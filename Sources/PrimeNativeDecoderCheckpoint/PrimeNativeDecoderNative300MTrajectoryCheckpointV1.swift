// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Darwin
import CryptoKit
import Foundation
import MLX
import PrimeCore
import PrimeNativeDecoder

/// The three process-local four-leaf sets used by the Stage-7 trajectory
/// checkpoint experiment.  Only `baselineCheckpoint` is a resume authority;
/// the other two roles are immutable comparison evidence.
public enum PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case baselineCheckpoint = "baseline_checkpoint"
    case uninterruptedNPlus1Comparator =
        "uninterrupted_n_plus_1_comparator"
    case resumedNPlus1Comparator = "resumed_n_plus_1_comparator"

    public var loadAuthoritative: Bool {
        self == .baselineCheckpoint
    }
}

private struct TrajectoryExpectedSafetensorV1 {
    let storagePath: String
    let comparisonPath: String
    let shape: [Int]
    let elementCount: UInt64
    let byteCount: UInt64
}

private struct TrajectorySafetensorExtentV1 {
    let dataOffset: UInt64
    let byteCount: UInt64
}

private struct TrajectorySafetensorLayoutV1 {
    let extents: [String: TrajectorySafetensorExtentV1]
}

/// A small JSON recognizer used before Foundation decoding so duplicate keys
/// cannot be silently collapsed by an implementation-specific JSON parser.
private struct TrajectoryUniqueJSONScannerV1 {
    let bytes: [UInt8]
    var index = 0

    mutating func validate() throws {
        skipWhitespace()
        try value()
        skipWhitespace()
        guard index == bytes.count else { throw failure }
    }

    private var failure:
        PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
    { .streamingComparisonFailed }

    private mutating func value() throws {
        skipWhitespace()
        guard index < bytes.count else { throw failure }
        switch bytes[index] {
        case 0x7b: try object()
        case 0x5b: try array()
        case 0x22: _ = try string()
        case 0x74: try literal("true")
        case 0x66: try literal("false")
        case 0x6e: try literal("null")
        case 0x2d, 0x30 ... 0x39: try number()
        default: throw failure
        }
    }

    private mutating func object() throws {
        try expect(0x7b)
        skipWhitespace()
        if consume(0x7d) { return }
        var keys = Set<String>()
        while true {
            skipWhitespace()
            let key = try string()
            guard keys.insert(key).inserted else { throw failure }
            skipWhitespace()
            try expect(0x3a)
            try value()
            skipWhitespace()
            if consume(0x7d) { return }
            try expect(0x2c)
        }
    }

    private mutating func array() throws {
        try expect(0x5b)
        skipWhitespace()
        if consume(0x5d) { return }
        while true {
            try value()
            skipWhitespace()
            if consume(0x5d) { return }
            try expect(0x2c)
        }
    }

    private mutating func string() throws -> String {
        try expect(0x22)
        let start = index - 1
        var escaped = false
        while index < bytes.count {
            let byte = bytes[index]
            index += 1
            if escaped {
                if byte == 0x75 {
                    guard index + 4 <= bytes.count,
                          bytes[index ..< index + 4].allSatisfy({ value in
                              (value >= 0x30 && value <= 0x39)
                                  || (value >= 0x41 && value <= 0x46)
                                  || (value >= 0x61 && value <= 0x66)
                          })
                    else { throw failure }
                    index += 4
                } else if ![0x22, 0x5c, 0x2f, 0x62, 0x66, 0x6e, 0x72, 0x74]
                    .contains(byte)
                {
                    throw failure
                }
                escaped = false
                continue
            }
            if byte == 0x5c {
                escaped = true
                continue
            }
            if byte == 0x22 {
                let data = Data(bytes[start ..< index])
                guard let decoded = try? JSONSerialization.jsonObject(
                    with: Data("[".utf8) + data + Data("]".utf8))
                    as? [String],
                      decoded.count == 1
                else { throw failure }
                return decoded[0]
            }
            guard byte >= 0x20 else { throw failure }
        }
        throw failure
    }

    private mutating func number() throws {
        if consume(0x2d) {}
        guard index < bytes.count else { throw failure }
        if consume(0x30) {
            guard index == bytes.count
                    || !(bytes[index] >= 0x30 && bytes[index] <= 0x39)
            else { throw failure }
        } else {
            guard bytes[index] >= 0x31 && bytes[index] <= 0x39 else {
                throw failure
            }
            index += 1
            while index < bytes.count,
                  bytes[index] >= 0x30, bytes[index] <= 0x39
            { index += 1 }
        }
        if consume(0x2e) {
            try digits()
        }
        if index < bytes.count, bytes[index] == 0x65 || bytes[index] == 0x45 {
            index += 1
            if index < bytes.count, bytes[index] == 0x2b || bytes[index] == 0x2d {
                index += 1
            }
            try digits()
        }
    }

    private mutating func digits() throws {
        let start = index
        while index < bytes.count,
              bytes[index] >= 0x30, bytes[index] <= 0x39
        { index += 1 }
        guard index > start else { throw failure }
    }

    private mutating func literal(_ text: String) throws {
        let encoded = Array(text.utf8)
        guard index + encoded.count <= bytes.count,
              Array(bytes[index ..< index + encoded.count]) == encoded
        else { throw failure }
        index += encoded.count
    }

    private mutating func expect(_ byte: UInt8) throws {
        guard consume(byte) else { throw failure }
    }

    private mutating func consume(_ byte: UInt8) -> Bool {
        guard index < bytes.count, bytes[index] == byte else { return false }
        index += 1
        return true
    }

    private mutating func skipWhitespace() {
        while index < bytes.count,
              [0x20, 0x09, 0x0a, 0x0d].contains(bytes[index])
        { index += 1 }
    }
}

private func trajectoryExactUnsignedV1(_ value: Any?) -> UInt64? {
    guard let number = value as? NSNumber,
          CFGetTypeID(number) != CFBooleanGetTypeID()
    else { return nil }
    let text = number.stringValue
    guard !text.isEmpty, text.allSatisfy({ $0 >= "0" && $0 <= "9" })
    else { return nil }
    return UInt64(text)
}

private func trajectoryPreadExactlyV1(
    _ descriptor: Int32,
    offset: UInt64,
    buffer: UnsafeMutableRawBufferPointer
) throws {
    var completed = 0
    while completed < buffer.count {
        let current = offset.addingReportingOverflow(UInt64(completed))
        guard !current.overflow,
              current.partialValue <= UInt64(Int64.max),
              let base = buffer.baseAddress
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .streamingComparisonFailed
        }
        let count = Darwin.pread(
            descriptor,
            base.advanced(by: completed),
            buffer.count - completed,
            off_t(current.partialValue))
        if count < 0, errno == EINTR { continue }
        guard count > 0 else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .streamingComparisonFailed
        }
        completed += count
    }
}

private func trajectoryParseSafetensorsV1(
    descriptor: Int32,
    expected: [TrajectoryExpectedSafetensorV1],
    expectedMetadata: [String: String]
) throws -> TrajectorySafetensorLayoutV1 {
    var metadata = stat()
    guard fstat(descriptor, &metadata) == 0, metadata.st_size > 8 else {
        throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
            .streamingComparisonFailed
    }
    var lengthBytes = [UInt8](repeating: 0, count: 8)
    try lengthBytes.withUnsafeMutableBytes {
        try trajectoryPreadExactlyV1(descriptor, offset: 0, buffer: $0)
    }
    let headerCount = lengthBytes.withUnsafeBytes {
        UInt64(littleEndian: $0.loadUnaligned(as: UInt64.self))
    }
    guard headerCount > 0, headerCount <= 16 * 1024 * 1024,
          headerCount <= UInt64(Int.max)
    else {
        throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
            .streamingComparisonFailed
    }
    let dataBase = UInt64(8).addingReportingOverflow(headerCount)
    guard !dataBase.overflow, dataBase.partialValue <= UInt64(metadata.st_size)
    else {
        throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
            .streamingComparisonFailed
    }
    var header = [UInt8](repeating: 0, count: Int(headerCount))
    try header.withUnsafeMutableBytes {
        try trajectoryPreadExactlyV1(descriptor, offset: 8, buffer: $0)
    }
    var scanner = TrajectoryUniqueJSONScannerV1(bytes: header)
    try scanner.validate()
    guard let object = try JSONSerialization.jsonObject(with: Data(header))
            as? [String: Any],
          Set(object.keys) == Set(expected.map(\.storagePath) + ["__metadata__"]),
          let observedMetadata = object["__metadata__"] as? [String: String],
          observedMetadata == expectedMetadata
    else {
        throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
            .streamingComparisonFailed
    }
    var extents = [String: TrajectorySafetensorExtentV1]()
    var relativeRanges = [(UInt64, UInt64)]()
    for tensor in expected {
        guard let fields = object[tensor.storagePath] as? [String: Any],
              Set(fields.keys) == ["dtype", "shape", "data_offsets"],
              fields["dtype"] as? String == "F32",
              let rawShape = fields["shape"] as? [Any],
              rawShape.count == tensor.shape.count,
              zip(rawShape, tensor.shape).allSatisfy({ pair in
                  trajectoryExactUnsignedV1(pair.0) == UInt64(pair.1)
              }),
              let offsets = fields["data_offsets"] as? [Any],
              offsets.count == 2,
              let start = trajectoryExactUnsignedV1(offsets[0]),
              let end = trajectoryExactUnsignedV1(offsets[1]),
              end > start,
              end - start == tensor.byteCount,
              !dataBase.partialValue.addingReportingOverflow(start).overflow,
              extents.updateValue(.init(
                  dataOffset: dataBase.partialValue
                    .addingReportingOverflow(start).partialValue,
                  byteCount: tensor.byteCount),
                  forKey: tensor.storagePath) == nil
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .streamingComparisonFailed
        }
        relativeRanges.append((start, end))
    }
    var cursor: UInt64 = 0
    for range in relativeRanges.sorted(by: { $0.0 < $1.0 }) {
        guard range.0 == cursor else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .streamingComparisonFailed
        }
        cursor = range.1
    }
    let exactSize = dataBase.partialValue.addingReportingOverflow(cursor)
    guard !exactSize.overflow,
          exactSize.partialValue == UInt64(metadata.st_size)
    else {
        throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
            .streamingComparisonFailed
    }
    return .init(extents: extents)
}

