#if canImport(Darwin)
import Darwin
#else
import Glibc
#endif
import CryptoKit
import Compression
import Foundation
import PrimeLatinProposalGitObservation
import PrimeLatinProposalPairCapture

public enum PrimeLatinProposalProducerRevalidationError:
    Error,
    Equatable,
    Sendable
{
    case invalidRequest(String)
    case unsafeFileSystemEntry(String)
    case invalidToolSource(String)
    case buildFailed(String)
    case processFailed(String)
    case processTimedOut(String)
    case processOutputTooLarge(String)
    case invalidRevalidationObservation(String)
    case captureChanged
}

public struct PrimeLatinProposalProducerRevalidationRequestV1:
    Equatable,
    Sendable
{
    public let labRoot: URL
    public let producerRepositoryRoot: URL
    public let toolRepositoryRoot: URL
    public let scratchParent: URL

    public init(
        labRoot: URL,
        producerRepositoryRoot: URL,
        toolRepositoryRoot: URL,
        scratchParent: URL
    ) throws {
        self.labRoot = try Self.requireCanonicalAbsoluteRoot(
            labRoot,
            field: "lab_root")
        self.producerRepositoryRoot = try Self.requireCanonicalAbsoluteRoot(
            producerRepositoryRoot,
            field: "producer_repository_root")
        self.toolRepositoryRoot = try Self.requireCanonicalAbsoluteRoot(
            toolRepositoryRoot,
            field: "tool_repository_root")
        self.scratchParent = try Self.requireCanonicalAbsoluteRoot(
            scratchParent,
            field: "scratch_parent")
        let paths = [
            self.labRoot.path,
            self.producerRepositoryRoot.path,
            self.toolRepositoryRoot.path,
            self.scratchParent.path,
        ]
        guard Set(paths).count == paths.count,
              !Self.pathsOverlap(
                self.labRoot.path,
                self.producerRepositoryRoot.path),
              !Self.pathsOverlap(
                self.labRoot.path,
                self.toolRepositoryRoot.path),
              !Self.pathsOverlap(
                self.producerRepositoryRoot.path,
                self.toolRepositoryRoot.path),
              !Self.pathsOverlap(
                self.scratchParent.path,
                self.labRoot.path),
              !Self.pathsOverlap(
                self.scratchParent.path,
                self.producerRepositoryRoot.path),
              !Self.pathsOverlap(
                self.scratchParent.path,
                self.toolRepositoryRoot.path)
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRequest("distinct_nonoverlapping_roots")
        }
    }

    private static func requireCanonicalAbsoluteRoot(
        _ value: URL,
        field: String
    ) throws -> URL {
        guard value.isFileURL,
              !value.path.isEmpty,
              value.path.hasPrefix("/"),
              value.path != "/",
              !value.path.utf8.contains(0),
              !value.path.hasSuffix("/"),
              !value.path.contains("//"),
              !value.path.contains("/./"),
              !value.path.contains("/../"),
              !value.path.hasSuffix("/.."),
              value.pathComponents.allSatisfy({ $0 != "." && $0 != ".." })
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRequest(field)
        }
        return value
    }

    private static func pathsOverlap(_ first: String, _ second: String) -> Bool {
        first == second
            || first.hasPrefix(second + "/")
            || second.hasPrefix(first + "/")
    }
}

public struct PrimeLatinProposalProducerRevalidationArtifactObservationV1:
    Equatable,
    Sendable
{
    public let role: String
    public let relativePath: String
    public let gitBlobOID: String
    public let sha256: String
    public let byteCount: UInt64

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

public struct PrimeLatinProposalProducerRevalidationSourceObservationV1:
    Equatable,
    Sendable
{
    public let repository: String
    public let locallyDeclaredOriginURL: String
    public let originObservationScope: String
    public let commit: String
    public let tree: String
    public let parentCommit: String
    public let rawCommitSHA256: String
    public let rawCommitByteCount: UInt64
    public let trackedIndexEntryCount: UInt64
    public let trackedIndexInventorySHA256: String
    public let trackedIndexInventoryByteCount: UInt64
    public let artifacts:
        [PrimeLatinProposalProducerRevalidationArtifactObservationV1]

    init(
        repository: String,
        locallyDeclaredOriginURL: String,
        originObservationScope: String,
        commit: String,
        tree: String,
        parentCommit: String,
        rawCommitSHA256: String,
        rawCommitByteCount: UInt64,
        trackedIndexEntryCount: UInt64,
        trackedIndexInventorySHA256: String,
        trackedIndexInventoryByteCount: UInt64,
        artifacts:
            [PrimeLatinProposalProducerRevalidationArtifactObservationV1]
    ) {
        self.repository = repository
        self.locallyDeclaredOriginURL = locallyDeclaredOriginURL
        self.originObservationScope = originObservationScope
        self.commit = commit
        self.tree = tree
        self.parentCommit = parentCommit
        self.rawCommitSHA256 = rawCommitSHA256
        self.rawCommitByteCount = rawCommitByteCount
        self.trackedIndexEntryCount = trackedIndexEntryCount
        self.trackedIndexInventorySHA256 = trackedIndexInventorySHA256
        self.trackedIndexInventoryByteCount = trackedIndexInventoryByteCount
        self.artifacts = artifacts
    }
}

public struct PrimeLatinProposalProducerRevalidationToolObservationV1:
    Equatable,
    Sendable
{
    public let role: String
    public let absolutePath: String
    public let sha256: String
    public let byteCount: UInt64
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let actualMode: UInt16

    init(role: String, file: PrimeLatinProposalProducerRevalidationFileStateV1) {
        self.role = role
        absolutePath = file.absolutePath
        sha256 = file.sha256
        byteCount = file.byteCount
        deviceID = file.deviceID
        inode = file.inode
        ownerUserID = file.ownerUserID
        actualMode = file.actualMode
    }
}

public struct PrimeLatinProposalProducerRevalidationBuildObservationV1:
    Equatable,
    Sendable
{
    public let buildPolicyID: String
    public let compilerLauncher:
        PrimeLatinProposalProducerRevalidationToolObservationV1
    public let compiler:
        PrimeLatinProposalProducerRevalidationToolObservationV1
    public let compilerIdentityScope: String
    public let compileCommandCount: UInt64
    public let processLaunchCount: UInt64
    public let governanceArtifactCount: UInt64
    public let compilerInputSourceCount: UInt64
    public let executable:
        PrimeLatinProposalProducerRevalidationToolObservationV1
}

public struct PrimeLatinProposalProducerRevalidationProcessObservationV1:
    Equatable,
    Sendable
{
    public let processPolicyID: String
    public let invocationCount: UInt64
    public let standardOutputSHA256: String
    public let standardOutputByteCount: UInt64
    public let standardErrorSHA256: String
    public let standardErrorByteCount: UInt64
}

public struct PrimeLatinProposalProducerRevalidationAuthorityBoundaryV1:
    Equatable,
    Sendable
{
    public let disposition: String
    public let pairCaptureAndRecaptureComplete: Bool
    public let inputSnapshotCaptureAndRecaptureComplete: Bool
    public let producerGitObservationComplete: Bool
    public let exactMergedRevalidatorSourceObserved: Bool
    public let exactRevalidatorSourceClosureObserved: Bool
    public let compilerIdentityObserved: Bool
    public let compilerCryptographicallyAuthenticated: Bool
    public let localExactSourceClosureBuildObserved: Bool
    public let externalSourceToBinaryAttestationAvailable: Bool
    public let revalidatorExecutableBuiltFromObservedSourceClosure: Bool
    public let revalidatorExecutableIdentityStable: Bool
    public let boundedFreshProcessObservationComplete: Bool
    public let canonicalRevalidationObservationDecoded: Bool
    public let expectedPairReceiptCrossBindingValidated: Bool
    public let exactTwentyOneInputBindingsCrossBound: Bool
    public let canonicalHashChainCrossBindingsMatched: Bool
    public let repeatedProducerProcessObservationUnchanged: Bool
    public let outputNamespaceAbsenceVerified: Bool
    public let llmGitStateIndependentlyObserved: Bool
    public let revalidatorToolSourceIndependentlyObserved: Bool
    public let liveProducerWorkspaceRevalidationComplete: Bool
    public let originRemoteCryptographicallyAuthenticated: Bool
    public let ignoredWorkspaceBytesObserved: Bool
    public let durableInputSnapshotPublished: Bool
    public let durableGitObservationPublished: Bool
    public let durableRevalidationObservationPublished: Bool
    public let independentPrimeReplayComplete: Bool
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
    public let proposalPairPublicationPerformedByThisObservation: Bool
    public let primeDurableReceiptPublished: Bool

    init() {
        disposition =
            "abstain_producer_revalidation_observation_complete_requires_independent_prime_replay"
        pairCaptureAndRecaptureComplete = true
        inputSnapshotCaptureAndRecaptureComplete = true
        producerGitObservationComplete = true
        exactMergedRevalidatorSourceObserved = true
        exactRevalidatorSourceClosureObserved = true
        compilerIdentityObserved = true
        compilerCryptographicallyAuthenticated = false
        localExactSourceClosureBuildObserved = true
        externalSourceToBinaryAttestationAvailable = false
        revalidatorExecutableBuiltFromObservedSourceClosure = true
        revalidatorExecutableIdentityStable = true
        boundedFreshProcessObservationComplete = true
        canonicalRevalidationObservationDecoded = true
        expectedPairReceiptCrossBindingValidated = true
        exactTwentyOneInputBindingsCrossBound = true
        canonicalHashChainCrossBindingsMatched = true
        repeatedProducerProcessObservationUnchanged = true
        outputNamespaceAbsenceVerified = true
        llmGitStateIndependentlyObserved = true
        revalidatorToolSourceIndependentlyObserved = true
        liveProducerWorkspaceRevalidationComplete = true
        originRemoteCryptographicallyAuthenticated = false
        ignoredWorkspaceBytesObserved = false
        durableInputSnapshotPublished = false
        durableGitObservationPublished = false
        durableRevalidationObservationPublished = false
        independentPrimeReplayComplete = false
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
        proposalPairPublicationPerformedByThisObservation = false
        primeDurableReceiptPublished = false
    }
}

public struct PrimeLatinProposalProducerRevalidationObservationV1:
    Equatable,
    Sendable
{
    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let pairReceiptSHA256: String
    public let producerRepository: String
    public let producerCommit: String
    public let producerTree: String
    public let toolSource:
        PrimeLatinProposalProducerRevalidationSourceObservationV1
    public let candidateCatalogSHA256: String
    public let candidateCatalogByteCount: UInt64
    public let experimentManifestSHA256: String
    public let experimentManifestByteCount: UInt64
    public let candidateDeclarationSetSHA256: String
    public let candidateDeclarationSetByteCount: UInt64
    public let tokenizerBundleSHA256: String
    public let tokenizerBundleByteCount: UInt64
    public let candidateIDs: [String]
    public let candidateIdentitySHA256s: [String]
    public let declarationBundleSHA256s: [String]
    public let inputBindingCount: UInt64
    public let optimizerSteps: UInt64
    public let trainingTokens: UInt64
    public let wallClockSeconds: UInt64
    public let outputNamespace: String
    public let build:
        PrimeLatinProposalProducerRevalidationBuildObservationV1
    public let process:
        PrimeLatinProposalProducerRevalidationProcessObservationV1
    public let authority:
        PrimeLatinProposalProducerRevalidationAuthorityBoundaryV1

    init(
        toolSource: PrimeLatinProposalProducerRevalidationSourceObservationV1,
        child: PrimeLatinProposalProducerRevalidationChildObservationV1,
        build: PrimeLatinProposalProducerRevalidationBuildObservationV1,
        process: PrimeLatinProposalProducerRevalidationProcessObservationV1
    ) {
        schema =
            "ergentics_prime_latin_proposal_v3_producer_revalidation_observation_v1"
        outcome = "abstain"
        verificationScope =
            "prime_built_exact_merged_revalidator_source_closure_and_observed_two_cross_bound_live_producer_processes_only_non_authorizing"
        pairReceiptSHA256 = child.expectedPairReceiptSHA256
        producerRepository = child.llmSource.repository
        producerCommit = child.llmSource.commit
        producerTree = child.llmSource.tree
        self.toolSource = toolSource
        candidateCatalogSHA256 = child.candidateCatalogSHA256
        candidateCatalogByteCount = child.candidateCatalogByteCount
        experimentManifestSHA256 = child.experimentManifestSHA256
        experimentManifestByteCount = child.experimentManifestByteCount
        candidateDeclarationSetSHA256 = child.candidateDeclarationSetSHA256
        candidateDeclarationSetByteCount = child.candidateDeclarationSetByteCount
        tokenizerBundleSHA256 = child.tokenizerBundleSHA256
        tokenizerBundleByteCount = child.tokenizerBundleByteCount
        candidateIDs = child.candidateIDs
        candidateIdentitySHA256s = child.candidateIdentitySHA256s
        declarationBundleSHA256s = child.declarationBundleSHA256s
        inputBindingCount = UInt64(child.inputBindings.count)
        optimizerSteps = child.requestedTrialBudget.optimizerSteps
        trainingTokens = child.requestedTrialBudget.trainingTokens
        wallClockSeconds = child.requestedTrialBudget.wallClockSeconds
        outputNamespace = child.outputNamespace
        self.build = build
        self.process = process
        authority = PrimeLatinProposalProducerRevalidationAuthorityBoundaryV1()
    }
}

struct PrimeLatinProposalProducerRevalidationChildSourceV1:
    Codable,
    Equatable,
    Sendable
{
    let repository: String
    let commit: String
    let tree: String
}

struct PrimeLatinProposalProducerRevalidationChildBindingV1:
    Codable,
    Equatable,
    Sendable
{
    let role: String
    let scope: String
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
    let gitBlobOID: String?
}

struct PrimeLatinProposalProducerRevalidationChildBudgetV1:
    Codable,
    Equatable,
    Sendable
{
    let application: String
    let optimizerSteps: UInt64
    let trainingTokens: UInt64
    let wallClockSeconds: UInt64
}

struct PrimeLatinProposalProducerRevalidationChildAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    let disposition: String
    let exactFinalRequestValidated: Bool
    let exactProducerWorkspaceSourceObserved: Bool
    let exactTwentyOneInputBindingsReconstructed: Bool
    let publicTokenizerFactoryReconstructionComplete: Bool
    let publicCandidateDeclarationFactoryReconstructionComplete: Bool
    let publicCandidateCatalogFactoryReconstructionComplete: Bool
    let publicExperimentManifestFactoryReconstructionComplete: Bool
    let canonicalHashChainRecomputationComplete: Bool
    let liveProducerWorkspaceRevalidationComplete: Bool
    let repeatedLiveRevalidationUnchanged: Bool
    let outputNamespaceAbsenceVerified: Bool
    let expectedPairReceiptCrossBindingValidated: Bool
    let revalidatorToolSourceIndependentlyObserved: Bool
    let referencedInputSnapshotPublished: Bool
    let referencedArtifactBytesPublished: Bool
    let independentPrimeReplayComplete: Bool
    let runtimeDecoderImplementationAvailable: Bool
    let runtimeDependencyClosureEstablished: Bool
    let runtimeInitializationEstablished: Bool
    let primeProposalPacketProduced: Bool
    let primeTrialAuthorizationProduced: Bool
    let primeDecisionReceiptProduced: Bool
    let candidateSelectionAuthorized: Bool
    let trialExecutionAuthorized: Bool
    let furtherTrainingAuthorized: Bool
    let promotionAuthorized: Bool
    let productUseAuthorized: Bool
    let publicationAuthorized: Bool
    let proposalPairPublicationPerformed: Bool
    let durableRevalidationObservationPublished: Bool
    let primeDurableReceiptPublished: Bool

    var isExact: Bool {
        disposition
            == "abstain_live_producer_revalidation_complete_requires_independent_prime_replay"
            && exactFinalRequestValidated
            && exactProducerWorkspaceSourceObserved
            && exactTwentyOneInputBindingsReconstructed
            && publicTokenizerFactoryReconstructionComplete
            && publicCandidateDeclarationFactoryReconstructionComplete
            && publicCandidateCatalogFactoryReconstructionComplete
            && publicExperimentManifestFactoryReconstructionComplete
            && canonicalHashChainRecomputationComplete
            && liveProducerWorkspaceRevalidationComplete
            && repeatedLiveRevalidationUnchanged
            && outputNamespaceAbsenceVerified
            && expectedPairReceiptCrossBindingValidated
            && !revalidatorToolSourceIndependentlyObserved
            && !referencedInputSnapshotPublished
            && !referencedArtifactBytesPublished
            && !independentPrimeReplayComplete
            && !runtimeDecoderImplementationAvailable
            && !runtimeDependencyClosureEstablished
            && !runtimeInitializationEstablished
            && !primeProposalPacketProduced
            && !primeTrialAuthorizationProduced
            && !primeDecisionReceiptProduced
            && !candidateSelectionAuthorized
            && !trialExecutionAuthorized
            && !furtherTrainingAuthorized
            && !promotionAuthorized
            && !productUseAuthorized
            && !publicationAuthorized
            && !proposalPairPublicationPerformed
            && !durableRevalidationObservationPublished
            && !primeDurableReceiptPublished
    }
}

