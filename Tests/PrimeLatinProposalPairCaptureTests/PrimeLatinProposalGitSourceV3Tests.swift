import CryptoKit
import Foundation
import XCTest
@testable import PrimeLatinProposalPairCapture
@testable import PrimeLatinProposalGitObservation

final class PrimeLatinProposalGitSourceV3Tests: XCTestCase {
    func testObservesExactCleanGitSourceAndRemainsAbstaining() throws {
        let fixture = try GitSourceFixtureV3()
        let capture = try captureExpectingSuccess(fixture)
        let observation = capture.observation

        XCTAssertEqual(
            observation.schema,
            "ergentics_prime_latin_proposal_git_source_v3_observation")
        XCTAssertEqual(observation.outcome, "abstain")
        XCTAssertEqual(
            observation.verificationScope,
            "fixed_read_only_git_process_exact_head_tree_clean_status_and_" +
                "seven_snapshot_repository_bindings_only_non_authorizing")
        XCTAssertEqual(
            observation.pairReceiptSHA256,
            fixture.inputSnapshot.pairSHA256)
        XCTAssertEqual(
            observation.llmSource.repository,
            "Ergentics/ergentics-llm")
        XCTAssertEqual(
            observation.llmSource.commit,
            "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831")
        XCTAssertEqual(
            observation.llmSource.tree,
            "c1f41758aea2860ab06039776f5ea0403dff1b61")
        XCTAssertEqual(observation.snapshotArtifactCount, 21)

        let rootAttributes = try FileManager.default.attributesOfItem(
            atPath: fixture.inputSnapshot.llmRepositoryRoot.path)
        XCTAssertEqual(
            observation.repositoryRootDeviceID,
            try XCTUnwrap(
                rootAttributes[.systemNumber] as? NSNumber).uint64Value)
        XCTAssertEqual(
            observation.repositoryRootInode,
            try XCTUnwrap(
                rootAttributes[.systemFileNumber] as? NSNumber).uint64Value)
        XCTAssertEqual(
            observation.repositoryRootOwnerUserID,
            try XCTUnwrap(
                rootAttributes[.ownerAccountID] as? NSNumber).uint32Value)
        XCTAssertEqual(
            observation.repositoryRootActualMode,
            try XCTUnwrap(
                rootAttributes[.posixPermissions] as? NSNumber).uint16Value)

        XCTAssertEqual(observation.gitTool.absolutePath, "/usr/bin/git")
        assertLowercaseSHA256(observation.gitTool.sha256)
        XCTAssertGreaterThan(observation.gitTool.byteCount, 0)
        XCTAssertGreaterThan(observation.gitTool.deviceID, 0)
        XCTAssertGreaterThan(observation.gitTool.inode, 0)
        XCTAssertEqual(
            observation.gitTool.actualMode & 0o022,
            0,
            "The observed Git executable must not be group/world writable")
        XCTAssertTrue(observation.gitTool.version.hasPrefix("git version "))
        assertLowercaseSHA256(observation.gitTool.versionOutputSHA256)
        XCTAssertEqual(
            observation.gitTool.environmentPolicyID,
            "prime_latin_git_read_only_fixed_environment_v1")

        XCTAssertEqual(
            observation.locallyDeclaredOriginURL,
            GitSourceFixtureV3.expectedRemoteURL)
        XCTAssertEqual(
            observation.originObservationScope,
            "locally_declared_origin_only_not_network_authenticated")
        XCTAssertEqual(observation.objectFormat, "sha1")
        XCTAssertEqual(observation.headCommit, fixture.baseline.commit)
        XCTAssertEqual(observation.headTree, fixture.baseline.tree)
        XCTAssertEqual(observation.porcelainV2StatusByteCount, 0)
        XCTAssertEqual(
            observation.porcelainV2StatusSHA256,
            GitSourceFixtureV3.sha256(Data()))
        XCTAssertEqual(observation.rawCommitGitOID, fixture.baseline.commit)
        XCTAssertEqual(
            observation.recomputedRawCommitGitOID,
            fixture.baseline.commit)
        XCTAssertEqual(
            observation.rawCommitSHA256,
            fixture.baseline.rawCommitSHA256)
        XCTAssertEqual(
            observation.rawCommitByteCount,
            fixture.baseline.rawCommitByteCount)
        XCTAssertEqual(observation.repositoryArtifactCount, 7)
        XCTAssertEqual(observation.repositoryArtifacts.count, 7)
        let trackedIndexInventory = try fixture.git.data([
            "ls-files", "-v", "-z",
        ])
        XCTAssertEqual(observation.trackedIndexEntryCount, 7)
        XCTAssertEqual(
            observation.trackedIndexInventoryByteCount,
            UInt64(trackedIndexInventory.count))
        XCTAssertEqual(
            observation.trackedIndexInventorySHA256,
            GitSourceFixtureV3.sha256(trackedIndexInventory))
        XCTAssertEqual(trackedIndexInventory.last, 0)
        XCTAssertEqual(
            trackedIndexInventory.split(separator: 0).count,
            7)
        XCTAssertTrue(
            trackedIndexInventory.split(separator: 0).allSatisfy {
                $0.starts(with: Data("H ".utf8))
            })
        XCTAssertEqual(observation.gitCommandCount, 17)

        for (observed, expected) in zip(
            observation.repositoryArtifacts,
            fixture.baseline.artifacts)
        {
            XCTAssertEqual(observed.role, expected.role)
            XCTAssertEqual(observed.relativePath, expected.relativePath)
            XCTAssertEqual(observed.mode, "100644")
            XCTAssertEqual(observed.objectType, "blob")
            XCTAssertEqual(observed.gitBlobOID, expected.gitBlobOID)
            XCTAssertEqual(observed.recomputedGitBlobOID, expected.gitBlobOID)
            XCTAssertEqual(observed.snapshotSHA256, expected.sha256)
            XCTAssertEqual(observed.snapshotByteCount, expected.byteCount)
            XCTAssertEqual(observed.observedBlobSHA256, expected.sha256)
            XCTAssertEqual(observed.observedBlobByteCount, expected.byteCount)
        }

        assertAuthorityCeiling(observation.authority)
        XCTAssertEqual(
            try capture.recaptureAndValidateUnchanged(),
            observation)
    }

