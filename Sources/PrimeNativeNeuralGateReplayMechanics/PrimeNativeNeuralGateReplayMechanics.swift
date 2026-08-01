import CryptoKit
import Foundation

public enum PrimeNativeNeuralGateReplayMechanicsError:
    Error,
    Equatable,
    Sendable
{
    case emptyRecordSet
    case invalidDecodeLimits
    case invalidUTF8Record(index: Int)
    case recordCountLimitExceeded
    case recordByteLimitExceeded(index: Int)
    case aggregateByteLimitExceeded
    case invalidGlobalMagic
    case invalidChunkMagic
    case truncatedInput
    case trailingInput
    case integerOverflow
    case noncanonicalRecordOrder
    case emptyChunk
    case chunkRecordCountLimitExceeded
    case chunkOrdinalMismatch(
        expected: UInt32,
        observed: UInt32
    )
    case chunkPartitionMismatch
    case fingerprintMismatch
    case staleFingerprintCache
    case invalidManifest
    case invalidFingerprintObservation
    case invalidPromptBindingSHA256
    case incrementalReaderNotReusable
    case declaredRecordCountMismatch(
        expected: UInt64,
        observed: UInt64
    )
}

/// Target-free correlation identity derived only from the public schedule
/// index and the prompt-only PRIMECPI2 binding.
///
/// This value defines how a future supervisor-provided schedule capability can
/// let disjoint raw/sidecar and outer-evaluation producers agree on row
/// identity without sharing row IDs, split/family metadata, expected
/// completions, or another producer-controlled correlation channel. This
/// primitive does not authorize either producer to read a prompt artifact.
public enum PrimeNativeNeuralGateReplayCorrelationIdentity {
    public static let magic = "PRIMECOR1"
    public static let serializationContractID =
        "primecor1_then_uint32_big_endian_execution_index_then_raw_primecpi2_prompt_binding_sha256_v1"

    public static func derive(
        executionIndex: UInt32,
        primeCPI2PromptBindingSHA256: String
    ) throws -> String {
        guard primeCPI2PromptBindingSHA256.utf8.count == 64
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .invalidPromptBindingSHA256
        }
        let hexadecimal = Array(
            primeCPI2PromptBindingSHA256.utf8
        )
        var input = Data(magic.utf8)
        var bigEndianIndex = executionIndex.bigEndian
        withUnsafeBytes(of: &bigEndianIndex) {
            input.append(contentsOf: $0)
        }
        for index in stride(
            from: 0,
            to: hexadecimal.count,
            by: 2
        ) {
            guard let high = hexadecimalValue(
                hexadecimal[index]
            ),
                  let low = hexadecimalValue(
                      hexadecimal[index + 1]
                  )
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .invalidPromptBindingSHA256
            }
            input.append(high << 4 | low)
        }
        return PrimeNativeNeuralGateInvariantCodec
            .sha256(input)
    }

    private static func hexadecimalValue(
        _ value: UInt8
    ) -> UInt8? {
        switch value {
        case 48 ... 57:
            return value - 48
        case 97 ... 102:
            return value - 87
        default:
            return nil
        }
    }
}

/// Resource bounds for decoding untrusted Stage-B semantic payloads.
///
/// These limits are operational containment, not semantic evidence. The
/// canonical Stage-B format and fingerprints do not change when a stricter
/// decoder limit is used.
public struct PrimeNativeNeuralGateReplayDecodeLimits:
    Equatable,
    Sendable
{
    public static let stageB = Self(
        maximumRecordCount: 1_000_000,
        maximumRecordByteCount:
            16 * 1_024 * 1_024,
        maximumAggregateRecordBytes:
            1_024 * 1_024 * 1_024
    )

    public let maximumRecordCount: Int
    public let maximumRecordByteCount: Int
    public let maximumAggregateRecordBytes:
        Int

    init(
        maximumRecordCount: Int,
        maximumRecordByteCount: Int,
        maximumAggregateRecordBytes: Int
    ) {
        self.maximumRecordCount =
            maximumRecordCount
        self.maximumRecordByteCount =
            maximumRecordByteCount
        self.maximumAggregateRecordBytes =
            maximumAggregateRecordBytes
    }

    public static func bounded(
        maximumRecordCount: Int,
        maximumRecordByteCount: Int,
        maximumAggregateRecordBytes: Int
    ) throws -> Self {
        guard maximumRecordCount > 0,
              maximumRecordByteCount >= 0,
              maximumAggregateRecordBytes >= 0
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .invalidDecodeLimits
        }
        return Self(
            maximumRecordCount:
                maximumRecordCount,
            maximumRecordByteCount:
                maximumRecordByteCount,
            maximumAggregateRecordBytes:
                maximumAggregateRecordBytes
        )
    }
}

public struct PrimeNativeNeuralGateInvariantChunk:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: UInt32
    public let recordCount: Int
    public let byteCount: Int
    public let sha256: String

    public init(
        ordinal: UInt32,
        recordCount: Int,
        byteCount: Int,
        sha256: String
    ) {
        self.ordinal = ordinal
        self.recordCount = recordCount
        self.byteCount = byteCount
        self.sha256 = sha256
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case recordCount = "record_count"
        case byteCount = "byte_count"
        case sha256
    }
}

