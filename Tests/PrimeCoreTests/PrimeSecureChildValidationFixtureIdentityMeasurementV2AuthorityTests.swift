// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        requireSendable(Authority.self)
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_secure_child_validation_fixture_identity_measurement_v2_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_secure_child_validation_fixture_identity_measurement_v2_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "pure_authority_for_one_later_topology_bound_native_repeat_build_validation_fixture_identity_measurement_v2"
        )
        XCTAssertEqual(
            authority.status,
            "PURE_V2_MEASUREMENT_AUTHORITY_ONLY_exact_main_run171_topology_verified_future_one_shot_measurement_no_current_mechanics_identity_pin_repair_confirmation_or_canary"
        )

        let repository = authority.predecessorRepositoryClosure
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(repository.pullRequestNumber, 135)
        XCTAssertEqual(
            repository.baseRevision,
            "b7808f39815ebf639b183e00d2cd769a29ebad18"
        )
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            "8167f1eafdedf6e9344fde7a6542bd7e07600d8e"
        )
        XCTAssertEqual(
            repository.reviewedHeadOrderedParentRevisions,
            [repository.baseRevision]
        )
        XCTAssertEqual(
            repository.mergeRevision,
            "8dbbe8987da06b7e6cb9279e65a339595b77ca3b"
        )
        XCTAssertEqual(
            repository.mergeTree,
            "354265ca2344246abc33ce1e33ba56f749b16797"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.mergeTree)
        XCTAssertEqual(
            repository.orderedMergeParentRevisions,
            [repository.baseRevision, repository.reviewedHeadRevision]
        )
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.reviewedHeadIsDirectChildOfBase)
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.githubSignatureVerified)
        XCTAssertEqual(repository.githubSignatureReason, "valid")
        XCTAssertEqual(
            repository.githubSignatureVerifiedAt,
            "2026-08-21T23:34:30Z"
        )

        assertRun(
            authority.predecessorPullRequestRun,
            id: 32_536_596_669,
            number: 170,
            suite: 88_200_731_091,
            event: "pull_request",
            ref: "refs/pull/135/merge",
            head: repository.reviewedHeadRevision
        )
        assertJob(
            authority.predecessorPullRequestActiveJob,
            id: 96_938_589_193,
            runner: "macos-15",
            conclusion: "success",
            duration: 532,
            userSteps: 5,
            successfulSteps: 5
        )
        assertJob(
            authority.predecessorPullRequestReviewedJob,
            id: 96_940_077_274,
            runner: "macos-26",
            conclusion: "skipped",
            duration: 0,
            userSteps: 0,
            successfulSteps: 0
        )
        assertLog(
            authority.predecessorPullRequestActiveLog,
            jobID: authority.predecessorPullRequestActiveJob.jobID,
            bytes: 393_783,
            lines: 1_929,
            bomCount: 1,
            sha256:
                "4edb6534f4eb7d34be58017a89d043a3e24036f5ca87cf5306dad104ef9f0cf6"
        )

        assertRun(
            authority.predecessorWorkflowRun,
            id: 32_537_357_695,
            number: 171,
            suite: 88_202_577_325,
            event: "push",
            ref: "refs/heads/main",
            head: repository.mergeRevision
        )
        assertJob(
            authority.predecessorActiveJob,
            id: 96_940_664_684,
            runner: "macos-15",
            conclusion: "success",
            duration: 720,
            userSteps: 5,
            successfulSteps: 5
        )
        assertJob(
            authority.predecessorReviewedJob,
            id: 96_942_618_564,
            runner: "macos-26",
            conclusion: "success",
            duration: 4_046,
            userSteps: 5,
            successfulSteps: 5
        )
        assertLog(
            authority.predecessorActiveLog,
            jobID: authority.predecessorActiveJob.jobID,
            bytes: 393_906,
            lines: 1_929,
            bomCount: 1,
            sha256:
                "671f797da021f6ffc2798d4afc482fa69691e0fd48eb662f6e3b0f483b20bc89"
        )
        assertLog(
            authority.predecessorReviewedLog,
            jobID: authority.predecessorReviewedJob.jobID,
            bytes: 10_346_720,
            lines: 79_116,
            bomCount: 5,
            sha256:
                "412797e5b2420d2af3184bf06df96052db631489472eeba584d03d75387da9a1"
        )

        let tests = authority.predecessorTests
        XCTAssertEqual(tests.activeLatinTestCount, 116)
        XCTAssertEqual(tests.activeLatinPassCount, 116)
        XCTAssertEqual(tests.activeLatinFailureCount, 0)
        XCTAssertEqual(tests.activeLatinSkipCount, 0)
        XCTAssertEqual(tests.rootTestCount, 89)
        XCTAssertEqual(tests.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(tests.isolatedTestCount, 6)
        XCTAssertEqual(tests.rootTestCount + tests.isolatedTestCount, 95)
        XCTAssertEqual(tests.focusedWholeTestCount, 95)
        XCTAssertEqual(tests.retainedMetalTestCount, 44)
        XCTAssertEqual(tests.retainedMaintainedRuntimeTestCount, 1)
        XCTAssertEqual(tests.retainedTokenizerTestCount, 1)
        XCTAssertEqual(tests.retainedLiveTestCount, 46)
        XCTAssertEqual(tests.focusedWholeTestCount + tests.retainedLiveTestCount, 141)
        XCTAssertEqual(tests.aggregateTestCount, 141)
        XCTAssertEqual(tests.aggregateFailureCount, 0)
        XCTAssertEqual(tests.aggregateSkipCount, 0)

        let topology = authority.topologyVerificationClosure
        XCTAssertEqual(topology.implementationMergeRevision, repository.mergeRevision)
        XCTAssertEqual(topology.implementationMergeTree, repository.mergeTree)
        assertFiles(topology.implementationExactFiles, expectedCount: 5)
        XCTAssertEqual(
            topology.implementationExactFiles.map(\.path),
            [
                ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
                ".github/scripts/prime-ci-exact-revision-topology-verifier.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
            ]
        )
        XCTAssertEqual(
            topology.implementationExactFiles.map(\.gitBlob),
            [
                "853f893a057da09e7ce2b0fda873cd944cb45907",
                "3cb6fb84fc6bb38231606a710a772fec5aa5767e",
                "dd660a068c6645957567b97eeff917907e365966",
                "73533fa440b29c5eae6f4ecc5fbde078a747636f",
                "9470bba66c913d6cbb18348c1c50ffac93e1dd2c",
            ]
        )
        XCTAssertEqual(
            topology.helperFunctionName,
            "prime_verify_exact_revision_topology_v1"
        )
        XCTAssertEqual(topology.observedResultCode, "TOPOLOGY_VERIFIED")
        XCTAssertEqual(topology.observedRecordCount, 1)
        XCTAssertEqual(topology.observedHelperReturnStatus, 0)
        XCTAssertTrue(topology.firstFailedGuardIDWasNull)
        XCTAssertTrue(topology.missingObjectRoleWasNull)
        XCTAssertEqual(topology.matrixPredecessorPrivateCaseCount, 8)
        XCTAssertEqual(topology.matrixPredecessorPureCaseCount, 10)
        XCTAssertEqual(topology.matrixClassifierDirectCaseCount, 41)
        XCTAssertEqual(topology.matrixHelperParserCaseCount, 32)
        XCTAssertEqual(topology.matrixStaticSourceCaseCount, 8)
        XCTAssertEqual(topology.matrixRelationBindingCount, 135)
        XCTAssertEqual(
            topology.matrixRelationHelperBindingCount
                + topology.matrixGateBindingCount,
            topology.matrixRelationBindingCount
        )
        XCTAssertEqual(topology.matrixAttemptCount, 143)
        XCTAssertEqual(topology.matrixComponentHarnessCount, 6)
        XCTAssertEqual(topology.matrixPublicHelperCaseCount, 22)
        XCTAssertEqual(topology.matrixRawStreamCaseCount, 5)
        XCTAssertEqual(topology.matrixClosedChildCaseCount, 4)
        XCTAssertEqual(topology.matrixLiveEPIPECaseCount, 1)
        XCTAssertEqual(topology.matrixPostRawMutationCaseCount, 1)
        XCTAssertTrue(topology.matrixPassed)
        XCTAssertTrue(topology.postMatrixGatePassed)

        let retired = authority.retiredV1Closure
        assertFiles(retired.exactFiles, expectedCount: 11)
        XCTAssertEqual(retired.exactFileCount, 11)
        XCTAssertEqual(retired.measurementAuthorityCanonicalByteCount, 66_632)
        XCTAssertEqual(
            retired.measurementAuthorityCanonicalSHA256,
            "67ad7808b54314b7dcd70a86b5504e7321c4c348a0ecb2ec172d5b72ee3f6d43"
        )
        XCTAssertEqual(retired.measurementObservationCanonicalByteCount, 28_633)
        XCTAssertEqual(
            retired.measurementObservationCanonicalSHA256,
            "d7042968a0c78d213c92d73d11d6637f3c03b0f758555376263b9d3aa8ec1a77"
        )
        XCTAssertEqual(retired.measurementRunNumber, 160)
        XCTAssertEqual(retired.measurementRunAttempt, 1)
        XCTAssertEqual(retired.resultCode, "INVOCATION_ADMISSION_REFUSED")
        XCTAssertFalse(retired.measurementAttemptConsumed)
        XCTAssertEqual(retired.fixtureExecutionCount, 0)
        XCTAssertFalse(retired.fixtureIdentityEstablished)
        XCTAssertFalse(retired.repeatBuildDeterminismEstablished)
        XCTAssertFalse(retired.currentPinRelationEstablished)
        XCTAssertTrue(retired.oldFailureCauseRemainsInference)
        XCTAssertTrue(retired.opportunityRetired)
        XCTAssertFalse(retired.retryAuthorized)
        XCTAssertFalse(retired.rerunAuthorized)
        XCTAssertFalse(retired.replacementAuthorized)
        XCTAssertTrue(retired.allRetiredFilesMustRemainByteIdentical)
        XCTAssertFalse(retired.anyRetiredLauncherOrEvaluatorInvokedByV2)

        let inventory = authority.fixtureInputInventory
        assertFiles(inventory.exactFiles, expectedCount: 5)
        XCTAssertEqual(inventory.exactFileCount, 5)
        XCTAssertEqual(inventory.packagePath, "Tests/PrimeValidationWorkflow")
        XCTAssertEqual(
            inventory.fixtureProductName,
            "PrimeValidationWorkflowFixtureChild"
        )
        XCTAssertEqual(inventory.fixtureTargetName, inventory.fixtureProductName)
        XCTAssertEqual(inventory.fixtureExecutableLeaf, inventory.fixtureProductName)
        XCTAssertEqual(inventory.currentAcceptancePinByteCount, 89_632)
        XCTAssertEqual(
            inventory.currentAcceptancePinSHA256,
            "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd"
        )
        XCTAssertTrue(
            [
                inventory.packageManifestMutationAuthorized,
                inventory.packageLockMutationAuthorized,
                inventory.mirrorMutationAuthorized,
                inventory.fixtureSourceMutationAuthorized,
                inventory.secureChildKernelMutationAuthorized,
                inventory.currentPinMutationAuthorized,
            ].allSatisfy { !$0 }
        )

        let helper = authority.sharedTopologyHelperContract
        XCTAssertEqual(helper.classifierSource, topology.implementationExactFiles[0])
        XCTAssertEqual(helper.matrixSource, topology.implementationExactFiles[2])
        XCTAssertEqual(helper.helperSource, topology.implementationExactFiles[3])
        XCTAssertEqual(helper.sourcedFunctionName, topology.helperFunctionName)
        XCTAssertEqual(
            helper.helperFirstExecutableStatement,
            "[[ \"$-\" == *p* ]] || return 97"
        )
        XCTAssertEqual(
            helper.helperSecondExecutableStatement,
            "builtin unset BASH_ENV ENV"
        )
        XCTAssertEqual(
            helper.optionalRelationSuffixMarker,
            "--ordered-merge-child-relation"
        )
        XCTAssertEqual(helper.currentIndexMarker, "--current-index-exact-revision")
        XCTAssertEqual(helper.maximumOrdinaryExplicitRequestCount, 8)
        XCTAssertEqual(helper.maximumRelationExplicitRequestCount, 6)
        XCTAssertEqual(helper.exactRelationImplicitObjectCount, 2)
        XCTAssertEqual(
            helper.maximumRelationExplicitRequestCount
                + helper.exactRelationImplicitObjectCount,
            helper.maximumTotalObjectCount
        )
        XCTAssertEqual(helper.maximumParentCount, 8)
        XCTAssertEqual(helper.exactAllowedAmbientInputNames, ["RUNNER_TEMP"])
        XCTAssertEqual(helper.successResultCode, "TOPOLOGY_VERIFIED")
        XCTAssertEqual(helper.successReturnStatus, 0)
        XCTAssertEqual(helper.emittedFailureReturnStatus, 1)
        XCTAssertEqual(helper.internalNoRecordFailureReturnStatus, 2)
        XCTAssertEqual(helper.maximumCanonicalRecordByteCount, 512)
        XCTAssertTrue(helper.recordHasOneTerminalLF)
        XCTAssertFalse(helper.stderrPublished)
        XCTAssertTrue(helper.relationBindsOrderedMergeAndDiscoveredChild)
        XCTAssertTrue(
            helper
                .activatedMarkerBindsHEADCleanStatusAndIndexTreeBeforeAndAfterRawObservation
        )
        XCTAssertFalse(helper.sameEUIDConcurrentMutationInScope)

        let currentTopology = authority.currentAuthorityTopologyCallContract
        XCTAssertEqual(currentTopology.unchangedFetchDepth, 2)
        XCTAssertFalse(
            currentTopology
                .unchangedFetchesGuaranteeHistoricalReviewedHeadAvailability
        )
        XCTAssertTrue(
            currentTopology
                .reviewedHeadDirectChildAndSameTreeBoundByFrozenRun170AndRun171Evidence
        )
        XCTAssertEqual(currentTopology.frozenExternalEvidenceRunNumbers, [170, 171])
        XCTAssertEqual(
            currentTopology.availableImplementationBaseRevision,
            repository.mergeRevision
        )
        XCTAssertEqual(
            currentTopology.availableImplementationBaseTree,
            repository.mergeTree
        )
        XCTAssertEqual(
            currentTopology.availableImplementationBaseOrderedParentRevisions,
            repository.orderedMergeParentRevisions
        )
        XCTAssertFalse(currentTopology.helperReprovesHistoricalReviewedHeadAvailability)
        XCTAssertTrue(
            currentTopology
                .availableImplementationBaseUsesRawReplacementDisabledSHAReboundHelperProof
        )
        XCTAssertEqual(currentTopology.pullRequestExplicitRequestCount, 2)
        XCTAssertEqual(currentTopology.pullRequestCurrentExactRevisionRequestOrdinal, 1)
        XCTAssertEqual(currentTopology.pullRequestVerifiedImplementationBaseRequestOrdinal, 2)
        XCTAssertEqual(
            currentTopology.pullRequestExactFunctionArgumentVector,
            [
                helper.sourcedFunctionName,
                "<canonical_exact_checkout_root>", "2",
                "current_exact_revision", "<github.event.pull_request.head.sha>",
                "<independently_admitted_current_index_tree>", "1",
                repository.mergeRevision,
                "verified_implementation_base", repository.mergeRevision,
                repository.mergeTree, "2", repository.baseRevision,
                repository.reviewedHeadRevision, helper.currentIndexMarker,
            ]
        )
        XCTAssertEqual(currentTopology.pushExplicitRequestCount, 1)
        XCTAssertEqual(currentTopology.pushVerifiedImplementationBaseRequestOrdinal, 1)
        XCTAssertEqual(
            currentTopology.pushExactFunctionArgumentVector,
            [
                helper.sourcedFunctionName,
                "<canonical_exact_checkout_root>", "1",
                "verified_implementation_base", repository.mergeRevision,
                repository.mergeTree, "2", repository.baseRevision,
                repository.reviewedHeadRevision,
                helper.optionalRelationSuffixMarker,
                "current_exact_revision", "<github.sha>",
                "<independently_admitted_current_index_tree>",
                repository.mergeRevision, "current_reviewed_child",
            ]
        )
        XCTAssertTrue(currentTopology.pullRequestUsesCurrentIndexMarker)
        XCTAssertTrue(currentTopology.pushUsesOrderedMergeChildRelationSuffix)
        XCTAssertTrue(currentTopology.legacyExactCommitChecksAreCumulativeConsistencyOnly)
        XCTAssertFalse(
            currentTopology
                .legacyExactCommitChecksProvideRawReplacementDisabledSHAReboundProof
        )
        XCTAssertFalse(currentTopology.fetchVectorChangeAuthorized)

        let patch = authority.authorityPatchContract
        assertExactFive(
            patch.exactOrderedPaths,
            source:
                "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementV2Authority.swift",
            test:
                "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityTests.swift"
        )
        XCTAssertEqual(patch.exactPathCount, 5)
        XCTAssertEqual(patch.modifiedExistingPathCount, 3)
        XCTAssertEqual(patch.addedPathCount, 2)
        XCTAssertEqual(patch.expectedActiveLatinTestCount, 116)
        XCTAssertEqual(patch.expectedRootTestCount, 90)
        XCTAssertEqual(patch.expectedIsolatedTestCount, 6)
        XCTAssertEqual(patch.expectedFocusedWholeTestCount, 96)
        XCTAssertEqual(patch.expectedRetainedLiveTestCount, 46)
        XCTAssertEqual(patch.expectedAggregateTestCount, 142)
        XCTAssertEqual(patch.expectedEmbeddedProvenanceRecordCount, 532)
        XCTAssertEqual(patch.activeRootTimeoutMinutes, 45)
        XCTAssertEqual(patch.reviewedMainTimeoutMinutes, 90)
        XCTAssertEqual(patch.workflowJobCount, 2)
        XCTAssertEqual(patch.activeRootUserStepCount, 5)
        XCTAssertEqual(patch.reviewedMainUserStepCount, 5)
        XCTAssertTrue(patch.workflowJobAndStepTopologyMustRemainUnchanged)
        XCTAssertTrue(patch.fetchVectorsMustRemainByteIdentical)
        XCTAssertTrue(patch.retainedLiveCommandsMustRemainByteIdentical)
        XCTAssertTrue(patch.packageManifestMustRemainByteIdentical)
        XCTAssertTrue(patch.packageLockMustRemainByteIdentical)
        XCTAssertTrue(patch.currentHelperImplementationMustRemainByteIdentical)
        XCTAssertTrue(
            patch.baselineHostedGateMatrixTestsAndRetainedLiveCommandsStillExecute
        )
        XCTAssertFalse(patch.currentPatchExecutesMeasurement)

        let future = authority.futureMechanicsPatchContract
        XCTAssertEqual(future.exactPathCount, 5)
        XCTAssertEqual(future.modifiedExistingPathCount, 3)
        XCTAssertEqual(future.addedPathCount, 2)
        XCTAssertEqual(future.exactOrderedPaths.map(\.gitStatus), ["M", "M", "M", "A", "A"])
        XCTAssertEqual(
            future.exactOrderedPaths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement-v2.sh",
                "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluatorV2.swift",
            ]
        )
        XCTAssertEqual(future.launcherPath, future.exactOrderedPaths[3].path)
        XCTAssertEqual(future.evaluatorPath, future.exactOrderedPaths[4].path)
        XCTAssertTrue(future.exactMainGreenRequiredBeforeImplementation)
        XCTAssertTrue(future.authorityMergeRevisionAvailableOnlyAfterClosure)
        XCTAssertTrue(future.authorityMergeTreeAvailableOnlyAfterClosure)
        XCTAssertFalse(future.futureMechanicsPullRequestHeadFrozenHere)
        XCTAssertFalse(future.futureMechanicsMergeRevisionFrozenHere)
        XCTAssertFalse(future.futureMechanicsMergeTreeFrozenHere)
        XCTAssertFalse(future.futureMechanicsWorkflowRunFrozenHere)
        XCTAssertTrue(future.mechanicsPullRequestHeadMustBeDirectChildOfAuthorityMerge)
        XCTAssertTrue(future.mechanicsMergeMustBeSignedTwoParentSameTreeMerge)
        XCTAssertTrue(future.noInterveningMainCommitAuthorized)
        XCTAssertTrue(future.mainPushOnly)
        XCTAssertEqual(future.requiredEvent, "push")
        XCTAssertEqual(future.requiredRef, "refs/heads/main")
        XCTAssertEqual(future.requiredRunAttempt, 1)
        XCTAssertTrue(future.launcherMustPerformEquivalentThreePathSourceAdmission)
        XCTAssertTrue(future.launcherMustSourceSharedHelper)
        XCTAssertEqual(future.duplicatedPrivateTopologyParserCount, 0)
        XCTAssertEqual(
            future.helperRelationArgumentVector[8],
            helper.optionalRelationSuffixMarker
        )
        XCTAssertEqual(
            future.helperRelationArgumentVector,
            [
                "<canonical_exact_checkout_root>", "1",
                "verified_authority_base", "<authority_merge_revision>",
                "<authority_merge_tree>", "2",
                "<authority_merge_parent1>", "<authority_merge_parent2>",
                helper.optionalRelationSuffixMarker,
                "current_exact_revision", "<mechanics_merge_revision>",
                "<independently_admitted_current_index_tree>",
                "<authority_merge_revision>", "current_reviewed_child",
            ]
        )
        XCTAssertEqual(future.helperFixedAuthorityBaseExplicitRequestCount, 1)
        XCTAssertEqual(future.helperFixedAuthorityBaseExplicitRequestOrdinal, 1)
        XCTAssertTrue(future.helperUsesOrderedMergeChildRelationSuffix)
        XCTAssertTrue(
            future
                .helperFixedAuthorityBaseUsesRawReplacementDisabledSHAReboundProof
        )
        XCTAssertEqual(future.helperCallCount, 1)
        XCTAssertTrue(future.helperRecordCapturedBoundedlyAndNotRepublishedRaw)
        XCTAssertTrue(
            future
                .helperFailureProjectedAsOneSanitizedMeasurementRecordWhenLauncherControlsReturn
        )
        XCTAssertTrue(future.anyTopologyHelperFailureIsTerminal)
        XCTAssertFalse(future.topologyFailureConsumesBuildAttempt)
        XCTAssertEqual(future.expectedRootTestCount, 90)
        XCTAssertEqual(future.expectedFocusedWholeTestCount, 96)
        XCTAssertEqual(future.expectedAggregateTestCount, 142)
        XCTAssertEqual(future.expectedEmbeddedProvenanceRecordCount, 534)
        XCTAssertEqual(future.reviewedUserStepAdditionCount, 1)
        XCTAssertEqual(future.activeRootTimeoutMinutesRemains, 45)
        XCTAssertEqual(future.reviewedMainTimeoutMinutesRemains, 90)
        XCTAssertEqual(future.predecessorReviewedDurationSeconds, 4_046)
        XCTAssertEqual(future.predecessorReviewedTimeoutHeadroomSeconds, 1_354)
        XCTAssertEqual(4_046 + 1_354, 90 * 60)
        XCTAssertFalse(future.timingHeadroomGuaranteesFutureMeasurementCompletion)
        XCTAssertTrue(future.insufficientTimingRequiresSeparateAuthorityBeforeConsumption)

        let execution = authority.measurementExecutionContract
        XCTAssertTrue(execution.privateBaseLeaf.hasSuffix("-v2"))
        XCTAssertEqual(execution.exactTreeSourceRootLeaves.count, 2)
        XCTAssertTrue(execution.exactTreeSourceRootLeaves.allSatisfy { $0.hasSuffix("-v2") })
        XCTAssertEqual(execution.fixtureBuildRootSetLeaves.count, 2)
        XCTAssertTrue(execution.fixtureBuildRootSetLeaves.allSatisfy { $0.hasSuffix("-v2") })
        XCTAssertTrue(execution.evaluatorRootLeaf.hasSuffix("-v2"))
        XCTAssertTrue(execution.evaluatorExecutableLeaf.hasSuffix("-v2"))
        XCTAssertEqual(execution.buildConfiguration, "release")
        XCTAssertEqual(execution.independentExactTreeSourceRootCount, 2)
        XCTAssertEqual(execution.independentBuildRootSetCount, 2)
        XCTAssertEqual(execution.fixtureProductBuildCommandCount, 2)
        XCTAssertEqual(execution.showBinPathCommandCount, 2)
        XCTAssertEqual(execution.evaluatorCompileCommandCount, 1)
        XCTAssertEqual(execution.evaluatorCommandCount, 1)
        XCTAssertTrue(
            [
                execution.fixtureExecutableInvocationCount,
                execution.adapterInvocationCount,
                execution.leaseAcquisitionCount,
                execution.modelExecutionCount,
                execution.mlxExecutionCount,
                execution.metalExecutionCount,
                execution.pythonInvocationCount,
                execution.cppInvocationCount,
                execution.dependencyNetworkInvocationCount,
            ].allSatisfy { $0 == 0 }
        )
        XCTAssertEqual(execution.maximumFixtureExecutableByteCount, 4_194_304)
        XCTAssertEqual(execution.maximumShowBinAcceptedByteCount, 1_024)
        XCTAssertEqual(execution.maximumEvaluatorJSONByteCount, 2_048)
        XCTAssertEqual(execution.maximumPublishedRecordLineByteCount, 4_096)
        XCTAssertEqual(execution.maximumReadChunkByteCount, 65_536)
        XCTAssertEqual(
            execution.evaluatorRequiredImports,
            ["CryptoKit", "Darwin", "Foundation", "MachO"]
        )
        XCTAssertEqual(execution.evaluatorOpenFlags, ["O_RDONLY", "O_NOFOLLOW", "O_CLOEXEC"])
        XCTAssertTrue(execution.cryptoKitSHA256Required)
        XCTAssertTrue(execution.fullByteEqualityRequired)
        XCTAssertTrue(execution.thinArm64MachORequired)
        XCTAssertEqual(execution.exactLCUUIDCount, 1)
        XCTAssertEqual(execution.exactLCBuildVersionCount, 1)
        XCTAssertTrue(execution.entireLCBuildVersionCommandBytesCompared)
        XCTAssertFalse(execution.codeSignatureValidityEstablished)
        XCTAssertFalse(execution.launchabilityEstablished)
        XCTAssertTrue(execution.attemptConsumedImmediatelyBeforeFirstBuild)
        XCTAssertFalse(execution.preBuildTopologyFailureConsumesAttempt)
        XCTAssertTrue(execution.createdRootsRetainedOnlyUntilEphemeralRunnerTeardown)
        XCTAssertFalse(execution.createdRootReuseAuthorized)
        XCTAssertEqual(execution.actionsArtifactCount, 0)
        XCTAssertFalse(execution.durableEvidenceEstablishedByLauncher)

        let output = authority.measurementOutputContract
        XCTAssertTrue(output.prefix.contains("measurement-v2"))
        XCTAssertTrue(output.schemaID.contains("measurement_v2"))
        XCTAssertEqual(output.schemaVersion, 1)
        XCTAssertTrue(output.canonicalJSONRequired)
        XCTAssertEqual(output.exactLineCountWhenPresent, 1)
        XCTAssertTrue(output.terminalLFRequiredWhenPresent)
        XCTAssertEqual(output.maximumLineByteCount, 4_096)
        XCTAssertEqual(output.measurementOutcomeMembers, ["IDENTICAL", "DIFFERENT", "UNAVAILABLE"])
        XCTAssertEqual(output.observationOutcomeMembers, ["IDENTICAL", "DIFFERENT", "UNAVAILABLE", "FAILURE"])
        XCTAssertEqual(output.pinRelationMembers, ["MATCH", "DIFFERENT"])
        XCTAssertEqual(output.identicalResultCodes.count, 2)
        XCTAssertEqual(output.differentResultCode, "DIFFERENT_BUILD")
        XCTAssertEqual(output.topologyFailureResultCode, "TOPOLOGY_REFUSED")
        XCTAssertTrue(output.everyLowLevelResultMappedExactlyOnce)
        XCTAssertEqual(
            Set(output.exactLowLevelResultMappings.map(\.lowLevelResultCode)).count,
            output.exactLowLevelResultMappings.count
        )
        XCTAssertTrue(
            output.exactLowLevelResultMappings.allSatisfy {
                $0.terminallyRetiresMeasurementOpportunity
            }
        )
        let mappings = Dictionary(
            uniqueKeysWithValues: output.exactLowLevelResultMappings.map {
                ($0.lowLevelResultCode, $0)
            }
        )
        let expectedLowLevelCodes =
            output.identicalResultCodes
            + [output.differentResultCode]
            + output.unavailableResultCodes
            + output.failureResultCodes
        XCTAssertEqual(
            output.failureResultCodes,
            [
                "LAUNCHER_NOT_REACHED",
                "EXTERNAL_TIMEOUT",
                "EXTERNAL_CANCELLATION",
                "EXIT_PROJECTION_FAILURE",
                "ABRUPT_HOST_LOSS",
                "RECORD_ABSENT_CAUSE_UNESTABLISHED",
            ]
        )
        XCTAssertEqual(output.exactLowLevelResultMappings.count, 32)
        XCTAssertEqual(mappings.count, 32)
        XCTAssertEqual(Set(mappings.keys), Set(expectedLowLevelCodes))
        XCTAssertEqual(
            Dictionary(grouping: output.exactLowLevelResultMappings, by: \.measurementOutcome)
                .mapValues(\.count),
            ["IDENTICAL": 2, "DIFFERENT": 1, "UNAVAILABLE": 23, "FAILURE": 6]
        )
        XCTAssertEqual(
            mappings["PASS_IDENTICAL_CURRENT_PIN"]?.measurementOutcome,
            "IDENTICAL"
        )
        XCTAssertEqual(mappings["PASS_IDENTICAL_CURRENT_PIN"]?.pinRelation, "MATCH")
        XCTAssertEqual(
            mappings["PASS_IDENTICAL_DIFFERENT_PIN"]?.measurementOutcome,
            "IDENTICAL"
        )
        XCTAssertEqual(
            mappings["PASS_IDENTICAL_DIFFERENT_PIN"]?.pinRelation,
            "DIFFERENT"
        )
        XCTAssertEqual(mappings["DIFFERENT_BUILD"]?.measurementOutcome, "DIFFERENT")
        XCTAssertNil(mappings["DIFFERENT_BUILD"]?.pinRelation)
        for code in output.unavailableResultCodes {
            XCTAssertEqual(mappings[code]?.measurementOutcome, "UNAVAILABLE", code)
            XCTAssertNil(mappings[code]?.pinRelation, code)
        }
        for code in output.failureResultCodes {
            XCTAssertEqual(mappings[code]?.measurementOutcome, "FAILURE", code)
            XCTAssertNil(mappings[code]?.pinRelation, code)
            XCTAssertEqual(mappings[code]?.attemptConsumed, "unavailable", code)
        }
        XCTAssertEqual(mappings["LAUNCHER_NOT_REACHED"]?.recordCardinality, "zero")
        for code in [
            "EXTERNAL_TIMEOUT", "EXTERNAL_CANCELLATION",
            "EXIT_PROJECTION_FAILURE", "ABRUPT_HOST_LOSS",
        ] {
            XCTAssertEqual(
                mappings[code]?.recordCardinality,
                "zero_or_one_nonaccepting",
                code
            )
        }
        XCTAssertEqual(
            mappings["RECORD_ABSENT_CAUSE_UNESTABLISHED"]?.recordCardinality,
            "zero"
        )
        XCTAssertEqual(mappings["EXTERNAL_TIMEOUT"]?.workflowConclusion, "timed_out")
        XCTAssertEqual(mappings["EXTERNAL_CANCELLATION"]?.workflowConclusion, "cancelled")
        XCTAssertEqual(mappings["EXIT_PROJECTION_FAILURE"]?.workflowConclusion, "failure")
        XCTAssertEqual(
            mappings["RECORD_ABSENT_CAUSE_UNESTABLISHED"]?.workflowConclusion,
            "failure"
        )
        XCTAssertEqual(mappings["CAPTURE_REFUSED"]?.recordCardinality, "one")
        XCTAssertEqual(mappings["CAPTURE_REFUSED"]?.measurementOutcome, "UNAVAILABLE")
        XCTAssertEqual(
            output.failureDefinition,
            "launcher_not_reached_OR_external_timeout_OR_external_cancellation_OR_exit_projection_failure_OR_abrupt_host_loss_OR_record_absent_cause_unestablished"
        )
        XCTAssertTrue(output.differentBuildIsTerminal)
        XCTAssertTrue(output.identicalDifferentPinIsNotDifferentMeasurement)
        XCTAssertTrue(output.identityFieldsRequiredForIdenticalOrDifferent)
        XCTAssertTrue(output.pinRelationNullableUnlessOutcomeIdentical)
        XCTAssertEqual(output.rawAbsolutePathFieldCount, 0)
        XCTAssertEqual(output.rawBuildOutputOrErrorFieldCount, 0)
        XCTAssertEqual(output.exactRecordCountForEveryLauncherControlledOutcome, 1)
        XCTAssertTrue(
            output
                .recordMayBeAbsentOnlyAfterExternalTimeoutCancellationHostLossLauncherNotReachedExitProjectionFailureOrCauseUnestablished
        )
        XCTAssertTrue(output.absentRecordCauseClassificationRequiresPositiveEvidence)
        XCTAssertTrue(output.absentRecordCauseMustNeverBeInferredOrInvented)
        XCTAssertEqual(
            output.unclassifiedAbsentRecordResultCode,
            "RECORD_ABSENT_CAUSE_UNESTABLISHED"
        )
        XCTAssertEqual(
            output.absentRecordAttemptConsumptionWithoutSeparateProof,
            "unavailable"
        )
        XCTAssertFalse(output.failureOutcomesEstablishMeasurement)
        XCTAssertFalse(output.failureOutcomesEstablishFixtureIdentity)
        XCTAssertFalse(output.failureOutcomesAuthorizeRetryRerunOrReplacement)
        XCTAssertTrue(output.captureRefusedIsLauncherControlledExactlyOneRecord)
        XCTAssertTrue(
            output.everyRecordOrAbsentOutcomeRequiresAppendOnlyObservationAndRetirement
        )
        XCTAssertTrue(output.falseAttemptConsumptionStillRetiresOpportunity)

        XCTAssertEqual(authority.exactPhaseTransitions.map(\.ordinal), [1, 2, 3, 4, 5])
        XCTAssertEqual(
            authority.exactPhaseTransitions.map(\.measurementOutcome),
            ["DIFFERENT", "UNAVAILABLE", "FAILURE", "IDENTICAL", "IDENTICAL"]
        )
        XCTAssertTrue(
            authority.exactPhaseTransitions.allSatisfy {
                !$0.retryRerunReplacementOrImplicitCanaryAuthorized
            }
        )
        XCTAssertTrue(authority.exactPhaseTransitions[0].terminalAbsentNewAuthority)
        XCTAssertTrue(authority.exactPhaseTransitions[1].terminalAbsentNewAuthority)
        XCTAssertTrue(authority.exactPhaseTransitions[2].terminalAbsentNewAuthority)
        XCTAssertTrue(authority.exactPhaseTransitions[2].exactAllowedNextAuthorityIDs.isEmpty)
        XCTAssertEqual(authority.exactPhaseTransitions[3].pinRelation, "MATCH")
        XCTAssertEqual(authority.exactPhaseTransitions[4].pinRelation, "DIFFERENT")

        let preservation = authority.preservationContract
        XCTAssertTrue(preservation.retiredV1PathsMustRemainByteIdentical)
        XCTAssertTrue(preservation.retiredRun160RemainsTerminal)
        XCTAssertTrue(preservation.topologyImplementationFilesMustRemainByteIdentical)
        XCTAssertTrue(preservation.topologyAuthorityPairsMustRemainByteIdentical)
        XCTAssertTrue(
            [
                preservation.packageManifestMutationAuthorized,
                preservation.packageLockMutationAuthorized,
                preservation.dependencyResolutionMutationAuthorized,
                preservation.secureChildKernelMutationAuthorized,
                preservation.currentPinMutationAuthorized,
                preservation.existingV1LauncherRetrofittedOrReactivated,
                preservation.existingV1EvaluatorRetrofittedOrReactivated,
            ].allSatisfy { !$0 }
        )

        let ceiling = authority.authorityCeiling
        XCTAssertTrue(ceiling.predecessorExactMainClosureEstablished)
        XCTAssertTrue(ceiling.predecessorTopologyVerificationEstablished)
        XCTAssertTrue(ceiling.retiredV1ClosurePreserved)
        XCTAssertTrue(ceiling.v2MeasurementAuthorityEstablished)
        XCTAssertTrue(ceiling.exactlyOneFutureMechanicsAttemptAuthorizedAfterClosure)
        XCTAssertTrue(ceiling.currentPatchIsPureDataOnly)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(authority.orderedRequiredSeparateActions.count, 9)

        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        if Authority.canonicalByteCount == 0 || Authority.canonicalSHA256.isEmpty {
            let candidateSHA = PrimeSHA256.hexDigest(of: canonical)
            XCTFail(
                "PRE-FREEZE canonical pins intentionally unset; independent review must bind byte_count=\(canonical.count) sha256=\(candidateSHA)"
            )
            return
        }
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256
        )
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        try assertEveryRecursiveMutationRejects(canonical)
        try assertNoncanonicalEncodingsReject(canonical)
    }

    private func assertRun(
        _ run: Authority.WorkflowRunClosure,
        id: Int,
        number: Int,
        suite: Int,
        event: String,
        ref: String,
        head: String
    ) {
        XCTAssertEqual(run.workflowName, "Prime active-root quarantine")
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
        _ job: Authority.JobClosure,
        id: Int,
        runner: String,
        conclusion: String,
        duration: Int,
        userSteps: Int,
        successfulSteps: Int
    ) {
        XCTAssertEqual(job.jobID, id)
        XCTAssertEqual(job.runnerLabel, runner)
        XCTAssertEqual(job.status, "completed")
        XCTAssertEqual(job.conclusion, conclusion)
        XCTAssertEqual(job.durationSeconds, duration)
        XCTAssertEqual(job.userStepCount, userSteps)
        XCTAssertEqual(job.successfulUserStepCount, successfulSteps)
        XCTAssertEqual(job.failedUserStepCount, 0)
        XCTAssertEqual(job.skippedUserStepCount, 0)
    }

    private func assertLog(
        _ log: Authority.ConnectorDecodedLogIdentity,
        jobID: Int,
        bytes: Int,
        lines: Int,
        bomCount: Int,
        sha256: String
    ) {
        XCTAssertEqual(log.jobID, jobID)
        XCTAssertEqual(log.byteCount, bytes)
        XCTAssertEqual(log.lfByteCount, lines)
        XCTAssertEqual(log.crByteCount, 0)
        XCTAssertEqual(log.utf8BOMCount, bomCount)
        XCTAssertTrue(log.terminalLFPresent)
        XCTAssertEqual(log.sha256, sha256)
        XCTAssertTrue(log.repeatFetchExactlyEqual)
        XCTAssertFalse(log.rawArchiveBytesBound)
        XCTAssertFalse(log.rawArchiveRetained)
    }

    private func assertFiles(
        _ files: [Authority.FileIdentity],
        expectedCount: Int
    ) {
        XCTAssertEqual(files.count, expectedCount)
        XCTAssertEqual(files.map(\.ordinal), Array(1 ... expectedCount))
        XCTAssertEqual(Set(files.map(\.path)).count, expectedCount)
        XCTAssertTrue(files.allSatisfy { ["100644", "100755"].contains($0.gitMode) })
        XCTAssertTrue(files.allSatisfy { $0.gitBlob.utf8.count == 40 })
        XCTAssertTrue(files.allSatisfy { $0.byteCount > 0 })
        XCTAssertTrue(files.allSatisfy { $0.lfByteCount > 0 })
        XCTAssertTrue(files.allSatisfy { $0.crByteCount == 0 })
        XCTAssertTrue(files.allSatisfy { $0.sha256.utf8.count == 64 })
    }

    private func assertExactFive(
        _ paths: [Authority.PathContract],
        source: String,
        test: String
    ) {
        XCTAssertEqual(paths.count, 5)
        XCTAssertEqual(paths.map(\.ordinal), [1, 2, 3, 4, 5])
        XCTAssertEqual(paths.map(\.gitStatus), ["M", "M", "M", "A", "A"])
        XCTAssertEqual(
            paths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                source,
                test,
            ]
        )
        XCTAssertEqual(Set(paths.map(\.path)).count, 5)
    }

    private func authorityFalseClaims(
        _ ceiling: Authority.AuthorityCeiling
    ) -> [Bool] {
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
            ceiling.currentPinMatchEstablished,
            ceiling.currentPinMismatchEstablished,
            ceiling.pinRepairAuthorized,
            ceiling.pinRepairPerformed,
            ceiling.noMutationConfirmationAuthorized,
            ceiling.noMutationConfirmationPerformed,
            ceiling.realMonitorHeldLeaseCanaryAuthorized,
            ceiling.realMonitorHeldLeaseCanaryPerformed,
            ceiling.retryOrRerunAuthorized,
            ceiling.modelExecutionAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
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
        XCTAssertGreaterThan(valuePaths.count, 300)
        for path in valuePaths {
            let original = try value(at: path, in: root)
            let mutatedValue = mutateJSONValue(original)
            let mutatedRoot = try replacingValue(in: root, at: path, with: mutatedValue)
            try assertCanonicalRejects(mutatedRoot, context: "replace \(describe(path))")
        }

        let dictionaryPaths = allDictionaryPaths(root)
        XCTAssertGreaterThan(dictionaryPaths.count, 20)
        for path in dictionaryPaths {
            let dictionary = try XCTUnwrap(try value(at: path, in: root) as? [String: Any])
            for key in dictionary.keys.sorted() {
                let removed = try removingValue(in: root, at: path + [.key(key)])
                try assertCanonicalRejects(
                    removed,
                    context: "remove \(describe(path + [.key(key)]))"
                )
            }
        }

        let arrayPaths = allArrayPaths(root)
        XCTAssertGreaterThan(arrayPaths.count, 10)
        for path in arrayPaths {
            let array = try XCTUnwrap(try value(at: path, in: root) as? [Any])
            for index in array.indices {
                let removed = try removingValue(in: root, at: path + [.index(index)])
                try assertCanonicalRejects(
                    removed,
                    context: "remove \(describe(path + [.index(index)]))"
                )
            }
            if array.count >= 2 {
                for index in 0 ..< array.count - 1
                    where canonicalFragment(array[index])
                        != canonicalFragment(array[index + 1])
                {
                    var reordered = array
                    reordered.swapAt(index, index + 1)
                    let changed = try replacingValue(in: root, at: path, with: reordered)
                    try assertCanonicalRejects(
                        changed,
                        context: "reorder \(describe(path))"
                    )
                }
            }
        }

        var unknown = root
        unknown["unknown_recursive_mutation"] = true
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

    private func allDictionaryPaths(_ root: Any) -> [[JSONPathComponent]] {
        allValuePathsIncludingRoot(root).compactMap { path in
            ((try? value(at: path, in: root)) as? [String: Any]) == nil
                ? nil : path
        }
    }

    private func allArrayPaths(_ root: Any) -> [[JSONPathComponent]] {
        allValuePathsIncludingRoot(root).compactMap { path in
            ((try? value(at: path, in: root)) as? [Any]) == nil
                ? nil : path
        }
    }

    private func allValuePathsIncludingRoot(
        _ root: Any
    ) -> [[JSONPathComponent]] {
        [[]] + allValuePaths(root)
    }

    private func value(
        at path: [JSONPathComponent],
        in root: Any
    ) throws -> Any {
        var current = root
        for component in path {
            switch component {
            case let .key(key):
                current = try XCTUnwrap((current as? [String: Any])?[key])
            case let .index(index):
                let array = try XCTUnwrap(current as? [Any])
                current = array[index]
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
            dictionary["unknown_recursive_mutation"] = true
            return dictionary
        }
        XCTFail("unsupported JSON value \(type(of: value))")
        return "__unsupported_mutation"
    }

    private func assertCanonicalRejects(
        _ object: Any,
        context: String
    ) throws {
        let data = try canonicalJSONData(object)
        XCTAssertThrowsError(try Authority.decodeCanonical(data), context)
        if let loose = try? JSONDecoder().decode(Authority.self, from: data) {
            if loose != Authority.frozenV1 {
                XCTAssertThrowsError(try loose.validate(), context)
            }
        }
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

        let string = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let escapedSlash = string.replacingOccurrences(of: "/", with: "\\/")
        if escapedSlash != string {
            XCTAssertThrowsError(
                try Authority.decodeCanonical(try XCTUnwrap(escapedSlash.data(using: .utf8)))
            )
        }

        var oversized = Data(repeating: 0x20, count: 131_073)
        oversized[0] = 0x7B
        XCTAssertThrowsError(try Authority.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as? PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityError,
                .oversizedEncoding
            )
        }
    }

    private func canonicalJSONData(_ object: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    private func canonicalFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )) ?? Data()
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
