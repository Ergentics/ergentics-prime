import Foundation
import PrimeNativeNeuralGateReplayMechanics
import PrimeNativeNeuralGateCorrectedMechanics

/// A pure feasibility observation over caller-provided completion values.
///
/// This is not source-bound fixture admission and cannot establish row
/// identity, completeness, inclusion, or execution authority. The later
/// executor must validate the complete source-derived fixture before any row
/// executes.
public struct PrimeNativeNeuralGateCorrectedCompletionFeasibility:
    Equatable,
    Sendable
{
    public let observedCompletionCount: Int
    public let allValuesCanonicalNFC: Bool
    public let allValuesFitFixedCapWithEOS: Bool

    private init(
        observedCompletionCount: Int,
        allValuesCanonicalNFC: Bool
    ) {
        self.observedCompletionCount =
            observedCompletionCount
        self.allValuesCanonicalNFC =
            allValuesCanonicalNFC
        allValuesFitFixedCapWithEOS = true
    }

    public static func recompute(
        expectedCompletions: [String]
    ) throws -> Self {
        guard !expectedCompletions.isEmpty else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .emptyFixture
        }
        var allCanonical = true
        for (
            index,
            completion
        ) in expectedCompletions.enumerated() {
            let canonical =
                completion
                .precomposedStringWithCanonicalMapping
            allCanonical =
                allCanonical
                && Data(completion.utf8)
                    == Data(canonical.utf8)
            let decisionsRequired =
                canonical.utf8.count + 1
            guard decisionsRequired
                    <= PrimeNativeNeuralGateCorrectedExecutionPolicy
                    .maximumGenerationDecisions
            else {
                throw PrimeNativeNeuralGateCorrectedMechanicsError
                    .completionExceedsFixedCap(
                        index: index
                    )
            }
        }
        return Self(
            observedCompletionCount:
                expectedCompletions.count,
            allValuesCanonicalNFC: allCanonical
        )
    }
}

/// Correlation exists outside the executor-visible value. No execution API in
/// this module accepts this envelope.
public struct PrimeNativeNeuralGateCorrectedCorrelationEnvelope:
    Equatable,
    Sendable
{
    public let correlationID: String
    public let executionInput:
        PrimeNativeNeuralGatePromptOnlyExecutionInput

    public init(
        correlationID: String,
        executionInput:
            PrimeNativeNeuralGatePromptOnlyExecutionInput
    ) throws {
        let bytes = Array(correlationID.utf8)
        guard !bytes.isEmpty,
              bytes.count <= 512,
              bytes.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              })
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidCorrelationID
        }
        self.correlationID = correlationID
        self.executionInput = executionInput
    }
}

public enum PrimeNativeNeuralGateObservedTruth:
    String,
    Codable,
    Equatable,
    Sendable
{
    case unavailable
    case observedFalse = "observed_false"
    case observedTrue = "observed_true"
}

/// Target-bearing material rejoins only after raw execution exists.
public struct PrimeNativeNeuralGatePostExecutionRegradeMaterial:
    Equatable,
    Sendable
{
    public let rawExpectedCompletionUTF8: Data
    public let canonicalExpectedCompletionUTF8:
        Data

    public init(
        expectedCompletion: String
    ) throws {
        let canonical =
            expectedCompletion
            .precomposedStringWithCanonicalMapping
        guard canonical.utf8.count + 1
                <= PrimeNativeNeuralGateCorrectedExecutionPolicy
                .maximumGenerationDecisions
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidRegradeAuthority
        }
        rawExpectedCompletionUTF8 =
            Data(expectedCompletion.utf8)
        canonicalExpectedCompletionUTF8 =
            Data(canonical.utf8)
    }
}

