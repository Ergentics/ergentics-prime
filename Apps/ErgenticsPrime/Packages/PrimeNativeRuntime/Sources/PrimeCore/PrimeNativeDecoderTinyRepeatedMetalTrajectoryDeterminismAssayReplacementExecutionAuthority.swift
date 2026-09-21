// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift(String)
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderStage5ReplacementSourceIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String
    public let role: String
}

public struct PrimeNativeDecoderStage5ReplacementExternalSourceBindingV1:
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

public struct PrimeNativeDecoderStage5ReplacementSelectorBindingV1:
    Codable,
    Equatable,
    Sendable
{
    public let caseName: String
    public let rawValue: String
}

public struct PrimeNativeDecoderStage5ReplacementCurrentMainV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let ref: String
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let pullRequestNumber: Int
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let workflowRunAttempt: Int
    public let checkSuiteID: Int
    public let activeRootJobID: Int
    public let reviewedMainJobID: Int
    public let status: String
    public let conclusion: String
    public let previousAttemptURLWasNull: Bool
    public let rerunCount: Int
    public let artifactCount: Int
    public let activeRootJobStepCount: Int
    public let activeRootSuccessfulStepCount: Int
    public let reviewedMainJobStepCount: Int
    public let reviewedMainSuccessfulStepCount: Int
    public let rootTestCount: Int
    public let isolatedGroupTestCounts: [Int]
    public let isolatedTestCount: Int
    public let focusedWholeTestCount: Int
    public let metalTestCount: Int
    public let maintainedRuntimeTestCount: Int
    public let tokenizerTestCount: Int
    public let totalTestCount: Int
    public let stage5LauncherInvocationCount: Int
    public let stage5ReceiptCount: Int
    public let stage6LauncherInvocationCount: Int
    public let stage6ReceiptCount: Int
    public let exactChangedSources: [
        PrimeNativeDecoderStage5ReplacementSourceIdentityV1
    ]
    public let exactMainSealed: Bool
}

public struct PrimeNativeDecoderStage5ReplacementPredecessorV1:
    Codable,
    Equatable,
    Sendable
{
    public let designAuthorityID: String
    public let designAuthorityCanonicalSHA256: String
    public let originalStage5AuthorityID: String
    public let originalStage5AuthorityCanonicalSHA256: String
    public let immediateRepairAuthorityID: String
    public let immediateRepairAuthorityCanonicalSHA256: String
    public let failureObservationID: String
    public let failureObservationCanonicalSHA256: String
    public let failureMechanicsRevision: String
    public let failureMechanicsTree: String
    public let failureWorkflowRunID: Int
    public let failureWorkflowRunNumber: Int
    public let failureWorkflowRunAttempt: Int
    public let failureCheckSuiteID: Int
    public let exactThrownError: String
    public let combinedGuardConjuncts: [String]
    public let failedConjunctIdentified: Bool
    public let failingTrialOrdinalEstablished: Bool
    public let sourceStepEqualityEstablished: Bool
    public let sourceStepEqualityDisproved: Bool
    public let globalStepOneEstablished: Bool
    public let globalStepOneDisproved: Bool
    public let selectedTargetCountSixEstablished: Bool
    public let selectedTargetCountSixDisproved: Bool
    public let failingTrialOrdinalMinimum: Int
    public let failingTrialOrdinalMaximum: Int
    public let priorCompletedTrialCountMinimum: Int
    public let priorCompletedTrialCountMaximum: Int
    public let priorCompletedTrialCountEstablished: Bool
    public let failureStage5ReceiptCount: Int
    public let stage5MechanicsExecuted: Bool
    public let originalOneShotConsumed: Bool
    public let originalOneShotExhausted: Bool
    public let originalLauncherMutationAuthorized: Bool
    public let originalLauncherRerunAuthorized: Bool
    public let stage5ResultEstablished: Bool
    public let repeatedTrajectoryDeterminismEstablished: Bool
    public let exactMetalGradientBytesEstablished: Bool
    public let originalLauncher:
        PrimeNativeDecoderStage5ReplacementSourceIdentityV1
    public let originalAssayTest:
        PrimeNativeDecoderStage5ReplacementSourceIdentityV1
    public let originalAssayTestLFByteCount: Int
    public let originalAssayTestMutationAuthorized: Bool
    public let originalAssayTestRerunAuthorized: Bool
    public let stage5RetirementRevision: String
    public let stage5RetirementTree: String
    public let stage5RetirementRunID: Int
    public let stage5RetirementRunNumber: Int
    public let stage5RetirementRunAttempt: Int
    public let stage5RetirementConclusion: String
    public let stage5RetirementStage5InvocationCount: Int
    public let stage5RetirementStage5ReceiptCount: Int
    public let stage5InvocationRetired: Bool
    public let stage5LauncherPreservedForAudit: Bool
    public let stage6AuthorityID: String
    public let stage6AuthorityCanonicalSHA256: String
    public let stage6ObservationID: String
    public let stage6ObservationCanonicalSHA256: String
    public let stage6MechanicsRevision: String
    public let stage6MechanicsTree: String
    public let stage6WorkflowRunID: Int
    public let stage6WorkflowRunNumber: Int
    public let stage6WorkflowRunAttempt: Int
    public let stage6CheckSuiteID: Int
    public let stage6ReceiptSHA256: String
    public let stage6UniqueParameterCount: Int
    public let stage6MLXPeakBytes: UInt64
    public let stage6MemoryCapBytes: UInt64
    public let stage6WorkerElapsedNanoseconds: UInt64
    public let stage6ResourceEnvelopeEstablished: Bool
    public let stage6ResourceClearanceEstablished: Bool
    public let stage6RunnerMemoryCapacityEstablished: Bool
    public let stage6OrdinaryJobFitEstablished: Bool
    public let stage6OneShotConsumed: Bool
    public let stage6RetirementObservedOnCurrentMain: Bool
}

public struct PrimeNativeDecoderStage5ReplacementCurrentSourceBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let decoder: PrimeNativeDecoderStage5ReplacementSourceIdentityV1
    public let training: PrimeNativeDecoderStage5ReplacementSourceIdentityV1
    public let retainedAuthorityTest:
        PrimeNativeDecoderStage5ReplacementSourceIdentityV1
    public let decoderUsesMaintainedEmbeddingByDefault: Bool
    public let defaultTrainingLogitsAPIRemainsTrainingLogitsNoCache: Bool
    public let publicDecoderAPIAdditionAuthorized: Bool
    public let defaultInferenceOrTrainingSemanticChangeAuthorized: Bool
}

public struct PrimeNativeDecoderStage5ReplacementAlgorithmV1:
    Codable,
    Equatable,
    Sendable
{
    public let algorithmID: String
    public let accessLevel: String
    public let optInOnly: Bool
    public let selectorDeclaration: String
    public let orderedSelectorBindings: [
        PrimeNativeDecoderStage5ReplacementSelectorBindingV1
    ]
    public let selectorCases: [String]
    public let selectorRawValues: [String]
    public let sessionSelectorProperty: String
    public let trainerSelectorProperty: String
    public let selectorImmutableAfterInitialization: Bool
    public let existingInitializerDefaultCase: String
    public let newFreshInitializerParameter: String
    public let newRestoredInitializerParameter: String
    public let existingStepMethod: String
    public let existingEvaluateMethod: String
    public let existingStepAndEvaluateBehaviorRemainsGather: Bool
    public let selectorExplicitlyPassedThroughTrainStep: Bool
    public let selectorExplicitlyPassedThroughValueAndGrad: Bool
    public let selectorExplicitlyPassedThroughEvaluate: Bool
    public let selectorExplicitInFreshAndRestoredBConstructors: Bool
    public let readOnlyTrainingInputPathIDProperty: String
    public let allNineBBranchesExposeExpectedReadOnlyPathID: Bool
    public let denseModelMethod: String
    public let denseModelMethodSignature: String
    public let denseModelMethodIsNonthrowing: Bool
    public let embeddingForwardPairMethod: String
    public let embeddingForwardPairMethodSignature: String
    public let embeddingForwardPairMethodIsNonthrowing: Bool
    public let embeddingForwardPairUsesSameModelAndState: Bool
    public let embeddingForwardPairValidatedDenseConstructionCountPerCheck: Int
    public let wholeLogitsValidatedDenseConstructionCountPerForwardCheck: Int
    public let forwardEquivalenceMethod: String
    public let forwardEquivalenceMethodReadOnly: Bool
    public let forwardEquivalenceBoundaries: [String]
    public let sameModelPreMutationEmbeddingForwardPairSeamRequired: Bool
    public let sameModelPreMutationWholeLogitsPairRequired: Bool
    public let tokensMustBeRankTwo: Bool
    public let tokensMustBeInt32: Bool
    public let tokenIDsMustBeWithinVocabularyBounds: Bool
    public let tokenBoundsPredicate: String
    public let checkedVocabularySizeInt32ConversionRequired: Bool
    public let vocabularySizeInt32ConversionExpression: String
    public let tokenBoundsCombinedPredicateExpression: String
    public let tokenBoundsCheckedEvalExpression: String
    public let tokenBoundsSynchronizationExpression: String
    public let tokenBoundsHostReadExpression: String
    public let tokenBoundsCheckedEvalFailureAction: String
    public let tokenBoundsFalseFailureAction: String
    public let tokenBoundsFailureClassification: String
    public let tokenBoundsOperationOrder: [String]
    public let tokenBoundsCheckedEvalCountPerDenseEmbeddingCall: Int
    public let tokenBoundsGPUSynchronizeCountPerDenseEmbeddingCall: Int
    public let tokenBoundsHostBoolItemCountPerDenseEmbeddingCall: Int
    public let tokenBoundsFailureOccursBeforeOneHotConstruction: Bool
    public let batchAndSequenceDimensionsMustBePositive: Bool
    public let sequenceLengthMustNotExceedMaximumSequenceLength: Bool
    public let checkedBatchTimesSequenceMultiplicationRequired: Bool
    public let embeddingWeightDType: String
    public let embeddingWeightExactShapeSymbols: [String]
    public let exactIntermediateShapeChecksRequired: Bool
    public let dependencySourceBindingsClaimDeterminism: Bool
    public let forwardAndReplayExactnessRemainEmpirical: Bool
    public let tokenRank: Int
    public let tokenDType: String
    public let inputShapeSymbols: [String]
    public let flattenedTokensExpression: String
    public let flattenedTokensShapeSymbols: [String]
    public let vocabularyExpression: String
    public let vocabularyShapeSymbols: [String]
    public let oneHotExpression: String
    public let oneHotDType: String
    public let oneHotShapeSymbols: [String]
    public let embeddingExpression: String
    public let embeddingShapeSymbols: [String]
    public let restoredEmbeddingShapeSymbols: [String]
    public let unchangedSuccessorOperations: [String]
    public let tinyBatchSize: Int
    public let tinySequenceLength: Int
    public let tinyVocabularySize: Int
    public let tinyOneHotElementCount: Int
    public let tinyOneHotByteCount: Int
    public let native300CompatibilityBatchSize: Int
    public let native300CompatibilitySequenceLength: Int
    public let native300CompatibilityVocabularySize: Int
    public let native300CompatibilityOneHotElementCount: Int
    public let native300CompatibilityOneHotByteCount: Int
    public let usesSingleFlattenedTwoDimensionalMatmul: Bool
    public let usesBatchedBroadcastMatmul: Bool
    public let usesGatherForInputEmbedding: Bool
    public let usesScatterAddForInputEmbeddingWeightVJPByConstruction: Bool
    public let maintainedGatherImplementationChanged: Bool
    public let tiedOutputProjectionChanged: Bool
    public let checkedExactEmbeddingForwardEquivalenceRequired: Bool
    public let checkedExactWholeLogitsForwardEquivalenceRequired: Bool
}

public struct PrimeNativeDecoderStage5ReplacementAssayV1:
    Codable,
    Equatable,
    Sendable
{
    public let stageID: String
    public let objective: String
    public let fixtureVocabularySize: Int
    public let fixtureWidth: Int
    public let fixtureLayerCount: Int
    public let initializationSeed: Int
    public let expectedParameterCount: Int
    public let expectedParameterTensorCount: Int
    public let batchSize: Int
    public let sequenceLength: Int
    public let repeatedTokenIDs: [Int]
    public let expectedSourceSelectedTargetCount: Int
    public let expectedSuccessorSelectedTargetCount: Int
    public let trialCount: Int
    public let branchNames: [String]
    public let fullTrajectoryBranchCount: Int
    public let sameProcessRequired: Bool
    public let sameRetainedMetalDeviceRequired: Bool
    public let leaseAcquiredBeforeCoreGraphicsMetalOrMLX: Bool
    public let exactArmExecutionOrder: [String]
    public let armAName: String
    public let armAAPI: String
    public let armADiagnosticOnly: Bool
    public let armACanGateClearance: Bool
    public let armACompletedTrialCount: Int
    public let armAIndependentSourceStepDiagnosticPairCount: Int
    public let armAPairBranchNames: [String]
    public let armASourceStepEqualityDisaggregated: Bool
    public let armAGlobalStepOneDisaggregated: Bool
    public let armASelectedTargetCountDisaggregated: Bool
    public let armAFirstTensorMismatchCoordinateRecorded: Bool
    public let armAFirstScalarMismatchCoordinateRecorded: Bool
    public let armARestoreBranchRequired: Bool
    public let armAMeasuredMismatchThrows: Bool
    public let armAInfrastructureFailureIsInvalidInfrastructure: Bool
    public let armAMeasuredMismatchSkipsArmB: Bool
    public let armARecordsFirstMismatchWithoutThrowing: Bool
    public let armBName: String
    public let armBAPI: String
    public let armBOptInOnly: Bool
    public let armBFullTrialCount: Int
    public let armBFullTrajectoryBranchCount: Int
    public let armBExpectedReadOnlySelectorID: String
    public let armBFreshConstructor: String
    public let armBRestoreConstructor: String
    public let armBValidMeasurementCompletesFullPlanBeforeTerminalReceipt: Bool
    public let sourceStepComparisonsDisaggregated: Bool
    public let noCombinedGuardPermitted: Bool
    public let continueAfterMeasuredMismatch: Bool
    public let armBReplayExactComparisonDomains: [String]
    public let forwardEquivalenceComparisonDomains: [String]
    public let deterministicFirstMismatchComparisonDomainOrder: [String]
    public let crossTrialExactComparisonRequired: Bool
    public let inMemorySnapshotOnly: Bool
    public let durableCheckpointIOAuthorized: Bool
    public let artifactRetentionAuthorized: Bool
}

