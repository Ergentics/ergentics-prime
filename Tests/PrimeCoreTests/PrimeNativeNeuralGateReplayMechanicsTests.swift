import Foundation
import XCTest
@testable import PrimeNativeNeuralGateReplayMechanics

final class PrimeNativeNeuralGateReplayMechanicsTests:
    XCTestCase
{
    func testPackageDeclaresOnlyPureLibraryFoundationTarget()
        throws
    {
        let package = withoutWhitespace(
            try String(
                contentsOfFile: "Package.swift",
                encoding: .utf8
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateReplayMechanics")"#
            )
        )
        XCTAssertFalse(
            package.contains(
                #".executableTarget(name:"PrimeNativeNeuralGateReplayMechanics""#
            )
        )
        for forbiddenDependency in [
            "PrimeCore",
            "PrimeNativeCorpusReplayMechanics",
            "ErgenticsPrimeRuntime",
            "NeuralKit",
            "PMHNPCompanion",
            "MLX",
        ] {
            XCTAssertFalse(
                package.contains(
                    #".target(name:"PrimeNativeNeuralGateReplayMechanics",dependencies:["\#(forbiddenDependency)""#
                ),
                "foundation target acquired dependency: \(forbiddenDependency)"
            )
        }
    }

    func testTargetFreeCorrelationIdentityKnownAnswer()
        throws
    {
        XCTAssertEqual(
            PrimeNativeNeuralGateReplayCorrelationIdentity
                .magic,
            "PRIMECOR1"
        )
        XCTAssertEqual(
            PrimeNativeNeuralGateReplayCorrelationIdentity
                .serializationContractID,
            "primecor1_then_uint32_big_endian_execution_index_then_raw_primecpi2_prompt_binding_sha256_v1"
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateReplayCorrelationIdentity
                .derive(
                    executionIndex: 7,
                    primeCPI2PromptBindingSHA256:
                        String(repeating: "a", count: 64)
                ),
            "c2016a2c2031328ac2b73bb8d5d05f54969133ffca0600548712fef0c742cc7a"
        )
        for invalid in [
            String(repeating: "a", count: 63),
            String(repeating: "A", count: 64),
            String(repeating: "g", count: 64),
        ] {
            XCTAssertThrowsError(
                try PrimeNativeNeuralGateReplayCorrelationIdentity
                    .derive(
                        executionIndex: 7,
                        primeCPI2PromptBindingSHA256:
                            invalid
                    )
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeNativeNeuralGateReplayMechanicsError,
                    .invalidPromptBindingSHA256
                )
            }
        }
    }

    func testKnownAnswerPreservesRawUTF8Identity()
        throws
    {
        let records = try [
            "c3a9",
            "41",
            "",
            "65cc81",
            "41",
        ].map(dataFromHex)
        let bundle =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: records)

        XCTAssertEqual(
            bundle.canonicalRecords.map(hex),
            [
                "",
                "41",
                "41",
                "65cc81",
                "c3a9",
            ]
        )
        XCTAssertEqual(
            bundle.globalStream.count,
            64
        )
        XCTAssertEqual(
            bundle.manifest.globalStreamSHA256,
            "56ae18634d740ef5e08f86212ac580510db5211def0834302871ba8a00246294"
        )
        XCTAssertEqual(
            bundle.chunkStreams.count,
            1
        )
        XCTAssertEqual(
            bundle.chunkStreams[0].count,
            64
        )
        XCTAssertEqual(
            bundle.manifest.chunks[0].sha256,
            "be85d2d8dea54573b84d99afbabf9cf8fdca050f1dafed9d498547eb455860a2"
        )
        XCTAssertEqual(
            bundle
                .fingerprintObservation
                .direct
                .residues,
            [
                1_809_436_187,
                238_577_571,
                1_233_137_383,
            ]
        )
        XCTAssertEqual(
            bundle
                .fingerprintObservation
                .direct,
            bundle
                .fingerprintObservation
                .accelerated
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateInvariantCodec
                .validate(
                    manifest: bundle.manifest,
                    fingerprintObservation:
                        bundle
                        .fingerprintObservation,
                    globalStream:
                        bundle.globalStream,
                    chunkStreams:
                        bundle.chunkStreams
                ),
            bundle.canonicalRecords
        )

        XCTAssertNotEqual(
            bundle.canonicalRecords[3],
            bundle.canonicalRecords[4]
        )
        XCTAssertEqual(
            String(
                data: bundle.canonicalRecords[3],
                encoding: .utf8
            ),
            String(
                data: bundle.canonicalRecords[4],
                encoding: .utf8
            )
        )
    }

    func testIncrementalReadersAndGlobalAccumulatorMatchFrozenBytesAtEverySplit()
        throws
    {
        let records = try [
            "c3a9",
            "41",
            "",
            "65cc81",
            "41",
        ].map(dataFromHex)
        let bundle = try
            PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: records)

        for split in 0 ... bundle.globalStream.count {
            let reader =
                PrimeNativeNeuralGateInvariantFramedRecordReader(
                    kind: .global
                )
            var observed = [Data]()
            try reader.consume(
                bundle.globalStream.prefix(split)
            ) {
                observed.append($0)
            }
            try reader.consume(
                bundle.globalStream.dropFirst(split)
            ) {
                observed.append($0)
            }
            let summary = try reader.finish()
            XCTAssertEqual(
                observed,
                bundle.canonicalRecords,
                "global split \(split)"
            )
            XCTAssertEqual(summary.kind, .global)
            XCTAssertEqual(
                summary.declaredRecordCount,
                UInt64(bundle.canonicalRecords.count)
            )
            XCTAssertEqual(
                summary.observedRecordCount,
                bundle.canonicalRecords.count
            )
            XCTAssertNil(summary.chunkOrdinal)
            XCTAssertEqual(
                summary.streamSHA256,
                bundle.manifest.globalStreamSHA256
            )
            XCTAssertEqual(
                summary.byteCount,
                UInt64(bundle.globalStream.count)
            )
            XCTAssertEqual(
                summary.aggregateRecordByteCount,
                UInt64(
                    bundle.canonicalRecords.reduce(0) {
                        $0 + $1.count
                    }
                )
            )
        }

        let chunk = try XCTUnwrap(
            bundle.chunkStreams.first
        )
        for split in 0 ... chunk.count {
            let reader =
                PrimeNativeNeuralGateInvariantFramedRecordReader(
                    kind: .chunk
                )
            var observed = [Data]()
            try reader.consume(chunk.prefix(split)) {
                observed.append($0)
            }
            try reader.consume(chunk.dropFirst(split)) {
                observed.append($0)
            }
            let summary = try reader.finish()
            XCTAssertEqual(
                observed,
                bundle.canonicalRecords,
                "chunk split \(split)"
            )
            XCTAssertEqual(summary.kind, .chunk)
            XCTAssertEqual(summary.chunkOrdinal, 0)
            XCTAssertEqual(
                summary.streamSHA256,
                bundle.manifest.chunks[0].sha256
            )
            XCTAssertEqual(
                summary.byteCount,
                UInt64(chunk.count)
            )
        }

        var accumulator = try
            PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator(
                declaredRecordCount:
                    UInt64(bundle.canonicalRecords.count)
            )
        for record in bundle.canonicalRecords {
            try accumulator.append(
                canonicalRecord: record
            )
        }
        let accumulated = try accumulator.finish()
        XCTAssertEqual(
            accumulated.streamSHA256,
            bundle.manifest.globalStreamSHA256
        )
        XCTAssertEqual(
            accumulated.byteCount,
            UInt64(bundle.globalStream.count)
        )
        XCTAssertEqual(
            accumulated.observedRecordCount,
            bundle.canonicalRecords.count
        )
    }

    func testIncrementalReaderRejectsMalformedBoundsOrderingAndEOF()
        throws
    {
        let valid = global(
            records: [
                Data("a".utf8),
                Data("b".utf8),
            ]
        )
        for end in 0 ..< valid.count {
            assertIncrementalFailure(
                .truncatedInput,
                kind: .global,
                data: valid.prefix(end),
                "truncation at byte \(end)"
            )
        }

        var wrongGlobalMagic = valid
        wrongGlobalMagic[0] = UInt8(ascii: "X")
        assertIncrementalFailure(
            .invalidGlobalMagic,
            kind: .global,
            data: wrongGlobalMagic
        )
        let validChunk = try chunk(
            ordinal: 7,
            records: [Data("a".utf8)]
        )
        var wrongChunkMagic = validChunk
        wrongChunkMagic[0] = UInt8(ascii: "X")
        assertIncrementalFailure(
            .invalidChunkMagic,
            kind: .chunk,
            data: wrongChunkMagic
        )

        var trailing = valid
        trailing.append(0)
        assertIncrementalFailure(
            .trailingInput,
            kind: .global,
            data: trailing
        )
        let laterTrailing =
            PrimeNativeNeuralGateInvariantFramedRecordReader(
                kind: .global
            )
        try laterTrailing.consume(valid) { _ in }
        XCTAssertThrowsError(
            try laterTrailing.consume(Data([0])) { _ in }
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .trailingInput
            )
        }

        var countOverflow = Data("PRIMEIRM1".utf8)
        append(UInt64.max, to: &countOverflow)
        assertIncrementalFailure(
            .integerOverflow,
            kind: .global,
            data: countOverflow
        )
        var lengthOverflow = Data("PRIMEIRM1".utf8)
        append(UInt64(1), to: &lengthOverflow)
        append(UInt64.max, to: &lengthOverflow)
        assertIncrementalFailure(
            .integerOverflow,
            kind: .global,
            data: lengthOverflow
        )
        assertIncrementalFailure(
            .chunkRecordCountLimitExceeded,
            kind: .chunk,
            data: chunkHeader(
                ordinal: 0,
                count: 4_097
            )
        )

        let tight = try limits(
            records: 2,
            recordBytes: 1,
            aggregateBytes: 1
        )
        assertIncrementalFailure(
            .recordByteLimitExceeded(index: 0),
            kind: .global,
            data: global(
                records: [Data("aa".utf8)]
            ),
            limits: tight
        )
        assertIncrementalFailure(
            .aggregateByteLimitExceeded,
            kind: .global,
            data: global(
                records: [
                    Data("a".utf8),
                    Data("b".utf8),
                ]
            ),
            limits: tight
        )

        var invalidUTF8 = Data("PRIMEIRM1".utf8)
        append(UInt64(1), to: &invalidUTF8)
        append(UInt64(2), to: &invalidUTF8)
        invalidUTF8.append(contentsOf: [0xC0, 0xAF])
        assertIncrementalFailure(
            .invalidUTF8Record(index: 0),
            kind: .global,
            data: invalidUTF8
        )
        assertIncrementalFailure(
            .noncanonicalRecordOrder,
            kind: .global,
            data: global(
                records: [
                    Data("b".utf8),
                    Data("a".utf8),
                ]
            )
        )

        let callbackFailure =
            PrimeNativeNeuralGateInvariantFramedRecordReader(
                kind: .global
            )
        XCTAssertThrowsError(
            try callbackFailure.consume(valid) { _ in
                throw CocoaError(.fileReadCorruptFile)
            }
        )
        XCTAssertThrowsError(try callbackFailure.finish()) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .incrementalReaderNotReusable
            )
        }

        let reentrant =
            PrimeNativeNeuralGateInvariantFramedRecordReader(
                kind: .global
            )
        XCTAssertThrowsError(
            try reentrant.consume(valid) { _ in
                _ = try reentrant.finish()
            }
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .incrementalReaderNotReusable
            )
        }
    }

    func testGlobalAccumulatorFailsClosedOnCountBoundsUTF8AndOrder()
        throws
    {
        var incomplete = try
            PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator(
                declaredRecordCount: 2
            )
        try incomplete.append(
            canonicalRecord: Data("a".utf8)
        )
        XCTAssertThrowsError(try incomplete.finish()) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .truncatedInput
            )
        }

        var complete = try
            PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator(
                declaredRecordCount: 1
            )
        try complete.append(
            canonicalRecord: Data("a".utf8)
        )
        XCTAssertThrowsError(
            try complete.append(
                canonicalRecord: Data("b".utf8)
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .trailingInput
            )
        }

        var invalidUTF8 = try
            PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator(
                declaredRecordCount: 1
            )
        XCTAssertThrowsError(
            try invalidUTF8.append(
                canonicalRecord: Data([0xC0, 0xAF])
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .invalidUTF8Record(index: 0)
            )
        }

        var noncanonical = try
            PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator(
                declaredRecordCount: 2
            )
        try noncanonical.append(
            canonicalRecord: Data("b".utf8)
        )
        XCTAssertThrowsError(
            try noncanonical.append(
                canonicalRecord: Data("a".utf8)
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .noncanonicalRecordOrder
            )
        }

        let tight = try limits(
            records: 1,
            recordBytes: 1,
            aggregateBytes: 1
        )
        var oversized = try
            PrimeNativeNeuralGateInvariantGlobalStreamSHA256Accumulator(
                declaredRecordCount: 1,
                limits: tight
            )
        XCTAssertThrowsError(
            try oversized.append(
                canonicalRecord: Data("aa".utf8)
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .recordByteLimitExceeded(index: 0)
            )
        }
    }

    func testCanonicalChunkPartitionUses4096AndExactOrdinals()
        throws
    {
        let records = (0..<4_097).map {
            Data(
                String(
                    format: "record-%08d",
                    $0
                ).utf8
            )
        }
        let bundle =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: records)

        XCTAssertEqual(
            bundle.chunkStreams.count,
            2
        )
        let first =
            try PrimeNativeNeuralGateInvariantCodec
            .decodeChunk(
                bundle.chunkStreams[0]
            )
        let second =
            try PrimeNativeNeuralGateInvariantCodec
            .decodeChunk(
                bundle.chunkStreams[1]
            )
        XCTAssertEqual(first.ordinal, 0)
        XCTAssertEqual(first.records.count, 4_096)
        XCTAssertEqual(second.ordinal, 1)
        XCTAssertEqual(second.records.count, 1)
        XCTAssertEqual(
            first.records + second.records,
            bundle.canonicalRecords
        )
    }

    func testGlobalDecoderRejectsMalformedFramingAndOrdering()
        throws
    {
        let bundle =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("a".utf8),
                    Data("b".utf8),
                ]
            )

        var wrongMagic = bundle.globalStream
        wrongMagic[0] = UInt8(ascii: "X")
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(wrongMagic)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .invalidGlobalMagic
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(
                    Data(bundle.globalStream.dropLast())
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .truncatedInput
            )
        }

        var trailing = bundle.globalStream
        trailing.append(0)
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(trailing)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .trailingInput
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .encodeGlobal(
                    canonicalRecords: [
                        Data("b".utf8),
                        Data("a".utf8),
                    ]
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .noncanonicalRecordOrder
            )
        }
    }

    func testDecodersAndCacheRebaseNonzeroBasedDataSlices()
        throws
    {
        let bundle =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("a".utf8),
                    Data("b".utf8),
                ]
            )
        var paddedGlobal = Data([0xFF])
        paddedGlobal.append(bundle.globalStream)
        let slicedGlobal =
            paddedGlobal.dropFirst()
        XCTAssertNotEqual(
            slicedGlobal.startIndex,
            0
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(slicedGlobal),
            bundle.canonicalRecords
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateAffineFingerprintCache
                .build(
                    globalStream: slicedGlobal
                )
                .reuse(for: slicedGlobal),
            bundle
                .fingerprintObservation
                .accelerated
        )

        var paddedChunk = Data([0xFF])
        paddedChunk.append(
            bundle.chunkStreams[0]
        )
        let slicedChunk =
            paddedChunk.dropFirst()
        XCTAssertNotEqual(
            slicedChunk.startIndex,
            0
        )
        XCTAssertEqual(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(slicedChunk)
                .records,
            bundle.canonicalRecords
        )

        let malformedGlobal =
            slicedGlobal.dropLast()
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(malformedGlobal)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .truncatedInput
            )
        }
        let malformedChunk =
            slicedChunk.dropLast()
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(malformedChunk)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .truncatedInput
            )
        }
    }

    func testDecoderRejectsInvalidUTF8AndLimitsBeforeAllocation()
        throws
    {
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .makeBundle(
                    records: [
                        Data([0xC0, 0xAF]),
                    ]
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .invalidUTF8Record(index: 0)
            )
        }

        let countLimited =
            try limits(
                records: 1,
                recordBytes: 8,
                aggregateBytes: 8
            )
        let twoRecords =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("a".utf8),
                    Data("b".utf8),
                ]
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(
                    twoRecords.globalStream,
                    limits: countLimited
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .recordCountLimitExceeded
            )
        }

        let oneRecord =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("abcd".utf8),
                ]
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(
                    oneRecord.globalStream,
                    limits:
                        try limits(
                            records: 1,
                            recordBytes: 3,
                            aggregateBytes: 8
                        )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .recordByteLimitExceeded(index: 0)
            )
        }
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(
                    oneRecord.globalStream,
                    limits:
                        try limits(
                            records: 1,
                            recordBytes: 8,
                            aggregateBytes: 3
                        )
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .aggregateByteLimitExceeded
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateReplayDecodeLimits
                .bounded(
                    maximumRecordCount: 0,
                    maximumRecordByteCount: 1,
                    maximumAggregateRecordBytes: 1
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .invalidDecodeLimits
            )
        }
    }

    func testGlobalDecoderRejectsCountLengthAndRawOrderAttacks()
        throws
    {
        var countOverflow =
            Data("PRIMEIRM1".utf8)
        append(
            UInt64.max,
            to: &countOverflow
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(countOverflow)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .integerOverflow
            )
        }

        var lengthOverflow =
            Data("PRIMEIRM1".utf8)
        append(
            UInt64(1),
            to: &lengthOverflow
        )
        append(
            UInt64.max,
            to: &lengthOverflow
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(lengthOverflow)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .integerOverflow
            )
        }

        let noncanonical = global(
            records: [
                Data("b".utf8),
                Data("a".utf8),
            ]
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeGlobal(noncanonical)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .noncanonicalRecordOrder
            )
        }
    }

    func testChunkDecoderRejectsEveryFramingBoundary()
        throws
    {
        let valid = try chunk(
            ordinal: 0,
            records: [
                Data("a".utf8),
            ]
        )

        var wrongMagic = valid
        wrongMagic[0] = UInt8(ascii: "X")
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(wrongMagic)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .invalidChunkMagic
            )
        }

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(
                    Data(valid.dropLast())
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .truncatedInput
            )
        }

        var trailing = valid
        trailing.append(0)
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(trailing)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .trailingInput
            )
        }

        let zero = chunkHeader(
            ordinal: 0,
            count: 0
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(zero)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .emptyChunk
            )
        }

        let tooMany = chunkHeader(
            ordinal: 0,
            count: 4_097
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(tooMany)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .chunkRecordCountLimitExceeded
            )
        }

        let countLimited =
            try limits(
                records: 1,
                recordBytes: 8,
                aggregateBytes: 8
            )
        let twoRecords = try chunk(
            ordinal: 0,
            records: [
                Data("a".utf8),
                Data("b".utf8),
            ]
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(
                    twoRecords,
                    limits: countLimited
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .recordCountLimitExceeded
            )
        }

        var invalidUTF8 = chunkHeader(
            ordinal: 0,
            count: 1
        )
        append(
            UInt64(2),
            to: &invalidUTF8
        )
        invalidUTF8.append(
            contentsOf: [0xC0, 0xAF]
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .decodeChunk(invalidUTF8)
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .invalidUTF8Record(index: 0)
            )
        }
    }

    func testChunkPartitionRejectsGapReorderAndShortNonfinal()
        throws
    {
        let records = (0..<4_097).map {
            Data(
                String(
                    format: "%08d",
                    $0
                ).utf8
            )
        }
        let bundle =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(records: records)

        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .validateChunkPartition(
                    canonicalRecords:
                        bundle.canonicalRecords,
                    chunkStreams:
                        bundle.chunkStreams.reversed()
                )
        )

        var duplicateOrdinal =
            bundle.chunkStreams[1]
        replaceUInt32(
            in: &duplicateOrdinal,
            at: 9,
            with: 0
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .validateChunkPartition(
                    canonicalRecords:
                        bundle.canonicalRecords,
                    chunkStreams: [
                        bundle.chunkStreams[0],
                        duplicateOrdinal,
                    ]
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .chunkOrdinalMismatch(
                    expected: 1,
                    observed: 0
                )
            )
        }

        var ordinalGap = bundle.chunkStreams[1]
        replaceUInt32(
            in: &ordinalGap,
            at: 9,
            with: 2
        )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .validateChunkPartition(
                    canonicalRecords:
                        bundle.canonicalRecords,
                    chunkStreams: [
                        bundle.chunkStreams[0],
                        ordinalGap,
                    ]
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .chunkOrdinalMismatch(
                    expected: 1,
                    observed: 2
                )
            )
        }

        let shortFirst =
            try chunk(
                ordinal: 0,
                records: [
                    bundle.canonicalRecords[0],
                ]
            )
        let rest =
            try chunk(
                ordinal: 1,
                records: Array(
                    bundle.canonicalRecords.dropFirst()
                )
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .validateChunkPartition(
                    canonicalRecords:
                        bundle.canonicalRecords,
                    chunkStreams: [
                        shortFirst,
                        rest,
                    ]
                )
        )
    }

    func testTypedValidationRecomputesInsteadOfTrustingPayloads()
        throws
    {
        let bundle =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("alpha".utf8),
                    Data("beta".utf8),
                ]
            )
        let forgedManifest =
            PrimeNativeNeuralGateInvariantManifest(
                recordCount:
                    bundle.manifest.recordCount,
                globalStreamByteCount:
                    bundle
                    .manifest
                    .globalStreamByteCount,
                globalStreamSHA256:
                    String(
                        repeating: "0",
                        count: 64
                    ),
                chunks:
                    bundle.manifest.chunks
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .validate(
                    manifest: forgedManifest,
                    fingerprintObservation:
                        bundle
                        .fingerprintObservation,
                    globalStream:
                        bundle.globalStream,
                    chunkStreams:
                        bundle.chunkStreams
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .invalidManifest
            )
        }

        let forgedFingerprint =
            PrimeNativeNeuralGateFingerprint(
                prime:
                    PrimeNativeNeuralGateFingerprintMechanics
                    .prime,
                evaluationPoints:
                    PrimeNativeNeuralGateFingerprintMechanics
                    .evaluationPoints,
                residues: [0, 0, 0],
                recordCount:
                    bundle.canonicalRecords.count
            )
        let forgedObservation =
            PrimeNativeNeuralGateFingerprintObservation(
                orderedMultisetStreamSHA256:
                    bundle
                    .manifest
                    .globalStreamSHA256,
                direct: forgedFingerprint,
                accelerated: forgedFingerprint
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateInvariantCodec
                .validate(
                    manifest: bundle.manifest,
                    fingerprintObservation:
                        forgedObservation,
                    globalStream:
                        bundle.globalStream,
                    chunkStreams:
                        bundle.chunkStreams
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .invalidFingerprintObservation
            )
        }

        for mutation in [
            (
                key: "exact_equality_observed",
                value: false as Any
            ),
            (
                key: "direct_algorithm_id",
                value: "caller_forged" as Any
            ),
        ] {
            let encoded = try JSONEncoder().encode(
                bundle.fingerprintObservation
            )
            var object = try XCTUnwrap(
                try JSONSerialization
                    .jsonObject(
                        with: encoded
                    ) as? [String: Any]
            )
            object[mutation.key] =
                mutation.value
            let mutatedData =
                try JSONSerialization.data(
                    withJSONObject: object
                )
            let decoded =
                try JSONDecoder().decode(
                    PrimeNativeNeuralGateFingerprintObservation
                        .self,
                    from: mutatedData
                )
            XCTAssertThrowsError(
                try PrimeNativeNeuralGateInvariantCodec
                    .validate(
                        manifest:
                            bundle.manifest,
                        fingerprintObservation:
                            decoded,
                        globalStream:
                            bundle.globalStream,
                        chunkStreams:
                            bundle.chunkStreams
                    )
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeNativeNeuralGateReplayMechanicsError,
                    .invalidFingerprintObservation
                )
            }
        }
    }

    func testCacheRequiresRawByteEqualityAndHash()
        throws
    {
        let first =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("same-length-A".utf8),
                ]
            )
        let second =
            try PrimeNativeNeuralGateInvariantCodec
            .makeBundle(
                records: [
                    Data("same-length-B".utf8),
                ]
            )
        let cache =
            try PrimeNativeNeuralGateAffineFingerprintCache
            .build(
                globalStream: first.globalStream
            )

        XCTAssertEqual(
            try cache.reuse(
                for: first.globalStream
            ),
            first
                .fingerprintObservation
                .accelerated
        )
        XCTAssertThrowsError(
            try cache.reuse(
                for: second.globalStream
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .staleFingerprintCache
            )
        }

        let forcedDigestCollision =
            PrimeNativeNeuralGateAffineFingerprintCache
            .testOnly(
                streamSHA256:
                    PrimeNativeNeuralGateInvariantCodec
                    .sha256(second.globalStream),
                fingerprint:
                    first
                    .fingerprintObservation
                    .accelerated,
                globalStream:
                    first.globalStream
            )
        XCTAssertThrowsError(
            try forcedDigestCollision.reuse(
                for: second.globalStream
            )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .staleFingerprintCache
            )
        }
        XCTAssertTrue(
            first
                .fingerprintObservation
                .cacheKey
                .contains(
                    PrimeNativeNeuralGateInvariantCodec
                    .serializationContractID
                )
        )
        XCTAssertTrue(
            first
                .fingerprintObservation
                .cacheKey
                .contains(
                    PrimeNativeNeuralGateFingerprintMechanics
                    .directAlgorithmID
                )
        )
    }

    func testDirectAndAffineImplementationsAgreeOnDeterministicSweep()
        throws
    {
        for count in [
            1,
            2,
            3,
            31,
            257,
        ] {
            let records = (0..<count).map {
                index in
                Data(
                    "row-\(index % 17)-\(index)"
                        .utf8
                )
            }
            let canonical =
                try PrimeNativeNeuralGateInvariantCodec
                .canonicalRecords(records)
            XCTAssertEqual(
                try PrimeNativeNeuralGateFingerprintMechanics
                    .direct(
                        canonicalRecords:
                            canonical
                    ),
                try PrimeNativeNeuralGateFingerprintMechanics
                    .accelerated(
                        canonicalRecords:
                            canonical
                    )
            )
        }
    }

    func testFingerprintEntryPointsEnforceBoundsBeforeUTF8Work()
        throws
    {
        let byteLimited =
            try limits(
                records: 1,
                recordBytes: 1,
                aggregateBytes: 1
            )
        let oversizedInvalidUTF8 =
            Data([0xC0, 0xAF])
        for fingerprint in [
            PrimeNativeNeuralGateFingerprintMechanics
                .direct,
            PrimeNativeNeuralGateFingerprintMechanics
                .accelerated,
        ] {
            XCTAssertThrowsError(
                try fingerprint(
                    [oversizedInvalidUTF8],
                    byteLimited
                )
            ) {
                XCTAssertEqual(
                    $0 as?
                        PrimeNativeNeuralGateReplayMechanicsError,
                    .recordByteLimitExceeded(
                        index: 0
                    )
                )
            }
        }

        let countLimited =
            try limits(
                records: 1,
                recordBytes: 8,
                aggregateBytes: 8
            )
        XCTAssertThrowsError(
            try PrimeNativeNeuralGateFingerprintMechanics
                .direct(
                    canonicalRecords: [
                        Data("a".utf8),
                        Data("b".utf8),
                    ],
                    limits: countLimited
                )
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                .recordCountLimitExceeded
            )
        }
    }

    func testSourceHasNoExecutionOrTrapAuthority()
        throws
    {
        let source = try String(
            contentsOfFile:
                "Sources/PrimeNativeNeuralGateReplayMechanics/PrimeNativeNeuralGateReplayMechanics.swift",
            encoding: .utf8
        )
        for forbidden in [
            "import Python",
            "import MLX",
            "import NeuralKit",
            "Foundation.Process",
            "Process(",
            "posix_spawn",
            "execve(",
            "system(",
            "popen(",
            "/bin/sh",
            "/bin/zsh",
            "\"python3\"",
            "try!",
            "fatalError(",
            "precondition(",
            "preconditionFailure(",
            "FileHandle(forWriting",
            "FileHandle(forUpdating",
            "FileManager.default",
            "OutputStream(",
            "URLSession",
            "NSFileCoordinator",
            "createFile(",
            "write(to:",
            "O_WRONLY",
            "O_RDWR",
            "O_CREAT",
            "open(",
            "fopen(",
            "rename(",
            "unlink(",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "pure mechanics contains forbidden authority: \(forbidden)"
            )
        }
    }

    private func limits(
        records: Int,
        recordBytes: Int,
        aggregateBytes: Int
    ) throws
        -> PrimeNativeNeuralGateReplayDecodeLimits
    {
        try PrimeNativeNeuralGateReplayDecodeLimits
        .bounded(
            maximumRecordCount: records,
            maximumRecordByteCount:
                recordBytes,
            maximumAggregateRecordBytes:
                aggregateBytes
        )
    }

    private func assertIncrementalFailure(
        _ expected:
            PrimeNativeNeuralGateReplayMechanicsError,
        kind:
            PrimeNativeNeuralGateInvariantFramedStreamKind,
        data: Data,
        limits:
            PrimeNativeNeuralGateReplayDecodeLimits = .stageB,
        _ message: String = "",
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try {
                let reader =
                    PrimeNativeNeuralGateInvariantFramedRecordReader(
                        kind: kind,
                        limits: limits
                    )
                try reader.consume(data) { _ in }
                _ = try reader.finish()
            }(),
            message,
            file: file,
            line: line
        ) {
            XCTAssertEqual(
                $0 as?
                    PrimeNativeNeuralGateReplayMechanicsError,
                expected,
                message,
                file: file,
                line: line
            )
        }
    }

    private func global(
        records: [Data]
    ) -> Data {
        var data = Data("PRIMEIRM1".utf8)
        append(
            UInt64(records.count),
            to: &data
        )
        for record in records {
            append(
                UInt64(record.count),
                to: &data
            )
            data.append(record)
        }
        return data
    }

    private func chunkHeader(
        ordinal: UInt32,
        count: UInt32
    ) -> Data {
        var data = Data("PRIMEIRC1".utf8)
        append(ordinal, to: &data)
        append(count, to: &data)
        return data
    }

    private func withoutWhitespace(
        _ value: String
    ) -> String {
        value.filter {
            !$0.isWhitespace
        }
    }

    private func dataFromHex(
        _ hex: String
    ) throws -> Data {
        guard hex.utf8.count.isMultiple(of: 2)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        let bytes = Array(hex.utf8)
        var result = Data()
        var index = 0
        while index < bytes.count {
            guard let high = nibble(bytes[index]),
                  let low = nibble(
                      bytes[index + 1]
                  )
            else {
                throw CocoaError(
                    .fileReadCorruptFile
                )
            }
            result.append(high << 4 | low)
            index += 2
        }
        return result
    }

    private func nibble(
        _ byte: UInt8
    ) -> UInt8? {
        switch byte {
        case 48...57:
            byte - 48
        case 97...102:
            byte - 87
        default:
            nil
        }
    }

    private func hex(
        _ data: Data
    ) -> String {
        data.map {
            String(format: "%02x", $0)
        }.joined()
    }

    private func replaceUInt32(
        in data: inout Data,
        at offset: Int,
        with value: UInt32
    ) {
        var encoded = value.bigEndian
        withUnsafeBytes(of: &encoded) {
            data.replaceSubrange(
                offset..<(offset + 4),
                with: $0
            )
        }
    }

    private func chunk(
        ordinal: UInt32,
        records: [Data]
    ) throws -> Data {
        var data = Data("PRIMEIRC1".utf8)
        append(ordinal, to: &data)
        append(
            UInt32(records.count),
            to: &data
        )
        for record in records {
            append(
                UInt64(record.count),
                to: &data
            )
            data.append(record)
        }
        return data
    }

    private func append<
        Value: FixedWidthInteger
    >(
        _ value: Value,
        to data: inout Data
    ) {
        var encoded = value.bigEndian
        withUnsafeBytes(of: &encoded) {
            data.append(contentsOf: $0)
        }
    }
}