    func testRejectsModifiedStagedAndUntrackedWorkspaceState() throws {
        let modified = try GitSourceFixtureV3()
        try modified.replaceRepositoryArtifact(
            role: "root_package_manifest",
            with: Data("dirty root package manifest fixture\n".utf8))
        assertGitError(.invalidObservation("working_tree_status")) {
            try modified.capture(
                snapshotCapture: modified.makeInputSnapshot(
                    matchingCurrentRepositoryBytes: true),
                plan: modified.planMatchingCurrentRepositoryBytes())
        }

        let staged = try GitSourceFixtureV3()
        try staged.replaceRepositoryArtifact(
            role: "evaluation_contract",
            with: Data("{\"evaluation\":\"staged-dirty\"}".utf8))
        try staged.git.run([
            "add", "--",
            staged.inputSnapshot.relativePath(for: "evaluation_contract"),
        ])
        assertGitError(.invalidObservation("working_tree_status")) {
            try staged.capture(
                snapshotCapture: staged.makeInputSnapshot(
                    matchingCurrentRepositoryBytes: true),
                plan: staged.planMatchingCurrentRepositoryBytes())
        }

        let untracked = try GitSourceFixtureV3()
        try Data("untracked fixture\n".utf8).write(
            to: untracked.inputSnapshot.llmRepositoryRoot
                .appendingPathComponent("untracked.txt"),
            options: .withoutOverwriting)
        assertGitError(.invalidObservation("working_tree_status")) {
            try untracked.capture()
        }
    }

    func testRejectsAssumeUnchangedAndSkipWorktreeIndexVisibilityFlags()
        throws
    {
        try assertHiddenIndexMutationIsRejected(
            flag: "--assume-unchanged")
        try assertHiddenIndexMutationIsRejected(
            flag: "--skip-worktree")
    }

    func testRejectsWrongOriginAndSameTreeWrongCommit() throws {
        let wrongOrigin = try GitSourceFixtureV3()
        try wrongOrigin.git.run([
            "remote", "set-url", "origin",
            "https://example.invalid/not-ergentics-llm.git",
        ])
        assertGitError(.invalidObservation("locally_declared_origin")) {
            try wrongOrigin.capture()
        }

        let wrongCommit = try GitSourceFixtureV3()
        try wrongCommit.git.run([
            "commit", "--quiet", "--allow-empty", "--no-gpg-sign", "-m",
            "Same tree but a different commit",
        ])
        XCTAssertEqual(
            try wrongCommit.git.singleLine(["rev-parse", "HEAD^{tree}"]),
            wrongCommit.baseline.tree)
        XCTAssertNotEqual(
            try wrongCommit.git.singleLine(["rev-parse", "HEAD^{commit}"]),
            wrongCommit.baseline.commit)
        assertGitError(.invalidObservation("head_commit")) {
            try wrongCommit.capture()
        }
    }

