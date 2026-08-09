import Foundation
import PrimeLatinProposalIndependentReplay
import PrimeLatinProposalProducerRevalidationObservation

public enum PrimeLatinProposalValidationCompositionErrorV1:
    Error,
    Equatable,
    Sendable
{
    case invalidChildObservation(String)
    case crossBindingMismatch(String)
    case captureChanged
}

public struct PrimeLatinProposalValidationCompositionAuthorityBoundaryV1:
    Equatable,
    Sendable
{
    public let disposition: String

    public let producerRevalidationCaptureAndRecaptureComplete: Bool
    public let independentReplayCaptureAndRecaptureComplete: Bool
    public let cooperativeSameRequestRootSequenceComplete: Bool
    public let producerRevalidationAuthorityBoundaryExact: Bool
    public let independentReplayAuthorityBoundaryExact: Bool
    public let exactPairReceiptCrossBindingMatched: Bool
    public let exactProducerSourceCrossBindingMatched: Bool
    public let exactCandidateCatalogCrossBindingMatched: Bool
    public let exactExperimentManifestCrossBindingMatched: Bool
    public let exactCandidateDeclarationSetCrossBindingMatched: Bool
    public let exactTokenizerBundleCrossBindingMatched: Bool
    public let exactCandidateIdentityInventoryCrossBindingMatched: Bool
    public let exactTwentyOneInputBindingCountCrossBindingMatched: Bool
    public let exactTwentyOneOriginalInputBytesRetained: Bool
    public let exactTrialBudgetCrossBindingMatched: Bool
    public let exactOutputNamespaceCrossBindingMatched: Bool
    public let outputNamespaceAbsenceVerified: Bool
    public let referencedInputSnapshotAvailable: Bool
    public let referencedArtifactBytesAvailable: Bool
    public let llmGitStateIndependentlyObserved: Bool
    public let revalidatorToolSourceIndependentlyObserved: Bool
    public let liveProducerWorkspaceRevalidationComplete: Bool
    public let independentPrimeReplayComplete: Bool
    public let validationCompositionComplete: Bool

    public let atomicCrossProcessSnapshotEstablished: Bool
    public let compilerCryptographicallyAuthenticated: Bool
    public let externalSourceToBinaryAttestationAvailable: Bool
    public let originRemoteCryptographicallyAuthenticated: Bool
    public let ignoredWorkspaceBytesObserved: Bool
    public let declarationSourceSemanticsIndependentlyVerified: Bool
    public let tokenizerModelSemanticsIndependentlyValidated: Bool
    public let tokenizerTrainingReplayComplete: Bool
    public let evaluationExecutionComplete: Bool
    public let selectionObservationComplete: Bool
    public let durableInputSnapshotPublished: Bool
    public let durableGitObservationPublished: Bool
    public let durableProducerRevalidationObservationPublished: Bool
    public let durableIndependentReplayObservationPublished: Bool
    public let durableValidationCompositionObservationPublished: Bool
    public let runtimeDecoderImplementationAvailable: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let primeProposalPolicyEstablished: Bool
    public let primeProposalPacketProduced: Bool
    public let primeTrialAuthorizationProduced: Bool
    public let primeDecisionReceiptProduced: Bool
    public let candidateSelectionAuthorized: Bool
    public let trialExecutionAuthorized: Bool
    public let furtherTrainingAuthorized: Bool
    public let promotionAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let proposalPairPublicationPerformedByThisComposition: Bool
    public let primeDurableReceiptPublished: Bool

    init() {
        disposition =
            "abstain_live_producer_revalidation_and_independent_prime_replay_composed_proposal_policy_runtime_decoder_initialization_evaluation_trial_decision_and_publication_authority_absent"

        producerRevalidationCaptureAndRecaptureComplete = true
        independentReplayCaptureAndRecaptureComplete = true
        cooperativeSameRequestRootSequenceComplete = true
        producerRevalidationAuthorityBoundaryExact = true
        independentReplayAuthorityBoundaryExact = true
        exactPairReceiptCrossBindingMatched = true
        exactProducerSourceCrossBindingMatched = true
        exactCandidateCatalogCrossBindingMatched = true
        exactExperimentManifestCrossBindingMatched = true
        exactCandidateDeclarationSetCrossBindingMatched = true
        exactTokenizerBundleCrossBindingMatched = true
        exactCandidateIdentityInventoryCrossBindingMatched = true
        exactTwentyOneInputBindingCountCrossBindingMatched = true
        exactTwentyOneOriginalInputBytesRetained = true
        exactTrialBudgetCrossBindingMatched = true
        exactOutputNamespaceCrossBindingMatched = true
        outputNamespaceAbsenceVerified = true
        referencedInputSnapshotAvailable = true
        referencedArtifactBytesAvailable = true
        llmGitStateIndependentlyObserved = true
        revalidatorToolSourceIndependentlyObserved = true
        liveProducerWorkspaceRevalidationComplete = true
        independentPrimeReplayComplete = true
        validationCompositionComplete = true

        atomicCrossProcessSnapshotEstablished = false
        compilerCryptographicallyAuthenticated = false
        externalSourceToBinaryAttestationAvailable = false
        originRemoteCryptographicallyAuthenticated = false
        ignoredWorkspaceBytesObserved = false
        declarationSourceSemanticsIndependentlyVerified = false
        tokenizerModelSemanticsIndependentlyValidated = false
        tokenizerTrainingReplayComplete = false
        evaluationExecutionComplete = false
        selectionObservationComplete = false
        durableInputSnapshotPublished = false
        durableGitObservationPublished = false
        durableProducerRevalidationObservationPublished = false
        durableIndependentReplayObservationPublished = false
        durableValidationCompositionObservationPublished = false
        runtimeDecoderImplementationAvailable = false
        runtimeDependencyClosureEstablished = false
        runtimeInitializationEstablished = false
        primeProposalPolicyEstablished = false
        primeProposalPacketProduced = false
        primeTrialAuthorizationProduced = false
        primeDecisionReceiptProduced = false
        candidateSelectionAuthorized = false
        trialExecutionAuthorized = false
        furtherTrainingAuthorized = false
        promotionAuthorized = false
        productUseAuthorized = false
        publicationAuthorized = false
        proposalPairPublicationPerformedByThisComposition = false
        primeDurableReceiptPublished = false
    }
}