public struct PrimeNativeNeuralGatePredictionRegradeObservation:
    Equatable,
    Sendable
{
    public let rawExecutionSHA256: String
    public let outputUTF8Valid: Bool
    public let exactMatch: Bool
    public let predictedAbstention: Bool
    public let semanticMatch:
        PrimeNativeNeuralGateObservedTruth

    public static func recompute(
        execution:
            PrimeNativeNeuralGateRawExecution,
        material:
            PrimeNativeNeuralGatePostExecutionRegradeMaterial
    ) -> Self {
        let canonicalOutputUTF8 =
            execution.outputText.map {
                Data(
                    $0
                    .precomposedStringWithCanonicalMapping
                    .utf8
                )
            }
        return Self(
            rawExecutionSHA256:
                execution.traceSHA256,
            outputUTF8Valid:
                execution.outputText != nil,
            exactMatch:
                execution.termination == .eos
                && canonicalOutputUTF8
                    == material
                    .canonicalExpectedCompletionUTF8,
            predictedAbstention:
                canonicalOutputUTF8
                    == Data("ABSTAIN\n".utf8),
            semanticMatch: .unavailable
        )
    }
}

public struct PrimeNativeNeuralGateWeightedLossRow:
    Equatable,
    Sendable
{
    public let targetTokenCount: Int
    public let crossEntropyBefore: Double
    public let crossEntropyAfter: Double

    public init(
        targetTokenCount: Int,
        crossEntropyBefore: Double,
        crossEntropyAfter: Double
    ) throws {
        guard targetTokenCount > 0,
              crossEntropyBefore.isFinite,
              crossEntropyBefore > 0,
              crossEntropyAfter.isFinite,
              crossEntropyAfter >= 0
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidLossRow
        }
        self.targetTokenCount = targetTokenCount
        self.crossEntropyBefore =
            crossEntropyBefore
        self.crossEntropyAfter =
            crossEntropyAfter
    }
}

public struct PrimeNativeNeuralGateWeightedLossStatistics:
    Equatable,
    Sendable
{
    public let rowCount: Int
    public let totalTargetTokenCount: Int
    public let weightedMeanBefore: Double
    public let weightedMeanAfter: Double
    public let effectiveRows: Double
    public let unbiasedVarianceDenominator:
        Double
    public let weightedVarianceAfter: Double
    public let standardErrorAfter: Double

    public static func recompute(
        rows: [PrimeNativeNeuralGateWeightedLossRow]
    ) throws -> Self {
        guard !rows.isEmpty else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidLossRow
        }
        var total = 0
        for row in rows {
            let addition = total.addingReportingOverflow(
                row.targetTokenCount
            )
            guard !addition.overflow else {
                throw PrimeNativeNeuralGateCorrectedMechanicsError
                    .lossWeightOverflow
            }
            total = addition.partialValue
        }
        let totalWeight = Double(total)
        let before = rows.reduce(0.0) {
            $0
                + $1.crossEntropyBefore
                * Double($1.targetTokenCount)
        } / totalWeight
        let after = rows.reduce(0.0) {
            $0
                + $1.crossEntropyAfter
                * Double($1.targetTokenCount)
        } / totalWeight
        let weightSquared = rows.reduce(0.0) {
            let weight =
                Double($1.targetTokenCount)
            return $0 + weight * weight
        }
        let effectiveRows =
            totalWeight * totalWeight
            / Swift.max(1, weightSquared)
        let denominator =
            totalWeight
            - weightSquared
            / Swift.max(1, totalWeight)
        let squaredDeviation = rows.reduce(0.0) {
            let delta =
                $1.crossEntropyAfter - after
            return $0
                + Double($1.targetTokenCount)
                * delta * delta
        }
        let variance =
            denominator > 0
            ? squaredDeviation / denominator
            : 0
        let standardError =
            Foundation.sqrt(
                variance
                    / Swift.max(1, effectiveRows)
            )
        let values = [
            before,
            after,
            effectiveRows,
            denominator,
            variance,
            standardError,
        ]
        guard values.allSatisfy(\.isFinite)
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .nonfiniteLossStatistic
        }
        return Self(
            rowCount: rows.count,
            totalTargetTokenCount: total,
            weightedMeanBefore: before,
            weightedMeanAfter: after,
            effectiveRows: effectiveRows,
            unbiasedVarianceDenominator:
                denominator,
            weightedVarianceAfter: variance,
            standardErrorAfter: standardError
        )
    }
}

