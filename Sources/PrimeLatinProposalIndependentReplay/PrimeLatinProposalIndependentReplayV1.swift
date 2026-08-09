import CryptoKit
import Foundation
import PrimeLatinProposalGitObservation
import PrimeLatinProposalPairCapture

public enum PrimeLatinProposalIndependentReplayError:
    Error,
    Equatable,
    Sendable
{
    case invalidOriginalInputs(String)
    case invalidArtifact(String)
    case invalidReconstruction(String)
    case invalidReference(String)
    case captureChanged
}

public struct PrimeLatinProposalIndependentReplayAuthorityBoundaryV1:
    Equatable,
    Sendable
{
    public let disposition: String
    public let pairCaptureAndRecaptureComplete: Bool
    public let inputSnapshotCaptureAndRecaptureComplete: Bool
    public let producerGitObservationComplete: Bool
    public let exactTwentyOneOriginalInputBindingsCrossBound: Bool
    public let exactTwentyOneOriginalInputBytesRetained: Bool
    public let retainedOriginalInputHashCountRecomputationComplete: Bool
    public let independentTokenizerBundleReconstructionComplete: Bool
    public let independentDeclarationTargetClosureReconstructionComplete: Bool
    public let independentCandidateIdentityReconstructionComplete: Bool
    public let independentCandidateDeclarationSetReconstructionComplete: Bool
    public let independentCandidateCatalogReconstructionComplete: Bool
    public let independentExperimentManifestReconstructionComplete: Bool
    public let canonicalCandidateCatalogBytesMatched: Bool
    public let canonicalExperimentManifestBytesMatched: Bool
    public let canonicalHashChainRecomputationComplete: Bool
    public let outputNamespaceAbsenceVerified: Bool
    public let referencedInputSnapshotAvailable: Bool
    public let referencedArtifactBytesAvailable: Bool
    public let llmGitStateIndependentlyObserved: Bool
    public let independentPrimeReplayComplete: Bool
    public let ergenticsLatinProducerModuleImported: Bool
    public let ergenticsLatinProducerFunctionInvoked: Bool
    public let ergenticsLatinProducerSourceUsedAsReplayImplementation: Bool
    public let liveProducerWorkspaceRevalidationComplete: Bool
    public let revalidatorToolSourceIndependentlyObserved: Bool
    public let originRemoteCryptographicallyAuthenticated: Bool
    public let ignoredWorkspaceBytesObserved: Bool
    public let declarationSourceSemanticsIndependentlyVerified: Bool
    public let tokenizerModelSemanticsIndependentlyValidated: Bool
    public let tokenizerTrainingReplayComplete: Bool
    public let evaluationExecutionComplete: Bool
    public let selectionObservationComplete: Bool
    public let durableInputSnapshotPublished: Bool
    public let durableGitObservationPublished: Bool
    public let durableIndependentReplayObservationPublished: Bool
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
            "abstain_independent_prime_structural_replay_complete_live_producer_revalidation_not_composed_and_runtime_decoder_initialization_evaluation_trial_and_publication_authority_absent"
        pairCaptureAndRecaptureComplete = true
        inputSnapshotCaptureAndRecaptureComplete = true
        producerGitObservationComplete = true
        exactTwentyOneOriginalInputBindingsCrossBound = true
        exactTwentyOneOriginalInputBytesRetained = true
        retainedOriginalInputHashCountRecomputationComplete = true
        independentTokenizerBundleReconstructionComplete = true
        independentDeclarationTargetClosureReconstructionComplete = true
        independentCandidateIdentityReconstructionComplete = true
        independentCandidateDeclarationSetReconstructionComplete = true
        independentCandidateCatalogReconstructionComplete = true
        independentExperimentManifestReconstructionComplete = true
        canonicalCandidateCatalogBytesMatched = true
        canonicalExperimentManifestBytesMatched = true
        canonicalHashChainRecomputationComplete = true
        outputNamespaceAbsenceVerified = true
        referencedInputSnapshotAvailable = true
        referencedArtifactBytesAvailable = true
        llmGitStateIndependentlyObserved = true
        independentPrimeReplayComplete = true
        ergenticsLatinProducerModuleImported = false
        ergenticsLatinProducerFunctionInvoked = false
        ergenticsLatinProducerSourceUsedAsReplayImplementation = false
        liveProducerWorkspaceRevalidationComplete = false
        revalidatorToolSourceIndependentlyObserved = false
        originRemoteCryptographicallyAuthenticated = false
        ignoredWorkspaceBytesObserved = false
        declarationSourceSemanticsIndependentlyVerified = false
        tokenizerModelSemanticsIndependentlyValidated = false
        tokenizerTrainingReplayComplete = false
        evaluationExecutionComplete = false
        selectionObservationComplete = false
        durableInputSnapshotPublished = false
        durableGitObservationPublished = false
        durableIndependentReplayObservationPublished = false
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

public struct PrimeLatinProposalIndependentReplayObservationV1:
    Equatable,
    Sendable
{
    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let replayPolicyID: String
    public let pairReceiptSHA256: String
    public let pairReceiptByteCount: UInt64
    public let producerRepository: String
    public let producerCommit: String
    public let producerTree: String
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
    public let retainedOriginalInputByteCount: UInt64
    public let optimizerSteps: UInt64
    public let trainingTokens: UInt64
    public let wallClockSeconds: UInt64
    public let outputNamespace: String
    public let orderedTensorCount: UInt64
    public let uniqueParameterStorageCount: UInt64
    public let totalParameterCount: UInt64
    public let authority:
        PrimeLatinProposalIndependentReplayAuthorityBoundaryV1

    init(
        reconstruction: PrimeLatinProposalIndependentReplayReconstructionV1,
        references: PrimeLatinProposalIndependentReplayReferenceV1
    ) {
        schema =
            "ergentics_prime_latin_proposal_v3_independent_replay_observation_v1"
        outcome = "abstain"
        verificationScope =
            "prime_owned_independent_typed_reconstruction_from_one_git_bound_retained_twenty_one_original_input_snapshot_and_byte_exact_catalog_experiment_cross_check_only_non_authorizing"
        replayPolicyID =
            "prime_latin_v3_retained_original_input_independent_reconstruction_v1"
        pairReceiptSHA256 = references.pairReceiptSHA256
        pairReceiptByteCount = UInt64(references.pairReceiptData.count)
        producerRepository = reconstruction.source.repository
        producerCommit = reconstruction.source.commit
        producerTree = reconstruction.source.tree
        candidateCatalogSHA256 =
            PrimeLatinProposalIndependentReplayHashV1.sha256(
                reconstruction.candidateCatalogData)
        candidateCatalogByteCount =
            UInt64(reconstruction.candidateCatalogData.count)
        experimentManifestSHA256 =
            PrimeLatinProposalIndependentReplayHashV1.sha256(
                reconstruction.experimentManifestData)
        experimentManifestByteCount =
            UInt64(reconstruction.experimentManifestData.count)
        candidateDeclarationSetSHA256 =
            reconstruction.candidateDeclarationSetSHA256
        candidateDeclarationSetByteCount =
            reconstruction.candidateDeclarationSetByteCount
        tokenizerBundleSHA256 = reconstruction.tokenizerBundleSHA256
        tokenizerBundleByteCount = reconstruction.tokenizerBundleByteCount
        candidateIDs = reconstruction.candidateIDs
        candidateIdentitySHA256s = reconstruction.candidateIdentitySHA256s
        declarationBundleSHA256s = reconstruction.declarationBundleSHA256s
        inputBindingCount = UInt64(reconstruction.originalInputs.count)
        retainedOriginalInputByteCount = reconstruction.originalInputs.reduce(
            into: UInt64(0), { $0 += $1.byteCount })
        optimizerSteps = reconstruction.experiment.requestedTrialBudget
            .optimizerSteps
        trainingTokens = reconstruction.experiment.requestedTrialBudget
            .trainingTokens
        wallClockSeconds = reconstruction.experiment.requestedTrialBudget
            .wallClockSeconds
        outputNamespace = reconstruction.experiment.outputNamespace
        orderedTensorCount = UInt64(
            reconstruction.architecture.orderedTensors.count)
        uniqueParameterStorageCount =
            reconstruction.derivation.uniqueStorageCount
        totalParameterCount = reconstruction.derivation.totalParameterCount
        authority = PrimeLatinProposalIndependentReplayAuthorityBoundaryV1()
    }
}

struct PrimeLatinProposalIndependentReplayGitReferenceV1:
    Equatable,
    Sendable
{
    let pairReceiptSHA256: String
    let sourceRepository: String
    let headCommit: String
    let headTree: String
    let statusSHA256: String
    let statusByteCount: UInt64
    let snapshotArtifactCount: UInt64
    let repositoryArtifacts:
        [PrimeLatinProposalIndependentReplayGitArtifactReferenceV1]
    let authorityExact: Bool
}

struct PrimeLatinProposalIndependentReplayGitArtifactReferenceV1:
    Equatable,
    Sendable
{
    let role: String
    let relativePath: String
    let gitBlobOID: String
    let sha256: String
    let byteCount: UInt64
}

struct PrimeLatinProposalIndependentReplayReferenceV1:
    Equatable,
    Sendable
{
    let pairReceiptSHA256: String
    let pairReceiptByteCount: UInt64
    let source: PrimeLatinReplaySourceV1
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
    let snapshotArtifacts:
        [PrimeLatinProposalIndependentReplayExpectedInputV1]
    let pairAuthorityExact: Bool
    let snapshotAuthorityExact: Bool
    let pairReceiptData: Data
    let candidateCatalogData: Data
    let experimentManifestData: Data
    let git: PrimeLatinProposalIndependentReplayGitReferenceV1
}

struct PrimeLatinProposalIndependentReplaySourceStateV1:
    Equatable,
    Sendable
{
    let originalInputs:
        PrimeLatinProposalIndependentReplayOriginalInputsV1
    let references: PrimeLatinProposalIndependentReplayReferenceV1
}

final class PrimeLatinProposalIndependentReplaySourceCaptureV1:
    @unchecked Sendable
{
    let initial: PrimeLatinProposalIndependentReplaySourceStateV1
    private let recaptureBody:
        @Sendable () throws -> PrimeLatinProposalIndependentReplaySourceStateV1

    init(
        initial: PrimeLatinProposalIndependentReplaySourceStateV1,
        recapture: @escaping @Sendable () throws
            -> PrimeLatinProposalIndependentReplaySourceStateV1
    ) {
        self.initial = initial
        recaptureBody = recapture
    }

    func recapture() throws
        -> PrimeLatinProposalIndependentReplaySourceStateV1
    {
        try recaptureBody()
    }
}

struct PrimeLatinProposalIndependentReplayCaptureDependenciesV1:
    @unchecked Sendable
{
    let captureSource:
        @Sendable () throws
            -> PrimeLatinProposalIndependentReplaySourceCaptureV1
    let beforeSecondReconstruction: @Sendable () throws -> Void
    let beforeFinalRecapture: @Sendable () throws -> Void

    init(
        captureSource: @escaping @Sendable () throws
            -> PrimeLatinProposalIndependentReplaySourceCaptureV1,
        beforeSecondReconstruction:
            @escaping @Sendable () throws -> Void = {},
        beforeFinalRecapture:
            @escaping @Sendable () throws -> Void = {}
    ) {
        self.captureSource = captureSource
        self.beforeSecondReconstruction = beforeSecondReconstruction
        self.beforeFinalRecapture = beforeFinalRecapture
    }
}

public final class PrimeLatinProposalIndependentReplayCaptureV1:
    @unchecked Sendable
{
    public let observation:
        PrimeLatinProposalIndependentReplayObservationV1

    private let lock = NSLock()
    private let sourceCapture:
        PrimeLatinProposalIndependentReplaySourceCaptureV1
    private let expectedPlan:
        PrimeLatinProposalIndependentReplayExpectedPlanV1
    private let dependencies:
        PrimeLatinProposalIndependentReplayCaptureDependenciesV1

    private init(
        sourceCapture:
            PrimeLatinProposalIndependentReplaySourceCaptureV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1,
        dependencies:
            PrimeLatinProposalIndependentReplayCaptureDependenciesV1,
        observation: PrimeLatinProposalIndependentReplayObservationV1
    ) {
        self.sourceCapture = sourceCapture
        self.expectedPlan = expectedPlan
        self.dependencies = dependencies
        self.observation = observation
    }

    public static func capture(
        labRoot: URL,
        llmRepositoryRoot: URL
    ) throws -> PrimeLatinProposalIndependentReplayCaptureV1 {
        try capture(
            expectedPlan: .exactFinal,
            dependencies: .live(
                labRoot: labRoot,
                llmRepositoryRoot: llmRepositoryRoot))
    }

    static func captureForTesting(
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1,
        dependencies:
            PrimeLatinProposalIndependentReplayCaptureDependenciesV1
    ) throws -> PrimeLatinProposalIndependentReplayCaptureV1 {
        try capture(expectedPlan: expectedPlan, dependencies: dependencies)
    }

    @discardableResult
    public func recaptureAndValidateUnchanged() throws
        -> PrimeLatinProposalIndependentReplayObservationV1
    {
        lock.lock()
        defer { lock.unlock() }
        do {
            let current = try Self.observe(
                sourceCapture: sourceCapture,
                expectedPlan: expectedPlan,
                dependencies: dependencies,
                useInitialState: false)
            guard current == observation else {
                throw PrimeLatinProposalIndependentReplayError.captureChanged
            }
            return current
        } catch {
            throw PrimeLatinProposalIndependentReplayError.captureChanged
        }
    }

    static func reconstructForTesting(
        originalInputs:
            PrimeLatinProposalIndependentReplayOriginalInputsV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws -> PrimeLatinProposalIndependentReplayReconstructionV1 {
        try PrimeLatinProposalIndependentReconstructorV1.reconstruct(
            originalInputs: originalInputs,
            expectedPlan: expectedPlan)
    }

    static func compareForTesting(
        reconstruction:
            PrimeLatinProposalIndependentReplayReconstructionV1,
        references: PrimeLatinProposalIndependentReplayReferenceV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws -> PrimeLatinProposalIndependentReplayObservationV1 {
        try PrimeLatinProposalIndependentReplayComparatorV1.compare(
            reconstruction: reconstruction,
            references: references,
            expectedPlan: expectedPlan)
    }

    static func makeAuthorityForTesting()
        -> PrimeLatinProposalIndependentReplayAuthorityBoundaryV1
    {
        PrimeLatinProposalIndependentReplayAuthorityBoundaryV1()
    }

    private static func capture(
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1,
        dependencies:
            PrimeLatinProposalIndependentReplayCaptureDependenciesV1
    ) throws -> PrimeLatinProposalIndependentReplayCaptureV1 {
        let sourceCapture = try dependencies.captureSource()
        let observation = try observe(
            sourceCapture: sourceCapture,
            expectedPlan: expectedPlan,
            dependencies: dependencies,
            useInitialState: true)
        return PrimeLatinProposalIndependentReplayCaptureV1(
            sourceCapture: sourceCapture,
            expectedPlan: expectedPlan,
            dependencies: dependencies,
            observation: observation)
    }

    private static func observe(
        sourceCapture:
            PrimeLatinProposalIndependentReplaySourceCaptureV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1,
        dependencies:
            PrimeLatinProposalIndependentReplayCaptureDependenciesV1,
        useInitialState: Bool
    ) throws -> PrimeLatinProposalIndependentReplayObservationV1 {
        let before = useInitialState
            ? sourceCapture.initial : try sourceCapture.recapture()
        guard before == sourceCapture.initial else {
            throw PrimeLatinProposalIndependentReplayError.captureChanged
        }
        let first = try PrimeLatinProposalIndependentReconstructorV1
            .reconstruct(
                originalInputs: before.originalInputs,
                expectedPlan: expectedPlan)
        try dependencies.beforeSecondReconstruction()
        let second = try PrimeLatinProposalIndependentReconstructorV1
            .reconstruct(
                originalInputs: before.originalInputs,
                expectedPlan: expectedPlan)
        guard first == second else {
            throw PrimeLatinProposalIndependentReplayError.captureChanged
        }
        let firstObservation = try PrimeLatinProposalIndependentReplayComparatorV1
            .compare(
                reconstruction: second,
                references: before.references,
                expectedPlan: expectedPlan)
        try dependencies.beforeFinalRecapture()
        let after = try sourceCapture.recapture()
        guard after == before else {
            throw PrimeLatinProposalIndependentReplayError.captureChanged
        }
        let final = try PrimeLatinProposalIndependentReconstructorV1
            .reconstruct(
                originalInputs: after.originalInputs,
                expectedPlan: expectedPlan)
        let finalObservation = try PrimeLatinProposalIndependentReplayComparatorV1
            .compare(
                reconstruction: final,
                references: after.references,
                expectedPlan: expectedPlan)
        guard final == second,
              finalObservation == firstObservation else {
            throw PrimeLatinProposalIndependentReplayError.captureChanged
        }
        return finalObservation
    }
}

private extension PrimeLatinProposalIndependentReplayCaptureDependenciesV1 {
    static func live(
        labRoot: URL,
        llmRepositoryRoot: URL
    ) -> PrimeLatinProposalIndependentReplayCaptureDependenciesV1 {
        PrimeLatinProposalIndependentReplayCaptureDependenciesV1(
            captureSource: {
                let plan = PrimeLatinProposalIndependentReplayExpectedPlanV1
                    .exactFinal
                let git = try PrimeLatinProposalGitSourceCaptureV3.capture(
                    labRoot: labRoot,
                    llmRepositoryRoot: llmRepositoryRoot,
                    pairSHA256: plan.pairReceiptSHA256)
                let initial = try sourceState(
                    git: git,
                    retained: git.retainedMaterialForIndependentReplayV1())
                return PrimeLatinProposalIndependentReplaySourceCaptureV1(
                    initial: initial,
                    recapture: {
                        _ = try git.recaptureAndValidateUnchanged()
                        return try sourceState(
                            git: git,
                            retained: git
                                .retainedMaterialForIndependentReplayV1())
                    })
            })
    }

    static func sourceState(
        git: PrimeLatinProposalGitSourceCaptureV3,
        retained: PrimeLatinProposalIndependentReplayRetainedMaterialV1
    ) throws -> PrimeLatinProposalIndependentReplaySourceStateV1 {
        let observation = git.observation
        let artifacts = observation.repositoryArtifacts.map {
            PrimeLatinProposalIndependentReplayGitArtifactReferenceV1(
                role: $0.role,
                relativePath: $0.relativePath,
                gitBlobOID: $0.gitBlobOID,
                sha256: $0.observedBlobSHA256,
                byteCount: $0.observedBlobByteCount)
        }
        let authority = observation.authority
        let authorityExact =
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
        let reference = PrimeLatinProposalIndependentReplayReferenceV1(
            pairReceiptSHA256: retained.references.pair.observation
                .pairReceiptSHA256,
            pairReceiptByteCount: retained.references.pair.observation
                .pairReceiptByteCount,
            source: PrimeLatinReplaySourceV1(
                repository: retained.references.pair.observation.llmSource
                    .repository,
                commit: retained.references.pair.observation.llmSource.commit,
                tree: retained.references.pair.observation.llmSource.tree),
            candidateCatalogSHA256: retained.references.pair.observation
                .candidateCatalogSHA256,
            candidateCatalogByteCount: retained.references.pair.observation
                .candidateCatalogByteCount,
            experimentManifestSHA256: retained.references.pair.observation
                .experimentManifestSHA256,
            experimentManifestByteCount: retained.references.pair.observation
                .experimentManifestByteCount,
            candidateDeclarationSetSHA256: retained.references.pair.observation
                .candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                retained.references.pair.observation
                    .candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: retained.references.pair.observation
                .tokenizerBundleSHA256,
            tokenizerBundleByteCount: retained.references.pair.observation
                .tokenizerBundleByteCount,
            candidateIDs: retained.references.pair.observation.candidateIDs,
            candidateIdentitySHA256s: retained.references.pair.observation
                .candidateIdentitySHA256s,
            declarationBundleSHA256s: retained.references.pair.observation
                .declarationBundleSHA256s,
            outputNamespace: retained.references.pair.observation
                .outputNamespace,
            snapshotArtifacts: retained.references.snapshotObservation
                .artifacts.map {
                    PrimeLatinProposalIndependentReplayExpectedInputV1(
                        role: $0.roles.count == 1
                            ? $0.roles[0] : "invalid_role_inventory",
                        scope: $0.scope,
                        relativePath: $0.relativePath,
                        sha256: $0.sha256,
                        byteCount: $0.byteCount)
                },
            pairAuthorityExact: pairAuthorityIsExact(
                retained.references.pair.observation.authority),
            snapshotAuthorityExact: snapshotAuthorityIsExact(
                retained.references.snapshotObservation.authority),
            pairReceiptData: retained.references.pair.receiptData,
            candidateCatalogData:
                retained.references.pair.candidateCatalogData,
            experimentManifestData:
                retained.references.pair.experimentManifestData,
            git: PrimeLatinProposalIndependentReplayGitReferenceV1(
                pairReceiptSHA256: observation.pairReceiptSHA256,
                sourceRepository: observation.llmSource.repository,
                headCommit: observation.headCommit,
                headTree: observation.headTree,
                statusSHA256: observation.porcelainV2StatusSHA256,
                statusByteCount: observation.porcelainV2StatusByteCount,
                snapshotArtifactCount: observation.snapshotArtifactCount,
                repositoryArtifacts: artifacts,
                authorityExact: authorityExact))
        return PrimeLatinProposalIndependentReplaySourceStateV1(
            originalInputs: retained.originalInputs,
            references: reference)
    }

    static func pairAuthorityIsExact(
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

    static func snapshotAuthorityIsExact(
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
}

struct PrimeLatinProposalIndependentReplayExpectedInputV1:
    Equatable,
    Sendable
{
    let role: String
    let scope: PrimeLatinProposalInputArtifactScopeV3
    let relativePath: String
    let sha256: String
    let byteCount: UInt64

    init(
        role: String,
        scope: PrimeLatinProposalInputArtifactScopeV3,
        relativePath: String,
        sha256: String,
        byteCount: UInt64
    ) {
        self.role = role
        self.scope = scope
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
    }
}

struct PrimeLatinProposalIndependentReplayExpectedPlanV1:
    Equatable,
    Sendable
{
    let pairReceiptSHA256: String
    let pairReceiptByteCount: UInt64
    let sourceRepository: String
    let sourceCommit: String
    let sourceTree: String
    let candidateCatalogSHA256: String
    let candidateCatalogByteCount: UInt64
    let experimentManifestSHA256: String
    let experimentManifestByteCount: UInt64
    let declarationTargetClosureSHA256: String
    let declarationTargetClosureByteCount: UInt64
    let candidateIdentitySHA256: String
    let declarationBundleSHA256: String
    let declarationBundleByteCount: UInt64
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let candidateID: String
    let sourceAttribution: String
    let tokenizerID: String
    let vocabularySize: UInt64
    let tokenizerCorpusLineCount: UInt64
    let orderedTensorCount: UInt64
    let uniqueParameterStorageCount: UInt64
    let totalParameterCount: UInt64
    let initializationAlgorithmID: String
    let initializationSeedDerivationSHA256: String
    let evaluationProcedureID: String
    let prospectiveCorpusID: String
    let optimizerSteps: UInt64
    let trainingTokens: UInt64
    let wallClockSeconds: UInt64
    let outputNamespace: String
    let inputBindings:
        [PrimeLatinProposalIndependentReplayExpectedInputV1]
    let gitArtifacts:
        [PrimeLatinProposalIndependentReplayGitArtifactReferenceV1]

    init(
        pairReceiptSHA256: String,
        pairReceiptByteCount: UInt64,
        sourceRepository: String,
        sourceCommit: String,
        sourceTree: String,
        candidateCatalogSHA256: String,
        candidateCatalogByteCount: UInt64,
        experimentManifestSHA256: String,
        experimentManifestByteCount: UInt64,
        declarationTargetClosureSHA256: String,
        declarationTargetClosureByteCount: UInt64,
        candidateIdentitySHA256: String,
        declarationBundleSHA256: String,
        declarationBundleByteCount: UInt64,
        candidateDeclarationSetSHA256: String,
        candidateDeclarationSetByteCount: UInt64,
        tokenizerBundleSHA256: String,
        tokenizerBundleByteCount: UInt64,
        candidateID: String,
        sourceAttribution: String,
        tokenizerID: String,
        vocabularySize: UInt64,
        tokenizerCorpusLineCount: UInt64,
        orderedTensorCount: UInt64 = 12,
        uniqueParameterStorageCount: UInt64 = 11,
        totalParameterCount: UInt64 = 131_736,
        initializationAlgorithmID: String =
            "latin_structural_fixture_v3_776c412e_sha256_domain_v1",
        initializationSeedDerivationSHA256: String =
            "82f8dbc28cfd3f538901bd1a36da5e3dafa9b8de7ee6d9ec50aad2e122daaf1a",
        evaluationProcedureID: String =
            "latin_structural_fixture_evaluation_v1",
        prospectiveCorpusID: String =
            "latin_structural_fixture_v3_776c412e",
        optimizerSteps: UInt64,
        trainingTokens: UInt64,
        wallClockSeconds: UInt64,
        outputNamespace: String,
        inputBindings:
            [PrimeLatinProposalIndependentReplayExpectedInputV1],
        gitArtifacts:
            [PrimeLatinProposalIndependentReplayGitArtifactReferenceV1]
    ) {
        self.pairReceiptSHA256 = pairReceiptSHA256
        self.pairReceiptByteCount = pairReceiptByteCount
        self.sourceRepository = sourceRepository
        self.sourceCommit = sourceCommit
        self.sourceTree = sourceTree
        self.candidateCatalogSHA256 = candidateCatalogSHA256
        self.candidateCatalogByteCount = candidateCatalogByteCount
        self.experimentManifestSHA256 = experimentManifestSHA256
        self.experimentManifestByteCount = experimentManifestByteCount
        self.declarationTargetClosureSHA256 =
            declarationTargetClosureSHA256
        self.declarationTargetClosureByteCount =
            declarationTargetClosureByteCount
        self.candidateIdentitySHA256 = candidateIdentitySHA256
        self.declarationBundleSHA256 = declarationBundleSHA256
        self.declarationBundleByteCount = declarationBundleByteCount
        self.candidateDeclarationSetSHA256 =
            candidateDeclarationSetSHA256
        self.candidateDeclarationSetByteCount =
            candidateDeclarationSetByteCount
        self.tokenizerBundleSHA256 = tokenizerBundleSHA256
        self.tokenizerBundleByteCount = tokenizerBundleByteCount
        self.candidateID = candidateID
        self.sourceAttribution = sourceAttribution
        self.tokenizerID = tokenizerID
        self.vocabularySize = vocabularySize
        self.tokenizerCorpusLineCount = tokenizerCorpusLineCount
        self.orderedTensorCount = orderedTensorCount
        self.uniqueParameterStorageCount = uniqueParameterStorageCount
        self.totalParameterCount = totalParameterCount
        self.initializationAlgorithmID = initializationAlgorithmID
        self.initializationSeedDerivationSHA256 =
            initializationSeedDerivationSHA256
        self.evaluationProcedureID = evaluationProcedureID
        self.prospectiveCorpusID = prospectiveCorpusID
        self.optimizerSteps = optimizerSteps
        self.trainingTokens = trainingTokens
        self.wallClockSeconds = wallClockSeconds
        self.outputNamespace = outputNamespace
        self.inputBindings = inputBindings
        self.gitArtifacts = gitArtifacts
    }

    static let exactFinal = PrimeLatinProposalIndependentReplayExpectedPlanV1(
        pairReceiptSHA256:
            "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7",
        pairReceiptByteCount: 1_833,
        sourceRepository: "Ergentics/ergentics-llm",
        sourceCommit: "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831",
        sourceTree: "c1f41758aea2860ab06039776f5ea0403dff1b61",
        candidateCatalogSHA256:
            "12387e11fdbf68ab5b76cad79c6c958e9b82ddeca1cb588b844918a2ab0dc6b4",
        candidateCatalogByteCount: 20_803,
        experimentManifestSHA256:
            "8436ab6d656b2393792c564d0bdb9a25d1ade9f5c457ad3b96cf99bacc708a76",
        experimentManifestByteCount: 3_364,
        declarationTargetClosureSHA256:
            "815b3231fbb000968bbe2c19efe92013540d7241cba728c9b0ec1e89e9a4d193",
        declarationTargetClosureByteCount: 1_961,
        candidateIdentitySHA256:
            "64a288b62cdef276923eb72e5cc4d209a7195526408414fc5167522151481265",
        declarationBundleSHA256:
            "6f07896e50b2b530ea5f5924859d1e66bf9880366c16cf37832138a0e6c7f4bd",
        declarationBundleByteCount: 14_302,
        candidateDeclarationSetSHA256:
            "45c787dba8c538794cbaf7cb90acb4528d2dedcaf666a1f0da151ca236138881",
        candidateDeclarationSetByteCount: 14_860,
        tokenizerBundleSHA256:
            "9fa3b6eea42a9c4c13ec1ecda2309ec4c35b3022638ae61a08dd2f0fcb9b074c",
        tokenizerBundleByteCount: 2_930,
        candidateID: "latin_structural_fixture_v1",
        sourceAttribution:
            "ergentics_codex_assisted_structural_fixture",
        tokenizerID: "ergentics_latin_bpe_v2",
        vocabularySize: 16_384,
        tokenizerCorpusLineCount: 98_858,
        optimizerSteps: 1,
        trainingTokens: 128,
        wallClockSeconds: 60,
        outputNamespace:
            "models/latin-prospective/structural-fixture-v3-776c412e",
        inputBindings: [
            input(
                "root_package_manifest", .ergenticsLLMRepository,
                "Package.swift",
                "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902",
                6_109),
            input(
                "root_dependency_lock", .ergenticsLLMRepository,
                "Package.resolved",
                "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530",
                645),
            input(
                "declaration_package_manifest", .ergenticsLLMRepository,
                "Research/Latin/CandidateDeclarations/Package.swift",
                "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63",
                892),
            input(
                "declaration_production_source", .ergenticsLLMRepository,
                "Research/Latin/CandidateDeclarations/Sources/ErgenticsLatinCandidateDeclarations/ErgenticsLatinCandidateDeclarations.swift",
                "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4",
                35_119),
            input(
                "candidate_architecture", .ergenticsLLMRepository,
                "Research/Latin/candidates/latin_structural_fixture_v1/architecture.json",
                "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70",
                2_794),
            input(
                "candidate_parameter_count_derivation",
                .ergenticsLLMRepository,
                "Research/Latin/candidates/latin_structural_fixture_v1/parameter-count-derivation.json",
                "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f",
                2_702),
            input(
                "evaluation_contract", .ergenticsLLMRepository,
                "Research/Latin/evaluation_contract.json",
                "4a0dd1bc973f7ce380df9775413c4e43033ba0cc409fb45a9368c2bef6835d52",
                164),
            input(
                "tokenizer_manifest", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/manifest.json",
                "b1ae203307de9c657f9d2558875e104d33f62e464c2cb83504d2f2f714ac6b76",
                2_180),
            input(
                "tokenizer_sentencepiece_model", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/model.spm",
                "3819dbc5381bfd5f52cc8b28e6f1e224ea5e30bdaaaf94dc5307fde91c9cccb5",
                285_705),
            input(
                "tokenizer_vocabulary", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/vocab.txt",
                "fb7f86c49cca2b9115f55ff559ac76e8977110e1251a3a21baa9e7dc9132c3ce",
                256_196),
            input(
                "tokenizer_recommendation", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/recommendation.json",
                "ce4c3be2e999057a102465593e2c87c4cd7424a7f633427c97c0790c20f34596",
                1_836),
            input(
                "tokenizer_approval", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/approval.json",
                "34162b2625ba160f0cc3d38c8ec7ef2c8930b0b4376a19bfd9b0fff8c96d936b",
                277),
            input(
                "tokenizer_staged_training_input", .ergenticsMLXLab,
                "tokenizer/ergentics_latin_bpe_v2/staging/train-input.txt",
                "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
                3_743_426),
            input(
                "tokenizer_corpus_manifest", .ergenticsMLXLab,
                "corpus/la/L1/primary-corpus-manifest.json",
                "87a4dcdfbbd8a9ad3f297b320bc94012e98835f395d79b6e6d99e6ce410c36b4",
                1_715),
            input(
                "tokenizer_admitted_corpus_input", .ergenticsMLXLab,
                "corpus/la/L1/train.txt",
                "7a4dbdfc9885d734e802d912c72ee904f957f856ec0e4827a9583a7b8d357e76",
                3_743_426),
            input(
                "initialization_contract", .ergenticsMLXLab,
                "evidence/latin-proposal-inputs/v3/776c412e/initialization-contract.json",
                "b5a959d839d41c2956a3f3d74515d4e7d0c403a23c35aaa201f18d0f4a3b2446",
                281),
            input(
                "prospective_corpus_manifest", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/corpus-manifest.json",
                "ac3fed959b9f5736124de80fba5b09206afda730099cc2f8706849687cfa7313",
                772),
            input(
                "training_split", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/training.txt",
                "57ce94783f3f93b18de0420b60f1900c15647b57868916c74bf3c94f3c35b695",
                61),
            input(
                "validation_split", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/validation.txt",
                "845a5ec82d415a7c00decc6933ae448aecfe5c7ac2fe8d369d5c066df25de78b",
                51),
            input(
                "selection_split", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/selection.txt",
                "d69252b64c20d2fd7f4a219e85d7dfe0b93a0e8bf8aded46b4fc70834e2d74a3",
                50),
            input(
                "selection_observation_declaration", .ergenticsMLXLab,
                "corpus/la/L1/prospective-v3-776c412e/selection-observation.json",
                "440965ad0976163f2e0d3c08868ee01a4a04b94fe808d85db5c9558965ab855f",
                311),
        ],
        gitArtifacts: [
            git(
                "root_package_manifest", "Package.swift",
                "dabd1cd7002ddbfa4d05d7c4f7660133892d0050",
                "ab460122d5f364046224c6445a20f3beb34e2831de94db1271bbafb59726c902",
                6_109),
            git(
                "root_dependency_lock", "Package.resolved",
                "4e822bfadbe5f4dced15a277f4d5423a03d76890",
                "2847fb936ec74eef250b8439d778f0a1ea8d0c630bf09438587764a4b99c6530",
                645),
            git(
                "declaration_package_manifest",
                "Research/Latin/CandidateDeclarations/Package.swift",
                "67907b47cf941c6e36154dd729b284f64c90ca9b",
                "9d5242248391613382c9c42bb388b1ad1d1597956f272e5d5b410b7891b38b63",
                892),
            git(
                "declaration_production_source",
                "Research/Latin/CandidateDeclarations/Sources/ErgenticsLatinCandidateDeclarations/ErgenticsLatinCandidateDeclarations.swift",
                "a951d3710dba072aa7eb8554c60abafdd032cb7f",
                "676443927b5024c6e58caa562777a27945dad384c6cc88b5d94d11e73c047bc4",
                35_119),
            git(
                "candidate_architecture",
                "Research/Latin/candidates/latin_structural_fixture_v1/architecture.json",
                "a3a9582003bfdbce2c94707313c0e402955bca9b",
                "4b31feeeba780bc39c064d4540f5701935f960e1e1d8c82c81d295a65e643a70",
                2_794),
            git(
                "candidate_parameter_count_derivation",
                "Research/Latin/candidates/latin_structural_fixture_v1/parameter-count-derivation.json",
                "9957d0b17edd019ce760fdae9907a8ebadf408e3",
                "45d15481883cf606e8e739aa71815bf9bd2fdd51494059328e3ba16a9ed5fb8f",
                2_702),
            git(
                "evaluation_contract",
                "Research/Latin/evaluation_contract.json",
                "0f052ee6724d4815b8c18eae968175631035f00d",
                "4a0dd1bc973f7ce380df9775413c4e43033ba0cc409fb45a9368c2bef6835d52",
                164),
        ])

    private static func input(
        _ role: String,
        _ scope: PrimeLatinProposalInputArtifactScopeV3,
        _ relativePath: String,
        _ sha256: String,
        _ byteCount: UInt64
    ) -> PrimeLatinProposalIndependentReplayExpectedInputV1 {
        .init(
            role: role,
            scope: scope,
            relativePath: relativePath,
            sha256: sha256,
            byteCount: byteCount)
    }

    private static func git(
        _ role: String,
        _ relativePath: String,
        _ gitBlobOID: String,
        _ sha256: String,
        _ byteCount: UInt64
    ) -> PrimeLatinProposalIndependentReplayGitArtifactReferenceV1 {
        .init(
            role: role,
            relativePath: relativePath,
            gitBlobOID: gitBlobOID,
            sha256: sha256,
            byteCount: byteCount)
    }
}

struct PrimeLatinProposalIndependentReplayReconstructionV1:
    Equatable,
    Sendable
{
    let source: PrimeLatinReplaySourceV1
    let originalInputs:
        [PrimeLatinProposalIndependentReplayOriginalInputV1]
    let architecture: PrimeLatinReplayArchitectureV1
    let derivation: PrimeLatinReplayDerivationV1
    let tokenizerBundle: PrimeLatinReplayTokenizerBundleV1
    let candidateCatalog: PrimeLatinReplayCandidateCatalogV1
    let experiment: PrimeLatinReplayExperimentManifestV1
    let pairReceipt: PrimeLatinReplayPairReceiptV1
    let candidateCatalogData: Data
    let experimentManifestData: Data
    let pairReceiptData: Data
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let candidateIDs: [String]
    let candidateIdentitySHA256s: [String]
    let declarationBundleSHA256s: [String]
}

enum PrimeLatinReplayScopeV1: String, Codable, Sendable {
    case ergenticsLLMRepository = "ergentics_llm_repository"
    case ergenticsMLXLab = "ergentics_mlx_lab"

    init(_ value: PrimeLatinProposalInputArtifactScopeV3) {
        switch value {
        case .ergenticsLLMRepository: self = .ergenticsLLMRepository
        case .ergenticsMLXLab: self = .ergenticsMLXLab
        }
    }
}

struct PrimeLatinReplaySourceV1: Codable, Equatable, Sendable {
    let repository: String
    let commit: String
    let tree: String
}

struct PrimeLatinReplayArtifactBindingV1:
    Codable,
    Equatable,
    Sendable
{
    let scope: PrimeLatinReplayScopeV1
    let relativePath: String
    let sha256: String
    let byteCount: UInt64

    init(_ input: PrimeLatinProposalIndependentReplayOriginalInputV1) {
        scope = PrimeLatinReplayScopeV1(input.scope)
        relativePath = input.relativePath
        sha256 = input.sha256
        byteCount = input.byteCount
    }
}

struct PrimeLatinReplayCommittedBindingV1:
    Codable,
    Equatable,
    Sendable
{
    let artifact: PrimeLatinReplayArtifactBindingV1
    let gitBlobOID: String
}

struct PrimeLatinReplayTokenizerRoleBindingV1:
    Codable,
    Equatable,
    Sendable
{
    let role: String
    let artifact: PrimeLatinReplayArtifactBindingV1
}

struct PrimeLatinReplayTokenizerAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    let primeProposalAuthority = "absent"
    let architectureAuthority = false
    let trialExecutionAuthority = false
    let trainingAuthority = false
    let promotionAuthority = false
    let productUseAuthority = false
}

struct PrimeLatinReplayTokenizerBundleV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_tokenizer_bundle_v2"
    let tokenizerID: String
    let bindingScope =
        "direct_tokenizer_bundle_and_declared_corpus_manifest"
    let tokenizerManifest: PrimeLatinReplayTokenizerRoleBindingV1
    let sentencePieceModel: PrimeLatinReplayTokenizerRoleBindingV1
    let vocabulary: PrimeLatinReplayTokenizerRoleBindingV1
    let recommendation: PrimeLatinReplayTokenizerRoleBindingV1
    let approval: PrimeLatinReplayTokenizerRoleBindingV1
    let stagedTrainingInput: PrimeLatinReplayTokenizerRoleBindingV1
    let corpusManifest: PrimeLatinReplayTokenizerRoleBindingV1
    let manifestListedCorpusInputs: [PrimeLatinReplayTokenizerRoleBindingV1]
    let recommendationApprovalAttributionAssurance =
        "trusted_local_declaration"
    let cryptographicHumanAuthentication = false
    let corpusProvenanceScope =
        "manifest_declarations_bound_only_admitted_train_bytes_observed"
    let modelSemanticValidation = "opaque_bytes_hash_and_count_only"
    let sentencePieceToolDisposition =
        "third_party_tool_and_format_recorded_provenance_not_independently_replayed"
    let sentencePieceTrainerValidation =
        "recorded_declaration_only_binary_not_observed"
    let trainingReplayStatus = "not_performed"
    let snapshotConsistency =
        "cooperative_descriptor_reads_revalidated_not_atomic"
    let authorityStatus =
        "root_bound_tokenizer_input_only_non_authorizing"
    let authority = PrimeLatinReplayTokenizerAuthorityV1()
}

struct PrimeLatinReplayTokenizerProposalV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_tokenizer_proposal_binding_v2"
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let tokenizerBundle: PrimeLatinReplayTokenizerBundleV1
    let bindingScope = "full_admitted_tokenizer_bundle_eight_live_inputs"
    let liveRevalidationPolicy =
        "proposal_workspace_descriptor_safe_revalidation_required"
    let publicationStatus = "not_implemented_input_bridge_only"
    let authorityStatus = "tokenizer_proposal_input_only_non_authorizing"
}

struct PrimeLatinReplayUnreachablePinV1:
    Codable,
    Equatable,
    Sendable
{
    let identity: String
    let kind: String
    let location: String
    let revision: String
    let version: String?
    let reachableFromDeclarationTarget = false

    enum CodingKeys: String, CodingKey {
        case identity, kind, location, revision, version
        case reachableFromDeclarationTarget =
            "reachable_from_declaration_target"
    }
}

struct PrimeLatinReplayDeclarationClosureV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_declaration_target_closure_v1"
    let scope = "nested_declaration_target_only_not_runtime"
    let targetName = "ErgenticsLatinCandidateDeclarations"
    let nestedPackageManifest: PrimeLatinReplayCommittedBindingV1
    let productionSources: [PrimeLatinReplayCommittedBindingV1]
    let rootPackageLock: PrimeLatinReplayCommittedBindingV1
    let directTargetDependencies: [String] = []
    let reachableLocalTargets = ["ErgenticsLatinCandidateDeclarations"]
    let reachableExternalProducts: [String] = []
    let reachablePackagePins: [String] = []
    let unreachableRootPackagePins: [PrimeLatinReplayUnreachablePinV1]
    let pathDependencyCount: UInt64 = 0
    let binaryTargetCount: UInt64 = 0
    let systemLibraryTargetCount: UInt64 = 0
    let pluginCount: UInt64 = 0
    let macroCount: UInt64 = 0
    let unsafeFlagCount: UInt64 = 0
    let nestedPackageLockStatus = "absent_required"
    let declarationTargetSourceClosure = "established"
    let declarationTargetDependencyClosure = "exact_zero"
}

struct PrimeLatinReplayCandidateAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    let runtimeDecoderImplementation = "absent"
    let runtimeDependencyClosure = "not_established"
    let initialization = "not_established"
    let primeProposal = "absent"
    let primeDecisionReceipt = "absent"
    let primeAuthority = false
    let executionAuthority = false
    let trainingAuthority = false
    let promotionAuthority = false
    let productAuthority = false
    let publicationAuthority = false

    enum CodingKeys: String, CodingKey {
        case runtimeDecoderImplementation = "runtime_decoder_implementation"
        case runtimeDependencyClosure = "runtime_dependency_closure"
        case initialization
        case primeProposal = "prime_proposal"
        case primeDecisionReceipt = "prime_decision_receipt"
        case primeAuthority = "prime_authority"
        case executionAuthority = "execution_authority"
        case trainingAuthority = "training_authority"
        case promotionAuthority = "promotion_authority"
        case productAuthority = "product_authority"
        case publicationAuthority = "publication_authority"
    }
}

