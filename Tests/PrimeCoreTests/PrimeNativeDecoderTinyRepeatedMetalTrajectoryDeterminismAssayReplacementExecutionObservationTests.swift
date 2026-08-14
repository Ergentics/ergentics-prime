// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationTests:
    XCTestCase
{
    private typealias Observation =
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndSplitOutcomeCeiling()
        throws
    {
        let observation = Observation.frozenV1

        XCTAssertNoThrow(try observation.validate())
        XCTAssertNoThrow(try observation.validateExactV1())
        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_observation_v1"
        )
        XCTAssertEqual(
            observation.observationKind,
            "terminal_exact_main_stage5_replacement_pass_clearance_with_separate_outer_launcher_postflight_failure"
        )
        XCTAssertEqual(
            observation.predecessorAuthorityID,
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                .frozenV1.authorityID
        )
        XCTAssertEqual(
            observation.predecessorAuthorityCanonicalSHA256,
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                .canonicalSHA256
        )

        let repository = observation.repositoryIdentity
        XCTAssertEqual(repository.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(repository.pullRequestNumber, 110)
        XCTAssertEqual(repository.ref, "refs/heads/main")
        XCTAssertEqual(
            repository.baseRevision,
            "a0ce9561bdbc867b12f13aed7a7f54846faf3020"
        )
        XCTAssertEqual(
            repository.baseTree,
            "e7f85dcecbc82b7e74065cc1991175152f53c13f"
        )
        XCTAssertEqual(
            repository.reviewedHeadRevision,
            "c778d7955976f2412826060aca3e1eb9e839d01d"
        )
        XCTAssertEqual(repository.reviewedHeadTree, repository.mergeTree)
        XCTAssertEqual(
            repository.mergeRevision,
            "68422b34425fce761ce8d4afcbd7b0edbc1cf648"
        )
        XCTAssertEqual(
            repository.mergeTree,
            "658f7f2aa6a023efb37520bd7596c37b474ecda1"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [repository.baseRevision, repository.reviewedHeadRevision]
        )
        XCTAssertEqual(repository.mergedAt, "2026-08-14T19:42:53Z")
        XCTAssertTrue(repository.mergeCommitSignatureVerified)
        XCTAssertEqual(repository.mergeCommitSignatureReason, "valid")
        XCTAssertTrue(repository.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(repository.exactMainRefMatchedAtTerminalAudit)
        XCTAssertEqual(repository.changedPathCount, 10)
        XCTAssertEqual(repository.manifestOrLockChangedPathCount, 0)

        let sources = observation.observedSourceBindings
        XCTAssertEqual(sources.count, 10)
        XCTAssertEqual(Set(sources.map(\.path)).count, 10)
        XCTAssertEqual(
            sources.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage5-repeated-trajectory-replacement.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift",
                "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift",
                "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift",
            ]
        )
        XCTAssertTrue(
            sources.allSatisfy {
                ["100644", "100755"].contains($0.gitMode)
                    && isLowercaseHex($0.gitBlob, count: 40)
                    && $0.byteCount > 0
                    && isLowercaseHex($0.sha256, count: 64)
                    && !$0.role.isEmpty
            }
        )
        XCTAssertEqual(sources[1].byteCount, 60_532)
        XCTAssertEqual(
            sources[8].sha256,
            "62aa2bdd1ac68c83630f771fe58ac36fa2e4a885e5e657cbcc56efe33b4ac836"
        )

        let run = observation.runIdentity
        XCTAssertEqual(run.workflowID, 329_017_041)
        XCTAssertEqual(run.runID, 31_834_513_845)
        XCTAssertEqual(run.runNumber, 117)
        XCTAssertEqual(run.runAttempt, 1)
        XCTAssertEqual(run.checkSuiteID, 86_367_936_511)
        XCTAssertEqual(run.event, "push")
        XCTAssertEqual(run.headBranch, "main")
        XCTAssertEqual(run.headRevision, repository.mergeRevision)
        XCTAssertEqual(run.actor, "psyop-archivist")
        XCTAssertEqual(run.triggeringActor, run.actor)
        XCTAssertEqual(run.createdAt, "2026-08-14T19:42:56Z")
        XCTAssertEqual(run.startedAt, run.createdAt)
        XCTAssertEqual(run.terminalUpdatedAt, "2026-08-14T20:34:30Z")
        XCTAssertEqual(run.status, "completed")
        XCTAssertEqual(run.conclusion, "failure")
        XCTAssertEqual(run.exactHeadPushRunCount, 1)
        XCTAssertTrue(run.previousAttemptURLWasNull)
        XCTAssertEqual(run.rerunCount, 0)
        XCTAssertFalse(run.rerunObserved)
        XCTAssertFalse(run.rerunAuthorized)
        XCTAssertEqual(run.artifactCount, 0)

        let active = observation.activeRootJob
        XCTAssertEqual(active.id, 94_877_692_182)
        XCTAssertEqual(active.conclusion, "success")
        XCTAssertEqual(active.runnerID, 1_000_001_766)
        XCTAssertEqual(active.runnerLabel, "macos-15")
        XCTAssertEqual(active.orderedStepNames.count, 7)
        XCTAssertEqual(
            active.orderedStepConclusions,
            Array(repeating: "success", count: 7)
        )
        XCTAssertEqual(active.checkAnnotationCount, 0)

        let reviewed = observation.reviewedMainJob
        XCTAssertEqual(reviewed.id, 94_878_305_625)
        XCTAssertEqual(reviewed.conclusion, "failure")
        XCTAssertEqual(reviewed.runnerID, 1_000_001_767)
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
        XCTAssertEqual(reviewed.checkAnnotationLine, 75_394)
        XCTAssertEqual(
            reviewed.checkAnnotationMessage,
            "Process completed with exit code 2."
        )

        assertRawLog(
            observation.activeRootRawLog,
            byteCount: 272_058,
            lfByteCount: 1_820,
            sha256:
                "b86a463fd351bd91e25bb7dfa2929c88a7ab07c2d2c21f84a0050cab33b3f1cb"
        )
        assertRawLog(
            observation.reviewedMainRawLog,
            byteCount: 10_345_902,
            lfByteCount: 79_185,
            sha256:
                "baf8736d0578a5c92440ada6400bb07318d5b122c87de6be6f3a405782445f78"
        )

        let topology = observation.testTopology
        XCTAssertEqual(topology.rootTestCount, 58)
        XCTAssertEqual(topology.isolatedCheckpointGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(topology.isolatedCheckpointTestCount, 6)
        XCTAssertEqual(topology.focusedWholeTestCount, 64)
        XCTAssertEqual(topology.metalTestCount, 44)
        XCTAssertEqual(topology.maintainedRuntimeTestCount, 1)
        XCTAssertEqual(topology.tokenizerTestCount, 1)
        XCTAssertEqual(topology.replacementAssayTestCount, 1)
        XCTAssertEqual(topology.totalTestCount, 111)
        XCTAssertEqual(topology.totalFailureCount, 0)
        XCTAssertEqual(topology.totalSkipCount, 0)
        XCTAssertEqual(
            topology.observedLiveExecutionOrder,
            ["metal", "maintained_runtime", "tokenizer", "stage5_replacement"]
        )

        let assay = observation.replacementTestBoundary
        XCTAssertEqual(assay.jobStepNumber, 6)
        XCTAssertEqual(assay.jobStepStartedAt, "2026-08-14T20:09:40Z")
        XCTAssertEqual(assay.jobStepCompletedAt, "2026-08-14T20:34:19Z")
        XCTAssertEqual(assay.launcherInvocationCount, 1)
        XCTAssertEqual(assay.buildInvocationCount, 1)
        XCTAssertEqual(assay.buildCompletionCount, 1)
        XCTAssertEqual(assay.buildDurationMilliseconds, 187_840)
        XCTAssertEqual(assay.directXCTestInvocationCount, 1)
        XCTAssertEqual(
            assay.testClass,
            "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests"
        )
        XCTAssertEqual(
            assay.testMethod,
            "testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume"
        )
        XCTAssertEqual(assay.testStartCount, 1)
        XCTAssertEqual(assay.testPassCount, 1)
        XCTAssertEqual(assay.testFailureCount, 0)
        XCTAssertEqual(assay.testSkipCount, 0)
        XCTAssertEqual(assay.testDurationMilliseconds, 6_932)
        XCTAssertEqual(assay.receiptCount, 1)
        XCTAssertEqual(assay.receiptStatus, "PASS_CLEARANCE")
        XCTAssertTrue(assay.receiptEmittedBeforeTestPass)

        let receipt = observation.receiptIdentity
        XCTAssertEqual(
            receipt.prefix,
            "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1="
        )
        XCTAssertEqual(receipt.prefixByteCount, 51)
        XCTAssertEqual(receipt.canonicalJSONByteCount, 13_036)
        XCTAssertEqual(
            receipt.canonicalJSONSHA256,
            "ce939ca5f6e9e5d37cf61b412dcb02d811495909466903c8575169265a330fb0"
        )
        XCTAssertEqual(receipt.storageByteCountIncludingLF, 13_037)
        XCTAssertEqual(
            receipt.storageSHA256IncludingLF,
            "b8b202c0408d0379a390e4fe12053ef4ac79914c4431e5eb93ba55c64578e2e0"
        )
        XCTAssertEqual(receipt.prefixedCanonicalByteCount, 13_087)
        XCTAssertEqual(
            receipt.prefixedCanonicalSHA256,
            "2154abe45f7e0c65e8196f8ebc4aabab0363caf18ce93d10c72f822ac8ade1f3"
        )
        XCTAssertEqual(receipt.prefixedCanonicalLFByteCount, 13_088)
        XCTAssertEqual(
            receipt.prefixedCanonicalLFSHA256,
            "751c73d0cca21c4a705345fa9c76ba480df850d353aae005179c6272c6cf4f8c"
        )
        XCTAssertEqual(receipt.fullTimestampedLineByteCount, 13_116)
        XCTAssertEqual(
            receipt.fullTimestampedLineSHA256,
            "cce381a08a4b77b2210ede6511dd7ae61c15eca4db1371dccceb4980f2fc4b3f"
        )
        XCTAssertEqual(receipt.logLineNumber, 79_175)
        XCTAssertEqual(receipt.emittedAt, "2026-08-14T20:34:19.4169310Z")
        XCTAssertEqual(receipt.exactOccurrenceCount, 1)
        XCTAssertEqual(receipt.status, "PASS_CLEARANCE")
        XCTAssertEqual(receipt.authorityID, observation.predecessorAuthorityID)
        XCTAssertEqual(
            receipt.authorityCanonicalSHA256,
            observation.predecessorAuthorityCanonicalSHA256
        )
        XCTAssertEqual(
            receipt.canonicalJSON,
            Observation.frozenReceiptCanonicalJSON
        )

        let receiptData = try XCTUnwrap(receipt.canonicalJSON.data(using: .utf8))
        XCTAssertEqual(receiptData.count, 13_036)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: receiptData),
            receipt.canonicalJSONSHA256
        )
        let receiptObject = try XCTUnwrap(
            JSONSerialization.jsonObject(with: receiptData) as? [String: Any]
        )
        XCTAssertEqual(
            receiptObject.keys.sorted(),
            [
                "arm_a", "arm_b", "authority", "ceiling", "environment",
                "execution", "forward_equivalence", "operation_counts",
                "receipt_id", "schema_version", "status",
            ]
        )
        XCTAssertEqual(receiptObject["status"] as? String, "PASS_CLEARANCE")
        XCTAssertEqual(receiptObject["schema_version"] as? Int, 1)
        XCTAssertGreaterThan(allValuePaths(in: receiptObject).count, 190)
        XCTAssertGreaterThan(allDictionaryPaths(in: receiptObject).count, 55)
        XCTAssertGreaterThan(allScalarPaths(in: receiptObject).count, 140)

        let counts = observation.operationCounts
        XCTAssertEqual(counts.armASourceStepCount, 6)
        XCTAssertEqual(counts.armBTrainingStepCount, 15)
        XCTAssertEqual(counts.armBEvaluateCount, 18)
        XCTAssertEqual(counts.armBSnapshotCount, 3)
        XCTAssertEqual(counts.armBRestoreCount, 3)
        XCTAssertEqual(counts.armBForwardEquivalenceCheckCount, 9)
        XCTAssertEqual(counts.armBInputEmbeddingPairSeamCount, 9)
        XCTAssertEqual(counts.armBDenseWholeLogitsCallCount, 57)
        XCTAssertEqual(counts.armBDenseEmbeddingConstructionCount, 66)
        XCTAssertEqual(counts.armBTokenBoundsValidationCount, 66)
        XCTAssertEqual(counts.armBTokenBoundsCheckedEvalCount, 66)
        XCTAssertEqual(counts.armBTokenBoundsGPUSynchronizeCount, 66)
        XCTAssertEqual(counts.armBTokenBoundsHostBoolItemCount, 66)
        XCTAssertEqual(counts.synchronizeCount, 75)
        XCTAssertEqual(counts.receiptCount, 1)

        let clearance = observation.clearanceBoundary
        XCTAssertTrue(clearance.armAIsDiagnosticOnly)
        XCTAssertFalse(clearance.armAGatesOrSkipsArmB)
        XCTAssertEqual(clearance.armATrialCount, 3)
        XCTAssertEqual(clearance.armACompletedDiagnosticPairCount, 3)
        XCTAssertFalse(clearance.armAMeasuredMismatch)
        XCTAssertEqual(clearance.armBTrialCount, 3)
        XCTAssertEqual(clearance.armBBranchCount, 9)
        XCTAssertEqual(clearance.armBBranchNames.count, 3)
        XCTAssertEqual(clearance.armBComparisonDomains.count, 7)
        XCTAssertTrue(clearance.armBAllExactComparisonsPassed)
        XCTAssertTrue(clearance.armBAllForwardEquivalenceChecksPassed)
        XCTAssertFalse(clearance.armBFirstMismatchObserved)
        XCTAssertTrue(clearance.sameModelPreMutationForwardEquivalence)
        XCTAssertTrue(clearance.sameDeviceBPathExactGradientBytesEstablished)
        XCTAssertTrue(clearance.repeatedSameDeviceBPathDeterminismEstablished)
        XCTAssertTrue(clearance.stage5MechanicsSuccessEstablished)
        XCTAssertTrue(clearance.stage5ResultEstablished)
        XCTAssertTrue(clearance.stage5AssayClearanceEstablished)

        let outer = observation.outerLauncherFailureBoundary
        XCTAssertTrue(outer.testOutcomeWasPass)
        XCTAssertTrue(outer.outerWorkflowOutcomeWasFailure)
        XCTAssertTrue(outer.failureOccurredAfterReceiptAndTestPass)
        XCTAssertEqual(outer.aggregateGuardSourceLines, [1122, 1123, 1124, 1125, 1126])
        XCTAssertEqual(outer.aggregateGuardConjuncts.count, 6)
        XCTAssertTrue(outer.aggregateGuardFailed)
        XCTAssertFalse(outer.failedConjunctIdentified)
        XCTAssertFalse(outer.actualLeaseParentMetadataObserved)
        XCTAssertEqual(
            outer.exactLauncherFailureMessage,
            "replacement lease parent identity changed"
        )
        XCTAssertEqual(
            outer.exactFailureLine,
            "swift-driver version: 1.148.6 prime-native-decoder-stage5-repeated-trajectory-replacement: replacement lease parent identity changed"
        )
        XCTAssertEqual(outer.failureLoggedAt, "2026-08-14T20:34:19.5246420Z")
        XCTAssertEqual(outer.exactFailureLineOccurrenceCount, 1)
        XCTAssertEqual(outer.launcherExitCode, 2)
        XCTAssertEqual(outer.workflowProcessExitCode, 2)
        XCTAssertEqual(outer.workflowExitAnnotationOccurrenceCount, 1)
        XCTAssertFalse(outer.localAPFSLinkCountReproductionBoundAsCause)
        XCTAssertTrue(outerUnreachedClaims(outer).allSatisfy { !$0 })

        let lease = observation.leaseBoundary
        XCTAssertEqual(
            lease.environmentKey,
            "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_METAL_LEASE_PATH"
        )
        XCTAssertTrue(lease.acquiredBeforeCoreGraphicsMetalOrMLX)
        XCTAssertEqual(lease.retainedDeviceName, "Apple Paravirtual device")
        XCTAssertEqual(lease.retainedDeviceRegistryID, 4_294_967_800)
        XCTAssertTrue(lease.receiptConstructedValidatedAndRoundTrippedWhileHeld)
        XCTAssertTrue(lease.receiptEmissionCheckedWhileHeld)
        XCTAssertTrue(lease.receiptFlushCheckedWhileHeld)
        XCTAssertTrue(lease.explicitReleaseAfterReceiptReached)
        XCTAssertFalse(lease.outerLeaseParentCleanupCompleted)

        let retirement = observation.retirementBoundary
        XCTAssertTrue(retirement.retirementRequired)
        XCTAssertFalse(retirement.retirementObserved)
        XCTAssertEqual(retirement.exactChangedPathCount, 5)
        XCTAssertEqual(retirement.exactOrderedChangedPaths.count, 5)
        XCTAssertEqual(retirement.expectedRootTestCount, 59)
        XCTAssertEqual(retirement.expectedIsolatedCheckpointGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(retirement.expectedIsolatedCheckpointTestCount, 6)
        XCTAssertEqual(retirement.expectedFocusedWholeTestCount, 65)
        XCTAssertEqual(retirement.expectedMetalTestCount, 44)
        XCTAssertEqual(retirement.expectedMaintainedRuntimeTestCount, 1)
        XCTAssertEqual(retirement.expectedTokenizerTestCount, 1)
        XCTAssertEqual(retirement.expectedReplacementAssayTestCount, 0)
        XCTAssertEqual(retirement.expectedTotalTestCount, 111)
        XCTAssertEqual(retirement.expectedFailureCount, 0)
        XCTAssertEqual(retirement.expectedSkipCount, 0)
        XCTAssertEqual(
            retirement.expectedLiveExecutionOrder,
            ["metal", "maintained_runtime", "tokenizer"]
        )
        XCTAssertEqual(retirement.expectedOriginalStage5LauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedOriginalStage5ReceiptCount, 0)
        XCTAssertEqual(retirement.expectedReplacementStage5LauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedReplacementStage5ReceiptCount, 0)
        XCTAssertEqual(retirement.expectedStage6LauncherInvocationCount, 0)
        XCTAssertEqual(retirement.expectedStage6ReceiptCount, 0)
        XCTAssertEqual(retirement.expectedReviewedMainTimeoutMinutes, 60)
        XCTAssertTrue(retirement.replacementLauncherPreservedForAudit)
        XCTAssertTrue(retirement.replacementAssaySourcePreservedForAudit)
        XCTAssertFalse(retirement.replacementLiveExecutionPermittedByRetirement)

        let ceiling = observation.authorityCeiling
        XCTAssertTrue(ceiling.oneShotConsumed)
        XCTAssertTrue(ceiling.oneShotExhausted)
        XCTAssertTrue(ceiling.stage5ReceiptEstablished)
        XCTAssertTrue(ceiling.stage5MechanicsSuccessEstablished)
        XCTAssertTrue(ceiling.stage5ResultEstablished)
        XCTAssertTrue(ceiling.stage5AssayClearanceEstablished)
        XCTAssertFalse(ceiling.launcherPostReceiptCompletionEstablished)
        XCTAssertFalse(ceiling.outerWorkflowSuccessEstablished)
        XCTAssertTrue(ceiling.repeatedSameDeviceBPathDeterminismEstablished)
        XCTAssertTrue(ceiling.exactSameDeviceBPathGradientBytesEstablished)
        XCTAssertFalse(ceiling.defaultGatherDeterminismEstablished)
        XCTAssertFalse(ceiling.arbitraryTokenDeterminismEstablished)
        XCTAssertFalse(ceiling.crossDeviceDeterminismEstablished)
        XCTAssertFalse(ceiling.additionalExecutionOrRerunAuthorized)
        XCTAssertFalse(ceiling.durableCheckpointIOAuthorized)
        XCTAssertFalse(ceiling.retainedArtifactAuthorized)
        XCTAssertFalse(ceiling.artifactUploadAuthorized)
        XCTAssertFalse(ceiling.candidateAdmissionGranted)
        XCTAssertFalse(ceiling.modelQualityEstablished)
        XCTAssertFalse(ceiling.downstreamTrialAuthorized)
        XCTAssertFalse(ceiling.canaryAuthorized)
        XCTAssertFalse(ceiling.quantizationAuthorized)
        XCTAssertFalse(ceiling.productUseAuthorized)
        XCTAssertFalse(ceiling.publicationAuthorized)
        XCTAssertTrue(ceiling.stage6HistoricalResourceClearanceRemainsEstablished)
        XCTAssertFalse(ceiling.stage6HistoricalResourceClearanceAppliesToBPath)
        XCTAssertFalse(ceiling.bSpecificNative300ResourceWitnessEstablished)
        XCTAssertFalse(ceiling.bSpecificNative300ResourceWitnessAuthorized)
        XCTAssertTrue(ceiling.bSpecificNative300ResourceWitnessRequiresSeparateAuthority)
        XCTAssertTrue(ceiling.stage7RequiresNewBSpecificNative300ResourceWitness)
        XCTAssertTrue(ceiling.stage7RequiresSeparateAuthorityAfterWitness)
        XCTAssertFalse(ceiling.stage7AuthorityEstablished)
        XCTAssertFalse(ceiling.stage7Authorized)
        XCTAssertTrue(authorityFalseClaims(ceiling).allSatisfy { !$0 })
        XCTAssertEqual(observation.orderedRequiredSeparateActions.count, 5)
        XCTAssertEqual(
            observation.status,
            "PASS_CLEARANCE_exact_main_stage5_replacement_one_test_passed_one_receipt_then_outer_launcher_postflight_failure_one_shot_consumed_no_rerun_stage7_false"
        )

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservation.swift"
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
            Observation.canonicalSHA256
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
        XCTAssertGreaterThan(valuePaths.count, 280)
        XCTAssertGreaterThan(dictionaryPaths.count, 25)
        XCTAssertGreaterThan(scalarPaths.count, 220)

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
        XCTAssertGreaterThan(regularDecodedDriftCount, 220)

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
                    dictionary["unknown_stage5_pass_field_\(index)"] = true
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

    private func outerUnreachedClaims(
        _ boundary: Observation.OuterLauncherFailureBoundary
    ) -> [Bool] {
        [
            boundary.nextLeaseFileGuardReached,
            boundary.exactChildInventoryGuardReached,
            boundary.leaseFileRemovalReached,
            boundary.leaseParentRemovalReached,
            boundary.cleanupAbsenceProofReached,
            boundary.repositoryPostflightReached,
            boundary.privateWorkingDirectoryPostflightReached,
            boundary.metallibPostflightReached,
            boundary.launcherOKMarkerReached,
        ]
    }

    private func authorityFalseClaims(
        _ ceiling: Observation.AuthorityCeiling
    ) -> [Bool] {
        [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.replacementExecutionAuthorized,
            ceiling.launcherPostReceiptCompletionEstablished,
            ceiling.outerWorkflowSuccessEstablished,
            ceiling.defaultGatherDeterminismEstablished,
            ceiling.arbitraryTokenDeterminismEstablished,
            ceiling.crossDeviceDeterminismEstablished,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.candidateAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage6HistoricalResourceClearanceAppliesToBPath,
            ceiling.bSpecificNative300ResourceWitnessEstablished,
            ceiling.bSpecificNative300ResourceWitnessAuthorized,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
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