struct PrimeLatinProposalProducerRevalidationChildObservationV1:
    Codable,
    Equatable,
    Sendable
{
    let schema: String
    let outcome: String
    let verificationScope: String
    let revalidationStatus: String
    let revalidatorToolSourceIdentityStatus: String
    let expectedPairReceiptSHA256: String
    let pairReceiptObservationStatus: String
    let llmSource: PrimeLatinProposalProducerRevalidationChildSourceV1
    let candidateCatalogSHA256: String
    let candidateCatalogByteCount: UInt64
    let experimentManifestSHA256: String
    let experimentManifestByteCount: UInt64
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let candidateIDs: [String]
    let candidateIdentitySHA256s: [String]
    let declarationBundleSHA256s: [String]
    let inputBindings:
        [PrimeLatinProposalProducerRevalidationChildBindingV1]
    let requestedTrialBudget:
        PrimeLatinProposalProducerRevalidationChildBudgetV1
    let outputNamespace: String
    let catalogAuthorityStatus: String
    let catalogPublicationStatus: String
    let experimentPublicationStatus: String
    let authority: PrimeLatinProposalProducerRevalidationChildAuthorityV1
}

private struct PrimeLatinProposalProducerRevalidationExpectedPlanV1 {
    static let pairSHA256 =
        "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7"
    static let producerRepository = "Ergentics/ergentics-llm"
    static let producerCommit =
        "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831"
    static let producerTree =
        "c1f41758aea2860ab06039776f5ea0403dff1b61"
    static let toolCommit =
        "1ccfb6bf6718e2378f14ab87cacae1ada303cf48"
    static let toolTree =
        "6ee438bf1132d26767fbf447355b8165455b956f"
    static let toolParent = producerCommit
    static let toolOrigin =
        "https://github.com/Ergentics/ergentics-llm.git"
    static let toolRawCommitSHA256 =
        "380c13a3f9f3421db875d2ccc3c4547002374a9d74427a0573e0c59f6d3078ac"
    static let toolRawCommitByteCount: UInt64 = 1_328
    static let trackedIndexEntryCount: UInt64 = 147
    static let trackedIndexInventorySHA256 =
        "802f7505ad91869b27420e0beb152e6ba725eb82a801b4fd9289d999afac0c81"
    static let trackedIndexInventoryByteCount: UInt64 = 14_281
    static let candidateCatalogSHA256 =
        "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4"
    static let candidateCatalogByteCount: UInt64 = 20_803
    static let experimentManifestSHA256 =
        "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76"
    static let experimentManifestByteCount: UInt64 = 3_364
    static let candidateDeclarationSetSHA256 =
        "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881"
    static let candidateDeclarationSetByteCount: UInt64 = 14_860
    static let tokenizerBundleSHA256 =
        "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c"
    static let tokenizerBundleByteCount: UInt64 = 2_930
    static let candidateIDs = ["latin_structural_fixture_v1"]
    static let candidateIdentitySHA256s = [
        "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265",
    ]
    static let declarationBundleSHA256s = [
        "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd",
    ]
    static let outputNamespace =
        "models/latin-prospective/structural-fixture-v3-776c412e"
    static let canonicalProbeOutputSHA256 =
        "0657289657fbb99ca91ad9b1788ccfbe9b1697881cef85df6241ab30b0bf984f"
    static let canonicalProbeOutputByteCount: UInt64 = 8_434

    static let toolArtifacts = [
        PrimeLatinProposalProducerRevalidationArtifactObservationV1(
            role: "isolated_package_manifest",
            relativePath: ".github/scripts/latin-proposal-artifacts.Package.swift",
            gitBlobOID: "9617fac7d88afb2bf33df7324ab15efa1a5a94aa",
            sha256:
                "136a65f9f574b6a1f3a6e25d4fed66e9b859e536c55b8f28f8a6dd4797d64bd6",
            byteCount: 1_463),
        PrimeLatinProposalProducerRevalidationArtifactObservationV1(
            role: "proposal_artifact_source",
            relativePath:
                "Sources/ErgenticsLatinProposalArtifacts/ErgenticsLatinProposalArtifacts.swift",
            gitBlobOID: "302ccde06959cc6ffb411d455ad656c9e50e4ce1",
            sha256:
                "686ee51886ed5813db6a9883cc6e5e9fa86f1e3f918dafad865e06926824a6e3",
            byteCount: 325_892),
        PrimeLatinProposalProducerRevalidationArtifactObservationV1(
            role: "producer_revalidation_source",
            relativePath:
                "Sources/ErgenticsLatinProposalV3Revalidation/ErgenticsLatinProposalV3Revalidation.swift",
            gitBlobOID: "828f18920113f77a849dec56997618ae6f1addc7",
            sha256:
                "91aa0ca7ebeeb97e808493ad4f0cede9c54dbb08ecc7476619e52cada883a0ee",
            byteCount: 55_905),
        PrimeLatinProposalProducerRevalidationArtifactObservationV1(
            role: "producer_revalidation_probe_source",
            relativePath:
                "Sources/ErgenticsLatinProposalV3RevalidationProbe/ErgenticsLatinProposalV3RevalidationProbeMain.swift",
            gitBlobOID: "b050f965afab11b46bed9037b42c0a59d27e3f26",
            sha256:
                "180ebeb889cd6d585c89384efa8b4b55984501b4e6be0dbb8928d92cffb2c52d",
            byteCount: 8_115),
    ]

    static let inputBindings = [
        binding(
            "root_package_manifest", "ergentics_llm_repository",
            "Package.swift",
            "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902",
            6_109),
        binding(
            "root_dependency_lock", "ergentics_llm_repository",
            "Package.resolved",
            "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530",
            645, "4e822bfadbe5f4dced15a277f4d5423a03d76890"),
        binding(
            "declaration_package_manifest", "ergentics_llm_repository",
            "Research/Latin/CandidateDeclarations/Package.swift",
            "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63",
            892, "67907b47cf941c6e36154dd729b284f64c90ca9b"),
        binding(
            "declaration_production_source", "ergentics_llm_repository",
            "Research/Latin/CandidateDeclarations/Sources/ErgenticsLatinCandidateDeclarations/ErgenticsLatinCandidateDeclarations.swift",
            "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4",
            35_119, "a951d3710dba072aa7eb8554c60abafdd032cb7f"),
        binding(
            "candidate_architecture", "ergentics_llm_repository",
            "Research/Latin/candidates/latin_structural_fixture_v1/architecture.json",
            "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70",
            2_794, "a3a9582003bfdbce2c94707313c0e402955bca9b"),
        binding(
            "candidate_parameter_count_derivation",
            "ergentics_llm_repository",
            "Research/Latin/candidates/latin_structural_fixture_v1/parameter-count-derivation.json",
            "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f",
            2_702, "9957d0b17edd019ce760fdae9907a8ebadf408e3"),
        binding(
            "evaluation_contract", "ergentics_llm_repository",
            "Research/Latin/evaluation_contract.json",
            "4a0dd1bc973f7ce380df9775413c4e43033ba0cc409fb45a9368c2bef6835d52",
            164),
        binding(
            "tokenizer_manifest", "ergentics_mlx_lab",
            "tokenizer/ergentics_latin_bpe_v2/manifest.json",
            "b1ae203307de9c657f9d2558875e104d33f62e464c2cb83504d2f2f714ac6b76",
            2_180),
        binding(
            "tokenizer_sentencepiece_model", "ergentics_mlx_lab",
            "tokenizer/ergentics_latin_bpe_v2/model.spm",
            "3819dbc5381bfd5f52cc8b28e6f1e224ea5e30bdaaaf94dc5307fde91c9cccb5",
            285_705),
        binding(
            "tokenizer_vocabulary", "ergentics_mlx_lab",
            "tokenizer/ergentics_latin_bpe_v2/vocab.txt",
            "fb7f86c49cca2b9115f55ff559ac76e8977110e1251a3a21baa9e7dc9132c3ce",
            256_196),
        binding(
            "tokenizer_recommendation", "ergentics_mlx_lab",
            "tokenizer/ergentics_latin_bpe_v2/recommendation.json",
            "ce4c3be2e999057a102465593e2c87c4cd7424a7f633427c97c0790c20f34596",
            1_836),
        binding(
            "tokenizer_approval", "ergentics_mlx_lab",
            "tokenizer/ergentics_latin_bpe_v2/approval.json",
            "34162b2625ba160f0cc3d38c8ec7ef2c8930b0b4376a19bfd9b0fff8c96d936b",
            277),
        binding(
            "tokenizer_staged_training_input", "ergentics_mlx_lab",
            "tokenizer/ergentics_latin_bpe_v2/staging/train-input.txt",
            "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
            3_743_426),
        binding(
            "tokenizer_corpus_manifest", "ergentics_mlx_lab",
            "corpus/la/L1/primary-corpus-manifest.json",
            "87a4dcdfbbd8a9ad3f297b320bc94012e98835f395d79b6e6d99e6ce410c36b4",
            1_715),
        binding(
            "tokenizer_admitted_corpus_input", "ergentics_mlx_lab",
            "corpus/la/L1/train.txt",
            "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
            3_743_426),
        binding(
            "initialization_contract", "ergentics_mlx_lab",
            "evidence/latin-proposal-inputs/v3/776c412e/initialization-contract.json",
            "b5a959d839d41c2956a3f3d74515d4e7d0c403a23c35aaa201f18d0f4a3b2446",
            281),
        binding(
            "prospective_corpus_manifest", "ergentics_mlx_lab",
            "corpus/la/L1/prospective-v3-776c412e/corpus-manifest.json",
            "ac3fed959b9f5736124de80fba5b09206afda730099cc2f8706849687cfa7313",
            772),
        binding(
            "training_split", "ergentics_mlx_lab",
            "corpus/la/L1/prospective-v3-776c412e/training.txt",
            "57ce94783f3f93b18de0420b60f1900c15647b57868916c74bf3c94f3c35b695",
            61),
        binding(
            "validation_split", "ergentics_mlx_lab",
            "corpus/la/L1/prospective-v3-776c412e/validation.txt",
            "845a5ec82d415a7c00decc6933ae448aecfe5c7ac2fe8d369d5c066df25de78b",
            51),
        binding(
            "selection_split", "ergentics_mlx_lab",
            "corpus/la/L1/prospective-v3-776c412e/selection.txt",
            "d69252b64c20d2fd7f4a219e85d7dfe0b93a0e8bf8aded46b4fc70834e2d74a3",
            50),
        binding(
            "selection_observation_declaration", "ergentics_mlx_lab",
            "corpus/la/L1/prospective-v3-776c412e/selection-observation.json",
            "440965ad0976163f2e0d3c08868ee01a4a04b94fe808d85db5c9558965ab855f",
            311),
    ]

