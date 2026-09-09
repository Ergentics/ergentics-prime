// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityError:
    Error, Equatable, Sendable
{
    case contractDrift(String)
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderBSpecificNative300MSourceIdentityV1:
    Codable, Equatable, Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
    public let role: String
}

public struct PrimeNativeDecoderBSpecificNative300MRepositoryV1:
    Codable, Equatable, Sendable
{
    public let repository: String
    public let ref: String
    public let authorityBaseRevision: String
    public let authorityBaseTree: String
    public let authorityBaseOrderedParents: [String]
    public let retirementPullRequestNumber: Int
    public let retirementReviewedHeadRevision: String
    public let retirementReviewedHeadTree: String
    public let retirementMergedAt: String
    public let retirementWorkflowRunID: Int
    public let retirementWorkflowRunNumber: Int
    public let retirementWorkflowRunAttempt: Int
    public let retirementCheckSuiteID: Int
    public let retirementActiveRootJobID: Int
    public let retirementActiveRootRunnerImage: String
    public let retirementActiveRootJobConclusion: String
    public let retirementReviewedMainJobID: Int
    public let retirementReviewedMainRunnerImage: String
    public let retirementReviewedMainJobConclusion: String
    public let retirementPreviousAttemptURLWasNull: Bool
    public let retirementExactHeadPushRunCount: Int
    public let retirementRerunCount: Int
    public let retirementArtifactCount: Int
    public let retirementRootTestCount: Int
    public let retirementIsolatedGroupTestCounts: [Int]
    public let retirementIsolatedTestCount: Int
    public let retirementFocusedWholeTestCount: Int
    public let retirementMetalTestCount: Int
    public let retirementMaintainedRuntimeTestCount: Int
    public let retirementTokenizerTestCount: Int
    public let retirementTotalTestCount: Int
    public let retirementLiveOrder: [String]
    public let retirementOriginalStage5LauncherInvocationCount: Int
    public let retirementReplacementStage5LauncherInvocationCount: Int
    public let retirementHistoricalStage6LauncherInvocationCount: Int
    public let retirementMaintainedRuntimeReceiptCount: Int
    public let retirementTokenizerReceiptCount: Int
    public let retirementOriginalStage5ReceiptCount: Int
    public let retirementReplacementStage5ReceiptCount: Int
    public let retirementHistoricalStage6ReceiptCount: Int
    public let retirementBResourceWitnessReceiptCount: Int
    public let retirementExactChangedPaths: [String]
    public let retirementChangedSourceIdentities:
        [PrimeNativeDecoderBSpecificNative300MSourceIdentityV1]
    public let preservedIndexSHA256: String
    public let embeddedSourceIdentitySHA256: String
    public let authorityClosureExactChangedPaths: [String]
    public let authoritySourceAndTestAreOnlyNewPaths: Bool
    public let immutableBaseSourceBindings:
        [PrimeNativeDecoderBSpecificNative300MSourceIdentityV1]
}

