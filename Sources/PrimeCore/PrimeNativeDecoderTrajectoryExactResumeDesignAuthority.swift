// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

public enum PrimeNativeDecoderTrajectoryExactResumeBlockerV1:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case seed43ArtifactWasEphemeral =
        "seed43_artifact_was_ephemeral"
    case genericTrainEvaluateSurfaceMissing =
        "generic_train_evaluate_surface_missing"
    case optimizerStepAndScheduleStateMissing =
        "optimizer_step_and_schedule_state_missing"
    case mlxRandomStateHasNoDedicatedSupportedTypedExactImporter =
        "mlx_random_state_has_no_dedicated_supported_typed_exact_importer"
    case deterministicDataCursorMissing =
        "deterministic_data_cursor_missing"
    case multiLeafCommitMechanicsMissing =
        "multi_leaf_commit_mechanics_missing"
    case metalRepeatedTokenGradientDeterminismUnproven =
        "metal_repeated_token_gradient_determinism_unproven"
    case native300MTrainingResourceEnvelopeUnproven =
        "native300m_training_resource_envelope_unproven"
}

public enum PrimeNativeDecoderTrajectoryExactResumeStageV1:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case trajectorySchemaAndPureContract =
        "trajectory_schema_and_pure_contract_v1"
    case tinyCPUTrainEvaluateMechanics =
        "tiny_cpu_train_evaluate_mechanics_v1"
    case tinyCPUExplicitRNGCursorResume =
        "tiny_cpu_explicit_rng_cursor_resume_v1"
    case tinyDurableMultileafCommitFaultInjection =
        "tiny_durable_multileaf_commit_fault_injection_v1"
    case tinyRepeatedMetalTrajectoryDeterminismAssay =
        "tiny_repeated_metal_trajectory_determinism_assay_v1"
    case native300MResourceOnlyOneStepProbe =
        "native300m_resource_only_one_step_probe_v1"
    case native300MTrajectoryCheckpointExecution =
        "native300m_trajectory_checkpoint_execution_v1"
    case retainedTrajectoryProvenanceAndAdmission =
        "retained_trajectory_provenance_and_admission_v1"
}

public enum PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case weightsV2 = "weights_v2"
    case optimizerMoments = "optimizer_moments"
    case controlStateManifest = "control_state_manifest"
    case commitManifest = "commit_manifest"
}

public struct PrimeNativeDecoderTrajectoryRepositoryIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let ref: String
    public let revision: String
    public let tree: String
    public let orderedParentRevisions: [String]
    public let pullRequestNumber: Int
    public let reviewedHeadRevision: String
    public let reviewedHeadTree: String
    public let embeddedSourceIdentitySHA256: String
    public let embeddedSourceIdentityIsCanonicalSourceClosureBinding: Bool
    public let sourceClosureFileCount: Int
    public let sourceClosureRecordCount: Int
    public let sourceClosureDirectoryCount: Int
    public let sourceClosureCanonicalByteCount: Int
    public let predecessorSourceClosureCoversEveryRepositoryInputSourceUsedByThisDesign:
        Bool
    public let activeGateRecomputesAndRequiresExactSourceClosure: Bool
    public let currentArcSourceClosureRefreshRequired: Bool
    public let unboundOrRuntimeDiscoveredInputSourceAuthorized: Bool
    public let historyPreservingTwoParentMerge: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
}

public struct PrimeNativeDecoderTrajectoryPredecessorObservationsV1:
    Codable,
    Equatable,
    Sendable
{
    public let seed42FailureObservationID: String
    public let seed42AuthorityID: String
    public let seed42RunID: Int
    public let seed42InitializationSeed: UInt64
    public let seed42ObservedRevision: String
    public let seed42ObservedTree: String
    public let seed42PublicWriteReturnSourceInferred: Bool
    public let seed42PublicWriteCompletionCountSourceInferred: Int
    public let seed42PublicLoadCompletionCountSourceInferred: Int
    public let seed42TypedReceiptEmitted: Bool
    public let seed42ArtifactBytesBound: Bool
    public let seed42ExternalBindingFieldsIndependentlyBound: Bool
    public let seed42ArtifactAvailabilityEstablished: Bool
    public let seed42ArtifactRetentionEstablished: Bool
    public let seed42CheckpointAdmissionGranted: Bool
    public let seed42OriginalArtifactRecoverable: Bool
    public let seed42RegenerationWouldBeNewExecutionNotRecovery: Bool
    public let seed42AuthorityExhausted: Bool

    public let seed43SuccessObservationID: String
    public let seed43AuthorityID: String
    public let seed43EvidenceID: String
    public let seed43RunID: Int
    public let seed43InitializationSeed: UInt64
    public let seed43ObservedRevision: String
    public let seed43ObservedTree: String
    public let seed43ArtifactRelativePath: String
    public let seed43ArtifactByteCount: UInt64
    public let seed43ArtifactSHA256: String
    public let seed43PublicWriteCompletionCountObserved: Int
    public let seed43FreshPublicLoadCompletionCountObserved: Int
    public let seed43ExternalBindingBound: Bool
    public let seed43VerifiedArtifactDeleted: Bool
    public let seed43ParentVerifiedLiteralCleanupCompleted: Bool
    public let seed43ArtifactAvailableBeyondProcess: Bool
    public let seed43ArtifactRetentionEstablished: Bool
    public let seed43ArtifactProvenanceEstablished: Bool
    public let seed43CheckpointAdmissionGranted: Bool
    public let seed43TrainingResumeEstablished: Bool
    public let seed43OriginalArtifactRecoverable: Bool
    public let seed43RegenerationWouldBeNewExecutionNotRecovery: Bool
    public let seed43AuthorityExhausted: Bool

    public let cumulativePublicWriteCompletionCountSourceInferredAfterSeed43Success:
        Int
    public let cumulativePublicLoadCompletionCountSourceInferredAfterSeed43Success:
        Int
    public let usableParentCheckpointCount: Int
    public let neitherObservationSuppliesAvailableResumeParent: Bool
}

public struct PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let revision: String
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String
    public let claimScope: String
}

public struct
    PrimeNativeDecoderTrajectoryExternalDependencyRevisionRelationshipV1:
    Codable,
    Equatable,
    Sendable
{
    public let parentRepository: String
    public let parentRevision: String
    public let childPath: String
    public let gitMode: String
    public let childRepository: String
    public let childRevision: String
}

public struct PrimeNativeDecoderTrajectoryCheckpointV2BoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let externalBindingSchemaID: String
    public let artifactKind: String
    public let checkpointFormat: String
    public let stateScope: String
    public let exactMLXRevision: String
    public let uniqueParameterCount: UInt64
    public let parameterPathCount: Int
    public let totalLogicalParameterByteCount: UInt64
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let kvCacheStateIncluded: Bool
    public let exactExistingV2ByteIdentityMustRemainUnchanged: Bool
    public let wideningOrReinterpretingV2Authorized: Bool
    public let trajectoryEnvelopeMustReferenceExactExternalV2Binding: Bool
    public let seed43ExternalBindingCanBeUsedAsAvailableParent: Bool
    public let newRetainedWeightsArtifactRequiredForFutureResume: Bool
}

public struct PrimeNativeDecoderTrajectoryAdamWStateDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let implementation: String
    public let rootPinnedMLXRevision: String
    public let typedRestoreIntroductionRevision: String
    public let currentTypedRestoreRuntimeRevision: String
    public let typedRestoreIntroductionIsAncestorOfCurrentRevision: Bool
    public let typedRestoreFeasibilitySchemaVersion: Int
    public let configurationScope: String
    public let learningRateFloat32BitPattern: UInt32
    public let beta1Float32BitPattern: UInt32
    public let beta2Float32BitPattern: UInt32
    public let epsilonFloat32BitPattern: UInt32
    public let weightDecayFloat32BitPattern: UInt32
    public let biasCorrectionApplied: Bool
    public let optimizerHasInternalStepCounter: Bool
    public let learningRateIsMutableRuntimeState: Bool
    public let explicitGlobalOptimizerStepRequired: Bool
    public let exactScheduleIdentityRequired: Bool
    public let exactCurrentLearningRateBitPatternRequired: Bool
    public let trainableParameterPathCount: Int
    public let firstMomentTensorCount: Int
    public let secondMomentTensorCount: Int
    public let totalMomentTensorCount: Int
    public let momentDType: String
    public let firstMomentLogicalByteCount: UInt64
    public let secondMomentLogicalByteCount: UInt64
    public let totalMomentLogicalByteCount: UInt64
    public let exactPathShapeDTypeAndLogicalHashRequired: Bool
    public let restoreIntoUninitializedOptimizerRequired: Bool
    public let missingGradientPolicy: String
    public let native300MHyperparametersResolved: Bool
    public let native300MHyperparameterSelectionAuthorized: Bool
}

