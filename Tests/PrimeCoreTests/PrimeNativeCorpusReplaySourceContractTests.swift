import Foundation
import XCTest
@testable import PrimeNativeCorpusReplay

final class PrimeNativeCorpusReplaySourceContractTests:
    XCTestCase
{
    private static let transplantedDonorPaths:
        Set<String> = [
            "Sources/PrimeNativeCorpusReplayMechanics/PrimeNativeByteTokenizer.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/ErgenticsPrimeNativeTextCorpus.swift",
        ]

    private static let expectedSourceSnapshotPaths:
        Set<String> = [
            "Package.swift",
            "Sources/PrimeCore/PrimeDurableArtifacts.swift",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift",
            "Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift",
            "Sources/PrimeCore/PrimeSwiftSourceProvenance.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/PrimeNativeByteTokenizer.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/ErgenticsPrimeNativeTextCorpus.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/SeedBridge.swift",
            "Sources/PrimeNativeCorpusReplayMechanics/PrimeNativeCorpusReplayObservation.swift",
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayContract.swift",
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayArguments.swift",
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayOverlay.swift",
            "Sources/PrimeNativeCorpusReplayProbe/PrimeNativeCorpusReplayProbeMain.swift",
            "Sources/PrimeNativeCorpusReplayVerifier/PrimeNativeCorpusReplayVerifierMain.swift",
        ]

    func testPackageAddsNoDependencyAndReplayTargetsHaveExactDependencies()
        throws
    {
        let package = withoutWhitespace(
            try source("Package.swift")
        )

        XCTAssertEqual(
            occurrences(of: ".package(", in: package),
            2,
            "corpus replay must not add a package dependency"
        )
        for dependency in [
            #"url:"https://github.com/Ergentics/ergentics-mlx-swift""#,
            #"url:"https://github.com/ml-explore/mlx-swift-lm""#,
        ] {
            XCTAssertTrue(package.contains(dependency))
        }
        for forbidden in [
            ".package(path:",
            "pmhnp-companion",
            "PMHNPCompanion",
            "neural-kit",
            #"name:"NeuralKit""#,
        ] {
            XCTAssertFalse(
                package.contains(forbidden),
                "corpus replay added a donor runtime dependency: \(forbidden)"
            )
        }

        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeCorpusReplayMechanics")"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeCorpusReplay",dependencies:["PrimeCore","PrimeNativeCorpusReplayMechanics",])"#
            )
        )
        for executable in [
            "PrimeNativeCorpusReplayProbe",
            "PrimeNativeCorpusReplayVerifier",
        ] {
            XCTAssertTrue(
                package.contains(
                    #".executable(name:"\#(executable)",targets:["\#(executable)",])"#
                )
            )
            XCTAssertTrue(
                package.contains(
                    #".executableTarget(name:"\#(executable)",dependencies:["PrimeCore","PrimeNativeCorpusReplay","PrimeNativeCorpusReplayMechanics",])"#
                )
            )
            XCTAssertEqual(
                occurrences(
                    of: #"name:"\#(executable)""#,
                    in: package
                ),
                2
            )
        }
        XCTAssertTrue(
            package.contains(
                #".testTarget(name:"PrimeCoreTests",dependencies:["PrimeCore","PrimeNativeCorpusReplay","PrimeNativeCorpusReplayMechanics","PrimeNativeNeuralGateContract","PrimeNativeNeuralGateReplayMechanics","PrimeNativeNeuralGateCorrectedMechanics","PrimeNativeNeuralGateCorrectedFixtureAuthority","PrimeNativeNeuralGatePromptSolver","PrimeNativeNeuralGateLogitSidecarMechanics",])"#
            )
        )
    }

    func testEveryNewReplaySourceUsesOnlySwiftNativeAuthority()
        throws
    {
        let authority = try joinedSource(
            replaySourcePaths
        )

        for forbiddenImport in [
            "import PythonKit",
            "import MLX",
            "import MLXNN",
            "import MLXOptimizers",
            "import MLXLLM",
            "import NeuralKit",
            "import PMHNP",
            "import PMHNPCompanion",
        ] {
            XCTAssertFalse(
                authority.contains(forbiddenImport),
                "replay authority imports a forbidden runtime: \(forbiddenImport)"
            )
        }
        for forbiddenExecution in [
            "NSTask",
            "posix_spawn",
            "posix_spawnp",
            "execve(",
            "execl(",
            "execlp(",
            "system(",
            "popen(",
            "/usr/bin/python",
            "/bin/python",
            "\"python3\"",
            "/bin/sh",
            "/bin/zsh",
            "/bin/bash",
            "/usr/bin/env",
        ] {
            XCTAssertFalse(
                authority.contains(forbiddenExecution),
                "replay authority admits external execution: \(forbiddenExecution)"
            )
        }
        let processConstructor = try NSRegularExpression(
            pattern:
                #"\b(?:Foundation\.)?Process\s*\("#
        )
        XCTAssertEqual(
            processConstructor.numberOfMatches(
                in: authority,
                range: NSRange(
                    authority.startIndex...,
                    in: authority
                )
            ),
            0,
            "replay authority must not construct an external Process"
        )
    }

    func testReplayOwnedLayerUsesOnlyPrimeDurablePublication()
        throws
    {
        let ownedPaths = try replaySourcePaths.filter {
            !Self.transplantedDonorPaths.contains($0)
        }
        let authority = try joinedSource(ownedPaths)

        for forbiddenWrite in [
            "FileHandle(forWritingAtPath:",
            "FileHandle(forUpdatingAtPath:",
            "FileHandle(forWritingTo:",
            "FileHandle(forUpdating:",
            "FileManager.default.createFile",
            "FileManager.default.createDirectory",
            "FileManager.default.copyItem",
            "FileManager.default.moveItem",
            "FileManager.default.removeItem",
            "FileManager.default.replaceItem",
            "OutputStream(",
            ".write(to:",
            "O_WRONLY",
            "O_RDWR",
            "O_CREAT",
            "O_TRUNC",
            "rename(",
            "renameat(",
            "unlink(",
            "unlinkat(",
            "mkdir(",
            "mkdirat(",
        ] {
            XCTAssertFalse(
                authority.contains(forbiddenWrite),
                "replay-owned authority bypasses Prime durable publication: \(forbiddenWrite)"
            )
        }
        for forbiddenModeRepair in [
            "chmod(",
            "fchmod(",
            "chmodat(",
            "fchmodat(",
            "NSFilePosixPermissions",
            "FileAttributeKey.posixPermissions",
            ".posixPermissions",
            "setAttributes(",
            "setxattr(",
            "removexattr(",
        ] {
            XCTAssertFalse(
                authority.contains(forbiddenModeRepair),
                "replay authority must reject, not repair, modes: \(forbiddenModeRepair)"
            )
        }

        // The two byte-exact donor blobs retain historical convenience
        // writers. Prime may call their pure manifest/verify surfaces, but
        // artifact publication must remain descriptor-bound in PrimeCore.
        XCTAssertFalse(
            authority.contains(".writeManifest("),
            "Prime replay must not invoke transplanted direct manifest writers"
        )
    }

    func testCLIExposesExactlyTwoRootArgumentsAndNoScientificKnobs()
        throws
    {
        let cliPaths = try replaySourcePaths.filter {
            $0.hasSuffix(
                "PrimeNativeCorpusReplayArguments.swift"
            )
                || $0.contains(
                    "PrimeNativeCorpusReplayProbe/"
                )
                || $0.contains(
                    "PrimeNativeCorpusReplayVerifier/"
                )
        }
        let authority = try joinedSource(cliPaths)
        let expression = try NSRegularExpression(
            pattern: #"--[a-z][a-z0-9-]*"#
        )
        let range = NSRange(
            authority.startIndex...,
            in: authority
        )
        let arguments = Set(
            expression.matches(
                in: authority,
                range: range
            ).compactMap {
                Range($0.range, in: authority).map {
                    String(authority[$0])
                }
            }
        )
        XCTAssertEqual(
            arguments,
            [
                "--prime-root",
                "--artifact-root",
            ]
        )
    }

    func testCandidateSourceCannotRepresentReceiptOrPass()
        throws
    {
        let contract = try source(
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayContract.swift"
        )
        let candidate = try slice(
            contract,
            from:
                "public struct PrimeNativeCorpusReplayCandidate:",
            until:
                "\npublic enum PrimeNativeCorpusReplayOutcome:"
        )

        XCTAssertTrue(
            candidate.contains(
                "\"ergentics_prime_native_full_corpus_replay_candidate\""
            )
        )
        XCTAssertTrue(
            candidate.contains(
                "receiptPublished = false"
            )
        )
        XCTAssertTrue(
            candidate.contains(
                "probeProcessIdentifier"
            )
        )
        XCTAssertTrue(
            candidate.contains(
                "\"probe_process_identifier\""
            )
        )
        XCTAssertTrue(
            candidate.contains(
                "It is not a PASS receipt."
            )
        )
        XCTAssertFalse(candidate.contains("outcome"))
        XCTAssertFalse(candidate.contains("case pass"))
    }

    func testFreshProcessClaimIsIdentifierBoundAndNotUnconditional()
        throws
    {
        let contract = try source(
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayContract.swift"
        )
        let receipt = try slice(
            contract,
            from:
                "public struct PrimeNativeCorpusReplayReceipt:",
            until: "\n}"
        )
        let overlay = try source(
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayOverlay.swift"
        )

        XCTAssertTrue(
            receipt.contains(
                "probeProcessIdentifier > 0"
            )
        )
        XCTAssertTrue(
            receipt.contains(
                "verifierProcessIdentifier > 0"
            )
        )
        XCTAssertTrue(
            receipt.contains(
                "probeProcessIdentifier"
            )
        )
        XCTAssertTrue(
            receipt.contains(
                "!= verifierProcessIdentifier"
            )
        )
        XCTAssertFalse(
            receipt.contains(
                "freshProcessReplayExact = true"
            )
        )
        XCTAssertTrue(
            overlay.contains(
                "requireDistinctProcessIdentifiers"
            )
        )
        XCTAssertTrue(
            overlay.contains(
                "probe and verifier process identifiers must be positive and distinct"
            )
        )
    }

    func testRequiredSourceSnapshotSetIsExactAndCoversEveryReplaySource()
        throws
    {
        XCTAssertEqual(
            PrimeNativeCorpusReplayPlan
                .requiredPrimeSourcePaths,
            Self.expectedSourceSnapshotPaths
        )
        XCTAssertTrue(
            Set(try replaySourcePaths).isSubset(
                of: Self.expectedSourceSnapshotPaths
            ),
            "a replay authority source is absent from the frozen snapshot"
        )
        for path in Self.expectedSourceSnapshotPaths {
            XCTAssertTrue(
                FileManager.default.fileExists(
                    atPath: repositoryRoot
                        .appendingPathComponent(path).path
                ),
                "frozen source snapshot path does not exist: \(path)"
            )
        }
    }

    private var replaySourcePaths: [String] {
        get throws {
            let sources = repositoryRoot
                .appendingPathComponent("Sources")
            let manager = FileManager.default
            let enumerator = manager.enumerator(
                at: sources,
                includingPropertiesForKeys: [
                    .isRegularFileKey,
                ],
                options: [.skipsHiddenFiles]
            )
            var result: [String] = []
            while let url = enumerator?.nextObject()
                as? URL
            {
                let relative = url.path
                    .replacingOccurrences(
                        of: sources.path + "/",
                        with: "Sources/"
                    )
                guard relative.hasPrefix(
                    "Sources/PrimeNativeCorpusReplay"
                ),
                relative.hasSuffix(".swift")
                else {
                    continue
                }
                result.append(relative)
            }
            return result.sorted()
        }
    }

    private func joinedSource(
        _ repositoryRelativePaths: [String]
    ) throws -> String {
        try repositoryRelativePaths.map {
            try source($0)
        }.joined(separator: "\n")
    }

    private func source(
        _ repositoryRelativePath: String
    ) throws -> String {
        let url = repositoryRoot.appendingPathComponent(
            repositoryRelativePath
        )
        guard FileManager.default.fileExists(
            atPath: url.path
        ) else {
            XCTFail(
                "missing planned corpus replay authority file: \(repositoryRelativePath)"
            )
            throw CocoaError(.fileNoSuchFile)
        }
        return try String(
            contentsOf: url,
            encoding: .utf8
        )
    }

    private func slice(
        _ source: String,
        from start: String,
        until end: String
    ) throws -> Substring {
        let startRange = try XCTUnwrap(
            source.range(of: start)
        )
        let endRange = try XCTUnwrap(
            source.range(
                of: end,
                range:
                    startRange.upperBound
                        ..< source.endIndex
            )
        )
        return source[
            startRange.lowerBound ..< endRange.lowerBound
        ]
    }

    private func occurrences(
        of needle: String,
        in source: String
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

    private func withoutWhitespace(
        _ source: String
    ) -> String {
        String(
            source.filter {
                !$0.isWhitespace
            }
        )
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
