import Foundation
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateSemanticVerdictPolicy {
    public static let criticalLegCatalogSHA256 =
        "b25d5993dda60cfe3dfffacbdd9e56280383490aae5a0f8ca07b1b6ab76fb87c"
    public static let statisticsContractSHA256 =
        "c10ac090a9d24688e7aa1fb9aa4a4d3ffde4a7d705080e28a47aa46455c6bf0c"
    public static let capabilityThresholdContractSHA256 =
        "882f36f3aed229e9a55da353e9b64cbe28d5535a61b7f6b8e1c945c7bd316470"
    public static let verdictContractSHA256 =
        "a5a607f9a583fa932962c78f82e7407e5964fa1adb3c776e1cd21c095001973c"
    public static let finiteFieldContractSHA256 =
        "d042a33ee52550fcc9ea0cce14ddba4a03cb24f3900c73282b9491436d36a095"
    public static let weightedLossAggregationID =
        "target_token_weighted_row_unbiased_effective_n_v1"
    public static let fixedPromptPredicateID =
        "finite_positive_margins_and_stable_greedy_token_and_two_times_max_abs_logit_delta_strictly_below_min_margin"
    public static let triadicSemantics =
        "count_derived_label_not_four_tier_independence_audit"
    public static let countDerivedLabelScope =
        "provisional_count_only_non_authorizing"
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
}

public enum PrimeNativeNeuralGateSemanticMechanicsOutcome:
    String,
    Encodable,
    Equatable,
    Sendable
{
    case grounded = "GROUNDED"
    case abstain = "ABSTAIN"
}

public struct PrimeNativeNeuralGateSemanticCriticalLegObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let legID: String
    public let passed:
        PrimeNativeNeuralGateSemanticObservationState
    public let detail: String
    public let evidence:
        [PrimeNativeNeuralGateSemanticArtifactReference]

    public init(
        ordinal: Int,
        legID: String,
        passed:
            PrimeNativeNeuralGateSemanticObservationState,
        detail: String,
        evidence:
            [PrimeNativeNeuralGateSemanticArtifactReference]
                = []
    ) throws {
        self.ordinal = ordinal
        self.legID = legID
        self.passed = passed
        self.detail = detail
        self.evidence = evidence
        try validate()
    }

    public func validate() throws {
        let expected =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .orderedCriticalLegIDs
        guard ordinal > 0,
              ordinal <= expected.count,
              legID == expected[ordinal - 1],
              semanticIsBoundedUTF8(
                  detail,
                  maximumByteCount: 4_096
              ),
              evidence.count <= 64
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidStatisticsVerdict(legID)
        }
        try evidence.forEach { try $0.validate() }
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case legID = "leg_id"
        case passed
        case detail
        case evidence
    }
}

func semanticArtifactReferenceIsVerifiedAndDurablyPublished(
    _ reference: PrimeNativeNeuralGateSemanticArtifactReference
) -> Bool {
    reference.descriptorContentVerified == .observedTrue
        && reference.durablePublicationObserved == .observedTrue
}

func semanticCriticalLegEvidenceIsFullyBound(
    _ leg: PrimeNativeNeuralGateSemanticCriticalLegObservation
) -> Bool {
    !leg.evidence.isEmpty
        && leg.evidence.allSatisfy(
            semanticArtifactReferenceIsVerifiedAndDurablyPublished
        )
}

func semanticAllCriticalLegEvidenceIsFullyBound(
    _ legs: [PrimeNativeNeuralGateSemanticCriticalLegObservation]
) -> Bool {
    !legs.isEmpty
        && legs.allSatisfy(
            semanticCriticalLegEvidenceIsFullyBound
        )
}

