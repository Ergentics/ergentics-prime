#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import CryptoKit
import Foundation
import PrimeLatinProposalPairCapture

public enum PrimeLatinProposalGitSourceError:
    Error,
    Equatable,
    Sendable
{
    case invalidObservation(String)
    case captureChanged
    case gitProcessFailed(String)
    case gitProcessTimedOut(String)
    case gitOutputTooLarge(String)
}

public struct PrimeLatinProposalGitToolObservationV3:
    Equatable,
    Sendable
{
    public let absolutePath: String
    public let sha256: String
    public let byteCount: UInt64
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let actualMode: UInt16
    public let version: String
    public let versionOutputSHA256: String
    public let environmentPolicyID: String

    fileprivate init(
        binding: PrimeLatinProposalGitToolBindingV3,
        version: String,
        versionData: Data
    ) {
        absolutePath = binding.absolutePath
        sha256 = binding.sha256
        byteCount = binding.byteCount
        deviceID = binding.identity.deviceID
        inode = binding.identity.inode
        ownerUserID = binding.identity.ownerUserID
        actualMode = binding.identity.actualMode
        self.version = version
        versionOutputSHA256 = PrimeLatinProposalGitHashV3.sha256(versionData)
        environmentPolicyID =
            PrimeLatinProposalGitContractV3.environmentPolicyID
    }
}

public struct PrimeLatinProposalGitArtifactObservationV3:
    Equatable,
    Sendable
{
    public let role: String
    public let relativePath: String
    public let mode: String
    public let objectType: String
    public let gitBlobOID: String
    public let recomputedGitBlobOID: String
    public let snapshotSHA256: String
    public let snapshotByteCount: UInt64
    public let observedBlobSHA256: String
    public let observedBlobByteCount: UInt64

    fileprivate init(
        expectation: PrimeLatinProposalGitExpectedArtifactV3,
        mode: String,
        objectType: String,
        observedBlobData: Data
    ) {
        role = expectation.role
        relativePath = expectation.relativePath
        self.mode = mode
        self.objectType = objectType
        gitBlobOID = expectation.gitBlobOID
        recomputedGitBlobOID = PrimeLatinProposalGitHashV3.gitOID(
            type: "blob",
            data: observedBlobData)
        snapshotSHA256 = expectation.sha256
        snapshotByteCount = expectation.byteCount
        observedBlobSHA256 = PrimeLatinProposalGitHashV3.sha256(
            observedBlobData)
        observedBlobByteCount = UInt64(observedBlobData.count)
    }
}

public struct PrimeLatinProposalGitSourceAuthorityBoundaryV3:
    Equatable,
    Sendable
{
    public let disposition: String
    public let snapshotCaptureAndRecaptureComplete: Bool
    public let stableLLMRepositoryRootBoundObservationComplete: Bool
    public let stableGitToolObservationComplete: Bool
    public let exactHeadCommitObserved: Bool
    public let exactHeadTreeObserved: Bool
    public let cleanPorcelainV2StatusObserved: Bool
    public let noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved: Bool
    public let exactRawCommitObjectObserved: Bool
    public let exactSevenRepositoryTreeEntriesObserved: Bool
    public let sevenRepositoryBlobHashCountBindingsMatchedSnapshot: Bool
    public let localOriginDeclarationObserved: Bool
    public let repeatedGitObservationUnchanged: Bool
    public let referencedInputSnapshotAvailable: Bool
    public let referencedArtifactBytesAvailable: Bool
    public let llmGitStateIndependentlyObserved: Bool
    public let originRemoteCryptographicallyAuthenticated: Bool
    public let ignoredWorkspaceBytesObserved: Bool
    public let durableInputSnapshotPublished: Bool
    public let durableGitObservationPublished: Bool
    public let liveProducerWorkspaceRevalidationComplete: Bool
    public let independentReplayComplete: Bool
    public let runtimeDecoderImplementationAvailable: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let primeProposalPacketProduced: Bool
    public let primeTrialAuthorizationProduced: Bool
    public let primeDecisionReceiptProduced: Bool
    public let candidateSelectionAuthorized: Bool
    public let trialExecutionAuthorized: Bool
    public let furtherTrainingAuthorized: Bool
    public let promotionAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let primeDurableReceiptPublished: Bool

    fileprivate init() {
        disposition =
            "abstain_git_observation_only_requires_live_producer_revalidation_and_independent_replay"
        snapshotCaptureAndRecaptureComplete = true
        stableLLMRepositoryRootBoundObservationComplete = true
        stableGitToolObservationComplete = true
        exactHeadCommitObserved = true
        exactHeadTreeObserved = true
        cleanPorcelainV2StatusObserved = true
        noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved = true
        exactRawCommitObjectObserved = true
        exactSevenRepositoryTreeEntriesObserved = true
        sevenRepositoryBlobHashCountBindingsMatchedSnapshot = true
        localOriginDeclarationObserved = true
        repeatedGitObservationUnchanged = true
        referencedInputSnapshotAvailable = true
        referencedArtifactBytesAvailable = true
        llmGitStateIndependentlyObserved = true
        originRemoteCryptographicallyAuthenticated = false
        ignoredWorkspaceBytesObserved = false
        durableInputSnapshotPublished = false
        durableGitObservationPublished = false
        liveProducerWorkspaceRevalidationComplete = false
        independentReplayComplete = false
        runtimeDecoderImplementationAvailable = false
        runtimeDependencyClosureEstablished = false
        runtimeInitializationEstablished = false
        primeProposalPacketProduced = false
        primeTrialAuthorizationProduced = false
        primeDecisionReceiptProduced = false
        candidateSelectionAuthorized = false
        trialExecutionAuthorized = false
        furtherTrainingAuthorized = false
        promotionAuthorized = false
        productUseAuthorized = false
        publicationAuthorized = false
        primeDurableReceiptPublished = false
    }
}

