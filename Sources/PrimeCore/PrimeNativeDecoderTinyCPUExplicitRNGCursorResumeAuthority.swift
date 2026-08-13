// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case nonCanonicalEncoding
}

public enum PrimeNativeDecoderTinyCPUExplicitRNGDomainV1:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case modelInitialization = "model_initialization_v1"
    case trainingDataOrder = "training_data_order_v1"
    case augmentation = "augmentation_v1"
    case evaluation = "evaluation_v1"
}

public struct PrimeNativeDecoderTinyCPUResumeRepositoryBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let ref: String
    public let stage2RetirementMergeRevision: String
    public let stage2RetirementTree: String
    public let orderedParentRevisions: [String]
    public let stage2SuccessReviewedHeadRevision: String
    public let stage2SuccessObservationCanonicalSHA256: String
    public let stage2SuccessObservationSourcePath: String
    public let stage2SuccessObservationSourceGitBlob: String
    public let stage2SuccessObservationSourceSHA256: String
    public let stage2SuccessObservationTestPath: String
    public let stage2SuccessObservationTestGitBlob: String
    public let stage2SuccessObservationTestSHA256: String
    public let embeddedSourceIdentitySHA256: String
    public let stage2RetirementMergeIsCurrentAuthorityBase: Bool
    public let authorityMustMergeAndPassExactMainBeforeImplementation: Bool
    public let implementationMustBindFinalAuthorityMergeAndTree: Bool
}

public struct PrimeNativeDecoderTinyCPUResumeStage2EvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let mechanicsExecutionRunID: Int
    public let mechanicsExecutionRunAttempt: Int
    public let mechanicsExecutionRerunCount: Int
    public let mechanicsExecutionRootTestCount: Int
    public let mechanicsExecutionMetalTestCount: Int
    public let mechanicsExecutionRuntimeTestCount: Int
    public let mechanicsExecutionTokenizerTestCount: Int
    public let mechanicsExecutionStage2TestStartCount: Int
    public let mechanicsExecutionStage2TestPassCount: Int
    public let mechanicsExecutionStage2TestFailureCount: Int
    public let mechanicsExecutionStage2TestSkipCount: Int
    public let mechanicsExecutionReceiptCount: Int
    public let mechanicsExecutionReceiptSHA256: String
    public let mechanicsExecutionActionsArtifactCount: Int
    public let retirementRunID: Int
    public let retirementRunAttempt: Int
    public let retirementRerunCount: Int
    public let retirementRootTestCount: Int
    public let retirementMetalTestCount: Int
    public let retirementRuntimeTestCount: Int
    public let retirementTokenizerTestCount: Int
    public let retirementStage2InvocationCount: Int
    public let retirementStage2ReceiptCount: Int
    public let retirementActionsArtifactCount: Int
    public let stage2MechanicsEstablished: Bool
    public let stage2InvocationRetired: Bool
    public let stage2LauncherPreservedForAudit: Bool
}

public struct PrimeNativeDecoderTinyCPUResumeFixtureV1:
    Codable,
    Equatable,
    Sendable
{
    public let configurationType: String
    public let trainerType: String
    public let vocabularySize: Int
    public let modelWidth: Int
    public let layerCount: Int
    public let queryHeadCount: Int
    public let keyValueHeadCount: Int
    public let headWidth: Int
    public let intermediateWidth: Int
    public let maximumSequenceLength: Int
    public let maximumBatchSize: Int
    public let initializationSeed: UInt64
    public let uniqueParameterCount: Int
    public let trainableParameterPathCount: Int
    public let firstMomentTensorCount: Int
    public let secondMomentTensorCount: Int
    public let snapshotGlobalStep: Int
    public let terminalGlobalStep: Int
    public let existingMaximumGlobalStep: Int
    public let learningRateFloat32BitPattern: UInt32
    public let beta1Float32BitPattern: UInt32
    public let beta2Float32BitPattern: UInt32
    public let epsilonFloat32BitPattern: UInt32
    public let weightDecayFloat32BitPattern: UInt32
    public let scheduleID: String
    public let currentLearningRateMustBeRestoredExactly: Bool
}