struct PrimeLatinReplayCandidateTokenizerV1:
    Codable,
    Equatable,
    Sendable
{
    let tokenizerID: String
    let proposalBundleSHA256: String
    let proposalBundleByteCount: UInt64
    let vocabularySize: UInt64
    let unknownTokenID: UInt64
    let beginningOfSequenceTokenID: UInt64
    let endOfSequenceTokenID: UInt64
    let paddingTokenID: UInt64

    enum CodingKeys: String, CodingKey {
        case tokenizerID = "tokenizer_id"
        case proposalBundleSHA256 = "proposal_bundle_sha256"
        case proposalBundleByteCount = "proposal_bundle_byte_count"
        case vocabularySize = "vocabulary_size"
        case unknownTokenID = "unk_token_id"
        case beginningOfSequenceTokenID = "bos_token_id"
        case endOfSequenceTokenID = "eos_token_id"
        case paddingTokenID = "pad_token_id"
    }
}

struct PrimeLatinReplayGeometryV1:
    Codable,
    Equatable,
    Sendable
{
    let maximumSequenceLength: UInt64
    let modelWidth: UInt64
    let layerCount: UInt64
    let attentionHeadCount: UInt64
    let attentionHeadWidth: UInt64
    let intermediateWidth: UInt64

    enum CodingKeys: String, CodingKey {
        case maximumSequenceLength = "maximum_sequence_length"
        case modelWidth = "model_width"
        case layerCount = "layer_count"
        case attentionHeadCount = "attention_head_count"
        case attentionHeadWidth = "attention_head_width"
        case intermediateWidth = "intermediate_width"
    }
}

