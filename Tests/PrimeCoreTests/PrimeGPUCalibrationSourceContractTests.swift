import Foundation
import XCTest

final class PrimeGPUCalibrationSourceContractTests:
    XCTestCase
{
    func testFailurePublicationRetainsOrderedMetallibGate()
        throws
    {
        let source = try calibrationSource()
        let function = try slice(
            source,
            from: "private func publishFailure(",
            until: "private func supervisorDisposition("
        )
        try assertOrdered(
            [
                "PrimePinnedMLXMetallib.reverifySibling(",
                "let failure = PrimeGPUCalibrationFailureReceipt(",
                "try failure.validate(in: artifactRoot)",
                "try artifactRoot.publishCanonical(",
            ],
            in: function
        )
    }

    func testGroundedPromotionRetainsOrderedMetallibGate()
        throws
    {
        let source = try calibrationSource()
        let supervisor = try slice(
            source,
            from: "private func runSupervisor(",
            until: "@main"
        )
        let grounded = try slice(
            String(supervisor),
            from:
                "case let .grounded(receipt, candidateBinding):",
            until:
                "case let .abstain(receipt, candidateBinding):"
        )
        try assertOrdered(
            [
                "guard supervisorDisposition(",
                "PrimePinnedMLXMetallib",
                ".reverifySibling(",
                "let finalReceipt = receipt.finalized(",
                "try finalReceipt.validate(",
                "try artifactRoot.publishCanonical(",
            ],
            in: grounded
        )
    }

    private func calibrationSource() throws -> String {
        let url = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath,
            isDirectory: true
        ).appendingPathComponent(
            "Sources/PrimeGPUCalibration/" +
                "PrimeGPUCalibrationMain.swift"
        )
        return try String(
            contentsOf: url,
            encoding: .utf8
        )
    }

    private func slice(
        _ source: String,
        from startAnchor: String,
        until endAnchor: String
    ) throws -> Substring {
        let start = try XCTUnwrap(
            source.range(of: startAnchor)?.lowerBound
        )
        let end = try XCTUnwrap(
            source.range(
                of: endAnchor,
                range: start ..< source.endIndex
            )?.lowerBound
        )
        return source[start ..< end]
    }

    private func assertOrdered(
        _ anchors: [String],
        in source: Substring
    ) throws {
        var cursor = source.startIndex
        for anchor in anchors {
            let match = try XCTUnwrap(
                source.range(
                    of: anchor,
                    range: cursor ..< source.endIndex
                ),
                "missing ordered source-contract anchor: \(anchor)"
            )
            cursor = match.upperBound
        }
    }
}
