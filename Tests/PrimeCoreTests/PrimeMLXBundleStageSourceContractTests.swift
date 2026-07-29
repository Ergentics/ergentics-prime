import Foundation
import XCTest
@testable import PrimeCore

final class PrimeMLXBundleStageSourceContractTests:
    XCTestCase
{
    func testSharedCLIParserAcceptsOnlyExactRoleHostPairs()
        throws
    {
        let cases: [
            (
                role: PrimeMLXRuntimeRole,
                destination: String
            )
        ] = [
            (
                .calibration,
                "PrimeGPUCalibration"
            ),
            (
                .optimizerRestoreProbe,
                "PrimeOptimizerRestoreProbe"
            ),
        ]

        for testCase in cases {
            let parsed =
                try PrimeMLXBundleStageArguments
                    .parse(
                        [
                            "--source-host",
                            "/tmp/PrimeMLXBundleDonor",
                            "--destination-host",
                            "/tmp/\(testCase.destination)",
                            "--runtime-role",
                            testCase.role.rawValue,
                        ]
                    )
            XCTAssertEqual(
                parsed.runtimeRole,
                testCase.role
            )
            XCTAssertEqual(
                parsed.destinationHost
                    .lastPathComponent,
                testCase.destination
            )
        }
    }

    func testSharedCLIParserRejectsCrossRoleHosts() {
        let cases: [
            (
                role: PrimeMLXRuntimeRole,
                destination: String
            )
        ] = [
            (
                .calibration,
                "PrimeOptimizerRestoreProbe"
            ),
            (
                .optimizerRestoreProbe,
                "PrimeGPUCalibration"
            ),
        ]

        for testCase in cases {
            XCTAssertThrowsError(
                try PrimeMLXBundleStageArguments
                    .parse(
                        [
                            "--source-host",
                            "/tmp/PrimeMLXBundleDonor",
                            "--destination-host",
                            "/tmp/\(testCase.destination)",
                            "--runtime-role",
                            testCase.role.rawValue,
                        ]
                    )
            ) { error in
                XCTAssertEqual(
                    error as?
                        PrimeMLXBundleStageArgumentError,
                    .invalidArgument(
                        "--destination-host basename must be " +
                            PrimeMLXRuntimeImageLayout
                            .destinationHostExecutableName(
                                for: testCase.role
                            ) +
                            " for --runtime-role " +
                            testCase.role.rawValue
                    )
                )
            }
        }
    }

    func testSharedCLIParserFailsClosedOnArgumentMutations() {
        let valid = [
            "--source-host",
            "/tmp/PrimeMLXBundleDonor",
            "--destination-host",
            "/tmp/PrimeGPUCalibration",
            "--runtime-role",
            "calibration",
        ]
        let mutations = [
            Array(valid.dropLast(2)),
            Array(valid.dropLast()) + ["caller_defined"],
            valid + [
                "--runtime-role",
                "optimizer_restore_probe",
            ],
            valid + [
                "--caller-defined",
                "value",
            ],
            [
                "--source-host",
                "/tmp/PrimeGPUCalibration",
                "--destination-host",
                "/tmp/PrimeGPUCalibration",
                "--runtime-role",
                "calibration",
            ],
        ]

        for mutation in mutations {
            XCTAssertThrowsError(
                try PrimeMLXBundleStageArguments
                    .parse(mutation)
            )
        }
    }

    func testSelectedRoleBindsCaptureAndBothStagedVerificationPaths()
        throws
    {
        let source = try stageSource()
        let expectedBinding = try slice(
            source,
            from: "private func expectedBinding(",
            until: "@main"
        )
        try assertOrdered(
            [
                "runtimeRole: PrimeMLXRuntimeRole",
                "PrimeMLXRuntimeImageLayout",
                ".declaration(",
                "for: runtimeRole",
            ],
            in: expectedBinding
        )

        let main = try slice(
            source,
            from: "@main",
            until:
                "Foundation.exit(EXIT_FAILURE)"
        )
        XCTAssertEqual(
            occurrences(
                of: "runtimeRole: runtimeRole",
                in: main
            ),
            4
        )
        try assertOrdered(
            [
                "PrimeMLXBundleStageArguments",
                ".parse(",
                "let runtimeRole =",
                "let destinationBundle =",
                "expectedBinding(",
                "runtimeRole: runtimeRole",
                ".reverifyStagedRuntimeImage(",
                "runtimeRole: runtimeRole",
            ],
            in: main
        )
        XCTAssertFalse(
            main.contains("runtimeRole!")
        )
        try assertOrdered(
            [
                ".captureSibling(",
                "runtimeRole: runtimeRole",
                ".reverifyStagedRuntimeImage(",
                "runtimeRole: runtimeRole",
            ],
            in: main
        )
    }

    private func stageSource() throws -> String {
        let url = URL(
            fileURLWithPath:
                FileManager.default.currentDirectoryPath,
            isDirectory: true
        ).appendingPathComponent(
            "Sources/PrimeMLXBundleStage/" +
                "PrimeMLXBundleStageMain.swift"
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
