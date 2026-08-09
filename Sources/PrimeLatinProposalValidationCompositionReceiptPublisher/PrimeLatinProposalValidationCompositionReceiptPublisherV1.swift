import Foundation
import PrimeCore
import PrimeLatinProposalValidationComposition
import PrimeLatinProposalValidationCompositionReceipt

public enum PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1:
    Error,
    Equatable,
    Sendable
{
    case invalidSourceObservation(String)
    case captureChanged
    case receiptTooLarge
    case publicationFailed
    case verificationFailed
}

public struct PrimeLatinProposalValidationCompositionReceiptPublicationAuthorityBoundaryV1:
    Equatable,
    Sendable
{
    public let disposition: String

    public let validationCompositionCaptureAndRecaptureComplete: Bool
    public let validationCompositionAuthorityBoundaryExact: Bool
    public let exactReceiptProjectionComplete: Bool
    public let canonicalReceiptEncodingComplete: Bool
    public let canonicalReceiptRedecodeComplete: Bool
    public let receiptContentAddressBindingVerified: Bool
    public let privateArtifactRootModeVerified: Bool
    public let artifactRootEmptyAtAdmission: Bool
    public let artifactRootEmptyAtFinalPrepublicationMutationCheck: Bool
    public let exclusiveNoReplacePublicationComplete: Bool
    public let immutableSingleLinkReceiptArtifactVerified: Bool
    public let receiptFileDurabilitySyncComplete: Bool
    public let receiptDirectoryDurabilitySyncComplete: Bool
    public let durableValidationCompositionReceiptPublished: Bool
    public let primeDurableReceiptPublished: Bool

    public let atomicCrossProcessSnapshotEstablished: Bool
    public let exclusiveArtifactRootOwnershipEstablished: Bool
    public let postPublicationSourceRecaptureComplete: Bool
    public let compilerCryptographicallyAuthenticated: Bool
    public let externalSourceToBinaryAttestationAvailable: Bool
    public let publisherIdentityCryptographicallyAuthenticated: Bool
    public let receiptCryptographicallySigned: Bool
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
    public let rawProducerRevalidationObservationPublished: Bool
    public let rawIndependentReplayObservationPublished: Bool
    public let currentLiveProducerWorkspaceRevalidationRestoredFromReceipt:
        Bool
    public let currentIndependentPrimeReplayRestoredFromReceipt: Bool
    public let runtimeDecoderImplementationAvailable: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let primeProposalPolicyEstablished: Bool
    public let proposalAdmissionEvaluationComplete: Bool
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
    public let proposalPairPublicationPerformedByThisPublisher: Bool
    public let publicNetworkPublicationPerformed: Bool

    init() {
        disposition =
            "abstain_durable_validation_composition_receipt_published_" +
            "decoded_receipt_does_not_restore_live_validation_or_" +
            "establish_proposal_admission_packet_trial_runtime_selection_" +
            "promotion_product_or_publication_authority"

        validationCompositionCaptureAndRecaptureComplete = true
        validationCompositionAuthorityBoundaryExact = true
        exactReceiptProjectionComplete = true
        canonicalReceiptEncodingComplete = true
        canonicalReceiptRedecodeComplete = true
        receiptContentAddressBindingVerified = true
        privateArtifactRootModeVerified = true
        artifactRootEmptyAtAdmission = true
        artifactRootEmptyAtFinalPrepublicationMutationCheck = true
        exclusiveNoReplacePublicationComplete = true
        immutableSingleLinkReceiptArtifactVerified = true
        receiptFileDurabilitySyncComplete = true
        receiptDirectoryDurabilitySyncComplete = true
        durableValidationCompositionReceiptPublished = true
        primeDurableReceiptPublished = true

        atomicCrossProcessSnapshotEstablished = false
        exclusiveArtifactRootOwnershipEstablished = false
        postPublicationSourceRecaptureComplete = false
        compilerCryptographicallyAuthenticated = false
        externalSourceToBinaryAttestationAvailable = false
        publisherIdentityCryptographicallyAuthenticated = false
        receiptCryptographicallySigned = false
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
        rawProducerRevalidationObservationPublished = false
        rawIndependentReplayObservationPublished = false
        currentLiveProducerWorkspaceRevalidationRestoredFromReceipt = false
        currentIndependentPrimeReplayRestoredFromReceipt = false
        runtimeDecoderImplementationAvailable = false
        runtimeDependencyClosureEstablished = false
        runtimeInitializationEstablished = false
        primeProposalPolicyEstablished = false
        proposalAdmissionEvaluationComplete = false
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
        proposalPairPublicationPerformedByThisPublisher = false
        publicNetworkPublicationPerformed = false
    }
}