struct PrimeLatinReplayAttentionV1:
    Codable,
    Equatable,
    Sendable
{
    let mechanism = "multi_head_self_attention"
    let causalMaskPolicy = "required"
    let biasPolicy = "none"

    enum CodingKeys: String, CodingKey {
        case mechanism
        case causalMaskPolicy = "causal_mask_policy"
        case biasPolicy = "bias_policy"
    }
}

struct PrimeLatinReplayFeedForwardV1:
    Codable,
    Equatable,
    Sendable
{
    let mechanism = "gated_mlp"
    let activation = "silu"
    let gatingPolicy = "multiplicative_gate"
    let biasPolicy = "none"

    enum CodingKeys: String, CodingKey {
        case mechanism, activation
        case gatingPolicy = "gating_policy"
        case biasPolicy = "bias_policy"
    }
}

struct PrimeLatinReplayEpsilonV1:
    Codable,
    Equatable,
    Sendable
{
    let numerator: UInt64 = 1
    let denominator: UInt64 = 100_000
}

struct PrimeLatinReplayNormalizationV1:
    Codable,
    Equatable,
    Sendable
{
    let placement = "pre_norm"
    let mechanism = "rms_norm"
    let parameterPolicy = "learned_scale_only"
    let epsilon = PrimeLatinReplayEpsilonV1()

    enum CodingKeys: String, CodingKey {
        case placement, mechanism
        case parameterPolicy = "parameter_policy"
        case epsilon
    }
}

