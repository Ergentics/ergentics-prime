import CryptoKit
import Foundation

/// Evidence-bound scale selection for an Ergentics-native decoder.
///
/// The profiles use maintained `MLXLLM.LlamaModel` primitives. The Engine
/// compares full-weight Swift/Metal architecture profiles over the same
/// balanced training schedule and disjoint held-out evaluation. This is not a
/// pure parameter-scale experiment: depth, width, GQA geometry, FFN width, and
/// RoPE also change between profiles. Each profile must stand on its own
/// evidence; a smaller profile is never a prerequisite for a larger one.
/// Selecting a bounded canary never authorizes a broad-English or
/// product-quality claim.
public enum ErgenticsNativeScaleEngineRecommend {
    public static let schemaVersion = "6"
    public static let familyID = "ergentics_native_scale_sweep"
    public static let comparisonKind =
        "architecture_profile_comparison_not_pure_scale"
    public static let comparisonBudgetScopeID =
        "fixed_token_fixed_step_short_horizon_learning_efficiency_only_v1"
    public static let maintainedBFloat16CalibrationAction =
        "run_maintained_mlx_bfloat16_executor_feasibility_calibration"
    public static let fairExecutorDesignAction =
        "design_fixed_token_matched_compute_and_convergence_capped_executor_arms"
    public static let comparisonPrerequisiteIDs = [
        "increase_independent_confirmation_replicates_to_at_least_3",
        "bind_calibrated_paired_seed_profile_comparison",
        "separate_initialization_training_and_evaluation_seed_domains_for_factor_attribution",
        "design_fixed_token_matched_compute_and_convergence_capped_executor_arms",
    ]
    public static let replicateVariationScopeID =
        "whole_pipeline_root_seed_with_domain_separated_schedule_namespaces_v1"

    public static let broadLanguagePlanningTokensPerParameter: Int64 = 20
    public static let minimumProbeTokenPresentations: Int64 = 10_000
    public static let minimumRelativeLossReduction = 0.01
    public static let semanticFamilyQualityRuleID =
        "strict_improvement_each_required_semantic_family_v1"
    public static let relativeLossReductionMethodID =
        "descriptive_all_selected_rate_replicates_including_adaptive_discovery_v1"
    public static let profileComparisonUncertaintyMethodID =
        "independent_confirmation_only_paired_seed_comparison_unbound_v1"
    public static let minimumIndependentConfirmationReplicateCount =
        3
    /// No calibrated small-sample comparison has been accepted. The current
    /// two confirmation seeds can describe behavior but cannot select or
    /// promote an architecture profile.
    public static let profileComparisonCalibrationID: String? = nil
    public static let profileProbeBlockTokenPresentations:
        Int64 = 147_456
    public static let defaultPlannedTrainingBlockCount:
        Int64 = 1_357
    public static let defaultPlannedTrainingTokenPresentations:
        Int64 =
            profileProbeBlockTokenPresentations
            * defaultPlannedTrainingBlockCount
    public static let profileProbeTrainingScheduleID =
        "manifest_sha256_curriculum_240_valid_48_refusal_reason_stratified_v3"
    public static let profileProbeValidRowCount: Int64 = 240
    public static let profileProbeRefusalRowCount: Int64 = 48
    public static let profileProbeValidRowsPerFamily: Int64 = 40
    public static let profileProbeRefusalRowsPerFamily: Int64 = 8
    public static let requiredAutoregressiveGenerationCap = 64
    public static let requiredFullEvaluationPhaseCount: Int64 = 3
    public static let adaptiveSearchID =
        "adaptive_lr_discovery_confirm_v1"
    public static let discoverySeed = 1_618
    public static let confirmationSeeds = [2_718, 3_141]
    public static let adaptiveSeeds =
        [discoverySeed] + confirmationSeeds
    public static let discoveryLearningRates =
        [0.0001, 0.0003, 0.001]
    public static let learningRateGridRationaleID =
        "bracket_measured_native_random_init_adamw_3e-4_v1"
    public static let learningRateGridAnchorArtifactSHA256 =
        "686bc619ca2019e0960a887b35a8e7dc853172b0d24d27cfbba01e5624c7360c"
    /// Conservative preflight-only allowance for safetensors metadata before
    /// a measured artifact size exists. Authorization uses the measured size.
    public static let maximumCheckpointHeaderPlanningBytes:
        Int64 = 16 * 1_024 * 1_024
    public static let requiredSemanticFamilyIDs = Set(
        ErgenticsPrimeNativeTextCorpus.SemanticFamily.allCases.map(\.rawValue)
    )