public struct PrimeNativeNeuralGateFixedPromptReplayObservation:
    Equatable,
    Sendable
{
    public let logitCount: Int
    public let firstGreedyTokenID: Int
    public let replayGreedyTokenID: Int
    public let firstRunnerUpMargin: Double
    public let replayRunnerUpMargin: Double
    public let maximumAbsoluteLogitDelta:
        Double
    public let greedyTokenStable: Bool
    public let behavioralReplayExact: Bool
    public let bitwiseReplayExact: Bool

    public static func recompute(
        firstFloatBitPatterns: [UInt32],
        replayFloatBitPatterns: [UInt32]
    ) throws -> Self {
        guard firstFloatBitPatterns.count
                == PrimeNativeNeuralGateCorrectedExecutionPolicy
                .fullVocabularyLogitCount,
              firstFloatBitPatterns.count
                == replayFloatBitPatterns.count
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidFixedPromptReplay
        }
        let first =
            firstFloatBitPatterns.map {
                Float(bitPattern: $0)
            }
        let replay =
            replayFloatBitPatterns.map {
                Float(bitPattern: $0)
            }
        guard first.allSatisfy(\.isFinite),
              replay.allSatisfy(\.isFinite)
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidFixedPromptReplay
        }
        func greedyIndex(_ values: [Float])
            -> Int
        {
            var selected = 0
            for index in values.indices.dropFirst() {
                if values[index] > values[selected] {
                    selected = index
                }
            }
            return selected
        }
        func runnerUp(
            _ values: [Float],
            excluding index: Int
        ) -> Float {
            var result = -Float.infinity
            for candidate in values.indices
                where candidate != index
            {
                result = Swift.max(
                    result,
                    values[candidate]
                )
            }
            return result
        }
        let firstGreedy = greedyIndex(first)
        let replayGreedy = greedyIndex(replay)
        let firstMargin =
            Double(first[firstGreedy])
                - Double(
                    runnerUp(
                        first,
                        excluding: firstGreedy
                    )
                )
        let replayMargin =
            Double(replay[replayGreedy])
                - Double(
                    runnerUp(
                        replay,
                        excluding: replayGreedy
                    )
                )
        let maximumDelta = zip(first, replay)
            .map {
                abs(
                    Double($0.0)
                        - Double($0.1)
                )
            }
            .max() ?? 0
        let stable =
            firstGreedy == replayGreedy
        let doubledDelta = 2 * maximumDelta
        let behavioral =
            maximumDelta.isFinite
            && firstMargin.isFinite
            && replayMargin.isFinite
            && firstMargin > 0
            && replayMargin > 0
            && stable
            && doubledDelta.isFinite
            && doubledDelta
                < Swift.min(
                    firstMargin,
                    replayMargin
                )
        return Self(
            logitCount: first.count,
            firstGreedyTokenID: firstGreedy,
            replayGreedyTokenID: replayGreedy,
            firstRunnerUpMargin: firstMargin,
            replayRunnerUpMargin:
                replayMargin,
            maximumAbsoluteLogitDelta:
                maximumDelta,
            greedyTokenStable: stable,
            behavioralReplayExact: behavioral,
            bitwiseReplayExact:
                firstFloatBitPatterns
                == replayFloatBitPatterns
        )
    }
}

public enum PrimeNativeNeuralGateCapabilitySplit:
    String,
    CaseIterable,
    Equatable,
    Sendable
{
    case validation
    case combinationHoldout =
        "combination_holdout"
    case outOfDistribution = "ood"
    case mutation
    case abstention

    public var requiredRowCount: Int {
        switch self {
        case .validation,
             .combinationHoldout,
             .outOfDistribution,
             .mutation:
            4_096
        case .abstention:
            2_048
        }
    }

    public var minimumCorrectedExactAccuracy:
        Double?
    {
        switch self {
        case .validation:
            nil
        case .combinationHoldout,
             .mutation:
            0.80
        case .outOfDistribution:
            0.70
        case .abstention:
            1
        }
    }

    public var correctedMustStrictlyImprove:
        Bool
    {
        self != .validation
    }
}

public struct PrimeNativeNeuralGateCapabilityRow:
    Equatable,
    Sendable
{
    public let split:
        PrimeNativeNeuralGateCapabilitySplit
    public let zeroShotExact: Bool
    public let correctedExact: Bool
    public let expectedAbstention: Bool
    public let correctedAbstention: Bool

    public init(
        split:
            PrimeNativeNeuralGateCapabilitySplit,
        zeroShotExact: Bool,
        correctedExact: Bool,
        expectedAbstention: Bool = false,
        correctedAbstention: Bool = false
    ) {
        self.split = split
        self.zeroShotExact = zeroShotExact
        self.correctedExact = correctedExact
        self.expectedAbstention =
            expectedAbstention
        self.correctedAbstention =
            correctedAbstention
    }
}