struct PrimeLatinReplayPoliciesV1:
    Codable,
    Equatable,
    Sendable
{
    let attention = PrimeLatinReplayAttentionV1()
    let feedForward = PrimeLatinReplayFeedForwardV1()
    let normalization = PrimeLatinReplayNormalizationV1()
    let position = "rotary_no_learned_parameters"
    let projection = "token_embedding_tied_output_projection"

    enum CodingKeys: String, CodingKey {
        case attention
        case feedForward = "feed_forward"
        case normalization, position, projection
    }
}

struct PrimeLatinReplayTensorV1:
    Codable,
    Equatable,
    Sendable
{
    let role: String
    let storageID: String
    let dimensions: [UInt64]

    enum CodingKeys: String, CodingKey {
        case role
        case storageID = "storage_id"
        case dimensions
    }
}

struct PrimeLatinReplayTermV1:
    Codable,
    Equatable,
    Sendable
{
    let role: String
    let storageID: String
    let dimensions: [UInt64]
    let elementCount: UInt64
    let countedAsUniqueStorage: Bool

    enum CodingKeys: String, CodingKey {
        case role
        case storageID = "storage_id"
        case dimensions
        case elementCount = "element_count"
        case countedAsUniqueStorage = "counted_as_unique_storage"
    }
}

struct PrimeLatinReplayArchitectureV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_candidate_architecture_v1"
    let candidateSlug: String
    let fixtureOnly = true
    let sourceAttribution: String
    let cryptographicHumanAuthentication = false
    let tokenizer: PrimeLatinReplayCandidateTokenizerV1
    let geometry: PrimeLatinReplayGeometryV1
    let policies = PrimeLatinReplayPoliciesV1()
    let orderedTensors: [PrimeLatinReplayTensorV1]
    let authorityBoundary = PrimeLatinReplayCandidateAuthorityV1()

    enum CodingKeys: String, CodingKey {
        case schema
        case candidateSlug = "candidate_slug"
        case fixtureOnly = "fixture_only"
        case sourceAttribution = "source_attribution"
        case cryptographicHumanAuthentication =
            "cryptographic_human_authentication"
        case tokenizer, geometry, policies
        case orderedTensors = "ordered_tensors"
        case authorityBoundary = "authority_boundary"
    }
}

struct PrimeLatinReplayDerivationV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_parameter_count_derivation_v1"
    let architectureSchema = "ergentics_latin_candidate_architecture_v1"
    let candidateSlug: String
    let fixtureOnly = true
    let sourceAttribution: String
    let cryptographicHumanAuthentication = false
    let status = "declarative_recomputed_not_runtime_reconciled"
    let orderedTerms: [PrimeLatinReplayTermV1]
    let uniqueStorageCount: UInt64
    let totalParameterCount: UInt64
    let authorityBoundary = PrimeLatinReplayCandidateAuthorityV1()

    enum CodingKeys: String, CodingKey {
        case schema
        case architectureSchema = "architecture_schema"
        case candidateSlug = "candidate_slug"
        case fixtureOnly = "fixture_only"
        case sourceAttribution = "source_attribution"
        case cryptographicHumanAuthentication =
            "cryptographic_human_authentication"
        case status
        case orderedTerms = "ordered_terms"
        case uniqueStorageCount = "unique_storage_count"
        case totalParameterCount = "total_parameter_count"
        case authorityBoundary = "authority_boundary"
    }
}

struct PrimeLatinReplayIdentityMaterialV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_candidate_identity_material_domain_v1"
    let laneID = "latin_primary_prospective_v1"
    let llmSource: PrimeLatinReplaySourceV1
    let candidateSlug: String
    let sourceAttribution: String
    let tokenizerID: String
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let tokenizerVocabularySize: UInt64
    let architectureSHA256: String
    let architectureByteCount: UInt64
    let parameterCountDerivationSHA256: String
    let parameterCountDerivationByteCount: UInt64
    let declarationTargetClosureSHA256: String
    let declarationTargetClosureByteCount: UInt64
}

struct PrimeLatinReplayDeclarationBundleV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_candidate_declaration_input_bundle_v1"
    let laneID = "latin_primary_prospective_v1"
    let llmSource: PrimeLatinReplaySourceV1
    let tokenizerProposalBinding: PrimeLatinReplayTokenizerProposalV1
    let nestedPackageManifest: PrimeLatinReplayCommittedBindingV1
    let productionSources: [PrimeLatinReplayCommittedBindingV1]
    let architectureArtifact: PrimeLatinReplayCommittedBindingV1
    let architecture: PrimeLatinReplayArchitectureV1
    let parameterCountDerivationArtifact: PrimeLatinReplayCommittedBindingV1
    let parameterCountDerivation: PrimeLatinReplayDerivationV1
    let declarationTargetClosure: PrimeLatinReplayDeclarationClosureV1
    let identityMaterial: PrimeLatinReplayIdentityMaterialV1
    let candidateIdentitySHA256: String
    let declarationTargetSourceClosure = "established"
    let declarationTargetDependencyClosure = "exact_zero"
    let parameterCountStatus =
        "declarative_recomputed_not_runtime_reconciled"
    let runtimeDecoderImplementation = "absent"
    let runtimeDependencyClosure = "not_established"
    let initializationStatus = "not_established"
    let publicationStatus = "not_implemented_encode_only"
    let authority = PrimeLatinReplayCandidateAuthorityV1()
}

struct PrimeLatinReplayDeclarationBindingV1:
    Codable,
    Equatable,
    Sendable
{
    let candidateID: String
    let sourceAttribution: String
    let attributionAssurance = "trusted_local_declaration"
    let cryptographicHumanAuthentication = false
    let candidateIdentitySHA256: String
    let declarationBundleSHA256: String
    let declarationBundleByteCount: UInt64
    let declarationBundle: PrimeLatinReplayDeclarationBundleV1
}

struct PrimeLatinReplayDeclarationSetV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_candidate_declaration_set_v3"
    let laneID = "latin_primary_prospective_v1"
    let candidates: [PrimeLatinReplayDeclarationBindingV1]
}

struct PrimeLatinReplayDependencyQuarantineV1:
    Codable,
    Equatable,
    Sendable
{
    let policyID = "ergentics_latin_first_party_dependency_quarantine_v1"
    let packageManifest: PrimeLatinReplayArtifactBindingV1
    let dependencyLock: PrimeLatinReplayArtifactBindingV1
    let candidateImplementationSources: [PrimeLatinReplayArtifactBindingV1] = []
    let authorityTargetDependencyCount: UInt64 = 0
    let lockfilePinScanComplete = true
    let status = "producer_recomputed_pass"
}

struct PrimeLatinReplayCandidateCatalogV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_candidate_catalog_v3"
    let laneID = "latin_primary_prospective_v1"
    let llmSource: PrimeLatinReplaySourceV1
    let packageManifest: PrimeLatinReplayArtifactBindingV1
    let dependencyLock: PrimeLatinReplayArtifactBindingV1
    let tokenizerProposalBinding: PrimeLatinReplayTokenizerProposalV1
    let initializationContract: PrimeLatinReplayArtifactBindingV1
    let candidateDeclarations: PrimeLatinReplayDeclarationSetV1
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let ergenticsMLXLocation =
        "https://github.com/Ergentics/ergentics-mlx-swift"
    let ergenticsMLXRevision =
        "d37885a278f1c37484a94d0f401a418735e66519"
    let quarantinePolicyID =
        "ergentics_latin_first_party_dependency_quarantine_v1"
    let proposalInputDependencyQuarantine:
        PrimeLatinReplayDependencyQuarantineV1
    let declarationTargetSourceClosureStatus = "established"
    let declarationTargetDependencyClosureStatus = "exact_zero"
    let runtimeDecoderImplementationStatus = "absent"
    let runtimeCandidateDependencyClosureStatus = "not_established"
    let initializationStatus =
        "contract_bound_runtime_initialization_not_established"
    let parameterCountStatus =
        "declarative_recomputed_not_runtime_reconciled"
    let completenessStatus =
        "candidate_declaration_bound_decoder_absent_runtime_initialization_and_runtime_dependency_closure_not_established_by_bridge"
    let primeConsumerStatus = "not_implemented_v3"
    let publicationStatus = "not_implemented_input_bridge_only"
    let authorityStatus =
        "root_bound_declaration_proposal_input_v3_only_non_authorizing"
}

struct PrimeLatinReplaySplitSetV1:
    Codable,
    Equatable,
    Sendable
{
    let trainingSplitID: String
    let validationSplitID: String
    let selectionSplitID: String
    let selectionDataStatus = "trusted_local_declared_unverified"
    let trainingSplit: PrimeLatinReplayArtifactBindingV1
    let validationSplit: PrimeLatinReplayArtifactBindingV1
    let selectionSplit: PrimeLatinReplayArtifactBindingV1
    let selectionObservationDeclaration: PrimeLatinReplayArtifactBindingV1
}

struct PrimeLatinReplayBudgetV1:
    Codable,
    Equatable,
    Sendable
{
    let application = "identical_per_candidate_requested_ceiling"
    let optimizerSteps: UInt64
    let trainingTokens: UInt64
    let wallClockSeconds: UInt64
}

struct PrimeLatinReplayExperimentAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    let primeProposalPacket = "absent"
    let primeTrialAuthorization = "absent"
    let primeDecisionReceipt = "absent"
    let candidateSelectionAuthorized = false
    let trialExecutionAuthorized = false
    let furtherTrainingAuthorized = false
    let promotionAuthorized = false
    let productUseAuthorized = false
    let publicationAuthorized = false
}

struct PrimeLatinReplayExperimentManifestV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_experiment_manifest_v3"
    let laneID = "latin_primary_prospective_v1"
    let llmSource: PrimeLatinReplaySourceV1
    let candidateCatalogSHA256: String
    let candidateCatalogByteCount: UInt64
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let candidateIDs: [String]
    let dependencyLock: PrimeLatinReplayArtifactBindingV1
    let tokenizerBundleSHA256: String
    let tokenizerBundleByteCount: UInt64
    let initializationContract: PrimeLatinReplayArtifactBindingV1
    let corpusManifest: PrimeLatinReplayArtifactBindingV1
    let evaluationContract: PrimeLatinReplayArtifactBindingV1
    let splits: PrimeLatinReplaySplitSetV1
    let requestedTrialBudget: PrimeLatinReplayBudgetV1
    let outputNamespace: String
    let outputDisposition = "must_be_absent_create_once_non_restorable"
    let completenessStatus =
        "evaluator_and_prospective_data_completeness_not_established_by_bridge"
    let primeConsumerStatus = "not_implemented_v3"
    let publicationStatus = "not_implemented_input_bridge_only"
    let authority = PrimeLatinReplayExperimentAuthorityV1()
}

struct PrimeLatinReplayPublishedDocumentV1:
    Codable,
    Equatable,
    Sendable
{
    let documentKind: String
    let relativePath: String
    let sha256: String
    let byteCount: UInt64
}

struct PrimeLatinReplayPairAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    let primeProposalPacket = "absent"
    let primeTrialAuthorization = "absent"
    let primeDecisionReceipt = "absent"
    let candidateSelectionAuthorized = false
    let trialExecutionAuthorized = false
    let furtherTrainingAuthorized = false
    let promotionAuthorized = false
    let productUseAuthorized = false
    let publicationAuthorized = false
}

struct PrimeLatinReplayPairReceiptV1:
    Codable,
    Equatable,
    Sendable
{
    let schema = "ergentics_latin_proposal_pair_receipt_v3"
    let llmSource: PrimeLatinReplaySourceV1
    let candidateCatalog: PrimeLatinReplayPublishedDocumentV1
    let experimentManifest: PrimeLatinReplayPublishedDocumentV1
    let candidateDeclarationSetSHA256: String
    let candidateDeclarationSetByteCount: UInt64
    let publicationMechanicsStatus =
        "content_addressed_create_once_pair_complete"
    let authorityStatus = "mechanics_only_non_authorizing"
    let completionScope = "canonical_v3_catalog_experiment_pair_only"
    let referencedInputSnapshot = "absent"
    let referencedArtifactBytes =
        "absent_from_pair_except_catalog_and_experiment_children"
    let independentReplayStatus =
        "requires_original_bound_input_bytes_and_live_provenance"
    let primeConsumerStatus = "prime_consumer_state_not_observed_by_producer"
    let externalStateCommitAtomicity =
        "absent_live_roots_revalidated_before_receipt_rename"
    let publicationCoordination = "cooperative_process_lock_only"
    let authority = PrimeLatinReplayPairAuthorityV1()
}

private struct PrimeLatinReplayResolvedFileV1: Codable {
    let version: UInt64
    let originHash: String
    let pins: [PrimeLatinReplayResolvedPinV1]
}

private struct PrimeLatinReplayResolvedPinV1: Codable {
    let identity: String
    let kind: String
    let location: String
    let state: PrimeLatinReplayResolvedStateV1
}

private struct PrimeLatinReplayResolvedStateV1: Codable {
    let revision: String
    let version: String?
}

private struct PrimeLatinReplayTokenizerNormalizationV1:
    Codable,
    Equatable
{
    let swiftPreNormalization: String
    let sentencePieceRule: String
    let addDummyPrefix: Bool
    let removeExtraWhitespaces: Bool
    let escapeWhitespaces: Bool

    enum CodingKeys: String, CodingKey {
        case swiftPreNormalization = "swift_pre_normalization"
        case sentencePieceRule = "sentencepiece_rule"
        case addDummyPrefix = "add_dummy_prefix"
        case removeExtraWhitespaces = "remove_extra_whitespaces"
        case escapeWhitespaces = "escape_whitespaces"
    }
}

private struct PrimeLatinReplaySpecialTokenV1: Codable, Equatable {
    let id: UInt64
    let piece: String
}

private struct PrimeLatinReplaySpecialTokensV1: Codable, Equatable {
    let scheme: String
    let unk: PrimeLatinReplaySpecialTokenV1
    let bos: PrimeLatinReplaySpecialTokenV1
    let eos: PrimeLatinReplaySpecialTokenV1
    let pad: PrimeLatinReplaySpecialTokenV1
}

private struct PrimeLatinReplayTrainerOptionsV1: Codable, Equatable {
    let vocabSize: UInt64
    let modelType: String
    let byteFallback: Bool
    let characterCoverage: Double
    let maxSentenceLength: UInt64
    let hardVocabLimit: Bool
    let inputSentenceSize: UInt64
    let shuffleInputSentence: Bool
    let randomSeed: UInt64
    let numThreads: UInt64
    let userDefinedSymbols: [String]

    enum CodingKeys: String, CodingKey {
        case vocabSize = "vocab_size"
        case modelType = "model_type"
        case byteFallback = "byte_fallback"
        case characterCoverage = "character_coverage"
        case maxSentenceLength = "max_sentence_length"
        case hardVocabLimit = "hard_vocab_limit"
        case inputSentenceSize = "input_sentence_size"
        case shuffleInputSentence = "shuffle_input_sentence"
        case randomSeed = "random_seed"
        case numThreads = "num_threads"
        case userDefinedSymbols = "user_defined_symbols"
    }
}

private struct PrimeLatinReplayCorpusSliceV1: Codable, Equatable {
    let languages: [String]
    let levels: [String]
}

private struct PrimeLatinReplayCorpusInputV1: Codable, Equatable {
    let path: String
    let sha256: String
    let bytes: UInt64
}