public struct PrimeNativeNeuralGateInvariantManifest:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let serializationContractID: String
    public let recordCount: Int
    public let globalStreamByteCount: Int
    public let globalStreamSHA256: String
    public let chunks:
        [PrimeNativeNeuralGateInvariantChunk]

    public init(
        recordCount: Int,
        globalStreamByteCount: Int,
        globalStreamSHA256: String,
        chunks:
            [PrimeNativeNeuralGateInvariantChunk]
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_invariant_manifest"
        serializationContractID =
            PrimeNativeNeuralGateInvariantCodec
            .serializationContractID
        self.recordCount = recordCount
        self.globalStreamByteCount =
            globalStreamByteCount
        self.globalStreamSHA256 =
            globalStreamSHA256
        self.chunks = chunks
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case serializationContractID =
            "serialization_contract_id"
        case recordCount = "record_count"
        case globalStreamByteCount =
            "global_stream_byte_count"
        case globalStreamSHA256 =
            "global_stream_sha256"
        case chunks
    }
}

public struct PrimeNativeNeuralGateFingerprint:
    Codable,
    Equatable,
    Sendable
{
    public let prime: UInt64
    public let evaluationPoints: [UInt64]
    public let residues: [UInt64]
    public let recordCount: Int

    public init(
        prime: UInt64,
        evaluationPoints: [UInt64],
        residues: [UInt64],
        recordCount: Int
    ) {
        self.prime = prime
        self.evaluationPoints = evaluationPoints
        self.residues = residues
        self.recordCount = recordCount
    }

    private enum CodingKeys: String, CodingKey {
        case prime
        case evaluationPoints =
            "evaluation_points"
        case residues
        case recordCount = "record_count"
    }
}

public struct PrimeNativeNeuralGateFingerprintObservation:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let artifactKind: String
    public let directAlgorithmID: String
    public let acceleratedAlgorithmID: String
    public let orderedMultisetStreamSHA256:
        String
    public let direct:
        PrimeNativeNeuralGateFingerprint
    public let accelerated:
        PrimeNativeNeuralGateFingerprint
    public let exactEqualityObserved: Bool
    public let cacheKey: String

    public init(
        orderedMultisetStreamSHA256:
            String,
        direct:
            PrimeNativeNeuralGateFingerprint,
        accelerated:
            PrimeNativeNeuralGateFingerprint
    ) {
        schemaVersion = 1
        artifactKind =
            "ergentics_prime_native_neural_gate_fingerprint_observation"
        directAlgorithmID =
            PrimeNativeNeuralGateFingerprintMechanics
            .directAlgorithmID
        acceleratedAlgorithmID =
            PrimeNativeNeuralGateFingerprintMechanics
            .acceleratedAlgorithmID
        self.orderedMultisetStreamSHA256 =
            orderedMultisetStreamSHA256
        self.direct = direct
        self.accelerated = accelerated
        exactEqualityObserved =
            direct == accelerated
        cacheKey =
            PrimeNativeNeuralGateFingerprintMechanics
            .cacheKey(
                streamSHA256:
                    orderedMultisetStreamSHA256
            )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case artifactKind = "artifact_kind"
        case directAlgorithmID =
            "direct_algorithm_id"
        case acceleratedAlgorithmID =
            "accelerated_algorithm_id"
        case orderedMultisetStreamSHA256 =
            "ordered_multiset_stream_sha256"
        case direct
        case accelerated
        case exactEqualityObserved =
            "exact_equality_observed"
        case cacheKey = "cache_key"
    }
}

/// In-memory mechanics result. It is deliberately not `Codable`: durable
/// authority comes from separately published bytes plus typed recomputation.
public struct PrimeNativeNeuralGateInvariantBundle:
    Equatable,
    Sendable
{
    public let canonicalRecords: [Data]
    public let globalStream: Data
    public let chunkStreams: [Data]
    public let manifest:
        PrimeNativeNeuralGateInvariantManifest
    public let fingerprintObservation:
        PrimeNativeNeuralGateFingerprintObservation

    init(
        canonicalRecords: [Data],
        globalStream: Data,
        chunkStreams: [Data],
        manifest:
            PrimeNativeNeuralGateInvariantManifest,
        fingerprintObservation:
            PrimeNativeNeuralGateFingerprintObservation
    ) {
        self.canonicalRecords = canonicalRecords
        self.globalStream = globalStream
        self.chunkStreams = chunkStreams
        self.manifest = manifest
        self.fingerprintObservation =
            fingerprintObservation
    }
}

/// Selects one of the two frozen raw UTF-8 invariant stream envelopes.
public enum PrimeNativeNeuralGateInvariantFramedStreamKind:
    Equatable,
    Sendable
{
    case global
    case chunk
}

/// Bounded result from an incrementally validated invariant stream.
///
/// This value records mechanics only. It does not establish where bytes came
/// from or authorize a descriptor, artifact, evaluation, or receipt.
public struct PrimeNativeNeuralGateInvariantFramedStreamSummary:
    Equatable,
    Sendable
{
    public let kind:
        PrimeNativeNeuralGateInvariantFramedStreamKind
    public let declaredRecordCount: UInt64
    public let observedRecordCount: Int
    public let chunkOrdinal: UInt32?
    public let streamSHA256: String
    public let byteCount: UInt64
    public let aggregateRecordByteCount: UInt64

    fileprivate init(
        kind:
            PrimeNativeNeuralGateInvariantFramedStreamKind,
        declaredRecordCount: UInt64,
        observedRecordCount: Int,
        chunkOrdinal: UInt32?,
        streamSHA256: String,
        byteCount: UInt64,
        aggregateRecordByteCount: UInt64
    ) {
        self.kind = kind
        self.declaredRecordCount = declaredRecordCount
        self.observedRecordCount = observedRecordCount
        self.chunkOrdinal = chunkOrdinal
        self.streamSHA256 = streamSHA256
        self.byteCount = byteCount
        self.aggregateRecordByteCount =
            aggregateRecordByteCount
    }
}