public struct PrimeNativeNeuralGateCapabilitySplitObservation:
    Equatable,
    Sendable
{
    public let split:
        PrimeNativeNeuralGateCapabilitySplit
    public let rowCount: Int
    public let zeroShotExactAccuracy: Double
    public let correctedExactAccuracy: Double
    public let thresholdSatisfied: Bool
}

public struct PrimeNativeNeuralGateCapabilityObservation:
    Equatable,
    Sendable
{
    public let totalRowCount: Int
    public let splits:
        [PrimeNativeNeuralGateCapabilitySplitObservation]
    public let thresholdsSatisfied: Bool
    public let sourceBoundRowIdentityAndCoverageEstablished:
        Bool
    public let modelCapability:
        PrimeNativeNeuralGateObservedTruth

    public static func recompute(
        rows: [PrimeNativeNeuralGateCapabilityRow]
    ) throws -> Self {
        var observations: [
            PrimeNativeNeuralGateCapabilitySplitObservation
        ] = []
        for split in
            PrimeNativeNeuralGateCapabilitySplit
            .allCases
        {
            let splitRows =
                rows.filter { $0.split == split }
            guard splitRows.count
                    == split.requiredRowCount
            else {
                throw PrimeNativeNeuralGateCorrectedMechanicsError
                    .invalidCapabilityRows
            }
            let rowCount = splitRows.count
            let zero =
                Double(
                    splitRows.filter(\.zeroShotExact)
                        .count
                )
                / Double(rowCount)
            let corrected =
                Double(
                    splitRows.filter(\.correctedExact)
                        .count
                )
                / Double(rowCount)
            var passes =
                split.minimumCorrectedExactAccuracy
                .map { corrected >= $0 }
                ?? true
            if split.correctedMustStrictlyImprove {
                passes =
                    passes && corrected > zero
            }
            if split == .abstention {
                passes = passes
                    && splitRows.allSatisfy {
                        $0.expectedAbstention
                            && $0.correctedAbstention
                            && $0.correctedExact
                    }
            }
            observations.append(
                .init(
                    split: split,
                    rowCount: rowCount,
                    zeroShotExactAccuracy: zero,
                    correctedExactAccuracy:
                        corrected,
                    thresholdSatisfied: passes
                )
            )
        }
        let expectedTotal =
            PrimeNativeNeuralGateCapabilitySplit
            .allCases
            .map(\.requiredRowCount)
            .reduce(0, +)
        guard rows.count == expectedTotal else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidCapabilityRows
        }
        return Self(
            totalRowCount: rows.count,
            splits: observations,
            thresholdsSatisfied:
                observations.allSatisfy(
                    \.thresholdSatisfied
                ),
            sourceBoundRowIdentityAndCoverageEstablished:
                false,
            modelCapability: .unavailable
        )
    }
}

public struct PrimeNativeNeuralGateCriticalLegObservation:
    Equatable,
    Sendable
{
    public let legID: String
    public let passed: Bool
    public let detail: String

    public init(
        legID: String,
        passed: Bool,
        detail: String
    ) {
        self.legID = legID
        self.passed = passed
        self.detail = detail
    }
}

public enum PrimeNativeNeuralGateMechanicsOutcome:
    String,
    Equatable,
    Sendable
{
    case grounded = "GROUNDED"
    case abstain = "ABSTAIN"
}