public struct PrimeLatinProposalValidationCompositionObservationV1:
    Equatable,
    Sendable
{
    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let compositionPolicyID: String

    public let producerRevalidationObservation:
        PrimeLatinProposalProducerRevalidationObservationV1
    public let independentReplayObservation:
        PrimeLatinProposalIndependentReplayObservationV1

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
        PrimeLatinProposalValidationCompositionAuthorityBoundaryV1

    fileprivate init(
        producer:
            PrimeLatinProposalProducerRevalidationObservationV1,
        replay: PrimeLatinProposalIndependentReplayObservationV1,
        binding: PrimeLatinProposalValidationCompositionBindingV1
    ) {
        schema =
            "ergentics_prime_latin_proposal_v3_validation_composition_observation_v1"
        outcome = "abstain"
        verificationScope =
            "prime_owned_cooperative_same_request_root_sequence_composing_one_live_producer_revalidation_observation_and_one_independent_replay_observation_with_exact_shared_identity_hash_count_budget_and_output_namespace_cross_bindings_only_non_authorizing"
        compositionPolicyID =
            "prime_latin_v3_producer_revalidation_independent_replay_composition_v1"
        producerRevalidationObservation = producer
        independentReplayObservation = replay
        pairReceiptSHA256 = binding.pairReceiptSHA256
        pairReceiptByteCount = binding.pairReceiptByteCount
        producerRepository = binding.producerRepository
        producerCommit = binding.producerCommit
        producerTree = binding.producerTree
        candidateCatalogSHA256 = binding.candidateCatalogSHA256
        candidateCatalogByteCount = binding.candidateCatalogByteCount
        experimentManifestSHA256 = binding.experimentManifestSHA256
        experimentManifestByteCount = binding.experimentManifestByteCount
        candidateDeclarationSetSHA256 =
            binding.candidateDeclarationSetSHA256
        candidateDeclarationSetByteCount =
            binding.candidateDeclarationSetByteCount
        tokenizerBundleSHA256 = binding.tokenizerBundleSHA256
        tokenizerBundleByteCount = binding.tokenizerBundleByteCount
        candidateIDs = binding.candidateIDs
        candidateIdentitySHA256s = binding.candidateIdentitySHA256s
        declarationBundleSHA256s = binding.declarationBundleSHA256s
        inputBindingCount = binding.inputBindingCount
        retainedOriginalInputByteCount = binding.retainedOriginalInputByteCount
        optimizerSteps = binding.optimizerSteps
        trainingTokens = binding.trainingTokens
        wallClockSeconds = binding.wallClockSeconds
        outputNamespace = binding.outputNamespace
        orderedTensorCount = binding.orderedTensorCount
        uniqueParameterStorageCount = binding.uniqueParameterStorageCount
        totalParameterCount = binding.totalParameterCount
        authority = PrimeLatinProposalValidationCompositionAuthorityBoundaryV1()
    }
}

struct PrimeLatinProposalValidationCompositionChildProjectionV1:
    Equatable,
    Sendable
{
    enum Kind: String, Equatable, Sendable {
        case producer
        case replay
    }

    var kind: Kind
    var requestLabRoot: String
    var requestProducerRepositoryRoot: String
    var childContractExact: Bool
    var pairReceiptSHA256: String
    var pairReceiptByteCount: UInt64
    var producerRepository: String
    var producerCommit: String
    var producerTree: String
    var candidateCatalogSHA256: String
    var candidateCatalogByteCount: UInt64
    var experimentManifestSHA256: String
    var experimentManifestByteCount: UInt64
    var candidateDeclarationSetSHA256: String
    var candidateDeclarationSetByteCount: UInt64
    var tokenizerBundleSHA256: String
    var tokenizerBundleByteCount: UInt64
    var candidateIDs: [String]
    var candidateIdentitySHA256s: [String]
    var declarationBundleSHA256s: [String]
    var inputBindingCount: UInt64
    var retainedOriginalInputByteCount: UInt64
    var optimizerSteps: UInt64
    var trainingTokens: UInt64
    var wallClockSeconds: UInt64
    var outputNamespace: String
    var orderedTensorCount: UInt64
    var uniqueParameterStorageCount: UInt64
    var totalParameterCount: UInt64
}