public struct PrimeNativeDecoderTrajectoryRandomStateDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let upstreamType: String
    public let upstreamStateStorageVisibility: String
    public let upstreamInnerStateExportAvailable: Bool
    public let dedicatedSupportedTypedExactStateImporterAvailable: Bool
    public let innerStateArrayContainerIsDirectStateReference: Bool
    public let innerStateElementsCanMutateStateViaUnderscoredUpdate: Bool
    public let publicUnderscoredMLXArrayUpdateInternalAvailable: Bool
    public let underscoredMutationDocumentedAsImplementationDetail: Bool
    public let underscoredMutationAuthorizedForTrajectoryResume: Bool
    public let underscoredMutationReliabilityEstablishedForTrajectoryResume:
        Bool
    public let upstreamSeedOnlyResetsState: Bool
    public let primeOwnedExplicitKeyCounterRequired: Bool
    public let requiredDomainIDs: [String]
    public let implicitGlobalRandomStateAuthorized: Bool
    public let sharedCounterAcrossDomainsAuthorized: Bool
    public let stochasticModelOperationsAuthorizedInFirstMechanicsArc: Bool
    public let currentDecoderUsesRandomnessAfterInitialization: Bool
    public let evaluationMayConsumeTrainingRandomState: Bool
    public let exactAlgorithmKeyCounterAndConsumptionDigestRequired: Bool
}

public struct PrimeNativeDecoderTrajectoryDataCursorDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let requiredIdentityFields: [String]
    public let requiredPositionFields: [String]
    public let requiredBatchPolicyFields: [String]
    public let requiredBoundaryFields: [String]
    public let snapshotBoundary: String
    public let cursorPointsToNextUnconsumedBatch: Bool
    public let accumulationPhaseAtSnapshot: Int
    public let pendingGradientTensorCountAtSnapshot: Int
    public let pendingPrefetchItemCountAtSnapshot: Int
    public let kvCacheEntryCountAtSnapshot: Int
    public let arbitraryMidAccumulationSnapshotAuthorized: Bool
    public let exactNextBatchTokenAndMaskDigestRequired: Bool
    public let skipOrDuplicateBatchPermitted: Bool
}

public struct PrimeNativeDecoderTrainEvaluateSurfaceDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let proposedProduct: String
    public let proposedTarget: String
    public let proposedDependencies: [String]
    public let genericTokenBatchValidationRequired: Bool
    public let causalLabelShiftRequired: Bool
    public let exactMaskAndPaddingPolicyRequired: Bool
    public let exactLossReductionRequired: Bool
    public let evaluatedGradientsRequired: Bool
    public let exactGradientClippingPolicyRequired: Bool
    public let updateOnlyAtOptimizerStepBoundary: Bool
    public let evaluationIsReadOnly: Bool
    public let evaluationUsesTrainingMode: Bool
    public let evaluationUsesKVCache: Bool
    public let checkpointSnapshotAfterUpdateAndCheckedEvaluation: Bool
    public let surfaceEstablishedByThisAuthority: Bool
}

public struct PrimeNativeDecoderTrajectoryCheckpointLeafDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let role: PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1
    public let artifactKind: String
    public let encoding: String
    public let publicationOrdinal: Int
    public let required: Bool
    public let immutableNoReplace: Bool
    public let independentlyExternallyBound: Bool
    public let authoritativeBeforeFinalCommit: Bool
}

public struct PrimeNativeDecoderTrajectoryCheckpointSchemaDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let externalCommitBindingSchemaID: String
    public let leafInventory: [PrimeNativeDecoderTrajectoryCheckpointLeafDesignV1]
    public let optimizerArtifactFormat: String
    public let controlStateEncoding: String
    public let commitManifestEncoding: String
    public let finalCommitManifestPublishedLast: Bool
    public let finalCommitManifestIsExclusiveCommitPoint: Bool
    public let artifactRootProvidesPerFileNoReplace: Bool
    public let artifactRootProvidesAtomicMultiFileTransaction: Bool
    public let partialPrecommitLeavesAreAuthoritative: Bool
    public let partialPrecommitLeavesMustBeQuarantined: Bool
    public let discoverAndTrustLoadAuthorized: Bool
    public let loadRequiresExternallySuppliedExactCommitBinding: Bool
    public let loadRequiresExactInventoryAndEveryLeafBinding: Bool
    public let inPlaceMutationOrReplacementAuthorized: Bool
    public let failedWritePartialStateCanBePromoted: Bool
    public let kvCachePersisted: Bool
}

public struct PrimeNativeDecoderTrajectoryDeterminismDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let embeddingLookupVJPUsesScatterAdd: Bool
    public let repeatedTokenMetalScatterMayUseAtomicAccumulation: Bool
    public let exactMetalGradientBytesEstablished: Bool
    public let exactCrossDeviceTrajectoryEstablished: Bool
    public let requiredEnvironmentBindings: [String]
    public let sameDeviceRepeatedUninterruptedAndResumedTrialsRequired: Bool
    public let exactTensorByteEqualityRequiredForTrajectoryExactClaim: Bool
    public let ulpToleranceEstablishesTrajectoryExactResume: Bool
    public let toleranceOnlyEstablishesFunctionalContinuity: Bool
}

public struct PrimeNativeDecoderTrajectoryResourceDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let weightsLogicalByteCount: UInt64
    public let optimizerMomentLogicalByteCount: UInt64
    public let minimumCommittedTensorStateByteCount: UInt64
    public let gradientLogicalByteCount: UInt64
    public let minimumStatePlusGradientByteCount: UInt64
    public let containerHeadersAndManifestsIncludedInMinimum: Bool
    public let duplicateMaterializationsGraphsAndTemporaryBuffersIncluded:
        Bool
    public let seed43ObservedWeightsContainerByteCount: UInt64
    public let seed43ObservedLiveStepDurationSeconds: Int
    public let seed43ObservedAvailableFilesystemBytesAfterBuild: UInt64
    public let seed43RunnerMemoryCapacityRecorded: Bool
    public let native300MOneStepTrainingFitsOrdinary45MinuteJobEstablished:
        Bool
    public let native300MOneStepTrainingFitsObservedMemoryEstablished: Bool
    public let separateResourceOnlyProbeRequired: Bool
}

public struct PrimeNativeDecoderTrajectoryExactResumeStagePlanV1:
    Codable,
    Equatable,
    Sendable
{
    public let stage: PrimeNativeDecoderTrajectoryExactResumeStageV1
    public let objective: String
    public let requiredCompletedPredecessorStage:
        PrimeNativeDecoderTrajectoryExactResumeStageV1?
    public let separatelyAuthorizedSuccessorRequired: Bool
    public let implementationAuthorizedByThisDesignAuthority: Bool
    public let trainingExecutionAuthorizedByThisDesignAuthority: Bool
    public let artifactIOAuthorizedByThisDesignAuthority: Bool
    public let retainedArtifactAuthorizedByThisDesignAuthority: Bool
}