    private static func binding(
        _ role: String,
        _ scope: String,
        _ relativePath: String,
        _ sha256: String,
        _ byteCount: UInt64,
        _ gitBlobOID: String? = nil
    ) -> PrimeLatinProposalProducerRevalidationChildBindingV1 {
        .init(
            role: role,
            scope: scope,
            relativePath: relativePath,
            sha256: sha256,
            byteCount: byteCount,
            gitBlobOID: gitBlobOID)
    }
}

struct PrimeLatinProposalProducerRevalidationProducerArtifactStateV1:
    Equatable,
    Sendable
{
    let role: String
    let scope: String
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
}

struct PrimeLatinProposalProducerRevalidationProducerStateV1:
    Equatable,
    Sendable
{
    let pairReceiptSHA256: String
    let repository: String
    let commit: String
    let tree: String
    let candidateCatalogSHA256: String
    let candidateCatalogByteCount: UInt64
    let experimentManifestSHA256: String
    let experimentManifestByteCount: UInt64
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let candidateIDs: [String]
    let candidateIdentitySHA256s: [String]
    let declarationBundleSHA256s: [String]
    let outputNamespace: String
    let artifacts:
        [PrimeLatinProposalProducerRevalidationProducerArtifactStateV1]
    let pairAuthorityExact: Bool
    let snapshotAuthorityExact: Bool
    let gitAuthorityExact: Bool
    let gitHeadCommit: String
    let gitHeadTree: String
    let gitStatusByteCount: UInt64
    let gitStatusSHA256: String
}

final class PrimeLatinProposalProducerRevalidationProducerCaptureV1:
    @unchecked Sendable
{
    let initial: PrimeLatinProposalProducerRevalidationProducerStateV1
    private let recaptureBody:
        @Sendable () throws
            -> PrimeLatinProposalProducerRevalidationProducerStateV1

    init(
        initial: PrimeLatinProposalProducerRevalidationProducerStateV1,
        recapture: @escaping @Sendable () throws
            -> PrimeLatinProposalProducerRevalidationProducerStateV1
    ) {
        self.initial = initial
        recaptureBody = recapture
    }

    func recapture() throws
        -> PrimeLatinProposalProducerRevalidationProducerStateV1
    {
        try recaptureBody()
    }
}

struct PrimeLatinProposalProducerRevalidationToolStateV1:
    Equatable,
    Sendable
{
    let source:
        PrimeLatinProposalProducerRevalidationSourceObservationV1
    let sourceDataByRole: [String: Data]
    let rootDeviceID: UInt64
    let rootInode: UInt64
    let rootOwnerUserID: UInt32
    let rootActualMode: UInt16
}

final class PrimeLatinProposalProducerRevalidationToolCaptureV1:
    @unchecked Sendable
{
    let initial: PrimeLatinProposalProducerRevalidationToolStateV1
    private let recaptureBody:
        @Sendable () throws -> PrimeLatinProposalProducerRevalidationToolStateV1

    init(
        initial: PrimeLatinProposalProducerRevalidationToolStateV1,
        recapture: @escaping @Sendable () throws
            -> PrimeLatinProposalProducerRevalidationToolStateV1
    ) {
        self.initial = initial
        recaptureBody = recapture
    }

    func recapture() throws
        -> PrimeLatinProposalProducerRevalidationToolStateV1
    {
        try recaptureBody()
    }
}

struct PrimeLatinProposalProducerRevalidationBuildCaptureV1:
    @unchecked Sendable
{
    let observation:
        PrimeLatinProposalProducerRevalidationBuildObservationV1
    let executableURL: URL
    let recaptureExecutable:
        @Sendable () throws
            -> PrimeLatinProposalProducerRevalidationToolObservationV1
    let cleanup: @Sendable () -> Void
}

struct PrimeLatinProposalProducerRevalidationProcessResultV1:
    Equatable,
    Sendable
{
    let terminationStatus: Int32
    let terminationReasonWasExit: Bool
    let timedOut: Bool
    let standardOutput: Data
    let standardError: Data

    init(
        terminationStatus: Int32,
        terminationReasonWasExit: Bool = true,
        timedOut: Bool = false,
        standardOutput: Data,
        standardError: Data = Data()
    ) {
        self.terminationStatus = terminationStatus
        self.terminationReasonWasExit = terminationReasonWasExit
        self.timedOut = timedOut
        self.standardOutput = standardOutput
        self.standardError = standardError
    }
}

struct PrimeLatinProposalProducerRevalidationCaptureDependenciesV1:
    @unchecked Sendable
{
    let captureProducer:
        @Sendable (PrimeLatinProposalProducerRevalidationRequestV1) throws
            -> PrimeLatinProposalProducerRevalidationProducerCaptureV1
    let captureTool:
        @Sendable (PrimeLatinProposalProducerRevalidationRequestV1) throws
            -> PrimeLatinProposalProducerRevalidationToolCaptureV1
    let buildProbe:
        @Sendable (
            PrimeLatinProposalProducerRevalidationRequestV1,
            PrimeLatinProposalProducerRevalidationToolStateV1
        ) throws -> PrimeLatinProposalProducerRevalidationBuildCaptureV1
    let runProbe:
        @Sendable (
            PrimeLatinProposalProducerRevalidationRequestV1,
            PrimeLatinProposalProducerRevalidationBuildCaptureV1
        ) throws -> PrimeLatinProposalProducerRevalidationProcessResultV1
    let beforeSecondRun: @Sendable () throws -> Void
    let beforeFinalRecapture: @Sendable () throws -> Void
    let validateProducer:
        @Sendable (PrimeLatinProposalProducerRevalidationProducerStateV1)
            throws -> Void
    let validateTool:
        @Sendable (PrimeLatinProposalProducerRevalidationToolStateV1)
            throws -> Void
    let validateBuild:
        @Sendable (PrimeLatinProposalProducerRevalidationBuildObservationV1)
            throws -> Void
    let decodeRepeatedOutputs:
        @Sendable (Data, Data) throws
            -> PrimeLatinProposalProducerRevalidationChildObservationV1
    let validateChild:
        @Sendable (
            PrimeLatinProposalProducerRevalidationChildObservationV1,
            PrimeLatinProposalProducerRevalidationProducerStateV1
        ) throws -> Void

    init(
        captureProducer:
            @escaping @Sendable (
                PrimeLatinProposalProducerRevalidationRequestV1
            ) throws
                -> PrimeLatinProposalProducerRevalidationProducerCaptureV1,
        captureTool:
            @escaping @Sendable (
                PrimeLatinProposalProducerRevalidationRequestV1
            ) throws -> PrimeLatinProposalProducerRevalidationToolCaptureV1,
        buildProbe:
            @escaping @Sendable (
                PrimeLatinProposalProducerRevalidationRequestV1,
                PrimeLatinProposalProducerRevalidationToolStateV1
            ) throws -> PrimeLatinProposalProducerRevalidationBuildCaptureV1,
        runProbe:
            @escaping @Sendable (
                PrimeLatinProposalProducerRevalidationRequestV1,
                PrimeLatinProposalProducerRevalidationBuildCaptureV1
            ) throws -> PrimeLatinProposalProducerRevalidationProcessResultV1,
        beforeSecondRun: @escaping @Sendable () throws -> Void = {},
        beforeFinalRecapture: @escaping @Sendable () throws -> Void = {},
        validateProducer:
            @escaping @Sendable (
                PrimeLatinProposalProducerRevalidationProducerStateV1
            ) throws -> Void = {
                try PrimeLatinProposalProducerRevalidationCaptureV1
                    .validateProducerForDependencies($0)
            },
        validateTool:
            @escaping @Sendable (
                PrimeLatinProposalProducerRevalidationToolStateV1
            ) throws -> Void = {
                try PrimeLatinProposalProducerRevalidationCaptureV1
                    .validateToolForDependencies($0)
            },
        validateBuild:
            @escaping @Sendable (
                PrimeLatinProposalProducerRevalidationBuildObservationV1
            ) throws -> Void = {
                try PrimeLatinProposalProducerRevalidationCaptureV1
                    .validateBuildForDependencies($0)
            },
        decodeRepeatedOutputs:
            @escaping @Sendable (Data, Data) throws
                -> PrimeLatinProposalProducerRevalidationChildObservationV1 = {
                    try PrimeLatinProposalProducerRevalidationCaptureV1
                        .validateRepeatedOutputsForDependencies($0, $1)
                },
        validateChild:
            @escaping @Sendable (
                PrimeLatinProposalProducerRevalidationChildObservationV1,
                PrimeLatinProposalProducerRevalidationProducerStateV1
            ) throws -> Void = {
                try PrimeLatinProposalProducerRevalidationCaptureV1
                    .validateChildForDependencies($0, producer: $1)
            }
    ) {
        self.captureProducer = captureProducer
        self.captureTool = captureTool
        self.buildProbe = buildProbe
        self.runProbe = runProbe
        self.beforeSecondRun = beforeSecondRun
        self.beforeFinalRecapture = beforeFinalRecapture
        self.validateProducer = validateProducer
        self.validateTool = validateTool
        self.validateBuild = validateBuild
        self.decodeRepeatedOutputs = decodeRepeatedOutputs
        self.validateChild = validateChild
    }
}