public struct PrimeLatinProposalGitSourceObservationV3:
    Equatable,
    Sendable
{
    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let pairReceiptSHA256: String
    public let llmSource: PrimeLatinProposalInputsV3SourceObservation
    public let snapshotArtifactCount: UInt64
    public let repositoryRootDeviceID: UInt64
    public let repositoryRootInode: UInt64
    public let repositoryRootOwnerUserID: UInt32
    public let repositoryRootActualMode: UInt16
    public let gitTool: PrimeLatinProposalGitToolObservationV3
    public let locallyDeclaredOriginURL: String
    public let originObservationScope: String
    public let objectFormat: String
    public let headCommit: String
    public let headTree: String
    public let porcelainV2StatusByteCount: UInt64
    public let porcelainV2StatusSHA256: String
    public let trackedIndexEntryCount: UInt64
    public let trackedIndexInventoryByteCount: UInt64
    public let trackedIndexInventorySHA256: String
    public let rawCommitGitOID: String
    public let recomputedRawCommitGitOID: String
    public let rawCommitSHA256: String
    public let rawCommitByteCount: UInt64
    public let repositoryArtifactCount: UInt64
    public let repositoryArtifacts:
        [PrimeLatinProposalGitArtifactObservationV3]
    public let gitCommandCount: UInt64
    public let authority: PrimeLatinProposalGitSourceAuthorityBoundaryV3

    fileprivate init(
        snapshot: PrimeLatinProposalInputSnapshotObservationV3,
        rootIdentity: PrimeLatinProposalGitFileIdentityV3,
        git: PrimeLatinProposalGitObservationStateV3
    ) {
        schema =
            "ergentics_prime_latin_proposal_git_source_v3_observation"
        outcome = "abstain"
        verificationScope =
            "fixed_read_only_git_process_exact_head_tree_clean_status_and_seven_snapshot_repository_bindings_only_non_authorizing"
        pairReceiptSHA256 = snapshot.pairReceiptSHA256
        llmSource = snapshot.llmSource
        snapshotArtifactCount = snapshot.artifactCount
        repositoryRootDeviceID = rootIdentity.deviceID
        repositoryRootInode = rootIdentity.inode
        repositoryRootOwnerUserID = rootIdentity.ownerUserID
        repositoryRootActualMode = rootIdentity.actualMode
        gitTool = git.gitTool
        locallyDeclaredOriginURL = git.locallyDeclaredOriginURL
        originObservationScope =
            "locally_declared_origin_only_not_network_authenticated"
        objectFormat = git.objectFormat
        headCommit = git.headCommit
        headTree = git.headTree
        porcelainV2StatusByteCount = git.statusByteCount
        porcelainV2StatusSHA256 = git.statusSHA256
        trackedIndexEntryCount = git.trackedIndexEntryCount
        trackedIndexInventoryByteCount = git.trackedIndexInventoryByteCount
        trackedIndexInventorySHA256 = git.trackedIndexInventorySHA256
        rawCommitGitOID = git.headCommit
        recomputedRawCommitGitOID = git.recomputedRawCommitGitOID
        rawCommitSHA256 = git.rawCommitSHA256
        rawCommitByteCount = git.rawCommitByteCount
        repositoryArtifactCount = UInt64(git.artifacts.count)
        repositoryArtifacts = git.artifacts
        gitCommandCount = UInt64(git.commandObservations.count)
        authority = PrimeLatinProposalGitSourceAuthorityBoundaryV3()
    }
}

struct PrimeLatinProposalGitExpectedArtifactV3:
    Equatable,
    Sendable
{
    let role: String
    let relativePath: String
    let gitBlobOID: String
    let sha256: String
    let byteCount: UInt64

    init(
        role: String,
        relativePath: String,
        gitBlobOID: String,
        sha256: String,
        byteCount: UInt64
    ) {
        self.role = role
        self.relativePath = relativePath
        self.gitBlobOID = gitBlobOID
        self.sha256 = sha256
        self.byteCount = byteCount
    }
}

struct PrimeLatinProposalGitExpectedSourcePlanV3:
    Equatable,
    Sendable
{
    let sourceRepository: String
    let locallyDeclaredOriginURL: String
    let commit: String
    let tree: String
    let rawCommitSHA256: String
    let rawCommitByteCount: UInt64
    let artifacts: [PrimeLatinProposalGitExpectedArtifactV3]

    init(
        sourceRepository: String,
        locallyDeclaredOriginURL: String,
        commit: String,
        tree: String,
        rawCommitSHA256: String,
        rawCommitByteCount: UInt64,
        artifacts: [PrimeLatinProposalGitExpectedArtifactV3]
    ) {
        self.sourceRepository = sourceRepository
        self.locallyDeclaredOriginURL = locallyDeclaredOriginURL
        self.commit = commit
        self.tree = tree
        self.rawCommitSHA256 = rawCommitSHA256
        self.rawCommitByteCount = rawCommitByteCount
        self.artifacts = artifacts
    }
}

/// A process-local, read-only observation of the exact Git source that backs
/// one already captured V3 proposal-input snapshot. It produces no receipt and
/// grants no proposal, execution, training, selection, or publication authority.
public final class PrimeLatinProposalGitSourceCaptureV3:
    @unchecked Sendable
{
    public let observation: PrimeLatinProposalGitSourceObservationV3

    private let lock = NSLock()
    private let snapshotCapture: PrimeLatinProposalInputSnapshotCaptureV3
    private let snapshotObservation:
        PrimeLatinProposalInputSnapshotObservationV3
    private let repositoryRoot: PrimeLatinProposalGitRootHandleV3
    private let expectedSource: PrimeLatinProposalGitExpectedSourcePlanV3
    private let gitState: PrimeLatinProposalGitObservationStateV3

    private init(
        snapshotCapture: PrimeLatinProposalInputSnapshotCaptureV3,
        snapshotObservation: PrimeLatinProposalInputSnapshotObservationV3,
        repositoryRoot: PrimeLatinProposalGitRootHandleV3,
        expectedSource: PrimeLatinProposalGitExpectedSourcePlanV3,
        gitState: PrimeLatinProposalGitObservationStateV3
    ) {
        self.snapshotCapture = snapshotCapture
        self.snapshotObservation = snapshotObservation
        self.repositoryRoot = repositoryRoot
        self.expectedSource = expectedSource
        self.gitState = gitState
        observation = PrimeLatinProposalGitSourceObservationV3(
            snapshot: snapshotObservation,
            rootIdentity: repositoryRoot.identity,
            git: gitState)
    }

    public static func capture(
        labRoot: URL,
        llmRepositoryRoot: URL,
        pairSHA256: String
    ) throws -> PrimeLatinProposalGitSourceCaptureV3 {
        let snapshotCapture: PrimeLatinProposalInputSnapshotCaptureV3
        do {
            snapshotCapture = try PrimeLatinProposalInputSnapshotCaptureV3
                .capture(
                    labRoot: labRoot,
                    llmRepositoryRoot: llmRepositoryRoot,
                    pairSHA256: pairSHA256)
        } catch {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "proposal_input_snapshot_v3")
        }
        return try capture(
            snapshotCapture: snapshotCapture,
            llmRepositoryRoot: llmRepositoryRoot,
            expectedSource: .finalHandoff,
            requireSnapshotSourceMatch: true,
            beforeSecondObservation: {})
    }

    static func captureForTesting(
        snapshotCapture: PrimeLatinProposalInputSnapshotCaptureV3,
        llmRepositoryRoot: URL,
        expectedSource: PrimeLatinProposalGitExpectedSourcePlanV3,
        beforeSecondObservation: () throws -> Void
    ) throws -> PrimeLatinProposalGitSourceCaptureV3 {
        try capture(
            snapshotCapture: snapshotCapture,
            llmRepositoryRoot: llmRepositoryRoot,
            expectedSource: expectedSource,
            requireSnapshotSourceMatch: false,
            beforeSecondObservation: beforeSecondObservation)
    }

    @discardableResult
    public func recaptureAndValidateUnchanged() throws
        -> PrimeLatinProposalGitSourceObservationV3
    {
        lock.lock()
        defer { lock.unlock() }
        do {
            let first = try PrimeLatinProposalGitObserverV3.observe(
                repositoryRoot: repositoryRoot,
                expectedSource: expectedSource,
                snapshot: snapshotObservation)
            let firstSnapshot = try snapshotCapture
                .recaptureAndValidateUnchanged()
            let second = try PrimeLatinProposalGitObserverV3.observe(
                repositoryRoot: repositoryRoot,
                expectedSource: expectedSource,
                snapshot: snapshotObservation)
            let secondSnapshot = try snapshotCapture
                .recaptureAndValidateUnchanged()
            guard first == second,
                  second == gitState,
                  firstSnapshot == snapshotObservation,
                  secondSnapshot == snapshotObservation else {
                throw PrimeLatinProposalGitSourceError.captureChanged
            }
            try repositoryRoot.validateReboundIdentity()
            return observation
        } catch {
            throw PrimeLatinProposalGitSourceError.captureChanged
        }
    }

    private static func capture(
        snapshotCapture: PrimeLatinProposalInputSnapshotCaptureV3,
        llmRepositoryRoot: URL,
        expectedSource: PrimeLatinProposalGitExpectedSourcePlanV3,
        requireSnapshotSourceMatch: Bool,
        beforeSecondObservation: () throws -> Void
    ) throws -> PrimeLatinProposalGitSourceCaptureV3 {
        let snapshot = snapshotCapture.observation
        try PrimeLatinProposalGitContractV3.validate(
            expectedSource: expectedSource,
            snapshot: snapshot,
            requireSnapshotSourceMatch: requireSnapshotSourceMatch)
        let root = try PrimeLatinProposalGitRootHandleV3(
            url: llmRepositoryRoot)
        let first = try PrimeLatinProposalGitObserverV3.observe(
            repositoryRoot: root,
            expectedSource: expectedSource,
            snapshot: snapshot)
        let recaptured: PrimeLatinProposalInputSnapshotObservationV3
        do {
            recaptured = try snapshotCapture
                .recaptureAndValidateUnchanged()
            try beforeSecondObservation()
        } catch {
            throw PrimeLatinProposalGitSourceError.captureChanged
        }
        let second = try PrimeLatinProposalGitObserverV3.observe(
            repositoryRoot: root,
            expectedSource: expectedSource,
            snapshot: snapshot)
        let finalSnapshot: PrimeLatinProposalInputSnapshotObservationV3
        do {
            finalSnapshot = try snapshotCapture
                .recaptureAndValidateUnchanged()
        } catch {
            throw PrimeLatinProposalGitSourceError.captureChanged
        }
        guard first == second,
              recaptured == snapshot,
              finalSnapshot == snapshot else {
            throw PrimeLatinProposalGitSourceError.captureChanged
        }
        try root.validateReboundIdentity()
        return PrimeLatinProposalGitSourceCaptureV3(
            snapshotCapture: snapshotCapture,
            snapshotObservation: snapshot,
            repositoryRoot: root,
            expectedSource: expectedSource,
            gitState: second)
    }
}

