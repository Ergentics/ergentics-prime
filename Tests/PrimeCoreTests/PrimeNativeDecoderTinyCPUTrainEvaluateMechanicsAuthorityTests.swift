// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityTests:
    XCTestCase
{
    private typealias Authority =
        PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveMutationAndCeiling()
        throws
    {
        let authority = Authority.frozenV1

        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.currentStage,
            PrimeNativeDecoderTrajectoryExactResumeStageV1
                .tinyCPUTrainEvaluateMechanics.rawValue
        )
        XCTAssertEqual(
            authority.predecessorAuthorityID,
            PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1
                .frozenV1.authorityID
        )

        let repository = authority.repositoryIdentity
        XCTAssertEqual(
            repository.revision,
            "605d47dde85715f356e4d6e11beb3a3262cc4e7e"
        )
        XCTAssertEqual(
            repository.tree,
            "72200da83e2ae16f3986c525e3a6cd13b47869c4"
        )
        XCTAssertEqual(
            repository.orderedParentRevisions,
            [
                "5eeba9e6483bafd1bbb5c96753491b3dd1609ea0",
                "defbefcc49a0dea3cbe723af0015a670323fe0e4",
            ]
        )
        XCTAssertTrue(repository.historyPreservingTwoParentMerge)
        XCTAssertTrue(repository.mergeTreeEqualsReviewedHeadTree)
        XCTAssertEqual(
            repository.embeddedSourceIdentitySHA256,
            "8b207cf27ccab08f95b652f340e23f4a8846942e6027ca2e9536218a418c91d5"
        )
        XCTAssertTrue(
            repository
                .embeddedIdentityCoversAdmittedPackageSourceTestAndDocumentationClosure
        )
        XCTAssertTrue(
            repository
                .everyPredecessorRepositoryInputUsedByAuthorityIsEmbeddedOrExactlyBound
        )
        XCTAssertTrue(repository.externalDependenciesExcludedFromEmbeddedIdentity)
        XCTAssertTrue(repository.currentArcSourceClosureRefreshRequired)

        let evidence = authority.reviewedMainEvidence
        XCTAssertEqual(evidence.workflowRunID, 31_515_766_609)
        XCTAssertEqual(evidence.workflowRunAttempt, 1)
        XCTAssertEqual(evidence.activeRootJobID, 93_860_388_811)
        XCTAssertEqual(evidence.reviewedMainJobID, 93_861_112_336)
        XCTAssertEqual(evidence.reviewedMainTimeoutMinutes, 60)
        XCTAssertTrue(evidence.reviewedMainCompletedInsideTimeout)
        XCTAssertEqual(evidence.exactFocusedTestCount, 39)
        XCTAssertEqual(evidence.exactFocusedFailureCount, 0)
        XCTAssertEqual(evidence.metalTestCount, 44)
        XCTAssertEqual(evidence.metalFailureCount, 0)
        XCTAssertEqual(
            evidence.liveSequence,
            [
                "metal_44_of_44",
                "runtime_receipt",
                "tokenizer_receipt",
            ]
        )
        XCTAssertEqual(evidence.runtimeReceiptCount, 1)
        XCTAssertEqual(evidence.tokenizerReceiptCount, 1)
        XCTAssertEqual(evidence.seed42CheckpointCommandCount, 0)
        XCTAssertEqual(evidence.seed43CheckpointCommandCount, 0)
        XCTAssertEqual(evidence.checkpointReceiptMarkerCount, 0)
        XCTAssertEqual(evidence.artifactUploadStepCount, 0)
        XCTAssertEqual(evidence.actionsArtifactCount, 0)
        XCTAssertEqual(evidence.rerunCount, 0)
        XCTAssertTrue(
            evidence.firstAndOnlyWorkflowAttemptCompletedSuccessfully
        )
        XCTAssertEqual(evidence.activeRootSealedRawJobLogByteCount, 228_177)
        XCTAssertEqual(
            evidence.activeRootSealedRawJobLogSHA256.utf8.count,
            64
        )
        XCTAssertTrue(
            isLowercaseHex(evidence.activeRootSealedRawJobLogSHA256)
        )
        XCTAssertEqual(
            evidence.reviewedMainSealedRawJobLogByteCount,
            10_232_197
        )
        XCTAssertEqual(
            evidence.reviewedMainSealedRawJobLogSHA256.utf8.count,
            64
        )
        XCTAssertTrue(
            isLowercaseHex(evidence.reviewedMainSealedRawJobLogSHA256)
        )

        XCTAssertEqual(authority.internalSourceBindings.count, 9)
        XCTAssertEqual(authority.externalSourceBindings.count, 23)
        XCTAssertEqual(
            authority.externalSourceBindings.map(\.path),
            [
                "Source/MLX/Device.swift",
                "Source/MLX/Stream.swift",
                "Source/MLX/State.swift",
                "Source/MLX/Random.swift",
                "Source/MLX/MLXArray.swift",
                "Source/MLX/Transforms+Eval.swift",
                "Source/MLX/Transforms+Grad.swift",
                "Source/MLX/Transforms+Internal.swift",
                "Source/MLX/Nested.swift",
                "Source/MLXNN/Module.swift",
                "Source/MLXNN/Linear.swift",
                "Source/MLXNN/Embedding.swift",
                "Source/MLXNN/ValueAndGrad.swift",
                "Source/MLXNN/Losses.swift",
                "Source/MLXOptimizers/Optimizers.swift",
                "Source/MLXOptimizers/AdamOptimizerState.swift",
                "mlx/scheduler.h",
                "mlx/scheduler.cpp",
                "mlx/backend/metal/device.cpp",
                "mlx/c/stream.cpp",
                "mlx/backend/metal/metal.cpp",
                "mlx/backend/metal/device_info.cpp",
                "mlx/backend/metal/eval.cpp",
            ]
        )
        let addedBootstrapBindings = authority.externalSourceBindings.suffix(4)
        XCTAssertEqual(
            addedBootstrapBindings.map(\.repository),
            ["ml-explore/mlx-c", "ml-explore/mlx", "ml-explore/mlx", "ml-explore/mlx"]
        )
        XCTAssertEqual(
            addedBootstrapBindings.map(\.gitBlob),
            [
                "2d17997b386fd11ff5f8d66b0b0e007ab439e460",
                "51bd2e62ff2d44849f55cac58f7b1b118dde5ed4",
                "b8f5f0e752271b2ae75833300723c5f26bf3f93f",
                "bd58a691a9546d1c5186d74964df1cdf5c703f95",
            ]
        )
        XCTAssertEqual(
            addedBootstrapBindings.map(\.byteCount),
            [2_929, 1_407, 1_621, 2_851]
        )
        XCTAssertEqual(
            addedBootstrapBindings.map(\.sha256),
            [
                "46e0b11db1e5d9c484406eff357a235339e344dd7724f3bd33dacefdd0a9c4ef",
                "15f9a639a2be2d971f0dee00189d0737da208d4facb21e8d41dc74e7633001a8",
                "90f160d788d670c0bb89db50fb5bc99490499058e218fd00f6915ca3d7c176f5",
                "934ba9a4e6acf729fc554ad5e16cd36b7f933048b7a5dc217da92430981b39b5",
            ]
        )
        XCTAssertEqual(authority.externalGitlinks.count, 2)
        XCTAssertTrue(
            authority.everyPredecessorInternalClaimHasExactSourceBinding
        )
        XCTAssertTrue(
            authority
                .currentArcImplementationSourcesRequireRefreshedEmbeddedClosure
        )
        XCTAssertTrue(authority.everyExternalClaimHasExactSourceBinding)
        XCTAssertEqual(
            Set(authority.internalSourceBindings.map(\.claimScope)).count,
            authority.internalSourceBindings.count
        )
        XCTAssertEqual(
            Set(authority.externalSourceBindings.map(\.claimScope)).count,
            authority.externalSourceBindings.count
        )
        XCTAssertTrue(
            authority.internalSourceBindings.allSatisfy { binding in
                ["100644", "100755"].contains(binding.gitMode)
                    && binding.gitBlob.utf8.count == 40
                    && isLowercaseHex(binding.gitBlob)
                    && binding.byteCount > 0
                    && binding.sha256.utf8.count == 64
                    && isLowercaseHex(binding.sha256)
            }
        )
        XCTAssertTrue(
            authority.externalSourceBindings.allSatisfy { binding in
                let repositoryRevisionIsExact =
                    (binding.repository
                        == "Ergentics/ergentics-mlx-swift"
                        && binding.revision
                            == "d37885a278f1c37484a94d0f401a418735e66519")
                    || (binding.repository == "ml-explore/mlx"
                        && binding.revision
                            == "ce45c52505c8158ea48d2a54e8caae05efd86bfe")
                    || (binding.repository == "ml-explore/mlx-c"
                        && binding.revision
                            == "0726ca922fc902c4c61ef9c27d94132be418e945")
                return repositoryRevisionIsExact
                    && binding.gitMode == "100644"
                    && binding.gitBlob.utf8.count == 40
                    && isLowercaseHex(binding.gitBlob)
                    && binding.byteCount > 0
                    && binding.sha256.utf8.count == 64
                    && isLowercaseHex(binding.sha256)
            }
        )
        XCTAssertEqual(
            authority.externalGitlinks.map(\.gitMode),
            ["160000", "160000"]
        )
        XCTAssertEqual(
            authority.externalGitlinks.map(\.childRevision),
            [
                "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                "0726ca922fc902c4c61ef9c27d94132be418e945",
            ]
        )

        XCTAssertEqual(
            authority.targetDesign.orderedTargetDependencies,
            [
                "PrimeCore",
                "PrimeNativeDecoder",
                "MLX",
                "MLXNN",
                "MLXOptimizers",
            ]
        )
        XCTAssertEqual(
            authority.targetDesign.targetName,
            "PrimeNativeDecoderTraining"
        )
        XCTAssertEqual(
            authority.targetDesign.productionSourceExpectedSHA256,
            "5e6810a6bd5a9dc0bbe6d6369cec3db6dc84068dc9b415413aafb03f311211dc"
        )
        XCTAssertTrue(authority.targetDesign.exactDependencyAllowlistRequired)
        XCTAssertFalse(
            authority.targetDesign.additionalTargetDependencyAuthorized
        )
        XCTAssertEqual(
            authority.targetDesign.currentArcManifestExpectedSHA256,
            "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2"
        )
        XCTAssertEqual(
            authority.targetDesign.currentArcLockExpectedGitBlob,
            "14d804bb4291720477240c27e24de6fbdc876b3b"
        )
        XCTAssertEqual(
            authority.targetDesign.currentArcLockExpectedSHA256,
            "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375"
        )
        XCTAssertTrue(
            authority.targetDesign
                .packageResolvedOriginHashOnlyRefreshAuthorized
        )
        XCTAssertTrue(
            authority.targetDesign
                .packageResolvedPinPayloadJSONIdenticalToPredecessor
        )
        XCTAssertFalse(
            authority.targetDesign
                .packageResolvedPinInventoryChangeAuthorized
        )
        XCTAssertFalse(
            authority.targetDesign
                .packageResolvedDependencyRevisionChangeAuthorized
        )
        XCTAssertTrue(
            authority.targetDesign
                .packageResolvedOriginHashMustEqualCurrentManifestSHA256
        )
        XCTAssertFalse(authority.targetDesign.checkpointTargetDependencyPresent)
        XCTAssertFalse(
            authority.targetDesign.checkpointTargetDependencyAuthorized
        )
        XCTAssertEqual(
            authority.targetDesign.validationPackageManifestExpectedGitBlob,
            "9f05e5a17426f00adf9dad7b55d84057122e98f9"
        )
        XCTAssertEqual(
            authority.targetDesign.validationPackageManifestExpectedSHA256,
            "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45"
        )
        XCTAssertEqual(
            authority.targetDesign.validationPackageLockExpectedGitBlob,
            "8bf05edf1ea8789e7683e72fe756d79aaaa61320"
        )
        XCTAssertEqual(
            authority.targetDesign.validationPackageLockExpectedSHA256,
            "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225"
        )
        XCTAssertTrue(
            authority.targetDesign
                .validationPackageLockOriginHashMustEqualManifestSHA256
        )
        XCTAssertTrue(
            authority.targetDesign
                .validationPackageLockPinPayloadJSONIdenticalToRootLock
        )
        XCTAssertEqual(
            authority.targetDesign.validationOrderedDirectProductDependencies,
            ["PrimeNativeDecoderTraining", "MLX"]
        )
        XCTAssertEqual(
            authority.targetDesign.validationOrderedLinkedFrameworks,
            ["CoreGraphics", "Metal"]
        )
        XCTAssertEqual(
            authority.targetDesign.validationSourceExpectedGitBlob,
            "61e86200c508526ae2ab66e359d771841f7208db"
        )
        XCTAssertEqual(
            authority.targetDesign.validationSourceExpectedSHA256,
            "29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96"
        )
        XCTAssertEqual(
            authority.targetDesign.validationOrderedImports,
            [
                "CoreGraphics",
                "Metal",
                "MLX",
                "XCTest",
                "PrimeNativeDecoderTraining",
            ]
        )
        XCTAssertTrue(authority.targetDesign.validationSourceIsSoleXCTestSource)
        XCTAssertTrue(
            authority.targetDesign.validationSourceContainsExactlyOneTestMethod
        )
        XCTAssertEqual(
            authority.targetDesign.validationFocusedFilter,
            "PrimeNativeDecoderTrainingTests/testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"
        )

        let surface = authority.surfaceDesign
        XCTAssertEqual(
            surface.batchType,
            "PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1"
        )
        XCTAssertEqual(
            surface.configurationType,
            "PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1"
        )
        XCTAssertEqual(
            surface.trainerType,
            "PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1"
        )
        XCTAssertEqual(surface.decoderNoCacheSeamAccess, "package")
        XCTAssertEqual(surface.decoderNoCacheSeamRequiredRank, 2)
        XCTAssertEqual(surface.decoderNoCacheSeamRequiredDType, "int32")
        XCTAssertTrue(
            surface.predecessorDecoderIdentityRemainsHistoricalAndFrozen
        )
        XCTAssertEqual(
            surface.currentDecoderSuccessorExpectedGitBlob,
            "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f"
        )
        XCTAssertEqual(
            surface.currentDecoderSuccessorExpectedSHA256,
            "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994"
        )
        XCTAssertFalse(
            surface.frozenCheckpointRuntimeTokenizerAuthoritiesReinterpreted
        )
        XCTAssertFalse(
            surface.v2CheckpointCompatibilityForDecoderSuccessorReestablished
        )
        XCTAssertFalse(
            surface.checkpointProvenanceForDecoderSuccessorEstablished
        )
        XCTAssertTrue(surface.futureDurableStageRequiresNewExactDecoderIdentity)
        XCTAssertEqual(
            surface.errorType,
            "PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1"
        )
        XCTAssertEqual(surface.errorTypeAccess, "internal")
        XCTAssertTrue(surface.decoderPackageScopedNoCacheSeamAuthorized)
        XCTAssertFalse(surface.publicRawMLXDecoderAPIAdded)
        XCTAssertFalse(surface.kvCacheAcceptedByTrainingSeam)
        XCTAssertFalse(surface.kvCacheAllocatedByTrainingSeam)
        XCTAssertFalse(surface.callerSuppliedDecoderConfigurationAccepted)
        XCTAssertTrue(
            surface
                .resultExposesOnlyControlCountsFloat32BitPatternsAndLogicalDigests
        )
        XCTAssertFalse(surface.rawParameterOrMomentTensorExposureAuthorized)

        let fixture = authority.fixtureDesign
        XCTAssertEqual(fixture.vocabularySize, 32)
        XCTAssertEqual(fixture.modelWidth, 16)
        XCTAssertEqual(fixture.layerCount, 2)
        XCTAssertEqual(fixture.queryHeadCount, 4)
        XCTAssertEqual(fixture.keyValueHeadCount, 2)
        XCTAssertEqual(fixture.headWidth, 4)
        XCTAssertEqual(fixture.intermediateWidth, 32)
        XCTAssertEqual(fixture.maximumSequenceLength, 16)
        XCTAssertEqual(fixture.initializationSeed, 7)
        XCTAssertEqual(fixture.uniqueParameterCount, 5_200)
        XCTAssertEqual(fixture.parameterPathCount, 20)
        XCTAssertEqual(fixture.firstMomentTensorCount, 20)
        XCTAssertEqual(fixture.secondMomentTensorCount, 20)
        XCTAssertEqual(fixture.totalMomentTensorCount, 40)
        XCTAssertEqual(fixture.parameterLogicalByteCount, 20_800)
        XCTAssertEqual(fixture.optimizerMomentLogicalByteCount, 41_600)
        XCTAssertEqual(
            Set(fixture.exactOrderedParameterPaths).count,
            fixture.parameterPathCount
        )
        XCTAssertTrue(fixture.trueGroupedQueryAttention)
        XCTAssertTrue(fixture.tiedTokenEmbeddingAndOutputHead)
        XCTAssertFalse(fixture.independentLMHeadPresent)
        XCTAssertTrue(fixture.layerCountExercisesPathIndexing)

        let loss = authority.batchAndLossDesign
        XCTAssertEqual(loss.rectangularRank, 2)
        XCTAssertEqual(loss.minimumBatchSize, 1)
        XCTAssertEqual(loss.maximumBatchSize, 2)
        XCTAssertEqual(
            loss.oversizedBatchTypedRejection,
            "batchTooLarge(observed:maximum:)"
        )
        XCTAssertTrue(
            loss.oversizedBatchRejectedBeforeSequenceInspectionAndAllocation
        )
        XCTAssertEqual(loss.paddingSide, "right")
        XCTAssertEqual(loss.paddingTokenID, 0)
        XCTAssertTrue(loss.paddingMustBeContiguousSuffix)
        XCTAssertTrue(loss.validTokenCountIsAuthoritativeContentBoundary)
        XCTAssertTrue(loss.paddingTokenIDMayAppearAsContentBeforeValidTokenCount)
        XCTAssertTrue(
            loss.onlyPositionsAtOrAfterValidTokenCountMustEqualPaddingTokenID
        )
        XCTAssertTrue(loss.completionMaskMustBeFalseAtOrAfterValidTokenCount)
        XCTAssertTrue(loss.completionMaskMustBeContiguousSuffixBeforePadding)
        XCTAssertFalse(loss.promptTokensSelectedForLoss)
        XCTAssertFalse(loss.paddingTokensSelectedForLoss)
        XCTAssertTrue(loss.selectedLabelCountMustBePositive)
        XCTAssertEqual(
            loss.lossReduction,
            "single_global_sum_over_all_selected_labels_divided_by_global_selected_label_count"
        )
        XCTAssertFalse(loss.perRowMeanThenRowMeanAuthorized)
        XCTAssertEqual(loss.labelSmoothingFloat32BitPattern, 0)
        XCTAssertTrue(loss.sharedPrefixCausalInvarianceRequired)

        let clip = authority.gradientClipDesign
        XCTAssertEqual(clip.pathEncoding, "raw_utf8")
        XCTAssertEqual(clip.accumulationDType, "float32")
        XCTAssertEqual(clip.thresholdFloat32BitPattern, Float(1).bitPattern)
        XCTAssertEqual(clip.epsilonFloat32BitPattern, Float(1e-6).bitPattern)
        XCTAssertEqual(
            clip.noClipComparison,
            "norm_strictly_less_than_threshold"
        )
        XCTAssertEqual(clip.clipScaleFormula, "1/(norm+1e-6)")
        XCTAssertTrue(clip.thresholdEqualityTakesClipBranch)
        XCTAssertTrue(clip.oneSharedScaleAppliedToEveryGradient)
        XCTAssertTrue(clip.gradientPathsMustExactlyEqualParameterPaths)
        XCTAssertTrue(clip.finiteNonzeroGradientRequiredForEveryFixturePath)
        XCTAssertTrue(
            clip.validationMustActivelyTriggerScaleStrictlyBetweenZeroAndOne
        )

        let adamW = authority.adamWDesign
        XCTAssertEqual(
            adamW.learningRateFloat32BitPattern,
            Float(1e-4).bitPattern
        )
        XCTAssertEqual(adamW.beta1Float32BitPattern, Float(0.9).bitPattern)
        XCTAssertEqual(adamW.beta2Float32BitPattern, Float(0.999).bitPattern)
        XCTAssertEqual(
            adamW.epsilonFloat32BitPattern,
            Float(1e-8).bitPattern
        )
        XCTAssertEqual(
            adamW.weightDecayFloat32BitPattern,
            Float(0.01).bitPattern
        )
        XCTAssertFalse(adamW.biasCorrectionApplied)
        XCTAssertFalse(adamW.optimizerHasInternalStepCounter)
        XCTAssertTrue(adamW.optimizerStepOwnedByPrime)
        XCTAssertEqual(adamW.initialOptimizerStep, 0)
        XCTAssertEqual(adamW.finalOptimizerStep, 2)
        XCTAssertFalse(adamW.missingGradientAuthorized)
        XCTAssertFalse(adamW.native300MHyperparametersEstablished)

        let control = authority.controlExecutionDesign
        XCTAssertEqual(control.requiredDevice, "cpu")
        XCTAssertFalse(control.gpuComputeExecutionAuthorized)
        XCTAssertFalse(control.metalTensorOperationAuthorized)
        XCTAssertEqual(control.independentTrainerCount, 2)
        XCTAssertEqual(control.updateStepCountPerTrainer, 2)
        XCTAssertEqual(control.step1ValidTokenCounts, [5, 6])
        XCTAssertEqual(control.step2ValidTokenCounts, [4, 5])
        XCTAssertEqual(control.evaluationValidTokenCounts, [3, 6])
        XCTAssertEqual(
            control.evaluationCompletionMaskRows,
            [
                [false, true, true, false, false, false],
                [false, true, true, true, true, true],
            ]
        )
        XCTAssertEqual(control.evaluationSharedPrefixSelectedLabelCount, 2)
        XCTAssertTrue(control.trainersExecuteInSameProcess)
        XCTAssertTrue(control.trainersUseSameSeedConfigurationAndBatches)
        XCTAssertFalse(control.stochasticSamplingAfterFactoryInitialization)
        XCTAssertTrue(control.uninterruptedControlOnly)
        XCTAssertFalse(control.interruptionOrResumeBoundaryPresent)
        XCTAssertTrue(control.evaluationIsReadOnly)
        XCTAssertFalse(control.evaluationUsesTrainingMode)
        XCTAssertFalse(control.evaluationUsesKVCache)
        XCTAssertTrue(control.exactFloat32LossBitEqualityRequired)
        XCTAssertTrue(control.exactEvaluationBitEqualityRequired)
        XCTAssertTrue(control.exactParameterLogicalDigestEqualityRequired)
        XCTAssertTrue(control.exactMomentLogicalDigestEqualityRequired)
        XCTAssertTrue(control.exactOptimizerStepEqualityRequired)
        XCTAssertTrue(control.thirdStepRejectionIsPreGraphPreMutationAtomic)
        XCTAssertFalse(
            control.generalPostOptimizerUpdateFailureRollbackEstablished
        )
        XCTAssertFalse(control.continuationAfterPostUpdateFailureAuthorized)
        XCTAssertTrue(control.failedTrainerMustBeDiscarded)
        XCTAssertEqual(
            control.tensorLogicalDigestAlgorithmID,
            "sha256_domain_utf8_path_u32be_rank_u32be_dimensions_u64be_count_f32_bits_u32be_v1"
        )
        XCTAssertEqual(
            control.stateLogicalDigestAlgorithmID,
            "sha256_domain_utf8_role_u32be_tensor_count_then_canonical_tensor_records_v1"
        )

        let host = authority.hostCapabilityBoundary
        XCTAssertFalse(host.localMetalDeviceVisible)
        XCTAssertTrue(host.pinnedRuntimeMetalSchedulerInitializationRequired)
        XCTAssertTrue(host.pinnedSchedulerInitializesGPUStreamBeforeCPUStream)
        XCTAssertTrue(
            host
                .withoutEarlyGuardNoDeviceFailurePrecedesCPUTrainerInitialization
        )
        XCTAssertFalse(host.localCPUTrainerInitializationReached)
        XCTAssertFalse(host.localMechanicsExecutionObserved)
        XCTAssertTrue(host.testOnlyMetalDeviceDiscoveryAuthorized)
        XCTAssertEqual(
            host.testOnlyCapabilityDiscoveryModules,
            ["CoreGraphics", "Metal"]
        )
        XCTAssertFalse(host.testOnlyDiscoveryPerformsTensorComputation)
        XCTAssertTrue(host.earlyNilDeviceSkipAuthorizedForLocalCapabilityGuard)
        XCTAssertEqual(host.localFocusedTestObservedTestCount, 1)
        XCTAssertEqual(host.localFocusedTestObservedSkipCount, 1)
        XCTAssertEqual(host.localFocusedTestObservedFailureCount, 0)
        XCTAssertFalse(
            host.localGuardReachedMLXDeviceOrStaticRuntimeInitialization
        )
        XCTAssertFalse(host.localCapabilitySkipCountsAsMechanicsSuccess)
        XCTAssertFalse(host.localCapabilitySkipCountsAsExecutionObservation)
        XCTAssertFalse(host.metalSchedulerBootstrapAuthorizesMetalTensorExecution)
        XCTAssertTrue(host.hostedMacOSRunnerExecutionRequired)
        XCTAssertEqual(host.hostedFocusedTestRequiredExecutionCount, 1)
        XCTAssertEqual(host.hostedFocusedTestRequiredSkipCount, 0)
        XCTAssertEqual(host.hostedFocusedTestRequiredFailureCount, 0)
        XCTAssertTrue(host.hostedSuccessfulExecutionObservationPending)

        XCTAssertTrue(stage2Ceilings(authority).allSatisfy { $0 })
        XCTAssertTrue(downstreamCeilings(authority).allSatisfy { !$0 })
        XCTAssertTrue(authority.implementationObservedByThisPreExecutionAuthority)
        XCTAssertFalse(authority.executionObservedByThisPreExecutionAuthority)
        XCTAssertEqual(
            authority.orderedNextActions.first,
            "validate_bind_and_publish_already_materialized_exact_stage2_implementation_source_closure"
        )
        XCTAssertTrue(authority.status.hasPrefix("AUTHORIZED_TINY_CPU_"))

        requireSendable(Authority.self)
        let canonical = try authority.canonicalData()
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            "3520f1a778b33be0fad8c8967318b0b4ad8ed86b4746620e0bbf0e6c385f7840"
        )
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical)
                as? [String: Any]
        )
        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 300)
        XCTAssertGreaterThan(dictionaryPaths.count, 30)

        for path in valuePaths {
            try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: mutateJSONValue
                ),
                label: "mutated \(pathLabel(path))"
            )
            try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { _ in NSNull() }
                ),
                label: "null \(pathLabel(path))"
            )
            try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
        }

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_stage2_field_\(index)"] = true
                    return dictionary
                }
            )
            try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))"
            )
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
                return [path]
                    + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path]
                    + allValuePaths(in: array[index], prefix: path)
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

    private func removingValue(
        in value: Any,
        at path: JSONPath
    ) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(
                    in: object[key]!,
                    at: remainder
                )
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(
                    in: array[index],
                    at: remainder
                )
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
            return NSNumber(value: number.uint64Value + 1)
        }
        if var array = value as? [Any] {
            array.append(array.first ?? "__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["unknown_mutation"] = true
            return object
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }

    private func assertCanonicalRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Authority.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashEscapedData = try XCTUnwrap(
            slashEscaped.data(using: .utf8)
        )
        XCTAssertThrowsError(
            try Authority.decodeCanonical(slashEscapedData)
        )

        var reordered = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
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
        XCTAssertThrowsError(try Authority.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(
            String(data: canonical, encoding: .utf8)
        )
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening)
        )
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(duplicateData))
    }

    private func stage2Ceilings(_ authority: Authority) -> [Bool] {
        let ceiling = authority.authorityCeiling
        return [
            ceiling.dependencyManifestMutationForExactTargetAuthorized,
            ceiling.exactStage2ProductionImplementationAuthorized,
            ceiling.exactStage2ValidationImplementationAuthorized,
            ceiling.tinyCPUModelAllocationAuthorized,
            ceiling.tinyCPUDecoderForwardAuthorized,
            ceiling.tinyCPULossEvaluationAuthorized,
            ceiling.tinyCPUBackwardAuthorized,
            ceiling.tinyCPUGradientClipAuthorized,
            ceiling.tinyCPUAdamWStepAuthorized,
            ceiling.exactTwoStepControlExecutionAuthorized,
        ]
    }

    private func downstreamCeilings(_ authority: Authority) -> [Bool] {
        let ceiling = authority.authorityCeiling
        return [
            ceiling.primeOwnedFilesystemIOAuthorized,
            ceiling.childProcessExecutionAuthorized,
            ceiling.stochasticSamplingAfterFactoryInitializationAuthorized,
            ceiling.explicitRNGDomainImplementationAuthorized,
            ceiling.deterministicDataCursorImplementationAuthorized,
            ceiling.resumeExecutionAuthorized,
            ceiling.checkpointReadAuthorized,
            ceiling.checkpointWriteAuthorized,
            ceiling.checkpointArtifactCreationAuthorized,
            ceiling.artifactRootMutationAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.artifactRetentionAuthorized,
            ceiling.checkpointProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.metalTensorExecutionAuthorized,
            ceiling.metalDeterminismEstablished,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MResourceProbeAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.trajectoryExactResumeEstablished,
            ceiling.trainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func isLowercaseHex(_ value: String) -> Bool {
        value.utf8.allSatisfy { byte in
            (byte >= 48 && byte <= 57)
                || (byte >= 97 && byte <= 102)
        }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
