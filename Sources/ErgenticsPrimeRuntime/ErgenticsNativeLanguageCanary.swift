import CryptoKit
import Foundation

/// Evidence authority for the first-party, random-initialized Prime text lane.
///
/// This authority deliberately refuses the earlier symbolic mechanics lineage.
/// A report must bind the fixed 512-token native byte tokenizer, one of the
/// maintained Engine scale profiles, a first-party corpus manifest, and a
/// Swift/MLX/Metal executor. A throughput probe is only an admission witness;
/// it is never interpreted as language capability.
public enum ErgenticsNativeLanguageCanary {
    public static let schemaVersion = "4"
    public static let familyID = "ergentics_prime_native_language_v1"
    public static let lineageID =
        "ergentics_prime_native_random_init_text_v1"
    public static let generationContractID =
        "greedy_native_bytes_eos_fixed_cap64_kv_v2"
    public static let executorArtifactFileName =
        "PrimeNativeLanguageSwiftCanary"
    public static let recommenderArtifactFileName =
        "PrimeNativeLanguageCanaryRecommend"
    public static let metalLibraryPrimaryFileName =
        "mlx.metallib"
    public static let metalLibraryFallbackFileName =
        "default.metallib"
    public static let metalLibraryBundleSearchAuditID =
        "bundle_main_all_bundles_mirror_audit_v1"
    public static let requiredBuildConfiguration = "release"
    public static let requiredPrecision = "float32"
    public static let probeTokenManifestFileName =
        "probe-token-manifest.json"
    public static let configurationArtifactFileName =
        "run-configuration.txt"
    public static let checkpointArtifactFileName =
        "checkpoint.safetensors"
    public static let trainingStageArtifactFileName =
        "training-stage.json"
    public static let evaluationArtifactDirectoryName =
        "evaluation-shards"
    public static let executorWallAccountingID =
        "cumulative_checkpoint_stage_executor_wall_v1"
    public static let maximumGenerationTokenDecisions = 64
    public static let promptGroupingKeyID =
        "prompt_byte_token_count_excluding_bos_v1"
    public static let allowedCompletionTokenIDs =
        [PrimeNativeByteTokenizer.endOfSequenceTokenID]
        + Array(PrimeNativeByteTokenizer.byteTokenRange)
    public static let allowedCompletionTokenSetSHA256: String = {
        let material = allowedCompletionTokenIDs
            .map(String.init)
            .joined(separator: "\n")
        return SHA256.hash(data: Data(material.utf8)).map {
            String(format: "%02x", $0)
        }.joined()
    }()
    public static let evaluationGenerationPhaseCount = 3
    public static let evaluationShardSize = 512
    public static let maximumEvaluationShardBytesPerRow = 16_384
    public static let maximumEvaluationShardEnvelopeBytes = 4_096
    public static let frozenSeeds = [1618, 2718, 3141]
    public static let minimumEvaluationRows: [Split: Int] = [
        .validation: 4_096,
        .combinationHoldout: 4_096,
        .outOfDistribution: 4_096,
        .mutation: 4_096,
        .abstention: 2_048,
    ]
    public static let minimumSemanticFamilyCount = 6

    /// The only row shape admitted by the model-generation boundary.
    ///
    /// Targets and verifier fields are deliberately unrepresentable here;
    /// they remain available only to the later independent regrade.
    public struct PromptOnlyEvaluationRow:
        Equatable, Sendable
    {
        public let rowID: String
        public let promptText: String
        public let promptGroupingKey: Int
        public let generationDecisionBudget: Int

        public init(rowID: String, promptText: String) {
            self.rowID = rowID
            self.promptText = promptText
            self.promptGroupingKey =
                PrimeNativeByteTokenizer.encode(promptText).count
            self.generationDecisionBudget =
                ErgenticsNativeLanguageCanary
                    .maximumGenerationTokenDecisions
        }
    }

    public static func observedFP32ParameterDTypesBound(
        modelParameterDTypes: [String],
        trainableParameterDTypes: [String]
    ) -> Bool {
        modelParameterDTypes == [requiredPrecision]
            && trainableParameterDTypes == [requiredPrecision]
    }

    public enum TrainingPersistencePolicy:
        String, Codable, Sendable
    {
        case profileProbeNoResume =
            "profile_probe_no_resume"
        case boundedDiagnosticNoOptimizerResume =
            "bounded_diagnostic_no_optimizer_resume"
        case exactOptimizerStateResume =
            "exact_optimizer_state_resume"
    }

    public enum Mode: String, Codable, Sendable {
        case profileProbe = "profile_probe"
        case fullCanary = "full_canary"
    }

    public enum Split: String, Codable, CaseIterable, Sendable {
        case validation
        case combinationHoldout = "combination_holdout"
        case outOfDistribution = "ood"
        case mutation
        case abstention
    }

    /// Corpus generation is deterministic but materializing all 150k rows is
    /// intentionally nontrivial. Cache the exact non-training authority rows
    /// once so repeated report regrades and three-seed consensus do not turn
    /// evidence verification into repeated corpus regeneration.
    private static let authorityEvaluationRows =
        ErgenticsPrimeNativeTextCorpus.allRows()
            .filter {
                Set(Split.allCases.map(\.rawValue))
                    .contains($0.split)
            }
            .sorted { $0.rowID < $1.rowID }
    private static let authoritySelectionRowsByID = Dictionary(
        uniqueKeysWithValues:
            (
                ErgenticsPrimeNativeTextCorpus.rows(
                    for: .validation
                )
                    + ErgenticsPrimeNativeTextCorpus.rows(
                        for: .refusalValidation
                    )
            ).map { ($0.rowID, $0) }
    )

    /// Conservative, contract-derived upper bounds used for preflight
    /// projection. The executor enforces the same shard byte ceiling.
    public static var plannedFullEvaluationRowCount: Int64 {
        Int64(authorityEvaluationRows.count)
    }

    public static var plannedFullEvaluationContextLengthGroupCount: Int {
        Set(
            authorityEvaluationRows.map {
                $0.promptTokenCount - 1
            }
        ).count
    }

    public static var plannedFullEvaluationOrderedRowIDsSHA256: String {
        let material = authorityEvaluationRows.map(\.rowID)
            .joined(separator: "\n")
        return SHA256.hash(data: Data(material.utf8)).map {
            String(format: "%02x", $0)
        }.joined()
    }

    public static var plannedFullEvaluationContextLengthGroupingSHA256:
        String
    {
        let material = authorityEvaluationRows.sorted {
            let leftLength = $0.promptTokenCount - 1
            let rightLength = $1.promptTokenCount - 1
            return leftLength == rightLength
                ? $0.rowID < $1.rowID
                : leftLength < rightLength
        }.map {
            "\($0.promptTokenCount - 1)|\($0.rowID)"
        }.joined(separator: "\n")
        return SHA256.hash(data: Data(material.utf8)).map {
            String(format: "%02x", $0)
        }.joined()
    }

    public static var plannedFullEvaluationPromptTokenCount: Int64 {
        Int64(evaluationGenerationPhaseCount)
            * authorityEvaluationRows.reduce(Int64(0)) {
                $0 + Int64($1.promptTokenCount)
            }
    }

    public static var plannedFullEvaluationMaximumGeneratedTokenCount:
        Int64
    {
        Int64(evaluationGenerationPhaseCount)
            * Int64(authorityEvaluationRows.count)
            * Int64(maximumGenerationTokenDecisions)
    }

    public static var plannedFullEvaluationNonPaddingTokenCount: Int64 {
        plannedFullEvaluationPromptTokenCount
            + plannedFullEvaluationMaximumGeneratedTokenCount
    }

    public static var plannedShardArtifactBytesUpperBound: Int64 {
        let rowCount = authorityEvaluationRows.count
        let shardCount =
            (rowCount + evaluationShardSize - 1)
                / evaluationShardSize
        let onePhase =
            Int64(rowCount)
                * Int64(maximumEvaluationShardBytesPerRow)
                + Int64(shardCount)
                    * Int64(maximumEvaluationShardEnvelopeBytes)
        return Int64(evaluationGenerationPhaseCount) * onePhase
    }

    public struct ProfileBinding: Codable, Equatable, Sendable {
        public let profileID: String
        public let vocabularySize: Int
        public let maximumSequenceLength: Int
        public let expectedParameterCount: Int64
        public let observedParameterCount: Int64
        public let observedTrainableParameterCount: Int64

        public init(
            profileID: String,
            vocabularySize: Int,
            maximumSequenceLength: Int,
            expectedParameterCount: Int64,
            observedParameterCount: Int64,
            observedTrainableParameterCount: Int64
        ) {
            self.profileID = profileID
            self.vocabularySize = vocabularySize
            self.maximumSequenceLength = maximumSequenceLength
            self.expectedParameterCount = expectedParameterCount
            self.observedParameterCount = observedParameterCount
            self.observedTrainableParameterCount =
                observedTrainableParameterCount
        }

        enum CodingKeys: String, CodingKey {
            case profileID = "profile_id"
            case vocabularySize = "vocabulary_size"
            case maximumSequenceLength = "maximum_sequence_length"
            case expectedParameterCount = "expected_parameter_count"
            case observedParameterCount = "observed_parameter_count"
            case observedTrainableParameterCount =
                "observed_trainable_parameter_count"
        }
    }

    public struct TokenizerBinding: Codable, Equatable, Sendable {
        public let tokenizerID: String
        public let manifestSHA256: String
        public let vocabularySize: Int
        public let deterministicReplayPassed: Bool
        public let independentFoundationReplayPassed: Bool

        public init(
            tokenizerID: String,
            manifestSHA256: String,
            vocabularySize: Int,
            deterministicReplayPassed: Bool,
            independentFoundationReplayPassed: Bool
        ) {
            self.tokenizerID = tokenizerID
            self.manifestSHA256 = manifestSHA256
            self.vocabularySize = vocabularySize
            self.deterministicReplayPassed =
                deterministicReplayPassed
            self.independentFoundationReplayPassed =
                independentFoundationReplayPassed
        }

        enum CodingKeys: String, CodingKey {
            case tokenizerID = "tokenizer_id"
            case manifestSHA256 = "manifest_sha256"
            case vocabularySize = "vocabulary_size"
            case deterministicReplayPassed =
                "deterministic_replay_passed"
            case independentFoundationReplayPassed =
                "independent_foundation_replay_passed"
        }
    }

    public struct CorpusBinding: Codable, Equatable, Sendable {
        public let corpusID: String
        public let manifestSHA256: String
        public let manifestArtifactSHA256: String
        public let manifestFileName: String
        public let maximumEvaluationPromptTokenCount: Int
        public let maximumEvaluationTargetTokenCount: Int
        public let overCapTargetRowIDs: [String]
        public let generationContextLength: Int
        public let insufficientGenerationContextRowIDs: [String]
        public let firstPartyRightsBound: Bool
        public let exactObjectHashesPresent: Bool
        public let disjointSplitsVerified: Bool
        public let probeTokenManifestSHA256: String
        public let probeTokenManifestArtifactSHA256: String
        public let probeTokenManifestFileName: String
        public let probeTokenCount: Int
        public let trainingTokenInstances: Int
        public let deduplicatedTrainingTokenInstances: Int
        public let trainingRowCount: Int
        public let validTrainingRowCount: Int
        public let refusalTrainingRowCount: Int
        public let refusalSelectionValidationRowCount: Int
        public let finalAbstentionRowCount: Int
        public let refusalCurriculumBound: Bool
        public let semanticCombinationCount: Int
        public let expectedEvaluationRows: [Split: Int]
        public let expectedEvaluationRowSHA256: [String: String]
        public let expectedEvaluationContractSHA256:
            [String: String]
        public let expectedSemanticFamilyRows:
            [Split: [String: Int]]

        public init(
            corpusID: String,
            manifestSHA256: String,
            manifestArtifactSHA256: String,
            manifestFileName: String,
            maximumEvaluationPromptTokenCount: Int,
            maximumEvaluationTargetTokenCount: Int,
            overCapTargetRowIDs: [String],
            generationContextLength: Int,
            insufficientGenerationContextRowIDs: [String],
            firstPartyRightsBound: Bool,
            exactObjectHashesPresent: Bool,
            disjointSplitsVerified: Bool,
            probeTokenManifestSHA256: String,
            probeTokenManifestArtifactSHA256: String,
            probeTokenManifestFileName: String,
            probeTokenCount: Int,
            trainingTokenInstances: Int,
            deduplicatedTrainingTokenInstances: Int,
            trainingRowCount: Int,
            validTrainingRowCount: Int = 131_072,
            refusalTrainingRowCount: Int = 4_096,
            refusalSelectionValidationRowCount: Int = 2_048,
            finalAbstentionRowCount: Int = 2_048,
            refusalCurriculumBound: Bool = true,
            semanticCombinationCount: Int,
            expectedEvaluationRows: [Split: Int],
            expectedEvaluationRowSHA256: [String: String],
            expectedEvaluationContractSHA256: [String: String],
            expectedSemanticFamilyRows: [Split: [String: Int]]
        ) {
            self.corpusID = corpusID
            self.manifestSHA256 = manifestSHA256
            self.manifestArtifactSHA256 =
                manifestArtifactSHA256
            self.manifestFileName = manifestFileName
            self.maximumEvaluationPromptTokenCount =
                maximumEvaluationPromptTokenCount
            self.maximumEvaluationTargetTokenCount =
                maximumEvaluationTargetTokenCount
            self.overCapTargetRowIDs = overCapTargetRowIDs
            self.generationContextLength =
                generationContextLength
            self.insufficientGenerationContextRowIDs =
                insufficientGenerationContextRowIDs
            self.firstPartyRightsBound = firstPartyRightsBound
            self.exactObjectHashesPresent = exactObjectHashesPresent
            self.disjointSplitsVerified = disjointSplitsVerified
            self.probeTokenManifestSHA256 =
                probeTokenManifestSHA256
            self.probeTokenManifestArtifactSHA256 =
                probeTokenManifestArtifactSHA256
            self.probeTokenManifestFileName =
                probeTokenManifestFileName
            self.probeTokenCount = probeTokenCount
            self.trainingTokenInstances = trainingTokenInstances
            self.deduplicatedTrainingTokenInstances =
                deduplicatedTrainingTokenInstances
            self.trainingRowCount = trainingRowCount
            self.validTrainingRowCount = validTrainingRowCount
            self.refusalTrainingRowCount =
                refusalTrainingRowCount
            self.refusalSelectionValidationRowCount =
                refusalSelectionValidationRowCount
            self.finalAbstentionRowCount =
                finalAbstentionRowCount
            self.refusalCurriculumBound = refusalCurriculumBound
            self.semanticCombinationCount =
                semanticCombinationCount
            self.expectedEvaluationRows = expectedEvaluationRows
            self.expectedEvaluationRowSHA256 =
                expectedEvaluationRowSHA256
            self.expectedEvaluationContractSHA256 =
                expectedEvaluationContractSHA256
            self.expectedSemanticFamilyRows =
                expectedSemanticFamilyRows
        }

        enum CodingKeys: String, CodingKey {
            case corpusID = "corpus_id"
            case manifestSHA256 = "manifest_sha256"
            case manifestArtifactSHA256 =
                "manifest_artifact_sha256"
            case manifestFileName = "manifest_file_name"
            case maximumEvaluationPromptTokenCount =
                "maximum_evaluation_prompt_token_count"
            case maximumEvaluationTargetTokenCount =
                "maximum_evaluation_target_token_count"
            case overCapTargetRowIDs =
                "over_cap_target_row_ids"
            case generationContextLength =
                "generation_context_length"
            case insufficientGenerationContextRowIDs =
                "insufficient_generation_context_row_ids"
            case firstPartyRightsBound = "first_party_rights_bound"
            case exactObjectHashesPresent =
                "exact_object_hashes_present"
            case disjointSplitsVerified =
                "disjoint_splits_verified"
            case probeTokenManifestSHA256 =
                "probe_token_manifest_sha256"
            case probeTokenManifestArtifactSHA256 =
                "probe_token_manifest_artifact_sha256"
            case probeTokenManifestFileName =
                "probe_token_manifest_file_name"
            case probeTokenCount = "probe_token_count"
            case trainingTokenInstances =
                "training_token_instances"
            case deduplicatedTrainingTokenInstances =
                "deduplicated_training_token_instances"
            case trainingRowCount = "training_row_count"
            case validTrainingRowCount =
                "valid_training_row_count"
            case refusalTrainingRowCount =
                "refusal_training_row_count"
            case refusalSelectionValidationRowCount =
                "refusal_selection_validation_row_count"
            case finalAbstentionRowCount =
                "final_abstention_row_count"
            case refusalCurriculumBound =
                "refusal_curriculum_bound"
            case semanticCombinationCount =
                "semantic_combination_count"
            case expectedEvaluationRows =
                "expected_evaluation_rows"
            case expectedEvaluationRowSHA256 =
                "expected_evaluation_row_sha256"
            case expectedEvaluationContractSHA256 =
                "expected_evaluation_contract_sha256"
            case expectedSemanticFamilyRows =
                "expected_semantic_family_rows"
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
        public let optimizerImplementation: String
        public let deviceType: String
        public let deviceDescription: String
        public let mlxSwiftVersion: String
        public let mlxSwiftExamplesVersion: String
        public let mlxSwiftLicenseID: String
        public let mlxSwiftExamplesLicenseID: String
        public let packageResolvedSHA256: String
        public let executorArtifactSHA256: String
        public let executorArtifactFileName: String
        public let recommenderArtifactSHA256: String
        public let recommenderArtifactFileName: String
        public let metalLibraryArtifactSHA256: String
        public let metalLibraryArtifactByteCount: Int64
        public let metalLibraryPrimaryFileName: String
        public let metalLibraryFallbackFileName: String
        public let metalLibraryBundleSearchAuditID: String
        public let metalLibraryBundleSearchBaseCount: Int
        public let metalLibraryVerifiedBundleMirrorCount: Int
        public let metalLibraryDivergentBundleCandidateCount: Int
        public let metalLibrarySourceMLXSwiftRevision: String
        public let observedModelParameterDTypes: [String]
        public let observedTrainableParameterDTypes: [String]
        public let externalPackagesSupplyExecutionPrimitivesOnly: Bool
        public let externalPackagesSupplyTextTokenizerOrWeights: Bool
        public let maintainedPrimitivesOnly: Bool
        public let customTransformerCode: Bool
        public let customMetalKernels: Bool
        public let randomInitialization: Bool
        public let importedBaseWeights: Bool
        public let pythonProducedEvidence: Bool

        public init(
            executionLanguage: String,
            buildConfiguration: String,
            precision: String,
            framework: String,
            modelImplementation: String,
            optimizerImplementation: String,
            deviceType: String,
            deviceDescription: String,
            mlxSwiftVersion: String,
            mlxSwiftExamplesVersion: String,
            mlxSwiftLicenseID: String,
            mlxSwiftExamplesLicenseID: String,
            packageResolvedSHA256: String,
            executorArtifactSHA256: String,
            executorArtifactFileName: String,
            recommenderArtifactSHA256: String,
            recommenderArtifactFileName: String,
            metalLibraryArtifactSHA256: String,
            metalLibraryArtifactByteCount: Int64,
            metalLibraryPrimaryFileName: String,
            metalLibraryFallbackFileName: String,
            metalLibraryBundleSearchAuditID: String,
            metalLibraryBundleSearchBaseCount: Int,
            metalLibraryVerifiedBundleMirrorCount: Int,
            metalLibraryDivergentBundleCandidateCount: Int,
            metalLibrarySourceMLXSwiftRevision: String,
            observedModelParameterDTypes: [String],
            observedTrainableParameterDTypes: [String],
            externalPackagesSupplyExecutionPrimitivesOnly: Bool,
            externalPackagesSupplyTextTokenizerOrWeights: Bool,
            maintainedPrimitivesOnly: Bool,
            customTransformerCode: Bool,
            customMetalKernels: Bool,
            randomInitialization: Bool,
            importedBaseWeights: Bool,
            pythonProducedEvidence: Bool
        ) {
            self.executionLanguage = executionLanguage
            self.buildConfiguration = buildConfiguration
            self.precision = precision
            self.framework = framework
            self.modelImplementation = modelImplementation
            self.optimizerImplementation = optimizerImplementation
            self.deviceType = deviceType
            self.deviceDescription = deviceDescription
            self.mlxSwiftVersion = mlxSwiftVersion
            self.mlxSwiftExamplesVersion =
                mlxSwiftExamplesVersion
            self.mlxSwiftLicenseID = mlxSwiftLicenseID
            self.mlxSwiftExamplesLicenseID =
                mlxSwiftExamplesLicenseID
            self.packageResolvedSHA256 = packageResolvedSHA256
            self.executorArtifactSHA256 =
                executorArtifactSHA256
            self.executorArtifactFileName =
                executorArtifactFileName
            self.recommenderArtifactSHA256 =
                recommenderArtifactSHA256
            self.recommenderArtifactFileName =
                recommenderArtifactFileName
            self.metalLibraryArtifactSHA256 =
                metalLibraryArtifactSHA256
            self.metalLibraryArtifactByteCount =
                metalLibraryArtifactByteCount
            self.metalLibraryPrimaryFileName =
                metalLibraryPrimaryFileName
            self.metalLibraryFallbackFileName =
                metalLibraryFallbackFileName
            self.metalLibraryBundleSearchAuditID =
                metalLibraryBundleSearchAuditID
            self.metalLibraryBundleSearchBaseCount =
                metalLibraryBundleSearchBaseCount
            self.metalLibraryVerifiedBundleMirrorCount =
                metalLibraryVerifiedBundleMirrorCount
            self.metalLibraryDivergentBundleCandidateCount =
                metalLibraryDivergentBundleCandidateCount
            self.metalLibrarySourceMLXSwiftRevision =
                metalLibrarySourceMLXSwiftRevision
            self.observedModelParameterDTypes =
                observedModelParameterDTypes
            self.observedTrainableParameterDTypes =
                observedTrainableParameterDTypes
            self.externalPackagesSupplyExecutionPrimitivesOnly =
                externalPackagesSupplyExecutionPrimitivesOnly
            self.externalPackagesSupplyTextTokenizerOrWeights =
                externalPackagesSupplyTextTokenizerOrWeights
            self.maintainedPrimitivesOnly =
                maintainedPrimitivesOnly
            self.customTransformerCode = customTransformerCode
            self.customMetalKernels = customMetalKernels
            self.randomInitialization = randomInitialization
            self.importedBaseWeights = importedBaseWeights
            self.pythonProducedEvidence = pythonProducedEvidence
        }

