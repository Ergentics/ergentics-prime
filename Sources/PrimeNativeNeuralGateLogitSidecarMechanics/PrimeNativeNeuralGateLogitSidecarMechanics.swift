import CryptoKit
import Foundation
import PrimeNativeNeuralGateCorrectedMechanics

public enum PrimeNativeNeuralGateLogitSidecarPolicy {
    public static let codecID =
        "prime_stage_b_full_vocabulary_logit_sidecar_dictionary_deduplicated_row_index_chunks_big_endian_v1"
    public static let dictionaryMagic = "PRMLGD01"
    public static let chunkMagic = "PRMLGC01"
    public static let manifestMagic = "PRMLGM01"
    public static let aggregateDomain = "PRMLGA01"

    public static let vocabularyCount = 512
    public static let maximumDictionaryEntryCount =
        65_536
    public static let maximumDecisionsPerRow = 64
    public static let exactRowCount = 18_432
    public static let rowsPerChunk = 1_024
    public static let exactChunkCount = 18
    public static let maximumDictionaryCandidateCount =
        exactRowCount * maximumDecisionsPerRow
    public static let maximumDictionaryFileByteCount =
        256 * 1_024 * 1_024
    public static let maximumChunkFileByteCount =
        1 * 1_024 * 1_024
    public static let maximumManifestFileByteCount =
        64 * 1_024
    public static let maximumAggregateFileByteCount =
        512 * 1_024 * 1_024
    public static let maximumCorrelationIDByteCount =
        512

    public static let dictionaryEntrySerializationID =
        "512_float32_bit_patterns_uint32_big_endian_in_token_id_order_v1"
    public static let fileSHA256Policy =
        "sha256_over_exact_file_bytes_v1"
    public static let aggregateSHA256Policy =
        "sha256_prmlga01_then_for_dictionary_and_chunks_in_order_uint64_big_endian_length_then_exact_file_bytes_v1"

    public static let executionImplemented = false
    public static let durableArtifactPublished = false
    public static let modelExecutionClaimed = false
    public static let metalExecutionAuthorityClaimed =
        false
    public static let scientificIndependenceClaimed =
        false
    public static let terminalReceiptAuthorized =
        false
}

public enum PrimeNativeNeuralGateLogitSidecarError:
    Error,
    Equatable,
    Sendable
{
    case emptyDictionary
    case dictionaryEntryCountLimitExceeded(
        observed: Int
    )
    case dictionaryCandidateCountLimitExceeded(
        observed: Int
    )
    case invalidVocabularyCount(
        entryIndex: Int,
        observed: Int
    )
    case nonfiniteLogit(
        entryIndex: Int,
        tokenID: Int
    )
    case invalidDictionaryOrdering
    case invalidDictionaryIndex(UInt32)
    case unreferencedDictionaryEntry(UInt32)
    case invalidMagic
    case invalidEvaluationSeed
    case evaluationSeedMismatch
    case invalidDeclaredVocabularyCount
    case invalidDeclaredEntryCount
    case invalidChunkOrdinal
    case invalidRowCount
    case invalidRowOrdinal(
        expected: Int,
        observed: Int
    )
    case invalidCorrelationID
    case duplicateCorrelationID
    case invalidDecisionCount
    case invalidDecisionOrdinal(
        expected: Int,
        observed: Int
    )
    case invalidChunkPartition
    case dictionaryFileByteLimitExceeded
    case chunkFileByteLimitExceeded
    case manifestFileByteLimitExceeded
    case aggregateByteLimitExceeded
    case integerOverflow
    case truncatedInput
    case trailingInput
    case invalidSHA256
    case dictionaryBindingMismatch
    case chunkBindingMismatch
    case aggregateBindingMismatch
}

public struct PrimeNativeNeuralGateLogitDecisionReference:
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let dictionaryIndex: UInt32

    public init(
        ordinal: Int,
        dictionaryIndex: UInt32
    ) throws {
        guard (1 ...
            PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDecisionsPerRow)
            .contains(ordinal)
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidDecisionOrdinal(
                    expected: 1,
                    observed: ordinal
                )
        }
        self.ordinal = ordinal
        self.dictionaryIndex = dictionaryIndex
    }
}

public struct PrimeNativeNeuralGateLogitRowReference:
    Equatable,
    Sendable
{
    public let rowOrdinal: Int
    public let correlationID: String
    public let decisions:
        [PrimeNativeNeuralGateLogitDecisionReference]

    public init(
        rowOrdinal: Int,
        correlationID: String,
        decisions:
            [PrimeNativeNeuralGateLogitDecisionReference]
    ) throws {
        guard (0 ..<
            PrimeNativeNeuralGateLogitSidecarPolicy
                .exactRowCount)
            .contains(rowOrdinal)
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidRowOrdinal(
                    expected: 0,
                    observed: rowOrdinal
                )
        }
        guard Self.isValidCorrelationID(
            correlationID
        ) else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidCorrelationID
        }
        guard !decisions.isEmpty,
              decisions.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDecisionsPerRow,
              decisions.map(\.ordinal)
                == Array(1 ... decisions.count)
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidDecisionCount
        }
        self.rowOrdinal = rowOrdinal
        self.correlationID = correlationID
        self.decisions = decisions
    }

    fileprivate static func isValidCorrelationID(
        _ value: String
    ) -> Bool {
        let bytes = Array(value.utf8)
        return !bytes.isEmpty
            && bytes.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumCorrelationIDByteCount
            && bytes.allSatisfy {
                $0 >= 0x21 && $0 <= 0x7e
            }
    }
}