public struct PrimeNativeNeuralGateWeightedStatisticsObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let aggregationID: String
    public let rowCount: Int
    public let totalTargetTokenCount: Int
    public let weightedMeanBefore: Double
    public let weightedMeanAfter: Double
    public let effectiveRows: Double
    public let unbiasedVarianceDenominator: Double
    public let weightedVarianceAfter: Double
    public let standardErrorAfter: Double
    public let absoluteTolerance: Double
    public let relativeTolerance: Double
    public let recomputationObserved:
        PrimeNativeNeuralGateSemanticObservationState

    public init(
        rowCount: Int,
        totalTargetTokenCount: Int,
        weightedMeanBefore: Double,
        weightedMeanAfter: Double,
        effectiveRows: Double,
        unbiasedVarianceDenominator: Double,
        weightedVarianceAfter: Double,
        standardErrorAfter: Double,
        recomputationObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        aggregationID =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .weightedLossAggregationID
        self.rowCount = rowCount
        self.totalTargetTokenCount =
            totalTargetTokenCount
        self.weightedMeanBefore = weightedMeanBefore
        self.weightedMeanAfter = weightedMeanAfter
        self.effectiveRows = effectiveRows
        self.unbiasedVarianceDenominator =
            unbiasedVarianceDenominator
        self.weightedVarianceAfter =
            weightedVarianceAfter
        self.standardErrorAfter = standardErrorAfter
        absoluteTolerance = 1e-12
        relativeTolerance = 1e-12
        self.recomputationObserved =
            recomputationObserved
        try validate()
    }

    public func validate() throws {
        let values = [
            weightedMeanBefore,
            weightedMeanAfter,
            effectiveRows,
            unbiasedVarianceDenominator,
            weightedVarianceAfter,
            standardErrorAfter,
            absoluteTolerance,
            relativeTolerance,
        ]
        guard aggregationID
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .weightedLossAggregationID,
              rowCount > 0,
              rowCount <= 1_000_000,
              totalTargetTokenCount >= rowCount,
              values.allSatisfy(\.isFinite),
              weightedMeanBefore > 0,
              weightedMeanAfter >= 0,
              effectiveRows > 0,
              effectiveRows <= Double(rowCount),
              unbiasedVarianceDenominator >= 0,
              weightedVarianceAfter >= 0,
              standardErrorAfter >= 0,
              absoluteTolerance == 1e-12,
              relativeTolerance == 1e-12
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidStatisticsVerdict("weighted_statistics")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case aggregationID = "aggregation_id"
        case rowCount = "row_count"
        case totalTargetTokenCount =
            "total_target_token_count"
        case weightedMeanBefore = "weighted_mean_before"
        case weightedMeanAfter = "weighted_mean_after"
        case effectiveRows = "effective_rows"
        case unbiasedVarianceDenominator =
            "unbiased_variance_denominator"
        case weightedVarianceAfter =
            "weighted_variance_after"
        case standardErrorAfter = "standard_error_after"
        case absoluteTolerance = "absolute_tolerance"
        case relativeTolerance = "relative_tolerance"
        case recomputationObserved =
            "recomputation_observed"
    }
}

