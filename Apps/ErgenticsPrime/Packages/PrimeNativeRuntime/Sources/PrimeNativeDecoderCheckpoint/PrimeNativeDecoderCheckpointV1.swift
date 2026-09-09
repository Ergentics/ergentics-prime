// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import PrimeCore
import PrimeNativeDecoder
import MLX
import MLXNN

public enum PrimeNativeDecoderCheckpointError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case invalidTokenIdentity
    case invalidCompatibilityIdentity
    case invalidCheckpointManifest
    case invalidFileDescriptor(Int32)
    case checkpointDescriptorNotRegular
    case checkpointDescriptorNotReadable
    case checkpointDescriptorNotWritable
    case checkpointDescriptorAppendModeForbidden
    case checkpointFileTooLarge(observed: UInt64, maximum: UInt64)
    case duplicateParameterPath(String)
    case parameterPathSetMismatch
    case parameterShapeMismatch(String)
    case parameterDTypeMismatch(String)
    case parameterByteCountMismatch(String)
    case parameterContainsNonFiniteValue(String)
    case parameterLogicalHashMismatch(String)
    case checkpointMetadataMismatch
    case checkpointWriteFailed
    case checkpointReadFailed
    case checkpointRestoreFailed
    case checkpointSizeOverflow
}

public struct PrimeNativeDecoderConfigurationSnapshotV1:
    Codable,
    Equatable,
    Sendable
{
    public let vocabularySize: Int
    public let modelWidth: Int
    public let layerCount: Int
    public let queryHeadCount: Int
    public let keyValueHeadCount: Int
    public let headWidth: Int
    public let intermediateWidth: Int
    public let maximumSequenceLength: Int
    public let ropeThetaBitPattern: UInt32
    public let rmsNormEpsilonBitPattern: UInt32
    public let uniqueParameterCount: Int64

    public init(
        _ configuration: PrimeNativeGQADecoderConfiguration
    ) {
        vocabularySize = configuration.vocabularySize
        modelWidth = configuration.modelWidth
        layerCount = configuration.layerCount
        queryHeadCount = configuration.queryHeadCount
        keyValueHeadCount = configuration.keyValueHeadCount
        headWidth = configuration.headWidth
        intermediateWidth = configuration.intermediateWidth
        maximumSequenceLength = configuration.maximumSequenceLength
        ropeThetaBitPattern = configuration.ropeTheta.bitPattern
        rmsNormEpsilonBitPattern =
            configuration.rmsNormEpsilon.bitPattern
        uniqueParameterCount = configuration.uniqueParameterCount
    }

    public func configuration()
        throws -> PrimeNativeGQADecoderConfiguration
    {
        let result = try PrimeNativeGQADecoderConfiguration(
            vocabularySize: vocabularySize,
            modelWidth: modelWidth,
            layerCount: layerCount,
            queryHeadCount: queryHeadCount,
            keyValueHeadCount: keyValueHeadCount,
            headWidth: headWidth,
            intermediateWidth: intermediateWidth,
            maximumSequenceLength: maximumSequenceLength,
            ropeTheta: Float(bitPattern: ropeThetaBitPattern),
            rmsNormEpsilon: Float(
                bitPattern: rmsNormEpsilonBitPattern))
        guard result.uniqueParameterCount == uniqueParameterCount else {
            throw PrimeNativeDecoderCheckpointError.contractDrift
        }
        return result
    }

    private enum CodingKeys: String, CodingKey {
        case vocabularySize = "vocabulary_size"
        case modelWidth = "model_width"
        case layerCount = "layer_count"
        case queryHeadCount = "query_head_count"
        case keyValueHeadCount = "key_value_head_count"
        case headWidth = "head_width"
        case intermediateWidth = "intermediate_width"
        case maximumSequenceLength = "maximum_sequence_length"
        case ropeThetaBitPattern = "rope_theta_float32_bit_pattern"
        case rmsNormEpsilonBitPattern =
            "rms_norm_epsilon_float32_bit_pattern"
        case uniqueParameterCount = "unique_parameter_count"
    }
}

public struct PrimeNativeDecoderTokenIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let tokenizerID: String
    public let tokenizerManifestSHA256: String
    public let vocabularySize: Int

    public static func nativeByte512() throws -> Self {
        let manifest = try PrimeNativeByteTokenizer.manifest()
        let result = Self(
            schemaVersion: 1,
            tokenizerID: PrimeNativeByteTokenizer.tokenizerID,
            tokenizerManifestSHA256: manifest.manifestSHA256,
            vocabularySize:
                PrimeNativeByteTokenizer.boundModelVocabularySize)
        try result.validateNativeByte512()
        return result
    }

    static func synthetic(vocabularySize: Int) -> Self {
        Self(
            schemaVersion: 1,
            tokenizerID: "synthetic_checkpoint_test_tokenizer_only",
            tokenizerManifestSHA256: PrimeSHA256.hexDigest(
                of: Data(
                    "synthetic_checkpoint_test_tokenizer_only_\(vocabularySize)"
                        .utf8)),
            vocabularySize: vocabularySize)
    }

    func validateNativeByte512() throws {
        let authority = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
        guard schemaVersion == 1,
              tokenizerID == authority.publicTokenizerID,
              tokenizerManifestSHA256
                == authority.publicTokenizerManifestSHA256,
              vocabularySize == authority.publicVocabularySize,
              vocabularySize
                == PrimeNativeByteTokenizer.boundModelVocabularySize
        else {
            throw PrimeNativeDecoderCheckpointError.invalidTokenIdentity
        }
    }

    func validateSynthetic(expectedVocabularySize: Int) throws {
        guard schemaVersion == 1,
              tokenizerID
                == "synthetic_checkpoint_test_tokenizer_only",
              vocabularySize == expectedVocabularySize,
              tokenizerManifestSHA256 == PrimeSHA256.hexDigest(
                  of: Data(
                      "synthetic_checkpoint_test_tokenizer_only_\(vocabularySize)"
                          .utf8))
        else {
            throw PrimeNativeDecoderCheckpointError.invalidTokenIdentity
        }
    }

    private init(
        schemaVersion: Int,
        tokenizerID: String,
        tokenizerManifestSHA256: String,
        vocabularySize: Int
    ) {
        self.schemaVersion = schemaVersion
        self.tokenizerID = tokenizerID
        self.tokenizerManifestSHA256 = tokenizerManifestSHA256
        self.vocabularySize = vocabularySize
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case tokenizerID = "tokenizer_id"
        case tokenizerManifestSHA256 = "tokenizer_manifest_sha256"
        case vocabularySize = "vocabulary_size"
    }
}

public struct PrimeNativeDecoderParameterDescriptorV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let shape: [Int]
    public let dtype: String
    public let elementCount: UInt64
    public let byteCount: UInt64

    private enum CodingKeys: String, CodingKey {
        case path
        case shape
        case dtype
        case elementCount = "element_count"
        case byteCount = "byte_count"
    }
}

