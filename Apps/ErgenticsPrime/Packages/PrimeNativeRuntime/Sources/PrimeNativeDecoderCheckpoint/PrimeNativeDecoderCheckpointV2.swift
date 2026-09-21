// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import Foundation
import MLX
import MLXNN
import PrimeCore
import PrimeNativeDecoder

private let maximumV2ManifestByteCount: UInt64 = 16 * 1024 * 1024
private let maximumV2SafetensorsHeaderByteCount: UInt64 =
    16 * 1024 * 1024

/// Stable failures from the V2 checkpoint container boundary.
///
/// The public codec deliberately does not expose descriptor, path-reopening,
/// or MLX serialization errors. Callers receive this bounded error vocabulary
/// while `PrimeArtifactRoot` retains the filesystem capability.
public enum PrimeNativeDecoderCheckpointV2Error:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case invalidManifest
    case invalidExternalBinding
    case modelConfigurationMismatch
    case descriptorRejected
    case invalidCheckpointSize(observed: UInt64)
    case checkpointFileTooLarge(observed: UInt64, maximum: UInt64)
    case invalidSafetensorsHeader
    case invalidSafetensorsLayout
    case destinationConflict
    case containerHashMismatch
    case containerByteCountMismatch
    case concurrentMutation
    case durabilityOrPublicationFailure
    case artifactVerificationFailed
    case checkpointWriteFailed
    case checkpointReadFailed
    case checkpointRestoreFailed
    case duplicateParameterPath(String)
    case parameterPathSetMismatch
    case parameterShapeMismatch(String)
    case parameterDTypeMismatch(String)
    case parameterByteCountMismatch(String)
    case parameterContainsNonFiniteValue(String)
    case parameterLogicalHashMismatch(String)
    case checkpointMetadataMismatch
}

public struct PrimeNativeDecoderCheckpointTensorBindingV2:
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

/// Canonical, weights-only metadata embedded in an exact V2 safetensors
/// container.
///
/// The manifest binds logical tensors and the declarative V2 compatibility
/// identity. It intentionally does not contain the SHA-256 of its own
/// container; that self-referential value is carried out-of-band by
/// `PrimeNativeDecoderCheckpointExternalBindingV2`.
public struct PrimeNativeDecoderCheckpointManifestV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let artifactKind: String
    public let checkpointFormat: String
    public let stateScope: String
    public let logicalTensorHashAlgorithm: String
    public let logicalTensorByteEncoding: String
    public let compatibilityIdentity:
        PrimeNativeDecoderCompatibilityIdentityV2
    public let tensorBindings:
        [PrimeNativeDecoderCheckpointTensorBindingV2]
    public let tensorBindingsSHA256: String
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let kvCacheStateIncluded: Bool

    /// Validates the exact Native-300M/byte-512 V2 manifest projection. This
    /// does not locate, hash, admit, or authorize a checkpoint artifact.
    public func validate() throws {
        try validateExactNative300MByte512()
    }

    fileprivate static func makeNative300MByte512(
        identity: PrimeNativeDecoderCompatibilityIdentityV2,
        tensorBindings: [PrimeNativeDecoderCheckpointTensorBindingV2]
    ) throws -> Self {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1
        let tensorBindingBytes: Data
        do {
            tensorBindingBytes = try PrimeCanonicalJSON.encode(
                tensorBindings)
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.invalidManifest
        }
        let result = Self(
            schemaVersion: authority.manifestSchemaVersion,
            schemaID: authority.manifestSchemaID,
            artifactKind: authority.checkpointArtifactKind,
            checkpointFormat: authority.checkpointFormat,
            stateScope: authority.stateScope,
            logicalTensorHashAlgorithm:
                authority.logicalTensorHashAlgorithm,
            logicalTensorByteEncoding:
                authority.logicalTensorByteEncoding,
            compatibilityIdentity: identity,
            tensorBindings: tensorBindings,
            tensorBindingsSHA256:
                PrimeSHA256.hexDigest(of: tensorBindingBytes),
            optimizerStateIncluded: false,
            rngStateIncluded: false,
            dataCursorIncluded: false,
            kvCacheStateIncluded: false)
        try result.validateExactNative300MByte512()
        return result
    }

    fileprivate func validateExactNative300MByte512() throws {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1
        let expectedIdentity: PrimeNativeDecoderCompatibilityIdentityV2
        do {
            try authority.validateExactV1()
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.contractDrift
        }
        do {
            expectedIdentity = try .native300MByte512()
            try compatibilityIdentity.validate()
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.invalidManifest
        }
        let expectedPaths = expectedIdentity.parameterCatalog.map(\.path)
        let observedPaths = tensorBindings.map(\.path)
        let tensorBindingBytes: Data
        let manifestBytes: Data
        do {
            tensorBindingBytes = try PrimeCanonicalJSON.encode(
                tensorBindings)
            manifestBytes = try PrimeCanonicalJSON.encode(self)
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.invalidManifest
        }
        guard schemaVersion == authority.manifestSchemaVersion,
              schemaID == authority.manifestSchemaID,
              artifactKind == authority.checkpointArtifactKind,
              checkpointFormat == authority.checkpointFormat,
              stateScope == authority.stateScope,
              logicalTensorHashAlgorithm
                == authority.logicalTensorHashAlgorithm,
              logicalTensorByteEncoding
                == authority.logicalTensorByteEncoding,
              compatibilityIdentity == expectedIdentity,
              observedPaths == expectedPaths,
              Set(observedPaths).count == observedPaths.count,
              tensorBindings.allSatisfy({ binding in
                  binding.logicalSHA256.utf8.count == 64
                      && binding.logicalSHA256.utf8.allSatisfy(
                          isV2LowercaseHex)
                      && binding.allValuesFinite
              }),
              tensorBindingsSHA256
                == PrimeSHA256.hexDigest(of: tensorBindingBytes),
              !manifestBytes.isEmpty,
              UInt64(manifestBytes.count)
                <= maximumV2ManifestByteCount,
              !optimizerStateIncluded,
              !rngStateIncluded,
              !dataCursorIncluded,
              !kvCacheStateIncluded
        else {
            throw PrimeNativeDecoderCheckpointV2Error.invalidManifest
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case artifactKind = "artifact_kind"
        case checkpointFormat = "checkpoint_format"
        case stateScope = "state_scope"
        case logicalTensorHashAlgorithm =
            "logical_tensor_hash_algorithm"
        case logicalTensorByteEncoding =
            "logical_tensor_byte_encoding"
        case compatibilityIdentity = "compatibility_identity"
        case tensorBindings = "tensor_bindings"
        case tensorBindingsSHA256 = "tensor_bindings_sha256"
        case optimizerStateIncluded = "optimizer_state_included"
        case rngStateIncluded = "rng_state_included"
        case dataCursorIncluded = "data_cursor_included"
        case kvCacheStateIncluded = "kv_cache_state_included"
    }
}

