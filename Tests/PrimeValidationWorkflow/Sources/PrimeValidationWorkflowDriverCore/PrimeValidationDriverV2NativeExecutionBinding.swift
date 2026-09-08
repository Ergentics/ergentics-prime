// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Dispatch
import Foundation
@_spi(PrimeValidationDriverV2RoleFacade) import PrimeCore
import PrimeValidationWorkflowContracts

/// This bridge is constructed only by consuming G's retained native lifetime.
/// Decoded plan/process values can be checked but cannot construct this owner.
@available(macOS 26.0, *)
package final class PrimeValidationDriverV2NativeExecutionBinding {
    package let plan: PrimeValidationExecutionPlanV2
    private let intent: PrimeValidationRunIntentV2
    private let build: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1
    private let inventory: PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1
    private let planning: PrimeValidationDriverV2ExecutionPlanObservation
    private let parser: PrimeValidationDriverV2ExecutionBinding
    private let lock = NSLock()
    private var owner: PrimeValidationDriverV2ExecutionOwner?
    private var parsed: [PrimeValidationDriverV2ParsedShardEvidence] = []
    private var observations: [PrimeValidationDriverV2ShardRawObservation] = []
    private var acceptanceData: [Data] = []
    private var conclusion: PrimeValidationDriverV2ParsedExecutionConclusion?

    package convenience init(inventoryBinding: PrimeValidationDriverV2InventoryBinding) throws {
        try self.init(raw: inventoryBinding.prepareNativeExecutionPlan(),
            intent: inventoryBinding.intent, build: inventoryBinding.predecessor,
            inventory: inventoryBinding.envelope)
    }

    private init(raw: PrimeValidationDriverV2ExecutionPlanRawCapability,
        intent: PrimeValidationRunIntentV2,
        build: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1,
        inventory: PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1) throws {
        var consumed = false
        defer { if !consumed { raw.rejectValidatedPlan() } }
        let original = try PrimeValidationExecutionPlanV2.make(
            intent: intent, buildReceipt: build.receipt, inventoryReceipt: inventory.receipt)
        try PrimeValidationDriverV2NativeExecutionValidation.validatePlan(
            raw.observation, intent: intent, build: build, inventory: inventory, plan: original)
        let parser = try PrimeValidationDriverV2ExecutionBinding(
            intent: intent, build: build.receipt, inventory: inventory.receipt, plan: original)
        self.intent = intent; self.build = build; self.inventory = inventory
        self.plan = original; self.planning = raw.observation; self.parser = parser
        owner = try raw.consumeValidatedPlan(originalPlanData: PrimeCanonicalJSON.encode(original))
        consumed = true
    }

    /// Only the next original shard can run. A failed raw join, parser error,
    /// failed terminal, or dropped raw capability permanently closes the route.
    package func executeNextShard() throws -> PrimeValidationDriverV2ParsedExecutionTransition {
        lock.lock(); defer { lock.unlock() }
        guard let current = owner, conclusion == nil, parsed.count < plan.shards.count else {
            owner = nil; throw nativeExecutionRejected("next_only")
        }
        owner = nil
        let raw = try current.executeNextShard()
        var accepted = false
        defer { if !accepted { raw.rejectValidatedAcceptance() } }
        let observation = raw.observation
        let index = parsed.count
        let previousHash = try acceptanceData.last.map { PrimeSHA256.hexDigest(of: $0) }
            ?? PrimeSHA256.hexDigest(of: PrimeCanonicalJSON.encode(planning))
        let child = try PrimeValidationDriverV2NativeExecutionValidation.validateShard(
            observation, index: index, intent: intent, build: build, plan: plan,
            planning: planning, previous: observations.last, predecessorSHA256: previousHash)
        let invocation = plan.shardInvocations[index]
        let stdout = try PrimeValidationDriverV2NativeExecutionValidation.bound(
            observation.standardOutputBinding, name: "standard_output",
            path: invocation.standardOutputRelativePath, data: observation.standardOutputData)
        let stderr = try PrimeValidationDriverV2NativeExecutionValidation.bound(
            observation.standardErrorBinding, name: "standard_error",
            path: invocation.standardErrorRelativePath, data: observation.standardErrorData)
        let result: PrimeValidationDriverV2BoundRawArtifact
        switch invocation.primaryResult {
        case .standardOutput:
            result = try .init(binding: .init(name: "result", relativePath: stdout.binding.relativePath,
                content: stdout.binding.content), data: stdout.data)
        case let .file(path):
            guard let binding = observation.resultBinding, let data = observation.resultData else {
                throw nativeExecutionRejected("missing_result")
            }
            result = try PrimeValidationDriverV2NativeExecutionValidation.bound(
                binding, name: "result", path: path, data: data)
        case .none: throw nativeExecutionRejected("result_kind")
        }
        let evidence = try parser.admit(start: .init(runID: plan.runID,
            executionPlanSHA256: parser.planSHA256, shard: plan.shards[index]),
            observedChild: child, result: result, standardOutput: stdout, standardError: stderr)
        let nextPrefix = parsed + [evidence]
        let transition = try parser.transition(after: nextPrefix)
        if transition == .stoppedAtFailedTerminal {
            // Retain the failed fact for diagnostics, never an advancing owner.
            parsed = nextPrefix; observations.append(observation)
            return transition
        }
        let bytes = try PrimeValidationDriverV2NativeExecutionValidation.acceptance(
            observation, transition: transition, nextOriginalShardID:
                index + 1 < plan.shards.count ? plan.shards[index + 1].shardID : "")
        let nextOwner = try raw.consumeValidatedAcceptance(acceptanceData: bytes)
        accepted = true
        parsed = nextPrefix; observations.append(observation); acceptanceData.append(bytes)
        owner = nextOwner
        return transition
    }

    /// A proposal owns a one-shot live permit and only parser-produced semantic
    /// outputs. Publication still requires held phase history and receipt-last
    /// manifest joins; this method performs no publication itself.
    package func consumeForPublication() throws -> PrimeValidationDriverV2NativeExecutionPublicationProposal {
        lock.lock(); defer { lock.unlock() }
        guard let current = owner, conclusion == nil,
              parsed.count == plan.shards.count, observations.count == parsed.count,
              acceptanceData.count == parsed.count, current.allShardsAccepted else {
            owner = nil; throw nativeExecutionRejected("incomplete_publication")
        }
        owner = nil
        try current.beginReconciliation()
        let conclusion = try parser.conclude(parsed)
        try current.finishReconciliation(validatedResultData: PrimeCanonicalJSON.encode(
            NativeExecutionReconciliation(reference: conclusion.reference, candidate: conclusion.candidate)))
        try current.beginComparison()
        // Re-run the exact final kernels in the separately measured comparison
        // phase. Their inputs remain parser-owned; no caller aggregate enters.
        let comparison = try PrimeValidationPairedSemanticComparatorV2.compareAssumingValidatedAggregates(
            reference: conclusion.reference, candidate: conclusion.candidate,
            executionPlan: plan, executionPlanSHA256: parser.planSHA256)
        let final = try PrimeValidationDriverFinalReceiptV2.makeAssumingValidatedComparison(
            comparison: comparison, reference: conclusion.reference, candidate: conclusion.candidate)
        guard try PrimeCanonicalJSON.encode(comparison) == PrimeCanonicalJSON.encode(conclusion.comparison),
              try PrimeCanonicalJSON.encode(final) == PrimeCanonicalJSON.encode(conclusion.finalReceipt) else {
            throw nativeExecutionRejected("comparison_repeat_join")
        }
        try current.finishComparison(validatedResultData: PrimeCanonicalJSON.encode(
            NativeExecutionComparison(comparison: comparison, finalReceipt: final)))
        self.conclusion = conclusion
        let permit = try current.consumeForPublication()
        let completed = permit.observation
        let originalData = try PrimeCanonicalJSON.encode(plan)
        let history = try PrimeCanonicalJSON.decode(PrimeValidationDriverV2PublicationPhaseHistoryV1.self,
            from: completed.phaseHistoryData)
        try history.validate(intent: intent, requireComplete: true)
        guard completed.canonicalIntentData == planning.canonicalIntentData,
              completed.declaredExecutionGoScopeData == planning.declaredExecutionGoScopeData,
              completed.predecessorInventoryBinding == planning.predecessorInventoryBinding,
              completed.packageResolvedBinding == planning.packageResolvedBinding,
              PrimeValidationContentBinding(data: completed.sourceSnapshotData) == intent.sourceSnapshot,
              completed.orderedShardIdentifiers == plan.shards.map(\.shardID),
              completed.orderedTerminalBindings == observations.map(\.terminalBinding),
              completed.orderedAcceptanceBindings.count == acceptanceData.count,
              history.immutablePrefixBindings == completed.orderedPhasePrefixBindings else {
            throw nativeExecutionRejected("completed_native_join")
        }
        try PrimeValidationDriverV2NativeExecutionValidation.artifact(
            completed.planBinding, path: "plan.json", data: originalData)
        try PrimeValidationDriverV2NativeExecutionValidation.artifact(
            completed.goBinding, path: "go.json", data: PrimeCanonicalJSON.encode(planning))
        for (index, bytes) in acceptanceData.enumerated() {
            try PrimeValidationDriverV2NativeExecutionValidation.artifact(
                completed.orderedAcceptanceBindings[index],
                path: PrimeValidationDriverV2NativeExecutionValidation.shardRoot(plan.shards[index]) + "/binding.json",
                data: bytes)
        }
        return .init(permit: permit, intent: intent, build: build, inventory: inventory,
            plan: plan, conclusion: conclusion, rawShards: observations, history: history)
    }
}

