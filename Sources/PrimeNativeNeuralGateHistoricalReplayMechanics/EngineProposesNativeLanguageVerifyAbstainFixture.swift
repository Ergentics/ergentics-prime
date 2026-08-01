import CryptoKit
import ErgenticsPrimeRuntime
import PrimeNativeNeuralGateReplayMechanics
import Foundation

public enum EngineProposesNativeLanguageVerifyAbstainFixture {
    public enum MaterializationError: Error, Equatable {
        case invalidPackageResolvedArtifact
    }

    private typealias Gate =
        PrimeNeuralNativeLanguageVerifyAbstainGate
    private typealias Authority =
        ErgenticsNativeLanguageCanary
    private typealias Corpus =
        ErgenticsPrimeNativeTextCorpus

    private struct ProbeTokenManifest: Codable {
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

    private struct ProbeBundle {
        let fileName: String
        let canonicalSHA256: String
        let artifactSHA256: String
        let artifactData: Data
        let tokenCount: Int
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
        let heldoutScheduleSHA256: String
        let scheduledSemanticFamilyRows: [String: Int]
        let nonPaddingTokens: Int
        let answerTokens: Int
    }

    private struct HeldoutLossBundle {
        let rows: [Authority.HeldoutLossRow]
        let targetTokenCount: Int
        let nonPaddingTokenCount: Int
        let crossEntropyBefore: Double
        let crossEntropyAfter: Double
        let standardError: Double
        let familyBefore: [String: Double]
        let familyAfter: [String: Double]
        let validTargetTokenCount: Int
        let refusalTargetTokenCount: Int
        let validCrossEntropyBefore: Double
        let validCrossEntropyAfter: Double
        let refusalCrossEntropyBefore: Double
        let refusalCrossEntropyAfter: Double
    }

    private struct ScaleComparisonManifest: Codable {
        let schemaVersion: String
        let familyID: String
        let hyperparameterSearchID: String
        let profileIDs: [String]
        let tokenizerManifestSHA256: String
        let corpusManifestSHA256: String
        let packageResolvedSHA256: String
        let executorArtifactSHA256: String
        let discoveryLearningRates: [Double]
        let discoverySeed: Int
        let confirmationSeeds: [Int]
        let discoveryPurposeID: String
        let confirmationPurposeID: String
        let scheduleID: String
        let steps: Int
        let batchSize: Int
        let gradientAccumulationSteps: Int
        let effectiveBatchSize: Int
        let sequenceLength: Int
        let evaluationBatchSize: Int
        let heldoutRowCount: Int
        let storedValidTrainingRowCount: Int
        let storedRefusalTrainingRowCount: Int
        let scheduledValidRowCount: Int
        let scheduledRefusalRowCount: Int
        let heldoutValidRowCount: Int
        let heldoutRefusalRowCount: Int
        let validRowsPerSemanticFamily: Int
        let refusalRowsPerSemanticFamily: Int
        let selectionValidationSplitIDs: [String]
        let optimizerImplementation: String
        let optimizerScheduleID: String
        let warmupSteps: Int
        let weightDecay: Double
        let gradientClipNorm: Double
        let lossReduction: String

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case familyID = "family_id"
            case hyperparameterSearchID =
                "hyperparameter_search_id"
            case profileIDs = "profile_ids"
            case tokenizerManifestSHA256 =
                "tokenizer_manifest_sha256"
            case corpusManifestSHA256 =
                "corpus_manifest_sha256"
            case packageResolvedSHA256 =
                "package_resolved_sha256"
            case executorArtifactSHA256 =
                "executor_artifact_sha256"
            case discoveryLearningRates =
                "discovery_learning_rates"
            case discoverySeed = "discovery_seed"
            case confirmationSeeds = "confirmation_seeds"
            case discoveryPurposeID = "discovery_purpose_id"
            case confirmationPurposeID =
                "confirmation_purpose_id"
            case scheduleID = "schedule_id"
            case steps
            case batchSize = "batch_size"
            case gradientAccumulationSteps =
                "gradient_accumulation_steps"
            case effectiveBatchSize = "effective_batch_size"
            case sequenceLength = "sequence_length"
            case evaluationBatchSize = "evaluation_batch_size"
            case heldoutRowCount = "heldout_row_count"
            case storedValidTrainingRowCount =
                "stored_valid_training_row_count"
            case storedRefusalTrainingRowCount =
                "stored_refusal_training_row_count"
            case scheduledValidRowCount =
                "scheduled_valid_row_count"
            case scheduledRefusalRowCount =
                "scheduled_refusal_row_count"
            case heldoutValidRowCount =
                "heldout_valid_row_count"
            case heldoutRefusalRowCount =
                "heldout_refusal_row_count"
            case validRowsPerSemanticFamily =
                "valid_rows_per_semantic_family"
            case refusalRowsPerSemanticFamily =
                "refusal_rows_per_semantic_family"
            case selectionValidationSplitIDs =
                "selection_validation_split_ids"
            case optimizerImplementation =
                "optimizer_implementation"
            case optimizerScheduleID =
                "optimizer_schedule_id"
            case warmupSteps = "warmup_steps"
            case weightDecay = "weight_decay"
            case gradientClipNorm = "gradient_clip_norm"
            case lossReduction = "loss_reduction"
        }
    }

    private struct Generated: Codable {
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

    private struct GenerationShardEntry: Codable {
        let rowID: String
        let generated: Generated

        enum CodingKeys: String, CodingKey {
            case rowID = "row_id"
            case generated
        }
    }

    private struct GenerationShard: Codable {
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

    private struct ShardBundle {
        let bindings: [Authority.EvaluationShardBinding]
        let dataByFileName: [String: Data]
    }

    private struct SelectedParameterFingerprintPayload:
        Encodable
    {
        let name: String
        let shape: [Int]
        let dtype: String
        let indices: [Int]
        let floatBitPatterns: [UInt32]
    }

    private struct FixedPromptReplayFingerprintPayload:
        Encodable
    {
        let logitFloatBitPatterns: [UInt32]
        let greedyTokenID: Int
    }

    public struct Fixture {
        public let materials:
            PrimeNeuralNativeLanguageVerifyAbstainGate.Materials
        public let reports:
            [ErgenticsNativeLanguageCanary.Report]
        public let constructionDurationsSeconds: [String: Double]
    }