/// Incremental PRIMEIRM1/PRIMEIRC1 reader for bounded descriptor-fed bytes.
///
/// Only one complete record is retained at a time. The declared record length
/// and aggregate payload bounds are checked before record storage is reserved.
/// Every consumed byte contributes to the exact stream SHA-256. A thrown parse
/// or consumer error poisons the reader so partially admitted state cannot be
/// resumed accidentally.
public final class PrimeNativeNeuralGateInvariantFramedRecordReader {
    public let kind:
        PrimeNativeNeuralGateInvariantFramedStreamKind
    public let limits:
        PrimeNativeNeuralGateReplayDecodeLimits
    public let requireCanonicalOrder: Bool
    public let requiredDeclaredRecordCount: UInt64?

    private let expectedMagic: Data
    private var magic = Data()
    private var metadata = Data()
    private var length = Data()
    private var record = Data()
    private var expectedRecordByteCount: Int?
    private var declaredCount: UInt64?
    private var expectedCount: Int?
    private var ordinal: UInt32?
    private var observedCount = 0
    private var aggregateBytes: UInt64 = 0
    private var previousRecord: Data?
    private var hasher = SHA256()
    private var consumedByteCount: UInt64 = 0
    private var failed = false
    private var isConsuming = false
    private var completedSummary:
        PrimeNativeNeuralGateInvariantFramedStreamSummary?

    public init(
        kind:
            PrimeNativeNeuralGateInvariantFramedStreamKind,
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits = .stageB,
        requireCanonicalOrder: Bool = true,
        requiredDeclaredRecordCount: UInt64? = nil
    ) {
        self.kind = kind
        self.limits = limits
        self.requireCanonicalOrder =
            requireCanonicalOrder
        self.requiredDeclaredRecordCount =
            requiredDeclaredRecordCount
        switch kind {
        case .global:
            expectedMagic =
                PrimeNativeNeuralGateInvariantCodec
                .globalMagic
        case .chunk:
            expectedMagic =
                PrimeNativeNeuralGateInvariantCodec
                .chunkMagic
        }
    }