private func trajectoryAppendBigEndianV1(_ value: UInt64, to data: inout Data) {
    var bigEndian = value.bigEndian
    withUnsafeBytes(of: &bigEndian) { data.append(contentsOf: $0) }
}

private func trajectoryDigestHexV1<D: Digest>(_ digest: D) -> String {
    digest.map { String(format: "%02x", $0) }.joined()
}

/// Canonical metadata embedded in the neutral optimizer-moment safetensors
/// leaf.  The checkpoint target deliberately has no MLXOptimizers dependency:
/// it stores only a role-prefixed `[String: MLXArray]` catalog.  Training owns
/// conversion to and from typed `AdamOptimizerState`.
public struct PrimeNativeDecoderNative300MTrajectoryMomentTensorV1:
    Codable,
    Equatable,
    Sendable
{
    public let storageKey: String
    public let shape: [Int]
    public let dtype: String
    public let elementCount: UInt64
    public let logicalByteCount: UInt64

    private enum CodingKeys: String, CodingKey {
        case storageKey = "storage_key"
        case shape
        case dtype
        case elementCount = "element_count"
        case logicalByteCount = "logical_byte_count"
    }
}

public struct PrimeNativeDecoderNative300MTrajectoryMomentManifestV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let encoding: String
    public let firstMomentPrefix: String
    public let secondMomentPrefix: String
    public let tensors:
        [PrimeNativeDecoderNative300MTrajectoryMomentTensorV1]
    public let tensorCatalogCanonicalSHA256: String

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case encoding
        case firstMomentPrefix = "first_moment_prefix"
        case secondMomentPrefix = "second_moment_prefix"
        case tensors
        case tensorCatalogCanonicalSHA256 =
            "tensor_catalog_canonical_sha256"
    }
}

public struct PrimeNativeDecoderNative300MTrajectoryCommitManifestV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let stateScope: String
    public let setRole:
        PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
    public let loadAuthoritative: Bool
    public let precommitLeafBindings:
        [PrimeNativeDecoderTrajectoryLeafBindingV1]
    public let weightsExternalBinding:
        PrimeNativeDecoderCheckpointExternalBindingV2
    public let optimizerMomentManifest:
        PrimeNativeDecoderNative300MTrajectoryMomentManifestV1
    public let controlStateCanonicalByteCount: UInt64
    public let controlStateCanonicalSHA256: String
    public let finalCommitManifestIsExclusiveCommitPoint: Bool
    public let partialPrecommitLeavesAreAuthoritative: Bool
    public let loadRequiresExternallySuppliedExactCommitBinding: Bool

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case stateScope = "state_scope"
        case setRole = "set_role"
        case loadAuthoritative = "load_authoritative"
        case precommitLeafBindings = "precommit_leaf_bindings"
        case weightsExternalBinding = "weights_external_binding"
        case optimizerMomentManifest = "optimizer_moment_manifest"
        case controlStateCanonicalByteCount =
            "control_state_canonical_byte_count"
        case controlStateCanonicalSHA256 =
            "control_state_canonical_sha256"
        case finalCommitManifestIsExclusiveCommitPoint =
            "final_commit_manifest_is_exclusive_commit_point"
        case partialPrecommitLeavesAreAuthoritative =
            "partial_precommit_leaves_are_authoritative"
        case loadRequiresExternallySuppliedExactCommitBinding =
            "load_requires_externally_supplied_exact_commit_binding"
    }
}

/// The sole out-of-band authority accepted by the Native-300M trajectory
/// codec.  No API discovers a directory and trusts its embedded commit.
public struct PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let directory: String
    public let setRole:
        PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
    public let loadAuthoritative: Bool
    public let orderedLeafBindings:
        [PrimeNativeDecoderTrajectoryLeafBindingV1]
    public let weightsExternalBinding:
        PrimeNativeDecoderCheckpointExternalBindingV2
    public let optimizerMomentManifest:
        PrimeNativeDecoderNative300MTrajectoryMomentManifestV1
    public let controlStateCanonicalByteCount: UInt64
    public let controlStateCanonicalSHA256: String
    public let commitManifestCanonicalByteCount: UInt64
    public let commitManifestCanonicalSHA256: String

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case directory
        case setRole = "set_role"
        case loadAuthoritative = "load_authoritative"
        case orderedLeafBindings = "ordered_leaf_bindings"
        case weightsExternalBinding = "weights_external_binding"
        case optimizerMomentManifest = "optimizer_moment_manifest"
        case controlStateCanonicalByteCount =
            "control_state_canonical_byte_count"
        case controlStateCanonicalSHA256 =
            "control_state_canonical_sha256"
        case commitManifestCanonicalByteCount =
            "commit_manifest_canonical_byte_count"
        case commitManifestCanonicalSHA256 =
            "commit_manifest_canonical_sha256"
    }
}

/// Fail-closed publication evidence for a set whose exclusive commit was not
/// published.  Every listed leaf remains independently bound and the four
/// deterministic final paths let the supervisor remove only known names.
/// This value is never load authority.
public struct PrimeNativeDecoderNative300MTrajectoryQuarantineV1:
    Equatable,
    Sendable
{
    public let directory: String
    public let setRole:
        PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
    public let publishedPrecommitLeafBindings:
        [PrimeNativeDecoderTrajectoryLeafBindingV1]
    public let knownLeafRelativePaths: [String]
    public let finalCommitPublished: Bool
}

public struct PrimeNativeDecoderNative300MTrajectoryModelAndControlV1 {
    public let model: PrimeNativeGQADecoder
    public let controlState: Data
}

public struct PrimeNativeDecoderNative300MTrajectoryStreamedTensorV1:
    Equatable,
    Sendable
{
    public let path: String
    public let shape: [Int]
    public let dtype: String
    public let elementCount: UInt64
    public let logicalByteCount: UInt64
    public let leftLogicalSHA256: String
    public let rightLogicalSHA256: String
    public let exact: Bool
}

public struct PrimeNativeDecoderNative300MTrajectoryStreamedCatalogV1:
    Equatable,
    Sendable
{
    public let tensors:
        [PrimeNativeDecoderNative300MTrajectoryStreamedTensorV1]
    public let structuralSHA256: String
    public let leftLogicalSHA256: String
    public let rightLogicalSHA256: String
    public let totalElementCount: UInt64
    public let totalLogicalByteCount: UInt64
    public let firstMismatchPath: String?

    public var exact: Bool { firstMismatchPath == nil }
}

public struct PrimeNativeDecoderNative300MTrajectoryStreamingComparisonV1:
    Equatable,
    Sendable
{
    public let weights:
        PrimeNativeDecoderNative300MTrajectoryStreamedCatalogV1
    public let firstMoments:
        PrimeNativeDecoderNative300MTrajectoryStreamedCatalogV1
    public let secondMoments:
        PrimeNativeDecoderNative300MTrajectoryStreamedCatalogV1
    public let uninterruptedControlState: Data
    public let resumedControlState: Data
    public let controlSemanticExact: Bool
    public let firstControlMismatchPath: String?
}

public struct PrimeNativeDecoderNative300MTrajectoryCleanupV1:
    Equatable,
    Sendable
{
    public let knownLeafCount: Int
    public let deletedLeafCount: Int
    public let deletedPrivateComparatorCount: Int
    public let unknownInventoryCount: Int
    public let postCleanupInventoryEmpty: Bool
    public let absenceProved: Bool
    public let recursiveCleanupUsed: Bool
}

public enum PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case invalidDirectory
    case invalidSetRole
    case invalidMomentCatalog
    case invalidControlState
    case invalidExternalCommitBinding
    case invalidCommitManifest
    case destinationConflict
    case publicationFailed
    case artifactVerificationFailed
    case weightsRestoreFailed
    case momentRestoreFailed
    case streamingComparisonFailed
    case cleanupFailed
    case partialPublication(
        PrimeNativeDecoderNative300MTrajectoryQuarantineV1
    )
    /// Cleanup-only authority for a complete set whose exclusive commit was
    /// published before a later validation or inventory check failed.  This
    /// binding must never be promoted to load authority or receipt evidence.
    case committedPublicationRequiresCleanup(
        PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    )
}

/// Exact four-leaf Native-300M trajectory checkpoint composition.
///
/// Publication order is weights V2, neutral optimizer moments, canonical
/// control state, and finally an exclusive canonical commit.  A caller must
/// pass the returned binding back for every read; an embedded manifest never
/// supplies its own expected hashes.
public enum PrimeNativeDecoderNative300MTrajectoryCheckpointV1 {
    public static let checkpointSchemaID =
        "ergentics_prime_native_decoder_trajectory_exact_resume_checkpoint_v1"
    public static let externalCommitBindingSchemaID =
        "ergentics_prime_native_decoder_trajectory_exact_resume_external_commit_binding_v1"
    public static let momentManifestSchemaID =
        "ergentics_prime_native_decoder_adamw_moments_checkpoint_v1"
    public static let momentEncoding =
        "safetensors_role_prefixed_string_mlxarray_catalog"
    public static let firstMomentStoragePrefix = "first_moment."
    public static let secondMomentStoragePrefix = "second_moment."
    public static let expectedParameterPathCount = 218
    public static let expectedMomentTensorCount = 436

    public static let weightsFileName = "weights.safetensors"
    public static let optimizerMomentsFileName =
        "optimizer_moments.safetensors"
    public static let controlStateFileName = "control_state.json"
    public static let commitManifestFileName = "commit.json"

    private static let stateScope =
        "native300m_b_path_same_device_ephemeral_exact_resume_v1"
    private static let momentManifestMetadataKey =
        "prime_native_decoder_trajectory_moment_manifest_v1"
    private static let momentManifestSHA256MetadataKey =
        "prime_native_decoder_trajectory_moment_manifest_sha256_v1"
    private static let maximumMomentContainerByteCount: UInt64 =
        2_185_633_792
    private static let maximumControlOrCommitByteCount: UInt64 =
        16 * 1024 * 1024

    /// The supervisor calls this once before any set publication.  Individual
    /// set publication intentionally does not demand an empty root because all
    /// three exact sets coexist in that one private root until comparison.
    public static func beginEphemeralRun(
        root: PrimeArtifactRoot
    ) throws {
        do {
            try root.requirePrivateRootMode()
            try root.requireEmpty()
        } catch {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .destinationConflict
        }
    }

