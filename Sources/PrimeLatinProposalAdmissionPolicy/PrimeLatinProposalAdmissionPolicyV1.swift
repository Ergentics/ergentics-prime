import PrimeLatinProposalValidationCompositionReceipt

public enum PrimeLatinProposalAdmissionOutcomeV1:
    String,
    CaseIterable,
    Equatable,
    Sendable
{
    case abstain = "ABSTAIN"
}

public enum PrimeLatinProposalAdmissionReasonV1:
    String,
    CaseIterable,
    Equatable,
    Hashable,
    Sendable
{
    case decodedReceiptDoesNotRestoreCurrentLiveValidation =
        "decoded_receipt_does_not_restore_current_live_validation"
    case exactCandidateIDClassifiedAsStructuralFixtureByPolicy =
        "exact_candidate_id_classified_as_structural_fixture_by_policy"
    case runtimeDecoderImplementationNotEstablishedByReceipt =
        "runtime_decoder_implementation_not_established_by_receipt"
    case runtimeDependencyClosureNotEstablishedByReceipt =
        "runtime_dependency_closure_not_established_by_receipt"
    case runtimeInitializationNotEstablishedByReceipt =
        "runtime_initialization_not_established_by_receipt"
}

public struct PrimeLatinProposalAdmissionAuthorityBoundaryV1:
    Equatable,
    Sendable
{
    public let disposition: String

    public let exactTypedReceiptProjectionValidated: Bool
    public let sourceReceiptHistoricalAuthorityClaimsRetained: Bool
    public let exactCandidateIDClassifiedAsStructuralFixtureByPolicy: Bool
    public let primeProposalPolicyEstablished: Bool
    public let proposalAdmissionEvaluationComplete: Bool
    public let typedAbstainProduced: Bool
    public let orderedAbstentionReasonsComplete: Bool

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
    public let currentLiveProducerWorkspaceRevalidationRestoredFromReceipt:
        Bool
    public let currentIndependentPrimeReplayRestoredFromReceipt: Bool
    public let runtimeDecoderImplementationAvailable: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let receiptArtifactBindingVerified: Bool
    public let canonicalReceiptBytesVerified: Bool
    public let receiptContentAddressVerified: Bool
    public let durableInputSnapshotPublished: Bool
    public let durableGitObservationPublished: Bool
    public let durableProducerRevalidationObservationPublished: Bool
    public let durableIndependentReplayObservationPublished: Bool
    public let durableValidationCompositionObservationPublished: Bool
    public let rawProducerRevalidationObservationAvailableToPolicy: Bool
    public let rawIndependentReplayObservationAvailableToPolicy: Bool
    public let durableValidationCompositionReceiptPublished: Bool
    public let primeDurableReceiptPublished: Bool
    public let proposalAdmissionGranted: Bool
    public let primeProposalPacketProduced: Bool
    public let primeTrialAuthorizationProduced: Bool
    public let primeDecisionReceiptProduced: Bool
    public let candidateSelectionAuthorized: Bool
    public let trialExecutionAuthorized: Bool
    public let furtherTrainingAuthorized: Bool
    public let promotionAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let proposalPairPublicationPerformedByThisPolicy: Bool
    public let admissionObservationPublished: Bool
    public let publicNetworkPublicationPerformed: Bool

    init() {
        disposition =
            "abstain_exact_typed_validation_composition_receipt_projection_" +
            "admission_evaluated_current_live_validation_not_restored_" +
            "candidate_classified_structural_fixture_runtime_decoder_" +
            "dependency_closure_and_initialization_not_established_by_" +
            "receipt"

        exactTypedReceiptProjectionValidated = true
        sourceReceiptHistoricalAuthorityClaimsRetained = true
        exactCandidateIDClassifiedAsStructuralFixtureByPolicy = true
        primeProposalPolicyEstablished = true
        proposalAdmissionEvaluationComplete = true
        typedAbstainProduced = true
        orderedAbstentionReasonsComplete = true

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
        currentLiveProducerWorkspaceRevalidationRestoredFromReceipt = false
        currentIndependentPrimeReplayRestoredFromReceipt = false
        runtimeDecoderImplementationAvailable = false
        runtimeDependencyClosureEstablished = false
        runtimeInitializationEstablished = false
        receiptArtifactBindingVerified = false
        canonicalReceiptBytesVerified = false
        receiptContentAddressVerified = false
        durableInputSnapshotPublished = false
        durableGitObservationPublished = false
        durableProducerRevalidationObservationPublished = false
        durableIndependentReplayObservationPublished = false
        durableValidationCompositionObservationPublished = false
        rawProducerRevalidationObservationAvailableToPolicy = false
        rawIndependentReplayObservationAvailableToPolicy = false
        durableValidationCompositionReceiptPublished = false
        primeDurableReceiptPublished = false
        proposalAdmissionGranted = false
        primeProposalPacketProduced = false
        primeTrialAuthorizationProduced = false
        primeDecisionReceiptProduced = false
        candidateSelectionAuthorized = false
        trialExecutionAuthorized = false
        furtherTrainingAuthorized = false
        promotionAuthorized = false
        productUseAuthorized = false
        publicationAuthorized = false
        proposalPairPublicationPerformedByThisPolicy = false
        admissionObservationPublished = false
        publicNetworkPublicationPerformed = false
    }
}

public struct PrimeLatinProposalAdmissionEvaluationV1:
    Equatable,
    Sendable
{
    public let schema: String
    public let outcome: PrimeLatinProposalAdmissionOutcomeV1
    public let verificationScope: String
    public let policyID: String
    public let sourceReceipt:
        PrimeLatinProposalValidationCompositionReceiptV1
    public let orderedReasons: [PrimeLatinProposalAdmissionReasonV1]
    public let authority: PrimeLatinProposalAdmissionAuthorityBoundaryV1

    init(
        sourceReceipt:
            PrimeLatinProposalValidationCompositionReceiptV1,
        orderedReasons: [PrimeLatinProposalAdmissionReasonV1]
    ) {
        schema =
            "ergentics_prime_latin_proposal_v3_admission_observation_v1"
        outcome = .abstain
        verificationScope =
            "exact_frozen_v3_typed_receipt_projection_only_no_artifact_" +
            "binding_or_current_liveness"
        policyID =
            "prime_latin_v3_exact_typed_receipt_projection_admission_v1"
        self.sourceReceipt = sourceReceipt
        self.orderedReasons = orderedReasons
        authority = PrimeLatinProposalAdmissionAuthorityBoundaryV1()
    }
}

public enum PrimeLatinProposalAdmissionPolicyV1 {
    public static let orderedAbstentionReasons: [
        PrimeLatinProposalAdmissionReasonV1
    ] = [
        .decodedReceiptDoesNotRestoreCurrentLiveValidation,
        .exactCandidateIDClassifiedAsStructuralFixtureByPolicy,
        .runtimeDecoderImplementationNotEstablishedByReceipt,
        .runtimeDependencyClosureNotEstablishedByReceipt,
        .runtimeInitializationNotEstablishedByReceipt,
    ]

    public static func evaluate(
        receipt: PrimeLatinProposalValidationCompositionReceiptV1
    ) throws -> PrimeLatinProposalAdmissionEvaluationV1 {
        try receipt.validateExactV1()
        return PrimeLatinProposalAdmissionEvaluationV1(
            sourceReceipt: receipt,
            orderedReasons: orderedAbstentionReasons)
    }
}