public struct PrimeNativeNeuralGateFixedPromptMarginObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let predicateID: String
    public let logitCount: Int
    public let firstGreedyTokenID: Int
    public let replayGreedyTokenID: Int
    public let firstRunnerUpMargin: Double
    public let replayRunnerUpMargin: Double
    public let maximumAbsoluteLogitDelta: Double
    public let greedyTokenStable:
        PrimeNativeNeuralGateSemanticObservationState
    public let behavioralReplayExact:
        PrimeNativeNeuralGateSemanticObservationState
    public let bitwiseReplayExact:
        PrimeNativeNeuralGateSemanticObservationState

    public init(
        firstGreedyTokenID: Int,
        replayGreedyTokenID: Int,
        firstRunnerUpMargin: Double,
        replayRunnerUpMargin: Double,
        maximumAbsoluteLogitDelta: Double,
        greedyTokenStable:
            PrimeNativeNeuralGateSemanticObservationState,
        behavioralReplayExact:
            PrimeNativeNeuralGateSemanticObservationState,
        bitwiseReplayExact:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        predicateID =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .fixedPromptPredicateID
        logitCount = 512
        self.firstGreedyTokenID = firstGreedyTokenID
        self.replayGreedyTokenID = replayGreedyTokenID
        self.firstRunnerUpMargin = firstRunnerUpMargin
        self.replayRunnerUpMargin = replayRunnerUpMargin
        self.maximumAbsoluteLogitDelta =
            maximumAbsoluteLogitDelta
        self.greedyTokenStable = greedyTokenStable
        self.behavioralReplayExact =
            behavioralReplayExact
        self.bitwiseReplayExact = bitwiseReplayExact
        try validate()
    }

    public func validate() throws {
        let values = [
            firstRunnerUpMargin,
            replayRunnerUpMargin,
            maximumAbsoluteLogitDelta,
        ]
        let tokenIDsMatch =
            firstGreedyTokenID == replayGreedyTokenID
        let doubledDelta =
            2 * maximumAbsoluteLogitDelta
        let behavioralPredicate =
            firstRunnerUpMargin > 0
            && replayRunnerUpMargin > 0
            && tokenIDsMatch
            && doubledDelta.isFinite
            && doubledDelta
                < Swift.min(
                    firstRunnerUpMargin,
                    replayRunnerUpMargin
                )
        let greedyStateMatches =
            greedyTokenStable == .unavailable
            || greedyTokenStable
                == (tokenIDsMatch
                    ? .observedTrue
                    : .observedFalse)
        let behavioralStateMatches =
            behavioralReplayExact == .unavailable
            || behavioralReplayExact
                == (behavioralPredicate
                    ? .observedTrue
                    : .observedFalse)
        let bitwiseTrueIsConsistent =
            bitwiseReplayExact != .observedTrue
            || (tokenIDsMatch
                && firstRunnerUpMargin
                    == replayRunnerUpMargin
                && maximumAbsoluteLogitDelta == 0)
        guard predicateID
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .fixedPromptPredicateID,
              logitCount == 512,
              (0 ..< logitCount).contains(
                  firstGreedyTokenID
              ),
              (0 ..< logitCount).contains(
                  replayGreedyTokenID
              ),
              values.allSatisfy(\.isFinite),
              maximumAbsoluteLogitDelta >= 0,
              greedyStateMatches,
              behavioralStateMatches,
              bitwiseTrueIsConsistent
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidStatisticsVerdict("fixed_prompt_margin")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case predicateID = "predicate_id"
        case logitCount = "logit_count"
        case firstGreedyTokenID = "first_greedy_token_id"
        case replayGreedyTokenID = "replay_greedy_token_id"
        case firstRunnerUpMargin = "first_runner_up_margin"
        case replayRunnerUpMargin = "replay_runner_up_margin"
        case maximumAbsoluteLogitDelta =
            "maximum_absolute_logit_delta"
        case greedyTokenStable = "greedy_token_stable"
        case behavioralReplayExact =
            "behavioral_replay_exact"
        case bitwiseReplayExact = "bitwise_replay_exact"
    }
}