/// Non-`Codable` capability produced only by exact dictionary decoding.
public struct PrimeNativeNeuralGateValidatedLogitDictionary:
    Equatable,
    Sendable
{
    public let replicateContext:
        PrimeNativeNeuralGateCorrectedReplicateContext
    public let orderedFullVocabularyLogitBitPatterns:
        [[UInt32]]
    public let canonicalFileSHA256: String
    public let canonicalFileByteCount: UInt64

    fileprivate init(
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext,
        orderedFullVocabularyLogitBitPatterns:
            [[UInt32]],
        canonicalFileSHA256: String,
        canonicalFileByteCount: UInt64
    ) {
        self.replicateContext = replicateContext
        self.orderedFullVocabularyLogitBitPatterns =
            orderedFullVocabularyLogitBitPatterns
        self.canonicalFileSHA256 =
            canonicalFileSHA256
        self.canonicalFileByteCount =
            canonicalFileByteCount
    }

    public var evaluationSeed: Int {
        replicateContext.evaluationSeed
    }

    public var entryCount: Int {
        orderedFullVocabularyLogitBitPatterns
            .count
    }

    public var orderedFullVocabularyLogits:
        [[Float]]
    {
        orderedFullVocabularyLogitBitPatterns
            .map {
                $0.map(Float.init(bitPattern:))
            }
    }

    public func fullVocabularyLogits(
        at dictionaryIndex: UInt32
    ) throws -> [Float] {
        guard let index = Int(
            exactly: dictionaryIndex
        ),
              orderedFullVocabularyLogitBitPatterns
                .indices.contains(index)
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidDictionaryIndex(
                    dictionaryIndex
                )
        }
        return orderedFullVocabularyLogitBitPatterns[
            index
        ].map(Float.init(bitPattern:))
    }

    public func dictionaryIndex(
        forFullVocabularyLogits logits:
            [Float]
    ) throws -> UInt32 {
        let patterns =
            try PrimeNativeNeuralGateLogitSidecarCodec
            .validatedBitPatterns(
                logits,
                entryIndex: 0
            )
        var lower = 0
        var upper =
            orderedFullVocabularyLogitBitPatterns
            .count
        while lower < upper {
            let midpoint =
                lower + (upper - lower) / 2
            let candidate =
                orderedFullVocabularyLogitBitPatterns[
                    midpoint
                ]
            if candidate == patterns {
                guard let result = UInt32(
                    exactly: midpoint
                ) else {
                    throw PrimeNativeNeuralGateLogitSidecarError
                        .integerOverflow
                }
                return result
            }
            if candidate.lexicographicallyPrecedes(
                patterns
            ) {
                lower = midpoint + 1
            } else {
                upper = midpoint
            }
        }
        throw PrimeNativeNeuralGateLogitSidecarError
            .invalidDictionaryIndex(
                UInt32.max
            )
    }
}

/// Bounded one-vector-at-a-time construction of a canonical dictionary.
///
/// Candidate count is intentionally distinct from unique-entry count:
/// repeated vectors do not consume additional dictionary capacity.
public struct
    PrimeNativeNeuralGateLogitDictionaryAccumulator
{
    public let replicateContext:
        PrimeNativeNeuralGateCorrectedReplicateContext
    public private(set) var admittedCandidateCount =
        0

    private var uniqueEntries =
        Set<[UInt32]>()
    private let maximumUniqueEntryCount: Int
    private let maximumCandidateCount: Int

    public init(
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext
    ) {
        self.replicateContext = replicateContext
        maximumUniqueEntryCount =
            PrimeNativeNeuralGateLogitSidecarPolicy
            .maximumDictionaryEntryCount
        maximumCandidateCount =
            PrimeNativeNeuralGateLogitSidecarPolicy
            .maximumDictionaryCandidateCount
    }

    init(
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext,
        testingMaximumUniqueEntryCount: Int,
        testingMaximumCandidateCount: Int =
            PrimeNativeNeuralGateLogitSidecarPolicy
            .maximumDictionaryCandidateCount
    ) throws {
        guard testingMaximumUniqueEntryCount > 0,
              testingMaximumUniqueEntryCount
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDictionaryEntryCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .dictionaryEntryCountLimitExceeded(
                    observed:
                        testingMaximumUniqueEntryCount
                )
        }
        guard testingMaximumCandidateCount > 0,
              testingMaximumCandidateCount
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDictionaryCandidateCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .dictionaryCandidateCountLimitExceeded(
                    observed:
                        testingMaximumCandidateCount
                )
        }
        self.replicateContext = replicateContext
        maximumUniqueEntryCount =
            testingMaximumUniqueEntryCount
        maximumCandidateCount =
            testingMaximumCandidateCount
    }

    public var uniqueEntryCount: Int {
        uniqueEntries.count
    }

    public mutating func admit(
        fullVocabularyLogits: [Float]
    ) throws {
        let nextCandidateCount =
            admittedCandidateCount
            .addingReportingOverflow(1)
        guard !nextCandidateCount.overflow
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .integerOverflow
        }
        guard nextCandidateCount.partialValue
                <= maximumCandidateCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .dictionaryCandidateCountLimitExceeded(
                    observed:
                        nextCandidateCount
                        .partialValue
                )
        }
        let patterns =
            try PrimeNativeNeuralGateLogitSidecarCodec
            .validatedBitPatterns(
                fullVocabularyLogits,
                entryIndex:
                    admittedCandidateCount
            )
        if !uniqueEntries.contains(patterns) {
            let nextUniqueCount =
                uniqueEntries.count
                .addingReportingOverflow(1)
            guard !nextUniqueCount.overflow
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .integerOverflow
            }
            guard nextUniqueCount.partialValue
                    <= maximumUniqueEntryCount
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .dictionaryEntryCountLimitExceeded(
                        observed:
                            nextUniqueCount
                            .partialValue
                    )
            }
            uniqueEntries.insert(patterns)
        }
        admittedCandidateCount =
            nextCandidateCount.partialValue
    }

    public func finalize() throws -> Data {
        try PrimeNativeNeuralGateLogitSidecarCodec
            .encodeDictionary(
                validatedEntries:
                    Array(uniqueEntries),
                replicateContext:
                    replicateContext
            )
    }
}