private extension PrimeLatinProposalGitExpectedSourcePlanV3 {
    static let finalHandoff = PrimeLatinProposalGitExpectedSourcePlanV3(
        sourceRepository: "Ergentics/ergentics-llm",
        locallyDeclaredOriginURL:
            "https://github.com/Ergentics/ergentics-llm.git",
        commit: "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
        tree: "c1f41758aea2860ab06039776f5ea0403dff1b61",
        rawCommitSHA256:
            "0e4e7ea646db282de4f23064acad5884586d01cdcc89611deae3c01298b29fed",
        rawCommitByteCount: 1_222,
        artifacts: [
            PrimeLatinProposalGitExpectedArtifactV3(
                role: "root_package_manifest",
                relativePath: "Package.swift",
                gitBlobOID:
                    "dabd1cd7002ddbfa4d05d7c4f7660133892d0050",
                sha256:
                    "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902",
                byteCount: 6_109),
            PrimeLatinProposalGitExpectedArtifactV3(
                role: "root_dependency_lock",
                relativePath: "Package.resolved",
                gitBlobOID:
                    "4e822bfadbe5f4dced15a277f4d5423a03d76890",
                sha256:
                    "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530",
                byteCount: 645),
            PrimeLatinProposalGitExpectedArtifactV3(
                role: "declaration_package_manifest",
                relativePath:
                    "Research/Latin/CandidateDeclarations/Package.swift",
                gitBlobOID:
                    "67907b47cf941c6e36154dd729b284f64c90ca9b",
                sha256:
                    "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63",
                byteCount: 892),
            PrimeLatinProposalGitExpectedArtifactV3(
                role: "declaration_production_source",
                relativePath:
                    "Research/Latin/CandidateDeclarations/Sources/ErgenticsLatinCandidateDeclarations/ErgenticsLatinCandidateDeclarations.swift",
                gitBlobOID:
                    "a951d3710dba072aa7eb8554c60abafdd032cb7f",
                sha256:
                    "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4",
                byteCount: 35_119),
            PrimeLatinProposalGitExpectedArtifactV3(
                role: "candidate_architecture",
                relativePath:
                    "Research/Latin/candidates/latin_structural_fixture_v1/architecture.json",
                gitBlobOID:
                    "a3a9582003bfdbce2c94707313c0e402955bca9b",
                sha256:
                    "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70",
                byteCount: 2_794),
            PrimeLatinProposalGitExpectedArtifactV3(
                role: "candidate_parameter_count_derivation",
                relativePath:
                    "Research/Latin/candidates/latin_structural_fixture_v1/parameter-count-derivation.json",
                gitBlobOID:
                    "9957d0b17edd019ce760fdae9907a8ebadf408e3",
                sha256:
                    "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f",
                byteCount: 2_702),
            PrimeLatinProposalGitExpectedArtifactV3(
                role: "evaluation_contract",
                relativePath: "Research/Latin/evaluation_contract.json",
                gitBlobOID:
                    "0f052ee6724d4815b8c18eae968175631035f00d",
                sha256:
                    "4a0dd1bc973f7ce380df9775413c4e43033ba0cc409fb45a9368c2bef6835d52",
                byteCount: 164),
        ])
}

private enum PrimeLatinProposalGitContractV3 {
    static let gitExecutablePath = "/usr/bin/git"
    static let environmentPolicyID =
        "prime_latin_git_read_only_fixed_environment_v1"
    static let processTimeoutSeconds: Double = 30
    static let processTerminationGraceSeconds: Double = 2
    static let maximumStderrByteCount: UInt64 = 65_536
    static let maximumStatusByteCount: UInt64 = 65_536
    static let maximumTrackedIndexInventoryByteCount: UInt64 = 1_048_576
    static let maximumTrackedIndexEntryCount: UInt64 = 16_384
    static let maximumTreeInventoryByteCount: UInt64 = 65_536
    static let maximumGitToolByteCount: UInt64 = 134_217_728
    static let expectedObjectFormat = "sha1"
    static let expectedStatusSHA256 =
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    static let finalTrackedIndexEntryCount: UInt64 = 144
    static let finalTrackedIndexInventoryByteCount: UInt64 = 6_933
    static let finalTrackedIndexInventorySHA256 =
        "101afd50470f669f8b4de14f9188e16854a4166b355bf8a4e9ec810a59a9e289"
    static let repositoryRoles = [
        "root_package_manifest",
        "root_dependency_lock",
        "declaration_package_manifest",
        "declaration_production_source",
        "candidate_architecture",
        "candidate_parameter_count_derivation",
        "evaluation_contract",
    ]
    static let repositoryPaths = [
        "Package.swift",
        "Package.resolved",
        "Research/Latin/CandidateDeclarations/Package.swift",
        "Research/Latin/CandidateDeclarations/Sources/ErgenticsLatinCandidateDeclarations/ErgenticsLatinCandidateDeclarations.swift",
        "Research/Latin/candidates/latin_structural_fixture_v1/architecture.json",
        "Research/Latin/candidates/latin_structural_fixture_v1/parameter-count-derivation.json",
        "Research/Latin/evaluation_contract.json",
    ]