public struct PrimeNativeDecoderCompatibilityIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let identityScope: String
    public let authorityID: String
    public let architectureSchema: String
    public let implementationID: String
    public let decoderSourceSHA256: String
    public let exactMLXRevision: String
    public let parameterPathSchema: String
    public let requiredTensorDType: String
    public let tiedOutputProjection: Bool
    public let configuration: PrimeNativeDecoderConfigurationSnapshotV1
    public let tokenIdentity: PrimeNativeDecoderTokenIdentityV1
    public let parameterCatalog: [PrimeNativeDecoderParameterDescriptorV1]
    public let parameterCatalogSHA256: String
    public let totalParameterCount: UInt64
    public let totalParameterByteCount: UInt64
    public let maximumCheckpointByteCount: UInt64

    /// Returns the exact declarative Native-300M/byte-512 checkpoint
    /// compatibility identity. It does not allocate a model, validate
    /// tokenizer behavior, establish runtime readiness, or admit checkpoint
    /// bytes.
    public static func native300MByte512() throws -> Self {
        try make(
            identityScope:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .publicCheckpointCompatibilityProfile,
            configuration: .native300MInventory(
                vocabularySize:
                    PrimeNativeByteTokenizer.boundModelVocabularySize),
            tokenIdentity: .nativeByte512())
    }

    static func analyticParameterCatalog(
        for configuration: PrimeNativeGQADecoderConfiguration
    ) throws -> [PrimeNativeDecoderParameterDescriptorV1] {
        var result = [PrimeNativeDecoderParameterDescriptorV1]()
        var paths = Set<String>()

        func append(_ path: String, _ shape: [Int]) throws {
            guard paths.insert(path).inserted else {
                throw PrimeNativeDecoderCheckpointError
                    .duplicateParameterPath(path)
            }
            let elementCount = try checkedElementCount(shape)
            let byteCount = elementCount.multipliedReportingOverflow(by: 4)
            guard !byteCount.overflow else {
                throw PrimeNativeDecoderCheckpointError
                    .checkpointSizeOverflow
            }
            result.append(
                PrimeNativeDecoderParameterDescriptorV1(
                    path: path,
                    shape: shape,
                    dtype: "float32",
                    elementCount: elementCount,
                    byteCount: byteCount.partialValue))
        }

        let width = configuration.modelWidth
        let keyValueWidth = configuration.keyValueProjectionWidth
        let intermediate = configuration.intermediateWidth
        try append(
            "token_embedding.weight",
            [configuration.vocabularySize, width])
        for index in 0 ..< configuration.layerCount {
            let prefix = "layers.\(index)"
            try append("\(prefix).attention_norm.weight", [width])
            try append(
                "\(prefix).attention.query_projection.weight",
                [width, width])
            try append(
                "\(prefix).attention.key_projection.weight",
                [keyValueWidth, width])
            try append(
                "\(prefix).attention.value_projection.weight",
                [keyValueWidth, width])
            try append(
                "\(prefix).attention.output_projection.weight",
                [width, width])
            try append("\(prefix).feed_forward_norm.weight", [width])
            try append(
                "\(prefix).feed_forward.gate_projection.weight",
                [intermediate, width])
            try append(
                "\(prefix).feed_forward.up_projection.weight",
                [intermediate, width])
            try append(
                "\(prefix).feed_forward.down_projection.weight",
                [width, intermediate])
        }
        try append("final_norm.weight", [width])
        return result.sorted { $0.path < $1.path }
    }

    static func synthetic(
        configuration: PrimeNativeGQADecoderConfiguration
    ) throws -> Self {
        let expectedConfiguration = try exactSyntheticConfiguration()
        guard configuration == expectedConfiguration else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }
        return try make(
            identityScope: "synthetic_checkpoint_test_only",
            configuration: configuration,
            tokenIdentity: .synthetic(
                vocabularySize: configuration.vocabularySize))
    }

    /// Validates only the declarative checkpoint compatibility projection. A
    /// successful result is not checkpoint provenance, admission, or runtime
    /// authorization.
    public func validate() throws {
        try validate(allowSynthetic: false)
    }

    func validate(allowSynthetic: Bool) throws {
        let authority = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
        do {
            try authority.validate()
        } catch {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }

        if !allowSynthetic
            || identityScope
                == authority.publicCheckpointCompatibilityProfile
        {
            guard identityScope
                    == authority.publicCheckpointCompatibilityProfile
            else {
                throw PrimeNativeDecoderCheckpointError
                    .invalidCompatibilityIdentity
            }
            let expected = try Self.native300MByte512()
            guard self == expected else {
                throw PrimeNativeDecoderCheckpointError
                    .invalidCompatibilityIdentity
            }
            return
        }

        guard identityScope == "synthetic_checkpoint_test_only" else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }
        let decodedConfiguration: PrimeNativeGQADecoderConfiguration
        do {
            decodedConfiguration = try configuration.configuration()
        } catch {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }
        let expectedSyntheticConfiguration = try Self
            .exactSyntheticConfiguration()
        guard decodedConfiguration == expectedSyntheticConfiguration else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }
        let expectedCatalog = try Self.analyticParameterCatalog(
            for: decodedConfiguration)
        let expectedCatalogSHA256 = PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(expectedCatalog))
        let expectedElementCount = try Self.sum(
            expectedCatalog.map(\.elementCount))
        let expectedByteCount = try Self.sum(
            expectedCatalog.map(\.byteCount))
        let expectedMaximum = try Self.maximumCheckpointBytes(
            parameterBytes: expectedByteCount)

        guard schemaVersion == 1,
              schemaID == authority.compatibilityIdentitySchema,
              authorityID == authority.authorityID,
              architectureSchema
                == PrimeNativeGQADecoderConfiguration.architectureSchema,
              implementationID
                == PrimeNativeGQADecoderConfiguration.implementationID,
              decoderSourceSHA256 == authority.decoderSourceSHA256,
              exactMLXRevision == authority.exactMLXRevision,
              parameterPathSchema == authority.parameterPathSchema,
              requiredTensorDType == authority.tensorDType,
              tiedOutputProjection,
              tokenIdentity.vocabularySize
                == decodedConfiguration.vocabularySize,
              parameterCatalog == expectedCatalog,
              parameterCatalogSHA256 == expectedCatalogSHA256,
              totalParameterCount == expectedElementCount,
              totalParameterCount
                == UInt64(decodedConfiguration.uniqueParameterCount),
              totalParameterByteCount == expectedByteCount,
              maximumCheckpointByteCount == expectedMaximum
        else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }

        try tokenIdentity.validateSynthetic(
            expectedVocabularySize:
                decodedConfiguration.vocabularySize)
    }

    private static func make(
        identityScope: String,
        configuration: PrimeNativeGQADecoderConfiguration,
        tokenIdentity: PrimeNativeDecoderTokenIdentityV1
    ) throws -> Self {
        try PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1.validate()
        let catalog = try analyticParameterCatalog(for: configuration)
        let totalCount = try sum(catalog.map(\.elementCount))
        let totalBytes = try sum(catalog.map(\.byteCount))
        return Self(
            schemaVersion: 1,
            schemaID:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .compatibilityIdentitySchema,
            identityScope: identityScope,
            authorityID:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .authorityID,
            architectureSchema:
                PrimeNativeGQADecoderConfiguration.architectureSchema,
            implementationID:
                PrimeNativeGQADecoderConfiguration.implementationID,
            decoderSourceSHA256:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .decoderSourceSHA256,
            exactMLXRevision:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .exactMLXRevision,
            parameterPathSchema:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .parameterPathSchema,
            requiredTensorDType: "float32",
            tiedOutputProjection: true,
            configuration:
                PrimeNativeDecoderConfigurationSnapshotV1(configuration),
            tokenIdentity: tokenIdentity,
            parameterCatalog: catalog,
            parameterCatalogSHA256: PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(catalog)),
            totalParameterCount: totalCount,
            totalParameterByteCount: totalBytes,
            maximumCheckpointByteCount: try maximumCheckpointBytes(
                parameterBytes: totalBytes))
    }

    private static func exactSyntheticConfiguration()
        throws -> PrimeNativeGQADecoderConfiguration
    {
        try PrimeNativeGQADecoderConfiguration(
            vocabularySize: 32,
            modelWidth: 16,
            layerCount: 2,
            queryHeadCount: 4,
            keyValueHeadCount: 2,
            headWidth: 4,
            intermediateWidth: 32,
            maximumSequenceLength: 16)
    }

    private static func checkedElementCount(
        _ shape: [Int]
    ) throws -> UInt64 {
        guard !shape.isEmpty else {
            throw PrimeNativeDecoderCheckpointError.contractDrift
        }
        var result: UInt64 = 1
        for dimension in shape {
            guard dimension > 0 else {
                throw PrimeNativeDecoderCheckpointError.contractDrift
            }
            let multiplied = result.multipliedReportingOverflow(
                by: UInt64(dimension))
            guard !multiplied.overflow else {
                throw PrimeNativeDecoderCheckpointError
                    .checkpointSizeOverflow
            }
            result = multiplied.partialValue
        }
        return result
    }

    private static func sum(
        _ values: [UInt64]
    ) throws -> UInt64 {
        var result: UInt64 = 0
        for value in values {
            let added = result.addingReportingOverflow(value)
            guard !added.overflow else {
                throw PrimeNativeDecoderCheckpointError
                    .checkpointSizeOverflow
            }
            result = added.partialValue
        }
        return result
    }

    private static func maximumCheckpointBytes(
        parameterBytes: UInt64
    ) throws -> UInt64 {
        let overhead: UInt64 = 16 * 1024 * 1024
        let result = parameterBytes.addingReportingOverflow(overhead)
        guard !result.overflow else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointSizeOverflow
        }
        return result.partialValue
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case identityScope = "identity_scope"
        case authorityID = "authority_id"
        case architectureSchema = "architecture_schema"
        case implementationID = "implementation_id"
        case decoderSourceSHA256 = "decoder_source_sha256"
        case exactMLXRevision = "exact_mlx_revision"
        case parameterPathSchema = "parameter_path_schema"
        case requiredTensorDType = "required_tensor_dtype"
        case tiedOutputProjection = "tied_output_projection"
        case configuration
        case tokenIdentity = "token_identity"
        case parameterCatalog = "parameter_catalog"
        case parameterCatalogSHA256 = "parameter_catalog_sha256"
        case totalParameterCount = "total_parameter_count"
        case totalParameterByteCount = "total_parameter_byte_count"
        case maximumCheckpointByteCount = "maximum_checkpoint_byte_count"
    }
}

