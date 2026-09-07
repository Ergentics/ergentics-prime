// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
import PrimeValidationWorkflowContracts

/// Content admission only. This value carries no file descriptor, process
/// observation authority, or permission to execute a child.
package struct PrimeValidationDriverV2BoundRawArtifact {
    package let binding: PrimeValidationDriverArtifactBindingV2
    package let data: Data

    package init(binding: PrimeValidationDriverArtifactBindingV2, data: Data) throws {
        try binding.validate(permitsEmpty: true)
        guard data.count <= 128 * 1024 * 1024,
              binding.content == PrimeValidationContentBinding(data: data) else {
            throw PrimeValidationDriverV2Error.invalidBinding("execution_raw_content")
        }
        self.binding = binding; self.data = data
    }
}

/// The private constructor prevents decoded observations or semantic arrays
/// from acquiring parser authority. Every instance was reparsed from raw bytes.
package struct PrimeValidationDriverV2ParsedRawResults {
    fileprivate let results: [PrimeValidationSemanticTestResultV2]
    fileprivate let explicitParallelSkips: Set<PrimeValidationTestID>
    fileprivate let raw: PrimeValidationDriverV2BoundRawArtifact

    private init(results: [PrimeValidationSemanticTestResultV2],
                 explicitParallelSkips: Set<PrimeValidationTestID>,
                 raw: PrimeValidationDriverV2BoundRawArtifact) {
        self.results = results; self.explicitParallelSkips = explicitParallelSkips; self.raw = raw
    }

    package static func parse(
        lane: PrimeValidationExecutionLane,
        expectedIDs: [PrimeValidationTestID],
        selectionMode: PrimeValidationShardSelectionModeV2 = .allInventory,
        raw: PrimeValidationDriverV2BoundRawArtifact
    ) throws -> Self {
        let framework: PrimeValidationFramework = lane == .swiftTesting ? .swiftTesting : .xctest
        guard !expectedIDs.isEmpty, expectedIDs == expectedIDs.sorted(),
              Set(expectedIDs).count == expectedIDs.count,
              expectedIDs.allSatisfy({ $0.framework == framework }) else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        let observed: [String]
        let content: PrimeValidationContentBinding
        var terminals: [String: PrimeValidationSemanticTerminalV2] = [:]
        var reasons: [String: String] = [:]
        var parallelSkips = Set<PrimeValidationTestID>()
        switch lane {
        case .parallelXCTest:
            let parsed = try PrimeValidationParallelXCTestXUnitObservation.parse(raw.data)
            try parsed.validate()
            observed = parsed.observedRawIDs; content = parsed.contentBinding
            for id in parsed.failedRawIDs { terminals[id] = .failed }
            // Parallel xUnit cannot establish an exact skip reason. Preserve
            // its explicit markers separately and join them to same-arm
            // sequential transcripts before aggregate or terminal reuse.
            parallelSkips = try Set(parsed.explicitSkippedRawIDs.map {
                try PrimeValidationTestID.parse($0, framework: .xctest)
            })
        case .sequentialXCTest:
            let parsed = try PrimeValidationSequentialXCTestObservation.parse(raw.data,
                expectedTopLevelSuite: selectionMode == .allInventory ? .allTests : .selectedTests)
            try parsed.validate()
            observed = parsed.observedRawIDs; content = parsed.contentBinding
            for id in parsed.failedRawIDs { terminals[id] = .failed }
            for skip in parsed.skips {
                terminals[skip.rawID] = .skipped; reasons[skip.rawID] = skip.exactReason
            }
        case .swiftTesting:
            let parsed = try PrimeValidationSwiftTestingXUnitObservation.parse(raw.data)
            try parsed.validate()
            observed = parsed.observedRawIDs; content = parsed.contentBinding
            for id in parsed.failedRawIDs { terminals[id] = .failed }
            for id in parsed.errorRawIDs { terminals[id] = .error }
            // The existing strict shape parser does not retain skip messages.
            // Extract only those messages from the already validated document;
            // an absent/ambiguous reason is unsupported, never invented.
            reasons = try PrimeValidationDriverV2XUnitSkipReasons.parse(
                raw.data, expectedRawIDs: Set(parsed.skippedRawIDs))
            for id in parsed.skippedRawIDs { terminals[id] = .skipped }
        }
        guard content == raw.binding.content,
              observed == expectedIDs.map(\.rawValue),
              Set(observed).count == observed.count else {
            throw PrimeValidationDriverV2Error.invalidBinding("execution_observed_ids")
        }
        let results = expectedIDs.map {
            PrimeValidationSemanticTestResultV2(testID: $0,
                terminal: terminals[$0.rawValue] ?? .passed,
                exactSkipReason: reasons[$0.rawValue] ?? "")
        }
        try results.forEach { try $0.validate() }
        return .init(results: results, explicitParallelSkips: parallelSkips, raw: raw)
    }
}