    public static func adaptiveReplicateID(
        profileID: String,
        probePurposeID: String,
        learningRate: Double,
        seed: Int
    ) -> String {
        // The schema-4 executor applies LR as Float and originally bound that
        // exact Float bit pattern into every durable replicate ID. Preserve
        // that historical identity contract when recomputing from decoded
        // Double report fields.
        let canonical = [
            adaptiveSearchID,
            profileID,
            probePurposeID,
            String(Float(learningRate).bitPattern),
            String(seed),
        ].joined(separator: "|")
        return SHA256.hash(data: Data(canonical.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    public enum TokenizerMode: String, Codable, CaseIterable, Sendable {
        /// Fully Swift, fixed, reversible tokenizer.
        case nativeUTF8Byte512 = "native_utf8_byte_512"

        /// Optional maintained BPE artifact compiler; loading and replay remain
        /// Swift-native and are hash-bound.
        case optionalByteLevelBPE16384 =
            "optional_byte_level_bpe_16384"

        public var vocabularySize: Int {
            switch self {
            case .nativeUTF8Byte512:
                PrimeNativeByteTokenizer.boundModelVocabularySize
            case .optionalByteLevelBPE16384:
                16_384
            }
        }
    }

    public struct ModelProfile: Codable, Equatable, Sendable {
        public let profileID: String
        public let modelDimension: Int
        public let layerCount: Int
        public let attentionHeads: Int
        public let keyValueHeads: Int
        public let headDimension: Int
        public let feedForwardDimension: Int
        /// Model context contract, not a claim about probe sequence length.
        public let maximumSequenceLength: Int
        public let ropeBase: Int

        public init(
            profileID: String,
            modelDimension: Int,
            layerCount: Int,
            attentionHeads: Int,
            keyValueHeads: Int,
            headDimension: Int,
            feedForwardDimension: Int,
            maximumSequenceLength: Int,
            ropeBase: Int
        ) {
            self.profileID = profileID
            self.modelDimension = modelDimension
            self.layerCount = layerCount
            self.attentionHeads = attentionHeads
            self.keyValueHeads = keyValueHeads
            self.headDimension = headDimension
            self.feedForwardDimension = feedForwardDimension
            self.maximumSequenceLength = maximumSequenceLength
            self.ropeBase = ropeBase
        }

        public var architectureValid: Bool {
            !profileID.isEmpty
                && modelDimension > 0
                && layerCount >= 4
                && attentionHeads > 0
                && keyValueHeads > 0
                && attentionHeads % keyValueHeads == 0
                && headDimension > 0
                && attentionHeads * headDimension == modelDimension
                && feedForwardDimension > modelDimension
                && maximumSequenceLength >= 512
                && modelDimension % 64 == 0
                && headDimension % 64 == 0
                && feedForwardDimension % 64 == 0
        }

        /// Exact maintained, bias-free `MLXLLM.LlamaModel` count: tied token
        /// embeddings, GQA, three SwiGLU projections, block RMSNorms, and final
        /// RMSNorm.
        public func parameterCount(vocabularySize: Int) -> Int64 {
            let d = Int64(modelDimension)
            let queryHeads = Int64(attentionHeads)
            let kvHeads = Int64(keyValueHeads)
            let head = Int64(headDimension)
            let ffn = Int64(feedForwardDimension)
            let embedding = Int64(vocabularySize) * d
            let query = d * queryHeads * head
            let keyAndValue = 2 * d * kvHeads * head
            let output = queryHeads * head * d
            let feedForward = 3 * d * ffn
            let blockNorms = 2 * d
            let perLayer =
                query + keyAndValue + output + feedForward + blockNorms
            return embedding + Int64(layerCount) * perLayer + d
        }
    }

    public static let native300M = ModelProfile(
        profileID: "ergentics_prime_native_300m_gqa_v1",
        modelDimension: 1_024,
        layerCount: 24,
        attentionHeads: 16,
        keyValueHeads: 4,
        headDimension: 64,
        feedForwardDimension: 2_816,
        maximumSequenceLength: 2_048,
        ropeBase: 10_000
    )

    public static let native1B = ModelProfile(
        profileID: "ergentics_prime_native_1b_gqa_v1",
        modelDimension: 2_048,
        layerCount: 24,
        attentionHeads: 32,
        keyValueHeads: 8,
        headDimension: 64,
        feedForwardDimension: 5_504,
        maximumSequenceLength: 2_048,
        ropeBase: 10_000
    )

    public static let native3B = ModelProfile(
        profileID: "ergentics_prime_native_3b_gqa_v1",
        modelDimension: 3_072,
        layerCount: 28,
        attentionHeads: 24,
        keyValueHeads: 8,
        headDimension: 128,
        feedForwardDimension: 8_192,
        maximumSequenceLength: 2_048,
        ropeBase: 500_000
    )

    /// Increasing scale order is part of the sweep contract.
    public static let profiles = [native300M, native1B, native3B]

    public struct TokenizerEvidence: Codable, Equatable, Sendable {
        public let mode: TokenizerMode
        public let tokenizerID: String
        public let vocabularySize: Int
        public let manifestSHA256: String
        public let sourceCorpusManifestSHA256: String?
        public let deterministicReplayPassed: Bool
        public let swiftRoundTripPassed: Bool
        public let externalCompilerUsed: Bool
        public let externalCompilerProvenanceBound: Bool
        public let compilerLibrary: String?
        public let compilerVersion: String?
        public let compilerLicenseID: String?

        public init(
            mode: TokenizerMode,
            tokenizerID: String,
            vocabularySize: Int,
            manifestSHA256: String,
            sourceCorpusManifestSHA256: String? = nil,
            deterministicReplayPassed: Bool,
            swiftRoundTripPassed: Bool,
            externalCompilerUsed: Bool,
            externalCompilerProvenanceBound: Bool = false,
            compilerLibrary: String? = nil,
            compilerVersion: String? = nil,
            compilerLicenseID: String? = nil
        ) {
            self.mode = mode
            self.tokenizerID = tokenizerID
            self.vocabularySize = vocabularySize
            self.manifestSHA256 = manifestSHA256
            self.sourceCorpusManifestSHA256 =
                sourceCorpusManifestSHA256
            self.deterministicReplayPassed =
                deterministicReplayPassed
            self.swiftRoundTripPassed = swiftRoundTripPassed
            self.externalCompilerUsed = externalCompilerUsed
            self.externalCompilerProvenanceBound =
                externalCompilerProvenanceBound
            self.compilerLibrary = compilerLibrary
            self.compilerVersion = compilerVersion
            self.compilerLicenseID = compilerLicenseID
        }
    }

    public struct CorpusEvidence: Codable, Equatable, Sendable {
        public let manifestSHA256: String
        public let firstPartyOrLicensedRightsBound: Bool
        public let exactObjectHashesPresent: Bool
        public let holdoutIsolated: Bool
        /// Token instances after deterministic deduplication under the bound
        /// tokenizer. This is not the number of token types.
        public let deduplicatedTrainingTokenInstances: Int64
        public let uniqueTrainingRows: Int64
        public let uniqueSemanticCombinations: Int64

        public init(
            manifestSHA256: String,
            firstPartyOrLicensedRightsBound: Bool,
            exactObjectHashesPresent: Bool,
            holdoutIsolated: Bool,
            deduplicatedTrainingTokenInstances: Int64,
            uniqueTrainingRows: Int64,
            uniqueSemanticCombinations: Int64
        ) {
            self.manifestSHA256 = manifestSHA256
            self.firstPartyOrLicensedRightsBound =
                firstPartyOrLicensedRightsBound
            self.exactObjectHashesPresent = exactObjectHashesPresent
            self.holdoutIsolated = holdoutIsolated
            self.deduplicatedTrainingTokenInstances =
                deduplicatedTrainingTokenInstances
            self.uniqueTrainingRows = uniqueTrainingRows
            self.uniqueSemanticCombinations =
                uniqueSemanticCombinations
        }
    }

    public struct ImplementationEvidence:
        Codable, Equatable, Sendable
    {
        public let executionLanguage: String
        public let buildConfiguration: String
        public let precision: String
        public let framework: String
        public let modelImplementation: String
        public let mlxSwiftVersion: String
        public let mlxSwiftExamplesVersion: String
        public let deviceType: String
        public let standardPrimitives: Bool
        public let customMetalKernels: Bool
        public let randomInitialization: Bool
        public let importedBaseWeights: Bool

        public init(
            executionLanguage: String,
            buildConfiguration: String,
            precision: String,
            framework: String,
            modelImplementation: String,
            mlxSwiftVersion: String,
            mlxSwiftExamplesVersion: String,
            deviceType: String,
            standardPrimitives: Bool,
            customMetalKernels: Bool,
            randomInitialization: Bool,
            importedBaseWeights: Bool
        ) {
            self.executionLanguage = executionLanguage
            self.buildConfiguration = buildConfiguration
            self.precision = precision
            self.framework = framework
            self.modelImplementation = modelImplementation
            self.mlxSwiftVersion = mlxSwiftVersion
            self.mlxSwiftExamplesVersion = mlxSwiftExamplesVersion
            self.deviceType = deviceType
            self.standardPrimitives = standardPrimitives
            self.customMetalKernels = customMetalKernels
            self.randomInitialization = randomInitialization
            self.importedBaseWeights = importedBaseWeights
        }
    }

    /// One full-weight initial-learning probe. Every scale in a comparable
    /// sweep must consume the exact same token presentation manifest, token
    /// count, sequence length, and batch size.
    public struct ProfileProbeEvidence:
        Codable, Equatable, Sendable
    {
        public let profileID: String
        public let parameterCount: Int64
        public let trainableParameterCount: Int64
        public let tokenizerManifestSHA256: String
        public let corpusManifestSHA256: String
        public let vocabularySize: Int
        public let profileMaximumSequenceLength: Int
        public let measuredSequenceLength: Int
        public let batchSize: Int
        public let gradientAccumulationSteps: Int?
        public let effectiveBatchSize: Int?
        public let probeTokenManifestSHA256: String
        public let probeTokenPresentations: Int64
        public let completedTrainingSteps: Int
        public let optimizer: String
        public let learningRate: Double
        public let weightDecay: Double
        public let precision: String
        public let seed: Int
        public let gradientClipNorm: Double?
        public let fullWeightTraining: Bool
        public let initialLoss: Double
        public let finalLoss: Double
        public let firstGradientNorm: Double
        public let tokensPerSecond: Double
        public let peakMemoryBytes: Int64
        public let finiteLogitsPassed: Bool
        public let causalMaskPassed: Bool
        /// `nil` means the costly multi-GB reload was not run for this sweep
        /// probe. `false` means it ran and failed, which rejects the probe.
        /// Strict reload remains mandatory for the selected full canary.
        public let checkpointReloadExact: Bool?
        public let repeatedInferenceExact: Bool
        /// Exact deterministic random-initialization state used by this
        /// profile probe. The profile timing preflight must bind back to one
        /// admitted probe state; a syntactically valid but unrelated state
        /// hash is not evidence.
        public let initializationFingerprintSHA256: String?

        // Schema-v3 matrix evidence. These fields are optional only so an old
        // report remains decodable and can fail closed. No nil value is
        // eligible.
        public let comparisonManifestSHA256: String?
        public let trainingScheduleManifestSHA256: String?
        public let heldoutEvaluationManifestSHA256: String?
        public let trainingUniqueRows: Int64?
        public let trainingSemanticFamilyUniqueRowCounts: [String: Int64]?
        public let trainingValidUniqueRows: Int64?
        public let trainingRefusalUniqueRows: Int64?
        public let trainingValidSemanticFamilyUniqueRowCounts:
            [String: Int64]?
        public let trainingRefusalSemanticFamilyUniqueRowCounts:
            [String: Int64]?
        public let trainingRefusalReasonUniqueRowCounts:
            [String: Int64]?
        public let trainingRefusalReasonScheduleSHA256: String?
        public let processedTokenCount: Int64?
        public let nonPaddingTokenCount: Int64?
        public let targetTokenCount: Int64?
        public let heldoutUniqueRows: Int64?
        public let heldoutValidUniqueRows: Int64?
        public let heldoutRefusalUniqueRows: Int64?
        public let heldoutValidSemanticFamilyUniqueRowCounts:
            [String: Int64]?
        public let heldoutRefusalSemanticFamilyUniqueRowCounts:
            [String: Int64]?
        public let heldoutRefusalReasonUniqueRowCounts:
            [String: Int64]?
        public let heldoutRefusalReasonScheduleSHA256: String?
        public let selectionValidationSplitIDs: [String]?
        public let trainingHeldoutRowHashIntersectionCount: Int64?
        public let heldoutTargetTokenCount: Int64?
        public let heldoutValidTargetTokenCount: Int64?
        public let heldoutRefusalTargetTokenCount: Int64?
        public let heldoutCrossEntropyBefore: Double?
        public let heldoutCrossEntropyAfter: Double?
        public let heldoutValidCrossEntropyBefore: Double?
        public let heldoutValidCrossEntropyAfter: Double?
        public let heldoutRefusalCrossEntropyBefore: Double?
        public let heldoutRefusalCrossEntropyAfter: Double?
        public let heldoutCrossEntropyStandardError: Double?
        public let heldoutFamilyCrossEntropyBefore: [String: Double]?
        public let heldoutFamilyCrossEntropyAfter: [String: Double]?
        public let optimizerImplementation: String?
        public let adamBeta1: Double?
        public let adamBeta2: Double?
        public let adamEpsilon: Double?
        public let decoupledWeightDecay: Bool?
        public let learningRateSchedule: String?
        public let gradientClipMode: String?
        public let lossReduction: String?
        public let coldStartSeconds: Double?
        public let timingWarmupSteps: Int?
        public let timingWarmupSeconds: Double?
        public let steadyStateMeasurementSeconds: Double?
        public let steadyStateMeasuredSteps: Int?
        public let steadyStateNonPaddingTokenCount: Int64?
        public let steadyStateTokensPerSecond: Double?
        public let throughputTokenBasis: String?
        public let heldoutEvaluationNonPaddingTokenCount: Int64?
        public let heldoutEvaluationElapsedSeconds: Double?
        public let hyperparameterSearchID: String?
        public let probePurposeID: String?
        public let scheduleID: String?
        public let learningRateDiscoverySeed: Int?
        public let replicateID: String?
        public let declaredLearningRateGrid: [Double]?
        public let declaredReplicateSeeds: [Int]?

        public init(
            profileID: String,
            parameterCount: Int64,
            trainableParameterCount: Int64,
            tokenizerManifestSHA256: String,
            corpusManifestSHA256: String,
            vocabularySize: Int,
            profileMaximumSequenceLength: Int,
            measuredSequenceLength: Int,
            batchSize: Int,
            gradientAccumulationSteps: Int? = nil,
            effectiveBatchSize: Int? = nil,
            probeTokenManifestSHA256: String,
            probeTokenPresentations: Int64,
            completedTrainingSteps: Int,
            optimizer: String,
            learningRate: Double,
            weightDecay: Double,
            precision: String,
            seed: Int,
            gradientClipNorm: Double?,
            fullWeightTraining: Bool,
            initialLoss: Double,
            finalLoss: Double,
            firstGradientNorm: Double,
            tokensPerSecond: Double,
            peakMemoryBytes: Int64,
            finiteLogitsPassed: Bool,
            causalMaskPassed: Bool,
            checkpointReloadExact: Bool?,
            repeatedInferenceExact: Bool,
            initializationFingerprintSHA256: String? = nil,
            comparisonManifestSHA256: String? = nil,
            trainingScheduleManifestSHA256: String? = nil,
            heldoutEvaluationManifestSHA256: String? = nil,
            trainingUniqueRows: Int64? = nil,
            trainingSemanticFamilyUniqueRowCounts:
                [String: Int64]? = nil,
            trainingValidUniqueRows: Int64? = nil,
            trainingRefusalUniqueRows: Int64? = nil,
            trainingValidSemanticFamilyUniqueRowCounts:
                [String: Int64]? = nil,
            trainingRefusalSemanticFamilyUniqueRowCounts:
                [String: Int64]? = nil,
            trainingRefusalReasonUniqueRowCounts:
                [String: Int64]? = nil,
            trainingRefusalReasonScheduleSHA256: String? = nil,
            processedTokenCount: Int64? = nil,
            nonPaddingTokenCount: Int64? = nil,
            targetTokenCount: Int64? = nil,
            heldoutUniqueRows: Int64? = nil,
            heldoutValidUniqueRows: Int64? = nil,
            heldoutRefusalUniqueRows: Int64? = nil,
            heldoutValidSemanticFamilyUniqueRowCounts:
                [String: Int64]? = nil,
            heldoutRefusalSemanticFamilyUniqueRowCounts:
                [String: Int64]? = nil,
            heldoutRefusalReasonUniqueRowCounts:
                [String: Int64]? = nil,
            heldoutRefusalReasonScheduleSHA256: String? = nil,
            selectionValidationSplitIDs: [String]? = nil,
            trainingHeldoutRowHashIntersectionCount: Int64? = nil,
            heldoutTargetTokenCount: Int64? = nil,
            heldoutValidTargetTokenCount: Int64? = nil,
            heldoutRefusalTargetTokenCount: Int64? = nil,
            heldoutCrossEntropyBefore: Double? = nil,
            heldoutCrossEntropyAfter: Double? = nil,
            heldoutValidCrossEntropyBefore: Double? = nil,
            heldoutValidCrossEntropyAfter: Double? = nil,
            heldoutRefusalCrossEntropyBefore: Double? = nil,
            heldoutRefusalCrossEntropyAfter: Double? = nil,
            heldoutCrossEntropyStandardError: Double? = nil,
            heldoutFamilyCrossEntropyBefore:
                [String: Double]? = nil,
            heldoutFamilyCrossEntropyAfter:
                [String: Double]? = nil,
            optimizerImplementation: String? = nil,
            adamBeta1: Double? = nil,
            adamBeta2: Double? = nil,
            adamEpsilon: Double? = nil,
            decoupledWeightDecay: Bool? = nil,
            learningRateSchedule: String? = nil,
            gradientClipMode: String? = nil,
            lossReduction: String? = nil,
            coldStartSeconds: Double? = nil,
            timingWarmupSteps: Int? = nil,
            timingWarmupSeconds: Double? = nil,
            steadyStateMeasurementSeconds: Double? = nil,
            steadyStateMeasuredSteps: Int? = nil,
            steadyStateNonPaddingTokenCount: Int64? = nil,
            steadyStateTokensPerSecond: Double? = nil,
            throughputTokenBasis: String? = nil,
            heldoutEvaluationNonPaddingTokenCount: Int64? = nil,
            heldoutEvaluationElapsedSeconds: Double? = nil,
            hyperparameterSearchID: String? = nil,
            probePurposeID: String? = nil,
            scheduleID: String? = nil,
            learningRateDiscoverySeed: Int? = nil,
            replicateID: String? = nil,
            declaredLearningRateGrid: [Double]? = nil,
            declaredReplicateSeeds: [Int]? = nil
        ) {
            self.profileID = profileID
            self.parameterCount = parameterCount
            self.trainableParameterCount = trainableParameterCount
            self.tokenizerManifestSHA256 =
                tokenizerManifestSHA256
            self.corpusManifestSHA256 = corpusManifestSHA256
            self.vocabularySize = vocabularySize
            self.profileMaximumSequenceLength =
                profileMaximumSequenceLength
            self.measuredSequenceLength = measuredSequenceLength
            self.batchSize = batchSize
            self.gradientAccumulationSteps =
                gradientAccumulationSteps
            self.effectiveBatchSize = effectiveBatchSize
            self.probeTokenManifestSHA256 =
                probeTokenManifestSHA256
            self.probeTokenPresentations = probeTokenPresentations
            self.completedTrainingSteps = completedTrainingSteps
            self.optimizer = optimizer
            self.learningRate = learningRate
            self.weightDecay = weightDecay
            self.precision = precision
            self.seed = seed
            self.gradientClipNorm = gradientClipNorm
            self.fullWeightTraining = fullWeightTraining
            self.initialLoss = initialLoss
            self.finalLoss = finalLoss
            self.firstGradientNorm = firstGradientNorm
            self.tokensPerSecond = tokensPerSecond
            self.peakMemoryBytes = peakMemoryBytes
            self.finiteLogitsPassed = finiteLogitsPassed
            self.causalMaskPassed = causalMaskPassed
            self.checkpointReloadExact = checkpointReloadExact
            self.repeatedInferenceExact = repeatedInferenceExact
            self.initializationFingerprintSHA256 =
                initializationFingerprintSHA256
            self.comparisonManifestSHA256 =
                comparisonManifestSHA256
            self.trainingScheduleManifestSHA256 =
                trainingScheduleManifestSHA256
            self.heldoutEvaluationManifestSHA256 =
                heldoutEvaluationManifestSHA256
            self.trainingUniqueRows = trainingUniqueRows
            self.trainingSemanticFamilyUniqueRowCounts =
                trainingSemanticFamilyUniqueRowCounts
            self.trainingValidUniqueRows =
                trainingValidUniqueRows
            self.trainingRefusalUniqueRows =
                trainingRefusalUniqueRows
            self.trainingValidSemanticFamilyUniqueRowCounts =
                trainingValidSemanticFamilyUniqueRowCounts
            self.trainingRefusalSemanticFamilyUniqueRowCounts =
                trainingRefusalSemanticFamilyUniqueRowCounts
            self.trainingRefusalReasonUniqueRowCounts =
                trainingRefusalReasonUniqueRowCounts
            self.trainingRefusalReasonScheduleSHA256 =
                trainingRefusalReasonScheduleSHA256
            self.processedTokenCount = processedTokenCount
            self.nonPaddingTokenCount = nonPaddingTokenCount
            self.targetTokenCount = targetTokenCount
            self.heldoutUniqueRows = heldoutUniqueRows
            self.heldoutValidUniqueRows =
                heldoutValidUniqueRows
            self.heldoutRefusalUniqueRows =
                heldoutRefusalUniqueRows
            self.heldoutValidSemanticFamilyUniqueRowCounts =
                heldoutValidSemanticFamilyUniqueRowCounts
            self.heldoutRefusalSemanticFamilyUniqueRowCounts =
                heldoutRefusalSemanticFamilyUniqueRowCounts
            self.heldoutRefusalReasonUniqueRowCounts =
                heldoutRefusalReasonUniqueRowCounts
            self.heldoutRefusalReasonScheduleSHA256 =
                heldoutRefusalReasonScheduleSHA256
            self.selectionValidationSplitIDs =
                selectionValidationSplitIDs
            self.trainingHeldoutRowHashIntersectionCount =
                trainingHeldoutRowHashIntersectionCount
            self.heldoutTargetTokenCount = heldoutTargetTokenCount
            self.heldoutValidTargetTokenCount =
                heldoutValidTargetTokenCount
            self.heldoutRefusalTargetTokenCount =
                heldoutRefusalTargetTokenCount
            self.heldoutCrossEntropyBefore =
                heldoutCrossEntropyBefore
            self.heldoutCrossEntropyAfter =
                heldoutCrossEntropyAfter
            self.heldoutValidCrossEntropyBefore =
                heldoutValidCrossEntropyBefore
            self.heldoutValidCrossEntropyAfter =
                heldoutValidCrossEntropyAfter
            self.heldoutRefusalCrossEntropyBefore =
                heldoutRefusalCrossEntropyBefore
            self.heldoutRefusalCrossEntropyAfter =
                heldoutRefusalCrossEntropyAfter
            self.heldoutCrossEntropyStandardError =
                heldoutCrossEntropyStandardError
            self.heldoutFamilyCrossEntropyBefore =
                heldoutFamilyCrossEntropyBefore
            self.heldoutFamilyCrossEntropyAfter =
                heldoutFamilyCrossEntropyAfter
            self.optimizerImplementation = optimizerImplementation
            self.adamBeta1 = adamBeta1
            self.adamBeta2 = adamBeta2
            self.adamEpsilon = adamEpsilon
            self.decoupledWeightDecay = decoupledWeightDecay
            self.learningRateSchedule = learningRateSchedule
            self.gradientClipMode = gradientClipMode
            self.lossReduction = lossReduction
            self.coldStartSeconds = coldStartSeconds
            self.timingWarmupSteps = timingWarmupSteps
            self.timingWarmupSeconds = timingWarmupSeconds
            self.steadyStateMeasurementSeconds =
                steadyStateMeasurementSeconds
            self.steadyStateMeasuredSteps =
                steadyStateMeasuredSteps
            self.steadyStateNonPaddingTokenCount =
                steadyStateNonPaddingTokenCount
            self.steadyStateTokensPerSecond =
                steadyStateTokensPerSecond
            self.throughputTokenBasis = throughputTokenBasis
            self.heldoutEvaluationNonPaddingTokenCount =
                heldoutEvaluationNonPaddingTokenCount
            self.heldoutEvaluationElapsedSeconds =
                heldoutEvaluationElapsedSeconds
            self.hyperparameterSearchID = hyperparameterSearchID
            self.probePurposeID = probePurposeID
            self.scheduleID = scheduleID
            self.learningRateDiscoverySeed =
                learningRateDiscoverySeed
            self.replicateID = replicateID
            self.declaredLearningRateGrid =
                declaredLearningRateGrid
            self.declaredReplicateSeeds = declaredReplicateSeeds
        }

        public var relativeLossReduction: Double {
            guard initialLoss.isFinite, initialLoss > 0,
                  finalLoss.isFinite else {
                return -.infinity
            }
            return (initialLoss - finalLoss) / initialLoss
        }

        public var heldoutRelativeLossReduction: Double {
            guard let before = heldoutCrossEntropyBefore,
                  let after = heldoutCrossEntropyAfter,
                  before.isFinite, before > 0,
                  after.isFinite else {
                return -.infinity
            }
            return (before - after) / before
        }
    }

    /// One measured, durable write+read preflight for a profile's actual FP32
    /// checkpoint plus its fixed evaluation shards. It is profile evidence,
    /// not LR/seed-trial evidence, so discovery reports never need backfilling.
    public struct ProfileIOEvidence:
        Codable, Equatable, Sendable
    {
        public let profileID: String
        public let parameterCount: Int64
        public let measurementManifestSHA256: String
        public let checkpointPrecision: String
        public let checkpointPayloadBytes: Int64
        public let checkpointArtifactBytes: Int64
        public let shardArtifactBytes: Int64
        public let bytesTransferred: Int64
        public let elapsedSeconds: Double
        public let bytesPerSecond: Double
        public let durableWriteAndExactReadPassed: Bool

        public init(
            profileID: String,
            parameterCount: Int64,
            measurementManifestSHA256: String,
            checkpointPrecision: String,
            checkpointPayloadBytes: Int64,
            checkpointArtifactBytes: Int64,
            shardArtifactBytes: Int64,
            bytesTransferred: Int64,
            elapsedSeconds: Double,
            bytesPerSecond: Double,
            durableWriteAndExactReadPassed: Bool
        ) {
            self.profileID = profileID
            self.parameterCount = parameterCount
            self.measurementManifestSHA256 =
                measurementManifestSHA256
            self.checkpointPrecision = checkpointPrecision
            self.checkpointPayloadBytes =
                checkpointPayloadBytes
            self.checkpointArtifactBytes =
                checkpointArtifactBytes
            self.shardArtifactBytes = shardArtifactBytes
            self.bytesTransferred = bytesTransferred
            self.elapsedSeconds = elapsedSeconds
            self.bytesPerSecond = bytesPerSecond
            self.durableWriteAndExactReadPassed =
                durableWriteAndExactReadPassed
        }
    }

    /// Profile-bound autoregressive timing preflight. Teacher-forced
    /// cross-entropy throughput is intentionally not accepted as a generation
    /// proxy: prompt prefill and cached one-token decode are measured
    /// separately under the exact target-independent fixed-cap contract.
    public struct ProfileAutoregressivePreflightEvidence:
        Codable, Equatable, Sendable
    {
        public let profileID: String
        public let parameterCount: Int64
        public let measurementManifestSHA256: String
        public let corpusManifestSHA256: String
        public let orderedEvaluationRowIDsSHA256: String
        public let contextLengthGroupingSHA256: String
        public let artifactSHA256: String
        public let artifactRelativePath: String
        public let probeSeed: Int
        public let probeReplicateID: String
        public let modelStateSHA256: String
        public let evaluationRowCount: Int64
        public let coveredEvaluationRowCount: Int64
        public let contextLengthGroupCount: Int
        public let coveredContextLengthGroupCount: Int
        public let batchSize: Int
        public let promptOnlyBatching: Bool
        public let targetIndependentFixedGenerationCap: Bool
        public let eosAllowed: Bool
        public let eosIgnoredForTiming: Bool
        public let generationCapTokenCount: Int
        public let kvCacheEnabled: Bool
        public let promptPrefillTokenCount: Int64
        public let promptPrefillElapsedSeconds: Double
        public let promptPrefillTokensPerSecond: Double
        public let cachedDecodeTokenCount: Int64
        public let cachedDecodeElapsedSeconds: Double
        public let cachedDecodeTokensPerSecond: Double
        public let cachedUncachedGreedyTokenParity: Bool
        public let cachedUncachedMaximumLogitDelta: Double
        public let peakMemoryBytes: Int64

        public init(
            profileID: String,
            parameterCount: Int64,
            measurementManifestSHA256: String,
            corpusManifestSHA256: String,
            orderedEvaluationRowIDsSHA256: String,
            contextLengthGroupingSHA256: String,
            artifactSHA256: String,
            artifactRelativePath: String,
            probeSeed: Int,
            probeReplicateID: String,
            modelStateSHA256: String,
            evaluationRowCount: Int64,
            coveredEvaluationRowCount: Int64,
            contextLengthGroupCount: Int,
            coveredContextLengthGroupCount: Int,
            batchSize: Int,
            promptOnlyBatching: Bool,
            targetIndependentFixedGenerationCap: Bool,
            eosAllowed: Bool,
            eosIgnoredForTiming: Bool,
            generationCapTokenCount: Int,
            kvCacheEnabled: Bool,
            promptPrefillTokenCount: Int64,
            promptPrefillElapsedSeconds: Double,
            promptPrefillTokensPerSecond: Double,
            cachedDecodeTokenCount: Int64,
            cachedDecodeElapsedSeconds: Double,
            cachedDecodeTokensPerSecond: Double,
            cachedUncachedGreedyTokenParity: Bool,
            cachedUncachedMaximumLogitDelta: Double,
            peakMemoryBytes: Int64
        ) {
            self.profileID = profileID
            self.parameterCount = parameterCount
            self.measurementManifestSHA256 =
                measurementManifestSHA256
            self.corpusManifestSHA256 = corpusManifestSHA256
            self.orderedEvaluationRowIDsSHA256 =
                orderedEvaluationRowIDsSHA256
            self.contextLengthGroupingSHA256 =
                contextLengthGroupingSHA256
            self.artifactSHA256 = artifactSHA256
            self.artifactRelativePath = artifactRelativePath
            self.probeSeed = probeSeed
            self.probeReplicateID = probeReplicateID
            self.modelStateSHA256 = modelStateSHA256
            self.evaluationRowCount = evaluationRowCount
            self.coveredEvaluationRowCount =
                coveredEvaluationRowCount
            self.contextLengthGroupCount =
                contextLengthGroupCount
            self.coveredContextLengthGroupCount =
                coveredContextLengthGroupCount
            self.batchSize = batchSize
            self.promptOnlyBatching = promptOnlyBatching
            self.targetIndependentFixedGenerationCap =
                targetIndependentFixedGenerationCap
            self.eosAllowed = eosAllowed
            self.eosIgnoredForTiming = eosIgnoredForTiming
            self.generationCapTokenCount =
                generationCapTokenCount
            self.kvCacheEnabled = kvCacheEnabled
            self.promptPrefillTokenCount =
                promptPrefillTokenCount
            self.promptPrefillElapsedSeconds =
                promptPrefillElapsedSeconds
            self.promptPrefillTokensPerSecond =
                promptPrefillTokensPerSecond
            self.cachedDecodeTokenCount =
                cachedDecodeTokenCount
            self.cachedDecodeElapsedSeconds =
                cachedDecodeElapsedSeconds
            self.cachedDecodeTokensPerSecond =
                cachedDecodeTokensPerSecond
            self.cachedUncachedGreedyTokenParity =
                cachedUncachedGreedyTokenParity
            self.cachedUncachedMaximumLogitDelta =
                cachedUncachedMaximumLogitDelta
            self.peakMemoryBytes = peakMemoryBytes
        }
    }

    public struct Inputs: Codable, Equatable, Sendable {
        public let tokenizer: TokenizerEvidence
        public let corpus: CorpusEvidence
        public let implementation: ImplementationEvidence
        public let probes: [ProfileProbeEvidence]
        public let failedProfileTrials:
            [ErgenticsNativeLanguageProfileTrialFailure.Evidence]
        /// Effective training token presentations planned for the eventual
        /// bounded canary. Repeated presentations are counted honestly.
        public let plannedTrainingTokenPresentations: Int64
        public let plannedTrainingBlockCount: Int64?
        public let plannedTrainingScheduleID: String?
        public let plannedValidRowPresentations: Int64?
        public let plannedRefusalRowPresentations: Int64?
        public let plannedValidSemanticFamilyRowPresentations:
            [String: Int64]?
        public let plannedRefusalSemanticFamilyRowPresentations:
            [String: Int64]?
        public let unifiedMemoryBytes: Int64
        public let freeDiskBytes: Int64
        public let maximumWallClockSeconds: Double
        /// Absolute held-out cross-entropy difference below which two
        /// architecture profiles are treated as practically indistinguishable.
        /// Optional for decoding old inputs; nil is fail-closed.
        public let qualityIndifferenceCrossEntropy: Double?
        /// Legacy schema-5 diagnostic input. Schema 6 does not interpret this
        /// as a confidence critical value and never uses it for selection.
        public let qualityConfidenceZ: Double?
        /// Legacy teacher-forced loss-evaluation count, retained for artifact
        /// decoding and reporting only. It is not used for generation timing.
        public let plannedFullEvaluationNonPaddingTokenCount: Int64?
        public let plannedFullEvaluationPromptTokenCount: Int64?
        public let plannedFullEvaluationMaximumGeneratedTokenCount:
            Int64?
        public let plannedShardArtifactBytesUpperBound: Int64?
        public let profileIOBenchmarks: [ProfileIOEvidence]
        public let profileAutoregressivePreflights:
            [ProfileAutoregressivePreflightEvidence]

        public init(
            tokenizer: TokenizerEvidence,
            corpus: CorpusEvidence,
            implementation: ImplementationEvidence,
            probes: [ProfileProbeEvidence],
            failedProfileTrials:
                [
                    ErgenticsNativeLanguageProfileTrialFailure
                        .Evidence
                ] = [],
            plannedTrainingTokenPresentations: Int64,
            plannedTrainingBlockCount: Int64? = nil,
            plannedTrainingScheduleID: String? = nil,
            plannedValidRowPresentations: Int64? = nil,
            plannedRefusalRowPresentations: Int64? = nil,
            plannedValidSemanticFamilyRowPresentations:
                [String: Int64]? = nil,
            plannedRefusalSemanticFamilyRowPresentations:
                [String: Int64]? = nil,
            unifiedMemoryBytes: Int64,
            freeDiskBytes: Int64,
            maximumWallClockSeconds: Double,
            qualityIndifferenceCrossEntropy: Double? = nil,
            qualityConfidenceZ: Double? = nil,
            plannedFullEvaluationNonPaddingTokenCount: Int64? = nil,
            plannedFullEvaluationPromptTokenCount: Int64? = nil,
            plannedFullEvaluationMaximumGeneratedTokenCount:
                Int64? = nil,
            plannedShardArtifactBytesUpperBound: Int64? = nil,
            profileIOBenchmarks: [ProfileIOEvidence] = [],
            profileAutoregressivePreflights:
                [ProfileAutoregressivePreflightEvidence] = []
        ) {
            self.tokenizer = tokenizer
            self.corpus = corpus
            self.implementation = implementation
            self.probes = probes
            self.failedProfileTrials = failedProfileTrials
            self.plannedTrainingTokenPresentations =
                plannedTrainingTokenPresentations
            self.plannedTrainingBlockCount =
                plannedTrainingBlockCount
            self.plannedTrainingScheduleID =
                plannedTrainingScheduleID
            self.plannedValidRowPresentations =
                plannedValidRowPresentations
            self.plannedRefusalRowPresentations =
                plannedRefusalRowPresentations
            self.plannedValidSemanticFamilyRowPresentations =
                plannedValidSemanticFamilyRowPresentations
            self.plannedRefusalSemanticFamilyRowPresentations =
                plannedRefusalSemanticFamilyRowPresentations
            self.unifiedMemoryBytes = unifiedMemoryBytes
            self.freeDiskBytes = freeDiskBytes
            self.maximumWallClockSeconds = maximumWallClockSeconds
            self.qualityIndifferenceCrossEntropy =
                qualityIndifferenceCrossEntropy
            self.qualityConfidenceZ = qualityConfidenceZ
            self.plannedFullEvaluationNonPaddingTokenCount =
                plannedFullEvaluationNonPaddingTokenCount
            self.plannedFullEvaluationPromptTokenCount =
                plannedFullEvaluationPromptTokenCount
            self.plannedFullEvaluationMaximumGeneratedTokenCount =
                plannedFullEvaluationMaximumGeneratedTokenCount
            self.plannedShardArtifactBytesUpperBound =
                plannedShardArtifactBytesUpperBound
            self.profileIOBenchmarks = profileIOBenchmarks
            self.profileAutoregressivePreflights =
                profileAutoregressivePreflights
        }
    }

    public struct Leg: Codable, Equatable, Sendable {
        public let id: String
        public let pass: Bool
        public let detail: String
    }

    public struct QualityRejectedTrial:
        Codable, Equatable, Sendable
    {
        public let probePurposeID: String
        public let replicateID: String
        public let seed: Int
        public let learningRate: Double
        public let minimumRelativeLossReduction: Double
        public let semanticFamilyQualityRuleID: String
        public let heldoutCrossEntropyBefore: Double
        public let heldoutCrossEntropyAfter: Double
        public let heldoutValidCrossEntropyBefore: Double
        public let heldoutValidCrossEntropyAfter: Double
        public let heldoutRefusalCrossEntropyBefore: Double
        public let heldoutRefusalCrossEntropyAfter: Double
        public let heldoutFamilyCrossEntropyBefore:
            [String: Double]
        public let heldoutFamilyCrossEntropyAfter:
            [String: Double]
        public let failedQualityPredicates: [String]

        enum CodingKeys: String, CodingKey {
            case probePurposeID = "probe_purpose_id"
            case replicateID = "replicate_id"
            case seed
            case learningRate = "learning_rate"
            case minimumRelativeLossReduction =
                "minimum_relative_loss_reduction"
            case semanticFamilyQualityRuleID =
                "semantic_family_quality_rule_id"
            case heldoutCrossEntropyBefore =
                "heldout_cross_entropy_before"
            case heldoutCrossEntropyAfter =
                "heldout_cross_entropy_after"
            case heldoutValidCrossEntropyBefore =
                "heldout_valid_cross_entropy_before"
            case heldoutValidCrossEntropyAfter =
                "heldout_valid_cross_entropy_after"
            case heldoutRefusalCrossEntropyBefore =
                "heldout_refusal_cross_entropy_before"
            case heldoutRefusalCrossEntropyAfter =
                "heldout_refusal_cross_entropy_after"
            case heldoutFamilyCrossEntropyBefore =
                "heldout_family_cross_entropy_before"
            case heldoutFamilyCrossEntropyAfter =
                "heldout_family_cross_entropy_after"
            case failedQualityPredicates =
                "failed_quality_predicates"
        }
    }

    public struct ProfileAssessment: Codable, Equatable, Sendable {
        public let profile: ModelProfile
        public let tokenizerMode: TokenizerMode
        public let vocabularySize: Int
        public let parameterCount: Int64
        public let minimumFP32AdamTrainingStateBytes: Int64
        public let fp32CheckpointBytes: Int64
        public let broadLanguagePlanningTokenInstances: Int64
        public let minimumDeduplicatedTrainingTokenInstances: Int64
        public let minimumUniqueTrainingRows: Int64
        public let minimumUniqueSemanticCombinations: Int64
        public let minimumPlannedTrainingTokenPresentations: Int64
        public let measuredSequenceLength: Int?
        public let measuredBatchSize: Int?
        public let measuredTokensPerSecond: Double?
        public let measuredPeakMemoryBytes: Int64?
        /// Descriptive reduction over all selected-rate replicates. It
        /// includes adaptive discovery seed 1618 and is not confirmatory.
        public let relativeLossReduction: Double?
        public let heldoutCrossEntropyBefore: Double?
        public let heldoutCrossEntropyAfter: Double?
        /// Legacy schema-6 alias for the descriptive all-replicate
        /// between-seed standard error. It is not used for selection.
        public let heldoutCrossEntropyStandardError: Double?
        /// Propagated uncertainty of the independently measured held-out
        /// rows inside each replicate. This is reported separately because it
        /// is not a substitute for between-seed training variance.
        public let heldoutCrossEntropyWithinRowStandardError: Double?
        /// Descriptive standard error across all selected-rate outcomes,
        /// including the adaptive discovery seed.
        public let heldoutCrossEntropyBetweenSeedStandardError: Double?
        public let independentConfirmationReplicateCount: Int
        public let confirmationRelativeLossReduction: Double?
        public let confirmationHeldoutCrossEntropyBefore: Double?
        public let confirmationHeldoutCrossEntropyAfter: Double?
        public let confirmationHeldoutCrossEntropyWithinRowStandardError:
            Double?
        public let confirmationHeldoutCrossEntropyBetweenSeedStandardError:
            Double?
        public let confirmationHeldoutValidCrossEntropyAfter: Double?
        public let confirmationHeldoutRefusalCrossEntropyAfter:
            Double?
        public let confirmationHeldoutFamilyCrossEntropyAfter:
            [String: Double]?
        public let independentConfirmationComparisonGrounded: Bool
        public let heldoutValidCrossEntropyBefore: Double?
        public let heldoutValidCrossEntropyAfter: Double?
        public let heldoutRefusalCrossEntropyBefore: Double?
        public let heldoutRefusalCrossEntropyAfter: Double?
        public let selectedLearningRate: Double?
        public let evidenceTrialCount: Int
        public let qualityRejectedTrialCount: Int
        public let qualityRejectedTrials: [QualityRejectedTrial]
        public let failedTrialCount: Int
        public let failedTrialClassifications:
            [
                ErgenticsNativeLanguageProfileTrialFailure
                    .Classification
            ]
        public let profileTrialFailureEvidenceGrounded: Bool
        public let completedLearningRateGrid: [Double]
        public let completedReplicateSeeds: [Int]
        public let missingConfirmationSeeds: [Int]
        public let discoveryLearningRateGridGrounded: Bool
        public let selectedLearningRateReplicatesGrounded: Bool
        public let projectedCanaryTrainingSeconds: Double?
        public let projectedEvaluationSeconds: Double?
        public let projectedCheckpointAndShardIOSeconds: Double?
        public let projectedTotalSeconds: Double?
        public let profileProbeGrounded: Bool
        public let balancedTrainingScheduleGrounded: Bool
        public let tokenAccountingGrounded: Bool
        public let disjointHeldoutGrounded: Bool
        public let exactOptimizerGrounded: Bool
        public let coldAndSteadyTimingGrounded: Bool
        public let profileIOBenchmarkGrounded: Bool
        public let autoregressivePreflightGrounded: Bool
        public let measuredPromptPrefillTokensPerSecond: Double?
        public let measuredCachedDecodeTokensPerSecond: Double?
        /// The complete maintained profile screen shares one matrix
        /// contract. This can be true before I/O/AR/full-wall eligibility.
        public let profileScreenMatrixComparable: Bool
        public let architectureProfileComparable: Bool
        public let corpusMassSufficient: Bool
        public let plannedTokenPresentationsSufficient: Bool
        public let memorySufficient: Bool
        public let wallClockSufficient: Bool
        public let learningSlopeNonRegressed: Bool
        public let currentFunctionalCanaryEligible: Bool
        public let blockedReason: String?

        enum CodingKeys: String, CodingKey {
            case profile
            case tokenizerMode = "tokenizer_mode"
            case vocabularySize = "vocabulary_size"
            case parameterCount = "parameter_count"
            case minimumFP32AdamTrainingStateBytes =
                "minimum_fp32_adam_training_state_bytes"
            case fp32CheckpointBytes = "fp32_checkpoint_bytes"
            case broadLanguagePlanningTokenInstances =
                "broad_language_planning_token_instances"
            case minimumDeduplicatedTrainingTokenInstances =
                "minimum_deduplicated_training_token_instances"
            case minimumUniqueTrainingRows =
                "minimum_unique_training_rows"
            case minimumUniqueSemanticCombinations =
                "minimum_unique_semantic_combinations"
            case minimumPlannedTrainingTokenPresentations =
                "minimum_planned_training_token_presentations"
            case measuredSequenceLength = "measured_sequence_length"
            case measuredBatchSize = "measured_batch_size"
            case measuredTokensPerSecond =
                "measured_tokens_per_second"
            case measuredPeakMemoryBytes =
                "measured_peak_memory_bytes"
            case relativeLossReduction =
                "relative_loss_reduction"
            case heldoutCrossEntropyBefore =
                "heldout_cross_entropy_before"
            case heldoutCrossEntropyAfter =
                "heldout_cross_entropy_after"
            case heldoutCrossEntropyStandardError =
                "heldout_cross_entropy_standard_error"
            case heldoutCrossEntropyWithinRowStandardError =
                "heldout_cross_entropy_within_row_standard_error"
            case heldoutCrossEntropyBetweenSeedStandardError =
                "heldout_cross_entropy_between_seed_standard_error"
            case independentConfirmationReplicateCount =
                "independent_confirmation_replicate_count"
            case confirmationRelativeLossReduction =
                "confirmation_relative_loss_reduction"
            case confirmationHeldoutCrossEntropyBefore =
                "confirmation_heldout_cross_entropy_before"
            case confirmationHeldoutCrossEntropyAfter =
                "confirmation_heldout_cross_entropy_after"
            case confirmationHeldoutCrossEntropyWithinRowStandardError =
                "confirmation_heldout_cross_entropy_within_row_standard_error"
            case confirmationHeldoutCrossEntropyBetweenSeedStandardError =
                "confirmation_heldout_cross_entropy_between_seed_standard_error"
            case confirmationHeldoutValidCrossEntropyAfter =
                "confirmation_heldout_valid_cross_entropy_after"
            case confirmationHeldoutRefusalCrossEntropyAfter =
                "confirmation_heldout_refusal_cross_entropy_after"
            case confirmationHeldoutFamilyCrossEntropyAfter =
                "confirmation_heldout_family_cross_entropy_after"
            case independentConfirmationComparisonGrounded =
                "independent_confirmation_comparison_grounded"
            case heldoutValidCrossEntropyBefore =
                "heldout_valid_cross_entropy_before"
            case heldoutValidCrossEntropyAfter =
                "heldout_valid_cross_entropy_after"
            case heldoutRefusalCrossEntropyBefore =
                "heldout_refusal_cross_entropy_before"
            case heldoutRefusalCrossEntropyAfter =
                "heldout_refusal_cross_entropy_after"
            case selectedLearningRate = "selected_learning_rate"
            case evidenceTrialCount = "evidence_trial_count"
            case qualityRejectedTrialCount =
                "quality_rejected_trial_count"
            case qualityRejectedTrials =
                "quality_rejected_trials"
            case failedTrialCount = "failed_trial_count"
            case failedTrialClassifications =
                "failed_trial_classifications"
            case profileTrialFailureEvidenceGrounded =
                "profile_trial_failure_evidence_grounded"
            case completedLearningRateGrid =
                "completed_learning_rate_grid"
            case completedReplicateSeeds =
                "completed_replicate_seeds"
            case missingConfirmationSeeds =
                "missing_confirmation_seeds"
            case discoveryLearningRateGridGrounded =
                "discovery_learning_rate_grid_grounded"
            case selectedLearningRateReplicatesGrounded =
                "selected_learning_rate_replicates_grounded"
            case projectedCanaryTrainingSeconds =
                "projected_canary_training_seconds"
            case projectedEvaluationSeconds =
                "projected_evaluation_seconds"
            case projectedCheckpointAndShardIOSeconds =
                "projected_checkpoint_and_shard_io_seconds"
            case projectedTotalSeconds =
                "projected_total_seconds"
            case profileProbeGrounded = "profile_probe_grounded"
            case balancedTrainingScheduleGrounded =
                "balanced_training_schedule_grounded"
            case tokenAccountingGrounded =
                "token_accounting_grounded"
            case disjointHeldoutGrounded =
                "disjoint_heldout_grounded"
            case exactOptimizerGrounded =
                "exact_optimizer_grounded"
            case coldAndSteadyTimingGrounded =
                "cold_and_steady_timing_grounded"
            case profileIOBenchmarkGrounded =
                "profile_io_benchmark_grounded"
            case autoregressivePreflightGrounded =
                "autoregressive_preflight_grounded"
            case measuredPromptPrefillTokensPerSecond =
                "measured_prompt_prefill_tokens_per_second"
            case measuredCachedDecodeTokensPerSecond =
                "measured_cached_decode_tokens_per_second"
            case profileScreenMatrixComparable =
                "profile_screen_matrix_comparable"
            case architectureProfileComparable =
                "architecture_profile_comparable"
            case corpusMassSufficient = "corpus_mass_sufficient"
            case plannedTokenPresentationsSufficient =
                "planned_token_presentations_sufficient"
            case memorySufficient = "memory_sufficient"
            case wallClockSufficient = "wall_clock_sufficient"
            case learningSlopeNonRegressed =
                "learning_slope_non_regressed"
            case currentFunctionalCanaryEligible =
                "current_functional_canary_eligible"
            case blockedReason = "blocked_reason"
        }
    }

    public struct Recommendation: Codable, Equatable, Sendable {
        public let schemaVersion: String
        public let outcome: String
        public let familyID: String
        public let comparisonKind: String
        public let comparisonBudgetScopeID: String
        public let comparisonPrerequisiteIDs: [String]
        public let replicateVariationScopeID: String
        public let initializationVsScheduleFactorAttributionAuthorized:
            Bool
        public let claimScope: String
        public let selectionReason: String
        public let nextAction: String
        public let nextUnmeasuredProfileID: String?
        public let selectedProfileID: String?
        public let prioritizedProfileForIOPreflightID: String?
        public let prioritizedProfileForAutoregressivePreflightID:
            String?
        public let selectedTokenizerMode: TokenizerMode
        public let selectedParameterCount: Int64?
        public let qualityIndifferenceCrossEntropy: Double?
        public let legacyQualityConfidenceZDiagnostic: Double?
        public let relativeLossReductionMethodID: String
        public let profileComparisonUncertaintyMethodID: String
        public let minimumIndependentConfirmationReplicateCount:
            Int
        public let profileComparisonCalibrationID: String?
        public let profileComparisonGrounded: Bool
        public let plannedTrainingTokenPresentations: Int64
        public let plannedTrainingBlockCount: Int64?
        public let plannedTrainingScheduleID: String?
        public let plannedValidRowPresentations: Int64?
        public let plannedRefusalRowPresentations: Int64?
        public let plannedValidSemanticFamilyRowPresentations:
            [String: Int64]?
        public let plannedRefusalSemanticFamilyRowPresentations:
            [String: Int64]?
        public let plannedFullEvaluationNonPaddingTokenCount: Int64?
        public let plannedFullEvaluationPromptTokenCount: Int64?
        public let plannedFullEvaluationMaximumGeneratedTokenCount:
            Int64?
        public let plannedShardArtifactBytesUpperBound: Int64?
        public let maximumWallClockSeconds: Double
        public let adaptiveDiscoveryLearningRates: [Double]
        public let learningRateGridRationaleID: String
        public let learningRateGridAnchorArtifactSHA256: String
        public let adaptiveReplicateSeeds: [Int]
        public let checkpointHeaderPlanningUpperBoundBytes: Int64
        public let profileIOBenchmarks: [ProfileIOEvidence]
        public let profileAutoregressivePreflights:
            [ProfileAutoregressivePreflightEvidence]
        public let failedProfileTrials:
            [ErgenticsNativeLanguageProfileTrialFailure.Evidence]
        public let profileScreenMatrixComparable: Bool
        public let architectureQualityCapacityWinnerAuthorized:
            Bool
        public let functionalCanaryAuthorized: Bool
        public let broadLanguageClaimAuthorized: Bool
        public let oneBillionScaleAuthorized: Bool
        public let threeBillionScaleAuthorized: Bool
        public let profiles: [ProfileAssessment]
        public let legs: [Leg]

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case outcome
            case familyID = "family_id"
            case comparisonKind = "comparison_kind"
            case comparisonBudgetScopeID =
                "comparison_budget_scope_id"
            case comparisonPrerequisiteIDs =
                "comparison_prerequisite_ids"
            case replicateVariationScopeID =
                "replicate_variation_scope_id"
            case initializationVsScheduleFactorAttributionAuthorized =
                "initialization_vs_schedule_factor_attribution_authorized"
            case claimScope = "claim_scope"
            case selectionReason = "selection_reason"
            case nextAction = "next_action"
            case nextUnmeasuredProfileID =
                "next_unmeasured_profile_id"
            case selectedProfileID = "selected_profile_id"
            case prioritizedProfileForIOPreflightID =
                "prioritized_profile_for_io_preflight_id"
            case prioritizedProfileForAutoregressivePreflightID =
                "prioritized_profile_for_autoregressive_preflight_id"
            case selectedTokenizerMode = "selected_tokenizer_mode"
            case selectedParameterCount = "selected_parameter_count"
            case qualityIndifferenceCrossEntropy =
                "quality_indifference_cross_entropy"
            case legacyQualityConfidenceZDiagnostic =
                "legacy_quality_confidence_z_diagnostic"
            case relativeLossReductionMethodID =
                "relative_loss_reduction_method_id"
            case profileComparisonUncertaintyMethodID =
                "profile_comparison_uncertainty_method_id"
            case minimumIndependentConfirmationReplicateCount =
                "minimum_independent_confirmation_replicate_count"
            case profileComparisonCalibrationID =
                "profile_comparison_calibration_id"
            case profileComparisonGrounded =
                "profile_comparison_grounded"
            case plannedTrainingTokenPresentations =
                "planned_training_token_presentations"
            case plannedTrainingBlockCount =
                "planned_training_block_count"
            case plannedTrainingScheduleID =
                "planned_training_schedule_id"
            case plannedValidRowPresentations =
                "planned_valid_row_presentations"
            case plannedRefusalRowPresentations =
                "planned_refusal_row_presentations"
            case plannedValidSemanticFamilyRowPresentations =
                "planned_valid_semantic_family_row_presentations"
            case plannedRefusalSemanticFamilyRowPresentations =
                "planned_refusal_semantic_family_row_presentations"
            case plannedFullEvaluationNonPaddingTokenCount =
                "planned_full_evaluation_non_padding_token_count"
            case plannedFullEvaluationPromptTokenCount =
                "planned_full_evaluation_prompt_token_count"
            case plannedFullEvaluationMaximumGeneratedTokenCount =
                "planned_full_evaluation_maximum_generated_token_count"
            case plannedShardArtifactBytesUpperBound =
                "planned_shard_artifact_bytes_upper_bound"
            case maximumWallClockSeconds =
                "maximum_wall_clock_seconds"
            case adaptiveDiscoveryLearningRates =
                "adaptive_discovery_learning_rates"
            case learningRateGridRationaleID =
                "learning_rate_grid_rationale_id"
            case learningRateGridAnchorArtifactSHA256 =
                "learning_rate_grid_anchor_artifact_sha256"
            case adaptiveReplicateSeeds =
                "adaptive_replicate_seeds"
            case checkpointHeaderPlanningUpperBoundBytes =
                "checkpoint_header_planning_upper_bound_bytes"
            case profileIOBenchmarks =
                "profile_io_benchmarks"
            case profileAutoregressivePreflights =
                "profile_autoregressive_preflights"
            case failedProfileTrials = "failed_profile_trials"
            case profileScreenMatrixComparable =
                "profile_screen_matrix_comparable"
            case architectureQualityCapacityWinnerAuthorized =
                "architecture_quality_capacity_winner_authorized"
            case functionalCanaryAuthorized =
                "functional_canary_authorized"
            case broadLanguageClaimAuthorized =
                "broad_language_claim_authorized"
            case oneBillionScaleAuthorized =
                "one_billion_scale_authorized"
            case threeBillionScaleAuthorized =
                "three_billion_scale_authorized"
            case profiles
            case legs
        }
    }

    private struct MatrixContract: Equatable {
        let comparisonManifestSHA256: String
        let measuredSequenceLength: Int
        let batchSize: Int
        let gradientAccumulationSteps: Int
        let effectiveBatchSize: Int
        let optimizer: String
        let optimizerImplementation: String
        let weightDecay: Double
        let adamBeta1: Double
        let adamBeta2: Double
        let adamEpsilon: Double
        let decoupledWeightDecay: Bool
        let learningRateSchedule: String
        let gradientClipMode: String
        let precision: String
        let gradientClipNorm: Double
        let lossReduction: String
        let timingWarmupSteps: Int
        let steadyStateMeasuredSteps: Int
        let throughputTokenBasis: String
        let hyperparameterSearchID: String
        let scheduleID: String
        let trainingUniqueRows: Int64
        let trainingValidUniqueRows: Int64
        let trainingRefusalUniqueRows: Int64
        let trainingValidSemanticFamilyUniqueRowCounts:
            [String: Int64]
        let trainingRefusalSemanticFamilyUniqueRowCounts:
            [String: Int64]
        let heldoutUniqueRows: Int64
        let heldoutValidUniqueRows: Int64
        let heldoutRefusalUniqueRows: Int64
        let heldoutValidSemanticFamilyUniqueRowCounts:
            [String: Int64]
        let heldoutRefusalSemanticFamilyUniqueRowCounts:
            [String: Int64]
        let selectionValidationSplitIDs: [String]
        let learningRateDiscoverySeed: Int
        let declaredLearningRateGrid: [Double]
        let declaredReplicateSeeds: [Int]
    }

    private struct SeedContract: Equatable {
        let seed: Int
        let probeTokenManifestSHA256: String
        let trainingScheduleManifestSHA256: String
        let heldoutEvaluationManifestSHA256: String
        let processedTokenCount: Int64
        let nonPaddingTokenCount: Int64
        let targetTokenCount: Int64
        let trainingUniqueRows: Int64
        let trainingSemanticFamilyUniqueRowCounts: [String: Int64]
        let trainingValidUniqueRows: Int64
        let trainingRefusalUniqueRows: Int64
        let trainingValidSemanticFamilyUniqueRowCounts:
            [String: Int64]
        let trainingRefusalSemanticFamilyUniqueRowCounts:
            [String: Int64]
        let heldoutUniqueRows: Int64
        let heldoutValidUniqueRows: Int64
        let heldoutRefusalUniqueRows: Int64
        let heldoutValidSemanticFamilyUniqueRowCounts:
            [String: Int64]
        let heldoutRefusalSemanticFamilyUniqueRowCounts:
            [String: Int64]
        let selectionValidationSplitIDs: [String]
        let heldoutTargetTokenCount: Int64
        let heldoutValidTargetTokenCount: Int64
        let heldoutRefusalTargetTokenCount: Int64
    }

    private struct ProfileAggregate {
        let profile: ModelProfile
        let trials: [ProfileProbeEvidence]
        let representative: ProfileProbeEvidence
        let matrixContract: MatrixContract?
        let seedContracts: [Int: SeedContract]
        let screenGrounded: Bool
        let evidenceGrounded: Bool
        let balancedScheduleGrounded: Bool
        let tokenAccountingGrounded: Bool
        let heldoutEvidenceGrounded: Bool
        let selectedQualityGrounded: Bool
        let optimizerGrounded: Bool
        let timingGrounded: Bool
        let discoveryGridGrounded: Bool
        let selectedRateReplicatesGrounded: Bool
        let discoveryQualityRejected: Bool
        let selectedLearningRate: Double?
        let missingConfirmationSeeds: [Int]
        let qualityRejectedTrials: [QualityRejectedTrial]
        let selectedConfirmationQualityRejected: Bool
        let heldoutCrossEntropyBefore: Double?
        let heldoutCrossEntropyAfter: Double?
        let heldoutCrossEntropyWithinRowStandardError: Double?
        let heldoutCrossEntropyBetweenSeedStandardError: Double?
        let independentConfirmationReplicateCount: Int
        let confirmationHeldoutCrossEntropyBefore: Double?
        let confirmationHeldoutCrossEntropyAfter: Double?
        let confirmationHeldoutCrossEntropyWithinRowStandardError:
            Double?
        let confirmationHeldoutCrossEntropyBetweenSeedStandardError:
            Double?
        let confirmationHeldoutValidCrossEntropyAfter: Double?
        let confirmationHeldoutRefusalCrossEntropyAfter: Double?
        let confirmationHeldoutFamilyCrossEntropyAfter:
            [String: Double]?
        let independentConfirmationComparisonGrounded: Bool
        let heldoutValidCrossEntropyBefore: Double?
        let heldoutValidCrossEntropyAfter: Double?
        let heldoutRefusalCrossEntropyBefore: Double?
        let heldoutRefusalCrossEntropyAfter: Double?
        let heldoutFamilyCrossEntropyAfter: [String: Double]?
        let steadyTokensPerSecond: Double?
        let coldStartSeconds: Double?
        let peakMemoryBytes: Int64?
    }

    private struct ProfileDecision {
        let profile: ModelProfile
        let aggregate: ProfileAggregate?
        let parameterCount: Int64
        let stateBytes: Int64
        let minimumCorpusTokens: Int64
        let minimumRows: Int64
        let minimumCombinations: Int64
        let minimumPlanned: Int64
        let corpusMass: Bool
        let plannedMass: Bool
        let memory: Bool
        let projectedTrainingSeconds: Double?
        let projectedEvaluationSeconds: Double?
        let projectedIOSeconds: Double?
        let projectedTotalSeconds: Double?
        let wallClock: Bool
        let ioBenchmarkGrounded: Bool
        let autoregressivePreflightGrounded: Bool
        let autoregressivePreflight:
            ProfileAutoregressivePreflightEvidence?
        let screenEligible: Bool
        let independentEligible: Bool
        let blockedReason: String?
    }

    private static func isSHA256(_ value: String?) -> Bool {
        guard let value, value.count == 64 else { return false }
        return value.allSatisfy {
            "0123456789abcdef".contains($0)
        }
    }

    private static func probePurposeRank(_ purpose: String?) -> Int {
        guard let purpose else { return 2 }
        if purpose
            == ErgenticsNativeLanguageRunConfiguration.discoveryPurposeID {
            return 0
        }
        if purpose
            == ErgenticsNativeLanguageRunConfiguration.confirmationPurposeID {
            return 1
        }
        return 2
    }

    private static func profileProbePrecedes(
        _ left: ProfileProbeEvidence,
        _ right: ProfileProbeEvidence
    ) -> Bool {
        if left.profileID != right.profileID {
            return left.profileID < right.profileID
        }
        let leftPurposeRank = probePurposeRank(left.probePurposeID)
        let rightPurposeRank = probePurposeRank(right.probePurposeID)
        if leftPurposeRank != rightPurposeRank {
            return leftPurposeRank < rightPurposeRank
        }
        if left.seed != right.seed {
            return left.seed < right.seed
        }
        if left.learningRate != right.learningRate {
            return left.learningRate < right.learningRate
        }
        return (left.replicateID ?? "") < (right.replicateID ?? "")
    }

    private static func qualityRejectedTrialPrecedes(
        _ left: QualityRejectedTrial,
        _ right: QualityRejectedTrial
    ) -> Bool {
        let leftPurposeRank = probePurposeRank(left.probePurposeID)
        let rightPurposeRank = probePurposeRank(right.probePurposeID)
        if leftPurposeRank != rightPurposeRank {
            return leftPurposeRank < rightPurposeRank
        }
        if left.seed != right.seed {
            return left.seed < right.seed
        }
        if left.learningRate != right.learningRate {
            return left.learningRate < right.learningRate
        }
        return left.replicateID < right.replicateID
    }

    private static func ceilDivide(
        _ numerator: Int64,
        by denominator: Int64
    ) -> Int64 {
        (numerator + denominator - 1) / denominator
    }

    public static func minimumDeduplicatedTrainingTokenInstances(
        parameterCount: Int64
    ) -> Int64 {
        ceilDivide(parameterCount, by: 256)
    }

    public static func minimumUniqueTrainingRows(
        parameterCount: Int64
    ) -> Int64 {
        max(2_000, ceilDivide(parameterCount, by: 131_072))
    }

    public static func minimumUniqueSemanticCombinations(
        parameterCount: Int64
    ) -> Int64 {
        max(1_000, ceilDivide(parameterCount, by: 262_144))
    }

    public static func minimumPlannedTrainingTokenPresentations(
        parameterCount: Int64
    ) -> Int64 {
        max(10_000_000, ceilDivide(parameterCount, by: 16))
    }

    private static func plannedTrainingScheduleGrounded(
        _ input: Inputs
    ) -> Bool {
        guard let blocks = input.plannedTrainingBlockCount,
              blocks > 0,
              input.plannedTrainingScheduleID
                == profileProbeTrainingScheduleID,
              let validRows = input.plannedValidRowPresentations,
              let refusalRows =
                input.plannedRefusalRowPresentations,
              let validFamilyRows =
                input
                    .plannedValidSemanticFamilyRowPresentations,
              Set(validFamilyRows.keys) == requiredSemanticFamilyIDs,
              let refusalFamilyRows =
                input
                    .plannedRefusalSemanticFamilyRowPresentations,
              Set(refusalFamilyRows.keys)
                == requiredSemanticFamilyIDs else {
            return false
        }
        let (expectedTokens, tokenOverflow) =
            blocks.multipliedReportingOverflow(
                by: profileProbeBlockTokenPresentations
            )
        let (expectedValidRows, validOverflow) =
            blocks.multipliedReportingOverflow(
                by: profileProbeValidRowCount
            )
        let (expectedRefusalRows, refusalOverflow) =
            blocks.multipliedReportingOverflow(
                by: profileProbeRefusalRowCount
            )
        let (expectedValidFamilyRows, validFamilyOverflow) =
            blocks.multipliedReportingOverflow(
                by: profileProbeValidRowsPerFamily
            )
        let (
            expectedRefusalFamilyRows,
            refusalFamilyOverflow
        ) = blocks.multipliedReportingOverflow(
            by: profileProbeRefusalRowsPerFamily
        )
        guard !tokenOverflow,
              !validOverflow,
              !refusalOverflow,
              !validFamilyOverflow,
              !refusalFamilyOverflow,
              expectedTokens
                == input.plannedTrainingTokenPresentations,
              validRows == expectedValidRows,
              refusalRows == expectedRefusalRows,
              validFamilyRows.values.allSatisfy({
                  $0 == expectedValidFamilyRows
              }),
              refusalFamilyRows.values.allSatisfy({
                  $0 == expectedRefusalFamilyRows
              }) else {
            return false
        }
        return true
    }

    private static func tokenizerGrounded(
        _ tokenizer: TokenizerEvidence,
        corpusManifestSHA256: String
    ) -> Bool {
        guard tokenizer.vocabularySize == tokenizer.mode.vocabularySize,
              isSHA256(tokenizer.manifestSHA256),
              tokenizer.deterministicReplayPassed,
              tokenizer.swiftRoundTripPassed else {
            return false
        }
        switch tokenizer.mode {
        case .nativeUTF8Byte512:
            return tokenizer.tokenizerID
                == PrimeNativeByteTokenizer.tokenizerID
                && tokenizer.manifestSHA256
                    == PrimeNativeByteTokenizer.manifest()
                        .manifestSHA256
                && !tokenizer.externalCompilerUsed
                && tokenizer.sourceCorpusManifestSHA256 == nil
        case .optionalByteLevelBPE16384:
            return tokenizer.tokenizerID
                == "ergentics_native_bpe_16384_v1"
                && tokenizer.externalCompilerUsed
                && tokenizer.externalCompilerProvenanceBound
                && tokenizer.compilerLibrary
                    == "huggingface-tokenizers"
                && !(tokenizer.compilerVersion ?? "").isEmpty
                && tokenizer.compilerLicenseID == "Apache-2.0"
                && tokenizer.sourceCorpusManifestSHA256
                    == corpusManifestSHA256
        }
    }

    private static func implementationGrounded(
        _ implementation: ImplementationEvidence
    ) -> Bool {
        implementation.executionLanguage == "swift"
            && implementation.buildConfiguration
                == ErgenticsNativeLanguageCanary
                    .requiredBuildConfiguration
            && implementation.precision
                == ErgenticsNativeLanguageCanary.requiredPrecision
            && implementation.framework == "mlx-swift"
            && implementation.modelImplementation
                == "MLXLLM.LlamaModel"
            && implementation.mlxSwiftVersion == "0.29.1"
            && implementation.mlxSwiftExamplesVersion == "2.29.1"
            && implementation.deviceType == "gpu"
            && implementation.standardPrimitives
            && !implementation.customMetalKernels
            && implementation.randomInitialization
            && !implementation.importedBaseWeights
    }

    private static func corpusProvenanceGrounded(
        _ corpus: CorpusEvidence
    ) -> Bool {
        isSHA256(corpus.manifestSHA256)
            && corpus.firstPartyOrLicensedRightsBound
            && corpus.exactObjectHashesPresent
            && corpus.holdoutIsolated
            && corpus.deduplicatedTrainingTokenInstances > 0
            && corpus.uniqueTrainingRows > 0
            && corpus.uniqueSemanticCombinations > 0
    }

    private static func basicProbeBindingGrounded(
        _ probe: ProfileProbeEvidence,
        profile: ModelProfile,
        parameterCount: Int64,
        input: Inputs
    ) -> Bool {
        probe.profileID == profile.profileID
            && probe.parameterCount == parameterCount
            && probe.trainableParameterCount == parameterCount
            && probe.tokenizerManifestSHA256
                == input.tokenizer.manifestSHA256
            && probe.corpusManifestSHA256
                == input.corpus.manifestSHA256
            && probe.vocabularySize == input.tokenizer.mode.vocabularySize
            && probe.profileMaximumSequenceLength
                == profile.maximumSequenceLength
            && probe.measuredSequenceLength >= 64
            && probe.measuredSequenceLength
                <= profile.maximumSequenceLength
            && probe.batchSize > 0
            && isSHA256(probe.probeTokenManifestSHA256)
            && probe.completedTrainingSteps >= 10
            && probe.optimizer == "AdamW"
            && probe.learningRate.isFinite
            && probe.learningRate > 0
            && probe.weightDecay.isFinite
            && probe.weightDecay >= 0
            && ["float32", "bfloat16"].contains(probe.precision)
            && probe.seed >= 0
            && probe.fullWeightTraining
            && probe.initialLoss.isFinite
            && probe.initialLoss > 0
            && probe.finalLoss.isFinite
            && probe.finalLoss >= 0
            && probe.firstGradientNorm.isFinite
            && probe.firstGradientNorm > 0
            && probe.tokensPerSecond.isFinite
            && probe.tokensPerSecond > 0
            && probe.peakMemoryBytes > 0
            && probe.finiteLogitsPassed
            && probe.causalMaskPassed
            && probe.checkpointReloadExact != false
            && probe.repeatedInferenceExact
            && isSHA256(probe.initializationFingerprintSHA256)
    }

    private static func balancedScheduleGrounded(
        _ probe: ProfileProbeEvidence
    ) -> Bool {
        guard let refusalWitness =
                ErgenticsNativeLanguageCanary
                    .deterministicRefusalReasonSchedule(
                        rows:
                            ErgenticsPrimeNativeTextCorpus.rows(
                                for: .refusalTrain
                            ),
                        seed: probe.seed,
                        blockCount: 1,
                        namespace:
                            "balanced_refusal_reason_stratified_train_v2",
                        corpusManifestSHA256:
                            probe.corpusManifestSHA256
                    )
        else {
            return false
        }
        let expectedRefusalReasonCounts =
            refusalWitness.reasonRowCounts.mapValues(Int64.init)
        guard let manifest = probe.trainingScheduleManifestSHA256,
              isSHA256(manifest),
              let uniqueRows = probe.trainingUniqueRows,
              uniqueRows
                == profileProbeValidRowCount
                    + profileProbeRefusalRowCount,
              let validRows = probe.trainingValidUniqueRows,
              validRows == profileProbeValidRowCount,
              let refusalRows = probe.trainingRefusalUniqueRows,
              refusalRows == profileProbeRefusalRowCount,
              validRows + refusalRows == uniqueRows,
              let counts =
                probe.trainingSemanticFamilyUniqueRowCounts,
              Set(counts.keys) == requiredSemanticFamilyIDs,
              counts.values.allSatisfy({
                  $0 == profileProbeValidRowsPerFamily
                    + profileProbeRefusalRowsPerFamily
              }),
              counts.values.reduce(0, +) == uniqueRows,
              let validFamilyCounts =
                probe
                    .trainingValidSemanticFamilyUniqueRowCounts,
              Set(validFamilyCounts.keys)
                == requiredSemanticFamilyIDs,
              validFamilyCounts.values.allSatisfy({
                  $0 == profileProbeValidRowsPerFamily
              }),
              validFamilyCounts.values.reduce(0, +) == validRows,
              let refusalFamilyCounts =
                probe
                    .trainingRefusalSemanticFamilyUniqueRowCounts,
              Set(refusalFamilyCounts.keys)
                == requiredSemanticFamilyIDs,
              refusalFamilyCounts.values.allSatisfy({
                  $0 == profileProbeRefusalRowsPerFamily
              }),
              refusalFamilyCounts.values.reduce(0, +)
                == refusalRows,
              probe.trainingRefusalReasonUniqueRowCounts
                == expectedRefusalReasonCounts,
              probe.trainingRefusalReasonScheduleSHA256
                == refusalWitness.orderedReasonScheduleSHA256,
              requiredSemanticFamilyIDs.allSatisfy({
                  guard let total = counts[$0],
                        let valid = validFamilyCounts[$0],
                        let refusal = refusalFamilyCounts[$0] else {
                      return false
                  }
                  return total == valid + refusal
              }) else {
            return false
        }
        guard let effectiveBatchSize = probe.effectiveBatchSize else {
            return false
        }
        let rowPresentations =
            Int64(probe.completedTrainingSteps)
                * Int64(effectiveBatchSize)
        return uniqueRows <= rowPresentations
    }

    private static func tokenAccountingGrounded(
        _ probe: ProfileProbeEvidence
    ) -> Bool {
        guard let accumulation = probe.gradientAccumulationSteps,
              let effectiveBatch = probe.effectiveBatchSize,
              accumulation > 0,
              effectiveBatch == probe.batchSize * accumulation else {
            return false
        }
        let (stepBatch, firstOverflow) =
            Int64(probe.completedTrainingSteps)
                .multipliedReportingOverflow(
                    by: Int64(effectiveBatch)
                )
        let (expectedProcessed, secondOverflow) =
            stepBatch.multipliedReportingOverflow(
                by: Int64(probe.measuredSequenceLength)
            )
        guard !firstOverflow, !secondOverflow,
              let processed = probe.processedTokenCount,
              let nonPadding = probe.nonPaddingTokenCount,
              let targets = probe.targetTokenCount,
              processed == expectedProcessed,
              processed == probe.probeTokenPresentations,
              processed == profileProbeBlockTokenPresentations,
              processed >= minimumProbeTokenPresentations,
              nonPadding > 0, nonPadding <= processed,
              targets > 0, targets < nonPadding else {
            return false
        }
        return true
    }

    private static func heldoutEvidenceGrounded(
        _ probe: ProfileProbeEvidence
    ) -> Bool {
        guard let refusalWitness =
                ErgenticsNativeLanguageCanary
                    .deterministicRefusalReasonSchedule(
                        rows:
                            ErgenticsPrimeNativeTextCorpus.rows(
                                for: .refusalValidation
                            ),
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
        let expectedRefusalReasonCounts =
            refusalWitness.reasonRowCounts.mapValues(Int64.init)
        guard let trainingManifest =
                probe.trainingScheduleManifestSHA256,
              let heldoutManifest =
                probe.heldoutEvaluationManifestSHA256,
              isSHA256(heldoutManifest),
              heldoutManifest != trainingManifest,
              let intersection =
                probe.trainingHeldoutRowHashIntersectionCount,
              intersection == 0,
              let heldoutRows = probe.heldoutUniqueRows,
              heldoutRows
                == profileProbeValidRowCount
                    + profileProbeRefusalRowCount,
              let validRows = probe.heldoutValidUniqueRows,
              validRows == profileProbeValidRowCount,
              let refusalRows = probe.heldoutRefusalUniqueRows,
              refusalRows == profileProbeRefusalRowCount,
              validRows + refusalRows == heldoutRows,
              let validFamilyRows =
                probe.heldoutValidSemanticFamilyUniqueRowCounts,
              Set(validFamilyRows.keys) == requiredSemanticFamilyIDs,
              validFamilyRows.values.allSatisfy({
                  $0 == profileProbeValidRowsPerFamily
              }),
              validFamilyRows.values.reduce(0, +) == validRows,
              let refusalFamilyRows =
                probe.heldoutRefusalSemanticFamilyUniqueRowCounts,
              Set(refusalFamilyRows.keys)
                == requiredSemanticFamilyIDs,
              refusalFamilyRows.values.allSatisfy({
                  $0 == profileProbeRefusalRowsPerFamily
              }),
              refusalFamilyRows.values.reduce(0, +)
                == refusalRows,
              probe.heldoutRefusalReasonUniqueRowCounts
                == expectedRefusalReasonCounts,
              probe.heldoutRefusalReasonScheduleSHA256
                == refusalWitness.orderedReasonScheduleSHA256,
              let selectionSplits =
                probe.selectionValidationSplitIDs,
              selectionSplits.count == 2,
              Set(selectionSplits)
                == Set([
                    ErgenticsPrimeNativeTextCorpus.Split.validation
                        .rawValue,
                    ErgenticsPrimeNativeTextCorpus.Split
                        .refusalValidation.rawValue,
                ]),
              let heldoutTargets = probe.heldoutTargetTokenCount,
              heldoutTargets >= heldoutRows,
              let validTargets =
                probe.heldoutValidTargetTokenCount,
              validTargets > 0,
              let refusalTargets =
                probe.heldoutRefusalTargetTokenCount,
              refusalTargets > 0,
              validTargets + refusalTargets == heldoutTargets,
              let before = probe.heldoutCrossEntropyBefore,
              let after = probe.heldoutCrossEntropyAfter,
              let validBefore =
                probe.heldoutValidCrossEntropyBefore,
              let validAfter =
                probe.heldoutValidCrossEntropyAfter,
              let refusalBefore =
                probe.heldoutRefusalCrossEntropyBefore,
              let refusalAfter =
                probe.heldoutRefusalCrossEntropyAfter,
              let standardError =
                probe.heldoutCrossEntropyStandardError,
              before.isFinite, before > 0,
              after.isFinite, after >= 0,
              validBefore.isFinite, validBefore > 0,
              validAfter.isFinite, validAfter >= 0,
              refusalBefore.isFinite, refusalBefore > 0,
              refusalAfter.isFinite, refusalAfter >= 0,
              standardError.isFinite, standardError >= 0,
              let familyBefore =
                probe.heldoutFamilyCrossEntropyBefore,
              let familyAfter =
                probe.heldoutFamilyCrossEntropyAfter,
              Set(familyBefore.keys) == requiredSemanticFamilyIDs,
              Set(familyAfter.keys) == requiredSemanticFamilyIDs else {
            return false
        }
        let weightedBefore =
            (
                validBefore * Double(validTargets)
                    + refusalBefore * Double(refusalTargets)
            ) / Double(heldoutTargets)
        let weightedAfter =
            (
                validAfter * Double(validTargets)
                    + refusalAfter * Double(refusalTargets)
            ) / Double(heldoutTargets)
        let weightingTolerance =
            max(1e-9, max(before, after) * 1e-9)
        guard abs(weightedBefore - before) <= weightingTolerance,
              abs(weightedAfter - after) <= weightingTolerance,
              abs(probe.initialLoss - before) <= weightingTolerance,
              abs(probe.finalLoss - after) <= weightingTolerance else {
            return false
        }
        return requiredSemanticFamilyIDs.allSatisfy { family in
            guard let familyInitial = familyBefore[family],
                  let familyFinal = familyAfter[family] else {
                return false
            }
            return familyInitial.isFinite
                && familyInitial > 0
                && familyFinal.isFinite
                && familyFinal >= 0
        }
    }

    private static func heldoutQualityFailures(
        _ probe: ProfileProbeEvidence
    ) -> [String]? {
        guard heldoutEvidenceGrounded(probe),
              let validBefore =
                probe.heldoutValidCrossEntropyBefore,
              let validAfter =
                probe.heldoutValidCrossEntropyAfter,
              let refusalBefore =
                probe.heldoutRefusalCrossEntropyBefore,
              let refusalAfter =
                probe.heldoutRefusalCrossEntropyAfter,
              let familyBefore =
                probe.heldoutFamilyCrossEntropyBefore,
              let familyAfter =
                probe.heldoutFamilyCrossEntropyAfter else {
            return nil
        }
        var failures = [String]()
        if probe.relativeLossReduction
            < minimumRelativeLossReduction {
            failures.append(
                "training_relative_loss_reduction_below_minimum"
            )
        }
        if probe.heldoutRelativeLossReduction
            < minimumRelativeLossReduction {
            failures.append(
                "heldout_relative_loss_reduction_below_minimum"
            )
        }
        if (validBefore - validAfter) / validBefore
            < minimumRelativeLossReduction {
            failures.append(
                "valid_relative_loss_reduction_below_minimum"
            )
        }
        if (refusalBefore - refusalAfter) / refusalBefore
            < minimumRelativeLossReduction {
            failures.append(
                "refusal_relative_loss_reduction_below_minimum"
            )
        }
        for family in requiredSemanticFamilyIDs.sorted() {
            if familyAfter[family]! >= familyBefore[family]! {
                failures.append(
                    "semantic_family_not_improved:\(family)"
                )
            }
        }
        return failures
    }

    private static func heldoutQualityGrounded(
        _ probe: ProfileProbeEvidence
    ) -> Bool {
        heldoutQualityFailures(probe)?.isEmpty == true
    }

    private static func qualityRejectedTrial(
        _ probe: ProfileProbeEvidence
    ) -> QualityRejectedTrial? {
        guard let failures = heldoutQualityFailures(probe),
              !failures.isEmpty,
              let purpose = probe.probePurposeID,
              let replicateID = probe.replicateID,
              !replicateID.isEmpty,
              let before = probe.heldoutCrossEntropyBefore,
              let after = probe.heldoutCrossEntropyAfter,
              let validBefore =
                probe.heldoutValidCrossEntropyBefore,
              let validAfter =
                probe.heldoutValidCrossEntropyAfter,
              let refusalBefore =
                probe.heldoutRefusalCrossEntropyBefore,
              let refusalAfter =
                probe.heldoutRefusalCrossEntropyAfter,
              let familyBefore =
                probe.heldoutFamilyCrossEntropyBefore,
              let familyAfter =
                probe.heldoutFamilyCrossEntropyAfter else {
            return nil
        }
        return QualityRejectedTrial(
            probePurposeID: purpose,
            replicateID: replicateID,
            seed: probe.seed,
            learningRate: probe.learningRate,
            minimumRelativeLossReduction:
                minimumRelativeLossReduction,
            semanticFamilyQualityRuleID:
                semanticFamilyQualityRuleID,
            heldoutCrossEntropyBefore: before,
            heldoutCrossEntropyAfter: after,
            heldoutValidCrossEntropyBefore: validBefore,
            heldoutValidCrossEntropyAfter: validAfter,
            heldoutRefusalCrossEntropyBefore: refusalBefore,
            heldoutRefusalCrossEntropyAfter: refusalAfter,
            heldoutFamilyCrossEntropyBefore: familyBefore,
            heldoutFamilyCrossEntropyAfter: familyAfter,
            failedQualityPredicates: failures
        )
    }

    private static func optimizerGrounded(
        _ probe: ProfileProbeEvidence
    ) -> Bool {
        guard let clip = probe.gradientClipNorm else {
            return false
        }
        return probe.optimizer == "AdamW"
            && probe.optimizerImplementation
                == "MLXOptimizers.AdamW"
            && probe.adamBeta1 == 0.9
            && probe.adamBeta2 == 0.999
            && probe.adamEpsilon == 1e-8
            && probe.decoupledWeightDecay == true
            && probe.learningRateSchedule
                == "linear_warmup4_then_constant_v1"
            && probe.gradientClipMode
                == "global_l2_norm_pre_optimizer_step"
            && probe.lossReduction
                == "mean_target_token_cross_entropy"
            && clip.isFinite
            && clip > 0
    }

    private static func timingGrounded(
        _ probe: ProfileProbeEvidence
    ) -> Bool {
        guard let cold = probe.coldStartSeconds,
              let warmupSteps = probe.timingWarmupSteps,
              let warmupSeconds = probe.timingWarmupSeconds,
              let measurement = probe.steadyStateMeasurementSeconds,
              let steps = probe.steadyStateMeasuredSteps,
              let measuredNonPadding =
                probe.steadyStateNonPaddingTokenCount,
              let steady = probe.steadyStateTokensPerSecond,
              let heldoutTokens =
                probe.heldoutEvaluationNonPaddingTokenCount,
              let heldoutSeconds =
                probe.heldoutEvaluationElapsedSeconds,
              cold.isFinite, cold > 0,
              warmupSteps >= 1,
              warmupSeconds.isFinite, warmupSeconds > 0,
              measurement.isFinite, measurement > 0,
              steps >= 2,
              measuredNonPadding > 0,
              heldoutTokens > 0,
              heldoutSeconds.isFinite, heldoutSeconds > 0,
              steady.isFinite, steady > 0 else {
            return false
        }
        let recomputed =
            Double(measuredNonPadding) / measurement
        let tolerance = max(1e-9, steady * 1e-9)
        return abs(probe.tokensPerSecond - steady) <= tolerance
            && abs(recomputed - steady) <= tolerance
            && probe.throughputTokenBasis == "non_padding_tokens"
            && warmupSteps + steps <= probe.completedTrainingSteps
    }

    private static func matrixContract(
        _ probe: ProfileProbeEvidence
    ) -> MatrixContract? {
        guard let comparisonManifest =
                probe.comparisonManifestSHA256,
              isSHA256(comparisonManifest),
              let accumulation =
                probe.gradientAccumulationSteps,
              let effectiveBatch = probe.effectiveBatchSize,
              let implementation = probe.optimizerImplementation,
              let beta1 = probe.adamBeta1,
              let beta2 = probe.adamBeta2,
              let epsilon = probe.adamEpsilon,
              let decoupled = probe.decoupledWeightDecay,
              let schedule = probe.learningRateSchedule,
              let clipMode = probe.gradientClipMode,
              let clip = probe.gradientClipNorm,
              let reduction = probe.lossReduction,
              let warmupSteps = probe.timingWarmupSteps,
              let measuredSteps = probe.steadyStateMeasuredSteps,
              let throughputBasis = probe.throughputTokenBasis,
              let searchID = probe.hyperparameterSearchID,
              searchID == adaptiveSearchID,
              let scheduleID = probe.scheduleID,
              scheduleID == profileProbeTrainingScheduleID,
              let trainingRows = probe.trainingUniqueRows,
              let trainingValidRows =
                probe.trainingValidUniqueRows,
              let trainingRefusalRows =
                probe.trainingRefusalUniqueRows,
              let trainingValidFamilyRows =
                probe
                    .trainingValidSemanticFamilyUniqueRowCounts,
              let trainingRefusalFamilyRows =
                probe
                    .trainingRefusalSemanticFamilyUniqueRowCounts,
              let heldoutRows = probe.heldoutUniqueRows,
              let heldoutValidRows =
                probe.heldoutValidUniqueRows,
              let heldoutRefusalRows =
                probe.heldoutRefusalUniqueRows,
              let heldoutValidFamilyRows =
                probe
                    .heldoutValidSemanticFamilyUniqueRowCounts,
              let heldoutRefusalFamilyRows =
                probe
                    .heldoutRefusalSemanticFamilyUniqueRowCounts,
              let selectionValidationSplitIDs =
                probe.selectionValidationSplitIDs,
              let learningRateDiscoverySeed =
                probe.learningRateDiscoverySeed,
              let learningRates = probe.declaredLearningRateGrid,
              let seeds = probe.declaredReplicateSeeds else {
            return nil
        }
        return MatrixContract(
            comparisonManifestSHA256: comparisonManifest,
            measuredSequenceLength: probe.measuredSequenceLength,
            batchSize: probe.batchSize,
            gradientAccumulationSteps: accumulation,
            effectiveBatchSize: effectiveBatch,
            optimizer: probe.optimizer,
            optimizerImplementation: implementation,
            weightDecay: probe.weightDecay,
            adamBeta1: beta1,
            adamBeta2: beta2,
            adamEpsilon: epsilon,
            decoupledWeightDecay: decoupled,
            learningRateSchedule: schedule,
            gradientClipMode: clipMode,
            precision: probe.precision,
            gradientClipNorm: clip,
            lossReduction: reduction,
            timingWarmupSteps: warmupSteps,
            steadyStateMeasuredSteps: measuredSteps,
            throughputTokenBasis: throughputBasis,
            hyperparameterSearchID: searchID,
            scheduleID: scheduleID,
            trainingUniqueRows: trainingRows,
            trainingValidUniqueRows: trainingValidRows,
            trainingRefusalUniqueRows: trainingRefusalRows,
            trainingValidSemanticFamilyUniqueRowCounts:
                trainingValidFamilyRows,
            trainingRefusalSemanticFamilyUniqueRowCounts:
                trainingRefusalFamilyRows,
            heldoutUniqueRows: heldoutRows,
            heldoutValidUniqueRows: heldoutValidRows,
            heldoutRefusalUniqueRows: heldoutRefusalRows,
            heldoutValidSemanticFamilyUniqueRowCounts:
                heldoutValidFamilyRows,
            heldoutRefusalSemanticFamilyUniqueRowCounts:
                heldoutRefusalFamilyRows,
            selectionValidationSplitIDs:
                selectionValidationSplitIDs.sorted(),
            learningRateDiscoverySeed:
                learningRateDiscoverySeed,
            declaredLearningRateGrid: learningRates,
            declaredReplicateSeeds: seeds
        )
    }

    private static func seedContract(
        _ probe: ProfileProbeEvidence
    ) -> SeedContract? {
        guard let trainingManifest =
                probe.trainingScheduleManifestSHA256,
              let heldoutManifest =
                probe.heldoutEvaluationManifestSHA256,
              let processed = probe.processedTokenCount,
              let nonPadding = probe.nonPaddingTokenCount,
              let targets = probe.targetTokenCount,
              let uniqueRows = probe.trainingUniqueRows,
              let familyRows =
                probe.trainingSemanticFamilyUniqueRowCounts,
              let trainingValidRows =
                probe.trainingValidUniqueRows,
              let trainingRefusalRows =
                probe.trainingRefusalUniqueRows,
              let trainingValidFamilyRows =
                probe
                    .trainingValidSemanticFamilyUniqueRowCounts,
              let trainingRefusalFamilyRows =
                probe
                    .trainingRefusalSemanticFamilyUniqueRowCounts,
              let heldoutRows = probe.heldoutUniqueRows,
              let heldoutValidRows =
                probe.heldoutValidUniqueRows,
              let heldoutRefusalRows =
                probe.heldoutRefusalUniqueRows,
              let heldoutValidFamilyRows =
                probe
                    .heldoutValidSemanticFamilyUniqueRowCounts,
              let heldoutRefusalFamilyRows =
                probe
                    .heldoutRefusalSemanticFamilyUniqueRowCounts,
              let selectionValidationSplitIDs =
                probe.selectionValidationSplitIDs,
              let heldoutTargets = probe.heldoutTargetTokenCount,
              let heldoutValidTargets =
                probe.heldoutValidTargetTokenCount,
              let heldoutRefusalTargets =
                probe.heldoutRefusalTargetTokenCount else {
            return nil
        }
        return SeedContract(
            seed: probe.seed,
            probeTokenManifestSHA256:
                probe.probeTokenManifestSHA256,
            trainingScheduleManifestSHA256: trainingManifest,
            heldoutEvaluationManifestSHA256: heldoutManifest,
            processedTokenCount: processed,
            nonPaddingTokenCount: nonPadding,
            targetTokenCount: targets,
            trainingUniqueRows: uniqueRows,
            trainingSemanticFamilyUniqueRowCounts: familyRows,
            trainingValidUniqueRows: trainingValidRows,
            trainingRefusalUniqueRows: trainingRefusalRows,
            trainingValidSemanticFamilyUniqueRowCounts:
                trainingValidFamilyRows,
            trainingRefusalSemanticFamilyUniqueRowCounts:
                trainingRefusalFamilyRows,
            heldoutUniqueRows: heldoutRows,
            heldoutValidUniqueRows: heldoutValidRows,
            heldoutRefusalUniqueRows: heldoutRefusalRows,
            heldoutValidSemanticFamilyUniqueRowCounts:
                heldoutValidFamilyRows,
            heldoutRefusalSemanticFamilyUniqueRowCounts:
                heldoutRefusalFamilyRows,
            selectionValidationSplitIDs:
                selectionValidationSplitIDs.sorted(),
            heldoutTargetTokenCount: heldoutTargets,
            heldoutValidTargetTokenCount: heldoutValidTargets,
            heldoutRefusalTargetTokenCount: heldoutRefusalTargets
        )
    }

    private static func deterministicReplicateIDGrounded(
        _ trial: ProfileProbeEvidence
    ) -> Bool {
        guard let probePurposeID = trial.probePurposeID,
              let replicateID = trial.replicateID else {
            return false
        }
        return replicateID == adaptiveReplicateID(
            profileID: trial.profileID,
            probePurposeID: probePurposeID,
            learningRate: trial.learningRate,
            seed: trial.seed
        )
    }

    private static func discoverySelectedLearningRate(
        _ trials: [ProfileProbeEvidence]
    ) -> Double? {
        let discoveryTrials = trials.filter {
            $0.seed == discoverySeed
        }
        guard discoveryTrials.count == discoveryLearningRates.count,
              Set(discoveryTrials.map(\.learningRate))
                == Set(discoveryLearningRates),
              discoveryTrials.allSatisfy({
                  $0.probePurposeID == "balanced_lr_discovery_v1"
              }) else {
            return nil
        }
        let qualityAccepted = discoveryTrials.filter(
            heldoutQualityGrounded
        )
        return qualityAccepted.min(by: {
            let left =
                $0.heldoutCrossEntropyAfter ?? .infinity
            let right =
                $1.heldoutCrossEntropyAfter ?? .infinity
            if left == right {
                return $0.learningRate < $1.learningRate
            }
            return left < right
        })?.learningRate
    }

    private static func groundedDiscoveryTrials(
        profile: ModelProfile,
        parameterCount: Int64,
        trials: [ProfileProbeEvidence],
        input: Inputs
    ) -> [ProfileProbeEvidence]? {
        let discoveryTrials = trials.filter {
            $0.seed == discoverySeed
        }
        let replicateIDs =
            discoveryTrials.compactMap(\.replicateID)
        guard discoveryTrials.count
                == discoveryLearningRates.count,
              Set(discoveryTrials.map(\.learningRate))
                == Set(discoveryLearningRates),
              discoveryTrials.allSatisfy({
                  $0.probePurposeID
                    == ErgenticsNativeLanguageRunConfiguration
                        .discoveryPurposeID
                      && deterministicReplicateIDGrounded($0)
              }),
              replicateIDs.count == discoveryTrials.count,
              Set(replicateIDs).count == replicateIDs.count,
              discoveryTrials.allSatisfy({
                  basicProbeBindingGrounded(
                      $0,
                      profile: profile,
                      parameterCount: parameterCount,
                      input: input
                  )
                      && balancedScheduleGrounded($0)
                      && tokenAccountingGrounded($0)
                      && heldoutEvidenceGrounded($0)
                      && optimizerGrounded($0)
                      && timingGrounded($0)
              }),
              let firstMatrixContract =
                discoveryTrials.first.flatMap(matrixContract),
              discoveryTrials.allSatisfy({
                  matrixContract($0) == firstMatrixContract
              }),
              let firstSeedContract =
                discoveryTrials.first.flatMap(seedContract),
              discoveryTrials.allSatisfy({
                  seedContract($0) == firstSeedContract
              }) else {
            return nil
        }
        return discoveryTrials.sorted(by: profileProbePrecedes)
    }

    private static func groundedDiscoverySelectedLearningRate(
        profile: ModelProfile,
        parameterCount: Int64,
        trials: [ProfileProbeEvidence],
        input: Inputs
    ) -> Double? {
        guard let discoveryTrials = groundedDiscoveryTrials(
                  profile: profile,
                  parameterCount: parameterCount,
                  trials: trials,
                  input: input
              ),
              let selected =
                discoverySelectedLearningRate(discoveryTrials),
              let selectedTrial = discoveryTrials.first(where: {
                  $0.learningRate == selected
              }),
              heldoutQualityGrounded(selectedTrial) else {
            return nil
        }
        return selected
    }

    private static func adaptiveSelectedLearningRate(
        _ trials: [ProfileProbeEvidence]
    ) -> Double? {
        guard let first = trials.first,
              let rates = first.declaredLearningRateGrid,
              let seeds = first.declaredReplicateSeeds,
              let declaredDiscoverySeed =
                first.learningRateDiscoverySeed,
              rates == discoveryLearningRates,
              seeds == adaptiveSeeds,
              declaredDiscoverySeed == discoverySeed,
              trials.count
                == rates.count + confirmationSeeds.count else {
            return nil
        }
        var observed: Set<String> = []
        var replicateIDs: Set<String> = []
        for trial in trials {
            guard trial.declaredLearningRateGrid == rates,
                  trial.declaredReplicateSeeds == seeds,
                  trial.learningRateDiscoverySeed
                    == discoverySeed,
                  trial.hyperparameterSearchID == adaptiveSearchID,
                  rates.contains(trial.learningRate),
                  seeds.contains(trial.seed),
                  let replicateID = trial.replicateID,
                  !replicateID.isEmpty,
                  deterministicReplicateIDGrounded(trial),
                  replicateIDs.insert(replicateID).inserted else {
                return nil
            }
            observed.insert("\(trial.learningRate.bitPattern):\(trial.seed)")
        }
        guard let selected =
                discoverySelectedLearningRate(trials) else {
            return nil
        }
        let confirmationTrials = trials.filter {
            $0.seed != discoverySeed
        }
        guard confirmationTrials.allSatisfy({
            $0.learningRate == selected
                && $0.probePurposeID
                    == "balanced_lr_confirmation_v1"
        }) else {
            return nil
        }
        var expected = Set(
            rates.map {
                "\($0.bitPattern):\(discoverySeed)"
            }
        )
        for seed in confirmationSeeds {
            expected.insert("\(selected.bitPattern):\(seed)")
        }
        return observed == expected ? selected : nil
    }

    private static func mean(_ values: [Double]) -> Double? {
        guard !values.isEmpty,
              values.allSatisfy(\.isFinite) else {
            return nil
        }
        return values.reduce(0, +) / Double(values.count)
    }

    private static func standardErrorOfReplicateMeans(
        _ values: [Double]
    ) -> Double? {
        guard values.count >= 2,
              values.allSatisfy(\.isFinite),
              let average = mean(values) else {
            return nil
        }
        let squaredDeviationSum = values.reduce(0) {
            $0 + ($1 - average) * ($1 - average)
        }
        let sampleVariance =
            squaredDeviationSum / Double(values.count - 1)
        guard sampleVariance.isFinite, sampleVariance >= 0 else {
            return nil
        }
        return sqrt(sampleVariance / Double(values.count))
    }

    private static func aggregate(
        profile: ModelProfile,
        parameterCount: Int64,
        trials: [ProfileProbeEvidence],
        input: Inputs
    ) -> ProfileAggregate? {
        let orderedTrials = trials.sorted(by: profileProbePrecedes)
        guard let fallbackRepresentative = orderedTrials.first else {
            return nil
        }
        let schedules = orderedTrials.map(balancedScheduleGrounded)
        let accounting = orderedTrials.map(tokenAccountingGrounded)
        let heldoutEvidence = orderedTrials.map(
            heldoutEvidenceGrounded
        )
        let optimizers = orderedTrials.map(optimizerGrounded)
        let timings = orderedTrials.map(timingGrounded)
        let base = orderedTrials.map {
            basicProbeBindingGrounded(
                $0,
                profile: profile,
                parameterCount: parameterCount,
                input: input
            )
        }
        let contracts = orderedTrials.map(matrixContract)
        let firstContract = contracts.first ?? nil
        let commonContract =
            firstContract != nil
                && contracts.allSatisfy { $0 == firstContract }
        var seedContracts: [Int: SeedContract] = [:]
        var seedContractsGrounded = true
        for (seed, seedTrials) in Dictionary(
            grouping: orderedTrials,
            by: \.seed
        ) {
            let contracts = seedTrials.map(seedContract)
            let first = contracts.first ?? nil
            guard let first,
                  contracts.allSatisfy({ $0 == first }) else {
                seedContractsGrounded = false
                continue
            }
            seedContracts[seed] = first
        }
        let discoveryTrials = groundedDiscoveryTrials(
            profile: profile,
            parameterCount: parameterCount,
            trials: orderedTrials,
            input: input
        )
        let discoveryGridGrounded = discoveryTrials != nil
        let selectedRate = discoveryTrials.flatMap(
            discoverySelectedLearningRate
        )
        let confirmationTrials = orderedTrials.filter {
            $0.seed != discoverySeed
        }
        let confirmationPrefixGrounded: Bool = {
            guard discoveryGridGrounded else {
                return false
            }
            guard let selectedRate else {
                return confirmationTrials.isEmpty
            }
            return confirmationTrials.count
                <= confirmationSeeds.count
                && Set(confirmationTrials.map(\.seed)).count
                    == confirmationTrials.count
                && confirmationTrials.allSatisfy {
                    $0.probePurposeID
                        == ErgenticsNativeLanguageRunConfiguration
                            .confirmationPurposeID
                        && confirmationSeeds.contains($0.seed)
                        && $0.learningRate == selectedRate
                }
        }()
        let structuralEvidence =
            base.allSatisfy { $0 }
            && schedules.allSatisfy { $0 }
            && accounting.allSatisfy { $0 }
            && heldoutEvidence.allSatisfy { $0 }
            && optimizers.allSatisfy { $0 }
            && timings.allSatisfy { $0 }
            && commonContract
            && seedContractsGrounded
            && discoveryGridGrounded
            && confirmationPrefixGrounded
        let selectedRateReplicatesGrounded =
            structuralEvidence
            && selectedRate != nil
            && adaptiveSelectedLearningRate(orderedTrials)
                == selectedRate
        let selectedTrials = selectedRate.map { selected in
            orderedTrials.filter { $0.learningRate == selected }
        } ?? []
        let selectedConfirmationTrials = selectedTrials.filter {
            $0.probePurposeID
                == ErgenticsNativeLanguageRunConfiguration
                    .confirmationPurposeID
                && confirmationSeeds.contains($0.seed)
        }
        let selectedQuality =
            !selectedTrials.isEmpty
            && selectedTrials.allSatisfy(heldoutQualityGrounded)
        let discoveryQualityRejected =
            structuralEvidence && selectedRate == nil
        let selectedConfirmationQualityRejected =
            selectedRateReplicatesGrounded
            && selectedTrials.contains {
                $0.probePurposeID
                    == ErgenticsNativeLanguageRunConfiguration
                        .confirmationPurposeID
                    && !heldoutQualityGrounded($0)
            }
        let qualityRejectedTrials: [QualityRejectedTrial] = {
            guard commonContract, seedContractsGrounded else {
                return []
            }
            return orderedTrials.enumerated().compactMap {
                index, trial in
                guard base[index],
                      schedules[index],
                      accounting[index],
                      heldoutEvidence[index],
                      optimizers[index],
                      timings[index] else {
                    return nil
                }
                return qualityRejectedTrial(trial)
            }.sorted(by: qualityRejectedTrialPrecedes)
        }()
        let missingConfirmations = selectedRate == nil
            ? confirmationSeeds
            : confirmationSeeds.filter { seed in
                !selectedTrials.contains { $0.seed == seed }
            }

        let before = mean(
            selectedTrials.compactMap(\.heldoutCrossEntropyBefore)
        )
        let after = mean(
            selectedTrials.compactMap(\.heldoutCrossEntropyAfter)
        )
        let validBefore = mean(
            selectedTrials.compactMap(
                \.heldoutValidCrossEntropyBefore
            )
        )
        let validAfter = mean(
            selectedTrials.compactMap(
                \.heldoutValidCrossEntropyAfter
            )
        )
        let refusalBefore = mean(
            selectedTrials.compactMap(
                \.heldoutRefusalCrossEntropyBefore
            )
        )
        let refusalAfter = mean(
            selectedTrials.compactMap(
                \.heldoutRefusalCrossEntropyAfter
            )
        )
        let withinRowStandardError: Double? = {
            let values = selectedTrials.compactMap(
                \.heldoutCrossEntropyStandardError
            )
            guard values.count == selectedTrials.count,
                  !values.isEmpty else {
                return nil
            }
            return sqrt(values.map { $0 * $0 }.reduce(0, +))
                / Double(values.count)
        }()
        let betweenSeedStandardError =
            standardErrorOfReplicateMeans(
                selectedTrials.compactMap(
                    \.heldoutCrossEntropyAfter
                )
            )
        let familyAfter: [String: Double]? = {
            guard !selectedTrials.isEmpty else { return nil }
            var result: [String: Double] = [:]
            for family in requiredSemanticFamilyIDs {
                let values = selectedTrials.compactMap {
                    $0.heldoutFamilyCrossEntropyAfter?[family]
                }
                guard values.count == selectedTrials.count,
                      let familyMean = mean(values) else {
                    return nil
                }
                result[family] = familyMean
            }
            return result
        }()
        let confirmationBefore = mean(
            selectedConfirmationTrials.compactMap(
                \.heldoutCrossEntropyBefore
            )
        )
        let confirmationAfter = mean(
            selectedConfirmationTrials.compactMap(
                \.heldoutCrossEntropyAfter
            )
        )
        let confirmationWithinRowStandardError: Double? = {
            let values = selectedConfirmationTrials.compactMap(
                \.heldoutCrossEntropyStandardError
            )
            guard values.count
                    == selectedConfirmationTrials.count,
                  !values.isEmpty else {
                return nil
            }
            return sqrt(values.map { $0 * $0 }.reduce(0, +))
                / Double(values.count)
        }()
        let confirmationBetweenSeedStandardError =
            standardErrorOfReplicateMeans(
                selectedConfirmationTrials.compactMap(
                    \.heldoutCrossEntropyAfter
                )
            )
        let confirmationValidAfter = mean(
            selectedConfirmationTrials.compactMap(
                \.heldoutValidCrossEntropyAfter
            )
        )
        let confirmationRefusalAfter = mean(
            selectedConfirmationTrials.compactMap(
                \.heldoutRefusalCrossEntropyAfter
            )
        )
        let confirmationFamilyAfter: [String: Double]? = {
            guard !selectedConfirmationTrials.isEmpty else {
                return nil
            }
            var result: [String: Double] = [:]
            for family in requiredSemanticFamilyIDs {
                let values =
                    selectedConfirmationTrials.compactMap {
                        $0.heldoutFamilyCrossEntropyAfter?[family]
                    }
                guard values.count
                        == selectedConfirmationTrials.count,
                      let familyMean = mean(values) else {
                    return nil
                }
                result[family] = familyMean
            }
            return result
        }()
        let independentConfirmationComparisonGrounded =
            selectedConfirmationTrials.count
                >= minimumIndependentConfirmationReplicateCount
            && profileComparisonCalibrationID != nil

        let selectedMetricsGrounded =
            before != nil
            && after != nil
            && validBefore != nil
            && validAfter != nil
            && refusalBefore != nil
            && refusalAfter != nil
            && withinRowStandardError != nil
            && betweenSeedStandardError != nil
            && familyAfter != nil
        let screenEvidence =
            structuralEvidence
            && selectedRateReplicatesGrounded
            && selectedMetricsGrounded
            && selectedQuality
        return ProfileAggregate(
            profile: profile,
            trials: orderedTrials,
            representative:
                selectedTrials.first(where: {
                    $0.seed == discoverySeed
                }) ?? fallbackRepresentative,
            matrixContract: commonContract ? firstContract : nil,
            seedContracts:
                seedContractsGrounded ? seedContracts : [:],
            screenGrounded: screenEvidence,
            evidenceGrounded: structuralEvidence,
            balancedScheduleGrounded:
                schedules.allSatisfy { $0 },
            tokenAccountingGrounded:
                accounting.allSatisfy { $0 },
            heldoutEvidenceGrounded:
                heldoutEvidence.allSatisfy { $0 },
            selectedQualityGrounded: selectedQuality,
            optimizerGrounded: optimizers.allSatisfy { $0 },
            timingGrounded: timings.allSatisfy { $0 },
            discoveryGridGrounded: discoveryGridGrounded,
            selectedRateReplicatesGrounded:
                selectedRateReplicatesGrounded,
            discoveryQualityRejected: discoveryQualityRejected,
            selectedLearningRate: selectedRate,
            missingConfirmationSeeds: missingConfirmations,
            qualityRejectedTrials: qualityRejectedTrials,
            selectedConfirmationQualityRejected:
                selectedConfirmationQualityRejected,
            heldoutCrossEntropyBefore: before,
            heldoutCrossEntropyAfter: after,
            heldoutCrossEntropyWithinRowStandardError:
                withinRowStandardError,
            heldoutCrossEntropyBetweenSeedStandardError:
                betweenSeedStandardError,
            independentConfirmationReplicateCount:
                selectedConfirmationTrials.count,
            confirmationHeldoutCrossEntropyBefore:
                confirmationBefore,
            confirmationHeldoutCrossEntropyAfter:
                confirmationAfter,
            confirmationHeldoutCrossEntropyWithinRowStandardError:
                confirmationWithinRowStandardError,
            confirmationHeldoutCrossEntropyBetweenSeedStandardError:
                confirmationBetweenSeedStandardError,
            confirmationHeldoutValidCrossEntropyAfter:
                confirmationValidAfter,
            confirmationHeldoutRefusalCrossEntropyAfter:
                confirmationRefusalAfter,
            confirmationHeldoutFamilyCrossEntropyAfter:
                confirmationFamilyAfter,
            independentConfirmationComparisonGrounded:
                independentConfirmationComparisonGrounded,
            heldoutValidCrossEntropyBefore: validBefore,
            heldoutValidCrossEntropyAfter: validAfter,
            heldoutRefusalCrossEntropyBefore: refusalBefore,
            heldoutRefusalCrossEntropyAfter: refusalAfter,
            heldoutFamilyCrossEntropyAfter: familyAfter,
            steadyTokensPerSecond: mean(
                selectedTrials.compactMap(
                    \.steadyStateTokensPerSecond
                )
            ),
            coldStartSeconds: mean(
                selectedTrials.compactMap(\.coldStartSeconds)
            ),
            peakMemoryBytes:
                selectedTrials.map(\.peakMemoryBytes).max()
        )
    }

    private static func matrixComparable(
        _ decisions: [ProfileDecision]
    ) -> Bool {
        guard !decisions.isEmpty else { return false }
        let contracts = decisions.compactMap {
            $0.aggregate?.matrixContract
        }
        guard contracts.count == decisions.count,
              let firstContract = contracts.first,
              contracts.allSatisfy({ $0 == firstContract }),
              let firstSeedContracts =
                decisions.first?.aggregate?.seedContracts else {
            return false
        }
        return decisions.allSatisfy {
            $0.aggregate?.seedContracts == firstSeedContracts
        }
    }

    private static func selectProfile(
        from decisions: [ProfileDecision]
    ) -> (ProfileDecision?, String) {
        guard !decisions.isEmpty else {
            return (nil, "no_independently_eligible_profile")
        }
        guard matrixComparable(decisions) else {
            return (
                nil,
                "eligible_profiles_are_not_one_comparable_architecture_matrix"
            )
        }
        guard profileComparisonCalibrationID != nil else {
            return (
                nil,
                "independent_confirmation_comparison_calibration_unbound"
            )
        }
        return (
            nil,
            "independent_confirmation_profile_selection_not_implemented"
        )
    }

    private static func ioBenchmarkGrounded(
        _ benchmark: ProfileIOEvidence?,
        profile: ModelProfile,
        parameterCount: Int64,
        plannedShardBytesUpperBound: Int64?
    ) -> Bool {
        guard let benchmark,
              let plannedShardBytesUpperBound,
              plannedShardBytesUpperBound >= 0 else {
            return false
        }
        let checkpointPayloadBytes = parameterCount * 4
        let (artifactBytes, addOverflow) =
            benchmark.checkpointArtifactBytes
                .addingReportingOverflow(
                    benchmark.shardArtifactBytes
            )
        let (expectedTransferred, multiplyOverflow) =
            artifactBytes.multipliedReportingOverflow(by: 2)
        guard !addOverflow, !multiplyOverflow,
              benchmark.profileID == profile.profileID,
              benchmark.parameterCount == parameterCount,
              isSHA256(benchmark.measurementManifestSHA256),
              benchmark.checkpointPrecision == "float32",
              benchmark.checkpointPayloadBytes
                == checkpointPayloadBytes,
              benchmark.checkpointArtifactBytes
                >= checkpointPayloadBytes,
              benchmark.shardArtifactBytes >= 0,
              benchmark.shardArtifactBytes
                <= plannedShardBytesUpperBound,
              benchmark.bytesTransferred == expectedTransferred,
              benchmark.elapsedSeconds.isFinite,
              benchmark.elapsedSeconds > 0,
              benchmark.bytesPerSecond.isFinite,
              benchmark.bytesPerSecond > 0,
              benchmark.durableWriteAndExactReadPassed else {
            return false
        }
        let recomputed =
            Double(expectedTransferred)
                / benchmark.elapsedSeconds
        let tolerance =
            max(1e-6, benchmark.bytesPerSecond * 1e-9)
        return abs(recomputed - benchmark.bytesPerSecond)
            <= tolerance
    }

    private static func autoregressivePreflightGrounded(
        _ preflight: ProfileAutoregressivePreflightEvidence?,
        profile: ModelProfile,
        parameterCount: Int64,
        input: Inputs
    ) -> Bool {
        guard let preflight else { return false }
        let boundProbe = input.probes.first {
            $0.profileID == preflight.profileID
                && $0.seed == preflight.probeSeed
                && $0.replicateID
                    == preflight.probeReplicateID
        }
        let (expectedDecodeTokens, decodeOverflow) =
            preflight.evaluationRowCount
                .multipliedReportingOverflow(
                    by: Int64(
                        requiredAutoregressiveGenerationCap
                    )
                )
        let (plannedPromptTokens, promptPlanOverflow) =
            preflight.promptPrefillTokenCount
                .multipliedReportingOverflow(
                    by: requiredFullEvaluationPhaseCount
                )
        let (plannedDecodeTokens, decodePlanOverflow) =
            preflight.cachedDecodeTokenCount
                .multipliedReportingOverflow(
                    by: requiredFullEvaluationPhaseCount
                )
        guard !decodeOverflow,
              !promptPlanOverflow,
              !decodePlanOverflow,
              preflight.profileID == profile.profileID,
              preflight.parameterCount == parameterCount,
              isSHA256(preflight.measurementManifestSHA256),
              preflight.corpusManifestSHA256
                == input.corpus.manifestSHA256,
              preflight.corpusManifestSHA256
                == ErgenticsPrimeNativeTextCorpus.manifest()
                    .manifestSHA256,
              preflight.evaluationRowCount
                == ErgenticsNativeLanguageCanary
                    .plannedFullEvaluationRowCount,
              preflight.orderedEvaluationRowIDsSHA256
                == ErgenticsNativeLanguageCanary
                    .plannedFullEvaluationOrderedRowIDsSHA256,
              preflight.contextLengthGroupCount
                == ErgenticsNativeLanguageCanary
                    .plannedFullEvaluationContextLengthGroupCount,
              preflight.contextLengthGroupingSHA256
                == ErgenticsNativeLanguageCanary
                    .plannedFullEvaluationContextLengthGroupingSHA256,
              isSHA256(preflight.artifactSHA256),
              !preflight.artifactRelativePath.isEmpty,
              !preflight.artifactRelativePath.hasPrefix("/"),
              !preflight.artifactRelativePath.contains(".."),
              isSHA256(preflight.modelStateSHA256),
              boundProbe?.initializationFingerprintSHA256
                == preflight.modelStateSHA256,
              preflight.evaluationRowCount > 0,
              preflight.coveredEvaluationRowCount
                == preflight.evaluationRowCount,
              preflight.contextLengthGroupCount > 0,
              preflight.coveredContextLengthGroupCount
                == preflight.contextLengthGroupCount,
              preflight.contextLengthGroupCount
                <= preflight.evaluationRowCount,
              preflight.batchSize > 0,
              preflight.promptOnlyBatching,
              preflight.targetIndependentFixedGenerationCap,
              preflight.eosAllowed,
              preflight.eosIgnoredForTiming,
              preflight.generationCapTokenCount
                == requiredAutoregressiveGenerationCap,
              preflight.kvCacheEnabled,
              preflight.promptPrefillTokenCount > 0,
              preflight.promptPrefillElapsedSeconds.isFinite,
              preflight.promptPrefillElapsedSeconds > 0,
              preflight.promptPrefillTokensPerSecond.isFinite,
              preflight.promptPrefillTokensPerSecond > 0,
              preflight.cachedDecodeTokenCount
                == expectedDecodeTokens,
              input.plannedFullEvaluationPromptTokenCount
                == plannedPromptTokens,
              input.plannedFullEvaluationMaximumGeneratedTokenCount
                == plannedDecodeTokens,
              preflight.cachedDecodeElapsedSeconds.isFinite,
              preflight.cachedDecodeElapsedSeconds > 0,
              preflight.cachedDecodeTokensPerSecond.isFinite,
              preflight.cachedDecodeTokensPerSecond > 0,
              preflight.cachedUncachedGreedyTokenParity,
              preflight.cachedUncachedMaximumLogitDelta.isFinite,
              preflight.cachedUncachedMaximumLogitDelta >= 0,
              preflight.cachedUncachedMaximumLogitDelta <= 1e-5,
              preflight.peakMemoryBytes > 0 else {
            return false
        }
        let recomputedPrefill =
            Double(preflight.promptPrefillTokenCount)
                / preflight.promptPrefillElapsedSeconds
        let recomputedDecode =
            Double(preflight.cachedDecodeTokenCount)
                / preflight.cachedDecodeElapsedSeconds
        let prefillTolerance = max(
            1e-9,
            preflight.promptPrefillTokensPerSecond * 1e-9
        )
        let decodeTolerance = max(
            1e-9,
            preflight.cachedDecodeTokensPerSecond * 1e-9
        )
        return abs(
            recomputedPrefill
                - preflight.promptPrefillTokensPerSecond
        ) <= prefillTolerance
            && abs(
                recomputedDecode
                    - preflight.cachedDecodeTokensPerSecond
            ) <= decodeTolerance
    }

    private static func assessment(
        for decision: ProfileDecision,
        tokenizerMode: TokenizerMode,
        profileScreenMatrixComparable: Bool,
        architectureMatrixComparable: Bool,
        failedTrials:
            [ErgenticsNativeLanguageProfileTrialFailure.Evidence],
        profileTrialFailureEvidenceGrounded: Bool
    ) -> ProfileAssessment {
        let aggregate = decision.aggregate
        let trial = aggregate?.representative
        let completedDiscoveryGrid =
            aggregate?.discoveryGridGrounded == true
            ? discoveryLearningRates
            : []
        let completedSeeds: [Int] = {
            guard aggregate?.evidenceGrounded == true else {
                return []
            }
            return Array(
                Set(
                    aggregate?.trials.map(\.seed) ?? []
                )
            ).sorted()
        }()
        let qualityRejectedTrials =
            aggregate?.qualityRejectedTrials ?? []
        return ProfileAssessment(
            profile: decision.profile,
            tokenizerMode: tokenizerMode,
            vocabularySize: tokenizerMode.vocabularySize,
            parameterCount: decision.parameterCount,
            minimumFP32AdamTrainingStateBytes: decision.stateBytes,
            fp32CheckpointBytes: decision.parameterCount * 4,
            broadLanguagePlanningTokenInstances:
                decision.parameterCount
                * broadLanguagePlanningTokensPerParameter,
            minimumDeduplicatedTrainingTokenInstances:
                decision.minimumCorpusTokens,
            minimumUniqueTrainingRows: decision.minimumRows,
            minimumUniqueSemanticCombinations:
                decision.minimumCombinations,
            minimumPlannedTrainingTokenPresentations:
                decision.minimumPlanned,
            measuredSequenceLength: trial?.measuredSequenceLength,
            measuredBatchSize: trial?.batchSize,
            measuredTokensPerSecond:
                aggregate?.steadyTokensPerSecond,
            measuredPeakMemoryBytes: aggregate?.peakMemoryBytes,
            relativeLossReduction: {
                guard let before =
                        aggregate?.heldoutCrossEntropyBefore,
                      let after =
                        aggregate?.heldoutCrossEntropyAfter,
                      before.isFinite, before > 0,
                      after.isFinite else {
                    return nil
                }
                return (before - after) / before
            }(),
            heldoutCrossEntropyBefore:
                aggregate?.heldoutCrossEntropyBefore,
            heldoutCrossEntropyAfter:
                aggregate?.heldoutCrossEntropyAfter,
            heldoutCrossEntropyStandardError:
                aggregate?
                    .heldoutCrossEntropyBetweenSeedStandardError,
            heldoutCrossEntropyWithinRowStandardError:
                aggregate?
                    .heldoutCrossEntropyWithinRowStandardError,
            heldoutCrossEntropyBetweenSeedStandardError:
                aggregate?
                    .heldoutCrossEntropyBetweenSeedStandardError,
            independentConfirmationReplicateCount:
                aggregate?
                    .independentConfirmationReplicateCount ?? 0,
            confirmationRelativeLossReduction: {
                guard let before =
                        aggregate?
                            .confirmationHeldoutCrossEntropyBefore,
                      let after =
                        aggregate?
                            .confirmationHeldoutCrossEntropyAfter,
                      before.isFinite, before > 0,
                      after.isFinite else {
                    return nil
                }
                return (before - after) / before
            }(),
            confirmationHeldoutCrossEntropyBefore:
                aggregate?
                    .confirmationHeldoutCrossEntropyBefore,
            confirmationHeldoutCrossEntropyAfter:
                aggregate?
                    .confirmationHeldoutCrossEntropyAfter,
            confirmationHeldoutCrossEntropyWithinRowStandardError:
                aggregate?
                    .confirmationHeldoutCrossEntropyWithinRowStandardError,
            confirmationHeldoutCrossEntropyBetweenSeedStandardError:
                aggregate?
                    .confirmationHeldoutCrossEntropyBetweenSeedStandardError,
            confirmationHeldoutValidCrossEntropyAfter:
                aggregate?
                    .confirmationHeldoutValidCrossEntropyAfter,
            confirmationHeldoutRefusalCrossEntropyAfter:
                aggregate?
                    .confirmationHeldoutRefusalCrossEntropyAfter,
            confirmationHeldoutFamilyCrossEntropyAfter:
                aggregate?
                    .confirmationHeldoutFamilyCrossEntropyAfter,
            independentConfirmationComparisonGrounded:
                aggregate?
                    .independentConfirmationComparisonGrounded
                    == true,
            heldoutValidCrossEntropyBefore:
                aggregate?.heldoutValidCrossEntropyBefore,
            heldoutValidCrossEntropyAfter:
                aggregate?.heldoutValidCrossEntropyAfter,
            heldoutRefusalCrossEntropyBefore:
                aggregate?.heldoutRefusalCrossEntropyBefore,
            heldoutRefusalCrossEntropyAfter:
                aggregate?.heldoutRefusalCrossEntropyAfter,
            selectedLearningRate: aggregate?.selectedLearningRate,
            evidenceTrialCount: aggregate?.trials.count ?? 0,
            qualityRejectedTrialCount:
                qualityRejectedTrials.count,
            qualityRejectedTrials: qualityRejectedTrials,
            failedTrialCount: failedTrials.count,
            failedTrialClassifications:
                failedTrials.map(\.classification),
            profileTrialFailureEvidenceGrounded:
                profileTrialFailureEvidenceGrounded,
            completedLearningRateGrid: completedDiscoveryGrid,
            completedReplicateSeeds: completedSeeds,
            missingConfirmationSeeds:
                aggregate?.missingConfirmationSeeds
                    ?? confirmationSeeds,
            discoveryLearningRateGridGrounded:
                aggregate?.discoveryGridGrounded == true,
            selectedLearningRateReplicatesGrounded:
                aggregate?.selectedRateReplicatesGrounded == true,
            projectedCanaryTrainingSeconds:
                decision.projectedTrainingSeconds,
            projectedEvaluationSeconds:
                decision.projectedEvaluationSeconds,
            projectedCheckpointAndShardIOSeconds:
                decision.projectedIOSeconds,
            projectedTotalSeconds: decision.projectedTotalSeconds,
            profileProbeGrounded:
                aggregate?.evidenceGrounded == true,
            balancedTrainingScheduleGrounded:
                aggregate?.balancedScheduleGrounded == true,
            tokenAccountingGrounded:
                aggregate?.tokenAccountingGrounded == true,
            disjointHeldoutGrounded:
                aggregate?.heldoutEvidenceGrounded == true,
            exactOptimizerGrounded:
                aggregate?.optimizerGrounded == true,
            coldAndSteadyTimingGrounded:
                aggregate?.timingGrounded == true,
            profileIOBenchmarkGrounded:
                decision.ioBenchmarkGrounded,
            autoregressivePreflightGrounded:
                decision.autoregressivePreflightGrounded,
            measuredPromptPrefillTokensPerSecond:
                decision.autoregressivePreflight?
                    .promptPrefillTokensPerSecond,
            measuredCachedDecodeTokensPerSecond:
                decision.autoregressivePreflight?
                    .cachedDecodeTokensPerSecond,
            profileScreenMatrixComparable:
                decision.aggregate?.screenGrounded == true
                && profileScreenMatrixComparable,
            architectureProfileComparable:
                decision.independentEligible
                && architectureMatrixComparable,
            corpusMassSufficient: decision.corpusMass,
            plannedTokenPresentationsSufficient:
                decision.plannedMass,
            memorySufficient: decision.memory,
            wallClockSufficient: decision.wallClock,
            learningSlopeNonRegressed:
                aggregate?.selectedQualityGrounded == true,
            currentFunctionalCanaryEligible:
                decision.independentEligible,
            blockedReason: decision.blockedReason
        )
    }

    public static func recommend(_ input: Inputs) -> Recommendation {
        let tokenizerBound = tokenizerGrounded(
            input.tokenizer,
            corpusManifestSHA256: input.corpus.manifestSHA256
        )
        let implementationBound = implementationGrounded(
            input.implementation
        )
        let corpusProvenance = corpusProvenanceGrounded(input.corpus)
        let knownProfileIDs = Set(profiles.map(\.profileID))
        let suppliedProfileIDs = input.probes.map(\.profileID)
        let trialKeys = input.probes.map {
            "\($0.profileID)|\($0.learningRate.bitPattern)|\($0.seed)|\($0.replicateID ?? "<missing>")"
        }
        let successfulMatrixKeys = input.probes.map {
            "\($0.profileID)|\($0.learningRate.bitPattern)|\($0.seed)"
        }
        let probeSetGrounded =
            Set(suppliedProfileIDs).isSubset(of: knownProfileIDs)
                && Set(trialKeys).count == trialKeys.count
        let failedProfileIDs =
            input.failedProfileTrials.map(\.profileID)
        let failedTrialKeys =
            input.failedProfileTrials.map(\.trialKey)
        let failedMatrixKeys = input.failedProfileTrials.map {
            "\($0.profileID)|\($0.learningRate.bitPattern)|\($0.seed)"
        }
        let failedTrialsStructurallyGrounded =
            input.failedProfileTrials.allSatisfy { failure in
                do {
                    try ErgenticsNativeLanguageProfileTrialFailure
                        .validate(failure)
                    return true
                } catch {
                    return false
                }
            }
        let failedTrialMatrixGrounded =
            input.failedProfileTrials.allSatisfy { failure in
                guard discoveryLearningRates.contains(
                    failure.learningRate
                ) else {
                    return false
                }
                if failure.probePurposeID
                    == ErgenticsNativeLanguageRunConfiguration
                        .discoveryPurposeID {
                    return failure.seed == discoverySeed
                }
                if failure.probePurposeID
                    == ErgenticsNativeLanguageRunConfiguration
                        .confirmationPurposeID {
                    return confirmationSeeds.contains(failure.seed)
                }
                return false
            }
        let failedTrialAuthoritySetGrounded: Bool = {
            guard !input.failedProfileTrials.isEmpty else {
                return true
            }
            return Set(
                input.failedProfileTrials.map(
                    \.tokenizerArtifactSHA256
                )
            ).count == 1
                && Set(
                    input.failedProfileTrials.map(
                        \.corpusArtifactSHA256
                    )
                ).count == 1
                && Set(
                    input.failedProfileTrials.map(
                        \.packageResolvedSHA256
                    )
                ).count == 1
                && Set(
                    input.failedProfileTrials.map(
                        \.executorArtifactSHA256
                    )
                ).count == 1
                && Set(
                    input.failedProfileTrials.map(
                        \.recommenderArtifactSHA256
                    )
                ).count == 1
                && Set(
                    input.failedProfileTrials.map(
                        \.metalLibraryArtifactSHA256
                    )
                ).count == 1
                && Set(
                    input.failedProfileTrials.map(
                        \.metalLibraryArtifactByteCount
                    )
                ).count == 1
                && Set(
                    input.failedProfileTrials.map(
                        \.metalLibrarySourceMLXSwiftRevision
                    )
                ).count == 1
        }()
        let failedTrialBaseSetGrounded =
            failedTrialsStructurallyGrounded
                && Set(failedProfileIDs).isSubset(of: knownProfileIDs)
                && Set(failedTrialKeys).count
                    == failedTrialKeys.count
                && Set(failedMatrixKeys).count
                    == failedMatrixKeys.count
                && Set(failedMatrixKeys).isDisjoint(
                    with: Set(successfulMatrixKeys)
                )
                && failedTrialMatrixGrounded
                && failedTrialAuthoritySetGrounded
        let hasFailedProfileTrials =
            !input.failedProfileTrials.isEmpty
        let orderedFailedProfileTrials =
            input.failedProfileTrials.sorted { left, right in
                if left.profileID != right.profileID {
                    return left.profileID < right.profileID
                }
                if left.probePurposeID != right.probePurposeID {
                    return left.probePurposeID
                        < right.probePurposeID
                }
                if left.seed != right.seed {
                    return left.seed < right.seed
                }
                return left.learningRate < right.learningRate
            }
        let failedTrialsByProfile = Dictionary(
            grouping: orderedFailedProfileTrials,
            by: \.profileID
        )
        let ioProfileIDs =
            input.profileIOBenchmarks.map(\.profileID)
        let ioBenchmarkSetGrounded =
            Set(ioProfileIDs).isSubset(of: knownProfileIDs)
                && Set(ioProfileIDs).count == ioProfileIDs.count
        var ioByProfile: [String: ProfileIOEvidence] = [:]
        for benchmark in input.profileIOBenchmarks
        where ioByProfile[benchmark.profileID] == nil {
            ioByProfile[benchmark.profileID] = benchmark
        }
        let autoregressiveProfileIDs =
            input.profileAutoregressivePreflights.map(\.profileID)
        let autoregressivePreflightSetGrounded =
            Set(autoregressiveProfileIDs).isSubset(of: knownProfileIDs)
                && Set(autoregressiveProfileIDs).count
                    == autoregressiveProfileIDs.count
        var autoregressiveByProfile:
            [String: ProfileAutoregressivePreflightEvidence] = [:]
        for preflight in input.profileAutoregressivePreflights
        where autoregressiveByProfile[preflight.profileID] == nil {
            autoregressiveByProfile[preflight.profileID] = preflight
        }
        let tolerance = input.qualityIndifferenceCrossEntropy
        let qualityContractGrounded =
            tolerance.map { $0.isFinite && $0 >= 0 } ?? false
        let plannedScheduleGrounded =
            plannedTrainingScheduleGrounded(input)
        let wallProjectionContractGrounded =
            input.plannedFullEvaluationPromptTokenCount
                .map {
                    $0
                        == ErgenticsNativeLanguageCanary
                            .plannedFullEvaluationPromptTokenCount
                } ?? false
            && input.plannedFullEvaluationMaximumGeneratedTokenCount
                .map {
                    $0
                        == ErgenticsNativeLanguageCanary
                            .plannedFullEvaluationMaximumGeneratedTokenCount
                } ?? false
            && input.plannedFullEvaluationNonPaddingTokenCount
                == ErgenticsNativeLanguageCanary
                    .plannedFullEvaluationNonPaddingTokenCount
            && input.plannedShardArtifactBytesUpperBound
                == ErgenticsNativeLanguageCanary
                    .plannedShardArtifactBytesUpperBound

        let grouped = Dictionary(grouping: input.probes, by: \.profileID)
        var aggregates: [String: ProfileAggregate] = [:]
        for profile in profiles {
            let vocabularySize = input.tokenizer.mode.vocabularySize
            let parameters = profile.parameterCount(
                vocabularySize: vocabularySize
            )
            if let trials = grouped[profile.profileID],
               let aggregate = aggregate(
                   profile: profile,
                   parameterCount: parameters,
                   trials: trials,
                   input: input
               ) {
                aggregates[profile.profileID] = aggregate
            }
        }
        let confirmationFailureDiscoveryGrounded =
            input.failedProfileTrials.allSatisfy { failure in
                guard failure.probePurposeID
                    == ErgenticsNativeLanguageRunConfiguration
                        .confirmationPurposeID else {
                    return true
                }
                guard let profile = profiles.first(where: {
                    $0.profileID == failure.profileID
                }),
                let trials = grouped[failure.profileID]
                else {
                    return false
                }
                let parameterCount = profile.parameterCount(
                    vocabularySize:
                        input.tokenizer.mode.vocabularySize
                )
                return groundedDiscoverySelectedLearningRate(
                    profile: profile,
                    parameterCount: parameterCount,
                    trials: trials,
                    input: input
                ) == failure.learningRate
            }
        let failedTrialSetGrounded =
            failedTrialBaseSetGrounded
                && confirmationFailureDiscoveryGrounded
        let failedTrialsRouteToBFloat16 =
            hasFailedProfileTrials
                && failedTrialSetGrounded
                && input.failedProfileTrials.allSatisfy {
                    $0.routesToBFloat16Challenger
                }

        var decisions: [ProfileDecision] = []
        for profile in profiles {
            let vocabularySize = input.tokenizer.mode.vocabularySize
            let parameters = profile.parameterCount(
                vocabularySize: vocabularySize
            )
            let stateBytes = parameters * 16
            let minimumCorpusTokens =
                minimumDeduplicatedTrainingTokenInstances(
                    parameterCount: parameters
                )
            let minimumRows = minimumUniqueTrainingRows(
                parameterCount: parameters
            )
            let minimumCombinations =
                minimumUniqueSemanticCombinations(
                    parameterCount: parameters
                )
            let minimumPlanned =
                minimumPlannedTrainingTokenPresentations(
                    parameterCount: parameters
                )
            let corpusMass =
                input.corpus.deduplicatedTrainingTokenInstances
                    >= minimumCorpusTokens
                && input.corpus.uniqueTrainingRows >= minimumRows
                && input.corpus.uniqueSemanticCombinations
                    >= minimumCombinations
            let plannedMass =
                plannedScheduleGrounded
                &&
                input.plannedTrainingTokenPresentations
                    >= minimumPlanned
            let fp32CheckpointBytes = parameters * 4
            let ioBenchmark = ioByProfile[profile.profileID]
            let ioGrounded =
                ioBenchmarkSetGrounded
                && ioBenchmarkGrounded(
                    ioBenchmark,
                    profile: profile,
                    parameterCount: parameters,
                    plannedShardBytesUpperBound:
                        input
                            .plannedShardArtifactBytesUpperBound
                )
            let checkpointArtifactPlanningBytes =
                ioGrounded
                ? ioBenchmark!.checkpointArtifactBytes
                : fp32CheckpointBytes
                    + maximumCheckpointHeaderPlanningBytes
            let minimumArtifactDiskBytes =
                input.plannedShardArtifactBytesUpperBound
                    .map {
                        (
                            checkpointArtifactPlanningBytes
                                + $0
                        ) * 3
                    } ?? .max
            let lowerBoundMemory =
                input.unifiedMemoryBytes >= stateBytes * 2
                && input.freeDiskBytes >= minimumArtifactDiskBytes
            let aggregate = aggregates[profile.profileID]
            let autoregressivePreflight =
                autoregressiveByProfile[profile.profileID]
            let autoregressiveGrounded =
                autoregressivePreflightSetGrounded
                && autoregressivePreflightGrounded(
                    autoregressivePreflight,
                    profile: profile,
                    parameterCount: parameters,
                    input: input
                )
            let measuredMemory = aggregate?.peakMemoryBytes.map {
                $0 <= input.unifiedMemoryBytes * 4 / 5
            } ?? false
            let autoregressiveMemory =
                autoregressivePreflight.map {
                    $0.peakMemoryBytes
                        <= input.unifiedMemoryBytes * 4 / 5
                } ?? true
            let memory =
                lowerBoundMemory
                    && measuredMemory
                    && autoregressiveMemory
            let projectedTrainingSeconds: Double? = {
                guard let throughput =
                        aggregate?.steadyTokensPerSecond,
                      throughput > 0 else {
                    return nil
                }
                return Double(
                    input.plannedTrainingTokenPresentations
                ) / throughput
            }()
            let projectedTrainingExceedsWallClock =
                input.maximumWallClockSeconds > 0
                && (projectedTrainingSeconds.map {
                    $0 > input.maximumWallClockSeconds
                } ?? false)
            let projectedEvaluationSeconds: Double? = {
                guard let plannedPromptTokens =
                        input
                            .plannedFullEvaluationPromptTokenCount,
                      let plannedGeneratedTokens =
                        input
                            .plannedFullEvaluationMaximumGeneratedTokenCount,
                      let preflight = autoregressivePreflight,
                      autoregressiveGrounded else {
                    return nil
                }
                return
                    Double(plannedPromptTokens)
                        / preflight.promptPrefillTokensPerSecond
                    + Double(plannedGeneratedTokens)
                        / preflight.cachedDecodeTokensPerSecond
            }()
            let projectedIOSeconds: Double? = {
                guard let shardBytes =
                        input
                            .plannedShardArtifactBytesUpperBound,
                      let throughput =
                        ioBenchmark?
                            .bytesPerSecond,
                      let checkpointArtifactBytes =
                        ioBenchmark?.checkpointArtifactBytes,
                      ioGrounded,
                      throughput > 0 else {
                    return nil
                }
                return Double(
                    2
                        * (
                            checkpointArtifactBytes
                                + shardBytes
                        )
                ) / throughput
            }()
            let projectedTotalSeconds: Double? = {
                guard let training = projectedTrainingSeconds,
                      let evaluation = projectedEvaluationSeconds,
                      let io = projectedIOSeconds,
                      let cold = aggregate?.coldStartSeconds else {
                    return nil
                }
                return cold + training + evaluation + io
            }()
            let wallClock =
                input.maximumWallClockSeconds > 0
                && wallProjectionContractGrounded
                && (projectedTotalSeconds.map {
                    $0 <= input.maximumWallClockSeconds
                } ?? false)
            let eligible =
                tokenizerBound
                && implementationBound
                && corpusProvenance
                && probeSetGrounded
                && failedTrialSetGrounded
                && !hasFailedProfileTrials
                && qualityContractGrounded
                && profile.architectureValid
                && aggregate?.screenGrounded == true
                && aggregate?
                    .independentConfirmationComparisonGrounded
                    == true
                && ioGrounded
                && autoregressiveGrounded
                && corpusMass
                && plannedMass
                && memory
                && wallClock
            let screenEligible =
                tokenizerBound
                && implementationBound
                && corpusProvenance
                && probeSetGrounded
                && failedTrialSetGrounded
                && !hasFailedProfileTrials
                && qualityContractGrounded
                && profile.architectureValid
                && aggregate?.screenGrounded == true
                && corpusMass
                && plannedMass
                && memory

            let blockedReason: String? = {
                if !tokenizerBound {
                    return "tokenizer_not_grounded"
                }
                if !implementationBound {
                    return "swift_mlx_implementation_not_grounded"
                }
                if !corpusProvenance {
                    return "corpus_provenance_not_grounded"
                }
                if !probeSetGrounded {
                    return "probe_set_has_unknown_or_duplicate_trial"
                }
                if !failedTrialSetGrounded {
                    return "profile_trial_failure_evidence_not_grounded"
                }
                if hasFailedProfileTrials {
                    guard let failures =
                            failedTrialsByProfile[
                                profile.profileID
                            ],
                          !failures.isEmpty else {
                        return "profile_screen_interrupted_by_failed_trial"
                    }
                    return failures.allSatisfy {
                        $0.routesToBFloat16Challenger
                    }
                        ? "fp32_profile_trial_timed_out"
                        : "native_profile_trial_failed"
                }
                if !qualityContractGrounded {
                    return "quality_tolerance_or_confidence_not_grounded"
                }
                if !plannedScheduleGrounded {
                    return "planned_240_valid_48_refusal_block_schedule_not_grounded"
                }
                if !wallProjectionContractGrounded {
                    return "autoregressive_evaluation_or_io_projection_not_bound"
                }
                if aggregate == nil {
                    return "profile_probe_missing"
                }
                if aggregate?.balancedScheduleGrounded != true {
                    return "balanced_unique_family_schedule_not_grounded"
                }
                if aggregate?.tokenAccountingGrounded != true {
                    return "processed_nonpad_target_accounting_not_grounded"
                }
                if aggregate?.heldoutEvidenceGrounded != true {
                    return "disjoint_heldout_cross_entropy_not_grounded"
                }
                if aggregate?.optimizerGrounded != true {
                    return "exact_optimizer_or_clip_semantics_not_grounded"
                }
                if aggregate?.timingGrounded != true {
                    return "cold_or_steady_timing_not_grounded"
                }
                if aggregate?.discoveryGridGrounded != true {
                    return "learning_rate_discovery_grid_incomplete"
                }
                if aggregate?.evidenceGrounded != true {
                    return "profile_probe_binding_or_matrix_contract_failed"
                }
                if aggregate?.discoveryQualityRejected == true {
                    return "all_discovery_learning_rates_quality_rejected"
                }
                if aggregate?.selectedRateReplicatesGrounded != true {
                    return "selected_learning_rate_replicates_incomplete"
                }
                if aggregate?
                    .selectedConfirmationQualityRejected == true {
                    return "selected_learning_rate_confirmation_quality_regressed"
                }
                if aggregate?.selectedQualityGrounded != true {
                    return "selected_learning_rate_quality_not_grounded"
                }
                if projectedTrainingExceedsWallClock {
                    return "projected_training_wall_clock_exceeds_budget"
                }
                if aggregate?
                    .independentConfirmationReplicateCount
                    ?? 0
                    < minimumIndependentConfirmationReplicateCount {
                    return "independent_confirmation_replicates_insufficient_for_profile_comparison"
                }
                if profileComparisonCalibrationID == nil {
                    return "independent_confirmation_comparison_calibration_unbound"
                }
                if !ioGrounded {
                    return "profile_fp32_io_benchmark_not_grounded"
                }
                if !autoregressiveGrounded {
                    return "profile_prompt_prefill_or_cached_fixed64_decode_preflight_not_grounded"
                }
                if !corpusMass {
                    return "deduplicated_corpus_mass_or_semantic_breadth_insufficient"
                }
                if !plannedMass {
                    return "planned_token_presentations_insufficient"
                }
                if !memory {
                    return "measured_or_lower_bound_memory_insufficient"
                }
                if !wallClock {
                    return "projected_wall_clock_exceeds_budget"
                }
                return nil
            }()
            decisions.append(
                ProfileDecision(
                    profile: profile,
                    aggregate: aggregate,
                    parameterCount: parameters,
                    stateBytes: stateBytes,
                    minimumCorpusTokens: minimumCorpusTokens,
                    minimumRows: minimumRows,
                    minimumCombinations: minimumCombinations,
                    minimumPlanned: minimumPlanned,
                    corpusMass: corpusMass,
                    plannedMass: plannedMass,
                    memory: memory,
                    projectedTrainingSeconds:
                        projectedTrainingSeconds,
                    projectedEvaluationSeconds:
                        projectedEvaluationSeconds,
                    projectedIOSeconds: projectedIOSeconds,
                    projectedTotalSeconds:
                        projectedTotalSeconds,
                    wallClock: wallClock,
                    ioBenchmarkGrounded: ioGrounded,
                    autoregressivePreflightGrounded:
                        autoregressiveGrounded,
                    autoregressivePreflight:
                        autoregressivePreflight,
                    screenEligible: screenEligible,
                    independentEligible: eligible,
                    blockedReason: blockedReason
                )
            )
        }

        let maintainedProfileEvidenceDecisions =
            decisions.filter {
                $0.aggregate?.evidenceGrounded == true
            }
        let maintainedProfileCoverageGrounded =
            maintainedProfileEvidenceDecisions.count
                == profiles.count
        let maintainedProfileScreenDecisions =
            decisions.filter {
                $0.aggregate?.screenGrounded == true
            }
        let maintainedProfileScreenCoverageGrounded =
            maintainedProfileScreenDecisions.count
                == profiles.count
        let maintainedSelectedRateReplicateCoverageGrounded =
            decisions.allSatisfy {
                $0.aggregate?
                    .selectedRateReplicatesGrounded == true
            }
        let maintainedIndependentConfirmationReplicationGrounded =
            decisions.allSatisfy {
                ($0.aggregate?
                    .independentConfirmationReplicateCount ?? 0)
                    >= minimumIndependentConfirmationReplicateCount
            }
        let maintainedProfileScreenComparable =
            maintainedProfileScreenCoverageGrounded
                && matrixComparable(
                    maintainedProfileScreenDecisions
                )
        let discoveryQualityRegressionDecision =
            maintainedProfileCoverageGrounded
            ? decisions.first {
                $0.aggregate?.discoveryQualityRejected == true
            }
            : nil
        let confirmationQualityRegressionDecision =
            maintainedProfileCoverageGrounded
            ? decisions.first {
                $0.aggregate?
                    .selectedConfirmationQualityRejected == true
            }
            : nil
        let eligibleDecisions =
            maintainedProfileScreenComparable
            ? decisions.filter(\.independentEligible)
            : []
        let architectureMatrixComparable =
            maintainedProfileScreenComparable
                && !eligibleDecisions.isEmpty
                && matrixComparable(eligibleDecisions)
        let (selectedDecision, baseSelectionReason) =
            selectProfile(
                from: eligibleDecisions
            )
        let selectionReason =
            !failedTrialSetGrounded
            ? "profile_trial_failure_evidence_not_grounded"
            : hasFailedProfileTrials
                ? "profile_trial_failure_forces_abstain"
                : !maintainedProfileCoverageGrounded
                    ? "maintained_profile_matrix_incomplete"
                    : discoveryQualityRegressionDecision != nil
                        ? "all_discovery_learning_rates_quality_rejected"
                        : confirmationQualityRegressionDecision != nil
                            ? "selected_learning_rate_confirmation_quality_regressed"
                            : !maintainedSelectedRateReplicateCoverageGrounded
                                ? "selected_learning_rate_replicates_incomplete"
                                : !maintainedProfileScreenComparable
                                    ? "eligible_profiles_are_not_one_comparable_architecture_matrix"
                                    : !maintainedIndependentConfirmationReplicationGrounded
                                        ? "independent_confirmation_replicates_insufficient_for_profile_comparison"
                                        : profileComparisonCalibrationID
                                            == nil
                                            ? "independent_confirmation_comparison_calibration_unbound"
                                            : baseSelectionReason
        let screenDecisions = decisions.filter(\.screenEligible)
        let (pilotPriorityDecision, _) = selectProfile(
            from: screenDecisions
        )

        let assessments = decisions.map {
            assessment(
                for: $0,
                tokenizerMode: input.tokenizer.mode,
                profileScreenMatrixComparable:
                    maintainedProfileScreenComparable,
                architectureMatrixComparable:
                    architectureMatrixComparable,
                failedTrials:
                    failedTrialsByProfile[
                        $0.profile.profileID
                    ] ?? [],
                profileTrialFailureEvidenceGrounded:
                    failedTrialSetGrounded
            )
        }

        let selectedIndex = selectedDecision.flatMap { selected in
            profiles.firstIndex {
                $0.profileID == selected.profile.profileID
            }
        }
        let nextUnmeasured = profiles.first {
            grouped[$0.profileID] == nil
        }

        let nextAction: String = {
            if !failedTrialSetGrounded {
                return "repair_profile_trial_failure_evidence"
            }
            if hasFailedProfileTrials {
                return failedTrialsRouteToBFloat16
                    ? maintainedBFloat16CalibrationAction
                    : "diagnose_native_profile_trial_failure"
            }
            if !tokenizerBound {
                return "materialize_and_replay_native_tokenizer"
            }
            if !implementationBound {
                return "repair_swift_mlx_random_init_contract"
            }
            if !corpusProvenance {
                return "bind_corpus_provenance_and_semantic_counts"
            }
            if !probeSetGrounded {
                return "repair_profile_probe_set"
            }
            if !ioBenchmarkSetGrounded {
                return "repair_profile_io_benchmark_set"
            }
            if !qualityContractGrounded {
                return "bind_quality_tolerance_and_confidence_contract"
            }
            if !plannedScheduleGrounded {
                return "bind_1357_exact_240_valid_48_refusal_training_blocks"
            }
            if !wallProjectionContractGrounded {
                return "bind_prompt_prefill_fixed64_decode_and_io_projection_plan"
            }
            if maintainedProfileScreenComparable,
               decisions.contains(where: {
                guard $0.aggregate?.screenGrounded == true,
                      let projected =
                        $0.projectedTrainingSeconds else {
                    return false
                }
                return projected > input.maximumWallClockSeconds
            }) {
                return maintainedBFloat16CalibrationAction
            }
            if let priority = pilotPriorityDecision,
               !priority.ioBenchmarkGrounded {
                return "measure_\(priority.profile.profileID)_fp32_checkpoint_and_shard_io"
            }
            if let priority = pilotPriorityDecision,
               !priority.autoregressivePreflightGrounded {
                return "measure_\(priority.profile.profileID)_prompt_prefill_and_cached_fixed64_decode"
            }
            if selectedDecision == nil,
               decisions.contains(where: {
                   $0.blockedReason
                        == "measured_or_lower_bound_memory_insufficient"
                        || $0.blockedReason
                            == "projected_wall_clock_exceeds_budget"
               }) {
                return maintainedBFloat16CalibrationAction
            }
            for profile in profiles {
                let profileTrials =
                    grouped[profile.profileID] ?? []
                for rate in discoveryLearningRates
                where !profileTrials.contains(where: {
                    $0.seed == discoverySeed
                        && $0.learningRate == rate
                }) {
                    return "run_\(profile.profileID)_discovery_lr_\(rate)_seed_\(discoverySeed)"
                }
            }
            for profile in profiles {
                if aggregates[profile.profileID]?
                    .discoveryQualityRejected == true {
                    return "diagnose_\(profile.profileID)_discovery_grid_quality_regression"
                }
            }
            for profile in profiles
            where aggregates[profile.profileID]?
                .selectedConfirmationQualityRejected == true {
                return "diagnose_\(profile.profileID)_selected_learning_rate_confirmation_quality_regression"
            }
            for profile in profiles {
                guard let aggregate =
                        aggregates[profile.profileID],
                      let rate =
                        aggregate.selectedLearningRate,
                      let seed =
                        aggregate.missingConfirmationSeeds.first
                else {
                    continue
                }
                return "run_\(profile.profileID)_confirmation_lr_\(rate)_seed_\(seed)"
            }
            if !maintainedIndependentConfirmationReplicationGrounded {
                return fairExecutorDesignAction
            }
            if profileComparisonCalibrationID == nil {
                return "bind_calibrated_paired_seed_profile_comparison"
            }
            if !architectureMatrixComparable {
                return "repair_architecture_profile_comparison_matrix"
            }
            if selectedDecision == nil {
                return "repair_independent_profile_probe_evidence"
            }
            if let nextUnmeasured {
                return "run_\(nextUnmeasured.profileID)_independent_matrix_probe"
            }
            return "run_\(selectedDecision!.profile.profileID)_bounded_canary"
        }()

        let legs = [
            Leg(
                id: "S1_maintained_gqa_profiles",
                pass: profiles.allSatisfy(\.architectureValid),
                detail: profiles.map(\.profileID).joined(separator: ",")
            ),
            Leg(
                id: "S2_swift_mlx_random_init",
                pass: implementationBound,
                detail:
                    "\(input.implementation.executionLanguage) \(input.implementation.framework) \(input.implementation.modelImplementation)"
            ),
            Leg(
                id: "S3_tokenizer_artifact_and_swift_replay",
                pass: tokenizerBound,
                detail:
                    "\(input.tokenizer.mode.rawValue) vocab=\(input.tokenizer.vocabularySize)"
            ),
            Leg(
                id: "S4_corpus_provenance_and_exact_counts",
                pass: corpusProvenance,
                detail:
                    "tokens=\(input.corpus.deduplicatedTrainingTokenInstances) rows=\(input.corpus.uniqueTrainingRows) combinations=\(input.corpus.uniqueSemanticCombinations)"
            ),
            Leg(
                id: "S5_known_unique_profile_trial_set",
                pass: probeSetGrounded,
                detail:
                    suppliedProfileIDs.sorted().joined(separator: ",")
            ),
            Leg(
                id: "S5a_complete_maintained_profile_coverage",
                pass: maintainedProfileCoverageGrounded,
                detail:
                    "\(maintainedProfileEvidenceDecisions.count)/\(profiles.count)"
            ),
            Leg(
                id: "S5b_profile_trial_failure_set",
                pass:
                    failedTrialSetGrounded
                    && !hasFailedProfileTrials,
                detail:
                    orderedFailedProfileTrials.map {
                        "\($0.profileID):\($0.classification.rawValue)"
                    }.joined(separator: ",")
            ),
            Leg(
                id: "S6_balanced_disjoint_accounted_matrix",
                pass: maintainedProfileScreenComparable,
                detail:
                    "screen_matrix mixture=240_valid:48_refusal families=40_valid:8_refusal \(requiredSemanticFamilyIDs.sorted().joined(separator: ","))"
            ),
            Leg(
                id: "S6a_independent_confirmation_replication",
                pass:
                    maintainedIndependentConfirmationReplicationGrounded,
                detail:
                    "observed=\(confirmationSeeds.count) required=\(minimumIndependentConfirmationReplicateCount) discovery_seed_excluded"
            ),
            Leg(
                id: "S6b_profile_comparison_calibration",
                pass: profileComparisonCalibrationID != nil,
                detail:
                    profileComparisonCalibrationID
                    ?? "unbound_no_confidence_claim"
            ),
            Leg(
                id: "S7_architecture_profile_matrix_comparable",
                pass: architectureMatrixComparable,
                detail:
                    "\(comparisonKind) scope=\(comparisonBudgetScopeID)"
            ),
            Leg(
                id: "S8_data_led_profile_selected",
                pass: selectedDecision != nil,
                detail:
                    selectedDecision?.profile.profileID ?? "none"
            ),
            Leg(
                id: "S9_profile_bound_autoregressive_preflight",
                pass:
                    selectedDecision?
                        .autoregressivePreflightGrounded == true,
                detail:
                    "prompt_only_prefill_and_cached_fixed64_decode"
            ),
            Leg(
                id: "S10_broad_language_claim_boundary",
                pass: true,
                detail: "broad_language=false"
            ),
        ]

        let criticalLegsGrounded = legs.allSatisfy(\.pass)
        return Recommendation(
            schemaVersion: schemaVersion,
            outcome:
                selectedDecision != nil && criticalLegsGrounded
                ? "GROUNDED"
                : "ABSTAIN",
            familyID: familyID,
            comparisonKind: comparisonKind,
            comparisonBudgetScopeID:
                comparisonBudgetScopeID,
            comparisonPrerequisiteIDs:
                comparisonPrerequisiteIDs,
            replicateVariationScopeID:
                replicateVariationScopeID,
            initializationVsScheduleFactorAttributionAuthorized:
                false,
            claimScope:
                "fixed_token_fixed_step_short_horizon_learning_efficiency_diagnostic_only",
            selectionReason: selectionReason,
            nextAction: nextAction,
            nextUnmeasuredProfileID: nextUnmeasured?.profileID,
            selectedProfileID: selectedDecision?.profile.profileID,
            prioritizedProfileForIOPreflightID:
                pilotPriorityDecision?.profile.profileID,
            prioritizedProfileForAutoregressivePreflightID:
                pilotPriorityDecision?.profile.profileID,
            selectedTokenizerMode: input.tokenizer.mode,
            selectedParameterCount:
                selectedDecision?.parameterCount,
            qualityIndifferenceCrossEntropy:
                input.qualityIndifferenceCrossEntropy,
            legacyQualityConfidenceZDiagnostic:
                input.qualityConfidenceZ,
            relativeLossReductionMethodID:
                relativeLossReductionMethodID,
            profileComparisonUncertaintyMethodID:
                profileComparisonUncertaintyMethodID,
            minimumIndependentConfirmationReplicateCount:
                minimumIndependentConfirmationReplicateCount,
            profileComparisonCalibrationID:
                profileComparisonCalibrationID,
            profileComparisonGrounded:
                maintainedProfileScreenComparable
                && maintainedIndependentConfirmationReplicationGrounded
                && profileComparisonCalibrationID != nil,
            plannedTrainingTokenPresentations:
                input.plannedTrainingTokenPresentations,
            plannedTrainingBlockCount:
                input.plannedTrainingBlockCount,
            plannedTrainingScheduleID:
                input.plannedTrainingScheduleID,
            plannedValidRowPresentations:
                input.plannedValidRowPresentations,
            plannedRefusalRowPresentations:
                input.plannedRefusalRowPresentations,
            plannedValidSemanticFamilyRowPresentations:
                input
                    .plannedValidSemanticFamilyRowPresentations,
            plannedRefusalSemanticFamilyRowPresentations:
                input
                    .plannedRefusalSemanticFamilyRowPresentations,
            plannedFullEvaluationNonPaddingTokenCount:
                input
                    .plannedFullEvaluationNonPaddingTokenCount,
            plannedFullEvaluationPromptTokenCount:
                input.plannedFullEvaluationPromptTokenCount,
            plannedFullEvaluationMaximumGeneratedTokenCount:
                input
                    .plannedFullEvaluationMaximumGeneratedTokenCount,
            plannedShardArtifactBytesUpperBound:
                input.plannedShardArtifactBytesUpperBound,
            maximumWallClockSeconds:
                input.maximumWallClockSeconds,
            adaptiveDiscoveryLearningRates:
                discoveryLearningRates,
            learningRateGridRationaleID:
                learningRateGridRationaleID,
            learningRateGridAnchorArtifactSHA256:
                learningRateGridAnchorArtifactSHA256,
            adaptiveReplicateSeeds: adaptiveSeeds,
            checkpointHeaderPlanningUpperBoundBytes:
                maximumCheckpointHeaderPlanningBytes,
            profileIOBenchmarks:
                input.profileIOBenchmarks.sorted {
                    $0.profileID < $1.profileID
                },
            profileAutoregressivePreflights:
                input.profileAutoregressivePreflights.sorted {
                    $0.profileID < $1.profileID
                },
            failedProfileTrials:
                orderedFailedProfileTrials,
            profileScreenMatrixComparable:
                maintainedProfileScreenComparable,
            architectureQualityCapacityWinnerAuthorized:
                false,
            functionalCanaryAuthorized:
                selectedDecision != nil && criticalLegsGrounded,
            broadLanguageClaimAuthorized: false,
            oneBillionScaleAuthorized:
                (selectedIndex ?? -1) >= 1,
            threeBillionScaleAuthorized:
                (selectedIndex ?? -1) >= 2,
            profiles: assessments,
            legs: legs
        )
    }
}
