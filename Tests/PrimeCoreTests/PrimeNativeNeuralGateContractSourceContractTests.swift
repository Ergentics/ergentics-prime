import Foundation
import XCTest
@testable import PrimeNativeNeuralGateContract

final class PrimeNativeNeuralGateContractSourceContractTests:
    XCTestCase
{
    private static let ownedPaths = [
        "Sources/PrimeCore/PrimeNativeNeuralGateContractArguments.swift",
        "Sources/PrimeCore/PrimeNativeNeuralGateContractProjection.swift",
        "Sources/PrimeNativeNeuralGateContract/PrimeNativeNeuralGateContractOverlay.swift",
        "Sources/PrimeNativeNeuralGateContractProjectionProbe/PrimeNativeNeuralGateContractProjectionProbeMain.swift",
        "Sources/PrimeNativeNeuralGateContractProjectionVerifier/PrimeNativeNeuralGateContractProjectionVerifierMain.swift",
    ]

    func testAdapterAddsNoPackageOrPMHNPRuntimeDependency()
        throws
    {
        let package = withoutWhitespace(
            try source("Package.swift")
        )
        XCTAssertEqual(
            occurrences(of: ".package(", in: package),
            1
        )
        for forbidden in [
            ".package(path:",
            "mlx-swift-lm",
            "MLXLLM",
            "pmhnp-companion",
            "PMHNPCompanion",
            #"name:"NeuralKit""#,
            #"package:"neural-kit""#,
        ] {
            XCTAssertFalse(
                package.contains(forbidden),
                "adapter added a forbidden runtime dependency: \(forbidden)"
            )
        }
        XCTAssertTrue(
            package.contains(
                #".target(name:"PrimeNativeNeuralGateContract",dependencies:["PrimeCore","PrimeNativeCorpusReplay",])"#
            )
        )
        for executable in [
            "PrimeNativeNeuralGateContractProjectionProbe",
            "PrimeNativeNeuralGateContractProjectionVerifier",
        ] {
            XCTAssertTrue(
                package.contains(
                    #".executableTarget(name:"\#(executable)",dependencies:["PrimeCore","PrimeNativeNeuralGateContract",])"#
                )
            )
        }
    }

    func testOwnedAdapterUsesSwiftAndNoExternalScientificExecutor()
        throws
    {
        let authority = try joinedSource(
            Self.ownedPaths
        )
        for forbidden in [
            "import PythonKit",
            "import NeuralKit",
            "import PMHNP",
            "import PMHNPCompanion",
            "import MLX",
            "import MLXNN",
            "import MLXOptimizers",
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
                authority.contains(forbidden),
                "adapter admits forbidden authority: \(forbidden)"
            )
        }
        let processConstructor =
            try NSRegularExpression(
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
            0
        )
    }

    func testOwnedAdapterPublishesOnlyThroughPrimeArtifactRoot()
        throws
    {
        let authority = try joinedSource(
            Self.ownedPaths
        )
        for forbidden in [
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
            "chmod(",
            "fchmod(",
        ] {
            XCTAssertFalse(
                authority.contains(forbidden),
                "adapter bypasses descriptor-backed publication: \(forbidden)"
            )
        }
    }

    func testCLIHasOnlyFrozenRootsAndNoScientificKnobs()
        throws
    {
        let authority = try joinedSource([
            "Sources/PrimeCore/PrimeNativeNeuralGateContractArguments.swift",
            "Sources/PrimeNativeNeuralGateContractProjectionProbe/PrimeNativeNeuralGateContractProjectionProbeMain.swift",
            "Sources/PrimeNativeNeuralGateContractProjectionVerifier/PrimeNativeNeuralGateContractProjectionVerifierMain.swift",
        ])
        let expression = try NSRegularExpression(
            pattern: #"--[a-z][a-z0-9-]*"#
        )
        let arguments = Set(
            expression.matches(
                in: authority,
                range: NSRange(
                    authority.startIndex...,
                    in: authority
                )
            ).compactMap {
                Range($0.range, in: authority).map {
                    String(authority[$0])
                }
            }
        )
        XCTAssertEqual(
            arguments,
            [
                "--generation-root",
                "--corpus-replay-root",
                "--prime-root",
                "--artifact-root",
            ]
        )
        for forbidden in [
            "--donor-root",
            "--companion-root",
            "--source-file",
            "--model",
            "--checkpoint",
            "--generation-shard",
            "--seed",
            "--threshold",
            "--profile",
            "--schema",
            "--mutation",
            "--output-file",
            "--python",
            "--shell",
        ] {
            XCTAssertFalse(
                authority.contains(forbidden)
            )
        }
    }

    func testSourceSnapshotClosesEveryOwnedAuthorityFile()
        throws
    {
        XCTAssertTrue(
            Set(Self.ownedPaths).isSubset(
                of:
                PrimeNativeNeuralGateContractPlan
                .requiredPrimeSourcePaths
            )
        )
        for path in
            PrimeNativeNeuralGateContractPlan
            .requiredPrimeSourcePaths
        {
            XCTAssertTrue(
                FileManager.default.fileExists(
                    atPath: path
                ),
                "required source path is absent: \(path)"
            )
        }
    }

    func testNormalOutputsExposeTheHistoricalTruthGap()
        throws
    {
        let authority = try joinedSource(
            Self.ownedPaths
        )
        for required in [
            "historicalSemanticMutationsExecuted",
            "historicalSZFingerprintRecomputed",
            "agentContractKitFourTierAuditPerformed",
            "phaseThreeCompatibilityComplete",
            "source_pinned_synthetic_fixture_materialization_and_gate_replay",
        ] {
            XCTAssertTrue(
                authority.contains(required),
                "normal evidence omits limitation: \(required)"
            )
        }
    }

    func testTerminalReceiptUsesExclusiveCanonicalPublication()
        throws
    {
        let overlay = try source(
            "Sources/PrimeNativeNeuralGateContract/PrimeNativeNeuralGateContractOverlay.swift"
        )
        XCTAssertTrue(
            overlay.contains(
                "try root.publishCanonicalExclusively("
            )
        )
        XCTAssertFalse(
            overlay.contains(
                """
                // Receipt publication is deliberately last.
                let receiptBinding =
                    try root.publishCanonical(
                """
            )
        )
    }

    func testHistoricalParentAuthorityUsesClosedPinsAndExactTuples()
        throws
    {
        let provenance = try source(
            "Sources/PrimeCore/PrimeSwiftSourceProvenance.swift"
        )
        let generation = try source(
            "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift"
        )
        let corpus = try source(
            "Sources/PrimeNativeCorpusReplay/PrimeNativeCorpusReplayOverlay.swift"
        )
        let adapter = try source(
            "Sources/PrimeNativeNeuralGateContract/PrimeNativeNeuralGateContractOverlay.swift"
        )

        XCTAssertTrue(
            provenance.contains(
                "public enum PrimePinnedHistoricalReleaseSource"
            )
        )
        XCTAssertFalse(
            provenance.contains(
                "expectedSourceIdentitySHA256"
            )
        )
        XCTAssertFalse(
            generation.contains(
                "expectedPrimeSourceIdentitySHA256"
            )
        )
        XCTAssertFalse(
            corpus.contains(
                "expectedPrimeSourceIdentitySHA256"
            )
        )
        for required in [
            "validateCanonicalHistorical20260730",
            "28906ef704f4d8727ea0da5e068f6ecbe52330ab",
            "c2d07ff9f4a011f7dddf8eb91dcd7278d873b18c",
            "f3b51e4a01f4af2725fff1e1256db7d1378e0d412b6f22d26840ef5f97ff15c7",
            "guard persisted == self",
        ] {
            XCTAssertTrue(generation.contains(required))
        }
        for required in [
            "validateCanonicalHistorical20260730",
            "e17d031af4ec48b644a326646da7bcb8ce24388d",
            "3f061674b652cca9cbc2429dc44c85a3aa803665",
            "a9319a41b436075523c4ace314233f69370af1917725e1caea91ed36409a292f",
            "0811b735c3162269907ce44db5321733dc01fc85454f45a8ebb19e0520b02d37",
            "guard persisted == receipt",
        ] {
            XCTAssertTrue(corpus.contains(required))
        }
        XCTAssertEqual(
            occurrences(
                of:
                    ".validateCanonicalHistorical20260730(",
                in: adapter
            ),
            4
        )
    }

    private func source(
        _ relativePath: String
    ) throws -> String {
        try String(
            contentsOfFile: relativePath,
            encoding: .utf8
        )
    }

    private func joinedSource(
        _ paths: [String]
    ) throws -> String {
        try paths.map(source).joined(
            separator: "\n"
        )
    }

    private func withoutWhitespace(
        _ value: String
    ) -> String {
        value.filter { !$0.isWhitespace }
    }

    private func occurrences(
        of needle: String,
        in haystack: String
    ) -> Int {
        guard !needle.isEmpty else { return 0 }
        var count = 0
        var start = haystack.startIndex
        while let range = haystack.range(
            of: needle,
            range: start ..< haystack.endIndex
        ) {
            count += 1
            start = range.upperBound
        }
        return count
    }
}
