import CryptoKit
import Foundation
import PrimeNativeNeuralGateCorrectedMechanics
import PrimeNativeNeuralGateLogitSidecarMechanics
@testable import PrimeNativeNeuralGateMLXLogSoftmaxRecomputation
import XCTest

final class
    PrimeNativeNeuralGateMLXLogSoftmaxRecomputationTests:
    XCTestCase
{
    private typealias Provenance =
        PrimeNativeNeuralGateMLXLogSoftmaxProvenance
    private typealias Recomputer =
        PrimeNativeNeuralGateMLXFloat32LogSoftmaxRecomputer
    private typealias RecomputationError =
        PrimeNativeNeuralGateMLXLogSoftmaxRecomputationError

    func testProvenancePinsExactHistoricalAndMaintainedSources()
    {
        XCTAssertEqual(
            Provenance.companionRevision,
            "163fc100710ece48119bc25954452d10f6a84f7f"
        )
        XCTAssertEqual(
            Provenance.companionTreeOID,
            "9009daa4f8a07fbd5897e00b9571cef44ec292db"
        )
        XCTAssertEqual(
            Provenance.companionExecutorGitBlobOID,
            "94227842cdff73434c926527a6081aaf20f37155"
        )
        XCTAssertEqual(
            Provenance.companionExecutorByteCount,
            174_006
        )
        XCTAssertEqual(
            Provenance.companionExecutorSHA256,
            "7a3ba9477a7ac82dccfe6dcc7ec09af738b40298cdab6b259ddf1e9d36ec15b4"
        )
        XCTAssertEqual(
            Provenance
                .companionPackageResolvedGitBlobOID,
            "18aef69512c82c3e6cdff192f3aa0a6ee13c702e"
        )
        XCTAssertEqual(
            Provenance
                .companionPackageResolvedByteCount,
            1_949
        )
        XCTAssertEqual(
            Provenance
                .companionPackageResolvedSHA256,
            "cf1ba313dcb0c959e80ba09d6cbe0c56bcd921523bda5cec2c682c8ae7696ab3"
        )

        XCTAssertEqual(
            Provenance.upstreamMLXSwiftRevision,
            "072b684acaae80b6a463abab3a103732f33774bf"
        )
        XCTAssertEqual(
            Provenance.upstreamMLXSwiftTreeOID,
            "aecc4c90c4720b0624def30913f139eb1e878ea5"
        )
        XCTAssertEqual(
            Provenance
                .upstreamActivationsGitBlobOID,
            "f5ee9205eac15b537f6a9552371c30255c88e69e"
        )
        XCTAssertEqual(
            Provenance.upstreamActivationsByteCount,
            19_101
        )
        XCTAssertEqual(
            Provenance.upstreamActivationsSHA256,
            "c6e82121f1a7efceca0de234b5ef0058162f70bcccc4cef63b6d85d524ef1beb"
        )

        XCTAssertEqual(
            Provenance.forkMLXSwiftRevision,
            "d37885a278f1c37484a94d0f401a418735e66519"
        )
        XCTAssertEqual(
            Provenance.forkMLXSwiftTreeOID,
            "5310749549cca107fc1bb07d82dacf043bc02b9e"
        )
        XCTAssertEqual(
            Provenance.forkActivationsGitBlobOID,
            "a40618fac9f7c2226599c0219eccc11fcfcb0df5"
        )
        XCTAssertEqual(
            Provenance.forkActivationsByteCount,
            23_918
        )
        XCTAssertEqual(
            Provenance.forkActivationsSHA256,
            "5145539a33687bb4e9ce5ac00b821fef9f5e18652818c278c1807443b5e552f1"
        )
        XCTAssertEqual(
            Provenance.exactLogSoftmaxFunctionSHA256,
            "8d576115e1be7648d4a4da72c025893d23e67b1d30a53646d09e74bfe58fc639"
        )
        let exactFunction =
            "public func logSoftmax(_ x: MLXArray, axis: Int = -1) -> MLXArray {\n"
            + "    x - logSumExp(x, axis: axis, keepDims: true)\n"
            + "}\n"
        XCTAssertEqual(
            SHA256.hash(
                data: Data(exactFunction.utf8)
            ).map {
                String(format: "%02x", $0)
            }.joined(),
            Provenance.exactLogSoftmaxFunctionSHA256
        )
        XCTAssertTrue(
            Provenance.sourcePinnedOperationImplemented
        )
    }

    func testNonclaimsRemainClosed() {
        XCTAssertFalse(
            Provenance
                .companionRuntimeDependencyPresent
        )
        XCTAssertFalse(
            Provenance
                .neuralKitRuntimeDependencyPresent
        )
        XCTAssertFalse(
            Provenance.modelExecutionClaimed
        )
        XCTAssertFalse(
            Provenance.metalExecutionAuthorityClaimed
        )
        XCTAssertFalse(
            Provenance.durableStageBArtifactPublished
        )
        XCTAssertFalse(
            Provenance
                .independentProcessReceiptPublished
        )
        XCTAssertFalse(
            Provenance.scientificIndependenceClaimed
        )
        XCTAssertFalse(
            Provenance.calibrationEvidenceClaimed
        )
        XCTAssertFalse(
            Provenance.productAuthorityClaimed
        )
    }

    func testValidatedSidecarAdapterPreservesExactDictionaryBinding()
        throws
    {
        let context =
            try PrimeNativeNeuralGateCorrectedReplicateContext(
                evaluationSeed: 1_618
            )
        let dictionaryData =
            try PrimeNativeNeuralGateLogitSidecarCodec
            .encodeDictionary(
                fullVocabularyLogits: [
                    structuralVector(
                        selectedTokenID: 511
                    ),
                    structuralVector(
                        selectedTokenID: 70
                    ),
                ],
                replicateContext: context
            )
        let dictionary =
            try PrimeNativeNeuralGateLogitSidecarCodec
            .decodeDictionary(
                dictionaryData,
                expectedReplicateContext:
                    context
            )
        let typed = try Recomputer.recompute(
            dictionary: dictionary
        )
        let rawVectors =
            try (0 ..< dictionary.entryCount)
            .map {
                try dictionary.fullVocabularyLogits(
                    at: UInt32($0)
                )
            }
        let raw = try Recomputer.recompute(
            fullVocabularyLogitVectors:
                rawVectors,
            inputDictionarySHA256:
                dictionary.canonicalFileSHA256,
            evaluationSeed:
                dictionary.evaluationSeed
        )

        XCTAssertEqual(typed, raw)
        XCTAssertEqual(
            typed.inputDictionarySHA256,
            dictionary.canonicalFileSHA256
        )
        XCTAssertEqual(
            typed.evaluationSeed,
            1_618
        )
        XCTAssertEqual(
            typed.vectorCount,
            dictionary.entryCount
        )
    }

    func testBatchedEqualsSingletonAndIsExactlyRepeatable()
        throws
    {
        let selectedTokenIDs = [
            70,
            256,
            511,
        ]
        let vectors =
            selectedTokenIDs.map(
                structuralVector
            )
        let first = try Recomputer.recompute(
            fullVocabularyLogitVectors:
                vectors,
            inputDictionarySHA256:
                String(repeating: "a", count: 64)
        )
        let second = try Recomputer.recompute(
            fullVocabularyLogitVectors:
                vectors,
            inputDictionarySHA256:
                String(repeating: "a", count: 64)
        )

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.vectorCount, 3)
        XCTAssertEqual(
            first.vocabularyCount,
            512
        )
        XCTAssertEqual(first.inputDType, "float32")
        XCTAssertEqual(first.outputDType, "float32")
        XCTAssertEqual(first.axis, -1)
        XCTAssertEqual(
            first.logProbabilityVectors.count,
            3
        )
        XCTAssertTrue(
            first.logProbabilityVectors
                .allSatisfy {
                    $0.count == 512
                        && $0.allSatisfy {
                            $0.isFinite && $0 <= 0
                        }
                }
        )

        var singletonVectors: [[Float]] = []
        for (
            index,
            vector
        ) in vectors.enumerated() {
            let singleton =
                try Recomputer.recompute(
                    fullVocabularyLogitVectors: [
                        vector,
                    ],
                    inputDictionarySHA256:
                        String(
                            repeating:
                                Character(
                                    String(
                                        format:
                                            "%x",
                                        index + 1
                                    )
                                ),
                            count: 64
                        )
                )
            singletonVectors.append(
                singleton
                    .logProbabilityVectors[0]
            )
        }
        XCTAssertEqual(
            first.logProbabilityVectors,
            singletonVectors
        )

        for (
            vectorIndex,
            selectedTokenID
        ) in selectedTokenIDs.enumerated() {
            let vector =
                first.logProbabilityVectors[
                    vectorIndex
                ]
            let selectedBits =
                vector[selectedTokenID]
                .bitPattern
            let unselectedBits =
                vector[
                    selectedTokenID == 0
                    ? 1
                    : 0
                ].bitPattern
            XCTAssertTrue(
                vector.indices.allSatisfy {
                    $0 == selectedTokenID
                        ? vector[$0].bitPattern
                            == selectedBits
                        : vector[$0].bitPattern
                            == unselectedBits
                }
            )
            XCTAssertGreaterThan(
                vector[selectedTokenID],
                vector[
                    selectedTokenID == 0
                    ? 1
                    : 0
                ]
            )
        }
        XCTAssertEqual(
            first.bitPatternSHA256.count,
            64
        )
        XCTAssertTrue(
            first.bitPatternSHA256.utf8
                .allSatisfy {
                    ($0 >= 48 && $0 <= 57)
                        || ($0 >= 97 && $0 <= 102)
                }
        )
        XCTAssertEqual(
            first.bitPatternSHA256,
            second.bitPatternSHA256
        )
        XCTAssertEqual(
            first.bitPatternSHA256,
            "8dca965dbb3057c79d268435b23e58ecab8e77ecfe745b6a434cc1b2a852d98a"
        )
    }

    func testMalformedAndNonfiniteInputsFailClosed()
        throws
    {
        let sha = String(
            repeating: "0",
            count: 64
        )
        XCTAssertThrowsError(
            try Recomputer.recompute(
                fullVocabularyLogitVectors: [],
                inputDictionarySHA256: sha
            )
        ) {
            XCTAssertEqual(
                $0 as? RecomputationError,
                .emptyDictionary
            )
        }

        XCTAssertThrowsError(
            try Recomputer.recompute(
                fullVocabularyLogitVectors: [
                    Array(
                        repeating: 0,
                        count: 511
                    ),
                ],
                inputDictionarySHA256: sha
            )
        ) {
            XCTAssertEqual(
                $0 as? RecomputationError,
                .invalidVocabularyCount(
                    vectorIndex: 0,
                    observed: 511
                )
            )
        }

        for nonfinite in [
            Float.nan,
            Float.infinity,
            -Float.infinity,
        ] {
            var vector = structuralVector(
                selectedTokenID: 70
            )
            vector[13] = nonfinite
            XCTAssertThrowsError(
                try Recomputer.recompute(
                    fullVocabularyLogitVectors: [
                        vector,
                    ],
                    inputDictionarySHA256:
                        sha
                )
            ) {
                XCTAssertEqual(
                    $0 as? RecomputationError,
                    .nonfiniteInput(
                        vectorIndex: 0,
                        tokenID: 13
                    )
                )
            }
        }

        XCTAssertThrowsError(
            try Recomputer.recompute(
                fullVocabularyLogitVectors: [
                    structuralVector(
                        selectedTokenID: 70
                    ),
                ],
                inputDictionarySHA256: "ABC"
            )
        ) {
            XCTAssertEqual(
                $0 as? RecomputationError,
                .invalidDictionarySHA256
            )
        }
    }

    func testTwoHundredFiftySevenVectorsCrossBatchBoundaryExactly()
        throws
    {
        let selectedTokenIDs =
            [70] + Array(256 ... 511)
        let inputs =
            selectedTokenIDs.map(
                structuralVector
            )
        let combined = try Recomputer.recompute(
            fullVocabularyLogitVectors: inputs,
            inputDictionarySHA256:
                String(repeating: "b", count: 64)
        )
        let firstBatch = try Recomputer.recompute(
            fullVocabularyLogitVectors:
                Array(inputs[0 ..< 256]),
            inputDictionarySHA256:
                String(repeating: "c", count: 64)
        )
        let finalSingleton =
            try Recomputer.recompute(
                fullVocabularyLogitVectors: [
                    inputs[256],
                ],
                inputDictionarySHA256:
                    String(
                        repeating: "d",
                        count: 64
                    )
            )
        let reconstructed =
            firstBatch.logProbabilityVectors
            + finalSingleton.logProbabilityVectors

        XCTAssertEqual(
            Recomputer.maximumMLXBatchVectorCount,
            256
        )
        XCTAssertEqual(combined.vectorCount, 257)
        XCTAssertEqual(
            combined.logProbabilityVectors,
            reconstructed
        )
        let reconstructedSHA256 =
            Recomputer.bitPatternSHA256(
                reconstructed
            )
        XCTAssertEqual(
            combined.bitPatternSHA256,
            reconstructedSHA256
        )
    }

    func testDictionaryVectorCountLimitFailsBeforeMLX()
    {
        let vectors = Array(
            repeating:
                structuralVector(
                    selectedTokenID: 70
                ),
            count:
                Recomputer
                .maximumDictionaryVectorCount
                + 1
        )
        XCTAssertThrowsError(
            try Recomputer.recompute(
                fullVocabularyLogitVectors:
                    vectors,
                inputDictionarySHA256:
                    String(
                        repeating: "f",
                        count: 64
                    )
            )
        ) {
            XCTAssertEqual(
                $0 as? RecomputationError,
                .dictionaryVectorCountLimitExceeded(
                    observed: 65_537
                )
            )
        }
    }

    private func structuralVector(
        selectedTokenID: Int
    ) -> [Float] {
        var vector = Array(
            repeating: Float(-1),
            count: 512
        )
        vector[selectedTokenID] = 1
        return vector
    }
}