/// Out-of-band expectation required to consume a V2 checkpoint container.
///
/// `artifactBinding.sha256` is the whole-container hash. Keeping it outside
/// the embedded manifest avoids a self-hash and prevents container metadata
/// from supplying its own expected digest.
public struct PrimeNativeDecoderCheckpointExternalBindingV2:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let manifest: PrimeNativeDecoderCheckpointManifestV2
    public let manifestCanonicalByteCount: UInt64
    public let manifestCanonicalSHA256: String
    public let artifactBinding: PrimeArtifactBinding

    public init(
        manifest: PrimeNativeDecoderCheckpointManifestV2,
        manifestCanonicalByteCount: UInt64,
        manifestCanonicalSHA256: String,
        artifactBinding: PrimeArtifactBinding
    ) {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1
        schemaVersion = authority.manifestSchemaVersion
        schemaID = authority.externalBindingSchema
        self.manifest = manifest
        self.manifestCanonicalByteCount = manifestCanonicalByteCount
        self.manifestCanonicalSHA256 = manifestCanonicalSHA256
        self.artifactBinding = artifactBinding
    }

    /// Validates the external expectation without opening the artifact. The
    /// codec additionally asks `PrimeArtifactRoot` to verify the bound file
    /// before and after complete MLX materialization.
    public func validate() throws {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1
        do {
            try authority.validateExactV1()
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.contractDrift
        }
        do {
            try manifest.validateExactNative300MByte512()
            let manifestBytes = try PrimeCanonicalJSON.encode(manifest)
            let pathComponents = artifactBinding.relativePath.split(
                separator: "/",
                omittingEmptySubsequences: false)
            guard schemaVersion == authority.manifestSchemaVersion,
                  schemaID == authority.externalBindingSchema,
                  manifestCanonicalByteCount
                    == UInt64(manifestBytes.count),
                  manifestCanonicalByteCount > 0,
                  manifestCanonicalByteCount
                    <= maximumV2ManifestByteCount,
                  manifestCanonicalSHA256
                    == PrimeSHA256.hexDigest(of: manifestBytes),
                  artifactBinding.purpose == .immutableData,
                  artifactBinding.byteCount
                    > manifest.compatibilityIdentity
                        .totalParameterByteCount,
                  artifactBinding.byteCount
                    <= manifest.compatibilityIdentity
                        .maximumCheckpointByteCount,
                  artifactBinding.sha256.utf8.count == 64,
                  artifactBinding.sha256.utf8.allSatisfy(
                      isV2LowercaseHex),
                  !artifactBinding.relativePath.isEmpty,
                  !artifactBinding.relativePath.hasPrefix("/"),
                  !artifactBinding.relativePath.utf8.contains(0),
                  !pathComponents.isEmpty,
                  pathComponents.allSatisfy({ component in
                      !component.isEmpty
                          && component != "."
                          && component != ".."
                          && component.utf8.count <= 255
                  })
            else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidExternalBinding
            }
        } catch let error as PrimeNativeDecoderCheckpointV2Error {
            throw error
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidExternalBinding
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case manifest
        case manifestCanonicalByteCount =
            "manifest_canonical_byte_count"
        case manifestCanonicalSHA256 = "manifest_canonical_sha256"
        case artifactBinding = "artifact_binding"
    }
}

/// Exact Native-300M/byte-512 V2 checkpoint container I/O.
///
/// Filesystem authority stays inside `PrimeArtifactRoot`. No public API
/// accepts a URL, file handle, or raw descriptor, and there is no
/// discover-and-trust or in-place mutation path.
public enum PrimeNativeDecoderCheckpointCodecV2 {
    public static let manifestMetadataKey =
        PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
            .frozenV1.manifestMetadataKey
    public static let manifestSHA256MetadataKey =
        PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
            .frozenV1.manifestSHA256MetadataKey

