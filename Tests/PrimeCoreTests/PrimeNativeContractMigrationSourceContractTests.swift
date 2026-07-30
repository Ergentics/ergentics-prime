import Foundation
import XCTest

final class PrimeNativeContractMigrationSourceContractTests:
    XCTestCase
{
    func testGitTransportDirectlyExecutesOnlyPinnedReadOnlyPlumbing()
        throws
    {
        let transport = try source(
            "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift"
        )
        let resolver = try source(
            "Sources/PrimeCore/PrimeNativeContractMigrationResolver.swift"
        )
        let compactTransport = withoutWhitespace(transport)

        XCTAssertTrue(
            compactTransport.contains(
                #"publicstaticletgitExecutableURL=URL(fileURLWithPath:"/usr/bin/git")"#
            )
        )
        XCTAssertEqual(
            occurrences(
                of: "let process = Process()",
                in: transport
            ),
            1
        )
        XCTAssertTrue(
            transport.contains("finishCaptures(")
        )
        XCTAssertFalse(
            transport.contains("captureGroup.wait()")
        )

        let run = try slice(
            transport,
            from: "private func run(",
            until: "\n    private static func parseTreeEntries("
        )
        try assertOrdered(
            [
                "let process = Process()",
                "process.executableURL = Self.gitExecutableURL",
                "\"--no-replace-objects\"",
                "\"-c\"",
                "\"core.fsmonitor=false\"",
                "\"-C\"",
                "repositoryRoot.path",
                "process.arguments = actualArguments",
                "process.environment = [",
                "process.currentDirectoryURL =",
                "URL(fileURLWithPath: \"/\")",
                "FileHandle(forReadingAtPath: \"/dev/null\")",
                "process.standardInput = standardInput",
                "process.standardOutput = stdoutPipe",
                "process.standardError = stderrPipe",
                "try process.run()",
            ],
            in: run
        )

        let environment = try slice(
            String(run),
            from: "process.environment = [",
            until: "\n        process.currentDirectoryURL"
        )
        XCTAssertEqual(
            withoutWhitespace(String(environment)),
            #"process.environment=["GIT_NO_REPLACE_OBJECTS":"1","GIT_OPTIONAL_LOCKS":"0","GIT_CONFIG_NOSYSTEM":"1","GIT_CONFIG_GLOBAL":"/dev/null","GIT_CONFIG_SYSTEM":"/dev/null","GIT_TERMINAL_PROMPT":"0","GIT_PAGER":"cat","GIT_FLUSH":"1","LC_ALL":"C","LANG":"C","TMPDIR":"/private/tmp",]"#
        )
        for forbiddenInheritance in [
            "ProcessInfo.processInfo.environment",
            "environment[",
            "setenv(",
        ] {
            XCTAssertFalse(
                run.contains(forbiddenInheritance),
                "forbidden inherited environment route: \(forbiddenInheritance)"
            )
        }

        for exactCommand in [
            #"arguments:["--version"]"#,
            #"arguments:["remote","get-url","origin",]"#,
            #"arguments:["rev-parse","--show-object-format",]"#,
            #"arguments:["rev-parse","\(plan.companionRevision)^{commit}",]"#,
            #"arguments:["rev-parse","\(plan.companionRevision)^{tree}",]"#,
            #"arguments:["cat-file","-p",plan.companionRevision,]"#,
            #"arguments:["ls-tree","-z","--full-tree",plan.companionRevision,"--",]+plan.artifacts.map(\.repositoryRelativePath)"#,
            #"arguments:["cat-file","blob",entry.objectID,]"#,
            #"arguments:["rev-parse","HEAD^{commit}",]"#,
            #"arguments:["status","--porcelain=v1","--untracked-files=all",]"#,
        ] {
            XCTAssertTrue(
                compactTransport.contains(exactCommand),
                "missing exact Git plumbing command: \(exactCommand)"
            )
        }

        for forbiddenCommand in [
            "\"show\"",
            "\"archive\"",
            "\"fetch\"",
            "\"checkout\"",
            "\"pull\"",
            "\"push\"",
        ] {
            XCTAssertFalse(
                transport.contains(forbiddenCommand),
                "forbidden Git transport command: \(forbiddenCommand)"
            )
            XCTAssertFalse(
                resolver.contains(forbiddenCommand),
                "exact argv allowlist must not admit \(forbiddenCommand)"
            )
        }

        let cli = try source(
            "Sources/PrimeNativeContractResolutionProbe/PrimeNativeContractResolutionProbeMain.swift"
        )
        let verifier = try source(
            "Sources/PrimeNativeContractResolutionVerifier/PrimeNativeContractResolutionVerifierMain.swift"
        )
        let authoritySources =
            transport + resolver + cli + verifier
        for forbiddenExecutor in [
            "PythonKit",
            "/usr/bin/python",
            "/bin/python",
            "/bin/sh",
            "/bin/zsh",
            "/bin/bash",
            "executableURL = URL(fileURLWithPath: \"/usr/bin/env\")",
        ] {
            XCTAssertFalse(
                authoritySources.contains(forbiddenExecutor),
                "forbidden non-Swift executor: \(forbiddenExecutor)"
            )
        }
        XCTAssertEqual(
            occurrences(
                of: "let process = Process()",
                in: authoritySources
            ),
            1
        )
    }

    func testCompanionIsReadOnlyAndPublicationTargetsArtifactRoot()
        throws
    {
        let transport = try source(
            "Sources/PrimeCore/PrimeNativeGitBlobTransport.swift"
        )
        let resolver = try source(
            "Sources/PrimeCore/PrimeNativeContractMigrationResolver.swift"
        )
        let plan = try source(
            "Sources/PrimeCore/PrimeNativeContractMigration.swift"
        )
        let cli = try source(
            "Sources/PrimeNativeContractResolutionProbe/PrimeNativeContractResolutionProbeMain.swift"
        )

        for forbiddenWrite in [
            "FileHandle(forWriting",
            ".write(to:",
            "FileManager.default.createFile",
            "FileManager.default.copyItem",
            "FileManager.default.moveItem",
            "FileManager.default.removeItem",
            "root.publish(",
            "root.publishCanonical(",
        ] {
            XCTAssertFalse(
                transport.contains(forbiddenWrite),
                "Git transport must not write: \(forbiddenWrite)"
            )
        }
        XCTAssertFalse(resolver.contains("companionRoot"))
        XCTAssertFalse(
            cli.contains(
                "PrimeArtifactRoot(\n                directoryURL: arguments.companionRoot"
            )
        )
        try assertOrdered(
            [
                "PrimeArtifactRoot(",
                "directoryURL: arguments.artifactRoot",
                "try artifactRoot.requirePrivateRootMode()",
                "try artifactRoot.requireEmpty()",
                "transport.sourceState(",
                "repositoryRoot: arguments.primeRoot",
                "phase: .preSnapshot",
                "transport.resolve(",
                "arguments.companionRoot",
                "PrimeNativeContractMigrationResolver",
                ".publish(",
                "to: artifactRoot",
            ],
            in: cli[...]
        )
        try assertOrdered(
            [
                "try PrimeSwiftSourceProvenance.validate(",
                "try runningExecutableData()",
                "phase: .postExecutable",
                "resolver source changed during capture",
                "try root.requirePrivateRootMode()",
                "try root.requireEmpty()",
                "try root.ensurePrivateDirectory(",
                "root.publishCanonical(",
            ],
            in: resolver[...]
        )
        for executableBinding in [
            "_NSGetExecutablePath",
            "PrimeNative3BLoadedExecutableVnode",
            ".observeCurrentProcess()",
            "O_RDONLY | O_NOFOLLOW | O_CLOEXEC",
            "try loaded.requireMatches(",
            "before.st_mtimespec.tv_sec",
            "before.st_ctimespec.tv_sec",
            "256 * 1024 * 1024",
        ] {
            XCTAssertTrue(
                resolver.contains(executableBinding),
                "running executable must bind loaded vnode: \(executableBinding)"
            )
        }
        XCTAssertFalse(
            cli.contains("Bundle.main.executableURL")
        )

        for requiredBoundary in [
            "companionReadOnly: true",
            "companionRuntimeDependencyAuthorized: false",
            "compatibilityReplayComplete: false",
            "adapterImplementationAuthorized: false",
            "archiveExpansionAuthorized: false",
            "companionExecutionAuthorized: false",
            "neuralKitExecutionAuthorized: false",
            "modelExecutionAuthorized: false",
            "functionalTrainingAuthorized: false",
            "quantizationAuthorized: false",
            "productUseAuthorized: false",
            "pythonExecutionAuthorized: false",
            "shellExecutionAuthorized: false",
            "historicalShellCaptureImportedAsAuthority: false",
        ] {
            XCTAssertTrue(
                plan.contains(requiredBoundary),
                "missing frozen authority boundary: \(requiredBoundary)"
            )
        }
        for requiredReceiptRejection in [
            "!companionWritePerformed",
            "!companionRuntimeDependencyAdded",
            "!donorExecutionPerformed",
            "!neuralKitExecutionPerformed",
            "!modelTrainingPerformed",
            "!productPromotionAuthorized",
        ] {
            XCTAssertTrue(
                plan.contains(requiredReceiptRejection),
                "receipt must reject authority expansion: \(requiredReceiptRejection)"
            )
        }
    }

    func testReceiptRevalidatesExactCommandArgvAndSourceBindings()
        throws
    {
        let contract = try source(
            "Sources/PrimeCore/PrimeNativeContractMigration.swift"
        )
        let resolver = try source(
            "Sources/PrimeCore/PrimeNativeContractMigrationResolver.swift"
        )
        let receiptStart = try XCTUnwrap(
            contract.range(
                of:
                    "public struct PrimeNativeContractMigrationReceipt:"
            )?.lowerBound
        )
        let receiptValidation = try slice(
            String(contract[receiptStart...]),
            from: "public func validate() throws {",
            until: "\n    public func validate("
        )
        let compactReceiptValidation =
            withoutWhitespace(String(receiptValidation))

        for required in [
            #"resolverSourceSnapshot.relativePath=="prime-swift-source-snapshot.v1.json""#,
            #"resolverExecutable.relativePath==PrimeNativeContractMigrationResolver.resolverExecutablePath"#,
            #"tryPrimeNativeContractMigrationResolver.validateCommandObservations(commandObservations,plan:plan)"#,
            #"tryPrimeNativeContractMigrationResolver.validateCommandOutputBindings(commandObservations,gitTool:gitTool,repository:repository,plan:plan)"#,
            #"tryPrimeNativeContractMigrationResolver.validateResolverSourceCommandObservations(resolverSourceCommandObservations,remoteURL:resolverSourceRemoteURL,revision:resolverSourceRevision,treeOID:resolverSourceTreeOID,clean:resolverSourceTreeClean)"#,
        ] {
            XCTAssertTrue(
                compactReceiptValidation.contains(required),
                "decoded receipt must revalidate \(required)"
            )
        }

        let commandValidation = try slice(
            resolver,
            from: "func validateCommandObservations(",
            until: "\n    private static func throwsError("
        )
        let compactCommandValidation =
            withoutWhitespace(String(commandValidation))
        for required in [
            #"zip(observations,expected).allSatisfy"#,
            #"observation.operation==expectation.operation"#,
            #"observation.argv==expectation.argv"#,
            #"letprefix=["--no-replace-objects","-c","core.fsmonitor=false","-C","<repository-root>",]"#,
            #""git_version""#,
            #""remote_identity""#,
            #""object_format""#,
            #""resolved_revision""#,
            #""resolved_tree""#,
            #""raw_commit""#,
            #""inventory_tree""#,
            #""post_resolved_revision""#,
            #""post_resolved_tree""#,
            #""cat-file""#,
            #""ls-tree""#,
            #"expectedInventoryTreeOutput(plan:plan)"#,
            #"equalsLine:gitTool.version"#,
            #".preSnapshot"#,
            #".postExecutable"#,
        ] {
            XCTAssertTrue(
                compactCommandValidation.contains(required),
                "command receipt must bind exact operation/argv: \(required)"
            )
        }
        for forbiddenWeakValidation in [
            "let forbidden = Set(",
            "isReadOnlyGitArgv(",
        ] {
            XCTAssertFalse(
                commandValidation.contains(
                    forbiddenWeakValidation
                ),
                "blacklist cannot replace exact argv validation: \(forbiddenWeakValidation)"
            )
        }
    }

    func testPackageWiresDedicatedResolverCLIOnlyToPrimeCore()
        throws
    {
        let package = withoutWhitespace(
            try source("Package.swift")
        )
        XCTAssertTrue(
            package.contains(
                #".executable(name:"PrimeNativeContractResolutionProbe",targets:["PrimeNativeContractResolutionProbe",])"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".executableTarget(name:"PrimeNativeContractResolutionProbe",dependencies:["PrimeCore"])"#
            )
        )
        XCTAssertEqual(
            occurrences(
                of: #"name:"PrimeNativeContractResolutionProbe""#,
                in: package
            ),
            2
        )
        XCTAssertTrue(
            package.contains(
                #".executable(name:"PrimeNativeContractResolutionVerifier",targets:["PrimeNativeContractResolutionVerifier",])"#
            )
        )
        XCTAssertTrue(
            package.contains(
                #".executableTarget(name:"PrimeNativeContractResolutionVerifier",dependencies:["PrimeCore"])"#
            )
        )
        XCTAssertEqual(
            occurrences(
                of: #"name:"PrimeNativeContractResolutionVerifier""#,
                in: package
            ),
            2
        )
    }

    func testCLIAcceptsOnlyFixedRootsAndFrozenResolutionScope()
        throws
    {
        let cli = try source(
            "Sources/PrimeNativeContractResolutionProbe/PrimeNativeContractResolutionProbeMain.swift"
        )
        let arguments = try source(
            "Sources/PrimeCore/PrimeNativeContractResolutionArguments.swift"
        )
        let plan = try source(
            "Sources/PrimeCore/PrimeNativeContractMigration.swift"
        )
        let verifier = try source(
            "Sources/PrimeNativeContractResolutionVerifier/PrimeNativeContractResolutionVerifierMain.swift"
        )

        XCTAssertTrue(
            arguments.contains(
                "required arguments: --companion-root <absolute canonical path> --prime-root <absolute canonical path> --artifact-root <absolute canonical path>"
            )
        )
        XCTAssertEqual(
            occurrences(
                of: "case \"--",
                in: arguments
            ),
            3
        )
        for fixedArgument in [
            "case \"--companion-root\":",
            "case \"--prime-root\":",
            "case \"--artifact-root\":",
            "guard value.hasPrefix(\"/\")",
            "value != \"/\"",
            "root.standardizedFileURL.path == value",
            "root.resolvingSymlinksInPath()",
            "disjoint(companionRoot, primeRoot)",
            "disjoint(companionRoot, artifactRoot)",
            "primeRoot != artifactRoot",
            "primeRoot.path + \"/artifacts/\"",
            "!left.hasPrefix(right + \"/\")",
            "!right.hasPrefix(left + \"/\")",
        ] {
            XCTAssertTrue(
                arguments.contains(fixedArgument),
                "missing fixed CLI contract: \(fixedArgument)"
            )
        }
        for fixedMainContract in [
            "PrimeNativeContractResolutionArguments",
            ".parse(CommandLine.arguments)",
            "PrimeNativeContractMigrationPlan.frozenV1",
            "try plan.validate()",
            "phase: .preSnapshot",
            "PrimeSwiftSourceProvenance.capture(",
            ".requiredResolverSourcePaths",
            "resolverSourceRoot:",
            "resolverSourcePreState:",
            "resolverSourceSnapshot:",
            "guard sourceState.clean",
            "\"resolver source tree is not clean\"",
        ] {
            XCTAssertTrue(
                cli.contains(fixedMainContract),
                "missing fixed CLI execution contract: \(fixedMainContract)"
            )
        }
        for forbiddenArgument in [
            "case \"--revision\":",
            "case \"--tree\":",
            "case \"--remote\":",
            "case \"--artifact\":",
            "case \"--scope\":",
            "case \"--execute\":",
            "case \"--model\":",
            "case \"--seed\":",
            "case \"--python\":",
            "case \"--shell\":",
        ] {
            XCTAssertFalse(
                arguments.contains(forbiddenArgument),
                "CLI must not expose scientific or donor-selection knob: \(forbiddenArgument)"
            )
        }

        for frozenScope in [
            "\"ergentics_prime_frozen_companion_blob_resolver_v1\"",
            "scope: \"frozen_companion_blob_resolution_only\"",
            "expectedArtifactCount: 8",
            "scientificAuthorityLanguage: \"swift\"",
            "\"swift_process_direct_exec_usr_bin_git_read_only_plumbing_no_shell\"",
        ] {
            XCTAssertTrue(
                plan.contains(frozenScope),
                "missing frozen resolver scope: \(frozenScope)"
            )
        }
        XCTAssertTrue(
            cli.contains(
                "claimScope:\n                    result.receipt.claimScope"
            )
        )
        XCTAssertTrue(
            cli.contains(
                "(\"ABSTAIN: \\(message)\\n\").utf8"
            )
        )
        for verifierContract in [
            "PrimeNativeContractResolutionVerifierArguments",
            ".parse(CommandLine.arguments)",
            "try root.requirePrivateRootMode()",
            "root.bindExisting(",
            "PrimeNativeContractMigrationReceipt.self",
            "try receipt.validate(in: root)",
            "guard rebound == receiptBinding",
            "freshProcessPersistenceValidated: true",
            "independentScientificOracleClaimed: false",
        ] {
            XCTAssertTrue(
                verifier.contains(verifierContract),
                "missing verifier contract: \(verifierContract)"
            )
        }
        XCTAssertFalse(verifier.contains("Process()"))
        XCTAssertFalse(verifier.contains("/usr/bin/git"))
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
        return try String(
            contentsOf:
                root.appendingPathComponent(
                    repositoryRelativePath
                ),
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
