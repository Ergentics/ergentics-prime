import Foundation
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

public struct PrimeNativeNeuralGateMLXSourcePin:
    Encodable,
    Equatable,
    Sendable
{
    public let roleID: String
    public let remoteURL: String
    public let revision: String
    public let treeOID: String
    public let relativePath: String
    public let gitBlobOID: String
    public let byteCount: UInt64
    public let sha256: String

    fileprivate init(
        roleID: String,
        remoteURL: String,
        revision: String,
        treeOID: String,
        relativePath: String,
        gitBlobOID: String,
        byteCount: UInt64,
        sha256: String
    ) {
        self.roleID = roleID
        self.remoteURL = remoteURL
        self.revision = revision
        self.treeOID = treeOID
        self.relativePath = relativePath
        self.gitBlobOID = gitBlobOID
        self.byteCount = byteCount
        self.sha256 = sha256
    }

    public func validate() throws {
        let gitValues = [
            revision,
            treeOID,
            gitBlobOID,
        ]
        guard semanticIsSafeIdentifier(roleID),
              remoteURL.hasPrefix("https://github.com/"),
              gitValues.allSatisfy({
                  $0.utf8.count == 40
                      && $0.utf8.allSatisfy({ byte in
                          (byte >= 48 && byte <= 57)
                              || (byte >= 97 && byte <= 102)
                      })
              }),
              semanticIsSafeRelativePath(relativePath),
              byteCount > 0,
              semanticIsLowercaseSHA256(sha256)
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidMLXObservation(roleID)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case roleID = "role_id"
        case remoteURL = "remote_url"
        case revision
        case treeOID = "tree_oid"
        case relativePath = "relative_path"
        case gitBlobOID = "git_blob_oid"
        case byteCount = "byte_count"
        case sha256
    }
}

public struct PrimeNativeNeuralGateMLXObservationContract:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let observationSchemaID: String
    public let sourceBindingContractID: String
    public let sidecarCodecID: String
    public let operationID: String
    public let inputDType: String
    public let outputDType: String
    public let axis: Int
    public let fullVocabularyLogitCount: Int
    public let maximumDictionaryVectorCount: Int
    public let maximumBatchVectorCount: Int
    public let bitPatternSerializationID: String
    public let exactLogSoftmaxFunctionSerializationID:
        String
    public let exactLogSoftmaxFunctionSHA256: String
    public let sourcePins:
        [PrimeNativeNeuralGateMLXSourcePin]
    public let MLXImportedBySemanticContract: Bool
    public let durableArtifactObserved: Bool
    public let fullFixtureRecomputationObserved: Bool
    public let modelExecutionObserved: Bool
    public let metalExecutionAuthorityObserved: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    public static let frozenV1 = Self(
        schemaVersion: 1,
        contractID:
            "prime_stage_b_mlx_digest_observation_schema_contract_v1",
        observationSchemaID:
            "prime_stage_b_mlx_logsoftmax_digest_observation_v1",
        sourceBindingContractID:
            "prime_stage_b_logit_sidecar_float32_logsoftmax_source_binding_v1",
        sidecarCodecID:
            "prime_stage_b_full_vocabulary_logit_sidecar_dictionary_deduplicated_row_index_chunks_big_endian_v1",
        operationID:
            "mlxnn_float32_logsoftmax_axis_minus_one_over_full_512_vocabulary_v1",
        inputDType: "float32",
        outputDType: "float32",
        axis: -1,
        fullVocabularyLogitCount: 512,
        maximumDictionaryVectorCount: 65_536,
        maximumBatchVectorCount: 256,
        bitPatternSerializationID:
            "primelsm1_then_uint32_be_vector_count_uint32_be_vocabulary_count_then_float32_bit_patterns_uint32_be_row_major_v1",
        exactLogSoftmaxFunctionSerializationID:
            "utf8_exact_three_line_function_declaration_body_and_closing_brace_with_final_lf_v1",
        exactLogSoftmaxFunctionSHA256:
            "8d576115e1be7648d4a4da72c025893d23e67b1d30a53646d09e74bfe58fc639",
        sourcePins: makeMLXSourcePins(),
        MLXImportedBySemanticContract: false,
        durableArtifactObserved: false,
        fullFixtureRecomputationObserved: false,
        modelExecutionObserved: false,
        metalExecutionAuthorityObserved: false,
        scientificAuthorityAuthorized: false,
        productAuthorityAuthorized: false
    )

    public func validate() throws {
        try sourcePins.forEach { try $0.validate() }
        guard self == .frozenV1,
              schemaVersion == 1,
              semanticIsSafeIdentifier(contractID),
              semanticIsSafeIdentifier(observationSchemaID),
              semanticIsSafeIdentifier(sourceBindingContractID),
              semanticIsSafeIdentifier(sidecarCodecID),
              semanticIsSafeIdentifier(operationID),
              inputDType == "float32",
              outputDType == "float32",
              axis == -1,
              fullVocabularyLogitCount == 512,
              maximumDictionaryVectorCount == 65_536,
              maximumBatchVectorCount == 256,
              semanticIsLowercaseSHA256(
                  exactLogSoftmaxFunctionSHA256
              ),
              sourcePins.count == 4,
              Set(sourcePins.map(\.roleID)).count == 4,
              !MLXImportedBySemanticContract,
              !durableArtifactObserved,
              !fullFixtureRecomputationObserved,
              !modelExecutionObserved,
              !metalExecutionAuthorityObserved,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidFrozenContract
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case observationSchemaID = "observation_schema_id"
        case sourceBindingContractID =
            "source_binding_contract_id"
        case sidecarCodecID = "sidecar_codec_id"
        case operationID = "operation_id"
        case inputDType = "input_dtype"
        case outputDType = "output_dtype"
        case axis
        case fullVocabularyLogitCount =
            "full_vocabulary_logit_count"
        case maximumDictionaryVectorCount =
            "maximum_dictionary_vector_count"
        case maximumBatchVectorCount =
            "maximum_batch_vector_count"
        case bitPatternSerializationID =
            "bit_pattern_serialization_id"
        case exactLogSoftmaxFunctionSerializationID =
            "exact_logsoftmax_function_serialization_id"
        case exactLogSoftmaxFunctionSHA256 =
            "exact_logsoftmax_function_sha256"
        case sourcePins = "source_pins"
        case MLXImportedBySemanticContract =
            "mlx_imported_by_semantic_contract"
        case durableArtifactObserved =
            "durable_artifact_observed"
        case fullFixtureRecomputationObserved =
            "full_fixture_recomputation_observed"
        case modelExecutionObserved = "model_execution_observed"
        case metalExecutionAuthorityObserved =
            "metal_execution_authority_observed"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
    }
}