/// Non-Codable parser evidence. Its receipt is an output, never an input to
/// this adapter. It cannot construct a native execution owner or authorize H.
package struct PrimeValidationDriverV2ParsedShardEvidence {
    package let evidence: PrimeValidationShardEvidenceV2
    fileprivate let parsed: PrimeValidationDriverV2ParsedRawResults
    fileprivate let standardOutput: PrimeValidationDriverV2BoundRawArtifact
    fileprivate let standardError: PrimeValidationDriverV2BoundRawArtifact
    fileprivate init(evidence: PrimeValidationShardEvidenceV2,
                     parsed: PrimeValidationDriverV2ParsedRawResults,
                     standardOutput: PrimeValidationDriverV2BoundRawArtifact,
                     standardError: PrimeValidationDriverV2BoundRawArtifact) {
        self.evidence = evidence; self.parsed = parsed
        self.standardOutput = standardOutput; self.standardError = standardError
    }
}

package struct PrimeValidationDriverV2ParsedExecutionConclusion {
    package let reference: PrimeValidationArmAggregateV2
    package let candidate: PrimeValidationArmAggregateV2
    package let comparison: PrimeValidationPairedComparisonReceiptV2
    package let finalReceipt: PrimeValidationDriverFinalReceiptV2
    fileprivate init(reference: PrimeValidationArmAggregateV2,
                     candidate: PrimeValidationArmAggregateV2,
                     comparison: PrimeValidationPairedComparisonReceiptV2,
                     finalReceipt: PrimeValidationDriverFinalReceiptV2) {
        self.reference = reference; self.candidate = candidate
        self.comparison = comparison; self.finalReceipt = finalReceipt
    }
}

/// Semantic eligibility for an already-started exact plan prefix. This is
/// not a native next-owner or an absence-based execution authorization.
package enum PrimeValidationDriverV2ParsedExecutionTransition: Equatable {
    case nextShard(shardID: String, pendingSequentialShardIDs: [String])
    case stoppedAtFailedTerminal
    case readyForConclusion
}