public final class PrimeLatinProposalProducerRevalidationCaptureV1:
    @unchecked Sendable
{
    public let observation:
        PrimeLatinProposalProducerRevalidationObservationV1

    private let lock = NSLock()
    private let request: PrimeLatinProposalProducerRevalidationRequestV1
    private let producerCapture:
        PrimeLatinProposalProducerRevalidationProducerCaptureV1
    private let toolCapture:
        PrimeLatinProposalProducerRevalidationToolCaptureV1
    private let buildCapture:
        PrimeLatinProposalProducerRevalidationBuildCaptureV1
    private let dependencies:
        PrimeLatinProposalProducerRevalidationCaptureDependenciesV1

    private init(
        request: PrimeLatinProposalProducerRevalidationRequestV1,
        producerCapture:
            PrimeLatinProposalProducerRevalidationProducerCaptureV1,
        toolCapture: PrimeLatinProposalProducerRevalidationToolCaptureV1,
        buildCapture: PrimeLatinProposalProducerRevalidationBuildCaptureV1,
        dependencies:
            PrimeLatinProposalProducerRevalidationCaptureDependenciesV1,
        observation:
            PrimeLatinProposalProducerRevalidationObservationV1
    ) {
        self.request = request
        self.producerCapture = producerCapture
        self.toolCapture = toolCapture
        self.buildCapture = buildCapture
        self.dependencies = dependencies
        self.observation = observation
    }

    deinit {
        buildCapture.cleanup()
    }

    public static func capture(
        request: PrimeLatinProposalProducerRevalidationRequestV1
    ) throws -> PrimeLatinProposalProducerRevalidationCaptureV1 {
        try capture(request: request, dependencies: .live)
    }

    static func captureForTesting(
        request: PrimeLatinProposalProducerRevalidationRequestV1,
        dependencies:
            PrimeLatinProposalProducerRevalidationCaptureDependenciesV1
    ) throws -> PrimeLatinProposalProducerRevalidationCaptureV1 {
        try capture(request: request, dependencies: dependencies)
    }

    @discardableResult
    public func recaptureAndValidateUnchanged() throws
        -> PrimeLatinProposalProducerRevalidationObservationV1
    {
        lock.lock()
        defer { lock.unlock() }
        do {
            let current = try Self.observe(
                request: request,
                producerCapture: producerCapture,
                toolCapture: toolCapture,
                buildCapture: buildCapture,
                dependencies: dependencies,
                useInitialState: false)
            guard current == observation else {
                throw PrimeLatinProposalProducerRevalidationError
                    .captureChanged
            }
            return current
        } catch {
            throw PrimeLatinProposalProducerRevalidationError.captureChanged
        }
    }

    static func decodeChildObservationForTesting(
        _ canonicalJSON: Data
    ) throws -> PrimeLatinProposalProducerRevalidationChildObservationV1 {
        try decodeCanonicalChild(canonicalJSON)
    }

    static func validateRepeatedOutputsForTesting(
        _ first: Data,
        _ second: Data
    ) throws -> PrimeLatinProposalProducerRevalidationChildObservationV1 {
        try validateRepeatedOutputs(first, second)
    }

    static func makeAuthorityForTesting()
        -> PrimeLatinProposalProducerRevalidationAuthorityBoundaryV1
    {
        PrimeLatinProposalProducerRevalidationAuthorityBoundaryV1()
    }

    static func observeToolStateForTesting(
        at root: URL
    ) throws -> PrimeLatinProposalProducerRevalidationToolStateV1 {
        try PrimeLatinProposalProducerRevalidationLiveV1.observeTool(at: root)
    }

    private static func capture(
        request: PrimeLatinProposalProducerRevalidationRequestV1,
        dependencies:
            PrimeLatinProposalProducerRevalidationCaptureDependenciesV1
    ) throws -> PrimeLatinProposalProducerRevalidationCaptureV1 {
        let producer = try dependencies.captureProducer(request)
        let tool = try dependencies.captureTool(request)
        let build = try dependencies.buildProbe(request, tool.initial)
        do {
            let observation = try observe(
                request: request,
                producerCapture: producer,
                toolCapture: tool,
                buildCapture: build,
                dependencies: dependencies,
                useInitialState: true)
            return PrimeLatinProposalProducerRevalidationCaptureV1(
                request: request,
                producerCapture: producer,
                toolCapture: tool,
                buildCapture: build,
                dependencies: dependencies,
                observation: observation)
        } catch {
            build.cleanup()
            throw error
        }
    }

    private static func observe(
        request: PrimeLatinProposalProducerRevalidationRequestV1,
        producerCapture:
            PrimeLatinProposalProducerRevalidationProducerCaptureV1,
        toolCapture: PrimeLatinProposalProducerRevalidationToolCaptureV1,
        buildCapture: PrimeLatinProposalProducerRevalidationBuildCaptureV1,
        dependencies:
            PrimeLatinProposalProducerRevalidationCaptureDependenciesV1,
        useInitialState: Bool
    ) throws -> PrimeLatinProposalProducerRevalidationObservationV1 {
        let producerBefore = useInitialState
            ? producerCapture.initial : try producerCapture.recapture()
        let toolBefore = useInitialState
            ? toolCapture.initial : try toolCapture.recapture()
        let executableBefore = try buildCapture.recaptureExecutable()
        guard producerBefore == producerCapture.initial,
              toolBefore == toolCapture.initial,
              executableBefore == buildCapture.observation.executable else {
            throw PrimeLatinProposalProducerRevalidationError.captureChanged
        }
        try dependencies.validateProducer(producerBefore)
        try dependencies.validateTool(toolBefore)
        try dependencies.validateBuild(buildCapture.observation)

        let first = try dependencies.runProbe(request, buildCapture)
        try dependencies.beforeSecondRun()
        let second = try dependencies.runProbe(request, buildCapture)
        try dependencies.beforeFinalRecapture()

        let producerAfter = try producerCapture.recapture()
        let toolAfter = try toolCapture.recapture()
        let executableAfter = try buildCapture.recaptureExecutable()
        guard producerAfter == producerBefore,
              toolAfter == toolBefore,
              executableAfter == buildCapture.observation.executable
        else {
            throw PrimeLatinProposalProducerRevalidationError.captureChanged
        }
        try validateProcess(first, label: "first_probe")
        try validateProcess(second, label: "second_probe")
        let child = try dependencies.decodeRepeatedOutputs(
            first.standardOutput,
            second.standardOutput)
        try dependencies.validateChild(child, producerAfter)

        let process = PrimeLatinProposalProducerRevalidationProcessObservationV1(
            processPolicyID:
                "prime_latin_producer_revalidation_fixed_fresh_process_v1",
            invocationCount: 2,
            standardOutputSHA256:
                PrimeLatinProposalProducerRevalidationHashV1.sha256(
                    first.standardOutput),
            standardOutputByteCount: UInt64(first.standardOutput.count),
            standardErrorSHA256:
                PrimeLatinProposalProducerRevalidationHashV1.sha256(
                    first.standardError),
            standardErrorByteCount: UInt64(first.standardError.count))
        return PrimeLatinProposalProducerRevalidationObservationV1(
            toolSource: toolAfter.source,
            child: child,
            build: buildCapture.observation,
            process: process)
    }

    private static func validateProcess(
        _ result: PrimeLatinProposalProducerRevalidationProcessResultV1,
        label: String
    ) throws {
        if result.timedOut {
            throw PrimeLatinProposalProducerRevalidationError
                .processTimedOut(label)
        }
        guard result.terminationReasonWasExit,
              result.terminationStatus == 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .processFailed(label)
        }
        guard result.standardOutput.count <= 65_537,
              result.standardError.count <= 65_536 else {
            throw PrimeLatinProposalProducerRevalidationError
                .processOutputTooLarge(label)
        }
        guard result.standardError.isEmpty else {
            throw PrimeLatinProposalProducerRevalidationError
                .processFailed(label + "_stderr")
        }
    }

    private static func validateRepeatedOutputs(
        _ first: Data,
        _ second: Data
    ) throws -> PrimeLatinProposalProducerRevalidationChildObservationV1 {
        guard first == second else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRevalidationObservation("repeated_process_output")
        }
        guard UInt64(first.count)
                == PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .canonicalProbeOutputByteCount,
              PrimeLatinProposalProducerRevalidationHashV1.sha256(first)
                == PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .canonicalProbeOutputSHA256,
              first.last == 0x0a else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRevalidationObservation("canonical_process_output")
        }
        let canonicalJSON = first.dropLast()
        guard !canonicalJSON.contains(0x0a),
              !canonicalJSON.contains(0x0d) else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRevalidationObservation("single_line_output")
        }
        return try decodeCanonicalChild(Data(canonicalJSON))
    }

    private static func decodeCanonicalChild(
        _ data: Data
    ) throws -> PrimeLatinProposalProducerRevalidationChildObservationV1 {
        guard !data.isEmpty,
              data.count <= 65_536,
              data.first == 0x7b,
              data.last == 0x7d else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRevalidationObservation("child_json_shape")
        }
        do {
            let decoder = JSONDecoder()
            let child = try decoder.decode(
                PrimeLatinProposalProducerRevalidationChildObservationV1.self,
                from: data)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
            guard try encoder.encode(child) == data else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidRevalidationObservation("child_json_canonical")
            }
            return child
        } catch let error as PrimeLatinProposalProducerRevalidationError {
            throw error
        } catch {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRevalidationObservation("child_json_decode")
        }
    }

    private static func validateBuild(
        _ build: PrimeLatinProposalProducerRevalidationBuildObservationV1
    ) throws {
        guard build.buildPolicyID
                == "prime_latin_exact_source_direct_swiftc_build_v1",
              build.compilerLauncher.absolutePath == "/usr/bin/xcrun",
              build.compilerLauncher.role == "compiler_launcher",
              build.compilerLauncher.byteCount > 0,
              isLowerSHA256(build.compilerLauncher.sha256),
              build.compilerLauncher.ownerUserID == 0,
              build.compilerLauncher.actualMode & 0o022 == 0,
              build.compiler.role == "swift_compiler",
              build.compiler.absolutePath
                == PrimeLatinProposalProducerRevalidationLiveV1.compilerPath,
              build.compiler.byteCount > 0,
              isLowerSHA256(build.compiler.sha256),
              build.compiler.ownerUserID == 0,
              build.compiler.actualMode & 0o022 == 0,
              build.compilerIdentityScope
                == "fixed_developer_directory_exact_swift_driver_binary_observed_not_cryptographically_authenticated",
              build.compileCommandCount == 3,
              build.processLaunchCount == 5,
              build.governanceArtifactCount == 4,
              build.compilerInputSourceCount == 3,
              build.executable.role == "producer_revalidation_probe_executable",
              build.executable.byteCount > 0,
              isLowerSHA256(build.executable.sha256),
              build.executable.ownerUserID == UInt32(geteuid()),
              build.executable.actualMode == 0o700
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .buildFailed("build_observation")
        }
    }

    private static func isLowerSHA256(_ value: String) -> Bool {
        value.utf8.count == 64
            && value.utf8.allSatisfy {
                (48...57).contains($0) || (97...102).contains($0)
            }
    }

    private static func validateProducer(
        _ producer: PrimeLatinProposalProducerRevalidationProducerStateV1
    ) throws {
        let expected = PrimeLatinProposalProducerRevalidationExpectedPlanV1.self
        guard producer.pairReceiptSHA256 == expected.pairSHA256,
              producer.repository == expected.producerRepository,
              producer.commit == expected.producerCommit,
              producer.tree == expected.producerTree,
              producer.candidateCatalogSHA256
                == expected.candidateCatalogSHA256,
              producer.candidateCatalogByteCount
                == expected.candidateCatalogByteCount,
              producer.experimentManifestSHA256
                == expected.experimentManifestSHA256,
              producer.experimentManifestByteCount
                == expected.experimentManifestByteCount,
              producer.candidateDeclarationSetSHA256
                == expected.candidateDeclarationSetSHA256,
              producer.candidateDeclarationSetByteCount
                == expected.candidateDeclarationSetByteCount,
              producer.tokenizerBundleSHA256 == expected.tokenizerBundleSHA256,
              producer.tokenizerBundleByteCount
                == expected.tokenizerBundleByteCount,
              producer.candidateIDs == expected.candidateIDs,
              producer.candidateIdentitySHA256s
                == expected.candidateIdentitySHA256s,
              producer.declarationBundleSHA256s
                == expected.declarationBundleSHA256s,
              producer.outputNamespace == expected.outputNamespace,
              producer.artifacts == expected.inputBindings.map({ binding in
                  PrimeLatinProposalProducerRevalidationProducerArtifactStateV1(
                    role: binding.role,
                    scope: binding.scope,
                    relativePath: binding.relativePath,
                    sha256: binding.sha256,
                    byteCount: binding.byteCount)
              }),
              producer.pairAuthorityExact,
              producer.snapshotAuthorityExact,
              producer.gitAuthorityExact,
              producer.gitHeadCommit == expected.producerCommit,
              producer.gitHeadTree == expected.producerTree,
              producer.gitStatusByteCount == 0,
              producer.gitStatusSHA256
                == PrimeLatinProposalProducerRevalidationHashV1.emptySHA256
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRevalidationObservation("producer_cross_bindings")
        }
    }

    private static func validateTool(
        _ tool: PrimeLatinProposalProducerRevalidationToolStateV1
    ) throws {
        let expected = PrimeLatinProposalProducerRevalidationExpectedPlanV1.self
        guard tool.source.repository == expected.producerRepository,
              tool.source.locallyDeclaredOriginURL == expected.toolOrigin,
              tool.source.originObservationScope
                == "locally_declared_origin_only_not_network_authenticated",
              tool.source.commit == expected.toolCommit,
              tool.source.tree == expected.toolTree,
              tool.source.parentCommit == expected.toolParent,
              tool.source.rawCommitSHA256 == expected.toolRawCommitSHA256,
              tool.source.rawCommitByteCount == expected.toolRawCommitByteCount,
              tool.source.trackedIndexEntryCount
                == expected.trackedIndexEntryCount,
              tool.source.trackedIndexInventorySHA256
                == expected.trackedIndexInventorySHA256,
              tool.source.trackedIndexInventoryByteCount
                == expected.trackedIndexInventoryByteCount,
              tool.source.artifacts == expected.toolArtifacts,
              Set(tool.sourceDataByRole.keys)
                == Set(expected.toolArtifacts.map(\.role)),
              tool.rootOwnerUserID == UInt32(geteuid()),
              tool.rootActualMode & 0o022 == 0
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("tool_cross_bindings")
        }
        for artifact in expected.toolArtifacts {
            guard let data = tool.sourceDataByRole[artifact.role],
                  UInt64(data.count) == artifact.byteCount,
                  PrimeLatinProposalProducerRevalidationHashV1.sha256(data)
                    == artifact.sha256 else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource(artifact.role)
            }
        }
    }

    private static func validateChild(
        _ child: PrimeLatinProposalProducerRevalidationChildObservationV1,
        producer: PrimeLatinProposalProducerRevalidationProducerStateV1
    ) throws {
        let expected = PrimeLatinProposalProducerRevalidationExpectedPlanV1.self
        guard child.schema
                == "ergentics_latin_proposal_v3_live_revalidation_observation_v1",
              child.outcome == "abstain",
              child.verificationScope
                == "exact_final_public_factory_reconstruction_and_live_workspace_revalidation_only_non_authorizing",
              child.revalidationStatus
                == "exact_final_factory_reconstruction_and_repeated_live_revalidation_complete",
              child.revalidatorToolSourceIdentityStatus
                == "not_observed_by_revalidator",
              child.expectedPairReceiptSHA256 == expected.pairSHA256,
              child.pairReceiptObservationStatus
                == "expected_cross_binding_only_not_observed_or_published",
              child.llmSource.repository == expected.producerRepository,
              child.llmSource.commit == expected.producerCommit,
              child.llmSource.tree == expected.producerTree,
              child.candidateCatalogSHA256 == expected.candidateCatalogSHA256,
              child.candidateCatalogByteCount
                == expected.candidateCatalogByteCount,
              child.experimentManifestSHA256
                == expected.experimentManifestSHA256,
              child.experimentManifestByteCount
                == expected.experimentManifestByteCount,
              child.candidateDeclarationSetSHA256
                == expected.candidateDeclarationSetSHA256,
              child.candidateDeclarationSetByteCount
                == expected.candidateDeclarationSetByteCount,
              child.tokenizerBundleSHA256 == expected.tokenizerBundleSHA256,
              child.tokenizerBundleByteCount == expected.tokenizerBundleByteCount,
              child.candidateIDs == expected.candidateIDs,
              child.candidateIdentitySHA256s
                == expected.candidateIdentitySHA256s,
              child.declarationBundleSHA256s
                == expected.declarationBundleSHA256s,
              child.inputBindings == expected.inputBindings,
              child.requestedTrialBudget.application
                == "identical_per_candidate_requested_ceiling",
              child.requestedTrialBudget.optimizerSteps == 1,
              child.requestedTrialBudget.trainingTokens == 128,
              child.requestedTrialBudget.wallClockSeconds == 60,
              child.outputNamespace == expected.outputNamespace,
              child.catalogAuthorityStatus
                == "root_bound_declaration_proposal_input_v3_only_non_authorizing",
              child.catalogPublicationStatus
                == "not_implemented_input_bridge_only",
              child.experimentPublicationStatus
                == "not_implemented_input_bridge_only",
              child.authority.isExact,
              child.expectedPairReceiptSHA256 == producer.pairReceiptSHA256,
              child.candidateCatalogSHA256
                == producer.candidateCatalogSHA256,
              child.candidateCatalogByteCount
                == producer.candidateCatalogByteCount,
              child.experimentManifestSHA256
                == producer.experimentManifestSHA256,
              child.experimentManifestByteCount
                == producer.experimentManifestByteCount,
              child.candidateDeclarationSetSHA256
                == producer.candidateDeclarationSetSHA256,
              child.candidateDeclarationSetByteCount
                == producer.candidateDeclarationSetByteCount,
              child.tokenizerBundleSHA256 == producer.tokenizerBundleSHA256,
              child.tokenizerBundleByteCount
                == producer.tokenizerBundleByteCount,
              child.candidateIDs == producer.candidateIDs,
              child.candidateIdentitySHA256s
                == producer.candidateIdentitySHA256s,
              child.declarationBundleSHA256s
                == producer.declarationBundleSHA256s,
              child.outputNamespace == producer.outputNamespace
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidRevalidationObservation("child_cross_bindings")
        }
    }

    static func validateProducerForDependencies(
        _ producer: PrimeLatinProposalProducerRevalidationProducerStateV1
    ) throws {
        try validateProducer(producer)
    }

    static func validateToolForDependencies(
        _ tool: PrimeLatinProposalProducerRevalidationToolStateV1
    ) throws {
        try validateTool(tool)
    }

    static func validateBuildForDependencies(
        _ build: PrimeLatinProposalProducerRevalidationBuildObservationV1
    ) throws {
        try validateBuild(build)
    }

    static func validateRepeatedOutputsForDependencies(
        _ first: Data,
        _ second: Data
    ) throws -> PrimeLatinProposalProducerRevalidationChildObservationV1 {
        try validateRepeatedOutputs(first, second)
    }

    static func validateChildForDependencies(
        _ child: PrimeLatinProposalProducerRevalidationChildObservationV1,
        producer: PrimeLatinProposalProducerRevalidationProducerStateV1
    ) throws {
        try validateChild(child, producer: producer)
    }
}

