// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityTests:
    XCTestCase
{
    typealias Authority =
        PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        let authority = Authority.frozenV1
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.roadmap.stageID,
            "native300m_resource_only_one_step_probe_v1")
        XCTAssertEqual(
            authority.roadmap.requiredPredecessorStageID,
            "tiny_repeated_metal_trajectory_determinism_assay_v1")
        XCTAssertTrue(authority.roadmap.predecessorStageLifecycleCompleted)
        XCTAssertFalse(authority.roadmap.predecessorResultEstablished)
        XCTAssertFalse(authority.roadmap.predecessorAssayClearanceEstablished)
        XCTAssertTrue(
            authority.roadmap.nextStageRequiresAssayAndResourceClearance)
        XCTAssertFalse(authority.roadmap.nextStageAuthorizedByThisAuthority)

        XCTAssertTrue(authority.stage5Failure.stage5MechanicsExecuted)
        XCTAssertTrue(authority.stage5Failure.oneShotExecutionConsumed)
        XCTAssertTrue(authority.stage5Failure.oneShotExecutionExhausted)
        XCTAssertFalse(authority.stage5Failure.stage5ResultEstablished)
        XCTAssertFalse(
            authority.stage5Failure.stage5MechanicsSuccessEstablished)
        XCTAssertFalse(
            authority.stage5Failure.repeatedTrajectoryDeterminismEstablished)
        XCTAssertFalse(
            authority.stage5Failure.exactMetalGradientBytesEstablished)
        XCTAssertTrue(authority.stage5Retirement.stage5InvocationRetired)
        XCTAssertEqual(authority.stage5Retirement.workflowRunID, 31_763_253_701)
        XCTAssertEqual(authority.stage5Retirement.workflowRunNumber, 107)
        XCTAssertEqual(authority.stage5Retirement.rootTestCount, 54)
        XCTAssertEqual(authority.stage5Retirement.focusedWholeTestCount, 60)
        XCTAssertEqual(authority.stage5Retirement.totalTestCount, 106)
        XCTAssertEqual(authority.stage5Retirement.stage5LauncherInvocationCount, 0)
        XCTAssertEqual(authority.stage5Retirement.stage6LauncherInvocationCount, 0)

        XCTAssertEqual(authority.configuration.initializationSeed, 44)
        XCTAssertEqual(authority.configuration.batchSize, 1)
        XCTAssertEqual(authority.configuration.sequenceLength, 128)
        XCTAssertEqual(authority.configuration.validTokenCount, 128)
        XCTAssertEqual(authority.configuration.selectedTargetCount, 127)
        XCTAssertEqual(authority.configuration.batchTokenIDs[0].count, 128)
        XCTAssertEqual(
            authority.configuration.batchCompletionMask[0],
            [false] + Array(repeating: true, count: 127))
        XCTAssertEqual(
            authority.configuration.optimizerQualifiedType,
            "MLXOptimizers.AdamW")
        XCTAssertEqual(authority.configuration.parameterDType, "float32")
        XCTAssertEqual(
            authority.configuration.lossGraphAlgorithmID,
            "prime_stage6_causal_masked_mean_cross_entropy_f32_v1")
        XCTAssertEqual(authority.configuration.tokenIDStorageDType, "int32")
        XCTAssertEqual(authority.configuration.completionMaskStorageDType, "bool")
        XCTAssertEqual(
            authority.configuration.trainingLogitsExpectedShape,
            [1, 128, 512])
        XCTAssertEqual(
            authority.configuration.shiftedLogitsExpectedShape,
            [1, 127, 512])
        XCTAssertEqual(
            authority.configuration.shiftedTargetsExpectedShape,
            [1, 127])
        XCTAssertTrue(authority.configuration.shiftedCompletionMaskAllTrue)
        XCTAssertEqual(authority.configuration.crossEntropyReduction, "none")
        XCTAssertEqual(authority.configuration.perTargetLossDType, "float32")
        XCTAssertEqual(
            authority.configuration.perTargetLossExpectedShape,
            [1, 127])
        XCTAssertEqual(
            authority.configuration.perTargetLossExpectedElementCount,
            127)
        XCTAssertTrue(
            authority.configuration
                .perTargetLossShapeAndDTypeValidatedInsideValueAndGradClosureBeforeReduction)
        XCTAssertEqual(authority.configuration.lossDType, "float32")
        XCTAssertEqual(authority.configuration.lossExpectedRank, 0)
        XCTAssertFalse(
            authority.configuration.independentOrDetachedLossAuthorized)
        XCTAssertEqual(
            authority.configuration.rawGradientNormAlgorithmID,
            "prime_stage6_global_f32_l2_norm_utf8_catalog_v1")
        XCTAssertEqual(
            authority.configuration.gradientClipAlgorithmID,
            "prime_stage6_global_norm_clip_f32_v1")
        XCTAssertTrue(
            authority.configuration.gradientClipOccursExactlyOnceBeforeAdamW)
        XCTAssertTrue(
            authority.configuration.adamWConsumesOnlyClippedGradientCatalog)
        XCTAssertEqual(
            authority.configuration.parameterFingerprintExpectedSampleCount,
            654)
        XCTAssertFalse(
            authority.configuration.parameterFingerprintFullTensorHostCopyAuthorized)
        XCTAssertFalse(authority.configuration.adamWBiasCorrectionApplied)
        XCTAssertEqual(
            authority.configuration.optimizerStateInspectionAPI,
            "MLXOptimizers.AdamW.innerState()")
        XCTAssertEqual(authority.configuration.optimizerStateExpectedArrayCount, 436)
        XCTAssertEqual(authority.configuration.optimizerStateExpectedPairCount, 218)
        XCTAssertFalse(
            authority.configuration.optimizerNamedStateExportDuringProbeAuthorized)
        XCTAssertTrue(authority.configuration.optimizerStateMustBeEmptyBeforeUpdate)
        XCTAssertEqual(
            authority.configuration.postUpdateFullStateEvaluationAPI,
            "checkedEval(model,optimizer,after_fingerprint_sample_views)")
        XCTAssertEqual(
            authority.configuration.postModelFullStateEvaluationAPI,
            "checkedEval(model,before_fingerprint_sample_views)")
        XCTAssertFalse(authority.configuration.paddingAuthorized)
        XCTAssertFalse(authority.configuration.kvCacheAuthorized)
        XCTAssertFalse(
            authority.configuration.modelQualityOrReadOnlyEvaluationAuthorized)
        XCTAssertFalse(authority.configuration.generationAuthorized)
        XCTAssertFalse(authority.configuration.checkpointAuthorized)

        XCTAssertEqual(
            authority.resourceEnvelope.minimumCommittedTensorStateByteCount,
            3_253_284_864)
        XCTAssertEqual(
            authority.resourceEnvelope.minimumStatePlusGradientByteCount,
            4_337_713_152)
        XCTAssertEqual(
            authority.resourceEnvelope
                .threeTimesCommittedStateDiskComparatorByteCount,
            9_759_854_592)
        XCTAssertEqual(
            authority.resourceEnvelope.minimumAvailableFilesystemByteCount,
            12_884_901_888)
        XCTAssertTrue(
            authority.resourceEnvelope
                .preflightAbstainWhenAvailableFilesystemBelowMinimum)
        XCTAssertEqual(
            authority.environment.authorityClosureReviewedJobTimeoutMinutes,
            60)
        XCTAssertFalse(
            authority.environment
                .authorityClosureWorkflowTimeoutMutationAuthorized)
        XCTAssertEqual(
            authority.environment.successorReviewedJobTimeoutMinutes,
            90)
        XCTAssertTrue(
            authority.environment
                .successorReviewedWorkflowTimeoutMutationAuthorized)
        XCTAssertTrue(authority.environment.metalDeviceHasUnifiedMemoryRequired)
        XCTAssertEqual(
            authority.resourceEnvelope.configuredMLXMemoryLimitFormula,
            "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)")
        XCTAssertEqual(
            authority.environment.filesystemObservationTarget,
            "resolved_swiftpm_scratch_directory_containing_release_executable")
        XCTAssertTrue(
            authority.environment
                .filesystemObservationRequiresScratchAndExecutableSameFSID)
        XCTAssertEqual(
            authority.environment.mlxDefaultDeviceScopeAPI,
            "Device.withDefaultDevice(executionDevice)")
        XCTAssertEqual(
            authority.environment.mlxDefaultDeviceObjectIdentityAPI,
            "Device.defaultDevice()===executionDevice")
        XCTAssertFalse(authority.environment.mlxCPUFallbackAuthorized)
        XCTAssertEqual(
            authority.environment.mlxPeakMemoryResetAPI,
            "MLX.Memory.peakMemory = 0")
        XCTAssertEqual(authority.environment.mlxPeakMemoryResetCount, 1)
        XCTAssertTrue(
            authority.environment.metalCurrentAllocatedSizeObservationRequired)
        XCTAssertEqual(authority.futureProbe.workerActiveTimeoutSeconds, 1_200)
        XCTAssertEqual(
            authority.futureProbe.supervisorEndToEndTimeoutSeconds,
            1_500)
        XCTAssertEqual(authority.futureProbe.directXCTestCount, 1)
        XCTAssertEqual(authority.futureProbe.directExecutableProbeCount, 1)
        XCTAssertEqual(authority.futureProbe.aggregateDirectInvocationCount, 2)
        XCTAssertEqual(
            authority.futureProbe.releaseBuildCommand,
            "swift build --package-path Tests/PrimeNativeDecoderTrainingValidation --configuration release --build-tests")
        XCTAssertEqual(
            authority.futureProbe.releaseContractXCTestCommand,
            "swift test --package-path Tests/PrimeNativeDecoderTrainingValidation --configuration release --skip-build --filter PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests/testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure")
        XCTAssertTrue(authority.futureProbe.releaseContractXCTestUsesSkipBuild)
        XCTAssertEqual(authority.futureProbe.swiftRunInvocationCount, 0)
        XCTAssertEqual(authority.futureProbe.additionalBuildCount, 0)
        XCTAssertEqual(authority.futureProbe.supervisorProcessCount, 1)
        XCTAssertEqual(authority.futureProbe.maximumWorkerProcessCount, 1)
        XCTAssertEqual(authority.futureProbe.workerSpawnAttemptCount, 1)
        XCTAssertEqual(authority.futureProbe.valueAndGradCount, 1)
        XCTAssertEqual(authority.futureProbe.gradientNormCount, 1)
        XCTAssertEqual(authority.futureProbe.gradientClipCount, 1)
        XCTAssertEqual(authority.futureProbe.adamWUpdateCount, 1)
        XCTAssertEqual(authority.futureProbe.fullGraphEvaluationCount, 1)
        XCTAssertEqual(authority.futureProbe.checkedEvaluationBarrierCount, 5)
        XCTAssertEqual(authority.futureProbe.gpuSynchronizationBarrierCount, 5)
        XCTAssertEqual(authority.futureProbe.memoryClearCacheCount, 1)
        XCTAssertEqual(authority.futureProbe.postflightDeviceReenumerationCount, 1)
        XCTAssertEqual(
            authority.futureProbe.phaseElapsedSemantics,
            "cumulative_from_worker_probe_epoch_to_boundary_snapshot")
        XCTAssertTrue(
            authority.futureProbe
                .filesystemFSIDMustRemainStableAcrossObservedPhases)
        XCTAssertEqual(authority.futureProbe.kvCacheAllocationCount, 0)
        XCTAssertEqual(authority.futureProbe.evaluationForwardPassCount, 0)
        XCTAssertEqual(authority.futureProbe.resourceMeasurementBoundaries.count, 6)
        XCTAssertEqual(
            authority.futureProbe.normativeMaximumWorkerCandidateFrameCount,
            1)
        XCTAssertEqual(authority.futureProbe.passWorkerCandidateFrameCount, 1)
        XCTAssertEqual(authority.futureProbe.abstainAcceptedWorkerCandidateCount, 0)
        XCTAssertEqual(
            authority.environment.requiredMetricKeysAtEveryCompletedBoundary,
            Array(authority.receiptContract.phaseMetricKeys.dropFirst(3)))
        XCTAssertEqual(
            authority.receiptContract.nullableNumericMetricKeys,
            authority.environment.requiredMetricKeysAtEveryCompletedBoundary)
        XCTAssertEqual(
            authority.receiptContract.nullableEnvironmentObservationKeys.count,
            15)
        XCTAssertEqual(
            authority.receiptContract.nullableLimitObservationKeys.count,
            11)
        XCTAssertEqual(
            authority.receiptContract.nullableOutcomeObservationKeys.count,
            10)
        XCTAssertEqual(
            authority.receiptContract.nullableExecutionTerminationKeys,
            [
                "worker_exit_code", "worker_signal", "worker_spawn_errno",
                "worker_last_complete_frame_sequence",
                "worker_active_elapsed_nanoseconds",
                "worker_timeout_trigger_elapsed_nanoseconds",
                "supervisor_timeout_trigger_elapsed_nanoseconds",
                "timeout_scope",
            ])
        XCTAssertEqual(
            authority.receiptContract.topLevelKeys,
            [
                "authority", "ceiling", "configuration", "environment",
                "execution", "lease", "limits", "outcome",
                "phase_metrics", "receipt_id", "schema_version",
            ])
        XCTAssertEqual(
            authority.receiptContract.statusDomain,
            ["PASS", "ABSTAIN"])
        XCTAssertEqual(
            authority.receiptContract.classificationDomain,
            ["pass"] + authority.futureProbe.abstainClasses)
        XCTAssertTrue(
            authority.receiptContract.classificationDomain.contains(
                "worker_spawn_failure"))
        XCTAssertTrue(authority.receiptContract.canonicalSortedJSONRequired)
        XCTAssertEqual(
            authority.receiptContract.nonPhaseUnavailableEncoding,
            "JSON_null_with_keys_present")
        XCTAssertTrue(
            authority.receiptContract
                .unavailableReasonNullIffAvailabilityObserved)
        XCTAssertTrue(
            authority.receiptContract
                .unavailableReasonEqualsClassificationIffAvailabilityUnavailable)
        XCTAssertEqual(
            authority.receiptContract.abstainPhasePartitionRule,
            "all_six_rows_present_as_contiguous_possibly_empty_observed_prefix_plus_possibly_empty_unavailable_suffix")
        XCTAssertTrue(
            authority.receiptContract
                .abstainUnavailableSuffixMayBeEmptyOnlyWhenAllSixBoundariesWereObservedBeforeClassification)
        XCTAssertTrue(
            authority.receiptContract
                .passRequiresAllEnvironmentLimitAndOutcomeObservationsNonNull)
        XCTAssertEqual(authority.receiptContract.passWorkerExitCode, 0)
        XCTAssertTrue(authority.receiptContract.passWorkerSignalMustBeNull)
        XCTAssertTrue(authority.receiptContract.passWorkerTimeoutMustBeFalse)
        XCTAssertEqual(authority.receiptContract.configurationKeys.count, 45)
        XCTAssertEqual(authority.receiptContract.environmentKeys.count, 26)
        XCTAssertEqual(authority.receiptContract.executionKeys.count, 52)
        XCTAssertEqual(authority.receiptContract.limitsKeys.count, 29)
        XCTAssertEqual(authority.receiptContract.outcomeKeys.count, 19)
        XCTAssertEqual(authority.receiptContract.operationCountKeys.count, 19)
        XCTAssertTrue(
            authority.receiptContract.operationCountKeys.contains(
                "mlx_peak_memory_reset_count"))
        XCTAssertTrue(authority.receiptContract.workerCandidateAcceptedIffPASS)
        XCTAssertTrue(
            authority.receiptContract.abstainObservedCandidateFrameRule.contains(
                "late_wait_status_timeout_candidate_payload_or_transport_validation_or_trailing_partial_ABSTAIN_may_be_1"))
        XCTAssertTrue(
            authority.receiptContract.abstainObservedCandidateFrameRule.contains(
                "duplicate_frame_executor_receipt_drift_may_be_at_least_2"))
        XCTAssertTrue(
            authority.receiptContract.allABSTAINReceiptsSupervisorSynthesized)
        XCTAssertTrue(
            authority.receiptContract
                .passPostflightDeviceIdentityMatchesPreflightMustBeTrue)
        XCTAssertTrue(
            authority.receiptContract
                .passPostflightMLXPolicyAndLimitsMatchPreflightMustBeTrue)
        XCTAssertEqual(authority.receiptContract.workerFrameSchemaVersion, 1)
        XCTAssertEqual(
            authority.receiptContract.workerFrameMaximumByteCount,
            1_048_576)
        XCTAssertTrue(
            authority.receiptContract
                .workerTransportFrameByteCountIncludesFinalLF)
        XCTAssertTrue(
            authority.receiptContract
                .supervisorCompletesAllFallibleWorkBeforeCanonicalEmission)
        XCTAssertTrue(
            authority.receiptContract
                .supervisorHasNoFallibleWorkAssertionsDefersOrCleanupAfterFlush)
        XCTAssertTrue(authority.receiptContract.supervisorSoleReceiptStdoutOwner)
        XCTAssertEqual(authority.receiptContract.workerStdoutReceiptCount, 0)
        XCTAssertEqual(authority.receiptContract.terminalSupervisorReceiptCount, 1)
        XCTAssertTrue(
            authority.receiptContract
                .launcherValidatesEitherCanonicalStatusAndExitsZero)
        XCTAssertTrue(
            authority.receiptContract
                .invalidReceiptDriftOrUncontainedNoReceiptFailureExitsNonzero)
        XCTAssertEqual(authority.receiptContract.ceilingKeys.count, 25)
        XCTAssertEqual(authority.receiptContract.outcomeTransitionKeys.count, 5)
        XCTAssertEqual(authority.authorityClosureScope.exactChangedPaths.count, 5)
        XCTAssertEqual(authority.successorScope.exactChangedPaths.count, 8)
        XCTAssertFalse(
            authority.authorityClosureScope.newTrainingProbeSourceAuthorized)
        XCTAssertFalse(
            authority.authorityClosureScope
                .existingTrainingSourceMutationAuthorized)
        XCTAssertTrue(
            authority.authorityClosureScope.newStage6AuthorityTestAuthorized)
        XCTAssertFalse(
            authority.authorityClosureScope
                .newStage6MechanicsPureContractTestAuthorized)
        XCTAssertTrue(authority.successorScope.newTrainingProbeSourceAuthorized)
        XCTAssertFalse(
            authority.successorScope.existingTrainingSourceMutationAuthorized)
        XCTAssertFalse(
            authority.successorScope.newStage6AuthorityTestAuthorized)
        XCTAssertTrue(
            authority.successorScope
                .newStage6MechanicsPureContractTestAuthorized)
        XCTAssertTrue(
            authority.successorScope
                .trainingValidationManifestMutationAuthorized)
        XCTAssertTrue(authority.successorScope.newStage6LauncherAuthorized)
        XCTAssertTrue(
            authority.successorScope.newStage6ExecutableMainAuthorized)
        XCTAssertEqual(
            authority.successorManifest.newExecutableTargetDirectProductDependencies,
            [
                ".product(name:\"PrimeNativeDecoderTraining\",package:\"ergentics-prime\")",
            ])
        XCTAssertEqual(
            authority.successorManifest.newExecutableMainImports,
            ["Foundation", "PrimeNativeDecoderTraining"])
        XCTAssertEqual(
            authority.successorManifest.newContractTestClassName,
            "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests")
        XCTAssertEqual(
            authority.successorManifest.newContractTestMethodName,
            "testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure")
        XCTAssertEqual(
            authority.successorManifest.newContractTestFilter,
            "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests/testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure")
        XCTAssertEqual(
            authority.successorManifest.focusedValidationContractTestFilter,
            authority.successorManifest.newContractTestFilter)
        XCTAssertEqual(
            authority.successorManifest.stage6LauncherContractTestFilter,
            authority.successorManifest.newContractTestFilter)
        XCTAssertTrue(
            authority.successorManifest
                .bothContractTestInvocationsUseSameExactFilterOnce)
        XCTAssertEqual(
            authority.successorManifest.existingTestTargetLinkerFrameworks,
            ["CoreGraphics", "Metal"])
        XCTAssertTrue(
            authority.successorManifest.rootPackageManifestMustRemainByteIdentical)
        XCTAssertEqual(authority.suite.authorityRootTestCount, 55)
        XCTAssertEqual(authority.suite.authorityFocusedWholeTestCount, 61)
        XCTAssertEqual(authority.suite.authorityTotalTestCount, 107)
        XCTAssertEqual(
            authority.suite.futureStage6PureContractFocusedXCTestCount,
            1)
        XCTAssertEqual(
            authority.suite.futureStage6PureContractDirectXCTestCount,
            1)
        XCTAssertEqual(
            authority.suite.futureStage6PureContractXCTestStartCount,
            2)
        XCTAssertEqual(
            authority.suite.futureStage6ExecutableOperationalProbeCount,
            1)
        XCTAssertEqual(
            authority.suite.futureStage6LauncherLocalAggregateDirectInvocationCount,
            2)
        XCTAssertEqual(authority.suite.futureStage6AggregateInvocationCount, 3)
        XCTAssertEqual(authority.suite.futureMechanicsXCTestTotalCount, 109)
        XCTAssertEqual(
            authority.suite.futureMechanicsLiveOrder,
            ["metal", "maintained_runtime", "tokenizer", "stage6"])
        XCTAssertEqual(
            authority.suite.futureStage6InternalOrder,
            [
                "stage6_pure_contract_xctest",
                "stage6_resource_probe_executable",
            ])

        XCTAssertTrue(authority.ceiling.authorityOnlyNoProbeResultEvidence)
        XCTAssertTrue(
            authority.ceiling
                .mechanicsImplementationAuthorizedAfterGreenAuthorityClosure)
        XCTAssertTrue(
            authority.ceiling.oneExactMainResourceProbeOpportunityAuthorized)
        XCTAssertTrue(
            authority.ceiling
                .oneNative300MAllocationAuthorizedForResourceProbe)
        XCTAssertTrue(
            authority.ceiling
                .oneNative300MTrainingStepAuthorizedForResourceProbe)
        XCTAssertTrue(authority.ceiling.boundedResourceMeasurementAuthorized)
        XCTAssertTrue(authority.ceiling.tinyTypedInMemoryResumeEstablished)
        XCTAssertTrue(authority.ceiling.tinyDurableSnapshotRoundTripEstablished)
        XCTAssertTrue(falseCeilings(authority).allSatisfy { !$0 })

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        let canonicalSHA256 = PrimeSHA256.hexDigest(of: canonical)
        XCTAssertEqual(canonicalSHA256, Authority.canonicalSHA256)
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any])
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let arrayPaths = allArrayPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 250)
        XCTAssertGreaterThan(dictionaryPaths.count, 15)
        XCTAssertGreaterThan(arrayPaths.count, 10)
        XCTAssertGreaterThan(scalarPaths.count, 175)

        var regularDecodedDriftCount = 0
        for path in valuePaths {
            let mutatedData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))")
            if let loose = try? JSONDecoder().decode(
                Authority.self,
                from: mutatedData), loose != authority
            {
                regularDecodedDriftCount += 1
                XCTAssertThrowsError(try loose.validateExactV1())
            }
            _ = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: { _ in NSNull() }),
                label: "null \(pathLabel(path))")
            _ = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))")
        }
        XCTAssertGreaterThan(regularDecodedDriftCount, 175)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(in: object, at: path) { value in
                var dictionary = value as! [String: Any]
                dictionary["unknown_stage6_authority_field_\(index)"] = true
                return dictionary
            }
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown \(pathLabel(path))")
            let loose = try JSONDecoder().decode(Authority.self, from: unknownData)
            XCTAssertEqual(loose, authority)
        }

        var reorderedArrayCount = 0
        for path in arrayPaths {
            var didReorder = false
            let reordered = replacingValue(in: object, at: path) { value in
                var array = value as! [Any]
                guard array.count >= 2 else { return array }
                for left in 0 ..< array.count {
                    for right in (left + 1) ..< array.count {
                        if canonicalJSONFragment(array[left])
                            != canonicalJSONFragment(array[right])
                        {
                            array.swapAt(left, right)
                            didReorder = true
                            return array
                        }
                    }
                }
                return array
            }
            if didReorder {
                _ = try assertCanonicalRejects(
                    reordered,
                    label: "reordered \(pathLabel(path))")
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 0)
        try assertNoncanonicalEncodingsReject(canonical, object: object)

        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repositoryRoot.appendingPathComponent(
            "Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthority.swift")
        let sourceText = try String(contentsOf: sourceURL, encoding: .utf8)
        XCTAssertFalse(
            sourceText.contains("__PRIME_STAGE6_AUTHORITY_CANONICAL_SHA256__"))
        XCTAssertEqual(
            sourceText.split(separator: "\n").filter {
                $0.hasPrefix("import ")
            }.map(String.init),
            ["import Foundation"])
        for forbidden in [
            "import CoreGraphics", "import Darwin", "import Metal",
            "import MLX", "import MLXNN", "import MLXOptimizers",
            "FileManager.", "FileHandle.", "URLSession", "Process(",
            "posix_spawn", "execve(", "Memory.snapshot(",
        ] {
            XCTAssertFalse(sourceText.contains(forbidden), forbidden)
        }
        let testText = try String(contentsOfFile: #filePath, encoding: .utf8)
        XCTAssertEqual(
            testText.components(separatedBy: "func " + "test").count - 1,
            1)
    }

    private func falseCeilings(_ authority: Authority) -> [Bool] {
        let ceiling = authority.ceiling
        return [
            ceiling.stage5ReplacementExecutionAuthorized,
            ceiling.stage5ResultEstablished,
            ceiling.stage5MechanicsSuccessEstablished,
            ceiling.stage5AssayClearanceEstablished,
            ceiling.exactMetalGradientBytesEstablished,
            ceiling.repeatedTrajectoryDeterminismEstablished,
            ceiling.metalDeterminismEstablished,
            ceiling.resourceProbeExecuted,
            ceiling.resourceEnvelopeEstablished,
            ceiling.resourceClearanceEstablished,
            ceiling.ordinaryJobFitEstablished,
            ceiling.runnerMemoryCapacityEstablished,
            ceiling.broadNative300MTrainingAuthorized,
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.native300MTrajectoryTrainingResumeEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map { component in
            switch component {
            case let .key(key): return key
            case let .index(index): return "[\(index)]"
            }
        }.joined(separator: ".")
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
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
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

    private func allScalarPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
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
                in: object[key]!, at: remainder, with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index], at: remainder, with: transform)
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
        XCTFail("unsupported canonical JSON value")
        return value
    }

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes])) ?? Data()
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
            options: [.sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line)
        return data
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data([0x20]) + canonical))
        XCTAssertThrowsError(
            try Authority.decodeCanonical(canonical + Data([0x0a])))
        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        XCTAssertThrowsError(
            try Authority.decodeCanonical(Data(slashEscaped.utf8)))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let firstQuote = try XCTUnwrap(duplicate.firstIndex(of: "\""))
        let keyStart = duplicate.index(after: firstQuote)
        let keyEnd = try XCTUnwrap(duplicate[keyStart...].firstIndex(of: "\""))
        let key = String(duplicate[keyStart ..< keyEnd])
        duplicate.insert(
            contentsOf: "\"\(key)\":null,",
            at: duplicate.index(after: duplicate.startIndex))
        XCTAssertThrowsError(try Authority.decodeCanonical(Data(duplicate.utf8)))
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