    func testRejectsRewrittenAndIncludedOriginSpoofing() throws {
        let rewritten = try GitSourceFixtureV3()
        try rewritten.git.run([
            "remote", "set-url", "origin", "ergentics-llm-origin",
        ])
        try rewritten.git.run([
            "config",
            "url.\(GitSourceFixtureV3.expectedRemoteURL).insteadOf",
            "ergentics-llm-origin",
        ])
        XCTAssertEqual(
            try rewritten.git.singleLine([
                "remote", "get-url", "origin",
            ]),
            GitSourceFixtureV3.expectedRemoteURL,
            "The fixture proves ordinary Git URL rewriting would mask the " +
                "raw local declaration")
        assertGitError(.invalidObservation("locally_declared_origin")) {
            try rewritten.capture()
        }

        let included = try GitSourceFixtureV3()
        try included.git.run(["remote", "remove", "origin"])
        let includedConfig = included.inputSnapshot.llmRepositoryRoot
            .appendingPathComponent(".git/origin-include.config")
        try Data(
            ("[remote \"origin\"]\n" +
             "\turl = \(GitSourceFixtureV3.expectedRemoteURL)\n").utf8
        ).write(to: includedConfig, options: .withoutOverwriting)
        try included.git.run([
            "config", "include.path", includedConfig.path,
        ])
        XCTAssertEqual(
            try included.git.singleLine([
                "remote", "get-url", "origin",
            ]),
            GitSourceFixtureV3.expectedRemoteURL,
            "The fixture proves included config would be visible without the " +
                "observer's --no-includes boundary")
        assertGitError(.gitProcessFailed("local_origin_declaration")) {
            try included.capture()
        }
    }

    func testRejectsTreeBlobHybridAndInvalidSourcePlans() throws {
        let hybrid = try GitSourceFixtureV3()
        var hybridArtifacts = hybrid.baseline.artifacts
        hybridArtifacts[0] = hybridArtifacts[0].replacing(
            gitBlobOID: hybridArtifacts[1].gitBlobOID)
        assertGitError(.invalidObservation("tree_entry_root_package_manifest")) {
            try hybrid.capture(
                plan: hybrid.baseline.replacing(artifacts: hybridArtifacts))
        }

        let missing = try GitSourceFixtureV3()
        assertGitError(.invalidObservation("git_source_plan")) {
            try missing.capture(
                plan: missing.baseline.replacing(
                    artifacts: Array(missing.baseline.artifacts.dropLast())))
        }

        let wrongRepository = try GitSourceFixtureV3()
        assertGitError(.invalidObservation("git_source_plan")) {
            try wrongRepository.capture(
                plan: wrongRepository.baseline.replacing(
                    repository: "Ergentics/not-the-final-source"))
        }
    }

    func testRejectsRepositoryRootSymlinkAndSubdirectory() throws {
        let symlink = try GitSourceFixtureV3()
        let alias = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "prime-latin-v3-git-root-alias-\(UUID().uuidString)")
        try FileManager.default.createSymbolicLink(
            at: alias,
            withDestinationURL: symlink.inputSnapshot.llmRepositoryRoot)
        defer { try? FileManager.default.removeItem(at: alias) }
        assertGitError(.invalidObservation("llm_repository_root")) {
            try symlink.capture(llmRepositoryRoot: alias)
        }

