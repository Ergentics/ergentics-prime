import XCTest

@testable import PrimeLatinProposalAdmissionPolicy
@testable import PrimeLatinProposalValidationCompositionReceipt

final class PrimeLatinProposalAdmissionPolicyV1Tests: XCTestCase {
    func testExactReceiptProducesTypedFailClosedAbstention() throws {
        let receipt = try PrimeLatinProposalValidationCompositionReceiptV1(
            projecting: .exactFinal)

        let observation = try PrimeLatinProposalAdmissionPolicyV1.evaluate(
            receipt: receipt)

        XCTAssertEqual(
            observation.schema,
            "ergentics_prime_latin_proposal_v3_admission_observation_v1")
        XCTAssertEqual(observation.outcome, .abstain)
        XCTAssertEqual(observation.outcome.rawValue, "ABSTAIN")
        XCTAssertEqual(
            observation.verificationScope,
            "exact_frozen_v3_typed_receipt_projection_only_no_artifact_" +
                "binding_or_current_liveness")
        XCTAssertEqual(
            observation.policyID,
            "prime_latin_v3_exact_typed_receipt_projection_admission_v1")
        XCTAssertEqual(observation.sourceReceipt, receipt)
        XCTAssertEqual(
            observation.orderedReasons,
            [
                .decodedReceiptDoesNotRestoreCurrentLiveValidation,
                .exactCandidateIDClassifiedAsStructuralFixtureByPolicy,
                .runtimeDecoderImplementationNotEstablishedByReceipt,
                .runtimeDependencyClosureNotEstablishedByReceipt,
                .runtimeInitializationNotEstablishedByReceipt,
            ])
        XCTAssertEqual(
            observation.orderedReasons,
            PrimeLatinProposalAdmissionPolicyV1.orderedAbstentionReasons)
        XCTAssertEqual(
            PrimeLatinProposalAdmissionOutcomeV1.allCases,
            [.abstain])
        XCTAssertEqual(
            PrimeLatinProposalAdmissionReasonV1.allCases,
            observation.orderedReasons)
        XCTAssertEqual(observation.orderedReasons.count, 5)
        XCTAssertEqual(Set(observation.orderedReasons).count, 5)
    }