struct PrimeLatinProposalValidationCompositionBindingV1:
    Equatable,
    Sendable
{
    let pairReceiptSHA256: String
    let pairReceiptByteCount: UInt64
    let producerRepository: String
    let producerCommit: String
    let producerTree: String
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
    let inputBindingCount: UInt64
    let retainedOriginalInputByteCount: UInt64
    let optimizerSteps: UInt64
    let trainingTokens: UInt64
    let wallClockSeconds: UInt64
    let outputNamespace: String
    let orderedTensorCount: UInt64
    let uniqueParameterStorageCount: UInt64
    let totalParameterCount: UInt64
}

private enum PrimeLatinProposalValidationCompositionPolicyV1 {
    static let pairReceiptSHA256 =
        "6c47d6ff17d72e48873c9f4ae9ce0a0fe7e57dea8e25db144c5f1d8d42761ff7"
    static let pairReceiptByteCount: UInt64 = 1_833
    static let producerRepository = "Ergentics/ergentics-llm"
    static let producerCommit =
        "776c412e3f10e8bf4e33cd0ae60787d9ca6b5831"
    static let producerTree =
        "c1f41758aea2860ab06039776f5ea0403dff1b61"
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
    static let inputBindingCount: UInt64 = 21
    static let retainedOriginalInputByteCount: UInt64 = 8_084_712
    static let optimizerSteps: UInt64 = 1
    static let trainingTokens: UInt64 = 128
    static let wallClockSeconds: UInt64 = 60
    static let outputNamespace =
        "models/latin-prospective/structural-fixture-v3-776c412e"
    static let orderedTensorCount: UInt64 = 12
    static let uniqueParameterStorageCount: UInt64 = 11
    static let totalParameterCount: UInt64 = 131_736
}