public struct PrimeNativeDecoderBSpecificNative300MStage5PassV1:
    Codable, Equatable, Sendable
{
    public let authorityID: String
    public let authorityCanonicalSHA256: String
    public let currentDecoderIdentityObservationID: String
    public let currentDecoderIdentityCanonicalSHA256: String
    public let passObservationID: String
    public let passObservationCanonicalSHA256: String
    public let mechanicsRevision: String
    public let mechanicsTree: String
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let workflowRunAttempt: Int
    public let checkSuiteID: Int
    public let activeRootJobID: Int
    public let reviewedMainJobID: Int
    public let runConclusion: String
    public let reviewedMainJobConclusion: String
    public let launcherInvocationCount: Int
    public let directXCTestInvocationCount: Int
    public let testPassCount: Int
    public let testFailureCount: Int
    public let testSkipCount: Int
    public let receiptID: String
    public let receiptPrefix: String
    public let receiptPrefixByteCount: Int
    public let receiptRawJSONByteCount: Int
    public let receiptRawJSONSHA256: String
    public let receiptPrefixedByteCount: Int
    public let receiptPrefixedSHA256: String
    public let receiptStatus: String
    public let receiptOccurrenceCount: Int
    public let oneShotConsumed: Bool
    public let oneShotExhausted: Bool
    public let armATrialCount: Int
    public let armACompletedDiagnosticPairCount: Int
    public let armAMeasuredMismatch: Bool
    public let armBTrialCount: Int
    public let armBBranchCount: Int
    public let armBComparisonDomainCount: Int
    public let armBAllExactComparisonsPassed: Bool
    public let armBAllForwardEquivalenceChecksPassed: Bool
    public let armBTrainingStepCount: Int
    public let armBEvaluateCount: Int
    public let armBSnapshotCount: Int
    public let armBRestoreCount: Int
    public let armBForwardEquivalenceCheckCount: Int
    public let armBDenseWholeLogitsCallCount: Int
    public let armBDenseEmbeddingConstructionCount: Int
    public let armBTokenBoundsValidationCount: Int
    public let armBTokenBoundsCheckedEvalCount: Int
    public let armBTokenBoundsGPUSynchronizeCount: Int
    public let armBTokenBoundsHostBoolItemCount: Int
    public let stage5MechanicsSuccessEstablished: Bool
    public let stage5ResultEstablished: Bool
    public let stage5AssayClearanceEstablished: Bool
    public let repeatedSameDeviceBPathDeterminismEstablished: Bool
    public let exactSameDeviceBPathGradientBytesEstablished: Bool
    public let defaultGatherDeterminismEstablished: Bool
    public let outerLauncherFailureMessage: String
    public let outerLauncherExitCode: Int
    public let outerLeaseParentGuardConjuncts: [String]
    public let outerLeaseParentGuardFailed: Bool
    public let failedGuardConjunctIdentified: Bool
    public let actualLeaseParentMetadataObserved: Bool
    public let localAPFSLinkCountReproductionBoundAsCause: Bool
    public let receiptEstablishedBeforeOuterFailure: Bool
    public let launcherPostReceiptCompletionEstablished: Bool
    public let outerWorkflowSuccessEstablished: Bool
    public let replacementLauncherRetired: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MHistoricalStage6V1:
    Codable, Equatable, Sendable
{
    public let authorityID: String
    public let authorityCanonicalSHA256: String
    public let observationID: String
    public let observationCanonicalSHA256: String
    public let mechanicsRevision: String
    public let mechanicsTree: String
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let workflowRunAttempt: Int
    public let checkSuiteID: Int
    public let receiptRawJSONByteCount: Int
    public let receiptRawJSONSHA256: String
    public let receiptPrefixedByteCount: Int
    public let receiptPrefixedSHA256: String
    public let trainingLogitsAPI: String
    public let trainingInputPathID: String
    public let uniqueParameterCount: UInt64
    public let parameterPathCount: Int
    public let observedPhysicalMemoryCapacityBytes: UInt64
    public let configuredMemoryLimitBytes: UInt64
    public let observedMLXPeakBytes: UInt64
    public let workerElapsedNanoseconds: UInt64
    public let resourceProbeExecuted: Bool
    public let resourceEnvelopeEstablished: Bool
    public let resourceClearanceEstablished: Bool
    public let runnerMemoryCapacityEstablished: Bool
    public let ordinaryJobFitEstablished: Bool
    public let oneShotConsumed: Bool
    public let retirementRevision: String
    public let retirementTree: String
    public let retirementPullRequestNumber: Int
    public let retirementWorkflowRunID: Int
    public let retirementWorkflowRunNumber: Int
    public let retirementObserved: Bool
    public let remainsHistoricalEvidence: Bool
    public let appliesToCurrentBPath: Bool
    public let mayBeUsedAsBPeakPrediction: Bool
    public let mayBeUsedAsBResourceClearance: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MPathV1:
    Codable, Equatable, Sendable
{
    public let algorithmID: String
    public let selectorCase: String
    public let selectorRawValue: String
    public let trainingLogitsAPI: String
    public let maintainedGatherTrainingLogitsAPI: String
    public let inputEmbeddingForwardPairAPI: String
    public let decoderSource:
        PrimeNativeDecoderBSpecificNative300MSourceIdentityV1
    public let trainingSource:
        PrimeNativeDecoderBSpecificNative300MSourceIdentityV1
    public let packageOnlySurfaceRequired: Bool
    public let publicDecoderAPIAdded: Bool
    public let currentDecoderIdentityIsSoleRetainedLiveIdentity: Bool
    public let defaultGatherPathRemainsByteIdentical: Bool
    public let densePathIsExplicitOptIn: Bool
    public let decoderLayersFinalNormAndOutputProjectionSharedWithMaintainedPath:
        Bool
    public let tokenBoundsCombinedPredicate: String
    public let tokenBoundsCheckedInt32VocabularyConversionRequired: Bool
    public let tokenBoundsCheckedEvalCountPerDenseConstruction: Int
    public let tokenBoundsGPUSynchronizeCountPerDenseConstruction: Int
    public let tokenBoundsHostBoolItemCountPerDenseConstruction: Int
    public let denseMatmulCountPerDenseConstruction: Int
}

public struct PrimeNativeDecoderBSpecificNative300MConfigurationV1:
    Codable, Equatable, Sendable
{
    public let compatibilitySchemaID: String
    public let modelConfigurationFactory: String
    public let modelFactory: String
    public let vocabularySize: Int
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
    public let parameterDType: String
    public let logicalParameterByteCount: UInt64
    public let initializationSeed: UInt64
    public let batchSize: Int
    public let sequenceLength: Int
    public let validTokenCount: Int
    public let selectedTargetCount: Int
    public let tokenAlgorithmID: String
    public let batchTokenIDs: [[Int]]
    public let batchTokenIDsSHA256: String
    public let batchTokenIDsSHA256PreimageRule: String
    public let completionMask: [[Bool]]
    public let tokenIDStorageDType: String
    public let completionMaskStorageDType: String
    public let flattenedTokenColumnShape: [Int]
    public let vocabularyRowShape: [Int]
    public let denseOneHotShape: [Int]
    public let denseOneHotDType: String
    public let denseOneHotElementCount: Int
    public let denseOneHotLogicalByteCount: UInt64
    public let flattenedDenseEmbeddingShape: [Int]
    public let flattenedDenseEmbeddingDType: String
    public let flattenedDenseEmbeddingElementCount: Int
    public let flattenedDenseEmbeddingLogicalByteCount: UInt64
    public let restoredDenseEmbeddingShape: [Int]
    public let trainingLogitsExpectedShape: [Int]
    public let trainingLogitsDType: String
    public let trainingLogitsUsesCausalAttentionMask: Bool
    public let shiftedLogitsSlice: String
    public let shiftedTargetsSlice: String
    public let shiftedCompletionMaskSlice: String
    public let shiftedLogitsExpectedShape: [Int]
    public let shiftedTargetsExpectedShape: [Int]
    public let shiftedCompletionMaskExpectedShape: [Int]
    public let shiftedCompletionMaskAllTrue: Bool
    public let lossGraphAlgorithmID: String
    public let crossEntropyAPI: String
    public let crossEntropyWeights: String
    public let crossEntropyAxis: Int
    public let crossEntropyLabelSmoothingFloat32BitPattern: UInt32
    public let crossEntropyReduction: String
    public let valueAndGradAPI: String
    public let valueAndGradClosureArguments: [String]
    public let valueAndGradClosureReturnsOnlyScalarLoss: Bool
    public let optimizerQualifiedType: String
    public let optimizerStateInspectionAPI: String
    public let optimizerStateExpectedArrayCount: Int
    public let optimizerStateExpectedPairCount: Int
    public let learningRateFloat32BitPattern: UInt32
    public let beta1Float32BitPattern: UInt32
    public let beta2Float32BitPattern: UInt32
    public let epsilonFloat32BitPattern: UInt32
    public let weightDecayFloat32BitPattern: UInt32
    public let maximumGradientNormFloat32BitPattern: UInt32
    public let gradientNormEpsilonFloat32BitPattern: UInt32
    public let rawGradientNormAlgorithmID: String
    public let gradientClipAlgorithmID: String
    public let parameterFingerprintAlgorithmID: String
    public let parameterFingerprintExpectedSampleCount: Int
    public let gradientAccumulationCount: Int
    public let optimizerStepCount: Int
    public let paddingAuthorized: Bool
    public let kvCacheAuthorized: Bool
    public let evaluationForwardAuthorized: Bool
    public let generationAuthorized: Bool
    public let checkpointAuthorized: Bool
    public let configurationIsResourceWitnessOnlyNotTrainingPolicy: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MResourceEnvelopeV1:
    Codable, Equatable, Sendable
{
    public let weightsLogicalByteCount: UInt64
    public let gradientLogicalByteCount: UInt64
    public let optimizerMomentTensorCount: Int
    public let optimizerMomentLogicalByteCount: UInt64
    public let minimumCommittedTensorStateByteCount: UInt64
    public let minimumStatePlusGradientByteCount: UInt64
    public let threeTimesCommittedStateDiskComparatorByteCount: UInt64
    public let minimumConfiguredMLXMemoryLimitByteCount: UInt64
    public let configuredMLXMemoryLimitMaximumByteCount: UInt64
    public let configuredMLXMemoryLimitFormula: String
    public let configuredMLXCacheLimitByteCount: UInt64
    public let minimumAvailableFilesystemByteCount: UInt64
    public let workerActiveTimeoutSeconds: Int
    public let supervisorEndToEndTimeoutSeconds: Int
    public let terminationGraceSeconds: Int
    public let requiredPhaseNames: [String]
    public let requiredMetricKeys: [String]
    public let historicalStage6PeakIsBaselineOnly: Bool
    public let analyticBIncrementalBytesArePeakEvidence: Bool
    public let analyticBIncrementalBytesAreClearanceEvidence: Bool
    public let containerHeadersAndManifestsIncludedInMinimum: Bool
    public let duplicateGraphsAndTemporaryBuffersIncludedInMinimum: Bool
    public let configuredMLXLimitIsProcessRSSLimit: Bool
    public let filesystemObservationIsCheckpointDiskSufficiencyClaim: Bool
    public let passRequiresAllPhaseMetricsObserved: Bool
    public let passRequiresMeasuredPeakBelowConfiguredLimit: Bool
    public let passEstablishesOnlyExactRunResourceWitness: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MExecutionPlanV1:
    Codable, Equatable, Sendable
{
    public let swiftPMBuildConfiguration: String
    public let buildCount: Int
    public let focusedPureContractXCTestCount: Int
    public let launcherPureContractXCTestCount: Int
    public let pureContractXCTestStartCount: Int
    public let launcherInvocationCount: Int
    public let directExecutableProbeCount: Int
    public let successorAggregateInvocationCount: Int
    public let supervisorProcessCount: Int
    public let maximumWorkerProcessCount: Int
    public let workerSpawnAttemptCount: Int
    public let successorAggregateInvocationTopology: [String]
    public let modelAllocationCount: Int
    public let modelMaterializationCount: Int
    public let valueAndGradCount: Int
    public let directPackageBTrainingLogitsAPICallCount: Int
    public let maintainedGatherTrainingLogitsCount: Int
    public let tinyTrainingSelectorInvocationCount: Int
    public let inputEmbeddingForwardPairDiagnosticInvocationCount: Int
    public let denseEmbeddingConstructionCount: Int
    public let tokenBoundsValidationCount: Int
    public let tokenBoundsCheckedEvalCount: Int
    public let tokenBoundsGPUSynchronizeCount: Int
    public let tokenBoundsHostBoolItemCount: Int
    public let crossEntropyCount: Int
    public let forwardLossCount: Int
    public let backwardCount: Int
    public let rawGradientNormCount: Int
    public let gradientClipCount: Int
    public let optimizerStepCount: Int
    public let adamWUpdateCount: Int
    public let fullGraphEvaluationCount: Int
    public let checkedEvaluationBarrierCount: Int
    public let gpuSynchronizationBarrierCount: Int
    public let orderedCheckedEvaluationAndSynchronizationBarriers: [String]
    public let memoryClearCacheCount: Int
    public let postflightDeviceReenumerationCount: Int
    public let kvCacheAllocationCount: Int
    public let evaluationForwardPassCount: Int
    public let checkpointReadCount: Int
    public let checkpointWriteCount: Int
    public let artifactUploadCount: Int
    public let qualityMetricComputationCount: Int
    public let generatedTokenCount: Int
    public let oneExactMainOpportunityAfterGreenAuthorityClosure: Bool
    public let retryAuthorized: Bool
    public let rerunAuthorized: Bool
    public let replacementRunAuthorized: Bool
    public let resourceOperationCountsArePassPathExact: Bool
    public let abstainOperationCountsAreAttemptedPrefixCounts: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MInheritedResourceContractV1:
    Codable, Equatable, Sendable
{
    public let historicalAuthorityID: String
    public let historicalAuthorityCanonicalSHA256: String
    public let preservationRule: String
    public let exactAuthorizedDeltas: [String]
    public let mlxEnableTF32: String
    public let exactMLXRevision: String
    public let metalDeviceIndex: Int
    public let exactMetalDeviceCount: Int
    public let singletonDeviceEnumerationRequired: Bool
    public let indexZeroMustMatchDefaultDevice: Bool
    public let mlxGraphCompileMode: String
    public let mlxCompileTransformInvocationCount: Int
    public let configuredMLXMemoryLimitSetter: String
    public let configuredMLXMemoryLimitSetCount: Int
    public let configuredMLXMemoryLimitReadbackRequired: Bool
    public let configuredMLXCacheLimitSetter: String
    public let configuredMLXCacheLimitSetCount: Int
    public let configuredMLXCacheLimitReadbackRequired: Bool
    public let mlxPeakMemoryResetAPI: String
    public let mlxPeakMemoryResetCount: Int
    public let filesystemObservationUsesStatFS: Bool
    public let filesystemObservationRequiresStableOrderedFSID: Bool
    public let phaseAndLiveSetRulesInheritedWithoutChange: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MLeaseReceiptIntegrityV1:
    Codable, Equatable, Sendable
{
    public let leaseType: String
    public let leaseAcquisitionMode: String
    public let preflightParentRequiredTupleFields: [String]
    public let descriptorDerivedIdentityFields: [String]
    public let parentDescriptorOpenFlags: [String]
    public let leaseFileDescriptorOpenFlags: [String]
    public let descriptorNameRebindRequired: Bool
    public let descriptorNameRebindMustMatchDeviceAndInode: Bool
    public let identityEvidenceIsDescriptorDerivedInSupervisorAndVerifier:
        Bool
    public let preflightParentMustBeEmptyDirectory: Bool
    public let preflightParentMustBeNonSymlink: Bool
    public let preflightParentPhysicalPathMustEqualExpectedPath: Bool
    public let parentRequiredFileType: String
    public let parentRequiredOwnerMatchesEffectiveUID: Bool
    public let parentGroupPolicy: String
    public let parentRequiredMode: String
    public let parentSecurityFlagsRequiredValue: Int
    public let parentACLEntryCountRequired: Int
    public let parentAllowedExtendedAttributeNames: [String]
    public let parentObservedExtendedAttributeNamesMustBeAllowedSubset: Bool
    public let parentLinkCountObserved: Bool
    public let parentLinkCountMustBePositive: Bool
    public let parentLinkCountUsedAsStableIdentityAfterChildCreation: Bool
    public let postCandidateParentFieldsRequiringExactPreflightEquality:
        [String]
    public let postCandidateParentIdentityGuardIsOpaqueAggregate: Bool
    public let postCandidateParentMismatchIdentifiesExactField: Bool
    public let exactOneChildInventoryRequired: Bool
    public let leaseInventoryComparisonRule: String
    public let exactChildBasename: String
    public let leaseFileMustBeRegularNonSymlink: Bool
    public let leaseFileMustMatchParentDeviceID: Bool
    public let leaseFileRequiredOwnerMatchesEffectiveUID: Bool
    public let leaseFileRequiredGroupMatchesEffectiveGID: Bool
    public let leaseFileRequiredMode: String
    public let leaseFileRequiredLinkCount: Int
    public let leaseFileRequiredByteCount: Int
    public let leaseFileSecurityFlagsRequiredValue: Int
    public let leaseFileACLEntryCountRequired: Int
    public let leaseFileAllowedExtendedAttributeNames: [String]
    public let leaseFileObservedExtendedAttributeNamesMustBeAllowedSubset: Bool
    public let resourceWorkerExecProcessCount: Int
    public let releaseVerifierExecProcessCount: Int
    public let operationalProbeRoleProcessInvocationCount: Int
    public let resourceWorkerSpawnCount: Int
    public let releaseVerifierSpawnCount: Int
    public let primeLeaseAcquireAttemptCount: Int
    public let primeLeaseAcquireSuccessCount: Int
    public let primeLeaseReleaseCallCount: Int
    public let individualFlockSyscallSuccessClaimCount: Int
    public let individualCloseSyscallSuccessClaimCount: Int
    public let supervisorIsSoleLeaseOwnerBeforeExplicitRelease: Bool
    public let supervisorHoldsLeaseThroughCandidateAndDeviceMLXPostflight: Bool
    public let explicitSupervisorReleaseCount: Int
    public let releaseVerifierExecChildCount: Int
    public let verifierExecutesWhileSupervisorAliveAfterVoidRelease: Bool
    public let releaseVerifierMustAcquireReleaseAndExitZero: Bool
    public let releaseVerifierExitZeroObservationCount: Int
    public let supervisorExitZeroObservationCount: Int
    public let outerWaitsForSupervisorExitBeforePublication: Bool
    public let verifierProcessExitProvidesKernelCloseBackstop: Bool
    public let workerExecInheritsLeaseFileDescriptorCount: Int
    public let verifierParentDeviceAndInodeMustEqualSupervisorPreRelease:
        Bool
    public let verifierLeaseFileDeviceAndInodeMustEqualSupervisorPreRelease:
        Bool
    public let outerFinalReboundIdentityMustMatchVerifier: Bool
    public let launcherUnlinksLeaseFile: Bool
    public let launcherRemovesLeaseParent: Bool
    public let launcherCleanupUnlinkCount: Int
    public let launcherCleanupRemoveFileCount: Int
    public let launcherCleanupRemoveDirectoryCount: Int
    public let persistentLeaseRootAndLeafAreIntentionalLeaseSemantics: Bool
    public let persistentLeaseRootAndLeafAreRetainedArtifact: Bool
    public let privateWorkingDirectoryPostflightRequired: Bool
    public let repositoryPostflightRequired: Bool
    public let metallibPostflightRequired: Bool
    public let internalCandidatePrefix: String
    public let publicCanonicalReceiptPrefix: String
    public let internalCandidateMaximumCount: Int
    public let workerPublicCanonicalReceiptCount: Int
    public let supervisorPublicCanonicalReceiptCount: Int
    public let launcherPublicCanonicalReceiptMaximumCount: Int
    public let validTerminalClassificationPublicReceiptCount: Int
    public let internalCandidateIsResultEvidence: Bool
    public let publicPrefixCountsAreAllOutcomeCeilings: Bool
    public let processLeaseAcquireAndReleaseCountsArePassPathExact: Bool
    public let abstainProcessAndLeaseCountsAreAttemptedPrefixCounts: Bool
    public let outerPathRebindThreatModel: String
    public let outerPathRebindIsAuthoritativeAgainstHostileSameUIDMutation: Bool
    public let anyPublicReceiptRequiresTerminalClassificationClosure: Bool
    public let anyPublicReceiptRequiresSupervisorTermination: Bool
    public let passRequiresValidatedScientificCandidate: Bool
    public let passRequiresLeaseReleaseVerifierAndPersistentIdentityProof:
        Bool
    public let passRequiresAllPostflights: Bool
    public let passRequiresOuterIntegritySuccess: Bool
    public let resourceAbstainMayBeSupervisorSynthesizedWithoutCandidate:
        Bool
    public let resourceAbstainMayCompleteWithoutReleaseVerifierOnlyWhenNoLeaseWasAcquired:
        Bool
    public let resourceAbstainAfterLeaseAcquisitionRequiresReleaseVerifier:
        Bool
    public let resourceAbstainRequiresApplicableLeaseDispositionProof: Bool
    public let resourceAbstainRequiresAllApplicableOuterPostflights: Bool
    public let resourceAbstainRequiresSafeOuterPublicationClosure: Bool
    public let integrityAbstainRequiresSupervisorTermination: Bool
    public let integrityAbstainRequiresTerminalClassificationClosure: Bool
    public let integrityAbstainRequiresOuterIntegritySuccess: Bool
    public let publicReceiptEmissionAndFlushAreFinalFallibleLauncherAction:
        Bool
    public let launcherExitTrapsClearedBeforePublicReceipt: Bool
    public let finalPublicReceiptCommand: String
    public let noAuthoredActionAfterFinalPublicReceiptExec: Bool
    public let launcherOKMarkerAfterPublicReceipt: Bool
    public let publicReceiptEmissionFailureExitsNonzeroWithoutReceiptClaim:
        Bool
    public let candidateIntegrityOrPostflightFailureEmitsPassOrResourceAbstain:
        Bool
    public let candidateIntegrityOrPostflightFailureEstablishesClearance: Bool
    public let candidateIntegrityOrPostflightFailureConsumesOpportunity: Bool
    public let candidateIntegrityOrPostflightFailurePermitsRetry: Bool
    public let candidateIntegrityOrPostflightFailureEmitsIntegrityAbstainWhenSafelyClassifiable:
        Bool
    public let integrityFailureReceiptStatus: String
    public let integrityFailureReceiptRequiresValidatedCandidate: Bool
    public let integrityFailureReceiptPreservesCandidateScientificStatus:
        Bool
    public let integrityFailureReceiptRequiresFirstFailedGuard: Bool
    public let integrityFailureReceiptRequiresErrnoWhenAvailable: Bool
    public let integrityFailureReceiptRequiresActualMetadataAvailability:
        Bool
    public let integrityFailureReceiptActualMetadataMayBeNull: Bool
    public let integrityFailureReceiptNullActualMetadataRequiresUnavailableReasonOrErrno:
        Bool
    public let integrityFailureReceiptRequiredBindings: [String]
    public let orderedIntegrityGuardIDs: [String]
    public let integrityFailureReceiptEstablishesResourceClearance: Bool
    public let malformedOrUnsafePrivatePacketMayProduceNoPublicReceipt: Bool
    public let candidateRemainsSeparatelyObservableInRetirement: Bool
    public let receiptForbiddenUnscopedSuccessKeys: [String]
    public let run117AggregateGuardFailed: Bool
    public let run117FailedConjunctIdentified: Bool
    public let run117ParentMetadataObserved: Bool
    public let localAPFSDiagnosticBoundAsRun117Cause: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MScopeV1:
    Codable, Equatable, Sendable
{
    public let exactChangedPaths: [String]
    public let rootPackageManifestMutationAuthorized: Bool
    public let rootPackageResolvedMutationAuthorized: Bool
    public let validationManifestMutationAuthorized: Bool
    public let validationLockMutationAuthorized: Bool
    public let newAuthoritySourceAuthorized: Bool
    public let newAuthorityTestAuthorized: Bool
    public let newLauncherAuthorized: Bool
    public let newTrainingProbeSourceAuthorized: Bool
    public let newExecutableMainAuthorized: Bool
    public let newPureContractTestAuthorized: Bool
    public let existingDecoderSourceMutationAuthorized: Bool
    public let existingTrainingSourceMutationAuthorized: Bool
    public let historicalStage6MechanicsMutationAuthorized: Bool
    public let originalStage5MechanicsMutationAuthorized: Bool
    public let replacementStage5MechanicsMutationAuthorized: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MSuccessorManifestV1:
    Codable, Equatable, Sendable
{
    public let launcherPath: String
    public let packageManifestPath: String
    public let packageName: String
    public let executableProductName: String
    public let executableTargetName: String
    public let executableMainPath: String
    public let executableMainImports: [String]
    public let executableMainEntryPoint: String
    public let trainingProbeSourcePath: String
    public let trainingProbePublicType: String
    public let contractTestPath: String
    public let contractTestClassName: String
    public let contractTestMethodName: String
    public let contractTestFilter: String
    public let rootPackageManifestMustRemainByteIdentical: Bool
    public let decoderAndExistingTrainingSourcesMustRemainByteIdentical: Bool
    public let historicalStage6MechanicsMustRemainByteIdentical: Bool
    public let originalAndReplacementStage5MechanicsMustRemainByteIdentical:
        Bool
    public let authorityActiveJobTimeoutMinutes: Int
    public let authorityReviewedJobTimeoutMinutes: Int
    public let successorActiveJobTimeoutMinutes: Int
    public let successorReviewedJobTimeoutMinutes: Int
    public let successorReviewedOnlyTimeoutMutationAuthorized: Bool
    public let retirementReviewedJobTimeoutMinutes: Int
    public let retirementMustRestoreReviewedTimeout: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MSuiteV1:
    Codable, Equatable, Sendable
{
    public let authorityRootTestCount: Int
    public let isolatedGroupTestCounts: [Int]
    public let isolatedTestCount: Int
    public let authorityFocusedWholeTestCount: Int
    public let metalTestCount: Int
    public let maintainedRuntimeTestCount: Int
    public let tokenizerTestCount: Int
    public let authorityTotalXCTestCount: Int
    public let authorityLiveOrder: [String]
    public let authorityOriginalStage5LauncherInvocationCount: Int
    public let authorityReplacementStage5LauncherInvocationCount: Int
    public let authorityHistoricalStage6LauncherInvocationCount: Int
    public let authorityBResourceWitnessLauncherInvocationCount: Int
    public let authorityMaintainedRuntimeReceiptCount: Int
    public let authorityTokenizerReceiptCount: Int
    public let authorityOriginalStage5ReceiptCount: Int
    public let authorityReplacementStage5ReceiptCount: Int
    public let authorityHistoricalStage6ReceiptCount: Int
    public let authorityBResourceWitnessReceiptCount: Int
    public let futureFocusedStepXCTestCount: Int
    public let futureLiveStepXCTestCount: Int
    public let futureTotalXCTestCount: Int
    public let futureBContractFocusedXCTestCount: Int
    public let futureBContractLauncherXCTestCount: Int
    public let futureBContractXCTestStartCount: Int
    public let futureBExecutableOperationalProbeCount: Int
    public let futureBSuccessorAggregateInvocationCount: Int
    public let futureBLauncherInvocationCount: Int
    public let futureBPublicReceiptMaximumCount: Int
    public let futureMaintainedRuntimeReceiptCount: Int
    public let futureTokenizerReceiptCount: Int
    public let futureOriginalStage5ReceiptCount: Int
    public let futureReplacementStage5ReceiptCount: Int
    public let futureHistoricalStage6ReceiptCount: Int
    public let futureOriginalStage5LauncherInvocationCount: Int
    public let futureReplacementStage5LauncherInvocationCount: Int
    public let futureHistoricalStage6LauncherInvocationCount: Int
    public let futureLiveOrder: [String]
    public let futureBInternalOrder: [String]
}

public struct PrimeNativeDecoderBSpecificNative300MOutcomeTransitionsV1:
    Codable, Equatable, Sendable
{
    public let publicStatusDomain: [String]
    public let passClassification: String
    public let abstainClassifications: [String]
    public let integrityAbstainClassification: String
    public let noPublicReceiptClassifications: [String]
    public let classificationDecisionRules: [String]
    public let authorityClosureExecutesWitness: Bool
    public let passRequiresExactBAPIAndOperationCounts: Bool
    public let passRequiresFiniteLossAndPositiveRawGradientNorm: Bool
    public let passRequiresParameterFingerprintChange: Bool
    public let passRequiresAllResourceAndIntegrityClosureProof: Bool
    public let passEstablishesBSpecificResourceWitness: Bool
    public let passEstablishesBSpecificResourceClearance: Bool
    public let passEstablishesHistoricalStage6ApplicabilityToB: Bool
    public let passEstablishesOrdinaryJobFit: Bool
    public let passAuthorizesStage7: Bool
    public let passRequiresSeparateStage7Authority: Bool
    public let abstainEstablishesTerminalBResourceObservation: Bool
    public let abstainEstablishesBSpecificResourceWitness: Bool
    public let abstainEstablishesBSpecificResourceClearance: Bool
    public let abstainAuthorizesStage7: Bool
    public let integrityAbstainStatus: String
    public let integrityAbstainRequiresCandidatePresent: Bool
    public let integrityAbstainCandidateScientificStatusDomain: [String]
    public let integrityAbstainEstablishesBSpecificResourceWitness: Bool
    public let integrityAbstainEstablishesResourceClearance: Bool
    public let integrityAbstainPreservesCandidateForRetirement: Bool
    public let malformedOrUnsafePrivatePacketEmitsPublicReceipt: Bool
    public let malformedOrUnsafePrivatePacketEstablishesResult: Bool
    public let mechanicsBeginningConsumesOneShotEvenWithoutTerminalReceipt:
        Bool
    public let everyOutcomeForbidsRetryAndRerun: Bool
    public let everyOutcomeRequiresAppendOnlyObservationAndRetirement: Bool
    public let everyOutcomeKeepsStage7False: Bool
}

public struct PrimeNativeDecoderBSpecificNative300MAuthorityCeilingV1:
    Codable, Equatable, Sendable
{
    public let authorityOnlyNoWitnessEvidence: Bool
    public let stage5MechanicsSuccessEstablished: Bool
    public let stage5ResultEstablished: Bool
    public let stage5AssayClearanceEstablished: Bool
    public let repeatedSameDeviceBPathDeterminismEstablished: Bool
    public let exactSameDeviceBPathGradientBytesEstablished: Bool
    public let historicalStage6ResourceClearanceRemainsEstablished: Bool
    public let historicalStage6ResourceClearanceAppliesToBPath: Bool
    public let bSpecificNative300MResourceWitnessRequiresSeparateAuthority:
        Bool
    public let bSpecificNative300MResourceWitnessMechanicsAuthorizedAfterGreenClosure:
        Bool
    public let oneExactMainBSpecificNative300MResourceWitnessAuthorized: Bool
    public let oneNative300MAllocationAuthorizedForWitness: Bool
    public let oneNative300MTrainingStepAuthorizedForWitness: Bool
    public let boundedResourceMeasurementAuthorized: Bool
    public let bSpecificNative300MResourceWitnessExecuted: Bool
    public let bSpecificNative300MResourceWitnessEstablished: Bool
    public let bSpecificNative300MResourceClearanceEstablished: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
    public let ordinaryJobFitEstablished: Bool
    public let broadNative300MTrainingAuthorized: Bool
    public let defaultGatherDeterminismEstablished: Bool
    public let arbitraryTokenDeterminismEstablished: Bool
    public let crossDeviceDeterminismEstablished: Bool
    public let durableCheckpointIOAuthorized: Bool
    public let retainedArtifactAuthorized: Bool
    public let artifactUploadAuthorized: Bool
    public let generalTrainingResumeEstablished: Bool
    public let native300MTrajectoryTrainingResumeEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let stage7RequiresBSpecificNative300MResourceWitness: Bool
    public let stage7RequiresSeparateAuthorityAfterWitness: Bool
    public let stage7AuthorityEstablished: Bool
    public let stage7Authorized: Bool
    public let downstreamTrialAuthorized: Bool
    public let canaryAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Append-only, execution-pure compatibility revalidation authority. The
/// original Stage-6 resource PASS remains valid historical evidence for the
/// maintained gather path, but it predates candidate B and cannot clear B.
/// This authority permits one separately implemented B-specific Native-300M
/// resource witness after a green exact-main closure. It never authorizes
/// Stage 7.
public struct PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityV1:
    Codable, Equatable, Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let roadmapBoundaryID: String
    public let repository: PrimeNativeDecoderBSpecificNative300MRepositoryV1
    public let stage5Pass: PrimeNativeDecoderBSpecificNative300MStage5PassV1
    public let historicalStage6:
        PrimeNativeDecoderBSpecificNative300MHistoricalStage6V1
    public let bPath: PrimeNativeDecoderBSpecificNative300MPathV1
    public let configuration:
        PrimeNativeDecoderBSpecificNative300MConfigurationV1
    public let resourceEnvelope:
        PrimeNativeDecoderBSpecificNative300MResourceEnvelopeV1
    public let inheritedResourceContract:
        PrimeNativeDecoderBSpecificNative300MInheritedResourceContractV1
    public let futureExecution:
        PrimeNativeDecoderBSpecificNative300MExecutionPlanV1
    public let leaseReceiptIntegrity:
        PrimeNativeDecoderBSpecificNative300MLeaseReceiptIntegrityV1
    public let authorityClosureScope:
        PrimeNativeDecoderBSpecificNative300MScopeV1
    public let successorScope: PrimeNativeDecoderBSpecificNative300MScopeV1
    public let successorManifest:
        PrimeNativeDecoderBSpecificNative300MSuccessorManifestV1
    public let suite: PrimeNativeDecoderBSpecificNative300MSuiteV1
    public let transitions:
        PrimeNativeDecoderBSpecificNative300MOutcomeTransitionsV1
    public let ceiling:
        PrimeNativeDecoderBSpecificNative300MAuthorityCeilingV1
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalSHA256 =
        "15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba"

    public static let frozenV1: Self = {
        func source(
            _ path: String,
            _ mode: String,
            _ blob: String,
            _ bytes: Int,
            _ lines: Int,
            _ sha256: String,
            _ role: String
        ) -> PrimeNativeDecoderBSpecificNative300MSourceIdentityV1 {
            .init(
                path: path,
                gitMode: mode,
                gitBlob: blob,
                byteCount: bytes,
                lfByteCount: lines,
                sha256: sha256,
                role: role)
        }

        let authoritySource =
            "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthority.swift"
        let authorityTest =
            "Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityTests.swift"
        let launcher =
            ".github/scripts/prime-ci-native-decoder-b-specific-native300m-resource-witness.sh"
        let trainingProbe =
            "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift"
        let executableMain =
            "Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MResourceWitness/main.swift"
        let contractTest =
            "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests.swift"
        let authorityPaths = [
            ".github/scripts/prime-ci-active-root-quarantine.sh",
            ".github/workflows/prime-active-root-quarantine.yml",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            authoritySource,
            authorityTest,
        ]
        let successorPaths = [
            ".github/scripts/prime-ci-active-root-quarantine.sh",
            launcher,
            ".github/workflows/prime-active-root-quarantine.yml",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            trainingProbe,
            "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
            executableMain,
            contractTest,
        ]
        let tokens = [1] + (0 ..< 127).map { index in
            2 + ((index * 73 + 44) % 510)
        }

        return Self(
            schemaVersion: 1,
            authorityID:
                "prime_native_decoder_b_specific_native300m_resource_witness_authority_v1",
            authorityKind:
                "append_only_dependency_free_nonexecuting_current_b_path_native300m_resource_compatibility_revalidation_authority",
            roadmapBoundaryID:
                "b_specific_native300m_resource_witness_v1",
            repository: .init(
                repository: "Ergentics/ergentics-prime",
                ref: "refs/heads/main",
                authorityBaseRevision:
                    "7be3d77ad3ed3ae3ec7ec10d0aed6231c1083be4",
                authorityBaseTree:
                    "428097e2bf01276b91c9f4d7023a3c6ad496c4ca",
                authorityBaseOrderedParents: [
                    "68422b34425fce761ce8d4afcbd7b0edbc1cf648",
                    "5ec7b58ed9186e93268b1dad0dcac889a03cb3ff",
                ],
                retirementPullRequestNumber: 111,
                retirementReviewedHeadRevision:
                    "5ec7b58ed9186e93268b1dad0dcac889a03cb3ff",
                retirementReviewedHeadTree:
                    "428097e2bf01276b91c9f4d7023a3c6ad496c4ca",
                retirementMergedAt: "2026-08-14T21:22:48Z",
                retirementWorkflowRunID: 31_842_165_031,
                retirementWorkflowRunNumber: 119,
                retirementWorkflowRunAttempt: 1,
                retirementCheckSuiteID: 86_388_590_215,
                retirementActiveRootJobID: 94_901_180_243,
                retirementActiveRootRunnerImage: "macos-15",
                retirementActiveRootJobConclusion: "success",
                retirementReviewedMainJobID: 94_901_897_572,
                retirementReviewedMainRunnerImage: "macos-26",
                retirementReviewedMainJobConclusion: "success",
                retirementPreviousAttemptURLWasNull: true,
                retirementExactHeadPushRunCount: 1,
                retirementRerunCount: 0,
                retirementArtifactCount: 0,
                retirementRootTestCount: 59,
                retirementIsolatedGroupTestCounts: [1, 1, 2, 2],
                retirementIsolatedTestCount: 6,
                retirementFocusedWholeTestCount: 65,
                retirementMetalTestCount: 44,
                retirementMaintainedRuntimeTestCount: 1,
                retirementTokenizerTestCount: 1,
                retirementTotalTestCount: 111,
                retirementLiveOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                retirementOriginalStage5LauncherInvocationCount: 0,
                retirementReplacementStage5LauncherInvocationCount: 0,
                retirementHistoricalStage6LauncherInvocationCount: 0,
                retirementMaintainedRuntimeReceiptCount: 1,
                retirementTokenizerReceiptCount: 1,
                retirementOriginalStage5ReceiptCount: 0,
                retirementReplacementStage5ReceiptCount: 0,
                retirementHistoricalStage6ReceiptCount: 0,
                retirementBResourceWitnessReceiptCount: 0,
                retirementExactChangedPaths: [
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                    ".github/workflows/prime-active-root-quarantine.yml",
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservation.swift",
                    "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationTests.swift",
                ],
                retirementChangedSourceIdentities: [
                    source(
                        ".github/scripts/prime-ci-active-root-quarantine.sh",
                        "100755",
                        "3674144056ba86da2314d70bf47f66a5fa340538",
                        736_055, 12_754,
                        "f39579d9de1680b370a247b9e2571accf36dc377ad70a1247f008bc14526cf8a",
                        "stage5_pass_retirement_active_root_gate"),
                    source(
                        ".github/workflows/prime-active-root-quarantine.yml",
                        "100644",
                        "cfcaf7014d2a20b95759d7a1cee3df7599b028ce",
                        91_822, 594,
                        "a3ccc7ace3b0794ac1dcf89127c2c4d69f8dc07ba6199ecacf8650c5fdde9284",
                        "stage5_pass_retirement_workflow"),
                    source(
                        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                        "100644",
                        "5b0cc44a0edcf2eb439adb88cf979b2326efcf75",
                        546, 13,
                        "67d58a726cbb1e603e4db8d539e0f180d81d90fb9db94e2742500d1b2194905c",
                        "stage5_pass_retirement_embedded_provenance"),
                    source(
                        "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservation.swift",
                        "100644",
                        "daca1d73cdb2d71fc2298aa30b39da757e881923",
                        70_671, 1_205,
                        "52aa88169affbfa80f08ea3a1425d0b5273154f187a38fc286e02abd7f37943c",
                        "stage5_pass_observation"),
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationTests.swift",
                        "100644",
                        "c1a925db6906286561ea7ca72b7be9a5209a6e93",
                        38_745, 913,
                        "ae74b493749675fc6d81224d83bd01fae9371aa3c9f16196ec6342aca5eaae02",
                        "stage5_pass_observation_test"),
                ],
                preservedIndexSHA256:
                    "8742966c9f6322aa353facd846f4bcfab546cff6ab7997fac86b76249c56dcbb",
                embeddedSourceIdentitySHA256:
                    "9dd52e311c9332e9f48f8e05e24c0da32397fac33de8766c6b02bddb5e7b6e35",
                authorityClosureExactChangedPaths: authorityPaths,
                authoritySourceAndTestAreOnlyNewPaths: true,
                immutableBaseSourceBindings: [
                    source(
                        ".github/scripts/prime-ci-native-decoder-stage6-native300m-resource-only-one-step.sh",
                        "100755",
                        "9e8f7ca0c6fa6c02bc4b0f40cc2185d2e6d46d13",
                        108_576, 2_016,
                        "8801c46f54eaee475f3a2fdb697b2184af4233b9cdf7a66ddd9867d14eb4f349",
                        "historical_stage6_launcher_template_only"),
                    source(
                        "Sources/PrimeCore/PrimeMetalDeviceLease.swift",
                        "100644",
                        "da3daa54802b67dc2c8c04a89b388e9927dd8726",
                        16_985, 534,
                        "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657",
                        "nonblocking_exclusive_device_lease"),
                    source(
                        "Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthority.swift",
                        "100644",
                        "d65361e24a5eb3608ca774066a76ecf608c76d53",
                        210_057, 3_571,
                        "a03507b0cbd532949178fa5515d0b0d0cabfe786b0d79619d89453ea23b855c6",
                        "historical_stage6_authority"),
                    source(
                        "Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservation.swift",
                        "100644",
                        "f2b688b5c073a71d4179a75f0ced9651ac696025",
                        69_114, 1_117,
                        "e3927b4ce209662466bd014b6112da733f0fe816006b7722792f9c61f6aad3ad",
                        "historical_stage6_pass_observation"),
                    source(
                        "Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift",
                        "100644",
                        "68a711c708eecff01b9d63795cdcb03c127d64b8",
                        23_783, 526,
                        "88451317772e9ec05a1bb59362c4d2c3e953cb9284a3b9db65ee1892222f88c9",
                        "current_b_decoder_identity_observation"),
                    source(
                        "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift",
                        "100644",
                        "ded305476edfc832ae4e910b1985da77c7a10cd0",
                        144_935, 2_728,
                        "634eabe81f63a570cfe2f565d95befbd8c77ea98ba7864a212f45511c7f8b5fc",
                        "stage5_replacement_authority"),
                    source(
                        "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservation.swift",
                        "100644",
                        "daca1d73cdb2d71fc2298aa30b39da757e881923",
                        70_671, 1_205,
                        "52aa88169affbfa80f08ea3a1425d0b5273154f187a38fc286e02abd7f37943c",
                        "stage5_replacement_pass_observation"),
                    source(
                        "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                        "100644",
                        "de6cff4472de55a8fafe2962c3be4ca37c972caf",
                        43_339, 1_193,
                        "ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc",
                        "current_b_decoder_source"),
                    source(
                        "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift",
                        "100644",
                        "4c13d3098f07eb748980a351823dcf4fc36da337",
                        188_872, 4_334,
                        "b29384112ed178b6d3bce6fb8dd138c861521cbddd968d418208baa669b5caf0",
                        "historical_stage6_probe_template_only"),
                    source(
                        "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                        "100644",
                        "4566477e14b4b6cfa06286f384f07f8d452e8724",
                        97_449, 2_444,
                        "cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb",
                        "current_b_training_selector_source"),
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityTests.swift",
                        "100644",
                        "a6ff11d4d8beb2aa39ca6e04ac32defb94220033",
                        36_733, 796,
                        "a501188363b11b61731099066d61594a0dc3d27fbe5c5c4eec3d0fbcea0de065",
                        "historical_stage6_authority_test"),
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationTests.swift",
                        "100644",
                        "075a07a0ff9577a9b9c6f9824d2c632db2fe78bf",
                        28_383, 723,
                        "79bed57c8d2461a56e9bec335ba6869d0981fc5daa32f85845f4835efc8736d5",
                        "historical_stage6_pass_observation_test"),
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift",
                        "100644",
                        "f5b8e7787616d650b0a990227e2744b84d8b5e4c",
                        23_283, 570,
                        "b0bdb47454adc6f9d69ec6e47f1cbc2df7c3c5aa8ccb1ac9d68a4ab593d605aa",
                        "current_b_decoder_identity_observation_test"),
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests.swift",
                        "100644",
                        "e7e240f6bb6e037f0b41f28d925ce0fcd38c42a7",
                        49_796, 1_017,
                        "71506cbc21fb8d03886bdc95500e6249f5d61a59f84569dfda95875289435e08",
                        "stage5_replacement_authority_test"),
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationTests.swift",
                        "100644",
                        "c1a925db6906286561ea7ca72b7be9a5209a6e93",
                        38_745, 913,
                        "ae74b493749675fc6d81224d83bd01fae9371aa3c9f16196ec6342aca5eaae02",
                        "stage5_replacement_pass_observation_test"),
                    source(
                        "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests.swift",
                        "100644",
                        "75deca6b2d1d640d2c6d3b4eb3f6dfbb52101ec7",
                        3_532, 90,
                        "d7ad08a56dab0936cd9aac434de2a8828a2302df1a588b6ceca6de5d46a8981a",
                        "historical_stage6_pure_contract_template_only"),
                ]),
            stage5Pass: .init(
                authorityID:
                    "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_authority_v1",
                authorityCanonicalSHA256:
                    "e0b1fadf4075765078ba3cf29e7cce85be930791651020d45cba1b5b91466252",
                currentDecoderIdentityObservationID:
                    "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_current_decoder_identity_observation_v1",
                currentDecoderIdentityCanonicalSHA256:
                    "a8ecffbf0a24cb6970158982811107e216600571976c87f5e7e78f699b8d72b3",
                passObservationID:
                    "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_observation_v1",
                passObservationCanonicalSHA256:
                    "7e17cfdc59f63a775aa4ec5b797328e80c0ab75ef65b2b3ddd7f4bf8deb48ef9",
                mechanicsRevision:
                    "68422b34425fce761ce8d4afcbd7b0edbc1cf648",
                mechanicsTree:
                    "658f7f2aa6a023efb37520bd7596c37b474ecda1",
                workflowRunID: 31_834_513_845,
                workflowRunNumber: 117,
                workflowRunAttempt: 1,
                checkSuiteID: 86_367_936_511,
                activeRootJobID: 94_877_692_182,
                reviewedMainJobID: 94_878_305_625,
                runConclusion: "failure",
                reviewedMainJobConclusion: "failure",
                launcherInvocationCount: 1,
                directXCTestInvocationCount: 1,
                testPassCount: 1,
                testFailureCount: 0,
                testSkipCount: 0,
                receiptID:
                    "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_receipt_v1",
                receiptPrefix:
                    "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1=",
                receiptPrefixByteCount: 51,
                receiptRawJSONByteCount: 13_036,
                receiptRawJSONSHA256:
                    "ce939ca5f6e9e5d37cf61b412dcb02d811495909466903c8575169265a330fb0",
                receiptPrefixedByteCount: 13_087,
                receiptPrefixedSHA256:
                    "2154abe45f7e0c65e8196f8ebc4aabab0363caf18ce93d10c72f822ac8ade1f3",
                receiptStatus: "PASS_CLEARANCE",
                receiptOccurrenceCount: 1,
                oneShotConsumed: true,
                oneShotExhausted: true,
                armATrialCount: 3,
                armACompletedDiagnosticPairCount: 3,
                armAMeasuredMismatch: false,
                armBTrialCount: 3,
                armBBranchCount: 9,
                armBComparisonDomainCount: 7,
                armBAllExactComparisonsPassed: true,
                armBAllForwardEquivalenceChecksPassed: true,
                armBTrainingStepCount: 15,
                armBEvaluateCount: 18,
                armBSnapshotCount: 3,
                armBRestoreCount: 3,
                armBForwardEquivalenceCheckCount: 9,
                armBDenseWholeLogitsCallCount: 57,
                armBDenseEmbeddingConstructionCount: 66,
                armBTokenBoundsValidationCount: 66,
                armBTokenBoundsCheckedEvalCount: 66,
                armBTokenBoundsGPUSynchronizeCount: 66,
                armBTokenBoundsHostBoolItemCount: 66,
                stage5MechanicsSuccessEstablished: true,
                stage5ResultEstablished: true,
                stage5AssayClearanceEstablished: true,
                repeatedSameDeviceBPathDeterminismEstablished: true,
                exactSameDeviceBPathGradientBytesEstablished: true,
                defaultGatherDeterminismEstablished: false,
                outerLauncherFailureMessage:
                    "replacement lease parent identity changed",
                outerLauncherExitCode: 2,
                outerLeaseParentGuardConjuncts: [
                    "lease_root_is_directory",
                    "lease_root_is_not_symlink",
                    "lease_root_physical_path_equals_expected",
                    "lease_root_owner_equals_effective_uid",
                    "lease_root_mode_equals_0700",
                    "lease_root_link_count_equals_2",
                ],
                outerLeaseParentGuardFailed: true,
                failedGuardConjunctIdentified: false,
                actualLeaseParentMetadataObserved: false,
                localAPFSLinkCountReproductionBoundAsCause: false,
                receiptEstablishedBeforeOuterFailure: true,
                launcherPostReceiptCompletionEstablished: false,
                outerWorkflowSuccessEstablished: false,
                replacementLauncherRetired: true,
                additionalExecutionOrRerunAuthorized: false),
            historicalStage6: .init(
                authorityID:
                    "prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1",
                authorityCanonicalSHA256:
                    "2627ffc0dd6499a9a1b20fa217b7f1c4a9723a6fd6332ef24a9ee251b5b0bf56",
                observationID:
                    "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_execution_observation_v1",
                observationCanonicalSHA256:
                    "6f18f128b30565cba0e53ad4f834882d050851199639299d2aa9ecf2e0cb51bf",
                mechanicsRevision:
                    "437acb46a5af63f6c604e5f5c50f3b63eaa296f2",
                mechanicsTree:
                    "f87272ed850cd2ac1898bd6c5d4cbefd2c664bb0",
                workflowRunID: 31_784_730_175,
                workflowRunNumber: 111,
                workflowRunAttempt: 1,
                checkSuiteID: 86_228_325_084,
                receiptRawJSONByteCount: 17_435,
                receiptRawJSONSHA256:
                    "104f3579f2caf19f27cbbe694f8a854cc8927d9188af055075c11b1fe1c94c55",
                receiptPrefixedByteCount: 17_505,
                receiptPrefixedSHA256:
                    "454b623ce9a95131de9b2f03f5a1e4100ef52023bc0ccaf644567d6d4eda2185",
                trainingLogitsAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCache",
                trainingInputPathID: "maintained_gather_v1",
                uniqueParameterCount: 271_107_072,
                parameterPathCount: 218,
                observedPhysicalMemoryCapacityBytes: 7_516_192_768,
                configuredMemoryLimitBytes: 5_010_800_640,
                observedMLXPeakBytes: 4_781_317_844,
                workerElapsedNanoseconds: 33_519_059_708,
                resourceProbeExecuted: true,
                resourceEnvelopeEstablished: true,
                resourceClearanceEstablished: true,
                runnerMemoryCapacityEstablished: true,
                ordinaryJobFitEstablished: false,
                oneShotConsumed: true,
                retirementRevision:
                    "54635d6b58e4f9c7ddedb30a3c22fffb17d8e174",
                retirementTree:
                    "afd51da78370aee8851341fe46b2533450944b2f",
                retirementPullRequestNumber: 108,
                retirementWorkflowRunID: 31_793_069_525,
                retirementWorkflowRunNumber: 113,
                retirementObserved: true,
                remainsHistoricalEvidence: true,
                appliesToCurrentBPath: false,
                mayBeUsedAsBPeakPrediction: false,
                mayBeUsedAsBResourceClearance: false),
            bPath: .init(
                algorithmID:
                    "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1",
                selectorCase: "denseOneHotMatmulV1",
                selectorRawValue:
                    "flattened_dense_one_hot_matmul_input_embedding_v1",
                trainingLogitsAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
                maintainedGatherTrainingLogitsAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCache",
                inputEmbeddingForwardPairAPI:
                    "PrimeNativeGQADecoder.trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1",
                decoderSource: source(
                    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                    "100644",
                    "de6cff4472de55a8fafe2962c3be4ca37c972caf",
                    43_339, 1_193,
                    "ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc",
                    "current_b_decoder_source"),
                trainingSource: source(
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                    "100644",
                    "4566477e14b4b6cfa06286f384f07f8d452e8724",
                    97_449, 2_444,
                    "cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb",
                    "current_b_training_selector_source"),
                packageOnlySurfaceRequired: true,
                publicDecoderAPIAdded: false,
                currentDecoderIdentityIsSoleRetainedLiveIdentity: true,
                defaultGatherPathRemainsByteIdentical: true,
                densePathIsExplicitOptIn: true,
                decoderLayersFinalNormAndOutputProjectionSharedWithMaintainedPath:
                    true,
                tokenBoundsCombinedPredicate:
                    "all((tokens>=Int32(0))&&(tokens<Int32(exactly:vocabularySize)))",
                tokenBoundsCheckedInt32VocabularyConversionRequired: true,
                tokenBoundsCheckedEvalCountPerDenseConstruction: 1,
                tokenBoundsGPUSynchronizeCountPerDenseConstruction: 1,
                tokenBoundsHostBoolItemCountPerDenseConstruction: 1,
                denseMatmulCountPerDenseConstruction: 1),
            configuration: .init(
                compatibilitySchemaID:
                    "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
                modelConfigurationFactory:
                    "native300MInventory(vocabularySize:)",
                modelFactory: "make(configuration:seed:)",
                vocabularySize: 512,
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
                parameterDType: "float32",
                logicalParameterByteCount: 1_084_428_288,
                initializationSeed: 44,
                batchSize: 1,
                sequenceLength: 128,
                validTokenCount: 128,
                selectedTargetCount: 127,
                tokenAlgorithmID:
                    "prime_stage6_seed44_batch1x128_mod510_stride73_v1",
                batchTokenIDs: [tokens],
                batchTokenIDsSHA256:
                    "220a52583cdbb82311863f4643679734b2ffc69725af021f066a84fc7520a172",
                batchTokenIDsSHA256PreimageRule:
                    "sha256_of_compact_json_utf8_rank_two_batch_token_ids",
                completionMask:
                    [[false] + Array(repeating: true, count: 127)],
                tokenIDStorageDType: "int32",
                completionMaskStorageDType: "bool",
                flattenedTokenColumnShape: [128, 1],
                vocabularyRowShape: [1, 512],
                denseOneHotShape: [128, 512],
                denseOneHotDType: "float32",
                denseOneHotElementCount: 65_536,
                denseOneHotLogicalByteCount: 262_144,
                flattenedDenseEmbeddingShape: [128, 1_024],
                flattenedDenseEmbeddingDType: "float32",
                flattenedDenseEmbeddingElementCount: 131_072,
                flattenedDenseEmbeddingLogicalByteCount: 524_288,
                restoredDenseEmbeddingShape: [1, 128, 1_024],
                trainingLogitsExpectedShape: [1, 128, 512],
                trainingLogitsDType: "float32",
                trainingLogitsUsesCausalAttentionMask: true,
                shiftedLogitsSlice: "logits[0...,0..<127,0...]",
                shiftedTargetsSlice: "token_ids[0...,1..<128]",
                shiftedCompletionMaskSlice:
                    "completion_mask[0...,1..<128]",
                shiftedLogitsExpectedShape: [1, 127, 512],
                shiftedTargetsExpectedShape: [1, 127],
                shiftedCompletionMaskExpectedShape: [1, 127],
                shiftedCompletionMaskAllTrue: true,
                lossGraphAlgorithmID:
                    "prime_stage6_causal_masked_mean_cross_entropy_f32_v1",
                crossEntropyAPI:
                    "MLXNN.crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)",
                crossEntropyWeights: "nil",
                crossEntropyAxis: -1,
                crossEntropyLabelSmoothingFloat32BitPattern: 0,
                crossEntropyReduction: "none",
                valueAndGradAPI: "MLXNN.valueAndGrad(model:_:)",
                valueAndGradClosureArguments: [
                    "model", "token_ids", "completion_mask",
                ],
                valueAndGradClosureReturnsOnlyScalarLoss: true,
                optimizerQualifiedType: "MLXOptimizers.AdamW",
                optimizerStateInspectionAPI:
                    "MLXOptimizers.AdamW.innerState()",
                optimizerStateExpectedArrayCount: 436,
                optimizerStateExpectedPairCount: 218,
                learningRateFloat32BitPattern: 953_267_991,
                beta1Float32BitPattern: 1_063_675_494,
                beta2Float32BitPattern: 1_065_336_439,
                epsilonFloat32BitPattern: 841_731_191,
                weightDecayFloat32BitPattern: 1_008_981_770,
                maximumGradientNormFloat32BitPattern: 1_065_353_216,
                gradientNormEpsilonFloat32BitPattern: 897_988_541,
                rawGradientNormAlgorithmID:
                    "prime_stage6_global_f32_l2_norm_utf8_catalog_v1",
                gradientClipAlgorithmID:
                    "prime_stage6_global_norm_clip_f32_v1",
                parameterFingerprintAlgorithmID:
                    "prime_stage6_parameter_catalog_sample_f32be_sha256_v1",
                parameterFingerprintExpectedSampleCount: 654,
                gradientAccumulationCount: 1,
                optimizerStepCount: 1,
                paddingAuthorized: false,
                kvCacheAuthorized: false,
                evaluationForwardAuthorized: false,
                generationAuthorized: false,
                checkpointAuthorized: false,
                configurationIsResourceWitnessOnlyNotTrainingPolicy: true),
            resourceEnvelope: .init(
                weightsLogicalByteCount: 1_084_428_288,
                gradientLogicalByteCount: 1_084_428_288,
                optimizerMomentTensorCount: 436,
                optimizerMomentLogicalByteCount: 2_168_856_576,
                minimumCommittedTensorStateByteCount: 3_253_284_864,
                minimumStatePlusGradientByteCount: 4_337_713_152,
                threeTimesCommittedStateDiskComparatorByteCount:
                    9_759_854_592,
                minimumConfiguredMLXMemoryLimitByteCount: 4_337_713_152,
                configuredMLXMemoryLimitMaximumByteCount: 17_179_869_184,
                configuredMLXMemoryLimitFormula:
                    "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)",
                configuredMLXCacheLimitByteCount: 0,
                minimumAvailableFilesystemByteCount: 12_884_901_888,
                workerActiveTimeoutSeconds: 1_200,
                supervisorEndToEndTimeoutSeconds: 1_500,
                terminationGraceSeconds: 10,
                requiredPhaseNames: [
                    "preflight",
                    "post_model_materialization",
                    "post_b_forward_backward",
                    "post_norm_clip",
                    "post_adam_update_full_evaluation",
                    "post_lexical_deallocation_and_clear_cache",
                ],
                requiredMetricKeys: [
                    "cumulative_worker_probe_elapsed_nanoseconds",
                    "physical_memory_capacity_bytes",
                    "task_resident_bytes",
                    "task_physical_footprint_bytes",
                    "getrusage_max_rss_bytes",
                    "metal_current_allocated_bytes",
                    "mlx_active_bytes",
                    "mlx_cache_bytes",
                    "mlx_peak_bytes",
                    "filesystem_capacity_bytes",
                    "filesystem_available_bytes",
                ],
                historicalStage6PeakIsBaselineOnly: true,
                analyticBIncrementalBytesArePeakEvidence: false,
                analyticBIncrementalBytesAreClearanceEvidence: false,
                containerHeadersAndManifestsIncludedInMinimum: false,
                duplicateGraphsAndTemporaryBuffersIncludedInMinimum: false,
                configuredMLXLimitIsProcessRSSLimit: false,
                filesystemObservationIsCheckpointDiskSufficiencyClaim: false,
                passRequiresAllPhaseMetricsObserved: true,
                passRequiresMeasuredPeakBelowConfiguredLimit: true,
                passEstablishesOnlyExactRunResourceWitness: true),
            inheritedResourceContract: .init(
                historicalAuthorityID:
                    "prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1",
                historicalAuthorityCanonicalSHA256:
                    "2627ffc0dd6499a9a1b20fa217b7f1c4a9723a6fd6332ef24a9ee251b5b0bf56",
                preservationRule:
                    "preserve_historical_stage6_configuration_environment_phase_live_set_metric_limit_fingerprint_optimizer_timeout_and_resource_abstain_semantics_except_exact_authorized_deltas;no_unlisted_semantic_delta",
                exactAuthorizedDeltas: [
                    "new_ids_paths_exact_main_provenance_and_b_specific_post_forward_backward_phase_name",
                    "maintained_gather_training_logits_replaced_by_sole_direct_b_training_logits_api",
                    "b_flattened_dense_shapes_and_one_ordered_token_bounds_checked_eval_sync_host_bool_barrier_added",
                    "supervisor_owns_lease_and_distinct_exec_verifier_proves_persistent_release_disposition",
                    "private_candidate_outer_final_publication_and_abstain_integrity_added",
                ],
                mlxEnableTF32: "0",
                exactMLXRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                metalDeviceIndex: 0,
                exactMetalDeviceCount: 1,
                singletonDeviceEnumerationRequired: true,
                indexZeroMustMatchDefaultDevice: true,
                mlxGraphCompileMode: "eager_uncompiled_no_compile_transform",
                mlxCompileTransformInvocationCount: 0,
                configuredMLXMemoryLimitSetter: "MLX.Memory.memoryLimit",
                configuredMLXMemoryLimitSetCount: 1,
                configuredMLXMemoryLimitReadbackRequired: true,
                configuredMLXCacheLimitSetter: "MLX.Memory.cacheLimit",
                configuredMLXCacheLimitSetCount: 1,
                configuredMLXCacheLimitReadbackRequired: true,
                mlxPeakMemoryResetAPI: "MLX.Memory.peakMemory = 0",
                mlxPeakMemoryResetCount: 1,
                filesystemObservationUsesStatFS: true,
                filesystemObservationRequiresStableOrderedFSID: true,
                phaseAndLiveSetRulesInheritedWithoutChange: true),
            futureExecution: .init(
                swiftPMBuildConfiguration: "release",
                buildCount: 1,
                focusedPureContractXCTestCount: 1,
                launcherPureContractXCTestCount: 1,
                pureContractXCTestStartCount: 2,
                launcherInvocationCount: 1,
                directExecutableProbeCount: 1,
                successorAggregateInvocationCount: 3,
                supervisorProcessCount: 1,
                maximumWorkerProcessCount: 1,
                workerSpawnAttemptCount: 1,
                successorAggregateInvocationTopology: [
                    "focused_pure_contract_xctest_start",
                    "launcher_pure_contract_xctest_start",
                    "direct_executable_probe",
                ],
                modelAllocationCount: 1,
                modelMaterializationCount: 1,
                valueAndGradCount: 1,
                directPackageBTrainingLogitsAPICallCount: 1,
                maintainedGatherTrainingLogitsCount: 0,
                tinyTrainingSelectorInvocationCount: 0,
                inputEmbeddingForwardPairDiagnosticInvocationCount: 0,
                denseEmbeddingConstructionCount: 1,
                tokenBoundsValidationCount: 1,
                tokenBoundsCheckedEvalCount: 1,
                tokenBoundsGPUSynchronizeCount: 1,
                tokenBoundsHostBoolItemCount: 1,
                crossEntropyCount: 1,
                forwardLossCount: 1,
                backwardCount: 1,
                rawGradientNormCount: 1,
                gradientClipCount: 1,
                optimizerStepCount: 1,
                adamWUpdateCount: 1,
                fullGraphEvaluationCount: 1,
                checkedEvaluationBarrierCount: 6,
                gpuSynchronizationBarrierCount: 6,
                orderedCheckedEvaluationAndSynchronizationBarriers: [
                    "model_materialization_all_model_parameters_before_fingerprint_samples",
                    "sole_b_logits_call_token_bounds_checked_eval_default_gpu_sync_then_host_bool_item",
                    "forward_backward_loss_and_all_gradients",
                    "pre_clip_raw_gradient_norm_before_host_scalar_read",
                    "post_norm_clip_all_clipped_gradients",
                    "post_adam_model_436_moments_and_after_fingerprint_views",
                ],
                memoryClearCacheCount: 1,
                postflightDeviceReenumerationCount: 1,
                kvCacheAllocationCount: 0,
                evaluationForwardPassCount: 0,
                checkpointReadCount: 0,
                checkpointWriteCount: 0,
                artifactUploadCount: 0,
                qualityMetricComputationCount: 0,
                generatedTokenCount: 0,
                oneExactMainOpportunityAfterGreenAuthorityClosure: true,
                retryAuthorized: false,
                rerunAuthorized: false,
                replacementRunAuthorized: false,
                resourceOperationCountsArePassPathExact: true,
                abstainOperationCountsAreAttemptedPrefixCounts: true),
            leaseReceiptIntegrity: .init(
                leaseType: "PrimeMetalDeviceLease",
                leaseAcquisitionMode: "exclusive_nonblocking",
                preflightParentRequiredTupleFields: [
                    "physical_path", "file_type", "device_id", "inode",
                    "uid", "gid", "mode", "security_flags",
                    "acl_entry_count", "allowed_extended_attribute_names",
                ],
                descriptorDerivedIdentityFields: [
                    "file_type", "device_id", "inode", "uid", "gid",
                    "mode", "security_flags", "acl_entry_count",
                    "observed_extended_attribute_names",
                ],
                parentDescriptorOpenFlags: [
                    "O_RDONLY", "O_DIRECTORY", "O_NOFOLLOW", "O_CLOEXEC",
                ],
                leaseFileDescriptorOpenFlags: [
                    "O_RDWR", "O_CREAT", "O_NOFOLLOW", "O_CLOEXEC",
                ],
                descriptorNameRebindRequired: true,
                descriptorNameRebindMustMatchDeviceAndInode: true,
                identityEvidenceIsDescriptorDerivedInSupervisorAndVerifier:
                    true,
                preflightParentMustBeEmptyDirectory: true,
                preflightParentMustBeNonSymlink: true,
                preflightParentPhysicalPathMustEqualExpectedPath: true,
                parentRequiredFileType: "directory",
                parentRequiredOwnerMatchesEffectiveUID: true,
                parentGroupPolicy:
                    "preflight_observed_gid_must_remain_exactly_unchanged",
                parentRequiredMode: "0700",
                parentSecurityFlagsRequiredValue: 0,
                parentACLEntryCountRequired: 0,
                parentAllowedExtendedAttributeNames: [
                    "com.apple.provenance",
                ],
                parentObservedExtendedAttributeNamesMustBeAllowedSubset: true,
                parentLinkCountObserved: true,
                parentLinkCountMustBePositive: false,
                parentLinkCountUsedAsStableIdentityAfterChildCreation: false,
                postCandidateParentFieldsRequiringExactPreflightEquality: [
                    "physical_path", "file_type", "device_id", "inode",
                    "uid", "gid", "mode", "security_flags",
                    "acl_entry_count",
                ],
                postCandidateParentIdentityGuardIsOpaqueAggregate: false,
                postCandidateParentMismatchIdentifiesExactField: true,
                exactOneChildInventoryRequired: true,
                leaseInventoryComparisonRule:
                    "unordered_exact_basename_set_equals_{device-0.lock}",
                exactChildBasename: "device-0.lock",
                leaseFileMustBeRegularNonSymlink: true,
                leaseFileMustMatchParentDeviceID: true,
                leaseFileRequiredOwnerMatchesEffectiveUID: true,
                leaseFileRequiredGroupMatchesEffectiveGID: true,
                leaseFileRequiredMode: "0600",
                leaseFileRequiredLinkCount: 1,
                leaseFileRequiredByteCount: 0,
                leaseFileSecurityFlagsRequiredValue: 0,
                leaseFileACLEntryCountRequired: 0,
                leaseFileAllowedExtendedAttributeNames: [
                    "com.apple.provenance",
                ],
                leaseFileObservedExtendedAttributeNamesMustBeAllowedSubset:
                    true,
                resourceWorkerExecProcessCount: 1,
                releaseVerifierExecProcessCount: 1,
                operationalProbeRoleProcessInvocationCount: 3,
                resourceWorkerSpawnCount: 1,
                releaseVerifierSpawnCount: 1,
                primeLeaseAcquireAttemptCount: 2,
                primeLeaseAcquireSuccessCount: 2,
                primeLeaseReleaseCallCount: 2,
                individualFlockSyscallSuccessClaimCount: 0,
                individualCloseSyscallSuccessClaimCount: 0,
                supervisorIsSoleLeaseOwnerBeforeExplicitRelease: true,
                supervisorHoldsLeaseThroughCandidateAndDeviceMLXPostflight:
                    true,
                explicitSupervisorReleaseCount: 1,
                releaseVerifierExecChildCount: 1,
                verifierExecutesWhileSupervisorAliveAfterVoidRelease: true,
                releaseVerifierMustAcquireReleaseAndExitZero: true,
                releaseVerifierExitZeroObservationCount: 1,
                supervisorExitZeroObservationCount: 1,
                outerWaitsForSupervisorExitBeforePublication: true,
                verifierProcessExitProvidesKernelCloseBackstop: true,
                workerExecInheritsLeaseFileDescriptorCount: 0,
                verifierParentDeviceAndInodeMustEqualSupervisorPreRelease:
                    true,
                verifierLeaseFileDeviceAndInodeMustEqualSupervisorPreRelease:
                    true,
                outerFinalReboundIdentityMustMatchVerifier: true,
                launcherUnlinksLeaseFile: false,
                launcherRemovesLeaseParent: false,
                launcherCleanupUnlinkCount: 0,
                launcherCleanupRemoveFileCount: 0,
                launcherCleanupRemoveDirectoryCount: 0,
                persistentLeaseRootAndLeafAreIntentionalLeaseSemantics: true,
                persistentLeaseRootAndLeafAreRetainedArtifact: false,
                privateWorkingDirectoryPostflightRequired: true,
                repositoryPostflightRequired: true,
                metallibPostflightRequired: true,
                internalCandidatePrefix:
                    "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_INTERNAL_CANDIDATE_V1=",
                publicCanonicalReceiptPrefix:
                    "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_RECEIPT_V1=",
                internalCandidateMaximumCount: 1,
                workerPublicCanonicalReceiptCount: 0,
                supervisorPublicCanonicalReceiptCount: 0,
                launcherPublicCanonicalReceiptMaximumCount: 1,
                validTerminalClassificationPublicReceiptCount: 1,
                internalCandidateIsResultEvidence: false,
                publicPrefixCountsAreAllOutcomeCeilings: true,
                processLeaseAcquireAndReleaseCountsArePassPathExact: true,
                abstainProcessAndLeaseCountsAreAttemptedPrefixCounts: true,
                outerPathRebindThreatModel:
                    "non_hostile_same_uid_runner_temp_environment",
                outerPathRebindIsAuthoritativeAgainstHostileSameUIDMutation:
                    false,
                anyPublicReceiptRequiresTerminalClassificationClosure: true,
                anyPublicReceiptRequiresSupervisorTermination: true,
                passRequiresValidatedScientificCandidate: true,
                passRequiresLeaseReleaseVerifierAndPersistentIdentityProof:
                    true,
                passRequiresAllPostflights: true,
                passRequiresOuterIntegritySuccess: true,
                resourceAbstainMayBeSupervisorSynthesizedWithoutCandidate:
                    true,
                resourceAbstainMayCompleteWithoutReleaseVerifierOnlyWhenNoLeaseWasAcquired:
                    true,
                resourceAbstainAfterLeaseAcquisitionRequiresReleaseVerifier:
                    true,
                resourceAbstainRequiresApplicableLeaseDispositionProof: true,
                resourceAbstainRequiresAllApplicableOuterPostflights: true,
                resourceAbstainRequiresSafeOuterPublicationClosure: true,
                integrityAbstainRequiresSupervisorTermination: true,
                integrityAbstainRequiresTerminalClassificationClosure: true,
                integrityAbstainRequiresOuterIntegritySuccess: false,
                publicReceiptEmissionAndFlushAreFinalFallibleLauncherAction:
                    true,
                launcherExitTrapsClearedBeforePublicReceipt: true,
                finalPublicReceiptCommand:
                    "exec /usr/bin/printf '%s\\n' \"$public_line\"",
                noAuthoredActionAfterFinalPublicReceiptExec: true,
                launcherOKMarkerAfterPublicReceipt: false,
                publicReceiptEmissionFailureExitsNonzeroWithoutReceiptClaim:
                    true,
                candidateIntegrityOrPostflightFailureEmitsPassOrResourceAbstain:
                    false,
                candidateIntegrityOrPostflightFailureEstablishesClearance:
                    false,
                candidateIntegrityOrPostflightFailureConsumesOpportunity:
                    true,
                candidateIntegrityOrPostflightFailurePermitsRetry: false,
                candidateIntegrityOrPostflightFailureEmitsIntegrityAbstainWhenSafelyClassifiable:
                    true,
                integrityFailureReceiptStatus: "ABSTAIN_INTEGRITY",
                integrityFailureReceiptRequiresValidatedCandidate: true,
                integrityFailureReceiptPreservesCandidateScientificStatus:
                    true,
                integrityFailureReceiptRequiresFirstFailedGuard: true,
                integrityFailureReceiptRequiresErrnoWhenAvailable: true,
                integrityFailureReceiptRequiresActualMetadataAvailability:
                    true,
                integrityFailureReceiptActualMetadataMayBeNull: true,
                integrityFailureReceiptNullActualMetadataRequiresUnavailableReasonOrErrno:
                    true,
                integrityFailureReceiptRequiredBindings: [
                    "candidate_present", "candidate_scientific_status",
                    "candidate_sha256", "first_failed_guard_id",
                    "errno_availability", "errno",
                    "actual_metadata_availability", "actual_metadata",
                    "actual_metadata_unavailable_reason",
                    "one_shot_consumed",
                    "b_specific_native300m_resource_clearance",
                ],
                orderedIntegrityGuardIDs: [
                    "supervisor_preflight_parent_physical_path",
                    "supervisor_preflight_parent_descriptor_policy",
                    "supervisor_preflight_parent_empty_inventory",
                    "supervisor_lease_acquire",
                    "supervisor_private_candidate_validation",
                    "supervisor_post_candidate_parent_stable_fields",
                    "supervisor_post_candidate_exact_child_inventory",
                    "supervisor_post_candidate_lease_file_policy",
                    "supervisor_device_and_mlx_postflight",
                    "supervisor_void_release_call",
                    "verifier_parent_identity",
                    "verifier_lease_file_identity",
                    "verifier_acquire_release_and_exit_zero",
                    "supervisor_exit_zero",
                    "outer_private_working_directory_postflight",
                    "outer_repository_postflight",
                    "outer_metallib_postflight",
                    "outer_parent_and_lease_file_rebind",
                ],
                integrityFailureReceiptEstablishesResourceClearance: false,
                malformedOrUnsafePrivatePacketMayProduceNoPublicReceipt: true,
                candidateRemainsSeparatelyObservableInRetirement: true,
                receiptForbiddenUnscopedSuccessKeys: [
                    "mechanics_success", "workflow_success",
                ],
                run117AggregateGuardFailed: true,
                run117FailedConjunctIdentified: false,
                run117ParentMetadataObserved: false,
                localAPFSDiagnosticBoundAsRun117Cause: false),
            authorityClosureScope: .init(
                exactChangedPaths: authorityPaths,
                rootPackageManifestMutationAuthorized: false,
                rootPackageResolvedMutationAuthorized: false,
                validationManifestMutationAuthorized: false,
                validationLockMutationAuthorized: false,
                newAuthoritySourceAuthorized: true,
                newAuthorityTestAuthorized: true,
                newLauncherAuthorized: false,
                newTrainingProbeSourceAuthorized: false,
                newExecutableMainAuthorized: false,
                newPureContractTestAuthorized: false,
                existingDecoderSourceMutationAuthorized: false,
                existingTrainingSourceMutationAuthorized: false,
                historicalStage6MechanicsMutationAuthorized: false,
                originalStage5MechanicsMutationAuthorized: false,
                replacementStage5MechanicsMutationAuthorized: false),
            successorScope: .init(
                exactChangedPaths: successorPaths,
                rootPackageManifestMutationAuthorized: false,
                rootPackageResolvedMutationAuthorized: false,
                validationManifestMutationAuthorized: true,
                validationLockMutationAuthorized: false,
                newAuthoritySourceAuthorized: false,
                newAuthorityTestAuthorized: false,
                newLauncherAuthorized: true,
                newTrainingProbeSourceAuthorized: true,
                newExecutableMainAuthorized: true,
                newPureContractTestAuthorized: true,
                existingDecoderSourceMutationAuthorized: false,
                existingTrainingSourceMutationAuthorized: false,
                historicalStage6MechanicsMutationAuthorized: false,
                originalStage5MechanicsMutationAuthorized: false,
                replacementStage5MechanicsMutationAuthorized: false),
            successorManifest: .init(
                launcherPath: launcher,
                packageManifestPath:
                    "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                packageName: "PrimeNativeDecoderTrainingValidation",
                executableProductName:
                    "PrimeNativeDecoderBSpecificNative300MResourceWitness",
                executableTargetName:
                    "PrimeNativeDecoderBSpecificNative300MResourceWitness",
                executableMainPath: executableMain,
                executableMainImports: [
                    "Foundation", "PrimeNativeDecoderTraining",
                ],
                executableMainEntryPoint:
                    "PrimeNativeDecoderBSpecificNative300MResourceWitness.runSupervisor()",
                trainingProbeSourcePath: trainingProbe,
                trainingProbePublicType:
                    "PrimeNativeDecoderBSpecificNative300MResourceWitness",
                contractTestPath: contractTest,
                contractTestClassName:
                    "PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests",
                contractTestMethodName:
                    "testBSpecificNative300MResourceWitnessContractIsExactAndExecutionPure",
                contractTestFilter:
                    "PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests/testBSpecificNative300MResourceWitnessContractIsExactAndExecutionPure",
                rootPackageManifestMustRemainByteIdentical: true,
                decoderAndExistingTrainingSourcesMustRemainByteIdentical:
                    true,
                historicalStage6MechanicsMustRemainByteIdentical: true,
                originalAndReplacementStage5MechanicsMustRemainByteIdentical:
                    true,
                authorityActiveJobTimeoutMinutes: 45,
                authorityReviewedJobTimeoutMinutes: 60,
                successorActiveJobTimeoutMinutes: 45,
                successorReviewedJobTimeoutMinutes: 90,
                successorReviewedOnlyTimeoutMutationAuthorized: true,
                retirementReviewedJobTimeoutMinutes: 60,
                retirementMustRestoreReviewedTimeout: true),
            suite: .init(
                authorityRootTestCount: 60,
                isolatedGroupTestCounts: [1, 1, 2, 2],
                isolatedTestCount: 6,
                authorityFocusedWholeTestCount: 66,
                metalTestCount: 44,
                maintainedRuntimeTestCount: 1,
                tokenizerTestCount: 1,
                authorityTotalXCTestCount: 112,
                authorityLiveOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                authorityOriginalStage5LauncherInvocationCount: 0,
                authorityReplacementStage5LauncherInvocationCount: 0,
                authorityHistoricalStage6LauncherInvocationCount: 0,
                authorityBResourceWitnessLauncherInvocationCount: 0,
                authorityMaintainedRuntimeReceiptCount: 1,
                authorityTokenizerReceiptCount: 1,
                authorityOriginalStage5ReceiptCount: 0,
                authorityReplacementStage5ReceiptCount: 0,
                authorityHistoricalStage6ReceiptCount: 0,
                authorityBResourceWitnessReceiptCount: 0,
                futureFocusedStepXCTestCount: 67,
                futureLiveStepXCTestCount: 47,
                futureTotalXCTestCount: 114,
                futureBContractFocusedXCTestCount: 1,
                futureBContractLauncherXCTestCount: 1,
                futureBContractXCTestStartCount: 2,
                futureBExecutableOperationalProbeCount: 1,
                futureBSuccessorAggregateInvocationCount: 3,
                futureBLauncherInvocationCount: 1,
                futureBPublicReceiptMaximumCount: 1,
                futureMaintainedRuntimeReceiptCount: 1,
                futureTokenizerReceiptCount: 1,
                futureOriginalStage5ReceiptCount: 0,
                futureReplacementStage5ReceiptCount: 0,
                futureHistoricalStage6ReceiptCount: 0,
                futureOriginalStage5LauncherInvocationCount: 0,
                futureReplacementStage5LauncherInvocationCount: 0,
                futureHistoricalStage6LauncherInvocationCount: 0,
                futureLiveOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                    "b_specific_native300m_resource_witness",
                ],
                futureBInternalOrder: [
                    "b_resource_witness_pure_contract_xctest",
                    "b_resource_witness_supervisor_resource_worker_and_release_verifier",
                ]),
            transitions: .init(
                publicStatusDomain: [
                    "ABSTAIN", "ABSTAIN_INTEGRITY", "PASS",
                ],
                passClassification: "pass",
                abstainClassifications: [
                    "worker_spawn_failure",
                    "preflight_floor",
                    "lease_busy",
                    "oom",
                    "timeout",
                    "signal",
                    "nonfinite",
                    "topology_dtype",
                    "no_update",
                ],
                integrityAbstainClassification: "integrity_failure",
                noPublicReceiptClassifications: [
                    "executor_receipt_drift",
                    "malformed_private_packet",
                    "unsafe_private_packet",
                    "unknown_integrity_guard",
                    "canonicalization_failure",
                    "publication_failure",
                ],
                classificationDecisionRules: [
                    "PASS:validated_PASS_candidate_and_every_required_resource_and_integrity_guard_passes",
                    "ABSTAIN:exhaustive_resource_classification_and_every_applicable_integrity_classification_and_publication_guard_passes;candidate_not_required",
                    "ABSTAIN_INTEGRITY:validated_PASS_or_ABSTAIN_candidate_and_first_known_integrity_guard_failure_safely_captured_and_terminal_classification_publication_closure_passes",
                    "NO_RECEIPT:malformed_duplicate_or_unsafe_private_packet_unknown_guard_canonicalization_failure_or_publication_failure;nonzero_and_no_result",
                ],
                authorityClosureExecutesWitness: false,
                passRequiresExactBAPIAndOperationCounts: true,
                passRequiresFiniteLossAndPositiveRawGradientNorm: true,
                passRequiresParameterFingerprintChange: true,
                passRequiresAllResourceAndIntegrityClosureProof: true,
                passEstablishesBSpecificResourceWitness: true,
                passEstablishesBSpecificResourceClearance: true,
                passEstablishesHistoricalStage6ApplicabilityToB: false,
                passEstablishesOrdinaryJobFit: false,
                passAuthorizesStage7: false,
                passRequiresSeparateStage7Authority: true,
                abstainEstablishesTerminalBResourceObservation: true,
                abstainEstablishesBSpecificResourceWitness: false,
                abstainEstablishesBSpecificResourceClearance: false,
                abstainAuthorizesStage7: false,
                integrityAbstainStatus: "ABSTAIN_INTEGRITY",
                integrityAbstainRequiresCandidatePresent: true,
                integrityAbstainCandidateScientificStatusDomain: [
                    "ABSTAIN", "PASS",
                ],
                integrityAbstainEstablishesBSpecificResourceWitness: false,
                integrityAbstainEstablishesResourceClearance: false,
                integrityAbstainPreservesCandidateForRetirement: true,
                malformedOrUnsafePrivatePacketEmitsPublicReceipt: false,
                malformedOrUnsafePrivatePacketEstablishesResult: false,
                mechanicsBeginningConsumesOneShotEvenWithoutTerminalReceipt:
                    true,
                everyOutcomeForbidsRetryAndRerun: true,
                everyOutcomeRequiresAppendOnlyObservationAndRetirement: true,
                everyOutcomeKeepsStage7False: true),
            ceiling: .init(
                authorityOnlyNoWitnessEvidence: true,
                stage5MechanicsSuccessEstablished: true,
                stage5ResultEstablished: true,
                stage5AssayClearanceEstablished: true,
                repeatedSameDeviceBPathDeterminismEstablished: true,
                exactSameDeviceBPathGradientBytesEstablished: true,
                historicalStage6ResourceClearanceRemainsEstablished: true,
                historicalStage6ResourceClearanceAppliesToBPath: false,
                bSpecificNative300MResourceWitnessRequiresSeparateAuthority:
                    true,
                bSpecificNative300MResourceWitnessMechanicsAuthorizedAfterGreenClosure:
                    true,
                oneExactMainBSpecificNative300MResourceWitnessAuthorized: true,
                oneNative300MAllocationAuthorizedForWitness: true,
                oneNative300MTrainingStepAuthorizedForWitness: true,
                boundedResourceMeasurementAuthorized: true,
                bSpecificNative300MResourceWitnessExecuted: false,
                bSpecificNative300MResourceWitnessEstablished: false,
                bSpecificNative300MResourceClearanceEstablished: false,
                additionalExecutionOrRerunAuthorized: false,
                ordinaryJobFitEstablished: false,
                broadNative300MTrainingAuthorized: false,
                defaultGatherDeterminismEstablished: false,
                arbitraryTokenDeterminismEstablished: false,
                crossDeviceDeterminismEstablished: false,
                durableCheckpointIOAuthorized: false,
                retainedArtifactAuthorized: false,
                artifactUploadAuthorized: false,
                generalTrainingResumeEstablished: false,
                native300MTrajectoryTrainingResumeEstablished: false,
                checkpointAdmissionGranted: false,
                modelQualityEstablished: false,
                candidateAdmissionGranted: false,
                stage7RequiresBSpecificNative300MResourceWitness: true,
                stage7RequiresSeparateAuthorityAfterWitness: true,
                stage7AuthorityEstablished: false,
                stage7Authorized: false,
                downstreamTrialAuthorized: false,
                canaryAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false),
            orderedRequiredSeparateActions: [
                "merge_and_pass_exact_main_b_specific_native300m_resource_witness_pure_authority_closure",
                "separately_implement_only_the_exact_eight_path_b_resource_witness_successor",
                "use_exactly_one_exact_main_b_resource_witness_opportunity_without_retry_or_rerun",
                "append_only_observe_and_retire_every_pass_abstain_or_invalid_outcome",
                "obtain_separate_stage7_authority_only_after_a_pass_witness",
            ],
            status:
                "AUTHORIZED_exact5_pure_b_specific_native300m_resource_witness_authority_then_one_exact8_exact_main_opportunity_historical_stage6_nonapplicable_candidate_before_public_receipt_stage7_false")
    }()

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityError
                    .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validateExactV1() throws {
        let replacementAuthority =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                .frozenV1
        let currentIdentity =
            PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationV1
                .frozenV1
        let stage5Observation =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationV1
                .frozenV1
        let stage6Authority =
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                .frozenV1
        let stage6Observation =
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationV1
                .frozenV1
        try replacementAuthority.validateExactV1()
        try currentIdentity.validateExactV1()
        try stage5Observation.validateExactV1()
        try stage6Authority.validateExactV1()
        try stage6Observation.validateExactV1()

        let falseCeilings = [
            ceiling.historicalStage6ResourceClearanceAppliesToBPath,
            ceiling.bSpecificNative300MResourceWitnessExecuted,
            ceiling.bSpecificNative300MResourceWitnessEstablished,
            ceiling.bSpecificNative300MResourceClearanceEstablished,
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.ordinaryJobFitEstablished,
            ceiling.broadNative300MTrainingAuthorized,
            ceiling.defaultGatherDeterminismEstablished,
            ceiling.arbitraryTokenDeterminismEstablished,
            ceiling.crossDeviceDeterminismEstablished,
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
        let sourceIdentitiesAreExact =
            repository.immutableBaseSourceBindings.allSatisfy { identity in
                ["100644", "100755"].contains(identity.gitMode)
                    && Self.isLowercaseHex(identity.gitBlob, count: 40)
                    && identity.byteCount > 0
                    && identity.lfByteCount > 0
                    && Self.isLowercaseHex(identity.sha256, count: 64)
            }
        let operationCounts = [
            futureExecution.buildCount,
            futureExecution.focusedPureContractXCTestCount,
            futureExecution.launcherPureContractXCTestCount,
            futureExecution.launcherInvocationCount,
            futureExecution.directExecutableProbeCount,
            futureExecution.supervisorProcessCount,
            futureExecution.maximumWorkerProcessCount,
            futureExecution.workerSpawnAttemptCount,
            futureExecution.modelAllocationCount,
            futureExecution.modelMaterializationCount,
            futureExecution.valueAndGradCount,
            futureExecution.directPackageBTrainingLogitsAPICallCount,
            futureExecution.denseEmbeddingConstructionCount,
            futureExecution.tokenBoundsValidationCount,
            futureExecution.tokenBoundsCheckedEvalCount,
            futureExecution.tokenBoundsGPUSynchronizeCount,
            futureExecution.tokenBoundsHostBoolItemCount,
            futureExecution.crossEntropyCount,
            futureExecution.forwardLossCount,
            futureExecution.backwardCount,
            futureExecution.rawGradientNormCount,
            futureExecution.gradientClipCount,
            futureExecution.optimizerStepCount,
            futureExecution.adamWUpdateCount,
            futureExecution.fullGraphEvaluationCount,
            futureExecution.memoryClearCacheCount,
            futureExecution.postflightDeviceReenumerationCount,
        ]
        let zeroOperationCounts = [
            futureExecution.maintainedGatherTrainingLogitsCount,
            futureExecution.tinyTrainingSelectorInvocationCount,
            futureExecution.inputEmbeddingForwardPairDiagnosticInvocationCount,
            futureExecution.kvCacheAllocationCount,
            futureExecution.evaluationForwardPassCount,
            futureExecution.checkpointReadCount,
            futureExecution.checkpointWriteCount,
            futureExecution.artifactUploadCount,
            futureExecution.qualityMetricComputationCount,
            futureExecution.generatedTokenCount,
        ]
        let batchTokenIDsData = try JSONEncoder().encode(
            configuration.batchTokenIDs)

        guard self == Self.frozenV1,
              schemaVersion == 1,
              authorityID
                == "prime_native_decoder_b_specific_native300m_resource_witness_authority_v1",
              roadmapBoundaryID
                == "b_specific_native300m_resource_witness_v1",
              repository.repository == "Ergentics/ergentics-prime",
              repository.ref == "refs/heads/main",
              repository.authorityBaseRevision
                == "7be3d77ad3ed3ae3ec7ec10d0aed6231c1083be4",
              repository.authorityBaseTree
                == "428097e2bf01276b91c9f4d7023a3c6ad496c4ca",
              repository.authorityBaseOrderedParents == [
                  "68422b34425fce761ce8d4afcbd7b0edbc1cf648",
                  "5ec7b58ed9186e93268b1dad0dcac889a03cb3ff",
              ],
              repository.retirementPullRequestNumber == 111,
              repository.retirementWorkflowRunID == 31_842_165_031,
              repository.retirementWorkflowRunNumber == 119,
              repository.retirementWorkflowRunAttempt == 1,
              repository.retirementCheckSuiteID == 86_388_590_215,
              repository.retirementActiveRootJobConclusion == "success",
              repository.retirementReviewedMainJobConclusion == "success",
              repository.retirementPreviousAttemptURLWasNull,
              repository.retirementExactHeadPushRunCount == 1,
              repository.retirementRerunCount == 0,
              repository.retirementArtifactCount == 0,
              repository.retirementIsolatedTestCount
                == repository.retirementIsolatedGroupTestCounts.reduce(0, +),
              repository.retirementFocusedWholeTestCount
                == repository.retirementRootTestCount
                    + repository.retirementIsolatedTestCount,
              repository.retirementTotalTestCount
                == repository.retirementFocusedWholeTestCount
                    + repository.retirementMetalTestCount
                    + repository.retirementMaintainedRuntimeTestCount
                    + repository.retirementTokenizerTestCount,
              repository.retirementLiveOrder
                == ["metal", "maintained_runtime", "tokenizer"],
              repository.retirementOriginalStage5LauncherInvocationCount == 0,
              repository.retirementReplacementStage5LauncherInvocationCount
                == 0,
              repository.retirementHistoricalStage6LauncherInvocationCount
                == 0,
              repository.retirementExactChangedPaths
                == repository.retirementExactChangedPaths.sorted(),
              Set(repository.retirementExactChangedPaths).count == 5,
              repository.retirementChangedSourceIdentities.count == 5,
              repository.authorityClosureExactChangedPaths
                == repository.authorityClosureExactChangedPaths.sorted(),
              Set(repository.authorityClosureExactChangedPaths).count == 5,
              repository.authoritySourceAndTestAreOnlyNewPaths,
              repository.immutableBaseSourceBindings.count == 16,
              sourceIdentitiesAreExact,
              Self.isLowercaseHex(repository.preservedIndexSHA256, count: 64),
              Self.isLowercaseHex(
                  repository.embeddedSourceIdentitySHA256, count: 64),
              stage5Pass.authorityID == replacementAuthority.authorityID,
              stage5Pass.authorityCanonicalSHA256
                == PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                    .canonicalSHA256,
              stage5Pass.currentDecoderIdentityObservationID
                == currentIdentity.observationID,
              stage5Pass.currentDecoderIdentityCanonicalSHA256
                == PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationV1
                    .canonicalSHA256,
              stage5Pass.passObservationID == stage5Observation.observationID,
              stage5Pass.passObservationCanonicalSHA256
                == PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationV1
                    .canonicalSHA256,
              stage5Pass.workflowRunNumber == 117,
              stage5Pass.workflowRunAttempt == 1,
              stage5Pass.runConclusion == "failure",
              stage5Pass.reviewedMainJobConclusion == "failure",
              stage5Pass.launcherInvocationCount == 1,
              stage5Pass.directXCTestInvocationCount == 1,
              stage5Pass.testPassCount == 1,
              stage5Pass.testFailureCount == 0,
              stage5Pass.testSkipCount == 0,
              stage5Pass.receiptStatus == "PASS_CLEARANCE",
              stage5Pass.receiptOccurrenceCount == 1,
              stage5Pass.oneShotConsumed,
              stage5Pass.oneShotExhausted,
              stage5Pass.armBAllExactComparisonsPassed,
              stage5Pass.armBAllForwardEquivalenceChecksPassed,
              stage5Pass.stage5MechanicsSuccessEstablished,
              stage5Pass.stage5ResultEstablished,
              stage5Pass.stage5AssayClearanceEstablished,
              stage5Pass.repeatedSameDeviceBPathDeterminismEstablished,
              stage5Pass.exactSameDeviceBPathGradientBytesEstablished,
              !stage5Pass.defaultGatherDeterminismEstablished,
              stage5Pass.outerLeaseParentGuardConjuncts.count == 6,
              stage5Pass.outerLeaseParentGuardFailed,
              !stage5Pass.failedGuardConjunctIdentified,
              !stage5Pass.actualLeaseParentMetadataObserved,
              !stage5Pass.localAPFSLinkCountReproductionBoundAsCause,
              stage5Pass.receiptEstablishedBeforeOuterFailure,
              !stage5Pass.launcherPostReceiptCompletionEstablished,
              !stage5Pass.outerWorkflowSuccessEstablished,
              stage5Pass.replacementLauncherRetired,
              !stage5Pass.additionalExecutionOrRerunAuthorized,
              historicalStage6.authorityID == stage6Authority.authorityID,
              historicalStage6.authorityCanonicalSHA256
                == PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                    .canonicalSHA256,
              historicalStage6.observationID
                == stage6Observation.observationID,
              historicalStage6.observationCanonicalSHA256
                == PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationV1
                    .canonicalSHA256,
              historicalStage6.trainingLogitsAPI
                == "PrimeNativeGQADecoder.trainingLogitsNoCache",
              historicalStage6.trainingInputPathID == "maintained_gather_v1",
              historicalStage6.resourceProbeExecuted,
              historicalStage6.resourceEnvelopeEstablished,
              historicalStage6.resourceClearanceEstablished,
              historicalStage6.runnerMemoryCapacityEstablished,
              !historicalStage6.ordinaryJobFitEstablished,
              historicalStage6.oneShotConsumed,
              historicalStage6.retirementObserved,
              historicalStage6.remainsHistoricalEvidence,
              !historicalStage6.appliesToCurrentBPath,
              !historicalStage6.mayBeUsedAsBPeakPrediction,
              !historicalStage6.mayBeUsedAsBResourceClearance,
              bPath.algorithmID
                == "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1",
              bPath.selectorRawValue
                == "flattened_dense_one_hot_matmul_input_embedding_v1",
              bPath.trainingLogitsAPI
                == "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
              bPath.packageOnlySurfaceRequired,
              !bPath.publicDecoderAPIAdded,
              bPath.currentDecoderIdentityIsSoleRetainedLiveIdentity,
              bPath.defaultGatherPathRemainsByteIdentical,
              bPath.densePathIsExplicitOptIn,
              bPath.decoderLayersFinalNormAndOutputProjectionSharedWithMaintainedPath,
              bPath.tokenBoundsCheckedInt32VocabularyConversionRequired,
              bPath.tokenBoundsCheckedEvalCountPerDenseConstruction == 1,
              bPath.tokenBoundsGPUSynchronizeCountPerDenseConstruction == 1,
              bPath.tokenBoundsHostBoolItemCountPerDenseConstruction == 1,
              bPath.denseMatmulCountPerDenseConstruction == 1,
              configuration.vocabularySize == 512,
              configuration.modelWidth == 1_024,
              configuration.layerCount == 24,
              configuration.ropeThetaFloat32BitPattern == 1_176_256_512,
              configuration.rmsNormEpsilonFloat32BitPattern == 925_353_388,
              configuration.parameterPathCount == 218,
              configuration.uniqueParameterCount == 271_107_072,
              configuration.logicalParameterByteCount == 1_084_428_288,
              configuration.initializationSeed == 44,
              configuration.batchSize == 1,
              configuration.sequenceLength == 128,
              configuration.validTokenCount == 128,
              configuration.selectedTargetCount == 127,
              configuration.batchTokenIDs.count == 1,
              configuration.batchTokenIDs[0].count == 128,
              configuration.batchTokenIDs[0]
                == [1] + (0 ..< 127).map({ 2 + (($0 * 73 + 44) % 510) }),
              configuration.batchTokenIDsSHA256
                == PrimeSHA256.hexDigest(of: batchTokenIDsData),
              configuration.batchTokenIDsSHA256PreimageRule
                == "sha256_of_compact_json_utf8_rank_two_batch_token_ids",
              configuration.completionMask
                == [[false] + Array(repeating: true, count: 127)],
              configuration.tokenIDStorageDType == "int32",
              configuration.completionMaskStorageDType == "bool",
              configuration.flattenedTokenColumnShape == [128, 1],
              configuration.vocabularyRowShape == [1, 512],
              configuration.denseOneHotShape == [128, 512],
              configuration.denseOneHotDType == "float32",
              configuration.denseOneHotElementCount == 65_536,
              configuration.denseOneHotLogicalByteCount == 262_144,
              configuration.flattenedDenseEmbeddingShape == [128, 1_024],
              configuration.flattenedDenseEmbeddingDType == "float32",
              configuration.flattenedDenseEmbeddingElementCount == 131_072,
              configuration.flattenedDenseEmbeddingLogicalByteCount
                == 524_288,
              configuration.restoredDenseEmbeddingShape == [1, 128, 1_024],
              configuration.trainingLogitsExpectedShape == [1, 128, 512],
              configuration.trainingLogitsDType == "float32",
              configuration.trainingLogitsUsesCausalAttentionMask,
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
              configuration.crossEntropyWeights == "nil",
              configuration.crossEntropyAxis == -1,
              configuration.crossEntropyLabelSmoothingFloat32BitPattern == 0,
              configuration.crossEntropyReduction == "none",
              configuration.valueAndGradClosureArguments
                == ["model", "token_ids", "completion_mask"],
              configuration.valueAndGradClosureReturnsOnlyScalarLoss,
              configuration.optimizerStateExpectedArrayCount == 436,
              configuration.optimizerStateExpectedPairCount == 218,
              configuration.parameterFingerprintExpectedSampleCount == 654,
              configuration.gradientAccumulationCount == 1,
              configuration.optimizerStepCount == 1,
              !configuration.paddingAuthorized,
              !configuration.kvCacheAuthorized,
              !configuration.evaluationForwardAuthorized,
              !configuration.generationAuthorized,
              !configuration.checkpointAuthorized,
              configuration.configurationIsResourceWitnessOnlyNotTrainingPolicy,
              resourceEnvelope.minimumCommittedTensorStateByteCount
                == resourceEnvelope.weightsLogicalByteCount
                    + resourceEnvelope.optimizerMomentLogicalByteCount,
              resourceEnvelope.minimumStatePlusGradientByteCount
                == resourceEnvelope.minimumCommittedTensorStateByteCount
                    + resourceEnvelope.gradientLogicalByteCount,
              resourceEnvelope.configuredMLXMemoryLimitFormula
                == "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)",
              resourceEnvelope.historicalStage6PeakIsBaselineOnly,
              !resourceEnvelope.analyticBIncrementalBytesArePeakEvidence,
              !resourceEnvelope.analyticBIncrementalBytesAreClearanceEvidence,
              !resourceEnvelope.containerHeadersAndManifestsIncludedInMinimum,
              !resourceEnvelope.duplicateGraphsAndTemporaryBuffersIncludedInMinimum,
              !resourceEnvelope.configuredMLXLimitIsProcessRSSLimit,
              !resourceEnvelope.filesystemObservationIsCheckpointDiskSufficiencyClaim,
              resourceEnvelope.passRequiresAllPhaseMetricsObserved,
              resourceEnvelope.passRequiresMeasuredPeakBelowConfiguredLimit,
              resourceEnvelope.passEstablishesOnlyExactRunResourceWitness,
              inheritedResourceContract.historicalAuthorityID
                == historicalStage6.authorityID,
              inheritedResourceContract.historicalAuthorityCanonicalSHA256
                == historicalStage6.authorityCanonicalSHA256,
              inheritedResourceContract.preservationRule
                == "preserve_historical_stage6_configuration_environment_phase_live_set_metric_limit_fingerprint_optimizer_timeout_and_resource_abstain_semantics_except_exact_authorized_deltas;no_unlisted_semantic_delta",
              inheritedResourceContract.exactAuthorizedDeltas == [
                  "new_ids_paths_exact_main_provenance_and_b_specific_post_forward_backward_phase_name",
                  "maintained_gather_training_logits_replaced_by_sole_direct_b_training_logits_api",
                  "b_flattened_dense_shapes_and_one_ordered_token_bounds_checked_eval_sync_host_bool_barrier_added",
                  "supervisor_owns_lease_and_distinct_exec_verifier_proves_persistent_release_disposition",
                  "private_candidate_outer_final_publication_and_abstain_integrity_added",
              ],
              inheritedResourceContract.mlxEnableTF32 == "0",
              inheritedResourceContract.exactMLXRevision
                == "d37885a278f1c37484a94d0f401a418735e66519",
              inheritedResourceContract.metalDeviceIndex == 0,
              inheritedResourceContract.exactMetalDeviceCount == 1,
              inheritedResourceContract.singletonDeviceEnumerationRequired,
              inheritedResourceContract.indexZeroMustMatchDefaultDevice,
              inheritedResourceContract.mlxGraphCompileMode
                == "eager_uncompiled_no_compile_transform",
              inheritedResourceContract.mlxCompileTransformInvocationCount
                == 0,
              inheritedResourceContract.configuredMLXMemoryLimitSetter
                == "MLX.Memory.memoryLimit",
              inheritedResourceContract.configuredMLXMemoryLimitSetCount == 1,
              inheritedResourceContract.configuredMLXMemoryLimitReadbackRequired,
              inheritedResourceContract.configuredMLXCacheLimitSetter
                == "MLX.Memory.cacheLimit",
              inheritedResourceContract.configuredMLXCacheLimitSetCount == 1,
              inheritedResourceContract.configuredMLXCacheLimitReadbackRequired,
              inheritedResourceContract.mlxPeakMemoryResetCount == 1,
              inheritedResourceContract.mlxPeakMemoryResetAPI
                == "MLX.Memory.peakMemory = 0",
              inheritedResourceContract.filesystemObservationUsesStatFS,
              inheritedResourceContract.filesystemObservationRequiresStableOrderedFSID,
              inheritedResourceContract.phaseAndLiveSetRulesInheritedWithoutChange,
              operationCounts.allSatisfy({ $0 == 1 }),
              zeroOperationCounts.allSatisfy({ $0 == 0 }),
              futureExecution.pureContractXCTestStartCount == 2,
              futureExecution.successorAggregateInvocationCount == 3,
              futureExecution.successorAggregateInvocationTopology == [
                  "focused_pure_contract_xctest_start",
                  "launcher_pure_contract_xctest_start",
                  "direct_executable_probe",
              ],
              futureExecution.checkedEvaluationBarrierCount == 6,
              futureExecution.gpuSynchronizationBarrierCount == 6,
              futureExecution.orderedCheckedEvaluationAndSynchronizationBarriers
                == [
                    "model_materialization_all_model_parameters_before_fingerprint_samples",
                    "sole_b_logits_call_token_bounds_checked_eval_default_gpu_sync_then_host_bool_item",
                    "forward_backward_loss_and_all_gradients",
                    "pre_clip_raw_gradient_norm_before_host_scalar_read",
                    "post_norm_clip_all_clipped_gradients",
                    "post_adam_model_436_moments_and_after_fingerprint_views",
                ],
              futureExecution.resourceOperationCountsArePassPathExact,
              futureExecution.abstainOperationCountsAreAttemptedPrefixCounts,
              futureExecution.oneExactMainOpportunityAfterGreenAuthorityClosure,
              !futureExecution.retryAuthorized,
              !futureExecution.rerunAuthorized,
              !futureExecution.replacementRunAuthorized,
              leaseReceiptIntegrity.preflightParentRequiredTupleFields == [
                  "physical_path", "file_type", "device_id", "inode",
                  "uid", "gid", "mode", "security_flags",
                  "acl_entry_count", "allowed_extended_attribute_names",
              ],
              leaseReceiptIntegrity.parentDescriptorOpenFlags == [
                  "O_RDONLY", "O_DIRECTORY", "O_NOFOLLOW", "O_CLOEXEC",
              ],
              leaseReceiptIntegrity.leaseFileDescriptorOpenFlags == [
                  "O_RDWR", "O_CREAT", "O_NOFOLLOW", "O_CLOEXEC",
              ],
              leaseReceiptIntegrity.descriptorNameRebindRequired,
              leaseReceiptIntegrity.descriptorNameRebindMustMatchDeviceAndInode,
              leaseReceiptIntegrity.identityEvidenceIsDescriptorDerivedInSupervisorAndVerifier,
              leaseReceiptIntegrity.preflightParentMustBeEmptyDirectory,
              leaseReceiptIntegrity.preflightParentMustBeNonSymlink,
              leaseReceiptIntegrity.preflightParentPhysicalPathMustEqualExpectedPath,
              leaseReceiptIntegrity.parentRequiredFileType == "directory",
              leaseReceiptIntegrity.parentRequiredOwnerMatchesEffectiveUID,
              leaseReceiptIntegrity.parentGroupPolicy
                == "preflight_observed_gid_must_remain_exactly_unchanged",
              leaseReceiptIntegrity.parentRequiredMode == "0700",
              leaseReceiptIntegrity.parentLinkCountObserved,
              !leaseReceiptIntegrity.parentLinkCountMustBePositive,
              !leaseReceiptIntegrity.parentLinkCountUsedAsStableIdentityAfterChildCreation,
              leaseReceiptIntegrity.postCandidateParentFieldsRequiringExactPreflightEquality
                == [
                    "physical_path", "file_type", "device_id", "inode",
                    "uid", "gid", "mode", "security_flags",
                    "acl_entry_count",
                ],
              !leaseReceiptIntegrity.postCandidateParentIdentityGuardIsOpaqueAggregate,
              leaseReceiptIntegrity.postCandidateParentMismatchIdentifiesExactField,
              leaseReceiptIntegrity.exactOneChildInventoryRequired,
              leaseReceiptIntegrity.leaseInventoryComparisonRule
                == "unordered_exact_basename_set_equals_{device-0.lock}",
              leaseReceiptIntegrity.leaseFileMustBeRegularNonSymlink,
              leaseReceiptIntegrity.leaseFileMustMatchParentDeviceID,
              leaseReceiptIntegrity.leaseFileRequiredMode == "0600",
              leaseReceiptIntegrity.leaseFileRequiredLinkCount == 1,
              leaseReceiptIntegrity.leaseFileRequiredByteCount == 0,
              leaseReceiptIntegrity.parentAllowedExtendedAttributeNames
                == ["com.apple.provenance"],
              leaseReceiptIntegrity.parentObservedExtendedAttributeNamesMustBeAllowedSubset,
              leaseReceiptIntegrity.leaseFileAllowedExtendedAttributeNames
                == ["com.apple.provenance"],
              leaseReceiptIntegrity.leaseFileObservedExtendedAttributeNamesMustBeAllowedSubset,
              leaseReceiptIntegrity.operationalProbeRoleProcessInvocationCount
                == 3,
              leaseReceiptIntegrity.resourceWorkerSpawnCount == 1,
              leaseReceiptIntegrity.releaseVerifierSpawnCount == 1,
              leaseReceiptIntegrity.primeLeaseAcquireAttemptCount == 2,
              leaseReceiptIntegrity.primeLeaseAcquireSuccessCount == 2,
              leaseReceiptIntegrity.primeLeaseReleaseCallCount == 2,
              leaseReceiptIntegrity.individualFlockSyscallSuccessClaimCount
                == 0,
              leaseReceiptIntegrity.individualCloseSyscallSuccessClaimCount
                == 0,
              leaseReceiptIntegrity.supervisorIsSoleLeaseOwnerBeforeExplicitRelease,
              leaseReceiptIntegrity.supervisorHoldsLeaseThroughCandidateAndDeviceMLXPostflight,
              leaseReceiptIntegrity.explicitSupervisorReleaseCount == 1,
              leaseReceiptIntegrity.releaseVerifierExecChildCount == 1,
              leaseReceiptIntegrity.verifierExecutesWhileSupervisorAliveAfterVoidRelease,
              leaseReceiptIntegrity.releaseVerifierMustAcquireReleaseAndExitZero,
              leaseReceiptIntegrity.releaseVerifierExitZeroObservationCount
                == 1,
              leaseReceiptIntegrity.supervisorExitZeroObservationCount == 1,
              leaseReceiptIntegrity.outerWaitsForSupervisorExitBeforePublication,
              leaseReceiptIntegrity.verifierProcessExitProvidesKernelCloseBackstop,
              leaseReceiptIntegrity.workerExecInheritsLeaseFileDescriptorCount
                == 0,
              leaseReceiptIntegrity.verifierParentDeviceAndInodeMustEqualSupervisorPreRelease,
              leaseReceiptIntegrity.verifierLeaseFileDeviceAndInodeMustEqualSupervisorPreRelease,
              leaseReceiptIntegrity.outerFinalReboundIdentityMustMatchVerifier,
              !leaseReceiptIntegrity.launcherUnlinksLeaseFile,
              !leaseReceiptIntegrity.launcherRemovesLeaseParent,
              leaseReceiptIntegrity.persistentLeaseRootAndLeafAreIntentionalLeaseSemantics,
              !leaseReceiptIntegrity.persistentLeaseRootAndLeafAreRetainedArtifact,
              leaseReceiptIntegrity.workerPublicCanonicalReceiptCount == 0,
              leaseReceiptIntegrity.supervisorPublicCanonicalReceiptCount == 0,
              leaseReceiptIntegrity.launcherPublicCanonicalReceiptMaximumCount
                == 1,
              leaseReceiptIntegrity.validTerminalClassificationPublicReceiptCount
                == 1,
              !leaseReceiptIntegrity.internalCandidateIsResultEvidence,
              leaseReceiptIntegrity.publicPrefixCountsAreAllOutcomeCeilings,
              leaseReceiptIntegrity.processLeaseAcquireAndReleaseCountsArePassPathExact,
              leaseReceiptIntegrity.abstainProcessAndLeaseCountsAreAttemptedPrefixCounts,
              leaseReceiptIntegrity.anyPublicReceiptRequiresTerminalClassificationClosure,
              leaseReceiptIntegrity.anyPublicReceiptRequiresSupervisorTermination,
              leaseReceiptIntegrity.passRequiresValidatedScientificCandidate,
              leaseReceiptIntegrity.passRequiresLeaseReleaseVerifierAndPersistentIdentityProof,
              leaseReceiptIntegrity.passRequiresAllPostflights,
              leaseReceiptIntegrity.passRequiresOuterIntegritySuccess,
              leaseReceiptIntegrity.resourceAbstainMayBeSupervisorSynthesizedWithoutCandidate,
              leaseReceiptIntegrity.resourceAbstainMayCompleteWithoutReleaseVerifierOnlyWhenNoLeaseWasAcquired,
              leaseReceiptIntegrity.resourceAbstainAfterLeaseAcquisitionRequiresReleaseVerifier,
              leaseReceiptIntegrity.resourceAbstainRequiresApplicableLeaseDispositionProof,
              leaseReceiptIntegrity.resourceAbstainRequiresAllApplicableOuterPostflights,
              leaseReceiptIntegrity.resourceAbstainRequiresSafeOuterPublicationClosure,
              leaseReceiptIntegrity.integrityAbstainRequiresSupervisorTermination,
              leaseReceiptIntegrity.integrityAbstainRequiresTerminalClassificationClosure,
              !leaseReceiptIntegrity.integrityAbstainRequiresOuterIntegritySuccess,
              leaseReceiptIntegrity.publicReceiptEmissionAndFlushAreFinalFallibleLauncherAction,
              leaseReceiptIntegrity.launcherExitTrapsClearedBeforePublicReceipt,
              leaseReceiptIntegrity.finalPublicReceiptCommand
                == "exec /usr/bin/printf '%s\\n' \"$public_line\"",
              leaseReceiptIntegrity.noAuthoredActionAfterFinalPublicReceiptExec,
              !leaseReceiptIntegrity.launcherOKMarkerAfterPublicReceipt,
              !leaseReceiptIntegrity.candidateIntegrityOrPostflightFailureEmitsPassOrResourceAbstain,
              !leaseReceiptIntegrity.candidateIntegrityOrPostflightFailureEstablishesClearance,
              leaseReceiptIntegrity.candidateIntegrityOrPostflightFailureConsumesOpportunity,
              !leaseReceiptIntegrity.candidateIntegrityOrPostflightFailurePermitsRetry,
              leaseReceiptIntegrity.candidateIntegrityOrPostflightFailureEmitsIntegrityAbstainWhenSafelyClassifiable,
              leaseReceiptIntegrity.integrityFailureReceiptStatus
                == "ABSTAIN_INTEGRITY",
              leaseReceiptIntegrity.integrityFailureReceiptRequiresValidatedCandidate,
              leaseReceiptIntegrity.integrityFailureReceiptPreservesCandidateScientificStatus,
              leaseReceiptIntegrity.integrityFailureReceiptRequiresFirstFailedGuard,
              leaseReceiptIntegrity.integrityFailureReceiptRequiresErrnoWhenAvailable,
              leaseReceiptIntegrity.integrityFailureReceiptRequiresActualMetadataAvailability,
              leaseReceiptIntegrity.integrityFailureReceiptActualMetadataMayBeNull,
              leaseReceiptIntegrity.integrityFailureReceiptNullActualMetadataRequiresUnavailableReasonOrErrno,
              leaseReceiptIntegrity.integrityFailureReceiptRequiredBindings
                == [
                    "candidate_present", "candidate_scientific_status",
                    "candidate_sha256", "first_failed_guard_id",
                    "errno_availability", "errno",
                    "actual_metadata_availability", "actual_metadata",
                    "actual_metadata_unavailable_reason",
                    "one_shot_consumed",
                    "b_specific_native300m_resource_clearance",
                ],
              leaseReceiptIntegrity.orderedIntegrityGuardIDs.count == 18,
              !leaseReceiptIntegrity.integrityFailureReceiptEstablishesResourceClearance,
              leaseReceiptIntegrity.malformedOrUnsafePrivatePacketMayProduceNoPublicReceipt,
              leaseReceiptIntegrity.candidateRemainsSeparatelyObservableInRetirement,
              leaseReceiptIntegrity.run117AggregateGuardFailed,
              !leaseReceiptIntegrity.run117FailedConjunctIdentified,
              !leaseReceiptIntegrity.run117ParentMetadataObserved,
              !leaseReceiptIntegrity.localAPFSDiagnosticBoundAsRun117Cause,
              authorityClosureScope.exactChangedPaths
                == authorityClosureScope.exactChangedPaths.sorted(),
              Set(authorityClosureScope.exactChangedPaths).count == 5,
              !authorityClosureScope.validationManifestMutationAuthorized,
              authorityClosureScope.newAuthoritySourceAuthorized,
              authorityClosureScope.newAuthorityTestAuthorized,
              !authorityClosureScope.newLauncherAuthorized,
              successorScope.exactChangedPaths
                == successorScope.exactChangedPaths.sorted(),
              Set(successorScope.exactChangedPaths).count == 8,
              successorScope.validationManifestMutationAuthorized,
              successorScope.newLauncherAuthorized,
              successorScope.newTrainingProbeSourceAuthorized,
              successorScope.newExecutableMainAuthorized,
              successorScope.newPureContractTestAuthorized,
              !successorScope.existingDecoderSourceMutationAuthorized,
              !successorScope.existingTrainingSourceMutationAuthorized,
              !successorScope.historicalStage6MechanicsMutationAuthorized,
              successorManifest.rootPackageManifestMustRemainByteIdentical,
              successorManifest.decoderAndExistingTrainingSourcesMustRemainByteIdentical,
              successorManifest.historicalStage6MechanicsMustRemainByteIdentical,
              successorManifest.originalAndReplacementStage5MechanicsMustRemainByteIdentical,
              successorManifest.authorityActiveJobTimeoutMinutes == 45,
              successorManifest.authorityReviewedJobTimeoutMinutes == 60,
              successorManifest.successorActiveJobTimeoutMinutes == 45,
              successorManifest.successorReviewedJobTimeoutMinutes == 90,
              successorManifest.successorReviewedOnlyTimeoutMutationAuthorized,
              successorManifest.retirementReviewedJobTimeoutMinutes == 60,
              successorManifest.retirementMustRestoreReviewedTimeout,
              suite.isolatedTestCount
                == suite.isolatedGroupTestCounts.reduce(0, +),
              suite.authorityFocusedWholeTestCount
                == suite.authorityRootTestCount + suite.isolatedTestCount,
              suite.authorityTotalXCTestCount
                == suite.authorityFocusedWholeTestCount
                    + suite.metalTestCount
                    + suite.maintainedRuntimeTestCount
                    + suite.tokenizerTestCount,
              suite.authorityTotalXCTestCount == 112,
              suite.authorityMaintainedRuntimeReceiptCount == 1,
              suite.authorityTokenizerReceiptCount == 1,
              suite.authorityOriginalStage5ReceiptCount == 0,
              suite.authorityReplacementStage5ReceiptCount == 0,
              suite.authorityHistoricalStage6ReceiptCount == 0,
              suite.authorityBResourceWitnessReceiptCount == 0,
              suite.futureFocusedStepXCTestCount == 67,
              suite.futureLiveStepXCTestCount == 47,
              suite.futureTotalXCTestCount == 114,
              suite.futureBContractXCTestStartCount == 2,
              suite.futureBSuccessorAggregateInvocationCount == 3,
              suite.futureBPublicReceiptMaximumCount == 1,
              suite.futureMaintainedRuntimeReceiptCount == 1,
              suite.futureTokenizerReceiptCount == 1,
              suite.futureOriginalStage5ReceiptCount == 0,
              suite.futureReplacementStage5ReceiptCount == 0,
              suite.futureHistoricalStage6ReceiptCount == 0,
              suite.futureLiveOrder == [
                  "metal", "maintained_runtime", "tokenizer",
                  "b_specific_native300m_resource_witness",
              ],
              transitions.publicStatusDomain
                == ["ABSTAIN", "ABSTAIN_INTEGRITY", "PASS"],
              transitions.passClassification == "pass",
              transitions.abstainClassifications == [
                  "worker_spawn_failure", "preflight_floor", "lease_busy",
                  "oom", "timeout", "signal", "nonfinite",
                  "topology_dtype", "no_update",
              ],
              transitions.integrityAbstainClassification
                == "integrity_failure",
              transitions.noPublicReceiptClassifications == [
                  "executor_receipt_drift", "malformed_private_packet",
                  "unsafe_private_packet", "unknown_integrity_guard",
                  "canonicalization_failure", "publication_failure",
              ],
              transitions.classificationDecisionRules.count == 4,
              !transitions.authorityClosureExecutesWitness,
              transitions.passRequiresExactBAPIAndOperationCounts,
              transitions.passRequiresAllResourceAndIntegrityClosureProof,
              transitions.passEstablishesBSpecificResourceWitness,
              transitions.passEstablishesBSpecificResourceClearance,
              !transitions.passEstablishesHistoricalStage6ApplicabilityToB,
              !transitions.passEstablishesOrdinaryJobFit,
              !transitions.passAuthorizesStage7,
              transitions.passRequiresSeparateStage7Authority,
              transitions.abstainEstablishesTerminalBResourceObservation,
              !transitions.abstainEstablishesBSpecificResourceWitness,
              !transitions.abstainEstablishesBSpecificResourceClearance,
              !transitions.abstainAuthorizesStage7,
              transitions.integrityAbstainStatus == "ABSTAIN_INTEGRITY",
              transitions.integrityAbstainRequiresCandidatePresent,
              transitions.integrityAbstainCandidateScientificStatusDomain
                == ["ABSTAIN", "PASS"],
              !transitions.integrityAbstainEstablishesBSpecificResourceWitness,
              !transitions.integrityAbstainEstablishesResourceClearance,
              transitions.integrityAbstainPreservesCandidateForRetirement,
              !transitions.malformedOrUnsafePrivatePacketEmitsPublicReceipt,
              !transitions.malformedOrUnsafePrivatePacketEstablishesResult,
              transitions.mechanicsBeginningConsumesOneShotEvenWithoutTerminalReceipt,
              transitions.everyOutcomeForbidsRetryAndRerun,
              transitions.everyOutcomeRequiresAppendOnlyObservationAndRetirement,
              transitions.everyOutcomeKeepsStage7False,
              ceiling.authorityOnlyNoWitnessEvidence,
              ceiling.stage5MechanicsSuccessEstablished,
              ceiling.stage5ResultEstablished,
              ceiling.stage5AssayClearanceEstablished,
              ceiling.repeatedSameDeviceBPathDeterminismEstablished,
              ceiling.exactSameDeviceBPathGradientBytesEstablished,
              ceiling.historicalStage6ResourceClearanceRemainsEstablished,
              ceiling.bSpecificNative300MResourceWitnessRequiresSeparateAuthority,
              ceiling.bSpecificNative300MResourceWitnessMechanicsAuthorizedAfterGreenClosure,
              ceiling.oneExactMainBSpecificNative300MResourceWitnessAuthorized,
              ceiling.oneNative300MAllocationAuthorizedForWitness,
              ceiling.oneNative300MTrainingStepAuthorizedForWitness,
              ceiling.boundedResourceMeasurementAuthorized,
              ceiling.stage7RequiresBSpecificNative300MResourceWitness,
              ceiling.stage7RequiresSeparateAuthorityAfterWitness,
              falseCeilings.allSatisfy({ !$0 }),
              orderedRequiredSeparateActions.count == 5,
              status.hasSuffix("stage7_false") else {
            throw
                PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityError
                    .contractDrift("frozen V1")
        }
    }

    private static func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy { scalar in
                (scalar.value >= 48 && scalar.value <= 57)
                    || (scalar.value >= 97 && scalar.value <= 102)
            }
    }
}