    static func validate(
        expectedSource: PrimeLatinProposalGitExpectedSourcePlanV3,
        snapshot: PrimeLatinProposalInputSnapshotObservationV3,
        requireSnapshotSourceMatch: Bool
    ) throws {
        guard expectedSource.sourceRepository
                == "Ergentics/ergentics-llm",
              !expectedSource.locallyDeclaredOriginURL.isEmpty,
              !expectedSource.locallyDeclaredOriginURL.contains("\n"),
              !expectedSource.locallyDeclaredOriginURL.contains("\r"),
              !expectedSource.locallyDeclaredOriginURL.contains("\0"),
              isGitOID(expectedSource.commit),
              isGitOID(expectedSource.tree),
              isSHA256(expectedSource.rawCommitSHA256),
              expectedSource.rawCommitByteCount > 0,
              expectedSource.rawCommitByteCount <= 65_536,
              expectedSource.artifacts.count == repositoryRoles.count,
              expectedSource.artifacts.map(\.role) == repositoryRoles,
              expectedSource.artifacts.map(\.relativePath) == repositoryPaths,
              snapshot.schema
                == "ergentics_prime_latin_proposal_input_snapshot_v3_observation",
              snapshot.outcome == "abstain",
              snapshot.artifactCount == UInt64(snapshot.artifacts.count),
              snapshot.artifactCount == 21,
              snapshot.llmSource.repository
                == expectedSource.sourceRepository else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "git_source_plan")
        }
        if requireSnapshotSourceMatch {
            guard snapshot.llmSource.commit == expectedSource.commit,
                  snapshot.llmSource.tree == expectedSource.tree,
                  expectedSource == .finalHandoff else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "final_handoff_source")
            }
        }

        let repositoryArtifacts = snapshot.artifacts.filter {
            $0.scope == .ergenticsLLMRepository
        }
        guard repositoryArtifacts.count == repositoryRoles.count else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "snapshot_repository_artifact_count")
        }
        var locations = Set<String>()
        var aggregateByteCount: UInt64 = 0
        for (artifact, expected) in zip(
            repositoryArtifacts,
            expectedSource.artifacts)
        {
            let next = aggregateByteCount.addingReportingOverflow(
                expected.byteCount)
            guard artifact.roles == [expected.role],
                  artifact.relativePath == expected.relativePath,
                  artifact.sha256 == expected.sha256,
                  artifact.byteCount == expected.byteCount,
                  artifact.actualMode == 0o444
                    || artifact.actualMode == 0o644,
                  isSafeRelativePath(expected.relativePath),
                  isGitOID(expected.gitBlobOID),
                  isSHA256(expected.sha256),
                  expected.byteCount > 0,
                  expected.byteCount <= 8_388_608,
                  !next.overflow,
                  next.partialValue <= 16_777_216,
                  locations.insert(expected.relativePath).inserted else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "snapshot_repository_artifact_\(expected.role)")
            }
            aggregateByteCount = next.partialValue
        }
    }

    static func isGitOID(_ value: String) -> Bool {
        value.count == 40 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    static func isSHA256(_ value: String) -> Bool {
        value.count == 64 && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }

    static func isSafeRelativePath(_ value: String) -> Bool {
        guard !value.isEmpty,
              !value.hasPrefix("/"),
              !value.contains("\0"),
              !value.contains("\\"),
              !value.contains("//") else {
            return false
        }
        return value.split(separator: "/", omittingEmptySubsequences: false)
            .allSatisfy { $0 != "." && $0 != ".." && !$0.isEmpty }
    }
}

private struct PrimeLatinProposalGitFileIdentityV3:
    Equatable,
    Sendable
{
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let ownerGroupID: UInt32
    let actualMode: UInt16
    let linkCount: UInt64
    let byteCount: UInt64

    init(_ metadata: stat) {
        deviceID = UInt64(bitPattern: Int64(metadata.st_dev))
        inode = UInt64(metadata.st_ino)
        ownerUserID = UInt32(metadata.st_uid)
        ownerGroupID = UInt32(metadata.st_gid)
        actualMode = UInt16(metadata.st_mode & mode_t(0o7777))
        linkCount = UInt64(metadata.st_nlink)
        byteCount = metadata.st_size >= 0
            ? UInt64(metadata.st_size)
            : UInt64.max
    }
}

private final class PrimeLatinProposalGitRootHandleV3:
    @unchecked Sendable
{
    let url: URL
    let identity: PrimeLatinProposalGitFileIdentityV3
    private let realPath: String
    private let descriptor: Int32

    init(url: URL) throws {
        guard url.isFileURL,
              url.path.hasPrefix("/"),
              !url.path.contains("\0"),
              url.standardizedFileURL.path == url.path,
              url.resolvingSymlinksInPath().standardizedFileURL.path
                == url.path else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "llm_repository_root")
        }
        var pathMetadata = stat()
        guard lstat(url.path, &pathMetadata) == 0,
              pathMetadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              pathMetadata.st_uid == geteuid(),
              pathMetadata.st_mode & mode_t(0o022) == 0 else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "llm_repository_root")
        }
        let opened = open(
            url.path,
            O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
        guard opened >= 0 else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "llm_repository_root")
        }
        var descriptorMetadata = stat()
        guard fstat(opened, &descriptorMetadata) == 0 else {
            _ = close(opened)
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "llm_repository_root")
        }
        let pathIdentity = PrimeLatinProposalGitFileIdentityV3(pathMetadata)
        let descriptorIdentity = PrimeLatinProposalGitFileIdentityV3(
            descriptorMetadata)
        guard pathIdentity == descriptorIdentity,
              descriptorIdentity.inode > 0,
              descriptorIdentity.linkCount > 0 else {
            _ = close(opened)
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "llm_repository_root")
        }
        let resolvedPath: String
        do {
            resolvedPath = try Self.resolvedRealPath(url.path)
        } catch {
            _ = close(opened)
            throw error
        }
        self.url = url
        descriptor = opened
        identity = descriptorIdentity
        realPath = resolvedPath
    }

    deinit {
        _ = close(descriptor)
    }

    func validateReboundIdentity() throws {
        guard url.standardizedFileURL.path == url.path,
              url.resolvingSymlinksInPath().standardizedFileURL.path
                == url.path else {
            throw PrimeLatinProposalGitSourceError.captureChanged
        }
        var descriptorMetadata = stat()
        var pathMetadata = stat()
        guard fstat(descriptor, &descriptorMetadata) == 0,
              lstat(url.path, &pathMetadata) == 0,
              pathMetadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              PrimeLatinProposalGitFileIdentityV3(descriptorMetadata)
                == identity,
              PrimeLatinProposalGitFileIdentityV3(pathMetadata)
                == identity else {
            throw PrimeLatinProposalGitSourceError.captureChanged
        }
    }

    func validateObservedTopLevel(_ observedPath: String) throws {
        let components = observedPath.split(
            separator: "/",
            omittingEmptySubsequences: false)
        guard observedPath.hasPrefix("/"),
              !observedPath.contains("\0"),
              components.count > 1,
              components[0].isEmpty,
              components.dropFirst().allSatisfy({
                  !$0.isEmpty && $0 != "." && $0 != ".."
              }) else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "repository_top_level")
        }
        let observedRealPath: String
        do {
            observedRealPath = try Self.resolvedRealPath(observedPath)
        } catch {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "repository_top_level")
        }
        guard observedRealPath == realPath else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "repository_top_level")
        }
        var metadata = stat()
        guard lstat(observedPath, &metadata) == 0,
              metadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFDIR),
              PrimeLatinProposalGitFileIdentityV3(metadata) == identity else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "repository_top_level")
        }
        try validateReboundIdentity()
    }

    private static func resolvedRealPath(_ path: String) throws -> String {
        guard let resolved = realpath(path, nil) else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "llm_repository_root")
        }
        defer { free(resolved) }
        return String(cString: resolved)
    }
}

