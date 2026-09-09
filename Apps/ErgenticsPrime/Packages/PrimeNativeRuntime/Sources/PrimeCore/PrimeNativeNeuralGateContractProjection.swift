import Foundation

public enum PrimeNativeNeuralGateContractProjectionError:
    Error,
    Equatable,
    LocalizedError,
    Sendable
{
    case invalidSourceBinding(String)
    case invalidFiniteFieldContract
    case invalidStatisticalContract
    case invalidCapabilityThresholdContract
    case invalidVerdictContract
    case invalidProjection(String)

    public var errorDescription: String? {
        switch self {
        case let .invalidSourceBinding(role):
            "native neural-gate source binding is invalid: \(role)"
        case .invalidFiniteFieldContract:
            "native neural-gate finite-field contract drifted"
        case .invalidStatisticalContract:
            "native neural-gate statistical contract drifted"
        case .invalidCapabilityThresholdContract:
            "native neural-gate capability-threshold contract drifted"
        case .invalidVerdictContract:
            "native neural-gate verdict contract drifted"
        case let .invalidProjection(detail):
            "native neural-gate contract projection drifted: \(detail)"
        }
    }
}

private enum PrimeNativeNeuralGateContractHex {
    static func isLowercaseHex(
        _ value: String,
        byteCount: Int
    ) -> Bool {
        value.utf8.count == byteCount * 2
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57)
                    || ($0 >= 97 && $0 <= 102)
            }
    }
}

public enum PrimeNativeNeuralGateSourceRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case nativeLanguageGate =
        "native_language_gate"
    case nativeByteTokenizerAuthority =
        "native_byte_tokenizer_authority"
    case nativeTextCorpusAuthority =
        "native_text_corpus_authority"
    case canaryReportAuthority =
        "canary_report_authority"
    case runConfigurationAuthority =
        "run_configuration_authority"
    case artifactPathSafetyAuthority =
        "artifact_path_safety_authority"
    case profileTrialFailureAuthority =
        "profile_trial_failure_authority"
    case scaleRecommendationLineage =
        "scale_recommendation_lineage"
    case verdictCarrier = "verdict_carrier"
    case behavioralRegressionFixture =
        "behavioral_regression_fixture"
}

/// Exact historical source identity. These bindings are lineage and
/// contract evidence; Stage A does not resolve or execute their bytes.
public struct PrimeNativeNeuralGateSourceBinding:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeNativeNeuralGateSourceRole
    public let repositoryRelativePath: String
    public let mode: String
    public let objectType: String
    public let gitBlobOID: String
    public let byteCount: UInt64
    public let sha256: String
    public let semanticScope: String

    public init(
        role: PrimeNativeNeuralGateSourceRole,
        repositoryRelativePath: String,
        mode: String,
        objectType: String,
        gitBlobOID: String,
        byteCount: UInt64,
        sha256: String,
        semanticScope: String
    ) {
        self.role = role
        self.repositoryRelativePath =
            repositoryRelativePath
        self.mode = mode
        self.objectType = objectType
        self.gitBlobOID = gitBlobOID
        self.byteCount = byteCount
        self.sha256 = sha256
        self.semanticScope = semanticScope
    }

    public func validate() throws {
        let components = repositoryRelativePath.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        guard !components.isEmpty,
              components.allSatisfy({
                  !$0.isEmpty && $0 != "." && $0 != ".."
              }),
              !repositoryRelativePath.hasPrefix("/"),
              !repositoryRelativePath.contains("\0"),
              mode == "100644",
              objectType == "blob",
              PrimeNativeNeuralGateContractHex
                .isLowercaseHex(
                    gitBlobOID,
                    byteCount: 20
                ),
              byteCount > 0,
              PrimeNativeNeuralGateContractHex
                .isLowercaseHex(
                    sha256,
                    byteCount: 32
                ),
              !semanticScope.isEmpty
        else {
            throw PrimeNativeNeuralGateContractProjectionError
                .invalidSourceBinding(role.rawValue)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case role
        case repositoryRelativePath =
            "repository_relative_path"
        case mode
        case objectType = "object_type"
        case gitBlobOID = "git_blob_oid"
        case byteCount = "byte_count"
        case sha256
        case semanticScope = "semantic_scope"
    }
}

public struct PrimeNativeNeuralGateCriticalLegContract:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let legID: String
    public let projectedMeaning: String

    public init(
        ordinal: Int,
        legID: String,
        projectedMeaning: String
    ) {
        self.ordinal = ordinal
        self.legID = legID
        self.projectedMeaning = projectedMeaning
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case legID = "leg_id"
        case projectedMeaning =
            "projected_meaning"
    }
}

