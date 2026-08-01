import Foundation

/// Canonical parser and exact reconciliation authority for the staged native
/// language run configuration. The configuration hash proves exact bytes;
/// this authority proves that every behavior/provenance binding in those
/// bytes agrees with the executor invocation and the independently regraded
/// report.
public enum ErgenticsNativeLanguageRunConfiguration {
    public static let discoveryPurposeID =
        "balanced_lr_discovery_v1"
    public static let confirmationPurposeID =
        "balanced_lr_confirmation_v1"

    public enum ValidationError: Error, Equatable {
        case invalidUTF8
        case malformedLine
        case duplicateOrEmptyBinding
        case invalidKeySet
        case invalidValue(String)
        case expectedBindingMismatch
    }

    public struct Configuration: Equatable, Sendable {
        public let mode: ErgenticsNativeLanguageCanary.Mode
        public let buildConfiguration: String
        public let precision: String
        public let phase: String?
        public let probePurposeID: String?
        public let profileID: String
        public let seed: Int
        public let steps: Int
        public let batchSize: Int
        public let gradientAccumulationSteps: Int
        public let sequenceLength: Int
        public let processedPaddedTokenPositions: Int
        public let plannedTrainingTokenPresentations: Int
        public let evaluationBatchSize: Int
        public let evaluationShardSize: Int?
        public let learningRate: Double
        public let weightDecay: Double
        public let maximumExecutorWallSeconds: Double
        public let executorWallAccountingID: String
        public let tokenizerArtifactSHA256: String
        public let corpusArtifactSHA256: String
        public let packageResolvedSHA256: String
        public let executorSHA256: String
        public let recommenderSHA256: String
        public let metalLibraryArtifactSHA256: String
        public let metalLibraryArtifactByteCount: Int64
        public let metalLibraryPrimaryFileName: String
        public let metalLibraryFallbackFileName: String
        public let metalLibraryBundleSearchAuditID: String
        public let metalLibrarySourceMLXSwiftRevision: String

        public init(
            mode: ErgenticsNativeLanguageCanary.Mode,
            buildConfiguration: String,
            precision: String,
            phase: String?,
            probePurposeID: String?,
            profileID: String,
            seed: Int,
            steps: Int,
            batchSize: Int,
            gradientAccumulationSteps: Int,
            sequenceLength: Int,
            processedPaddedTokenPositions: Int,
            plannedTrainingTokenPresentations: Int,
            evaluationBatchSize: Int,
            evaluationShardSize: Int?,
            learningRate: Double,
            weightDecay: Double,
            maximumExecutorWallSeconds: Double,
            executorWallAccountingID: String =
                ErgenticsNativeLanguageCanary
                    .executorWallAccountingID,
            tokenizerArtifactSHA256: String,
            corpusArtifactSHA256: String,
            packageResolvedSHA256: String,
            executorSHA256: String,
            recommenderSHA256: String,
            metalLibraryArtifactSHA256: String,
            metalLibraryArtifactByteCount: Int64,
            metalLibraryPrimaryFileName: String,
            metalLibraryFallbackFileName: String,
            metalLibraryBundleSearchAuditID: String,
            metalLibrarySourceMLXSwiftRevision: String
        ) {
            self.mode = mode
            self.buildConfiguration = buildConfiguration
            self.precision = precision
            self.phase = phase
            self.probePurposeID = probePurposeID
            self.profileID = profileID
            self.seed = seed
            self.steps = steps
            self.batchSize = batchSize
            self.gradientAccumulationSteps =
                gradientAccumulationSteps
            self.sequenceLength = sequenceLength
            self.processedPaddedTokenPositions =
                processedPaddedTokenPositions
            self.plannedTrainingTokenPresentations =
                plannedTrainingTokenPresentations
            self.evaluationBatchSize = evaluationBatchSize
            self.evaluationShardSize = evaluationShardSize
            self.learningRate = learningRate
            self.weightDecay = weightDecay
            self.maximumExecutorWallSeconds =
                maximumExecutorWallSeconds
            self.executorWallAccountingID =
                executorWallAccountingID
            self.tokenizerArtifactSHA256 =
                tokenizerArtifactSHA256
            self.corpusArtifactSHA256 =
                corpusArtifactSHA256
            self.packageResolvedSHA256 =
                packageResolvedSHA256
            self.executorSHA256 = executorSHA256
            self.recommenderSHA256 = recommenderSHA256
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
            self.metalLibrarySourceMLXSwiftRevision =
                metalLibrarySourceMLXSwiftRevision
        }
    }

    public typealias Expected = Configuration

    private static let commonKeys: Set<String> = [
        "schema_version",
        "generation_contract_id",
        "mode",
        "build_configuration",
        "precision",
        "profile_id",
        "seed",
        "steps",
        "batch_size",
        "gradient_accumulation_steps",
        "sequence_length",
        "processed_padded_token_positions",
        "planned_training_token_presentations",
        "evaluation_batch_size",
        "learning_rate",
        "weight_decay",
        "max_seconds",
        "executor_wall_accounting_id",
        "tokenizer_artifact_sha256",
        "corpus_artifact_sha256",
        "package_resolved_sha256",
        "executor_sha256",
        "recommender_sha256",
        "metal_library_artifact_sha256",
        "metal_library_artifact_byte_count",
        "metal_library_primary_file_name",
        "metal_library_fallback_file_name",
        "metal_library_bundle_search_audit_id",
        "metal_library_source_mlx_swift_revision",
    ]