public struct PrimeNativeNeuralGateCountDerivedVerdict:
    Equatable,
    Sendable
{
    public static let orderedCriticalLegIDs = [
        "NL1_canonical_material_reload",
        "NL2_finite_field_sz_pool_expansion",
        "NL3_foundation_tokenizer_corpus_regrade",
        "NL4_raw_executor_row_regrade",
        "NL5_causal_training_mechanics",
        "NL6_checkpoint_durability",
        "NL7_same_seed_initialization_training_result_replay",
        "NL8_frozen_exact_seed_consensus",
        "NL9_capability_and_malformed_abstention",
        "NL10_mutation_synthesis",
    ]

    public let legs:
        [PrimeNativeNeuralGateCriticalLegObservation]
    public let passingCount: Int
    public let countDerivedLabel: String
    public let countDerivedLabelScope: String
    public let mechanicsOutcome:
        PrimeNativeNeuralGateMechanicsOutcome
    public let modelCapability:
        PrimeNativeNeuralGateObservedTruth
    public let sourceBoundCriticalLegEvidenceEstablished:
        Bool
    public let distinctImplementationFamiliesEstablished:
        Bool
    public let agentContractKitFourTierAuditPerformed:
        Bool

    public static func recompute(
        legs:
            [PrimeNativeNeuralGateCriticalLegObservation]
    ) throws -> Self {
        guard legs.map(\.legID)
                == orderedCriticalLegIDs,
              Set(legs.map(\.legID)).count
                == orderedCriticalLegIDs.count
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidCriticalLegs
        }
        let count = legs.filter(\.passed).count
        let label =
            count >= 3
            ? "independentThreePlus(\(count))"
            : "oracleDerived(\(count))"
        return Self(
            legs: legs,
            passingCount: count,
            countDerivedLabel: label,
            countDerivedLabelScope:
                "provisional_count_only_non_authorizing",
            mechanicsOutcome: .abstain,
            modelCapability: .unavailable,
            sourceBoundCriticalLegEvidenceEstablished:
                false,
            distinctImplementationFamiliesEstablished:
                false,
            agentContractKitFourTierAuditPerformed:
                false
        )
    }
}

public enum PrimeNativeNeuralGateCorrectedMutationID:
    String,
    CaseIterable,
    Equatable,
    Sendable
{
    case targetValueChangesRawExecution =
        "target_value_changes_raw_execution"
    case targetLengthChangesRawExecution =
        "target_length_changes_raw_execution"
    case expectedCompletionInjectedIntoPrediction =
        "expected_completion_injected_into_prediction"
    case targetDependentPromptGrouping =
        "target_dependent_prompt_grouping"
    case targetDependentDecisionBudget =
        "target_dependent_decision_budget"
    case eosUnavailableAtDecision =
        "eos_unavailable_at_decision"
    case completionSupportNarrowed =
        "completion_support_narrowed"
    case fixedCapDrift = "fixed_cap_drift"
    case targetDependentTermination =
        "target_dependent_termination"
    case targetDependentRowInclusion =
        "target_dependent_row_inclusion"
    case correlationRowIDInjectedIntoPrediction =
        "correlation_row_id_injected_into_prediction"
    case correlationSplitInjectedIntoPrediction =
        "correlation_split_injected_into_prediction"
    case correlationSemanticFamilyInjectedIntoPrediction =
        "correlation_semantic_family_injected_into_prediction"
    case rowDependentEvaluationSeed =
        "row_dependent_evaluation_seed"
    case retainedStateChangesPermutedRowTrace =
        "retained_state_changes_permuted_row_trace"

    public var expectedFailedLeg: String {
        switch self {
        case .targetValueChangesRawExecution:
            "corrected_target_value_independence"
        case .targetLengthChangesRawExecution:
            "corrected_target_length_independence"
        case .expectedCompletionInjectedIntoPrediction,
             .correlationRowIDInjectedIntoPrediction,
             .correlationSplitInjectedIntoPrediction,
             .correlationSemanticFamilyInjectedIntoPrediction:
            "corrected_prediction_input_exclusion"
        case .targetDependentPromptGrouping:
            "corrected_prompt_grouping"
        case .targetDependentDecisionBudget:
            "corrected_decision_budget"
        case .eosUnavailableAtDecision:
            "corrected_eos_availability"
        case .completionSupportNarrowed:
            "corrected_completion_support"
        case .fixedCapDrift:
            "corrected_fixed_cap"
        case .targetDependentTermination:
            "corrected_termination_independence"
        case .targetDependentRowInclusion:
            "corrected_row_inclusion_independence"
        case .rowDependentEvaluationSeed:
            "corrected_replicate_seed_scope"
        case .retainedStateChangesPermutedRowTrace:
            "corrected_row_order_state_independence"
        }
    }
}