enum PrimeLatinProposalValidationCompositionEngineV1 {
    static func validate(
        producer: PrimeLatinProposalValidationCompositionChildProjectionV1,
        replay: PrimeLatinProposalValidationCompositionChildProjectionV1
    ) throws -> PrimeLatinProposalValidationCompositionBindingV1 {
        guard producer.kind == .producer else {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .invalidChildObservation("producer_kind")
        }
        guard replay.kind == .replay else {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .invalidChildObservation("replay_kind")
        }
        guard producer.childContractExact else {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .invalidChildObservation("producer_authority")
        }
        guard replay.childContractExact else {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .invalidChildObservation("replay_authority")
        }
        try requireExactFinal(producer, label: "producer")
        try requireExactFinal(replay, label: "replay")
        guard !producer.requestLabRoot.isEmpty,
              !producer.requestProducerRepositoryRoot.isEmpty,
              producer.requestLabRoot == replay.requestLabRoot,
              producer.requestProducerRepositoryRoot
                == replay.requestProducerRepositoryRoot
        else {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .crossBindingMismatch("same_request_roots")
        }

        try requireEqual(
            producer.pairReceiptSHA256, replay.pairReceiptSHA256,
            "pair_receipt_sha256")
        try requireEqual(
            producer.pairReceiptByteCount, replay.pairReceiptByteCount,
            "pair_receipt_byte_count")
        try requireEqual(
            producer.producerRepository, replay.producerRepository,
            "producer_repository")
        try requireEqual(
            producer.producerCommit, replay.producerCommit,
            "producer_commit")
        try requireEqual(
            producer.producerTree, replay.producerTree,
            "producer_tree")
        try requireEqual(
            producer.candidateCatalogSHA256,
            replay.candidateCatalogSHA256,
            "candidate_catalog_sha256")
        try requireEqual(
            producer.candidateCatalogByteCount,
            replay.candidateCatalogByteCount,
            "candidate_catalog_byte_count")
        try requireEqual(
            producer.experimentManifestSHA256,
            replay.experimentManifestSHA256,
            "experiment_manifest_sha256")
        try requireEqual(
            producer.experimentManifestByteCount,
            replay.experimentManifestByteCount,
            "experiment_manifest_byte_count")
        try requireEqual(
            producer.candidateDeclarationSetSHA256,
            replay.candidateDeclarationSetSHA256,
            "candidate_declaration_set_sha256")
        try requireEqual(
            producer.candidateDeclarationSetByteCount,
            replay.candidateDeclarationSetByteCount,
            "candidate_declaration_set_byte_count")
        try requireEqual(
            producer.tokenizerBundleSHA256,
            replay.tokenizerBundleSHA256,
            "tokenizer_bundle_sha256")
        try requireEqual(
            producer.tokenizerBundleByteCount,
            replay.tokenizerBundleByteCount,
            "tokenizer_bundle_byte_count")
        try requireEqual(
            producer.candidateIDs, replay.candidateIDs,
            "candidate_ids")
        try requireEqual(
            producer.candidateIdentitySHA256s,
            replay.candidateIdentitySHA256s,
            "candidate_identity_sha256s")
        try requireEqual(
            producer.declarationBundleSHA256s,
            replay.declarationBundleSHA256s,
            "declaration_bundle_sha256s")
        try requireEqual(
            producer.inputBindingCount, replay.inputBindingCount,
            "input_binding_count")
        try requireEqual(
            producer.optimizerSteps, replay.optimizerSteps,
            "optimizer_steps")
        try requireEqual(
            producer.trainingTokens, replay.trainingTokens,
            "training_tokens")
        try requireEqual(
            producer.wallClockSeconds, replay.wallClockSeconds,
            "wall_clock_seconds")
        try requireEqual(
            producer.outputNamespace, replay.outputNamespace,
            "output_namespace")

        return PrimeLatinProposalValidationCompositionBindingV1(
            pairReceiptSHA256: replay.pairReceiptSHA256,
            pairReceiptByteCount: replay.pairReceiptByteCount,
            producerRepository: replay.producerRepository,
            producerCommit: replay.producerCommit,
            producerTree: replay.producerTree,
            candidateCatalogSHA256: replay.candidateCatalogSHA256,
            candidateCatalogByteCount: replay.candidateCatalogByteCount,
            experimentManifestSHA256: replay.experimentManifestSHA256,
            experimentManifestByteCount: replay.experimentManifestByteCount,
            candidateDeclarationSetSHA256:
                replay.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                replay.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: replay.tokenizerBundleSHA256,
            tokenizerBundleByteCount: replay.tokenizerBundleByteCount,
            candidateIDs: replay.candidateIDs,
            candidateIdentitySHA256s: replay.candidateIdentitySHA256s,
            declarationBundleSHA256s: replay.declarationBundleSHA256s,
            inputBindingCount: replay.inputBindingCount,
            retainedOriginalInputByteCount:
                replay.retainedOriginalInputByteCount,
            optimizerSteps: replay.optimizerSteps,
            trainingTokens: replay.trainingTokens,
            wallClockSeconds: replay.wallClockSeconds,
            outputNamespace: replay.outputNamespace,
            orderedTensorCount: replay.orderedTensorCount,
            uniqueParameterStorageCount:
                replay.uniqueParameterStorageCount,
            totalParameterCount: replay.totalParameterCount)
    }

    private static func requireExactFinal(
        _ value: PrimeLatinProposalValidationCompositionChildProjectionV1,
        label: String
    ) throws {
        let expected = PrimeLatinProposalValidationCompositionPolicyV1.self
        guard value.pairReceiptSHA256 == expected.pairReceiptSHA256,
              value.pairReceiptByteCount == expected.pairReceiptByteCount,
              value.producerRepository == expected.producerRepository,
              value.producerCommit == expected.producerCommit,
              value.producerTree == expected.producerTree,
              value.candidateCatalogSHA256 == expected.candidateCatalogSHA256,
              value.candidateCatalogByteCount
                == expected.candidateCatalogByteCount,
              value.experimentManifestSHA256
                == expected.experimentManifestSHA256,
              value.experimentManifestByteCount
                == expected.experimentManifestByteCount,
              value.candidateDeclarationSetSHA256
                == expected.candidateDeclarationSetSHA256,
              value.candidateDeclarationSetByteCount
                == expected.candidateDeclarationSetByteCount,
              value.tokenizerBundleSHA256 == expected.tokenizerBundleSHA256,
              value.tokenizerBundleByteCount
                == expected.tokenizerBundleByteCount,
              value.candidateIDs == expected.candidateIDs,
              value.candidateIdentitySHA256s
                == expected.candidateIdentitySHA256s,
              value.declarationBundleSHA256s
                == expected.declarationBundleSHA256s,
              value.inputBindingCount == expected.inputBindingCount,
              value.retainedOriginalInputByteCount
                == expected.retainedOriginalInputByteCount,
              value.optimizerSteps == expected.optimizerSteps,
              value.trainingTokens == expected.trainingTokens,
              value.wallClockSeconds == expected.wallClockSeconds,
              value.outputNamespace == expected.outputNamespace,
              value.orderedTensorCount == expected.orderedTensorCount,
              value.uniqueParameterStorageCount
                == expected.uniqueParameterStorageCount,
              value.totalParameterCount == expected.totalParameterCount
        else {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .invalidChildObservation(label + "_exact_final")
        }
    }

    private static func requireEqual<T: Equatable>(
        _ first: T,
        _ second: T,
        _ field: String
    ) throws {
        guard first == second else {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .crossBindingMismatch(field)
        }
    }
}