    /// Writes an exact V2 Native-300M/byte-512 weights-only checkpoint to a
    /// new immutable artifact. Before publication, the generated bytes are
    /// reloaded and fully materialized from the same hidden descriptor into a
    /// fresh decoder and reinspected against the exact manifest.
    public static func writeNative300MByte512(
        model: PrimeNativeGQADecoder,
        to root: PrimeArtifactRoot,
        at relativePath: String
    ) throws -> PrimeNativeDecoderCheckpointExternalBindingV2 {
        do {
            let authority =
                PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                    .frozenV1
            try authority.validateExactV1()
            guard authority
                    .native300MCheckpointWriteExecutionAuthorized
            else {
                throw PrimeNativeDecoderCheckpointV2Error.contractDrift
            }
            let identity = try PrimeNativeDecoderCompatibilityIdentityV2
                .native300MByte512()
            try identity.validate()
            guard PrimeNativeDecoderConfigurationSnapshotV1(
                model.configuration) == identity.configuration
            else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .modelConfigurationMismatch
            }

            let arrays = try uniqueParameters(model)
            let tensorBindings = try inspect(
                arrays: arrays,
                identity: identity)
            let manifest = try PrimeNativeDecoderCheckpointManifestV2
                .makeNative300MByte512(
                    identity: identity,
                    tensorBindings: tensorBindings)
            let manifestBytes: Data
            do {
                manifestBytes = try PrimeCanonicalJSON.encode(manifest)
            } catch {
                throw PrimeNativeDecoderCheckpointV2Error.invalidManifest
            }
            guard let manifestText = String(
                data: manifestBytes,
                encoding: .utf8),
                  !manifestBytes.isEmpty,
                  UInt64(manifestBytes.count)
                    <= maximumV2ManifestByteCount
            else {
                throw PrimeNativeDecoderCheckpointV2Error.invalidManifest
            }
            let metadata = [
                manifestMetadataKey: manifestText,
                manifestSHA256MetadataKey:
                    PrimeSHA256.hexDigest(of: manifestBytes),
            ]

            let artifactBinding: PrimeArtifactBinding
            do {
                artifactBinding = try root.publishGeneratedFile(
                    at: relativePath,
                    purpose: .immutableData,
                    maximumByteCount:
                        identity.maximumCheckpointByteCount
                ) { descriptor in
                    try preflightFreshWriteDescriptor(descriptor)
                    do {
                        try MLX.save(
                            arrays: arrays,
                            metadata: metadata,
                            fileDescriptor: descriptor,
                            maximumBytes:
                                identity.maximumCheckpointByteCount)
                    } catch {
                        throw PrimeNativeDecoderCheckpointV2Error
                            .checkpointWriteFailed
                    }
                    try preflightReadableDescriptor(
                        descriptor,
                        maximumBytes:
                            identity.maximumCheckpointByteCount)
                    guard lseek(descriptor, 0, SEEK_SET) >= 0 else {
                        throw PrimeNativeDecoderCheckpointV2Error
                            .descriptorRejected
                    }
                    _ = try loadAndMaterialize(
                        expectedManifest: manifest,
                        fileDescriptor: descriptor)
                    let afterWrite = try inspect(
                        arrays: try uniqueParameters(model),
                        identity: identity)
                    guard afterWrite == tensorBindings else {
                        throw PrimeNativeDecoderCheckpointV2Error
                            .contractDrift
                    }
                }
            } catch let error as PrimeNativeDecoderCheckpointV2Error {
                throw error
            } catch {
                throw mapPublicationError(error)
            }

            let result = PrimeNativeDecoderCheckpointExternalBindingV2(
                manifest: manifest,
                manifestCanonicalByteCount: UInt64(manifestBytes.count),
                manifestCanonicalSHA256:
                    PrimeSHA256.hexDigest(of: manifestBytes),
                artifactBinding: artifactBinding)
            try result.validate()
            return result
        } catch let error as PrimeNativeDecoderCheckpointV2Error {
            throw error
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.contractDrift
        }
    }

    /// Loads the exact externally bound artifact into a newly allocated
    /// decoder. `PrimeArtifactRoot` retains the verified descriptor through
    /// complete tensor evaluation, restore, and exact post-load reinspection.
    public static func loadNative300MByte512(
        expected: PrimeNativeDecoderCheckpointExternalBindingV2,
        from root: PrimeArtifactRoot
    ) throws -> PrimeNativeGQADecoder {
        do {
            let authority =
                PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                    .frozenV1
            try authority.validateExactV1()
            guard authority
                    .native300MCheckpointLoadExecutionAuthorized
            else {
                throw PrimeNativeDecoderCheckpointV2Error.contractDrift
            }
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.contractDrift
        }
        try expected.validate()
        do {
            return try root.withVerifiedArtifactDescriptor(
                expected.artifactBinding
            ) { descriptor in
                try preflightReadableDescriptor(
                    descriptor,
                    maximumBytes: expected.manifest
                        .compatibilityIdentity.maximumCheckpointByteCount)
                let loaded = try loadContainer(
                    expectedManifest: expected.manifest,
                    fileDescriptor: descriptor)
                return loaded
            } materialize: { loaded in
                try materialize(
                    loaded,
                    expectedManifest: expected.manifest)
            }
        } catch let error as PrimeNativeDecoderCheckpointV2Error {
            throw error
        } catch {
            throw mapVerificationError(error)
        }
    }

    private static func mapPublicationError(
        _ error: Error
    ) -> PrimeNativeDecoderCheckpointV2Error {
        guard let durable = error as? PrimeDurableArtifactError else {
            return .durabilityOrPublicationFailure
        }
        switch durable {
        case .invalidRelativePath,
             .invalidSemantics:
            return .invalidExternalBinding
        case .conflictingArtifact:
            return .destinationConflict
        case .hashMismatch:
            return .containerHashMismatch
        case .byteCountMismatch:
            return .containerByteCountMismatch
        case .untrustedDirectory,
             .nonemptyArtifactRoot,
             .unsafeArtifact:
            return .concurrentMutation
        case .artifactTooLarge,
             .nonCanonicalJSON,
             .invalidObservation,
             .posix,
             .unsupportedPlatform:
            return .durabilityOrPublicationFailure
        }
    }

    private static func mapVerificationError(
        _ error: Error
    ) -> PrimeNativeDecoderCheckpointV2Error {
        guard let durable = error as? PrimeDurableArtifactError else {
            return .artifactVerificationFailed
        }
        switch durable {
        case .invalidRelativePath,
             .invalidSemantics:
            return .invalidExternalBinding
        case .conflictingArtifact:
            return .destinationConflict
        case .hashMismatch:
            return .containerHashMismatch
        case .byteCountMismatch,
             .artifactTooLarge:
            return .containerByteCountMismatch
        case .untrustedDirectory,
             .nonemptyArtifactRoot,
             .unsafeArtifact:
            return .concurrentMutation
        case .nonCanonicalJSON,
             .invalidObservation,
             .posix,
             .unsupportedPlatform:
            return .artifactVerificationFailed
        }
    }

    private struct LoadedContainer {
        let arrays: [String: MLXArray]
    }

    private static func loadAndMaterialize(
        expectedManifest: PrimeNativeDecoderCheckpointManifestV2,
        fileDescriptor: Int32
    ) throws -> PrimeNativeGQADecoder {
        let loaded = try loadContainer(
            expectedManifest: expectedManifest,
            fileDescriptor: fileDescriptor)
        return try materialize(
            loaded,
            expectedManifest: expectedManifest)
    }

    private static func loadContainer(
        expectedManifest: PrimeNativeDecoderCheckpointManifestV2,
        fileDescriptor: Int32
    ) throws -> LoadedContainer {
        try expectedManifest.validateExactNative300MByte512()
        try validateRawSafetensorsLayout(
            expectedManifest: expectedManifest,
            fileDescriptor: fileDescriptor)
        guard lseek(fileDescriptor, 0, SEEK_SET) >= 0 else {
            throw PrimeNativeDecoderCheckpointV2Error.descriptorRejected
        }
        let arrays: [String: MLXArray]
        let metadata: [String: String]
        do {
            (arrays, metadata) = try MLX.loadArraysAndMetadata(
                fileDescriptor: fileDescriptor,
                stream: .cpu)
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error
                .checkpointReadFailed
        }
        try decodeExactEmbeddedManifest(
            metadata,
            expectedManifest: expectedManifest)
        return LoadedContainer(arrays: arrays)
    }

    private static func materialize(
        _ loaded: LoadedContainer,
        expectedManifest: PrimeNativeDecoderCheckpointManifestV2
    ) throws -> PrimeNativeGQADecoder {
        let identity = expectedManifest.compatibilityIdentity
        let loadedBindings = try inspect(
            arrays: loaded.arrays,
            identity: identity)
        guard loadedBindings == expectedManifest.tensorBindings else {
            throw PrimeNativeDecoderCheckpointV2Error
                .parameterLogicalHashMismatch("<catalog>")
        }

        let configuration: PrimeNativeGQADecoderConfiguration
        do {
            configuration = try identity.configuration.configuration()
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.contractDrift
        }
        let model = PrimeNativeGQADecoder.make(
            configuration: configuration)
        let parameters = ModuleParameters.unflattened(
            loaded.arrays.map { ($0.key, $0.value) })
        do {
            try model.update(parameters: parameters, verify: .all)
            try checkedEval(model.parameters().flattenedValues())
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error
                .checkpointRestoreFailed
        }
        let restored = try inspect(
            arrays: try uniqueParameters(model),
            identity: identity)
        guard restored == expectedManifest.tensorBindings else {
            throw PrimeNativeDecoderCheckpointV2Error
                .parameterLogicalHashMismatch("<restored_catalog>")
        }
        return model
    }

    private static func decodeExactEmbeddedManifest(
        _ metadata: [String: String],
        expectedManifest: PrimeNativeDecoderCheckpointManifestV2
    ) throws {
        let expectedBytes: Data
        do {
            expectedBytes = try PrimeCanonicalJSON.encode(expectedManifest)
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error
                .checkpointMetadataMismatch
        }
        guard let expectedText = String(
            data: expectedBytes,
            encoding: .utf8),
              Set(metadata.keys) == Set([
                  manifestMetadataKey,
                  manifestSHA256MetadataKey,
              ]),
              let embeddedText = metadata[manifestMetadataKey],
              embeddedText == expectedText,
              let embeddedBytes = embeddedText.data(using: .utf8),
              embeddedBytes == expectedBytes,
              metadata[manifestSHA256MetadataKey]
                == PrimeSHA256.hexDigest(of: embeddedBytes)
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .checkpointMetadataMismatch
        }
        do {
            let decoded = try PrimeCanonicalJSON.decode(
                PrimeNativeDecoderCheckpointManifestV2.self,
                from: embeddedBytes,
                artifact: "<checkpoint_v2_metadata>")
            guard decoded == expectedManifest else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .checkpointMetadataMismatch
            }
            try decoded.validateExactNative300MByte512()
        } catch let error as PrimeNativeDecoderCheckpointV2Error {
            throw error
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error
                .checkpointMetadataMismatch
        }
    }

    /// Validates the exact safetensors byte layout before the MLX parser sees
    /// the descriptor. This closes the format-level ambiguity left by merely
    /// checking that each declared range lies somewhere inside the file.
    private static func validateRawSafetensorsLayout(
        expectedManifest: PrimeNativeDecoderCheckpointManifestV2,
        fileDescriptor: Int32
    ) throws {
        var fileMetadata = stat()
        guard fstat(fileDescriptor, &fileMetadata) == 0,
              fileMetadata.st_size >= 0
        else {
            throw PrimeNativeDecoderCheckpointV2Error.descriptorRejected
        }
        let fileByteCount = UInt64(fileMetadata.st_size)
        guard fileByteCount > 8 else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidCheckpointSize(observed: fileByteCount)
        }

        var encodedHeaderLength = [UInt8](repeating: 0, count: 8)
        try encodedHeaderLength.withUnsafeMutableBytes { buffer in
            try preadExactly(
                fileDescriptor,
                into: buffer,
                at: 0)
        }
        let headerByteCount = encodedHeaderLength.withUnsafeBytes {
            UInt64(littleEndian: $0.loadUnaligned(as: UInt64.self))
        }
        guard headerByteCount > 0,
              headerByteCount <= maximumV2SafetensorsHeaderByteCount,
              headerByteCount <= UInt64(Int.max)
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
        let headerEnd = UInt64(8).addingReportingOverflow(
            headerByteCount)
        guard !headerEnd.overflow,
              headerEnd.partialValue <= fileByteCount
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }

        let identity = expectedManifest.compatibilityIdentity
        let exactFileByteCount = headerEnd.partialValue
            .addingReportingOverflow(identity.totalParameterByteCount)
        guard !exactFileByteCount.overflow,
              exactFileByteCount.partialValue == fileByteCount
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsLayout
        }

        var header = [UInt8](
            repeating: 0,
            count: Int(headerByteCount))
        try header.withUnsafeMutableBytes { buffer in
            try preadExactly(
                fileDescriptor,
                into: buffer,
                at: 8)
        }
        let manifestBytes: Data
        do {
            manifestBytes = try PrimeCanonicalJSON.encode(
                expectedManifest)
        } catch {
            throw PrimeNativeDecoderCheckpointV2Error.invalidManifest
        }
        guard UInt64(manifestBytes.count)
                <= maximumV2ManifestByteCount,
              let manifestText = String(
                  data: manifestBytes,
                  encoding: .utf8)
        else {
            throw PrimeNativeDecoderCheckpointV2Error.invalidManifest
        }
        let exactMetadata = [
            manifestMetadataKey: manifestText,
            manifestSHA256MetadataKey:
                PrimeSHA256.hexDigest(of: manifestBytes),
        ]
        var parser = PrimeV2SafetensorsHeaderParser(
            bytes: header,
            expectedCatalog: identity.parameterCatalog,
            expectedMetadata: exactMetadata)
        let extents = try parser.parse()

        var cursor: UInt64 = 0
        for extent in extents.sorted(by: { lhs, rhs in
            if lhs.start == rhs.start {
                return lhs.path < rhs.path
            }
            return lhs.start < rhs.start
        }) {
            guard extent.start == cursor,
                  extent.end > extent.start
            else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsLayout
            }
            cursor = extent.end
        }
        guard cursor == identity.totalParameterByteCount else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsLayout
        }
    }

    private static func preadExactly(
        _ fileDescriptor: Int32,
        into buffer: UnsafeMutableRawBufferPointer,
        at initialOffset: UInt64
    ) throws {
        guard initialOffset <= UInt64(Int64.max) else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
        var completed = 0
        while completed < buffer.count {
            let offset = initialOffset.addingReportingOverflow(
                UInt64(completed))
            guard !offset.overflow,
                  offset.partialValue <= UInt64(Int64.max),
                  let baseAddress = buffer.baseAddress
            else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsHeader
            }
            let count = Darwin.pread(
                fileDescriptor,
                baseAddress.advanced(by: completed),
                buffer.count - completed,
                off_t(offset.partialValue))
            if count < 0 {
                if errno == EINTR {
                    continue
                }
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsHeader
            }
            guard count > 0 else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsHeader
            }
            completed += count
        }
    }

    private static func preflightFreshWriteDescriptor(
        _ fileDescriptor: Int32
    ) throws {
        guard fileDescriptor >= 0 else {
            throw PrimeNativeDecoderCheckpointV2Error.descriptorRejected
        }
        var metadata = stat()
        guard fstat(fileDescriptor, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              metadata.st_size == 0
        else {
            throw PrimeNativeDecoderCheckpointV2Error.descriptorRejected
        }
        let flags = fcntl(fileDescriptor, F_GETFL)
        guard flags >= 0,
              flags & O_ACCMODE != O_RDONLY,
              flags & O_APPEND == 0
        else {
            throw PrimeNativeDecoderCheckpointV2Error.descriptorRejected
        }
    }

    private static func preflightReadableDescriptor(
        _ fileDescriptor: Int32,
        maximumBytes: UInt64
    ) throws {
        guard fileDescriptor >= 0 else {
            throw PrimeNativeDecoderCheckpointV2Error.descriptorRejected
        }
        var metadata = stat()
        guard fstat(fileDescriptor, &metadata) == 0,
              (metadata.st_mode & S_IFMT) == S_IFREG,
              metadata.st_size >= 0
        else {
            throw PrimeNativeDecoderCheckpointV2Error.descriptorRejected
        }
        let flags = fcntl(fileDescriptor, F_GETFL)
        guard flags >= 0,
              flags & O_ACCMODE != O_WRONLY
        else {
            throw PrimeNativeDecoderCheckpointV2Error.descriptorRejected
        }
        let observed = UInt64(metadata.st_size)
        guard observed > 0 else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidCheckpointSize(observed: observed)
        }
        guard observed <= maximumBytes else {
            throw PrimeNativeDecoderCheckpointV2Error
                .checkpointFileTooLarge(
                    observed: observed,
                    maximum: maximumBytes)
        }
    }

    private static func uniqueParameters(
        _ model: PrimeNativeGQADecoder
    ) throws -> [String: MLXArray] {
        var result = [String: MLXArray]()
        for (path, array) in model.parameters().flattened() {
            guard result.updateValue(array, forKey: path) == nil else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .duplicateParameterPath(path)
            }
        }
        return result
    }

    private static func inspect(
        arrays: [String: MLXArray],
        identity: PrimeNativeDecoderCompatibilityIdentityV2
    ) throws -> [PrimeNativeDecoderCheckpointTensorBindingV2] {
        let expectedPaths = identity.parameterCatalog.map(\.path)
        guard Set(arrays.keys) == Set(expectedPaths),
              arrays.count == expectedPaths.count
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .parameterPathSetMismatch
        }

        var result = [PrimeNativeDecoderCheckpointTensorBindingV2]()
        result.reserveCapacity(expectedPaths.count)
        for descriptor in identity.parameterCatalog {
            guard let array = arrays[descriptor.path] else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .parameterPathSetMismatch
            }
            guard array.shape == descriptor.shape else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .parameterShapeMismatch(descriptor.path)
            }
            guard array.dtype == .float32,
                  descriptor.dtype == "float32"
            else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .parameterDTypeMismatch(descriptor.path)
            }
            guard array.size >= 0,
                  UInt64(array.size) == descriptor.elementCount
            else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .parameterByteCountMismatch(descriptor.path)
            }
            do {
                try checkedEval(array)
            } catch {
                throw PrimeNativeDecoderCheckpointV2Error
                    .checkpointReadFailed
            }
            let logical = array.asData(access: .copy)
            guard logical.shape == descriptor.shape,
                  logical.dType == .float32,
                  UInt64(logical.data.count) == descriptor.byteCount
            else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .parameterByteCountMismatch(descriptor.path)
            }
            let canonicalBytes: Data
            do {
                canonicalBytes = try canonicalV2LogicalFloat32Data(
                    logical.data)
            } catch {
                throw PrimeNativeDecoderCheckpointV2Error
                    .parameterContainsNonFiniteValue(descriptor.path)
            }
            result.append(
                PrimeNativeDecoderCheckpointTensorBindingV2(
                    path: descriptor.path,
                    logicalSHA256:
                        PrimeSHA256.hexDigest(of: canonicalBytes),
                    allValuesFinite: true))
        }
        return result
    }
}