public struct PrimeNativeDecoderCheckpointTensorBindingV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let logicalSHA256: String
    public let allValuesFinite: Bool

    private enum CodingKeys: String, CodingKey {
        case path
        case logicalSHA256 = "logical_sha256"
        case allValuesFinite = "all_values_finite"
    }
}

public struct PrimeNativeDecoderCheckpointManifestV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let artifactKind: String
    public let checkpointFormat: String
    public let stateScope: String
    public let compatibilityIdentity:
        PrimeNativeDecoderCompatibilityIdentityV1
    public let tensorBindings:
        [PrimeNativeDecoderCheckpointTensorBindingV1]
    public let tensorBindingsSHA256: String
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let kvCacheStateIncluded: Bool

    /// Validates a weights-only manifest projection. It does not prove that a
    /// retained artifact exists, establish its provenance, or authorize its
    /// use by a runtime or trial.
    public func validate() throws {
        try validate(allowSynthetic: false)
    }

    func validate(allowSynthetic: Bool) throws {
        let authority = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
        try compatibilityIdentity.validate(
            allowSynthetic: allowSynthetic)
        let expectedPaths = compatibilityIdentity.parameterCatalog.map(\.path)
        let observedPaths = tensorBindings.map(\.path)
        guard schemaVersion == 1,
              schemaID == authority.checkpointSchema,
              artifactKind == authority.checkpointArtifactKind,
              checkpointFormat == authority.checkpointFormat,
              stateScope == authority.stateScope,
              observedPaths == expectedPaths,
              Set(observedPaths).count == observedPaths.count,
              tensorBindings.allSatisfy({
                  $0.logicalSHA256.utf8.count == 64
                      && $0.logicalSHA256.utf8.allSatisfy(isLowercaseHex)
                      && $0.allValuesFinite
              }),
              tensorBindingsSHA256 == PrimeSHA256.hexDigest(
                  of: try PrimeCanonicalJSON.encode(tensorBindings)),
              !optimizerStateIncluded,
              !rngStateIncluded,
              !dataCursorIncluded,
              !kvCacheStateIncluded
        else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCheckpointManifest
        }
    }

    static func make(
        compatibilityIdentity: PrimeNativeDecoderCompatibilityIdentityV1,
        tensorBindings: [PrimeNativeDecoderCheckpointTensorBindingV1],
        allowSynthetic: Bool
    ) throws -> Self {
        let result = Self(
            schemaVersion: 1,
            schemaID:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .checkpointSchema,
            artifactKind:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .checkpointArtifactKind,
            checkpointFormat:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .checkpointFormat,
            stateScope:
                PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                    .stateScope,
            compatibilityIdentity: compatibilityIdentity,
            tensorBindings: tensorBindings,
            tensorBindingsSHA256: PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(tensorBindings)),
            optimizerStateIncluded: false,
            rngStateIncluded: false,
            dataCursorIncluded: false,
            kvCacheStateIncluded: false)
        try result.validate(allowSynthetic: allowSynthetic)
        return result
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case artifactKind = "artifact_kind"
        case checkpointFormat = "checkpoint_format"
        case stateScope = "state_scope"
        case compatibilityIdentity = "compatibility_identity"
        case tensorBindings = "tensor_bindings"
        case tensorBindingsSHA256 = "tensor_bindings_sha256"
        case optimizerStateIncluded = "optimizer_state_included"
        case rngStateIncluded = "rng_state_included"
        case dataCursorIncluded = "data_cursor_included"
        case kvCacheStateIncluded = "kv_cache_state_included"
    }
}