/// A same-module semantic adapter for a fully validated frozen plan. These
/// methods verify recorded process facts; native truth and durable start/ledger
/// ownership must be supplied by the separate live H executor. Public complete
/// receipt/resume APIs remain fail closed, and no nil/nil execution permit is
/// exposed here because absence alone is not a validated durable prefix.
package final class PrimeValidationDriverV2ExecutionBinding {
    package let plan: PrimeValidationExecutionPlanV2
    package let planSHA256: String

    package init(intent: PrimeValidationRunIntentV2,
                 build: PrimeValidationBuildReceiptV2,
                 inventory: PrimeValidationInventoryReceiptV2,
                 plan: PrimeValidationExecutionPlanV2) throws {
        try plan.validate(intent: intent, buildReceipt: build, inventoryReceipt: inventory)
        self.plan = plan
        planSHA256 = try plan.identitySHA256(
            intent: intent, buildReceipt: build, inventoryReceipt: inventory)
    }

    package func admit(
        start: PrimeValidationShardStartV2,
        observedChild: PrimeValidationObservedChildReceiptV2,
        result: PrimeValidationDriverV2BoundRawArtifact,
        standardOutput: PrimeValidationDriverV2BoundRawArtifact,
        standardError: PrimeValidationDriverV2BoundRawArtifact
    ) throws -> PrimeValidationDriverV2ParsedShardEvidence {
        let index = try validateStart(start)
        let invocation = plan.shardInvocations[index]
        guard observedChild.invocation == invocation,
              observedChild.standardOutputArtifact == standardOutput.binding,
              observedChild.standardErrorArtifact == standardError.binding,
              standardOutput.binding.name == "standard_output",
              standardError.binding.name == "standard_error",
              result.binding.name == "result",
              standardOutput.binding.relativePath == invocation.standardOutputRelativePath,
              standardError.binding.relativePath == invocation.standardErrorRelativePath,
              standardOutput.binding.relativePath != standardError.binding.relativePath,
              result.binding.relativePath != standardError.binding.relativePath else {
            throw PrimeValidationDriverV2Error.invalidBinding("execution_child_join")
        }
        switch (invocation.primaryResult, observedChild.primaryResult) {
        case (.standardOutput, .standardOutput):
            guard result.binding.relativePath == standardOutput.binding.relativePath,
                  result.data == standardOutput.data else {
                throw PrimeValidationDriverV2Error.invalidBinding("execution_stdout_result")
            }
        case let (.file(path), .file(primary)):
            try primary.validate(permitsEmpty: true)
            guard primary.name == "primary_result", primary.relativePath == path,
                  result.binding.relativePath == path,
                  primary.content == result.binding.content,
                  path != standardOutput.binding.relativePath,
                  path != standardError.binding.relativePath else {
                throw PrimeValidationDriverV2Error.invalidBinding("execution_file_result")
            }
        default: throw PrimeValidationDriverV2Error.invalidBinding("execution_primary_kind")
        }
        try observedChild.process.validate(
            standardOutputContent: standardOutput.binding.content,
            standardErrorContent: standardError.binding.content)
        let parsed = try PrimeValidationDriverV2ParsedRawResults.parse(
            lane: start.shard.key.lane, expectedIDs: start.shard.testIDs,
            selectionMode: start.shard.selectionMode, raw: result)
        let receipt = PrimeValidationShardReceiptV2(
            runID: plan.runID, executionPlanSHA256: planSHA256,
            shardStartSHA256: try start.identitySHA256(
                expectedRunID: plan.runID, expectedExecutionPlanSHA256: planSHA256),
            shardID: start.shard.shardID, disposition: .complete, incompleteReason: "",
            resultArtifact: result.binding,
            standardOutputArtifact: standardOutput.binding,
            standardErrorArtifact: standardError.binding,
            process: observedChild.process, semanticResults: parsed.results,
            activeNanoseconds: observedChild.activeNanoseconds)
        let evidence = PrimeValidationShardEvidenceV2(start: start, receipt: receipt)
        try evidence.validateAssumingParsedSemanticEvidence(
            executionPlan: plan, expectedExecutionPlanSHA256: planSHA256)
        return .init(evidence: evidence, parsed: parsed,
                     standardOutput: standardOutput, standardError: standardError)
    }

    package func resumeDecision(
        for parsed: PrimeValidationDriverV2ParsedShardEvidence,
        sequentialEvidence: [PrimeValidationDriverV2ParsedShardEvidence] = []
    ) throws -> PrimeValidationResumeDecisionV2 {
        try validate(parsed)
        try validateSequentialSkipAuthority([parsed] + sequentialEvidence)
        return try PrimeValidationResumeStateMachineV2.decideShardAssumingParsedSemanticEvidence(
            start: parsed.evidence.start, terminal: parsed.evidence.receipt,
            expectedRunID: plan.runID, expectedExecutionPlanSHA256: planSHA256,
            maximumActiveNanoseconds: maximum(for: parsed.evidence.key.arm))
    }

    package func startedWithoutTerminal(_ start: PrimeValidationShardStartV2) throws
        -> PrimeValidationResumeDecisionV2 {
        _ = try validateStart(start)
        return try PrimeValidationResumeStateMachineV2.decideShardAssumingParsedSemanticEvidence(
            start: start, terminal: nil, expectedRunID: plan.runID,
            expectedExecutionPlanSHA256: planSHA256,
            maximumActiveNanoseconds: maximum(for: start.shard.key.arm))
    }

    package func transition(after prefix: [PrimeValidationDriverV2ParsedShardEvidence]) throws
        -> PrimeValidationDriverV2ParsedExecutionTransition {
        guard !prefix.isEmpty, prefix.count <= plan.shards.count,
              prefix.map({ $0.evidence.start.shard }) == Array(plan.shards.prefix(prefix.count)) else {
            throw PrimeValidationDriverV2Error.invalidBinding("execution_exact_prefix")
        }
        try prefix.forEach { try validate($0) }
        for arm in [PrimeValidationComparisonArmV2.reference, .candidate] {
            let active = try PrimeValidationDriverV2Validation.checkedSum(
                prefix.filter { $0.evidence.key.arm == arm }.map { $0.evidence.receipt.activeNanoseconds })
            guard active <= maximum(for: arm) else {
                throw PrimeValidationDriverV2Error.invalidBinding("execution_arm_budget")
            }
        }
        for (index, value) in prefix.enumerated() where value.evidence.receipt.hasTerminalGateFailure {
            guard index == prefix.count - 1 else {
                throw PrimeValidationDriverV2Error.invalidBinding("execution_successor_after_failure")
            }
            return .stoppedAtFailedTerminal
        }
        var pending = Set<String>()
        var pendingArms = Set<PrimeValidationComparisonArmV2>()
        for parallel in prefix where !parallel.parsed.explicitParallelSkips.isEmpty {
            for identifier in parallel.parsed.explicitParallelSkips {
                guard let required = plan.shards.first(where: {
                    $0.key.arm == parallel.evidence.key.arm && $0.key.lane == .sequentialXCTest
                        && $0.testIDs.contains(identifier)
                }) else { throw PrimeValidationDriverV2Error.invalidExecutionPlan }
                if let sequential = prefix.first(where: { $0.evidence.start.shard == required }) {
                    guard sequential.parsed.results.first(where: { $0.testID == identifier })?.terminal == .skipped else {
                        throw PrimeValidationDriverV2Error.invalidBinding("execution_sequential_skip_authority")
                    }
                } else {
                    pending.insert(required.shardID); pendingArms.insert(required.key.arm)
                }
            }
        }
        guard prefix.count < plan.shards.count else {
            guard pending.isEmpty else { throw PrimeValidationDriverV2Error.invalidAggregate }
            return .readyForConclusion
        }
        let next = plan.shards[prefix.count]
        guard pending.isEmpty || (pendingArms == Set([next.key.arm]) && next.key.lane != .swiftTesting) else {
            throw PrimeValidationDriverV2Error.invalidBinding("execution_unresolved_skip_successor")
        }
        let orderedPending = plan.shards.filter { pending.contains($0.shardID) }.map(\.shardID)
        return .nextShard(shardID: next.shardID, pendingSequentialShardIDs: orderedPending)
    }

    package func conclude(_ parsed: [PrimeValidationDriverV2ParsedShardEvidence]) throws
        -> PrimeValidationDriverV2ParsedExecutionConclusion {
        try parsed.forEach { try validate($0) }
        guard Set(parsed.map { $0.evidence.key }).count == parsed.count else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        for arm in [PrimeValidationComparisonArmV2.reference, .candidate] {
            let active = try PrimeValidationDriverV2Validation.checkedSum(
                parsed.filter { $0.evidence.key.arm == arm }.map { $0.evidence.receipt.activeNanoseconds })
            guard active <= maximum(for: arm) else {
                throw PrimeValidationDriverV2Error.invalidBinding("execution_arm_budget")
            }
        }
        try validateSequentialSkipAuthority(parsed)
        func aggregate(_ arm: PrimeValidationComparisonArmV2) throws -> PrimeValidationArmAggregateV2 {
            try .aggregateAssumingAdmittedPlan(arm: arm,
                shardEvidence: parsed.filter { $0.evidence.key.arm == arm }.map(\.evidence),
                executionPlan: plan, expectedExecutionPlanSHA256: planSHA256)
        }
        let reference = try aggregate(.reference), candidate = try aggregate(.candidate)
        let comparison = try PrimeValidationPairedSemanticComparatorV2.compareAssumingValidatedAggregates(
            reference: reference, candidate: candidate, executionPlan: plan, executionPlanSHA256: planSHA256)
        let final = try PrimeValidationDriverFinalReceiptV2.makeAssumingValidatedComparison(
            comparison: comparison, reference: reference, candidate: candidate)
        return .init(reference: reference, candidate: candidate, comparison: comparison, finalReceipt: final)
    }

    private func validate(_ value: PrimeValidationDriverV2ParsedShardEvidence) throws {
        _ = try validateStart(value.evidence.start)
        let reparsed = try PrimeValidationDriverV2ParsedRawResults.parse(
            lane: value.evidence.key.lane, expectedIDs: value.evidence.start.shard.testIDs,
            selectionMode: value.evidence.start.shard.selectionMode, raw: value.parsed.raw)
        guard reparsed.results == value.evidence.receipt.semanticResults,
              reparsed.explicitParallelSkips == value.parsed.explicitParallelSkips,
              value.parsed.raw.binding == value.evidence.receipt.resultArtifact,
              value.standardOutput.binding == value.evidence.receipt.standardOutputArtifact,
              value.standardError.binding == value.evidence.receipt.standardErrorArtifact else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        try value.evidence.validateAssumingParsedSemanticEvidence(
            executionPlan: plan, expectedExecutionPlanSHA256: planSHA256)
    }

    private func validateStart(_ start: PrimeValidationShardStartV2) throws -> Int {
        try start.validate(expectedRunID: plan.runID, expectedExecutionPlanSHA256: planSHA256)
        guard let index = plan.shards.firstIndex(of: start.shard),
              plan.shardInvocations.indices.contains(index) else {
            throw PrimeValidationDriverV2Error.invalidExecutionPlan
        }
        return index
    }

    private func maximum(for arm: PrimeValidationComparisonArmV2) -> UInt64 {
        arm == .reference ? plan.maximumReferenceShardActiveNanoseconds
            : plan.maximumCandidateShardActiveNanoseconds
    }

    private func validateSequentialSkipAuthority(
        _ values: [PrimeValidationDriverV2ParsedShardEvidence]
    ) throws {
        try values.forEach { try validate($0) }
        guard Set(values.map { $0.evidence.key }).count == values.count else {
            throw PrimeValidationDriverV2Error.invalidAggregate
        }
        for arm in [PrimeValidationComparisonArmV2.reference, .candidate] {
            let sameArm = values.filter { $0.evidence.key.arm == arm }
            let sequential = sameArm.filter { $0.evidence.key.lane == .sequentialXCTest }
                .flatMap { $0.parsed.results }.filter { $0.terminal == .skipped }
            let skips = Set(sequential.map(\.testID))
            let parallel = sameArm.filter { $0.evidence.key.lane == .parallelXCTest }
                .reduce(into: Set<PrimeValidationTestID>()) { $0.formUnion($1.parsed.explicitParallelSkips) }
            guard parallel.isSubset(of: skips) else {
                throw PrimeValidationDriverV2Error.invalidBinding("execution_sequential_skip_authority")
            }
        }
    }
}