private struct PrimeLatinReplayTokenizerManifestV1: Codable {
    let schema: String
    let tokenizerID: String
    let publicationContract: String
    let modelPath: String
    let modelSHA256: String
    let vocabSHA256: String
    let vocabSize: UInt64
    let sentencePieceVersion: String
    let sentencePieceTrainerSHA256: String
    let normalization: PrimeLatinReplayTokenizerNormalizationV1
    let specialTokens: PrimeLatinReplaySpecialTokensV1
    let trainerOptions: PrimeLatinReplayTrainerOptionsV1
    let corpusManifestPath: String
    let corpusManifestSHA256: String
    let corpusSlice: PrimeLatinReplayCorpusSliceV1
    let corpusInputs: [PrimeLatinReplayCorpusInputV1]
    let stagedTrainInputSHA256: String
    let recommendationSHA256: String
    let approvalSHA256: String
    let trainedAt: String

    enum CodingKeys: String, CodingKey {
        case schema
        case tokenizerID = "tokenizer_id"
        case publicationContract = "publication_contract"
        case modelPath = "model_path"
        case modelSHA256 = "model_sha256"
        case vocabSHA256 = "vocab_sha256"
        case vocabSize = "vocab_size"
        case sentencePieceVersion = "sentencepiece_version"
        case sentencePieceTrainerSHA256 = "sentencepiece_trainer_sha256"
        case normalization
        case specialTokens = "special_tokens"
        case trainerOptions = "trainer_options"
        case corpusManifestPath = "corpus_manifest_path"
        case corpusManifestSHA256 = "corpus_manifest_sha256"
        case corpusSlice = "corpus_slice"
        case corpusInputs = "corpus_inputs"
        case stagedTrainInputSHA256 = "staged_train_input_sha256"
        case recommendationSHA256 = "recommendation_sha256"
        case approvalSHA256 = "approval_sha256"
        case trainedAt = "trained_at"
    }
}

private struct PrimeLatinReplayTokenizerRecommendationV1: Codable {
    let schema: String
    let tokenizerID: String
    let publicationContract: String
    let corpusManifestSHA256: String
    let corpusManifestPath: String
    let corpusSlice: PrimeLatinReplayCorpusSliceV1
    let corpusInputs: [PrimeLatinReplayCorpusInputV1]
    let corpusLineCount: UInt64
    let normalization: PrimeLatinReplayTokenizerNormalizationV1
    let specialTokens: PrimeLatinReplaySpecialTokensV1
    let sentencePieceVersion: String
    let sentencePieceTrainerBinary: String
    let sentencePieceTrainerSHA256: String
    let trainerOptions: PrimeLatinReplayTrainerOptionsV1
    let generatedBy: String
    let approvalStatus: String
    let approvedBy: String?
    let approvedAt: String?

    enum CodingKeys: String, CodingKey {
        case schema
        case tokenizerID = "tokenizer_id"
        case publicationContract = "publication_contract"
        case corpusManifestSHA256 = "corpus_manifest_sha256"
        case corpusManifestPath = "corpus_manifest_path"
        case corpusSlice = "corpus_slice"
        case corpusInputs = "corpus_inputs"
        case corpusLineCount = "corpus_line_count"
        case normalization
        case specialTokens = "special_tokens"
        case sentencePieceVersion = "sentencepiece_version"
        case sentencePieceTrainerBinary = "sentencepiece_trainer_binary"
        case sentencePieceTrainerSHA256 = "sentencepiece_trainer_sha256"
        case trainerOptions = "trainer_options"
        case generatedBy = "generated_by"
        case approvalStatus = "approval_status"
        case approvedBy = "approved_by"
        case approvedAt = "approved_at"
    }
}

private struct PrimeLatinReplayTokenizerApprovalV1: Codable {
    let schema: String
    let tokenizerID: String
    let recommendationSHA256: String
    let approvedBy: String
    let approvedAt: String

    enum CodingKeys: String, CodingKey {
        case schema
        case tokenizerID = "tokenizer_id"
        case recommendationSHA256 = "recommendation_sha256"
        case approvedBy = "approved_by"
        case approvedAt = "approved_at"
    }
}

private struct PrimeLatinReplayPrimaryCorpusManifestV1: Codable {
    let schema: String
    let files: [PrimeLatinReplayPrimaryCorpusFileV1]
}

private struct PrimeLatinReplayPrimaryCorpusFileV1: Codable {
    let path: String
    let sha256: String
    let bytes: UInt64
    let language: String
    let level: String
    let topics: [String]
}

private struct PrimeLatinReplayInitializationContractV1:
    Codable,
    Equatable
{
    let algorithmID: String
    let freshWeightsRequired: Bool
    let importedWeightsAllowed: Bool
    let schema: String
    let seedDerivationSHA256: String

    enum CodingKeys: String, CodingKey {
        case algorithmID = "algorithm_id"
        case freshWeightsRequired = "fresh_weights_required"
        case importedWeightsAllowed = "imported_weights_allowed"
        case schema
        case seedDerivationSHA256 = "seed_derivation_sha256"
    }
}

private struct PrimeLatinReplayEvaluationContractV1:
    Codable,
    Equatable
{
    let candidateIndependent: Bool
    let procedureID: String
    let schema: String
    let thresholdsObserved: Bool

    enum CodingKeys: String, CodingKey {
        case candidateIndependent = "candidate_independent"
        case procedureID = "procedure_id"
        case schema
        case thresholdsObserved = "thresholds_observed"
    }
}

private struct PrimeLatinReplayProspectiveCorpusManifestV1:
    Codable,
    Equatable
{
    let corpusID: String
    let schema: String
    let splits: [PrimeLatinReplayProspectiveSplitV1]

    enum CodingKeys: String, CodingKey {
        case corpusID = "corpus_id"
        case schema, splits
    }
}

private struct PrimeLatinReplayProspectiveSplitV1:
    Codable,
    Equatable
{
    let byteCount: UInt64
    let relativePath: String
    let role: String
    let sha256: String
    let splitID: String

    enum CodingKeys: String, CodingKey {
        case byteCount = "byte_count"
        case relativePath = "relative_path"
        case role, sha256
        case splitID = "split_id"
    }
}

private struct PrimeLatinReplaySelectionDeclarationV1:
    Codable,
    Equatable
{
    let cryptographicHumanAuthentication: Bool
    let schema: String
    let selectionSplitSHA256: String
    let sourceAttribution: String
    let unobservedForModelSelectionDeclared: Bool

    enum CodingKeys: String, CodingKey {
        case cryptographicHumanAuthentication =
            "cryptographic_human_authentication"
        case schema
        case selectionSplitSHA256 = "selection_split_sha256"
        case sourceAttribution = "source_attribution"
        case unobservedForModelSelectionDeclared =
            "unobserved_for_model_selection_declared"
    }
}

// This implementation deliberately owns its JSON and digest primitives. The
// replay target does not import the producer module and does not call a
// producer encoder, validator, or reconstruction function.
enum PrimeLatinProposalIndependentReplayHashV1 {
    private static let hexadecimal = Array("0123456789abcdef".utf8)

    static func sha256(_ data: Data) -> String {
        hex(SHA256.hash(data: data))
    }

    static func gitBlobOID(_ data: Data) -> String {
        var framed = Data("blob \(data.count)\u{0}".utf8)
        framed.append(data)
        return hex(Insecure.SHA1.hash(data: framed))
    }

    private static func hex<Digest: Sequence>(_ digest: Digest) -> String
    where Digest.Element == UInt8 {
        var result = [UInt8]()
        result.reserveCapacity(64)
        for byte in digest {
            result.append(hexadecimal[Int(byte >> 4)])
            result.append(hexadecimal[Int(byte & 0x0f)])
        }
        return String(decoding: result, as: UTF8.self)
    }
}

private enum PrimeLatinProposalIndependentReplayJSONV1 {
    static let maximumDocumentBytes = 1_048_576

    static func canonical<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        do {
            let data = try encoder.encode(value)
            guard !data.isEmpty, data.count <= maximumDocumentBytes else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidReconstruction("canonical_document_size")
            }
            return data
        } catch let error as PrimeLatinProposalIndependentReplayError {
            throw error
        } catch {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReconstruction("canonical_encoding")
        }
    }

    static func canonicalLine<Value: Encodable>(_ value: Value) throws
        -> Data
    {
        var data = try canonical(value)
        data.append(0x0a)
        return data
    }

    static func decodeCanonical<Value: Codable>(
        _ type: Value.Type,
        from data: Data,
        context: String
    ) throws -> Value {
        guard !data.isEmpty, data.count <= maximumDocumentBytes else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReference(context + "_size")
        }
        try requireNoDuplicateKeys(data, context: context)
        do {
            let value = try JSONDecoder().decode(type, from: data)
            guard try canonical(value) == data else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidReference(context + "_canonical")
            }
            return value
        } catch let error as PrimeLatinProposalIndependentReplayError {
            throw error
        } catch {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReference(context + "_decode")
        }
    }

    static func decodeOriginal<Value: Codable>(
        _ type: Value.Type,
        from data: Data,
        context: String,
        nullableTopLevelKeys: Set<String> = []
    ) throws -> Value {
        guard !data.isEmpty, data.count <= maximumDocumentBytes else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact(context + "_size")
        }
        try requireNoDuplicateKeys(data, context: context)
        do {
            let value = try JSONDecoder().decode(type, from: data)
            var original = try JSONSerialization.jsonObject(
                with: data, options: [.fragmentsAllowed])
            if var dictionary = original as? [String: Any] {
                for key in nullableTopLevelKeys
                where dictionary[key] is NSNull {
                    dictionary.removeValue(forKey: key)
                }
                original = dictionary
            }
            let encoded = try canonical(value)
            let reconstructed = try JSONSerialization.jsonObject(
                with: encoded, options: [.fragmentsAllowed])
            guard (original as AnyObject).isEqual(reconstructed) else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidArtifact(context + "_shape")
            }
            return value
        } catch let error as PrimeLatinProposalIndependentReplayError {
            throw error
        } catch {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact(context + "_decode")
        }
    }

    private static func requireNoDuplicateKeys(
        _ data: Data,
        context: String
    ) throws {
        do {
            var parser = DuplicateKeyParser(bytes: Array(data))
            try parser.parseDocument()
        } catch {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact(context + "_duplicate_or_invalid_json")
        }
    }

    private struct DuplicateKeyParser {
        enum Failure: Error { case invalid }
        let bytes: [UInt8]
        var index = 0

        mutating func parseDocument() throws {
            skipWhitespace()
            try parseValue()
            skipWhitespace()
            guard index == bytes.count else { throw Failure.invalid }
        }

        mutating func parseValue() throws {
            skipWhitespace()
            guard index < bytes.count else { throw Failure.invalid }
            switch bytes[index] {
            case 0x7b: try parseObject()
            case 0x5b: try parseArray()
            case 0x22: _ = try parseString()
            case 0x74: try consume("true")
            case 0x66: try consume("false")
            case 0x6e: try consume("null")
            default: try parseNumber()
            }
        }

        mutating func parseObject() throws {
            try take(0x7b)
            skipWhitespace()
            if takeIf(0x7d) { return }
            var keys = Set<String>()
            while true {
                skipWhitespace()
                let key = try parseString()
                guard keys.insert(key).inserted else { throw Failure.invalid }
                skipWhitespace()
                try take(0x3a)
                try parseValue()
                skipWhitespace()
                if takeIf(0x7d) { return }
                try take(0x2c)
            }
        }

        mutating func parseArray() throws {
            try take(0x5b)
            skipWhitespace()
            if takeIf(0x5d) { return }
            while true {
                try parseValue()
                skipWhitespace()
                if takeIf(0x5d) { return }
                try take(0x2c)
            }
        }

        mutating func parseString() throws -> String {
            let start = index
            try take(0x22)
            var escaped = false
            while index < bytes.count {
                let byte = bytes[index]
                index += 1
                if escaped {
                    if byte == 0x75 {
                        guard index + 4 <= bytes.count,
                              bytes[index ..< index + 4].allSatisfy({
                                  ($0 >= 48 && $0 <= 57)
                                      || ($0 >= 65 && $0 <= 70)
                                      || ($0 >= 97 && $0 <= 102)
                              }) else { throw Failure.invalid }
                        index += 4
                    } else if ![0x22, 0x5c, 0x2f, 0x62, 0x66, 0x6e, 0x72,
                               0x74].contains(byte) {
                        throw Failure.invalid
                    }
                    escaped = false
                } else if byte == 0x5c {
                    escaped = true
                } else if byte == 0x22 {
                    let encoded = Data(bytes[start ..< index])
                    return try JSONDecoder().decode(String.self, from: encoded)
                } else if byte < 0x20 {
                    throw Failure.invalid
                }
            }
            throw Failure.invalid
        }

        mutating func parseNumber() throws {
            let start = index
            if takeIf(0x2d), index == bytes.count { throw Failure.invalid }
            if takeIf(0x30) {
                if index < bytes.count, isDigit(bytes[index]) {
                    throw Failure.invalid
                }
            } else {
                guard index < bytes.count,
                      bytes[index] >= 0x31, bytes[index] <= 0x39 else {
                    throw Failure.invalid
                }
                while index < bytes.count, isDigit(bytes[index]) { index += 1 }
            }
            if takeIf(0x2e) {
                let fraction = index
                while index < bytes.count, isDigit(bytes[index]) { index += 1 }
                guard index > fraction else { throw Failure.invalid }
            }
            if index < bytes.count, bytes[index] == 0x65 || bytes[index] == 0x45 {
                index += 1
                _ = takeIf(0x2b) || takeIf(0x2d)
                let exponent = index
                while index < bytes.count, isDigit(bytes[index]) { index += 1 }
                guard index > exponent else { throw Failure.invalid }
            }
            guard index > start else { throw Failure.invalid }
        }

        mutating func consume(_ text: String) throws {
            for byte in text.utf8 { try take(byte) }
        }

        mutating func take(_ byte: UInt8) throws {
            guard index < bytes.count, bytes[index] == byte else {
                throw Failure.invalid
            }
            index += 1
        }

        mutating func takeIf(_ byte: UInt8) -> Bool {
            guard index < bytes.count, bytes[index] == byte else { return false }
            index += 1
            return true
        }

        mutating func skipWhitespace() {
            while index < bytes.count,
                  [0x20, 0x09, 0x0a, 0x0d].contains(bytes[index]) {
                index += 1
            }
        }

        func isDigit(_ byte: UInt8) -> Bool { byte >= 48 && byte <= 57 }
    }
}

private enum PrimeLatinProposalIndependentReplayInputV1 {
    static let roles = [
        "root_package_manifest", "root_dependency_lock",
        "declaration_package_manifest", "declaration_production_source",
        "candidate_architecture", "candidate_parameter_count_derivation",
        "evaluation_contract", "tokenizer_manifest",
        "tokenizer_sentencepiece_model", "tokenizer_vocabulary",
        "tokenizer_recommendation", "tokenizer_approval",
        "tokenizer_staged_training_input", "tokenizer_corpus_manifest",
        "tokenizer_admitted_corpus_input", "initialization_contract",
        "prospective_corpus_manifest", "training_split", "validation_split",
        "selection_split", "selection_observation_declaration",
    ]
    static let repositoryRoleCount = 7
    static let maximumArtifactBytes: UInt64 = 8_388_608
    static let maximumAggregateBytes: UInt64 = 67_108_864