public struct PrimeNativeDecoderStage5ReplacementReceiptContractV1:
    Codable,
    Equatable,
    Sendable
{
    public let receiptID: String
    public let linePrefix: String
    public let schemaVersion: Int
    public let authorityIDBinding: String
    public let authorityCanonicalSHA256Binding: String
    public let runtimeAuthorityCanonicalSHA256ResolvesTo64LowerHex: Bool
    public let runtimeAuthorityCanonicalSHA256MayEqualSymbolLiteral: Bool
    public let terminalGreenStatuses: [String]
    public let passStatus: String
    public let measuredMismatchStatus: String
    public let gatingComparisonFields: [String]
    public let passPredicate: String
    public let measuredMismatchPredicate: String
    public let canonicalSortedJSONRequired: Bool
    public let withoutEscapingSlashesRequired: Bool
    public let encodeDecodeReencodeIdentityRequired: Bool
    public let exactlyOneTerminalReceiptLineRequired: Bool
    public let lineFeedTerminatorRequired: Bool
    public let emittedWhileLeaseHeld: Bool
    public let flushBeforeLeaseReleaseRequired: Bool
    public let passRequiresAllArmBExactComparisons: Bool
    public let passRequiresAllForwardEquivalenceChecks: Bool
    public let armAOutcomeCanChangeTerminalStatus: Bool
    public let measuredMismatchRequiresValidCompletedMeasurement: Bool
    public let measuredMismatchReportsFirstMismatchCoordinates: Bool
    public let measuredMismatchIsGreenMeasuredOutcome: Bool
    public let passFirstMismatchMustBeNull: Bool
    public let measuredMismatchFirstMismatchMustBeNonNull: Bool
    public let measuredMismatchRequiresAtLeastOneGatingComparisonFalse: Bool
    public let firstMismatchCanIdentifyForwardBoundary: Bool
    public let tensorMismatchRequiresShapeDTypeByteOffsetAndSHAs: Bool
    public let scalarMismatchRequiresReferenceAndObservedFloat32Bits: Bool
    public let forwardMismatchRequiresForwardBoundary: Bool
    public let nonApplicableMismatchFieldsMustBeNull: Bool
    public let firstMismatchDeterministicSelectionOrder: [String]
    public let armAMismatchMayPopulateBFirstMismatch: Bool
    public let invalidInfrastructureClassifications: [String]
    public let invalidInfrastructureEmitsTerminalResult: Bool
    public let invalidInfrastructureExitsNonzero: Bool
    public let requiredTopLevelKeys: [String]
    public let requiredAuthorityKeys: [String]
    public let requiredExecutionKeys: [String]
    public let requiredEnvironmentKeys: [String]
    public let requiredArmAOutcomeKeys: [String]
    public let requiredArmBOutcomeKeys: [String]
    public let requiredFirstMismatchCoordinateKeys: [String]
    public let requiredForwardEquivalenceKeys: [String]
    public let requiredOperationCountKeys: [String]
    public let requiredCeilingKeys: [String]
    public let greenOutcomeTrueCeilingKeys: [String]
    public let passOnlyTrueCeilingKeys: [String]
    public let alwaysFalseCeilingKeys: [String]
    public let alwaysTrueResourceGuardCeilingKeys: [String]
    public let firstMismatchCoordinateNullableIffNoMismatch: Bool
    public let requiredBSelectorIDCount: Int
    public let requiredBSelectorIDValue: String
    public let requiredArmBFreshConstructorValue: String
    public let requiredArmBRestoreConstructorValue: String
    public let requiredForwardEquivalenceBoundaryNames: [String]
    public let requiredArmATrialCount: Int
    public let requiredArmBSelectorBranchCount: Int
    public let requiredArmBTrialCount: Int
    public let requiredArmBTrajectoryBranchCount: Int
    public let expectedArmASourceStepCount: Int
    public let expectedArmBTrainingStepCount: Int
    public let expectedArmBSnapshotCount: Int
    public let expectedArmBRestoreCount: Int
    public let expectedArmBEvaluateCount: Int
    public let expectedArmBForwardEquivalenceCheckCount: Int
    public let expectedArmBDenseWholeLogitsCallCount: Int
    public let expectedArmBInputEmbeddingPairSeamCount: Int
    public let expectedArmBDenseEmbeddingConstructionCount: Int
    public let expectedArmBTokenBoundsValidationCount: Int
    public let expectedArmBTokenBoundsCheckedEvalCount: Int
    public let expectedArmBTokenBoundsGPUSynchronizeCount: Int
    public let expectedArmBTokenBoundsHostBoolItemCount: Int
    public let synchronizeCountMustMatchComparedArrayAndForwardCheckPlan: Bool
    public let artifactUploadCount: Int
    public let rerunCount: Int
    public let retryCount: Int
}

public struct PrimeNativeDecoderStage5ReplacementAuthorityClosureScopeV1:
    Codable,
    Equatable,
    Sendable
{
    public let exactChangedPaths: [String]
    public let expectedRootTestCount: Int
    public let expectedIsolatedGroupTestCounts: [Int]
    public let expectedIsolatedTestCount: Int
    public let expectedFocusedWholeTestCount: Int
    public let expectedMetalTestCount: Int
    public let expectedMaintainedRuntimeTestCount: Int
    public let expectedTokenizerTestCount: Int
    public let expectedTotalTestCount: Int
    public let exactLiveOrder: [String]
    public let originalStage5LauncherInvocationCount: Int
    public let replacementStage5LauncherInvocationCount: Int
    public let stage6LauncherInvocationCount: Int
    public let artifactCount: Int
    public let authorityOnlyNoMetalOrMLX: Bool
}

public struct PrimeNativeDecoderStage5ReplacementSuccessorScopeV1:
    Codable,
    Equatable,
    Sendable
{
    public let exactChangedPaths: [String]
    public let newLauncherPath: String
    public let newCurrentDecoderIdentityObservationSourcePath: String
    public let newCurrentDecoderIdentityObservationTestPath: String
    public let decoderSourcePath: String
    public let trainingSourcePath: String
    public let retainedAuthorityTestPath: String
    public let newAssayTestPath: String
    public let newAssayTestClass: String
    public let newAssayTestMethod: String
    public let newAssayTestFilter: String
    public let expectedRootTestCount: Int
    public let expectedIsolatedGroupTestCounts: [Int]
    public let expectedIsolatedTestCount: Int
    public let expectedFocusedWholeTestCount: Int
    public let expectedMetalTestCount: Int
    public let expectedMaintainedRuntimeTestCount: Int
    public let expectedTokenizerTestCount: Int
    public let expectedPreReplacementTestCount: Int
    public let expectedReplacementTestCount: Int
    public let expectedTotalTestCount: Int
    public let exactLiveOrder: [String]
    public let replacementLauncherInvocationCount: Int
    public let replacementBuildCount: Int
    public let replacementDirectXCTestCount: Int
    public let replacementReceiptCount: Int
    public let originalLauncherInvocationCount: Int
    public let stage6LauncherInvocationCount: Int
    public let exactMainExecutionOpportunityCount: Int
    public let manifestMutationAuthorized: Bool
    public let packageLockMutationAuthorized: Bool
    public let originalStage5LauncherMutationAuthorized: Bool
    public let defaultGatherPathMutationAuthorized: Bool
    public let decoderSourceMutationAuthorized: Bool
    public let decoderSourceMutationScope: String
    public let trainingSourceMutationAuthorized: Bool
    public let trainingSourceMutationScope: String
    public let otherProductionSourceMutationAuthorized: Bool
    public let newPackageOnlyOptInPathAuthorized: Bool
    public let retainedAuthorityTestMutationAuthorized: Bool
    public let retainedAuthorityTestPermittedMutation: String
    public let retainedAuthorityTestClass: String
    public let retainedAuthorityTestImports: [String]
    public let retainedAuthorityTestMethodNames: [String]
    public let retainedAuthorityTestMethodCount: Int
    public let retainedHistoricalMetalRepairGitBlob: String
    public let retainedHistoricalMetalRepairByteCount: Int
    public let retainedHistoricalMetalRepairSHA256: String
    public let retainedGitBlobOIDOccurrenceCount: Int
    public let retainedCryptoKitSHA1FramingOccurrenceCount: Int
    public let retainedAllOtherAssertionsByteSemanticallyPreserved: Bool
    public let newCurrentIdentityObservationAuthorized: Bool
}

public struct PrimeNativeDecoderStage5ReplacementOutcomeTransitionsV1:
    Codable,
    Equatable,
    Sendable
{
    public let passClearanceEstablishesStage5Result: Bool
    public let passClearanceEstablishesStage5MechanicsSuccess: Bool
    public let passClearanceEstablishesStage5AssayClearance: Bool
    public let passClearanceEstablishesRepeatedSameDeviceBPathDeterminism: Bool
    public let passClearanceEstablishesExactSameDeviceBPathGradientBytes: Bool
    public let passClearanceEstablishesDefaultGatherDeterminism: Bool
    public let passClearanceEstablishesArbitraryTokenDeterminism: Bool
    public let passClearanceEstablishesCrossDeviceDeterminism: Bool
    public let measuredMismatchEstablishesStage5Result: Bool
    public let measuredMismatchEstablishesStage5MechanicsSuccess: Bool
    public let measuredMismatchEstablishesStage5Clearance: Bool
    public let measuredMismatchPermitsRerun: Bool
    public let eitherGreenOutcomeConsumesOneShot: Bool
    public let invalidInfrastructureConsumesExactMainOpportunity: Bool
    public let invalidInfrastructureEstablishesStage5Result: Bool
    public let successorObservationRequiredAfterAnyTerminalGreenOutcome: Bool
    public let stage7AuthorizedByPassClearance: Bool
    public let stage7RequiresNewBSpecificNative300ResourceWitness: Bool
    public let stage7RequiresSeparateAuthorityAfterWitness: Bool
}

public struct PrimeNativeDecoderStage5ReplacementAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let replacementMechanicsImplementationAuthorizedAfterGreenClosure: Bool
    public let oneExactMainReplacementExecutionAuthorizedAfterGreenClosure: Bool
    public let authorityClosureExecutedReplacement: Bool
    public let authorityClosureObservedMLX: Bool
    public let authorityClosureEstablishedStage5Result: Bool
    public let authorityClosureEstablishedStage5Clearance: Bool
    public let authorityClosureEstablishedRepeatedTrajectoryDeterminism: Bool
    public let authorityClosureEstablishedExactMetalGradientBytes: Bool
    public let defaultGatherDeterminismEstablished: Bool
    public let arbitraryTokenDeterminismEstablished: Bool
    public let crossDeviceDeterminismEstablished: Bool
    public let originalFailedRunReinterpreted: Bool
    public let originalLauncherRecoveryAuthorized: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
    public let durableCheckpointIOAuthorized: Bool
    public let retainedArtifactAuthorized: Bool
    public let broadNative300TrainingAuthorized: Bool
    public let stage6ResourceClearanceRemainsHistorical: Bool
    public let stage6HistoricalResourceClearanceAppliesToBPath: Bool
    public let bSpecificNative300ResourceWitnessAuthorized: Bool
    public let bSpecificNative300ResourceWitnessRequiresSeparateAuthority: Bool
    public let bSpecificNative300ResourceWitnessEstablished: Bool
    public let stage7AuthorityEstablished: Bool
    public let stage7Authorized: Bool
    public let candidateAdmissionGranted: Bool
    public let modelQualityEstablished: Bool
    public let canaryAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Pure, append-only authority for one separately named exact-main Stage-5