public struct PrimeNativeNeuralGateValidatedLogitChunk:
    Equatable,
    Sendable
{
    public let replicateContext:
        PrimeNativeNeuralGateCorrectedReplicateContext
    public let chunkOrdinal: Int
    public let rows:
        [PrimeNativeNeuralGateLogitRowReference]
    public let canonicalFileSHA256: String
    public let canonicalFileByteCount: UInt64

    fileprivate init(
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext,
        chunkOrdinal: Int,
        rows:
            [PrimeNativeNeuralGateLogitRowReference],
        canonicalFileSHA256: String,
        canonicalFileByteCount: UInt64
    ) {
        self.replicateContext = replicateContext
        self.chunkOrdinal = chunkOrdinal
        self.rows = rows
        self.canonicalFileSHA256 =
            canonicalFileSHA256
        self.canonicalFileByteCount =
            canonicalFileByteCount
    }

    public var decisionCount: Int {
        rows.reduce(0) {
            $0 + $1.decisions.count
        }
    }
}

public struct PrimeNativeNeuralGateLogitChunkBinding:
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let rowCount: Int
    public let byteCount: UInt64
    public let sha256: String
}

public struct PrimeNativeNeuralGateValidatedLogitManifest:
    Equatable,
    Sendable
{
    public let replicateContext:
        PrimeNativeNeuralGateCorrectedReplicateContext
    public let dictionaryByteCount: UInt64
    public let dictionarySHA256: String
    public let chunkBindings:
        [PrimeNativeNeuralGateLogitChunkBinding]
    public let rowCount: Int
    public let decisionCount: UInt64
    public let aggregateByteCount: UInt64
    public let aggregateSHA256: String
    public let canonicalFileSHA256: String
    public let canonicalFileByteCount: UInt64
}

public struct PrimeNativeNeuralGateValidatedLogitSidecar:
    Equatable,
    Sendable
{
    public let dictionary:
        PrimeNativeNeuralGateValidatedLogitDictionary
    public let chunks:
        [PrimeNativeNeuralGateValidatedLogitChunk]
    public let manifest:
        PrimeNativeNeuralGateValidatedLogitManifest
}

public enum PrimeNativeNeuralGateLogitSidecarCodec {
    private static let dictionaryMagic =
        Data(
            PrimeNativeNeuralGateLogitSidecarPolicy
                .dictionaryMagic.utf8
        )
    private static let chunkMagic =
        Data(
            PrimeNativeNeuralGateLogitSidecarPolicy
                .chunkMagic.utf8
        )
    private static let manifestMagic =
        Data(
            PrimeNativeNeuralGateLogitSidecarPolicy
                .manifestMagic.utf8
        )
    private static let aggregateDomain =
        Data(
            PrimeNativeNeuralGateLogitSidecarPolicy
                .aggregateDomain.utf8
        )

    public static func encodeDictionary(
        fullVocabularyLogits: [[Float]],
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext
    ) throws -> Data {
        var accumulator =
            PrimeNativeNeuralGateLogitDictionaryAccumulator(
                replicateContext:
                    replicateContext
            )
        for logits in fullVocabularyLogits {
            try accumulator.admit(
                fullVocabularyLogits:
                    logits
            )
        }
        return try accumulator.finalize()
    }