        let subdirectory = try GitSourceFixtureV3()
        assertGitError(.invalidObservation("repository_top_level")) {
            try subdirectory.capture(
                llmRepositoryRoot: subdirectory.inputSnapshot.llmRepositoryRoot
                    .appendingPathComponent("Research"))
        }
    }

    func testRejectsLateGitStateMutationAndRecaptureDrift() throws {
        let late = try GitSourceFixtureV3()
        assertGitError(.invalidObservation("head_commit")) {
            try late.capture {
                try late.git.run([
                    "commit", "--quiet", "--allow-empty", "--no-gpg-sign",
                    "-m", "Late same-tree mutation",
                ])
            }
        }

        let recapture = try GitSourceFixtureV3()
        let capture = try captureExpectingSuccess(recapture)
        try Data("post-capture untracked fixture\n".utf8).write(
            to: recapture.inputSnapshot.llmRepositoryRoot
                .appendingPathComponent("post-capture-untracked.txt"),
            options: .withoutOverwriting)
        XCTAssertThrowsError(
            try capture.recaptureAndValidateUnchanged()
        ) { error in
            XCTAssertEqual(
                error as? PrimeLatinProposalGitSourceError,
                .captureChanged)
        }
    }

    private func assertAuthorityCeiling(
        _ authority: PrimeLatinProposalGitSourceAuthorityBoundaryV3,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            authority.disposition,
            "abstain_git_observation_only_requires_live_producer_" +
                "revalidation_and_independent_replay",
            file: file,
            line: line)
        XCTAssertTrue(
            authority.snapshotCaptureAndRecaptureComplete,
            file: file, line: line)
        XCTAssertTrue(
            authority.stableLLMRepositoryRootBoundObservationComplete,
            file: file, line: line)
        XCTAssertTrue(
            authority.stableGitToolObservationComplete,
            file: file, line: line)
        XCTAssertTrue(authority.exactHeadCommitObserved, file: file, line: line)
        XCTAssertTrue(authority.exactHeadTreeObserved, file: file, line: line)
        XCTAssertTrue(
            authority.cleanPorcelainV2StatusObserved,
            file: file, line: line)
        XCTAssertTrue(
            authority.exactRawCommitObjectObserved,
            file: file, line: line)
        XCTAssertTrue(
            authority.exactSevenRepositoryTreeEntriesObserved,
            file: file, line: line)
        XCTAssertTrue(
            authority.sevenRepositoryBlobHashCountBindingsMatchedSnapshot,
            file: file, line: line)
        XCTAssertTrue(
            authority.localOriginDeclarationObserved,
            file: file, line: line)
        XCTAssertTrue(
            authority.repeatedGitObservationUnchanged,
            file: file, line: line)
        XCTAssertTrue(
            authority.referencedInputSnapshotAvailable,
            file: file, line: line)
        XCTAssertTrue(
            authority.referencedArtifactBytesAvailable,
            file: file, line: line)
        XCTAssertTrue(
            authority.llmGitStateIndependentlyObserved,
            file: file, line: line)
        XCTAssertTrue(
            authority.noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved,
            file: file, line: line)

        XCTAssertFalse(
            authority.originRemoteCryptographicallyAuthenticated,
            file: file, line: line)
        XCTAssertFalse(
            authority.ignoredWorkspaceBytesObserved,
            file: file, line: line)
        XCTAssertFalse(
            authority.durableInputSnapshotPublished,
            file: file, line: line)
        XCTAssertFalse(
            authority.durableGitObservationPublished,
            file: file, line: line)
        XCTAssertFalse(
            authority.liveProducerWorkspaceRevalidationComplete,
            file: file, line: line)
        XCTAssertFalse(
            authority.independentReplayComplete,
            file: file, line: line)
        XCTAssertFalse(
            authority.runtimeDecoderImplementationAvailable,
            file: file, line: line)
        XCTAssertFalse(
            authority.runtimeDependencyClosureEstablished,
            file: file, line: line)
        XCTAssertFalse(
            authority.runtimeInitializationEstablished,
            file: file, line: line)
        XCTAssertFalse(
            authority.primeProposalPacketProduced,
            file: file, line: line)
        XCTAssertFalse(
            authority.primeTrialAuthorizationProduced,
            file: file, line: line)
        XCTAssertFalse(
            authority.primeDecisionReceiptProduced,
            file: file, line: line)
        XCTAssertFalse(
            authority.candidateSelectionAuthorized,
            file: file, line: line)
        XCTAssertFalse(
            authority.trialExecutionAuthorized,
            file: file, line: line)
        XCTAssertFalse(
            authority.furtherTrainingAuthorized,
            file: file, line: line)
        XCTAssertFalse(
            authority.promotionAuthorized,
            file: file, line: line)
        XCTAssertFalse(
            authority.productUseAuthorized,
            file: file, line: line)
        XCTAssertFalse(
            authority.publicationAuthorized,
            file: file, line: line)
        XCTAssertFalse(
            authority.primeDurableReceiptPublished,
            file: file, line: line)
    }

    private func assertHiddenIndexMutationIsRejected(
        flag: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let fixture = try GitSourceFixtureV3()
        let relativePath =
            "Research/Latin/index-visibility-extra.txt"
        let extraURL = fixture.inputSnapshot.llmRepositoryRoot
            .appendingPathComponent(relativePath)
        try Data("committed extra tracked fixture\n".utf8).write(
            to: extraURL,
            options: .withoutOverwriting)
        try fixture.git.run(["add", "--", relativePath])
        try fixture.git.run([
            "commit", "--quiet", "--no-gpg-sign", "-m",
            "Add extra tracked index-visibility fixture",
        ])
        let matchingPlan = try fixture.derivePlan()

        try fixture.git.run(["update-index", flag, "--", relativePath])
        try Data("mutated bytes hidden from porcelain v2\n".utf8).write(
            to: extraURL)
        let visibilityRecord = try fixture.git.data([
            "ls-files", "-v", "-z", "--", relativePath,
        ])
        let expectedTag = flag == "--assume-unchanged" ? "h" : "S"
        XCTAssertEqual(
            visibilityRecord,
            Data("\(expectedTag) \(relativePath)\u{0}".utf8),
            "Unexpected ls-files visibility tag for \(flag)",
            file: file,
            line: line)
        let porcelain = try fixture.git.data([
            "status",
            "--porcelain=v2",
            "-z",
            "--untracked-files=all",
            "--ignore-submodules=none",
        ])
        XCTAssertTrue(
            porcelain.isEmpty,
            "Fixture did not hide the mutation for \(flag)",
            file: file,
            line: line)

        assertGitError(
            .invalidObservation("tracked_index_visibility"),
            file: file,
            line: line
        ) {
            try fixture.capture(plan: matchingPlan)
        }
    }

    private func assertGitError<T>(
        _ expected: PrimeLatinProposalGitSourceError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ operation: () throws -> T
    ) {
        do {
            _ = try operation()
            XCTFail("Expected Git-observation rejection", file: file, line: line)
        } catch {
            XCTAssertEqual(
                error as? PrimeLatinProposalGitSourceError,
                expected,
                file: file,
                line: line)
        }
    }

    private func captureExpectingSuccess(
        _ fixture: GitSourceFixtureV3,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> PrimeLatinProposalGitSourceCaptureV3 {
        do {
            return try fixture.capture()
        } catch {
            XCTFail(
                "Unexpected Git-observation capture error: " +
                    String(reflecting: error),
                file: file,
                line: line)
            throw error
        }
    }

    private func assertLowercaseSHA256(
        _ value: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(value.count, 64, file: file, line: line)
        XCTAssertTrue(
            value.allSatisfy { $0.isNumber || ("a"..."f").contains(String($0)) },
            file: file,
            line: line)
    }
}

