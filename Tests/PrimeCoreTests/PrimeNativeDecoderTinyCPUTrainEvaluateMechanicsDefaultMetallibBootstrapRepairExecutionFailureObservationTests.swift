// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_repair_execution_failure_observation_v1"
        )
        XCTAssertEqual(
            observation.observationKind,
            "exact_main_stage2_metallib_bootstrap_repair_launcher_preflight_false_positive_observation"
        )
        XCTAssertEqual(
            observation.predecessorAuthorityID,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            observation.predecessorAuthorityCanonicalSHA256,
            "2c397195129a550817996f8914c036ae39ede13d5c67186fe0c74a2daf99f7de"
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 87)
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(
            repository.revision,
            "6b5233ae0589de539e91f613e7990de3ca5b5833"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "8504f0af692e19d3337cec00f2c624537bc7386a",
                "cf93879f650f1708e51478cc630ac9a753226471",
            ]
        )
        XCTAssertEqual(
            repository.tree,
            "8d8944b8b73547c97822b50e06da895a1fb29f1f"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.tree)
        XCTAssertEqual(repository.mergedAt, "2026-08-11T22:59:38Z")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertEqual(
            repository.mergeCommitSignatureVerifiedAt,
            "2026-08-11T23:42:09Z"
        )
        XCTAssertTrue(repository.exactMainRefStillMatchedAtAudit)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "bdb0a217ec36611373ed7b25b982d78ee97f9f82d9ab274507978ab728194c2d"
        )

        let sources = observation.observedSourceBindings
        XCTAssertEqual(sources.count, 10)
        XCTAssertEqual(
            sources.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests.swift",
                "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
            ]
        )
        XCTAssertEqual(Set(sources.map(\.path)).count, sources.count)
        XCTAssertTrue(
            sources.allSatisfy { source in
                ["100644", "100755"].contains(source.gitMode)
                    && source.gitBlob.utf8.count == 40
                    && isLowercaseHex(source.gitBlob)
                    && source.byteCount > 0
                    && source.sha256.utf8.count == 64
                    && isLowercaseHex(source.sha256)
                    && !source.claimScope.isEmpty
            }
        )
        XCTAssertEqual(sources[0].gitBlob, "ab69f596f6b77ac51a5ccbbb3f8ad95c610308a5")
        XCTAssertEqual(sources[1].gitBlob, "fd339c3819059050dcd31112023e169e22f9fbac")
        XCTAssertEqual(sources[2].gitBlob, "b3c943d2bce9fd6d8b32dcd885fc67768760327f")
        XCTAssertEqual(sources[4].byteCount, 51_385)
        XCTAssertEqual(sources[5].byteCount, 29_596)
        XCTAssertEqual(sources[6].byteCount, 16_695)
        XCTAssertEqual(
            sources[6].sha256,
            "89ff93473e36ecc8a1fad38ef46c792ad0d12edee2508d91101d4df336cf7c2c"
        )

        let run = observation.runIdentity
        XCTAssertEqual(run.workflowID, 329_017_041)
        XCTAssertEqual(run.workflowName, "Prime active-root quarantine")
        XCTAssertEqual(run.runID, 31_544_702_133)
        XCTAssertEqual(run.runNumber, 71)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.revision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-11T22:59:40Z")
        XCTAssertEqual(run.terminalUpdatedAt, "2026-08-11T23:41:02Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.checkSuiteID, 85_570_388_096)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 93_954_592_456)
        XCTAssertEqual(active.runnerID, 1_000_001_697)
        XCTAssertEqual(active.runnerName, "GitHub Actions 1000001697")
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.orderedSteps.map(\.number), Array(1 ... 7))
        XCTAssertTrue(active.orderedSteps.allSatisfy { $0.conclusion == "success" })
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.id, 93_955_091_811)
        XCTAssertEqual(reviewed.runnerID, 1_000_001_698)
        XCTAssertEqual(reviewed.runnerName, "GitHub Actions 1000001698")
        XCTAssertEqual(reviewed.conclusion, "failure")
        XCTAssertEqual(reviewed.orderedSteps.map(\.number), Array(1 ... 7))
        XCTAssertEqual(
            reviewed.orderedSteps.map(\.conclusion),
            [
                "success", "success", "success", "success", "success",
                "failure", "success",
            ]
        )
        XCTAssertEqual(
            reviewed.orderedSteps[5].name,
            "Run the Prime-owned decoder on live Metal"
        )
        XCTAssertEqual(reviewed.checkAnnotationCount, 1)
        XCTAssertEqual(reviewed.checkAnnotationPath, ".github")
        XCTAssertEqual(reviewed.checkAnnotationStartLine, 74_946)
        XCTAssertEqual(reviewed.checkAnnotationEndLine, 74_946)
        XCTAssertEqual(reviewed.checkAnnotationLevel, "failure")
        XCTAssertEqual(
            reviewed.checkAnnotationMessage,
            "Process completed with exit code 2."
        )

        let toolchain = observation.runnerToolchain
        XCTAssertEqual(toolchain.runnerVersion, "2.336.0")
        XCTAssertEqual(toolchain.runnerProvisionerVersion, "20260707.563")
        XCTAssertEqual(
            toolchain.runnerProvisionerCommit,
            "02667638d2b423fbc733a8e32a88b44996a3ba6e"
        )
        XCTAssertEqual(toolchain.activeRunnerImage, "macos-15-arm64")
        XCTAssertEqual(toolchain.activeRunnerImageVersion, "20260727.0256.1")
        XCTAssertEqual(toolchain.activeOperatingSystemVersion, "15.7.7")
        XCTAssertEqual(toolchain.activeOperatingSystemBuild, "24G720")
        XCTAssertEqual(toolchain.reviewedRunnerImage, "macos-26-arm64")
        XCTAssertEqual(toolchain.reviewedRunnerImageVersion, "20260728.0273.1")
        XCTAssertEqual(toolchain.reviewedOperatingSystemVersion, "26.5.2")
        XCTAssertEqual(toolchain.reviewedOperatingSystemBuild, "25F84")
        XCTAssertEqual(toolchain.reviewedArchitecture, "arm64")
        XCTAssertEqual(toolchain.xcodeVersion, "26.6")
        XCTAssertEqual(toolchain.xcodeBuildVersion, "17F113")
        XCTAssertEqual(toolchain.swiftTarget, "arm64-apple-macosx26.0")
        XCTAssertEqual(toolchain.macOSSDKVersion, "26.5")
        XCTAssertEqual(toolchain.swiftDriverVersion, "1.148.6")
        XCTAssertTrue(toolchain.exactHostedRunnerImagesRecorded)
        XCTAssertFalse(toolchain.exactPhysicalRunnerIdentityRecorded)

        assertRawLog(
            observation.activeRootRawLog,
            byteCount: 234_526,
            lfByteCount: 1_749,
            sha256:
                "4f8f50aa9bc9df36a4389e2d87b0eb91baed8ebf7761cb54729688ca3656e7e5"
        )
        assertRawLog(
            observation.reviewedMainRawLog,
            byteCount: 10_245_450,
            lfByteCount: 78_438,
            sha256:
                "53a5f1f178e1f6d46a8b14aecca09b95b79fc9121fc9f3c3a1985528e5b6efec"
        )
        assertRawLog(
            observation.secureFetchStepRawLog,
            byteCount: 4_893,
            lfByteCount: 54,
            sha256:
                "a9e9797d237f18227eac1e1a1d71c46fb6ff937637ef94383c89bc26acb34b2c"
        )
        assertRawLog(
            observation.focusedContractsStepRawLog,
            byteCount: 344_155,
            lfByteCount: 3_350,
            sha256:
                "6858e8f204000409cbbbbb023a667c57e1684fca8280ea43f693f3457e18de43"
        )
        assertRawLog(
            observation.liveStage2StepRawLog,
            byteCount: 9_890_254,
            lfByteCount: 74_946,
            sha256:
                "b122f61be5b1811176ce6a69878ac1693de1c3ee2e049f6444c5f8892ca9cb3b"
        )

        let archive = observation.rawLogArchive
        XCTAssertEqual(archive.byteCount, 1_348_689)
        XCTAssertEqual(
            archive.sha256,
            "54a7d35df9485108b3f084fc5508bdc5887b8dccb89beee2ce1fa0a6c048bd17"
        )
        XCTAssertEqual(archive.memberCount, 18)
        XCTAssertEqual(archive.members.count, archive.memberCount)
        XCTAssertEqual(
            archive.members.reduce(0) { $0 + $1.byteCount },
            archive.uncompressedByteCount
        )
        XCTAssertEqual(archive.uncompressedByteCount, 20_961_389)
        XCTAssertEqual(Set(archive.members.map(\.path)).count, archive.memberCount)
        XCTAssertTrue(archive.repeatedDownloadsWereByteIdentical)
        XCTAssertTrue(archive.memberTimestampsAreDOSZero)
        XCTAssertEqual(
            archive.members.first?.sha256,
            observation.reviewedMainRawLog.sha256
        )
        XCTAssertEqual(
            archive.members[1].sha256,
            observation.activeRootRawLog.sha256
        )
        XCTAssertNotEqual(
            archive.stage2DiagnosticMemberTimestamp,
            archive.stage2DiagnosticAggregateTimestamp
        )
        XCTAssertNotEqual(
            archive.stage2ExitMemberTimestamp,
            archive.stage2ExitAggregateTimestamp
        )

        let predecessor = observation.predecessorBoundary
        XCTAssertTrue(predecessor.activeRootGatePassed)
        XCTAssertTrue(predecessor.dependencyFreeSwiftParsePassed)
        XCTAssertEqual(predecessor.latinInvocationCount, 1)
        XCTAssertEqual(predecessor.latinCompletedTestCount, 116)
        XCTAssertEqual(predecessor.latinFailureCount, 0)
        XCTAssertEqual(predecessor.latinSkipCount, 0)
        XCTAssertEqual(predecessor.latinFinalSummaryOccurrenceCount, 2)
        XCTAssertEqual(predecessor.securePrivateDependencyFetchInvocationCount, 1)
        XCTAssertEqual(predecessor.securePrivateDependencyFetchCompletionCount, 1)
        XCTAssertEqual(predecessor.securePrivateDependencyFetchRetryCount, 0)
        XCTAssertEqual(predecessor.tlsVerificationBypassCount, 0)
        XCTAssertEqual(predecessor.focusedRootInvocationCount, 1)
        XCTAssertEqual(predecessor.focusedRootTestCount, 39)
        XCTAssertEqual(predecessor.focusedRootFailureCount, 0)
        XCTAssertEqual(predecessor.focusedRootSkipCount, 0)
        XCTAssertEqual(predecessor.focusedRootSuccessSummaryOccurrenceCount, 2)
        XCTAssertEqual(predecessor.isolatedCheckpointGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(predecessor.focusedWholeStepTestCount, 45)
        XCTAssertEqual(predecessor.focusedWholeStepFailureCount, 0)
        XCTAssertEqual(predecessor.focusedWholeStepSkipCount, 0)
        XCTAssertEqual(predecessor.offendingPredecessorPackageTestCount, 2)
        XCTAssertEqual(predecessor.offendingPredecessorPackageFailureCount, 0)
        XCTAssertEqual(predecessor.offendingPredecessorPackageSkipCount, 0)
        XCTAssertEqual(predecessor.offendingPredecessorMethodStartCount, 1)
        XCTAssertEqual(predecessor.offendingPredecessorMethodPassCount, 1)
        XCTAssertEqual(
            predecessor.observedLiveInvocationSequence,
            ["metal", "maintained_runtime", "tokenizer", "stage2"]
        )
        XCTAssertEqual(predecessor.observedLiveInvocationCounts, [1, 1, 1, 1])
        XCTAssertEqual(
            predecessor.greenPredecessorLiveSequence,
            ["metal", "maintained_runtime", "tokenizer"]
        )
        XCTAssertEqual(predecessor.greenPredecessorLiveSuccessCounts, [1, 1, 1])
        XCTAssertEqual(predecessor.metallibBuildInvocationCount, 1)
        XCTAssertEqual(predecessor.metallibBuildCompletionCount, 1)
        XCTAssertEqual(predecessor.freshMetallibCandidateCount, 1)
        XCTAssertEqual(predecessor.freshMetallibByteCount, 6_292_716)
        XCTAssertEqual(
            predecessor.freshMetallibSHA256,
            "c77ef927122ee30ece82d983db66b4b83b5a04a3977cafb07f5940a7d0255255"
        )
        XCTAssertEqual(predecessor.metalGroupTestCounts, [11, 14, 19])
        XCTAssertEqual(predecessor.metalTestCount, 44)
        XCTAssertEqual(predecessor.metalFailureCount, 0)
        XCTAssertEqual(predecessor.metalSkipCount, 0)
        XCTAssertEqual(predecessor.runtimeInvocationCount, 1)
        XCTAssertEqual(predecessor.runtimeTestCount, 1)
        XCTAssertEqual(predecessor.runtimeFailureCount, 0)
        XCTAssertEqual(predecessor.runtimeSkipCount, 0)
        assertReceipt(
            predecessor.runtimeReceipt,
            byteCount: 6_853,
            sha256:
                "5df550107d486819d132a66de422de8929ecba9a750aec528b2b1bfff9ccc90f"
        )
        XCTAssertEqual(predecessor.tokenizerInvocationCount, 1)
        XCTAssertEqual(predecessor.tokenizerTestCount, 1)
        XCTAssertEqual(predecessor.tokenizerFailureCount, 0)
        XCTAssertEqual(predecessor.tokenizerSkipCount, 0)
        assertReceipt(
            predecessor.tokenizerReceipt,
            byteCount: 7_182,
            sha256:
                "ceba20f60d3fd6d1afc0eb56bc28372aa93d52b9f3fd53b8b506d9aeda8ed0dd"
        )
        XCTAssertEqual(predecessor.predecessorLogInventoryCount, 10)
        XCTAssertEqual(predecessor.emittedPredecessorReceiptCount, 2)
        XCTAssertEqual(predecessor.completedPreStage2TestCount, 91)
        XCTAssertEqual(predecessor.preStage2FailureCount, 0)
        XCTAssertEqual(predecessor.preStage2SkipCount, 0)

        let failure = observation.launcherFailureBoundary
        XCTAssertEqual(failure.workflowOutcome, "failure")
        XCTAssertEqual(
            failure.stage2Disposition,
            "launcher_preflight_false_positive_before_metallib_discovery_staging_build_or_test"
        )
        XCTAssertEqual(failure.failedJobStepNumber, 6)
        XCTAssertEqual(
            failure.failedJobStepName,
            "Run the Prime-owned decoder on live Metal"
        )
        XCTAssertEqual(failure.launcherInvocationCount, 1)
        XCTAssertEqual(
            failure.launcherCommand,
            "bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh"
        )
        XCTAssertEqual(
            failure.validationTestClass,
            "PrimeNativeDecoderTrainingTests"
        )
        XCTAssertEqual(
            failure.validationTestMethod,
            "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"
        )
        XCTAssertEqual(
            failure.validationTestFilter,
            "PrimeNativeDecoderTrainingTests/testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"
        )
        XCTAssertEqual(failure.intendedBuildCommand, "swift build --build-tests")
        XCTAssertEqual(failure.guardCommand, "grep -Eiq")
        XCTAssertEqual(
            failure.guardRegex,
            "^Test (Case|Suite).*failed|^error:|skipped|Test skipped"
        )
        XCTAssertTrue(failure.guardCaseInsensitive)
        XCTAssertTrue(failure.guardRegexUnboundedBeforeFailedSubstring)
        XCTAssertEqual(failure.guardFailureSourceLine, 374)
        XCTAssertEqual(failure.predecessorReceiptValidationSourceLine, 376)
        XCTAssertEqual(failure.stage2MetallibDiscoverySourceLine, 383)
        XCTAssertEqual(failure.stage2FreshPathAbsenceGuardSourceLine, 495)
        XCTAssertEqual(failure.stage2WorkspaceCreationSourceLine, 501)
        XCTAssertEqual(failure.matchedPredecessorLogOrdinal, 4)
        XCTAssertEqual(failure.completedPredecessorLogScanCountBeforeFalsePositive, 3)
        XCTAssertEqual(
            failure.matchedPassingIdentifier,
            "testFailedAttemptObservationIsExactExhaustedAndPure"
        )
        XCTAssertTrue(failure.matchedStartedLine.hasSuffix("started."))
        XCTAssertTrue(failure.matchedPassedLine.hasSuffix("passed (0.860 seconds)."))
        XCTAssertEqual(
            failure.matchedStartedMemberTimestamp,
            "2026-08-11T23:17:30.3633930Z"
        )
        XCTAssertEqual(
            failure.matchedStartedAggregateTimestamp,
            "2026-08-11T23:17:30.3633940Z"
        )
        XCTAssertEqual(
            failure.matchedPassedMemberTimestamp,
            "2026-08-11T23:17:30.3635720Z"
        )
        XCTAssertEqual(
            failure.matchedPassedAggregateTimestamp,
            "2026-08-11T23:17:30.3635730Z"
        )
        XCTAssertEqual(failure.matchedIdentifierStartCount, 1)
        XCTAssertEqual(failure.matchedIdentifierPassCount, 1)
        XCTAssertEqual(failure.matchedPackageTestCount, 2)
        XCTAssertEqual(failure.matchedPackageFailureCount, 0)
        XCTAssertEqual(failure.matchedPackageSkipCount, 0)
        XCTAssertEqual(
            failure.falsePositiveCause,
            "case_insensitive_unbounded_failed_substring_matched_passed_test_identifier"
        )
        XCTAssertEqual(
            failure.failureClassification,
            "predecessor_log_validation_false_positive_after_green_predecessors_before_stage2_metallib_discovery_or_build"
        )
        XCTAssertEqual(
            failure.exactDiagnostic,
            "prime-native-decoder-stage2-metallib-bootstrap-repair: predecessor test log failed or skipped: /Users/runner/work/_temp/prime-checkpoint-v2-io-execution-pure-tests.log"
        )
        XCTAssertEqual(failure.processExitCode, 2)
        XCTAssertEqual(failure.exactExitMessage, "Process completed with exit code 2.")
        XCTAssertFalse(failure.predecessorReceiptValidationReached)
        XCTAssertTrue(failure.sameJobFreshMetallibWasAvailableFromPredecessor)
        XCTAssertFalse(failure.sameJobFreshMetallibWasInspectedByStage2Launcher)
        XCTAssertFalse(failure.stage2RepairLauncherReachedFreshMetallibDiscovery)
        XCTAssertEqual(failure.stage2MetallibDiscoveryCount, 0)
        XCTAssertEqual(failure.stage2MetallibCandidateCount, 0)
        XCTAssertEqual(failure.stage2StagedDestinationCount, 0)
        XCTAssertEqual(failure.stage2MetallibCopyCount, 0)
        XCTAssertEqual(failure.stage2ScratchPathCreationCount, 0)
        XCTAssertEqual(failure.stage2CachePathCreationCount, 0)
        XCTAssertEqual(failure.stage2ConfigPathCreationCount, 0)
        XCTAssertEqual(failure.stage2SecurityPathCreationCount, 0)
        XCTAssertEqual(failure.stage2PrivateWorkingDirectoryCreationCount, 0)
        XCTAssertEqual(failure.stage2TestLogPathCreationCount, 0)
        XCTAssertEqual(failure.stage2BuildInvocationCount, 0)
        XCTAssertEqual(failure.stage2BuildTestsInvocationCount, 0)
        XCTAssertEqual(failure.stage2DirectXCTestInvocationCount, 0)
        XCTAssertEqual(failure.stage2TestStartCount, 0)
        XCTAssertEqual(failure.stage2TestPassCount, 0)
        XCTAssertEqual(failure.stage2TestFailureCount, 0)
        XCTAssertEqual(failure.stage2TestSkipCount, 0)
        XCTAssertEqual(failure.stage2RepairReceiptCount, 0)
        XCTAssertFalse(failure.stage2MechanicsEstablished)
        XCTAssertFalse(failure.stage2BootstrapRepairEstablished)
        XCTAssertTrue(failure.failureOccurredAfterGreenPredecessors)
        XCTAssertTrue(failure.failureOccurredBeforeTargetTestBundleResolution)
        XCTAssertFalse(failure.predecessorTestFailureObserved)
        XCTAssertFalse(failure.stage2MechanicsTestFailureObserved)
        XCTAssertFalse(failure.metallibDiscoveryOrBuildFailureObserved)
        XCTAssertTrue(failure.launcherClassifierFalsePositiveObserved)
        XCTAssertFalse(failure.launcherSourceMutationPerformed)

        let artifacts = observation.artifactBoundary
        XCTAssertEqual(artifacts.actionsArtifactsTotalCount, 0)
        XCTAssertTrue(artifacts.actionsArtifactsArrayExactlyEmpty)
        XCTAssertEqual(artifacts.publishedWorkflowArtifactCount, 0)
        XCTAssertEqual(artifacts.artifactUploadStepCount, 0)
        XCTAssertTrue(artifacts.runLogArchiveObserved)
        XCTAssertFalse(artifacts.runLogArchiveIsActionsArtifact)
        XCTAssertFalse(artifacts.freshMetallibRetainedAfterJob)
        XCTAssertFalse(artifacts.freshMetallibArtifactProvenanceEstablished)
        XCTAssertTrue(artifacts.runtimeReceiptEmitted)
        XCTAssertTrue(artifacts.tokenizerReceiptEmitted)
        XCTAssertFalse(artifacts.stage2RepairReceiptEmitted)
        XCTAssertTrue(artifactFalseClaims(artifacts).allSatisfy { !$0 })

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.predecessorExecutionAuthorityConsumed)
        XCTAssertTrue(ceiling.predecessorExecutionAuthorityExhausted)
        XCTAssertTrue(ceiling.failureObservationAuthorizesNothing)
        XCTAssertTrue(ceiling.distinctRepairAuthorityRequired)
        XCTAssertTrue(ceiling.launcherSourceMustRemainPreservedForAudit)
        XCTAssertTrue(ceiling.consumedStage2LiveInvocationRetirementRequired)
        XCTAssertTrue(ceiling.stage3RemainsBlocked)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(
            observation.status,
            "FAIL_exact_main_stage2_launcher_preflight_false_positive_no_stage2_test_no_receipt_no_rerun_no_actions_or_stage2_artifact_no_downstream_authority"
        )
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 5)
        XCTAssertEqual(
            observation.orderedRequiredSeparateActions.first,
            "retire_consumed_stage2_live_invocation_without_rerun"
        )
        XCTAssertTrue(
            observation.orderedRequiredSeparateActions.contains(
                "separately_authorize_bounded_predecessor_log_classifier_repair"
            )
        )

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservation.swift"
        )
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        let importLines = sourceText.split(separator: "\n").filter {
            $0.hasPrefix("import ")
        }.map(String.init)
        XCTAssertEqual(importLines, ["import Foundation"])
        for forbidden in [
            "import CoreGraphics", "import Metal", "import MLX",
            "FileManager.", "FileHandle.", "URLSession", "Process(",
            "posix_spawn", "execve(",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        let testText = try String(contentsOfFile: #filePath, encoding: .utf8)
        XCTAssertEqual(
            testText.components(separatedBy: "func " + "test").count - 1,
            1
        )

        requireSendable(Observation.self)
        let canonical = try observation.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(observation))
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            "2184710f59bc2b4625bb0a74f5f835c859fada79406ffc957b5ffca4861a9926"
        )
        let decoded = try Observation.decodeCanonical(canonical)
        XCTAssertEqual(decoded, observation)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 350)
        XCTAssertGreaterThan(dictionaryPaths.count, 20)
        XCTAssertGreaterThan(scalarPaths.count, 250)

        var regularDecodedDriftCount = 0
        var mutationCount = 0
        var nullCount = 0
        var removalCount = 0
        for path in valuePaths {
            let mutated = replacingValue(
                in: object,
                at: path,
                with: mutateJSONValue
            )
            let mutationData = try assertCanonicalRejects(
                mutated,
                label: "mutated \(pathLabel(path))"
            )
            mutationCount += 1
            if let loose = try? JSONDecoder().decode(
                Observation.self,
                from: mutationData
            ), loose != observation {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }

            _ = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                label: "null \(pathLabel(path))"
            )
            nullCount += 1

            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
            removalCount += 1
        }
        XCTAssertEqual(mutationCount, valuePaths.count)
        XCTAssertEqual(nullCount, valuePaths.count)
        XCTAssertEqual(removalCount, valuePaths.count)
        XCTAssertGreaterThan(regularDecodedDriftCount, 250)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary[
                        "unknown_stage2_bootstrap_failure_field_\(index)"
                    ] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))"
            )
            let loose = try JSONDecoder().decode(
                Observation.self,
                from: unknownData
            )
            XCTAssertEqual(loose, observation)
            unknownFieldCount += 1
        }
        XCTAssertEqual(unknownFieldCount, dictionaryPaths.count)

        try assertNoncanonicalEncodingsReject(canonical, object: object)
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)

        var label: String {
            switch self {
            case let .key(key):
                return key
            case let .index(index):
                return "[\(index)]"
            }
        }
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map(\.label).joined(separator: ".")
    }

    private func allValuePaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
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

    private func allScalarPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allScalarPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)]
                )
            }
        }
        return [prefix]
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else {
            return transform(value)
        }
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
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
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

    private func mutateJSONValue(_ value: Any) -> Any {
        if let string = value as? String {
            return string + "__mutation"
        }
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
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(
            try Observation.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
        return data
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
        let slashEscapedData = try XCTUnwrap(slashEscaped.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(slashEscapedData))

        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let openingBrace = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: openingBrace)
        )
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

    private func assertRawLog(
        _ log: PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1,
        byteCount: Int,
        lfByteCount: Int,
        sha256: String
    ) {
        XCTAssertEqual(log.byteCount, byteCount)
        XCTAssertEqual(log.lfByteCount, lfByteCount)
        XCTAssertEqual(log.splitLineCountExcludingTerminalEmpty, lfByteCount)
        XCTAssertEqual(
            log.newlineDelimitedComponentCountIncludingTerminalEmpty,
            lfByteCount + 1
        )
        XCTAssertEqual(log.sha256, sha256)
        XCTAssertEqual(log.utf8BOMHex, "efbbbf")
        XCTAssertTrue(log.startsWithUTF8BOM)
        XCTAssertTrue(log.usesLFOnly)
        XCTAssertTrue(log.endsWithLF)
    }

    private func assertReceipt(
        _ receipt: PrimeNativeDecoderStage2BootstrapFailureReceiptIdentityV1,
        byteCount: Int,
        sha256: String
    ) {
        XCTAssertEqual(receipt.count, 1)
        XCTAssertEqual(receipt.jsonByteCount, byteCount)
        XCTAssertEqual(receipt.jsonSHA256, sha256)
        XCTAssertTrue(receipt.outcomeEstablished)
        XCTAssertEqual(receipt.metallibByteCount, 6_292_716)
        XCTAssertEqual(
            receipt.metallibSHA256,
            "c77ef927122ee30ece82d983db66b4b83b5a04a3977cafb07f5940a7d0255255"
        )
        XCTAssertFalse(receipt.loadedMetallibIdentityIndependentlyObserved)
        XCTAssertFalse(receipt.metallibArtifactProvenanceEstablished)
    }

    private func artifactFalseClaims(
        _ artifacts: PrimeNativeDecoderStage2BootstrapFailureArtifactBoundaryV1
    ) -> [Bool] {
        [
            artifacts.runLogArchiveIsActionsArtifact,
            artifacts.jobLogsRetainedInRepository,
            artifacts.durableJobLogPublicationEstablished,
            artifacts.freshMetallibRetainedAfterJob,
            artifacts.freshMetallibArtifactProvenanceEstablished,
            artifacts.stage2RepairReceiptEmitted,
            artifacts.checkpointArtifactCreated,
            artifacts.checkpointArtifactUploaded,
            artifacts.checkpointArtifactRetained,
            artifacts.checkpointArtifactProvenanceEstablished,
        ]
    }

    private func authorityFalseClaims(
        _ ceiling: PrimeNativeDecoderStage2BootstrapFailureAuthorityCeilingV1
    ) -> [Bool] {
        [
            ceiling.rerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.workflowMutationBeyondRequiredRetirementAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.predecessorLogClassifierRepairAuthorized,
            ceiling.tlsVerificationBypassAuthorized,
            ceiling.credentialMutationAuthorized,
            ceiling.newMetallibBuildAuthorized,
            ceiling.stage2ReexecutionAuthorized,
            ceiling.stage2SuccessEstablished,
            ceiling.stage2RepairReceiptPublicationAuthorized,
            ceiling.workflowArtifactUploadAuthorized,
            ceiling.checkpointReadEstablished,
            ceiling.checkpointWriteEstablished,
            ceiling.checkpointRoundTripEstablished,
            ceiling.checkpointArtifactAvailabilityEstablished,
            ceiling.checkpointArtifactRetentionEstablished,
            ceiling.checkpointArtifactProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.native300MTrainingEstablished,
            ceiling.trajectoryExactResumeEstablished,
            ceiling.trainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage3AuthorityEstablished,
        ]
    }

    private func isLowercaseHex(_ value: String) -> Bool {
        !value.isEmpty
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