private struct PrimeLatinProposalGitToolBindingV3:
    Equatable,
    Sendable
{
    let absolutePath: String
    let sha256: String
    let byteCount: UInt64
    let identity: PrimeLatinProposalGitFileIdentityV3
}

private enum PrimeLatinProposalGitToolReaderV3 {
    static func readBinding() throws -> PrimeLatinProposalGitToolBindingV3 {
        let path = PrimeLatinProposalGitContractV3.gitExecutablePath
        var pathMetadata = stat()
        guard lstat(path, &pathMetadata) == 0,
              pathMetadata.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG),
              pathMetadata.st_uid == 0,
              pathMetadata.st_mode & mode_t(0o022) == 0,
              pathMetadata.st_mode & mode_t(0o6000) == 0,
              pathMetadata.st_mode & mode_t(0o111) != 0,
              pathMetadata.st_size > 0,
              UInt64(pathMetadata.st_size)
                <= PrimeLatinProposalGitContractV3.maximumGitToolByteCount
        else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "git_tool")
        }
        let descriptor = open(path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "git_tool")
        }
        defer { _ = close(descriptor) }
        var initialMetadata = stat()
        guard fstat(descriptor, &initialMetadata) == 0,
              PrimeLatinProposalGitFileIdentityV3(initialMetadata)
                == PrimeLatinProposalGitFileIdentityV3(pathMetadata) else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "git_tool")
        }
        let data = try readAll(
            descriptor: descriptor,
            maximumByteCount:
                PrimeLatinProposalGitContractV3.maximumGitToolByteCount)
        var finalDescriptorMetadata = stat()
        var finalPathMetadata = stat()
        guard fstat(descriptor, &finalDescriptorMetadata) == 0,
              lstat(path, &finalPathMetadata) == 0,
              PrimeLatinProposalGitFileIdentityV3(finalDescriptorMetadata)
                == PrimeLatinProposalGitFileIdentityV3(initialMetadata),
              PrimeLatinProposalGitFileIdentityV3(finalPathMetadata)
                == PrimeLatinProposalGitFileIdentityV3(initialMetadata),
              UInt64(data.count) == UInt64(initialMetadata.st_size) else {
            throw PrimeLatinProposalGitSourceError.captureChanged
        }
        return PrimeLatinProposalGitToolBindingV3(
            absolutePath: path,
            sha256: PrimeLatinProposalGitHashV3.sha256(data),
            byteCount: UInt64(data.count),
            identity: PrimeLatinProposalGitFileIdentityV3(initialMetadata))
    }

    private static func readAll(
        descriptor: Int32,
        maximumByteCount: UInt64
    ) throws -> Data {
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 65_536)
        while true {
            let count: Int = buffer.withUnsafeMutableBytes { bytes in
                #if canImport(Darwin)
                return Darwin.read(
                    descriptor,
                    bytes.baseAddress,
                    bytes.count)
                #else
                return Glibc.read(
                    descriptor,
                    bytes.baseAddress,
                    bytes.count)
                #endif
            }
            if count == 0 {
                return result
            }
            if count < 0 {
                if errno == EINTR {
                    continue
                }
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "git_tool")
            }
            let next = UInt64(result.count).addingReportingOverflow(
                UInt64(count))
            guard !next.overflow,
                  next.partialValue <= maximumByteCount else {
                throw PrimeLatinProposalGitSourceError.gitOutputTooLarge(
                    "git_tool")
            }
            result.append(contentsOf: buffer.prefix(count))
        }
    }
}

private struct PrimeLatinProposalGitCommandObservationV3:
    Equatable,
    Sendable
{
    let operation: String
    let argv: [String]
    let terminationStatus: Int32
    let terminationReason: String
    let stdoutByteCount: UInt64
    let stdoutSHA256: String
    let stderrByteCount: UInt64
    let stderrSHA256: String
}

private struct PrimeLatinProposalGitTreeEntryV3:
    Equatable,
    Sendable
{
    let mode: String
    let objectType: String
    let objectID: String
}

private struct PrimeLatinProposalGitTrackedIndexInventoryV3:
    Equatable,
    Sendable
{
    let paths: [String]
    let byteCount: UInt64
    let sha256: String
}

private struct PrimeLatinProposalGitObservationStateV3:
    Equatable,
    Sendable
{
    let gitTool: PrimeLatinProposalGitToolObservationV3
    let locallyDeclaredOriginURL: String
    let objectFormat: String
    let headCommit: String
    let headTree: String
    let statusByteCount: UInt64
    let statusSHA256: String
    let trackedIndexEntryCount: UInt64
    let trackedIndexInventoryByteCount: UInt64
    let trackedIndexInventorySHA256: String
    let recomputedRawCommitGitOID: String
    let rawCommitSHA256: String
    let rawCommitByteCount: UInt64
    let artifacts: [PrimeLatinProposalGitArtifactObservationV3]
    let commandObservations: [PrimeLatinProposalGitCommandObservationV3]
}