public enum PrimeNativeNeuralGateMutation:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case obsoleteSchema = "obsolete_schema"
    case lineage
    case quantHessianLineage =
        "quant_hessian_lineage"
    case profile
    case debugBuildConfiguration =
        "debug_build_configuration"
    case nonFloat32Precision =
        "non_float32_precision"
    case tokenizer
    case corpusSplitLeakage =
        "corpus_split_leakage"
    case corpusLabelLeakage =
        "corpus_label_leakage"
    case corpusOverCapTarget =
        "corpus_over_cap_target"
    case corpusPromptWindow =
        "corpus_prompt_window"
    case targetLengthOracleLeakage =
        "target_length_oracle_leakage"
    case targetDependentPromptGrouping =
        "target_dependent_prompt_grouping"
    case constrainedASCIIDecoding =
        "constrained_ascii_decoding"
    case eosUnavailable = "eos_unavailable"
    case immediateEOSMeanOmission =
        "immediate_eos_mean_omission"
    case supportWitnessInconsistency =
        "support_witness_inconsistency"
    case trainedSupportAssistance =
        "trained_support_assistance"
    case executorPrediction = "executor_prediction"
    case executorRowHash = "executor_row_hash"
    case causalTraining = "causal_training"
    case heldoutLossEvidence =
        "heldout_loss_evidence"
    case refusalReasonScheduleCount =
        "refusal_reason_schedule_count"
    case refusalReasonScheduleHash =
        "refusal_reason_schedule_hash"
    case optimizerProvenance =
        "optimizer_provenance"
    case executorWallNonFinite =
        "executor_wall_non_finite"
    case executorWallZero =
        "executor_wall_zero"
    case executorWallOverCap =
        "executor_wall_over_cap"
    case cachedUncachedMultiStepDelta =
        "cached_uncached_multi_step_delta"
    case cachedUncachedMultiStepParity =
        "cached_uncached_multi_step_parity"
    case cachedUncachedMultiStepDecisionCount =
        "cached_uncached_multi_step_decision_count"
    case cachedUncachedMultiStepUnevenEOS =
        "cached_uncached_multi_step_uneven_eos"
    case executorArtifactDigest =
        "executor_artifact_digest"
    case executorArtifactFileName =
        "executor_artifact_file_name"
    case recommenderArtifactDigest =
        "recommender_artifact_digest"
    case recommenderArtifactFileName =
        "recommender_artifact_file_name"
    case configurationArtifactDigest =
        "configuration_artifact_digest"
    case configurationArtifactFileName =
        "configuration_artifact_file_name"
    case configurationWallCapMismatch =
        "configuration_wall_cap_mismatch"
    case metalLibraryArtifactDigest =
        "metal_library_artifact_digest"
    case metalLibraryBundleShadowAudit =
        "metal_library_bundle_shadow_audit"
    case durabilityCheckpoint =
        "durability_checkpoint"
    case durabilityProvenanceMismatch =
        "durability_provenance_mismatch"
    case sameSeedReplay = "same_seed_replay"
    case seedConsensus = "seed_consensus"
    case malformedAbstention =
        "malformed_abstention"

    public var expectedFailedLeg: String {
        switch self {
        case .obsoleteSchema,
             .lineage,
             .quantHessianLineage,
             .profile,
             .debugBuildConfiguration,
             .nonFloat32Precision,
             .executorArtifactDigest,
             .executorArtifactFileName,
             .recommenderArtifactDigest,
             .recommenderArtifactFileName,
             .configurationArtifactDigest,
             .configurationArtifactFileName,
             .configurationWallCapMismatch,
             .metalLibraryArtifactDigest,
             .metalLibraryBundleShadowAudit:
            "NL1_canonical_material_reload"
        case .tokenizer,
             .corpusSplitLeakage,
             .corpusLabelLeakage,
             .corpusOverCapTarget,
             .corpusPromptWindow:
            "NL3_foundation_tokenizer_corpus_regrade"
        case .targetLengthOracleLeakage,
             .targetDependentPromptGrouping,
             .constrainedASCIIDecoding,
             .eosUnavailable,
             .immediateEOSMeanOmission,
             .supportWitnessInconsistency,
             .executorPrediction,
             .executorRowHash:
            "NL4_raw_executor_row_regrade"
        case .causalTraining,
             .heldoutLossEvidence,
             .refusalReasonScheduleCount,
             .refusalReasonScheduleHash,
             .optimizerProvenance,
             .executorWallNonFinite,
             .executorWallZero,
             .executorWallOverCap,
             .cachedUncachedMultiStepDelta,
             .cachedUncachedMultiStepParity,
             .cachedUncachedMultiStepDecisionCount,
             .cachedUncachedMultiStepUnevenEOS:
            "NL5_causal_training_mechanics"
        case .durabilityCheckpoint,
             .durabilityProvenanceMismatch:
            "NL6_checkpoint_durability"
        case .sameSeedReplay:
            "NL7_same_seed_initialization_training_result_replay"
        case .seedConsensus:
            "NL8_frozen_exact_seed_consensus"
        case .malformedAbstention,
             .trainedSupportAssistance:
            "NL9_capability_and_malformed_abstention"
        }
    }

    public var mutatesRawPredictions: Bool {
        switch self {
        case .corpusLabelLeakage,
             .corpusOverCapTarget,
             .targetLengthOracleLeakage,
             .targetDependentPromptGrouping,
             .constrainedASCIIDecoding,
             .eosUnavailable,
             .immediateEOSMeanOmission,
             .supportWitnessInconsistency,
             .trainedSupportAssistance,
             .executorPrediction,
             .executorRowHash,
             .malformedAbstention:
            true
        default:
            false
        }
    }
}

public struct PrimeNativeNeuralGateMutationContract:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let mutationID: String
    public let expectedFailedLeg: String
    public let mutatesRawPredictions: Bool

    public init(
        ordinal: Int,
        mutation:
            PrimeNativeNeuralGateMutation
    ) {
        self.ordinal = ordinal
        mutationID = mutation.rawValue
        expectedFailedLeg =
            mutation.expectedFailedLeg
        mutatesRawPredictions =
            mutation.mutatesRawPredictions
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case mutationID = "mutation_id"
        case expectedFailedLeg =
            "expected_failed_leg"
        case mutatesRawPredictions =
            "mutates_raw_predictions"
    }
}