private struct GitArtifactFixtureV3: Equatable {
    let role: String
    let relativePath: String
    let gitBlobOID: String
    let sha256: String
    let byteCount: UInt64
}

private struct GitSourceFixturePlanV3: Equatable {
    let repository: String
    let commit: String
    let tree: String
    let rawCommitSHA256: String
    let rawCommitByteCount: UInt64
    let artifacts: [GitArtifactFixtureV3]
}

private final class GitSourceFixtureV3 {
    static let expectedRemoteURL =
        "https://github.com/Ergentics/ergentics-llm.git"

    let inputSnapshot: InputSnapshotFixtureV3
    let git: LocalGitFixtureV3
    let baseline: GitSourceFixturePlanV3

    init() throws {
        let inputSnapshot = try InputSnapshotFixtureV3()
        let repositoryArtifacts = inputSnapshot.artifacts.filter {
            $0.scope == .ergenticsLLMRepository
        }
        let git = LocalGitFixtureV3(
            repositoryRoot: inputSnapshot.llmRepositoryRoot)
        self.inputSnapshot = inputSnapshot
        self.git = git

        try git.run(["init", "--quiet"])
        try git.run(["config", "user.name", "Prime Latin Git Fixture"])
        try git.run([
            "config", "user.email", "prime-latin-git-fixture@example.invalid",
        ])
        try git.run(["config", "commit.gpgSign", "false"])
        try git.run([
            "remote", "add", "origin", Self.expectedRemoteURL,
        ])
        try git.run(
            ["add", "--"] + repositoryArtifacts.map(\.relativePath))
        try git.run([
            "commit", "--quiet", "--no-gpg-sign", "-m",
            "Prime Latin synthetic final-source fixture",
        ])
        baseline = try Self.derivePlan(
            git: git,
            repositoryArtifacts: repositoryArtifacts)
    }