private enum PrimeLatinProposalGitObserverV3 {
    static func observe(
        repositoryRoot: PrimeLatinProposalGitRootHandleV3,
        expectedSource: PrimeLatinProposalGitExpectedSourcePlanV3,
        snapshot: PrimeLatinProposalInputSnapshotObservationV3
    ) throws -> PrimeLatinProposalGitObservationStateV3 {
        try repositoryRoot.validateReboundIdentity()
        try PrimeLatinProposalGitContractV3.validate(
            expectedSource: expectedSource,
            snapshot: snapshot,
            requireSnapshotSourceMatch: false)
        let initialToolBinding = try PrimeLatinProposalGitToolReaderV3
            .readBinding()
        let runner = PrimeLatinProposalGitProcessRunnerV3(
            repositoryRoot: repositoryRoot.url)
        var commands = [PrimeLatinProposalGitCommandObservationV3]()

        let versionResult = try runner.run(
            operation: "git_version",
            arguments: ["--version"],
            maximumStdoutByteCount: 4_096)
        commands.append(versionResult.observation)
        let version = try singleLine(
            versionResult.stdout,
            operation: "git_version")
        guard version.hasPrefix("git version ") else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "git_version")
        }

        let topLevelResult = try runner.run(
            operation: "repository_top_level",
            arguments: ["rev-parse", "--show-toplevel"],
            maximumStdoutByteCount: 16_384)
        commands.append(topLevelResult.observation)
        let topLevel = try singleLine(
            topLevelResult.stdout,
            operation: "repository_top_level")
        try repositoryRoot.validateObservedTopLevel(topLevel)

        let originResult = try runner.run(
            operation: "local_origin_declaration",
            arguments: [
                "config",
                "--local",
                "--no-includes",
                "--get-all",
                "remote.origin.url",
            ],
            maximumStdoutByteCount: 16_384)
        commands.append(originResult.observation)
        let originURL = try singleLine(
            originResult.stdout,
            operation: "local_origin_declaration")
        guard originURL == expectedSource.locallyDeclaredOriginURL else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "locally_declared_origin")
        }

        let objectFormatResult = try runner.run(
            operation: "object_format",
            arguments: ["rev-parse", "--show-object-format"],
            maximumStdoutByteCount: 1_024)
        commands.append(objectFormatResult.observation)
        let objectFormat = try singleLine(
            objectFormatResult.stdout,
            operation: "object_format")
        guard objectFormat == PrimeLatinProposalGitContractV3
                .expectedObjectFormat else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "object_format")
        }

        let headResult = try runner.run(
            operation: "head_commit",
            arguments: ["rev-parse", "--verify", "HEAD^{commit}"],
            maximumStdoutByteCount: 1_024)
        commands.append(headResult.observation)
        let headCommit = try singleLine(
            headResult.stdout,
            operation: "head_commit")
        guard headCommit == expectedSource.commit else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "head_commit")
        }

        let treeResult = try runner.run(
            operation: "head_tree",
            arguments: ["rev-parse", "--verify", "HEAD^{tree}"],
            maximumStdoutByteCount: 1_024)
        commands.append(treeResult.observation)
        let headTree = try singleLine(
            treeResult.stdout,
            operation: "head_tree")
        guard headTree == expectedSource.tree else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "head_tree")
        }

        let statusResult = try runner.run(
            operation: "porcelain_v2_status",
            arguments: [
                "status",
                "--porcelain=v2",
                "-z",
                "--untracked-files=all",
                "--ignore-submodules=none",
            ],
            maximumStdoutByteCount:
                PrimeLatinProposalGitContractV3.maximumStatusByteCount)
        commands.append(statusResult.observation)
        let statusSHA256 = PrimeLatinProposalGitHashV3.sha256(
            statusResult.stdout)
        guard statusResult.stdout.isEmpty,
              statusSHA256
                == PrimeLatinProposalGitContractV3.expectedStatusSHA256 else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "working_tree_status")
        }

        let trackedIndexResult = try runner.run(
            operation: "tracked_index_visibility",
            arguments: ["ls-files", "-v", "-z"],
            maximumStdoutByteCount:
                PrimeLatinProposalGitContractV3
                    .maximumTrackedIndexInventoryByteCount)
        commands.append(trackedIndexResult.observation)
        let trackedIndex = try parseTrackedIndexInventory(
            trackedIndexResult.stdout)
        let trackedPaths = Set(trackedIndex.paths)
        guard expectedSource.artifacts.allSatisfy({
            trackedPaths.contains($0.relativePath)
        }) else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "tracked_index_visibility")
        }
        if expectedSource == .finalHandoff {
            guard UInt64(trackedIndex.paths.count)
                    == PrimeLatinProposalGitContractV3
                        .finalTrackedIndexEntryCount,
                  trackedIndex.byteCount
                    == PrimeLatinProposalGitContractV3
                        .finalTrackedIndexInventoryByteCount,
                  trackedIndex.sha256
                    == PrimeLatinProposalGitContractV3
                        .finalTrackedIndexInventorySHA256 else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "tracked_index_visibility")
            }
        }

        let rawCommitResult = try runner.run(
            operation: "raw_commit",
            arguments: ["cat-file", "commit", expectedSource.commit],
            maximumStdoutByteCount: incremented(
                expectedSource.rawCommitByteCount))
        commands.append(rawCommitResult.observation)
        let rawCommitSHA256 = PrimeLatinProposalGitHashV3.sha256(
            rawCommitResult.stdout)
        let recomputedCommitOID = PrimeLatinProposalGitHashV3.gitOID(
            type: "commit",
            data: rawCommitResult.stdout)
        guard UInt64(rawCommitResult.stdout.count)
                == expectedSource.rawCommitByteCount,
              rawCommitSHA256 == expectedSource.rawCommitSHA256,
              recomputedCommitOID == expectedSource.commit else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "raw_commit")
        }

        let inventoryResult = try runner.run(
            operation: "seven_path_tree_inventory",
            arguments:
                [
                    "ls-tree",
                    "-z",
                    "--full-tree",
                    expectedSource.tree,
                    "--",
                ] + expectedSource.artifacts.map(\.relativePath),
            maximumStdoutByteCount:
                PrimeLatinProposalGitContractV3
                    .maximumTreeInventoryByteCount)
        commands.append(inventoryResult.observation)
        let treeEntries = try parseTreeEntries(inventoryResult.stdout)
        guard treeEntries.count == expectedSource.artifacts.count else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "seven_path_tree_inventory")
        }

        var artifacts = [PrimeLatinProposalGitArtifactObservationV3]()
        artifacts.reserveCapacity(expectedSource.artifacts.count)
        for expected in expectedSource.artifacts {
            guard let entry = treeEntries[expected.relativePath],
                  entry.mode == "100644",
                  entry.objectType == "blob",
                  entry.objectID == expected.gitBlobOID else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "tree_entry_\(expected.role)")
            }
            let blobResult = try runner.run(
                operation: "blob_\(expected.role)",
                arguments: [
                    "cat-file",
                    "blob",
                    expected.gitBlobOID,
                ],
                maximumStdoutByteCount: incremented(expected.byteCount))
            commands.append(blobResult.observation)
            let artifact = PrimeLatinProposalGitArtifactObservationV3(
                expectation: expected,
                mode: entry.mode,
                objectType: entry.objectType,
                observedBlobData: blobResult.stdout)
            guard artifact.recomputedGitBlobOID == expected.gitBlobOID,
                  artifact.observedBlobSHA256 == expected.sha256,
                  artifact.observedBlobByteCount == expected.byteCount,
                  artifact.snapshotSHA256 == expected.sha256,
                  artifact.snapshotByteCount == expected.byteCount else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "blob_\(expected.role)")
            }
            artifacts.append(artifact)
        }

        let finalToolBinding = try PrimeLatinProposalGitToolReaderV3
            .readBinding()
        try repositoryRoot.validateReboundIdentity()
        guard initialToolBinding == finalToolBinding else {
            throw PrimeLatinProposalGitSourceError.captureChanged
        }
        let toolObservation = PrimeLatinProposalGitToolObservationV3(
            binding: finalToolBinding,
            version: version,
            versionData: versionResult.stdout)
        return PrimeLatinProposalGitObservationStateV3(
            gitTool: toolObservation,
            locallyDeclaredOriginURL: originURL,
            objectFormat: objectFormat,
            headCommit: headCommit,
            headTree: headTree,
            statusByteCount: UInt64(statusResult.stdout.count),
            statusSHA256: statusSHA256,
            trackedIndexEntryCount: UInt64(trackedIndex.paths.count),
            trackedIndexInventoryByteCount: trackedIndex.byteCount,
            trackedIndexInventorySHA256: trackedIndex.sha256,
            recomputedRawCommitGitOID: recomputedCommitOID,
            rawCommitSHA256: rawCommitSHA256,
            rawCommitByteCount: UInt64(rawCommitResult.stdout.count),
            artifacts: artifacts,
            commandObservations: commands)
    }

    private static func singleLine(
        _ data: Data,
        operation: String
    ) throws -> String {
        guard data.last == 0x0a,
              data.count > 1,
              !data.dropLast().contains(0x0a),
              !data.dropLast().contains(0x0d),
              !data.dropLast().contains(0),
              let value = String(
                data: Data(data.dropLast()),
                encoding: .utf8),
              !value.isEmpty else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                operation)
        }
        return value
    }

    private static func parseTrackedIndexInventory(
        _ data: Data
    ) throws -> PrimeLatinProposalGitTrackedIndexInventoryV3 {
        guard !data.isEmpty,
              UInt64(data.count)
                <= PrimeLatinProposalGitContractV3
                    .maximumTrackedIndexInventoryByteCount,
              data.last == 0 else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "tracked_index_visibility")
        }
        let records = data.split(
            separator: 0,
            omittingEmptySubsequences: false)
        guard records.count > 1,
              records.last?.isEmpty == true else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "tracked_index_visibility")
        }
        let nonterminalRecords = records.dropLast()
        guard !nonterminalRecords.isEmpty,
              UInt64(nonterminalRecords.count)
                <= PrimeLatinProposalGitContractV3
                    .maximumTrackedIndexEntryCount else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "tracked_index_visibility")
        }
        var paths = [String]()
        paths.reserveCapacity(nonterminalRecords.count)
        var uniquePaths = Set<String>()
        for record in nonterminalRecords {
            guard record.count > 2,
                  record[record.startIndex] == UInt8(ascii: "H"),
                  record[record.index(after: record.startIndex)]
                    == UInt8(ascii: " ") else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "tracked_index_visibility")
            }
            let pathStart = record.index(
                record.startIndex,
                offsetBy: 2)
            guard let path = String(
                    data: Data(record[pathStart...]),
                    encoding: .utf8),
                  PrimeLatinProposalGitContractV3.isSafeRelativePath(path),
                  path.unicodeScalars.allSatisfy({ scalar in
                      let value = scalar.value
                      return value >= 0x20
                        && value != 0x7f
                        && !(0x80...0x9f).contains(value)
                        && value != 0x2028
                        && value != 0x2029
                  }),
                  uniquePaths.insert(path).inserted else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "tracked_index_visibility")
            }
            paths.append(path)
        }
        return PrimeLatinProposalGitTrackedIndexInventoryV3(
            paths: paths,
            byteCount: UInt64(data.count),
            sha256: PrimeLatinProposalGitHashV3.sha256(data))
    }

    private static func parseTreeEntries(
        _ data: Data
    ) throws -> [String: PrimeLatinProposalGitTreeEntryV3] {
        guard !data.isEmpty,
              data.last == 0 else {
            throw PrimeLatinProposalGitSourceError.invalidObservation(
                "seven_path_tree_inventory")
        }
        var entries = [String: PrimeLatinProposalGitTreeEntryV3]()
        for record in data.split(separator: 0) {
            guard let tab = record.firstIndex(of: UInt8(ascii: "\t")),
                  let header = String(
                    data: Data(record[..<tab]),
                    encoding: .utf8),
                  let path = String(
                    data: Data(record[record.index(after: tab)...]),
                    encoding: .utf8) else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "seven_path_tree_inventory")
            }
            let headerFields = header.split(
                separator: " ",
                omittingEmptySubsequences: false)
            guard headerFields.count == 3,
                  PrimeLatinProposalGitContractV3
                    .isSafeRelativePath(path),
                  entries[path] == nil else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "seven_path_tree_inventory")
            }
            let entry = PrimeLatinProposalGitTreeEntryV3(
                mode: String(headerFields[0]),
                objectType: String(headerFields[1]),
                objectID: String(headerFields[2]))
            guard PrimeLatinProposalGitContractV3.isGitOID(
                entry.objectID) else {
                throw PrimeLatinProposalGitSourceError.invalidObservation(
                    "seven_path_tree_inventory")
            }
            entries[path] = entry
        }
        return entries
    }

    private static func incremented(_ value: UInt64) -> UInt64 {
        let next = value.addingReportingOverflow(1)
        return next.overflow ? UInt64.max : next.partialValue
    }
}