public enum PrimeNativeNeuralGateSemanticCapabilitySplit:
    String,
    CaseIterable,
    Encodable,
    Equatable,
    Sendable
{
    case validation
    case combinationHoldout = "combination_holdout"
    case outOfDistribution = "ood"
    case mutation
    case abstention

    public var requiredRowCount: Int {
        self == .abstention ? 2_048 : 4_096
    }

    public var minimumCorrectedAccuracy: Double? {
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

    public var correctedMustStrictlyImprove: Bool {
        self != .validation
    }
}

public struct PrimeNativeNeuralGateCapabilitySplitObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let split:
        PrimeNativeNeuralGateSemanticCapabilitySplit
    public let rowCount: Int
    public let zeroShotExactAccuracy: Double
    public let correctedExactAccuracy: Double
    public let thresholdSatisfied:
        PrimeNativeNeuralGateSemanticObservationState
    public let exactAbstentionDecisionsObserved:
        PrimeNativeNeuralGateSemanticObservationState

    public init(
        split:
            PrimeNativeNeuralGateSemanticCapabilitySplit,
        zeroShotExactAccuracy: Double,
        correctedExactAccuracy: Double,
        thresholdSatisfied:
            PrimeNativeNeuralGateSemanticObservationState,
        exactAbstentionDecisionsObserved:
            PrimeNativeNeuralGateSemanticObservationState = .unavailable
    ) throws {
        self.split = split
        rowCount = split.requiredRowCount
        self.zeroShotExactAccuracy =
            zeroShotExactAccuracy
        self.correctedExactAccuracy =
            correctedExactAccuracy
        self.thresholdSatisfied = thresholdSatisfied
        self.exactAbstentionDecisionsObserved =
            exactAbstentionDecisionsObserved
        try validate()
    }

    public func validate() throws {
        let minimumSatisfied =
            split.minimumCorrectedAccuracy.map {
                correctedExactAccuracy >= $0
            } ?? true
        let improvementSatisfied =
            !split.correctedMustStrictlyImprove
            || correctedExactAccuracy
                > zeroShotExactAccuracy
        let frozenAccuracyPredicate =
            minimumSatisfied && improvementSatisfied
        let derivedThresholdSatisfied: Bool? = {
            guard split == .abstention else {
                return frozenAccuracyPredicate
            }
            switch exactAbstentionDecisionsObserved {
            case .unavailable:
                return nil
            case .observedFalse:
                return false
            case .observedTrue:
                return frozenAccuracyPredicate
            }
        }()
        let expectedThresholdState =
            derivedThresholdSatisfied.map {
                $0 ? PrimeNativeNeuralGateSemanticObservationState
                    .observedTrue
                    : .observedFalse
            } ?? .unavailable
        let abstentionStateIsConsistent: Bool
        if split == .abstention {
            abstentionStateIsConsistent =
                exactAbstentionDecisionsObserved
                    != .observedTrue
                || correctedExactAccuracy == 1
        } else {
            abstentionStateIsConsistent =
                exactAbstentionDecisionsObserved == .unavailable
        }
        let thresholdStateIsConsistent: Bool
        if split == .abstention {
            thresholdStateIsConsistent =
                thresholdSatisfied == expectedThresholdState
        } else {
            thresholdStateIsConsistent =
                thresholdSatisfied == .unavailable
                || thresholdSatisfied == expectedThresholdState
        }
        guard rowCount == split.requiredRowCount,
              zeroShotExactAccuracy.isFinite,
              correctedExactAccuracy.isFinite,
              (0 ... 1).contains(zeroShotExactAccuracy),
              (0 ... 1).contains(correctedExactAccuracy),
              abstentionStateIsConsistent,
              thresholdStateIsConsistent
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidStatisticsVerdict(split.rawValue)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case split
        case rowCount = "row_count"
        case zeroShotExactAccuracy =
            "zero_shot_exact_accuracy"
        case correctedExactAccuracy =
            "corrected_exact_accuracy"
        case thresholdSatisfied = "threshold_satisfied"
        case exactAbstentionDecisionsObserved =
            "exact_abstention_decisions_observed"
    }
}

public struct PrimeNativeNeuralGateCapabilityObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let totalRowCount: Int
    public let splits:
        [PrimeNativeNeuralGateCapabilitySplitObservation]
    public let sourceBoundRowIdentityAndCoverage:
        PrimeNativeNeuralGateSemanticObservationState
    public let thresholdsSatisfied:
        PrimeNativeNeuralGateSemanticObservationState
    public let modelCapability:
        PrimeNativeNeuralGateSemanticObservationState

    public init(
        splits:
            [PrimeNativeNeuralGateCapabilitySplitObservation],
        sourceBoundRowIdentityAndCoverage:
            PrimeNativeNeuralGateSemanticObservationState,
        thresholdsSatisfied:
            PrimeNativeNeuralGateSemanticObservationState,
        modelCapability:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        totalRowCount = 18_432
        self.splits = splits
        self.sourceBoundRowIdentityAndCoverage =
            sourceBoundRowIdentityAndCoverage
        self.thresholdsSatisfied = thresholdsSatisfied
        self.modelCapability = modelCapability
        try validate()
    }

    public func validate() throws {
        try splits.forEach { try $0.validate() }
        let splitThresholdStates =
            splits.map(\.thresholdSatisfied)
        let expectedAggregateThresholdState:
            PrimeNativeNeuralGateSemanticObservationState
        if splitThresholdStates.contains(.observedFalse) {
            expectedAggregateThresholdState = .observedFalse
        } else if splitThresholdStates.allSatisfy({
            $0 == .observedTrue
        }) {
            expectedAggregateThresholdState = .observedTrue
        } else {
            expectedAggregateThresholdState = .unavailable
        }
        let modelCapabilityTrueIsBound =
            modelCapability != .observedTrue
            || (sourceBoundRowIdentityAndCoverage
                    == .observedTrue
                && thresholdsSatisfied == .observedTrue)
        guard totalRowCount == 18_432,
              splits.map(\.split)
                == PrimeNativeNeuralGateSemanticCapabilitySplit
                .allCases,
              splits.map(\.rowCount).reduce(0, +)
                == totalRowCount,
              thresholdsSatisfied
                == expectedAggregateThresholdState,
              modelCapabilityTrueIsBound
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidStatisticsVerdict("capability")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case totalRowCount = "total_row_count"
        case splits
        case sourceBoundRowIdentityAndCoverage =
            "source_bound_row_identity_and_coverage"
        case thresholdsSatisfied = "thresholds_satisfied"
        case modelCapability = "model_capability"
    }
}