    var repositoryArtifacts: [InputSnapshotArtifactV3] {
        inputSnapshot.artifacts.filter {
            $0.scope == .ergenticsLLMRepository
        }
    }

    func makeInputSnapshot(
        matchingCurrentRepositoryBytes: Bool = false
    ) throws -> PrimeLatinProposalInputSnapshotCaptureV3 {
        try inputSnapshot.capture(
            expectations: matchingCurrentRepositoryBytes
                ? try expectationsMatchingCurrentRepositoryBytes()
                : inputSnapshot.expectations)
    }

    func capture(
        snapshotCapture: PrimeLatinProposalInputSnapshotCaptureV3? = nil,
        llmRepositoryRoot: URL? = nil,
        plan: GitSourceFixturePlanV3? = nil,
        beforeSecondObservation: () throws -> Void = {}
    ) throws -> PrimeLatinProposalGitSourceCaptureV3 {
        try PrimeLatinProposalGitSourceCaptureV3.captureForTesting(
            snapshotCapture: snapshotCapture ?? makeInputSnapshot(),
            llmRepositoryRoot:
                llmRepositoryRoot ?? inputSnapshot.llmRepositoryRoot,
            expectedSource: Self.productionPlan(from: plan ?? baseline),
            beforeSecondObservation: beforeSecondObservation)
    }

    func derivePlan() throws -> GitSourceFixturePlanV3 {
        try Self.derivePlan(
            git: git,
            repositoryArtifacts: repositoryArtifacts)
    }

    private static func derivePlan(
        git: LocalGitFixtureV3,
        repositoryArtifacts: [InputSnapshotArtifactV3]
    ) throws -> GitSourceFixturePlanV3 {
        let commit = try git.singleLine(["rev-parse", "HEAD^{commit}"])
        let tree = try git.singleLine(["rev-parse", "HEAD^{tree}"])
        let rawCommit = try git.data(["cat-file", "-p", commit])
        let artifacts = try repositoryArtifacts.map { artifact in
            GitArtifactFixtureV3(
                role: artifact.role,
                relativePath: artifact.relativePath,
                gitBlobOID: try git.singleLine([
                    "rev-parse", "\(commit):\(artifact.relativePath)",
                ]),
                sha256: artifact.sha256,
                byteCount: UInt64(artifact.data.count))
        }
        return GitSourceFixturePlanV3(
            repository: "Ergentics/ergentics-llm",
            commit: commit,
            tree: tree,
            rawCommitSHA256: Self.sha256(rawCommit),
            rawCommitByteCount: UInt64(rawCommit.count),
            artifacts: artifacts)
    }

    func planMatchingCurrentRepositoryBytes() throws
        -> GitSourceFixturePlanV3
    {
        let artifacts = try repositoryArtifacts.map { artifact in
            let data = try Data(contentsOf: inputSnapshot.url(
                for: artifact.role))
            return GitArtifactFixtureV3(
                role: artifact.role,
                relativePath: artifact.relativePath,
                gitBlobOID: Self.gitBlobOID(data),
                sha256: Self.sha256(data),
                byteCount: UInt64(data.count))
        }
        return baseline.replacing(artifacts: artifacts)
    }

    func replaceRepositoryArtifact(role: String, with data: Data) throws {
        precondition(
            inputSnapshot.artifact(for: role).scope
                == .ergenticsLLMRepository)
        try inputSnapshot.replace(role: role, with: data)
    }

    private func expectationsMatchingCurrentRepositoryBytes() throws
        -> [PrimeLatinProposalInputArtifactExpectationV3]
    {
        try inputSnapshot.expectations.map { expectation in
            guard expectation.scope == .ergenticsLLMRepository else {
                return expectation
            }
            let data = try Data(contentsOf: inputSnapshot.llmRepositoryRoot
                .appendingPathComponent(expectation.relativePath))
            return PrimeLatinProposalInputArtifactExpectationV3(
                role: expectation.role,
                scope: expectation.scope,
                relativePath: expectation.relativePath,
                sha256: Self.sha256(data),
                byteCount: UInt64(data.count))
        }
    }