    static func validate(
        _ originals: PrimeLatinProposalIndependentReplayOriginalInputsV1,
        against plan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws -> [String: PrimeLatinProposalIndependentReplayOriginalInputV1] {
        let values = originals.artifacts
        guard plan.inputBindings.count == roles.count,
              plan.inputBindings.map(\.role) == roles,
              values.count == roles.count,
              values.map(\.role) == roles else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidOriginalInputs("exact_role_inventory")
        }
        var aggregate: UInt64 = 0
        var locations = Set<String>()
        var digestRoles = [String: [String]]()
        var result = [String: PrimeLatinProposalIndependentReplayOriginalInputV1]()
        for index in values.indices {
            let value = values[index]
            let expected = plan.inputBindings[index]
            guard value.role == expected.role,
                  value.scope == expected.scope,
                  value.relativePath == expected.relativePath,
                  value.sha256 == expected.sha256,
                  value.byteCount == expected.byteCount,
                  value.byteCount == UInt64(value.data.count),
                  value.byteCount > 0,
                  value.byteCount <= maximumArtifactBytes,
                  PrimeLatinProposalIndependentReplayHashV1.sha256(value.data)
                    == value.sha256,
                  validPath(value.relativePath),
                  (index < repositoryRoleCount
                    ? value.scope == .ergenticsLLMRepository
                    : value.scope == .ergenticsMLXLab) else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidOriginalInputs("binding_\(value.role)")
            }
            let next = aggregate.addingReportingOverflow(value.byteCount)
            guard !next.overflow, next.partialValue <= maximumAggregateBytes else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidOriginalInputs("aggregate_byte_count")
            }
            aggregate = next.partialValue
            let location = value.scope.rawValue + "\u{0}"
                + value.relativePath.lowercased()
            guard locations.insert(location).inserted else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidOriginalInputs("location_alias")
            }
            digestRoles[value.sha256, default: []].append(value.role)
            result[value.role] = value
        }
        let duplicateGroups = digestRoles.values.filter { $0.count > 1 }
        guard duplicateGroups.count == 1,
              duplicateGroups[0].count == 2,
              Set(duplicateGroups[0]) == [
                "tokenizer_staged_training_input",
                "tokenizer_admitted_corpus_input",
              ] else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidOriginalInputs("hash_alias")
        }
        return result
    }

    private static func validPath(_ path: String) -> Bool {
        guard !path.isEmpty, !path.hasPrefix("/"), !path.contains("\\"),
              !path.utf8.contains(0) else { return false }
        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        return !components.isEmpty && components.allSatisfy {
            !$0.isEmpty && $0 != "." && $0 != ".."
        }
    }
}

enum PrimeLatinProposalIndependentReconstructorV1 {
    static func reconstruct(
        originalInputs:
            PrimeLatinProposalIndependentReplayOriginalInputsV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws -> PrimeLatinProposalIndependentReplayReconstructionV1 {
        let inputs = try PrimeLatinProposalIndependentReplayInputV1.validate(
            originalInputs, against: expectedPlan)
        func input(_ role: String)
            throws -> PrimeLatinProposalIndependentReplayOriginalInputV1
        {
            guard let value = inputs[role] else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidOriginalInputs("missing_\(role)")
            }
            return value
        }

        let rootManifest = try input("root_package_manifest")
        let rootLock = try input("root_dependency_lock")
        let nestedManifest = try input("declaration_package_manifest")
        let productionSource = try input("declaration_production_source")
        try validateManifests(
            rootManifest: rootManifest.data,
            nestedManifest: nestedManifest.data)

        let resolved: PrimeLatinReplayResolvedFileV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayResolvedFileV1.self,
                from: rootLock.data,
                context: "root_dependency_lock")
        let unreachablePins = try validateResolvedFile(resolved)

        let tokenizerBundle = try reconstructTokenizerBundle(
            inputs: inputs,
            expectedPlan: expectedPlan)
        let tokenizerBundleData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(
                tokenizerBundle)
        let tokenizerBundleSHA256 =
            PrimeLatinProposalIndependentReplayHashV1.sha256(
                tokenizerBundleData)
        let tokenizerBundleByteCount = UInt64(tokenizerBundleData.count)
        let tokenizerProposal = PrimeLatinReplayTokenizerProposalV1(
            tokenizerBundleSHA256: tokenizerBundleSHA256,
            tokenizerBundleByteCount: tokenizerBundleByteCount,
            tokenizerBundle: tokenizerBundle)