    fileprivate static func encodeDictionary(
        validatedEntries: [[UInt32]],
        replicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext
    ) throws -> Data {
        guard !validatedEntries.isEmpty else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .emptyDictionary
        }
        var entries = validatedEntries
        entries.sort {
            $0.lexicographicallyPrecedes($1)
        }
        guard entries.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDictionaryEntryCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .dictionaryEntryCountLimitExceeded(
                    observed: entries.count
                )
        }
        var data = dictionaryMagic
        appendUInt64(
            UInt64(
                replicateContext.evaluationSeed
            ),
            to: &data
        )
        appendUInt32(
            UInt32(
                PrimeNativeNeuralGateLogitSidecarPolicy
                    .vocabularyCount
            ),
            to: &data
        )
        guard let entryCount = UInt32(
            exactly: entries.count
        ) else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .integerOverflow
        }
        appendUInt32(entryCount, to: &data)
        for entry in entries {
            for pattern in entry {
                appendUInt32(pattern, to: &data)
            }
        }
        guard data.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDictionaryFileByteCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .dictionaryFileByteLimitExceeded
        }
        return data
    }

    public static func decodeDictionary(
        _ data: Data,
        expectedReplicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext?
            = nil
    ) throws
        -> PrimeNativeNeuralGateValidatedLogitDictionary
    {
        guard data.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDictionaryFileByteCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .dictionaryFileByteLimitExceeded
        }
        var reader = Reader(data)
        guard try reader.read(
            dictionaryMagic.count
        ) == dictionaryMagic else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidMagic
        }
        let context = try replicateContext(
            encodedSeed:
                try reader.readUInt64(),
            expected: expectedReplicateContext
        )
        guard try reader.readUInt32()
                == UInt32(
                    PrimeNativeNeuralGateLogitSidecarPolicy
                        .vocabularyCount
                )
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidDeclaredVocabularyCount
        }
        let encodedCount =
            try reader.readUInt32()
        guard encodedCount > 0,
              let count = Int(
                  exactly: encodedCount
              ),
              count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDictionaryEntryCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidDeclaredEntryCount
        }
        var entries: [[UInt32]] = []
        entries.reserveCapacity(count)
        for entryIndex in 0 ..< count {
            var entry: [UInt32] = []
            entry.reserveCapacity(
                PrimeNativeNeuralGateLogitSidecarPolicy
                    .vocabularyCount
            )
            for tokenID in
                0 ..<
                PrimeNativeNeuralGateLogitSidecarPolicy
                    .vocabularyCount
            {
                let pattern =
                    try reader.readUInt32()
                guard Float(
                    bitPattern: pattern
                ).isFinite else {
                    throw PrimeNativeNeuralGateLogitSidecarError
                        .nonfiniteLogit(
                            entryIndex:
                                entryIndex,
                            tokenID: tokenID
                        )
                }
                entry.append(pattern)
            }
            if let previous = entries.last,
               !previous.lexicographicallyPrecedes(
                   entry
               )
            {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidDictionaryOrdering
            }
            entries.append(entry)
        }
        guard reader.isAtEnd else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .trailingInput
        }
        return PrimeNativeNeuralGateValidatedLogitDictionary(
            replicateContext: context,
            orderedFullVocabularyLogitBitPatterns:
                entries,
            canonicalFileSHA256: sha256(data),
            canonicalFileByteCount:
                UInt64(data.count)
        )
    }

    public static func encodeChunk(
        rows:
            [PrimeNativeNeuralGateLogitRowReference],
        chunkOrdinal: Int,
        dictionary:
            PrimeNativeNeuralGateValidatedLogitDictionary
    ) throws -> Data {
        guard (0 ..<
            PrimeNativeNeuralGateLogitSidecarPolicy
                .exactChunkCount)
            .contains(chunkOrdinal)
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidChunkOrdinal
        }
        guard !rows.isEmpty,
              rows.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .rowsPerChunk
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidRowCount
        }
        let expectedFirst =
            chunkOrdinal
            * PrimeNativeNeuralGateLogitSidecarPolicy
            .rowsPerChunk
        var correlationIDs = Set<String>()
        var data = chunkMagic
        appendUInt64(
            UInt64(
                dictionary.evaluationSeed
            ),
            to: &data
        )
        appendUInt32(
            UInt32(chunkOrdinal),
            to: &data
        )
        appendUInt32(
            UInt32(rows.count),
            to: &data
        )
        for (
            rowOffset,
            row
        ) in rows.enumerated() {
            let expected =
                expectedFirst + rowOffset
            guard row.rowOrdinal == expected else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidRowOrdinal(
                        expected: expected,
                        observed: row.rowOrdinal
                    )
            }
            guard correlationIDs.insert(
                row.correlationID
            ).inserted else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .duplicateCorrelationID
            }
            appendUInt32(
                UInt32(row.rowOrdinal),
                to: &data
            )
            let correlationBytes =
                Array(row.correlationID.utf8)
            guard PrimeNativeNeuralGateLogitRowReference
                    .isValidCorrelationID(
                        row.correlationID
                    ),
                  let correlationCount =
                    UInt16(
                        exactly:
                            correlationBytes.count
                    )
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidCorrelationID
            }
            appendUInt16(
                correlationCount,
                to: &data
            )
            data.append(
                contentsOf: correlationBytes
            )
            guard !row.decisions.isEmpty,
                  row.decisions.count
                    <= PrimeNativeNeuralGateLogitSidecarPolicy
                    .maximumDecisionsPerRow,
                  row.decisions.map(\.ordinal)
                    == Array(
                        1 ... row.decisions.count
                    ),
                  let decisionCount =
                    UInt8(
                        exactly:
                            row.decisions.count
                    )
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidDecisionCount
            }
            data.append(decisionCount)
            for decision in row.decisions {
                guard let ordinal = UInt8(
                    exactly: decision.ordinal
                ) else {
                    throw PrimeNativeNeuralGateLogitSidecarError
                        .integerOverflow
                }
                guard Int(
                    decision.dictionaryIndex
                ) < dictionary.entryCount
                else {
                    throw PrimeNativeNeuralGateLogitSidecarError
                        .invalidDictionaryIndex(
                            decision
                                .dictionaryIndex
                        )
                }
                data.append(ordinal)
                appendUInt32(
                    decision.dictionaryIndex,
                    to: &data
                )
            }
        }
        guard data.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumChunkFileByteCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .chunkFileByteLimitExceeded
        }
        return data
    }

    public static func decodeChunk(
        _ data: Data,
        dictionary:
            PrimeNativeNeuralGateValidatedLogitDictionary,
        expectedChunkOrdinal: Int? = nil
    ) throws
        -> PrimeNativeNeuralGateValidatedLogitChunk
    {
        guard data.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumChunkFileByteCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .chunkFileByteLimitExceeded
        }
        var reader = Reader(data)
        guard try reader.read(
            chunkMagic.count
        ) == chunkMagic else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidMagic
        }
        _ = try replicateContext(
            encodedSeed:
                try reader.readUInt64(),
            expected: dictionary.replicateContext
        )
        let encodedOrdinal =
            try reader.readUInt32()
        guard let ordinal = Int(
            exactly: encodedOrdinal
        ),
              (0 ..<
                PrimeNativeNeuralGateLogitSidecarPolicy
                    .exactChunkCount)
                .contains(ordinal),
              expectedChunkOrdinal == nil
                || expectedChunkOrdinal == ordinal
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidChunkOrdinal
        }
        let encodedRowCount =
            try reader.readUInt32()
        guard encodedRowCount > 0,
              let rowCount = Int(
                  exactly: encodedRowCount
              ),
              rowCount
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .rowsPerChunk
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidRowCount
        }
        let expectedFirst =
            ordinal
            * PrimeNativeNeuralGateLogitSidecarPolicy
            .rowsPerChunk
        var rows:
            [PrimeNativeNeuralGateLogitRowReference] = []
        rows.reserveCapacity(rowCount)
        var correlations = Set<String>()
        for rowOffset in 0 ..< rowCount {
            let encodedRowOrdinal =
                try reader.readUInt32()
            guard let rowOrdinal = Int(
                exactly: encodedRowOrdinal
            ) else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .integerOverflow
            }
            let expected =
                expectedFirst + rowOffset
            guard rowOrdinal == expected else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidRowOrdinal(
                        expected: expected,
                        observed: rowOrdinal
                    )
            }
            let correlationCount =
                Int(try reader.readUInt16())
            guard correlationCount > 0,
                  correlationCount
                    <= PrimeNativeNeuralGateLogitSidecarPolicy
                    .maximumCorrelationIDByteCount
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidCorrelationID
            }
            let correlationData =
                try reader.read(
                    correlationCount
                )
            let correlationBytes =
                Array(correlationData)
            guard correlationBytes.allSatisfy({
                $0 >= 0x21 && $0 <= 0x7e
            }),
                  let correlationID = String(
                      bytes: correlationBytes,
                      encoding: .ascii
                  )
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidCorrelationID
            }
            guard correlations.insert(
                correlationID
            ).inserted else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .duplicateCorrelationID
            }
            let decisionCount =
                Int(try reader.readUInt8())
            guard decisionCount > 0,
                  decisionCount
                    <= PrimeNativeNeuralGateLogitSidecarPolicy
                    .maximumDecisionsPerRow
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidDecisionCount
            }
            var decisions:
                [PrimeNativeNeuralGateLogitDecisionReference] = []
            decisions.reserveCapacity(
                decisionCount
            )
            for offset in 0 ..< decisionCount {
                let observedOrdinal =
                    Int(try reader.readUInt8())
                let expectedOrdinal = offset + 1
                guard observedOrdinal
                        == expectedOrdinal
                else {
                    throw PrimeNativeNeuralGateLogitSidecarError
                        .invalidDecisionOrdinal(
                            expected:
                                expectedOrdinal,
                            observed:
                                observedOrdinal
                        )
                }
                let index =
                    try reader.readUInt32()
                guard Int(index)
                        < dictionary.entryCount
                else {
                    throw PrimeNativeNeuralGateLogitSidecarError
                        .invalidDictionaryIndex(
                            index
                        )
                }
                decisions.append(
                    try PrimeNativeNeuralGateLogitDecisionReference(
                        ordinal: observedOrdinal,
                        dictionaryIndex: index
                    )
                )
            }
            rows.append(
                try PrimeNativeNeuralGateLogitRowReference(
                    rowOrdinal: rowOrdinal,
                    correlationID:
                        correlationID,
                    decisions: decisions
                )
            )
        }
        guard reader.isAtEnd else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .trailingInput
        }
        return PrimeNativeNeuralGateValidatedLogitChunk(
            replicateContext:
                dictionary.replicateContext,
            chunkOrdinal: ordinal,
            rows: rows,
            canonicalFileSHA256:
                sha256(data),
            canonicalFileByteCount:
                UInt64(data.count)
        )
    }

    public static func encodeManifest(
        dictionaryData: Data,
        chunkData: [Data],
        expectedReplicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext?
            = nil
    ) throws -> Data {
        let dictionary = try decodeDictionary(
            dictionaryData,
            expectedReplicateContext:
                expectedReplicateContext
        )
        let chunks = try validatedCompleteChunks(
            chunkData,
            dictionary: dictionary
        )
        let aggregate =
            try aggregateBinding(
                dictionaryData: dictionaryData,
                chunkData: chunkData
            )
        let decisionCount =
            try checkedDecisionCount(chunks)

        var data = manifestMagic
        appendUInt64(
            UInt64(dictionary.evaluationSeed),
            to: &data
        )
        appendUInt64(
            dictionary.canonicalFileByteCount,
            to: &data
        )
        try appendSHA256(
            dictionary.canonicalFileSHA256,
            to: &data
        )
        appendUInt32(
            UInt32(chunks.count),
            to: &data
        )
        appendUInt32(
            UInt32(
                PrimeNativeNeuralGateLogitSidecarPolicy
                    .exactRowCount
            ),
            to: &data
        )
        appendUInt64(decisionCount, to: &data)
        for chunk in chunks {
            appendUInt32(
                UInt32(chunk.chunkOrdinal),
                to: &data
            )
            appendUInt32(
                UInt32(chunk.rows.count),
                to: &data
            )
            appendUInt64(
                chunk.canonicalFileByteCount,
                to: &data
            )
            try appendSHA256(
                chunk.canonicalFileSHA256,
                to: &data
            )
        }
        appendUInt64(
            aggregate.byteCount,
            to: &data
        )
        try appendSHA256(
            aggregate.sha256,
            to: &data
        )
        guard data.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumManifestFileByteCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .manifestFileByteLimitExceeded
        }
        return data
    }

    public static func decodeManifest(
        _ data: Data,
        expectedReplicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext?
            = nil
    ) throws
        -> PrimeNativeNeuralGateValidatedLogitManifest
    {
        guard data.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumManifestFileByteCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .manifestFileByteLimitExceeded
        }
        var reader = Reader(data)
        guard try reader.read(
            manifestMagic.count
        ) == manifestMagic else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidMagic
        }
        let context = try replicateContext(
            encodedSeed:
                try reader.readUInt64(),
            expected: expectedReplicateContext
        )
        let dictionaryByteCount =
            try reader.readUInt64()
        guard dictionaryByteCount > 0,
              dictionaryByteCount
                <= UInt64(
                    PrimeNativeNeuralGateLogitSidecarPolicy
                        .maximumDictionaryFileByteCount
                )
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .dictionaryFileByteLimitExceeded
        }
        let dictionarySHA256 =
            try reader.readSHA256()
        let chunkCount =
            try reader.readUInt32()
        guard chunkCount
                == UInt32(
                    PrimeNativeNeuralGateLogitSidecarPolicy
                        .exactChunkCount
                )
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidChunkPartition
        }
        let rowCount =
            try reader.readUInt32()
        guard rowCount
                == UInt32(
                    PrimeNativeNeuralGateLogitSidecarPolicy
                        .exactRowCount
                )
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidRowCount
        }
        let decisionCount =
            try reader.readUInt64()
        guard decisionCount
                >= UInt64(rowCount),
              decisionCount
                <= UInt64(rowCount)
                    * UInt64(
                        PrimeNativeNeuralGateLogitSidecarPolicy
                            .maximumDecisionsPerRow
                    )
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidDecisionCount
        }
        var bindings:
            [PrimeNativeNeuralGateLogitChunkBinding] = []
        bindings.reserveCapacity(Int(chunkCount))
        var boundFileByteCount =
            dictionaryByteCount
        for expectedOrdinal in
            0 ..< Int(chunkCount)
        {
            let ordinal =
                try reader.readUInt32()
            guard ordinal
                    == UInt32(expectedOrdinal)
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidChunkOrdinal
            }
            let bindingRowCount =
                try reader.readUInt32()
            guard bindingRowCount
                    == UInt32(
                        PrimeNativeNeuralGateLogitSidecarPolicy
                            .rowsPerChunk
                    )
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidChunkPartition
            }
            let byteCount =
                try reader.readUInt64()
            guard byteCount > 0,
                  byteCount
                    <= UInt64(
                        PrimeNativeNeuralGateLogitSidecarPolicy
                            .maximumChunkFileByteCount
                    )
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .chunkFileByteLimitExceeded
            }
            let nextBoundFileByteCount =
                boundFileByteCount
                .addingReportingOverflow(byteCount)
            guard !nextBoundFileByteCount
                    .overflow
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .integerOverflow
            }
            boundFileByteCount =
                nextBoundFileByteCount
                .partialValue
            bindings.append(
                PrimeNativeNeuralGateLogitChunkBinding(
                    ordinal: expectedOrdinal,
                    rowCount:
                        Int(bindingRowCount),
                    byteCount: byteCount,
                    sha256:
                        try reader.readSHA256()
                )
            )
        }
        let aggregateByteCount =
            try reader.readUInt64()
        guard aggregateByteCount > 0,
              aggregateByteCount
                <= UInt64(
                    PrimeNativeNeuralGateLogitSidecarPolicy
                        .maximumAggregateFileByteCount
                )
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .aggregateByteLimitExceeded
        }
        guard aggregateByteCount
                == boundFileByteCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .aggregateBindingMismatch
        }
        let aggregateSHA256 =
            try reader.readSHA256()
        guard reader.isAtEnd else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .trailingInput
        }
        return PrimeNativeNeuralGateValidatedLogitManifest(
            replicateContext: context,
            dictionaryByteCount:
                dictionaryByteCount,
            dictionarySHA256:
                dictionarySHA256,
            chunkBindings: bindings,
            rowCount: Int(rowCount),
            decisionCount: decisionCount,
            aggregateByteCount:
                aggregateByteCount,
            aggregateSHA256:
                aggregateSHA256,
            canonicalFileSHA256: sha256(data),
            canonicalFileByteCount:
                UInt64(data.count)
        )
    }

    public static func validateCompleteSidecar(
        dictionaryData: Data,
        chunkData: [Data],
        manifestData: Data,
        expectedReplicateContext:
            PrimeNativeNeuralGateCorrectedReplicateContext?
            = nil
    ) throws
        -> PrimeNativeNeuralGateValidatedLogitSidecar
    {
        let dictionary = try decodeDictionary(
            dictionaryData,
            expectedReplicateContext:
                expectedReplicateContext
        )
        let chunks = try validatedCompleteChunks(
            chunkData,
            dictionary: dictionary
        )
        let manifest = try decodeManifest(
            manifestData,
            expectedReplicateContext:
                dictionary.replicateContext
        )
        guard manifest.dictionaryByteCount
                == dictionary.canonicalFileByteCount,
              manifest.dictionarySHA256
                == dictionary.canonicalFileSHA256
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .dictionaryBindingMismatch
        }
        let bindings = chunks.map {
            PrimeNativeNeuralGateLogitChunkBinding(
                ordinal: $0.chunkOrdinal,
                rowCount: $0.rows.count,
                byteCount:
                    $0.canonicalFileByteCount,
                sha256:
                    $0.canonicalFileSHA256
            )
        }
        guard bindings
                == manifest.chunkBindings,
              try checkedDecisionCount(chunks)
                == manifest.decisionCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .chunkBindingMismatch
        }
        let aggregate = try aggregateBinding(
            dictionaryData: dictionaryData,
            chunkData: chunkData
        )
        guard aggregate.byteCount
                == manifest.aggregateByteCount,
              aggregate.sha256
                == manifest.aggregateSHA256
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .aggregateBindingMismatch
        }
        return PrimeNativeNeuralGateValidatedLogitSidecar(
            dictionary: dictionary,
            chunks: chunks,
            manifest: manifest
        )
    }

    public static func aggregateSHA256(
        dictionaryData: Data,
        chunkData: [Data]
    ) throws -> String {
        try aggregateBinding(
            dictionaryData: dictionaryData,
            chunkData: chunkData
        ).sha256
    }

    fileprivate static func validatedBitPatterns(
        _ logits: [Float],
        entryIndex: Int
    ) throws -> [UInt32] {
        guard logits.count
                == PrimeNativeNeuralGateLogitSidecarPolicy
                .vocabularyCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidVocabularyCount(
                    entryIndex: entryIndex,
                    observed: logits.count
                )
        }
        var patterns: [UInt32] = []
        patterns.reserveCapacity(logits.count)
        for (
            tokenID,
            value
        ) in logits.enumerated() {
            guard value.isFinite else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .nonfiniteLogit(
                        entryIndex: entryIndex,
                        tokenID: tokenID
                    )
            }
            patterns.append(value.bitPattern)
        }
        return patterns
    }

    private static func validatedCompleteChunks(
        _ chunkData: [Data],
        dictionary:
            PrimeNativeNeuralGateValidatedLogitDictionary
    ) throws
        -> [PrimeNativeNeuralGateValidatedLogitChunk]
    {
        guard chunkData.count
                == PrimeNativeNeuralGateLogitSidecarPolicy
                .exactChunkCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidChunkPartition
        }
        var chunks:
            [PrimeNativeNeuralGateValidatedLogitChunk] = []
        chunks.reserveCapacity(chunkData.count)
        var correlations = Set<String>()
        var referencedDictionaryEntries = Array(
            repeating: false,
            count:
                dictionary
                .orderedFullVocabularyLogitBitPatterns
                .count
        )
        for (
            ordinal,
            data
        ) in chunkData.enumerated() {
            let chunk = try decodeChunk(
                data,
                dictionary: dictionary,
                expectedChunkOrdinal: ordinal
            )
            guard chunk.rows.count
                    == PrimeNativeNeuralGateLogitSidecarPolicy
                    .rowsPerChunk
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .invalidChunkPartition
            }
            for row in chunk.rows {
                guard correlations.insert(
                    row.correlationID
                ).inserted else {
                    throw PrimeNativeNeuralGateLogitSidecarError
                        .duplicateCorrelationID
                }
                for decision in row.decisions {
                    referencedDictionaryEntries[
                        Int(decision.dictionaryIndex)
                    ] = true
                }
            }
            chunks.append(chunk)
        }
        guard chunks.reduce(0, {
            $0 + $1.rows.count
        }) == PrimeNativeNeuralGateLogitSidecarPolicy
            .exactRowCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidChunkPartition
        }
        if let unreferencedIndex =
            referencedDictionaryEntries
            .firstIndex(of: false)
        {
            guard let encodedIndex =
                UInt32(exactly: unreferencedIndex)
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .integerOverflow
            }
            throw PrimeNativeNeuralGateLogitSidecarError
                .unreferencedDictionaryEntry(
                    encodedIndex
                )
        }
        return chunks
    }

    private static func checkedDecisionCount(
        _ chunks:
            [PrimeNativeNeuralGateValidatedLogitChunk]
    ) throws -> UInt64 {
        var total: UInt64 = 0
        for chunk in chunks {
            let next = total.addingReportingOverflow(
                UInt64(chunk.decisionCount)
            )
            guard !next.overflow else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .integerOverflow
            }
            total = next.partialValue
        }
        return total
    }

    private static func aggregateBinding(
        dictionaryData: Data,
        chunkData: [Data]
    ) throws -> (
        byteCount: UInt64,
        sha256: String
    ) {
        guard dictionaryData.count
                <= PrimeNativeNeuralGateLogitSidecarPolicy
                .maximumDictionaryFileByteCount,
              chunkData.allSatisfy({
                  $0.count
                      <= PrimeNativeNeuralGateLogitSidecarPolicy
                      .maximumChunkFileByteCount
              })
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .aggregateByteLimitExceeded
        }
        guard chunkData.count
                == PrimeNativeNeuralGateLogitSidecarPolicy
                .exactChunkCount
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidChunkPartition
        }
        var aggregateBytes: UInt64 = 0
        var hasher = SHA256()
        hasher.update(data: aggregateDomain)
        for file in [dictionaryData] + chunkData {
            guard let byteCount = UInt64(
                exactly: file.count
            ) else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .integerOverflow
            }
            let next =
                aggregateBytes
                .addingReportingOverflow(byteCount)
            guard !next.overflow,
                  next.partialValue
                    <= UInt64(
                        PrimeNativeNeuralGateLogitSidecarPolicy
                            .maximumAggregateFileByteCount
                    )
            else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .aggregateByteLimitExceeded
            }
            aggregateBytes = next.partialValue
            var lengthData = Data()
            appendUInt64(
                byteCount,
                to: &lengthData
            )
            hasher.update(data: lengthData)
            hasher.update(data: file)
        }
        return (
            aggregateBytes,
            hasher.finalize().map {
                String(format: "%02x", $0)
            }.joined()
        )
    }

    private static func replicateContext(
        encodedSeed: UInt64,
        expected:
            PrimeNativeNeuralGateCorrectedReplicateContext?
    ) throws
        -> PrimeNativeNeuralGateCorrectedReplicateContext
    {
        guard let seed = Int(
            exactly: encodedSeed
        ),
              let context = try? PrimeNativeNeuralGateCorrectedReplicateContext(
                  evaluationSeed: seed
              )
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidEvaluationSeed
        }
        guard expected == nil
                || expected == context
        else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .evaluationSeedMismatch
        }
        return context
    }

    private static func sha256(
        _ data: Data
    ) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }

    private static func appendSHA256(
        _ value: String,
        to data: inout Data
    ) throws {
        guard let bytes = hexadecimalBytes(
            value
        ), bytes.count == 32 else {
            throw PrimeNativeNeuralGateLogitSidecarError
                .invalidSHA256
        }
        data.append(contentsOf: bytes)
    }

    private static func hexadecimalBytes(
        _ value: String
    ) -> [UInt8]? {
        let bytes = Array(value.utf8)
        guard bytes.count == 64 else {
            return nil
        }
        var result: [UInt8] = []
        result.reserveCapacity(32)
        var index = 0
        while index < bytes.count {
            guard let high = hexadecimalNibble(
                bytes[index]
            ),
                  let low = hexadecimalNibble(
                      bytes[index + 1]
                  )
            else {
                return nil
            }
            result.append(high << 4 | low)
            index += 2
        }
        return result
    }

    private static func hexadecimalNibble(
        _ byte: UInt8
    ) -> UInt8? {
        switch byte {
        case 48 ... 57:
            byte - 48
        case 97 ... 102:
            byte - 87
        default:
            nil
        }
    }

    private static func appendUInt16(
        _ value: UInt16,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }

    private static func appendUInt32(
        _ value: UInt32,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
    }

    private static func appendUInt64(
        _ value: UInt64,
        to data: inout Data
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.append(contentsOf: $0)
        }
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
                throw PrimeNativeNeuralGateLogitSidecarError
                    .truncatedInput
            }
            let end = data.index(
                offset,
                offsetBy: count
            )
            let result = data.subdata(
                in: offset ..< end
            )
            offset = end
            return result
        }

        mutating func readUInt8() throws -> UInt8 {
            guard offset < data.endIndex else {
                throw PrimeNativeNeuralGateLogitSidecarError
                    .truncatedInput
            }
            let value = data[offset]
            data.formIndex(after: &offset)
            return value
        }

        mutating func readUInt16()
            throws -> UInt16
        {
            var value: UInt16 = 0
            for _ in 0 ..< 2 {
                value =
                    (value << 8)
                    | UInt16(try readUInt8())
            }
            return value
        }

        mutating func readUInt32()
            throws -> UInt32
        {
            var value: UInt32 = 0
            for _ in 0 ..< 4 {
                value =
                    (value << 8)
                    | UInt32(try readUInt8())
            }
            return value
        }

        mutating func readUInt64()
            throws -> UInt64
        {
            var value: UInt64 = 0
            for _ in 0 ..< 8 {
                value =
                    (value << 8)
                    | UInt64(try readUInt8())
            }
            return value
        }

        mutating func readSHA256()
            throws -> String
        {
            try read(32).map {
                String(format: "%02x", $0)
            }.joined()
        }
    }
}