    static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map {
            String(format: "%02x", $0)
        }.joined()
    }

    private static func gitBlobOID(_ data: Data) -> String {
        var framed = Data("blob \(data.count)\u{0}".utf8)
        framed.append(data)
        return Insecure.SHA1.hash(data: framed).map {
            String(format: "%02x", $0)
        }.joined()
    }

    private static func productionPlan(
        from fixture: GitSourceFixturePlanV3
    ) -> PrimeLatinProposalGitExpectedSourcePlanV3 {
        PrimeLatinProposalGitExpectedSourcePlanV3(
            sourceRepository: fixture.repository,
            locallyDeclaredOriginURL: expectedRemoteURL,
            commit: fixture.commit,
            tree: fixture.tree,
            rawCommitSHA256: fixture.rawCommitSHA256,
            rawCommitByteCount: fixture.rawCommitByteCount,
            artifacts: fixture.artifacts.map {
                PrimeLatinProposalGitExpectedArtifactV3(
                    role: $0.role,
                    relativePath: $0.relativePath,
                    gitBlobOID: $0.gitBlobOID,
                    sha256: $0.sha256,
                    byteCount: $0.byteCount)
            })
    }
}

private extension GitArtifactFixtureV3 {
    func replacing(
        gitBlobOID: String? = nil,
        sha256: String? = nil,
        byteCount: UInt64? = nil
    ) -> GitArtifactFixtureV3 {
        GitArtifactFixtureV3(
            role: role,
            relativePath: relativePath,
            gitBlobOID: gitBlobOID ?? self.gitBlobOID,
            sha256: sha256 ?? self.sha256,
            byteCount: byteCount ?? self.byteCount)
    }
}

private extension GitSourceFixturePlanV3 {
    func replacing(
        repository: String? = nil,
        commit: String? = nil,
        tree: String? = nil,
        rawCommitSHA256: String? = nil,
        rawCommitByteCount: UInt64? = nil,
        artifacts: [GitArtifactFixtureV3]? = nil
    ) -> GitSourceFixturePlanV3 {
        GitSourceFixturePlanV3(
            repository: repository ?? self.repository,
            commit: commit ?? self.commit,
            tree: tree ?? self.tree,
            rawCommitSHA256: rawCommitSHA256 ?? self.rawCommitSHA256,
            rawCommitByteCount: rawCommitByteCount ?? self.rawCommitByteCount,
            artifacts: artifacts ?? self.artifacts)
    }
}

private struct LocalGitFixtureV3 {
    private static let maximumOutputByteCount = 1 * 1_024 * 1_024
    private let repositoryRoot: URL

    init(repositoryRoot: URL) {
        self.repositoryRoot = repositoryRoot
    }

    @discardableResult
    func run(_ arguments: [String]) throws -> Data {
        try data(arguments)
    }

    func singleLine(_ arguments: [String]) throws -> String {
        let value = String(decoding: try data(arguments), as: UTF8.self)
        let lines = value.split(
            separator: "\n",
            omittingEmptySubsequences: false)
        guard lines.count == 2, lines[1].isEmpty, !lines[0].isEmpty else {
            throw LocalGitFixtureError.invalidSingleLine(arguments)
        }
        return String(lines[0])
    }

    func data(_ arguments: [String]) throws -> Data {
        let process = Process()
        let standardOutput = Pipe()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = arguments
        process.currentDirectoryURL = repositoryRoot
        process.environment = [
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_OPTIONAL_LOCKS": "0",
            "GIT_TERMINAL_PROMPT": "0",
            "HOME": repositoryRoot.path,
            "LANG": "C",
            "LC_ALL": "C",
            "PATH": "/usr/bin:/bin",
        ]
        process.standardOutput = standardOutput
        process.standardError = standardError
        try process.run()
        process.waitUntilExit()
        let output = standardOutput.fileHandleForReading.readDataToEndOfFile()
        let error = standardError.fileHandleForReading.readDataToEndOfFile()
        guard output.count <= Self.maximumOutputByteCount,
              error.count <= Self.maximumOutputByteCount
        else {
            throw LocalGitFixtureError.outputTooLarge(arguments)
        }
        guard process.terminationReason == .exit,
              process.terminationStatus == 0
        else {
            throw LocalGitFixtureError.commandFailed(
                arguments,
                process.terminationStatus,
                String(decoding: error, as: UTF8.self))
        }
        return output
    }
}

private enum LocalGitFixtureError: Error {
    case commandFailed([String], Int32, String)
    case invalidSingleLine([String])
    case outputTooLarge([String])
}