        let architectureInput = try input("candidate_architecture")
        let architecture: PrimeLatinReplayArchitectureV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayArchitectureV1.self,
                from: architectureInput.data,
                context: "candidate_architecture")
        try validateArchitecture(
            architecture,
            expectedPlan: expectedPlan,
            tokenizerBundleSHA256: tokenizerBundleSHA256,
            tokenizerBundleByteCount: tokenizerBundleByteCount)
        guard try PrimeLatinProposalIndependentReplayJSONV1.canonicalLine(
                architecture) == architectureInput.data else {
            throw PrimeLatinProposalIndependentReplayError.invalidArtifact(
                "candidate_architecture_canonical_line")
        }

        let derivation = try reconstructDerivation(
            architecture: architecture,
            input: try input("candidate_parameter_count_derivation"),
            expectedPlan: expectedPlan)

        let source = PrimeLatinReplaySourceV1(
            repository: expectedPlan.sourceRepository,
            commit: expectedPlan.sourceCommit,
            tree: expectedPlan.sourceTree)
        try validateSource(source)

        let nestedBinding = committed(nestedManifest)
        let sourceBinding = committed(productionSource)
        let architectureBinding = committed(architectureInput)
        let derivationInput = try input("candidate_parameter_count_derivation")
        let derivationBinding = committed(derivationInput)
        let rootLockBinding = committed(rootLock)
        let closure = PrimeLatinReplayDeclarationClosureV1(
            nestedPackageManifest: nestedBinding,
            productionSources: [sourceBinding],
            rootPackageLock: rootLockBinding,
            unreachableRootPackagePins: unreachablePins)
        let closureData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(closure)

        let identity = PrimeLatinReplayIdentityMaterialV1(
            llmSource: source,
            candidateSlug: architecture.candidateSlug,
            sourceAttribution: architecture.sourceAttribution,
            tokenizerID: architecture.tokenizer.tokenizerID,
            tokenizerBundleSHA256: tokenizerBundleSHA256,
            tokenizerBundleByteCount: tokenizerBundleByteCount,
            tokenizerVocabularySize: architecture.tokenizer.vocabularySize,
            architectureSHA256: architectureInput.sha256,
            architectureByteCount: architectureInput.byteCount,
            parameterCountDerivationSHA256: derivationInput.sha256,
            parameterCountDerivationByteCount: derivationInput.byteCount,
            declarationTargetClosureSHA256:
                PrimeLatinProposalIndependentReplayHashV1.sha256(closureData),
            declarationTargetClosureByteCount: UInt64(closureData.count))
        let identityData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(identity)
        let candidateIdentitySHA256 =
            PrimeLatinProposalIndependentReplayHashV1.sha256(identityData)

        let declarationBundle = PrimeLatinReplayDeclarationBundleV1(
            llmSource: source,
            tokenizerProposalBinding: tokenizerProposal,
            nestedPackageManifest: nestedBinding,
            productionSources: [sourceBinding],
            architectureArtifact: architectureBinding,
            architecture: architecture,
            parameterCountDerivationArtifact: derivationBinding,
            parameterCountDerivation: derivation,
            declarationTargetClosure: closure,
            identityMaterial: identity,
            candidateIdentitySHA256: candidateIdentitySHA256)
        let declarationBundleData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(
                declarationBundle)
        let declarationBundleSHA256 =
            PrimeLatinProposalIndependentReplayHashV1.sha256(
                declarationBundleData)
        let declarationBinding = PrimeLatinReplayDeclarationBindingV1(
            candidateID: architecture.candidateSlug,
            sourceAttribution: architecture.sourceAttribution,
            candidateIdentitySHA256: candidateIdentitySHA256,
            declarationBundleSHA256: declarationBundleSHA256,
            declarationBundleByteCount: UInt64(declarationBundleData.count),
            declarationBundle: declarationBundle)
        let declarationSet = PrimeLatinReplayDeclarationSetV1(
            candidates: [declarationBinding])
        let declarationSetData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(
                declarationSet)
        let declarationSetSHA256 =
            PrimeLatinProposalIndependentReplayHashV1.sha256(
                declarationSetData)

        let initializationInput = try input("initialization_contract")
        try validateInitialization(
            initializationInput, expectedPlan: expectedPlan)
        let packageBinding = binding(rootManifest)
        let dependencyLockBinding = binding(rootLock)
        let catalog = PrimeLatinReplayCandidateCatalogV1(
            llmSource: source,
            packageManifest: packageBinding,
            dependencyLock: dependencyLockBinding,
            tokenizerProposalBinding: tokenizerProposal,
            initializationContract: binding(initializationInput),
            candidateDeclarations: declarationSet,
            candidateDeclarationSetSHA256: declarationSetSHA256,
            candidateDeclarationSetByteCount: UInt64(declarationSetData.count),
            proposalInputDependencyQuarantine:
                PrimeLatinReplayDependencyQuarantineV1(
                    packageManifest: packageBinding,
                    dependencyLock: dependencyLockBinding))
        let catalogData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(catalog)
        let catalogSHA256 =
            PrimeLatinProposalIndependentReplayHashV1.sha256(catalogData)

        let experiment = try reconstructExperiment(
            inputs: inputs,
            expectedPlan: expectedPlan,
            source: source,
            catalogSHA256: catalogSHA256,
            catalogByteCount: UInt64(catalogData.count),
            declarationSetSHA256: declarationSetSHA256,
            declarationSetByteCount: UInt64(declarationSetData.count),
            dependencyLock: dependencyLockBinding,
            tokenizerBundleSHA256: tokenizerBundleSHA256,
            tokenizerBundleByteCount: tokenizerBundleByteCount,
            initializationContract: binding(initializationInput),
            candidateID: architecture.candidateSlug)
        let experimentData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(experiment)
        let experimentSHA256 =
            PrimeLatinProposalIndependentReplayHashV1.sha256(experimentData)

        let publicationRoot = "evidence/latin-proposal-artifacts/v3"
        let pairReceipt = PrimeLatinReplayPairReceiptV1(
            llmSource: source,
            candidateCatalog: PrimeLatinReplayPublishedDocumentV1(
                documentKind: "candidate_catalog_v3",
                relativePath:
                    "\(publicationRoot)/catalogs/\(catalogSHA256).json",
                sha256: catalogSHA256,
                byteCount: UInt64(catalogData.count)),
            experimentManifest: PrimeLatinReplayPublishedDocumentV1(
                documentKind: "experiment_manifest_v3",
                relativePath:
                    "\(publicationRoot)/experiments/\(experimentSHA256).json",
                sha256: experimentSHA256,
                byteCount: UInt64(experimentData.count)),
            candidateDeclarationSetSHA256: declarationSetSHA256,
            candidateDeclarationSetByteCount: UInt64(declarationSetData.count))
        let pairReceiptData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(pairReceipt)

        return PrimeLatinProposalIndependentReplayReconstructionV1(
            source: source,
            originalInputs: originalInputs.artifacts,
            architecture: architecture,
            derivation: derivation,
            tokenizerBundle: tokenizerBundle,
            candidateCatalog: catalog,
            experiment: experiment,
            pairReceipt: pairReceipt,
            candidateCatalogData: catalogData,
            experimentManifestData: experimentData,
            pairReceiptData: pairReceiptData,
            candidateDeclarationSetSHA256: declarationSetSHA256,
            candidateDeclarationSetByteCount: UInt64(declarationSetData.count),
            tokenizerBundleSHA256: tokenizerBundleSHA256,
            tokenizerBundleByteCount: tokenizerBundleByteCount,
            candidateIDs: [architecture.candidateSlug],
            candidateIdentitySHA256s: [candidateIdentitySHA256],
            declarationBundleSHA256s: [declarationBundleSHA256])
    }

    private static func binding(
        _ input: PrimeLatinProposalIndependentReplayOriginalInputV1
    ) -> PrimeLatinReplayArtifactBindingV1 {
        PrimeLatinReplayArtifactBindingV1(input)
    }

    private static func committed(
        _ input: PrimeLatinProposalIndependentReplayOriginalInputV1
    ) -> PrimeLatinReplayCommittedBindingV1 {
        PrimeLatinReplayCommittedBindingV1(
            artifact: binding(input),
            gitBlobOID:
                PrimeLatinProposalIndependentReplayHashV1.gitBlobOID(
                    input.data))
    }

    private static func validateSource(_ source: PrimeLatinReplaySourceV1)
        throws
    {
        guard source.repository == "Ergentics/ergentics-llm",
              isHex(source.commit, count: 40),
              isHex(source.tree, count: 40) else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReconstruction("llm_source")
        }
    }

    private static func validateManifests(
        rootManifest: Data,
        nestedManifest: Data
    ) throws {
        guard let root = String(data: rootManifest, encoding: .utf8),
              root.contains("name: \"ErgenticsLLM\""),
              root.contains("name: \"ErgenticsLatinProposalArtifacts\""),
              root.contains("https://github.com/Ergentics/ergentics-mlx-swift"),
              let nested = String(data: nestedManifest, encoding: .utf8),
              nested.contains("name: \"ErgenticsLatinCandidateDeclarations\""),
              nested.contains("dependencies: []"),
              nested.contains("sources: [\"ErgenticsLatinCandidateDeclarations.swift\"]"),
              !nested.lowercased().contains("unsafeflags"),
              !nested.contains(".binaryTarget"),
              !nested.contains(".systemLibrary"),
              !nested.contains(".plugin"),
              !nested.contains(".macro") else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("declaration_source_closure")
        }
    }

    private static func validateResolvedFile(
        _ resolved: PrimeLatinReplayResolvedFileV1
    ) throws -> [PrimeLatinReplayUnreachablePinV1] {
        guard resolved.version == 3,
              resolved.originHash
                == "20d66b7673267d4c6a015d569030ff5e170a472893bade61a20d37d043dcd45e",
              resolved.pins.count == 2 else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("root_dependency_lock_semantics")
        }
        let pins = resolved.pins.map {
            PrimeLatinReplayUnreachablePinV1(
                identity: $0.identity,
                kind: $0.kind,
                location: $0.location,
                revision: $0.state.revision,
                version: $0.state.version)
        }
        guard pins[0].identity == "ergentics-mlx-swift",
              pins[0].kind == "remoteSourceControl",
              pins[0].location
                == "https://github.com/Ergentics/ergentics-mlx-swift",
              pins[0].revision
                == "d37885a278f1c37484a94d0f401a418735e66519",
              pins[0].version == nil,
              pins[1].identity == "swift-numerics",
              pins[1].kind == "remoteSourceControl",
              pins[1].location == "https://github.com/apple/swift-numerics",
              pins[1].revision
                == "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
              pins[1].version == "1.1.1" else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("root_dependency_lock_pins")
        }
        return pins
    }

    private static func reconstructTokenizerBundle(
        inputs: [String: PrimeLatinProposalIndependentReplayOriginalInputV1],
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws -> PrimeLatinReplayTokenizerBundleV1 {
        func value(_ role: String)
            throws -> PrimeLatinProposalIndependentReplayOriginalInputV1
        {
            guard let result = inputs[role] else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidOriginalInputs("missing_\(role)")
            }
            return result
        }
        let manifestInput = try value("tokenizer_manifest")
        let modelInput = try value("tokenizer_sentencepiece_model")
        let vocabularyInput = try value("tokenizer_vocabulary")
        let recommendationInput = try value("tokenizer_recommendation")
        let approvalInput = try value("tokenizer_approval")
        let stagedInput = try value("tokenizer_staged_training_input")
        let corpusManifestInput = try value("tokenizer_corpus_manifest")
        let admittedInput = try value("tokenizer_admitted_corpus_input")

        let manifest: PrimeLatinReplayTokenizerManifestV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayTokenizerManifestV1.self,
                from: manifestInput.data,
                context: "tokenizer_manifest")
        let recommendation: PrimeLatinReplayTokenizerRecommendationV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayTokenizerRecommendationV1.self,
                from: recommendationInput.data,
                context: "tokenizer_recommendation",
                nullableTopLevelKeys: ["approved_by", "approved_at"])
        let approval: PrimeLatinReplayTokenizerApprovalV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayTokenizerApprovalV1.self,
                from: approvalInput.data,
                context: "tokenizer_approval")
        let corpus: PrimeLatinReplayPrimaryCorpusManifestV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayPrimaryCorpusManifestV1.self,
                from: corpusManifestInput.data,
                context: "tokenizer_corpus_manifest")

        guard manifest.schema == "prime_tokenizer_manifest_v2",
              recommendation.schema == "prime_tokenizer_recommendation_v2",
              approval.schema == "ergentics_tokenizer_human_approval_v1",
              corpus.schema == "prime_corpus_manifest_v2",
              manifest.tokenizerID == expectedPlan.tokenizerID,
              recommendation.tokenizerID == expectedPlan.tokenizerID,
              approval.tokenizerID == expectedPlan.tokenizerID,
              manifest.publicationContract == "atomic_candidate_rename_v1",
              recommendation.publicationContract
                == "atomic_candidate_rename_v1",
              manifest.modelPath == modelInput.relativePath,
              manifest.modelSHA256 == modelInput.sha256,
              manifest.vocabSHA256 == vocabularyInput.sha256,
              manifest.vocabSize == expectedPlan.vocabularySize,
              recommendation.corpusLineCount
                == expectedPlan.tokenizerCorpusLineCount,
              manifest.corpusManifestPath == corpusManifestInput.relativePath,
              manifest.corpusManifestSHA256 == corpusManifestInput.sha256,
              recommendation.corpusManifestPath
                == corpusManifestInput.relativePath,
              recommendation.corpusManifestSHA256
                == corpusManifestInput.sha256,
              manifest.corpusInputs.count == 1,
              recommendation.corpusInputs.count == 1,
              manifest.corpusInputs[0].path == admittedInput.relativePath,
              manifest.corpusInputs[0].sha256 == admittedInput.sha256,
              manifest.corpusInputs[0].bytes == admittedInput.byteCount,
              recommendation.corpusInputs[0].path == admittedInput.relativePath,
              recommendation.corpusInputs[0].sha256 == admittedInput.sha256,
              recommendation.corpusInputs[0].bytes == admittedInput.byteCount,
              manifest.stagedTrainInputSHA256 == stagedInput.sha256,
              manifest.recommendationSHA256 == recommendationInput.sha256,
              manifest.approvalSHA256 == approvalInput.sha256,
              approval.recommendationSHA256 == recommendationInput.sha256,
              manifest.normalization == recommendation.normalization,
              manifest.specialTokens == recommendation.specialTokens,
              manifest.trainerOptions == recommendation.trainerOptions,
              manifest.corpusSlice == recommendation.corpusSlice,
              manifest.normalization.swiftPreNormalization == "nfc",
              manifest.normalization.sentencePieceRule == "identity",
              !manifest.normalization.addDummyPrefix,
              !manifest.normalization.removeExtraWhitespaces,
              manifest.normalization.escapeWhitespaces,
              manifest.specialTokens.scheme
                == "sentencepiece_builtin_fixed_v1",
              manifest.specialTokens.unk.id == 0,
              manifest.specialTokens.unk.piece == "<unk>",
              manifest.specialTokens.bos.id == 1,
              manifest.specialTokens.bos.piece == "<bos>",
              manifest.specialTokens.eos.id == 2,
              manifest.specialTokens.eos.piece == "<eos>",
              manifest.specialTokens.pad.id == 3,
              manifest.specialTokens.pad.piece == "<pad>",
              manifest.corpusSlice.languages == ["la"],
              manifest.corpusSlice.levels == ["L1"],
              manifest.trainerOptions.vocabSize == expectedPlan.vocabularySize,
              manifest.trainerOptions.modelType == "bpe",
              manifest.trainerOptions.byteFallback,
              manifest.trainerOptions.characterCoverage == 1.0,
              manifest.trainerOptions.maxSentenceLength == 128,
              !manifest.trainerOptions.hardVocabLimit,
              manifest.trainerOptions.inputSentenceSize == 0,
              !manifest.trainerOptions.shuffleInputSentence,
              manifest.trainerOptions.randomSeed == 0,
              manifest.trainerOptions.numThreads == 1,
              manifest.trainerOptions.userDefinedSymbols.isEmpty,
              recommendation.approvalStatus == "pending",
              recommendation.approvedBy == nil,
              recommendation.approvedAt == nil,
              !approval.approvedBy.isEmpty,
              !approval.approvedAt.isEmpty,
              !manifest.trainedAt.isEmpty,
              stagedInput.data == admittedInput.data,
              !stagedInput.data.contains(0x0d),
              UInt64(stagedInput.data.reduce(into: 0) {
                  if $1 == 0x0a { $0 += 1 }
              }) == expectedPlan.tokenizerCorpusLineCount,
              validateVocabulary(
                vocabularyInput.data,
                expectedSize: expectedPlan.vocabularySize),
              corpus.files.contains(where: {
                  $0.path == admittedInput.relativePath
                    && $0.sha256 == admittedInput.sha256
                    && $0.bytes == admittedInput.byteCount
                    && $0.language == "la"
                    && $0.level == "L1"
              }) else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("tokenizer_bundle_semantics")
        }

        func role(
            _ outputRole: String,
            _ input: PrimeLatinProposalIndependentReplayOriginalInputV1
        ) -> PrimeLatinReplayTokenizerRoleBindingV1 {
            PrimeLatinReplayTokenizerRoleBindingV1(
                role: outputRole,
                artifact: binding(input))
        }
        return PrimeLatinReplayTokenizerBundleV1(
            tokenizerID: expectedPlan.tokenizerID,
            tokenizerManifest: role("tokenizer_manifest", manifestInput),
            sentencePieceModel: role("sentencepiece_model", modelInput),
            vocabulary: role("vocabulary", vocabularyInput),
            recommendation: role("recommendation", recommendationInput),
            approval: role("approval", approvalInput),
            stagedTrainingInput: role("staged_training_input", stagedInput),
            corpusManifest: role("corpus_manifest", corpusManifestInput),
            manifestListedCorpusInputs: [
                role("admitted_corpus_input", admittedInput),
            ])
    }

    private static func validateVocabulary(
        _ data: Data,
        expectedSize: UInt64
    ) -> Bool {
        guard !data.isEmpty, !data.contains(0x0d), data.last == 0x0a,
              let text = String(data: data, encoding: .utf8) else {
            return false
        }
        let rows = text.split(separator: "\n", omittingEmptySubsequences: false)
            .dropLast()
        guard UInt64(rows.count) == expectedSize, rows.count >= 260 else {
            return false
        }
        var pieces = Set<String>()
        for (index, row) in rows.enumerated() {
            let columns = row.split(
                separator: "\t", omittingEmptySubsequences: false)
            guard columns.count == 2,
                  let score = Double(columns[1]), score.isFinite else {
                return false
            }
            let piece = String(columns[0])
            guard !piece.isEmpty, pieces.insert(piece).inserted else {
                return false
            }
            if index < 4 {
                let expected = ["<unk>", "<bos>", "<eos>", "<pad>"]
                guard piece == expected[index], score == 0 else {
                    return false
                }
            } else if index < 260 {
                let byte = index - 4
                let expected = String(format: "<0x%02X>", byte)
                guard piece == expected else { return false }
            }
        }
        return true
    }

    private static func validateArchitecture(
        _ architecture: PrimeLatinReplayArchitectureV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1,
        tokenizerBundleSHA256: String,
        tokenizerBundleByteCount: UInt64
    ) throws {
        let expectedTensors: [(String, String, [UInt64])] = [
            ("token_embedding_weight",
             "token_embedding_and_output_projection",
             [expectedPlan.vocabularySize, 8]),
            ("layer_0_attention_norm_scale",
             "layer_0_attention_norm_scale", [8]),
            ("layer_0_attention_query_weight",
             "layer_0_attention_query_weight", [8, 8]),
            ("layer_0_attention_key_weight",
             "layer_0_attention_key_weight", [8, 8]),
            ("layer_0_attention_value_weight",
             "layer_0_attention_value_weight", [8, 8]),
            ("layer_0_attention_output_weight",
             "layer_0_attention_output_weight", [8, 8]),
            ("layer_0_feed_forward_norm_scale",
             "layer_0_feed_forward_norm_scale", [8]),
            ("layer_0_feed_forward_gate_weight",
             "layer_0_feed_forward_gate_weight", [16, 8]),
            ("layer_0_feed_forward_up_weight",
             "layer_0_feed_forward_up_weight", [16, 8]),
            ("layer_0_feed_forward_down_weight",
             "layer_0_feed_forward_down_weight", [8, 16]),
            ("final_norm_scale", "final_norm_scale", [8]),
            ("output_projection_weight",
             "token_embedding_and_output_projection",
             [expectedPlan.vocabularySize, 8]),
        ]
        guard architecture.schema
                == "ergentics_latin_candidate_architecture_v1",
              architecture.candidateSlug == expectedPlan.candidateID,
              architecture.fixtureOnly,
              architecture.sourceAttribution == expectedPlan.sourceAttribution,
              !architecture.cryptographicHumanAuthentication,
              architecture.authorityBoundary
                == PrimeLatinReplayCandidateAuthorityV1(),
              architecture.tokenizer.tokenizerID == expectedPlan.tokenizerID,
              architecture.tokenizer.proposalBundleSHA256
                == tokenizerBundleSHA256,
              architecture.tokenizer.proposalBundleByteCount
                == tokenizerBundleByteCount,
              architecture.tokenizer.vocabularySize
                == expectedPlan.vocabularySize,
              architecture.tokenizer.unknownTokenID == 0,
              architecture.tokenizer.beginningOfSequenceTokenID == 1,
              architecture.tokenizer.endOfSequenceTokenID == 2,
              architecture.tokenizer.paddingTokenID == 3,
              architecture.geometry.maximumSequenceLength == 16,
              architecture.geometry.modelWidth == 8,
              architecture.geometry.layerCount == 1,
              architecture.geometry.attentionHeadCount == 2,
              architecture.geometry.attentionHeadWidth == 4,
              architecture.geometry.intermediateWidth == 16,
              architecture.policies == PrimeLatinReplayPoliciesV1(),
              UInt64(architecture.orderedTensors.count)
                == expectedPlan.orderedTensorCount,
              architecture.orderedTensors.count == expectedTensors.count,
              zip(architecture.orderedTensors, expectedTensors).allSatisfy({
                  $0.role == $1.0 && $0.storageID == $1.1
                    && $0.dimensions == $1.2
              }) else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("candidate_architecture_semantics")
        }
    }

    private static func reconstructDerivation(
        architecture: PrimeLatinReplayArchitectureV1,
        input: PrimeLatinProposalIndependentReplayOriginalInputV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws -> PrimeLatinReplayDerivationV1 {
        var seen = Set<String>()
        var uniqueCount: UInt64 = 0
        var total: UInt64 = 0
        var terms = [PrimeLatinReplayTermV1]()
        for tensor in architecture.orderedTensors {
            var elements: UInt64 = 1
            guard !tensor.dimensions.isEmpty else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidArtifact("candidate_tensor_dimensions")
            }
            for dimension in tensor.dimensions {
                let product = elements.multipliedReportingOverflow(by: dimension)
                guard dimension > 0, !product.overflow else {
                    throw PrimeLatinProposalIndependentReplayError
                        .invalidArtifact("candidate_parameter_overflow")
                }
                elements = product.partialValue
            }
            let unique = seen.insert(tensor.storageID).inserted
            if unique {
                let count = uniqueCount.addingReportingOverflow(1)
                let sum = total.addingReportingOverflow(elements)
                guard !count.overflow, !sum.overflow else {
                    throw PrimeLatinProposalIndependentReplayError
                        .invalidArtifact("candidate_parameter_overflow")
                }
                uniqueCount = count.partialValue
                total = sum.partialValue
            }
            terms.append(
                PrimeLatinReplayTermV1(
                    role: tensor.role,
                    storageID: tensor.storageID,
                    dimensions: tensor.dimensions,
                    elementCount: elements,
                    countedAsUniqueStorage: unique))
        }
        let reconstructed = PrimeLatinReplayDerivationV1(
            candidateSlug: architecture.candidateSlug,
            sourceAttribution: architecture.sourceAttribution,
            orderedTerms: terms,
            uniqueStorageCount: uniqueCount,
            totalParameterCount: total)
        let declared: PrimeLatinReplayDerivationV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayDerivationV1.self,
                from: input.data,
                context: "candidate_parameter_count_derivation")
        guard reconstructed == declared,
              uniqueCount == expectedPlan.uniqueParameterStorageCount,
              total == expectedPlan.totalParameterCount,
              try PrimeLatinProposalIndependentReplayJSONV1.canonicalLine(
                reconstructed) == input.data else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("candidate_parameter_count_derivation_semantics")
        }
        return reconstructed
    }

    private static func validateInitialization(
        _ input: PrimeLatinProposalIndependentReplayOriginalInputV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws {
        let value: PrimeLatinReplayInitializationContractV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayInitializationContractV1.self,
                from: input.data,
                context: "initialization_contract")
        guard value.schema == "ergentics_latin_initialization_contract_v1",
              value.algorithmID == expectedPlan.initializationAlgorithmID,
              value.freshWeightsRequired,
              !value.importedWeightsAllowed,
              value.seedDerivationSHA256
                == expectedPlan.initializationSeedDerivationSHA256,
              isHex(value.seedDerivationSHA256, count: 64) else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("initialization_contract_semantics")
        }
    }

    private static func reconstructExperiment(
        inputs: [String: PrimeLatinProposalIndependentReplayOriginalInputV1],
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1,
        source: PrimeLatinReplaySourceV1,
        catalogSHA256: String,
        catalogByteCount: UInt64,
        declarationSetSHA256: String,
        declarationSetByteCount: UInt64,
        dependencyLock: PrimeLatinReplayArtifactBindingV1,
        tokenizerBundleSHA256: String,
        tokenizerBundleByteCount: UInt64,
        initializationContract: PrimeLatinReplayArtifactBindingV1,
        candidateID: String
    ) throws -> PrimeLatinReplayExperimentManifestV1 {
        func value(_ role: String)
            throws -> PrimeLatinProposalIndependentReplayOriginalInputV1
        {
            guard let result = inputs[role] else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidOriginalInputs("missing_\(role)")
            }
            return result
        }
        let corpusInput = try value("prospective_corpus_manifest")
        let training = try value("training_split")
        let validation = try value("validation_split")
        let selection = try value("selection_split")
        let selectionDeclaration = try value(
            "selection_observation_declaration")
        let evaluation = try value("evaluation_contract")

        let corpus: PrimeLatinReplayProspectiveCorpusManifestV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayProspectiveCorpusManifestV1.self,
                from: corpusInput.data,
                context: "prospective_corpus_manifest")
        let evaluationContract: PrimeLatinReplayEvaluationContractV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplayEvaluationContractV1.self,
                from: evaluation.data,
                context: "evaluation_contract")
        let selectionObservation: PrimeLatinReplaySelectionDeclarationV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeOriginal(
                PrimeLatinReplaySelectionDeclarationV1.self,
                from: selectionDeclaration.data,
                context: "selection_observation_declaration")
        guard let trainingLines = splitLines(training.data),
              let validationLines = splitLines(validation.data),
              let selectionLines = splitLines(selection.data),
              trainingLines.isDisjoint(with: validationLines),
              trainingLines.isDisjoint(with: selectionLines),
              validationLines.isDisjoint(with: selectionLines) else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("prospective_split_bytes")
        }

        let splitInputs = [training, validation, selection]
        let expectedRoles = ["training", "validation", "selection"]
        guard corpus.schema == "ergentics_latin_corpus_manifest_v1",
              corpus.corpusID == expectedPlan.prospectiveCorpusID,
              corpus.splits.count == 3,
              corpus.splits.map(\.role) == expectedRoles,
              zip(corpus.splits, splitInputs).allSatisfy({ split, input in
                  split.relativePath == input.relativePath
                    && split.sha256 == input.sha256
                    && split.byteCount == input.byteCount
                    && !split.splitID.isEmpty
              }),
              Set(corpus.splits.map(\.splitID)).count == 3,
              Set(splitInputs.map(\.sha256)).count == 3,
              evaluationContract.schema
                == "ergentics_latin_evaluation_contract_v1",
              evaluationContract.candidateIndependent,
              evaluationContract.procedureID
                == expectedPlan.evaluationProcedureID,
              !evaluationContract.thresholdsObserved,
              selectionObservation.schema
                == "ergentics_latin_selection_observation_declaration_v1",
              !selectionObservation.cryptographicHumanAuthentication,
              selectionObservation.selectionSplitSHA256 == selection.sha256,
              !selectionObservation.sourceAttribution.isEmpty,
              selectionObservation.unobservedForModelSelectionDeclared,
              expectedPlan.optimizerSteps > 0,
              expectedPlan.trainingTokens > 0,
              expectedPlan.wallClockSeconds > 0,
              validOutputNamespace(expectedPlan.outputNamespace),
              inputs.values.allSatisfy({
                  !pathsOverlap($0.relativePath, expectedPlan.outputNamespace)
              }) else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidArtifact("experiment_input_semantics")
        }
        let splits = PrimeLatinReplaySplitSetV1(
            trainingSplitID: corpus.splits[0].splitID,
            validationSplitID: corpus.splits[1].splitID,
            selectionSplitID: corpus.splits[2].splitID,
            trainingSplit: binding(training),
            validationSplit: binding(validation),
            selectionSplit: binding(selection),
            selectionObservationDeclaration: binding(selectionDeclaration))
        return PrimeLatinReplayExperimentManifestV1(
            llmSource: source,
            candidateCatalogSHA256: catalogSHA256,
            candidateCatalogByteCount: catalogByteCount,
            candidateDeclarationSetSHA256: declarationSetSHA256,
            candidateDeclarationSetByteCount: declarationSetByteCount,
            candidateIDs: [candidateID],
            dependencyLock: dependencyLock,
            tokenizerBundleSHA256: tokenizerBundleSHA256,
            tokenizerBundleByteCount: tokenizerBundleByteCount,
            initializationContract: initializationContract,
            corpusManifest: binding(corpusInput),
            evaluationContract: binding(evaluation),
            splits: splits,
            requestedTrialBudget: PrimeLatinReplayBudgetV1(
                optimizerSteps: expectedPlan.optimizerSteps,
                trainingTokens: expectedPlan.trainingTokens,
                wallClockSeconds: expectedPlan.wallClockSeconds),
            outputNamespace: expectedPlan.outputNamespace)
    }

    private static func validOutputNamespace(_ value: String) -> Bool {
        value.hasPrefix("models/latin-prospective/")
            && !value.hasPrefix("/")
            && !value.contains("\\")
            && !value.lowercased().contains("ergentics_latin_primary_v1")
            && value.split(separator: "/").allSatisfy {
                !$0.isEmpty && $0 != "." && $0 != ".."
            }
    }

    private static func splitLines(_ data: Data) -> Set<String>? {
        guard !data.isEmpty, !data.contains(0x0d), data.last == 0x0a,
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        let rows = text.split(separator: "\n", omittingEmptySubsequences: false)
            .dropLast().map(String.init)
        guard !rows.isEmpty, rows.allSatisfy({ !$0.isEmpty }),
              Set(rows).count == rows.count else { return nil }
        return Set(rows)
    }

    private static func pathsOverlap(_ first: String, _ second: String)
        -> Bool
    {
        let a = first.lowercased()
        let b = second.lowercased()
        return a == b || a.hasPrefix(b + "/") || b.hasPrefix(a + "/")
    }

    private static func isHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
        }
    }
}