    public func consume(
        _ bytes: Data,
        onRecord: (Data) throws -> Void
    ) throws {
        guard !failed,
              !isConsuming
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .incrementalReaderNotReusable
        }
        if completedSummary != nil {
            guard bytes.isEmpty else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .trailingInput
            }
            return
        }
        guard !bytes.isEmpty else {
            return
        }
        isConsuming = true
        defer {
            isConsuming = false
        }
        do {
            let addition = consumedByteCount
                .addingReportingOverflow(
                    UInt64(bytes.count)
                )
            guard !addition.overflow else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .integerOverflow
            }
            consumedByteCount = addition.partialValue
            hasher.update(data: bytes)

            var cursor = bytes.startIndex
            while cursor < bytes.endIndex {
                if magic.count < expectedMagic.count {
                    Self.appendAvailable(
                        from: bytes,
                        cursor: &cursor,
                        to: &magic,
                        requiredCount:
                            expectedMagic.count
                    )
                    if magic.count == expectedMagic.count,
                       magic != expectedMagic
                    {
                        switch kind {
                        case .global:
                            throw PrimeNativeNeuralGateReplayMechanicsError
                                .invalidGlobalMagic
                        case .chunk:
                            throw PrimeNativeNeuralGateReplayMechanicsError
                                .invalidChunkMagic
                        }
                    }
                    continue
                }

                if declaredCount == nil {
                    Self.appendAvailable(
                        from: bytes,
                        cursor: &cursor,
                        to: &metadata,
                        requiredCount: 8
                    )
                    if metadata.count == 8 {
                        try decodeMetadata()
                    }
                    continue
                }

                guard let expectedCount else {
                    throw PrimeNativeNeuralGateReplayMechanicsError
                        .incrementalReaderNotReusable
                }
                guard observedCount < expectedCount else {
                    throw PrimeNativeNeuralGateReplayMechanicsError
                        .trailingInput
                }

                if expectedRecordByteCount == nil {
                    Self.appendAvailable(
                        from: bytes,
                        cursor: &cursor,
                        to: &length,
                        requiredCount: 8
                    )
                    if length.count == 8 {
                        try decodeRecordLength()
                        if expectedRecordByteCount == 0 {
                            try admitRecord(onRecord)
                        }
                    }
                    continue
                }

                guard let required = expectedRecordByteCount
                else {
                    throw PrimeNativeNeuralGateReplayMechanicsError
                        .incrementalReaderNotReusable
                }
                Self.appendAvailable(
                    from: bytes,
                    cursor: &cursor,
                    to: &record,
                    requiredCount: required
                )
                if record.count == required {
                    try admitRecord(onRecord)
                }
            }
        } catch {
            failed = true
            throw error
        }
    }

    public func finish() throws
        -> PrimeNativeNeuralGateInvariantFramedStreamSummary
    {
        guard !failed,
              !isConsuming
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .incrementalReaderNotReusable
        }
        if let completedSummary {
            return completedSummary
        }
        guard magic.count == expectedMagic.count,
              declaredCount != nil,
              metadata.count == 8,
              length.isEmpty,
              expectedRecordByteCount == nil,
              record.isEmpty,
              let declaredCount,
              let expectedCount,
              observedCount == expectedCount
        else {
            failed = true
            throw PrimeNativeNeuralGateReplayMechanicsError
                .truncatedInput
        }
        let summary =
            PrimeNativeNeuralGateInvariantFramedStreamSummary(
                kind: kind,
                declaredRecordCount: declaredCount,
                observedRecordCount: observedCount,
                chunkOrdinal: ordinal,
                streamSHA256:
                    Self.hexadecimal(
                        hasher.finalize()
                    ),
                byteCount: consumedByteCount,
                aggregateRecordByteCount:
                    aggregateBytes
            )
        completedSummary = summary
        return summary
    }

    private func decodeMetadata() throws {
        switch kind {
        case .global:
            let count = Self.decodeUInt64(metadata)
            guard let intCount = Int(exactly: count)
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .integerOverflow
            }
            guard intCount > 0 else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .emptyRecordSet
            }
            guard intCount <= limits.maximumRecordCount
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .recordCountLimitExceeded
            }
            if let requiredDeclaredRecordCount,
               count != requiredDeclaredRecordCount
            {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .declaredRecordCountMismatch(
                        expected: requiredDeclaredRecordCount,
                        observed: count
                    )
            }
            declaredCount = count
            expectedCount = intCount
        case .chunk:
            ordinal = Self.decodeUInt32(
                Data(metadata.prefix(4))
            )
            let count = Self.decodeUInt32(
                Data(metadata.suffix(4))
            )
            guard count > 0 else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .emptyChunk
            }
            guard count <= UInt32(
                PrimeNativeNeuralGateInvariantCodec
                    .maximumRecordsPerChunk
            ) else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .chunkRecordCountLimitExceeded
            }
            let intCount = Int(count)
            guard intCount <= limits.maximumRecordCount
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .recordCountLimitExceeded
            }
            if let requiredDeclaredRecordCount,
               UInt64(count) != requiredDeclaredRecordCount
            {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .declaredRecordCountMismatch(
                        expected: requiredDeclaredRecordCount,
                        observed: UInt64(count)
                    )
            }
            declaredCount = UInt64(count)
            expectedCount = intCount
        }
    }

    private func decodeRecordLength() throws {
        let encoded = Self.decodeUInt64(length)
        guard let intLength = Int(exactly: encoded)
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .integerOverflow
        }
        guard intLength <= limits.maximumRecordByteCount
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .recordByteLimitExceeded(
                    index: observedCount
                )
        }
        let aggregate = aggregateBytes
            .addingReportingOverflow(encoded)
        guard !aggregate.overflow else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .integerOverflow
        }
        guard aggregate.partialValue
                <= UInt64(
                    limits.maximumAggregateRecordBytes
                )
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .aggregateByteLimitExceeded
        }
        aggregateBytes = aggregate.partialValue
        expectedRecordByteCount = intLength
        length.removeAll(keepingCapacity: true)
        record.removeAll(keepingCapacity: false)
        if intLength > 0 {
            record.reserveCapacity(intLength)
        }
    }

    private func admitRecord(
        _ consumer: (Data) throws -> Void
    ) throws {
        guard String(data: record, encoding: .utf8) != nil
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .invalidUTF8Record(index: observedCount)
        }
        if requireCanonicalOrder,
           let previousRecord,
           record.lexicographicallyPrecedes(previousRecord)
        {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .noncanonicalRecordOrder
        }
        try consumer(record)
        if requireCanonicalOrder {
            previousRecord = record
        }
        let next = observedCount
            .addingReportingOverflow(1)
        guard !next.overflow else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .integerOverflow
        }
        observedCount = next.partialValue
        expectedRecordByteCount = nil
        record = Data()
    }

    private static func appendAvailable(
        from source: Data,
        cursor: inout Data.Index,
        to destination: inout Data,
        requiredCount: Int
    ) {
        let remaining = requiredCount
            - destination.count
        let available = source.distance(
            from: cursor,
            to: source.endIndex
        )
        let count = min(remaining, available)
        let end = source.index(
            cursor,
            offsetBy: count
        )
        destination.append(
            contentsOf: source[cursor..<end]
        )
        cursor = end
    }

    private static func decodeUInt32(
        _ data: Data
    ) -> UInt32 {
        data.reduce(0) {
            ($0 << 8) | UInt32($1)
        }
    }

    private static func decodeUInt64(
        _ data: Data
    ) -> UInt64 {
        data.reduce(0) {
            ($0 << 8) | UInt64($1)
        }
    }

    fileprivate static func hexadecimal<Bytes: Sequence>(
        _ bytes: Bytes
    ) -> String where Bytes.Element == UInt8 {
        bytes.map {
            String(format: "%02x", $0)
        }.joined()
    }
}

