import Foundation
import PrimeNativeCorpusReplayMechanics
import PrimeNativeNeuralGateCorrectedFixtureAuthority
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateLogitSidecarMechanics
import PrimeNativeNeuralGateMLXLogSoftmaxRecomputation
import PrimeNativeNeuralGatePromptSolver
import XCTest

final class
    PrimeNativeNeuralGateLogitSidecarExhaustiveIntegrationTests:
    XCTestCase
{
    private typealias Corpus =
        ErgenticsPrimeNativeTextCorpus
    private typealias ExecutionPolicy =
        PrimeNativeNeuralGateCorrectedExecutionPolicy
    private typealias Input =
        PrimeNativeNeuralGatePromptOnlyExecutionInput
    private typealias Context =
        PrimeNativeNeuralGateCorrectedReplicateContext
    private typealias Solver =
        PrimeNativeNeuralGatePromptOnlyReplicateSolver
    private typealias SidecarPolicy =
        PrimeNativeNeuralGateLogitSidecarPolicy
    private typealias SidecarCodec =
        PrimeNativeNeuralGateLogitSidecarCodec
    private typealias Recomputer =
        PrimeNativeNeuralGateMLXFloat32LogSoftmaxRecomputer

    private struct SelectedFixtureRow:
        Sendable
    {
        let source: Corpus.Row
        let input: Input
    }

    private struct ReplicateSummary {
        let evaluationSeed: Int
        let dictionaryBitPatterns: [[UInt32]]
        let dictionarySHA256: String
        let aggregateSHA256: String
        let manifestSHA256: String
        let mlxLogProbabilitySHA256: String
        let decisionCount: UInt64
        let dictionaryByteCount: UInt64
        let aggregateByteCount: UInt64
        let manifestByteCount: UInt64
    }

    private enum HarnessError:
        Error,
        LocalizedError
    {
        case invariant(String)

        var errorDescription: String? {
            switch self {
            case .invariant(let detail):
                detail
            }
        }
    }

    private static let selectedFixtureRows =
        Result<[SelectedFixtureRow], Error> {
            let splits: [Corpus.Split] = [
                .validation,
                .combinationHoldout,
                .ood,
                .mutation,
                .abstention,
            ]
            let expectedCounts: [Corpus.Split: Int] = [
                .validation: 4_096,
                .combinationHoldout: 4_096,
                .ood: 4_096,
                .mutation: 4_096,
                .abstention: 2_048,
            ]
            var rows: [Corpus.Row] = []
            for split in splits {
                let splitRows = Corpus.rows(
                    for: split
                )
                guard splitRows.count
                        == expectedCounts[split]
                else {
                    throw HarnessError.invariant(
                        "fixture split count drift: "
                            + "\(split.rawValue)="
                            + "\(splitRows.count)"
                    )
                }
                rows.append(contentsOf: splitRows)
            }
            rows.sort {
                Data($0.rowID.utf8)
                    .lexicographicallyPrecedes(
                        Data($1.rowID.utf8)
                    )
            }
            guard rows.count
                    == PrimeNativeNeuralGateCorrectedFixtureObservation
                    .exactRowCount,
                  Set(rows.map(\.rowID)).count
                    == rows.count,
                  rows.first?.rowID
                    == PrimeNativeNeuralGateCorrectedFixtureObservation
                    .frozenFirstRowID,
                  rows.last?.rowID
                    == PrimeNativeNeuralGateCorrectedFixtureObservation
                    .frozenLastRowID
            else {
                throw HarnessError.invariant(
                    "selected fixture identity drift"
                )
            }
            return try rows.map {
                SelectedFixtureRow(
                    source: $0,
                    input: try Input.derive(
                        promptText: $0.promptText
                    )
                )
            }
        }

    func testEveryCorrectedFixtureDecisionRoundTripsAcrossTriadAndMLX()
        throws
    {
        let rows =
            try Self.selectedFixtureRows.get()
        try require(
            rows.count == SidecarPolicy.exactRowCount,
            "exhaustive row count drift"
        )

        var summaries: [ReplicateSummary] = []
        for seed in
            ExecutionPolicy.admittedEvaluationSeeds
        {
            summaries.append(
                try evaluateReplicate(
                    seed: seed,
                    rows: rows
                )
            )
        }

        try require(
            summaries.map(\.evaluationSeed)
                == ExecutionPolicy
                    .admittedEvaluationSeeds,
            "replicate seed ordering drift"
        )
        try require(
            Set(
                summaries.map(\.dictionarySHA256)
            ).count == summaries.count,
            "replicate seed was not bound into dictionary bytes"
        )
        try require(
            Set(
                summaries.map(\.aggregateSHA256)
            ).count == summaries.count,
            "replicate seed was not bound into aggregate bytes"
        )
        try require(
            summaries.dropFirst().allSatisfy {
                $0.dictionaryBitPatterns
                    == summaries[0]
                    .dictionaryBitPatterns
            },
            "replicate seed changed semantic logit vectors"
        )
        try require(
            Set(
                summaries.map(
                    \.mlxLogProbabilitySHA256
                )
            ).count == 1,
            "replicate seed changed MLX Float32 recomputation"
        )
        try require(
            Set(
                summaries.map(\.decisionCount)
            ).count == 1,
            "replicate seed changed decision count"
        )
        try require(
            summaries.allSatisfy {
                    $0.dictionaryBitPatterns.count
                        == 44
                        && $0.dictionaryByteCount
                            == 90_136
                        && $0.aggregateByteCount
                            == 2_070_912
                        && $0.manifestByteCount
                            == 976
                },
            "canonical sidecar geometry drift"
        )
        try require(
            summaries.map(\.decisionCount)
                == [
                    232_638,
                    232_638,
                    232_638,
                ],
            "canonical decision count drift"
        )
        try require(
            summaries.map(\.dictionarySHA256)
                == [
                    "58228cc5098c19f1f59a29f5243508d7e0792310cbab4768a11d359910e47f18",
                    "cf9f82fe81f29d3172eb8314e560c4886f7a9256a550f001632114478872e63d",
                    "dd79de305867b513c279628673f64123f2e29dda0a52c842b5e4cde8dcffa56f",
                ],
            "canonical dictionary digest drift"
        )
        try require(
            summaries.map(\.aggregateSHA256)
                == [
                    "00bc8c01c6c222a8e0b38e0b1a0b044aaafccc5ce4c84cbc84af7ce11aa6a536",
                    "283209400f70a34d3e56ddb8d49b2497de22d509d68bfbebd1cd43c63ac4eb01",
                    "93afb257079c4008792c8061d0f7a044eac01c72112a95f7bbdee1388cc943ba",
                ],
            "canonical aggregate digest drift"
        )
        try require(
            summaries.map(\.manifestSHA256)
                == [
                    "3fbf477fcc447c95da5a9816c4dde857201b99ca83d74c7d76ad9e52b24ec309",
                    "b1c0150f023e04a2394a7ace3b5d1b15a2687e61de15f6aa82e42529d9d0ad39",
                    "562851ffd68eba3cf1434d7ff5d54bb88eb4acd58cf2ea98d1dca976bd66e6a3",
                ],
            "canonical manifest digest drift"
        )
        try require(
            summaries.map(
                \.mlxLogProbabilitySHA256
            ) == [
                "db6906710bffd6a81653ca01df91f913f8a5430da8c8e9c8e620b3c88f7b2f02",
                "db6906710bffd6a81653ca01df91f913f8a5430da8c8e9c8e620b3c88f7b2f02",
                "db6906710bffd6a81653ca01df91f913f8a5430da8c8e9c8e620b3c88f7b2f02",
            ],
            "canonical MLX Float32 digest drift"
        )
    }

    func testSelectedFixtureExactCompletionSupport()
        throws
    {
        let rows =
            try Self.selectedFixtureRows.get()
        var selectedTokenIDs =
            Set([
                ExecutionPolicy
                    .endOfSequenceTokenID,
            ])
        for row in rows {
            for byte in
                row.source.expectedCompletion.utf8
            {
                selectedTokenIDs.insert(
                    Int(byte)
                        + ExecutionPolicy
                        .byteTokenBase
                )
            }
        }
        XCTAssertEqual(
            selectedTokenIDs.sorted(),
            [
                70,
                266,
                288,
                301,
                302,
                304,
                305,
                306,
                307,
                308,
                309,
                310,
                311,
                312,
                313,
                314,
                321,
                322,
                329,
                334,
                338,
                339,
                340,
                353,
                354,
                355,
                356,
                357,
                358,
                360,
                361,
                362,
                363,
                364,
                365,
                366,
                367,
                368,
                370,
                371,
                372,
                373,
                376,
                377,
            ]
        )
        XCTAssertTrue(
            selectedTokenIDs.isSubset(
                of:
                    Set(
                        ExecutionPolicy
                            .orderedCompletionSupport
                    )
            )
        )
    }

    private func evaluateReplicate(
        seed: Int,
        rows: [SelectedFixtureRow]
    ) throws -> ReplicateSummary {
        let context = try Context(
            evaluationSeed: seed
        )
        let solver = try Solver(
            replicateContext: context
        )
        var accumulator =
            PrimeNativeNeuralGateLogitDictionaryAccumulator(
                replicateContext: context
            )
        var uniqueIndexByBitPatterns:
            [[UInt32]: Int] = [:]
        var uniqueBitPatterns: [[UInt32]] = []
        var rowTemporaryIndices: [[Int]] = []
        rowTemporaryIndices.reserveCapacity(
            rows.count
        )

        for row in rows {
            let execution = try solver.solve(
                row.input
            )
            try require(
                !execution.decisions.isEmpty
                    && execution.decisions.count
                        <= SidecarPolicy
                        .maximumDecisionsPerRow,
                "decision geometry drift for "
                    + row.source.rowID
            )
            var temporaryIndices: [Int] = []
            temporaryIndices.reserveCapacity(
                execution.decisions.count
            )
            for decision in execution.decisions {
                try accumulator.admit(
                    fullVocabularyLogits:
                        decision
                        .fullVocabularyLogits
                )
                let bitPatterns =
                    decision
                    .fullVocabularyLogits
                    .map(\.bitPattern)
                let temporaryIndex: Int
                if let existing =
                    uniqueIndexByBitPatterns[
                        bitPatterns
                    ]
                {
                    temporaryIndex = existing
                } else {
                    temporaryIndex =
                        uniqueBitPatterns.count
                    uniqueIndexByBitPatterns[
                        bitPatterns
                    ] = temporaryIndex
                    uniqueBitPatterns.append(
                        bitPatterns
                    )
                }
                temporaryIndices.append(
                    temporaryIndex
                )
            }
            rowTemporaryIndices.append(
                temporaryIndices
            )
        }

        try require(
            accumulator.admittedCandidateCount
                == rowTemporaryIndices.reduce(
                    0
                ) {
                    $0 + $1.count
                },
            "streaming candidate count drift"
        )
        try require(
            accumulator.uniqueEntryCount
                == uniqueBitPatterns.count,
            "streaming unique-entry count drift"
        )

        let dictionaryData =
            try accumulator.finalize()
        let dictionary =
            try SidecarCodec.decodeDictionary(
                dictionaryData,
                expectedReplicateContext:
                    context
            )
        let canonicalIndexByTemporary =
            try uniqueBitPatterns.map {
                try dictionary.dictionaryIndex(
                    forFullVocabularyLogits:
                        $0.map(
                            Float.init(
                                bitPattern:
                            )
                        )
                )
            }

        var sidecarRows:
            [PrimeNativeNeuralGateLogitRowReference] = []
        sidecarRows.reserveCapacity(rows.count)
        for rowOrdinal in rows.indices {
            let temporaryIndices =
                rowTemporaryIndices[rowOrdinal]
            sidecarRows.append(
                try PrimeNativeNeuralGateLogitRowReference(
                    rowOrdinal: rowOrdinal,
                    correlationID:
                        rows[rowOrdinal]
                        .source.rowID,
                    decisions:
                        try temporaryIndices
                        .enumerated().map {
                            offset,
                            temporaryIndex in
                            try PrimeNativeNeuralGateLogitDecisionReference(
                                ordinal: offset + 1,
                                dictionaryIndex:
                                    canonicalIndexByTemporary[
                                        temporaryIndex
                                    ]
                            )
                        }
                )
            )
        }

        var chunkData: [Data] = []
        chunkData.reserveCapacity(
            SidecarPolicy.exactChunkCount
        )
        for chunkOrdinal in
            0 ..< SidecarPolicy.exactChunkCount
        {
            let first =
                chunkOrdinal
                * SidecarPolicy.rowsPerChunk
            let end =
                first + SidecarPolicy.rowsPerChunk
            chunkData.append(
                try SidecarCodec.encodeChunk(
                    rows:
                        Array(
                            sidecarRows[
                                first ..< end
                            ]
                        ),
                    chunkOrdinal:
                        chunkOrdinal,
                    dictionary: dictionary
                )
            )
        }
        let manifestData =
            try SidecarCodec.encodeManifest(
                dictionaryData: dictionaryData,
                chunkData: chunkData,
                expectedReplicateContext:
                    context
            )
        let sidecar =
            try SidecarCodec.validateCompleteSidecar(
                dictionaryData: dictionaryData,
                chunkData: chunkData,
                manifestData: manifestData,
                expectedReplicateContext:
                    context
            )
        let repeatedManifestData =
            try SidecarCodec.encodeManifest(
                dictionaryData: dictionaryData,
                chunkData: chunkData,
                expectedReplicateContext:
                    context
            )
        try require(
            manifestData
                == repeatedManifestData,
            "manifest replay drift"
        )

        var reconstructedDecisionCount:
            UInt64 = 0
        for (
            rowOrdinal,
            chunk
        ) in sidecar.chunks
            .flatMap(\.rows)
            .enumerated()
        {
            try require(
                chunk.rowOrdinal == rowOrdinal,
                "reconstructed row ordinal drift"
            )
            try require(
                chunk.correlationID
                    == rows[rowOrdinal]
                    .source.rowID,
                "outer correlation drift"
            )
            for (
                offset,
                decision
            ) in chunk.decisions.enumerated() {
                let temporaryIndex =
                    rowTemporaryIndices[
                        rowOrdinal
                    ][offset]
                let dictionaryIndex =
                    Int(decision.dictionaryIndex)
                try require(
                    sidecar.dictionary
                        .orderedFullVocabularyLogitBitPatterns[
                            dictionaryIndex
                        ]
                        == uniqueBitPatterns[
                            temporaryIndex
                        ],
                    "lossless logit reconstruction drift"
                )
                reconstructedDecisionCount += 1
            }
        }
        try require(
            reconstructedDecisionCount
                == sidecar.manifest.decisionCount,
            "reconstructed decision count drift"
        )

        let mlx = try Recomputer.recompute(
            dictionary: sidecar.dictionary
        )
        try require(
            mlx.vectorCount
                == sidecar.dictionary.entryCount
                && mlx.inputDictionarySHA256
                    == sidecar.dictionary
                    .canonicalFileSHA256
                && mlx.evaluationSeed == seed,
            "typed MLX dictionary binding drift"
        )

        return ReplicateSummary(
            evaluationSeed: seed,
            dictionaryBitPatterns:
                sidecar.dictionary
                .orderedFullVocabularyLogitBitPatterns,
            dictionarySHA256:
                sidecar.dictionary
                .canonicalFileSHA256,
            aggregateSHA256:
                sidecar.manifest.aggregateSHA256,
            manifestSHA256:
                sidecar.manifest
                .canonicalFileSHA256,
            mlxLogProbabilitySHA256:
                mlx.bitPatternSHA256,
            decisionCount:
                sidecar.manifest.decisionCount,
            dictionaryByteCount:
                sidecar.dictionary
                .canonicalFileByteCount,
            aggregateByteCount:
                sidecar.manifest.aggregateByteCount,
            manifestByteCount:
                sidecar.manifest
                .canonicalFileByteCount
        )
    }

    private func require(
        _ condition: @autoclosure () -> Bool,
        _ detail: @autoclosure () -> String
    ) throws {
        guard condition() else {
            throw HarnessError.invariant(
                detail()
            )
        }
    }
}