private struct PrimeLatinProposalGitProcessResultV3 {
    let stdout: Data
    let observation: PrimeLatinProposalGitCommandObservationV3
}

private final class PrimeLatinProposalGitCaptureBoxV3:
    @unchecked Sendable
{
    private let maximumByteCount: UInt64
    private let lock = NSLock()
    private var bytes = Data()
    private var totalByteCount: UInt64 = 0
    private var overflowed = false

    init(maximumByteCount: UInt64) {
        self.maximumByteCount = maximumByteCount
    }

    func drain(_ handle: FileHandle) {
        defer { try? handle.close() }
        while true {
            do {
                guard let chunk = try handle.read(upToCount: 65_536),
                      !chunk.isEmpty else {
                    return
                }
                lock.lock()
                let next = totalByteCount.addingReportingOverflow(
                    UInt64(chunk.count))
                if next.overflow {
                    totalByteCount = UInt64.max
                    overflowed = true
                } else {
                    totalByteCount = next.partialValue
                }
                let remaining = maximumByteCount > UInt64(bytes.count)
                    ? maximumByteCount - UInt64(bytes.count)
                    : 0
                if remaining > 0 {
                    bytes.append(
                        chunk.prefix(Int(min(remaining, UInt64(Int.max)))))
                }
                if totalByteCount > maximumByteCount {
                    overflowed = true
                }
                lock.unlock()
            } catch {
                lock.lock()
                overflowed = true
                lock.unlock()
                return
            }
        }
    }

    func snapshot() -> (
        data: Data,
        totalByteCount: UInt64,
        overflowed: Bool
    ) {
        lock.lock()
        defer { lock.unlock() }
        return (bytes, totalByteCount, overflowed)
    }
}