    private static func selectedParameterSampleLayout(
        _ profile:
            ErgenticsNativeScaleEngineRecommend.ModelProfile
    ) -> [(name: String, shape: [Int])] {
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

    private static func selectedParameterSamples(
        profile:
            ErgenticsNativeScaleEngineRecommend.ModelProfile,
        seed: Int,
        stage: Int
    ) -> [Authority.SelectedParameterSample] {
        selectedParameterSampleLayout(profile).enumerated().map {
            ordinal, entry in
            let elementCount = entry.shape.reduce(1, *)
            let indices = Array(
                Set([
                    0,
                    max(0, elementCount / 2),
                    max(0, elementCount - 1),
                ])
            ).sorted()
            let patterns = indices.enumerated().map {
                sampleIndex, _ -> UInt32 in
                let mantissa =
                    UInt32(
                        (
                            seed * 1_009
                                + stage * 131_071
                                + ordinal * 17
                                + sampleIndex
                        ) & 0x007f_ffff
                    )
                return 0x3f00_0000 | mantissa
            }
            return Authority.SelectedParameterSample(
                name: entry.name,
                shape: entry.shape,
                dtype: Authority.requiredPrecision,
                indices: indices,
                floatBitPatterns: patterns
            )
        }
    }

    private static func selectedParameterFingerprint(
        _ samples: [Authority.SelectedParameterSample]
    ) -> String {
        let payload = samples.map {
            SelectedParameterFingerprintPayload(
                name: $0.name,
                shape: $0.shape,
                dtype: $0.dtype,
                indices: $0.indices,
                floatBitPatterns: $0.floatBitPatterns
            )
        }
        return sha256(try! canonicalEncoder().encode(payload))
    }

    private static func fixedPromptResultFingerprint(
        _ bitPatterns: [UInt32],
        greedyTokenID: Int
    ) -> String {
        sha256(
            try! canonicalEncoder().encode(
                FixedPromptReplayFingerprintPayload(
                    logitFloatBitPatterns: bitPatterns,
                    greedyTokenID: greedyTokenID
                )
            )
        )
    }

    private static func sameSeedReplayEvidence(
        profile:
            ErgenticsNativeScaleEngineRecommend.ModelProfile,
        seed: Int,
        scheduledRowIDs: [String]
    ) -> Authority.SameSeedReplayEvidence {
        let initial = selectedParameterSamples(
            profile: profile,
            seed: seed,
            stage: 0
        )
        let differentSeed = seed + 1
        let differentInitial = selectedParameterSamples(
            profile: profile,
            seed: differentSeed,
            stage: 0
        )
        let postStep = selectedParameterSamples(
            profile: profile,
            seed: seed,
            stage: 1
        )
        var firstLogits = Array(
            repeating: Float(-4).bitPattern,
            count:
                PrimeNativeByteTokenizer
                    .boundModelVocabularySize
        )
        firstLogits[0] = Float.zero.bitPattern
        firstLogits[17] = Float(4).bitPattern
        firstLogits[18] = Float(2).bitPattern
        var replayLogits = firstLogits
        replayLogits[0] =
            Float.leastNonzeroMagnitude.bitPattern
        let firstValues = firstLogits.map {
            Float(bitPattern: $0)
        }
        let replayValues = replayLogits.map {
            Float(bitPattern: $0)
        }
        let maximumLogitDelta = zip(
            firstValues,
            replayValues
        ).map {
            abs(Double($0.0) - Double($0.1))
        }.max()!
        let firstMargin =
            Double(firstValues[17]) - Double(firstValues[18])
        let replayMargin =
            Double(replayValues[17])
                - Double(replayValues[18])
        let initialFingerprint =
            selectedParameterFingerprint(initial)
        let postStepFingerprint =
            selectedParameterFingerprint(postStep)
        return Authority.SameSeedReplayEvidence(
            optimizerSteps: 1,
            scheduledRowIDs: scheduledRowIDs,
            initialFingerprintSHA256:
                initialFingerprint,
            replayInitialFingerprintSHA256:
                initialFingerprint,
            initialSelectedParameterSamples: initial,
            replayInitialSelectedParameterSamples: initial,
            initializationReplayExact: true,
            differentSeed: differentSeed,
            differentSeedInitialFingerprintSHA256:
                selectedParameterFingerprint(differentInitial),
            differentSeedInitialSelectedParameterSamples:
                differentInitial,
            differentSeedInitializationDiverged: true,
            firstStepLoss: 6,
            replayStepLoss: 6,
            stepLossExact: true,
            postStepFingerprintSHA256:
                postStepFingerprint,
            replayPostStepFingerprintSHA256:
                postStepFingerprint,
            postStepSelectedParameterSamples: postStep,
            replayPostStepSelectedParameterSamples: postStep,
            postStepSelectedParametersExact: true,
            postStepSelectedParameterMaximumDelta: 0,
            fixedPromptLogitFloatBitPatterns: firstLogits,
            replayFixedPromptLogitFloatBitPatterns:
                replayLogits,
            fixedPromptMaximumLogitDelta:
                maximumLogitDelta,
            fixedPromptGreedyTokenID: 17,
            replayFixedPromptGreedyTokenID: 17,
            fixedPromptGreedyRunnerUpMargin: firstMargin,
            replayFixedPromptGreedyRunnerUpMargin:
                replayMargin,
            fixedPromptGreedyTokenExact: true,
            fixedPromptBehavioralReplayExact: true,
            fixedPromptResultSHA256:
                fixedPromptResultFingerprint(
                    firstLogits,
                    greedyTokenID: 17
                ),
            replayFixedPromptResultSHA256:
                fixedPromptResultFingerprint(
                    replayLogits,
                    greedyTokenID: 17
                ),
            fixedPromptResultExact: false
        )
    }

    public static func materialize(
        packageResolvedURL: URL
    ) throws -> Fixture {
        let fixtureStarted =
            ProcessInfo.processInfo.systemUptime
        var phaseDurationsSeconds = [String: Double]()
        func recordPhase(
            _ name: String,
            started: Double
        ) {
            phaseDurationsSeconds[name, default: 0] +=
                ProcessInfo.processInfo.systemUptime - started
        }
        let foundationStarted =
            ProcessInfo.processInfo.systemUptime
        let tokenizer = PrimeNativeByteTokenizer.manifest()
        let corpus = Corpus.manifest()
        let corpusManifestData =
            try! prettyEncoder().encode(corpus)
        let trainingRows = Corpus.rows(for: .train)
            .sorted { $0.rowID < $1.rowID }
        let refusalTrainingRows =
            Corpus.rows(for: .refusalTrain)
            .sorted { $0.rowID < $1.rowID }
        let selectionRows =
            (
                Corpus.rows(for: .validation)
                    + Corpus.rows(for: .refusalValidation)
            ).sorted { $0.rowID < $1.rowID }
        let evaluationRows: [Corpus.Row] = [
            Corpus.Split.validation,
            .combinationHoldout,
            .ood,
            .mutation,
            .abstention,
        ].flatMap { Corpus.rows(for: $0) }
            .sorted { $0.rowID < $1.rowID }
        recordPhase(
            "fixture_foundation_materialization",
            started: foundationStarted
        )
        let rawRowsStarted =
            ProcessInfo.processInfo.systemUptime
        let rawRows = evaluationRows.map(rawPrediction)
        recordPhase(
            "fixture_raw_evaluation_rows",
            started: rawRowsStarted
        )
        let staticBindingsStarted =
            ProcessInfo.processInfo.systemUptime
        let profile =
            ErgenticsNativeScaleEngineRecommend.native300M
        let parameters = profile.parameterCount(
            vocabularySize:
                PrimeNativeByteTokenizer.boundModelVocabularySize
        )
        let trainEvidence = corpus.splitEvidence.first {
            $0.split == Corpus.Split.train.rawValue
        }!
        let refusalTrainEvidence = corpus.splitEvidence.first {
            $0.split == Corpus.Split.refusalTrain.rawValue
        }!
        let packageResolvedData =
            try Data(contentsOf: packageResolvedURL)
        let packageResolvedSHA256 =
            sha256(packageResolvedData)
        guard packageResolvedSHA256
            == "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3",
              let packageResolvedBinding =
                Gate.observePackageResolvedArtifact(
                    packageResolvedURL,
                    expectedSHA256: packageResolvedSHA256
                )
        else {
            throw MaterializationError
                .invalidPackageResolvedArtifact
        }
        let metalLibraryData =
            Data("fixture-mlx-metal-library\n".utf8)
        let metalLibrarySHA256 =
            sha256(metalLibraryData)
        let metalLibraryByteCount =
            Int64(metalLibraryData.count)
        let metalLibraryBundleSearchBaseCount = 1
        let metalLibraryVerifiedBundleMirrorCount = 0
        let metalLibraryDivergentBundleCandidateCount = 0
        let executorArtifactFileName =
            "PrimeNativeLanguageSwiftCanary"
        let executorArtifactData = Data(
            "compiled-swift-executor-artifact-v2".utf8
        )
        let executorArtifactSHA256 =
            sha256(executorArtifactData)
        let recommenderArtifactFileName =
            "PrimeNativeLanguageCanaryRecommend"
        let recommenderArtifactData = Data(
            "compiled-swift-recommender-artifact-v1".utf8
        )
        let recommenderArtifactSHA256 =
            sha256(recommenderArtifactData)
        var configurationArtifactDataBySeed =
            [Int: Data]()
        let comparisonManifest = ScaleComparisonManifest(
            schemaVersion: "1",
            familyID:
                ErgenticsNativeScaleEngineRecommend.familyID,
            hyperparameterSearchID:
                ErgenticsNativeScaleEngineRecommend
                    .adaptiveSearchID,
            profileIDs:
                ErgenticsNativeScaleEngineRecommend.profiles
                    .map(\.profileID).sorted(),
            tokenizerManifestSHA256:
                tokenizer.manifestSHA256,
            corpusManifestSHA256: corpus.manifestSHA256,
            packageResolvedSHA256: packageResolvedSHA256,
            executorArtifactSHA256:
                executorArtifactSHA256,
            discoveryLearningRates:
                ErgenticsNativeScaleEngineRecommend
                    .discoveryLearningRates,
            discoverySeed:
                ErgenticsNativeScaleEngineRecommend.discoverySeed,
            confirmationSeeds:
                ErgenticsNativeScaleEngineRecommend
                    .confirmationSeeds,
            discoveryPurposeID:
                "balanced_lr_discovery_v1",
            confirmationPurposeID:
                "balanced_lr_confirmation_v1",
            scheduleID:
                ErgenticsNativeScaleEngineRecommend
                    .profileProbeTrainingScheduleID,
            steps: 36,
            batchSize: 2,
            gradientAccumulationSteps: 4,
            effectiveBatchSize: 8,
            sequenceLength: 512,
            evaluationBatchSize: 32,
            heldoutRowCount: 288,
            storedValidTrainingRowCount:
                trainingRows.count,
            storedRefusalTrainingRowCount:
                refusalTrainingRows.count,
            scheduledValidRowCount: 240,
            scheduledRefusalRowCount: 48,
            heldoutValidRowCount: 240,
            heldoutRefusalRowCount: 48,
            validRowsPerSemanticFamily: 40,
            refusalRowsPerSemanticFamily: 8,
            selectionValidationSplitIDs: [
                Corpus.Split.validation.rawValue,
                Corpus.Split.refusalValidation.rawValue,
            ],
            optimizerImplementation: "MLXOptimizers.AdamW",
            optimizerScheduleID:
                "linear_warmup4_then_constant_v1",
            warmupSteps: 4,
            weightDecay: 0.01,
            gradientClipNorm: 1,
            lossReduction:
                "mean_target_token_cross_entropy"
        )
        let comparisonManifestSHA256 = sha256(
            try! canonicalEncoder().encode(comparisonManifest)
        )
        let expectedRows = Dictionary(
            uniqueKeysWithValues: Authority.Split.allCases.map {
                split in
                (
                    split,
                    evaluationRows.filter {
                        $0.split == split.rawValue
                    }.count
                )
            }
        )
        let expectedRowHashes = Dictionary(
            uniqueKeysWithValues: evaluationRows.map {
                ($0.rowID, $0.rowSHA256)
            }
        )
        let expectedEvaluationHashes = Dictionary(
            uniqueKeysWithValues: evaluationRows.map {
                ($0.rowID, $0.evaluationRowSHA256)
            }
        )
        let expectedFamilies = Dictionary(
            uniqueKeysWithValues: Authority.Split.allCases.map {
                split in
                (
                    split,
                    Dictionary(
                        grouping: evaluationRows.filter {
                            $0.split == split.rawValue
                        },
                        by: \.semanticFamily
                    ).mapValues(\.count)
                )
            }
        )
        recordPhase(
            "fixture_static_bindings",
            started: staticBindingsStarted
        )
        var checkpointBindingsBySeed =
            [Int: Gate.ObservedCheckpointBinding]()
        var metalLibraryBindingsBySeed =
            [Int: Gate.ObservedMetalLibraryBinding]()
        var trainingStageDataBySeed = [Int: Data]()
        let reportsAndArtifacts = Authority.frozenSeeds.map {
            seed -> (Authority.Report, ProbeBundle, ShardBundle) in
            let seedStarted =
                ProcessInfo.processInfo.systemUptime
            let probeStarted =
                ProcessInfo.processInfo.systemUptime
            let probe = probeBundle(
                seed: seed,
                steps: 36,
                batchSize: 2,
                gradientAccumulationSteps: 4,
                sequenceLength: 512,
                validTrainingRows: trainingRows,
                refusalTrainingRows:
                    refusalTrainingRows,
                tokenizerManifestSHA256:
                    tokenizer.manifestSHA256,
                corpusManifestSHA256:
                    corpus.manifestSHA256,
                corpusManifestArtifactSHA256:
                    sha256(corpusManifestData)
            )
            recordPhase(
                "fixture_seed_probe_bundles",
                started: probeStarted
            )
            let checkpointData = Data(
                "fixture-checkpoint-seed-\(seed)".utf8
            )
            let checkpointSHA256 = sha256(checkpointData)
            checkpointBindingsBySeed[seed] =
                Gate.ObservedCheckpointBinding(
                    fileName:
                        Gate.checkpointArtifactFileName,
                    sha256: checkpointSHA256,
                    byteCount: Int64(checkpointData.count)
                )
            metalLibraryBindingsBySeed[seed] =
                Gate.ObservedMetalLibraryBinding(
                    primaryFileName:
                        Authority.metalLibraryPrimaryFileName,
                    fallbackFileName:
                        Authority.metalLibraryFallbackFileName,
                    sha256: metalLibrarySHA256,
                    byteCount: metalLibraryByteCount
                )
            let heldoutStarted =
                ProcessInfo.processInfo.systemUptime
            let heldout = heldoutLossBundle(
                rowIDs: probe.heldoutRowIDs,
                selectionRows: selectionRows
            )
            var lossTrace = (0 ..< 36).map { step in
                heldout.crossEntropyBefore
                    + (
                        heldout.crossEntropyAfter
                            - heldout.crossEntropyBefore
                    ) * Double(step) / 35
            }
            lossTrace[0] = heldout.crossEntropyBefore
            lossTrace[35] = heldout.crossEntropyAfter
            recordPhase(
                "fixture_seed_heldout_loss_bundles",
                started: heldoutStarted
            )
            let configurationStarted =
                ProcessInfo.processInfo.systemUptime
            let configurationArtifactFileName =
                "run-configuration.txt"
            let configurationArtifactData = Data(
                (
                    [
                        "schema_version=\(Authority.schemaVersion)",
                        "generation_contract_id=\(Authority.generationContractID)",
                        "mode=full_canary",
                        "build_configuration=\(Authority.requiredBuildConfiguration)",
                        "precision=\(Authority.requiredPrecision)",
                        "profile_id=\(profile.profileID)",
                        "seed=\(seed)",
                        "steps=36",
                        "batch_size=2",
                        "gradient_accumulation_steps=4",
                        "sequence_length=512",
                        "processed_padded_token_positions=\(probe.tokenCount)",
                        "planned_training_token_presentations=\(probe.tokenCount)",
                        "evaluation_batch_size=32",
                        "evaluation_shard_size=512",
                        "learning_rate=0.0001",
                        "weight_decay=0.01",
                        "max_seconds=1800",
                        "executor_wall_accounting_id=\(Authority.executorWallAccountingID)",
                        "tokenizer_artifact_sha256=\(sha256(try! prettyEncoder().encode(tokenizer)))",
                        "corpus_artifact_sha256=\(sha256(corpusManifestData))",
                        "package_resolved_sha256=\(packageResolvedSHA256)",
                        "executor_sha256=\(executorArtifactSHA256)",
                        "recommender_sha256=\(recommenderArtifactSHA256)",
                        "metal_library_artifact_sha256=\(metalLibrarySHA256)",
                        "metal_library_artifact_byte_count=\(metalLibraryByteCount)",
                        "metal_library_primary_file_name=\(Authority.metalLibraryPrimaryFileName)",
                        "metal_library_fallback_file_name=\(Authority.metalLibraryFallbackFileName)",
                        "metal_library_bundle_search_audit_id=\(Authority.metalLibraryBundleSearchAuditID)",
                        "metal_library_source_mlx_swift_revision=\(packageResolvedBinding.mlxSwiftRevision)",
                    ].joined(separator: "\n") + "\n"
                ).utf8
            )
            configurationArtifactDataBySeed[seed] =
                configurationArtifactData
            let configurationArtifactSHA256 =
                sha256(configurationArtifactData)
            let trainingStage = Gate.TrainingStageAudit(
                schemaVersion: "2",
                buildConfiguration:
                    Authority.requiredBuildConfiguration,
                precision: Authority.requiredPrecision,
                profileID: profile.profileID,
                seed: seed,
                corpusManifestSHA256:
                    corpus.manifestSHA256,
                corpusManifestArtifactSHA256:
                    sha256(corpusManifestData),
                corpusManifestFileName:
                    "prime-native-text-corpus-manifest.v1.json",
                tokenizerManifestSHA256:
                    tokenizer.manifestSHA256,
                probeManifestSHA256:
                    probe.canonicalSHA256,
                probePurposeID:
                    "bounded_full_diagnostic_v1",
                scheduleID:
                    "manifest_sha256_curriculum_240_valid_48_refusal_epoch_reason_stratified_v3",
                heldoutScheduleSHA256:
                    probe.heldoutScheduleSHA256,
                requestedSteps: 36,
                measurementWarmupSteps: 0,
                timedSteps: 36,
                batchSize: 2,
                gradientAccumulationSteps: 4,
                sequenceLength: 512,
                evaluationBatchSize: 32,
                evaluationShardSize:
                    Authority.evaluationShardSize,
                learningRate: 0.0001,
                weightDecay: 0.01,
                expectedParameterCount: parameters,
                observedParameterCount: parameters,
                observedTrainableParameterCount: parameters,
                checkpointSHA256: checkpointSHA256,
                checkpointFileName:
                    Gate.checkpointArtifactFileName,
                configurationSHA256:
                    configurationArtifactSHA256,
                executableSHA256:
                    executorArtifactSHA256,
                packageResolvedSHA256:
                    packageResolvedSHA256,
                metalLibraryArtifactSHA256:
                    metalLibrarySHA256,
                metalLibraryArtifactByteCount:
                    metalLibraryByteCount,
                metalLibraryPrimaryFileName:
                    Authority.metalLibraryPrimaryFileName,
                metalLibraryFallbackFileName:
                    Authority.metalLibraryFallbackFileName,
                metalLibraryBundleSearchAuditID:
                    Authority.metalLibraryBundleSearchAuditID,
                metalLibraryBundleSearchBaseCount:
                    metalLibraryBundleSearchBaseCount,
                metalLibraryVerifiedBundleMirrorCount:
                    metalLibraryVerifiedBundleMirrorCount,
                metalLibraryDivergentBundleCandidateCount:
                    metalLibraryDivergentBundleCandidateCount,
                metalLibrarySourceMLXSwiftRevision:
                    packageResolvedBinding.mlxSwiftRevision,
                observedModelParameterDTypes: ["float32"],
                observedTrainableParameterDTypes: ["float32"],
                plannedTrainingTokenPresentations:
                    probe.tokenCount,
                persistencePolicy:
                    .exactOptimizerStateResume,
                executorWallAccountingID:
                    Authority.executorWallAccountingID,
                declaredMaximumExecutorWallSeconds:
                    1_800,
                cumulativeExecutorWallSecondsAtCheckpoint:
                    1
            )
            let trainingStageData =
                try! prettyEncoder().encode(trainingStage)
            trainingStageDataBySeed[seed] = trainingStageData
            recordPhase(
                "fixture_seed_run_configurations",
                started: configurationStarted
            )
            let shardsStarted =
                ProcessInfo.processInfo.systemUptime
            let shards = shardBundle(
                seed: seed,
                profileID: profile.profileID,
                corpusManifestSHA256:
                    corpus.manifestSHA256,
                probeManifestSHA256:
                    probe.canonicalSHA256,
                checkpointSHA256: checkpointSHA256,
                rows: rawRows
            )
            recordPhase(
                "fixture_seed_evaluation_shards",
                started: shardsStarted
            )
            let reportStarted =
                ProcessInfo.processInfo.systemUptime
            let binding = Authority.CorpusBinding(
                corpusID: corpus.corpusID,
                manifestSHA256: corpus.manifestSHA256,
                manifestArtifactSHA256:
                    sha256(corpusManifestData),
                manifestFileName:
                    "prime-native-text-corpus-manifest.v1.json",
                maximumEvaluationPromptTokenCount:
                    rawRows.map(\.promptTokenIDs.count).max()!,
                maximumEvaluationTargetTokenCount:
                    rawRows.map(\.targetTokenIDs.count).max()!,
                overCapTargetRowIDs: [],
                generationContextLength:
                    profile.maximumSequenceLength,
                insufficientGenerationContextRowIDs: [],
                firstPartyRightsBound: true,
                exactObjectHashesPresent: true,
                disjointSplitsVerified: true,
                probeTokenManifestSHA256:
                    probe.canonicalSHA256,
                probeTokenManifestArtifactSHA256:
                    probe.artifactSHA256,
                probeTokenManifestFileName:
                    probe.fileName,
                probeTokenCount: probe.tokenCount,
                trainingTokenInstances:
                    trainEvidence.rawTokenInstances,
                deduplicatedTrainingTokenInstances:
                    trainEvidence
                        .deduplicatedSequenceTokenInstances,
                trainingRowCount:
                    trainEvidence.rowCount
                        + refusalTrainEvidence.rowCount,
                validTrainingRowCount:
                    trainEvidence.rowCount,
                refusalTrainingRowCount:
                    refusalTrainEvidence.rowCount,
                refusalSelectionValidationRowCount:
                    Corpus.rowCounts[.refusalValidation]!,
                finalAbstentionRowCount:
                    Corpus.rowCounts[.abstention]!,
                refusalCurriculumBound: true,
                semanticCombinationCount:
                    trainEvidence
                        .uniqueSemanticCombinationCount,
                expectedEvaluationRows: expectedRows,
                expectedEvaluationRowSHA256:
                    expectedRowHashes,
                expectedEvaluationContractSHA256:
                    expectedEvaluationHashes,
                expectedSemanticFamilyRows:
                    expectedFamilies
            )
            let replayEvidence = sameSeedReplayEvidence(
                profile: profile,
                seed: seed,
                scheduledRowIDs:
                    Array(probe.scheduledRowIDs.prefix(8))
            )
            let report = Authority.Report(
                mode: .fullCanary,
                seed: seed,
                profile: .init(
                    profileID: profile.profileID,
                    vocabularySize:
                        PrimeNativeByteTokenizer
                            .boundModelVocabularySize,
                    maximumSequenceLength:
                        profile.maximumSequenceLength,
                    expectedParameterCount: parameters,
                    observedParameterCount: parameters,
                    observedTrainableParameterCount:
                        parameters
                ),
                tokenizer: .init(
                    tokenizerID:
                        PrimeNativeByteTokenizer.tokenizerID,
                    manifestSHA256:
                        tokenizer.manifestSHA256,
                    vocabularySize:
                        PrimeNativeByteTokenizer
                            .boundModelVocabularySize,
                    deterministicReplayPassed: true,
                    independentFoundationReplayPassed: true
                ),
                corpus: binding,
                implementation: .init(
                    executionLanguage: "swift",
                    buildConfiguration:
                        Authority.requiredBuildConfiguration,
                    precision: Authority.requiredPrecision,
                    framework: "mlx-swift",
                    modelImplementation:
                        "MLXLLM.LlamaModel",
                    optimizerImplementation:
                        "MLXOptimizers.AdamW",
                    deviceType: "gpu",
                    deviceDescription: "Metal(gpu)",
                    mlxSwiftVersion: "0.29.1",
                    mlxSwiftExamplesVersion: "2.29.1",
                    mlxSwiftLicenseID: "MIT",
                    mlxSwiftExamplesLicenseID: "MIT",
                    packageResolvedSHA256:
                        packageResolvedSHA256,
                    executorArtifactSHA256:
                        executorArtifactSHA256,
                    executorArtifactFileName:
                        executorArtifactFileName,
                    recommenderArtifactSHA256:
                        recommenderArtifactSHA256,
                    recommenderArtifactFileName:
                        recommenderArtifactFileName,
                    metalLibraryArtifactSHA256:
                        metalLibrarySHA256,
                    metalLibraryArtifactByteCount:
                        metalLibraryByteCount,
                    metalLibraryPrimaryFileName:
                        Authority.metalLibraryPrimaryFileName,
                    metalLibraryFallbackFileName:
                        Authority.metalLibraryFallbackFileName,
                    metalLibraryBundleSearchAuditID:
                        Authority.metalLibraryBundleSearchAuditID,
                    metalLibraryBundleSearchBaseCount:
                        metalLibraryBundleSearchBaseCount,
                    metalLibraryVerifiedBundleMirrorCount:
                        metalLibraryVerifiedBundleMirrorCount,
                    metalLibraryDivergentBundleCandidateCount:
                        metalLibraryDivergentBundleCandidateCount,
                    metalLibrarySourceMLXSwiftRevision:
                        packageResolvedBinding.mlxSwiftRevision,
                    observedModelParameterDTypes: ["float32"],
                    observedTrainableParameterDTypes: ["float32"],
                    externalPackagesSupplyExecutionPrimitivesOnly:
                        true,
                    externalPackagesSupplyTextTokenizerOrWeights:
                        false,
                    maintainedPrimitivesOnly: true,
                    customTransformerCode: false,
                    customMetalKernels: false,
                    randomInitialization: true,
                    importedBaseWeights: false,
                    pythonProducedEvidence: false
                ),
                training: .init(
                    requestedSteps: 36,
                    completedSteps: 36,
                    probePurposeID:
                        "bounded_full_diagnostic_v1",
                    scheduleID:
                        "manifest_sha256_curriculum_240_valid_48_refusal_epoch_reason_stratified_v3",
                    distinctScheduledRowCount:
                        probe.scheduledRowIDs.count,
                    scheduledSemanticFamilyRows:
                        probe.scheduledSemanticFamilyRows,
                    scheduledValidRowCount:
                        probe.scheduledValidRowCount,
                    scheduledRefusalRowCount:
                        probe.scheduledRefusalRowCount,
                    scheduledValidSemanticFamilyRows:
                        probe.scheduledValidSemanticFamilyRows,
                    scheduledRefusalSemanticFamilyRows:
                        probe
                            .scheduledRefusalSemanticFamilyRows,
                    scheduledRefusalReasonRows:
                        probe.scheduledRefusalReasonRows,
                    scheduledRefusalReasonScheduleSHA256:
                        probe
                            .scheduledRefusalReasonScheduleSHA256,
                    heldoutRowCount:
                        probe.heldoutRowIDs.count,
                    heldoutValidRowCount:
                        probe.heldoutValidRowCount,
                    heldoutRefusalRowCount:
                        probe.heldoutRefusalRowCount,
                    heldoutValidSemanticFamilyRows:
                        probe.heldoutValidSemanticFamilyRows,
                    heldoutRefusalSemanticFamilyRows:
                        probe.heldoutRefusalSemanticFamilyRows,
                    heldoutRefusalReasonRows:
                        probe.heldoutRefusalReasonRows,
                    heldoutRefusalReasonScheduleSHA256:
                        probe
                            .heldoutRefusalReasonScheduleSHA256,
                    selectionValidationSplitIDs: [
                        Corpus.Split.validation.rawValue,
                        Corpus.Split.refusalValidation.rawValue,
                    ],
                    heldoutScheduleSHA256:
                        probe.heldoutScheduleSHA256,
                    comparisonManifestSHA256:
                        comparisonManifestSHA256,
                    trainingScheduleManifestSHA256:
                        probe.canonicalSHA256,
                    trainingHeldoutRowHashIntersectionCount:
                        0,
                    heldoutTargetTokenCount:
                        heldout.targetTokenCount,
                    heldoutValidTargetTokenCount:
                        heldout.validTargetTokenCount,
                    heldoutRefusalTargetTokenCount:
                        heldout.refusalTargetTokenCount,
                    heldoutEvaluationNonPaddingTokenCount:
                        heldout.nonPaddingTokenCount * 2,
                    heldoutEvaluationElapsedSeconds: 1,
                    heldoutCrossEntropyBefore:
                        heldout.crossEntropyBefore,
                    heldoutCrossEntropyAfter:
                        heldout.crossEntropyAfter,
                    heldoutValidCrossEntropyBefore:
                        heldout.validCrossEntropyBefore,
                    heldoutValidCrossEntropyAfter:
                        heldout.validCrossEntropyAfter,
                    heldoutRefusalCrossEntropyBefore:
                        heldout.refusalCrossEntropyBefore,
                    heldoutRefusalCrossEntropyAfter:
                        heldout.refusalCrossEntropyAfter,
                    heldoutCrossEntropyStandardError:
                        heldout.standardError,
                    heldoutCrossEntropyStandardErrorMethodID:
                        "target_token_weighted_row_unbiased_effective_n_v1",
                    heldoutFamilyCrossEntropyBefore:
                        heldout.familyBefore,
                    heldoutFamilyCrossEntropyAfter:
                        heldout.familyAfter,
                    heldoutLossRows: heldout.rows,
                    measurementWarmupSteps: 0,
                    timedSteps: 36,
                    batchSize: 2,
                    gradientAccumulationSteps: 4,
                    effectiveBatchSize: 8,
                    measuredSequenceLength: 512,
                    processedPaddedTokenPositions:
                        probe.tokenCount,
                    plannedTrainingTokenPresentations:
                        probe.tokenCount,
                    trainedTokens: probe.nonPaddingTokens,
                    elapsedSeconds: 2,
                    coldStartElapsedSeconds: 0.25,
                    measurementWarmupElapsedSeconds: 0,
                    timedElapsedSeconds: 2,
                    timedNonPaddingTokens:
                        probe.nonPaddingTokens,
                    tokensPerSecond:
                        Double(probe.nonPaddingTokens) / 2,
                    peakMemoryBytes: 8_000_000_000,
                    learningRate: 0.0001,
                    learningRateScheduleID:
                        "linear_warmup_cosine_10pct_floor_v1",
                    optimizerImplementation:
                        "MLXOptimizers.AdamW",
                    adamBeta1: 0.9,
                    adamBeta2: 0.999,
                    adamEpsilon: 1e-8,
                    decoupledWeightDecay: true,
                    gradientClipMode:
                        "global_l2_norm_pre_optimizer_step",
                    lossReduction:
                        "mean_target_token_cross_entropy",
                    warmupSteps: 1,
                    minimumLearningRate: 0.00001,
                    weightDecay: 0.01,
                    precision: "float32",
                    gradientClipNorm: 1,
                    fullWeightTraining: true,
                    shiftedCausalLanguageModelLoss: true,
                    promptTokensMasked: true,
                    targetTokenWeightedEffectiveBatchLoss:
                        true,
                    answerTokensContributed:
                        probe.answerTokens,
                    firstGradientNorm: 2,
                    firstClippedGradientNorm: 1,
                    firstWeightUpdateNorm: 0.5,
                    causalPrefixMaximumLogitDelta: 0,
                    suffixEffectMaximumLogitDelta: 0.1,
                    logitsFinite: true,
                    repeatedInferenceMaximumLogitDelta: 0,
                    cachedUncachedMaximumLogitDelta: 0,
                    cachedUncachedGreedyTokenParity: true,
                    cachedUncachedMultiStepMaximumLogitDelta:
                        0,
                    cachedUncachedMultiStepGreedyTokenParity:
                        true,
                    cachedUncachedMultiStepComparedDecisionCount:
                        6,
                    cachedUncachedMultiStepUnevenEOS: true,
                    initializationFingerprintSHA256:
                        replayEvidence.initialFingerprintSHA256,
                    sameSeedInitializationReplayExact: true,
                    initialLoss:
                        heldout.crossEntropyBefore,
                    finalLoss:
                        heldout.crossEntropyAfter,
                    losses: lossTrace,
                    hyperparameterSearchID:
                        ErgenticsNativeScaleEngineRecommend
                            .adaptiveSearchID,
                    learningRateDiscoverySeed:
                        ErgenticsNativeScaleEngineRecommend
                            .discoverySeed,
                    replicateID: sha256(
                        Data(
                            [
                                ErgenticsNativeScaleEngineRecommend
                                    .adaptiveSearchID,
                                profile.profileID,
                                "bounded_full_diagnostic_v1",
                                String(0.0001.bitPattern),
                                String(seed),
                            ].joined(separator: "|").utf8
                        )
                    ),
                    declaredLearningRateGrid:
                        ErgenticsNativeScaleEngineRecommend
                            .discoveryLearningRates,
                    declaredReplicateSeeds:
                        ErgenticsNativeScaleEngineRecommend
                            .adaptiveSeeds,
                    configurationArtifactSHA256:
                        configurationArtifactSHA256,
                    configurationArtifactFileName:
                        configurationArtifactFileName,
                    executorWallAccountingID:
                        Authority.executorWallAccountingID,
                    resumedFromTrainingStage: false,
                    priorExecutorWallSeconds: 0,
                    checkpointStageExecutorWallSeconds: 1,
                    declaredMaximumExecutorWallSeconds:
                        1_800,
                    measuredTotalExecutorWallSeconds: 3,
                    persistencePolicy:
                        .exactOptimizerStateResume,
                    interruptedTrajectoryReplayExact: true
                ),
                sameSeedReplay: replayEvidence,
                durability: .init(
                    checkpointSHA256: checkpointSHA256,
                    buildConfiguration:
                        Authority.requiredBuildConfiguration,
                    precision: Authority.requiredPrecision,
                    checkpointFileName:
                        Gate.checkpointArtifactFileName,
                    trainingStageSHA256:
                        sha256(trainingStageData),
                    trainingStageFileName:
                        Gate.trainingStageArtifactFileName,
                    evaluationDirectoryName:
                        Gate.evaluationShardDirectoryName,
                    checkpointTensorCount: 200,
                    checkpointReloadWeightsExact: true,
                    checkpointReloadMaximumWeightDelta: 0,
                    checkpointReloadMaximumLogitDelta: 0,
                    repeatedInferenceMaximumLogitDelta: 0,
                    reloadedPredictionsExact: true,
                    configurationSHA256:
                        configurationArtifactSHA256,
                    executableSHA256:
                        executorArtifactSHA256,
                    recommenderSHA256:
                        recommenderArtifactSHA256,
                    recommenderFileName:
                        recommenderArtifactFileName,
                    metalLibraryArtifactSHA256:
                        metalLibrarySHA256,
                    metalLibraryArtifactByteCount:
                        metalLibraryByteCount,
                    metalLibraryPrimaryFileName:
                        Authority.metalLibraryPrimaryFileName,
                    metalLibraryFallbackFileName:
                        Authority.metalLibraryFallbackFileName,
                    metalLibraryBundleSearchAuditID:
                        Authority.metalLibraryBundleSearchAuditID,
                    metalLibraryBundleSearchBaseCount:
                        metalLibraryBundleSearchBaseCount,
                    metalLibraryVerifiedBundleMirrorCount:
                        metalLibraryVerifiedBundleMirrorCount,
                    metalLibraryDivergentBundleCandidateCount:
                        metalLibraryDivergentBundleCandidateCount,
                    metalLibrarySourceMLXSwiftRevision:
                        packageResolvedBinding.mlxSwiftRevision,
                    observedModelParameterDTypes: ["float32"],
                    observedTrainableParameterDTypes: ["float32"]
                ),
                evaluationShards: shards.bindings,
                rawPredictions: rawRows
            )
            recordPhase(
                "fixture_seed_reports",
                started: reportStarted
            )
            recordPhase(
                "fixture_seed_total",
                started: seedStarted
            )
            return (report, probe, shards)
        }
        let reports = reportsAndArtifacts.map(\.0)
        let compact = canonicalEncoder()
        let pretty = prettyEncoder()
        let materialsStarted =
            ProcessInfo.processInfo.systemUptime
        let materials = Gate.Materials(
                reportData: reports.map {
                    try! compact.encode($0)
                },
                tokenizerManifestData:
                    try! pretty.encode(tokenizer),
                corpusManifestData:
                    corpusManifestData,
                packageResolvedArtifactBinding:
                    packageResolvedBinding,
                probeTokenManifestDataBySeed:
                    Dictionary(
                        uniqueKeysWithValues:
                            reportsAndArtifacts.map {
                                ($0.0.seed, $0.1.artifactData)
                            }
                    ),
                evaluationShardDataBySeed:
                    Dictionary(
                        uniqueKeysWithValues:
                            reportsAndArtifacts.map {
                                (
                                    $0.0.seed,
                                    $0.2.dataByFileName
                                )
                            }
                    ),
                executorArtifactDataByFileName: [
                    executorArtifactFileName:
                        executorArtifactData
                ],
                recommenderArtifactDataByFileName: [
                    recommenderArtifactFileName:
                        recommenderArtifactData
                ],
                checkpointArtifactBindingBySeed:
                    checkpointBindingsBySeed,
                metalLibraryArtifactBindingBySeed:
                    metalLibraryBindingsBySeed,
                trainingStageArtifactDataBySeed:
                    trainingStageDataBySeed,
                configurationArtifactDataBySeed:
                    configurationArtifactDataBySeed
            )
        recordPhase(
            "fixture_materials_assembly",
            started: materialsStarted
        )
        phaseDurationsSeconds["fixture_total"] =
            ProcessInfo.processInfo.systemUptime - fixtureStarted
        return Fixture(
            materials: materials,
            reports: reports,
            constructionDurationsSeconds:
                phaseDurationsSeconds
        )
    }

    private static func rawPrediction(
        _ row: Corpus.Row
    ) -> Authority.RawPrediction {
        let target =
            PrimeNativeByteTokenizer.encode(row.expectedCompletion)
        let zeroText = String(
            repeating: "x",
            count: target.count
        )
        let zero = PrimeNativeByteTokenizer.encode(zeroText)
        let zeroVerification =
            Corpus.verifyGeneratedCompletion(
                row: row,
                completion: zeroText
            )
        let trainedVerification =
            Corpus.verifyGeneratedCompletion(
                row: row,
                completion: row.expectedCompletion
            )
        return .init(
            rowID: row.rowID,
            corpusRowSHA256: row.rowSHA256,
            evaluationRowSHA256: row.evaluationRowSHA256,
            split: Authority.Split(rawValue: row.split)!,
            semanticFamily: row.semanticFamily,
            invariantIDs: row.invariantIDs,
            mutationID: row.mutationID,
            abstentionReason: row.abstentionReason,
            prompt: row.promptText,
            promptTokenIDs:
                [
                    PrimeNativeByteTokenizer
                        .beginningOfSequenceTokenID
                ] + PrimeNativeByteTokenizer.encode(
                    row.promptText
                ),
            target: row.expectedCompletion,
            targetTokenIDs: target,
            zeroShotPrediction: zeroText,
            zeroShotPredictionTokenIDs: zero,
            zeroShotMeanLogProbability: -10,
            zeroShotTokenLogProbabilities:
                Array(repeating: -10, count: target.count),
            zeroShotTerminatedByEOS: true,
            zeroShotTerminationReason: "eos",
            zeroShotUTF8Valid: true,
            zeroShotEOSLogProbability: -10,
            zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity:
                true,
            zeroShotDisallowedFullVocabularyArgmaxCount: 0,
            zeroShotMaximumDisallowedTokenProbabilityMass:
                0.25,
            zeroShotExactMatch: false,
            zeroShotSemanticVerifierPass:
                zeroVerification.semanticMatch,
            zeroShotAbstentionDecision:
                zeroVerification.abstentionDecision,
            zeroShotLatencySeconds: 0.001,
            trainedPrediction: row.expectedCompletion,
            trainedPredictionTokenIDs: target,
            trainedMeanLogProbability: -0.01,
            trainedTokenLogProbabilities:
                Array(repeating: -0.01, count: target.count),
            trainedTerminatedByEOS: true,
            trainedTerminationReason: "eos",
            trainedUTF8Valid: true,
            trainedEOSLogProbability: -0.01,
            trainedRawFullVocabularyAllowedSupportGreedyTokenParity:
                true,
            trainedDisallowedFullVocabularyArgmaxCount: 0,
            trainedMaximumDisallowedTokenProbabilityMass:
                0.01,
            trainedExactMatch: true,
            trainedSemanticVerifierPass:
                trainedVerification.semanticMatch,
            trainedAbstentionDecision:
                trainedVerification.abstentionDecision,
            trainedLatencySeconds: 0.001,
            promptGroupingKeyID:
                Authority.promptGroupingKeyID,
            promptGroupingKey:
                PrimeNativeByteTokenizer.encode(
                    row.promptText
                ).count,
            generationDecisionBudget:
                Authority.maximumGenerationTokenDecisions,
            allowedCompletionTokenSetSHA256:
                Authority.allowedCompletionTokenSetSHA256,
            eosAvailableAtEveryDecision: true,
            targetIndependentDecisionBudget: true,
            zeroShotDecisionsExecuted: zero.count + 1,
            trainedDecisionsExecuted: target.count + 1
        )
    }

    private static func shardBundle(
        seed: Int,
        profileID: String,
        corpusManifestSHA256: String,
        probeManifestSHA256: String,
        checkpointSHA256: String,
        rows: [Authority.RawPrediction]
    ) -> ShardBundle {
        let ordered = rows.sorted { $0.rowID < $1.rowID }
        var bindings = [Authority.EvaluationShardBinding]()
        var dataByFileName = [String: Data]()
        for phase in ["zero_shot", "trained", "reloaded"] {
            let modelBinding: String
            if phase == "zero_shot" {
                modelBinding = sha256(
                    Data(
                        [
                            Authority.lineageID,
                            profileID,
                            String(seed),
                            corpusManifestSHA256,
                            probeManifestSHA256,
                            Authority.generationContractID,
                            "random_init",
                        ].joined(separator: "|").utf8
                    )
                )
            } else {
                modelBinding = checkpointSHA256
            }
            let entries = ordered.map {
                row -> GenerationShardEntry in
                let generated: Generated
                if phase == "zero_shot" {
                    generated = Generated(
                        text: row.zeroShotPrediction,
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
                        utf8Valid:
                            row.zeroShotUTF8Valid,
                        eosLogProbability:
                            row.zeroShotEOSLogProbability,
                        rawFullVocabularyAllowedSupportGreedyTokenParity:
                            row
                                .zeroShotRawFullVocabularyAllowedSupportGreedyTokenParity,
                        disallowedFullVocabularyArgmaxCount:
                            row
                                .zeroShotDisallowedFullVocabularyArgmaxCount,
                        maximumDisallowedTokenProbabilityMass:
                            row
                                .zeroShotMaximumDisallowedTokenProbabilityMass,
                        latencySeconds:
                            row.zeroShotLatencySeconds
                    )
                } else {
                    generated = Generated(
                        text: row.trainedPrediction,
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
                        utf8Valid:
                            row.trainedUTF8Valid,
                        eosLogProbability:
                            row.trainedEOSLogProbability,
                        rawFullVocabularyAllowedSupportGreedyTokenParity:
                            row
                                .trainedRawFullVocabularyAllowedSupportGreedyTokenParity,
                        disallowedFullVocabularyArgmaxCount:
                            row
                                .trainedDisallowedFullVocabularyArgmaxCount,
                        maximumDisallowedTokenProbabilityMass:
                            row
                                .trainedMaximumDisallowedTokenProbabilityMass,
                        latencySeconds:
                            row.trainedLatencySeconds
                    )
                }
                return GenerationShardEntry(
                    rowID: row.rowID,
                    generated: generated
                )
            }
            let fileName = "\(phase)-shard-00000.json"
            let shard = GenerationShard(
                schemaVersion: "2",
                phase: phase,
                profileID: profileID,
                seed: seed,
                corpusManifestSHA256:
                    corpusManifestSHA256,
                generationContractID:
                    Authority.generationContractID,
                maximumGenerationTokenDecisions:
                    Authority.maximumGenerationTokenDecisions,
                modelBindingSHA256: modelBinding,
                firstRowID: ordered.first!.rowID,
                lastRowID: ordered.last!.rowID,
                entries: entries
            )
            let data = try! prettyEncoder().encode(shard)
            dataByFileName[fileName] = data
            bindings.append(
                Authority.EvaluationShardBinding(
                    phase: phase,
                    fileName: fileName,
                    artifactSHA256: sha256(data),
                    rowCount: entries.count,
                    firstRowID: ordered.first!.rowID,
                    lastRowID: ordered.last!.rowID
                )
            )
        }
        return ShardBundle(
            bindings: bindings,
            dataByFileName: dataByFileName
        )
    }

    private static func probeBundle(
        seed: Int,
        steps: Int,
        batchSize: Int,
        gradientAccumulationSteps: Int,
        sequenceLength: Int,
        validTrainingRows: [Corpus.Row],
        refusalTrainingRows: [Corpus.Row],
        tokenizerManifestSHA256: String,
        corpusManifestSHA256: String,
        corpusManifestArtifactSHA256: String
    ) -> ProbeBundle {
        let validFitting = validTrainingRows.filter {
            $0.sequenceTokenCount <= sequenceLength
        }
        let refusalFitting = refusalTrainingRows.filter {
            $0.sequenceTokenCount <= sequenceLength
        }
        let effectiveBatchSize =
            batchSize * gradientAccumulationSteps
        let scheduledCount = steps * effectiveBatchSize
        precondition(scheduledCount % 288 == 0)
        let blockCount = scheduledCount / 288
        let scheduledValid = Authority
            .deterministicBalancedScheduleRowIDs(
                rows: validFitting,
                seed: seed,
                count: blockCount * 240,
                namespace: "balanced_valid_train_v1",
                corpusManifestSHA256:
                    corpusManifestSHA256
            )
        let scheduledRefusalWitness = Authority
            .deterministicRefusalReasonSchedule(
                rows: refusalFitting,
                seed: seed,
                blockCount: blockCount,
                namespace:
                    "balanced_refusal_reason_stratified_train_v2",
                corpusManifestSHA256:
                    corpusManifestSHA256
            )!
        let scheduledRefusal =
            scheduledRefusalWitness.rowIDs
        let scheduled = interleavedFiveToOne(
            valid: scheduledValid,
            refusal: scheduledRefusal
        )
        let byID = Dictionary(
            uniqueKeysWithValues:
                (validFitting + refusalFitting).map {
                    ($0.rowID, $0)
                }
        )
        let scheduledRows = scheduled.map { byID[$0]! }
        let materialized = Dictionary(
            uniqueKeysWithValues:
                scheduledRows.map { ($0.rowID, $0) }
        ).values.sorted { $0.rowID < $1.rowID }
        let heldoutValidCandidates =
            Corpus.rows(for: .validation)
            .filter { $0.sequenceTokenCount <= sequenceLength }
        let heldoutRefusalCandidates =
            Corpus.rows(for: .refusalValidation)
            .filter { $0.sequenceTokenCount <= sequenceLength }
        let heldoutValid = Authority
            .deterministicBalancedScheduleRowIDs(
                rows: heldoutValidCandidates,
                seed: seed,
                count: 240,
                namespace: "balanced_valid_selection_v1",
                corpusManifestSHA256:
                    corpusManifestSHA256
            )
        let heldoutRefusalWitness = Authority
            .deterministicRefusalReasonSchedule(
                rows: heldoutRefusalCandidates,
                seed: seed,
                blockCount: 1,
                namespace:
                    "balanced_refusal_reason_stratified_selection_v2",
                corpusManifestSHA256:
                    corpusManifestSHA256
            )!
        let heldoutRefusal =
            heldoutRefusalWitness.rowIDs
        let heldout = interleavedFiveToOne(
            valid: heldoutValid,
            refusal: heldoutRefusal
        )
        let heldoutSHA = sha256(
            Data(heldout.joined(separator: "\n").utf8)
        )
        let scheduledFamilies = Dictionary(
            grouping: scheduledRows,
            by: \.semanticFamily
        ).mapValues(\.count)
        let scheduledValidFamilies = Dictionary(
            grouping: scheduledValid.map { byID[$0]! },
            by: \.semanticFamily
        ).mapValues(\.count)
        let scheduledRefusalFamilies = Dictionary(
            grouping: scheduledRefusal.map { byID[$0]! },
            by: \.semanticFamily
        ).mapValues(\.count)
        let heldoutByID = Dictionary(
            uniqueKeysWithValues:
                (
                    heldoutValidCandidates
                        + heldoutRefusalCandidates
                ).map { ($0.rowID, $0) }
        )
        let heldoutValidFamilies = Dictionary(
            grouping: heldoutValid.map { heldoutByID[$0]! },
            by: \.semanticFamily
        ).mapValues(\.count)
        let heldoutRefusalFamilies = Dictionary(
            grouping: heldoutRefusal.map {
                heldoutByID[$0]!
            },
            by: \.semanticFamily
        ).mapValues(\.count)
        let nonPadding = scheduledRows.map(
            \.sequenceTokenCount
        ).reduce(0, +)
        let answerTokens = scheduledRows.map {
            PrimeNativeByteTokenizer.encode(
                $0.expectedCompletion
            ).count + 1
        }.reduce(0, +)
        let processed =
            scheduledRows.count * sequenceLength
        let manifest = ProbeTokenManifest(
            schemaVersion: "2",
            tokenizerManifestSHA256:
                tokenizerManifestSHA256,
            corpusManifestSHA256:
                corpusManifestSHA256,
            corpusManifestArtifactSHA256:
                corpusManifestArtifactSHA256,
            seed: seed,
            steps: steps,
            measurementWarmupSteps: 0,
            timedSteps: steps,
            batchSize: batchSize,
            gradientAccumulationSteps:
                gradientAccumulationSteps,
            effectiveBatchSize: effectiveBatchSize,
            sequenceLength: sequenceLength,
            presentationMode:
                "balanced_manifest_epoch_permutation",
            probePurposeID:
                "bounded_full_diagnostic_v1",
            scheduleID:
                "manifest_sha256_curriculum_240_valid_48_refusal_epoch_reason_stratified_v3",
            uniqueInputRows: Set(scheduled).count,
            scheduledRowIDs: scheduled,
            scheduledValidRowCount: scheduledValid.count,
            scheduledRefusalRowCount:
                scheduledRefusal.count,
            scheduledValidSemanticFamilyRows:
                scheduledValidFamilies,
            scheduledRefusalSemanticFamilyRows:
                scheduledRefusalFamilies,
            scheduledRefusalReasonRows:
                scheduledRefusalWitness.reasonRowCounts,
            scheduledRefusalReasonScheduleSHA256:
                scheduledRefusalWitness
                    .orderedReasonScheduleSHA256,
            heldoutRowIDs: heldout,
            heldoutValidRowCount: heldoutValid.count,
            heldoutRefusalRowCount:
                heldoutRefusal.count,
            heldoutValidSemanticFamilyRows:
                heldoutValidFamilies,
            heldoutRefusalSemanticFamilyRows:
                heldoutRefusalFamilies,
            heldoutRefusalReasonRows:
                heldoutRefusalWitness.reasonRowCounts,
            heldoutRefusalReasonScheduleSHA256:
                heldoutRefusalWitness
                    .orderedReasonScheduleSHA256,
            selectionValidationSplitIDs: [
                Corpus.Split.validation.rawValue,
                Corpus.Split.refusalValidation.rawValue,
            ],
            heldoutScheduleSHA256: heldoutSHA,
            processedPaddedTokenPositions: processed,
            nonPaddingInputTokenPresentations:
                nonPadding,
            lossContributingAnswerTokenPresentations:
                answerTokens,
            inputIDs: materialized.map {
                preparedInputIDs(
                    $0,
                    sequenceLength: sequenceLength
                )
            },
            lossMasks: materialized.map {
                preparedLossMask(
                    $0,
                    sequenceLength: sequenceLength
                )
            }
        )
        let canonical = try! canonicalEncoder().encode(manifest)
        let artifact = try! prettyEncoder().encode(manifest)
        return ProbeBundle(
            fileName: "probe-token-manifest.json",
            canonicalSHA256: sha256(canonical),
            artifactSHA256: sha256(artifact),
            artifactData: artifact,
            tokenCount: processed,
            scheduledRowIDs: scheduled,
            scheduledValidRowCount: scheduledValid.count,
            scheduledRefusalRowCount:
                scheduledRefusal.count,
            scheduledValidSemanticFamilyRows:
                scheduledValidFamilies,
            scheduledRefusalSemanticFamilyRows:
                scheduledRefusalFamilies,
            scheduledRefusalReasonRows:
                scheduledRefusalWitness.reasonRowCounts,
            scheduledRefusalReasonScheduleSHA256:
                scheduledRefusalWitness
                    .orderedReasonScheduleSHA256,
            heldoutRowIDs: heldout,
            heldoutValidRowCount: heldoutValid.count,
            heldoutRefusalRowCount:
                heldoutRefusal.count,
            heldoutValidSemanticFamilyRows:
                heldoutValidFamilies,
            heldoutRefusalSemanticFamilyRows:
                heldoutRefusalFamilies,
            heldoutRefusalReasonRows:
                heldoutRefusalWitness.reasonRowCounts,
            heldoutRefusalReasonScheduleSHA256:
                heldoutRefusalWitness
                    .orderedReasonScheduleSHA256,
            heldoutScheduleSHA256: heldoutSHA,
            scheduledSemanticFamilyRows:
                scheduledFamilies,
            nonPaddingTokens: nonPadding,
            answerTokens: answerTokens
        )
    }

    private static func interleavedFiveToOne(
        valid: [String],
        refusal: [String]
    ) -> [String] {
        precondition(valid.count == refusal.count * 5)
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

    private static func heldoutLossBundle(
        rowIDs: [String],
        selectionRows: [Corpus.Row]
    ) -> HeldoutLossBundle {
        let byID = Dictionary(
            uniqueKeysWithValues:
                selectionRows.map { ($0.rowID, $0) }
        )
        let rows = rowIDs.enumerated().map {
            index, rowID -> Authority.HeldoutLossRow in
            let row = byID[rowID]!
            return Authority.HeldoutLossRow(
                rowID: row.rowID,
                rowSHA256: row.rowSHA256,
                selectionSplitID: row.split,
                targetClass:
                    row.split
                        == Corpus.Split
                            .refusalValidation.rawValue
                    ? "refusal_abstain"
                    : "valid_completion",
                semanticFamily: row.semanticFamily,
                targetTokenCount:
                    PrimeNativeByteTokenizer
                        .encode(row.expectedCompletion).count + 1,
                nonPaddingTokenCount: row.sequenceTokenCount,
                crossEntropyBefore:
                    6 + Double(index % 7) / 100,
                crossEntropyAfter:
                    1 + Double(index % 5) / 100
            )
        }
        let targetTokenCount =
            rows.map(\.targetTokenCount).reduce(0, +)
        let nonPaddingTokenCount =
            rows.map(\.nonPaddingTokenCount).reduce(0, +)
        let totalWeight = Double(targetTokenCount)
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
        func byFamily(
            _ keyPath: KeyPath<Authority.HeldoutLossRow, Double>
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
        func weightedLoss(
            _ classRows: [Authority.HeldoutLossRow],
            _ keyPath:
                KeyPath<Authority.HeldoutLossRow, Double>
        ) -> Double {
            let tokens =
                classRows.map(\.targetTokenCount).reduce(0, +)
            return classRows.reduce(0.0) {
                $0
                    + $1[keyPath: keyPath]
                        * Double($1.targetTokenCount)
            } / Double(tokens)
        }
        let validRows = rows.filter {
            $0.targetClass == "valid_completion"
        }
        let refusalRows = rows.filter {
            $0.targetClass == "refusal_abstain"
        }
        return HeldoutLossBundle(
            rows: rows,
            targetTokenCount: targetTokenCount,
            nonPaddingTokenCount: nonPaddingTokenCount,
            crossEntropyBefore: before,
            crossEntropyAfter: after,
            standardError: standardError,
            familyBefore: byFamily(\.crossEntropyBefore),
            familyAfter: byFamily(\.crossEntropyAfter),
            validTargetTokenCount:
                validRows.map(\.targetTokenCount).reduce(0, +),
            refusalTargetTokenCount:
                refusalRows.map(\.targetTokenCount).reduce(0, +),
            validCrossEntropyBefore:
                weightedLoss(validRows, \.crossEntropyBefore),
            validCrossEntropyAfter:
                weightedLoss(validRows, \.crossEntropyAfter),
            refusalCrossEntropyBefore:
                weightedLoss(refusalRows, \.crossEntropyBefore),
            refusalCrossEntropyAfter:
                weightedLoss(refusalRows, \.crossEntropyAfter)
        )
    }

    private static func preparedInputIDs(
        _ row: Corpus.Row,
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

    private static func preparedLossMask(
        _ row: Corpus.Row,
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

    private static func canonicalEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return encoder
    }

    private static func prettyEncoder() -> JSONEncoder {
        let encoder = canonicalEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return encoder
    }

    private static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }
}
