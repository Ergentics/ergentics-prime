// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityError:
    Error, Equatable, Sendable
{
    case contractDrift
    case nonCanonicalEncoding
}

public enum PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1:
    String, Codable, CaseIterable, Equatable, Sendable
{
    case uninterrupted = "uninterrupted"
    case sourceSnapshot = "source_snapshot"
    case freshRestoredFromSourceSnapshot =
        "fresh_restored_from_source_snapshot"
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryRepositoryV1:
    Codable, Equatable, Sendable
{
    public let repository: String
    public let ref: String
    public let stage4RetirementMergeRevision: String
    public let stage4RetirementTree: String
    public let orderedParentRevisions: [String]
    public let embeddedSourceIdentitySHA256: String
    public let embeddedSourceProvenanceGitBlob: String
    public let embeddedSourceProvenanceSHA256: String
    public let designAuthorityCanonicalSHA256: String
    public let designAuthoritySourceGitBlob: String
    public let designAuthoritySourceSHA256: String
    public let designAuthorityTestGitBlob: String
    public let designAuthorityTestSHA256: String
    public let stage4AuthorityCanonicalSHA256: String
    public let stage4AuthoritySourceGitBlob: String
    public let stage4AuthoritySourceSHA256: String
    public let stage4RepairAuthorityCanonicalSHA256: String
    public let stage4RepairAuthoritySourceGitBlob: String
    public let stage4RepairAuthoritySourceSHA256: String
    public let stage4ObservationCanonicalSHA256: String
    public let stage4ObservationSourceGitBlob: String
    public let stage4ObservationSourceSHA256: String
    public let stage4ObservationTestGitBlob: String
    public let stage4ObservationTestSHA256: String
    public let stage4LauncherGitBlob: String
    public let stage4LauncherSHA256: String
    public let stage4RetirementMergeIsCurrentAuthorityBase: Bool
    public let authorityMustMergeAndPassExactMainBeforeImplementation: Bool
    public let implementationMustBindFinalAuthorityMergeAndTree: Bool
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryRunV1:
    Codable, Equatable, Sendable
{
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let workflowRunID: Int
    public let workflowRunNumber: Int
    public let checkSuiteID: Int
    public let runAttempt: Int
    public let activeJobID: Int
    public let reviewedJobID: Int
    public let exactHeadPushRunCount: Int
    public let rerunCount: Int
    public let artifactCount: Int
    public let activeJobConclusion: String
    public let reviewedJobConclusion: String
    public let terminalConclusion: String
    public let focusedRootTestCount: Int
    public let focusedIsolatedTestCount: Int
    public let focusedWholeTestCount: Int
    public let metalTestCount: Int
    public let maintainedRuntimeTestCount: Int
    public let maintainedRuntimeReceiptCount: Int
    public let tokenizerTestCount: Int
    public let tokenizerReceiptCount: Int
    public let stage4InvocationCount: Int
    public let stage4ReceiptCount: Int
    public let stage4StartedCount: Int
    public let stage4PassedCount: Int
    public let stage4FailureCount: Int
    public let stage4SkipCount: Int
    public let totalTestCount: Int
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectorySecureFetchV1:
    Codable, Equatable, Sendable
{
    public let stepConclusion: String
    public let invocationCount: Int
    public let completionCount: Int
    public let authenticatedDepthOneFetchCount: Int
    public let submoduleUpdateInvocationCount: Int
    public let mlxCloneCount: Int
    public let mlxCCloneCount: Int
    public let workflowAuthoredRetryCount: Int
    public let gitInternalRetryScheduledCount: Int
    public let tlsFailureCount: Int
    public let tlsVerificationBypassCount: Int
    public let customCAInstallationCount: Int
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryStage4ReceiptV1:
    Codable, Equatable, Sendable
{
    public let receiptPrefixOccurrenceCount: Int
    public let rawJSONByteCount: Int
    public let rawJSONSHA256: String
    public let rawJSONWasCanonical: Bool
    public let publishedFileCount: Int
    public let injectedFailureCount: Int
    public let finalCommitManifestPublishedLast: Bool
    public let externallySuppliedExactCommitBindingRequired: Bool
    public let everyPartialPrecommitInventoryQuarantined: Bool
    public let exactStage3SnapshotRoundTripEstablished: Bool
    public let ephemeralPrivateRootReclaimed: Bool
    public let retainedArtifactEstablished: Bool
    public let artifactUploadInvoked: Bool
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryPredecessorV1:
    Codable, Equatable, Sendable
{
    public let stage4Execution: PrimeNativeDecoderTinyRepeatedMetalTrajectoryRunV1
    public let stage4ExecutionSecureFetch:
        PrimeNativeDecoderTinyRepeatedMetalTrajectorySecureFetchV1
    public let stage4Receipt:
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryStage4ReceiptV1
    public let stage4Retirement: PrimeNativeDecoderTinyRepeatedMetalTrajectoryRunV1
    public let stage4RetirementSecureFetch:
        PrimeNativeDecoderTinyRepeatedMetalTrajectorySecureFetchV1
    public let stage4LauncherSourcePreserved: Bool
    public let stage4SuccessfulAttemptConsumed: Bool
    public let stage4MechanicsEstablished: Bool
    public let stage4InvocationRetired: Bool
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryRoadmapV1:
    Codable, Equatable, Sendable
{
    public let stageID: String
    public let objective: String
    public let requiredPredecessorStageID: String
    public let nextStageID: String
    public let nextStageObjective: String
    public let separateStage5AuthorityRequired: Bool
    public let stage6RequiresSeparateAuthority: Bool
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryEnvironmentV1:
    Codable, Equatable, Sendable
{
    public let requiredBindings: [String]
    public let mlxEnableTF32: String
    public let metalDeviceIndex: Int
    public let exactMetalDeviceCount: Int
    public let sameMetalDeviceRequiredAcrossEveryTrialAndBranch: Bool
    public let crossDeviceComparisonAuthorized: Bool
    public let explicitDefaultGPUStreamRequired: Bool
    public let checkedEvaluationRequiredForEveryComparedArray: Bool
    public let explicitSynchronizeRequiredBeforeEveryByteRead: Bool
    public let exclusiveMetalDeviceLeaseRequiredForWholeAssay: Bool
    public let leaseType: String
    public let leaseModule: String
    public let trainingValidationTestImportsPrimeCore: Bool
    public let trainingValidationTestDirectlyOwnsFullDurationLease: Bool
    public let leaseAcquiredBeforeCoreGraphicsMetalOrMLXAccess: Bool
    public let leaseHeldThroughPostflightAndReceipt: Bool
    public let leaseReleasedOnlyAfterReceipt: Bool
    public let singletonDeviceEnumerationRequired: Bool
    public let indexZeroMustMatchDefaultDevice: Bool
    public let postflightDeviceIdentityReverificationRequired: Bool
    public let compileModeMustBeRecorded: Bool
    public let swiftPMBuildConfiguration: String
    public let mlxGraphCompileMode: String
    public let mlxCompileTransformInvocationCount: Int
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryFixtureV1:
    Codable, Equatable, Sendable
{
    public let vocabularySize: Int
    public let modelWidth: Int
    public let layerCount: Int
    public let queryHeadCount: Int
    public let keyValueHeadCount: Int
    public let headWidth: Int
    public let intermediateWidth: Int
    public let maximumSequenceLength: Int
    public let maximumBatchSize: Int
    public let initializerSeed: Int
    public let uniqueParameterCount: Int
    public let modelTensorCount: Int
    public let firstMomentTensorCount: Int
    public let secondMomentTensorCount: Int
    public let sourceSnapshotGlobalStep: Int
    public let terminalGlobalStep: Int
    public let sourceStepTokenIDs: [[Int]]
    public let sourceStepValidTokenCounts: [Int]
    public let sourceStepCompletionMask: [[Bool]]
    public let successorStepTokenIDs: [[Int]]
    public let successorStepValidTokenCounts: [Int]
    public let successorStepCompletionMask: [[Bool]]
    public let repeatedTokenIDs: [Int]
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryAssayV1:
    Codable, Equatable, Sendable
{
    public let independentTrialCount: Int
    public let totalTrajectoryBranchExecutionCount: Int
    public let allTrialsRunInOneProcess: Bool
    public let exactBranchesPerTrial:
        [PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1]
    public let uninterruptedBranchStartsFromFreshFixture: Bool
    public let sourceSnapshotBranchStartsFromFreshFixture: Bool
    public let sourceSnapshotBranchCapturesAtExactStep: Bool
    public let sourceSnapshotCaptureIsReadOnly: Bool
    public let sourceSnapshotBranchContinuesToTerminalStep: Bool
    public let restoredBranchUsesFreshModelOptimizerRNGAndCursor: Bool
    public let restoredBranchLoadsOnlyTheSourceSnapshot: Bool
    public let everyBranchReachesTerminalStep: Bool
    public let everyTrialUsesFreshObjectsAndArrays: Bool
    public let objectOrArrayAliasingAcrossBranchesAuthorized: Bool
    public let stateReuseAcrossTrialsAuthorized: Bool
    public let implicitOrGlobalMLXRandomStateAuthorized: Bool
    public let sourceSnapshotExistsOnlyInMemory: Bool
    public let durableCheckpointIOAuthorized: Bool
    public let filesystemArtifactIOAuthorized: Bool
    public let networkIOAuthorized: Bool
    public let buildCount: Int
    public let directXCTestCount: Int
    public let receiptID: String
    public let receiptPrefix: String
    public let testClass: String
    public let testMethod: String
    public let testFilter: String
    public let expectedFailureCount: Int
    public let expectedSkipCount: Int
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryEqualityV1:
    Codable, Equatable, Sendable
{
    public let exactComparedComponents: [String]
    public let exactRawGradientBytesRequired: Bool
    public let exactSourceStepRawGradientBytesRequired: Bool
    public let exactSuccessorStepRawGradientBytesRequired: Bool
    public let exactClippedGradientBytesRequired: Bool
    public let exactSourceStepClippedGradientBytesRequired: Bool
    public let exactSuccessorStepClippedGradientBytesRequired: Bool
    public let exactModelParameterBytesRequired: Bool
    public let exactAdamFirstMomentBytesRequired: Bool
    public let exactAdamSecondMomentBytesRequired: Bool
    public let exactRNGDomainKeyCounterAndConsumptionBytesRequired: Bool
    public let exactNextUnconsumedCursorBytesRequired: Bool
    public let exactTerminalStateBytesRequired: Bool
    public let exactStepOneBoundaryStateAcrossAllBranchesRequired: Bool
    public let exactLossNormAndClipScalarFloat32BitPatternsRequired: Bool
    public let exactReadOnlyEvaluationFloat32BitPatternsRequired: Bool
    public let canonicalParameterPathOrderRequired: Bool
    public let canonicalShapeAndDTypeOrderRequired: Bool
    public let float32LittleEndianByteReadOrderRequired: Bool
    public let sourceStepEqualityBranches:
        [PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1]
    public let successorAndTerminalEqualityBranches:
        [PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1]
    public let exactSourceStepWithinTrialAcrossProducingBranchesRequired: Bool
    public let exactSourceStepAcrossAllTrialsRequired: Bool
    public let exactSuccessorAndTerminalWithinTrialAcrossAllBranchesRequired: Bool
    public let exactSuccessorAndTerminalAcrossAllTrialsRequired: Bool
    public let tensorShapesAndDTypesMustMatchBeforeByteComparison: Bool
    public let unorderedOrToleranceComparisonAuthorized: Bool
    public let ulpToleranceEstablishesTrajectoryExactResume: Bool
    public let toleranceOnlyEstablishesFunctionalContinuity: Bool
    public let resultEstablishedByThisAuthority: Bool
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectorySuccessorScopeV1:
    Codable, Equatable, Sendable
{
    public let exactChangedPaths: [String]
    public let rootPackageManifestMutationAuthorized: Bool
    public let rootPackageResolvedMutationAuthorized: Bool
    public let trainingValidationManifestMutationAuthorized: Bool
    public let trainingValidationLockMutationAuthorized: Bool
    public let trainingSourceMutationAuthorized: Bool
    public let existingMetalLauncherMutationAuthorized: Bool
    public let existingRuntimeLauncherMutationAuthorized: Bool
    public let existingTokenizerLauncherMutationAuthorized: Bool
    public let existingStage4LauncherMutationAuthorized: Bool
    public let newStage5LauncherRequired: Bool
    public let newTrainingValidationOneMethodTestRequired: Bool
    public let secureFetchMutationAuthorized: Bool
    public let workflowTimeoutChangeAuthorized: Bool
    public let existingCPUTrainingBehaviorMutationAuthorized: Bool
    public let stage5BoundedDevicePolicyRequired: Bool
    public let activeCheckoutDepth: Int
    public let reviewedCheckoutDepth: Int
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryAuthorityClosureScopeV1:
    Codable, Equatable, Sendable
{
    public let exactChangedPaths: [String]
    public let exactChangedPathCount: Int
    public let sourceAndTestAreOnlyNewPaths: Bool
    public let rootPackageManifestMutationAuthorized: Bool
    public let rootPackageResolvedMutationAuthorized: Bool
    public let trainingSourceMutationAuthorized: Bool
    public let stage5LauncherCreationAuthorized: Bool
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectorySuiteV1:
    Codable, Equatable, Sendable
{
    public let authorityRootTestCount: Int
    public let isolatedTestCount: Int
    public let implementationFocusedWholeTestCount: Int
    public let predecessorMetalTestCount: Int
    public let predecessorRuntimeTestCount: Int
    public let predecessorTokenizerTestCount: Int
    public let preStage5TotalTestCount: Int
    public let stage5DirectXCTestCount: Int
    public let totalTestCount: Int
    public let metalLauncherInvocationCount: Int
    public let runtimeLauncherInvocationCount: Int
    public let tokenizerLauncherInvocationCount: Int
    public let stage4LauncherInvocationCount: Int
    public let authorityStage5LauncherInvocationCount: Int
    public let authorityStage5ReceiptCount: Int
    public let authorityClosureLiveOrder: [String]
    public let futureMechanicsLiveOrder: [String]
}

public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryAuthorityCeilingV1:
    Codable, Equatable, Sendable
{
    public let authorityOnlyNoAssayResultEvidence: Bool
    public let mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: Bool
    public let oneExactMainExecutionOpportunityAuthorized: Bool
    public let threeBoundedSameProcessAssayTrialsAuthorized: Bool
    public let inMemorySourceSnapshotAuthorized: Bool
    public let additionalExecutionOrRerunAuthorized: Bool
    public let durableCheckpointIOAuthorized: Bool
    public let retainedArtifactAuthorized: Bool
    public let artifactUploadAuthorized: Bool
    public let crossDeviceClaimAuthorized: Bool
    public let exactMetalGradientBytesEstablished: Bool
    public let metalDeterminismEstablished: Bool
    public let trainingExecutionObserved: Bool
    public let stage4RerunAuthorized: Bool
    public let stage6Authorized: Bool
    public let native300MAllocationAuthorized: Bool
    public let native300MTrainingAuthorized: Bool
    public let generalTrainingAuthorized: Bool
    public let generalTrainingResumeEstablished: Bool
    public let modelQualityEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let candidateAdmissionGranted: Bool
    public let downstreamTrialAuthorized: Bool
    public let canaryAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
}

/// Pure authority for the fifth trajectory stage. It freezes one later tiny,
/// same-device Metal determinism assay and performs no training, Metal,
/// filesystem, checkpoint, network, artifact, or publication operation.
public struct PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityV1:
    Codable, Equatable, Sendable
{
    public static let canonicalSHA256 =
        "00c49e63315b2aacb439204e778f54bcf63c2fdf643282f3bd64e2b3b4094089"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_authority_v1",
        repository: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            stage4RetirementMergeRevision:
                "b198ba81f4c6958d70b56ea3a23f56f07fa90854",
            stage4RetirementTree:
                "54af1d38bdd454a924228a37a5b76a64ac5b56ae",
            orderedParentRevisions: [
                "8c310bb61fb9b44f1e789332eb3cfc29681ee407",
                "9f9f792edaba668cd5bd2183cfbf00ca12b31193",
            ],
            embeddedSourceIdentitySHA256:
                "24bb8290a09174ea70b14cc7f3303cf20a7912db5ff7e385d3e62051a3324abe",
            embeddedSourceProvenanceGitBlob:
                "12e42286d12b08327bfc1b2393c7dc136d033d6c",
            embeddedSourceProvenanceSHA256:
                "fac7bdf1766ce52861df2df81579c7324f44753d092f554bfc42b91c0767af11",
            designAuthorityCanonicalSHA256:
                "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
            designAuthoritySourceGitBlob:
                "20bcbf28ddcfa9a6339510d53e81da02ada9953e",
            designAuthoritySourceSHA256:
                "92194cb171eb1219393008c1dcd3b1c7dfcb2fd9232f4149391dfc428a5e7969",
            designAuthorityTestGitBlob:
                "186dc546c7f889f28d700322ac06b7b8a8a4c252",
            designAuthorityTestSHA256:
                "1fc9d8a4dde9e5e4192de9c248076f218ea38094eb68c335ade6de50862eb58b",
            stage4AuthorityCanonicalSHA256:
                "0b167685f0cc10cbf5d705d6cf67b72b54555dfa52b9f4aaebd00613e057b031",
            stage4AuthoritySourceGitBlob:
                "c9a1a23e65454fd7fd8f46e118c04060d0a78123",
            stage4AuthoritySourceSHA256:
                "6b38af1926584bc47d20971299214e737bbda931395b08cef6bb5bf64b439ba8",
            stage4RepairAuthorityCanonicalSHA256:
                "6a6dfc7b30319f9ccc1d17c2f08282c266962cd500d47696cbb42b4b1b0ff826",
            stage4RepairAuthoritySourceGitBlob:
                "3e2c1065d15f2a3dc40a9aebe716d8a07e9d8d9e",
            stage4RepairAuthoritySourceSHA256:
                "a3ceff4fba525ec8bc625ce416feed78050f52da354bbcd3068e74552a8efe60",
            stage4ObservationCanonicalSHA256:
                "7239edc86e007b1a8b6fa7a742bfb812e8ef8caa4b1dc8dbcb32b66b5b88e5e0",
            stage4ObservationSourceGitBlob:
                "f33ea9a4d567002499170946928cc1f11ccc8000",
            stage4ObservationSourceSHA256:
                "5aa6f297acb4070e62dcc14fb8caf4e6852b41a43ddd26e85ece9b1597091ac0",
            stage4ObservationTestGitBlob:
                "35f76f1d39fea0f70cfe46f7092d38bab02da13e",
            stage4ObservationTestSHA256:
                "e28f7d1871023055638595049b81f43f15ca4691c356ffc9555c81b9c97cc273",
            stage4LauncherGitBlob:
                "4184e23941460fe397e284e094d782f1265d19d9",
            stage4LauncherSHA256:
                "e3eb8a66340c924bbb579023eee04eaee1242a8a682f17ae668898ee8d36c6a2",
            stage4RetirementMergeIsCurrentAuthorityBase: true,
            authorityMustMergeAndPassExactMainBeforeImplementation: true,
            implementationMustBindFinalAuthorityMergeAndTree: true),
        predecessor: .init(
            stage4Execution: .init(
                mergeRevision:
                    "8c310bb61fb9b44f1e789332eb3cfc29681ee407",
                mergeTree:
                    "4508cd0d62cfe6e9405ea2b9e4cfcb197965c5e5",
                orderedParentRevisions: [
                    "f15f22b580aebf924c1dfc4a5636263f962a659c",
                    "ef9fc40c9bc947f78910f9f8cf8a243566f63728",
                ],
                workflowRunID: 31_726_013_984,
                workflowRunNumber: 97,
                checkSuiteID: 86_069_785_338,
                runAttempt: 1,
                activeJobID: 94_534_454_341,
                reviewedJobID: 94_535_376_461,
                exactHeadPushRunCount: 1,
                rerunCount: 0,
                artifactCount: 0,
                activeJobConclusion: "success",
                reviewedJobConclusion: "success",
                terminalConclusion: "success",
                focusedRootTestCount: 50,
                focusedIsolatedTestCount: 6,
                focusedWholeTestCount: 56,
                metalTestCount: 44,
                maintainedRuntimeTestCount: 1,
                maintainedRuntimeReceiptCount: 1,
                tokenizerTestCount: 1,
                tokenizerReceiptCount: 1,
                stage4InvocationCount: 1,
                stage4ReceiptCount: 1,
                stage4StartedCount: 1,
                stage4PassedCount: 1,
                stage4FailureCount: 0,
                stage4SkipCount: 0,
                totalTestCount: 103),
            stage4ExecutionSecureFetch: .init(
                stepConclusion: "success",
                invocationCount: 1,
                completionCount: 1,
                authenticatedDepthOneFetchCount: 1,
                submoduleUpdateInvocationCount: 1,
                mlxCloneCount: 1,
                mlxCCloneCount: 1,
                workflowAuthoredRetryCount: 0,
                gitInternalRetryScheduledCount: 0,
                tlsFailureCount: 0,
                tlsVerificationBypassCount: 0,
                customCAInstallationCount: 0),
            stage4Receipt: .init(
                receiptPrefixOccurrenceCount: 1,
                rawJSONByteCount: 4_147,
                rawJSONSHA256:
                    "a0bbebb611b12ef1e88ffe625120b86a3a0caf7f29f0edbf20233c7fbe244fbd",
                rawJSONWasCanonical: true,
                publishedFileCount: 4,
                injectedFailureCount: 7,
                finalCommitManifestPublishedLast: true,
                externallySuppliedExactCommitBindingRequired: true,
                everyPartialPrecommitInventoryQuarantined: true,
                exactStage3SnapshotRoundTripEstablished: true,
                ephemeralPrivateRootReclaimed: true,
                retainedArtifactEstablished: false,
                artifactUploadInvoked: false),
            stage4Retirement: .init(
                mergeRevision:
                    "b198ba81f4c6958d70b56ea3a23f56f07fa90854",
                mergeTree:
                    "54af1d38bdd454a924228a37a5b76a64ac5b56ae",
                orderedParentRevisions: [
                    "8c310bb61fb9b44f1e789332eb3cfc29681ee407",
                    "9f9f792edaba668cd5bd2183cfbf00ca12b31193",
                ],
                workflowRunID: 31_732_666_495,
                workflowRunNumber: 99,
                checkSuiteID: 86_089_225_356,
                runAttempt: 1,
                activeJobID: 94_556_644_948,
                reviewedJobID: 94_557_541_771,
                exactHeadPushRunCount: 1,
                rerunCount: 0,
                artifactCount: 0,
                activeJobConclusion: "success",
                reviewedJobConclusion: "success",
                terminalConclusion: "success",
                focusedRootTestCount: 51,
                focusedIsolatedTestCount: 6,
                focusedWholeTestCount: 57,
                metalTestCount: 44,
                maintainedRuntimeTestCount: 1,
                maintainedRuntimeReceiptCount: 1,
                tokenizerTestCount: 1,
                tokenizerReceiptCount: 1,
                stage4InvocationCount: 0,
                stage4ReceiptCount: 0,
                stage4StartedCount: 0,
                stage4PassedCount: 0,
                stage4FailureCount: 0,
                stage4SkipCount: 0,
                totalTestCount: 103),
            stage4RetirementSecureFetch: .init(
                stepConclusion: "success",
                invocationCount: 1,
                completionCount: 1,
                authenticatedDepthOneFetchCount: 1,
                submoduleUpdateInvocationCount: 1,
                mlxCloneCount: 1,
                mlxCCloneCount: 1,
                workflowAuthoredRetryCount: 0,
                gitInternalRetryScheduledCount: 0,
                tlsFailureCount: 0,
                tlsVerificationBypassCount: 0,
                customCAInstallationCount: 0),
            stage4LauncherSourcePreserved: true,
            stage4SuccessfulAttemptConsumed: true,
            stage4MechanicsEstablished: true,
            stage4InvocationRetired: true),
        roadmap: .init(
            stageID:
                "tiny_repeated_metal_trajectory_determinism_assay_v1",
            objective:
                "measure_repeated_same_device_uninterrupted_and_resumed_exact_gradient_and_parameter_bytes",
            requiredPredecessorStageID:
                "tiny_durable_multileaf_commit_fault_injection_v1",
            nextStageID:
                "native300m_resource_only_one_step_probe_v1",
            nextStageObjective:
                "measure_native300m_one_step_memory_disk_and_duration_without_quality_or_checkpoint_claim",
            separateStage5AuthorityRequired: true,
            stage6RequiresSeparateAuthority: true),
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
            metalDeviceIndex: 0,
            exactMetalDeviceCount: 1,
            sameMetalDeviceRequiredAcrossEveryTrialAndBranch: true,
            crossDeviceComparisonAuthorized: false,
            explicitDefaultGPUStreamRequired: true,
            checkedEvaluationRequiredForEveryComparedArray: true,
            explicitSynchronizeRequiredBeforeEveryByteRead: true,
            exclusiveMetalDeviceLeaseRequiredForWholeAssay: true,
            leaseType: "PrimeMetalDeviceLease",
            leaseModule: "PrimeCore",
            trainingValidationTestImportsPrimeCore: true,
            trainingValidationTestDirectlyOwnsFullDurationLease: true,
            leaseAcquiredBeforeCoreGraphicsMetalOrMLXAccess: true,
            leaseHeldThroughPostflightAndReceipt: true,
            leaseReleasedOnlyAfterReceipt: true,
            singletonDeviceEnumerationRequired: true,
            indexZeroMustMatchDefaultDevice: true,
            postflightDeviceIdentityReverificationRequired: true,
            compileModeMustBeRecorded: true,
            swiftPMBuildConfiguration: "debug",
            mlxGraphCompileMode:
                "eager_uncompiled_no_compile_transform",
            mlxCompileTransformInvocationCount: 0),
        fixture: .init(
            vocabularySize: 32,
            modelWidth: 16,
            layerCount: 2,
            queryHeadCount: 4,
            keyValueHeadCount: 2,
            headWidth: 4,
            intermediateWidth: 32,
            maximumSequenceLength: 16,
            maximumBatchSize: 2,
            initializerSeed: 7,
            uniqueParameterCount: 5_200,
            modelTensorCount: 20,
            firstMomentTensorCount: 20,
            secondMomentTensorCount: 20,
            sourceSnapshotGlobalStep: 1,
            terminalGlobalStep: 2,
            sourceStepTokenIDs: [
                [1, 1, 1, 2, 3, 0],
                [4, 5, 6, 7, 8, 9],
            ],
            sourceStepValidTokenCounts: [5, 6],
            sourceStepCompletionMask: [
                [false, false, false, true, true, false],
                [false, false, true, true, true, true],
            ],
            successorStepTokenIDs: [
                [10, 11, 12, 13, 0, 0],
                [14, 15, 15, 15, 16, 0],
            ],
            successorStepValidTokenCounts: [4, 5],
            successorStepCompletionMask: [
                [false, true, true, true, false, false],
                [false, false, false, true, true, false],
            ],
            repeatedTokenIDs: [1, 15]),
        assay: .init(
            independentTrialCount: 3,
            totalTrajectoryBranchExecutionCount: 9,
            allTrialsRunInOneProcess: true,
            exactBranchesPerTrial:
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1.allCases,
            uninterruptedBranchStartsFromFreshFixture: true,
            sourceSnapshotBranchStartsFromFreshFixture: true,
            sourceSnapshotBranchCapturesAtExactStep: true,
            sourceSnapshotCaptureIsReadOnly: true,
            sourceSnapshotBranchContinuesToTerminalStep: true,
            restoredBranchUsesFreshModelOptimizerRNGAndCursor: true,
            restoredBranchLoadsOnlyTheSourceSnapshot: true,
            everyBranchReachesTerminalStep: true,
            everyTrialUsesFreshObjectsAndArrays: true,
            objectOrArrayAliasingAcrossBranchesAuthorized: false,
            stateReuseAcrossTrialsAuthorized: false,
            implicitOrGlobalMLXRandomStateAuthorized: false,
            sourceSnapshotExistsOnlyInMemory: true,
            durableCheckpointIOAuthorized: false,
            filesystemArtifactIOAuthorized: false,
            networkIOAuthorized: false,
            buildCount: 1,
            directXCTestCount: 1,
            receiptID:
                "prime_native_decoder_stage5_tiny_repeated_metal_trajectory_determinism_receipt_v1",
            receiptPrefix:
                "PRIME_NATIVE_DECODER_STAGE5_TINY_REPEATED_METAL_TRAJECTORY_DETERMINISM_RECEIPT=",
            testClass:
                "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests",
            testMethod:
                "testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes",
            testFilter:
                "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests/testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes",
            expectedFailureCount: 0,
            expectedSkipCount: 0),
        equality: .init(
            exactComparedComponents: [
                "raw_gradients",
                "clipped_gradients",
                "model_parameters",
                "adam_first_moments",
                "adam_second_moments",
                "rng_domain_keys_counters_and_consumption",
                "next_unconsumed_cursor",
                "step_one_boundary_state",
                "source_loss",
                "source_per_target_losses",
                "source_raw_gradient_norm",
                "source_clip_scale",
                "source_clipped_gradient_norm",
                "successor_loss",
                "successor_per_target_losses",
                "successor_raw_gradient_norm",
                "successor_clip_scale",
                "successor_clipped_gradient_norm",
                "terminal_read_only_evaluation_float32_bit_patterns",
                "terminal_state",
            ],
            exactRawGradientBytesRequired: true,
            exactSourceStepRawGradientBytesRequired: true,
            exactSuccessorStepRawGradientBytesRequired: true,
            exactClippedGradientBytesRequired: true,
            exactSourceStepClippedGradientBytesRequired: true,
            exactSuccessorStepClippedGradientBytesRequired: true,
            exactModelParameterBytesRequired: true,
            exactAdamFirstMomentBytesRequired: true,
            exactAdamSecondMomentBytesRequired: true,
            exactRNGDomainKeyCounterAndConsumptionBytesRequired: true,
            exactNextUnconsumedCursorBytesRequired: true,
            exactTerminalStateBytesRequired: true,
            exactStepOneBoundaryStateAcrossAllBranchesRequired: true,
            exactLossNormAndClipScalarFloat32BitPatternsRequired: true,
            exactReadOnlyEvaluationFloat32BitPatternsRequired: true,
            canonicalParameterPathOrderRequired: true,
            canonicalShapeAndDTypeOrderRequired: true,
            float32LittleEndianByteReadOrderRequired: true,
            sourceStepEqualityBranches: [
                .uninterrupted,
                .sourceSnapshot,
            ],
            successorAndTerminalEqualityBranches:
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1.allCases,
            exactSourceStepWithinTrialAcrossProducingBranchesRequired: true,
            exactSourceStepAcrossAllTrialsRequired: true,
            exactSuccessorAndTerminalWithinTrialAcrossAllBranchesRequired: true,
            exactSuccessorAndTerminalAcrossAllTrialsRequired: true,
            tensorShapesAndDTypesMustMatchBeforeByteComparison: true,
            unorderedOrToleranceComparisonAuthorized: false,
            ulpToleranceEstablishesTrajectoryExactResume: false,
            toleranceOnlyEstablishesFunctionalContinuity: true,
            resultEstablishedByThisAuthority: false),
        authorityClosureScope: .init(
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthority.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityTests.swift",
            ],
            exactChangedPathCount: 5,
            sourceAndTestAreOnlyNewPaths: true,
            rootPackageManifestMutationAuthorized: false,
            rootPackageResolvedMutationAuthorized: false,
            trainingSourceMutationAuthorized: false,
            stage5LauncherCreationAuthorized: false),
        successorScope: .init(
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
            ],
            rootPackageManifestMutationAuthorized: false,
            rootPackageResolvedMutationAuthorized: false,
            trainingValidationManifestMutationAuthorized: false,
            trainingValidationLockMutationAuthorized: false,
            trainingSourceMutationAuthorized: true,
            existingMetalLauncherMutationAuthorized: false,
            existingRuntimeLauncherMutationAuthorized: false,
            existingTokenizerLauncherMutationAuthorized: false,
            existingStage4LauncherMutationAuthorized: false,
            newStage5LauncherRequired: true,
            newTrainingValidationOneMethodTestRequired: true,
            secureFetchMutationAuthorized: false,
            workflowTimeoutChangeAuthorized: false,
            existingCPUTrainingBehaviorMutationAuthorized: false,
            stage5BoundedDevicePolicyRequired: true,
            activeCheckoutDepth: 1,
            reviewedCheckoutDepth: 1),
        suite: .init(
            authorityRootTestCount: 52,
            isolatedTestCount: 6,
            implementationFocusedWholeTestCount: 58,
            predecessorMetalTestCount: 44,
            predecessorRuntimeTestCount: 1,
            predecessorTokenizerTestCount: 1,
            preStage5TotalTestCount: 104,
            stage5DirectXCTestCount: 1,
            totalTestCount: 105,
            metalLauncherInvocationCount: 1,
            runtimeLauncherInvocationCount: 1,
            tokenizerLauncherInvocationCount: 1,
            stage4LauncherInvocationCount: 0,
            authorityStage5LauncherInvocationCount: 0,
            authorityStage5ReceiptCount: 0,
            authorityClosureLiveOrder: [
                "metal",
                "maintained_runtime",
                "tokenizer",
            ],
            futureMechanicsLiveOrder: [
                "root",
                "metal",
                "maintained_runtime",
                "tokenizer",
                "stage5",
            ]),
        ceiling: .init(
            authorityOnlyNoAssayResultEvidence: true,
            mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: true,
            oneExactMainExecutionOpportunityAuthorized: true,
            threeBoundedSameProcessAssayTrialsAuthorized: true,
            inMemorySourceSnapshotAuthorized: true,
            additionalExecutionOrRerunAuthorized: false,
            durableCheckpointIOAuthorized: false,
            retainedArtifactAuthorized: false,
            artifactUploadAuthorized: false,
            crossDeviceClaimAuthorized: false,
            exactMetalGradientBytesEstablished: false,
            metalDeterminismEstablished: false,
            trainingExecutionObserved: false,
            stage4RerunAuthorized: false,
            stage6Authorized: false,
            native300MAllocationAuthorized: false,
            native300MTrainingAuthorized: false,
            generalTrainingAuthorized: false,
            generalTrainingResumeEstablished: false,
            modelQualityEstablished: false,
            checkpointAdmissionGranted: false,
            candidateAdmissionGranted: false,
            downstreamTrialAuthorized: false,
            canaryAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        status:
            "AUTHORIZED_stage5_tiny_single_device_three_trial_in_memory_exact_trajectory_determinism_assay_mechanics_and_one_exact_main_witness_after_green_authority_closure_no_durable_io_retention_cross_device_stage6_native300m_general_training_quality_admission_rerun_or_downstream_authority")

    public let schemaVersion: Int
    public let authorityID: String
    public let repository: PrimeNativeDecoderTinyRepeatedMetalTrajectoryRepositoryV1
    public let predecessor: PrimeNativeDecoderTinyRepeatedMetalTrajectoryPredecessorV1
    public let roadmap: PrimeNativeDecoderTinyRepeatedMetalTrajectoryRoadmapV1
    public let environment: PrimeNativeDecoderTinyRepeatedMetalTrajectoryEnvironmentV1
    public let fixture: PrimeNativeDecoderTinyRepeatedMetalTrajectoryFixtureV1
    public let assay: PrimeNativeDecoderTinyRepeatedMetalTrajectoryAssayV1
    public let equality: PrimeNativeDecoderTinyRepeatedMetalTrajectoryEqualityV1
    public let authorityClosureScope:
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryAuthorityClosureScopeV1
    public let successorScope: PrimeNativeDecoderTinyRepeatedMetalTrajectorySuccessorScopeV1
    public let suite: PrimeNativeDecoderTinyRepeatedMetalTrajectorySuiteV1
    public let ceiling: PrimeNativeDecoderTinyRepeatedMetalTrajectoryAuthorityCeilingV1
    public let status: String

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityError
                .contractDrift
        }
        let design = PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1
            .frozenV1
        let stage4 =
            PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityV1
                .frozenV1
        let repair =
            PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityV1
                .frozenV1
        let observation =
            PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationV1
                .frozenV1
        let requiredPlan = design.orderedStages.first {
            $0.stage == .tinyRepeatedMetalTrajectoryDeterminismAssay
        }
        let nextPlan = design.orderedStages.first {
            $0.stage == .native300MResourceOnlyOneStepProbe
        }
        let exactFetch = PrimeNativeDecoderTinyRepeatedMetalTrajectorySecureFetchV1(
            stepConclusion: "success",
            invocationCount: 1,
            completionCount: 1,
            authenticatedDepthOneFetchCount: 1,
            submoduleUpdateInvocationCount: 1,
            mlxCloneCount: 1,
            mlxCCloneCount: 1,
            workflowAuthoredRetryCount: 0,
            gitInternalRetryScheduledCount: 0,
            tlsFailureCount: 0,
            tlsVerificationBypassCount: 0,
            customCAInstallationCount: 0)
        let falseCeiling = [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.crossDeviceClaimAuthorized,
            ceiling.exactMetalGradientBytesEstablished,
            ceiling.metalDeterminismEstablished,
            ceiling.trainingExecutionObserved,
            ceiling.stage4RerunAuthorized,
            ceiling.stage6Authorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.generalTrainingAuthorized,
            ceiling.generalTrainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.candidateAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
        guard schemaVersion == 1,
              authorityID
                == "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_authority_v1",
              repository.repository == "Ergentics/ergentics-prime",
              repository.ref == "refs/heads/main",
              repository.stage4RetirementMergeRevision
                == "b198ba81f4c6958d70b56ea3a23f56f07fa90854",
              repository.stage4RetirementTree
                == "54af1d38bdd454a924228a37a5b76a64ac5b56ae",
              repository.orderedParentRevisions == [
                  "8c310bb61fb9b44f1e789332eb3cfc29681ee407",
                  "9f9f792edaba668cd5bd2183cfbf00ca12b31193",
              ],
              repository.stage4RetirementMergeIsCurrentAuthorityBase,
              repository.authorityMustMergeAndPassExactMainBeforeImplementation,
              repository.implementationMustBindFinalAuthorityMergeAndTree,
              repository.designAuthorityCanonicalSHA256
                == "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
              repository.stage4AuthorityCanonicalSHA256
                == PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionAuthorityV1
                    .canonicalSHA256,
              repository.stage4RepairAuthorityCanonicalSHA256
                == PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionPackageResolvedScopeRepairAuthorityV1
                    .canonicalSHA256,
              repository.stage4ObservationCanonicalSHA256
                == PrimeNativeDecoderTinyDurableMultileafCommitFaultInjectionExecutionObservationV1
                    .canonicalSHA256,
              PrimeSHA256.hexDigest(of: try PrimeCanonicalJSON.encode(design))
                == repository.designAuthorityCanonicalSHA256,
              PrimeSHA256.hexDigest(of: try stage4.canonicalData())
                == repository.stage4AuthorityCanonicalSHA256,
              PrimeSHA256.hexDigest(of: try repair.canonicalData())
                == repository.stage4RepairAuthorityCanonicalSHA256,
              PrimeSHA256.hexDigest(of: try observation.canonicalData())
                == repository.stage4ObservationCanonicalSHA256,
              requiredPlan?.objective == roadmap.objective,
              requiredPlan?.requiredCompletedPredecessorStage
                == .tinyDurableMultileafCommitFaultInjection,
              requiredPlan?.separatelyAuthorizedSuccessorRequired == true,
              requiredPlan?.implementationAuthorizedByThisDesignAuthority == false,
              requiredPlan?.trainingExecutionAuthorizedByThisDesignAuthority == false,
              requiredPlan?.artifactIOAuthorizedByThisDesignAuthority == false,
              requiredPlan?.retainedArtifactAuthorizedByThisDesignAuthority == false,
              nextPlan?.objective == roadmap.nextStageObjective,
              nextPlan?.requiredCompletedPredecessorStage
                == .tinyRepeatedMetalTrajectoryDeterminismAssay,
              roadmap.stageID
                == PrimeNativeDecoderTrajectoryExactResumeStageV1
                    .tinyRepeatedMetalTrajectoryDeterminismAssay.rawValue,
              roadmap.requiredPredecessorStageID
                == PrimeNativeDecoderTrajectoryExactResumeStageV1
                    .tinyDurableMultileafCommitFaultInjection.rawValue,
              roadmap.nextStageID
                == PrimeNativeDecoderTrajectoryExactResumeStageV1
                    .native300MResourceOnlyOneStepProbe.rawValue,
              roadmap.separateStage5AuthorityRequired,
              roadmap.stage6RequiresSeparateAuthority,
              predecessor.stage4Execution.workflowRunID == 31_726_013_984,
              predecessor.stage4Execution.workflowRunNumber == 97,
              predecessor.stage4Execution.runAttempt == 1,
              predecessor.stage4Execution.exactHeadPushRunCount == 1,
              predecessor.stage4Execution.rerunCount == 0,
              predecessor.stage4Execution.artifactCount == 0,
              predecessor.stage4Execution.terminalConclusion == "success",
              predecessor.stage4Execution.focusedRootTestCount == 50,
              predecessor.stage4Execution.focusedIsolatedTestCount == 6,
              predecessor.stage4Execution.focusedWholeTestCount == 56,
              predecessor.stage4Execution.metalTestCount == 44,
              predecessor.stage4Execution.maintainedRuntimeTestCount == 1,
              predecessor.stage4Execution.maintainedRuntimeReceiptCount == 1,
              predecessor.stage4Execution.tokenizerTestCount == 1,
              predecessor.stage4Execution.tokenizerReceiptCount == 1,
              predecessor.stage4Execution.stage4InvocationCount == 1,
              predecessor.stage4Execution.stage4ReceiptCount == 1,
              predecessor.stage4Execution.stage4StartedCount == 1,
              predecessor.stage4Execution.stage4PassedCount == 1,
              predecessor.stage4Execution.stage4FailureCount == 0,
              predecessor.stage4Execution.stage4SkipCount == 0,
              predecessor.stage4Execution.totalTestCount == 103,
              predecessor.stage4ExecutionSecureFetch == exactFetch,
              predecessor.stage4Receipt.receiptPrefixOccurrenceCount == 1,
              predecessor.stage4Receipt.rawJSONByteCount == 4_147,
              predecessor.stage4Receipt.rawJSONSHA256
                == "a0bbebb611b12ef1e88ffe625120b86a3a0caf7f29f0edbf20233c7fbe244fbd",
              predecessor.stage4Receipt.rawJSONWasCanonical,
              predecessor.stage4Receipt.publishedFileCount == 4,
              predecessor.stage4Receipt.injectedFailureCount == 7,
              predecessor.stage4Receipt.finalCommitManifestPublishedLast,
              predecessor.stage4Receipt
                .externallySuppliedExactCommitBindingRequired,
              predecessor.stage4Receipt
                .everyPartialPrecommitInventoryQuarantined,
              predecessor.stage4Receipt.exactStage3SnapshotRoundTripEstablished,
              predecessor.stage4Receipt.ephemeralPrivateRootReclaimed,
              !predecessor.stage4Receipt.retainedArtifactEstablished,
              !predecessor.stage4Receipt.artifactUploadInvoked,
              predecessor.stage4Retirement.workflowRunID == 31_732_666_495,
              predecessor.stage4Retirement.workflowRunNumber == 99,
              predecessor.stage4Retirement.runAttempt == 1,
              predecessor.stage4Retirement.exactHeadPushRunCount == 1,
              predecessor.stage4Retirement.rerunCount == 0,
              predecessor.stage4Retirement.artifactCount == 0,
              predecessor.stage4Retirement.terminalConclusion == "success",
              predecessor.stage4Retirement.focusedRootTestCount == 51,
              predecessor.stage4Retirement.focusedIsolatedTestCount == 6,
              predecessor.stage4Retirement.focusedWholeTestCount == 57,
              predecessor.stage4Retirement.metalTestCount == 44,
              predecessor.stage4Retirement.maintainedRuntimeTestCount == 1,
              predecessor.stage4Retirement.maintainedRuntimeReceiptCount == 1,
              predecessor.stage4Retirement.tokenizerTestCount == 1,
              predecessor.stage4Retirement.tokenizerReceiptCount == 1,
              predecessor.stage4Retirement.stage4InvocationCount == 0,
              predecessor.stage4Retirement.stage4ReceiptCount == 0,
              predecessor.stage4Retirement.totalTestCount == 103,
              predecessor.stage4RetirementSecureFetch == exactFetch,
              predecessor.stage4LauncherSourcePreserved,
              predecessor.stage4SuccessfulAttemptConsumed,
              predecessor.stage4MechanicsEstablished,
              predecessor.stage4InvocationRetired
        else {
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityError
                .contractDrift
        }
        try validateAssayAndCeiling(design: design, falseCeiling: falseCeiling)
    }

    private func validateAssayAndCeiling(
        design: PrimeNativeDecoderTrajectoryExactResumeDesignAuthorityV1,
        falseCeiling: [Bool]
    ) throws {
        guard environment.requiredBindings
                == design.determinismDesign.requiredEnvironmentBindings,
              environment.requiredBindings.count == 10,
              environment.mlxEnableTF32 == "0",
              environment.metalDeviceIndex == 0,
              environment.exactMetalDeviceCount == 1,
              environment.sameMetalDeviceRequiredAcrossEveryTrialAndBranch,
              !environment.crossDeviceComparisonAuthorized,
              environment.explicitDefaultGPUStreamRequired,
              environment.checkedEvaluationRequiredForEveryComparedArray,
              environment.explicitSynchronizeRequiredBeforeEveryByteRead,
              environment.exclusiveMetalDeviceLeaseRequiredForWholeAssay,
              environment.leaseType == "PrimeMetalDeviceLease",
              environment.leaseModule == "PrimeCore",
              environment.trainingValidationTestImportsPrimeCore,
              environment.trainingValidationTestDirectlyOwnsFullDurationLease,
              environment.leaseAcquiredBeforeCoreGraphicsMetalOrMLXAccess,
              environment.leaseHeldThroughPostflightAndReceipt,
              environment.leaseReleasedOnlyAfterReceipt,
              environment.singletonDeviceEnumerationRequired,
              environment.indexZeroMustMatchDefaultDevice,
              environment.postflightDeviceIdentityReverificationRequired,
              environment.compileModeMustBeRecorded,
              environment.swiftPMBuildConfiguration == "debug",
              environment.mlxGraphCompileMode
                == "eager_uncompiled_no_compile_transform",
              environment.mlxCompileTransformInvocationCount == 0,
              design.determinismDesign.embeddingLookupVJPUsesScatterAdd,
              design.determinismDesign
                .repeatedTokenMetalScatterMayUseAtomicAccumulation,
              !design.determinismDesign.exactMetalGradientBytesEstablished,
              !design.determinismDesign.exactCrossDeviceTrajectoryEstablished,
              design.determinismDesign
                .sameDeviceRepeatedUninterruptedAndResumedTrialsRequired,
              design.determinismDesign
                .exactTensorByteEqualityRequiredForTrajectoryExactClaim,
              !design.determinismDesign
                .ulpToleranceEstablishesTrajectoryExactResume,
              design.determinismDesign
                .toleranceOnlyEstablishesFunctionalContinuity,
              fixture.vocabularySize == 32,
              fixture.modelWidth == 16,
              fixture.layerCount == 2,
              fixture.queryHeadCount == 4,
              fixture.keyValueHeadCount == 2,
              fixture.headWidth == 4,
              fixture.intermediateWidth == 32,
              fixture.maximumSequenceLength == 16,
              fixture.maximumBatchSize == 2,
              fixture.initializerSeed == 7,
              fixture.uniqueParameterCount == 5_200,
              fixture.modelTensorCount == 20,
              fixture.firstMomentTensorCount == 20,
              fixture.secondMomentTensorCount == 20,
              fixture.sourceSnapshotGlobalStep == 1,
              fixture.terminalGlobalStep == 2,
              fixture.sourceStepTokenIDs == [
                  [1, 1, 1, 2, 3, 0],
                  [4, 5, 6, 7, 8, 9],
              ],
              fixture.sourceStepValidTokenCounts == [5, 6],
              fixture.sourceStepCompletionMask == [
                  [false, false, false, true, true, false],
                  [false, false, true, true, true, true],
              ],
              fixture.successorStepTokenIDs == [
                  [10, 11, 12, 13, 0, 0],
                  [14, 15, 15, 15, 16, 0],
              ],
              fixture.successorStepValidTokenCounts == [4, 5],
              fixture.successorStepCompletionMask == [
                  [false, true, true, true, false, false],
                  [false, false, false, true, true, false],
              ],
              fixture.repeatedTokenIDs == [1, 15],
              assay.independentTrialCount == 3,
              assay.totalTrajectoryBranchExecutionCount == 9,
              assay.allTrialsRunInOneProcess,
              assay.exactBranchesPerTrial
                == PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1
                    .allCases,
              assay.uninterruptedBranchStartsFromFreshFixture,
              assay.sourceSnapshotBranchStartsFromFreshFixture,
              assay.sourceSnapshotBranchCapturesAtExactStep,
              assay.sourceSnapshotCaptureIsReadOnly,
              assay.sourceSnapshotBranchContinuesToTerminalStep,
              assay.restoredBranchUsesFreshModelOptimizerRNGAndCursor,
              assay.restoredBranchLoadsOnlyTheSourceSnapshot,
              assay.everyBranchReachesTerminalStep,
              assay.everyTrialUsesFreshObjectsAndArrays,
              !assay.objectOrArrayAliasingAcrossBranchesAuthorized,
              !assay.stateReuseAcrossTrialsAuthorized,
              !assay.implicitOrGlobalMLXRandomStateAuthorized,
              assay.sourceSnapshotExistsOnlyInMemory,
              !assay.durableCheckpointIOAuthorized,
              !assay.filesystemArtifactIOAuthorized,
              !assay.networkIOAuthorized,
              assay.buildCount == 1,
              assay.directXCTestCount == 1,
              assay.receiptID
                == "prime_native_decoder_stage5_tiny_repeated_metal_trajectory_determinism_receipt_v1",
              assay.receiptPrefix
                == "PRIME_NATIVE_DECODER_STAGE5_TINY_REPEATED_METAL_TRAJECTORY_DETERMINISM_RECEIPT=",
              assay.testClass
                == "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests",
              assay.testMethod
                == "testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes",
              assay.testFilter
                == "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests/testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes",
              assay.expectedFailureCount == 0,
              assay.expectedSkipCount == 0,
              equality.exactComparedComponents == [
                  "raw_gradients",
                  "clipped_gradients",
                  "model_parameters",
                  "adam_first_moments",
                  "adam_second_moments",
                  "rng_domain_keys_counters_and_consumption",
                  "next_unconsumed_cursor",
                  "step_one_boundary_state",
                  "source_loss",
                  "source_per_target_losses",
                  "source_raw_gradient_norm",
                  "source_clip_scale",
                  "source_clipped_gradient_norm",
                  "successor_loss",
                  "successor_per_target_losses",
                  "successor_raw_gradient_norm",
                  "successor_clip_scale",
                  "successor_clipped_gradient_norm",
                  "terminal_read_only_evaluation_float32_bit_patterns",
                  "terminal_state",
              ],
              equality.exactRawGradientBytesRequired,
              equality.exactSourceStepRawGradientBytesRequired,
              equality.exactSuccessorStepRawGradientBytesRequired,
              equality.exactClippedGradientBytesRequired,
              equality.exactSourceStepClippedGradientBytesRequired,
              equality.exactSuccessorStepClippedGradientBytesRequired,
              equality.exactModelParameterBytesRequired,
              equality.exactAdamFirstMomentBytesRequired,
              equality.exactAdamSecondMomentBytesRequired,
              equality.exactRNGDomainKeyCounterAndConsumptionBytesRequired,
              equality.exactNextUnconsumedCursorBytesRequired,
              equality.exactTerminalStateBytesRequired,
              equality.exactStepOneBoundaryStateAcrossAllBranchesRequired,
              equality.exactLossNormAndClipScalarFloat32BitPatternsRequired,
              equality.exactReadOnlyEvaluationFloat32BitPatternsRequired,
              equality.canonicalParameterPathOrderRequired,
              equality.canonicalShapeAndDTypeOrderRequired,
              equality.float32LittleEndianByteReadOrderRequired,
              equality.sourceStepEqualityBranches
                == [.uninterrupted, .sourceSnapshot],
              equality.successorAndTerminalEqualityBranches
                == PrimeNativeDecoderTinyRepeatedMetalTrajectoryBranchV1
                    .allCases,
              equality.exactSourceStepWithinTrialAcrossProducingBranchesRequired,
              equality.exactSourceStepAcrossAllTrialsRequired,
              equality
                .exactSuccessorAndTerminalWithinTrialAcrossAllBranchesRequired,
              equality.exactSuccessorAndTerminalAcrossAllTrialsRequired,
              equality.tensorShapesAndDTypesMustMatchBeforeByteComparison,
              !equality.unorderedOrToleranceComparisonAuthorized,
              !equality.ulpToleranceEstablishesTrajectoryExactResume,
              equality.toleranceOnlyEstablishesFunctionalContinuity,
              !equality.resultEstablishedByThisAuthority
        else {
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityError
                .contractDrift
        }
        try validateScopeSuiteAndCeiling(falseCeiling: falseCeiling)
    }

    private func validateScopeSuiteAndCeiling(
        falseCeiling: [Bool]
    ) throws {
        guard authorityClosureScope.exactChangedPaths
                == authorityClosureScope.exactChangedPaths.sorted(),
              Set(authorityClosureScope.exactChangedPaths).count == 5,
              authorityClosureScope.exactChangedPathCount == 5,
              authorityClosureScope.sourceAndTestAreOnlyNewPaths,
              !authorityClosureScope.rootPackageManifestMutationAuthorized,
              !authorityClosureScope.rootPackageResolvedMutationAuthorized,
              !authorityClosureScope.trainingSourceMutationAuthorized,
              !authorityClosureScope.stage5LauncherCreationAuthorized,
              successorScope.exactChangedPaths
                == successorScope.exactChangedPaths.sorted(),
              Set(successorScope.exactChangedPaths).count == 6,
              !successorScope.rootPackageManifestMutationAuthorized,
              !successorScope.rootPackageResolvedMutationAuthorized,
              !successorScope.trainingValidationManifestMutationAuthorized,
              !successorScope.trainingValidationLockMutationAuthorized,
              successorScope.trainingSourceMutationAuthorized,
              !successorScope.existingMetalLauncherMutationAuthorized,
              !successorScope.existingRuntimeLauncherMutationAuthorized,
              !successorScope.existingTokenizerLauncherMutationAuthorized,
              !successorScope.existingStage4LauncherMutationAuthorized,
              successorScope.newStage5LauncherRequired,
              successorScope.newTrainingValidationOneMethodTestRequired,
              !successorScope.secureFetchMutationAuthorized,
              !successorScope.workflowTimeoutChangeAuthorized,
              !successorScope.existingCPUTrainingBehaviorMutationAuthorized,
              successorScope.stage5BoundedDevicePolicyRequired,
              successorScope.activeCheckoutDepth == 1,
              successorScope.reviewedCheckoutDepth == 1,
              suite.authorityRootTestCount == 52,
              suite.isolatedTestCount == 6,
              suite.implementationFocusedWholeTestCount == 58,
              suite.predecessorMetalTestCount == 44,
              suite.predecessorRuntimeTestCount == 1,
              suite.predecessorTokenizerTestCount == 1,
              suite.preStage5TotalTestCount == 104,
              suite.stage5DirectXCTestCount == 1,
              suite.totalTestCount == 105,
              suite.metalLauncherInvocationCount == 1,
              suite.runtimeLauncherInvocationCount == 1,
              suite.tokenizerLauncherInvocationCount == 1,
              suite.stage4LauncherInvocationCount == 0,
              suite.authorityStage5LauncherInvocationCount == 0,
              suite.authorityStage5ReceiptCount == 0,
              suite.authorityClosureLiveOrder
                == ["metal", "maintained_runtime", "tokenizer"],
              suite.futureMechanicsLiveOrder
                == ["root", "metal", "maintained_runtime", "tokenizer", "stage5"],
              ceiling.authorityOnlyNoAssayResultEvidence,
              ceiling.mechanicsImplementationAuthorizedAfterGreenAuthorityClosure,
              ceiling.oneExactMainExecutionOpportunityAuthorized,
              ceiling.threeBoundedSameProcessAssayTrialsAuthorized,
              ceiling.inMemorySourceSnapshotAuthorized,
              falseCeiling.allSatisfy({ !$0 }),
              status
                == "AUTHORIZED_stage5_tiny_single_device_three_trial_in_memory_exact_trajectory_determinism_assay_mechanics_and_one_exact_main_witness_after_green_authority_closure_no_durable_io_retention_cross_device_stage6_native300m_general_training_quality_admission_rerun_or_downstream_authority"
        else {
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityError
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
            throw PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayAuthorityError
                .nonCanonicalEncoding
        }
        return value
    }
}
