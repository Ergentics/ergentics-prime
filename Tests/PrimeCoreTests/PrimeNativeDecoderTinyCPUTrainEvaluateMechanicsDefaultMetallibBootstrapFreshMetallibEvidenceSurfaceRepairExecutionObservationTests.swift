// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndSuccessCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_execution_observation_v1"
        )
        XCTAssertEqual(
            observation.observationKind,
            "exact_main_stage2_fresh_metallib_evidence_surface_repair_execution_success_observation"
        )
        XCTAssertEqual(
            observation.predecessorAuthorityID,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            observation.predecessorAuthorityCanonicalSHA256,
            "bc6aa0630196e1c02814834ffb3f8502ae51bcdc751ecbc37cb9bb5dd22c502a"
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 91)
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(
            repository.revision,
            "5c1b7c4f7a7689cba53ded11dd8b12a0f1a3229d"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "075922cec8361c0085d5b2c6d000828e3c0bfc35",
                "f2d04016463133854995d2523770bb19cfe2eef4",
            ]
        )
        XCTAssertEqual(
            repository.tree,
            "d673bcbfa13b660b7fe898dc127186e8da1aaa6b"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.tree)
        XCTAssertEqual(
            repository.exactFirstParentChangedPaths,
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityV1
                .frozenV1.repairDesign.exactDirectSuccessorChangedPaths
        )
        XCTAssertEqual(
            repository.exactFirstParentChangedStatuses,
            ["M", "M", "M", "M", "A", "A"]
        )
        XCTAssertEqual(repository.mergedAt, "2026-08-12T05:00:12Z")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertEqual(
            repository.mergeCommitSignatureVerifiedAt,
            "2026-08-12T05:01:03Z"
        )
        XCTAssertTrue(repository.exactMainRefStillMatchedAtAudit)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "2e9a9da262a8c6a6b3e12b2d71e42627fc46bbc6bffd60c7791d5a5812ce58d7"
        )

        let sources = observation.observedSourceBindings
        XCTAssertEqual(sources.count, 18)
        XCTAssertEqual(Set(sources.map(\.path)).count, sources.count)
        XCTAssertTrue(
            sources.allSatisfy { source in
                ["100644", "100755"].contains(source.gitMode)
                    && source.gitBlob.utf8.count == 40
                    && isLowercaseHex(source.gitBlob)
                    && source.byteCount > 0
                    && source.lfByteCount > 0
                    && source.sha256.utf8.count == 64
                    && isLowercaseHex(source.sha256)
                    && !source.claimScope.isEmpty
            }
        )
        XCTAssertEqual(
            sources.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-metal.sh",
                ".github/scripts/prime-ci-native-decoder-runtime-closure.sh",
                ".github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
                ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Package.swift",
                "Package.resolved",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
            ]
        )
        XCTAssertEqual(sources[0].gitBlob, "9e672102963536627599940f5ec899b131651bc4")
        XCTAssertEqual(sources[4].gitBlob, "6a50cc027a566104a1d9d505add93b619f1a32f5")
        XCTAssertEqual(sources[5].gitBlob, "0fe28060b356e4aac1fb5109d23777dca1adba33")
        XCTAssertEqual(sources[8].gitBlob, "d7a025193c0dafe405f12f33aa4a0e5b91c827c4")
        XCTAssertEqual(sources[13].gitBlob, "523d30f7bd42d67276476ee545cc2f62c4a5b361")
        XCTAssertEqual(sources[14].gitBlob, "cb5e9301694ae6f37d0d2001fecabe589d563c6c")
        XCTAssertEqual(sources[4].byteCount, 53_660)
        XCTAssertEqual(
            sources[4].sha256,
            "27c276d9acf9662ff315dccb849304aa61b44dfad67237120eeb9dd97324a840"
        )

        let run = observation.runIdentity
        XCTAssertEqual(run.workflowID, 329_017_041)
        XCTAssertEqual(run.runID, 31_565_094_400)
        XCTAssertEqual(run.runNumber, 79)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.revision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-12T05:00:18Z")
        XCTAssertEqual(run.terminalUpdatedAt, "2026-08-12T05:51:30Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "success")
        XCTAssertEqual(run.checkSuiteID, 85_623_258_434)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.secondAttemptEndpointHTTPStatus, 404)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 94_015_181_778)
        XCTAssertEqual(active.runnerID, 1_000_001_709)
        XCTAssertEqual(active.runnerName, "GitHub Actions 1000001709")
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.orderedSteps.map(\.number), Array(1 ... 7))
        XCTAssertTrue(active.orderedSteps.allSatisfy { $0.conclusion == "success" })
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.id, 94_015_642_394)
        XCTAssertEqual(reviewed.runnerID, 1_000_001_710)
        XCTAssertEqual(reviewed.runnerName, "GitHub Actions 1000001710")
        XCTAssertEqual(reviewed.conclusion, "success")
        XCTAssertEqual(reviewed.orderedSteps.map(\.number), Array(1 ... 7))
        XCTAssertTrue(reviewed.orderedSteps.allSatisfy { $0.conclusion == "success" })
        XCTAssertEqual(
            reviewed.orderedSteps[5].name,
            "Run the Prime-owned decoder on live Metal"
        )
        XCTAssertEqual(reviewed.checkAnnotationCount, 0)

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
            byteCount: 238_922,
            lfByteCount: 1_761,
            sha256:
                "680fc1b1672db3ef0d2bab7d7e8599d6d176d3929d14aeeef4f03197cdc7cce4"
        )
        assertRawLog(
            observation.reviewedMainRawLog,
            byteCount: 10_294_957,
            lfByteCount: 78_905,
            sha256:
                "019f6ba8535ddaca21b49ecc289b91cb09679552cb597c99d634139646ff7c3a"
        )
        assertRawLog(
            observation.secureFetchStepRawLog,
            byteCount: 4_893,
            lfByteCount: 54,
            sha256:
                "457781579fa43d313886ca57c887fd5a42d828a6b97e33cec5fc682181d3caf7"
        )
        assertRawLog(
            observation.focusedContractsStepRawLog,
            byteCount: 353_901,
            lfByteCount: 3_403,
            sha256:
                "c21ee98599a75671bfe125cf100a42d02131acedb0dd5265c050177d074e79ac"
        )
        assertRawLog(
            observation.liveStage2StepRawLog,
            byteCount: 9_930_010,
            lfByteCount: 75_360,
            sha256:
                "6327bf59a8f84557af8d9cc01f4274114e48e47238379139752bd2b94e3df583"
        )

        let archive = observation.rawLogArchive
        XCTAssertEqual(archive.byteCount, 1_357_752)
        XCTAssertEqual(
            archive.sha256,
            "02e8588ba5ac1190ce309cd1a7b92fc8fc04e383e5ffb101acb07df17590dfb3"
        )
        XCTAssertEqual(archive.memberCount, 18)
        XCTAssertEqual(archive.members.count, archive.memberCount)
        XCTAssertEqual(
            archive.members.reduce(0) { $0 + $1.byteCount },
            archive.uncompressedByteCount
        )
        XCTAssertEqual(archive.uncompressedByteCount, 21_069_195)
        XCTAssertEqual(Set(archive.members.map(\.path)).count, archive.memberCount)
        XCTAssertTrue(archive.repeatedDownloadsWereByteIdentical)
        XCTAssertTrue(archive.memberTimestampsAreDOSZero)
        XCTAssertEqual(
            archive.members.first?.sha256,
            observation.reviewedMainRawLog.sha256
        )
        XCTAssertEqual(
            archive.members[9].sha256,
            observation.activeRootRawLog.sha256
        )

        let secureFetch = observation.secureFetchBoundary
        XCTAssertEqual(secureFetch.invocationCount, 1)
        XCTAssertEqual(secureFetch.completionCount, 1)
        XCTAssertEqual(secureFetch.workflowAuthoredRetryCount, 0)
        XCTAssertEqual(secureFetch.separateRetryStepCount, 0)
        XCTAssertEqual(secureFetch.gitInternalSubmoduleRetryCount, 0)
        XCTAssertEqual(secureFetch.mlxSubmoduleCloneAttemptCount, 1)
        XCTAssertEqual(secureFetch.mlxCSubmoduleCloneAttemptCount, 1)
        XCTAssertEqual(secureFetch.gitSubmoduleTLSFailureCount, 0)
        XCTAssertEqual(secureFetch.tlsVerificationBypassCount, 0)
        XCTAssertEqual(secureFetch.customCAInstallationCount, 0)
        XCTAssertEqual(
            secureFetch.workflowBlockSHA256,
            "ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847"
        )

        let predecessor = observation.predecessorBoundary
        XCTAssertTrue(predecessor.activeRootGatePassed)
        XCTAssertTrue(predecessor.dependencyFreeSwiftParsePassed)
        XCTAssertEqual(predecessor.latinInvocationCount, 1)
        XCTAssertEqual(predecessor.latinCompletedTestCount, 116)
        XCTAssertEqual(predecessor.latinFailureCount, 0)
        XCTAssertEqual(predecessor.latinSkipCount, 0)
        XCTAssertEqual(predecessor.focusedRootInvocationCount, 1)
        XCTAssertEqual(predecessor.focusedRootTestCount, 43)
        XCTAssertEqual(predecessor.focusedRootFailureCount, 0)
        XCTAssertEqual(predecessor.focusedRootSkipCount, 0)
        XCTAssertEqual(predecessor.isolatedCheckpointGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(predecessor.focusedWholeStepTestCount, 49)
        XCTAssertEqual(
            predecessor.liveInvocationSequence,
            ["metal", "maintained_runtime", "tokenizer", "stage2"]
        )
        XCTAssertEqual(predecessor.liveInvocationCounts, [1, 1, 1, 1])
        XCTAssertEqual(predecessor.metallibBuildInvocationCount, 1)
        XCTAssertEqual(predecessor.metallibBuildCompletionCount, 1)
        XCTAssertEqual(predecessor.freshMetallibCandidateCount, 1)
        XCTAssertEqual(predecessor.freshMetallibByteCount, 6_292_732)
        XCTAssertEqual(
            predecessor.freshMetallibSHA256,
            "54b57ce3dea5c648cbee3096602cf51791033badb2fbbdc632741bb3b1b5f7d6"
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
            rawByteCount: 6_853,
            rawSHA256:
                "1e03e85dd25c553d46d181c148b8b45bb7e701498cb335f2a07b4596b32bb619"
        )
        XCTAssertEqual(predecessor.tokenizerInvocationCount, 1)
        XCTAssertEqual(predecessor.tokenizerTestCount, 1)
        XCTAssertEqual(predecessor.tokenizerFailureCount, 0)
        XCTAssertEqual(predecessor.tokenizerSkipCount, 0)
        assertReceipt(
            predecessor.tokenizerReceipt,
            rawByteCount: 7_182,
            rawSHA256:
                "102ccf73a7e4c527dfbdce70d52946e570f4c2677e50e189e0a41c82705baca7"
        )
        XCTAssertEqual(predecessor.validatedPredecessorLogCount, 11)
        XCTAssertEqual(predecessor.validatedPredecessorReceiptCount, 2)
        XCTAssertEqual(predecessor.predecessorArtifactSnapshotCount, 16)
        XCTAssertEqual(
            predecessor.predecessorArtifactRevalidationCountAfterXCTest,
            16
        )
        XCTAssertEqual(predecessor.completedPreStage2TestCount, 95)
        XCTAssertEqual(predecessor.preStage2FailureCount, 0)
        XCTAssertEqual(predecessor.preStage2SkipCount, 0)

        let metal = observation.metalCaptureBoundary
        XCTAssertEqual(
            metal.fixedLogPath,
            "$RUNNER_TEMP/prime-native-decoder-metal-full-output.log"
        )
        XCTAssertTrue(metal.initialAbsenceRequired)
        XCTAssertEqual(metal.captureInvocationCount, 1)
        XCTAssertEqual(metal.teeInvocationCount, 1)
        XCTAssertEqual(metal.pipelineStatusElementCount, 2)
        XCTAssertEqual(metal.launcherPipelineStatus, 0)
        XCTAssertEqual(metal.teePipelineStatus, 0)
        XCTAssertTrue(metal.pipelineStatusCapturedImmediatelyAfterPipeline)
        XCTAssertTrue(metal.errexitRestoredImmediatelyAfterStatusCapture)
        XCTAssertTrue(metal.logRegularFileRequired)
        XCTAssertTrue(metal.logSymbolicLinkForbidden)
        XCTAssertTrue(metal.logNonemptyRequired)
        XCTAssertEqual(metal.logRequiredHardLinkCount, 1)
        XCTAssertEqual(metal.frozenLogPermissionMode, "444")
        XCTAssertEqual(metal.fullOutputIdentityPrefixCount, 1)
        XCTAssertEqual(metal.fullOutputExactIdentityCount, 1)
        XCTAssertEqual(metal.xctestOnlyIdentityPrefixCount, 0)
        XCTAssertEqual(metal.xctestOnlyExactIdentityCount, 0)
        XCTAssertFalse(metal.metalLauncherSourceChanged)

        let stage2 = observation.stage2Boundary
        XCTAssertEqual(stage2.launcherInvocationCount, 1)
        XCTAssertEqual(stage2.stepNumber, 6)
        XCTAssertEqual(stage2.stepName, reviewed.orderedSteps[5].name)
        XCTAssertEqual(stage2.predecessorAuthorityID, observation.predecessorAuthorityID)
        XCTAssertEqual(stage2.classifierCommand, "grep -Eq")
        XCTAssertEqual(stage2.acceptanceFixtureCount, 8)
        XCTAssertEqual(stage2.acceptanceFixtureMatchCount, 0)
        XCTAssertEqual(stage2.rejectionFixtureCount, 5)
        XCTAssertEqual(stage2.rejectionFixtureMatchCount, 5)
        XCTAssertEqual(stage2.scannedLogCount, 8)
        XCTAssertTrue(stage2.predecessorClassifierPassed)
        XCTAssertEqual(stage2.freshSourceCandidateCount, 1)
        XCTAssertTrue(stage2.freshSourceRegularFileIdentityValidated)
        XCTAssertEqual(stage2.metallibIdentityInventoryCount, 5)
        XCTAssertEqual(stage2.byteIdenticalComparisonCount, 5)
        XCTAssertEqual(stage2.byteCountEqualityCount, 5)
        XCTAssertEqual(stage2.sha256EqualityCount, 5)
        XCTAssertEqual(stage2.metalBundleCandidateCount, 2)
        XCTAssertEqual(stage2.runtimeBundleCandidateCount, 1)
        XCTAssertEqual(stage2.tokenizerBundleCandidateCount, 1)
        XCTAssertEqual(stage2.runtimeReceiptIdentityMatchCount, 1)
        XCTAssertEqual(stage2.tokenizerReceiptIdentityMatchCount, 1)
        XCTAssertTrue(stage2.sourceBoundEvidenceEstablished)
        XCTAssertFalse(stage2.loadedMetallibPathInferred)
        XCTAssertFalse(stage2.independentlyObservedLoadedMetallibIdentityEstablished)
        XCTAssertEqual(stage2.buildCommand, "swift build --build-tests")
        XCTAssertEqual(stage2.buildCommandCount, 1)
        XCTAssertFalse(stage2.metallibBuiltByThisLauncher)
        XCTAssertEqual(stage2.stagedDestinationCount, 2)
        XCTAssertEqual(stage2.stagedCopyCount, 2)
        XCTAssertEqual(stage2.stagedPermissionMode, "444")
        XCTAssertEqual(stage2.stagedRelativePaths.count, 2)
        XCTAssertTrue(stage2.stagedCopiesByteIdentical)
        XCTAssertEqual(stage2.directXCTestInvocationCount, 1)
        XCTAssertEqual(
            stage2.validationTestMethod,
            "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"
        )
        XCTAssertEqual(stage2.testStartCount, 1)
        XCTAssertEqual(stage2.testPassCount, 1)
        XCTAssertEqual(stage2.testFailureCount, 0)
        XCTAssertEqual(stage2.testSkipCount, 0)
        XCTAssertTrue(stage2.privateWorkingDirectoryEmptyBeforeAndAfter)
        assertReceipt(
            stage2.receipt,
            rawByteCount: 6_428,
            rawSHA256:
                "5c7a1cb1cec4a66517e5e1fc382ae757f6d6b6460d1f55b963040b958d907a78"
        )
        XCTAssertEqual(
            stage2.receipt.canonicalJSONSHA256,
            stage2.receipt.rawJSONSHA256
        )
        XCTAssertEqual(
            stage2.receipt.receiptLineSHA256,
            "5d4f75241c28ba8d47ad048b2297387411822f85131832d271eb8605f906cdc8"
        )
        XCTAssertEqual(stage2.trustedCompletedTestCount, 96)
        XCTAssertTrue(stage2.mechanicsExecutionEstablished)
        XCTAssertTrue(stage2.defaultMetallibBootstrapRepairEstablished)
        XCTAssertTrue(stage2.freshMetallibEvidenceSurfaceRepairEstablished)

        let artifacts = observation.artifactBoundary
        XCTAssertEqual(artifacts.actionsArtifactsTotalCount, 0)
        XCTAssertTrue(artifacts.actionsArtifactsArrayExactlyEmpty)
        XCTAssertEqual(artifacts.publishedWorkflowArtifactCount, 0)
        XCTAssertEqual(artifacts.artifactUploadStepCount, 0)
        XCTAssertTrue(artifacts.runLogArchiveObserved)
        XCTAssertTrue(artifacts.runtimeReceiptEmitted)
        XCTAssertTrue(artifacts.tokenizerReceiptEmitted)
        XCTAssertTrue(artifacts.stage2ReceiptEmitted)
        XCTAssertTrue(artifactFalseClaims(artifacts).allSatisfy { !$0 })

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.predecessorRepairAuthorityConsumed)
        XCTAssertTrue(ceiling.predecessorRepairAuthorityExhausted)
        XCTAssertTrue(ceiling.successObservationAuthorizesNothing)
        XCTAssertTrue(ceiling.consumedStage2LiveInvocationRetirementRequired)
        XCTAssertTrue(ceiling.launcherSourceMustRemainPreservedForAudit)
        XCTAssertTrue(ceiling.stage3RemainsBlocked)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(
            observation.status,
            "PASS_exact_main_stage2_fresh_metallib_evidence_surface_repair_one_test_zero_failure_zero_skip_no_rerun_no_artifact_no_stage3_authority"
        )
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 5)
        XCTAssertEqual(
            observation.orderedRequiredSeparateActions.first,
            "retire_consumed_stage2_live_invocation_without_rerun"
        )
        XCTAssertEqual(
            observation.orderedRequiredSeparateActions.last,
            "keep_stage3_blocked_until_distinct_authority"
        )

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservation.swift"
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
            "f553a7ce431cedccf25b06a89af2a47f8adcf9db556ca4b5a2341bb3463729e4"
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
        XCTAssertGreaterThan(valuePaths.count, 400)
        XCTAssertGreaterThan(dictionaryPaths.count, 20)
        XCTAssertGreaterThan(scalarPaths.count, 300)

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
        XCTAssertGreaterThan(regularDecodedDriftCount, 300)

        var unknownFieldCount = 0
        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary[
                        "unknown_stage2_evidence_repair_execution_field_\(index)"
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
        _ log: PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1,
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
        _ receipt: PrimeNativeDecoderStage2EvidenceRepairExecutionReceiptIdentityV1,
        rawByteCount: Int,
        rawSHA256: String
    ) {
        XCTAssertEqual(receipt.count, 1)
        XCTAssertEqual(receipt.rawJSONByteCount, rawByteCount)
        XCTAssertEqual(receipt.rawJSONSHA256, rawSHA256)
        XCTAssertEqual(receipt.canonicalJSONByteCount, rawByteCount)
        XCTAssertEqual(receipt.canonicalJSONSHA256, rawSHA256)
        XCTAssertTrue(receipt.rawJSONWasCanonical)
        XCTAssertEqual(
            receipt.receiptLineByteCount,
            receipt.prefix.utf8.count + rawByteCount
        )
        XCTAssertTrue(receipt.outcomeEstablished)
        XCTAssertEqual(receipt.metallibByteCount, 6_292_732)
        XCTAssertEqual(
            receipt.metallibSHA256,
            "54b57ce3dea5c648cbee3096602cf51791033badb2fbbdc632741bb3b1b5f7d6"
        )
        XCTAssertFalse(receipt.loadedMetallibIdentityIndependentlyObserved)
        XCTAssertFalse(receipt.metallibArtifactProvenanceEstablished)
    }

    private func artifactFalseClaims(
        _ artifacts: PrimeNativeDecoderStage2EvidenceRepairExecutionArtifactBoundaryV1
    ) -> [Bool] {
        [
            artifacts.runLogArchiveIsActionsArtifact,
            artifacts.jobLogsRetainedInRepository,
            artifacts.durableJobLogPublicationEstablished,
            artifacts.freshMetallibRetainedAfterJob,
            artifacts.freshMetallibArtifactProvenanceEstablished,
            artifacts.checkpointArtifactCreated,
            artifacts.checkpointArtifactUploaded,
            artifacts.checkpointArtifactRetained,
            artifacts.checkpointArtifactProvenanceEstablished,
        ]
    }

    private func authorityFalseClaims(
        _ ceiling: PrimeNativeDecoderStage2EvidenceRepairExecutionAuthorityCeilingV1
    ) -> [Bool] {
        [
            ceiling.rerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.workflowMutationBeyondRequiredRetirementAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.tlsVerificationBypassAuthorized,
            ceiling.credentialMutationAuthorized,
            ceiling.newMetallibBuildAuthorized,
            ceiling.additionalStage2ExecutionAuthorized,
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