public struct PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1:
    Equatable,
    Sendable
{
    public let schema: String
    public let outcome: String
    public let verificationScope: String
    public let publicationPolicyID: String
    public let receipt: PrimeLatinProposalValidationCompositionReceiptV1
    public let artifactBinding: PrimeArtifactBinding
    public let verifiedArtifact: PrimeVerifiedArtifact
    public let authority:
        PrimeLatinProposalValidationCompositionReceiptPublicationAuthorityBoundaryV1

    init(
        receipt: PrimeLatinProposalValidationCompositionReceiptV1,
        artifactBinding: PrimeArtifactBinding,
        verifiedArtifact: PrimeVerifiedArtifact
    ) {
        schema =
            "ergentics_prime_latin_proposal_v3_validation_composition_" +
            "receipt_publication_observation_v1"
        outcome = "abstain"
        verificationScope =
            "prime_owned_descriptor_safe_exclusive_content_addressed_" +
            "publication_of_one_canonical_validation_composition_" +
            "receipt_only_non_authorizing"
        publicationPolicyID =
            "prime_latin_v3_validation_composition_receipt_publication_v1"
        self.receipt = receipt
        self.artifactBinding = artifactBinding
        self.verifiedArtifact = verifiedArtifact
        authority =
            PrimeLatinProposalValidationCompositionReceiptPublicationAuthorityBoundaryV1()
    }
}

public enum PrimeLatinProposalValidationCompositionReceiptPublisherV1 {
    public static func publish(
        capture: PrimeLatinProposalValidationCompositionCaptureV1,
        artifactRoot: PrimeArtifactRoot
    ) throws
        -> PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1
    {
        let initialProjection = projection(
            of: capture.observation)
        return try publishUsingSingleEngine(
            initialProjection: initialProjection,
            artifactRoot: artifactRoot,
            recaptureProjection: {
                let current: PrimeLatinProposalValidationCompositionObservationV1
                do {
                    current = try capture.recaptureAndValidateUnchanged()
                } catch {
                    throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                        .captureChanged
                }
                return projection(of: current)
            },
            afterDirectoryCreated: {},
            afterExclusivePublication: { _ in })
    }

    static func publishForTesting(
        initialProjection:
            PrimeLatinProposalValidationCompositionReceiptProjectionV1,
        artifactRoot: PrimeArtifactRoot,
        recaptureProjection: () throws
            -> PrimeLatinProposalValidationCompositionReceiptProjectionV1,
        afterDirectoryCreated: () throws -> Void = {},
        afterExclusivePublication:
            (PrimeArtifactBinding) throws -> Void = { _ in }
    ) throws
        -> PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1
    {
        try publishUsingSingleEngine(
            initialProjection: initialProjection,
            artifactRoot: artifactRoot,
            recaptureProjection: recaptureProjection,
            afterDirectoryCreated: afterDirectoryCreated,
            afterExclusivePublication: afterExclusivePublication)
    }