        enum CodingKeys: String, CodingKey {
            case executionLanguage = "execution_language"
            case buildConfiguration = "build_configuration"
            case precision
            case framework
            case modelImplementation = "model_implementation"
            case optimizerImplementation =
                "optimizer_implementation"
            case deviceType = "device_type"
            case deviceDescription = "device_description"
            case mlxSwiftVersion = "mlx_swift_version"
            case mlxSwiftExamplesVersion =
                "mlx_swift_examples_version"
            case mlxSwiftLicenseID = "mlx_swift_license_id"
            case mlxSwiftExamplesLicenseID =
                "mlx_swift_examples_license_id"
            case packageResolvedSHA256 =
                "package_resolved_sha256"
            case executorArtifactSHA256 =
                "executor_artifact_sha256"
            case executorArtifactFileName =
                "executor_artifact_file_name"
            case recommenderArtifactSHA256 =
                "recommender_artifact_sha256"
            case recommenderArtifactFileName =
                "recommender_artifact_file_name"
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
            case externalPackagesSupplyExecutionPrimitivesOnly =
                "external_packages_supply_execution_primitives_only"
            case externalPackagesSupplyTextTokenizerOrWeights =
                "external_packages_supply_text_tokenizer_or_weights"
            case maintainedPrimitivesOnly =
                "maintained_primitives_only"
            case customTransformerCode =
                "custom_transformer_code"
            case customMetalKernels = "custom_metal_kernels"
            case randomInitialization = "random_initialization"
            case importedBaseWeights = "imported_base_weights"
            case pythonProducedEvidence = "python_produced_evidence"
        }
    }

    /// Row-unit held-out evidence retained in the report so recommendation
    /// code can independently recompute every aggregate instead of trusting
    /// executor-supplied summary statistics.
    public struct HeldoutLossRow: Codable, Equatable, Sendable {
        public let rowID: String
        public let rowSHA256: String
        public let selectionSplitID: String
        public let targetClass: String
        public let semanticFamily: String
        public let targetTokenCount: Int
        public let nonPaddingTokenCount: Int
        public let crossEntropyBefore: Double
        public let crossEntropyAfter: Double

        public init(
            rowID: String,
            rowSHA256: String,
            selectionSplitID: String = "validation",
            targetClass: String = "valid_completion",
            semanticFamily: String,
            targetTokenCount: Int,
            nonPaddingTokenCount: Int,
            crossEntropyBefore: Double,
            crossEntropyAfter: Double
        ) {
            self.rowID = rowID
            self.rowSHA256 = rowSHA256
            self.selectionSplitID = selectionSplitID
            self.targetClass = targetClass
            self.semanticFamily = semanticFamily
            self.targetTokenCount = targetTokenCount
            self.nonPaddingTokenCount = nonPaddingTokenCount
            self.crossEntropyBefore = crossEntropyBefore
            self.crossEntropyAfter = crossEntropyAfter
        }

        enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case rowSHA256 = "row_sha256"
            case selectionSplitID = "selection_split_id"
            case targetClass = "target_class"
            case semanticFamily = "semantic_family"
            case targetTokenCount = "target_token_count"
            case nonPaddingTokenCount = "non_padding_token_count"
            case crossEntropyBefore = "cross_entropy_before"
            case crossEntropyAfter = "cross_entropy_after"
        }
    }

    public struct TrainingEvidence: Codable, Equatable, Sendable {
        public let requestedSteps: Int
        public let completedSteps: Int
        public let probePurposeID: String
        public let scheduleID: String
        public let distinctScheduledRowCount: Int
        public let scheduledSemanticFamilyRows: [String: Int]
        public let scheduledValidRowCount: Int
        public let scheduledRefusalRowCount: Int
        public let scheduledValidSemanticFamilyRows: [String: Int]
        public let scheduledRefusalSemanticFamilyRows: [String: Int]
        public let scheduledRefusalReasonRows: [String: Int]
        public let scheduledRefusalReasonScheduleSHA256: String
        public let heldoutRowCount: Int
        public let heldoutValidRowCount: Int
        public let heldoutRefusalRowCount: Int
        public let heldoutValidSemanticFamilyRows: [String: Int]
        public let heldoutRefusalSemanticFamilyRows: [String: Int]
        public let heldoutRefusalReasonRows: [String: Int]
        public let heldoutRefusalReasonScheduleSHA256: String
        public let selectionValidationSplitIDs: [String]
        public let heldoutScheduleSHA256: String
        public let comparisonManifestSHA256: String
        public let trainingScheduleManifestSHA256: String
        public let trainingHeldoutRowHashIntersectionCount: Int
        public let heldoutTargetTokenCount: Int
        public let heldoutValidTargetTokenCount: Int
        public let heldoutRefusalTargetTokenCount: Int
        public let heldoutEvaluationNonPaddingTokenCount: Int
        public let heldoutEvaluationElapsedSeconds: Double
        public let heldoutCrossEntropyBefore: Double
        public let heldoutCrossEntropyAfter: Double
        public let heldoutValidCrossEntropyBefore: Double
        public let heldoutValidCrossEntropyAfter: Double
        public let heldoutRefusalCrossEntropyBefore: Double
        public let heldoutRefusalCrossEntropyAfter: Double
        public let heldoutCrossEntropyStandardError: Double
        public let heldoutCrossEntropyStandardErrorMethodID: String
        public let heldoutFamilyCrossEntropyBefore: [String: Double]
        public let heldoutFamilyCrossEntropyAfter: [String: Double]
        public let heldoutLossRows: [HeldoutLossRow]
        public let measurementWarmupSteps: Int
        public let timedSteps: Int
        public let batchSize: Int
        public let gradientAccumulationSteps: Int
        public let effectiveBatchSize: Int
        public let measuredSequenceLength: Int
        public let evaluationBatchSize: Int
        public let evaluationShardSize: Int
        public let processedPaddedTokenPositions: Int
        public let plannedTrainingTokenPresentations: Int
        public let trainedTokens: Int
        public let elapsedSeconds: Double
        public let coldStartElapsedSeconds: Double
        public let measurementWarmupElapsedSeconds: Double
        public let timedElapsedSeconds: Double
        public let timedNonPaddingTokens: Int
        public let tokensPerSecond: Double
        public let peakMemoryBytes: Int64
        public let learningRate: Double
        public let learningRateScheduleID: String
        public let optimizerImplementation: String
        public let adamBeta1: Double
        public let adamBeta2: Double
        public let adamEpsilon: Double
        public let decoupledWeightDecay: Bool
        public let gradientClipMode: String
        public let lossReduction: String
        public let warmupSteps: Int
        public let minimumLearningRate: Double
        public let weightDecay: Double
        public let precision: String
        public let gradientClipNorm: Double?
        public let fullWeightTraining: Bool
        public let shiftedCausalLanguageModelLoss: Bool
        public let promptTokensMasked: Bool
        public let targetTokenWeightedEffectiveBatchLoss: Bool
        public let answerTokensContributed: Int
        public let firstGradientNorm: Double
        public let firstClippedGradientNorm: Double
        public let firstWeightUpdateNorm: Double
        public let causalPrefixMaximumLogitDelta: Double
        public let suffixEffectMaximumLogitDelta: Double
        public let logitsFinite: Bool
        public let repeatedInferenceMaximumLogitDelta: Double
        public let cachedUncachedMaximumLogitDelta: Double
        public let cachedUncachedGreedyTokenParity: Bool
        public let cachedUncachedMultiStepMaximumLogitDelta: Double
        public let cachedUncachedMultiStepGreedyTokenParity: Bool
        public let cachedUncachedMultiStepComparedDecisionCount: Int
        public let cachedUncachedMultiStepUnevenEOS: Bool
        public let initializationFingerprintSHA256: String
        public let sameSeedInitializationReplayExact: Bool
        public let initialLoss: Double
        public let finalLoss: Double
        public let losses: [Double]
        public let hyperparameterSearchID: String
        public let learningRateDiscoverySeed: Int
        public let replicateID: String
        public let declaredLearningRateGrid: [Double]
        public let declaredReplicateSeeds: [Int]
        public let configurationArtifactSHA256: String
        public let configurationArtifactFileName: String
        public let executorWallAccountingID: String
        public let resumedFromTrainingStage: Bool
        public let priorExecutorWallSeconds: Double
        public let checkpointStageExecutorWallSeconds: Double
        public let preexistingEvaluationArtifactNamesAtInvocationStart:
            [String]
        public let declaredMaximumExecutorWallSeconds: Double
        /// Legacy JSON name retained for schema continuity. This clock stops
        /// immediately before final report encoding/write. For a resumed full
        /// diagnostic it is the persisted checkpoint-stage time plus the
        /// current invocation time, not a reset per-invocation clock. The
        /// runner's external hard alarm remains authoritative for final
        /// emission and whole-process enforcement.
        public let measuredTotalExecutorWallSeconds: Double
        public let persistencePolicy: TrainingPersistencePolicy
        public let interruptedTrajectoryReplayExact: Bool

        public init(
            requestedSteps: Int,
            completedSteps: Int,
            probePurposeID: String,
            scheduleID: String,
            distinctScheduledRowCount: Int,
            scheduledSemanticFamilyRows: [String: Int],
            scheduledValidRowCount: Int,
            scheduledRefusalRowCount: Int,
            scheduledValidSemanticFamilyRows: [String: Int],
            scheduledRefusalSemanticFamilyRows: [String: Int],
            scheduledRefusalReasonRows: [String: Int],
            scheduledRefusalReasonScheduleSHA256: String,
            heldoutRowCount: Int,
            heldoutValidRowCount: Int,
            heldoutRefusalRowCount: Int,
            heldoutValidSemanticFamilyRows: [String: Int],
            heldoutRefusalSemanticFamilyRows: [String: Int],
            heldoutRefusalReasonRows: [String: Int],
            heldoutRefusalReasonScheduleSHA256: String,
            selectionValidationSplitIDs: [String],
            heldoutScheduleSHA256: String,
            comparisonManifestSHA256: String,
            trainingScheduleManifestSHA256: String,
            trainingHeldoutRowHashIntersectionCount: Int,
            heldoutTargetTokenCount: Int,
            heldoutValidTargetTokenCount: Int,
            heldoutRefusalTargetTokenCount: Int,
            heldoutEvaluationNonPaddingTokenCount: Int,
            heldoutEvaluationElapsedSeconds: Double,
            heldoutCrossEntropyBefore: Double,
            heldoutCrossEntropyAfter: Double,
            heldoutValidCrossEntropyBefore: Double,
            heldoutValidCrossEntropyAfter: Double,
            heldoutRefusalCrossEntropyBefore: Double,
            heldoutRefusalCrossEntropyAfter: Double,
            heldoutCrossEntropyStandardError: Double,
            heldoutCrossEntropyStandardErrorMethodID: String,
            heldoutFamilyCrossEntropyBefore: [String: Double],
            heldoutFamilyCrossEntropyAfter: [String: Double],
            heldoutLossRows: [HeldoutLossRow],
            measurementWarmupSteps: Int,
            timedSteps: Int,
            batchSize: Int,
            gradientAccumulationSteps: Int,
            effectiveBatchSize: Int,
            measuredSequenceLength: Int,
            evaluationBatchSize: Int = 32,
            evaluationShardSize: Int =
                ErgenticsNativeLanguageCanary.evaluationShardSize,
            processedPaddedTokenPositions: Int,
            plannedTrainingTokenPresentations: Int,
            trainedTokens: Int,
            elapsedSeconds: Double,
            coldStartElapsedSeconds: Double,
            measurementWarmupElapsedSeconds: Double,
            timedElapsedSeconds: Double,
            timedNonPaddingTokens: Int,
            tokensPerSecond: Double,
            peakMemoryBytes: Int64,
            learningRate: Double,
            learningRateScheduleID: String,
            optimizerImplementation: String,
            adamBeta1: Double,
            adamBeta2: Double,
            adamEpsilon: Double,
            decoupledWeightDecay: Bool,
            gradientClipMode: String,
            lossReduction: String,
            warmupSteps: Int,
            minimumLearningRate: Double,
            weightDecay: Double,
            precision: String,
            gradientClipNorm: Double?,
            fullWeightTraining: Bool,
            shiftedCausalLanguageModelLoss: Bool,
            promptTokensMasked: Bool,
            targetTokenWeightedEffectiveBatchLoss: Bool,
            answerTokensContributed: Int,
            firstGradientNorm: Double,
            firstClippedGradientNorm: Double,
            firstWeightUpdateNorm: Double,
            causalPrefixMaximumLogitDelta: Double,
            suffixEffectMaximumLogitDelta: Double,
            logitsFinite: Bool,
            repeatedInferenceMaximumLogitDelta: Double,
            cachedUncachedMaximumLogitDelta: Double,
            cachedUncachedGreedyTokenParity: Bool,
            cachedUncachedMultiStepMaximumLogitDelta: Double = 0,
            cachedUncachedMultiStepGreedyTokenParity: Bool = true,
            cachedUncachedMultiStepComparedDecisionCount: Int = 6,
            cachedUncachedMultiStepUnevenEOS: Bool = true,
            initializationFingerprintSHA256: String,
            sameSeedInitializationReplayExact: Bool,
            initialLoss: Double,
            finalLoss: Double,
            losses: [Double],
            hyperparameterSearchID: String,
            learningRateDiscoverySeed: Int,
            replicateID: String,
            declaredLearningRateGrid: [Double],
            declaredReplicateSeeds: [Int],
            configurationArtifactSHA256: String,
            configurationArtifactFileName: String,
            executorWallAccountingID: String =
                ErgenticsNativeLanguageCanary
                    .executorWallAccountingID,
            resumedFromTrainingStage: Bool = false,
            priorExecutorWallSeconds: Double = 0,
            checkpointStageExecutorWallSeconds: Double = 0,
            preexistingEvaluationArtifactNamesAtInvocationStart:
                [String] = [],
            declaredMaximumExecutorWallSeconds: Double = 1_800,
            measuredTotalExecutorWallSeconds: Double = 1,
            persistencePolicy: TrainingPersistencePolicy =
                .profileProbeNoResume,
            interruptedTrajectoryReplayExact: Bool = false
        ) {
            self.requestedSteps = requestedSteps
            self.completedSteps = completedSteps
            self.probePurposeID = probePurposeID
            self.scheduleID = scheduleID
            self.distinctScheduledRowCount =
                distinctScheduledRowCount
            self.scheduledSemanticFamilyRows =
                scheduledSemanticFamilyRows
            self.scheduledValidRowCount =
                scheduledValidRowCount
            self.scheduledRefusalRowCount =
                scheduledRefusalRowCount
            self.scheduledValidSemanticFamilyRows =
                scheduledValidSemanticFamilyRows
            self.scheduledRefusalSemanticFamilyRows =
                scheduledRefusalSemanticFamilyRows
            self.scheduledRefusalReasonRows =
                scheduledRefusalReasonRows
            self.scheduledRefusalReasonScheduleSHA256 =
                scheduledRefusalReasonScheduleSHA256
            self.heldoutRowCount = heldoutRowCount
            self.heldoutValidRowCount = heldoutValidRowCount
            self.heldoutRefusalRowCount =
                heldoutRefusalRowCount
            self.heldoutValidSemanticFamilyRows =
                heldoutValidSemanticFamilyRows
            self.heldoutRefusalSemanticFamilyRows =
                heldoutRefusalSemanticFamilyRows
            self.heldoutRefusalReasonRows =
                heldoutRefusalReasonRows
            self.heldoutRefusalReasonScheduleSHA256 =
                heldoutRefusalReasonScheduleSHA256
            self.selectionValidationSplitIDs =
                selectionValidationSplitIDs
            self.heldoutScheduleSHA256 =
                heldoutScheduleSHA256
            self.comparisonManifestSHA256 =
                comparisonManifestSHA256
            self.trainingScheduleManifestSHA256 =
                trainingScheduleManifestSHA256
            self.trainingHeldoutRowHashIntersectionCount =
                trainingHeldoutRowHashIntersectionCount
            self.heldoutTargetTokenCount =
                heldoutTargetTokenCount
            self.heldoutValidTargetTokenCount =
                heldoutValidTargetTokenCount
            self.heldoutRefusalTargetTokenCount =
                heldoutRefusalTargetTokenCount
            self.heldoutEvaluationNonPaddingTokenCount =
                heldoutEvaluationNonPaddingTokenCount
            self.heldoutEvaluationElapsedSeconds =
                heldoutEvaluationElapsedSeconds
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
            self.heldoutCrossEntropyStandardErrorMethodID =
                heldoutCrossEntropyStandardErrorMethodID
            self.heldoutFamilyCrossEntropyBefore =
                heldoutFamilyCrossEntropyBefore
            self.heldoutFamilyCrossEntropyAfter =
                heldoutFamilyCrossEntropyAfter
            self.heldoutLossRows = heldoutLossRows
            self.measurementWarmupSteps =
                measurementWarmupSteps
            self.timedSteps = timedSteps
            self.batchSize = batchSize
            self.gradientAccumulationSteps =
                gradientAccumulationSteps
            self.effectiveBatchSize = effectiveBatchSize
            self.measuredSequenceLength = measuredSequenceLength
            self.evaluationBatchSize = evaluationBatchSize
            self.evaluationShardSize = evaluationShardSize
            self.processedPaddedTokenPositions =
                processedPaddedTokenPositions
            self.plannedTrainingTokenPresentations =
                plannedTrainingTokenPresentations
            self.trainedTokens = trainedTokens
            self.elapsedSeconds = elapsedSeconds
            self.coldStartElapsedSeconds =
                coldStartElapsedSeconds
            self.measurementWarmupElapsedSeconds =
                measurementWarmupElapsedSeconds
            self.timedElapsedSeconds = timedElapsedSeconds
            self.timedNonPaddingTokens =
                timedNonPaddingTokens
            self.tokensPerSecond = tokensPerSecond
            self.peakMemoryBytes = peakMemoryBytes
            self.learningRate = learningRate
            self.learningRateScheduleID = learningRateScheduleID
            self.optimizerImplementation =
                optimizerImplementation
            self.adamBeta1 = adamBeta1
            self.adamBeta2 = adamBeta2
            self.adamEpsilon = adamEpsilon
            self.decoupledWeightDecay = decoupledWeightDecay
            self.gradientClipMode = gradientClipMode
            self.lossReduction = lossReduction
            self.warmupSteps = warmupSteps
            self.minimumLearningRate = minimumLearningRate
            self.weightDecay = weightDecay
            self.precision = precision
            self.gradientClipNorm = gradientClipNorm
            self.fullWeightTraining = fullWeightTraining
            self.shiftedCausalLanguageModelLoss =
                shiftedCausalLanguageModelLoss
            self.promptTokensMasked = promptTokensMasked
            self.targetTokenWeightedEffectiveBatchLoss =
                targetTokenWeightedEffectiveBatchLoss
            self.answerTokensContributed = answerTokensContributed
            self.firstGradientNorm = firstGradientNorm
            self.firstClippedGradientNorm =
                firstClippedGradientNorm
            self.firstWeightUpdateNorm = firstWeightUpdateNorm
            self.causalPrefixMaximumLogitDelta =
                causalPrefixMaximumLogitDelta
            self.suffixEffectMaximumLogitDelta =
                suffixEffectMaximumLogitDelta
            self.logitsFinite = logitsFinite
            self.repeatedInferenceMaximumLogitDelta =
                repeatedInferenceMaximumLogitDelta
            self.cachedUncachedMaximumLogitDelta =
                cachedUncachedMaximumLogitDelta
            self.cachedUncachedGreedyTokenParity =
                cachedUncachedGreedyTokenParity
            self.cachedUncachedMultiStepMaximumLogitDelta =
                cachedUncachedMultiStepMaximumLogitDelta
            self.cachedUncachedMultiStepGreedyTokenParity =
                cachedUncachedMultiStepGreedyTokenParity
            self.cachedUncachedMultiStepComparedDecisionCount =
                cachedUncachedMultiStepComparedDecisionCount
            self.cachedUncachedMultiStepUnevenEOS =
                cachedUncachedMultiStepUnevenEOS
            self.initializationFingerprintSHA256 =
                initializationFingerprintSHA256
            self.sameSeedInitializationReplayExact =
                sameSeedInitializationReplayExact
            self.initialLoss = initialLoss
            self.finalLoss = finalLoss
            self.losses = losses
            self.hyperparameterSearchID =
                hyperparameterSearchID
            self.learningRateDiscoverySeed =
                learningRateDiscoverySeed
            self.replicateID = replicateID
            self.declaredLearningRateGrid =
                declaredLearningRateGrid
            self.declaredReplicateSeeds =
                declaredReplicateSeeds
            self.configurationArtifactSHA256 =
                configurationArtifactSHA256
            self.configurationArtifactFileName =
                configurationArtifactFileName
            self.executorWallAccountingID =
                executorWallAccountingID
            self.resumedFromTrainingStage =
                resumedFromTrainingStage
            self.priorExecutorWallSeconds =
                priorExecutorWallSeconds
            self.checkpointStageExecutorWallSeconds =
                checkpointStageExecutorWallSeconds
            self
                .preexistingEvaluationArtifactNamesAtInvocationStart =
                preexistingEvaluationArtifactNamesAtInvocationStart
            self.declaredMaximumExecutorWallSeconds =
                declaredMaximumExecutorWallSeconds
            self.measuredTotalExecutorWallSeconds =
                measuredTotalExecutorWallSeconds
            self.persistencePolicy = persistencePolicy
            self.interruptedTrajectoryReplayExact =
                interruptedTrajectoryReplayExact
        }

