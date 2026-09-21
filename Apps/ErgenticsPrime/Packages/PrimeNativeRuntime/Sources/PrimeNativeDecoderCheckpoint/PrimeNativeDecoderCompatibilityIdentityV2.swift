// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore

/// The exact declarative checkpoint compatibility identity for the repaired
/// Native-300M decoder source.
///
/// This value reuses the validated V1 configuration, tokenizer identity, and
/// ordered parameter catalog. It does not define a V2 checkpoint manifest or
/// codec, allocate a model, perform checkpoint I/O, validate tokenizer/model
/// behavior, establish a runtime, or admit checkpoint bytes.
public struct PrimeNativeDecoderCompatibilityIdentityV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let identityScope: String
    public let authorityID: String
    public let predecessorCompatibilityIdentitySHA256: String
    public let repairAuthorityID: String
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

    /// Returns only the repaired decoder's declarative Native-300M/byte-512
    /// compatibility identity. No model, checkpoint container, or runtime is
    /// created by this factory.
    public static func native300MByte512() throws -> Self {
        try makeNative300MByte512()
    }

    /// Validates the exact declarative V2 identity. Successful validation is
    /// not checkpoint artifact compatibility, provenance, admission, runtime
    /// readiness, or training authority.
    public func validate() throws {
        let expected = try Self.makeNative300MByte512()
        guard self == expected else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }
    }

    private static func makeNative300MByte512() throws -> Self {
        let authority =
            PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan.frozenV2
        do {
            try authority.validateExactV2()
        } catch {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }

        let predecessor = try PrimeNativeDecoderCompatibilityIdentityV1
            .native300MByte512()
        try predecessor.validate()
        let predecessorBytes = try PrimeCanonicalJSON.encode(predecessor)
        let parameterCatalogBytes = try PrimeCanonicalJSON.encode(
            predecessor.parameterCatalog)

        guard predecessor.schemaVersion == 1,
              predecessor.schemaID
                == authority.historicalV1CompatibilityIdentitySchema,
              predecessor.identityScope
                == authority.historicalV1CompatibilityProfile,
              predecessor.decoderSourceSHA256
                == authority.historicalV1DecoderSourceSHA256,
              predecessorBytes.count
                == authority.historicalV1CanonicalIdentityByteCount,
              PrimeSHA256.hexDigest(of: predecessorBytes)
                == authority.historicalV1CanonicalIdentitySHA256,
              predecessor.architectureSchema == authority.architectureSchema,
              predecessor.implementationID == authority.implementationID,
              predecessor.exactMLXRevision == authority.exactMLXRevision,
              predecessor.parameterPathSchema == authority.parameterPathSchema,
              predecessor.requiredTensorDType
                == authority.requiredTensorDType,
              predecessor.tiedOutputProjection
                == authority.tiedOutputProjection,
              predecessor.configuration.vocabularySize
                == authority.vocabularySize,
              predecessor.configuration.modelWidth == authority.modelWidth,
              predecessor.configuration.layerCount == authority.layerCount,
              predecessor.configuration.queryHeadCount
                == authority.queryHeadCount,
              predecessor.configuration.keyValueHeadCount
                == authority.keyValueHeadCount,
              predecessor.configuration.headWidth == authority.headWidth,
              predecessor.configuration.intermediateWidth
                == authority.intermediateWidth,
              predecessor.configuration.maximumSequenceLength
                == authority.maximumSequenceLength,
              predecessor.configuration.ropeThetaBitPattern
                == authority.ropeThetaFloat32BitPattern,
              predecessor.configuration.rmsNormEpsilonBitPattern
                == authority.rmsNormEpsilonFloat32BitPattern,
              predecessor.tokenIdentity.tokenizerID == authority.tokenizerID,
              predecessor.tokenIdentity.tokenizerManifestSHA256
                == authority.tokenizerManifestSHA256,
              predecessor.tokenIdentity.vocabularySize
                == authority.tokenizerVocabularySize,
              predecessor.parameterCatalog.count
                == authority.parameterDescriptorCount,
              parameterCatalogBytes.count
                == authority.parameterCatalogCanonicalByteCount,
              predecessor.parameterCatalogSHA256
                == authority.parameterCatalogSHA256,
              PrimeSHA256.hexDigest(of: parameterCatalogBytes)
                == authority.parameterCatalogSHA256,
              predecessor.totalParameterCount
                == authority.totalParameterCount,
              predecessor.totalParameterByteCount
                == authority.totalParameterByteCount,
              predecessor.maximumCheckpointByteCount
                == authority.maximumCheckpointByteCount
        else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }

        let result = Self(
            schemaVersion: authority.schemaVersion,
            schemaID: authority.compatibilityIdentitySchema,
            identityScope: authority.publicCompatibilityProfile,
            authorityID: authority.authorityID,
            predecessorCompatibilityIdentitySHA256:
                authority.historicalV1CanonicalIdentitySHA256,
            repairAuthorityID: authority.repairAuthorityID,
            architectureSchema: predecessor.architectureSchema,
            implementationID: predecessor.implementationID,
            decoderSourceSHA256: authority.repairedDecoderSourceSHA256,
            exactMLXRevision: predecessor.exactMLXRevision,
            parameterPathSchema: predecessor.parameterPathSchema,
            requiredTensorDType: predecessor.requiredTensorDType,
            tiedOutputProjection: predecessor.tiedOutputProjection,
            configuration: predecessor.configuration,
            tokenIdentity: predecessor.tokenIdentity,
            parameterCatalog: predecessor.parameterCatalog,
            parameterCatalogSHA256: predecessor.parameterCatalogSHA256,
            totalParameterCount: predecessor.totalParameterCount,
            totalParameterByteCount: predecessor.totalParameterByteCount,
            maximumCheckpointByteCount:
                predecessor.maximumCheckpointByteCount)
        let canonicalBytes = try PrimeCanonicalJSON.encode(result)
        guard canonicalBytes.count
                == authority.publicV2CanonicalIdentityByteCount,
              PrimeSHA256.hexDigest(of: canonicalBytes)
                == authority.publicV2CanonicalIdentitySHA256
        else {
            throw PrimeNativeDecoderCheckpointError
                .invalidCompatibilityIdentity
        }
        return result
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case identityScope = "identity_scope"
        case authorityID = "authority_id"
        case predecessorCompatibilityIdentitySHA256 =
            "predecessor_compatibility_identity_sha256"
        case repairAuthorityID = "repair_authority_id"
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
