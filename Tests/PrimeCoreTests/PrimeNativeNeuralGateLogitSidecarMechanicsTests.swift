import Foundation
import PrimeNativeNeuralGateCorrectedMechanics
@testable import PrimeNativeNeuralGateLogitSidecarMechanics
import XCTest

final class
    PrimeNativeNeuralGateLogitSidecarMechanicsTests:
    XCTestCase
{
    private typealias Policy =
        PrimeNativeNeuralGateLogitSidecarPolicy
    private typealias Codec =
        PrimeNativeNeuralGateLogitSidecarCodec
    private typealias SidecarError =
        PrimeNativeNeuralGateLogitSidecarError
    private typealias Context =
        PrimeNativeNeuralGateCorrectedReplicateContext

    func testPolicyIsExactAndAllAuthorityNonclaimsRemainClosed()
    {
        XCTAssertEqual(
            Policy.codecID,
            "prime_stage_b_full_vocabulary_logit_sidecar_dictionary_deduplicated_row_index_chunks_big_endian_v1"
        )
        XCTAssertEqual(
            Policy.dictionaryMagic,
            "PRMLGD01"
        )
        XCTAssertEqual(
            Policy.chunkMagic,
            "PRMLGC01"
        )
        XCTAssertEqual(
            Policy.manifestMagic,
            "PRMLGM01"
        )
        XCTAssertEqual(
            Policy.aggregateDomain,
            "PRMLGA01"
        )
        XCTAssertEqual(Policy.vocabularyCount, 512)
        XCTAssertEqual(
            Policy.maximumDictionaryEntryCount,
            65_536
        )
        XCTAssertEqual(
            Policy.maximumDictionaryCandidateCount,
            1_179_648
        )
        XCTAssertEqual(
            Policy.maximumDecisionsPerRow,
            64
        )
        XCTAssertEqual(Policy.exactRowCount, 18_432)
        XCTAssertEqual(Policy.rowsPerChunk, 1_024)
        XCTAssertEqual(Policy.exactChunkCount, 18)
        XCTAssertEqual(
            Policy.maximumDictionaryFileByteCount,
            256 * 1_024 * 1_024
        )
        XCTAssertEqual(
            Policy.maximumChunkFileByteCount,
            1 * 1_024 * 1_024
        )
        XCTAssertEqual(
            Policy.maximumManifestFileByteCount,
            64 * 1_024
        )
        XCTAssertEqual(
            Policy.maximumAggregateFileByteCount,
            512 * 1_024 * 1_024
        )
        XCTAssertFalse(Policy.executionImplemented)
        XCTAssertFalse(Policy.durableArtifactPublished)
        XCTAssertFalse(Policy.modelExecutionClaimed)
        XCTAssertFalse(
            Policy.metalExecutionAuthorityClaimed
        )
        XCTAssertFalse(
            Policy.scientificIndependenceClaimed
        )
        XCTAssertFalse(
            Policy.terminalReceiptAuthorized
        )
    }

    func testDictionaryCanonicalizesDeduplicatesAndRoundTripsExactBits()
        throws
    {
        let context = try Context(
            evaluationSeed: 1_618
        )
        let selected70 =
            structuralVector(selectedTokenID: 70)
        let selected256 =
            structuralVector(selectedTokenID: 256)
        let data = try Codec.encodeDictionary(
            fullVocabularyLogits: [
                selected256,
                selected70,
                selected256,
            ],
            replicateContext: context
        )
        let decoded = try Codec.decodeDictionary(
            data,
            expectedReplicateContext: context
        )
        let reencoded = try Codec.encodeDictionary(
            fullVocabularyLogits:
                decoded.orderedFullVocabularyLogits,
            replicateContext: context
        )

        XCTAssertEqual(decoded.evaluationSeed, 1_618)
        XCTAssertEqual(decoded.entryCount, 2)
        XCTAssertEqual(
            decoded.canonicalFileByteCount,
            UInt64(data.count)
        )
        XCTAssertEqual(
            decoded.canonicalFileSHA256.count,
            64
        )
        XCTAssertEqual(data, reencoded)
        XCTAssertEqual(
            try decoded.fullVocabularyLogits(
                at: try decoded.dictionaryIndex(
                    forFullVocabularyLogits:
                        selected70
                )
            ),
            selected70
        )
        XCTAssertEqual(
            try decoded.fullVocabularyLogits(
                at: try decoded.dictionaryIndex(
                    forFullVocabularyLogits:
                        selected256
                )
            ),
            selected256
        )
        XCTAssertEqual(
            Array(data.prefix(8)),
            Array(Policy.dictionaryMagic.utf8)
        )

        var slicedEnvelope = Data(
            repeating: 0xa5,
            count: 7
        )
        slicedEnvelope.append(data)
        slicedEnvelope.append(0x5a)
        let slicedData =
            slicedEnvelope[
                7 ..< 7 + data.count
            ]
        XCTAssertEqual(slicedData.startIndex, 7)
        XCTAssertEqual(
            try Codec.decodeDictionary(
                slicedData,
                expectedReplicateContext:
                    context
            ),
            decoded
        )
        assertDictionaryError(
            slicedEnvelope[
                7 ..< 7 + data.count - 1
            ],
            context: context,
            expected: .truncatedInput
        )
    }

    func testDictionaryMalformedOrderingNonfiniteBoundsAndSeedFailClosed()
        throws
    {
        let context = try Context(
            evaluationSeed: 1_618
        )
        let data = try Codec.encodeDictionary(
            fullVocabularyLogits: [
                structuralVector(
                    selectedTokenID: 70
                ),
                structuralVector(
                    selectedTokenID: 256
                ),
            ],
            replicateContext: context
        )

        var badMagic = data
        badMagic[0] ^= 0xff
        assertDictionaryError(
            badMagic,
            context: context,
            expected: .invalidMagic
        )

        var wrongSeed = data
        replaceUInt64(
            2_718,
            in: &wrongSeed,
            at: 8
        )
        assertDictionaryError(
            wrongSeed,
            context: context,
            expected: .evaluationSeedMismatch
        )

        var invalidSeed = data
        replaceUInt64(
            9_999,
            in: &invalidSeed,
            at: 8
        )
        assertDictionaryError(
            invalidSeed,
            context: nil,
            expected: .invalidEvaluationSeed
        )

        var nonfinite = data
        replaceUInt32(
            0x7f80_0000,
            in: &nonfinite,
            at: 24
        )
        XCTAssertThrowsError(
            try Codec.decodeDictionary(
                nonfinite
            )
        ) {
            guard case .nonfiniteLogit =
                    $0 as? SidecarError
            else {
                return XCTFail(
                    "unexpected error: \($0)"
                )
            }
        }

        let entryByteCount = 512 * 4
        var duplicate = data
        duplicate.replaceSubrange(
            (24 + entryByteCount)
                ..< (24 + 2 * entryByteCount),
            with:
                data[
                    24
                        ..< (24 + entryByteCount)
                ]
        )
        assertDictionaryError(
            duplicate,
            context: context,
            expected: .invalidDictionaryOrdering
        )

        var reversed = data
        let first = Data(
            data[
                24 ..< (24 + entryByteCount)
            ]
        )
        let second = Data(
            data[
                (24 + entryByteCount)
                    ..< (24 + 2 * entryByteCount)
            ]
        )
        reversed.replaceSubrange(
            24 ..< (24 + entryByteCount),
            with: second
        )
        reversed.replaceSubrange(
            (24 + entryByteCount)
                ..< (24 + 2 * entryByteCount),
            with: first
        )
        assertDictionaryError(
            reversed,
            context: context,
            expected: .invalidDictionaryOrdering
        )

        var trailing = data
        trailing.append(0)
        assertDictionaryError(
            trailing,
            context: context,
            expected: .trailingInput
        )

        XCTAssertThrowsError(
            try Codec.encodeDictionary(
                fullVocabularyLogits: [],
                replicateContext: context
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .emptyDictionary
            )
        }

        var nanVector =
            structuralVector(selectedTokenID: 70)
        nanVector[11] = .nan
        XCTAssertThrowsError(
            try Codec.encodeDictionary(
                fullVocabularyLogits: [
                    nanVector,
                ],
                replicateContext: context
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .nonfiniteLogit(
                    entryIndex: 0,
                    tokenID: 11
                )
            )
        }

        let oversized = Data(
            repeating: 0,
            count:
                Policy
                .maximumDictionaryFileByteCount
                + 1
        )
        assertDictionaryError(
            oversized,
            context: nil,
            expected:
                .dictionaryFileByteLimitExceeded
        )
    }

    func testStreamingAccumulatorBoundsUniqueEntriesNotCandidateCount()
        throws
    {
        let context = try Context(
            evaluationSeed: 1_618
        )
        let selected70 =
            structuralVector(selectedTokenID: 70)
        var accumulator =
            PrimeNativeNeuralGateLogitDictionaryAccumulator(
                replicateContext: context
            )
        for _ in 0 ..< 3 {
            try accumulator.admit(
                fullVocabularyLogits:
                    selected70
            )
        }
        XCTAssertEqual(
            accumulator.admittedCandidateCount,
            3
        )
        XCTAssertEqual(
            accumulator.uniqueEntryCount,
            1
        )
        XCTAssertEqual(
            try accumulator.finalize(),
            try Codec.encodeDictionary(
                fullVocabularyLogits: [
                    selected70,
                    selected70,
                    selected70,
                ],
                replicateContext: context
            )
        )

        let repeatedCandidates = Array(
            repeating: selected70,
            count:
                Policy.maximumDictionaryEntryCount
                + 1
        )
        let repeatedData =
            try Codec.encodeDictionary(
                fullVocabularyLogits:
                    repeatedCandidates,
                replicateContext: context
            )
        XCTAssertEqual(
            try Codec.decodeDictionary(
                repeatedData
            ).entryCount,
            1
        )

        var bounded =
            try PrimeNativeNeuralGateLogitDictionaryAccumulator(
                replicateContext: context,
                testingMaximumUniqueEntryCount:
                    2
            )
        try bounded.admit(
            fullVocabularyLogits:
                structuralVector(
                    selectedTokenID: 70
                )
        )
        try bounded.admit(
            fullVocabularyLogits:
                structuralVector(
                    selectedTokenID: 256
                )
        )
        XCTAssertThrowsError(
            try bounded.admit(
                fullVocabularyLogits:
                    structuralVector(
                        selectedTokenID: 511
                    )
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .dictionaryEntryCountLimitExceeded(
                    observed: 3
                )
            )
        }
        XCTAssertEqual(
            bounded.admittedCandidateCount,
            2
        )
        XCTAssertEqual(
            bounded.uniqueEntryCount,
            2
        )

        var candidateBounded =
            try PrimeNativeNeuralGateLogitDictionaryAccumulator(
                replicateContext: context,
                testingMaximumUniqueEntryCount:
                    2,
                testingMaximumCandidateCount:
                    3
            )
        for _ in 0 ..< 3 {
            try candidateBounded.admit(
                fullVocabularyLogits:
                    selected70
            )
        }
        XCTAssertThrowsError(
            try candidateBounded.admit(
                fullVocabularyLogits:
                    selected70
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .dictionaryCandidateCountLimitExceeded(
                    observed: 4
                )
            )
        }
        XCTAssertEqual(
            candidateBounded
                .admittedCandidateCount,
            3
        )
        XCTAssertEqual(
            candidateBounded.uniqueEntryCount,
            1
        )

        let empty =
            PrimeNativeNeuralGateLogitDictionaryAccumulator(
                replicateContext: context
            )
        XCTAssertThrowsError(
            try empty.finalize()
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .emptyDictionary
            )
        }
    }

    func testChunkRoundTripAndMutationsFailClosed()
        throws
    {
        let context = try Context(
            evaluationSeed: 1_618
        )
        let dictionaryData =
            try Codec.encodeDictionary(
                fullVocabularyLogits: [
                    structuralVector(
                        selectedTokenID: 70
                    ),
                ],
                replicateContext: context
            )
        let dictionary =
            try Codec.decodeDictionary(
                dictionaryData
            )
        let rows = try (0 ..< 2).map {
            try row(
                ordinal: $0,
                correlationID:
                    correlationID($0),
                dictionaryIndex: 0,
                decisionCount: $0 + 1
            )
        }
        let data = try Codec.encodeChunk(
            rows: rows,
            chunkOrdinal: 0,
            dictionary: dictionary
        )
        let decoded = try Codec.decodeChunk(
            data,
            dictionary: dictionary,
            expectedChunkOrdinal: 0
        )

        XCTAssertEqual(decoded.rows, rows)
        XCTAssertEqual(decoded.decisionCount, 3)
        XCTAssertEqual(
            decoded.canonicalFileByteCount,
            UInt64(data.count)
        )
        XCTAssertEqual(
            Array(data.prefix(8)),
            Array(Policy.chunkMagic.utf8)
        )

        var slicedEnvelope = Data(
            repeating: 0xa5,
            count: 5
        )
        slicedEnvelope.append(data)
        slicedEnvelope.append(0x5a)
        let slicedData =
            slicedEnvelope[
                5 ..< 5 + data.count
            ]
        XCTAssertEqual(slicedData.startIndex, 5)
        XCTAssertEqual(
            try Codec.decodeChunk(
                slicedData,
                dictionary: dictionary,
                expectedChunkOrdinal: 0
            ),
            decoded
        )
        assertChunkError(
            slicedEnvelope[
                5 ..< 5 + data.count - 1
            ],
            dictionary: dictionary,
            expected: .truncatedInput
        )

        let duplicateCorrelationRows = [
            rows[0],
            try row(
                ordinal: 1,
                correlationID:
                    rows[0].correlationID,
                dictionaryIndex: 0,
                decisionCount: 1
            ),
        ]
        XCTAssertThrowsError(
            try Codec.encodeChunk(
                rows: duplicateCorrelationRows,
                chunkOrdinal: 0,
                dictionary: dictionary
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .duplicateCorrelationID
            )
        }

        var badOrdinal = data
        replaceUInt32(
            UInt32(Policy.exactChunkCount),
            in: &badOrdinal,
            at: 16
        )
        assertChunkError(
            badOrdinal,
            dictionary: dictionary,
            expected: .invalidChunkOrdinal
        )

        var badRow = data
        replaceUInt32(1, in: &badRow, at: 24)
        assertChunkError(
            badRow,
            dictionary: dictionary,
            expected:
                .invalidRowOrdinal(
                    expected: 0,
                    observed: 1
                )
        )

        let firstCorrelationStart = 30
        var badCorrelation = data
        badCorrelation[
            firstCorrelationStart
        ] = 0x20
        assertChunkError(
            badCorrelation,
            dictionary: dictionary,
            expected: .invalidCorrelationID
        )

        let correlationLength =
            correlationID(0).utf8.count
        let decisionCountOffset =
            firstCorrelationStart
            + correlationLength
        let firstDecisionOrdinalOffset =
            decisionCountOffset + 1
        var badDecisionOrdinal = data
        badDecisionOrdinal[
            firstDecisionOrdinalOffset
        ] = 2
        assertChunkError(
            badDecisionOrdinal,
            dictionary: dictionary,
            expected:
                .invalidDecisionOrdinal(
                    expected: 1,
                    observed: 2
                )
        )

        var badIndex = data
        replaceUInt32(
            1,
            in: &badIndex,
            at:
                firstDecisionOrdinalOffset + 1
        )
        assertChunkError(
            badIndex,
            dictionary: dictionary,
            expected: .invalidDictionaryIndex(1)
        )

        var trailing = data
        trailing.append(0)
        assertChunkError(
            trailing,
            dictionary: dictionary,
            expected: .trailingInput
        )

        let oversized = Data(
            repeating: 0,
            count:
                Policy.maximumChunkFileByteCount
                + 1
        )
        assertChunkError(
            oversized,
            dictionary: dictionary,
            expected:
                .chunkFileByteLimitExceeded
        )
    }

    func testCompleteFixtureManifestAndAggregateAreExactAndMutationBound()
        throws
    {
        let fixture = try completeFixture()
        let manifestData =
            try Codec.encodeManifest(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData: fixture.chunkData,
                expectedReplicateContext:
                    fixture.context
            )
        let validated =
            try Codec.validateCompleteSidecar(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData: fixture.chunkData,
                manifestData: manifestData,
                expectedReplicateContext:
                    fixture.context
            )
        let repeatedManifest =
            try Codec.encodeManifest(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData: fixture.chunkData,
                expectedReplicateContext:
                    fixture.context
            )

        XCTAssertEqual(manifestData, repeatedManifest)
        XCTAssertEqual(
            validated.chunks.count,
            Policy.exactChunkCount
        )
        XCTAssertEqual(
            validated.manifest.rowCount,
            Policy.exactRowCount
        )
        XCTAssertEqual(
            validated.manifest.decisionCount,
            UInt64(Policy.exactRowCount)
        )
        XCTAssertEqual(
            validated.manifest.aggregateSHA256,
            try Codec.aggregateSHA256(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData: fixture.chunkData
            )
        )
        XCTAssertEqual(
            Array(manifestData.prefix(8)),
            Array(Policy.manifestMagic.utf8)
        )

        let unusedDictionaryFixture =
            try completeFixture(
                includingUnusedDictionaryEntry: true
            )
        XCTAssertThrowsError(
            try Codec.encodeManifest(
                dictionaryData:
                    unusedDictionaryFixture
                    .dictionaryData,
                chunkData:
                    unusedDictionaryFixture
                    .chunkData,
                expectedReplicateContext:
                    unusedDictionaryFixture.context
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .unreferencedDictionaryEntry(1)
            )
        }
        XCTAssertThrowsError(
            try Codec.validateCompleteSidecar(
                dictionaryData:
                    unusedDictionaryFixture
                    .dictionaryData,
                chunkData:
                    unusedDictionaryFixture
                    .chunkData,
                manifestData: manifestData,
                expectedReplicateContext:
                    unusedDictionaryFixture.context
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .unreferencedDictionaryEntry(1)
            )
        }

        var slicedEnvelope = Data(
            repeating: 0xa5,
            count: 9
        )
        slicedEnvelope.append(manifestData)
        slicedEnvelope.append(0x5a)
        let slicedManifest =
            slicedEnvelope[
                9 ..< 9 + manifestData.count
            ]
        XCTAssertEqual(
            slicedManifest.startIndex,
            9
        )
        XCTAssertEqual(
            try Codec.decodeManifest(
                slicedManifest,
                expectedReplicateContext:
                    fixture.context
            ),
            validated.manifest
        )
        XCTAssertThrowsError(
            try Codec.decodeManifest(
                slicedEnvelope[
                    9 ..<
                    9 + manifestData.count - 1
                ],
                expectedReplicateContext:
                    fixture.context
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .truncatedInput
            )
        }

        var badAggregateByteCount =
            manifestData
        replaceUInt64(
            validated.manifest
                .aggregateByteCount + 1,
            in: &badAggregateByteCount,
            at:
                badAggregateByteCount.count
                - 40
        )
        XCTAssertThrowsError(
            try Codec.decodeManifest(
                badAggregateByteCount,
                expectedReplicateContext:
                    fixture.context
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .aggregateBindingMismatch
            )
        }

        XCTAssertThrowsError(
            try Codec.aggregateSHA256(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData:
                    Array(
                        fixture.chunkData.dropLast()
                    )
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .invalidChunkPartition
            )
        }

        XCTAssertThrowsError(
            try Codec.validateCompleteSidecar(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData:
                    Array(
                        fixture.chunkData.dropLast()
                    ),
                manifestData: manifestData
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .invalidChunkPartition
            )
        }

        var reordered = fixture.chunkData
        reordered.swapAt(0, 1)
        XCTAssertThrowsError(
            try Codec.validateCompleteSidecar(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData: reordered,
                manifestData: manifestData
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .invalidChunkOrdinal
            )
        }

        var mutatedChunkData =
            fixture.chunkData
        var firstChunk =
            mutatedChunkData[0]
        firstChunk[firstChunk.count - 1] ^= 1
        mutatedChunkData[0] = firstChunk
        XCTAssertThrowsError(
            try Codec.validateCompleteSidecar(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData: mutatedChunkData,
                manifestData: manifestData
            )
        )

        var mutatedManifest = manifestData
        mutatedManifest[
            mutatedManifest.count - 1
        ] ^= 1
        XCTAssertThrowsError(
            try Codec.validateCompleteSidecar(
                dictionaryData:
                    fixture.dictionaryData,
                chunkData: fixture.chunkData,
                manifestData: mutatedManifest
            )
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                .aggregateBindingMismatch
            )
        }
    }

    private func completeFixture(
        includingUnusedDictionaryEntry: Bool = false
    ) throws -> (
        context: Context,
        dictionaryData: Data,
        chunkData: [Data]
    ) {
        let context = try Context(
            evaluationSeed: 1_618
        )
        let referencedVector =
            structuralVector(
                selectedTokenID: 70
            )
        var dictionaryVectors = [
            referencedVector,
        ]
        if includingUnusedDictionaryEntry {
            dictionaryVectors.append(
                structuralVector(
                    selectedTokenID: 256
                )
            )
        }
        let dictionaryData =
            try Codec.encodeDictionary(
                fullVocabularyLogits:
                    dictionaryVectors,
                replicateContext: context
            )
        let dictionary =
            try Codec.decodeDictionary(
                dictionaryData
            )
        let referencedDictionaryIndex =
            try dictionary.dictionaryIndex(
                forFullVocabularyLogits:
                    referencedVector
            )
        var chunks: [Data] = []
        chunks.reserveCapacity(
            Policy.exactChunkCount
        )
        for chunkOrdinal in
            0 ..< Policy.exactChunkCount
        {
            let first =
                chunkOrdinal
                * Policy.rowsPerChunk
            let rows = try (
                first
                    ..< first
                    + Policy.rowsPerChunk
            ).map {
                try row(
                    ordinal: $0,
                    correlationID:
                        correlationID($0),
                    dictionaryIndex:
                        referencedDictionaryIndex,
                    decisionCount: 1
                )
            }
            chunks.append(
                try Codec.encodeChunk(
                    rows: rows,
                    chunkOrdinal:
                        chunkOrdinal,
                    dictionary: dictionary
                )
            )
        }
        return (
            context,
            dictionaryData,
            chunks
        )
    }

    private func row(
        ordinal: Int,
        correlationID: String,
        dictionaryIndex: UInt32,
        decisionCount: Int
    ) throws
        -> PrimeNativeNeuralGateLogitRowReference
    {
        try PrimeNativeNeuralGateLogitRowReference(
            rowOrdinal: ordinal,
            correlationID: correlationID,
            decisions:
                (1 ... decisionCount).map {
                    try PrimeNativeNeuralGateLogitDecisionReference(
                        ordinal: $0,
                        dictionaryIndex:
                            dictionaryIndex
                    )
                }
        )
    }

    private func structuralVector(
        selectedTokenID: Int
    ) -> [Float] {
        var vector = Array(
            repeating: Float(-1),
            count: Policy.vocabularyCount
        )
        vector[selectedTokenID] = 1
        return vector
    }

    private func correlationID(
        _ ordinal: Int
    ) -> String {
        String(
            format: "row-%08d",
            ordinal
        )
    }

    private func assertDictionaryError(
        _ data: Data,
        context: Context?,
        expected: SidecarError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try Codec.decodeDictionary(
                data,
                expectedReplicateContext: context
            ),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func assertChunkError(
        _ data: Data,
        dictionary:
            PrimeNativeNeuralGateValidatedLogitDictionary,
        expected: SidecarError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try Codec.decodeChunk(
                data,
                dictionary: dictionary
            ),
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as? SidecarError,
                expected,
                file: file,
                line: line
            )
        }
    }

    private func replaceUInt32(
        _ value: UInt32,
        in data: inout Data,
        at offset: Int
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.replaceSubrange(
                offset ..< offset + 4,
                with: $0
            )
        }
    }

    private func replaceUInt64(
        _ value: UInt64,
        in data: inout Data,
        at offset: Int
    ) {
        var bigEndian = value.bigEndian
        withUnsafeBytes(of: &bigEndian) {
            data.replaceSubrange(
                offset ..< offset + 8,
                with: $0
            )
        }
    }
}