public struct PrimeNativeDecoderTinyCPUResumeRandomDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let algorithmID: String
    public let keyDerivationID: String
    public let counterEncoding: String
    public let outputByteCountPerCounter: Int
    public let rootSeed: UInt64
    public let requiredDomains: [PrimeNativeDecoderTinyCPUExplicitRNGDomainV1]
    public let keyByteCountPerDomain: Int
    public let counterByteCountPerDomain: Int
    public let domainKeysMustBePairwiseDistinct: Bool
    public let countersAreIndependent: Bool
    public let consumptionDigestAlgorithmID: String
    public let snapshotBindsAlgorithmKeysCountersAndConsumptionDigest: Bool
    public let modelInitializationConsumesOnlyModelDomain: Bool
    public let rowPermutationConsumesOnlyDataOrderDomain: Bool
    public let augmentationConsumesOnlyAugmentationDomain: Bool
    public let evaluationConsumesOnlyEvaluationDomain: Bool
    public let evaluationConsumptionCountInFirstWitness: Int
    public let augmentationConsumptionCountInFirstWitness: Int
    public let implicitGlobalRandomStateAuthorized: Bool
    public let sharedCounterAcrossDomainsAuthorized: Bool
    public let mlxRandomStateInnerStateImporterAuthorized: Bool
    public let underscoredMLXArrayMutationAuthorized: Bool
}

public struct PrimeNativeDecoderTinyCPUResumeCursorDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaID: String
    public let corpusBinding: String
    public let tokenizerBinding: String
    public let exampleGeneratorBinding: String
    public let sourceInventoryBinding: String
    public let splitIdentity: String
    public let curriculumIdentity: String
    public let epoch: Int
    public let permutationAlgorithmID: String
    public let permutationDomain: PrimeNativeDecoderTinyCPUExplicitRNGDomainV1
    public let rowIDCount: Int
    public let batchSize: Int
    public let microbatchSize: Int
    public let sequenceLength: Int
    public let paddingPolicy: String
    public let dropLastPolicy: String
    public let causalMaskPolicy: String
    public let snapshotNextBatchOrdinal: Int
    public let snapshotNextRowIndex: Int
    public let snapshotNextRowIDs: [String]
    public let nextBatchTokenAndMaskDigestAlgorithmID: String
    public let cursorPointsToNextUnconsumedBatch: Bool
    public let skipOrDuplicateBatchPermitted: Bool
    public let callerSuppliedBatchSubstitutionPermitted: Bool
}

public struct PrimeNativeDecoderTinyCPUResumeSnapshotBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let snapshotType: String
    public let snapshotStorage: String
    public let snapshotBoundary: String
    public let modelTensorCount: Int
    public let optimizerMomentTensorCount: Int
    public let optimizerConfigurationIncluded: Bool
    public let optimizerScheduleIncluded: Bool
    public let globalStepIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let lastGradientIncluded: Bool
    public let lastTrainResultIncluded: Bool
    public let accumulationPhase: Int
    public let pendingGradientTensorCount: Int
    public let pendingPrefetchItemCount: Int
    public let kvCacheEntryCount: Int
    public let snapshotAfterCheckedReadOnlyEvaluation: Bool
    public let arbitraryMidAccumulationSnapshotAuthorized: Bool
    public let exportProducesAliasedMutableTensorReferences: Bool
    public let restoreTargetMustBeFresh: Bool
    public let restoreTargetOptimizerMustBeUninitialized: Bool
    public let restoreValidatesExactPathsShapesDTypesAndCounts: Bool
    public let restoreFailureMustLeaveFreshTargetUnchanged: Bool
}

public struct PrimeNativeDecoderTinyCPUResumeWitnessV1:
    Codable,
    Equatable,
    Sendable
{
    public let controlArm: [String]
    public let resumedArm: [String]
    public let initialStateEqualityRequired: Bool
    public let step1ResultEqualityRequired: Bool
    public let snapshotStateEqualityRequired: Bool
    public let restoredImmediateStateEqualityRequired: Bool
    public let step2ResultEqualityRequired: Bool
    public let terminalStateEqualityRequired: Bool
    public let terminalEvaluationEqualityRequired: Bool
    public let comparedStepResultFields: [String]
    public let comparedSnapshotFields: [String]
    public let tensorValueEqualityIsBitExact: Bool
    public let digestEqualityAloneIsSufficient: Bool
    public let independentObjectIdentityRequired: Bool
    public let snapshotAliasIsolationRequired: Bool
    public let rejectedMutationFamilies: [String]
    public let exactlyOneHostedTestRequired: Bool
    public let hostedTestFailureCountRequired: Int
    public let hostedTestSkipCountRequired: Int
}

