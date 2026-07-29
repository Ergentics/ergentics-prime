import Foundation
import XCTest

final class PrimeGPUCalibrationSourceContractTests:
    XCTestCase
{
    func testSourceSnapshotDelegatesToSharedProvenance()
        throws
    {
        let source = try calibrationSource()
        let function = try slice(
            source,
            from: "private func sourceSnapshot(",
            until: "private func runningExecutableURL("
        )
        try assertOrdered(
            [
                "PrimeSwiftSourceProvenance",
                ".capture(",
                "at: sourceRoot",
                "PrimeNative3BFP32ExecutionConfiguration",
                ".requiredPrimeSourceRelativePaths",
            ],
            in: function
        )
        XCTAssertFalse(
            function.contains(
                "FileManager.default.enumerator"
            )
        )
        XCTAssertFalse(
            function.contains(
                "PrimeSHA256.hexDigest"
            )
        )
    }

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
                "let executableURL = try stagedExecutableURL(",
                "switch metallibReverification",
                "case .currentProcess:",
                "PrimePinnedMLXMetallib.reverifySibling(",
                "case .stagedRuntimeImage:",
                ".reverifyStagedRuntimeImage(",
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
                ".reverifyStagedRuntimeImage(",
                "let finalReceipt = receipt.finalized(",
                "try finalReceipt.validate(",
                "try artifactRoot.publishCanonical(",
            ],
            in: grounded
        )
    }

    func testWorkerAndSupervisorFailurePathsBindExactRuntimeRole()
        throws
    {
        let source = try calibrationSource()
        let worker = try slice(
            source,
            from: "private func runWorker(",
            until: "private func runSupervisor("
        )
        XCTAssertEqual(
            occurrences(
                of: ".currentProcess",
                in: worker
            ),
            2
        )
        XCTAssertEqual(
            occurrences(
                of: ".stagedRuntimeImage",
                in: worker
            ),
            0
        )

        let supervisor = try slice(
            source,
            from: "private func runSupervisor(",
            until: "@main"
        )
        XCTAssertEqual(
            occurrences(
                of: ".stagedRuntimeImage",
                in: supervisor
            ),
            6
        )
        XCTAssertEqual(
            occurrences(
                of: ".currentProcess",
                in: supervisor
            ),
            0
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

    private func occurrences(
        of needle: String,
        in source: Substring
    ) -> Int {
        var count = 0
        var cursor = source.startIndex
        while let match = source.range(
            of: needle,
            range: cursor ..< source.endIndex
        ) {
            count += 1
            cursor = match.upperBound
        }
        return count
    }
}