/// Append-only, dependency-free design authority for trajectory-exact resume.
///
/// Seed 42 did not complete its one-shot contract. Its write return is only a
/// source-pinned inference; no load, typed receipt, retained artifact, or
/// checkpoint admission exists. Seed 43 later proved one public V2 write and
/// one fresh public V2 load, then the parent deliberately unlinked the fixed
/// artifact and removed its root. Consequently neither run supplies a usable
/// parent checkpoint.
///
/// This declaration designs future state boundaries. It imports no MLX module,
/// implements no train/evaluate or persistence surface, performs no I/O, and
/// authorizes none of the separately staged executions below. The predecessor
/// embedded digest binds repository inputs only. MLX and MLX Swift claims are
/// separately bound to exact external repository revisions and source bytes;
/// those bytes are not reclassified as members of the embedded source closure.
public struct PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let currentArc: String
    public let authoritativeRepositoryIdentity:
        PrimeNativeDecoderTrajectoryRepositoryIdentityV1
    public let predecessorObservations:
        PrimeNativeDecoderTrajectoryPredecessorObservationsV1
    public let v2Boundary:
        PrimeNativeDecoderTrajectoryCheckpointV2BoundaryV1
    public let optimizerStateDesign:
        PrimeNativeDecoderTrajectoryAdamWStateDesignV1
    public let randomStateDesign:
        PrimeNativeDecoderTrajectoryRandomStateDesignV1
    public let dataCursorDesign:
        PrimeNativeDecoderTrajectoryDataCursorDesignV1
    public let trainEvaluateSurfaceDesign:
        PrimeNativeDecoderTrainEvaluateSurfaceDesignV1
    public let trajectoryCheckpointSchema:
        PrimeNativeDecoderTrajectoryCheckpointSchemaDesignV1
    public let determinismDesign:
        PrimeNativeDecoderTrajectoryDeterminismDesignV1
    public let resourceDesign:
        PrimeNativeDecoderTrajectoryResourceDesignV1
    public let externalDependencySourcesIncludedInRepositoryClosure: Bool
    public let externalDependencySourceBindings:
        [PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1]
    public let externalDependencyRevisionRelationships:
        [PrimeNativeDecoderTrajectoryExternalDependencyRevisionRelationshipV1]
    public let everyExternalDependencyClaimUsedByThisDesignHasExactSourceBinding:
        Bool
    public let blockers: [PrimeNativeDecoderTrajectoryExactResumeBlockerV1]
    public let orderedStages:
        [PrimeNativeDecoderTrajectoryExactResumeStagePlanV1]

    public let allowedSourceImports: [String]
    public let mlxImported: Bool
    public let mlxNNImported: Bool
    public let mlxOptimizersImported: Bool
    public let dependencyManifestMutationAuthorized: Bool
    public let processExecutionAuthorized: Bool
    public let filesystemIOAuthorized: Bool
    public let executableTrainingCodeAuthorized: Bool
    public let trainEvaluateImplementationAuthorized: Bool
    public let modelAllocationAuthorized: Bool
    public let decoderForwardAuthorized: Bool
    public let lossEvaluationAuthorized: Bool
    public let backwardAuthorized: Bool
    public let optimizerStepAuthorized: Bool
    public let randomSamplingAuthorized: Bool
    public let checkpointReadAuthorized: Bool
    public let checkpointWriteAuthorized: Bool
    public let artifactRootMutationAuthorized: Bool
    public let liveLauncherAuthorized: Bool
    public let workflowTimeoutChangeAuthorized: Bool
    public let workflowCheckoutDepthChangeAuthorized: Bool
    public let native300MResourceProbeAuthorized: Bool
    public let native300MTrainingConfigurationEstablished: Bool
    public let metalDeterminismClaimEstablished: Bool
    public let trajectoryExactCPUResumeEstablished: Bool
    public let native300MTrajectoryResumeEstablished: Bool
    public let trainingResumeEstablished: Bool
    public let checkpointArtifactAvailabilityEstablished: Bool
    public let checkpointDurabilityEstablished: Bool
    public let checkpointArtifactRetentionAuthorized: Bool
    public let checkpointArtifactUploadAuthorized: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let releaseInstrumentationAuthorized: Bool
    public let trainingExecutionObserved: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1: Self = {
        let externalDependencySourceBindings = [
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "Ergentics/ergentics-mlx-swift",
                revision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                path: "Source/MLX/State.swift",
                gitMode: "100644",
                gitBlob: "54bb1b60a5d644fd7255e2ec2acc812fbbe2302d",
                byteCount: 3_409,
                sha256:
                    "0463a11292161fb036a154f0f44755fe93282f82ffc9f1c713b34a428670e44b",
                claimScope:
                    "random_state_private_storage_inner_state_export_and_seed_only_reset"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "Ergentics/ergentics-mlx-swift",
                revision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                path: "Source/MLX/Protocols.swift",
                gitMode: "100644",
                gitBlob: "015b6fe50db791c8ce723c7bac32d32da3b9c447",
                byteCount: 1_079,
                sha256:
                    "1695559788cb24750c215ec0a3dd403464fb32d1a3ac3a35385fdba8bdc8823c",
                claimScope:
                    "updatable_inner_state_elements_can_mutate_state_via_underscored_implementation_detail"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "Ergentics/ergentics-mlx-swift",
                revision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                path: "Source/MLX/MLXArray.swift",
                gitMode: "100644",
                gitBlob: "121955b49b4eefd2f05d117d710990f8ba15f816",
                byteCount: 19_676,
                sha256:
                    "0cd516b95d5d75840978e265d3069709a8f557de96264df8605f246d91b0126c",
                claimScope:
                    "public_underscored_mlxarray_update_internal_context_mutation_surface"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "Ergentics/ergentics-mlx-swift",
                revision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                path: "Source/MLXOptimizers/Optimizers.swift",
                gitMode: "100644",
                gitBlob: "fb9c5d9636a211bb74fae7bf6a1dbbd4fe01d7b9",
                byteCount: 24_109,
                sha256:
                    "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d",
                claimScope:
                    "adamw_configuration_mutability_bias_correction_absence_and_no_step_counter"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "Ergentics/ergentics-mlx-swift",
                revision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                path: "Source/MLXNN/Embedding.swift",
                gitMode: "100644",
                gitBlob: "dbda7607bc4580cf914b2fcd5c0ab6094165359a",
                byteCount: 1_878,
                sha256:
                    "43ed8569fea7af6d5c028992662d6c0cbc256fe6f3cc8342d0b4a3ded4136f12",
                claimScope:
                    "embedding_forward_uses_indexed_weight_gather"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "Ergentics/ergentics-mlx-swift",
                revision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                path: "Source/MLXOptimizers/AdamOptimizerState.swift",
                gitMode: "100644",
                gitBlob: "f1ba85c50f8f181b06fb48bde066b8e11a5331f3",
                byteCount: 9_717,
                sha256:
                    "175f6325730aa9a658f7aab91b9eb7d6c6d11b375cfa951297db447dfd9ae86d",
                claimScope:
                    "current_typed_adam_moment_export_and_uninitialized_path_shape_dtype_checked_import"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "Ergentics/ergentics-mlx-swift",
                revision:
                    "68904d54b72871f26968261ae05d4fbb7c5e3142",
                path: "Source/MLXOptimizers/AdamOptimizerState.swift",
                gitMode: "100644",
                gitBlob: "2696c7e436e8ca4d74107694ea65bb0993314878",
                byteCount: 9_985,
                sha256:
                    "3ee01b6d2b84606258bbd6e1e913a6fbc09acec66e0a8bcb38fcc1f964868676",
                claimScope:
                    "historical_typed_adam_state_introduction_predecessor_only"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "Ergentics/ergentics-mlx-swift",
                revision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                path: "Source/MLX/MLXArray+Indexing.swift",
                gitMode: "100644",
                gitBlob: "9a891b5df0d6f2bdeb0df584497c2c068b65a4e9",
                byteCount: 49_556,
                sha256:
                    "bde9521ff694e054f05c414442df77e7bcd816c9ee8929f538d9c2bd22d3f4fa",
                claimScope:
                    "array_indexing_routes_array_indices_to_mlx_gather"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "ml-explore/mlx-c",
                revision:
                    "0726ca922fc902c4c61ef9c27d94132be418e945",
                path: "mlx/c/ops.cpp",
                gitMode: "100644",
                gitBlob: "f5eac1b48e75ec3d0a41903816e61168b8a78967",
                byteCount: 95_167,
                sha256:
                    "7b3e5028628d68c4aec3dd0587eea760d245943f3a06b6dc1d11ceebe0f040ec",
                claimScope:
                    "mlx_gather_c_api_routes_to_mlx_core_gather"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path: "mlx/primitives.cpp",
                gitMode: "100644",
                gitBlob: "92e54f99918de054fa0b521d13e4c8f415ce2fc1",
                byteCount: 179_760,
                sha256:
                    "3f87a0cfcf4b15cfda6c14b00401828500a7eee8c397ce30400d76d6d0c71ad5",
                claimScope:
                    "gather_vjp_routes_source_gradient_through_scatter_add"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path:
                    "mlx/backend/metal/kernels/indexing/scatter.h",
                gitMode: "100644",
                gitBlob: "f0217b3369f2c87c826a963ba900773d3b59bc91",
                byteCount: 1_791,
                sha256:
                    "6d6d81912ce7d6b896eb0225d1ac6885d30cd30213b67d996d3efc03f4a3c292",
                claimScope:
                    "metal_general_scatter_uses_atomic_output_updates"),
            PrimeNativeDecoderTrajectoryExternalDependencySourceBindingV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path:
                    "mlx/backend/metal/kernels/indexing/scatter_axis.h",
                gitMode: "100644",
                gitBlob: "73fd7ab4a3dfbf75e7a92451997bcf56cfa71f23",
                byteCount: 1_610,
                sha256:
                    "43eabd0216101f8e32f5cdd19ce40b7f954564be27fad98a5e0fe345e7b94ce5",
                claimScope:
                    "metal_axis_scatter_uses_atomic_output_updates"),
        ]
        let externalDependencyRevisionRelationships = [
            PrimeNativeDecoderTrajectoryExternalDependencyRevisionRelationshipV1(
                parentRepository: "Ergentics/ergentics-mlx-swift",
                parentRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                childPath: "Source/Cmlx/mlx",
                gitMode: "160000",
                childRepository: "ml-explore/mlx",
                childRevision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe"),
            PrimeNativeDecoderTrajectoryExternalDependencyRevisionRelationshipV1(
                parentRepository: "Ergentics/ergentics-mlx-swift",
                parentRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                childPath: "Source/Cmlx/mlx-c",
                gitMode: "160000",
                childRepository: "ml-explore/mlx-c",
                childRevision:
                    "0726ca922fc902c4c61ef9c27d94132be418e945"),
        ]

        let leafInventory = [
            PrimeNativeDecoderTrajectoryCheckpointLeafDesignV1(
                role: .weightsV2,
                artifactKind:
                    "prime_native_decoder_model_weights_only_checkpoint",
                encoding: "safetensors_plus_exact_v2_external_binding",
                publicationOrdinal: 1,
                required: true,
                immutableNoReplace: true,
                independentlyExternallyBound: true,
                authoritativeBeforeFinalCommit: false),
            PrimeNativeDecoderTrajectoryCheckpointLeafDesignV1(
                role: .optimizerMoments,
                artifactKind:
                    "prime_native_decoder_adamw_moments_checkpoint_v1",
                encoding: "safetensors",
                publicationOrdinal: 2,
                required: true,
                immutableNoReplace: true,
                independentlyExternallyBound: true,
                authoritativeBeforeFinalCommit: false),
            PrimeNativeDecoderTrajectoryCheckpointLeafDesignV1(
                role: .controlStateManifest,
                artifactKind:
                    "prime_native_decoder_trajectory_control_state_v1",
                encoding: "canonical_json",
                publicationOrdinal: 3,
                required: true,
                immutableNoReplace: true,
                independentlyExternallyBound: true,
                authoritativeBeforeFinalCommit: false),
            PrimeNativeDecoderTrajectoryCheckpointLeafDesignV1(
                role: .commitManifest,
                artifactKind:
                    "prime_native_decoder_trajectory_commit_manifest_v1",
                encoding: "canonical_json",
                publicationOrdinal: 4,
                required: true,
                immutableNoReplace: true,
                independentlyExternallyBound: true,
                authoritativeBeforeFinalCommit: false),
        ]

        let stages = [
            PrimeNativeDecoderTrajectoryExactResumeStagePlanV1(
                stage: .trajectorySchemaAndPureContract,
                objective:
                    "freeze_dependency_free_schema_blockers_boundaries_and_false_ceiling_with_pure_mutation_validation",
                requiredCompletedPredecessorStage: nil,
                separatelyAuthorizedSuccessorRequired: true,
                implementationAuthorizedByThisDesignAuthority: false,
                trainingExecutionAuthorizedByThisDesignAuthority: false,
                artifactIOAuthorizedByThisDesignAuthority: false,
                retainedArtifactAuthorizedByThisDesignAuthority: false),
            PrimeNativeDecoderTrajectoryExactResumeStagePlanV1(
                stage: .tinyCPUTrainEvaluateMechanics,
                objective:
                    "implement_generic_causal_train_evaluate_surfaces_and_exact_two_step_cpu_control",
                requiredCompletedPredecessorStage:
                    .trajectorySchemaAndPureContract,
                separatelyAuthorizedSuccessorRequired: true,
                implementationAuthorizedByThisDesignAuthority: false,
                trainingExecutionAuthorizedByThisDesignAuthority: false,
                artifactIOAuthorizedByThisDesignAuthority: false,
                retainedArtifactAuthorizedByThisDesignAuthority: false),
            PrimeNativeDecoderTrajectoryExactResumeStagePlanV1(
                stage: .tinyCPUExplicitRNGCursorResume,
                objective:
                    "prove_uninterrupted_equals_resumed_with_prime_owned_rng_domains_exact_cursor_and_optimizer_step_boundary",
                requiredCompletedPredecessorStage:
                    .tinyCPUTrainEvaluateMechanics,
                separatelyAuthorizedSuccessorRequired: true,
                implementationAuthorizedByThisDesignAuthority: false,
                trainingExecutionAuthorizedByThisDesignAuthority: false,
                artifactIOAuthorizedByThisDesignAuthority: false,
                retainedArtifactAuthorizedByThisDesignAuthority: false),
            PrimeNativeDecoderTrajectoryExactResumeStagePlanV1(
                stage: .tinyDurableMultileafCommitFaultInjection,
                objective:
                    "prove_immutable_leaf_publication_final_commit_and_partial_write_quarantine",
                requiredCompletedPredecessorStage:
                    .tinyCPUExplicitRNGCursorResume,
                separatelyAuthorizedSuccessorRequired: true,
                implementationAuthorizedByThisDesignAuthority: false,
                trainingExecutionAuthorizedByThisDesignAuthority: false,
                artifactIOAuthorizedByThisDesignAuthority: false,
                retainedArtifactAuthorizedByThisDesignAuthority: false),
            PrimeNativeDecoderTrajectoryExactResumeStagePlanV1(
                stage: .tinyRepeatedMetalTrajectoryDeterminismAssay,
                objective:
                    "measure_repeated_same_device_uninterrupted_and_resumed_exact_gradient_and_parameter_bytes",
                requiredCompletedPredecessorStage:
                    .tinyDurableMultileafCommitFaultInjection,
                separatelyAuthorizedSuccessorRequired: true,
                implementationAuthorizedByThisDesignAuthority: false,
                trainingExecutionAuthorizedByThisDesignAuthority: false,
                artifactIOAuthorizedByThisDesignAuthority: false,
                retainedArtifactAuthorizedByThisDesignAuthority: false),
            PrimeNativeDecoderTrajectoryExactResumeStagePlanV1(
                stage: .native300MResourceOnlyOneStepProbe,
                objective:
                    "measure_native300m_one_step_memory_disk_and_duration_without_quality_or_checkpoint_claim",
                requiredCompletedPredecessorStage:
                    .tinyRepeatedMetalTrajectoryDeterminismAssay,
                separatelyAuthorizedSuccessorRequired: true,
                implementationAuthorizedByThisDesignAuthority: false,
                trainingExecutionAuthorizedByThisDesignAuthority: false,
                artifactIOAuthorizedByThisDesignAuthority: false,
                retainedArtifactAuthorizedByThisDesignAuthority: false),
            PrimeNativeDecoderTrajectoryExactResumeStagePlanV1(
                stage: .native300MTrajectoryCheckpointExecution,
                objective:
                    "execute_one_bounded_native300m_step_checkpoint_restore_and_exact_successor_step_only_after_assay_and_resource_clearance",
                requiredCompletedPredecessorStage:
                    .native300MResourceOnlyOneStepProbe,
                separatelyAuthorizedSuccessorRequired: true,
                implementationAuthorizedByThisDesignAuthority: false,
                trainingExecutionAuthorizedByThisDesignAuthority: false,
                artifactIOAuthorizedByThisDesignAuthority: false,
                retainedArtifactAuthorizedByThisDesignAuthority: false),
            PrimeNativeDecoderTrajectoryExactResumeStagePlanV1(
                stage: .retainedTrajectoryProvenanceAndAdmission,
                objective:
                    "separately_bind_retained_bytes_provenance_and_any_checkpoint_admission_after_mechanics_succeed",
                requiredCompletedPredecessorStage:
                    .native300MTrajectoryCheckpointExecution,
                separatelyAuthorizedSuccessorRequired: true,
                implementationAuthorizedByThisDesignAuthority: false,
                trainingExecutionAuthorizedByThisDesignAuthority: false,
                artifactIOAuthorizedByThisDesignAuthority: false,
                retainedArtifactAuthorizedByThisDesignAuthority: false),
        ]

        return Self(
            schemaVersion: 1,
            authorityID:
                "ergentics_prime_native_decoder_trajectory_exact_resume_design_authority_v1",
            authorityKind:
                "append_only_dependency_free_nonexecuting_trajectory_exact_resume_design_authority",
            currentArc: "trajectory_schema_and_pure_contract_v1",
            authoritativeRepositoryIdentity: .init(
                repository: "Ergentics/ergentics-prime",
                ref: "refs/heads/main",
                revision:
                    "3ab523afa0a50fbea42dd3e3ead1f010b7e1b800",
                tree:
                    "5204aaa93f0370382e2378eb634f7e0900cd3770",
                orderedParentRevisions: [
                    "44cfa2caa3af5bb44ad53294de33ba2d0faa9a59",
                    "84f508b7f1d1e491b5303d35913a341054292db3",
                ],
                pullRequestNumber: 80,
                reviewedHeadRevision:
                    "84f508b7f1d1e491b5303d35913a341054292db3",
                reviewedHeadTree:
                    "5204aaa93f0370382e2378eb634f7e0900cd3770",
                embeddedSourceIdentitySHA256:
                    "dd13f4b3d37610dfe6ecd35e5612e87b0df1ada28836fc111a2bbdc4ed3cb6bb",
                embeddedSourceIdentityIsCanonicalSourceClosureBinding: true,
                sourceClosureFileCount: 414,
                sourceClosureRecordCount: 413,
                sourceClosureDirectoryCount: 132,
                sourceClosureCanonicalByteCount: 83_251,
                predecessorSourceClosureCoversEveryRepositoryInputSourceUsedByThisDesign:
                    true,
                activeGateRecomputesAndRequiresExactSourceClosure: true,
                currentArcSourceClosureRefreshRequired: true,
                unboundOrRuntimeDiscoveredInputSourceAuthorized: false,
                historyPreservingTwoParentMerge: true,
                mergeTreeEqualsReviewedHeadTree: true),
            predecessorObservations: .init(
                seed42FailureObservationID:
                    "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_failure_observation_v1",
                seed42AuthorityID:
                    "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_authority_v1",
                seed42RunID: 31_472_165_002,
                seed42InitializationSeed: 42,
                seed42ObservedRevision:
                    "27749af3347437daa693d4375acb759283923a4a",
                seed42ObservedTree:
                    "a222082fa6b5c469cc4da967a77cbb7e4960e455",
                seed42PublicWriteReturnSourceInferred: true,
                seed42PublicWriteCompletionCountSourceInferred: 1,
                seed42PublicLoadCompletionCountSourceInferred: 0,
                seed42TypedReceiptEmitted: false,
                seed42ArtifactBytesBound: false,
                seed42ExternalBindingFieldsIndependentlyBound: false,
                seed42ArtifactAvailabilityEstablished: false,
                seed42ArtifactRetentionEstablished: false,
                seed42CheckpointAdmissionGranted: false,
                seed42OriginalArtifactRecoverable: false,
                seed42RegenerationWouldBeNewExecutionNotRecovery: true,
                seed42AuthorityExhausted: true,
                seed43SuccessObservationID:
                    "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_observation_v1",
                seed43AuthorityID:
                    "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_authority_v1",
                seed43EvidenceID:
                    "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_evidence_v1",
                seed43RunID: 31_484_642_403,
                seed43InitializationSeed: 43,
                seed43ObservedRevision:
                    "44cfa2caa3af5bb44ad53294de33ba2d0faa9a59",
                seed43ObservedTree:
                    "fbd57cd9de786e38121fa02b0664b1fb4fcd3d3c",
                seed43ArtifactRelativePath:
                    "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors",
                seed43ArtifactByteCount: 1_084_525_304,
                seed43ArtifactSHA256:
                    "a6dae67b9a24e3d0220d22e3060bb43bab7d8cd027d97ea635db8580774cd538",
                seed43PublicWriteCompletionCountObserved: 1,
                seed43FreshPublicLoadCompletionCountObserved: 1,
                seed43ExternalBindingBound: true,
                seed43VerifiedArtifactDeleted: true,
                seed43ParentVerifiedLiteralCleanupCompleted: true,
                seed43ArtifactAvailableBeyondProcess: false,
                seed43ArtifactRetentionEstablished: false,
                seed43ArtifactProvenanceEstablished: false,
                seed43CheckpointAdmissionGranted: false,
                seed43TrainingResumeEstablished: false,
                seed43OriginalArtifactRecoverable: false,
                seed43RegenerationWouldBeNewExecutionNotRecovery: true,
                seed43AuthorityExhausted: true,
                cumulativePublicWriteCompletionCountSourceInferredAfterSeed43Success:
                    2,
                cumulativePublicLoadCompletionCountSourceInferredAfterSeed43Success:
                    1,
                usableParentCheckpointCount: 0,
                neitherObservationSuppliesAvailableResumeParent: true),
            v2Boundary: .init(
                schemaVersion: 2,
                schemaID:
                    "ergentics_prime_native_decoder_weights_checkpoint_v2",
                externalBindingSchemaID:
                    "manifest_plus_canonical_manifest_identity_plus_prime_artifact_binding_v2",
                artifactKind:
                    "prime_native_decoder_model_weights_only_checkpoint",
                checkpointFormat: "safetensors",
                stateScope:
                    "model_parameters_only_no_optimizer_rng_cursor_or_cache",
                exactMLXRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                uniqueParameterCount: 271_107_072,
                parameterPathCount: 218,
                totalLogicalParameterByteCount: 1_084_428_288,
                optimizerStateIncluded: false,
                rngStateIncluded: false,
                dataCursorIncluded: false,
                kvCacheStateIncluded: false,
                exactExistingV2ByteIdentityMustRemainUnchanged: true,
                wideningOrReinterpretingV2Authorized: false,
                trajectoryEnvelopeMustReferenceExactExternalV2Binding: true,
                seed43ExternalBindingCanBeUsedAsAvailableParent: false,
                newRetainedWeightsArtifactRequiredForFutureResume: true),
            optimizerStateDesign: .init(
                implementation: "MLXOptimizers.AdamW",
                rootPinnedMLXRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                typedRestoreIntroductionRevision:
                    "68904d54b72871f26968261ae05d4fbb7c5e3142",
                currentTypedRestoreRuntimeRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                typedRestoreIntroductionIsAncestorOfCurrentRevision: true,
                typedRestoreFeasibilitySchemaVersion: 2,
                configurationScope:
                    "tiny_cpu_mechanics_only_not_native300m_training",
                learningRateFloat32BitPattern: 953_267_991,
                beta1Float32BitPattern: 1_063_675_494,
                beta2Float32BitPattern: 1_065_336_439,
                epsilonFloat32BitPattern: 841_731_191,
                weightDecayFloat32BitPattern: 1_008_981_770,
                biasCorrectionApplied: false,
                optimizerHasInternalStepCounter: false,
                learningRateIsMutableRuntimeState: true,
                explicitGlobalOptimizerStepRequired: true,
                exactScheduleIdentityRequired: true,
                exactCurrentLearningRateBitPatternRequired: true,
                trainableParameterPathCount: 218,
                firstMomentTensorCount: 218,
                secondMomentTensorCount: 218,
                totalMomentTensorCount: 436,
                momentDType: "float32",
                firstMomentLogicalByteCount: 1_084_428_288,
                secondMomentLogicalByteCount: 1_084_428_288,
                totalMomentLogicalByteCount: 2_168_856_576,
                exactPathShapeDTypeAndLogicalHashRequired: true,
                restoreIntoUninitializedOptimizerRequired: true,
                missingGradientPolicy: "reject",
                native300MHyperparametersResolved: false,
                native300MHyperparameterSelectionAuthorized: false),
            randomStateDesign: .init(
                upstreamType: "MLXRandom.RandomState",
                upstreamStateStorageVisibility: "private",
                upstreamInnerStateExportAvailable: true,
                dedicatedSupportedTypedExactStateImporterAvailable: false,
                innerStateArrayContainerIsDirectStateReference: false,
                innerStateElementsCanMutateStateViaUnderscoredUpdate: true,
                publicUnderscoredMLXArrayUpdateInternalAvailable: true,
                underscoredMutationDocumentedAsImplementationDetail: true,
                underscoredMutationAuthorizedForTrajectoryResume: false,
                underscoredMutationReliabilityEstablishedForTrajectoryResume:
                    false,
                upstreamSeedOnlyResetsState: true,
                primeOwnedExplicitKeyCounterRequired: true,
                requiredDomainIDs: [
                    "model_initialization_v1",
                    "training_data_order_v1",
                    "augmentation_v1",
                    "evaluation_v1",
                ],
                implicitGlobalRandomStateAuthorized: false,
                sharedCounterAcrossDomainsAuthorized: false,
                stochasticModelOperationsAuthorizedInFirstMechanicsArc:
                    false,
                currentDecoderUsesRandomnessAfterInitialization: false,
                evaluationMayConsumeTrainingRandomState: false,
                exactAlgorithmKeyCounterAndConsumptionDigestRequired: true),
            dataCursorDesign: .init(
                requiredIdentityFields: [
                    "corpus_binding",
                    "tokenizer_binding",
                    "example_generator_binding",
                    "source_inventory_binding",
                    "split_identity",
                    "curriculum_identity",
                ],
                requiredPositionFields: [
                    "epoch",
                    "permutation_algorithm",
                    "permutation_domain",
                    "permutation_key",
                    "permutation_hash",
                    "next_row_index",
                    "next_row_ids",
                ],
                requiredBatchPolicyFields: [
                    "batch_size",
                    "microbatch_size",
                    "sequence_length",
                    "padding_policy",
                    "drop_last_policy",
                    "causal_mask_policy",
                ],
                requiredBoundaryFields: [
                    "optimizer_step",
                    "accumulation_phase",
                    "pending_gradient_count",
                    "pending_prefetch_count",
                    "kv_cache_entry_count",
                    "next_batch_token_and_mask_digest",
                ],
                snapshotBoundary:
                    "after_optimizer_update_and_checked_read_only_evaluation_before_next_batch_consumption",
                cursorPointsToNextUnconsumedBatch: true,
                accumulationPhaseAtSnapshot: 0,
                pendingGradientTensorCountAtSnapshot: 0,
                pendingPrefetchItemCountAtSnapshot: 0,
                kvCacheEntryCountAtSnapshot: 0,
                arbitraryMidAccumulationSnapshotAuthorized: false,
                exactNextBatchTokenAndMaskDigestRequired: true,
                skipOrDuplicateBatchPermitted: false),
            trainEvaluateSurfaceDesign: .init(
                proposedProduct: "PrimeNativeDecoderTraining",
                proposedTarget: "PrimeNativeDecoderTraining",
                proposedDependencies: [
                    "PrimeCore",
                    "PrimeNativeDecoder",
                    "PrimeNativeDecoderCheckpoint",
                    "MLX",
                    "MLXNN",
                    "MLXOptimizers",
                ],
                genericTokenBatchValidationRequired: true,
                causalLabelShiftRequired: true,
                exactMaskAndPaddingPolicyRequired: true,
                exactLossReductionRequired: true,
                evaluatedGradientsRequired: true,
                exactGradientClippingPolicyRequired: true,
                updateOnlyAtOptimizerStepBoundary: true,
                evaluationIsReadOnly: true,
                evaluationUsesTrainingMode: false,
                evaluationUsesKVCache: false,
                checkpointSnapshotAfterUpdateAndCheckedEvaluation: true,
                surfaceEstablishedByThisAuthority: false),
            trajectoryCheckpointSchema: .init(
                schemaVersion: 1,
                schemaID:
                    "ergentics_prime_native_decoder_trajectory_exact_resume_checkpoint_v1",
                externalCommitBindingSchemaID:
                    "ergentics_prime_native_decoder_trajectory_exact_resume_external_commit_binding_v1",
                leafInventory: leafInventory,
                optimizerArtifactFormat: "safetensors",
                controlStateEncoding: "canonical_json",
                commitManifestEncoding: "canonical_json",
                finalCommitManifestPublishedLast: true,
                finalCommitManifestIsExclusiveCommitPoint: true,
                artifactRootProvidesPerFileNoReplace: true,
                artifactRootProvidesAtomicMultiFileTransaction: false,
                partialPrecommitLeavesAreAuthoritative: false,
                partialPrecommitLeavesMustBeQuarantined: true,
                discoverAndTrustLoadAuthorized: false,
                loadRequiresExternallySuppliedExactCommitBinding: true,
                loadRequiresExactInventoryAndEveryLeafBinding: true,
                inPlaceMutationOrReplacementAuthorized: false,
                failedWritePartialStateCanBePromoted: false,
                kvCachePersisted: false),
            determinismDesign: .init(
                embeddingLookupVJPUsesScatterAdd: true,
                repeatedTokenMetalScatterMayUseAtomicAccumulation: true,
                exactMetalGradientBytesEstablished: false,
                exactCrossDeviceTrajectoryEstablished: false,
                requiredEnvironmentBindings: [
                    "MLX_ENABLE_TF32=0",
                    "operating_system_and_build",
                    "xcode_swift_sdk_and_driver",
                    "exact_mlx_revision",
                    "exact_metallib_binding",
                    "metal_device_identity",
                    "tensor_shapes_and_dtypes",
                    "stream_assignment_and_order",
                    "evaluation_order",
                    "compile_mode",
                ],
                sameDeviceRepeatedUninterruptedAndResumedTrialsRequired:
                    true,
                exactTensorByteEqualityRequiredForTrajectoryExactClaim: true,
                ulpToleranceEstablishesTrajectoryExactResume: false,
                toleranceOnlyEstablishesFunctionalContinuity: true),
            resourceDesign: .init(
                weightsLogicalByteCount: 1_084_428_288,
                optimizerMomentLogicalByteCount: 2_168_856_576,
                minimumCommittedTensorStateByteCount: 3_253_284_864,
                gradientLogicalByteCount: 1_084_428_288,
                minimumStatePlusGradientByteCount: 4_337_713_152,
                containerHeadersAndManifestsIncludedInMinimum: false,
                duplicateMaterializationsGraphsAndTemporaryBuffersIncluded:
                    false,
                seed43ObservedWeightsContainerByteCount: 1_084_525_304,
                seed43ObservedLiveStepDurationSeconds: 1_631,
                seed43ObservedAvailableFilesystemBytesAfterBuild:
                    101_145_567_232,
                seed43RunnerMemoryCapacityRecorded: false,
                native300MOneStepTrainingFitsOrdinary45MinuteJobEstablished:
                    false,
                native300MOneStepTrainingFitsObservedMemoryEstablished: false,
                separateResourceOnlyProbeRequired: true),
            externalDependencySourcesIncludedInRepositoryClosure: false,
            externalDependencySourceBindings:
                externalDependencySourceBindings,
            externalDependencyRevisionRelationships:
                externalDependencyRevisionRelationships,
            everyExternalDependencyClaimUsedByThisDesignHasExactSourceBinding:
                true,
            blockers: PrimeNativeDecoderTrajectoryExactResumeBlockerV1
                .allCases,
            orderedStages: stages,
            allowedSourceImports: ["Foundation"],
            mlxImported: false,
            mlxNNImported: false,
            mlxOptimizersImported: false,
            dependencyManifestMutationAuthorized: false,
            processExecutionAuthorized: false,
            filesystemIOAuthorized: false,
            executableTrainingCodeAuthorized: false,
            trainEvaluateImplementationAuthorized: false,
            modelAllocationAuthorized: false,
            decoderForwardAuthorized: false,
            lossEvaluationAuthorized: false,
            backwardAuthorized: false,
            optimizerStepAuthorized: false,
            randomSamplingAuthorized: false,
            checkpointReadAuthorized: false,
            checkpointWriteAuthorized: false,
            artifactRootMutationAuthorized: false,
            liveLauncherAuthorized: false,
            workflowTimeoutChangeAuthorized: false,
            workflowCheckoutDepthChangeAuthorized: false,
            native300MResourceProbeAuthorized: false,
            native300MTrainingConfigurationEstablished: false,
            metalDeterminismClaimEstablished: false,
            trajectoryExactCPUResumeEstablished: false,
            native300MTrajectoryResumeEstablished: false,
            trainingResumeEstablished: false,
            checkpointArtifactAvailabilityEstablished: false,
            checkpointDurabilityEstablished: false,
            checkpointArtifactRetentionAuthorized: false,
            checkpointArtifactUploadAuthorized: false,
            checkpointArtifactProvenanceEstablished: false,
            checkpointAdmissionGranted: false,
            releaseInstrumentationAuthorized: false,
            trainingExecutionObserved: false,
            modelQualityEstablished: false,
            candidateAdmissionGranted: false,
            trialAuthorized: false,
            canaryReplacementAuthorized: false,
            quantizationAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            status:
                "ABSTAIN_design_only_no_usable_seed42_or_seed43_parent_no_training_io_retention_provenance_admission_or_exact_metal_resume_claim",
            orderedNextActions: [
                "freeze_trajectory_schema_and_pure_mutation_contract",
                "separately_authorize_tiny_cpu_train_evaluate_mechanics",
                "separately_authorize_tiny_cpu_explicit_rng_cursor_resume",
                "separately_authorize_tiny_durable_multileaf_commit_fault_injection",
                "separately_authorize_tiny_repeated_metal_trajectory_determinism_assay",
                "separately_authorize_native300m_resource_only_one_step_probe",
                "separately_authorize_native300m_trajectory_checkpoint_execution_only_after_clearance",
                "separately_authorize_retained_trajectory_provenance_and_admission",
            ])
    }()

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let failure =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1
                .frozenV1
        let ioAuthority =
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1
        do {
            try failure.validateExactV1()
            try ioAuthority.validateExactV1()
        } catch {
            throw
                PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityError
                    .contractDrift
        }

        let exactStages =
            PrimeNativeDecoderTrajectoryExactResumeStageV1.allCases
        let stageValues = orderedStages.map(\.stage)
        let publicationOrdinals =
            trajectoryCheckpointSchema.leafInventory.map(
                \.publicationOrdinal)
        let falseStageCeilings = orderedStages.allSatisfy { stage in
            stage.separatelyAuthorizedSuccessorRequired
                && !stage.implementationAuthorizedByThisDesignAuthority
                && !stage.trainingExecutionAuthorizedByThisDesignAuthority
                && !stage.artifactIOAuthorizedByThisDesignAuthority
                && !stage.retainedArtifactAuthorizedByThisDesignAuthority
        }
        let falseExecutionAndAdmissionCeilings = [
            mlxImported,
            mlxNNImported,
            mlxOptimizersImported,
            dependencyManifestMutationAuthorized,
            processExecutionAuthorized,
            filesystemIOAuthorized,
            executableTrainingCodeAuthorized,
            trainEvaluateImplementationAuthorized,
            modelAllocationAuthorized,
            decoderForwardAuthorized,
            lossEvaluationAuthorized,
            backwardAuthorized,
            optimizerStepAuthorized,
            randomSamplingAuthorized,
            checkpointReadAuthorized,
            checkpointWriteAuthorized,
            artifactRootMutationAuthorized,
            liveLauncherAuthorized,
            workflowTimeoutChangeAuthorized,
            workflowCheckoutDepthChangeAuthorized,
            native300MResourceProbeAuthorized,
            native300MTrainingConfigurationEstablished,
            metalDeterminismClaimEstablished,
            trajectoryExactCPUResumeEstablished,
            native300MTrajectoryResumeEstablished,
            trainingResumeEstablished,
            checkpointArtifactAvailabilityEstablished,
            checkpointDurabilityEstablished,
            checkpointArtifactRetentionAuthorized,
            checkpointArtifactUploadAuthorized,
            checkpointArtifactProvenanceEstablished,
            checkpointAdmissionGranted,
            releaseInstrumentationAuthorized,
            trainingExecutionObserved,
            modelQualityEstablished,
            candidateAdmissionGranted,
            trialAuthorized,
            canaryReplacementAuthorized,
            quantizationAuthorized,
            productUseAuthorized,
            publicationAuthorized,
        ].allSatisfy { !$0 }
        let expectedExternalDependencySourcePaths = [
            "Source/MLX/State.swift",
            "Source/MLX/Protocols.swift",
            "Source/MLX/MLXArray.swift",
            "Source/MLXOptimizers/Optimizers.swift",
            "Source/MLXNN/Embedding.swift",
            "Source/MLXOptimizers/AdamOptimizerState.swift",
            "Source/MLXOptimizers/AdamOptimizerState.swift",
            "Source/MLX/MLXArray+Indexing.swift",
            "mlx/c/ops.cpp",
            "mlx/primitives.cpp",
            "mlx/backend/metal/kernels/indexing/scatter.h",
            "mlx/backend/metal/kernels/indexing/scatter_axis.h",
        ]
        let externalDependencyBindingsAreExactLowercaseHex =
            externalDependencySourceBindings.allSatisfy { binding in
                binding.gitMode == "100644"
                    && binding.gitBlob.utf8.count == 40
                    && binding.gitBlob.utf8.allSatisfy { byte in
                        (byte >= 48 && byte <= 57)
                            || (byte >= 97 && byte <= 102)
                    }
                    && binding.byteCount > 0
                    && binding.sha256.utf8.count == 64
                    && binding.sha256.utf8.allSatisfy { byte in
                        (byte >= 48 && byte <= 57)
                            || (byte >= 97 && byte <= 102)
                    }
                    && !binding.claimScope.isEmpty
            }
        let externalDependencyBindingIdentities =
            externalDependencySourceBindings.map { binding in
                "\(binding.repository)@\(binding.revision):\(binding.path)"
            }

        guard self == Self.frozenV1,
              schemaVersion == 1,
              authorityID
                == "ergentics_prime_native_decoder_trajectory_exact_resume_design_authority_v1",
              currentArc == exactStages[0].rawValue,
              authoritativeRepositoryIdentity.revision
                == "3ab523afa0a50fbea42dd3e3ead1f010b7e1b800",
              authoritativeRepositoryIdentity.tree
                == "5204aaa93f0370382e2378eb634f7e0900cd3770",
              authoritativeRepositoryIdentity.orderedParentRevisions == [
                  "44cfa2caa3af5bb44ad53294de33ba2d0faa9a59",
                  "84f508b7f1d1e491b5303d35913a341054292db3",
              ],
              authoritativeRepositoryIdentity
                .historyPreservingTwoParentMerge,
              authoritativeRepositoryIdentity.mergeTreeEqualsReviewedHeadTree,
              authoritativeRepositoryIdentity
                .embeddedSourceIdentityIsCanonicalSourceClosureBinding,
              authoritativeRepositoryIdentity.sourceClosureFileCount == 414,
              authoritativeRepositoryIdentity.sourceClosureRecordCount == 413,
              authoritativeRepositoryIdentity.sourceClosureDirectoryCount
                == 132,
              authoritativeRepositoryIdentity.sourceClosureCanonicalByteCount
                == 83_251,
              authoritativeRepositoryIdentity
                .predecessorSourceClosureCoversEveryRepositoryInputSourceUsedByThisDesign,
              authoritativeRepositoryIdentity
                .activeGateRecomputesAndRequiresExactSourceClosure,
              authoritativeRepositoryIdentity.currentArcSourceClosureRefreshRequired,
              !authoritativeRepositoryIdentity
                .unboundOrRuntimeDiscoveredInputSourceAuthorized,
              predecessorObservations.seed42FailureObservationID
                == failure.observationID,
              predecessorObservations.seed42AuthorityID
                == failure.predecessorAuthorityID,
              predecessorObservations.seed42AuthorityExhausted,
              predecessorObservations
                .seed42PublicWriteCompletionCountSourceInferred == 1,
              predecessorObservations
                .seed42PublicLoadCompletionCountSourceInferred == 0,
              !predecessorObservations.seed42ArtifactBytesBound,
              !predecessorObservations
                .seed42ExternalBindingFieldsIndependentlyBound,
              !predecessorObservations.seed42ArtifactAvailabilityEstablished,
              !predecessorObservations.seed42OriginalArtifactRecoverable,
              predecessorObservations
                .seed42RegenerationWouldBeNewExecutionNotRecovery,
              predecessorObservations.seed43ExternalBindingBound,
              predecessorObservations
                .seed43PublicWriteCompletionCountObserved == 1,
              predecessorObservations
                .seed43FreshPublicLoadCompletionCountObserved == 1,
              predecessorObservations.seed43VerifiedArtifactDeleted,
              predecessorObservations.seed43ParentVerifiedLiteralCleanupCompleted,
              !predecessorObservations.seed43ArtifactAvailableBeyondProcess,
              !predecessorObservations.seed43ArtifactRetentionEstablished,
              !predecessorObservations.seed43OriginalArtifactRecoverable,
              predecessorObservations
                .seed43RegenerationWouldBeNewExecutionNotRecovery,
              predecessorObservations
                .cumulativePublicWriteCompletionCountSourceInferredAfterSeed43Success
                == predecessorObservations
                    .seed42PublicWriteCompletionCountSourceInferred
                    + predecessorObservations
                        .seed43PublicWriteCompletionCountObserved,
              predecessorObservations
                .cumulativePublicLoadCompletionCountSourceInferredAfterSeed43Success
                == predecessorObservations
                    .seed42PublicLoadCompletionCountSourceInferred
                    + predecessorObservations
                        .seed43FreshPublicLoadCompletionCountObserved,
              predecessorObservations.usableParentCheckpointCount == 0,
              predecessorObservations
                .neitherObservationSuppliesAvailableResumeParent,
              v2Boundary.schemaVersion == ioAuthority.manifestSchemaVersion,
              v2Boundary.schemaID == ioAuthority.manifestSchemaID,
              v2Boundary.externalBindingSchemaID
                == ioAuthority.externalBindingSchema,
              v2Boundary.artifactKind == ioAuthority.checkpointArtifactKind,
              v2Boundary.totalLogicalParameterByteCount
                == ioAuthority.totalParameterByteCount,
              !v2Boundary.optimizerStateIncluded,
              !v2Boundary.rngStateIncluded,
              !v2Boundary.dataCursorIncluded,
              !v2Boundary.kvCacheStateIncluded,
              v2Boundary.exactExistingV2ByteIdentityMustRemainUnchanged,
              !v2Boundary.wideningOrReinterpretingV2Authorized,
              !v2Boundary.seed43ExternalBindingCanBeUsedAsAvailableParent,
              optimizerStateDesign.firstMomentTensorCount
                == optimizerStateDesign.trainableParameterPathCount,
              optimizerStateDesign.secondMomentTensorCount
                == optimizerStateDesign.trainableParameterPathCount,
              optimizerStateDesign.totalMomentTensorCount
                == optimizerStateDesign.firstMomentTensorCount
                    + optimizerStateDesign.secondMomentTensorCount,
              optimizerStateDesign.totalMomentLogicalByteCount
                == optimizerStateDesign.firstMomentLogicalByteCount
                    + optimizerStateDesign.secondMomentLogicalByteCount,
              optimizerStateDesign.configurationScope
                == "tiny_cpu_mechanics_only_not_native300m_training",
              optimizerStateDesign.currentTypedRestoreRuntimeRevision
                == optimizerStateDesign.rootPinnedMLXRevision,
              optimizerStateDesign.typedRestoreIntroductionRevision
                == "68904d54b72871f26968261ae05d4fbb7c5e3142",
              optimizerStateDesign
                .typedRestoreIntroductionIsAncestorOfCurrentRevision,
              !optimizerStateDesign.biasCorrectionApplied,
              !optimizerStateDesign.optimizerHasInternalStepCounter,
              optimizerStateDesign.explicitGlobalOptimizerStepRequired,
              !optimizerStateDesign.native300MHyperparametersResolved,
              !optimizerStateDesign
                .native300MHyperparameterSelectionAuthorized,
              randomStateDesign.upstreamInnerStateExportAvailable,
              !randomStateDesign
                .dedicatedSupportedTypedExactStateImporterAvailable,
              !randomStateDesign.innerStateArrayContainerIsDirectStateReference,
              randomStateDesign
                .innerStateElementsCanMutateStateViaUnderscoredUpdate,
              randomStateDesign
                .publicUnderscoredMLXArrayUpdateInternalAvailable,
              randomStateDesign
                .underscoredMutationDocumentedAsImplementationDetail,
              !randomStateDesign
                .underscoredMutationAuthorizedForTrajectoryResume,
              !randomStateDesign
                .underscoredMutationReliabilityEstablishedForTrajectoryResume,
              randomStateDesign.primeOwnedExplicitKeyCounterRequired,
              Set(randomStateDesign.requiredDomainIDs).count == 4,
              !randomStateDesign.implicitGlobalRandomStateAuthorized,
              !randomStateDesign.sharedCounterAcrossDomainsAuthorized,
              dataCursorDesign.accumulationPhaseAtSnapshot == 0,
              dataCursorDesign.pendingGradientTensorCountAtSnapshot == 0,
              dataCursorDesign.pendingPrefetchItemCountAtSnapshot == 0,
              dataCursorDesign.kvCacheEntryCountAtSnapshot == 0,
              dataCursorDesign.cursorPointsToNextUnconsumedBatch,
              !dataCursorDesign.arbitraryMidAccumulationSnapshotAuthorized,
              !dataCursorDesign.skipOrDuplicateBatchPermitted,
              trainEvaluateSurfaceDesign.evaluationIsReadOnly,
              !trainEvaluateSurfaceDesign.evaluationUsesTrainingMode,
              !trainEvaluateSurfaceDesign.evaluationUsesKVCache,
              !trainEvaluateSurfaceDesign.surfaceEstablishedByThisAuthority,
              trajectoryCheckpointSchema.leafInventory.map(\.role)
                == PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1
                    .allCases,
              publicationOrdinals == [1, 2, 3, 4],
              trajectoryCheckpointSchema.leafInventory.allSatisfy({ leaf in
                  leaf.required
                      && leaf.immutableNoReplace
                      && leaf.independentlyExternallyBound
                      && !leaf.authoritativeBeforeFinalCommit
              }),
              trajectoryCheckpointSchema.finalCommitManifestPublishedLast,
              trajectoryCheckpointSchema
                .finalCommitManifestIsExclusiveCommitPoint,
              trajectoryCheckpointSchema.artifactRootProvidesPerFileNoReplace,
              !trajectoryCheckpointSchema
                .artifactRootProvidesAtomicMultiFileTransaction,
              !trajectoryCheckpointSchema.partialPrecommitLeavesAreAuthoritative,
              trajectoryCheckpointSchema
                .partialPrecommitLeavesMustBeQuarantined,
              !trajectoryCheckpointSchema.discoverAndTrustLoadAuthorized,
              trajectoryCheckpointSchema
                .loadRequiresExternallySuppliedExactCommitBinding,
              determinismDesign.embeddingLookupVJPUsesScatterAdd,
              determinismDesign
                .repeatedTokenMetalScatterMayUseAtomicAccumulation,
              !determinismDesign.exactMetalGradientBytesEstablished,
              determinismDesign
                .sameDeviceRepeatedUninterruptedAndResumedTrialsRequired,
              determinismDesign
                .exactTensorByteEqualityRequiredForTrajectoryExactClaim,
              !determinismDesign.ulpToleranceEstablishesTrajectoryExactResume,
              resourceDesign.minimumCommittedTensorStateByteCount
                == resourceDesign.weightsLogicalByteCount
                    + resourceDesign.optimizerMomentLogicalByteCount,
              resourceDesign.minimumStatePlusGradientByteCount
                == resourceDesign.minimumCommittedTensorStateByteCount
                    + resourceDesign.gradientLogicalByteCount,
              !resourceDesign.containerHeadersAndManifestsIncludedInMinimum,
              !resourceDesign.seed43RunnerMemoryCapacityRecorded,
              !resourceDesign
                .native300MOneStepTrainingFitsOrdinary45MinuteJobEstablished,
              resourceDesign.separateResourceOnlyProbeRequired,
              !externalDependencySourcesIncludedInRepositoryClosure,
              externalDependencySourceBindings.map(\.path)
                == expectedExternalDependencySourcePaths,
              Set(externalDependencyBindingIdentities).count == 12,
              Set(externalDependencySourceBindings.map(\.claimScope)).count
                == 12,
              externalDependencySourceBindings.map(\.repository) == [
                  "Ergentics/ergentics-mlx-swift",
                  "Ergentics/ergentics-mlx-swift",
                  "Ergentics/ergentics-mlx-swift",
                  "Ergentics/ergentics-mlx-swift",
                  "Ergentics/ergentics-mlx-swift",
                  "Ergentics/ergentics-mlx-swift",
                  "Ergentics/ergentics-mlx-swift",
                  "Ergentics/ergentics-mlx-swift",
                  "ml-explore/mlx-c",
                  "ml-explore/mlx",
                  "ml-explore/mlx",
                  "ml-explore/mlx",
              ],
              externalDependencySourceBindings.map(\.revision) == [
                  "d37885a278f1c37484a94d0f401a418735e66519",
                  "d37885a278f1c37484a94d0f401a418735e66519",
                  "d37885a278f1c37484a94d0f401a418735e66519",
                  "d37885a278f1c37484a94d0f401a418735e66519",
                  "d37885a278f1c37484a94d0f401a418735e66519",
                  "d37885a278f1c37484a94d0f401a418735e66519",
                  "68904d54b72871f26968261ae05d4fbb7c5e3142",
                  "d37885a278f1c37484a94d0f401a418735e66519",
                  "0726ca922fc902c4c61ef9c27d94132be418e945",
                  "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                  "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                  "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
              ],
              externalDependencyBindingsAreExactLowercaseHex,
              externalDependencyRevisionRelationships == [
                  .init(
                      parentRepository: "Ergentics/ergentics-mlx-swift",
                      parentRevision:
                          "d37885a278f1c37484a94d0f401a418735e66519",
                      childPath: "Source/Cmlx/mlx",
                      gitMode: "160000",
                      childRepository: "ml-explore/mlx",
                      childRevision:
                          "ce45c52505c8158ea48d2a54e8caae05efd86bfe"),
                  .init(
                      parentRepository: "Ergentics/ergentics-mlx-swift",
                      parentRevision:
                          "d37885a278f1c37484a94d0f401a418735e66519",
                      childPath: "Source/Cmlx/mlx-c",
                      gitMode: "160000",
                      childRepository: "ml-explore/mlx-c",
                      childRevision:
                          "0726ca922fc902c4c61ef9c27d94132be418e945"),
              ],
              everyExternalDependencyClaimUsedByThisDesignHasExactSourceBinding,
              blockers
                == PrimeNativeDecoderTrajectoryExactResumeBlockerV1.allCases,
              stageValues == exactStages,
              Set(stageValues).count == exactStages.count,
              falseStageCeilings,
              allowedSourceImports == ["Foundation"],
              falseExecutionAndAdmissionCeilings,
              orderedNextActions.count == exactStages.count
        else {
            throw
                PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityError
                    .contractDrift
        }
    }
}
