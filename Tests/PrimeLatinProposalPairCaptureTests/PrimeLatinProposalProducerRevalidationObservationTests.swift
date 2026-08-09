import CryptoKit
import Foundation
import XCTest
@testable import PrimeLatinProposalProducerRevalidationObservation

final class PrimeLatinProposalProducerRevalidationObservationTests:
    XCTestCase
{
    func testDecodesTheExactCanonicalChildAndTwoRunsMustBeIdentical()
        throws
    {
        let data = try canonicalChildData()
        let decoded = try PrimeLatinProposalProducerRevalidationCaptureV1
            .decodeChildObservationForTesting(data)
        XCTAssertEqual(
            decoded.schema,
            "ergentics_latin_proposal_v3_live_revalidation_observation_v1")
        XCTAssertEqual(decoded.outcome, "abstain")
        XCTAssertEqual(decoded.expectedPairReceiptSHA256, Self.pairSHA256)
        XCTAssertEqual(decoded.llmSource.commit, Self.producerCommit)
        XCTAssertEqual(decoded.llmSource.tree, Self.producerTree)
        XCTAssertEqual(decoded.inputBindings.count, 21)
        XCTAssertEqual(
            Set(decoded.inputBindings.map(\.role)).count,
            decoded.inputBindings.count)
        XCTAssertEqual(decoded.requestedTrialBudget.optimizerSteps, 1)
        XCTAssertEqual(decoded.requestedTrialBudget.trainingTokens, 128)
        XCTAssertEqual(decoded.requestedTrialBudget.wallClockSeconds, 60)
        XCTAssertEqual(
            decoded.requestedTrialBudget.application,
            "identical_per_candidate_requested_ceiling")

        let stdout = data + Data([0x0a])
        XCTAssertEqual(stdout.count, 8_434)
        XCTAssertEqual(
            Self.sha256(stdout),
            "0657289657fbb99ca91ad9b1788ccfbe9b1697881cef85df6241ab30b0bf984f")
        XCTAssertEqual(
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .validateRepeatedOutputsForTesting(stdout, stdout),
            decoded)
    }

    func testRejectsNoncanonicalDuplicateAndUnknownChildJSON()
        throws
    {
        let canonical = try canonicalChildData()
        var whitespace = canonical
        whitespace.insert(0x20, at: whitespace.startIndex)
        assertChildDecodeRejected(whitespace)

        let duplicate = Data("{\"schema\":\"duplicate\",".utf8)
            + canonical.dropFirst()
        assertChildDecodeRejected(duplicate)

        assertChildDecodeRejected(try canonicalChildData { value in
            value["unknown"] = true
        })
    }

    func testRejectsSemanticallyDeviatedChildCrossBindings() throws {
        let deviations = [
            try canonicalChildData { value in
                value["outcome"] = "pass"
            },
            try canonicalChildData { value in
                var source = value["llmSource"] as! [String: Any]
                source["commit"] = String(repeating: "0", count: 40)
                value["llmSource"] = source
            },
            try canonicalChildData { value in
                var authority = value["authority"] as! [String: Any]
                authority["independentPrimeReplayComplete"] = true
                value["authority"] = authority
            },
            try canonicalChildData { value in
                var budget = value["requestedTrialBudget"] as! [String: Any]
                budget["trainingTokens"] = 129
                value["requestedTrialBudget"] = budget
            },
            try canonicalChildData { value in
                var bindings = value["inputBindings"] as! [[String: Any]]
                bindings[0]["sha256"] = String(repeating: "0", count: 64)
                value["inputBindings"] = bindings
            },
        ]
        for deviation in deviations {
            let harness = try SyntheticHarness(stdout: deviation, owner: self)
            assertCaptureError(
                .invalidRevalidationObservation("child_cross_bindings")
            ) {
                try PrimeLatinProposalProducerRevalidationCaptureV1
                    .captureForTesting(
                        request: try syntheticRequest(),
                        dependencies: harness.dependencies(
                            decodeRepeatedOutputs: { first, second in
                                guard first == second,
                                      first.last == 0x0a else {
                                    throw PrimeLatinProposalProducerRevalidationError
                                        .invalidRevalidationObservation(
                                            "synthetic_process_output")
                                }
                                return try PrimeLatinProposalProducerRevalidationCaptureV1
                                    .decodeChildObservationForTesting(
                                        Data(first.dropLast()))
                            }))
            }
        }
    }

    func testRejectsChangedOrMalformedRepeatedProcessOutput() throws {
        let canonical = try canonicalChildData()
        let stdout = canonical + Data([0x0a])
        let changed = try canonicalChildData { value in
            value["candidateCatalogByteCount"] = 20_804
        } + Data([0x0a])
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .validateRepeatedOutputsForTesting(stdout, changed))
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .validateRepeatedOutputsForTesting(canonical, canonical))
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .validateRepeatedOutputsForTesting(
                    stdout + Data([0x0a]),
                    stdout + Data([0x0a])))
    }

    func testAuthorityCeilingIsExactAndNonAuthorizing() {
        let authority = PrimeLatinProposalProducerRevalidationCaptureV1
            .makeAuthorityForTesting()
        XCTAssertEqual(
            authority.disposition,
            "abstain_producer_revalidation_observation_complete_requires_independent_prime_replay")
        for value in [
            authority.pairCaptureAndRecaptureComplete,
            authority.inputSnapshotCaptureAndRecaptureComplete,
            authority.producerGitObservationComplete,
            authority.exactMergedRevalidatorSourceObserved,
            authority.exactRevalidatorSourceClosureObserved,
            authority.compilerIdentityObserved,
            authority.localExactSourceClosureBuildObserved,
            authority.revalidatorExecutableBuiltFromObservedSourceClosure,
            authority.revalidatorExecutableIdentityStable,
            authority.boundedFreshProcessObservationComplete,
            authority.canonicalRevalidationObservationDecoded,
            authority.expectedPairReceiptCrossBindingValidated,
            authority.exactTwentyOneInputBindingsCrossBound,
            authority.canonicalHashChainCrossBindingsMatched,
            authority.repeatedProducerProcessObservationUnchanged,
            authority.outputNamespaceAbsenceVerified,
            authority.llmGitStateIndependentlyObserved,
            authority.revalidatorToolSourceIndependentlyObserved,
            authority.liveProducerWorkspaceRevalidationComplete,
        ] {
            XCTAssertTrue(value)
        }
        for value in [
            authority.compilerCryptographicallyAuthenticated,
            authority.externalSourceToBinaryAttestationAvailable,
            authority.originRemoteCryptographicallyAuthenticated,
            authority.ignoredWorkspaceBytesObserved,
            authority.durableInputSnapshotPublished,
            authority.durableGitObservationPublished,
            authority.durableRevalidationObservationPublished,
            authority.independentPrimeReplayComplete,
            authority.runtimeDecoderImplementationAvailable,
            authority.runtimeDependencyClosureEstablished,
            authority.runtimeInitializationEstablished,
            authority.primeProposalPacketProduced,
            authority.primeTrialAuthorizationProduced,
            authority.primeDecisionReceiptProduced,
            authority.candidateSelectionAuthorized,
            authority.trialExecutionAuthorized,
            authority.furtherTrainingAuthorized,
            authority.promotionAuthorized,
            authority.productUseAuthorized,
            authority.publicationAuthorized,
            authority.proposalPairPublicationPerformedByThisObservation,
            authority.primeDurableReceiptPublished,
        ] {
            XCTAssertFalse(value)
        }
    }

    func testSyntheticCaptureCrossBindsTwoFreshRunsAndRecaptures()
        throws
    {
        let harness = try SyntheticHarness(stdout: canonicalChildData(), owner: self)
        let capture = try PrimeLatinProposalProducerRevalidationCaptureV1
            .captureForTesting(
                request: try syntheticRequest(),
                dependencies: harness.dependencies())

        XCTAssertEqual(
            capture.observation.schema,
            "ergentics_prime_latin_proposal_v3_producer_revalidation_observation_v1")
        XCTAssertEqual(capture.observation.outcome, "abstain")
        XCTAssertEqual(capture.observation.pairReceiptSHA256, Self.pairSHA256)
        XCTAssertEqual(capture.observation.producerCommit, Self.producerCommit)
        XCTAssertEqual(capture.observation.producerTree, Self.producerTree)
        XCTAssertEqual(
            capture.observation.toolSource.commit,
            "1ccfb6bf6718e2378f14ab87cacae1ada303cf48")
        XCTAssertEqual(capture.observation.inputBindingCount, 21)
        XCTAssertEqual(capture.observation.process.invocationCount, 2)
        XCTAssertEqual(
            capture.observation.build.compiler.role,
            "swift_compiler")
        XCTAssertTrue(
            capture.observation.build.compiler.absolutePath
                .hasSuffix("/usr/bin/swift-driver"))
        XCTAssertEqual(
            capture.observation.build.compilerIdentityScope,
            "fixed_developer_directory_exact_swift_driver_binary_observed_not_cryptographically_authenticated")
        XCTAssertEqual(capture.observation.process.standardOutputByteCount, 8_434)
        XCTAssertEqual(
            capture.observation.process.standardOutputSHA256,
            "0657289657fbb99ca91ad9b1788ccfbe9b1697881cef85df6241ab30b0bf984f")
        XCTAssertEqual(harness.runCount.value, 2)

        XCTAssertEqual(
            try capture.recaptureAndValidateUnchanged(),
            capture.observation)
        XCTAssertEqual(harness.runCount.value, 4)
        XCTAssertTrue(capture.observation.authority.liveProducerWorkspaceRevalidationComplete)
        XCTAssertFalse(capture.observation.authority.independentPrimeReplayComplete)
    }

    func testRejectsProducerToolProbeCompilerAndOutputMutation() throws {
        let producer = try SyntheticHarness(stdout: canonicalChildData(), owner: self)
        assertCaptureError(.captureChanged) {
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .captureForTesting(
                    request: try syntheticRequest(),
                    dependencies: producer.dependencies(
                        beforeFinalRecapture: {
                            producer.producer.value = self.syntheticProducerState(
                                commit: String(repeating: "0", count: 40))
                        }))
        }

        let tool = try SyntheticHarness(stdout: canonicalChildData(), owner: self)
        assertCaptureError(.captureChanged) {
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .captureForTesting(
                    request: try syntheticRequest(),
                    dependencies: tool.dependencies(
                        beforeFinalRecapture: {
                            tool.tool.value = self.syntheticToolState(
                                rootInode: tool.tool.value.rootInode + 1)
                        }))
        }

        let sourceClosure = try SyntheticHarness(
            stdout: canonicalChildData(), owner: self)
        assertCaptureError(.captureChanged) {
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .captureForTesting(
                    request: try syntheticRequest(),
                    dependencies: sourceClosure.dependencies(
                        beforeFinalRecapture: {
                            sourceClosure.tool.value = self.syntheticToolState(
                                sourceDataByRole: [
                                    "synthetic_probe": Data("changed".utf8),
                                ])
                        }))
        }

        let executable = try SyntheticHarness(
            stdout: canonicalChildData(), owner: self)
        assertCaptureError(.captureChanged) {
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .captureForTesting(
                    request: try syntheticRequest(),
                    dependencies: executable.dependencies(
                        beforeFinalRecapture: {
                            executable.executable.value = self.syntheticTool(
                                role: "producer_revalidation_probe_executable",
                                path: "/synthetic/probe",
                                sha256: String(repeating: "f", count: 64))
                        }))
        }

        let compiler = try SyntheticHarness(stdout: canonicalChildData(), owner: self)
        let changedCompiler = syntheticBuildObservation(
            compilerSHA256: String(repeating: "e", count: 64))
        assertCaptureError(.buildFailed("synthetic_build")) {
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .captureForTesting(
                    request: try syntheticRequest(),
                    dependencies: compiler.dependencies(
                        buildObservation: changedCompiler))
        }

        let output = try SyntheticHarness(stdout: canonicalChildData(), owner: self)
        assertCaptureError(
            .invalidRevalidationObservation("repeated_process_output")
        ) {
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .captureForTesting(
                    request: try syntheticRequest(),
                    dependencies: output.dependencies(
                        beforeSecondRun: {
                            var changed = output.process.value.standardOutput
                            changed[changed.startIndex] ^= 1
                            output.process.value = .init(
                                terminationStatus: 0,
                                standardOutput: changed)
                        }))
        }
    }

    func testRejectsTimeoutNonzeroOversizeAndStandardError() throws {
        let canonical = try canonicalChildData() + Data([0x0a])
        let cases: [(
            PrimeLatinProposalProducerRevalidationProcessResultV1,
            PrimeLatinProposalProducerRevalidationError
        )] = [
            (.init(
                terminationStatus: 0,
                timedOut: true,
                standardOutput: canonical),
             .processTimedOut("first_probe")),
            (.init(
                terminationStatus: 23,
                standardOutput: canonical),
             .processFailed("first_probe")),
            (.init(
                terminationStatus: 0,
                standardOutput: Data(repeating: 0x61, count: 65_538)),
             .processOutputTooLarge("first_probe")),
            (.init(
                terminationStatus: 0,
                standardOutput: canonical,
                standardError: Data("unexpected".utf8)),
             .processFailed("first_probe_stderr")),
        ]
        for fixture in cases {
            let harness = try SyntheticHarness(
                stdout: canonicalChildData(), owner: self)
            harness.process.value = fixture.0
            assertCaptureError(fixture.1) {
                try PrimeLatinProposalProducerRevalidationCaptureV1
                    .captureForTesting(
                        request: try syntheticRequest(),
                        dependencies: harness.dependencies())
            }
        }
    }

    func testBeforeAndAfterRecaptureDriftBothFailClosed() throws {
        let before = try SyntheticHarness(stdout: canonicalChildData(), owner: self)
        assertCaptureError(.captureChanged) {
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .captureForTesting(
                    request: try syntheticRequest(),
                    dependencies: before.dependencies(
                        beforeSecondRun: {
                            before.producer.value = self.syntheticProducerState(
                                tree: String(repeating: "0", count: 40))
                        }))
        }

        let after = try SyntheticHarness(stdout: canonicalChildData(), owner: self)
        let capture = try PrimeLatinProposalProducerRevalidationCaptureV1
            .captureForTesting(
                request: try syntheticRequest(),
                dependencies: after.dependencies())
        after.tool.value = syntheticToolState(
            rootDeviceID: after.tool.value.rootDeviceID + 1)
        assertCaptureError(.captureChanged) {
            try capture.recaptureAndValidateUnchanged()
        }
    }

    func testRequestRejectsAliasedOverlappingAndNoncanonicalRoots() throws {
        let base = URL(fileURLWithPath: "/tmp/prime-latin-revalidation-tests")
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationRequestV1(
                labRoot: base.appendingPathComponent("same"),
                producerRepositoryRoot: base.appendingPathComponent("same"),
                toolRepositoryRoot: base.appendingPathComponent("tool"),
                scratchParent: base.appendingPathComponent("scratch")))
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationRequestV1(
                labRoot: base.appendingPathComponent("lab"),
                producerRepositoryRoot: base.appendingPathComponent("lab/repo"),
                toolRepositoryRoot: base.appendingPathComponent("tool"),
                scratchParent: base.appendingPathComponent("scratch")))
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationRequestV1(
                labRoot: URL(string: "https://example.invalid/lab")!,
                producerRepositoryRoot: base.appendingPathComponent("producer"),
                toolRepositoryRoot: base.appendingPathComponent("tool"),
                scratchParent: base.appendingPathComponent("scratch")))
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationRequestV1(
                labRoot: URL(fileURLWithPath: "/tmp/a/../lab"),
                producerRepositoryRoot: base.appendingPathComponent("producer"),
                toolRepositoryRoot: base.appendingPathComponent("tool"),
                scratchParent: base.appendingPathComponent("scratch")))
    }

    func testFileAdmissionRejectsRootAliasSymlinkHardlinkAndUnsafeMode()
        throws
    {
        let fixture = try FileAdmissionFixture()
        defer { fixture.cleanup() }

        XCTAssertNoThrow(
            try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .validateRootForTesting(fixture.root))
        XCTAssertNoThrow(
            try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .validateFileForTesting(
                    fixture.regularFile,
                    under: fixture.root))

        let rootAlias = fixture.container.appendingPathComponent("root-alias")
        try FileManager.default.createSymbolicLink(
            at: rootAlias,
            withDestinationURL: fixture.root)
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .validateRootForTesting(rootAlias))

        let fileAlias = fixture.root.appendingPathComponent("file-alias")
        try FileManager.default.createSymbolicLink(
            at: fileAlias,
            withDestinationURL: fixture.regularFile)
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .validateFileForTesting(fileAlias, under: fixture.root))

        let hardlink = fixture.root.appendingPathComponent("hardlink")
        try FileManager.default.linkItem(
            at: fixture.regularFile,
            to: hardlink)
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .validateFileForTesting(
                    fixture.regularFile,
                    under: fixture.root))
        try FileManager.default.removeItem(at: hardlink)

        try FileManager.default.setAttributes(
            [.posixPermissions: NSNumber(value: 0o666)],
            ofItemAtPath: fixture.regularFile.path)
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .validateFileForTesting(
                    fixture.regularFile,
                    under: fixture.root))
        try FileManager.default.setAttributes(
            [.posixPermissions: NSNumber(value: 0o600)],
            ofItemAtPath: fixture.regularFile.path)

        try FileManager.default.setAttributes(
            [.posixPermissions: NSNumber(value: 0o777)],
            ofItemAtPath: fixture.root.path)
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .validateRootForTesting(fixture.root))
    }

    private func syntheticRequest() throws
        -> PrimeLatinProposalProducerRevalidationRequestV1
    {
        let root = URL(fileURLWithPath: "/tmp/prime-latin-revalidation-synthetic")
        return try .init(
            labRoot: root.appendingPathComponent("lab"),
            producerRepositoryRoot: root.appendingPathComponent("producer"),
            toolRepositoryRoot: root.appendingPathComponent("tool"),
            scratchParent: root.appendingPathComponent("scratch"))
    }

    private func syntheticProducerState(
        commit: String = producerCommit,
        tree: String = producerTree
    ) -> PrimeLatinProposalProducerRevalidationProducerStateV1 {
        .init(
            pairReceiptSHA256: Self.pairSHA256,
            repository: "Ergentics/ergentics-llm",
            commit: commit,
            tree: tree,
            candidateCatalogSHA256:
                "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4",
            candidateCatalogByteCount: 20_803,
            experimentManifestSHA256:
                "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76",
            experimentManifestByteCount: 3_364,
            candidateDeclarationSetSHA256:
                "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881",
            candidateDeclarationSetByteCount: 14_860,
            tokenizerBundleSHA256:
                "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c",
            tokenizerBundleByteCount: 2_930,
            candidateIDs: ["latin_structural_fixture_v1"],
            candidateIdentitySHA256s: [
                "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265",
            ],
            declarationBundleSHA256s: [
                "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd",
            ],
            outputNamespace:
                "models/latin-prospective/structural-fixture-v3-776c412e",
            artifacts: [],
            pairAuthorityExact: true,
            snapshotAuthorityExact: true,
            gitAuthorityExact: true,
            gitHeadCommit: commit,
            gitHeadTree: tree,
            gitStatusByteCount: 0,
            gitStatusSHA256:
                "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    }

    private func syntheticToolState(
        rootDeviceID: UInt64 = 10,
        rootInode: UInt64 = 20,
        sourceDataByRole: [String: Data] = [
            "synthetic_probe": Data("probe".utf8),
        ]
    ) -> PrimeLatinProposalProducerRevalidationToolStateV1 {
        .init(
            source: .init(
                repository: "Ergentics/ergentics-llm",
                locallyDeclaredOriginURL:
                    "https://github.com/Ergentics/ergentics-llm.git",
                originObservationScope:
                    "locally_declared_origin_only_not_network_authenticated",
                commit: "1ccfb6bf6718e2378f14ab87cacae1ada303cf48",
                tree: "6ee438bf1132d26767fbf447355b8165455b956f",
                parentCommit: Self.producerCommit,
                rawCommitSHA256: String(repeating: "a", count: 64),
                rawCommitByteCount: 1,
                trackedIndexEntryCount: 1,
                trackedIndexInventorySHA256:
                    String(repeating: "b", count: 64),
                trackedIndexInventoryByteCount: 1,
                artifacts: []),
            sourceDataByRole: sourceDataByRole,
            rootDeviceID: rootDeviceID,
            rootInode: rootInode,
            rootOwnerUserID: 501,
            rootActualMode: 0o700)
    }

    private func syntheticTool(
        role: String,
        path: String,
        sha256: String = String(repeating: "c", count: 64)
    ) -> PrimeLatinProposalProducerRevalidationToolObservationV1 {
        .init(
            role: role,
            file: .init(
                absolutePath: path,
                sha256: sha256,
                byteCount: 10,
                deviceID: 30,
                inode: 40,
                ownerUserID: 501,
                actualMode: 0o700))
    }

    private func syntheticBuildObservation(
        compilerSHA256: String = String(repeating: "d", count: 64)
    ) -> PrimeLatinProposalProducerRevalidationBuildObservationV1 {
        .init(
            buildPolicyID: "synthetic_direct_swiftc",
            compilerLauncher: syntheticTool(
                role: "compiler_launcher",
                path: "/usr/bin/xcrun"),
            compiler: syntheticTool(
                role: "swift_compiler",
                path:
                    "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver",
                sha256: compilerSHA256),
            compilerIdentityScope:
                "fixed_developer_directory_exact_swift_driver_binary_observed_not_cryptographically_authenticated",
            compileCommandCount: 3,
            processLaunchCount: 5,
            governanceArtifactCount: 4,
            compilerInputSourceCount: 3,
            executable: syntheticTool(
                role: "producer_revalidation_probe_executable",
                path: "/synthetic/probe"))
    }

    private func assertCaptureError<T>(
        _ expected: PrimeLatinProposalProducerRevalidationError,
        _ body: () throws -> T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try body(), file: file, line: line) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalProducerRevalidationError,
                expected,
                file: file,
                line: line)
        }
    }

    private final class StateBox<Value>: @unchecked Sendable {
        var value: Value

        init(_ value: Value) {
            self.value = value
        }
    }

    private final class FileAdmissionFixture {
        let container: URL
        let root: URL
        let regularFile: URL

        init() throws {
            let parent = URL(fileURLWithPath: "/private/tmp", isDirectory: true)
            container = parent.appendingPathComponent(
                "prime-latin-file-admission-\(UUID().uuidString)",
                isDirectory: true)
            root = container.appendingPathComponent("root", isDirectory: true)
            regularFile = root.appendingPathComponent("source.swift")
            try FileManager.default.createDirectory(
                at: root,
                withIntermediateDirectories: true)
            try FileManager.default.setAttributes(
                [.posixPermissions: NSNumber(value: 0o700)],
                ofItemAtPath: container.path)
            try FileManager.default.setAttributes(
                [.posixPermissions: NSNumber(value: 0o700)],
                ofItemAtPath: root.path)
            try Data("synthetic source\n".utf8).write(
                to: regularFile,
                options: .withoutOverwriting)
            try FileManager.default.setAttributes(
                [.posixPermissions: NSNumber(value: 0o600)],
                ofItemAtPath: regularFile.path)
        }

        func cleanup() {
            try? FileManager.default.removeItem(at: container)
        }
    }

    private final class SyntheticHarness: @unchecked Sendable {
        let producer: StateBox<
            PrimeLatinProposalProducerRevalidationProducerStateV1>
        let tool: StateBox<PrimeLatinProposalProducerRevalidationToolStateV1>
        let executable: StateBox<
            PrimeLatinProposalProducerRevalidationToolObservationV1>
        let process: StateBox<
            PrimeLatinProposalProducerRevalidationProcessResultV1>
        let runCount = StateBox(0)
        let expectedBuild:
            PrimeLatinProposalProducerRevalidationBuildObservationV1

        init(
            stdout: Data,
            owner: PrimeLatinProposalProducerRevalidationObservationTests
        ) throws {
            producer = StateBox(owner.syntheticProducerState())
            tool = StateBox(owner.syntheticToolState())
            let build = owner.syntheticBuildObservation()
            expectedBuild = build
            executable = StateBox(build.executable)
            process = StateBox(.init(
                terminationStatus: 0,
                standardOutput: stdout + Data([0x0a])))
        }

        func dependencies(
            buildObservation:
                PrimeLatinProposalProducerRevalidationBuildObservationV1? = nil,
            beforeSecondRun: @escaping @Sendable () throws -> Void = {},
            beforeFinalRecapture: @escaping @Sendable () throws -> Void = {},
            decodeRepeatedOutputs:
                (@Sendable (Data, Data) throws
                    -> PrimeLatinProposalProducerRevalidationChildObservationV1)?
                    = nil
        ) -> PrimeLatinProposalProducerRevalidationCaptureDependenciesV1 {
            let selectedBuild = buildObservation ?? expectedBuild
            let selectedDecoder = decodeRepeatedOutputs ?? { first, second in
                try PrimeLatinProposalProducerRevalidationCaptureV1
                    .validateRepeatedOutputsForTesting(first, second)
            }
            return .init(
                captureProducer: { _ in
                    PrimeLatinProposalProducerRevalidationProducerCaptureV1(
                        initial: self.producer.value,
                        recapture: { self.producer.value })
                },
                captureTool: { _ in
                    PrimeLatinProposalProducerRevalidationToolCaptureV1(
                        initial: self.tool.value,
                        recapture: { self.tool.value })
                },
                buildProbe: { _, _ in
                    PrimeLatinProposalProducerRevalidationBuildCaptureV1(
                        observation: selectedBuild,
                        executableURL: URL(
                            fileURLWithPath: selectedBuild.executable.absolutePath),
                        recaptureExecutable: { self.executable.value },
                        cleanup: {})
                },
                runProbe: { _, _ in
                    self.runCount.value += 1
                    return self.process.value
                },
                beforeSecondRun: beforeSecondRun,
                beforeFinalRecapture: beforeFinalRecapture,
                validateProducer: { _ in },
                validateTool: { _ in },
                validateBuild: { observed in
                    guard observed == self.expectedBuild else {
                        throw PrimeLatinProposalProducerRevalidationError
                            .buildFailed("synthetic_build")
                    }
                },
                decodeRepeatedOutputs: selectedDecoder)
        }
    }

    private func assertChildDecodeRejected(
        _ data: Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(
            try PrimeLatinProposalProducerRevalidationCaptureV1
                .decodeChildObservationForTesting(data),
            file: file,
            line: line)
    }

    private func canonicalChildData(
        mutate: (inout [String: Any]) -> Void = { _ in }
    ) throws -> Data {
        var value = exactChildObject()
        mutate(&value)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(try JSONValue(value))
    }

    private func exactChildObject() -> [String: Any] {
        [
            "schema":
                "ergentics_latin_proposal_v3_live_revalidation_observation_v1",
            "outcome": "abstain",
            "verificationScope":
                "exact_final_public_factory_reconstruction_and_live_workspace_revalidation_only_non_authorizing",
            "revalidationStatus":
                "exact_final_factory_reconstruction_and_repeated_live_revalidation_complete",
            "revalidatorToolSourceIdentityStatus":
                "not_observed_by_revalidator",
            "expectedPairReceiptSHA256": Self.pairSHA256,
            "pairReceiptObservationStatus":
                "expected_cross_binding_only_not_observed_or_published",
            "llmSource": [
                "repository": "Ergentics/ergentics-llm",
                "commit": Self.producerCommit,
                "tree": Self.producerTree,
            ],
            "candidateCatalogSHA256":
                "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4",
            "candidateCatalogByteCount": 20_803,
            "experimentManifestSHA256":
                "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76",
            "experimentManifestByteCount": 3_364,
            "candidateDeclarationSetSHA256":
                "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881",
            "candidateDeclarationSetByteCount": 14_860,
            "tokenizerBundleSHA256":
                "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c",
            "tokenizerBundleByteCount": 2_930,
            "candidateIDs": ["latin_structural_fixture_v1"],
            "candidateIdentitySHA256s": [
                "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265",
            ],
            "declarationBundleSHA256s": [
                "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd",
            ],
            "inputBindings": exactInputBindings(),
            "requestedTrialBudget": [
                "application":
                    "identical_per_candidate_requested_ceiling",
                "optimizerSteps": 1,
                "trainingTokens": 128,
                "wallClockSeconds": 60,
            ],
            "outputNamespace":
                "models/latin-prospective/structural-fixture-v3-776c412e",
            "catalogAuthorityStatus":
                "root_bound_declaration_proposal_input_v3_only_non_authorizing",
            "catalogPublicationStatus":
                "not_implemented_input_bridge_only",
            "experimentPublicationStatus":
                "not_implemented_input_bridge_only",
            "authority": exactChildAuthority(),
        ]
    }

    private func exactChildAuthority() -> [String: Any] {
        var result: [String: Any] = [
            "disposition":
                "abstain_live_producer_revalidation_complete_requires_independent_prime_replay",
        ]
        for key in Self.childPositiveAuthorityKeys {
            result[key] = true
        }
        for key in Self.childNegativeAuthorityKeys {
            result[key] = false
        }
        return result
    }

    private func exactInputBindings() -> [[String: Any]] {
        Self.inputBindingFixtures.map { fixture in
            var result: [String: Any] = [
                "role": fixture.role,
                "scope": fixture.scope,
                "relativePath": fixture.relativePath,
                "sha256": fixture.sha256,
                "byteCount": fixture.byteCount,
            ]
            if let gitBlobOID = fixture.gitBlobOID {
                result["gitBlobOID"] = gitBlobOID
            }
            return result
        }
    }

    private static let pairSHA256 =
        "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7"
    private static let producerCommit =
        "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831"
    private static let producerTree =
        "c1f41758aea2860ab06039776f5ea0403dff1b61"

    private static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private static let childPositiveAuthorityKeys = [
        "exactFinalRequestValidated",
        "exactProducerWorkspaceSourceObserved",
        "exactTwentyOneInputBindingsReconstructed",
        "publicTokenizerFactoryReconstructionComplete",
        "publicCandidateDeclarationFactoryReconstructionComplete",
        "publicCandidateCatalogFactoryReconstructionComplete",
        "publicExperimentManifestFactoryReconstructionComplete",
        "canonicalHashChainRecomputationComplete",
        "liveProducerWorkspaceRevalidationComplete",
        "repeatedLiveRevalidationUnchanged",
        "outputNamespaceAbsenceVerified",
        "expectedPairReceiptCrossBindingValidated",
    ]

    private static let childNegativeAuthorityKeys = [
        "revalidatorToolSourceIndependentlyObserved",
        "referencedInputSnapshotPublished",
        "referencedArtifactBytesPublished",
        "independentPrimeReplayComplete",
        "runtimeDecoderImplementationAvailable",
        "runtimeDependencyClosureEstablished",
        "runtimeInitializationEstablished",
        "primeProposalPacketProduced",
        "primeTrialAuthorizationProduced",
        "primeDecisionReceiptProduced",
        "candidateSelectionAuthorized",
        "trialExecutionAuthorized",
        "furtherTrainingAuthorized",
        "promotionAuthorized",
        "productUseAuthorized",
        "publicationAuthorized",
        "proposalPairPublicationPerformed",
        "durableRevalidationObservationPublished",
        "primeDurableReceiptPublished",
    ]

    private struct InputBindingFixture {
        let role: String
        let scope: String
        let relativePath: String
        let sha256: String
        let byteCount: Int
        let gitBlobOID: String?
    }

    private enum JSONValue: Encodable {
        case object([String: JSONValue])
        case array([JSONValue])
        case string(String)
        case integer(Int)
        case boolean(Bool)
        case null

        init(_ value: Any) throws {
            if let value = value as? [String: Any] {
                self = .object(try value.mapValues(Self.init))
            } else if let value = value as? [Any] {
                self = .array(try value.map(Self.init))
            } else if let value = value as? String {
                self = .string(value)
            } else if let value = value as? Bool {
                self = .boolean(value)
            } else if let value = value as? Int {
                self = .integer(value)
            } else if value is NSNull {
                self = .null
            } else {
                throw JSONValueError.unsupportedValue
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .object(let value):
                try container.encode(value)
            case .array(let value):
                try container.encode(value)
            case .string(let value):
                try container.encode(value)
            case .integer(let value):
                try container.encode(value)
            case .boolean(let value):
                try container.encode(value)
            case .null:
                try container.encodeNil()
            }
        }
    }

    private enum JSONValueError: Error {
        case unsupportedValue
    }

    private static let inputBindingFixtures: [InputBindingFixture] = [
        .init(
            role: "root_package_manifest",
            scope: "ergentics_llm_repository",
            relativePath: "Package.swift",
            sha256:
                "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902",
            byteCount: 6_109,
            gitBlobOID: nil),
        .init(
            role: "root_dependency_lock",
            scope: "ergentics_llm_repository",
            relativePath: "Package.resolved",
            sha256:
                "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530",
            byteCount: 645,
            gitBlobOID: "4e822bfadbe5f4dced15a277f4d5423a03d76890"),
        .init(
            role: "declaration_package_manifest",
            scope: "ergentics_llm_repository",
            relativePath:
                "Research/Latin/CandidateDeclarations/Package.swift",
            sha256:
                "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63",
            byteCount: 892,
            gitBlobOID: "67907b47cf941c6e36154dd729b284f64c90ca9b"),
        .init(
            role: "declaration_production_source",
            scope: "ergentics_llm_repository",
            relativePath:
                "Research/Latin/CandidateDeclarations/Sources/ErgenticsLatinCandidateDeclarations/ErgenticsLatinCandidateDeclarations.swift",
            sha256:
                "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4",
            byteCount: 35_119,
            gitBlobOID: "a951d3710dba072aa7eb8554c60abafdd032cb7f"),
        .init(
            role: "candidate_architecture",
            scope: "ergentics_llm_repository",
            relativePath:
                "Research/Latin/candidates/latin_structural_fixture_v1/architecture.json",
            sha256:
                "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70",
            byteCount: 2_794,
            gitBlobOID: "a3a9582003bfdbce2c94707313c0e402955bca9b"),
        .init(
            role: "candidate_parameter_count_derivation",
            scope: "ergentics_llm_repository",
            relativePath:
                "Research/Latin/candidates/latin_structural_fixture_v1/parameter-count-derivation.json",
            sha256:
                "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f",
            byteCount: 2_702,
            gitBlobOID: "9957d0b17edd019ce760fdae9907a8ebadf408e3"),
        .init(
            role: "evaluation_contract",
            scope: "ergentics_llm_repository",
            relativePath: "Research/Latin/evaluation_contract.json",
            sha256:
                "4a0dd1bc973f7ce380df9775413c4e43033ba0cc409fb45a9368c2bef6835d52",
            byteCount: 164,
            gitBlobOID: nil),
        .init(
            role: "tokenizer_manifest",
            scope: "ergentics_mlx_lab",
            relativePath: "tokenizer/ergentics_latin_bpe_v2/manifest.json",
            sha256:
                "b1ae203307de9c657f9d2558875e104d33f62e464c2cb83504d2f2f714ac6b76",
            byteCount: 2_180,
            gitBlobOID: nil),
        .init(
            role: "tokenizer_sentencepiece_model",
            scope: "ergentics_mlx_lab",
            relativePath: "tokenizer/ergentics_latin_bpe_v2/model.spm",
            sha256:
                "3819dbc5381bfd5f52cc8b28e6f1e224ea5e30bdaaaf94dc5307fde91c9cccb5",
            byteCount: 285_705,
            gitBlobOID: nil),
        .init(
            role: "tokenizer_vocabulary",
            scope: "ergentics_mlx_lab",
            relativePath: "tokenizer/ergentics_latin_bpe_v2/vocab.txt",
            sha256:
                "fb7f86c49cca2b9115f55ff559ac76e8977110e1251a3a21baa9e7dc9132c3ce",
            byteCount: 256_196,
            gitBlobOID: nil),
        .init(
            role: "tokenizer_recommendation",
            scope: "ergentics_mlx_lab",
            relativePath:
                "tokenizer/ergentics_latin_bpe_v2/recommendation.json",
            sha256:
                "ce4c3be2e999057a102465593e2c87c4cd7424a7f633427c97c0790c20f34596",
            byteCount: 1_836,
            gitBlobOID: nil),
        .init(
            role: "tokenizer_approval",
            scope: "ergentics_mlx_lab",
            relativePath: "tokenizer/ergentics_latin_bpe_v2/approval.json",
            sha256:
                "34162b2625ba160f0cc3d38c8ec7ef2c8930b0b4376a19bfd9b0fff8c96d936b",
            byteCount: 277,
            gitBlobOID: nil),
        .init(
            role: "tokenizer_staged_training_input",
            scope: "ergentics_mlx_lab",
            relativePath:
                "tokenizer/ergentics_latin_bpe_v2/staging/train-input.txt",
            sha256:
                "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
            byteCount: 3_743_426,
            gitBlobOID: nil),
        .init(
            role: "tokenizer_corpus_manifest",
            scope: "ergentics_mlx_lab",
            relativePath: "corpus/la/L1/primary-corpus-manifest.json",
            sha256:
                "87a4dcdfbbd8a9ad3f297b320bc94012e98835f395d79b6e6d99e6ce410c36b4",
            byteCount: 1_715,
            gitBlobOID: nil),
        .init(
            role: "tokenizer_admitted_corpus_input",
            scope: "ergentics_mlx_lab",
            relativePath: "corpus/la/L1/train.txt",
            sha256:
                "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
            byteCount: 3_743_426,
            gitBlobOID: nil),
        .init(
            role: "initialization_contract",
            scope: "ergentics_mlx_lab",
            relativePath:
                "evidence/latin-proposal-inputs/v3/776c412e/initialization-contract.json",
            sha256:
                "b5a959d839d41c2956a3f3d74515d4e7d0c403a23c35aaa201f18d0f4a3b2446",
            byteCount: 281,
            gitBlobOID: nil),
        .init(
            role: "prospective_corpus_manifest",
            scope: "ergentics_mlx_lab",
            relativePath:
                "corpus/la/L1/prospective-v3-776c412e/corpus-manifest.json",
            sha256:
                "ac3fed959b9f5736124de80fba5b09206afda730099cc2f8706849687cfa7313",
            byteCount: 772,
            gitBlobOID: nil),
        .init(
            role: "training_split",
            scope: "ergentics_mlx_lab",
            relativePath:
                "corpus/la/L1/prospective-v3-776c412e/training.txt",
            sha256:
                "57ce94783f3f93b18de0420b60f1900c15647b57868916c74bf3c94f3c35b695",
            byteCount: 61,
            gitBlobOID: nil),
        .init(
            role: "validation_split",
            scope: "ergentics_mlx_lab",
            relativePath:
                "corpus/la/L1/prospective-v3-776c412e/validation.txt",
            sha256:
                "845a5ec82d415a7c00decc6933ae448aecfe5c7ac2fe8d369d5c066df25de78b",
            byteCount: 51,
            gitBlobOID: nil),
        .init(
            role: "selection_split",
            scope: "ergentics_mlx_lab",
            relativePath:
                "corpus/la/L1/prospective-v3-776c412e/selection.txt",
            sha256:
                "d69252b64c20d2fd7f4a219e85d7dfe0b93a0e8bf8aded46b4fc70834e2d74a3",
            byteCount: 50,
            gitBlobOID: nil),
        .init(
            role: "selection_observation_declaration",
            scope: "ergentics_mlx_lab",
            relativePath:
                "corpus/la/L1/prospective-v3-776c412e/selection-observation.json",
            sha256:
                "440965ad0976163f2e0d3c08868ee01a4a04b94fe808d85db5c9558965ab855f",
            byteCount: 311,
            gitBlobOID: nil),
    ]
}
