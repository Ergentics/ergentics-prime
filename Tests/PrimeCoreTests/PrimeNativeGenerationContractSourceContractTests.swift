import Foundation
import XCTest

final class PrimeNativeGenerationContractSourceContractTests:
    XCTestCase
{
    private static let plannedAuthorityPaths = [
        "Sources/PrimeCore/PrimeNativeGenerationContractProjection.swift",
        "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift",
        "Sources/PrimeCore/PrimeNativeGenerationContractArguments.swift",
        "Sources/PrimeCore/PrimeDurableArtifacts.swift",
        "Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift",
        "Sources/PrimeCore/PrimeSwiftSourceProvenance.swift",
        "Sources/PrimeNativeGenerationContractProjectionProbe/PrimeNativeGenerationContractProjectionProbeMain.swift",
        "Sources/PrimeNativeGenerationContractProjectionVerifier/PrimeNativeGenerationContractProjectionVerifierMain.swift",
    ]

    private static let generationOwnedAuthorityPaths = [
        "Sources/PrimeCore/PrimeNativeGenerationContractProjection.swift",
        "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift",
        "Sources/PrimeCore/PrimeNativeGenerationContractArguments.swift",
        "Sources/PrimeNativeGenerationContractProjectionProbe/PrimeNativeGenerationContractProjectionProbeMain.swift",
        "Sources/PrimeNativeGenerationContractProjectionVerifier/PrimeNativeGenerationContractProjectionVerifierMain.swift",
    ]

    func testPlannedAuthorityExistsAndUsesNoExternalExecutionArchiveOrDonorRuntime()
        throws
    {
        let authority = try joinedSource(
            Self.plannedAuthorityPaths
        )

        for forbidden in [
            "Foundation.Process",
            "NSTask",
            "posix_spawn",
            "posix_spawnp",
            "execve(",
            "execl(",
            "execlp(",
            "system(",
            "popen(",
            "dlopen(",
            "dlsym(",
            "Bundle(path:",
            "NSBundle",
            "NSClassFromString",
            "PythonKit",
            "/usr/bin/python",
            "/bin/python",
            "\"python3\"",
            "/bin/sh",
            "/bin/zsh",
            "/bin/bash",
            "/usr/bin/env",
            "import Compression",
            "import AppleArchive",
            "ArchiveByteStream",
            "ArchiveStream",
            "COMPRESSION_LZMA",
            "compression_decode",
            "/usr/bin/tar",
            "/usr/bin/xz",
            "\"tar\"",
            "\"xz\"",
            ".tar.xz",
            "import NeuralKit",
            "import PMHNP",
            "PMHNPCompanion",
        ] {
            XCTAssertFalse(
                authority.contains(forbidden),
                "generation-contract authority admits a forbidden route: \(forbidden)"
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
            "generation-contract authority must not construct Foundation Process"
        )
    }

    func testGenerationLayerCannotBypassDescriptorPublicationOrRepairModes()
        throws
    {
        let authority = try joinedSource(
            Self.plannedAuthorityPaths
        )
        for forbiddenWrite in [
            "FileHandle(forWritingAtPath:",
            "FileHandle(forUpdatingAtPath:",
            "FileManager.default.createFile",
            "FileManager.default.createDirectory",
            "FileManager.default.copyItem",
            "FileManager.default.moveItem",
            "FileManager.default.removeItem",
            "FileManager.default.replaceItem",
            ".write(to:",
        ] {
            XCTAssertFalse(
                authority.contains(forbiddenWrite),
                "generation-contract authority must publish only through descriptor-backed Prime artifact APIs: \(forbiddenWrite)"
            )
        }

        // PrimeDurableArtifacts owns immutable descriptor publication and
        // therefore legitimately seals newly published descriptors. The new
        // generation layer itself must never chmod an existing input or
        // normalize a Git checkout behind the verifier's back.
        let generationLayer = try joinedSource(
            Self.generationOwnedAuthorityPaths
        )
        for forbiddenDirectWrite in [
            "FileHandle(forWritingTo:",
            "FileHandle(forUpdating:",
            "OutputStream(",
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
            "setxattr(",
            "removexattr(",
        ] {
            XCTAssertFalse(
                generationLayer.contains(
                    forbiddenDirectWrite
                ),
                "generation-contract layer bypasses descriptor-backed publication: \(forbiddenDirectWrite)"
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
        ] {
            XCTAssertFalse(
                generationLayer.contains(
                    forbiddenModeRepair
                ),
                "generation-contract authority must reject, not repair, checkout modes: \(forbiddenModeRepair)"
            )
        }
    }

    func testCLIExposesOnlyFrozenRootsAndNoAuthorityExpandingKnobs()
        throws
    {
        let cliAuthority = try joinedSource([
            "Sources/PrimeCore/PrimeNativeGenerationContractArguments.swift",
            "Sources/PrimeNativeGenerationContractProjectionProbe/PrimeNativeGenerationContractProjectionProbeMain.swift",
            "Sources/PrimeNativeGenerationContractProjectionVerifier/PrimeNativeGenerationContractProjectionVerifierMain.swift",
        ])

        for requiredArgument in [
            "--adapter-root",
            "--prime-root",
            "--artifact-root",
        ] {
            XCTAssertTrue(
                cliAuthority.contains(requiredArgument),
                "missing frozen generation-contract root: \(requiredArgument)"
            )
        }

        for forbiddenArgument in [
            "--companion-root",
            "--donor-root",
            "--archive",
            "--report",
            "--source",
            "--source-file",
            "--executable",
            "--binary",
            "--command",
            "--python",
            "--shell",
            "--model",
            "--checkpoint",
            "--tokenizer",
            "--corpus",
            "--generation-shard",
            "--seed",
            "--target",
            "--target-length",
            "--budget",
            "--generation-budget",
            "--schema",
            "--contract",
            "--profile",
            "--output-file",
        ] {
            XCTAssertFalse(
                cliAuthority.contains(forbiddenArgument),
                "generation-contract CLI exposes an authority-expanding knob: \(forbiddenArgument)"
            )
        }
    }

    func testNormalSummariesDiscloseSameSourceFreshVerifierRestriction()
        throws
    {
        let overlay = try source(
            "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift"
        )
        let probe = try source(
            "Sources/PrimeNativeGenerationContractProjectionProbe/PrimeNativeGenerationContractProjectionProbeMain.swift"
        )
        let verifier = try source(
            "Sources/PrimeNativeGenerationContractProjectionVerifier/PrimeNativeGenerationContractProjectionVerifierMain.swift"
        )

        for authority in [overlay, probe, verifier] {
            XCTAssertTrue(
                authority.contains(
                    "freshVerifierSameSourceIdentityRequired"
                ),
                "normal evidence path hides the same-source verifier restriction"
            )
        }
        XCTAssertTrue(
            verifier.contains(
                "sameSourceFreshProcessPersistenceValidated"
            )
        )
        XCTAssertFalse(
            verifier.contains(
                "let freshProcessPersistenceValidated"
            ),
            "verifier must not emit an unqualified persistence claim"
        )
    }

    func testPackageAddsNoDependencyAndExecutablesDependOnlyOnPrimeCore()
        throws
    {
        let package = withoutWhitespace(
            try source("Package.swift")
        )

        XCTAssertEqual(
            occurrences(of: ".package(", in: package),
            1,
            "generation projection must not add a package dependency"
        )
        for existingDependency in [
            #"url:"https://github.com/Ergentics/ergentics-mlx-swift""#,
        ] {
            XCTAssertTrue(
                package.contains(existingDependency),
                "existing dependency inventory drifted: \(existingDependency)"
            )
        }
        for forbiddenDependency in [
            ".package(path:",
            "pmhnp-companion",
            "PMHNPCompanion",
            "neural-kit",
            #"name:"NeuralKit""#,
            "mlx-swift-lm",
            "MLXLLM",
        ] {
            XCTAssertFalse(
                package.contains(forbiddenDependency),
                "generation projection added a donor runtime dependency: \(forbiddenDependency)"
            )
        }

        for executable in [
            "PrimeNativeGenerationContractProjectionProbe",
            "PrimeNativeGenerationContractProjectionVerifier",
        ] {
            XCTAssertTrue(
                try matches(
                    #"\.executable\(name:"\#(executable)",targets:\["\#(executable)",?\]\)"#,
                    in: package
                ),
                "missing generation-contract executable product: \(executable)"
            )
            XCTAssertTrue(
                try matches(
                    #"\.executableTarget\(name:"\#(executable)",dependencies:\["PrimeCore",?\]\)"#,
                    in: package
                ),
                "generation-contract executable must depend only on PrimeCore: \(executable)"
            )
            XCTAssertEqual(
                occurrences(
                    of: #"name:"\#(executable)""#,
                    in: package
                ),
                2,
                "generation-contract executable must have exactly one product and one target"
            )
        }
    }

    func testProjectionSourceSnapshotRequiresEveryAuthorityFile()
        throws
    {
        let projectionAuthority = try joinedSource([
            "Sources/PrimeCore/PrimeNativeGenerationContractProjection.swift",
            "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift",
        ])

        for requiredPath in Self.plannedAuthorityPaths {
            XCTAssertTrue(
                projectionAuthority.contains(
                    "\"\(requiredPath)\""
                ),
                "generation source snapshot omits required authority: \(requiredPath)"
            )
        }
    }

    func testProjectionKeepsSchema2RawWireAndSchema4RegradeFieldsDistinct()
        throws
    {
        let projectionAuthority = try joinedSource([
            "Sources/PrimeCore/PrimeNativeGenerationContractProjection.swift",
            "Sources/PrimeCore/PrimeNativeGenerationContractOverlay.swift",
        ])

        for requiredType in [
            "PrimeNativeGenerationRawShardFieldProjection",
            "PrimeNativeGenerationSchema4RegradeFieldProjection",
            "PrimeNativeHistoricalRawGenerationObservation",
        ] {
            XCTAssertTrue(
                projectionAuthority.contains(requiredType),
                "missing exact generation-contract surface: \(requiredType)"
            )
        }

        let schema2EnvelopeAndEntryFields = [
            "schema_version",
            "phase",
            "profile_id",
            "seed",
            "corpus_manifest_sha256",
            "generation_contract_id",
            "maximum_generation_token_decisions",
            "model_binding_sha256",
            "first_row_id",
            "last_row_id",
            "entries",
            "row_id",
            "generated",
        ]
        let schema2GeneratedCamelCaseFields = [
            "text",
            "tokenIDs",
            "tokenLogProbabilities",
            "meanLogProbability",
            "terminatedByEOS",
            "terminationReason",
            "utf8Valid",
            "eosLogProbability",
            "rawFullVocabularyAllowedSupportGreedyTokenParity",
            "disallowedFullVocabularyArgmaxCount",
            "maximumDisallowedTokenProbabilityMass",
            "latencySeconds",
        ]
        let schema4RawPredictionSnakeCaseFields = [
            "row_id",
            "corpus_row_sha256",
            "evaluation_row_sha256",
            "split",
            "semantic_family",
            "invariant_ids",
            "mutation_id",
            "abstention_reason",
            "prompt",
            "prompt_token_ids",
            "target",
            "target_token_ids",
            "prompt_grouping_key_id",
            "prompt_grouping_key",
            "generation_decision_budget",
            "allowed_completion_token_set_sha256",
            "eos_available_at_every_decision",
            "target_independent_decision_budget",
            "zero_shot_decisions_executed",
            "zero_shot_prediction",
            "zero_shot_prediction_token_ids",
            "zero_shot_mean_log_probability",
            "zero_shot_token_log_probabilities",
            "zero_shot_terminated_by_eos",
            "zero_shot_termination_reason",
            "zero_shot_utf8_valid",
            "zero_shot_eos_log_probability",
            "zero_shot_raw_full_vocabulary_allowed_support_greedy_token_parity",
            "zero_shot_disallowed_full_vocabulary_argmax_count",
            "zero_shot_maximum_disallowed_token_probability_mass",
            "zero_shot_exact_match",
            "zero_shot_semantic_verifier_pass",
            "zero_shot_abstention_decision",
            "zero_shot_latency_seconds",
            "trained_prediction",
            "trained_prediction_token_ids",
            "trained_mean_log_probability",
            "trained_token_log_probabilities",
            "trained_terminated_by_eos",
            "trained_termination_reason",
            "trained_utf8_valid",
            "trained_eos_log_probability",
            "trained_raw_full_vocabulary_allowed_support_greedy_token_parity",
            "trained_disallowed_full_vocabulary_argmax_count",
            "trained_maximum_disallowed_token_probability_mass",
            "trained_exact_match",
            "trained_semantic_verifier_pass",
            "trained_abstention_decision",
            "trained_latency_seconds",
            "trained_decisions_executed",
        ]

        for field in schema2EnvelopeAndEntryFields {
            assertQuotedField(
                field,
                existsIn: projectionAuthority,
                contract: "schema-2 shard envelope"
            )
        }
        for field in schema2GeneratedCamelCaseFields {
            assertQuotedField(
                field,
                existsIn: projectionAuthority,
                contract: "schema-2 raw Generated"
            )
        }
        for field in schema4RawPredictionSnakeCaseFields {
            assertQuotedField(
                field,
                existsIn: projectionAuthority,
                contract: "schema-4 RawPrediction"
            )
        }

        XCTAssertFalse(
            Set(schema2GeneratedCamelCaseFields)
                .isSubset(
                    of: Set(
                        schema4RawPredictionSnakeCaseFields
                    )
                ),
            "raw shard and post-generation regrade field vocabularies must remain distinct"
        )
        XCTAssertFalse(
            projectionAuthority.contains(
                "PrimeNativeGenerationObservation"
            ),
            "the generic 4,096-token transport must not masquerade as the exact fixed-cap64 wire contract"
        )
    }

    private func assertQuotedField(
        _ field: String,
        existsIn source: String,
        contract: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertTrue(
            source.contains("\"\(field)\""),
            "\(contract) projection omits exact field \(field)",
            file: file,
            line: line
        )
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
        let tests = URL(
            fileURLWithPath: #filePath
        ).deletingLastPathComponent()
        let root = tests
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root.appendingPathComponent(
            repositoryRelativePath
        )
        guard FileManager.default.fileExists(
            atPath: url.path
        ) else {
            XCTFail(
                "missing planned generation-contract authority file: \(repositoryRelativePath)"
            )
            throw CocoaError(.fileNoSuchFile)
        }
        return try String(
            contentsOf: url,
            encoding: .utf8
        )
    }

    private func matches(
        _ pattern: String,
        in source: String
    ) throws -> Bool {
        let expression = try NSRegularExpression(
            pattern: pattern
        )
        return expression.firstMatch(
            in: source,
            range: NSRange(
                source.startIndex...,
                in: source
            )
        ) != nil
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
}