/// Digest-only MLX observation. It intentionally contains neither MLX values
/// nor `[[Float]]`; full vectors remain in the bounded sidecar.
public struct PrimeNativeNeuralGateMLXLogSoftmaxDigestObservation:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let sourceBindingContractID: String
    public let sidecarCodecID: String
    public let operationID: String
    public let evaluationSeed:
        PrimeNativeNeuralGateArtifactSeed
    public let inputDictionarySHA256: String
    public let vectorCount: Int
    public let vocabularyCount: Int
    public let inputDType: String
    public let outputDType: String
    public let axis: Int
    public let bitPatternSerializationID: String
    public let outputBitPatternSHA256: String
    public let sourcePins:
        [PrimeNativeNeuralGateMLXSourcePin]
    public let sourcePinningObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let recomputationObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let fullFixtureCoverageObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let durableArtifactObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let modelExecutionObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let metalExecutionAuthorityObserved:
        PrimeNativeNeuralGateSemanticObservationState
    public let processRecordPublished: Bool
    public let mechanicsPassAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool

    public init(
        evaluationSeed:
            PrimeNativeNeuralGateArtifactSeed,
        inputDictionarySHA256: String,
        vectorCount: Int,
        outputBitPatternSHA256: String,
        sourcePinningObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        recomputationObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        fullFixtureCoverageObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        durableArtifactObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        modelExecutionObserved:
            PrimeNativeNeuralGateSemanticObservationState,
        metalExecutionAuthorityObserved:
            PrimeNativeNeuralGateSemanticObservationState
    ) throws {
        let contract =
            PrimeNativeNeuralGateMLXObservationContract
            .frozenV1
        schemaVersion = 1
        schemaID = contract.observationSchemaID
        sourceBindingContractID =
            contract.sourceBindingContractID
        sidecarCodecID = contract.sidecarCodecID
        operationID = contract.operationID
        self.evaluationSeed = evaluationSeed
        self.inputDictionarySHA256 =
            inputDictionarySHA256
        self.vectorCount = vectorCount
        vocabularyCount =
            contract.fullVocabularyLogitCount
        inputDType = contract.inputDType
        outputDType = contract.outputDType
        axis = contract.axis
        bitPatternSerializationID =
            contract.bitPatternSerializationID
        self.outputBitPatternSHA256 =
            outputBitPatternSHA256
        sourcePins = contract.sourcePins
        self.sourcePinningObserved =
            sourcePinningObserved
        self.recomputationObserved =
            recomputationObserved
        self.fullFixtureCoverageObserved =
            fullFixtureCoverageObserved
        self.durableArtifactObserved =
            durableArtifactObserved
        self.modelExecutionObserved =
            modelExecutionObserved
        self.metalExecutionAuthorityObserved =
            metalExecutionAuthorityObserved
        processRecordPublished = false
        mechanicsPassAuthorized = false
        scientificAuthorityAuthorized = false
        productAuthorityAuthorized = false
        try validate()
    }

    public var relativePath: String {
        "neural-gate-replay/corrected/replicates/"
            + evaluationSeed.pathComponent
            + "/mlx-logsoftmax-observation.v1.json"
    }

    public func validate() throws {
        let contract =
            PrimeNativeNeuralGateMLXObservationContract
            .frozenV1
        try contract.validate()
        guard schemaVersion == 1,
              schemaID == contract.observationSchemaID,
              sourceBindingContractID
                == contract.sourceBindingContractID,
              sidecarCodecID == contract.sidecarCodecID,
              operationID == contract.operationID,
              semanticIsLowercaseSHA256(
                  inputDictionarySHA256
              ),
              vectorCount > 0,
              vectorCount
                <= contract.maximumDictionaryVectorCount,
              vocabularyCount
                == contract.fullVocabularyLogitCount,
              inputDType == "float32",
              outputDType == "float32",
              axis == -1,
              bitPatternSerializationID
                == contract.bitPatternSerializationID,
              semanticIsLowercaseSHA256(
                  outputBitPatternSHA256
              ),
              sourcePins == contract.sourcePins,
              semanticIsSafeRelativePath(relativePath),
              !processRecordPublished,
              !mechanicsPassAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidMLXObservation("digest_observation")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case sourceBindingContractID =
            "source_binding_contract_id"
        case sidecarCodecID = "sidecar_codec_id"
        case operationID = "operation_id"
        case evaluationSeed = "evaluation_seed"
        case inputDictionarySHA256 =
            "input_dictionary_sha256"
        case vectorCount = "vector_count"
        case vocabularyCount = "vocabulary_count"
        case inputDType = "input_dtype"
        case outputDType = "output_dtype"
        case axis
        case bitPatternSerializationID =
            "bit_pattern_serialization_id"
        case outputBitPatternSHA256 =
            "output_bit_pattern_sha256"
        case sourcePins = "source_pins"
        case sourcePinningObserved =
            "source_pinning_observed"
        case recomputationObserved =
            "recomputation_observed"
        case fullFixtureCoverageObserved =
            "full_fixture_coverage_observed"
        case durableArtifactObserved =
            "durable_artifact_observed"
        case modelExecutionObserved =
            "model_execution_observed"
        case metalExecutionAuthorityObserved =
            "metal_execution_authority_observed"
        case processRecordPublished =
            "process_record_published"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
    }
}

