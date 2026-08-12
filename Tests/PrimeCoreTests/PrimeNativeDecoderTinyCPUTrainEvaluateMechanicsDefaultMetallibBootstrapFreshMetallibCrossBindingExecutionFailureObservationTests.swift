// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_cross_binding_execution_failure_observation_v1"
        )
        XCTAssertEqual(
            observation.observationKind,
            "exact_main_stage2_fresh_metallib_cross_binding_evidence_surface_failure_observation"
        )
        XCTAssertEqual(
            observation.predecessorAuthorityID,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            observation.predecessorAuthorityCanonicalSHA256,
            "9c94ceeca77c3fc5173adfa41f9965d33c3a78f8d975b639dd3dc0aa2c2ed99b"
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 89)
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(
            repository.revision,
            "050c0e4c60df4a1d0bd3dbba1f194f425609cb1b"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "775b247fb8c1f0e3c28d01fce281d8d29bbb4dd1",
                "f34057921b53af80ddb40c0fd89fa4ee0ddbce85",
            ]
        )
        XCTAssertEqual(
            repository.tree,
            "ea5a8da68dd9539cdb78b5203da796941c5495a8"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.tree)
        XCTAssertEqual(repository.mergedAt, "2026-08-12T01:59:55Z")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertEqual(
            repository.mergeCommitSignatureVerifiedAt,
            "2026-08-12T02:00:42Z"
        )
        XCTAssertTrue(repository.exactMainRefStillMatchedAtAudit)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "643c3de86ac22c478750f052bdf1db77bb3e634623154e8898044792ef09d02f"
        )

        let sources = observation.observedSourceBindings
        XCTAssertEqual(sources.count, 10)
        XCTAssertEqual(
            sources.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-metal.sh",
                ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift",
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
        XCTAssertEqual(sources[0].gitBlob, "4ee3891f06d7e4b9e0e7cfdee93a0f5ed90ae3b0")
        XCTAssertEqual(sources[1].gitBlob, "418d2d2753cee38e0b3558ad45e1e09865ffd11d")
        XCTAssertEqual(sources[2].gitBlob, "45fc1f82ecfe14a6a9e98c345706f75b37c2d1cb")
        XCTAssertEqual(sources[3].gitBlob, "aa71ada76c09fcb68a4795fc37e3e9dbea0e56ea")
        XCTAssertEqual(sources[5].byteCount, 66_167)
        XCTAssertEqual(sources[6].byteCount, 35_453)
        XCTAssertEqual(sources[7].byteCount, 1_054)
        XCTAssertEqual(
            sources[2].sha256,
            "3b8a0790b521de9c6ca03760aef8e9bbece4d46f6d1f8505dae44fc9a559d185"
        )

        let run = observation.runIdentity
        XCTAssertEqual(run.workflowID, 329_017_041)
        XCTAssertEqual(run.workflowName, "Prime active-root quarantine")
        XCTAssertEqual(run.runID, 31_555_440_908)
        XCTAssertEqual(run.runNumber, 75)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.revision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-12T01:59:57Z")
        XCTAssertEqual(run.terminalUpdatedAt, "2026-08-12T02:42:08Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.checkSuiteID, 85_598_166_484)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 93_986_794_547)
        XCTAssertEqual(active.runnerID, 1_000_001_703)
        XCTAssertEqual(active.runnerName, "GitHub Actions 1000001703")
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.orderedSteps.map(\.number), Array(1 ... 7))
        XCTAssertTrue(active.orderedSteps.allSatisfy { $0.conclusion == "success" })
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.id, 93_987_253_841)
        XCTAssertEqual(reviewed.runnerID, 1_000_001_704)
        XCTAssertEqual(reviewed.runnerName, "GitHub Actions 1000001704")
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
        XCTAssertEqual(reviewed.checkAnnotationStartLine, 74_948)
        XCTAssertEqual(reviewed.checkAnnotationEndLine, 74_948)
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
            byteCount: 236_478,
            lfByteCount: 1_755,
            sha256:
                "2d0839aafcb251a967a181907251ef5f26f4b5d85f4ad69f8c6fcbb38222bf61"
        )
        assertRawLog(
            observation.reviewedMainRawLog,
            byteCount: 10_250_415,
            lfByteCount: 78_468,
            sha256:
                "8ebdef95e509637be4286d5d2dc3533805c97c63d7f626402e991a970838237b"
        )
        assertRawLog(
            observation.secureFetchStepRawLog,
            byteCount: 4_893,
            lfByteCount: 54,
            sha256:
                "63625513e2a698f208d6fd3783036842ab0d53f976ac6af8e1714c16f78af11f"
        )
        assertRawLog(
            observation.focusedContractsStepRawLog,
            byteCount: 348_841,
            lfByteCount: 3_378,
            sha256:
                "fcaf74ba6119764649030408235e13e662b57988e68acb9c98d4f3d4515636cd"
        )
        assertRawLog(
            observation.liveStage2StepRawLog,
            byteCount: 9_890_533,
            lfByteCount: 74_948,
            sha256:
                "278f5f0b53e71489bee1da2c9ab780563e8f2a8800c31a66ad47464455219eba"
        )

        let archive = observation.rawLogArchive
        XCTAssertEqual(archive.byteCount, 1_341_817)
        XCTAssertEqual(
            archive.sha256,
            "c7ce5e5ee05c21795ba15a235038ae9a23b66fb486e5a3448c3905a86bf6d214"
        )
        XCTAssertEqual(archive.memberCount, 18)
        XCTAssertEqual(archive.members.count, archive.memberCount)
        XCTAssertEqual(
            archive.members.reduce(0) { $0 + $1.byteCount },
            archive.uncompressedByteCount
        )
        XCTAssertEqual(archive.uncompressedByteCount, 20_975_223)
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
        XCTAssertEqual(predecessor.workflowAuthoredRetryCount, 0)
        XCTAssertEqual(predecessor.separateSecureFetchRetryStepCount, 0)
        XCTAssertEqual(predecessor.gitInternalSubmoduleRetryCount, 0)
        XCTAssertEqual(predecessor.priorRunGitInternalSubmoduleRetryCount, 1)
        XCTAssertEqual(predecessor.mlxSubmoduleCloneAttemptCount, 1)
        XCTAssertEqual(predecessor.mlxCSubmoduleCloneAttemptCount, 1)
        XCTAssertEqual(predecessor.gitSubmoduleTLSFailureCount, 0)
        XCTAssertEqual(
            predecessor.secureFetchWorkflowBlockSHA256,
            "ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847"
        )
        XCTAssertEqual(predecessor.tlsVerificationBypassCount, 0)
        XCTAssertEqual(predecessor.customCAInstallationCount, 0)
        XCTAssertEqual(predecessor.focusedRootInvocationCount, 1)
        XCTAssertEqual(predecessor.focusedRootTestCount, 41)
        XCTAssertEqual(predecessor.focusedRootFailureCount, 0)
        XCTAssertEqual(predecessor.focusedRootSkipCount, 0)
        XCTAssertEqual(predecessor.focusedRootSuccessSummaryOccurrenceCount, 2)
        XCTAssertEqual(predecessor.isolatedCheckpointGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(predecessor.focusedWholeStepTestCount, 47)
        XCTAssertEqual(predecessor.focusedWholeStepFailureCount, 0)
        XCTAssertEqual(predecessor.focusedWholeStepSkipCount, 0)
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
        XCTAssertEqual(predecessor.freshMetallibByteCount, 6_292_684)
        XCTAssertEqual(
            predecessor.freshMetallibSHA256,
            "0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994"
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
                "ee8dc3c019344a781d2d4bf04bd944a7348522e6b02de85a9a6beff180635e23"
        )
        XCTAssertEqual(predecessor.tokenizerInvocationCount, 1)
        XCTAssertEqual(predecessor.tokenizerTestCount, 1)
        XCTAssertEqual(predecessor.tokenizerFailureCount, 0)
        XCTAssertEqual(predecessor.tokenizerSkipCount, 0)
        assertReceipt(
            predecessor.tokenizerReceipt,
            byteCount: 7_182,
            sha256:
                "665878cbd3b2edf76d684f4185601fd3cb676320256d2d4e00d40f66d38b74a2"
        )
        XCTAssertEqual(predecessor.predecessorLogInventoryCount, 10)
        XCTAssertEqual(predecessor.emittedPredecessorReceiptCount, 2)
        XCTAssertEqual(predecessor.completedPreStage2TestCount, 93)
        XCTAssertEqual(predecessor.preStage2FailureCount, 0)
        XCTAssertEqual(predecessor.preStage2SkipCount, 0)

        let failure = observation.launcherFailureBoundary
        XCTAssertEqual(failure.workflowOutcome, "failure")
        XCTAssertEqual(
            failure.stage2Disposition,
            "fresh_metallib_discovery_completed_then_cross_binding_log_channel_guard_failed_before_receipt_validation_staging_build_or_test"
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
        XCTAssertEqual(failure.classifierCommand, "grep -Eq")
        XCTAssertEqual(
            failure.classifierRegex,
            "^Test Case '[^']+' failed \\(\u{7c}^Test Suite '[^']+' failed at \u{7c}^error:\u{7c}^Test Case '[^']+' skipped \\(\u{7c} : Test skipped - "
        )
        XCTAssertEqual(failure.classifierAcceptedFixtureCount, 8)
        XCTAssertEqual(failure.classifierRejectedFixtureCount, 5)
        XCTAssertEqual(failure.predecessorLogInventoryCount, 10)
        XCTAssertEqual(failure.predecessorLogScanCount, 8)
        XCTAssertTrue(failure.predecessorLogClassifierPassed)
        XCTAssertEqual(failure.stage2MetallibDiscoverySourceLine, 437)
        XCTAssertEqual(failure.stage2MetallibHashSourceLine, 465)
        XCTAssertEqual(failure.metalAggregateIdentityEmissionSourceLine, 159)
        XCTAssertEqual(failure.metalXCTestTeeSourceLines, [162, 163])
        XCTAssertEqual(failure.crossBindingGuardSourceLines, [471, 472, 473])
        XCTAssertEqual(failure.predecessorReceiptValidationSourceLine, 475)
        XCTAssertEqual(failure.stage2FreshPathAbsenceGuardSourceLine, 549)
        XCTAssertEqual(failure.stage2WorkspaceCreationSourceLine, 555)
        XCTAssertEqual(failure.stage2BuildSourceLine, 585)
        XCTAssertEqual(failure.stage2CopySourceLines, [642, 643])
        XCTAssertEqual(failure.stage2DirectXCTestSourceLines, [674, 675, 676])
        XCTAssertEqual(failure.aggregateMetalIdentityCount, 1)
        XCTAssertEqual(failure.metalXCTestLogIdentityCount, 0)
        XCTAssertEqual(failure.discoveredMetallibByteCount, 6_292_684)
        XCTAssertEqual(
            failure.discoveredMetallibSHA256,
            "0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994"
        )
        XCTAssertTrue(failure.runtimeReceiptMetallibIdentityMatched)
        XCTAssertTrue(failure.tokenizerReceiptMetallibIdentityMatched)
        XCTAssertFalse(failure.metallibIdentityDivergenceObserved)
        XCTAssertEqual(
            failure.deterministicLogChannelCause,
            "metal_identity_bare_echo_precedes_xctest_tee_so_aggregate_has_identity_but_xctest_only_metal_log_does_not"
        )
        XCTAssertEqual(
            failure.failureClassification,
            "deterministic_evidence_capture_scope_mismatch_after_fresh_metallib_discovery_no_identity_divergence"
        )
        XCTAssertEqual(
            failure.exactDiagnostic,
            "prime-native-decoder-stage2-metallib-bootstrap-repair: Metal log does not bind the fresh metallib"
        )
        XCTAssertEqual(failure.processExitCode, 2)
        XCTAssertEqual(failure.exactExitMessage, "Process completed with exit code 2.")
        XCTAssertFalse(failure.predecessorReceiptValidationReached)
        XCTAssertTrue(failure.sameJobFreshMetallibWasAvailableFromPredecessor)
        XCTAssertTrue(failure.sameJobFreshMetallibWasInspectedByStage2Launcher)
        XCTAssertTrue(failure.stage2RepairLauncherReachedFreshMetallibDiscovery)
        XCTAssertEqual(failure.stage2MetallibDiscoveryCount, 1)
        XCTAssertEqual(failure.stage2MetallibCandidateCount, 1)
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
        XCTAssertFalse(failure.launcherClassifierFalsePositiveObserved)
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
            "FAIL_exact_main_stage2_fresh_metallib_cross_binding_log_channel_guard_no_stage2_build_test_or_receipt_no_rerun_no_artifact_no_downstream_authority"
        )
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 5)
        XCTAssertEqual(
            observation.orderedRequiredSeparateActions.first,
            "retire_consumed_stage2_live_invocation_without_rerun"
        )
        XCTAssertTrue(
            observation.orderedRequiredSeparateActions.contains(
                "separately_authorize_bounded_fresh_metallib_cross_binding_evidence_surface_repair"
            )
        )

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservation.swift"
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
            "6c0f9a82ff61e30abc9122faca47fdace203deecd464431d41fd84d0709d382f"
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
                        "unknown_stage2_fresh_cross_binding_failure_field_\(index)"
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
        _ log: PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1,
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
        _ receipt: PrimeNativeDecoderStage2FreshCrossBindingFailureReceiptIdentityV1,
        byteCount: Int,
        sha256: String
    ) {
        XCTAssertEqual(receipt.count, 1)
        XCTAssertEqual(receipt.jsonByteCount, byteCount)
        XCTAssertEqual(receipt.jsonSHA256, sha256)
        XCTAssertTrue(receipt.outcomeEstablished)
        XCTAssertEqual(receipt.metallibByteCount, 6_292_684)
        XCTAssertEqual(
            receipt.metallibSHA256,
            "0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994"
        )
        XCTAssertFalse(receipt.loadedMetallibIdentityIndependentlyObserved)
        XCTAssertFalse(receipt.metallibArtifactProvenanceEstablished)
    }

    private func artifactFalseClaims(
        _ artifacts: PrimeNativeDecoderStage2FreshCrossBindingFailureArtifactBoundaryV1
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
        _ ceiling: PrimeNativeDecoderStage2FreshCrossBindingFailureAuthorityCeilingV1
    ) -> [Bool] {
        [
            ceiling.rerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.workflowMutationBeyondRequiredRetirementAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.predecessorLogClassifierRepairAuthorized,
            ceiling.freshMetallibCrossBindingRepairAuthorized,
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