/// A second projection, never a replacement shape parser. The strict existing
/// parser has already rejected DTDs/entities/unknown structure. Keep exact
/// message bytes (or exact text when no message exists), without manufacturing
/// a skip reason from policy or an identifier.
private final class PrimeValidationDriverV2XUnitSkipReasons: NSObject, XMLParserDelegate {
    private var currentID: String?
    private var inSkip = false
    private var message: String?
    private var text = ""
    private var reasons: [String: String] = [:]
    private var invalid = false

    static func parse(_ data: Data, expectedRawIDs: Set<String>) throws -> [String: String] {
        guard !expectedRawIDs.isEmpty else { return [:] }
        let delegate = PrimeValidationDriverV2XUnitSkipReasons()
        let parser = XMLParser(data: data)
        parser.shouldResolveExternalEntities = false; parser.delegate = delegate
        guard parser.parse(), !delegate.invalid,
              Set(delegate.reasons.keys) == expectedRawIDs else {
            throw PrimeValidationDriverV2Error.invalidBinding("execution_xunit_skip_reason")
        }
        return delegate.reasons
    }
    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?,
                qualifiedName: String?, attributes: [String: String] = [:]) {
        if name == "testcase" {
            currentID = (attributes["classname"] ?? "") + "/" + (attributes["name"] ?? "")
        } else if name == "skipped" {
            inSkip = true; message = attributes["message"]; text = ""
        }
    }
    func parser(_ parser: XMLParser, foundCharacters value: String) {
        if inSkip { text += value }
    }
    func parser(_ parser: XMLParser, didEndElement name: String, namespaceURI: String?, qualifiedName: String?) {
        if name == "skipped" {
            let body = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let reason = message ?? body
            guard let currentID, reasons[currentID] == nil,
                  !reason.isEmpty,
                  message == nil || body.isEmpty || body == reason else { invalid = true; return }
            reasons[currentID] = reason; inSkip = false
        } else if name == "testcase" { currentID = nil }
    }
}
