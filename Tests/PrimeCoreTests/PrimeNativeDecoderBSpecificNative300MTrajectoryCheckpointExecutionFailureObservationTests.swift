// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_b_specific_native300m_trajectory_checkpoint_execution_failure_observation_v1"
        )
        XCTAssertEqual(
            observation.observationKind,
            "terminal_exact_main_stage7_supervisor_nonzero_no_public_receipt_orphan_sleep_observed_private_cause_unrecoverable"
        )
        XCTAssertEqual(
            observation.predecessorAuthorityID,
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            observation.predecessorAuthorityCanonicalSHA256,
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                .canonicalSHA256
        )
        XCTAssertEqual(
            observation.predecessorAuthorityCanonicalSHA256,
            "4d995b21a20424f1b05fbcb9fbe33780dbd7af03cbf68047270db4aae192caa4"
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 116)
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(
            repository.baseRevision,
            "300bad298bc9ff6f2752d1409639ff9e99318db6"
        )
        XCTAssertEqual(
            repository.baseTree,
            "d7c57b442e6c9a278b2ab58142ac86cbfa622930"
        )
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            "c2077a68d5ac684528bf948cef3d3fa38b823a02"
        )
        XCTAssertEqual(
            repository.reviewedHeadTree,
            "63019d792346f8a6aeec461bdfc06721671385e8"
        )
        XCTAssertEqual(
            repository.reviewedHeadOrderedParents,
            [repository.baseRevision]
        )
        XCTAssertEqual(
            repository.mergeRevision,
            "88e001083c19f995f5ef5bd7c36f48356a90b997"
        )
        XCTAssertEqual(repository.mergeTree, repository.reviewedHeadTree)
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [repository.baseRevision, repository.reviewedHeadRevision]
        )
        XCTAssertEqual(repository.mergeCommitterAt, "2026-08-15T11:54:43Z")
        XCTAssertEqual(repository.mergedAt, "2026-08-15T11:54:44Z")
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.exactMainRefMatchedAtTerminalAudit)
        XCTAssertEqual(repository.changedPathCount, 9)
        XCTAssertEqual(repository.changedManifestPathCount, 1)
        XCTAssertEqual(repository.changedLockPathCount, 0)
        XCTAssertTrue(repository.rootManifestPreserved)
        XCTAssertTrue(repository.rootLockPreserved)
        XCTAssertTrue(repository.validationLockPreserved)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "026ac33c426c8368e3eecfc327637580590b580c9b094af7aef61a7158c9906a"
        )

        let sources = observation.mechanicsSourceBindings
        XCTAssertEqual(sources.count, 9)
        XCTAssertEqual(
            sources.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderNative300MTrajectoryCheckpointV1.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution/main.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionContractTests.swift",
            ]
        )
        XCTAssertEqual(
            sources.map(\.gitMode),
            ["100755", "100755", "100644", "100644", "100644", "100644", "100644", "100644", "100644"]
        )
        XCTAssertEqual(
            sources.map(\.gitBlob),
            [
                "d1c9cac53aec04645934bbafdc366db57e5b8255",
                "6222fcc7d41e596116c54c2b7fecabb749bac31c",
                "02775347d217695a3a8da92c69718dbb980f2158",
                "d3593c1103941defafd203abdbd5a0517e3485bb",
                "994b11884ad271b796baf8298182a014324efc44",
                "939b949cd86741e98cdb389863f1b9378107b78f",
                "482a3c1a6bfbf0a5f853ae554b1e37f2badf21e8",
                "26e16be125faca470c81c6909c06a71d65f91829",
                "10dae9f4911b8965e700de7ae7160f730888fdc7",
            ]
        )
        XCTAssertEqual(
            sources.map(\.byteCount),
            [983_780, 186_086, 118_793, 546, 103_580, 311_307, 3_619, 250, 132_644]
        )
        XCTAssertEqual(
            sources.map(\.lfByteCount),
            [16_772, 3_486, 775, 13, 2_428, 7_129, 115, 8, 2_875]
        )
        XCTAssertEqual(
            sources.map(\.sha256),
            [
                "dc36124507a78cd99c4e883f45513cd8085219243b5c5a759f0c06e50c36f0b6",
                "5d7a2d1a84996064923f1ffb027c321368399d9dd03a5ece10fee4d7e749f6de",
                "e26b0b0a581c38ff698e4bebe13a4c57e33983d790ab462c65d79c086e62103a",
                "4e56c1f104b1fcd2dfb023f29e84b7084cefd086030dd9978d34b1ff13c46dfb",
                "c410a41ac9dc00e5c3e530021cb5884c9e5d6a292099a62e648f5542ca75692e",
                "15d2407998ac485ba0603cdd0f0318f06e2b668e79e87df5675429a145dd5238",
                "f9faef3dd3247f1c1da302184aecfdc4e55f54580ea4e00ab9fd0c20b45eb362",
                "0b6ec9c781ca0839df9a02a2e2e5f4caa49ae38e0c7f3f8a187bf338ec459ad4",
                "9dcdf7856814f3e7bf624c6a61c2eab191e7ecb759e50a4e11a3d84aaa7e303a",
            ]
        )
        XCTAssertEqual(Set(sources.map(\.path)).count, 9)
        XCTAssertTrue(
            sources.allSatisfy {
                isLowercaseHex($0.gitBlob, count: 40)
                    && isLowercaseHex($0.sha256, count: 64)
                    && !$0.claimScope.isEmpty
            }
        )

        let review = observation.pullRequestReviewBoundary
        XCTAssertEqual(review.pullRequestCreatedAt, "2026-08-15T11:46:31Z")
        XCTAssertEqual(review.pullRequestMergedAt, repository.mergedAt)
        XCTAssertEqual(review.pullRequestCommitCount, 1)
        XCTAssertEqual(review.pullRequestChangedPathCount, 9)
        XCTAssertEqual(review.workflowRunID, 31_882_905_671)
        XCTAssertEqual(review.workflowRunNumber, 128)
        XCTAssertEqual(review.workflowRunAttempt, 1)
        XCTAssertEqual(review.workflowEvent, "pull_request")
        XCTAssertEqual(review.workflowHeadRevision, repository.reviewedHeadRevision)
        XCTAssertEqual(review.workflowCheckSuiteID, 86_483_861_376)
        XCTAssertEqual(review.workflowCreatedAt, "2026-08-15T11:46:34Z")
        XCTAssertEqual(review.workflowStartedAt, review.workflowCreatedAt)
        XCTAssertEqual(review.workflowUpdatedAt, "2026-08-15T11:49:30Z")
        XCTAssertEqual(review.workflowStatus, "completed")
        XCTAssertEqual(review.workflowConclusion, "success")
        XCTAssertTrue(review.previousAttemptURLWasNull)
        XCTAssertEqual(review.activeRootJobID, 95_007_853_688)
        XCTAssertEqual(review.activeRootJobStartedAt, "2026-08-15T11:46:37Z")
        XCTAssertEqual(review.activeRootJobCompletedAt, "2026-08-15T11:49:28Z")
        XCTAssertEqual(review.activeRootJobConclusion, "success")
        XCTAssertEqual(review.activeRootRunnerID, 1_000_001_783)
        XCTAssertEqual(review.activeRootTestStartCount, 116)
        XCTAssertEqual(review.activeRootTestPassCount, 116)
        XCTAssertEqual(review.activeRootTestFailureCount, 0)
        XCTAssertEqual(review.activeRootTestSkipCount, 0)
        XCTAssertEqual(review.reviewedMainCompileJobID, 95_008_130_205)
        XCTAssertEqual(review.reviewedMainCompileConclusion, "skipped")
        XCTAssertEqual(review.reviewedMainCompileStepCount, 0)
        XCTAssertEqual(review.stage7JobID, 95_008_130_384)
        XCTAssertEqual(review.stage7JobConclusion, "skipped")
        XCTAssertEqual(review.stage7JobStepCount, 0)
        XCTAssertEqual(review.stage7LauncherInvocationCount, 0)
        XCTAssertEqual(review.stage7ContractInvocationCount, 0)
        XCTAssertEqual(review.stage7ExecutableInvocationCount, 0)
        XCTAssertEqual(review.stage7ReceiptCount, 0)
        XCTAssertEqual(review.metalOrNative300MechanicsInvocationCount, 0)
        XCTAssertEqual(review.actionsArtifactCount, 0)
        XCTAssertEqual(review.rerunCount, 0)
        assertRawLog(
            observation.pullRequestActiveRootRawLog,
            byteCount: 292_354,
            lfByteCount: 1_846,
            sha256: "9f4a4beba90cbc170a74eda15fd7ad16daa549395cca658a5f02a62c9bf9e10f"
        )

        let run = observation.exactMainRunIdentity
        XCTAssertEqual(run.workflowID, 329_017_041)
        XCTAssertEqual(run.workflowName, "Prime active-root quarantine")
        XCTAssertEqual(
            run.workflowPath,
            ".github/workflows/prime-active-root-quarantine.yml"
        )
        XCTAssertEqual(run.runID, 31_883_255_378)
        XCTAssertEqual(run.runNumber, 129)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.mergeRevision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-15T11:54:46Z")
        XCTAssertEqual(run.startedAt, run.createdAt)
        XCTAssertEqual(run.terminalUpdatedAt, "2026-08-15T13:03:57Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.checkSuiteID, 86_484_623_523)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 95_008_665_011)
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.startedAt, "2026-08-15T11:54:49Z")
        XCTAssertEqual(active.completedAt, "2026-08-15T11:58:02Z")
        XCTAssertEqual(active.runnerID, 1_000_001_784)
        XCTAssertEqual(active.runnerLabel, "macos-15")
        XCTAssertEqual(active.orderedStepNames.count, 7)
        XCTAssertEqual(active.orderedStepConclusions, Array(repeating: "success", count: 7))
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainCompileJob
        XCTAssertEqual(reviewed.id, 95_008_982_463)
        XCTAssertEqual(reviewed.conclusion, "success")
        XCTAssertEqual(reviewed.startedAt, "2026-08-15T11:58:04Z")
        XCTAssertEqual(reviewed.completedAt, "2026-08-15T12:46:27Z")
        XCTAssertEqual(reviewed.runnerID, 1_000_001_785)
        XCTAssertEqual(reviewed.runnerLabel, "macos-26")
        XCTAssertEqual(reviewed.orderedStepNames.count, 7)
        XCTAssertEqual(reviewed.orderedStepConclusions, Array(repeating: "success", count: 7))
        XCTAssertEqual(reviewed.checkAnnotationCount, 0)

        let stage7 = observation.stage7Job
        XCTAssertEqual(stage7.id, 95_013_990_901)
        XCTAssertEqual(stage7.conclusion, "failure")
        XCTAssertEqual(stage7.startedAt, "2026-08-15T12:46:29Z")
        XCTAssertEqual(stage7.completedAt, "2026-08-15T13:03:56Z")
        XCTAssertEqual(stage7.runnerID, 1_000_001_786)
        XCTAssertEqual(stage7.runnerLabel, "macos-26")
        XCTAssertEqual(stage7.orderedStepNames.count, 6)
        XCTAssertEqual(
            stage7.orderedStepConclusions,
            ["success", "success", "success", "success", "failure", "success"]
        )
        XCTAssertEqual(stage7.checkAnnotationCount, 1)
        XCTAssertEqual(stage7.checkAnnotationPath, ".github")
        XCTAssertEqual(stage7.checkAnnotationLine, 74_288)
        XCTAssertEqual(stage7.checkAnnotationMessage, "Process completed with exit code 2.")

        assertRawLog(
            observation.activeRootRawLog,
            byteCount: 292_453,
            lfByteCount: 1_847,
            sha256: "36f626e4a038d513fbb0629db54c9806690eb644135bfdd13009a8abeb1cb584"
        )
        assertRawLog(
            observation.reviewedMainCompileRawLog,
            byteCount: 10_348_477,
            lfByteCount: 79_295,
            sha256: "c565edf57bba08e2430ec82570a75604f9b9730300fe17102eac4cb4ff337e22"
        )
        assertRawLog(
            observation.stage7RawLog,
            byteCount: 9_829_534,
            lfByteCount: 74_429,
            sha256: "b446819db9570743f162d9ea9015d4927689e854d5aba16f9c4ce65543e59be2"
        )

        let topology = observation.testTopology
        XCTAssertEqual(topology.activeLatinTestStartCount, 116)
        XCTAssertEqual(topology.activeLatinTestPassCount, 116)
        XCTAssertEqual(topology.activeLatinFailureCount, 0)
        XCTAssertEqual(topology.activeLatinSkipCount, 0)
        XCTAssertEqual(topology.focusedRootTestCount, 62)
        XCTAssertEqual(topology.isolatedCheckpointGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(topology.isolatedCheckpointTestCount, 6)
        XCTAssertEqual(topology.focusedStage7ContractTestCount, 1)
        XCTAssertEqual(topology.focusedWholeStepTestCount, 69)
        XCTAssertEqual(topology.metalTestCount, 44)
        XCTAssertEqual(topology.maintainedRuntimeTestCount, 1)
        XCTAssertEqual(topology.tokenizerTestCount, 1)
        XCTAssertEqual(topology.liveTestCount, 46)
        XCTAssertEqual(topology.reviewedCompileTestCount, 115)
        XCTAssertEqual(topology.reviewedCompileFailureCount, 0)
        XCTAssertEqual(topology.reviewedCompileSkipCount, 0)
        XCTAssertEqual(topology.stage7LauncherLocalContractTestCount, 1)
        XCTAssertEqual(topology.stage7LauncherLocalContractPassCount, 1)
        XCTAssertEqual(topology.aggregateReviewedXCTestCount, 116)
        XCTAssertEqual(topology.directOperationalProbeInvocationCount, 1)
        XCTAssertEqual(topology.directOperationalProbeSuccessCount, 0)
        XCTAssertEqual(
            topology.observedLiveExecutionOrder,
            [
                "focused", "metal", "maintained_runtime", "tokenizer",
                "stage7_launcher_local_contract", "stage7_supervisor",
            ]
        )

        let failure = observation.executionFailureBoundary
        XCTAssertEqual(failure.failedJobStepNumber, 5)
        XCTAssertEqual(
            failure.failedJobStepName,
            "Reconstruct exact Stage-7 inputs and invoke the sole launcher"
        )
        XCTAssertEqual(failure.failedJobStepStartedAt, "2026-08-15T12:46:43Z")
        XCTAssertEqual(failure.failedJobStepCompletedAt, "2026-08-15T13:03:50Z")
        XCTAssertEqual(failure.releaseBuildInvocationCount, 1)
        XCTAssertEqual(failure.releaseBuildCompletionCount, 1)
        XCTAssertEqual(failure.releaseBuildDurationMilliseconds, 633_920)
        XCTAssertEqual(failure.launcherLocalPureContractInvocationCount, 1)
        XCTAssertEqual(failure.launcherLocalPureContractStartCount, 1)
        XCTAssertEqual(failure.launcherLocalPureContractPassCount, 1)
        XCTAssertEqual(failure.launcherLocalPureContractFailureCount, 0)
        XCTAssertEqual(failure.launcherLocalPureContractSkipCount, 0)
        XCTAssertEqual(failure.launcherLocalPureContractDurationMilliseconds, 8_901)
        XCTAssertEqual(failure.launcherInvocationCount, 1)
        XCTAssertEqual(failure.directSupervisorExecutableInvocationCount, 1)
        XCTAssertTrue(failure.oneShotBoundaryReached)
        XCTAssertTrue(failure.oneShotConsumed)
        XCTAssertTrue(failure.oneShotExhausted)
        XCTAssertEqual(
            failure.supervisorNonzeroMarkerLine,
            "swift-driver version: 1.148.6 prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution: sole supervisor invocation did not exit zero"
        )
        XCTAssertEqual(failure.supervisorNonzeroMarkerOccurrenceCount, 1)
        XCTAssertEqual(
            failure.exactSupervisorExitStatusEvidence,
            "unknown_nonzero_launcher_disclosed_no_numeric_supervisor_status"
        )
        XCTAssertEqual(failure.launcherExitCode, 2)
        XCTAssertEqual(failure.workflowProcessExitMessage, "Process completed with exit code 2.")
        XCTAssertEqual(failure.workflowProcessExitMessageOccurrenceCount, 1)
        XCTAssertEqual(
            failure.publicReceiptPrefix,
            "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RECEIPT_V1="
        )
        XCTAssertEqual(failure.hostedLogPublicReceiptPrefixOccurrenceCount, 0)
        XCTAssertEqual(
            failure.privateCandidateSchemaID,
            "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_candidate_v1"
        )
        XCTAssertEqual(failure.hostedLogPrivateCandidateSchemaIDOccurrenceCount, 0)
        XCTAssertEqual(
            failure.privateTerminalSchemaID,
            "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_terminal_v1"
        )
        XCTAssertEqual(failure.hostedLogPrivateTerminalSchemaIDOccurrenceCount, 0)
        XCTAssertEqual(
            failure.publicReceiptSchemaID,
            "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_receipt_v1"
        )
        XCTAssertEqual(failure.hostedLogPublicReceiptSchemaIDOccurrenceCount, 0)
        XCTAssertEqual(failure.hostedLogExternalFailsafeStartedMarkerCount, 0)
        XCTAssertEqual(failure.hostedLogExternalFailsafeFailedMarkerCount, 0)
        XCTAssertFalse(failure.privateSupervisorCauseRecoverable)
        XCTAssertEqual(
            failure.privateSupervisorCauseEvidence,
            "unrecoverable_private_stdout_stderr_and_frames_not_published"
        )
        XCTAssertEqual(failure.supervisorStdoutEvidence, "unknown_private_capture_not_published")
        XCTAssertEqual(failure.supervisorStderrEvidence, "unknown_private_capture_not_published")
        XCTAssertEqual(failure.privateCandidateFrameEvidence, "unknown_no_publicly_recoverable_frame")
        XCTAssertEqual(failure.privateTerminalFrameEvidence, "unknown_no_publicly_recoverable_frame")
        XCTAssertEqual(failure.workerProcessEvidence, "unknown")
        XCTAssertEqual(failure.releaseVerifierProcessEvidence, "unknown")
        XCTAssertEqual(failure.leaseEvidence, "unknown")
        XCTAssertEqual(failure.checkpointPublicationEvidence, "unknown")
        XCTAssertEqual(failure.comparisonDomainEvidence, "unknown")
        XCTAssertEqual(failure.resourcePhaseEvidence, "unknown")
        XCTAssertEqual(failure.artifactCleanupAndAbsenceEvidence, "unknown")
        XCTAssertEqual(
            failure.scientificOutcomeEvidence,
            "unknown_not_a_valid_terminal_scientific_classification"
        )
        XCTAssertEqual(failure.resourceOutcomeEvidence, "unknown")
        XCTAssertEqual(failure.exactResumeEvidence, "unknown")
        XCTAssertFalse(failure.validPublicTerminalEstablished)
        XCTAssertFalse(failure.mechanicsSuccessEstablished)
        XCTAssertTrue(failure.workflowFailureEstablished)
        XCTAssertFalse(failure.integrityClosureEstablished)

        let orphan = observation.orphanProcessBoundary
        XCTAssertTrue(orphan.githubRunnerOrphanCleanupObserved)
        XCTAssertEqual(orphan.observedOrphanProcessCount, 1)
        XCTAssertEqual(orphan.observedOrphanPID, 29_906)
        XCTAssertEqual(orphan.observedOrphanProcessName, "sleep")
        XCTAssertEqual(
            orphan.observedOrphanTerminationLine,
            "Terminate orphan process: pid (29906) (sleep)"
        )
        XCTAssertEqual(orphan.observedOrphanTerminationLineOccurrenceCount, 1)
        XCTAssertEqual(orphan.observedOrphanTerminationAt, "2026-08-15T13:03:51.2835430Z")
        XCTAssertFalse(orphan.noOrphanClosureEstablished)
        XCTAssertEqual(orphan.observedProcessRoleEvidence, "unknown_unattributed_sleep_process")
        XCTAssertFalse(orphan.watchdogChildAttributionDirectlyObserved)
        XCTAssertEqual(
            orphan.watchdogChildExplanation,
            "source_consistent_external_watchdog_sleep_child_survived_watchdog_subshell_termination"
        )
        XCTAssertTrue(orphan.watchdogChildExplanationIsInferenceOnly)
        XCTAssertEqual(orphan.watchdogSleepSecondsInFrozenSource, 5_120)
        XCTAssertTrue(orphan.explanationConsistentWithFrozenSource)
        XCTAssertFalse(orphan.supervisorWorkerOrVerifierOrphanEstablished)

        let lineage = observation.artifactAndLineageBoundary
        XCTAssertEqual(lineage.pullRequestRunArtifactCount, 0)
        XCTAssertEqual(lineage.exactMainRunArtifactCount, 0)
        XCTAssertEqual(lineage.artifactUploadStepCount, 0)
        XCTAssertEqual(lineage.exactMainRunCountForHead, 1)
        XCTAssertEqual(lineage.runAttemptCount, 1)
        XCTAssertTrue(lineage.previousAttemptURLWasNull)
        XCTAssertEqual(lineage.retryCount, 0)
        XCTAssertEqual(lineage.rerunCount, 0)
        XCTAssertEqual(lineage.replacementExecutionCount, 0)
        XCTAssertEqual(lineage.publicReceiptCount, 0)
        XCTAssertFalse(lineage.retainedArtifactEstablished)
        XCTAssertFalse(lineage.runnerLocalArtifactAbsenceEstablished)
        XCTAssertFalse(lineage.checkpointCleanupEstablished)
        XCTAssertFalse(lineage.durableFailureReceiptPublished)

        let retirement = observation.retirementBoundary
        XCTAssertTrue(retirement.retirementRequired)
        XCTAssertFalse(retirement.retirementObserved)
        XCTAssertEqual(retirement.exactChangedPathCount, 5)
        XCTAssertEqual(
            retirement.exactOrderedChangedPaths,
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationTests.swift",
            ]
        )
        XCTAssertEqual(retirement.expectedActiveLatinTestCount, 116)
        XCTAssertEqual(retirement.expectedRootTestCount, 63)
        XCTAssertEqual(retirement.expectedIsolatedCheckpointGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(retirement.expectedIsolatedCheckpointTestCount, 6)
        XCTAssertEqual(retirement.expectedFocusedWholeStepTestCount, 69)
        XCTAssertEqual(retirement.expectedMetalTestCount, 44)
        XCTAssertEqual(retirement.expectedRuntimeTestCount, 1)
        XCTAssertEqual(retirement.expectedTokenizerTestCount, 1)
        XCTAssertEqual(retirement.expectedLiveTestCount, 46)
        XCTAssertEqual(retirement.expectedTotalTestCount, 115)
        XCTAssertEqual(retirement.expectedStage7JobCount, 0)
        XCTAssertEqual(retirement.expectedStage7FocusedContractInvocationCount, 0)
        XCTAssertEqual(retirement.expectedStage7LauncherLocalContractInvocationCount, 0)
        XCTAssertEqual(retirement.expectedStage7LauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedStage7ExecutableInvocationCount, 0)
        XCTAssertEqual(retirement.expectedStage7ReceiptCount, 0)
        XCTAssertTrue(retirement.stage7MechanicsPayloadsMustRemainPreserved)
        XCTAssertFalse(retirement.replacementOrRepairExecutionPermittedByRetirement)

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.oneShotExecutionConsumed)
        XCTAssertTrue(ceiling.oneShotExecutionExhausted)
        XCTAssertTrue(ceiling.failureObservationAuthorizesNothing)
        XCTAssertTrue(ceiling.exactRetirementRequired)
        XCTAssertTrue(ceiling.mechanicsPayloadPreservationRequired)
        XCTAssertTrue(ceiling.workflowFailureEstablished)
        XCTAssertTrue(
            ceiling.requiredPublicTerminalIntegrityClosureFailureEstablished
        )
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 6)
        XCTAssertEqual(
            observation.status,
            "FAIL_exact_main_stage7_release_and_pure_pass_supervisor_nonzero_no_public_receipt_private_cause_unrecoverable_orphan_sleep_observed_one_shot_consumed_no_retry_no_stage8"
        )

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservation.swift"
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
        XCTAssertEqual(canonical.count, Observation.canonicalByteCount)
        XCTAssertEqual(Observation.canonicalByteCount, 20_617)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Observation.canonicalSHA256
        )
        XCTAssertEqual(
            Observation.canonicalSHA256,
            "0a188a5a99d90d90828dca5eadeb0a167a71c6a9348201ff103be042d60ccf97"
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
        for path in valuePaths {
            let mutationData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))"
            )
            if let loose = try? JSONDecoder().decode(
                Observation.self,
                from: mutationData
            ), loose != observation {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }
            _ = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: { _ in NSNull() }),
                label: "null \(pathLabel(path))"
            )
            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
        }
        XCTAssertGreaterThan(regularDecodedDriftCount, 250)

        let arrayPaths = allArrayPaths(in: object)
        var reorderedArrayCount = 0
        for path in arrayPaths {
            var didReorder = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in 0 ..< array.count {
                        for right in (left + 1) ..< array.count {
                            if canonicalJSONFragment(array[left])
                                != canonicalJSONFragment(array[right]) {
                                array.swapAt(left, right)
                                didReorder = true
                                return array
                            }
                        }
                    }
                    return array
                }
            )
            if didReorder {
                _ = try assertCanonicalRejects(
                    reordered,
                    label: "reordered array at \(pathLabel(path))"
                )
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 10)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_stage7_failure_field_\(index)"] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))"
            )
            let loose = try JSONDecoder().decode(Observation.self, from: unknownData)
            XCTAssertEqual(loose, observation)
        }

        try assertNoncanonicalEncodingsReject(canonical, object: object)
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

    private func allDictionaryPaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(in: array[index], prefix: prefix + [.index(index)])
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
            object[key] = replacingValue(in: object[key]!, at: remainder, with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(in: array[index], at: remainder, with: transform)
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

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )) ?? Data()
    }

    private func mutateJSONValue(_ value: Any) -> Any {
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
        reordered.insert(contentsOf: schemaField, at: reordered.index(after: openingBrace))
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Observation.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(contentsOf: schemaField, at: duplicate.index(after: duplicateOpening))
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Observation.decodeCanonical(duplicateData))
    }

    private func assertRawLog(
        _ log: Observation.RawLogIdentity,
        byteCount: Int,
        lfByteCount: Int,
        sha256: String
    ) {
        XCTAssertEqual(log.byteCount, byteCount)
        XCTAssertEqual(log.lfByteCount, lfByteCount)
        XCTAssertEqual(
            log.newlineDelimitedComponentCountIncludingTerminalEmpty,
            lfByteCount + 1
        )
        XCTAssertEqual(log.sha256, sha256)
        XCTAssertEqual(log.utf8BOMHex, "efbbbf")
        XCTAssertTrue(log.startsWithUTF8BOM)
        XCTAssertTrue(log.usesLFOnly)
        XCTAssertTrue(log.endsWithLF)
        XCTAssertTrue(log.repeatFetchExactlyEqual)
        XCTAssertEqual(
            log.bindingKind,
            "github_job_log_endpoint_decoded_utf8_bytes_v1"
        )
        XCTAssertFalse(log.rawGitHubLogArchiveBytesBound)
        XCTAssertFalse(log.retainedInRepository)
    }

    private func authorityFalseClaims(_ ceiling: Observation.AuthorityCeiling) -> [Bool] {
        [
            ceiling.privateFailureCauseRecovered,
            ceiling.validStage7TerminalEstablished,
            ceiling.stage7MechanicsSuccessEstablished,
            ceiling.passExactEstablished,
            ceiling.measuredExactMismatchEstablished,
            ceiling.abstainResourceEstablished,
            ceiling.abstainIntegrityEstablished,
            ceiling.scientificOutcomeEstablished,
            ceiling.resourceOutcomeEstablished,
            ceiling.exactResumeEstablished,
            ceiling.checkpointBindingEstablished,
            ceiling.checkpointCleanupAndAbsenceEstablished,
            ceiling.releaseVerifierClosureEstablished,
            ceiling.noOrphanClosureEstablished,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.replacementExecutionAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.additionalNative300MExecutionAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.generalTrainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.stage8AuthorityEstablished,
            ceiling.stage8Authorized,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
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