private enum PrimeLatinProposalProducerRevalidationHashV1 {
    static let emptySHA256 =
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func gitOID(type: String, data: Data) -> String {
        var framed = Data("\(type) \(data.count)\u{0}".utf8)
        framed.append(data)
        return Insecure.SHA1.hash(data: framed)
            .map { String(format: "%02x", $0) }.joined()
    }
}

struct PrimeLatinProposalProducerRevalidationFileStateV1:
    Equatable,
    Sendable
{
    let absolutePath: String
    let sha256: String
    let byteCount: UInt64
    let deviceID: UInt64
    let inode: UInt64
    let ownerUserID: UInt32
    let actualMode: UInt16
}

struct PrimeLatinProposalProducerRevalidationFileReadV1 {
    let state: PrimeLatinProposalProducerRevalidationFileStateV1
    let data: Data
}

extension PrimeLatinProposalProducerRevalidationCaptureDependenciesV1 {
    static let live = PrimeLatinProposalProducerRevalidationCaptureDependenciesV1(
        captureProducer: { request in
            try PrimeLatinProposalProducerRevalidationLiveV1
                .captureProducer(request)
        },
        captureTool: { request in
            try PrimeLatinProposalProducerRevalidationLiveV1.captureTool(request)
        },
        buildProbe: { request, tool in
            try PrimeLatinProposalProducerRevalidationLiveV1.buildProbe(
                request: request,
                tool: tool)
        },
        runProbe: { request, build in
            try PrimeLatinProposalProducerRevalidationLiveV1.runProbe(
                request: request,
                build: build)
        })
}

private enum PrimeLatinProposalProducerRevalidationLiveV1 {
    static func captureProducer(
        _ request: PrimeLatinProposalProducerRevalidationRequestV1
    ) throws -> PrimeLatinProposalProducerRevalidationProducerCaptureV1 {
        let pair = try PrimeLatinProposalPairCaptureV3.capture(
            labRoot: request.labRoot,
            pairSHA256:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .pairSHA256)
        let snapshot = try PrimeLatinProposalInputSnapshotCaptureV3.capture(
            labRoot: request.labRoot,
            llmRepositoryRoot: request.producerRepositoryRoot,
            pairSHA256:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .pairSHA256)
        let git = try PrimeLatinProposalGitSourceCaptureV3.capture(
            labRoot: request.labRoot,
            llmRepositoryRoot: request.producerRepositoryRoot,
            pairSHA256:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .pairSHA256)
        let initial = producerState(
            pair: pair.observation,
            snapshot: snapshot.observation,
            git: git.observation)
        return PrimeLatinProposalProducerRevalidationProducerCaptureV1(
            initial: initial,
            recapture: {
                let pairObservation = try pair.recaptureAndValidateUnchanged()
                let snapshotObservation = try snapshot
                    .recaptureAndValidateUnchanged()
                let gitObservation = try git.recaptureAndValidateUnchanged()
                return producerState(
                    pair: pairObservation,
                    snapshot: snapshotObservation,
                    git: gitObservation)
            })
    }

    private static func producerState(
        pair: PrimeLatinProposalPairObservationV3,
        snapshot: PrimeLatinProposalInputSnapshotObservationV3,
        git: PrimeLatinProposalGitSourceObservationV3
    ) -> PrimeLatinProposalProducerRevalidationProducerStateV1 {
        PrimeLatinProposalProducerRevalidationProducerStateV1(
            pairReceiptSHA256: pair.pairReceiptSHA256,
            repository: pair.llmSource.repository,
            commit: pair.llmSource.commit,
            tree: pair.llmSource.tree,
            candidateCatalogSHA256: pair.candidateCatalogSHA256,
            candidateCatalogByteCount: pair.candidateCatalogByteCount,
            experimentManifestSHA256: pair.experimentManifestSHA256,
            experimentManifestByteCount: pair.experimentManifestByteCount,
            candidateDeclarationSetSHA256:
                pair.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                pair.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: pair.tokenizerBundleSHA256,
            tokenizerBundleByteCount: pair.tokenizerBundleByteCount,
            candidateIDs: pair.candidateIDs,
            candidateIdentitySHA256s: pair.candidateIdentitySHA256s,
            declarationBundleSHA256s: pair.declarationBundleSHA256s,
            outputNamespace: pair.outputNamespace,
            artifacts: snapshot.artifacts.map { artifact in
                PrimeLatinProposalProducerRevalidationProducerArtifactStateV1(
                    role: artifact.roles.count == 1
                        ? artifact.roles[0] : "invalid_role_inventory",
                    scope: artifact.scope.rawValue,
                    relativePath: artifact.relativePath,
                    sha256: artifact.sha256,
                    byteCount: artifact.byteCount)
            },
            pairAuthorityExact: pairAuthorityIsExact(pair.authority),
            snapshotAuthorityExact:
                snapshotAuthorityIsExact(snapshot.authority),
            gitAuthorityExact: gitAuthorityIsExact(git.authority),
            gitHeadCommit: git.headCommit,
            gitHeadTree: git.headTree,
            gitStatusByteCount: git.porcelainV2StatusByteCount,
            gitStatusSHA256: git.porcelainV2StatusSHA256)
    }

    private static func pairAuthorityIsExact(
        _ authority: PrimeLatinProposalPairAuthorityBoundaryV3
    ) -> Bool {
        authority.canonicalReceiptRedecodeComplete
            && authority.receiptContentAddressBindingVerified
            && authority.childContentAddressBindingsVerified
            && authority.stableRootBoundCaptureComplete
            && authority.pairChildDocumentBytesAvailable
            && authority.embeddedHashChainRecomputationComplete
            && authority.llmPairReceiptObserved
            && !authority.referencedInputSnapshotAvailable
            && !authority.referencedArtifactBytesAvailable
            && !authority.liveProducerWorkspaceRevalidationComplete
            && !authority.llmGitStateIndependentlyObserved
            && !authority.independentReplayComplete
            && !authority.runtimeDecoderImplementationAvailable
            && !authority.runtimeDependencyClosureEstablished
            && !authority.runtimeInitializationEstablished
            && !authority.primeProposalPacketProduced
            && !authority.primeTrialAuthorizationProduced
            && !authority.primeDecisionReceiptProduced
            && !authority.candidateSelectionAuthorized
            && !authority.trialExecutionAuthorized
            && !authority.furtherTrainingAuthorized
            && !authority.promotionAuthorized
            && !authority.productUseAuthorized
            && !authority.publicationAuthorized
            && !authority.primeDurableReceiptPublished
    }

    private static func snapshotAuthorityIsExact(
        _ authority: PrimeLatinProposalInputSnapshotAuthorityBoundaryV3
    ) -> Bool {
        authority.stablePairRootBoundCaptureComplete
            && authority.stableLLMRepositoryRootBoundCaptureComplete
            && authority.stableLabRootBoundCaptureComplete
            && authority.artifactPathRoleHashCountBindingsVerified
            && authority.outputNamespaceAbsenceVerified
            && authority.pairCaptureAndRecaptureComplete
            && authority.referencedInputSnapshotAvailable
            && authority.referencedArtifactBytesAvailable
            && !authority.durableInputSnapshotPublished
            && !authority.liveProducerWorkspaceRevalidationComplete
            && !authority.llmGitStateIndependentlyObserved
            && !authority.independentReplayComplete
            && !authority.runtimeDecoderImplementationAvailable
            && !authority.runtimeDependencyClosureEstablished
            && !authority.runtimeInitializationEstablished
            && !authority.primeProposalPacketProduced
            && !authority.primeTrialAuthorizationProduced
            && !authority.primeDecisionReceiptProduced
            && !authority.candidateSelectionAuthorized
            && !authority.trialExecutionAuthorized
            && !authority.furtherTrainingAuthorized
            && !authority.promotionAuthorized
            && !authority.productUseAuthorized
            && !authority.publicationAuthorized
            && !authority.primeDurableReceiptPublished
    }

    private static func gitAuthorityIsExact(
        _ authority: PrimeLatinProposalGitSourceAuthorityBoundaryV3
    ) -> Bool {
        authority.snapshotCaptureAndRecaptureComplete
            && authority.stableLLMRepositoryRootBoundObservationComplete
            && authority.stableGitToolObservationComplete
            && authority.exactHeadCommitObserved
            && authority.exactHeadTreeObserved
            && authority.cleanPorcelainV2StatusObserved
            && authority.noAssumeUnchangedOrSkipWorktreeIndexEntriesObserved
            && authority.exactRawCommitObjectObserved
            && authority.exactSevenRepositoryTreeEntriesObserved
            && authority.sevenRepositoryBlobHashCountBindingsMatchedSnapshot
            && authority.localOriginDeclarationObserved
            && authority.repeatedGitObservationUnchanged
            && authority.referencedInputSnapshotAvailable
            && authority.referencedArtifactBytesAvailable
            && authority.llmGitStateIndependentlyObserved
            && !authority.originRemoteCryptographicallyAuthenticated
            && !authority.ignoredWorkspaceBytesObserved
            && !authority.durableInputSnapshotPublished
            && !authority.durableGitObservationPublished
            && !authority.liveProducerWorkspaceRevalidationComplete
            && !authority.independentReplayComplete
            && !authority.runtimeDecoderImplementationAvailable
            && !authority.runtimeDependencyClosureEstablished
            && !authority.runtimeInitializationEstablished
            && !authority.primeProposalPacketProduced
            && !authority.primeTrialAuthorizationProduced
            && !authority.primeDecisionReceiptProduced
            && !authority.candidateSelectionAuthorized
            && !authority.trialExecutionAuthorized
            && !authority.furtherTrainingAuthorized
            && !authority.promotionAuthorized
            && !authority.productUseAuthorized
            && !authority.publicationAuthorized
            && !authority.primeDurableReceiptPublished
    }
}

enum PrimeLatinProposalProducerRevalidationFileAdmissionV1 {
    static func validateRootForTesting(_ url: URL) throws {
        _ = try rootState(url, permitSharedStickyParent: false)
    }

