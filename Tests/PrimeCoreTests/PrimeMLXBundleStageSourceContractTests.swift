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
            (
                .typedOptimizerRestoreProbe,
                "PrimeTypedOptimizerRestoreProbe"
            ),
            (
                .native3BMetalContinuationProbe,
                "PrimeNative3BMetalContinuationProbe"
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
            let scaffold =
                try PrimeMLXRuntimeScaffoldArguments
                    .parse(
                        [
                            "--source-root",
                            "/private/tmp/ergentics-prime-source",
                            "--destination-host",
                            "/private/tmp/\(testCase.destination)",
                            "--runtime-role",
                            testCase.role.rawValue,
                        ]
                    )
            XCTAssertEqual(
                scaffold.runtimeRole,
                testCase.role
            )
            XCTAssertEqual(
                scaffold.destinationHost
                    .lastPathComponent,
                testCase.destination
            )
            XCTAssertEqual(
                scaffold.sourceRoot.lastPathComponent,
                "ergentics-prime-source"
            )
        }
    }

    func testSharedCLIParserRejectsCrossRoleHosts() {
        for role in PrimeMLXRuntimeRole.allCases {
            for otherRole
            in PrimeMLXRuntimeRole.allCases
            where otherRole != role {
                let destination =
                    PrimeMLXRuntimeImageLayout
                    .destinationHostExecutableName(
                        for: otherRole
                    )
                XCTAssertThrowsError(
                    try PrimeMLXBundleStageArguments
                        .parse(
                            [
                                "--source-host",
                                "/tmp/PrimeMLXBundleDonor",
                                "--destination-host",
                                "/tmp/\(destination)",
                                "--runtime-role",
                                role.rawValue,
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
                                    for: role
                                ) +
                                " for --runtime-role " +
                                role.rawValue
                        )
                    )
                }
                XCTAssertThrowsError(
                    try PrimeMLXRuntimeScaffoldArguments
                        .parse(
                            [
                                "--source-root",
                                "/private/tmp/ergentics-prime-source",
                                "--destination-host",
                                "/private/tmp/\(destination)",
                                "--runtime-role",
                                role.rawValue,
                            ]
                        )
                ) { error in
                    XCTAssertEqual(
                        error as?
                            PrimeMLXRuntimeScaffoldArgumentError,
                        .invalidArgument(
                            "--destination-host basename must be " +
                                PrimeMLXRuntimeImageLayout
                                .destinationHostExecutableName(
                                    for: role
                                ) +
                                " for --runtime-role " +
                                role.rawValue
                        )
                    )
                }
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

        let validScaffold = [
            "--source-root",
            "/private/tmp/ergentics-prime-source",
            "--destination-host",
            "/private/tmp/PrimeGPUCalibration",
            "--runtime-role",
            "calibration",
        ]
        let scaffoldMutations = [
            Array(validScaffold.dropLast(2)),
            Array(validScaffold.dropLast()) + [
                "caller_defined",
            ],
            validScaffold + [
                "--source-root",
                "/private/tmp/second-source",
            ],
            validScaffold + [
                "--destination-host",
                "/private/tmp/PrimeGPUCalibration",
            ],
            validScaffold + [
                "--runtime-role",
                "optimizer_restore_probe",
            ],
            validScaffold + [
                "--caller-defined",
                "value",
            ],
        ]
        for mutation in scaffoldMutations {
            XCTAssertThrowsError(
                try PrimeMLXRuntimeScaffoldArguments
                    .parse(mutation)
            )
        }
    }

    func testSharedCLIParserRejectsSymlinkTraversalBeforeResolution()
        throws
    {
        let root =
            FileManager.default
            .temporaryDirectory
            .appendingPathComponent(
                "prime-mlx-stage-arguments-\(UUID().uuidString)",
                isDirectory: true
            )
        defer {
            try? FileManager.default.removeItem(
                at: root
            )
        }
        let sourceDirectory =
            root.appendingPathComponent(
                "source",
                isDirectory: true
            )
        let destinationDirectory =
            root.appendingPathComponent(
                "destination",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: sourceDirectory,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: destinationDirectory,
            withIntermediateDirectories: true
        )
        let sourceHost =
            sourceDirectory.appendingPathComponent(
                "PrimeMLXBundleDonor"
            )
        let destinationHost =
            destinationDirectory
            .appendingPathComponent(
                "PrimeGPUCalibration"
            )
        try Data().write(to: sourceHost)
        try Data().write(to: destinationHost)

        let sourceAlias =
            root.appendingPathComponent(
                "source-alias",
                isDirectory: true
            )
        try FileManager.default
            .createSymbolicLink(
                at: sourceAlias,
                withDestinationURL:
                    sourceDirectory
            )
        XCTAssertThrowsError(
            try PrimeMLXBundleStageArguments
                .parse(
                    [
                        "--source-host",
                        sourceAlias
                            .appendingPathComponent(
                                "PrimeMLXBundleDonor"
                            ).path,
                        "--destination-host",
                        destinationHost.path,
                        "--runtime-role",
                        "calibration",
                    ]
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeMLXBundleStageArgumentError,
                .invalidArgument(
                    "--source-host must not traverse symbolic links"
                )
            )
        }
        XCTAssertThrowsError(
            try PrimeMLXRuntimeScaffoldArguments
                .parse(
                    [
                        "--source-root",
                        sourceAlias.path,
                        "--destination-host",
                        destinationHost.path,
                        "--runtime-role",
                        "calibration",
                    ]
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeMLXRuntimeScaffoldArgumentError,
                .invalidArgument(
                    "--source-root must not traverse symbolic links"
                )
            )
        }

        let destinationAlias =
            root.appendingPathComponent(
                "destination-alias",
                isDirectory: true
            )
        try FileManager.default
            .createSymbolicLink(
                at: destinationAlias,
                withDestinationURL:
                    destinationDirectory
            )
        XCTAssertThrowsError(
            try PrimeMLXBundleStageArguments
                .parse(
                    [
                        "--source-host",
                        sourceHost.path,
                        "--destination-host",
                        destinationAlias
                            .appendingPathComponent(
                                "PrimeGPUCalibration"
                            ).path,
                        "--runtime-role",
                        "calibration",
                    ]
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeMLXBundleStageArgumentError,
                .invalidArgument(
                    "--destination-host must not traverse symbolic links"
                )
            )
        }
        XCTAssertThrowsError(
            try PrimeMLXRuntimeScaffoldArguments
                .parse(
                    [
                        "--source-root",
                        sourceDirectory.path,
                        "--destination-host",
                        destinationAlias
                            .appendingPathComponent(
                                "PrimeGPUCalibration"
                            ).path,
                        "--runtime-role",
                        "calibration",
                    ]
                )
        ) { error in
            XCTAssertEqual(
                error as?
                    PrimeMLXRuntimeScaffoldArgumentError,
                .invalidArgument(
                    "--destination-host must not traverse symbolic links"
                )
            )
        }
    }

    func testSelectedRoleBindsOneUnconditionalExactStageAndManifestOutput()
        throws
    {
        let source = try stageSource()
        let main = try slice(
            source,
            from: "@main",
            until:
                "Foundation.exit(EXIT_FAILURE)"
        )
        XCTAssertEqual(
            occurrences(
                of: ".stageExactXcodeMetallib(",
                in: main
            ),
            1
        )
        try assertOrdered(
            [
                "PrimeMLXBundleStageArguments",
                ".parse(",
                "let runtimeRole =",
                ".stageExactXcodeMetallib(",
                "from: arguments.sourceHost",
                "beside: arguments.destinationHost",
                "runtimeRole: runtimeRole",
                "destination_metallib_initially_absent=",
                "result.destinationMetallibInitiallyAbsent",
                "xcode_donor_info_plist_sha256=",
                "expectedXcodeDonorInfoPlistSHA256",
                "runtime_info_plist_sha256=",
                "expectedInfoPlistSHA256",
                "metallib_sha256=",
                "result.binding.artifact.sha256",
            ],
            in: main
        )
        XCTAssertFalse(
            main.contains("runtimeRole!")
        )
        for forbidden in [
            "fileExists(",
            ".captureSibling(",
            "python",
            "/bin/sh",
            "/bin/zsh",
            "copyItem(",
            "moveItem(",
            "removeItem(",
        ] {
            XCTAssertFalse(
                main.contains(forbidden),
                "forbidden exact-stage route \(forbidden)"
            )
        }

        let scaffoldSource = try String(
            contentsOf: URL(
                fileURLWithPath:
                    FileManager.default
                    .currentDirectoryPath,
                isDirectory: true
            ).appendingPathComponent(
                "Sources/PrimeMLXRuntimeScaffold/" +
                    "PrimeMLXRuntimeScaffoldMain.swift"
            ),
            encoding: .utf8
        )
        let scaffoldMain = try slice(
            scaffoldSource,
            from: "@main",
            until:
                "Foundation.exit(EXIT_FAILURE)"
        )
        XCTAssertEqual(
            occurrences(
                of: ".scaffoldCanonicalRuntimeBundle(",
                in: scaffoldMain
            ),
            1
        )
        try assertOrdered(
            [
                "PrimeMLXRuntimeScaffoldArguments",
                ".parse(",
                "let runtimeRole =",
                ".scaffoldCanonicalRuntimeBundle(",
                "from: arguments.sourceRoot",
                "beside: arguments.destinationHost",
                "runtimeRole: runtimeRole",
                "destination_bundle_initially_absent=",
                "result.destinationBundleInitiallyAbsent",
                "runtime_info_plist_sha256=",
                "result.infoPlist.sha256",
                "metallib_absent=true",
            ],
            in: scaffoldMain
        )
        for forbidden in [
            "runtimeRole!",
            "fileExists(",
            "python",
            "/bin/sh",
            "/bin/zsh",
            "Process(",
            "copyItem(",
            "moveItem(",
            "removeItem(",
            "Data(contentsOf:",
            "Templates/",
            "canonical-swiftpm-runtime",
            "Info.plist",
        ] {
            XCTAssertFalse(
                scaffoldMain.contains(forbidden),
                "forbidden runtime-scaffold CLI route \(forbidden)"
            )
        }

        let pinnedRuntimeSource = try String(
            contentsOf: URL(
                fileURLWithPath:
                    FileManager.default
                    .currentDirectoryPath,
                isDirectory: true
            ).appendingPathComponent(
                "Sources/PrimeCore/" +
                    "PrimePinnedMLXMetallib.swift"
            ),
            encoding: .utf8
        )
        let publicScaffold = try slice(
            pinnedRuntimeSource,
            from:
                "public static func scaffoldCanonicalRuntimeBundle(",
            until:
                "\n    static func scaffoldCanonicalRuntimeBundle("
        )
        XCTAssertEqual(
            occurrences(
                of: ".validateReleaseEvidence(",
                in: publicScaffold
            ),
            1
        )
        try assertOrdered(
            [
                "PrimeSwiftSourceProvenance.capture(",
                ".validateReleaseEvidence(",
                "withHeldCanonicalRuntimeInfoPlist(",
                "guard heldTemplate",
                "== template.contents",
                "usingCanonicalRuntimeInfoPlist:",
                "heldTemplate",
            ],
            in: publicScaffold
        )
    }

    func testIsolatedMechanicsTestStagerIsSwiftOnlyAndPathBound()
        throws
    {
        let source = try String(
            contentsOf: URL(
                fileURLWithPath:
                    FileManager.default
                    .currentDirectoryPath,
                isDirectory: true
            ).appendingPathComponent(
                "Sources/PrimeMLXTestBundleStage/" +
                    "PrimeMLXTestBundleStageMain.swift"
            ),
            encoding: .utf8
        )
        for required in [
            "testBundle.pathExtension",
            "== \"xctest\"",
            "== \"Contents\"",
            "== \"Resources\"",
            "PrimeMLXRuntimeEnvironmentPolicy",
            "PrimeArtifactRoot(",
            ".captureSibling(",
            ".typedOptimizerRestoreProbe",
            "existingBundleMismatch",
        ] {
            XCTAssertTrue(
                source.contains(required),
                "missing isolated-stage boundary \(required)"
            )
        }
        for forbidden in [
            "python",
            "/bin/sh",
            "/bin/zsh",
            "copyItem(",
            "moveItem(",
            "removeItem(",
            "\\(error)",
        ] {
            XCTAssertFalse(
                source.contains(forbidden),
                "forbidden isolated-stage route \(forbidden)"
            )
        }
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