/// No decoder or caller initializer can create a publication proposal.
package final class PrimeValidationDriverV2NativeExecutionPublicationProposal {
    package let intent: PrimeValidationRunIntentV2
    package let build: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1
    package let inventory: PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1
    package let plan: PrimeValidationExecutionPlanV2
    package let conclusion: PrimeValidationDriverV2ParsedExecutionConclusion
    package let rawShards: [PrimeValidationDriverV2ShardRawObservation]
    package let history: PrimeValidationDriverV2PublicationPhaseHistoryV1
    private let lock = NSLock()
    private var permit: PrimeValidationDriverV2ExecutionPublicationPermit?
    fileprivate init(permit: PrimeValidationDriverV2ExecutionPublicationPermit,
        intent: PrimeValidationRunIntentV2, build: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1,
        inventory: PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1,
        plan: PrimeValidationExecutionPlanV2, conclusion: PrimeValidationDriverV2ParsedExecutionConclusion,
        rawShards: [PrimeValidationDriverV2ShardRawObservation], history: PrimeValidationDriverV2PublicationPhaseHistoryV1) {
        self.permit = permit; self.intent = intent; self.build = build; self.inventory = inventory
        self.plan = plan; self.conclusion = conclusion; self.rawShards = rawShards
        self.history = history
    }
    package func consumePermit() throws -> PrimeValidationDriverV2ExecutionPublicationPermit {
        lock.lock(); defer { lock.unlock() }
        guard let permit else { throw nativeExecutionRejected("proposal_consumed") }
        self.permit = nil; try permit.revalidate(); return permit
    }
}