    static func validateFileForTesting(_ url: URL, under root: URL) throws {
        let rootPath = try canonicalPath(root)
        let filePath = try canonicalPath(url)
        guard filePath.hasPrefix(rootPath + "/") else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("file_outside_root")
        }
        _ = try readRegularFile(
            url,
            maximumByteCount: 8_388_608,
            requiredOwner: UInt32(geteuid()),
            allowedModes: [0o400, 0o440, 0o444, 0o600, 0o640, 0o644])
    }

    static func rootState(
        _ url: URL,
        permitSharedStickyParent: Bool
    ) throws -> PrimeLatinProposalProducerRevalidationFileStateV1 {
        let path = try canonicalPath(url)
        var information = stat()
        guard lstat(path, &information) == 0,
              (information.st_mode & S_IFMT) == S_IFDIR else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("root_not_directory")
        }
        let mode = UInt16(information.st_mode & 0o7777)
        let owner = UInt32(information.st_uid)
        let ordinaryPrivate = owner == UInt32(geteuid())
            && mode & 0o022 == 0
        let sharedSticky = permitSharedStickyParent
            && owner == 0
            && mode & 0o1000 != 0
            && mode & 0o002 != 0
            && mode & 0o020 != 0
        guard ordinaryPrivate || sharedSticky else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("root_mode_or_owner")
        }
        let descriptor = open(
            path,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW)
        guard descriptor >= 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("root_open")
        }
        defer { _ = close(descriptor) }
        var opened = stat()
        guard fstat(descriptor, &opened) == 0,
              opened.st_dev == information.st_dev,
              opened.st_ino == information.st_ino,
              opened.st_mode == information.st_mode,
              opened.st_uid == information.st_uid else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("root_rebound")
        }
        try requireTrustedDescriptorMetadata(descriptor, label: "root")
        return PrimeLatinProposalProducerRevalidationFileStateV1(
            absolutePath: path,
            sha256: "directory_not_hashed",
            byteCount: 0,
            deviceID: UInt64(information.st_dev),
            inode: UInt64(information.st_ino),
            ownerUserID: owner,
            actualMode: mode)
    }

    static func readRegularFile(
        _ url: URL,
        maximumByteCount: UInt64,
        requiredOwner: UInt32?,
        allowedModes: Set<UInt16>,
        requireSingleLink: Bool = true
    ) throws -> PrimeLatinProposalProducerRevalidationFileReadV1 {
        let path = try canonicalPath(url)
        var before = stat()
        guard lstat(path, &before) == 0,
              (before.st_mode & S_IFMT) == S_IFREG,
              (requireSingleLink ? before.st_nlink == 1 : before.st_nlink >= 1),
              before.st_size >= 0,
              UInt64(before.st_size) <= maximumByteCount else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("unsafe_regular_file")
        }
        let mode = UInt16(before.st_mode & 0o7777)
        guard allowedModes.contains(mode),
              requiredOwner == nil || UInt32(before.st_uid) == requiredOwner
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("file_mode_or_owner")
        }
        let descriptor = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW)
        guard descriptor >= 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("file_open")
        }
        defer { _ = close(descriptor) }
        var opened = stat()
        guard fstat(descriptor, &opened) == 0,
              opened.st_dev == before.st_dev,
              opened.st_ino == before.st_ino,
              opened.st_size == before.st_size,
              opened.st_mode == before.st_mode,
              opened.st_nlink == before.st_nlink else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("file_rebound")
        }
        try requireTrustedDescriptorMetadata(descriptor, label: "file")
        var data = Data()
        data.reserveCapacity(Int(opened.st_size))
        var buffer = [UInt8](repeating: 0, count: 65_536)
        while true {
            let count = read(descriptor, &buffer, buffer.count)
            if count == 0 { break }
            guard count > 0,
                  UInt64(data.count + count) <= maximumByteCount else {
                throw PrimeLatinProposalProducerRevalidationError
                    .unsafeFileSystemEntry("file_read")
            }
            data.append(buffer, count: count)
        }
        var after = stat()
        guard fstat(descriptor, &after) == 0,
              after.st_dev == opened.st_dev,
              after.st_ino == opened.st_ino,
              after.st_size == opened.st_size,
              after.st_mode == opened.st_mode,
              after.st_nlink == opened.st_nlink,
              UInt64(data.count) == UInt64(opened.st_size) else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("file_changed")
        }
        try requireTrustedDescriptorMetadata(descriptor, label: "file_final")
        return PrimeLatinProposalProducerRevalidationFileReadV1(
            state: PrimeLatinProposalProducerRevalidationFileStateV1(
                absolutePath: path,
                sha256:
                    PrimeLatinProposalProducerRevalidationHashV1.sha256(data),
                byteCount: UInt64(data.count),
                deviceID: UInt64(opened.st_dev),
                inode: UInt64(opened.st_ino),
                ownerUserID: UInt32(opened.st_uid),
                actualMode: mode),
            data: data)
    }

    static func canonicalPath(_ url: URL) throws -> String {
        guard url.isFileURL,
              url.path.hasPrefix("/"),
              url.path != "/",
              !url.path.utf8.contains(0),
              let resolved = realpath(url.path, nil) else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("canonical_path")
        }
        defer { free(resolved) }
        let actual = String(cString: resolved)
        guard actual == url.path else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("root_alias")
        }
        return actual
    }

    static func requireTrustedDescriptorMetadata(
        _ descriptor: Int32,
        label: String
    ) throws {
        #if canImport(Darwin)
        errno = 0
        if let accessControlList = acl_get_fd_np(
            descriptor,
            ACL_TYPE_EXTENDED
        ) {
            acl_free(UnsafeMutableRawPointer(accessControlList))
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry(label + "_acl")
        } else if errno != ENOENT && errno != ENOTSUP {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry(label + "_acl_read")
        }
        errno = 0
        let requiredSize = flistxattr(descriptor, nil, 0, 0)
        guard requiredSize >= 0,
              requiredSize <= 65_536 else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry(label + "_xattr_read")
        }
        guard requiredSize > 0 else { return }
        var names = [CChar](repeating: 0, count: requiredSize)
        let actualSize = names.withUnsafeMutableBufferPointer {
            flistxattr(descriptor, $0.baseAddress, $0.count, 0)
        }
        guard actualSize == requiredSize else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry(label + "_xattr_changed")
        }
        let bytes = names.prefix(actualSize).map { UInt8(bitPattern: $0) }
        var start = bytes.startIndex
        var observed = Set<String>()
        for index in bytes.indices where bytes[index] == 0 {
            guard start < index,
                  let name = String(
                    bytes: bytes[start..<index],
                    encoding: .utf8) else {
                throw PrimeLatinProposalProducerRevalidationError
                    .unsafeFileSystemEntry(label + "_xattr_encoding")
            }
            observed.insert(name)
            start = bytes.index(after: index)
        }
        guard start == bytes.endIndex,
              observed.isSubset(of: ["com.apple.provenance"]) else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry(label + "_xattr")
        }
        #else
        _ = descriptor
        _ = label
        #endif
    }
}

private extension PrimeLatinProposalProducerRevalidationLiveV1 {
    static let developerDirectory =
        "/Applications/Xcode.app/Contents/Developer"
    static let compilerPath = developerDirectory
        + "/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-driver"