enum PrimeLatinProposalIndependentReplayComparatorV1 {
    static func compare(
        reconstruction: PrimeLatinProposalIndependentReplayReconstructionV1,
        references: PrimeLatinProposalIndependentReplayReferenceV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws -> PrimeLatinProposalIndependentReplayObservationV1 {
        try validateReconstruction(
            reconstruction, expectedPlan: expectedPlan)
        try validateReferenceArtifacts(
            references,
            reconstruction: reconstruction,
            expectedPlan: expectedPlan)
        try validateGit(
            references.git,
            reconstruction: reconstruction,
            expectedPlan: expectedPlan)
        guard references.pairAuthorityExact,
              references.snapshotAuthorityExact else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReference("authority_boundary")
        }
        return PrimeLatinProposalIndependentReplayObservationV1(
            reconstruction: reconstruction,
            references: references)
    }

    private static func validateReconstruction(
        _ value: PrimeLatinProposalIndependentReplayReconstructionV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws {
        let catalogHash = PrimeLatinProposalIndependentReplayHashV1.sha256(
            value.candidateCatalogData)
        let experimentHash = PrimeLatinProposalIndependentReplayHashV1.sha256(
            value.experimentManifestData)
        let pairHash = PrimeLatinProposalIndependentReplayHashV1.sha256(
            value.pairReceiptData)
        guard value.source == PrimeLatinReplaySourceV1(
                repository: expectedPlan.sourceRepository,
                commit: expectedPlan.sourceCommit,
                tree: expectedPlan.sourceTree),
              value.originalInputs.count == expectedPlan.inputBindings.count,
              zip(value.originalInputs, expectedPlan.inputBindings)
                .allSatisfy({ original, expected in
                    original.role == expected.role
                        && original.scope == expected.scope
                        && original.relativePath == expected.relativePath
                        && original.sha256 == expected.sha256
                        && original.byteCount == expected.byteCount
                }),
              catalogHash == expectedPlan.candidateCatalogSHA256,
              UInt64(value.candidateCatalogData.count)
                == expectedPlan.candidateCatalogByteCount,
              experimentHash == expectedPlan.experimentManifestSHA256,
              UInt64(value.experimentManifestData.count)
                == expectedPlan.experimentManifestByteCount,
              pairHash == expectedPlan.pairReceiptSHA256,
              UInt64(value.pairReceiptData.count)
                == expectedPlan.pairReceiptByteCount,
              value.candidateDeclarationSetSHA256
                == expectedPlan.candidateDeclarationSetSHA256,
              value.candidateDeclarationSetByteCount
                == expectedPlan.candidateDeclarationSetByteCount,
              value.tokenizerBundleSHA256
                == expectedPlan.tokenizerBundleSHA256,
              value.tokenizerBundleByteCount
                == expectedPlan.tokenizerBundleByteCount,
              value.candidateIDs == [expectedPlan.candidateID],
              value.candidateIdentitySHA256s
                == [expectedPlan.candidateIdentitySHA256],
              value.declarationBundleSHA256s
                == [expectedPlan.declarationBundleSHA256],
              UInt64(value.architecture.orderedTensors.count)
                == expectedPlan.orderedTensorCount,
              value.derivation.uniqueStorageCount
                == expectedPlan.uniqueParameterStorageCount,
              value.derivation.totalParameterCount
                == expectedPlan.totalParameterCount,
              value.experiment.requestedTrialBudget.optimizerSteps
                == expectedPlan.optimizerSteps,
              value.experiment.requestedTrialBudget.trainingTokens
                == expectedPlan.trainingTokens,
              value.experiment.requestedTrialBudget.wallClockSeconds
                == expectedPlan.wallClockSeconds,
              value.experiment.outputNamespace == expectedPlan.outputNamespace
        else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReconstruction("expected_output_golden")
        }

        guard let declaration = value.candidateCatalog
                .candidateDeclarations.candidates.first,
              value.candidateCatalog.candidateDeclarations.candidates.count == 1
        else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReconstruction("candidate_inventory")
        }
        let closureData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(
                declaration.declarationBundle.declarationTargetClosure)
        let identityData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(
                declaration.declarationBundle.identityMaterial)
        let bundleData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(
                declaration.declarationBundle)
        let setData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(
                value.candidateCatalog.candidateDeclarations)
        let tokenizerData = try
            PrimeLatinProposalIndependentReplayJSONV1.canonical(
                value.tokenizerBundle)
        guard PrimeLatinProposalIndependentReplayHashV1.sha256(closureData)
                == expectedPlan.declarationTargetClosureSHA256,
              UInt64(closureData.count)
                == expectedPlan.declarationTargetClosureByteCount,
              PrimeLatinProposalIndependentReplayHashV1.sha256(identityData)
                == expectedPlan.candidateIdentitySHA256,
              PrimeLatinProposalIndependentReplayHashV1.sha256(bundleData)
                == expectedPlan.declarationBundleSHA256,
              UInt64(bundleData.count)
                == expectedPlan.declarationBundleByteCount,
              PrimeLatinProposalIndependentReplayHashV1.sha256(setData)
                == expectedPlan.candidateDeclarationSetSHA256,
              UInt64(setData.count)
                == expectedPlan.candidateDeclarationSetByteCount,
              PrimeLatinProposalIndependentReplayHashV1.sha256(tokenizerData)
                == expectedPlan.tokenizerBundleSHA256,
              UInt64(tokenizerData.count)
                == expectedPlan.tokenizerBundleByteCount else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReconstruction("canonical_hash_chain")
        }
        if expectedPlan == .exactFinal {
            guard value.originalInputs.reduce(into: UInt64(0), {
                $0 += $1.byteCount
            }) == 8_084_712 else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidReconstruction("exact_final_input_aggregate")
            }
        }
    }

    private static func validateReferenceArtifacts(
        _ reference: PrimeLatinProposalIndependentReplayReferenceV1,
        reconstruction: PrimeLatinProposalIndependentReplayReconstructionV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws {
        let decodedCatalog: PrimeLatinReplayCandidateCatalogV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeCanonical(
                PrimeLatinReplayCandidateCatalogV1.self,
                from: reference.candidateCatalogData,
                context: "referenced_candidate_catalog")
        let decodedExperiment: PrimeLatinReplayExperimentManifestV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeCanonical(
                PrimeLatinReplayExperimentManifestV1.self,
                from: reference.experimentManifestData,
                context: "referenced_experiment_manifest")
        let decodedReceipt: PrimeLatinReplayPairReceiptV1 = try
            PrimeLatinProposalIndependentReplayJSONV1.decodeCanonical(
                PrimeLatinReplayPairReceiptV1.self,
                from: reference.pairReceiptData,
                context: "referenced_pair_receipt")

        guard decodedCatalog == reconstruction.candidateCatalog,
              decodedExperiment == reconstruction.experiment,
              decodedReceipt == reconstruction.pairReceipt,
              reference.candidateCatalogData
                == reconstruction.candidateCatalogData,
              reference.experimentManifestData
                == reconstruction.experimentManifestData,
              reference.pairReceiptData == reconstruction.pairReceiptData,
              reference.pairReceiptSHA256
                == expectedPlan.pairReceiptSHA256,
              reference.pairReceiptByteCount
                == expectedPlan.pairReceiptByteCount,
              UInt64(reference.pairReceiptData.count)
                == reference.pairReceiptByteCount,
              PrimeLatinProposalIndependentReplayHashV1.sha256(
                reference.pairReceiptData) == reference.pairReceiptSHA256,
              reference.source == reconstruction.source,
              reference.candidateCatalogSHA256
                == expectedPlan.candidateCatalogSHA256,
              reference.candidateCatalogByteCount
                == expectedPlan.candidateCatalogByteCount,
              UInt64(reference.candidateCatalogData.count)
                == reference.candidateCatalogByteCount,
              PrimeLatinProposalIndependentReplayHashV1.sha256(
                reference.candidateCatalogData)
                    == reference.candidateCatalogSHA256,
              reference.experimentManifestSHA256
                == expectedPlan.experimentManifestSHA256,
              reference.experimentManifestByteCount
                == expectedPlan.experimentManifestByteCount,
              UInt64(reference.experimentManifestData.count)
                == reference.experimentManifestByteCount,
              PrimeLatinProposalIndependentReplayHashV1.sha256(
                reference.experimentManifestData)
                    == reference.experimentManifestSHA256,
              reference.candidateDeclarationSetSHA256
                == expectedPlan.candidateDeclarationSetSHA256,
              reference.candidateDeclarationSetByteCount
                == expectedPlan.candidateDeclarationSetByteCount,
              reference.tokenizerBundleSHA256
                == expectedPlan.tokenizerBundleSHA256,
              reference.tokenizerBundleByteCount
                == expectedPlan.tokenizerBundleByteCount,
              reference.candidateIDs == [expectedPlan.candidateID],
              reference.candidateIdentitySHA256s
                == [expectedPlan.candidateIdentitySHA256],
              reference.declarationBundleSHA256s
                == [expectedPlan.declarationBundleSHA256],
              reference.outputNamespace == expectedPlan.outputNamespace,
              reference.snapshotArtifacts == expectedPlan.inputBindings else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReference("artifact_cross_binding")
        }
        let root = "evidence/latin-proposal-artifacts/v3"
        guard decodedReceipt.candidateCatalog.documentKind
                == "candidate_catalog_v3",
              decodedReceipt.candidateCatalog.relativePath
                == "\(root)/catalogs/\(reference.candidateCatalogSHA256).json",
              decodedReceipt.candidateCatalog.sha256
                == reference.candidateCatalogSHA256,
              decodedReceipt.candidateCatalog.byteCount
                == reference.candidateCatalogByteCount,
              decodedReceipt.experimentManifest.documentKind
                == "experiment_manifest_v3",
              decodedReceipt.experimentManifest.relativePath
                == "\(root)/experiments/\(reference.experimentManifestSHA256).json",
              decodedReceipt.experimentManifest.sha256
                == reference.experimentManifestSHA256,
              decodedReceipt.experimentManifest.byteCount
                == reference.experimentManifestByteCount,
              decodedReceipt.candidateDeclarationSetSHA256
                == reference.candidateDeclarationSetSHA256,
              decodedReceipt.candidateDeclarationSetByteCount
                == reference.candidateDeclarationSetByteCount else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReference("pair_child_bindings")
        }
    }

    private static func validateGit(
        _ git: PrimeLatinProposalIndependentReplayGitReferenceV1,
        reconstruction: PrimeLatinProposalIndependentReplayReconstructionV1,
        expectedPlan: PrimeLatinProposalIndependentReplayExpectedPlanV1
    ) throws {
        let emptySHA256 =
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        guard git.pairReceiptSHA256 == expectedPlan.pairReceiptSHA256,
              git.sourceRepository == expectedPlan.sourceRepository,
              git.headCommit == expectedPlan.sourceCommit,
              git.headTree == expectedPlan.sourceTree,
              git.statusSHA256 == emptySHA256,
              git.statusByteCount == 0,
              git.snapshotArtifactCount
                == UInt64(expectedPlan.inputBindings.count),
              git.repositoryArtifacts == expectedPlan.gitArtifacts,
              git.repositoryArtifacts.count == 7,
              git.authorityExact else {
            throw PrimeLatinProposalIndependentReplayError
                .invalidReference("git_observation")
        }
        for (index, artifact) in git.repositoryArtifacts.enumerated() {
            let expectedInput = expectedPlan.inputBindings[index]
            let original = reconstruction.originalInputs[index]
            guard artifact.role == expectedInput.role,
                  artifact.relativePath == expectedInput.relativePath,
                  artifact.sha256 == expectedInput.sha256,
                  artifact.byteCount == expectedInput.byteCount,
                  original.scope == .ergenticsLLMRepository,
                  artifact.gitBlobOID
                    == PrimeLatinProposalIndependentReplayHashV1.gitBlobOID(
                        original.data) else {
                throw PrimeLatinProposalIndependentReplayError
                    .invalidReference("git_artifact_\(artifact.role)")
            }
        }
    }
}