/// Aggregate detector artifact reference. Per-mutation detector records and
/// detector behavior live outside this non-mutation schema file.
public struct PrimeNativeNeuralGateCorrectedDetectorObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let catalogID: String
    public let exactObservationCount: Int
    public let observationStream:
        PrimeNativeNeuralGateSemanticArtifactReference
    public let commonCaptureScheduleReferenceIdentitySHA256:
        String
    public let probeBranchReferenceIdentitySHA256: String
    public let verifierBranchReferenceIdentitySHA256: String
    public let exactCatalogCoverageObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let exactFailureSetsObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let independentDetectorObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let processDeliveryObserved: Bool
    public let mechanicsPassAuthorized: Bool

    public init(
        observationStream:
            PrimeNativeNeuralGateSemanticArtifactReference,
        commonCaptureScheduleReferenceIdentitySHA256:
            String,
        probeBranchReferenceIdentitySHA256: String,
        verifierBranchReferenceIdentitySHA256: String,
        exactCatalogCoverageObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        exactFailureSetsObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        independentDetectorObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        schemaVersion = 1
        schemaID =
            "prime_stage_b_corrected_detector_observation_v1"
        catalogID =
            "prime_stage_b_corrected_fixed_cap_eos_mutation_catalog_15_v1"
        exactObservationCount = 15
        self.observationStream = observationStream
        self.commonCaptureScheduleReferenceIdentitySHA256 =
            commonCaptureScheduleReferenceIdentitySHA256
        self.probeBranchReferenceIdentitySHA256 =
            probeBranchReferenceIdentitySHA256
        self.verifierBranchReferenceIdentitySHA256 =
            verifierBranchReferenceIdentitySHA256
        self.exactCatalogCoverageObserved =
            exactCatalogCoverageObserved
        self.exactFailureSetsObserved =
            exactFailureSetsObserved
        self.independentDetectorObserved =
            independentDetectorObserved
        processDeliveryObserved = false
        mechanicsPassAuthorized = false
        try validate()
    }

    public func validate() throws {
        try observationStream.validate()
        guard schemaVersion == 1,
              exactObservationCount
                == PrimeNativeNeuralGateMutationCatalog
                .correctedEntries.count,
              observationStream.relativePath
                == "neural-gate-replay/corrected/mutations/corrected_fixed_cap_eos/detector-observations.v1.bin",
              [
                  commonCaptureScheduleReferenceIdentitySHA256,
                  probeBranchReferenceIdentitySHA256,
                  verifierBranchReferenceIdentitySHA256,
              ].allSatisfy(semanticIsLowercaseSHA256),
              probeBranchReferenceIdentitySHA256
                != verifierBranchReferenceIdentitySHA256,
              !processDeliveryObserved,
              !mechanicsPassAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidStatisticsVerdict("detector_observation")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case catalogID = "catalog_id"
        case exactObservationCount = "exact_observation_count"
        case observationStream = "observation_stream"
        case commonCaptureScheduleReferenceIdentitySHA256 =
            "common_capture_schedule_reference_identity_sha256"
        case probeBranchReferenceIdentitySHA256 =
            "probe_branch_reference_identity_sha256"
        case verifierBranchReferenceIdentitySHA256 =
            "verifier_branch_reference_identity_sha256"
        case exactCatalogCoverageObserved =
            "exact_catalog_coverage_observed"
        case exactFailureSetsObserved =
            "exact_failure_sets_observed"
        case independentDetectorObserved =
            "independent_detector_observed"
        case processDeliveryObserved =
            "process_delivery_observed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
    }
}

