// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary
// DRAFT. No constructor below is available from decoded receipt data.
import Darwin
import Dispatch
import Foundation

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2ExecutionPlanStartV1: Codable, Equatable, Sendable {
    public let schema: String
    public let runID: String
    public let intentSHA256: String
    public let declaredExecutionGoScopeSHA256: String
    public let startedAtUptimeNanoseconds: UInt64
    public let expiresAtUptimeNanoseconds: UInt64
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2ExecutionPlanObservation: Codable, Equatable, Sendable {
    public let canonicalIntentData: Data
    public let declaredExecutionGoScopeData: Data
    public let planningStartBinding: PrimeArtifactBinding
    public let predecessorInventoryBinding: PrimeArtifactBinding
    public let xctestListBinding: PrimeArtifactBinding
    public let swiftTestingListBinding: PrimeArtifactBinding
    public let xctestListData: Data
    public let swiftTestingListData: Data
    public let schedule: PrimeValidationDriverV2ClosedScheduleObservation
    public let expectedOriginalExecutionPlanData: Data
    public let sourceSnapshotSHA256: String
    public let packageResolvedBinding: PrimeArtifactBinding
    public let planningStartedAtUptimeNanoseconds: UInt64
    public let planningExpiresAtUptimeNanoseconds: UInt64
}

struct PrimeValidationDriverV2ClosedExecutionPolicy {
    let physicalExecutableAbsolutePath: String
    let logicalArgumentZero = "swift-test"
    let physicalArgumentZero: String
    let physicalArguments: [String]
    let completeReplacementEnvironment: [(String, String)]
    let physicalWorkingDirectoryAbsolutePath: String
    let standardOutputMaximumByteCount: UInt64 = 16 * 1024 * 1024

    static func originalLogicalArguments(physical: [String]) throws -> [String] {
        let prefix = PrimeValidationDriverV2SwiftPMPhysicalArguments.testabilityPrefix
        guard physical.starts(with: prefix), physical.count > prefix.count else {
            throw hRejected("physical_testability_prefix")
        }
        return ["test"] + physical.dropFirst(prefix.count)
    }
}

/// Pure next-only state used by the live owner under its lock. A failed start
/// or mismatched completion poisons the entire remaining schedule.
struct PrimeValidationDriverV2ExecutionCursor {
    let count: Int
    private(set) var next = 0
    private(set) var awaiting = false
    private(set) var poisoned = false
    var allAccepted: Bool { !poisoned && count > 0 && next == count && !awaiting }
    mutating func begin() throws -> Int {
        guard !poisoned, !awaiting, next < count else { stop(); throw hRejected("next_only") }
        let index = next
        next += 1; awaiting = true
        return index
    }
    mutating func accept(index: Int) throws {
        guard !poisoned, awaiting, next > 0, index == next - 1 else {
            stop(); throw hRejected("accept_current_only")
        }
        awaiting = false
    }
    mutating func stop() { poisoned = true }
}

/// Consumes G, retains its native roots, and exposes only data for the original
/// DriverCore planner to compare before accepting this one-shot capability.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2ExecutionPlanRawCapability: @unchecked Sendable {
    public let observation: PrimeValidationDriverV2ExecutionPlanObservation
    private let lock = NSLock()
    private var state: PrimeValidationDriverV2InventoryExecutionState?
    private let inventoryStaging: PrimeValidationDriverV2InventoryStaging
    private let planningDeadline: PrimeSecureChildPhaseDeadline
    private let policies: [PrimeValidationDriverV2ClosedExecutionPolicy]
    private let staging: PrimeValidationDriverV2ExecutionStaging

    init(state: PrimeValidationDriverV2InventoryExecutionState,
         inventoryStaging: PrimeValidationDriverV2InventoryStaging) throws {
        guard state.context.executionAuthorized else { throw hRejected("H_not_authorized") }
        self.state = state; self.inventoryStaging = inventoryStaging
        planningDeadline = try .init(startUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds,
            durationNanoseconds: 30_000_000_000)
        try PrimeValidationDriverV2ExecutionGoScope.validate(state.context.executionGoScopeData,
            intentData: state.context.canonicalExecutionIntentData,
            retainedSourceIdentitySHA256: state.retainedState.admission.sourceSnapshot.sourceIdentitySHA256)
        guard let predecessor = state.executionPredecessorObservation else { throw hRejected("go_native_E_missing") }
        try PrimeValidationDriverV2ExecutionGoScope.joinObservedPrime(state.context.executionGoScopeData,
            predecessor: predecessor,
            retainedSourceIdentitySHA256: state.retainedState.admission.sourceSnapshot.sourceIdentitySHA256)
        staging = try .init(build: state.buildStaging)
        let planningStart = try staging.publish(PrimeValidationDriverV2ExecutionPlanStartV1(
            schema: "prime_driver_v2_gate_h_execution_plan_start_v1",
            runID: state.context.evidenceRunID,
            intentSHA256: PrimeSHA256.hexDigest(of: state.context.canonicalExecutionIntentData),
            declaredExecutionGoScopeSHA256: PrimeSHA256.hexDigest(of: state.context.executionGoScopeData),
            startedAtUptimeNanoseconds: planningDeadline.startUptimeNanoseconds,
            expiresAtUptimeNanoseconds: planningDeadline.expiresAtUptimeNanoseconds
        ), path: "phase-04-start.json")
        let root = inventoryStaging.root
        let previous = try root.bindExisting(at: "binding.json", purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024)
        let x = try root.bindExisting(at: "xctest-list.stdout.log", purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024)
        let s = try root.bindExisting(at: "swift-testing-list.stdout.log", purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024)
        let xd = try root.readVerified(x, maximumByteCount: 16 * 1024 * 1024)
        let sd = try root.readVerified(s, maximumByteCount: 16 * 1024 * 1024)
        let intent = try HJSON.object(state.context.canonicalExecutionIntentData)
        guard let baseline = intent["baseline"],
              let inventoryProfile = try PrimeValidationDriverV2InventoryProfile.resolve(
                canonicalBaselineData: HJSON.encode(baseline))
        else { throw hRejected("intent_inventory_profile") }
        let schedule = try PrimeValidationDriverV2ClosedShardSchedule.observeFrozenLists(
            runID: state.context.evidenceRunID, xctestData: xd, swiftTestingData: sd,
            profile: inventoryProfile)
        let inventoryEnvelope = try HJSON.object(root.readVerified(previous, maximumByteCount: 16 * 1024 * 1024))
        let buildBinding = try state.buildStaging.buildRoot.bindExisting(at: "binding.json", purpose: .immutableData, maximumByteCount: 16 * 1024 * 1024)
        let buildEnvelope = try HJSON.object(state.buildStaging.buildRoot.readVerified(buildBinding, maximumByteCount: 16 * 1024 * 1024))
        let source = try PrimeCanonicalJSON.encode(state.retainedState.admission.sourceSnapshot)
        let resolved = state.retainedState.admission.packageResolvedBinding
        let policy = try PrimeValidationDriverV2ClosedRolePolicy.fixedSequence(context: state.context,
            toolchain: state.retainedState.admission.toolchain.observation)[1]
        guard policy.logicalArgumentZero == "swift-test",
              policy.physicalArguments.suffix(2) == ["--disable-swift-testing", "list"],
              intent["runID"] as? String == state.context.evidenceRunID,
              let sourceBinding = intent["sourceSnapshot"], let lockBinding = intent["packageLock"],
              try HJSON.encode(sourceBinding) == HJSON.encode(["byteCount": source.count, "sha256": PrimeSHA256.hexDigest(of: source)]),
              try HJSON.encode(lockBinding) == HJSON.encode(["byteCount": resolved.byteCount, "sha256": resolved.sha256]),
              let phases = intent["phaseBudgets"] as? [[String: Any]],
              let environment = intent["environmentPolicy"] as? [String: Any],
              let logicalEnvironment = environment["orderedEntries"], let swift = intent["swiftExecutable"],
              let iReceipt = inventoryEnvelope["receipt"], let bReceipt = buildEnvelope["receipt"]
        else { throw hRejected("intent_or_retained_scope") }
        for (phase, duration) in [("execution_plan", UInt64(30_000_000_000)),
                                  ("reference_execution", UInt64(1_800_000_000_000)),
                                  ("candidate_execution", UInt64(1_800_000_000_000))] {
            let entries = phases.filter { $0["phase"] as? String == phase }
            guard entries.count == 1, (entries[0]["maximumActiveNanoseconds"] as? NSNumber)?.uint64Value == duration else { throw hRejected("frozen_phase_budget") }
        }
        var nativePolicies: [PrimeValidationDriverV2ClosedExecutionPolicy] = []
        var invocations: [[String: Any]] = []
        for shard in schedule.shards {
            var arguments = Array(policy.physicalArguments.dropLast(2))
            switch shard.lane {
            case "parallel_xctest": arguments += ["--disable-swift-testing", "--parallel", "--num-workers", "1"]
            case "sequential_xctest": arguments += ["--disable-swift-testing", "--no-parallel"]
            case "swift_testing": arguments += ["--disable-xctest", "--no-parallel"]
            default: throw hRejected("closed_lane")
            }
            if shard.arm == "candidate" { arguments += ["--filter", shard.filterPattern] }
            if shard.requiresXUnit { arguments += ["--xunit-output", state.context.outputAbsolutePath + "/" + shard.relativeRoot + "/result.xml"] }
            nativePolicies.append(.init(physicalExecutableAbsolutePath: policy.physicalExecutableAbsolutePath,
                physicalArgumentZero: policy.physicalArgumentZero,
                physicalArguments: arguments, completeReplacementEnvironment: policy.completeReplacementEnvironment,
                physicalWorkingDirectoryAbsolutePath: policy.physicalWorkingDirectoryAbsolutePath))
            let shardObject = try HJSON.object(shard.canonicalPlanData)
            invocations.append(["runID": schedule.runID, "role": "shard", "shardKey": shardObject["key"]!,
                "shardID": shard.shardID, "executable": swift, "arguments": try PrimeValidationDriverV2ClosedExecutionPolicy.originalLogicalArguments(physical: arguments),
                "orderedEnvironment": logicalEnvironment, "workingDirectoryAbsolutePath": state.context.repositoryRootAbsolutePath,
                "primaryResult": shard.requiresXUnit ? ["file": ["relativePath": shard.relativeRoot + "/result.xml"]] : ["standardOutput": [:]],
                "standardOutputRelativePath": shard.relativeRoot + "/stdout.log",
                "standardErrorRelativePath": shard.relativeRoot + "/stderr.log"])
        }
        policies = nativePolicies
        let expectedPlan: [String: Any] = ["schemaVersion": 2, "runID": schedule.runID,
            "intentSHA256": PrimeSHA256.hexDigest(of: state.context.canonicalExecutionIntentData),
            "buildReceiptSHA256": PrimeSHA256.hexDigest(of: try HJSON.encode(bReceipt)),
            "inventoryReceiptSHA256": PrimeSHA256.hexDigest(of: try HJSON.encode(iReceipt)),
            "baseline": baseline, "inventory": try HJSON.object(schedule.canonicalInventoryData),
            "inventorySHA256": PrimeSHA256.hexDigest(of: schedule.canonicalInventoryData),
            "maximumReferenceShardActiveNanoseconds": UInt64(1_800_000_000_000),
            "maximumCandidateShardActiveNanoseconds": UInt64(1_800_000_000_000),
            "shards": try JSONSerialization.jsonObject(with: schedule.canonicalShardsData), "shardInvocations": invocations]
        observation = .init(canonicalIntentData: state.context.canonicalExecutionIntentData,
            declaredExecutionGoScopeData: state.context.executionGoScopeData,
            planningStartBinding: planningStart,
            predecessorInventoryBinding: previous, xctestListBinding: x, swiftTestingListBinding: s,
            xctestListData: xd, swiftTestingListData: sd, schedule: schedule,
            expectedOriginalExecutionPlanData: try HJSON.encode(expectedPlan),
            sourceSnapshotSHA256: PrimeSHA256.hexDigest(of: source), packageResolvedBinding: resolved,
            planningStartedAtUptimeNanoseconds: planningDeadline.startUptimeNanoseconds,
            planningExpiresAtUptimeNanoseconds: planningDeadline.expiresAtUptimeNanoseconds)
        try Self.checkpoint(state, inventory: inventoryStaging, deadline: planningDeadline)
        try staging.revalidate()
    }

    public func consumeValidatedPlan(originalPlanData: Data) throws -> PrimeValidationDriverV2ExecutionOwner {
        lock.lock(); defer { lock.unlock() }
        guard let state else { throw hRejected("plan_consumed") }
        self.state = nil
        guard originalPlanData == observation.expectedOriginalExecutionPlanData else { throw hRejected("original_planner_parity") }
        try Self.checkpoint(state, inventory: inventoryStaging, deadline: planningDeadline)
        try staging.revalidate()
        return try .init(state: state, inventory: inventoryStaging, observation: observation,
                         policies: policies, planningDeadline: planningDeadline, staging: staging)
    }
    public func rejectValidatedPlan() { lock.lock(); state = nil; lock.unlock() }
    deinit { state = nil }

    static func checkpoint(_ state: PrimeValidationDriverV2InventoryExecutionState,
        inventory: PrimeValidationDriverV2InventoryStaging, deadline: PrimeSecureChildPhaseDeadline) throws {
        let before = DispatchTime.now().uptimeNanoseconds
        guard try deadline.authorizesNewWork(observedAtUptimeNanoseconds: before) else { throw hRejected("deadline") }
        try state.retainedState.buildRevalidateTransferredContinuity(staging: state.buildStaging)
        try inventory.revalidate()
        try state.pinnedBundleInput.revalidateAfterBuild(deadlineNanoseconds: deadline.expiresAtUptimeNanoseconds)
        try state.artifacts.revalidateAfterBuild(deadlineNanoseconds: deadline.expiresAtUptimeNanoseconds)
        try state.retainedState.buildRevalidateTransferredContinuity(staging: state.buildStaging)
        guard try deadline.authorizesNewWork(observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds,
            notBeforeUptimeNanoseconds: before) else { throw hRejected("deadline") }
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2ShardRawObservation: Codable, Equatable, Sendable {
    public let shard: PrimeValidationDriverV2ClosedShardObservation
    public let executionPlanSHA256: String
    public let process: PrimeValidationDriverV2BuildProcessObservation
    public let prestartBinding: PrimeArtifactBinding
    public let startBinding: PrimeArtifactBinding
    public let terminalBinding: PrimeArtifactBinding
    public let standardOutputBinding: PrimeArtifactBinding
    public let standardErrorBinding: PrimeArtifactBinding
    public let standardOutputData: Data
    public let standardErrorData: Data
    public let resultBinding: PrimeArtifactBinding?
    public let resultData: Data?
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2ShardRawCapability: @unchecked Sendable {
    public let observation: PrimeValidationDriverV2ShardRawObservation
    private let lock = NSLock()
    private var owner: PrimeValidationDriverV2ExecutionOwner?
    init(observation: PrimeValidationDriverV2ShardRawObservation, owner: PrimeValidationDriverV2ExecutionOwner) {
        self.observation = observation; self.owner = owner
    }
    /// The admitted DriverCore bridge supplies its parser-derived transition.
    /// Native code rechecks the raw identity and exact next fixed shard only.
    public func consumeValidatedAcceptance(acceptanceData: Data) throws -> PrimeValidationDriverV2ExecutionOwner {
        lock.lock(); defer { lock.unlock() }
        guard let owner else { throw hRejected("raw_shard_consumed") }
        self.owner = nil
        do { try owner.accept(observation, data: acceptanceData); return owner }
        catch { owner.poison(); throw error }
    }
    public func rejectValidatedAcceptance() { lock.lock(); owner?.poison(); owner = nil; lock.unlock() }
    deinit { owner?.poison() }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2ExecutionOwner: @unchecked Sendable {
    private let lock = NSLock()
    private var state: PrimeValidationDriverV2InventoryExecutionState?
    private let inventory: PrimeValidationDriverV2InventoryStaging
    let observation: PrimeValidationDriverV2ExecutionPlanObservation
    let staging: PrimeValidationDriverV2ExecutionStaging
    private let policies: [PrimeValidationDriverV2ClosedExecutionPolicy]
    private var deadline: PrimeSecureChildPhaseDeadline
    private let phaseWriter: PrimeValidationDriverV2ExecutionPhaseWriter
    private var arm = "reference"
    private var cursor: PrimeValidationDriverV2ExecutionCursor
    private var next: Int { cursor.next }
    private var awaiting: Bool { cursor.awaiting }
    private var previousTerminalSHA256: String
    private var terminalBindings: [PrimeArtifactBinding] = []
    private var acceptanceBindings: [PrimeArtifactBinding] = []
    private var armFirstPrestart: PrimeArtifactBinding?
    private var armAcceptanceBindings: [PrimeArtifactBinding] = []
    private let goBinding: PrimeArtifactBinding
    private let planBinding: PrimeArtifactBinding
    let planSHA256: String

    init(state: PrimeValidationDriverV2InventoryExecutionState, inventory: PrimeValidationDriverV2InventoryStaging,
        observation: PrimeValidationDriverV2ExecutionPlanObservation, policies: [PrimeValidationDriverV2ClosedExecutionPolicy],
        planningDeadline: PrimeSecureChildPhaseDeadline, staging: PrimeValidationDriverV2ExecutionStaging) throws {
        self.state = state; self.inventory = inventory; self.observation = observation; self.policies = policies
        cursor = .init(count: policies.count)
        self.staging = staging
        deadline = planningDeadline
        phaseWriter = try .init(staging: staging, state: state, inventory: inventory, planObservation: observation)
        planSHA256 = PrimeSHA256.hexDigest(of: observation.expectedOriginalExecutionPlanData)
        let plan = try staging.publishData(observation.expectedOriginalExecutionPlanData, path: "plan.json")
        let go = try staging.publish(observation, path: "go.json")
        goBinding = go; planBinding = plan
        previousTerminalSHA256 = go.sha256
        guard plan.sha256 == planSHA256 else { throw hRejected("published_plan") }
        try phaseWriter.capturePredecessors()
        try phaseWriter.recordPlan(startBinding: observation.planningStartBinding, planBinding: plan,
            goBinding: go, completedAt: DispatchTime.now().uptimeNanoseconds)
        try PrimeValidationDriverV2ExecutionPlanRawCapability.checkpoint(state, inventory: inventory, deadline: deadline)
    }

    func beginNext() throws -> (PrimeValidationDriverV2InventoryExecutionState,
        PrimeValidationDriverV2ClosedShardObservation, PrimeValidationDriverV2ClosedExecutionPolicy,
        PrimeSecureChildPhaseDeadline, String) {
        lock.lock(); defer { lock.unlock() }
        guard let state, !awaiting, next < policies.count else { self.state = nil; throw hRejected("next_only") }
        // Irreversible before namespace creation, durable prestart, or spawn.
        let index = try cursor.begin()
        let shard = observation.schedule.shards[index]
        do {
            try checkpoint(state)
            if next == 1 || shard.arm != arm {
                guard (next == 1 && shard.arm == "reference") || (arm == "reference" && shard.arm == "candidate") else { throw hRejected("arm_transition") }
                arm = shard.arm
                deadline = try .init(startUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds,
                                     durationNanoseconds: 1_800_000_000_000)
            }
            try checkpoint(state)
            try staging.beginShard(shard)
            return (state, shard, policies[next - 1], deadline, previousTerminalSHA256)
        } catch { self.state = nil; throw error }
    }
    func checkpoint(_ state: PrimeValidationDriverV2InventoryExecutionState) throws {
        let before = DispatchTime.now().uptimeNanoseconds
        try PrimeValidationDriverV2ExecutionPlanRawCapability.checkpoint(state, inventory: inventory, deadline: deadline)
        try staging.revalidate()
        try phaseWriter.revalidate()
        guard try deadline.authorizesNewWork(
            observedAtUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds,
            notBeforeUptimeNanoseconds: before) else { throw hRejected("full_checkpoint_deadline") }
    }
    func revalidateContinuity() throws {
        lock.lock(); defer { lock.unlock() }
        guard let state else { throw hRejected("execution_poisoned") }
        do { try checkpoint(state) } catch { self.state = nil; throw error }
    }
    func accept(_ raw: PrimeValidationDriverV2ShardRawObservation, data: Data) throws {
        lock.lock(); defer { lock.unlock() }
        guard let state, awaiting, next > 0, raw.shard == observation.schedule.shards[next - 1],
              raw.process.exitedNormally, raw.process.exitStatus == 0,
              raw.process.terminationSignal == 0, !raw.process.coreDumped,
              !raw.shard.requiresXUnit || raw.resultBinding != nil else { throw hRejected("cannot_advance_failed_shard") }
        try checkpoint(state)
        let value = try HJSON.object(data)
        let nextID = next < policies.count ? observation.schedule.shards[next].shardID : ""
        guard Set(value.keys) == ["schema", "executionPlanSHA256", "rawObservationSHA256", "shardID", "nextShardID", "semanticTransition"],
              value["schema"] as? String == "prime_driver_v2_gate_h_parsed_shard_acceptance_v1",
              value["executionPlanSHA256"] as? String == planSHA256,
              value["rawObservationSHA256"] as? String == PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(raw)),
              value["shardID"] as? String == raw.shard.shardID,
              value["nextShardID"] as? String == nextID,
              value["semanticTransition"] as? String == (nextID.isEmpty ? "ready_for_conclusion" : "next_shard")
        else { throw hRejected("typed_acceptance_join") }
        let accepted = try staging.publishData(data, path: raw.shard.relativeRoot + "/binding.json")
        try staging.closeShard()
        previousTerminalSHA256 = accepted.sha256
        terminalBindings.append(raw.terminalBinding)
        acceptanceBindings.append(accepted)
        if armFirstPrestart == nil { armFirstPrestart = raw.prestartBinding }
        armAcceptanceBindings.append(accepted)
        try cursor.accept(index: next - 1)
        if next == policies.count || observation.schedule.shards[next].arm != raw.shard.arm {
            try phaseWriter.recordArm(arm: raw.shard.arm,
                startedAt: deadline.startUptimeNanoseconds,
                completedAt: DispatchTime.now().uptimeNanoseconds,
                firstPrestart: armFirstPrestart!, lastTerminal: raw.terminalBinding,
                acceptances: armAcceptanceBindings)
            armFirstPrestart = nil; armAcceptanceBindings.removeAll()
        }
        try checkpoint(state)
    }

    public func beginReconciliation() throws { try beginFinalPhase(reconciliation: true) }
    public func finishReconciliation(validatedResultData: Data) throws {
        try finishFinalPhase(reconciliation: true, data: validatedResultData)
    }
    public func beginComparison() throws { try beginFinalPhase(reconciliation: false) }
    public func finishComparison(validatedResultData: Data) throws {
        try finishFinalPhase(reconciliation: false, data: validatedResultData)
    }
    private func beginFinalPhase(reconciliation: Bool) throws {
        lock.lock(); defer { lock.unlock() }
        guard let state, cursor.allAccepted else { self.state = nil; throw hRejected("final_phase_incomplete") }
        do {
            try checkpoint(state)
            if reconciliation { try phaseWriter.beginReconciliation() } else { try phaseWriter.beginComparison() }
            deadline = try phaseWriter.activeDeadline()
            try checkpoint(state)
        } catch { self.state = nil; throw error }
    }
    private func finishFinalPhase(reconciliation: Bool, data: Data) throws {
        lock.lock(); defer { lock.unlock() }
        guard let state, cursor.allAccepted else { self.state = nil; throw hRejected("final_phase_incomplete") }
        do {
            try checkpoint(state)
            let fields = try HJSON.object(data)
            guard Set(fields.keys) == Set(reconciliation ? ["reference", "candidate"] : ["comparison", "finalReceipt"]) else {
                throw hRejected("final_phase_result_keys")
            }
            if reconciliation { try phaseWriter.finishReconciliation(validatedResultData: data) }
            else { try phaseWriter.finishComparison(validatedResultData: data) }
            try checkpoint(state)
        } catch { self.state = nil; throw error }
    }
    public var allShardsAccepted: Bool {
        lock.lock(); defer { lock.unlock() }; return state != nil && cursor.allAccepted
    }
    public func consumeForPublication() throws -> PrimeValidationDriverV2ExecutionPublicationPermit {
        lock.lock(); defer { lock.unlock() }
        guard let state, !awaiting, next == policies.count,
              terminalBindings.count == next, acceptanceBindings.count == next else {
            self.state = nil; throw hRejected("publication_requires_complete_prefix")
        }
        self.state = nil
        try checkpoint(state)
        let phaseHistoryData = try phaseWriter.historyData
        // The final held E history reads still belong to comparison. They
        // cannot consume its remaining time and silently reset publication.
        try checkpoint(state)
        let deadline = try PrimeSecureChildPhaseDeadline(startUptimeNanoseconds: DispatchTime.now().uptimeNanoseconds,
            durationNanoseconds: 30_000_000_000)
        let intent = try HJSON.object(observation.canonicalIntentData)
        let phases = (intent["phaseBudgets"] as? [[String: Any]])?.filter { $0["phase"] as? String == "publication" }
        guard phases?.count == 1, (phases?[0]["maximumActiveNanoseconds"] as? NSNumber)?.uint64Value == 30_000_000_000 else { throw hRejected("publication_budget") }
        let completed = PrimeValidationDriverV2ExecutionCompletedObservation(
            canonicalIntentData: observation.canonicalIntentData,
            declaredExecutionGoScopeData: observation.declaredExecutionGoScopeData,
            sourceSnapshotData: try PrimeCanonicalJSON.encode(state.retainedState.admission.sourceSnapshot),
            packageResolvedBinding: state.retainedState.admission.packageResolvedBinding,
            predecessorInventoryBinding: observation.predecessorInventoryBinding,
            planBinding: planBinding, goBinding: goBinding,
            orderedShardIdentifiers: observation.schedule.shards.map(\.shardID),
            orderedTerminalBindings: terminalBindings, orderedAcceptanceBindings: acceptanceBindings,
            phaseHistoryData: phaseHistoryData, orderedPhasePrefixBindings: phaseWriter.orderedPrefixBindings,
            immutableArtifactBindings: try staging.completedBindings(),
            publicationStartedAtUptimeNanoseconds: deadline.startUptimeNanoseconds,
            publicationExpiresAtUptimeNanoseconds: deadline.expiresAtUptimeNanoseconds)
        return .init(state: state, inventory: inventory, staging: staging, phaseWriter: phaseWriter,
            deadline: deadline, observation: completed)
    }
    func poison() { lock.lock(); state = nil; cursor.stop(); lock.unlock() }
    deinit { state = nil }
    @available(macOS 26.0, *)
    public func executeNextShard() throws -> PrimeValidationDriverV2ShardRawCapability {
        try PrimeValidationDriverV2ShardExecutor.execute(owner: self)
    }
}

@_spi(PrimeValidationDriverV2RoleFacade)
public struct PrimeValidationDriverV2ExecutionCompletedObservation: Codable, Equatable, Sendable {
    public let canonicalIntentData: Data
    public let declaredExecutionGoScopeData: Data
    public let sourceSnapshotData: Data
    public let packageResolvedBinding: PrimeArtifactBinding
    public let predecessorInventoryBinding: PrimeArtifactBinding
    public let planBinding: PrimeArtifactBinding
    public let goBinding: PrimeArtifactBinding
    public let orderedShardIdentifiers: [String]
    public let orderedTerminalBindings: [PrimeArtifactBinding]
    public let orderedAcceptanceBindings: [PrimeArtifactBinding]
    public let phaseHistoryData: Data
    public let orderedPhasePrefixBindings: [PrimeArtifactBinding]
    public let immutableArtifactBindings: [PrimeArtifactBinding]
    public let publicationStartedAtUptimeNanoseconds: UInt64
    public let publicationExpiresAtUptimeNanoseconds: UInt64
}

@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2ExecutionPublicationPermit: @unchecked Sendable {
    public let observation: PrimeValidationDriverV2ExecutionCompletedObservation
    private let lock = NSLock()
    private var lifetime: PrimeValidationDriverV2ExecutionPublicationLifetime?
    init(state: PrimeValidationDriverV2InventoryExecutionState, inventory: PrimeValidationDriverV2InventoryStaging,
         staging: PrimeValidationDriverV2ExecutionStaging, phaseWriter: PrimeValidationDriverV2ExecutionPhaseWriter,
         deadline: PrimeSecureChildPhaseDeadline,
         observation: PrimeValidationDriverV2ExecutionCompletedObservation) {
        self.observation = observation
        lifetime = .init(state: state, inventory: inventory, staging: staging, phaseWriter: phaseWriter,
            deadline: deadline, observation: observation)
    }
    public func consumePublicationLifetime() throws -> PrimeValidationDriverV2ExecutionPublicationLifetime {
        lock.lock(); defer { lock.unlock() }
        guard let value = lifetime else { throw hRejected("publication_permit_consumed") }
        lifetime = nil
        try value.revalidateContinuity()
        return value
    }
    public func revalidate() throws {
        lock.lock(); defer { lock.unlock() }
        guard let value = lifetime else { throw hRejected("publication_permit_consumed") }
        try value.revalidateContinuity()
    }
}

/// Additive publication code supplies its fixed namespace operations here.
/// These retained internal members are not exposed to decoded DriverCore data.
@_spi(PrimeValidationDriverV2RoleFacade)
public final class PrimeValidationDriverV2ExecutionPublicationLifetime: @unchecked Sendable {
    public let observation: PrimeValidationDriverV2ExecutionCompletedObservation
    let state: PrimeValidationDriverV2InventoryExecutionState
    let inventory: PrimeValidationDriverV2InventoryStaging
    let staging: PrimeValidationDriverV2ExecutionStaging
    let phaseWriter: PrimeValidationDriverV2ExecutionPhaseWriter
    let deadline: PrimeSecureChildPhaseDeadline
    init(state: PrimeValidationDriverV2InventoryExecutionState, inventory: PrimeValidationDriverV2InventoryStaging,
         staging: PrimeValidationDriverV2ExecutionStaging, phaseWriter: PrimeValidationDriverV2ExecutionPhaseWriter,
         deadline: PrimeSecureChildPhaseDeadline,
         observation: PrimeValidationDriverV2ExecutionCompletedObservation) {
        self.state = state; self.inventory = inventory; self.staging = staging
        self.phaseWriter = phaseWriter
        self.deadline = deadline; self.observation = observation
    }
    public func revalidateContinuity() throws {
        try PrimeValidationDriverV2ExecutionPlanRawCapability.checkpoint(state, inventory: inventory, deadline: deadline)
        try phaseWriter.revalidate()
        guard try staging.completedBindings() == observation.immutableArtifactBindings else { throw hRejected("publication_ledger_changed") }
    }
}