    func testAuthorityBoundaryEstablishesOnlyPolicyAndAbstention() throws {
        let receipt = try PrimeLatinProposalValidationCompositionReceiptV1(
            projecting: .exactFinal)
        let authority = try PrimeLatinProposalAdmissionPolicyV1.evaluate(
            receipt: receipt).authority

        XCTAssertEqual(
            authority.disposition,
            "abstain_exact_typed_validation_composition_receipt_projection_" +
                "admission_evaluated_current_live_validation_not_restored_" +
                "candidate_classified_structural_fixture_runtime_decoder_" +
                "dependency_closure_and_initialization_not_established_by_" +
                "receipt")

        let requiredTrue: [(String, Bool)] = [
            ("exactTypedReceiptProjectionValidated",
             authority.exactTypedReceiptProjectionValidated),
            ("sourceReceiptHistoricalAuthorityClaimsRetained",
             authority.sourceReceiptHistoricalAuthorityClaimsRetained),
            ("exactCandidateIDClassifiedAsStructuralFixtureByPolicy",
             authority
                .exactCandidateIDClassifiedAsStructuralFixtureByPolicy),
            ("primeProposalPolicyEstablished",
             authority.primeProposalPolicyEstablished),
            ("proposalAdmissionEvaluationComplete",
             authority.proposalAdmissionEvaluationComplete),
            ("typedAbstainProduced", authority.typedAbstainProduced),
            ("orderedAbstentionReasonsComplete",
             authority.orderedAbstentionReasonsComplete),
        ]
        XCTAssertEqual(requiredTrue.count, 7)
        for (field, value) in requiredTrue {
            XCTAssertTrue(value, "expected true authority field: \(field)")
        }

        let requiredFalse: [(String, Bool)] = [
            ("atomicCrossProcessSnapshotEstablished",
             authority.atomicCrossProcessSnapshotEstablished),
            ("compilerCryptographicallyAuthenticated",
             authority.compilerCryptographicallyAuthenticated),
            ("externalSourceToBinaryAttestationAvailable",
             authority.externalSourceToBinaryAttestationAvailable),
            ("originRemoteCryptographicallyAuthenticated",
             authority.originRemoteCryptographicallyAuthenticated),
            ("ignoredWorkspaceBytesObserved",
             authority.ignoredWorkspaceBytesObserved),
            ("declarationSourceSemanticsIndependentlyVerified",
             authority.declarationSourceSemanticsIndependentlyVerified),
            ("tokenizerModelSemanticsIndependentlyValidated",
             authority.tokenizerModelSemanticsIndependentlyValidated),
            ("tokenizerTrainingReplayComplete",
             authority.tokenizerTrainingReplayComplete),
            ("evaluationExecutionComplete",
             authority.evaluationExecutionComplete),
            ("selectionObservationComplete",
             authority.selectionObservationComplete),
            ("currentLiveProducerWorkspaceRevalidationRestoredFromReceipt",
             authority
                .currentLiveProducerWorkspaceRevalidationRestoredFromReceipt),
            ("currentIndependentPrimeReplayRestoredFromReceipt",
             authority.currentIndependentPrimeReplayRestoredFromReceipt),
            ("runtimeDecoderImplementationAvailable",
             authority.runtimeDecoderImplementationAvailable),
            ("runtimeDependencyClosureEstablished",
             authority.runtimeDependencyClosureEstablished),
            ("runtimeInitializationEstablished",
             authority.runtimeInitializationEstablished),
            ("receiptArtifactBindingVerified",
             authority.receiptArtifactBindingVerified),
            ("canonicalReceiptBytesVerified",
             authority.canonicalReceiptBytesVerified),
            ("receiptContentAddressVerified",
             authority.receiptContentAddressVerified),
            ("durableInputSnapshotPublished",
             authority.durableInputSnapshotPublished),
            ("durableGitObservationPublished",
             authority.durableGitObservationPublished),
            ("durableProducerRevalidationObservationPublished",
             authority.durableProducerRevalidationObservationPublished),
            ("durableIndependentReplayObservationPublished",
             authority.durableIndependentReplayObservationPublished),
            ("durableValidationCompositionObservationPublished",
             authority.durableValidationCompositionObservationPublished),
            ("rawProducerRevalidationObservationAvailableToPolicy",
             authority.rawProducerRevalidationObservationAvailableToPolicy),
            ("rawIndependentReplayObservationAvailableToPolicy",
             authority.rawIndependentReplayObservationAvailableToPolicy),
            ("durableValidationCompositionReceiptPublished",
             authority.durableValidationCompositionReceiptPublished),
            ("primeDurableReceiptPublished",
             authority.primeDurableReceiptPublished),
            ("proposalAdmissionGranted",
             authority.proposalAdmissionGranted),
            ("primeProposalPacketProduced",
             authority.primeProposalPacketProduced),
            ("primeTrialAuthorizationProduced",
             authority.primeTrialAuthorizationProduced),
            ("primeDecisionReceiptProduced",
             authority.primeDecisionReceiptProduced),
            ("candidateSelectionAuthorized",
             authority.candidateSelectionAuthorized),
            ("trialExecutionAuthorized",
             authority.trialExecutionAuthorized),
            ("furtherTrainingAuthorized",
             authority.furtherTrainingAuthorized),
            ("promotionAuthorized", authority.promotionAuthorized),
            ("productUseAuthorized", authority.productUseAuthorized),
            ("publicationAuthorized", authority.publicationAuthorized),
            ("proposalPairPublicationPerformedByThisPolicy",
             authority.proposalPairPublicationPerformedByThisPolicy),
            ("admissionObservationPublished",
             authority.admissionObservationPublished),
            ("publicNetworkPublicationPerformed",
             authority.publicNetworkPublicationPerformed),
        ]
        XCTAssertEqual(requiredFalse.count, 40)
        for (field, value) in requiredFalse {
            XCTAssertFalse(value, "expected false authority field: \(field)")
        }
    }

    func testMutatedProjectionCannotConstructPolicyInput() throws {
        var projection =
            PrimeLatinProposalValidationCompositionReceiptProjectionV1
                .exactFinal
        projection.candidateIDs = ["invented_runnable_candidate"]

        XCTAssertThrowsError(
            try PrimeLatinProposalValidationCompositionReceiptV1(
                projecting: projection)) { error in
            XCTAssertEqual(
                error as?
                    PrimeLatinProposalValidationCompositionReceiptErrorV1,
                .invalidReceipt("candidate_ids"))
        }
    }
}
