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
            2
        )
        for forbidden in [
            ".package(path:",
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