public struct PrimeNativeNeuralGateCorrectedMutationObservation:
    Equatable,
    Sendable
{
    public let mutationID:
        PrimeNativeNeuralGateCorrectedMutationID
    public let expectedFailedLeg: String
    public let baselineGlobalSHA256: String
    public let mutatedGlobalSHA256: String
    public let restoredGlobalSHA256: String
    public let baselineFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let mutatedFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let restoredFingerprint:
        PrimeNativeNeuralGateFingerprint
    public let callerReportedExpectedLegFailure:
        Bool
    public let independentMutationExecutionObserved:
        Bool
    public let independentDetectorObserved: Bool
    public let rawRecordsDiverged: Bool
    public let fingerprintDiverged: Bool
    public let rawRecordsRestoredExactly: Bool
    public let fingerprintRestoredExactly: Bool

    public static func recompute(
        mutationID:
            PrimeNativeNeuralGateCorrectedMutationID,
        baselineRecords: [String],
        mutatedRecords: [String],
        restoredRecords: [String],
        observedFailedLegIDs: [String]
    ) throws -> Self {
        let baseline =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records:
                    baselineRecords.map {
                        Data($0.utf8)
                    }
            )
        let mutated =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records:
                    mutatedRecords.map {
                        Data($0.utf8)
                    }
            )
        let restored =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records:
                    restoredRecords.map {
                        Data($0.utf8)
                    }
            )
        let baselineFingerprint =
            baseline.fingerprintObservation.direct
        let mutatedFingerprint =
            mutated.fingerprintObservation.direct
        let restoredFingerprint =
            restored.fingerprintObservation.direct
        let expected = mutationID.expectedFailedLeg
        let observation = Self(
            mutationID: mutationID,
            expectedFailedLeg: expected,
            baselineGlobalSHA256:
                baseline.manifest
                .globalStreamSHA256,
            mutatedGlobalSHA256:
                mutated.manifest
                .globalStreamSHA256,
            restoredGlobalSHA256:
                restored.manifest
                .globalStreamSHA256,
            baselineFingerprint:
                baselineFingerprint,
            mutatedFingerprint:
                mutatedFingerprint,
            restoredFingerprint:
                restoredFingerprint,
            callerReportedExpectedLegFailure:
                observedFailedLegIDs
                .contains(expected),
            independentMutationExecutionObserved:
                false,
            independentDetectorObserved: false,
            rawRecordsDiverged:
                baseline.globalStream
                    != mutated.globalStream,
            fingerprintDiverged:
                baselineFingerprint
                    != mutatedFingerprint,
            rawRecordsRestoredExactly:
                baseline.globalStream
                    == restored.globalStream,
            fingerprintRestoredExactly:
                baselineFingerprint
                    == restoredFingerprint
        )
        try observation.validate()
        return observation
    }

    public func validate() throws {
        guard expectedFailedLeg
                == mutationID.expectedFailedLeg,
              callerReportedExpectedLegFailure,
              !independentMutationExecutionObserved,
              !independentDetectorObserved,
              rawRecordsDiverged,
              baselineGlobalSHA256
                != mutatedGlobalSHA256,
              fingerprintDiverged,
              baselineFingerprint
                != mutatedFingerprint,
              rawRecordsRestoredExactly,
              baselineGlobalSHA256
                == restoredGlobalSHA256,
              fingerprintRestoredExactly,
              baselineFingerprint
                == restoredFingerprint
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidMutationObservation(
                    mutationID.rawValue
                )
        }
    }
}

public struct PrimeNativeNeuralGateCorrectedMutationSweepObservation:
    Equatable,
    Sendable
{
    public let observations:
        [PrimeNativeNeuralGateCorrectedMutationObservation]
    public let catalogComplete: Bool

    public static func recompute(
        observations:
            [PrimeNativeNeuralGateCorrectedMutationObservation]
    ) throws -> Self {
        guard observations.map(\.mutationID)
                == PrimeNativeNeuralGateCorrectedMutationID
                .allCases
        else {
            throw PrimeNativeNeuralGateCorrectedMechanicsError
                .invalidMutationCatalog
        }
        try observations.forEach {
            try $0.validate()
        }
        return Self(
            observations: observations,
            catalogComplete: true
        )
    }
}