/// replacement assay. The consumed gather-path run remains an ambiguous
/// terminal failure and its launcher remains frozen. Arm A remeasures that
/// maintained path for diagnosis only. Arm B is an opt-in package-only input
/// embedding path whose flattened Float32 one-hot matrix is multiplied by the
/// embedding weight in one two-dimensional matmul before the unchanged decoder
/// layers, final norm, and tied output projection.
///
/// A valid completed assay always produces one canonical green receipt:
/// `PASS_CLEARANCE` when every Arm-B and forward-equivalence comparison is
/// exact, or `MEASURED_EXACT_MISMATCH` otherwise. Infrastructure drift is red
/// and produces no result. Even `PASS_CLEARANCE` is scoped only to the tiny,
/// repeated-token, same-device Arm-B path. Stage 7 remains false until a new
/// Arm-B-specific native-300M resource witness and a separate authority exist.
public struct
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let currentMain: PrimeNativeDecoderStage5ReplacementCurrentMainV1
    public let predecessor: PrimeNativeDecoderStage5ReplacementPredecessorV1
    public let inheritedOriginalEnvironment:
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryEnvironmentV1
    public let inheritedOriginalFixture:
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryFixtureV1
    public let inheritedOriginalAssayTopology:
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryAssayV1
    public let inheritedOriginalEquality:
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryEqualityV1
    public let replacementInheritsOriginalEnvironmentExactly: Bool
    public let replacementInheritsOriginalFixtureExactly: Bool
    public let replacementInheritsOriginalFreshnessAndBranchTopologyExactly:
        Bool
    public let replacementInheritsOriginalEqualityExactly: Bool
    public let originalReceiptAndTestIdentifiersReplaced: Bool
    public let currentSources:
        PrimeNativeDecoderStage5ReplacementCurrentSourceBoundaryV1
    public let externalSourceBindings: [
        PrimeNativeDecoderStage5ReplacementExternalSourceBindingV1
    ]
    public let inheritedExecutionSupportAuthorityID: String
    public let inheritedExecutionSupportBindings: [
        PrimeNativeDecoderStage5ReplacementExternalSourceBindingV1
    ]
    public let inheritedExecutionSupportBindingsExcludedFromArmABindingUnion:
        Bool
    public let armAExternalBindingKeys: [String]
    public let armBExternalBindingKeys: [String]
    public let exactExternalBindingOverlapKeys: [String]
    public let exactExternalBindingOverlapPaths: [String]
    public let algorithm: PrimeNativeDecoderStage5ReplacementAlgorithmV1
    public let assay: PrimeNativeDecoderStage5ReplacementAssayV1
    public let receipt: PrimeNativeDecoderStage5ReplacementReceiptContractV1
    public let authorityClosureScope:
        PrimeNativeDecoderStage5ReplacementAuthorityClosureScopeV1
    public let successorScope:
        PrimeNativeDecoderStage5ReplacementSuccessorScopeV1
    public let outcomeTransitions:
        PrimeNativeDecoderStage5ReplacementOutcomeTransitionsV1
    public let authorityCeiling:
        PrimeNativeDecoderStage5ReplacementAuthorityCeilingV1
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalSHA256 =
        "e0b1fadf4075765078ba3cf29e7cce85be930791651020d45cba1b5b91466252"

    public static let frozenV1: Self = {
        func source(
            _ path: String,
            _ mode: String,
            _ blob: String,
            _ bytes: Int,
            _ sha256: String,
            _ role: String
        ) -> PrimeNativeDecoderStage5ReplacementSourceIdentityV1 {
            .init(
                path: path,
                gitMode: mode,
                gitBlob: blob,
                byteCount: bytes,
                sha256: sha256,
                role: role)
        }

        let authorityID =
            "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_authority_v1"
        let newLauncher =
            ".github/scripts/prime-ci-native-decoder-stage5-repeated-trajectory-replacement.sh"
        let identityObservationSource =
            "Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift"
        let identityObservationTest =
            "Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift"
        let decoderSource =
            "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift"
        let trainingSource =
            "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift"
        let retainedAuthorityTest =
            "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift"
        let assayTest =
            "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift"
        let assayTestClass =
            "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests"
        let assayTestMethod =
            "testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume"

        return Self(
            schemaVersion: 1,
            authorityID: authorityID,
            authorityKind:
                "separate_one_shot_stage5_ab_replacement_execution_authority",
            currentMain: .init(
                repository: "Ergentics/ergentics-prime",
                ref: "refs/heads/main",
                mergeRevision:
                    "54635d6b58e4f9c7ddedb30a3c22fffb17d8e174",
                mergeTree:
                    "afd51da78370aee8851341fe46b2533450944b2f",
                orderedParentRevisions: [
                    "437acb46a5af63f6c604e5f5c50f3b63eaa296f2",
                    "03d31f5cc3acfddd338fd06dea5a14aa0bc10677",
                ],
                pullRequestNumber: 108,
                workflowRunID: 31_793_069_525,
                workflowRunNumber: 113,
                workflowRunAttempt: 1,
                checkSuiteID: 86_250_730_227,
                activeRootJobID: 94_744_094_754,
                reviewedMainJobID: 94_744_877_958,
                status: "completed",
                conclusion: "success",
                previousAttemptURLWasNull: true,
                rerunCount: 0,
                artifactCount: 0,
                activeRootJobStepCount: 7,
                activeRootSuccessfulStepCount: 7,
                reviewedMainJobStepCount: 7,
                reviewedMainSuccessfulStepCount: 7,
                rootTestCount: 56,
                isolatedGroupTestCounts: [1, 1, 2, 2],
                isolatedTestCount: 6,
                focusedWholeTestCount: 62,
                metalTestCount: 44,
                maintainedRuntimeTestCount: 1,
                tokenizerTestCount: 1,
                totalTestCount: 108,
                stage5LauncherInvocationCount: 0,
                stage5ReceiptCount: 0,
                stage6LauncherInvocationCount: 0,
                stage6ReceiptCount: 0,
                exactChangedSources: [
                    source(
                        ".github/scripts/prime-ci-active-root-quarantine.sh",
                        "100755",
                        "acf57af123abeb8e7e00b9cba190aaf9e3524db5",
                        678_233,
                        "b61dd2b8f05cafbb230ed27fdbd07bfc2a0d511be15f2e1690b680fc3346d261",
                        "stage6_retirement_active_gate"),
                    source(
                        ".github/workflows/prime-active-root-quarantine.yml",
                        "100644",
                        "d73871ff049d9a1be36ba2a26ab1075cb91e2fb4",
                        80_463,
                        "ed406d472ff1ae352ef84accc54bc23ec9e63fe1a184e34be7aaf0f99e16b9da",
                        "stage6_retirement_workflow"),
                    source(
                        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                        "100644",
                        "29ee5012a771afbc8eb369ef93c1d5b676342b69",
                        546,
                        "6bb421dae14a46992b6e95c784e83b29e2c354c549ada927ccedf8e71534c155",
                        "stage6_retirement_embedded_provenance"),
                    source(
                        "Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservation.swift",
                        "100644",
                        "f2b688b5c073a71d4179a75f0ced9651ac696025",
                        69_114,
                        "e3927b4ce209662466bd014b6112da733f0fe816006b7722792f9c61f6aad3ad",
                        "stage6_pass_observation_preserved_during_retirement"),
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationTests.swift",
                        "100644",
                        "075a07a0ff9577a9b9c6f9824d2c632db2fe78bf",
                        28_383,
                        "79bed57c8d2461a56e9bec335ba6869d0981fc5daa32f85845f4835efc8736d5",
                        "stage6_pass_observation_retirement_contract_test"),
                ],
                exactMainSealed: true),
            predecessor: .init(
                designAuthorityID:
                    "ergentics_prime_native_decoder_trajectory_exact_resume_design_authority_v1",
                designAuthorityCanonicalSHA256:
                    "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
                originalStage5AuthorityID:
                    "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_authority_v1",
                originalStage5AuthorityCanonicalSHA256:
                    "00c49e63315b2aacb439204e778f54bcf63c2fdf643282f3bd64e2b3b4094089",
                immediateRepairAuthorityID:
                    "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_exact_main_swift_numerics_resolution_repair_authority_v1",
                immediateRepairAuthorityCanonicalSHA256:
                    "a5a8e5300ea8413e738fddd4b8fed930dcc9983d5a29eea102862f9744b50fff",
                failureObservationID:
                    "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_execution_failure_observation_v1",
                failureObservationCanonicalSHA256:
                    "ac735b84948e6b9b6b492a79925d7e0770d6eb332ba4d643d7f2884a4a7f81d2",
                failureMechanicsRevision:
                    "8bdf6abe15d7f9a83045a3f9ee21fcc28f7ee91d",
                failureMechanicsTree:
                    "f7dbc81e4f7e8ccebdf39f0fb5200a7780be91dc",
                failureWorkflowRunID: 31_756_331_438,
                failureWorkflowRunNumber: 105,
                failureWorkflowRunAttempt: 1,
                failureCheckSuiteID: 86_154_359_326,
                exactThrownError:
                    "contractDrift(\"source-step exact bytes\")",
                combinedGuardConjuncts: [
                    "uninterruptedSourceStep == sourceSnapshotSourceStep",
                    "uninterruptedSourceStep.result.globalStep == 1",
                    "uninterruptedSourceStep.result.selectedTargetCount == 6",
                ],
                failedConjunctIdentified: false,
                failingTrialOrdinalEstablished: false,
                sourceStepEqualityEstablished: false,
                sourceStepEqualityDisproved: false,
                globalStepOneEstablished: false,
                globalStepOneDisproved: false,
                selectedTargetCountSixEstablished: false,
                selectedTargetCountSixDisproved: false,
                failingTrialOrdinalMinimum: 1,
                failingTrialOrdinalMaximum: 3,
                priorCompletedTrialCountMinimum: 0,
                priorCompletedTrialCountMaximum: 2,
                priorCompletedTrialCountEstablished: false,
                failureStage5ReceiptCount: 0,
                stage5MechanicsExecuted: true,
                originalOneShotConsumed: true,
                originalOneShotExhausted: true,
                originalLauncherMutationAuthorized: false,
                originalLauncherRerunAuthorized: false,
                stage5ResultEstablished: false,
                repeatedTrajectoryDeterminismEstablished: false,
                exactMetalGradientBytesEstablished: false,
                originalLauncher: source(
                    ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh",
                    "100755",
                    "6547ee06663c1ea409a6256e48f6111245056020",
                    48_869,
                    "c639cfcb4d1d0a103b285ed38849565f16b00932fc3b9d921febbf798c30d5f9",
                    "consumed_launcher_preserved_for_audit_only"),
                originalAssayTest: source(
                    "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
                    "100644",
                    "46f91f32e91870d21c46cd318972a857b8ef6e12",
                    28_292,
                    "50b19a0bfe8752d2b80c09527b70731d906e8064c8e2d49a758c8c48b48f4398",
                    "consumed_assay_test_preserved_for_audit_only"),
                originalAssayTestLFByteCount: 606,
                originalAssayTestMutationAuthorized: false,
                originalAssayTestRerunAuthorized: false,
                stage5RetirementRevision:
                    "f5a9638194c53922f09c39c3c76095b5cc47c25e",
                stage5RetirementTree:
                    "a17a8f92604157c0de0252dbc30cf22681d6a13d",
                stage5RetirementRunID: 31_763_253_701,
                stage5RetirementRunNumber: 107,
                stage5RetirementRunAttempt: 1,
                stage5RetirementConclusion: "success",
                stage5RetirementStage5InvocationCount: 0,
                stage5RetirementStage5ReceiptCount: 0,
                stage5InvocationRetired: true,
                stage5LauncherPreservedForAudit: true,
                stage6AuthorityID:
                    "prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1",
                stage6AuthorityCanonicalSHA256:
                    PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                        .canonicalSHA256,
                stage6ObservationID:
                    "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_execution_observation_v1",
                stage6ObservationCanonicalSHA256:
                    PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationV1
                        .canonicalSHA256,
                stage6MechanicsRevision:
                    "437acb46a5af63f6c604e5f5c50f3b63eaa296f2",
                stage6MechanicsTree:
                    "f87272ed850cd2ac1898bd6c5d4cbefd2c664bb0",
                stage6WorkflowRunID: 31_784_730_175,
                stage6WorkflowRunNumber: 111,
                stage6WorkflowRunAttempt: 1,
                stage6CheckSuiteID: 86_228_325_084,
                stage6ReceiptSHA256:
                    "104f3579f2caf19f27cbbe694f8a854cc8927d9188af055075c11b1fe1c94c55",
                stage6UniqueParameterCount: 271_107_072,
                stage6MLXPeakBytes: 4_781_317_844,
                stage6MemoryCapBytes: 5_010_800_640,
                stage6WorkerElapsedNanoseconds: 33_519_059_708,
                stage6ResourceEnvelopeEstablished: true,
                stage6ResourceClearanceEstablished: true,
                stage6RunnerMemoryCapacityEstablished: true,
                stage6OrdinaryJobFitEstablished: false,
                stage6OneShotConsumed: true,
                stage6RetirementObservedOnCurrentMain: true),
            inheritedOriginalEnvironment:
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1
                    .frozenV1.environment,
            inheritedOriginalFixture:
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1
                    .frozenV1.fixture,
            inheritedOriginalAssayTopology:
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1
                    .frozenV1.assay,
            inheritedOriginalEquality:
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1
                    .frozenV1.equality,
            replacementInheritsOriginalEnvironmentExactly: true,
            replacementInheritsOriginalFixtureExactly: true,
            replacementInheritsOriginalFreshnessAndBranchTopologyExactly:
                true,
            replacementInheritsOriginalEqualityExactly: true,
            originalReceiptAndTestIdentifiersReplaced: true,
            currentSources: .init(
                decoder: source(
                    decoderSource,
                    "100644",
                    "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f",
                    39_598,
                    "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
                    "current_decoder_before_opt_in_successor"),
                training: source(
                    trainingSource,
                    "100644",
                    "271b7fe4a856a76a00730954c23bdca3b33e761d",
                    86_387,
                    "f49b946e5272992f09ecf7b1dd8439bda15c5ac696a4f6298bafa19994f2b4c2",
                    "current_stage5_training_mechanics_before_successor"),
                retainedAuthorityTest: source(
                    retainedAuthorityTest,
                    "100644",
                    "329e57a8cbb2aa55879a94c88b17c391d13a1eb4",
                    35_548,
                    "40c65bd0169ed5af08248acb38b5b287a82894fec8e8f2c2808f348e3cd50373",
                    "current_decoder_identity_assertions_before_successor"),
                decoderUsesMaintainedEmbeddingByDefault: true,
                defaultTrainingLogitsAPIRemainsTrainingLogitsNoCache: true,
                publicDecoderAPIAdditionAuthorized: false,
                defaultInferenceOrTrainingSemanticChangeAuthorized: false),
            externalSourceBindings: [
                .init(
                    repository: "Ergentics/ergentics-mlx-swift",
                    revision:
                        "d37885a278f1c37484a94d0f401a418735e66519",
                    path: "Source/MLX/Factory.swift",
                    gitMode: "100644",
                    gitBlob: "913540511292660716688dbf73e8375d0683b48b",
                    byteCount: 40_780,
                    sha256:
                        "27161deb4b2207d8806e5ac629c8ae2b0d374579169822e37810bb365383331a",
                    claimScope:
                        "arange_dtype_overload_for_flattened_vocabulary"),
                .init(
                    repository: "Ergentics/ergentics-mlx-swift",
                    revision:
                        "d37885a278f1c37484a94d0f401a418735e66519",
                    path: "Source/MLX/MLXArray+Indexing.swift",
                    gitMode: "100644",
                    gitBlob: "9a891b5df0d6f2bdeb0df584497c2c068b65a4e9",
                    byteCount: 49_556,
                    sha256:
                        "bde9521ff694e054f05c414442df77e7bcd816c9ee8929f538d9c2bd22d3f4fa",
                    claimScope: "array_indexing_routes_array_indices_to_mlx_gather"),
                .init(
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
                        "c_api_routing_for_all_arange_astype_equal_greater_equal_less_logical_and_matmul_reshape"),
                .init(
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
                        "float32_astype_and_bool_item_host_read_for_bounds_and_explicit_one_hot"),
                .init(
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
                        "maintained_gather_weight_and_tied_aslinear_baseline"),
                .init(
                    repository: "ml-explore/mlx",
                    revision:
                        "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                    path: "mlx/ops.cpp",
                    gitMode: "100644",
                    gitBlob: "e6554c2c4ffb198d993b98f06941647118e3c97e",
                    byteCount: 188_014,
                    sha256:
                        "3952048eb504d51f5028f261aecf47cfcb50cf18a4958fb7946c1eba1b03afc2",
                    claimScope:
                        "matmul_and_equal_greater_equal_less_logical_and_all_construction_with_explicit_two_dimensional_operands"),
                .init(
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
                        "matmul_rhs_vjp_is_transposed_lhs_times_cotangent_and_historical_gather_vjp_uses_scatter_add"),
                .init(
                    repository: "ml-explore/mlx",
                    revision:
                        "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                    path: "mlx/backend/metal/kernels/indexing/scatter.h",
                    gitMode: "100644",
                    gitBlob: "f0217b3369f2c87c826a963ba900773d3b59bc91",
                    byteCount: 1_791,
                    sha256:
                        "6d6d81912ce7d6b896eb0225d1ac6885d30cd30213b67d996d3efc03f4a3c292",
                    claimScope: "metal_general_scatter_uses_atomic_output_updates"),
                .init(
                    repository: "ml-explore/mlx",
                    revision:
                        "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                    path: "mlx/backend/metal/matmul.cpp",
                    gitMode: "100644",
                    gitBlob: "84b6ee06da379ceb73b9c3b555adbda6af0c6322",
                    byteCount: 84_257,
                    sha256:
                        "4bef524645dce8feb94300766dec1586caf93c0167fe9757409fb452c15b1361",
                    claimScope:
                        "metal_matmul_dispatch_only_not_determinism_evidence"),
                .init(
                    repository: "Ergentics/ergentics-mlx-swift",
                    revision:
                        "d37885a278f1c37484a94d0f401a418735e66519",
                    path: "Source/MLX/MLXArray+Ops.swift",
                    gitMode: "100644",
                    gitBlob: "4d950f3da8350df9c3b01af2513f75c15ae3c289",
                    byteCount: 100_938,
                    sha256:
                        "143dddcf954dd6b9f6854ffa23a0600fa1559564ef857fd3cb98cf822b41abf6",
                    claimScope:
                        "reshape_integer_equal_gte_lt_logical_and_all_for_bounds_and_explicit_one_hot"),
                .init(
                    repository: "Ergentics/ergentics-mlx-swift",
                    revision:
                        "d37885a278f1c37484a94d0f401a418735e66519",
                    path: "Source/MLX/Ops+Array.swift",
                    gitMode: "100644",
                    gitBlob: "b0b0ddbdb8fa7b1ce95dc92452cece460bf64f79",
                    byteCount: 59_664,
                    sha256:
                        "821e38aaa144cd19b0a1ae05fbddab8fdf5277d150635445cab6d40d5761ddef",
                    claimScope:
                        "swift_matmul_routes_explicit_two_dimensional_operands"),
            ],
            inheritedExecutionSupportAuthorityID:
                "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_authority_v1",
            inheritedExecutionSupportBindings: [
                .init(
                    repository: "Ergentics/ergentics-mlx-swift",
                    revision:
                        "d37885a278f1c37484a94d0f401a418735e66519",
                    path: "Source/MLX/Transforms+Eval.swift",
                    gitMode: "100644",
                    gitBlob: "46fe9c593099c0b939d1d85a68f37023a6dacc24",
                    byteCount: 5_256,
                    sha256:
                        "14b867c903be78547b426305257ca70e214b7b854acf1c0dc2cf7c82333f4999",
                    claimScope: "inherited_checked_eval_execution_support"),
                .init(
                    repository: "Ergentics/ergentics-mlx-swift",
                    revision:
                        "d37885a278f1c37484a94d0f401a418735e66519",
                    path: "Source/MLX/Stream.swift",
                    gitMode: "100644",
                    gitBlob: "c276d6dec11553eafb25988ed552aaf6f6b299a1",
                    byteCount: 4_612,
                    sha256:
                        "03b4e08befc3bbe926e21b402989b1a1411050bde900dbfac5d3f6b777183f8f",
                    claimScope:
                        "inherited_explicit_default_gpu_stream_synchronization_support"),
            ],
            inheritedExecutionSupportBindingsExcludedFromArmABindingUnion:
                true,
            armAExternalBindingKeys: [
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/MLXArray+Indexing.swift",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLXNN/Embedding.swift",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/backend/metal/kernels/indexing/scatter.h",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/primitives.cpp",
            ],
            armBExternalBindingKeys: [
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/Factory.swift",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/MLXArray+Ops.swift",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/MLXArray.swift",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLX/Ops+Array.swift",
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLXNN/Embedding.swift",
                "ml-explore/mlx-c@0726ca922fc902c4c61ef9c27d94132be418e945:mlx/c/ops.cpp",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/backend/metal/matmul.cpp",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/ops.cpp",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/primitives.cpp",
            ],
            exactExternalBindingOverlapKeys: [
                "Ergentics/ergentics-mlx-swift@d37885a278f1c37484a94d0f401a418735e66519:Source/MLXNN/Embedding.swift",
                "ml-explore/mlx@ce45c52505c8158ea48d2a54e8caae05efd86bfe:mlx/primitives.cpp",
            ],
            exactExternalBindingOverlapPaths: [
                "Source/MLXNN/Embedding.swift", "mlx/primitives.cpp",
            ],
            algorithm: .init(
                algorithmID:
                    "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1",
                accessLevel: "package",
                optInOnly: true,
                selectorDeclaration:
                    "PrimeNativeDecoderTinyMetalTrajectoryTrainingInputPathV1: String",
                orderedSelectorBindings: [
                    .init(
                        caseName: "maintainedGatherV1",
                        rawValue: "maintained_gather_v1"),
                    .init(
                        caseName: "denseOneHotMatmulV1",
                        rawValue:
                            "flattened_dense_one_hot_matmul_input_embedding_v1"),
                ],
                selectorCases: [
                    "maintainedGatherV1", "denseOneHotMatmulV1",
                ],
                selectorRawValues: [
                    "maintained_gather_v1",
                    "flattened_dense_one_hot_matmul_input_embedding_v1",
                ],
                sessionSelectorProperty:
                    "stage5ReplacementTrainingInputPath",
                trainerSelectorProperty:
                    "stage5ReplacementTrainingInputPath",
                selectorImmutableAfterInitialization: true,
                existingInitializerDefaultCase: "maintainedGatherV1",
                newFreshInitializerParameter:
                    "stage5ReplacementTrainingInputPath",
                newRestoredInitializerParameter:
                    "stage5ReplacementTrainingInputPath",
                existingStepMethod:
                    "trainNextExactMetalTrajectoryStep",
                existingEvaluateMethod: "checkedEvaluate",
                existingStepAndEvaluateBehaviorRemainsGather: true,
                selectorExplicitlyPassedThroughTrainStep: true,
                selectorExplicitlyPassedThroughValueAndGrad: true,
                selectorExplicitlyPassedThroughEvaluate: true,
                selectorExplicitInFreshAndRestoredBConstructors: true,
                readOnlyTrainingInputPathIDProperty:
                    "stage5ReplacementTrainingInputPathID",
                allNineBBranchesExposeExpectedReadOnlyPathID: true,
                denseModelMethod:
                    "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
                denseModelMethodSignature:
                    "package func trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1(_ tokens: MLXArray) -> MLXArray",
                denseModelMethodIsNonthrowing: true,
                embeddingForwardPairMethod:
                    "PrimeNativeGQADecoder.trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1",
                embeddingForwardPairMethodSignature:
                    "package func trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1(_ rankTwoTokenIDs: MLXArray) -> (maintainedGather: MLXArray, flattenedDenseOneHotMatmul: MLXArray)",
                embeddingForwardPairMethodIsNonthrowing: true,
                embeddingForwardPairUsesSameModelAndState: true,
                embeddingForwardPairValidatedDenseConstructionCountPerCheck: 1,
                wholeLogitsValidatedDenseConstructionCountPerForwardCheck: 1,
                forwardEquivalenceMethod:
                    "checkedTrainingInputPathForwardEquivalenceAtCurrentBoundaryV1",
                forwardEquivalenceMethodReadOnly: true,
                forwardEquivalenceBoundaries: [
                    "initial", "source_boundary", "terminal",
                ],
                sameModelPreMutationEmbeddingForwardPairSeamRequired: true,
                sameModelPreMutationWholeLogitsPairRequired: true,
                tokensMustBeRankTwo: true,
                tokensMustBeInt32: true,
                tokenIDsMustBeWithinVocabularyBounds: true,
                tokenBoundsPredicate:
                    "all_token_ids_gte_0_and_lt_v_before_one_hot",
                checkedVocabularySizeInt32ConversionRequired: true,
                vocabularySizeInt32ConversionExpression:
                    "guard let checkedInt32V = Int32(exactly: V) else { preconditionFailure() }",
                tokenBoundsCombinedPredicateExpression:
                    "((tokens .>= Int32(0)) .&& (tokens .< checkedInt32V)).all()",
                tokenBoundsCheckedEvalExpression:
                    "do { try checkedEval(tokenBounds) } catch { preconditionFailure() }",
                tokenBoundsSynchronizationExpression:
                    "StreamOrDevice.default.stream.synchronize()",
                tokenBoundsHostReadExpression:
                    "precondition(tokenBounds.item(Bool.self))",
                tokenBoundsCheckedEvalFailureAction: "preconditionFailure",
                tokenBoundsFalseFailureAction: "precondition",
                tokenBoundsFailureClassification:
                    "invalid_infrastructure_red_no_terminal_receipt",
                tokenBoundsOperationOrder: [
                    "checked_vocabulary_size_int32_conversion",
                    "construct_combined_bounds_reduction",
                    "checked_eval_combined_bounds",
                    "gpu_stream_synchronize",
                    "read_one_bool_item",
                    "fail_closed_or_construct_one_hot",
                ],
                tokenBoundsCheckedEvalCountPerDenseEmbeddingCall: 1,
                tokenBoundsGPUSynchronizeCountPerDenseEmbeddingCall: 1,
                tokenBoundsHostBoolItemCountPerDenseEmbeddingCall: 1,
                tokenBoundsFailureOccursBeforeOneHotConstruction: true,
                batchAndSequenceDimensionsMustBePositive: true,
                sequenceLengthMustNotExceedMaximumSequenceLength: true,
                checkedBatchTimesSequenceMultiplicationRequired: true,
                embeddingWeightDType: "float32",
                embeddingWeightExactShapeSymbols: ["V", "W"],
                exactIntermediateShapeChecksRequired: true,
                dependencySourceBindingsClaimDeterminism: false,
                forwardAndReplayExactnessRemainEmpirical: true,
                tokenRank: 2,
                tokenDType: "int32",
                inputShapeSymbols: ["B", "S"],
                flattenedTokensExpression:
                    "tokens.reshaped([B*S,1])",
                flattenedTokensShapeSymbols: ["B*S", "1"],
                vocabularyExpression:
                    "arange(V,dtype:.int32).reshaped([1,V])",
                vocabularyShapeSymbols: ["1", "V"],
                oneHotExpression:
                    "(flattenedTokens .== vocabulary).asType(.float32)",
                oneHotDType: "float32",
                oneHotShapeSymbols: ["B*S", "V"],
                embeddingExpression:
                    "matmul(oneHot,tokenEmbedding.weight)",
                embeddingShapeSymbols: ["B*S", "W"],
                restoredEmbeddingShapeSymbols: ["B", "S", "W"],
                unchangedSuccessorOperations: [
                    "decoder_layers",
                    "final_norm",
                    "tied_token_embedding_output_projection",
                ],
                tinyBatchSize: 2,
                tinySequenceLength: 6,
                tinyVocabularySize: 32,
                tinyOneHotElementCount: 384,
                tinyOneHotByteCount: 1_536,
                native300CompatibilityBatchSize: 1,
                native300CompatibilitySequenceLength: 128,
                native300CompatibilityVocabularySize: 512,
                native300CompatibilityOneHotElementCount: 65_536,
                native300CompatibilityOneHotByteCount: 262_144,
                usesSingleFlattenedTwoDimensionalMatmul: true,
                usesBatchedBroadcastMatmul: false,
                usesGatherForInputEmbedding: false,
                usesScatterAddForInputEmbeddingWeightVJPByConstruction: false,
                maintainedGatherImplementationChanged: false,
                tiedOutputProjectionChanged: false,
                checkedExactEmbeddingForwardEquivalenceRequired: true,
                checkedExactWholeLogitsForwardEquivalenceRequired: true),
            assay: .init(
                stageID:
                    "tiny_repeated_metal_trajectory_determinism_assay_replacement_v1",
                objective:
                    "measure_maintained_gather_diagnostically_and_clear_only_flattened_dense_one_hot_matmul_same_device_exact_resume",
                fixtureVocabularySize: 32,
                fixtureWidth: 16,
                fixtureLayerCount: 2,
                initializationSeed: 7,
                expectedParameterCount: 5_200,
                expectedParameterTensorCount: 20,
                batchSize: 2,
                sequenceLength: 6,
                repeatedTokenIDs: [1, 15],
                expectedSourceSelectedTargetCount: 6,
                expectedSuccessorSelectedTargetCount: 5,
                trialCount: 3,
                branchNames: [
                    "uninterrupted",
                    "source_snapshot",
                    "fresh_restored_from_source_snapshot",
                ],
                fullTrajectoryBranchCount: 9,
                sameProcessRequired: true,
                sameRetainedMetalDeviceRequired: true,
                leaseAcquiredBeforeCoreGraphicsMetalOrMLX: true,
                exactArmExecutionOrder: [
                    "maintained_embedding_gather_diagnostic",
                    "flattened_dense_one_hot_matmul_clearance",
                ],
                armAName: "maintained_embedding_gather_diagnostic",
                armAAPI: "PrimeNativeGQADecoder.trainingLogitsNoCache",
                armADiagnosticOnly: true,
                armACanGateClearance: false,
                armACompletedTrialCount: 3,
                armAIndependentSourceStepDiagnosticPairCount: 3,
                armAPairBranchNames: [
                    "uninterrupted", "source_snapshot",
                ],
                armASourceStepEqualityDisaggregated: true,
                armAGlobalStepOneDisaggregated: true,
                armASelectedTargetCountDisaggregated: true,
                armAFirstTensorMismatchCoordinateRecorded: true,
                armAFirstScalarMismatchCoordinateRecorded: true,
                armARestoreBranchRequired: false,
                armAMeasuredMismatchThrows: false,
                armAInfrastructureFailureIsInvalidInfrastructure: true,
                armAMeasuredMismatchSkipsArmB: false,
                armARecordsFirstMismatchWithoutThrowing: true,
                armBName: "flattened_dense_one_hot_matmul_clearance",
                armBAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
                armBOptInOnly: true,
                armBFullTrialCount: 3,
                armBFullTrajectoryBranchCount: 9,
                armBExpectedReadOnlySelectorID:
                    "flattened_dense_one_hot_matmul_input_embedding_v1",
                armBFreshConstructor:
                    "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(metalGPUIndexZero:stage5ReplacementTrainingInputPath:)",
                armBRestoreConstructor:
                    "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(restoring:metalGPUIndexZero:stage5ReplacementTrainingInputPath:)",
                armBValidMeasurementCompletesFullPlanBeforeTerminalReceipt:
                    true,
                sourceStepComparisonsDisaggregated: true,
                noCombinedGuardPermitted: true,
                continueAfterMeasuredMismatch: true,
                armBReplayExactComparisonDomains: [
                    "control_rng_and_cursor_state",
                    "evaluation_loss_and_logits_bytes",
                    "global_step_and_selected_target_count",
                    "model_parameter_bytes",
                    "optimizer_first_and_second_moment_bytes",
                    "raw_and_clipped_gradient_bytes",
                    "training_loss_norm_and_clip_scalar_bits",
                ],
                forwardEquivalenceComparisonDomains: [
                    "arm_b_embedding_forward_bytes_against_arm_a",
                    "arm_b_whole_logits_forward_bytes_against_arm_a",
                ],
                deterministicFirstMismatchComparisonDomainOrder: [
                    "arm_b_embedding_forward_bytes_against_arm_a",
                    "arm_b_whole_logits_forward_bytes_against_arm_a",
                    "control_rng_and_cursor_state",
                    "evaluation_loss_and_logits_bytes",
                    "global_step_and_selected_target_count",
                    "model_parameter_bytes",
                    "optimizer_first_and_second_moment_bytes",
                    "raw_and_clipped_gradient_bytes",
                    "training_loss_norm_and_clip_scalar_bits",
                ],
                crossTrialExactComparisonRequired: true,
                inMemorySnapshotOnly: true,
                durableCheckpointIOAuthorized: false,
                artifactRetentionAuthorized: false),
            receipt: .init(
                receiptID:
                    "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_receipt_v1",
                linePrefix:
                    "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1=",
                schemaVersion: 1,
                authorityIDBinding: authorityID,
                authorityCanonicalSHA256Binding:
                    "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1.canonicalSHA256",
                runtimeAuthorityCanonicalSHA256ResolvesTo64LowerHex: true,
                runtimeAuthorityCanonicalSHA256MayEqualSymbolLiteral: false,
                terminalGreenStatuses: [
                    "MEASURED_EXACT_MISMATCH", "PASS_CLEARANCE",
                ],
                passStatus: "PASS_CLEARANCE",
                measuredMismatchStatus: "MEASURED_EXACT_MISMATCH",
                gatingComparisonFields: [
                    "all_arm_b_exact_comparisons",
                    "all_forward_equivalence_checks",
                ],
                passPredicate:
                    "valid_completed_measurement && all_arm_b_exact_comparisons && all_forward_equivalence_checks",
                measuredMismatchPredicate:
                    "valid_completed_measurement && (!all_arm_b_exact_comparisons || !all_forward_equivalence_checks)",
                canonicalSortedJSONRequired: true,
                withoutEscapingSlashesRequired: true,
                encodeDecodeReencodeIdentityRequired: true,
                exactlyOneTerminalReceiptLineRequired: true,
                lineFeedTerminatorRequired: true,
                emittedWhileLeaseHeld: true,
                flushBeforeLeaseReleaseRequired: true,
                passRequiresAllArmBExactComparisons: true,
                passRequiresAllForwardEquivalenceChecks: true,
                armAOutcomeCanChangeTerminalStatus: false,
                measuredMismatchRequiresValidCompletedMeasurement: true,
                measuredMismatchReportsFirstMismatchCoordinates: true,
                measuredMismatchIsGreenMeasuredOutcome: true,
                passFirstMismatchMustBeNull: true,
                measuredMismatchFirstMismatchMustBeNonNull: true,
                measuredMismatchRequiresAtLeastOneGatingComparisonFalse: true,
                firstMismatchCanIdentifyForwardBoundary: true,
                tensorMismatchRequiresShapeDTypeByteOffsetAndSHAs: true,
                scalarMismatchRequiresReferenceAndObservedFloat32Bits: true,
                forwardMismatchRequiresForwardBoundary: true,
                nonApplicableMismatchFieldsMustBeNull: true,
                firstMismatchDeterministicSelectionOrder: [
                    "comparison_domain_order",
                    "trial_ordinal",
                    "branch_order",
                    "utf8_path",
                    "byte_offset_or_scalar_name",
                ],
                armAMismatchMayPopulateBFirstMismatch: false,
                invalidInfrastructureClassifications: [
                    "authority_or_provenance_drift",
                    "device_or_lease_failure",
                    "fixture_shape_dtype_or_inventory_drift",
                    "nonfinite_or_evaluation_failure",
                    "receipt_construction_or_transport_drift",
                    "snapshot_decode_or_restore_failure",
                ],
                invalidInfrastructureEmitsTerminalResult: false,
                invalidInfrastructureExitsNonzero: true,
                requiredTopLevelKeys: [
                    "arm_a",
                    "arm_b",
                    "authority",
                    "ceiling",
                    "environment",
                    "execution",
                    "forward_equivalence",
                    "operation_counts",
                    "receipt_id",
                    "schema_version",
                    "status",
                ],
                requiredAuthorityKeys: [
                    "authority_canonical_sha256",
                    "authority_id",
                    "authority_source_git_blob",
                    "authority_source_sha256",
                    "authority_test_git_blob",
                    "authority_test_sha256",
                ],
                requiredExecutionKeys: [
                    "artifact_count",
                    "authority_closure_active_job_conclusion",
                    "authority_closure_active_job_id",
                    "authority_closure_check_suite_id",
                    "authority_closure_conclusion",
                    "authority_closure_reviewed_job_conclusion",
                    "authority_closure_reviewed_job_id",
                    "authority_closure_revision",
                    "authority_closure_run_attempt",
                    "authority_closure_run_id",
                    "authority_closure_run_number",
                    "authority_closure_tree",
                    "build_count",
                    "direct_xctest_count",
                    "embedded_source_identity_sha256",
                    "exact_changed_source_identities",
                    "exact_main_revision",
                    "exact_main_tree",
                    "launcher_invocation_count",
                    "lease_acquired_before_coregraphics_metal_or_mlx",
                    "lease_path",
                    "mechanics_event",
                    "mechanics_head_ordered_parent_revisions",
                    "mechanics_head_revision",
                    "mechanics_head_tree",
                    "mechanics_ref",
                    "mechanics_run_attempt",
                    "one_shot_consumed",
                    "original_stage5_launcher_invocation_count",
                    "rerun_count",
                    "retained_metal_device_identity",
                    "retry_count",
                    "stage6_launcher_invocation_count",
                    "test_filter",
                ],
                requiredEnvironmentKeys: [
                    "exact_metallib_byte_count",
                    "exact_metallib_path",
                    "exact_metallib_sha256",
                    "exact_mlx_c_revision",
                    "exact_mlx_revision",
                    "lease_path",
                    "lease_type",
                    "metal_device_count",
                    "metal_device_index",
                    "metal_device_is_default",
                    "metal_device_name",
                    "metal_device_registry_id",
                    "mlx_compile_transform_invocation_count",
                    "mlx_default_stream_is_gpu",
                    "mlx_enable_tf32",
                    "mlx_graph_compile_mode",
                    "operating_system_build",
                    "swift_sdk",
                    "swift_version",
                    "swiftpm_build_configuration",
                    "xcode_version",
                ],
                requiredArmAOutcomeKeys: [
                    "completed_diagnostic_pair_count",
                    "first_scalar_mismatch",
                    "first_tensor_mismatch",
                    "global_step_one_by_pair",
                    "measured_mismatch",
                    "pair_branch_names",
                    "selected_target_count_six_by_pair",
                    "source_step_equal_by_pair",
                    "trial_count",
                ],
                requiredArmBOutcomeKeys: [
                    "all_exact_comparisons_passed",
                    "all_forward_equivalence_checks_passed",
                    "branch_names",
                    "comparison_domain_results",
                    "first_mismatch",
                    "fresh_constructor",
                    "restore_constructor",
                    "selector_id_by_branch",
                    "status",
                    "trajectory_branch_count",
                    "trial_count",
                ],
                requiredFirstMismatchCoordinateKeys: [
                    "arm",
                    "branch",
                    "byte_offset",
                    "comparison_domain",
                    "component",
                    "dtype",
                    "forward_boundary",
                    "observed_branch",
                    "observed_scalar_float32_bits",
                    "observed_sha256",
                    "parameter_or_tensor_path",
                    "reference_branch",
                    "reference_scalar_float32_bits",
                    "reference_sha256",
                    "scalar_name",
                    "shape",
                    "trial_ordinal",
                ],
                requiredForwardEquivalenceKeys: [
                    "boundary_names",
                    "embedding_forward_exact_by_boundary",
                    "same_model_pre_mutation",
                    "whole_logits_exact_by_boundary",
                ],
                requiredOperationCountKeys: [
                    "arm_a_source_step_count",
                    "arm_b_dense_embedding_construction_count",
                    "arm_b_dense_whole_logits_call_count",
                    "arm_b_evaluate_count",
                    "arm_b_forward_equivalence_check_count",
                    "arm_b_input_embedding_pair_seam_count",
                    "arm_b_restore_count",
                    "arm_b_snapshot_count",
                    "arm_b_token_bounds_checked_eval_count",
                    "arm_b_token_bounds_gpu_synchronize_count",
                    "arm_b_token_bounds_host_bool_item_count",
                    "arm_b_token_bounds_validation_count",
                    "arm_b_training_step_count",
                    "receipt_count",
                    "synchronize_count",
                ],
                requiredCeilingKeys: [
                    "additional_execution_or_rerun_authorized",
                    "arbitrary_token_determinism_established",
                    "artifact_upload_authorized",
                    "b_specific_native300_resource_witness_authorized",
                    "b_specific_native300_resource_witness_established",
                    "b_specific_native300_resource_witness_requires_separate_authority",
                    "candidate_admission_granted",
                    "cross_device_determinism_established",
                    "default_gather_determinism_established",
                    "durable_checkpoint_io_authorized",
                    "exact_same_device_b_path_gradient_bytes_established",
                    "model_quality_established",
                    "one_shot_consumed",
                    "repeated_same_device_b_path_determinism_established",
                    "retained_artifact_authorized",
                    "stage5_assay_clearance_established",
                    "stage5_mechanics_success_established",
                    "stage5_result_established",
                    "stage6_historical_resource_clearance_applies_to_b_path",
                    "stage6_resource_clearance_remains_historical",
                    "stage7_authority_established",
                    "stage7_authorized",
                    "stage7_requires_new_b_specific_native300_resource_witness",
                    "stage7_requires_separate_authority_after_witness",
                ],
                greenOutcomeTrueCeilingKeys: [
                    "one_shot_consumed",
                    "stage5_mechanics_success_established",
                    "stage5_result_established",
                ],
                passOnlyTrueCeilingKeys: [
                    "exact_same_device_b_path_gradient_bytes_established",
                    "repeated_same_device_b_path_determinism_established",
                    "stage5_assay_clearance_established",
                ],
                alwaysFalseCeilingKeys: [
                    "additional_execution_or_rerun_authorized",
                    "arbitrary_token_determinism_established",
                    "artifact_upload_authorized",
                    "b_specific_native300_resource_witness_authorized",
                    "b_specific_native300_resource_witness_established",
                    "candidate_admission_granted",
                    "cross_device_determinism_established",
                    "default_gather_determinism_established",
                    "durable_checkpoint_io_authorized",
                    "model_quality_established",
                    "retained_artifact_authorized",
                    "stage6_historical_resource_clearance_applies_to_b_path",
                    "stage7_authority_established",
                    "stage7_authorized",
                ],
                alwaysTrueResourceGuardCeilingKeys: [
                    "b_specific_native300_resource_witness_requires_separate_authority",
                    "stage6_resource_clearance_remains_historical",
                    "stage7_requires_new_b_specific_native300_resource_witness",
                    "stage7_requires_separate_authority_after_witness",
                ],
                firstMismatchCoordinateNullableIffNoMismatch: true,
                requiredBSelectorIDCount: 9,
                requiredBSelectorIDValue:
                    "flattened_dense_one_hot_matmul_input_embedding_v1",
                requiredArmBFreshConstructorValue:
                    "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(metalGPUIndexZero:stage5ReplacementTrainingInputPath:)",
                requiredArmBRestoreConstructorValue:
                    "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(restoring:metalGPUIndexZero:stage5ReplacementTrainingInputPath:)",
                requiredForwardEquivalenceBoundaryNames: [
                    "initial", "source_boundary", "terminal",
                ],
                requiredArmATrialCount: 3,
                requiredArmBSelectorBranchCount: 9,
                requiredArmBTrialCount: 3,
                requiredArmBTrajectoryBranchCount: 9,
                expectedArmASourceStepCount: 6,
                expectedArmBTrainingStepCount: 15,
                expectedArmBSnapshotCount: 3,
                expectedArmBRestoreCount: 3,
                expectedArmBEvaluateCount: 18,
                expectedArmBForwardEquivalenceCheckCount: 9,
                expectedArmBDenseWholeLogitsCallCount: 57,
                expectedArmBInputEmbeddingPairSeamCount: 9,
                expectedArmBDenseEmbeddingConstructionCount: 66,
                expectedArmBTokenBoundsValidationCount: 66,
                expectedArmBTokenBoundsCheckedEvalCount: 66,
                expectedArmBTokenBoundsGPUSynchronizeCount: 66,
                expectedArmBTokenBoundsHostBoolItemCount: 66,
                synchronizeCountMustMatchComparedArrayAndForwardCheckPlan:
                    true,
                artifactUploadCount: 0,
                rerunCount: 0,
                retryCount: 0),
            authorityClosureScope: .init(
                exactChangedPaths: [
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                    ".github/workflows/prime-active-root-quarantine.yml",
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift",
                    "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests.swift",
                ],
                expectedRootTestCount: 57,
                expectedIsolatedGroupTestCounts: [1, 1, 2, 2],
                expectedIsolatedTestCount: 6,
                expectedFocusedWholeTestCount: 63,
                expectedMetalTestCount: 44,
                expectedMaintainedRuntimeTestCount: 1,
                expectedTokenizerTestCount: 1,
                expectedTotalTestCount: 109,
                exactLiveOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                originalStage5LauncherInvocationCount: 0,
                replacementStage5LauncherInvocationCount: 0,
                stage6LauncherInvocationCount: 0,
                artifactCount: 0,
                authorityOnlyNoMetalOrMLX: true),
            successorScope: .init(
                exactChangedPaths: [
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                    newLauncher,
                    ".github/workflows/prime-active-root-quarantine.yml",
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    identityObservationSource,
                    decoderSource,
                    trainingSource,
                    identityObservationTest,
                    assayTest,
                    retainedAuthorityTest,
                ],
                newLauncherPath: newLauncher,
                newCurrentDecoderIdentityObservationSourcePath:
                    identityObservationSource,
                newCurrentDecoderIdentityObservationTestPath:
                    identityObservationTest,
                decoderSourcePath: decoderSource,
                trainingSourcePath: trainingSource,
                retainedAuthorityTestPath: retainedAuthorityTest,
                newAssayTestPath: assayTest,
                newAssayTestClass: assayTestClass,
                newAssayTestMethod: assayTestMethod,
                newAssayTestFilter:
                    assayTestClass + "/" + assayTestMethod,
                expectedRootTestCount: 58,
                expectedIsolatedGroupTestCounts: [1, 1, 2, 2],
                expectedIsolatedTestCount: 6,
                expectedFocusedWholeTestCount: 64,
                expectedMetalTestCount: 44,
                expectedMaintainedRuntimeTestCount: 1,
                expectedTokenizerTestCount: 1,
                expectedPreReplacementTestCount: 110,
                expectedReplacementTestCount: 1,
                expectedTotalTestCount: 111,
                exactLiveOrder: [
                    "metal",
                    "maintained_runtime",
                    "tokenizer",
                    "stage5_repeated_trajectory_replacement",
                ],
                replacementLauncherInvocationCount: 1,
                replacementBuildCount: 1,
                replacementDirectXCTestCount: 1,
                replacementReceiptCount: 1,
                originalLauncherInvocationCount: 0,
                stage6LauncherInvocationCount: 0,
                exactMainExecutionOpportunityCount: 1,
                manifestMutationAuthorized: false,
                packageLockMutationAuthorized: false,
                originalStage5LauncherMutationAuthorized: false,
                defaultGatherPathMutationAuthorized: false,
                decoderSourceMutationAuthorized: true,
                decoderSourceMutationScope:
                    "add_only_package_trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1_and_same_model_pre_mutation_embedding_forward_pair_seam_default_gather_unchanged",
                trainingSourceMutationAuthorized: true,
                trainingSourceMutationScope:
                    "add_only_immutable_stage5ReplacementTrainingInputPath_selector_plumbing_fresh_and_restored_initializers_read_only_path_id_and_forward_equivalence_helper_existing_defaults_gather",
                otherProductionSourceMutationAuthorized: false,
                newPackageOnlyOptInPathAuthorized: true,
                retainedAuthorityTestMutationAuthorized: true,
                retainedAuthorityTestPermittedMutation:
                    "replace_only_live_Stage2_surfaceDesign_currentDecoderSuccessor_identity_comparison_with_PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationV1",
                retainedAuthorityTestClass:
                    "PrimeNativeDecoderAuthorityTests",
                retainedAuthorityTestImports: [
                    "CryptoKit", "Foundation", "XCTest", "PrimeCore",
                ],
                retainedAuthorityTestMethodNames: [
                    "testFrozenPredecessorSourceIsByteExact",
                    "testFrozenPredecessorAuthorityStillValidatesExactly",
                    "testDerivedGQAMechanicsAuthorityIsExactAndAdditive",
                    "testDerivedAuthorityDoesNotPromoteMechanicsIntoRuntimeAuthority",
                    "testDerivedAuthorityRejectsEveryBooleanAuthorityMutation",
                    "testCheckpointAuthorityIsAppendOnlyAndMechanicsScoped",
                    "testCheckpointAuthorityKeepsRuntimeAndDownstreamCeilingsFalse",
                    "testCheckpointAuthorityRejectsEveryBooleanMutation",
                    "testMetalRepairAuthorityIsAppendOnlyAndSourceExact",
                    "testMetalRepairAuthorityKeepsRuntimeAndTrainingCeilingsFalse",
                    "testMetalRepairAuthorityRejectsEveryBooleanAndPolicyMutation",
                ],
                retainedAuthorityTestMethodCount: 11,
                retainedHistoricalMetalRepairGitBlob:
                    "835a4826549e1f28ec27e3533f746218beb3bdf2",
                retainedHistoricalMetalRepairByteCount: 39_050,
                retainedHistoricalMetalRepairSHA256:
                    "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
                retainedGitBlobOIDOccurrenceCount: 2,
                retainedCryptoKitSHA1FramingOccurrenceCount: 1,
                retainedAllOtherAssertionsByteSemanticallyPreserved: true,
                newCurrentIdentityObservationAuthorized: true),
            outcomeTransitions: .init(
                passClearanceEstablishesStage5Result: true,
                passClearanceEstablishesStage5MechanicsSuccess: true,
                passClearanceEstablishesStage5AssayClearance: true,
                passClearanceEstablishesRepeatedSameDeviceBPathDeterminism:
                    true,
                passClearanceEstablishesExactSameDeviceBPathGradientBytes:
                    true,
                passClearanceEstablishesDefaultGatherDeterminism: false,
                passClearanceEstablishesArbitraryTokenDeterminism: false,
                passClearanceEstablishesCrossDeviceDeterminism: false,
                measuredMismatchEstablishesStage5Result: true,
                measuredMismatchEstablishesStage5MechanicsSuccess: true,
                measuredMismatchEstablishesStage5Clearance: false,
                measuredMismatchPermitsRerun: false,
                eitherGreenOutcomeConsumesOneShot: true,
                invalidInfrastructureConsumesExactMainOpportunity: true,
                invalidInfrastructureEstablishesStage5Result: false,
                successorObservationRequiredAfterAnyTerminalGreenOutcome: true,
                stage7AuthorizedByPassClearance: false,
                stage7RequiresNewBSpecificNative300ResourceWitness: true,
                stage7RequiresSeparateAuthorityAfterWitness: true),
            authorityCeiling: .init(
                replacementMechanicsImplementationAuthorizedAfterGreenClosure:
                    true,
                oneExactMainReplacementExecutionAuthorizedAfterGreenClosure:
                    true,
                authorityClosureExecutedReplacement: false,
                authorityClosureObservedMLX: false,
                authorityClosureEstablishedStage5Result: false,
                authorityClosureEstablishedStage5Clearance: false,
                authorityClosureEstablishedRepeatedTrajectoryDeterminism: false,
                authorityClosureEstablishedExactMetalGradientBytes: false,
                defaultGatherDeterminismEstablished: false,
                arbitraryTokenDeterminismEstablished: false,
                crossDeviceDeterminismEstablished: false,
                originalFailedRunReinterpreted: false,
                originalLauncherRecoveryAuthorized: false,
                additionalExecutionOrRerunAuthorized: false,
                durableCheckpointIOAuthorized: false,
                retainedArtifactAuthorized: false,
                broadNative300TrainingAuthorized: false,
                stage6ResourceClearanceRemainsHistorical: true,
                stage6HistoricalResourceClearanceAppliesToBPath: false,
                bSpecificNative300ResourceWitnessAuthorized: false,
                bSpecificNative300ResourceWitnessRequiresSeparateAuthority:
                    true,
                bSpecificNative300ResourceWitnessEstablished: false,
                stage7AuthorityEstablished: false,
                stage7Authorized: false,
                candidateAdmissionGranted: false,
                modelQualityEstablished: false,
                canaryAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false),
            orderedRequiredSeparateActions: [
                "close_this_exact5_authority_pair_on_exact_main_with_109_tests_and_no_stage5_or_stage6_invocation",
                "materialize_only_the_exact10_successor_after_green_authority_closure",
                "seal_new_current_decoder_identity_and_preserve_the_default_gather_path",
                "execute_one_exact_main_ab_replacement_opportunity_and_accept_only_one_canonical_green_measured_outcome",
                "record_and_retire_pass_clearance_or_measured_exact_mismatch_without_rerun",
                "if_pass_clearance_then_require_a_new_b_specific_native300_resource_witness_before_any_separate_stage7_authority",
            ],
            status:
                "AUTHORIZED_exact5_authority_closure_then_one_exact10_stage5_ab_replacement_opportunity_no_execution_observed_stage7_false")
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
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityError
                    .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let originalStage5 =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1
                .frozenV1
        let immediateRepair =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityV1
                .frozenV1
        let failure =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationV1
                .frozenV1
        let stage6Authority =
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                .frozenV1
        let stage6Observation =
            PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationV1
                .frozenV1
        let design =
            PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1.frozenV1
        let tinyCPUMechanics =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1.frozenV1
        do {
            try originalStage5.validateExactV1()
            try immediateRepair.validateExactV1()
            try failure.validateExactV1()
            try stage6Authority.validateExactV1()
            try stage6Observation.validateExactV1()
            try design.validateExactV1()
            try tinyCPUMechanics.validateExactV1()
        } catch {
            throw
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityError
                    .contractDrift("predecessor validation")
        }

        let designHash: String
        let originalStage5Hash: String
        let immediateRepairHash: String
        let failureHash: String
        do {
            designHash = PrimeSHA256.hexDigest(
                of: try PrimeCanonicalJSON.encode(design))
            originalStage5Hash = PrimeSHA256.hexDigest(
                of: try originalStage5.canonicalData())
            immediateRepairHash = PrimeSHA256.hexDigest(
                of: try immediateRepair.canonicalData())
            failureHash = PrimeSHA256.hexDigest(
                of: try failure.canonicalData())
        } catch {
            throw
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityError
                    .contractDrift("predecessor canonicalization")
        }

        let closure = authorityClosureScope
        let successor = successorScope
        let transition = outcomeTransitions
        let ceiling = authorityCeiling
        let externalBindingKeys = Set(externalSourceBindings.map {
            $0.repository + "@" + $0.revision + ":" + $0.path
        })
        let armAExternalBindingSet = Set(armAExternalBindingKeys)
        let armBExternalBindingSet = Set(armBExternalBindingKeys)
        let externalBindingOverlapSet = Set(exactExternalBindingOverlapKeys)
        let inheritedExecutionSupportBindingKeys = Set(
            inheritedExecutionSupportBindings.map {
                $0.repository + "@" + $0.revision + ":" + $0.path
            })
        let mechanicsExecutionSupportBindings =
            tinyCPUMechanics.externalSourceBindings.filter {
                $0.path == "Source/MLX/Stream.swift"
                    || $0.path == "Source/MLX/Transforms+Eval.swift"
            }
        let inheritedExecutionSupportMatchesMechanics =
            inheritedExecutionSupportBindings.allSatisfy { inherited in
                mechanicsExecutionSupportBindings.contains { mechanics in
                    inherited.repository == mechanics.repository
                        && inherited.revision == mechanics.revision
                        && inherited.path == mechanics.path
                        && inherited.gitMode == mechanics.gitMode
                        && inherited.gitBlob == mechanics.gitBlob
                        && inherited.byteCount == mechanics.byteCount
                        && inherited.sha256 == mechanics.sha256
                }
            }
        let closureFalseClaims = [
            ceiling.authorityClosureExecutedReplacement,
            ceiling.authorityClosureObservedMLX,
            ceiling.authorityClosureEstablishedStage5Result,
            ceiling.authorityClosureEstablishedStage5Clearance,
            ceiling.authorityClosureEstablishedRepeatedTrajectoryDeterminism,
            ceiling.authorityClosureEstablishedExactMetalGradientBytes,
            ceiling.defaultGatherDeterminismEstablished,
            ceiling.arbitraryTokenDeterminismEstablished,
            ceiling.crossDeviceDeterminismEstablished,
            ceiling.originalFailedRunReinterpreted,
            ceiling.originalLauncherRecoveryAuthorized,
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.broadNative300TrainingAuthorized,
            ceiling.stage6HistoricalResourceClearanceAppliesToBPath,
            ceiling.bSpecificNative300ResourceWitnessAuthorized,
            ceiling.bSpecificNative300ResourceWitnessEstablished,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
            ceiling.candidateAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              designHash
                == "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
              predecessor.designAuthorityID == design.authorityID,
              predecessor.designAuthorityCanonicalSHA256 == designHash,
              predecessor.originalStage5AuthorityID
                == originalStage5.authorityID,
              predecessor.originalStage5AuthorityCanonicalSHA256
                == originalStage5Hash,
              predecessor.originalStage5AuthorityCanonicalSHA256
                == PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1
                    .canonicalSHA256,
              predecessor.immediateRepairAuthorityID
                == immediateRepair.authorityID,
              predecessor.immediateRepairAuthorityCanonicalSHA256
                == immediateRepairHash,
              predecessor.immediateRepairAuthorityCanonicalSHA256
                == PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityV1
                    .canonicalSHA256,
              currentMain.exactMainSealed,
              currentMain.mergeRevision
                == "54635d6b58e4f9c7ddedb30a3c22fffb17d8e174",
              currentMain.mergeTree
                == "afd51da78370aee8851341fe46b2533450944b2f",
              currentMain.orderedParentRevisions == [
                  "437acb46a5af63f6c604e5f5c50f3b63eaa296f2",
                  "03d31f5cc3acfddd338fd06dea5a14aa0bc10677",
              ],
              currentMain.workflowRunAttempt == 1,
              currentMain.conclusion == "success",
              currentMain.previousAttemptURLWasNull,
              currentMain.rerunCount == 0,
              currentMain.artifactCount == 0,
              currentMain.activeRootJobStepCount
                == currentMain.activeRootSuccessfulStepCount,
              currentMain.reviewedMainJobStepCount
                == currentMain.reviewedMainSuccessfulStepCount,
              currentMain.isolatedTestCount
                == currentMain.isolatedGroupTestCounts.reduce(0, +),
              currentMain.focusedWholeTestCount
                == currentMain.rootTestCount + currentMain.isolatedTestCount,
              currentMain.totalTestCount
                == currentMain.focusedWholeTestCount
                    + currentMain.metalTestCount
                    + currentMain.maintainedRuntimeTestCount
                    + currentMain.tokenizerTestCount,
              currentMain.exactChangedSources.count == 5,
              currentMain.exactChangedSources.map(\.path)
                == currentMain.exactChangedSources.map(\.path).sorted(),
              Set(currentMain.exactChangedSources.map(\.path)).count == 5,
              predecessor.failureObservationID == failure.observationID,
              predecessor.failureObservationCanonicalSHA256 == failureHash,
              predecessor.failureObservationCanonicalSHA256
                == "ac735b84948e6b9b6b492a79925d7e0770d6eb332ba4d643d7f2884a4a7f81d2",
              predecessor.combinedGuardConjuncts
                == failure.assayFailureBoundary.combinedGuardConjuncts,
              !predecessor.failedConjunctIdentified,
              !predecessor.failingTrialOrdinalEstablished,
              !predecessor.sourceStepEqualityEstablished,
              !predecessor.sourceStepEqualityDisproved,
              !predecessor.globalStepOneEstablished,
              !predecessor.globalStepOneDisproved,
              !predecessor.selectedTargetCountSixEstablished,
              !predecessor.selectedTargetCountSixDisproved,
              predecessor.failingTrialOrdinalMinimum == 1,
              predecessor.failingTrialOrdinalMaximum == 3,
              predecessor.priorCompletedTrialCountMinimum == 0,
              predecessor.priorCompletedTrialCountMaximum == 2,
              !predecessor.priorCompletedTrialCountEstablished,
              predecessor.failureStage5ReceiptCount == 0,
              predecessor.stage5MechanicsExecuted,
              predecessor.originalOneShotConsumed,
              predecessor.originalOneShotExhausted,
              !predecessor.originalLauncherMutationAuthorized,
              !predecessor.originalLauncherRerunAuthorized,
              predecessor.originalAssayTest.path
                == "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
              predecessor.originalAssayTest.gitBlob
                == "46f91f32e91870d21c46cd318972a857b8ef6e12",
              predecessor.originalAssayTest.byteCount == 28_292,
              predecessor.originalAssayTestLFByteCount == 606,
              predecessor.originalAssayTest.sha256
                == "50b19a0bfe8752d2b80c09527b70731d906e8064c8e2d49a758c8c48b48f4398",
              !predecessor.originalAssayTestMutationAuthorized,
              !predecessor.originalAssayTestRerunAuthorized,
              !predecessor.stage5ResultEstablished,
              !predecessor.repeatedTrajectoryDeterminismEstablished,
              !predecessor.exactMetalGradientBytesEstablished,
              predecessor.stage5InvocationRetired,
              predecessor.stage5LauncherPreservedForAudit,
              predecessor.stage5RetirementStage5InvocationCount == 0,
              predecessor.stage5RetirementStage5ReceiptCount == 0,
              predecessor.stage6AuthorityID == stage6Authority.authorityID,
              predecessor.stage6AuthorityCanonicalSHA256
                == PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityV1
                    .canonicalSHA256,
              predecessor.stage6ObservationID
                == stage6Observation.observationID,
              predecessor.stage6ObservationCanonicalSHA256
                == PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationV1
                    .canonicalSHA256,
              predecessor.stage6ReceiptSHA256
                == "104f3579f2caf19f27cbbe694f8a854cc8927d9188af055075c11b1fe1c94c55",
              predecessor.stage6ResourceEnvelopeEstablished,
              predecessor.stage6ResourceClearanceEstablished,
              predecessor.stage6RunnerMemoryCapacityEstablished,
              !predecessor.stage6OrdinaryJobFitEstablished,
              predecessor.stage6OneShotConsumed,
              predecessor.stage6RetirementObservedOnCurrentMain,
              predecessor.stage6MLXPeakBytes < predecessor.stage6MemoryCapBytes,
              inheritedOriginalEnvironment == originalStage5.environment,
              inheritedOriginalFixture == originalStage5.fixture,
              inheritedOriginalAssayTopology == originalStage5.assay,
              inheritedOriginalEquality == originalStage5.equality,
              replacementInheritsOriginalEnvironmentExactly,
              replacementInheritsOriginalFixtureExactly,
              replacementInheritsOriginalFreshnessAndBranchTopologyExactly,
              replacementInheritsOriginalEqualityExactly,
              originalReceiptAndTestIdentifiersReplaced,
              inheritedOriginalEnvironment.mlxEnableTF32 == "0",
              inheritedOriginalEnvironment.metalDeviceIndex == 0,
              inheritedOriginalEnvironment.exactMetalDeviceCount == 1,
              inheritedOriginalEnvironment
                .sameMetalDeviceRequiredAcrossEveryTrialAndBranch,
              inheritedOriginalEnvironment.explicitDefaultGPUStreamRequired,
              inheritedOriginalEnvironment
                .checkedEvaluationRequiredForEveryComparedArray,
              inheritedOriginalEnvironment
                .explicitSynchronizeRequiredBeforeEveryByteRead,
              inheritedOriginalEnvironment
                .exclusiveMetalDeviceLeaseRequiredForWholeAssay,
              inheritedOriginalEnvironment
                .leaseAcquiredBeforeCoreGraphicsMetalOrMLXAccess,
              inheritedOriginalEnvironment.leaseHeldThroughPostflightAndReceipt,
              inheritedOriginalEnvironment.singletonDeviceEnumerationRequired,
              inheritedOriginalEnvironment
                .postflightDeviceIdentityReverificationRequired,
              inheritedOriginalEnvironment.swiftPMBuildConfiguration == "debug",
              inheritedOriginalEnvironment.mlxGraphCompileMode
                == "eager_uncompiled_no_compile_transform",
              inheritedOriginalEnvironment.mlxCompileTransformInvocationCount
                == 0,
              inheritedOriginalFixture.sourceSnapshotGlobalStep == 1,
              inheritedOriginalFixture.terminalGlobalStep == 2,
              inheritedOriginalFixture.sourceStepTokenIDs == [
                  [1, 1, 1, 2, 3, 0],
                  [4, 5, 6, 7, 8, 9],
              ],
              inheritedOriginalFixture.sourceStepValidTokenCounts == [5, 6],
              inheritedOriginalFixture.sourceStepCompletionMask == [
                  [false, false, false, true, true, false],
                  [false, false, true, true, true, true],
              ],
              inheritedOriginalFixture.successorStepTokenIDs == [
                  [10, 11, 12, 13, 0, 0],
                  [14, 15, 15, 15, 16, 0],
              ],
              inheritedOriginalFixture.successorStepValidTokenCounts == [4, 5],
              inheritedOriginalFixture.successorStepCompletionMask == [
                  [false, true, true, true, false, false],
                  [false, false, false, true, true, false],
              ],
              inheritedOriginalFixture.repeatedTokenIDs == [1, 15],
              inheritedOriginalAssayTopology.independentTrialCount == 3,
              inheritedOriginalAssayTopology
                .totalTrajectoryBranchExecutionCount == 9,
              inheritedOriginalAssayTopology.allTrialsRunInOneProcess,
              inheritedOriginalAssayTopology
                .uninterruptedBranchStartsFromFreshFixture,
              inheritedOriginalAssayTopology
                .sourceSnapshotBranchStartsFromFreshFixture,
              inheritedOriginalAssayTopology
                .sourceSnapshotBranchCapturesAtExactStep,
              inheritedOriginalAssayTopology.sourceSnapshotCaptureIsReadOnly,
              inheritedOriginalAssayTopology
                .sourceSnapshotBranchContinuesToTerminalStep,
              inheritedOriginalAssayTopology
                .restoredBranchUsesFreshModelOptimizerRNGAndCursor,
              inheritedOriginalAssayTopology
                .restoredBranchLoadsOnlyTheSourceSnapshot,
              inheritedOriginalAssayTopology.everyBranchReachesTerminalStep,
              inheritedOriginalAssayTopology.everyTrialUsesFreshObjectsAndArrays,
              !inheritedOriginalAssayTopology
                .objectOrArrayAliasingAcrossBranchesAuthorized,
              !inheritedOriginalAssayTopology.stateReuseAcrossTrialsAuthorized,
              !inheritedOriginalAssayTopology
                .implicitOrGlobalMLXRandomStateAuthorized,
              inheritedOriginalEquality
                .exactSourceStepWithinTrialAcrossProducingBranchesRequired,
              inheritedOriginalEquality.exactSourceStepAcrossAllTrialsRequired,
              inheritedOriginalEquality
                .exactSuccessorAndTerminalWithinTrialAcrossAllBranchesRequired,
              inheritedOriginalEquality
                .exactSuccessorAndTerminalAcrossAllTrialsRequired,
              inheritedOriginalEquality
                .tensorShapesAndDTypesMustMatchBeforeByteComparison,
              inheritedOriginalEquality.canonicalParameterPathOrderRequired,
              inheritedOriginalEquality.canonicalShapeAndDTypeOrderRequired,
              inheritedOriginalEquality.float32LittleEndianByteReadOrderRequired,
              !inheritedOriginalEquality.unorderedOrToleranceComparisonAuthorized,
              currentSources.decoderUsesMaintainedEmbeddingByDefault,
              currentSources.defaultTrainingLogitsAPIRemainsTrainingLogitsNoCache,
              !currentSources.publicDecoderAPIAdditionAuthorized,
              !currentSources.defaultInferenceOrTrainingSemanticChangeAuthorized,
              externalSourceBindings.count == 11,
              externalSourceBindings.map(\.claimScope)
                == externalSourceBindings.map(\.claimScope).sorted(),
              Set(externalSourceBindings.map(\.claimScope)).count == 11,
              Set(externalSourceBindings.map {
                  $0.repository + "\u{0}" + $0.revision + "\u{0}" + $0.path
              }).count == 11,
              !externalSourceBindings.contains(where: {
                  $0.path == "Source/MLX/Ops.swift"
              }),
              externalSourceBindings.contains(where: {
                  $0.path == "Source/MLX/MLXArray.swift"
                    && $0.claimScope
                        == "float32_astype_and_bool_item_host_read_for_bounds_and_explicit_one_hot"
              }),
              externalSourceBindings.contains(where: {
                  $0.path == "Source/MLX/MLXArray+Ops.swift"
                    && $0.claimScope
                        == "reshape_integer_equal_gte_lt_logical_and_all_for_bounds_and_explicit_one_hot"
              }),
              externalSourceBindings.contains(where: {
                  $0.repository == "ml-explore/mlx-c"
                    && $0.path == "mlx/c/ops.cpp"
                    && $0.claimScope
                        == "c_api_routing_for_all_arange_astype_equal_greater_equal_less_logical_and_matmul_reshape"
              }),
              externalSourceBindings.contains(where: {
                  $0.repository == "ml-explore/mlx"
                    && $0.path == "mlx/ops.cpp"
                    && $0.claimScope
                        == "matmul_and_equal_greater_equal_less_logical_and_all_construction_with_explicit_two_dimensional_operands"
              }),
              inheritedExecutionSupportAuthorityID
                == tinyCPUMechanics.authorityID,
              inheritedExecutionSupportAuthorityID
                == "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_authority_v1",
              inheritedExecutionSupportBindings.count == 2,
              inheritedExecutionSupportBindings.map(\.claimScope)
                == [
                    "inherited_checked_eval_execution_support",
                    "inherited_explicit_default_gpu_stream_synchronization_support",
                ],
              Set(inheritedExecutionSupportBindings.map(\.path))
                == Set([
                    "Source/MLX/Stream.swift",
                    "Source/MLX/Transforms+Eval.swift",
                ]),
              mechanicsExecutionSupportBindings.count == 2,
              inheritedExecutionSupportMatchesMechanics,
              inheritedExecutionSupportBindingKeys.count == 2,
              inheritedExecutionSupportBindingKeys.isDisjoint(
                  with: externalBindingKeys),
              inheritedExecutionSupportBindingsExcludedFromArmABindingUnion,
              armAExternalBindingKeys == armAExternalBindingKeys.sorted(),
              armBExternalBindingKeys == armBExternalBindingKeys.sorted(),
              exactExternalBindingOverlapKeys
                == exactExternalBindingOverlapKeys.sorted(),
              exactExternalBindingOverlapPaths
                == ["Source/MLXNN/Embedding.swift", "mlx/primitives.cpp"],
              armAExternalBindingSet.count == 4,
              armBExternalBindingSet.count == 9,
              externalBindingOverlapSet.count == 2,
              armAExternalBindingSet.intersection(armBExternalBindingSet)
                == externalBindingOverlapSet,
              armAExternalBindingSet.union(armBExternalBindingSet)
                == externalBindingKeys,
              armBExternalBindingSet
                .subtracting(armAExternalBindingSet).count == 7,
              algorithm.optInOnly,
              algorithm.accessLevel == "package",
              algorithm.selectorDeclaration
                == "PrimeNativeDecoderTinyMetalTrajectoryTrainingInputPathV1: String",
              algorithm.orderedSelectorBindings == [
                  .init(
                      caseName: "maintainedGatherV1",
                      rawValue: "maintained_gather_v1"),
                  .init(
                      caseName: "denseOneHotMatmulV1",
                      rawValue:
                          "flattened_dense_one_hot_matmul_input_embedding_v1"),
              ],
              algorithm.selectorCases
                == ["maintainedGatherV1", "denseOneHotMatmulV1"],
              algorithm.selectorRawValues == [
                  "maintained_gather_v1",
                  "flattened_dense_one_hot_matmul_input_embedding_v1",
              ],
              algorithm.orderedSelectorBindings.map(\.caseName)
                == algorithm.selectorCases,
              algorithm.orderedSelectorBindings.map(\.rawValue)
                == algorithm.selectorRawValues,
              algorithm.sessionSelectorProperty
                == algorithm.trainerSelectorProperty,
              algorithm.selectorImmutableAfterInitialization,
              algorithm.existingInitializerDefaultCase
                == "maintainedGatherV1",
              algorithm.newFreshInitializerParameter
                == algorithm.sessionSelectorProperty,
              algorithm.newRestoredInitializerParameter
                == algorithm.sessionSelectorProperty,
              algorithm.existingStepAndEvaluateBehaviorRemainsGather,
              algorithm.selectorExplicitlyPassedThroughTrainStep,
              algorithm.selectorExplicitlyPassedThroughValueAndGrad,
              algorithm.selectorExplicitlyPassedThroughEvaluate,
              algorithm.selectorExplicitInFreshAndRestoredBConstructors,
              algorithm.readOnlyTrainingInputPathIDProperty
                == "stage5ReplacementTrainingInputPathID",
              algorithm.allNineBBranchesExposeExpectedReadOnlyPathID,
              algorithm.denseModelMethod == assay.armBAPI,
              algorithm.denseModelMethodSignature
                == "package func trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1(_ tokens: MLXArray) -> MLXArray",
              algorithm.denseModelMethodIsNonthrowing,
              algorithm.embeddingForwardPairMethod
                == "PrimeNativeGQADecoder.trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1",
              algorithm.embeddingForwardPairMethodSignature
                == "package func trainingInputEmbeddingForwardPairForFlattenedDenseOneHotMatmulAssayV1(_ rankTwoTokenIDs: MLXArray) -> (maintainedGather: MLXArray, flattenedDenseOneHotMatmul: MLXArray)",
              algorithm.embeddingForwardPairMethodIsNonthrowing,
              algorithm.embeddingForwardPairUsesSameModelAndState,
              algorithm
                .embeddingForwardPairValidatedDenseConstructionCountPerCheck
                == 1,
              algorithm
                .wholeLogitsValidatedDenseConstructionCountPerForwardCheck
                == 1,
              algorithm.forwardEquivalenceMethod
                == "checkedTrainingInputPathForwardEquivalenceAtCurrentBoundaryV1",
              algorithm.forwardEquivalenceMethodReadOnly,
              algorithm.forwardEquivalenceBoundaries
                == ["initial", "source_boundary", "terminal"],
              algorithm.sameModelPreMutationEmbeddingForwardPairSeamRequired,
              algorithm.sameModelPreMutationWholeLogitsPairRequired,
              algorithm.tokensMustBeRankTwo,
              algorithm.tokensMustBeInt32,
              algorithm.tokenIDsMustBeWithinVocabularyBounds,
              algorithm.tokenBoundsPredicate
                == "all_token_ids_gte_0_and_lt_v_before_one_hot",
              algorithm.checkedVocabularySizeInt32ConversionRequired,
              algorithm.vocabularySizeInt32ConversionExpression
                == "guard let checkedInt32V = Int32(exactly: V) else { preconditionFailure() }",
              algorithm.tokenBoundsCombinedPredicateExpression
                == "((tokens .>= Int32(0)) .&& (tokens .< checkedInt32V)).all()",
              algorithm.tokenBoundsCheckedEvalExpression
                == "do { try checkedEval(tokenBounds) } catch { preconditionFailure() }",
              algorithm.tokenBoundsSynchronizationExpression
                == "StreamOrDevice.default.stream.synchronize()",
              algorithm.tokenBoundsHostReadExpression
                == "precondition(tokenBounds.item(Bool.self))",
              algorithm.tokenBoundsCheckedEvalFailureAction
                == "preconditionFailure",
              algorithm.tokenBoundsFalseFailureAction == "precondition",
              algorithm.tokenBoundsFailureClassification
                == "invalid_infrastructure_red_no_terminal_receipt",
              algorithm.tokenBoundsOperationOrder == [
                  "checked_vocabulary_size_int32_conversion",
                  "construct_combined_bounds_reduction",
                  "checked_eval_combined_bounds",
                  "gpu_stream_synchronize",
                  "read_one_bool_item",
                  "fail_closed_or_construct_one_hot",
              ],
              algorithm.tokenBoundsCheckedEvalCountPerDenseEmbeddingCall == 1,
              algorithm.tokenBoundsGPUSynchronizeCountPerDenseEmbeddingCall
                == 1,
              algorithm.tokenBoundsHostBoolItemCountPerDenseEmbeddingCall == 1,
              algorithm.tokenBoundsFailureOccursBeforeOneHotConstruction,
              algorithm.batchAndSequenceDimensionsMustBePositive,
              algorithm.sequenceLengthMustNotExceedMaximumSequenceLength,
              algorithm.checkedBatchTimesSequenceMultiplicationRequired,
              algorithm.embeddingWeightDType == "float32",
              algorithm.embeddingWeightExactShapeSymbols == ["V", "W"],
              algorithm.exactIntermediateShapeChecksRequired,
              !algorithm.dependencySourceBindingsClaimDeterminism,
              algorithm.forwardAndReplayExactnessRemainEmpirical,
              algorithm.tokenRank == 2,
              algorithm.tokenDType == "int32",
              algorithm.inputShapeSymbols == ["B", "S"],
              algorithm.flattenedTokensShapeSymbols == ["B*S", "1"],
              algorithm.vocabularyShapeSymbols == ["1", "V"],
              algorithm.oneHotExpression
                == "(flattenedTokens .== vocabulary).asType(.float32)",
              algorithm.oneHotDType == "float32",
              algorithm.oneHotShapeSymbols == ["B*S", "V"],
              algorithm.embeddingShapeSymbols == ["B*S", "W"],
              algorithm.restoredEmbeddingShapeSymbols == ["B", "S", "W"],
              algorithm.tinyOneHotElementCount
                == algorithm.tinyBatchSize
                    * algorithm.tinySequenceLength
                    * algorithm.tinyVocabularySize,
              algorithm.tinyBatchSize > 0,
              algorithm.tinySequenceLength > 0,
              algorithm.tinySequenceLength
                <= inheritedOriginalFixture.maximumSequenceLength,
              algorithm.tinyBatchSize
                <= inheritedOriginalFixture.maximumBatchSize,
              algorithm.tinyOneHotByteCount
                == algorithm.tinyOneHotElementCount * 4,
              algorithm.native300CompatibilityOneHotElementCount
                == algorithm.native300CompatibilityBatchSize
                    * algorithm.native300CompatibilitySequenceLength
                    * algorithm.native300CompatibilityVocabularySize,
              algorithm.native300CompatibilityOneHotByteCount
                == algorithm.native300CompatibilityOneHotElementCount * 4,
              algorithm.usesSingleFlattenedTwoDimensionalMatmul,
              !algorithm.usesBatchedBroadcastMatmul,
              !algorithm.usesGatherForInputEmbedding,
              !algorithm.usesScatterAddForInputEmbeddingWeightVJPByConstruction,
              !algorithm.maintainedGatherImplementationChanged,
              !algorithm.tiedOutputProjectionChanged,
              algorithm.checkedExactEmbeddingForwardEquivalenceRequired,
              algorithm.checkedExactWholeLogitsForwardEquivalenceRequired,
              assay.trialCount == 3,
              assay.expectedSourceSelectedTargetCount == 6,
              assay.expectedSuccessorSelectedTargetCount == 5,
              assay.branchNames.count == 3,
              assay.branchNames == [
                  "uninterrupted",
                  "source_snapshot",
                  "fresh_restored_from_source_snapshot",
              ],
              assay.fullTrajectoryBranchCount
                == assay.trialCount * assay.branchNames.count,
              assay.sameProcessRequired,
              assay.sameRetainedMetalDeviceRequired,
              assay.leaseAcquiredBeforeCoreGraphicsMetalOrMLX,
              assay.exactArmExecutionOrder
                == [assay.armAName, assay.armBName],
              assay.exactArmExecutionOrder == [
                  "maintained_embedding_gather_diagnostic",
                  "flattened_dense_one_hot_matmul_clearance",
              ],
              assay.armADiagnosticOnly,
              !assay.armACanGateClearance,
              assay.armACompletedTrialCount == assay.trialCount,
              assay.armAIndependentSourceStepDiagnosticPairCount
                == assay.trialCount,
              assay.armAPairBranchNames
                == ["uninterrupted", "source_snapshot"],
              assay.armASourceStepEqualityDisaggregated,
              assay.armAGlobalStepOneDisaggregated,
              assay.armASelectedTargetCountDisaggregated,
              assay.armAFirstTensorMismatchCoordinateRecorded,
              assay.armAFirstScalarMismatchCoordinateRecorded,
              !assay.armARestoreBranchRequired,
              !assay.armAMeasuredMismatchThrows,
              assay.armAInfrastructureFailureIsInvalidInfrastructure,
              !assay.armAMeasuredMismatchSkipsArmB,
              assay.armARecordsFirstMismatchWithoutThrowing,
              assay.armBOptInOnly,
              assay.armBFullTrialCount == assay.trialCount,
              assay.armBFullTrajectoryBranchCount
                == assay.fullTrajectoryBranchCount,
              assay.armBExpectedReadOnlySelectorID
                == "flattened_dense_one_hot_matmul_input_embedding_v1",
              assay.armBFreshConstructor.contains(
                "metalGPUIndexZero:stage5ReplacementTrainingInputPath:"),
              assay.armBRestoreConstructor.contains(
                "restoring:metalGPUIndexZero:stage5ReplacementTrainingInputPath:"),
              assay.armBValidMeasurementCompletesFullPlanBeforeTerminalReceipt,
              assay.sourceStepComparisonsDisaggregated,
              assay.noCombinedGuardPermitted,
              assay.continueAfterMeasuredMismatch,
              assay.armBReplayExactComparisonDomains
                == assay.armBReplayExactComparisonDomains.sorted(),
              assay.forwardEquivalenceComparisonDomains
                == assay.forwardEquivalenceComparisonDomains.sorted(),
              Set(assay.armBReplayExactComparisonDomains).isDisjoint(
                  with: Set(assay.forwardEquivalenceComparisonDomains)),
              assay.deterministicFirstMismatchComparisonDomainOrder
                == assay.forwardEquivalenceComparisonDomains
                    + assay.armBReplayExactComparisonDomains,
              assay.crossTrialExactComparisonRequired,
              assay.inMemorySnapshotOnly,
              !assay.durableCheckpointIOAuthorized,
              !assay.artifactRetentionAuthorized,
              receipt.receiptID
                == "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_receipt_v1",
              receipt.linePrefix
                == "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1=",
              receipt.schemaVersion == 1,
              receipt.authorityIDBinding == authorityID,
              receipt.authorityCanonicalSHA256Binding
                == "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1.canonicalSHA256",
              receipt.runtimeAuthorityCanonicalSHA256ResolvesTo64LowerHex,
              !receipt.runtimeAuthorityCanonicalSHA256MayEqualSymbolLiteral,
              receipt.terminalGreenStatuses
                == receipt.terminalGreenStatuses.sorted(),
              receipt.terminalGreenStatuses
                == ["MEASURED_EXACT_MISMATCH", "PASS_CLEARANCE"],
              receipt.gatingComparisonFields == [
                  "all_arm_b_exact_comparisons",
                  "all_forward_equivalence_checks",
              ],
              receipt.passPredicate
                == "valid_completed_measurement && all_arm_b_exact_comparisons && all_forward_equivalence_checks",
              receipt.measuredMismatchPredicate
                == "valid_completed_measurement && (!all_arm_b_exact_comparisons || !all_forward_equivalence_checks)",
              receipt.canonicalSortedJSONRequired,
              receipt.withoutEscapingSlashesRequired,
              receipt.encodeDecodeReencodeIdentityRequired,
              receipt.exactlyOneTerminalReceiptLineRequired,
              receipt.lineFeedTerminatorRequired,
              receipt.emittedWhileLeaseHeld,
              receipt.flushBeforeLeaseReleaseRequired,
              receipt.passRequiresAllArmBExactComparisons,
              receipt.passRequiresAllForwardEquivalenceChecks,
              !receipt.armAOutcomeCanChangeTerminalStatus,
              receipt.measuredMismatchRequiresValidCompletedMeasurement,
              receipt.measuredMismatchReportsFirstMismatchCoordinates,
              receipt.measuredMismatchIsGreenMeasuredOutcome,
              receipt.passFirstMismatchMustBeNull,
              receipt.measuredMismatchFirstMismatchMustBeNonNull,
              receipt.measuredMismatchRequiresAtLeastOneGatingComparisonFalse,
              receipt.firstMismatchCanIdentifyForwardBoundary,
              receipt.tensorMismatchRequiresShapeDTypeByteOffsetAndSHAs,
              receipt.scalarMismatchRequiresReferenceAndObservedFloat32Bits,
              receipt.forwardMismatchRequiresForwardBoundary,
              receipt.nonApplicableMismatchFieldsMustBeNull,
              receipt.firstMismatchDeterministicSelectionOrder == [
                  "comparison_domain_order",
                  "trial_ordinal",
                  "branch_order",
                  "utf8_path",
                  "byte_offset_or_scalar_name",
              ],
              !receipt.armAMismatchMayPopulateBFirstMismatch,
              !receipt.invalidInfrastructureEmitsTerminalResult,
              receipt.invalidInfrastructureExitsNonzero,
              receipt.requiredTopLevelKeys
                == receipt.requiredTopLevelKeys.sorted(),
              receipt.requiredAuthorityKeys
                == receipt.requiredAuthorityKeys.sorted(),
              receipt.requiredExecutionKeys
                == receipt.requiredExecutionKeys.sorted(),
              receipt.requiredEnvironmentKeys
                == receipt.requiredEnvironmentKeys.sorted(),
              receipt.requiredArmAOutcomeKeys
                == receipt.requiredArmAOutcomeKeys.sorted(),
              receipt.requiredArmBOutcomeKeys
                == receipt.requiredArmBOutcomeKeys.sorted(),
              receipt.requiredFirstMismatchCoordinateKeys
                == receipt.requiredFirstMismatchCoordinateKeys.sorted(),
              receipt.requiredForwardEquivalenceKeys
                == receipt.requiredForwardEquivalenceKeys.sorted(),
              receipt.requiredOperationCountKeys
                == receipt.requiredOperationCountKeys.sorted(),
              receipt.requiredCeilingKeys
                == receipt.requiredCeilingKeys.sorted(),
              receipt.greenOutcomeTrueCeilingKeys
                == receipt.greenOutcomeTrueCeilingKeys.sorted(),
              receipt.passOnlyTrueCeilingKeys
                == receipt.passOnlyTrueCeilingKeys.sorted(),
              receipt.alwaysFalseCeilingKeys
                == receipt.alwaysFalseCeilingKeys.sorted(),
              receipt.alwaysTrueResourceGuardCeilingKeys
                == receipt.alwaysTrueResourceGuardCeilingKeys.sorted(),
              Set(
                  receipt.greenOutcomeTrueCeilingKeys
                    + receipt.passOnlyTrueCeilingKeys
                    + receipt.alwaysFalseCeilingKeys
                    + receipt.alwaysTrueResourceGuardCeilingKeys)
                == Set(receipt.requiredCeilingKeys),
              Set(receipt.greenOutcomeTrueCeilingKeys).isDisjoint(
                  with: Set(receipt.passOnlyTrueCeilingKeys)),
              Set(receipt.greenOutcomeTrueCeilingKeys).isDisjoint(
                  with: Set(receipt.alwaysFalseCeilingKeys)),
              Set(receipt.passOnlyTrueCeilingKeys).isDisjoint(
                  with: Set(receipt.alwaysFalseCeilingKeys)),
              Set(receipt.alwaysTrueResourceGuardCeilingKeys).isDisjoint(
                  with: Set(
                      receipt.greenOutcomeTrueCeilingKeys
                        + receipt.passOnlyTrueCeilingKeys
                        + receipt.alwaysFalseCeilingKeys)),
              receipt.firstMismatchCoordinateNullableIffNoMismatch,
              receipt.requiredBSelectorIDCount
                == assay.armBFullTrajectoryBranchCount,
              receipt.requiredBSelectorIDValue
                == assay.armBExpectedReadOnlySelectorID,
              receipt.requiredArmBFreshConstructorValue
                == assay.armBFreshConstructor,
              receipt.requiredArmBRestoreConstructorValue
                == assay.armBRestoreConstructor,
              receipt.requiredForwardEquivalenceBoundaryNames
                == algorithm.forwardEquivalenceBoundaries,
              receipt.requiredArmATrialCount == assay.trialCount,
              receipt.requiredArmBSelectorBranchCount
                == assay.armBFullTrajectoryBranchCount,
              receipt.requiredArmBTrialCount == assay.trialCount,
              receipt.requiredArmBTrajectoryBranchCount
                == assay.armBFullTrajectoryBranchCount,
              receipt.expectedArmASourceStepCount
                == assay.armAIndependentSourceStepDiagnosticPairCount * 2,
              receipt.expectedArmBTrainingStepCount
                == assay.armBFullTrialCount * 5,
              receipt.expectedArmBSnapshotCount == assay.armBFullTrialCount,
              receipt.expectedArmBRestoreCount == assay.armBFullTrialCount,
              receipt.expectedArmBEvaluateCount
                == assay.armBFullTrialCount * 6,
              receipt.expectedArmBForwardEquivalenceCheckCount
                == assay.armBFullTrialCount
                    * algorithm.forwardEquivalenceBoundaries.count,
              receipt.expectedArmBDenseWholeLogitsCallCount
                == receipt.expectedArmBTrainingStepCount * 2
                    + receipt.expectedArmBEvaluateCount
                    + receipt.expectedArmBForwardEquivalenceCheckCount
                        * algorithm
                            .wholeLogitsValidatedDenseConstructionCountPerForwardCheck,
              receipt.expectedArmBDenseWholeLogitsCallCount == 57,
              receipt.expectedArmBInputEmbeddingPairSeamCount
                == receipt.expectedArmBForwardEquivalenceCheckCount,
              receipt.expectedArmBInputEmbeddingPairSeamCount == 9,
              receipt.expectedArmBDenseEmbeddingConstructionCount
                == receipt.expectedArmBDenseWholeLogitsCallCount
                    + receipt.expectedArmBInputEmbeddingPairSeamCount
                        * algorithm
                            .embeddingForwardPairValidatedDenseConstructionCountPerCheck,
              receipt.expectedArmBDenseEmbeddingConstructionCount == 66,
              receipt.expectedArmBTokenBoundsValidationCount
                == receipt.expectedArmBDenseEmbeddingConstructionCount,
              receipt.expectedArmBTokenBoundsValidationCount == 66,
              receipt.expectedArmBTokenBoundsCheckedEvalCount
                == receipt.expectedArmBDenseEmbeddingConstructionCount
                    * algorithm
                        .tokenBoundsCheckedEvalCountPerDenseEmbeddingCall,
              receipt.expectedArmBTokenBoundsGPUSynchronizeCount
                == receipt.expectedArmBDenseEmbeddingConstructionCount
                    * algorithm
                        .tokenBoundsGPUSynchronizeCountPerDenseEmbeddingCall,
              receipt.expectedArmBTokenBoundsHostBoolItemCount
                == receipt.expectedArmBDenseEmbeddingConstructionCount
                    * algorithm
                        .tokenBoundsHostBoolItemCountPerDenseEmbeddingCall,
              receipt.expectedArmBTokenBoundsCheckedEvalCount == 66,
              receipt.expectedArmBTokenBoundsGPUSynchronizeCount == 66,
              receipt.expectedArmBTokenBoundsHostBoolItemCount == 66,
              receipt.synchronizeCountMustMatchComparedArrayAndForwardCheckPlan,
              receipt.artifactUploadCount == 0,
              receipt.rerunCount == 0,
              receipt.retryCount == 0,
              closure.exactChangedPaths == closure.exactChangedPaths.sorted(),
              Set(closure.exactChangedPaths).count == 5,
              closure.expectedIsolatedTestCount
                == closure.expectedIsolatedGroupTestCounts.reduce(0, +),
              closure.expectedFocusedWholeTestCount
                == closure.expectedRootTestCount
                    + closure.expectedIsolatedTestCount,
              closure.expectedTotalTestCount
                == closure.expectedFocusedWholeTestCount
                    + closure.expectedMetalTestCount
                    + closure.expectedMaintainedRuntimeTestCount
                    + closure.expectedTokenizerTestCount,
              closure.expectedTotalTestCount == 109,
              closure.originalStage5LauncherInvocationCount == 0,
              closure.replacementStage5LauncherInvocationCount == 0,
              closure.stage6LauncherInvocationCount == 0,
              closure.artifactCount == 0,
              closure.authorityOnlyNoMetalOrMLX,
              successor.exactChangedPaths
                == successor.exactChangedPaths.sorted(),
              Set(successor.exactChangedPaths).count == 10,
              successor.expectedIsolatedTestCount
                == successor.expectedIsolatedGroupTestCounts.reduce(0, +),
              successor.expectedFocusedWholeTestCount
                == successor.expectedRootTestCount
                    + successor.expectedIsolatedTestCount,
              successor.expectedPreReplacementTestCount
                == successor.expectedFocusedWholeTestCount
                    + successor.expectedMetalTestCount
                    + successor.expectedMaintainedRuntimeTestCount
                    + successor.expectedTokenizerTestCount,
              successor.expectedTotalTestCount
                == successor.expectedPreReplacementTestCount
                    + successor.expectedReplacementTestCount,
              successor.replacementLauncherInvocationCount == 1,
              successor.replacementBuildCount == 1,
              successor.replacementDirectXCTestCount == 1,
              successor.replacementReceiptCount == 1,
              successor.originalLauncherInvocationCount == 0,
              successor.stage6LauncherInvocationCount == 0,
              successor.exactMainExecutionOpportunityCount == 1,
              !successor.manifestMutationAuthorized,
              !successor.packageLockMutationAuthorized,
              !successor.originalStage5LauncherMutationAuthorized,
              !successor.defaultGatherPathMutationAuthorized,
              successor.decoderSourceMutationAuthorized,
              successor.decoderSourceMutationScope.contains(
                "package_trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1"),
              successor.trainingSourceMutationAuthorized,
              successor.trainingSourceMutationScope.contains(
                "immutable_stage5ReplacementTrainingInputPath_selector"),
              !successor.otherProductionSourceMutationAuthorized,
              successor.newPackageOnlyOptInPathAuthorized,
              successor.retainedAuthorityTestMutationAuthorized,
              successor.retainedAuthorityTestClass
                == "PrimeNativeDecoderAuthorityTests",
              successor.retainedAuthorityTestImports
                == ["CryptoKit", "Foundation", "XCTest", "PrimeCore"],
              successor.retainedAuthorityTestMethodCount == 11,
              successor.retainedAuthorityTestMethodNames.count
                == successor.retainedAuthorityTestMethodCount,
              Set(successor.retainedAuthorityTestMethodNames).count == 11,
              successor.retainedHistoricalMetalRepairGitBlob
                == "835a4826549e1f28ec27e3533f746218beb3bdf2",
              successor.retainedHistoricalMetalRepairByteCount == 39_050,
              successor.retainedHistoricalMetalRepairSHA256
                == "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
              successor.retainedGitBlobOIDOccurrenceCount == 2,
              successor.retainedCryptoKitSHA1FramingOccurrenceCount == 1,
              successor.retainedAllOtherAssertionsByteSemanticallyPreserved,
              successor.newCurrentIdentityObservationAuthorized,
              transition.passClearanceEstablishesStage5Result,
              transition.passClearanceEstablishesStage5MechanicsSuccess,
              transition.passClearanceEstablishesStage5AssayClearance,
              transition.passClearanceEstablishesRepeatedSameDeviceBPathDeterminism,
              transition.passClearanceEstablishesExactSameDeviceBPathGradientBytes,
              !transition.passClearanceEstablishesDefaultGatherDeterminism,
              !transition.passClearanceEstablishesArbitraryTokenDeterminism,
              !transition.passClearanceEstablishesCrossDeviceDeterminism,
              transition.measuredMismatchEstablishesStage5Result,
              transition.measuredMismatchEstablishesStage5MechanicsSuccess,
              !transition.measuredMismatchEstablishesStage5Clearance,
              !transition.measuredMismatchPermitsRerun,
              transition.eitherGreenOutcomeConsumesOneShot,
              transition.invalidInfrastructureConsumesExactMainOpportunity,
              !transition.invalidInfrastructureEstablishesStage5Result,
              transition.successorObservationRequiredAfterAnyTerminalGreenOutcome,
              !transition.stage7AuthorizedByPassClearance,
              transition.stage7RequiresNewBSpecificNative300ResourceWitness,
              transition.stage7RequiresSeparateAuthorityAfterWitness,
              ceiling.replacementMechanicsImplementationAuthorizedAfterGreenClosure,
              ceiling.oneExactMainReplacementExecutionAuthorizedAfterGreenClosure,
              ceiling.stage6ResourceClearanceRemainsHistorical,
              ceiling.bSpecificNative300ResourceWitnessRequiresSeparateAuthority,
              closureFalseClaims.allSatisfy({ !$0 }),
              orderedRequiredSeparateActions.count == 6
        else {
            throw
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityError
                    .contractDrift("exact V1")
        }
    }
}