public struct PrimeNativeNeuralGateStatisticsVerdictObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let arm: PrimeNativeNeuralGateArtifactArm
    public let criticalLegCatalogSHA256: String
    public let statisticsContractSHA256: String
    public let capabilityThresholdContractSHA256: String
    public let verdictContractSHA256: String
    public let finiteFieldContractSHA256: String
    public let weightedStatistics:
        PrimeNativeNeuralGateWeightedStatisticsObservation
    public let fixedPromptMargin:
        PrimeNativeNeuralGateFixedPromptMarginObservation
    public let capability:
        PrimeNativeNeuralGateCapabilityObservation
    public let criticalLegs:
        [PrimeNativeNeuralGateSemanticCriticalLegObservation]
    public let mutationSweepSatisfied:
        PrimeNativeNeuralGateSemanticObservationState
    public let passingLegCount: Int
    /// Provisional count-only lineage value. It never authorizes or directly
    /// determines `mechanicsOutcome`.
    public let countDerivedLabel: String
    public let countDerivedLabelScope: String
    public let mechanicsOutcome:
        PrimeNativeNeuralGateSemanticMechanicsOutcome
    public let sourceBoundCriticalLegEvidence:
        PrimeNativeNeuralGateSemanticObservationState
    public let distinctImplementationFamiliesEstablished:
        PrimeNativeNeuralGateSemanticObservationState
    public let agentContractKitFourTierAuditPerformed:
        PrimeNativeNeuralGateSemanticObservationState
    public let triadicSemantics: String
    public let perFamilyRankMarginAnalysisIncluded: Bool
    public let perFamilyDecisionMarginAnalysisIncluded:
        Bool
    public let confidenceIntervalsIncluded: Bool
    public let guardedStatisticalEntanglementIncluded:
        Bool
    public let mechanicsPassAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    public init(
        arm: PrimeNativeNeuralGateArtifactArm,
        weightedStatistics:
            PrimeNativeNeuralGateWeightedStatisticsObservation,
        fixedPromptMargin:
            PrimeNativeNeuralGateFixedPromptMarginObservation,
        capability:
            PrimeNativeNeuralGateCapabilityObservation,
        criticalLegs:
            [PrimeNativeNeuralGateSemanticCriticalLegObservation],
        mutationSweepSatisfied:
            PrimeNativeNeuralGateSemanticObservationState,
        sourceBoundCriticalLegEvidence:
            PrimeNativeNeuralGateSemanticObservationState,
        distinctImplementationFamiliesEstablished:
            PrimeNativeNeuralGateSemanticObservationState,
        agentContractKitFourTierAuditPerformed:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        schemaVersion = 1
        schemaID =
            arm == .correctedFixedCapEOS
            ? "prime_stage_b_corrected_statistics_verdict_observation_v1"
            : "prime_stage_b_historical_statistics_verdict_observation_v1"
        self.arm = arm
        criticalLegCatalogSHA256 =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .criticalLegCatalogSHA256
        statisticsContractSHA256 =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .statisticsContractSHA256
        capabilityThresholdContractSHA256 =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .capabilityThresholdContractSHA256
        verdictContractSHA256 =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .verdictContractSHA256
        finiteFieldContractSHA256 =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .finiteFieldContractSHA256
        self.weightedStatistics = weightedStatistics
        self.fixedPromptMargin = fixedPromptMargin
        self.capability = capability
        self.criticalLegs = criticalLegs
        self.mutationSweepSatisfied =
            mutationSweepSatisfied
        passingLegCount = criticalLegs.filter {
            $0.passed == .observedTrue
        }.count
        countDerivedLabel =
            passingLegCount >= 3
            ? "independentThreePlus(\(passingLegCount))"
            : "oracleDerived(\(passingLegCount))"
        countDerivedLabelScope =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .countDerivedLabelScope
        self.sourceBoundCriticalLegEvidence =
            sourceBoundCriticalLegEvidence
        self.distinctImplementationFamiliesEstablished =
            distinctImplementationFamiliesEstablished
        self.agentContractKitFourTierAuditPerformed =
            agentContractKitFourTierAuditPerformed
        mechanicsOutcome = Self.deriveMechanicsOutcome(
            weightedStatistics: weightedStatistics,
            fixedPromptMargin: fixedPromptMargin,
            capability: capability,
            criticalLegs: criticalLegs,
            mutationSweepSatisfied: mutationSweepSatisfied,
            sourceBoundCriticalLegEvidence:
                sourceBoundCriticalLegEvidence,
            distinctImplementationFamiliesEstablished:
                distinctImplementationFamiliesEstablished,
            agentContractKitFourTierAuditPerformed:
                agentContractKitFourTierAuditPerformed
        )
        triadicSemantics =
            PrimeNativeNeuralGateSemanticVerdictPolicy
            .triadicSemantics
        perFamilyRankMarginAnalysisIncluded = false
        perFamilyDecisionMarginAnalysisIncluded = false
        confidenceIntervalsIncluded = false
        guardedStatisticalEntanglementIncluded = false
        mechanicsPassAuthorized = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
        try validate()
    }

    public func validate() throws {
        try weightedStatistics.validate()
        try fixedPromptMargin.validate()
        try capability.validate()
        try criticalLegs.forEach { try $0.validate() }
        let count = criticalLegs.filter {
            $0.passed == .observedTrue
        }.count
        let expectedLabel =
            count >= 3
            ? "independentThreePlus(\(count))"
            : "oracleDerived(\(count))"
        let allCriticalLegEvidenceIsBound =
            semanticAllCriticalLegEvidenceIsFullyBound(
                criticalLegs
            )
        let expectedOutcome = Self.deriveMechanicsOutcome(
            weightedStatistics: weightedStatistics,
            fixedPromptMargin: fixedPromptMargin,
            capability: capability,
            criticalLegs: criticalLegs,
            mutationSweepSatisfied: mutationSweepSatisfied,
            sourceBoundCriticalLegEvidence:
                sourceBoundCriticalLegEvidence,
            distinctImplementationFamiliesEstablished:
                distinctImplementationFamiliesEstablished,
            agentContractKitFourTierAuditPerformed:
                agentContractKitFourTierAuditPerformed
        )
        guard schemaVersion == 1,
              [
                  criticalLegCatalogSHA256,
                  statisticsContractSHA256,
                  capabilityThresholdContractSHA256,
                  verdictContractSHA256,
                  finiteFieldContractSHA256,
              ].allSatisfy(semanticIsLowercaseSHA256),
              criticalLegs.count == 10,
              criticalLegs.map(\.ordinal)
                == Array(1 ... 10),
              criticalLegs.map(\.legID)
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .orderedCriticalLegIDs,
              passingLegCount == count,
              countDerivedLabel == expectedLabel,
              countDerivedLabelScope
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .countDerivedLabelScope,
              sourceBoundCriticalLegEvidence != .observedTrue
                || allCriticalLegEvidenceIsBound,
              mechanicsOutcome == expectedOutcome,
              triadicSemantics
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .triadicSemantics,
              !perFamilyRankMarginAnalysisIncluded,
              !perFamilyDecisionMarginAnalysisIncluded,
              !confidenceIntervalsIncluded,
              !guardedStatisticalEntanglementIncluded,
              !mechanicsPassAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidStatisticsVerdict("verdict")
        }
    }

    private static func deriveMechanicsOutcome(
        weightedStatistics:
            PrimeNativeNeuralGateWeightedStatisticsObservation,
        fixedPromptMargin:
            PrimeNativeNeuralGateFixedPromptMarginObservation,
        capability:
            PrimeNativeNeuralGateCapabilityObservation,
        criticalLegs:
            [PrimeNativeNeuralGateSemanticCriticalLegObservation],
        mutationSweepSatisfied:
            PrimeNativeNeuralGateSemanticObservationState,
        sourceBoundCriticalLegEvidence:
            PrimeNativeNeuralGateSemanticObservationState,
        distinctImplementationFamiliesEstablished:
            PrimeNativeNeuralGateSemanticObservationState,
        agentContractKitFourTierAuditPerformed:
            PrimeNativeNeuralGateSemanticObservationState
    ) -> PrimeNativeNeuralGateSemanticMechanicsOutcome {
        let allTenCriticalLegsObservedTrue =
            criticalLegs.count
                == PrimeNativeNeuralGateSemanticVerdictPolicy
                .orderedCriticalLegIDs.count
            && criticalLegs.allSatisfy {
                $0.passed == .observedTrue
            }
        let allTrueLegEvidenceIsFullyBound =
            criticalLegs.allSatisfy {
                $0.passed != .observedTrue
                    || semanticCriticalLegEvidenceIsFullyBound($0)
            }
        guard allTenCriticalLegsObservedTrue,
              allTrueLegEvidenceIsFullyBound,
              weightedStatistics.recomputationObserved
                == .observedTrue,
              fixedPromptMargin.greedyTokenStable
                == .observedTrue,
              fixedPromptMargin.behavioralReplayExact
                == .observedTrue,
              capability.modelCapability == .observedTrue,
              mutationSweepSatisfied == .observedTrue,
              sourceBoundCriticalLegEvidence == .observedTrue,
              distinctImplementationFamiliesEstablished
                == .observedTrue,
              agentContractKitFourTierAuditPerformed
                == .observedTrue
        else {
            return .abstain
        }
        return .grounded
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case arm
        case criticalLegCatalogSHA256 =
            "critical_leg_catalog_sha256"
        case statisticsContractSHA256 =
            "statistics_contract_sha256"
        case capabilityThresholdContractSHA256 =
            "capability_threshold_contract_sha256"
        case verdictContractSHA256 =
            "verdict_contract_sha256"
        case finiteFieldContractSHA256 =
            "finite_field_contract_sha256"
        case weightedStatistics = "weighted_statistics"
        case fixedPromptMargin = "fixed_prompt_margin"
        case capability
        case criticalLegs = "critical_legs"
        case mutationSweepSatisfied =
            "mutation_sweep_satisfied"
        case passingLegCount = "passing_leg_count"
        case countDerivedLabel = "count_derived_label"
        case countDerivedLabelScope =
            "count_derived_label_scope"
        case mechanicsOutcome = "mechanics_outcome"
        case sourceBoundCriticalLegEvidence =
            "source_bound_critical_leg_evidence"
        case distinctImplementationFamiliesEstablished =
            "distinct_implementation_families_established"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case triadicSemantics = "triadic_semantics"
        case perFamilyRankMarginAnalysisIncluded =
            "per_family_rank_margin_analysis_included"
        case perFamilyDecisionMarginAnalysisIncluded =
            "per_family_decision_margin_analysis_included"
        case confidenceIntervalsIncluded =
            "confidence_intervals_included"
        case guardedStatisticalEntanglementIncluded =
            "guarded_statistical_entanglement_included"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
    }
}