    public static func publish(
        root: PrimeArtifactRoot,
        directory: String,
        setRole:
            PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1,
        model: PrimeNativeGQADecoder,
        optimizerMoments: [String: MLXArray],
        controlState: Data
    ) throws
        -> PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    {
        var publishedPrecommit =
            [PrimeNativeDecoderTrajectoryLeafBindingV1]()
        var commitPublished = false
        var committedBinding:
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1?
        func rethrowAfterPrecommitRecovery(
            _ publicationError: Error,
            leafRole: PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1,
            publicationOrdinal: Int,
            maximumByteCount: UInt64
        ) throws -> Never {
            do {
                if let recovered = try
                    recoverCleanupLeafAfterPublicationFailure(
                        root: root,
                        directory: directory,
                        setRole: setRole,
                        leafRole: leafRole,
                        publicationOrdinal: publicationOrdinal,
                        priorLeaves: publishedPrecommit,
                        maximumByteCount: maximumByteCount)
                {
                    publishedPrecommit.append(recovered)
                }
            } catch {
                // An unknown name, unsafe final file, or unstable observation
                // cannot support a quarantine claim.  Withhold the prefix so
                // the outer path is the frozen no-public publication failure.
                publishedPrecommit.removeAll(keepingCapacity: false)
            }
            throw publicationError
        }
        do {
            try root.requirePrivateRootMode()
            try validateDirectory(directory, role: setRole)
            try validateCanonicalControl(controlState)
            let modelCatalog = try exactModelCatalog(model)
            let momentManifest = try makeMomentManifest(
                optimizerMoments,
                matching: modelCatalog)
            let maximumWeightsByteCount = try
                PrimeNativeDecoderCompatibilityIdentityV2
                .native300MByte512().maximumCheckpointByteCount
            try root.ensurePrivateDirectory(at: directory)
            for file in [
                weightsFileName, optimizerMomentsFileName,
                controlStateFileName, commitManifestFileName,
            ] {
                try root.requireAbsent(at: path(directory, file))
            }

            let weights: PrimeNativeDecoderCheckpointExternalBindingV2
            do {
                weights = try PrimeNativeDecoderCheckpointCodecV2
                    .writeNative300MByte512(
                        model: model,
                        to: root,
                        at: path(directory, weightsFileName))
            } catch {
                try rethrowAfterPrecommitRecovery(
                    error,
                    leafRole: .weightsV2,
                    publicationOrdinal: 1,
                    maximumByteCount: maximumWeightsByteCount)
            }
            let weightsLeaf = PrimeNativeDecoderTrajectoryLeafBindingV1(
                role: .weightsV2,
                publicationOrdinal: 1,
                artifact: weights.artifactBinding)
            publishedPrecommit.append(weightsLeaf)

            let momentsArtifact: PrimeArtifactBinding
            do {
                momentsArtifact = try publishMoments(
                    optimizerMoments,
                    manifest: momentManifest,
                    root: root,
                    relativePath: path(
                        directory,
                        optimizerMomentsFileName))
            } catch {
                try rethrowAfterPrecommitRecovery(
                    error,
                    leafRole: .optimizerMoments,
                    publicationOrdinal: 2,
                    maximumByteCount: maximumMomentContainerByteCount)
            }
            let momentsLeaf = PrimeNativeDecoderTrajectoryLeafBindingV1(
                role: .optimizerMoments,
                publicationOrdinal: 2,
                artifact: momentsArtifact)
            publishedPrecommit.append(momentsLeaf)

            let controlArtifact: PrimeArtifactBinding
            do {
                controlArtifact = try root.publishGeneratedFile(
                    at: path(directory, controlStateFileName),
                    purpose: .immutableData,
                    maximumByteCount: maximumControlOrCommitByteCount
                ) { descriptor in
                    try writeAll(controlState, descriptor: descriptor)
                }
            } catch {
                try rethrowAfterPrecommitRecovery(
                    error,
                    leafRole: .controlStateManifest,
                    publicationOrdinal: 3,
                    maximumByteCount: maximumControlOrCommitByteCount)
            }
            let controlLeaf = PrimeNativeDecoderTrajectoryLeafBindingV1(
                role: .controlStateManifest,
                publicationOrdinal: 3,
                artifact: controlArtifact)
            publishedPrecommit.append(controlLeaf)
            let precommit = [weightsLeaf, momentsLeaf, controlLeaf]
            let commit = PrimeNativeDecoderNative300MTrajectoryCommitManifestV1(
                schemaVersion: 1,
                schemaID: checkpointSchemaID,
                stateScope: stateScope,
                setRole: setRole,
                loadAuthoritative: setRole.loadAuthoritative,
                precommitLeafBindings: precommit,
                weightsExternalBinding: weights,
                optimizerMomentManifest: momentManifest,
                controlStateCanonicalByteCount: UInt64(controlState.count),
                controlStateCanonicalSHA256:
                    PrimeSHA256.hexDigest(of: controlState),
                finalCommitManifestIsExclusiveCommitPoint: true,
                partialPrecommitLeavesAreAuthoritative: false,
                loadRequiresExternallySuppliedExactCommitBinding: true)
            let commitBytes = try PrimeCanonicalJSON.encode(commit)
            guard !commitBytes.isEmpty,
                  UInt64(commitBytes.count)
                    <= maximumControlOrCommitByteCount
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .invalidCommitManifest
            }
            let commitRelativePath = path(
                directory,
                commitManifestFileName)
            let expectedCommitArtifact = PrimeArtifactBinding(
                relativePath: commitRelativePath,
                sha256: PrimeSHA256.hexDigest(of: commitBytes),
                byteCount: UInt64(commitBytes.count),
                purpose: .immutableData)
            let commitLeaf = PrimeNativeDecoderTrajectoryLeafBindingV1(
                role: .commitManifest,
                publicationOrdinal: 4,
                artifact: expectedCommitArtifact)
            let result =
                PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1(
                    schemaVersion: 1,
                    schemaID: externalCommitBindingSchemaID,
                    directory: directory,
                    setRole: setRole,
                    loadAuthoritative: setRole.loadAuthoritative,
                    orderedLeafBindings: precommit + [commitLeaf],
                    weightsExternalBinding: weights,
                    optimizerMomentManifest: momentManifest,
                    controlStateCanonicalByteCount:
                        UInt64(controlState.count),
                    controlStateCanonicalSHA256:
                        PrimeSHA256.hexDigest(of: controlState),
                    commitManifestCanonicalByteCount:
                        UInt64(commitBytes.count),
                    commitManifestCanonicalSHA256:
                        PrimeSHA256.hexDigest(of: commitBytes))
            // Prove the full caller-supplied binding before the exclusive
            // commit attempt.  This exact binding also lets the failure path
            // recover a commit whose durable publisher renamed successfully
            // and then failed during its post-rename verification.
            try validateExternalBinding(result)
            committedBinding = result
            do {
                let commitArtifact = try root.publishCanonicalExclusively(
                    commit,
                    at: commitRelativePath)
                guard commitArtifact == expectedCommitArtifact else {
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .publicationFailed
                }
                commitPublished = true
            } catch {
                let publicationError = error
                if (try? root.verify(expectedCommitArtifact)) != nil {
                    commitPublished = true
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .committedPublicationRequiresCleanup(result)
                }
                do {
                    try root.requireAbsent(at: commitRelativePath)
                } catch {
                    // Neither exact presence nor exact absence was proved.
                    // Suppress the three-leaf quarantine claim so the outer
                    // path fails as unknown publication inventory and emits
                    // no receipt instead of attempting an incomplete unlink.
                    publishedPrecommit.removeAll(keepingCapacity: false)
                    throw publicationError
                }
                throw publicationError
            }
            _ = try root.captureTrustedInventory(
                rolePrefix: directory,
                expectedArtifacts:
                    result.orderedLeafBindings.map(\.artifact))
                .recaptureAndValidateUnchanged()
            return result
        } catch let error as
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
        {
            if commitPublished, let committedBinding {
                if case .committedPublicationRequiresCleanup = error {
                    throw error
                }
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .committedPublicationRequiresCleanup(committedBinding)
            }
            if !commitPublished, !publishedPrecommit.isEmpty,
               case .partialPublication = error
            {
                throw error
            }
            if !commitPublished, !publishedPrecommit.isEmpty {
                throw partialPublication(
                    directory: directory,
                    role: setRole,
                    leaves: publishedPrecommit)
            }
            throw error
        } catch is PrimeNativeDecoderCheckpointV2Error {
            if commitPublished, let committedBinding {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .committedPublicationRequiresCleanup(committedBinding)
            }
            if !commitPublished, !publishedPrecommit.isEmpty {
                throw partialPublication(
                    directory: directory,
                    role: setRole,
                    leaves: publishedPrecommit)
            }
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .publicationFailed
        } catch is PrimeDurableArtifactError {
            if commitPublished, let committedBinding {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .committedPublicationRequiresCleanup(committedBinding)
            }
            if !commitPublished, !publishedPrecommit.isEmpty {
                throw partialPublication(
                    directory: directory,
                    role: setRole,
                    leaves: publishedPrecommit)
            }
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .publicationFailed
        } catch {
            if commitPublished, let committedBinding {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .committedPublicationRequiresCleanup(committedBinding)
            }
            if !commitPublished, !publishedPrecommit.isEmpty {
                throw partialPublication(
                    directory: directory,
                    role: setRole,
                    leaves: publishedPrecommit)
            }
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .publicationFailed
        }
    }

    /// Validates all four immutable leaves and the caller-supplied commit
    /// binding without allocating a model or loading the moment tensors.
    public static func verify(
        root: PrimeArtifactRoot,
        externalCommitBinding:
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    ) throws {
        do {
            try root.requirePrivateRootMode()
            try validateExternalBinding(externalCommitBinding)
            let capture = try root.captureTrustedInventory(
                rolePrefix: externalCommitBinding.directory,
                expectedArtifacts:
                    externalCommitBinding.orderedLeafBindings.map(\.artifact))
            for leaf in externalCommitBinding.orderedLeafBindings {
                _ = try root.verify(leaf.artifact)
            }
            try validateCommit(
                root: root,
                binding: externalCommitBinding)
            _ = try capture.recaptureAndValidateUnchanged()
        } catch let error as
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
        {
            throw error
        } catch {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .artifactVerificationFailed
        }
    }

    /// Restores only the weights and canonical control leaf.  Moment loading
    /// remains a separate, explicitly deferred operation so the worker can
    /// deallocate the uninterrupted branch before materializing 2.17 GiB of
    /// optimizer state.
    public static func loadAuthoritativeModelAndControl(
        root: PrimeArtifactRoot,
        externalCommitBinding:
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    ) throws -> PrimeNativeDecoderNative300MTrajectoryModelAndControlV1 {
        guard externalCommitBinding.setRole == .baselineCheckpoint,
              externalCommitBinding.loadAuthoritative
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidSetRole
        }
        try verify(
            root: root,
            externalCommitBinding: externalCommitBinding)
        let model: PrimeNativeGQADecoder
        do {
            model = try PrimeNativeDecoderCheckpointCodecV2
                .loadNative300MByte512(
                    expected:
                        externalCommitBinding.weightsExternalBinding,
                    from: root)
        } catch {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .weightsRestoreFailed
        }
        let controlLeaf = externalCommitBinding.orderedLeafBindings[2]
        let control: Data
        do {
            control = try root.readVerified(
                controlLeaf.artifact,
                maximumByteCount: maximumControlOrCommitByteCount)
            try validateCanonicalControl(control)
            guard UInt64(control.count)
                    == externalCommitBinding
                        .controlStateCanonicalByteCount,
                  PrimeSHA256.hexDigest(of: control)
                    == externalCommitBinding
                        .controlStateCanonicalSHA256
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .invalidControlState
            }
        } catch let error as
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
        {
            throw error
        } catch {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .artifactVerificationFailed
        }
        return .init(model: model, controlState: control)
    }

    /// Loads the neutral role-prefixed MLX catalog for typed interpretation by
    /// PrimeNativeDecoderTraining.  Comparator roles may be inspected through
    /// this API, but only the baseline API above can allocate a resume model.
    public static func loadNeutralMomentCatalog(
        root: PrimeArtifactRoot,
        externalCommitBinding:
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1,
        matching model: PrimeNativeGQADecoder
    ) throws -> [String: MLXArray] {
        try verify(
            root: root,
            externalCommitBinding: externalCommitBinding)
        let leaf = externalCommitBinding.orderedLeafBindings[1]
        let modelCatalog = try exactModelCatalog(model)
        do {
            return try root.withVerifiedArtifactDescriptor(
                leaf.artifact
            ) { descriptor in
                try MLX.loadArraysAndMetadata(
                    fileDescriptor: descriptor,
                    // Metal has no Load::eval_gpu implementation. Materialize
                    // descriptor-backed file bytes on the CPU I/O stream, as
                    // the V2 weight loader does; subsequent Adam/model work
                    // still uses the caller's unchanged default GPU stream.
                    stream: .cpu)
            } materialize: { arrays, metadata in
                try validateLoadedMoments(
                    arrays: arrays,
                    metadata: metadata,
                    expected:
                        externalCommitBinding.optimizerMomentManifest,
                    matching: modelCatalog)
                return arrays
            }
        } catch let error as
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
        {
            throw error
        } catch {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .momentRestoreFailed
        }
    }

    /// Compares the two private successor sets only after their live MLX
    /// states have been destroyed by the training target.  Every tensor is
    /// read from two already verified descriptors with bounded `pread`
    /// buffers, one sorted path at a time.  No model or MLX array is loaded,
    /// and whole-container equality is never used as scientific evidence.
    public static func comparePrivateComparatorsStreaming(
        root: PrimeArtifactRoot,
        uninterrupted:
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1,
        resumed:
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    ) throws ->
        PrimeNativeDecoderNative300MTrajectoryStreamingComparisonV1
    {
        guard uninterrupted.setRole == .uninterruptedNPlus1Comparator,
              resumed.setRole == .resumedNPlus1Comparator,
              !uninterrupted.loadAuthoritative,
              !resumed.loadAuthoritative
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidSetRole
        }
        do {
            try verify(root: root, externalCommitBinding: uninterrupted)
            try verify(root: root, externalCommitBinding: resumed)

            let leftWeightManifest = uninterrupted.weightsExternalBinding
                .manifest
            let rightWeightManifest = resumed.weightsExternalBinding.manifest
            let leftWeightExpected = leftWeightManifest.compatibilityIdentity
                .parameterCatalog.map {
                    TrajectoryExpectedSafetensorV1(
                        storagePath: $0.path,
                        comparisonPath: $0.path,
                        shape: $0.shape,
                        elementCount: $0.elementCount,
                        byteCount: $0.byteCount)
                }
            let rightWeightExpected = rightWeightManifest
                .compatibilityIdentity.parameterCatalog.map {
                    TrajectoryExpectedSafetensorV1(
                        storagePath: $0.path,
                        comparisonPath: $0.path,
                        shape: $0.shape,
                        elementCount: $0.elementCount,
                        byteCount: $0.byteCount)
                }
            let leftWeightManifestData = try PrimeCanonicalJSON.encode(
                leftWeightManifest)
            let rightWeightManifestData = try PrimeCanonicalJSON.encode(
                rightWeightManifest)
            let weights = try compareSafetensorsStreaming(
                root: root,
                leftArtifact: uninterrupted.orderedLeafBindings[0].artifact,
                rightArtifact: resumed.orderedLeafBindings[0].artifact,
                leftExpected: leftWeightExpected,
                rightExpected: rightWeightExpected,
                leftContainerExpected: leftWeightExpected,
                rightContainerExpected: rightWeightExpected,
                leftMetadata: [
                    PrimeNativeDecoderCheckpointCodecV2.manifestMetadataKey:
                        String(decoding: leftWeightManifestData, as: UTF8.self),
                    PrimeNativeDecoderCheckpointCodecV2
                        .manifestSHA256MetadataKey:
                        PrimeSHA256.hexDigest(of: leftWeightManifestData),
                ],
                rightMetadata: [
                    PrimeNativeDecoderCheckpointCodecV2.manifestMetadataKey:
                        String(decoding: rightWeightManifestData, as: UTF8.self),
                    PrimeNativeDecoderCheckpointCodecV2
                        .manifestSHA256MetadataKey:
                        PrimeSHA256.hexDigest(of: rightWeightManifestData),
                ],
                leftExpectedLogicalSHA256: Dictionary(
                    uniqueKeysWithValues:
                        leftWeightManifest.tensorBindings.map {
                            ($0.path, $0.logicalSHA256)
                        }),
                rightExpectedLogicalSHA256: Dictionary(
                    uniqueKeysWithValues:
                        rightWeightManifest.tensorBindings.map {
                            ($0.path, $0.logicalSHA256)
                        }))

            let leftMomentManifestData = try PrimeCanonicalJSON.encode(
                uninterrupted.optimizerMomentManifest)
            let rightMomentManifestData = try PrimeCanonicalJSON.encode(
                resumed.optimizerMomentManifest)
            let leftMomentMetadata = [
                momentManifestMetadataKey:
                    String(decoding: leftMomentManifestData, as: UTF8.self),
                momentManifestSHA256MetadataKey:
                    PrimeSHA256.hexDigest(of: leftMomentManifestData),
            ]
            let rightMomentMetadata = [
                momentManifestMetadataKey:
                    String(decoding: rightMomentManifestData, as: UTF8.self),
                momentManifestSHA256MetadataKey:
                    PrimeSHA256.hexDigest(of: rightMomentManifestData),
            ]
            func expectedMoments(
                _ manifest:
                    PrimeNativeDecoderNative300MTrajectoryMomentManifestV1,
                prefix: String?
            ) -> [TrajectoryExpectedSafetensorV1] {
                manifest.tensors.compactMap { tensor in
                    guard prefix.map({
                        tensor.storageKey.hasPrefix($0)
                    }) ?? true else {
                        return nil
                    }
                    return .init(
                        storagePath: tensor.storageKey,
                        comparisonPath: tensor.storageKey,
                        shape: tensor.shape,
                        elementCount: tensor.elementCount,
                        byteCount: tensor.logicalByteCount)
                }
            }
            let firstMoments = try compareSafetensorsStreaming(
                root: root,
                leftArtifact: uninterrupted.orderedLeafBindings[1].artifact,
                rightArtifact: resumed.orderedLeafBindings[1].artifact,
                leftExpected: expectedMoments(
                    uninterrupted.optimizerMomentManifest,
                    prefix: firstMomentStoragePrefix),
                rightExpected: expectedMoments(
                    resumed.optimizerMomentManifest,
                    prefix: firstMomentStoragePrefix),
                leftContainerExpected: expectedMoments(
                    uninterrupted.optimizerMomentManifest, prefix: nil),
                rightContainerExpected: expectedMoments(
                    resumed.optimizerMomentManifest, prefix: nil),
                leftMetadata: leftMomentMetadata,
                rightMetadata: rightMomentMetadata,
                leftExpectedLogicalSHA256: [:],
                rightExpectedLogicalSHA256: [:])
            let secondMoments = try compareSafetensorsStreaming(
                root: root,
                leftArtifact: uninterrupted.orderedLeafBindings[1].artifact,
                rightArtifact: resumed.orderedLeafBindings[1].artifact,
                leftExpected: expectedMoments(
                    uninterrupted.optimizerMomentManifest,
                    prefix: secondMomentStoragePrefix),
                rightExpected: expectedMoments(
                    resumed.optimizerMomentManifest,
                    prefix: secondMomentStoragePrefix),
                leftContainerExpected: expectedMoments(
                    uninterrupted.optimizerMomentManifest, prefix: nil),
                rightContainerExpected: expectedMoments(
                    resumed.optimizerMomentManifest, prefix: nil),
                leftMetadata: leftMomentMetadata,
                rightMetadata: rightMomentMetadata,
                leftExpectedLogicalSHA256: [:],
                rightExpectedLogicalSHA256: [:])

            let leftControl = try root.readVerified(
                uninterrupted.orderedLeafBindings[2].artifact,
                maximumByteCount: maximumControlOrCommitByteCount)
            let rightControl = try root.readVerified(
                resumed.orderedLeafBindings[2].artifact,
                maximumByteCount: maximumControlOrCommitByteCount)
            let control = try compareComparatorControls(
                leftControl,
                rightControl)

            try verify(root: root, externalCommitBinding: uninterrupted)
            try verify(root: root, externalCommitBinding: resumed)
            return .init(
                weights: weights,
                firstMoments: firstMoments,
                secondMoments: secondMoments,
                uninterruptedControlState: leftControl,
                resumedControlState: rightControl,
                controlSemanticExact: control.exact,
                firstControlMismatchPath: control.firstMismatchPath)
        } catch let error as
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
        {
            throw error
        } catch {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .streamingComparisonFailed
        }
    }

    private static func compareSafetensorsStreaming(
        root: PrimeArtifactRoot,
        leftArtifact: PrimeArtifactBinding,
        rightArtifact: PrimeArtifactBinding,
        leftExpected: [TrajectoryExpectedSafetensorV1],
        rightExpected: [TrajectoryExpectedSafetensorV1],
        leftContainerExpected: [TrajectoryExpectedSafetensorV1],
        rightContainerExpected: [TrajectoryExpectedSafetensorV1],
        leftMetadata: [String: String],
        rightMetadata: [String: String],
        leftExpectedLogicalSHA256: [String: String],
        rightExpectedLogicalSHA256: [String: String]
    ) throws -> PrimeNativeDecoderNative300MTrajectoryStreamedCatalogV1 {
        try root.withVerifiedArtifactDescriptor(leftArtifact) {
            leftDescriptor in
            try root.withVerifiedArtifactDescriptor(rightArtifact) {
                rightDescriptor in
                let leftLayout = try trajectoryParseSafetensorsV1(
                    descriptor: leftDescriptor,
                    expected: leftContainerExpected,
                    expectedMetadata: leftMetadata)
                let rightLayout = try trajectoryParseSafetensorsV1(
                    descriptor: rightDescriptor,
                    expected: rightContainerExpected,
                    expectedMetadata: rightMetadata)
                return try streamCatalog(
                    leftDescriptor: leftDescriptor,
                    rightDescriptor: rightDescriptor,
                    leftLayout: leftLayout,
                    rightLayout: rightLayout,
                    leftExpected: leftExpected,
                    rightExpected: rightExpected,
                    leftExpectedLogicalSHA256:
                        leftExpectedLogicalSHA256,
                    rightExpectedLogicalSHA256:
                        rightExpectedLogicalSHA256)
            } materialize: { $0 }
        } materialize: { $0 }
    }

    private static func streamCatalog(
        leftDescriptor: Int32,
        rightDescriptor: Int32,
        leftLayout: TrajectorySafetensorLayoutV1,
        rightLayout: TrajectorySafetensorLayoutV1,
        leftExpected: [TrajectoryExpectedSafetensorV1],
        rightExpected: [TrajectoryExpectedSafetensorV1],
        leftExpectedLogicalSHA256: [String: String],
        rightExpectedLogicalSHA256: [String: String]
    ) throws -> PrimeNativeDecoderNative300MTrajectoryStreamedCatalogV1 {
        let leftSorted = leftExpected.sorted {
            rawUTF8Less($0.comparisonPath, $1.comparisonPath)
        }
        let rightSorted = rightExpected.sorted {
            rawUTF8Less($0.comparisonPath, $1.comparisonPath)
        }
        guard leftSorted.count == rightSorted.count,
              !leftSorted.isEmpty,
              Set(leftSorted.map(\.comparisonPath)).count == leftSorted.count,
              Set(rightSorted.map(\.comparisonPath)).count
                == rightSorted.count
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .streamingComparisonFailed
        }
        for (left, right) in zip(leftSorted, rightSorted) {
            guard left.comparisonPath == right.comparisonPath,
                  left.shape == right.shape,
                  left.elementCount == right.elementCount,
                  left.byteCount == right.byteCount
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .streamingComparisonFailed
            }
        }

        var structural = SHA256()
        var leftLogical = SHA256()
        var rightLogical = SHA256()
        var totalElements: UInt64 = 0
        var totalBytes: UInt64 = 0
        var firstMismatch: String?
        var records =
            [PrimeNativeDecoderNative300MTrajectoryStreamedTensorV1]()
        records.reserveCapacity(leftSorted.count)
        let chunkByteCount = 64 * 1024
        var leftBuffer = [UInt8](repeating: 0, count: chunkByteCount)
        var rightBuffer = [UInt8](repeating: 0, count: chunkByteCount)
        for (left, right) in zip(leftSorted, rightSorted) {
            guard let leftExtent = leftLayout.extents[left.storagePath],
                  let rightExtent = rightLayout.extents[right.storagePath],
                  leftExtent.byteCount == left.byteCount,
                  rightExtent.byteCount == right.byteCount
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .streamingComparisonFailed
            }
            let pathData = Data(left.comparisonPath.utf8)
            var structuralRecord = Data()
            trajectoryAppendBigEndianV1(
                UInt64(pathData.count), to: &structuralRecord)
            structuralRecord.append(pathData)
            trajectoryAppendBigEndianV1(
                UInt64(left.shape.count), to: &structuralRecord)
            for dimension in left.shape {
                guard dimension >= 0 else {
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .streamingComparisonFailed
                }
                trajectoryAppendBigEndianV1(
                    UInt64(dimension), to: &structuralRecord)
            }
            let dtypeData = Data("float32".utf8)
            trajectoryAppendBigEndianV1(
                UInt64(dtypeData.count), to: &structuralRecord)
            structuralRecord.append(dtypeData)
            trajectoryAppendBigEndianV1(
                left.elementCount, to: &structuralRecord)
            trajectoryAppendBigEndianV1(
                left.byteCount, to: &structuralRecord)
            structural.update(data: structuralRecord)
            var logicalPrefix = Data()
            trajectoryAppendBigEndianV1(
                UInt64(pathData.count), to: &logicalPrefix)
            logicalPrefix.append(pathData)
            leftLogical.update(data: logicalPrefix)
            rightLogical.update(data: logicalPrefix)

            var leftTensor = SHA256()
            var rightTensor = SHA256()
            var offset: UInt64 = 0
            var exact = true
            while offset < left.byteCount {
                let remaining = left.byteCount - offset
                let count = min(UInt64(chunkByteCount), remaining)
                let leftOffset = leftExtent.dataOffset
                    .addingReportingOverflow(offset)
                let rightOffset = rightExtent.dataOffset
                    .addingReportingOverflow(offset)
                guard !leftOffset.overflow, !rightOffset.overflow else {
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .streamingComparisonFailed
                }
                try leftBuffer.withUnsafeMutableBytes { buffer in
                    try trajectoryPreadExactlyV1(
                        leftDescriptor,
                        offset: leftOffset.partialValue,
                        buffer: UnsafeMutableRawBufferPointer(
                            start: buffer.baseAddress,
                            count: Int(count)))
                }
                try rightBuffer.withUnsafeMutableBytes { buffer in
                    try trajectoryPreadExactlyV1(
                        rightDescriptor,
                        offset: rightOffset.partialValue,
                        buffer: UnsafeMutableRawBufferPointer(
                            start: buffer.baseAddress,
                            count: Int(count)))
                }
                let leftData = Data(leftBuffer.prefix(Int(count)))
                let rightData = Data(rightBuffer.prefix(Int(count)))
                leftTensor.update(data: leftData)
                rightTensor.update(data: rightData)
                leftLogical.update(data: leftData)
                rightLogical.update(data: rightData)
                exact = exact && leftData == rightData
                offset += count
            }
            let leftSHA = trajectoryDigestHexV1(leftTensor.finalize())
            let rightSHA = trajectoryDigestHexV1(rightTensor.finalize())
            if let expected = leftExpectedLogicalSHA256[left.storagePath],
               expected != leftSHA
            {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .streamingComparisonFailed
            }
            if let expected = rightExpectedLogicalSHA256[right.storagePath],
               expected != rightSHA
            {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .streamingComparisonFailed
            }
            if !exact, firstMismatch == nil {
                firstMismatch = left.comparisonPath
            }
            let elementSum = totalElements.addingReportingOverflow(
                left.elementCount)
            let byteSum = totalBytes.addingReportingOverflow(left.byteCount)
            guard !elementSum.overflow, !byteSum.overflow else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .streamingComparisonFailed
            }
            totalElements = elementSum.partialValue
            totalBytes = byteSum.partialValue
            records.append(.init(
                path: left.comparisonPath,
                shape: left.shape,
                dtype: "float32",
                elementCount: left.elementCount,
                logicalByteCount: left.byteCount,
                leftLogicalSHA256: leftSHA,
                rightLogicalSHA256: rightSHA,
                exact: exact))
        }
        return .init(
            tensors: records,
            structuralSHA256: trajectoryDigestHexV1(structural.finalize()),
            leftLogicalSHA256: trajectoryDigestHexV1(
                leftLogical.finalize()),
            rightLogicalSHA256: trajectoryDigestHexV1(
                rightLogical.finalize()),
            totalElementCount: totalElements,
            totalLogicalByteCount: totalBytes,
            firstMismatchPath: firstMismatch)
    }

    // Scientific branch roles are written by trajectoryComparatorControl;
    // they are distinct from the directories used to retain each set.
    static func compareComparatorControls(
        _ left: Data,
        _ right: Data
    ) throws -> (exact: Bool, firstMismatchPath: String?) {
        let required =
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                .frozenV1.checkpoint.comparatorControlRequiredFields
        try validateCanonicalControl(left)
        try validateCanonicalControl(right)
        guard let leftObject = try JSONSerialization.jsonObject(with: left)
                as? [String: Any],
              let rightObject = try JSONSerialization.jsonObject(with: right)
                as? [String: Any],
              Set(leftObject.keys) == Set(required),
              Set(rightObject.keys) == Set(required),
              leftObject["branch_role"] as? String
                == "uninterrupted_n_plus_1",
              rightObject["branch_role"] as? String
                == "resumed_n_plus_1"
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .streamingComparisonFailed
        }
        for field in required.filter({ $0 != "branch_role" }).sorted(
            by: rawUTF8Less)
        {
            guard let leftValue = leftObject[field],
                  let rightValue = rightObject[field]
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .streamingComparisonFailed
            }
            let leftField = try JSONSerialization.data(
                withJSONObject: [leftValue],
                options: [.sortedKeys, .withoutEscapingSlashes])
            let rightField = try JSONSerialization.data(
                withJSONObject: [rightValue],
                options: [.sortedKeys, .withoutEscapingSlashes])
            if leftField != rightField {
                return (false, field)
            }
        }
        return (true, nil)
    }

    /// Deletes only the exact, externally bound leaves produced by this run.
    /// The root and every role directory are descriptor-bound, inventories
    /// must be exact before mutation, every file is rehashed through its held
    /// descriptor, and removal uses `unlinkat`/`AT_REMOVEDIR` without any
    /// recursive traversal.
    public static func cleanupKnownPublishedSets(
        root: PrimeArtifactRoot,
        bindings:
            [PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1],
        quarantines:
            [PrimeNativeDecoderNative300MTrajectoryQuarantineV1] = []
    ) throws -> PrimeNativeDecoderNative300MTrajectoryCleanupV1 {
        do {
            try root.requirePrivateRootMode()
            let roles = bindings.map(\.setRole)
                + quarantines.map(\.setRole)
            guard Set(roles).count == roles.count,
                  bindings.allSatisfy({ binding in
                      binding.directory == binding.setRole.rawValue
                          && binding.orderedLeafBindings.count == 4
                  }),
                  quarantines.allSatisfy({ quarantine in
                      !quarantine.finalCommitPublished
                          && quarantine.directory
                            == quarantine.setRole.rawValue
                          && !quarantine.publishedPrecommitLeafBindings.isEmpty
                          && quarantine.publishedPrecommitLeafBindings.count < 4
                          && quarantine.knownLeafRelativePaths == [
                              path(quarantine.directory, weightsFileName),
                              path(
                                  quarantine.directory,
                                  optimizerMomentsFileName),
                              path(
                                  quarantine.directory,
                                  controlStateFileName),
                              path(
                                  quarantine.directory,
                                  commitManifestFileName),
                          ]
                          && quarantine.publishedPrecommitLeafBindings
                            .map(\.role)
                            == Array(
                                PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1
                                    .allCases.prefix(
                                        quarantine
                                            .publishedPrecommitLeafBindings
                                            .count))
                          && quarantine.publishedPrecommitLeafBindings
                            .map(\.publicationOrdinal)
                            == Array(
                                1 ... quarantine
                                    .publishedPrecommitLeafBindings.count)
                          && quarantine.publishedPrecommitLeafBindings
                            .enumerated().allSatisfy { index, leaf in
                                leaf.artifact.relativePath
                                    == quarantine.knownLeafRelativePaths[index]
                                    && leaf.artifact.purpose == .immutableData
                                    && isLowercaseSHA256(leaf.artifact.sha256)
                            }
                  })
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .cleanupFailed
            }
            for binding in bindings {
                try verify(root: root, externalCommitBinding: binding)
            }
            let rootDescriptor = root.directoryURL.path.withCString {
                Darwin.open(
                    $0,
                    O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
            }
            guard rootDescriptor >= 0 else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .cleanupFailed
            }
            defer { _ = Darwin.close(rootDescriptor) }
            let identity = try root.verifiedRootIdentity()
            var rootStatus = stat()
            guard fstat(rootDescriptor, &rootStatus) == 0,
                  UInt64(bitPattern: Int64(rootStatus.st_dev))
                    == identity.deviceID,
                  UInt64(rootStatus.st_ino) == identity.inode,
                  rootStatus.st_uid == identity.ownerUserID,
                  rootStatus.st_gid == identity.ownerGroupID,
                  rootStatus.st_mode & mode_t(0o777) == mode_t(0o700)
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .cleanupFailed
            }
            let expectedDirectories = Set(
                bindings.map(\.directory) + quarantines.map(\.directory))
            let rootNames = try enumerateDescriptorNames(rootDescriptor)
            guard Set(rootNames) == expectedDirectories else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .cleanupFailed
            }

            let cleanupEntries: [(
                directory: String,
                leaves: [PrimeNativeDecoderTrajectoryLeafBindingV1],
                comparator: Bool
            )] = bindings.map {
                ($0.directory, $0.orderedLeafBindings, !$0.loadAuthoritative)
            } + quarantines.map {
                ($0.directory, $0.publishedPrecommitLeafBindings,
                 !$0.setRole.loadAuthoritative)
            }
            var deletedLeaves = 0
            for entry in cleanupEntries.sorted(by: {
                rawUTF8Less($0.directory, $1.directory)
            }) {
                let directoryDescriptor = entry.directory.withCString {
                    Darwin.openat(
                        rootDescriptor,
                        $0,
                        O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
                }
                guard directoryDescriptor >= 0 else {
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .cleanupFailed
                }
                defer { _ = Darwin.close(directoryDescriptor) }
                var directoryStatus = stat()
                guard fstat(directoryDescriptor, &directoryStatus) == 0,
                      directoryStatus.st_uid == geteuid(),
                      directoryStatus.st_mode & mode_t(S_IFMT)
                        == mode_t(S_IFDIR),
                      directoryStatus.st_mode & mode_t(0o777)
                        == mode_t(0o700)
                else {
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .cleanupFailed
                }
                let expectedFileNames = entry.leaves.map {
                    URL(fileURLWithPath: $0.artifact.relativePath)
                        .lastPathComponent
                }
                guard Set(try enumerateDescriptorNames(directoryDescriptor))
                        == Set(expectedFileNames)
                else {
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .cleanupFailed
                }
                for leaf in entry.leaves.sorted(by: {
                    $0.publicationOrdinal < $1.publicationOrdinal
                }) {
                    _ = try root.verify(leaf.artifact)
                    let fileName = URL(
                        fileURLWithPath: leaf.artifact.relativePath)
                        .lastPathComponent
                    let fileDescriptor = fileName.withCString {
                        Darwin.openat(
                            directoryDescriptor,
                            $0,
                            O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
                    }
                    guard fileDescriptor >= 0 else {
                        throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                            .cleanupFailed
                    }
                    var heldStatus = stat()
                    let statusOK = fstat(fileDescriptor, &heldStatus) == 0
                        && heldStatus.st_mode & mode_t(S_IFMT)
                            == mode_t(S_IFREG)
                        && heldStatus.st_uid == geteuid()
                        && heldStatus.st_size >= 0
                        && UInt64(heldStatus.st_size)
                            == leaf.artifact.byteCount
                    let heldSHA = statusOK
                        ? try descriptorSHA256(
                            fileDescriptor,
                            byteCount: leaf.artifact.byteCount)
                        : ""
                    var namedStatus = stat()
                    let namedOK = fileName.withCString {
                        fstatat(
                            directoryDescriptor,
                            $0,
                            &namedStatus,
                            AT_SYMLINK_NOFOLLOW)
                    } == 0
                    guard statusOK,
                          heldSHA == leaf.artifact.sha256,
                          namedOK,
                          namedStatus.st_dev == heldStatus.st_dev,
                          namedStatus.st_ino == heldStatus.st_ino,
                          namedStatus.st_size == heldStatus.st_size
                    else {
                        _ = Darwin.close(fileDescriptor)
                        throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                            .cleanupFailed
                    }
                    let unlinked = fileName.withCString {
                        Darwin.unlinkat(directoryDescriptor, $0, 0)
                    }
                    _ = Darwin.close(fileDescriptor)
                    guard unlinked == 0 else {
                        throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                            .cleanupFailed
                    }
                    deletedLeaves += 1
                }
                guard try enumerateDescriptorNames(directoryDescriptor).isEmpty,
                      entry.directory.withCString({
                          Darwin.unlinkat(
                              rootDescriptor,
                              $0,
                              AT_REMOVEDIR)
                      }) == 0
                else {
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .cleanupFailed
                }
            }
            guard try enumerateDescriptorNames(rootDescriptor).isEmpty else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .cleanupFailed
            }
            try root.requireEmpty()
            return .init(
                knownLeafCount: cleanupEntries.reduce(0) {
                    $0 + $1.leaves.count
                },
                deletedLeafCount: deletedLeaves,
                deletedPrivateComparatorCount: cleanupEntries.filter(
                    \.comparator).count,
                unknownInventoryCount: 0,
                postCleanupInventoryEmpty: true,
                absenceProved: true,
                recursiveCleanupUsed: false)
        } catch let error as
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
        {
            throw error
        } catch {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
    }

    private static func enumerateDescriptorNames(
        _ descriptor: Int32
    ) throws -> [String] {
        let duplicate = fcntl(descriptor, F_DUPFD_CLOEXEC, 0)
        guard duplicate >= 0, lseek(duplicate, 0, SEEK_SET) >= 0,
              let directory = fdopendir(duplicate)
        else {
            if duplicate >= 0 { _ = Darwin.close(duplicate) }
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        defer { _ = closedir(directory) }
        var names = [String]()
        errno = 0
        while let entry = readdir(directory) {
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(
                    to: CChar.self,
                    capacity: Int(MAXNAMLEN) + 1
                ) { String(cString: $0) }
            }
            if name != ".", name != ".." { names.append(name) }
            errno = 0
        }
        guard errno == 0 else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        return names.sorted(by: rawUTF8Less)
    }

    private static func descriptorSHA256(
        _ descriptor: Int32,
        byteCount: UInt64
    ) throws -> String {
        var hasher = SHA256()
        var buffer = [UInt8](repeating: 0, count: 64 * 1024)
        var offset: UInt64 = 0
        while offset < byteCount {
            let count = Int(min(UInt64(buffer.count), byteCount - offset))
            try buffer.withUnsafeMutableBytes {
                try trajectoryPreadExactlyV1(
                    descriptor,
                    offset: offset,
                    buffer: UnsafeMutableRawBufferPointer(
                        start: $0.baseAddress,
                        count: count))
            }
            hasher.update(data: Data(buffer.prefix(count)))
            offset += UInt64(count)
        }
        return trajectoryDigestHexV1(hasher.finalize())
    }

    public static func validateExternalBinding(
        _ binding:
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    ) throws {
        try validateDirectory(binding.directory, role: binding.setRole)
        let leaves = binding.orderedLeafBindings
        guard binding.schemaVersion == 1,
              binding.schemaID == externalCommitBindingSchemaID,
              binding.loadAuthoritative
                == binding.setRole.loadAuthoritative,
              leaves.map(\.role)
                == PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1.allCases,
              leaves.map(\.publicationOrdinal) == [1, 2, 3, 4],
              leaves.map(\.artifact.relativePath) == [
                  path(binding.directory, weightsFileName),
                  path(binding.directory, optimizerMomentsFileName),
                  path(binding.directory, controlStateFileName),
                  path(binding.directory, commitManifestFileName),
              ],
              leaves.allSatisfy({
                  $0.artifact.purpose == .immutableData
                      && isLowercaseSHA256($0.artifact.sha256)
              }),
              binding.weightsExternalBinding.artifactBinding
                == leaves[0].artifact,
              binding.optimizerMomentManifest.schemaVersion == 1,
              binding.optimizerMomentManifest.schemaID
                == momentManifestSchemaID,
              binding.optimizerMomentManifest.encoding == momentEncoding,
              binding.optimizerMomentManifest.firstMomentPrefix
                == firstMomentStoragePrefix,
              binding.optimizerMomentManifest.secondMomentPrefix
                == secondMomentStoragePrefix,
              binding.optimizerMomentManifest.tensors.count
                == expectedMomentTensorCount,
              binding.controlStateCanonicalByteCount > 1,
              binding.controlStateCanonicalByteCount
                == leaves[2].artifact.byteCount,
              binding.controlStateCanonicalSHA256 == leaves[2].artifact.sha256,
              binding.commitManifestCanonicalByteCount > 1,
              binding.commitManifestCanonicalByteCount
                == leaves[3].artifact.byteCount,
              binding.commitManifestCanonicalSHA256
                == leaves[3].artifact.sha256,
              isLowercaseSHA256(binding.controlStateCanonicalSHA256),
              isLowercaseSHA256(binding.commitManifestCanonicalSHA256)
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidExternalCommitBinding
        }
        do {
            try binding.weightsExternalBinding.validate()
            let catalogBytes = try PrimeCanonicalJSON.encode(
                binding.optimizerMomentManifest.tensors)
            guard PrimeSHA256.hexDigest(of: catalogBytes)
                    == binding.optimizerMomentManifest
                        .tensorCatalogCanonicalSHA256
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .invalidExternalCommitBinding
            }
            try validateManifestRolePairs(
                binding.optimizerMomentManifest)
        } catch let error as
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
        {
            throw error
        } catch {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidExternalCommitBinding
        }
    }

    private static func validateCommit(
        root: PrimeArtifactRoot,
        binding:
            PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    ) throws {
        let data = try root.readVerified(
            binding.orderedLeafBindings[3].artifact,
            maximumByteCount: maximumControlOrCommitByteCount)
        guard UInt64(data.count)
                == binding.commitManifestCanonicalByteCount,
              PrimeSHA256.hexDigest(of: data)
                == binding.commitManifestCanonicalSHA256
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidCommitManifest
        }
        let manifest = try PrimeCanonicalJSON.decode(
            PrimeNativeDecoderNative300MTrajectoryCommitManifestV1.self,
            from: data,
            artifact: binding.orderedLeafBindings[3].artifact.relativePath)
        guard manifest.schemaVersion == 1,
              manifest.schemaID == checkpointSchemaID,
              manifest.stateScope == stateScope,
              manifest.setRole == binding.setRole,
              manifest.loadAuthoritative == binding.loadAuthoritative,
              manifest.precommitLeafBindings
                == Array(binding.orderedLeafBindings.prefix(3)),
              manifest.weightsExternalBinding
                == binding.weightsExternalBinding,
              manifest.optimizerMomentManifest
                == binding.optimizerMomentManifest,
              manifest.controlStateCanonicalByteCount
                == binding.controlStateCanonicalByteCount,
              manifest.controlStateCanonicalSHA256
                == binding.controlStateCanonicalSHA256,
              manifest.finalCommitManifestIsExclusiveCommitPoint,
              !manifest.partialPrecommitLeavesAreAuthoritative,
              manifest.loadRequiresExternallySuppliedExactCommitBinding
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidCommitManifest
        }
    }

    private static func publishMoments(
        _ arrays: [String: MLXArray],
        manifest: PrimeNativeDecoderNative300MTrajectoryMomentManifestV1,
        root: PrimeArtifactRoot,
        relativePath: String
    ) throws -> PrimeArtifactBinding {
        let manifestData = try PrimeCanonicalJSON.encode(manifest)
        guard let manifestText = String(
                data: manifestData,
                encoding: .utf8)
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidMomentCatalog
        }
        let metadata = [
            momentManifestMetadataKey: manifestText,
            momentManifestSHA256MetadataKey:
                PrimeSHA256.hexDigest(of: manifestData),
        ]
        return try root.publishGeneratedFile(
            at: relativePath,
            purpose: .immutableData,
            maximumByteCount: maximumMomentContainerByteCount
        ) { descriptor in
            try MLX.save(
                arrays: arrays,
                metadata: metadata,
                fileDescriptor: descriptor,
                maximumBytes: maximumMomentContainerByteCount)
        }
    }

    private static func makeMomentManifest(
        _ arrays: [String: MLXArray],
        matching modelCatalog: [String: MLXArray]
    ) throws -> PrimeNativeDecoderNative300MTrajectoryMomentManifestV1 {
        guard arrays.count == expectedMomentTensorCount else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidMomentCatalog
        }
        let sortedKeys = arrays.keys.sorted(by: rawUTF8Less)
        let firstPaths = Set(sortedKeys.compactMap { key -> String? in
            guard key.hasPrefix(firstMomentStoragePrefix) else {
                return nil
            }
            return String(key.dropFirst(firstMomentStoragePrefix.count))
        })
        let secondPaths = Set(sortedKeys.compactMap { key -> String? in
            guard key.hasPrefix(secondMomentStoragePrefix) else {
                return nil
            }
            return String(key.dropFirst(secondMomentStoragePrefix.count))
        })
        let modelPaths = Set(modelCatalog.keys)
        guard Set(sortedKeys).count == expectedMomentTensorCount,
              sortedKeys.filter({
                  $0.hasPrefix(firstMomentStoragePrefix)
              }).count == expectedParameterPathCount,
              sortedKeys.filter({
                  $0.hasPrefix(secondMomentStoragePrefix)
              }).count == expectedParameterPathCount,
              firstPaths == secondPaths,
              firstPaths == modelPaths
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidMomentCatalog
        }
        var strippedPaths = Set<String>()
        var tensors =
            [PrimeNativeDecoderNative300MTrajectoryMomentTensorV1]()
        tensors.reserveCapacity(expectedMomentTensorCount)
        for key in sortedKeys {
            guard key.utf8.count <= 1_024,
                  key.utf8.allSatisfy({ $0 >= 0x21 && $0 <= 0x7e }),
                  let array = arrays[key],
                  array.dtype == .float32,
                  array.size > 0,
                  array.itemSize == 4,
                  array.nbytes == array.size * array.itemSize
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .invalidMomentCatalog
            }
            let prefix = key.hasPrefix(firstMomentStoragePrefix)
                ? firstMomentStoragePrefix : secondMomentStoragePrefix
            let parameterPath = String(key.dropFirst(prefix.count))
            guard !parameterPath.isEmpty,
                  strippedPaths.insert("\(prefix)\(parameterPath)").inserted,
                  let parameter = modelCatalog[parameterPath],
                  array.shape == parameter.shape,
                  array.dtype == parameter.dtype,
                  array.size == parameter.size,
                  array.nbytes == parameter.nbytes
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .invalidMomentCatalog
            }
            tensors.append(.init(
                storageKey: key,
                shape: array.shape,
                dtype: "float32",
                elementCount: UInt64(array.size),
                logicalByteCount: UInt64(array.nbytes)))
        }
        let catalogData = try PrimeCanonicalJSON.encode(tensors)
        return .init(
            schemaVersion: 1,
            schemaID: momentManifestSchemaID,
            encoding: momentEncoding,
            firstMomentPrefix: firstMomentStoragePrefix,
            secondMomentPrefix: secondMomentStoragePrefix,
            tensors: tensors,
            tensorCatalogCanonicalSHA256:
                PrimeSHA256.hexDigest(of: catalogData))
    }

    private static func validateLoadedMoments(
        arrays: [String: MLXArray],
        metadata: [String: String],
        expected: PrimeNativeDecoderNative300MTrajectoryMomentManifestV1,
        matching modelCatalog: [String: MLXArray]
    ) throws {
        guard Set(metadata.keys) == [
                  momentManifestMetadataKey,
                  momentManifestSHA256MetadataKey,
              ],
              let manifestText = metadata[momentManifestMetadataKey],
              let manifestData = manifestText.data(using: .utf8),
              metadata[momentManifestSHA256MetadataKey]
                == PrimeSHA256.hexDigest(of: manifestData),
              let decoded = try? PrimeCanonicalJSON.decode(
                  PrimeNativeDecoderNative300MTrajectoryMomentManifestV1.self,
                  from: manifestData,
                  artifact: "optimizer_moments.safetensors:metadata"),
              decoded == expected
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidMomentCatalog
        }
        let observed = try makeMomentManifest(
            arrays,
            matching: modelCatalog)
        guard observed == expected else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidMomentCatalog
        }
    }

    private static func validateCanonicalControl(_ data: Data) throws {
        guard !data.isEmpty,
              UInt64(data.count) <= maximumControlOrCommitByteCount,
              let object = try? JSONSerialization.jsonObject(with: data),
              JSONSerialization.isValidJSONObject(object),
              let canonical = try? JSONSerialization.data(
                  withJSONObject: object,
                  options: [.sortedKeys, .withoutEscapingSlashes]),
              canonical == data
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidControlState
        }
    }

    private static func validateDirectory(
        _ directory: String,
        role: PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
    ) throws {
        guard directory == role.rawValue,
              directory.utf8.count <= 96,
              directory.utf8.allSatisfy({ byte in
                  (byte >= 48 && byte <= 57)
                      || (byte >= 97 && byte <= 122)
                      || byte == 95
              })
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidDirectory
        }
    }

    private static func exactModelCatalog(
        _ model: PrimeNativeGQADecoder
    ) throws -> [String: MLXArray] {
        var result = [String: MLXArray]()
        for (parameterPath, array) in model.parameters().flattened() {
            guard result.updateValue(array, forKey: parameterPath) == nil,
                  !parameterPath.isEmpty,
                  array.dtype == .float32,
                  array.size > 0,
                  array.itemSize == 4,
                  array.nbytes == array.size * array.itemSize
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .invalidMomentCatalog
            }
        }
        guard result.count == expectedParameterPathCount else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidMomentCatalog
        }
        return result
    }

    private static func validateManifestRolePairs(
        _ manifest:
            PrimeNativeDecoderNative300MTrajectoryMomentManifestV1
    ) throws {
        let byKey = Dictionary(
            uniqueKeysWithValues: manifest.tensors.map {
                ($0.storageKey, $0)
            })
        guard byKey.count == expectedMomentTensorCount else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidExternalCommitBinding
        }
        var firstPaths = Set<String>()
        var secondPaths = Set<String>()
        for tensor in manifest.tensors {
            if tensor.storageKey.hasPrefix(firstMomentStoragePrefix) {
                firstPaths.insert(String(tensor.storageKey.dropFirst(
                    firstMomentStoragePrefix.count)))
            } else if tensor.storageKey.hasPrefix(secondMomentStoragePrefix) {
                secondPaths.insert(String(tensor.storageKey.dropFirst(
                    secondMomentStoragePrefix.count)))
            } else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .invalidExternalCommitBinding
            }
        }
        guard firstPaths.count == expectedParameterPathCount,
              firstPaths == secondPaths
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .invalidExternalCommitBinding
        }
        for parameterPath in firstPaths {
            guard let first = byKey[firstMomentStoragePrefix + parameterPath],
                  let second = byKey[
                      secondMomentStoragePrefix + parameterPath],
                  first.shape == second.shape,
                  first.dtype == "float32",
                  second.dtype == "float32",
                  first.elementCount == second.elementCount,
                  first.logicalByteCount == second.logicalByteCount,
                  first.elementCount > 0,
                  first.logicalByteCount == first.elementCount * 4
            else {
                throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                    .invalidExternalCommitBinding
            }
        }
    }

    private static func partialPublication(
        directory: String,
        role: PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1,
        leaves: [PrimeNativeDecoderTrajectoryLeafBindingV1]
    ) -> PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error {
        .partialPublication(.init(
            directory: directory,
            setRole: role,
            publishedPrecommitLeafBindings: leaves,
            knownLeafRelativePaths: knownLeafRelativePaths(for: role),
            finalCommitPublished: false))
    }

    /// Recovers only cleanup evidence for the next deterministic precommit
    /// leaf when the durable publisher may have renamed the final path before
    /// throwing.  Exact absence preserves the prior prefix; exact safe
    /// presence appends one descriptor-bound leaf.  Any unknown name,
    /// nonexact file, or unstable observation throws so the caller can
    /// suppress quarantine evidence and take the frozen no-public path.
    private static func recoverCleanupLeafAfterPublicationFailure(
        root: PrimeArtifactRoot,
        directory: String,
        setRole: PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1,
        leafRole: PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1,
        publicationOrdinal: Int,
        priorLeaves: [PrimeNativeDecoderTrajectoryLeafBindingV1],
        maximumByteCount: UInt64
    ) throws -> PrimeNativeDecoderTrajectoryLeafBindingV1? {
        let orderedRoles =
            PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1.allCases
        try validateDirectory(directory, role: setRole)
        guard publicationOrdinal >= 1,
              publicationOrdinal <= orderedRoles.count,
              leafRole == orderedRoles[publicationOrdinal - 1],
              priorLeaves.map(\.role)
                == Array(orderedRoles.prefix(publicationOrdinal - 1)),
              priorLeaves.map(\.publicationOrdinal)
                == Array(1 ..< publicationOrdinal),
              maximumByteCount > 0
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        let fileName: String
        switch leafRole {
        case .weightsV2: fileName = weightsFileName
        case .optimizerMoments: fileName = optimizerMomentsFileName
        case .controlStateManifest: fileName = controlStateFileName
        case .commitManifest: fileName = commitManifestFileName
        }
        let relativePath = path(directory, fileName)
        let expectedPriorNames = priorLeaves.map {
            URL(fileURLWithPath: $0.artifact.relativePath).lastPathComponent
        }
        guard priorLeaves.enumerated().allSatisfy({ index, leaf in
            leaf.artifact.relativePath
                == path(directory, [
                    weightsFileName, optimizerMomentsFileName,
                    controlStateFileName, commitManifestFileName,
                ][index])
                && leaf.artifact.purpose == .immutableData
        }) else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }

        try root.requirePrivateRootMode()
        let rootDescriptor = root.directoryURL.path.withCString {
            Darwin.open(
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        }
        guard rootDescriptor >= 0 else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        defer { _ = Darwin.close(rootDescriptor) }
        let rootIdentity = try root.verifiedRootIdentity()
        var rootStatus = stat()
        guard fstat(rootDescriptor, &rootStatus) == 0,
              UInt64(bitPattern: Int64(rootStatus.st_dev))
                == rootIdentity.deviceID,
              UInt64(rootStatus.st_ino) == rootIdentity.inode,
              rootStatus.st_uid == rootIdentity.ownerUserID,
              rootStatus.st_gid == rootIdentity.ownerGroupID,
              rootStatus.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              rootStatus.st_mode & mode_t(0o777) == mode_t(0o700)
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        let directoryDescriptor = directory.withCString {
            Darwin.openat(
                rootDescriptor,
                $0,
                O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        }
        guard directoryDescriptor >= 0 else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        defer { _ = Darwin.close(directoryDescriptor) }
        var directoryBefore = stat()
        guard fstat(directoryDescriptor, &directoryBefore) == 0,
              directoryBefore.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              directoryBefore.st_mode & mode_t(0o777) == mode_t(0o700),
              directoryBefore.st_uid == rootIdentity.ownerUserID,
              directoryBefore.st_gid == rootIdentity.ownerGroupID
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        let beforeNames = try enumerateDescriptorNames(directoryDescriptor)
        if beforeNames == expectedPriorNames.sorted(by: rawUTF8Less) {
            try root.requireAbsent(at: relativePath)
            return nil
        }
        let expectedPresentNames = (expectedPriorNames + [fileName]).sorted(
            by: rawUTF8Less)
        guard beforeNames == expectedPresentNames else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }

        let fileDescriptor = fileName.withCString {
            Darwin.openat(
                directoryDescriptor,
                $0,
                O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        }
        guard fileDescriptor >= 0 else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        defer { _ = Darwin.close(fileDescriptor) }
        var fileBefore = stat()
        guard fstat(fileDescriptor, &fileBefore) == 0,
              fileBefore.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              fileBefore.st_mode & mode_t(0o7777) == mode_t(0o444),
              fileBefore.st_uid == rootIdentity.ownerUserID,
              fileBefore.st_gid == rootIdentity.ownerGroupID,
              fileBefore.st_nlink == 1,
              fileBefore.st_size > 0,
              UInt64(fileBefore.st_size) <= maximumByteCount
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        let byteCount = UInt64(fileBefore.st_size)
        let binding = PrimeArtifactBinding(
            relativePath: relativePath,
            sha256: try descriptorSHA256(
                fileDescriptor,
                byteCount: byteCount),
            byteCount: byteCount,
            purpose: .immutableData)
        _ = try root.verify(binding)

        var fileAfter = stat()
        var namedAfter = stat()
        let namedStatus = fileName.withCString {
            fstatat(
                directoryDescriptor,
                $0,
                &namedAfter,
                AT_SYMLINK_NOFOLLOW)
        }
        var directoryAfter = stat()
        guard fstat(fileDescriptor, &fileAfter) == 0,
              namedStatus == 0,
              fstat(directoryDescriptor, &directoryAfter) == 0,
              fileBefore.st_dev == fileAfter.st_dev,
              fileBefore.st_dev == namedAfter.st_dev,
              fileBefore.st_ino == fileAfter.st_ino,
              fileBefore.st_ino == namedAfter.st_ino,
              fileBefore.st_uid == fileAfter.st_uid,
              fileBefore.st_uid == namedAfter.st_uid,
              fileBefore.st_gid == fileAfter.st_gid,
              fileBefore.st_gid == namedAfter.st_gid,
              fileBefore.st_mode == fileAfter.st_mode,
              fileBefore.st_mode == namedAfter.st_mode,
              fileBefore.st_nlink == fileAfter.st_nlink,
              fileBefore.st_nlink == namedAfter.st_nlink,
              fileBefore.st_size == fileAfter.st_size,
              fileBefore.st_size == namedAfter.st_size,
              directoryBefore.st_dev == directoryAfter.st_dev,
              directoryBefore.st_ino == directoryAfter.st_ino,
              directoryBefore.st_uid == directoryAfter.st_uid,
              directoryBefore.st_gid == directoryAfter.st_gid,
              directoryBefore.st_mode == directoryAfter.st_mode,
              try enumerateDescriptorNames(directoryDescriptor)
                == expectedPresentNames,
              try root.verifiedRootIdentity() == rootIdentity
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                .cleanupFailed
        }
        return .init(
            role: leafRole,
            publicationOrdinal: publicationOrdinal,
            artifact: binding)
    }

    public static func knownLeafRelativePaths(
        for role:
            PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
    ) -> [String] {
        [
            weightsFileName, optimizerMomentsFileName,
            controlStateFileName, commitManifestFileName,
        ].map { path(role.rawValue, $0) }
    }

    private static func rawUTF8Less(_ lhs: String, _ rhs: String) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
    }

    private static func path(_ directory: String, _ file: String) -> String {
        "\(directory)/\(file)"
    }

    private static func isLowercaseSHA256(_ value: String) -> Bool {
        value.utf8.count == 64 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    private static func writeAll(
        _ data: Data,
        descriptor: Int32
    ) throws {
        try data.withUnsafeBytes { bytes in
            guard let base = bytes.baseAddress else { return }
            var offset = 0
            while offset < bytes.count {
                let count = Darwin.write(
                    descriptor,
                    base.advanced(by: offset),
                    bytes.count - offset)
                if count < 0, errno == EINTR { continue }
                guard count > 0 else {
                    throw PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
                        .publicationFailed
                }
                offset += count
            }
        }
    }
}