/// Pure checks are deliberately separate for mutation testing. They do not
/// construct owners, resume native children, or accept caller semantic arrays.
package enum PrimeValidationDriverV2NativeExecutionValidation {
    package static func validatePlan(_ raw: PrimeValidationDriverV2ExecutionPlanObservation,
        intent: PrimeValidationRunIntentV2, build: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1,
        inventory: PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1,
        plan: PrimeValidationExecutionPlanV2) throws {
        try inventory.validate(intent: intent, expectedSupervisorPID: build.predecessorSupervisorPID,
            build: build, expectedBuildBinding: inventory.predecessorBuildBinding)
        try plan.validate(intent: intent, buildReceipt: build.receipt, inventoryReceipt: inventory.receipt)
        let intentData = try PrimeCanonicalJSON.encode(intent)
        guard raw.canonicalIntentData == intentData,
              raw.sourceSnapshotSHA256 == intent.sourceSnapshot.sha256,
              raw.packageResolvedBinding.byteCount == intent.packageLock.byteCount,
              raw.packageResolvedBinding.sha256 == intent.packageLock.sha256,
              raw.packageResolvedBinding.purpose == .immutableData,
              raw.packageResolvedBinding.relativePath == "Package.resolved",
              raw.xctestListData == inventory.receipt.xctestListData,
              raw.swiftTestingListData == inventory.receipt.swiftTestingListData,
              raw.xctestListBinding == inventory.children[0].standardOutputBinding,
              raw.swiftTestingListBinding == inventory.children[1].standardOutputBinding,
              raw.planningStartedAtUptimeNanoseconds >= inventory.children[1].process.waitReturnedUptimeNanoseconds,
              raw.planningStartedAtUptimeNanoseconds < inventory.children[1].process.deadlineExpiresAtUptimeNanoseconds,
              raw.planningExpiresAtUptimeNanoseconds > raw.planningStartedAtUptimeNanoseconds,
              raw.planningExpiresAtUptimeNanoseconds - raw.planningStartedAtUptimeNanoseconds == 30_000_000_000,
              raw.expectedOriginalExecutionPlanData == (try PrimeCanonicalJSON.encode(plan)) else {
            throw nativeExecutionRejected("original_plan_join")
        }
        try artifact(raw.predecessorInventoryBinding, path: "binding.json", data: PrimeCanonicalJSON.encode(inventory))
        try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateJournalBinding(
            raw.planningStartBinding, path: "phase-04-start.json",
            type: PrimeValidationDriverV2ExecutionPlanStartV1.self, object: [
            "schema": "prime_driver_v2_gate_h_execution_plan_start_v1", "runID": intent.runID,
            "intentSHA256": PrimeSHA256.hexDigest(of: intentData),
            "declaredExecutionGoScopeSHA256": PrimeSHA256.hexDigest(of: raw.declaredExecutionGoScopeData),
            "startedAtUptimeNanoseconds": raw.planningStartedAtUptimeNanoseconds,
            "expiresAtUptimeNanoseconds": raw.planningExpiresAtUptimeNanoseconds])
        let originalInventory = try PrimeValidationInventory.parse(
            xctestList: raw.xctestListData, swiftTestingList: raw.swiftTestingListData)
        guard raw.schedule.runID == intent.runID,
              raw.schedule.canonicalInventoryData == (try PrimeCanonicalJSON.encode(originalInventory)),
              raw.schedule.canonicalShardsData == (try PrimeCanonicalJSON.encode(plan.shards)),
              raw.schedule.shards.count == plan.shards.count else { throw nativeExecutionRejected("full_schedule") }
        for (index, shard) in raw.schedule.shards.enumerated() {
            try validateShardProjection(shard, original: plan.shards[index], index: index)
        }
        let go = try PrimeCanonicalJSON.decode(NativeExecutionGo.self, from: raw.declaredExecutionGoScopeData)
        try go.validate(intent: intent)
        _ = try PrimeValidationExecutorAdmissionPolicyV2.budgetProfile(for: intent)
    }

    package static func validateShardProjection(_ observed: PrimeValidationDriverV2ClosedShardObservation,
        original: PrimeValidationShardPlanV2, index: Int) throws {
        guard observed.ordinal == index + 1, observed.arm == original.key.arm.rawValue,
              observed.lane == original.key.lane.rawValue, observed.index == original.key.index,
              observed.shardID == original.shardID, observed.selectedIdentifiers == original.testIDs.map(\.rawValue),
              observed.filterPattern == original.filterPattern,
              observed.canonicalPlanData == (try PrimeCanonicalJSON.encode(original)) else {
            throw nativeExecutionRejected("shard_projection")
        }
    }

    package static func validateShard(_ raw: PrimeValidationDriverV2ShardRawObservation, index: Int,
        intent: PrimeValidationRunIntentV2, build: PrimeValidationDriverV2BuildDurableBindingEnvelopeV1,
        plan: PrimeValidationExecutionPlanV2, planning: PrimeValidationDriverV2ExecutionPlanObservation,
        previous: PrimeValidationDriverV2ShardRawObservation?, predecessorSHA256: String) throws
        -> PrimeValidationObservedChildReceiptV2 {
        guard plan.shards.indices.contains(index), plan.shardInvocations.indices.contains(index) else {
            throw nativeExecutionRejected("shard_index")
        }
        let shard = plan.shards[index], invocation = plan.shardInvocations[index], p = raw.process
        try validateShardProjection(raw.shard, original: shard, index: index)
        let budgetProfile = try PrimeValidationExecutorAdmissionPolicyV2.budgetProfile(for: intent)
        try validateNativeProcess(p, supervisorPID: build.predecessorSupervisorPID, budgetProfile: budgetProfile)
        let planHash = PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(plan))
        let physical = build.toolchain.swiftPackageExecutable
        let expectedLaunch = try PrimeValidationSwiftPackageAdmissionLaunchPlanV2.make(
            intent: intent, toolchain: build.toolchain).launches[1]
        try p.validatePhysicalArgumentZero()
        guard let physicalArgumentZero = p.physicalArgumentZero,
              physicalArgumentZero == (try expectedLaunch.physicalArgumentZero()),
              raw.executionPlanSHA256 == planHash, invocation.role == .shard,
              invocation.arguments.first == "test", p.logicalArgumentZero == "swift-test",
              p.arguments == PrimeValidationDriverV2SwiftPMPhysicalArguments.testabilityPrefix + Array(invocation.arguments.dropFirst()),
              p.orderedEnvironment == expectedLaunch.orderedCompleteReplacementEnvironment.map({ [$0.key, $0.value] }),
              p.executableAbsolutePath == physical.canonicalAbsolutePath,
              p.executableByteCount == physical.content.byteCount, p.executableSHA256 == physical.content.sha256,
              p.executableDeviceID == physical.deviceID, p.executableInode == physical.inode,
              p.workingDirectoryAbsolutePath == intent.roots.repositoryRoot.absolutePath,
              p.workingDirectoryDeviceID == intent.roots.repositoryRoot.deviceID,
              p.workingDirectoryInode == intent.roots.repositoryRoot.inode,
              p.standardOutput.outputDeviceID == intent.roots.evidenceRoot.deviceID,
              p.standardError.outputDeviceID == intent.roots.evidenceRoot.deviceID,
              p.standardOutput.outputInode != p.standardError.outputInode else {
            throw nativeExecutionRejected("physical_shard_policy")
        }
        let intervalStart: UInt64
        if let previous {
            guard index > 0, previous.shard.shardID == plan.shards[index - 1].shardID,
                  p.spawnReturnedUptimeNanoseconds >= previous.process.waitReturnedUptimeNanoseconds else {
                throw nativeExecutionRejected("chronological_prefix")
            }
            if previous.shard.arm == raw.shard.arm {
                guard p.deadlineStartedAtUptimeNanoseconds == previous.process.deadlineStartedAtUptimeNanoseconds,
                      p.deadlineExpiresAtUptimeNanoseconds == previous.process.deadlineExpiresAtUptimeNanoseconds else {
                    throw nativeExecutionRejected("shared_arm_deadline")
                }
                intervalStart = previous.process.waitReturnedUptimeNanoseconds
            } else {
                guard previous.shard.arm == "reference", raw.shard.arm == "candidate",
                      p.deadlineStartedAtUptimeNanoseconds >= previous.process.waitReturnedUptimeNanoseconds,
                      p.deadlineStartedAtUptimeNanoseconds < previous.process.deadlineExpiresAtUptimeNanoseconds else {
                    throw nativeExecutionRejected("arm_transfer")
                }
                intervalStart = p.deadlineStartedAtUptimeNanoseconds
            }
        } else {
            guard index == 0, raw.shard.arm == "reference",
                  p.deadlineStartedAtUptimeNanoseconds >= planning.planningStartedAtUptimeNanoseconds,
                  p.deadlineStartedAtUptimeNanoseconds < planning.planningExpiresAtUptimeNanoseconds else {
                throw nativeExecutionRejected("plan_transfer")
            }
            intervalStart = p.deadlineStartedAtUptimeNanoseconds
        }
        let root = shardRoot(shard)
        let fields: [String: Any] = ["schema": "prime_driver_v2_gate_h_shard_prestart_v1",
            "executionPlanSHA256": planHash, "shardID": shard.shardID, "runID": intent.runID,
            "ordinal": index + 1, "role": "shard", "predecessorSHA256": predecessorSHA256,
            "deadlineStartedAtUptimeNanoseconds": p.deadlineStartedAtUptimeNanoseconds,
            "deadlineExpiresAtUptimeNanoseconds": p.deadlineExpiresAtUptimeNanoseconds,
            "executableAbsolutePath": p.executableAbsolutePath, "executableSHA256": p.executableSHA256,
            "logicalArgumentZero": p.logicalArgumentZero, "physicalArgumentZero": physicalArgumentZero, "arguments": p.arguments,
            "orderedEnvironment": p.orderedEnvironment, "workingDirectoryAbsolutePath": p.workingDirectoryAbsolutePath]
        try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateJournalBinding(
            raw.prestartBinding, path: root + "/prestart.json",
            type: PrimeValidationDriverV2ExecutionPrestartV1.self, object: fields)
        try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateJournalBinding(
            raw.startBinding, path: root + "/start.json", type: PrimeValidationDriverV2InventoryStartV1.self, object: [
            "schema": "prime_driver_v2_gate_h_shard_start_v1", "role": "shard",
            "prestartSHA256": raw.prestartBinding.sha256, "processIdentifier": p.processIdentifier,
            "sessionIdentifier": p.sessionIdentifier, "processGroupIdentifier": p.processGroupIdentifier,
            "appliedSpawnFlags": p.appliedSpawnFlags, "spawnReturnedUptimeNanoseconds": p.spawnReturnedUptimeNanoseconds,
            "mappedExecutablePathTelemetry": p.executableAbsolutePath,
            "exactSuspendedWorkingDirectoryJoin": p.exactSuspendedWorkingDirectoryJoin])
        try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateJournalBinding(
            raw.terminalBinding, path: root + "/terminal.json", type: PrimeValidationDriverV2InventoryTerminalV1.self, object: [
            "schema": "prime_driver_v2_gate_h_shard_terminal_v1", "role": "shard",
            "startSHA256": raw.startBinding.sha256,
            "process": JSONSerialization.jsonObject(with: PrimeCanonicalJSON.encode(p))])
        let stdout = try bound(raw.standardOutputBinding, name: "standard_output",
            path: invocation.standardOutputRelativePath, data: raw.standardOutputData)
        let stderr = try bound(raw.standardErrorBinding, name: "standard_error",
            path: invocation.standardErrorRelativePath, data: raw.standardErrorData)
        guard raw.standardOutputBinding.sha256 == p.standardOutput.outputSHA256,
              raw.standardOutputBinding.byteCount == p.standardOutput.outputByteCount,
              raw.standardErrorBinding.sha256 == p.standardError.outputSHA256,
              raw.standardErrorBinding.byteCount == p.standardError.outputByteCount else {
            throw nativeExecutionRejected("stream_native_join")
        }
        let primary: PrimeValidationObservedPrimaryResultV2
        switch invocation.primaryResult {
        case .standardOutput:
            guard raw.resultBinding == nil, raw.resultData == nil else { throw nativeExecutionRejected("unexpected_xunit") }
            primary = .standardOutput
        case let .file(path):
            guard let binding = raw.resultBinding, let data = raw.resultData else { throw nativeExecutionRejected("missing_xunit") }
            primary = .file(try bound(binding, name: "primary_result", path: path, data: data).binding)
        case .none: throw nativeExecutionRejected("result_kind")
        }
        // matchedTestCount is only assigned after the strict parser has proved
        // the exact unchanged selected-ID set from these raw bytes.
        let resultRaw: PrimeValidationDriverV2BoundRawArtifact
        if case .standardOutput = invocation.primaryResult { resultRaw = stdout }
        else { resultRaw = try bound(raw.resultBinding!, name: "result",
            path: raw.resultBinding!.relativePath, data: raw.resultData!) }
        _ = try PrimeValidationDriverV2ParsedRawResults.parse(lane: shard.key.lane,
            expectedIDs: shard.testIDs, selectionMode: shard.selectionMode, raw: resultRaw)
        let child = try makeChild(invocation: invocation, primary: primary, process: p,
            intervalStartedAt: intervalStart, matchedCount: shard.testIDs.count,
            stdout: stdout.binding, stderr: stderr.binding, supervisorPID: build.predecessorSupervisorPID,
            budgetProfile: budgetProfile)
        try child.validate(expectedInvocation: invocation,
            maximumActiveNanoseconds: budgetProfile.executionArmMaximumActiveNanoseconds)
        return child
    }

    package static func validateNativeProcess(_ p: PrimeValidationDriverV2BuildProcessObservation,
        supervisorPID: Int32, budgetProfile: PrimeValidationDriverV2ExecutionBudgetProfile = .frozenV1) throws {
        let flags = UInt16(POSIX_SPAWN_START_SUSPENDED) | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
            | UInt16(POSIX_SPAWN_SETPGROUP) | UInt16(POSIX_SPAWN_SETSIGDEF) | UInt16(POSIX_SPAWN_SETSIGMASK)
        guard supervisorPID > 0, p.processIdentifier > 0, p.processIdentifier != supervisorPID,
              p.sessionIdentifier == supervisorPID, p.parentProcessIdentifier == supervisorPID,
              p.processGroupIdentifier == p.processIdentifier,
              p.mappedImageJoined, p.exactSuspendedWorkingDirectoryJoin,
              p.appliedSpawnFlags == flags, p.spawnReturnCode == 0,
              p.deadlineStartedAtUptimeNanoseconds > 0,
              p.deadlineExpiresAtUptimeNanoseconds > p.deadlineStartedAtUptimeNanoseconds,
              p.deadlineExpiresAtUptimeNanoseconds - p.deadlineStartedAtUptimeNanoseconds == budgetProfile.executionArmMaximumActiveNanoseconds,
              p.spawnReturnedUptimeNanoseconds >= p.deadlineStartedAtUptimeNanoseconds,
              p.resumedAtUptimeNanoseconds >= p.spawnReturnedUptimeNanoseconds,
              p.deathObservedUptimeNanoseconds >= p.resumedAtUptimeNanoseconds,
              p.waitReturnedUptimeNanoseconds >= p.deathObservedUptimeNanoseconds,
              p.waitReturnedUptimeNanoseconds < p.deadlineExpiresAtUptimeNanoseconds,
              p.preReapProcessGroupMemberIdentifiers == [p.processIdentifier],
              p.requestedWaitProcessIdentifier == p.processIdentifier,
              p.returnedWaitProcessIdentifier == p.processIdentifier, p.exactReapCount == 1,
              !p.cleanupInitiated, p.waitOptions == 0, p.exitedNormally,
              p.exitStatus >= 0, p.exitStatus <= 255, p.rawWaitStatus == p.exitStatus << 8,
              p.terminationSignal == 0, !p.coreDumped, p.processGroupEmptyAfterReap else {
            throw nativeExecutionRejected("native_lifecycle")
        }
        try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateStream(p.standardOutput)
        try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateStream(p.standardError)
    }

    package static func makeChild(invocation: PrimeValidationInvocationV2,
        primary: PrimeValidationObservedPrimaryResultV2, process p: PrimeValidationDriverV2BuildProcessObservation,
        intervalStartedAt: UInt64, matchedCount: Int,
        stdout: PrimeValidationDriverArtifactBindingV2, stderr: PrimeValidationDriverArtifactBindingV2,
        supervisorPID: Int32, budgetProfile: PrimeValidationDriverV2ExecutionBudgetProfile = .frozenV1)
        throws -> PrimeValidationObservedChildReceiptV2 {
        try validateNativeProcess(p, supervisorPID: supervisorPID, budgetProfile: budgetProfile)
        guard intervalStartedAt >= p.deadlineStartedAtUptimeNanoseconds,
              p.waitReturnedUptimeNanoseconds > intervalStartedAt,
              matchedCount >= 0 else { throw nativeExecutionRejected("active_interval") }
        func stream(_ s: PrimeValidationDriverV2BuildStreamObservation) -> PrimeValidationStreamAuditV2 {
            .init(eofObserved: s.reachedEOF, totalByteCount: s.totalByteCount,
                capturedByteCount: s.capturedByteCount, overflowObserved: s.overflowed,
                readErrorNumber: s.readErrorNumber, writeErrorNumber: s.writeErrorNumber)
        }
        return .init(invocation: invocation, primaryResult: primary,
            standardOutputArtifact: stdout, standardErrorArtifact: stderr,
            process: .init(processIdentifier: p.processIdentifier, sessionIdentifier: p.sessionIdentifier,
                processGroupIdentifier: p.processGroupIdentifier, deadlineDisposition: .completed,
                sigtermDelivery: .notAttempted, sigkillDelivery: .notAttempted,
                preReapProcessGroupMembers: p.preReapProcessGroupMemberIdentifiers,
                exactReturnedProcessIdentifier: p.returnedWaitProcessIdentifier, rawWaitStatus: p.rawWaitStatus,
                waitTermination: .exited(p.exitStatus), processGroupEmptyAfterReap: p.processGroupEmptyAfterReap,
                standardOutput: stream(p.standardOutput), standardError: stream(p.standardError),
                matchedTestCount: matchedCount, supervisorSessionIdentifier: supervisorPID),
            activeNanoseconds: p.waitReturnedUptimeNanoseconds - intervalStartedAt)
    }

    package static func acceptance(_ raw: PrimeValidationDriverV2ShardRawObservation,
        transition: PrimeValidationDriverV2ParsedExecutionTransition, nextOriginalShardID: String) throws -> Data {
        let label: String
        switch transition {
        case let .nextShard(shardID, _):
            guard !nextOriginalShardID.isEmpty, shardID == nextOriginalShardID else { throw nativeExecutionRejected("next_id") }
            label = "next_shard"
        case .readyForConclusion:
            guard nextOriginalShardID.isEmpty else { throw nativeExecutionRejected("early_conclusion") }
            label = "ready_for_conclusion"
        case .stoppedAtFailedTerminal: throw nativeExecutionRejected("failed_acceptance")
        }
        return try PrimeCanonicalJSON.encode(NativeExecutionAcceptance(
            schema: "prime_driver_v2_gate_h_parsed_shard_acceptance_v1",
            executionPlanSHA256: raw.executionPlanSHA256,
            rawObservationSHA256: PrimeSHA256.hexDigest(of: PrimeCanonicalJSON.encode(raw)),
            shardID: raw.shard.shardID, nextShardID: nextOriginalShardID, semanticTransition: label))
    }
    package static func shardRoot(_ shard: PrimeValidationShardPlanV2) -> String {
        "shards/" + shard.key.arm.rawValue + "/" + shard.key.lane.rawValue + "/"
            + String(shard.key.index) + "-" + String(shard.shardID.prefix(16))
    }
    package static func artifact(_ binding: PrimeArtifactBinding, path: String, data: Data) throws {
        try PrimeValidationDriverV2InventoryDurableBindingEnvelopeV1.validateArtifact(binding, path: path, data: data)
    }
    package static func bound(_ binding: PrimeArtifactBinding, name: String,
        path: String, data: Data) throws -> PrimeValidationDriverV2BoundRawArtifact {
        try artifact(binding, path: path, data: data)
        return try .init(binding: .init(name: name, relativePath: path,
            content: .init(data: data)), data: data)
    }
}