        enum CodingKeys: String, CodingKey {
            case requestedSteps = "requested_steps"
            case completedSteps = "completed_steps"
            case probePurposeID = "probe_purpose_id"
            case scheduleID = "schedule_id"
            case distinctScheduledRowCount =
                "distinct_scheduled_row_count"
            case scheduledSemanticFamilyRows =
                "scheduled_semantic_family_rows"
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
            case heldoutRowCount = "heldout_row_count"
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
            case comparisonManifestSHA256 =
                "comparison_manifest_sha256"
            case trainingScheduleManifestSHA256 =
                "training_schedule_manifest_sha256"
            case trainingHeldoutRowHashIntersectionCount =
                "training_heldout_row_hash_intersection_count"
            case heldoutTargetTokenCount =
                "heldout_target_token_count"
            case heldoutValidTargetTokenCount =
                "heldout_valid_target_token_count"
            case heldoutRefusalTargetTokenCount =
                "heldout_refusal_target_token_count"
            case heldoutEvaluationNonPaddingTokenCount =
                "heldout_evaluation_non_padding_token_count"
            case heldoutEvaluationElapsedSeconds =
                "heldout_evaluation_elapsed_seconds"
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
            case heldoutCrossEntropyStandardError =
                "heldout_cross_entropy_standard_error"
            case heldoutCrossEntropyStandardErrorMethodID =
                "heldout_cross_entropy_standard_error_method_id"
            case heldoutFamilyCrossEntropyBefore =
                "heldout_family_cross_entropy_before"
            case heldoutFamilyCrossEntropyAfter =
                "heldout_family_cross_entropy_after"
            case heldoutLossRows = "heldout_loss_rows"
            case measurementWarmupSteps =
                "measurement_warmup_steps"
            case timedSteps = "timed_steps"
            case batchSize = "batch_size"
            case gradientAccumulationSteps =
                "gradient_accumulation_steps"
            case effectiveBatchSize = "effective_batch_size"
            case measuredSequenceLength = "measured_sequence_length"
            case evaluationBatchSize = "evaluation_batch_size"
            case evaluationShardSize = "evaluation_shard_size"
            case processedPaddedTokenPositions =
                "processed_padded_token_positions"
            case plannedTrainingTokenPresentations =
                "planned_training_token_presentations"
            case trainedTokens = "trained_tokens"
            case elapsedSeconds = "elapsed_seconds"
            case coldStartElapsedSeconds =
                "cold_start_elapsed_seconds"
            case measurementWarmupElapsedSeconds =
                "measurement_warmup_elapsed_seconds"
            case timedElapsedSeconds = "timed_elapsed_seconds"
            case timedNonPaddingTokens =
                "timed_non_padding_tokens"
            case tokensPerSecond = "tokens_per_second"
            case peakMemoryBytes = "peak_memory_bytes"
            case learningRate = "learning_rate"
            case learningRateScheduleID =
                "learning_rate_schedule_id"
            case optimizerImplementation =
                "optimizer_implementation"
            case adamBeta1 = "adam_beta_1"
            case adamBeta2 = "adam_beta_2"
            case adamEpsilon = "adam_epsilon"
            case decoupledWeightDecay =
                "decoupled_weight_decay"
            case gradientClipMode = "gradient_clip_mode"
            case lossReduction = "loss_reduction"
            case warmupSteps = "warmup_steps"
            case minimumLearningRate =
                "minimum_learning_rate"
            case weightDecay = "weight_decay"
            case precision
            case gradientClipNorm = "gradient_clip_norm"
            case fullWeightTraining = "full_weight_training"
            case shiftedCausalLanguageModelLoss =
                "shifted_causal_language_model_loss"
            case promptTokensMasked = "prompt_tokens_masked"
            case targetTokenWeightedEffectiveBatchLoss =
                "target_token_weighted_effective_batch_loss"
            case answerTokensContributed =
                "answer_tokens_contributed"
            case firstGradientNorm = "first_gradient_norm"
            case firstClippedGradientNorm =
                "first_clipped_gradient_norm"
            case firstWeightUpdateNorm =
                "first_weight_update_norm"
            case causalPrefixMaximumLogitDelta =
                "causal_prefix_maximum_logit_delta"
            case suffixEffectMaximumLogitDelta =
                "suffix_effect_maximum_logit_delta"
            case logitsFinite = "logits_finite"
            case repeatedInferenceMaximumLogitDelta =
                "repeated_inference_maximum_logit_delta"
            case cachedUncachedMaximumLogitDelta =
                "cached_uncached_maximum_logit_delta"
            case cachedUncachedGreedyTokenParity =
                "cached_uncached_greedy_token_parity"
            case cachedUncachedMultiStepMaximumLogitDelta =
                "cached_uncached_multi_step_maximum_logit_delta"
            case cachedUncachedMultiStepGreedyTokenParity =
                "cached_uncached_multi_step_greedy_token_parity"
            case cachedUncachedMultiStepComparedDecisionCount =
                "cached_uncached_multi_step_compared_decision_count"
            case cachedUncachedMultiStepUnevenEOS =
                "cached_uncached_multi_step_uneven_eos"
            case initializationFingerprintSHA256 =
                "initialization_fingerprint_sha256"
            case sameSeedInitializationReplayExact =
                "same_seed_initialization_replay_exact"
            case initialLoss = "initial_loss"
            case finalLoss = "final_loss"
            case losses
            case hyperparameterSearchID =
                "hyperparameter_search_id"
            case learningRateDiscoverySeed =
                "learning_rate_discovery_seed"
            case replicateID = "replicate_id"
            case declaredLearningRateGrid =
                "declared_learning_rate_grid"
            case declaredReplicateSeeds =
                "declared_replicate_seeds"
            case configurationArtifactSHA256 =
                "configuration_artifact_sha256"
            case configurationArtifactFileName =
                "configuration_artifact_file_name"
            case executorWallAccountingID =
                "executor_wall_accounting_id"
            case resumedFromTrainingStage =
                "resumed_from_training_stage"
            case priorExecutorWallSeconds =
                "prior_executor_wall_seconds"
            case checkpointStageExecutorWallSeconds =
                "checkpoint_stage_executor_wall_seconds"
            case preexistingEvaluationArtifactNamesAtInvocationStart =
                "preexisting_evaluation_artifact_names_at_invocation_start"
            case declaredMaximumExecutorWallSeconds =
                "declared_maximum_executor_wall_seconds"
            case measuredTotalExecutorWallSeconds =
                "measured_total_executor_wall_seconds"
            case persistencePolicy = "persistence_policy"
            case interruptedTrajectoryReplayExact =
                "interrupted_trajectory_replay_exact"
        }
    }

    public struct DurabilityEvidence: Codable, Equatable, Sendable {
        public let checkpointSHA256: String
        public let buildConfiguration: String
        public let precision: String
        public let checkpointFileName: String
        public let trainingStageSHA256: String
        public let trainingStageFileName: String
        public let evaluationDirectoryName: String
        public let checkpointTensorCount: Int
        public let checkpointReloadWeightsExact: Bool
        public let checkpointReloadMaximumWeightDelta: Double
        public let checkpointReloadMaximumLogitDelta: Double
        public let repeatedInferenceMaximumLogitDelta: Double
        public let reloadedPredictionsExact: Bool
        public let configurationSHA256: String
        public let executableSHA256: String
        public let recommenderSHA256: String
        public let recommenderFileName: String
        public let metalLibraryArtifactSHA256: String
        public let metalLibraryArtifactByteCount: Int64
        public let metalLibraryPrimaryFileName: String
        public let metalLibraryFallbackFileName: String
        public let metalLibraryBundleSearchAuditID: String
        public let metalLibraryBundleSearchBaseCount: Int
        public let metalLibraryVerifiedBundleMirrorCount: Int
        public let metalLibraryDivergentBundleCandidateCount: Int
        public let metalLibrarySourceMLXSwiftRevision: String
        public let observedModelParameterDTypes: [String]
        public let observedTrainableParameterDTypes: [String]

        public init(
            checkpointSHA256: String,
            buildConfiguration: String,
            precision: String,
            checkpointFileName: String,
            trainingStageSHA256: String,
            trainingStageFileName: String,
            evaluationDirectoryName: String,
            checkpointTensorCount: Int,
            checkpointReloadWeightsExact: Bool,
            checkpointReloadMaximumWeightDelta: Double,
            checkpointReloadMaximumLogitDelta: Double,
            repeatedInferenceMaximumLogitDelta: Double,
            reloadedPredictionsExact: Bool,
            configurationSHA256: String,
            executableSHA256: String,
            recommenderSHA256: String,
            recommenderFileName: String,
            metalLibraryArtifactSHA256: String,
            metalLibraryArtifactByteCount: Int64,
            metalLibraryPrimaryFileName: String,
            metalLibraryFallbackFileName: String,
            metalLibraryBundleSearchAuditID: String,
            metalLibraryBundleSearchBaseCount: Int,
            metalLibraryVerifiedBundleMirrorCount: Int,
            metalLibraryDivergentBundleCandidateCount: Int,
            metalLibrarySourceMLXSwiftRevision: String,
            observedModelParameterDTypes: [String],
            observedTrainableParameterDTypes: [String]
        ) {
            self.checkpointSHA256 = checkpointSHA256
            self.buildConfiguration = buildConfiguration
            self.precision = precision
            self.checkpointFileName = checkpointFileName
            self.trainingStageSHA256 = trainingStageSHA256
            self.trainingStageFileName = trainingStageFileName
            self.evaluationDirectoryName =
                evaluationDirectoryName
            self.checkpointTensorCount = checkpointTensorCount
            self.checkpointReloadWeightsExact =
                checkpointReloadWeightsExact
            self.checkpointReloadMaximumWeightDelta =
                checkpointReloadMaximumWeightDelta
            self.checkpointReloadMaximumLogitDelta =
                checkpointReloadMaximumLogitDelta
            self.repeatedInferenceMaximumLogitDelta =
                repeatedInferenceMaximumLogitDelta
            self.reloadedPredictionsExact =
                reloadedPredictionsExact
            self.configurationSHA256 = configurationSHA256
            self.executableSHA256 = executableSHA256
            self.recommenderSHA256 = recommenderSHA256
            self.recommenderFileName = recommenderFileName
            self.metalLibraryArtifactSHA256 =
                metalLibraryArtifactSHA256
            self.metalLibraryArtifactByteCount =
                metalLibraryArtifactByteCount
            self.metalLibraryPrimaryFileName =
                metalLibraryPrimaryFileName
            self.metalLibraryFallbackFileName =
                metalLibraryFallbackFileName
            self.metalLibraryBundleSearchAuditID =
                metalLibraryBundleSearchAuditID
            self.metalLibraryBundleSearchBaseCount =
                metalLibraryBundleSearchBaseCount
            self.metalLibraryVerifiedBundleMirrorCount =
                metalLibraryVerifiedBundleMirrorCount
            self.metalLibraryDivergentBundleCandidateCount =
                metalLibraryDivergentBundleCandidateCount
            self.metalLibrarySourceMLXSwiftRevision =
                metalLibrarySourceMLXSwiftRevision
            self.observedModelParameterDTypes =
                observedModelParameterDTypes
            self.observedTrainableParameterDTypes =
                observedTrainableParameterDTypes
        }

        enum CodingKeys: String, CodingKey {
            case checkpointSHA256 = "checkpoint_sha256"
            case buildConfiguration = "build_configuration"
            case precision
            case checkpointFileName = "checkpoint_file_name"
            case trainingStageSHA256 = "training_stage_sha256"
            case trainingStageFileName = "training_stage_file_name"
            case evaluationDirectoryName =
                "evaluation_directory_name"
            case checkpointTensorCount = "checkpoint_tensor_count"
            case checkpointReloadWeightsExact =
                "checkpoint_reload_weights_exact"
            case checkpointReloadMaximumWeightDelta =
                "checkpoint_reload_maximum_weight_delta"
            case checkpointReloadMaximumLogitDelta =
                "checkpoint_reload_maximum_logit_delta"
            case repeatedInferenceMaximumLogitDelta =
                "repeated_inference_maximum_logit_delta"
            case reloadedPredictionsExact =
                "reloaded_predictions_exact"
            case configurationSHA256 = "configuration_sha256"
            case executableSHA256 = "executable_sha256"
            case recommenderSHA256 = "recommender_sha256"
            case recommenderFileName = "recommender_file_name"
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
        }
    }

    public struct RawPrediction: Codable, Equatable, Sendable {
        public let rowID: String
        public let corpusRowSHA256: String
        public let evaluationRowSHA256: String
        public let split: Split
        public let semanticFamily: String
        public let invariantIDs: [String]
        public let mutationID: String?
        public let abstentionReason: String?
        public let prompt: String
        public let promptTokenIDs: [Int]
        public let target: String
        public let targetTokenIDs: [Int]
        public let promptGroupingKeyID: String
        public let promptGroupingKey: Int
        public let generationDecisionBudget: Int
        public let allowedCompletionTokenSetSHA256: String
        public let eosAvailableAtEveryDecision: Bool
        public let targetIndependentDecisionBudget: Bool
        public let zeroShotDecisionsExecuted: Int
        public let zeroShotPrediction: String?
        public let zeroShotPredictionTokenIDs: [Int]
        public let zeroShotMeanLogProbability: Double
        public let zeroShotTokenLogProbabilities: [Double]
        public let zeroShotTerminatedByEOS: Bool
        public let zeroShotTerminationReason: String
        public let zeroShotUTF8Valid: Bool
        public let zeroShotEOSLogProbability: Double?
        public let zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity:
            Bool
        public let zeroShotDisallowedFullVocabularyArgmaxCount: Int
        public let zeroShotMaximumDisallowedTokenProbabilityMass:
            Double
        public let zeroShotExactMatch: Bool
        public let zeroShotSemanticVerifierPass: Bool
        public let zeroShotAbstentionDecision: Bool
        public let zeroShotLatencySeconds: Double
        public let trainedPrediction: String?
        public let trainedPredictionTokenIDs: [Int]
        public let trainedMeanLogProbability: Double
        public let trainedTokenLogProbabilities: [Double]
        public let trainedTerminatedByEOS: Bool
        public let trainedTerminationReason: String
        public let trainedUTF8Valid: Bool
        public let trainedEOSLogProbability: Double?
        public let trainedRawFullVocabularyAllowedSupportGreedyTokenParity:
            Bool
        public let trainedDisallowedFullVocabularyArgmaxCount: Int
        public let trainedMaximumDisallowedTokenProbabilityMass:
            Double
        public let trainedExactMatch: Bool
        public let trainedSemanticVerifierPass: Bool
        public let trainedAbstentionDecision: Bool
        public let trainedLatencySeconds: Double
        public let trainedDecisionsExecuted: Int

        public init(
            rowID: String,
            corpusRowSHA256: String,
            evaluationRowSHA256: String,
            split: Split,
            semanticFamily: String,
            invariantIDs: [String],
            mutationID: String? = nil,
            abstentionReason: String? = nil,
            prompt: String,
            promptTokenIDs: [Int],
            target: String,
            targetTokenIDs: [Int],
            zeroShotPrediction: String?,
            zeroShotPredictionTokenIDs: [Int],
            zeroShotMeanLogProbability: Double,
            zeroShotTokenLogProbabilities: [Double],
            zeroShotTerminatedByEOS: Bool,
            zeroShotTerminationReason: String,
            zeroShotUTF8Valid: Bool,
            zeroShotEOSLogProbability: Double?,
            zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity:
                Bool = true,
            zeroShotDisallowedFullVocabularyArgmaxCount: Int = 0,
            zeroShotMaximumDisallowedTokenProbabilityMass:
                Double = 0,
            zeroShotExactMatch: Bool,
            zeroShotSemanticVerifierPass: Bool,
            zeroShotAbstentionDecision: Bool,
            zeroShotLatencySeconds: Double,
            trainedPrediction: String?,
            trainedPredictionTokenIDs: [Int],
            trainedMeanLogProbability: Double,
            trainedTokenLogProbabilities: [Double],
            trainedTerminatedByEOS: Bool,
            trainedTerminationReason: String,
            trainedUTF8Valid: Bool,
            trainedEOSLogProbability: Double?,
            trainedRawFullVocabularyAllowedSupportGreedyTokenParity:
                Bool = true,
            trainedDisallowedFullVocabularyArgmaxCount: Int = 0,
            trainedMaximumDisallowedTokenProbabilityMass:
                Double = 0,
            trainedExactMatch: Bool,
            trainedSemanticVerifierPass: Bool,
            trainedAbstentionDecision: Bool,
            trainedLatencySeconds: Double,
            promptGroupingKeyID: String =
                ErgenticsNativeLanguageCanary.promptGroupingKeyID,
            promptGroupingKey: Int? = nil,
            generationDecisionBudget: Int =
                ErgenticsNativeLanguageCanary
                    .maximumGenerationTokenDecisions,
            allowedCompletionTokenSetSHA256: String =
                ErgenticsNativeLanguageCanary
                    .allowedCompletionTokenSetSHA256,
            eosAvailableAtEveryDecision: Bool = true,
            targetIndependentDecisionBudget: Bool = true,
            zeroShotDecisionsExecuted: Int? = nil,
            trainedDecisionsExecuted: Int? = nil
        ) {
            self.rowID = rowID
            self.corpusRowSHA256 = corpusRowSHA256
            self.evaluationRowSHA256 = evaluationRowSHA256
            self.split = split
            self.semanticFamily = semanticFamily
            self.invariantIDs = invariantIDs
            self.mutationID = mutationID
            self.abstentionReason = abstentionReason
            self.prompt = prompt
            self.promptTokenIDs = promptTokenIDs
            self.target = target
            self.targetTokenIDs = targetTokenIDs
            self.promptGroupingKeyID = promptGroupingKeyID
            self.promptGroupingKey =
                promptGroupingKey
                    ?? max(0, promptTokenIDs.count - 1)
            self.generationDecisionBudget =
                generationDecisionBudget
            self.allowedCompletionTokenSetSHA256 =
                allowedCompletionTokenSetSHA256
            self.eosAvailableAtEveryDecision =
                eosAvailableAtEveryDecision
            self.targetIndependentDecisionBudget =
                targetIndependentDecisionBudget
            self.zeroShotDecisionsExecuted =
                zeroShotDecisionsExecuted
                    ?? zeroShotPredictionTokenIDs.count
                        + (zeroShotTerminatedByEOS ? 1 : 0)
            self.zeroShotPrediction = zeroShotPrediction
            self.zeroShotPredictionTokenIDs =
                zeroShotPredictionTokenIDs
            self.zeroShotMeanLogProbability =
                zeroShotMeanLogProbability
            self.zeroShotTokenLogProbabilities =
                zeroShotTokenLogProbabilities
            self.zeroShotTerminatedByEOS =
                zeroShotTerminatedByEOS
            self.zeroShotTerminationReason =
                zeroShotTerminationReason
            self.zeroShotUTF8Valid = zeroShotUTF8Valid
            self.zeroShotEOSLogProbability =
                zeroShotEOSLogProbability
            self
                .zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity =
                zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity
            self.zeroShotDisallowedFullVocabularyArgmaxCount =
                zeroShotDisallowedFullVocabularyArgmaxCount
            self.zeroShotMaximumDisallowedTokenProbabilityMass =
                zeroShotMaximumDisallowedTokenProbabilityMass
            self.zeroShotExactMatch = zeroShotExactMatch
            self.zeroShotSemanticVerifierPass =
                zeroShotSemanticVerifierPass
            self.zeroShotAbstentionDecision =
                zeroShotAbstentionDecision
            self.zeroShotLatencySeconds = zeroShotLatencySeconds
            self.trainedPrediction = trainedPrediction
            self.trainedPredictionTokenIDs =
                trainedPredictionTokenIDs
            self.trainedMeanLogProbability =
                trainedMeanLogProbability
            self.trainedTokenLogProbabilities =
                trainedTokenLogProbabilities
            self.trainedTerminatedByEOS =
                trainedTerminatedByEOS
            self.trainedTerminationReason =
                trainedTerminationReason
            self.trainedUTF8Valid = trainedUTF8Valid
            self.trainedEOSLogProbability =
                trainedEOSLogProbability
            self
                .trainedRawFullVocabularyAllowedSupportGreedyTokenParity =
                trainedRawFullVocabularyAllowedSupportGreedyTokenParity
            self.trainedDisallowedFullVocabularyArgmaxCount =
                trainedDisallowedFullVocabularyArgmaxCount
            self.trainedMaximumDisallowedTokenProbabilityMass =
                trainedMaximumDisallowedTokenProbabilityMass
            self.trainedExactMatch = trainedExactMatch
            self.trainedSemanticVerifierPass =
                trainedSemanticVerifierPass
            self.trainedAbstentionDecision =
                trainedAbstentionDecision
            self.trainedLatencySeconds = trainedLatencySeconds
            self.trainedDecisionsExecuted =
                trainedDecisionsExecuted
                    ?? trainedPredictionTokenIDs.count
                        + (trainedTerminatedByEOS ? 1 : 0)
        }

        enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case corpusRowSHA256 = "corpus_row_sha256"
            case evaluationRowSHA256 = "evaluation_row_sha256"
            case split
            case semanticFamily = "semantic_family"
            case invariantIDs = "invariant_ids"
            case mutationID = "mutation_id"
            case abstentionReason = "abstention_reason"
            case prompt
            case promptTokenIDs = "prompt_token_ids"
            case target
            case targetTokenIDs = "target_token_ids"
            case promptGroupingKeyID =
                "prompt_grouping_key_id"
            case promptGroupingKey = "prompt_grouping_key"
            case generationDecisionBudget =
                "generation_decision_budget"
            case allowedCompletionTokenSetSHA256 =
                "allowed_completion_token_set_sha256"
            case eosAvailableAtEveryDecision =
                "eos_available_at_every_decision"
            case targetIndependentDecisionBudget =
                "target_independent_decision_budget"
            case zeroShotDecisionsExecuted =
                "zero_shot_decisions_executed"
            case zeroShotPrediction = "zero_shot_prediction"
            case zeroShotPredictionTokenIDs =
                "zero_shot_prediction_token_ids"
            case zeroShotMeanLogProbability =
                "zero_shot_mean_log_probability"
            case zeroShotTokenLogProbabilities =
                "zero_shot_token_log_probabilities"
            case zeroShotTerminatedByEOS =
                "zero_shot_terminated_by_eos"
            case zeroShotTerminationReason =
                "zero_shot_termination_reason"
            case zeroShotUTF8Valid =
                "zero_shot_utf8_valid"
            case zeroShotEOSLogProbability =
                "zero_shot_eos_log_probability"
            case zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity =
                "zero_shot_raw_full_vocabulary_allowed_support_greedy_token_parity"
            case zeroShotDisallowedFullVocabularyArgmaxCount =
                "zero_shot_disallowed_full_vocabulary_argmax_count"
            case zeroShotMaximumDisallowedTokenProbabilityMass =
                "zero_shot_maximum_disallowed_token_probability_mass"
            case zeroShotExactMatch = "zero_shot_exact_match"
            case zeroShotSemanticVerifierPass =
                "zero_shot_semantic_verifier_pass"
            case zeroShotAbstentionDecision =
                "zero_shot_abstention_decision"
            case zeroShotLatencySeconds =
                "zero_shot_latency_seconds"
            case trainedPrediction = "trained_prediction"
            case trainedPredictionTokenIDs =
                "trained_prediction_token_ids"
            case trainedMeanLogProbability =
                "trained_mean_log_probability"
            case trainedTokenLogProbabilities =
                "trained_token_log_probabilities"
            case trainedTerminatedByEOS =
                "trained_terminated_by_eos"
            case trainedTerminationReason =
                "trained_termination_reason"
            case trainedUTF8Valid = "trained_utf8_valid"
            case trainedEOSLogProbability =
                "trained_eos_log_probability"
            case trainedRawFullVocabularyAllowedSupportGreedyTokenParity =
                "trained_raw_full_vocabulary_allowed_support_greedy_token_parity"
            case trainedDisallowedFullVocabularyArgmaxCount =
                "trained_disallowed_full_vocabulary_argmax_count"
            case trainedMaximumDisallowedTokenProbabilityMass =
                "trained_maximum_disallowed_token_probability_mass"
            case trainedExactMatch = "trained_exact_match"
            case trainedSemanticVerifierPass =
                "trained_semantic_verifier_pass"
            case trainedAbstentionDecision =
                "trained_abstention_decision"
            case trainedLatencySeconds =
                "trained_latency_seconds"
            case trainedDecisionsExecuted =
                "trained_decisions_executed"
        }
    }

    public struct EvaluationShardBinding:
        Codable, Equatable, Sendable
    {
        public let phase: String
        public let fileName: String
        public let artifactSHA256: String
        public let rowCount: Int
        public let firstRowID: String
        public let lastRowID: String

        public init(
            phase: String,
            fileName: String,
            artifactSHA256: String,
            rowCount: Int,
            firstRowID: String,
            lastRowID: String
        ) {
            self.phase = phase
            self.fileName = fileName
            self.artifactSHA256 = artifactSHA256
            self.rowCount = rowCount
            self.firstRowID = firstRowID
            self.lastRowID = lastRowID
        }

        enum CodingKeys: String, CodingKey {
            case phase
            case fileName = "file_name"
            case artifactSHA256 = "artifact_sha256"
            case rowCount = "row_count"
            case firstRowID = "first_row_id"
            case lastRowID = "last_row_id"
        }
    }

    public struct SelectedParameterSample:
        Codable, Equatable, Sendable
    {
        public let name: String
        public let shape: [Int]
        public let dtype: String
        public let indices: [Int]
        public let floatBitPatterns: [UInt32]

        public init(
            name: String,
            shape: [Int],
            dtype: String,
            indices: [Int],
            floatBitPatterns: [UInt32]
        ) {
            self.name = name
            self.shape = shape
            self.dtype = dtype
            self.indices = indices
            self.floatBitPatterns = floatBitPatterns
        }

        enum CodingKeys: String, CodingKey {
            case name
            case shape
            case dtype
            case indices
            case floatBitPatterns = "float_bit_patterns"
        }
    }

    public struct SameSeedReplayEvidence:
        Codable, Equatable, Sendable
    {
        public let optimizerSteps: Int
        public let scheduledRowIDs: [String]
        public let initialFingerprintSHA256: String
        public let replayInitialFingerprintSHA256: String
        public let initialSelectedParameterSamples:
            [SelectedParameterSample]
        public let replayInitialSelectedParameterSamples:
            [SelectedParameterSample]
        public let initializationReplayExact: Bool
        public let differentSeed: Int
        public let differentSeedInitialFingerprintSHA256: String
        public let differentSeedInitialSelectedParameterSamples:
            [SelectedParameterSample]
        public let differentSeedInitializationDiverged: Bool
        public let firstStepLoss: Double
        public let replayStepLoss: Double
        public let stepLossExact: Bool
        public let postStepFingerprintSHA256: String
        public let replayPostStepFingerprintSHA256: String
        public let postStepSelectedParameterSamples:
            [SelectedParameterSample]
        public let replayPostStepSelectedParameterSamples:
            [SelectedParameterSample]
        public let postStepSelectedParametersExact: Bool
        public let postStepSelectedParameterMaximumDelta: Double
        public let fixedPromptLogitFloatBitPatterns: [UInt32]
        public let replayFixedPromptLogitFloatBitPatterns: [UInt32]
        public let fixedPromptMaximumLogitDelta: Double
        public let fixedPromptGreedyTokenID: Int
        public let replayFixedPromptGreedyTokenID: Int
        public let fixedPromptGreedyRunnerUpMargin: Double
        public let replayFixedPromptGreedyRunnerUpMargin: Double
        public let fixedPromptGreedyTokenExact: Bool
        public let fixedPromptBehavioralReplayExact: Bool
        public let fixedPromptResultSHA256: String
        public let replayFixedPromptResultSHA256: String
        public let fixedPromptResultExact: Bool

        public init(
            optimizerSteps: Int,
            scheduledRowIDs: [String],
            initialFingerprintSHA256: String,
            replayInitialFingerprintSHA256: String,
            initialSelectedParameterSamples:
                [SelectedParameterSample],
            replayInitialSelectedParameterSamples:
                [SelectedParameterSample],
            initializationReplayExact: Bool,
            differentSeed: Int,
            differentSeedInitialFingerprintSHA256: String,
            differentSeedInitialSelectedParameterSamples:
                [SelectedParameterSample],
            differentSeedInitializationDiverged: Bool,
            firstStepLoss: Double,
            replayStepLoss: Double,
            stepLossExact: Bool,
            postStepFingerprintSHA256: String,
            replayPostStepFingerprintSHA256: String,
            postStepSelectedParameterSamples:
                [SelectedParameterSample],
            replayPostStepSelectedParameterSamples:
                [SelectedParameterSample],
            postStepSelectedParametersExact: Bool,
            postStepSelectedParameterMaximumDelta: Double,
            fixedPromptLogitFloatBitPatterns: [UInt32],
            replayFixedPromptLogitFloatBitPatterns: [UInt32],
            fixedPromptMaximumLogitDelta: Double,
            fixedPromptGreedyTokenID: Int,
            replayFixedPromptGreedyTokenID: Int,
            fixedPromptGreedyRunnerUpMargin: Double,
            replayFixedPromptGreedyRunnerUpMargin: Double,
            fixedPromptGreedyTokenExact: Bool,
            fixedPromptBehavioralReplayExact: Bool,
            fixedPromptResultSHA256: String,
            replayFixedPromptResultSHA256: String,
            fixedPromptResultExact: Bool
        ) {
            self.optimizerSteps = optimizerSteps
            self.scheduledRowIDs = scheduledRowIDs
            self.initialFingerprintSHA256 =
                initialFingerprintSHA256
            self.replayInitialFingerprintSHA256 =
                replayInitialFingerprintSHA256
            self.initialSelectedParameterSamples =
                initialSelectedParameterSamples
            self.replayInitialSelectedParameterSamples =
                replayInitialSelectedParameterSamples
            self.initializationReplayExact =
                initializationReplayExact
            self.differentSeed = differentSeed
            self.differentSeedInitialFingerprintSHA256 =
                differentSeedInitialFingerprintSHA256
            self.differentSeedInitialSelectedParameterSamples =
                differentSeedInitialSelectedParameterSamples
            self.differentSeedInitializationDiverged =
                differentSeedInitializationDiverged
            self.firstStepLoss = firstStepLoss
            self.replayStepLoss = replayStepLoss
            self.stepLossExact = stepLossExact
            self.postStepFingerprintSHA256 =
                postStepFingerprintSHA256
            self.replayPostStepFingerprintSHA256 =
                replayPostStepFingerprintSHA256
            self.postStepSelectedParameterSamples =
                postStepSelectedParameterSamples
            self.replayPostStepSelectedParameterSamples =
                replayPostStepSelectedParameterSamples
            self.postStepSelectedParametersExact =
                postStepSelectedParametersExact
            self.postStepSelectedParameterMaximumDelta =
                postStepSelectedParameterMaximumDelta
            self.fixedPromptLogitFloatBitPatterns =
                fixedPromptLogitFloatBitPatterns
            self.replayFixedPromptLogitFloatBitPatterns =
                replayFixedPromptLogitFloatBitPatterns
            self.fixedPromptMaximumLogitDelta =
                fixedPromptMaximumLogitDelta
            self.fixedPromptGreedyTokenID =
                fixedPromptGreedyTokenID
            self.replayFixedPromptGreedyTokenID =
                replayFixedPromptGreedyTokenID
            self.fixedPromptGreedyRunnerUpMargin =
                fixedPromptGreedyRunnerUpMargin
            self.replayFixedPromptGreedyRunnerUpMargin =
                replayFixedPromptGreedyRunnerUpMargin
            self.fixedPromptGreedyTokenExact =
                fixedPromptGreedyTokenExact
            self.fixedPromptBehavioralReplayExact =
                fixedPromptBehavioralReplayExact
            self.fixedPromptResultSHA256 =
                fixedPromptResultSHA256
            self.replayFixedPromptResultSHA256 =
                replayFixedPromptResultSHA256
            self.fixedPromptResultExact =
                fixedPromptResultExact
        }

        enum CodingKeys: String, CodingKey {
            case optimizerSteps = "optimizer_steps"
            case scheduledRowIDs = "scheduled_row_ids"
            case initialFingerprintSHA256 =
                "initial_fingerprint_sha256"
            case replayInitialFingerprintSHA256 =
                "replay_initial_fingerprint_sha256"
            case initialSelectedParameterSamples =
                "initial_selected_parameter_samples"
            case replayInitialSelectedParameterSamples =
                "replay_initial_selected_parameter_samples"
            case initializationReplayExact =
                "initialization_replay_exact"
            case differentSeed = "different_seed"
            case differentSeedInitialFingerprintSHA256 =
                "different_seed_initial_fingerprint_sha256"
            case differentSeedInitialSelectedParameterSamples =
                "different_seed_initial_selected_parameter_samples"
            case differentSeedInitializationDiverged =
                "different_seed_initialization_diverged"
            case firstStepLoss = "first_step_loss"
            case replayStepLoss = "replay_step_loss"
            case stepLossExact = "step_loss_exact"
            case postStepFingerprintSHA256 =
                "post_step_fingerprint_sha256"
            case replayPostStepFingerprintSHA256 =
                "replay_post_step_fingerprint_sha256"
            case postStepSelectedParameterSamples =
                "post_step_selected_parameter_samples"
            case replayPostStepSelectedParameterSamples =
                "replay_post_step_selected_parameter_samples"
            case postStepSelectedParametersExact =
                "post_step_selected_parameters_exact"
            case postStepSelectedParameterMaximumDelta =
                "post_step_selected_parameter_maximum_delta"
            case fixedPromptLogitFloatBitPatterns =
                "fixed_prompt_logit_float_bit_patterns"
            case replayFixedPromptLogitFloatBitPatterns =
                "replay_fixed_prompt_logit_float_bit_patterns"
            case fixedPromptMaximumLogitDelta =
                "fixed_prompt_maximum_logit_delta"
            case fixedPromptGreedyTokenID =
                "fixed_prompt_greedy_token_id"
            case replayFixedPromptGreedyTokenID =
                "replay_fixed_prompt_greedy_token_id"
            case fixedPromptGreedyRunnerUpMargin =
                "fixed_prompt_greedy_runner_up_margin"
            case replayFixedPromptGreedyRunnerUpMargin =
                "replay_fixed_prompt_greedy_runner_up_margin"
            case fixedPromptGreedyTokenExact =
                "fixed_prompt_greedy_token_exact"
            case fixedPromptBehavioralReplayExact =
                "fixed_prompt_behavioral_replay_exact"
            case fixedPromptResultSHA256 =
                "fixed_prompt_result_sha256"
            case replayFixedPromptResultSHA256 =
                "replay_fixed_prompt_result_sha256"
            case fixedPromptResultExact =
                "fixed_prompt_result_exact"
        }
    }

    public struct Report: Codable, Equatable, Sendable {
        public let schemaVersion: String
        public let familyID: String
        public let lineageID: String
        public let mode: Mode
        public let seed: Int
        public let parentCheckpointSHA256: String?
        public let legacySymbolicManifestSHA256: String?
        public let generationContractID: String
        public let profile: ProfileBinding
        public let tokenizer: TokenizerBinding
        public let corpus: CorpusBinding
        public let implementation: ImplementationEvidence
        public let training: TrainingEvidence
        public let sameSeedReplay: SameSeedReplayEvidence
        public let durability: DurabilityEvidence?
        public let evaluationShards: [EvaluationShardBinding]
        public let rawPredictions: [RawPrediction]

        public init(
            schemaVersion: String =
                ErgenticsNativeLanguageCanary.schemaVersion,
            familyID: String =
                ErgenticsNativeLanguageCanary.familyID,
            lineageID: String =
                ErgenticsNativeLanguageCanary.lineageID,
            mode: Mode,
            seed: Int,
            parentCheckpointSHA256: String? = nil,
            legacySymbolicManifestSHA256: String? = nil,
            generationContractID: String =
                ErgenticsNativeLanguageCanary.generationContractID,
            profile: ProfileBinding,
            tokenizer: TokenizerBinding,
            corpus: CorpusBinding,
            implementation: ImplementationEvidence,
            training: TrainingEvidence,
            sameSeedReplay: SameSeedReplayEvidence,
            durability: DurabilityEvidence?,
            evaluationShards: [EvaluationShardBinding] = [],
            rawPredictions: [RawPrediction]
        ) {
            self.schemaVersion = schemaVersion
            self.familyID = familyID
            self.lineageID = lineageID
            self.mode = mode
            self.seed = seed
            self.parentCheckpointSHA256 =
                parentCheckpointSHA256
            self.legacySymbolicManifestSHA256 =
                legacySymbolicManifestSHA256
            self.generationContractID = generationContractID
            self.profile = profile
            self.tokenizer = tokenizer
            self.corpus = corpus
            self.implementation = implementation
            self.training = training
            self.sameSeedReplay = sameSeedReplay
            self.durability = durability
            self.evaluationShards = evaluationShards
            self.rawPredictions = rawPredictions
        }

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case familyID = "family_id"
            case lineageID = "lineage_id"
            case mode
            case seed
            case parentCheckpointSHA256 =
                "parent_checkpoint_sha256"
            case legacySymbolicManifestSHA256 =
                "legacy_symbolic_manifest_sha256"
            case generationContractID = "generation_contract_id"
            case profile
            case tokenizer
            case corpus
            case implementation
            case training
            case sameSeedReplay = "same_seed_replay"
            case durability
            case evaluationShards = "evaluation_shards"
            case rawPredictions = "raw_predictions"
        }
    }

    public struct Leg: Codable, Equatable, Sendable {
        public let id: String
        public let pass: Bool
        public let detail: String
    }

    public struct SplitMetric: Codable, Equatable, Sendable {
        public let split: Split
        public let role: String
        public let count: Int
        public let zeroShotExactAccuracy: Double
        public let trainedExactAccuracy: Double
        public let trainedMeanLogProbability: Double

        enum CodingKeys: String, CodingKey {
            case split
            case role
            case count
            case zeroShotExactAccuracy =
                "zero_shot_exact_accuracy"
            case trainedExactAccuracy = "trained_exact_accuracy"
            case trainedMeanLogProbability =
                "trained_mean_log_probability"
        }
    }

    public struct Recommendation: Codable, Equatable, Sendable {
        public let schemaVersion: String
        public let outcome: String
        public let claimScope: String
        public let nextAction: String
        public let reportSHA256: String
        public let profileID: String
        public let seed: Int
        public let mode: Mode
        public let splitMetrics: [SplitMetric]
        public let legs: [Leg]

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case outcome
            case claimScope = "claim_scope"
            case nextAction = "next_action"
            case reportSHA256 = "report_sha256"
            case profileID = "profile_id"
            case seed
            case mode
            case splitMetrics = "split_metrics"
            case legs
        }
    }

    public struct ConsensusRecommendation:
        Codable, Equatable, Sendable
    {
        public let schemaVersion: String
        public let outcome: String
        public let claimScope: String
        public let profileID: String?
        public let seeds: [Int]
        public let reportSHA256s: [String]
        public let allSeedReportsGrounded: Bool
        public let nextAction: String

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case outcome
            case claimScope = "claim_scope"
            case profileID = "profile_id"
            case seeds
            case reportSHA256s = "report_sha256s"
            case allSeedReportsGrounded =
                "all_seed_reports_grounded"
            case nextAction = "next_action"
        }
    }

    private static func isSHA256(_ value: String?) -> Bool {
        guard let value, value.count == 64 else { return false }
        return value.allSatisfy {
            "0123456789abcdef".contains($0)
        }
    }

    private static func isGitRevision(_ value: String) -> Bool {
        value.count == 40
            && value.allSatisfy {
                "0123456789abcdef".contains($0)
            }
    }

    private static func finitePositive(_ value: Double) -> Bool {
        value.isFinite && value > 0
    }

    private static func exactIntegerProduct(
        _ factors: [Int]
    ) -> Int? {
        var product = 1
        for factor in factors {
            let next =
                product.multipliedReportingOverflow(by: factor)
            guard !next.overflow else { return nil }
            product = next.partialValue
        }
        return product
    }

    private static func exactIntegerSum(
        _ values: [Int]
    ) -> Int? {
        var total = 0
        for value in values {
            let next = total.addingReportingOverflow(value)
            guard !next.overflow else { return nil }
            total = next.partialValue
        }
        return total
    }

    public static func remainingExecutorWallSeconds(
        maximum: Double,
        prior: Double
    ) -> Double? {
        guard maximum.isFinite, maximum > 0,
              prior.isFinite, prior >= 0,
              prior < maximum else {
            return nil
        }
        let remaining = maximum - prior
        return remaining.isFinite && remaining > 0
            ? remaining : nil
    }

    public static func executorWallEvidenceBound(
        mode: Mode,
        accountingID: String,
        resumedFromTrainingStage: Bool,
        priorExecutorWallSeconds: Double,
        checkpointStageExecutorWallSeconds: Double,
        measuredTotalExecutorWallSeconds: Double,
        declaredMaximumExecutorWallSeconds: Double
    ) -> Bool {
        guard accountingID == executorWallAccountingID,
              remainingExecutorWallSeconds(
                  maximum: declaredMaximumExecutorWallSeconds,
                  prior: priorExecutorWallSeconds
              ) != nil,
              measuredTotalExecutorWallSeconds.isFinite,
              measuredTotalExecutorWallSeconds
                > priorExecutorWallSeconds,
              measuredTotalExecutorWallSeconds
                <= declaredMaximumExecutorWallSeconds else {
            return false
        }
        if mode == .profileProbe {
            return !resumedFromTrainingStage
                && priorExecutorWallSeconds == 0
                && checkpointStageExecutorWallSeconds == 0
        }
        guard checkpointStageExecutorWallSeconds.isFinite,
              checkpointStageExecutorWallSeconds > 0,
              checkpointStageExecutorWallSeconds
                <= measuredTotalExecutorWallSeconds else {
            return false
        }
        return resumedFromTrainingStage
            ? priorExecutorWallSeconds
                == checkpointStageExecutorWallSeconds
            : priorExecutorWallSeconds == 0
    }

    public static func fullStageExecutorWallBound(
        stageAccountingID: String,
        stageDeclaredMaximumExecutorWallSeconds: Double,
        stageCumulativeExecutorWallSeconds: Double,
        training: TrainingEvidence
    ) -> Bool {
        stageAccountingID == executorWallAccountingID
            && stageAccountingID
                == training.executorWallAccountingID
            && stageDeclaredMaximumExecutorWallSeconds
                == training.declaredMaximumExecutorWallSeconds
            && stageCumulativeExecutorWallSeconds
                == training.checkpointStageExecutorWallSeconds
            && executorWallEvidenceBound(
                mode: .fullCanary,
                accountingID: training.executorWallAccountingID,
                resumedFromTrainingStage:
                    training.resumedFromTrainingStage,
                priorExecutorWallSeconds:
                    training.priorExecutorWallSeconds,
                checkpointStageExecutorWallSeconds:
                    stageCumulativeExecutorWallSeconds,
                measuredTotalExecutorWallSeconds:
                    training.measuredTotalExecutorWallSeconds,
                declaredMaximumExecutorWallSeconds:
                    stageDeclaredMaximumExecutorWallSeconds
            )
    }

    public static func fullStageEvaluationGeometryBound(
        stageEvaluationBatchSize: Int,
        stageEvaluationShardSize: Int,
        reportEvaluationBatchSize: Int,
        reportEvaluationShardSize: Int
    ) -> Bool {
        stageEvaluationBatchSize > 0
            && stageEvaluationBatchSize
                == reportEvaluationBatchSize
            && stageEvaluationShardSize == evaluationShardSize
            && stageEvaluationShardSize
                == reportEvaluationShardSize
    }

    static func fullArtifactBasenamesBound(
        _ durability: DurabilityEvidence
    ) -> Bool {
        durability.checkpointFileName
                == checkpointArtifactFileName
            && durability.trainingStageFileName
                == trainingStageArtifactFileName
            && durability.evaluationDirectoryName
                == evaluationArtifactDirectoryName
            && durability.metalLibraryPrimaryFileName
                == metalLibraryPrimaryFileName
            && durability.metalLibraryFallbackFileName
                == metalLibraryFallbackFileName
    }

    static func evaluationShardFileNamesBound(
        _ shards: [EvaluationShardBinding]
    ) -> Bool {
        let phases = [
            "zero_shot",
            "trained",
            "reloaded",
        ]
        guard Set(shards.map(\.phase)) == Set(phases) else {
            return false
        }
        return phases.allSatisfy { phase in
            let names = shards.filter {
                $0.phase == phase
            }.map(\.fileName).sorted()
            return !names.isEmpty
                && names
                == (0 ..< names.count).map {
                    String(
                        format: "\(phase)-shard-%05d.json",
                        $0
                    )
                }
        }
    }

    public static func executedDecisionMeanLogProbability(
        byteTokenLogProbabilities: [Double],
        eosLogProbability: Double?,
        terminatedByEOS: Bool
    ) -> Double? {
        guard byteTokenLogProbabilities.allSatisfy(\.isFinite)
        else {
            return nil
        }
        var executed = byteTokenLogProbabilities
        if terminatedByEOS {
            guard let eosLogProbability,
                  eosLogProbability.isFinite else {
                return nil
            }
            executed.append(eosLogProbability)
        } else if eosLogProbability != nil {
            return nil
        }
        guard !executed.isEmpty else { return nil }
        return executed.reduce(0, +) / Double(executed.count)
    }

    /// Orders already-ranked rows without recomputing an immutable rank from
    /// inside the sort comparator. The row ID is the frozen collision
    /// tiebreaker.
    static func orderedScheduleRowIDs(
        _ rankedRows: [(rowID: String, rank: String)]
    ) -> [String] {
        rankedRows.sorted { left, right in
            left.rank == right.rank
                ? left.rowID < right.rowID
                : left.rank < right.rank
        }.map(\.rowID)
    }

    /// Manifest-bound deterministic epoch permutation with semantic-family
    /// round-robin interleaving. This is an auditable schedule, not a learned
    /// or hand-authored curriculum order.
    public static func deterministicBalancedScheduleRowIDs(
        rows: [ErgenticsPrimeNativeTextCorpus.Row],
        seed: Int,
        count: Int,
        namespace: String,
        corpusManifestSHA256: String
    ) -> [String] {
        guard count > 0, !rows.isEmpty else { return [] }
        let families = Dictionary(
            grouping: rows,
            by: \.semanticFamily
        )
        let familyIDs = families.keys.sorted()
        var result = [String]()
        result.reserveCapacity(count)
        var epoch = 0
        while result.count < count {
            let queues = Dictionary(
                uniqueKeysWithValues: familyIDs.map { family in
                    (
                        family,
                        orderedScheduleRowIDs(
                            families[family]!.map { row in
                                let material = [
                                    corpusManifestSHA256,
                                    namespace,
                                    String(seed),
                                    String(epoch),
                                    row.rowID,
                                ].joined(separator: "|")
                                return (
                                    rowID: row.rowID,
                                    rank: SHA256.hash(
                                        data: Data(material.utf8)
                                    ).map {
                                        String(format: "%02x", $0)
                                    }.joined()
                                )
                            }
                        )
                    )
                }
            )
            var offsets = Dictionary(
                uniqueKeysWithValues: familyIDs.map { ($0, 0) }
            )
            var emitted = true
            while emitted, result.count < count {
                emitted = false
                for family in familyIDs {
                    let offset = offsets[family]!
                    guard offset < queues[family]!.count else {
                        continue
                    }
                    result.append(queues[family]![offset])
                    offsets[family] = offset + 1
                    emitted = true
                    if result.count == count { break }
                }
            }
            epoch += 1
        }
        return result
    }

    /// Interleaves the independently ranked valid and refusal schedules using
    /// the exact executor curriculum cadence.
    public static func interleavedValidAndRefusalScheduleRowIDs(
        valid: [String],
        refusal: [String],
        validRowsPerRefusal: Int
    ) -> [String]? {
        guard validRowsPerRefusal > 0 else { return nil }
        var result = [String]()
        result.reserveCapacity(valid.count + refusal.count)
        var validIndex = 0
        var refusalIndex = 0
        while validIndex < valid.count
            || refusalIndex < refusal.count
        {
            let validEnd = min(
                valid.count,
                validIndex + validRowsPerRefusal
            )
            if validIndex < validEnd {
                result.append(
                    contentsOf: valid[validIndex ..< validEnd]
                )
                validIndex = validEnd
            }
            if refusalIndex < refusal.count {
                result.append(refusal[refusalIndex])
                refusalIndex += 1
            }
        }
        return result
    }

    public struct RefusalReasonScheduleWitness:
        Equatable, Sendable
    {
        public let rowIDs: [String]
        public let reasonRowCounts: [String: Int]
        public let orderedReasonScheduleSHA256: String
    }

    /// Deterministic two-axis refusal schedule. Every 48-row block has eight
    /// rows from each semantic family and exposes all seven refusal reasons;
    /// row choice inside each family/reason stratum is SHA-256 ranked.
    public static func deterministicRefusalReasonSchedule(
        rows: [ErgenticsPrimeNativeTextCorpus.Row],
        seed: Int,
        blockCount: Int,
        namespace: String,
        corpusManifestSHA256: String
    ) -> RefusalReasonScheduleWitness? {
        guard blockCount > 0 else { return nil }
        let families =
            ErgenticsPrimeNativeTextCorpus.SemanticFamily
                .allCases.map(\.rawValue).sorted()
        let reasons =
            ErgenticsPrimeNativeTextCorpus.refusalReasonIDs.sorted()
        let ambiguousReason = "ambiguous_query"
        let byStratum = Dictionary(grouping: rows) {
            row -> String in
            "\(row.semanticFamily)|\(row.abstentionReason ?? "")"
        }
        var queues = [String: [String]]()
        var specificReasonByFamily = [String: String]()
        for family in families {
            let observedReasons = Set(
                rows.filter {
                    $0.semanticFamily == family
                }.compactMap(\.abstentionReason)
            )
            let specificReasons =
                observedReasons.subtracting([ambiguousReason])
            guard observedReasons.contains(ambiguousReason),
                  specificReasons.count == 1,
                  let specificReason = specificReasons.first else {
                return nil
            }
            specificReasonByFamily[family] = specificReason
            for reason in [ambiguousReason, specificReason] {
                let stratum = "\(family)|\(reason)"
                guard let candidates = byStratum[stratum],
                      !candidates.isEmpty else {
                    return nil
                }
                queues[stratum] = orderedScheduleRowIDs(
                    candidates.map { row in
                        let material = [
                            corpusManifestSHA256,
                            namespace,
                            String(seed),
                            family,
                            reason,
                            row.rowID,
                        ].joined(separator: "|")
                        return (
                            rowID: row.rowID,
                            rank: SHA256.hash(
                                data: Data(material.utf8)
                            ).map {
                                String(format: "%02x", $0)
                            }.joined()
                        )
                    }
                )
            }
        }
        var offsets = Dictionary(
            uniqueKeysWithValues:
                queues.keys.map { ($0, 0) }
        )
        var result = [String]()
        var scheduledReasons = [String]()
        result.reserveCapacity(blockCount * 48)
        scheduledReasons.reserveCapacity(blockCount * 48)
        for _ in 0 ..< blockCount {
            for family in families {
                for slot in 0 ..< 8 {
                    let reason =
                        slot == 0
                        ? ambiguousReason
                        : specificReasonByFamily[family]!
                    let stratum = "\(family)|\(reason)"
                    let offset = offsets[stratum]!
                    guard offset < queues[stratum]!.count else {
                        return nil
                    }
                    result.append(queues[stratum]![offset])
                    scheduledReasons.append(reason)
                    offsets[stratum] = offset + 1
                }
            }
        }
        let counts = Dictionary(
            grouping: scheduledReasons,
            by: { $0 }
        ).mapValues(\.count)
        guard Set(counts.keys) == Set(reasons),
              counts.values.reduce(0, +) == blockCount * 48
        else {
            return nil
        }
        let material = zip(result, scheduledReasons).map {
            "\($0.0)|\($0.1)"
        }.joined(separator: "\n")
        let hash = SHA256.hash(data: Data(material.utf8)).map {
            String(format: "%02x", $0)
        }.joined()
        return RefusalReasonScheduleWitness(
            rowIDs: result,
            reasonRowCounts: counts,
            orderedReasonScheduleSHA256: hash
        )
    }

    private static func exactProfile(
        _ binding: ProfileBinding
    ) -> ErgenticsNativeScaleEngineRecommend.ModelProfile? {
        guard let profile =
            ErgenticsNativeScaleEngineRecommend.profiles.first(
                where: { $0.profileID == binding.profileID }
            )
        else { return nil }
        let expected = profile.parameterCount(
            vocabularySize:
                PrimeNativeByteTokenizer.boundModelVocabularySize
        )
        guard binding.vocabularySize
                == PrimeNativeByteTokenizer.boundModelVocabularySize,
              binding.maximumSequenceLength
                == profile.maximumSequenceLength,
              binding.expectedParameterCount == expected,
              binding.observedParameterCount == expected,
              binding.observedTrainableParameterCount == expected else {
            return nil
        }
        return profile
    }

    private static func splitMetrics(
        _ rows: [RawPrediction]
    ) -> [SplitMetric] {
        Split.allCases.compactMap { split in
            let group = rows.filter { $0.split == split }
            guard !group.isEmpty else { return nil }
            return SplitMetric(
                split: split,
                role:
                    split == .validation
                    ? "selection_tuned_diagnostic"
                    : "independent_capability",
                count: group.count,
                zeroShotExactAccuracy:
                    Double(group.filter(\.zeroShotExactMatch).count)
                    / Double(group.count),
                trainedExactAccuracy:
                    Double(group.filter(\.trainedExactMatch).count)
                    / Double(group.count),
                trainedMeanLogProbability:
                    group.map(\.trainedMeanLogProbability)
                        .reduce(0, +) / Double(group.count)
            )
        }
    }

    private static func predictionRowsValid(
        _ report: Report
    ) -> Bool {
        let rows = report.rawPredictions
        let authorityRows = Dictionary(
            uniqueKeysWithValues:
                authorityEvaluationRows
                .map { ($0.rowID, $0) }
        )
        guard Set(rows.map(\.rowID)).count == rows.count,
              rows.allSatisfy({
                  guard let authorityRow = authorityRows[$0.rowID]
                  else { return false }
                  let zeroDecoded =
                      try? PrimeNativeByteTokenizer.decode(
                          $0.zeroShotPredictionTokenIDs
                      )
                  let trainedDecoded =
                      try? PrimeNativeByteTokenizer.decode(
                          $0.trainedPredictionTokenIDs
                      )
                  let zeroShotVerification = zeroDecoded.map {
                      ErgenticsPrimeNativeTextCorpus
                          .verifyGeneratedCompletion(
                              row: authorityRow,
                              completion: $0
                          )
                  }
                  let trainedVerification = trainedDecoded.map {
                      ErgenticsPrimeNativeTextCorpus
                          .verifyGeneratedCompletion(
                              row: authorityRow,
                              completion: $0
                          )
                  }
                  let zeroSemantic =
                      $0.zeroShotTerminatedByEOS
                          && (
                              zeroShotVerification?.semanticMatch
                                  ?? false
                          )
                  let trainedSemantic =
                      $0.trainedTerminatedByEOS
                          && (
                              trainedVerification?.semanticMatch
                                  ?? false
                          )
                  let zeroAbstention =
                      $0.zeroShotTerminatedByEOS
                          && (
                              zeroShotVerification?
                                  .abstentionDecision
                                  ?? false
                          )
                  let trainedAbstention =
                      $0.trainedTerminatedByEOS
                          && (
                              trainedVerification?
                                  .abstentionDecision
                                  ?? false
                          )
                  let zeroShotExecutedMean =
                      executedDecisionMeanLogProbability(
                          byteTokenLogProbabilities:
                              $0.zeroShotTokenLogProbabilities,
                          eosLogProbability:
                              $0.zeroShotEOSLogProbability,
                          terminatedByEOS:
                              $0.zeroShotTerminatedByEOS
                      )
                  let trainedExecutedMean =
                      executedDecisionMeanLogProbability(
                          byteTokenLogProbabilities:
                              $0.trainedTokenLogProbabilities,
                          eosLogProbability:
                              $0.trainedEOSLogProbability,
                          terminatedByEOS:
                              $0.trainedTerminatedByEOS
                      )
                  return !$0.rowID.isEmpty
                      && isSHA256($0.corpusRowSHA256)
                      && isSHA256($0.evaluationRowSHA256)
                      && authorityRow.rowSHA256
                          == $0.corpusRowSHA256
                      && authorityRow.evaluationRowSHA256
                          == $0.evaluationRowSHA256
                      && !$0.semanticFamily.isEmpty
                      && !$0.invariantIDs.isEmpty
                      && !$0.prompt.isEmpty
                      && $0.promptTokenIDs
                          == [
                              PrimeNativeByteTokenizer
                                  .beginningOfSequenceTokenID
                          ] + PrimeNativeByteTokenizer.encode(
                              $0.prompt
                          )
                      && $0.promptGroupingKeyID
                          == promptGroupingKeyID
                      && $0.promptGroupingKey
                          == $0.promptTokenIDs.count - 1
                      && $0.generationDecisionBudget
                          == maximumGenerationTokenDecisions
                      && $0.allowedCompletionTokenSetSHA256
                          == allowedCompletionTokenSetSHA256
                      && $0.eosAvailableAtEveryDecision
                      && $0.targetIndependentDecisionBudget
                      && !$0.target.isEmpty
                      && $0.targetTokenIDs
                          == PrimeNativeByteTokenizer.encode(
                              $0.target
                          )
                      && !$0.targetTokenIDs.isEmpty
                      && $0.targetTokenIDs.allSatisfy {
                          (0 ..<
                              PrimeNativeByteTokenizer
                                  .boundModelVocabularySize)
                              .contains($0)
                      }
                      && $0.zeroShotPredictionTokenIDs.allSatisfy {
                          PrimeNativeByteTokenizer.byteTokenRange
                              .contains($0)
                      }
                      && $0.trainedPredictionTokenIDs.allSatisfy {
                          PrimeNativeByteTokenizer.byteTokenRange
                              .contains($0)
                      }
                      && $0.zeroShotPredictionTokenIDs.count
                          + ($0.zeroShotTerminatedByEOS ? 1 : 0)
                          <= maximumGenerationTokenDecisions
                      && $0.zeroShotDecisionsExecuted
                          == $0.zeroShotPredictionTokenIDs.count
                              + (
                                  $0.zeroShotTerminatedByEOS
                                  ? 1 : 0
                              )
                      && $0.zeroShotDecisionsExecuted
                          <= $0.generationDecisionBudget
                      && $0.trainedPredictionTokenIDs.count
                          + ($0.trainedTerminatedByEOS ? 1 : 0)
                          <= maximumGenerationTokenDecisions
                      && $0.trainedDecisionsExecuted
                          == $0.trainedPredictionTokenIDs.count
                              + (
                                  $0.trainedTerminatedByEOS
                                  ? 1 : 0
                              )
                      && $0.trainedDecisionsExecuted
                          <= $0.generationDecisionBudget
                      && $0
                          .zeroShotDisallowedFullVocabularyArgmaxCount
                          >= 0
                      && $0
                          .zeroShotDisallowedFullVocabularyArgmaxCount
                          <= $0.zeroShotDecisionsExecuted
                      && $0
                          .zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity
                          == (
                              $0
                                  .zeroShotDisallowedFullVocabularyArgmaxCount
                                  == 0
                          )
                      && $0
                          .zeroShotMaximumDisallowedTokenProbabilityMass
                          .isFinite
                      && $0
                          .zeroShotMaximumDisallowedTokenProbabilityMass
                          >= 0
                      && $0
                          .zeroShotMaximumDisallowedTokenProbabilityMass
                          <= 1.000_001
                      && $0
                          .trainedDisallowedFullVocabularyArgmaxCount
                          >= 0
                      && $0
                          .trainedDisallowedFullVocabularyArgmaxCount
                          <= $0.trainedDecisionsExecuted
                      && $0
                          .trainedRawFullVocabularyAllowedSupportGreedyTokenParity
                          == (
                              $0
                                  .trainedDisallowedFullVocabularyArgmaxCount
                                  == 0
                          )
                      && $0
                          .trainedMaximumDisallowedTokenProbabilityMass
                          .isFinite
                      && $0
                          .trainedMaximumDisallowedTokenProbabilityMass
                          >= 0
                      && $0
                          .trainedMaximumDisallowedTokenProbabilityMass
                          <= 1.000_001
                      && (
                          $0.split == .validation
                          || (
                              $0
                                  .trainedRawFullVocabularyAllowedSupportGreedyTokenParity
                                  && $0
                                      .trainedDisallowedFullVocabularyArgmaxCount
                                      == 0
                          )
                      )
                      && (
                          $0.zeroShotTerminatedByEOS
                          ? (
                              $0.zeroShotTerminationReason == "eos"
                                  && $0.zeroShotEOSLogProbability?
                                      .isFinite == true
                          )
                          : (
                              $0.zeroShotTerminationReason
                                  == "fixed_cap"
                                  && $0.zeroShotEOSLogProbability
                                      == nil
                                  && $0.zeroShotPredictionTokenIDs
                                      .count
                                      == maximumGenerationTokenDecisions
                          )
                      )
                      && (
                          $0.trainedTerminatedByEOS
                          ? (
                              $0.trainedTerminationReason == "eos"
                                  && $0.trainedEOSLogProbability?
                                      .isFinite == true
                          )
                          : (
                              $0.trainedTerminationReason
                                  == "fixed_cap"
                                  && $0.trainedEOSLogProbability == nil
                                  && $0.trainedPredictionTokenIDs
                                      .count
                                      == maximumGenerationTokenDecisions
                          )
                      )
                      && $0.zeroShotMeanLogProbability.isFinite
                      && $0.trainedMeanLogProbability.isFinite
                      && $0.zeroShotTokenLogProbabilities.count
                          == $0.zeroShotPredictionTokenIDs.count
                      && $0.trainedTokenLogProbabilities.count
                          == $0.trainedPredictionTokenIDs.count
                      && $0.zeroShotTokenLogProbabilities
                          .allSatisfy(\.isFinite)
                      && $0.trainedTokenLogProbabilities
                          .allSatisfy(\.isFinite)
                      && zeroShotExecutedMean != nil
                      && trainedExecutedMean != nil
                      && abs(
                          $0.zeroShotMeanLogProbability
                              - zeroShotExecutedMean!
                      ) <= 1e-12
                      && abs(
                          $0.trainedMeanLogProbability
                              - trainedExecutedMean!
                      ) <= 1e-12
                      && finitePositive($0.zeroShotLatencySeconds)
                      && finitePositive($0.trainedLatencySeconds)
                      && (
                          try? PrimeNativeByteTokenizer.decode(
                              $0.targetTokenIDs
                          )
                      ) == $0.target
                      && $0.zeroShotUTF8Valid
                          == (zeroDecoded != nil)
                      && $0.trainedUTF8Valid
                          == (trainedDecoded != nil)
                      && zeroDecoded == $0.zeroShotPrediction
                      && trainedDecoded == $0.trainedPrediction
                      && $0.zeroShotExactMatch
                          == (
                              $0.zeroShotTerminatedByEOS
                                  && $0.zeroShotPredictionTokenIDs
                                  == $0.targetTokenIDs
                          )
                      && $0.trainedExactMatch
                          == (
                              $0.trainedTerminatedByEOS
                                  && $0.trainedPredictionTokenIDs
                                  == $0.targetTokenIDs
                          )
                      && $0.zeroShotSemanticVerifierPass
                          == zeroSemantic
                      && $0.trainedSemanticVerifierPass
                          == trainedSemantic
                      && $0.zeroShotAbstentionDecision
                          == zeroAbstention
                      && $0.trainedAbstentionDecision
                          == trainedAbstention
                      && ($0.split != .mutation
                          || !($0.mutationID ?? "").isEmpty)
                      && ($0.split != .abstention
                          || (
                              $0.target == "ABSTAIN\n"
                                  && !($0.abstentionReason ?? "")
                                      .isEmpty
                          ))
              }) else {
            return false
        }
        let observed = Dictionary(
            uniqueKeysWithValues: Split.allCases.map { split in
                (split, rows.filter { $0.split == split }.count)
            }
        )
        return report.corpus.expectedEvaluationRows.allSatisfy {
            split, count in
            count == (minimumEvaluationRows[split] ?? .max)
                && observed[split] == count
        } && Set(report.corpus.expectedEvaluationRows.keys)
            == Set(Split.allCases)
            && report.corpus.expectedEvaluationRowSHA256.count
                == rows.count
            && report.corpus.expectedEvaluationContractSHA256.count
                == rows.count
            && rows.allSatisfy {
                report.corpus.expectedEvaluationRowSHA256[$0.rowID]
                    == $0.corpusRowSHA256
                    && report.corpus
                        .expectedEvaluationContractSHA256[$0.rowID]
                        == $0.evaluationRowSHA256
            }
            && Set(
                report.corpus.expectedSemanticFamilyRows.keys
            ) == Set(Split.allCases)
            && Split.allCases.allSatisfy { split in
                let observedFamilies = Dictionary(
                    grouping: rows.filter { $0.split == split },
                    by: \.semanticFamily
                ).mapValues(\.count)
                guard let expectedFamilies =
                    report.corpus.expectedSemanticFamilyRows[split],
                    expectedFamilies.count
                        >= minimumSemanticFamilyCount,
                    expectedFamilies == observedFamilies else {
                    return false
                }
                let splitMinimum =
                    minimumEvaluationRows[split] ?? .max
                let familyMinimum =
                    splitMinimum / minimumSemanticFamilyCount
                return expectedFamilies.values.allSatisfy {
                    $0 >= familyMinimum
                }
            }
    }

    private static func capabilityGrounded(
        _ metrics: [SplitMetric]
    ) -> Bool {
        let bySplit = Dictionary(
            uniqueKeysWithValues: metrics.map { ($0.split, $0) }
        )
        guard let combination = bySplit[.combinationHoldout],
              let ood = bySplit[.outOfDistribution],
              let mutation = bySplit[.mutation],
              let abstention = bySplit[.abstention] else {
            return false
        }
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

    private static func heldoutLossEvidenceBound(
        _ report: Report
    ) -> Bool {
        let training = report.training
        let rows = training.heldoutLossRows.sorted {
            $0.rowID < $1.rowID
        }
        let requiredFamilies = Set(
            ErgenticsPrimeNativeTextCorpus.SemanticFamily
                .allCases.map(\.rawValue)
        )
        let validRows = rows.filter {
            $0.targetClass == "valid_completion"
        }
        let refusalRows = rows.filter {
            $0.targetClass == "refusal_abstain"
        }
        guard training.scheduledRefusalRowCount
                .isMultiple(of: 48),
              let scheduledRefusalWitness =
                deterministicRefusalReasonSchedule(
                    rows:
                        ErgenticsPrimeNativeTextCorpus.rows(
                            for: .refusalTrain
                        ),
                    seed: report.seed,
                    blockCount:
                        training.scheduledRefusalRowCount / 48,
                    namespace:
                        "balanced_refusal_reason_stratified_train_v2",
                    corpusManifestSHA256:
                        report.corpus.manifestSHA256
                ),
              let heldoutRefusalWitness =
                deterministicRefusalReasonSchedule(
                    rows:
                        ErgenticsPrimeNativeTextCorpus.rows(
                            for: .refusalValidation
                        ),
                    seed: report.seed,
                    blockCount: 1,
                    namespace:
                        "balanced_refusal_reason_stratified_selection_v2",
                    corpusManifestSHA256:
                        report.corpus.manifestSHA256
                ),
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
              Set(refusalRows.map(\.rowID))
                == Set(heldoutRefusalWitness.rowIDs)
        else {
            return false
        }
        guard rows.count == training.heldoutRowCount,
              Set(rows.map(\.rowID)).count == rows.count,
              Set(rows.map(\.rowSHA256)).count == rows.count,
              rows.allSatisfy({ row in
                  !row.rowID.isEmpty
                      && isSHA256(row.rowSHA256)
                      && requiredFamilies.contains(
                          row.semanticFamily
                      )
                      && row.targetTokenCount > 0
                      && row.nonPaddingTokenCount
                          > row.targetTokenCount
                      && row.crossEntropyBefore.isFinite
                      && row.crossEntropyBefore > 0
                      && row.crossEntropyAfter.isFinite
                      && row.crossEntropyAfter >= 0
                      && {
                          guard let authority =
                              authoritySelectionRowsByID[row.rowID]
                          else { return false }
                          let expectedClass =
                              authority.split
                                  == ErgenticsPrimeNativeTextCorpus
                                      .Split.refusalValidation
                                      .rawValue
                              ? "refusal_abstain"
                              : "valid_completion"
                          return authority.rowSHA256
                                  == row.rowSHA256
                              && authority.semanticFamily
                                  == row.semanticFamily
                              && authority.split
                                  == row.selectionSplitID
                              && expectedClass == row.targetClass
                              && row.targetTokenCount
                                  == authority.completionTokenCount
                              && row.nonPaddingTokenCount
                                  == authority.sequenceTokenCount
                      }()
              }),
              training.selectionValidationSplitIDs
                == [
                    ErgenticsPrimeNativeTextCorpus.Split.validation
                        .rawValue,
                    ErgenticsPrimeNativeTextCorpus.Split
                        .refusalValidation.rawValue,
                ],
              validRows.count == training.heldoutValidRowCount,
              refusalRows.count == training.heldoutRefusalRowCount,
              training.heldoutValidRowCount == 240,
              training.heldoutRefusalRowCount == 48,
              Dictionary(
                  grouping: validRows,
                  by: \.semanticFamily
              ).mapValues(\.count)
                == training.heldoutValidSemanticFamilyRows,
              Dictionary(
                  grouping: refusalRows,
                  by: \.semanticFamily
              ).mapValues(\.count)
                == training.heldoutRefusalSemanticFamilyRows,
              training.heldoutValidSemanticFamilyRows.count == 6,
              training.heldoutValidSemanticFamilyRows.values
                .allSatisfy({ $0 == 40 }),
              training.heldoutRefusalSemanticFamilyRows.count == 6,
              training.heldoutRefusalSemanticFamilyRows.values
                .allSatisfy({ $0 == 8 }),
              training.trainingHeldoutRowHashIntersectionCount
                == 0 else {
            return false
        }
        func agrees(_ left: Double, _ right: Double) -> Bool {
            abs(left - right)
                <= max(1e-12, abs(right) * 1e-12)
        }
        guard let targetTokens = exactIntegerSum(
                  rows.map(\.targetTokenCount)
              ),
              let nonPadding = exactIntegerSum(
                  rows.map(\.nonPaddingTokenCount)
              ),
              let doubledNonPadding = exactIntegerProduct([
                  nonPadding,
                  2,
              ]),
              targetTokens == training.heldoutTargetTokenCount,
              doubledNonPadding
                == training
                    .heldoutEvaluationNonPaddingTokenCount,
              finitePositive(
                  training.heldoutEvaluationElapsedSeconds
              ) else {
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
        func classAggregate(
            _ classRows: [HeldoutLossRow]
        ) -> (Int, Double, Double)? {
            guard let tokens = exactIntegerSum(
                      classRows.map(\.targetTokenCount)
                  ),
                  tokens > 0 else {
                return nil
            }
            let weight = Double(tokens)
            return (
                tokens,
                classRows.reduce(0.0) {
                    $0
                        + $1.crossEntropyBefore
                            * Double($1.targetTokenCount)
                } / weight,
                classRows.reduce(0.0) {
                    $0
                        + $1.crossEntropyAfter
                            * Double($1.targetTokenCount)
                } / weight
            )
        }
        guard let validAggregate = classAggregate(validRows),
              let refusalAggregate = classAggregate(refusalRows),
              validAggregate.0
                == training.heldoutValidTargetTokenCount,
              refusalAggregate.0
                == training.heldoutRefusalTargetTokenCount,
              validAggregate.0 + refusalAggregate.0
                == training.heldoutTargetTokenCount,
              agrees(
                  validAggregate.1,
                  training.heldoutValidCrossEntropyBefore
              ),
              agrees(
                  validAggregate.2,
                  training.heldoutValidCrossEntropyAfter
              ),
              agrees(
                  refusalAggregate.1,
                  training.heldoutRefusalCrossEntropyBefore
              ),
              agrees(
                  refusalAggregate.2,
                  training.heldoutRefusalCrossEntropyAfter
              )
        else {
            return false
        }
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
                + Double($1.targetTokenCount) * delta * delta
        }
        let variance =
            denominator > 0
            ? squaredDeviation / denominator
            : 0
        let standardError =
            sqrt(variance / max(1, effectiveRows))
        let beforeByFamily = Dictionary(
            grouping: rows,
            by: \.semanticFamily
        ).mapValues { familyRows in
            let tokens =
                familyRows.map(\.targetTokenCount).reduce(0, +)
            return familyRows.reduce(0.0) {
                $0
                    + $1.crossEntropyBefore
                        * Double($1.targetTokenCount)
            } / Double(tokens)
        }
        let afterByFamily = Dictionary(
            grouping: rows,
            by: \.semanticFamily
        ).mapValues { familyRows in
            let tokens =
                familyRows.map(\.targetTokenCount).reduce(0, +)
            return familyRows.reduce(0.0) {
                $0
                    + $1.crossEntropyAfter
                        * Double($1.targetTokenCount)
            } / Double(tokens)
        }
        guard Set(beforeByFamily.keys) == requiredFamilies,
              Set(afterByFamily.keys) == requiredFamilies,
              Set(training.heldoutFamilyCrossEntropyBefore.keys)
                == requiredFamilies,
              Set(training.heldoutFamilyCrossEntropyAfter.keys)
                == requiredFamilies,
              requiredFamilies.allSatisfy({ family in
                  agrees(
                      beforeByFamily[family]!,
                      training
                          .heldoutFamilyCrossEntropyBefore[family]!
                  )
                      && agrees(
                          afterByFamily[family]!,
                          training
                              .heldoutFamilyCrossEntropyAfter[
                                  family
                              ]!
                      )
              }) else {
            return false
        }
        return agrees(before, training.heldoutCrossEntropyBefore)
            && agrees(after, training.heldoutCrossEntropyAfter)
            && agrees(
                standardError,
                training.heldoutCrossEntropyStandardError
            )
            && training
                .heldoutCrossEntropyStandardErrorMethodID
                == "target_token_weighted_row_unbiased_effective_n_v1"
            && agrees(training.initialLoss, before)
            && agrees(training.finalLoss, after)
            && (
                report.mode != .fullCanary
                    || (
                        training.heldoutValidCrossEntropyAfter
                            <= training
                                .heldoutValidCrossEntropyBefore
                                + 0.01
                            && training
                                .heldoutRefusalCrossEntropyAfter
                                <= training
                                    .heldoutRefusalCrossEntropyBefore
                                    + 0.01
                    )
            )
    }

    private struct SelectedParameterFingerprintPayload: Encodable {
        let name: String
        let shape: [Int]
        let dtype: String
        let indices: [Int]
        let floatBitPatterns: [UInt32]
    }

    private struct FixedPromptReplayFingerprintPayload: Encodable {
        let logitFloatBitPatterns: [UInt32]
        let greedyTokenID: Int
    }

    private struct SelectedParameterReplayRegrade {
        let firstFingerprintSHA256: String
        let replayFingerprintSHA256: String
        let maximumDelta: Double
        let exact: Bool
        let zeroDeltaMatchesHashEquality: Bool
    }

    private struct FixedPromptReplayRegrade {
        let firstResultSHA256: String
        let replayResultSHA256: String
        let maximumLogitDelta: Double
        let firstGreedyTokenID: Int
        let replayGreedyTokenID: Int
        let firstGreedyRunnerUpMargin: Double
        let replayGreedyRunnerUpMargin: Double
        let greedyTokenExact: Bool
        let behavioralReplayExact: Bool
        let resultExact: Bool
        let zeroDeltaMatchesHashEquality: Bool
    }

    private static func canonicalPayloadSHA256<T: Encodable>(
        _ value: T
    ) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        guard let data = try? encoder.encode(value) else {
            return nil
        }
        return SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private static func selectedParameterSampleValid(
        _ sample: SelectedParameterSample
    ) -> Bool {
        guard !sample.name.isEmpty,
              !sample.shape.isEmpty,
              sample.shape.allSatisfy({ $0 > 0 }),
              sample.dtype == requiredPrecision,
              !sample.indices.isEmpty,
              sample.indices == sample.indices.sorted(),
              Set(sample.indices).count == sample.indices.count,
              sample.indices.count == sample.floatBitPatterns.count,
              sample.floatBitPatterns.allSatisfy({
                  Float(bitPattern: $0).isFinite
              }) else {
            return false
        }
        var elementCount = 1
        for dimension in sample.shape {
            let product =
                elementCount.multipliedReportingOverflow(
                    by: dimension
                )
            guard !product.overflow else { return false }
            elementCount = product.partialValue
        }
        let expectedIndices = Array(
            Set([
                0,
                max(0, elementCount / 2),
                max(0, elementCount - 1),
            ])
        ).sorted()
        return sample.indices == expectedIndices
    }

    private static func selectedParameterReplayRegrade(
        first: [SelectedParameterSample],
        replay: [SelectedParameterSample],
        expectedLayout: [(name: String, shape: [Int])]
    ) -> SelectedParameterReplayRegrade? {
        guard !first.isEmpty,
              first.count == replay.count,
              first.count == expectedLayout.count,
              first.map(\.name) == first.map(\.name).sorted(),
              Set(first.map(\.name)).count == first.count,
              first.allSatisfy(selectedParameterSampleValid),
              replay.allSatisfy(selectedParameterSampleValid),
              zip(first, expectedLayout).allSatisfy({ pair in
                  pair.0.name == pair.1.name
                      && pair.0.shape == pair.1.shape
              }),
              first.map(\.name) == replay.map(\.name),
              first.map(\.shape) == replay.map(\.shape),
              first.map(\.dtype) == replay.map(\.dtype),
              first.map(\.indices) == replay.map(\.indices),
              let firstHash = canonicalPayloadSHA256(
                  first.map {
                      SelectedParameterFingerprintPayload(
                          name: $0.name,
                          shape: $0.shape,
                          dtype: $0.dtype,
                          indices: $0.indices,
                          floatBitPatterns: $0.floatBitPatterns
                      )
                  }
              ),
              let replayHash = canonicalPayloadSHA256(
                  replay.map {
                      SelectedParameterFingerprintPayload(
                          name: $0.name,
                          shape: $0.shape,
                          dtype: $0.dtype,
                          indices: $0.indices,
                          floatBitPatterns: $0.floatBitPatterns
                      )
                  }
              ) else {
            return nil
        }
        let maximumDelta = zip(first, replay).flatMap {
            left, right in
            zip(
                left.floatBitPatterns,
                right.floatBitPatterns
            ).map {
                abs(
                    Double(Float(bitPattern: $0.0))
                        - Double(Float(bitPattern: $0.1))
                )
            }
        }.max() ?? 0
        guard maximumDelta.isFinite else { return nil }
        let hashesEqual = firstHash == replayHash
        let deltaZero = maximumDelta == 0
        return SelectedParameterReplayRegrade(
            firstFingerprintSHA256: firstHash,
            replayFingerprintSHA256: replayHash,
            maximumDelta: maximumDelta,
            exact: hashesEqual && deltaZero,
            zeroDeltaMatchesHashEquality:
                deltaZero == hashesEqual
        )
    }

    private static func fixedPromptGreedyDecision(
        _ logits: [Float]
    ) -> (tokenID: Int, runnerUpMargin: Double)? {
        guard logits.count
                == PrimeNativeByteTokenizer
                    .boundModelVocabularySize,
              logits.allSatisfy(\.isFinite),
              let greedy = logits.enumerated().max(by: {
                  $0.element < $1.element
              }),
              let runnerUp = logits.enumerated()
                .filter({ $0.offset != greedy.offset })
                .map(\.element).max() else {
            return nil
        }
        let margin =
            Double(greedy.element) - Double(runnerUp)
        guard margin.isFinite, margin >= 0 else { return nil }
        return (greedy.offset, margin)
    }

    private static func fixedPromptReplayRegrade(
        firstBitPatterns: [UInt32],
        replayBitPatterns: [UInt32]
    ) -> FixedPromptReplayRegrade? {
        guard firstBitPatterns.count
                == PrimeNativeByteTokenizer
                    .boundModelVocabularySize,
              replayBitPatterns.count
                == PrimeNativeByteTokenizer
                    .boundModelVocabularySize else {
            return nil
        }
        let first = firstBitPatterns.map {
            Float(bitPattern: $0)
        }
        let replay = replayBitPatterns.map {
            Float(bitPattern: $0)
        }
        guard let firstDecision =
                fixedPromptGreedyDecision(first),
              let replayDecision =
                fixedPromptGreedyDecision(replay) else {
            return nil
        }
        let maximumDelta = zip(first, replay).map {
            abs(Double($0.0) - Double($0.1))
        }.max() ?? 0
        guard maximumDelta.isFinite,
              let firstHash = canonicalPayloadSHA256(
                  FixedPromptReplayFingerprintPayload(
                      logitFloatBitPatterns: firstBitPatterns,
                      greedyTokenID: firstDecision.tokenID
                  )
              ),
              let replayHash = canonicalPayloadSHA256(
                  FixedPromptReplayFingerprintPayload(
                      logitFloatBitPatterns: replayBitPatterns,
                      greedyTokenID: replayDecision.tokenID
                  )
              ) else {
            return nil
        }
        let greedyExact =
            firstDecision.tokenID == replayDecision.tokenID
        let doubledDelta = 2 * maximumDelta
        let behavioralExact =
            firstDecision.runnerUpMargin > 0
                && replayDecision.runnerUpMargin > 0
                && greedyExact
                && doubledDelta.isFinite
                && doubledDelta
                    < min(
                        firstDecision.runnerUpMargin,
                        replayDecision.runnerUpMargin
                    )
        let hashesEqual = firstHash == replayHash
        let deltaZero = maximumDelta == 0
        return FixedPromptReplayRegrade(
            firstResultSHA256: firstHash,
            replayResultSHA256: replayHash,
            maximumLogitDelta: maximumDelta,
            firstGreedyTokenID: firstDecision.tokenID,
            replayGreedyTokenID: replayDecision.tokenID,
            firstGreedyRunnerUpMargin:
                firstDecision.runnerUpMargin,
            replayGreedyRunnerUpMargin:
                replayDecision.runnerUpMargin,
            greedyTokenExact: greedyExact,
            behavioralReplayExact: behavioralExact,
            resultExact: hashesEqual && deltaZero,
            zeroDeltaMatchesHashEquality:
                deltaZero == hashesEqual
        )
    }

    static func expectedSelectedParameterSampleLayout(
        _ binding: ProfileBinding
    ) -> [(name: String, shape: [Int])]? {
        guard let profile = exactProfile(binding) else {
            return nil
        }
        let dimension = profile.modelDimension
        let queryDimension =
            profile.attentionHeads * profile.headDimension
        let keyValueDimension =
            profile.keyValueHeads * profile.headDimension
        let feedForward = profile.feedForwardDimension
        var layout: [(name: String, shape: [Int])] = [
            (
                "model.embed_tokens.weight",
                [
                    PrimeNativeByteTokenizer
                        .boundModelVocabularySize,
                    dimension,
                ]
            ),
            ("model.norm.weight", [dimension]),
        ]
        for layer in 0 ..< profile.layerCount {
            let prefix = "model.layers.\(layer)"
            layout.append(
                contentsOf: [
                    (
                        "\(prefix).input_layernorm.weight",
                        [dimension]
                    ),
                    (
                        "\(prefix).mlp.down_proj.weight",
                        [dimension, feedForward]
                    ),
                    (
                        "\(prefix).mlp.gate_proj.weight",
                        [feedForward, dimension]
                    ),
                    (
                        "\(prefix).mlp.up_proj.weight",
                        [feedForward, dimension]
                    ),
                    (
                        "\(prefix).post_attention_layernorm.weight",
                        [dimension]
                    ),
                    (
                        "\(prefix).self_attn.k_proj.weight",
                        [keyValueDimension, dimension]
                    ),
                    (
                        "\(prefix).self_attn.o_proj.weight",
                        [dimension, queryDimension]
                    ),
                    (
                        "\(prefix).self_attn.q_proj.weight",
                        [queryDimension, dimension]
                    ),
                    (
                        "\(prefix).self_attn.v_proj.weight",
                        [keyValueDimension, dimension]
                    ),
                ]
            )
        }
        return layout.sorted { $0.name < $1.name }
    }

    struct SameSeedReplayScheduleCacheKey:
        Hashable, Sendable
    {
        let seed: Int
        let measuredSequenceLength: Int
        let effectiveBatchSize: Int
        let scheduledValidRowCount: Int
        let scheduledRefusalRowCount: Int
        let corpusManifestSHA256: String
    }

    private final class SameSeedReplayScheduleCache:
        @unchecked Sendable
    {
        private let lock = NSLock()
        private var prefixes =
            [SameSeedReplayScheduleCacheKey: [String]]()
        private let maximumEntryCount = 64

        func value(
            for key: SameSeedReplayScheduleCacheKey,
            compute: () -> [String]?
        ) -> [String]? {
            lock.lock()
            let cached = prefixes[key]
            lock.unlock()
            if let cached { return cached }

            guard let computed = compute() else {
                return nil
            }
            lock.lock()
            if prefixes.count >= maximumEntryCount {
                prefixes.removeAll(keepingCapacity: true)
            }
            prefixes[key] = computed
            lock.unlock()
            return computed
        }
    }

    private static let sameSeedReplayScheduleCache =
        SameSeedReplayScheduleCache()

    static func sameSeedReplayScheduleCacheKey(
        seed: Int,
        measuredSequenceLength: Int,
        effectiveBatchSize: Int,
        scheduledValidRowCount: Int,
        scheduledRefusalRowCount: Int,
        corpusManifestSHA256: String
    ) -> SameSeedReplayScheduleCacheKey {
        SameSeedReplayScheduleCacheKey(
            seed: seed,
            measuredSequenceLength: measuredSequenceLength,
            effectiveBatchSize: effectiveBatchSize,
            scheduledValidRowCount: scheduledValidRowCount,
            scheduledRefusalRowCount:
                scheduledRefusalRowCount,
            corpusManifestSHA256: corpusManifestSHA256
        )
    }

    static func expectedSameSeedReplaySchedulePrefix(
        seed: Int,
        measuredSequenceLength: Int,
        effectiveBatchSize: Int,
        scheduledValidRowCount: Int,
        scheduledRefusalRowCount: Int,
        corpusManifestSHA256: String
    ) -> [String]? {
        let scheduledTotal =
            scheduledValidRowCount.addingReportingOverflow(
                scheduledRefusalRowCount
            )
        guard measuredSequenceLength > 0,
              effectiveBatchSize > 0,
              scheduledValidRowCount > 0,
              scheduledRefusalRowCount > 0,
              scheduledRefusalRowCount.isMultiple(of: 48),
              !scheduledTotal.overflow,
              scheduledTotal.partialValue
                >= effectiveBatchSize else {
            return nil
        }
        let key = sameSeedReplayScheduleCacheKey(
            seed: seed,
            measuredSequenceLength: measuredSequenceLength,
            effectiveBatchSize: effectiveBatchSize,
            scheduledValidRowCount: scheduledValidRowCount,
            scheduledRefusalRowCount:
                scheduledRefusalRowCount,
            corpusManifestSHA256: corpusManifestSHA256
        )
        return sameSeedReplayScheduleCache.value(for: key) {
            let validRows =
                ErgenticsPrimeNativeTextCorpus.rows(for: .train)
                    .filter {
                        $0.sequenceTokenCount
                            <= measuredSequenceLength
                    }
            let refusalRows =
                ErgenticsPrimeNativeTextCorpus.rows(
                    for: .refusalTrain
                ).filter {
                    $0.sequenceTokenCount
                        <= measuredSequenceLength
                }
            // The report carries only the first effective batch. Deterministic
            // schedules are prefix-stable, so derive only the source prefixes
            // that can contribute to that witness rather than materializing a
            // full-canary schedule with millions of repeated rows.
            let neededValidCount = min(
                scheduledValidRowCount,
                effectiveBatchSize
            )
            let neededRefusalCount = min(
                scheduledRefusalRowCount,
                effectiveBatchSize
            )
            let valid = deterministicBalancedScheduleRowIDs(
                rows: validRows,
                seed: seed,
                count: neededValidCount,
                namespace: "balanced_valid_train_v1",
                corpusManifestSHA256: corpusManifestSHA256
            )
            let neededRefusalBlocks =
                (neededRefusalCount - 1) / 48 + 1
            guard valid.count == neededValidCount,
                  let refusalWitness =
                    deterministicRefusalReasonSchedule(
                        rows: refusalRows,
                        seed: seed,
                        blockCount: neededRefusalBlocks,
                        namespace:
                            "balanced_refusal_reason_stratified_train_v2",
                        corpusManifestSHA256:
                            corpusManifestSHA256
                    ),
                  refusalWitness.rowIDs.count
                    >= neededRefusalCount,
                  let scheduled =
                    interleavedValidAndRefusalScheduleRowIDs(
                        valid: valid,
                        refusal: Array(
                            refusalWitness.rowIDs.prefix(
                                neededRefusalCount
                            )
                        ),
                        validRowsPerRefusal: 5
                    ),
                  scheduled.count >= effectiveBatchSize else {
                return nil
            }
            return Array(
                scheduled.prefix(effectiveBatchSize)
            )
        }
    }

    private static func expectedSameSeedReplaySchedulePrefix(
        _ report: Report
    ) -> [String]? {
        expectedSameSeedReplaySchedulePrefix(
            seed: report.seed,
            measuredSequenceLength:
                report.training.measuredSequenceLength,
            effectiveBatchSize:
                report.training.effectiveBatchSize,
            scheduledValidRowCount:
                report.training.scheduledValidRowCount,
            scheduledRefusalRowCount:
                report.training.scheduledRefusalRowCount,
            corpusManifestSHA256:
                report.corpus.manifestSHA256
        )
    }

    private static func reportSHA256(_ report: Report) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        // Mutation regrade must return ABSTAIN for non-finite evidence rather
        // than trapping while hashing the rejected report.
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "Infinity",
            negativeInfinity: "-Infinity",
            nan: "NaN"
        )
        let data = try! encoder.encode(report)
        return SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    public static func recommend(_ report: Report) -> Recommendation {
        let profile = exactProfile(report.profile)
        let schemaBound =
            report.schemaVersion == schemaVersion
                && report.familyID == familyID
                && report.lineageID == lineageID
                && report.generationContractID
                    == generationContractID
        let independentLineage =
            report.parentCheckpointSHA256 == nil
                && report.legacySymbolicManifestSHA256 == nil
                && !report.implementation.importedBaseWeights
                && !report.implementation.pythonProducedEvidence
        let tokenizerBound =
            report.tokenizer.tokenizerID
                == PrimeNativeByteTokenizer.tokenizerID
                && report.tokenizer.vocabularySize
                    == PrimeNativeByteTokenizer
                        .boundModelVocabularySize
                && report.tokenizer.manifestSHA256
                    == PrimeNativeByteTokenizer.manifest()
                        .manifestSHA256
                && report.tokenizer.deterministicReplayPassed
                && report.tokenizer
                    .independentFoundationReplayPassed
        let authorityMaximumPromptTokenCount =
            authorityEvaluationRows.map {
                1 + PrimeNativeByteTokenizer.encode(
                    $0.promptText
                ).count
            }.max() ?? 0
        let authorityTargetLengths =
            authorityEvaluationRows.map {
                (
                    rowID: $0.rowID,
                    count: PrimeNativeByteTokenizer.encode(
                        $0.expectedCompletion
                    ).count
                )
            }
        let authorityMaximumTargetTokenCount =
            authorityTargetLengths.map(\.count).max() ?? 0
        let authorityOverCapTargetRowIDs =
            authorityTargetLengths.filter {
                $0.count + 1
                    > maximumGenerationTokenDecisions
            }.map(\.rowID).sorted()
        let corpusBound =
            !report.corpus.corpusID.isEmpty
                && isSHA256(report.corpus.manifestSHA256)
                && isSHA256(
                    report.corpus.manifestArtifactSHA256
                )
                && !report.corpus.manifestFileName.isEmpty
                && !report.corpus.manifestFileName.contains("/")
                && report.corpus
                    .maximumEvaluationPromptTokenCount > 0
                && report.corpus
                    .maximumEvaluationPromptTokenCount
                    == authorityMaximumPromptTokenCount
                && report.corpus
                    .maximumEvaluationTargetTokenCount
                    == authorityMaximumTargetTokenCount
                && report.corpus
                    .maximumEvaluationTargetTokenCount + 1
                    <= maximumGenerationTokenDecisions
                && report.corpus.overCapTargetRowIDs
                    == authorityOverCapTargetRowIDs
                && report.corpus.overCapTargetRowIDs.isEmpty
                && report.corpus.generationContextLength
                    == report.profile.maximumSequenceLength
                && report.corpus
                    .maximumEvaluationPromptTokenCount
                    + maximumGenerationTokenDecisions
                    <= report.corpus.generationContextLength
                && report.corpus
                    .insufficientGenerationContextRowIDs.isEmpty
                && report.corpus.firstPartyRightsBound
                && report.corpus.exactObjectHashesPresent
                && report.corpus.disjointSplitsVerified
                && isSHA256(
                    report.corpus.probeTokenManifestSHA256
                )
                && isSHA256(
                    report.corpus
                        .probeTokenManifestArtifactSHA256
                )
                && report.corpus.probeTokenManifestFileName
                    == probeTokenManifestFileName
                && report.corpus.probeTokenCount > 0
                && report.corpus.trainingTokenInstances > 0
                && report.corpus
                    .deduplicatedTrainingTokenInstances > 0
                && report.corpus
                    .deduplicatedTrainingTokenInstances
                    <= report.corpus.trainingTokenInstances
                && report.corpus.trainingRowCount > 0
                && report.corpus.validTrainingRowCount
                    == ErgenticsPrimeNativeTextCorpus.rowCounts[
                        .train
                    ]
                && report.corpus.refusalTrainingRowCount
                    == ErgenticsPrimeNativeTextCorpus.rowCounts[
                        .refusalTrain
                    ]
                && report.corpus
                    .refusalSelectionValidationRowCount
                    == ErgenticsPrimeNativeTextCorpus.rowCounts[
                        .refusalValidation
                    ]
                && report.corpus.finalAbstentionRowCount
                    == ErgenticsPrimeNativeTextCorpus.rowCounts[
                        .abstention
                    ]
                && report.corpus.trainingRowCount
                    == report.corpus.validTrainingRowCount
                        + report.corpus.refusalTrainingRowCount
                && report.corpus.refusalCurriculumBound
                && report.corpus.semanticCombinationCount > 0
                && report.corpus.expectedEvaluationRowSHA256
                    .allSatisfy {
                        !$0.key.isEmpty && isSHA256($0.value)
                    }
                && report.corpus.expectedEvaluationContractSHA256
                    .allSatisfy {
                        !$0.key.isEmpty && isSHA256($0.value)
                    }
        let implementationBound =
            report.implementation.executionLanguage == "swift"
                && report.implementation.buildConfiguration
                    == requiredBuildConfiguration
                && report.implementation.precision
                    == requiredPrecision
                && report.implementation.framework == "mlx-swift"
                && report.implementation.modelImplementation
                    == "MLXLLM.LlamaModel"
                && report.implementation.optimizerImplementation
                    == "MLXOptimizers.AdamW"
                && report.implementation.deviceType == "gpu"
                && !report.implementation.deviceDescription.isEmpty
                && report.implementation.mlxSwiftVersion == "0.29.1"
                && report.implementation.mlxSwiftExamplesVersion
                    == "2.29.1"
                && report.implementation.mlxSwiftLicenseID == "MIT"
                && report.implementation
                    .mlxSwiftExamplesLicenseID == "MIT"
                && isSHA256(
                    report.implementation.packageResolvedSHA256
                )
                && isSHA256(
                    report.implementation.executorArtifactSHA256
                )
                && report.implementation
                    .executorArtifactFileName
                    == executorArtifactFileName
                && isSHA256(
                    report.implementation
                        .recommenderArtifactSHA256
                )
                && report.implementation
                    .recommenderArtifactFileName
                    == recommenderArtifactFileName
                && isSHA256(
                    report.implementation
                        .metalLibraryArtifactSHA256
                )
                && report.implementation
                    .metalLibraryArtifactByteCount > 0
                && report.implementation
                    .metalLibraryPrimaryFileName
                    == metalLibraryPrimaryFileName
                && report.implementation
                    .metalLibraryFallbackFileName
                    == metalLibraryFallbackFileName
                && report.implementation
                    .metalLibraryBundleSearchAuditID
                    == metalLibraryBundleSearchAuditID
                && report.implementation
                    .metalLibraryBundleSearchBaseCount > 0
                && report.implementation
                    .metalLibraryVerifiedBundleMirrorCount >= 0
                && report.implementation
                    .metalLibraryVerifiedBundleMirrorCount
                    <= report.implementation
                        .metalLibraryBundleSearchBaseCount
                && report.implementation
                    .metalLibraryDivergentBundleCandidateCount == 0
                && isGitRevision(
                    report.implementation
                        .metalLibrarySourceMLXSwiftRevision
                )
                && observedFP32ParameterDTypesBound(
                    modelParameterDTypes:
                        report.implementation
                            .observedModelParameterDTypes,
                    trainableParameterDTypes:
                        report.implementation
                            .observedTrainableParameterDTypes
                )
                && report.implementation
                    .externalPackagesSupplyExecutionPrimitivesOnly
                && !report.implementation
                    .externalPackagesSupplyTextTokenizerOrWeights
                && report.implementation.maintainedPrimitivesOnly
                && !report.implementation.customTransformerCode
                && !report.implementation.customMetalKernels
                && report.implementation.randomInitialization
        let lossesFinite =
            report.training.losses.count
                == report.training.completedSteps
                && report.training.losses.allSatisfy {
                    $0.isFinite && $0 > 0
                }
        let mechanicsBound: Bool = {
            guard let expectedEffectiveBatchSize =
                    exactIntegerProduct([
                        report.training.batchSize,
                        report.training
                            .gradientAccumulationSteps,
                    ]),
                  let expectedProcessedPaddedTokenPositions =
                    exactIntegerProduct([
                        report.training.requestedSteps,
                        report.training.batchSize,
                        report.training
                            .gradientAccumulationSteps,
                        report.training.measuredSequenceLength,
                    ]) else {
                return false
            }
            return report.training.requestedSteps > 0
                && report.training.completedSteps
                    == report.training.requestedSteps
                && report.training.batchSize > 0
                && report.training.gradientAccumulationSteps > 0
                && report.training.effectiveBatchSize
                    == expectedEffectiveBatchSize
                && report.training.measuredSequenceLength >= 8
                && report.training.measuredSequenceLength
                    <= (profile?.maximumSequenceLength ?? 0)
                && report.training.evaluationBatchSize > 0
                && report.training.evaluationShardSize
                    == evaluationShardSize
                && report.training.processedPaddedTokenPositions
                    == expectedProcessedPaddedTokenPositions
                && report.training
                    .plannedTrainingTokenPresentations
                    == report.training
                        .processedPaddedTokenPositions
                && report.corpus.probeTokenCount
                    == report.training
                        .processedPaddedTokenPositions
                && report.training.trainedTokens > 0
                && report.training.trainedTokens
                    <= report.training
                        .processedPaddedTokenPositions
                && report.training.answerTokensContributed > 0
                && report.training.answerTokensContributed
                    <= report.training.trainedTokens
                && report.training.timedNonPaddingTokens > 0
                && report.training.timedNonPaddingTokens
                    <= report.training.trainedTokens
                && finitePositive(report.training.elapsedSeconds)
                && finitePositive(
                    report.training.coldStartElapsedSeconds
                )
                && report.training.coldStartElapsedSeconds
                    <= report.training.elapsedSeconds
                && report.training
                    .measurementWarmupElapsedSeconds.isFinite
                && report.training
                    .measurementWarmupElapsedSeconds >= 0
                && finitePositive(
                    report.training.timedElapsedSeconds
                )
                && finitePositive(report.training.tokensPerSecond)
                && abs(
                    report.training.tokensPerSecond
                        - Double(
                            report.training
                                .timedNonPaddingTokens
                        )
                            / report.training.timedElapsedSeconds
                ) <= max(
                    1e-12,
                    abs(report.training.tokensPerSecond) * 1e-12
                )
                && report.training.peakMemoryBytes > 0
                && finitePositive(report.training.learningRate)
                && report.training.weightDecay.isFinite
                && report.training.weightDecay >= 0
                && report.training.optimizerImplementation
                    == "MLXOptimizers.AdamW"
                && report.training.adamBeta1 == 0.9
                && report.training.adamBeta2 == 0.999
                && report.training.adamEpsilon == 1e-8
                && report.training.decoupledWeightDecay
                && report.training.gradientClipMode
                    == "global_l2_norm_pre_optimizer_step"
                && report.training.lossReduction
                    == "mean_target_token_cross_entropy"
                && report.training.precision
                    == requiredPrecision
                && (
                    report.training.gradientClipNorm == nil
                        || finitePositive(
                            report.training.gradientClipNorm!
                        )
                )
                && report.training.fullWeightTraining
                && report.training.shiftedCausalLanguageModelLoss
                && report.training.promptTokensMasked
                && report.training
                    .targetTokenWeightedEffectiveBatchLoss
                && finitePositive(
                    report.training.firstGradientNorm
                )
                && finitePositive(
                    report.training.firstClippedGradientNorm
                )
                && report.training.firstClippedGradientNorm
                    <= 1.000_001
                && finitePositive(
                    report.training.firstWeightUpdateNorm
                )
                && report.training
                    .causalPrefixMaximumLogitDelta == 0
                && finitePositive(
                    report.training
                        .suffixEffectMaximumLogitDelta
                )
                && report.training.logitsFinite
                && report.training
                    .repeatedInferenceMaximumLogitDelta == 0
                && report.training
                    .cachedUncachedMaximumLogitDelta.isFinite
                && report.training
                    .cachedUncachedMaximumLogitDelta <= 1e-4
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
                && isSHA256(
                    report.training
                        .initializationFingerprintSHA256
                )
                && report.training
                    .sameSeedInitializationReplayExact
                && lossesFinite
                && finitePositive(report.training.initialLoss)
                && report.training.finalLoss.isFinite
                && report.training.finalLoss >= 0
                && (
                    report.mode != .fullCanary
                        || report.training.finalLoss
                            < report.training.initialLoss
                )
                && isSHA256(
                    report.training.comparisonManifestSHA256
                )
                && report.training
                    .trainingScheduleManifestSHA256
                    == report.corpus.probeTokenManifestSHA256
                && heldoutLossEvidenceBound(report)
                && report.training.hyperparameterSearchID
                    == ErgenticsNativeScaleEngineRecommend
                        .adaptiveSearchID
                && report.training.learningRateDiscoverySeed
                    == ErgenticsNativeScaleEngineRecommend
                        .discoverySeed
                && isSHA256(report.training.replicateID)
                && report.training.declaredLearningRateGrid
                    == ErgenticsNativeScaleEngineRecommend
                        .discoveryLearningRates
                && report.training.declaredReplicateSeeds
                    == ErgenticsNativeScaleEngineRecommend
                        .adaptiveSeeds
                && isSHA256(
                    report.training.configurationArtifactSHA256
                )
                && report.training
                    .configurationArtifactFileName
                    == configurationArtifactFileName
                && executorWallEvidenceBound(
                    mode: report.mode,
                    accountingID:
                        report.training.executorWallAccountingID,
                    resumedFromTrainingStage:
                        report.training
                            .resumedFromTrainingStage,
                    priorExecutorWallSeconds:
                        report.training.priorExecutorWallSeconds,
                    checkpointStageExecutorWallSeconds:
                        report.training
                            .checkpointStageExecutorWallSeconds,
                    measuredTotalExecutorWallSeconds:
                        report.training
                            .measuredTotalExecutorWallSeconds,
                    declaredMaximumExecutorWallSeconds:
                        report.training
                            .declaredMaximumExecutorWallSeconds
                )
                && !report.training.resumedFromTrainingStage
                && report.training
                    .preexistingEvaluationArtifactNamesAtInvocationStart
                    .isEmpty
                && (
                    report.mode != .profileProbe
                        || report.training
                            .declaredMaximumExecutorWallSeconds
                            == 1_800
                )
                && (
                    (
                        report.mode == .profileProbe
                            && report.training.persistencePolicy
                                == .profileProbeNoResume
                            && !report.training
                                .interruptedTrajectoryReplayExact
                    )
                    || (
                        report.mode == .fullCanary
                            && report.training.persistencePolicy
                                == .boundedDiagnosticNoOptimizerResume
                            && !report.training
                                .interruptedTrajectoryReplayExact
                    )
                    || (
                        report.mode == .fullCanary
                            && report.training.persistencePolicy
                                == .exactOptimizerStateResume
                            && report.training
                                .interruptedTrajectoryReplayExact
                    )
                )
        }()
        let scheduledRowCountTotal = exactIntegerSum([
            report.training.scheduledValidRowCount,
            report.training.scheduledRefusalRowCount,
        ])
        let fullScheduleCountBound: Bool = {
            guard report.training.requestedSteps > 0,
                  report.training.requestedSteps
                    .isMultiple(of: 36),
                  let scheduledRowCountTotal else {
                return false
            }
            let blockCount =
                report.training.requestedSteps / 36
            guard let expectedValidRows =
                    exactIntegerProduct([blockCount, 240]),
                  let expectedRefusalRows =
                    exactIntegerProduct([blockCount, 48]),
                  let expectedValidFamilyRows =
                    exactIntegerProduct([blockCount, 40]),
                  let expectedRefusalFamilyRows =
                    exactIntegerProduct([blockCount, 8])
            else {
                return false
            }
            return scheduledRowCountTotal
                    == report.training.distinctScheduledRowCount
                && report.training.scheduledValidRowCount
                    == expectedValidRows
                && report.training.scheduledRefusalRowCount
                    == expectedRefusalRows
                && report.training
                    .scheduledValidSemanticFamilyRows.values
                    .allSatisfy {
                        $0 == expectedValidFamilyRows
                    }
                && report.training
                    .scheduledRefusalSemanticFamilyRows.values
                    .allSatisfy {
                        $0 == expectedRefusalFamilyRows
                    }
        }()
        let profileScheduleBound =
            report.mode != .profileProbe
                || (
                    (
                        (
                            report.training.probePurposeID
                                == "balanced_lr_discovery_v1"
                                && report.seed
                                    == ErgenticsNativeScaleEngineRecommend
                                        .discoverySeed
                        )
                            || (
                                report.training.probePurposeID
                                    == "balanced_lr_confirmation_v1"
                                    && ErgenticsNativeScaleEngineRecommend
                                        .confirmationSeeds
                                        .contains(report.seed)
                            )
                    )
                        && report.training.scheduleID
                            == ErgenticsNativeScaleEngineRecommend
                                .profileProbeTrainingScheduleID
                        && report.training.requestedSteps == 36
                        && report.training.completedSteps == 36
                        && report.training
                            .measurementWarmupSteps == 4
                        && report.training.timedSteps == 32
                        && report.training.batchSize == 2
                        && report.training
                            .gradientAccumulationSteps == 4
                        && report.training.effectiveBatchSize == 8
                        && report.training
                            .distinctScheduledRowCount == 288
                        && report.training.heldoutRowCount == 288
                        && isSHA256(
                            report.training
                                .heldoutScheduleSHA256
                        )
                        && report.training
                            .scheduledSemanticFamilyRows.count == 6
                        && report.training
                            .scheduledSemanticFamilyRows.values
                            .allSatisfy { $0 == 48 }
                        && report.training.scheduledValidRowCount
                            == 240
                        && report.training.scheduledRefusalRowCount
                            == 48
                        && report.training
                            .scheduledValidSemanticFamilyRows.count
                            == 6
                        && report.training
                            .scheduledValidSemanticFamilyRows.values
                            .allSatisfy { $0 == 40 }
                        && report.training
                            .scheduledRefusalSemanticFamilyRows.count
                            == 6
                        && report.training
                            .scheduledRefusalSemanticFamilyRows.values
                            .allSatisfy { $0 == 8 }
                        && scheduledRowCountTotal
                            == Optional(
                                report.training
                                    .distinctScheduledRowCount
                            )
                        && report.training.learningRateScheduleID
                            == "linear_warmup4_then_constant_v1"
                        && report.training.warmupSteps == 4
                        && report.training.gradientClipNorm == 1
                )
        let fullScheduleBound =
            report.mode != .fullCanary
                || (
                    report.training.probePurposeID
                        == "bounded_full_diagnostic_v1"
                        && report.training.scheduleID
                            == "manifest_sha256_curriculum_240_valid_48_refusal_epoch_reason_stratified_v3"
                        && report.training.batchSize == 2
                        && report.training
                            .gradientAccumulationSteps == 4
                        && report.training.effectiveBatchSize == 8
                        && report.training.measuredSequenceLength
                            == 512
                        && report.training.requestedSteps
                            .isMultiple(of: 36)
                        && fullScheduleCountBound
                        && report.training
                            .scheduledValidSemanticFamilyRows.count
                            == 6
                        && report.training
                            .scheduledRefusalSemanticFamilyRows.count
                            == 6
                        && report.training
                            .measurementWarmupSteps == 0
                        && report.training.timedSteps
                            == report.training.requestedSteps
                        && report.training.learningRateScheduleID
                            == "linear_warmup_cosine_10pct_floor_v1"
                        && report.training.gradientClipNorm == 1
                )
        let replay = report.sameSeedReplay
        let selectedParameterLayout =
            expectedSelectedParameterSampleLayout(
                report.profile
            )
        let expectedDifferentSeed =
            report.seed.addingReportingOverflow(1)
        let initializationRegrade:
            SelectedParameterReplayRegrade? = {
            guard let selectedParameterLayout else {
                return nil
            }
            return selectedParameterReplayRegrade(
                first:
                    replay.initialSelectedParameterSamples,
                replay:
                    replay.replayInitialSelectedParameterSamples,
                expectedLayout: selectedParameterLayout
            )
        }()
        let initializationReplayBound: Bool = {
            guard let derived = initializationRegrade else {
                return false
            }
            return derived.zeroDeltaMatchesHashEquality
                && replay.initialFingerprintSHA256
                    == derived.firstFingerprintSHA256
                && replay.replayInitialFingerprintSHA256
                    == derived.replayFingerprintSHA256
                && replay.initializationReplayExact
                    == derived.exact
                && derived.exact
                && report.training
                    .initializationFingerprintSHA256
                    == derived.firstFingerprintSHA256
        }()
        let differentSeedRegrade:
            SelectedParameterReplayRegrade? = {
            guard let selectedParameterLayout else {
                return nil
            }
            return selectedParameterReplayRegrade(
                first:
                    replay.initialSelectedParameterSamples,
                replay:
                    replay
                        .differentSeedInitialSelectedParameterSamples,
                expectedLayout: selectedParameterLayout
            )
        }()
        let differentSeedBound: Bool = {
            guard !expectedDifferentSeed.overflow,
                  let derived = differentSeedRegrade else {
                return false
            }
            let diverged =
                derived.firstFingerprintSHA256
                    != derived.replayFingerprintSHA256
                    && derived.maximumDelta > 0
            return derived.zeroDeltaMatchesHashEquality
                && replay.differentSeed
                    == expectedDifferentSeed.partialValue
                && replay
                    .differentSeedInitialFingerprintSHA256
                    == derived.replayFingerprintSHA256
                && replay.differentSeedInitializationDiverged
                    == diverged
                && diverged
        }()
        let stepLossesEqual =
            replay.firstStepLoss == replay.replayStepLoss
        let stepLossBound =
            replay.firstStepLoss.isFinite
                && replay.firstStepLoss > 0
                && replay.replayStepLoss.isFinite
                && replay.replayStepLoss > 0
                && replay.stepLossExact == stepLossesEqual
                && stepLossesEqual
        let selectedParameterRegrade:
            SelectedParameterReplayRegrade? = {
            guard let selectedParameterLayout else {
                return nil
            }
            return selectedParameterReplayRegrade(
                first:
                    replay.postStepSelectedParameterSamples,
                replay:
                    replay
                        .replayPostStepSelectedParameterSamples,
                expectedLayout: selectedParameterLayout
            )
        }()
        let selectedParameterReplayBound: Bool = {
            guard let derived = selectedParameterRegrade else {
                return false
            }
            return derived.zeroDeltaMatchesHashEquality
                && replay.postStepFingerprintSHA256
                    == derived.firstFingerprintSHA256
                && replay.replayPostStepFingerprintSHA256
                    == derived.replayFingerprintSHA256
                && replay
                    .postStepSelectedParameterMaximumDelta
                    == derived.maximumDelta
                && replay.postStepSelectedParametersExact
                    == derived.exact
        }()
        let fixedPromptRegrade = fixedPromptReplayRegrade(
            firstBitPatterns:
                replay.fixedPromptLogitFloatBitPatterns,
            replayBitPatterns:
                replay.replayFixedPromptLogitFloatBitPatterns
        )
        let fixedPromptReplayBound: Bool = {
            guard let derived = fixedPromptRegrade else {
                return false
            }
            return derived.zeroDeltaMatchesHashEquality
                && replay.fixedPromptMaximumLogitDelta
                    == derived.maximumLogitDelta
                && replay.fixedPromptGreedyTokenID
                    == derived.firstGreedyTokenID
                && replay.replayFixedPromptGreedyTokenID
                    == derived.replayGreedyTokenID
                && replay.fixedPromptGreedyRunnerUpMargin
                    == derived.firstGreedyRunnerUpMargin
                && replay
                    .replayFixedPromptGreedyRunnerUpMargin
                    == derived.replayGreedyRunnerUpMargin
                && replay.fixedPromptGreedyTokenExact
                    == derived.greedyTokenExact
                && replay.fixedPromptBehavioralReplayExact
                    == derived.behavioralReplayExact
                && replay.fixedPromptResultSHA256
                    == derived.firstResultSHA256
                && replay.replayFixedPromptResultSHA256
                    == derived.replayResultSHA256
                && replay.fixedPromptResultExact
                    == derived.resultExact
        }()
        let expectedReplaySchedule =
            mechanicsBound
                && profileScheduleBound
                && fullScheduleBound
            ? expectedSameSeedReplaySchedulePrefix(report)
            : nil
        let scheduleReplayBound =
            expectedReplaySchedule.map {
                replay.scheduledRowIDs == $0
            } ?? false
        let replayBitwiseExact =
            initializationReplayBound
                && stepLossBound
                && selectedParameterReplayBound
                && (
                    selectedParameterRegrade?.exact
                        ?? false
                )
                && fixedPromptReplayBound
                && (fixedPromptRegrade?.resultExact ?? false)
        let replayBehavioralBound =
            replay.optimizerSteps == 1
                && scheduleReplayBound
                && initializationReplayBound
                && differentSeedBound
                && stepLossBound
                && selectedParameterReplayBound
                && fixedPromptReplayBound
                && (
                    fixedPromptRegrade?
                        .behavioralReplayExact
                        ?? false
                )
        let metrics = splitMetrics(report.rawPredictions)
        let fullMode = report.mode == .fullCanary
        let rawBound =
            !fullMode
                ? report.rawPredictions.isEmpty
                    && report.evaluationShards.isEmpty
                : predictionRowsValid(report)
        let shardPhases = [
            "zero_shot",
            "trained",
            "reloaded",
        ]
        let shardsBound: Bool = {
            guard fullMode else {
                return report.evaluationShards.isEmpty
            }
            let shards = report.evaluationShards
            guard !shards.isEmpty,
                  Set(shards.map(\.fileName)).count == shards.count,
                  evaluationShardFileNamesBound(shards),
                  shards.allSatisfy({
                      shardPhases.contains($0.phase)
                          && $0.fileName
                            == URL(
                                fileURLWithPath: $0.fileName
                            ).lastPathComponent
                          && !$0.fileName.contains("/")
                          && !$0.fileName.contains("\\")
                          && isSHA256($0.artifactSHA256)
                          && $0.rowCount > 0
                          && !$0.firstRowID.isEmpty
                          && !$0.lastRowID.isEmpty
                  }) else {
                return false
            }
            return shardPhases.allSatisfy { phase in
                guard let phaseRowCount = exactIntegerSum(
                    shards.filter {
                        $0.phase == phase
                    }.map(\.rowCount)
                ) else {
                    return false
                }
                return phaseRowCount
                    == report.rawPredictions.count
            }
        }()
        let durabilityBound: Bool = {
            guard fullMode else { return report.durability == nil }
            guard let durability = report.durability else {
                return false
            }
            return isSHA256(durability.checkpointSHA256)
                && durability.buildConfiguration
                    == requiredBuildConfiguration
                && durability.buildConfiguration
                    == report.implementation.buildConfiguration
                && durability.precision == requiredPrecision
                && durability.precision
                    == report.implementation.precision
                && fullArtifactBasenamesBound(durability)
                && isSHA256(durability.trainingStageSHA256)
                && durability.checkpointTensorCount > 0
                && durability.checkpointReloadWeightsExact
                && durability
                    .checkpointReloadMaximumWeightDelta == 0
                && durability
                    .checkpointReloadMaximumLogitDelta == 0
                && durability
                    .repeatedInferenceMaximumLogitDelta == 0
                && durability.reloadedPredictionsExact
                && isSHA256(durability.configurationSHA256)
                && isSHA256(durability.executableSHA256)
                && isSHA256(durability.recommenderSHA256)
                && durability.recommenderFileName
                    == recommenderArtifactFileName
                && durability.configurationSHA256
                    == report.training
                        .configurationArtifactSHA256
                && durability.executableSHA256
                    == report.implementation
                        .executorArtifactSHA256
                && durability.recommenderSHA256
                    == report.implementation
                        .recommenderArtifactSHA256
                && durability.recommenderFileName
                    == report.implementation
                        .recommenderArtifactFileName
                && durability.metalLibraryArtifactSHA256
                    == report.implementation
                        .metalLibraryArtifactSHA256
                && durability.metalLibraryArtifactByteCount
                    == report.implementation
                        .metalLibraryArtifactByteCount
                && durability.metalLibraryPrimaryFileName
                    == report.implementation
                        .metalLibraryPrimaryFileName
                && durability.metalLibraryFallbackFileName
                    == report.implementation
                        .metalLibraryFallbackFileName
                && durability.metalLibraryBundleSearchAuditID
                    == report.implementation
                        .metalLibraryBundleSearchAuditID
                && durability.metalLibraryBundleSearchBaseCount
                    == report.implementation
                        .metalLibraryBundleSearchBaseCount
                && durability
                    .metalLibraryVerifiedBundleMirrorCount
                    == report.implementation
                        .metalLibraryVerifiedBundleMirrorCount
                && durability
                    .metalLibraryDivergentBundleCandidateCount
                    == report.implementation
                        .metalLibraryDivergentBundleCandidateCount
                && durability.metalLibrarySourceMLXSwiftRevision
                    == report.implementation
                        .metalLibrarySourceMLXSwiftRevision
                && durability.observedModelParameterDTypes
                    == report.implementation
                        .observedModelParameterDTypes
                && durability.observedTrainableParameterDTypes
                    == report.implementation
                        .observedTrainableParameterDTypes
        }()
        let functionalCapability =
            !fullMode || capabilityGrounded(metrics)
        let exactTrainingContinuation =
            !fullMode
                || (
                    report.training.persistencePolicy
                        == .exactOptimizerStateResume
                        && report.training
                            .interruptedTrajectoryReplayExact
                )
        let capability =
            functionalCapability && exactTrainingContinuation
        let seedBound = frozenSeeds.contains(report.seed)

        let legs = [
            Leg(
                id: "N1_schema_and_random_init_text_lineage",
                pass: schemaBound && independentLineage,
                detail:
                    "family=\(report.familyID) lineage=\(report.lineageID) parent=\(report.parentCheckpointSHA256 ?? "none")"
            ),
            Leg(
                id: "N2_exact_maintained_engine_profile",
                pass: profile != nil,
                detail:
                    "profile=\(report.profile.profileID) expected=\(report.profile.expectedParameterCount) observed=\(report.profile.observedParameterCount)"
            ),
            Leg(
                id: "N3_native_512_tokenizer_replay",
                pass: tokenizerBound,
                detail:
                    "tokenizer=\(report.tokenizer.tokenizerID) vocab=\(report.tokenizer.vocabularySize)"
            ),
            Leg(
                id: "N4_first_party_corpus_and_probe_binding",
                pass: corpusBound,
                detail:
                    "corpus=\(report.corpus.corpusID) probe_tokens=\(report.corpus.probeTokenCount)"
            ),
            Leg(
                id: "N5_swift_mlx_metal_maintained_primitives",
                pass: implementationBound,
                detail:
                    "\(report.implementation.executionLanguage) \(report.implementation.modelImplementation) \(report.implementation.deviceType)"
            ),
            Leg(
                id: "N6_shifted_masked_finite_learning_step",
                pass:
                    mechanicsBound
                        && profileScheduleBound
                        && fullScheduleBound,
                detail:
                    "purpose=\(report.training.probePurposeID) schedule=\(report.training.scheduleID) steps=\(report.training.completedSteps) effective_batch=\(report.training.effectiveBatchSize) gradient=\(report.training.firstGradientNorm) update=\(report.training.firstWeightUpdateNorm)"
            ),
            Leg(
                id: "N7_frozen_seed",
                pass: seedBound,
                detail:
                    "seed=\(report.seed) allowed=\(frozenSeeds)"
            ),
            Leg(
                id:
                    "N7b_same_seed_behavioral_replay_and_seed_falsifier",
                pass: replayBehavioralBound,
                detail:
                    "behavioral=\(replayBehavioralBound) bitwise=\(replayBitwiseExact) init_exact=\(replay.initializationReplayExact) step_loss_exact=\(replay.stepLossExact) trajectory_exact=\(replay.postStepSelectedParametersExact) parameter_delta=\(replay.postStepSelectedParameterMaximumDelta) result_exact=\(replay.fixedPromptResultExact) logit_delta=\(replay.fixedPromptMaximumLogitDelta) first_greedy=\(replay.fixedPromptGreedyTokenID) replay_greedy=\(replay.replayFixedPromptGreedyTokenID) first_margin=\(replay.fixedPromptGreedyRunnerUpMargin) replay_margin=\(replay.replayFixedPromptGreedyRunnerUpMargin) greedy_exact=\(replay.fixedPromptGreedyTokenExact) different_seed=\(replay.differentSeedInitializationDiverged)"
            ),
            Leg(
                id: "N8_complete_raw_autoregressive_regrade",
                pass: rawBound && shardsBound,
                detail:
                    "mode=\(report.mode.rawValue) rows=\(report.rawPredictions.count) shards=\(report.evaluationShards.count)"
            ),
            Leg(
                id: "N9_checkpoint_reload_and_replay",
                pass: durabilityBound,
                detail:
                    "required=\(fullMode) present=\(report.durability != nil)"
            ),
            Leg(
                id: "N10_functional_generalization_thresholds",
                pass: capability,
                detail:
                    fullMode
                    ? (
                        metrics.map {
                        "\($0.split.rawValue)=\($0.trainedExactAccuracy)"
                        }.joined(separator: " ")
                        + " persistence="
                        + report.training.persistencePolicy.rawValue
                        + " interrupted_exact="
                        + String(
                            report.training
                                .interruptedTrajectoryReplayExact
                        )
                    )
                    : "not_a_capability_claim"
            ),
        ]
        let grounded = legs.allSatisfy(\.pass)
        let nextAction: String
        if !schemaBound || !independentLineage {
            nextAction = "reject_legacy_or_imported_lineage"
        } else if profile == nil {
            nextAction = "bind_exact_maintained_engine_profile"
        } else if !tokenizerBound {
            nextAction = "repair_native_byte_tokenizer_binding"
        } else if !corpusBound {
            nextAction = "repair_first_party_corpus_binding"
        } else if !implementationBound
            || !mechanicsBound
            || !profileScheduleBound
            || !fullScheduleBound
            || !replayBehavioralBound {
            nextAction = "repair_swift_mlx_training_evidence"
        } else if !seedBound {
            nextAction = "return_to_frozen_seed_set"
        } else if !rawBound || !shardsBound || !durabilityBound {
            nextAction = "complete_raw_evaluation_and_durability"
        } else if !functionalCapability {
            nextAction = "abstain_and_diagnose_learning_representation"
        } else if !exactTrainingContinuation {
            nextAction =
                "implement_exact_optimizer_state_resume_before_capability_claim"
        } else if report.mode == .profileProbe {
            nextAction = "compare_exact_profile_probe_set"
        } else {
            nextAction = "run_exact_three_seed_consensus"
        }
        return Recommendation(
            schemaVersion: schemaVersion,
            outcome: grounded ? "GROUNDED" : "ABSTAIN",
            claimScope:
                report.mode == .profileProbe
                ? "profile_admission_only_no_language_capability"
                : (
                    exactTrainingContinuation
                    ? "controlled_compositional_language_canary_only"
                    : "bounded_full_diagnostic_no_capability_claim"
                ),
            nextAction: nextAction,
            reportSHA256: reportSHA256(report),
            profileID: report.profile.profileID,
            seed: report.seed,
            mode: report.mode,
            splitMetrics: metrics,
            legs: legs
        )
    }

    /// Whether a status-zero executor completion contradicts the independent
    /// authority regrade of the report bytes it just published.
    ///
    /// Full-canary ABSTAIN is a valid diagnostic outcome. A profile probe,
    /// however, may only return status zero when its written report regrades
    /// GROUNDED for profile admission.
    public static func profileProbeCompletionContradictsRegrade(
        report: Report,
        recommendation: Recommendation
    ) -> Bool {
        report.mode == .profileProbe
            && (
                recommendation.reportSHA256 != reportSHA256(report)
                    || recommendation.outcome != "GROUNDED"
            )
    }

    public static func consensus(
        reports: [Report]
    ) -> ConsensusRecommendation {
        let seeds = reports.map(\.seed).sorted()
        let profileIDs = Set(reports.map(\.profile.profileID))
        let modes = Set(reports.map(\.mode))
        let recommendations = reports.map(recommend)
        let initializationFingerprints = Set(
            reports.map {
                $0.training.initializationFingerprintSHA256
            }
        )
        let commonLineage =
            Set(reports.map(\.tokenizer.manifestSHA256)).count == 1
                && Set(reports.map(\.corpus.manifestSHA256)).count
                    == 1
                && Set(
                    reports.map {
                        $0.implementation.packageResolvedSHA256
                    }
                ).count == 1
                && Set(
                    reports.map {
                        $0.implementation.executorArtifactSHA256
                    }
                ).count == 1
                && Set(reports.map(\.generationContractID)).count
                    == 1
        let exactSet =
            seeds == frozenSeeds.sorted()
                && Set(seeds).count == frozenSeeds.count
                && profileIDs.count == 1
                && modes == [.fullCanary]
                && initializationFingerprints.count
                    == frozenSeeds.count
                && commonLineage
        let grounded =
            exactSet
                && recommendations.allSatisfy {
                    $0.outcome == "GROUNDED"
                }
        return ConsensusRecommendation(
            schemaVersion: schemaVersion,
            outcome: grounded ? "GROUNDED" : "ABSTAIN",
            claimScope:
                "three_seed_controlled_compositional_language_canary_only",
            profileID: profileIDs.count == 1
                ? profileIDs.first : nil,
            seeds: seeds,
            reportSHA256s:
                recommendations.map(\.reportSHA256).sorted(),
            allSeedReportsGrounded:
                recommendations.allSatisfy {
                    $0.outcome == "GROUNDED"
                },
            nextAction: grounded
                ? "admit_isolated_prime_domain_transfer_canary"
                : "abstain_without_prime_transfer"
        )
    }
}
