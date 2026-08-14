// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndFailureCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_execution_failure_observation_v1"
        )
        XCTAssertEqual(
            observation.predecessorAuthorityID,
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            observation.predecessorAuthorityCanonicalSHA256,
            "a5a8e5300ea8413e738fddd4b8fed930dcc9983d5a29eea102862f9744b50fff"
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 104)
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(
            repository.baseRevision,
            "522e4620596eed909822b80b782d74d282f429c5"
        )
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            "ed4833a3a90b265f61a06b6ab25547010bba8807"
        )
        XCTAssertEqual(
            repository.mergeRevision,
            "8bdf6abe15d7f9a83045a3f9ee21fcc28f7ee91d"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                repository.baseRevision,
                repository.reviewedHeadRevision,
            ]
        )
        XCTAssertEqual(
            repository.mergeTree,
            "f7dbc81e4f7e8ccebdf39f0fb5200a7780be91dc"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.mergeTree)
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.exactMainRefMatchedAtTerminalAudit)
        XCTAssertEqual(repository.changedPathCount, 6)
        XCTAssertEqual(repository.manifestOrLockChangedPathCount, 0)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "4f8d6f238fcdeaf800d7a12af76be6082682b42b38d79c9b9bfe0f490309c791"
        )

        let sources = observation.observedSourceBindings
        XCTAssertEqual(sources.count, 6)
        XCTAssertEqual(
            sources.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
            ]
        )
        XCTAssertEqual(Set(sources.map(\.path)).count, 6)
        XCTAssertTrue(
            sources.allSatisfy {
                ["100644", "100755"].contains($0.gitMode)
                    && isLowercaseHex($0.gitBlob, count: 40)
                    && $0.byteCount > 0
                    && $0.lfByteCount > 0
                    && isLowercaseHex($0.sha256, count: 64)
                    && !$0.claimScope.isEmpty
            }
        )
        XCTAssertEqual(
            sources[1].gitBlob,
            "6547ee06663c1ea409a6256e48f6111245056020"
        )
        XCTAssertEqual(sources[1].byteCount, 48_869)
        XCTAssertEqual(sources[1].lfByteCount, 830)
        XCTAssertEqual(
            sources[1].sha256,
            "c639cfcb4d1d0a103b285ed38849565f16b00932fc3b9d921febbf798c30d5f9"
        )

        let run = observation.runIdentity
        XCTAssertEqual(run.workflowID, 329_017_041)
        XCTAssertEqual(run.runID, 31_756_331_438)
        XCTAssertEqual(run.runNumber, 105)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.mergeRevision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-14T00:08:19Z")
        XCTAssertEqual(run.terminalUpdatedAt, "2026-08-14T00:55:28Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.checkSuiteID, 86_154_359_326)
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 94_632_729_903)
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.runnerID, 1_000_001_748)
        XCTAssertEqual(active.runnerLabel, "macos-15")
        XCTAssertEqual(active.orderedStepNames.count, 7)
        XCTAssertEqual(
            active.orderedStepConclusions,
            Array(repeating: "success", count: 7)
        )
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.id, 94_633_409_696)
        XCTAssertEqual(reviewed.conclusion, "failure")
        XCTAssertEqual(reviewed.runnerID, 1_000_001_749)
        XCTAssertEqual(reviewed.runnerLabel, "macos-26")
        XCTAssertEqual(reviewed.orderedStepNames.count, 7)
        XCTAssertEqual(
            reviewed.orderedStepConclusions,
            [
                "success", "success", "success", "success", "success",
                "failure", "success",
            ]
        )
        XCTAssertEqual(reviewed.checkAnnotationCount, 1)
        XCTAssertEqual(reviewed.checkAnnotationPath, ".github")
        XCTAssertEqual(reviewed.checkAnnotationLine, 75_376)
        XCTAssertEqual(
            reviewed.checkAnnotationMessage,
            "Process completed with exit code 2."
        )

        assertRawLog(
            observation.activeRootRawLog,
            byteCount: 254_662,
            lfByteCount: 1_797,
            sha256:
                "9d891c4dc94e2fdfc2422c08a1455d7841bdd8431538dad07a1acacfdb0aff04"
        )
        assertRawLog(
            observation.reviewedMainRawLog,
            byteCount: 10_320_159,
            lfByteCount: 79_103,
            sha256:
                "9141883d20c03c210a6d544256dd89b4bfa31406230dd372b4d44df65b27f16c"
        )

        let repair = observation.repairClosureBoundary
        XCTAssertEqual(repair.workflowRunID, 31_750_678_556)
        XCTAssertEqual(repair.workflowRunNumber, 103)
        XCTAssertEqual(repair.checkSuiteID, 86_139_786_214)
        XCTAssertEqual(
            repair.stage5AuthorityCanonicalSHA256,
            "00c49e63315b2aacb439204e778f54bcf63c2fdf643282f3bd64e2b3b4094089"
        )
        XCTAssertEqual(
            repair.immediateRepairAuthorityCanonicalSHA256,
            observation.predecessorAuthorityCanonicalSHA256
        )
        XCTAssertTrue(repair.frozenByConsumedLauncher)

        let pre = observation.preStage5Boundary
        XCTAssertTrue(pre.activeRootGatePassed)
        XCTAssertTrue(pre.dependencyFreeSwiftParsePassed)
        XCTAssertEqual(pre.latinInvocationCount, 1)
        XCTAssertEqual(pre.latinTestCount, 116)
        XCTAssertEqual(pre.latinFailureCount, 0)
        XCTAssertEqual(pre.latinSkipCount, 0)
        XCTAssertEqual(pre.focusedRootInvocationCount, 1)
        XCTAssertEqual(pre.focusedRootTestCount, 53)
        XCTAssertEqual(pre.isolatedCheckpointGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(pre.isolatedCheckpointTestCount, 6)
        XCTAssertEqual(pre.focusedWholeStepTestCount, 59)
        XCTAssertEqual(pre.depthOneCheckoutCount, 2)
        XCTAssertEqual(pre.securePrivateDependencyFetchInvocationCount, 1)
        XCTAssertEqual(pre.securePrivateDependencyFetchCompletionCount, 1)
        XCTAssertEqual(pre.authenticatedDepthOneFetchCount, 1)
        XCTAssertEqual(pre.submoduleUpdateCount, 1)
        XCTAssertEqual(pre.mlxCloneCount, 1)
        XCTAssertEqual(pre.mlxCCloneCount, 1)
        XCTAssertEqual(pre.workflowAuthoredFetchRetryCount, 0)
        XCTAssertEqual(pre.gitInternalFetchRetryCount, 0)
        XCTAssertEqual(pre.tlsVerificationFailureCount, 0)
        XCTAssertEqual(pre.tlsVerificationBypassCount, 0)
        XCTAssertEqual(pre.customCertificateAuthorityCount, 0)
        XCTAssertTrue(pre.swiftNumericsCacheMappingValidated)
        XCTAssertEqual(pre.swiftNumericsCacheMappingCount, 1)
        XCTAssertEqual(pre.swiftNumericsCacheFetchCompletionCount, 9)
        XCTAssertEqual(pre.swiftNumericsMappedIsolatedInvocationCount, 4)
        XCTAssertEqual(pre.metallibPublicSwiftNumericsFetchCount, 1)
        XCTAssertEqual(pre.metallibPublicSwiftNumericsCheckoutCount, 1)
        XCTAssertTrue(pre.metallibPublicSwiftNumericsResolutionSucceeded)
        XCTAssertEqual(
            pre.swiftNumericsResolvedRevision,
            repair.exactSwiftNumericsRevision
        )
        XCTAssertEqual(
            pre.observedLiveExecutionOrder,
            ["metal", "maintained_runtime", "tokenizer"]
        )
        XCTAssertEqual(pre.metalTestCount, 44)
        XCTAssertEqual(pre.runtimeTestCount, 1)
        XCTAssertEqual(pre.runtimeReceiptCount, 1)
        XCTAssertEqual(pre.tokenizerTestCount, 1)
        XCTAssertEqual(pre.tokenizerReceiptCount, 1)
        XCTAssertEqual(pre.preStage5TestCount, 105)
        XCTAssertEqual(pre.preStage5FailureCount, 0)
        XCTAssertEqual(pre.preStage5SkipCount, 0)
        XCTAssertTrue(
            pre.predecessorStage3TypedInMemoryResumeRemainsEstablished
        )
        XCTAssertTrue(
            pre.predecessorStage4DurableRoundTripRemainsEstablished
        )
        XCTAssertEqual(pre.stage4LauncherInvocationCount, 0)
        XCTAssertEqual(pre.stage6LauncherInvocationCount, 0)

        let failure = observation.assayFailureBoundary
        XCTAssertEqual(failure.failedJobStepNumber, 6)
        XCTAssertEqual(
            failure.failedJobStepName,
            "Run the Prime-owned decoder on live Metal"
        )
        XCTAssertEqual(failure.failureSourceLine, 135)
        XCTAssertEqual(failure.stage5LauncherInvocationCount, 1)
        XCTAssertEqual(failure.stage5BuildInvocationCount, 1)
        XCTAssertEqual(failure.stage5BuildCompletionCount, 1)
        XCTAssertEqual(failure.stage5BuildDurationMilliseconds, 179_580)
        XCTAssertEqual(failure.stage5DirectXCTestInvocationCount, 1)
        XCTAssertEqual(
            failure.testClass,
            "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests"
        )
        XCTAssertEqual(
            failure.testMethod,
            "testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes"
        )
        XCTAssertEqual(failure.testStartCount, 1)
        XCTAssertEqual(failure.testPassCount, 0)
        XCTAssertEqual(failure.testFailureCount, 1)
        XCTAssertEqual(failure.testSkipCount, 0)
        XCTAssertEqual(failure.allReviewedTestStartCount, 106)
        XCTAssertEqual(failure.allReviewedTestPassCount, 105)
        XCTAssertEqual(failure.allReviewedTestFailureCount, 1)
        XCTAssertEqual(failure.allReviewedTestSkipCount, 0)
        XCTAssertEqual(failure.exactFailureSummaryOccurrenceCount, 3)
        XCTAssertEqual(failure.testDurationMilliseconds, 2_205)
        XCTAssertEqual(
            failure.exactThrownError,
            "contractDrift(\"source-step exact bytes\")"
        )
        XCTAssertEqual(failure.exactThrownErrorOccurrenceCount, 1)
        XCTAssertEqual(
            failure.combinedGuardConjuncts,
            [
                "uninterruptedSourceStep == sourceSnapshotSourceStep",
                "uninterruptedSourceStep.result.globalStep == 1",
                "uninterruptedSourceStep.result.selectedTargetCount == 6",
            ]
        )
        XCTAssertTrue(failure.combinedGuardFailed)
        XCTAssertFalse(failure.failedConjunctIdentified)
        XCTAssertFalse(failure.sourceStepEqualityEstablished)
        XCTAssertFalse(failure.sourceStepEqualityDisproved)
        XCTAssertFalse(failure.globalStepOneEstablished)
        XCTAssertFalse(failure.globalStepOneDisproved)
        XCTAssertFalse(failure.selectedTargetCountSixEstablished)
        XCTAssertFalse(failure.selectedTargetCountSixDisproved)
        XCTAssertFalse(failure.failingTrialOrdinalEstablished)
        XCTAssertEqual(failure.failingTrialOrdinalMinimum, 1)
        XCTAssertEqual(failure.failingTrialOrdinalMaximum, 3)
        XCTAssertFalse(failure.priorCompletedTrialCountEstablished)
        XCTAssertEqual(failure.priorCompletedTrialCountMinimum, 0)
        XCTAssertEqual(failure.priorCompletedTrialCountMaximum, 2)
        XCTAssertFalse(failure.globalCompletedBranchCountEstablished)
        XCTAssertTrue(failure.freshSourceObjectsGuardPassedInFailingTrial)
        XCTAssertTrue(failure.bothFirstStepCallsReturnedInFailingTrial)
        XCTAssertTrue(failure.tinyStage5TrainingExecutionObserved)
        XCTAssertFalse(failure.failingTrialEvaluationReached)
        XCTAssertFalse(failure.failingTrialSnapshotReached)
        XCTAssertFalse(failure.receiptPostflightAfterLoopReached)
        XCTAssertEqual(failure.stage5ReceiptAnchoredCount, 0)
        XCTAssertEqual(failure.stage5ReceiptTotalOccurrenceCount, 0)
        XCTAssertFalse(failure.stage5ReceiptConstructed)
        XCTAssertFalse(failure.stage5ReceiptEmitted)
        XCTAssertFalse(failure.stage5DeterminismEstablished)
        XCTAssertEqual(failure.launcherExitCode, 2)
        XCTAssertEqual(failure.launcherFailureLineOccurrenceCount, 1)
        XCTAssertEqual(failure.workflowProcessExitCode, 2)
        XCTAssertEqual(failure.workflowExitAnnotationOccurrenceCount, 1)

        let lease = observation.leaseBoundary
        XCTAssertTrue(
            lease.acquiredBeforeCoreGraphicsMetalOrMLXAccessSourceInferred
        )
        XCTAssertTrue(lease.heldAtFailedGuardSourceInferred)
        XCTAssertFalse(lease.acquisitionFailureObserved)
        XCTAssertFalse(lease.receiptEmittedWhileHeld)
        XCTAssertFalse(lease.receiptFlushedWhileHeld)
        XCTAssertFalse(lease.explicitReleaseImmediatelyAfterReceiptReached)
        XCTAssertTrue(lease.deinitCallsReleaseInFrozenSource)
        XCTAssertFalse(lease.deinitReleaseObservedInTerminalLog)
        XCTAssertTrue(lease.processTerminationReleasesKernelFlock)
        XCTAssertFalse(lease.launcherPostSuccessLeaseFileCleanupReached)
        XCTAssertFalse(lease.leaseFileDeletionObserved)
        XCTAssertFalse(lease.leaseParentDeletionObserved)
        XCTAssertFalse(lease.leaseHeldAfterXCTestProcessExit)

        let artifacts = observation.artifactBoundary
        XCTAssertEqual(artifacts.actionsArtifactsTotalCount, 0)
        XCTAssertTrue(artifacts.actionsArtifactsArrayExactlyEmpty)
        XCTAssertEqual(artifacts.artifactUploadStepCount, 0)
        XCTAssertFalse(artifacts.stage5ReceiptArtifactCreated)
        XCTAssertFalse(artifacts.stage5ReceiptArtifactUploaded)
        XCTAssertFalse(artifacts.stage5ReceiptRetainedInRepository)
        XCTAssertFalse(artifacts.durableJobLogPublicationEstablished)

        let retirement = observation.retirementBoundary
        XCTAssertTrue(retirement.retirementRequired)
        XCTAssertFalse(retirement.retirementObserved)
        XCTAssertEqual(retirement.exactChangedPathCount, 5)
        XCTAssertEqual(retirement.exactOrderedChangedPaths.count, 5)
        XCTAssertEqual(retirement.expectedRootTestCount, 54)
        XCTAssertEqual(
            retirement.expectedIsolatedCheckpointGroupTestCounts,
            [1, 1, 2, 2]
        )
        XCTAssertEqual(retirement.expectedIsolatedCheckpointTestCount, 6)
        XCTAssertEqual(retirement.expectedFocusedWholeStepTestCount, 60)
        XCTAssertEqual(retirement.expectedMetalTestCount, 44)
        XCTAssertEqual(retirement.expectedRuntimeTestCount, 1)
        XCTAssertEqual(retirement.expectedTokenizerTestCount, 1)
        XCTAssertEqual(
            retirement.expectedLiveExecutionOrder,
            pre.observedLiveExecutionOrder
        )
        XCTAssertEqual(retirement.expectedTotalTestCount, 106)
        XCTAssertEqual(retirement.expectedDepthOneCheckoutCount, 2)
        XCTAssertEqual(retirement.expectedStage4LauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedStage5LauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedStage5ReceiptCount, 0)
        XCTAssertEqual(retirement.expectedStage6LauncherInvocationCount, 0)
        XCTAssertTrue(retirement.stage5LauncherMustRemainPreserved)
        XCTAssertEqual(retirement.stage5LauncherGitMode, "100755")
        XCTAssertEqual(
            retirement.stage5LauncherGitBlob,
            sources[1].gitBlob
        )
        XCTAssertEqual(retirement.stage5LauncherSHA256, sources[1].sha256)
        XCTAssertFalse(retirement.replacementLiveExecutionPermittedByRetirement)

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.oneShotExecutionConsumed)
        XCTAssertTrue(ceiling.oneShotExecutionExhausted)
        XCTAssertTrue(ceiling.failureObservationAuthorizesNothing)
        XCTAssertTrue(ceiling.exactRetirementRequired)
        XCTAssertTrue(ceiling.launcherPreservationRequired)
        XCTAssertFalse(
            ceiling.mechanicsImplementationAuthorizedAfterGreenAuthorityClosure
        )
        XCTAssertFalse(ceiling.oneExactMainExecutionOpportunityAuthorized)
        XCTAssertFalse(ceiling.threeBoundedSameProcessAssayTrialsAuthorized)
        XCTAssertFalse(ceiling.inMemorySourceSnapshotAuthorized)
        XCTAssertTrue(ceiling.trainingExecutionObserved)
        XCTAssertTrue(ceiling.stage5MechanicsExecuted)
        XCTAssertFalse(ceiling.stage5ResultEstablished)
        XCTAssertFalse(ceiling.additionalExecutionOrRerunAuthorized)
        XCTAssertFalse(ceiling.stage4RerunAuthorized)
        XCTAssertFalse(ceiling.stage5AssayDurableCheckpointIOObserved)
        XCTAssertFalse(ceiling.durableCheckpointIOAuthorized)
        XCTAssertFalse(ceiling.retainedCheckpointArtifactAuthorized)
        XCTAssertFalse(ceiling.retainedArtifactAuthorized)
        XCTAssertFalse(ceiling.checkpointArtifactUploadAuthorized)
        XCTAssertFalse(ceiling.artifactUploadAuthorized)
        XCTAssertFalse(ceiling.crossDeviceClaimAuthorized)
        XCTAssertFalse(ceiling.exactMetalGradientBytesEstablished)
        XCTAssertFalse(ceiling.metalDeterminismEstablished)
        XCTAssertFalse(ceiling.stage5AssayNative300MModelAllocationObserved)
        XCTAssertFalse(ceiling.native300MAllocationAuthorized)
        XCTAssertFalse(ceiling.native300MTrainingAuthorized)
        XCTAssertFalse(ceiling.native300MTrainingObserved)
        XCTAssertFalse(ceiling.stage5AssayCheckpointResumeEstablished)
        XCTAssertFalse(ceiling.stage5AssayTrainingResumeEstablished)
        XCTAssertFalse(ceiling.generalTrainingEstablished)
        XCTAssertFalse(ceiling.generalTrainingAuthorized)
        XCTAssertFalse(ceiling.generalTrainingResumeEstablished)
        XCTAssertFalse(ceiling.stage6Authorized)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(
            observation.status,
            "FAIL_exact_main_stage5_combined_source_step_guard_one_test_one_failure_no_receipt_no_explicit_cleanup_no_determinism_one_shot_consumed_no_retry_no_stage6"
        )
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 5)

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservation.swift"
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
            "ac735b84948e6b9b6b492a79925d7e0770d6eb332ba4d643d7f2884a4a7f81d2"
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
        XCTAssertGreaterThan(valuePaths.count, 250)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)
        XCTAssertGreaterThan(scalarPaths.count, 180)

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
                replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                label: "null \(pathLabel(path))"
            )
            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
        }
        XCTAssertGreaterThan(regularDecodedDriftCount, 180)

        let arrayPaths = allArrayPaths(in: object)
        var reorderedArrayCount = 0
        for path in arrayPaths {
            var didReorder = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else {
                        return array
                    }
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
        XCTAssertGreaterThan(reorderedArrayCount, 0)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_stage5_failure_field_\(index)"] = true
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
        }

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

    private func allArrayPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)]
                )
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(
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

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )) ?? Data()
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
        XCTAssertFalse(log.rawGitHubLogArchiveBytesBound)
        XCTAssertFalse(log.retainedInRepository)
    }

    private func authorityFalseClaims(
        _ ceiling: Observation.AuthorityCeiling
    ) -> [Bool] {
        [
            ceiling.mechanicsImplementationAuthorizedAfterGreenAuthorityClosure,
            ceiling.oneExactMainExecutionOpportunityAuthorized,
            ceiling.threeBoundedSameProcessAssayTrialsAuthorized,
            ceiling.inMemorySourceSnapshotAuthorized,
            ceiling.rerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.stage4RerunAuthorized,
            ceiling.stage5ReceiptEstablished,
            ceiling.stage5ResultEstablished,
            ceiling.stage5MechanicsSuccessEstablished,
            ceiling.repeatedTrajectoryDeterminismEstablished,
            ceiling.stage5AssayCheckpointResumeEstablished,
            ceiling.stage5AssayDurableCheckpointIOObserved,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedCheckpointArtifactAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.checkpointArtifactUploadAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.crossDeviceDeterminismEstablished,
            ceiling.crossDeviceClaimAuthorized,
            ceiling.exactMetalGradientBytesEstablished,
            ceiling.metalDeterminismEstablished,
            ceiling.stage5AssayNative300MModelAllocationObserved,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingEstablished,
            ceiling.native300MTrainingAuthorized,
            ceiling.native300MTrainingObserved,
            ceiling.generalTrainingEstablished,
            ceiling.generalTrainingAuthorized,
            ceiling.stage5AssayTrainingResumeEstablished,
            ceiling.generalTrainingResumeEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage6AuthorityEstablished,
            ceiling.stage6Authorized,
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