public enum PrimeNativeDecoderCheckpointCodecV1 {
    public static let manifestMetadataKey =
        "ergentics_prime_native_decoder_checkpoint_manifest_v1"
    public static let manifestSHA256MetadataKey =
        "ergentics_prime_native_decoder_checkpoint_manifest_sha256_v1"

    // Executable descriptor mechanics remain internal and synthetic-only in
    // this authority slice. Public native-300M load/write requires a later,
    // explicit authority successor. Pinned MLX truncates the borrowed file
    // before writing; failure does not preserve prior contents, publish
    // atomically, fsync, or establish recovery/durability.
    static func writeSynthetic(
        model: PrimeNativeGQADecoder,
        identity: PrimeNativeDecoderCompatibilityIdentityV1,
        fileDescriptor: Int32
    ) throws -> PrimeNativeDecoderCheckpointManifestV1 {
        try write(
            model: model,
            identity: identity,
            fileDescriptor: fileDescriptor,
            allowSynthetic: true)
    }

    static func loadSynthetic(
        expectedManifest: PrimeNativeDecoderCheckpointManifestV1,
        fileDescriptor: Int32
    ) throws -> PrimeNativeGQADecoder {
        try load(
            expectedManifest: expectedManifest,
            fileDescriptor: fileDescriptor,
            allowSynthetic: true)
    }

