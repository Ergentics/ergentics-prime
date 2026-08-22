// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndTimingBaseContinuityCeiling()
        throws
    {
        requireSendable(Authority.self)
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())

        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256
        )
        XCTAssertEqual(try Authority.decodeCanonical(canonical), authority)
        try assertNoncanonicalEncodingsReject(canonical)

        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_secure_child_validation_fixture_identity_measurement_v2_timing_repair_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_secure_child_validation_fixture_identity_measurement_v2_timing_repair_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "append_only_dependency_free_nonexecuting_lifecycle_bounded_reviewed_main_operational_margin_and_base_continuity_amendment_authority"
        )
        XCTAssertEqual(
            authority.status,
            "PRECONSUMPTION_V2_TIMING_MARGIN_AMENDMENT_ONLY_exact_main_run174_success_lifecycle_bounded_90_to_120_base_rebind_conditional_no_mechanics_measurement_outcome_or_retry"
        )

        assertV2Files(authority.v2AuthorityExactFiveIdentity)
        XCTAssertEqual(
            authority.v2AuthorityExactFiveExcludedIndexSHA256,
            "4f528c8a72027a1cd46f6bac6ac40c3d8732a82f0de398f3d3bd1668ec0c48c0"
        )
        XCTAssertEqual(
            authority.repairExactFiveExcludedIndexSHA256,
            "a914a9886f2c9396815fe7235c42532bd229185e342c45322bc078b8c8cf9088"
        )

        let repository = authority.repositoryClosure
        XCTAssertEqual(repository.pullRequestNumber, 136)
        XCTAssertEqual(
            repository.baseRevision,
            "8dbbe8987da06b7e6cb9279e65a339595b77ca3b"
        )
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            "16908cbe5386f07cbc63d8744e768e82775bed31"
        )
        XCTAssertEqual(
            repository.mergeRevision,
            "3f69d6e911ca48c39edc55508e93fed64fc48732"
        )
        XCTAssertEqual(
            repository.mergeTree,
            "4c1a528ab5b5f53a26c9278e627c3d57b2d938cc"
        )
        XCTAssertEqual(
            repository.orderedMergeParentRevisions,
            [repository.baseRevision, repository.reviewedHeadRevision]
        )
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.reviewedHeadIsDirectChildOfBase)
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.githubSignatureVerified)
        XCTAssertEqual(repository.githubSignatureReason, "valid")

        assertRun(
            authority.pullRequestRun,
            id: 32_546_060_670,
            number: 173,
            suite: 88_223_758_722,
            event: "pull_request",
            ref: "refs/pull/136/merge",
            head: repository.reviewedHeadRevision
        )
        assertRun(
            authority.exactMainRun,
            id: 32_546_516_122,
            number: 174,
            suite: 88_224_868_710,
            event: "push",
            ref: "refs/heads/main",
            head: repository.mergeRevision
        )
        assertJob(
            authority.pullRequestActiveJob,
            id: 96_964_562_115,
            runner: "macos-15",
            duration: 542
        )
        XCTAssertEqual(authority.pullRequestReviewedJob.conclusion, "skipped")
        XCTAssertEqual(authority.pullRequestReviewedJob.durationSeconds, 0)
        XCTAssertTrue(
            authority.pullRequestReviewedJobConnectorTimestampOrderingAnomalyObserved
        )
        XCTAssertFalse(authority.pullRequestReviewedJobDurationDerivedFromTimestamps)
        assertJob(
            authority.exactMainActiveJob,
            id: 96_965_818_328,
            runner: "macos-15",
            duration: 652
        )
        assertJob(
            authority.exactMainReviewedJob,
            id: 96_967_143_447,
            runner: "macos-26",
            duration: 4_501
        )
        assertLog(
            authority.exactMainActiveLog,
            jobID: authority.exactMainActiveJob.jobID,
            bytes: 401_541,
            lines: 1_934,
            bomOffsets: [0],
            sha256:
                "d1dc2560122658574b903c5a2607af92ec4bd686ab432a36dd10bf335301b99a"
        )
        assertLog(
            authority.exactMainReviewedLog,
            jobID: authority.exactMainReviewedJob.jobID,
            bytes: 10_348_696,
            lines: 79_127,
            bomOffsets: [0, 2_112_505, 4_225_437, 6_338_033, 8_452_544],
            sha256:
                "70e6c5d538857e1da1b77a67ef52697ce5d444be25918de8cb3fa9f43b09724f"
        )

        let tests = authority.exactMainTests
        XCTAssertEqual(tests.activeLatinTestCount, 116)
        XCTAssertEqual(tests.rootTestCount, 90)
        XCTAssertEqual(tests.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(tests.isolatedTestCount, 6)
        XCTAssertEqual(tests.focusedWholeTestCount, 96)
        XCTAssertEqual(tests.retainedLiveTestCount, 46)
        XCTAssertEqual(tests.aggregateTestCount, 142)
        XCTAssertEqual(tests.reviewedFailureCount, 0)
        XCTAssertEqual(tests.reviewedSkipCount, 0)
        XCTAssertEqual(tests.v2AuthorityTestStartCount, 1)
        XCTAssertEqual(tests.v2AuthorityTestPassCount, 1)
        XCTAssertEqual(tests.v2LauncherInvocationCount, 0)
        XCTAssertEqual(tests.v2EvaluatorInvocationCount, 0)
        XCTAssertEqual(tests.v2MeasurementRecordCount, 0)

        let history = authority.historicalTimingReference
        XCTAssertEqual(
            history.sourceAuthorityID,
            "ergentics_prime_exact_revision_topology_relation_timeout_repair_authority_v1"
        )
        XCTAssertEqual(history.evidenceDerivedLowerBoundSeconds, 4_859)
        XCTAssertEqual(history.sourceCanonicalByteCount, 18_515)
        XCTAssertEqual(
            history.sourceCanonicalSHA256,
            "667a8c408635407eecb5cc2fd8381baf1cc1f28fc771ff541c66b3816b97a5f4"
        )
        XCTAssertEqual(history.sourceGitBlob, "ff4d218de7b95a908d75e70037ae3e5f651eaa0c")
        XCTAssertEqual(history.sourceByteCount, 70_984)
        XCTAssertEqual(history.sourceLFByteCount, 1_386)
        XCTAssertEqual(
            history.sourceSHA256,
            "3de1ce8ffd050dd47f1913eaaaf05459e9bf3a6a5b76a81574c8b0ca679943f4"
        )
        XCTAssertFalse(history.historicalCompileAndRuntimeVarianceMeasured)
        XCTAssertFalse(history.historicalArithmeticGuaranteedCompletion)

        let ledger = authority.conservationLedger
        XCTAssertEqual(ledger.configuredReviewedMainTimeoutMinutes, 90)
        XCTAssertEqual(ledger.configuredReviewedMainTimeoutSeconds, 5_400)
        XCTAssertEqual(ledger.proposedReviewedMainTimeoutMinutes, 120)
        XCTAssertEqual(ledger.proposedReviewedMainTimeoutSeconds, 7_200)
        XCTAssertEqual(ledger.timeoutDeltaMinutes, 30)
        XCTAssertEqual(ledger.timeoutDeltaSeconds, 1_800)
        XCTAssertEqual(ledger.run174ReviewedDurationSeconds, 4_501)
        XCTAssertEqual(ledger.run171ReviewedDurationSeconds, 4_046)
        XCTAssertEqual(ledger.run174MinusRun171DriftSeconds, 455)
        XCTAssertEqual(ledger.run174HeadroomBeforeSeconds, 899)
        XCTAssertEqual(ledger.run174HeadroomAfterSeconds, 2_699)
        XCTAssertEqual(ledger.historicalLowerBoundSeconds, 4_859)
        XCTAssertEqual(ledger.historicalHeadroomBeforeSeconds, 541)
        XCTAssertEqual(ledger.historicalHeadroomAfterSeconds, 2_341)
        XCTAssertEqual(ledger.selectedReferenceSeconds, 4_859)
        XCTAssertEqual(
            ledger.selectedReferenceRule,
            "maximum_of_run174_reviewed_duration_and_frozen_historical_complete_composition_lower_bound"
        )
        XCTAssertEqual(ledger.selectedReferenceHeadroomAfterSeconds, 2_341)
        XCTAssertEqual(ledger.repairAuthorityTestNominalCompileExcludedAllocationSeconds, 10)
        XCTAssertFalse(ledger.repairAuthorityTestHostedReviewedMainRuntimeMeasured)
        XCTAssertFalse(ledger.repairAuthorityTestAllocationExternallyEnforced)
        XCTAssertEqual(ledger.run174PlusNominalRepairTestAllocationSeconds, 4_511)
        XCTAssertEqual(ledger.headroomAfterNominalRepairTestAllocationAt90Seconds, 889)
        XCTAssertEqual(ledger.headroomAfterNominalRepairTestAllocationAt120Seconds, 2_689)
        XCTAssertEqual(ledger.selectedReferencePlusNominalRepairTestAllocationSeconds, 4_869)
        XCTAssertEqual(ledger.selectedReferenceAndAllocationHeadroomAt90Seconds, 531)
        XCTAssertEqual(ledger.selectedReferenceAndAllocationHeadroomAt120Seconds, 2_331)
        XCTAssertEqual(
            Authority.checkedSum([
                ledger.selectedReferenceSeconds,
                ledger.repairAuthorityTestNominalCompileExcludedAllocationSeconds,
                ledger.selectedReferenceAndAllocationHeadroomAt120Seconds,
            ]),
            ledger.proposedReviewedMainTimeoutSeconds
        )
        XCTAssertEqual(ledger.futureIndependentReleaseBuildCount, 2)
        XCTAssertEqual(ledger.futureEvaluatorCompileCount, 1)
        XCTAssertEqual(ledger.futureEvaluatorExecutionCount, 1)
        XCTAssertFalse(ledger.futureMeasurementDurationMeasured)
        XCTAssertFalse(ledger.futureMeasurementFitsConfiguredTimeoutEstablished)
        XCTAssertFalse(ledger.futureMeasurementFitsProposedTimeoutGuaranteed)
        XCTAssertTrue(ledger.timeoutIsCeilingNotRuntimeTarget)
        XCTAssertFalse(ledger.demonstrated90MinuteInsufficiencyEstablished)
        XCTAssertFalse(ledger.minimumNecessaryTimeoutEstablished)
        XCTAssertTrue(ledger.boundedOperationalMarginAuthorized)
        XCTAssertFalse(ledger.arithmeticGuaranteesMeasurementCompletion)
        XCTAssertFalse(ledger.mechanicsRuntimeMeasured)
        XCTAssertFalse(ledger.permanentBaselineIncreaseAuthorized)
        XCTAssertEqual(ledger.observationMustRestoreReviewedMainTimeoutMinutes, 90)
        XCTAssertEqual(
            ledger.conservationEquationID,
            "proposed_timeout_seconds_equals_selected_reference_seconds_plus_nominal_repair_test_allocation_seconds_plus_unallocated_headroom_seconds"
        )
        XCTAssertTrue(ledger.arithmeticUsesCheckedIntegerInputsOnly)
        XCTAssertEqual(Authority.checkedMultiply(90, 60), 5_400)
        XCTAssertEqual(Authority.checkedSubtract(7_200, 4_501), 2_699)
        XCTAssertEqual(Authority.checkedAdd(4_501, 10), 4_511)
        XCTAssertEqual(Authority.checkedSum([44, 1, 1]), 46)
        XCTAssertNil(Authority.checkedMultiply(Int.max, 60))
        XCTAssertNil(Authority.checkedAdd(Int.max, 1))
        XCTAssertNil(Authority.checkedSubtract(Int.min, 1))
        XCTAssertNil(Authority.checkedSum([Int.max, 1]))

        let patch = authority.repairPatchContract
        assertExactFive(patch.exactOrderedPaths)
        XCTAssertEqual(patch.workflowTimeoutLiteralBefore, "timeout-minutes: 90")
        XCTAssertEqual(patch.workflowTimeoutLiteralAfter, "timeout-minutes: 120")
        XCTAssertEqual(patch.workflowTimeoutLiteralChangeOccurrenceCount, 1)
        XCTAssertEqual(patch.activeRootTimeoutMinutes, 45)
        XCTAssertEqual(patch.reviewedMainTimeoutBeforeMinutes, 90)
        XCTAssertEqual(patch.reviewedMainTimeoutAfterMinutes, 120)
        XCTAssertEqual(patch.workflowJobCount, 2)
        XCTAssertEqual(patch.activeRootUserStepCount, 5)
        XCTAssertEqual(patch.reviewedMainUserStepCount, 5)
        XCTAssertTrue(patch.workflowJobAndStepOrderMustRemainUnchanged)
        XCTAssertTrue(patch.fetchInvocationCountAndDepthMustRemainUnchanged)
        XCTAssertEqual(patch.existingFetchDepth, 2)
        XCTAssertTrue(patch.fetchCheckoutTargetsMustRemainUnchanged)
        XCTAssertTrue(patch.fetchCredentialHandlingMustRemainUnchanged)
        XCTAssertTrue(patch.existingFetchWantOrderMustRemainUnchanged)
        XCTAssertEqual(
            patch.existingOrderedImmutableWantRevisions,
            [
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
                "444cd402c966521f6163f4949b4a73f9a5184e29",
                "1bc2471d12f034d51ae6eb8c977198635bc37717",
                "3c40cce6350da7ed0ce0f5ccb0620f76feff0501",
                "3d2148227d264502010e64a0c0db70bc1362c50c",
                "6a811d3029bdb77e038750694fbf10eec0f358f8",
                "5623872afda1895630ba0eacdfab76961c5e755b",
                "57f4264dd865a47766e27a9dbc06a82dd1fbfe11",
                "f5db7101cf3538daae103ba56601a509ad8bad80",
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
                "75b14056b75e8af6af0c070453f7ef14ac10a063",
                "3ad8087ed6e403ba81f46bba97ceb5d440979e0a",
                "ef64686e76d2d67e46deb696bfeef18ea96c96a2",
                "e1d90e3f2ae6c4d3c279bf5fb64ce3baafc1f540",
                "0abcb4ad5487a775627bbb587184c375dd691978",
                "4570716892722873757de6eae1bd897167d674eb",
                "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
                "b3402efd96d3ff893a0c2b73897cf48c9b313c8c",
                "232a17e8f58a297919366d963ee1d7bc38cdbaee",
                "a4d8583fa7c59f885002ee06a07c1d5264c0c223",
            ]
        )
        XCTAssertEqual(
            patch.immutableWantPrefixBeforeAdditions,
            [
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
                "444cd402c966521f6163f4949b4a73f9a5184e29",
                "1bc2471d12f034d51ae6eb8c977198635bc37717",
            ]
        )
        XCTAssertEqual(
            patch.addedImmutableFetchWantRevisions,
            [
                repository.mergeRevision,
                repository.reviewedHeadRevision,
                repository.baseRevision,
            ]
        )
        XCTAssertEqual(patch.addedImmutableFetchWantCountPerExistingFetch, 3)
        XCTAssertEqual(patch.existingFetchInvocationCount, 2)
        XCTAssertEqual(patch.totalAddedImmutableFetchWantOccurrenceCount, 6)
        XCTAssertTrue(patch.addedWantsRequireRawObjectVerification)
        XCTAssertTrue(patch.rawObjectVerificationPerformsNoAncestryTraversal)
        XCTAssertTrue(patch.rawSignaturePresenceDoesNotReverifyGitHubSignature)
        XCTAssertEqual(patch.additionalFetchInvocationCount, 0)
        XCTAssertTrue(patch.retainedLiveCommandSequenceMustRemainByteIdentical)
        XCTAssertTrue(patch.v2AuthorityPairMustRemainByteIdentical)
        XCTAssertTrue(patch.topologyHelperClassifierAndMatrixMustRemainByteIdentical)
        XCTAssertTrue(patch.retiredV1FilesMustRemainByteIdentical)
        XCTAssertTrue(patch.fixtureInputsMustRemainByteIdentical)
        XCTAssertTrue(patch.packageManifestMustRemainByteIdentical)
        XCTAssertTrue(patch.packageLockMustRemainByteIdentical)
        XCTAssertEqual(patch.v2MechanicsPathCountAddedNow, 0)
        XCTAssertEqual(patch.v2MechanicsInvocationCountNow, 0)
        XCTAssertEqual(patch.actionsArtifactCount, 0)
        XCTAssertEqual(patch.newDependencyNetworkInvocationCount, 0)
        XCTAssertEqual(patch.topologyHelperInvocationCountPerGate, 1)
        XCTAssertEqual(
            patch.pullRequestTopologyExplicitRequestRoles,
            [
                "current_exact_revision",
                "verified_v2_authority_base",
                "verified_implementation_base",
            ]
        )
        XCTAssertEqual(
            patch.pushMainTopologyExplicitRequestRoles,
            [
                "verified_v2_authority_base",
                "verified_implementation_base",
            ]
        )
        XCTAssertEqual(patch.topologyRelationFixedParent1Revision, repository.mergeRevision)
        XCTAssertTrue(patch.topologyRequestsPerformNoAncestryTraversal)

        let continuity = authority.baseContinuityAmendment
        XCTAssertTrue(continuity.predecessorRequiresMechanicsDirectChildOfAuthorityMerge)
        XCTAssertTrue(continuity.predecessorForbidsInterveningMainCommit)
        XCTAssertEqual(continuity.predecessorAuthorityMergeRevision, repository.mergeRevision)
        XCTAssertEqual(continuity.narrowlySupersededRuleCount, 1)
        XCTAssertTrue(continuity.timingRepairIsOnlyAuthorizedInterveningPatch)
        XCTAssertTrue(continuity.predecessorV2AuthorityPairRemainsByteIdentical)
        XCTAssertTrue(
            continuity.allOtherV2MeasurementSemanticAndSecurityContractsRemainUnchanged
        )
        XCTAssertTrue(continuity.exact32CodeOutcomeTaxonomyRemainsUnchanged)
        XCTAssertEqual(continuity.oneShotOpportunityCountBefore, 1)
        XCTAssertEqual(continuity.oneShotOpportunityConsumedByRepair, 0)
        XCTAssertEqual(continuity.oneShotOpportunityCountAfter, 1)
        XCTAssertEqual(continuity.authorizedMechanicsAttemptCountBefore, 1)
        XCTAssertEqual(continuity.mechanicsAttemptsCreatedByRepair, 0)
        XCTAssertEqual(continuity.authorizedMechanicsAttemptCountAfter, 1)
        XCTAssertFalse(continuity.timingRepairCreatesAdditionalOpportunity)
        XCTAssertNil(continuity.timingRepairMergeRevision)
        XCTAssertNil(continuity.timingRepairReviewedHeadRevision)
        XCTAssertNil(continuity.timingRepairMergeTree)
        XCTAssertNil(continuity.timingRepairClosureRunID)
        XCTAssertEqual(continuity.requiredRepairMergeParent1Revision, repository.mergeRevision)
        XCTAssertEqual(continuity.requiredRepairMergeOrderedParentCount, 2)
        XCTAssertTrue(continuity.requiredTimingRepairReviewedHeadDirectChildOfParent1)
        XCTAssertTrue(continuity.requiredTimingRepairReviewedHeadTreeEqualsMergeTree)
        XCTAssertTrue(continuity.requiredRepairMergeTreeEqualsTimingRepairReviewedHeadTree)
        XCTAssertTrue(continuity.requiredRepairMergeParent2EqualsTimingRepairReviewedHead)
        XCTAssertTrue(continuity.requiredRepairMergeSignatureVerified)
        XCTAssertEqual(continuity.requiredRepairMergeSignatureReason, "valid")
        XCTAssertEqual(continuity.requiredClosureEvent, "push")
        XCTAssertEqual(continuity.requiredClosureRef, "refs/heads/main")
        XCTAssertEqual(continuity.requiredClosureRunAttempt, 1)
        XCTAssertEqual(continuity.requiredClosureMatchingRunCount, 1)
        XCTAssertTrue(continuity.requiredClosurePreviousAttemptURLMustBeNil)
        XCTAssertEqual(continuity.requiredClosureRetryCount, 0)
        XCTAssertEqual(continuity.requiredClosureRerunCount, 0)
        XCTAssertEqual(continuity.requiredClosureActionsArtifactCount, 0)
        XCTAssertEqual(continuity.requiredClosureConclusion, "success")
        XCTAssertTrue(continuity.requiredClosureRunHeadSHAEqualsObservedRepairMerge)
        XCTAssertTrue(continuity.pullRequestGreenIsInsufficient)
        XCTAssertFalse(continuity.currentV2MechanicsAuthorized)
        XCTAssertTrue(continuity.conditionalPostClosureMechanicsRebuildAuthorized)
        XCTAssertEqual(
            continuity.conditionalAuthorizationPredicate,
            "unique_attempt1_direct_push_main_run_for_observed_timing_repair_merge_is_successful"
        )
        XCTAssertEqual(
            continuity.rebuiltMechanicsFixedParent1Source,
            "future_observed_timing_repair_merge_revision_after_unique_attempt1_direct_push_main_success"
        )
        XCTAssertTrue(continuity.requiredFutureMechanicsHeadDirectChildOfObservedRepairMerge)
        XCTAssertTrue(continuity.requiredFutureMechanicsMergeParent1EqualsObservedRepairMerge)
        XCTAssertTrue(continuity.requiredFutureMechanicsMergeParent2EqualsMechanicsHead)
        XCTAssertTrue(continuity.requiredFutureMechanicsMergeTreeEqualsMechanicsHeadTree)
        XCTAssertFalse(continuity.staleMechanicsBasedOnPredecessorMergeMayMerge)
        XCTAssertTrue(continuity.separateMechanicsReviewAndTestingRequired)
        XCTAssertFalse(continuity.separatePostClosureAuthorityPairRequired)

        let restoration = authority.timeoutRestorationPolicy
        XCTAssertEqual(
            restoration.elevatedTimeoutLifecycleID,
            "reviewed_main_120_from_repair_merge_until_mechanics_observation_or_restore_only_abort"
        )
        XCTAssertEqual(restoration.targetReviewedMainTimeoutMinutes, 90)
        XCTAssertEqual(
            restoration.exactTerminalTriggerIDsInOrder,
            [
                "repair_closure_cannot_establish_unique_attempt1_direct_push_main_success",
                "main_intervenes_after_valid_closure_before_mechanics",
                "mechanics_is_abandoned_or_requires_broader_surface",
                "mechanics_reaches_any_terminal_outcome",
            ]
        )
        XCTAssertEqual(restoration.exactTerminalTriggerCount, 4)
        XCTAssertTrue(restoration.repairClosureDisqualificationCovered)
        XCTAssertTrue(restoration.interveningMainBeforeMechanicsCovered)
        XCTAssertTrue(restoration.mechanicsAbandonmentOrBroaderSurfaceCovered)
        XCTAssertTrue(restoration.everyMechanicsOutcomeCovered)
        XCTAssertTrue(
            restoration.validClosurePermitsOnlyMechanicsOrRestoreOnlyAsNextRoadmapMutation
        )
        XCTAssertTrue(restoration.restoreOnlyTransitionMustBeNextRoadmapMutation)
        XCTAssertEqual(
            restoration.restorationTransitionRole,
            "append_only_exact5_restore_only_observation_or_abandonment_transition"
        )
        XCTAssertTrue(restoration.restorationTransitionRequiresSeparateReviewAndTesting)
        XCTAssertFalse(restoration.restorationTransitionConsumesMeasurementOpportunity)
        XCTAssertFalse(restoration.restorationTransitionConsumesMechanicsAttempt)
        XCTAssertFalse(restoration.restorationTransitionCreatesMeasurementOpportunity)
        XCTAssertFalse(restoration.restorationTransitionAuthorizesMechanics)
        XCTAssertFalse(restoration.failedRepairClosureAuthorizesMechanics)
        XCTAssertFalse(restoration.wallClockRestorationDeadlineEstablished)
        XCTAssertFalse(restoration.indefiniteElevatedBaselineAuthorized)

        let preserved = authority.preservedV2Semantics
        XCTAssertEqual(preserved.predecessorAuthorityCanonicalByteCount, 41_626)
        XCTAssertEqual(
            preserved.predecessorAuthorityCanonicalSHA256,
            "d32cc3d90e5476e6f279d24bcb392f570358836c702429ecebf27dc1458077c4"
        )
        XCTAssertEqual(
            preserved.predecessorAuthoritySourceGitBlob,
            "44dac55cb6620f9f667cf564efb137102e1546c8"
        )
        XCTAssertEqual(
            preserved.predecessorAuthorityTestGitBlob,
            "a7f5624d2147f4852b2b0422a90c14776689b4b2"
        )
        XCTAssertEqual(preserved.fixtureInputCount, 5)
        XCTAssertEqual(
            preserved.fixtureInputSHA256InOrdinalOrder,
            [
                "99354cfc3da2d75ac960d1c704257656eec563bc17344d694678626ae9c1f518",
                "d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a",
                "b8476f18b4ee05b10e208cc37667d3c69e117bd5eda0162e77804570c5713a6b",
                "f016793fb012c9dc70a47b5ea0ba325f582d1e7c0c5a84b303855cc8543eb274",
                "1ed890d017b67c97a0d980d58cb7614bb71362091c02b03d26a26222b24d5fcd",
            ]
        )
        XCTAssertEqual(preserved.currentAcceptancePinByteCount, 89_632)
        XCTAssertEqual(
            preserved.currentAcceptancePinSHA256,
            "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd"
        )
        XCTAssertEqual(preserved.phaseTransitionCount, 5)
        XCTAssertEqual(
            preserved.phaseTransitionKeysInOrdinalOrder,
            [
                "DIFFERENT:nil:terminal",
                "UNAVAILABLE:nil:terminal",
                "FAILURE:nil:terminal",
                "IDENTICAL:MATCH:separate_no_mutation_confirmation_authority",
                "IDENTICAL:DIFFERENT:separate_exact_pin_repair_authority",
            ]
        )
        XCTAssertEqual(preserved.exactLowLevelResultCodeCount, 32)
        XCTAssertTrue(preserved.preservationIsSemanticAndByteIdentityOnly)
        XCTAssertTrue(preserved.preservationPerformsNoExecution)

        let opportunity = authority.opportunityPreservation
        XCTAssertEqual(opportunity.exactLowLevelResultCodeCount, 32)
        XCTAssertEqual(
            [
                "IDENTICAL": opportunity.identicalResultCodeCount,
                "DIFFERENT": opportunity.differentResultCodeCount,
                "UNAVAILABLE": opportunity.unavailableResultCodeCount,
                "FAILURE": opportunity.failureResultCodeCount,
            ],
            ["IDENTICAL": 2, "DIFFERENT": 1, "UNAVAILABLE": 23, "FAILURE": 6]
        )
        XCTAssertFalse(opportunity.preBuildTopologyFailureConsumesAttempt)
        XCTAssertTrue(opportunity.falseAttemptConsumptionStillRetiresOpportunity)
        XCTAssertTrue(opportunity.everyOutcomeRequiresAppendOnlyObservationAndRetirement)
        XCTAssertTrue(opportunity.absentRecordCauseRequiresPositiveEvidence)
        XCTAssertFalse(opportunity.absentRecordCauseMayBeInferredOrInvented)
        XCTAssertFalse(opportunity.timeoutOrAbsentRecordAuthorizesRetry)
        XCTAssertFalse(opportunity.retryAuthorized)
        XCTAssertFalse(opportunity.rerunAuthorized)
        XCTAssertFalse(opportunity.replacementAuthorized)

        let counts = authority.expectedClosureCounts
        XCTAssertEqual(counts.activeLatinTestCount, 116)
        XCTAssertEqual(counts.predecessorRootTestCount, 90)
        XCTAssertEqual(counts.repairRootTestCount, 91)
        XCTAssertEqual(counts.isolatedTestCount, 6)
        XCTAssertEqual(counts.repairFocusedWholeTestCount, 97)
        XCTAssertEqual(counts.retainedLiveTestCount, 46)
        XCTAssertEqual(counts.repairAggregateTestCount, 143)
        XCTAssertEqual(counts.predecessorEmbeddedProvenanceRecordCount, 532)
        XCTAssertEqual(counts.repairEmbeddedProvenanceRecordCount, 534)
        XCTAssertEqual(counts.repairNewEmbeddedSourceRecordCount, 2)
        XCTAssertEqual(counts.futureMechanicsRootTestCount, 91)
        XCTAssertEqual(counts.futureMechanicsFocusedWholeTestCount, 97)
        XCTAssertEqual(counts.futureMechanicsAggregateTestCount, 143)
        XCTAssertEqual(counts.futureMechanicsEmbeddedProvenanceRecordCount, 536)
        XCTAssertEqual(counts.futureMechanicsActiveRootUserStepCount, 5)
        XCTAssertEqual(counts.futureMechanicsReviewedMainUserStepCount, 6)
        XCTAssertEqual(counts.repairAuthorityTestCount, 1)
        XCTAssertEqual(counts.failureCount, 0)
        XCTAssertEqual(counts.skipCount, 0)
        XCTAssertEqual(counts.actionsArtifactCount, 0)
        XCTAssertTrue(counts.expectedNotObserved)
        XCTAssertFalse(counts.successEstablished)

        XCTAssertTrue(authority.authorityCeiling.v2AuthorityExactMainClosureEstablished)
        XCTAssertTrue(authority.authorityCeiling.exactMainRun174EvidenceEstablished)
        XCTAssertTrue(authority.authorityCeiling.boundedTimingAndBaseContinuityRepairAuthorized)
        XCTAssertTrue(authority.authorityCeiling.predecessorV2AuthorityPreserved)
        XCTAssertTrue(authorityFalseClaims(authority.authorityCeiling).allSatisfy { !$0 })
        XCTAssertEqual(
            authority.orderedRequiredSeparateActions,
            [
                "independently_review_and_bind_the_canonical_source_test_and_exact_main_evidence_pins",
                "merge_only_this_pure_exact5_90_to_120_minute_timing_and_base_continuity_repair",
                "observe_one_unique_attempt1_direct_push_main_exact_main_closure",
                "do_not_invoke_build_or_consume_the_v2_measurement_opportunity_in_this_repair",
                "only_after_green_closure_rebuild_the_previously_authorized_exact5_v2_mechanics_with_the_observed_repair_merge_as_fixed_parent1",
                "preserve_the_single_opportunity_exact32_outcome_taxonomy_and_terminal_no_retry_semantics",
                "if_repair_closure_cannot_establish_unique_attempt1_direct_push_main_success_make_the_next_roadmap_mutation_append_only_restore_only_to_90_and_do_not_authorize_mechanics",
                "if_main_intervenes_or_mechanics_is_abandoned_or_requires_broader_surface_make_the_next_roadmap_mutation_append_only_restore_only_to_90",
                "after_the_one_shot_mechanics_immediately_append_outcome_and_retirement_and_restore_reviewed_main_timeout_to_90_minutes",
                "every_restore_only_transition_consumes_neither_the_measurement_opportunity_nor_the_mechanics_attempt_and_authorizes_no_mechanics",
                "no_terminal_path_may_leave_120_as_an_indefinite_reviewed_main_baseline",
            ]
        )

        try assertCorrelatedInvariantMutationsReject(canonical)
        try assertEveryRecursiveMutationRejects(canonical)
    }

    private func assertRun(
        _ run: Authority.WorkflowRun,
        id: Int,
        number: Int,
        suite: Int,
        event: String,
        ref: String,
        head: String
    ) {
        XCTAssertEqual(run.runID, id)
        XCTAssertEqual(run.runNumber, number)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.checkSuiteID, suite)
        XCTAssertEqual(run.event, event)
        XCTAssertEqual(run.ref, ref)
        XCTAssertEqual(run.headSHA, head)
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "success")
        XCTAssertNil(run.previousAttemptURL)
        XCTAssertEqual(run.matchingRunCountForHead, 1)
        XCTAssertEqual(run.retryCount, 0)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertEqual(run.actionsArtifactCount, 0)
    }

    private func assertJob(
        _ job: Authority.Job,
        id: Int,
        runner: String,
        duration: Int
    ) {
        XCTAssertEqual(job.jobID, id)
        XCTAssertEqual(job.runnerLabel, runner)
        XCTAssertEqual(job.status, "completed")
        XCTAssertEqual(job.conclusion, "success")
        XCTAssertEqual(job.durationSeconds, duration)
        XCTAssertEqual(job.userStepCount, 5)
        XCTAssertEqual(job.successfulUserStepCount, 5)
        XCTAssertEqual(job.failedUserStepCount, 0)
        XCTAssertEqual(job.skippedUserStepCount, 0)
    }

    private func assertLog(
        _ log: Authority.ConnectorDecodedLogIdentity,
        jobID: Int,
        bytes: Int,
        lines: Int,
        bomOffsets: [Int],
        sha256: String
    ) {
        XCTAssertEqual(log.jobID, jobID)
        XCTAssertEqual(log.byteCount, bytes)
        XCTAssertEqual(log.lfByteCount, lines)
        XCTAssertEqual(log.crByteCount, 0)
        XCTAssertEqual(log.utf8BOMCount, bomOffsets.count)
        XCTAssertTrue(log.utf8BOMByteOffsetsAreBound)
        XCTAssertEqual(log.utf8BOMByteOffsets, bomOffsets)
        XCTAssertTrue(log.terminalLFPresent)
        XCTAssertEqual(log.sha256, sha256)
        XCTAssertTrue(log.repeatFetchExactlyEqual)
        XCTAssertFalse(log.rawArchiveBytesBound)
        XCTAssertFalse(log.rawArchiveRetained)
    }

    private func assertV2Files(_ files: [Authority.FileIdentity]) {
        XCTAssertEqual(files.count, 5)
        XCTAssertEqual(files.map(\.ordinal), [1, 2, 3, 4, 5])
        XCTAssertEqual(
            files.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementV2Authority.swift",
                "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityTests.swift",
            ]
        )
        XCTAssertEqual(files.map(\.gitMode), ["100755", "100644", "100644", "100644", "100644"])
        XCTAssertEqual(
            files.map(\.gitBlob),
            [
                "11d9fb7b38e162168014831e55ef3016ea4a8869",
                "a18a517bdbb31c0f452ac8d4d13068441500aa02",
                "2e2cb7cfb1ede79e30a97db1a4d8ee675f961703",
                "44dac55cb6620f9f667cf564efb137102e1546c8",
                "a7f5624d2147f4852b2b0422a90c14776689b4b2",
            ]
        )
        XCTAssertEqual(files.map(\.byteCount), [1_623_267, 222_682, 546, 73_439, 52_465])
        XCTAssertEqual(files.map(\.lfByteCount), [25_502, 780, 13, 1_408, 1_178])
        XCTAssertTrue(files.allSatisfy { $0.crByteCount == 0 })
        XCTAssertEqual(
            files.map(\.sha256),
            [
                "4cf008ed967c30f1636772d3fda75c91145f74a80929c16df7833adc5377fc53",
                "ee501dc525924918b7706b1c929696f92e87ec50961d1a82079a1bf1f1f4f915",
                "e8be1c58d823c05997b9ac3aa3196e5970836d985fc20eac8737456253915b9b",
                "0ce03a04ffd3fac1dfd71c91d5a0353747916ed90f7b0c7fb8c14371e28d2438",
                "8a442a5cd17b18ebb7379ceec53384b252be9b980048a392ed5e9d89e9299db2",
            ]
        )
        XCTAssertEqual(
            files.map(\.role),
            [
                "frozen_v2_authority_gate",
                "frozen_v2_authority_workflow",
                "frozen_v2_authority_embedded_provenance",
                "frozen_v2_measurement_authority",
                "frozen_v2_measurement_authority_test",
            ]
        )
    }

    private func assertExactFive(_ paths: [Authority.PathContract]) {
        XCTAssertEqual(paths.count, 5)
        XCTAssertEqual(paths.map(\.ordinal), [1, 2, 3, 4, 5])
        XCTAssertEqual(paths.map(\.gitStatus), ["M", "M", "M", "A", "A"])
        XCTAssertEqual(paths.map(\.gitMode), ["100755", "100644", "100644", "100644", "100644"])
        XCTAssertEqual(
            paths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityTests.swift",
            ]
        )
        XCTAssertEqual(
            paths.map(\.role),
            [
                "bind_run174_timing_evidence_and_base_continuity_repair",
                "raise_only_reviewed_main_timeout_90_to_120_and_integrate_pure_test",
                "bind_534_record_source_identity",
                "pure_timing_and_base_continuity_repair_authority",
                "sole_exhaustive_pure_repair_authority_test",
            ]
        )
    }

    private func authorityFalseClaims(_ ceiling: Authority.AuthorityCeiling) -> [Bool] {
        [
            ceiling.filesystemReadPerformedByAuthorityValue,
            ceiling.filesystemWritePerformedByAuthorityValue,
            ceiling.processExecutionPerformedByAuthorityValue,
            ceiling.gitExecutionPerformedByAuthorityValue,
            ceiling.compilerExecutionPerformedByAuthorityValue,
            ceiling.verifierExecutionPerformedByAuthorityValue,
            ceiling.networkExecutionPerformedByAuthorityValue,
            ceiling.fixtureBuildPerformed,
            ceiling.fixtureExecutionPerformed,
            ceiling.evaluatorExecutionPerformed,
            ceiling.measurementMechanicsPerformed,
            ceiling.measurementObservationEstablished,
            ceiling.measurementOutcomeEstablished,
            ceiling.fixtureIdentityEstablished,
            ceiling.repeatBuildDeterminismEstablished,
            ceiling.pinRelationEstablished,
            ceiling.pinRepairAuthorized,
            ceiling.noMutationConfirmationAuthorized,
            ceiling.realMonitorHeldLeaseCanaryAuthorized,
            ceiling.additionalMeasurementOpportunityAuthorized,
            ceiling.retryOrRerunAuthorized,
            ceiling.modelExecutionAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func assertCorrelatedInvariantMutationsReject(_ canonical: Data) throws {
        let root = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )

        var timeoutPair = root
        var timeoutLedger = try XCTUnwrap(timeoutPair["conservationLedger"] as? [String: Any])
        timeoutLedger["proposedReviewedMainTimeoutMinutes"] = 121
        timeoutLedger["proposedReviewedMainTimeoutSeconds"] = 7_260
        timeoutPair["conservationLedger"] = timeoutLedger
        try assertRelationsReject(timeoutPair, context: "paired timeout mutation")

        var durationPair = root
        var durationLedger = try XCTUnwrap(durationPair["conservationLedger"] as? [String: Any])
        durationLedger["run174ReviewedDurationSeconds"] = 4_502
        durationLedger["run174HeadroomBeforeSeconds"] = 898
        durationLedger["run174HeadroomAfterSeconds"] = 2_698
        durationPair["conservationLedger"] = durationLedger
        try assertRelationsReject(durationPair, context: "duration/headroom conservation mutation")

        var selectedReferencePair = root
        var selectedReferenceLedger = try XCTUnwrap(
            selectedReferencePair["conservationLedger"] as? [String: Any]
        )
        selectedReferenceLedger["selectedReferencePlusNominalRepairTestAllocationSeconds"] = 4_870
        selectedReferenceLedger["selectedReferenceAndAllocationHeadroomAt90Seconds"] = 530
        selectedReferenceLedger["selectedReferenceAndAllocationHeadroomAt120Seconds"] = 2_330
        selectedReferencePair["conservationLedger"] = selectedReferenceLedger
        try assertRelationsReject(
            selectedReferencePair,
            context: "selected reference/allocation conservation mutation"
        )

        var parentSwap = root
        var repository = try XCTUnwrap(parentSwap["repositoryClosure"] as? [String: Any])
        let parents = try XCTUnwrap(repository["orderedMergeParentRevisions"] as? [Any])
        repository["orderedMergeParentRevisions"] = Array(parents.reversed())
        parentSwap["repositoryClosure"] = repository
        try assertRelationsReject(parentSwap, context: "ordered parent swap")

        var countPair = root
        var counts = try XCTUnwrap(countPair["expectedClosureCounts"] as? [String: Any])
        counts["repairRootTestCount"] = 92
        counts["repairFocusedWholeTestCount"] = 98
        counts["repairAggregateTestCount"] = 144
        countPair["expectedClosureCounts"] = counts
        try assertRelationsReject(countPair, context: "correlated count mutation")

        var opportunityPair = root
        var continuity = try XCTUnwrap(opportunityPair["baseContinuityAmendment"] as? [String: Any])
        continuity["oneShotOpportunityCountBefore"] = 2
        continuity["oneShotOpportunityCountAfter"] = 2
        opportunityPair["baseContinuityAmendment"] = continuity
        try assertRelationsReject(opportunityPair, context: "paired opportunity mutation")

        var repairParent2Relation = root
        var repairParent2Continuity = try XCTUnwrap(
            repairParent2Relation["baseContinuityAmendment"] as? [String: Any]
        )
        repairParent2Continuity[
            "requiredRepairMergeParent2EqualsTimingRepairReviewedHead"
        ] = false
        repairParent2Relation["baseContinuityAmendment"] = repairParent2Continuity
        try assertRelationsReject(
            repairParent2Relation,
            context: "repair merge parent2/reviewed-head relation mutation"
        )

        var closureHeadRelation = root
        var closureHeadContinuity = try XCTUnwrap(
            closureHeadRelation["baseContinuityAmendment"] as? [String: Any]
        )
        closureHeadContinuity["requiredClosureRunHeadSHAEqualsObservedRepairMerge"] = false
        closureHeadRelation["baseContinuityAmendment"] = closureHeadContinuity
        try assertRelationsReject(
            closureHeadRelation,
            context: "closure run head/repair merge relation mutation"
        )

        var restorationOrder = root
        var restoration = try XCTUnwrap(
            restorationOrder["timeoutRestorationPolicy"] as? [String: Any]
        )
        let triggers = try XCTUnwrap(restoration["exactTerminalTriggerIDsInOrder"] as? [Any])
        restoration["exactTerminalTriggerIDsInOrder"] = Array(triggers.reversed())
        restorationOrder["timeoutRestorationPolicy"] = restoration
        try assertRelationsReject(restorationOrder, context: "restoration trigger order mutation")
    }

    private enum JSONPathComponent {
        case key(String)
        case index(Int)
    }

    private func assertEveryRecursiveMutationRejects(_ canonical: Data) throws {
        let root = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let valuePaths = allValuePaths(root)
        XCTAssertGreaterThan(valuePaths.count, 150)
        for path in valuePaths {
            let original = try value(at: path, in: root)
            let mutated = try replacingValue(
                in: root,
                at: path,
                with: mutateJSONValue(original)
            )
            try assertCanonicalRejects(mutated, context: "replace \(describe(path))")
        }

        let dictionaryPaths = allValuePathsIncludingRoot(root).filter {
            ((try? value(at: $0, in: root)) as? [String: Any]) != nil
        }
        for path in dictionaryPaths {
            let dictionary = try XCTUnwrap(try value(at: path, in: root) as? [String: Any])
            for key in dictionary.keys.sorted() {
                let removed = try removingValue(in: root, at: path + [.key(key)])
                try assertCanonicalRejects(removed, context: "remove \(describe(path + [.key(key)]))")
            }
        }

        let arrayPaths = allValuePathsIncludingRoot(root).filter {
            ((try? value(at: $0, in: root)) as? [Any]) != nil
        }
        for path in arrayPaths {
            let array = try XCTUnwrap(try value(at: path, in: root) as? [Any])
            for index in array.indices {
                let removed = try removingValue(in: root, at: path + [.index(index)])
                try assertCanonicalRejects(removed, context: "remove \(describe(path + [.index(index)]))")
            }
            if array.count >= 2 {
                var reordered = array
                reordered.swapAt(0, 1)
                let changed = try replacingValue(in: root, at: path, with: reordered)
                try assertCanonicalRejects(changed, context: "reorder \(describe(path))")
            }
        }

        var unknown = root
        unknown["unknownRecursiveMutation"] = true
        try assertCanonicalRejects(unknown, context: "unknown top-level field")
    }

    private func allValuePaths(_ root: Any) -> [[JSONPathComponent]] {
        var paths: [[JSONPathComponent]] = []
        func visit(_ value: Any, _ path: [JSONPathComponent]) {
            if !path.isEmpty { paths.append(path) }
            if let dictionary = value as? [String: Any] {
                for key in dictionary.keys.sorted() {
                    if let child = dictionary[key] {
                        visit(child, path + [.key(key)])
                    }
                }
            } else if let array = value as? [Any] {
                for (index, child) in array.enumerated() {
                    visit(child, path + [.index(index)])
                }
            }
        }
        visit(root, [])
        return paths
    }

    private func allValuePathsIncludingRoot(_ root: Any) -> [[JSONPathComponent]] {
        [[]] + allValuePaths(root)
    }

    private func value(at path: [JSONPathComponent], in root: Any) throws -> Any {
        var current = root
        for component in path {
            switch component {
            case let .key(key):
                current = try XCTUnwrap((current as? [String: Any])?[key])
            case let .index(index):
                current = try XCTUnwrap(current as? [Any])[index]
            }
        }
        return current
    }

    private func replacingValue(
        in root: Any,
        at path: [JSONPathComponent],
        with replacement: Any
    ) throws -> Any {
        guard let first = path.first else { return replacement }
        switch first {
        case let .key(key):
            var dictionary = try XCTUnwrap(root as? [String: Any])
            dictionary[key] = try replacingValue(
                in: try XCTUnwrap(dictionary[key]),
                at: Array(path.dropFirst()),
                with: replacement
            )
            return dictionary
        case let .index(index):
            var array = try XCTUnwrap(root as? [Any])
            array[index] = try replacingValue(
                in: array[index],
                at: Array(path.dropFirst()),
                with: replacement
            )
            return array
        }
    }

    private func removingValue(
        in root: Any,
        at path: [JSONPathComponent]
    ) throws -> Any {
        guard let first = path.first else {
            XCTFail("cannot remove root")
            return root
        }
        if path.count == 1 {
            switch first {
            case let .key(key):
                var dictionary = try XCTUnwrap(root as? [String: Any])
                dictionary.removeValue(forKey: key)
                return dictionary
            case let .index(index):
                var array = try XCTUnwrap(root as? [Any])
                array.remove(at: index)
                return array
            }
        }
        switch first {
        case let .key(key):
            var dictionary = try XCTUnwrap(root as? [String: Any])
            dictionary[key] = try removingValue(
                in: try XCTUnwrap(dictionary[key]),
                at: Array(path.dropFirst())
            )
            return dictionary
        case let .index(index):
            var array = try XCTUnwrap(root as? [Any])
            array[index] = try removingValue(
                in: array[index],
                at: Array(path.dropFirst())
            )
            return array
        }
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if value is NSNull { return "__null_mutation" }
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return number.int64Value == Int64.max
                ? number.int64Value - 1 : number.int64Value + 1
        }
        if var array = value as? [Any] {
            array.append(array.first ?? "__mutation")
            return array
        }
        if var dictionary = value as? [String: Any] {
            dictionary["unknownRecursiveMutation"] = true
            return dictionary
        }
        XCTFail("unsupported JSON value \(type(of: value))")
        return "__unsupported_mutation"
    }

    private func assertCanonicalRejects(_ object: Any, context: String) throws {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(try Authority.decodeCanonical(data), context)
        if let loose = try? JSONDecoder().decode(Authority.self, from: data),
           loose != Authority.frozenV1
        {
            XCTAssertThrowsError(try loose.validate(), context)
        }
    }

    private func assertRelationsReject(_ object: Any, context: String) throws {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        let loose = try JSONDecoder().decode(Authority.self, from: data)
        XCTAssertNotEqual(loose, Authority.frozenV1, context)
        XCTAssertThrowsError(try loose.validateRelationsV1(), context)
    }

    private func assertNoncanonicalEncodingsReject(_ canonical: Data) throws {
        var bom = Data([0xEF, 0xBB, 0xBF])
        bom.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(bom))

        var terminalLF = canonical
        terminalLF.append(0x0A)
        XCTAssertThrowsError(try Authority.decodeCanonical(terminalLF))

        var leadingSpace = Data([0x20])
        leadingSpace.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(leadingSpace))

        let canonicalString = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let escapedSlashString = canonicalString.replacingOccurrences(of: "/", with: "\\/")
        XCTAssertNotEqual(escapedSlashString, canonicalString)
        XCTAssertThrowsError(
            try Authority.decodeCanonical(try XCTUnwrap(escapedSlashString.data(using: .utf8)))
        )

        var oversized = Data(repeating: 0x20, count: 131_073)
        oversized[0] = 0x7B
        XCTAssertThrowsError(try Authority.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityError,
                .oversizedEncoding
            )
        }
    }

    private func describe(_ path: [JSONPathComponent]) -> String {
        if path.isEmpty { return "$" }
        return path.reduce("$") { result, component in
            switch component {
            case let .key(key): return result + "." + key
            case let .index(index): return result + "[\(index)]"
            }
        }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
