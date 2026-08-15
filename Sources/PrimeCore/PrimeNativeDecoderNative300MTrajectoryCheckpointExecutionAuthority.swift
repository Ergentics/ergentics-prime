// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityError:
    Error, Equatable, Sendable
{
    case contractDrift(String)
    case noncanonicalEncoding
}

/// Append-only, dependency-free, nonexecuting authority for roadmap Stage 7.
///
/// This declaration binds the completed B-path determinism and resource
/// prerequisites and freezes one separately reviewed exact-main mechanics
/// opportunity. It imports no MLX module, performs no process or filesystem
/// operation, allocates no model, and reads or writes no checkpoint.
public struct PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1:
    Codable, Equatable, Sendable
{
    public struct SourceIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct RepositoryIdentity: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let revision: String
        public let tree: String
        public let orderedParentRevisions: [String]
        public let pullRequestNumber: Int
        public let historyPreservingTwoParentMerge: Bool
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let exactMainRequired: Bool
    }

    public struct RoadmapBinding: Codable, Equatable, Sendable {
        public let authorityID: String
        public let canonicalSHA256: String
        public let source: SourceIdentity
        public let test: SourceIdentity
        public let orderedStageIDs: [String]
        public let stageOrdinal: Int
        public let stageID: String
        public let objective: String
        public let requiredPredecessorStageID: String
        public let successorStageID: String
        public let separatelyAuthorizedSuccessorRequired: Bool
    }

    public struct PredecessorObservationBinding:
        Codable, Equatable, Sendable
    {
        public let observationID: String
        public let canonicalSHA256: String
        public let source: SourceIdentity
        public let test: SourceIdentity
        public let mechanicsRevision: String
        public let mechanicsTree: String
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let status: String
        public let oneShotConsumed: Bool
        public let oneShotExhausted: Bool
    }

    public struct EstablishedPrerequisites: Codable, Equatable, Sendable {
        public let stage5MechanicsSuccessEstablished: Bool
        public let stage5ResultEstablished: Bool
        public let stage5AssayClearanceEstablished: Bool
        public let repeatedSameDeviceBPathDeterminismEstablished: Bool
        public let exactSameDeviceBPathGradientBytesEstablished: Bool
        public let bSpecificNative300MResourceWitnessEstablished: Bool
        public let bSpecificNative300MResourceClearanceEstablished: Bool
        public let bSpecificNative300MRunnerCapacityEstablished: Bool
        public let historicalStage6ResourceClearanceRemainsEstablished: Bool
        public let historicalStage6ResourceClearanceAppliesToBPath: Bool
        public let defaultGatherDeterminismEstablished: Bool
        public let arbitraryTokenDeterminismEstablished: Bool
        public let crossDeviceDeterminismEstablished: Bool
    }

    public struct RetirementClosureIdentity: Codable, Equatable, Sendable {
        public let frozenObservationRetirementObserved: Bool
        public let laterRetirementClosureObserved: Bool
        public let repository: RepositoryIdentity
        public let workflowID: Int
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let activeRootJobID: Int
        public let activeRootJobConclusion: String
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let exactChangedPaths: [SourceIdentity]
        public let rootTestCount: Int
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let totalTestCount: Int
        public let artifactCount: Int
        public let retryCount: Int
        public let rerunCount: Int
        public let retiredLauncherAndReceiptCountsAreZero: Bool
        public let embeddedSourceIdentitySHA256: String
        public let embeddedSourceIdentityRecordCount: Int
        public let preservedIndexSHA256: String
    }

    public struct BPathPolicy: Codable, Equatable, Sendable {
        public let algorithmID: String
        public let selectorCase: String
        public let selectorRawValue: String
        public let decoderAPI: String
        public let packageOnlySurfaceRequired: Bool
        public let publicDecoderAPIAdded: Bool
        public let maintainedInferencePathUnchanged: Bool
        public let vocabularySize: Int
        public let modelWidth: Int
        public let layerCount: Int
        public let queryHeadCount: Int
        public let keyValueHeadCount: Int
        public let headWidth: Int
        public let intermediateWidth: Int
        public let maximumSequenceLength: Int
        public let parameterPathCount: Int
        public let uniqueParameterCount: UInt64
        public let parameterDType: String
        public let logicalParameterByteCount: UInt64
        public let initialModelSeed: UInt64
        public let batchSize: Int
        public let sequenceLength: Int
        public let selectedTargetCount: Int
        public let exactFixedBatchCount: Int
        public let batchAlgorithmIDs: [String]
        public let batchGenerationRules: [String]
        public let batchTokenIDsSHA256: [String]
        public let completionMaskGenerationRule: String
        public let completionMaskSHA256: String
        public let batchTokenAndMaskSHA256: [String]
        public let batchDigestPreimageRule: String
        public let evaluationBatchOrdinal: Int
        public let evaluationBatchTokenAndMaskSHA256: String
        public let evaluationConsumesDataCursor: Bool
        public let evaluationDecoderAPI: String
        public let evaluationTemporarilySetsTrainingModeFalse: Bool
        public let evaluationRestoresPriorTrainingMode: Bool
        public let evaluationUsesKVCache: Bool
        public let evaluationChecksFullModelOptimizerAndControlNonmutation:
            Bool
        public let predecessorConfigurationWasTrainingPolicy: Bool
        public let explicitlyReauthorizedForThisStage7Opportunity: Bool
        public let repeatedBatchConsumptionWithinSingleBranchAuthorized: Bool
        public let sameSuccessorBatchAcrossAlternateBranchesRequired: Bool
        public let evaluationInputReuseWithoutCursorConsumptionAuthorized:
            Bool
        public let paddingAuthorized: Bool
        public let kvCacheAuthorized: Bool
    }

    public struct TrainingMathPolicy: Codable, Equatable, Sendable {
        public let compatibilitySchemaID: String
        public let modelConfigurationFactory: String
        public let modelFactory: String
        public let ropeThetaFloat32BitPattern: UInt32
        public let rmsNormEpsilonFloat32BitPattern: UInt32
        public let shiftedLogitsSlice: String
        public let shiftedTargetsSlice: String
        public let shiftedCompletionMaskSlice: String
        public let shiftedLogitsShape: [Int]
        public let shiftedTargetsShape: [Int]
        public let shiftedCompletionMaskShape: [Int]
        public let crossEntropyAPI: String
        public let crossEntropyWeights: String
        public let crossEntropyAxis: Int
        public let crossEntropyLabelSmoothingFloat32BitPattern: UInt32
        public let crossEntropyReduction: String
        public let maskedMeanFormula: String
        public let selectedTargetDivisor: Int
        public let exactLossBitsAndPerTargetOutputsCaptured: Bool
        public let perTargetLossEvidenceShape: [Int]
        public let perTargetLossEvidenceDType: String
        public let perTargetLossEvidenceElementCount: Int
        public let wholeLogitsEvidenceRule: String
        public let wholeLogitsEvidenceShape: [Int]
        public let wholeLogitsEvidenceDType: String
        public let wholeLogitsEvidenceElementCount: Int
        public let wholeLogitsEvidenceLogicalByteCount: Int
        public let valueAndGradAPI: String
        public let valueAndGradClosureReturnsOnlyScalarLoss: Bool
        public let rawGradientNormAlgorithmID: String
        public let rawGradientNormFormula: String
        public let gradientClipAlgorithmID: String
        public let gradientClipScaleFormula: String
        public let adamWUsesBiasCorrection: Bool
        public let adamWUpdateOrdering: String
        public let exactPolicyPromotedOnlyForThisStage7Opportunity: Bool
    }

    public struct ImmutableImplementationPolicy:
        Codable, Equatable, Sendable
    {
        public let predecessorRevision: String
        public let predecessorTree: String
        public let exactBaseSources: [SourceIdentity]
        public let exactBaseSourceCount: Int
        public let validationPackageManifestIsControlledSuccessorMutation: Bool
        public let rootPackageManifestMustRemainByteIdentical: Bool
        public let rootAndValidationLocksMustRemainByteIdentical: Bool
        public let allProductionImplementationSourcesMustRemainByteIdentical:
            Bool
        public let exactMLXRevision: String
        public let requiredRuntimePrimitiveAPIs: [String]
        public let receiptCarriesExactImplementationInventory: Bool
        public let implementationDriftBeforeExecutionFailsClosed: Bool
    }

    public struct OptimizerAndControlPolicy:
        Codable, Equatable, Sendable
    {
        public let implementation: String
        public let typedStateType: String
        public let typedMappingOwnedByTraining: Bool
        public let checkpointCodecUsesNeutralMomentCatalog: Bool
        public let learningRateFloat32BitPattern: UInt32
        public let beta1Float32BitPattern: UInt32
        public let beta2Float32BitPattern: UInt32
        public let epsilonFloat32BitPattern: UInt32
        public let weightDecayFloat32BitPattern: UInt32
        public let maximumGradientNormFloat32BitPattern: UInt32
        public let gradientNormEpsilonFloat32BitPattern: UInt32
        public let gradientAccumulationCount: Int
        public let initialGlobalStep: Int
        public let snapshotGlobalStep: Int
        public let terminalGlobalStep: Int
        public let exactScheduleIdentityRequired: Bool
        public let scheduleID: String
        public let learningRateFloat32BitPatternsAtStepsZeroOneTwo: [UInt32]
        public let optimizerHasInternalStepCounter: Bool
        public let callerOwnsGlobalStep: Bool
        public let mutableRuntimeLearningRateStateRequired: Bool
        public let updateTimeLearningRateReadOrdering: String
        public let exactCurrentLearningRateBitsRequired: Bool
        public let explicitRNGRequired: Bool
        public let rngDomainIDs: [String]
        public let exactRNGAlgorithmKeyCounterAndConsumptionDigestRequired:
            Bool
        public let cursorPointsToNextUnconsumedBatchAtSnapshot: Bool
        public let snapshotNextBatchOrdinal: Int
        public let accumulationPhaseAtSnapshot: Int
        public let pendingGradientCountAtSnapshot: Int
        public let pendingPrefetchCountAtSnapshot: Int
        public let kvCacheEntryCountAtSnapshot: Int
    }

    public struct RNGDomainPolicy: Codable, Equatable, Sendable {
        public let domainID: String
        public let keySHA256: String
        public let snapshotCounter: UInt64
        public let snapshotConsumptionSHA256: String
        public let terminalCounter: UInt64
        public let terminalConsumptionSHA256: String
    }

    public struct ExplicitRNGPolicy: Codable, Equatable, Sendable {
        public let algorithmID: String
        public let keyDerivationPreimageRule: String
        public let outputPreimageRule: String
        public let consumptionPreimageRule: String
        public let rootSeed: UInt64
        public let domains: [RNGDomainPolicy]
        public let domainKeysPairwiseDistinct: Bool
        public let countersIndependent: Bool
        public let implicitGlobalRandomStateAuthorized: Bool
        public let evaluationConsumesRNG: Bool
        public let augmentationConsumesRNG: Bool
    }

    public struct DataCursorPolicy: Codable, Equatable, Sendable {
        public let schemaID: String
        public let corpusBinding: String
        public let tokenizerBinding: String
        public let exampleGeneratorBinding: String
        public let sourceInventoryBinding: String
        public let splitIdentity: String
        public let curriculumIdentity: String
        public let epochAtSnapshot: Int
        public let permutationAlgorithm: String
        public let permutationDomain: String
        public let permutationKeySHA256: String
        public let permutationSHA256: String
        public let permutationSHA256PreimageRule: String
        public let nextRowIndexAtSnapshot: Int
        public let nextRowIDsAtSnapshot: [String]
        public let nextRowIDsSHA256: String
        public let nextRowIDsSHA256PreimageRule: String
        public let terminalEpoch: Int
        public let terminalNextBatchOrdinal: Int
        public let terminalNextRowIndex: Int
        public let terminalNextRowIDs: [String]
        public let terminalNextRowIDsSHA256: String
        public let terminalNoNextBatchIdentity: String
        public let terminalNoNextBatchSHA256: String
        public let terminalNoNextBatchSHA256PreimageRule: String
        public let evaluationCheckedAtSnapshotCurrentStep: Bool
        public let evaluationCheckedAtEachTerminalCurrentStep: Bool
        public let batchSize: Int
        public let microbatchSize: Int
        public let sequenceLength: Int
        public let paddingPolicy: String
        public let dropLastPolicy: String
        public let causalMaskPolicy: String
        public let nextBatchTokenAndMaskSHA256: String
        public let cursorAdvanceCountPerTrainingStep: Int
        public let evaluationAdvancesCursor: Bool
    }

    public struct TrajectoryExecutionPolicy: Codable, Equatable, Sendable {
        public let baselineStepCount: Int
        public let uninterruptedSuccessorStepCount: Int
        public let restoredSuccessorStepCount: Int
        public let totalTrainingStepCount: Int
        public let totalBackwardCount: Int
        public let totalOptimizerUpdateCount: Int
        public let snapshotCount: Int
        public let freshRestoreCount: Int
        public let checkedReadOnlyEvaluationCount: Int
        public let snapshotBoundary: String
        public let exactOrderedPhases: [String]
        public let uninterruptedAndRestoredFullStatesMayOverlap: Bool
        public let baselineGradientsReleasedBeforeV2AndMomentPublication: Bool
        public let uninterruptedGradientEvidenceCapturedBeforeRelease: Bool
        public let uninterruptedGradientsReleasedBeforeComparatorPublication:
            Bool
        public let restoredGradientEvidenceCapturedBeforeRelease: Bool
        public let restoredGradientsReleasedBeforeComparatorPublication: Bool
        public let restoredDecoderTrainingModeTrueBeforeSuccessor: Bool
        public let decoderTrainingModeTrueAfterEveryEvaluationRestore: Bool
        public let resumedStateDeallocatedBeforeStreamingComparison: Bool
        public let cacheClearedAfterResumedComparatorPublication: Bool
        public let uninterruptedStateDeallocatedBeforeRestore: Bool
        public let cacheClearedBeforeRestore: Bool
        public let v2WriterTransientFreshVerificationModelAccountedFor: Bool
        public let optimizerMomentSemanticReloadDeferredUntilAfterDeallocation:
            Bool
        public let eagerSecondMomentMaterializationDuringPublicationAuthorized:
            Bool
        public let exactSameDeviceOnly: Bool
        public let authoritativeBaselineFourLeafSetRole: String
        public let privateComparatorFourLeafSetRoles: [String]
    }

    public struct OperationCounts: Codable, Equatable, Sendable {
        public let trainingStepCount: Int
        public let backwardCount: Int
        public let optimizerUpdateCount: Int
        public let denseBPathLogitsCallCount: Int
        public let tokenBoundsValidationCount: Int
        public let tokenBoundsCheckedEvalCount: Int
        public let tokenBoundsGPUSynchronizeCount: Int
        public let tokenBoundsHostBoolItemCount: Int
        public let denseOneHotMatmulConstructionCount: Int
        public let gradientEvidenceCaptureCount: Int
        public let gradientCatalogReleaseCount: Int
        public let resourceMeasurementCheckedEvalCount: Int
        public let resourceMeasurementSynchronizeCount: Int
        public let checkedReadOnlyEvaluationCount: Int
        public let evaluationForwardPassCount: Int
        public let forwardLossCount: Int
        public let crossEntropyCount: Int
        public let trainingModeDisableCount: Int
        public let trainingModeRestoreCount: Int
        public let v2WeightsWriteCount: Int
        public let v2InternalVerificationLoadCount: Int
        public let publicRestoreLoadCount: Int
        public let optimizerMomentPublishCount: Int
        public let deferredOptimizerMomentLoadCount: Int
        public let leafPublicationCount: Int
        public let finalCommitPublicationCount: Int
        public let modelAllocationAndMaterializationCount: Int
        public let optimizerAllocationCount: Int
        public let typedOptimizerStateImportCount: Int
        public let workerProcessCount: Int
        public let supervisorProcessCount: Int
        public let releaseVerifierProcessCount: Int
        public let maximumPublicReceiptCount: Int
    }

    public struct CheckpointLeafPolicy: Codable, Equatable, Sendable {
        public let role: String
        public let artifactKind: String
        public let encoding: String
        public let publicationOrdinal: Int
        public let required: Bool
        public let immutableNoReplace: Bool
        public let independentlyExternallyBound: Bool
        public let authoritativeBeforeFinalCommit: Bool
    }

    public struct CheckpointPolicy: Codable, Equatable, Sendable {
        public let schemaID: String
        public let externalCommitBindingSchemaID: String
        public let leaves: [CheckpointLeafPolicy]
        public let finalCommitManifestPublishedLast: Bool
        public let finalCommitManifestIsExclusiveCommitPoint: Bool
        public let partialPrecommitLeavesAreAuthoritative: Bool
        public let partialPrecommitLeavesMustBeQuarantined: Bool
        public let failedWritePartialStateCanBePromoted: Bool
        public let discoverAndTrustLoadAuthorized: Bool
        public let loadRequiresCallerSuppliedExactCommitBinding: Bool
        public let loadRequiresExactInventoryAndEveryLeafBinding: Bool
        public let inPlaceMutationOrReplacementAuthorized: Bool
        public let retainedCheckpointAuthorized: Bool
        public let artifactUploadAuthorized: Bool
        public let baselineControlRequiredFields: [String]
        public let comparatorControlRequiredFields: [String]
        public let baselineIsSoleLoadAuthoritativeResumeSet: Bool
        public let comparatorRoleRejectedAsResumeAuthority: Bool
    }

    public struct ComparisonDomain: Codable, Equatable, Sendable {
        public let id: String
        public let kind: String
        public let leftRole: String
        public let rightRole: String
        public let expectedPathCount: Int
        public let expectedPathSetBinding: String
        public let exactRequired: Bool
        public let domainPathComplete: Bool
        public let sortedUniquePathsRequired: Bool
        public let shapeDTypeElementAndByteCountRequired: Bool
        public let canonicalLogicalBytesOrFrozenPerPathSHA256Required: Bool
    }

    public struct ComparisonPolicy: Codable, Equatable, Sendable {
        public let domains: [ComparisonDomain]
        public let exactTensorBytesRequired: Bool
        public let containerByteEqualityAloneSufficient: Bool
        public let ulpToleranceEstablishesExactResume: Bool
        public let measuredExactMismatchIsValidTerminalOutcome: Bool
        public let measuredExactMismatchEstablishesResume: Bool
        public let structuralCatalogDigestAlgorithmID: String
        public let structuralCatalogDigestPreimageRule: String
        public let logicalBytesDigestAlgorithmID: String
        public let logicalBytesDigestPreimageRule: String
        public let topologyDriftClassification: String
        public let evaluationComparisonRequiredPaths: [String]
    }

    public struct ResourcePolicy: Codable, Equatable, Sendable {
        public let observedRun123ConfiguredMemoryLimitBytes: UInt64
        public let successorMemoryLimitFormula: String
        public let successorMemoryLimitSetterCount: Int
        public let successorMemoryLimitReadbackCount: Int
        public let successorCacheLimitSetterCount: Int
        public let successorCacheLimitReadbackCount: Int
        public let minimumMemoryLimitFloorBytes: UInt64
        public let configuredCacheLimitBytes: UInt64
        public let observedPeakBytes: UInt64
        public let weightsLogicalBytes: UInt64
        public let optimizerMomentLogicalBytes: UInt64
        public let minimumCommittedTensorStateBytes: UInt64
        public let gradientLogicalBytes: UInt64
        public let minimumStatePlusGradientBytes: UInt64
        public let threeTimesCommittedStateDiskComparatorBytes: UInt64
        public let availableFilesystemFloorBytes: UInt64
        public let projectedStatePlusV2VerificationWeightsBytes: UInt64
        public let rejectedStatePlusEagerMomentReloadBytes: UInt64
        public let ephemeralFourLeafSetCount: Int
        public let ephemeralFourLeafSetRoles: [String]
        public let uninterruptedSuccessorStateRetainedInRAMForComparison:
            Bool
        public let descriptorBoundStreamingLeafComparisonRequired: Bool
        public let resourceABSTAINAuthorized: Bool
        public let resourceABSTAINEstablishesResume: Bool
        public let ordinaryJobFitEstablished: Bool
        public let sequentialOnePathAtATimeHashAndCompareRequired: Bool
        public let privateComparatorInventoryBoundAndDeletedBeforeReceipt:
            Bool
        public let predecessorPeakIsStage7PeakBound: Bool
        public let peakResetCountBeforeActiveWork: Int
        public let requiredPhaseIDs: [String]
        public let requiredPerPhaseMetricFields: [String]
        public let requiredCheckedEvalPhaseTargets: [String]
        public let measurementAllocatesSecondTensorCatalog: Bool
        public let measurementMutatesOrResetsCumulativePeak: Bool
        public let resourceABSTAINGuardIDs: [String]
    }

    public struct EnvironmentPolicy: Codable, Equatable, Sendable {
        public let mlxEnableTF32: String
        public let exactMLXRevision: String
        public let exactMLXCheckoutOrigin: String
        public let swiftPMBuildConfiguration: String
        public let graphCompileMode: String
        public let compileTransformInvocationCount: Int
        public let requiredDynamicBindings: [String]
        public let metalDeviceCount: Int
        public let metalDeviceIndex: Int
        public let metalDeviceMustBeDefault: Bool
        public let metalDeviceMustHaveUnifiedMemory: Bool
        public let mlxDeviceMustBeSuppliedDevice: Bool
        public let mlxDefaultStreamMustBeGPU: Bool
        public let cpuFallbackAuthorized: Bool
        public let stagedAndRuntimeMetallibBindingsRequired: Bool
        public let streamAssignmentAndOrderBound: Bool
        public let evaluationOrderBound: Bool
        public let preAndPostDeviceIdentityMustMatch: Bool
        public let preAndPostMLXPolicyAndLimitsMustMatch: Bool
    }

    public struct LeasePublicationIntegrityPolicy:
        Codable, Equatable, Sendable
    {
        public let leaseType: String
        public let metalDeviceIndex: Int
        public let acquireNonblockingBeforeCoreGraphicsMetalOrMLX: Bool
        public let supervisorOwnsLease: Bool
        public let workerInheritedLeaseDescriptorCount: Int
        public let holdThroughCandidateCleanupAndPostflight: Bool
        public let explicitVoidReleaseRequired: Bool
        public let distinctExecVerifierReacquiresAndReleases: Bool
        public let leaseAcquireCount: Int
        public let leaseReleaseCount: Int
        public let verifierRunsWhileSupervisorAlive: Bool
        public let verifierProofRequiredForPassOrPostAcquisitionAbstain:
            Bool
        public let persistentLeaseRootMode: String
        public let persistentLeaseLeafMode: String
        public let persistentLeaseRootOrLeafRemovalAuthorized: Bool
        public let descriptorDerivedLeaseTupleFields: [String]
        public let descriptorDerivedParentTupleFields: [String]
        public let parentNlinkIsObservationalOnly: Bool
        public let exactLeaseInventoryRequired: Bool
        public let artifactRootStartsPrivateAndEmpty: Bool
        public let unknownArtifactInventoryFailsClosed: Bool
        public let recursiveCleanupAuthorized: Bool
        public let artifactAbsenceProvedBeforeReceipt: Bool
        public let workerEmitsPrivateFramedCandidateOnly: Bool
        public let atMostOneCanonicalPublicReceipt: Bool
        public let publicReceiptIsLastAuthoredFallibleAction: Bool
        public let launcherTrapsClearedBeforeFinalReceipt: Bool
        public let finalReceiptUsesExecUsrBinPrintf: Bool
        public let workerPublicReceiptPrefixCount: Int
        public let supervisorPublicReceiptPrefixCount: Int
        public let launcherMaximumPublicReceiptPrefixCount: Int
        public let publicReceiptClaimsLauncherSuccess: Bool
        public let publicReceiptClaimsOuterWorkflowSuccess: Bool
        public let publicReceiptContainsRawAbsolutePaths: Bool
        public let publicReceiptContainsRawArtifactBytes: Bool
        public let privateCandidateUsesFramedChunkedTransport: Bool
        public let privateCandidateSchemaID: String
        public let privateTerminalSchemaID: String
        public let publicReceiptSchemaID: String
        public let publicReceiptPrefix: String
        public let publicReceiptMaximumCount: Int
        public let publicReceiptPayloadEncoding: String
        public let requiredPrivateCandidateFields: [String]
        public let requiredPrivateTerminalFields: [String]
        public let requiredPublicReceiptFields: [String]
        public let publicPathProjectionRule: String
        public let maximumPublicCanonicalByteCount: Int
        public let privateCandidateAndTerminalTransportFramesCarryOutOfBandByteCountAndSHA256:
            Bool
        public let maximumPrivateCandidateCanonicalByteCount: Int
        public let maximumPrivateTerminalCanonicalByteCount: Int
        public let framedLengthGrammar: String
        public let maximumFrameChunkByteCount: Int
        public let frameReadDeadlineSeconds: Int
        public let frameSHA256VerifiedBeforeDecode: Bool
        public let frameEOFAndTrailingByteRejectionRequired: Bool
        public let implementationInventoryEntryFields: [String]
        public let comparisonDomainResultFields: [String]
        public let resourcePhaseRecordFields: [String]
        public let checkpointSetBindingFields: [String]
        public let publicDescriptorTupleFields: [String]
        public let tensorCatalogProjectionFields: [String]
        public let environmentAndDeviceReceiptFields: [String]
        public let operationCountReceiptFields: [String]
        public let artifactCleanupReceiptFields: [String]
        public let semanticPathProjectionFields: [String]
        public let authorityAndExactMainBindingFields: [String]
        public let firstMismatchReceiptFields: [String]
        public let leaseAndVerifierReceiptFields: [String]
        public let semanticPathProjectionCount: Int
        public let publicReceiptNestedTypeAndCardinalityRules: [String]
        public let checkpointLeafBindingFields: [String]
        public let externalV2BindingFields: [String]
        public let filesystemIDFields: [String]
        public let lockBindingFields: [String]
        public let maximumTensorCatalogPathCount: Int
        public let pureMaximalReceiptSerializationCeilingTestRequired: Bool
        public let maximalPublicReceiptFixtureCanonicalByteCount: Int
    }

    public struct PathPolicy: Codable, Equatable, Sendable {
        public let path: String
        public let gitMode: String
        public let role: String
    }

    public struct AuthorityClosurePolicy: Codable, Equatable, Sendable {
        public let exactChangedPaths: [PathPolicy]
        public let expectedRootTestCount: Int
        public let expectedIsolatedGroupTestCounts: [Int]
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedMetalTestCount: Int
        public let expectedMaintainedRuntimeTestCount: Int
        public let expectedTokenizerTestCount: Int
        public let expectedLiveTestCount: Int
        public let expectedTotalTestCount: Int
        public let reviewedMainTimeoutMinutes: Int
        public let launcherInvocationCount: Int
        public let mechanicsExecutionCount: Int
        public let relevantReceiptCount: Int
        public let artifactCount: Int
    }

    public struct SuccessorPolicy: Codable, Equatable, Sendable {
        public let exactChangedPaths: [PathPolicy]
        public let exactChangedPathCount: Int
        public let checkpointCodecMomentValueType: String
        public let optimizerTypedMappingOwner: String
        public let rootPackageManifestMutationAuthorized: Bool
        public let rootPackageLockMutationAuthorized: Bool
        public let validationPackageLockMutationAuthorized: Bool
        public let existingMechanicsPayloadMutationAuthorized: Bool
        public let exactMainOnly: Bool
        public let separatelyReviewed: Bool
        public let oneShotOpportunityCount: Int
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementRunAuthorized: Bool
        public let focusedPureContractTestCount: Int
        public let launcherLocalPureContractTestCount: Int
        public let directSupervisorProbeCount: Int
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedTotalXCTestCount: Int
        public let reviewedMainTimeoutMinutes: Int
        public let checkoutDepth: Int
        public let releaseBuildCount: Int
        public let focusedContractBuildCount: Int
        public let launcherContractUsesSkipBuild: Bool
        public let workerTimeoutSeconds: Int
        public let supervisorTimeoutSeconds: Int
        public let terminationGraceSeconds: Int
        public let outerWorkflowTimeoutSeconds: Int
        public let timeoutConsumesOneShotAndNeverRetries: Bool
        public let timeoutReceiptRequiresIntegrityCleanupAndVerifierClosure:
            Bool
    }

    public struct OutcomePolicy: Codable, Equatable, Sendable {
        public let allowedTerminalStatuses: [String]
        public let noPublicReceiptFailureClasses: [String]
        public let oneShotConsumptionBoundary: String
        public let safeIntegrityAbstainMayEmitPublicReceiptOnlyAfterVerifier:
            Bool
        public let mechanicsBeginningConsumesOneShot: Bool
        public let everyOutcomeForbidsRetryRerunAndReplacement: Bool
        public let passEstablishesExactRunBPathSameDeviceEphemeralResume:
            Bool
        public let passCandidateRequiresIntegrityWorkflowObservationAndRetirement:
            Bool
        public let passCandidateCanSatisfyStage8PrerequisiteOnlyAfterClosure:
            Bool
        public let passAuthorizesStage8: Bool
        public let measuredMismatchRequiresFirstMismatchDomain: Bool
        public let measuredMismatchRequiresFirstMismatchPath: Bool
        public let measuredMismatchRequiresExpectedAndObservedBindings: Bool
        public let measuredMismatchEstablishesResume: Bool
        public let resourceAbstainEstablishesResume: Bool
        public let integrityAbstainEstablishesResume: Bool
        public let everyOutcomeRequiresAppendOnlyObservationAndRetirement:
            Bool
        public let resourceAbstainRequiresPositiveAuthorizedGuardProof: Bool
        public let unknownErrorsAndSemanticOrInventoryFailuresAreResource:
            Bool
        public let measuredMismatchRequiresTwoCompleteValidTrajectories:
            Bool
        public let completeScientificOutcomeRequiresFullCountsAndAllPhases:
            Bool
        public let abstainRequiresExactMonotonicOperationAndPhasePrefix: Bool
        public let abstainRequiresFirstFailedOperationOrGuardAndZeroLaterScience:
            Bool
        public let leaseUnavailableConsumesOneShotPermitsNullBindingsAndEmitsNoPublicReceipt:
            Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let authorityOnlyNoExecutionEvidence: Bool
        public let stage7AuthorityEstablished: Bool
        public let stage7MechanicsAuthorizedAfterGreenClosure: Bool
        public let oneSeparatelyReviewedExactMainStage7OpportunityAuthorized:
            Bool
        public let processExecutionAuthorizedByThisClosure: Bool
        public let filesystemIOAuthorizedByThisClosure: Bool
        public let mlxImportedByThisClosure: Bool
        public let metalImportedByThisClosure: Bool
        public let modelAllocationAuthorizedByThisClosure: Bool
        public let trainingExecutionAuthorizedByThisClosure: Bool
        public let checkpointReadAuthorizedByThisClosure: Bool
        public let checkpointWriteAuthorizedByThisClosure: Bool
        public let launcherInvocationAuthorizedByThisClosure: Bool
        public let workflowTimeoutMutationAuthorizedByThisClosure: Bool
        public let stage7ExecutionObserved: Bool
        public let native300MTrajectoryResumeEstablished: Bool
        public let generalTrainingResumeEstablished: Bool
        public let durableCheckpointAvailabilityEstablished: Bool
        public let checkpointDurabilityEstablished: Bool
        public let retainedArtifactAuthorized: Bool
        public let artifactUploadAuthorized: Bool
        public let checkpointProvenanceEstablished: Bool
        public let checkpointAdmissionGranted: Bool
        public let additionalExecutionAuthorized: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let broadNative300MTrainingAuthorized: Bool
        public let ordinaryJobFitEstablished: Bool
        public let modelQualityEstablished: Bool
        public let candidateAdmissionGranted: Bool
        public let downstreamTrialAuthorized: Bool
        public let canaryAuthorized: Bool
        public let quantizationAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
        public let stage8AuthorityEstablished: Bool
        public let stage8Authorized: Bool
    }

    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let roadmap: RoadmapBinding
    public let stage5BPass: PredecessorObservationBinding
    public let bSpecificNative300MResourcePass: PredecessorObservationBinding
    public let prerequisites: EstablishedPrerequisites
    public let retirementClosure: RetirementClosureIdentity
    public let bPath: BPathPolicy
    public let trainingMath: TrainingMathPolicy
    public let optimizerAndControl: OptimizerAndControlPolicy
    public let explicitRNG: ExplicitRNGPolicy
    public let dataCursor: DataCursorPolicy
    public let trajectory: TrajectoryExecutionPolicy
    public let operationCounts: OperationCounts
    public let checkpoint: CheckpointPolicy
    public let comparison: ComparisonPolicy
    public let resource: ResourcePolicy
    public let environment: EnvironmentPolicy
    public let immutableImplementation: ImmutableImplementationPolicy
    public let integrity: LeasePublicationIntegrityPolicy
    public let authorityClosure: AuthorityClosurePolicy
    public let successor: SuccessorPolicy
    public let outcomes: OutcomePolicy
    public let ceiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalSHA256 =
        "4d995b21a20424f1b05fbcb9fbe33780dbd7af03cbf68047270db4aae192caa4"

    public static let frozenV1: Self = {
        func source(
            _ path: String,
            _ mode: String,
            _ blob: String,
            _ bytes: Int,
            _ lines: Int,
            _ sha256: String,
            _ role: String
        ) -> SourceIdentity {
            .init(
                path: path,
                gitMode: mode,
                gitBlob: blob,
                byteCount: bytes,
                lfByteCount: lines,
                sha256: sha256,
                role: role)
        }

        func path(
            _ value: String,
            _ mode: String,
            _ role: String
        ) -> PathPolicy {
            .init(path: value, gitMode: mode, role: role)
        }

        let roadmapSource = source(
            "Sources/PrimeCore/PrimeNativeDecoderTrajectoryExactResumeDesignAuthority.swift",
            "100644", "20bcbf28ddcfa9a6339510d53e81da02ada9953e",
            77_582, 1_565,
            "92194cb171eb1219393008c1dcd3b1c7dfcb2fd9232f4149391dfc428a5e7969",
            "frozen_eight_stage_roadmap")
        let roadmapTest = source(
            "Tests/PrimeCoreTests/PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityTests.swift",
            "100644", "186dc546c7f889f28d700322ac06b7b8a8a4c252",
            26_700, 770,
            "1fc9d8a4dde9e5e4192de9c248076f218ea38094eb68c335ade6de50862eb58b",
            "frozen_eight_stage_roadmap_test")
        let stage5Source = source(
            "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservation.swift",
            "100644", "daca1d73cdb2d71fc2298aa30b39da757e881923",
            70_671, 1_205,
            "52aa88169affbfa80f08ea3a1425d0b5273154f187a38fc286e02abd7f37943c",
            "stage5_b_pass_observation")
        let stage5Test = source(
            "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationTests.swift",
            "100644", "c1a925db6906286561ea7ca72b7be9a5209a6e93",
            38_745, 913,
            "ae74b493749675fc6d81224d83bd01fae9371aa3c9f16196ec6342aca5eaae02",
            "stage5_b_pass_observation_test")
        let bResourceSource = source(
            "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservation.swift",
            "100644", "d44ba8ef5722b8193c0335dc65deaff0a931cfaa",
            95_684, 1_660,
            "3cd93a37facd384aee5b5ce4dbea17cf404452788af9a6b652f2f2f4efdee9b5",
            "b_resource_pass_and_retirement_observation")
        let bResourceTest = source(
            "Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationTests.swift",
            "100644", "6863d683344e4ecf912f77cc52c4c5cd75b15620",
            27_544, 684,
            "64e9192d4b9e9ae7f2f44137b096897c524bad94c1ca0c4f8222a0d9ffbd4a8b",
            "b_resource_pass_and_retirement_observation_test")

        let currentMain = RepositoryIdentity(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            revision: "912ca2ab8148255fa588a2a1d336b9dcb1221978",
            tree: "3f9dbf9abb6df4bd739a9f5c17a3583afdfee9c0",
            orderedParentRevisions: [
                "bf98ddb13f6f6128a185b2f553b5cb3f1e30904b",
                "f0bda9c9cf7a2bd8aadbc8acd2f0c2abc07189b8",
            ],
            pullRequestNumber: 114,
            historyPreservingTwoParentMerge: true,
            mergeTreeEqualsReviewedHeadTree: true,
            exactMainRequired: true)

        let implementationSources: [SourceIdentity] = [
            source("Package.swift", "100644", "8e14c10aded588b3902a042341bca7acc842bcc6", 32_843, 934, "fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81", "immutable_root_manifest"),
            source("Package.resolved", "100644", "14d804bb4291720477240c27e24de6fbdc876b3b", 645, 23, "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375", "immutable_root_lock"),
            source("Tests/PrimeNativeDecoderTrainingValidation/Package.swift", "100644", "08b732f88ce3be0cd86905df8b78f2492c7ca557", 2_778, 92, "46fca0c696a46ccc9e22180ca5ec80cffc202a43b68b5f8c9568051e8e71348e", "controlled_successor_validation_manifest_base"),
            source("Tests/PrimeNativeDecoderTrainingValidation/Package.resolved", "100644", "8bf05edf1ea8789e7683e72fe756d79aaaa61320", 645, 23, "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225", "immutable_validation_lock"),
            source("Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift", "100644", "de6cff4472de55a8fafe2962c3be4ca37c972caf", 43_339, 1_193, "ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc", "immutable_decoder_and_b_path"),
            source("Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift", "100644", "4566477e14b4b6cfa06286f384f07f8d452e8724", 97_449, 2_444, "cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb", "immutable_training_implementation"),
            source("Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift", "100644", "cf3d743d121f4eaa028e0e392e04587bcd0b93d8", 225_960, 5_233, "77fbe6b5e9548d84af30c95ba4ca0cfa2d03d5e1884c74d0a9ae297b109eed8b", "immutable_b_resource_predecessor_implementation"),
            source("Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift", "100644", "7e993df79cc3a7c37d130c9eb5e7f30f63a6c386", 9_228, 193, "2b73886d067015ea65a71944bdc9d0f06025ee65858e9cfccf9a8f0936cf36f3", "immutable_v2_compatibility_identity"),
            source("Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift", "100644", "105af3f93acf9358e7b66c3a327e45a931deab8b", 54_880, 1_476, "39f74373923fcbb56eae5da2038795668c3347115c854a219374d1b797c9761d", "immutable_v2_codec_and_writer"),
            source("Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOAuthority.swift", "100644", "f0d010959aaf20fddb755aec7a1b61550dec93dd", 40_522, 845, "8d3626aacfce1fd0350b79872b829df4322695981eaebcf88bc4f38ec2973880", "immutable_v2_io_authority"),
            source("Sources/PrimeCore/PrimeDurableArtifacts.swift", "100644", "e9e462aa17ae1d4393c77cf953b3c7d44abfcd1e", 144_993, 4_184, "faa8254ee6ecd97f064a6553efba8158fff6a33fc882607444ba117d56328430", "immutable_descriptor_bound_artifact_primitives"),
            source("Sources/PrimeCore/PrimeMetalDeviceLease.swift", "100644", "da3daa54802b67dc2c8c04a89b388e9927dd8726", 16_985, 534, "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657", "immutable_metal_device_lease"),
            source("Sources/PrimeCore/PrimeTypedOptimizerRestoreContract.swift", "100644", "eb0d6d5be6f8a1381006c7487dc5a56674fda510", 66_162, 1_983, "65c7fb2678f4a53aba9b0355929626dd56faea7fcfb1995a74a26f3bf144c5e4", "immutable_typed_optimizer_contract"),
            source("Sources/PrimeTypedOptimizerRestoreMechanics/PrimeTypedOptimizerRestoreMechanics.swift", "100644", "26ac4d40573938c51fb78b0c1d0d8ba8e8ad910b", 45_949, 1_511, "7b1cac142f20eb1a643863f113733546b4a386ee2e935d1d2f8fb3ed6f436b25", "immutable_typed_optimizer_restore_implementation"),
            source("Tests/PrimeNativeDecoderCheckpointV2IOValidation/Tests/PrimeNativeDecoderCheckpointV2IOTests/PrimeNativeDecoderCheckpointV2IOTests.swift", "100644", "74129e24c11a742adb11a80a8e454924426c63ee", 18_388, 409, "f910ae77c7ea54d67f751902168b278bd6a45a5c2deb45618c5f0cb0b6952376", "inherited_v2_io_proof"),
            source("Tests/PrimeCoreTests/PrimeMetalDeviceLeaseTests.swift", "100644", "05960c8017147f7a3e1d90fb68d2449bc18698b6", 13_257, 451, "ebdcd5d62d0d0915a63e82822ba58dc954e209bcaf7905b663b99a4687670018", "inherited_lease_proof"),
            source("Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests.swift", "100644", "b78613e392ab20df0d11a2546aadf484e419b75c", 30_202, 564, "fb3abc5d6377867d438b8c48fd9cbeab3549f4570ded7570cf4bc9f585c1d8a7", "inherited_b_resource_contract_proof"),
        ]

        func comparisonDomain(
            _ id: String, _ kind: String, _ left: String, _ right: String,
            _ count: Int, _ binding: String
        ) -> ComparisonDomain {
            let tensorTopology =
                kind == "tensor_catalog" || kind == "scalar_and_tensor"
            return ComparisonDomain(
                id: id,
                kind: kind,
                leftRole: left,
                rightRole: right,
                expectedPathCount: count,
                expectedPathSetBinding: binding,
                exactRequired: true,
                domainPathComplete: true,
                sortedUniquePathsRequired: tensorTopology,
                shapeDTypeElementAndByteCountRequired: tensorTopology,
                canonicalLogicalBytesOrFrozenPerPathSHA256Required:
                    tensorTopology)
        }
        let comparisonDomains = [
            comparisonDomain("snapshot_weights", "tensor_catalog", "published_baseline_checkpoint", "fresh_restored_baseline", 218, "exact_decoder_parameter_catalog_v1"),
            comparisonDomain("snapshot_optimizer_first_moments", "tensor_catalog", "published_baseline_checkpoint", "fresh_restored_baseline", 218, "role_prefixed_first_moment_parameter_catalog_v1"),
            comparisonDomain("snapshot_optimizer_second_moments", "tensor_catalog", "published_baseline_checkpoint", "fresh_restored_baseline", 218, "role_prefixed_second_moment_parameter_catalog_v1"),
            comparisonDomain("snapshot_full_canonical_control_state_roundtrip", "control", "published_baseline_control_leaf", "fresh_restored_control_state", 13, "baseline_control_required_fields_v1"),
            comparisonDomain("batch2_token_and_mask_digest", "digest", "uninterrupted_branch_batch2", "resumed_branch_batch2", 1, "frozen_batch2_token_and_mask_sha256_v1"),
            comparisonDomain("successor_loss_per_target_and_whole_logits_bits", "scalar_and_tensor", "uninterrupted_n_plus_1", "resumed_n_plus_1", 3, "loss_scalar_per_target_tensor_whole_logits_shape_1x128x512_float32_v1"),
            comparisonDomain("successor_raw_gradient_bytes", "tensor_catalog", "uninterrupted_n_plus_1", "resumed_n_plus_1", 218, "exact_decoder_parameter_catalog_v1"),
            comparisonDomain("successor_clipped_gradient_bytes", "tensor_catalog", "uninterrupted_n_plus_1", "resumed_n_plus_1", 218, "exact_decoder_parameter_catalog_v1"),
            comparisonDomain("successor_raw_norm_bits", "scalar", "uninterrupted_n_plus_1", "resumed_n_plus_1", 1, "raw_norm_float32_bits_v1"),
            comparisonDomain("successor_clipped_global_norm_bits", "scalar", "uninterrupted_n_plus_1", "resumed_n_plus_1", 1, "clipped_global_norm_float32_bits_v1"),
            comparisonDomain("successor_clip_scale_bits", "scalar", "uninterrupted_n_plus_1", "resumed_n_plus_1", 1, "clip_scale_float32_bits_v1"),
            comparisonDomain("successor_post_update_parameter_bytes", "tensor_catalog", "uninterrupted_n_plus_1", "resumed_n_plus_1", 218, "exact_decoder_parameter_catalog_v1"),
            comparisonDomain("successor_optimizer_first_moment_bytes", "tensor_catalog", "uninterrupted_n_plus_1", "resumed_n_plus_1", 218, "role_prefixed_first_moment_parameter_catalog_v1"),
            comparisonDomain("successor_optimizer_second_moment_bytes", "tensor_catalog", "uninterrupted_n_plus_1", "resumed_n_plus_1", 218, "role_prefixed_second_moment_parameter_catalog_v1"),
            comparisonDomain("successor_checked_evaluation_state_and_read_only_nonmutation", "scalar_and_tensor", "uninterrupted_n_plus_1_evaluation", "resumed_n_plus_1_evaluation", 8, "evaluation_required_paths_v1"),
            comparisonDomain("optimizer_global_step_schedule_and_current_learning_rate_bits", "control", "uninterrupted_n_plus_1_control", "resumed_n_plus_1_control", 5, "optimizer_terminal_control_fields_v1"),
            comparisonDomain("explicit_rng_algorithm_domain_key_counter_and_consumption_digest", "control", "uninterrupted_n_plus_1_control", "resumed_n_plus_1_control", 4, "four_explicit_rng_domain_records_v1"),
            comparisonDomain("cursor_and_snapshot_boundary_zero_state", "control", "uninterrupted_n_plus_1_control", "resumed_n_plus_1_control", 8, "terminal_cursor_and_zero_state_fields_v1"),
        ]

        return Self(
            schemaVersion: 1,
            authorityID:
                "prime_native_decoder_native300m_trajectory_checkpoint_execution_authority_v1",
            authorityKind:
                "append_only_dependency_free_nonexecuting_native300m_trajectory_checkpoint_execution_authority",
            roadmap: .init(
                authorityID:
                    "ergentics_prime_native_decoder_trajectory_exact_resume_design_authority_v1",
                canonicalSHA256:
                    "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
                source: roadmapSource,
                test: roadmapTest,
                orderedStageIDs: [
                    "trajectory_schema_and_pure_contract_v1",
                    "tiny_cpu_train_evaluate_mechanics_v1",
                    "tiny_cpu_explicit_rng_cursor_resume_v1",
                    "tiny_durable_multileaf_commit_fault_injection_v1",
                    "tiny_repeated_metal_trajectory_determinism_assay_v1",
                    "native300m_resource_only_one_step_probe_v1",
                    "native300m_trajectory_checkpoint_execution_v1",
                    "retained_trajectory_provenance_and_admission_v1",
                ],
                stageOrdinal: 7,
                stageID: "native300m_trajectory_checkpoint_execution_v1",
                objective:
                    "execute_one_bounded_native300m_step_checkpoint_restore_and_exact_successor_step_only_after_assay_and_resource_clearance",
                requiredPredecessorStageID:
                    "native300m_resource_only_one_step_probe_v1",
                successorStageID:
                    "retained_trajectory_provenance_and_admission_v1",
                separatelyAuthorizedSuccessorRequired: true),
            stage5BPass: .init(
                observationID:
                    "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_observation_v1",
                canonicalSHA256:
                    "7e17cfdc59f63a775aa4ec5b797328e80c0ab75ef65b2b3ddd7f4bf8deb48ef9",
                source: stage5Source,
                test: stage5Test,
                mechanicsRevision:
                    "68422b34425fce761ce8d4afcbd7b0edbc1cf648",
                mechanicsTree:
                    "658f7f2aa6a023efb37520bd7596c37b474ecda1",
                workflowRunID: 31_834_513_845,
                workflowRunNumber: 117,
                workflowRunAttempt: 1,
                status: "PASS_CLEARANCE",
                oneShotConsumed: true,
                oneShotExhausted: true),
            bSpecificNative300MResourcePass: .init(
                observationID:
                    "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_execution_observation_v1",
                canonicalSHA256:
                    "da9edca25faaef6ae6fae38669692603faeb7c29f4995a0fce4a096015a49a88",
                source: bResourceSource,
                test: bResourceTest,
                mechanicsRevision:
                    "bf98ddb13f6f6128a185b2f553b5cb3f1e30904b",
                mechanicsTree:
                    "2ef7501506f19b9d9734dbc63ccacc62182c3952",
                workflowRunID: 31_859_699_200,
                workflowRunNumber: 123,
                workflowRunAttempt: 1,
                status: "PASS",
                oneShotConsumed: true,
                oneShotExhausted: true),
            prerequisites: .init(
                stage5MechanicsSuccessEstablished: true,
                stage5ResultEstablished: true,
                stage5AssayClearanceEstablished: true,
                repeatedSameDeviceBPathDeterminismEstablished: true,
                exactSameDeviceBPathGradientBytesEstablished: true,
                bSpecificNative300MResourceWitnessEstablished: true,
                bSpecificNative300MResourceClearanceEstablished: true,
                bSpecificNative300MRunnerCapacityEstablished: true,
                historicalStage6ResourceClearanceRemainsEstablished: true,
                historicalStage6ResourceClearanceAppliesToBPath: false,
                defaultGatherDeterminismEstablished: false,
                arbitraryTokenDeterminismEstablished: false,
                crossDeviceDeterminismEstablished: false),
            retirementClosure: .init(
                frozenObservationRetirementObserved: false,
                laterRetirementClosureObserved: true,
                repository: currentMain,
                workflowID: 329_017_041,
                workflowRunID: 31_865_057_224,
                workflowRunNumber: 125,
                workflowRunAttempt: 1,
                checkSuiteID: 86_443_755_850,
                event: "push",
                activeRootJobID: 94_964_670_621,
                activeRootJobConclusion: "success",
                reviewedMainJobID: 94_965_011_315,
                reviewedMainJobConclusion: "success",
                exactChangedPaths: [
                    source(
                        ".github/scripts/prime-ci-active-root-quarantine.sh",
                        "100755",
                        "9bea612c2ca895c86b91284e9ac642c1bf1a752d",
                        815_405, 14_023,
                        "900cf646ab24a8b10facc8e5d18888ac1975a35b5e1b7d1d2389dccc12a1d25d",
                        "retirement_active_root_gate"),
                    source(
                        ".github/workflows/prime-active-root-quarantine.yml",
                        "100644",
                        "5bc2f0b1a983fc7509828dcd3d84fc939b7daf6d",
                        100_512, 613,
                        "a7c02e2026c6514baa4c026a64190bcc25c9e5692deec505c449b6431ffe180a",
                        "retirement_workflow"),
                    source(
                        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                        "100644",
                        "e8f5dfcfe9472869c81e7425023dbb2e49d6c67e",
                        546, 13,
                        "14e4be6abdd0c0e30e50f3cb3b7b8774c8e6d17d3639e79b159d01c4299d5704",
                        "retirement_embedded_provenance"),
                    bResourceSource,
                    bResourceTest,
                ],
                rootTestCount: 61,
                isolatedTestCount: 6,
                focusedWholeTestCount: 67,
                retainedLiveTestCount: 46,
                totalTestCount: 113,
                artifactCount: 0,
                retryCount: 0,
                rerunCount: 0,
                retiredLauncherAndReceiptCountsAreZero: true,
                embeddedSourceIdentitySHA256:
                    "1b2290a13d37b147c1e40cbb2e023f03175733c7fb4cf474c48fd482c5921dd9",
                embeddedSourceIdentityRecordCount: 488,
                preservedIndexSHA256:
                    "535dbd253cc99392ec6abfcb81eac30199d372803f09d107e52dcbb48fc1d497"),
            bPath: .init(
                algorithmID:
                    "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1",
                selectorCase: "denseOneHotMatmulV1",
                selectorRawValue:
                    "flattened_dense_one_hot_matmul_input_embedding_v1",
                decoderAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
                packageOnlySurfaceRequired: true,
                publicDecoderAPIAdded: false,
                maintainedInferencePathUnchanged: true,
                vocabularySize: 512,
                modelWidth: 1_024,
                layerCount: 24,
                queryHeadCount: 16,
                keyValueHeadCount: 4,
                headWidth: 64,
                intermediateWidth: 2_816,
                maximumSequenceLength: 2_048,
                parameterPathCount: 218,
                uniqueParameterCount: 271_107_072,
                parameterDType: "float32",
                logicalParameterByteCount: 1_084_428_288,
                initialModelSeed: 44,
                batchSize: 1,
                sequenceLength: 128,
                selectedTargetCount: 127,
                exactFixedBatchCount: 2,
                batchAlgorithmIDs: [
                    "prime_stage6_seed44_batch1x128_mod510_stride73_v1",
                    "prime_stage7_seed44_batch1x128_cursor1_mod510_stride151_v1",
                ],
                batchGenerationRules: [
                    "[1]+map_index_0_through_126_to_2_plus_index_times_73_plus_44_modulo_510",
                    "[1]+map_index_0_through_126_to_2_plus_index_times_151_plus_45_modulo_510",
                ],
                batchTokenIDsSHA256: [
                    "220a52583cdbb82311863f4643679734b2ffc69725af021f066a84fc7520a172",
                    "af5a9f69f9cf48f051d4f8ca39577e4b24f557bbde11bf32208aa603cc17f4c3",
                ],
                completionMaskGenerationRule:
                    "rank_two_single_row_array_false_then_127_true_values",
                completionMaskSHA256:
                    "92b0d20e1401a4a2abc71801ec84a6ada1a2a838132b7386f5efef7d4b345a6d",
                batchTokenAndMaskSHA256: [
                    "7fc5c4626fcb884976a4f5d4b8644ed087fa178027cc14a64044eb589daf5b62",
                    "e9ed189a1a8a9204cbc4bcf873e5c8b9c25273b6b9bd2e3c22e9279d1945088e",
                ],
                batchDigestPreimageRule:
                    "compact_sorted_key_json_utf8_rank_two_arrays_object_keys_completion_mask_and_token_ids",
                evaluationBatchOrdinal: 1,
                evaluationBatchTokenAndMaskSHA256:
                    "e9ed189a1a8a9204cbc4bcf873e5c8b9c25273b6b9bd2e3c22e9279d1945088e",
                evaluationConsumesDataCursor: false,
                evaluationDecoderAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
                evaluationTemporarilySetsTrainingModeFalse: true,
                evaluationRestoresPriorTrainingMode: true,
                evaluationUsesKVCache: false,
                evaluationChecksFullModelOptimizerAndControlNonmutation: true,
                predecessorConfigurationWasTrainingPolicy: false,
                explicitlyReauthorizedForThisStage7Opportunity: true,
                repeatedBatchConsumptionWithinSingleBranchAuthorized: false,
                sameSuccessorBatchAcrossAlternateBranchesRequired: true,
                evaluationInputReuseWithoutCursorConsumptionAuthorized: true,
                paddingAuthorized: false,
                kvCacheAuthorized: false),
            trainingMath: .init(
                compatibilitySchemaID:
                    "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
                modelConfigurationFactory:
                    "PrimeNativeGQADecoderConfiguration.native300MInventory(vocabularySize:512)",
                modelFactory:
                    "PrimeNativeGQADecoder.make(configuration:seed:)",
                ropeThetaFloat32BitPattern: 1_176_256_512,
                rmsNormEpsilonFloat32BitPattern: 925_353_388,
                shiftedLogitsSlice: "logits[0...,0..<127,0...]",
                shiftedTargetsSlice: "token_ids[0...,1..<128]",
                shiftedCompletionMaskSlice:
                    "completion_mask[0...,1..<128]",
                shiftedLogitsShape: [1, 127, 512],
                shiftedTargetsShape: [1, 127],
                shiftedCompletionMaskShape: [1, 127],
                crossEntropyAPI:
                    "MLXNN.crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)",
                crossEntropyWeights: "nil",
                crossEntropyAxis: -1,
                crossEntropyLabelSmoothingFloat32BitPattern: 0,
                crossEntropyReduction: "none",
                maskedMeanFormula:
                    "MLX.sum(per_target_loss*shifted_completion_mask.asType(.float32))/Float32(127)",
                selectedTargetDivisor: 127,
                exactLossBitsAndPerTargetOutputsCaptured: true,
                perTargetLossEvidenceShape: [1, 127],
                perTargetLossEvidenceDType: "float32",
                perTargetLossEvidenceElementCount: 127,
                wholeLogitsEvidenceRule:
                    "whole_logits_tensor_no_subset_before_shift_for_training_and_evaluation",
                wholeLogitsEvidenceShape: [1, 128, 512],
                wholeLogitsEvidenceDType: "float32",
                wholeLogitsEvidenceElementCount: 65_536,
                wholeLogitsEvidenceLogicalByteCount: 262_144,
                valueAndGradAPI: "MLXNN.valueAndGrad(model:_:)",
                valueAndGradClosureReturnsOnlyScalarLoss: true,
                rawGradientNormAlgorithmID:
                    "prime_stage6_global_f32_l2_norm_utf8_catalog_v1",
                rawGradientNormFormula:
                    "sqrt(sum_over_sorted_unique_paths(sum(gradient*gradient)))",
                gradientClipAlgorithmID:
                    "prime_stage6_global_norm_clip_f32_v1",
                gradientClipScaleFormula:
                    "min(Float32(1),maximum_gradient_norm/(raw_gradient_norm+gradient_norm_epsilon))",
                adamWUsesBiasCorrection: false,
                adamWUpdateOrdering:
                    "typed_AdamW_first_and_second_moments_then_decoupled_weight_decay_then_parameter_update_v1",
                exactPolicyPromotedOnlyForThisStage7Opportunity: true),
            optimizerAndControl: .init(
                implementation: "MLXOptimizers.AdamW",
                typedStateType: "AdamOptimizerState",
                typedMappingOwnedByTraining: true,
                checkpointCodecUsesNeutralMomentCatalog: true,
                learningRateFloat32BitPattern: 953_267_991,
                beta1Float32BitPattern: 1_063_675_494,
                beta2Float32BitPattern: 1_065_336_439,
                epsilonFloat32BitPattern: 841_731_191,
                weightDecayFloat32BitPattern: 1_008_981_770,
                maximumGradientNormFloat32BitPattern: 1_065_353_216,
                gradientNormEpsilonFloat32BitPattern: 897_988_541,
                gradientAccumulationCount: 1,
                initialGlobalStep: 0,
                snapshotGlobalStep: 1,
                terminalGlobalStep: 2,
                exactScheduleIdentityRequired: true,
                scheduleID: "constant_float32_learning_rate_v1",
                learningRateFloat32BitPatternsAtStepsZeroOneTwo: [
                    953_267_991, 953_267_991, 953_267_991,
                ],
                optimizerHasInternalStepCounter: false,
                callerOwnsGlobalStep: true,
                mutableRuntimeLearningRateStateRequired: true,
                updateTimeLearningRateReadOrdering:
                    "read_exact_float32_schedule_value_for_current_caller_step_immediately_before_adamw_update",
                exactCurrentLearningRateBitsRequired: true,
                explicitRNGRequired: true,
                rngDomainIDs: [
                    "model_initialization_v1",
                    "training_data_order_v1",
                    "augmentation_v1",
                    "evaluation_v1",
                ],
                exactRNGAlgorithmKeyCounterAndConsumptionDigestRequired: true,
                cursorPointsToNextUnconsumedBatchAtSnapshot: true,
                snapshotNextBatchOrdinal: 1,
                accumulationPhaseAtSnapshot: 0,
                pendingGradientCountAtSnapshot: 0,
                pendingPrefetchCountAtSnapshot: 0,
                kvCacheEntryCountAtSnapshot: 0),
            explicitRNG: .init(
                algorithmID: "sha256_counter_stream_v1",
                keyDerivationPreimageRule:
                    "sha256_utf8_prime_rng_key_v1_pipe_root_seed_decimal_pipe_domain_id",
                outputPreimageRule:
                    "sha256_utf8_prime_rng_output_v1_pipe_key_sha256_pipe_counter_decimal",
                consumptionPreimageRule:
                    "sha256_utf8_prime_rng_consumption_v1_pipe_domain_id_pipe_key_sha256_pipe_counter_before_pipe_counter_after_pipe_output_sha256_or_initial_zero_form",
                rootSeed: 44,
                domains: [
                    .init(
                        domainID: "model_initialization_v1",
                        keySHA256:
                            "81841e917219c7b5f32b1d28f346de8e200944c74db551c4d68b447d640ab7c3",
                        snapshotCounter: 1,
                        snapshotConsumptionSHA256:
                            "09a94232c0e287538033a198c102d21e9e66463cc753195463bd6bcea5dbf49d",
                        terminalCounter: 1,
                        terminalConsumptionSHA256:
                            "09a94232c0e287538033a198c102d21e9e66463cc753195463bd6bcea5dbf49d"),
                    .init(
                        domainID: "training_data_order_v1",
                        keySHA256:
                            "5dac53cfa73ddb616073eb979a105b8670e0032f9f58dcc578c200e01f9fc7e8",
                        snapshotCounter: 1,
                        snapshotConsumptionSHA256:
                            "478e3bc27342c234e560fe0f115acadc9322875ed1f0b704111436b54a61aba7",
                        terminalCounter: 2,
                        terminalConsumptionSHA256:
                            "8635f63040d540b810e954758592718d7aa217a8223cd06015bcee7e7bac75cf"),
                    .init(
                        domainID: "augmentation_v1",
                        keySHA256:
                            "844e82c444546ad5e68ed6aa2b03cb4dc339bbd92890692d0bf6d82f6c101936",
                        snapshotCounter: 0,
                        snapshotConsumptionSHA256:
                            "63de1106d0a8ec16ea7a25f425b09ab314b6bf8613c59be058609744788845b9",
                        terminalCounter: 0,
                        terminalConsumptionSHA256:
                            "63de1106d0a8ec16ea7a25f425b09ab314b6bf8613c59be058609744788845b9"),
                    .init(
                        domainID: "evaluation_v1",
                        keySHA256:
                            "015098b6cc2e83b47ae326da0501cd1478d5b9b556975ef7d5775be569878088",
                        snapshotCounter: 0,
                        snapshotConsumptionSHA256:
                            "be7149ab830966707309adfdf1cba38da5c1e7e5036e98d66962f8c025f0f211",
                        terminalCounter: 0,
                        terminalConsumptionSHA256:
                            "be7149ab830966707309adfdf1cba38da5c1e7e5036e98d66962f8c025f0f211"),
                ],
                domainKeysPairwiseDistinct: true,
                countersIndependent: true,
                implicitGlobalRandomStateAuthorized: false,
                evaluationConsumesRNG: false,
                augmentationConsumesRNG: false),
            dataCursor: .init(
                schemaID:
                    "prime_native_decoder_native300m_stage7_fixed_two_batch_cursor_v1",
                corpusBinding:
                    "synthetic_stage7_fixed_two_batch_fixture_v1",
                tokenizerBinding:
                    "not_applicable_direct_frozen_token_ids_v1",
                exampleGeneratorBinding:
                    "stage7_seed44_two_batch_formulae_v1",
                sourceInventoryBinding:
                    "two_in_memory_rank_two_token_and_mask_batches_v1",
                splitIdentity: "synthetic_train_only_v1",
                curriculumIdentity: "fixed_batch1_then_batch2_v1",
                epochAtSnapshot: 0,
                permutationAlgorithm: "fixed_identity_order_v1",
                permutationDomain: "training_data_order_v1",
                permutationKeySHA256:
                    "5dac53cfa73ddb616073eb979a105b8670e0032f9f58dcc578c200e01f9fc7e8",
                permutationSHA256:
                    "463f2998327eb3a694145e6014444480b2235be84aa6cfd57871cc64f1cd816c",
                permutationSHA256PreimageRule:
                    "sha256_of_compact_json_utf8_array_[0,1]",
                nextRowIndexAtSnapshot: 1,
                nextRowIDsAtSnapshot: ["stage7_fixed_row_1"],
                nextRowIDsSHA256:
                    "0ea879e81cb0c6cfe5727a5d326477f795cda9cb30060fdc5654047a9db258e1",
                nextRowIDsSHA256PreimageRule:
                    "sha256_of_compact_json_utf8_array_[stage7_fixed_row_1]",
                terminalEpoch: 1,
                terminalNextBatchOrdinal: 2,
                terminalNextRowIndex: 2,
                terminalNextRowIDs: [],
                terminalNextRowIDsSHA256:
                    "4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945",
                terminalNoNextBatchIdentity:
                    "end_of_exact_two_batch_fixture_no_next_batch_v1",
                terminalNoNextBatchSHA256:
                    "e060fff180d0d64ee23be9ee3a3bbcde166773ad8d207d61f074831258967d7a",
                terminalNoNextBatchSHA256PreimageRule:
                    "sha256_of_exact_utf8_terminal_no_next_batch_identity",
                evaluationCheckedAtSnapshotCurrentStep: true,
                evaluationCheckedAtEachTerminalCurrentStep: true,
                batchSize: 1,
                microbatchSize: 1,
                sequenceLength: 128,
                paddingPolicy: "none",
                dropLastPolicy: "not_applicable_exact_two_batches",
                causalMaskPolicy: "causal_attention_mask_v1",
                nextBatchTokenAndMaskSHA256:
                    "e9ed189a1a8a9204cbc4bcf873e5c8b9c25273b6b9bd2e3c22e9279d1945088e",
                cursorAdvanceCountPerTrainingStep: 1,
                evaluationAdvancesCursor: false),
            trajectory: .init(
                baselineStepCount: 1,
                uninterruptedSuccessorStepCount: 1,
                restoredSuccessorStepCount: 1,
                totalTrainingStepCount: 3,
                totalBackwardCount: 3,
                totalOptimizerUpdateCount: 3,
                snapshotCount: 1,
                freshRestoreCount: 1,
                checkedReadOnlyEvaluationCount: 3,
                snapshotBoundary:
                    "after_baseline_optimizer_update_and_checked_read_only_evaluation_before_batch2_consumption",
                exactOrderedPhases: [
                    "fresh_uninterrupted_model",
                    "baseline_step_n_batch1",
                    "checked_read_only_evaluation_n",
                    "publish_four_leaf_snapshot",
                    "uninterrupted_successor_step_n_plus_1_batch2",
                    "checked_read_only_evaluation_uninterrupted_n_plus_1",
                    "capture_uninterrupted_path_complete_gradient_evidence_then_release_gradients",
                    "publish_uninterrupted_n_plus_1_private_four_leaf_comparator",
                    "deallocate_uninterrupted_model_optimizer",
                    "clear_mlx_cache",
                    "fresh_restore_from_caller_supplied_exact_commit_binding",
                    "semantic_moment_reload_and_typed_optimizer_restore",
                    "restored_successor_step_n_plus_1_batch2",
                    "checked_read_only_evaluation_restored_n_plus_1",
                    "capture_resumed_path_complete_gradient_evidence_then_release_gradients",
                    "publish_resumed_n_plus_1_private_four_leaf_comparator",
                    "deallocate_resumed_model_optimizer_and_clear_mlx_cache",
                    "exact_path_complete_comparison",
                    "artifact_cleanup_and_absence_proof",
                    "postflight_and_release_verifier",
                    "public_receipt",
                ],
                uninterruptedAndRestoredFullStatesMayOverlap: false,
                baselineGradientsReleasedBeforeV2AndMomentPublication: true,
                uninterruptedGradientEvidenceCapturedBeforeRelease: true,
                uninterruptedGradientsReleasedBeforeComparatorPublication:
                    true,
                restoredGradientEvidenceCapturedBeforeRelease: true,
                restoredGradientsReleasedBeforeComparatorPublication: true,
                restoredDecoderTrainingModeTrueBeforeSuccessor: true,
                decoderTrainingModeTrueAfterEveryEvaluationRestore: true,
                resumedStateDeallocatedBeforeStreamingComparison: true,
                cacheClearedAfterResumedComparatorPublication: true,
                uninterruptedStateDeallocatedBeforeRestore: true,
                cacheClearedBeforeRestore: true,
                v2WriterTransientFreshVerificationModelAccountedFor: true,
                optimizerMomentSemanticReloadDeferredUntilAfterDeallocation:
                    true,
                eagerSecondMomentMaterializationDuringPublicationAuthorized:
                    false,
                exactSameDeviceOnly: true,
                authoritativeBaselineFourLeafSetRole:
                    "baseline_checkpoint",
                privateComparatorFourLeafSetRoles: [
                    "uninterrupted_n_plus_1_comparator",
                    "resumed_n_plus_1_comparator",
                ]),
            operationCounts: .init(
                trainingStepCount: 3,
                backwardCount: 3,
                optimizerUpdateCount: 3,
                denseBPathLogitsCallCount: 6,
                tokenBoundsValidationCount: 6,
                tokenBoundsCheckedEvalCount: 6,
                tokenBoundsGPUSynchronizeCount: 6,
                tokenBoundsHostBoolItemCount: 6,
                denseOneHotMatmulConstructionCount: 6,
                gradientEvidenceCaptureCount: 2,
                gradientCatalogReleaseCount: 3,
                resourceMeasurementCheckedEvalCount: 8,
                resourceMeasurementSynchronizeCount: 12,
                checkedReadOnlyEvaluationCount: 3,
                evaluationForwardPassCount: 3,
                forwardLossCount: 6,
                crossEntropyCount: 6,
                trainingModeDisableCount: 3,
                trainingModeRestoreCount: 3,
                v2WeightsWriteCount: 3,
                v2InternalVerificationLoadCount: 3,
                publicRestoreLoadCount: 1,
                optimizerMomentPublishCount: 3,
                deferredOptimizerMomentLoadCount: 1,
                leafPublicationCount: 12,
                finalCommitPublicationCount: 3,
                modelAllocationAndMaterializationCount: 5,
                optimizerAllocationCount: 2,
                typedOptimizerStateImportCount: 1,
                workerProcessCount: 1,
                supervisorProcessCount: 1,
                releaseVerifierProcessCount: 1,
                maximumPublicReceiptCount: 1),
            checkpoint: .init(
                schemaID:
                    "ergentics_prime_native_decoder_trajectory_exact_resume_checkpoint_v1",
                externalCommitBindingSchemaID:
                    "ergentics_prime_native_decoder_trajectory_exact_resume_external_commit_binding_v1",
                leaves: [
                    .init(
                        role: "weights_v2",
                        artifactKind:
                            "prime_native_decoder_model_weights_only_checkpoint",
                        encoding:
                            "safetensors_plus_exact_v2_external_binding",
                        publicationOrdinal: 1,
                        required: true,
                        immutableNoReplace: true,
                        independentlyExternallyBound: true,
                        authoritativeBeforeFinalCommit: false),
                    .init(
                        role: "optimizer_moments",
                        artifactKind:
                            "prime_native_decoder_adamw_moments_checkpoint_v1",
                        encoding: "safetensors_role_prefixed_string_mlxarray_catalog",
                        publicationOrdinal: 2,
                        required: true,
                        immutableNoReplace: true,
                        independentlyExternallyBound: true,
                        authoritativeBeforeFinalCommit: false),
                    .init(
                        role: "control_state_manifest",
                        artifactKind:
                            "prime_native_decoder_trajectory_control_state_v1",
                        encoding: "canonical_json",
                        publicationOrdinal: 3,
                        required: true,
                        immutableNoReplace: true,
                        independentlyExternallyBound: true,
                        authoritativeBeforeFinalCommit: false),
                    .init(
                        role: "commit_manifest",
                        artifactKind:
                            "prime_native_decoder_trajectory_commit_manifest_v1",
                        encoding: "canonical_json",
                        publicationOrdinal: 4,
                        required: true,
                        immutableNoReplace: true,
                        independentlyExternallyBound: true,
                        authoritativeBeforeFinalCommit: false),
                ],
                finalCommitManifestPublishedLast: true,
                finalCommitManifestIsExclusiveCommitPoint: true,
                partialPrecommitLeavesAreAuthoritative: false,
                partialPrecommitLeavesMustBeQuarantined: true,
                failedWritePartialStateCanBePromoted: false,
                discoverAndTrustLoadAuthorized: false,
                loadRequiresCallerSuppliedExactCommitBinding: true,
                loadRequiresExactInventoryAndEveryLeafBinding: true,
                inPlaceMutationOrReplacementAuthorized: false,
                retainedCheckpointAuthorized: false,
                artifactUploadAuthorized: false,
                baselineControlRequiredFields: [
                    "role", "global_step", "schedule_id",
                    "current_learning_rate_float32_bits", "rng_domains",
                    "data_cursor", "snapshot_boundary",
                    "checked_evaluation_complete", "accumulation_phase",
                    "pending_gradient_count", "pending_prefetch_count",
                    "kv_cache_entry_count", "decoder_training_mode_true",
                ],
                comparatorControlRequiredFields: [
                    "branch_role", "global_step", "schedule_id",
                    "current_learning_rate_float32_bits", "rng_domains",
                    "terminal_data_cursor", "loss_float32_bits",
                    "per_target_loss_topology_and_sha256",
                    "whole_logits_topology_and_sha256",
                    "raw_gradient_catalog_topology_and_sha256",
                    "clipped_gradient_catalog_topology_and_sha256",
                    "raw_norm_float32_bits", "clipped_norm_float32_bits",
                    "clip_scale_float32_bits",
                    "post_update_parameter_catalog_binding",
                    "optimizer_first_moment_catalog_binding",
                    "optimizer_second_moment_catalog_binding",
                    "checked_evaluation_binding",
                    "checked_evaluation_read_only_nonmutation_binding",
                    "decoder_training_mode_true",
                ],
                baselineIsSoleLoadAuthoritativeResumeSet: true,
                comparatorRoleRejectedAsResumeAuthority: true),
            comparison: .init(
                domains: comparisonDomains,
                exactTensorBytesRequired: true,
                containerByteEqualityAloneSufficient: false,
                ulpToleranceEstablishesExactResume: false,
                measuredExactMismatchIsValidTerminalOutcome: true,
                measuredExactMismatchEstablishesResume: false,
                structuralCatalogDigestAlgorithmID:
                    "prime_stage7_sorted_path_shape_dtype_element_and_byte_count_sha256_v1",
                structuralCatalogDigestPreimageRule:
                    "sha256_of_length_prefixed_utf8_paths_rank_dimensions_dtype_element_count_logical_byte_count_in_sorted_unique_path_order",
                logicalBytesDigestAlgorithmID:
                    "prime_stage7_sorted_path_canonical_logical_tensor_bytes_sha256_v1",
                logicalBytesDigestPreimageRule:
                    "sha256_of_length_prefixed_utf8_path_then_canonical_logical_bytes_in_sorted_unique_path_order",
                topologyDriftClassification:
                    "ABSTAIN_INTEGRITY_after_cleanup_and_release_verifier_not_measured_exact_mismatch",
                evaluationComparisonRequiredPaths: [
                    "loss_float32_bits", "per_target_loss_tensor_shape_1x127_float32",
                    "whole_logits_tensor_shape_1x128x512_float32", "pre_model_catalog_binding",
                    "post_model_catalog_binding",
                    "pre_post_optimizer_catalog_binding",
                    "pre_post_control_binding", "training_mode_restored_true",
                ]),
            resource: .init(
                observedRun123ConfiguredMemoryLimitBytes: 5_010_800_640,
                successorMemoryLimitFormula:
                    "min(UInt64(17179869184),retainedMTLDevice.recommendedMaxWorkingSetSize)",
                successorMemoryLimitSetterCount: 1,
                successorMemoryLimitReadbackCount: 1,
                successorCacheLimitSetterCount: 1,
                successorCacheLimitReadbackCount: 1,
                minimumMemoryLimitFloorBytes: 4_337_713_152,
                configuredCacheLimitBytes: 0,
                observedPeakBytes: 4_790_771_492,
                weightsLogicalBytes: 1_084_428_288,
                optimizerMomentLogicalBytes: 2_168_856_576,
                minimumCommittedTensorStateBytes: 3_253_284_864,
                gradientLogicalBytes: 1_084_428_288,
                minimumStatePlusGradientBytes: 4_337_713_152,
                threeTimesCommittedStateDiskComparatorBytes: 9_759_854_592,
                availableFilesystemFloorBytes: 12_884_901_888,
                projectedStatePlusV2VerificationWeightsBytes: 4_337_713_152,
                rejectedStatePlusEagerMomentReloadBytes: 5_422_141_440,
                ephemeralFourLeafSetCount: 3,
                ephemeralFourLeafSetRoles: [
                    "baseline_checkpoint",
                    "uninterrupted_n_plus_1_comparator",
                    "resumed_n_plus_1_comparator",
                ],
                uninterruptedSuccessorStateRetainedInRAMForComparison:
                    false,
                descriptorBoundStreamingLeafComparisonRequired: true,
                resourceABSTAINAuthorized: true,
                resourceABSTAINEstablishesResume: false,
                ordinaryJobFitEstablished: false,
                sequentialOnePathAtATimeHashAndCompareRequired: true,
                privateComparatorInventoryBoundAndDeletedBeforeReceipt: true,
                predecessorPeakIsStage7PeakBound: false,
                peakResetCountBeforeActiveWork: 1,
                requiredPhaseIDs: [
                    "preflight",
                    "post_initial_model_materialization",
                    "post_baseline_step_and_evaluation",
                    "post_baseline_gradient_release_and_baseline_four_leaf_publication",
                    "post_uninterrupted_successor_step_and_evaluation",
                    "post_uninterrupted_comparator_publication",
                    "post_uninterrupted_state_deallocation_and_cache_clear",
                    "post_fresh_weight_moment_and_control_restore",
                    "post_resumed_successor_step_and_evaluation",
                    "post_resumed_comparator_publication",
                    "post_streaming_compare_artifact_cleanup_and_absence",
                    "postflight",
                ],
                requiredPerPhaseMetricFields: [
                    "cumulative_elapsed_nanoseconds",
                    "physical_memory_capacity_bytes",
                    "task_resident_bytes",
                    "task_physical_footprint_bytes",
                    "getrusage_max_rss_bytes",
                    "mlx_active_bytes",
                    "mlx_cache_bytes",
                    "mlx_peak_bytes",
                    "metal_current_allocated_bytes",
                    "filesystem_fsid",
                    "filesystem_path",
                    "filesystem_capacity_bytes",
                    "filesystem_available_bytes",
                    "verified_configured_memory_limit_copied_from_preflight_bytes",
                    "verified_configured_cache_limit_copied_from_preflight_bytes",
                ],
                requiredCheckedEvalPhaseTargets: [
                    "post_initial_model_materialization:model_parameters",
                    "post_baseline_step_and_evaluation:model_optimizer_evaluation",
                    "post_baseline_gradient_release_and_baseline_four_leaf_publication:model_optimizer_checkpoint_bindings",
                    "post_uninterrupted_successor_step_and_evaluation:model_optimizer_evaluation_and_gradient_evidence",
                    "post_uninterrupted_comparator_publication:model_optimizer_comparator_bindings",
                    "post_fresh_weight_moment_and_control_restore:restored_model_optimizer_control",
                    "post_resumed_successor_step_and_evaluation:model_optimizer_evaluation_and_gradient_evidence",
                    "post_resumed_comparator_publication:model_optimizer_comparator_bindings",
                ],
                measurementAllocatesSecondTensorCatalog: false,
                measurementMutatesOrResetsCumulativePeak: false,
                resourceABSTAINGuardIDs: [
                    "memory_limit_below_minimum_floor",
                    "filesystem_available_below_three_set_floor",
                    "positively_identified_enomem",
                    "positively_identified_enospc",
                    "positively_identified_mlx_memory_limit_exhaustion",
                    "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure",
                ]),
            environment: .init(
                mlxEnableTF32: "0",
                exactMLXRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                exactMLXCheckoutOrigin:
                    "https://github.com/Ergentics/ergentics-mlx-swift",
                swiftPMBuildConfiguration: "release",
                graphCompileMode: "eager_uncompiled_no_compile_transform",
                compileTransformInvocationCount: 0,
                requiredDynamicBindings: [
                    "operating_system_and_build",
                    "xcode_version_and_build",
                    "swift_driver_version",
                    "swift_sdk_version",
                    "staged_metallib_path_byte_count_sha256",
                    "runtime_metallib_path_byte_count_sha256",
                    "metal_device_name_registry_id_unified_memory_max_buffer_and_recommended_working_set",
                    "stream_assignment_and_order",
                    "evaluation_order",
                ],
                metalDeviceCount: 1,
                metalDeviceIndex: 0,
                metalDeviceMustBeDefault: true,
                metalDeviceMustHaveUnifiedMemory: true,
                mlxDeviceMustBeSuppliedDevice: true,
                mlxDefaultStreamMustBeGPU: true,
                cpuFallbackAuthorized: false,
                stagedAndRuntimeMetallibBindingsRequired: true,
                streamAssignmentAndOrderBound: true,
                evaluationOrderBound: true,
                preAndPostDeviceIdentityMustMatch: true,
                preAndPostMLXPolicyAndLimitsMustMatch: true),
            immutableImplementation: .init(
                predecessorRevision: currentMain.revision,
                predecessorTree: currentMain.tree,
                exactBaseSources: implementationSources,
                exactBaseSourceCount: 17,
                validationPackageManifestIsControlledSuccessorMutation: true,
                rootPackageManifestMustRemainByteIdentical: true,
                rootAndValidationLocksMustRemainByteIdentical: true,
                allProductionImplementationSourcesMustRemainByteIdentical:
                    true,
                exactMLXRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                requiredRuntimePrimitiveAPIs: [
                    "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
                    "MLXNN.crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)",
                    "MLXNN.valueAndGrad(model:_:)",
                    "MLXOptimizers.AdamW.update(model:gradients:)",
                    "MLXOptimizers.AdamW.parameters()",
                    "MLXOptimizers.AdamW.update(parameters:matching:)",
                    "checkedEval(_:)",
                    "StreamOrDevice.default.stream.synchronize()",
                    "MLX.Memory.memoryLimit",
                    "MLX.Memory.cacheLimit",
                    "MLX.Memory.activeMemory",
                    "MLX.Memory.cacheMemory",
                    "MLX.Memory.peakMemory",
                    "MLX.Memory.clearCache()",
                    "PrimeNativeDecoderCheckpointCodecV2.writeNative300MByte512(model:to:at:)",
                    "PrimeNativeDecoderCheckpointCodecV2.loadNative300MByte512(expected:from:)",
                    "PrimeMetalDeviceLease.acquire(at:)",
                ],
                receiptCarriesExactImplementationInventory: true,
                implementationDriftBeforeExecutionFailsClosed: true),
            integrity: .init(
                leaseType: "PrimeMetalDeviceLease",
                metalDeviceIndex: 0,
                acquireNonblockingBeforeCoreGraphicsMetalOrMLX: true,
                supervisorOwnsLease: true,
                workerInheritedLeaseDescriptorCount: 0,
                holdThroughCandidateCleanupAndPostflight: true,
                explicitVoidReleaseRequired: true,
                distinctExecVerifierReacquiresAndReleases: true,
                leaseAcquireCount: 2,
                leaseReleaseCount: 2,
                verifierRunsWhileSupervisorAlive: true,
                verifierProofRequiredForPassOrPostAcquisitionAbstain: true,
                persistentLeaseRootMode: "0700",
                persistentLeaseLeafMode: "0600",
                persistentLeaseRootOrLeafRemovalAuthorized: false,
                descriptorDerivedLeaseTupleFields: [
                    "device_id", "inode", "uid", "gid", "mode", "acl",
                    "xattr_names", "security_flags", "file_type",
                    "byte_count", "observed_nlink",
                ],
                descriptorDerivedParentTupleFields: [
                    "physical_path", "device_id", "inode", "uid", "gid",
                    "mode", "acl", "xattr_names", "security_flags",
                    "file_type", "observed_nlink",
                ],
                parentNlinkIsObservationalOnly: true,
                exactLeaseInventoryRequired: true,
                artifactRootStartsPrivateAndEmpty: true,
                unknownArtifactInventoryFailsClosed: true,
                recursiveCleanupAuthorized: false,
                artifactAbsenceProvedBeforeReceipt: true,
                workerEmitsPrivateFramedCandidateOnly: true,
                atMostOneCanonicalPublicReceipt: true,
                publicReceiptIsLastAuthoredFallibleAction: true,
                launcherTrapsClearedBeforeFinalReceipt: true,
                finalReceiptUsesExecUsrBinPrintf: true,
                workerPublicReceiptPrefixCount: 0,
                supervisorPublicReceiptPrefixCount: 0,
                launcherMaximumPublicReceiptPrefixCount: 1,
                publicReceiptClaimsLauncherSuccess: false,
                publicReceiptClaimsOuterWorkflowSuccess: false,
                publicReceiptContainsRawAbsolutePaths: false,
                publicReceiptContainsRawArtifactBytes: false,
                privateCandidateUsesFramedChunkedTransport: true,
                privateCandidateSchemaID:
                    "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_candidate_v1",
                privateTerminalSchemaID:
                    "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_terminal_v1",
                publicReceiptSchemaID:
                    "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_receipt_v1",
                publicReceiptPrefix:
                    "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RECEIPT_V1=",
                publicReceiptMaximumCount: 1,
                publicReceiptPayloadEncoding:
                    "single_line_canonical_sorted_key_json_utf8",
                requiredPrivateCandidateFields: [
                    "schema", "authority_and_predecessor_bindings",
                    "implementation_inventory", "terminal_scientific_status",
                    "one_shot", "environment", "device_and_stream",
                    "operation_counts", "baseline_checkpoint_binding",
                    "uninterrupted_comparator_binding",
                    "resumed_comparator_binding", "comparison_domains",
                    "first_mismatch", "resource_phases",
                    "artifact_inventory_and_cleanup", "raw_private_paths",
                ],
                requiredPrivateTerminalFields: [
                    "schema", "candidate_byte_count", "candidate_sha256",
                    "candidate_status", "first_failed_guard",
                    "lease_acquisition", "cleanup_and_absence",
                    "release_verifier", "supervisor_integrity",
                    "private_raw_descriptor_tuples",
                ],
                requiredPublicReceiptFields: [
                    "schema", "authority_and_exact_main_bindings",
                    "implementation_inventory", "terminal_status",
                    "one_shot_consumed", "candidate_byte_count",
                    "candidate_sha256", "terminal_byte_count",
                    "terminal_sha256", "environment_and_device_bindings",
                    "operation_counts", "comparison_domain_results",
                    "first_mismatch_if_any", "resource_phases",
                    "checkpoint_and_comparator_bindings",
                    "artifact_cleanup_and_absence", "lease_and_verifier",
                    "semantic_path_roles_and_path_sha256",
                ],
                publicPathProjectionRule:
                    "private_raw_absolute_paths_never_projected_publicly_each_required_path_projects_semantic_role_and_sha256_of_utf8_path_metallibs_also_project_byte_count_and_content_sha256_all_nonpath_tuple_and_metric_fields_preserved",
                maximumPublicCanonicalByteCount: 131_072,
                privateCandidateAndTerminalTransportFramesCarryOutOfBandByteCountAndSHA256:
                    true,
                maximumPrivateCandidateCanonicalByteCount: 262_144,
                maximumPrivateTerminalCanonicalByteCount: 65_536,
                framedLengthGrammar:
                    "canonical_unsigned_decimal_no_sign_no_leading_zero_except_zero_then_lf",
                maximumFrameChunkByteCount: 16_384,
                frameReadDeadlineSeconds: 30,
                frameSHA256VerifiedBeforeDecode: true,
                frameEOFAndTrailingByteRejectionRequired: true,
                implementationInventoryEntryFields: [
                    "path_role", "git_mode", "git_blob", "byte_count",
                    "lf_byte_count", "sha256",
                ],
                comparisonDomainResultFields: [
                    "domain_id", "kind", "path_count",
                    "catalog_preimage_schema", "catalog_sha256",
                    "left_total_bytes", "left_sha256", "right_total_bytes",
                    "right_sha256", "exact", "first_mismatch_path",
                    "first_mismatch_expected_binding",
                    "first_mismatch_observed_binding",
                    "tensor_catalog_projection",
                ],
                resourcePhaseRecordFields: [
                    "phase_id", "cumulative_elapsed_nanoseconds",
                    "physical_memory_capacity_bytes", "task_resident_bytes",
                    "task_physical_footprint_bytes", "getrusage_max_rss_bytes",
                    "mlx_active_bytes", "mlx_cache_bytes", "mlx_peak_bytes",
                    "metal_current_allocated_bytes", "filesystem_fsid",
                    "filesystem_semantic_role", "filesystem_path_sha256",
                    "filesystem_capacity_bytes", "filesystem_available_bytes",
                    "verified_configured_memory_limit_copied_from_preflight_bytes",
                    "verified_configured_cache_limit_copied_from_preflight_bytes",
                ],
                checkpointSetBindingFields: [
                    "set_role", "load_authoritative", "commit_schema",
                    "commit_byte_count", "commit_sha256", "leaf_count",
                    "ordered_leaf_roles", "each_leaf_byte_count_and_sha256",
                    "external_v2_binding", "control_schema_and_sha256",
                ],
                publicDescriptorTupleFields: [
                    "semantic_role", "path_sha256", "device_id", "inode",
                    "uid", "gid", "mode", "acl_entry_count",
                    "xattr_names", "security_flags", "file_type",
                    "byte_count", "observed_nlink",
                ],
                tensorCatalogProjectionFields: [
                    "algorithm_id", "sorted_unique_path_count",
                    "shape_dtype_element_and_byte_count_preimage_sha256",
                    "canonical_logical_bytes_preimage_sha256",
                    "total_element_count", "total_logical_byte_count",
                    "first_mismatch_path_if_any",
                ],
                environmentAndDeviceReceiptFields: [
                    "mlx_enable_tf32", "mlx_checkout_origin",
                    "mlx_revision", "swiftpm_configuration", "graph_mode",
                    "compile_transform_count", "os_build", "xcode_build",
                    "swift_driver", "swift_sdk", "staged_metallib_role",
                    "staged_metallib_path_sha256",
                    "staged_metallib_byte_count_and_content_sha256",
                    "runtime_metallib_role", "runtime_metallib_path_sha256",
                    "runtime_metallib_byte_count_and_content_sha256",
                    "metal_name_registry_unified_max_buffer_recommended_set",
                    "mlx_device_and_default_gpu_stream", "stream_order",
                    "evaluation_order", "pre_post_identity_and_policy_equal",
                    "root_and_validation_lock_bindings",
                ],
                operationCountReceiptFields: [
                    "training_step_count", "backward_count",
                    "optimizer_update_count", "dense_b_path_logits_call_count",
                    "token_bounds_validation_count",
                    "token_bounds_checked_eval_count",
                    "token_bounds_gpu_synchronize_count",
                    "token_bounds_host_bool_item_count",
                    "dense_one_hot_matmul_construction_count",
                    "gradient_evidence_capture_count",
                    "gradient_catalog_release_count",
                    "resource_measurement_checked_eval_count",
                    "resource_measurement_synchronize_count",
                    "checked_read_only_evaluation_count",
                    "evaluation_forward_pass_count", "forward_loss_count",
                    "cross_entropy_count", "training_mode_disable_count",
                    "training_mode_restore_count", "v2_weights_write_count",
                    "v2_internal_verification_load_count",
                    "public_restore_load_count",
                    "optimizer_moment_publish_count",
                    "deferred_optimizer_moment_load_count",
                    "leaf_publication_count", "final_commit_publication_count",
                    "model_allocation_and_materialization_count",
                    "optimizer_allocation_count",
                    "typed_optimizer_state_import_count", "worker_process_count",
                    "supervisor_process_count",
                    "release_verifier_process_count",
                    "maximum_public_receipt_count",
                ],
                artifactCleanupReceiptFields: [
                    "initial_inventory_empty", "known_inventory_before_cleanup",
                    "unknown_inventory_count", "deleted_known_leaf_count",
                    "deleted_private_comparator_count",
                    "post_cleanup_inventory_empty", "absence_proved",
                    "recursive_cleanup_used", "artifact_upload_count",
                    "retained_artifact_count",
                ],
                semanticPathProjectionFields: [
                    "semantic_role", "path_sha256", "byte_count",
                    "content_sha256", "raw_absolute_path_present",
                ],
                authorityAndExactMainBindingFields: [
                    "authority_id", "authority_canonical_sha256",
                    "repository", "revision", "tree", "ordered_parents",
                    "workflow_run_id", "workflow_run_number", "run_attempt",
                ],
                firstMismatchReceiptFields: [
                    "availability", "domain_id", "path",
                    "expected_binding", "observed_binding",
                ],
                leaseAndVerifierReceiptFields: [
                    "lease_acquired", "lease_release_count",
                    "verifier_executed", "verifier_exit_zero",
                    "supervisor_alive_during_verifier", "preflight_parent",
                    "post_candidate_parent", "post_candidate_leaf",
                    "verifier_parent", "verifier_leaf", "inventory_exact",
                ],
                semanticPathProjectionCount: 5,
                publicReceiptNestedTypeAndCardinalityRules: [
                    "schema:string",
                    "authority_and_exact_main_bindings:object_exact_fields",
                    "implementation_inventory:array_exactly_17_objects",
                    "terminal_status:string_enum",
                    "one_shot_consumed:boolean_true",
                    "candidate_byte_count:integer_or_null",
                    "candidate_sha256:lowerhex64_or_null",
                    "terminal_byte_count:integer",
                    "terminal_sha256:lowerhex64",
                    "environment_and_device_bindings:object_exact_fields",
                    "operation_counts:object_exact_integer_fields",
                    "comparison_domain_results:array_exactly_18_objects",
                    "first_mismatch_if_any:object_exact_fields",
                    "resource_phases:array_ordered_prefix_zero_through_12_objects",
                    "checkpoint_and_comparator_bindings:array_zero_through_3_objects",
                    "artifact_cleanup_and_absence:object_exact_fields",
                    "lease_and_verifier:object_exact_fields",
                    "semantic_path_roles_and_path_sha256:array_exactly_5_objects",
                ],
                checkpointLeafBindingFields: [
                    "role", "publication_ordinal", "byte_count", "sha256",
                ],
                externalV2BindingFields: [
                    "schema_id", "compatibility_identity_sha256",
                    "artifact_semantic_role", "artifact_path_sha256",
                    "container_byte_count", "container_sha256",
                    "manifest_sha256",
                ],
                filesystemIDFields: ["word0", "word1"],
                lockBindingFields: [
                    "path_role", "git_blob", "byte_count", "sha256",
                ],
                maximumTensorCatalogPathCount: 218,
                pureMaximalReceiptSerializationCeilingTestRequired: true,
                maximalPublicReceiptFixtureCanonicalByteCount: 54_022),
            authorityClosure: .init(
                exactChangedPaths: [
                    path(
                        ".github/scripts/prime-ci-active-root-quarantine.sh",
                        "100755", "active_root_gate"),
                    path(
                        ".github/workflows/prime-active-root-quarantine.yml",
                        "100644", "workflow"),
                    path(
                        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                        "100644", "embedded_provenance"),
                    path(
                        "Sources/PrimeCore/PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthority.swift",
                        "100644", "stage7_authority_source"),
                    path(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityTests.swift",
                        "100644", "stage7_authority_test"),
                ],
                expectedRootTestCount: 62,
                expectedIsolatedGroupTestCounts: [1, 1, 2, 2],
                expectedIsolatedTestCount: 6,
                expectedFocusedWholeTestCount: 68,
                expectedMetalTestCount: 44,
                expectedMaintainedRuntimeTestCount: 1,
                expectedTokenizerTestCount: 1,
                expectedLiveTestCount: 46,
                expectedTotalTestCount: 114,
                reviewedMainTimeoutMinutes: 60,
                launcherInvocationCount: 0,
                mechanicsExecutionCount: 0,
                relevantReceiptCount: 0,
                artifactCount: 0),
            successor: .init(
                exactChangedPaths: [
                    path(
                        ".github/scripts/prime-ci-active-root-quarantine.sh",
                        "100755", "active_root_gate"),
                    path(
                        ".github/scripts/prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution.sh",
                        "100755", "stage7_launcher"),
                    path(
                        ".github/workflows/prime-active-root-quarantine.yml",
                        "100644", "workflow"),
                    path(
                        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                        "100644", "embedded_provenance"),
                    path(
                        "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderNative300MTrajectoryCheckpointV1.swift",
                        "100644", "neutral_trajectory_checkpoint_codec"),
                    path(
                        "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
                        "100644", "stage7_training_execution_and_supervisor"),
                    path(
                        "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                        "100644", "validation_manifest"),
                    path(
                        "Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution/main.swift",
                        "100644", "stage7_executable_main"),
                    path(
                        "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionContractTests.swift",
                        "100644", "stage7_pure_contract_test"),
                ],
                exactChangedPathCount: 9,
                checkpointCodecMomentValueType: "[String: MLXArray]",
                optimizerTypedMappingOwner: "PrimeNativeDecoderTraining",
                rootPackageManifestMutationAuthorized: false,
                rootPackageLockMutationAuthorized: false,
                validationPackageLockMutationAuthorized: false,
                existingMechanicsPayloadMutationAuthorized: false,
                exactMainOnly: true,
                separatelyReviewed: true,
                oneShotOpportunityCount: 1,
                retryAuthorized: false,
                rerunAuthorized: false,
                replacementRunAuthorized: false,
                focusedPureContractTestCount: 1,
                launcherLocalPureContractTestCount: 1,
                directSupervisorProbeCount: 1,
                expectedRootTestCount: 62,
                expectedIsolatedTestCount: 6,
                expectedFocusedWholeTestCount: 69,
                expectedRetainedLiveTestCount: 46,
                expectedTotalXCTestCount: 116,
                reviewedMainTimeoutMinutes: 120,
                checkoutDepth: 1,
                releaseBuildCount: 1,
                focusedContractBuildCount: 1,
                launcherContractUsesSkipBuild: true,
                workerTimeoutSeconds: 4_800,
                supervisorTimeoutSeconds: 5_100,
                terminationGraceSeconds: 10,
                outerWorkflowTimeoutSeconds: 7_200,
                timeoutConsumesOneShotAndNeverRetries: true,
                timeoutReceiptRequiresIntegrityCleanupAndVerifierClosure:
                    true),
            outcomes: .init(
                allowedTerminalStatuses: [
                    "PASS_EXACT",
                    "MEASURED_EXACT_MISMATCH",
                    "ABSTAIN_RESOURCE",
                    "ABSTAIN_INTEGRITY",
                ],
                noPublicReceiptFailureClasses: [
                    "malformed_private_candidate",
                    "unsafe_private_candidate",
                    "canonicalization_failure",
                    "publication_failure",
                    "unknown_artifact_inventory",
                    "lease_unavailable_or_acquisition_failure_after_one_shot_consumption",
                    "release_verifier_integrity_failure",
                ],
                oneShotConsumptionBoundary:
                    "immediately_before_sole_supervisor_invocation_and_before_any_lease_acquisition",
                safeIntegrityAbstainMayEmitPublicReceiptOnlyAfterVerifier:
                    true,
                mechanicsBeginningConsumesOneShot: true,
                everyOutcomeForbidsRetryRerunAndReplacement: true,
                passEstablishesExactRunBPathSameDeviceEphemeralResume: true,
                passCandidateRequiresIntegrityWorkflowObservationAndRetirement:
                    true,
                passCandidateCanSatisfyStage8PrerequisiteOnlyAfterClosure:
                    true,
                passAuthorizesStage8: false,
                measuredMismatchRequiresFirstMismatchDomain: true,
                measuredMismatchRequiresFirstMismatchPath: true,
                measuredMismatchRequiresExpectedAndObservedBindings: true,
                measuredMismatchEstablishesResume: false,
                resourceAbstainEstablishesResume: false,
                integrityAbstainEstablishesResume: false,
                everyOutcomeRequiresAppendOnlyObservationAndRetirement: true,
                resourceAbstainRequiresPositiveAuthorizedGuardProof: true,
                unknownErrorsAndSemanticOrInventoryFailuresAreResource:
                    false,
                measuredMismatchRequiresTwoCompleteValidTrajectories: true,
                completeScientificOutcomeRequiresFullCountsAndAllPhases:
                    true,
                abstainRequiresExactMonotonicOperationAndPhasePrefix: true,
                abstainRequiresFirstFailedOperationOrGuardAndZeroLaterScience:
                    true,
                leaseUnavailableConsumesOneShotPermitsNullBindingsAndEmitsNoPublicReceipt:
                    true),
            ceiling: .init(
                authorityOnlyNoExecutionEvidence: true,
                stage7AuthorityEstablished: true,
                stage7MechanicsAuthorizedAfterGreenClosure: true,
                oneSeparatelyReviewedExactMainStage7OpportunityAuthorized:
                    true,
                processExecutionAuthorizedByThisClosure: false,
                filesystemIOAuthorizedByThisClosure: false,
                mlxImportedByThisClosure: false,
                metalImportedByThisClosure: false,
                modelAllocationAuthorizedByThisClosure: false,
                trainingExecutionAuthorizedByThisClosure: false,
                checkpointReadAuthorizedByThisClosure: false,
                checkpointWriteAuthorizedByThisClosure: false,
                launcherInvocationAuthorizedByThisClosure: false,
                workflowTimeoutMutationAuthorizedByThisClosure: false,
                stage7ExecutionObserved: false,
                native300MTrajectoryResumeEstablished: false,
                generalTrainingResumeEstablished: false,
                durableCheckpointAvailabilityEstablished: false,
                checkpointDurabilityEstablished: false,
                retainedArtifactAuthorized: false,
                artifactUploadAuthorized: false,
                checkpointProvenanceEstablished: false,
                checkpointAdmissionGranted: false,
                additionalExecutionAuthorized: false,
                retryAuthorized: false,
                rerunAuthorized: false,
                broadNative300MTrainingAuthorized: false,
                ordinaryJobFitEstablished: false,
                modelQualityEstablished: false,
                candidateAdmissionGranted: false,
                downstreamTrialAuthorized: false,
                canaryAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false,
                stage8AuthorityEstablished: false,
                stage8Authorized: false),
            orderedRequiredSeparateActions: [
                "merge_and_pass_exact_main_stage7_pure_authority_closure",
                "separately_implement_only_the_frozen_exact_nine_successor",
                "use_exactly_one_exact_main_stage7_opportunity_without_retry_rerun_or_replacement",
                "append_only_observe_and_retire_every_terminal_outcome",
                "obtain_separate_stage8_authority_only_after_a_pass_observation",
            ],
            status:
                "AUTHORIZED_exact5_pure_stage7_authority_then_one_separately_reviewed_exact9_exact_main_opportunity_no_execution_retention_admission_or_stage8_authority")
    }()

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityError
                .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        guard self == expected else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityError
                .contractDrift("frozen authority")
        }

        func isLowercaseHex64(_ value: String) -> Bool {
            value.utf8.count == 64 && value.utf8.allSatisfy { byte in
                (byte >= 48 && byte <= 57) || (byte >= 97 && byte <= 102)
            }
        }

        let prerequisiteTruths = [
            prerequisites.stage5MechanicsSuccessEstablished,
            prerequisites.stage5ResultEstablished,
            prerequisites.stage5AssayClearanceEstablished,
            prerequisites.repeatedSameDeviceBPathDeterminismEstablished,
            prerequisites.exactSameDeviceBPathGradientBytesEstablished,
            prerequisites.bSpecificNative300MResourceWitnessEstablished,
            prerequisites.bSpecificNative300MResourceClearanceEstablished,
            prerequisites.bSpecificNative300MRunnerCapacityEstablished,
            prerequisites.historicalStage6ResourceClearanceRemainsEstablished,
        ]
        let prerequisiteFalseCeilings = [
            prerequisites.historicalStage6ResourceClearanceAppliesToBPath,
            prerequisites.defaultGatherDeterminismEstablished,
            prerequisites.arbitraryTokenDeterminismEstablished,
            prerequisites.crossDeviceDeterminismEstablished,
        ]
        let closureFalseCeilings = [
            ceiling.processExecutionAuthorizedByThisClosure,
            ceiling.filesystemIOAuthorizedByThisClosure,
            ceiling.mlxImportedByThisClosure,
            ceiling.metalImportedByThisClosure,
            ceiling.modelAllocationAuthorizedByThisClosure,
            ceiling.trainingExecutionAuthorizedByThisClosure,
            ceiling.checkpointReadAuthorizedByThisClosure,
            ceiling.checkpointWriteAuthorizedByThisClosure,
            ceiling.launcherInvocationAuthorizedByThisClosure,
            ceiling.workflowTimeoutMutationAuthorizedByThisClosure,
            ceiling.stage7ExecutionObserved,
            ceiling.native300MTrajectoryResumeEstablished,
            ceiling.generalTrainingResumeEstablished,
            ceiling.durableCheckpointAvailabilityEstablished,
            ceiling.checkpointDurabilityEstablished,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.checkpointProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.additionalExecutionAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.broadNative300MTrainingAuthorized,
            ceiling.ordinaryJobFitEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage8AuthorityEstablished,
            ceiling.stage8Authorized,
        ]
        let authorityPaths = authorityClosure.exactChangedPaths
        let successorPaths = successor.exactChangedPaths
        let labeledStructuralChecks: [(String, Bool)] = [
            ("b path reuse scope",
             !bPath.repeatedBatchConsumptionWithinSingleBranchAuthorized
                && bPath.sameSuccessorBatchAcrossAlternateBranchesRequired
                && bPath.evaluationInputReuseWithoutCursorConsumptionAuthorized),
            ("training math", trainingMath.selectedTargetDivisor == 127
                && !trainingMath.adamWUsesBiasCorrection
                && trainingMath.compatibilitySchemaID
                    == "ergentics_prime_native_decoder_checkpoint_compatibility_v2"
                && trainingMath.ropeThetaFloat32BitPattern == 1_176_256_512
                && trainingMath.rmsNormEpsilonFloat32BitPattern == 925_353_388
                && trainingMath.shiftedLogitsShape == [1, 127, 512]
                && trainingMath.shiftedTargetsShape == [1, 127]
                && trainingMath.shiftedCompletionMaskShape == [1, 127]
                && trainingMath.crossEntropyAxis == -1
                && trainingMath.crossEntropyReduction == "none"),
            ("schedule", optimizerAndControl
                .learningRateFloat32BitPatternsAtStepsZeroOneTwo.count == 3),
            ("cursor terminal", dataCursor.terminalNextBatchOrdinal == 2
                && dataCursor.terminalNextRowIDs.isEmpty),
            ("operation topology", operationCounts
                .resourceMeasurementCheckedEvalCount == 8
                && operationCounts.tokenBoundsCheckedEvalCount == 6
                && operationCounts.tokenBoundsGPUSynchronizeCount == 6
                && operationCounts.tokenBoundsHostBoolItemCount == 6
                && operationCounts.denseOneHotMatmulConstructionCount == 6
                && operationCounts.gradientEvidenceCaptureCount == 2
                && operationCounts.gradientCatalogReleaseCount == 3),
            ("checkpoint controls", checkpoint.baselineControlRequiredFields.count
                == 13 && checkpoint.comparatorControlRequiredFields.count == 20),
            ("resource phases", resource.requiredPhaseIDs.count == 12
                && Set(resource.requiredPhaseIDs).count == 12
                && resource.requiredPerPhaseMetricFields.count == 15
                && Set(resource.requiredPerPhaseMetricFields).count == 15
                && resource.peakResetCountBeforeActiveWork == 1),
            ("environment", environment.requiredDynamicBindings.count == 9
                && environment.mlxEnableTF32 == "0"
                && environment.compileTransformInvocationCount == 0
                && environment.metalDeviceCount == 1
                && !environment.cpuFallbackAuthorized),
            ("implementation inventory",
             immutableImplementation.exactBaseSources.count == 17
                && immutableImplementation.requiredRuntimePrimitiveAPIs.count
                    == 17
                && immutableImplementation.exactBaseSources.allSatisfy({
                    $0.gitMode == "100644"
                        && isLowercaseHex64($0.sha256)
                        && $0.gitBlob.utf8.count == 40
                        && $0.byteCount > 0 && $0.lfByteCount > 0
                })),
            ("receipt schema", integrity.requiredPrivateCandidateFields.count
                == 16 && integrity.requiredPrivateTerminalFields.count == 10
                && integrity.requiredPublicReceiptFields.count == 18),
            ("timeouts", successor.workerTimeoutSeconds == 4_800
                && successor.supervisorTimeoutSeconds == 5_100
                && successor.workerTimeoutSeconds
                    < successor.supervisorTimeoutSeconds
                && successor.supervisorTimeoutSeconds
                    < successor.outerWorkflowTimeoutSeconds),
            ("outcome classification",
             outcomes.resourceAbstainRequiresPositiveAuthorizedGuardProof
                && !outcomes
                    .unknownErrorsAndSemanticOrInventoryFailuresAreResource
                && outcomes.measuredMismatchRequiresTwoCompleteValidTrajectories),
        ]
        if let failed = labeledStructuralChecks.first(where: { !$0.1 }) {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityError
                .contractDrift(failed.0)
        }

        guard schemaVersion == 1,
              roadmap.orderedStageIDs.count == 8,
              roadmap.stageOrdinal == 7,
              roadmap.orderedStageIDs[6] == roadmap.stageID,
              roadmap.orderedStageIDs[5]
                == roadmap.requiredPredecessorStageID,
              roadmap.orderedStageIDs[7] == roadmap.successorStageID,
              roadmap.separatelyAuthorizedSuccessorRequired,
              stage5BPass.status == "PASS_CLEARANCE",
              stage5BPass.oneShotConsumed,
              stage5BPass.oneShotExhausted,
              bSpecificNative300MResourcePass.status == "PASS",
              bSpecificNative300MResourcePass.oneShotConsumed,
              bSpecificNative300MResourcePass.oneShotExhausted,
              prerequisiteTruths.allSatisfy({ $0 }),
              prerequisiteFalseCeilings.allSatisfy({ !$0 }),
              !retirementClosure.frozenObservationRetirementObserved,
              retirementClosure.laterRetirementClosureObserved,
              retirementClosure.repository.revision
                == "912ca2ab8148255fa588a2a1d336b9dcb1221978",
              retirementClosure.repository.tree
                == "3f9dbf9abb6df4bd739a9f5c17a3583afdfee9c0",
              retirementClosure.workflowRunNumber == 125,
              retirementClosure.checkSuiteID == 86_443_755_850,
              retirementClosure.activeRootJobConclusion == "success",
              retirementClosure.reviewedMainJobConclusion == "success",
              retirementClosure.artifactCount == 0,
              retirementClosure.retryCount == 0,
              retirementClosure.rerunCount == 0,
              retirementClosure.retiredLauncherAndReceiptCountsAreZero,
              retirementClosure.embeddedSourceIdentitySHA256
                == "1b2290a13d37b147c1e40cbb2e023f03175733c7fb4cf474c48fd482c5921dd9",
              retirementClosure.embeddedSourceIdentityRecordCount == 488,
              retirementClosure.preservedIndexSHA256
                == "535dbd253cc99392ec6abfcb81eac30199d372803f09d107e52dcbb48fc1d497",
              bPath.algorithmID
                == "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1",
              bPath.selectorCase == "denseOneHotMatmulV1",
              bPath.selectorRawValue
                == "flattened_dense_one_hot_matmul_input_embedding_v1",
              bPath.decoderAPI
                == "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
              bPath.packageOnlySurfaceRequired,
              !bPath.publicDecoderAPIAdded,
              bPath.initialModelSeed == 44,
              bPath.exactFixedBatchCount == 2,
              bPath.batchAlgorithmIDs.count == 2,
              bPath.batchGenerationRules.count == 2,
              bPath.batchTokenIDsSHA256.count == 2,
              bPath.batchTokenIDsSHA256.allSatisfy(isLowercaseHex64),
              bPath.completionMaskGenerationRule
                == "rank_two_single_row_array_false_then_127_true_values",
              isLowercaseHex64(bPath.completionMaskSHA256),
              bPath.batchTokenAndMaskSHA256.count == 2,
              bPath.batchTokenAndMaskSHA256.allSatisfy(isLowercaseHex64),
              Set(bPath.batchTokenAndMaskSHA256).count == 2,
              bPath.evaluationBatchOrdinal == 1,
              bPath.evaluationBatchTokenAndMaskSHA256
                == bPath.batchTokenAndMaskSHA256[1],
              !bPath.evaluationConsumesDataCursor,
              bPath.evaluationDecoderAPI == bPath.decoderAPI,
              bPath.evaluationTemporarilySetsTrainingModeFalse,
              bPath.evaluationRestoresPriorTrainingMode,
              !bPath.evaluationUsesKVCache,
              bPath
                .evaluationChecksFullModelOptimizerAndControlNonmutation,
              !bPath.predecessorConfigurationWasTrainingPolicy,
              bPath.explicitlyReauthorizedForThisStage7Opportunity,
              !bPath
                .repeatedBatchConsumptionWithinSingleBranchAuthorized,
              bPath.sameSuccessorBatchAcrossAlternateBranchesRequired,
              bPath.evaluationInputReuseWithoutCursorConsumptionAuthorized,
              trainingMath.compatibilitySchemaID
                == "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
              trainingMath.modelConfigurationFactory
                == "PrimeNativeGQADecoderConfiguration.native300MInventory(vocabularySize:512)",
              trainingMath.ropeThetaFloat32BitPattern == 1_176_256_512,
              trainingMath.rmsNormEpsilonFloat32BitPattern == 925_353_388,
              trainingMath.shiftedLogitsShape == [1, 127, 512],
              trainingMath.shiftedTargetsShape == [1, 127],
              trainingMath.shiftedCompletionMaskShape == [1, 127],
              trainingMath.crossEntropyAxis == -1,
              trainingMath.crossEntropyLabelSmoothingFloat32BitPattern == 0,
              trainingMath.crossEntropyReduction == "none",
              trainingMath.selectedTargetDivisor == 127,
              trainingMath.exactLossBitsAndPerTargetOutputsCaptured,
              trainingMath.perTargetLossEvidenceShape == [1, 127],
              trainingMath.perTargetLossEvidenceDType == "float32",
              trainingMath.perTargetLossEvidenceElementCount == 127,
              trainingMath.wholeLogitsEvidenceRule
                == "whole_logits_tensor_no_subset_before_shift_for_training_and_evaluation",
              trainingMath.wholeLogitsEvidenceShape == [1, 128, 512],
              trainingMath.wholeLogitsEvidenceDType == "float32",
              trainingMath.wholeLogitsEvidenceElementCount == 65_536,
              trainingMath.wholeLogitsEvidenceLogicalByteCount == 262_144,
              trainingMath.valueAndGradClosureReturnsOnlyScalarLoss,
              !trainingMath.adamWUsesBiasCorrection,
              trainingMath.exactPolicyPromotedOnlyForThisStage7Opportunity,
              optimizerAndControl.snapshotGlobalStep == 1,
              optimizerAndControl.terminalGlobalStep == 2,
              optimizerAndControl.scheduleID
                == "constant_float32_learning_rate_v1",
              optimizerAndControl.learningRateFloat32BitPatternsAtStepsZeroOneTwo
                == [953_267_991, 953_267_991, 953_267_991],
              !optimizerAndControl.optimizerHasInternalStepCounter,
              optimizerAndControl.callerOwnsGlobalStep,
              optimizerAndControl.mutableRuntimeLearningRateStateRequired,
              optimizerAndControl.cursorPointsToNextUnconsumedBatchAtSnapshot,
              optimizerAndControl.snapshotNextBatchOrdinal == 1,
              optimizerAndControl.accumulationPhaseAtSnapshot == 0,
              optimizerAndControl.pendingGradientCountAtSnapshot == 0,
              optimizerAndControl.pendingPrefetchCountAtSnapshot == 0,
              optimizerAndControl.kvCacheEntryCountAtSnapshot == 0,
              explicitRNG.algorithmID == "sha256_counter_stream_v1",
              explicitRNG.rootSeed == 44,
              explicitRNG.domains.count == 4,
              Set(explicitRNG.domains.map(\.domainID)).count == 4,
              Set(explicitRNG.domains.map(\.keySHA256)).count == 4,
              explicitRNG.domains.allSatisfy({
                  isLowercaseHex64($0.keySHA256)
                    && isLowercaseHex64($0.snapshotConsumptionSHA256)
                    && isLowercaseHex64($0.terminalConsumptionSHA256)
              }),
              explicitRNG.domainKeysPairwiseDistinct,
              explicitRNG.countersIndependent,
              !explicitRNG.implicitGlobalRandomStateAuthorized,
              !explicitRNG.evaluationConsumesRNG,
              !explicitRNG.augmentationConsumesRNG,
              dataCursor.epochAtSnapshot == 0,
              dataCursor.nextRowIndexAtSnapshot == 1,
              dataCursor.nextRowIDsAtSnapshot == ["stage7_fixed_row_1"],
              isLowercaseHex64(dataCursor.nextRowIDsSHA256),
              dataCursor.terminalEpoch == 1,
              dataCursor.terminalNextBatchOrdinal == 2,
              dataCursor.terminalNextRowIndex == 2,
              dataCursor.terminalNextRowIDs.isEmpty,
              dataCursor.terminalNextRowIDsSHA256
                == "4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945",
              dataCursor.terminalNoNextBatchSHA256
                == "e060fff180d0d64ee23be9ee3a3bbcde166773ad8d207d61f074831258967d7a",
              dataCursor.evaluationCheckedAtSnapshotCurrentStep,
              dataCursor.evaluationCheckedAtEachTerminalCurrentStep,
              dataCursor.batchSize == 1,
              dataCursor.microbatchSize == 1,
              dataCursor.sequenceLength == 128,
              dataCursor.nextBatchTokenAndMaskSHA256
                == bPath.batchTokenAndMaskSHA256[1],
              dataCursor.cursorAdvanceCountPerTrainingStep == 1,
              !dataCursor.evaluationAdvancesCursor,
              trajectory.baselineStepCount == 1,
              trajectory.uninterruptedSuccessorStepCount == 1,
              trajectory.restoredSuccessorStepCount == 1,
              trajectory.totalTrainingStepCount == 3,
              trajectory.totalBackwardCount == 3,
              trajectory.totalOptimizerUpdateCount == 3,
              !trajectory.uninterruptedAndRestoredFullStatesMayOverlap,
              trajectory
                .baselineGradientsReleasedBeforeV2AndMomentPublication,
              trajectory
                .uninterruptedGradientEvidenceCapturedBeforeRelease,
              trajectory
                .uninterruptedGradientsReleasedBeforeComparatorPublication,
              trajectory.restoredGradientEvidenceCapturedBeforeRelease,
              trajectory.restoredGradientsReleasedBeforeComparatorPublication,
              trajectory.restoredDecoderTrainingModeTrueBeforeSuccessor,
              trajectory.decoderTrainingModeTrueAfterEveryEvaluationRestore,
              trajectory.resumedStateDeallocatedBeforeStreamingComparison,
              trajectory.cacheClearedAfterResumedComparatorPublication,
              trajectory.uninterruptedStateDeallocatedBeforeRestore,
              trajectory.cacheClearedBeforeRestore,
              trajectory.v2WriterTransientFreshVerificationModelAccountedFor,
              trajectory
                .optimizerMomentSemanticReloadDeferredUntilAfterDeallocation,
              !trajectory
                .eagerSecondMomentMaterializationDuringPublicationAuthorized,
              trajectory.authoritativeBaselineFourLeafSetRole
                == resource.ephemeralFourLeafSetRoles[0],
              trajectory.privateComparatorFourLeafSetRoles
                == Array(resource.ephemeralFourLeafSetRoles.dropFirst()),
              operationCounts.trainingStepCount == 3,
              operationCounts.backwardCount == 3,
              operationCounts.optimizerUpdateCount == 3,
              operationCounts.denseBPathLogitsCallCount == 6,
              operationCounts.tokenBoundsValidationCount == 6,
              operationCounts.tokenBoundsCheckedEvalCount == 6,
              operationCounts.tokenBoundsGPUSynchronizeCount == 6,
              operationCounts.tokenBoundsHostBoolItemCount == 6,
              operationCounts.denseOneHotMatmulConstructionCount == 6,
              operationCounts.gradientEvidenceCaptureCount == 2,
              operationCounts.gradientCatalogReleaseCount == 3,
              operationCounts.resourceMeasurementCheckedEvalCount == 8,
              operationCounts.resourceMeasurementSynchronizeCount == 12,
              operationCounts.checkedReadOnlyEvaluationCount == 3,
              operationCounts.evaluationForwardPassCount == 3,
              operationCounts.forwardLossCount == 6,
              operationCounts.crossEntropyCount == 6,
              operationCounts.trainingModeDisableCount == 3,
              operationCounts.trainingModeRestoreCount == 3,
              operationCounts.v2WeightsWriteCount == 3,
              operationCounts.v2InternalVerificationLoadCount == 3,
              operationCounts.publicRestoreLoadCount == 1,
              operationCounts.optimizerMomentPublishCount == 3,
              operationCounts.deferredOptimizerMomentLoadCount == 1,
              operationCounts.leafPublicationCount == 12,
              operationCounts.finalCommitPublicationCount == 3,
              operationCounts.modelAllocationAndMaterializationCount == 5,
              operationCounts.optimizerAllocationCount == 2,
              operationCounts.typedOptimizerStateImportCount == 1,
              operationCounts.workerProcessCount == 1,
              operationCounts.supervisorProcessCount == 1,
              operationCounts.releaseVerifierProcessCount == 1,
              operationCounts.maximumPublicReceiptCount == 1,
              checkpoint.leaves.count == 4,
              checkpoint.leaves.map(\.publicationOrdinal) == [1, 2, 3, 4],
              checkpoint.leaves.allSatisfy({
                  $0.required && $0.immutableNoReplace
                    && $0.independentlyExternallyBound
                    && !$0.authoritativeBeforeFinalCommit
              }),
              checkpoint.finalCommitManifestPublishedLast,
              checkpoint.finalCommitManifestIsExclusiveCommitPoint,
              !checkpoint.partialPrecommitLeavesAreAuthoritative,
              checkpoint.partialPrecommitLeavesMustBeQuarantined,
              !checkpoint.failedWritePartialStateCanBePromoted,
              !checkpoint.discoverAndTrustLoadAuthorized,
              checkpoint.loadRequiresCallerSuppliedExactCommitBinding,
              checkpoint.loadRequiresExactInventoryAndEveryLeafBinding,
              !checkpoint.inPlaceMutationOrReplacementAuthorized,
              !checkpoint.retainedCheckpointAuthorized,
              !checkpoint.artifactUploadAuthorized,
              checkpoint.baselineControlRequiredFields.count == 13,
              checkpoint.comparatorControlRequiredFields.count == 20,
              checkpoint.baselineIsSoleLoadAuthoritativeResumeSet,
              checkpoint.comparatorRoleRejectedAsResumeAuthority,
              comparison.domains.count == 18,
              comparison.domains.allSatisfy({
                  guard $0.exactRequired && $0.domainPathComplete,
                        !$0.leftRole.isEmpty, !$0.rightRole.isEmpty,
                        $0.expectedPathCount > 0,
                        !$0.expectedPathSetBinding.isEmpty
                  else {
                      return false
                  }
                  let tensorTopology =
                      $0.kind == "tensor_catalog"
                        || $0.kind == "scalar_and_tensor"
                  return $0.sortedUniquePathsRequired == tensorTopology
                    && $0.shapeDTypeElementAndByteCountRequired
                        == tensorTopology
                    && $0
                        .canonicalLogicalBytesOrFrozenPerPathSHA256Required
                        == tensorTopology
              }),
              comparison.exactTensorBytesRequired,
              !comparison.containerByteEqualityAloneSufficient,
              !comparison.ulpToleranceEstablishesExactResume,
              comparison.measuredExactMismatchIsValidTerminalOutcome,
              !comparison.measuredExactMismatchEstablishesResume,
              comparison.structuralCatalogDigestAlgorithmID
                == "prime_stage7_sorted_path_shape_dtype_element_and_byte_count_sha256_v1",
              comparison.logicalBytesDigestAlgorithmID
                == "prime_stage7_sorted_path_canonical_logical_tensor_bytes_sha256_v1",
              comparison.topologyDriftClassification
                == "ABSTAIN_INTEGRITY_after_cleanup_and_release_verifier_not_measured_exact_mismatch",
              comparison.evaluationComparisonRequiredPaths.count == 8,
              resource.observedPeakBytes
                < resource.observedRun123ConfiguredMemoryLimitBytes,
              resource.successorMemoryLimitSetterCount == 1,
              resource.successorMemoryLimitReadbackCount == 1,
              resource.successorCacheLimitSetterCount == 1,
              resource.successorCacheLimitReadbackCount == 1,
              resource.minimumMemoryLimitFloorBytes
                == resource.minimumStatePlusGradientBytes,
              resource.configuredCacheLimitBytes == 0,
              resource.projectedStatePlusV2VerificationWeightsBytes
                == resource.minimumCommittedTensorStateBytes
                    + resource.weightsLogicalBytes,
              resource.rejectedStatePlusEagerMomentReloadBytes
                == resource.minimumCommittedTensorStateBytes
                    + resource.optimizerMomentLogicalBytes,
              resource.rejectedStatePlusEagerMomentReloadBytes
                > resource.observedRun123ConfiguredMemoryLimitBytes,
              resource.ephemeralFourLeafSetCount == 3,
              resource.ephemeralFourLeafSetRoles.count == 3,
              !resource
                .uninterruptedSuccessorStateRetainedInRAMForComparison,
              resource.descriptorBoundStreamingLeafComparisonRequired,
              resource.resourceABSTAINAuthorized,
              !resource.resourceABSTAINEstablishesResume,
              !resource.ordinaryJobFitEstablished,
              resource.sequentialOnePathAtATimeHashAndCompareRequired,
              !resource.predecessorPeakIsStage7PeakBound,
              resource.peakResetCountBeforeActiveWork == 1,
              resource.requiredPhaseIDs.count == 12,
              Set(resource.requiredPhaseIDs).count == 12,
              resource.requiredPerPhaseMetricFields.count == 15,
              Set(resource.requiredPerPhaseMetricFields).count == 15,
              resource.requiredCheckedEvalPhaseTargets.count == 8,
              !resource.measurementAllocatesSecondTensorCatalog,
              !resource.measurementMutatesOrResetsCumulativePeak,
              resource.resourceABSTAINGuardIDs.count == 6,
              environment.mlxEnableTF32 == "0",
              environment.exactMLXRevision
                == "d37885a278f1c37484a94d0f401a418735e66519",
              environment.exactMLXCheckoutOrigin
                == "https://github.com/Ergentics/ergentics-mlx-swift",
              environment.swiftPMBuildConfiguration == "release",
              environment.compileTransformInvocationCount == 0,
              environment.requiredDynamicBindings.count == 9,
              environment.metalDeviceCount == 1,
              environment.metalDeviceIndex == 0,
              environment.metalDeviceMustBeDefault,
              environment.metalDeviceMustHaveUnifiedMemory,
              environment.mlxDeviceMustBeSuppliedDevice,
              environment.mlxDefaultStreamMustBeGPU,
              !environment.cpuFallbackAuthorized,
              environment.stagedAndRuntimeMetallibBindingsRequired,
              environment.streamAssignmentAndOrderBound,
              environment.evaluationOrderBound,
              environment.preAndPostDeviceIdentityMustMatch,
              environment.preAndPostMLXPolicyAndLimitsMustMatch,
              immutableImplementation.predecessorRevision
                == retirementClosure.repository.revision,
              immutableImplementation.predecessorTree
                == retirementClosure.repository.tree,
              immutableImplementation.exactBaseSourceCount == 17,
              immutableImplementation.exactBaseSources.count == 17,
              Set(immutableImplementation.exactBaseSources.map(\.path)).count
                == 17,
              immutableImplementation.exactBaseSources.allSatisfy({
                  $0.gitMode == "100644"
                    && isLowercaseHex64($0.sha256)
                    && $0.gitBlob.utf8.count == 40
                    && $0.byteCount > 0 && $0.lfByteCount > 0
              }),
              immutableImplementation
                .validationPackageManifestIsControlledSuccessorMutation,
              immutableImplementation
                .rootPackageManifestMustRemainByteIdentical,
              immutableImplementation
                .rootAndValidationLocksMustRemainByteIdentical,
              immutableImplementation
                .allProductionImplementationSourcesMustRemainByteIdentical,
              immutableImplementation.exactMLXRevision
                == environment.exactMLXRevision,
              immutableImplementation.requiredRuntimePrimitiveAPIs.count
                == 17,
              immutableImplementation.receiptCarriesExactImplementationInventory,
              immutableImplementation.implementationDriftBeforeExecutionFailsClosed,
              integrity.workerInheritedLeaseDescriptorCount == 0,
              integrity.leaseAcquireCount == 2,
              integrity.leaseReleaseCount == 2,
              integrity.verifierRunsWhileSupervisorAlive,
              integrity.verifierProofRequiredForPassOrPostAcquisitionAbstain,
              !integrity.persistentLeaseRootOrLeafRemovalAuthorized,
              integrity.descriptorDerivedLeaseTupleFields.count == 11,
              integrity.descriptorDerivedParentTupleFields.count == 11,
              integrity.parentNlinkIsObservationalOnly,
              integrity.exactLeaseInventoryRequired,
              !integrity.recursiveCleanupAuthorized,
              integrity.artifactAbsenceProvedBeforeReceipt,
              integrity.atMostOneCanonicalPublicReceipt,
              integrity.publicReceiptIsLastAuthoredFallibleAction,
              integrity.launcherTrapsClearedBeforeFinalReceipt,
              integrity.finalReceiptUsesExecUsrBinPrintf,
              integrity.workerPublicReceiptPrefixCount == 0,
              integrity.supervisorPublicReceiptPrefixCount == 0,
              integrity.launcherMaximumPublicReceiptPrefixCount == 1,
              !integrity.publicReceiptClaimsLauncherSuccess,
              !integrity.publicReceiptClaimsOuterWorkflowSuccess,
              !integrity.publicReceiptContainsRawAbsolutePaths,
              !integrity.publicReceiptContainsRawArtifactBytes,
              integrity.privateCandidateUsesFramedChunkedTransport,
              integrity.publicReceiptMaximumCount == 1,
              integrity.publicReceiptPayloadEncoding
                == "single_line_canonical_sorted_key_json_utf8",
              integrity.requiredPrivateCandidateFields.count == 16,
              integrity.requiredPrivateTerminalFields.count == 10,
              integrity.requiredPublicReceiptFields.count == 18,
              integrity.maximumPublicCanonicalByteCount == 131_072,
              integrity
                .privateCandidateAndTerminalTransportFramesCarryOutOfBandByteCountAndSHA256,
              integrity.maximumPrivateCandidateCanonicalByteCount == 262_144,
              integrity.maximumPrivateTerminalCanonicalByteCount == 65_536,
              integrity.maximumFrameChunkByteCount == 16_384,
              integrity.frameReadDeadlineSeconds == 30,
              integrity.frameSHA256VerifiedBeforeDecode,
              integrity.frameEOFAndTrailingByteRejectionRequired,
              integrity.implementationInventoryEntryFields.count == 6,
              integrity.comparisonDomainResultFields.count == 14,
              integrity.resourcePhaseRecordFields.count == 17,
              integrity.checkpointSetBindingFields.count == 10,
              integrity.publicDescriptorTupleFields.count == 13,
              integrity.tensorCatalogProjectionFields.count == 7,
              Set(integrity.environmentAndDeviceReceiptFields).count
                == integrity.environmentAndDeviceReceiptFields.count,
              Set(integrity.operationCountReceiptFields).count
                == integrity.operationCountReceiptFields.count,
              Set(integrity.artifactCleanupReceiptFields).count
                == integrity.artifactCleanupReceiptFields.count,
              Set(integrity.semanticPathProjectionFields).count
                == integrity.semanticPathProjectionFields.count,
              integrity.authorityAndExactMainBindingFields.count == 9,
              integrity.firstMismatchReceiptFields.count == 5,
              integrity.leaseAndVerifierReceiptFields.count == 11,
              integrity.semanticPathProjectionCount == 5,
              integrity.publicReceiptNestedTypeAndCardinalityRules.count
                == integrity.requiredPublicReceiptFields.count,
              integrity.checkpointLeafBindingFields.count == 4,
              integrity.externalV2BindingFields.count == 7,
              integrity.filesystemIDFields == ["word0", "word1"],
              integrity.lockBindingFields.count == 4,
              integrity.maximumTensorCatalogPathCount == 218,
              integrity.pureMaximalReceiptSerializationCeilingTestRequired,
              integrity.maximalPublicReceiptFixtureCanonicalByteCount
                == 54_022,
              authorityPaths.count == 5,
              Set(authorityPaths.map(\.path)).count == 5,
              authorityPaths.map(\.gitMode)
                == ["100755", "100644", "100644", "100644", "100644"],
              authorityClosure.expectedRootTestCount == 62,
              authorityClosure.expectedIsolatedGroupTestCounts == [1, 1, 2, 2],
              authorityClosure.expectedIsolatedTestCount == 6,
              authorityClosure.expectedFocusedWholeTestCount == 68,
              authorityClosure.expectedLiveTestCount == 46,
              authorityClosure.expectedTotalTestCount == 114,
              authorityClosure.expectedFocusedWholeTestCount
                == authorityClosure.expectedRootTestCount
                    + authorityClosure.expectedIsolatedTestCount,
              authorityClosure.expectedLiveTestCount
                == authorityClosure.expectedMetalTestCount
                    + authorityClosure.expectedMaintainedRuntimeTestCount
                    + authorityClosure.expectedTokenizerTestCount,
              authorityClosure.expectedTotalTestCount
                == authorityClosure.expectedFocusedWholeTestCount
                    + authorityClosure.expectedLiveTestCount,
              authorityClosure.reviewedMainTimeoutMinutes == 60,
              authorityClosure.launcherInvocationCount == 0,
              authorityClosure.mechanicsExecutionCount == 0,
              authorityClosure.relevantReceiptCount == 0,
              authorityClosure.artifactCount == 0,
              successorPaths.count == successor.exactChangedPathCount,
              successorPaths.count == 9,
              Set(successorPaths.map(\.path)).count == 9,
              successor.checkpointCodecMomentValueType == "[String: MLXArray]",
              successor.optimizerTypedMappingOwner
                == "PrimeNativeDecoderTraining",
              !successor.rootPackageManifestMutationAuthorized,
              !successor.rootPackageLockMutationAuthorized,
              !successor.validationPackageLockMutationAuthorized,
              !successor.existingMechanicsPayloadMutationAuthorized,
              successor.exactMainOnly,
              successor.separatelyReviewed,
              successor.oneShotOpportunityCount == 1,
              !successor.retryAuthorized,
              !successor.rerunAuthorized,
              !successor.replacementRunAuthorized,
              successor.expectedFocusedWholeTestCount == 69,
              successor.expectedTotalXCTestCount == 116,
              successor.reviewedMainTimeoutMinutes == 120,
              successor.checkoutDepth == 1,
              successor.workerTimeoutSeconds == 4_800,
              successor.supervisorTimeoutSeconds == 5_100,
              successor.terminationGraceSeconds == 10,
              successor.supervisorTimeoutSeconds
                < successor.outerWorkflowTimeoutSeconds,
              successor.workerTimeoutSeconds
                < successor.supervisorTimeoutSeconds,
              successor.timeoutConsumesOneShotAndNeverRetries,
              successor
                .timeoutReceiptRequiresIntegrityCleanupAndVerifierClosure,
              outcomes.allowedTerminalStatuses
                == [
                    "PASS_EXACT", "MEASURED_EXACT_MISMATCH", "ABSTAIN_RESOURCE",
                    "ABSTAIN_INTEGRITY",
                ],
              outcomes.noPublicReceiptFailureClasses.count == 7,
              outcomes.oneShotConsumptionBoundary
                == "immediately_before_sole_supervisor_invocation_and_before_any_lease_acquisition",
              outcomes
                .safeIntegrityAbstainMayEmitPublicReceiptOnlyAfterVerifier,
              outcomes.mechanicsBeginningConsumesOneShot,
              outcomes.everyOutcomeForbidsRetryRerunAndReplacement,
              outcomes.passEstablishesExactRunBPathSameDeviceEphemeralResume,
              outcomes
                .passCandidateRequiresIntegrityWorkflowObservationAndRetirement,
              outcomes
                .passCandidateCanSatisfyStage8PrerequisiteOnlyAfterClosure,
              !outcomes.passAuthorizesStage8,
              outcomes.measuredMismatchRequiresFirstMismatchDomain,
              outcomes.measuredMismatchRequiresFirstMismatchPath,
              outcomes
                .measuredMismatchRequiresExpectedAndObservedBindings,
              !outcomes.measuredMismatchEstablishesResume,
              !outcomes.resourceAbstainEstablishesResume,
                !outcomes.integrityAbstainEstablishesResume,
                outcomes.everyOutcomeRequiresAppendOnlyObservationAndRetirement,
              outcomes.resourceAbstainRequiresPositiveAuthorizedGuardProof,
                !outcomes
                    .unknownErrorsAndSemanticOrInventoryFailuresAreResource,
              outcomes.measuredMismatchRequiresTwoCompleteValidTrajectories,
              outcomes.completeScientificOutcomeRequiresFullCountsAndAllPhases,
              outcomes.abstainRequiresExactMonotonicOperationAndPhasePrefix,
              outcomes
                .abstainRequiresFirstFailedOperationOrGuardAndZeroLaterScience,
              outcomes
                .leaseUnavailableConsumesOneShotPermitsNullBindingsAndEmitsNoPublicReceipt,
                ceiling.authorityOnlyNoExecutionEvidence,
              ceiling.stage7AuthorityEstablished,
              ceiling.stage7MechanicsAuthorizedAfterGreenClosure,
              ceiling
                .oneSeparatelyReviewedExactMainStage7OpportunityAuthorized,
              closureFalseCeilings.allSatisfy({ !$0 }),
              orderedRequiredSeparateActions.count == 5,
              status.hasPrefix("AUTHORIZED_exact5_pure_stage7_authority")
        else {
            throw PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityError
                .contractDrift("semantic invariant")
        }
    }
}