    private static let profileOnlyKeys: Set<String> = [
        "hyperparameter_search_id",
        "phase",
        "probe_purpose_id",
    ]

    private static let fullOnlyKeys: Set<String> = [
        "evaluation_shard_size",
    ]

    private static func integer(
        _ key: String,
        in values: [String: String],
        positive: Bool = true
    ) throws -> Int {
        guard let raw = values[key],
              let parsed = Int(raw),
              String(parsed) == raw,
              !positive || parsed > 0 else {
            throw ValidationError.invalidValue(key)
        }
        return parsed
    }

    private static func finiteDouble(
        _ key: String,
        in values: [String: String],
        nonnegative: Bool = false
    ) throws -> Double {
        guard let raw = values[key],
              raw.range(
                  of:
                    #"^(0|[1-9][0-9]*)(\.[0-9]*[1-9])?$"#,
                  options: .regularExpression
              ) != nil,
              let parsed = Double(raw),
              parsed.isFinite,
              nonnegative ? parsed >= 0 : parsed > 0 else {
            throw ValidationError.invalidValue(key)
        }
        return parsed
    }

    private static func positiveInt64(
        _ key: String,
        in values: [String: String]
    ) throws -> Int64 {
        guard let raw = values[key],
              let parsed = Int64(raw),
              parsed > 0,
              String(parsed) == raw else {
            throw ValidationError.invalidValue(key)
        }
        return parsed
    }

    private static func isSHA256(_ value: String) -> Bool {
        value.count == 64
            && value.allSatisfy {
                "0123456789abcdef".contains($0)
            }
    }