private struct PrimeV2SafetensorsExtent {
    let path: String
    let start: UInt64
    let end: UInt64
}

/// Strict parser for the small JSON subset permitted by the exact V2
/// safetensors header. Parsing bytes directly rejects duplicate keys before
/// either Foundation or MLX can apply implementation-specific duplicate-key
/// behavior.
private struct PrimeV2SafetensorsHeaderParser {
    private let bytes: [UInt8]
    private let expectedCatalog:
        [PrimeNativeDecoderParameterDescriptorV1]
    private let expectedMetadata: [String: String]
    private var index = 0

    init(
        bytes: [UInt8],
        expectedCatalog: [PrimeNativeDecoderParameterDescriptorV1],
        expectedMetadata: [String: String]
    ) {
        self.bytes = bytes
        self.expectedCatalog = expectedCatalog
        self.expectedMetadata = expectedMetadata
    }

    mutating func parse() throws -> [PrimeV2SafetensorsExtent] {
        var descriptors = [
            String: PrimeNativeDecoderParameterDescriptorV1
        ]()
        for descriptor in expectedCatalog {
            guard descriptors.updateValue(
                descriptor,
                forKey: descriptor.path) == nil
            else {
                throw PrimeNativeDecoderCheckpointV2Error.contractDrift
            }
        }

        skipWhitespace()
        try expect(ascii: "{")
        var topLevelNames = Set<String>()
        var observedTensorNames = Set<String>()
        var observedMetadata = false
        var extents = [PrimeV2SafetensorsExtent]()

        skipWhitespace()
        guard !consume(ascii: "}") else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
        while true {
            let name = try parseString()
            guard topLevelNames.insert(name).inserted else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsHeader
            }
            skipWhitespace()
            try expect(ascii: ":")
            if name == "__metadata__" {
                guard !observedMetadata else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                try parseExactMetadata()
                observedMetadata = true
            } else {
                guard let descriptor = descriptors[name],
                      observedTensorNames.insert(name).inserted
                else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                extents.append(
                    try parseTensor(
                        named: name,
                        descriptor: descriptor))
            }
            skipWhitespace()
            if consume(ascii: "}") {
                break
            }
            try expect(ascii: ",")
            skipWhitespace()
        }
        skipWhitespace()
        guard index == bytes.count,
              observedMetadata,
              observedTensorNames == Set(descriptors.keys),
              topLevelNames.count == descriptors.count + 1,
              extents.count == descriptors.count
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
        return extents
    }

    private mutating func parseExactMetadata() throws {
        skipWhitespace()
        try expect(ascii: "{")
        var observed = [String: String]()
        skipWhitespace()
        if !consume(ascii: "}") {
            while true {
                let key = try parseString()
                guard expectedMetadata[key] != nil,
                      observed[key] == nil,
                      observed.count < expectedMetadata.count
                else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                skipWhitespace()
                try expect(ascii: ":")
                let value = try parseString()
                observed[key] = value
                skipWhitespace()
                if consume(ascii: "}") {
                    break
                }
                try expect(ascii: ",")
                skipWhitespace()
            }
        }
        guard observed == expectedMetadata else {
            throw PrimeNativeDecoderCheckpointV2Error
                .checkpointMetadataMismatch
        }
    }

    private mutating func parseTensor(
        named name: String,
        descriptor: PrimeNativeDecoderParameterDescriptorV1
    ) throws -> PrimeV2SafetensorsExtent {
        skipWhitespace()
        try expect(ascii: "{")
        var fieldNames = Set<String>()
        var dtype: String?
        var shape: [UInt64]?
        var offsets: (start: UInt64, end: UInt64)?

        skipWhitespace()
        if !consume(ascii: "}") {
            while true {
                let field = try parseString()
                guard fieldNames.insert(field).inserted else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                skipWhitespace()
                try expect(ascii: ":")
                switch field {
                case "dtype":
                    dtype = try parseString()
                case "shape":
                    shape = try parseUnsignedIntegerArray(
                        maximumCount: descriptor.shape.count)
                case "data_offsets":
                    offsets = try parseOffsets()
                default:
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                skipWhitespace()
                if consume(ascii: "}") {
                    break
                }
                try expect(ascii: ",")
                skipWhitespace()
            }
        }
        guard fieldNames == Set(["dtype", "shape", "data_offsets"]),
              let dtype,
              let shape,
              let offsets,
              dtype == "F32",
              descriptor.dtype == "float32"
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsLayout
        }

        var expectedShape = [UInt64]()
        expectedShape.reserveCapacity(descriptor.shape.count)
        for dimension in descriptor.shape {
            guard dimension >= 0 else {
                throw PrimeNativeDecoderCheckpointV2Error.contractDrift
            }
            expectedShape.append(UInt64(dimension))
        }
        var elementCount: UInt64 = 1
        for dimension in expectedShape {
            let product = elementCount.multipliedReportingOverflow(
                by: dimension)
            guard !product.overflow else {
                throw PrimeNativeDecoderCheckpointV2Error.contractDrift
            }
            elementCount = product.partialValue
        }
        let byteCount = elementCount.multipliedReportingOverflow(by: 4)
        let extentByteCount = offsets.end.subtractingReportingOverflow(
            offsets.start)
        guard shape == expectedShape,
              elementCount == descriptor.elementCount,
              !byteCount.overflow,
              byteCount.partialValue == descriptor.byteCount,
              !extentByteCount.overflow,
              extentByteCount.partialValue == descriptor.byteCount
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsLayout
        }
        return PrimeV2SafetensorsExtent(
            path: name,
            start: offsets.start,
            end: offsets.end)
    }

    private mutating func parseUnsignedIntegerArray(
        maximumCount: Int
    ) throws -> [UInt64] {
        skipWhitespace()
        try expect(ascii: "[")
        var result = [UInt64]()
        skipWhitespace()
        if consume(ascii: "]") {
            return result
        }
        while true {
            guard result.count < maximumCount else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsLayout
            }
            result.append(try parseUnsignedInteger())
            skipWhitespace()
            if consume(ascii: "]") {
                return result
            }
            try expect(ascii: ",")
            skipWhitespace()
        }
    }

    private mutating func parseOffsets() throws
        -> (start: UInt64, end: UInt64)
    {
        skipWhitespace()
        try expect(ascii: "[")
        skipWhitespace()
        let start = try parseUnsignedInteger()
        skipWhitespace()
        try expect(ascii: ",")
        skipWhitespace()
        let end = try parseUnsignedInteger()
        skipWhitespace()
        try expect(ascii: "]")
        return (start, end)
    }

    private mutating func parseUnsignedInteger() throws -> UInt64 {
        skipWhitespace()
        guard index < bytes.count,
              bytes[index] != ascii("-")
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
        let first = bytes[index]
        guard isDigit(first) else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }

        var value: UInt64 = 0
        if first == ascii("0") {
            index += 1
            guard index == bytes.count || !isDigit(bytes[index]) else {
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsHeader
            }
        } else {
            while index < bytes.count, isDigit(bytes[index]) {
                let digit = UInt64(bytes[index] - ascii("0"))
                let multiplied = value.multipliedReportingOverflow(by: 10)
                let added = multiplied.partialValue
                    .addingReportingOverflow(digit)
                guard !multiplied.overflow, !added.overflow else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                value = added.partialValue
                index += 1
            }
        }
        guard index == bytes.count
                || (bytes[index] != ascii(".")
                    && bytes[index] != ascii("e")
                    && bytes[index] != ascii("E"))
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
        return value
    }

    private mutating func parseString() throws -> String {
        skipWhitespace()
        try expect(ascii: "\"")
        var decoded = [UInt8]()
        while index < bytes.count {
            let byte = bytes[index]
            index += 1
            switch byte {
            case ascii("\""):
                guard let result = String(
                    bytes: decoded,
                    encoding: .utf8)
                else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                return result
            case ascii("\\"):
                try parseEscape(into: &decoded)
            case 0 ... 0x1f:
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsHeader
            default:
                decoded.append(byte)
            }
        }
        throw PrimeNativeDecoderCheckpointV2Error
            .invalidSafetensorsHeader
    }

    private mutating func parseEscape(into decoded: inout [UInt8]) throws {
        guard index < bytes.count else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
        let escaped = bytes[index]
        index += 1
        switch escaped {
        case ascii("\""), ascii("\\"), ascii("/"):
            decoded.append(escaped)
        case ascii("b"):
            decoded.append(0x08)
        case ascii("f"):
            decoded.append(0x0c)
        case ascii("n"):
            decoded.append(0x0a)
        case ascii("r"):
            decoded.append(0x0d)
        case ascii("t"):
            decoded.append(0x09)
        case ascii("u"):
            let first = try parseHexQuad()
            let scalar: UInt32
            if first >= 0xd800, first <= 0xdbff {
                guard consume(ascii: "\\"),
                      consume(ascii: "u")
                else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                let second = try parseHexQuad()
                guard second >= 0xdc00, second <= 0xdfff else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                scalar = 0x10000
                    + (UInt32(first - 0xd800) << 10)
                    + UInt32(second - 0xdc00)
            } else {
                guard first < 0xdc00 || first > 0xdfff else {
                    throw PrimeNativeDecoderCheckpointV2Error
                        .invalidSafetensorsHeader
                }
                scalar = UInt32(first)
            }
            appendUTF8(scalar, to: &decoded)
        default:
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
    }

    private mutating func parseHexQuad() throws -> UInt16 {
        guard index <= bytes.count,
              bytes.count - index >= 4
        else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
        var value: UInt16 = 0
        for _ in 0 ..< 4 {
            let byte = bytes[index]
            index += 1
            let digit: UInt16
            switch byte {
            case ascii("0") ... ascii("9"):
                digit = UInt16(byte - ascii("0"))
            case ascii("A") ... ascii("F"):
                digit = UInt16(byte - ascii("A") + 10)
            case ascii("a") ... ascii("f"):
                digit = UInt16(byte - ascii("a") + 10)
            default:
                throw PrimeNativeDecoderCheckpointV2Error
                    .invalidSafetensorsHeader
            }
            value = (value << 4) | digit
        }
        return value
    }

    private func appendUTF8(_ scalar: UInt32, to bytes: inout [UInt8]) {
        if scalar <= 0x7f {
            bytes.append(UInt8(scalar))
        } else if scalar <= 0x7ff {
            bytes.append(UInt8(0xc0 | (scalar >> 6)))
            bytes.append(UInt8(0x80 | (scalar & 0x3f)))
        } else if scalar <= 0xffff {
            bytes.append(UInt8(0xe0 | (scalar >> 12)))
            bytes.append(UInt8(0x80 | ((scalar >> 6) & 0x3f)))
            bytes.append(UInt8(0x80 | (scalar & 0x3f)))
        } else {
            bytes.append(UInt8(0xf0 | (scalar >> 18)))
            bytes.append(UInt8(0x80 | ((scalar >> 12) & 0x3f)))
            bytes.append(UInt8(0x80 | ((scalar >> 6) & 0x3f)))
            bytes.append(UInt8(0x80 | (scalar & 0x3f)))
        }
    }

    private mutating func expect(ascii character: Character) throws {
        guard consume(ascii: character) else {
            throw PrimeNativeDecoderCheckpointV2Error
                .invalidSafetensorsHeader
        }
    }

    private mutating func consume(ascii character: Character) -> Bool {
        let expected = ascii(character)
        guard index < bytes.count,
              bytes[index] == expected
        else {
            return false
        }
        index += 1
        return true
    }

    private mutating func skipWhitespace() {
        while index < bytes.count {
            switch bytes[index] {
            case 0x09, 0x0a, 0x0d, 0x20:
                index += 1
            default:
                return
            }
        }
    }

    private func isDigit(_ byte: UInt8) -> Bool {
        byte >= ascii("0") && byte <= ascii("9")
    }

    private func ascii(_ character: Character) -> UInt8 {
        character.asciiValue!
    }
}

private func canonicalV2LogicalFloat32Data(_ data: Data) throws -> Data {
    guard data.count.isMultiple(of: MemoryLayout<UInt32>.size) else {
        throw PrimeNativeDecoderCheckpointV2Error.contractDrift
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
                throw PrimeNativeDecoderCheckpointV2Error.contractDrift
            }
            var littleEndianBits = bits.littleEndian
            Swift.withUnsafeBytes(of: &littleEndianBits) {
                canonical.append(contentsOf: $0)
            }
        }
    }
    return canonical
}

private func isV2LowercaseHex(_ byte: UInt8) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