public final class PrimeLatinProposalValidationCompositionCaptureV1:
    @unchecked Sendable
{
    public let observation:
        PrimeLatinProposalValidationCompositionObservationV1

    private let lock = NSLock()
    private let request: PrimeLatinProposalProducerRevalidationRequestV1
    private let producerCapture:
        PrimeLatinProposalProducerRevalidationCaptureV1
    private let replayCapture: PrimeLatinProposalIndependentReplayCaptureV1

    private init(
        request: PrimeLatinProposalProducerRevalidationRequestV1,
        producerCapture:
            PrimeLatinProposalProducerRevalidationCaptureV1,
        replayCapture: PrimeLatinProposalIndependentReplayCaptureV1,
        observation:
            PrimeLatinProposalValidationCompositionObservationV1
    ) {
        self.request = request
        self.producerCapture = producerCapture
        self.replayCapture = replayCapture
        self.observation = observation
    }

    public static func capture(
        request: PrimeLatinProposalProducerRevalidationRequestV1
    ) throws -> PrimeLatinProposalValidationCompositionCaptureV1 {
        let producerCapture:
            PrimeLatinProposalProducerRevalidationCaptureV1
        do {
            producerCapture = try .capture(request: request)
        } catch {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .invalidChildObservation("producer_capture")
        }

        let replayCapture: PrimeLatinProposalIndependentReplayCaptureV1
        do {
            replayCapture = try .capture(
                labRoot: request.labRoot,
                llmRepositoryRoot: request.producerRepositoryRoot)
        } catch {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .invalidChildObservation("replay_capture")
        }

        let binding = try validateLiveSequence(
            request: request,
            initialProducer: producerCapture.observation,
            initialReplay: replayCapture.observation,
            producerCapture: producerCapture,
            replayCapture: replayCapture)
        let observation =
            PrimeLatinProposalValidationCompositionObservationV1(
                producer: producerCapture.observation,
                replay: replayCapture.observation,
                binding: binding)
        return PrimeLatinProposalValidationCompositionCaptureV1(
            request: request,
            producerCapture: producerCapture,
            replayCapture: replayCapture,
            observation: observation)
    }

    @discardableResult
    public func recaptureAndValidateUnchanged() throws
        -> PrimeLatinProposalValidationCompositionObservationV1
    {
        lock.lock()
        defer { lock.unlock() }
        do {
            let binding = try Self.validateLiveSequence(
                request: request,
                initialProducer: producerCapture.observation,
                initialReplay: replayCapture.observation,
                producerCapture: producerCapture,
                replayCapture: replayCapture)
            let current =
                PrimeLatinProposalValidationCompositionObservationV1(
                    producer: producerCapture.observation,
                    replay: replayCapture.observation,
                    binding: binding)
            guard current == observation else {
                throw PrimeLatinProposalValidationCompositionErrorV1
                    .captureChanged
            }
            return current
        } catch {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .captureChanged
        }
    }

    static func makeAuthorityForTesting()
        -> PrimeLatinProposalValidationCompositionAuthorityBoundaryV1
    {
        PrimeLatinProposalValidationCompositionAuthorityBoundaryV1()
    }

    static func exactProducerProjectionForTesting(
        labRoot: String = "/synthetic/lab",
        producerRepositoryRoot: String = "/synthetic/producer"
    ) -> PrimeLatinProposalValidationCompositionChildProjectionV1 {
        exactProjectionForTesting(
            kind: .producer,
            labRoot: labRoot,
            producerRepositoryRoot: producerRepositoryRoot)
    }

    static func exactReplayProjectionForTesting(
        labRoot: String = "/synthetic/lab",
        producerRepositoryRoot: String = "/synthetic/producer"
    ) -> PrimeLatinProposalValidationCompositionChildProjectionV1 {
        exactProjectionForTesting(
            kind: .replay,
            labRoot: labRoot,
            producerRepositoryRoot: producerRepositoryRoot)
    }

    static func validateForTesting(
        producer: PrimeLatinProposalValidationCompositionChildProjectionV1,
        replay: PrimeLatinProposalValidationCompositionChildProjectionV1
    ) throws -> PrimeLatinProposalValidationCompositionBindingV1 {
        try PrimeLatinProposalValidationCompositionEngineV1.validate(
            producer: producer,
            replay: replay)
    }

    static func validateSequenceForTesting(
        initialProducer:
            PrimeLatinProposalValidationCompositionChildProjectionV1,
        initialReplay:
            PrimeLatinProposalValidationCompositionChildProjectionV1,
        recaptureReplay:
            () throws
                -> PrimeLatinProposalValidationCompositionChildProjectionV1,
        recaptureProducer:
            () throws
                -> PrimeLatinProposalValidationCompositionChildProjectionV1
    ) throws -> PrimeLatinProposalValidationCompositionBindingV1 {
        let replayBefore = try recaptureReplay()
        let producerCurrent = try recaptureProducer()
        let replayAfter = try recaptureReplay()
        guard replayBefore == initialReplay,
              producerCurrent == initialProducer,
              replayAfter == initialReplay,
              replayBefore == replayAfter
        else {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .captureChanged
        }
        return try PrimeLatinProposalValidationCompositionEngineV1.validate(
            producer: producerCurrent,
            replay: replayAfter)
    }

    private static func validateLiveSequence(
        request: PrimeLatinProposalProducerRevalidationRequestV1,
        initialProducer:
            PrimeLatinProposalProducerRevalidationObservationV1,
        initialReplay: PrimeLatinProposalIndependentReplayObservationV1,
        producerCapture:
            PrimeLatinProposalProducerRevalidationCaptureV1,
        replayCapture: PrimeLatinProposalIndependentReplayCaptureV1
    ) throws -> PrimeLatinProposalValidationCompositionBindingV1 {
        do {
            return try validateSequenceForTesting(
                initialProducer: projectProducer(
                    initialProducer,
                    request: request),
                initialReplay: projectReplay(
                    initialReplay,
                    request: request),
                recaptureReplay: {
                    let current = try replayCapture
                        .recaptureAndValidateUnchanged()
                    return projectReplay(current, request: request)
                },
                recaptureProducer: {
                    let current = try producerCapture
                        .recaptureAndValidateUnchanged()
                    return projectProducer(current, request: request)
                })
        } catch let error as
            PrimeLatinProposalValidationCompositionErrorV1
        {
            throw error
        } catch {
            throw PrimeLatinProposalValidationCompositionErrorV1
                .captureChanged
        }
    }

    private static func exactProjectionForTesting(
        kind: PrimeLatinProposalValidationCompositionChildProjectionV1.Kind,
        labRoot: String,
        producerRepositoryRoot: String
    ) -> PrimeLatinProposalValidationCompositionChildProjectionV1 {
        let expected = PrimeLatinProposalValidationCompositionPolicyV1.self
        return PrimeLatinProposalValidationCompositionChildProjectionV1(
            kind: kind,
            requestLabRoot: labRoot,
            requestProducerRepositoryRoot: producerRepositoryRoot,
            childContractExact: true,
            pairReceiptSHA256: expected.pairReceiptSHA256,
            pairReceiptByteCount: expected.pairReceiptByteCount,
            producerRepository: expected.producerRepository,
            producerCommit: expected.producerCommit,
            producerTree: expected.producerTree,
            candidateCatalogSHA256: expected.candidateCatalogSHA256,
            candidateCatalogByteCount: expected.candidateCatalogByteCount,
            experimentManifestSHA256: expected.experimentManifestSHA256,
            experimentManifestByteCount: expected.experimentManifestByteCount,
            candidateDeclarationSetSHA256:
                expected.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                expected.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: expected.tokenizerBundleSHA256,
            tokenizerBundleByteCount: expected.tokenizerBundleByteCount,
            candidateIDs: expected.candidateIDs,
            candidateIdentitySHA256s: expected.candidateIdentitySHA256s,
            declarationBundleSHA256s: expected.declarationBundleSHA256s,
            inputBindingCount: expected.inputBindingCount,
            retainedOriginalInputByteCount:
                expected.retainedOriginalInputByteCount,
            optimizerSteps: expected.optimizerSteps,
            trainingTokens: expected.trainingTokens,
            wallClockSeconds: expected.wallClockSeconds,
            outputNamespace: expected.outputNamespace,
            orderedTensorCount: expected.orderedTensorCount,
            uniqueParameterStorageCount:
                expected.uniqueParameterStorageCount,
            totalParameterCount: expected.totalParameterCount)
    }

    private static func projectProducer(
        _ value: PrimeLatinProposalProducerRevalidationObservationV1,
        request: PrimeLatinProposalProducerRevalidationRequestV1
    ) -> PrimeLatinProposalValidationCompositionChildProjectionV1 {
        let expected = PrimeLatinProposalValidationCompositionPolicyV1.self
        return PrimeLatinProposalValidationCompositionChildProjectionV1(
            kind: .producer,
            requestLabRoot: request.labRoot.path,
            requestProducerRepositoryRoot:
                request.producerRepositoryRoot.path,
            childContractExact: producerContractExact(value),
            pairReceiptSHA256: value.pairReceiptSHA256,
            pairReceiptByteCount: expected.pairReceiptByteCount,
            producerRepository: value.producerRepository,
            producerCommit: value.producerCommit,
            producerTree: value.producerTree,
            candidateCatalogSHA256: value.candidateCatalogSHA256,
            candidateCatalogByteCount: value.candidateCatalogByteCount,
            experimentManifestSHA256: value.experimentManifestSHA256,
            experimentManifestByteCount: value.experimentManifestByteCount,
            candidateDeclarationSetSHA256:
                value.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                value.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: value.tokenizerBundleSHA256,
            tokenizerBundleByteCount: value.tokenizerBundleByteCount,
            candidateIDs: value.candidateIDs,
            candidateIdentitySHA256s: value.candidateIdentitySHA256s,
            declarationBundleSHA256s: value.declarationBundleSHA256s,
            inputBindingCount: value.inputBindingCount,
            retainedOriginalInputByteCount:
                expected.retainedOriginalInputByteCount,
            optimizerSteps: value.optimizerSteps,
            trainingTokens: value.trainingTokens,
            wallClockSeconds: value.wallClockSeconds,
            outputNamespace: value.outputNamespace,
            orderedTensorCount: expected.orderedTensorCount,
            uniqueParameterStorageCount:
                expected.uniqueParameterStorageCount,
            totalParameterCount: expected.totalParameterCount)
    }

    private static func projectReplay(
        _ value: PrimeLatinProposalIndependentReplayObservationV1,
        request: PrimeLatinProposalProducerRevalidationRequestV1
    ) -> PrimeLatinProposalValidationCompositionChildProjectionV1 {
        PrimeLatinProposalValidationCompositionChildProjectionV1(
            kind: .replay,
            requestLabRoot: request.labRoot.path,
            requestProducerRepositoryRoot:
                request.producerRepositoryRoot.path,
            childContractExact: replayContractExact(value),
            pairReceiptSHA256: value.pairReceiptSHA256,
            pairReceiptByteCount: value.pairReceiptByteCount,
            producerRepository: value.producerRepository,
            producerCommit: value.producerCommit,
            producerTree: value.producerTree,
            candidateCatalogSHA256: value.candidateCatalogSHA256,
            candidateCatalogByteCount: value.candidateCatalogByteCount,
            experimentManifestSHA256: value.experimentManifestSHA256,
            experimentManifestByteCount: value.experimentManifestByteCount,
            candidateDeclarationSetSHA256:
                value.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                value.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: value.tokenizerBundleSHA256,
            tokenizerBundleByteCount: value.tokenizerBundleByteCount,
            candidateIDs: value.candidateIDs,
            candidateIdentitySHA256s: value.candidateIdentitySHA256s,
            declarationBundleSHA256s: value.declarationBundleSHA256s,
            inputBindingCount: value.inputBindingCount,
            retainedOriginalInputByteCount:
                value.retainedOriginalInputByteCount,
            optimizerSteps: value.optimizerSteps,
            trainingTokens: value.trainingTokens,
            wallClockSeconds: value.wallClockSeconds,
            outputNamespace: value.outputNamespace,
            orderedTensorCount: value.orderedTensorCount,
            uniqueParameterStorageCount:
                value.uniqueParameterStorageCount,
            totalParameterCount: value.totalParameterCount)
    }

    private static func producerContractExact(
        _ value: PrimeLatinProposalProducerRevalidationObservationV1
    ) -> Bool {
        let source = value.toolSource
        let build = value.build
        let process = value.process
        let authority = value.authority
        return value.schema
            == "ergentics_prime_latin_proposal_v3_producer_revalidation_observation_v1"
            && value.outcome == "abstain"
            && value.verificationScope
                == "prime_built_exact_merged_revalidator_source_closure_and_observed_two_cross_bound_live_producer_processes_only_non_authorizing"
            && source.repository == "Ergentics/ergentics-llm"
            && source.locallyDeclaredOriginURL
                == "https://github.com/Ergentics/ergentics-llm.git"
            && source.originObservationScope
                == "locally_declared_origin_only_not_network_authenticated"
            && source.commit
                == "1ccfb6bf6718e2378f14ab87cacae1ada303cf48"
            && source.tree
                == "6ee438bf1132d26767fbf447355b8165455b956f"
            && source.parentCommit
                == PrimeLatinProposalValidationCompositionPolicyV1
                    .producerCommit
            && source.rawCommitSHA256
                == "380c13a3f9f3421db875d2ccc3c4547002374a9d74427a0573e0c59f6d3078ac"
            && source.rawCommitByteCount == 1_328
            && source.trackedIndexEntryCount == 147
            && source.trackedIndexInventorySHA256
                == "802f7505ad91869b27420e0beb152e6ba725eb82a801b4fd9289d999afac0c81"
            && source.trackedIndexInventoryByteCount == 14_281
            && source.artifacts.count == 4
            && build.buildPolicyID
                == "prime_latin_exact_source_direct_swiftc_build_v1"
            && build.compilerLauncher.role == "compiler_launcher"
            && build.compilerLauncher.absolutePath == "/usr/bin/xcrun"
            && build.compiler.role == "swift_compiler"
            && build.compilerIdentityScope
                == "fixed_developer_directory_exact_swift_driver_binary_observed_not_cryptographically_authenticated"
            && build.compileCommandCount == 3
            && build.processLaunchCount == 5
            && build.governanceArtifactCount == 4
            && build.compilerInputSourceCount == 3
            && build.executable.role
                == "producer_revalidation_probe_executable"
            && process.processPolicyID
                == "prime_latin_producer_revalidation_fixed_fresh_process_v1"
            && process.invocationCount == 2
            && process.standardOutputSHA256
                == "0657289657fbb99ca91ad9b1788ccfbe9b1697881cef85df6241ab30b0bf984f"
            && process.standardOutputByteCount == 8_434
            && process.standardErrorSHA256
                == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
            && process.standardErrorByteCount == 0
            && authority.disposition
                == "abstain_producer_revalidation_observation_complete_requires_independent_prime_replay"
            && authority.pairCaptureAndRecaptureComplete
            && authority.inputSnapshotCaptureAndRecaptureComplete
            && authority.producerGitObservationComplete
            && authority.exactMergedRevalidatorSourceObserved
            && authority.exactRevalidatorSourceClosureObserved
            && authority.compilerIdentityObserved
            && !authority.compilerCryptographicallyAuthenticated
            && authority.localExactSourceClosureBuildObserved
            && !authority.externalSourceToBinaryAttestationAvailable
            && authority.revalidatorExecutableBuiltFromObservedSourceClosure
            && authority.revalidatorExecutableIdentityStable
            && authority.boundedFreshProcessObservationComplete
            && authority.canonicalRevalidationObservationDecoded
            && authority.expectedPairReceiptCrossBindingValidated
            && authority.exactTwentyOneInputBindingsCrossBound
            && authority.canonicalHashChainCrossBindingsMatched
            && authority.repeatedProducerProcessObservationUnchanged
            && authority.outputNamespaceAbsenceVerified
            && authority.llmGitStateIndependentlyObserved
            && authority.revalidatorToolSourceIndependentlyObserved
            && authority.liveProducerWorkspaceRevalidationComplete
            && !authority.originRemoteCryptographicallyAuthenticated
            && !authority.ignoredWorkspaceBytesObserved
            && !authority.durableInputSnapshotPublished
            && !authority.durableGitObservationPublished
            && !authority.durableRevalidationObservationPublished
            && !authority.independentPrimeReplayComplete
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
            && !authority.proposalPairPublicationPerformedByThisObservation
            && !authority.primeDurableReceiptPublished
    }

    private static func replayContractExact(
        _ value: PrimeLatinProposalIndependentReplayObservationV1
    ) -> Bool {
        let authority = value.authority
        return value.schema
            == "ergentics_prime_latin_proposal_v3_independent_replay_observation_v1"
            && value.outcome == "abstain"
            && value.verificationScope
                == "prime_owned_independent_typed_reconstruction_from_one_git_bound_retained_twenty_one_original_input_snapshot_and_byte_exact_catalog_experiment_cross_check_only_non_authorizing"
            && value.replayPolicyID
                == "prime_latin_v3_retained_original_input_independent_reconstruction_v1"
            && authority.disposition
                == "abstain_independent_prime_structural_replay_complete_live_producer_revalidation_not_composed_and_runtime_decoder_initialization_evaluation_trial_and_publication_authority_absent"
            && authority.pairCaptureAndRecaptureComplete
            && authority.inputSnapshotCaptureAndRecaptureComplete
            && authority.producerGitObservationComplete
            && authority.exactTwentyOneOriginalInputBindingsCrossBound
            && authority.exactTwentyOneOriginalInputBytesRetained
            && authority.retainedOriginalInputHashCountRecomputationComplete
            && authority.independentTokenizerBundleReconstructionComplete
            && authority.independentDeclarationTargetClosureReconstructionComplete
            && authority.independentCandidateIdentityReconstructionComplete
            && authority.independentCandidateDeclarationSetReconstructionComplete
            && authority.independentCandidateCatalogReconstructionComplete
            && authority.independentExperimentManifestReconstructionComplete
            && authority.canonicalCandidateCatalogBytesMatched
            && authority.canonicalExperimentManifestBytesMatched
            && authority.canonicalHashChainRecomputationComplete
            && authority.outputNamespaceAbsenceVerified
            && authority.referencedInputSnapshotAvailable
            && authority.referencedArtifactBytesAvailable
            && authority.llmGitStateIndependentlyObserved
            && authority.independentPrimeReplayComplete
            && !authority.ergenticsLatinProducerModuleImported
            && !authority.ergenticsLatinProducerFunctionInvoked
            && !authority.ergenticsLatinProducerSourceUsedAsReplayImplementation
            && !authority.liveProducerWorkspaceRevalidationComplete
            && !authority.revalidatorToolSourceIndependentlyObserved
            && !authority.originRemoteCryptographicallyAuthenticated
            && !authority.ignoredWorkspaceBytesObserved
            && !authority.declarationSourceSemanticsIndependentlyVerified
            && !authority.tokenizerModelSemanticsIndependentlyValidated
            && !authority.tokenizerTrainingReplayComplete
            && !authority.evaluationExecutionComplete
            && !authority.selectionObservationComplete
            && !authority.durableInputSnapshotPublished
            && !authority.durableGitObservationPublished
            && !authority.durableIndependentReplayObservationPublished
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
            && !authority.proposalPairPublicationPerformedByThisObservation
            && !authority.primeDurableReceiptPublished
    }
}
