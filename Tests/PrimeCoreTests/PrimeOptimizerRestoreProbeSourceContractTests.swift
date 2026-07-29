import Foundation
import XCTest

final class PrimeOptimizerRestoreProbeSourceContractTests:
    XCTestCase
{
    func testProbeKeepsCPUScopedMaintainedMechanics()
        throws
    {
        let source = try probeSource()
        XCTAssertTrue(
            source.contains(
                "Device.withDefaultDevice(.cpu)"
            )
        )
        XCTAssertTrue(
            source.contains(
                "try requireCPUDefault()"
            )
        )
        XCTAssertTrue(
            source.contains(
                "device.deviceType == .cpu"
            )
        )
        XCTAssertTrue(
            source.contains(
                "StreamOrDevice.default.description"
            )
        )
        XCTAssertTrue(
            source.contains(
                "PrimeOptimizerRestoreCPUExecutionObservations("
            )
        )
        XCTAssertTrue(
            source.contains("valueAndGrad(")
        )
        XCTAssertTrue(
            source.contains("let optimizer = AdamW(")
        )
        XCTAssertTrue(
            source.contains("optimizer.update(")
        )
        XCTAssertTrue(
            source.contains("try checkedEval(")
        )
        XCTAssertTrue(
            source.contains("try MLX.save(")
        )
        XCTAssertTrue(
            source.contains(
                "try MLX.loadArraysAndMetadata("
            )
        )
        XCTAssertTrue(
            source.contains("verify: .all")
        )
    }

    func testProbeRejectsUnsupportedExecutionRoutes()
        throws
    {
        let source = try probeSource()
        let forbidden = [
            ".gpu",
            "_updateInternal",
            "Python",
            "python",
            "shell",
            "/bin/" + "sh",
            "-c",
        ]
        for token in forbidden {
            XCTAssertFalse(
                source.contains(token),
                "forbidden restore-probe source token: \(token)"
            )
        }
    }

    func testParentRunsDistinctWriterThenVerifierImages()
        throws
    {
        let source = try probeSource()
        let parent = try slice(
            source,
            from: "private func runParent(",
            until: "@main"
        )
        try assertOrdered(
            [
                "PrimePinnedMLXMetallib.captureSibling(",
                "runtimeRole: .optimizerRestoreProbe",
                "let executable = try root.publish(",
                "purpose: .executable",
                "let launchedWriterPID = try runChild(",
                "role: .writer",
                "let launchedVerifierPID = try runChild(",
                "role: .verifier",
                ".reverifyStagedRuntimeImage(",
                "let writerBinding = try root.bindExisting(",
                "let verifierBinding = try root.bindExisting(",
                "writer.processIdentifier",
                "== launchedWriterPID",
                "verifier.verifierProcessIdentifier",
                "== launchedVerifierPID",
                "PrimeOptimizerRestoreReceipt(",
                "try receipt.validate(in: root)",
                "try root.publishCanonical(",
            ],
            in: parent
        )
        XCTAssertTrue(
            source.contains(
                "let process = Process()"
            )
        )
        XCTAssertTrue(
            source.contains(
                "process.executableURL = executableURL"
            )
        )
        XCTAssertTrue(
            source.contains(
                "return process.processIdentifier"
            )
        )
        XCTAssertEqual(
            source.components(
                separatedBy:
                    "maximumByteCount: 256 * 1024 * 1024"
            ).count - 1,
            2
        )
    }

    func testProbeRecordsTruthfulUnsupportedRestore()
        throws
    {
        let source = try probeSource()
        XCTAssertTrue(
            source.contains(
                "supportedTypedOptimizerRestoreAPI:" +
                    "\n                .observed(false)"
            )
        )
        XCTAssertTrue(
            source.contains(
                "implementationDetailMutationUsed:" +
                    "\n                .observed(false)"
            )
        )
        XCTAssertTrue(
            source.contains(
                "exactTrajectoryContinuation:" +
                    "\n                .unavailable,"
            )
        )
        XCTAssertTrue(
            source.contains(
                "outcome: .abstain"
            )
        )
        XCTAssertTrue(
            source.contains(
                "private let abstainExitStatus: Int32 = 2"
            )
        )
        XCTAssertTrue(
            source.contains(
                "exit(abstainExitStatus)"
            )
        )
        XCTAssertTrue(
            source.contains(
                "Source/MLX/Nested.swift"
            )
        )
    }

    private func probeSource() throws -> String {
        let url = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath,
            isDirectory: true
        ).appendingPathComponent(
            "Sources/PrimeOptimizerRestoreProbe/" +
                "PrimeOptimizerRestoreProbeMain.swift"
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
