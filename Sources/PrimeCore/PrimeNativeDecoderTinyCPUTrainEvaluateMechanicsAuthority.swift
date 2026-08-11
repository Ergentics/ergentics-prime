// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderTinyCPUFileIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String
    public let claimScope: String
}

public struct PrimeNativeDecoderTinyCPUExternalSourceIdentityV1:
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

public struct PrimeNativeDecoderTinyCPUExternalGitlinkV1:
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

public struct PrimeNativeDecoderTinyCPURepositoryIdentityV1:
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
    public let historyPreservingTwoParentMerge: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
    public let embeddedSourceIdentitySHA256: String
    public let embeddedIdentityCoversAdmittedPackageSourceTestAndDocumentationClosure:
        Bool
    public let everyPredecessorRepositoryInputUsedByAuthorityIsEmbeddedOrExactlyBound:
        Bool
    public let externalDependenciesExcludedFromEmbeddedIdentity: Bool
    public let currentArcSourceClosureRefreshRequired: Bool
}

public struct PrimeNativeDecoderTinyCPUReviewedMainEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let workflowRunID: Int
    public let workflowRunAttempt: Int
    public let event: String
    public let revision: String
    public let conclusion: String
    public let activeRootJobID: Int
    public let reviewedMainJobID: Int
    public let activeRootJobConclusion: String
    public let reviewedMainJobConclusion: String
    public let reviewedMainTimeoutMinutes: Int
    public let reviewedMainCompletedInsideTimeout: Bool
    public let exactFocusedTestCount: Int
    public let exactFocusedFailureCount: Int
    public let metalTestCount: Int
    public let metalFailureCount: Int
    public let liveSequence: [String]
    public let runtimeReceiptCount: Int
    public let tokenizerReceiptCount: Int
    public let seed42CheckpointCommandCount: Int
    public let seed43CheckpointCommandCount: Int
    public let checkpointReceiptMarkerCount: Int
    public let artifactUploadStepCount: Int
    public let actionsArtifactCount: Int
    public let rerunCount: Int
    public let firstAndOnlyWorkflowAttemptCompletedSuccessfully: Bool
    public let activeRootSealedRawJobLogByteCount: Int
    public let activeRootSealedRawJobLogSHA256: String
    public let reviewedMainSealedRawJobLogByteCount: Int
    public let reviewedMainSealedRawJobLogSHA256: String
}

public struct PrimeNativeDecoderTinyCPUTargetDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let productName: String
    public let targetName: String
    public let productionSourcePath: String
    public let productionSourceExpectedGitMode: String
    public let productionSourceExpectedGitBlob: String
    public let productionSourceExpectedByteCount: Int
    public let productionSourceExpectedSHA256: String
    public let orderedTargetDependencies: [String]
    public let orderedAllowedImports: [String]
    public let exactDependencyAllowlistRequired: Bool
    public let additionalTargetDependencyAuthorized: Bool
    public let currentArcManifestExpectedGitMode: String
    public let currentArcManifestExpectedGitBlob: String
    public let currentArcManifestExpectedByteCount: Int
    public let currentArcManifestExpectedSHA256: String
    public let currentArcLockExpectedGitMode: String
    public let currentArcLockExpectedGitBlob: String
    public let currentArcLockExpectedByteCount: Int
    public let currentArcLockExpectedSHA256: String
    public let packageResolvedOriginHashOnlyRefreshAuthorized: Bool
    public let packageResolvedPinPayloadJSONIdenticalToPredecessor: Bool
    public let packageResolvedPinInventoryChangeAuthorized: Bool
    public let packageResolvedDependencyRevisionChangeAuthorized: Bool
    public let packageResolvedOriginHashMustEqualCurrentManifestSHA256: Bool
    public let checkpointTargetDependencyPresent: Bool
    public let checkpointTargetDependencyAuthorized: Bool
    public let validationPackagePath: String
    public let validationPackageManifestExpectedGitMode: String
    public let validationPackageManifestExpectedGitBlob: String
    public let validationPackageManifestExpectedByteCount: Int
    public let validationPackageManifestExpectedSHA256: String
    public let validationPackageLockPath: String
    public let validationPackageLockExpectedGitMode: String
    public let validationPackageLockExpectedGitBlob: String
    public let validationPackageLockExpectedByteCount: Int
    public let validationPackageLockExpectedSHA256: String
    public let validationPackageLockOriginHashMustEqualManifestSHA256: Bool
    public let validationPackageLockPinPayloadJSONIdenticalToRootLock: Bool
    public let validationOrderedDirectProductDependencies: [String]
    public let validationOrderedLinkedFrameworks: [String]
    public let validationTargetName: String
    public let validationSourcePath: String
    public let validationSourceExpectedGitMode: String
    public let validationSourceExpectedGitBlob: String
    public let validationSourceExpectedByteCount: Int
    public let validationSourceExpectedSHA256: String
    public let validationOrderedImports: [String]
    public let validationSourceIsSoleXCTestSource: Bool
    public let validationSourceContainsExactlyOneTestMethod: Bool
    public let validationTestClass: String
    public let validationTestMethod: String
    public let validationFocusedFilter: String
}

public struct PrimeNativeDecoderTinyCPUSurfaceDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let batchType: String
    public let configurationType: String
    public let trainerType: String
    public let stepResultType: String
    public let evaluationType: String
    public let errorType: String
    public let errorTypeAccess: String
    public let decoderNoCacheSeamSignature: String
    public let decoderNoCacheSeamAccess: String
    public let decoderNoCacheSeamRequiredRank: Int
    public let decoderNoCacheSeamRequiredDType: String
    public let decoderPackageScopedNoCacheSeamAuthorized: Bool
    public let predecessorDecoderIdentityRemainsHistoricalAndFrozen: Bool
    public let currentDecoderSuccessorMutationScope: String
    public let currentDecoderSuccessorExpectedGitMode: String
    public let currentDecoderSuccessorExpectedGitBlob: String
    public let currentDecoderSuccessorExpectedByteCount: Int
    public let currentDecoderSuccessorExpectedSHA256: String
    public let frozenCheckpointRuntimeTokenizerAuthoritiesReinterpreted: Bool
    public let v2CheckpointCompatibilityForDecoderSuccessorReestablished: Bool
    public let checkpointProvenanceForDecoderSuccessorEstablished: Bool
    public let futureDurableStageRequiresNewExactDecoderIdentity: Bool
    public let publicRawMLXDecoderAPIAdded: Bool
    public let kvCacheAcceptedByTrainingSeam: Bool
    public let kvCacheAllocatedByTrainingSeam: Bool
    public let callerSuppliedDecoderConfigurationAccepted: Bool
    public let resultExposesOnlyControlCountsFloat32BitPatternsAndLogicalDigests:
        Bool
    public let rawParameterOrMomentTensorExposureAuthorized: Bool
}

public struct PrimeNativeDecoderTinyCPUFixtureDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let vocabularySize: Int
    public let modelWidth: Int
    public let layerCount: Int
    public let queryHeadCount: Int
    public let keyValueHeadCount: Int
    public let headWidth: Int
    public let intermediateWidth: Int
    public let maximumSequenceLength: Int
    public let initializationSeed: UInt64
    public let uniqueParameterCount: Int
    public let parameterPathCount: Int
    public let firstMomentTensorCount: Int
    public let secondMomentTensorCount: Int
    public let totalMomentTensorCount: Int
    public let parameterLogicalByteCount: Int
    public let optimizerMomentLogicalByteCount: Int
    public let trueGroupedQueryAttention: Bool
    public let tiedTokenEmbeddingAndOutputHead: Bool
    public let independentLMHeadPresent: Bool
    public let layerCountExercisesPathIndexing: Bool
    public let exactOrderedParameterPaths: [String]
}

public struct PrimeNativeDecoderTinyCPUBatchAndLossDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let tokenStorage: String
    public let maskStorage: String
    public let rectangularRank: Int
    public let minimumBatchSize: Int
    public let maximumBatchSize: Int
    public let oversizedBatchTypedRejection: String
    public let oversizedBatchRejectedBeforeSequenceInspectionAndAllocation: Bool
    public let paddingSide: String
    public let paddingTokenID: Int
    public let paddingMustBeContiguousSuffix: Bool
    public let validTokenCountIsAuthoritativeContentBoundary: Bool
    public let paddingTokenIDMayAppearAsContentBeforeValidTokenCount: Bool
    public let onlyPositionsAtOrAfterValidTokenCountMustEqualPaddingTokenID: Bool
    public let completionMaskMustBeFalseAtOrAfterValidTokenCount: Bool
    public let completionMaskAlignment: String
    public let completionMaskMustBeContiguousSuffixBeforePadding: Bool
    public let promptTokensSelectedForLoss: Bool
    public let paddingTokensSelectedForLoss: Bool
    public let causalInputSlice: String
    public let causalTargetSlice: String
    public let selectedLossSlice: String
    public let selectedLabelCountMustBePositive: Bool
    public let lossFunction: String
    public let lossReduction: String
    public let perRowMeanThenRowMeanAuthorized: Bool
    public let labelSmoothingFloat32BitPattern: UInt32
    public let sharedPrefixCausalInvarianceRequired: Bool
    public let validationRejectsEmptyRaggedOutOfRangeAndNoncontiguousInputs: Bool
}

public struct PrimeNativeDecoderTinyCPUGradientClipDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let owner: String
    public let pathEncoding: String
    public let pathOrder: String
    public let accumulationDType: String
    public let gradientDTypeRequired: String
    public let normFormula: String
    public let thresholdFloat32BitPattern: UInt32
    public let epsilonFloat32BitPattern: UInt32
    public let noClipComparison: String
    public let noClipScaleFloat32BitPattern: UInt32
    public let clipScaleFormula: String
    public let thresholdEqualityTakesClipBranch: Bool
    public let oneSharedScaleAppliedToEveryGradient: Bool
    public let gradientPathsMustExactlyEqualParameterPaths: Bool
    public let finiteNonzeroGradientRequiredForEveryFixturePath: Bool
    public let validationMustActivelyTriggerScaleStrictlyBetweenZeroAndOne: Bool
}