public struct PrimeNativeDecoderTinyCPUResumeSuccessorScopeV1:
    Codable,
    Equatable,
    Sendable
{
    public let exactChangedPaths: [String]
    public let trainingManifestMutationAuthorized: Bool
    public let trainingLockMutationAuthorized: Bool
    public let stage2ValidationSourceMutationAuthorized: Bool
    public let checkpointTargetDependencyAuthorized: Bool
    public let newHostedLauncherRequired: Bool
    public let reviewedCheckoutDepthChangeAuthorized: Bool
    public let workflowTimeoutChangeAuthorized: Bool
    public let secureFetchMutationAuthorized: Bool
    public let existingMetalLauncherMutationAuthorized: Bool
    public let existingRuntimeLauncherMutationAuthorized: Bool
    public let existingTokenizerLauncherMutationAuthorized: Bool
    public let uploadStepAuthorized: Bool
}

public struct PrimeNativeDecoderTinyCPUResumeAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorityOnlyNoExecutionEvidence: Bool
    public let implementationAuthorizedAfterGreenAuthorityClosure: Bool
    public let oneExactMainExecutionOpportunityAuthorized: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
    public let filesystemMutationAuthorized: Bool
    public let checkpointReadAuthorized: Bool
    public let checkpointWriteAuthorized: Bool
    public let checkpointCodecMutationAuthorized: Bool
    public let artifactRootAuthorized: Bool
    public let durableSnapshotEncodingAuthorized: Bool
    public let retainedArtifactAuthorized: Bool
    public let artifactUploadAuthorized: Bool
    public let checkpointProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let metalDeterminismEstablished: Bool
    public let runtimeLoadedMetallibIdentityEstablished: Bool
    public let native300MAllocationAuthorized: Bool
    public let native300MTrainingAuthorized: Bool
    public let generalTrainingResumeEstablished: Bool
    public let stage4Authorized: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Pure, append-only authority for the third trajectory stage. It grants one
