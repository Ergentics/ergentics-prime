// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import CryptoKit
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityV1

    func testFrozenV1CanonicalCodableBoundedMutationAndTimeoutRepairCeiling()
        throws
    {
        requireSendable(Authority.self)
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_exact_revision_topology_relation_timeout_repair_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityID,
            "ergentics_prime_exact_revision_topology_relation_timeout_repair_authority_v1"
        )
        XCTAssertTrue(authority.status.hasPrefix("RUN166_TIMEOUT_INCOMPLETE"))

        let frozen = authority.frozenRun166ExactFiveIdentity
        XCTAssertEqual(
            frozen.exactMainRevision,
            "444cd402c966521f6163f4949b4a73f9a5184e29"
        )
        XCTAssertEqual(
            frozen.exactMainTree,
            "2471a8610f4081c8a181daf9ac1d6d4ae8ec5f37"
        )
        XCTAssertEqual(frozen.exactFiles.count, 5)
        XCTAssertEqual(
            frozen.exactFiles.map(\.gitBlob),
            [
                "bc1d55368818a999976cffa8fb7e0f1ba47a5b83",
                "0b75726844c901def086d7e2dc6a062307731c6b",
                "8e6f105c2088fd5717fb54132a496e8507996c10",
                "bd063eb9f7998b1d95180c5cb5df0c49096af246",
                "be1b09bc9cde1f3e251791aa21b3e966ed4e8050",
            ]
        )
        XCTAssertEqual(
            frozen.exactFiles.map(\.byteCount),
            [1_511_716, 206_489, 546, 340_871, 173_242]
        )
        XCTAssertEqual(
            frozen.exactFiles.map(\.lfByteCount),
            [23_972, 761, 13, 5_530, 3_685]
        )
        XCTAssertTrue(frozen.exactFiles.allSatisfy { $0.crByteCount == 0 })
        XCTAssertEqual(
            frozen.exactFiveExcludedIndexSHA256,
            "915fe480012287f0620a38c0f298618966b1437fbca8038e35d53929a8c20d36"
        )
        XCTAssertEqual(frozen.relationAuthorityCanonicalByteCount, 467_184)
        XCTAssertEqual(
            frozen.relationAuthorityCanonicalSHA256,
            "ae13d26870b73515bf76018d2f0c1f10d13edf0a59c38857e5767f1abc668a98"
        )
        XCTAssertTrue(frozen.relationAuthorityPairMustRemainByteIdentical)
        XCTAssertFalse(frozen.relationAuthorityPairSuperseded)

        let repository = authority.repositoryIdentity
        XCTAssertEqual(repository.pullRequestNumber, 133)
        XCTAssertEqual(repository.mergeRevision, frozen.exactMainRevision)
        XCTAssertEqual(repository.mergeTree, frozen.exactMainTree)
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "3c40cce6350da7ed0ce0f5ccb0620f76feff0501",
                "2aa0185f43a470669fcabd160d897680d35a1b66",
            ]
        )
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.githubSignatureVerified)
        XCTAssertEqual(repository.githubSignatureReason, "valid")
        XCTAssertEqual(
            repository.githubSignatureVerifiedAt,
            "2026-08-21T14:10:00Z"
        )
        XCTAssertEqual(repository.gitObjectIdentityAlgorithm, "sha1")
        XCTAssertEqual(
            repository.gitObjectIdentityPurpose,
            "repository_native_Git_object_identity_only"
        )
        XCTAssertEqual(repository.syntheticGitEvidenceCount, 0)
        XCTAssertTrue(
            repository.gitSHA1MakesNoAuthenticityOrCollisionResistanceClaim
        )

        let run = authority.workflowRun
        XCTAssertEqual(run.runID, 32_490_668_515)
        XCTAssertEqual(run.runNumber, 166)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.checkSuiteID, 88_074_911_774)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.ref, "refs/heads/main")
        XCTAssertEqual(run.headSHA, repository.mergeRevision)
        XCTAssertEqual(run.conclusion, "cancelled")
        XCTAssertEqual(
            try duration(run.startedAt, run.completedAt),
            run.durationSeconds
        )
        XCTAssertNil(run.previousAttemptURL)
        XCTAssertEqual(run.matchingPushRunCountForHead, 1)
        XCTAssertEqual(run.retryCount, 0)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertEqual(run.actionsArtifactCount, 0)

        XCTAssertEqual(authority.activeRootJob.jobID, 96_797_271_270)
        XCTAssertEqual(authority.activeRootJob.conclusion, "success")
        XCTAssertEqual(authority.activeRootJob.durationSeconds, 268)
        XCTAssertEqual(authority.reviewedMainJob.jobID, 96_798_603_025)
        XCTAssertEqual(authority.reviewedMainJob.conclusion, "cancelled")
        XCTAssertEqual(authority.reviewedMainJob.durationSeconds, 4_527)
        let activeTests = authority.activeRootTestObservation
        XCTAssertEqual(activeTests.jobID, authority.activeRootJob.jobID)
        XCTAssertEqual(activeTests.latinTestCount, 116)
        XCTAssertEqual(activeTests.passCount, 116)
        XCTAssertEqual(activeTests.failureCount, 0)
        XCTAssertEqual(activeTests.skipCount, 0)

        assertLog(
            authority.activeRootLogIdentity,
            bytes: 385_283,
            lines: 1_922,
            bomCount: 1,
            bomOffsets: [0],
            offsetsAreBound: true,
            sha256:
                "6ebc29a465f49b11469f25f43d893b4684ddb4abc674fbca608e5f6e659259fd"
        )
        assertLog(
            authority.reviewedMainLogIdentity,
            bytes: 10_328_495,
            lines: 78_979,
            bomCount: 5,
            bomOffsets: [0, 2_112_582, 4_225_492, 6_338_188, 8_452_737],
            offsetsAreBound: true,
            sha256:
                "2e4a205cab29a6db3a56dd993c62c92570cc9c1d250bf8015329cef22b636380"
        )

        assertTextEvidence(
            authority.maximumExecutionTimeAnnotation,
            expectedText:
                "The job has exceeded the maximum execution time of 1h15m0s",
            expectedBytes: 58,
            expectedSHA256:
                "4a373f31128d7837a6248f4969b8c56aa5e328eba65ecb114c71ac29a8950faf"
        )
        assertTextEvidence(
            authority.cancellationAnnotation,
            expectedText: "The operation was canceled.",
            expectedBytes: 27,
            expectedSHA256:
                "71f739a80227fe65631c8cc4f6f0ca8327b4a3bfbd2bbc3bf0f13da06c056766"
        )
        assertTextEvidence(
            authority.cancellationLogLine,
            expectedText:
                "2026-08-21T15:29:50.1841720Z ##[error]The operation was canceled.\n",
            expectedBytes: 66,
            expectedSHA256:
                "10ac42948e70289b86176025f1672bf84201fc618daf62471376a574ca671575"
        )
        XCTAssertEqual(authority.cancellationLogLine.oneBasedLineNumber, 78_976)
        XCTAssertEqual(
            authority.cancellationLogLine.zeroBasedByteOffset,
            10_328_221
        )

        let focused = authority.focusedObservation
        XCTAssertEqual(try duration(focused.startedAt, focused.completedAt), 3_217)
        XCTAssertEqual(focused.rootTestCount, 88)
        XCTAssertEqual(focused.isolatedTestCount, 6)
        XCTAssertEqual(focused.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(focused.focusedWholeTestCount, 94)
        XCTAssertEqual(focused.passCount, 94)
        XCTAssertEqual(focused.failureCount, 0)
        XCTAssertEqual(focused.skipCount, 0)
        XCTAssertEqual(focused.relationAuthorityTestStartCount, 1)
        XCTAssertEqual(focused.relationAuthorityTestPassCount, 1)
        XCTAssertEqual(focused.relationAuthorityTestDurationMilliseconds, 1_077_052)

        let partial = authority.partialLiveObservation
        XCTAssertEqual(try duration(partial.startedAt, partial.completedAt), 1_277)
        XCTAssertEqual(
            partial.commandOrder,
            [
                "bash .github/scripts/prime-ci-native-decoder-metal.sh",
                "bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh",
                "bash .github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
            ]
        )
        XCTAssertTrue(partial.metal.completed)
        XCTAssertEqual(partial.metal.passCount, 44)
        XCTAssertTrue(partial.maintainedRuntime.completed)
        XCTAssertEqual(partial.maintainedRuntime.passCount, 1)
        XCTAssertEqual(partial.maintainedRuntime.receiptCount, 1)
        XCTAssertFalse(partial.tokenizer.completed)
        XCTAssertTrue(partial.tokenizer.cancelled)
        XCTAssertFalse(partial.tokenizer.semanticOutcomeEstablished)
        XCTAssertEqual(partial.metalTestCount, 44)
        XCTAssertEqual(partial.maintainedRuntimeTestCount, 1)
        XCTAssertEqual(partial.maintainedRuntimeReceiptCount, 1)
        XCTAssertEqual(partial.tokenizerTestCount, 0)
        XCTAssertEqual(partial.completedLiveTestCount, 45)
        XCTAssertEqual(partial.completedLivePassCount, 45)
        XCTAssertEqual(partial.expectedCompleteLiveTestCount, 46)
        XCTAssertEqual(partial.completedAggregateTestCount, 139)
        XCTAssertEqual(partial.expectedCompleteAggregateTestCount, 140)
        XCTAssertEqual(partial.missingLiveTestCount, 1)
        XCTAssertEqual(partial.lastTokenizerBuildProgressLine, "[99/196] Compiling bnns.cpp")
        XCTAssertTrue(partial.tokenizerBuildProcessStarted)
        XCTAssertFalse(partial.tokenizerTestCaseExecutionStarted)

        let baseline = authority.successfulLiveBaseline
        XCTAssertEqual(baseline.workflowRunID, 32_434_498_068)
        XCTAssertEqual(baseline.workflowRunNumber, 164)
        XCTAssertEqual(baseline.checkSuiteID, 87_927_821_060)
        XCTAssertEqual(baseline.reviewedMainJobID, 96_633_611_089)
        XCTAssertEqual(baseline.reviewedMainJobConclusion, "success")
        XCTAssertEqual(baseline.liveDurationSeconds, 1_609)
        XCTAssertEqual(baseline.postLiveDurationSeconds, 14)
        XCTAssertEqual(baseline.completedLiveTestCount, 46)
        XCTAssertTrue(baseline.baselineIsSuccessfulAndComplete)
        assertLog(
            baseline.reviewedLogIdentity,
            bytes: 10_341_953,
            lines: 79_079,
            bomCount: 5,
            bomOffsets: [],
            offsetsAreBound: false,
            sha256:
                "0149f6b4312df9570dbeaf652c9fecd368ca9f9b446b9b2cc14cc1d61d717c4f"
        )

        let timeout = authority.timeoutClassification
        XCTAssertEqual(timeout.configuredReviewedMainTimeoutMinutes, 75)
        XCTAssertEqual(timeout.proposedReviewedMainTimeoutMinutes, 90)
        XCTAssertEqual(timeout.configuredTimeoutSeconds, 75 * 60)
        XCTAssertEqual(timeout.proposedTimeoutSeconds, 90 * 60)
        XCTAssertEqual(timeout.exactClassification, "timeout_incomplete_not_semantic_failure")
        XCTAssertTrue(timeout.configuredTimeoutBoundaryAnnotationObserved)
        XCTAssertTrue(timeout.cancellationAnnotationObserved)
        XCTAssertTrue(timeout.cancellationLogLineObserved)
        XCTAssertTrue(timeout.allCompletedTestsPassed)
        XCTAssertTrue(timeout.incompleteCommandHasNoSemanticOutcome)
        XCTAssertTrue(timeout.timeoutIncompleteNotSemanticFailure)
        XCTAssertFalse(timeout.observedRunMayBeRerunOrRetried)
        XCTAssertFalse(timeout.successorMechanicsAuthorized)

        let runtime = authority.runtimeDerivation
        XCTAssertEqual(runtime.preFocusedOverheadSeconds, 19)
        XCTAssertEqual(runtime.observedFocusedSeconds, 3_217)
        XCTAssertEqual(runtime.frozenSuccessfulLiveBaselineSeconds, 1_609)
        XCTAssertEqual(runtime.postLiveOverheadSeconds, 14)
        XCTAssertEqual(19 + 3_217 + 1_609 + 14, 4_859)
        XCTAssertEqual(runtime.evidenceDerivedLowerBoundSeconds, 4_859)
        XCTAssertEqual(4_859 - 75 * 60, 359)
        XCTAssertEqual(90 * 60 - 4_859, 541)
        XCTAssertEqual(4_859 + 5, 4_864)
        XCTAssertEqual(4_864 - 75 * 60, 364)
        XCTAssertEqual(90 * 60 - 4_864, 536)
        XCTAssertEqual(81 * 60 - 4_859, 1)
        XCTAssertEqual((4_864 + 59) / 60, 82)
        XCTAssertEqual(
            runtime.lowerBoundWithNewAuthorityTestCeilingSeconds,
            4_864
        )
        XCTAssertEqual(
            runtime.preFreezeMaximumObservedAuthorityTestCeilingSeconds,
            1
        )
        XCTAssertEqual(
            runtime.lowerBoundWithPreFreezeMaximumObservedAuthorityTestSeconds,
            4_860
        )
        XCTAssertEqual(
            runtime
                .proposed90MinuteUnallocatedHeadroomWithPreFreezeMaximumObservedAuthorityTestSeconds,
            540
        )
        XCTAssertEqual(
            runtime
                .proposed90MinuteRemainingUnallocatedCompileAndVarianceAllowanceSeconds,
            536
        )
        XCTAssertEqual(runtime.nextExistingFifteenMinuteBoundary, 90)
        XCTAssertFalse(runtime.compileAndRuntimeVarianceMeasured)
        XCTAssertFalse(runtime.arithmeticHeadroomGuaranteesCompletion)
        XCTAssertTrue(runtime.exactMainSuccessMustBeObserved)
        XCTAssertTrue(runtime.arithmeticUsesCheckedIntegerInputsOnly)

        let repair = authority.repairAuthority
        XCTAssertEqual(repair.exactOrderedPaths.count, 5)
        XCTAssertEqual(repair.exactOrderedPaths.map(\.gitStatus), ["M", "M", "M", "A", "A"])
        XCTAssertEqual(repair.workflowTimeoutLiteralBefore, "timeout-minutes: 75")
        XCTAssertEqual(repair.workflowTimeoutLiteralAfter, "timeout-minutes: 90")
        XCTAssertEqual(repair.workflowTimeoutLiteralChangeOccurrenceCount, 1)
        XCTAssertTrue(repair.workflowJobAndStepOrderMustRemainUnchanged)
        XCTAssertTrue(repair.retainedLiveCommandSequenceMustRemainByteIdentical)
        XCTAssertTrue(repair.topologyVerifierImplementationMustRemainByteIdentical)
        XCTAssertTrue(repair.relationAuthorityPairMustRemainByteIdentical)
        XCTAssertEqual(repair.newSuccessorRelationMechanicsInvocationCount, 0)
        XCTAssertEqual(repair.authorizedTimeoutRepairMergeAttemptCount, 1)
        XCTAssertFalse(repair.observedRunRerunAuthorized)
        XCTAssertFalse(repair.observedRunRetryAuthorized)
        XCTAssertFalse(repair.replacementExecutionAuthorized)
        XCTAssertFalse(repair.successorMechanicsAuthorized)
        XCTAssertTrue(repair.exactFiveIncludesTimeoutRepairImplementation)
        XCTAssertFalse(repair.successorRelationImplementationIncluded)

        let sequence = authority.successorSequenceAmendment
        XCTAssertTrue(
            sequence.predecessorRelationAuthorityRequiresNoInterveningMainCommit
        )
        XCTAssertEqual(sequence.predecessorBaseRevision, frozen.exactMainRevision)
        XCTAssertEqual(sequence.narrowlySupersededRuleCount, 1)
        XCTAssertTrue(sequence.predecessorAuthorityPairRemainsByteIdentical)
        XCTAssertTrue(
            sequence.allRelationAPISemanticAndSecurityContractsRemainUnchanged
        )
        XCTAssertTrue(sequence.timeoutRepairIsTheOnlyAuthorizedInterveningPatch)
        XCTAssertNil(sequence.timeoutRepairMergeRevision)
        XCTAssertTrue(sequence.requiredClosureHeadEqualsObservedTimeoutRepairMerge)
        XCTAssertTrue(sequence.requiredRepairMergeSignatureVerified)
        XCTAssertEqual(sequence.requiredRepairMergeSignatureReason, "valid")
        XCTAssertTrue(
            sequence.requiredRepairMergeHistoryPreservingTwoParentShape
        )
        XCTAssertEqual(sequence.requiredRepairMergeParentCount, 2)
        XCTAssertEqual(
            sequence.requiredRepairMergeParent1Revision,
            frozen.exactMainRevision
        )
        XCTAssertTrue(sequence.requiredRepairMergeParent2DirectChildOfParent1)
        XCTAssertTrue(sequence.requiredRepairMergeParent2TreeEqualsMergeTree)
        XCTAssertTrue(sequence.requiredRepairMergeTreeEqualsReviewedHeadTree)
        XCTAssertEqual(sequence.requiredClosureRunEvent, "push")
        XCTAssertEqual(sequence.requiredClosureRunRef, "refs/heads/main")
        XCTAssertEqual(sequence.requiredClosureRunAttempt, 1)
        XCTAssertEqual(sequence.requiredClosureMatchingRunCount, 1)
        XCTAssertEqual(sequence.requiredClosureConclusion, "success")
        XCTAssertTrue(sequence.pullRequestGreenIsInsufficient)
        XCTAssertFalse(sequence.currentSuccessorMechanicsAuthorized)
        XCTAssertFalse(sequence.currentSuccessorImplementationAuthorized)
        XCTAssertTrue(sequence.conditionalPostClosureSuccessorRebuildAuthorized)
        XCTAssertEqual(
            sequence.conditionalAuthorizationPredicate,
            "unique_attempt1_direct_push_main_run_for_observed_timeout_repair_merge_is_successful"
        )
        XCTAssertTrue(
            sequence.conditionalAuthorizationRequiresAllTopologyAndRunFacts
        )
        XCTAssertTrue(sequence.separateImplementationReviewAndTestingRequired)
        XCTAssertFalse(sequence.separatePostClosureAuthorityPairRequired)

        let closure = authority.expectedRepairClosure
        XCTAssertEqual(closure.rootTestCount, 89)
        XCTAssertEqual(closure.isolatedTestCount, 6)
        XCTAssertEqual(closure.focusedWholeTestCount, 95)
        XCTAssertEqual(closure.retainedLiveTestCount, 46)
        XCTAssertEqual(closure.aggregateTestCount, 141)
        XCTAssertEqual(closure.embeddedProvenanceRecordCount, 530)
        XCTAssertEqual(closure.predecessorEmbeddedProvenanceRecordCount, 528)
        XCTAssertEqual(closure.newEmbeddedSourceRecordCount, 2)
        XCTAssertEqual(closure.timeoutMinutes, 90)
        XCTAssertEqual(closure.repairAuthorityTestCount, 1)
        XCTAssertEqual(
            closure.newSuccessorRelationMechanicsInvocationCount,
            0
        )
        XCTAssertTrue(closure.closureIsExpectedNotObserved)
        XCTAssertFalse(closure.closureSuccessEstablished)

        let work = authority.authorityTestWorkCeiling
        XCTAssertEqual(work.maximumExternalFocusedTestDurationMilliseconds, 5_000)
        XCTAssertEqual(
            work.preFreezeFocusedTestDurationMillisecondsSamples,
            [15, 18]
        )
        XCTAssertEqual(
            work.preFreezeMaximumObservedFocusedTestDurationMilliseconds,
            18
        )
        XCTAssertTrue(work.externalMeasurementRequiredBeforeCanonicalFreeze)
        XCTAssertTrue(work.preFreezeExternalMeasurementRequirementSatisfied)
        XCTAssertTrue(work.samplesApplyToPremeasurementCandidates)
        XCTAssertTrue(work.finalPinnedByteRuntimeRequiresExternalValidation)
        XCTAssertFalse(work.finalPinnedByteExternalValidationCompleted)
        XCTAssertEqual(work.externalMeasurementPassCount, 2)
        XCTAssertEqual(work.externalMeasurementFailureCount, 0)
        XCTAssertTrue(work.externalMeasurementUsedCachedDependencies)
        XCTAssertFalse(work.externalMeasurementWasHosted)
        XCTAssertFalse(work.externalMeasurementWasCleanBuildDelta)
        XCTAssertFalse(work.wallClockAssertionInsideTest)
        XCTAssertEqual(work.boundedMutationCaseCount, 32)
        XCTAssertEqual(work.maximumBoundedMutationCaseCount, 32)
        XCTAssertEqual(work.recursiveJSONValuePathEnumerationCount, 0)
        XCTAssertTrue(work.deterministicWorkCeilingEnforcedByTest)

        let falseCeilings = [
            authority.authorityCeiling.semanticFailureEstablished,
            authority.authorityCeiling
                .relationImplementationPerformedByAuthorityValue,
            authority.authorityCeiling
                .topologyVerifierExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.helperExecutionPerformedByAuthorityValue,
            authority.authorityCeiling
                .classifierExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.matrixExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.filesystemReadPerformedByAuthorityValue,
            authority.authorityCeiling.filesystemWritePerformedByAuthorityValue,
            authority.authorityCeiling.processExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.gitExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.compilerExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.networkExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.modelExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.leaseExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.fixtureExecutionPerformedByAuthorityValue,
            authority.authorityCeiling.rerunAuthorized,
            authority.authorityCeiling.retryAuthorized,
            authority.authorityCeiling.replacementExecutionAuthorized,
            authority.authorityCeiling.successorMechanicsAuthorized,
            authority.authorityCeiling.successorRelationMeasurementAuthorized,
            authority.authorityCeiling.successorRelationConfirmationAuthorized,
            authority.authorityCeiling.successorRelationCanaryAuthorized,
            authority.authorityCeiling.productUseAuthorized,
            authority.authorityCeiling.publicationAuthorized,
        ]
        XCTAssertTrue(falseCeilings.allSatisfy { !$0 })

        XCTAssertEqual(Authority.canonicalByteCount, 18_515)
        XCTAssertEqual(
            Authority.canonicalSHA256,
            "667a8c408635407eecb5cc2fd8381baf1cc1f28fc771ff541c66b3816b97a5f4"
        )
        let canonical = try authority.canonicalData()
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)

        let mutations: [([String], Any)] = [
            (["schemaVersion"], 2),
            (["schemaID"], "drift"),
            (["authorityID"], "drift"),
            (["authorityKind"], "drift"),
            (["frozenRun166ExactFiveIdentity", "exactMainRevision"], String(repeating: "0", count: 40)),
            (["frozenRun166ExactFiveIdentity", "exactMainTree"], String(repeating: "0", count: 40)),
            (["frozenRun166ExactFiveIdentity", "relationAuthorityCanonicalByteCount"], 1),
            (["repositoryIdentity", "pullRequestNumber"], 0),
            (["repositoryIdentity", "githubSignatureVerified"], false),
            (["workflowRun", "runID"], 0),
            (["workflowRun", "conclusion"], "failure"),
            (["activeRootJob", "conclusion"], "failure"),
            (["reviewedMainJob", "conclusion"], "failure"),
            (["activeRootTestObservation", "passCount"], 0),
            (["activeRootLogIdentity", "byteCount"], 1),
            (["reviewedMainLogIdentity", "sha256"], String(repeating: "0", count: 64)),
            (["maximumExecutionTimeAnnotation", "text"], "drift"),
            (["cancellationAnnotation", "exactOccurrenceCount"], 0),
            (["cancellationLogLine", "zeroBasedByteOffset"], 0),
            (["focusedObservation", "durationSeconds"], 0),
            (["focusedObservation", "rootTestCount"], 0),
            (["partialLiveObservation", "completedLiveTestCount"], 46),
            (["successfulLiveBaseline", "liveDurationSeconds"], 0),
            (["timeoutClassification", "exactClassification"], "drift"),
            (["runtimeDerivation", "lowerBoundWithNewAuthorityTestCeilingSeconds"], 0),
            (["repairAuthority", "reviewedMainTimeoutAfterMinutes"], 75),
            (["successorSequenceAmendment", "currentSuccessorMechanicsAuthorized"], true),
            (["expectedRepairClosure", "rootTestCount"], 88),
            (["authorityTestWorkCeiling", "preFreezeMaximumObservedFocusedTestDurationMilliseconds"], 0),
            (["authorityCeiling", "semanticFailureEstablished"], true),
            (["orderedNextActions"], ["drift"]),
            (["status"], "drift"),
        ]
        XCTAssertEqual(mutations.count, work.boundedMutationCaseCount)
        let canonicalObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        for mutation in mutations {
            var object = canonicalObject
            replaceValue(in: &object, path: mutation.0, with: mutation.1)
            let data = try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )
            XCTAssertThrowsError(try Authority.decodeCanonical(data))
        }

        let oversized = Data(
            repeating: 0x20,
            count: 131_073
        )
        XCTAssertThrowsError(try Authority.decodeCanonical(oversized)) { error in
            XCTAssertEqual(
                error as? PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityError,
                .oversizedEncoding
            )
        }
    }

    private func assertLog(
        _ log: Authority.ConnectorDecodedUTF8LogIdentity,
        bytes: Int,
        lines: Int,
        bomCount: Int,
        bomOffsets: [Int],
        offsetsAreBound: Bool,
        sha256: String
    ) {
        XCTAssertEqual(log.representation, "connector_decoded_UTF8_job_log")
        XCTAssertEqual(log.byteCount, bytes)
        XCTAssertEqual(log.lfByteCount, lines)
        XCTAssertEqual(log.crByteCount, 0)
        XCTAssertTrue(log.terminalLFPresent)
        XCTAssertEqual(log.utf8BOMCount, bomCount)
        XCTAssertEqual(log.utf8BOMByteOffsets, bomOffsets)
        XCTAssertEqual(log.utf8BOMByteOffsetsAreBound, offsetsAreBound)
        XCTAssertEqual(log.sha256, sha256)
        XCTAssertTrue(log.repeatFetchExactlyEqual)
        XCTAssertFalse(log.rawArchiveBytesBound)
        XCTAssertFalse(log.rawArchiveRetained)
    }

    private func assertTextEvidence(
        _ evidence: Authority.ExactTextEvidence,
        expectedText: String,
        expectedBytes: Int,
        expectedSHA256: String
    ) {
        let data = Data(expectedText.utf8)
        XCTAssertEqual(evidence.text, expectedText)
        XCTAssertEqual(data.count, expectedBytes)
        XCTAssertEqual(evidence.utf8ByteCount, expectedBytes)
        XCTAssertEqual(hexString(SHA256.hash(data: data)), expectedSHA256)
        XCTAssertEqual(evidence.sha256, expectedSHA256)
        XCTAssertEqual(evidence.exactOccurrenceCount, 1)
    }

    private func replaceValue(
        in object: inout [String: Any],
        path: [String],
        with value: Any
    ) {
        precondition(!path.isEmpty)
        if path.count == 1 {
            object[path[0]] = value
            return
        }
        var child = object[path[0]] as! [String: Any]
        replaceValue(in: &child, path: Array(path.dropFirst()), with: value)
        object[path[0]] = child
    }

    private func duration(_ start: String, _ end: String) throws -> Int {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return Int(
            try XCTUnwrap(formatter.date(from: end)).timeIntervalSince(
                try XCTUnwrap(formatter.date(from: start))
            )
        )
    }

    private func hexString<D: Digest>(_ digest: D) -> String {
        digest.map { String(format: "%02x", $0) }.joined()
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
