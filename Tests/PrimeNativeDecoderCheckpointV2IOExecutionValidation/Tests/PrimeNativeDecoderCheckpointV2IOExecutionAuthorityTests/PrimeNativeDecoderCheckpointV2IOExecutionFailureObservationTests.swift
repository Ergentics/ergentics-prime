// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
import XCTest

import PrimeCore

final class PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests:
    XCTestCase
{
    func testFailedAttemptObservationIsExactExhaustedAndPure() throws {
        let observation =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1
                .frozenV1
        try observation.validateExactV1()

        XCTAssertEqual(observation.schemaVersion, 1)
        XCTAssertEqual(
            observation.observationID,
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_failure_observation_v1")
        XCTAssertEqual(
            observation.observationKind,
            "github_reviewed_main_exact_one_shot_checkpoint_v2_io_failure_observation")
        XCTAssertTrue(observation.predecessorAuthorityRemainsFrozen)
        XCTAssertTrue(observation.predecessorAuthorityRequiredForConsumption)
        XCTAssertTrue(observation.predecessorAuthorityValidated)
        XCTAssertEqual(observation.predecessorBaseSourceBindingCount, 12)
        XCTAssertEqual(
            observation.predecessorNewExecutionSourceBindingCount,
            6)

        XCTAssertEqual(
            observation.authoritativeRepository,
            "Ergentics/ergentics-prime")
        XCTAssertEqual(observation.observedPullRequestNumber, 77)
        XCTAssertEqual(observation.observedRef, "refs/heads/main")
        XCTAssertEqual(
            observation.observedRevision,
            "27749af3347437daa693d4375acb759283923a4a")
        XCTAssertEqual(
            observation.observedOrderedParentRevisions,
            [
                "b861fa8270cbdceefd6079f7e09fece495fc4b79",
                "93fdf5119a8c293412d1505288222699f657613d",
            ])
        XCTAssertEqual(
            observation.observedTree,
            "a222082fa6b5c469cc4da967a77cbb7e4960e455")
        XCTAssertEqual(
            observation.reviewedPullRequestHeadTree,
            observation.observedTree)
        XCTAssertTrue(observation.historyPreservingTwoParentMergeObserved)
        XCTAssertTrue(observation.mergeTreeEqualsReviewedHeadTree)
        XCTAssertTrue(observation.exactDirectSuccessorOfAuthorizedBaseObserved)
        XCTAssertEqual(observation.observedSourceBindings.count, 10)
        XCTAssertEqual(
            Set(observation.observedSourceBindings.map(\.path)).count,
            10)

        XCTAssertEqual(observation.workflowID, 329_017_041)
        XCTAssertEqual(observation.runID, 31_472_165_002)
        XCTAssertEqual(observation.runNumber, 51)
        XCTAssertEqual(observation.runAttempt, 1)
        XCTAssertEqual(observation.runEvent, "push")
        XCTAssertEqual(observation.runStatus, "completed")
        XCTAssertEqual(observation.runConclusion, "failure")
        XCTAssertEqual(observation.activeRootJobID, 93_717_678_740)
        XCTAssertEqual(observation.activeRootJobConclusion, "success")
        XCTAssertTrue(observation.activeRootJobSucceeded)
        XCTAssertEqual(observation.reviewedMainJobID, 93_718_282_081)
        XCTAssertEqual(observation.reviewedMainJobConclusion, "failure")
        XCTAssertTrue(observation.reviewedMainRanAfterActiveRootSuccess)
        XCTAssertEqual(
            observation.reviewedMainOrderedStepConclusions,
            [
                "success", "success", "success", "success", "success",
                "failure", "success",
            ])
        XCTAssertEqual(
            observation.liveStepName,
            "Run the Prime-owned decoder on live Metal")
        XCTAssertEqual(observation.liveStepConclusion, "failure")

        XCTAssertEqual(observation.activeJobRenderedLogByteCount, 314_687)
        XCTAssertEqual(observation.activeJobRenderedLogLineCount, 1_707)
        XCTAssertEqual(
            observation.reviewedMainJobRenderedLogByteCount,
            14_369_398)
        XCTAssertEqual(
            observation.reviewedMainJobRenderedLogLineCount,
            77_706)
        XCTAssertTrue(observation.renderedJobLogsBound)
        XCTAssertFalse(observation.rawGitHubLogArchiveBytesBound)
        XCTAssertFalse(observation.jobLogsRetainedInRepository)
        XCTAssertFalse(observation.durableJobLogPublicationEstablished)
        XCTAssertEqual(observation.publishedWorkflowArtifactCount, 0)
        XCTAssertFalse(observation.checkpointArtifactUploaded)

        XCTAssertEqual(observation.runnerImage, "macos-26-arm64")
        XCTAssertEqual(observation.operatingSystemVersion, "26.5.2")
        XCTAssertEqual(observation.operatingSystemBuild, "25F84")
        XCTAssertEqual(observation.architecture, "arm64")
        XCTAssertEqual(observation.xcodeVersion, "26.6")
        XCTAssertEqual(observation.xcodeBuildVersion, "17F113")
        XCTAssertTrue(observation.exactHostedRunnerImageRecorded)
        XCTAssertFalse(observation.exactPhysicalRunnerIdentityRecorded)

        XCTAssertEqual(
            observation.exactMLXRevision,
            "d37885a278f1c37484a94d0f401a418735e66519")
        XCTAssertEqual(observation.metallibByteCount, 6_292_716)
        XCTAssertEqual(
            observation.metallibSHA256,
            "28f37e46c6fddadfe602a1534c1dacd337c2700908494c5eaeb3917f8c20de2b")
        XCTAssertTrue(observation.freshMetallibBuildSucceeded)
        XCTAssertFalse(observation.metallibBytesRetainedInRepository)
        XCTAssertFalse(observation.metallibArtifactUploaded)
        XCTAssertFalse(observation.metallibArtifactProvenanceEstablished)

        XCTAssertTrue(observation.predecessorMetalGateSucceeded)
        XCTAssertTrue(observation.predecessorMaintainedRuntimeClosureSucceeded)
        XCTAssertTrue(observation.predecessorTokenizerCompatibilitySucceeded)
        XCTAssertEqual(observation.predecessorValidatedLogCount, 8)
        XCTAssertEqual(observation.predecessorValidatedReceiptCount, 2)
        XCTAssertEqual(
            observation.exactAuthorizedRunnerTemporaryPathCountReclaimed,
            24)
        XCTAssertTrue(
            observation.authorizedRunnerTemporaryReclamationCompleted)

        XCTAssertEqual(
            observation.exactOrderedFailureLines,
            [
                "prime-native-decoder-checkpoint-v2-io-execution-probe: contract drift: artifact root changed identity during write",
                "prime-native-decoder-checkpoint-v2-io: Release probe failed",
                "Process completed with exit code 2.",
            ])
        XCTAssertEqual(observation.probeProcessExitCode, 2)
        XCTAssertEqual(observation.receiptBeginMarkerCount, 0)
        XCTAssertEqual(observation.receiptChunkMarkerCount, 0)
        XCTAssertEqual(observation.receiptEndMarkerCount, 0)
        XCTAssertFalse(observation.executionEvidenceValueConstructed)
        XCTAssertFalse(observation.canonicalReceiptConstructed)
        XCTAssertFalse(observation.canonicalReceiptEmitted)

        XCTAssertEqual(observation.initializationSeed, 42)
        XCTAssertEqual(
            observation.callerSourceModelConstructionCountSourceInferred,
            1)
        XCTAssertEqual(
            observation.initialParameterMaterializationEvaluationCountSourceInferred,
            1)
        XCTAssertEqual(
            observation.initialParameterMaterializationEvaluationAPI,
            "MLX.checkedEval(model)")
        XCTAssertEqual(observation.memoryCacheLimitSourceInferred, 0)
        XCTAssertEqual(
            observation.memoryCacheClearInvocationCountSourceInferred,
            1)
        XCTAssertEqual(
            observation.publicCheckpointWriteInvocationCountSourceInferred,
            1)
        XCTAssertEqual(
            observation.publicCheckpointWriteCompletionCountSourceInferred,
            1)
        XCTAssertTrue(observation.externalBindingReturnSourceInferred)
        XCTAssertFalse(
            observation.externalBindingFieldsIndependentlyObserved)
        XCTAssertEqual(
            observation.publicCheckpointLoadInvocationCountSourceInferred,
            0)
        XCTAssertEqual(
            observation.publicCheckpointLoadCompletionCountSourceInferred,
            0)
        XCTAssertTrue(
            observation.sourceModelLexicalScopeEndedBeforeFailureSourceInferred)
        XCTAssertFalse(observation.sourceModelARCDeallocationObserved)
        XCTAssertFalse(
            observation.postWriteRootStableObjectIdentityGuardPassed)
        XCTAssertFalse(observation.publishedArtifactPathInspectionCompleted)
        XCTAssertFalse(observation.artifactRootIdentityBeforeWriteEmitted)
        XCTAssertFalse(observation.artifactRootIdentityAfterWriteEmitted)
        XCTAssertFalse(observation.artifactRootChangedFieldIdentifiedByRun)
        XCTAssertEqual(
            observation.localDiagnosticRootLinkCountBeforeLeafAddition,
            2)
        XCTAssertEqual(
            observation.localDiagnosticRootLinkCountAfterLeafAddition,
            3)
        XCTAssertFalse(observation.localDiagnosisIsFailedRunTelemetry)
        XCTAssertFalse(observation.parentReceiptVerificationCompleted)
        XCTAssertFalse(observation.parentArtifactUnlinkCompleted)
        XCTAssertFalse(observation.parentArtifactRootRmdirCompleted)
        XCTAssertFalse(observation.eventualRunnerVMCleanupObserved)

        XCTAssertTrue(observation.predecessorAuthorityAttemptConsumed)
        XCTAssertTrue(observation.predecessorAuthorityExhausted)
        XCTAssertFalse(observation.rerunObserved)
        XCTAssertFalse(observation.rerunAuthorized)
        XCTAssertFalse(observation.replacementExecutionAuthorityEstablished)
        XCTAssertFalse(observation.native300MModelAllocationIndependentlyObserved)
        XCTAssertFalse(observation.native300MCheckpointWriteIndependentlyObserved)
        XCTAssertFalse(observation.native300MCheckpointLoadObserved)
        XCTAssertFalse(observation.checkpointIORoundTripObserved)
        XCTAssertFalse(
            observation.checkpointArtifactAvailabilityEstablished)
        XCTAssertFalse(
            observation.checkpointArtifactRetentionEstablished)
        XCTAssertFalse(observation.checkpointArtifactProvenanceEstablished)
        XCTAssertFalse(
            observation.checkpointContainerHashIndependentlyObserved)
        XCTAssertFalse(observation.checkpointAdmissionGranted)
        XCTAssertFalse(observation.checkpointDurabilityObserved)
        XCTAssertFalse(observation.logicalParameterRoundTripObserved)
        XCTAssertFalse(observation.checkpointLoadedForwardObserved)
        XCTAssertFalse(
            observation.optimizerStateInclusionObservedByCheckpointAttempt)
        XCTAssertFalse(
            observation.rngStateInclusionObservedByCheckpointAttempt)
        XCTAssertFalse(
            observation.dataCursorInclusionObservedByCheckpointAttempt)
        XCTAssertFalse(
            observation.kvCacheStateInclusionObservedByCheckpointAttempt)
        XCTAssertFalse(observation.decoderForwardObservedByCheckpointAttempt)
        XCTAssertFalse(observation.backwardInvokedByCheckpointAttempt)
        XCTAssertFalse(observation.trainingExecutionObserved)
        XCTAssertFalse(observation.productUseAuthorized)
        XCTAssertFalse(observation.publicationAuthorized)
        XCTAssertEqual(
            observation.status,
            "ABSTAIN_seed42_public_write_return_source_inferred_postwrite_root_guard_failed_no_load_no_receipt_no_artifact_admission")
        XCTAssertEqual(
            observation.orderedNextActions,
            [
                "append_exact_failed_attempt_observation_and_remove_exhausted_live_command",
                "repair_artifact_root_identity_semantics_without_reclassifying_the_failed_run",
                "require_a_separate_successor_execution_authority_before_any_new_attempt",
            ])

        let encoded = try JSONEncoder().encode(observation)
        XCTAssertEqual(
            try JSONDecoder().decode(
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1
                    .self,
                from: encoded),
            observation)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: encoded)
                as? [String: Any])
        let mutations = recursiveMutations(of: object, path: "$root")
        XCTAssertGreaterThan(mutations.count, 200)

        var decodedMutationCount = 0
        var rejectedAtDecodeCount = 0
        for (label, mutatedObject) in mutations {
            let data = try JSONSerialization.data(
                withJSONObject: mutatedObject,
                options: [.sortedKeys])
            do {
                let mutated = try JSONDecoder().decode(
                    PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1
                        .self,
                    from: data)
                decodedMutationCount += 1
                XCTAssertThrowsError(
                    try mutated.validateExactV1(),
                    "failure-observation mutation accepted: \(label)"
                ) { error in
                    XCTAssertEqual(
                        error as?
                            PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationError,
                        .contractDrift,
                        "unexpected mutation error for \(label)")
                }
            } catch is DecodingError {
                rejectedAtDecodeCount += 1
            }
        }
        XCTAssertGreaterThan(decodedMutationCount, 150)
        XCTAssertGreaterThan(rejectedAtDecodeCount, 0)
        XCTAssertEqual(
            decodedMutationCount + rejectedAtDecodeCount,
            mutations.count)
    }

    private func recursiveMutations(
        of value: Any,
        path: String
    ) -> [(String, Any)] {
        if let dictionary = value as? [String: Any] {
            var result = [(String, Any)]()
            for key in dictionary.keys.sorted() {
                guard let child = dictionary[key] else { continue }
                for (childLabel, childMutation) in recursiveMutations(
                    of: child,
                    path: "\(path).\(key)"
                ) {
                    var copy = dictionary
                    copy[key] = childMutation
                    result.append((childLabel, copy))
                }
            }
            if let firstKey = dictionary.keys.sorted().first {
                var copy = dictionary
                copy.removeValue(forKey: firstKey)
                result.append(("\(path).remove.\(firstKey)", copy))
            }
            return result
        }
        if let array = value as? [Any] {
            var result = [(String, Any)]()
            for index in array.indices {
                for (childLabel, childMutation) in recursiveMutations(
                    of: array[index],
                    path: "\(path)[\(index)]"
                ) {
                    var copy = array
                    copy[index] = childMutation
                    result.append((childLabel, copy))
                }
            }
            if !array.isEmpty {
                var dropped = array
                dropped.removeLast()
                result.append(("\(path).drop", dropped))
                var duplicated = array
                duplicated.append(array[0])
                result.append(("\(path).duplicate", duplicated))
            }
            if array.count > 1,
               !jsonValuesAreEqual(array[0], array[1]) {
                var reordered = array
                reordered.swapAt(0, 1)
                result.append(("\(path).reorder", reordered))
            }
            return result
        }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return [("\(path).boolean", !number.boolValue)]
            }
            return [
                (
                    "\(path).number",
                    NSNumber(value: number.int64Value + 1)
                ),
            ]
        }
        if let string = value as? String {
            return [("\(path).string", string + "_mutated")]
        }
        return [("\(path).type", "unexpected_mutation")]
    }

    private func jsonValuesAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        let lhsData = try? JSONSerialization.data(
            withJSONObject: ["value": lhs],
            options: [.sortedKeys])
        let rhsData = try? JSONSerialization.data(
            withJSONObject: ["value": rhs],
            options: [.sortedKeys])
        return lhsData == rhsData
    }
}