public struct PrimeNativeNeuralGateFiniteFieldFingerprint:
    Codable,
    Equatable,
    Sendable
{
    public let prime: UInt64
    public let evaluationPoints: [UInt64]
    public let residues: [UInt64]
    public let recordCount: Int

    public init(
        prime: UInt64,
        evaluationPoints: [UInt64],
        residues: [UInt64],
        recordCount: Int
    ) {
        self.prime = prime
        self.evaluationPoints = evaluationPoints
        self.residues = residues
        self.recordCount = recordCount
    }

    private enum CodingKeys: String, CodingKey {
        case prime
        case evaluationPoints =
            "evaluation_points"
        case residues
        case recordCount = "record_count"
    }
}

public struct PrimeNativeNeuralGateFiniteFieldContract:
    Codable,
    Equatable,
    Sendable
{
    public let prime: UInt64
    public let evaluationPoints: [UInt64]
    public let recordOrdering: String
    public let lengthPrefix: String
    public let accumulatorSeed: UInt64
    public let byteOffset: UInt64
    public let acceleratedPathRequiresDirectEquality:
        Bool

    public static let frozenV1 = Self(
        prime: 2_147_483_647,
        evaluationPoints: [
            257, 65_537, 1_000_003,
        ],
        recordOrdering:
            "raw_utf8_lexicographic_ascending",
        lengthPrefix:
            "uint64_big_endian_utf8_byte_count",
        accumulatorSeed: 1,
        byteOffset: 1,
        acceleratedPathRequiresDirectEquality:
            true
    )

    public init(
        prime: UInt64,
        evaluationPoints: [UInt64],
        recordOrdering: String,
        lengthPrefix: String,
        accumulatorSeed: UInt64,
        byteOffset: UInt64,
        acceleratedPathRequiresDirectEquality:
            Bool
    ) {
        self.prime = prime
        self.evaluationPoints = evaluationPoints
        self.recordOrdering = recordOrdering
        self.lengthPrefix = lengthPrefix
        self.accumulatorSeed = accumulatorSeed
        self.byteOffset = byteOffset
        self.acceleratedPathRequiresDirectEquality =
            acceleratedPathRequiresDirectEquality
    }

    public func validate() throws {
        guard self == .frozenV1,
              Set(evaluationPoints).count
                == evaluationPoints.count,
              evaluationPoints.allSatisfy({
                  $0 > 1 && $0 < prime
              })
        else {
            throw PrimeNativeNeuralGateContractProjectionError
                .invalidFiniteFieldContract
        }
    }

    public func fingerprint(
        records: [String]
    ) throws
        -> PrimeNativeNeuralGateFiniteFieldFingerprint
    {
        try validate()
        let canonical = records.sorted {
            $0.utf8.lexicographicallyPrecedes(
                $1.utf8
            )
        }
        let residues = evaluationPoints.map {
            point in
            var accumulator = accumulatorSeed
            for record in canonical {
                var count =
                    UInt64(record.utf8.count).bigEndian
                withUnsafeBytes(of: &count) {
                    bytes in
                    for byte in bytes {
                        accumulator =
                            (
                                accumulator * point
                                    + UInt64(byte)
                                    + byteOffset
                            ) % prime
                    }
                }
                for byte in record.utf8 {
                    accumulator =
                        (
                            accumulator * point
                                + UInt64(byte)
                                + byteOffset
                        ) % prime
                }
            }
            return accumulator
        }
        return PrimeNativeNeuralGateFiniteFieldFingerprint(
            prime: prime,
            evaluationPoints: evaluationPoints,
            residues: residues,
            recordCount: canonical.count
        )
    }

    private enum CodingKeys: String, CodingKey {
        case prime
        case evaluationPoints =
            "evaluation_points"
        case recordOrdering = "record_ordering"
        case lengthPrefix = "length_prefix"
        case accumulatorSeed =
            "accumulator_seed"
        case byteOffset = "byte_offset"
        case acceleratedPathRequiresDirectEquality =
            "accelerated_path_requires_direct_equality"
    }
}