public struct
    PrimeNativeNeuralGateCorrectedStatisticsVerdictObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let observation:
        PrimeNativeNeuralGateStatisticsVerdictObservation
    public let detectorObservation:
        PrimeNativeNeuralGateSemanticArtifactReference
    public let evaluationObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let durablePublicationObserved: Bool
    public let mechanicsPassAuthorized: Bool

    public init(
        observation:
            PrimeNativeNeuralGateStatisticsVerdictObservation,
        detectorObservation:
            PrimeNativeNeuralGateSemanticArtifactReference,
        evaluationObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        schemaVersion = 1
        schemaID =
            "prime_stage_b_corrected_statistics_verdict_observation_v1"
        self.observation = observation
        self.detectorObservation = detectorObservation
        self.evaluationObserved = evaluationObserved
        durablePublicationObserved = false
        mechanicsPassAuthorized = false
        try validate()
    }

    public func validate() throws {
        try observation.validate()
        try detectorObservation.validate()
        guard schemaVersion == 1,
              observation.arm == .correctedFixedCapEOS,
              detectorObservation.relativePath
                == "neural-gate-replay/corrected/mutations/corrected_fixed_cap_eos/detector-observations.v1.bin",
              !durablePublicationObserved,
              !mechanicsPassAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidStatisticsVerdict("corrected_wrapper")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case observation
        case detectorObservation = "detector_observation"
        case evaluationObserved = "evaluation_observed"
        case durablePublicationObserved =
            "durable_publication_observed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
    }
}