/// Computes the exact PRIMEIRM1 SHA-256 from bounded canonical records without
/// materializing the framed global stream.
public struct
    PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator
{
    public let declaredRecordCount: UInt64
    public let limits:
        PrimeNativeNeuralGateReplayDecodeLimits
    public let requireCanonicalOrder: Bool

    private let expectedRecordCount: Int
    private var observedRecordCount = 0
    private var aggregateRecordByteCount: UInt64 = 0
    private var byteCount: UInt64
    private var previousRecord: Data?
    private var hasher: SHA256
    private var failed = false
    private var completedSummary:
        PrimeNativeNeuralGateInvariantFramedStreamSummary?

    public init(
        declaredRecordCount: UInt64,
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits = .stageB,
        requireCanonicalOrder: Bool = true
    ) throws {
        guard let count = Int(
            exactly: declaredRecordCount
        ) else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .integerOverflow
        }
        guard count > 0 else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .emptyRecordSet
        }
        guard count <= limits.maximumRecordCount else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .recordCountLimitExceeded
        }
        self.declaredRecordCount = declaredRecordCount
        self.limits = limits
        self.requireCanonicalOrder =
            requireCanonicalOrder
        expectedRecordCount = count
        byteCount = 17
        var hasher = SHA256()
        hasher.update(
            data:
                PrimeNativeNeuralGateInvariantCodec
                .globalMagic
        )
        var encoded = declaredRecordCount.bigEndian
        withUnsafeBytes(of: &encoded) {
            hasher.update(data: Data($0))
        }
        self.hasher = hasher
    }

    public mutating func append(
        canonicalRecord: Data
    ) throws {
        guard !failed else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .incrementalReaderNotReusable
        }
        guard completedSummary == nil else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .trailingInput
        }
        var admitted = false
        defer {
            if !admitted {
                failed = true
            }
        }
        guard observedRecordCount < expectedRecordCount
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .trailingInput
        }
        guard canonicalRecord.count
                <= limits.maximumRecordByteCount
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .recordByteLimitExceeded(
                    index: observedRecordCount
                )
        }
        let recordByteCount = UInt64(
            canonicalRecord.count
        )
        let aggregate = aggregateRecordByteCount
            .addingReportingOverflow(recordByteCount)
        guard !aggregate.overflow else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .integerOverflow
        }
        guard aggregate.partialValue
                <= UInt64(
                    limits.maximumAggregateRecordBytes
                )
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .aggregateByteLimitExceeded
        }
        guard String(
            data: canonicalRecord,
            encoding: .utf8
        ) != nil else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .invalidUTF8Record(
                    index: observedRecordCount
                )
        }
        if requireCanonicalOrder,
           let previousRecord,
           canonicalRecord.lexicographicallyPrecedes(
               previousRecord
           )
        {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .noncanonicalRecordOrder
        }
        let framedAddition = UInt64(8)
            .addingReportingOverflow(recordByteCount)
        guard !framedAddition.overflow else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .integerOverflow
        }
        let nextByteCount = byteCount
            .addingReportingOverflow(
                framedAddition.partialValue
            )
        guard !nextByteCount.overflow else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .integerOverflow
        }
        var encodedLength = recordByteCount.bigEndian
        withUnsafeBytes(of: &encodedLength) {
            hasher.update(data: Data($0))
        }
        hasher.update(data: canonicalRecord)
        aggregateRecordByteCount =
            aggregate.partialValue
        byteCount = nextByteCount.partialValue
        if requireCanonicalOrder {
            previousRecord = canonicalRecord
        }
        observedRecordCount += 1
        admitted = true
    }

    public mutating func finish() throws
        -> PrimeNativeNeuralGateInvariantFramedStreamSummary
    {
        guard !failed else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .incrementalReaderNotReusable
        }
        if let completedSummary {
            return completedSummary
        }
        guard observedRecordCount == expectedRecordCount
        else {
            failed = true
            throw PrimeNativeNeuralGateReplayMechanicsError
                .truncatedInput
        }
        let summary =
            PrimeNativeNeuralGateInvariantFramedStreamSummary(
                kind: .global,
                declaredRecordCount:
                    declaredRecordCount,
                observedRecordCount:
                    observedRecordCount,
                chunkOrdinal: nil,
                streamSHA256:
                    PrimeNativeNeuralGateInvariantFramedRecordReader
                    .hexadecimal(hasher.finalize()),
                byteCount: byteCount,
                aggregateRecordByteCount:
                    aggregateRecordByteCount
            )
        completedSummary = summary
        return summary
    }
}

public enum PrimeNativeNeuralGateInvariantCodec {
    public static let serializationContractID =
        "prime_raw_utf8_length_framed_ordered_multiset_v1"
    public static let maximumRecordsPerChunk =
        4_096

    fileprivate static let globalMagic =
        Data("PRIMEIRM1".utf8)
    fileprivate static let chunkMagic =
        Data("PRIMEIRC1".utf8)