/// later tiny in-memory exact-resume implementation and hosted witness, but
/// performs no MLX work and grants no durable checkpoint or downstream use.
public struct PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public static let canonicalSHA256 =
        "0ab57d5e8c71b18d03c9730da1e90399d57c05ccaa155aa31aff0c3001987fe6"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "prime_native_decoder_tiny_cpu_explicit_rng_cursor_resume_authority_v1",
        stageID: "tiny_cpu_explicit_rng_cursor_resume_v1",
        requiredPredecessorStageID: "tiny_cpu_train_evaluate_mechanics_v1",
        repository: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            stage2RetirementMergeRevision:
                "71b456d78be5addc858b706677005753eb22c39a",
            stage2RetirementTree:
                "6e5a37bb71cdf62040e31a8ab21fc935e7f663a3",
            orderedParentRevisions: [
                "5c1b7c4f7a7689cba53ded11dd8b12a0f1a3229d",
                "86b616e3b35a98e02a17c81a4f00e864af51be50",
            ],
            stage2SuccessReviewedHeadRevision:
                "86b616e3b35a98e02a17c81a4f00e864af51be50",
            stage2SuccessObservationCanonicalSHA256:
                "f553a7ce431cedccf25b06a89af2a47f8adcf9db556ca4b5a2341bb3463729e4",
            stage2SuccessObservationSourcePath:
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservation.swift",
            stage2SuccessObservationSourceGitBlob:
                "3acba8ddf8bd90dc36a858d1d424f3efdd6e8d44",
            stage2SuccessObservationSourceSHA256:
                "24490e18f9b20e622fcd92f054f0325b55e1f404302754d71cc57eb26e424c3f",
            stage2SuccessObservationTestPath:
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationTests.swift",
            stage2SuccessObservationTestGitBlob:
                "1b182445cc3aa7bcd57e2b99390daf8a42141b3f",
            stage2SuccessObservationTestSHA256:
                "7c6cabc7b0ed955f0b5d194f7e7766ca27b8613ff9e9c69b43b431e761b859bb",
            embeddedSourceIdentitySHA256:
                "a0928e3acd1f78b706e1a89fc0e6220d4697b227e538a9b07ea0af5cbd47e131",
            stage2RetirementMergeIsCurrentAuthorityBase: true,
            authorityMustMergeAndPassExactMainBeforeImplementation: true,
            implementationMustBindFinalAuthorityMergeAndTree: true),
        stage2Evidence: .init(
            mechanicsExecutionRunID: 31_565_094_400,
            mechanicsExecutionRunAttempt: 1,
            mechanicsExecutionRerunCount: 0,
            mechanicsExecutionRootTestCount: 43,
            mechanicsExecutionMetalTestCount: 44,
            mechanicsExecutionRuntimeTestCount: 1,
            mechanicsExecutionTokenizerTestCount: 1,
            mechanicsExecutionStage2TestStartCount: 1,
            mechanicsExecutionStage2TestPassCount: 1,
            mechanicsExecutionStage2TestFailureCount: 0,
            mechanicsExecutionStage2TestSkipCount: 0,
            mechanicsExecutionReceiptCount: 1,
            mechanicsExecutionReceiptSHA256:
                "5c7a1cb1cec4a66517e5e1fc382ae757f6d6b6460d1f55b963040b958d907a78",
            mechanicsExecutionActionsArtifactCount: 0,
            retirementRunID: 31_572_113_622,
            retirementRunAttempt: 1,
            retirementRerunCount: 0,
            retirementRootTestCount: 44,
            retirementMetalTestCount: 44,
            retirementRuntimeTestCount: 1,
            retirementTokenizerTestCount: 1,
            retirementStage2InvocationCount: 0,
            retirementStage2ReceiptCount: 0,
            retirementActionsArtifactCount: 0,
            stage2MechanicsEstablished: true,
            stage2InvocationRetired: true,
            stage2LauncherPreservedForAudit: true),
        fixture: .init(
            configurationType:
                "PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1",
            trainerType: "PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1",
            vocabularySize: 32,
            modelWidth: 16,
            layerCount: 2,
            queryHeadCount: 4,
            keyValueHeadCount: 2,
            headWidth: 4,
            intermediateWidth: 32,
            maximumSequenceLength: 16,
            maximumBatchSize: 2,
            initializationSeed: 7,
            uniqueParameterCount: 5_200,
            trainableParameterPathCount: 20,
            firstMomentTensorCount: 20,
            secondMomentTensorCount: 20,
            snapshotGlobalStep: 1,
            terminalGlobalStep: 2,
            existingMaximumGlobalStep: 2,
            learningRateFloat32BitPattern: Float(1e-4).bitPattern,
            beta1Float32BitPattern: Float(0.9).bitPattern,
            beta2Float32BitPattern: Float(0.999).bitPattern,
            epsilonFloat32BitPattern: Float(1e-8).bitPattern,
            weightDecayFloat32BitPattern: Float(0.01).bitPattern,
            scheduleID: "constant_float32_learning_rate_v1",
            currentLearningRateMustBeRestoredExactly: true),
        randomDesign: .init(
            algorithmID: "sha256_counter_stream_v1",
            keyDerivationID:
                "sha256_domain_utf8_root_seed_u64be_domain_utf8_v1",
            counterEncoding: "unsigned_64_bit_big_endian",
            outputByteCountPerCounter: 32,
            rootSeed: 7,
            requiredDomains: PrimeNativeDecoderTinyCPUExplicitRNGDomainV1
                .allCases,
            keyByteCountPerDomain: 32,
            counterByteCountPerDomain: 8,
            domainKeysMustBePairwiseDistinct: true,
            countersAreIndependent: true,
            consumptionDigestAlgorithmID:
                "sha256_domain_utf8_key_counter_before_counter_after_output_digest_v1",
            snapshotBindsAlgorithmKeysCountersAndConsumptionDigest: true,
            modelInitializationConsumesOnlyModelDomain: true,
            rowPermutationConsumesOnlyDataOrderDomain: true,
            augmentationConsumesOnlyAugmentationDomain: true,
            evaluationConsumesOnlyEvaluationDomain: true,
            evaluationConsumptionCountInFirstWitness: 0,
            augmentationConsumptionCountInFirstWitness: 0,
            implicitGlobalRandomStateAuthorized: false,
            sharedCounterAcrossDomainsAuthorized: false,
            mlxRandomStateInnerStateImporterAuthorized: false,
            underscoredMLXArrayMutationAuthorized: false),
        cursorDesign: .init(
            schemaID: "prime_native_decoder_tiny_cpu_data_cursor_v1",
            corpusBinding: "tiny_cpu_two_batch_fixture_v1",
            tokenizerBinding: "literal_token_ids_v1",
            exampleGeneratorBinding: "frozen_literal_rows_v1",
            sourceInventoryBinding: "two_training_batches_one_evaluation_batch_v1",
            splitIdentity: "train_two_batches_eval_one_batch_v1",
            curriculumIdentity: "fixed_step1_then_step2_v1",
            epoch: 0,
            permutationAlgorithmID:
                "sha256_key_epoch_u64be_row_id_utf8_sort_digest_then_row_id_v1",
            permutationDomain: .trainingDataOrder,
            rowIDCount: 4,
            batchSize: 2,
            microbatchSize: 2,
            sequenceLength: 6,
            paddingPolicy: "right_zero_filler_valid_prefix_v1",
            dropLastPolicy: "reject_incomplete_batch",
            causalMaskPolicy: "token_aligned_false_star_true_plus_v1",
            snapshotNextBatchOrdinal: 1,
            snapshotNextRowIndex: 2,
            snapshotNextRowIDs: ["train_row_2", "train_row_3"],
            nextBatchTokenAndMaskDigestAlgorithmID:
                "sha256_domain_utf8_rows_i32be_tokens_u8_masks_v1",
            cursorPointsToNextUnconsumedBatch: true,
            skipOrDuplicateBatchPermitted: false,
            callerSuppliedBatchSubstitutionPermitted: false),
        snapshotBoundary: .init(
            snapshotType:
                "PrimeNativeDecoderTinyCPUInMemoryResumeSnapshotV1",
            snapshotStorage: "process_local_typed_value_only",
            snapshotBoundary:
                "after_step1_optimizer_update_and_checked_read_only_evaluation_before_step2_batch_consumption",
            modelTensorCount: 20,
            optimizerMomentTensorCount: 40,
            optimizerConfigurationIncluded: true,
            optimizerScheduleIncluded: true,
            globalStepIncluded: true,
            rngStateIncluded: true,
            dataCursorIncluded: true,
            lastGradientIncluded: false,
            lastTrainResultIncluded: false,
            accumulationPhase: 0,
            pendingGradientTensorCount: 0,
            pendingPrefetchItemCount: 0,
            kvCacheEntryCount: 0,
            snapshotAfterCheckedReadOnlyEvaluation: true,
            arbitraryMidAccumulationSnapshotAuthorized: false,
            exportProducesAliasedMutableTensorReferences: false,
            restoreTargetMustBeFresh: true,
            restoreTargetOptimizerMustBeUninitialized: true,
            restoreValidatesExactPathsShapesDTypesAndCounts: true,
            restoreFailureMustLeaveFreshTargetUnchanged: true),
        witness: .init(
            controlArm: [
                "fresh_seed7_trainer",
                "consume_step1_batch",
                "checked_read_only_evaluation",
                "consume_step2_batch",
                "checked_terminal_evaluation",
            ],
            resumedArm: [
                "independent_fresh_seed7_trainer",
                "consume_step1_batch",
                "checked_read_only_evaluation",
                "export_typed_in_memory_snapshot",
                "discard_source_trainer",
                "construct_fresh_seed7_restore_target",
                "restore_snapshot_into_fresh_target",
                "consume_exact_cursor_step2_batch",
                "checked_terminal_evaluation",
            ],
            initialStateEqualityRequired: true,
            step1ResultEqualityRequired: true,
            snapshotStateEqualityRequired: true,
            restoredImmediateStateEqualityRequired: true,
            step2ResultEqualityRequired: true,
            terminalStateEqualityRequired: true,
            terminalEvaluationEqualityRequired: true,
            comparedStepResultFields: [
                "loss_float32_bits",
                "selected_loss_float32_bits",
                "raw_gradient_norm_float32_bits",
                "clip_scale_float32_bits",
                "clipped_gradient_norm_float32_bits",
                "parameter_state",
                "first_moment_state",
                "second_moment_state",
            ],
            comparedSnapshotFields: [
                "model_tensor_values",
                "first_moment_tensor_values",
                "second_moment_tensor_values",
                "optimizer_configuration",
                "optimizer_schedule",
                "global_step",
                "rng_domains",
                "data_cursor",
            ],
            tensorValueEqualityIsBitExact: true,
            digestEqualityAloneIsSufficient: false,
            independentObjectIdentityRequired: true,
            snapshotAliasIsolationRequired: true,
            rejectedMutationFamilies: [
                "missing_extra_or_duplicate_tensor_path",
                "tensor_shape_dtype_or_value_drift",
                "optimizer_configuration_or_step_drift",
                "rng_algorithm_domain_key_counter_or_consumption_drift",
                "cursor_identity_position_policy_or_next_batch_drift",
                "restore_into_initialized_target",
                "snapshot_alias_mutation",
                "skipped_duplicated_or_substituted_batch",
            ],
            exactlyOneHostedTestRequired: true,
            hostedTestFailureCountRequired: 0,
            hostedTestSkipCountRequired: 0),
        successorScope: .init(
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage3-tiny-cpu-resume.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeTests.swift",
            ],
            trainingManifestMutationAuthorized: false,
            trainingLockMutationAuthorized: false,
            stage2ValidationSourceMutationAuthorized: false,
            checkpointTargetDependencyAuthorized: false,
            newHostedLauncherRequired: true,
            reviewedCheckoutDepthChangeAuthorized: true,
            workflowTimeoutChangeAuthorized: false,
            secureFetchMutationAuthorized: false,
            existingMetalLauncherMutationAuthorized: false,
            existingRuntimeLauncherMutationAuthorized: false,
            existingTokenizerLauncherMutationAuthorized: false,
            uploadStepAuthorized: false),
        ceiling: .init(
            authorityOnlyNoExecutionEvidence: true,
            implementationAuthorizedAfterGreenAuthorityClosure: true,
            oneExactMainExecutionOpportunityAuthorized: true,
            additionalExecutionOrRerunAuthorized: false,
            filesystemMutationAuthorized: false,
            checkpointReadAuthorized: false,
            checkpointWriteAuthorized: false,
            checkpointCodecMutationAuthorized: false,
            artifactRootAuthorized: false,
            durableSnapshotEncodingAuthorized: false,
            retainedArtifactAuthorized: false,
            artifactUploadAuthorized: false,
            checkpointProvenanceEstablished: false,
            checkpointAdmissionGranted: false,
            metalDeterminismEstablished: false,
            runtimeLoadedMetallibIdentityEstablished: false,
            native300MAllocationAuthorized: false,
            native300MTrainingAuthorized: false,
            generalTrainingResumeEstablished: false,
            stage4Authorized: false,
            modelQualityEstablished: false,
            candidateAdmissionGranted: false,
            trialAuthorized: false,
            canaryAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        status:
            "AUTHORIZED_stage3_tiny_cpu_typed_in_memory_explicit_rng_cursor_resume_implementation_and_one_exact_main_witness_after_green_authority_closure_no_checkpoint_artifact_metal_determinism_native300m_or_downstream_authority")

    public let schemaVersion: Int
    public let authorityID: String
    public let stageID: String
    public let requiredPredecessorStageID: String
    public let repository: PrimeNativeDecoderTinyCPUResumeRepositoryBoundaryV1
    public let stage2Evidence: PrimeNativeDecoderTinyCPUResumeStage2EvidenceV1
    public let fixture: PrimeNativeDecoderTinyCPUResumeFixtureV1
    public let randomDesign: PrimeNativeDecoderTinyCPUResumeRandomDesignV1
    public let cursorDesign: PrimeNativeDecoderTinyCPUResumeCursorDesignV1
    public let snapshotBoundary: PrimeNativeDecoderTinyCPUResumeSnapshotBoundaryV1
    public let witness: PrimeNativeDecoderTinyCPUResumeWitnessV1
    public let successorScope: PrimeNativeDecoderTinyCPUResumeSuccessorScopeV1
    public let ceiling: PrimeNativeDecoderTinyCPUResumeAuthorityCeilingV1
    public let status: String

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityError
                .contractDrift
        }
        let stage2 =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationV1
                .frozenV1
        let design = PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1
            .frozenV1
        let stage2CanonicalSHA256 = PrimeSHA256.hexDigest(
            of: try stage2.canonicalData())
        var designContainsRequiredStage = false
        for stagePlan in design.orderedStages {
            if stagePlan.stage
                == PrimeNativeDecoderTrajectoryExactResumeStageV1
                    .tinyCPUExplicitRNGCursorResume,
                stagePlan.requiredCompletedPredecessorStage
                    == PrimeNativeDecoderTrajectoryExactResumeStageV1
                        .tinyCPUTrainEvaluateMechanics
            {
                designContainsRequiredStage = true
            }
        }
        let requiredPaths = successorScope.exactChangedPaths
        let falseCeiling = [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.filesystemMutationAuthorized,
            ceiling.checkpointReadAuthorized,
            ceiling.checkpointWriteAuthorized,
            ceiling.checkpointCodecMutationAuthorized,
            ceiling.artifactRootAuthorized,
            ceiling.durableSnapshotEncodingAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.checkpointProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.metalDeterminismEstablished,
            ceiling.runtimeLoadedMetallibIdentityEstablished,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.stage4Authorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
        guard schemaVersion == 1,
              authorityID
                == "prime_native_decoder_tiny_cpu_explicit_rng_cursor_resume_authority_v1",
              stageID == "tiny_cpu_explicit_rng_cursor_resume_v1",
              requiredPredecessorStageID
                == "tiny_cpu_train_evaluate_mechanics_v1",
              repository.repository == "Ergentics/ergentics-prime",
              repository.ref == "refs/heads/main",
              repository.orderedParentRevisions.count == 2,
              repository.stage2SuccessObservationCanonicalSHA256
                == stage2CanonicalSHA256,
              repository.embeddedSourceIdentitySHA256
                == "a0928e3acd1f78b706e1a89fc0e6220d4697b227e538a9b07ea0af5cbd47e131",
              repository.stage2RetirementMergeIsCurrentAuthorityBase,
              repository.authorityMustMergeAndPassExactMainBeforeImplementation,
              repository.implementationMustBindFinalAuthorityMergeAndTree,
              stage2Evidence.mechanicsExecutionStage2TestStartCount == 1,
              stage2Evidence.mechanicsExecutionStage2TestPassCount == 1,
              stage2Evidence.mechanicsExecutionStage2TestFailureCount == 0,
              stage2Evidence.mechanicsExecutionStage2TestSkipCount == 0,
              stage2Evidence.mechanicsExecutionReceiptCount == 1,
              stage2Evidence.mechanicsExecutionActionsArtifactCount == 0,
              stage2Evidence.retirementRootTestCount == 44,
              stage2Evidence.retirementMetalTestCount == 44,
              stage2Evidence.retirementRuntimeTestCount == 1,
              stage2Evidence.retirementTokenizerTestCount == 1,
              stage2Evidence.retirementStage2InvocationCount == 0,
              stage2Evidence.retirementStage2ReceiptCount == 0,
              stage2Evidence.retirementActionsArtifactCount == 0,
              stage2Evidence.stage2MechanicsEstablished,
              stage2Evidence.stage2InvocationRetired,
              stage2Evidence.stage2LauncherPreservedForAudit,
              fixture.uniqueParameterCount == 5_200,
              fixture.trainableParameterPathCount == 20,
              fixture.firstMomentTensorCount == 20,
              fixture.secondMomentTensorCount == 20,
              fixture.snapshotGlobalStep == 1,
              fixture.terminalGlobalStep == 2,
              fixture.existingMaximumGlobalStep == 2,
              fixture.currentLearningRateMustBeRestoredExactly,
              randomDesign.requiredDomains
                == PrimeNativeDecoderTinyCPUExplicitRNGDomainV1.allCases,
              Set(randomDesign.requiredDomains).count == 4,
              randomDesign.keyByteCountPerDomain == 32,
              randomDesign.counterByteCountPerDomain == 8,
              randomDesign.domainKeysMustBePairwiseDistinct,
              randomDesign.countersAreIndependent,
              randomDesign.snapshotBindsAlgorithmKeysCountersAndConsumptionDigest,
              randomDesign.evaluationConsumptionCountInFirstWitness == 0,
              randomDesign.augmentationConsumptionCountInFirstWitness == 0,
              !randomDesign.implicitGlobalRandomStateAuthorized,
              !randomDesign.sharedCounterAcrossDomainsAuthorized,
              !randomDesign.mlxRandomStateInnerStateImporterAuthorized,
              !randomDesign.underscoredMLXArrayMutationAuthorized,
              cursorDesign.permutationDomain == .trainingDataOrder,
              cursorDesign.snapshotNextBatchOrdinal == 1,
              cursorDesign.snapshotNextRowIndex == 2,
              cursorDesign.snapshotNextRowIDs
                == ["train_row_2", "train_row_3"],
              cursorDesign.cursorPointsToNextUnconsumedBatch,
              !cursorDesign.skipOrDuplicateBatchPermitted,
              !cursorDesign.callerSuppliedBatchSubstitutionPermitted,
              snapshotBoundary.modelTensorCount == 20,
              snapshotBoundary.optimizerMomentTensorCount == 40,
              snapshotBoundary.optimizerConfigurationIncluded,
              snapshotBoundary.optimizerScheduleIncluded,
              snapshotBoundary.globalStepIncluded,
              snapshotBoundary.rngStateIncluded,
              snapshotBoundary.dataCursorIncluded,
              !snapshotBoundary.lastGradientIncluded,
              !snapshotBoundary.lastTrainResultIncluded,
              snapshotBoundary.accumulationPhase == 0,
              snapshotBoundary.pendingGradientTensorCount == 0,
              snapshotBoundary.pendingPrefetchItemCount == 0,
              snapshotBoundary.kvCacheEntryCount == 0,
              snapshotBoundary.snapshotAfterCheckedReadOnlyEvaluation,
              !snapshotBoundary.arbitraryMidAccumulationSnapshotAuthorized,
              !snapshotBoundary.exportProducesAliasedMutableTensorReferences,
              snapshotBoundary.restoreTargetMustBeFresh,
              snapshotBoundary.restoreTargetOptimizerMustBeUninitialized,
              snapshotBoundary.restoreValidatesExactPathsShapesDTypesAndCounts,
              snapshotBoundary.restoreFailureMustLeaveFreshTargetUnchanged,
              witness.controlArm.count == 5,
              witness.resumedArm.count == 9,
              witness.step2ResultEqualityRequired,
              witness.terminalStateEqualityRequired,
              witness.terminalEvaluationEqualityRequired,
              witness.tensorValueEqualityIsBitExact,
              !witness.digestEqualityAloneIsSufficient,
              witness.independentObjectIdentityRequired,
              witness.snapshotAliasIsolationRequired,
              witness.rejectedMutationFamilies.count == 8,
              witness.exactlyOneHostedTestRequired,
              witness.hostedTestFailureCountRequired == 0,
              witness.hostedTestSkipCountRequired == 0,
              requiredPaths == requiredPaths.sorted(),
              Set(requiredPaths).count == 6,
              !successorScope.trainingManifestMutationAuthorized,
              !successorScope.trainingLockMutationAuthorized,
              !successorScope.stage2ValidationSourceMutationAuthorized,
              !successorScope.checkpointTargetDependencyAuthorized,
              successorScope.newHostedLauncherRequired,
              successorScope.reviewedCheckoutDepthChangeAuthorized,
              !successorScope.workflowTimeoutChangeAuthorized,
              !successorScope.secureFetchMutationAuthorized,
              !successorScope.existingMetalLauncherMutationAuthorized,
              !successorScope.existingRuntimeLauncherMutationAuthorized,
              !successorScope.existingTokenizerLauncherMutationAuthorized,
              !successorScope.uploadStepAuthorized,
              ceiling.authorityOnlyNoExecutionEvidence,
              ceiling.implementationAuthorizedAfterGreenAuthorityClosure,
              ceiling.oneExactMainExecutionOpportunityAuthorized,
              falseCeiling.allSatisfy({ !$0 }),
              designContainsRequiredStage,
              status
                == "AUTHORIZED_stage3_tiny_cpu_typed_in_memory_explicit_rng_cursor_resume_implementation_and_one_exact_main_witness_after_green_authority_closure_no_checkpoint_artifact_metal_determinism_native300m_or_downstream_authority"
        else {
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityError
                .contractDrift
        }
    }

    public func canonicalData() throws -> Data {
        try validateExactV1()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeAuthorityError
                .nonCanonicalEncoding
        }
        return value
    }
}