public struct PrimeNativeDecoderTinyCPUAdamWDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let implementation: String
    public let learningRateFloat32BitPattern: UInt32
    public let beta1Float32BitPattern: UInt32
    public let beta2Float32BitPattern: UInt32
    public let epsilonFloat32BitPattern: UInt32
    public let weightDecayFloat32BitPattern: UInt32
    public let biasCorrectionApplied: Bool
    public let optimizerHasInternalStepCounter: Bool
    public let optimizerStepOwnedByPrime: Bool
    public let initialOptimizerStep: Int
    public let finalOptimizerStep: Int
    public let updateBoundary: String
    public let momentPathShapeDTypeCompletenessRequiredAfterEveryStep: Bool
    public let missingGradientAuthorized: Bool
    public let native300MHyperparametersEstablished: Bool
}

public struct PrimeNativeDecoderTinyCPUControlExecutionDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let requiredDevice: String
    public let gpuComputeExecutionAuthorized: Bool
    public let metalTensorOperationAuthorized: Bool
    public let independentTrainerCount: Int
    public let updateStepCountPerTrainer: Int
    public let step1TokenRows: [[Int]]
    public let step1ValidTokenCounts: [Int]
    public let step1CompletionMaskRows: [[Bool]]
    public let step2TokenRows: [[Int]]
    public let step2ValidTokenCounts: [Int]
    public let step2CompletionMaskRows: [[Bool]]
    public let evaluationTokenRows: [[Int]]
    public let evaluationValidTokenCounts: [Int]
    public let evaluationCompletionMaskRows: [[Bool]]
    public let evaluationSharedPrefixSelectedLabelCount: Int
    public let trainersExecuteInSameProcess: Bool
    public let trainersUseSameSeedConfigurationAndBatches: Bool
    public let stochasticSamplingAfterFactoryInitialization: Bool
    public let uninterruptedControlOnly: Bool
    public let interruptionOrResumeBoundaryPresent: Bool
    public let evaluationIsReadOnly: Bool
    public let evaluationUsesTrainingMode: Bool
    public let evaluationUsesKVCache: Bool
    public let exactFloat32LossBitEqualityRequired: Bool
    public let exactEvaluationBitEqualityRequired: Bool
    public let exactParameterLogicalDigestEqualityRequired: Bool
    public let exactMomentLogicalDigestEqualityRequired: Bool
    public let exactOptimizerStepEqualityRequired: Bool
    public let thirdStepRejectionIsPreGraphPreMutationAtomic: Bool
    public let generalPostOptimizerUpdateFailureRollbackEstablished: Bool
    public let continuationAfterPostUpdateFailureAuthorized: Bool
    public let failedTrainerMustBeDiscarded: Bool
    public let digestPathOrder: String
    public let tensorLogicalDigestAlgorithmID: String
    public let stateLogicalDigestAlgorithmID: String
    public let expectedParameterPathCount: Int
    public let expectedMomentTensorCount: Int
}

public struct PrimeNativeDecoderTinyCPUHostCapabilityBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let observedLocalEnvironment: String
    public let localMetalDeviceVisible: Bool
    public let pinnedRuntimeMetalSchedulerInitializationRequired: Bool
    public let pinnedSchedulerInitializesGPUStreamBeforeCPUStream: Bool
    public let withoutEarlyGuardNoDeviceFailurePrecedesCPUTrainerInitialization:
        Bool
    public let localCPUTrainerInitializationReached: Bool
    public let localMechanicsExecutionObserved: Bool
    public let testOnlyMetalDeviceDiscoveryAuthorized: Bool
    public let testOnlyCapabilityDiscoveryModules: [String]
    public let testOnlyDiscoveryPerformsTensorComputation: Bool
    public let earlyNilDeviceSkipAuthorizedForLocalCapabilityGuard: Bool
    public let localFocusedTestObservedTestCount: Int
    public let localFocusedTestObservedSkipCount: Int
    public let localFocusedTestObservedFailureCount: Int
    public let localGuardReachedMLXDeviceOrStaticRuntimeInitialization: Bool
    public let localCapabilitySkipCountsAsMechanicsSuccess: Bool
    public let localCapabilitySkipCountsAsExecutionObservation: Bool
    public let metalSchedulerBootstrapAuthorizesMetalTensorExecution: Bool
    public let hostedMacOSRunnerExecutionRequired: Bool
    public let hostedFocusedTestRequiredExecutionCount: Int
    public let hostedFocusedTestRequiredSkipCount: Int
    public let hostedFocusedTestRequiredFailureCount: Int
    public let hostedSuccessfulExecutionObservationPending: Bool
}

public struct PrimeNativeDecoderTinyCPUAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let dependencyManifestMutationForExactTargetAuthorized: Bool
    public let exactStage2ProductionImplementationAuthorized: Bool
    public let exactStage2ValidationImplementationAuthorized: Bool
    public let tinyCPUModelAllocationAuthorized: Bool
    public let tinyCPUDecoderForwardAuthorized: Bool
    public let tinyCPULossEvaluationAuthorized: Bool
    public let tinyCPUBackwardAuthorized: Bool
    public let tinyCPUGradientClipAuthorized: Bool
    public let tinyCPUAdamWStepAuthorized: Bool
    public let exactTwoStepControlExecutionAuthorized: Bool
    public let primeOwnedFilesystemIOAuthorized: Bool
    public let childProcessExecutionAuthorized: Bool
    public let stochasticSamplingAfterFactoryInitializationAuthorized: Bool
    public let explicitRNGDomainImplementationAuthorized: Bool
    public let deterministicDataCursorImplementationAuthorized: Bool
    public let resumeExecutionAuthorized: Bool
    public let checkpointReadAuthorized: Bool
    public let checkpointWriteAuthorized: Bool
    public let checkpointArtifactCreationAuthorized: Bool
    public let artifactRootMutationAuthorized: Bool
    public let artifactUploadAuthorized: Bool
    public let artifactRetentionAuthorized: Bool
    public let checkpointProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let metalTensorExecutionAuthorized: Bool
    public let metalDeterminismEstablished: Bool
    public let native300MAllocationAuthorized: Bool
    public let native300MResourceProbeAuthorized: Bool
    public let native300MTrainingAuthorized: Bool
    public let trajectoryExactResumeEstablished: Bool
    public let trainingResumeEstablished: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Append-only authority for the second exact-resume roadmap stage.