    public static func makeBundle(
        records: [Data]
    ) throws
        -> PrimeNativeNeuralGateInvariantBundle
    {
        let canonical = try canonicalRecords(
            records
        )
        let global = try encodeGlobal(
            canonicalRecords: canonical
        )
        let chunks = try encodeChunks(
            canonicalRecords: canonical
        )
        let direct =
            try PrimeNativeNeuralGateFingerprintMechanics
            .direct(canonicalRecords: canonical)
        let accelerated =
            try PrimeNativeNeuralGateFingerprintMechanics
            .accelerated(
                canonicalRecords: canonical
            )
        guard direct == accelerated else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .fingerprintMismatch
        }
        let streamSHA = sha256(global)
        let chunkManifest = try chunks.map {
            chunk in
            let decoded = try decodeChunk(
                chunk
            )
            return PrimeNativeNeuralGateInvariantChunk(
                ordinal: decoded.ordinal,
                recordCount:
                    decoded.records.count,
                byteCount: chunk.count,
                sha256: sha256(chunk)
            )
        }
        let manifest =
            PrimeNativeNeuralGateInvariantManifest(
                recordCount: canonical.count,
                globalStreamByteCount:
                    global.count,
                globalStreamSHA256: streamSHA,
                chunks: chunkManifest
            )
        let fingerprints =
            PrimeNativeNeuralGateFingerprintObservation(
                orderedMultisetStreamSHA256:
                    streamSHA,
                direct: direct,
                accelerated: accelerated
            )
        return PrimeNativeNeuralGateInvariantBundle(
            canonicalRecords: canonical,
            globalStream: global,
            chunkStreams: chunks,
            manifest: manifest,
            fingerprintObservation:
                fingerprints
        )
    }

    public static func validate(
        manifest:
            PrimeNativeNeuralGateInvariantManifest,
        fingerprintObservation:
            PrimeNativeNeuralGateFingerprintObservation,
        globalStream: Data,
        chunkStreams: [Data]
    ) throws
        -> [Data]
    {
        let records = try decodeGlobal(
            globalStream
        )
        try validateChunkPartition(
            canonicalRecords: records,
            chunkStreams: chunkStreams
        )
        let recomputed = try makeBundle(
            records: records
        )
        guard manifest == recomputed.manifest
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .invalidManifest
        }
        guard fingerprintObservation
                == recomputed
                .fingerprintObservation
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .invalidFingerprintObservation
        }
        return records
    }

    public static func canonicalRecords(
        _ records: [Data],
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits
            = .stageB
    ) throws -> [Data] {
        guard !records.isEmpty else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .emptyRecordSet
        }
        try validateRecords(
            records,
            limits: limits,
            requireCanonicalOrder: false
        )
        return records.sorted {
            $0.lexicographicallyPrecedes($1)
        }
    }

    public static func encodeGlobal(
        canonicalRecords records: [Data]
    ) throws -> Data {
        try validateRecords(
            records,
            limits: .stageB,
            requireCanonicalOrder: true
        )
        var output = globalMagic
        try appendBigEndian(
            UInt64(records.count),
            to: &output
        )
        try appendFramed(
            records,
            to: &output
        )
        return output
    }

    public static func encodeChunks(
        canonicalRecords records: [Data]
    ) throws -> [Data] {
        try validateRecords(
            records,
            limits: .stageB,
            requireCanonicalOrder: true
        )
        var chunks: [Data] = []
        var start = 0
        var ordinal: UInt32 = 0
        while start < records.count {
            let end = min(
                start + maximumRecordsPerChunk,
                records.count
            )
            let slice = Array(records[start..<end])
            var output = chunkMagic
            try appendBigEndian(
                ordinal,
                to: &output
            )
            try appendBigEndian(
                UInt32(slice.count),
                to: &output
            )
            try appendFramed(
                slice,
                to: &output
            )
            chunks.append(output)
            guard ordinal < UInt32.max else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .integerOverflow
            }
            ordinal += 1
            start = end
        }
        return chunks
    }

    public static func decodeGlobal(
        _ data: Data,
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits
            = .stageB
    ) throws -> [Data] {
        var reader = Reader(data)
        guard try reader.read(globalMagic.count)
                == globalMagic
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .invalidGlobalMagic
        }
        let count: UInt64 =
            try reader.readBigEndian()
        let intCount = try checkedInt(count)
        guard intCount > 0 else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .emptyRecordSet
        }
        guard intCount <= limits.maximumRecordCount
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .recordCountLimitExceeded
        }
        let records = try reader.readRecords(
            count: intCount,
            limits: limits
        )
        guard reader.isAtEnd else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .trailingInput
        }
        try validateRecords(
            records,
            limits: limits,
            requireCanonicalOrder: true
        )
        return records
    }

    public static func decodeChunk(
        _ data: Data,
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits
            = .stageB
    ) throws
        -> (ordinal: UInt32, records: [Data])
    {
        var reader = Reader(data)
        guard try reader.read(chunkMagic.count)
                == chunkMagic
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .invalidChunkMagic
        }
        let ordinal: UInt32 =
            try reader.readBigEndian()
        let count: UInt32 =
            try reader.readBigEndian()
        guard count > 0 else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .emptyChunk
        }
        guard count <= UInt32(
            maximumRecordsPerChunk
        ) else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .chunkRecordCountLimitExceeded
        }
        guard Int(count)
                <= limits.maximumRecordCount
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .recordCountLimitExceeded
        }
        let records = try reader.readRecords(
            count: Int(count),
            limits: limits
        )
        guard reader.isAtEnd else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .trailingInput
        }
        try validateRecords(
            records,
            limits: limits,
            requireCanonicalOrder: true
        )
        return (ordinal, records)
    }

    public static func validateChunkPartition(
        canonicalRecords records: [Data],
        chunkStreams: [Data],
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits
            = .stageB
    ) throws {
        try validateRecords(
            records,
            limits: limits,
            requireCanonicalOrder: true
        )
        let expectedChunkCount =
            (
                records.count
                    + maximumRecordsPerChunk - 1
            ) / maximumRecordsPerChunk
        guard chunkStreams.count
                == expectedChunkCount
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .chunkPartitionMismatch
        }
        var reconstructed: [Data] = []
        reconstructed.reserveCapacity(records.count)
        for (index, stream) in
            chunkStreams.enumerated()
        {
            let decoded = try decodeChunk(
                stream,
                limits: limits
            )
            guard let expectedOrdinal =
                    UInt32(exactly: index),
                  decoded.ordinal
                    == expectedOrdinal
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .chunkOrdinalMismatch(
                        expected:
                            UInt32(
                                truncatingIfNeeded:
                                    index
                            ),
                        observed: decoded.ordinal
                    )
            }
            let isFinal =
                index == chunkStreams.count - 1
            guard isFinal
                    || decoded.records.count
                        == maximumRecordsPerChunk
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .chunkPartitionMismatch
            }
            reconstructed.append(
                contentsOf: decoded.records
            )
        }
        guard reconstructed == records else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .chunkPartitionMismatch
        }
    }

    public static func sha256(
        _ data: Data
    ) -> String {
        SHA256.hash(data: data)
            .map {
                String(
                    format: "%02x",
                    $0
                )
            }
            .joined()
    }

    private static func validateRecords(
        _ records: [Data],
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits,
        requireCanonicalOrder: Bool
    ) throws {
        guard !records.isEmpty else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .emptyRecordSet
        }
        guard records.count
                <= limits.maximumRecordCount
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .recordCountLimitExceeded
        }
        var aggregate = 0
        for (index, record) in
            records.enumerated()
        {
            guard record.count
                    <= limits
                    .maximumRecordByteCount
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .recordByteLimitExceeded(
                        index: index
                    )
            }
            let next = aggregate
                .addingReportingOverflow(
                    record.count
                )
            guard !next.overflow else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .integerOverflow
            }
            aggregate = next.partialValue
            guard aggregate
                    <= limits
                    .maximumAggregateRecordBytes
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .aggregateByteLimitExceeded
            }
            guard String(
                data: record,
                encoding: .utf8
            ) != nil else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .invalidUTF8Record(
                        index: index
                    )
            }
            if requireCanonicalOrder,
               index > 0,
               record.lexicographicallyPrecedes(
                   records[index - 1]
               )
            {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .noncanonicalRecordOrder
            }
        }
    }

    private static func appendFramed(
        _ records: [Data],
        to output: inout Data
    ) throws {
        for record in records {
            try appendBigEndian(
                UInt64(record.count),
                to: &output
            )
            output.append(record)
        }
    }

    private static func appendBigEndian<
        Value: FixedWidthInteger
    >(
        _ value: Value,
        to output: inout Data
    ) throws {
        var encoded = value.bigEndian
        withUnsafeBytes(of: &encoded) {
            output.append(contentsOf: $0)
        }
    }

    private static func checkedInt(
        _ value: UInt64
    ) throws -> Int {
        guard let result = Int(exactly: value)
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .integerOverflow
        }
        return result
    }

    private struct Reader {
        let data: Data
        var offset: Data.Index

        init(_ data: Data) {
            self.data = data
            offset = data.startIndex
        }

        var isAtEnd: Bool {
            offset == data.endIndex
        }

        mutating func read(
            _ count: Int
        ) throws -> Data {
            guard count >= 0,
                  offset <= data.endIndex,
                  count <= data.distance(
                      from: offset,
                      to: data.endIndex
                  )
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .truncatedInput
            }
            let end = data.index(
                offset,
                offsetBy: count
            )
            let result = data.subdata(
                in: offset..<end
            )
            offset = end
            return result
        }

        mutating func readBigEndian<
            Value: FixedWidthInteger
        >() throws -> Value {
            let bytes = try read(
                MemoryLayout<Value>.size
            )
            var result: Value = 0
            for byte in bytes {
                result =
                    (result << 8)
                    | Value(byte)
            }
            return result
        }

        mutating func readRecords(
            count: Int,
            limits:
                PrimeNativeNeuralGateReplayDecodeLimits
        ) throws -> [Data] {
            var records: [Data] = []
            records.reserveCapacity(count)
            var aggregate = 0
            for index in 0..<count {
                let length: UInt64 =
                    try readBigEndian()
                guard let intLength =
                        Int(exactly: length)
                else {
                    throw PrimeNativeNeuralGateReplayMechanicsError
                        .integerOverflow
                }
                guard intLength
                        <= limits
                        .maximumRecordByteCount
                else {
                    throw PrimeNativeNeuralGateReplayMechanicsError
                        .recordByteLimitExceeded(
                            index: index
                        )
                }
                let next = aggregate
                    .addingReportingOverflow(
                        intLength
                    )
                guard !next.overflow else {
                    throw PrimeNativeNeuralGateReplayMechanicsError
                        .integerOverflow
                }
                aggregate = next.partialValue
                guard aggregate
                        <= limits
                        .maximumAggregateRecordBytes
                else {
                    throw PrimeNativeNeuralGateReplayMechanicsError
                        .aggregateByteLimitExceeded
                }
                records.append(
                    try read(intLength)
                )
            }
            return records
        }
    }
}