private struct PrimeLatinProposalGitProcessRunnerV3 {
    let repositoryRoot: URL

    func run(
        operation: String,
        arguments: [String],
        maximumStdoutByteCount: UInt64
    ) throws -> PrimeLatinProposalGitProcessResultV3 {
        let process = Process()
        process.executableURL = URL(
            fileURLWithPath:
                PrimeLatinProposalGitContractV3.gitExecutablePath)
        let actualArguments = [
            "--no-replace-objects",
            "-c",
            "core.fsmonitor=false",
            "-c",
            "core.fileMode=true",
            "-c",
            "core.hooksPath=/dev/null",
            "-C",
            repositoryRoot.path,
        ] + arguments
        process.arguments = actualArguments
        process.environment = [
            "GIT_NO_REPLACE_OBJECTS": "1",
            "GIT_NO_LAZY_FETCH": "1",
            "GIT_ALLOW_PROTOCOL": "none",
            "GIT_OPTIONAL_LOCKS": "0",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_CONFIG_GLOBAL": "/dev/null",
            "GIT_CONFIG_SYSTEM": "/dev/null",
            "GIT_TERMINAL_PROMPT": "0",
            "GIT_PAGER": "",
            "PAGER": "",
            "GIT_FLUSH": "1",
            "LC_ALL": "C",
            "LANG": "C",
            "TMPDIR": "/private/tmp",
        ]
        process.currentDirectoryURL = URL(fileURLWithPath: "/")
        guard let standardInput = FileHandle(
            forReadingAtPath: "/dev/null") else {
            throw PrimeLatinProposalGitSourceError.gitProcessFailed(
                operation)
        }
        process.standardInput = standardInput
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        let stdoutCapture = PrimeLatinProposalGitCaptureBoxV3(
            maximumByteCount: maximumStdoutByteCount)
        let stderrCapture = PrimeLatinProposalGitCaptureBoxV3(
            maximumByteCount:
                PrimeLatinProposalGitContractV3.maximumStderrByteCount)
        let captureGroup = DispatchGroup()
        let termination = DispatchSemaphore(value: 0)
        process.terminationHandler = { _ in termination.signal() }

        do {
            try process.run()
        } catch {
            try? standardInput.close()
            try? stdoutPipe.fileHandleForWriting.close()
            try? stderrPipe.fileHandleForWriting.close()
            throw PrimeLatinProposalGitSourceError.gitProcessFailed(
                operation)
        }
        try? standardInput.close()
        try? stdoutPipe.fileHandleForWriting.close()
        try? stderrPipe.fileHandleForWriting.close()

        captureGroup.enter()
        DispatchQueue.global(qos: .utility).async {
            stdoutCapture.drain(stdoutPipe.fileHandleForReading)
            captureGroup.leave()
        }
        captureGroup.enter()
        DispatchQueue.global(qos: .utility).async {
            stderrCapture.drain(stderrPipe.fileHandleForReading)
            captureGroup.leave()
        }

        let waitResult = termination.wait(
            timeout: .now()
                + PrimeLatinProposalGitContractV3.processTimeoutSeconds)
        if waitResult == .timedOut {
            process.terminate()
            if termination.wait(
                timeout: .now()
                    + PrimeLatinProposalGitContractV3
                        .processTerminationGraceSeconds) == .timedOut
            {
                #if canImport(Darwin)
                _ = Darwin.kill(process.processIdentifier, SIGKILL)
                #else
                _ = Glibc.kill(process.processIdentifier, SIGKILL)
                #endif
                _ = termination.wait(
                    timeout: .now()
                        + PrimeLatinProposalGitContractV3
                            .processTerminationGraceSeconds)
            }
            _ = finishCaptures(
                captureGroup,
                stdoutPipe: stdoutPipe,
                stderrPipe: stderrPipe)
            throw PrimeLatinProposalGitSourceError.gitProcessTimedOut(
                operation)
        }
        guard finishCaptures(
            captureGroup,
            stdoutPipe: stdoutPipe,
            stderrPipe: stderrPipe) else {
            throw PrimeLatinProposalGitSourceError.gitProcessTimedOut(
                operation)
        }

        let stdout = stdoutCapture.snapshot()
        let stderr = stderrCapture.snapshot()
        guard !stdout.overflowed,
              !stderr.overflowed else {
            throw PrimeLatinProposalGitSourceError.gitOutputTooLarge(
                operation)
        }
        let reason: String
        switch process.terminationReason {
        case .exit:
            reason = "exit"
        case .uncaughtSignal:
            reason = "uncaught_signal"
        @unknown default:
            reason = "unknown"
        }
        let normalizedArguments = actualArguments.map {
            $0 == repositoryRoot.path ? "<repository-root>" : $0
        }
        let observation = PrimeLatinProposalGitCommandObservationV3(
            operation: operation,
            argv: normalizedArguments,
            terminationStatus: process.terminationStatus,
            terminationReason: reason,
            stdoutByteCount: stdout.totalByteCount,
            stdoutSHA256: PrimeLatinProposalGitHashV3.sha256(stdout.data),
            stderrByteCount: stderr.totalByteCount,
            stderrSHA256: PrimeLatinProposalGitHashV3.sha256(stderr.data))
        guard process.terminationReason == .exit,
              process.terminationStatus == 0,
              stderr.totalByteCount == 0 else {
            throw PrimeLatinProposalGitSourceError.gitProcessFailed(
                operation)
        }
        return PrimeLatinProposalGitProcessResultV3(
            stdout: stdout.data,
            observation: observation)
    }

    private func finishCaptures(
        _ group: DispatchGroup,
        stdoutPipe: Pipe,
        stderrPipe: Pipe
    ) -> Bool {
        if group.wait(
            timeout: .now()
                + PrimeLatinProposalGitContractV3
                    .processTerminationGraceSeconds) == .success
        {
            return true
        }
        try? stdoutPipe.fileHandleForReading.close()
        try? stderrPipe.fileHandleForReading.close()
        _ = group.wait(
            timeout: .now()
                + PrimeLatinProposalGitContractV3
                    .processTerminationGraceSeconds)
        return false
    }
}

private enum PrimeLatinProposalGitHashV3 {
    static func sha256(_ data: Data) -> String {
        hex(SHA256.hash(data: data))
    }

    static func gitOID(type: String, data: Data) -> String {
        var object = Data("\(type) \(data.count)\0".utf8)
        object.append(data)
        return hex(Insecure.SHA1.hash(data: object))
    }

    private static func hex<D: Sequence>(_ digest: D) -> String
    where D.Element == UInt8 {
        digest.map { String(format: "%02x", $0) }.joined()
    }
}