private func makeMLXSourcePins()
    -> [PrimeNativeNeuralGateMLXSourcePin]
{
    [
        .init(
            roleID: "companion_executor",
            remoteURL:
                "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
            revision:
                "163fc100710ece48119bc25954452d10f6a84f7f",
            treeOID:
                "9009daa4f8a07fbd5897e00b9571cef44ec292db",
            relativePath:
                "prime-runtime/Sources/PrimeNativeLanguageSwiftCanary/main.swift",
            gitBlobOID:
                "94227842cdff73434c926527a6081aaf20f37155",
            byteCount: 174_006,
            sha256:
                "7a3ba9477a7ac82dccfe6dcc7ec09af738b40298cdab6b259ddf1e9d36ec15b4"
        ),
        .init(
            roleID: "companion_package_lock",
            remoteURL:
                "https://github.com/Ergentics/pmhnp-companion-ergentics.git",
            revision:
                "163fc100710ece48119bc25954452d10f6a84f7f",
            treeOID:
                "9009daa4f8a07fbd5897e00b9571cef44ec292db",
            relativePath:
                "prime-runtime/Package.resolved",
            gitBlobOID:
                "18aef69512c82c3e6cdff192f3aa0a6ee13c702e",
            byteCount: 1_949,
            sha256:
                "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
        ),
        .init(
            roleID: "upstream_mlxnn_activations",
            remoteURL:
                "https://github.com/ml-explore/mlx-swift.git",
            revision:
                "072b684acaae80b6a463abab3a103732f33774bf",
            treeOID:
                "aecc4c90c4720b0624def30913f139eb1e878ea5",
            relativePath:
                "Source/MLXNN/Activations.swift",
            gitBlobOID:
                "f5ee9205eac15b537f6a9552371c30255c88e69e",
            byteCount: 19_101,
            sha256:
                "c6e82121f1a7efceca0de234b5ef0058162f70bcccc4cef63b6d85d524ef1beb"
        ),
        .init(
            roleID: "ergentics_mlxnn_activations",
            remoteURL:
                "https://github.com/Ergentics/ergentics-mlx-swift.git",
            revision:
                "d37885a278f1c37484a94d0f401a418735e66519",
            treeOID:
                "5310749549cca107fc1bb07d82dacf043bc02b9e",
            relativePath:
                "Source/MLXNN/Activations.swift",
            gitBlobOID:
                "a40618fac9f7c2226599c0219eccc11fcfcb0df5",
            byteCount: 23_918,
            sha256:
                "5145539a33687bb4e9ce5ac00b821fef9f5e18652818c278c1807443b5e552f1"
        ),
    ]
}