public struct PrimeNativeNeuralGateStatisticalContract:
    Codable,
    Equatable,
    Sendable
{
    public let lossAggregationID: String
    public let rowWeight: String
    public let weightedMeanFormula: String
    public let effectiveSampleSizeFormula: String
    public let unbiasedWeightedVarianceDenominator:
        String
    public let weightedSquaredDeviationFormula:
        String
    public let weightedVarianceFormula: String
    public let nonpositiveVarianceDenominatorBehavior:
        String
    public let standardErrorFormula: String
    public let absoluteTolerance: Double
    public let relativeTolerance: Double
    public let finiteLossesRequired: Bool
    public let fixedPromptRunnerUpMarginReplayRequired:
        Bool
    public let fixedPromptRunnerUpMarginPredicate:
        String
    public let fixedPromptReplayEvidenceFieldsMustEqualRecomputation:
        Bool
    public let fixedPromptResultExactIsBitwiseLogitEquality:
        Bool
    public let perFamilyRankMarginStatisticalAnalysisIncluded:
        Bool
    public let perFamilyDecisionMarginStatisticalAnalysisIncluded:
        Bool
    public let confidenceIntervalsIncluded: Bool
    public let guardedStatisticalEntanglementIncluded:
        Bool

    public static let frozenV1 = Self(
        lossAggregationID:
            "target_token_weighted_row_unbiased_effective_n_v1",
        rowWeight: "target_token_count",
        weightedMeanFormula:
            "sum_wx_div_sum_w_after_positive_total_weight_guard",
        effectiveSampleSizeFormula:
            "square_sum_w_div_max_1_sum_square_w",
        unbiasedWeightedVarianceDenominator:
            "sum_w_minus_sum_square_w_div_max_1_sum_w",
        weightedSquaredDeviationFormula:
            "sum_w_times_square_x_after_minus_weighted_mean_after",
        weightedVarianceFormula:
            "weighted_squared_deviation_div_unbiased_denominator_when_positive",
        nonpositiveVarianceDenominatorBehavior:
            "variance_zero",
        standardErrorFormula:
            "sqrt(weighted_unbiased_variance_div_max_1_effective_rows)",
        absoluteTolerance: 1e-12,
        relativeTolerance: 1e-12,
        finiteLossesRequired: true,
        fixedPromptRunnerUpMarginReplayRequired:
            true,
        fixedPromptRunnerUpMarginPredicate:
            "finite_positive_margins_and_stable_greedy_token_and_two_times_max_abs_logit_delta_strictly_below_min_margin",
        fixedPromptReplayEvidenceFieldsMustEqualRecomputation:
            true,
        fixedPromptResultExactIsBitwiseLogitEquality:
            true,
        perFamilyRankMarginStatisticalAnalysisIncluded:
            false,
        perFamilyDecisionMarginStatisticalAnalysisIncluded:
            false,
        confidenceIntervalsIncluded: false,
        guardedStatisticalEntanglementIncluded:
            false
    )

    public init(
        lossAggregationID: String,
        rowWeight: String,
        weightedMeanFormula: String,
        effectiveSampleSizeFormula: String,
        unbiasedWeightedVarianceDenominator:
            String,
        weightedSquaredDeviationFormula:
            String,
        weightedVarianceFormula: String,
        nonpositiveVarianceDenominatorBehavior:
            String,
        standardErrorFormula: String,
        absoluteTolerance: Double,
        relativeTolerance: Double,
        finiteLossesRequired: Bool,
        fixedPromptRunnerUpMarginReplayRequired:
            Bool,
        fixedPromptRunnerUpMarginPredicate:
            String,
        fixedPromptReplayEvidenceFieldsMustEqualRecomputation:
            Bool,
        fixedPromptResultExactIsBitwiseLogitEquality:
            Bool,
        perFamilyRankMarginStatisticalAnalysisIncluded:
            Bool,
        perFamilyDecisionMarginStatisticalAnalysisIncluded:
            Bool,
        confidenceIntervalsIncluded: Bool,
        guardedStatisticalEntanglementIncluded:
            Bool
    ) {
        self.lossAggregationID =
            lossAggregationID
        self.rowWeight = rowWeight
        self.weightedMeanFormula =
            weightedMeanFormula
        self.effectiveSampleSizeFormula =
            effectiveSampleSizeFormula
        self.unbiasedWeightedVarianceDenominator =
            unbiasedWeightedVarianceDenominator
        self.weightedSquaredDeviationFormula =
            weightedSquaredDeviationFormula
        self.weightedVarianceFormula =
            weightedVarianceFormula
        self.nonpositiveVarianceDenominatorBehavior =
            nonpositiveVarianceDenominatorBehavior
        self.standardErrorFormula =
            standardErrorFormula
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.finiteLossesRequired =
            finiteLossesRequired
        self.fixedPromptRunnerUpMarginReplayRequired =
            fixedPromptRunnerUpMarginReplayRequired
        self.fixedPromptRunnerUpMarginPredicate =
            fixedPromptRunnerUpMarginPredicate
        self.fixedPromptReplayEvidenceFieldsMustEqualRecomputation =
            fixedPromptReplayEvidenceFieldsMustEqualRecomputation
        self.fixedPromptResultExactIsBitwiseLogitEquality =
            fixedPromptResultExactIsBitwiseLogitEquality
        self.perFamilyRankMarginStatisticalAnalysisIncluded =
            perFamilyRankMarginStatisticalAnalysisIncluded
        self.perFamilyDecisionMarginStatisticalAnalysisIncluded =
            perFamilyDecisionMarginStatisticalAnalysisIncluded
        self.confidenceIntervalsIncluded =
            confidenceIntervalsIncluded
        self.guardedStatisticalEntanglementIncluded =
            guardedStatisticalEntanglementIncluded
    }

    public func validate() throws {
        guard self == .frozenV1,
              absoluteTolerance.isFinite,
              relativeTolerance.isFinite,
              absoluteTolerance > 0,
              relativeTolerance > 0,
              finiteLossesRequired,
              fixedPromptRunnerUpMarginReplayRequired,
              !fixedPromptRunnerUpMarginPredicate.isEmpty,
              fixedPromptReplayEvidenceFieldsMustEqualRecomputation,
              fixedPromptResultExactIsBitwiseLogitEquality,
              !perFamilyRankMarginStatisticalAnalysisIncluded,
              !perFamilyDecisionMarginStatisticalAnalysisIncluded,
              !confidenceIntervalsIncluded,
              !guardedStatisticalEntanglementIncluded
        else {
            throw PrimeNativeNeuralGateContractProjectionError
                .invalidStatisticalContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case lossAggregationID =
            "loss_aggregation_id"
        case rowWeight = "row_weight"
        case weightedMeanFormula =
            "weighted_mean_formula"
        case effectiveSampleSizeFormula =
            "effective_sample_size_formula"
        case unbiasedWeightedVarianceDenominator =
            "unbiased_weighted_variance_denominator"
        case weightedSquaredDeviationFormula =
            "weighted_squared_deviation_formula"
        case weightedVarianceFormula =
            "weighted_variance_formula"
        case nonpositiveVarianceDenominatorBehavior =
            "nonpositive_variance_denominator_behavior"
        case standardErrorFormula =
            "standard_error_formula"
        case absoluteTolerance =
            "absolute_tolerance"
        case relativeTolerance =
            "relative_tolerance"
        case finiteLossesRequired =
            "finite_losses_required"
        case fixedPromptRunnerUpMarginReplayRequired =
            "fixed_prompt_runner_up_margin_replay_required"
        case fixedPromptRunnerUpMarginPredicate =
            "fixed_prompt_runner_up_margin_predicate"
        case fixedPromptReplayEvidenceFieldsMustEqualRecomputation =
            "fixed_prompt_replay_evidence_fields_must_equal_recomputation"
        case fixedPromptResultExactIsBitwiseLogitEquality =
            "fixed_prompt_result_exact_is_bitwise_logit_equality"
        case perFamilyRankMarginStatisticalAnalysisIncluded =
            "per_family_rank_margin_statistical_analysis_included"
        case perFamilyDecisionMarginStatisticalAnalysisIncluded =
            "per_family_decision_margin_statistical_analysis_included"
        case confidenceIntervalsIncluded =
            "confidence_intervals_included"
        case guardedStatisticalEntanglementIncluded =
            "guarded_statistical_entanglement_included"
    }
}

public struct PrimeNativeNeuralGateSplitContract:
    Codable,
    Equatable,
    Sendable
{
    public let split: String
    public let requiredRows: Int
    public let minimumTrainedExactAccuracy:
        Double?
    public let trainedMustStrictlyImproveOverZeroShot:
        Bool

    public init(
        split: String,
        requiredRows: Int,
        minimumTrainedExactAccuracy:
            Double?,
        trainedMustStrictlyImproveOverZeroShot:
            Bool
    ) {
        self.split = split
        self.requiredRows = requiredRows
        self.minimumTrainedExactAccuracy =
            minimumTrainedExactAccuracy
        self.trainedMustStrictlyImproveOverZeroShot =
            trainedMustStrictlyImproveOverZeroShot
    }

    private enum CodingKeys: String, CodingKey {
        case split
        case requiredRows = "required_rows"
        case minimumTrainedExactAccuracy =
            "minimum_trained_exact_accuracy"
        case trainedMustStrictlyImproveOverZeroShot =
            "trained_must_strictly_improve_over_zero_shot"
    }
}

public struct PrimeNativeNeuralGateCapabilityThresholdContract:
    Codable,
    Equatable,
    Sendable
{
    public let splits:
        [PrimeNativeNeuralGateSplitContract]
    public let validationIsSelectionTelemetry:
        Bool
    public let heldCapabilitySplitIDs: [String]
    public let requiredTotalRows: Int
    public let malformedAndRefusalAbstentionMustBeExact:
        Bool

    public static let frozenV1 = Self(
        splits: [
            PrimeNativeNeuralGateSplitContract(
                split: "validation",
                requiredRows: 4_096,
                minimumTrainedExactAccuracy: nil,
                trainedMustStrictlyImproveOverZeroShot:
                    false
            ),
            PrimeNativeNeuralGateSplitContract(
                split: "combination_holdout",
                requiredRows: 4_096,
                minimumTrainedExactAccuracy: 0.80,
                trainedMustStrictlyImproveOverZeroShot:
                    true
            ),
            PrimeNativeNeuralGateSplitContract(
                split: "ood",
                requiredRows: 4_096,
                minimumTrainedExactAccuracy: 0.70,
                trainedMustStrictlyImproveOverZeroShot:
                    true
            ),
            PrimeNativeNeuralGateSplitContract(
                split: "mutation",
                requiredRows: 4_096,
                minimumTrainedExactAccuracy: 0.80,
                trainedMustStrictlyImproveOverZeroShot:
                    true
            ),
            PrimeNativeNeuralGateSplitContract(
                split: "abstention",
                requiredRows: 2_048,
                minimumTrainedExactAccuracy: 1,
                trainedMustStrictlyImproveOverZeroShot:
                    true
            ),
        ],
        validationIsSelectionTelemetry: true,
        heldCapabilitySplitIDs: [
            "combination_holdout",
            "ood",
            "mutation",
            "abstention",
        ],
        requiredTotalRows: 18_432,
        malformedAndRefusalAbstentionMustBeExact:
            true
    )

    public init(
        splits:
            [PrimeNativeNeuralGateSplitContract],
        validationIsSelectionTelemetry: Bool,
        heldCapabilitySplitIDs: [String],
        requiredTotalRows: Int,
        malformedAndRefusalAbstentionMustBeExact:
            Bool
    ) {
        self.splits = splits
        self.validationIsSelectionTelemetry =
            validationIsSelectionTelemetry
        self.heldCapabilitySplitIDs =
            heldCapabilitySplitIDs
        self.requiredTotalRows =
            requiredTotalRows
        self.malformedAndRefusalAbstentionMustBeExact =
            malformedAndRefusalAbstentionMustBeExact
    }

    public func validate() throws {
        guard self == .frozenV1,
              Set(splits.map(\.split)).count
                == splits.count,
              splits.map(\.requiredRows)
                .reduce(0, +) == requiredTotalRows,
              validationIsSelectionTelemetry,
              malformedAndRefusalAbstentionMustBeExact
        else {
            throw PrimeNativeNeuralGateContractProjectionError
                .invalidCapabilityThresholdContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case splits
        case validationIsSelectionTelemetry =
            "validation_is_selection_telemetry"
        case heldCapabilitySplitIDs =
            "held_capability_split_ids"
        case requiredTotalRows =
            "required_total_rows"
        case malformedAndRefusalAbstentionMustBeExact =
            "malformed_and_refusal_abstention_must_be_exact"
    }
}

public struct PrimeNativeNeuralGateVerdictContract:
    Codable,
    Equatable,
    Sendable
{
    public let minimumIndependentPassingCountForCountLabel:
        Int
    public let allCriticalLegsRequiredForGrounded:
        Bool
    public let requiredCriticalLegCount: Int
    public let passingLabelFormat: String
    public let abstainLabelFormat: String
    public let triadicSemantics: String
    public let distinctImplementationFamiliesEstablished:
        Bool
    public let agentContractKitFourTierAuditPerformed:
        Bool

    public static let frozenV1 = Self(
        minimumIndependentPassingCountForCountLabel:
            3,
        allCriticalLegsRequiredForGrounded:
            true,
        requiredCriticalLegCount: 10,
        passingLabelFormat:
            "independentThreePlus(k)",
        abstainLabelFormat: "oracleDerived(k)",
        triadicSemantics:
            "count_derived_label_not_four_tier_independence_audit",
        distinctImplementationFamiliesEstablished:
            false,
        agentContractKitFourTierAuditPerformed:
            false
    )

    public init(
        minimumIndependentPassingCountForCountLabel:
            Int,
        allCriticalLegsRequiredForGrounded:
            Bool,
        requiredCriticalLegCount: Int,
        passingLabelFormat: String,
        abstainLabelFormat: String,
        triadicSemantics: String,
        distinctImplementationFamiliesEstablished:
            Bool,
        agentContractKitFourTierAuditPerformed:
            Bool
    ) {
        self.minimumIndependentPassingCountForCountLabel =
            minimumIndependentPassingCountForCountLabel
        self.allCriticalLegsRequiredForGrounded =
            allCriticalLegsRequiredForGrounded
        self.requiredCriticalLegCount =
            requiredCriticalLegCount
        self.passingLabelFormat =
            passingLabelFormat
        self.abstainLabelFormat =
            abstainLabelFormat
        self.triadicSemantics = triadicSemantics
        self.distinctImplementationFamiliesEstablished =
            distinctImplementationFamiliesEstablished
        self.agentContractKitFourTierAuditPerformed =
            agentContractKitFourTierAuditPerformed
    }

    public func validate() throws {
        guard self == .frozenV1,
              minimumIndependentPassingCountForCountLabel
                == 3,
              allCriticalLegsRequiredForGrounded,
              requiredCriticalLegCount == 10,
              !distinctImplementationFamiliesEstablished,
              !agentContractKitFourTierAuditPerformed
        else {
            throw PrimeNativeNeuralGateContractProjectionError
                .invalidVerdictContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case minimumIndependentPassingCountForCountLabel =
            "minimum_independent_passing_count_for_count_label"
        case allCriticalLegsRequiredForGrounded =
            "all_critical_legs_required_for_grounded"
        case requiredCriticalLegCount =
            "required_critical_leg_count"
        case passingLabelFormat =
            "passing_label_format"
        case abstainLabelFormat =
            "abstain_label_format"
        case triadicSemantics =
            "triadic_semantics"
        case distinctImplementationFamiliesEstablished =
            "distinct_implementation_families_established"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
    }
}

public struct PrimeNativeNeuralGateContractProjection:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let projectionID: String
    public let claimScope: String
    public let companionRepository: String
    public let companionRemoteURL: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let sourceBindings:
        [PrimeNativeNeuralGateSourceBinding]
    public let criticalLegs:
        [PrimeNativeNeuralGateCriticalLegContract]
    public let mutationCatalog:
        [PrimeNativeNeuralGateMutationContract]
    public let finiteField:
        PrimeNativeNeuralGateFiniteFieldContract
    public let statistics:
        PrimeNativeNeuralGateStatisticalContract
    public let capabilityThresholds:
        PrimeNativeNeuralGateCapabilityThresholdContract
    public let verdict:
        PrimeNativeNeuralGateVerdictContract
    public let historicalSyntheticSummaryClassification:
        String
    public let sourceBlobBytesResolvedAtExecution:
        Bool
    public let invariantRecordsObserved: Bool
    public let historicalSemanticMutationsExecuted:
        Bool
    public let historicalSZFingerprintRecomputed:
        Bool
    public let neuralKitExecuted: Bool
    public let modelExecutionPerformed: Bool
    public let phaseThreeCompatibilityComplete:
        Bool
    public let productUseAuthorized: Bool
    public let projectionRelativePath: String
    public let authorityStatement: String

    public static let frozenV1: Self = {
        let legIDs = [
            (
                "NL1_canonical_material_reload",
                "canonical material and provenance subcontracts"
            ),
            (
                "NL2_finite_field_sz_pool_expansion",
                "three-point finite-field polynomial and structural corruptions"
            ),
            (
                "NL3_foundation_tokenizer_corpus_regrade",
                "Foundation UTF-8 and embedded corpus-row regrade"
            ),
            (
                "NL4_raw_executor_row_regrade",
                "complete per-row autoregressive prediction and hash regrade"
            ),
            (
                "NL5_causal_training_mechanics",
                "shifted masked causal loss, finite gradients, and update evidence"
            ),
            (
                "NL6_checkpoint_durability",
                "checkpoint, configuration, and executable replay evidence"
            ),
            (
                "NL7_same_seed_initialization_training_result_replay",
                "same-seed initialization, step, parameter, and raw-result replay evidence"
            ),
            (
                "NL8_frozen_exact_seed_consensus",
                "exact frozen three-seed profile, corpus, and tokenizer consensus"
            ),
            (
                "NL9_capability_and_malformed_abstention",
                "frozen heldout thresholds and exact malformed abstention"
            ),
            (
                "NL10_mutation_synthesis",
                "all named semantic mutations detected, fingerprint-divergent, and restored"
            ),
        ]
        return Self(
            schemaVersion: 1,
            projectionID:
                "ergentics_prime_neuralkit_native_language_gate_contract_projection_v1",
            claimScope:
                "source_pinned_neuralkit_native_language_gate_contract_projection_only",
            companionRepository:
                "Ergentics/pmhnp-companion-ergentics",
            companionRemoteURL:
                "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
            companionRevision:
                "163fc100710ece48119bc25954452d10f6a84f7f",
            companionTreeOID:
                "9009daa4f8a07fbd5897e00b9571cef44ec292db",
            sourceBindings: [
                PrimeNativeNeuralGateSourceBinding(
                    role: .nativeLanguageGate,
                    repositoryRelativePath:
                        "neural-kit/Sources/NeuralKit/PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "795fff7c458ec68ba4562b6cd1c674fe8de7ffc4",
                    byteCount: 368_918,
                    sha256:
                        "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
                    semanticScope:
                        "NL1-NL10, native loss-statistics and fixed-prompt margin predicates, finite-field fingerprint, selected capability thresholds, and 46-mutation sweep"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .nativeByteTokenizerAuthority,
                    repositoryRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/PrimeNativeByteTokenizer.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "27f5d4f61864499027d3e65516ae4c5cfe1ff5d1",
                    byteCount: 21_320,
                    sha256:
                        "9cee58d44cf3c80bfe53b7568753c4ad4a76d6e54f2e32e6020b795ef0973721",
                    semanticScope:
                        "native byte-tokenizer compile authority"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .nativeTextCorpusAuthority,
                    repositoryRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsPrimeNativeTextCorpus.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "b2a087c9410a71f2bc99debade752ff779d7a8a8",
                    byteCount: 177_032,
                    sha256:
                        "4758ac2ffc8452614c7eee428333105ac63b0707cb890938d1e42966d3a14210",
                    semanticScope:
                        "native text-corpus compile authority"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .canaryReportAuthority,
                    repositoryRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "027a25b49dde1acfb4cd8af970e05ecd8241f427",
                    byteCount: 216_815,
                    sha256:
                        "8706343bf93c1dac70f5c263f7111667574da751cd27d6c3321a92fd822f063f",
                    semanticScope:
                        "report, split, raw-generation, and recommendation evidence schema"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .runConfigurationAuthority,
                    repositoryRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageRunConfiguration.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "d9141e1c08263f10f06b68acada836dc59a45dc9",
                    byteCount: 18_069,
                    sha256:
                        "1f770ed0a044597f6efd7ce1d74e14763cc5e64eeaa0e4036001a311d9e41c7b",
                    semanticScope:
                        "native-language run-configuration compile authority"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .artifactPathSafetyAuthority,
                    repositoryRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageArtifactPathSafety.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "f7404c905c58e8ff2d51f90ee90dad6cb61cbedc",
                    byteCount: 51_514,
                    sha256:
                        "cfeb5d3e3d3a39001f569239f5f9f4c1cb1c669342b366b12930793d36826f7c",
                    semanticScope:
                        "native-language artifact-path safety compile authority"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .profileTrialFailureAuthority,
                    repositoryRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageProfileTrialFailure.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "ed64476a8aea3010fe4e6a8b4f799eeb58e64d34",
                    byteCount: 16_567,
                    sha256:
                        "42d022ad2f9c423c9d1ff9e7fc52fc6576a51320a972c738d9d98fd84a956463",
                    semanticScope:
                        "native-language profile-trial failure compile authority"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .scaleRecommendationLineage,
                    repositoryRelativePath:
                        "prime-runtime/Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "c3f1e242d07ad3cc7b8e961edab868a895d567df",
                    byteCount: 190_002,
                    sha256:
                        "7cdc5ec341d7527c873b458c2ccb24ca27f9104709e9c37066d755bbb951a7ea",
                    semanticScope:
                        "profile and scale recommendation lineage; not a projected quality decision"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .verdictCarrier,
                    repositoryRelativePath:
                        "neural-kit/Sources/NeuralKit/PrimeNeuralVerifyAbstainGate.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "3866cc1fd1b39829c913376abece2454b0c11624",
                    byteCount: 4_659,
                    sha256:
                        "7f5ee1ee5579d13cec0ea4802994e6f07c4117c8202714f40fe1e3a0de21a42c",
                    semanticScope:
                        "Witness, Outcome, Verdict, and count-derived label carrier slice only; the broad generic source closure is not imported"
                ),
                PrimeNativeNeuralGateSourceBinding(
                    role: .behavioralRegressionFixture,
                    repositoryRelativePath:
                        "neural-kit/Tests/NeuralKitTests/EngineProposesNativeLanguageVerifyAbstainTests.swift",
                    mode: "100644",
                    objectType: "blob",
                    gitBlobOID:
                        "aa87aff21832ebd5c7a6598692139b81ae065e0b",
                    byteCount: 165_692,
                    sha256:
                        "266475d337fb49ba9c84e03a53871269a73812c3200a830a799ef90f4901968c",
                    semanticScope:
                        "historical synthetic fixture and regression vectors; not executed in Stage A"
                ),
            ],
            criticalLegs: legIDs.enumerated().map {
                PrimeNativeNeuralGateCriticalLegContract(
                    ordinal: $0.offset + 1,
                    legID: $0.element.0,
                    projectedMeaning: $0.element.1
                )
            },
            mutationCatalog:
                PrimeNativeNeuralGateMutation
                .allCases.enumerated().map {
                    PrimeNativeNeuralGateMutationContract(
                        ordinal: $0.offset + 1,
                        mutation: $0.element
                    )
                },
            finiteField: .frozenV1,
            statistics: .frozenV1,
            capabilityThresholds: .frozenV1,
            verdict: .frozenV1,
            historicalSyntheticSummaryClassification:
                "synthetic_first_party_contract_and_mutation_verification_only",
            sourceBlobBytesResolvedAtExecution:
                false,
            invariantRecordsObserved: false,
            historicalSemanticMutationsExecuted:
                false,
            historicalSZFingerprintRecomputed:
                false,
            neuralKitExecuted: false,
            modelExecutionPerformed: false,
            phaseThreeCompatibilityComplete:
                false,
            productUseAuthorized: false,
            projectionRelativePath:
                "neural-gate-contract/prime-native-neural-gate-contract-projection.v1.json",
            authorityStatement:
                "This Swift projection binds the selected eight-file native-gate pre-carrier compile closure plus the generic verdict-carrier and historical regression-fixture identities. It projects the ordered critical-leg identifiers and meanings, target-token-weighted loss-statistics and fixed-prompt runner-up-margin predicates, finite-field fingerprint mechanics, selected capability counts and thresholds, count-derived triadic label, all-critical admission rule, and complete 46-mutation catalog into a Prime-owned value contract. It does not resolve or execute donor source bytes, import the broad generic verdict source closure, reconstruct the unpublished 59,497 invariant records, execute the historical semantic mutations, recompute their SZ residues, perform AgentContractKit's four-tier audit, execute NeuralKit or a model, claim Phase-3 compatibility, or authorize product use."
        )
    }()

    public func validate() throws {
        let roles = sourceBindings.map(\.role)
        let legIDs = criticalLegs.map(\.legID)
        let mutationIDs =
            mutationCatalog.map(\.mutationID)
        guard self == .frozenV1,
              schemaVersion == 1,
              PrimeNativeContractMigrationPlan
                .isGitOID(companionRevision),
              PrimeNativeContractMigrationPlan
                .isGitOID(companionTreeOID),
              roles
                == PrimeNativeNeuralGateSourceRole
                .allCases,
              Set(roles).count == roles.count,
              criticalLegs.map(\.ordinal)
                == Array(1 ... 10),
              Set(legIDs).count == legIDs.count,
              verdict.requiredCriticalLegCount
                == criticalLegs.count,
              mutationCatalog.map(\.ordinal)
                == Array(1 ... 46),
              mutationIDs
                == PrimeNativeNeuralGateMutation
                .allCases.map(\.rawValue),
              Set(mutationIDs).count
                == mutationIDs.count,
              mutationCatalog.allSatisfy({
                  guard let mutation =
                          PrimeNativeNeuralGateMutation(
                              rawValue: $0.mutationID
                          )
                  else {
                      return false
                  }
                  return $0.expectedFailedLeg
                          == mutation.expectedFailedLeg
                      && $0.mutatesRawPredictions
                          == mutation
                          .mutatesRawPredictions
                      && legIDs.contains(
                          $0.expectedFailedLeg
                      )
              }),
              !sourceBlobBytesResolvedAtExecution,
              !invariantRecordsObserved,
              !historicalSemanticMutationsExecuted,
              !historicalSZFingerprintRecomputed,
              !neuralKitExecuted,
              !modelExecutionPerformed,
              !phaseThreeCompatibilityComplete,
              !productUseAuthorized,
              authorityStatement.contains(
                  "count-derived triadic label"
              ),
              authorityStatement.contains(
                  "does not resolve or execute donor source bytes"
              ),
              authorityStatement.contains(
                  "AgentContractKit's four-tier audit"
              )
        else {
            throw PrimeNativeNeuralGateContractProjectionError
                .invalidProjection(
                    "frozen contract"
                )
        }
        try sourceBindings.forEach {
            try $0.validate()
        }
        try finiteField.validate()
        try statistics.validate()
        try capabilityThresholds.validate()
        try verdict.validate()
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case projectionID = "projection_id"
        case claimScope = "claim_scope"
        case companionRepository =
            "companion_repository"
        case companionRemoteURL =
            "companion_remote_url"
        case companionRevision =
            "companion_revision"
        case companionTreeOID =
            "companion_tree_oid"
        case sourceBindings = "source_bindings"
        case criticalLegs = "critical_legs"
        case mutationCatalog =
            "mutation_catalog"
        case finiteField = "finite_field"
        case statistics
        case capabilityThresholds =
            "capability_thresholds"
        case verdict
        case historicalSyntheticSummaryClassification =
            "historical_synthetic_summary_classification"
        case sourceBlobBytesResolvedAtExecution =
            "source_blob_bytes_resolved_at_execution"
        case invariantRecordsObserved =
            "invariant_records_observed"
        case historicalSemanticMutationsExecuted =
            "historical_semantic_mutations_executed"
        case historicalSZFingerprintRecomputed =
            "historical_sz_fingerprint_recomputed"
        case neuralKitExecuted =
            "neural_kit_executed"
        case modelExecutionPerformed =
            "model_execution_performed"
        case phaseThreeCompatibilityComplete =
            "phase_three_compatibility_complete"
        case productUseAuthorized =
            "product_use_authorized"
        case projectionRelativePath =
            "projection_relative_path"
        case authorityStatement =
            "authority_statement"
    }
}