    static func buildProbe(
        request: PrimeLatinProposalProducerRevalidationRequestV1,
        tool: PrimeLatinProposalProducerRevalidationToolStateV1
    ) throws -> PrimeLatinProposalProducerRevalidationBuildCaptureV1 {
        _ = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .rootState(request.scratchParent, permitSharedStickyParent: true)
        let scratchRoot = try createScratch(in: request.scratchParent)
        var keepScratch = false
        defer {
            if !keepScratch {
                try? FileManager.default.removeItem(at: scratchRoot)
            }
        }
        let buildRoot = scratchRoot.appendingPathComponent(
            "Build", isDirectory: true)
        let moduleCache = scratchRoot.appendingPathComponent(
            "ModuleCache", isDirectory: true)
        try makePrivateDirectory(buildRoot)
        try makePrivateDirectory(moduleCache)

        let manifest = scratchRoot.appendingPathComponent(
            "latin-proposal-artifacts.Package.swift")
        let artifactSource = scratchRoot.appendingPathComponent(
            "ErgenticsLatinProposalArtifacts.swift")
        let revalidationSource = scratchRoot.appendingPathComponent(
            "ErgenticsLatinProposalV3Revalidation.swift")
        let probeSource = scratchRoot.appendingPathComponent(
            "ErgenticsLatinProposalV3RevalidationProbeMain.swift")
        let stagedByRole = [
            "isolated_package_manifest": manifest,
            "proposal_artifact_source": artifactSource,
            "producer_revalidation_source": revalidationSource,
            "producer_revalidation_probe_source": probeSource,
        ]
        for artifact in
            PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolArtifacts
        {
            guard let sourceData = tool.sourceDataByRole[artifact.role],
                  let destination = stagedByRole[artifact.role] else {
                throw PrimeLatinProposalProducerRevalidationError
                    .buildFailed("source_inventory")
            }
            try writeExclusive(sourceData, to: destination, finalMode: 0o400)
            let recaptured = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .readRegularFile(
                    destination,
                    maximumByteCount: 1_048_576,
                    requiredOwner: UInt32(geteuid()),
                    allowedModes: [0o400])
            guard recaptured.data == sourceData,
                  recaptured.state.sha256 == artifact.sha256,
                  recaptured.state.byteCount == artifact.byteCount else {
                throw PrimeLatinProposalProducerRevalidationError
                    .buildFailed("staged_\(artifact.role)")
            }
        }

        let launcher = try observeSystemTool(
            role: "compiler_launcher",
            path: "/usr/bin/xcrun",
            maximumByteCount: 134_217_728,
            allowMultipleLinks: true)
        let compiler = try observeSystemTool(
            role: "swift_compiler",
            path: compilerPath,
            maximumByteCount: 268_435_456,
            allowMultipleLinks: false)

        let artifactModule = buildRoot.appendingPathComponent(
            "ErgenticsLatinProposalArtifacts.swiftmodule")
        let artifactObject = buildRoot.appendingPathComponent(
            "ErgenticsLatinProposalArtifacts.o")
        let revalidationModule = buildRoot.appendingPathComponent(
            "ErgenticsLatinProposalV3Revalidation.swiftmodule")
        let revalidationObject = buildRoot.appendingPathComponent(
            "ErgenticsLatinProposalV3Revalidation.o")
        let executable = buildRoot.appendingPathComponent(
            "ErgenticsLatinProposalV3RevalidationProbe")
        let common = [
            "swiftc",
            "-module-cache-path", moduleCache.path,
        ]
        let commands = [
            common + [
                "-parse-as-library",
                "-emit-module",
                "-emit-object",
                "-module-name", "ErgenticsLatinProposalArtifacts",
                artifactSource.path,
                "-emit-module-path", artifactModule.path,
                "-o", artifactObject.path,
            ],
            common + [
                "-parse-as-library",
                "-emit-module",
                "-emit-object",
                "-module-name", "ErgenticsLatinProposalV3Revalidation",
                "-I", buildRoot.path,
                revalidationSource.path,
                "-emit-module-path", revalidationModule.path,
                "-o", revalidationObject.path,
            ],
            common + [
                "-parse-as-library",
                "-I", buildRoot.path,
                artifactObject.path,
                revalidationObject.path,
                probeSource.path,
                "-o", executable.path,
            ],
        ]
        let environment = fixedEnvironment(
            temporaryDirectory: scratchRoot,
            moduleCache: moduleCache)
        for (index, arguments) in commands.enumerated() {
            let result = try PrimeLatinProposalProducerRevalidationProcessRunnerV1
                .run(
                    executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
                    arguments: arguments,
                    environment: environment,
                    currentDirectoryURL: scratchRoot,
                    timeoutSeconds: 120,
                    maximumStandardOutputByteCount: 65_536,
                    maximumStandardErrorByteCount: 262_144)
            guard !result.timedOut else {
                throw PrimeLatinProposalProducerRevalidationError
                    .processTimedOut("swiftc_\(index + 1)")
            }
            guard result.terminationReasonWasExit,
                  result.terminationStatus == 0,
                  result.standardOutput.isEmpty else {
                throw PrimeLatinProposalProducerRevalidationError
                    .buildFailed("swiftc_\(index + 1)")
            }
        }
        guard chmod(executable.path, 0o700) == 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .buildFailed("executable_mode")
        }
        let executableObservation = try observeBuiltExecutable(executable)
        let finalLauncher = try observeSystemTool(
            role: "compiler_launcher",
            path: "/usr/bin/xcrun",
            maximumByteCount: 134_217_728,
            allowMultipleLinks: true)
        let finalCompiler = try observeSystemTool(
            role: "swift_compiler",
            path: compilerPath,
            maximumByteCount: 268_435_456,
            allowMultipleLinks: false)
        guard finalLauncher == launcher,
              finalCompiler == compiler else {
            throw PrimeLatinProposalProducerRevalidationError
                .buildFailed("compiler_changed")
        }
        keepScratch = true
        let observation = PrimeLatinProposalProducerRevalidationBuildObservationV1(
            buildPolicyID: "prime_latin_exact_source_direct_swiftc_build_v1",
            compilerLauncher: launcher,
            compiler: compiler,
            compilerIdentityScope:
                "fixed_developer_directory_exact_swift_driver_binary_observed_not_cryptographically_authenticated",
            compileCommandCount: 3,
            processLaunchCount: 5,
            governanceArtifactCount: 4,
            compilerInputSourceCount: 3,
            executable: executableObservation)
        return PrimeLatinProposalProducerRevalidationBuildCaptureV1(
            observation: observation,
            executableURL: executable,
            recaptureExecutable: { try observeBuiltExecutable(executable) },
            cleanup: { try? FileManager.default.removeItem(at: scratchRoot) })
    }

    static func runProbe(
        request: PrimeLatinProposalProducerRevalidationRequestV1,
        build: PrimeLatinProposalProducerRevalidationBuildCaptureV1
    ) throws -> PrimeLatinProposalProducerRevalidationProcessResultV1 {
        let arguments = [
            "--producer-repository-root", request.producerRepositoryRoot.path,
            "--lab-root", request.labRoot.path,
            "--expected-pair-receipt-sha256",
            PrimeLatinProposalProducerRevalidationExpectedPlanV1.pairSHA256,
            "--dependency-lock-relative-path", "Package.resolved",
            "--initialization-contract-relative-path",
            "evidence/latin-proposal-inputs/v3/776c412e/initialization-contract.json",
            "--corpus-manifest-relative-path",
            "corpus/la/L1/prospective-v3-776c412e/corpus-manifest.json",
            "--evaluation-contract-relative-path",
            "Research/Latin/evaluation_contract.json",
            "--training-split-id", "latin_fixture_train_v3",
            "--training-split-relative-path",
            "corpus/la/L1/prospective-v3-776c412e/training.txt",
            "--validation-split-id", "latin_fixture_validation_v3",
            "--validation-split-relative-path",
            "corpus/la/L1/prospective-v3-776c412e/validation.txt",
            "--selection-split-id", "latin_fixture_selection_v3",
            "--selection-split-relative-path",
            "corpus/la/L1/prospective-v3-776c412e/selection.txt",
            "--selection-observation-relative-path",
            "corpus/la/L1/prospective-v3-776c412e/selection-observation.json",
            "--optimizer-steps", "1",
            "--training-tokens", "128",
            "--wall-clock-seconds", "60",
            "--output-namespace",
            PrimeLatinProposalProducerRevalidationExpectedPlanV1.outputNamespace,
        ]
        guard arguments.count == 36 else {
            throw PrimeLatinProposalProducerRevalidationError
                .processFailed("probe_argument_count")
        }
        return try PrimeLatinProposalProducerRevalidationProcessRunnerV1.run(
            executableURL: build.executableURL,
            arguments: arguments,
            environment: fixedEnvironment(
                temporaryDirectory:
                    build.executableURL.deletingLastPathComponent(),
                moduleCache: nil),
            currentDirectoryURL: build.executableURL.deletingLastPathComponent(),
            timeoutSeconds: 120,
            maximumStandardOutputByteCount: 65_537,
            maximumStandardErrorByteCount: 65_536)
    }

    static func fixedEnvironment(
        temporaryDirectory: URL,
        moduleCache: URL?
    ) -> [String: String] {
        var environment = [
            "DEVELOPER_DIR": developerDirectory,
            "GIT_ALLOW_PROTOCOL": "none",
            "GIT_CONFIG_GLOBAL": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_NO_LAZY_FETCH": "1",
            "GIT_OPTIONAL_LOCKS": "0",
            "HOME": "/var/empty",
            "LANG": "C",
            "LC_ALL": "C",
            "NO_COLOR": "1",
            "PATH": "/usr/bin:/bin",
            "TMPDIR": temporaryDirectory.path,
        ]
        if let moduleCache {
            environment["CLANG_MODULE_CACHE_PATH"] = moduleCache.path
        }
        return environment
    }

    static func observeSystemTool(
        role: String,
        path: String,
        maximumByteCount: UInt64,
        allowMultipleLinks: Bool
    ) throws -> PrimeLatinProposalProducerRevalidationToolObservationV1 {
        let read = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .readRegularFile(
                URL(fileURLWithPath: path),
                maximumByteCount: maximumByteCount,
                requiredOwner: 0,
                allowedModes: [0o500, 0o550, 0o555, 0o700, 0o750, 0o755],
                requireSingleLink: !allowMultipleLinks)
        guard read.state.byteCount > 0,
              read.state.actualMode & 0o022 == 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .buildFailed(role)
        }
        return PrimeLatinProposalProducerRevalidationToolObservationV1(
            role: role,
            file: read.state)
    }

    static func observeBuiltExecutable(
        _ url: URL
    ) throws -> PrimeLatinProposalProducerRevalidationToolObservationV1 {
        let read = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .readRegularFile(
                url,
                maximumByteCount: 16_777_216,
                requiredOwner: UInt32(geteuid()),
                allowedModes: [0o700])
        guard read.data.prefix(4) == Data([0xcf, 0xfa, 0xed, 0xfe])
                || read.data.prefix(4) == Data([0xca, 0xfe, 0xba, 0xbe])
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .buildFailed("executable_format")
        }
        return PrimeLatinProposalProducerRevalidationToolObservationV1(
            role: "producer_revalidation_probe_executable",
            file: read.state)
    }

    static func createScratch(in parent: URL) throws -> URL {
        var template = Array(
            parent.appendingPathComponent(
                "prime-latin-producer-revalidation.XXXXXXXX")
                .path.utf8CString)
        guard let created = template.withUnsafeMutableBufferPointer({ buffer in
            mkdtemp(buffer.baseAddress)
        }) else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("scratch_create")
        }
        let url = URL(
            fileURLWithPath: String(cString: created),
            isDirectory: true)
        let state = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .rootState(url, permitSharedStickyParent: false)
        guard state.ownerUserID == UInt32(geteuid()),
              state.actualMode == 0o700 else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("scratch_identity")
        }
        return url
    }

    static func makePrivateDirectory(_ url: URL) throws {
        guard mkdir(url.path, 0o700) == 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("scratch_subdirectory")
        }
        _ = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .rootState(url, permitSharedStickyParent: false)
    }

    static func writeExclusive(
        _ data: Data,
        to url: URL,
        finalMode: mode_t
    ) throws {
        let descriptor = open(
            url.path,
            O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW,
            0o600)
        guard descriptor >= 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("scratch_file_create")
        }
        var succeeded = false
        defer {
            _ = close(descriptor)
            if !succeeded { _ = unlink(url.path) }
        }
        try data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else { return }
            var offset = 0
            while offset < rawBuffer.count {
                let count = write(
                    descriptor,
                    base.advanced(by: offset),
                    rawBuffer.count - offset)
                guard count > 0 else {
                    throw PrimeLatinProposalProducerRevalidationError
                        .unsafeFileSystemEntry("scratch_file_write")
                }
                offset += count
            }
        }
        guard fsync(descriptor) == 0,
              fchmod(descriptor, finalMode) == 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .unsafeFileSystemEntry("scratch_file_seal")
        }
        succeeded = true
    }
}

private final class PrimeLatinProposalProducerRevalidationBoundedReaderV1:
    @unchecked Sendable
{
    private let lock = NSLock()
    private let maximumByteCount: UInt64
    private var bytes = Data()
    private var exceeded = false
    private var failed = false

    init(maximumByteCount: UInt64) {
        self.maximumByteCount = maximumByteCount
    }

    func beginReading(
        _ handle: FileHandle,
        group: DispatchGroup
    ) {
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            defer { group.leave() }
            do {
                while let chunk = try handle.read(upToCount: 65_536),
                      !chunk.isEmpty {
                    lock.lock()
                    let remaining = maximumByteCount > UInt64(bytes.count)
                        ? maximumByteCount - UInt64(bytes.count) : 0
                    if UInt64(chunk.count) > remaining {
                        if remaining > 0 {
                            bytes.append(chunk.prefix(Int(remaining)))
                        }
                        exceeded = true
                    } else {
                        bytes.append(chunk)
                    }
                    lock.unlock()
                }
            } catch {
                lock.lock()
                failed = true
                lock.unlock()
            }
        }
    }

    func result() -> (data: Data, exceeded: Bool, failed: Bool) {
        lock.lock()
        defer { lock.unlock() }
        return (bytes, exceeded, failed)
    }
}

private enum PrimeLatinProposalProducerRevalidationProcessRunnerV1 {
    static func run(
        executableURL: URL,
        arguments: [String],
        environment: [String: String],
        currentDirectoryURL: URL,
        timeoutSeconds: UInt64,
        maximumStandardOutputByteCount: UInt64,
        maximumStandardErrorByteCount: UInt64
    ) throws -> PrimeLatinProposalProducerRevalidationProcessResultV1 {
        guard executableURL.path.hasPrefix("/"),
              currentDirectoryURL.path.hasPrefix("/"),
              timeoutSeconds > 0,
              timeoutSeconds <= 300,
              maximumStandardOutputByteCount > 0,
              maximumStandardErrorByteCount > 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .processFailed("runner_contract")
        }
        let standardOutputPipe = Pipe()
        let standardErrorPipe = Pipe()
        let standardOutputReader =
            PrimeLatinProposalProducerRevalidationBoundedReaderV1(
                maximumByteCount: maximumStandardOutputByteCount)
        let standardErrorReader =
            PrimeLatinProposalProducerRevalidationBoundedReaderV1(
                maximumByteCount: maximumStandardErrorByteCount)
        let readerGroup = DispatchGroup()
        standardOutputReader.beginReading(
            standardOutputPipe.fileHandleForReading,
            group: readerGroup)
        standardErrorReader.beginReading(
            standardErrorPipe.fileHandleForReading,
            group: readerGroup)

        let completion = DispatchSemaphore(value: 0)
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
        process.environment = environment
        process.currentDirectoryURL = currentDirectoryURL
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = standardOutputPipe
        process.standardError = standardErrorPipe
        process.terminationHandler = { _ in completion.signal() }
        do {
            try process.run()
        } catch {
            try? standardOutputPipe.fileHandleForWriting.close()
            try? standardErrorPipe.fileHandleForWriting.close()
            throw PrimeLatinProposalProducerRevalidationError
                .processFailed("launch")
        }
        try? standardOutputPipe.fileHandleForWriting.close()
        try? standardErrorPipe.fileHandleForWriting.close()

        var timedOut = completion.wait(
            timeout: .now() + .seconds(Int(timeoutSeconds))) == .timedOut
        if timedOut {
            process.terminate()
            if completion.wait(timeout: .now() + .seconds(1)) == .timedOut {
                _ = kill(process.processIdentifier, SIGKILL)
                if completion.wait(timeout: .now() + .seconds(2))
                    == .timedOut {
                    throw PrimeLatinProposalProducerRevalidationError
                        .processTimedOut("unreaped_process")
                }
            }
        }
        guard readerGroup.wait(timeout: .now() + .seconds(5)) == .success else {
            throw PrimeLatinProposalProducerRevalidationError
                .processTimedOut("output_drain")
        }
        let standardOutput = standardOutputReader.result()
        let standardError = standardErrorReader.result()
        guard !standardOutput.failed,
              !standardError.failed else {
            throw PrimeLatinProposalProducerRevalidationError
                .processFailed("output_read")
        }
        guard !standardOutput.exceeded,
              !standardError.exceeded else {
            throw PrimeLatinProposalProducerRevalidationError
                .processOutputTooLarge("bounded_output")
        }
        if !process.isRunning {
            process.waitUntilExit()
        } else {
            timedOut = true
        }
        return PrimeLatinProposalProducerRevalidationProcessResultV1(
            terminationStatus: process.terminationStatus,
            terminationReasonWasExit: process.terminationReason == .exit,
            timedOut: timedOut,
            standardOutput: standardOutput.data,
            standardError: standardError.data)
    }
}

private extension PrimeLatinProposalProducerRevalidationLiveV1 {
    static func captureTool(
        _ request: PrimeLatinProposalProducerRevalidationRequestV1
    ) throws -> PrimeLatinProposalProducerRevalidationToolCaptureV1 {
        let initial = try observeTool(at: request.toolRepositoryRoot)
        return PrimeLatinProposalProducerRevalidationToolCaptureV1(
            initial: initial,
            recapture: { try observeTool(at: request.toolRepositoryRoot) })
    }