///
/// This value authorizes only a tiny, CPU-only, two-step train/evaluate
/// mechanics implementation and its exact same-process control. It does not
/// authorize or establish RNG/cursor resume, checkpoint I/O, artifact
/// creation, Metal determinism, Native-300M training, quality, admission, or
/// product use. Repository inputs are bound by the embedded identity; pinned
/// dependency source bytes and gitlinks remain external, exact bindings.
public struct PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let predecessorAuthorityID: String
    public let currentStage: String
    public let repositoryIdentity:
        PrimeNativeDecoderTinyCPURepositoryIdentityV1
    public let reviewedMainEvidence:
        PrimeNativeDecoderTinyCPUReviewedMainEvidenceV1
    public let internalSourceBindings:
        [PrimeNativeDecoderTinyCPUFileIdentityV1]
    public let externalSourceBindings:
        [PrimeNativeDecoderTinyCPUExternalSourceIdentityV1]
    public let externalGitlinks:
        [PrimeNativeDecoderTinyCPUExternalGitlinkV1]
    public let everyPredecessorInternalClaimHasExactSourceBinding: Bool
    public let currentArcImplementationSourcesRequireRefreshedEmbeddedClosure:
        Bool
    public let everyExternalClaimHasExactSourceBinding: Bool
    public let targetDesign: PrimeNativeDecoderTinyCPUTargetDesignV1
    public let surfaceDesign: PrimeNativeDecoderTinyCPUSurfaceDesignV1
    public let fixtureDesign: PrimeNativeDecoderTinyCPUFixtureDesignV1
    public let batchAndLossDesign:
        PrimeNativeDecoderTinyCPUBatchAndLossDesignV1
    public let gradientClipDesign:
        PrimeNativeDecoderTinyCPUGradientClipDesignV1
    public let adamWDesign: PrimeNativeDecoderTinyCPUAdamWDesignV1
    public let controlExecutionDesign:
        PrimeNativeDecoderTinyCPUControlExecutionDesignV1
    public let hostCapabilityBoundary:
        PrimeNativeDecoderTinyCPUHostCapabilityBoundaryV1
    public let authorityCeiling:
        PrimeNativeDecoderTinyCPUAuthorityCeilingV1
    public let implementationObservedByThisPreExecutionAuthority: Bool
    public let executionObservedByThisPreExecutionAuthority: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1: Self = {
        let internalSourceBindings = [
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path: "Package.swift",
                gitMode: "100644",
                gitBlob: "f201abbf928e5e3d6b0c7785110539cdaeee911b",
                byteCount: 32_082,
                sha256:
                    "db81e337640b8eb923dbc90b9e22ce898c371ccffe08eed08050e45c34551400",
                claimScope:
                    "predecessor_target_graph_and_exact_pinned_dependency_declaration"),
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path: "Package.resolved",
                gitMode: "100644",
                gitBlob: "dcd0192f705c22378f2d9e871a240c0493ad8a80",
                byteCount: 645,
                sha256:
                    "a18ded75fe953803945898aba0b04a9cec4fca674f38bf914e5fa45dfdb70741",
                claimScope:
                    "exact_mlx_swift_revision_resolution"),
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path:
                    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                gitMode: "100644",
                gitBlob: "835a4826549e1f28ec27e3533f746218beb3bdf2",
                byteCount: 39_050,
                sha256:
                    "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
                claimScope:
                    "generic_decoder_geometry_seeded_factory_tied_head_and_no_cache_forward_predecessor"),
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderTrajectoryExactResumeDesignAuthority.swift",
                gitMode: "100644",
                gitBlob: "20bcbf28ddcfa9a6339510d53e81da02ada9953e",
                byteCount: 77_582,
                sha256:
                    "92194cb171eb1219393008c1dcd3b1c7dfcb2fd9232f4149391dfc428a5e7969",
                claimScope:
                    "completed_stage1_design_predecessor_and_ordered_stage_boundary"),
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path:
                    "Tests/PrimeCoreTests/PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityTests.swift",
                gitMode: "100644",
                gitBlob: "186dc546c7f889f28d700322ac06b7b8a8a4c252",
                byteCount: 26_700,
                sha256:
                    "1fc9d8a4dde9e5e4192de9c248076f218ea38094eb68c335ade6de50862eb58b",
                claimScope:
                    "completed_stage1_pure_canonical_mutation_contract"),
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservation.swift",
                gitMode: "100644",
                gitBlob: "26be0dbd5cec53fd9ea013a1c470106a4fbe4225",
                byteCount: 28_691,
                sha256:
                    "af3ef53cd5da61f68ca7c0aa661dfd57d58679d36c382a1ba0a306bf251197d0",
                claimScope:
                    "reviewed_main_timeout_observation_repaired_by_bound_successful_successor_run"),
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitMode: "100644",
                gitBlob: "e0195b74ed2dc43f32f12b2a4b38e546ce66e84f",
                byteCount: 546,
                sha256:
                    "e4ab836bf1a65e410b4c953bb361756a4400dbde4e4177e3870355462613d504",
                claimScope:
                    "predecessor_canonical_repository_source_closure_digest"),
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "76bfe16e5aa0b41f42aad0458494b5cb4f72fc0d",
                byteCount: 241_594,
                sha256:
                    "9d4b1672e761b26363b8a9ca2816b775899e86d9ecdf6eafa79283d0632fd6ea",
                claimScope:
                    "successful_exact_main_active_root_validation_gate"),
            PrimeNativeDecoderTinyCPUFileIdentityV1(
                path:
                    ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "1cafbc77e46154efaf3dae14dc2c8606e52100d8",
                byteCount: 36_506,
                sha256:
                    "e8daaf8d7816f4e7bb331ad3d6a54f559aebd05e9f1dc72b03313a737dae6147",
                claimScope:
                    "successful_exact_main_sixty_minute_reviewed_job_and_live_sequence"),
        ]

        let mlxRevision =
            "d37885a278f1c37484a94d0f401a418735e66519"
        let mlxRepository = "Ergentics/ergentics-mlx-swift"
        let externalSourceBindings = [
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/Device.swift",
                gitMode: "100644",
                gitBlob: "3a262c55306dab81abecfc36143eda73a0fc4c29",
                byteCount: 5_524,
                sha256:
                    "c357704669f8094bad35f1ea70920f9ce9a058256f776f593dbd81b1bb3e41ce",
                claimScope:
                    "task_local_cpu_default_device_scope"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/Stream.swift",
                gitMode: "100644",
                gitBlob: "c276d6dec11553eafb25988ed552aaf6f6b299a1",
                byteCount: 4_612,
                sha256:
                    "03b4e08befc3bbe926e21b402989b1a1411050bde900dbfac5d3f6b777183f8f",
                claimScope:
                    "swift_stream_cpu_static_initialization_calls_mlx_default_cpu_stream_new_before_cpu_tensor_execution"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/State.swift",
                gitMode: "100644",
                gitBlob: "54bb1b60a5d644fd7255e2ec2acc812fbbe2302d",
                byteCount: 3_409,
                sha256:
                    "0463a11292161fb036a154f0f44755fe93282f82ffc9f1c713b34a428670e44b",
                claimScope:
                    "seeded_factory_random_state_scope_only_not_resume_state"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/Random.swift",
                gitMode: "100644",
                gitBlob: "1f9b32a5caf5ee5291647ec65069588c4c98166a",
                byteCount: 49_475,
                sha256:
                    "482656db6f19d946455427b1a8a47628db69883b130172adc64ec8bed2251934",
                claimScope:
                    "seed7_random_initialization_operations_inside_factory_owned_state_scope"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/MLXArray.swift",
                gitMode: "100644",
                gitBlob: "121955b49b4eefd2f05d117d710990f8ba15f816",
                byteCount: 19_676,
                sha256:
                    "0cd516b95d5d75840978e265d3069709a8f557de96264df8605f246d91b0126c",
                claimScope:
                    "rank_shape_dtype_scalar_materialization_and_logical_bytes"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/Transforms+Eval.swift",
                gitMode: "100644",
                gitBlob: "46fe9c593099c0b939d1d85a68f37023a6dacc24",
                byteCount: 5_256,
                sha256:
                    "14b867c903be78547b426305257ca70e214b7b854acf1c0dc2cf7c82333f4999",
                claimScope:
                    "explicit_lazy_graph_parameter_gradient_moment_and_loss_evaluation"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/Transforms+Grad.swift",
                gitMode: "100644",
                gitBlob: "e8d29e719c2a15f3ad3d57a4c2f6609cc5968f00",
                byteCount: 4_266,
                sha256:
                    "431ce829cdaf421854785c102bc568c9fb2cb6170f6a0bc18d6327bb528fc2ad",
                claimScope:
                    "canonical_value_and_gradient_transform_entry"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/Transforms+Internal.swift",
                gitMode: "100644",
                gitBlob: "394aa4e98eb6c2ab479a9d332e534057ccbead04",
                byteCount: 3_772,
                sha256:
                    "9a6c1630e0468e7207cc92ac86f867d66807753927012bf057dfc511962a9de0",
                claimScope:
                    "nested_parameter_flatten_unflatten_gradient_transform_mechanics"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLX/Nested.swift",
                gitMode: "100644",
                gitBlob: "59c11457be5c934ec6cfc750b1b780106c3b7f23",
                byteCount: 37_630,
                sha256:
                    "29523d272fb85b6c535045fab0444c899acff508c9989dba6eea110e7ec69e22",
                claimScope:
                    "parameter_and_gradient_tree_flattening_and_path_identity"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLXNN/Module.swift",
                gitMode: "100644",
                gitBlob: "75e027bdb39f9692cd1c7b36210b79e2826dfd4c",
                byteCount: 61_198,
                sha256:
                    "bf3dd13a385f91cb808a9f21d5c84c6faac7e68ec922c45ea22ed2728374ae3b",
                claimScope:
                    "trainable_parameter_inventory_and_verified_parameter_update"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLXNN/Linear.swift",
                gitMode: "100644",
                gitBlob: "29bce458d900f7bb70464d9635a5fe33ad6d7c45",
                byteCount: 6_563,
                sha256:
                    "9baee0c013aed7eb7afc0304501e0c569d62bfb4b3d5aa733f9a17c6aa31ed19",
                claimScope:
                    "seeded_projection_initialization_and_exact_weight_shapes"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLXNN/Embedding.swift",
                gitMode: "100644",
                gitBlob: "dbda7607bc4580cf914b2fcd5c0ab6094165359a",
                byteCount: 1_878,
                sha256:
                    "43ed8569fea7af6d5c028992662d6c0cbc256fe6f3cc8342d0b4a3ded4136f12",
                claimScope:
                    "seeded_token_embedding_initialization_and_tied_aslinear_output_head"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLXNN/ValueAndGrad.swift",
                gitMode: "100644",
                gitBlob: "c5c3525cffbc4394972f87f76ee4521e20a6b0d7",
                byteCount: 4_949,
                sha256:
                    "0e1def6f8706a884dd4b9b3676f6bb1891db868c146d6aa19f727ee167856893",
                claimScope:
                    "model_trainable_parameter_value_and_gradient_adapter"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLXNN/Losses.swift",
                gitMode: "100644",
                gitBlob: "218ae25448302a45b75cc9f3c01793a54bccb40c",
                byteCount: 10_825,
                sha256:
                    "fa3202b9658e548ffdc67dea8f3816fe5415b5e16ca42b7b49378436eb7f396e",
                claimScope:
                    "selected_label_cross_entropy_without_label_smoothing"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLXOptimizers/Optimizers.swift",
                gitMode: "100644",
                gitBlob: "fb9c5d9636a211bb74fae7bf6a1dbbd4fe01d7b9",
                byteCount: 24_109,
                sha256:
                    "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d",
                claimScope:
                    "adamw_update_no_bias_correction_and_frozen_hyperparameters"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: mlxRepository,
                revision: mlxRevision,
                path: "Source/MLXOptimizers/AdamOptimizerState.swift",
                gitMode: "100644",
                gitBlob: "f1ba85c50f8f181b06fb48bde066b8e11a5331f3",
                byteCount: 9_717,
                sha256:
                    "175f6325730aa9a658f7aab91b9eb7d6c6d11b375cfa951297db447dfd9ae86d",
                claimScope:
                    "typed_complete_first_and_second_moment_observation_only_no_checkpoint"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path: "mlx/scheduler.h",
                gitMode: "100644",
                gitBlob: "c94044a797b20ae4fc10fec33b6347a278df82e5",
                byteCount: 4_260,
                sha256:
                    "0d24114d7cf813ad3f2cd51aa44a33a5b2669ec879cd144dce1d3cd84dfa922d",
                claimScope:
                    "scheduler_constructs_gpu_default_stream_before_cpu_default_stream_when_gpu_backend_available"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path: "mlx/scheduler.cpp",
                gitMode: "100644",
                gitBlob: "41dda5fd2ed821c4471aa5d9384cd32e64ca86e2",
                byteCount: 2_038,
                sha256:
                    "1c20f8444e5f45f566e37b58056bfd7ad0193fb205b886cb34527fef6035f223",
                claimScope:
                    "core_default_stream_constructs_process_singleton_scheduler"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path: "mlx/backend/metal/device.cpp",
                gitMode: "100644",
                gitBlob: "15824d6c5c8938ab11582f239e6a9598af87c241",
                byteCount: 24_956,
                sha256:
                    "d2000ba53a5f4137c91f0a6222ae86cc3c2c0c3d69dfda2f421f60bd55813a98",
                claimScope:
                    "metal_device_static_loader_resolves_default_device_or_throws_before_cpu_mechanics"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: "ml-explore/mlx-c",
                revision:
                    "0726ca922fc902c4c61ef9c27d94132be418e945",
                path: "mlx/c/stream.cpp",
                gitMode: "100644",
                gitBlob: "2d17997b386fd11ff5f8d66b0b0e007ab439e460",
                byteCount: 2_929,
                sha256:
                    "46e0b11db1e5d9c484406eff357a235339e344dd7724f3bd33dacefdd0a9c4ef",
                claimScope:
                    "swift_stream_cpu_c_bridge_to_core_default_stream_and_scheduler_singleton"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path: "mlx/backend/metal/metal.cpp",
                gitMode: "100644",
                gitBlob: "51bd2e62ff2d44849f55cac58f7b1b118dde5ed4",
                byteCount: 1_407,
                sha256:
                    "15f9a639a2be2d971f0dee00189d0737da208d4facb21e8d41dc74e7633001a8",
                claimScope:
                    "compiled_metal_backend_reports_availability_to_gpu_device_admission"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path: "mlx/backend/metal/device_info.cpp",
                gitMode: "100644",
                gitBlob: "b8f5f0e752271b2ae75833300723c5f26bf3f93f",
                byteCount: 1_621,
                sha256:
                    "90f160d788d670c0bb89db50fb5bc99490499058e218fd00f6915ca3d7c176f5",
                claimScope:
                    "gpu_availability_and_device_count_bridge_admits_scheduler_gpu_default_stream"),
            PrimeNativeDecoderTinyCPUExternalSourceIdentityV1(
                repository: "ml-explore/mlx",
                revision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                path: "mlx/backend/metal/eval.cpp",
                gitMode: "100644",
                gitBlob: "bd58a691a9546d1c5186d74964df1cdf5c703f95",
                byteCount: 2_851,
                sha256:
                    "934ba9a4e6acf729fc554ad5e16cd36b7f933048b7a5dc217da92430981b39b5",
                claimScope:
                    "scheduler_gpu_new_stream_enters_metal_device_loader_and_queue_creation"),
        ]

        let parameterPaths = [
            "final_norm.weight",
            "layers.0.attention.key_projection.weight",
            "layers.0.attention.output_projection.weight",
            "layers.0.attention.query_projection.weight",
            "layers.0.attention.value_projection.weight",
            "layers.0.attention_norm.weight",
            "layers.0.feed_forward.down_projection.weight",
            "layers.0.feed_forward.gate_projection.weight",
            "layers.0.feed_forward.up_projection.weight",
            "layers.0.feed_forward_norm.weight",
            "layers.1.attention.key_projection.weight",
            "layers.1.attention.output_projection.weight",
            "layers.1.attention.query_projection.weight",
            "layers.1.attention.value_projection.weight",
            "layers.1.attention_norm.weight",
            "layers.1.feed_forward.down_projection.weight",
            "layers.1.feed_forward.gate_projection.weight",
            "layers.1.feed_forward.up_projection.weight",
            "layers.1.feed_forward_norm.weight",
            "token_embedding.weight",
        ]

        return Self(
            schemaVersion: 1,
            authorityID:
                "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_authority_v1",
            authorityKind:
                "bounded_stage2_implementation_and_execution_authority",
            predecessorAuthorityID:
                PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1
                    .frozenV1.authorityID,
            currentStage:
                PrimeNativeDecoderTrajectoryExactResumeStageV1
                    .tinyCPUTrainEvaluateMechanics.rawValue,
            repositoryIdentity:
                PrimeNativeDecoderTinyCPURepositoryIdentityV1(
                    repository: "Ergentics/ergentics-prime",
                    ref: "refs/heads/main",
                    revision:
                        "605d47dde85715f356e4d6e11beb3a3262cc4e7e",
                    tree:
                        "72200da83e2ae16f3986c525e3a6cd13b47869c4",
                    orderedParentRevisions: [
                        "5eeba9e6483bafd1bbb5c96753491b3dd1609ea0",
                        "defbefcc49a0dea3cbe723af0015a670323fe0e4",
                    ],
                    pullRequestNumber: 82,
                    reviewedHeadRevision:
                        "defbefcc49a0dea3cbe723af0015a670323fe0e4",
                    reviewedHeadTree:
                        "72200da83e2ae16f3986c525e3a6cd13b47869c4",
                    historyPreservingTwoParentMerge: true,
                    mergeTreeEqualsReviewedHeadTree: true,
                    embeddedSourceIdentitySHA256:
                        "8b207cf27ccab08f95b652f340e23f4a8846942e6027ca2e9536218a418c91d5",
                    embeddedIdentityCoversAdmittedPackageSourceTestAndDocumentationClosure:
                        true,
                    everyPredecessorRepositoryInputUsedByAuthorityIsEmbeddedOrExactlyBound:
                        true,
                    externalDependenciesExcludedFromEmbeddedIdentity: true,
                    currentArcSourceClosureRefreshRequired: true),
            reviewedMainEvidence:
                PrimeNativeDecoderTinyCPUReviewedMainEvidenceV1(
                    workflowRunID: 31_515_766_609,
                    workflowRunAttempt: 1,
                    event: "push",
                    revision:
                        "605d47dde85715f356e4d6e11beb3a3262cc4e7e",
                    conclusion: "success",
                    activeRootJobID: 93_860_388_811,
                    reviewedMainJobID: 93_861_112_336,
                    activeRootJobConclusion: "success",
                    reviewedMainJobConclusion: "success",
                    reviewedMainTimeoutMinutes: 60,
                    reviewedMainCompletedInsideTimeout: true,
                    exactFocusedTestCount: 39,
                    exactFocusedFailureCount: 0,
                    metalTestCount: 44,
                    metalFailureCount: 0,
                    liveSequence: [
                        "metal_44_of_44",
                        "runtime_receipt",
                        "tokenizer_receipt",
                    ],
                    runtimeReceiptCount: 1,
                    tokenizerReceiptCount: 1,
                    seed42CheckpointCommandCount: 0,
                    seed43CheckpointCommandCount: 0,
                    checkpointReceiptMarkerCount: 0,
                    artifactUploadStepCount: 0,
                    actionsArtifactCount: 0,
                    rerunCount: 0,
                    firstAndOnlyWorkflowAttemptCompletedSuccessfully: true,
                    activeRootSealedRawJobLogByteCount: 228_177,
                    activeRootSealedRawJobLogSHA256:
                        "3cd63de60767b4a5bad072a5c444eea4fa167342d28c1e21fc4e26c6577b9e9d",
                    reviewedMainSealedRawJobLogByteCount: 10_232_197,
                    reviewedMainSealedRawJobLogSHA256:
                        "ac682eb0ab4a179f5e621b731d176a73879ce2ceba55ff7a5dc0dd1a19b8b391"),
            internalSourceBindings: internalSourceBindings,
            externalSourceBindings: externalSourceBindings,
            externalGitlinks: [
                PrimeNativeDecoderTinyCPUExternalGitlinkV1(
                    parentRepository: mlxRepository,
                    parentRevision: mlxRevision,
                    childPath: "Source/Cmlx/mlx",
                    gitMode: "160000",
                    childRepository: "ml-explore/mlx",
                    childRevision:
                        "ce45c52505c8158ea48d2a54e8caae05efd86bfe"),
                PrimeNativeDecoderTinyCPUExternalGitlinkV1(
                    parentRepository: mlxRepository,
                    parentRevision: mlxRevision,
                    childPath: "Source/Cmlx/mlx-c",
                    gitMode: "160000",
                    childRepository: "ml-explore/mlx-c",
                    childRevision:
                        "0726ca922fc902c4c61ef9c27d94132be418e945"),
            ],
            everyPredecessorInternalClaimHasExactSourceBinding: true,
            currentArcImplementationSourcesRequireRefreshedEmbeddedClosure:
                true,
            everyExternalClaimHasExactSourceBinding: true,
            targetDesign: PrimeNativeDecoderTinyCPUTargetDesignV1(
                productName: "PrimeNativeDecoderTraining",
                targetName: "PrimeNativeDecoderTraining",
                productionSourcePath:
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                productionSourceExpectedGitMode: "100644",
                productionSourceExpectedGitBlob:
                    "e160cc829f8498abafd100f3f0444742058f0479",
                productionSourceExpectedByteCount: 37_829,
                productionSourceExpectedSHA256:
                    "5e6810a6bd5a9dc0bbe6d6369cec3db6dc84068dc9b415413aafb03f311211dc",
                orderedTargetDependencies: [
                    "PrimeCore",
                    "PrimeNativeDecoder",
                    "MLX",
                    "MLXNN",
                    "MLXOptimizers",
                ],
                orderedAllowedImports: [
                    "Foundation",
                    "PrimeCore",
                    "PrimeNativeDecoder",
                    "MLX",
                    "MLXNN",
                    "MLXOptimizers",
                ],
                exactDependencyAllowlistRequired: true,
                additionalTargetDependencyAuthorized: false,
                currentArcManifestExpectedGitMode: "100644",
                currentArcManifestExpectedGitBlob:
                    "765d3c88139bc1f74af16b77b2f3b06d33f66f75",
                currentArcManifestExpectedByteCount: 32_795,
                currentArcManifestExpectedSHA256:
                    "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2",
                currentArcLockExpectedGitMode: "100644",
                currentArcLockExpectedGitBlob:
                    "14d804bb4291720477240c27e24de6fbdc876b3b",
                currentArcLockExpectedByteCount: 645,
                currentArcLockExpectedSHA256:
                    "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375",
                packageResolvedOriginHashOnlyRefreshAuthorized: true,
                packageResolvedPinPayloadJSONIdenticalToPredecessor: true,
                packageResolvedPinInventoryChangeAuthorized: false,
                packageResolvedDependencyRevisionChangeAuthorized: false,
                packageResolvedOriginHashMustEqualCurrentManifestSHA256: true,
                checkpointTargetDependencyPresent: false,
                checkpointTargetDependencyAuthorized: false,
                validationPackagePath:
                    "Tests/PrimeNativeDecoderTrainingValidation",
                validationPackageManifestExpectedGitMode: "100644",
                validationPackageManifestExpectedGitBlob:
                    "9f05e5a17426f00adf9dad7b55d84057122e98f9",
                validationPackageManifestExpectedByteCount: 1_054,
                validationPackageManifestExpectedSHA256:
                    "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45",
                validationPackageLockPath:
                    "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                validationPackageLockExpectedGitMode: "100644",
                validationPackageLockExpectedGitBlob:
                    "8bf05edf1ea8789e7683e72fe756d79aaaa61320",
                validationPackageLockExpectedByteCount: 645,
                validationPackageLockExpectedSHA256:
                    "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225",
                validationPackageLockOriginHashMustEqualManifestSHA256: true,
                validationPackageLockPinPayloadJSONIdenticalToRootLock: true,
                validationOrderedDirectProductDependencies: [
                    "PrimeNativeDecoderTraining",
                    "MLX",
                ],
                validationOrderedLinkedFrameworks: [
                    "CoreGraphics",
                    "Metal",
                ],
                validationTargetName: "PrimeNativeDecoderTrainingTests",
                validationSourcePath:
                    "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
                validationSourceExpectedGitMode: "100644",
                validationSourceExpectedGitBlob:
                    "61e86200c508526ae2ab66e359d771841f7208db",
                validationSourceExpectedByteCount: 30_214,
                validationSourceExpectedSHA256:
                    "29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96",
                validationOrderedImports: [
                    "CoreGraphics",
                    "Metal",
                    "MLX",
                    "XCTest",
                    "PrimeNativeDecoderTraining",
                ],
                validationSourceIsSoleXCTestSource: true,
                validationSourceContainsExactlyOneTestMethod: true,
                validationTestClass: "PrimeNativeDecoderTrainingTests",
                validationTestMethod:
                    "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                validationFocusedFilter:
                    "PrimeNativeDecoderTrainingTests/testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed"),
            surfaceDesign: PrimeNativeDecoderTinyCPUSurfaceDesignV1(
                batchType:
                    "PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1",
                configurationType:
                    "PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1",
                trainerType:
                    "PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1",
                stepResultType:
                    "PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1",
                evaluationType:
                    "PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1",
                errorType:
                    "PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1",
                errorTypeAccess: "internal",
                decoderNoCacheSeamSignature:
                    "trainingLogitsNoCache(_ rankTwoTokenIDs: MLXArray) -> MLXArray",
                decoderNoCacheSeamAccess: "package",
                decoderNoCacheSeamRequiredRank: 2,
                decoderNoCacheSeamRequiredDType: "int32",
                decoderPackageScopedNoCacheSeamAuthorized: true,
                predecessorDecoderIdentityRemainsHistoricalAndFrozen: true,
                currentDecoderSuccessorMutationScope:
                    "exact_package_only_rank2_int32_no_cache_training_logits_seam_only",
                currentDecoderSuccessorExpectedGitMode: "100644",
                currentDecoderSuccessorExpectedGitBlob:
                    "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f",
                currentDecoderSuccessorExpectedByteCount: 39_598,
                currentDecoderSuccessorExpectedSHA256:
                    "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
                frozenCheckpointRuntimeTokenizerAuthoritiesReinterpreted:
                    false,
                v2CheckpointCompatibilityForDecoderSuccessorReestablished:
                    false,
                checkpointProvenanceForDecoderSuccessorEstablished: false,
                futureDurableStageRequiresNewExactDecoderIdentity: true,
                publicRawMLXDecoderAPIAdded: false,
                kvCacheAcceptedByTrainingSeam: false,
                kvCacheAllocatedByTrainingSeam: false,
                callerSuppliedDecoderConfigurationAccepted: false,
                resultExposesOnlyControlCountsFloat32BitPatternsAndLogicalDigests:
                    true,
                rawParameterOrMomentTensorExposureAuthorized: false),
            fixtureDesign: PrimeNativeDecoderTinyCPUFixtureDesignV1(
                vocabularySize: 32,
                modelWidth: 16,
                layerCount: 2,
                queryHeadCount: 4,
                keyValueHeadCount: 2,
                headWidth: 4,
                intermediateWidth: 32,
                maximumSequenceLength: 16,
                initializationSeed: 7,
                uniqueParameterCount: 5_200,
                parameterPathCount: 20,
                firstMomentTensorCount: 20,
                secondMomentTensorCount: 20,
                totalMomentTensorCount: 40,
                parameterLogicalByteCount: 20_800,
                optimizerMomentLogicalByteCount: 41_600,
                trueGroupedQueryAttention: true,
                tiedTokenEmbeddingAndOutputHead: true,
                independentLMHeadPresent: false,
                layerCountExercisesPathIndexing: true,
                exactOrderedParameterPaths: parameterPaths),
            batchAndLossDesign:
                PrimeNativeDecoderTinyCPUBatchAndLossDesignV1(
                    tokenStorage: "row_major_int32_rank2",
                    maskStorage: "row_major_bool_rank2_token_aligned",
                    rectangularRank: 2,
                    minimumBatchSize: 1,
                    maximumBatchSize: 2,
                    oversizedBatchTypedRejection:
                        "batchTooLarge(observed:maximum:)",
                    oversizedBatchRejectedBeforeSequenceInspectionAndAllocation:
                        true,
                    paddingSide: "right",
                    paddingTokenID: 0,
                    paddingMustBeContiguousSuffix: true,
                    validTokenCountIsAuthoritativeContentBoundary: true,
                    paddingTokenIDMayAppearAsContentBeforeValidTokenCount: true,
                    onlyPositionsAtOrAfterValidTokenCountMustEqualPaddingTokenID:
                        true,
                    completionMaskMustBeFalseAtOrAfterValidTokenCount: true,
                    completionMaskAlignment:
                        "mask_at_token_index_marks_that_token_as_selected_causal_label",
                    completionMaskMustBeContiguousSuffixBeforePadding: true,
                    promptTokensSelectedForLoss: false,
                    paddingTokensSelectedForLoss: false,
                    causalInputSlice: "tokens[:,0..<sequence_length-1]",
                    causalTargetSlice: "tokens[:,1..<sequence_length]",
                    selectedLossSlice:
                        "completion_mask[:,1..<sequence_length]",
                    selectedLabelCountMustBePositive: true,
                    lossFunction:
                        "negative_selected_target_logit_plus_logsumexp_float32",
                    lossReduction:
                        "single_global_sum_over_all_selected_labels_divided_by_global_selected_label_count",
                    perRowMeanThenRowMeanAuthorized: false,
                    labelSmoothingFloat32BitPattern: 0,
                    sharedPrefixCausalInvarianceRequired: true,
                    validationRejectsEmptyRaggedOutOfRangeAndNoncontiguousInputs: true),
            gradientClipDesign:
                PrimeNativeDecoderTinyCPUGradientClipDesignV1(
                    owner: "PrimeNativeDecoderTraining",
                    pathEncoding: "raw_utf8",
                    pathOrder: "ascending_unsigned_utf8_lexicographic",
                    accumulationDType: "float32",
                    gradientDTypeRequired: "float32",
                    normFormula:
                        "sqrt(path_ordered_sum_of_per_tensor_sum_of_squares_float32)",
                    thresholdFloat32BitPattern: 1_065_353_216,
                    epsilonFloat32BitPattern: 897_988_541,
                    noClipComparison: "norm_strictly_less_than_threshold",
                    noClipScaleFloat32BitPattern: 1_065_353_216,
                    clipScaleFormula: "1/(norm+1e-6)",
                    thresholdEqualityTakesClipBranch: true,
                    oneSharedScaleAppliedToEveryGradient: true,
                    gradientPathsMustExactlyEqualParameterPaths: true,
                    finiteNonzeroGradientRequiredForEveryFixturePath: true,
                    validationMustActivelyTriggerScaleStrictlyBetweenZeroAndOne: true),
            adamWDesign: PrimeNativeDecoderTinyCPUAdamWDesignV1(
                implementation: "MLXOptimizers.AdamW",
                learningRateFloat32BitPattern: 953_267_991,
                beta1Float32BitPattern: 1_063_675_494,
                beta2Float32BitPattern: 1_065_336_439,
                epsilonFloat32BitPattern: 841_731_191,
                weightDecayFloat32BitPattern: 1_008_981_770,
                biasCorrectionApplied: false,
                optimizerHasInternalStepCounter: false,
                optimizerStepOwnedByPrime: true,
                initialOptimizerStep: 0,
                finalOptimizerStep: 2,
                updateBoundary:
                    "after_evaluated_loss_gradient_and_clip_at_prime_owned_step_boundary",
                momentPathShapeDTypeCompletenessRequiredAfterEveryStep: true,
                missingGradientAuthorized: false,
                native300MHyperparametersEstablished: false),
            controlExecutionDesign:
                PrimeNativeDecoderTinyCPUControlExecutionDesignV1(
                    requiredDevice: "cpu",
                    gpuComputeExecutionAuthorized: false,
                    metalTensorOperationAuthorized: false,
                    independentTrainerCount: 2,
                    updateStepCountPerTrainer: 2,
                    step1TokenRows: [
                        [1, 1, 1, 2, 3, 0],
                        [4, 5, 6, 7, 8, 9],
                    ],
                    step1ValidTokenCounts: [5, 6],
                    step1CompletionMaskRows: [
                        [false, false, false, true, true, false],
                        [false, false, true, true, true, true],
                    ],
                    step2TokenRows: [
                        [10, 11, 12, 13, 0, 0],
                        [14, 15, 15, 15, 16, 0],
                    ],
                    step2ValidTokenCounts: [4, 5],
                    step2CompletionMaskRows: [
                        [false, true, true, true, false, false],
                        [false, false, false, true, true, false],
                    ],
                    evaluationTokenRows: [
                        [17, 18, 19, 0, 0, 0],
                        [17, 18, 19, 20, 21, 22],
                    ],
                    evaluationValidTokenCounts: [3, 6],
                    evaluationCompletionMaskRows: [
                        [false, true, true, false, false, false],
                        [false, true, true, true, true, true],
                    ],
                    evaluationSharedPrefixSelectedLabelCount: 2,
                    trainersExecuteInSameProcess: true,
                    trainersUseSameSeedConfigurationAndBatches: true,
                    stochasticSamplingAfterFactoryInitialization: false,
                    uninterruptedControlOnly: true,
                    interruptionOrResumeBoundaryPresent: false,
                    evaluationIsReadOnly: true,
                    evaluationUsesTrainingMode: false,
                    evaluationUsesKVCache: false,
                    exactFloat32LossBitEqualityRequired: true,
                    exactEvaluationBitEqualityRequired: true,
                    exactParameterLogicalDigestEqualityRequired: true,
                    exactMomentLogicalDigestEqualityRequired: true,
                    exactOptimizerStepEqualityRequired: true,
                    thirdStepRejectionIsPreGraphPreMutationAtomic: true,
                    generalPostOptimizerUpdateFailureRollbackEstablished: false,
                    continuationAfterPostUpdateFailureAuthorized: false,
                    failedTrainerMustBeDiscarded: true,
                    digestPathOrder:
                        "ascending_unsigned_utf8_lexicographic",
                    tensorLogicalDigestAlgorithmID:
                        "sha256_domain_utf8_path_u32be_rank_u32be_dimensions_u64be_count_f32_bits_u32be_v1",
                    stateLogicalDigestAlgorithmID:
                        "sha256_domain_utf8_role_u32be_tensor_count_then_canonical_tensor_records_v1",
                    expectedParameterPathCount: 20,
                    expectedMomentTensorCount: 40),
            hostCapabilityBoundary:
                PrimeNativeDecoderTinyCPUHostCapabilityBoundaryV1(
                    observedLocalEnvironment:
                        "attached_codex_app_sandbox_2026-08-11",
                    localMetalDeviceVisible: false,
                    pinnedRuntimeMetalSchedulerInitializationRequired: true,
                    pinnedSchedulerInitializesGPUStreamBeforeCPUStream: true,
                    withoutEarlyGuardNoDeviceFailurePrecedesCPUTrainerInitialization:
                        true,
                    localCPUTrainerInitializationReached: false,
                    localMechanicsExecutionObserved: false,
                    testOnlyMetalDeviceDiscoveryAuthorized: true,
                    testOnlyCapabilityDiscoveryModules: [
                        "CoreGraphics",
                        "Metal",
                    ],
                    testOnlyDiscoveryPerformsTensorComputation: false,
                    earlyNilDeviceSkipAuthorizedForLocalCapabilityGuard: true,
                    localFocusedTestObservedTestCount: 1,
                    localFocusedTestObservedSkipCount: 1,
                    localFocusedTestObservedFailureCount: 0,
                    localGuardReachedMLXDeviceOrStaticRuntimeInitialization:
                        false,
                    localCapabilitySkipCountsAsMechanicsSuccess: false,
                    localCapabilitySkipCountsAsExecutionObservation: false,
                    metalSchedulerBootstrapAuthorizesMetalTensorExecution: false,
                    hostedMacOSRunnerExecutionRequired: true,
                    hostedFocusedTestRequiredExecutionCount: 1,
                    hostedFocusedTestRequiredSkipCount: 0,
                    hostedFocusedTestRequiredFailureCount: 0,
                    hostedSuccessfulExecutionObservationPending: true),
            authorityCeiling:
                PrimeNativeDecoderTinyCPUAuthorityCeilingV1(
                    dependencyManifestMutationForExactTargetAuthorized: true,
                    exactStage2ProductionImplementationAuthorized: true,
                    exactStage2ValidationImplementationAuthorized: true,
                    tinyCPUModelAllocationAuthorized: true,
                    tinyCPUDecoderForwardAuthorized: true,
                    tinyCPULossEvaluationAuthorized: true,
                    tinyCPUBackwardAuthorized: true,
                    tinyCPUGradientClipAuthorized: true,
                    tinyCPUAdamWStepAuthorized: true,
                    exactTwoStepControlExecutionAuthorized: true,
                    primeOwnedFilesystemIOAuthorized: false,
                    childProcessExecutionAuthorized: false,
                    stochasticSamplingAfterFactoryInitializationAuthorized:
                        false,
                    explicitRNGDomainImplementationAuthorized: false,
                    deterministicDataCursorImplementationAuthorized: false,
                    resumeExecutionAuthorized: false,
                    checkpointReadAuthorized: false,
                    checkpointWriteAuthorized: false,
                    checkpointArtifactCreationAuthorized: false,
                    artifactRootMutationAuthorized: false,
                    artifactUploadAuthorized: false,
                    artifactRetentionAuthorized: false,
                    checkpointProvenanceEstablished: false,
                    checkpointAdmissionGranted: false,
                    metalTensorExecutionAuthorized: false,
                    metalDeterminismEstablished: false,
                    native300MAllocationAuthorized: false,
                    native300MResourceProbeAuthorized: false,
                    native300MTrainingAuthorized: false,
                    trajectoryExactResumeEstablished: false,
                    trainingResumeEstablished: false,
                    modelQualityEstablished: false,
                    candidateAdmissionGranted: false,
                    trialAuthorized: false,
                    canaryReplacementAuthorized: false,
                    quantizationAuthorized: false,
                    productUseAuthorized: false,
                    publicationAuthorized: false),
            implementationObservedByThisPreExecutionAuthority: true,
            executionObservedByThisPreExecutionAuthority: false,
            status:
                "AUTHORIZED_TINY_CPU_TRAIN_EVALUATE_MECHANICS_ONLY_DOWNSTREAM_ABSTAIN",
            orderedNextActions: [
                "validate_bind_and_publish_already_materialized_exact_stage2_implementation_source_closure",
                "run_one_pure_authority_contract_test",
                "run_local_test_only_metal_capability_guard_without_counting_skip_as_mechanics_success",
                "require_hosted_two_trainer_two_step_cpu_mechanics_execution_exactly_one_test_zero_skips_zero_failures",
                "bind_completed_stage2_source_closure_and_exact_head_then_exact_main_ci",
                "separately_authorize_tiny_cpu_explicit_rng_cursor_resume",
            ])
    }()

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityError
                    .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityError
                    .contractDrift
        }
        do {
            try PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1
                .frozenV1.validateExactV1()
            try PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationV1
                .frozenV1.validateExactV1()
        } catch {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityError
                    .contractDrift
        }

        let exactDependencyOrder = [
            "PrimeCore",
            "PrimeNativeDecoder",
            "MLX",
            "MLXNN",
            "MLXOptimizers",
        ]
        let exactParameterPaths = fixtureDesign.exactOrderedParameterPaths
        let internalIdentities = internalSourceBindings.map { binding in
            "\(binding.gitMode):\(binding.gitBlob):\(binding.path)"
        }
        let externalIdentities = externalSourceBindings.map { binding in
            "\(binding.repository)@\(binding.revision):\(binding.path)"
        }
        let expectedExternalSourcePaths = [
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
        let internalBindingsWellFormed =
            internalSourceBindings.allSatisfy { binding in
                (binding.gitMode == "100644" || binding.gitMode == "100755")
                    && isTinyCPULowercaseHex(binding.gitBlob, count: 40)
                    && binding.byteCount > 0
                    && isTinyCPULowercaseHex(binding.sha256, count: 64)
                    && !binding.path.isEmpty
                    && !binding.claimScope.isEmpty
            }
        let externalBindingsWellFormed =
            externalSourceBindings.allSatisfy { binding in
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
                return binding.gitMode == "100644"
                    && repositoryRevisionIsExact
                    && isTinyCPULowercaseHex(binding.gitBlob, count: 40)
                    && binding.byteCount > 0
                    && isTinyCPULowercaseHex(binding.sha256, count: 64)
                    && !binding.path.isEmpty
                    && !binding.claimScope.isEmpty
            }
        let falseDownstreamCeilings = [
            authorityCeiling.primeOwnedFilesystemIOAuthorized,
            authorityCeiling.childProcessExecutionAuthorized,
            authorityCeiling
                .stochasticSamplingAfterFactoryInitializationAuthorized,
            authorityCeiling.explicitRNGDomainImplementationAuthorized,
            authorityCeiling.deterministicDataCursorImplementationAuthorized,
            authorityCeiling.resumeExecutionAuthorized,
            authorityCeiling.checkpointReadAuthorized,
            authorityCeiling.checkpointWriteAuthorized,
            authorityCeiling.checkpointArtifactCreationAuthorized,
            authorityCeiling.artifactRootMutationAuthorized,
            authorityCeiling.artifactUploadAuthorized,
            authorityCeiling.artifactRetentionAuthorized,
            authorityCeiling.checkpointProvenanceEstablished,
            authorityCeiling.checkpointAdmissionGranted,
            authorityCeiling.metalTensorExecutionAuthorized,
            authorityCeiling.metalDeterminismEstablished,
            authorityCeiling.native300MAllocationAuthorized,
            authorityCeiling.native300MResourceProbeAuthorized,
            authorityCeiling.native300MTrainingAuthorized,
            authorityCeiling.trajectoryExactResumeEstablished,
            authorityCeiling.trainingResumeEstablished,
            authorityCeiling.modelQualityEstablished,
            authorityCeiling.candidateAdmissionGranted,
            authorityCeiling.trialAuthorized,
            authorityCeiling.canaryReplacementAuthorized,
            authorityCeiling.quantizationAuthorized,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
        ].allSatisfy { !$0 }
        let exactStage2Ceilings = [
            authorityCeiling
                .dependencyManifestMutationForExactTargetAuthorized,
            authorityCeiling.exactStage2ProductionImplementationAuthorized,
            authorityCeiling.exactStage2ValidationImplementationAuthorized,
            authorityCeiling.tinyCPUModelAllocationAuthorized,
            authorityCeiling.tinyCPUDecoderForwardAuthorized,
            authorityCeiling.tinyCPULossEvaluationAuthorized,
            authorityCeiling.tinyCPUBackwardAuthorized,
            authorityCeiling.tinyCPUGradientClipAuthorized,
            authorityCeiling.tinyCPUAdamWStepAuthorized,
            authorityCeiling.exactTwoStepControlExecutionAuthorized,
        ].allSatisfy { $0 }

        guard schemaVersion == 1,
              authorityID
                == "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_authority_v1",
              predecessorAuthorityID
                == PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1
                    .frozenV1.authorityID,
              currentStage
                == PrimeNativeDecoderTrajectoryExactResumeStageV1
                    .tinyCPUTrainEvaluateMechanics.rawValue,
              repositoryIdentity.revision
                == "605d47dde85715f356e4d6e11beb3a3262cc4e7e",
              repositoryIdentity.repository == "Ergentics/ergentics-prime",
              repositoryIdentity.ref == "refs/heads/main",
              repositoryIdentity.pullRequestNumber == 82,
              repositoryIdentity.tree
                == "72200da83e2ae16f3986c525e3a6cd13b47869c4",
              repositoryIdentity.orderedParentRevisions == [
                  "5eeba9e6483bafd1bbb5c96753491b3dd1609ea0",
                  "defbefcc49a0dea3cbe723af0015a670323fe0e4",
              ],
              repositoryIdentity.historyPreservingTwoParentMerge,
              repositoryIdentity.mergeTreeEqualsReviewedHeadTree,
              repositoryIdentity.reviewedHeadRevision
                == repositoryIdentity.orderedParentRevisions[1],
              repositoryIdentity.reviewedHeadTree == repositoryIdentity.tree,
              repositoryIdentity.embeddedSourceIdentitySHA256
                == "8b207cf27ccab08f95b652f340e23f4a8846942e6027ca2e9536218a418c91d5",
              repositoryIdentity
                .embeddedIdentityCoversAdmittedPackageSourceTestAndDocumentationClosure,
              repositoryIdentity
                .everyPredecessorRepositoryInputUsedByAuthorityIsEmbeddedOrExactlyBound,
              repositoryIdentity.externalDependenciesExcludedFromEmbeddedIdentity,
              repositoryIdentity.currentArcSourceClosureRefreshRequired,
              reviewedMainEvidence.workflowRunID == 31_515_766_609,
              reviewedMainEvidence.workflowRunAttempt == 1,
              reviewedMainEvidence.event == "push",
              reviewedMainEvidence.revision == repositoryIdentity.revision,
              reviewedMainEvidence.conclusion == "success",
              reviewedMainEvidence.activeRootJobID == 93_860_388_811,
              reviewedMainEvidence.reviewedMainJobID == 93_861_112_336,
              reviewedMainEvidence.activeRootJobConclusion == "success",
              reviewedMainEvidence.reviewedMainJobConclusion == "success",
              reviewedMainEvidence.reviewedMainTimeoutMinutes == 60,
              reviewedMainEvidence.reviewedMainCompletedInsideTimeout,
              reviewedMainEvidence.exactFocusedTestCount == 39,
              reviewedMainEvidence.exactFocusedFailureCount == 0,
              reviewedMainEvidence.metalTestCount == 44,
              reviewedMainEvidence.metalFailureCount == 0,
              reviewedMainEvidence.liveSequence == [
                  "metal_44_of_44",
                  "runtime_receipt",
                  "tokenizer_receipt",
              ],
              reviewedMainEvidence.runtimeReceiptCount == 1,
              reviewedMainEvidence.tokenizerReceiptCount == 1,
              reviewedMainEvidence.seed42CheckpointCommandCount == 0,
              reviewedMainEvidence.seed43CheckpointCommandCount == 0,
              reviewedMainEvidence.checkpointReceiptMarkerCount == 0,
              reviewedMainEvidence.artifactUploadStepCount == 0,
              reviewedMainEvidence.actionsArtifactCount == 0,
              reviewedMainEvidence.rerunCount == 0,
              reviewedMainEvidence
                .firstAndOnlyWorkflowAttemptCompletedSuccessfully,
              reviewedMainEvidence.activeRootSealedRawJobLogByteCount
                == 228_177,
              isTinyCPULowercaseHex(
                  reviewedMainEvidence.activeRootSealedRawJobLogSHA256,
                  count: 64),
              reviewedMainEvidence.reviewedMainSealedRawJobLogByteCount
                == 10_232_197,
              isTinyCPULowercaseHex(
                  reviewedMainEvidence.reviewedMainSealedRawJobLogSHA256,
                  count: 64),
              internalSourceBindings.count == 9,
              externalSourceBindings.count == 23,
              externalSourceBindings.map(\.path)
                == expectedExternalSourcePaths,
              externalGitlinks.count == 2,
              Set(internalIdentities).count == internalSourceBindings.count,
              Set(externalIdentities).count == externalSourceBindings.count,
              Set(internalSourceBindings.map(\.claimScope)).count
                == internalSourceBindings.count,
              Set(externalSourceBindings.map(\.claimScope)).count
                == externalSourceBindings.count,
              internalBindingsWellFormed,
              externalBindingsWellFormed,
              externalGitlinks == [
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
              everyPredecessorInternalClaimHasExactSourceBinding,
              currentArcImplementationSourcesRequireRefreshedEmbeddedClosure,
              everyExternalClaimHasExactSourceBinding,
              targetDesign.productName == targetDesign.targetName,
              targetDesign.targetName == "PrimeNativeDecoderTraining",
              targetDesign.productionSourceExpectedGitMode == "100644",
              targetDesign.productionSourceExpectedGitBlob
                == "e160cc829f8498abafd100f3f0444742058f0479",
              targetDesign.productionSourceExpectedByteCount == 37_829,
              targetDesign.productionSourceExpectedSHA256
                == "5e6810a6bd5a9dc0bbe6d6369cec3db6dc84068dc9b415413aafb03f311211dc",
              targetDesign.orderedTargetDependencies == exactDependencyOrder,
              targetDesign.orderedAllowedImports == [
                  "Foundation",
                  "PrimeCore",
                  "PrimeNativeDecoder",
                  "MLX",
                  "MLXNN",
                  "MLXOptimizers",
              ],
              Set(targetDesign.orderedTargetDependencies).count == 5,
              targetDesign.exactDependencyAllowlistRequired,
              !targetDesign.additionalTargetDependencyAuthorized,
              targetDesign.currentArcManifestExpectedGitMode == "100644",
              targetDesign.currentArcManifestExpectedGitBlob
                == "765d3c88139bc1f74af16b77b2f3b06d33f66f75",
              targetDesign.currentArcManifestExpectedByteCount == 32_795,
              targetDesign.currentArcManifestExpectedSHA256
                == "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2",
              targetDesign.currentArcLockExpectedGitMode == "100644",
              targetDesign.currentArcLockExpectedGitBlob
                == "14d804bb4291720477240c27e24de6fbdc876b3b",
              targetDesign.currentArcLockExpectedByteCount == 645,
              targetDesign.currentArcLockExpectedSHA256
                == "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375",
              targetDesign.packageResolvedOriginHashOnlyRefreshAuthorized,
              targetDesign
                .packageResolvedPinPayloadJSONIdenticalToPredecessor,
              !targetDesign.packageResolvedPinInventoryChangeAuthorized,
              !targetDesign
                .packageResolvedDependencyRevisionChangeAuthorized,
              targetDesign
                .packageResolvedOriginHashMustEqualCurrentManifestSHA256,
              !targetDesign.checkpointTargetDependencyPresent,
              !targetDesign.checkpointTargetDependencyAuthorized,
              targetDesign.validationPackagePath
                == "Tests/PrimeNativeDecoderTrainingValidation",
              targetDesign.validationPackageManifestExpectedGitMode
                == "100644",
              targetDesign.validationPackageManifestExpectedGitBlob
                == "9f05e5a17426f00adf9dad7b55d84057122e98f9",
              targetDesign.validationPackageManifestExpectedByteCount
                == 1_054,
              targetDesign.validationPackageManifestExpectedSHA256
                == "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45",
              targetDesign.validationPackageLockPath
                == "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
              targetDesign.validationPackageLockExpectedGitMode == "100644",
              targetDesign.validationPackageLockExpectedGitBlob
                == "8bf05edf1ea8789e7683e72fe756d79aaaa61320",
              targetDesign.validationPackageLockExpectedByteCount == 645,
              targetDesign.validationPackageLockExpectedSHA256
                == "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225",
              targetDesign
                .validationPackageLockOriginHashMustEqualManifestSHA256,
              targetDesign
                .validationPackageLockPinPayloadJSONIdenticalToRootLock,
              targetDesign.validationOrderedDirectProductDependencies == [
                  "PrimeNativeDecoderTraining",
                  "MLX",
              ],
              targetDesign.validationOrderedLinkedFrameworks == [
                  "CoreGraphics",
                  "Metal",
              ],
              targetDesign.validationTargetName
                == "PrimeNativeDecoderTrainingTests",
              targetDesign.validationSourceExpectedGitMode == "100644",
              targetDesign.validationSourceExpectedGitBlob
                == "61e86200c508526ae2ab66e359d771841f7208db",
              targetDesign.validationSourceExpectedByteCount == 30_214,
              targetDesign.validationSourceExpectedSHA256
                == "29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96",
              targetDesign.validationOrderedImports == [
                  "CoreGraphics",
                  "Metal",
                  "MLX",
                  "XCTest",
                  "PrimeNativeDecoderTraining",
              ],
              targetDesign.validationSourceIsSoleXCTestSource,
              targetDesign.validationSourceContainsExactlyOneTestMethod,
              targetDesign.validationTestMethod
                == "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
              surfaceDesign.batchType
                == "PrimeNativeDecoderTinyCPUTrainEvaluateBatchV1",
              surfaceDesign.configurationType
                == "PrimeNativeDecoderTinyCPUTrainEvaluateConfigurationV1",
              surfaceDesign.trainerType
                == "PrimeNativeDecoderTinyCPUTrainEvaluateTrainerV1",
              surfaceDesign.stepResultType
                == "PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1",
              surfaceDesign.evaluationType
                == "PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1",
              surfaceDesign.errorType
                == "PrimeNativeDecoderTinyCPUTrainEvaluateErrorV1",
              surfaceDesign.errorTypeAccess == "internal",
              surfaceDesign.decoderNoCacheSeamSignature
                == "trainingLogitsNoCache(_ rankTwoTokenIDs: MLXArray) -> MLXArray",
              surfaceDesign.decoderNoCacheSeamAccess == "package",
              surfaceDesign.decoderNoCacheSeamRequiredRank == 2,
              surfaceDesign.decoderNoCacheSeamRequiredDType == "int32",
              surfaceDesign.decoderPackageScopedNoCacheSeamAuthorized,
              surfaceDesign
                .predecessorDecoderIdentityRemainsHistoricalAndFrozen,
              surfaceDesign.currentDecoderSuccessorMutationScope
                == "exact_package_only_rank2_int32_no_cache_training_logits_seam_only",
              surfaceDesign.currentDecoderSuccessorExpectedGitMode == "100644",
              surfaceDesign.currentDecoderSuccessorExpectedGitBlob
                == "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f",
              surfaceDesign.currentDecoderSuccessorExpectedByteCount == 39_598,
              surfaceDesign.currentDecoderSuccessorExpectedSHA256
                == "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
              !surfaceDesign
                .frozenCheckpointRuntimeTokenizerAuthoritiesReinterpreted,
              !surfaceDesign
                .v2CheckpointCompatibilityForDecoderSuccessorReestablished,
              !surfaceDesign
                .checkpointProvenanceForDecoderSuccessorEstablished,
              surfaceDesign.futureDurableStageRequiresNewExactDecoderIdentity,
              !surfaceDesign.publicRawMLXDecoderAPIAdded,
              !surfaceDesign.kvCacheAcceptedByTrainingSeam,
              !surfaceDesign.kvCacheAllocatedByTrainingSeam,
              !surfaceDesign.callerSuppliedDecoderConfigurationAccepted,
              surfaceDesign
                .resultExposesOnlyControlCountsFloat32BitPatternsAndLogicalDigests,
              !surfaceDesign.rawParameterOrMomentTensorExposureAuthorized,
              fixtureDesign.vocabularySize == 32,
              fixtureDesign.modelWidth == 16,
              fixtureDesign.layerCount == 2,
              fixtureDesign.queryHeadCount == 4,
              fixtureDesign.keyValueHeadCount == 2,
              fixtureDesign.headWidth == 4,
              fixtureDesign.intermediateWidth == 32,
              fixtureDesign.maximumSequenceLength == 16,
              fixtureDesign.initializationSeed == 7,
              fixtureDesign.uniqueParameterCount == 5_200,
              fixtureDesign.parameterPathCount == 20,
              fixtureDesign.totalMomentTensorCount == 40,
              fixtureDesign.parameterLogicalByteCount
                == fixtureDesign.uniqueParameterCount * 4,
              fixtureDesign.optimizerMomentLogicalByteCount
                == fixtureDesign.parameterLogicalByteCount * 2,
              Set(exactParameterPaths).count == 20,
              exactParameterPaths == exactParameterPaths.sorted(by: {
                  Array($0.utf8).lexicographicallyPrecedes(Array($1.utf8))
              }),
              fixtureDesign.trueGroupedQueryAttention,
              fixtureDesign.tiedTokenEmbeddingAndOutputHead,
              !fixtureDesign.independentLMHeadPresent,
              batchAndLossDesign.rectangularRank == 2,
              batchAndLossDesign.minimumBatchSize == 1,
              batchAndLossDesign.maximumBatchSize == 2,
              batchAndLossDesign.oversizedBatchTypedRejection
                == "batchTooLarge(observed:maximum:)",
              batchAndLossDesign
                .oversizedBatchRejectedBeforeSequenceInspectionAndAllocation,
              batchAndLossDesign.paddingSide == "right",
              batchAndLossDesign.paddingMustBeContiguousSuffix,
              batchAndLossDesign.validTokenCountIsAuthoritativeContentBoundary,
              batchAndLossDesign
                .paddingTokenIDMayAppearAsContentBeforeValidTokenCount,
              batchAndLossDesign
                .onlyPositionsAtOrAfterValidTokenCountMustEqualPaddingTokenID,
              batchAndLossDesign
                .completionMaskMustBeFalseAtOrAfterValidTokenCount,
              batchAndLossDesign
                .completionMaskMustBeContiguousSuffixBeforePadding,
              !batchAndLossDesign.promptTokensSelectedForLoss,
              !batchAndLossDesign.paddingTokensSelectedForLoss,
              batchAndLossDesign.selectedLabelCountMustBePositive,
              !batchAndLossDesign.perRowMeanThenRowMeanAuthorized,
              batchAndLossDesign.labelSmoothingFloat32BitPattern == 0,
              batchAndLossDesign.sharedPrefixCausalInvarianceRequired,
              gradientClipDesign.pathEncoding == "raw_utf8",
              gradientClipDesign.accumulationDType == "float32",
              gradientClipDesign.thresholdFloat32BitPattern
                == Float(1).bitPattern,
              gradientClipDesign.epsilonFloat32BitPattern
                == Float(1e-6).bitPattern,
              gradientClipDesign.noClipScaleFloat32BitPattern
                == Float(1).bitPattern,
              gradientClipDesign.noClipComparison
                == "norm_strictly_less_than_threshold",
              gradientClipDesign.clipScaleFormula == "1/(norm+1e-6)",
              gradientClipDesign.thresholdEqualityTakesClipBranch,
              gradientClipDesign.oneSharedScaleAppliedToEveryGradient,
              gradientClipDesign.gradientPathsMustExactlyEqualParameterPaths,
              gradientClipDesign
                .finiteNonzeroGradientRequiredForEveryFixturePath,
              gradientClipDesign
                .validationMustActivelyTriggerScaleStrictlyBetweenZeroAndOne,
              adamWDesign.learningRateFloat32BitPattern
                == Float(1e-4).bitPattern,
              adamWDesign.beta1Float32BitPattern == Float(0.9).bitPattern,
              adamWDesign.beta2Float32BitPattern == Float(0.999).bitPattern,
              adamWDesign.epsilonFloat32BitPattern
                == Float(1e-8).bitPattern,
              adamWDesign.weightDecayFloat32BitPattern
                == Float(0.01).bitPattern,
              !adamWDesign.biasCorrectionApplied,
              !adamWDesign.optimizerHasInternalStepCounter,
              adamWDesign.optimizerStepOwnedByPrime,
              adamWDesign.initialOptimizerStep == 0,
              adamWDesign.finalOptimizerStep == 2,
              !adamWDesign.missingGradientAuthorized,
              !adamWDesign.native300MHyperparametersEstablished,
              controlExecutionDesign.requiredDevice == "cpu",
              !controlExecutionDesign.gpuComputeExecutionAuthorized,
              !controlExecutionDesign.metalTensorOperationAuthorized,
              controlExecutionDesign.independentTrainerCount == 2,
              controlExecutionDesign.updateStepCountPerTrainer == 2,
              controlExecutionDesign.step1TokenRows == [
                  [1, 1, 1, 2, 3, 0],
                  [4, 5, 6, 7, 8, 9],
              ],
              controlExecutionDesign.step1ValidTokenCounts == [5, 6],
              controlExecutionDesign.step1CompletionMaskRows == [
                  [false, false, false, true, true, false],
                  [false, false, true, true, true, true],
              ],
              controlExecutionDesign.step2TokenRows == [
                  [10, 11, 12, 13, 0, 0],
                  [14, 15, 15, 15, 16, 0],
              ],
              controlExecutionDesign.step2ValidTokenCounts == [4, 5],
              controlExecutionDesign.step2CompletionMaskRows == [
                  [false, true, true, true, false, false],
                  [false, false, false, true, true, false],
              ],
              controlExecutionDesign.evaluationTokenRows == [
                  [17, 18, 19, 0, 0, 0],
                  [17, 18, 19, 20, 21, 22],
              ],
              controlExecutionDesign.evaluationValidTokenCounts == [3, 6],
              controlExecutionDesign.evaluationCompletionMaskRows == [
                  [false, true, true, false, false, false],
                  [false, true, true, true, true, true],
              ],
              controlExecutionDesign
                .evaluationSharedPrefixSelectedLabelCount == 2,
              controlExecutionDesign.trainersExecuteInSameProcess,
              controlExecutionDesign.trainersUseSameSeedConfigurationAndBatches,
              !controlExecutionDesign
                .stochasticSamplingAfterFactoryInitialization,
              controlExecutionDesign.uninterruptedControlOnly,
              !controlExecutionDesign.interruptionOrResumeBoundaryPresent,
              controlExecutionDesign.evaluationIsReadOnly,
              !controlExecutionDesign.evaluationUsesTrainingMode,
              !controlExecutionDesign.evaluationUsesKVCache,
              controlExecutionDesign
                .thirdStepRejectionIsPreGraphPreMutationAtomic,
              !controlExecutionDesign
                .generalPostOptimizerUpdateFailureRollbackEstablished,
              !controlExecutionDesign
                .continuationAfterPostUpdateFailureAuthorized,
              controlExecutionDesign.failedTrainerMustBeDiscarded,
              controlExecutionDesign.tensorLogicalDigestAlgorithmID
                == "sha256_domain_utf8_path_u32be_rank_u32be_dimensions_u64be_count_f32_bits_u32be_v1",
              controlExecutionDesign.stateLogicalDigestAlgorithmID
                == "sha256_domain_utf8_role_u32be_tensor_count_then_canonical_tensor_records_v1",
              controlExecutionDesign.expectedParameterPathCount == 20,
              controlExecutionDesign.expectedMomentTensorCount == 40,
              hostCapabilityBoundary.observedLocalEnvironment
                == "attached_codex_app_sandbox_2026-08-11",
              !hostCapabilityBoundary.localMetalDeviceVisible,
              hostCapabilityBoundary
                .pinnedRuntimeMetalSchedulerInitializationRequired,
              hostCapabilityBoundary
                .pinnedSchedulerInitializesGPUStreamBeforeCPUStream,
              hostCapabilityBoundary
                .withoutEarlyGuardNoDeviceFailurePrecedesCPUTrainerInitialization,
              !hostCapabilityBoundary.localCPUTrainerInitializationReached,
              !hostCapabilityBoundary.localMechanicsExecutionObserved,
              hostCapabilityBoundary.testOnlyMetalDeviceDiscoveryAuthorized,
              hostCapabilityBoundary.testOnlyCapabilityDiscoveryModules == [
                  "CoreGraphics",
                  "Metal",
              ],
              !hostCapabilityBoundary
                .testOnlyDiscoveryPerformsTensorComputation,
              hostCapabilityBoundary
                .earlyNilDeviceSkipAuthorizedForLocalCapabilityGuard,
              hostCapabilityBoundary.localFocusedTestObservedTestCount == 1,
              hostCapabilityBoundary.localFocusedTestObservedSkipCount == 1,
              hostCapabilityBoundary.localFocusedTestObservedFailureCount
                == 0,
              !hostCapabilityBoundary
                .localGuardReachedMLXDeviceOrStaticRuntimeInitialization,
              !hostCapabilityBoundary
                .localCapabilitySkipCountsAsMechanicsSuccess,
              !hostCapabilityBoundary
                .localCapabilitySkipCountsAsExecutionObservation,
              !hostCapabilityBoundary
                .metalSchedulerBootstrapAuthorizesMetalTensorExecution,
              hostCapabilityBoundary.hostedMacOSRunnerExecutionRequired,
              hostCapabilityBoundary.hostedFocusedTestRequiredExecutionCount
                == 1,
              hostCapabilityBoundary.hostedFocusedTestRequiredSkipCount == 0,
              hostCapabilityBoundary.hostedFocusedTestRequiredFailureCount
                == 0,
              hostCapabilityBoundary
                .hostedSuccessfulExecutionObservationPending,
              exactStage2Ceilings,
              falseDownstreamCeilings,
              implementationObservedByThisPreExecutionAuthority,
              !executionObservedByThisPreExecutionAuthority,
              orderedNextActions.first
                == "validate_bind_and_publish_already_materialized_exact_stage2_implementation_source_closure",
              orderedNextActions.count == 6
        else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityError
                    .contractDrift
        }
    }
}

private func isTinyCPULowercaseHex(
    _ value: String,
    count: Int
) -> Bool {
    value.utf8.count == count
        && value.utf8.allSatisfy { byte in
            (byte >= 48 && byte <= 57) || (byte >= 97 && byte <= 102)
        }
}