public enum PrimeNativeNeuralGateFingerprintMechanics {
    public static let directAlgorithmID =
        "raw_utf8_uint64be_length_horner_three_point_v1"
    public static let acceleratedAlgorithmID =
        "immutable_raw_utf8_affine_segment_tree_v1"
    public static let prime: UInt64 =
        2_147_483_647
    public static let evaluationPoints:
        [UInt64] = [
            257,
            65_537,
            1_000_003,
        ]
    public static let accumulatorSeed:
        UInt64 = 1
    public static let byteOffset: UInt64 = 1

    public static func direct(
        canonicalRecords records: [Data],
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits
            = .stageB
    ) throws -> PrimeNativeNeuralGateFingerprint {
        try requireCanonical(
            records,
            limits: limits
        )
        let residues = evaluationPoints.map {
            point in
            var accumulator = accumulatorSeed
            for record in records {
                let count = UInt64(record.count)
                for shift in stride(
                    from: 56,
                    through: 0,
                    by: -8
                ) {
                    let byte = UInt8(
                        truncatingIfNeeded:
                            count >> UInt64(shift)
                    )
                    accumulator =
                        (
                            accumulator * point
                                + UInt64(byte)
                                + byteOffset
                        ) % prime
                }
                for byte in record {
                    accumulator =
                        (
                            accumulator * point
                                + UInt64(byte)
                                + byteOffset
                        ) % prime
                }
            }
            return accumulator
        }
        return fingerprint(
            residues: residues,
            recordCount: records.count
        )
    }

    public static func accelerated(
        canonicalRecords records: [Data],
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits
            = .stageB
    ) throws -> PrimeNativeNeuralGateFingerprint {
        try requireCanonical(
            records,
            limits: limits
        )
        let residues = evaluationPoints.map {
            point in
            var level: [AffineSegment] =
                records.map {
                    recordSegment(
                        $0,
                        point: point
                    )
                }
            while level.count > 1 {
                var next: [AffineSegment] = []
                next.reserveCapacity(
                    (level.count + 1) / 2
                )
                var index = 0
                while index < level.count {
                    if index + 1 < level.count {
                        next.append(
                            compose(
                                level[index],
                                level[index + 1]
                            )
                        )
                    } else {
                        next.append(level[index])
                    }
                    index += 2
                }
                level = next
            }
            let root = level[0]
            return (
                accumulatorSeed
                    * root.multiplier
                    + root.addend
            ) % prime
        }
        return fingerprint(
            residues: residues,
            recordCount: records.count
        )
    }

