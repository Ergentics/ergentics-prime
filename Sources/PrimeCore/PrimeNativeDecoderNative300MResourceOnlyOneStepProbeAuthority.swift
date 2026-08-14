// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityError:
    Error, Equatable, Sendable
{
    case contractDrift(String)
}

public struct PrimeNativeDecoderNative300MResourceProbeSourceIdentityV1:
    Codable, Equatable, Sendable
{
    public let path: String
    public let mode: String
    public let gitBlob: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
    public let role: String
}

public struct PrimeNativeDecoderNative300MResourceProbeRepositoryV1:
    Codable, Equatable, Sendable
{
    public let repository: String
    public let ref: String
    public let authorityBaseRevision: String
    public let authorityBaseTree: String
    public let authorityBaseOrderedParents: [String]
    public let retirementPullRequestNumber: Int
    public let retirementReviewedHeadRevision: String
    public let authorityBaseIsExactTerminalStage5RetirementMain: Bool
    public let authorityClosureExactChangedPaths: [String]
    public let authorityClosurePreservedIndexSHA256: String
    public let authoritySourceAndTestAreOnlyNewPaths: Bool
    public let baseSourceBindings:
        [PrimeNativeDecoderNative300MResourceProbeSourceIdentityV1]
}

public struct PrimeNativeDecoderNative300MResourceProbeRoadmapV1:
    Codable, Equatable, Sendable
{
    public let designAuthorityID: String
    public let designAuthorityCanonicalSHA256: String
    public let designAuthoritySourceGitBlob: String
    public let designAuthorityTestGitBlob: String
    public let stageID: String
    public let objective: String
    public let requiredPredecessorStageID: String
    public let predecessorStageLifecycleCompleted: Bool
    public let predecessorResultEstablished: Bool
    public let predecessorAssayClearanceEstablished: Bool
    public let nextStageID: String
    public let nextStageObjective: String
    public let nextStageRequiresAssayAndResourceClearance: Bool
    public let nextStageAuthorizedByThisAuthority: Bool
    public let separatelyAuthorizedSuccessorRequired: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbeStage5FailureV1:
    Codable, Equatable, Sendable
{
    public let observationID: String
    public let observationCanonicalSHA256: String
    public let observationSourceGitBlob: String
    public let observationSourceSHA256: String
    public let observationTestGitBlob: String
    public let observationTestSHA256: String
    public let mechanicsMergeRevision: String
    public let mechanicsMergeTree: String
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let workflowRunAttempt: Int
    public let checkSuiteID: Int
    public let activeJobID: Int
    public let reviewedJobID: Int
    public let activeJobConclusion: String
    public let reviewedJobConclusion: String
    public let stage5LauncherInvocationCount: Int
    public let stage5DirectXCTestInvocationCount: Int
    public let stage5TestPassCount: Int
    public let stage5TestFailureCount: Int
    public let stage5TestSkipCount: Int
    public let exactThrownError: String
    public let combinedGuardConjunctCount: Int
    public let failingConjunctIdentified: Bool
    public let failingTrialOrdinalEstablished: Bool
    public let priorCompletedTrialCountMinimum: Int
    public let priorCompletedTrialCountMaximum: Int
    public let stage5ReceiptCount: Int
    public let stage5MechanicsExecuted: Bool
    public let oneShotExecutionConsumed: Bool
    public let oneShotExecutionExhausted: Bool
    public let stage5ResultEstablished: Bool
    public let stage5MechanicsSuccessEstablished: Bool
    public let repeatedTrajectoryDeterminismEstablished: Bool
    public let exactMetalGradientBytesEstablished: Bool
    public let metalDeterminismEstablished: Bool
    public let replacementStage5ExecutionAuthorized: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbeRetirementRunV1:
    Codable, Equatable, Sendable
{
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let reviewedHeadRevision: String
    public let pullRequestNumber: Int
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let workflowRunAttempt: Int
    public let checkSuiteID: Int
    public let event: String
    public let headBranch: String
    public let headRevision: String
    public let status: String
    public let conclusion: String
    public let previousAttemptURLWasNull: Bool
    public let exactHeadPushRunCount: Int
    public let rerunCount: Int
    public let artifactCount: Int
    public let activeJobID: Int
    public let activeRunnerImage: String
    public let activeJobConclusion: String
    public let reviewedJobID: Int
    public let reviewedRunnerImage: String
    public let reviewedJobConclusion: String
    public let rootTestCount: Int
    public let isolatedGroupTestCounts: [Int]
    public let isolatedTestCount: Int
    public let focusedWholeTestCount: Int
    public let metalTestCount: Int
    public let maintainedRuntimeTestCount: Int
    public let maintainedRuntimeReceiptCount: Int
    public let tokenizerTestCount: Int
    public let tokenizerReceiptCount: Int
    public let totalTestCount: Int
    public let depthOneCheckoutCount: Int
    public let liveExecutionOrder: [String]
    public let stage4LauncherInvocationCount: Int
    public let stage5LauncherInvocationCount: Int
    public let stage5ReceiptCount: Int
    public let stage6LauncherInvocationCount: Int
    public let stage6ReceiptCount: Int
    public let workflowAuthoredRetryCount: Int
    public let gitInternalRetryCount: Int
    public let tlsFailureCount: Int
    public let tlsVerificationBypassCount: Int
    public let customCAInstallationCount: Int
    public let stage5InvocationRetired: Bool
    public let stage5LauncherPreservedForAudit: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbeConfigurationV1:
    Codable, Equatable, Sendable
{
    public let compatibilitySchemaID: String
    public let modelModule: String
    public let modelConfigurationType: String
    public let modelConfigurationFactory: String
    public let modelType: String
    public let modelFactory: String
    public let vocabularySize: Int
    public let tokenizerID: String
    public let tokenizerManifestSHA256: String
    public let modelWidth: Int
    public let layerCount: Int
    public let queryHeadCount: Int
    public let keyValueHeadCount: Int
    public let headWidth: Int
    public let intermediateWidth: Int
    public let maximumSequenceLength: Int
    public let ropeThetaFloat32BitPattern: UInt32
    public let rmsNormEpsilonFloat32BitPattern: UInt32
    public let parameterPathCount: Int
    public let uniqueParameterCount: UInt64
    public let logicalFP32ParameterByteCount: UInt64
    public let initializationSeed: UInt64
    public let batchSize: Int
    public let sequenceLength: Int
    public let validTokenCount: Int
    public let gradientAccumulationCount: Int
    public let optimizerStepCount: Int
    public let tokenAlgorithmID: String
    public let batchTokenIDs: [[Int]]
    public let batchCompletionMask: [[Bool]]
    public let selectedTargetCount: Int
    public let lossGraphAlgorithmID: String
    public let tokenIDStorageDType: String
    public let completionMaskStorageDType: String
    public let trainingLogitsAPI: String
    public let trainingLogitsInvocationCount: Int
    public let trainingLogitsExpectedShape: [Int]
    public let trainingLogitsDType: String
    public let trainingLogitsUsesCausalAttentionMask: Bool
    public let trainingLogitsKVCacheAllocationCount: Int
    public let shiftedLogitsSlice: String
    public let shiftedTargetsSlice: String
    public let shiftedCompletionMaskSlice: String
    public let shiftedLogitsExpectedShape: [Int]
    public let shiftedTargetsExpectedShape: [Int]
    public let shiftedCompletionMaskExpectedShape: [Int]
    public let shiftedCompletionMaskAllTrue: Bool
    public let crossEntropyAPI: String
    public let crossEntropyWeights: String
    public let crossEntropyAxis: Int
    public let crossEntropyLabelSmoothingFloat32BitPattern: UInt32
    public let crossEntropyReduction: String
    public let perTargetLossDType: String
    public let perTargetLossExpectedShape: [Int]
    public let perTargetLossExpectedElementCount: Int
    public let perTargetLossAllElementsSelectedByShiftedMask: Bool
    public let perTargetLossShapeAndDTypeValidatedInsideValueAndGradClosureBeforeReduction:
        Bool
    public let lossReductionFormula: String
    public let lossDType: String
    public let lossExpectedRank: Int
    public let valueAndGradAPI: String
    public let valueAndGradClosureArguments: [String]
    public let valueAndGradClosureReturnsOnlyScalarLoss: Bool
    public let independentOrDetachedLossAuthorized: Bool
    public let learningRateFloat32BitPattern: UInt32
    public let beta1Float32BitPattern: UInt32
    public let beta2Float32BitPattern: UInt32
    public let epsilonFloat32BitPattern: UInt32
    public let weightDecayFloat32BitPattern: UInt32
    public let maximumGradientNormFloat32BitPattern: UInt32
    public let gradientNormEpsilonFloat32BitPattern: UInt32
    public let parameterDType: String
    public let optimizerQualifiedType: String
    public let optimizerStateInspectionAPI: String
    public let optimizerStatePairTopology: String
    public let optimizerStateExpectedArrayCount: Int
    public let optimizerStateExpectedPairCount: Int
    public let optimizerNamedStateExportDuringProbeAuthorized: Bool
    public let optimizerStateMustBeEmptyBeforeUpdate: Bool
    public let optimizerStateAdjacentPairsSameShapeAndFloat32Required: Bool
    public let optimizerStateParityElementCountEach: UInt64
    public let optimizerStateParityLogicalByteCountEach: UInt64
    public let optimizerStatePairShapeMultisetMustEqualModelParameterShapeMultiset:
        Bool
    public let optimizerStatePerPathMomentNamingEstablished: Bool
    public let postUpdateFullStateEvaluationAPI: String
    public let postModelFullStateEvaluationAPI: String
    public let postUpdateFullStateEvaluationIncludes218ModelAnd436OptimizerArrays:
        Bool
    public let adamWBiasCorrectionApplied: Bool
    public let gradientClippingMode: String
    public let gradientCatalogOrdering: String
    public let expectedGradientPathCount: Int
    public let rawGradientNormAlgorithmID: String
    public let rawGradientNormFormula: String
    public let rawGradientNormAccumulatorDType: String
    public let gradientNormEpsilonInsideNorm: Bool
    public let gradientClipAlgorithmID: String
    public let gradientClipThresholdFloat32BitPattern: UInt32
    public let gradientClipEpsilonFloat32BitPattern: UInt32
    public let gradientClipComparison: String
    public let gradientClipScaleFormula: String
    public let gradientClipScaleHostDType: String
    public let gradientClipApplication: String
    public let gradientClipApplicationCount: Int
    public let gradientClipOccursExactlyOnceBeforeAdamW: Bool
    public let adamWConsumesOnlyClippedGradientCatalog: Bool
    public let parameterFingerprintAlgorithmID: String
    public let parameterFingerprintCatalogOrdering: String
    public let parameterFingerprintSampleIndexRule: String
    public let parameterFingerprintIntegerEncoding: String
    public let parameterFingerprintFloatEncoding: String
    public let parameterFingerprintHash: String
    public let parameterFingerprintExpectedPathCount: Int
    public let parameterFingerprintSamplesPerPath: Int
    public let parameterFingerprintExpectedSampleCount: Int
    public let parameterFingerprintRequiresEveryTensorElementCountAtLeastThree:
        Bool
    public let parameterFingerprintRejectsEmptyOrDuplicatePaths: Bool
    public let parameterFingerprintFullTensorHostCopyAuthorized: Bool
    public let parameterFingerprintHashStreamRule: String
    public let parameterFingerprintSamplePlanHashOmitsValueBitsOnly: Bool
    public let paddingAuthorized: Bool
    public let kvCacheAuthorized: Bool
    public let modelQualityOrReadOnlyEvaluationAuthorized: Bool
    public let generationAuthorized: Bool
    public let checkpointAuthorized: Bool
    public let configurationIsResourceProbeOnlyNotTrainingPolicy: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbeResourceEnvelopeV1:
    Codable, Equatable, Sendable
{
    public let weightsLogicalByteCount: UInt64
    public let optimizerMomentTensorCount: Int
    public let optimizerMomentLogicalByteCount: UInt64
    public let minimumCommittedTensorStateByteCount: UInt64
    public let gradientLogicalByteCount: UInt64
    public let minimumStatePlusGradientByteCount: UInt64
    public let threeTimesCommittedStateDiskComparatorByteCount: UInt64
    public let containerHeadersAndManifestsIncludedInMinimum: Bool
    public let duplicateMaterializationsGraphsAndTemporaryBuffersIncluded: Bool
    public let seed43ObservedWeightsContainerByteCount: UInt64
    public let seed43ObservedLiveStepDurationSeconds: Int
    public let seed43ObservedAvailableFilesystemBytesAfterBuild: UInt64
    public let seed43RunnerMemoryCapacityRecorded: Bool
    public let native300MOneStepFitsCurrentReviewedJobEstablished: Bool
    public let native300MOneStepFitsObservedMemoryEstablished: Bool
    public let configuredMLXMemoryLimitMaximumByteCount: UInt64
    public let configuredMLXMemoryLimitFormula: String
    public let configuredMLXMemoryLimitRecommendedWorkingSetSource: String
    public let recommendedMaxWorkingSetSizeMustBePositive: Bool
    public let configuredMLXMemoryLimitUInt64ToIntConversionOverflowChecked:
        Bool
    public let receiptConfiguredMemoryLimitMustEqualRetainedDeviceFormula:
        Bool
    public let configuredMLXMemoryLimitSetter: String
    public let configuredMLXMemoryLimitSetCount: Int
    public let configuredMLXMemoryLimitReadbackRequired: Bool
    public let configuredMLXMemoryLimitReadbackMustEqualFormulaResult: Bool
    public let configuredMLXMemoryLimitReceiptBindingRequired: Bool
    public let configuredMLXCacheLimitByteCount: UInt64
    public let configuredMLXCacheLimitSetter: String
    public let configuredMLXCacheLimitSetCount: Int
    public let configuredMLXCacheLimitReadbackRequired: Bool
    public let postDeallocationClearCacheCount: Int
    public let minimumConfiguredMLXMemoryLimitByteCount: UInt64
    public let preflightAbstainWhenConfiguredMLXMemoryLimitBelowMinimum: Bool
    public let minimumAvailableFilesystemByteCount: UInt64
    public let preflightAbstainWhenAvailableFilesystemBelowMinimum: Bool
    public let mlxLimitIsNotProcessRSSLimit: Bool
    public let statfsIsObservationNotCheckpointDiskSufficiencyClaim: Bool
    public let separateResourceOnlyProbeRequired: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbeEnvironmentV1:
    Codable, Equatable, Sendable
{
    public let requiredBindings: [String]
    public let mlxEnableTF32: String
    public let exactMLXRevision: String
    public let runtimeMetallibFilename: String
    public let runtimeMetallibDiscoveryAndStagingPathRule: String
    public let runtimeMetallibCandidateCount: Int
    public let runtimeMetallibPathByteCountAndSHA256ReceiptBindingsRequired:
        Bool
    public let runtimeMetallibRetained: Bool
    public let runtimeMetallibUploaded: Bool
    public let metalDeviceIndex: Int
    public let exactMetalDeviceCount: Int
    public let singletonDeviceEnumerationRequired: Bool
    public let indexZeroMustMatchDefaultDevice: Bool
    public let exclusiveMetalDeviceLeaseRequired: Bool
    public let leaseType: String
    public let leaseModule: String
    public let leaseAcquisitionMode: String
    public let workerIsSoleAcquirerAndOwnerWhenAcquired: Bool
    public let kernelReleasesWorkerLeaseOnFatalTermination: Bool
    public let swiftPMBuildConfiguration: String
    public let mlxGraphCompileMode: String
    public let mlxCompileTransformInvocationCount: Int
    public let mlxExecutionDeviceConstruction: String
    public let mlxExecutionDeviceType: String
    public let mlxExecutionDeviceConstructorIndex: Int
    public let mlxDeviceIndexEvidence: String
    public let mlxDeviceIndexRuntimeReadbackAvailable: Bool
    public let mlxDeviceEqualityNotUsedForIdentity: Bool
    public let mlxDeviceTypeObservationAPI: String
    public let mlxDefaultDeviceScopeAPI: String
    public let mlxDefaultDeviceObjectIdentityAPI: String
    public let mlxDefaultDeviceObjectIdentityRequired: Bool
    public let mlxDefaultGPUStreamRequired: Bool
    public let mlxDefaultGPUStreamObservationAPI: String
    public let mlxCPUFallbackAuthorized: Bool
    public let mlxExecutionScopeCoversModelAllocationThroughLexicalDeallocation:
        Bool
    public let mlxGPUIndexEqualsMetalDeviceIndexRequired: Bool
    public let activeCheckoutDepth: Int
    public let reviewedCheckoutDepth: Int
    public let authorityClosureActiveJobTimeoutMinutes: Int
    public let authorityClosureReviewedJobTimeoutMinutes: Int
    public let authorityClosureWorkflowTimeoutMutationAuthorized: Bool
    public let successorActiveJobTimeoutMinutes: Int
    public let successorReviewedJobTimeoutMinutes: Int
    public let successorReviewedWorkflowTimeoutMutationAuthorized: Bool
    public let secureFetchMutationAuthorized: Bool
    public let memorySourceRepository: String
    public let memorySourceRevision: String
    public let memorySourcePath: String
    public let memorySourceMode: String
    public let memorySourceGitBlob: String
    public let memorySourceByteCount: Int
    public let memorySourceLFByteCount: Int
    public let memorySourceSHA256: String
    public let optimizerSourceRepository: String
    public let optimizerSourceRevision: String
    public let optimizerSourcePath: String
    public let optimizerSourceMode: String
    public let optimizerSourceGitBlob: String
    public let optimizerSourceByteCount: Int
    public let optimizerSourceLFByteCount: Int
    public let optimizerSourceSHA256: String
    public let mlxPeakMemoryResetBeforeProbeRequired: Bool
    public let mlxPeakMemoryResetAPI: String
    public let mlxPeakMemoryResetCount: Int
    public let mlxPeakMemoryResetOrder: String
    public let physicalMemoryCapacityObservationRequired: Bool
    public let darwinTaskResidentAndPhysicalFootprintObservationRequired: Bool
    public let getrusageMaxRSSObservationRequired: Bool
    public let mlxActiveCacheAndPeakBytesObservationRequired: Bool
    public let filesystemCapacityAndAvailableBytesObservationRequired: Bool
    public let filesystemObservationTarget: String
    public let filesystemObservationUsesStatFS: Bool
    public let filesystemObservationRequiresScratchAndExecutableSameFSID: Bool
    public let filesystemObservationFSIDEncoding: String
    public let filesystemResolvedTargetPathRule: String
    public let filesystemTargetPathValidationRule: String
    public let filesystemExecutableAndParentStatFSRule: String
    public let filesystemResolutionOrFSIDDriftClassification: String
    public let cumulativeWorkerProbeElapsedObservationRequired: Bool
    public let requiredMetricKeysAtEveryCompletedBoundary: [String]
    public let physicalMemoryMetricSource: String
    public let darwinTaskMetricSource: String
    public let getrusageMetricSource: String
    public let mlxMemoryMetricSource: String
    public let filesystemMetricFormula: String
    public let cumulativeElapsedMetricSource: String
    public let overflowCheckedMetricConversionsRequired: Bool
    public let metalCurrentAllocatedSizeObservationRequired: Bool
    public let metalCurrentAllocatedSizeMetricSource: String
    public let metalCurrentAllocatedSizeUsesRetainedSingletonDeviceRequired:
        Bool
    public let metalDeviceHasUnifiedMemoryRequired: Bool
    public let metalDeviceNameRegistryUnifiedMemoryRecommendedAndBufferBindingsRequired:
        Bool
    public let successfulLeaseAcquisitionPrecedesCoreGraphicsMetalOrMLX: Bool
    public let passLeaseHeldThroughCandidateFlushAndPostflight: Bool
    public let postAcquisitionFatalRequiresChildTerminationThenSupervisorReacquireReleaseProof:
        Bool
    public let leaseBusyRequiresAcquiredFalseAndCleanupProofNotApplicable: Bool
    public let leaseBusyNeverWaitsOrSteals: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbePlanV1:
    Codable, Equatable, Sendable
{
    public let buildCount: Int
    public let releaseBuildCommand: String
    public let releaseBuildCompilesDefaultProductsAndTests: Bool
    public let releaseContractXCTestCommand: String
    public let releaseContractXCTestUsesSkipBuild: Bool
    public let releaseBinPathResolutionCommand: String
    public let releaseBinPathResolutionCompilationCount: Int
    public let releaseExecutableDirectInvocationRule: String
    public let swiftRunInvocationCount: Int
    public let additionalBuildCount: Int
    public let stage6LauncherInvocationCount: Int
    public let directXCTestCount: Int
    public let directExecutableProbeCount: Int
    public let aggregateDirectInvocationCount: Int
    public let supervisorProcessCount: Int
    public let maximumWorkerProcessCount: Int
    public let workerSpawnAttemptCount: Int
    public let modelAllocationCount: Int
    public let modelMaterializationCount: Int
    public let valueAndGradCount: Int
    public let trainingLogitsCount: Int
    public let crossEntropyCount: Int
    public let forwardLossCount: Int
    public let backwardCount: Int
    public let gradientNormCount: Int
    public let gradientClipCount: Int
    public let optimizerStepCount: Int
    public let adamWUpdateCount: Int
    public let fullGraphEvaluationCount: Int
    public let kvCacheAllocationCount: Int
    public let evaluationForwardPassCount: Int
    public let checkedTensorMaterializationEvaluationRequired: Bool
    public let fullGraphEvaluationMeansTensorMaterializationNotEvaluationPass:
        Bool
    public let checkedEvaluationAPI: String
    public let gpuSynchronizationAPI: String
    public let orderedCheckedEvaluationAndSynchronizationBarriers: [String]
    public let checkedEvaluationBarrierCount: Int
    public let gpuSynchronizationBarrierCount: Int
    public let phaseMetricsSampledOnlyAfterApplicableBarrier: Bool
    public let hostScalarAndFingerprintReadsImmediatelyAfterApplicableSynchronization:
        Bool
    public let finalFullStateBarrierIncludesModelAndBothMomentCatalogs: Bool
    public let resourceMeasurementBoundaries: [String]
    public let resourceMeasurementBoundaryEndRules: [String]
    public let phaseElapsedSemantics: String
    public let workerProbeEpoch: String
    public let phaseIntervalPartitionRule: String
    public let phaseCumulativeElapsedStrictlyIncreasesAcrossObservedPrefix: Bool
    public let unavailablePhaseCumulativeElapsedMustBeNull: Bool
    public let lastObservedPhaseElapsedMustBeLessThanOrEqualWorkerActiveElapsed:
        Bool
    public let filesystemFSIDMustRemainStableAcrossObservedPhases: Bool
    public let filesystemInvalidOrOverflowClassification: String
    public let preflightAvailableFilesystemComparison: String
    public let allocatedProbeFunctionInlining: String
    public let allocatedProbeFunctionName: String
    public let allocatedProbeFunctionReturnType: String
    public let allocatedProbeReturnAllowsMLXOrReferenceEscape: Bool
    public let allocatedProbeLiveSetRules: [String]
    public let memoryClearCacheCount: Int
    public let memoryClearCacheOccursAfterAllocatedProbeReturnAndBeforeFinalSnapshot:
        Bool
    public let postflightDeviceReenumerationCount: Int
    public let postflightRunsAfterFinalDeallocationSnapshot: Bool
    public let postflightRunsWhileLeaseHeldAndInsideSuppliedDefaultDeviceScope:
        Bool
    public let postflightDeviceIdentityBindingsMustEqualPreflight: Bool
    public let postflightCurrentAllocatedSizeEqualityCheckAuthorized: Bool
    public let postflightMLXPolicyAndLimitReadbacksMustEqualPreflight: Bool
    public let postflightMismatchClassification: String
    public let completedBoundaryMetricInventoryRequired: Bool
    public let fatalOutcomeLaterBoundaryMetricsMayBeUnavailable: Bool
    public let workerActiveTimeoutSeconds: Int
    public let supervisorEndToEndTimeoutSeconds: Int
    public let terminationGraceSeconds: Int
    public let receiptPrefix: String
    public let receiptCount: Int
    public let normativeMaximumWorkerCandidateFrameCount: Int
    public let passWorkerCandidateFrameCount: Int
    public let abstainAcceptedWorkerCandidateCount: Int
    public let workerCandidateIsCapturedAndNeverEmittedWithCanonicalPrefix: Bool
    public let workerCanonicalReceiptPrefixEmissionCount: Int
    public let supervisorEmittedCanonicalReceiptCount: Int
    public let supervisorCanonicalReceiptStdoutLineCount: Int
    public let receiptFileCount: Int
    public let fatalOutcomeStillRequiresSupervisorCanonicalReceipt: Bool
    public let supervisorSynthesizesABSTAINReceiptWhenWorkerCandidateAbsent:
        Bool
    public let passRequirements: [String]
    public let abstainClasses: [String]
    public let oneExactMainOpportunityAfterGreenAuthorityClosure: Bool
    public let retryAuthorized: Bool
    public let rerunAuthorized: Bool
    public let replacementRunAuthorized: Bool
    public let checkpointReadCount: Int
    public let checkpointWriteCount: Int
    public let artifactUploadCount: Int
    public let qualityMetricComputationCount: Int
    public let generatedTokenCount: Int
}

public struct PrimeNativeDecoderNative300MResourceProbeReceiptContractV1:
    Codable, Equatable, Sendable
{
    public let schemaID: String
    public let receiptID: String
    public let receiptPrefix: String
    public let authorityIDBinding: String
    public let authorityCanonicalSHA256Binding: String
    public let authorityBaseRevisionBinding: String
    public let authorityBaseTreeBinding: String
    public let authorityClosureRunBindingRequired: Bool
    public let authorityClosureRequiredEvent: String
    public let authorityClosureRequiredRef: String
    public let authorityClosureRequiredAttempt: Int
    public let authorityClosureRequiredStatus: String
    public let authorityClosureRequiredConclusion: String
    public let authorityClosureRequiredJobConclusion: String
    public let authorityClosureRequiredArtifactCount: Int
    public let authorityClosureRequiredRerunCount: Int
    public let authorityClosureRevisionMustEqualWorkflowHeadAndMechanicsFirstParent:
        Bool
    public let mechanicsRequiredEvent: String
    public let mechanicsRequiredRef: String
    public let mechanicsRequiredAttempt: Int
    public let topLevelKeys: [String]
    public let authorityKeys: [String]
    public let ceilingKeys: [String]
    public let configurationKeys: [String]
    public let environmentKeys: [String]
    public let executionKeys: [String]
    public let sourceIdentityKeys: [String]
    public let leaseKeys: [String]
    public let limitsKeys: [String]
    public let outcomeKeys: [String]
    public let outcomeTransitionKeys: [String]
    public let outcomeTransitionRules: [String]
    public let operationCountKeys: [String]
    public let phaseNames: [String]
    public let phaseMetricKeys: [String]
    public let nullableNumericMetricKeys: [String]
    public let nullableEnvironmentObservationKeys: [String]
    public let nullableLimitObservationKeys: [String]
    public let nullableOutcomeObservationKeys: [String]
    public let nullableExecutionTerminationKeys: [String]
    public let timeoutScopeDomain: [String]
    public let statusDomain: [String]
    public let classificationDomain: [String]
    public let phaseAvailabilityDomain: [String]
    public let classificationAvailabilityRules: [String]
    public let unavailableMetricEncoding: String
    public let nonPhaseUnavailableEncoding: String
    public let byteUnit: String
    public let durationUnit: String
    public let canonicalSortedJSONRequired: Bool
    public let passRequiresWorkerCandidate: Bool
    public let passRequiresAllSixObservedBoundaries: Bool
    public let passRequiresMonotonicElapsedPeakAndMaxRSS: Bool
    public let passRequiresExactOperationCountsAndUpdateChecks: Bool
    public let receiptLossAndGradientBindingsMustEqualConfiguration: Bool
    public let passRawGradientNormFiniteAndPositive: Bool
    public let passGradientClipScaleBitwiseEqualsFrozenFormula: Bool
    public let operationCountsRecordAttemptedInvocationsIncludingFatalAttempt:
        Bool
    public let abstainRequiresPossiblyEmptyObservedPrefixAndExplicitUnavailableSuffix:
        Bool
    public let abstainPhasePartitionRule: String
    public let abstainUnavailableSuffixMayBeEmptyOnlyWhenAllSixBoundariesWereObservedBeforeClassification:
        Bool
    public let emptyObservedPrefixRule: String
    public let unavailableSuffixRequiresAllNumericMetricKeysPresentAndNull:
        Bool
    public let phaseAndAvailabilityMetadataAlwaysNonNull: Bool
    public let unavailableReasonKeyAlwaysPresent: Bool
    public let unavailableReasonNullIffAvailabilityObserved: Bool
    public let unavailableReasonEqualsClassificationIffAvailabilityUnavailable:
        Bool
    public let environmentObservationAtomicProgressRule: String
    public let mlxExecutionPolicyAtomicProgressRule: String
    public let filesystemObservationAtomicProgressRule: String
    public let limitObservationAtomicProgressRule: String
    public let validatedModelCatalogAtomicProgressRule: String
    public let validatedGradientCatalogAtomicProgressRule: String
    public let validatedMomentCatalogAtomicProgressRule: String
    public let validatedOptimizerMomentParityDerivationRule: String
    public let outcomeObservationProgressRules: [String]
    public let executionTerminationObservationRule: String
    public let workerSpawnObservationRule: String
    public let workerSpawnFailureRule: String
    public let executorReceiptDriftRule: String
    public let timeoutObservationRule: String
    public let workerActiveIntervalRule: String
    public let supervisorEndToEndIntervalRule: String
    public let passAndNonTimeoutABSTAINTimingRule: String
    public let timeoutABSTAINTimingRule: String
    public let passRequiresAllEnvironmentLimitAndOutcomeObservationsNonNull:
        Bool
    public let passWorkerExitCode: Int
    public let passWorkerSignalMustBeNull: Bool
    public let passWorkerTimeoutMustBeFalse: Bool
    public let passMLXDeviceType: String
    public let passMLXDeviceConstructorIndex: Int
    public let passMLXDefaultDeviceIsSuppliedDevice: Bool
    public let passMLXDefaultStreamIsGPU: Bool
    public let passMLXCPUFallbackUsed: Bool
    public let receiptMLXConstructorIndexAndMetalPolicyIndexMustBothEqualZero:
        Bool
    public let passCheckedEvaluationBarrierCount: Int
    public let passGPUSynchronizationBarrierCount: Int
    public let abstainBarrierCountsAreAttemptedPrefixCounts: Bool
    public let passFingerprintRequiresExactPlanPathAndSampleCounts: Bool
    public let passFingerprintRequiresLowercaseHexAndBeforeAfterDifference: Bool
    public let passPostflightDeviceIdentityMatchesPreflightMustBeTrue: Bool
    public let passPostflightMLXPolicyAndLimitsMatchPreflightMustBeTrue: Bool
    public let receiptAnalyticLimitsMustEqualFrozenResourceEnvelope: Bool
    public let passValidatedParameterPathCount: Int
    public let passValidatedUniqueParameterCount: UInt64
    public let passValidatedWeightsLogicalByteCount: UInt64
    public let passValidatedGradientPathCount: Int
    public let passValidatedGradientLogicalByteCount: UInt64
    public let passValidatedFirstMomentTensorCount: Int
    public let passValidatedSecondMomentTensorCount: Int
    public let passValidatedOptimizerMomentLogicalByteCount: UInt64
    public let receiptTimeoutCapsMustEqualFutureProbe: Bool
    public let staticToolchainAndMetallibFieldsAlwaysNonNull: Bool
    public let workerTransport: String
    public let workerFrameSchemaVersion: Int
    public let workerFrameTopLevelKeys: [String]
    public let workerFrameKindDomain: [String]
    public let workerFrameMaximumByteCount: Int
    public let workerFrameMaximumCompactJSONByteCount: Int
    public let workerTransportFrameByteCountIncludesFinalLF: Bool
    public let supervisorTransportBufferBoundRule: String
    public let workerTransportDoesNotAssumePIPEBUFAtomicity: Bool
    public let workerFrameEncoding: String
    public let workerFrameSequenceRule: String
    public let workerPipeOwnershipRule: String
    public let workerPipeWriteRule: String
    public let workerProgressCommitRule: String
    public let workerProgressSnapshotRule: String
    public let supervisorConcurrentDrainRule: String
    public let supervisorFrameParsingRule: String
    public let supervisorTransportDriftRule: String
    public let workerCandidateTerminalRule: String
    public let workerCandidateAcceptedIffPASS: Bool
    public let abstainObservedCandidateFrameRule: String
    public let allABSTAINReceiptsSupervisorSynthesized: Bool
    public let passWorkerTransportRule: String
    public let fatalWorkerTransportRule: String
    public let spawnFailureWorkerTransportRule: String
    public let workerProgressAndMaximumOneCandidateOnly: Bool
    public let workerStdoutReceiptCount: Int
    public let workerReceiptFileCount: Int
    public let workerArtifactCount: Int
    public let supervisorSoleReceiptStdoutOwner: Bool
    public let supervisorUsesFputsThenOneFlush: Bool
    public let supervisorCompletesAllFallibleWorkBeforeCanonicalEmission: Bool
    public let supervisorPreEmissionOrder: [String]
    public let supervisorFputsAndFlushReturnAndFerrorChecksRequired: Bool
    public let supervisorEmissionFailureExitsNonzeroWithoutClaimingValidReceipt:
        Bool
    public let supervisorHasNoFallibleWorkAssertionsDefersOrCleanupAfterFlush:
        Bool
    public let supervisorImmediateExitZeroAfterSuccessfulFlush: Bool
    public let supervisorSuccessfulFlushExitAPI: String
    public let launcherParsesCapturedLogOnlyAfterSupervisorTerminationAndRequiresExitZero:
        Bool
    public let supervisorEmitsAfterApplicableChildTerminationAndLeaseCleanupDisposition:
        Bool
    public let supervisorValidatesCandidateOrSynthesizesABSTAINWhenAbsent: Bool
    public let terminalSupervisorReceiptCount: Int
    public let supervisorExitsZeroAfterValidCanonicalTerminalReceiptAndCleanup:
        Bool
    public let launcherValidatesEitherCanonicalStatusAndExitsZero: Bool
    public let invalidReceiptDriftOrUncontainedNoReceiptFailureExitsNonzero:
        Bool
    public let workerNonzeroOrSignalMayYieldGreenSupervisorABSTAIN: Bool
    public let executorReceiptDriftGreenOnlyWithSynthesizedCanonicalABSTAIN:
        Bool
    public let buildOrLauncherBeforeSupervisorFailureReceiptCount: Int
    public let buildOrLauncherBeforeSupervisorFailureClassifiedExternally:
        Bool
    public let receiptBindsExactAuthoritySourceExecutionAndProvenanceIDs: Bool
    public let receiptBindsAllPersistentFalseCeilings: Bool
    public let receiptBindsOutcomeTransitionFieldsSeparately: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbeScopeV1:
    Codable, Equatable, Sendable
{
    public let exactChangedPaths: [String]
    public let sourceAndTestAreOnlyNewPaths: Bool
    public let rootPackageManifestMutationAuthorized: Bool
    public let rootPackageResolvedMutationAuthorized: Bool
    public let trainingValidationManifestMutationAuthorized: Bool
    public let trainingValidationLockMutationAuthorized: Bool
    public let newTrainingProbeSourceAuthorized: Bool
    public let existingTrainingSourceMutationAuthorized: Bool
    public let newStage6LauncherAuthorized: Bool
    public let newStage6ExecutableMainAuthorized: Bool
    public let newStage6AuthorityTestAuthorized: Bool
    public let newStage6MechanicsPureContractTestAuthorized: Bool
    public let existingMetalLauncherMutationAuthorized: Bool
    public let existingRuntimeLauncherMutationAuthorized: Bool
    public let existingTokenizerLauncherMutationAuthorized: Bool
    public let existingStage5LauncherMutationAuthorized: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbeSuccessorManifestV1:
    Codable, Equatable, Sendable
{
    public let packageManifestPath: String
    public let packageName: String
    public let newExecutableProductCount: Int
    public let newExecutableProductName: String
    public let newExecutableProductTargetNames: [String]
    public let newExecutableTargetCount: Int
    public let newExecutableTargetName: String
    public let newExecutableTargetSourcePath: String
    public let newExecutableTargetDirectProductDependencies: [String]
    public let newExecutableTargetDirectMLXProductDependencyCount: Int
    public let newExecutableTargetLinkerFrameworks: [String]
    public let newExecutableMainImports: [String]
    public let newExecutableMainEntryPoint: String
    public let trainingProbeSourcePath: String
    public let trainingProbeSourceImports: [String]
    public let existingTestTargetName: String
    public let newContractTestPath: String
    public let newContractTestClassName: String
    public let newContractTestMethodName: String
    public let newContractTestFilter: String
    public let focusedValidationContractTestFilter: String
    public let stage6LauncherContractTestFilter: String
    public let bothContractTestInvocationsUseSameExactFilterOnce: Bool
    public let newContractTestImports: [String]
    public let existingTestTargetDirectProductDependenciesAfterMutation:
        [String]
    public let existingTestTargetLinkerFrameworks: [String]
    public let existingTrainingAndMLXTestDependenciesRetained: Bool
    public let rootPackageManifestMustRemainByteIdentical: Bool
}

public struct PrimeNativeDecoderNative300MResourceProbeSuiteV1:
    Codable, Equatable, Sendable
{
    public let authorityRootTestCount: Int
    public let isolatedGroupTestCounts: [Int]
    public let isolatedTestCount: Int
    public let authorityFocusedWholeTestCount: Int
    public let predecessorMetalTestCount: Int
    public let predecessorRuntimeTestCount: Int
    public let predecessorTokenizerTestCount: Int
    public let authorityTotalTestCount: Int
    public let authorityStage5LauncherInvocationCount: Int
    public let authorityStage5ReceiptCount: Int
    public let authorityStage6LauncherInvocationCount: Int
    public let authorityStage6ReceiptCount: Int
    public let futureStage6PureContractFocusedXCTestCount: Int
    public let futureStage6PureContractDirectXCTestCount: Int
    public let futureStage6PureContractXCTestStartCount: Int
    public let futureStage6ExecutableOperationalProbeCount: Int
    public let futureStage6LauncherLocalAggregateDirectInvocationCount: Int
    public let futureStage6AggregateInvocationCount: Int
    public let futureMechanicsXCTestTotalCount: Int
    public let authorityClosureLiveOrder: [String]
    public let futureMechanicsLiveOrder: [String]
    public let futureStage6InternalOrder: [String]
}

public struct PrimeNativeDecoderNative300MResourceProbeAuthorityCeilingV1:
    Codable, Equatable, Sendable
{
    public let authorityOnlyNoProbeResultEvidence: Bool
    public let mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: Bool
    public let oneExactMainResourceProbeOpportunityAuthorized: Bool
    public let oneNative300MAllocationAuthorizedForResourceProbe: Bool
    public let oneNative300MTrainingStepAuthorizedForResourceProbe: Bool
    public let boundedResourceMeasurementAuthorized: Bool
    public let stage5ReplacementExecutionAuthorized: Bool
    public let stage5ResultEstablished: Bool
    public let stage5MechanicsSuccessEstablished: Bool
    public let stage5AssayClearanceEstablished: Bool
    public let exactMetalGradientBytesEstablished: Bool
    public let repeatedTrajectoryDeterminismEstablished: Bool
    public let metalDeterminismEstablished: Bool
    public let resourceProbeExecuted: Bool
    public let resourceEnvelopeEstablished: Bool
    public let resourceClearanceEstablished: Bool
    public let ordinaryJobFitEstablished: Bool
    public let runnerMemoryCapacityEstablished: Bool
    public let broadNative300MTrainingAuthorized: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
    public let durableCheckpointIOAuthorized: Bool
    public let retainedArtifactAuthorized: Bool
    public let artifactUploadAuthorized: Bool
    public let tinyTypedInMemoryResumeEstablished: Bool
    public let tinyDurableSnapshotRoundTripEstablished: Bool
    public let generalTrainingResumeEstablished: Bool
    public let native300MTrajectoryTrainingResumeEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let stage7AuthorityEstablished: Bool
    public let stage7Authorized: Bool
    public let downstreamTrialAuthorized: Bool
    public let canaryAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Pure, append-only Stage-6 authority. A failed-but-retired Stage 5 is a
/// completed lifecycle stage, not a successful assay result. This permits only
/// the independent resource probe. Stage 7 still lacks assay clearance.
public struct PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1:
    Codable, Equatable, Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let repository: PrimeNativeDecoderNative300MResourceProbeRepositoryV1
    public let roadmap: PrimeNativeDecoderNative300MResourceProbeRoadmapV1
    public let stage5Failure: PrimeNativeDecoderNative300MResourceProbeStage5FailureV1
    public let stage5Retirement: PrimeNativeDecoderNative300MResourceProbeRetirementRunV1
    public let configuration: PrimeNativeDecoderNative300MResourceProbeConfigurationV1
    public let resourceEnvelope: PrimeNativeDecoderNative300MResourceProbeResourceEnvelopeV1
    public let environment: PrimeNativeDecoderNative300MResourceProbeEnvironmentV1
    public let futureProbe: PrimeNativeDecoderNative300MResourceProbePlanV1
    public let receiptContract:
        PrimeNativeDecoderNative300MResourceProbeReceiptContractV1
    public let authorityClosureScope: PrimeNativeDecoderNative300MResourceProbeScopeV1
    public let successorScope: PrimeNativeDecoderNative300MResourceProbeScopeV1
    public let successorManifest:
        PrimeNativeDecoderNative300MResourceProbeSuccessorManifestV1
    public let suite: PrimeNativeDecoderNative300MResourceProbeSuiteV1
    public let ceiling: PrimeNativeDecoderNative300MResourceProbeAuthorityCeilingV1
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalSHA256 =
        "2627ffc0dd6499a9a1b20fa217b7f1c4a9723a6fd6332ef24a9ee251b5b0bf56"

    public static let frozenV1: Self = {
        func source(
            _ path: String,
            _ mode: String,
            _ blob: String,
            _ bytes: Int,
            _ lines: Int,
            _ sha256: String,
            _ role: String
        ) -> PrimeNativeDecoderNative300MResourceProbeSourceIdentityV1 {
            .init(
                path: path,
                mode: mode,
                gitBlob: blob,
                byteCount: bytes,
                lfByteCount: lines,
                sha256: sha256,
                role: role)
        }

        let authorityPaths = [
            ".github/scripts/prime-ci-active-root-quarantine.sh",
            ".github/workflows/prime-active-root-quarantine.yml",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            "Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthority.swift",
            "Tests/PrimeCoreTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityTests.swift",
        ]
        let successorPaths = [
            ".github/scripts/prime-ci-active-root-quarantine.sh",
            ".github/scripts/prime-ci-native-decoder-stage6-native300m-resource-only-one-step.sh",
            ".github/workflows/prime-active-root-quarantine.yml",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift",
            "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
            "Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe/main.swift",
            "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests.swift",
        ]
        let probeTokens = [1] + (0 ..< 127).map {
            2 + (($0 * 73 + 44) % 510)
        }

        return Self(
            schemaVersion: 1,
            authorityID:
                "prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1",
            authorityKind:
                "append_only_dependency_free_nonexecuting_stage6_native300m_resource_probe_authority",
            repository: .init(
                repository: "Ergentics/ergentics-prime",
                ref: "refs/heads/main",
                authorityBaseRevision:
                    "f5a9638194c53922f09c39c3c76095b5cc47c25e",
                authorityBaseTree:
                    "a17a8f92604157c0de0252dbc30cf22681d6a13d",
                authorityBaseOrderedParents: [
                    "8bdf6abe15d7f9a83045a3f9ee21fcc28f7ee91d",
                    "7ad93b26d1fb8fc353cc03ee3062fd6bacb88ecd",
                ],
                retirementPullRequestNumber: 105,
                retirementReviewedHeadRevision:
                    "7ad93b26d1fb8fc353cc03ee3062fd6bacb88ecd",
                authorityBaseIsExactTerminalStage5RetirementMain: true,
                authorityClosureExactChangedPaths: authorityPaths,
                authorityClosurePreservedIndexSHA256:
                    "972c5f99d102ad4dd117fd020d403e4b7332c8aef0d346992d2e375fc1c5aecf",
                authoritySourceAndTestAreOnlyNewPaths: true,
                baseSourceBindings: [
                    source(
                        ".github/scripts/prime-ci-active-root-quarantine.sh",
                        "100755", "60c815afd71b7d10e49b6630bdb810c8983950eb",
                        593_587, 10_387,
                        "389a9f73e3a2e5e0265fdf61009acbd5909384cd4ac29e73a42d8ec69da25985",
                        "terminal_stage5_retirement_gate"),
                    source(
                        ".github/workflows/prime-active-root-quarantine.yml",
                        "100644", "a485adb908ca18cb38871912d3802de609446365",
                        72_875, 561,
                        "60616810ced2f559189e207aa660b1d3927edd16287797807b5e484a657f7d6b",
                        "terminal_stage5_retirement_workflow"),
                    source(
                        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                        "100644", "506b03d6ce0c226e2052bf18d6eecd8a5dca4e26",
                        546, 13,
                        "3194d28ef388386e36c781448f5130a58692e36c9a49bcb8d339bdd048fa860d",
                        "terminal_stage5_retirement_provenance"),
                    source(
                        "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservation.swift",
                        "100644", "6b3eba9a247b8a200491e5d8298f08086c1d2cca",
                        55_118, 1_163,
                        "009606cea10a06747e274d176b88a4a8b3d3d8b1c2c5f2487e8775e145a883af",
                        "consumed_stage5_failure_observation"),
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationTests.swift",
                        "100644", "137fd5930c91e97e90fe3d9f646544b17a63fd83",
                        37_805, 901,
                        "308875161943d6fce257c348a209352da4ec569dd4567cfd5e70600ab9b2f768",
                        "consumed_stage5_failure_observation_test"),
                    source(
                        ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh",
                        "100755", "6547ee06663c1ea409a6256e48f6111245056020",
                        48_869, 830,
                        "c639cfcb4d1d0a103b285ed38849565f16b00932fc3b9d921febbf798c30d5f9",
                        "frozen_consumed_stage5_launcher_preserved_for_audit"),
                    source(
                        "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                        "100644", "271b7fe4a856a76a00730954c23bdca3b33e761d",
                        86_387, 2_173,
                        "f49b946e5272992f09ecf7b1dd8439bda15c5ac696a4f6298bafa19994f2b4c2",
                        "frozen_stage5_training_mechanics"),
                    source(
                        "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
                        "100644", "46f91f32e91870d21c46cd318972a857b8ef6e12",
                        28_292, 606,
                        "50b19a0bfe8752d2b80c09527b70731d906e8064c8e2d49a758c8c48b48f4398",
                        "frozen_stage5_assay_test"),
                    source(
                        "Sources/PrimeCore/PrimeMetalDeviceLease.swift",
                        "100644", "da3daa54802b67dc2c8c04a89b388e9927dd8726",
                        16_985, 534,
                        "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657",
                        "frozen_nonblocking_exclusive_device_lease"),
                    source(
                        "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                        "100644", "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f",
                        39_598, 1_102,
                        "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
                        "frozen_native300m_model_factory"),
                ]),
            roadmap: .init(
                designAuthorityID:
                    "ergentics_prime_native_decoder_trajectory_exact_resume_design_authority_v1",
                designAuthorityCanonicalSHA256:
                    "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
                designAuthoritySourceGitBlob:
                    "20bcbf28ddcfa9a6339510d53e81da02ada9953e",
                designAuthorityTestGitBlob:
                    "186dc546c7f889f28d700322ac06b7b8a8a4c252",
                stageID: "native300m_resource_only_one_step_probe_v1",
                objective:
                    "measure_native300m_one_step_memory_disk_and_duration_without_quality_or_checkpoint_claim",
                requiredPredecessorStageID:
                    "tiny_repeated_metal_trajectory_determinism_assay_v1",
                predecessorStageLifecycleCompleted: true,
                predecessorResultEstablished: false,
                predecessorAssayClearanceEstablished: false,
                nextStageID:
                    "native300m_trajectory_checkpoint_execution_v1",
                nextStageObjective:
                    "execute_one_bounded_native300m_step_checkpoint_restore_and_exact_successor_step_only_after_assay_and_resource_clearance",
                nextStageRequiresAssayAndResourceClearance: true,
                nextStageAuthorizedByThisAuthority: false,
                separatelyAuthorizedSuccessorRequired: true),
            stage5Failure: .init(
                observationID:
                    "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_execution_failure_observation_v1",
                observationCanonicalSHA256:
                    "ac735b84948e6b9b6b492a79925d7e0770d6eb332ba4d643d7f2884a4a7f81d2",
                observationSourceGitBlob:
                    "6b3eba9a247b8a200491e5d8298f08086c1d2cca",
                observationSourceSHA256:
                    "009606cea10a06747e274d176b88a4a8b3d3d8b1c2c5f2487e8775e145a883af",
                observationTestGitBlob:
                    "137fd5930c91e97e90fe3d9f646544b17a63fd83",
                observationTestSHA256:
                    "308875161943d6fce257c348a209352da4ec569dd4567cfd5e70600ab9b2f768",
                mechanicsMergeRevision:
                    "8bdf6abe15d7f9a83045a3f9ee21fcc28f7ee91d",
                mechanicsMergeTree:
                    "f7dbc81e4f7e8ccebdf39f0fb5200a7780be91dc",
                workflowRunID: 31_756_331_438,
                workflowRunNumber: 105,
                workflowRunAttempt: 1,
                checkSuiteID: 86_154_359_326,
                activeJobID: 94_632_729_903,
                reviewedJobID: 94_633_409_696,
                activeJobConclusion: "success",
                reviewedJobConclusion: "failure",
                stage5LauncherInvocationCount: 1,
                stage5DirectXCTestInvocationCount: 1,
                stage5TestPassCount: 0,
                stage5TestFailureCount: 1,
                stage5TestSkipCount: 0,
                exactThrownError: "contractDrift(\"source-step exact bytes\")",
                combinedGuardConjunctCount: 3,
                failingConjunctIdentified: false,
                failingTrialOrdinalEstablished: false,
                priorCompletedTrialCountMinimum: 0,
                priorCompletedTrialCountMaximum: 2,
                stage5ReceiptCount: 0,
                stage5MechanicsExecuted: true,
                oneShotExecutionConsumed: true,
                oneShotExecutionExhausted: true,
                stage5ResultEstablished: false,
                stage5MechanicsSuccessEstablished: false,
                repeatedTrajectoryDeterminismEstablished: false,
                exactMetalGradientBytesEstablished: false,
                metalDeterminismEstablished: false,
                replacementStage5ExecutionAuthorized: false),
            stage5Retirement: .init(
                mergeRevision:
                    "f5a9638194c53922f09c39c3c76095b5cc47c25e",
                mergeTree:
                    "a17a8f92604157c0de0252dbc30cf22681d6a13d",
                orderedParentRevisions: [
                    "8bdf6abe15d7f9a83045a3f9ee21fcc28f7ee91d",
                    "7ad93b26d1fb8fc353cc03ee3062fd6bacb88ecd",
                ],
                reviewedHeadRevision:
                    "7ad93b26d1fb8fc353cc03ee3062fd6bacb88ecd",
                pullRequestNumber: 105,
                workflowRunID: 31_763_253_701,
                workflowRunNumber: 107,
                workflowRunAttempt: 1,
                checkSuiteID: 86_172_361_851,
                event: "push",
                headBranch: "main",
                headRevision:
                    "f5a9638194c53922f09c39c3c76095b5cc47c25e",
                status: "completed",
                conclusion: "success",
                previousAttemptURLWasNull: true,
                exactHeadPushRunCount: 1,
                rerunCount: 0,
                artifactCount: 0,
                activeJobID: 94_653_827_612,
                activeRunnerImage: "macos-15",
                activeJobConclusion: "success",
                reviewedJobID: 94_654_353_548,
                reviewedRunnerImage: "macos-26",
                reviewedJobConclusion: "success",
                rootTestCount: 54,
                isolatedGroupTestCounts: [1, 1, 2, 2],
                isolatedTestCount: 6,
                focusedWholeTestCount: 60,
                metalTestCount: 44,
                maintainedRuntimeTestCount: 1,
                maintainedRuntimeReceiptCount: 1,
                tokenizerTestCount: 1,
                tokenizerReceiptCount: 1,
                totalTestCount: 106,
                depthOneCheckoutCount: 2,
                liveExecutionOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                stage4LauncherInvocationCount: 0,
                stage5LauncherInvocationCount: 0,
                stage5ReceiptCount: 0,
                stage6LauncherInvocationCount: 0,
                stage6ReceiptCount: 0,
                workflowAuthoredRetryCount: 0,
                gitInternalRetryCount: 0,
                tlsFailureCount: 0,
                tlsVerificationBypassCount: 0,
                customCAInstallationCount: 0,
                stage5InvocationRetired: true,
                stage5LauncherPreservedForAudit: true),
            configuration: .init(
                compatibilitySchemaID:
                    "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
                modelModule: "PrimeNativeDecoder",
                modelConfigurationType: "PrimeNativeGQADecoderConfiguration",
                modelConfigurationFactory:
                    "native300MInventory(vocabularySize:)",
                modelType: "PrimeNativeGQADecoder",
                modelFactory: "make(configuration:seed:)",
                vocabularySize: 512,
                tokenizerID: "ergentics_prime_nfc_utf8_byte_v1",
                tokenizerManifestSHA256:
                    "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7",
                modelWidth: 1_024,
                layerCount: 24,
                queryHeadCount: 16,
                keyValueHeadCount: 4,
                headWidth: 64,
                intermediateWidth: 2_816,
                maximumSequenceLength: 2_048,
                ropeThetaFloat32BitPattern: 1_176_256_512,
                rmsNormEpsilonFloat32BitPattern: 925_353_388,
                parameterPathCount: 218,
                uniqueParameterCount: 271_107_072,
                logicalFP32ParameterByteCount: 1_084_428_288,
                initializationSeed: 44,
                batchSize: 1,
                sequenceLength: 128,
                validTokenCount: 128,
                gradientAccumulationCount: 1,
                optimizerStepCount: 1,
                tokenAlgorithmID:
                    "prime_stage6_seed44_batch1x128_mod510_stride73_v1",
                batchTokenIDs: [probeTokens],
                batchCompletionMask:
                    [[false] + Array(repeating: true, count: 127)],
                selectedTargetCount: 127,
                lossGraphAlgorithmID:
                    "prime_stage6_causal_masked_mean_cross_entropy_f32_v1",
                tokenIDStorageDType: "int32",
                completionMaskStorageDType: "bool",
                trainingLogitsAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCache",
                trainingLogitsInvocationCount: 1,
                trainingLogitsExpectedShape: [1, 128, 512],
                trainingLogitsDType: "float32",
                trainingLogitsUsesCausalAttentionMask: true,
                trainingLogitsKVCacheAllocationCount: 0,
                shiftedLogitsSlice: "logits[0...,0..<127,0...]",
                shiftedTargetsSlice: "token_ids[0...,1..<128]",
                shiftedCompletionMaskSlice:
                    "completion_mask[0...,1..<128]",
                shiftedLogitsExpectedShape: [1, 127, 512],
                shiftedTargetsExpectedShape: [1, 127],
                shiftedCompletionMaskExpectedShape: [1, 127],
                shiftedCompletionMaskAllTrue: true,
                crossEntropyAPI:
                    "MLXNN.crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)",
                crossEntropyWeights: "nil",
                crossEntropyAxis: -1,
                crossEntropyLabelSmoothingFloat32BitPattern: 0,
                crossEntropyReduction: "none",
                perTargetLossDType: "float32",
                perTargetLossExpectedShape: [1, 127],
                perTargetLossExpectedElementCount: 127,
                perTargetLossAllElementsSelectedByShiftedMask: true,
                perTargetLossShapeAndDTypeValidatedInsideValueAndGradClosureBeforeReduction:
                    true,
                lossReductionFormula:
                    "MLX.sum(per_target_loss*shifted_completion_mask.asType(.float32))/Float32(127)",
                lossDType: "float32",
                lossExpectedRank: 0,
                valueAndGradAPI: "MLXNN.valueAndGrad(model:_:)",
                valueAndGradClosureArguments: [
                    "model", "token_ids", "completion_mask",
                ],
                valueAndGradClosureReturnsOnlyScalarLoss: true,
                independentOrDetachedLossAuthorized: false,
                learningRateFloat32BitPattern: 953_267_991,
                beta1Float32BitPattern: 1_063_675_494,
                beta2Float32BitPattern: 1_065_336_439,
                epsilonFloat32BitPattern: 841_731_191,
                weightDecayFloat32BitPattern: 1_008_981_770,
                maximumGradientNormFloat32BitPattern: 1_065_353_216,
                gradientNormEpsilonFloat32BitPattern: 897_988_541,
                parameterDType: "float32",
                optimizerQualifiedType: "MLXOptimizers.AdamW",
                optimizerStateInspectionAPI:
                    "MLXOptimizers.AdamW.innerState()",
                optimizerStatePairTopology:
                    "218_adjacent_[first_moment,second_moment]_pairs_from_TupleState.innerState",
                optimizerStateExpectedArrayCount: 436,
                optimizerStateExpectedPairCount: 218,
                optimizerNamedStateExportDuringProbeAuthorized: false,
                optimizerStateMustBeEmptyBeforeUpdate: true,
                optimizerStateAdjacentPairsSameShapeAndFloat32Required: true,
                optimizerStateParityElementCountEach: 271_107_072,
                optimizerStateParityLogicalByteCountEach: 1_084_428_288,
                optimizerStatePairShapeMultisetMustEqualModelParameterShapeMultiset:
                    true,
                optimizerStatePerPathMomentNamingEstablished: false,
                postUpdateFullStateEvaluationAPI:
                    "checkedEval(model,optimizer,after_fingerprint_sample_views)",
                postModelFullStateEvaluationAPI:
                    "checkedEval(model,before_fingerprint_sample_views)",
                postUpdateFullStateEvaluationIncludes218ModelAnd436OptimizerArrays:
                    true,
                adamWBiasCorrectionApplied: false,
                gradientClippingMode:
                    "global_l2_norm_clip_once_before_adamw_update",
                gradientCatalogOrdering:
                    "trainable_parameters_flattened_unique_paths_utf8_ascending",
                expectedGradientPathCount: 218,
                rawGradientNormAlgorithmID:
                    "prime_stage6_global_f32_l2_norm_utf8_catalog_v1",
                rawGradientNormFormula:
                    "sqrt(sum_in_utf8_path_order(MLX.sum(MLX.square(gradient.asType(.float32)))))",
                rawGradientNormAccumulatorDType: "float32",
                gradientNormEpsilonInsideNorm: false,
                gradientClipAlgorithmID:
                    "prime_stage6_global_norm_clip_f32_v1",
                gradientClipThresholdFloat32BitPattern: 1_065_353_216,
                gradientClipEpsilonFloat32BitPattern: 897_988_541,
                gradientClipComparison: "raw_norm_float32_less_than_1",
                gradientClipScaleFormula:
                    "raw_norm<1?Float32(1):Float32(1)/(raw_norm+Float32(1e-6))",
                gradientClipScaleHostDType: "float32",
                gradientClipApplication:
                    "identity_if_raw_norm_less_than_1_else_each_of_218_gradients_times_scale",
                gradientClipApplicationCount: 1,
                gradientClipOccursExactlyOnceBeforeAdamW: true,
                adamWConsumesOnlyClippedGradientCatalog: true,
                parameterFingerprintAlgorithmID:
                    "prime_stage6_parameter_catalog_sample_f32be_sha256_v1",
                parameterFingerprintCatalogOrdering:
                    "module_parameters_flattened_unique_paths_utf8_ascending",
                parameterFingerprintSampleIndexRule:
                    "deduplicated_ascending_[0,size/2,size-1]_per_nonempty_tensor",
                parameterFingerprintIntegerEncoding:
                    "uint64_big_endian_lengths_rank_dimensions_sample_count_and_flat_indices",
                parameterFingerprintFloatEncoding:
                    "float32_bit_pattern_uint32_big_endian",
                parameterFingerprintHash: "SHA256_lowercase_hex",
                parameterFingerprintExpectedPathCount: 218,
                parameterFingerprintSamplesPerPath: 3,
                parameterFingerprintExpectedSampleCount: 654,
                parameterFingerprintRequiresEveryTensorElementCountAtLeastThree:
                    true,
                parameterFingerprintRejectsEmptyOrDuplicatePaths: true,
                parameterFingerprintFullTensorHostCopyAuthorized: false,
                parameterFingerprintHashStreamRule:
                    "UTF8_algorithm_id_then_NUL_then_each_UTF8_sorted_path_as_UInt64BE_path_byte_count_path_bytes_UInt64BE_rank_each_UInt64BE_dimension_UInt64BE_sample_count_each_UInt64BE_flat_index_UInt32BE_Float_bit_pattern",
                parameterFingerprintSamplePlanHashOmitsValueBitsOnly: true,
                paddingAuthorized: false,
                kvCacheAuthorized: false,
                modelQualityOrReadOnlyEvaluationAuthorized: false,
                generationAuthorized: false,
                checkpointAuthorized: false,
                configurationIsResourceProbeOnlyNotTrainingPolicy: true),
            resourceEnvelope: .init(
                weightsLogicalByteCount: 1_084_428_288,
                optimizerMomentTensorCount: 436,
                optimizerMomentLogicalByteCount: 2_168_856_576,
                minimumCommittedTensorStateByteCount: 3_253_284_864,
                gradientLogicalByteCount: 1_084_428_288,
                minimumStatePlusGradientByteCount: 4_337_713_152,
                threeTimesCommittedStateDiskComparatorByteCount: 9_759_854_592,
                containerHeadersAndManifestsIncludedInMinimum: false,
                duplicateMaterializationsGraphsAndTemporaryBuffersIncluded: false,
                seed43ObservedWeightsContainerByteCount: 1_084_525_304,
                seed43ObservedLiveStepDurationSeconds: 1_631,
                seed43ObservedAvailableFilesystemBytesAfterBuild:
                    101_145_567_232,
                seed43RunnerMemoryCapacityRecorded: false,
                native300MOneStepFitsCurrentReviewedJobEstablished: false,
                native300MOneStepFitsObservedMemoryEstablished: false,
                configuredMLXMemoryLimitMaximumByteCount: 17_179_869_184,
                configuredMLXMemoryLimitFormula:
                    "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)",
                configuredMLXMemoryLimitRecommendedWorkingSetSource:
                    "retainedMTLDevice.recommendedMaxWorkingSetSize",
                recommendedMaxWorkingSetSizeMustBePositive: true,
                configuredMLXMemoryLimitUInt64ToIntConversionOverflowChecked:
                    true,
                receiptConfiguredMemoryLimitMustEqualRetainedDeviceFormula:
                    true,
                configuredMLXMemoryLimitSetter: "MLX.Memory.memoryLimit",
                configuredMLXMemoryLimitSetCount: 1,
                configuredMLXMemoryLimitReadbackRequired: true,
                configuredMLXMemoryLimitReadbackMustEqualFormulaResult: true,
                configuredMLXMemoryLimitReceiptBindingRequired: true,
                configuredMLXCacheLimitByteCount: 0,
                configuredMLXCacheLimitSetter: "MLX.Memory.cacheLimit",
                configuredMLXCacheLimitSetCount: 1,
                configuredMLXCacheLimitReadbackRequired: true,
                postDeallocationClearCacheCount: 1,
                minimumConfiguredMLXMemoryLimitByteCount: 4_337_713_152,
                preflightAbstainWhenConfiguredMLXMemoryLimitBelowMinimum: true,
                minimumAvailableFilesystemByteCount: 12_884_901_888,
                preflightAbstainWhenAvailableFilesystemBelowMinimum: true,
                mlxLimitIsNotProcessRSSLimit: true,
                statfsIsObservationNotCheckpointDiskSufficiencyClaim: true,
                separateResourceOnlyProbeRequired: true),
            environment: .init(
                requiredBindings: [
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
                mlxEnableTF32: "0",
                exactMLXRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                runtimeMetallibFilename: "default.metallib",
                runtimeMetallibDiscoveryAndStagingPathRule:
                    "one_fresh_absolute_realpath_staged_into_the_release_executable_resource_bundle",
                runtimeMetallibCandidateCount: 1,
                runtimeMetallibPathByteCountAndSHA256ReceiptBindingsRequired:
                    true,
                runtimeMetallibRetained: false,
                runtimeMetallibUploaded: false,
                metalDeviceIndex: 0,
                exactMetalDeviceCount: 1,
                singletonDeviceEnumerationRequired: true,
                indexZeroMustMatchDefaultDevice: true,
                exclusiveMetalDeviceLeaseRequired: true,
                leaseType: "PrimeMetalDeviceLease",
                leaseModule: "PrimeCore",
                leaseAcquisitionMode:
                    "flock_LOCK_EX_or_LOCK_NB_nonblocking_exclusive",
                workerIsSoleAcquirerAndOwnerWhenAcquired: true,
                kernelReleasesWorkerLeaseOnFatalTermination: true,
                swiftPMBuildConfiguration: "release",
                mlxGraphCompileMode: "eager_uncompiled_no_compile_transform",
                mlxCompileTransformInvocationCount: 0,
                mlxExecutionDeviceConstruction:
                    "Device(.gpu,index:Int32(0))",
                mlxExecutionDeviceType: "gpu",
                mlxExecutionDeviceConstructorIndex: 0,
                mlxDeviceIndexEvidence:
                    "constructor_argument_not_runtime_readback",
                mlxDeviceIndexRuntimeReadbackAvailable: false,
                mlxDeviceEqualityNotUsedForIdentity: true,
                mlxDeviceTypeObservationAPI:
                    "executionDevice.deviceType==.gpu",
                mlxDefaultDeviceScopeAPI:
                    "Device.withDefaultDevice(executionDevice)",
                mlxDefaultDeviceObjectIdentityAPI:
                    "Device.defaultDevice()===executionDevice",
                mlxDefaultDeviceObjectIdentityRequired: true,
                mlxDefaultGPUStreamRequired: true,
                mlxDefaultGPUStreamObservationAPI:
                    "Stream()==Stream.gpu",
                mlxCPUFallbackAuthorized: false,
                mlxExecutionScopeCoversModelAllocationThroughLexicalDeallocation:
                    true,
                mlxGPUIndexEqualsMetalDeviceIndexRequired: true,
                activeCheckoutDepth: 1,
                reviewedCheckoutDepth: 1,
                authorityClosureActiveJobTimeoutMinutes: 45,
                authorityClosureReviewedJobTimeoutMinutes: 60,
                authorityClosureWorkflowTimeoutMutationAuthorized: false,
                successorActiveJobTimeoutMinutes: 45,
                successorReviewedJobTimeoutMinutes: 90,
                successorReviewedWorkflowTimeoutMutationAuthorized: true,
                secureFetchMutationAuthorized: false,
                memorySourceRepository: "Ergentics/ergentics-mlx-swift",
                memorySourceRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                memorySourcePath: "Source/MLX/Memory.swift",
                memorySourceMode: "100644",
                memorySourceGitBlob:
                    "89baf9cc69d7e4f046467f197ce9da8a309248c3",
                memorySourceByteCount: 12_919,
                memorySourceLFByteCount: 361,
                memorySourceSHA256:
                    "cb6976cc37aa3e8a0fa1be8269fea2869ecdf5951e469556f67e21604b1701f8",
                optimizerSourceRepository: "Ergentics/ergentics-mlx-swift",
                optimizerSourceRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                optimizerSourcePath: "Source/MLXOptimizers/Optimizers.swift",
                optimizerSourceMode: "100644",
                optimizerSourceGitBlob:
                    "fb9c5d9636a211bb74fae7bf6a1dbbd4fe01d7b9",
                optimizerSourceByteCount: 24_109,
                optimizerSourceLFByteCount: 698,
                optimizerSourceSHA256:
                    "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d",
                mlxPeakMemoryResetBeforeProbeRequired: true,
                mlxPeakMemoryResetAPI: "MLX.Memory.peakMemory = 0",
                mlxPeakMemoryResetCount: 1,
                mlxPeakMemoryResetOrder:
                    "after_memory_and_cache_limit_set_and_readback_before_preflight_snapshot_and_model_allocation",
                physicalMemoryCapacityObservationRequired: true,
                darwinTaskResidentAndPhysicalFootprintObservationRequired: true,
                getrusageMaxRSSObservationRequired: true,
                mlxActiveCacheAndPeakBytesObservationRequired: true,
                filesystemCapacityAndAvailableBytesObservationRequired: true,
                filesystemObservationTarget:
                    "resolved_swiftpm_scratch_directory_containing_release_executable",
                filesystemObservationUsesStatFS: true,
                filesystemObservationRequiresScratchAndExecutableSameFSID:
                    true,
                filesystemObservationFSIDEncoding:
                    "darwin_fsid_t_ordered_two_int32_decimal_json_array",
                filesystemResolvedTargetPathRule:
                    "realpath_or_URL.resolvingSymlinksInPath.standardizedFileURL_of_absolute_parent_directory_containing_actually_launched_release_executable",
                filesystemTargetPathValidationRule:
                    "absolute_physical_UTF8_existing_directory_no_dot_or_dotdot_no_trailing_slash_and_not_root",
                filesystemExecutableAndParentStatFSRule:
                    "statfs_resolved_executable_and_parent_require_identical_ordered_fsid_and_all_six_snapshots_retain_that_pair",
                filesystemResolutionOrFSIDDriftClassification:
                    "topology_dtype",
                cumulativeWorkerProbeElapsedObservationRequired: true,
                requiredMetricKeysAtEveryCompletedBoundary: [
                    "cumulative_worker_probe_elapsed_nanoseconds",
                    "physical_memory_capacity_bytes",
                    "task_resident_bytes",
                    "task_physical_footprint_bytes",
                    "getrusage_max_rss_bytes",
                    "mlx_active_bytes",
                    "mlx_cache_bytes",
                    "mlx_peak_bytes",
                    "metal_current_allocated_bytes",
                    "filesystem_capacity_bytes",
                    "filesystem_available_bytes",
                ],
                physicalMemoryMetricSource:
                    "ProcessInfo.processInfo.physicalMemory_bytes",
                darwinTaskMetricSource:
                    "task_info_TASK_VM_INFO_resident_size_and_phys_footprint_bytes",
                getrusageMetricSource:
                    "getrusage_RUSAGE_SELF_ru_maxrss_macos_bytes",
                mlxMemoryMetricSource:
                    "MLX.Memory_activeMemory_cacheMemory_peakMemory_bytes",
                filesystemMetricFormula:
                    "capacity=checked_UInt64(f_blocks)*checked_UInt64(f_bsize);available=checked_UInt64(f_bavail)*checked_UInt64(f_bsize)_using_multipliedReportingOverflow_nonnegative_representable_operands",
                cumulativeElapsedMetricSource:
                    "ContinuousClock_elapsed_overflow_safe_nanoseconds",
                overflowCheckedMetricConversionsRequired: true,
                metalCurrentAllocatedSizeObservationRequired: true,
                metalCurrentAllocatedSizeMetricSource:
                    "MTLDevice.currentAllocatedSize_bytes",
                metalCurrentAllocatedSizeUsesRetainedSingletonDeviceRequired:
                    true,
                metalDeviceHasUnifiedMemoryRequired: true,
                metalDeviceNameRegistryUnifiedMemoryRecommendedAndBufferBindingsRequired:
                    true,
                successfulLeaseAcquisitionPrecedesCoreGraphicsMetalOrMLX: true,
                passLeaseHeldThroughCandidateFlushAndPostflight: true,
                postAcquisitionFatalRequiresChildTerminationThenSupervisorReacquireReleaseProof:
                    true,
                leaseBusyRequiresAcquiredFalseAndCleanupProofNotApplicable:
                    true,
                leaseBusyNeverWaitsOrSteals: true),
            futureProbe: .init(
                buildCount: 1,
                releaseBuildCommand:
                    "swift build --package-path Tests/PrimeNativeDecoderTrainingValidation --configuration release --build-tests",
                releaseBuildCompilesDefaultProductsAndTests: true,
                releaseContractXCTestCommand:
                    "swift test --package-path Tests/PrimeNativeDecoderTrainingValidation --configuration release --skip-build --filter PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests/testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure",
                releaseContractXCTestUsesSkipBuild: true,
                releaseBinPathResolutionCommand:
                    "swift build --package-path Tests/PrimeNativeDecoderTrainingValidation --configuration release --show-bin-path",
                releaseBinPathResolutionCompilationCount: 0,
                releaseExecutableDirectInvocationRule:
                    "invoke_resolved_release_bin_path/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe_directly_never_swift_run",
                swiftRunInvocationCount: 0,
                additionalBuildCount: 0,
                stage6LauncherInvocationCount: 1,
                directXCTestCount: 1,
                directExecutableProbeCount: 1,
                aggregateDirectInvocationCount: 2,
                supervisorProcessCount: 1,
                maximumWorkerProcessCount: 1,
                workerSpawnAttemptCount: 1,
                modelAllocationCount: 1,
                modelMaterializationCount: 1,
                valueAndGradCount: 1,
                trainingLogitsCount: 1,
                crossEntropyCount: 1,
                forwardLossCount: 1,
                backwardCount: 1,
                gradientNormCount: 1,
                gradientClipCount: 1,
                optimizerStepCount: 1,
                adamWUpdateCount: 1,
                fullGraphEvaluationCount: 1,
                kvCacheAllocationCount: 0,
                evaluationForwardPassCount: 0,
                checkedTensorMaterializationEvaluationRequired: true,
                fullGraphEvaluationMeansTensorMaterializationNotEvaluationPass:
                    true,
                checkedEvaluationAPI: "checkedEval",
                gpuSynchronizationAPI: "Stream.gpu.synchronize()",
                orderedCheckedEvaluationAndSynchronizationBarriers: [
                    "post_model_materialization_all_model_parameters_and_before_fingerprint_samples",
                    "post_forward_backward_loss_and_all_gradients",
                    "pre_clip_raw_gradient_norm_before_host_scalar_read",
                    "post_norm_clip_all_clipped_gradients",
                    "post_adam_update_all_model_parameters_both_moment_catalogs_and_after_fingerprint_samples",
                ],
                checkedEvaluationBarrierCount: 5,
                gpuSynchronizationBarrierCount: 5,
                phaseMetricsSampledOnlyAfterApplicableBarrier: true,
                hostScalarAndFingerprintReadsImmediatelyAfterApplicableSynchronization:
                    true,
                finalFullStateBarrierIncludesModelAndBothMomentCatalogs: true,
                resourceMeasurementBoundaries: [
                    "preflight",
                    "post_model_materialization",
                    "post_forward_backward",
                    "post_norm_clip",
                    "post_adam_update_full_evaluation",
                    "post_lexical_deallocation_and_clear_cache",
                ],
                resourceMeasurementBoundaryEndRules: [
                    "preflight:after_device_limit_statfs_checks_and_metric_snapshot",
                    "post_model_materialization:immediately_after_barrier_1_and_metric_snapshot",
                    "post_forward_backward:immediately_after_barrier_2_and_metric_snapshot",
                    "post_norm_clip:immediately_after_barrier_4_and_metric_snapshot",
                    "post_adam_update_full_evaluation:immediately_after_barrier_5_and_metric_snapshot",
                    "post_lexical_deallocation_and_clear_cache:after_lexical_deallocation_MLX.Memory.clearCache_and_final_metric_snapshot",
                ],
                phaseElapsedSemantics:
                    "cumulative_from_worker_probe_epoch_to_boundary_snapshot",
                workerProbeEpoch:
                    "first_child_instruction_before_nonblocking_lease_attempt",
                phaseIntervalPartitionRule:
                    "preflight=[epoch,end0];each_later_phase=(prior_end,current_end];observed_prefix_contiguous_no_overlap_no_gap",
                phaseCumulativeElapsedStrictlyIncreasesAcrossObservedPrefix:
                    true,
                unavailablePhaseCumulativeElapsedMustBeNull: true,
                lastObservedPhaseElapsedMustBeLessThanOrEqualWorkerActiveElapsed:
                    true,
                filesystemFSIDMustRemainStableAcrossObservedPhases: true,
                filesystemInvalidOrOverflowClassification: "topology_dtype",
                preflightAvailableFilesystemComparison:
                    "available>=12884901888_else_preflight_floor",
                allocatedProbeFunctionInlining: "@inline(never)",
                allocatedProbeFunctionName: "runAllocatedProbe",
                allocatedProbeFunctionReturnType: "PureSwiftProbeObservation",
                allocatedProbeReturnAllowsMLXOrReferenceEscape: false,
                allocatedProbeLiveSetRules: [
                    "preflight:no_MLX_tensors",
                    "post_model:model_and_before_fingerprint_sample_views_retained_through_barrier_1_host_hash_and_immediate_snapshot_then_sample_views_dropped",
                    "post_forward_backward:forward_helper_retains_model_input_mask_loss_and_raw_218_gradients_through_barrier_2_and_immediate_snapshot",
                    "post_norm_clip:forward_helper_retains_model_input_mask_loss_raw_218_gradients_raw_norm_scalar_and_one_clipped_218_catalog_through_barrier_4_and_immediate_snapshot_then_returns_only_evaluated_clipped_catalog_and_pure_Swift_loss_norm_scale_so_raw_input_mask_loss_and_closure_drop_before_AdamW",
                    "post_adam:model_218_optimizer_innerState_436_clipped_218_and_after_fingerprint_sample_views_retained_through_barrier_5_host_hash_and_immediate_snapshot_before_any_catalog_or_view_release",
                    "post_deallocation:allocated_function_returns_all_graph_objects_release_MLX.Memory.clearCache_once_final_snapshot_then_postflight_no_MLXArray_Module_Optimizer_Evaluatable_closure_or_Any_refs_escape",
                ],
                memoryClearCacheCount: 1,
                memoryClearCacheOccursAfterAllocatedProbeReturnAndBeforeFinalSnapshot:
                    true,
                postflightDeviceReenumerationCount: 1,
                postflightRunsAfterFinalDeallocationSnapshot: true,
                postflightRunsWhileLeaseHeldAndInsideSuppliedDefaultDeviceScope:
                    true,
                postflightDeviceIdentityBindingsMustEqualPreflight: true,
                postflightCurrentAllocatedSizeEqualityCheckAuthorized: false,
                postflightMLXPolicyAndLimitReadbacksMustEqualPreflight: true,
                postflightMismatchClassification: "topology_dtype",
                completedBoundaryMetricInventoryRequired: true,
                fatalOutcomeLaterBoundaryMetricsMayBeUnavailable: true,
                workerActiveTimeoutSeconds: 1_200,
                supervisorEndToEndTimeoutSeconds: 1_500,
                terminationGraceSeconds: 10,
                receiptPrefix:
                    "PRIME_NATIVE_DECODER_STAGE6_NATIVE300M_RESOURCE_ONLY_ONE_STEP_RECEIPT=",
                receiptCount: 1,
                normativeMaximumWorkerCandidateFrameCount: 1,
                passWorkerCandidateFrameCount: 1,
                abstainAcceptedWorkerCandidateCount: 0,
                workerCandidateIsCapturedAndNeverEmittedWithCanonicalPrefix:
                    true,
                workerCanonicalReceiptPrefixEmissionCount: 0,
                supervisorEmittedCanonicalReceiptCount: 1,
                supervisorCanonicalReceiptStdoutLineCount: 1,
                receiptFileCount: 0,
                fatalOutcomeStillRequiresSupervisorCanonicalReceipt: true,
                supervisorSynthesizesABSTAINReceiptWhenWorkerCandidateAbsent:
                    true,
                passRequirements: [
                    "exact_parameter_counts_shapes_and_float32_dtypes",
                    "finite_loss_and_gradient_norm",
                    "nonzero_gradient_norm",
                    "sampled_parameter_fingerprint_changed",
                    "complete_phase_resource_metrics",
                    "postflight_device_and_lease_identity",
                ],
                abstainClasses: [
                    "worker_spawn_failure", "preflight_floor",
                    "lease_busy",
                    "oom",
                    "timeout",
                    "signal",
                    "nonfinite",
                    "topology_dtype",
                    "no_update",
                    "executor_receipt_drift",
                ],
                oneExactMainOpportunityAfterGreenAuthorityClosure: true,
                retryAuthorized: false,
                rerunAuthorized: false,
                replacementRunAuthorized: false,
                checkpointReadCount: 0,
                checkpointWriteCount: 0,
                artifactUploadCount: 0,
                qualityMetricComputationCount: 0,
                generatedTokenCount: 0),
            receiptContract: .init(
                schemaID:
                    "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_receipt_v1",
                receiptID:
                    "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_receipt_v1",
                receiptPrefix:
                    "PRIME_NATIVE_DECODER_STAGE6_NATIVE300M_RESOURCE_ONLY_ONE_STEP_RECEIPT=",
                authorityIDBinding:
                    "prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1",
                authorityCanonicalSHA256Binding:
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1.canonicalSHA256",
                authorityBaseRevisionBinding:
                    "f5a9638194c53922f09c39c3c76095b5cc47c25e",
                authorityBaseTreeBinding:
                    "a17a8f92604157c0de0252dbc30cf22681d6a13d",
                authorityClosureRunBindingRequired: true,
                authorityClosureRequiredEvent: "push",
                authorityClosureRequiredRef: "refs/heads/main",
                authorityClosureRequiredAttempt: 1,
                authorityClosureRequiredStatus: "completed",
                authorityClosureRequiredConclusion: "success",
                authorityClosureRequiredJobConclusion: "success",
                authorityClosureRequiredArtifactCount: 0,
                authorityClosureRequiredRerunCount: 0,
                authorityClosureRevisionMustEqualWorkflowHeadAndMechanicsFirstParent:
                    true,
                mechanicsRequiredEvent: "push",
                mechanicsRequiredRef: "refs/heads/main",
                mechanicsRequiredAttempt: 1,
                topLevelKeys: [
                    "authority", "ceiling", "configuration", "environment",
                    "execution", "lease", "limits", "outcome",
                    "phase_metrics", "receipt_id", "schema_version",
                ],
                authorityKeys: [
                    "authority_canonical_sha256", "authority_id",
                    "authority_source_git_blob", "authority_source_sha256",
                    "authority_test_git_blob", "authority_test_sha256",
                ],
                ceilingKeys: [
                    "additional_execution_or_rerun_authorized",
                    "artifact_upload_authorized",
                    "broad_native300m_training_authorized",
                    "candidate_admission_granted", "canary_authorized",
                    "checkpoint_admission_granted",
                    "downstream_trial_authorized",
                    "durable_checkpoint_io_authorized",
                    "exact_metal_gradient_bytes_established",
                    "metal_determinism_established",
                    "model_quality_established", "product_use_authorized",
                    "publication_authorized", "quantization_authorized",
                    "ordinary_job_fit_established",
                    "repeated_trajectory_determinism_established",
                    "retained_artifact_authorized",
                    "stage5_assay_clearance_established",
                    "stage5_mechanics_success_established",
                    "stage5_replacement_execution_authorized",
                    "stage5_result_established",
                    "stage7_authority_established", "stage7_authorized",
                    "general_training_resume_established",
                    "native300m_trajectory_training_resume_established",
                ],
                configurationKeys: [
                    "adamw_beta1_float32_bits", "adamw_beta2_float32_bits",
                    "adamw_bias_correction_applied",
                    "adamw_epsilon_float32_bits",
                    "adamw_learning_rate_float32_bits",
                    "adamw_weight_decay_float32_bits", "batch_size",
                    "batch_token_ids_sha256", "completion_mask_dtype",
                    "cross_entropy_api", "cross_entropy_reduction",
                    "gradient_accumulation_count", "gradient_clip_algorithm_id",
                    "gradient_clip_mode",
                    "gradient_norm_epsilon_float32_bits",
                    "initialization_seed", "logits_dtype", "loss_dtype",
                    "loss_graph_algorithm_id",
                    "maximum_gradient_norm_float32_bits",
                    "model_configuration_factory", "model_factory",
                    "optimizer_qualified_type", "optimizer_state_inspection_api",
                    "optimizer_state_pair_topology", "optimizer_step_count",
                    "parameter_dtype", "parameter_path_count",
                    "parameter_fingerprint_algorithm_id",
                    "parameter_fingerprint_expected_path_count",
                    "parameter_fingerprint_expected_sample_count",
                    "parameter_fingerprint_samples_per_path",
                    "per_target_loss_dtype",
                    "per_target_loss_expected_element_count",
                    "per_target_loss_expected_shape",
                    "raw_gradient_norm_algorithm_id", "selected_target_count",
                    "sequence_length", "token_id_dtype", "training_logits_api",
                    "unique_parameter_count", "valid_token_count",
                    "value_and_grad_api", "post_model_full_state_evaluation_api",
                    "post_update_full_state_evaluation_api",
                ],
                environmentKeys: [
                    "metal_device_count", "metal_device_index",
                    "metal_device_is_default",
                    "metal_device_max_buffer_length_bytes",
                    "metal_device_max_recommended_working_set_bytes",
                    "metal_device_has_unified_memory",
                    "metal_device_name", "metal_device_registry_id",
                    "mlx_compile_transform_invocation_count",
                    "mlx_cpu_fallback_used", "mlx_default_device_is_supplied_device",
                    "mlx_default_stream_is_gpu", "mlx_device_constructor_index",
                    "mlx_device_type",
                    "mlx_enable_tf32", "mlx_revision",
                    "operating_system_build", "filesystem_observation_fsid",
                    "filesystem_observation_path", "runtime_metallib_byte_count",
                    "runtime_metallib_path", "runtime_metallib_sha256",
                    "swift_sdk", "swift_version",
                    "swiftpm_build_configuration", "xcode_version",
                ],
                executionKeys: [
                    "authority_closure_active_job_conclusion",
                    "authority_closure_active_job_id",
                    "authority_closure_artifact_count",
                    "authority_closure_check_suite_id",
                    "authority_closure_conclusion",
                    "authority_closure_event", "authority_closure_ref",
                    "authority_closure_rerun_count",
                    "authority_closure_revision",
                    "authority_closure_reviewed_job_conclusion",
                    "authority_closure_reviewed_job_id",
                    "authority_closure_run_attempt",
                    "authority_closure_run_id", "authority_closure_run_number",
                    "authority_closure_status", "authority_closure_tree",
                    "authority_base_revision", "authority_base_tree",
                    "build_count", "direct_executable_probe_count",
                    "direct_xctest_count", "exact_changed_source_identities",
                    "launcher_invocation_count",
                    "mechanics_event",
                    "mechanics_head_ordered_parent_revisions",
                    "mechanics_head_revision", "mechanics_head_tree",
                    "mechanics_ref", "mechanics_run_attempt", "mechanics_run_id",
                    "mechanics_run_number", "provenance_source_identities",
                    "repository",
                    "supervisor_end_to_end_elapsed_nanoseconds",
                    "supervisor_process_count", "worker_exit_code",
                    "supervisor_timeout_trigger_elapsed_nanoseconds",
                    "supervisor_timeout_triggered", "timeout_scope",
                    "worker_active_elapsed_nanoseconds",
                    "worker_process_count", "worker_signal",
                    "worker_candidate_frame_count",
                    "worker_last_complete_frame_sequence",
                    "worker_progress_frame_count",
                    "worker_spawn_attempt_count", "worker_spawn_errno",
                    "worker_spawn_succeeded",
                    "worker_trailing_partial_frame_discarded",
                    "worker_transport_drift_detected",
                    "worker_timeout_trigger_elapsed_nanoseconds",
                    "worker_timeout_triggered",
                ],
                sourceIdentityKeys: [
                    "byte_count", "git_blob", "mode", "path", "sha256",
                ],
                leaseKeys: [
                    "acquired_before_coregraphics_metal_or_mlx",
                    "acquired_nonblocking", "held_through_candidate_flush",
                    "held_through_postflight", "lease_path",
                    "supervisor_reacquire_release_proved", "type",
                    "worker_owned",
                ],
                limitsKeys: [
                    "available_filesystem_floor_bytes",
                    "configured_cache_limit_bytes",
                    "configured_cache_limit_readback_bytes",
                    "configured_memory_limit_bytes",
                    "configured_memory_limit_formula",
                    "configured_memory_limit_readback_bytes",
                    "container_headers_and_manifests_included_in_minimum",
                    "duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum",
                    "gradient_logical_bytes",
                    "minimum_committed_tensor_state_bytes",
                    "minimum_memory_limit_floor_bytes",
                    "minimum_state_plus_gradient_bytes",
                    "mlx_limit_is_not_rss_limit",
                    "optimizer_moment_logical_bytes",
                    "optimizer_moment_tensor_count",
                    "statfs_is_observational_only",
                    "supervisor_end_to_end_timeout_seconds",
                    "termination_grace_seconds",
                    "three_times_committed_state_disk_comparator_bytes",
                    "validated_first_moment_tensor_count",
                    "validated_gradient_logical_bytes",
                    "validated_gradient_path_count",
                    "validated_optimizer_moment_logical_bytes",
                    "validated_parameter_path_count",
                    "validated_second_moment_tensor_count",
                    "validated_unique_parameter_count",
                    "validated_weights_logical_bytes",
                    "weights_logical_bytes", "worker_active_timeout_seconds",
                ],
                outcomeKeys: [
                    "classification", "gradient_clip_scale_float32_bits",
                    "loss_float32_bits", "one_shot_consumed",
                    "operation_counts",
                    "parameter_fingerprint_after",
                    "parameter_fingerprint_before",
                    "parameter_fingerprint_sample_count",
                    "parameter_fingerprint_sample_plan_sha256",
                    "postflight_device_identity_matches_preflight",
                    "postflight_mlx_policy_and_limits_match_preflight",
                    "raw_gradient_norm_float32_bits",
                    "resource_clearance_established",
                    "resource_envelope_established", "resource_probe_executed",
                    "runner_memory_capacity_established", "status",
                    "update_occurred", "worker_candidate_present",
                ],
                outcomeTransitionKeys: [
                    "one_shot_consumed",
                    "resource_clearance_established",
                    "resource_envelope_established", "resource_probe_executed",
                    "runner_memory_capacity_established",
                ],
                outcomeTransitionRules: [
                    "one_shot_consumed:true_for_every_terminal_supervisor_receipt",
                    "resource_clearance_established:PASS_true_ABSTAIN_false",
                    "resource_envelope_established:PASS_true_ABSTAIN_false",
                    "resource_probe_executed:true_iff_recorded_attempted_model_allocation_count_equals_1_false_before_that_attempt",
                    "runner_memory_capacity_established:true_iff_metal_device_has_unified_memory_is_true_and_any_observed_phase_has_nonnull_physical_memory_capacity_bytes",
                ],
                operationCountKeys: [
                    "adamw_update_count", "backward_count",
                    "checked_evaluation_barrier_count",
                    "cross_entropy_count", "evaluation_forward_pass_count",
                    "forward_loss_count", "full_graph_evaluation_count",
                    "gpu_synchronization_barrier_count",
                    "gradient_clip_count", "gradient_norm_count",
                    "kv_cache_allocation_count",
                    "memory_clear_cache_count",
                    "mlx_peak_memory_reset_count",
                    "model_allocation_count", "model_materialization_count",
                    "optimizer_step_count",
                    "postflight_device_reenumeration_count",
                    "training_logits_count",
                    "value_and_grad_count",
                ],
                phaseNames: [
                    "preflight", "post_model_materialization",
                    "post_forward_backward", "post_norm_clip",
                    "post_adam_update_full_evaluation",
                    "post_lexical_deallocation_and_clear_cache",
                ],
                phaseMetricKeys: [
                    "phase", "availability", "unavailable_reason",
                    "cumulative_worker_probe_elapsed_nanoseconds",
                    "physical_memory_capacity_bytes", "task_resident_bytes",
                    "task_physical_footprint_bytes",
                    "getrusage_max_rss_bytes", "mlx_active_bytes",
                    "mlx_cache_bytes", "mlx_peak_bytes",
                    "metal_current_allocated_bytes",
                    "filesystem_capacity_bytes",
                    "filesystem_available_bytes",
                ],
                nullableNumericMetricKeys: [
                    "cumulative_worker_probe_elapsed_nanoseconds",
                    "physical_memory_capacity_bytes", "task_resident_bytes",
                    "task_physical_footprint_bytes",
                    "getrusage_max_rss_bytes", "mlx_active_bytes",
                    "mlx_cache_bytes", "mlx_peak_bytes",
                    "metal_current_allocated_bytes",
                    "filesystem_capacity_bytes",
                    "filesystem_available_bytes",
                ],
                nullableEnvironmentObservationKeys: [
                    "metal_device_count", "metal_device_index",
                    "metal_device_is_default",
                    "metal_device_max_buffer_length_bytes",
                    "metal_device_max_recommended_working_set_bytes",
                    "metal_device_has_unified_memory", "metal_device_name",
                    "metal_device_registry_id",
                    "mlx_cpu_fallback_used",
                    "mlx_default_device_is_supplied_device",
                    "mlx_default_stream_is_gpu", "mlx_device_constructor_index",
                    "mlx_device_type", "filesystem_observation_fsid",
                    "filesystem_observation_path",
                ],
                nullableLimitObservationKeys: [
                    "configured_memory_limit_bytes",
                    "configured_memory_limit_readback_bytes",
                    "configured_cache_limit_readback_bytes",
                    "validated_parameter_path_count",
                    "validated_unique_parameter_count",
                    "validated_weights_logical_bytes",
                    "validated_gradient_path_count",
                    "validated_gradient_logical_bytes",
                    "validated_first_moment_tensor_count",
                    "validated_second_moment_tensor_count",
                    "validated_optimizer_moment_logical_bytes",
                ],
                nullableOutcomeObservationKeys: [
                    "loss_float32_bits", "raw_gradient_norm_float32_bits",
                    "gradient_clip_scale_float32_bits",
                    "parameter_fingerprint_before",
                    "parameter_fingerprint_after",
                    "parameter_fingerprint_sample_plan_sha256",
                    "parameter_fingerprint_sample_count",
                    "postflight_device_identity_matches_preflight",
                    "postflight_mlx_policy_and_limits_match_preflight",
                    "update_occurred",
                ],
                nullableExecutionTerminationKeys: [
                    "worker_exit_code", "worker_signal",
                    "worker_spawn_errno",
                    "worker_last_complete_frame_sequence",
                    "worker_active_elapsed_nanoseconds",
                    "worker_timeout_trigger_elapsed_nanoseconds",
                    "supervisor_timeout_trigger_elapsed_nanoseconds",
                    "timeout_scope",
                ],
                timeoutScopeDomain: [
                    "worker_active", "supervisor_end_to_end",
                    "worker_active_and_supervisor_end_to_end",
                ],
                statusDomain: ["PASS", "ABSTAIN"],
                classificationDomain: [
                    "pass", "worker_spawn_failure", "preflight_floor",
                    "lease_busy", "oom",
                    "timeout", "signal", "nonfinite", "topology_dtype",
                    "no_update", "executor_receipt_drift",
                ],
                phaseAvailabilityDomain: [
                    "observed", "unavailable_before_probe_start",
                    "unavailable_after_fatal",
                    "unavailable_after_classification",
                ],
                classificationAvailabilityRules: [
                    "pass:all_six_observed",
                    "worker_spawn_failure:all_six_unavailable_before_probe_start",
                    "preflight_floor:preflight_observed_then_unavailable_after_classification_suffix",
                    "lease_busy:all_six_unavailable_before_probe_start",
                    "oom:possibly_empty_observed_prefix_then_unavailable_after_fatal_suffix",
                    "timeout:possibly_empty_observed_prefix_then_unavailable_after_fatal_suffix",
                    "signal:possibly_empty_observed_prefix_then_unavailable_after_fatal_suffix",
                    "nonfinite:observed_prefix_then_unavailable_after_classification_suffix",
                    "topology_dtype:possibly_empty_observed_prefix_then_unavailable_after_classification_suffix",
                    "no_update:observed_prefix_then_unavailable_after_classification_suffix",
                    "executor_receipt_drift:possibly_empty_observed_prefix_then_unavailable_after_classification_suffix",
                ],
                unavailableMetricEncoding: "JSON_null_with_keys_present",
                nonPhaseUnavailableEncoding: "JSON_null_with_keys_present",
                byteUnit: "bytes",
                durationUnit: "nanoseconds",
                canonicalSortedJSONRequired: true,
                passRequiresWorkerCandidate: true,
                passRequiresAllSixObservedBoundaries: true,
                passRequiresMonotonicElapsedPeakAndMaxRSS: true,
                passRequiresExactOperationCountsAndUpdateChecks: true,
                receiptLossAndGradientBindingsMustEqualConfiguration: true,
                passRawGradientNormFiniteAndPositive: true,
                passGradientClipScaleBitwiseEqualsFrozenFormula: true,
                operationCountsRecordAttemptedInvocationsIncludingFatalAttempt:
                    true,
                abstainRequiresPossiblyEmptyObservedPrefixAndExplicitUnavailableSuffix:
                    true,
                abstainPhasePartitionRule:
                    "all_six_rows_present_as_contiguous_possibly_empty_observed_prefix_plus_possibly_empty_unavailable_suffix",
                abstainUnavailableSuffixMayBeEmptyOnlyWhenAllSixBoundariesWereObservedBeforeClassification:
                    true,
                emptyObservedPrefixRule:
                    "allowed_only_for_worker_spawn_failure_lease_busy_topology_dtype_before_first_boundary_or_child_fatal_before_first_boundary",
                unavailableSuffixRequiresAllNumericMetricKeysPresentAndNull:
                    true,
                phaseAndAvailabilityMetadataAlwaysNonNull: true,
                unavailableReasonKeyAlwaysPresent: true,
                unavailableReasonNullIffAvailabilityObserved: true,
                unavailableReasonEqualsClassificationIffAvailabilityUnavailable:
                    true,
                environmentObservationAtomicProgressRule:
                    "all_eight_device_fields_atomically_nonnull_only_after_post_lease_identity_progress_and_all_null_for_lease_busy",
                mlxExecutionPolicyAtomicProgressRule:
                    "mlx_execution_policy:all_five_atomic_nonnull_after_post_lease_mlx_execution_policy_progress_else_all_null",
                filesystemObservationAtomicProgressRule:
                    "filesystem_observation_path_and_fsid_atomic_nonnull_after_resolved_swiftpm_scratch_and_release_executable_same_fsid_progress_else_both_null_and_all_six_phase_statfs_reads_use_that_same_target_fsid",
                limitObservationAtomicProgressRule:
                    "all_three_configured_and_readback_fields_atomically_nonnull_only_after_memory_and_cache_set_readback_progress",
                validatedModelCatalogAtomicProgressRule:
                    "validated_parameter_path_count_unique_parameter_count_and_weights_logical_bytes_atomic_after_model_catalog_else_all_null",
                validatedGradientCatalogAtomicProgressRule:
                    "validated_gradient_path_count_and_gradient_logical_bytes_atomic_after_gradient_catalog_else_all_null",
                validatedMomentCatalogAtomicProgressRule:
                    "validated_first_and_second_moment_tensor_counts_and_optimizer_moment_logical_bytes_atomic_after_adam_state_catalog_else_all_null",
                validatedOptimizerMomentParityDerivationRule:
                    "validated_first_moment_is_even_innerState_indices_and_second_moment_is_odd_innerState_indices_with_no_per_path_moment_naming_claim",
                outcomeObservationProgressRules: [
                    "parameter_fingerprint_sample_plan_sha256:nonnull_at_post_model_materialization_else_null",
                    "parameter_fingerprint_sample_count:nonnull_at_post_model_materialization_else_null",
                    "parameter_fingerprint_before:nonnull_at_post_model_materialization_else_null",
                    "loss_float32_bits:nonnull_at_post_forward_backward_else_null",
                    "raw_gradient_norm_float32_bits:nonnull_at_post_norm_clip_else_null",
                    "gradient_clip_scale_float32_bits:nonnull_at_post_norm_clip_else_null",
                    "parameter_fingerprint_after:nonnull_at_post_adam_update_full_evaluation_else_null",
                    "postflight_device_identity_matches_preflight:nonnull_after_postflight_device_reenumeration_else_null",
                    "postflight_mlx_policy_and_limits_match_preflight:nonnull_after_postflight_device_reenumeration_else_null",
                    "update_occurred:nonnull_at_post_adam_update_full_evaluation_else_null",
                ],
                executionTerminationObservationRule:
                    "after_waitpid_exactly_one_of_worker_exit_code_or_worker_signal_is_nonnull_iff_child_existed_and_both_are_null_if_no_child",
                workerSpawnObservationRule:
                    "worker_spawn_attempt_count_is_1;worker_spawn_succeeded_true_iff_child_exists;worker_spawn_errno_nonnull_iff_spawn_failed",
                workerSpawnFailureRule:
                    "no_child_no_candidate_worker_process_count_0_worker_timeout_triggered_false_worker_exit_signal_active_elapsed_timeout_trigger_elapsed_and_scope_null_all_operation_counts_0_one_shot_consumed_true_probe_envelope_clearance_capacity_false_dynamic_observations_null_lease_false_or_not_applicable_supervisor_elapsed_and_triggered_nonnull_supervisor_synthesizes_one_canonical_ABSTAIN_and_exits_0",
                executorReceiptDriftRule:
                    "candidate_zero_preserves_valid_terminal_progress_preflight_floor_lease_busy_nonfinite_topology_dtype_or_no_update_or_supervisor_derived_oom_timeout_signal_from_last_valid_progress_and_wait_status;candidate_absence_is_executor_receipt_drift_only_if_PASS_claimed_or_required_evidence_insufficient_or_transport_or_candidate_malformed_or_duplicate;missing_or_invalid_supervisor_receipt_or_supervisor_failure_is_nonzero",
                timeoutObservationRule:
                    "worker_timeout_triggered_is_false_when_no_child_else_boolean;timeout_scope_and_each_trigger_elapsed_are_null_iff_no_corresponding_trigger_and_scope_exactly_matches_true_trigger_booleans",
                workerActiveIntervalRule:
                    "supervisor_instant_immediately_before_successful_spawn_invocation_through_terminal_waitpid_return",
                supervisorEndToEndIntervalRule:
                    "immediately_before_spawn_attempt_through_terminal_waitpid_if_child_or_spawn_failure_determination_if_none_pipe_drain_lease_disposition_fd_close_and_candidate_validation_immediately_before_receipt_encoding",
                passAndNonTimeoutABSTAINTimingRule:
                    "both_timeout_triggers_false_scope_and_trigger_elapsed_null_and_applicable_elapsed_below_caps",
                timeoutABSTAINTimingRule:
                    "scope_matches_trigger_booleans_each_trigger_elapsed_at_least_deadline_and_terminal_elapsed_may_include_termination_grace",
                passRequiresAllEnvironmentLimitAndOutcomeObservationsNonNull:
                    true,
                passWorkerExitCode: 0,
                passWorkerSignalMustBeNull: true,
                passWorkerTimeoutMustBeFalse: true,
                passMLXDeviceType: "gpu",
                passMLXDeviceConstructorIndex: 0,
                passMLXDefaultDeviceIsSuppliedDevice: true,
                passMLXDefaultStreamIsGPU: true,
                passMLXCPUFallbackUsed: false,
                receiptMLXConstructorIndexAndMetalPolicyIndexMustBothEqualZero:
                    true,
                passCheckedEvaluationBarrierCount: 5,
                passGPUSynchronizationBarrierCount: 5,
                abstainBarrierCountsAreAttemptedPrefixCounts: true,
                passFingerprintRequiresExactPlanPathAndSampleCounts: true,
                passFingerprintRequiresLowercaseHexAndBeforeAfterDifference:
                    true,
                passPostflightDeviceIdentityMatchesPreflightMustBeTrue: true,
                passPostflightMLXPolicyAndLimitsMatchPreflightMustBeTrue:
                    true,
                receiptAnalyticLimitsMustEqualFrozenResourceEnvelope: true,
                passValidatedParameterPathCount: 218,
                passValidatedUniqueParameterCount: 271_107_072,
                passValidatedWeightsLogicalByteCount: 1_084_428_288,
                passValidatedGradientPathCount: 218,
                passValidatedGradientLogicalByteCount: 1_084_428_288,
                passValidatedFirstMomentTensorCount: 218,
                passValidatedSecondMomentTensorCount: 218,
                passValidatedOptimizerMomentLogicalByteCount: 2_168_856_576,
                receiptTimeoutCapsMustEqualFutureProbe: true,
                staticToolchainAndMetallibFieldsAlwaysNonNull: true,
                workerTransport:
                    "parent_captured_anonymous_pipe_progress_and_at_most_one_final_candidate",
                workerFrameSchemaVersion: 1,
                workerFrameTopLevelKeys: [
                    "frame_schema_version", "kind", "payload", "sequence",
                ],
                workerFrameKindDomain: ["progress", "candidate"],
                workerFrameMaximumByteCount: 1_048_576,
                workerFrameMaximumCompactJSONByteCount: 1_048_575,
                workerTransportFrameByteCountIncludesFinalLF: true,
                supervisorTransportBufferBoundRule:
                    "drift_when_unterminated_buffer_exceeds_1048575_or_completed_JSON_plus_LF_exceeds_1048576_and_never_allocate_beyond_bounded_buffer",
                workerTransportDoesNotAssumePIPEBUFAtomicity: true,
                workerFrameEncoding:
                    "one_line_sorted_key_compact_UTF8_JSON_plus_LF",
                workerFrameSequenceRule:
                    "UInt64_starts_0_increments_exactly_1_no_gaps_duplicates_or_reordering",
                workerPipeOwnershipRule:
                    "dedicated_anonymous_pipe_not_stdout_worker_sole_writer_supervisor_sole_reader",
                workerPipeWriteRule:
                    "raw_write_2_loop_handles_partial_writes_and_EINTR_no_fsync_or_stdio_fflush",
                workerProgressCommitRule:
                    "commit_only_after_all_canonical_JSON_and_LF_bytes_written",
                workerProgressSnapshotRule:
                    "full_cumulative_snapshot_after_each_completed_milestone_and_after_incrementing_attempted_count_before_every_potentially_fatal_lease_Metal_MLX_allocation_eval_sync_host_read_update_metric_or_clear_cache_invocation",
                supervisorConcurrentDrainRule:
                    "blocking_read_drain_starts_immediately_after_spawn_and_runs_concurrently_through_waitpid_and_EOF_to_prevent_pipe_capacity_deadlock",
                supervisorFrameParsingRule:
                    "incremental_LF_split_accepts_only_complete_canonical_frames_and_after_child_termination_EOF_discards_at_most_one_trailing_unterminated_fragment_with_receipt_record",
                supervisorTransportDriftRule:
                    "malformed_complete_unknown_kind_or_schema_duplicate_out_of_order_gapped_post_candidate_second_candidate_or_frame_over_1048576_bytes_is_transport_drift",
                workerCandidateTerminalRule:
                    "at_most_one_candidate_candidate_is_terminal_no_later_frames_no_receipt_prefix_stdout_file_or_artifact",
                workerCandidateAcceptedIffPASS: true,
                abstainObservedCandidateFrameRule:
                    "worker_candidate_frame_count_is_observed_syntactically_complete_candidate_kind_frames;PASS_exactly_1;cooperative_or_fatal_ABSTAIN_may_be_0;late_wait_status_timeout_candidate_payload_or_transport_validation_or_trailing_partial_ABSTAIN_may_be_1;duplicate_frame_executor_receipt_drift_may_be_at_least_2;worker_candidate_present_means_one_candidate_accepted_for_PASS_and_is_false_for_every_ABSTAIN;supervisor_synthesizes_every_ABSTAIN",
                allABSTAINReceiptsSupervisorSynthesized: true,
                passWorkerTransportRule:
                    "candidate_frame_count_1_transport_drift_false_trailing_partial_false",
                fatalWorkerTransportRule:
                    "candidate_frame_count_may_be_0_or_1_accepted_candidate_count_0_trailing_partial_may_be_true_supervisor_uses_last_valid_cumulative_progress_wait_status_timeout_and_validation",
                spawnFailureWorkerTransportRule:
                    "progress_count_0_candidate_count_0_last_sequence_null_trailing_partial_false_transport_drift_false",
                workerProgressAndMaximumOneCandidateOnly: true,
                workerStdoutReceiptCount: 0,
                workerReceiptFileCount: 0,
                workerArtifactCount: 0,
                supervisorSoleReceiptStdoutOwner: true,
                supervisorUsesFputsThenOneFlush: true,
                supervisorCompletesAllFallibleWorkBeforeCanonicalEmission:
                    true,
                supervisorPreEmissionOrder: [
                    "monitor_and_concurrently_drain_while_applying_timeout",
                    "terminate_child_or_process_group_if_applicable",
                    "terminal_waitpid_reap_if_child_or_record_spawn_failure_if_none",
                    "drain_remaining_pipe_to_EOF_and_join_reader",
                    "reacquire_release_or_record_lease_disposition",
                    "close_transport_file_descriptors",
                    "validate_candidate_or_synthesize_ABSTAIN",
                    "construct_canonical_encode_round_trip_self_validate_final_receipt_and_exact_one_line_bytes",
                ],
                supervisorFputsAndFlushReturnAndFerrorChecksRequired: true,
                supervisorEmissionFailureExitsNonzeroWithoutClaimingValidReceipt:
                    true,
                supervisorHasNoFallibleWorkAssertionsDefersOrCleanupAfterFlush:
                    true,
                supervisorImmediateExitZeroAfterSuccessfulFlush: true,
                supervisorSuccessfulFlushExitAPI: "_exit(0)",
                launcherParsesCapturedLogOnlyAfterSupervisorTerminationAndRequiresExitZero:
                    true,
                supervisorEmitsAfterApplicableChildTerminationAndLeaseCleanupDisposition:
                    true,
                supervisorValidatesCandidateOrSynthesizesABSTAINWhenAbsent:
                    true,
                terminalSupervisorReceiptCount: 1,
                supervisorExitsZeroAfterValidCanonicalTerminalReceiptAndCleanup:
                    true,
                launcherValidatesEitherCanonicalStatusAndExitsZero: true,
                invalidReceiptDriftOrUncontainedNoReceiptFailureExitsNonzero:
                    true,
                workerNonzeroOrSignalMayYieldGreenSupervisorABSTAIN: true,
                executorReceiptDriftGreenOnlyWithSynthesizedCanonicalABSTAIN:
                    true,
                buildOrLauncherBeforeSupervisorFailureReceiptCount: 0,
                buildOrLauncherBeforeSupervisorFailureClassifiedExternally:
                    true,
                receiptBindsExactAuthoritySourceExecutionAndProvenanceIDs: true,
                receiptBindsAllPersistentFalseCeilings: true,
                receiptBindsOutcomeTransitionFieldsSeparately: true),
            authorityClosureScope: .init(
                exactChangedPaths: authorityPaths,
                sourceAndTestAreOnlyNewPaths: true,
                rootPackageManifestMutationAuthorized: false,
                rootPackageResolvedMutationAuthorized: false,
                trainingValidationManifestMutationAuthorized: false,
                trainingValidationLockMutationAuthorized: false,
                newTrainingProbeSourceAuthorized: false,
                existingTrainingSourceMutationAuthorized: false,
                newStage6LauncherAuthorized: false,
                newStage6ExecutableMainAuthorized: false,
                newStage6AuthorityTestAuthorized: true,
                newStage6MechanicsPureContractTestAuthorized: false,
                existingMetalLauncherMutationAuthorized: false,
                existingRuntimeLauncherMutationAuthorized: false,
                existingTokenizerLauncherMutationAuthorized: false,
                existingStage5LauncherMutationAuthorized: false),
            successorScope: .init(
                exactChangedPaths: successorPaths,
                sourceAndTestAreOnlyNewPaths: false,
                rootPackageManifestMutationAuthorized: false,
                rootPackageResolvedMutationAuthorized: false,
                trainingValidationManifestMutationAuthorized: true,
                trainingValidationLockMutationAuthorized: false,
                newTrainingProbeSourceAuthorized: true,
                existingTrainingSourceMutationAuthorized: false,
                newStage6LauncherAuthorized: true,
                newStage6ExecutableMainAuthorized: true,
                newStage6AuthorityTestAuthorized: false,
                newStage6MechanicsPureContractTestAuthorized: true,
                existingMetalLauncherMutationAuthorized: false,
                existingRuntimeLauncherMutationAuthorized: false,
                existingTokenizerLauncherMutationAuthorized: false,
                existingStage5LauncherMutationAuthorized: false),
            successorManifest: .init(
                packageManifestPath:
                    "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                packageName: "PrimeNativeDecoderTrainingValidation",
                newExecutableProductCount: 1,
                newExecutableProductName:
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe",
                newExecutableProductTargetNames: [
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe",
                ],
                newExecutableTargetCount: 1,
                newExecutableTargetName:
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe",
                newExecutableTargetSourcePath:
                    "Sources/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe/main.swift",
                newExecutableTargetDirectProductDependencies: [
                    ".product(name:\"PrimeNativeDecoderTraining\",package:\"ergentics-prime\")",
                ],
                newExecutableTargetDirectMLXProductDependencyCount: 0,
                newExecutableTargetLinkerFrameworks: [
                    "CoreGraphics", "Metal",
                ],
                newExecutableMainImports: [
                    "Foundation", "PrimeNativeDecoderTraining",
                ],
                newExecutableMainEntryPoint:
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.runSupervisor()",
                trainingProbeSourcePath:
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift",
                trainingProbeSourceImports: [
                    "CoreGraphics", "Darwin", "Foundation", "Metal", "MLX",
                    "MLXNN", "MLXOptimizers", "PrimeCore",
                    "PrimeNativeDecoder",
                ],
                existingTestTargetName: "PrimeNativeDecoderTrainingTests",
                newContractTestPath:
                    "Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests.swift",
                newContractTestClassName:
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests",
                newContractTestMethodName:
                    "testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure",
                newContractTestFilter:
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests/testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure",
                focusedValidationContractTestFilter:
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests/testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure",
                stage6LauncherContractTestFilter:
                    "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests/testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure",
                bothContractTestInvocationsUseSameExactFilterOnce: true,
                newContractTestImports: [
                    "Foundation", "MLX", "PrimeCore",
                    "PrimeNativeDecoderTraining", "XCTest",
                ],
                existingTestTargetDirectProductDependenciesAfterMutation: [
                    ".product(name:\"PrimeCore\",package:\"ergentics-prime\")",
                    ".product(name:\"PrimeNativeDecoderTraining\",package:\"ergentics-prime\")",
                    ".product(name:\"MLX\",package:\"ergentics-mlx-swift\")",
                ],
                existingTestTargetLinkerFrameworks: [
                    "CoreGraphics", "Metal",
                ],
                existingTrainingAndMLXTestDependenciesRetained: true,
                rootPackageManifestMustRemainByteIdentical: true),
            suite: .init(
                authorityRootTestCount: 55,
                isolatedGroupTestCounts: [1, 1, 2, 2],
                isolatedTestCount: 6,
                authorityFocusedWholeTestCount: 61,
                predecessorMetalTestCount: 44,
                predecessorRuntimeTestCount: 1,
                predecessorTokenizerTestCount: 1,
                authorityTotalTestCount: 107,
                authorityStage5LauncherInvocationCount: 0,
                authorityStage5ReceiptCount: 0,
                authorityStage6LauncherInvocationCount: 0,
                authorityStage6ReceiptCount: 0,
                futureStage6PureContractFocusedXCTestCount: 1,
                futureStage6PureContractDirectXCTestCount: 1,
                futureStage6PureContractXCTestStartCount: 2,
                futureStage6ExecutableOperationalProbeCount: 1,
                futureStage6LauncherLocalAggregateDirectInvocationCount: 2,
                futureStage6AggregateInvocationCount: 3,
                futureMechanicsXCTestTotalCount: 109,
                authorityClosureLiveOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                futureMechanicsLiveOrder: [
                    "metal", "maintained_runtime", "tokenizer", "stage6",
                ],
                futureStage6InternalOrder: [
                    "stage6_pure_contract_xctest",
                    "stage6_resource_probe_executable",
                ]),
            ceiling: .init(
                authorityOnlyNoProbeResultEvidence: true,
                mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: true,
                oneExactMainResourceProbeOpportunityAuthorized: true,
                oneNative300MAllocationAuthorizedForResourceProbe: true,
                oneNative300MTrainingStepAuthorizedForResourceProbe: true,
                boundedResourceMeasurementAuthorized: true,
                stage5ReplacementExecutionAuthorized: false,
                stage5ResultEstablished: false,
                stage5MechanicsSuccessEstablished: false,
                stage5AssayClearanceEstablished: false,
                exactMetalGradientBytesEstablished: false,
                repeatedTrajectoryDeterminismEstablished: false,
                metalDeterminismEstablished: false,
                resourceProbeExecuted: false,
                resourceEnvelopeEstablished: false,
                resourceClearanceEstablished: false,
                ordinaryJobFitEstablished: false,
                runnerMemoryCapacityEstablished: false,
                broadNative300MTrainingAuthorized: false,
                additionalExecutionOrRerunAuthorized: false,
                durableCheckpointIOAuthorized: false,
                retainedArtifactAuthorized: false,
                artifactUploadAuthorized: false,
                tinyTypedInMemoryResumeEstablished: true,
                tinyDurableSnapshotRoundTripEstablished: true,
                generalTrainingResumeEstablished: false,
                native300MTrajectoryTrainingResumeEstablished: false,
                checkpointAdmissionGranted: false,
                modelQualityEstablished: false,
                candidateAdmissionGranted: false,
                stage7AuthorityEstablished: false,
                stage7Authorized: false,
                downstreamTrialAuthorized: false,
                canaryAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false),
            orderedRequiredSeparateActions: [
                "merge_and_pass_exact_main_stage6_pure_authority_closure",
                "separately_implement_exact_eight_path_stage6_resource_probe_mechanics",
                "use_exactly_one_direct_main_stage6_resource_probe_opportunity_without_retry_or_rerun",
                "append_only_observe_and_retire_the_stage6_outcome",
                "keep_stage7_false_without_both_stage5_assay_and_stage6_resource_clearance",
            ],
            status:
                "AUTHORIZED_stage6_native300m_resource_only_one_step_probe_mechanics_and_one_exact_main_witness_after_green_authority_closure_stage5_terminally_closed_result_false_no_assay_clearance_checkpoint_quality_stage7_rerun_or_downstream_authority")
    }()

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let decoded = try JSONDecoder().decode(Self.self, from: data)
        guard try decoded.canonicalData() == data else {
            throw PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityError
                .contractDrift("noncanonical encoding")
        }
        try decoded.validateExactV1()
        return decoded
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let design = PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1
            .frozenV1
        let failure =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationV1
                .frozenV1
        let stage3Observation =
            PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeExecutionObservationV1
                .frozenV1
        let stage4Observation =
            PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationV1
                .frozenV1
        try design.validateExactV1()
        try failure.validateExactV1()
        try stage3Observation.validateExactV1()
        try stage4Observation.validateExactV1()

        let stage6 = design.orderedStages.first {
            $0.stage == .native300MResourceOnlyOneStepProbe
        }
        let stage7 = design.orderedStages.first {
            $0.stage == .native300MTrajectoryCheckpointExecution
        }
        let falseCeilings = [
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

        guard self == Self.frozenV1,
              schemaVersion == 1,
              authorityID
                == "prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1",
              repository.authorityClosureExactChangedPaths
                == repository.authorityClosureExactChangedPaths.sorted(),
              Set(repository.authorityClosureExactChangedPaths).count == 5,
              repository.authoritySourceAndTestAreOnlyNewPaths,
              repository.authorityBaseIsExactTerminalStage5RetirementMain,
              repository.baseSourceBindings.count == 10,
              repository.baseSourceBindings.allSatisfy({ identity in
                  ["100644", "100755"].contains(identity.mode)
                      && Self.isLowercaseHex(identity.gitBlob, count: 40)
                      && identity.byteCount > 0
                      && identity.lfByteCount > 0
                      && Self.isLowercaseHex(identity.sha256, count: 64)
              }),
              repository.baseSourceBindings.contains(where: {
                  $0.path == "Sources/PrimeCore/PrimeMetalDeviceLease.swift"
                      && $0.role
                        == "frozen_nonblocking_exclusive_device_lease"
              }),
              repository.baseSourceBindings.contains(where: {
                  $0.path
                    == "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift"
                      && $0.role == "frozen_native300m_model_factory"
              }),
              roadmap.designAuthorityID == design.authorityID,
              PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(design))
                == roadmap.designAuthorityCanonicalSHA256,
              stage6?.objective == roadmap.objective,
              stage6?.requiredCompletedPredecessorStage
                == .tinyRepeatedMetalTrajectoryDeterminismAssay,
              stage7?.objective == roadmap.nextStageObjective,
              stage7?.requiredCompletedPredecessorStage
                == .native300MResourceOnlyOneStepProbe,
              roadmap.predecessorStageLifecycleCompleted,
              !roadmap.predecessorResultEstablished,
              !roadmap.predecessorAssayClearanceEstablished,
              roadmap.nextStageRequiresAssayAndResourceClearance,
              !roadmap.nextStageAuthorizedByThisAuthority,
              roadmap.separatelyAuthorizedSuccessorRequired,
              stage5Failure.observationID == failure.observationID,
              PrimeSHA256.hexDigest(of: try failure.canonicalData())
                == stage5Failure.observationCanonicalSHA256,
              stage5Failure.stage5MechanicsExecuted,
              stage5Failure.oneShotExecutionConsumed,
              stage5Failure.oneShotExecutionExhausted,
              !stage5Failure.stage5ResultEstablished,
              !stage5Failure.stage5MechanicsSuccessEstablished,
              !stage5Failure.repeatedTrajectoryDeterminismEstablished,
              !stage5Failure.exactMetalGradientBytesEstablished,
              !stage5Failure.metalDeterminismEstablished,
              !stage5Failure.replacementStage5ExecutionAuthorized,
              stage5Retirement.mergeRevision
                == repository.authorityBaseRevision,
              stage5Retirement.mergeTree == repository.authorityBaseTree,
              stage5Retirement.workflowRunID == 31_763_253_701,
              stage5Retirement.workflowRunNumber == 107,
              stage5Retirement.workflowRunAttempt == 1,
              stage5Retirement.checkSuiteID == 86_172_361_851,
              stage5Retirement.previousAttemptURLWasNull,
              stage5Retirement.exactHeadPushRunCount == 1,
              stage5Retirement.rerunCount == 0,
              stage5Retirement.artifactCount == 0,
              stage5Retirement.activeJobConclusion == "success",
              stage5Retirement.reviewedJobConclusion == "success",
              stage5Retirement.rootTestCount == 54,
              stage5Retirement.isolatedGroupTestCounts == [1, 1, 2, 2],
              stage5Retirement.isolatedTestCount
                == stage5Retirement.isolatedGroupTestCounts.reduce(0, +),
              stage5Retirement.focusedWholeTestCount
                == stage5Retirement.rootTestCount
                    + stage5Retirement.isolatedTestCount,
              stage5Retirement.totalTestCount
                == stage5Retirement.focusedWholeTestCount
                    + stage5Retirement.metalTestCount
                    + stage5Retirement.maintainedRuntimeTestCount
                    + stage5Retirement.tokenizerTestCount,
              stage5Retirement.stage5LauncherInvocationCount == 0,
              stage5Retirement.stage5ReceiptCount == 0,
              stage5Retirement.stage6LauncherInvocationCount == 0,
              stage5Retirement.stage6ReceiptCount == 0,
              stage5Retirement.stage5InvocationRetired,
              stage5Retirement.stage5LauncherPreservedForAudit,
              configuration.modelModule == "PrimeNativeDecoder",
              configuration.modelConfigurationType
                == "PrimeNativeGQADecoderConfiguration",
              configuration.modelConfigurationFactory
                == "native300MInventory(vocabularySize:)",
              configuration.modelType == "PrimeNativeGQADecoder",
              configuration.modelFactory == "make(configuration:seed:)",
              configuration.vocabularySize == 512,
              configuration.uniqueParameterCount == 271_107_072,
              configuration.logicalFP32ParameterByteCount
                == configuration.uniqueParameterCount * 4,
              configuration.parameterPathCount == 218,
              configuration.initializationSeed == 44,
              configuration.batchSize == 1,
              configuration.sequenceLength == 128,
              configuration.validTokenCount == 128,
              configuration.batchTokenIDs.count == 1,
              configuration.batchTokenIDs[0].count == 128,
              configuration.batchTokenIDs[0]
                == [1] + (0 ..< 127).map({ 2 + (($0 * 73 + 44) % 510) }),
              configuration.batchCompletionMask
                == [[false] + Array(repeating: true, count: 127)],
              configuration.selectedTargetCount == 127,
              configuration.lossGraphAlgorithmID
                == "prime_stage6_causal_masked_mean_cross_entropy_f32_v1",
              configuration.tokenIDStorageDType == "int32",
              configuration.completionMaskStorageDType == "bool",
              configuration.trainingLogitsAPI
                == "PrimeNativeGQADecoder.trainingLogitsNoCache",
              configuration.trainingLogitsInvocationCount == 1,
              configuration.trainingLogitsExpectedShape == [1, 128, 512],
              configuration.trainingLogitsDType == "float32",
              configuration.trainingLogitsUsesCausalAttentionMask,
              configuration.trainingLogitsKVCacheAllocationCount == 0,
              configuration.shiftedLogitsSlice
                == "logits[0...,0..<127,0...]",
              configuration.shiftedTargetsSlice
                == "token_ids[0...,1..<128]",
              configuration.shiftedCompletionMaskSlice
                == "completion_mask[0...,1..<128]",
              configuration.shiftedLogitsExpectedShape == [1, 127, 512],
              configuration.shiftedTargetsExpectedShape == [1, 127],
              configuration.shiftedCompletionMaskExpectedShape == [1, 127],
              configuration.shiftedCompletionMaskAllTrue,
              configuration.crossEntropyAPI
                == "MLXNN.crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)",
              configuration.crossEntropyWeights == "nil",
              configuration.crossEntropyAxis == -1,
              configuration.crossEntropyLabelSmoothingFloat32BitPattern == 0,
              configuration.crossEntropyReduction == "none",
              configuration.perTargetLossDType == "float32",
              configuration.perTargetLossExpectedShape == [1, 127],
              configuration.perTargetLossExpectedElementCount
                == configuration.selectedTargetCount,
              configuration.perTargetLossAllElementsSelectedByShiftedMask,
              configuration
                .perTargetLossShapeAndDTypeValidatedInsideValueAndGradClosureBeforeReduction,
              configuration.lossReductionFormula
                == "MLX.sum(per_target_loss*shifted_completion_mask.asType(.float32))/Float32(127)",
              configuration.lossDType == "float32",
              configuration.lossExpectedRank == 0,
              configuration.valueAndGradAPI == "MLXNN.valueAndGrad(model:_:)",
              configuration.valueAndGradClosureArguments
                == ["model", "token_ids", "completion_mask"],
              configuration.valueAndGradClosureReturnsOnlyScalarLoss,
              !configuration.independentOrDetachedLossAuthorized,
              configuration.gradientAccumulationCount == 1,
              configuration.optimizerStepCount == 1,
              configuration.learningRateFloat32BitPattern == 953_267_991,
              configuration.beta1Float32BitPattern == 1_063_675_494,
              configuration.beta2Float32BitPattern == 1_065_336_439,
              configuration.epsilonFloat32BitPattern == 841_731_191,
              configuration.weightDecayFloat32BitPattern == 1_008_981_770,
              configuration.maximumGradientNormFloat32BitPattern
                == 1_065_353_216,
              configuration.gradientNormEpsilonFloat32BitPattern
                == 897_988_541,
              configuration.parameterDType == "float32",
              configuration.optimizerQualifiedType == "MLXOptimizers.AdamW",
              configuration.optimizerStateInspectionAPI
                == "MLXOptimizers.AdamW.innerState()",
              configuration.optimizerStatePairTopology
                == "218_adjacent_[first_moment,second_moment]_pairs_from_TupleState.innerState",
              configuration.optimizerStateExpectedArrayCount
                == resourceEnvelope.optimizerMomentTensorCount,
              configuration.optimizerStateExpectedPairCount
                == configuration.parameterPathCount,
              !configuration.optimizerNamedStateExportDuringProbeAuthorized,
              configuration.optimizerStateMustBeEmptyBeforeUpdate,
              configuration
                .optimizerStateAdjacentPairsSameShapeAndFloat32Required,
              configuration.optimizerStateParityElementCountEach
                == configuration.uniqueParameterCount,
              configuration.optimizerStateParityLogicalByteCountEach
                == resourceEnvelope.weightsLogicalByteCount,
              configuration
                .optimizerStatePairShapeMultisetMustEqualModelParameterShapeMultiset,
              !configuration.optimizerStatePerPathMomentNamingEstablished,
              configuration.postUpdateFullStateEvaluationAPI
                == "checkedEval(model,optimizer,after_fingerprint_sample_views)",
              configuration.postModelFullStateEvaluationAPI
                == "checkedEval(model,before_fingerprint_sample_views)",
              configuration
                .postUpdateFullStateEvaluationIncludes218ModelAnd436OptimizerArrays,
              !configuration.adamWBiasCorrectionApplied,
              configuration.gradientClippingMode
                == "global_l2_norm_clip_once_before_adamw_update",
              configuration.gradientCatalogOrdering
                == "trainable_parameters_flattened_unique_paths_utf8_ascending",
              configuration.expectedGradientPathCount
                == configuration.parameterPathCount,
              configuration.rawGradientNormAlgorithmID
                == "prime_stage6_global_f32_l2_norm_utf8_catalog_v1",
              configuration.rawGradientNormFormula
                == "sqrt(sum_in_utf8_path_order(MLX.sum(MLX.square(gradient.asType(.float32)))))",
              configuration.rawGradientNormAccumulatorDType == "float32",
              !configuration.gradientNormEpsilonInsideNorm,
              configuration.gradientClipAlgorithmID
                == "prime_stage6_global_norm_clip_f32_v1",
              configuration.gradientClipThresholdFloat32BitPattern
                == configuration.maximumGradientNormFloat32BitPattern,
              configuration.gradientClipEpsilonFloat32BitPattern
                == configuration.gradientNormEpsilonFloat32BitPattern,
              configuration.gradientClipComparison
                == "raw_norm_float32_less_than_1",
              configuration.gradientClipScaleFormula
                == "raw_norm<1?Float32(1):Float32(1)/(raw_norm+Float32(1e-6))",
              configuration.gradientClipScaleHostDType == "float32",
              configuration.gradientClipApplication
                == "identity_if_raw_norm_less_than_1_else_each_of_218_gradients_times_scale",
              configuration.gradientClipApplicationCount == 1,
              configuration.gradientClipOccursExactlyOnceBeforeAdamW,
              configuration.adamWConsumesOnlyClippedGradientCatalog,
              configuration.parameterFingerprintAlgorithmID
                == "prime_stage6_parameter_catalog_sample_f32be_sha256_v1",
              configuration.parameterFingerprintCatalogOrdering
                == "module_parameters_flattened_unique_paths_utf8_ascending",
              configuration.parameterFingerprintSampleIndexRule
                == "deduplicated_ascending_[0,size/2,size-1]_per_nonempty_tensor",
              configuration.parameterFingerprintIntegerEncoding
                == "uint64_big_endian_lengths_rank_dimensions_sample_count_and_flat_indices",
              configuration.parameterFingerprintFloatEncoding
                == "float32_bit_pattern_uint32_big_endian",
              configuration.parameterFingerprintHash == "SHA256_lowercase_hex",
              configuration.parameterFingerprintExpectedPathCount
                == configuration.parameterPathCount,
              configuration.parameterFingerprintSamplesPerPath == 3,
              configuration.parameterFingerprintExpectedSampleCount
                == configuration.parameterFingerprintExpectedPathCount
                    * configuration.parameterFingerprintSamplesPerPath,
              configuration
                .parameterFingerprintRequiresEveryTensorElementCountAtLeastThree,
              configuration.parameterFingerprintRejectsEmptyOrDuplicatePaths,
              !configuration.parameterFingerprintFullTensorHostCopyAuthorized,
              configuration.parameterFingerprintHashStreamRule
                == "UTF8_algorithm_id_then_NUL_then_each_UTF8_sorted_path_as_UInt64BE_path_byte_count_path_bytes_UInt64BE_rank_each_UInt64BE_dimension_UInt64BE_sample_count_each_UInt64BE_flat_index_UInt32BE_Float_bit_pattern",
              configuration.parameterFingerprintSamplePlanHashOmitsValueBitsOnly,
              !configuration.paddingAuthorized,
              !configuration.kvCacheAuthorized,
              !configuration.modelQualityOrReadOnlyEvaluationAuthorized,
              !configuration.generationAuthorized,
              !configuration.checkpointAuthorized,
              configuration.configurationIsResourceProbeOnlyNotTrainingPolicy,
              resourceEnvelope.optimizerMomentTensorCount
                == configuration.parameterPathCount * 2,
              resourceEnvelope.optimizerMomentLogicalByteCount
                == resourceEnvelope.weightsLogicalByteCount * 2,
              resourceEnvelope.weightsLogicalByteCount
                == design.resourceDesign.weightsLogicalByteCount,
              resourceEnvelope.optimizerMomentLogicalByteCount
                == design.resourceDesign.optimizerMomentLogicalByteCount,
              resourceEnvelope.minimumCommittedTensorStateByteCount
                == resourceEnvelope.weightsLogicalByteCount
                    + resourceEnvelope.optimizerMomentLogicalByteCount,
              resourceEnvelope.minimumCommittedTensorStateByteCount
                == design.resourceDesign.minimumCommittedTensorStateByteCount,
              resourceEnvelope.minimumStatePlusGradientByteCount
                == resourceEnvelope.minimumCommittedTensorStateByteCount
                    + resourceEnvelope.gradientLogicalByteCount,
              resourceEnvelope.gradientLogicalByteCount
                == design.resourceDesign.gradientLogicalByteCount,
              resourceEnvelope.minimumStatePlusGradientByteCount
                == design.resourceDesign.minimumStatePlusGradientByteCount,
              resourceEnvelope.threeTimesCommittedStateDiskComparatorByteCount
                == resourceEnvelope.minimumCommittedTensorStateByteCount * 3,
              !resourceEnvelope.containerHeadersAndManifestsIncludedInMinimum,
              resourceEnvelope.containerHeadersAndManifestsIncludedInMinimum
                == design.resourceDesign
                    .containerHeadersAndManifestsIncludedInMinimum,
              !resourceEnvelope
                .duplicateMaterializationsGraphsAndTemporaryBuffersIncluded,
              resourceEnvelope
                .duplicateMaterializationsGraphsAndTemporaryBuffersIncluded
                == design.resourceDesign
                    .duplicateMaterializationsGraphsAndTemporaryBuffersIncluded,
              resourceEnvelope.seed43ObservedWeightsContainerByteCount
                == design.resourceDesign
                    .seed43ObservedWeightsContainerByteCount,
              resourceEnvelope.seed43ObservedLiveStepDurationSeconds
                == design.resourceDesign.seed43ObservedLiveStepDurationSeconds,
              resourceEnvelope.seed43ObservedAvailableFilesystemBytesAfterBuild
                == design.resourceDesign
                    .seed43ObservedAvailableFilesystemBytesAfterBuild,
              !resourceEnvelope.seed43RunnerMemoryCapacityRecorded,
              resourceEnvelope.seed43RunnerMemoryCapacityRecorded
                == design.resourceDesign.seed43RunnerMemoryCapacityRecorded,
              !resourceEnvelope
                .native300MOneStepFitsCurrentReviewedJobEstablished,
              resourceEnvelope
                .native300MOneStepFitsCurrentReviewedJobEstablished
                == design.resourceDesign
                    .native300MOneStepTrainingFitsOrdinary45MinuteJobEstablished,
              !resourceEnvelope.native300MOneStepFitsObservedMemoryEstablished,
              resourceEnvelope.native300MOneStepFitsObservedMemoryEstablished
                == design.resourceDesign
                    .native300MOneStepTrainingFitsObservedMemoryEstablished,
              resourceEnvelope.configuredMLXMemoryLimitMaximumByteCount
                == 17_179_869_184,
              resourceEnvelope.configuredMLXMemoryLimitFormula
                == "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)",
              resourceEnvelope
                .configuredMLXMemoryLimitRecommendedWorkingSetSource
                == "retainedMTLDevice.recommendedMaxWorkingSetSize",
              resourceEnvelope.recommendedMaxWorkingSetSizeMustBePositive,
              resourceEnvelope
                .configuredMLXMemoryLimitUInt64ToIntConversionOverflowChecked,
              resourceEnvelope
                .receiptConfiguredMemoryLimitMustEqualRetainedDeviceFormula,
              resourceEnvelope.configuredMLXMemoryLimitSetter
                == "MLX.Memory.memoryLimit",
              resourceEnvelope.configuredMLXMemoryLimitSetCount == 1,
              resourceEnvelope.configuredMLXMemoryLimitReadbackRequired,
              resourceEnvelope
                .configuredMLXMemoryLimitReadbackMustEqualFormulaResult,
              resourceEnvelope
                .configuredMLXMemoryLimitReceiptBindingRequired,
              resourceEnvelope.configuredMLXCacheLimitByteCount == 0,
              resourceEnvelope.configuredMLXCacheLimitSetter
                == "MLX.Memory.cacheLimit",
              resourceEnvelope.configuredMLXCacheLimitSetCount == 1,
              resourceEnvelope.configuredMLXCacheLimitReadbackRequired,
              resourceEnvelope.postDeallocationClearCacheCount == 1,
              resourceEnvelope.minimumConfiguredMLXMemoryLimitByteCount
                == resourceEnvelope.minimumStatePlusGradientByteCount,
              resourceEnvelope
                .preflightAbstainWhenConfiguredMLXMemoryLimitBelowMinimum,
              resourceEnvelope.minimumAvailableFilesystemByteCount
                == 12_884_901_888,
              resourceEnvelope
                .preflightAbstainWhenAvailableFilesystemBelowMinimum,
              resourceEnvelope.mlxLimitIsNotProcessRSSLimit,
              resourceEnvelope
                .statfsIsObservationNotCheckpointDiskSufficiencyClaim,
              resourceEnvelope.separateResourceOnlyProbeRequired,
              resourceEnvelope.separateResourceOnlyProbeRequired
                == design.resourceDesign.separateResourceOnlyProbeRequired,
              environment.requiredBindings
                == design.determinismDesign.requiredEnvironmentBindings,
              environment.mlxEnableTF32 == "0",
              environment.exactMLXRevision
                == "d37885a278f1c37484a94d0f401a418735e66519",
              environment.exactMLXRevision == environment.memorySourceRevision,
              environment.exactMLXRevision == environment.optimizerSourceRevision,
              environment.runtimeMetallibFilename == "default.metallib",
              environment.runtimeMetallibCandidateCount == 1,
              environment
                .runtimeMetallibPathByteCountAndSHA256ReceiptBindingsRequired,
              !environment.runtimeMetallibRetained,
              !environment.runtimeMetallibUploaded,
              environment.metalDeviceIndex == 0,
              environment.exactMetalDeviceCount == 1,
              environment.singletonDeviceEnumerationRequired,
              environment.indexZeroMustMatchDefaultDevice,
              environment.exclusiveMetalDeviceLeaseRequired,
              environment.leaseType == "PrimeMetalDeviceLease",
              environment.leaseModule == "PrimeCore",
              environment.leaseAcquisitionMode
                == "flock_LOCK_EX_or_LOCK_NB_nonblocking_exclusive",
              environment.workerIsSoleAcquirerAndOwnerWhenAcquired,
              environment.kernelReleasesWorkerLeaseOnFatalTermination,
              environment.swiftPMBuildConfiguration == "release",
              environment.mlxGraphCompileMode
                == "eager_uncompiled_no_compile_transform",
              environment.mlxCompileTransformInvocationCount == 0,
              environment.mlxExecutionDeviceConstruction
                == "Device(.gpu,index:Int32(0))",
              environment.mlxExecutionDeviceType == "gpu",
              environment.mlxExecutionDeviceConstructorIndex == 0,
              environment.mlxDeviceIndexEvidence
                == "constructor_argument_not_runtime_readback",
              !environment.mlxDeviceIndexRuntimeReadbackAvailable,
              environment.mlxDeviceEqualityNotUsedForIdentity,
              environment.mlxDeviceTypeObservationAPI
                == "executionDevice.deviceType==.gpu",
              environment.mlxDefaultDeviceScopeAPI
                == "Device.withDefaultDevice(executionDevice)",
              environment.mlxDefaultDeviceObjectIdentityAPI
                == "Device.defaultDevice()===executionDevice",
              environment.mlxDefaultDeviceObjectIdentityRequired,
              environment.mlxDefaultGPUStreamRequired,
              environment.mlxDefaultGPUStreamObservationAPI
                == "Stream()==Stream.gpu",
              !environment.mlxCPUFallbackAuthorized,
              environment
                .mlxExecutionScopeCoversModelAllocationThroughLexicalDeallocation,
              environment.mlxGPUIndexEqualsMetalDeviceIndexRequired,
              environment.mlxExecutionDeviceConstructorIndex
                == environment.metalDeviceIndex,
              environment.activeCheckoutDepth == 1,
              environment.reviewedCheckoutDepth == 1,
              environment.authorityClosureActiveJobTimeoutMinutes == 45,
              environment.authorityClosureReviewedJobTimeoutMinutes == 60,
              !environment
                .authorityClosureWorkflowTimeoutMutationAuthorized,
              environment.successorActiveJobTimeoutMinutes == 45,
              environment.successorReviewedJobTimeoutMinutes == 90,
              environment.successorReviewedWorkflowTimeoutMutationAuthorized,
              !environment.secureFetchMutationAuthorized,
              Self.isLowercaseHex(environment.memorySourceGitBlob, count: 40),
              Self.isLowercaseHex(environment.memorySourceSHA256, count: 64),
              environment.optimizerSourceRepository
                == "Ergentics/ergentics-mlx-swift",
              environment.optimizerSourcePath
                == "Source/MLXOptimizers/Optimizers.swift",
              environment.optimizerSourceMode == "100644",
              environment.optimizerSourceGitBlob
                == "fb9c5d9636a211bb74fae7bf6a1dbbd4fe01d7b9",
              environment.optimizerSourceByteCount == 24_109,
              environment.optimizerSourceLFByteCount == 698,
              environment.optimizerSourceSHA256
                == "f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d",
              environment.mlxPeakMemoryResetBeforeProbeRequired,
              environment.mlxPeakMemoryResetAPI == "MLX.Memory.peakMemory = 0",
              environment.mlxPeakMemoryResetCount == 1,
              environment.mlxPeakMemoryResetOrder
                == "after_memory_and_cache_limit_set_and_readback_before_preflight_snapshot_and_model_allocation",
              environment.physicalMemoryCapacityObservationRequired,
              environment
                .darwinTaskResidentAndPhysicalFootprintObservationRequired,
              environment.getrusageMaxRSSObservationRequired,
              environment.mlxActiveCacheAndPeakBytesObservationRequired,
              environment.filesystemCapacityAndAvailableBytesObservationRequired,
              environment.filesystemObservationTarget
                == "resolved_swiftpm_scratch_directory_containing_release_executable",
              environment.filesystemObservationUsesStatFS,
              environment
                .filesystemObservationRequiresScratchAndExecutableSameFSID,
              environment.filesystemObservationFSIDEncoding
                == "darwin_fsid_t_ordered_two_int32_decimal_json_array",
              environment.filesystemResolvedTargetPathRule
                == "realpath_or_URL.resolvingSymlinksInPath.standardizedFileURL_of_absolute_parent_directory_containing_actually_launched_release_executable",
              environment.filesystemTargetPathValidationRule
                == "absolute_physical_UTF8_existing_directory_no_dot_or_dotdot_no_trailing_slash_and_not_root",
              environment.filesystemExecutableAndParentStatFSRule
                == "statfs_resolved_executable_and_parent_require_identical_ordered_fsid_and_all_six_snapshots_retain_that_pair",
              environment.filesystemResolutionOrFSIDDriftClassification
                == "topology_dtype",
              environment.cumulativeWorkerProbeElapsedObservationRequired,
              environment.requiredMetricKeysAtEveryCompletedBoundary == [
                  "cumulative_worker_probe_elapsed_nanoseconds",
                  "physical_memory_capacity_bytes",
                  "task_resident_bytes",
                  "task_physical_footprint_bytes",
                  "getrusage_max_rss_bytes",
                  "mlx_active_bytes",
                  "mlx_cache_bytes",
                  "mlx_peak_bytes",
                  "metal_current_allocated_bytes",
                  "filesystem_capacity_bytes",
                  "filesystem_available_bytes",
              ],
              environment.physicalMemoryMetricSource
                == "ProcessInfo.processInfo.physicalMemory_bytes",
              environment.darwinTaskMetricSource
                == "task_info_TASK_VM_INFO_resident_size_and_phys_footprint_bytes",
              environment.getrusageMetricSource
                == "getrusage_RUSAGE_SELF_ru_maxrss_macos_bytes",
              environment.mlxMemoryMetricSource
                == "MLX.Memory_activeMemory_cacheMemory_peakMemory_bytes",
              environment.filesystemMetricFormula
                == "capacity=checked_UInt64(f_blocks)*checked_UInt64(f_bsize);available=checked_UInt64(f_bavail)*checked_UInt64(f_bsize)_using_multipliedReportingOverflow_nonnegative_representable_operands",
              environment.cumulativeElapsedMetricSource
                == "ContinuousClock_elapsed_overflow_safe_nanoseconds",
              environment.overflowCheckedMetricConversionsRequired,
              environment.metalCurrentAllocatedSizeObservationRequired,
              environment.metalCurrentAllocatedSizeMetricSource
                == "MTLDevice.currentAllocatedSize_bytes",
              environment
                .metalCurrentAllocatedSizeUsesRetainedSingletonDeviceRequired,
              environment.metalDeviceHasUnifiedMemoryRequired,
              environment
                .metalDeviceNameRegistryUnifiedMemoryRecommendedAndBufferBindingsRequired,
              environment
                .successfulLeaseAcquisitionPrecedesCoreGraphicsMetalOrMLX,
              environment.passLeaseHeldThroughCandidateFlushAndPostflight,
              environment
                .postAcquisitionFatalRequiresChildTerminationThenSupervisorReacquireReleaseProof,
              environment
                .leaseBusyRequiresAcquiredFalseAndCleanupProofNotApplicable,
              environment.leaseBusyNeverWaitsOrSteals,
              futureProbe.buildCount == 1,
              futureProbe.releaseBuildCommand
                == "swift build --package-path Tests/PrimeNativeDecoderTrainingValidation --configuration release --build-tests",
              futureProbe.releaseBuildCompilesDefaultProductsAndTests,
              futureProbe.releaseContractXCTestCommand
                == "swift test --package-path Tests/PrimeNativeDecoderTrainingValidation --configuration release --skip-build --filter PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests/testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure",
              futureProbe.releaseContractXCTestUsesSkipBuild,
              futureProbe.releaseBinPathResolutionCommand
                == "swift build --package-path Tests/PrimeNativeDecoderTrainingValidation --configuration release --show-bin-path",
              futureProbe.releaseBinPathResolutionCompilationCount == 0,
              futureProbe.releaseExecutableDirectInvocationRule
                == "invoke_resolved_release_bin_path/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe_directly_never_swift_run",
              futureProbe.swiftRunInvocationCount == 0,
              futureProbe.additionalBuildCount == 0,
              futureProbe.stage6LauncherInvocationCount == 1,
              futureProbe.directXCTestCount == 1,
              futureProbe.directExecutableProbeCount == 1,
              futureProbe.aggregateDirectInvocationCount == 2,
              futureProbe.aggregateDirectInvocationCount
                == futureProbe.directXCTestCount
                    + futureProbe.directExecutableProbeCount,
              futureProbe.supervisorProcessCount == 1,
              futureProbe.maximumWorkerProcessCount == 1,
              futureProbe.workerSpawnAttemptCount == 1,
              futureProbe.modelAllocationCount == 1,
              futureProbe.modelMaterializationCount == 1,
              futureProbe.valueAndGradCount == 1,
              futureProbe.trainingLogitsCount
                == configuration.trainingLogitsInvocationCount,
              futureProbe.crossEntropyCount == 1,
              futureProbe.forwardLossCount == 1,
              futureProbe.backwardCount == 1,
              futureProbe.gradientNormCount == 1,
              futureProbe.gradientClipCount == 1,
              futureProbe.optimizerStepCount == 1,
              futureProbe.adamWUpdateCount == 1,
              futureProbe.fullGraphEvaluationCount == 1,
              futureProbe.kvCacheAllocationCount == 0,
              futureProbe.evaluationForwardPassCount == 0,
              futureProbe.checkedTensorMaterializationEvaluationRequired,
              futureProbe
                .fullGraphEvaluationMeansTensorMaterializationNotEvaluationPass,
              futureProbe.checkedEvaluationAPI == "checkedEval",
              futureProbe.gpuSynchronizationAPI
                == "Stream.gpu.synchronize()",
              futureProbe.orderedCheckedEvaluationAndSynchronizationBarriers
                == [
                    "post_model_materialization_all_model_parameters_and_before_fingerprint_samples",
                    "post_forward_backward_loss_and_all_gradients",
                    "pre_clip_raw_gradient_norm_before_host_scalar_read",
                    "post_norm_clip_all_clipped_gradients",
                    "post_adam_update_all_model_parameters_both_moment_catalogs_and_after_fingerprint_samples",
                ],
              futureProbe.checkedEvaluationBarrierCount == 5,
              futureProbe.gpuSynchronizationBarrierCount == 5,
              futureProbe.phaseMetricsSampledOnlyAfterApplicableBarrier,
              futureProbe
                .hostScalarAndFingerprintReadsImmediatelyAfterApplicableSynchronization,
              futureProbe
                .finalFullStateBarrierIncludesModelAndBothMomentCatalogs,
              futureProbe.resourceMeasurementBoundaries.count == 6,
              futureProbe.resourceMeasurementBoundaryEndRules == [
                  "preflight:after_device_limit_statfs_checks_and_metric_snapshot",
                  "post_model_materialization:immediately_after_barrier_1_and_metric_snapshot",
                  "post_forward_backward:immediately_after_barrier_2_and_metric_snapshot",
                  "post_norm_clip:immediately_after_barrier_4_and_metric_snapshot",
                  "post_adam_update_full_evaluation:immediately_after_barrier_5_and_metric_snapshot",
                  "post_lexical_deallocation_and_clear_cache:after_lexical_deallocation_MLX.Memory.clearCache_and_final_metric_snapshot",
              ],
              futureProbe.resourceMeasurementBoundaryEndRules.count
                == futureProbe.resourceMeasurementBoundaries.count,
              futureProbe.phaseElapsedSemantics
                == "cumulative_from_worker_probe_epoch_to_boundary_snapshot",
              futureProbe.workerProbeEpoch
                == "first_child_instruction_before_nonblocking_lease_attempt",
              futureProbe.phaseIntervalPartitionRule
                == "preflight=[epoch,end0];each_later_phase=(prior_end,current_end];observed_prefix_contiguous_no_overlap_no_gap",
              futureProbe
                .phaseCumulativeElapsedStrictlyIncreasesAcrossObservedPrefix,
              futureProbe.unavailablePhaseCumulativeElapsedMustBeNull,
              futureProbe
                .lastObservedPhaseElapsedMustBeLessThanOrEqualWorkerActiveElapsed,
              futureProbe.filesystemFSIDMustRemainStableAcrossObservedPhases,
              futureProbe.filesystemInvalidOrOverflowClassification
                == "topology_dtype",
              futureProbe.preflightAvailableFilesystemComparison
                == "available>=12884901888_else_preflight_floor",
              futureProbe.allocatedProbeFunctionInlining == "@inline(never)",
              futureProbe.allocatedProbeFunctionName == "runAllocatedProbe",
              futureProbe.allocatedProbeFunctionReturnType
                == "PureSwiftProbeObservation",
              !futureProbe.allocatedProbeReturnAllowsMLXOrReferenceEscape,
              futureProbe.allocatedProbeLiveSetRules == [
                  "preflight:no_MLX_tensors",
                  "post_model:model_and_before_fingerprint_sample_views_retained_through_barrier_1_host_hash_and_immediate_snapshot_then_sample_views_dropped",
                  "post_forward_backward:forward_helper_retains_model_input_mask_loss_and_raw_218_gradients_through_barrier_2_and_immediate_snapshot",
                  "post_norm_clip:forward_helper_retains_model_input_mask_loss_raw_218_gradients_raw_norm_scalar_and_one_clipped_218_catalog_through_barrier_4_and_immediate_snapshot_then_returns_only_evaluated_clipped_catalog_and_pure_Swift_loss_norm_scale_so_raw_input_mask_loss_and_closure_drop_before_AdamW",
                  "post_adam:model_218_optimizer_innerState_436_clipped_218_and_after_fingerprint_sample_views_retained_through_barrier_5_host_hash_and_immediate_snapshot_before_any_catalog_or_view_release",
                  "post_deallocation:allocated_function_returns_all_graph_objects_release_MLX.Memory.clearCache_once_final_snapshot_then_postflight_no_MLXArray_Module_Optimizer_Evaluatable_closure_or_Any_refs_escape",
              ],
              futureProbe.memoryClearCacheCount
                == resourceEnvelope.postDeallocationClearCacheCount,
              futureProbe
                .memoryClearCacheOccursAfterAllocatedProbeReturnAndBeforeFinalSnapshot,
              futureProbe.postflightDeviceReenumerationCount == 1,
              futureProbe.postflightRunsAfterFinalDeallocationSnapshot,
              futureProbe
                .postflightRunsWhileLeaseHeldAndInsideSuppliedDefaultDeviceScope,
              futureProbe.postflightDeviceIdentityBindingsMustEqualPreflight,
              !futureProbe
                .postflightCurrentAllocatedSizeEqualityCheckAuthorized,
              futureProbe
                .postflightMLXPolicyAndLimitReadbacksMustEqualPreflight,
              futureProbe.postflightMismatchClassification == "topology_dtype",
              futureProbe.completedBoundaryMetricInventoryRequired,
              futureProbe.fatalOutcomeLaterBoundaryMetricsMayBeUnavailable,
              futureProbe.workerActiveTimeoutSeconds == 1_200,
              futureProbe.supervisorEndToEndTimeoutSeconds == 1_500,
              futureProbe.terminationGraceSeconds == 10,
              futureProbe.normativeMaximumWorkerCandidateFrameCount == 1,
              futureProbe.passWorkerCandidateFrameCount == 1,
              futureProbe.abstainAcceptedWorkerCandidateCount == 0,
              futureProbe
                .workerCandidateIsCapturedAndNeverEmittedWithCanonicalPrefix,
              futureProbe.workerCanonicalReceiptPrefixEmissionCount == 0,
              futureProbe.supervisorEmittedCanonicalReceiptCount == 1,
              futureProbe.supervisorCanonicalReceiptStdoutLineCount == 1,
              futureProbe.receiptFileCount == 0,
              futureProbe.fatalOutcomeStillRequiresSupervisorCanonicalReceipt,
              futureProbe
                .supervisorSynthesizesABSTAINReceiptWhenWorkerCandidateAbsent,
              futureProbe.passRequirements.count == 6,
              futureProbe.abstainClasses.count == 10,
              futureProbe.oneExactMainOpportunityAfterGreenAuthorityClosure,
              !futureProbe.retryAuthorized,
              !futureProbe.rerunAuthorized,
              !futureProbe.replacementRunAuthorized,
              futureProbe.checkpointReadCount == 0,
              futureProbe.checkpointWriteCount == 0,
              futureProbe.artifactUploadCount == 0,
              futureProbe.qualityMetricComputationCount == 0,
              futureProbe.generatedTokenCount == 0,
              receiptContract.schemaID
                == "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_receipt_v1",
              receiptContract.receiptID == receiptContract.schemaID,
              receiptContract.receiptPrefix == futureProbe.receiptPrefix,
              receiptContract.authorityIDBinding == authorityID,
              receiptContract.authorityCanonicalSHA256Binding
                == "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1.canonicalSHA256",
              receiptContract.authorityBaseRevisionBinding
                == repository.authorityBaseRevision,
              receiptContract.authorityBaseTreeBinding
                == repository.authorityBaseTree,
              receiptContract.authorityClosureRunBindingRequired,
              receiptContract.authorityClosureRequiredEvent == "push",
              receiptContract.authorityClosureRequiredRef == "refs/heads/main",
              receiptContract.authorityClosureRequiredAttempt == 1,
              receiptContract.authorityClosureRequiredStatus == "completed",
              receiptContract.authorityClosureRequiredConclusion == "success",
              receiptContract.authorityClosureRequiredJobConclusion == "success",
              receiptContract.authorityClosureRequiredArtifactCount == 0,
              receiptContract.authorityClosureRequiredRerunCount == 0,
              receiptContract
                .authorityClosureRevisionMustEqualWorkflowHeadAndMechanicsFirstParent,
              receiptContract.mechanicsRequiredEvent == "push",
              receiptContract.mechanicsRequiredRef == "refs/heads/main",
              receiptContract.mechanicsRequiredAttempt == 1,
              receiptContract.topLevelKeys == [
                  "authority", "ceiling", "configuration", "environment",
                  "execution", "lease", "limits", "outcome",
                  "phase_metrics", "receipt_id", "schema_version",
              ],
              receiptContract.sourceIdentityKeys == [
                  "byte_count", "git_blob", "mode", "path", "sha256",
              ],
              receiptContract.phaseNames
                == futureProbe.resourceMeasurementBoundaries,
              receiptContract.phaseMetricKeys
                == ["phase", "availability", "unavailable_reason"]
                    + environment.requiredMetricKeysAtEveryCompletedBoundary,
              receiptContract.nullableNumericMetricKeys
                == environment.requiredMetricKeysAtEveryCompletedBoundary,
              receiptContract.nullableEnvironmentObservationKeys == [
                  "metal_device_count", "metal_device_index",
                  "metal_device_is_default",
                  "metal_device_max_buffer_length_bytes",
                  "metal_device_max_recommended_working_set_bytes",
                  "metal_device_has_unified_memory", "metal_device_name",
                  "metal_device_registry_id",
                  "mlx_cpu_fallback_used",
                  "mlx_default_device_is_supplied_device",
                  "mlx_default_stream_is_gpu", "mlx_device_constructor_index",
                  "mlx_device_type", "filesystem_observation_fsid",
                  "filesystem_observation_path",
              ],
              receiptContract.nullableLimitObservationKeys == [
                  "configured_memory_limit_bytes",
                  "configured_memory_limit_readback_bytes",
                  "configured_cache_limit_readback_bytes",
                  "validated_parameter_path_count",
                  "validated_unique_parameter_count",
                  "validated_weights_logical_bytes",
                  "validated_gradient_path_count",
                  "validated_gradient_logical_bytes",
                  "validated_first_moment_tensor_count",
                  "validated_second_moment_tensor_count",
                  "validated_optimizer_moment_logical_bytes",
              ],
              receiptContract.nullableOutcomeObservationKeys == [
                  "loss_float32_bits", "raw_gradient_norm_float32_bits",
                  "gradient_clip_scale_float32_bits",
                  "parameter_fingerprint_before",
                  "parameter_fingerprint_after",
                  "parameter_fingerprint_sample_plan_sha256",
                  "parameter_fingerprint_sample_count",
                  "postflight_device_identity_matches_preflight",
                  "postflight_mlx_policy_and_limits_match_preflight",
                  "update_occurred",
              ],
              receiptContract.nullableExecutionTerminationKeys == [
                  "worker_exit_code", "worker_signal",
                  "worker_spawn_errno",
                  "worker_last_complete_frame_sequence",
                  "worker_active_elapsed_nanoseconds",
                  "worker_timeout_trigger_elapsed_nanoseconds",
                  "supervisor_timeout_trigger_elapsed_nanoseconds",
                  "timeout_scope",
              ],
              receiptContract.timeoutScopeDomain == [
                  "worker_active", "supervisor_end_to_end",
                  "worker_active_and_supervisor_end_to_end",
              ],
              receiptContract.statusDomain == ["PASS", "ABSTAIN"],
              receiptContract.classificationDomain
                == ["pass"] + futureProbe.abstainClasses,
              receiptContract.phaseAvailabilityDomain == [
                  "observed", "unavailable_before_probe_start",
                  "unavailable_after_fatal",
                  "unavailable_after_classification",
              ],
              receiptContract.classificationAvailabilityRules == [
                  "pass:all_six_observed",
                  "worker_spawn_failure:all_six_unavailable_before_probe_start",
                  "preflight_floor:preflight_observed_then_unavailable_after_classification_suffix",
                  "lease_busy:all_six_unavailable_before_probe_start",
                  "oom:possibly_empty_observed_prefix_then_unavailable_after_fatal_suffix",
                  "timeout:possibly_empty_observed_prefix_then_unavailable_after_fatal_suffix",
                  "signal:possibly_empty_observed_prefix_then_unavailable_after_fatal_suffix",
                  "nonfinite:observed_prefix_then_unavailable_after_classification_suffix",
                  "topology_dtype:possibly_empty_observed_prefix_then_unavailable_after_classification_suffix",
                  "no_update:observed_prefix_then_unavailable_after_classification_suffix",
                  "executor_receipt_drift:possibly_empty_observed_prefix_then_unavailable_after_classification_suffix",
              ],
              receiptContract.unavailableMetricEncoding
                == "JSON_null_with_keys_present",
              receiptContract.nonPhaseUnavailableEncoding
                == "JSON_null_with_keys_present",
              receiptContract.byteUnit == "bytes",
              receiptContract.durationUnit == "nanoseconds",
              receiptContract.canonicalSortedJSONRequired,
              receiptContract.passRequiresWorkerCandidate,
              receiptContract.passRequiresAllSixObservedBoundaries,
              receiptContract.passRequiresMonotonicElapsedPeakAndMaxRSS,
              receiptContract.passRequiresExactOperationCountsAndUpdateChecks,
              receiptContract
                .operationCountsRecordAttemptedInvocationsIncludingFatalAttempt,
              receiptContract
                .abstainRequiresPossiblyEmptyObservedPrefixAndExplicitUnavailableSuffix,
              receiptContract.abstainPhasePartitionRule
                == "all_six_rows_present_as_contiguous_possibly_empty_observed_prefix_plus_possibly_empty_unavailable_suffix",
              receiptContract
                .abstainUnavailableSuffixMayBeEmptyOnlyWhenAllSixBoundariesWereObservedBeforeClassification,
              receiptContract.emptyObservedPrefixRule
                == "allowed_only_for_worker_spawn_failure_lease_busy_topology_dtype_before_first_boundary_or_child_fatal_before_first_boundary",
              receiptContract
                .unavailableSuffixRequiresAllNumericMetricKeysPresentAndNull,
              receiptContract.phaseAndAvailabilityMetadataAlwaysNonNull,
              receiptContract.unavailableReasonKeyAlwaysPresent,
              receiptContract.unavailableReasonNullIffAvailabilityObserved,
              receiptContract
                .unavailableReasonEqualsClassificationIffAvailabilityUnavailable,
              receiptContract.environmentObservationAtomicProgressRule
                == "all_eight_device_fields_atomically_nonnull_only_after_post_lease_identity_progress_and_all_null_for_lease_busy",
              receiptContract.mlxExecutionPolicyAtomicProgressRule
                == "mlx_execution_policy:all_five_atomic_nonnull_after_post_lease_mlx_execution_policy_progress_else_all_null",
              receiptContract.filesystemObservationAtomicProgressRule
                == "filesystem_observation_path_and_fsid_atomic_nonnull_after_resolved_swiftpm_scratch_and_release_executable_same_fsid_progress_else_both_null_and_all_six_phase_statfs_reads_use_that_same_target_fsid",
              receiptContract.limitObservationAtomicProgressRule
                == "all_three_configured_and_readback_fields_atomically_nonnull_only_after_memory_and_cache_set_readback_progress",
              receiptContract.validatedModelCatalogAtomicProgressRule
                == "validated_parameter_path_count_unique_parameter_count_and_weights_logical_bytes_atomic_after_model_catalog_else_all_null",
              receiptContract.validatedGradientCatalogAtomicProgressRule
                == "validated_gradient_path_count_and_gradient_logical_bytes_atomic_after_gradient_catalog_else_all_null",
              receiptContract.validatedMomentCatalogAtomicProgressRule
                == "validated_first_and_second_moment_tensor_counts_and_optimizer_moment_logical_bytes_atomic_after_adam_state_catalog_else_all_null",
              receiptContract.validatedOptimizerMomentParityDerivationRule
                == "validated_first_moment_is_even_innerState_indices_and_second_moment_is_odd_innerState_indices_with_no_per_path_moment_naming_claim",
              receiptContract.outcomeObservationProgressRules == [
                  "parameter_fingerprint_sample_plan_sha256:nonnull_at_post_model_materialization_else_null",
                  "parameter_fingerprint_sample_count:nonnull_at_post_model_materialization_else_null",
                  "parameter_fingerprint_before:nonnull_at_post_model_materialization_else_null",
                  "loss_float32_bits:nonnull_at_post_forward_backward_else_null",
                  "raw_gradient_norm_float32_bits:nonnull_at_post_norm_clip_else_null",
                  "gradient_clip_scale_float32_bits:nonnull_at_post_norm_clip_else_null",
                  "parameter_fingerprint_after:nonnull_at_post_adam_update_full_evaluation_else_null",
                  "postflight_device_identity_matches_preflight:nonnull_after_postflight_device_reenumeration_else_null",
                  "postflight_mlx_policy_and_limits_match_preflight:nonnull_after_postflight_device_reenumeration_else_null",
                  "update_occurred:nonnull_at_post_adam_update_full_evaluation_else_null",
              ],
              receiptContract.executionTerminationObservationRule
                == "after_waitpid_exactly_one_of_worker_exit_code_or_worker_signal_is_nonnull_iff_child_existed_and_both_are_null_if_no_child",
              receiptContract.workerSpawnObservationRule
                == "worker_spawn_attempt_count_is_1;worker_spawn_succeeded_true_iff_child_exists;worker_spawn_errno_nonnull_iff_spawn_failed",
              receiptContract.workerSpawnFailureRule
                == "no_child_no_candidate_worker_process_count_0_worker_timeout_triggered_false_worker_exit_signal_active_elapsed_timeout_trigger_elapsed_and_scope_null_all_operation_counts_0_one_shot_consumed_true_probe_envelope_clearance_capacity_false_dynamic_observations_null_lease_false_or_not_applicable_supervisor_elapsed_and_triggered_nonnull_supervisor_synthesizes_one_canonical_ABSTAIN_and_exits_0",
              receiptContract.executorReceiptDriftRule
                == "candidate_zero_preserves_valid_terminal_progress_preflight_floor_lease_busy_nonfinite_topology_dtype_or_no_update_or_supervisor_derived_oom_timeout_signal_from_last_valid_progress_and_wait_status;candidate_absence_is_executor_receipt_drift_only_if_PASS_claimed_or_required_evidence_insufficient_or_transport_or_candidate_malformed_or_duplicate;missing_or_invalid_supervisor_receipt_or_supervisor_failure_is_nonzero",
              receiptContract.timeoutObservationRule
                == "worker_timeout_triggered_is_false_when_no_child_else_boolean;timeout_scope_and_each_trigger_elapsed_are_null_iff_no_corresponding_trigger_and_scope_exactly_matches_true_trigger_booleans",
              receiptContract.workerActiveIntervalRule
                == "supervisor_instant_immediately_before_successful_spawn_invocation_through_terminal_waitpid_return",
              receiptContract.supervisorEndToEndIntervalRule
                == "immediately_before_spawn_attempt_through_terminal_waitpid_if_child_or_spawn_failure_determination_if_none_pipe_drain_lease_disposition_fd_close_and_candidate_validation_immediately_before_receipt_encoding",
              receiptContract.passAndNonTimeoutABSTAINTimingRule
                == "both_timeout_triggers_false_scope_and_trigger_elapsed_null_and_applicable_elapsed_below_caps",
              receiptContract.timeoutABSTAINTimingRule
                == "scope_matches_trigger_booleans_each_trigger_elapsed_at_least_deadline_and_terminal_elapsed_may_include_termination_grace",
              receiptContract
                .passRequiresAllEnvironmentLimitAndOutcomeObservationsNonNull,
              receiptContract.passWorkerExitCode == 0,
              receiptContract.passWorkerSignalMustBeNull,
              receiptContract.passWorkerTimeoutMustBeFalse,
              receiptContract.passMLXDeviceType
                == environment.mlxExecutionDeviceType,
              receiptContract.passMLXDeviceConstructorIndex
                == environment.mlxExecutionDeviceConstructorIndex,
              receiptContract.passMLXDefaultDeviceIsSuppliedDevice,
              receiptContract.passMLXDefaultStreamIsGPU,
              !receiptContract.passMLXCPUFallbackUsed,
              receiptContract
                .receiptMLXConstructorIndexAndMetalPolicyIndexMustBothEqualZero,
              receiptContract.passCheckedEvaluationBarrierCount
                == futureProbe.checkedEvaluationBarrierCount,
              receiptContract.passGPUSynchronizationBarrierCount
                == futureProbe.gpuSynchronizationBarrierCount,
              receiptContract.abstainBarrierCountsAreAttemptedPrefixCounts,
              receiptContract
                .receiptLossAndGradientBindingsMustEqualConfiguration,
              receiptContract.passRawGradientNormFiniteAndPositive,
              receiptContract
                .passGradientClipScaleBitwiseEqualsFrozenFormula,
              receiptContract.passFingerprintRequiresExactPlanPathAndSampleCounts,
              receiptContract
                .passFingerprintRequiresLowercaseHexAndBeforeAfterDifference,
              receiptContract
                .passPostflightDeviceIdentityMatchesPreflightMustBeTrue,
              receiptContract
                .passPostflightMLXPolicyAndLimitsMatchPreflightMustBeTrue,
              receiptContract.receiptAnalyticLimitsMustEqualFrozenResourceEnvelope,
              receiptContract.passValidatedParameterPathCount
                == configuration.parameterPathCount,
              receiptContract.passValidatedUniqueParameterCount
                == configuration.uniqueParameterCount,
              receiptContract.passValidatedWeightsLogicalByteCount
                == resourceEnvelope.weightsLogicalByteCount,
              receiptContract.passValidatedGradientPathCount
                == configuration.expectedGradientPathCount,
              receiptContract.passValidatedGradientLogicalByteCount
                == resourceEnvelope.gradientLogicalByteCount,
              receiptContract.passValidatedFirstMomentTensorCount
                == configuration.parameterPathCount,
              receiptContract.passValidatedSecondMomentTensorCount
                == configuration.parameterPathCount,
              receiptContract.passValidatedOptimizerMomentLogicalByteCount
                == resourceEnvelope.optimizerMomentLogicalByteCount,
              receiptContract.receiptTimeoutCapsMustEqualFutureProbe,
              receiptContract.staticToolchainAndMetallibFieldsAlwaysNonNull,
              receiptContract.workerTransport
                == "parent_captured_anonymous_pipe_progress_and_at_most_one_final_candidate",
              receiptContract.workerFrameSchemaVersion == 1,
              receiptContract.workerFrameTopLevelKeys == [
                  "frame_schema_version", "kind", "payload", "sequence",
              ],
              receiptContract.workerFrameKindDomain
                == ["progress", "candidate"],
              receiptContract.workerFrameMaximumByteCount == 1_048_576,
              receiptContract.workerFrameMaximumCompactJSONByteCount
                == 1_048_575,
              receiptContract.workerTransportFrameByteCountIncludesFinalLF,
              receiptContract.supervisorTransportBufferBoundRule
                == "drift_when_unterminated_buffer_exceeds_1048575_or_completed_JSON_plus_LF_exceeds_1048576_and_never_allocate_beyond_bounded_buffer",
              receiptContract.workerTransportDoesNotAssumePIPEBUFAtomicity,
              receiptContract.workerFrameEncoding
                == "one_line_sorted_key_compact_UTF8_JSON_plus_LF",
              receiptContract.workerFrameSequenceRule
                == "UInt64_starts_0_increments_exactly_1_no_gaps_duplicates_or_reordering",
              receiptContract.workerPipeOwnershipRule
                == "dedicated_anonymous_pipe_not_stdout_worker_sole_writer_supervisor_sole_reader",
              receiptContract.workerPipeWriteRule
                == "raw_write_2_loop_handles_partial_writes_and_EINTR_no_fsync_or_stdio_fflush",
              receiptContract.workerProgressCommitRule
                == "commit_only_after_all_canonical_JSON_and_LF_bytes_written",
              receiptContract.workerProgressSnapshotRule
                == "full_cumulative_snapshot_after_each_completed_milestone_and_after_incrementing_attempted_count_before_every_potentially_fatal_lease_Metal_MLX_allocation_eval_sync_host_read_update_metric_or_clear_cache_invocation",
              receiptContract.supervisorConcurrentDrainRule
                == "blocking_read_drain_starts_immediately_after_spawn_and_runs_concurrently_through_waitpid_and_EOF_to_prevent_pipe_capacity_deadlock",
              receiptContract.supervisorFrameParsingRule
                == "incremental_LF_split_accepts_only_complete_canonical_frames_and_after_child_termination_EOF_discards_at_most_one_trailing_unterminated_fragment_with_receipt_record",
              receiptContract.supervisorTransportDriftRule
                == "malformed_complete_unknown_kind_or_schema_duplicate_out_of_order_gapped_post_candidate_second_candidate_or_frame_over_1048576_bytes_is_transport_drift",
              receiptContract.workerCandidateTerminalRule
                == "at_most_one_candidate_candidate_is_terminal_no_later_frames_no_receipt_prefix_stdout_file_or_artifact",
              receiptContract.workerCandidateAcceptedIffPASS,
              receiptContract.abstainObservedCandidateFrameRule
                == "worker_candidate_frame_count_is_observed_syntactically_complete_candidate_kind_frames;PASS_exactly_1;cooperative_or_fatal_ABSTAIN_may_be_0;late_wait_status_timeout_candidate_payload_or_transport_validation_or_trailing_partial_ABSTAIN_may_be_1;duplicate_frame_executor_receipt_drift_may_be_at_least_2;worker_candidate_present_means_one_candidate_accepted_for_PASS_and_is_false_for_every_ABSTAIN;supervisor_synthesizes_every_ABSTAIN",
              receiptContract.allABSTAINReceiptsSupervisorSynthesized,
              receiptContract.passWorkerTransportRule
                == "candidate_frame_count_1_transport_drift_false_trailing_partial_false",
              receiptContract.fatalWorkerTransportRule
                == "candidate_frame_count_may_be_0_or_1_accepted_candidate_count_0_trailing_partial_may_be_true_supervisor_uses_last_valid_cumulative_progress_wait_status_timeout_and_validation",
              receiptContract.spawnFailureWorkerTransportRule
                == "progress_count_0_candidate_count_0_last_sequence_null_trailing_partial_false_transport_drift_false",
              receiptContract.workerProgressAndMaximumOneCandidateOnly,
              receiptContract.workerStdoutReceiptCount == 0,
              receiptContract.workerReceiptFileCount == 0,
              receiptContract.workerArtifactCount == 0,
              receiptContract.supervisorSoleReceiptStdoutOwner,
              receiptContract.supervisorUsesFputsThenOneFlush,
              receiptContract
                .supervisorCompletesAllFallibleWorkBeforeCanonicalEmission,
              receiptContract.supervisorPreEmissionOrder == [
                  "monitor_and_concurrently_drain_while_applying_timeout",
                  "terminate_child_or_process_group_if_applicable",
                  "terminal_waitpid_reap_if_child_or_record_spawn_failure_if_none",
                  "drain_remaining_pipe_to_EOF_and_join_reader",
                  "reacquire_release_or_record_lease_disposition",
                  "close_transport_file_descriptors",
                  "validate_candidate_or_synthesize_ABSTAIN",
                  "construct_canonical_encode_round_trip_self_validate_final_receipt_and_exact_one_line_bytes",
              ],
              receiptContract
                .supervisorFputsAndFlushReturnAndFerrorChecksRequired,
              receiptContract
                .supervisorEmissionFailureExitsNonzeroWithoutClaimingValidReceipt,
              receiptContract
                .supervisorHasNoFallibleWorkAssertionsDefersOrCleanupAfterFlush,
              receiptContract.supervisorImmediateExitZeroAfterSuccessfulFlush,
              receiptContract.supervisorSuccessfulFlushExitAPI == "_exit(0)",
              receiptContract
                .launcherParsesCapturedLogOnlyAfterSupervisorTerminationAndRequiresExitZero,
              receiptContract
                .supervisorEmitsAfterApplicableChildTerminationAndLeaseCleanupDisposition,
              receiptContract
                .supervisorValidatesCandidateOrSynthesizesABSTAINWhenAbsent,
              receiptContract.terminalSupervisorReceiptCount == 1,
              receiptContract
                .supervisorExitsZeroAfterValidCanonicalTerminalReceiptAndCleanup,
              receiptContract
                .launcherValidatesEitherCanonicalStatusAndExitsZero,
              receiptContract
                .invalidReceiptDriftOrUncontainedNoReceiptFailureExitsNonzero,
              receiptContract
                .workerNonzeroOrSignalMayYieldGreenSupervisorABSTAIN,
              receiptContract
                .executorReceiptDriftGreenOnlyWithSynthesizedCanonicalABSTAIN,
              receiptContract
                .buildOrLauncherBeforeSupervisorFailureReceiptCount == 0,
              receiptContract
                .buildOrLauncherBeforeSupervisorFailureClassifiedExternally,
              receiptContract
                .receiptBindsExactAuthoritySourceExecutionAndProvenanceIDs,
              receiptContract.receiptBindsAllPersistentFalseCeilings,
              receiptContract
                .receiptBindsOutcomeTransitionFieldsSeparately,
              receiptContract.ceilingKeys.count == 25,
              receiptContract.outcomeTransitionKeys == [
                  "one_shot_consumed",
                  "resource_clearance_established",
                  "resource_envelope_established", "resource_probe_executed",
                  "runner_memory_capacity_established",
              ],
              receiptContract.outcomeTransitionRules.count == 5,
              receiptContract.configurationKeys.count == 45,
              receiptContract.environmentKeys.count == 26,
              receiptContract.executionKeys.count == 52,
              receiptContract.leaseKeys.count == 8,
              receiptContract.limitsKeys.count == 29,
              receiptContract.outcomeKeys.count == 19,
              receiptContract.operationCountKeys.count == 19,
              authorityClosureScope.exactChangedPaths
                == repository.authorityClosureExactChangedPaths,
              Set(authorityClosureScope.exactChangedPaths).count == 5,
              authorityClosureScope.sourceAndTestAreOnlyNewPaths,
              !authorityClosureScope.newTrainingProbeSourceAuthorized,
              !authorityClosureScope.existingTrainingSourceMutationAuthorized,
              !authorityClosureScope.newStage6LauncherAuthorized,
              !authorityClosureScope.newStage6ExecutableMainAuthorized,
              authorityClosureScope.newStage6AuthorityTestAuthorized,
              !authorityClosureScope
                .newStage6MechanicsPureContractTestAuthorized,
              successorScope.exactChangedPaths
                == successorScope.exactChangedPaths.sorted(),
              Set(successorScope.exactChangedPaths).count == 8,
              successorScope.trainingValidationManifestMutationAuthorized,
              !successorScope.trainingValidationLockMutationAuthorized,
              successorScope.newTrainingProbeSourceAuthorized,
              !successorScope.existingTrainingSourceMutationAuthorized,
              successorScope.newStage6LauncherAuthorized,
              successorScope.newStage6ExecutableMainAuthorized,
              !successorScope.newStage6AuthorityTestAuthorized,
              successorScope.newStage6MechanicsPureContractTestAuthorized,
              !successorScope.existingStage5LauncherMutationAuthorized,
              successorManifest.packageManifestPath
                == "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
              successorManifest.packageName
                == "PrimeNativeDecoderTrainingValidation",
              successorManifest.newExecutableProductCount == 1,
              successorManifest.newExecutableProductName
                == "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe",
              successorManifest.newExecutableProductTargetNames
                == ["PrimeNativeDecoderNative300MResourceOnlyOneStepProbe"],
              successorManifest.newExecutableTargetCount == 1,
              successorManifest.newExecutableTargetName
                == successorManifest.newExecutableProductName,
              successorManifest.newExecutableTargetSourcePath
                == "Sources/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe/main.swift",
              successorManifest.newExecutableTargetDirectProductDependencies
                == [
                    ".product(name:\"PrimeNativeDecoderTraining\",package:\"ergentics-prime\")",
                ],
              successorManifest
                .newExecutableTargetDirectMLXProductDependencyCount == 0,
              successorManifest.newExecutableTargetLinkerFrameworks
                == ["CoreGraphics", "Metal"],
              successorManifest.newExecutableMainImports
                == ["Foundation", "PrimeNativeDecoderTraining"],
              successorManifest.newExecutableMainEntryPoint
                == "PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.runSupervisor()",
              successorManifest.trainingProbeSourcePath
                == "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift",
              successorManifest.trainingProbeSourceImports == [
                  "CoreGraphics", "Darwin", "Foundation", "Metal", "MLX",
                  "MLXNN", "MLXOptimizers", "PrimeCore",
                  "PrimeNativeDecoder",
              ],
              successorManifest.existingTestTargetName
                == "PrimeNativeDecoderTrainingTests",
              successorManifest.newContractTestPath
                == "Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests.swift",
              successorManifest.newContractTestClassName
                == "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests",
              successorManifest.newContractTestMethodName
                == "testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure",
              successorManifest.newContractTestFilter
                == "PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests/testNative300MResourceOnlyOneStepProbeContractIsExactAndExecutionPure",
              successorManifest.focusedValidationContractTestFilter
                == successorManifest.newContractTestFilter,
              successorManifest.stage6LauncherContractTestFilter
                == successorManifest.newContractTestFilter,
              successorManifest.bothContractTestInvocationsUseSameExactFilterOnce,
              futureProbe.releaseContractXCTestCommand.hasSuffix(
                  "--filter " + successorManifest.newContractTestFilter),
              successorManifest.newContractTestImports == [
                  "Foundation", "MLX", "PrimeCore",
                  "PrimeNativeDecoderTraining", "XCTest",
              ],
              successorManifest
                .existingTestTargetDirectProductDependenciesAfterMutation == [
                    ".product(name:\"PrimeCore\",package:\"ergentics-prime\")",
                    ".product(name:\"PrimeNativeDecoderTraining\",package:\"ergentics-prime\")",
                    ".product(name:\"MLX\",package:\"ergentics-mlx-swift\")",
                ],
              successorManifest.existingTestTargetLinkerFrameworks
                == ["CoreGraphics", "Metal"],
              successorManifest.existingTrainingAndMLXTestDependenciesRetained,
              successorManifest.rootPackageManifestMustRemainByteIdentical,
              suite.authorityRootTestCount == 55,
              suite.isolatedTestCount
                == suite.isolatedGroupTestCounts.reduce(0, +),
              suite.authorityFocusedWholeTestCount
                == suite.authorityRootTestCount + suite.isolatedTestCount,
              suite.authorityTotalTestCount
                == suite.authorityFocusedWholeTestCount
                    + suite.predecessorMetalTestCount
                    + suite.predecessorRuntimeTestCount
                    + suite.predecessorTokenizerTestCount,
              suite.authorityStage5LauncherInvocationCount == 0,
              suite.authorityStage5ReceiptCount == 0,
              suite.authorityStage6LauncherInvocationCount == 0,
              suite.authorityStage6ReceiptCount == 0,
              suite.futureStage6PureContractFocusedXCTestCount == 1,
              suite.futureStage6PureContractDirectXCTestCount == 1,
              suite.futureStage6PureContractXCTestStartCount
                == suite.futureStage6PureContractFocusedXCTestCount
                    + suite.futureStage6PureContractDirectXCTestCount,
              suite.futureStage6ExecutableOperationalProbeCount == 1,
              suite.futureStage6LauncherLocalAggregateDirectInvocationCount
                == suite.futureStage6PureContractDirectXCTestCount
                    + suite.futureStage6ExecutableOperationalProbeCount,
              suite.futureStage6AggregateInvocationCount
                == suite.futureStage6PureContractXCTestStartCount
                    + suite.futureStage6ExecutableOperationalProbeCount,
              suite.futureMechanicsXCTestTotalCount
                == suite.authorityTotalTestCount
                    + suite.futureStage6PureContractXCTestStartCount,
              suite.futureMechanicsLiveOrder == [
                  "metal", "maintained_runtime", "tokenizer", "stage6",
              ],
              suite.futureStage6InternalOrder == [
                  "stage6_pure_contract_xctest",
                  "stage6_resource_probe_executable",
              ],
              ceiling.authorityOnlyNoProbeResultEvidence,
              ceiling.mechanicsImplementationAuthorizedAfterGreenAuthorityClosure,
              ceiling.oneExactMainResourceProbeOpportunityAuthorized,
              ceiling.oneNative300MAllocationAuthorizedForResourceProbe,
              ceiling.oneNative300MTrainingStepAuthorizedForResourceProbe,
              ceiling.boundedResourceMeasurementAuthorized,
              ceiling.tinyTypedInMemoryResumeEstablished
                == stage3Observation.stage3
                    .typedInMemorySnapshotExportRestoreEstablished,
              ceiling.tinyDurableSnapshotRoundTripEstablished
                == stage4Observation.receipt
                    .exactStage3SnapshotRoundTripEstablished,
              !ceiling.generalTrainingResumeEstablished,
              !ceiling.native300MTrajectoryTrainingResumeEstablished,
              falseCeilings.allSatisfy({ !$0 }),
              orderedRequiredSeparateActions.count == 5,
              status.hasPrefix("AUTHORIZED_stage6_") else {
            throw PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityError
                .contractDrift("frozen V1")
        }
    }

    private static func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }
}
