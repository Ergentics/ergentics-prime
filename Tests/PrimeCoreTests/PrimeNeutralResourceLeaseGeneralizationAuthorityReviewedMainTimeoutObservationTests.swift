// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndTimeoutCeiling()
        throws
    {
        requireSendable(Observation.self)
        let observation = Observation.frozenV1

        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.schemaID,
            "prime_neutral_resource_lease_generalization_authority_reviewed_main_timeout_observation_v1"
        )
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_neutral_resource_lease_generalization_authority_reviewed_main_timeout_run148_v1"
        )
        XCTAssertEqual(
            observation.observationKind,
            "append_only_reviewed_main_timeout_observation_and_bounded_repair_authority"
        )
        XCTAssertEqual(
            observation.classification,
            "timeout_incomplete_not_semantic_failure"
        )
        XCTAssertEqual(
            observation.originalAuthorityID,
            "ergentics_prime_neutral_resource_lease_generalization_authority_v1"
        )
        XCTAssertEqual(
            observation.originalAuthorityStatus,
            "AUTHORITY_ONLY_neutral_resource_lease_alias_and_typed_retention_exact5_no_implementation_no_mechanics_legacy_b_mlx_layer_a_preserved"
        )
        XCTAssertEqual(observation.originalAuthorityCanonicalByteCount, 27_174)
        XCTAssertEqual(
            observation.originalAuthorityCanonicalSHA256,
            "ae5b5a73861bbd1584510f0adf358eee32ddb478878597272dc8b0a67c0142cb"
        )
        XCTAssertTrue(observation.originalAuthorityRemainsFrozen)
        XCTAssertFalse(observation.originalAuthorityExactMainGreen)
        XCTAssertFalse(observation.originalAuthoritySemanticContractInvalidated)

        XCTAssertEqual(observation.frozenFiles.count, 5)
        assertFile(
            observation.frozenFiles[0],
            path: "Sources/PrimeCore/PrimeNeutralResourceLeaseGeneralizationAuthority.swift",
            mode: "100644",
            blob: "2d1a91b1d428b3d47698ed16e57392a0aba8695a",
            bytes: 71_435,
            lines: 1_367,
            sha256: "ea0353cfed507cc50889ab3555105ebacb3cd4cef1486294b5b8ae51254a53b1"
        )
        assertFile(
            observation.frozenFiles[1],
            path: "Tests/PrimeCoreTests/PrimeNeutralResourceLeaseGeneralizationAuthorityTests.swift",
            mode: "100644",
            blob: "eb35192c9fd4eac162195f73788b73df71d31e8a",
            bytes: 52_630,
            lines: 1_205,
            sha256: "0f074a097f3fdaa9917ede0fe8acb4819231f6d765030199710e8a7d0cefcf7a"
        )
        assertFile(
            observation.frozenFiles[2],
            path: ".github/scripts/prime-ci-active-root-quarantine.sh",
            mode: "100755",
            blob: "90df96e4909d01ac073eff79bfb1321323419f81",
            bytes: 1_230_079,
            lines: 20_419,
            sha256: "e0eee1a0b224a7f67650dc3276f66d2e4ac498a3d4133441a3e228afa140a968"
        )
        assertFile(
            observation.frozenFiles[3],
            path: ".github/workflows/prime-active-root-quarantine.yml",
            mode: "100644",
            blob: "b5b3dee162db46a1456756bef185dcf40849a79e",
            bytes: 146_013,
            lines: 694,
            sha256: "b4e20c181e8ca4f6d002f8a521025d89750c053510745bcf2ec3773b0fa43d78"
        )
        assertFile(
            observation.frozenFiles[4],
            path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            mode: "100644",
            blob: "fd966bf2f11acebe1e4ab0a4df2e7aad1a2db28e",
            bytes: 546,
            lines: 13,
            sha256: "272332346a40372e5a4bd8c466bbab4e6c65a67be58a6e352c2a9f233cd6230b"
        )
        XCTAssertEqual(Set(observation.frozenFiles.map(\.path)).count, 5)

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 124)
        XCTAssertEqual(
            repository.mergeRevision,
            "0abcb4ad5487a775627bbb587184c375dd691978"
        )
        XCTAssertEqual(
            repository.mergeTree,
            "94e16511f39fc79b2854423bc82b763974a9cc46"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "4570716892722873757de6eae1bd897167d674eb",
                "3258f3d8b8d79df7e2b152c4bdb9eac77223bb78",
            ]
        )
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            repository.orderedParentRevisions[1]
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.mergeTree)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.githubSignatureVerified)
        XCTAssertEqual(repository.githubSignatureReason, "valid")
        XCTAssertEqual(
            repository.githubSignatureVerifiedAt,
            "2026-08-17T03:15:14Z"
        )

        let pullRequest = observation.pullRequestClosure
        XCTAssertEqual(pullRequest.headRevision, repository.reviewedHeadRevision)
        XCTAssertEqual(pullRequest.headTree, repository.reviewedHeadTree)
        XCTAssertEqual(pullRequest.workflowRunID, 31_989_606_001)
        XCTAssertEqual(pullRequest.workflowRunNumber, 147)
        XCTAssertEqual(pullRequest.workflowRunAttempt, 1)
        XCTAssertEqual(pullRequest.activeRootJobID, 95_270_648_656)
        XCTAssertEqual(pullRequest.activeRootJobConclusion, "success")
        XCTAssertEqual(pullRequest.reviewedMainJobID, 95_271_322_489)
        XCTAssertEqual(pullRequest.reviewedMainJobConclusion, "skipped")
        XCTAssertEqual(pullRequest.reviewedMainJobStepCount, 0)
        XCTAssertEqual(pullRequest.matchingPullRequestRunCountForHead, 1)
        XCTAssertEqual(pullRequest.actionsArtifactCount, 0)
        XCTAssertFalse(pullRequest.consumedAuthorizedExactMainCompletion)

        let run = observation.workflowRun
        XCTAssertEqual(run.workflowName, "Prime active-root quarantine")
        XCTAssertEqual(run.runID, 31_990_567_513)
        XCTAssertEqual(run.runNumber, 148)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.checkSuiteID, 86_731_396_865)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.ref, "refs/heads/main")
        XCTAssertEqual(run.headSHA, repository.mergeRevision)
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "cancelled")
        XCTAssertEqual(run.createdAt, "2026-08-17T03:15:17Z")
        XCTAssertEqual(run.startedAt, "2026-08-17T03:15:17Z")
        XCTAssertEqual(run.updatedAt, "2026-08-17T04:20:28Z")
        XCTAssertNil(run.previousAttemptURL)
        XCTAssertEqual(run.matchingPushRunCountForHead, 1)
        XCTAssertEqual(run.retryCount, 0)
        XCTAssertEqual(run.rerunCount, 0)

        assertJob(
            observation.activeRootJob,
            id: 95_273_237_917,
            name: "First-party MLX / active-root quarantine",
            runner: "macos-15",
            conclusion: "success",
            startedAt: "2026-08-17T03:15:20Z",
            completedAt: "2026-08-17T03:19:57Z",
            stepNames: [
                "Set up job",
                "Check out the exact Prime revision",
                "Validate active metadata and preserved history",
                "Parse the changed Swift contracts without dependencies",
                "Validate isolated Latin capture and observation contracts",
                "Record the authority ceiling",
                "Complete job",
            ],
            stepConclusions: Array(repeating: "success", count: 7)
        )
        assertConnectorDecodedJobLog(
            observation.activeRootConnectorDecodedJobLog,
            jobID: 95_273_237_917,
            bytes: 327_304,
            lines: 1_886,
            sha256: "518d82f2e9c687bcfca06bc1ae583904f99e5acbaaef9168dda528ce161e319b",
            firstTimestamp: "2026-08-17T03:15:21.1771230Z",
            lastTimestamp: "2026-08-17T03:19:53.3499490Z"
        )
        XCTAssertEqual(observation.activeRootLatinTestCount, 116)
        XCTAssertEqual(observation.activeRootLatinFailureCount, 0)
        XCTAssertEqual(observation.activeRootLatinSkipCount, 0)

        assertJob(
            observation.reviewedMainJob,
            id: 95_273_924_450,
            name: "Reviewed main / focused source contracts",
            runner: "macos-26",
            conclusion: "cancelled",
            startedAt: "2026-08-17T03:20:00Z",
            completedAt: "2026-08-17T04:20:27Z",
            stepNames: [
                "Set up job",
                "Record the hosted Apple toolchain",
                "Check out reviewed main exactly",
                "Fetch the exact private dependency without evaluating Prime",
                "Compile and run the focused contracts without a credential",
                "Run the Prime-owned decoder on live Metal",
                "Complete job",
            ],
            stepConclusions: [
                "success", "success", "success", "success", "success",
                "cancelled", "success",
            ]
        )
        assertConnectorDecodedJobLog(
            observation.reviewedMainConnectorDecodedJobLog,
            jobID: 95_273_924_450,
            bytes: 10_316_082,
            lines: 78_941,
            sha256: "125d6f45ce2ca3ad688a66795ab85e8dbb5e79ed661ed921c7fae7a3cdd324fd",
            firstTimestamp: "2026-08-17T03:20:01.8671540Z",
            lastTimestamp: "2026-08-17T04:20:14.0529700Z"
        )

        let timeout = observation.timeoutEvidence
        XCTAssertEqual(timeout.configuredReviewedMainTimeoutMinutes, 60)
        XCTAssertEqual(timeout.proposedReviewedMainTimeoutMinutes, 75)
        XCTAssertEqual(timeout.reviewedJobAPIDurationSeconds, 3_627)
        XCTAssertTrue(timeout.configuredTimeoutBoundaryReached)
        XCTAssertEqual(
            timeout.maximumExecutionTimeAnnotation,
            "The job has exceeded the maximum execution time of 1h0m0s"
        )
        XCTAssertEqual(timeout.maximumExecutionTimeAnnotationCount, 1)
        XCTAssertEqual(timeout.cancellationAnnotation, "The operation was canceled.")
        XCTAssertEqual(timeout.cancellationAnnotationCount, 1)
        XCTAssertEqual(
            timeout.exactCancellationLogLine,
            "2026-08-17T04:20:13.8459900Z ##[error]The operation was canceled."
        )
        XCTAssertEqual(timeout.exactCancellationLogLineCount, 1)
        XCTAssertEqual(timeout.classificationBasis.count, 6)
        XCTAssertEqual(Set(timeout.classificationBasis).count, 6)
        XCTAssertTrue(timeout.timeoutIncompleteNotSemanticFailure)
        XCTAssertTrue(timeout.partialSuccessDoesNotCompleteReviewedMain)
        XCTAssertTrue(timeout.observedRunMayNotBeRerunOrRetried)

        let focused = observation.focusedObservation
        XCTAssertEqual(focused.startedAt, "2026-08-17T03:20:20Z")
        XCTAssertEqual(focused.completedAt, "2026-08-17T03:53:28Z")
        XCTAssertEqual(focused.durationSeconds, 1_988)
        XCTAssertEqual(focused.rootTestCount, 80)
        XCTAssertEqual(focused.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(focused.isolatedTestCount, 6)
        XCTAssertEqual(focused.focusedWholeTestCount, 86)
        XCTAssertEqual(focused.rootTestCount + focused.isolatedTestCount, 86)
        XCTAssertEqual(focused.failureCount, 0)
        XCTAssertEqual(focused.skipCount, 0)
        XCTAssertTrue(focused.allFiveCommandsCompleted)
        XCTAssertEqual(
            focused.neutralAuthorityTestClassName,
            "PrimeNeutralResourceLeaseGeneralizationAuthorityTests"
        )
        XCTAssertEqual(
            focused.neutralAuthorityTestMethodName,
            "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling"
        )
        XCTAssertEqual(focused.neutralAuthorityTestStartCount, 1)
        XCTAssertEqual(focused.neutralAuthorityTestPassCount, 1)
        XCTAssertEqual(focused.neutralAuthorityTestFailureCount, 0)
        XCTAssertEqual(focused.neutralAuthorityTestSkipCount, 0)
        XCTAssertEqual(focused.neutralAuthorityTestDurationMilliseconds, 2_397)

        let live = observation.retainedLiveObservation
        XCTAssertEqual(live.stepStartedAt, "2026-08-17T03:53:28Z")
        XCTAssertEqual(live.stepCompletedAt, "2026-08-17T04:20:13Z")
        XCTAssertEqual(live.stepDurationSeconds, 1_605)
        XCTAssertEqual(
            live.commandOrder,
            [
                "bash .github/scripts/prime-ci-native-decoder-metal.sh",
                "bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh",
                "bash .github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
            ]
        )
        assertRetainedCommand(
            live.metal,
            ordinal: 1,
            command: live.commandOrder[0],
            classification: "completed_success_retained_baseline",
            tests: 44,
            receipts: 0,
            markers: 1,
            completed: true,
            cancelled: false,
            runtimeCapabilityReached: true
        )
        assertRetainedCommand(
            live.maintainedRuntime,
            ordinal: 2,
            command: live.commandOrder[1],
            classification: "completed_success_retained_baseline",
            tests: 1,
            receipts: 1,
            markers: 1,
            completed: true,
            cancelled: false,
            runtimeCapabilityReached: true
        )
        assertRetainedCommand(
            live.tokenizer,
            ordinal: 3,
            command: live.commandOrder[2],
            classification: "cancelled_at_job_timeout_during_build_before_test_or_runtime",
            tests: 0,
            receipts: 0,
            markers: 0,
            completed: false,
            cancelled: true,
            runtimeCapabilityReached: false
        )
        XCTAssertEqual(
            live.tokenizerLastCompileProgress,
            "[197/199] Compiling PrimeNativeDecoder PrimeNativeGQADecoder.swift"
        )
        XCTAssertFalse(live.tokenizerTestProcessStarted)
        XCTAssertFalse(live.tokenizerNative300MAllocationObserved)
        XCTAssertEqual(live.completedLiveTestCount, 45)
        XCTAssertEqual(live.expectedCompleteLiveTestCount, 46)
        XCTAssertEqual(live.completedAggregateTestCount, 131)
        XCTAssertEqual(live.expectedCompleteAggregateTestCount, 132)
        XCTAssertEqual(
            focused.focusedWholeTestCount + live.completedLiveTestCount,
            live.completedAggregateTestCount
        )
        XCTAssertEqual(
            focused.focusedWholeTestCount + live.expectedCompleteLiveTestCount,
            live.expectedCompleteAggregateTestCount
        )
        XCTAssertFalse(live.retainedBaselineChanged)
        XCTAssertTrue(live.retainedPartialSuccessPreservedAsObservation)

        let absence = observation.absenceEvidence
        XCTAssertEqual(
            absence.workflowOperationalSurfaceCorpus,
            "parsed_workflow_executable_run_script_and_uses_nodes_excluding_echo_payload_text"
        )
        XCTAssertEqual(
            absence.workflowArtifactUploadActionNeedle,
            "uses: actions/upload-artifact@"
        )
        XCTAssertEqual(
            absence.workflowExactClosedCanaryLauncherPath,
            ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh"
        )
        XCTAssertEqual(
            absence.workflowExecutableClosedCanaryLauncherCommandNeedle,
            "run: bash .github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh"
        )
        XCTAssertEqual(
            absence.workflowExecutableSecureChildAdapterProductBuildCommandNeedle,
            "swift build --product PrimeValidationWorkflowSecureChildIntegration"
        )
        XCTAssertEqual(
            absence.workflowExecutableFixtureChildProductBuildCommandNeedle,
            "swift build --product PrimeValidationWorkflowFixtureChild"
        )
        XCTAssertTrue(absenceCounts(absence).allSatisfy { $0 == 0 })

        let repair = observation.repairAuthority
        assertExactFive(repair.exactOrderedPaths)
        XCTAssertEqual(repair.exactPathCount, 5)
        XCTAssertEqual(
            repair.workflowSoleTestExecutionBudgetChange,
            "trusted_main_compile_timeout_minutes_60_to_75"
        )
        XCTAssertEqual(repair.workflowSoleTestExecutionBudgetChangeOccurrenceCount, 1)
        XCTAssertEqual(repair.activeRootTimeoutMinutes, 45)
        XCTAssertEqual(repair.reviewedMainTimeoutBeforeMinutes, 60)
        XCTAssertEqual(repair.reviewedMainTimeoutAfterMinutes, 75)
        XCTAssertEqual(repair.reviewedMainTimeoutDeltaMinutes, 15)
        XCTAssertEqual(
            repair.reviewedMainTimeoutBeforeMinutes + repair.reviewedMainTimeoutDeltaMinutes,
            repair.reviewedMainTimeoutAfterMinutes
        )
        XCTAssertEqual(repair.activeRootPrimeFetchDepth, 2)
        XCTAssertEqual(repair.reviewedMainPrimeFetchDepth, 2)
        XCTAssertEqual(repair.reviewedMainMLXFetchDepth, 1)
        XCTAssertEqual(repair.workflowJobCount, 2)
        XCTAssertTrue(repair.reviewedMainNeedsActiveRoot)
        XCTAssertTrue(repair.workflowJobAndStepOrderMustRemainUnchanged)
        XCTAssertTrue(repair.retainedLiveCommandSequenceMustRemainByteIdentical)
        XCTAssertTrue(repair.workflowJobTopologyMustRemainUnchanged)
        XCTAssertEqual(
            repair.historicalAuthorityBaseObjectID,
            repository.orderedParentRevisions[0]
        )
        XCTAssertTrue(
            repair.activeRootExistingFetchAddsOnlyHistoricalAuthorityBaseObject
        )
        XCTAssertTrue(
            repair.reviewedMainExistingFetchAddsOnlyHistoricalAuthorityBaseObject
        )
        XCTAssertEqual(repair.addedImmutableProofWantCountPerExistingFetch, 1)
        XCTAssertTrue(
            repair.exactPrimeFetchInvocationCountPerCheckoutStepRemainsOne
        )
        XCTAssertEqual(repair.additionalFetchStepCount, 0)
        XCTAssertEqual(
            repair.additionalPrimeFetchInvocationCountPerCheckoutStep,
            0
        )
        XCTAssertEqual(repair.additionalMutableRefCount, 0)
        XCTAssertTrue(repair.historicalAuthorityBaseObjectIsExistingFetchInput)
        XCTAssertFalse(
            repair.historicalAuthorityBaseObjectIsDetachedWorktreeCheckoutTarget
        )
        XCTAssertFalse(
            repair.historicalAuthorityBaseObjectIsTestOrLiveExecutionInput
        )
        XCTAssertFalse(repair.lineageHydrationAddsMechanics)
        XCTAssertTrue(repair.existingRetainedLiveScriptsMustRemainByteIdentical)
        XCTAssertTrue(repair.originalAuthorityPairMustRemainByteIdentical)
        XCTAssertTrue(repair.readmeMustRemainByteIdentical)
        XCTAssertTrue(repair.packageManifestMustRemainByteIdentical)
        XCTAssertTrue(repair.packageLockMustRemainByteIdentical)
        XCTAssertTrue(repair.canaryLauncherMustRemainByteIdentical)
        XCTAssertTrue(repair.oneDistinctDirectSuccessorCompletionAuthorized)
        XCTAssertTrue(repair.directSuccessorAuthorizedOnlyAfterExactFiveClosure)
        XCTAssertEqual(repair.directSuccessorEvent, "push")
        XCTAssertEqual(repair.directSuccessorRef, "refs/heads/main")
        XCTAssertEqual(repair.directSuccessorRequiredRunAttempt, 1)
        XCTAssertEqual(repair.directSuccessorMaximumAuthorizedRunCount, 1)
        XCTAssertFalse(repair.pullRequestValidationConsumesDirectSuccessor)
        XCTAssertFalse(repair.observedRunRerunAuthorized)
        XCTAssertFalse(repair.observedRunRetryAuthorized)
        XCTAssertFalse(repair.additionalSuccessorAttemptAuthorized)
        XCTAssertFalse(repair.replacementExecutionCommandAuthorized)
        XCTAssertFalse(repair.implementationIncluded)
        XCTAssertFalse(repair.implementationAuthorizedByThisObservation)
        XCTAssertFalse(repair.downstreamAuthorityGranted)

        let expected = observation.expectedRepairClosure
        XCTAssertEqual(expected.activeLatinTestCount, 116)
        XCTAssertEqual(expected.rootTestCount, 81)
        XCTAssertEqual(expected.isolatedTestCount, 6)
        XCTAssertEqual(expected.focusedWholeTestCount, 87)
        XCTAssertEqual(expected.retainedLiveTestCount, 46)
        XCTAssertEqual(expected.aggregateTestCount, 133)
        XCTAssertEqual(expected.failureCount, 0)
        XCTAssertEqual(expected.skipCount, 0)
        XCTAssertEqual(expected.rootTestCount + expected.isolatedTestCount, 87)
        XCTAssertEqual(expected.focusedWholeTestCount + expected.retainedLiveTestCount, 133)
        XCTAssertEqual(expected.embeddedProvenanceRecordCount, 513)
        XCTAssertEqual(expected.timeoutMinutes, 75)
        XCTAssertEqual(expected.neutralTimeoutObservationTestCount, 1)
        XCTAssertEqual(expected.newMechanicsInvocationCount, 0)
        XCTAssertEqual(expected.actionsArtifactCount, 0)
        XCTAssertEqual(expected.requiredRunAttempt, 1)
        XCTAssertTrue(expected.requiredPreviousAttemptURLIsNull)
        XCTAssertTrue(expected.uniquePushRunRequired)
        XCTAssertTrue(expected.implementationMayOnlyBeSeparatelyReviewedAfterGreen)

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.timeoutObservationEstablished)
        XCTAssertTrue(ceiling.boundedTimeoutRepairAuthorized)
        XCTAssertTrue(ceiling.oneDistinctDirectSuccessorCompletionAuthorized)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(
            observation.status,
            "OBSERVED_TIMEOUT_INCOMPLETE_REPAIR_AUTHORIZED_exact5_timeout_60_to_75_no_implementation_no_new_mechanics"
        )
        XCTAssertEqual(
            observation.orderedNextActions,
            [
                "merge_only_this_pure_exact5_timeout_observation_and_repair",
                "require_one_unique_attempt1_direct_successor_exact_main_completion_at_75_minutes",
                "do_not_rerun_retry_or_recover_run148",
                "require_root81_isolated6_focused87_live46_aggregate133_and_provenance513",
                "only_after_green_separately_review_the_neutral_alias_and_typed_retention_implementation",
                "do_not_collapse_monitor_composition_durability_or_adapter_work_into_this_repair",
            ]
        )

        let canonical = try observation.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(observation))
        XCTAssertEqual(canonical.count, Observation.canonicalByteCount)
        XCTAssertEqual(PrimeSHA256.hexDigest(of: canonical), Observation.canonicalSHA256)
        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        let decoded = try Observation.decodeCanonical(canonical)
        XCTAssertEqual(decoded, observation)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let parentsPath: JSONPath = [
            .key("repositoryIdentity"), .key("orderedParentRevisions"),
        ]
        for malformedParents in [
            [],
            [repository.orderedParentRevisions[0]],
            repository.orderedParentRevisions + [repository.mergeRevision],
        ] {
            let malformed = replacingValue(
                in: object,
                at: parentsPath,
                with: { _ in malformedParents }
            )
            let data = try canonicalJSONData(malformed)
            XCTAssertThrowsError(try Observation.decodeCanonical(data))
            if let loose = try? JSONDecoder().decode(Observation.self, from: data) {
                XCTAssertThrowsError(try loose.validate())
                XCTAssertThrowsError(try loose.validateExactV1())
            }
        }

        let hugeIntegerPaths: [JSONPath] = [
            [.key("timeoutEvidence"), .key("reviewedJobAPIDurationSeconds")],
            [.key("focusedObservation"), .key("rootTestCount")],
            [.key("retainedLiveObservation"), .key("completedAggregateTestCount")],
            [.key("expectedRepairClosure"), .key("aggregateTestCount")],
        ]
        for path in hugeIntegerPaths {
            let malformed = replacingValue(
                in: object,
                at: path,
                with: { _ in NSNumber(value: Int.max) }
            )
            let data = try canonicalJSONData(malformed)
            let loose = try JSONDecoder().decode(Observation.self, from: data)
            XCTAssertThrowsError(try loose.validate())
            XCTAssertThrowsError(try loose.validateExactV1())
            XCTAssertThrowsError(try Observation.decodeCanonical(data))
        }

        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(dictionaryPaths.count, 20)
        XCTAssertGreaterThan(scalarPaths.count, 250)

        var mutationCount = 0
        var nullCount = 0
        var removalCount = 0
        var looseDecodedDriftCount = 0
        for path in valuePaths {
            let mutationData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))"
            )
            mutationCount += 1
            if assertLooseDecodedDriftRejects(
                mutationData,
                comparedTo: observation
            ) {
                looseDecodedDriftCount += 1
            }

            let nullData = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { value in
                        if value is NSNull { return "__null_mutation" }
                        return NSNull()
                    }
                ),
                label: "null \(pathLabel(path))"
            )
            nullCount += 1
            _ = assertLooseDecodedDriftRejects(nullData, comparedTo: observation)

            let removedData = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
            removalCount += 1
            _ = assertLooseDecodedDriftRejects(removedData, comparedTo: observation)
        }
        XCTAssertEqual(mutationCount, valuePaths.count)
        XCTAssertEqual(nullCount, valuePaths.count)
        XCTAssertEqual(removalCount, valuePaths.count)
        XCTAssertGreaterThan(looseDecodedDriftCount, 250)

        var reorderedArrayCount = 0
        for path in allArrayPaths(in: object) {
            var didReorder = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in 0 ..< array.count {
                        for right in (left + 1) ..< array.count
                        where canonicalJSONFragment(array[left])
                            != canonicalJSONFragment(array[right])
                        {
                            array.swapAt(left, right)
                            didReorder = true
                            return array
                        }
                    }
                    return array
                }
            )
            if didReorder {
                let data = try assertCanonicalRejects(
                    reordered,
                    label: "reordered \(pathLabel(path))"
                )
                XCTAssertTrue(
                    assertLooseDecodedDriftRejects(data, comparedTo: observation)
                )
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 8)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_timeout_observation_field_\(index)"] = true
                    return dictionary
                }
            )
            let data = try assertCanonicalRejects(
                unknown,
                label: "unknown \(pathLabel(path))"
            )
            XCTAssertEqual(
                try JSONDecoder().decode(Observation.self, from: data),
                observation
            )
            unknownFieldCount += 1
        }
        XCTAssertEqual(unknownFieldCount, dictionaryPaths.count)

        try assertNoncanonicalEncodingsReject(canonical, object: object)

        let oversized = Data(repeating: 0x20, count: 131_073)
        XCTAssertThrowsError(try Observation.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as?
                    PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationError,
                .oversizedEncoding
            )
        }
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)

        var label: String {
            switch self {
            case let .key(key): return key
            case let .index(index): return "[\(index)]"
            }
        }
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map(\.label).joined(separator: ".")
    }

    private func allValuePaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(in: array[index], prefix: path)
            }
        }
        return []
    }

    private func allDictionaryPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return []
    }

    private func allArrayPaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allScalarPaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allScalarPaths(in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return [prefix]
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else { return transform(value) }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!,
                at: remainder,
                with: transform
            )
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform
            )
            return array
        }
    }

    private func removingValue(in value: Any, at path: JSONPath) -> Any {
        precondition(!path.isEmpty)
        let remainder = Array(path.dropFirst())
        switch path[0] {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(in: object[key]!, at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(in: array[index], at: remainder)
            }
            return array
        }
    }

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )) ?? Data()
    }

    private func canonicalJSONData(_ value: Any) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: value,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if value is NSNull { return "__was_null_mutation" }
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return NSNumber(value: number.int64Value + 1)
        }
        if var array = value as? [Any] {
            array.append(array.first ?? "__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["unknown_recursive_mutation"] = true
            return object
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }

    @discardableResult
    private func assertCanonicalRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try canonicalJSONData(object)
        XCTAssertThrowsError(
            try Observation.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
        return data
    }

    @discardableResult
    private func assertLooseDecodedDriftRejects(
        _ data: Data,
        comparedTo observation: Observation,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let loose = try? JSONDecoder().decode(Observation.self, from: data),
              loose != observation
        else {
            return false
        }
        XCTAssertThrowsError(try loose.validate(), file: file, line: line)
        XCTAssertThrowsError(try loose.validateExactV1(), file: file, line: line)
        return true
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Observation.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashData = try XCTUnwrap(slashEscaped.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(slashData))

        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let opening = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(contentsOf: schemaField, at: reordered.index(after: opening))
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(duplicateData))
    }

    private func assertFile(
        _ identity: Observation.FileIdentity,
        path: String,
        mode: String,
        blob: String,
        bytes: Int,
        lines: Int,
        sha256: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(identity.path, path, file: file, line: line)
        XCTAssertEqual(identity.gitMode, mode, file: file, line: line)
        XCTAssertEqual(identity.gitBlob, blob, file: file, line: line)
        XCTAssertEqual(identity.byteCount, bytes, file: file, line: line)
        XCTAssertEqual(identity.lfByteCount, lines, file: file, line: line)
        XCTAssertEqual(identity.sha256, sha256, file: file, line: line)
        XCTAssertFalse(identity.role.isEmpty, file: file, line: line)
        XCTAssertTrue(isLowercaseHex(blob, count: 40), file: file, line: line)
        XCTAssertTrue(isLowercaseHex(sha256, count: 64), file: file, line: line)
    }

    private func assertJob(
        _ job: Observation.Job,
        id: Int,
        name: String,
        runner: String,
        conclusion: String,
        startedAt: String,
        completedAt: String,
        stepNames: [String],
        stepConclusions: [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(job.jobID, id, file: file, line: line)
        XCTAssertEqual(job.name, name, file: file, line: line)
        XCTAssertEqual(job.runnerLabel, runner, file: file, line: line)
        XCTAssertEqual(job.status, "completed", file: file, line: line)
        XCTAssertEqual(job.conclusion, conclusion, file: file, line: line)
        XCTAssertEqual(job.startedAt, startedAt, file: file, line: line)
        XCTAssertEqual(job.completedAt, completedAt, file: file, line: line)
        XCTAssertEqual(job.steps.map(\.number), Array(1 ... 7), file: file, line: line)
        XCTAssertEqual(job.steps.map(\.name), stepNames, file: file, line: line)
        XCTAssertEqual(job.steps.map(\.status), Array(repeating: "completed", count: 7), file: file, line: line)
        XCTAssertEqual(job.steps.map(\.conclusion), stepConclusions, file: file, line: line)
        XCTAssertTrue(job.steps.allSatisfy { !$0.startedAt.isEmpty && !$0.completedAt.isEmpty }, file: file, line: line)
    }

    private func assertRetainedCommand(
        _ command: Observation.RetainedCommandObservation,
        ordinal: Int,
        command expectedCommand: String,
        classification: String,
        tests: Int,
        receipts: Int,
        markers: Int,
        completed: Bool,
        cancelled: Bool,
        runtimeCapabilityReached: Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(command.ordinal, ordinal, file: file, line: line)
        XCTAssertEqual(command.command, expectedCommand, file: file, line: line)
        XCTAssertEqual(command.classification, classification, file: file, line: line)
        XCTAssertEqual(command.testCount, tests, file: file, line: line)
        XCTAssertEqual(command.failureCount, 0, file: file, line: line)
        XCTAssertEqual(command.skipCount, 0, file: file, line: line)
        XCTAssertEqual(command.receiptCount, receipts, file: file, line: line)
        XCTAssertEqual(command.okMarkerCount, markers, file: file, line: line)
        XCTAssertEqual(command.completed, completed, file: file, line: line)
        XCTAssertEqual(command.cancelled, cancelled, file: file, line: line)
        XCTAssertEqual(command.runtimeCapabilityReached, runtimeCapabilityReached, file: file, line: line)
    }

    private func assertConnectorDecodedJobLog(
        _ identity: Observation.ConnectorDecodedUTF8JobLogIdentity,
        jobID: Int,
        bytes: Int,
        lines: Int,
        sha256: String,
        firstTimestamp: String,
        lastTimestamp: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(identity.jobID, jobID, file: file, line: line)
        XCTAssertEqual(
            identity.bindingKind,
            "github_connector_decoded_utf8_job_log_aggregate_identity",
            file: file,
            line: line
        )
        XCTAssertEqual(
            identity.representation,
            "github_connector_decoded_utf8_job_log_aggregate_not_raw_zip",
            file: file,
            line: line
        )
        XCTAssertEqual(identity.byteCount, bytes, file: file, line: line)
        XCTAssertEqual(identity.lfByteCount, lines, file: file, line: line)
        XCTAssertEqual(identity.crByteCount, 0, file: file, line: line)
        XCTAssertEqual(identity.sha256, sha256, file: file, line: line)
        XCTAssertTrue(identity.utf8BOMPresent, file: file, line: line)
        XCTAssertTrue(identity.terminalLFPresent, file: file, line: line)
        XCTAssertTrue(identity.repeatFetchExactlyEqual, file: file, line: line)
        XCTAssertFalse(identity.rawArchiveBytesBound, file: file, line: line)
        XCTAssertFalse(identity.rawArchiveRetained, file: file, line: line)
        XCTAssertEqual(identity.firstTimestamp, firstTimestamp, file: file, line: line)
        XCTAssertEqual(identity.lastTimestamp, lastTimestamp, file: file, line: line)
        XCTAssertTrue(isLowercaseHex(sha256, count: 64), file: file, line: line)
    }

    private func assertExactFive(
        _ paths: [Observation.PathContract],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(paths.count, 5, file: file, line: line)
        XCTAssertEqual(paths.map(\.ordinal), Array(1 ... 5), file: file, line: line)
        XCTAssertEqual(
            paths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservation.swift",
                "Tests/PrimeCoreTests/PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationTests.swift",
            ],
            file: file,
            line: line
        )
        XCTAssertEqual(paths.map(\.gitStatus), ["M", "M", "M", "A", "A"], file: file, line: line)
        XCTAssertEqual(paths.map(\.gitMode), ["100755", "100644", "100644", "100644", "100644"], file: file, line: line)
        XCTAssertEqual(Set(paths.map(\.path)).count, 5, file: file, line: line)
        XCTAssertTrue(paths.allSatisfy { !$0.role.isEmpty }, file: file, line: line)
    }

    private func absenceCounts(_ evidence: Observation.AbsenceEvidence) -> [Int] {
        [
            evidence.actionsAPIArtifactCount,
            evidence.workflowArtifactUploadActionReferenceCount,
            evidence.workflowExactClosedCanaryLauncherPathReferenceCount,
            evidence.workflowExecutableClosedCanaryLauncherCommandCount,
            evidence.workflowExecutableSecureChildAdapterProductBuildCommandCount,
            evidence.workflowExecutableFixtureChildProductBuildCommandCount,
            evidence.patchImplementationSourceAddedCount,
            evidence.patchImplementationTestAddedCount,
            evidence.observationSourceRuntimeCapabilityCount,
        ]
    }

    private func authorityFalseClaims(_ ceiling: Observation.AuthorityCeiling) -> [Bool] {
        [
            ceiling.semanticFailureEstablished,
            ceiling.originalAuthorityInvalidated,
            ceiling.originalAuthorityExactMainGreenEstablished,
            ceiling.neutralLeaseImplementationPerformed,
            ceiling.leaseAcquisitionAuthorized,
            ceiling.leaseReleaseAuthorized,
            ceiling.leaseReacquisitionAuthorized,
            ceiling.descriptorInspectionAuthorized,
            ceiling.descriptorTransferAuthorized,
            ceiling.processExecutionAuthorized,
            ceiling.fixtureExecutionAuthorized,
            ceiling.adapterExecutionAuthorized,
            ceiling.canaryExecutionAuthorized,
            ceiling.canaryRetryAuthorized,
            ceiling.canaryRerunAuthorized,
            ceiling.filesystemWriteAuthorized,
            ceiling.networkAuthorized,
            ceiling.layerAMutationAuthorized,
            ceiling.secureChildCompositionAuthorized,
            ceiling.durableTransactionLayerBAuthorized,
            ceiling.durableEvidenceEstablished,
            ceiling.physicalMetalReservationEstablished,
            ceiling.mlxExecutionAuthorized,
            ceiling.metalExecutionAuthorized,
            ceiling.native300MExecutionAuthorized,
            ceiling.pythonAuthorized,
            ceiling.cppAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.generalTrainingResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