    private static func publishUsingSingleEngine(
        initialProjection:
            PrimeLatinProposalValidationCompositionReceiptProjectionV1,
        artifactRoot: PrimeArtifactRoot,
        recaptureProjection: () throws
            -> PrimeLatinProposalValidationCompositionReceiptProjectionV1,
        afterDirectoryCreated: () throws -> Void,
        afterExclusivePublication:
            (PrimeArtifactBinding) throws -> Void
    ) throws
        -> PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1
    {
        let receipt: PrimeLatinProposalValidationCompositionReceiptV1
        do {
            receipt = try .init(projecting: initialProjection)
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .invalidSourceObservation("initial_receipt_projection")
        }

        do {
            try artifactRoot.requirePrivateRootMode()
            try artifactRoot.requireEmpty()
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .publicationFailed
        }

        let currentProjection:
            PrimeLatinProposalValidationCompositionReceiptProjectionV1
        do {
            currentProjection = try recaptureProjection()
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .captureChanged
        }
        guard currentProjection == initialProjection else {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .captureChanged
        }

        let canonicalData: Data
        let receiptSHA256: String
        let receiptPath: String
        do {
            try receipt.validateExactV1()
            canonicalData = try PrimeCanonicalJSON.encode(receipt)
            guard UInt64(canonicalData.count)
                    <= PrimeLatinProposalValidationCompositionReceiptV1
                        .maximumByteCount else {
                throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                    .receiptTooLarge
            }
            receiptSHA256 = PrimeSHA256.hexDigest(of: canonicalData)
            receiptPath = try
                PrimeLatinProposalValidationCompositionReceiptContractV1
                    .relativePath(forSHA256: receiptSHA256)
        } catch let error as
            PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
        {
            throw error
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .invalidSourceObservation("canonical_receipt_encoding")
        }

        do {
            try artifactRoot.requirePrivateRootMode()
            try artifactRoot.requireEmpty()
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .publicationFailed
        }

        let published: PrimeArtifactBinding
        do {
            try artifactRoot.ensurePrivateDirectory(
                at:
                    PrimeLatinProposalValidationCompositionReceiptContractV1
                        .receiptDirectory)
            try artifactRoot.requireAbsent(at: receiptPath)
            try afterDirectoryCreated()
            published = try artifactRoot.publishCanonicalExclusively(
                receipt,
                at: receiptPath)
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .publicationFailed
        }

        do {
            try afterExclusivePublication(published)
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .verificationFailed
        }

        let rebound: PrimeArtifactBinding
        let verified: PrimeVerifiedArtifact
        let persisted: PrimeLatinProposalValidationCompositionReceiptV1
        do {
            rebound = try artifactRoot.bindExisting(
                at: receiptPath,
                purpose: .immutableData,
                maximumByteCount:
                    PrimeLatinProposalValidationCompositionReceiptV1
                        .maximumByteCount)
            verified = try artifactRoot.verify(rebound)
            persisted = try artifactRoot.decodeVerified(
                PrimeLatinProposalValidationCompositionReceiptV1.self,
                binding: rebound,
                maximumByteCount:
                    PrimeLatinProposalValidationCompositionReceiptV1
                        .maximumByteCount)
            try persisted.validateExactV1()
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .verificationFailed
        }

        let persistedData: Data
        do {
            persistedData = try PrimeCanonicalJSON.encode(persisted)
        } catch {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .verificationFailed
        }
        guard published == rebound,
              published.relativePath == receiptPath,
              published.sha256 == receiptSHA256,
              published.byteCount == UInt64(canonicalData.count),
              published.purpose == .immutableData,
              verified.binding == published,
              verified.actualMode == 0o444,
              persisted == receipt,
              persisted.projection == currentProjection,
              persistedData == canonicalData else {
            throw PrimeLatinProposalValidationCompositionReceiptPublisherErrorV1
                .verificationFailed
        }

        // PrimeArtifactRoot seals and synchronizes the receipt inode, then
        // exclusively renames and synchronizes the held receipt directory.
        // Only the verified success path may expose those durability claims.
        return
            PrimeLatinProposalValidationCompositionReceiptPublicationObservationV1(
                receipt: receipt,
                artifactBinding: published,
                verifiedArtifact: verified)
    }

    private static func projection(
        of observation:
            PrimeLatinProposalValidationCompositionObservationV1
    ) -> PrimeLatinProposalValidationCompositionReceiptProjectionV1 {
        let authority = observation.authority
        return PrimeLatinProposalValidationCompositionReceiptProjectionV1(
            schema:
                PrimeLatinProposalValidationCompositionReceiptContractV1
                    .schema,
            outcome:
                PrimeLatinProposalValidationCompositionReceiptContractV1
                    .outcome,
            verificationScope:
                PrimeLatinProposalValidationCompositionReceiptContractV1
                    .verificationScope,
            receiptPolicyID:
                PrimeLatinProposalValidationCompositionReceiptContractV1
                    .receiptPolicyID,
            sourceObservationSchema: observation.schema,
            sourceObservationOutcome: observation.outcome,
            sourceObservationVerificationScope:
                observation.verificationScope,
            sourceCompositionPolicyID: observation.compositionPolicyID,
            sourceAuthorityDisposition: authority.disposition,
            sourceAuthorityTrueClaims: trueClaims(from: authority),
            sourceAuthorityFalseClaims: falseClaims(from: authority),
            pairReceiptSHA256: observation.pairReceiptSHA256,
            pairReceiptByteCount: observation.pairReceiptByteCount,
            producerRepository: observation.producerRepository,
            producerCommit: observation.producerCommit,
            producerTree: observation.producerTree,
            candidateCatalogSHA256: observation.candidateCatalogSHA256,
            candidateCatalogByteCount: observation.candidateCatalogByteCount,
            experimentManifestSHA256:
                observation.experimentManifestSHA256,
            experimentManifestByteCount:
                observation.experimentManifestByteCount,
            candidateDeclarationSetSHA256:
                observation.candidateDeclarationSetSHA256,
            candidateDeclarationSetByteCount:
                observation.candidateDeclarationSetByteCount,
            tokenizerBundleSHA256: observation.tokenizerBundleSHA256,
            tokenizerBundleByteCount: observation.tokenizerBundleByteCount,
            candidateIDs: observation.candidateIDs,
            candidateIdentitySHA256s:
                observation.candidateIdentitySHA256s,
            declarationBundleSHA256s:
                observation.declarationBundleSHA256s,
            inputBindingCount: observation.inputBindingCount,
            retainedOriginalInputByteCount:
                observation.retainedOriginalInputByteCount,
            optimizerSteps: observation.optimizerSteps,
            trainingTokens: observation.trainingTokens,
            wallClockSeconds: observation.wallClockSeconds,
            outputNamespace: observation.outputNamespace,
            orderedTensorCount: observation.orderedTensorCount,
            uniqueParameterStorageCount:
                observation.uniqueParameterStorageCount,
            totalParameterCount: observation.totalParameterCount)
    }