    static func observeTool(
        at rootURL: URL
    ) throws -> PrimeLatinProposalProducerRevalidationToolStateV1 {
        let root = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .rootState(rootURL, permitSharedStickyParent: false)
        let gitPointer = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .readRegularFile(
                rootURL.appendingPathComponent(".git"),
                maximumByteCount: 4_096,
                requiredOwner: UInt32(geteuid()),
                allowedModes: [0o400, 0o440, 0o444, 0o600, 0o640, 0o644])
        guard let pointerText = String(
                data: gitPointer.data, encoding: .utf8),
              pointerText.hasPrefix("gitdir: "),
              pointerText.hasSuffix("\n"),
              pointerText.filter({ $0 == "\n" }).count == 1 else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("git_pointer")
        }
        let gitDirectoryPath = String(pointerText.dropFirst(8).dropLast())
        let gitDirectory = URL(
            fileURLWithPath: gitDirectoryPath,
            isDirectory: true)
        _ = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .rootState(gitDirectory, permitSharedStickyParent: false)
        let head = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .readRegularFile(
                gitDirectory.appendingPathComponent("HEAD"),
                maximumByteCount: 128,
                requiredOwner: UInt32(geteuid()),
                allowedModes: [0o400, 0o440, 0o444, 0o600, 0o640, 0o644])
        guard head.data == Data(
            (PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolCommit
                + "\n").utf8) else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("detached_exact_head")
        }
        let commonDirectory = try resolveCommonGitDirectory(
            worktreeGitDirectory: gitDirectory)
        let commit = try readLooseGitObject(
            oid: PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolCommit,
            commonDirectory: commonDirectory,
            expectedType: "commit",
            maximumPayloadByteCount: 8_192)
        guard UInt64(commit.count)
                == PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .toolRawCommitByteCount,
              PrimeLatinProposalProducerRevalidationHashV1.sha256(commit)
                == PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .toolRawCommitSHA256,
              PrimeLatinProposalProducerRevalidationHashV1.gitOID(
                type: "commit", data: commit)
                == PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .toolCommit,
              let commitText = String(data: commit, encoding: .utf8),
              commitText.hasPrefix(
                "tree \(PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolTree)\n" +
                "parent \(PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolParent)\n")
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("commit_object")
        }
        let index = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .readRegularFile(
                gitDirectory.appendingPathComponent("index"),
                maximumByteCount: 1_048_576,
                requiredOwner: UInt32(geteuid()),
                allowedModes: [0o400, 0o440, 0o444, 0o600, 0o640, 0o644])
        let indexObservation = try parseIndex(index.data)
        guard indexObservation.entryCount
                == PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .trackedIndexEntryCount,
              indexObservation.inventoryByteCount
                == PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .trackedIndexInventoryByteCount,
              indexObservation.inventorySHA256
                == PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .trackedIndexInventorySHA256 else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("tracked_index")
        }
        let origin = try locallyDeclaredOrigin(commonDirectory: commonDirectory)
        var sourceData: [String: Data] = [:]
        for artifact in
            PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolArtifacts
        {
            let read = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
                .readRegularFile(
                    rootURL.appendingPathComponent(artifact.relativePath),
                    maximumByteCount: 1_048_576,
                    requiredOwner: UInt32(geteuid()),
                    allowedModes: [0o400, 0o440, 0o444, 0o600, 0o640, 0o644])
            guard read.state.sha256 == artifact.sha256,
                  read.state.byteCount == artifact.byteCount,
                  PrimeLatinProposalProducerRevalidationHashV1.gitOID(
                    type: "blob", data: read.data) == artifact.gitBlobOID,
                  indexObservation.entries[artifact.relativePath]
                    == artifact.gitBlobOID else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource(artifact.role)
            }
            sourceData[artifact.role] = read.data
        }
        let finalRoot = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .rootState(rootURL, permitSharedStickyParent: false)
        guard finalRoot.deviceID == root.deviceID,
              finalRoot.inode == root.inode,
              finalRoot.ownerUserID == root.ownerUserID,
              finalRoot.actualMode == root.actualMode else {
            throw PrimeLatinProposalProducerRevalidationError.captureChanged
        }
        let source = PrimeLatinProposalProducerRevalidationSourceObservationV1(
            repository:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .producerRepository,
            locallyDeclaredOriginURL: origin,
            originObservationScope:
                "locally_declared_origin_only_not_network_authenticated",
            commit:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolCommit,
            tree: PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolTree,
            parentCommit:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1.toolParent,
            rawCommitSHA256:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .toolRawCommitSHA256,
            rawCommitByteCount:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .toolRawCommitByteCount,
            trackedIndexEntryCount: indexObservation.entryCount,
            trackedIndexInventorySHA256: indexObservation.inventorySHA256,
            trackedIndexInventoryByteCount:
                indexObservation.inventoryByteCount,
            artifacts:
                PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .toolArtifacts)
        return PrimeLatinProposalProducerRevalidationToolStateV1(
            source: source,
            sourceDataByRole: sourceData,
            rootDeviceID: root.deviceID,
            rootInode: root.inode,
            rootOwnerUserID: root.ownerUserID,
            rootActualMode: root.actualMode)
    }

    static func resolveCommonGitDirectory(
        worktreeGitDirectory: URL
    ) throws -> URL {
        let markerURL = worktreeGitDirectory.appendingPathComponent("commondir")
        if access(markerURL.path, F_OK) != 0 {
            return worktreeGitDirectory
        }
        let marker = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .readRegularFile(
                markerURL,
                maximumByteCount: 4_096,
                requiredOwner: UInt32(geteuid()),
                allowedModes: [0o400, 0o440, 0o444, 0o600, 0o640, 0o644])
        guard let value = String(data: marker.data, encoding: .utf8),
              value.hasSuffix("\n"),
              !value.dropLast().isEmpty else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("commondir")
        }
        let candidate = URL(
            fileURLWithPath: String(value.dropLast()),
            relativeTo: worktreeGitDirectory).standardizedFileURL
        _ = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .rootState(candidate, permitSharedStickyParent: false)
        return candidate
    }

    static func locallyDeclaredOrigin(commonDirectory: URL) throws -> String {
        let config = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .readRegularFile(
                commonDirectory.appendingPathComponent("config"),
                maximumByteCount: 65_536,
                requiredOwner: UInt32(geteuid()),
                allowedModes: [0o400, 0o440, 0o444, 0o600, 0o640, 0o644])
        guard let text = String(data: config.data, encoding: .utf8) else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("git_config")
        }
        var inOrigin = false
        var origins: [String] = []
        for rawLine in text.split(
            separator: "\n", omittingEmptySubsequences: false)
        {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("[") {
                inOrigin = line == "[remote \"origin\"]"
            } else if inOrigin,
                      line.hasPrefix("url = ") {
                origins.append(String(line.dropFirst(6)))
            }
        }
        guard origins
                == [PrimeLatinProposalProducerRevalidationExpectedPlanV1
                    .toolOrigin] else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("origin")
        }
        return origins[0]
    }

    static func readLooseGitObject(
        oid: String,
        commonDirectory: URL,
        expectedType: String,
        maximumPayloadByteCount: UInt64
    ) throws -> Data {
        let relative = "objects/\(oid.prefix(2))/\(oid.dropFirst(2))"
        let compressed = try PrimeLatinProposalProducerRevalidationFileAdmissionV1
            .readRegularFile(
                commonDirectory.appendingPathComponent(relative),
                maximumByteCount: maximumPayloadByteCount + 4_096,
                requiredOwner: UInt32(geteuid()),
                allowedModes: [0o400, 0o440, 0o444, 0o600, 0o640, 0o644])
        let inflated = try inflateGitZlib(
            compressed.data,
            maximumByteCount: maximumPayloadByteCount + 128)
        guard let separator = inflated.firstIndex(of: 0),
              separator < inflated.endIndex,
              let header = String(
                data: inflated[..<separator], encoding: .utf8),
              header.hasPrefix(expectedType + " "),
              let declared = UInt64(header.dropFirst(expectedType.count + 1))
        else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("loose_object_header")
        }
        let payload = Data(inflated[inflated.index(after: separator)...])
        guard UInt64(payload.count) == declared,
              declared <= maximumPayloadByteCount else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("loose_object_size")
        }
        return payload
    }

    static func inflateGitZlib(
        _ compressed: Data,
        maximumByteCount: UInt64
    ) throws -> Data {
        guard compressed.count >= 6,
              maximumByteCount > 0,
              maximumByteCount <= 1_048_576 else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("loose_object_compression")
        }
        let cmf = UInt16(compressed[0])
        let flg = UInt16(compressed[1])
        guard cmf & 0x0f == 8,
              ((cmf << 8) | flg) % 31 == 0,
              flg & 0x20 == 0 else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("loose_object_zlib_header")
        }
        let deflate = compressed.dropFirst(2).dropLast(4)
        var destination = [UInt8](
            repeating: 0,
            count: Int(maximumByteCount))
        let decoded = deflate.withUnsafeBytes { sourceBuffer in
            destination.withUnsafeMutableBytes { destinationBuffer in
                compression_decode_buffer(
                    destinationBuffer.bindMemory(to: UInt8.self).baseAddress!,
                    destinationBuffer.count,
                    sourceBuffer.bindMemory(to: UInt8.self).baseAddress!,
                    sourceBuffer.count,
                    nil,
                    COMPRESSION_ZLIB)
            }
        }
        guard decoded > 0,
              decoded < destination.count else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("loose_object_deflate")
        }
        let data = Data(destination.prefix(decoded))
        let expectedAdler = bigEndianUInt32(
            compressed,
            at: compressed.count - 4)
        guard adler32(data) == expectedAdler else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("loose_object_adler32")
        }
        return data
    }

    static func adler32(_ data: Data) -> UInt32 {
        let modulus: UInt32 = 65_521
        var first: UInt32 = 1
        var second: UInt32 = 0
        for byte in data {
            first = (first + UInt32(byte)) % modulus
            second = (second + first) % modulus
        }
        return (second << 16) | first
    }
}

private struct PrimeLatinProposalProducerRevalidationIndexObservationV1 {
    let entryCount: UInt64
    let inventorySHA256: String
    let inventoryByteCount: UInt64
    let entries: [String: String]
}

private extension PrimeLatinProposalProducerRevalidationLiveV1 {
    static func parseIndex(
        _ data: Data
    ) throws -> PrimeLatinProposalProducerRevalidationIndexObservationV1 {
        guard data.count >= 32,
              data.prefix(4) == Data("DIRC".utf8),
              bigEndianUInt32(data, at: 4) == 2 else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("index_header")
        }
        let contentEnd = data.count - 20
        let expectedChecksum = data.suffix(20)
        let observedChecksum = Data(Insecure.SHA1.hash(data: data[..<contentEnd]))
        guard observedChecksum == expectedChecksum else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("index_checksum")
        }
        let declaredCount = Int(bigEndianUInt32(data, at: 8))
        guard declaredCount > 0,
              declaredCount <= 16_384 else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("index_count")
        }
        var offset = 12
        var inventory = Data()
        var entries: [String: String] = [:]
        var priorPath: Data?
        for _ in 0..<declaredCount {
            let entryStart = offset
            guard entryStart + 62 <= contentEnd else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource("index_entry")
            }
            let mode = bigEndianUInt32(data, at: entryStart + 24)
            let oidData = data[(entryStart + 40)..<(entryStart + 60)]
            let flags = bigEndianUInt16(data, at: entryStart + 60)
            guard flags & 0x8000 == 0,
                  flags & 0x4000 == 0,
                  flags & 0x3000 == 0 else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource("index_flags")
            }
            let pathStart = entryStart + 62
            guard let pathEnd = data[pathStart..<contentEnd]
                .firstIndex(of: 0) else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource("index_path")
            }
            let pathData = Data(data[pathStart..<pathEnd])
            guard !pathData.isEmpty,
                  !pathData.contains(0),
                  priorPath == nil || priorPath!.lexicographicallyPrecedes(pathData),
                  let path = String(data: pathData, encoding: .utf8),
                  !path.hasPrefix("/"),
                  !path.split(separator: "/", omittingEmptySubsequences: false)
                    .contains(where: { $0.isEmpty || $0 == "." || $0 == ".." }),
                  entries[path] == nil else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource("index_path_shape")
            }
            let encodedLength = Int(flags & 0x0fff)
            guard encodedLength == 0x0fff || encodedLength == pathData.count else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource("index_path_length")
            }
            let oid = oidData.map { String(format: "%02x", $0) }.joined()
            let modeString = String(format: "%06o", mode)
            inventory.append(Data("\(modeString) \(oid) 0\t".utf8))
            inventory.append(pathData)
            inventory.append(0)
            entries[path] = oid
            priorPath = pathData
            let unpaddedLength = pathEnd + 1 - entryStart
            offset = entryStart + ((unpaddedLength + 7) & ~7)
            guard offset <= contentEnd else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource("index_padding")
            }
        }
        while offset < contentEnd {
            guard offset + 8 <= contentEnd else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource("index_extension")
            }
            let signature = data[offset..<(offset + 4)]
            let size = Int(bigEndianUInt32(data, at: offset + 4))
            guard signature == Data("TREE".utf8),
                  size >= 0,
                  offset + 8 + size <= contentEnd else {
                throw PrimeLatinProposalProducerRevalidationError
                    .invalidToolSource("index_extension_shape")
            }
            offset += 8 + size
        }
        guard offset == contentEnd,
              entries.count == declaredCount else {
            throw PrimeLatinProposalProducerRevalidationError
                .invalidToolSource("index_final")
        }
        return PrimeLatinProposalProducerRevalidationIndexObservationV1(
            entryCount: UInt64(declaredCount),
            inventorySHA256:
                PrimeLatinProposalProducerRevalidationHashV1.sha256(inventory),
            inventoryByteCount: UInt64(inventory.count),
            entries: entries)
    }

    static func bigEndianUInt16(_ data: Data, at offset: Int) -> UInt16 {
        (UInt16(data[offset]) << 8) | UInt16(data[offset + 1])
    }

    static func bigEndianUInt32(_ data: Data, at offset: Int) -> UInt32 {
        (UInt32(data[offset]) << 24)
            | (UInt32(data[offset + 1]) << 16)
            | (UInt32(data[offset + 2]) << 8)
            | UInt32(data[offset + 3])
    }
}
