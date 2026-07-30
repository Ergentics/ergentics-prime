import Foundation
import XCTest

final class PrimeNativeResolvedContractAdapterSourceContractTests:
    XCTestCase
{
    private static let authorityPaths = [
        "Sources/PrimeCore/PrimeNativeResolvedContractModels.swift",
        "Sources/PrimeCore/PrimeNativeByteTokenizer.swift",
        "Sources/PrimeCore/PrimeNativeResolvedContractAdapter.swift",
        "Sources/PrimeCore/PrimeNativeResolvedContractArguments.swift",
        "Sources/PrimeCore/PrimeSecureRunningExecutableCapture.swift",
        "Sources/PrimeNativeResolvedContractAdapterProbe/PrimeNativeResolvedContractAdapterProbeMain.swift",
        "Sources/PrimeNativeResolvedContractAdapterVerifier/PrimeNativeResolvedContractAdapterVerifierMain.swift",
    ]

    func testAllPlannedAuthorityFilesExistAndUseNoExternalExecutor()
        throws
    {
        let sources = try Self.authorityPaths.map {
            try source($0)
        }
        let authority = sources.joined(separator: "\n")

        for forbiddenExecutor in [
            "Foundation.Process",
            "NSTask",
            "posix_spawn",
            "execve(",
            "execl(",
            "system(",
            "popen(",
            "dlopen(",
            "dlsym(",
            "Bundle(path:",
            "NSBundle",
            "PythonKit",
            "/usr/bin/python",
            "/bin/python",
            "\"python3\"",
            "/bin/sh",
            "/bin/zsh",
            "/bin/bash",
            "/usr/bin/env",
        ] {
            XCTAssertFalse(
                authority.contains(forbiddenExecutor),
                "adapter authority must not execute external code: \(forbiddenExecutor)"
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
            0,
            "adapter authority must not construct Foundation Process"
        )

        for forbiddenArchiveRoute in [
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
        ] {
            XCTAssertFalse(
                authority.contains(forbiddenArchiveRoute),
                "adapter authority must not inspect or expand the opaque archive: \(forbiddenArchiveRoute)"
            )
        }

        for forbiddenRuntimeDependency in [
            "import NeuralKit",
            "import PMHNP",
            "PMHNPCompanion",
            "NSClassFromString(\"NeuralKit",
            "NSClassFromString(\"PMHNP",
        ] {
            XCTAssertFalse(
                authority.contains(
                    forbiddenRuntimeDependency
                ),
                "adapter authority must not load companion runtime code: \(forbiddenRuntimeDependency)"
            )
        }
    }

    func testAuthorityUsesNoDirectCompanionWriteRoute()
        throws
    {
        let authority = try Self.authorityPaths.map {
            try source($0)
        }.joined(separator: "\n")

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
                "adapter authority must publish only through descriptor-backed Prime artifact APIs: \(forbiddenWrite)"
            )
        }
    }

    func testCLIExposesNoDonorExecutionOrEvaluationKnobs()
        throws
    {
        let arguments = try source(
            "Sources/PrimeCore/PrimeNativeResolvedContractArguments.swift"
        )
        let mains = try [
            "Sources/PrimeNativeResolvedContractAdapterProbe/PrimeNativeResolvedContractAdapterProbeMain.swift",
            "Sources/PrimeNativeResolvedContractAdapterVerifier/PrimeNativeResolvedContractAdapterVerifierMain.swift",
        ].map {
            try source($0)
        }.joined(separator: "\n")
        let cliAuthority = arguments + "\n" + mains

        for forbiddenArgument in [
            "--companion-root",
            "--archive",
            "--report",
            "--source",
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
        ] {
            XCTAssertFalse(
                cliAuthority.contains(forbiddenArgument),
                "adapter CLI must not expose an authority-expanding knob: \(forbiddenArgument)"
            )
        }
    }

    func testPromptOnlyRequestHasNoTargetOrRegradeMaterial()
        throws
    {
        let models = try source(
            "Sources/PrimeCore/PrimeNativeResolvedContractModels.swift"
        )
        let declarations = try promptOnlyStructBodies(
            in: models
        )
        XCTAssertFalse(
            declarations.isEmpty,
            "models must declare a prompt-only generation request type"
        )

        let propertyExpression = try NSRegularExpression(
            pattern:
                #"(?m)^\s*(?:public\s+)?let\s+([A-Za-z_][A-Za-z0-9_]*)\s*:"#
        )
        let forbiddenFieldFragments = [
            "target",
            "completion",
            "expected",
            "evaluationrow",
            "corpusrow",
            "mutation",
            "abstention",
            "semantic",
            "verifier",
            "answer",
            "label",
        ]

        for declaration in declarations {
            let propertyRegion: String
            if let initializer = declaration.range(
                of: "init("
            ) ?? declaration.range(of: "init (") {
                propertyRegion = String(
                    declaration[..<initializer.lowerBound]
                )
            } else {
                propertyRegion = declaration
            }
            let range = NSRange(
                propertyRegion.startIndex...,
                in: propertyRegion
            )
            let fields = propertyExpression.matches(
                in: propertyRegion,
                range: range
            ).compactMap { match -> String? in
                guard let fieldRange = Range(
                    match.range(at: 1),
                    in: propertyRegion
                ) else {
                    return nil
                }
                return String(propertyRegion[fieldRange])
            }
            XCTAssertFalse(
                fields.isEmpty,
                "prompt-only request must expose explicit immutable fields"
            )
            for field in fields {
                let normalized = field.lowercased()
                XCTAssertFalse(
                    forbiddenFieldFragments.contains {
                        normalized.contains($0)
                    },
                    "prompt-only request leaks target or regrade material through field \(field)"
                )
            }
        }
    }

    func testPackageAddsNoDependencyAndAdapterExecutablesUseOnlyPrimeCore()
        throws
    {
        let package = withoutWhitespace(
            try source("Package.swift")
        )

        XCTAssertEqual(
            occurrences(of: ".package(", in: package),
            2,
            "adapter work must not add a package dependency"
        )
        for existingDependency in [
            #"url:"https://github.com/Ergentics/ergentics-mlx-swift""#,
            #"url:"https://github.com/ml-explore/mlx-swift-lm""#,
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
        ] {
            XCTAssertFalse(
                package.contains(forbiddenDependency),
                "adapter must not add a companion runtime dependency: \(forbiddenDependency)"
            )
        }

        for executable in [
            "PrimeNativeResolvedContractAdapterProbe",
            "PrimeNativeResolvedContractAdapterVerifier",
        ] {
            XCTAssertTrue(
                package.contains(
                    #".executable(name:"\#(executable)",targets:["\#(executable)",])"#
                ),
                "missing adapter executable product: \(executable)"
            )
            XCTAssertTrue(
                package.contains(
                    #".executableTarget(name:"\#(executable)",dependencies:["PrimeCore"])"#
                ),
                "adapter executable must depend only on PrimeCore: \(executable)"
            )
            XCTAssertEqual(
                occurrences(
                    of: #"name:"\#(executable)""#,
                    in: package
                ),
                2
            )
        }
    }

    func testProjectionRequiresBoundPublicationAndFreshValidationReplaysMutations()
        throws
    {
        let adapter = try source(
            "Sources/PrimeCore/PrimeNativeResolvedContractAdapter.swift"
        )
        XCTAssertTrue(
            adapter.contains(
                "fileprivate static func projection("
            ),
            "raw manifest data must not expose a public PASS-shaped projection API"
        )
        XCTAssertFalse(
            adapter.contains(
                "public static func projection("
            )
        )
        XCTAssertTrue(
            adapter.contains(
                "let replayedMutations ="
            )
        )
        XCTAssertTrue(
            adapter.contains(
                "guard replayedMutations == mutationSweep"
            ),
            "fresh receipt validation must rerun and compare the mutation sweep"
        )

        let tokenizer = try source(
            "Sources/PrimeCore/PrimeNativeByteTokenizer.swift"
        )
        XCTAssertTrue(
            tokenizer.contains(
                "canonicalize(text).data(using: .utf8)"
            ),
            "the Foundation challenger must use Foundation's UTF-8 encoder"
        )
        XCTAssertFalse(
            tokenizer.contains(
                "Data(canonicalize(text).utf8)"
            ),
            "the Foundation challenger must not reuse the primary String.UTF8View"
        )
    }

    private func promptOnlyStructBodies(
        in source: String
    ) throws -> [String] {
        let expression = try NSRegularExpression(
            pattern:
                #"(?m)(?:public\s+)?struct\s+[A-Za-z_][A-Za-z0-9_]*PromptOnly[A-Za-z0-9_]*\b"#
        )
        let matches = expression.matches(
            in: source,
            range: NSRange(source.startIndex..., in: source)
        )
        return try matches.map { match in
            let declaration = try XCTUnwrap(
                Range(match.range, in: source)
            )
            let open = try XCTUnwrap(
                source[
                    declaration.upperBound...
                ].firstIndex(of: "{"),
                "prompt-only request declaration is missing an opening brace"
            )
            var depth = 0
            var cursor = open
            while cursor < source.endIndex {
                switch source[cursor] {
                case "{":
                    depth += 1
                case "}":
                    depth -= 1
                    if depth == 0 {
                        return String(source[open ... cursor])
                    }
                default:
                    break
                }
                cursor = source.index(after: cursor)
            }
            XCTFail(
                "prompt-only request declaration is missing a closing brace"
            )
            return String(source[open...])
        }
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
                "missing planned adapter authority file: \(repositoryRelativePath)"
            )
            throw CocoaError(.fileNoSuchFile)
        }
        return try String(
            contentsOf: url,
            encoding: .utf8
        )
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