    private static func trueClaims(
        from authority:
            PrimeLatinProposalValidationCompositionAuthorityBoundaryV1
    ) -> [String] {
        var claims = [String]()
        append(
            "producerRevalidationCaptureAndRecaptureComplete",
            when: authority
                .producerRevalidationCaptureAndRecaptureComplete,
            to: &claims)
        append(
            "independentReplayCaptureAndRecaptureComplete",
            when: authority
                .independentReplayCaptureAndRecaptureComplete,
            to: &claims)
        append(
            "cooperativeSameRequestRootSequenceComplete",
            when: authority.cooperativeSameRequestRootSequenceComplete,
            to: &claims)
        append(
            "producerRevalidationAuthorityBoundaryExact",
            when: authority.producerRevalidationAuthorityBoundaryExact,
            to: &claims)
        append(
            "independentReplayAuthorityBoundaryExact",
            when: authority.independentReplayAuthorityBoundaryExact,
            to: &claims)
        append(
            "exactPairReceiptCrossBindingMatched",
            when: authority.exactPairReceiptCrossBindingMatched,
            to: &claims)
        append(
            "exactProducerSourceCrossBindingMatched",
            when: authority.exactProducerSourceCrossBindingMatched,
            to: &claims)
        append(
            "exactCandidateCatalogCrossBindingMatched",
            when: authority.exactCandidateCatalogCrossBindingMatched,
            to: &claims)
        append(
            "exactExperimentManifestCrossBindingMatched",
            when: authority.exactExperimentManifestCrossBindingMatched,
            to: &claims)
        append(
            "exactCandidateDeclarationSetCrossBindingMatched",
            when: authority
                .exactCandidateDeclarationSetCrossBindingMatched,
            to: &claims)
        append(
            "exactTokenizerBundleCrossBindingMatched",
            when: authority.exactTokenizerBundleCrossBindingMatched,
            to: &claims)
        append(
            "exactCandidateIdentityInventoryCrossBindingMatched",
            when: authority
                .exactCandidateIdentityInventoryCrossBindingMatched,
            to: &claims)
        append(
            "exactTwentyOneInputBindingCountCrossBindingMatched",
            when: authority
                .exactTwentyOneInputBindingCountCrossBindingMatched,
            to: &claims)
        append(
            "exactTwentyOneOriginalInputBytesRetained",
            when: authority.exactTwentyOneOriginalInputBytesRetained,
            to: &claims)
        append(
            "exactTrialBudgetCrossBindingMatched",
            when: authority.exactTrialBudgetCrossBindingMatched,
            to: &claims)
        append(
            "exactOutputNamespaceCrossBindingMatched",
            when: authority.exactOutputNamespaceCrossBindingMatched,
            to: &claims)
        append(
            "outputNamespaceAbsenceVerified",
            when: authority.outputNamespaceAbsenceVerified,
            to: &claims)
        append(
            "referencedInputSnapshotAvailable",
            when: authority.referencedInputSnapshotAvailable,
            to: &claims)
        append(
            "referencedArtifactBytesAvailable",
            when: authority.referencedArtifactBytesAvailable,
            to: &claims)
        append(
            "llmGitStateIndependentlyObserved",
            when: authority.llmGitStateIndependentlyObserved,
            to: &claims)
        append(
            "revalidatorToolSourceIndependentlyObserved",
            when: authority.revalidatorToolSourceIndependentlyObserved,
            to: &claims)
        append(
            "liveProducerWorkspaceRevalidationComplete",
            when: authority.liveProducerWorkspaceRevalidationComplete,
            to: &claims)
        append(
            "independentPrimeReplayComplete",
            when: authority.independentPrimeReplayComplete,
            to: &claims)
        append(
            "validationCompositionComplete",
            when: authority.validationCompositionComplete,
            to: &claims)
        return claims
    }