    public static func parse(_ data: Data) throws -> Configuration {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ValidationError.invalidUTF8
        }
        guard text.hasSuffix("\n"),
              !text.hasPrefix("\n"),
              !text.contains("\r"),
              !text.dropLast().contains("\n\n") else {
            throw ValidationError.malformedLine
        }
        var values = [String: String]()
        for line in text.dropLast().split(
            separator: "\n",
            omittingEmptySubsequences: false
        ) {
            guard let separator = line.firstIndex(of: "=") else {
                throw ValidationError.malformedLine
            }
            let key = String(line[..<separator])
            let value = String(line[line.index(after: separator)...])
            guard !key.isEmpty, !value.isEmpty,
                  values[key] == nil else {
                throw ValidationError.duplicateOrEmptyBinding
            }
            values[key] = value
        }
        guard values["schema_version"]
                == ErgenticsNativeLanguageCanary.schemaVersion,
              values["generation_contract_id"]
                == ErgenticsNativeLanguageCanary
                    .generationContractID,
              values["executor_wall_accounting_id"]
                == ErgenticsNativeLanguageCanary
                    .executorWallAccountingID,
              let rawMode = values["mode"],
              let mode =
                ErgenticsNativeLanguageCanary.Mode(
                    rawValue: rawMode
                ),
              values["build_configuration"]
                == ErgenticsNativeLanguageCanary
                    .requiredBuildConfiguration,
              values["precision"]
                == ErgenticsNativeLanguageCanary
                    .requiredPrecision else {
            throw ValidationError.invalidValue("authority")
        }
        let expectedKeys =
            commonKeys.union(
                mode == .profileProbe
                ? profileOnlyKeys : fullOnlyKeys
            )
        guard Set(values.keys) == expectedKeys else {
            throw ValidationError.invalidKeySet
        }
        guard let profileID = values["profile_id"],
              ErgenticsNativeScaleEngineRecommend.profiles
                .contains(where: { $0.profileID == profileID })
        else {
            throw ValidationError.invalidValue("profile_id")
        }
        let seed = try integer("seed", in: values)
        let steps = try integer("steps", in: values)
        let batchSize = try integer("batch_size", in: values)
        let accumulation = try integer(
            "gradient_accumulation_steps",
            in: values
        )
        let sequenceLength = try integer(
            "sequence_length",
            in: values
        )
        let processed = try integer(
            "processed_padded_token_positions",
            in: values
        )
        let planned = try integer(
            "planned_training_token_presentations",
            in: values
        )
        let (stepBatch, stepBatchOverflow) =
            steps.multipliedReportingOverflow(by: batchSize)
        let (withAccumulation, accumulationOverflow) =
            stepBatch.multipliedReportingOverflow(by: accumulation)
        let (expectedProcessed, sequenceOverflow) =
            withAccumulation.multipliedReportingOverflow(
                by: sequenceLength
            )
        guard !stepBatchOverflow,
              !accumulationOverflow,
              !sequenceOverflow,
              processed == expectedProcessed,
              planned == processed else {
            throw ValidationError.invalidValue(
                "processed_padded_token_positions"
            )
        }
        let learningRate = try finiteDouble(
            "learning_rate",
            in: values
        )
        let weightDecay = try finiteDouble(
            "weight_decay",
            in: values,
            nonnegative: true
        )
        guard Float(learningRate).isFinite,
              Float(learningRate) > 0,
              Float(weightDecay).isFinite,
              Float(weightDecay) >= 0 else {
            throw ValidationError.invalidValue(
                "optimizer_float32_conversion"
            )
        }
        let hashKeys = [
            "tokenizer_artifact_sha256",
            "corpus_artifact_sha256",
            "package_resolved_sha256",
            "executor_sha256",
            "recommender_sha256",
            "metal_library_artifact_sha256",
        ]
        guard hashKeys.allSatisfy({
            values[$0].map(isSHA256) == true
        }) else {
            throw ValidationError.invalidValue("sha256")
        }
        guard values["metal_library_primary_file_name"]
                == ErgenticsNativeLanguageCanary
                    .metalLibraryPrimaryFileName,
              values["metal_library_fallback_file_name"]
                == ErgenticsNativeLanguageCanary
                    .metalLibraryFallbackFileName else {
            throw ValidationError.invalidValue(
                "metal_library_file_name"
            )
        }
        guard values["metal_library_bundle_search_audit_id"]
                == ErgenticsNativeLanguageCanary
                    .metalLibraryBundleSearchAuditID,
              let sourceRevision =
                values["metal_library_source_mlx_swift_revision"],
              sourceRevision.count == 40,
              sourceRevision.allSatisfy({
                  "0123456789abcdef".contains($0)
              }) else {
            throw ValidationError.invalidValue(
                "metal_library_source_provenance"
            )
        }
        let phase = values["phase"]
        let purpose = values["probe_purpose_id"]
        if mode == .profileProbe {
            guard values["hyperparameter_search_id"]
                    == ErgenticsNativeScaleEngineRecommend
                        .adaptiveSearchID,
                  ErgenticsNativeScaleEngineRecommend
                    .discoveryLearningRates.contains(learningRate),
                  (
                      phase == "discovery"
                          && purpose == discoveryPurposeID
                          && seed
                            == ErgenticsNativeScaleEngineRecommend
                                .discoverySeed
                      || phase == "confirmation"
                          && purpose == confirmationPurposeID
                          && ErgenticsNativeScaleEngineRecommend
                            .confirmationSeeds.contains(seed)
                  ) else {
                throw ValidationError.invalidValue(
                    "profile_phase_contract"
                )
            }
        } else {
            guard ErgenticsNativeLanguageCanary.frozenSeeds
                    .contains(seed) else {
                throw ValidationError.invalidValue("seed")
            }
        }
        return Configuration(
            mode: mode,
            buildConfiguration:
                values["build_configuration"]!,
            precision: values["precision"]!,
            phase: phase,
            probePurposeID: purpose,
            profileID: profileID,
            seed: seed,
            steps: steps,
            batchSize: batchSize,
            gradientAccumulationSteps: accumulation,
            sequenceLength: sequenceLength,
            processedPaddedTokenPositions: processed,
            plannedTrainingTokenPresentations: planned,
            evaluationBatchSize: try integer(
                "evaluation_batch_size",
                in: values
            ),
            evaluationShardSize:
                mode == .fullCanary
                ? try integer(
                    "evaluation_shard_size",
                    in: values
                ) : nil,
            learningRate: learningRate,
            weightDecay: weightDecay,
            maximumExecutorWallSeconds: try finiteDouble(
                "max_seconds",
                in: values
            ),
            executorWallAccountingID:
                values["executor_wall_accounting_id"]!,
            tokenizerArtifactSHA256:
                values["tokenizer_artifact_sha256"]!,
            corpusArtifactSHA256:
                values["corpus_artifact_sha256"]!,
            packageResolvedSHA256:
                values["package_resolved_sha256"]!,
            executorSHA256: values["executor_sha256"]!,
            recommenderSHA256: values["recommender_sha256"]!,
            metalLibraryArtifactSHA256:
                values["metal_library_artifact_sha256"]!,
            metalLibraryArtifactByteCount:
                try positiveInt64(
                    "metal_library_artifact_byte_count",
                    in: values
                ),
            metalLibraryPrimaryFileName:
                values["metal_library_primary_file_name"]!,
            metalLibraryFallbackFileName:
                values["metal_library_fallback_file_name"]!,
            metalLibraryBundleSearchAuditID:
                values["metal_library_bundle_search_audit_id"]!,
            metalLibrarySourceMLXSwiftRevision:
                values["metal_library_source_mlx_swift_revision"]!
        )
    }

    @discardableResult
    public static func validate(
        _ data: Data,
        expected: Expected
    ) throws -> Configuration {
        let configuration = try parse(data)
        guard configuration == expected else {
            throw ValidationError.expectedBindingMismatch
        }
        return configuration
    }
}
