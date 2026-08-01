import CryptoKit
import ErgenticsPrimeRuntime
import Foundation

private typealias NativeLanguagePathSafety =
    ErgenticsNativeLanguageArtifactPathSafety

/// Post-artifact admission gate for the first-party native language canary.
///
/// This gate intentionally has a stronger rule than the generic
/// `PrimeNeuralVerifyAbstainGate`: every critical leg must pass. Three passing
/// witnesses are necessary for a triadic verdict, but never sufficient to
/// admit a native-language checkpoint.
enum PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter {
    public static let quantizationScope =
        "out_of_scope_pending_accepted_native_language_checkpoint"
    public static let requiredEvaluationRows:
        [ErgenticsNativeLanguageCanary.Split: Int] = [
            .validation: 4_096,
            .combinationHoldout: 4_096,
            .outOfDistribution: 4_096,
            .mutation: 4_096,
            .abstention: 2_048,
        ]

    public static let criticalLegIDs = [
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

    public struct ObservedCheckpointBinding:
        Sendable, Equatable
    {
        public let fileName: String
        public let sha256: String
        public let byteCount: Int64

        public init(
            fileName: String,
            sha256: String,
            byteCount: Int64
        ) {
            self.fileName = fileName
            self.sha256 = sha256
            self.byteCount = byteCount
        }
    }

    public struct ObservedPackageResolvedBinding:
        Sendable, Equatable
    {
        public let fileName: String
        public let sha256: String
        public let byteCount: Int64
        public let mlxSwiftRevision: String
        public let mlxSwiftExamplesVersion: String

        public init(
            fileName: String,
            sha256: String,
            byteCount: Int64,
            mlxSwiftRevision: String,
            mlxSwiftExamplesVersion: String
        ) {
            self.fileName = fileName
            self.sha256 = sha256
            self.byteCount = byteCount
            self.mlxSwiftRevision = mlxSwiftRevision
            self.mlxSwiftExamplesVersion =
                mlxSwiftExamplesVersion
        }
    }

    /// Streamed observation of the exact Metal library placed beside a
    /// staged native-language executor. Metal libraries are build products,
    /// not JSON evidence, so the gate carries only their physical identity.
    public struct ObservedMetalLibraryBinding:
        Sendable, Equatable
    {
        public let primaryFileName: String
        public let fallbackFileName: String
        public let sha256: String
        public let byteCount: Int64

        public init(
            primaryFileName: String,
            fallbackFileName: String,
            sha256: String,
            byteCount: Int64
        ) {
            self.primaryFileName = primaryFileName
            self.fallbackFileName = fallbackFileName
            self.sha256 = sha256
            self.byteCount = byteCount
        }
    }

    public struct Materials: Sendable {
        public let reportData: [Data]
        public let tokenizerManifestData: Data?
        public let corpusManifestData: Data?
        /// The package lock can grow independently of the gate. Preserve a
        /// streamed physical observation rather than assuming it fits in
        /// memory or trusting only hashes repeated by generated artifacts.
        public let packageResolvedArtifactBinding:
            ObservedPackageResolvedBinding?
        /// Every run directory uses the same frozen probe basename, while
        /// probe bytes differ by seed. Key physical bytes by seed.
        public let probeTokenManifestDataBySeed:
            [Int: Data]
        public let evaluationShardDataBySeed:
            [Int: [String: Data]]
        public let executorArtifactDataByFileName:
            [String: Data]
        public let recommenderArtifactDataByFileName:
            [String: Data]
        /// Checkpoints may be multi-GB. Carry only the streamed physical
        /// observation; never materialize checkpoint bytes into `Data`.
        public let checkpointArtifactBindingBySeed:
            [Int: ObservedCheckpointBinding]
        /// The staged executable and its Metal library are private per seed.
        /// Keep their observations seed-keyed even when the bytes are
        /// identical so one run directory cannot shadow another.
        public let metalLibraryArtifactBindingBySeed:
            [Int: ObservedMetalLibraryBinding]
        public let trainingStageArtifactDataBySeed:
            [Int: Data]
        /// Every report directory uses the same immutable basename
        /// `run-configuration.txt`. Key the bytes by seed so one run cannot
        /// silently replace another run's differently bound configuration.
        public let configurationArtifactDataBySeed:
            [Int: Data]
        fileprivate let exactArtifactCacheKey: String

        public init(
            reportData: [Data],
            tokenizerManifestData: Data?,
            corpusManifestData: Data?,
            packageResolvedArtifactBinding:
                ObservedPackageResolvedBinding? = nil,
            probeTokenManifestDataBySeed: [Int: Data] = [:],
            evaluationShardDataBySeed:
                [Int: [String: Data]] = [:],
            executorArtifactDataByFileName:
                [String: Data] = [:],
            recommenderArtifactDataByFileName:
                [String: Data] = [:],
            checkpointArtifactBindingBySeed:
                [Int: ObservedCheckpointBinding] = [:],
            metalLibraryArtifactBindingBySeed:
                [Int: ObservedMetalLibraryBinding] = [:],
            trainingStageArtifactDataBySeed:
                [Int: Data] = [:],
            configurationArtifactDataBySeed:
                [Int: Data] = [:]
        ) {
            self.reportData = reportData
            self.tokenizerManifestData = tokenizerManifestData
            self.corpusManifestData = corpusManifestData
            self.packageResolvedArtifactBinding =
                packageResolvedArtifactBinding
            self.probeTokenManifestDataBySeed =
                probeTokenManifestDataBySeed
            self.evaluationShardDataBySeed =
                evaluationShardDataBySeed
            self.executorArtifactDataByFileName =
                executorArtifactDataByFileName
            self.recommenderArtifactDataByFileName =
                recommenderArtifactDataByFileName
            self.checkpointArtifactBindingBySeed =
                checkpointArtifactBindingBySeed
            self.metalLibraryArtifactBindingBySeed =
                metalLibraryArtifactBindingBySeed
            self.trainingStageArtifactDataBySeed =
                trainingStageArtifactDataBySeed
            self.configurationArtifactDataBySeed =
                configurationArtifactDataBySeed
            self.exactArtifactCacheKey =
                PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter
                .exactMaterialsCacheKey(
                    reportData: reportData,
                    tokenizerManifestData:
                        tokenizerManifestData,
                    corpusManifestData: corpusManifestData,
                    packageResolvedBinding:
                        packageResolvedArtifactBinding,
                    probeData:
                        probeTokenManifestDataBySeed,
                    shardData: evaluationShardDataBySeed,
                    executorData:
                        executorArtifactDataByFileName,
                    recommenderData:
                        recommenderArtifactDataByFileName,
                    checkpointBindings:
                        checkpointArtifactBindingBySeed,
                    metalLibraryBindings:
                        metalLibraryArtifactBindingBySeed,
                    trainingStageData:
                        trainingStageArtifactDataBySeed,
                    configurationData:
                        configurationArtifactDataBySeed
                )
        }

        public static let absent = Materials(
            reportData: [],
            tokenizerManifestData: nil,
            corpusManifestData: nil,
            packageResolvedArtifactBinding: nil,
            probeTokenManifestDataBySeed: [:],
            evaluationShardDataBySeed: [:],
            executorArtifactDataByFileName: [:],
            recommenderArtifactDataByFileName: [:],
            checkpointArtifactBindingBySeed: [:],
            metalLibraryArtifactBindingBySeed: [:],
            trainingStageArtifactDataBySeed: [:],
            configurationArtifactDataBySeed: [:]
        )
    }

    public struct ArtifactURLs: Sendable {
        public let reportURLs: [URL]
        public let tokenizerManifestURL: URL
        public let corpusManifestURL: URL
        public let packageResolvedURL: URL

        public init(
            reportURLs: [URL],
            tokenizerManifestURL: URL,
            corpusManifestURL: URL,
            packageResolvedURL: URL
        ) {
            self.reportURLs = reportURLs
            self.tokenizerManifestURL = tokenizerManifestURL
            self.corpusManifestURL = corpusManifestURL
            self.packageResolvedURL = packageResolvedURL
        }
    }

    public struct FiniteFieldFingerprint:
        Codable, Equatable, Sendable
    {
        public let prime: UInt64
        public let evaluationPoints: [UInt64]
        public let residues: [UInt64]
        public let recordCount: Int
    }

    public enum Mutation: String, Codable, CaseIterable, Sendable {
        case obsoleteSchema = "obsolete_schema"
        case lineage
        case quantHessianLineage = "quant_hessian_lineage"
        case profile
        case debugBuildConfiguration =
            "debug_build_configuration"
        case nonFloat32Precision =
            "non_float32_precision"
        case tokenizer
        case corpusSplitLeakage = "corpus_split_leakage"
        case corpusLabelLeakage = "corpus_label_leakage"
        case corpusOverCapTarget = "corpus_over_cap_target"
        case corpusPromptWindow = "corpus_prompt_window"
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
        case heldoutLossEvidence = "heldout_loss_evidence"
        case refusalReasonScheduleCount =
            "refusal_reason_schedule_count"
        case refusalReasonScheduleHash =
            "refusal_reason_schedule_hash"
        case optimizerProvenance = "optimizer_provenance"
        case executorWallNonFinite =
            "executor_wall_non_finite"
        case executorWallZero = "executor_wall_zero"
        case executorWallOverCap = "executor_wall_over_cap"
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
        case durabilityCheckpoint = "durability_checkpoint"
        case durabilityProvenanceMismatch =
            "durability_provenance_mismatch"
        case sameSeedReplay = "same_seed_replay"
        case seedConsensus = "seed_consensus"
        case malformedAbstention = "malformed_abstention"

        public var expectedFailedLeg: String {
            switch self {
            case .obsoleteSchema, .lineage,
                 .quantHessianLineage, .profile,
                 .debugBuildConfiguration,
                 .nonFloat32Precision:
                "NL1_canonical_material_reload"
            case .tokenizer, .corpusSplitLeakage,
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
                 .executorPrediction, .executorRowHash:
                "NL4_raw_executor_row_regrade"
            case .causalTraining, .heldoutLossEvidence,
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
            case .executorArtifactDigest,
                 .executorArtifactFileName,
                 .recommenderArtifactDigest,
                 .recommenderArtifactFileName,
                 .configurationArtifactDigest,
                 .configurationArtifactFileName,
                 .configurationWallCapMismatch,
                 .metalLibraryArtifactDigest,
                 .metalLibraryBundleShadowAudit:
                "NL1_canonical_material_reload"
            case .durabilityCheckpoint,
                 .durabilityProvenanceMismatch:
                "NL6_checkpoint_durability"
            case .sameSeedReplay:
                "NL7_same_seed_initialization_training_result_replay"
            case .seedConsensus:
                "NL8_frozen_exact_seed_consensus"
            case .malformedAbstention:
                "NL9_capability_and_malformed_abstention"
            case .trainedSupportAssistance:
                "NL9_capability_and_malformed_abstention"
            }
        }

        fileprivate var mutatesRawPredictions: Bool {
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

    public struct MutationResult: Codable, Equatable, Sendable {
        public let mutation: Mutation
        public let expectedFailedLeg: String
        public let detected: Bool
        public let fingerprintDiverged: Bool
        public let restored: Bool
        public let restoredFingerprintExact: Bool

        enum CodingKeys: String, CodingKey {
            case mutation
            case expectedFailedLeg = "expected_failed_leg"
            case detected
            case fingerprintDiverged = "fingerprint_diverged"
            case restored
            case restoredFingerprintExact =
                "restored_fingerprint_exact"
        }
    }

    public struct MutationSweep: Codable, Equatable, Sendable {
        public let outcome: String
        public let triadicVerdict: String
        public let results: [MutationResult]

        enum CodingKeys: String, CodingKey {
            case outcome
            case triadicVerdict = "triadic_verdict"
            case results
        }
    }

    public struct Assessment: Sendable, Equatable {
        public let verdict: PrimeNeuralVerifyAbstainGate.Verdict
        public let nextAction: String
        public let fingerprint: FiniteFieldFingerprint?
        public let mutationSweep: MutationSweep?
        /// Exact NL1 subcontracts. A failed entry identifies the material or
        /// provenance binding that rejected the staged artifact set.
        public let materialReloadComponentPasses: [String: Bool]
        /// Monotonic wall-clock phase measurements for guarding the
        /// exhaustive admission path against accidental quadratic work.
        public let phaseDurationsSeconds: [String: Double]

        public var outcome: String {
            verdict.grounded ? "GROUNDED" : "ABSTAIN"
        }

        public var triadicVerdict: String {
            verdict.triadicVerdict
        }
    }

    private struct Evaluation {
        let exactArtifactCacheKey: String
        let reports: [ErgenticsNativeLanguageCanary.Report]
        let tokenizer:
            PrimeNativeByteTokenizer.Manifest?
        let corpus:
            ErgenticsPrimeNativeTextCorpus.Manifest?
        let materialReload: Bool
        let sz: Bool
        let foundationCorpus: Bool
        let rawExecutor: Bool
        let causalMechanics: Bool
        let durability: Bool
        let sameSeedReplay: Bool
        let seedConsensus: Bool
        let capability: Bool
        let materialReloadComponentPasses: [String: Bool]
        let fingerprint: FiniteFieldFingerprint?
        let invariantRecords: [String]
        let invariantRecordIsASCII: [Bool]
        let baselineSZPlanSeconds: Double
        let baselineSZStructuralPoolSeconds: Double
    }

    private struct EvaluationRowHashPayload: Encodable {
        let rowID: String
        let split: String
        let semanticFamily: String
        let mutationID: String?
        let prompt: String
        let target: String

        enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case split
            case semanticFamily = "semantic_family"
            case mutationID = "mutation_id"
            case prompt
            case target
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(
                keyedBy: CodingKeys.self
            )
            try container.encode(rowID, forKey: .rowID)
            try container.encode(split, forKey: .split)
            try container.encode(
                semanticFamily,
                forKey: .semanticFamily
            )
            if let mutationID {
                try container.encode(
                    mutationID,
                    forKey: .mutationID
                )
            } else {
                try container.encodeNil(forKey: .mutationID)
            }
            try container.encode(prompt, forKey: .prompt)
            try container.encode(target, forKey: .target)
        }
    }

    private struct CorpusProjection: Equatable {
        let split: String
        let semanticFamily: String
        let prompt: String
        let mutationID: String?
        let target: String
    }

    private struct RefusalPoolProjection {
        let split: String
        let rowCount: Int
        let reasonCounts: [String: Int]
        let contractCounts: [String: Int]
        let promptSet: Set<String>
        let semanticSet: Set<String>
        let contractSet: Set<String>
        let promptSetSHA256: String
        let semanticSetSHA256: String
        let independentRegradeSHA256: String
        let materialsValid: Bool
    }

    private struct PredictionRegrade {
        let text: String?
        let utf8Valid: Bool
        let exact: Bool
        let semantic: Bool
        let abstention: Bool
    }

    private struct InvariantRecordCollection {
        let records: [String]
        let isASCII: [Bool]
    }

    private struct MaterialReloadEvaluation {
        let componentPasses: [String: Bool]

        var pass: Bool {
            !componentPasses.isEmpty
                && componentPasses.values.allSatisfy { $0 }
        }
    }

    private struct ProbeTokenManifest:
        Codable, Equatable, Sendable
    {
        let schemaVersion: String
        let tokenizerManifestSHA256: String
        let corpusManifestSHA256: String
        let corpusManifestArtifactSHA256: String
        let seed: Int
        let steps: Int
        let measurementWarmupSteps: Int
        let timedSteps: Int
        let batchSize: Int
        let gradientAccumulationSteps: Int
        let effectiveBatchSize: Int
        let sequenceLength: Int
        let presentationMode: String
        let probePurposeID: String
        let scheduleID: String
        let uniqueInputRows: Int
        let scheduledRowIDs: [String]
        let scheduledValidRowCount: Int
        let scheduledRefusalRowCount: Int
        let scheduledValidSemanticFamilyRows: [String: Int]
        let scheduledRefusalSemanticFamilyRows: [String: Int]
        let scheduledRefusalReasonRows: [String: Int]
        let scheduledRefusalReasonScheduleSHA256: String
        let heldoutRowIDs: [String]
        let heldoutValidRowCount: Int
        let heldoutRefusalRowCount: Int
        let heldoutValidSemanticFamilyRows: [String: Int]
        let heldoutRefusalSemanticFamilyRows: [String: Int]
        let heldoutRefusalReasonRows: [String: Int]
        let heldoutRefusalReasonScheduleSHA256: String
        let selectionValidationSplitIDs: [String]
        let heldoutScheduleSHA256: String
        let processedPaddedTokenPositions: Int
        let nonPaddingInputTokenPresentations: Int
        let lossContributingAnswerTokenPresentations: Int
        let inputIDs: [[Int]]
        let lossMasks: [[Int]]

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case tokenizerManifestSHA256 =
                "tokenizer_manifest_sha256"
            case corpusManifestSHA256 =
                "corpus_manifest_sha256"
            case corpusManifestArtifactSHA256 =
                "corpus_manifest_artifact_sha256"
            case seed
            case steps
            case measurementWarmupSteps =
                "measurement_warmup_steps"
            case timedSteps = "timed_steps"
            case batchSize = "batch_size"
            case gradientAccumulationSteps =
                "gradient_accumulation_steps"
            case effectiveBatchSize = "effective_batch_size"
            case sequenceLength = "sequence_length"
            case presentationMode = "presentation_mode"
            case probePurposeID = "probe_purpose_id"
            case scheduleID = "schedule_id"
            case uniqueInputRows = "unique_input_rows"
            case scheduledRowIDs = "scheduled_row_ids"
            case scheduledValidRowCount =
                "scheduled_valid_row_count"
            case scheduledRefusalRowCount =
                "scheduled_refusal_row_count"
            case scheduledValidSemanticFamilyRows =
                "scheduled_valid_semantic_family_rows"
            case scheduledRefusalSemanticFamilyRows =
                "scheduled_refusal_semantic_family_rows"
            case scheduledRefusalReasonRows =
                "scheduled_refusal_reason_rows"
            case scheduledRefusalReasonScheduleSHA256 =
                "scheduled_refusal_reason_schedule_sha256"
            case heldoutRowIDs = "heldout_row_ids"
            case heldoutValidRowCount =
                "heldout_valid_row_count"
            case heldoutRefusalRowCount =
                "heldout_refusal_row_count"
            case heldoutValidSemanticFamilyRows =
                "heldout_valid_semantic_family_rows"
            case heldoutRefusalSemanticFamilyRows =
                "heldout_refusal_semantic_family_rows"
            case heldoutRefusalReasonRows =
                "heldout_refusal_reason_rows"
            case heldoutRefusalReasonScheduleSHA256 =
                "heldout_refusal_reason_schedule_sha256"
            case selectionValidationSplitIDs =
                "selection_validation_split_ids"
            case heldoutScheduleSHA256 =
                "heldout_schedule_sha256"
            case processedPaddedTokenPositions =
                "processed_padded_token_positions"
            case nonPaddingInputTokenPresentations =
                "non_padding_input_token_presentations"
            case lossContributingAnswerTokenPresentations =
                "loss_contributing_answer_token_presentations"
            case inputIDs = "input_ids"
            case lossMasks = "loss_masks"
        }
    }

    private struct Generated: Codable, Equatable, Sendable {
        let text: String?
        let tokenIDs: [Int]
        let tokenLogProbabilities: [Double]
        let meanLogProbability: Double
        let terminatedByEOS: Bool
        let terminationReason: String
        let utf8Valid: Bool
        let eosLogProbability: Double?
        let rawFullVocabularyAllowedSupportGreedyTokenParity: Bool
        let disallowedFullVocabularyArgmaxCount: Int
        let maximumDisallowedTokenProbabilityMass: Double
        let latencySeconds: Double
    }

    private struct GenerationShardEntry:
        Codable, Equatable, Sendable
    {
        let rowID: String
        let generated: Generated

        enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case generated
        }
    }

    private struct GenerationShard:
        Codable, Equatable, Sendable
    {
        let schemaVersion: String
        let phase: String
        let profileID: String
        let seed: Int
        let corpusManifestSHA256: String
        let generationContractID: String
        let maximumGenerationTokenDecisions: Int
        let modelBindingSHA256: String
        let firstRowID: String
        let lastRowID: String
        let entries: [GenerationShardEntry]

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case phase
            case profileID = "profile_id"
            case seed
            case corpusManifestSHA256 =
                "corpus_manifest_sha256"
            case generationContractID =
                "generation_contract_id"
            case maximumGenerationTokenDecisions =
                "maximum_generation_token_decisions"
            case modelBindingSHA256 =
                "model_binding_sha256"
            case firstRowID = "first_row_id"
            case lastRowID = "last_row_id"
            case entries
        }
    }

    struct TrainingStageAudit: Codable, Equatable, Sendable {
        let schemaVersion: String
        let buildConfiguration: String
        let precision: String
        let profileID: String
        let seed: Int
        let corpusManifestSHA256: String
        let corpusManifestArtifactSHA256: String
        let corpusManifestFileName: String
        let tokenizerManifestSHA256: String
        let probeManifestSHA256: String
        let probePurposeID: String
        let scheduleID: String
        let heldoutScheduleSHA256: String
        let requestedSteps: Int
        let measurementWarmupSteps: Int
        let timedSteps: Int
        let batchSize: Int
        let gradientAccumulationSteps: Int
        let sequenceLength: Int
        let evaluationBatchSize: Int
        let evaluationShardSize: Int
        let learningRate: Float
        let weightDecay: Float
        let expectedParameterCount: Int64
        let observedParameterCount: Int64
        let observedTrainableParameterCount: Int64
        let checkpointSHA256: String
        let checkpointFileName: String
        let configurationSHA256: String
        let executableSHA256: String
        let packageResolvedSHA256: String
        let metalLibraryArtifactSHA256: String
        let metalLibraryArtifactByteCount: Int64
        let metalLibraryPrimaryFileName: String
        let metalLibraryFallbackFileName: String
        let metalLibraryBundleSearchAuditID: String
        let metalLibraryBundleSearchBaseCount: Int
        let metalLibraryVerifiedBundleMirrorCount: Int
        let metalLibraryDivergentBundleCandidateCount: Int
        let metalLibrarySourceMLXSwiftRevision: String
        let observedModelParameterDTypes: [String]
        let observedTrainableParameterDTypes: [String]
        let plannedTrainingTokenPresentations: Int
        let persistencePolicy:
            ErgenticsNativeLanguageCanary.TrainingPersistencePolicy
        let executorWallAccountingID: String
        let declaredMaximumExecutorWallSeconds: Double
        let cumulativeExecutorWallSecondsAtCheckpoint: Double

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case buildConfiguration = "build_configuration"
            case precision
            case profileID = "profile_id"
            case seed
            case corpusManifestSHA256 =
                "corpus_manifest_sha256"
            case corpusManifestArtifactSHA256 =
                "corpus_manifest_artifact_sha256"
            case corpusManifestFileName =
                "corpus_manifest_file_name"
            case tokenizerManifestSHA256 =
                "tokenizer_manifest_sha256"
            case probeManifestSHA256 =
                "probe_manifest_sha256"
            case probePurposeID = "probe_purpose_id"
            case scheduleID = "schedule_id"
            case heldoutScheduleSHA256 =
                "heldout_schedule_sha256"
            case requestedSteps = "requested_steps"
            case measurementWarmupSteps =
                "measurement_warmup_steps"
            case timedSteps = "timed_steps"
            case batchSize = "batch_size"
            case gradientAccumulationSteps =
                "gradient_accumulation_steps"
            case sequenceLength = "sequence_length"
            case evaluationBatchSize =
                "evaluation_batch_size"
            case evaluationShardSize =
                "evaluation_shard_size"
            case learningRate = "learning_rate"
            case weightDecay = "weight_decay"
            case expectedParameterCount =
                "expected_parameter_count"
            case observedParameterCount =
                "observed_parameter_count"
            case observedTrainableParameterCount =
                "observed_trainable_parameter_count"
            case checkpointSHA256 = "checkpoint_sha256"
            case checkpointFileName = "checkpoint_file_name"
            case configurationSHA256 =
                "configuration_sha256"
            case executableSHA256 = "executable_sha256"
            case packageResolvedSHA256 =
                "package_resolved_sha256"
            case metalLibraryArtifactSHA256 =
                "metal_library_artifact_sha256"
            case metalLibraryArtifactByteCount =
                "metal_library_artifact_byte_count"
            case metalLibraryPrimaryFileName =
                "metal_library_primary_file_name"
            case metalLibraryFallbackFileName =
                "metal_library_fallback_file_name"
            case metalLibraryBundleSearchAuditID =
                "metal_library_bundle_search_audit_id"
            case metalLibraryBundleSearchBaseCount =
                "metal_library_bundle_search_base_count"
            case metalLibraryVerifiedBundleMirrorCount =
                "metal_library_verified_bundle_mirror_count"
            case metalLibraryDivergentBundleCandidateCount =
                "metal_library_divergent_bundle_candidate_count"
            case metalLibrarySourceMLXSwiftRevision =
                "metal_library_source_mlx_swift_revision"
            case observedModelParameterDTypes =
                "observed_model_parameter_dtypes"
            case observedTrainableParameterDTypes =
                "observed_trainable_parameter_dtypes"
            case plannedTrainingTokenPresentations =
                "planned_training_token_presentations"
            case persistencePolicy = "persistence_policy"
            case executorWallAccountingID =
                "executor_wall_accounting_id"
            case declaredMaximumExecutorWallSeconds =
                "declared_maximum_executor_wall_seconds"
            case cumulativeExecutorWallSecondsAtCheckpoint =
                "cumulative_executor_wall_seconds_at_checkpoint"
        }
    }

    private struct FieldAffine {
        let multiplier: UInt64
        let addend: UInt64

        static let identity = FieldAffine(
            multiplier: 1,
            addend: 0
        )
    }

    private struct PackageResolvedAudit: Decodable {
        struct Pin: Decodable {
            struct State: Decodable {
                let revision: String
                let version: String?
            }

            let identity: String
            let state: State
        }

        let pins: [Pin]
    }

    /// Swift `String` equality intentionally folds canonically equivalent
    /// Unicode scalar sequences. The SZ polynomial does not: it hashes the
    /// exact UTF-8 bytes. Use this key for every delta/multiset operation.
    private struct RawUTF8RecordKey: Hashable {
        let bytes: Data

        init(_ record: String) {
            bytes = Data(record.utf8)
        }

        var record: String {
            String(decoding: bytes, as: UTF8.self)
        }
    }

    private struct FiniteFieldBaselinePlan {
        let cacheKey: String
        let originalRecords: [String]
        let originalRecordIsASCII: [Bool]
        let sortedRecords: [String]
        let leafCount: Int
        let trees: [[FieldAffine]]
        let fingerprint: FiniteFieldFingerprint
    }

    private enum FingerprintSegment {
        case baselineRange(Range<Int>)
        case replacement(String)
    }

    private struct MutationSweepRun {
        let sweep: MutationSweep?
        let phaseDurationsSeconds: [String: Double]
    }

    private static let fieldPrime: UInt64 = 2_147_483_647
    private static let fieldPoints: [UInt64] = [
        257, 65_537, 1_000_003,
    ]
    private static let baselineSZCacheLock = NSLock()
    private nonisolated(unsafe) static var baselineSZCache:
        FiniteFieldBaselinePlan?
    private static let authorityCorpusManifestSHA256 =
        ErgenticsPrimeNativeTextCorpus.manifest().manifestSHA256
    private static let authoritativeRowsByID:
        [String: ErgenticsPrimeNativeTextCorpus.Row] = {
            let splits:
                [ErgenticsPrimeNativeTextCorpus.Split] = [
                    .validation,
                    .combinationHoldout,
                    .ood,
                    .mutation,
                    .abstention,
                ]
            return Dictionary(
                uniqueKeysWithValues: splits.flatMap {
                    ErgenticsPrimeNativeTextCorpus.rows(for: $0)
                }.map { ($0.rowID, $0) }
            )
        }()
    private static let authoritativeTrainingRows =
        ErgenticsPrimeNativeTextCorpus.rows(for: .train)
        .sorted { $0.rowID < $1.rowID }
    private static let authoritativeRefusalTrainingRows =
        ErgenticsPrimeNativeTextCorpus.rows(for: .refusalTrain)
        .sorted { $0.rowID < $1.rowID }
    private static let authoritativeSelectionRowsByID:
        [String: ErgenticsPrimeNativeTextCorpus.Row] = {
            let rows =
                ErgenticsPrimeNativeTextCorpus.rows(for: .validation)
                + ErgenticsPrimeNativeTextCorpus.rows(
                    for: .refusalValidation
                )
            return Dictionary(
                uniqueKeysWithValues:
                    rows.map { ($0.rowID, $0) }
            )
        }()
    private static let trainingRowIDs: Set<String> = Set(
        (
            authoritativeTrainingRows
                + authoritativeRefusalTrainingRows
        ).map(\.rowID)
    )
    private static let independentRefusalPoolBySplit:
        [String: RefusalPoolProjection] = {
            let splits: [
                ErgenticsPrimeNativeTextCorpus.Split
            ] = [
                .refusalTrain,
                .refusalValidation,
                .abstention,
            ]
            return Dictionary(
                uniqueKeysWithValues: splits.map { split in
                    let rows =
                        ErgenticsPrimeNativeTextCorpus.rows(
                            for: split
                        )
                    let regrades = rows.map {
                        ErgenticsPrimeNativeTextCorpus.verify(
                            row: $0
                        )
                    }
                    let reasons = rows.compactMap(
                        \.abstentionReason
                    )
                    let reasonCounts = Dictionary(
                        grouping: reasons,
                        by: { $0 }
                    ).mapValues(\.count)
                    let contractIDs = rows.map { row in
                        [
                            row.abstentionReason ?? "missing_reason",
                            row.mutationID ?? "missing_mutation",
                            row.surfaceFormID,
                        ].joined(separator: "|")
                    }
                    let contractCounts = Dictionary(
                        grouping: contractIDs,
                        by: { $0 }
                    ).mapValues(\.count)
                    let prompts = Set(rows.map(\.promptSHA256))
                    let semantics = Set(
                        rows.map(\.semanticSHA256)
                    )
                    let projection = RefusalPoolProjection(
                        split: split.rawValue,
                        rowCount: rows.count,
                        reasonCounts: reasonCounts,
                        contractCounts: contractCounts,
                        promptSet: prompts,
                        semanticSet: semantics,
                        contractSet: Set(contractIDs),
                        promptSetSHA256:
                            ErgenticsPrimeNativeTextCorpus
                            .canonicalSHA256(prompts.sorted()),
                        semanticSetSHA256:
                            ErgenticsPrimeNativeTextCorpus
                            .canonicalSHA256(semantics.sorted()),
                        independentRegradeSHA256:
                            ErgenticsPrimeNativeTextCorpus
                            .canonicalSHA256(
                                regrades.map(\.verifierSHA256)
                            ),
                        materialsValid:
                            Set(rows.map(\.rowID)).count
                                == rows.count
                                && reasons.count == rows.count
                                && rows.allSatisfy {
                                    $0.split == split.rawValue
                                        && $0.expectedCompletion
                                            == "ABSTAIN\n"
                                        && $0.mutationID != nil
                                        && !$0.surfaceFormID.isEmpty
                                }
                                && regrades.allSatisfy(
                                    \.accepted
                                )
                    )
                    return (split.rawValue, projection)
                }
            )
        }()
    private static let independentPromptGroupingKeyID =
        "prompt_byte_token_count_excluding_bos_v1"
    private static let independentGenerationDecisionBudget = 64
    static let checkpointArtifactFileName =
        "checkpoint.safetensors"
    static let trainingStageArtifactFileName =
        "training-stage.json"
    static let evaluationShardDirectoryName =
        "evaluation-shards"
    static let packageResolvedArtifactFileName =
        "Package.resolved"
    /// MLX first searches for a colocated `mlx.metallib`, then ultimately
    /// falls back to `default.metallib` in the process working directory.
    /// The private executor run stages byte-identical copies of both.
    static let metalLibraryPrimaryFileName =
        "mlx.metallib"
    static let metalLibraryFallbackFileName =
        "default.metallib"
    private static let rejectedMetalLibraryResourceDirectoryName =
        "Resources"
    private static let rejectedSwiftPMMetalLibraryBundleName =
        "mlx-swift_Cmlx.bundle"
    private static let independentAllowedCompletionTokenSetSHA256 =
        sha256(
            Data(
                (
                    [PrimeNativeByteTokenizer.endOfSequenceTokenID]
                        + Array(
                            PrimeNativeByteTokenizer.byteTokenRange
                        )
                )
                .map(String.init)
                .joined(separator: "\n")
                .utf8
            )
        )

    public static func load(_ urls: ArtifactURLs) -> Assessment {
        let reportPairs = urls.reportURLs.compactMap {
            url -> (URL, Data)? in
            guard let data = loadRegularNonSymlinkData(url) else {
                return nil
            }
            return (url, data)
        }
        var probesBySeed = [Int: Data]()
        var shardsBySeed = [Int: [String: Data]]()
        var executorArtifacts = [String: Data]()
        var recommenderArtifacts = [String: Data]()
        var checkpointBindingsBySeed =
            [Int: ObservedCheckpointBinding]()
        var metalLibraryBindingsBySeed =
            [Int: ObservedMetalLibraryBinding]()
        var trainingStageArtifactsBySeed = [Int: Data]()
        var configurationArtifactsBySeed = [Int: Data]()
        let declaredPackageResolvedSHA256s = Set(
            reportPairs.compactMap { _, data in
                try? JSONDecoder().decode(
                    ErgenticsNativeLanguageCanary.Report.self,
                    from: data
                ).implementation.packageResolvedSHA256
            }
        )
        let packageResolvedBinding =
            declaredPackageResolvedSHA256s.count == 1
            ? observePackageResolvedArtifact(
                urls.packageResolvedURL,
                expectedSHA256:
                    declaredPackageResolvedSHA256s.first!
            )
            : nil
        for (url, data) in reportPairs {
            guard let report = try? JSONDecoder().decode(
                ErgenticsNativeLanguageCanary.Report.self,
                from: data
            ) else { continue }
            let name = report.corpus.probeTokenManifestFileName
            guard name == "probe-token-manifest.json",
                  let probe = loadRegularNonSymlinkData(
                      url.deletingLastPathComponent()
                          .appendingPathComponent(name),
                      expectedSHA256:
                        report.corpus
                            .probeTokenManifestArtifactSHA256
                  )
            else { continue }
            probesBySeed[report.seed] = probe
            let executorName =
                report.implementation.executorArtifactFileName
            let executorURL =
                url.deletingLastPathComponent()
                .appendingPathComponent(executorName)
            if executorName == "PrimeNativeLanguageSwiftCanary",
               let artifact = loadRegularNonSymlinkData(
                   executorURL,
                   expectedSHA256:
                    report.implementation.executorArtifactSHA256
               )
            {
                executorArtifacts[executorName] = artifact
            }
            let recommenderName =
                report.implementation.recommenderArtifactFileName
            let recommenderURL =
                url.deletingLastPathComponent()
                .appendingPathComponent(recommenderName)
            if recommenderName
                    == "PrimeNativeLanguageCanaryRecommend",
               let artifact = loadRegularNonSymlinkData(
                   recommenderURL,
                   expectedSHA256:
                    report.implementation
                        .recommenderArtifactSHA256
               )
            {
                recommenderArtifacts[recommenderName] = artifact
            }
            let configurationName =
                report.training.configurationArtifactFileName
            let configurationURL =
                url.deletingLastPathComponent()
                .appendingPathComponent(configurationName)
            if configurationName == "run-configuration.txt",
               let artifact = loadRegularNonSymlinkData(
                   configurationURL,
                   expectedSHA256:
                    report.training.configurationArtifactSHA256
               )
            {
                configurationArtifactsBySeed[report.seed] =
                    artifact
            }
            if let metalLibrary =
                observeMetalLibraryArtifact(
                    reportURL: url,
                    primaryFileName:
                        report.implementation
                            .metalLibraryPrimaryFileName,
                    fallbackFileName:
                        report.implementation
                            .metalLibraryFallbackFileName,
                    expectedSHA256:
                        report.implementation
                            .metalLibraryArtifactSHA256,
                    expectedByteCount:
                        report.implementation
                            .metalLibraryArtifactByteCount
                )
            {
                metalLibraryBindingsBySeed[report.seed] =
                    metalLibrary
            }
            if let durability = report.durability {
                if let checkpoint =
                    observeCheckpointArtifact(
                        reportURL: url,
                        fileName: durability.checkpointFileName,
                        expectedSHA256:
                            durability.checkpointSHA256
                    )
                {
                    checkpointBindingsBySeed[report.seed] =
                        checkpoint
                }
                if durability.trainingStageFileName
                        == trainingStageArtifactFileName,
                   let stage = loadRegularNonSymlinkData(
                       url.deletingLastPathComponent()
                        .appendingPathComponent(
                            durability.trainingStageFileName
                        ),
                       expectedSHA256:
                        durability.trainingStageSHA256
                   )
                {
                    trainingStageArtifactsBySeed[report.seed] =
                        stage
                }
            }
            var shards = [String: Data]()
            if let evaluationDirectoryName =
                report.durability?.evaluationDirectoryName,
               evaluationShardDirectoryContainsExactly(
                   reportURL: url,
                   evaluationDirectoryName:
                    evaluationDirectoryName,
                   bindings: report.evaluationShards
               )
            {
                for binding in report.evaluationShards {
                    guard let shard =
                        loadEvaluationShardArtifact(
                            reportURL: url,
                            evaluationDirectoryName:
                                evaluationDirectoryName,
                            binding: binding
                        )
                    else { continue }
                    shards[binding.fileName] = shard
                }
            }
            shardsBySeed[report.seed] = shards
        }
        return dispose(
            Materials(
                reportData: reportPairs.map(\.1),
                tokenizerManifestData:
                    loadRegularNonSymlinkData(
                        urls.tokenizerManifestURL
                    ),
                corpusManifestData:
                    loadRegularNonSymlinkData(
                        urls.corpusManifestURL
                    ),
                packageResolvedArtifactBinding:
                    packageResolvedBinding,
                probeTokenManifestDataBySeed: probesBySeed,
                evaluationShardDataBySeed: shardsBySeed,
                executorArtifactDataByFileName:
                    executorArtifacts,
                recommenderArtifactDataByFileName:
                    recommenderArtifacts,
                checkpointArtifactBindingBySeed:
                    checkpointBindingsBySeed,
                metalLibraryArtifactBindingBySeed:
                    metalLibraryBindingsBySeed,
                trainingStageArtifactDataBySeed:
                    trainingStageArtifactsBySeed,
                configurationArtifactDataBySeed:
                    configurationArtifactsBySeed
            )
        )
    }

    static func loadRegularNonSymlinkData(
        _ url: URL,
        expectedSHA256: String? = nil
    ) -> Data? {
        guard (
                  try? NativeLanguagePathSafety
                    .requireRegularNonSymlink(
                        url,
                        label: "native language artifact"
                    )
              ) != nil,
              let data = try? Data(contentsOf: url),
              !data.isEmpty,
              expectedSHA256 == nil
                || (
                    expectedSHA256.map(isSHA256) == true
                        && sha256(data) == expectedSHA256
                )
        else {
            return nil
        }
        return data
    }

    static func observeCheckpointArtifact(
        reportURL: URL,
        fileName: String,
        expectedSHA256: String
    ) -> ObservedCheckpointBinding? {
        guard fileName == checkpointArtifactFileName,
              isSHA256(expectedSHA256)
        else {
            return nil
        }
        let url = reportURL.deletingLastPathComponent()
            .appendingPathComponent(fileName)
        guard (
                  try? NativeLanguagePathSafety
                    .requireRegularNonSymlink(
                        url,
                        label: "native language checkpoint"
                    )
              ) != nil,
              let attributes =
                try? FileManager.default.attributesOfItem(
                    atPath: url.path
                ),
              let fileSizeNumber =
                attributes[.size] as? NSNumber,
              fileSizeNumber.int64Value > 0,
              let streamedSHA = try? sha256File(url),
              streamedSHA == expectedSHA256
        else {
            return nil
        }
        return ObservedCheckpointBinding(
            fileName: fileName,
            sha256: streamedSHA,
            byteCount: fileSizeNumber.int64Value
        )
    }

    static func observePackageResolvedArtifact(
        _ url: URL,
        expectedSHA256: String
    ) -> ObservedPackageResolvedBinding? {
        guard url.isFileURL,
              url.lastPathComponent
                == packageResolvedArtifactFileName,
              !url.pathComponents.contains("."),
              !url.pathComponents.contains(".."),
              isSHA256(expectedSHA256),
              (
                  try? NativeLanguagePathSafety
                    .requireRegularNonSymlink(
                        url,
                        label: "native language package lock"
                    )
              ) != nil,
              let attributes =
                try? FileManager.default.attributesOfItem(
                    atPath: url.path
                ),
              let fileSizeNumber =
                attributes[.size] as? NSNumber,
              fileSizeNumber.int64Value > 0,
              let streamedSHA = try? sha256File(url),
              streamedSHA == expectedSHA256,
              let packageData = try? Data(
                  contentsOf: url,
                  options: .mappedIfSafe
              ),
              Int64(packageData.count)
                == fileSizeNumber.int64Value,
              let mlxBinding =
                packageResolvedMLXBinding(packageData)
        else {
            return nil
        }
        return ObservedPackageResolvedBinding(
            fileName: packageResolvedArtifactFileName,
            sha256: streamedSHA,
            byteCount: fileSizeNumber.int64Value,
            mlxSwiftRevision: mlxBinding.revision,
            mlxSwiftExamplesVersion:
                mlxBinding.examplesVersion
        )
    }

    /// Observes the two byte-identical Metal libraries in the private run
    /// directory. MLX's second colocated lookup and its run-directory SwiftPM
    /// bundle lookup must be absent so neither can shadow these bound bytes.
    /// The executor separately audits every `Bundle.allBundles` resource URL
    /// before the first MLX operation; that semantic evidence is regraded
    /// from the report and training stage.
    static func observeMetalLibraryArtifact(
        reportURL: URL,
        primaryFileName: String,
        fallbackFileName: String,
        expectedSHA256: String,
        expectedByteCount: Int64
    ) -> ObservedMetalLibraryBinding? {
        guard reportURL.isFileURL,
              primaryFileName == metalLibraryPrimaryFileName,
              fallbackFileName == metalLibraryFallbackFileName,
              isSHA256(expectedSHA256),
              expectedByteCount > 0
        else {
            return nil
        }
        let runDirectory =
            reportURL.deletingLastPathComponent()
        let primaryURL = runDirectory
            .appendingPathComponent(
                metalLibraryPrimaryFileName,
                isDirectory: false
            )
        let fallbackURL = runDirectory
            .appendingPathComponent(
                metalLibraryFallbackFileName,
                isDirectory: false
            )
        let resourcesShadowURL = runDirectory
            .appendingPathComponent(
                rejectedMetalLibraryResourceDirectoryName,
                isDirectory: true
            )
            .appendingPathComponent(
                metalLibraryPrimaryFileName,
                isDirectory: false
            )
        let swiftPMBundleShadowURL = runDirectory
            .appendingPathComponent(
                rejectedSwiftPMMetalLibraryBundleName,
                isDirectory: true
            )
            .appendingPathComponent(
                metalLibraryFallbackFileName,
                isDirectory: false
            )
        guard (
                  try? NativeLanguagePathSafety
                    .requireRegularNonSymlink(
                        primaryURL,
                        label:
                            "native language primary Metal library"
                    )
              ) != nil,
              (
                  try? NativeLanguagePathSafety
                    .requireRegularNonSymlink(
                        fallbackURL,
                        label:
                            "native language fallback Metal library"
                    )
              ) != nil,
              (
                  try? NativeLanguagePathSafety
                    .requireAbsent(
                        resourcesShadowURL,
                        label:
                            "native language Resources Metal shadow"
                    )
              ) != nil,
              (
                  try? NativeLanguagePathSafety
                    .requireAbsent(
                        swiftPMBundleShadowURL,
                        label:
                            "native language SwiftPM Metal shadow"
                    )
              ) != nil,
              let primaryAttributes =
                try? FileManager.default.attributesOfItem(
                    atPath: primaryURL.path
                ),
              let fallbackAttributes =
                try? FileManager.default.attributesOfItem(
                    atPath: fallbackURL.path
                ),
              let primarySizeNumber =
                primaryAttributes[.size] as? NSNumber,
              let fallbackSizeNumber =
                fallbackAttributes[.size] as? NSNumber,
              primarySizeNumber.int64Value
                == expectedByteCount,
              fallbackSizeNumber.int64Value
                == expectedByteCount,
              let primarySHA = try? sha256File(primaryURL),
              let fallbackSHA = try? sha256File(fallbackURL),
              primarySHA == expectedSHA256,
              fallbackSHA == expectedSHA256
        else {
            return nil
        }
        return ObservedMetalLibraryBinding(
            primaryFileName: metalLibraryPrimaryFileName,
            fallbackFileName: metalLibraryFallbackFileName,
            sha256: primarySHA,
            byteCount: primarySizeNumber.int64Value
        )
    }

    /// Physical layout contract shared by the production URL loader and fast
    /// filesystem regressions. Shards are never report siblings; they live in
    /// the frozen non-symlink `evaluation-shards` directory.
    static func loadEvaluationShardArtifact(
        reportURL: URL,
        evaluationDirectoryName: String,
        binding: ErgenticsNativeLanguageCanary.EvaluationShardBinding
    ) -> Data? {
        guard evaluationDirectoryName
                == evaluationShardDirectoryName,
              shardBasenameValid(
                  binding.fileName,
                  phase: binding.phase
              )
        else {
            return nil
        }
        let directoryURL =
            reportURL.deletingLastPathComponent()
            .appendingPathComponent(
                evaluationDirectoryName,
                isDirectory: true
            )
        guard (
                  try? NativeLanguagePathSafety
                    .requireDirectoryNonSymlink(
                        directoryURL,
                        label:
                            "native language evaluation shard directory"
                    )
              ) != nil
        else {
            return nil
        }
        let shardURL = directoryURL.appendingPathComponent(
            binding.fileName,
            isDirectory: false
        )
        return loadRegularNonSymlinkData(
            shardURL,
            expectedSHA256: binding.artifactSHA256
        )
    }

    static func evaluationShardDirectoryContainsExactly(
        reportURL: URL,
        evaluationDirectoryName: String,
        bindings: [
            ErgenticsNativeLanguageCanary.EvaluationShardBinding
        ]
    ) -> Bool {
        guard evaluationDirectoryName
                == evaluationShardDirectoryName,
              !bindings.isEmpty,
              bindings.allSatisfy({
                  shardBasenameValid(
                      $0.fileName,
                      phase: $0.phase
                  )
              })
        else {
            return false
        }
        let directoryURL =
            reportURL.deletingLastPathComponent()
            .appendingPathComponent(
                evaluationDirectoryName,
                isDirectory: true
            )
        guard (
                  try? NativeLanguagePathSafety
                    .requireDirectoryNonSymlink(
                        directoryURL,
                        label:
                            "native language evaluation shard directory"
                    )
              ) != nil,
              let names =
                try? FileManager.default.contentsOfDirectory(
                    atPath: directoryURL.path
                )
        else {
            return false
        }
        guard Set(names) == Set(bindings.map(\.fileName))
        else {
            return false
        }
        return bindings.allSatisfy { binding in
            let shardURL = directoryURL.appendingPathComponent(
                binding.fileName,
                isDirectory: false
            )
            return (
                try? NativeLanguagePathSafety
                    .requireRegularNonSymlink(
                        shardURL,
                        label:
                            "native language evaluation shard"
                    )
            ) != nil
        }
    }

    private static func safeBasename(_ name: String) -> Bool {
        !name.isEmpty
            && name != "."
            && name != ".."
            && !name.contains("\\")
            && URL(fileURLWithPath: name).lastPathComponent
                == name
    }

    private static func shardBasenameValid(
        _ name: String,
        phase: String
    ) -> Bool {
        guard ["zero_shot", "trained", "reloaded"]
                .contains(phase),
              safeBasename(name)
        else {
            return false
        }
        return name.range(
            of: "^\(phase)-shard-[0-9]{5}\\.json$",
            options: .regularExpression
        ) != nil
    }

    /// Narrow test seam for physical staged-artifact mutations. The
    /// exhaustive named sweep mutates report values; this additionally proves
    /// that missing or byte-tampered executables cannot satisfy NL1.
    static func provenanceArtifactsValidForTesting(
        _ materials: Materials
    ) -> Bool {
        let reports = materials.reportData.compactMap {
            try? JSONDecoder().decode(
                ErgenticsNativeLanguageCanary.Report.self,
                from: $0
            )
        }
        return provenanceArtifactsValid(
            reports: reports,
            tokenizerManifestData:
                materials.tokenizerManifestData,
            corpusManifestData:
                materials.corpusManifestData,
            packageResolvedBinding:
                materials.packageResolvedArtifactBinding,
            executorDataByFileName:
                materials.executorArtifactDataByFileName,
            recommenderDataByFileName:
                materials.recommenderArtifactDataByFileName,
            configurationDataBySeed:
                materials.configurationArtifactDataBySeed,
            metalLibraryBindingsBySeed:
                materials.metalLibraryArtifactBindingBySeed
        )
    }

    static func durablePhysicalArtifactsValidForTesting(
        _ materials: Materials
    ) -> Bool {
        let reports = materials.reportData.compactMap {
            try? JSONDecoder().decode(
                ErgenticsNativeLanguageCanary.Report.self,
                from: $0
            )
        }
        return durablePhysicalArtifactsValid(
            reports: reports,
            packageResolvedBinding:
                materials.packageResolvedArtifactBinding,
            checkpointBindingsBySeed:
                materials.checkpointArtifactBindingBySeed,
            metalLibraryBindingsBySeed:
                materials.metalLibraryArtifactBindingBySeed,
            trainingStageDataBySeed:
                materials.trainingStageArtifactDataBySeed
        )
    }

    /// Fast seam for the physical half of NL6. Semantic stage-to-report
    /// equality remains inside `durablePhysicalArtifactsValid`; this isolates
    /// missing, byte-tampered, renamed, and replaced staged files without
    /// constructing the exhaustive >55k-record fixture.
    static func durablePhysicalEnvelopeValidForTesting(
        checkpoint: ObservedCheckpointBinding?,
        trainingStageData: Data?,
        checkpointFileName: String,
        checkpointSHA256: String,
        trainingStageFileName: String,
        trainingStageSHA256: String,
        evaluationDirectoryName: String
    ) -> Bool {
        durablePhysicalEnvelopeValid(
            checkpoint: checkpoint,
            trainingStageData: trainingStageData,
            checkpointFileName: checkpointFileName,
            checkpointSHA256: checkpointSHA256,
            trainingStageFileName: trainingStageFileName,
            trainingStageSHA256: trainingStageSHA256,
            evaluationDirectoryName: evaluationDirectoryName
        )
    }

    static func exactMaterialsCacheKeyForTesting(
        _ materials: Materials
    ) -> String {
        materials.exactArtifactCacheKey
    }

    static func freshExecutorWallEvidenceValidForTesting(
        mode: ErgenticsNativeLanguageCanary.Mode,
        accountingID: String,
        resumedFromTrainingStage: Bool,
        priorExecutorWallSeconds: Double,
        checkpointStageExecutorWallSeconds: Double,
        measuredTotalExecutorWallSeconds: Double,
        declaredMaximumExecutorWallSeconds: Double,
        preexistingEvaluationArtifactNames: [String]
    ) -> Bool {
        freshExecutorWallEvidenceValid(
            mode: mode,
            accountingID: accountingID,
            resumedFromTrainingStage:
                resumedFromTrainingStage,
            priorExecutorWallSeconds:
                priorExecutorWallSeconds,
            checkpointStageExecutorWallSeconds:
                checkpointStageExecutorWallSeconds,
            measuredTotalExecutorWallSeconds:
                measuredTotalExecutorWallSeconds,
            declaredMaximumExecutorWallSeconds:
                declaredMaximumExecutorWallSeconds,
            preexistingEvaluationArtifactNames:
                preexistingEvaluationArtifactNames
        )
    }

    static func trainingRowCountsValidForTesting(
        total: Int,
        valid: Int,
        refusal: Int
    ) -> Bool {
        trainingRowCountsValid(
            total: total,
            valid: valid,
            refusal: refusal
        )
    }

    static func trainingLossTraceValidForTesting(
        _ losses: [Double],
        completedSteps: Int
    ) -> Bool {
        trainingLossTraceValid(
            losses,
            completedSteps: completedSteps
        )
    }

    static func exactTrainingContinuationValidForTesting(
        persistencePolicy:
            ErgenticsNativeLanguageCanary.TrainingPersistencePolicy,
        interruptedTrajectoryReplayExact: Bool
    ) -> Bool {
        exactTrainingContinuationValid(
            persistencePolicy: persistencePolicy,
            interruptedTrajectoryReplayExact:
                interruptedTrajectoryReplayExact
        )
    }

    static func metalLibraryBundleAuditValidForTesting(
        auditID: String?,
        baseCount: Int?,
        verifiedMirrorCount: Int?,
        divergentCandidateCount: Int?,
        sourceMLXSwiftRevision: String?,
        packageResolvedMLXSwiftRevision: String
    ) -> Bool {
        metalLibraryBundleAuditValid(
            auditID: auditID,
            baseCount: baseCount,
            verifiedMirrorCount: verifiedMirrorCount,
            divergentCandidateCount: divergentCandidateCount,
            sourceMLXSwiftRevision: sourceMLXSwiftRevision,
            packageResolvedMLXSwiftRevision:
                packageResolvedMLXSwiftRevision
        )
    }

    static func observedFP32ParameterDTypesValidForTesting(
        modelParameterDTypes: [String],
        trainableParameterDTypes: [String]
    ) -> Bool {
        observedFP32ParameterDTypesValid(
            modelParameterDTypes: modelParameterDTypes,
            trainableParameterDTypes:
                trainableParameterDTypes
        )
    }

    static func sameSeedReplayValidForTesting(
        _ reports: [ErgenticsNativeLanguageCanary.Report]
    ) -> Bool {
        sameSeedReplayValid(reports)
    }

    static func sameSeedFixedPromptBehavioralReplayValidForTesting(
        _ replay:
            ErgenticsNativeLanguageCanary
                .SameSeedReplayEvidence
    ) -> Bool {
        sameSeedFixedPromptBehavioralReplayValid(replay)
    }

    public static func dispose(
        _ materials: Materials
    ) -> Assessment {
        let totalStarted =
            ProcessInfo.processInfo.systemUptime
        let evaluationStarted =
            ProcessInfo.processInfo.systemUptime
        let evaluation = evaluate(materials)
        let evaluationSeconds =
            ProcessInfo.processInfo.systemUptime
                - evaluationStarted
        let sweepRun = mutationSweep(
            evaluation: evaluation,
            tokenizerManifestData:
                materials.tokenizerManifestData,
            corpusManifestData:
                materials.corpusManifestData,
            packageResolvedBinding:
                materials.packageResolvedArtifactBinding,
            executorArtifactDataByFileName:
                materials.executorArtifactDataByFileName,
            recommenderArtifactDataByFileName:
                materials.recommenderArtifactDataByFileName,
            configurationArtifactDataBySeed:
                materials.configurationArtifactDataBySeed,
            metalLibraryBindingsBySeed:
                materials.metalLibraryArtifactBindingBySeed
        )
        let sweep = sweepRun.sweep
        let mutationPass =
            sweep?.outcome == "GROUNDED"
                && sweep?.results.count == Mutation.allCases.count
        let legValues: [(String, Bool, String)] = [
            (
                criticalLegIDs[0],
                evaluation.materialReload,
                evaluation.materialReloadComponentPasses
                    .filter { !$0.value }.keys.sorted().isEmpty
                ? "all canonical material and provenance subcontracts passed"
                : "failed: "
                    + evaluation.materialReloadComponentPasses
                        .filter { !$0.value }.keys.sorted()
                        .joined(separator: ",")
            ),
            (
                criticalLegIDs[1],
                evaluation.sz,
                "three-point finite-field polynomial plus structural corruptions"
            ),
            (
                criticalLegIDs[2],
                evaluation.foundationCorpus,
                "Foundation.Data UTF-8 and independent corpus-row regrade"
            ),
            (
                criticalLegIDs[3],
                evaluation.rawExecutor,
                "complete per-row autoregressive prediction and hash regrade"
            ),
            (
                criticalLegIDs[4],
                evaluation.causalMechanics,
                "shifted masked causal loss, finite gradients, real update"
            ),
            (
                criticalLegIDs[5],
                evaluation.durability,
                "exact checkpoint/config/executable replay"
            ),
            (
                criticalLegIDs[6],
                evaluation.sameSeedReplay,
                "duplicate same-seed initialization, optimizer step, parameter, and raw-result replay"
            ),
            (
                criticalLegIDs[7],
                evaluation.seedConsensus,
                "exact frozen seed set and one profile/corpus/tokenizer"
            ),
            (
                criticalLegIDs[8],
                evaluation.capability,
                "frozen depth/thresholds and exact malformed ABSTAIN"
            ),
            (
                criticalLegIDs[9],
                mutationPass,
                "\(sweep?.results.count ?? 0)/\(Mutation.allCases.count) named mutations detected and restored"
            ),
        ]
        let witnesses = legValues.map {
            PrimeNeuralVerifyAbstainGate.Witness(
                leg: $0.0,
                pass: $0.1,
                detail: $0.2
            )
        }
        let allCriticalPass = witnesses.allSatisfy(\.pass)
        let verdict = PrimeNeuralVerifyAbstainGate.Verdict(
            witnesses: witnesses,
            outcome: allCriticalPass
                ? .grounded : .verifyAbstain
        )
        let action = nextAction(
            materials: materials,
            evaluation: evaluation,
            mutationPass: mutationPass
        )
        var durations = sweepRun.phaseDurationsSeconds
        durations["baseline_evaluate_total"] =
            evaluationSeconds
        durations["baseline_sz_plan"] =
            evaluation.baselineSZPlanSeconds
        durations["baseline_sz_structural_pool"] =
            evaluation.baselineSZStructuralPoolSeconds
        durations["baseline_evaluate_excluding_sz"] = max(
            0,
            evaluationSeconds
                - evaluation.baselineSZPlanSeconds
                - evaluation.baselineSZStructuralPoolSeconds
        )
        durations["dispose_total"] =
            ProcessInfo.processInfo.systemUptime
                - totalStarted
        return Assessment(
            verdict: verdict,
            nextAction: action,
            fingerprint: evaluation.fingerprint,
            mutationSweep: sweep,
            materialReloadComponentPasses:
                evaluation.materialReloadComponentPasses,
            phaseDurationsSeconds: durations
        )
    }

    private static func nextAction(
        materials: Materials,
        evaluation: Evaluation,
        mutationPass: Bool
    ) -> String {
        if containsObsoleteOrMissingReportSchema(
            materials.reportData
        ) {
            return "reject_obsolete_native_language_report_schema"
        }
        if materials.reportData.count
            != ErgenticsNativeLanguageCanary.frozenSeeds.count
        {
            return "run_full_native_language_canary_for_exact_frozen_seed_set"
        }
        if materials.tokenizerManifestData == nil {
            return "stage_canonical_native_byte_tokenizer_manifest"
        }
        if materials.corpusManifestData == nil {
            return "stage_canonical_native_text_corpus_manifest"
        }
        if materials.packageResolvedArtifactBinding == nil {
            return "stage_exact_package_resolved_artifact"
        }
        if containsForbiddenQuantHessianMetadata(
            materials.reportData
        ) {
            return "reject_quant_hessian_metadata_from_pre_checkpoint_language_gate"
        }
        if evaluation.reports.contains(where: {
            $0.generationContractID
                != ErgenticsNativeLanguageCanary
                    .generationContractID
        }) {
            return "reject_target_length_or_constrained_generation_contract"
        }
        if evaluation.reports.contains(where: { report in
            !report.corpus.overCapTargetRowIDs.isEmpty
                || report.corpus
                    .maximumEvaluationTargetTokenCount + 1
                    > ErgenticsNativeLanguageCanary
                        .maximumGenerationTokenDecisions
                || report.rawPredictions.contains {
                    $0.targetTokenIDs.count + 1
                        > ErgenticsNativeLanguageCanary
                            .maximumGenerationTokenDecisions
                }
        }) {
            return "reject_native_language_corpus_target_over_generation_cap"
        }
        if evaluation.reports.contains(where: {
            materials.probeTokenManifestDataBySeed[$0.seed] == nil
        }) {
            return "stage_probe_token_manifests_beside_reports"
        }
        if evaluation.reports.contains(where: {
            materials.executorArtifactDataByFileName[
                $0.implementation.executorArtifactFileName
            ] == nil
        }) {
            return "stage_exact_swift_executor_artifact_beside_reports"
        }
        if evaluation.reports.contains(where: {
            materials.metalLibraryArtifactBindingBySeed[
                $0.seed
            ] == nil
        }) {
            return "stage_exact_private_metal_library_pair_beside_executor"
        }
        if evaluation.reports.contains(where: {
            materials.recommenderArtifactDataByFileName[
                $0.implementation.recommenderArtifactFileName
            ] == nil
        }) {
            return "stage_exact_swift_recommender_artifact_beside_reports"
        }
        if evaluation.reports.contains(where: {
            materials.configurationArtifactDataBySeed[$0.seed] == nil
        }) {
            return "stage_exact_run_configuration_artifacts_beside_reports"
        }
        if evaluation.reports.contains(where: {
            materials.checkpointArtifactBindingBySeed[$0.seed]
                == nil
        }) {
            return "restore_exact_checkpoint_artifacts"
        }
        if evaluation.reports.contains(where: {
            materials.trainingStageArtifactDataBySeed[$0.seed]
                == nil
        }) {
            return "restore_exact_training_stage_artifacts"
        }
        if evaluation.reports.contains(where: { report in
            let available =
                materials.evaluationShardDataBySeed[
                    report.seed
                ] ?? [:]
            return report.evaluationShards.contains {
                available[$0.fileName] == nil
            }
        }) {
            return "restore_all_declared_evaluation_shards"
        }
        if !evaluation.materialReload {
            if !provenanceArtifactsValid(
                reports: evaluation.reports,
                tokenizerManifestData:
                    materials.tokenizerManifestData,
                corpusManifestData:
                    materials.corpusManifestData,
                packageResolvedBinding:
                    materials.packageResolvedArtifactBinding,
                executorDataByFileName:
                    materials.executorArtifactDataByFileName,
                recommenderDataByFileName:
                    materials.recommenderArtifactDataByFileName,
                configurationDataBySeed:
                    materials.configurationArtifactDataBySeed,
                metalLibraryBindingsBySeed:
                    materials.metalLibraryArtifactBindingBySeed
            ) {
                return "repair_executor_recommender_and_configuration_artifact_binding"
            }
            return "repair_canonical_native_language_material_binding"
        }
        if !evaluation.sz {
            return "repair_native_language_finite_field_fingerprint"
        }
        if !evaluation.foundationCorpus {
            return "repair_independent_foundation_tokenizer_corpus_regrade"
        }
        if !evaluation.rawExecutor {
            return "repair_complete_raw_executor_regrade"
        }
        if !evaluation.causalMechanics {
            return "repair_shifted_causal_training_mechanics"
        }
        if !evaluation.durability {
            return "repair_checkpoint_durability"
        }
        if !evaluation.sameSeedReplay {
            return "repair_same_seed_initialization_training_result_replay"
        }
        if !evaluation.seedConsensus {
            return "rerun_exact_frozen_seed_consensus"
        }
        if !evaluation.capability {
            return "abstain_and_diagnose_native_language_representation"
        }
        if !mutationPass {
            return "repair_native_language_mutation_synthesis"
        }
        return "admit_isolated_prime_domain_transfer_canary"
    }

    private static func evaluate(
        _ materials: Materials
    ) -> Evaluation {
        let decoder = JSONDecoder()
        let reports = materials.reportData.compactMap {
            try? decoder.decode(
                ErgenticsNativeLanguageCanary.Report.self,
                from: $0
            )
        }
        let tokenizer = materials.tokenizerManifestData.flatMap {
            try? decoder.decode(
                PrimeNativeByteTokenizer.Manifest.self,
                from: $0
            )
        }
        let corpus = materials.corpusManifestData.flatMap {
            try? decoder.decode(
                ErgenticsPrimeNativeTextCorpus.Manifest.self,
                from: $0
            )
        }
        let provenance = provenanceArtifactsValid(
            reports: reports,
            tokenizerManifestData:
                materials.tokenizerManifestData,
            corpusManifestData:
                materials.corpusManifestData,
            packageResolvedBinding:
                materials.packageResolvedArtifactBinding,
            executorDataByFileName:
                materials.executorArtifactDataByFileName,
            recommenderDataByFileName:
                materials.recommenderArtifactDataByFileName,
            configurationDataBySeed:
                materials.configurationArtifactDataBySeed,
            metalLibraryBindingsBySeed:
                materials.metalLibraryArtifactBindingBySeed
        )
        let canonicalReload = canonicalMaterialReload(
            materials: materials,
            reports: reports,
            tokenizer: tokenizer,
            corpus: corpus
        )
        var materialReloadComponents =
            canonicalReload.componentPasses
        materialReloadComponents["provenance_artifacts"] =
            provenance
        let materialReload =
            canonicalReload.pass && provenance
        let foundationCorpus = foundationCorpusRegrade(
            reports: reports,
            tokenizer: tokenizer,
            corpus: corpus
        )
        let rawExecutor = rawExecutorRegrade(reports)
        let causal = causalMechanicsValid(reports)
        let durability = durabilityValid(reports)
            && provenance
            && durablePhysicalArtifactsValid(
                reports: reports,
                packageResolvedBinding:
                    materials.packageResolvedArtifactBinding,
                checkpointBindingsBySeed:
                    materials.checkpointArtifactBindingBySeed,
                metalLibraryBindingsBySeed:
                    materials.metalLibraryArtifactBindingBySeed,
                trainingStageDataBySeed:
                    materials.trainingStageArtifactDataBySeed
            )
            && evaluationShardsValid(
                reports: reports,
                dataBySeed: materials.evaluationShardDataBySeed
            )
        let sameSeedReplay = sameSeedReplayValid(reports)
        let consensus = seedConsensusValid(reports)
        let capability = capabilityValid(reports)
        let invariantRecordCollection = invariantRecords(
            reports: reports,
            tokenizer: tokenizer,
            corpus: corpus,
            rowHashRegrade: rawExecutor && foundationCorpus
        )
        let records = invariantRecordCollection.records
        let planStarted =
            ProcessInfo.processInfo.systemUptime
        let baselinePlan = records.isEmpty
            ? nil
            : finiteFieldBaselinePlan(
                cacheKey: materials.exactArtifactCacheKey,
                records: records,
                recordIsASCII:
                    invariantRecordCollection.isASCII
            )
        let planSeconds =
            ProcessInfo.processInfo.systemUptime - planStarted
        let structuralStarted =
            ProcessInfo.processInfo.systemUptime
        let fingerprint = baselinePlan?.fingerprint
        let sz = baselinePlan.map {
            poolExpansionPasses(
                records,
                recordIsASCII:
                    invariantRecordCollection.isASCII,
                baselinePlan: $0
            )
        } ?? false
        let structuralSeconds =
            ProcessInfo.processInfo.systemUptime
                - structuralStarted
        return Evaluation(
            exactArtifactCacheKey:
                materials.exactArtifactCacheKey,
            reports: reports,
            tokenizer: tokenizer,
            corpus: corpus,
            materialReload: materialReload,
            sz: sz,
            foundationCorpus: foundationCorpus,
            rawExecutor: rawExecutor,
            causalMechanics: causal,
            durability: durability,
            sameSeedReplay: sameSeedReplay,
            seedConsensus: consensus,
            capability: capability,
            materialReloadComponentPasses:
                materialReloadComponents,
            fingerprint: fingerprint,
            invariantRecords: records,
            invariantRecordIsASCII:
                invariantRecordCollection.isASCII,
            baselineSZPlanSeconds: planSeconds,
            baselineSZStructuralPoolSeconds:
                structuralSeconds
        )
    }

    private static func canonicalMaterialReload(
        materials: Materials,
        reports: [ErgenticsNativeLanguageCanary.Report],
        tokenizer: PrimeNativeByteTokenizer.Manifest?,
        corpus: ErgenticsPrimeNativeTextCorpus.Manifest?
    ) -> MaterialReloadEvaluation {
        var components = [String: Bool]()
        let schemaAndMaterialPresence =
            reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count
                && reports.count == materials.reportData.count
                && tokenizer != nil
                && corpus != nil
                && !containsForbiddenQuantHessianMetadata(
                    materials.reportData
                )
        components["schema_and_material_presence"] =
            schemaAndMaterialPresence

        guard let tokenizer, let corpus else {
            components["tokenizer_corpus_verify"] = false
            components["corpus_report_binding"] = false
            components["probe_token_manifests"] = false
            components["evaluation_shards"] = false
            components["report_codable_replay"] = false
            components["report_sha_recommendation_binding"] = false
            components["authority_n1_n5"] = false
            return MaterialReloadEvaluation(
                componentPasses: components
            )
        }

        var tokenizerCorpusVerify = true
        do {
            try PrimeNativeByteTokenizer.verify(tokenizer)
            try ErgenticsPrimeNativeTextCorpus.verify(corpus)
        } catch {
            tokenizerCorpusVerify = false
        }
        components["tokenizer_corpus_verify"] =
            tokenizerCorpusVerify

        let corpusManifestData = materials.corpusManifestData
        let expectedCorpusManifestFileName =
            URL(
                fileURLWithPath:
                    ErgenticsPrimeNativeTextCorpus
                        .relativeManifestPath
            ).pathComponents.last
        components["corpus_report_binding"] =
            corpus.tokenizerManifestSHA256
                == tokenizer.manifestSHA256
                && corpusManifestData != nil
                && expectedCorpusManifestFileName != nil
                && reports.allSatisfy {
                    $0.mode == .fullCanary
                        && $0.generationContractID
                            == ErgenticsNativeLanguageCanary
                                .generationContractID
                        && $0.tokenizer.manifestSHA256
                            == tokenizer.manifestSHA256
                        && $0.corpus.manifestSHA256
                            == corpus.manifestSHA256
                        && $0.corpus.manifestArtifactSHA256
                            == corpusManifestData.map(sha256)
                        && $0.corpus.manifestFileName
                            == expectedCorpusManifestFileName
                }
        components["probe_token_manifests"] =
            probeTokenManifestsValid(
                reports: reports,
                dataBySeed:
                    materials.probeTokenManifestDataBySeed
            )
        components["evaluation_shards"] =
            evaluationShardsValid(
                reports: reports,
                dataBySeed:
                    materials.evaluationShardDataBySeed
            )

        let encoder = canonicalEncoder()
        let decoder = JSONDecoder()
        let required = [
            "N1_schema_and_random_init_text_lineage",
            "N2_exact_maintained_engine_profile",
            "N3_native_512_tokenizer_replay",
            "N4_first_party_corpus_and_probe_binding",
            "N5_swift_mlx_metal_maintained_primitives",
        ]
        var reportCodableReplay = true
        var reportSHARecommendationBinding = true
        var authorityN1N5 = true
        for report in reports {
            guard let data = try? encoder.encode(report),
                  let replay = try? decoder.decode(
                      ErgenticsNativeLanguageCanary.Report.self,
                      from: data
                  ) else {
                reportCodableReplay = false
                reportSHARecommendationBinding = false
                authorityN1N5 = false
                continue
            }
            reportCodableReplay =
                reportCodableReplay && replay == report
            let recommendation =
                ErgenticsNativeLanguageCanary.recommend(report)
            reportSHARecommendationBinding =
                reportSHARecommendationBinding
                    && sha256(data)
                        == recommendation.reportSHA256
            let byID = Dictionary(
                uniqueKeysWithValues:
                    recommendation.legs.map {
                        ($0.id, $0.pass)
                    }
            )
            authorityN1N5 =
                authorityN1N5
                    && required.allSatisfy {
                        byID[$0] == true
                    }
        }
        components["report_codable_replay"] =
            reportCodableReplay
        components["report_sha_recommendation_binding"] =
            reportSHARecommendationBinding
        components["authority_n1_n5"] = authorityN1N5
        return MaterialReloadEvaluation(
            componentPasses: components
        )
    }

    private static func metalLibraryBundleAuditValid(
        auditID: String?,
        baseCount: Int?,
        verifiedMirrorCount: Int?,
        divergentCandidateCount: Int?,
        sourceMLXSwiftRevision: String?,
        packageResolvedMLXSwiftRevision: String
    ) -> Bool {
        guard let auditID,
              let baseCount,
              let verifiedMirrorCount,
              let divergentCandidateCount,
              let sourceMLXSwiftRevision
        else {
            return false
        }
        return auditID
            == ErgenticsNativeLanguageCanary
                .metalLibraryBundleSearchAuditID
            && baseCount > 0
            && verifiedMirrorCount >= 0
            && verifiedMirrorCount <= baseCount
            && divergentCandidateCount == 0
            && isGitRevision(sourceMLXSwiftRevision)
            && sourceMLXSwiftRevision
                == packageResolvedMLXSwiftRevision
    }

    private static func provenanceArtifactsValid(
        reports: [ErgenticsNativeLanguageCanary.Report],
        tokenizerManifestData: Data?,
        corpusManifestData: Data?,
        packageResolvedBinding:
            ObservedPackageResolvedBinding?,
        executorDataByFileName: [String: Data],
        recommenderDataByFileName: [String: Data],
        configurationDataBySeed: [Int: Data],
        metalLibraryBindingsBySeed:
            [Int: ObservedMetalLibraryBinding]
    ) -> Bool {
        guard reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count,
              let tokenizerManifestData,
              let corpusManifestData,
              let packageResolvedBinding,
              packageResolvedBinding.fileName
                == packageResolvedArtifactFileName,
              isSHA256(packageResolvedBinding.sha256),
              packageResolvedBinding.byteCount > 0,
              isGitRevision(
                  packageResolvedBinding.mlxSwiftRevision
              ),
              packageResolvedBinding.mlxSwiftExamplesVersion
                == "2.29.1"
        else {
            return false
        }
        let tokenizerArtifactSHA256 =
            sha256(tokenizerManifestData)
        let corpusArtifactSHA256 =
            sha256(corpusManifestData)
        let executorNames = Set(
            reports.map {
                $0.implementation.executorArtifactFileName
            }
        )
        let recommenderNames = Set(
            reports.map {
                $0.implementation.recommenderArtifactFileName
            }
        )
        guard executorNames == Set(
                  executorDataByFileName.keys
              ),
              executorNames.count == 1,
              recommenderNames == Set(
                  recommenderDataByFileName.keys
              ),
              recommenderNames
                == ["PrimeNativeLanguageCanaryRecommend"],
              Set(configurationDataBySeed.keys)
                == Set(reports.map(\.seed)),
              Set(metalLibraryBindingsBySeed.keys)
                == Set(reports.map(\.seed))
        else {
            return false
        }
        return reports.allSatisfy { report in
            let implementation = report.implementation
            let training = report.training
            guard implementation.buildConfiguration
                    == ErgenticsNativeLanguageCanary
                        .requiredBuildConfiguration,
                  implementation.precision
                    == ErgenticsNativeLanguageCanary
                        .requiredPrecision,
                  observedFP32ParameterDTypesValid(
                      modelParameterDTypes:
                        implementation
                            .observedModelParameterDTypes,
                      trainableParameterDTypes:
                        implementation
                            .observedTrainableParameterDTypes
                  ),
                  training.precision
                    == ErgenticsNativeLanguageCanary
                        .requiredPrecision,
                  !implementation.executorArtifactFileName.isEmpty,
                  implementation.executorArtifactFileName != ".",
                  implementation.executorArtifactFileName != "..",
                  !implementation.executorArtifactFileName
                    .contains("\\"),
                  URL(
                      fileURLWithPath:
                        implementation.executorArtifactFileName
                  ).lastPathComponent
                    == implementation.executorArtifactFileName,
                  implementation.recommenderArtifactFileName
                    == "PrimeNativeLanguageCanaryRecommend",
                  URL(
                      fileURLWithPath:
                        implementation.recommenderArtifactFileName
                  ).lastPathComponent
                    == implementation.recommenderArtifactFileName,
                  !training.configurationArtifactFileName.isEmpty,
                  training.configurationArtifactFileName != ".",
                  training.configurationArtifactFileName != "..",
                  !training.configurationArtifactFileName
                    .contains("\\"),
                  URL(
                      fileURLWithPath:
                        training.configurationArtifactFileName
                  ).lastPathComponent
                    == training.configurationArtifactFileName,
                  let executorData =
                    executorDataByFileName[
                        implementation.executorArtifactFileName
                    ],
                  let recommenderData =
                    recommenderDataByFileName[
                        implementation.recommenderArtifactFileName
                    ],
                  let configurationData =
                    configurationDataBySeed[report.seed],
                  let metalLibrary =
                    metalLibraryBindingsBySeed[report.seed],
                  !executorData.isEmpty,
                  !recommenderData.isEmpty,
                  !configurationData.isEmpty,
                  sha256(executorData)
                    == implementation.executorArtifactSHA256,
                  sha256(recommenderData)
                    == implementation.recommenderArtifactSHA256,
                  sha256(configurationData)
                    == training.configurationArtifactSHA256,
                  implementation.packageResolvedSHA256
                    == packageResolvedBinding.sha256,
                  implementation.metalLibrarySourceMLXSwiftRevision
                    == packageResolvedBinding.mlxSwiftRevision,
                  implementation.mlxSwiftExamplesVersion
                    == packageResolvedBinding
                        .mlxSwiftExamplesVersion,
                  metalLibrary.primaryFileName
                    == metalLibraryPrimaryFileName,
                  metalLibrary.fallbackFileName
                    == metalLibraryFallbackFileName,
                  isSHA256(metalLibrary.sha256),
                  metalLibrary.byteCount > 0,
                  implementation.metalLibraryArtifactSHA256
                    == metalLibrary.sha256,
                  implementation.metalLibraryArtifactByteCount
                    == metalLibrary.byteCount,
                  implementation.metalLibraryPrimaryFileName
                    == metalLibrary.primaryFileName,
                  implementation.metalLibraryFallbackFileName
                    == metalLibrary.fallbackFileName,
                  metalLibraryBundleAuditValid(
                      auditID:
                        implementation
                            .metalLibraryBundleSearchAuditID,
                      baseCount:
                        implementation
                            .metalLibraryBundleSearchBaseCount,
                      verifiedMirrorCount:
                        implementation
                            .metalLibraryVerifiedBundleMirrorCount,
                      divergentCandidateCount:
                        implementation
                            .metalLibraryDivergentBundleCandidateCount,
                      sourceMLXSwiftRevision:
                        implementation
                            .metalLibrarySourceMLXSwiftRevision,
                      packageResolvedMLXSwiftRevision:
                        packageResolvedBinding.mlxSwiftRevision
                  ),
                  configurationContractValid(
                      configurationData,
                      report: report,
                      tokenizerArtifactSHA256:
                        tokenizerArtifactSHA256,
                      corpusArtifactSHA256:
                        corpusArtifactSHA256,
                      packageResolvedSHA256:
                        packageResolvedBinding.sha256
                  ),
                  let durability = report.durability,
                  durability.buildConfiguration
                    == ErgenticsNativeLanguageCanary
                        .requiredBuildConfiguration,
                  durability.buildConfiguration
                    == implementation.buildConfiguration,
                  durability.precision
                    == ErgenticsNativeLanguageCanary
                        .requiredPrecision,
                  durability.precision
                    == implementation.precision,
                  durability.precision == training.precision,
                  observedFP32ParameterDTypesValid(
                      modelParameterDTypes:
                        durability
                            .observedModelParameterDTypes,
                      trainableParameterDTypes:
                        durability
                            .observedTrainableParameterDTypes
                  ),
                  durability.observedModelParameterDTypes
                    == implementation
                        .observedModelParameterDTypes,
                  durability.observedTrainableParameterDTypes
                    == implementation
                        .observedTrainableParameterDTypes,
                  durability.executableSHA256
                    == implementation.executorArtifactSHA256,
                  durability.configurationSHA256
                    == training.configurationArtifactSHA256,
                  durability.recommenderSHA256
                    == implementation.recommenderArtifactSHA256,
                  durability.recommenderFileName
                    == implementation.recommenderArtifactFileName,
                  durability.metalLibraryArtifactSHA256
                    == implementation.metalLibraryArtifactSHA256,
                  durability.metalLibraryArtifactByteCount
                    == implementation.metalLibraryArtifactByteCount,
                  durability.metalLibraryPrimaryFileName
                    == implementation.metalLibraryPrimaryFileName,
                  durability.metalLibraryFallbackFileName
                    == implementation.metalLibraryFallbackFileName,
                  durability.metalLibraryBundleSearchAuditID
                    == implementation
                        .metalLibraryBundleSearchAuditID,
                  durability.metalLibraryBundleSearchBaseCount
                    == implementation
                        .metalLibraryBundleSearchBaseCount,
                  durability.metalLibraryVerifiedBundleMirrorCount
                    == implementation
                        .metalLibraryVerifiedBundleMirrorCount,
                  durability
                    .metalLibraryDivergentBundleCandidateCount
                    == implementation
                        .metalLibraryDivergentBundleCandidateCount,
                  durability.metalLibrarySourceMLXSwiftRevision
                    == implementation
                        .metalLibrarySourceMLXSwiftRevision,
                  report.corpus.manifestArtifactSHA256
                    == corpusArtifactSHA256
            else {
                return false
            }
            return true
        }
    }

    private static func configurationContractValid(
        _ data: Data,
        report: ErgenticsNativeLanguageCanary.Report,
        tokenizerArtifactSHA256: String,
        corpusArtifactSHA256: String,
        packageResolvedSHA256: String
    ) -> Bool {
        let expected =
            ErgenticsNativeLanguageRunConfiguration.Expected(
                mode: report.mode,
                buildConfiguration:
                    report.implementation.buildConfiguration,
                precision: report.implementation.precision,
                phase: nil,
                probePurposeID: nil,
                profileID: report.profile.profileID,
                seed: report.seed,
                steps: report.training.requestedSteps,
                batchSize: report.training.batchSize,
                gradientAccumulationSteps:
                    report.training.gradientAccumulationSteps,
                sequenceLength:
                    report.training.measuredSequenceLength,
                processedPaddedTokenPositions:
                    report.training
                        .processedPaddedTokenPositions,
                plannedTrainingTokenPresentations:
                    report.training
                        .plannedTrainingTokenPresentations,
                evaluationBatchSize:
                    report.training.evaluationBatchSize,
                evaluationShardSize:
                    report.mode == .fullCanary
                    ? report.training.evaluationShardSize : nil,
                learningRate: report.training.learningRate,
                weightDecay: report.training.weightDecay,
                maximumExecutorWallSeconds:
                    report.training
                        .declaredMaximumExecutorWallSeconds,
                tokenizerArtifactSHA256:
                    tokenizerArtifactSHA256,
                corpusArtifactSHA256:
                    corpusArtifactSHA256,
                packageResolvedSHA256:
                    packageResolvedSHA256,
                executorSHA256:
                    report.implementation.executorArtifactSHA256,
                recommenderSHA256:
                    report.implementation
                        .recommenderArtifactSHA256,
                metalLibraryArtifactSHA256:
                    report.implementation
                        .metalLibraryArtifactSHA256,
                metalLibraryArtifactByteCount:
                    report.implementation
                        .metalLibraryArtifactByteCount,
                metalLibraryPrimaryFileName:
                    report.implementation
                        .metalLibraryPrimaryFileName,
                metalLibraryFallbackFileName:
                    report.implementation
                        .metalLibraryFallbackFileName,
                metalLibraryBundleSearchAuditID:
                    report.implementation
                        .metalLibraryBundleSearchAuditID,
                metalLibrarySourceMLXSwiftRevision:
                    report.implementation
                        .metalLibrarySourceMLXSwiftRevision
            )
        return (
            try? ErgenticsNativeLanguageRunConfiguration.validate(
                data,
                expected: expected
            )
        ) != nil
    }

    private static func observedFP32ParameterDTypesValid(
        modelParameterDTypes: [String],
        trainableParameterDTypes: [String]
    ) -> Bool {
        modelParameterDTypes == [
            ErgenticsNativeLanguageCanary.requiredPrecision
        ]
            && trainableParameterDTypes == [
                ErgenticsNativeLanguageCanary.requiredPrecision
            ]
    }

    private static func probeTokenManifestsValid(
        reports: [ErgenticsNativeLanguageCanary.Report],
        dataBySeed: [Int: Data]
    ) -> Bool {
        guard Set(dataBySeed.keys) == Set(reports.map(\.seed))
        else {
            return false
        }
        for report in reports {
            let fileName =
                report.corpus.probeTokenManifestFileName
            let training = report.training
            guard fileName == "probe-token-manifest.json",
                  let data = dataBySeed[report.seed],
                  sha256(data)
                    == report.corpus
                        .probeTokenManifestArtifactSHA256,
                  let probe = try? JSONDecoder().decode(
                      ProbeTokenManifest.self,
                      from: data
                  ),
                  let canonical = try? canonicalEncoder()
                    .encode(probe),
                  sha256(canonical)
                    == report.corpus.probeTokenManifestSHA256,
                  sha256(canonical)
                    == report.training
                        .trainingScheduleManifestSHA256,
                  probe.schemaVersion == "2",
                  probe.tokenizerManifestSHA256
                    == report.tokenizer.manifestSHA256,
                  probe.corpusManifestSHA256
                    == report.corpus.manifestSHA256,
                  probe.corpusManifestArtifactSHA256
                    == report.corpus.manifestArtifactSHA256,
                  probe.seed == report.seed,
                  probe.steps == training.requestedSteps,
                  probe.measurementWarmupSteps
                    == training.measurementWarmupSteps,
                  probe.timedSteps
                    == training.timedSteps,
                  probe.batchSize == training.batchSize,
                  probe.gradientAccumulationSteps
                    == training.gradientAccumulationSteps,
                  probe.effectiveBatchSize
                    == training.effectiveBatchSize,
                  probe.effectiveBatchSize
                    == probe.batchSize
                        * probe.gradientAccumulationSteps,
                  probe.sequenceLength
                    == training.measuredSequenceLength,
                  probe.presentationMode
                    == "balanced_manifest_epoch_permutation",
                  probe.probePurposeID
                    == "bounded_full_diagnostic_v1",
                  probe.scheduleID
                    == "manifest_sha256_curriculum_240_valid_48_refusal_epoch_reason_stratified_v3",
                  probe.batchSize == 2,
                  probe.gradientAccumulationSteps == 4,
                  probe.effectiveBatchSize == 8,
                  probe.sequenceLength == 512,
                  probe.steps > 0,
                  probe.steps % 36 == 0,
                  probe.steps <= 216,
                  probe.measurementWarmupSteps == 0,
                  probe.timedSteps == probe.steps,
                  probe.scheduledRowIDs.count
                    == probe.steps * probe.effectiveBatchSize,
                  probe.scheduledRowIDs.count % 288 == 0,
                  probe.uniqueInputRows
                    == Set(probe.scheduledRowIDs).count,
                  probe.uniqueInputRows
                    == probe.scheduledRowIDs.count,
                  probe.scheduledValidRowCount
                    + probe.scheduledRefusalRowCount
                    == probe.scheduledRowIDs.count,
                  probe.scheduledValidRowCount
                    == probe.scheduledRowIDs.count / 288 * 240,
                  probe.scheduledRefusalRowCount
                    == probe.scheduledRowIDs.count / 288 * 48,
                  probe.scheduledValidRowCount
                    == training.scheduledValidRowCount,
                  probe.scheduledRefusalRowCount
                    == training.scheduledRefusalRowCount,
                  probe.scheduledValidSemanticFamilyRows
                    == training.scheduledValidSemanticFamilyRows,
                  probe.scheduledRefusalSemanticFamilyRows
                    == training
                        .scheduledRefusalSemanticFamilyRows,
                  probe.scheduledRefusalReasonRows
                    == training.scheduledRefusalReasonRows,
                  probe.scheduledRefusalReasonScheduleSHA256
                    == training
                        .scheduledRefusalReasonScheduleSHA256,
                  Set(probe.scheduledRefusalReasonRows.keys)
                    == Set(
                        ErgenticsPrimeNativeTextCorpus
                            .refusalReasonIDs
                    ),
                  probe.scheduledRefusalReasonRows.values
                    .allSatisfy({ $0 > 0 }),
                  probe.scheduledRefusalReasonRows.values
                    .reduce(0, +)
                    == probe.scheduledRefusalRowCount,
                  isSHA256(
                      probe
                        .scheduledRefusalReasonScheduleSHA256
                  ),
                  probe.heldoutRowIDs.count
                    == training.heldoutRowCount,
                  probe.heldoutRowIDs.count == 288,
                  probe.heldoutValidRowCount == 240,
                  probe.heldoutRefusalRowCount == 48,
                  probe.heldoutValidRowCount
                    == training.heldoutValidRowCount,
                  probe.heldoutRefusalRowCount
                    == training.heldoutRefusalRowCount,
                  probe.heldoutValidSemanticFamilyRows
                    == training.heldoutValidSemanticFamilyRows,
                  probe.heldoutRefusalSemanticFamilyRows
                    == training.heldoutRefusalSemanticFamilyRows,
                  probe.heldoutRefusalReasonRows
                    == training.heldoutRefusalReasonRows,
                  probe.heldoutRefusalReasonScheduleSHA256
                    == training
                        .heldoutRefusalReasonScheduleSHA256,
                  Set(probe.heldoutRefusalReasonRows.keys)
                    == Set(
                        ErgenticsPrimeNativeTextCorpus
                            .refusalReasonIDs
                    ),
                  probe.heldoutRefusalReasonRows.values
                    .allSatisfy({ $0 > 0 }),
                  probe.heldoutRefusalReasonRows.values
                    .reduce(0, +)
                    == probe.heldoutRefusalRowCount,
                  isSHA256(
                      probe.heldoutRefusalReasonScheduleSHA256
                  ),
                  probe.selectionValidationSplitIDs
                    == [
                        ErgenticsPrimeNativeTextCorpus.Split
                            .validation.rawValue,
                        ErgenticsPrimeNativeTextCorpus.Split
                            .refusalValidation.rawValue,
                    ],
                  probe.selectionValidationSplitIDs
                    == training.selectionValidationSplitIDs,
                  Set(probe.heldoutRowIDs).count
                    == probe.heldoutRowIDs.count,
                  Set(probe.scheduledRowIDs)
                    .isDisjoint(with: probe.heldoutRowIDs),
                  sha256(
                      Data(
                          probe.heldoutRowIDs
                            .joined(separator: "\n").utf8
                      )
                  ) == probe.heldoutScheduleSHA256,
                  probe.heldoutScheduleSHA256
                    == training.heldoutScheduleSHA256,
                  probe.processedPaddedTokenPositions
                    == probe.scheduledRowIDs.count
                        * probe.sequenceLength,
                  probe.processedPaddedTokenPositions
                    == training.processedPaddedTokenPositions,
                  probe.nonPaddingInputTokenPresentations
                    == training.trainedTokens,
                  probe
                    .lossContributingAnswerTokenPresentations
                    == training.answerTokensContributed,
                  report.corpus.probeTokenCount
                    == probe.processedPaddedTokenPositions,
                  training
                    .plannedTrainingTokenPresentations
                    == probe.processedPaddedTokenPositions
            else {
                return false
            }
            let blockCount = probe.scheduledRowIDs.count / 288
            let validFitting = authoritativeTrainingRows.filter {
                $0.sequenceTokenCount <= probe.sequenceLength
            }
            let refusalFitting =
                authoritativeRefusalTrainingRows.filter {
                    $0.sequenceTokenCount <= probe.sequenceLength
                }
            let expectedValidSchedule =
                ErgenticsNativeLanguageCanary
                .deterministicBalancedScheduleRowIDs(
                    rows: validFitting,
                    seed: probe.seed,
                    count: blockCount * 240,
                    namespace: "balanced_valid_train_v1",
                    corpusManifestSHA256:
                        probe.corpusManifestSHA256
                )
            guard let expectedRefusalWitness =
                ErgenticsNativeLanguageCanary
                .deterministicRefusalReasonSchedule(
                    rows: refusalFitting,
                    seed: probe.seed,
                    blockCount: blockCount,
                    namespace:
                        "balanced_refusal_reason_stratified_train_v2",
                    corpusManifestSHA256:
                        probe.corpusManifestSHA256
                )
            else {
                return false
            }
            let expectedRefusalSchedule =
                expectedRefusalWitness.rowIDs
            guard let expectedSchedule =
                    interleavedFiveToOneRowIDs(
                        valid: expectedValidSchedule,
                        refusal: expectedRefusalSchedule
                    )
            else {
                return false
            }
            let scheduledByID = Dictionary(
                uniqueKeysWithValues:
                    (validFitting + refusalFitting).map {
                        ($0.rowID, $0)
                    }
            )
            guard expectedSchedule.allSatisfy({
                scheduledByID[$0] != nil
            }) else {
                return false
            }
            let scheduledRows = expectedSchedule.map {
                scheduledByID[$0]!
            }
            let materializedRows = Dictionary(
                uniqueKeysWithValues:
                    scheduledRows.map { ($0.rowID, $0) }
            ).values.sorted { $0.rowID < $1.rowID }
            let expectedInputs = materializedRows.map {
                preparedInputIDs(
                    $0,
                    sequenceLength: probe.sequenceLength
                )
            }
            let expectedMasks = materializedRows.map {
                preparedLossMask(
                    $0,
                    sequenceLength: probe.sequenceLength
                )
            }
            let expectedFamilies = Dictionary(
                grouping: scheduledRows,
                by: \.semanticFamily
            ).mapValues(\.count)
            let expectedValidFamilies = Dictionary(
                grouping: expectedValidSchedule.map {
                    scheduledByID[$0]!
                },
                by: \.semanticFamily
            ).mapValues(\.count)
            let expectedRefusalFamilies = Dictionary(
                grouping: expectedRefusalSchedule.map {
                    scheduledByID[$0]!
                },
                by: \.semanticFamily
            ).mapValues(\.count)
            let requiredFamilies = Set(
                ErgenticsPrimeNativeTextCorpus
                    .SemanticFamily.allCases.map(\.rawValue)
            )
            guard Set(expectedFamilies.keys) == requiredFamilies,
                  Set(expectedValidFamilies.keys)
                    == requiredFamilies,
                  Set(expectedRefusalFamilies.keys)
                    == requiredFamilies,
                  expectedFamilies.values.allSatisfy({
                      $0 == blockCount * 48
                  }),
                  expectedValidFamilies.values.allSatisfy({
                      $0 == blockCount * 40
                  }),
                  expectedRefusalFamilies.values.allSatisfy({
                      $0 == blockCount * 8
                  })
            else {
                return false
            }
            let heldoutValidCandidates =
                ErgenticsPrimeNativeTextCorpus
                .rows(for: .validation)
                .filter {
                    $0.sequenceTokenCount <= probe.sequenceLength
                }
            let heldoutRefusalCandidates =
                ErgenticsPrimeNativeTextCorpus
                .rows(for: .refusalValidation)
                .filter {
                    $0.sequenceTokenCount <= probe.sequenceLength
                }
            let expectedHeldoutValid =
                ErgenticsNativeLanguageCanary
                .deterministicBalancedScheduleRowIDs(
                    rows: heldoutValidCandidates,
                    seed: probe.seed,
                    count: 240,
                    namespace: "balanced_valid_selection_v1",
                    corpusManifestSHA256:
                        probe.corpusManifestSHA256
                )
            guard let expectedHeldoutRefusalWitness =
                ErgenticsNativeLanguageCanary
                .deterministicRefusalReasonSchedule(
                    rows: heldoutRefusalCandidates,
                    seed: probe.seed,
                    blockCount: 1,
                    namespace:
                        "balanced_refusal_reason_stratified_selection_v2",
                    corpusManifestSHA256:
                        probe.corpusManifestSHA256
                )
            else {
                return false
            }
            let expectedHeldoutRefusal =
                expectedHeldoutRefusalWitness.rowIDs
            guard let expectedHeldout =
                    interleavedFiveToOneRowIDs(
                        valid: expectedHeldoutValid,
                        refusal: expectedHeldoutRefusal
                    )
            else {
                return false
            }
            let nonPadding = scheduledRows
                .map(\.sequenceTokenCount).reduce(0, +)
            let answerTokens = scheduledRows.map {
                PrimeNativeByteTokenizer.encode(
                    $0.expectedCompletion
                ).count + 1
            }.reduce(0, +)
            guard probe.scheduledRowIDs == expectedSchedule,
                  probe.heldoutRowIDs == expectedHeldout,
                  report.sameSeedReplay.scheduledRowIDs
                    == Array(
                        expectedSchedule.prefix(
                            probe.effectiveBatchSize
                        )
                    ),
                  report.training.distinctScheduledRowCount
                    == probe.uniqueInputRows,
                  report.training.scheduledSemanticFamilyRows
                    == expectedFamilies,
                  probe.scheduledValidSemanticFamilyRows
                    == expectedValidFamilies,
                  probe.scheduledRefusalSemanticFamilyRows
                    == expectedRefusalFamilies,
                  probe.scheduledRefusalReasonRows
                    == expectedRefusalWitness.reasonRowCounts,
                  probe.scheduledRefusalReasonScheduleSHA256
                    == expectedRefusalWitness
                        .orderedReasonScheduleSHA256,
                  probe.heldoutValidSemanticFamilyRows.values
                    .allSatisfy({ $0 == 40 }),
                  probe.heldoutRefusalSemanticFamilyRows.values
                    .allSatisfy({ $0 == 8 }),
                  probe.heldoutRefusalReasonRows
                    == expectedHeldoutRefusalWitness
                        .reasonRowCounts,
                  probe.heldoutRefusalReasonScheduleSHA256
                    == expectedHeldoutRefusalWitness
                        .orderedReasonScheduleSHA256,
                  Set(probe.heldoutValidSemanticFamilyRows.keys)
                    == requiredFamilies,
                  Set(probe.heldoutRefusalSemanticFamilyRows.keys)
                    == requiredFamilies,
                  probe.nonPaddingInputTokenPresentations
                    == nonPadding,
                  probe
                    .lossContributingAnswerTokenPresentations
                    == answerTokens,
                  probe.inputIDs == expectedInputs,
                  probe.lossMasks == expectedMasks else {
                return false
            }
        }
        return true
    }

    private static func preparedInputIDs(
        _ row: ErgenticsPrimeNativeTextCorpus.Row,
        sequenceLength: Int
    ) -> [Int] {
        var sequence =
            [PrimeNativeByteTokenizer.beginningOfSequenceTokenID]
            + PrimeNativeByteTokenizer.encode(row.promptText)
            + PrimeNativeByteTokenizer.encode(
                row.expectedCompletion
            )
            + [PrimeNativeByteTokenizer.endOfSequenceTokenID]
        sequence += Array(
            repeating: PrimeNativeByteTokenizer.padTokenID,
            count: sequenceLength - sequence.count
        )
        return sequence
    }

    private static func interleavedFiveToOneRowIDs(
        valid: [String],
        refusal: [String]
    ) -> [String]? {
        guard !refusal.isEmpty,
              valid.count == refusal.count * 5
        else {
            return nil
        }
        var result = [String]()
        result.reserveCapacity(valid.count + refusal.count)
        for refusalIndex in refusal.indices {
            let validStart = refusalIndex * 5
            result.append(
                contentsOf:
                    valid[validStart ..< validStart + 5]
            )
            result.append(refusal[refusalIndex])
        }
        return result
    }

    private static func preparedLossMask(
        _ row: ErgenticsPrimeNativeTextCorpus.Row,
        sequenceLength: Int
    ) -> [Int] {
        let promptCount =
            PrimeNativeByteTokenizer.encode(row.promptText).count
        let completionCount =
            PrimeNativeByteTokenizer.encode(
                row.expectedCompletion
            ).count
        var mask = Array(repeating: 0, count: sequenceLength - 1)
        let firstCompletionIndex = 1 + promptCount
        let sequenceCount =
            1 + promptCount + completionCount + 1
        for targetIndex in firstCompletionIndex ..< sequenceCount {
            mask[targetIndex - 1] = 1
        }
        return mask
    }

    private static func evaluationShardsValid(
        reports: [ErgenticsNativeLanguageCanary.Report],
        dataBySeed: [Int: [String: Data]]
    ) -> Bool {
        let phases = ["zero_shot", "trained", "reloaded"]
        for report in reports {
            guard let shardData = dataBySeed[report.seed],
                  report.durability?.evaluationDirectoryName
                    == evaluationShardDirectoryName,
                  !report.evaluationShards.isEmpty,
                  shardData.count
                    == report.evaluationShards.count,
                  Set(report.evaluationShards.map(\.fileName)).count
                    == report.evaluationShards.count,
                  report.evaluationShards.allSatisfy({
                      phases.contains($0.phase)
                          && shardBasenameValid(
                              $0.fileName,
                              phase: $0.phase
                          )
                  })
            else {
                return false
            }
            let rawRows = report.rawPredictions.sorted {
                $0.rowID < $1.rowID
            }
            let rawByID = Dictionary(
                uniqueKeysWithValues:
                    rawRows.map { ($0.rowID, $0) }
            )
            var decodedByFile = [String: GenerationShard]()
            for binding in report.evaluationShards {
                guard let data = shardData[binding.fileName],
                      sha256(data) == binding.artifactSHA256,
                      let shard = try? JSONDecoder().decode(
                          GenerationShard.self,
                          from: data
                      ),
                      shard.schemaVersion == "2",
                      shard.phase == binding.phase,
                      shard.profileID
                        == report.profile.profileID,
                      shard.seed == report.seed,
                      shard.corpusManifestSHA256
                        == report.corpus.manifestSHA256,
                      shard.generationContractID
                        == ErgenticsNativeLanguageCanary
                            .generationContractID,
                      shard.maximumGenerationTokenDecisions
                        == ErgenticsNativeLanguageCanary
                            .maximumGenerationTokenDecisions,
                      shard.entries.count == binding.rowCount,
                      shard.firstRowID == binding.firstRowID,
                      shard.lastRowID == binding.lastRowID,
                      shard.entries.first?.rowID
                        == binding.firstRowID,
                      shard.entries.last?.rowID
                        == binding.lastRowID,
                      Set(shard.entries.map(\.rowID)).count
                        == shard.entries.count
                else {
                    return false
                }
                let expectedModelBinding: String
                if binding.phase == "zero_shot" {
                    expectedModelBinding =
                        zeroShotModelBindingSHA256(
                            profileID:
                                report.profile.profileID,
                            seed: report.seed,
                            corpusManifestSHA256:
                                report.corpus.manifestSHA256,
                            probeManifestSHA256:
                                report.corpus
                                    .probeTokenManifestSHA256
                        )
                } else {
                    guard let checkpoint =
                        report.durability?.checkpointSHA256
                    else { return false }
                    expectedModelBinding = checkpoint
                }
                guard shard.modelBindingSHA256
                        == expectedModelBinding,
                      shard.entries.allSatisfy({
                          generatedEntryValid(
                              $0,
                              phase: binding.phase,
                              rawByID: rawByID
                          )
                      })
                else {
                    return false
                }
                decodedByFile[binding.fileName] = shard
            }
            for phase in phases {
                let bindings = report.evaluationShards
                    .filter { $0.phase == phase }
                    .sorted { $0.fileName < $1.fileName }
                let observed = bindings.flatMap {
                    decodedByFile[$0.fileName]!.entries.map(\.rowID)
                }
                guard observed == rawRows.map(\.rowID) else {
                    return false
                }
            }
        }
        return Set(dataBySeed.keys)
            == Set(reports.map(\.seed))
    }

    /// Exact zero-shot shard lineage used by the Swift executor. Kept
    /// internal so the independent parity regression can detect field-order
    /// drift without accepting an executor-produced expected value.
    static func zeroShotModelBindingSHA256(
        profileID: String,
        seed: Int,
        corpusManifestSHA256: String,
        probeManifestSHA256: String
    ) -> String {
        sha256(
            Data(
                [
                    ErgenticsNativeLanguageCanary.lineageID,
                    profileID,
                    String(seed),
                    corpusManifestSHA256,
                    probeManifestSHA256,
                    ErgenticsNativeLanguageCanary
                        .generationContractID,
                    "random_init",
                ].joined(separator: "|").utf8
            )
        )
    }

    private static func generatedEntryValid(
        _ entry: GenerationShardEntry,
        phase: String,
        rawByID:
            [String: ErgenticsNativeLanguageCanary.RawPrediction]
    ) -> Bool {
        guard let raw = rawByID[entry.rowID],
              entry.generated.meanLogProbability.isFinite,
              entry.generated.latencySeconds.isFinite,
              entry.generated.latencySeconds > 0,
              entry.generated.tokenLogProbabilities
                .allSatisfy(\.isFinite),
              entry.generated.tokenIDs.count
                <= ErgenticsNativeLanguageCanary
                    .maximumGenerationTokenDecisions,
              entry.generated.tokenLogProbabilities.count
                == entry.generated.tokenIDs.count,
              supportAssistanceWitnessValid(
                  parity:
                    entry.generated
                        .rawFullVocabularyAllowedSupportGreedyTokenParity,
                  disallowedArgmaxCount:
                    entry.generated
                        .disallowedFullVocabularyArgmaxCount,
                  maximumDisallowedProbabilityMass:
                    entry.generated
                        .maximumDisallowedTokenProbabilityMass,
                  decisionsExecuted:
                    entry.generated.tokenIDs.count
                        + (
                            entry.generated.terminatedByEOS
                                ? 1 : 0
                        )
              )
        else {
            return false
        }
        switch phase {
        case "zero_shot":
            return entry.generated.text == raw.zeroShotPrediction
                && entry.generated.tokenIDs
                    == raw.zeroShotPredictionTokenIDs
                && entry.generated.tokenLogProbabilities
                    == raw.zeroShotTokenLogProbabilities
                && entry.generated.meanLogProbability
                    == raw.zeroShotMeanLogProbability
                && entry.generated.terminatedByEOS
                    == raw.zeroShotTerminatedByEOS
                && entry.generated.terminationReason
                    == raw.zeroShotTerminationReason
                && entry.generated.utf8Valid
                    == raw.zeroShotUTF8Valid
                && entry.generated.eosLogProbability
                    == raw.zeroShotEOSLogProbability
                && entry.generated
                    .rawFullVocabularyAllowedSupportGreedyTokenParity
                    == raw
                        .zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity
                && entry.generated
                    .disallowedFullVocabularyArgmaxCount
                    == raw
                        .zeroShotDisallowedFullVocabularyArgmaxCount
                && entry.generated
                    .maximumDisallowedTokenProbabilityMass
                    == raw
                        .zeroShotMaximumDisallowedTokenProbabilityMass
                && entry.generated.latencySeconds
                    == raw.zeroShotLatencySeconds
        case "trained":
            return entry.generated.text == raw.trainedPrediction
                && entry.generated.tokenIDs
                    == raw.trainedPredictionTokenIDs
                && entry.generated.tokenLogProbabilities
                    == raw.trainedTokenLogProbabilities
                && entry.generated.meanLogProbability
                    == raw.trainedMeanLogProbability
                && entry.generated.terminatedByEOS
                    == raw.trainedTerminatedByEOS
                && entry.generated.terminationReason
                    == raw.trainedTerminationReason
                && entry.generated.utf8Valid
                    == raw.trainedUTF8Valid
                && entry.generated.eosLogProbability
                    == raw.trainedEOSLogProbability
                && entry.generated
                    .rawFullVocabularyAllowedSupportGreedyTokenParity
                    == raw
                        .trainedRawFullVocabularyAllowedSupportGreedyTokenParity
                && entry.generated
                    .disallowedFullVocabularyArgmaxCount
                    == raw
                        .trainedDisallowedFullVocabularyArgmaxCount
                && entry.generated
                    .maximumDisallowedTokenProbabilityMass
                    == raw
                        .trainedMaximumDisallowedTokenProbabilityMass
                && entry.generated.latencySeconds
                    == raw.trainedLatencySeconds
        case "reloaded":
            return entry.generated.text == raw.trainedPrediction
                && entry.generated.tokenIDs
                    == raw.trainedPredictionTokenIDs
                && entry.generated.tokenLogProbabilities
                    == raw.trainedTokenLogProbabilities
                && entry.generated.meanLogProbability
                    == raw.trainedMeanLogProbability
                && entry.generated.terminatedByEOS
                    == raw.trainedTerminatedByEOS
                && entry.generated.terminationReason
                    == raw.trainedTerminationReason
                && entry.generated.utf8Valid
                    == raw.trainedUTF8Valid
                && entry.generated.eosLogProbability
                    == raw.trainedEOSLogProbability
                && entry.generated
                    .rawFullVocabularyAllowedSupportGreedyTokenParity
                    == raw
                        .trainedRawFullVocabularyAllowedSupportGreedyTokenParity
                && entry.generated
                    .disallowedFullVocabularyArgmaxCount
                    == raw
                        .trainedDisallowedFullVocabularyArgmaxCount
                && entry.generated
                    .maximumDisallowedTokenProbabilityMass
                    == raw
                        .trainedMaximumDisallowedTokenProbabilityMass
        default:
            return false
        }
    }

    private static func supportAssistanceWitnessValid(
        parity: Bool,
        disallowedArgmaxCount: Int,
        maximumDisallowedProbabilityMass: Double,
        decisionsExecuted: Int
    ) -> Bool {
        disallowedArgmaxCount >= 0
            && disallowedArgmaxCount <= decisionsExecuted
            && parity == (disallowedArgmaxCount == 0)
            && maximumDisallowedProbabilityMass.isFinite
            && maximumDisallowedProbabilityMass >= 0
            && maximumDisallowedProbabilityMass <= 1.000_001
    }

    private static func foundationCorpusRegrade(
        reports: [ErgenticsNativeLanguageCanary.Report],
        tokenizer: PrimeNativeByteTokenizer.Manifest?,
        corpus: ErgenticsPrimeNativeTextCorpus.Manifest?
    ) -> Bool {
        guard let tokenizer, let corpus else { return false }
        // All immutable authority indexes below are generated from this exact
        // corpus object graph. Never reuse them across a manifest boundary.
        guard corpus.manifestSHA256
                == authorityCorpusManifestSHA256
        else {
            return false
        }
        do {
            try PrimeNativeByteTokenizer.verify(tokenizer)
            try ErgenticsPrimeNativeTextCorpus.verify(corpus)
        } catch {
            return false
        }
        guard corpus.leakageEvidence
                .trainEvaluationPromptOverlapCount == 0,
              corpus.leakageEvidence
                .trainEvaluationSemanticOverlapCount == 0,
              corpus.leakageEvidence
                .refusalTrainEvaluationPromptOverlapCount == 0,
              corpus.leakageEvidence
                .refusalTrainEvaluationSemanticOverlapCount == 0,
              corpus.leakageEvidence
                .refusalTrainAbstentionContractOverlapCount == 0,
              corpus.leakageEvidence
                .trainCombinationPairOverlapCount == 0,
              corpus.leakageEvidence.exactLookupEvaluationHits == 0,
              corpus.leakageEvidence.allRowIDsUnique,
              corpus.leakageEvidence.allRowHashesUnique,
              corpus.leakageEvidence
                .allValidSemanticsDisjointAcrossSplits,
              refusalCurriculumRegrade(corpus),
              reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count
        else {
            return false
        }

        var baselineCorpusRows: [String: CorpusProjection]?
        for report in reports {
            guard report.tokenizer.tokenizerID
                    == tokenizer.tokenizerID,
                  report.tokenizer.manifestSHA256
                    == tokenizer.manifestSHA256,
                  report.tokenizer.vocabularySize
                    == tokenizer.boundModelVocabularySize,
                  report.tokenizer.deterministicReplayPassed,
                  report.tokenizer
                    .independentFoundationReplayPassed,
                  report.corpus.corpusID == corpus.corpusID,
                  report.corpus.manifestSHA256
                    == corpus.manifestSHA256,
                  report.corpus.firstPartyRightsBound,
                  report.corpus.exactObjectHashesPresent,
                  report.corpus.disjointSplitsVerified,
                  trainingRowCountsValid(
                      total: report.corpus.trainingRowCount,
                      valid:
                        report.corpus.validTrainingRowCount,
                      refusal:
                        report.corpus.refusalTrainingRowCount
                  ),
                  report.corpus.generationContextLength
                    == report.profile.maximumSequenceLength,
                  report.corpus
                    .insufficientGenerationContextRowIDs.isEmpty,
                  report.corpus.expectedEvaluationRows
                    == requiredEvaluationRows
            else {
                return false
            }
            let rows = report.rawPredictions
            let maximumTargetTokenCount =
                rows.map(\.targetTokenIDs.count).max() ?? 0
            let overCapTargetRowIDs = rows.filter {
                $0.targetTokenIDs.count + 1
                    > ErgenticsNativeLanguageCanary
                        .maximumGenerationTokenDecisions
            }.map(\.rowID).sorted()
            guard Set(rows.map(\.rowID)).count == rows.count,
                  rows.count
                    == requiredEvaluationRows.values.reduce(0, +),
                  report.corpus
                    .maximumEvaluationPromptTokenCount
                    == rows.map(\.promptTokenIDs.count).max(),
                  report.corpus
                    .maximumEvaluationTargetTokenCount
                    == maximumTargetTokenCount,
                  report.corpus.overCapTargetRowIDs
                    == overCapTargetRowIDs,
                  report.corpus.overCapTargetRowIDs.isEmpty,
                  maximumTargetTokenCount + 1
                    <= ErgenticsNativeLanguageCanary
                        .maximumGenerationTokenDecisions,
                  rows.allSatisfy({
                      $0.promptTokenIDs.count
                          + ErgenticsNativeLanguageCanary
                              .maximumGenerationTokenDecisions
                          <= report.corpus
                              .generationContextLength
                  })
            else {
                return false
            }
            let duplicateKeyCount = Set(
                rows.map {
                    "\($0.prompt.utf8.count):\($0.prompt)"
                        + "|\($0.target.utf8.count):\($0.target)"
                }
            ).count
            guard duplicateKeyCount == rows.count else {
                return false
            }
            for split in ErgenticsNativeLanguageCanary.Split
                .allCases
            {
                guard rows.filter({ $0.split == split }).count
                        == requiredEvaluationRows[split]
                else { return false }
            }
            let familySet = Set(rows.map(\.semanticFamily))
            guard familySet
                    == Set(
                        ErgenticsPrimeNativeTextCorpus.SemanticFamily
                            .allCases.map(\.rawValue)
                    )
            else {
                return false
            }
            for row in rows {
                let promptIDs = [
                    PrimeNativeByteTokenizer
                        .beginningOfSequenceTokenID
                ] + PrimeNativeByteTokenizer
                    .encodeWithFoundationData(row.prompt)
                let targetIDs =
                    PrimeNativeByteTokenizer
                        .encodeWithFoundationData(row.target)
                guard promptIDs == row.promptTokenIDs,
                      targetIDs == row.targetTokenIDs,
                      targetIDs.count + 1
                        <= ErgenticsNativeLanguageCanary
                            .maximumGenerationTokenDecisions,
                      (
                          try? PrimeNativeByteTokenizer
                              .decodeWithFoundationData(targetIDs)
                      ) == row.target,
                      evaluationRowSHA256(row)
                        == row.evaluationRowSHA256,
                      corpusRowMatchesAuthority(row),
                      report.corpus
                        .expectedEvaluationRowSHA256[row.rowID]
                        == row.corpusRowSHA256,
                      report.corpus
                        .expectedEvaluationContractSHA256[row.rowID]
                        == row.evaluationRowSHA256
                else {
                    return false
                }
            }
            guard report.corpus.expectedEvaluationRowSHA256.count
                    == rows.count else {
                return false
            }
            let projection = Dictionary(
                uniqueKeysWithValues: rows.map {
                    (
                        $0.rowID,
                        CorpusProjection(
                            split: $0.split.rawValue,
                            semanticFamily: $0.semanticFamily,
                            prompt: $0.prompt,
                            mutationID: $0.mutationID,
                            target: $0.target
                        )
                    )
                }
            )
            if let baselineCorpusRows {
                guard baselineCorpusRows == projection else {
                    return false
                }
            } else {
                baselineCorpusRows = projection
            }
        }
        return true
    }

    private static func refusalCurriculumRegrade(
        _ corpus: ErgenticsPrimeNativeTextCorpus.Manifest
    ) -> Bool {
        let evidence = corpus.refusalCurriculumEvidence
        guard let training =
                independentRefusalPoolBySplit[
                    ErgenticsPrimeNativeTextCorpus.Split
                        .refusalTrain.rawValue
                ],
              let tuning =
                independentRefusalPoolBySplit[
                    ErgenticsPrimeNativeTextCorpus.Split
                        .refusalValidation.rawValue
                ],
              let final =
                independentRefusalPoolBySplit[
                    ErgenticsPrimeNativeTextCorpus.Split
                        .abstention.rawValue
                ]
        else {
            return false
        }
        func reasonCounts(
            _ values: [
                ErgenticsPrimeNativeTextCorpus.CoverageCount
            ]
        ) -> [String: Int]? {
            guard Set(values.map(\.id)).count == values.count
            else { return nil }
            return Dictionary(
                uniqueKeysWithValues:
                    values.map { ($0.id, $0.rowCount) }
            )
        }
        func contractCounts(
            _ values: [
                ErgenticsPrimeNativeTextCorpus
                    .RefusalContractCount
            ]
        ) -> [String: Int]? {
            let pairs = values.map {
                (
                    [
                        $0.abstentionReason,
                        $0.mutationID,
                        $0.surfaceFormID,
                    ].joined(separator: "|"),
                    $0.rowCount
                )
            }
            guard Set(pairs.map(\.0)).count == pairs.count
            else { return nil }
            return Dictionary(uniqueKeysWithValues: pairs)
        }
        let reasonSets = [
            Set(training.reasonCounts.keys),
            Set(tuning.reasonCounts.keys),
            Set(final.reasonCounts.keys),
        ]
        let trainingTuningPromptOverlap =
            training.promptSet.intersection(tuning.promptSet).count
        let trainingFinalPromptOverlap =
            training.promptSet.intersection(final.promptSet).count
        let tuningFinalPromptOverlap =
            tuning.promptSet.intersection(final.promptSet).count
        let trainingTuningSemanticOverlap =
            training.semanticSet.intersection(tuning.semanticSet)
            .count
        let trainingFinalSemanticOverlap =
            training.semanticSet.intersection(final.semanticSet)
            .count
        let tuningFinalSemanticOverlap =
            tuning.semanticSet.intersection(final.semanticSet)
            .count
        let trainingTuningContractOverlap =
            training.contractSet.intersection(tuning.contractSet)
            .count
        let trainingFinalContractOverlap =
            training.contractSet.intersection(final.contractSet)
            .count
        let tuningFinalContractOverlap =
            tuning.contractSet.intersection(final.contractSet)
            .count

        return training.materialsValid
            && tuning.materialsValid
            && final.materialsValid
            && training.rowCount
                == ErgenticsPrimeNativeTextCorpus
                    .rowCounts[.refusalTrain]
            && tuning.rowCount
                == ErgenticsPrimeNativeTextCorpus
                    .rowCounts[.refusalValidation]
            && final.rowCount
                == ErgenticsPrimeNativeTextCorpus
                    .rowCounts[.abstention]
            && reasonSets.allSatisfy { $0.count == 7 }
            && reasonSets[0] == reasonSets[1]
            && reasonSets[0] == reasonSets[2]
            && evidence.trainingSplit == training.split
            && evidence.tuningSplit == tuning.split
            && evidence.finalEvaluationSplit == final.split
            && evidence.trainingRowCount == training.rowCount
            && evidence.tuningRowCount == tuning.rowCount
            && evidence.finalEvaluationRowCount == final.rowCount
            && reasonCounts(evidence.trainingReasonCounts)
                == training.reasonCounts
            && reasonCounts(evidence.tuningReasonCounts)
                == tuning.reasonCounts
            && reasonCounts(evidence.finalEvaluationReasonCounts)
                == final.reasonCounts
            && contractCounts(evidence.trainingContractCounts)
                == training.contractCounts
            && contractCounts(evidence.tuningContractCounts)
                == tuning.contractCounts
            && contractCounts(
                evidence.finalEvaluationContractCounts
            ) == final.contractCounts
            && evidence.trainingPromptSetSHA256
                == training.promptSetSHA256
            && evidence.tuningPromptSetSHA256
                == tuning.promptSetSHA256
            && evidence.finalEvaluationPromptSetSHA256
                == final.promptSetSHA256
            && evidence.trainingSemanticSetSHA256
                == training.semanticSetSHA256
            && evidence.tuningSemanticSetSHA256
                == tuning.semanticSetSHA256
            && evidence.finalEvaluationSemanticSetSHA256
                == final.semanticSetSHA256
            && evidence.trainingIndependentRegradeSHA256
                == training.independentRegradeSHA256
            && evidence.tuningIndependentRegradeSHA256
                == tuning.independentRegradeSHA256
            && evidence.finalEvaluationIndependentRegradeSHA256
                == final.independentRegradeSHA256
            && evidence.trainingTuningPromptOverlapCount
                == trainingTuningPromptOverlap
            && evidence.trainingFinalEvaluationPromptOverlapCount
                == trainingFinalPromptOverlap
            && evidence.tuningFinalEvaluationPromptOverlapCount
                == tuningFinalPromptOverlap
            && evidence.trainingTuningSemanticOverlapCount
                == trainingTuningSemanticOverlap
            && evidence.trainingFinalEvaluationSemanticOverlapCount
                == trainingFinalSemanticOverlap
            && evidence.tuningFinalEvaluationSemanticOverlapCount
                == tuningFinalSemanticOverlap
            && evidence
                .trainingTuningMutationContractOverlapCount
                == trainingTuningContractOverlap
            && evidence
                .trainingFinalEvaluationMutationContractOverlapCount
                == trainingFinalContractOverlap
            && evidence
                .tuningFinalEvaluationMutationContractOverlapCount
                == tuningFinalContractOverlap
            && trainingTuningPromptOverlap == 0
            && trainingFinalPromptOverlap == 0
            && tuningFinalPromptOverlap == 0
            && trainingTuningSemanticOverlap == 0
            && trainingFinalSemanticOverlap == 0
            && tuningFinalSemanticOverlap == 0
            && trainingTuningContractOverlap == 0
            && trainingFinalContractOverlap == 0
            && tuningFinalContractOverlap == 0
            && evidence
                .allReasonsTaughtBeforeTuningAndEvaluation
            && evidence
                .allTuningAndEvaluationContractsHeldOut
            && evidence.allRowsIndependentlyVerified
    }

    private static func rawExecutorRegrade(
        _ reports: [ErgenticsNativeLanguageCanary.Report]
    ) -> Bool {
        guard reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count
        else { return false }
        for report in reports {
            guard report.generationContractID
                    == ErgenticsNativeLanguageCanary
                        .generationContractID
            else {
                return false
            }
            for row in report.rawPredictions {
                guard let authority =
                    authoritativeRowsByID[row.rowID]
                else { return false }
                let zeroRegrade = predictionRegrade(
                    tokenIDs: row.zeroShotPredictionTokenIDs,
                    terminatedByEOS:
                        row.zeroShotTerminatedByEOS,
                    authority: authority
                )
                let trainedRegrade = predictionRegrade(
                    tokenIDs: row.trainedPredictionTokenIDs,
                    terminatedByEOS:
                        row.trainedTerminatedByEOS,
                    authority: authority
                )
                guard generationMechanicsValid(
                          tokenIDs:
                            row.zeroShotPredictionTokenIDs,
                          tokenLogProbabilities:
                            row.zeroShotTokenLogProbabilities,
                          meanLogProbability:
                            row.zeroShotMeanLogProbability,
                          terminatedByEOS:
                            row.zeroShotTerminatedByEOS,
                          terminationReason:
                            row.zeroShotTerminationReason,
                          eosLogProbability:
                            row.zeroShotEOSLogProbability,
                          latencySeconds:
                            row.zeroShotLatencySeconds
                      ),
                      generationMechanicsValid(
                          tokenIDs:
                            row.trainedPredictionTokenIDs,
                          tokenLogProbabilities:
                            row.trainedTokenLogProbabilities,
                          meanLogProbability:
                            row.trainedMeanLogProbability,
                          terminatedByEOS:
                            row.trainedTerminatedByEOS,
                          terminationReason:
                            row.trainedTerminationReason,
                          eosLogProbability:
                            row.trainedEOSLogProbability,
                          latencySeconds:
                            row.trainedLatencySeconds
                      ),
                      supportAssistanceWitnessValid(
                          parity:
                            row
                                .zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity,
                          disallowedArgmaxCount:
                            row
                                .zeroShotDisallowedFullVocabularyArgmaxCount,
                          maximumDisallowedProbabilityMass:
                            row
                                .zeroShotMaximumDisallowedTokenProbabilityMass,
                          decisionsExecuted:
                            row.zeroShotDecisionsExecuted
                      ),
                      supportAssistanceWitnessValid(
                          parity:
                            row
                                .trainedRawFullVocabularyAllowedSupportGreedyTokenParity,
                          disallowedArgmaxCount:
                            row
                                .trainedDisallowedFullVocabularyArgmaxCount,
                          maximumDisallowedProbabilityMass:
                            row
                                .trainedMaximumDisallowedTokenProbabilityMass,
                          decisionsExecuted:
                            row.trainedDecisionsExecuted
                      ),
                      row.promptTokenIDs
                        == [
                            PrimeNativeByteTokenizer
                                .beginningOfSequenceTokenID
                        ] + PrimeNativeByteTokenizer.encode(
                            row.prompt
                        ),
                      row.promptGroupingKeyID
                        == independentPromptGroupingKeyID,
                      row.promptGroupingKey
                        == row.promptTokenIDs.count - 1,
                      row.generationDecisionBudget
                        == independentGenerationDecisionBudget,
                      row.allowedCompletionTokenSetSHA256
                        == independentAllowedCompletionTokenSetSHA256,
                      row.eosAvailableAtEveryDecision,
                      row.targetIndependentDecisionBudget,
                      row.targetTokenIDs
                        == PrimeNativeByteTokenizer.encode(
                            row.target
                        ),
                      row.targetTokenIDs.count + 1
                        <= independentGenerationDecisionBudget,
                      row.zeroShotDecisionsExecuted
                        == row.zeroShotPredictionTokenIDs.count
                            + (
                                row.zeroShotTerminatedByEOS
                                    ? 1 : 0
                            ),
                      row.zeroShotDecisionsExecuted
                        <= row.generationDecisionBudget,
                      row.trainedDecisionsExecuted
                        == row.trainedPredictionTokenIDs.count
                            + (
                                row.trainedTerminatedByEOS
                                    ? 1 : 0
                            ),
                      row.trainedDecisionsExecuted
                        <= row.generationDecisionBudget,
                      zeroRegrade.text
                        == row.zeroShotPrediction,
                      zeroRegrade.utf8Valid
                        == row.zeroShotUTF8Valid,
                      trainedRegrade.text
                        == row.trainedPrediction,
                      trainedRegrade.utf8Valid
                        == row.trainedUTF8Valid,
                      row.zeroShotExactMatch
                        == zeroRegrade.exact,
                      row.trainedExactMatch
                        == trainedRegrade.exact,
                      row.zeroShotSemanticVerifierPass
                        == zeroRegrade.semantic,
                      row.trainedSemanticVerifierPass
                        == trainedRegrade.semantic,
                      row.zeroShotAbstentionDecision
                        == zeroRegrade.abstention,
                      row.trainedAbstentionDecision
                        == trainedRegrade.abstention,
                      evaluationRowSHA256(row)
                        == row.evaluationRowSHA256,
                      corpusRowMatchesAuthority(row)
                else {
                    return false
                }
            }
        }
        return true
    }

    /// Internal for an independent regression of the executed-decision mean.
    /// The production regrade and the test both use this exact contract.
    static func generationMechanicsValid(
        tokenIDs: [Int],
        tokenLogProbabilities: [Double],
        meanLogProbability: Double,
        terminatedByEOS: Bool,
        terminationReason: String,
        eosLogProbability: Double?,
        latencySeconds: Double
    ) -> Bool {
        let maximum =
            ErgenticsNativeLanguageCanary
                .maximumGenerationTokenDecisions
        guard tokenIDs.allSatisfy({
                  PrimeNativeByteTokenizer.byteTokenRange
                    .contains($0)
              }),
              tokenLogProbabilities.count == tokenIDs.count,
              tokenLogProbabilities.allSatisfy(\.isFinite),
              meanLogProbability.isFinite,
              latencySeconds.isFinite,
              latencySeconds > 0
        else {
            return false
        }
        if terminatedByEOS {
            guard terminationReason == "eos",
                  tokenIDs.count + 1 <= maximum,
                  let eosLogProbability,
                  eosLogProbability.isFinite
            else {
                return false
            }
            let executedDecisionMean =
                (
                    tokenLogProbabilities.reduce(0, +)
                        + eosLogProbability
                ) / Double(tokenLogProbabilities.count + 1)
            return abs(
                meanLogProbability - executedDecisionMean
            ) <= 1e-12
        }
        guard terminationReason == "fixed_cap",
              tokenIDs.count == maximum,
              eosLogProbability == nil
        else {
            return false
        }
        let executedDecisionMean =
            tokenLogProbabilities.reduce(0, +)
                / Double(tokenLogProbabilities.count)
        return abs(
            meanLogProbability - executedDecisionMean
        ) <= 1e-12
    }

    private static func predictionRegrade(
        tokenIDs: [Int],
        terminatedByEOS: Bool,
        authority: ErgenticsPrimeNativeTextCorpus.Row
    ) -> PredictionRegrade {
        guard tokenIDs.allSatisfy({
            PrimeNativeByteTokenizer.byteTokenRange.contains($0)
        }) else {
            return PredictionRegrade(
                text: nil,
                utf8Valid: false,
                exact: false,
                semantic: false,
                abstention: false
            )
        }
        let bytes = tokenIDs.map {
            UInt8($0 - PrimeNativeByteTokenizer.byteTokenBase)
        }
        let text = String(data: Data(bytes), encoding: .utf8)
        guard terminatedByEOS, let text else {
            return PredictionRegrade(
                text: text,
                utf8Valid: text != nil,
                exact: false,
                semantic: false,
                abstention: false
            )
        }
        let verification =
            ErgenticsPrimeNativeTextCorpus
            .verifyGeneratedCompletion(
                row: authority,
                completion: text
            )
        return PredictionRegrade(
            text: text,
            utf8Valid: true,
            exact:
                tokenIDs
                    == PrimeNativeByteTokenizer.encode(
                        authority.expectedCompletion
                    )
                    && verification.exactMatch,
            semantic: verification.semanticMatch,
            abstention: verification.abstentionDecision
        )
    }

    private static func causalMechanicsValid(
        _ reports: [ErgenticsNativeLanguageCanary.Report]
    ) -> Bool {
        guard reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count
        else { return false }
        return reports.allSatisfy { report in
            guard independentTrainingEvidenceValid(report)
            else {
                return false
            }
            let byID = Dictionary(
                uniqueKeysWithValues:
                    ErgenticsNativeLanguageCanary.recommend(report)
                        .legs.map { ($0.id, $0.pass) }
            )
            return byID[
                "N5_swift_mlx_metal_maintained_primitives"
            ] == true
                && byID[
                    "N6_shifted_masked_finite_learning_step"
                ] == true
                && report.training
                    .targetTokenWeightedEffectiveBatchLoss
                && report.training.effectiveBatchSize
                    == report.training.batchSize
                        * report.training
                            .gradientAccumulationSteps
                && report.training
                    .processedPaddedTokenPositions
                    == report.training.requestedSteps
                        * report.training.effectiveBatchSize
                        * report.training.measuredSequenceLength
                && report.training
                    .plannedTrainingTokenPresentations
                    == report.training
                        .processedPaddedTokenPositions
                && report.training.firstClippedGradientNorm > 0
                && report.training.firstClippedGradientNorm
                    <= report.training.firstGradientNorm
                && report.training
                    .cachedUncachedMaximumLogitDelta == 0
                && report.training
                    .cachedUncachedGreedyTokenParity
                && report.training
                    .cachedUncachedMultiStepMaximumLogitDelta
                    .isFinite
                && report.training
                    .cachedUncachedMultiStepMaximumLogitDelta
                    >= 0
                && report.training
                    .cachedUncachedMultiStepMaximumLogitDelta
                    <= 1e-4
                && report.training
                    .cachedUncachedMultiStepGreedyTokenParity
                && report.training
                    .cachedUncachedMultiStepComparedDecisionCount
                    == 6
                && report.training
                    .cachedUncachedMultiStepUnevenEOS
                && trainingLossTraceValid(
                    report.training.losses,
                    completedSteps:
                        report.training.completedSteps
                )
        }
    }

    private static func independentTrainingEvidenceValid(
        _ report: ErgenticsNativeLanguageCanary.Report
    ) -> Bool {
        let training = report.training
        guard isSHA256(training.comparisonManifestSHA256),
              training.probePurposeID
                == "bounded_full_diagnostic_v1",
              training.scheduleID
                == "manifest_sha256_curriculum_240_valid_48_refusal_epoch_reason_stratified_v3",
              training.requestedSteps > 0,
              training.requestedSteps % 36 == 0,
              training.requestedSteps <= 216,
              training.completedSteps == training.requestedSteps,
              trainingLossTraceValid(
                  training.losses,
                  completedSteps: training.completedSteps
              ),
              training.batchSize == 2,
              training.gradientAccumulationSteps == 4,
              training.effectiveBatchSize == 8,
              training.measuredSequenceLength == 512,
              training.distinctScheduledRowCount
                == training.requestedSteps
                    * training.effectiveBatchSize,
              training.distinctScheduledRowCount % 288 == 0,
              training.scheduledValidRowCount
                == training.distinctScheduledRowCount / 288 * 240,
              training.scheduledRefusalRowCount
                == training.distinctScheduledRowCount / 288 * 48,
              Set(training.scheduledRefusalReasonRows.keys)
                == Set(
                    ErgenticsPrimeNativeTextCorpus
                        .refusalReasonIDs
                ),
              training.scheduledRefusalReasonRows.values
                .allSatisfy({ $0 > 0 }),
              training.scheduledRefusalReasonRows.values
                .reduce(0, +)
                == training.scheduledRefusalRowCount,
              isSHA256(
                  training
                    .scheduledRefusalReasonScheduleSHA256
              ),
              training.scheduledValidRowCount
                    + training.scheduledRefusalRowCount
                == training.distinctScheduledRowCount,
              training.heldoutRowCount == 288,
              training.heldoutValidRowCount == 240,
              training.heldoutRefusalRowCount == 48,
              Set(training.heldoutRefusalReasonRows.keys)
                == Set(
                    ErgenticsPrimeNativeTextCorpus
                        .refusalReasonIDs
                ),
              training.heldoutRefusalReasonRows.values
                .allSatisfy({ $0 > 0 }),
              training.heldoutRefusalReasonRows.values
                .reduce(0, +)
                == training.heldoutRefusalRowCount,
              isSHA256(
                  training.heldoutRefusalReasonScheduleSHA256
              ),
              training.heldoutValidRowCount
                    + training.heldoutRefusalRowCount
                == training.heldoutRowCount,
              training.selectionValidationSplitIDs
                == [
                    ErgenticsPrimeNativeTextCorpus.Split
                        .validation.rawValue,
                    ErgenticsPrimeNativeTextCorpus.Split
                        .refusalValidation.rawValue,
                ],
              training.trainingScheduleManifestSHA256
                == report.corpus.probeTokenManifestSHA256,
              training.optimizerImplementation
                == report.implementation.optimizerImplementation,
              training.optimizerImplementation
                == "MLXOptimizers.AdamW",
              training.adamBeta1 == 0.9,
              training.adamBeta2 == 0.999,
              training.adamEpsilon == 1e-8,
              training.decoupledWeightDecay,
              training.gradientClipMode
                == "global_l2_norm_pre_optimizer_step",
              training.lossReduction
                == "mean_target_token_cross_entropy",
              training.hyperparameterSearchID
                == ErgenticsNativeScaleEngineRecommend
                    .adaptiveSearchID,
              training.learningRateDiscoverySeed
                == ErgenticsNativeScaleEngineRecommend
                    .discoverySeed,
              training.declaredLearningRateGrid
                == ErgenticsNativeScaleEngineRecommend
                    .discoveryLearningRates,
              training.declaredReplicateSeeds
                == ErgenticsNativeScaleEngineRecommend
                    .adaptiveSeeds,
              training.declaredLearningRateGrid.contains(
                training.learningRate
              ),
              isSHA256(training.replicateID),
              training.replicateID == sha256(
                Data(
                    [
                        training.hyperparameterSearchID,
                        report.profile.profileID,
                        training.probePurposeID,
                        String(training.learningRate.bitPattern),
                        String(report.seed),
                    ].joined(separator: "|").utf8
                )
              ),
              training.coldStartElapsedSeconds.isFinite,
              training.coldStartElapsedSeconds > 0,
              training.coldStartElapsedSeconds
                <= training.elapsedSeconds,
              training
                .declaredMaximumExecutorWallSeconds.isFinite,
              training.declaredMaximumExecutorWallSeconds > 0,
              training
                .measuredTotalExecutorWallSeconds.isFinite,
              training.measuredTotalExecutorWallSeconds > 0,
              training.measuredTotalExecutorWallSeconds
                <= training.declaredMaximumExecutorWallSeconds,
              training.measuredTotalExecutorWallSeconds
                >= training.elapsedSeconds,
              freshExecutorWallEvidenceValid(
                    mode: report.mode,
                    accountingID:
                        training.executorWallAccountingID,
                    resumedFromTrainingStage:
                        training.resumedFromTrainingStage,
                    priorExecutorWallSeconds:
                        training.priorExecutorWallSeconds,
                    checkpointStageExecutorWallSeconds:
                        training
                            .checkpointStageExecutorWallSeconds,
                    measuredTotalExecutorWallSeconds:
                        training
                            .measuredTotalExecutorWallSeconds,
                    declaredMaximumExecutorWallSeconds:
                        training
                            .declaredMaximumExecutorWallSeconds,
                    preexistingEvaluationArtifactNames:
                        training
                            .preexistingEvaluationArtifactNamesAtInvocationStart
                ),
              training.heldoutEvaluationElapsedSeconds.isFinite,
              training.heldoutEvaluationElapsedSeconds > 0,
              training.heldoutCrossEntropyBefore.isFinite,
              training.heldoutCrossEntropyBefore > 0,
              training.heldoutCrossEntropyAfter.isFinite,
              training.heldoutCrossEntropyAfter >= 0,
              training.heldoutCrossEntropyAfter
                < training.heldoutCrossEntropyBefore,
              training.heldoutValidCrossEntropyBefore.isFinite,
              training.heldoutValidCrossEntropyBefore > 0,
              training.heldoutValidCrossEntropyAfter.isFinite,
              training.heldoutValidCrossEntropyAfter >= 0,
              training.heldoutValidCrossEntropyAfter
                < training.heldoutValidCrossEntropyBefore,
              training.heldoutRefusalCrossEntropyBefore.isFinite,
              training.heldoutRefusalCrossEntropyBefore > 0,
              training.heldoutRefusalCrossEntropyAfter.isFinite,
              training.heldoutRefusalCrossEntropyAfter >= 0,
              training.heldoutRefusalCrossEntropyAfter
                < training.heldoutRefusalCrossEntropyBefore,
              training.heldoutCrossEntropyStandardError.isFinite,
              training.heldoutCrossEntropyStandardError >= 0,
              training.heldoutCrossEntropyStandardErrorMethodID
                == "target_token_weighted_row_unbiased_effective_n_v1"
        else {
            return false
        }

        let fittingValidRows = authoritativeTrainingRows.filter {
            $0.sequenceTokenCount
                <= training.measuredSequenceLength
        }
        let fittingRefusalRows =
            authoritativeRefusalTrainingRows.filter {
                $0.sequenceTokenCount
                    <= training.measuredSequenceLength
            }
        let scheduledValidIDs =
            ErgenticsNativeLanguageCanary
            .deterministicBalancedScheduleRowIDs(
                rows: fittingValidRows,
                seed: report.seed,
                count: training.scheduledValidRowCount,
                namespace: "balanced_valid_train_v1",
                corpusManifestSHA256:
                    report.corpus.manifestSHA256
            )
        guard let scheduledRefusalWitness =
            ErgenticsNativeLanguageCanary
            .deterministicRefusalReasonSchedule(
                rows: fittingRefusalRows,
                seed: report.seed,
                blockCount:
                    training.scheduledRefusalRowCount / 48,
                namespace:
                    "balanced_refusal_reason_stratified_train_v2",
                corpusManifestSHA256:
                    report.corpus.manifestSHA256
            )
        else {
            return false
        }
        let scheduledRefusalIDs =
            scheduledRefusalWitness.rowIDs
        guard let scheduledIDs = interleavedFiveToOneRowIDs(
            valid: scheduledValidIDs,
            refusal: scheduledRefusalIDs
        ) else {
            return false
        }
        let heldoutValidRows =
            authoritativeSelectionRowsByID.values.filter {
                $0.split
                    == ErgenticsPrimeNativeTextCorpus.Split
                        .validation.rawValue
                    && $0.sequenceTokenCount
                        <= training.measuredSequenceLength
            }
        let heldoutRefusalRows =
            authoritativeSelectionRowsByID.values.filter {
                $0.split
                    == ErgenticsPrimeNativeTextCorpus.Split
                        .refusalValidation.rawValue
                    && $0.sequenceTokenCount
                        <= training.measuredSequenceLength
            }
        let heldoutValidIDs =
            ErgenticsNativeLanguageCanary
            .deterministicBalancedScheduleRowIDs(
                rows: Array(heldoutValidRows),
                seed: report.seed,
                count: training.heldoutValidRowCount,
                namespace: "balanced_valid_selection_v1",
                corpusManifestSHA256:
                    report.corpus.manifestSHA256
            )
        guard let heldoutRefusalWitness =
            ErgenticsNativeLanguageCanary
            .deterministicRefusalReasonSchedule(
                rows: Array(heldoutRefusalRows),
                seed: report.seed,
                blockCount: 1,
                namespace:
                    "balanced_refusal_reason_stratified_selection_v2",
                corpusManifestSHA256:
                    report.corpus.manifestSHA256
            )
        else {
            return false
        }
        let heldoutRefusalIDs =
            heldoutRefusalWitness.rowIDs
        guard let heldoutIDs = interleavedFiveToOneRowIDs(
            valid: heldoutValidIDs,
            refusal: heldoutRefusalIDs
        ) else {
            return false
        }
        let heldoutIDSet = Set(heldoutIDs)
        guard heldoutIDs.count == training.heldoutRowCount,
              heldoutIDSet.count == heldoutIDs.count,
              Set(scheduledIDs).isDisjoint(with: heldoutIDSet),
              training.scheduledRefusalReasonRows
                == scheduledRefusalWitness.reasonRowCounts,
              training.scheduledRefusalReasonScheduleSHA256
                == scheduledRefusalWitness
                    .orderedReasonScheduleSHA256,
              training.heldoutRefusalReasonRows
                == heldoutRefusalWitness.reasonRowCounts,
              training.heldoutRefusalReasonScheduleSHA256
                == heldoutRefusalWitness
                    .orderedReasonScheduleSHA256,
              training.heldoutScheduleSHA256 == sha256(
                Data(heldoutIDs.joined(separator: "\n").utf8)
              ),
              training.heldoutLossRows.count
                == training.heldoutRowCount,
              Set(training.heldoutLossRows.map(\.rowID))
                == heldoutIDSet,
              Set(training.heldoutLossRows.map(\.rowSHA256))
                .count == training.heldoutRowCount
        else {
            return false
        }

        let trainingRowsByID = Dictionary(
            uniqueKeysWithValues:
                (
                    authoritativeTrainingRows
                        + authoritativeRefusalTrainingRows
                ).map {
                    ($0.rowID, $0)
                }
        )
        guard scheduledIDs.allSatisfy({
            trainingRowsByID[$0] != nil
        }) else {
            return false
        }
        let scheduledHashes = Set(
            scheduledIDs.map {
                trainingRowsByID[$0]!.rowSHA256
            }
        )
        let heldoutHashes = Set(
            training.heldoutLossRows.map(\.rowSHA256)
        )
        guard scheduledHashes.intersection(heldoutHashes).count
                == training
                    .trainingHeldoutRowHashIntersectionCount,
              training.trainingHeldoutRowHashIntersectionCount
                == 0
        else {
            return false
        }

        let requiredFamilies =
            ErgenticsNativeScaleEngineRecommend
                .requiredSemanticFamilyIDs
        let blockCount = training.distinctScheduledRowCount / 288
        let scheduledValidFamilies = Dictionary(
            grouping: scheduledValidIDs.map {
                trainingRowsByID[$0]!
            },
            by: \.semanticFamily
        ).mapValues(\.count)
        let scheduledRefusalFamilies = Dictionary(
            grouping: scheduledRefusalIDs.map {
                trainingRowsByID[$0]!
            },
            by: \.semanticFamily
        ).mapValues(\.count)
        let scheduledFamilies = Dictionary(
            grouping: scheduledIDs.map {
                trainingRowsByID[$0]!
            },
            by: \.semanticFamily
        ).mapValues(\.count)
        guard Set(scheduledValidFamilies.keys) == requiredFamilies,
              Set(scheduledRefusalFamilies.keys)
                == requiredFamilies,
              scheduledValidFamilies.values.allSatisfy({
                  $0 == blockCount * 40
              }),
              scheduledRefusalFamilies.values.allSatisfy({
                  $0 == blockCount * 8
              }),
              scheduledFamilies.values.allSatisfy({
                  $0 == blockCount * 48
              }),
              training.scheduledValidSemanticFamilyRows
                == scheduledValidFamilies,
              training.scheduledRefusalSemanticFamilyRows
                == scheduledRefusalFamilies,
              training.scheduledSemanticFamilyRows
                == scheduledFamilies
        else {
            return false
        }
        let rows = training.heldoutLossRows
        let validRows = rows.filter {
            $0.targetClass == "valid_completion"
        }
        let refusalRows = rows.filter {
            $0.targetClass == "refusal_abstain"
        }
        let heldoutValidFamilies = Dictionary(
            grouping: validRows,
            by: \.semanticFamily
        ).mapValues(\.count)
        let heldoutRefusalFamilies = Dictionary(
            grouping: refusalRows,
            by: \.semanticFamily
        ).mapValues(\.count)
        guard validRows.count == 240,
              refusalRows.count == 48,
              Set(heldoutValidFamilies.keys) == requiredFamilies,
              Set(heldoutRefusalFamilies.keys) == requiredFamilies,
              heldoutValidFamilies.values.allSatisfy({
                  $0 == 40
              }),
              heldoutRefusalFamilies.values.allSatisfy({
                  $0 == 8
              }),
              training.heldoutValidSemanticFamilyRows
                == heldoutValidFamilies,
              training.heldoutRefusalSemanticFamilyRows
                == heldoutRefusalFamilies
        else {
            return false
        }
        guard rows.allSatisfy({ row in
            guard let authority =
                    authoritativeSelectionRowsByID[row.rowID]
            else {
                return false
            }
            let targetClass =
                authority.split
                    == ErgenticsPrimeNativeTextCorpus.Split
                        .refusalValidation.rawValue
                ? "refusal_abstain" : "valid_completion"
            let targetTokenCount =
                PrimeNativeByteTokenizer
                .encode(authority.expectedCompletion).count + 1
            return row.rowSHA256 == authority.rowSHA256
                && row.selectionSplitID == authority.split
                && row.targetClass == targetClass
                && row.semanticFamily
                    == authority.semanticFamily
                && requiredFamilies.contains(
                    row.semanticFamily
                )
                && row.targetTokenCount == targetTokenCount
                && row.nonPaddingTokenCount
                    == authority.sequenceTokenCount
                && row.nonPaddingTokenCount
                    > row.targetTokenCount
                && row.crossEntropyBefore.isFinite
                && row.crossEntropyBefore > 0
                && row.crossEntropyAfter.isFinite
                && row.crossEntropyAfter >= 0
        }) else {
            return false
        }

        let targetTokens =
            rows.map(\.targetTokenCount).reduce(0, +)
        let nonPadding =
            rows.map(\.nonPaddingTokenCount).reduce(0, +)
        let validTargetTokens =
            validRows.map(\.targetTokenCount).reduce(0, +)
        let refusalTargetTokens =
            refusalRows.map(\.targetTokenCount).reduce(0, +)
        guard targetTokens == training.heldoutTargetTokenCount,
              validTargetTokens
                == training.heldoutValidTargetTokenCount,
              refusalTargetTokens
                == training.heldoutRefusalTargetTokenCount,
              validTargetTokens + refusalTargetTokens
                == targetTokens,
              nonPadding * 2
                == training
                    .heldoutEvaluationNonPaddingTokenCount,
              targetTokens > 0
        else {
            return false
        }
        let totalWeight = Double(targetTokens)
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
            let weight = Double($1.targetTokenCount)
            return $0 + weight * weight
        }
        let effectiveRows =
            totalWeight * totalWeight / max(1, weightSquared)
        let denominator =
            totalWeight - weightSquared / max(1, totalWeight)
        let squaredDeviation = rows.reduce(0.0) {
            let delta = $1.crossEntropyAfter - after
            return $0
                + Double($1.targetTokenCount)
                    * delta * delta
        }
        let variance =
            denominator > 0
            ? squaredDeviation / denominator : 0
        let standardError =
            sqrt(variance / max(1, effectiveRows))
        let beforeByFamily = weightedLossByFamily(
            rows,
            keyPath: \.crossEntropyBefore
        )
        let afterByFamily = weightedLossByFamily(
            rows,
            keyPath: \.crossEntropyAfter
        )
        func weightedLoss(
            _ classRows:
                [ErgenticsNativeLanguageCanary.HeldoutLossRow],
            keyPath:
                KeyPath<
                    ErgenticsNativeLanguageCanary.HeldoutLossRow,
                    Double
                >
        ) -> Double {
            let tokens =
                classRows.map(\.targetTokenCount).reduce(0, +)
            return classRows.reduce(0.0) {
                $0
                    + $1[keyPath: keyPath]
                        * Double($1.targetTokenCount)
            } / Double(tokens)
        }
        let validBefore = weightedLoss(
            validRows,
            keyPath: \.crossEntropyBefore
        )
        let validAfter = weightedLoss(
            validRows,
            keyPath: \.crossEntropyAfter
        )
        let refusalBefore = weightedLoss(
            refusalRows,
            keyPath: \.crossEntropyBefore
        )
        let refusalAfter = weightedLoss(
            refusalRows,
            keyPath: \.crossEntropyAfter
        )
        return Set(beforeByFamily.keys) == requiredFamilies
            && Set(afterByFamily.keys) == requiredFamilies
            && Set(
                training.heldoutFamilyCrossEntropyBefore.keys
            ) == requiredFamilies
            && Set(
                training.heldoutFamilyCrossEntropyAfter.keys
            ) == requiredFamilies
            && requiredFamilies.allSatisfy { family in
                approximatelyEqual(
                    beforeByFamily[family]!,
                    training.heldoutFamilyCrossEntropyBefore[
                        family
                    ]!
                )
                    && approximatelyEqual(
                        afterByFamily[family]!,
                        training.heldoutFamilyCrossEntropyAfter[
                            family
                        ]!
                    )
            }
            && approximatelyEqual(
                before,
                training.heldoutCrossEntropyBefore
            )
            && approximatelyEqual(
                after,
                training.heldoutCrossEntropyAfter
            )
            && approximatelyEqual(
                standardError,
                training.heldoutCrossEntropyStandardError
            )
            && approximatelyEqual(
                validBefore,
                training.heldoutValidCrossEntropyBefore
            )
            && approximatelyEqual(
                validAfter,
                training.heldoutValidCrossEntropyAfter
            )
            && approximatelyEqual(
                refusalBefore,
                training.heldoutRefusalCrossEntropyBefore
            )
            && approximatelyEqual(
                refusalAfter,
                training.heldoutRefusalCrossEntropyAfter
            )
            && approximatelyEqual(
                training.initialLoss,
                before
            )
            && approximatelyEqual(
                training.finalLoss,
                after
            )
    }

    private static func weightedLossByFamily(
        _ rows: [ErgenticsNativeLanguageCanary.HeldoutLossRow],
        keyPath:
            KeyPath<
                ErgenticsNativeLanguageCanary.HeldoutLossRow,
                Double
            >
    ) -> [String: Double] {
        Dictionary(grouping: rows, by: \.semanticFamily)
            .mapValues { familyRows in
                let tokens = familyRows
                    .map(\.targetTokenCount).reduce(0, +)
                return familyRows.reduce(0.0) {
                    $0
                        + $1[keyPath: keyPath]
                            * Double($1.targetTokenCount)
                } / Double(tokens)
            }
    }

    private static func approximatelyEqual(
        _ left: Double,
        _ right: Double
    ) -> Bool {
        abs(left - right)
            <= max(1e-12, abs(right) * 1e-12)
    }

    private static func durabilityValid(
        _ reports: [ErgenticsNativeLanguageCanary.Report]
    ) -> Bool {
        guard reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count
        else { return false }
        return reports.allSatisfy { report in
            ErgenticsNativeLanguageCanary.recommend(report)
                .legs.first(where: {
                    $0.id == "N9_checkpoint_reload_and_replay"
                })?.pass == true
        }
    }

    private static func durablePhysicalArtifactsValid(
        reports: [ErgenticsNativeLanguageCanary.Report],
        packageResolvedBinding:
            ObservedPackageResolvedBinding?,
        checkpointBindingsBySeed:
            [Int: ObservedCheckpointBinding],
        metalLibraryBindingsBySeed:
            [Int: ObservedMetalLibraryBinding],
        trainingStageDataBySeed: [Int: Data]
    ) -> Bool {
        let seeds = Set(reports.map(\.seed))
        guard reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count,
              let packageResolvedBinding,
              packageResolvedBinding.fileName
                == packageResolvedArtifactFileName,
              isSHA256(packageResolvedBinding.sha256),
              packageResolvedBinding.byteCount > 0,
              isGitRevision(
                  packageResolvedBinding.mlxSwiftRevision
              ),
              packageResolvedBinding.mlxSwiftExamplesVersion
                == "2.29.1",
              Set(checkpointBindingsBySeed.keys) == seeds,
              Set(metalLibraryBindingsBySeed.keys) == seeds,
              Set(trainingStageDataBySeed.keys) == seeds
        else {
            return false
        }
        return reports.allSatisfy { report in
            guard let durability = report.durability,
                  report.implementation.buildConfiguration
                    == ErgenticsNativeLanguageCanary
                        .requiredBuildConfiguration,
                  report.implementation.precision
                    == ErgenticsNativeLanguageCanary
                        .requiredPrecision,
                  observedFP32ParameterDTypesValid(
                      modelParameterDTypes:
                        report.implementation
                            .observedModelParameterDTypes,
                      trainableParameterDTypes:
                        report.implementation
                            .observedTrainableParameterDTypes
                  ),
                  report.training.precision
                    == ErgenticsNativeLanguageCanary
                        .requiredPrecision,
                  durability.buildConfiguration
                    == ErgenticsNativeLanguageCanary
                        .requiredBuildConfiguration,
                  durability.buildConfiguration
                    == report.implementation.buildConfiguration,
                  durability.precision
                    == ErgenticsNativeLanguageCanary
                        .requiredPrecision,
                  durability.precision
                    == report.implementation.precision,
                  durability.precision
                    == report.training.precision,
                  observedFP32ParameterDTypesValid(
                      modelParameterDTypes:
                        durability
                            .observedModelParameterDTypes,
                      trainableParameterDTypes:
                        durability
                            .observedTrainableParameterDTypes
                  ),
                  durability.observedModelParameterDTypes
                    == report.implementation
                        .observedModelParameterDTypes,
                  durability.observedTrainableParameterDTypes
                    == report.implementation
                        .observedTrainableParameterDTypes,
                  let checkpoint =
                    checkpointBindingsBySeed[report.seed],
                  let metalLibrary =
                    metalLibraryBindingsBySeed[report.seed],
                  let stageData =
                    trainingStageDataBySeed[report.seed],
                  durablePhysicalEnvelopeValid(
                      checkpoint: checkpoint,
                      trainingStageData: stageData,
                      checkpointFileName:
                        durability.checkpointFileName,
                      checkpointSHA256:
                        durability.checkpointSHA256,
                      trainingStageFileName:
                        durability.trainingStageFileName,
                      trainingStageSHA256:
                        durability.trainingStageSHA256,
                      evaluationDirectoryName:
                        durability.evaluationDirectoryName
                  ),
                  let stage = try? JSONDecoder().decode(
                      TrainingStageAudit.self,
                      from: stageData
                  ),
                  stage.schemaVersion == "2",
                  stage.buildConfiguration
                    == ErgenticsNativeLanguageCanary
                        .requiredBuildConfiguration,
                  stage.buildConfiguration
                    == report.implementation.buildConfiguration,
                  stage.buildConfiguration
                    == durability.buildConfiguration,
                  stage.precision
                    == ErgenticsNativeLanguageCanary
                        .requiredPrecision,
                  stage.precision
                    == report.implementation.precision,
                  stage.precision == report.training.precision,
                  stage.precision == durability.precision,
                  observedFP32ParameterDTypesValid(
                      modelParameterDTypes:
                        stage.observedModelParameterDTypes,
                      trainableParameterDTypes:
                        stage.observedTrainableParameterDTypes
                  ),
                  stage.observedModelParameterDTypes
                    == report.implementation
                        .observedModelParameterDTypes,
                  stage.observedTrainableParameterDTypes
                    == report.implementation
                        .observedTrainableParameterDTypes,
                  stage.observedModelParameterDTypes
                    == durability.observedModelParameterDTypes,
                  stage.observedTrainableParameterDTypes
                    == durability.observedTrainableParameterDTypes,
                  stage.profileID == report.profile.profileID,
                  stage.seed == report.seed,
                  stage.corpusManifestSHA256
                    == report.corpus.manifestSHA256,
                  stage.corpusManifestArtifactSHA256
                    == report.corpus.manifestArtifactSHA256,
                  stage.corpusManifestFileName
                    == report.corpus.manifestFileName,
                  stage.tokenizerManifestSHA256
                    == report.tokenizer.manifestSHA256,
                  stage.probeManifestSHA256
                    == report.corpus.probeTokenManifestSHA256,
                  stage.probePurposeID
                    == report.training.probePurposeID,
                  stage.scheduleID == report.training.scheduleID,
                  stage.heldoutScheduleSHA256
                    == report.training.heldoutScheduleSHA256,
                  stage.requestedSteps
                    == report.training.requestedSteps,
                  stage.measurementWarmupSteps
                    == report.training.measurementWarmupSteps,
                  stage.timedSteps
                    == report.training.timedSteps,
                  stage.batchSize == report.training.batchSize,
                  stage.gradientAccumulationSteps
                    == report.training.gradientAccumulationSteps,
                  stage.sequenceLength
                    == report.training.measuredSequenceLength,
                  stage.evaluationBatchSize
                    == report.training.evaluationBatchSize,
                  stage.evaluationShardSize
                    == report.training.evaluationShardSize,
                  Float(report.training.learningRate)
                    == stage.learningRate,
                  Float(report.training.weightDecay)
                    == stage.weightDecay,
                  stage.expectedParameterCount
                    == report.profile.expectedParameterCount,
                  stage.observedParameterCount
                    == report.profile.observedParameterCount,
                  stage.observedTrainableParameterCount
                    == report.profile
                        .observedTrainableParameterCount,
                  stage.checkpointSHA256
                    == durability.checkpointSHA256,
                  stage.checkpointFileName
                    == durability.checkpointFileName,
                  stage.configurationSHA256
                    == report.training
                        .configurationArtifactSHA256,
                  stage.executableSHA256
                    == report.implementation
                        .executorArtifactSHA256,
                  stage.packageResolvedSHA256
                    == report.implementation
                        .packageResolvedSHA256,
                  stage.packageResolvedSHA256
                    == packageResolvedBinding.sha256,
                  metalLibrary.primaryFileName
                    == metalLibraryPrimaryFileName,
                  metalLibrary.fallbackFileName
                    == metalLibraryFallbackFileName,
                  isSHA256(metalLibrary.sha256),
                  metalLibrary.byteCount > 0,
                  stage.metalLibraryArtifactSHA256
                    == metalLibrary.sha256,
                  stage.metalLibraryArtifactByteCount
                    == metalLibrary.byteCount,
                  stage.metalLibraryPrimaryFileName
                    == metalLibrary.primaryFileName,
                  stage.metalLibraryFallbackFileName
                    == metalLibrary.fallbackFileName,
                  metalLibraryBundleAuditValid(
                      auditID:
                        stage.metalLibraryBundleSearchAuditID,
                      baseCount:
                        stage.metalLibraryBundleSearchBaseCount,
                      verifiedMirrorCount:
                        stage
                            .metalLibraryVerifiedBundleMirrorCount,
                      divergentCandidateCount:
                        stage
                            .metalLibraryDivergentBundleCandidateCount,
                      sourceMLXSwiftRevision:
                        stage.metalLibrarySourceMLXSwiftRevision,
                      packageResolvedMLXSwiftRevision:
                        packageResolvedBinding.mlxSwiftRevision
                  ),
                  stage.metalLibraryArtifactSHA256
                    == report.implementation
                        .metalLibraryArtifactSHA256,
                  stage.metalLibraryArtifactByteCount
                    == report.implementation
                        .metalLibraryArtifactByteCount,
                  stage.metalLibraryPrimaryFileName
                    == report.implementation
                        .metalLibraryPrimaryFileName,
                  stage.metalLibraryFallbackFileName
                    == report.implementation
                        .metalLibraryFallbackFileName,
                  stage.metalLibraryBundleSearchAuditID
                    == report.implementation
                        .metalLibraryBundleSearchAuditID,
                  stage.metalLibraryBundleSearchBaseCount
                    == report.implementation
                        .metalLibraryBundleSearchBaseCount,
                  stage.metalLibraryVerifiedBundleMirrorCount
                    == report.implementation
                        .metalLibraryVerifiedBundleMirrorCount,
                  stage.metalLibraryDivergentBundleCandidateCount
                    == report.implementation
                        .metalLibraryDivergentBundleCandidateCount,
                  stage.metalLibrarySourceMLXSwiftRevision
                    == packageResolvedBinding
                        .mlxSwiftRevision,
                  stage.metalLibrarySourceMLXSwiftRevision
                    == report.implementation
                        .metalLibrarySourceMLXSwiftRevision,
                  stage.metalLibraryArtifactSHA256
                    == durability.metalLibraryArtifactSHA256,
                  stage.metalLibraryArtifactByteCount
                    == durability.metalLibraryArtifactByteCount,
                  stage.metalLibraryPrimaryFileName
                    == durability.metalLibraryPrimaryFileName,
                  stage.metalLibraryFallbackFileName
                    == durability.metalLibraryFallbackFileName,
                  stage.metalLibraryBundleSearchAuditID
                    == durability
                        .metalLibraryBundleSearchAuditID,
                  stage.metalLibraryBundleSearchBaseCount
                    == durability
                        .metalLibraryBundleSearchBaseCount,
                  stage.metalLibraryVerifiedBundleMirrorCount
                    == durability
                        .metalLibraryVerifiedBundleMirrorCount,
                  stage.metalLibraryDivergentBundleCandidateCount
                    == durability
                        .metalLibraryDivergentBundleCandidateCount,
                  stage.metalLibrarySourceMLXSwiftRevision
                    == durability
                        .metalLibrarySourceMLXSwiftRevision,
                  stage.plannedTrainingTokenPresentations
                    == report.training
                        .plannedTrainingTokenPresentations,
                  stage.persistencePolicy
                    == report.training.persistencePolicy,
                  ErgenticsNativeLanguageCanary
                    .fullStageExecutorWallBound(
                        stageAccountingID:
                            stage.executorWallAccountingID,
                        stageDeclaredMaximumExecutorWallSeconds:
                            stage
                                .declaredMaximumExecutorWallSeconds,
                        stageCumulativeExecutorWallSeconds:
                            stage
                                .cumulativeExecutorWallSecondsAtCheckpoint,
                        training: report.training
                    )
            else {
                return false
            }
            return true
        }
    }

    private static func durablePhysicalEnvelopeValid(
        checkpoint: ObservedCheckpointBinding?,
        trainingStageData: Data?,
        checkpointFileName: String,
        checkpointSHA256: String,
        trainingStageFileName: String,
        trainingStageSHA256: String,
        evaluationDirectoryName: String
    ) -> Bool {
        guard checkpointFileName == checkpointArtifactFileName,
              trainingStageFileName
                == trainingStageArtifactFileName,
              evaluationDirectoryName
                == evaluationShardDirectoryName,
              isSHA256(checkpointSHA256),
              isSHA256(trainingStageSHA256),
              let checkpoint,
              checkpoint.fileName == checkpointFileName,
              checkpoint.sha256 == checkpointSHA256,
              checkpoint.byteCount > 0,
              let trainingStageData,
              !trainingStageData.isEmpty,
              sha256(trainingStageData) == trainingStageSHA256
        else {
            return false
        }
        return true
    }

    private static func trainingRowCountsValid(
        total: Int,
        valid: Int,
        refusal: Int
    ) -> Bool {
        guard let expectedValid =
                ErgenticsPrimeNativeTextCorpus.rowCounts[.train],
              let expectedRefusal =
                ErgenticsPrimeNativeTextCorpus
                    .rowCounts[.refusalTrain]
        else {
            return false
        }
        return valid == expectedValid
            && refusal == expectedRefusal
            && total == valid + refusal
    }

    private static func trainingLossTraceValid(
        _ losses: [Double],
        completedSteps: Int
    ) -> Bool {
        completedSteps > 0
            && losses.count == completedSteps
            && losses.allSatisfy { $0.isFinite && $0 > 0 }
            && losses.last! < losses.first!
    }

    private static func exactTrainingContinuationValid(
        persistencePolicy:
            ErgenticsNativeLanguageCanary.TrainingPersistencePolicy,
        interruptedTrajectoryReplayExact: Bool
    ) -> Bool {
        persistencePolicy == .exactOptimizerStateResume
            && interruptedTrajectoryReplayExact
    }

    private static func freshExecutorWallEvidenceValid(
        mode: ErgenticsNativeLanguageCanary.Mode,
        accountingID: String,
        resumedFromTrainingStage: Bool,
        priorExecutorWallSeconds: Double,
        checkpointStageExecutorWallSeconds: Double,
        measuredTotalExecutorWallSeconds: Double,
        declaredMaximumExecutorWallSeconds: Double,
        preexistingEvaluationArtifactNames: [String]
    ) -> Bool {
        ErgenticsNativeLanguageCanary.executorWallEvidenceBound(
            mode: mode,
            accountingID: accountingID,
            resumedFromTrainingStage:
                resumedFromTrainingStage,
            priorExecutorWallSeconds:
                priorExecutorWallSeconds,
            checkpointStageExecutorWallSeconds:
                checkpointStageExecutorWallSeconds,
            measuredTotalExecutorWallSeconds:
                measuredTotalExecutorWallSeconds,
            declaredMaximumExecutorWallSeconds:
                declaredMaximumExecutorWallSeconds
        )
            && !resumedFromTrainingStage
            && preexistingEvaluationArtifactNames.isEmpty
    }

    private static func sameSeedReplayValid(
        _ reports: [ErgenticsNativeLanguageCanary.Report]
    ) -> Bool {
        guard reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count,
              reports.allSatisfy({
                  $0.schemaVersion
                      == ErgenticsNativeLanguageCanary.schemaVersion
              }),
              Set(
                  reports.map {
                      $0.sameSeedReplay
                        .initialFingerprintSHA256
                  }
              ).count == reports.count
        else {
            return false
        }
        return reports.allSatisfy { report in
            let replay = report.sameSeedReplay
            let expectedRows =
                report.training.effectiveBatchSize
            return expectedRows > 0
                && replay.optimizerSteps == 1
                && replay.scheduledRowIDs.count == expectedRows
                && Set(replay.scheduledRowIDs).count
                    == replay.scheduledRowIDs.count
                && replay.scheduledRowIDs.allSatisfy {
                    trainingRowIDs.contains($0)
                }
                && sameSeedFixedPromptBehavioralReplayValid(
                    replay
                )
                && ErgenticsNativeLanguageCanary.recommend(report)
                .legs.first(where: {
                    $0.id
                        == "N7b_same_seed_behavioral_replay_and_seed_falsifier"
                })?.pass == true
        }
    }

    private static func sameSeedFixedPromptBehavioralReplayValid(
        _ replay:
            ErgenticsNativeLanguageCanary
                .SameSeedReplayEvidence
    ) -> Bool {
        let expectedLogitCount =
            PrimeNativeByteTokenizer.boundModelVocabularySize
        guard replay.fixedPromptLogitFloatBitPatterns.count
                == expectedLogitCount,
              replay
                .replayFixedPromptLogitFloatBitPatterns.count
                == expectedLogitCount else {
            return false
        }
        let first = replay.fixedPromptLogitFloatBitPatterns.map {
            Float(bitPattern: $0)
        }
        let repeated =
            replay.replayFixedPromptLogitFloatBitPatterns.map {
                Float(bitPattern: $0)
            }
        guard first.allSatisfy(\.isFinite),
              repeated.allSatisfy(\.isFinite),
              let firstGreedy = first.enumerated().max(by: {
                  $0.element < $1.element
              }),
              let repeatedGreedy =
                repeated.enumerated().max(by: {
                    $0.element < $1.element
                }),
              let firstRunnerUp = first.enumerated()
                .filter({
                    $0.offset != firstGreedy.offset
                }).map(\.element).max(),
              let repeatedRunnerUp = repeated.enumerated()
                .filter({
                    $0.offset != repeatedGreedy.offset
                }).map(\.element).max()
        else {
            return false
        }
        let maximumDelta = zip(first, repeated).map {
            abs(Double($0.0) - Double($0.1))
        }.max() ?? 0
        let firstMargin =
            Double(firstGreedy.element)
                - Double(firstRunnerUp)
        let repeatedMargin =
            Double(repeatedGreedy.element)
                - Double(repeatedRunnerUp)
        let greedyExact =
            firstGreedy.offset == repeatedGreedy.offset
        let doubledDelta = 2 * maximumDelta
        let behavioralExact =
            maximumDelta.isFinite
                && firstMargin.isFinite
                && repeatedMargin.isFinite
                && firstMargin > 0
                && repeatedMargin > 0
                && greedyExact
                && doubledDelta.isFinite
                && doubledDelta
                    < min(firstMargin, repeatedMargin)
        let bitwiseExact =
            replay.fixedPromptLogitFloatBitPatterns
                == replay
                    .replayFixedPromptLogitFloatBitPatterns
        return replay.fixedPromptMaximumLogitDelta
                == maximumDelta
            && replay.fixedPromptGreedyTokenID
                == firstGreedy.offset
            && replay.replayFixedPromptGreedyTokenID
                == repeatedGreedy.offset
            && replay.fixedPromptGreedyRunnerUpMargin
                == firstMargin
            && replay.replayFixedPromptGreedyRunnerUpMargin
                == repeatedMargin
            && replay.fixedPromptGreedyTokenExact
                == greedyExact
            && replay.fixedPromptBehavioralReplayExact
                == behavioralExact
            && replay.fixedPromptResultExact
                == bitwiseExact
            && behavioralExact
    }

    private static func seedConsensusValid(
        _ reports: [ErgenticsNativeLanguageCanary.Report]
    ) -> Bool {
        guard reports.map(\.seed).sorted()
                == ErgenticsNativeLanguageCanary.frozenSeeds.sorted(),
              Set(reports.map(\.seed)).count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count,
              Set(reports.map(\.profile.profileID)).count == 1,
              Set(reports.map(\.tokenizer.manifestSHA256)).count
                == 1,
              Set(reports.map(\.corpus.manifestSHA256)).count == 1,
              Set(
                  reports.map {
                      $0.training.comparisonManifestSHA256
                  }
              ).count == 1,
              reports.allSatisfy({
                  $0.training.declaredLearningRateGrid
                    == ErgenticsNativeScaleEngineRecommend
                        .discoveryLearningRates
                      && $0.training.declaredReplicateSeeds
                        == ErgenticsNativeScaleEngineRecommend
                            .adaptiveSeeds
              })
        else {
            return false
        }
        return ErgenticsNativeLanguageCanary.consensus(
            reports: reports
        ).outcome == "GROUNDED"
    }

    private static func capabilityValid(
        _ reports: [ErgenticsNativeLanguageCanary.Report]
    ) -> Bool {
        guard reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count
        else { return false }
        return reports.allSatisfy { report in
            let rows = report.rawPredictions
            guard report.corpus.expectedEvaluationRows
                    == requiredEvaluationRows,
                  exactTrainingContinuationValid(
                      persistencePolicy:
                        report.training.persistencePolicy,
                      interruptedTrajectoryReplayExact:
                        report.training
                            .interruptedTrajectoryReplayExact
                  ),
                  rows.count
                    == requiredEvaluationRows.values.reduce(0, +),
                  rows.filter({
                      $0.split == .abstention
                  }).allSatisfy({
                      $0.target == "ABSTAIN\n"
                          && $0.trainedPrediction == "ABSTAIN\n"
                          && $0.trainedTerminatedByEOS
                          && $0.trainedTerminationReason == "eos"
                          && $0.trainedUTF8Valid
                          && $0.trainedExactMatch
                          && $0.trainedSemanticVerifierPass
                          && $0.trainedAbstentionDecision
                  }),
                  rows.filter({
                      $0.split != .abstention
                  }).allSatisfy({
                      $0.trainedTerminatedByEOS
                          && $0.trainedTerminationReason == "eos"
                          && $0.trainedUTF8Valid
                          && $0.trainedPrediction != nil
                          && $0.trainedSemanticVerifierPass
                          && !$0.trainedAbstentionDecision
                  }),
                  rows.filter({
                      $0.split != .validation
                  }).allSatisfy({
                      $0
                          .trainedRawFullVocabularyAllowedSupportGreedyTokenParity
                          && $0
                              .trainedDisallowedFullVocabularyArgmaxCount
                              == 0
                  })
            else {
                return false
            }
            let recommendation =
                ErgenticsNativeLanguageCanary.recommend(report)
            guard recommendation.legs.first(where: {
                $0.id == "N10_functional_generalization_thresholds"
            })?.pass == true else {
                return false
            }
            let metrics = Dictionary(
                uniqueKeysWithValues:
                    recommendation.splitMetrics.map {
                        ($0.split, $0)
                    }
            )
            guard let validation = metrics[.validation],
                  let combination = metrics[.combinationHoldout],
                  let ood = metrics[.outOfDistribution],
                  let mutation = metrics[.mutation],
                  let abstention = metrics[.abstention],
                  validation.count == 4_096,
                  combination.count == 4_096,
                  ood.count == 4_096,
                  mutation.count == 4_096,
                  abstention.count == 2_048
            else {
                return false
            }
            // Validation remains selection/tuning telemetry. Independent
            // capability admission rests only on held-combination, OOD,
            // mutation, and final malformed/refusal rows.
            let independent = [
                combination,
                ood,
                mutation,
                abstention,
            ]
            return combination.trainedExactAccuracy >= 0.80
                && ood.trainedExactAccuracy >= 0.70
                && mutation.trainedExactAccuracy >= 0.80
                && abstention.trainedExactAccuracy == 1
                && independent.allSatisfy {
                    $0.trainedExactAccuracy
                        > $0.zeroShotExactAccuracy
                }
        }
    }

    public static func finiteFieldFingerprint(
        _ records: [String]
    ) -> FiniteFieldFingerprint {
        let canonical = records.sorted(
            by: rawUTF8LexicographicallyPrecedes
        )
        let residues = fieldPoints.map { point in
            var accumulator: UInt64 = 1
            for record in canonical {
                var length = UInt64(record.utf8.count).bigEndian
                withUnsafeBytes(of: &length) { bytes in
                    for byte in bytes {
                        accumulator = (
                            accumulator * point
                                + UInt64(byte) + 1
                        ) % fieldPrime
                    }
                }
                for byte in record.utf8 {
                    accumulator = (
                        accumulator * point
                            + UInt64(byte) + 1
                    ) % fieldPrime
                }
            }
            return accumulator
        }
        return FiniteFieldFingerprint(
            prime: fieldPrime,
            evaluationPoints: fieldPoints,
            residues: residues,
            recordCount: canonical.count
        )
    }

    private static func rawUTF8ExactlyEqual(
        _ left: String,
        _ right: String,
        leftIsASCII: Bool,
        rightIsASCII: Bool
    ) -> Bool {
        if leftIsASCII, rightIsASCII {
            // ASCII has one canonical byte spelling, so native String
            // equality is an exact fast path only when both classifications
            // were independently established during record construction.
            return left == right
        }
        return left.utf8.elementsEqual(right.utf8)
    }

    private static func rawUTF8RecordsExactlyEqual(
        _ left: [String],
        _ right: [String],
        leftIsASCII: [Bool],
        rightIsASCII: [Bool]
    ) -> Bool {
        guard left.count == right.count,
              leftIsASCII.count == left.count,
              rightIsASCII.count == right.count else {
            return false
        }
        return left.indices.allSatisfy {
            rawUTF8ExactlyEqual(
                left[$0],
                right[$0],
                leftIsASCII: leftIsASCII[$0],
                rightIsASCII: rightIsASCII[$0]
            )
        }
    }

    private static func rawUTF8LexicographicallyPrecedes(
        _ left: String,
        _ right: String
    ) -> Bool {
        left.utf8.lexicographicallyPrecedes(right.utf8)
    }

    /// Test-visible exact accelerator for the immutable-baseline path used by
    /// the exhaustive mutation sweep. The result must remain byte-for-byte
    /// equal to `finiteFieldFingerprint`; the latter stays as the independent
    /// direct implementation and fallback.
    static func finiteFieldFingerprintUsingImmutableBaseline(
        _ records: [String],
        mutatedRecords: [String]
    ) -> FiniteFieldFingerprint {
        let key = "finite_field_test_v1|"
            + sha256(
                Data(
                    records.sorted(
                        by: rawUTF8LexicographicallyPrecedes
                    ).joined(separator: "\u{0}").utf8
                )
            )
        let plan = finiteFieldBaselinePlan(
            cacheKey: key,
            records: records,
            recordIsASCII: records.map {
                $0.utf8.allSatisfy { $0 < 128 }
            }
        )
        return finiteFieldFingerprint(
            mutatedRecords,
            recordIsASCII: mutatedRecords.map {
                $0.utf8.allSatisfy { $0 < 128 }
            },
            using: plan
        )
    }

    private static func finiteFieldBaselinePlan(
        cacheKey: String,
        records: [String],
        recordIsASCII: [Bool]
    ) -> FiniteFieldBaselinePlan {
        precondition(records.count == recordIsASCII.count)
        let versionedKey =
            "native_language_invariant_records_affine_v1|"
            + cacheKey
        baselineSZCacheLock.lock()
        if let cached = baselineSZCache,
           cached.cacheKey == versionedKey,
           cached.originalRecordIsASCII == recordIsASCII,
           rawUTF8RecordsExactlyEqual(
               cached.originalRecords,
               records,
               leftIsASCII: cached.originalRecordIsASCII,
               rightIsASCII: recordIsASCII
           )
        {
            baselineSZCacheLock.unlock()
            return cached
        }
        baselineSZCacheLock.unlock()

        let canonical = records.sorted(
            by: rawUTF8LexicographicallyPrecedes
        )
        var leafCount = 1
        while leafCount < canonical.count {
            leafCount <<= 1
        }
        let trees = fieldPoints.map { point in
            var tree = Array(
                repeating: FieldAffine.identity,
                count: leafCount * 2
            )
            for (index, record) in canonical.enumerated() {
                tree[leafCount + index] =
                    fieldAffine(record: record, point: point)
            }
            if leafCount > 1 {
                for index in stride(
                    from: leafCount - 1,
                    through: 1,
                    by: -1
                ) {
                    tree[index] = compose(
                        tree[index * 2],
                        then: tree[index * 2 + 1]
                    )
                }
            }
            return tree
        }
        let residues = trees.map {
            apply($0[1], to: 1)
        }
        let plan = FiniteFieldBaselinePlan(
            cacheKey: versionedKey,
            originalRecords: records,
            originalRecordIsASCII: recordIsASCII,
            sortedRecords: canonical,
            leafCount: leafCount,
            trees: trees,
            fingerprint: FiniteFieldFingerprint(
                prime: fieldPrime,
                evaluationPoints: fieldPoints,
                residues: residues,
                recordCount: canonical.count
            )
        )
        baselineSZCacheLock.lock()
        baselineSZCache = plan
        baselineSZCacheLock.unlock()
        return plan
    }

    private static func finiteFieldFingerprint(
        _ records: [String],
        recordIsASCII: [Bool],
        using baselinePlan: FiniteFieldBaselinePlan
    ) -> FiniteFieldFingerprint {
        precondition(records.count == recordIsASCII.count)
        if rawUTF8RecordsExactlyEqual(
            baselinePlan.originalRecords,
            records,
            leftIsASCII:
                baselinePlan.originalRecordIsASCII,
            rightIsASCII: recordIsASCII
        ) {
            return baselinePlan.fingerprint
        }
        guard records.count == baselinePlan.originalRecords.count
        else {
            return finiteFieldFingerprint(records)
        }

        // Most named mutations alter one report field or one raw row. A broad
        // mutation (for example a seed-key rewrite) deliberately falls back
        // to the independent direct implementation instead of hiding work
        // behind an unsafe approximation.
        let maximumIncrementalDifferences = 1_024
        var removed: [RawUTF8RecordKey: Int] = [:]
        var added: [RawUTF8RecordKey: Int] = [:]
        var changedSlots = 0
        for index in records.indices where !rawUTF8ExactlyEqual(
            baselinePlan.originalRecords[index],
            records[index],
            leftIsASCII:
                baselinePlan.originalRecordIsASCII[index],
            rightIsASCII: recordIsASCII[index]
        ) {
            changedSlots += 1
            if changedSlots > maximumIncrementalDifferences {
                return finiteFieldFingerprint(records)
            }
            removed[
                RawUTF8RecordKey(
                    baselinePlan.originalRecords[index]
                ),
                default: 0
            ] += 1
            added[
                RawUTF8RecordKey(records[index]),
                default: 0
            ] += 1
        }
        if changedSlots == 0 {
            return baselinePlan.fingerprint
        }

        // Cancel records that only moved in the unsorted source order. The
        // fingerprint is defined over the sorted multiset, not array slots.
        for record in Array(removed.keys) {
            guard let additionCount = added[record] else {
                continue
            }
            let cancellation = min(
                removed[record] ?? 0,
                additionCount
            )
            let removalRemainder =
                (removed[record] ?? 0) - cancellation
            let additionRemainder =
                additionCount - cancellation
            if removalRemainder == 0 {
                removed.removeValue(forKey: record)
            } else {
                removed[record] = removalRemainder
            }
            if additionRemainder == 0 {
                added.removeValue(forKey: record)
            } else {
                added[record] = additionRemainder
            }
        }
        let editCount =
            removed.values.reduce(0, +)
                + added.values.reduce(0, +)
        guard editCount <= maximumIncrementalDifferences * 2,
              let segments = fingerprintSegments(
                baselinePlan: baselinePlan,
                removed: removed,
                added: added
              )
        else {
            return finiteFieldFingerprint(records)
        }

        let residues = fieldPoints.indices.map { pointIndex in
            var accumulator: UInt64 = 1
            for segment in segments {
                let transition: FieldAffine
                switch segment {
                case let .baselineRange(range):
                    transition = fieldRangeAffine(
                        range,
                        tree: baselinePlan.trees[pointIndex],
                        leafCount: baselinePlan.leafCount
                    )
                case let .replacement(record):
                    transition = fieldAffine(
                        record: record,
                        point: fieldPoints[pointIndex]
                    )
                }
                accumulator = apply(
                    transition,
                    to: accumulator
                )
            }
            return accumulator
        }
        return FiniteFieldFingerprint(
            prime: fieldPrime,
            evaluationPoints: fieldPoints,
            residues: residues,
            recordCount: records.count
        )
    }

    private static func fingerprintSegments(
        baselinePlan: FiniteFieldBaselinePlan,
        removed: [RawUTF8RecordKey: Int],
        added: [RawUTF8RecordKey: Int]
    ) -> [FingerprintSegment]? {
        var removalRemainders = removed
        var removedIndices = Set<Int>()
        for (index, record) in
            baselinePlan.sortedRecords.enumerated()
        {
            let key = RawUTF8RecordKey(record)
            guard let count = removalRemainders[key],
                  count > 0
            else {
                continue
            }
            removedIndices.insert(index)
            if count == 1 {
                removalRemainders.removeValue(forKey: key)
            } else {
                removalRemainders[key] = count - 1
            }
        }
        guard removalRemainders.isEmpty else {
            return nil
        }
        let additions = added.flatMap { key, count in
            Array(repeating: key.record, count: count)
        }.sorted(by: rawUTF8LexicographicallyPrecedes)
        guard additions.count == removedIndices.count else {
            return nil
        }

        var segments: [FingerprintSegment] = []
        var baselineIndex = 0
        var additionIndex = 0
        while baselineIndex < baselinePlan.sortedRecords.count
            || additionIndex < additions.count
        {
            if baselineIndex < baselinePlan.sortedRecords.count,
               removedIndices.contains(baselineIndex)
            {
                baselineIndex += 1
                continue
            }
            if additionIndex < additions.count,
               (
                   baselineIndex
                    == baselinePlan.sortedRecords.count
                    || rawUTF8LexicographicallyPrecedes(
                        additions[additionIndex],
                        baselinePlan.sortedRecords[baselineIndex]
                    )
               )
            {
                segments.append(
                    .replacement(additions[additionIndex])
                )
                additionIndex += 1
                continue
            }

            let rangeStart = baselineIndex
            while baselineIndex
                < baselinePlan.sortedRecords.count
            {
                if removedIndices.contains(baselineIndex) {
                    break
                }
                if additionIndex < additions.count,
                   rawUTF8LexicographicallyPrecedes(
                       additions[additionIndex],
                       baselinePlan.sortedRecords[baselineIndex]
                   )
                {
                    break
                }
                baselineIndex += 1
            }
            guard rangeStart < baselineIndex else {
                return nil
            }
            segments.append(
                .baselineRange(rangeStart..<baselineIndex)
            )
        }
        return segments
    }

    private static func fieldAffine(
        record: String,
        point: UInt64
    ) -> FieldAffine {
        var multiplier: UInt64 = 1
        var addend: UInt64 = 0
        let byteCount = UInt64(record.utf8.count)
        for shift in stride(from: 56, through: 0, by: -8) {
            let byte = UInt8(
                truncatingIfNeeded: byteCount >> UInt64(shift)
            )
            multiplier = (multiplier * point) % fieldPrime
            addend = (
                addend * point + UInt64(byte) + 1
            ) % fieldPrime
        }
        for byte in record.utf8 {
            multiplier = (multiplier * point) % fieldPrime
            addend = (
                addend * point + UInt64(byte) + 1
            ) % fieldPrime
        }
        return FieldAffine(
            multiplier: multiplier,
            addend: addend
        )
    }

    /// Compose the transition for `left` followed by `right`.
    private static func compose(
        _ left: FieldAffine,
        then right: FieldAffine
    ) -> FieldAffine {
        FieldAffine(
            multiplier:
                (left.multiplier * right.multiplier)
                    % fieldPrime,
            addend:
                (
                    left.addend * right.multiplier
                        + right.addend
                ) % fieldPrime
        )
    }

    private static func apply(
        _ affine: FieldAffine,
        to value: UInt64
    ) -> UInt64 {
        (
            value * affine.multiplier + affine.addend
        ) % fieldPrime
    }

    private static func fieldRangeAffine(
        _ range: Range<Int>,
        tree: [FieldAffine],
        leafCount: Int
    ) -> FieldAffine {
        var lower = range.lowerBound + leafCount
        var upper = range.upperBound + leafCount
        var left = FieldAffine.identity
        var right = FieldAffine.identity
        while lower < upper {
            if lower & 1 == 1 {
                left = compose(left, then: tree[lower])
                lower += 1
            }
            if upper & 1 == 1 {
                upper -= 1
                right = compose(tree[upper], then: right)
            }
            lower >>= 1
            upper >>= 1
        }
        return compose(left, then: right)
    }

    private static func poolExpansionPasses(
        _ records: [String],
        recordIsASCII: [Bool],
        baselinePlan: FiniteFieldBaselinePlan
    ) -> Bool {
        guard !records.isEmpty,
              records.count == recordIsASCII.count
        else {
            return false
        }
        let base = baselinePlan.fingerprint
        let prefixes = [
            "lineage|",
            "profile|",
            "tokenizer|",
            "corpus|",
            "implementation|",
            "training|",
            "training_mechanics|",
            "heldout_loss|",
            "refusal_curriculum|",
            "same_seed_replay|",
            "durability|",
            "row|",
            "seed_set|",
        ]
        var fingerprints: [FiniteFieldFingerprint] = []
        for prefix in prefixes {
            guard let index = records.firstIndex(where: {
                $0.hasPrefix(prefix)
            }) else {
                return false
            }
            var corrupted = records
            corrupted[index] += "|pool_corruption"
            let fingerprint = finiteFieldFingerprint(
                corrupted,
                recordIsASCII: recordIsASCII,
                using: baselinePlan
            )
            guard fingerprint != base else { return false }
            fingerprints.append(fingerprint)
        }
        return Set(fingerprints.map {
            $0.residues.map(String.init).joined(separator: ":")
        }).count
            == fingerprints.count
    }

    private static func invariantRecords(
        reports: [ErgenticsNativeLanguageCanary.Report],
        tokenizer: PrimeNativeByteTokenizer.Manifest?,
        corpus: ErgenticsPrimeNativeTextCorpus.Manifest?,
        rowHashRegrade: Bool,
        cachedRowRecordsBySeed:
            [Int: InvariantRecordCollection] = [:]
    ) -> InvariantRecordCollection {
        guard let tokenizer, let corpus else {
            return InvariantRecordCollection(
                records: [],
                isASCII: []
            )
        }
        let refusal = corpus.refusalCurriculumEvidence
        let refusalTrainingReasons =
            refusal.trainingReasonCounts.map { item in
                item.id + ":" + String(item.rowCount)
            }.joined(separator: ",")
        let refusalTuningReasons =
            refusal.tuningReasonCounts.map { item in
                item.id + ":" + String(item.rowCount)
            }.joined(separator: ",")
        let refusalFinalReasons =
            refusal.finalEvaluationReasonCounts.map { item in
                item.id + ":" + String(item.rowCount)
            }.joined(separator: ",")
        func refusalContracts(
            _ values: [
                ErgenticsPrimeNativeTextCorpus
                    .RefusalContractCount
            ]
        ) -> String {
            values.map { item in
                [
                    item.abstentionReason,
                    item.mutationID,
                    item.surfaceFormID,
                    String(item.rowCount),
                ].joined(separator: ":")
            }.joined(separator: ",")
        }
        let refusalTrainingContracts = refusalContracts(
            refusal.trainingContractCounts
        )
        let refusalTuningContracts = refusalContracts(
            refusal.tuningContractCounts
        )
        let refusalFinalContracts = refusalContracts(
            refusal.finalEvaluationContractCounts
        )
        var records: [String] = [
            [
                "tokenizer",
                tokenizer.schemaVersion,
                tokenizer.tokenizerID,
                tokenizer.ownership,
                tokenizer.implementationLanguage,
                tokenizer.algorithm,
                tokenizer.unicodeNormalization,
                String(tokenizer.tokenSpaceSize),
                String(tokenizer.boundModelVocabularySize),
                String(tokenizer.byteTokenBase),
                String(tokenizer.byteTokenCount),
            ].joined(separator: "|"),
            [
                "corpus",
                corpus.schemaVersion,
                corpus.corpusID,
                corpus.ownership,
                corpus.license,
                corpus.generator.generatorID,
                String(corpus.tokenAccounting.rawTokenInstances),
                String(corpus.tokenAccounting.uniqueSequenceCount),
                String(
                    corpus.tokenAccounting
                        .uniqueSemanticCombinationCount
                ),
                String(
                    corpus.leakageEvidence
                        .trainEvaluationPromptOverlapCount
                ),
                String(
                    corpus.leakageEvidence
                        .trainEvaluationSemanticOverlapCount
                ),
            ].joined(separator: "|"),
            [
                "refusal_curriculum",
                corpus.refusalCurriculumEvidence.trainingSplit,
                corpus.refusalCurriculumEvidence.tuningSplit,
                corpus.refusalCurriculumEvidence
                    .finalEvaluationSplit,
                String(
                    corpus.refusalCurriculumEvidence
                        .trainingRowCount
                ),
                String(
                    corpus.refusalCurriculumEvidence
                        .tuningRowCount
                ),
                String(
                    corpus.refusalCurriculumEvidence
                        .finalEvaluationRowCount
                ),
                refusalTrainingReasons,
                refusalTuningReasons,
                refusalFinalReasons,
                refusalTrainingContracts,
                refusalTuningContracts,
                refusalFinalContracts,
                corpus.refusalCurriculumEvidence
                    .trainingPromptSetSHA256,
                corpus.refusalCurriculumEvidence
                    .tuningPromptSetSHA256,
                corpus.refusalCurriculumEvidence
                    .finalEvaluationPromptSetSHA256,
                corpus.refusalCurriculumEvidence
                    .trainingSemanticSetSHA256,
                corpus.refusalCurriculumEvidence
                    .tuningSemanticSetSHA256,
                corpus.refusalCurriculumEvidence
                    .finalEvaluationSemanticSetSHA256,
                corpus.refusalCurriculumEvidence
                    .trainingIndependentRegradeSHA256,
                corpus.refusalCurriculumEvidence
                    .tuningIndependentRegradeSHA256,
                corpus.refusalCurriculumEvidence
                    .finalEvaluationIndependentRegradeSHA256,
                String(
                    corpus.refusalCurriculumEvidence
                        .allReasonsTaughtBeforeTuningAndEvaluation
                ),
                String(
                    corpus.refusalCurriculumEvidence
                        .allTuningAndEvaluationContractsHeldOut
                ),
                String(
                    corpus.refusalCurriculumEvidence
                        .allRowsIndependentlyVerified
                ),
            ].joined(separator: "|"),
            "row_hash_regrade|\(rowHashRegrade)",
        ]
        var recordIsASCII = records.map {
            $0.utf8.allSatisfy { $0 < 128 }
        }
        func appendRecord(_ record: String) {
            records.append(record)
            recordIsASCII.append(
                record.utf8.allSatisfy { $0 < 128 }
            )
        }
        func appendSelectedParameterSamples(
            label: String,
            seed: Int,
            samples:
                [
                    ErgenticsNativeLanguageCanary
                        .SelectedParameterSample
                ]
        ) {
            for sample in samples {
                appendRecord(
                    [
                        label,
                        String(seed),
                        sample.name,
                        sample.shape.map(String.init)
                            .joined(separator: ","),
                        sample.dtype,
                        sample.indices.map(String.init)
                            .joined(separator: ","),
                        sample.floatBitPatterns.map(String.init)
                            .joined(separator: ","),
                    ].joined(separator: "|")
                )
            }
        }
        for report in reports.sorted(by: { $0.seed < $1.seed }) {
            appendRecord(
                [
                    "lineage",
                    report.schemaVersion,
                    report.familyID,
                    report.lineageID,
                    report.mode.rawValue,
                    report.parentCheckpointSHA256 == nil
                        ? "no_parent" : "has_parent",
                    report.legacySymbolicManifestSHA256 == nil
                        ? "no_legacy" : "has_legacy",
                    report.generationContractID,
                ].joined(separator: "|")
            )
            appendRecord(
                [
                    "profile",
                    report.profile.profileID,
                    String(report.profile.vocabularySize),
                    String(report.profile.maximumSequenceLength),
                    String(report.profile.expectedParameterCount),
                    String(report.profile.observedParameterCount),
                    String(
                        report.profile
                            .observedTrainableParameterCount
                    ),
                ].joined(separator: "|")
            )
            appendRecord(
                [
                    "tokenizer",
                    String(report.seed),
                    report.tokenizer.tokenizerID,
                    String(report.tokenizer.vocabularySize),
                    String(
                        report.tokenizer
                            .deterministicReplayPassed
                    ),
                    String(
                        report.tokenizer
                            .independentFoundationReplayPassed
                    ),
                ].joined(separator: "|")
            )
            appendRecord(
                [
                    "corpus",
                    String(report.seed),
                    report.corpus.corpusID,
                    String(
                        report.corpus.firstPartyRightsBound
                    ),
                    String(
                        report.corpus.exactObjectHashesPresent
                    ),
                    String(
                        report.corpus.disjointSplitsVerified
                    ),
                    report.corpus.probeTokenManifestFileName,
                    String(report.corpus.probeTokenCount),
                    String(
                        report.corpus
                            .maximumEvaluationPromptTokenCount
                    ),
                    String(
                        report.corpus
                            .maximumEvaluationTargetTokenCount
                    ),
                    report.corpus.overCapTargetRowIDs
                        .sorted().joined(separator: ","),
                    String(
                        report.corpus.generationContextLength
                    ),
                    String(
                        report.corpus
                            .insufficientGenerationContextRowIDs
                            .isEmpty
                    ),
                    String(report.corpus.trainingRowCount),
                    String(report.corpus.trainingTokenInstances),
                    String(
                        report.corpus.semanticCombinationCount
                    ),
                ].joined(separator: "|")
            )
            appendRecord(
                [
                    "seed_set",
                    String(report.seed),
                ].joined(separator: "|")
            )
            appendRecord(
                [
                    "implementation",
                    String(report.seed),
                    report.implementation.executionLanguage,
                    report.implementation.buildConfiguration,
                    report.implementation.precision,
                    report.implementation.framework,
                    report.implementation.modelImplementation,
                    report.implementation.optimizerImplementation,
                    report.implementation.deviceType,
                    report.implementation.mlxSwiftVersion,
                    report.implementation.mlxSwiftExamplesVersion,
                    report.implementation.mlxSwiftLicenseID,
                    report.implementation
                        .mlxSwiftExamplesLicenseID,
                    report.implementation.packageResolvedSHA256,
                    report.implementation
                        .metalLibraryArtifactSHA256,
                    String(
                        report.implementation
                            .metalLibraryArtifactByteCount
                    ),
                    report.implementation
                        .metalLibraryPrimaryFileName,
                    report.implementation
                        .metalLibraryFallbackFileName,
                    report.implementation
                        .metalLibraryBundleSearchAuditID,
                    String(
                        report.implementation
                            .metalLibraryBundleSearchBaseCount
                    ),
                    String(
                        report.implementation
                            .metalLibraryVerifiedBundleMirrorCount
                    ),
                    String(
                        report.implementation
                            .metalLibraryDivergentBundleCandidateCount
                    ),
                    report.implementation
                        .metalLibrarySourceMLXSwiftRevision,
                    report.implementation
                        .observedModelParameterDTypes
                        .joined(separator: ","),
                    report.implementation
                        .observedTrainableParameterDTypes
                        .joined(separator: ","),
                    report.implementation
                        .executorArtifactFileName,
                    report.implementation
                        .executorArtifactSHA256,
                    report.implementation
                        .recommenderArtifactFileName,
                    report.implementation
                        .recommenderArtifactSHA256,
                    String(
                        isSHA256(
                            report.implementation
                                .executorArtifactSHA256
                        )
                    ),
                    String(
                        report.durability?.executableSHA256
                            == report.implementation
                                .executorArtifactSHA256
                    ),
                    String(
                        report.durability?.recommenderSHA256
                            == report.implementation
                                .recommenderArtifactSHA256
                    ),
                    String(
                        report.durability?.recommenderFileName
                            == report.implementation
                                .recommenderArtifactFileName
                    ),
                    String(
                        report.implementation
                            .externalPackagesSupplyExecutionPrimitivesOnly
                    ),
                    String(
                        report.implementation
                            .externalPackagesSupplyTextTokenizerOrWeights
                    ),
                    String(
                        report.implementation
                            .maintainedPrimitivesOnly
                    ),
                    String(
                        report.implementation
                            .customTransformerCode
                    ),
                    String(
                        report.implementation
                            .customMetalKernels
                    ),
                    String(
                        report.implementation.randomInitialization
                    ),
                    String(
                        report.implementation.importedBaseWeights
                    ),
                    String(
                        report.implementation.pythonProducedEvidence
                    ),
                ].joined(separator: "|")
            )
            let scheduledFamilyRows =
                report.training.scheduledSemanticFamilyRows
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ",")
            let scheduledValidFamilyRows =
                report.training.scheduledValidSemanticFamilyRows
                .sorted { $0.key < $1.key }
                .map { item in
                    item.key + "=" + String(item.value)
                }.joined(separator: ",")
            let scheduledRefusalFamilyRows =
                report.training.scheduledRefusalSemanticFamilyRows
                .sorted { $0.key < $1.key }
                .map { item in
                    item.key + "=" + String(item.value)
                }.joined(separator: ",")
            let scheduledRefusalReasonRows =
                report.training.scheduledRefusalReasonRows
                .sorted { $0.key < $1.key }
                .map { item in
                    item.key + "=" + String(item.value)
                }.joined(separator: ",")
            let heldoutValidFamilyRows =
                report.training.heldoutValidSemanticFamilyRows
                .sorted { $0.key < $1.key }
                .map { item in
                    item.key + "=" + String(item.value)
                }.joined(separator: ",")
            let heldoutRefusalFamilyRows =
                report.training.heldoutRefusalSemanticFamilyRows
                .sorted { $0.key < $1.key }
                .map { item in
                    item.key + "=" + String(item.value)
                }.joined(separator: ",")
            let heldoutRefusalReasonRows =
                report.training.heldoutRefusalReasonRows
                .sorted { $0.key < $1.key }
                .map { item in
                    item.key + "=" + String(item.value)
                }.joined(separator: ",")
            var trainingGeometry: [String] = [
                "training",
                String(report.seed),
                String(report.training.requestedSteps),
                String(report.training.completedSteps),
                report.training.probePurposeID,
                report.training.scheduleID,
                String(report.training.distinctScheduledRowCount),
                scheduledFamilyRows,
            ]
            trainingGeometry.append(contentsOf: [
                String(report.training.scheduledValidRowCount),
                String(report.training.scheduledRefusalRowCount),
                scheduledValidFamilyRows,
                scheduledRefusalFamilyRows,
                scheduledRefusalReasonRows,
                report.training
                    .scheduledRefusalReasonScheduleSHA256,
                String(report.training.heldoutRowCount),
                String(report.training.heldoutValidRowCount),
                String(report.training.heldoutRefusalRowCount),
                heldoutValidFamilyRows,
                heldoutRefusalFamilyRows,
                heldoutRefusalReasonRows,
                report.training
                    .heldoutRefusalReasonScheduleSHA256,
                report.training.selectionValidationSplitIDs
                    .joined(separator: ","),
            ])
            trainingGeometry.append(contentsOf: [
                String(
                    report.training
                        .heldoutScheduleSHA256.count == 64
                ),
                String(
                    report.training
                        .comparisonManifestSHA256.count == 64
                ),
                String(
                    report.training
                        .trainingScheduleManifestSHA256
                        == report.corpus
                            .probeTokenManifestSHA256
                ),
                String(
                    report.training
                        .trainingHeldoutRowHashIntersectionCount
                ),
                String(report.training.heldoutTargetTokenCount),
            ])
            trainingGeometry.append(contentsOf: [
                String(
                    report.training.heldoutValidTargetTokenCount
                ),
                String(
                    report.training.heldoutRefusalTargetTokenCount
                ),
                String(
                    report.training
                        .heldoutEvaluationNonPaddingTokenCount
                ),
                String(
                    report.training
                        .heldoutEvaluationElapsedSeconds
                ),
                String(
                    report.training.heldoutCrossEntropyBefore
                ),
                String(
                    report.training.heldoutCrossEntropyAfter
                ),
            ])
            trainingGeometry.append(contentsOf: [
                String(
                    report.training.heldoutValidCrossEntropyBefore
                ),
                String(
                    report.training.heldoutValidCrossEntropyAfter
                ),
                String(
                    report.training
                        .heldoutRefusalCrossEntropyBefore
                ),
                String(
                    report.training
                        .heldoutRefusalCrossEntropyAfter
                ),
                String(
                    report.training
                        .heldoutCrossEntropyStandardError
                ),
                report.training
                    .heldoutCrossEntropyStandardErrorMethodID,
            ])
            trainingGeometry.append(contentsOf: [
                String(report.training.measurementWarmupSteps),
                String(report.training.timedSteps),
                String(report.training.batchSize),
                String(report.training.gradientAccumulationSteps),
                String(report.training.effectiveBatchSize),
                String(report.training.measuredSequenceLength),
            ])
            trainingGeometry.append(
                String(
                    report.training.processedPaddedTokenPositions
                )
            )
            trainingGeometry.append(
                String(
                    report.training
                        .plannedTrainingTokenPresentations
                )
            )
            trainingGeometry.append(
                String(report.training.trainedTokens)
            )
            trainingGeometry.append(
                String(report.training.elapsedSeconds)
            )
            trainingGeometry.append(
                String(report.training.coldStartElapsedSeconds)
            )
            trainingGeometry.append(
                String(
                    report.training
                        .measurementWarmupElapsedSeconds
                )
            )
            trainingGeometry.append(
                String(report.training.timedElapsedSeconds)
            )
            trainingGeometry.append(
                String(report.training.timedNonPaddingTokens)
            )
            trainingGeometry.append(
                String(report.training.tokensPerSecond)
            )
            trainingGeometry.append(
                String(
                    report.training
                        .declaredMaximumExecutorWallSeconds
                )
            )
            trainingGeometry.append(
                String(
                    report.training
                        .measuredTotalExecutorWallSeconds
                )
            )
            trainingGeometry.append(
                String(
                    report.training
                        .measuredTotalExecutorWallSeconds
                        <= report.training
                            .declaredMaximumExecutorWallSeconds
                )
            )
            trainingGeometry.append(
                report.training.executorWallAccountingID
            )
            trainingGeometry.append(
                String(
                    report.training.resumedFromTrainingStage
                )
            )
            trainingGeometry.append(
                String(report.training.priorExecutorWallSeconds)
            )
            trainingGeometry.append(
                String(
                    report.training
                        .checkpointStageExecutorWallSeconds
                )
            )
            trainingGeometry.append(
                report.training
                    .preexistingEvaluationArtifactNamesAtInvocationStart
                    .sorted().joined(separator: ",")
            )
            appendRecord(
                trainingGeometry.joined(separator: "|")
            )

            var trainingMechanics: [String] = [
                "training_mechanics",
                String(report.seed),
                report.training.learningRateScheduleID,
                report.training.optimizerImplementation,
                String(report.training.adamBeta1),
                String(report.training.adamBeta2),
                String(report.training.adamEpsilon),
                String(report.training.decoupledWeightDecay),
                report.training.gradientClipMode,
                report.training.lossReduction,
            ]
            trainingMechanics.append(
                String(report.training.warmupSteps)
            )
            trainingMechanics.append(
                String(report.training.minimumLearningRate)
            )
            trainingMechanics.append(
                String(report.training.weightDecay)
            )
            trainingMechanics.append(
                report.training.precision
            )
            trainingMechanics.append(
                String(report.training.gradientClipNorm ?? -1)
            )
            trainingMechanics.append(
                String(report.training.fullWeightTraining)
            )
            trainingMechanics.append(
                String(
                    report.training
                        .shiftedCausalLanguageModelLoss
                )
            )
            trainingMechanics.append(
                String(report.training.promptTokensMasked)
            )
            trainingMechanics.append(
                String(
                    report.training
                        .targetTokenWeightedEffectiveBatchLoss
                )
            )
            trainingMechanics.append(
                String(report.training.answerTokensContributed)
            )
            trainingMechanics.append(
                String(report.training.firstGradientNorm)
            )
            trainingMechanics.append(
                String(report.training.firstClippedGradientNorm)
            )
            trainingMechanics.append(
                String(report.training.firstWeightUpdateNorm)
            )
            trainingMechanics.append(
                String(
                    report.training
                        .causalPrefixMaximumLogitDelta
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .suffixEffectMaximumLogitDelta
                )
            )
            trainingMechanics.append(
                String(report.training.logitsFinite)
            )
            trainingMechanics.append(
                String(
                    report.training
                        .repeatedInferenceMaximumLogitDelta
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .cachedUncachedMaximumLogitDelta
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .cachedUncachedGreedyTokenParity
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .cachedUncachedMultiStepMaximumLogitDelta
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .cachedUncachedMultiStepGreedyTokenParity
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .cachedUncachedMultiStepComparedDecisionCount
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .cachedUncachedMultiStepUnevenEOS
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .initializationFingerprintSHA256.count
                        == 64
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .sameSeedInitializationReplayExact
                )
            )
            trainingMechanics.append(
                report.training.hyperparameterSearchID
            )
            trainingMechanics.append(
                String(
                    report.training.learningRateDiscoverySeed
                )
            )
            trainingMechanics.append(
                String(report.training.replicateID.count == 64)
            )
            trainingMechanics.append(
                report.training.declaredLearningRateGrid
                    .map { String($0) }.joined(separator: ",")
            )
            trainingMechanics.append(
                report.training.declaredReplicateSeeds
                    .map { String($0) }.joined(separator: ",")
            )
            trainingMechanics.append(
                report.training.persistencePolicy.rawValue
            )
            trainingMechanics.append(
                report.training.configurationArtifactFileName
            )
            trainingMechanics.append(
                String(
                    isSHA256(
                        report.training
                            .configurationArtifactSHA256
                    )
                )
            )
            trainingMechanics.append(
                String(
                    report.durability?.configurationSHA256
                        == report.training
                            .configurationArtifactSHA256
                )
            )
            trainingMechanics.append(
                String(
                    report.training
                        .interruptedTrajectoryReplayExact
                )
            )
            appendRecord(
                trainingMechanics.joined(separator: "|")
            )
            for heldout in report.training.heldoutLossRows
                .sorted(by: { $0.rowID < $1.rowID })
            {
                appendRecord(
                    [
                        "heldout_loss",
                        String(report.seed),
                        heldout.rowID,
                        heldout.rowSHA256,
                        heldout.selectionSplitID,
                        heldout.targetClass,
                        heldout.semanticFamily,
                        String(heldout.targetTokenCount),
                        String(heldout.nonPaddingTokenCount),
                        String(heldout.crossEntropyBefore),
                        String(heldout.crossEntropyAfter),
                    ].joined(separator: "|")
                )
            }
            let heldoutFamilies = Set(
                report.training
                    .heldoutFamilyCrossEntropyBefore.keys
            ).union(
                report.training
                    .heldoutFamilyCrossEntropyAfter.keys
            )
            for family in heldoutFamilies.sorted() {
                appendRecord(
                    [
                        "heldout_family_loss",
                        String(report.seed),
                        family,
                        String(
                            report.training
                                .heldoutFamilyCrossEntropyBefore[
                                    family
                                ] ?? .nan
                        ),
                        String(
                            report.training
                                .heldoutFamilyCrossEntropyAfter[
                                    family
                                ] ?? .nan
                        ),
                    ].joined(separator: "|")
                )
            }
            let replay = report.sameSeedReplay
            appendRecord(
                [
                    "same_seed_replay",
                    String(report.seed),
                    String(replay.optimizerSteps),
                    replay.scheduledRowIDs.joined(separator: ","),
                    String(
                        replay.initialFingerprintSHA256
                            == replay
                                .replayInitialFingerprintSHA256
                    ),
                    replay.initialFingerprintSHA256,
                    replay.replayInitialFingerprintSHA256,
                    String(replay.initializationReplayExact),
                    String(replay.differentSeed),
                    replay.differentSeedInitialFingerprintSHA256,
                    String(
                        replay.differentSeedInitializationDiverged
                    ),
                    String(replay.firstStepLoss),
                    String(replay.replayStepLoss),
                    String(replay.stepLossExact),
                    String(
                        replay.postStepFingerprintSHA256
                            == replay
                                .replayPostStepFingerprintSHA256
                    ),
                    replay.postStepFingerprintSHA256,
                    replay.replayPostStepFingerprintSHA256,
                    String(
                        replay.postStepSelectedParametersExact
                    ),
                    String(
                        replay
                            .postStepSelectedParameterMaximumDelta
                    ),
                    String(replay.fixedPromptMaximumLogitDelta),
                    String(replay.fixedPromptGreedyTokenID),
                    String(replay.replayFixedPromptGreedyTokenID),
                    String(replay.fixedPromptGreedyRunnerUpMargin),
                    String(
                        replay
                            .replayFixedPromptGreedyRunnerUpMargin
                    ),
                    String(replay.fixedPromptGreedyTokenExact),
                    String(
                        replay.fixedPromptBehavioralReplayExact
                    ),
                    replay.fixedPromptResultSHA256,
                    replay.replayFixedPromptResultSHA256,
                    String(
                        replay.fixedPromptResultSHA256
                            == replay
                                .replayFixedPromptResultSHA256
                    ),
                    String(replay.fixedPromptResultExact),
                ].joined(separator: "|")
            )
            appendSelectedParameterSamples(
                label: "same_seed_initial_parameter_sample",
                seed: report.seed,
                samples:
                    replay.initialSelectedParameterSamples
            )
            appendSelectedParameterSamples(
                label:
                    "same_seed_replay_initial_parameter_sample",
                seed: report.seed,
                samples:
                    replay.replayInitialSelectedParameterSamples
            )
            appendSelectedParameterSamples(
                label:
                    "different_seed_initial_parameter_sample",
                seed: report.seed,
                samples:
                    replay
                        .differentSeedInitialSelectedParameterSamples
            )
            appendSelectedParameterSamples(
                label: "same_seed_post_step_parameter_sample",
                seed: report.seed,
                samples:
                    replay.postStepSelectedParameterSamples
            )
            appendSelectedParameterSamples(
                label:
                    "same_seed_replay_post_step_parameter_sample",
                seed: report.seed,
                samples:
                    replay
                        .replayPostStepSelectedParameterSamples
            )
            appendRecord(
                [
                    "same_seed_fixed_prompt_logits",
                    String(report.seed),
                    replay.fixedPromptLogitFloatBitPatterns
                        .map(String.init).joined(separator: ","),
                ].joined(separator: "|")
            )
            appendRecord(
                [
                    "same_seed_replay_fixed_prompt_logits",
                    String(report.seed),
                    replay
                        .replayFixedPromptLogitFloatBitPatterns
                        .map(String.init).joined(separator: ","),
                ].joined(separator: "|")
            )
            if let durability = report.durability {
                appendRecord(
                    [
                        "durability",
                        String(report.seed),
                        durability.buildConfiguration,
                        durability.precision,
                        durability.checkpointFileName,
                        durability.checkpointSHA256,
                        durability.trainingStageFileName,
                        durability.trainingStageSHA256,
                        durability.evaluationDirectoryName,
                        String(durability.checkpointTensorCount),
                        String(
                            durability
                                .checkpointReloadWeightsExact
                        ),
                        String(
                            durability
                                .checkpointReloadMaximumWeightDelta
                        ),
                        String(
                            durability
                                .checkpointReloadMaximumLogitDelta
                        ),
                        String(
                            durability
                                .repeatedInferenceMaximumLogitDelta
                        ),
                        String(
                            durability.reloadedPredictionsExact
                        ),
                        String(
                            durability.executableSHA256
                                == report.implementation
                                    .executorArtifactSHA256
                        ),
                        String(
                            durability.configurationSHA256
                                == report.training
                                    .configurationArtifactSHA256
                        ),
                        durability.recommenderFileName,
                        durability.recommenderSHA256,
                        durability.metalLibraryArtifactSHA256,
                        String(
                            durability
                                .metalLibraryArtifactByteCount
                        ),
                        durability.metalLibraryPrimaryFileName,
                        durability.metalLibraryFallbackFileName,
                        durability.metalLibraryBundleSearchAuditID,
                        String(
                            durability
                                .metalLibraryBundleSearchBaseCount
                        ),
                        String(
                            durability
                                .metalLibraryVerifiedBundleMirrorCount
                        ),
                        String(
                            durability
                                .metalLibraryDivergentBundleCandidateCount
                        ),
                        durability
                            .metalLibrarySourceMLXSwiftRevision,
                        durability
                            .observedModelParameterDTypes
                            .joined(separator: ","),
                        durability
                            .observedTrainableParameterDTypes
                            .joined(separator: ","),
                        String(
                            durability.recommenderSHA256
                                == report.implementation
                                    .recommenderArtifactSHA256
                        ),
                        String(
                            durability.recommenderFileName
                                == report.implementation
                                    .recommenderArtifactFileName
                        ),
                    ].joined(separator: "|")
                )
            } else {
                appendRecord("durability|\(report.seed)|missing")
            }
            for shard in report.evaluationShards.sorted(by: {
                $0.fileName < $1.fileName
            }) {
                appendRecord(
                    [
                        "evaluation_shard",
                        String(report.seed),
                        shard.phase,
                        shard.fileName,
                        String(shard.rowCount),
                        shard.firstRowID,
                        shard.lastRowID,
                    ].joined(separator: "|")
                )
            }
            if let cached =
                cachedRowRecordsBySeed[report.seed]
            {
                precondition(
                    cached.records.count == cached.isASCII.count
                )
                records.append(contentsOf: cached.records)
                recordIsASCII.append(
                    contentsOf: cached.isASCII
                )
            } else {
                for row in report.rawPredictions.sorted(by: {
                    $0.rowID < $1.rowID
                }) {
                    appendRecord(
                        rowInvariantRecord(
                            seed: report.seed,
                            row: row
                        )
                    )
                }
            }
        }
        return InvariantRecordCollection(
            records: records,
            isASCII: recordIsASCII
        )
    }

    private static func rowInvariantRecord(
        seed: Int,
        row: ErgenticsNativeLanguageCanary.RawPrediction
    ) -> String {
        let promptIDs = row.promptTokenIDs
            .map(String.init).joined(separator: ",")
        let targetIDs = row.targetTokenIDs
            .map(String.init).joined(separator: ",")
        let zeroIDs = row.zeroShotPredictionTokenIDs
            .map(String.init).joined(separator: ",")
        let zeroLogProbabilities =
            row.zeroShotTokenLogProbabilities
                .map { String($0) }.joined(separator: ",")
        let trainedIDs = row.trainedPredictionTokenIDs
            .map(String.init).joined(separator: ",")
        let trainedLogProbabilities =
            row.trainedTokenLogProbabilities
                .map { String($0) }.joined(separator: ",")
        let hashesRegrade =
            evaluationRowSHA256(row)
                == row.evaluationRowSHA256
                && corpusRowMatchesAuthority(row)
        let fields: [String] = [
            "row",
            String(seed),
            row.rowID,
            row.split.rawValue,
            row.semanticFamily,
            row.invariantIDs.joined(separator: ","),
            row.mutationID ?? "none",
            row.abstentionReason ?? "none",
            row.prompt,
            promptIDs,
            row.target,
            targetIDs,
            row.promptGroupingKeyID,
            String(row.promptGroupingKey),
            String(row.generationDecisionBudget),
            row.allowedCompletionTokenSetSHA256,
            String(row.eosAvailableAtEveryDecision),
            String(row.targetIndependentDecisionBudget),
            String(row.zeroShotDecisionsExecuted),
            row.zeroShotPrediction ?? "invalid_utf8",
            zeroIDs,
            String(row.zeroShotMeanLogProbability),
            zeroLogProbabilities,
            String(row.zeroShotTerminatedByEOS),
            row.zeroShotTerminationReason,
            String(row.zeroShotUTF8Valid),
            row.zeroShotEOSLogProbability.map { String($0) }
                ?? "none",
            String(
                row
                    .zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity
            ),
            String(
                row.zeroShotDisallowedFullVocabularyArgmaxCount
            ),
            String(
                row
                    .zeroShotMaximumDisallowedTokenProbabilityMass
            ),
            String(row.zeroShotExactMatch),
            String(row.zeroShotSemanticVerifierPass),
            String(row.zeroShotAbstentionDecision),
            String(row.zeroShotLatencySeconds),
            row.trainedPrediction ?? "invalid_utf8",
            trainedIDs,
            String(row.trainedMeanLogProbability),
            trainedLogProbabilities,
            String(row.trainedTerminatedByEOS),
            row.trainedTerminationReason,
            String(row.trainedUTF8Valid),
            row.trainedEOSLogProbability.map { String($0) }
                ?? "none",
            String(
                row
                    .trainedRawFullVocabularyAllowedSupportGreedyTokenParity
            ),
            String(
                row.trainedDisallowedFullVocabularyArgmaxCount
            ),
            String(
                row
                    .trainedMaximumDisallowedTokenProbabilityMass
            ),
            String(row.trainedExactMatch),
            String(row.trainedSemanticVerifierPass),
            String(row.trainedAbstentionDecision),
            String(row.trainedLatencySeconds),
            String(row.trainedDecisionsExecuted),
            String(hashesRegrade),
        ]
        return fields.joined(separator: "|")
    }

    private static func mutationSweep(
        evaluation: Evaluation,
        tokenizerManifestData: Data?,
        corpusManifestData: Data?,
        packageResolvedBinding:
            ObservedPackageResolvedBinding?,
        executorArtifactDataByFileName: [String: Data],
        recommenderArtifactDataByFileName: [String: Data],
        configurationArtifactDataBySeed: [Int: Data],
        metalLibraryBindingsBySeed:
            [Int: ObservedMetalLibraryBinding]
    ) -> MutationSweepRun {
        let sweepStarted =
            ProcessInfo.processInfo.systemUptime
        guard evaluation.materialReload,
              evaluation.sz,
              evaluation.foundationCorpus,
              evaluation.rawExecutor,
              evaluation.causalMechanics,
              evaluation.durability,
              evaluation.sameSeedReplay,
              evaluation.seedConsensus,
              evaluation.capability,
              let baseFingerprint = evaluation.fingerprint,
              tokenizerManifestData != nil,
              corpusManifestData != nil else {
            return MutationSweepRun(
                sweep: nil,
                phaseDurationsSeconds: [
                    "mutation_sweep_total":
                        ProcessInfo.processInfo.systemUptime
                            - sweepStarted,
                ]
            )
        }
        var reportSynthesisSeconds = 0.0
        var namedLegSeconds = 0.0
        var recordConstructionSeconds = 0.0
        var fingerprintSeconds = 0.0
        let planStarted =
            ProcessInfo.processInfo.systemUptime
        let baselinePlan = finiteFieldBaselinePlan(
            cacheKey: evaluation.exactArtifactCacheKey,
            records: evaluation.invariantRecords,
            recordIsASCII: evaluation.invariantRecordIsASCII
        )
        let planLookupSeconds =
            ProcessInfo.processInfo.systemUptime - planStarted

        // Recompute the restored baseline exactly once through the original,
        // independent bytewise implementation. Mutation reports are values;
        // no mutation can alter `evaluation` or this restored product.
        let restorationStarted =
            ProcessInfo.processInfo.systemUptime
        let independentlyRestoredFingerprint =
            finiteFieldFingerprint(evaluation.invariantRecords)
        let restorationSeconds =
            ProcessInfo.processInfo.systemUptime
                - restorationStarted
        let restorationExact =
            independentlyRestoredFingerprint == baseFingerprint
                && baselinePlan.fingerprint == baseFingerprint
        let cachedRowsBySeed = Dictionary(
            uniqueKeysWithValues: evaluation.reports.map {
                report in
                let prefix = "row|\(report.seed)|"
                let indices = evaluation.invariantRecords.indices
                    .filter {
                        evaluation.invariantRecords[$0]
                            .hasPrefix(prefix)
                    }
                return (
                    report.seed,
                    InvariantRecordCollection(
                        records: indices.map {
                            evaluation.invariantRecords[$0]
                        },
                        isASCII: indices.map {
                            evaluation.invariantRecordIsASCII[$0]
                        }
                    )
                )
            }
        )
        let results = Mutation.allCases.map { mutation in
            let reportStarted =
                ProcessInfo.processInfo.systemUptime
            let mutated = mutatedReports(
                evaluation.reports,
                mutation: mutation
            )
            reportSynthesisSeconds +=
                ProcessInfo.processInfo.systemUptime
                    - reportStarted
            let namedLegStarted =
                ProcessInfo.processInfo.systemUptime
            let detected = namedLegFails(
                mutation: mutation,
                reports: mutated,
                tokenizer: evaluation.tokenizer,
                corpus: evaluation.corpus,
                tokenizerManifestData: tokenizerManifestData,
                corpusManifestData: corpusManifestData,
                packageResolvedBinding:
                    packageResolvedBinding,
                executorArtifactDataByFileName:
                    executorArtifactDataByFileName,
                recommenderArtifactDataByFileName:
                    recommenderArtifactDataByFileName,
                configurationArtifactDataBySeed:
                    configurationArtifactDataBySeed,
                metalLibraryBindingsBySeed:
                    metalLibraryBindingsBySeed
            )
            namedLegSeconds +=
                ProcessInfo.processInfo.systemUptime
                    - namedLegStarted
            var reusableRows = cachedRowsBySeed
            if mutation.mutatesRawPredictions,
               let mutatedSeed = evaluation.reports.first?.seed
            {
                reusableRows.removeValue(forKey: mutatedSeed)
            }
            let recordStarted =
                ProcessInfo.processInfo.systemUptime
            let mutatedRecordCollection = invariantRecords(
                reports: mutated,
                tokenizer: evaluation.tokenizer,
                corpus: evaluation.corpus,
                rowHashRegrade:
                    mutation != .executorRowHash,
                cachedRowRecordsBySeed: reusableRows
            )
            let mutatedRecords =
                mutatedRecordCollection.records
            recordConstructionSeconds +=
                ProcessInfo.processInfo.systemUptime
                    - recordStarted
            let fingerprintStarted =
                ProcessInfo.processInfo.systemUptime
            let mutatedFingerprint =
                finiteFieldFingerprint(
                    mutatedRecords,
                    recordIsASCII:
                        mutatedRecordCollection.isASCII,
                    using: baselinePlan
                )
            fingerprintSeconds +=
                ProcessInfo.processInfo.systemUptime
                    - fingerprintStarted
            return MutationResult(
                mutation: mutation,
                expectedFailedLeg:
                    mutation.expectedFailedLeg,
                detected: detected,
                fingerprintDiverged:
                    mutatedFingerprint != baseFingerprint,
                restored:
                    rawUTF8RecordsExactlyEqual(
                        baselinePlan.originalRecords,
                        evaluation.invariantRecords,
                        leftIsASCII:
                            baselinePlan.originalRecordIsASCII,
                        rightIsASCII:
                            evaluation.invariantRecordIsASCII
                    ),
                restoredFingerprintExact: restorationExact
            )
        }
        let grounded = results.count == Mutation.allCases.count
            && results.allSatisfy {
                $0.detected
                    && $0.fingerprintDiverged
                    && $0.restored
                    && $0.restoredFingerprintExact
            }
        let sweep = MutationSweep(
            outcome: grounded ? "GROUNDED" : "ABSTAIN",
            triadicVerdict: grounded
                ? "independentThreePlus(\(results.count))"
                : "oracleDerived(\(results.filter(\.detected).count))",
            results: results
        )
        return MutationSweepRun(
            sweep: sweep,
            phaseDurationsSeconds: [
                "mutation_baseline_plan_lookup":
                    planLookupSeconds,
                "mutation_independent_restoration_fingerprint":
                    restorationSeconds,
                "mutation_report_synthesis":
                    reportSynthesisSeconds,
                "mutation_named_leg_regrade":
                    namedLegSeconds,
                "mutation_record_construction":
                    recordConstructionSeconds,
                "mutation_fingerprint":
                    fingerprintSeconds,
                "mutation_sweep_total":
                    ProcessInfo.processInfo.systemUptime
                        - sweepStarted,
            ]
        )
    }

    private static func namedLegFails(
        mutation: Mutation,
        reports: [ErgenticsNativeLanguageCanary.Report],
        tokenizer: PrimeNativeByteTokenizer.Manifest?,
        corpus: ErgenticsPrimeNativeTextCorpus.Manifest?,
        tokenizerManifestData: Data?,
        corpusManifestData: Data?,
        packageResolvedBinding:
            ObservedPackageResolvedBinding?,
        executorArtifactDataByFileName: [String: Data],
        recommenderArtifactDataByFileName: [String: Data],
        configurationArtifactDataBySeed: [Int: Data],
        metalLibraryBindingsBySeed:
            [Int: ObservedMetalLibraryBinding]
    ) -> Bool {
        switch mutation {
        case .obsoleteSchema, .lineage,
             .quantHessianLineage, .profile,
             .debugBuildConfiguration,
             .nonFloat32Precision:
            return !materialReportCoreValid(reports)
        case .tokenizer, .corpusSplitLeakage,
             .corpusLabelLeakage, .corpusOverCapTarget,
             .corpusPromptWindow:
            return !foundationCorpusRegrade(
                reports: reports,
                tokenizer: tokenizer,
                corpus: corpus
            )
        case .targetLengthOracleLeakage,
             .targetDependentPromptGrouping,
             .constrainedASCIIDecoding,
             .eosUnavailable,
             .immediateEOSMeanOmission,
             .supportWitnessInconsistency,
             .executorPrediction, .executorRowHash:
            return !rawExecutorRegrade(reports)
        case .causalTraining, .heldoutLossEvidence,
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
            return !causalMechanicsValid(reports)
        case .executorArtifactDigest,
             .executorArtifactFileName,
             .recommenderArtifactDigest,
             .recommenderArtifactFileName,
             .configurationArtifactDigest,
             .configurationArtifactFileName,
             .configurationWallCapMismatch,
             .metalLibraryArtifactDigest,
             .metalLibraryBundleShadowAudit:
            return !provenanceArtifactsValid(
                reports: reports,
                tokenizerManifestData: tokenizerManifestData,
                corpusManifestData: corpusManifestData,
                packageResolvedBinding:
                    packageResolvedBinding,
                executorDataByFileName:
                    executorArtifactDataByFileName,
                recommenderDataByFileName:
                    recommenderArtifactDataByFileName,
                configurationDataBySeed:
                    configurationArtifactDataBySeed,
                metalLibraryBindingsBySeed:
                    metalLibraryBindingsBySeed
            )
        case .durabilityCheckpoint:
            return !durabilityValid(reports)
        case .durabilityProvenanceMismatch:
            return !durabilityValid(reports)
                || !provenanceArtifactsValid(
                    reports: reports,
                    tokenizerManifestData:
                        tokenizerManifestData,
                    corpusManifestData:
                        corpusManifestData,
                    packageResolvedBinding:
                        packageResolvedBinding,
                    executorDataByFileName:
                        executorArtifactDataByFileName,
                    recommenderDataByFileName:
                        recommenderArtifactDataByFileName,
                    configurationDataBySeed:
                        configurationArtifactDataBySeed,
                    metalLibraryBindingsBySeed:
                        metalLibraryBindingsBySeed
                )
        case .sameSeedReplay:
            return !sameSeedReplayValid(reports)
        case .seedConsensus:
            return !seedConsensusValid(reports)
        case .malformedAbstention, .trainedSupportAssistance:
            return !capabilityValid(reports)
        }
    }

    private static func materialReportCoreValid(
        _ reports: [ErgenticsNativeLanguageCanary.Report]
    ) -> Bool {
        guard reports.count
                == ErgenticsNativeLanguageCanary.frozenSeeds.count
        else {
            return false
        }
        let required = [
            "N1_schema_and_random_init_text_lineage",
            "N2_exact_maintained_engine_profile",
            "N3_native_512_tokenizer_replay",
            "N4_first_party_corpus_and_probe_binding",
            "N5_swift_mlx_metal_maintained_primitives",
        ]
        return reports.allSatisfy { report in
            let recommendation =
                ErgenticsNativeLanguageCanary.recommend(report)
            let byID = Dictionary(
                uniqueKeysWithValues:
                    recommendation.legs.map {
                        ($0.id, $0.pass)
                    }
            )
            return report.mode == .fullCanary
                && required.allSatisfy {
                    byID[$0] == true
                }
        }
    }

    private static func mutatedReports(
        _ reports: [ErgenticsNativeLanguageCanary.Report],
        mutation: Mutation
    ) -> [ErgenticsNativeLanguageCanary.Report] {
        guard let first = reports.first else { return reports }
        var changed = reports
        switch mutation {
        case .obsoleteSchema:
            changed[0] = copy(first, schemaVersion: "1")
        case .lineage:
            changed[0] = copy(
                first,
                familyID: first.familyID + ".stale"
            )
        case .quantHessianLineage:
            changed[0] = copyWithLegacyLineage(first)
        case .profile:
            let p = first.profile
            changed[0] = copy(
                first,
                profile: .init(
                    profileID: p.profileID,
                    vocabularySize: p.vocabularySize - 1,
                    maximumSequenceLength:
                        p.maximumSequenceLength,
                    expectedParameterCount:
                        p.expectedParameterCount,
                    observedParameterCount:
                        p.observedParameterCount,
                    observedTrainableParameterCount:
                        p.observedTrainableParameterCount
                )
            )
        case .debugBuildConfiguration:
            changed[0] = copy(
                first,
                implementation: copy(
                    first.implementation,
                    buildConfiguration: "debug"
                ),
                durability: first.durability.map {
                    copy(
                        $0,
                        buildConfiguration: "debug"
                    )
                }
            )
        case .nonFloat32Precision:
            changed[0] = copy(
                first,
                implementation: copy(
                    first.implementation,
                    precision: "bfloat16",
                    observedModelParameterDTypes: ["bfloat16"],
                    observedTrainableParameterDTypes: [
                        "bfloat16"
                    ]
                ),
                training: copy(
                    first.training,
                    precision: "bfloat16"
                ),
                durability: first.durability.map {
                    copy(
                        $0,
                        precision: "bfloat16",
                        observedModelParameterDTypes: ["bfloat16"],
                        observedTrainableParameterDTypes: [
                            "bfloat16"
                        ]
                    )
                }
            )
        case .tokenizer:
            let t = first.tokenizer
            changed[0] = copy(
                first,
                tokenizer: .init(
                    tokenizerID: t.tokenizerID + ".stale",
                    manifestSHA256: t.manifestSHA256,
                    vocabularySize: t.vocabularySize,
                    deterministicReplayPassed:
                        t.deterministicReplayPassed,
                    independentFoundationReplayPassed:
                        t.independentFoundationReplayPassed
                )
            )
        case .corpusSplitLeakage:
            changed[0] = copy(
                first,
                corpus: copy(
                    first.corpus,
                    disjointSplitsVerified: false
                )
            )
        case .corpusLabelLeakage:
            if let pair = first.rawPredictions.indices
                .dropFirst().first.map({ (0, $0) })
            {
                var rows = first.rawPredictions
                let source = rows[pair.0]
                let destination = rows[pair.1]
                let leaked = copy(
                    destination,
                    prompt: source.prompt,
                    target: source.target,
                    targetTokenIDs: source.targetTokenIDs,
                    trainedPrediction: source.target,
                    trainedPredictionTokenIDs:
                        source.targetTokenIDs,
                    trainedExactMatch: true,
                    corpusRowSHA256: evaluationRowSHA256(
                        rowID: destination.rowID,
                        split: destination.split,
                        semanticFamily:
                            destination.semanticFamily,
                        mutationID: destination.mutationID,
                        prompt: source.prompt,
                        target: source.target
                    )
                )
                rows[pair.1] = leaked
                changed[0] = copy(
                    first,
                    corpus: corpusWithRowHash(
                        first.corpus,
                        rowID: leaked.rowID,
                        sha256: leaked.corpusRowSHA256
                    ),
                    rawPredictions: rows
                )
            }
        case .corpusOverCapTarget:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                let row = rows[index]
                let target = String(
                    repeating: "A",
                    count:
                        ErgenticsNativeLanguageCanary
                            .maximumGenerationTokenDecisions
                )
                let ids =
                    PrimeNativeByteTokenizer.encode(target)
                let mutated = copy(
                    row,
                    target: target,
                    targetTokenIDs: ids,
                    corpusRowSHA256: evaluationRowSHA256(
                        rowID: row.rowID,
                        split: row.split,
                        semanticFamily: row.semanticFamily,
                        mutationID: row.mutationID,
                        prompt: row.prompt,
                        target: target
                    )
                )
                rows[index] = mutated
                changed[0] = copy(
                    first,
                    corpus: copy(
                        corpusWithRowHash(
                            first.corpus,
                            rowID: row.rowID,
                            sha256: mutated.corpusRowSHA256
                        ),
                        maximumEvaluationTargetTokenCount:
                            ids.count,
                        overCapTargetRowIDs: [row.rowID]
                    ),
                    rawPredictions: rows
                )
            }
        case .corpusPromptWindow:
            let maximumPrompt =
                first.corpus.maximumEvaluationPromptTokenCount
            let rowID = first.rawPredictions.max {
                $0.promptTokenIDs.count
                    < $1.promptTokenIDs.count
            }?.rowID ?? "missing_prompt_row"
            changed[0] = copy(
                first,
                corpus: copy(
                    first.corpus,
                    generationContextLength:
                        maximumPrompt
                            + ErgenticsNativeLanguageCanary
                                .maximumGenerationTokenDecisions
                            - 1,
                    insufficientGenerationContextRowIDs:
                        [rowID]
                )
            )
        case .targetLengthOracleLeakage:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                let row = rows[index]
                rows[index] = copy(
                    row,
                    generationDecisionBudget:
                        row.targetTokenIDs.count + 1,
                    targetIndependentDecisionBudget: false
                )
                changed[0] = copy(first, rawPredictions: rows)
            }
        case .targetDependentPromptGrouping:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                let row = rows[index]
                rows[index] = copy(
                    row,
                    promptGroupingKeyID:
                        "target_token_count_oracle_v0",
                    promptGroupingKey: row.targetTokenIDs.count
                )
                changed[0] = copy(first, rawPredictions: rows)
            }
        case .constrainedASCIIDecoding:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                let asciiIDs =
                    [PrimeNativeByteTokenizer
                        .endOfSequenceTokenID]
                    + (0 ... 127).map {
                        PrimeNativeByteTokenizer.byteTokenBase + $0
                    }
                let asciiHash = sha256(
                    Data(
                        asciiIDs.map(String.init)
                            .joined(separator: "\n").utf8
                    )
                )
                rows[index] = copy(
                    rows[index],
                    allowedCompletionTokenSetSHA256: asciiHash
                )
                changed[0] = copy(first, rawPredictions: rows)
            }
        case .eosUnavailable:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                rows[index] = copy(
                    rows[index],
                    eosAvailableAtEveryDecision: false
                )
                changed[0] = copy(first, rawPredictions: rows)
            }
        case .immediateEOSMeanOmission:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                let row = rows[index]
                if let authority =
                    authoritativeRowsByID[row.rowID]
                {
                    let regrade = predictionRegrade(
                        tokenIDs: [],
                        terminatedByEOS: true,
                        authority: authority
                    )
                    rows[index] = copy(
                        row,
                        zeroShotPrediction: regrade.text ?? "",
                        zeroShotPredictionTokenIDs: [],
                        // Deliberately reproduces the historical empty-byte
                        // mean (0) while the one executed EOS decision has a
                        // finite nonzero log probability.
                        zeroShotMeanLogProbability: 0,
                        zeroShotTokenLogProbabilities: [],
                        zeroShotTerminatedByEOS: true,
                        zeroShotTerminationReason: "eos",
                        zeroShotUTF8Valid: regrade.utf8Valid,
                        zeroShotEOSLogProbability: -7.25,
                        zeroShotExactMatch: regrade.exact,
                        zeroShotSemanticVerifierPass:
                            regrade.semantic,
                        zeroShotAbstentionDecision:
                            regrade.abstention,
                        zeroShotDecisionsExecuted: 1
                    )
                    changed[0] = copy(
                        first,
                        rawPredictions: rows
                    )
                }
            }
        case .supportWitnessInconsistency:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                rows[index] = copy(
                    rows[index],
                    zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity:
                        true,
                    zeroShotDisallowedFullVocabularyArgmaxCount:
                        1,
                    zeroShotMaximumDisallowedTokenProbabilityMass:
                        0.25
                )
                changed[0] = copy(
                    first,
                    rawPredictions: rows
                )
            }
        case .trainedSupportAssistance:
            if let index = first.rawPredictions.firstIndex(
                where: {
                    $0.split == .combinationHoldout
                }
            ) {
                var rows = first.rawPredictions
                rows[index] = copy(
                    rows[index],
                    trainedRawFullVocabularyAllowedSupportGreedyTokenParity:
                        false,
                    trainedDisallowedFullVocabularyArgmaxCount:
                        1,
                    trainedMaximumDisallowedTokenProbabilityMass:
                        0.25
                )
                changed[0] = copy(
                    first,
                    rawPredictions: rows
                )
            }
        case .executorPrediction:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                let row = rows[index]
                rows[index] = copy(
                    row,
                    trainedPrediction: "corrupt",
                    trainedPredictionTokenIDs:
                        row.trainedPredictionTokenIDs,
                    trainedExactMatch: row.trainedExactMatch
                )
                changed[0] = copy(
                    first,
                    rawPredictions: rows
                )
            }
        case .executorRowHash:
            if let index = first.rawPredictions.indices.first {
                var rows = first.rawPredictions
                let row = rows[index]
                let wrong = String(repeating: "f", count: 64)
                rows[index] = copy(
                    row,
                    corpusRowSHA256: wrong
                )
                changed[0] = copy(
                    first,
                    corpus: corpusWithRowHash(
                        first.corpus,
                        rowID: row.rowID,
                        sha256: wrong
                    ),
                    rawPredictions: rows
                )
            }
        case .causalTraining:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    shiftedCausalLanguageModelLoss: false
                )
            )
        case .heldoutLossEvidence:
            if let index =
                first.training.heldoutLossRows.indices.first
            {
                var rows = first.training.heldoutLossRows
                let row = rows[index]
                rows[index] = .init(
                    rowID: row.rowID,
                    rowSHA256: row.rowSHA256,
                    selectionSplitID:
                        row.selectionSplitID,
                    targetClass: row.targetClass,
                    semanticFamily: row.semanticFamily,
                    targetTokenCount: row.targetTokenCount,
                    nonPaddingTokenCount:
                        row.nonPaddingTokenCount,
                    crossEntropyBefore:
                        row.crossEntropyBefore,
                    crossEntropyAfter:
                        row.crossEntropyAfter + 0.25
                )
                changed[0] = copy(
                    first,
                    training: copy(
                        first.training,
                        heldoutLossRows: rows
                    )
                )
            }
        case .refusalReasonScheduleCount:
            var counts =
                first.training.scheduledRefusalReasonRows
            counts["ambiguous_query", default: 0] += 1
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    scheduledRefusalReasonRows: counts
                )
            )
        case .refusalReasonScheduleHash:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    scheduledRefusalReasonScheduleSHA256:
                        mutatedSHA256(
                            first.training
                                .scheduledRefusalReasonScheduleSHA256
                        )
                )
            )
        case .optimizerProvenance:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    optimizerImplementation:
                        "hand_rolled_adamw"
                )
            )
        case .executorWallNonFinite:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    measuredTotalExecutorWallSeconds:
                        .infinity
                )
            )
        case .executorWallZero:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    declaredMaximumExecutorWallSeconds: 0
                )
            )
        case .executorWallOverCap:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    measuredTotalExecutorWallSeconds:
                        first.training
                            .declaredMaximumExecutorWallSeconds
                            + 1
                )
            )
        case .cachedUncachedMultiStepDelta:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    cachedUncachedMultiStepMaximumLogitDelta:
                        0.001
                )
            )
        case .cachedUncachedMultiStepParity:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    cachedUncachedMultiStepGreedyTokenParity:
                        false
                )
            )
        case .cachedUncachedMultiStepDecisionCount:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    cachedUncachedMultiStepComparedDecisionCount:
                        1
                )
            )
        case .cachedUncachedMultiStepUnevenEOS:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    cachedUncachedMultiStepUnevenEOS: false
                )
            )
        case .executorArtifactDigest:
            changed[0] = copy(
                first,
                implementation: copy(
                    first.implementation,
                    executorArtifactSHA256:
                        mutatedSHA256(
                            first.implementation
                                .executorArtifactSHA256
                        )
                )
            )
        case .executorArtifactFileName:
            changed[0] = copy(
                first,
                implementation: copy(
                    first.implementation,
                    executorArtifactFileName:
                        "../PrimeNativeLanguageSwiftCanary"
                )
            )
        case .configurationArtifactDigest:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    configurationArtifactSHA256:
                        mutatedSHA256(
                            first.training
                                .configurationArtifactSHA256
                    )
                )
            )
        case .recommenderArtifactDigest:
            changed[0] = copy(
                first,
                implementation: copy(
                    first.implementation,
                    recommenderArtifactSHA256:
                        mutatedSHA256(
                            first.implementation
                                .recommenderArtifactSHA256
                        )
                )
            )
        case .recommenderArtifactFileName:
            changed[0] = copy(
                first,
                implementation: copy(
                    first.implementation,
                    recommenderArtifactFileName:
                        "../PrimeNativeLanguageCanaryRecommend"
                )
            )
        case .configurationArtifactFileName:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    configurationArtifactFileName: ""
                )
            )
        case .configurationWallCapMismatch:
            changed[0] = copy(
                first,
                training: copy(
                    first.training,
                    declaredMaximumExecutorWallSeconds:
                        first.training
                            .declaredMaximumExecutorWallSeconds
                            - 1
                )
            )
        case .metalLibraryArtifactDigest:
            changed[0] = copy(
                first,
                implementation: copy(
                    first.implementation,
                    metalLibraryArtifactSHA256:
                        mutatedSHA256(
                            first.implementation
                                .metalLibraryArtifactSHA256
                        )
                )
            )
        case .metalLibraryBundleShadowAudit:
            changed[0] = copy(
                first,
                implementation: copy(
                    first.implementation,
                    metalLibraryDivergentBundleCandidateCount:
                        1
                )
            )
        case .durabilityCheckpoint:
            if let durability = first.durability {
                changed[0] = copy(
                    first,
                    durability: copy(
                        durability,
                        checkpointReloadWeightsExact: false
                    )
                )
            }
        case .durabilityProvenanceMismatch:
            if let durability = first.durability {
                changed[0] = copy(
                    first,
                    durability: copy(
                        durability,
                        executableSHA256:
                            mutatedSHA256(
                                durability.executableSHA256
                            )
                    )
                )
            }
        case .sameSeedReplay:
            var replayLogits =
                first.sameSeedReplay
                    .replayFixedPromptLogitFloatBitPatterns
            if !replayLogits.isEmpty {
                replayLogits[0] ^= 1
            }
            changed[0] = copy(
                first,
                sameSeedReplay: copy(
                    first.sameSeedReplay,
                    replayFixedPromptLogitFloatBitPatterns:
                        replayLogits
                )
            )
        case .seedConsensus:
            changed[0] = copy(first, seed: 99_991)
        case .malformedAbstention:
            if let index = first.rawPredictions.firstIndex(
                where: { $0.split == .abstention }
            ) {
                var rows = first.rawPredictions
                let row = rows[index]
                let target = "MAYBE\n"
                let ids =
                    PrimeNativeByteTokenizer.encode(target)
                let mutated = copy(
                    row,
                    target: target,
                    targetTokenIDs: ids,
                    trainedPrediction: target,
                    trainedPredictionTokenIDs: ids,
                    trainedExactMatch: true,
                    corpusRowSHA256: evaluationRowSHA256(
                        rowID: row.rowID,
                        split: row.split,
                        semanticFamily: row.semanticFamily,
                        mutationID: row.mutationID,
                        prompt: row.prompt,
                        target: target
                    )
                )
                rows[index] = mutated
                changed[0] = copy(
                    first,
                    corpus: corpusWithRowHash(
                        first.corpus,
                        rowID: row.rowID,
                        sha256: mutated.corpusRowSHA256
                    ),
                    rawPredictions: rows
                )
            }
        }
        return changed
    }

    private static func copy(
        _ report: ErgenticsNativeLanguageCanary.Report,
        schemaVersion: String? = nil,
        familyID: String? = nil,
        generationContractID: String? = nil,
        seed: Int? = nil,
        profile: ErgenticsNativeLanguageCanary.ProfileBinding?
            = nil,
        tokenizer:
            ErgenticsNativeLanguageCanary.TokenizerBinding? = nil,
        corpus: ErgenticsNativeLanguageCanary.CorpusBinding?
            = nil,
        implementation:
            ErgenticsNativeLanguageCanary
                .ImplementationEvidence? = nil,
        training: ErgenticsNativeLanguageCanary.TrainingEvidence?
            = nil,
        sameSeedReplay:
            ErgenticsNativeLanguageCanary
                .SameSeedReplayEvidence? = nil,
        durability:
            ErgenticsNativeLanguageCanary.DurabilityEvidence? = nil,
        rawPredictions:
            [ErgenticsNativeLanguageCanary.RawPrediction]? = nil
    ) -> ErgenticsNativeLanguageCanary.Report {
        .init(
            schemaVersion:
                schemaVersion ?? report.schemaVersion,
            familyID: familyID ?? report.familyID,
            lineageID: report.lineageID,
            mode: report.mode,
            seed: seed ?? report.seed,
            parentCheckpointSHA256:
                report.parentCheckpointSHA256,
            legacySymbolicManifestSHA256:
                report.legacySymbolicManifestSHA256,
            generationContractID:
                generationContractID
                    ?? report.generationContractID,
            profile: profile ?? report.profile,
            tokenizer: tokenizer ?? report.tokenizer,
            corpus: corpus ?? report.corpus,
            implementation:
                implementation ?? report.implementation,
            training: training ?? report.training,
            sameSeedReplay:
                sameSeedReplay ?? report.sameSeedReplay,
            durability: durability ?? report.durability,
            evaluationShards: report.evaluationShards,
            rawPredictions:
                rawPredictions ?? report.rawPredictions
        )
    }

    private static func copyWithLegacyLineage(
        _ report: ErgenticsNativeLanguageCanary.Report
    ) -> ErgenticsNativeLanguageCanary.Report {
        ErgenticsNativeLanguageCanary.Report(
            schemaVersion: report.schemaVersion,
            familyID: report.familyID,
            lineageID: report.lineageID,
            mode: report.mode,
            seed: report.seed,
            parentCheckpointSHA256:
                report.parentCheckpointSHA256,
            legacySymbolicManifestSHA256:
                String(repeating: "d", count: 64),
            generationContractID:
                report.generationContractID,
            profile: report.profile,
            tokenizer: report.tokenizer,
            corpus: report.corpus,
            implementation: report.implementation,
            training: report.training,
            sameSeedReplay: report.sameSeedReplay,
            durability: report.durability,
            evaluationShards: report.evaluationShards,
            rawPredictions: report.rawPredictions
        )
    }

    private static func copy(
        _ implementation:
            ErgenticsNativeLanguageCanary.ImplementationEvidence,
        buildConfiguration: String? = nil,
        precision: String? = nil,
        executorArtifactSHA256: String? = nil,
        executorArtifactFileName: String? = nil,
        recommenderArtifactSHA256: String? = nil,
        recommenderArtifactFileName: String? = nil,
        metalLibraryArtifactSHA256: String? = nil,
        metalLibraryDivergentBundleCandidateCount: Int? = nil,
        observedModelParameterDTypes: [String]? = nil,
        observedTrainableParameterDTypes: [String]? = nil
    ) -> ErgenticsNativeLanguageCanary.ImplementationEvidence {
        .init(
            executionLanguage:
                implementation.executionLanguage,
            buildConfiguration:
                buildConfiguration
                    ?? implementation.buildConfiguration,
            precision: precision ?? implementation.precision,
            framework: implementation.framework,
            modelImplementation:
                implementation.modelImplementation,
            optimizerImplementation:
                implementation.optimizerImplementation,
            deviceType: implementation.deviceType,
            deviceDescription:
                implementation.deviceDescription,
            mlxSwiftVersion: implementation.mlxSwiftVersion,
            mlxSwiftExamplesVersion:
                implementation.mlxSwiftExamplesVersion,
            mlxSwiftLicenseID:
                implementation.mlxSwiftLicenseID,
            mlxSwiftExamplesLicenseID:
                implementation.mlxSwiftExamplesLicenseID,
            packageResolvedSHA256:
                implementation.packageResolvedSHA256,
            executorArtifactSHA256:
                executorArtifactSHA256
                    ?? implementation.executorArtifactSHA256,
            executorArtifactFileName:
                executorArtifactFileName
                    ?? implementation.executorArtifactFileName,
            recommenderArtifactSHA256:
                recommenderArtifactSHA256
                    ?? implementation.recommenderArtifactSHA256,
            recommenderArtifactFileName:
                recommenderArtifactFileName
                    ?? implementation.recommenderArtifactFileName,
            metalLibraryArtifactSHA256:
                metalLibraryArtifactSHA256
                    ?? implementation
                        .metalLibraryArtifactSHA256,
            metalLibraryArtifactByteCount:
                implementation.metalLibraryArtifactByteCount,
            metalLibraryPrimaryFileName:
                implementation.metalLibraryPrimaryFileName,
            metalLibraryFallbackFileName:
                implementation.metalLibraryFallbackFileName,
            metalLibraryBundleSearchAuditID:
                implementation.metalLibraryBundleSearchAuditID,
            metalLibraryBundleSearchBaseCount:
                implementation.metalLibraryBundleSearchBaseCount,
            metalLibraryVerifiedBundleMirrorCount:
                implementation
                    .metalLibraryVerifiedBundleMirrorCount,
            metalLibraryDivergentBundleCandidateCount:
                metalLibraryDivergentBundleCandidateCount
                    ?? implementation
                        .metalLibraryDivergentBundleCandidateCount,
            metalLibrarySourceMLXSwiftRevision:
                implementation
                    .metalLibrarySourceMLXSwiftRevision,
            observedModelParameterDTypes:
                observedModelParameterDTypes
                    ?? implementation
                        .observedModelParameterDTypes,
            observedTrainableParameterDTypes:
                observedTrainableParameterDTypes
                    ?? implementation
                        .observedTrainableParameterDTypes,
            externalPackagesSupplyExecutionPrimitivesOnly:
                implementation
                    .externalPackagesSupplyExecutionPrimitivesOnly,
            externalPackagesSupplyTextTokenizerOrWeights:
                implementation
                    .externalPackagesSupplyTextTokenizerOrWeights,
            maintainedPrimitivesOnly:
                implementation.maintainedPrimitivesOnly,
            customTransformerCode:
                implementation.customTransformerCode,
            customMetalKernels:
                implementation.customMetalKernels,
            randomInitialization:
                implementation.randomInitialization,
            importedBaseWeights:
                implementation.importedBaseWeights,
            pythonProducedEvidence:
                implementation.pythonProducedEvidence
        )
    }

    private static func copy(
        _ corpus: ErgenticsNativeLanguageCanary.CorpusBinding,
        disjointSplitsVerified: Bool? = nil,
        maximumEvaluationTargetTokenCount: Int? = nil,
        overCapTargetRowIDs: [String]? = nil,
        generationContextLength: Int? = nil,
        insufficientGenerationContextRowIDs:
            [String]? = nil,
        expectedEvaluationRowSHA256: [String: String]? = nil
    ) -> ErgenticsNativeLanguageCanary.CorpusBinding {
        .init(
            corpusID: corpus.corpusID,
            manifestSHA256: corpus.manifestSHA256,
            manifestArtifactSHA256:
                corpus.manifestArtifactSHA256,
            manifestFileName: corpus.manifestFileName,
            maximumEvaluationPromptTokenCount:
                corpus.maximumEvaluationPromptTokenCount,
            maximumEvaluationTargetTokenCount:
                maximumEvaluationTargetTokenCount
                    ?? corpus.maximumEvaluationTargetTokenCount,
            overCapTargetRowIDs:
                overCapTargetRowIDs
                    ?? corpus.overCapTargetRowIDs,
            generationContextLength:
                generationContextLength
                    ?? corpus.generationContextLength,
            insufficientGenerationContextRowIDs:
                insufficientGenerationContextRowIDs
                    ?? corpus.insufficientGenerationContextRowIDs,
            firstPartyRightsBound:
                corpus.firstPartyRightsBound,
            exactObjectHashesPresent:
                corpus.exactObjectHashesPresent,
            disjointSplitsVerified:
                disjointSplitsVerified
                    ?? corpus.disjointSplitsVerified,
            probeTokenManifestSHA256:
                corpus.probeTokenManifestSHA256,
            probeTokenManifestArtifactSHA256:
                corpus.probeTokenManifestArtifactSHA256,
            probeTokenManifestFileName:
                corpus.probeTokenManifestFileName,
            probeTokenCount: corpus.probeTokenCount,
            trainingTokenInstances:
                corpus.trainingTokenInstances,
            deduplicatedTrainingTokenInstances:
                corpus.deduplicatedTrainingTokenInstances,
            trainingRowCount: corpus.trainingRowCount,
            validTrainingRowCount:
                corpus.validTrainingRowCount,
            refusalTrainingRowCount:
                corpus.refusalTrainingRowCount,
            refusalSelectionValidationRowCount:
                corpus.refusalSelectionValidationRowCount,
            finalAbstentionRowCount:
                corpus.finalAbstentionRowCount,
            refusalCurriculumBound:
                corpus.refusalCurriculumBound,
            semanticCombinationCount:
                corpus.semanticCombinationCount,
            expectedEvaluationRows:
                corpus.expectedEvaluationRows,
            expectedEvaluationRowSHA256:
                expectedEvaluationRowSHA256
                    ?? corpus.expectedEvaluationRowSHA256,
            expectedEvaluationContractSHA256:
                corpus.expectedEvaluationContractSHA256,
            expectedSemanticFamilyRows:
                corpus.expectedSemanticFamilyRows
        )
    }

    private static func corpusWithRowHash(
        _ corpus: ErgenticsNativeLanguageCanary.CorpusBinding,
        rowID: String,
        sha256: String
    ) -> ErgenticsNativeLanguageCanary.CorpusBinding {
        var hashes = corpus.expectedEvaluationRowSHA256
        hashes[rowID] = sha256
        return copy(
            corpus,
            expectedEvaluationRowSHA256: hashes
        )
    }

    private static func copy(
        _ training: ErgenticsNativeLanguageCanary.TrainingEvidence,
        precision: String? = nil,
        scheduledRefusalReasonRows: [String: Int]? = nil,
        scheduledRefusalReasonScheduleSHA256: String? = nil,
        shiftedCausalLanguageModelLoss: Bool? = nil,
        heldoutLossRows:
            [ErgenticsNativeLanguageCanary.HeldoutLossRow]? = nil,
        optimizerImplementation: String? = nil,
        configurationArtifactSHA256: String? = nil,
        configurationArtifactFileName: String? = nil,
        declaredMaximumExecutorWallSeconds: Double? = nil,
        measuredTotalExecutorWallSeconds: Double? = nil,
        cachedUncachedMultiStepMaximumLogitDelta:
            Double? = nil,
        cachedUncachedMultiStepGreedyTokenParity:
            Bool? = nil,
        cachedUncachedMultiStepComparedDecisionCount:
            Int? = nil,
        cachedUncachedMultiStepUnevenEOS: Bool? = nil
    ) -> ErgenticsNativeLanguageCanary.TrainingEvidence {
        return ErgenticsNativeLanguageCanary.TrainingEvidence(
            requestedSteps: training.requestedSteps,
            completedSteps: training.completedSteps,
            probePurposeID: training.probePurposeID,
            scheduleID: training.scheduleID,
            distinctScheduledRowCount:
                training.distinctScheduledRowCount,
            scheduledSemanticFamilyRows:
                training.scheduledSemanticFamilyRows,
            scheduledValidRowCount:
                training.scheduledValidRowCount,
            scheduledRefusalRowCount:
                training.scheduledRefusalRowCount,
            scheduledValidSemanticFamilyRows:
                training.scheduledValidSemanticFamilyRows,
            scheduledRefusalSemanticFamilyRows:
                training.scheduledRefusalSemanticFamilyRows,
            scheduledRefusalReasonRows:
                scheduledRefusalReasonRows
                    ?? training.scheduledRefusalReasonRows,
            scheduledRefusalReasonScheduleSHA256:
                scheduledRefusalReasonScheduleSHA256
                    ?? training
                        .scheduledRefusalReasonScheduleSHA256,
            heldoutRowCount:
                training.heldoutRowCount,
            heldoutValidRowCount:
                training.heldoutValidRowCount,
            heldoutRefusalRowCount:
                training.heldoutRefusalRowCount,
            heldoutValidSemanticFamilyRows:
                training.heldoutValidSemanticFamilyRows,
            heldoutRefusalSemanticFamilyRows:
                training.heldoutRefusalSemanticFamilyRows,
            heldoutRefusalReasonRows:
                training.heldoutRefusalReasonRows,
            heldoutRefusalReasonScheduleSHA256:
                training.heldoutRefusalReasonScheduleSHA256,
            selectionValidationSplitIDs:
                training.selectionValidationSplitIDs,
            heldoutScheduleSHA256:
                training.heldoutScheduleSHA256,
            comparisonManifestSHA256:
                training.comparisonManifestSHA256,
            trainingScheduleManifestSHA256:
                training.trainingScheduleManifestSHA256,
            trainingHeldoutRowHashIntersectionCount:
                training.trainingHeldoutRowHashIntersectionCount,
            heldoutTargetTokenCount:
                training.heldoutTargetTokenCount,
            heldoutValidTargetTokenCount:
                training.heldoutValidTargetTokenCount,
            heldoutRefusalTargetTokenCount:
                training.heldoutRefusalTargetTokenCount,
            heldoutEvaluationNonPaddingTokenCount:
                training.heldoutEvaluationNonPaddingTokenCount,
            heldoutEvaluationElapsedSeconds:
                training.heldoutEvaluationElapsedSeconds,
            heldoutCrossEntropyBefore:
                training.heldoutCrossEntropyBefore,
            heldoutCrossEntropyAfter:
                training.heldoutCrossEntropyAfter,
            heldoutValidCrossEntropyBefore:
                training.heldoutValidCrossEntropyBefore,
            heldoutValidCrossEntropyAfter:
                training.heldoutValidCrossEntropyAfter,
            heldoutRefusalCrossEntropyBefore:
                training.heldoutRefusalCrossEntropyBefore,
            heldoutRefusalCrossEntropyAfter:
                training.heldoutRefusalCrossEntropyAfter,
            heldoutCrossEntropyStandardError:
                training.heldoutCrossEntropyStandardError,
            heldoutCrossEntropyStandardErrorMethodID:
                training.heldoutCrossEntropyStandardErrorMethodID,
            heldoutFamilyCrossEntropyBefore:
                training.heldoutFamilyCrossEntropyBefore,
            heldoutFamilyCrossEntropyAfter:
                training.heldoutFamilyCrossEntropyAfter,
            heldoutLossRows:
                heldoutLossRows ?? training.heldoutLossRows,
            measurementWarmupSteps:
                training.measurementWarmupSteps,
            timedSteps: training.timedSteps,
            batchSize: training.batchSize,
            gradientAccumulationSteps:
                training.gradientAccumulationSteps,
            effectiveBatchSize:
                training.effectiveBatchSize,
            measuredSequenceLength:
                training.measuredSequenceLength,
            processedPaddedTokenPositions:
                training.processedPaddedTokenPositions,
            plannedTrainingTokenPresentations:
                training.plannedTrainingTokenPresentations,
            trainedTokens: training.trainedTokens,
            elapsedSeconds: training.elapsedSeconds,
            coldStartElapsedSeconds:
                training.coldStartElapsedSeconds,
            measurementWarmupElapsedSeconds:
                training.measurementWarmupElapsedSeconds,
            timedElapsedSeconds:
                training.timedElapsedSeconds,
            timedNonPaddingTokens:
                training.timedNonPaddingTokens,
            tokensPerSecond: training.tokensPerSecond,
            peakMemoryBytes: training.peakMemoryBytes,
            learningRate: training.learningRate,
            learningRateScheduleID:
                training.learningRateScheduleID,
            optimizerImplementation:
                optimizerImplementation
                    ?? training.optimizerImplementation,
            adamBeta1: training.adamBeta1,
            adamBeta2: training.adamBeta2,
            adamEpsilon: training.adamEpsilon,
            decoupledWeightDecay:
                training.decoupledWeightDecay,
            gradientClipMode: training.gradientClipMode,
            lossReduction: training.lossReduction,
            warmupSteps: training.warmupSteps,
            minimumLearningRate:
                training.minimumLearningRate,
            weightDecay: training.weightDecay,
            precision: precision ?? training.precision,
            gradientClipNorm: training.gradientClipNorm,
            fullWeightTraining: training.fullWeightTraining,
            shiftedCausalLanguageModelLoss:
                shiftedCausalLanguageModelLoss
                    ?? training.shiftedCausalLanguageModelLoss,
            promptTokensMasked: training.promptTokensMasked,
            targetTokenWeightedEffectiveBatchLoss:
                training
                    .targetTokenWeightedEffectiveBatchLoss,
            answerTokensContributed:
                training.answerTokensContributed,
            firstGradientNorm: training.firstGradientNorm,
            firstClippedGradientNorm:
                training.firstClippedGradientNorm,
            firstWeightUpdateNorm:
                training.firstWeightUpdateNorm,
            causalPrefixMaximumLogitDelta:
                training.causalPrefixMaximumLogitDelta,
            suffixEffectMaximumLogitDelta:
                training.suffixEffectMaximumLogitDelta,
            logitsFinite: training.logitsFinite,
            repeatedInferenceMaximumLogitDelta:
                training.repeatedInferenceMaximumLogitDelta,
            cachedUncachedMaximumLogitDelta:
                training.cachedUncachedMaximumLogitDelta,
            cachedUncachedGreedyTokenParity:
                training.cachedUncachedGreedyTokenParity,
            cachedUncachedMultiStepMaximumLogitDelta:
                cachedUncachedMultiStepMaximumLogitDelta
                    ?? training
                        .cachedUncachedMultiStepMaximumLogitDelta,
            cachedUncachedMultiStepGreedyTokenParity:
                cachedUncachedMultiStepGreedyTokenParity
                    ?? training
                        .cachedUncachedMultiStepGreedyTokenParity,
            cachedUncachedMultiStepComparedDecisionCount:
                cachedUncachedMultiStepComparedDecisionCount
                    ?? training
                        .cachedUncachedMultiStepComparedDecisionCount,
            cachedUncachedMultiStepUnevenEOS:
                cachedUncachedMultiStepUnevenEOS
                    ?? training
                        .cachedUncachedMultiStepUnevenEOS,
            initializationFingerprintSHA256:
                training.initializationFingerprintSHA256,
            sameSeedInitializationReplayExact:
                training.sameSeedInitializationReplayExact,
            initialLoss: training.initialLoss,
            finalLoss: training.finalLoss,
            losses: training.losses,
            hyperparameterSearchID:
                training.hyperparameterSearchID,
            learningRateDiscoverySeed:
                training.learningRateDiscoverySeed,
            replicateID: training.replicateID,
            declaredLearningRateGrid:
                training.declaredLearningRateGrid,
            declaredReplicateSeeds:
                training.declaredReplicateSeeds,
            configurationArtifactSHA256:
                configurationArtifactSHA256
                    ?? training.configurationArtifactSHA256,
            configurationArtifactFileName:
                configurationArtifactFileName
                    ?? training.configurationArtifactFileName,
            executorWallAccountingID:
                training.executorWallAccountingID,
            resumedFromTrainingStage:
                training.resumedFromTrainingStage,
            priorExecutorWallSeconds:
                training.priorExecutorWallSeconds,
            checkpointStageExecutorWallSeconds:
                training.checkpointStageExecutorWallSeconds,
            preexistingEvaluationArtifactNamesAtInvocationStart:
                training
                    .preexistingEvaluationArtifactNamesAtInvocationStart,
            declaredMaximumExecutorWallSeconds:
                declaredMaximumExecutorWallSeconds
                    ?? training
                        .declaredMaximumExecutorWallSeconds,
            measuredTotalExecutorWallSeconds:
                measuredTotalExecutorWallSeconds
                    ?? training.measuredTotalExecutorWallSeconds,
            persistencePolicy: training.persistencePolicy,
            interruptedTrajectoryReplayExact:
                training.interruptedTrajectoryReplayExact
        )
    }

    private static func copy(
        _ replay:
            ErgenticsNativeLanguageCanary
                .SameSeedReplayEvidence,
        replayFixedPromptLogitFloatBitPatterns:
            [UInt32]? = nil
    ) -> ErgenticsNativeLanguageCanary
        .SameSeedReplayEvidence
    {
        .init(
            optimizerSteps: replay.optimizerSteps,
            scheduledRowIDs: replay.scheduledRowIDs,
            initialFingerprintSHA256:
                replay.initialFingerprintSHA256,
            replayInitialFingerprintSHA256:
                replay.replayInitialFingerprintSHA256,
            initialSelectedParameterSamples:
                replay.initialSelectedParameterSamples,
            replayInitialSelectedParameterSamples:
                replay.replayInitialSelectedParameterSamples,
            initializationReplayExact:
                replay.initializationReplayExact,
            differentSeed: replay.differentSeed,
            differentSeedInitialFingerprintSHA256:
                replay.differentSeedInitialFingerprintSHA256,
            differentSeedInitialSelectedParameterSamples:
                replay
                    .differentSeedInitialSelectedParameterSamples,
            differentSeedInitializationDiverged:
                replay.differentSeedInitializationDiverged,
            firstStepLoss: replay.firstStepLoss,
            replayStepLoss: replay.replayStepLoss,
            stepLossExact: replay.stepLossExact,
            postStepFingerprintSHA256:
                replay.postStepFingerprintSHA256,
            replayPostStepFingerprintSHA256:
                replay.replayPostStepFingerprintSHA256,
            postStepSelectedParameterSamples:
                replay.postStepSelectedParameterSamples,
            replayPostStepSelectedParameterSamples:
                replay.replayPostStepSelectedParameterSamples,
            postStepSelectedParametersExact:
                replay.postStepSelectedParametersExact,
            postStepSelectedParameterMaximumDelta:
                replay
                    .postStepSelectedParameterMaximumDelta,
            fixedPromptLogitFloatBitPatterns:
                replay.fixedPromptLogitFloatBitPatterns,
            replayFixedPromptLogitFloatBitPatterns:
                replayFixedPromptLogitFloatBitPatterns
                    ?? replay
                        .replayFixedPromptLogitFloatBitPatterns,
            fixedPromptMaximumLogitDelta:
                replay.fixedPromptMaximumLogitDelta,
            fixedPromptGreedyTokenID:
                replay.fixedPromptGreedyTokenID,
            replayFixedPromptGreedyTokenID:
                replay.replayFixedPromptGreedyTokenID,
            fixedPromptGreedyRunnerUpMargin:
                replay.fixedPromptGreedyRunnerUpMargin,
            replayFixedPromptGreedyRunnerUpMargin:
                replay.replayFixedPromptGreedyRunnerUpMargin,
            fixedPromptGreedyTokenExact:
                replay.fixedPromptGreedyTokenExact,
            fixedPromptBehavioralReplayExact:
                replay.fixedPromptBehavioralReplayExact,
            fixedPromptResultSHA256:
                replay.fixedPromptResultSHA256,
            replayFixedPromptResultSHA256:
                replay.replayFixedPromptResultSHA256,
            fixedPromptResultExact:
                replay.fixedPromptResultExact
        )
    }

    private static func copy(
        _ durability: ErgenticsNativeLanguageCanary.DurabilityEvidence,
        buildConfiguration: String? = nil,
        precision: String? = nil,
        checkpointReloadWeightsExact: Bool? = nil,
        configurationSHA256: String? = nil,
        executableSHA256: String? = nil,
        observedModelParameterDTypes: [String]? = nil,
        observedTrainableParameterDTypes: [String]? = nil
    ) -> ErgenticsNativeLanguageCanary.DurabilityEvidence {
        .init(
            checkpointSHA256: durability.checkpointSHA256,
            buildConfiguration:
                buildConfiguration
                    ?? durability.buildConfiguration,
            precision: precision ?? durability.precision,
            checkpointFileName:
                durability.checkpointFileName,
            trainingStageSHA256:
                durability.trainingStageSHA256,
            trainingStageFileName:
                durability.trainingStageFileName,
            evaluationDirectoryName:
                durability.evaluationDirectoryName,
            checkpointTensorCount:
                durability.checkpointTensorCount,
            checkpointReloadWeightsExact:
                checkpointReloadWeightsExact
                    ?? durability.checkpointReloadWeightsExact,
            checkpointReloadMaximumWeightDelta:
                durability.checkpointReloadMaximumWeightDelta,
            checkpointReloadMaximumLogitDelta:
                durability.checkpointReloadMaximumLogitDelta,
            repeatedInferenceMaximumLogitDelta:
                durability.repeatedInferenceMaximumLogitDelta,
            reloadedPredictionsExact:
                durability.reloadedPredictionsExact,
            configurationSHA256:
                configurationSHA256
                    ?? durability.configurationSHA256,
            executableSHA256:
                executableSHA256
                    ?? durability.executableSHA256,
            recommenderSHA256:
                durability.recommenderSHA256,
            recommenderFileName:
                durability.recommenderFileName,
            metalLibraryArtifactSHA256:
                durability.metalLibraryArtifactSHA256,
            metalLibraryArtifactByteCount:
                durability.metalLibraryArtifactByteCount,
            metalLibraryPrimaryFileName:
                durability.metalLibraryPrimaryFileName,
            metalLibraryFallbackFileName:
                durability.metalLibraryFallbackFileName,
            metalLibraryBundleSearchAuditID:
                durability.metalLibraryBundleSearchAuditID,
            metalLibraryBundleSearchBaseCount:
                durability.metalLibraryBundleSearchBaseCount,
            metalLibraryVerifiedBundleMirrorCount:
                durability.metalLibraryVerifiedBundleMirrorCount,
            metalLibraryDivergentBundleCandidateCount:
                durability
                    .metalLibraryDivergentBundleCandidateCount,
            metalLibrarySourceMLXSwiftRevision:
                durability.metalLibrarySourceMLXSwiftRevision,
            observedModelParameterDTypes:
                observedModelParameterDTypes
                    ?? durability.observedModelParameterDTypes,
            observedTrainableParameterDTypes:
                observedTrainableParameterDTypes
                    ?? durability
                        .observedTrainableParameterDTypes
        )
    }

    private static func copy(
        _ row: ErgenticsNativeLanguageCanary.RawPrediction,
        prompt: String? = nil,
        target: String? = nil,
        targetTokenIDs: [Int]? = nil,
        zeroShotPrediction: String? = nil,
        zeroShotPredictionTokenIDs: [Int]? = nil,
        zeroShotMeanLogProbability: Double? = nil,
        zeroShotTokenLogProbabilities: [Double]? = nil,
        zeroShotTerminatedByEOS: Bool? = nil,
        zeroShotTerminationReason: String? = nil,
        zeroShotUTF8Valid: Bool? = nil,
        zeroShotEOSLogProbability: Double? = nil,
        zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity:
            Bool? = nil,
        zeroShotDisallowedFullVocabularyArgmaxCount: Int? = nil,
        zeroShotMaximumDisallowedTokenProbabilityMass:
            Double? = nil,
        zeroShotExactMatch: Bool? = nil,
        zeroShotSemanticVerifierPass: Bool? = nil,
        zeroShotAbstentionDecision: Bool? = nil,
        trainedPrediction: String? = nil,
        trainedPredictionTokenIDs: [Int]? = nil,
        trainedRawFullVocabularyAllowedSupportGreedyTokenParity:
            Bool? = nil,
        trainedDisallowedFullVocabularyArgmaxCount: Int? = nil,
        trainedMaximumDisallowedTokenProbabilityMass:
            Double? = nil,
        trainedExactMatch: Bool? = nil,
        corpusRowSHA256: String? = nil,
        promptGroupingKeyID: String? = nil,
        promptGroupingKey: Int? = nil,
        generationDecisionBudget: Int? = nil,
        allowedCompletionTokenSetSHA256: String? = nil,
        eosAvailableAtEveryDecision: Bool? = nil,
        targetIndependentDecisionBudget: Bool? = nil,
        zeroShotDecisionsExecuted: Int? = nil,
        trainedDecisionsExecuted: Int? = nil
    ) -> ErgenticsNativeLanguageCanary.RawPrediction {
        let resolvedCorpusRowSHA256 =
            corpusRowSHA256 ?? row.corpusRowSHA256
        let resolvedPrompt = prompt ?? row.prompt
        let resolvedTarget = target ?? row.target
        let resolvedTargetTokenIDs =
            targetTokenIDs ?? row.targetTokenIDs
        let resolvedTrainedPrediction =
            trainedPrediction ?? row.trainedPrediction
        let resolvedTrainedPredictionTokenIDs =
            trainedPredictionTokenIDs
                ?? row.trainedPredictionTokenIDs
        let resolvedTrainedExactMatch =
            trainedExactMatch ?? row.trainedExactMatch
        return ErgenticsNativeLanguageCanary.RawPrediction(
            rowID: row.rowID,
            corpusRowSHA256: resolvedCorpusRowSHA256,
            evaluationRowSHA256:
                row.evaluationRowSHA256,
            split: row.split,
            semanticFamily: row.semanticFamily,
            invariantIDs: row.invariantIDs,
            mutationID: row.mutationID,
            abstentionReason: row.abstentionReason,
            prompt: resolvedPrompt,
            promptTokenIDs: row.promptTokenIDs,
            target: resolvedTarget,
            targetTokenIDs: resolvedTargetTokenIDs,
            zeroShotPrediction:
                zeroShotPrediction ?? row.zeroShotPrediction,
            zeroShotPredictionTokenIDs:
                zeroShotPredictionTokenIDs
                    ?? row.zeroShotPredictionTokenIDs,
            zeroShotMeanLogProbability:
                zeroShotMeanLogProbability
                    ?? row.zeroShotMeanLogProbability,
            zeroShotTokenLogProbabilities:
                zeroShotTokenLogProbabilities
                    ?? row.zeroShotTokenLogProbabilities,
            zeroShotTerminatedByEOS:
                zeroShotTerminatedByEOS
                    ?? row.zeroShotTerminatedByEOS,
            zeroShotTerminationReason:
                zeroShotTerminationReason
                    ?? row.zeroShotTerminationReason,
            zeroShotUTF8Valid:
                zeroShotUTF8Valid ?? row.zeroShotUTF8Valid,
            zeroShotEOSLogProbability:
                zeroShotEOSLogProbability
                    ?? row.zeroShotEOSLogProbability,
            zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity:
                zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity
                    ?? row
                        .zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity,
            zeroShotDisallowedFullVocabularyArgmaxCount:
                zeroShotDisallowedFullVocabularyArgmaxCount
                    ?? row
                        .zeroShotDisallowedFullVocabularyArgmaxCount,
            zeroShotMaximumDisallowedTokenProbabilityMass:
                zeroShotMaximumDisallowedTokenProbabilityMass
                    ?? row
                        .zeroShotMaximumDisallowedTokenProbabilityMass,
            zeroShotExactMatch:
                zeroShotExactMatch ?? row.zeroShotExactMatch,
            zeroShotSemanticVerifierPass:
                zeroShotSemanticVerifierPass
                    ?? row.zeroShotSemanticVerifierPass,
            zeroShotAbstentionDecision:
                zeroShotAbstentionDecision
                    ?? row.zeroShotAbstentionDecision,
            zeroShotLatencySeconds:
                row.zeroShotLatencySeconds,
            trainedPrediction: resolvedTrainedPrediction,
            trainedPredictionTokenIDs:
                resolvedTrainedPredictionTokenIDs,
            trainedMeanLogProbability:
                row.trainedMeanLogProbability,
            trainedTokenLogProbabilities:
                row.trainedTokenLogProbabilities,
            trainedTerminatedByEOS:
                row.trainedTerminatedByEOS,
            trainedTerminationReason:
                row.trainedTerminationReason,
            trainedUTF8Valid:
                row.trainedUTF8Valid,
            trainedEOSLogProbability:
                row.trainedEOSLogProbability,
            trainedRawFullVocabularyAllowedSupportGreedyTokenParity:
                trainedRawFullVocabularyAllowedSupportGreedyTokenParity
                    ?? row
                        .trainedRawFullVocabularyAllowedSupportGreedyTokenParity,
            trainedDisallowedFullVocabularyArgmaxCount:
                trainedDisallowedFullVocabularyArgmaxCount
                    ?? row
                        .trainedDisallowedFullVocabularyArgmaxCount,
            trainedMaximumDisallowedTokenProbabilityMass:
                trainedMaximumDisallowedTokenProbabilityMass
                    ?? row
                        .trainedMaximumDisallowedTokenProbabilityMass,
            trainedExactMatch: resolvedTrainedExactMatch,
            trainedSemanticVerifierPass:
                row.trainedSemanticVerifierPass,
            trainedAbstentionDecision:
                row.trainedAbstentionDecision,
            trainedLatencySeconds:
                row.trainedLatencySeconds,
            promptGroupingKeyID:
                promptGroupingKeyID ?? row.promptGroupingKeyID,
            promptGroupingKey:
                promptGroupingKey ?? row.promptGroupingKey,
            generationDecisionBudget:
                generationDecisionBudget
                    ?? row.generationDecisionBudget,
            allowedCompletionTokenSetSHA256:
                allowedCompletionTokenSetSHA256
                    ?? row.allowedCompletionTokenSetSHA256,
            eosAvailableAtEveryDecision:
                eosAvailableAtEveryDecision
                    ?? row.eosAvailableAtEveryDecision,
            targetIndependentDecisionBudget:
                targetIndependentDecisionBudget
                    ?? row.targetIndependentDecisionBudget,
            zeroShotDecisionsExecuted:
                zeroShotDecisionsExecuted
                    ?? row.zeroShotDecisionsExecuted,
            trainedDecisionsExecuted:
                trainedDecisionsExecuted
                    ?? row.trainedDecisionsExecuted
        )
    }

    private static func evaluationRowSHA256(
        _ row: ErgenticsNativeLanguageCanary.RawPrediction
    ) -> String {
        evaluationRowSHA256(
            rowID: row.rowID,
            split: row.split,
            semanticFamily: row.semanticFamily,
            mutationID: row.mutationID,
            prompt: row.prompt,
            target: row.target
        )
    }

    private static func evaluationRowSHA256(
        rowID: String,
        split: ErgenticsNativeLanguageCanary.Split,
        semanticFamily: String,
        mutationID: String?,
        prompt: String,
        target: String
    ) -> String {
        let payload = EvaluationRowHashPayload(
            rowID: rowID,
            split: split.rawValue,
            semanticFamily: semanticFamily,
            mutationID: mutationID,
            prompt: prompt,
            target: target
        )
        return sha256(try! canonicalEncoder().encode(payload))
    }

    private static func corpusRowMatchesAuthority(
        _ row: ErgenticsNativeLanguageCanary.RawPrediction
    ) -> Bool {
        guard let authority = authoritativeRowsByID[row.rowID]
        else { return false }
        return authority.rowSHA256 == row.corpusRowSHA256
            && authority.evaluationRowSHA256
                == row.evaluationRowSHA256
            && authority.split == row.split.rawValue
            && authority.semanticFamily == row.semanticFamily
            && authority.mutationID == row.mutationID
            && authority.promptText == row.prompt
            && authority.expectedCompletion == row.target
            && authority.invariantIDs == row.invariantIDs
            && authority.abstentionReason == row.abstentionReason
    }

    private static func canonicalEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return encoder
    }

    private static func containsObsoleteOrMissingReportSchema(
        _ reportData: [Data]
    ) -> Bool {
        reportData.contains { data in
            guard let value =
                try? JSONSerialization.jsonObject(with: data),
                  let object = value as? [String: Any],
                  let schema = object["schema_version"] as? String
            else {
                return true
            }
            return schema
                != ErgenticsNativeLanguageCanary.schemaVersion
        }
    }

    private static func containsForbiddenQuantHessianMetadata(
        _ reportData: [Data]
    ) -> Bool {
        let forbidden = [
            "quant",
            "gptq",
            "hessian",
            "schur",
            "diagonal_coupling",
        ]
        func contains(_ value: Any) -> Bool {
            if let object = value as? [String: Any] {
                for (key, child) in object {
                    let normalized = key.lowercased()
                    if forbidden.contains(where: {
                        normalized.contains($0)
                    }) {
                        return true
                    }
                    if contains(child) { return true }
                }
            } else if let array = value as? [Any] {
                return array.contains(where: contains)
            }
            return false
        }
        return reportData.contains { data in
            guard let value =
                try? JSONSerialization.jsonObject(with: data)
            else { return true }
            return contains(value)
        }
    }

    private static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }

    private static func exactMaterialsCacheKey(
        reportData: [Data],
        tokenizerManifestData: Data?,
        corpusManifestData: Data?,
        packageResolvedBinding:
            ObservedPackageResolvedBinding?,
        probeData: [Int: Data],
        shardData: [Int: [String: Data]],
        executorData: [String: Data],
        recommenderData: [String: Data],
        checkpointBindings: [Int: ObservedCheckpointBinding],
        metalLibraryBindings:
            [Int: ObservedMetalLibraryBinding],
        trainingStageData: [Int: Data],
        configurationData: [Int: Data]
    ) -> String {
        var records = reportData.map {
            "report|\(sha256($0))"
        }.sorted()
        records.append(
            "tokenizer|"
                + (tokenizerManifestData.map(sha256) ?? "missing")
        )
        records.append(
            "corpus|"
                + (corpusManifestData.map(sha256) ?? "missing")
        )
        records.append(
            packageResolvedBinding.map {
                [
                    "package_resolved",
                    $0.fileName,
                    $0.sha256,
                    String($0.byteCount),
                    $0.mlxSwiftRevision,
                    $0.mlxSwiftExamplesVersion,
                ].joined(separator: "|")
            } ?? "package_resolved|missing"
        )
        records.append(contentsOf: probeData.map {
            "probe|\($0.key)|\(sha256($0.value))"
        })
        for (seed, shards) in shardData {
            records.append(contentsOf: shards.map {
                "shard|\(seed)|\($0.key)|\(sha256($0.value))"
            })
        }
        records.append(contentsOf: executorData.map {
            "executor|\($0.key)|\(sha256($0.value))"
        })
        records.append(contentsOf: recommenderData.map {
            "recommender|\($0.key)|\(sha256($0.value))"
        })
        records.append(contentsOf: checkpointBindings.map {
            [
                "checkpoint",
                String($0.key),
                $0.value.fileName,
                $0.value.sha256,
                String($0.value.byteCount),
            ].joined(separator: "|")
        })
        records.append(contentsOf: metalLibraryBindings.map {
            [
                "metal_library",
                String($0.key),
                $0.value.primaryFileName,
                $0.value.fallbackFileName,
                $0.value.sha256,
                String($0.value.byteCount),
            ].joined(separator: "|")
        })
        records.append(contentsOf: trainingStageData.map {
            "training_stage|\($0.key)|\(sha256($0.value))"
        })
        records.append(contentsOf: configurationData.map {
            "configuration|\($0.key)|\(sha256($0.value))"
        })
        return sha256(
            Data(records.sorted().joined(separator: "\n").utf8)
        )
    }

    private static func mutatedSHA256(_ value: String) -> String {
        guard let first = value.first else {
            return String(repeating: "0", count: 64)
        }
        let replacement: Character = first == "0" ? "1" : "0"
        return String(replacement) + value.dropFirst()
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.count == 64
            && value.allSatisfy {
                "0123456789abcdef".contains($0)
            }
    }

    private static func isGitRevision(
        _ value: String
    ) -> Bool {
        value.count == 40
            && value.allSatisfy {
                "0123456789abcdef".contains($0)
            }
    }

    private static func packageResolvedMLXBinding(
        _ data: Data
    ) -> (revision: String, examplesVersion: String)? {
        guard let lock = try? JSONDecoder().decode(
            PackageResolvedAudit.self,
            from: data
        ) else {
            return nil
        }
        let revisions = lock.pins.compactMap { pin in
            pin.identity == "mlx-swift"
                ? pin.state.revision : nil
        }
        guard revisions.count == 1,
              let revision = revisions.first,
              isGitRevision(revision)
        else {
            return nil
        }
        let examplePins = lock.pins.filter {
            $0.identity == "mlx-swift-examples"
        }
        guard examplePins.count == 1,
              let examplesVersion =
                examplePins.first?.state.version,
              examplesVersion == "2.29.1"
        else {
            return nil
        }
        return (revision, examplesVersion)
    }

    private static func sha256File(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let data =
                try handle.read(upToCount: 8 * 1_024 * 1_024)
                    ?? Data()
            if data.isEmpty { break }
            hasher.update(data: data)
        }
        return hasher.finalize().map {
            String(format: "%02x", $0)
        }.joined()
    }
}
// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import PrimeNativeNeuralGateHistoricalReplayMechanics
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateHistoricalEvidenceExportError:
    Error,
    Equatable,
    Sendable
{
    case invalidBaselineInvariantRecordCount(Int)
    case invalidBaselineInvariantASCIIFlagCount(Int)
    case invalidBaselineInvariantBundle
    case invalidBaselineFingerprint
    case invalidBaselineSeedCatalog
    case invalidMutationCatalog
    case invalidMutationInvariantRecordCount(
        mutationID: String,
        observed: Int
    )
    case invalidMutationInvariantASCIIFlagCount(
        mutationID: String,
        observed: Int
    )
    case invalidMutationFingerprint(String)
    case invalidRestoredInvariantRecords
    case invalidRestoredInvariantASCIIFlags
    case invalidRestoredInvariantBundle
    case invalidHistoricalAssessment
}

/// The sole cross-module entry point into the source-derived historical gate.
///
/// This facade accepts only in-memory historical materials and returns an
/// authority-free value. It performs no path lookup, process launch,
/// publication, receipt issuance, or product admission.
public enum PrimeNativeNeuralGateHistoricalEvidenceExporter {
    public struct NamedBoolean: Equatable, Sendable {
        public let name: String
        public let value: Bool

        init(name: String, value: Bool) {
            self.name = name
            self.value = value
        }
    }

    public struct CriticalLegValue: Equatable, Sendable {
        public let ordinal: Int
        public let legID: String
        public let passed: Bool

        init(
            ordinal: Int,
            legID: String,
            passed: Bool
        ) {
            self.ordinal = ordinal
            self.legID = legID
            self.passed = passed
        }
    }

    public struct MutationStreamIdentity:
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let mutationID: String
        public let baselineStreamSHA256: String
        public let mutatedStreamSHA256: String
        public let restoredStreamSHA256: String

        init(
            ordinal: Int,
            mutationID: String,
            baselineStreamSHA256: String,
            mutatedStreamSHA256: String,
            restoredStreamSHA256: String
        ) {
            self.ordinal = ordinal
            self.mutationID = mutationID
            self.baselineStreamSHA256 =
                baselineStreamSHA256
            self.mutatedStreamSHA256 =
                mutatedStreamSHA256
            self.restoredStreamSHA256 =
                restoredStreamSHA256
        }
    }

    public struct MutationFingerprintSet:
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let mutationID: String
        public let baseline:
            PrimeNativeNeuralGateFingerprintObservation
        public let mutated:
            PrimeNativeNeuralGateFingerprintObservation
        public let restored:
            PrimeNativeNeuralGateFingerprintObservation

        init(
            ordinal: Int,
            mutationID: String,
            baseline:
                PrimeNativeNeuralGateFingerprintObservation,
            mutated:
                PrimeNativeNeuralGateFingerprintObservation,
            restored:
                PrimeNativeNeuralGateFingerprintObservation
        ) {
            self.ordinal = ordinal
            self.mutationID = mutationID
            self.baseline = baseline
            self.mutated = mutated
            self.restored = restored
        }
    }

    public struct MutationObservedFailureSet:
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let mutationID: String
        public let orderedObservedFailedLegIDs:
            [String]

        init(
            ordinal: Int,
            mutationID: String,
            orderedObservedFailedLegIDs: [String]
        ) {
            self.ordinal = ordinal
            self.mutationID = mutationID
            self.orderedObservedFailedLegIDs =
                orderedObservedFailedLegIDs
        }
    }

    public struct HistoricalMutationVerdictValue:
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let mutationID: String
        public let expectedFailedLegID: String
        public let detected: Bool
        public let fingerprintDiverged: Bool
        public let restored: Bool
        public let restoredFingerprintExact: Bool

        init(
            ordinal: Int,
            mutationID: String,
            expectedFailedLegID: String,
            detected: Bool,
            fingerprintDiverged: Bool,
            restored: Bool,
            restoredFingerprintExact: Bool
        ) {
            self.ordinal = ordinal
            self.mutationID = mutationID
            self.expectedFailedLegID =
                expectedFailedLegID
            self.detected = detected
            self.fingerprintDiverged =
                fingerprintDiverged
            self.restored = restored
            self.restoredFingerprintExact =
                restoredFingerprintExact
        }
    }

    public struct HeldoutLossRowValue:
        Equatable,
        Sendable
    {
        public let rowID: String
        public let rowSHA256: String
        public let selectionSplitID: String
        public let targetClass: String
        public let semanticFamily: String
        public let targetTokenCount: Int
        public let nonPaddingTokenCount: Int
        public let crossEntropyBefore: Double
        public let crossEntropyAfter: Double

        init(
            _ row:
                ErgenticsNativeLanguageCanary.HeldoutLossRow
        ) {
            rowID = row.rowID
            rowSHA256 = row.rowSHA256
            selectionSplitID = row.selectionSplitID
            targetClass = row.targetClass
            semanticFamily = row.semanticFamily
            targetTokenCount = row.targetTokenCount
            nonPaddingTokenCount =
                row.nonPaddingTokenCount
            crossEntropyBefore = row.crossEntropyBefore
            crossEntropyAfter = row.crossEntropyAfter
        }
    }

    public struct HeldoutStatisticsValue:
        Equatable,
        Sendable
    {
        public let seed: Int
        public let heldoutRowCount: Int
        public let heldoutValidRowCount: Int
        public let heldoutRefusalRowCount: Int
        public let heldoutTargetTokenCount: Int
        public let heldoutValidTargetTokenCount: Int
        public let heldoutRefusalTargetTokenCount: Int
        public let heldoutEvaluationNonPaddingTokenCount: Int
        public let heldoutCrossEntropyBefore: Double
        public let heldoutCrossEntropyAfter: Double
        public let heldoutValidCrossEntropyBefore: Double
        public let heldoutValidCrossEntropyAfter: Double
        public let heldoutRefusalCrossEntropyBefore: Double
        public let heldoutRefusalCrossEntropyAfter: Double
        public let heldoutCrossEntropyStandardError: Double
        public let heldoutCrossEntropyStandardErrorMethodID:
            String
        public let heldoutFamilyCrossEntropyBefore:
            [String: Double]
        public let heldoutFamilyCrossEntropyAfter:
            [String: Double]
        public let initialLoss: Double
        public let finalLoss: Double
        public let heldoutLossRows: [HeldoutLossRowValue]

        init(
            report: ErgenticsNativeLanguageCanary.Report
        ) {
            let training = report.training
            seed = report.seed
            heldoutRowCount = training.heldoutRowCount
            heldoutValidRowCount =
                training.heldoutValidRowCount
            heldoutRefusalRowCount =
                training.heldoutRefusalRowCount
            heldoutTargetTokenCount =
                training.heldoutTargetTokenCount
            heldoutValidTargetTokenCount =
                training.heldoutValidTargetTokenCount
            heldoutRefusalTargetTokenCount =
                training.heldoutRefusalTargetTokenCount
            heldoutEvaluationNonPaddingTokenCount =
                training
                .heldoutEvaluationNonPaddingTokenCount
            heldoutCrossEntropyBefore =
                training.heldoutCrossEntropyBefore
            heldoutCrossEntropyAfter =
                training.heldoutCrossEntropyAfter
            heldoutValidCrossEntropyBefore =
                training.heldoutValidCrossEntropyBefore
            heldoutValidCrossEntropyAfter =
                training.heldoutValidCrossEntropyAfter
            heldoutRefusalCrossEntropyBefore =
                training.heldoutRefusalCrossEntropyBefore
            heldoutRefusalCrossEntropyAfter =
                training.heldoutRefusalCrossEntropyAfter
            heldoutCrossEntropyStandardError =
                training.heldoutCrossEntropyStandardError
            heldoutCrossEntropyStandardErrorMethodID =
                training
                .heldoutCrossEntropyStandardErrorMethodID
            heldoutFamilyCrossEntropyBefore =
                training.heldoutFamilyCrossEntropyBefore
            heldoutFamilyCrossEntropyAfter =
                training.heldoutFamilyCrossEntropyAfter
            initialLoss = training.initialLoss
            finalLoss = training.finalLoss
            heldoutLossRows = training.heldoutLossRows.map(
                HeldoutLossRowValue.init
            )
        }
    }

    public struct FixedPromptReplayValue:
        Equatable,
        Sendable
    {
        public let seed: Int
        public let firstLogitFloatBitPatterns: [UInt32]
        public let replayLogitFloatBitPatterns: [UInt32]
        public let maximumLogitDelta: Double
        public let firstGreedyTokenID: Int
        public let replayGreedyTokenID: Int
        public let firstGreedyRunnerUpMargin: Double
        public let replayGreedyRunnerUpMargin: Double
        public let greedyTokenExact: Bool
        public let behavioralReplayExact: Bool
        public let firstResultSHA256: String
        public let replayResultSHA256: String
        public let resultExact: Bool

        init(
            report: ErgenticsNativeLanguageCanary.Report
        ) {
            let replay = report.sameSeedReplay
            seed = report.seed
            firstLogitFloatBitPatterns =
                replay.fixedPromptLogitFloatBitPatterns
            replayLogitFloatBitPatterns =
                replay.replayFixedPromptLogitFloatBitPatterns
            maximumLogitDelta =
                replay.fixedPromptMaximumLogitDelta
            firstGreedyTokenID =
                replay.fixedPromptGreedyTokenID
            replayGreedyTokenID =
                replay.replayFixedPromptGreedyTokenID
            firstGreedyRunnerUpMargin =
                replay.fixedPromptGreedyRunnerUpMargin
            replayGreedyRunnerUpMargin =
                replay.replayFixedPromptGreedyRunnerUpMargin
            greedyTokenExact =
                replay.fixedPromptGreedyTokenExact
            behavioralReplayExact =
                replay.fixedPromptBehavioralReplayExact
            firstResultSHA256 =
                replay.fixedPromptResultSHA256
            replayResultSHA256 =
                replay.replayFixedPromptResultSHA256
            resultExact = replay.fixedPromptResultExact
        }
    }

    public struct CapabilitySplitValue:
        Equatable,
        Sendable
    {
        public let splitID: String
        public let rowCount: Int
        public let zeroShotExactAccuracy: Double
        public let trainedExactAccuracy: Double
        public let trainedMeanLogProbability: Double

        init(
            metric:
                ErgenticsNativeLanguageCanary.SplitMetric
        ) {
            splitID = metric.split.rawValue
            rowCount = metric.count
            zeroShotExactAccuracy =
                metric.zeroShotExactAccuracy
            trainedExactAccuracy =
                metric.trainedExactAccuracy
            trainedMeanLogProbability =
                metric.trainedMeanLogProbability
        }
    }

    public struct AbstentionDecisionRowValue:
        Equatable,
        Sendable
    {
        public let rowID: String
        public let corpusRowSHA256: String
        public let evaluationRowSHA256: String
        public let splitID: String
        public let target: String
        public let trainedPrediction: String?
        public let trainedTerminatedByEOS: Bool
        public let trainedTerminationReason: String
        public let trainedUTF8Valid: Bool
        public let trainedExactMatch: Bool
        public let trainedSemanticVerifierPass: Bool
        public let trainedAbstentionDecision: Bool

        init(
            row: ErgenticsNativeLanguageCanary.RawPrediction
        ) {
            rowID = row.rowID
            corpusRowSHA256 = row.corpusRowSHA256
            evaluationRowSHA256 =
                row.evaluationRowSHA256
            splitID = row.split.rawValue
            target = row.target
            trainedPrediction = row.trainedPrediction
            trainedTerminatedByEOS =
                row.trainedTerminatedByEOS
            trainedTerminationReason =
                row.trainedTerminationReason
            trainedUTF8Valid = row.trainedUTF8Valid
            trainedExactMatch = row.trainedExactMatch
            trainedSemanticVerifierPass =
                row.trainedSemanticVerifierPass
            trainedAbstentionDecision =
                row.trainedAbstentionDecision
        }
    }

    public struct CapabilityValue: Equatable, Sendable {
        public let seed: Int
        public let orderedSplitValues:
            [CapabilitySplitValue]
        public let requiredAbstentionRowCount: Int
        public let orderedAbstentionDecisionRows:
            [AbstentionDecisionRowValue]
        public let exactAbstentionDecisionsObserved: Bool

        init(
            report: ErgenticsNativeLanguageCanary.Report
        ) {
            seed = report.seed
            orderedSplitValues =
                ErgenticsNativeLanguageCanary
                .recommend(report)
                .splitMetrics.map {
                    CapabilitySplitValue(metric: $0)
                }
            requiredAbstentionRowCount = 2_048
            let abstentionRows = report.rawPredictions.filter {
                $0.split == .abstention
            }
            orderedAbstentionDecisionRows =
                abstentionRows.map {
                    AbstentionDecisionRowValue(row: $0)
                }
            exactAbstentionDecisionsObserved =
                abstentionRows.count
                    == requiredAbstentionRowCount
                && abstentionRows.allSatisfy { row in
                    row.target == "ABSTAIN\n"
                        && row.trainedPrediction
                            == "ABSTAIN\n"
                        && row.trainedTerminatedByEOS
                        && row.trainedTerminationReason == "eos"
                        && row.trainedUTF8Valid
                        && row.trainedExactMatch
                        && row.trainedSemanticVerifierPass
                        && row.trainedAbstentionDecision
                }
        }
    }

    public struct SourceDerivedSingletonRegradeDisposition:
        Equatable,
        Sendable
    {
        public let exactSingletonFailureSetsSatisfied: Bool
        public let outcome: String

        init(exactSingletonFailureSetsSatisfied: Bool) {
            self.exactSingletonFailureSetsSatisfied =
                exactSingletonFailureSetsSatisfied
            outcome = exactSingletonFailureSetsSatisfied
                ? "GROUNDED" : "ABSTAIN"
        }
    }

    public struct HistoricalStatisticsAndVerdictValues:
        Equatable,
        Sendable
    {
        public let heldoutStatistics:
            [HeldoutStatisticsValue]
        public let fixedPromptReplayValues:
            [FixedPromptReplayValue]
        public let capabilityValues:
            [CapabilityValue]
        public let historicalAgreeCount: Int
        public let historicalIndependentPassCount: Int
        public let historicalOutcome: String
        public let historicalTriadicLabel: String
        public let historicalNextAction: String
        public let materialReloadComponents:
            [NamedBoolean]
        public let historicalMutationOutcome: String
        public let historicalMutationTriadicLabel: String
        public let historicalMutationValues:
            [HistoricalMutationVerdictValue]
        public let sourceDerivedSingletonRegradeDisposition:
            SourceDerivedSingletonRegradeDisposition

        init(
            heldoutStatistics:
                [HeldoutStatisticsValue],
            fixedPromptReplayValues:
                [FixedPromptReplayValue],
            capabilityValues: [CapabilityValue],
            historicalAgreeCount: Int,
            historicalIndependentPassCount: Int,
            historicalOutcome: String,
            historicalTriadicLabel: String,
            historicalNextAction: String,
            materialReloadComponents: [NamedBoolean],
            historicalMutationOutcome: String,
            historicalMutationTriadicLabel: String,
            historicalMutationValues:
                [HistoricalMutationVerdictValue],
            sourceDerivedSingletonRegradeDisposition:
                SourceDerivedSingletonRegradeDisposition
        ) {
            self.heldoutStatistics = heldoutStatistics
            self.fixedPromptReplayValues =
                fixedPromptReplayValues
            self.capabilityValues = capabilityValues
            self.historicalAgreeCount =
                historicalAgreeCount
            self.historicalIndependentPassCount =
                historicalIndependentPassCount
            self.historicalOutcome = historicalOutcome
            self.historicalTriadicLabel =
                historicalTriadicLabel
            self.historicalNextAction =
                historicalNextAction
            self.materialReloadComponents =
                materialReloadComponents
            self.historicalMutationOutcome =
                historicalMutationOutcome
            self.historicalMutationTriadicLabel =
                historicalMutationTriadicLabel
            self.historicalMutationValues =
                historicalMutationValues
            self.sourceDerivedSingletonRegradeDisposition =
                sourceDerivedSingletonRegradeDisposition
        }
    }

    /// In-memory source-derived evidence. Deliberately not `Codable`:
    /// durable authority belongs to later descriptor-fed publication and
    /// independent terminal recomputation, not this carrier.
    public struct Evidence: Equatable, Sendable {
        public let orderedInvariantRecords: [Data]
        public let orderedInvariantRecordASCIIFlags: [Bool]
        public let baselineInvariantBundle:
            PrimeNativeNeuralGateInvariantBundle
        public let orderedMutationIdentities: [String]
        public let perMutationStreamIdentities:
            [MutationStreamIdentity]
        public let perMutationFingerprints:
            [MutationFingerprintSet]
        public let perMutationObservedFailedLegIDs:
            [MutationObservedFailureSet]
        public let historicalCriticalLegValues:
            [CriticalLegValue]
        public let historicalStatisticsAndVerdictValues:
            HistoricalStatisticsAndVerdictValues

        init(
            orderedInvariantRecords: [Data],
            orderedInvariantRecordASCIIFlags: [Bool],
            baselineInvariantBundle:
                PrimeNativeNeuralGateInvariantBundle,
            orderedMutationIdentities: [String],
            perMutationStreamIdentities:
                [MutationStreamIdentity],
            perMutationFingerprints:
                [MutationFingerprintSet],
            perMutationObservedFailedLegIDs:
                [MutationObservedFailureSet],
            historicalCriticalLegValues:
                [CriticalLegValue],
            historicalStatisticsAndVerdictValues:
                HistoricalStatisticsAndVerdictValues
        ) {
            self.orderedInvariantRecords =
                orderedInvariantRecords
            self.orderedInvariantRecordASCIIFlags =
                orderedInvariantRecordASCIIFlags
            self.baselineInvariantBundle =
                baselineInvariantBundle
            self.orderedMutationIdentities =
                orderedMutationIdentities
            self.perMutationStreamIdentities =
                perMutationStreamIdentities
            self.perMutationFingerprints =
                perMutationFingerprints
            self.perMutationObservedFailedLegIDs =
                perMutationObservedFailedLegIDs
            self.historicalCriticalLegValues =
                historicalCriticalLegValues
            self.historicalStatisticsAndVerdictValues =
                historicalStatisticsAndVerdictValues
        }
    }

    public static func export(
        _ source:
            PrimeNativeNeuralGateHistoricalReplayMechanics
            .PrimeNeuralNativeLanguageVerifyAbstainGate
            .Materials
    ) throws -> Evidence {
        let packageResolvedArtifactBinding =
            source.packageResolvedArtifactBinding.map {
                binding in
                PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter
                .ObservedPackageResolvedBinding(
                    fileName: binding.fileName,
                    sha256: binding.sha256,
                    byteCount: binding.byteCount,
                    mlxSwiftRevision:
                        binding.mlxSwiftRevision,
                    mlxSwiftExamplesVersion:
                        binding.mlxSwiftExamplesVersion
                )
            }
        let checkpointArtifactBindingBySeed =
            Dictionary(
                uniqueKeysWithValues:
                    source.checkpointArtifactBindingBySeed
                    .map { seed, binding in
                        (
                            seed,
                            PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter
                            .ObservedCheckpointBinding(
                                fileName: binding.fileName,
                                sha256: binding.sha256,
                                byteCount: binding.byteCount
                            )
                        )
                    }
            )
        let metalLibraryArtifactBindingBySeed =
            Dictionary(
                uniqueKeysWithValues:
                    source.metalLibraryArtifactBindingBySeed
                    .map { seed, binding in
                        (
                            seed,
                            PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter
                            .ObservedMetalLibraryBinding(
                                primaryFileName:
                                    binding.primaryFileName,
                                fallbackFileName:
                                    binding.fallbackFileName,
                                sha256: binding.sha256,
                                byteCount: binding.byteCount
                            )
                        )
                    }
            )
        let bridged =
            PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter
            .Materials(
                reportData: source.reportData,
                tokenizerManifestData:
                    source.tokenizerManifestData,
                corpusManifestData:
                    source.corpusManifestData,
                packageResolvedArtifactBinding:
                    packageResolvedArtifactBinding,
                probeTokenManifestDataBySeed:
                    source.probeTokenManifestDataBySeed,
                evaluationShardDataBySeed:
                    source.evaluationShardDataBySeed,
                executorArtifactDataByFileName:
                    source.executorArtifactDataByFileName,
                recommenderArtifactDataByFileName:
                    source.recommenderArtifactDataByFileName,
                checkpointArtifactBindingBySeed:
                    checkpointArtifactBindingBySeed,
                metalLibraryArtifactBindingBySeed:
                    metalLibraryArtifactBindingBySeed,
                trainingStageArtifactDataBySeed:
                    source.trainingStageArtifactDataBySeed,
                configurationArtifactDataBySeed:
                    source.configurationArtifactDataBySeed
            )
        return try PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter
            .exportHistoricalEvidence(bridged)
    }
}

extension
    PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter
{
    fileprivate static func exportHistoricalEvidence(
        _ materials: Materials
    ) throws
        -> PrimeNativeNeuralGateHistoricalEvidenceExporter
        .Evidence
    {
        typealias Exporter =
            PrimeNativeNeuralGateHistoricalEvidenceExporter
        let exactInvariantRecordCount = 59_497
        let exactMutationCount = 46
        let baseline = evaluate(materials)
        let baselineRecords = baseline.invariantRecords.map {
            Data($0.utf8)
        }
        guard baselineRecords.count
                == exactInvariantRecordCount
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidBaselineInvariantRecordCount(
                    baselineRecords.count
                )
        }
        guard baseline.invariantRecordIsASCII.count
                == exactInvariantRecordCount
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidBaselineInvariantASCIIFlagCount(
                    baseline.invariantRecordIsASCII.count
                )
        }
        let baselineBundle =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: baselineRecords)
        guard baselineBundle.manifest.recordCount
                == exactInvariantRecordCount,
              baselineBundle.chunkStreams.count == 15,
              baselineBundle.manifest.chunks.count == 15,
              baselineBundle.manifest.chunks.dropLast()
                .allSatisfy({ $0.recordCount == 4_096 }),
              baselineBundle.manifest.chunks.last?
                .recordCount == 2_153,
              baselineBundle.fingerprintObservation
                .exactEqualityObserved
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidBaselineInvariantBundle
        }
        guard fingerprint(
            baseline.fingerprint,
            equals:
                baselineBundle.fingerprintObservation.direct
        ) else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidBaselineFingerprint
        }

        let mutations = Mutation.allCases
        guard mutations.count == exactMutationCount,
              Set(mutations.map(\.rawValue)).count
                == exactMutationCount
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidMutationCatalog
        }
        let primitiveLegIDs = Array(
            criticalLegIDs.prefix(9)
        )
        var streamIdentities:
            [Exporter.MutationStreamIdentity] = []
        var fingerprintSets:
            [Exporter.MutationFingerprintSet] = []
        var observedFailureSets:
            [Exporter.MutationObservedFailureSet] = []
        streamIdentities.reserveCapacity(exactMutationCount)
        fingerprintSets.reserveCapacity(exactMutationCount)
        observedFailureSets.reserveCapacity(
            exactMutationCount
        )
        let mutationBaselinePlan = finiteFieldBaselinePlan(
            cacheKey: baseline.exactArtifactCacheKey,
            records: baseline.invariantRecords,
            recordIsASCII:
                baseline.invariantRecordIsASCII
        )
        let baselineSeeds = baseline.reports.map(\.seed)
        guard baselineSeeds.sorted()
                == ErgenticsNativeLanguageCanary
                    .frozenSeeds.sorted(),
              Set(baselineSeeds).count
                == ErgenticsNativeLanguageCanary
                    .frozenSeeds.count
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidBaselineSeedCatalog
        }
        var cachedRowsBySeed =
            [Int: InvariantRecordCollection]()
        cachedRowsBySeed.reserveCapacity(
            baseline.reports.count
        )
        for report in baseline.reports {
            guard cachedRowsBySeed[report.seed] == nil else {
                throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                    .invalidBaselineSeedCatalog
            }
            let prefix = "row|\(report.seed)|"
            let indices = baseline.invariantRecords.indices
                .filter {
                    baseline.invariantRecords[$0]
                        .hasPrefix(prefix)
                }
            cachedRowsBySeed[report.seed] =
                InvariantRecordCollection(
                    records: indices.map {
                        baseline.invariantRecords[$0]
                    },
                    isASCII: indices.map {
                        baseline.invariantRecordIsASCII[$0]
                    }
                )
        }

        for (offset, mutation) in mutations.enumerated() {
            let mutatedReports = mutatedReports(
                baseline.reports,
                mutation: mutation
            )
            var reusableRows = cachedRowsBySeed
            if mutation.mutatesRawPredictions,
               let mutatedSeed = baseline.reports.first?.seed
            {
                reusableRows.removeValue(forKey: mutatedSeed)
            }
            let mutatedRecordCollection = invariantRecords(
                reports: mutatedReports,
                tokenizer: baseline.tokenizer,
                corpus: baseline.corpus,
                rowHashRegrade:
                    mutation != .executorRowHash,
                cachedRowRecordsBySeed: reusableRows
            )
            let mutatedRecords =
                mutatedRecordCollection.records.map {
                    Data($0.utf8)
                }
            guard mutatedRecords.count
                    == exactInvariantRecordCount
            else {
                throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                    .invalidMutationInvariantRecordCount(
                        mutationID: mutation.rawValue,
                        observed: mutatedRecords.count
                    )
            }
            guard mutatedRecordCollection.isASCII.count
                    == exactInvariantRecordCount
            else {
                throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                    .invalidMutationInvariantASCIIFlagCount(
                        mutationID: mutation.rawValue,
                        observed:
                            mutatedRecordCollection
                            .isASCII.count
                    )
            }
            let donorMutatedFingerprint =
                finiteFieldFingerprint(
                    mutatedRecordCollection.records,
                    recordIsASCII:
                        mutatedRecordCollection.isASCII,
                    using: mutationBaselinePlan
                )
            let mutatedBundle =
                try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(records: mutatedRecords)
            guard mutatedBundle
                    .fingerprintObservation
                    .exactEqualityObserved,
                  fingerprint(
                      donorMutatedFingerprint,
                      equals:
                          mutatedBundle
                          .fingerprintObservation.direct
                  )
            else {
                throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                    .invalidMutationFingerprint(
                        mutation.rawValue
                    )
            }

            let mutatedReportData = try mutatedReports.map {
                try canonicalEncoder().encode($0)
            }
            let mutatedMaterials = Materials(
                reportData: mutatedReportData,
                tokenizerManifestData:
                    materials.tokenizerManifestData,
                corpusManifestData:
                    materials.corpusManifestData,
                packageResolvedArtifactBinding:
                    materials.packageResolvedArtifactBinding,
                probeTokenManifestDataBySeed:
                    materials.probeTokenManifestDataBySeed,
                evaluationShardDataBySeed:
                    materials.evaluationShardDataBySeed,
                executorArtifactDataByFileName:
                    materials.executorArtifactDataByFileName,
                recommenderArtifactDataByFileName:
                    materials.recommenderArtifactDataByFileName,
                checkpointArtifactBindingBySeed:
                    materials.checkpointArtifactBindingBySeed,
                metalLibraryArtifactBindingBySeed:
                    materials.metalLibraryArtifactBindingBySeed,
                trainingStageArtifactDataBySeed:
                    materials.trainingStageArtifactDataBySeed,
                configurationArtifactDataBySeed:
                    materials.configurationArtifactDataBySeed
            )
            let mutated = evaluate(mutatedMaterials)
            let primitiveValues = [
                mutated.materialReload,
                mutated.sz,
                mutated.foundationCorpus,
                mutated.rawExecutor,
                mutated.causalMechanics,
                mutated.durability,
                mutated.sameSeedReplay,
                mutated.seedConsensus,
                mutated.capability,
            ]
            let observed = zip(
                primitiveLegIDs,
                primitiveValues
            ).compactMap { legID, passed in
                passed ? nil : legID
            }
            let ordinal = offset + 1
            streamIdentities.append(
                Exporter.MutationStreamIdentity(
                    ordinal: ordinal,
                    mutationID: mutation.rawValue,
                    baselineStreamSHA256:
                        baselineBundle.manifest
                        .globalStreamSHA256,
                    mutatedStreamSHA256:
                        mutatedBundle.manifest
                        .globalStreamSHA256,
                    restoredStreamSHA256: ""
                )
            )
            fingerprintSets.append(
                Exporter.MutationFingerprintSet(
                    ordinal: ordinal,
                    mutationID: mutation.rawValue,
                    baseline:
                        baselineBundle
                        .fingerprintObservation,
                    mutated:
                        mutatedBundle
                        .fingerprintObservation,
                    restored:
                        baselineBundle
                        .fingerprintObservation
                )
            )
            observedFailureSets.append(
                Exporter.MutationObservedFailureSet(
                    ordinal: ordinal,
                    mutationID: mutation.rawValue,
                    orderedObservedFailedLegIDs:
                        observed
                )
            )
        }

        let restored = evaluate(materials)
        let restoredRecords = restored.invariantRecords.map {
            Data($0.utf8)
        }
        guard restoredRecords == baselineRecords else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidRestoredInvariantRecords
        }
        guard restored.invariantRecordIsASCII
                == baseline.invariantRecordIsASCII
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidRestoredInvariantASCIIFlags
        }
        let restoredBundle =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: restoredRecords)
        guard restoredBundle == baselineBundle,
              fingerprint(
                  restored.fingerprint,
                  equals:
                      restoredBundle
                      .fingerprintObservation.direct
              )
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidRestoredInvariantBundle
        }
        streamIdentities = streamIdentities.map {
            Exporter.MutationStreamIdentity(
                ordinal: $0.ordinal,
                mutationID: $0.mutationID,
                baselineStreamSHA256:
                    $0.baselineStreamSHA256,
                mutatedStreamSHA256:
                    $0.mutatedStreamSHA256,
                restoredStreamSHA256:
                    restoredBundle.manifest
                    .globalStreamSHA256
            )
        }
        fingerprintSets = fingerprintSets.map {
            Exporter.MutationFingerprintSet(
                ordinal: $0.ordinal,
                mutationID: $0.mutationID,
                baseline: $0.baseline,
                mutated: $0.mutated,
                restored:
                    restoredBundle
                    .fingerprintObservation
            )
        }

        let assessment = dispose(materials)
        guard assessment.verdict.witnesses.count == 10,
              assessment.verdict.witnesses.map(\.leg)
                == criticalLegIDs,
              let sweep = assessment.mutationSweep,
              sweep.results.count == exactMutationCount,
              sweep.results.map({ $0.mutation.rawValue })
                == mutations.map(\.rawValue)
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceExportError
                .invalidHistoricalAssessment
        }
        let criticalLegValues =
            assessment.verdict.witnesses.enumerated().map {
                Exporter.CriticalLegValue(
                    ordinal: $0.offset + 1,
                    legID: $0.element.leg,
                    passed: $0.element.pass
                )
            }
        let historicalMutationValues =
            sweep.results.enumerated().map {
                Exporter.HistoricalMutationVerdictValue(
                    ordinal: $0.offset + 1,
                    mutationID:
                        $0.element.mutation.rawValue,
                    expectedFailedLegID:
                        $0.element.expectedFailedLeg,
                    detected: $0.element.detected,
                    fingerprintDiverged:
                        $0.element.fingerprintDiverged,
                    restored: $0.element.restored,
                    restoredFingerprintExact:
                        $0.element
                        .restoredFingerprintExact
                )
            }
        let exactSingletonFailureSetsSatisfied =
            zip(mutations, observedFailureSets)
            .allSatisfy { mutation, observed in
                observed.orderedObservedFailedLegIDs
                    == [mutation.expectedFailedLeg]
            }
        let sourceDerivedSingletonRegradeDisposition =
            Exporter.SourceDerivedSingletonRegradeDisposition(
                exactSingletonFailureSetsSatisfied:
                    exactSingletonFailureSetsSatisfied
            )
        let statisticsAndVerdict =
            Exporter.HistoricalStatisticsAndVerdictValues(
                heldoutStatistics:
                    baseline.reports.map {
                        Exporter.HeldoutStatisticsValue(
                            report: $0
                        )
                    },
                fixedPromptReplayValues:
                    baseline.reports.map {
                        Exporter.FixedPromptReplayValue(
                            report: $0
                        )
                    },
                capabilityValues:
                    baseline.reports.map {
                        Exporter.CapabilityValue(
                            report: $0
                        )
                    },
                historicalAgreeCount:
                    assessment.verdict.agreeCount,
                historicalIndependentPassCount:
                    assessment.verdict
                    .independentPassCount,
                historicalOutcome: assessment.outcome,
                historicalTriadicLabel:
                    assessment.triadicVerdict,
                historicalNextAction:
                    assessment.nextAction,
                materialReloadComponents:
                    assessment
                    .materialReloadComponentPasses
                    .map {
                        Exporter.NamedBoolean(
                            name: $0.key,
                            value: $0.value
                        )
                    }
                    .sorted { $0.name < $1.name },
                historicalMutationOutcome:
                    sweep.outcome,
                historicalMutationTriadicLabel:
                    sweep.triadicVerdict,
                historicalMutationValues:
                    historicalMutationValues,
                sourceDerivedSingletonRegradeDisposition:
                    sourceDerivedSingletonRegradeDisposition
            )
        return Exporter.Evidence(
            orderedInvariantRecords: baselineRecords,
            orderedInvariantRecordASCIIFlags:
                baseline.invariantRecordIsASCII,
            baselineInvariantBundle: baselineBundle,
            orderedMutationIdentities:
                mutations.map(\.rawValue),
            perMutationStreamIdentities:
                streamIdentities,
            perMutationFingerprints: fingerprintSets,
            perMutationObservedFailedLegIDs:
                observedFailureSets,
            historicalCriticalLegValues:
                criticalLegValues,
            historicalStatisticsAndVerdictValues:
                statisticsAndVerdict
        )
    }

    private static func fingerprint(
        _ historical: FiniteFieldFingerprint?,
        equals replay: PrimeNativeNeuralGateFingerprint
    ) -> Bool {
        guard let historical else {
            return false
        }
        return historical.prime == replay.prime
            && historical.evaluationPoints
                == replay.evaluationPoints
            && historical.residues == replay.residues
            && historical.recordCount
                == replay.recordCount
    }
}