    private static func falseClaims(
        from authority:
            PrimeLatinProposalValidationCompositionAuthorityBoundaryV1
    ) -> [String] {
        var claims = [String]()
        append(
            "atomicCrossProcessSnapshotEstablished",
            when: !authority.atomicCrossProcessSnapshotEstablished,
            to: &claims)
        append(
            "compilerCryptographicallyAuthenticated",
            when: !authority.compilerCryptographicallyAuthenticated,
            to: &claims)
        append(
            "externalSourceToBinaryAttestationAvailable",
            when: !authority.externalSourceToBinaryAttestationAvailable,
            to: &claims)
        append(
            "originRemoteCryptographicallyAuthenticated",
            when: !authority.originRemoteCryptographicallyAuthenticated,
            to: &claims)
        append(
            "ignoredWorkspaceBytesObserved",
            when: !authority.ignoredWorkspaceBytesObserved,
            to: &claims)
        append(
            "declarationSourceSemanticsIndependentlyVerified",
            when:
                !authority.declarationSourceSemanticsIndependentlyVerified,
            to: &claims)
        append(
            "tokenizerModelSemanticsIndependentlyValidated",
            when: !authority.tokenizerModelSemanticsIndependentlyValidated,
            to: &claims)
        append(
            "tokenizerTrainingReplayComplete",
            when: !authority.tokenizerTrainingReplayComplete,
            to: &claims)
        append(
            "evaluationExecutionComplete",
            when: !authority.evaluationExecutionComplete,
            to: &claims)
        append(
            "selectionObservationComplete",
            when: !authority.selectionObservationComplete,
            to: &claims)
        append(
            "durableInputSnapshotPublished",
            when: !authority.durableInputSnapshotPublished,
            to: &claims)
        append(
            "durableGitObservationPublished",
            when: !authority.durableGitObservationPublished,
            to: &claims)
        append(
            "durableProducerRevalidationObservationPublished",
            when:
                !authority.durableProducerRevalidationObservationPublished,
            to: &claims)
        append(
            "durableIndependentReplayObservationPublished",
            when:
                !authority.durableIndependentReplayObservationPublished,
            to: &claims)
        append(
            "durableValidationCompositionObservationPublished",
            when:
                !authority.durableValidationCompositionObservationPublished,
            to: &claims)
        append(
            "runtimeDecoderImplementationAvailable",
            when: !authority.runtimeDecoderImplementationAvailable,
            to: &claims)
        append(
            "runtimeDependencyClosureEstablished",
            when: !authority.runtimeDependencyClosureEstablished,
            to: &claims)
        append(
            "runtimeInitializationEstablished",
            when: !authority.runtimeInitializationEstablished,
            to: &claims)
        append(
            "primeProposalPolicyEstablished",
            when: !authority.primeProposalPolicyEstablished,
            to: &claims)
        append(
            "primeProposalPacketProduced",
            when: !authority.primeProposalPacketProduced,
            to: &claims)
        append(
            "primeTrialAuthorizationProduced",
            when: !authority.primeTrialAuthorizationProduced,
            to: &claims)
        append(
            "primeDecisionReceiptProduced",
            when: !authority.primeDecisionReceiptProduced,
            to: &claims)
        append(
            "candidateSelectionAuthorized",
            when: !authority.candidateSelectionAuthorized,
            to: &claims)
        append(
            "trialExecutionAuthorized",
            when: !authority.trialExecutionAuthorized,
            to: &claims)
        append(
            "furtherTrainingAuthorized",
            when: !authority.furtherTrainingAuthorized,
            to: &claims)
        append(
            "promotionAuthorized",
            when: !authority.promotionAuthorized,
            to: &claims)
        append(
            "productUseAuthorized",
            when: !authority.productUseAuthorized,
            to: &claims)
        append(
            "publicationAuthorized",
            when: !authority.publicationAuthorized,
            to: &claims)
        append(
            "proposalPairPublicationPerformedByThisComposition",
            when:
                !authority.proposalPairPublicationPerformedByThisComposition,
            to: &claims)
        append(
            "primeDurableReceiptPublished",
            when: !authority.primeDurableReceiptPublished,
            to: &claims)
        return claims
    }

    private static func append(
        _ claim: String,
        when condition: Bool,
        to claims: inout [String]
    ) {
        if condition {
            claims.append(claim)
        }
    }
}