    public static func cacheKey(
        streamSHA256: String
    ) -> String {
        [
            PrimeNativeNeuralGateInvariantCodec
                .serializationContractID,
            directAlgorithmID,
            acceleratedAlgorithmID,
            String(prime),
            evaluationPoints
                .map(String.init)
                .joined(separator: ","),
            String(accumulatorSeed),
            String(byteOffset),
            streamSHA256,
        ].joined(separator: "|")
    }

    private static func fingerprint(
        residues: [UInt64],
        recordCount: Int
    ) -> PrimeNativeNeuralGateFingerprint {
        PrimeNativeNeuralGateFingerprint(
            prime: prime,
            evaluationPoints: evaluationPoints,
            residues: residues,
            recordCount: recordCount
        )
    }

    private static func requireCanonical(
        _ records: [Data],
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits
    ) throws {
        guard !records.isEmpty else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .emptyRecordSet
        }
        guard records.count
                <= limits.maximumRecordCount
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .recordCountLimitExceeded
        }
        var aggregate = 0
        for index in records.indices {
            guard records[index].count
                    <= limits
                    .maximumRecordByteCount
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .recordByteLimitExceeded(
                        index: index
                    )
            }
            let next = aggregate
                .addingReportingOverflow(
                    records[index].count
                )
            guard !next.overflow else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .integerOverflow
            }
            aggregate = next.partialValue
            guard aggregate
                    <= limits
                    .maximumAggregateRecordBytes
            else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .aggregateByteLimitExceeded
            }
            guard String(
                data: records[index],
                encoding: .utf8
            ) != nil else {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .invalidUTF8Record(
                        index: index
                    )
            }
            if index > 0,
               records[index]
               .lexicographicallyPrecedes(
                   records[index - 1]
               )
            {
                throw PrimeNativeNeuralGateReplayMechanicsError
                    .noncanonicalRecordOrder
            }
        }
    }

    private struct AffineSegment {
        let multiplier: UInt64
        let addend: UInt64
        let byteCount: UInt64
    }

    private static let identity =
        AffineSegment(
            multiplier: 1,
            addend: 0,
            byteCount: 0
        )

    private static func recordSegment(
        _ record: Data,
        point: UInt64
    ) -> AffineSegment {
        var segment = identity
        var encodedCount =
            UInt64(record.count).bigEndian
        withUnsafeBytes(of: &encodedCount) {
            bytes in
            for byte in bytes {
                segment = compose(
                    segment,
                    byteSegment(
                        byte,
                        point: point
                    )
                )
            }
        }
        for byte in record {
            segment = compose(
                segment,
                byteSegment(
                    byte,
                    point: point
                )
            )
        }
        return segment
    }

    private static func byteSegment(
        _ byte: UInt8,
        point: UInt64
    ) -> AffineSegment {
        AffineSegment(
            multiplier: point,
            addend:
                (
                    UInt64(byte) + byteOffset
                ) % prime,
            byteCount: 1
        )
    }

    private static func compose(
        _ left: AffineSegment,
        _ right: AffineSegment
    ) -> AffineSegment {
        AffineSegment(
            multiplier:
                (
                    left.multiplier
                        * right.multiplier
                ) % prime,
            addend:
                (
                    left.addend
                        * right.multiplier
                        + right.addend
                ) % prime,
            byteCount:
                left.byteCount
                    + right.byteCount
        )
    }
}

/// A transient, non-`Codable` cache. Cache reuse requires both the exact raw
/// global stream and its SHA-256, not a caller-supplied cache-hit Boolean.
public struct PrimeNativeNeuralGateAffineFingerprintCache:
    Equatable,
    Sendable
{
    public let streamSHA256: String
    public let fingerprint:
        PrimeNativeNeuralGateFingerprint
    private let globalStream: Data

    private init(
        streamSHA256: String,
        fingerprint:
            PrimeNativeNeuralGateFingerprint,
        globalStream: Data
    ) {
        self.streamSHA256 = streamSHA256
        self.fingerprint = fingerprint
        self.globalStream = globalStream
    }

    static func testOnly(
        streamSHA256: String,
        fingerprint:
            PrimeNativeNeuralGateFingerprint,
        globalStream: Data
    ) -> Self {
        Self(
            streamSHA256: streamSHA256,
            fingerprint: fingerprint,
            globalStream: globalStream
        )
    }

    public static func build(
        globalStream: Data
    ) throws -> Self {
        let records =
            try PrimeNativeNeuralGateInvariantCodec
            .decodeGlobal(globalStream)
        let direct =
            try PrimeNativeNeuralGateFingerprintMechanics
            .direct(
                canonicalRecords: records
            )
        let accelerated =
            try PrimeNativeNeuralGateFingerprintMechanics
            .accelerated(
                canonicalRecords: records
            )
        guard direct == accelerated else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .fingerprintMismatch
        }
        return Self(
            streamSHA256:
                PrimeNativeNeuralGateInvariantCodec
                .sha256(globalStream),
            fingerprint: accelerated,
            globalStream: globalStream
        )
    }

    public func reuse(
        for candidateGlobalStream: Data
    ) throws
        -> PrimeNativeNeuralGateFingerprint
    {
        let candidateSHA =
            PrimeNativeNeuralGateInvariantCodec
            .sha256(candidateGlobalStream)
        guard candidateSHA == streamSHA256,
              candidateGlobalStream == globalStream
        else {
            throw PrimeNativeNeuralGateReplayMechanicsError
                .staleFingerprintCache
        }
        return fingerprint
    }
}