    static func syntheticManifest(
        identity: PrimeNativeDecoderCompatibilityIdentityV1
    ) throws -> PrimeNativeDecoderCheckpointManifestV1 {
        let bindings = identity.parameterCatalog.map {
            PrimeNativeDecoderCheckpointTensorBindingV1(
                path: $0.path,
                logicalSHA256: PrimeSHA256.hexDigest(
                    of: Data("synthetic_binding_\($0.path)".utf8)),
                allValuesFinite: true)
        }
        return try .make(
            compatibilityIdentity: identity,
            tensorBindings: bindings,
            allowSynthetic: true)
    }

    private static func write(
        model: PrimeNativeGQADecoder,
        identity: PrimeNativeDecoderCompatibilityIdentityV1,
        fileDescriptor: Int32,
        allowSynthetic: Bool
    ) throws -> PrimeNativeDecoderCheckpointManifestV1 {
        try preflightWriteDescriptor(fileDescriptor)
        try identity.validate(allowSynthetic: allowSynthetic)
        guard PrimeNativeDecoderConfigurationSnapshotV1(model.configuration)
                == identity.configuration
        else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }
        let arrays = try uniqueParameters(model)
        let bindings = try inspect(
            arrays: arrays,
            identity: identity)
        let manifest = try PrimeNativeDecoderCheckpointManifestV1.make(
            compatibilityIdentity: identity,
            tensorBindings: bindings,
            allowSynthetic: allowSynthetic)
        let manifestData = try PrimeCanonicalJSON.encode(manifest)
        guard let manifestText = String(
            data: manifestData,
            encoding: .utf8)
        else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCheckpointManifest
        }
        let metadata = [
            manifestMetadataKey: manifestText,
            manifestSHA256MetadataKey:
                PrimeSHA256.hexDigest(of: manifestData),
        ]
        do {
            try MLX.save(
                arrays: arrays,
                metadata: metadata,
                fileDescriptor: fileDescriptor,
                maximumBytes: identity.maximumCheckpointByteCount)
        } catch {
            throw PrimeNativeDecoderCheckpointError
                .checkpointWriteFailed
        }
        let afterWrite = try inspect(
            arrays: try uniqueParameters(model),
            identity: identity)
        guard afterWrite == bindings else {
            throw PrimeNativeDecoderCheckpointError.contractDrift
        }
        return manifest
    }

    private static func load(
        expectedManifest: PrimeNativeDecoderCheckpointManifestV1,
        fileDescriptor: Int32,
        allowSynthetic: Bool
    ) throws -> PrimeNativeGQADecoder {
        try expectedManifest.validate(
            allowSynthetic: allowSynthetic)
        try preflightDescriptorSize(
            fileDescriptor,
            maximumBytes: expectedManifest.compatibilityIdentity
                .maximumCheckpointByteCount)
        let arrays: [String: MLXArray]
        let metadata: [String: String]
        do {
            (arrays, metadata) = try MLX.loadArraysAndMetadata(
                fileDescriptor: fileDescriptor,
                stream: .cpu)
        } catch {
            throw PrimeNativeDecoderCheckpointError
                .checkpointReadFailed
        }
        let embeddedManifest = try decodeManifest(
            metadata,
            expectedManifest: expectedManifest)
        guard embeddedManifest == expectedManifest else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointMetadataMismatch
        }
        try embeddedManifest.validate(
            allowSynthetic: allowSynthetic)
        let bindings = try inspect(
            arrays: arrays,
            identity: embeddedManifest.compatibilityIdentity)
        guard bindings == embeddedManifest.tensorBindings else {
            throw PrimeNativeDecoderCheckpointError
                .parameterLogicalHashMismatch("<catalog>")
        }

        // Unflatten only after the exact known path set has passed preflight.
        let configuration = try embeddedManifest
            .compatibilityIdentity.configuration.configuration()
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration)
        let parameters = ModuleParameters.unflattened(
            arrays.map { ($0.key, $0.value) })
        do {
            try model.update(parameters: parameters, verify: .all)
            try checkedEval(model.parameters().flattenedValues())
        } catch {
            throw PrimeNativeDecoderCheckpointError
                .checkpointRestoreFailed
        }
        let restored = try inspect(
            arrays: try uniqueParameters(model),
            identity: embeddedManifest.compatibilityIdentity)
        guard restored == embeddedManifest.tensorBindings else {
            throw PrimeNativeDecoderCheckpointError
                .parameterLogicalHashMismatch("<restored_catalog>")
        }
        return model
    }

    private static func decodeManifest(
        _ metadata: [String: String],
        expectedManifest: PrimeNativeDecoderCheckpointManifestV1
    ) throws -> PrimeNativeDecoderCheckpointManifestV1 {
        let expectedData = try PrimeCanonicalJSON.encode(expectedManifest)
        guard let expectedText = String(
            data: expectedData,
            encoding: .utf8)
        else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointMetadataMismatch
        }
        guard Set(metadata.keys) == Set([
            manifestMetadataKey,
            manifestSHA256MetadataKey,
        ]),
        let text = metadata[manifestMetadataKey],
        text == expectedText,
        let data = text.data(using: .utf8),
        data == expectedData,
        metadata[manifestSHA256MetadataKey]
            == PrimeSHA256.hexDigest(of: data)
        else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointMetadataMismatch
        }
        do {
            return try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderCheckpointManifestV1.self,
                from: data,
                artifact: "<checkpoint_metadata>")
        } catch {
            throw PrimeNativeDecoderCheckpointError
                .checkpointMetadataMismatch
        }
    }

    private static func preflightDescriptorSize(
        _ fileDescriptor: Int32,
        maximumBytes: UInt64
    ) throws {
        guard fileDescriptor >= 0 else {
            throw PrimeNativeDecoderCheckpointError
                .invalidFileDescriptor(fileDescriptor)
        }
        var metadata = stat()
        guard fstat(fileDescriptor, &metadata) == 0,
              metadata.st_size >= 0
        else {
            throw PrimeNativeDecoderCheckpointError
                .invalidFileDescriptor(fileDescriptor)
        }
        guard (metadata.st_mode & S_IFMT) == S_IFREG else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointDescriptorNotRegular
        }
        let flags = fcntl(fileDescriptor, F_GETFL)
        guard flags >= 0 else {
            throw PrimeNativeDecoderCheckpointError
                .invalidFileDescriptor(fileDescriptor)
        }
        guard flags & O_ACCMODE != O_WRONLY else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointDescriptorNotReadable
        }
        let observed = UInt64(metadata.st_size)
        guard observed <= maximumBytes else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointFileTooLarge(
                    observed: observed,
                    maximum: maximumBytes)
        }
    }

    private static func preflightWriteDescriptor(
        _ fileDescriptor: Int32
    ) throws {
        guard fileDescriptor >= 0 else {
            throw PrimeNativeDecoderCheckpointError
                .invalidFileDescriptor(fileDescriptor)
        }
        var metadata = stat()
        guard fstat(fileDescriptor, &metadata) == 0 else {
            throw PrimeNativeDecoderCheckpointError
                .invalidFileDescriptor(fileDescriptor)
        }
        guard (metadata.st_mode & S_IFMT) == S_IFREG else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointDescriptorNotRegular
        }
        let flags = fcntl(fileDescriptor, F_GETFL)
        guard flags >= 0 else {
            throw PrimeNativeDecoderCheckpointError
                .invalidFileDescriptor(fileDescriptor)
        }
        guard flags & O_ACCMODE != O_RDONLY else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointDescriptorNotWritable
        }
        guard flags & O_APPEND == 0 else {
            throw PrimeNativeDecoderCheckpointError
                .checkpointDescriptorAppendModeForbidden
        }
    }

    private static func uniqueParameters(
        _ model: PrimeNativeGQADecoder
    ) throws -> [String: MLXArray] {
        var result = [String: MLXArray]()
        for (path, array) in model.parameters().flattened() {
            guard result.updateValue(array, forKey: path) == nil else {
                throw PrimeNativeDecoderCheckpointError
                    .duplicateParameterPath(path)
            }
        }
        return result
    }

    private static func inspect(
        arrays: [String: MLXArray],
        identity: PrimeNativeDecoderCompatibilityIdentityV1
    ) throws -> [PrimeNativeDecoderCheckpointTensorBindingV1] {
        let expectedPaths = identity.parameterCatalog.map(\.path)
        guard Set(arrays.keys) == Set(expectedPaths),
              arrays.count == expectedPaths.count
        else {
            throw PrimeNativeDecoderCheckpointError
                .parameterPathSetMismatch
        }

        var result = [PrimeNativeDecoderCheckpointTensorBindingV1]()
        result.reserveCapacity(expectedPaths.count)
        for descriptor in identity.parameterCatalog {
            guard let array = arrays[descriptor.path] else {
                throw PrimeNativeDecoderCheckpointError
                    .parameterPathSetMismatch
            }
            guard array.shape == descriptor.shape else {
                throw PrimeNativeDecoderCheckpointError
                    .parameterShapeMismatch(descriptor.path)
            }
            guard array.dtype == .float32,
                  descriptor.dtype == "float32" else {
                throw PrimeNativeDecoderCheckpointError
                    .parameterDTypeMismatch(descriptor.path)
            }
            guard UInt64(array.size) == descriptor.elementCount else {
                throw PrimeNativeDecoderCheckpointError
                    .parameterByteCountMismatch(descriptor.path)
            }
            try checkedEval(array)
            let logical = array.asData(access: .copy)
            guard logical.shape == descriptor.shape,
                  logical.dType == .float32,
                  UInt64(logical.data.count) == descriptor.byteCount
            else {
                throw PrimeNativeDecoderCheckpointError
                    .parameterByteCountMismatch(descriptor.path)
            }
            let canonicalLogicalData: Data
            do {
                canonicalLogicalData = try canonicalLogicalFloat32Data(
                    logical.data)
            } catch {
                throw PrimeNativeDecoderCheckpointError
                    .parameterContainsNonFiniteValue(descriptor.path)
            }
            result.append(
                PrimeNativeDecoderCheckpointTensorBindingV1(
                    path: descriptor.path,
                    logicalSHA256:
                        PrimeSHA256.hexDigest(
                            of: canonicalLogicalData),
                    allValuesFinite: true))
        }
        return result
    }
}

func canonicalLogicalFloat32Data(_ data: Data) throws -> Data {
    guard data.count.isMultiple(of: MemoryLayout<UInt32>.size) else {
        throw PrimeNativeDecoderCheckpointError.contractDrift
    }
    var canonical = Data()
    canonical.reserveCapacity(data.count)
    try data.withUnsafeBytes { bytes in
        for offset in stride(
            from: 0,
            to: bytes.count,
            by: MemoryLayout<UInt32>.size
        ) {
            let bits = bytes.loadUnaligned(
                fromByteOffset: offset,
                as: UInt32.self)
            guard Float(bitPattern: bits).isFinite else {
                throw PrimeNativeDecoderCheckpointError.contractDrift
            }
            var littleEndianBits = bits.littleEndian
            Swift.withUnsafeBytes(of: &littleEndianBits) {
                canonical.append(contentsOf: $0)
            }
        }
    }
    return canonical
}

private func isLowercaseHex(_ byte: UInt8) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