private struct NativeExecutionAcceptance: Codable {
    let schema: String
    let executionPlanSHA256: String
    let rawObservationSHA256: String
    let shardID: String
    let nextShardID: String
    let semanticTransition: String
}

private struct NativeExecutionReconciliation: Codable {
    let reference: PrimeValidationArmAggregateV2
    let candidate: PrimeValidationArmAggregateV2
}

private struct NativeExecutionComparison: Codable {
    let comparison: PrimeValidationPairedComparisonReceiptV2
    let finalReceipt: PrimeValidationDriverFinalReceiptV2
}

private struct NativeExecutionGo: Codable {
    let schema: String
    let intentSHA256: String
    let sourceCommit: String
    let sourceTree: String
    let sourceTreeReplaySHA256: String
    let sourceIdentitySHA256: String
    let governorExecutable: PrimeValidationExecutableBindingV2
    let supervisorExecutable: PrimeValidationExecutableBindingV2
    let referenceScopes: [String]
    let candidateScope: String
    let referenceMaximumActiveNanoseconds: UInt64
    let candidateMaximumActiveNanoseconds: UInt64
    func validate(intent: PrimeValidationRunIntentV2) throws {
        let profile = try PrimeValidationExecutorAdmissionPolicyV2.budgetProfile(for: intent)
        guard schema == "prime_driver_v2_gate_h_declared_execution_scope_v1",
              intentSHA256 == (try intent.identitySHA256()), supervisorExecutable == intent.driverExecutable,
              referenceScopes == ["parallel_xctest", "sequential_xctest", "swift_testing"],
              candidateScope == "frozen_suite_contiguous_32_original_planner",
              referenceMaximumActiveNanoseconds == profile.executionArmMaximumActiveNanoseconds,
              candidateMaximumActiveNanoseconds == profile.executionArmMaximumActiveNanoseconds,
              [sourceCommit, sourceTree].allSatisfy({ value in
                  value.utf8.count == 40 && value.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) })
              }) else { throw nativeExecutionRejected("declared_go") }
        try PrimeValidationDriverV2Validation.requireSHA256(sourceIdentitySHA256)
        try PrimeValidationDriverV2Validation.requireSHA256(sourceTreeReplaySHA256)
        try governorExecutable.validate(); try supervisorExecutable.validate()
        // Core joins retained source identity, actual E HEAD/tree-replay bytes
        // and the supervisor declaration. The root tree OID stays declared
        // source-pin metadata; the governor independently holds its images.
    }
}

private func nativeExecutionRejected(_ reason: String) -> PrimeValidationDriverV2Error {
    .invalidBinding("native_execution_" + reason)
}
