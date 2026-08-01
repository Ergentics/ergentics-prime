import Foundation
import XCTest
import PrimeNativeNeuralGateCorrectedMutationDetector
import PrimeNativeNeuralGateCorrectedMutationProducer
import PrimeNativeNeuralGateCorrectedMutationSurfaceContracts
import PrimeNativeNeuralGateSemanticRecordContracts

final class PrimeNativeNeuralGateCorrectedMutationIntegrationTests:
    XCTestCase
{
    func testExactProducedBatchIsDetectedAfterIdentityErasure()
        throws
    {
        let contract =
            PrimeNativeNeuralGateCorrectedMutationRecordContract
            .frozenV1
        try contract.validate()
        let produced =
            try PrimeNativeNeuralGateCorrectedMutationProducer
            .produceBatch(baseline: makeBaseline())
        let blind = produced.map(\.blindTriplet)
        let reports =
            try PrimeNativeNeuralGateCorrectedMutationDetector
            .detectBatch(blind)

        XCTAssertEqual(
            produced.count,
            PrimeNativeNeuralGateCorrectedMutationSurfaceContract
                .exactBlindBatchCount
        )
        XCTAssertEqual(reports.count, produced.count)
        for (item, report) in zip(produced, reports) {
            XCTAssertEqual(
                report.orderedLegObservations.map(\.legID),
                PrimeNativeNeuralGateCorrectedControlLegID
                    .allCases,
                item.identity.mutationID.rawValue
            )
            XCTAssertEqual(
                report.failedLegIDs,
                [item.identity.mutationID.expectedFailedLegID],
                item.identity.mutationID.rawValue
            )
            XCTAssertTrue(
                item.identity.exactAllowedFailedLegIDSets
                    .contains(report.failedLegIDs),
                item.identity.mutationID.rawValue
            )
            XCTAssertEqual(item.baseline, item.restored)
            XCTAssertNotEqual(item.baseline.bytes, item.mutated.bytes)

            let materialText = String(
                decoding: item.mutated.bytes,
                as: UTF8.self
            )
            XCTAssertFalse(
                materialText.contains(item.identity.mutationID.rawValue)
            )
            XCTAssertFalse(
                materialText.contains(
                    item.identity.mutationID
                        .expectedFailedLegID.rawValue
                )
            )
        }
    }

    func testDetectorBatchIsReversalAndRotationInvariantBySurfaceIdentity()
        throws
    {
        let produced =
            try PrimeNativeNeuralGateCorrectedMutationProducer
            .produceBatch(baseline: makeBaseline())
        let batch = produced.map(\.blindTriplet)
        let expected = try keyedReports(batch)

        XCTAssertEqual(
            try keyedReports(Array(batch.reversed())),
            expected
        )
        let rotation = 6
        let rotated = Array(batch.dropFirst(rotation))
            + Array(batch.prefix(rotation))
        XCTAssertEqual(try keyedReports(rotated), expected)

        var transpositionCount = 0
        for first in batch.indices {
            for second in batch.indices where second > first {
                var transposed = batch
                transposed.swapAt(first, second)
                XCTAssertEqual(
                    try keyedReports(transposed),
                    expected,
                    "transposition \(first)<->\(second)"
                )
                transpositionCount += 1
            }
        }
        XCTAssertEqual(transpositionCount, 105)
    }

    func testImplementationSourcesRemainMutuallyUnaware()
        throws
    {
        let root = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath,
            isDirectory: true
        )
        let producer = try String(
            contentsOf:
                root.appendingPathComponent(
                    "Sources/PrimeNativeNeuralGateCorrectedMutationProducer/PrimeNativeNeuralGateCorrectedMutationProducer.swift"
                ),
            encoding: .utf8
        )
        let detector = try String(
            contentsOf:
                root.appendingPathComponent(
                    "Sources/PrimeNativeNeuralGateCorrectedMutationDetector/PrimeNativeNeuralGateCorrectedMutationDetector.swift"
                ),
            encoding: .utf8
        )

        XCTAssertFalse(
            producer.contains(
                "PrimeNativeNeuralGateCorrectedMutationDetector"
            )
        )
        XCTAssertFalse(
            detector.contains(
                "PrimeNativeNeuralGateCorrectedMutationProducer"
            )
        )
        XCTAssertFalse(
            detector.contains(
                "PrimeNativeNeuralGateCorrectedMutationCaseID"
            )
        )
        XCTAssertFalse(detector.contains("expectedFailedLegID"))
        XCTAssertFalse(detector.contains("mutationID"))
        XCTAssertTrue(
            producer.contains(
                "import PrimeNativeNeuralGateSemanticRecordContracts"
            )
        )
        XCTAssertFalse(
            detector.contains(
                "import PrimeNativeNeuralGateSemanticRecordContracts"
            )
        )
        XCTAssertTrue(
            detector.contains(
                "import PrimeNativeNeuralGateCorrectedMutationSurfaceContracts"
            )
        )
        XCTAssertTrue(
            detector.contains("public static func detectBatch(")
        )
        XCTAssertTrue(
            detector.contains("private static func detectSingle(")
        )
        XCTAssertFalse(
            detector.contains("public static func detect(")
        )
        XCTAssertFalse(producer.contains("import PrimeCore"))
        XCTAssertFalse(detector.contains("import PrimeCore"))
        XCTAssertFalse(producer.contains("import MLX"))
        XCTAssertFalse(detector.contains("import MLX"))
    }

    private func makeBaseline() throws
        -> PrimeNativeNeuralGateCorrectedControlMaterial
    {
        try .baseline(
            commonCaptureScheduleReferenceSHA256:
                String(repeating: "a", count: 64),
            branchCaptureScheduleReferenceSHA256:
                String(repeating: "b", count: 64),
            replicateSeed: 1_618
        )
    }

    private func keyedReports(
        _ batch:
            [PrimeNativeNeuralGateBlindCorrectedMutationTriplet]
    ) throws -> [String: [PrimeNativeNeuralGateCorrectedControlLegID]] {
        let reports =
            try PrimeNativeNeuralGateCorrectedMutationDetector
            .detectBatch(batch)
        return Dictionary(
            uniqueKeysWithValues: zip(batch, reports).map {
                (
                    $0.0.mutated.binding.surfaceSHA256
                        + ":"
                        + $0.0.mutated.bytes.base64EncodedString(),
                    $0.1.failedLegIDs
                )
            }
        )
    }
}
