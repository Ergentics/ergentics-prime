// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderReviewedMainMetalExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Exact GitHub-hosted observation of the reviewed-main decoder mechanics.
///
/// The same clean merge revision completed the corrected active-root and Latin
/// gates, the focused source-contract tests, a fresh pinned-MLX metallib build,
/// and all 44 isolated decoder tests on a visible Metal device. The generated
/// metallib was staged byte-exactly, but the loader was not independently
/// instrumented to prove which resource image it opened. This observation is
/// synthetic mechanics evidence, not a maintained-runtime policy, checkpoint
/// admission, training authorization, or downstream product decision.
public struct PrimeNativeDecoderReviewedMainMetalExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorObservationID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorRequiredForConsumption: Bool
    public let predecessorSourcePath: String
    public let predecessorSourceGitMode: String
    public let predecessorSourceGitBlob: String
    public let predecessorSourceByteCount: Int
    public let predecessorSourceSHA256: String

    public let authoritativeRepository: String
    public let observedPullRequestNumber: Int
    public let observedRef: String
    public let observedRevision: String
    public let observedOrderedParentRevisions: [String]
    public let observedTree: String
    public let reviewedPullRequestHeadRevision: String
    public let reviewedPullRequestHeadTree: String
    public let observedEmbeddedSourceIdentitySHA256: String
    public let historyPreservingTwoParentMergeObserved: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
    public let mergeAuthorizedByThisObservation: Bool

    public let observedWorkflowPath: String
    public let observedWorkflowGitMode: String
    public let observedWorkflowGitBlob: String
    public let observedWorkflowByteCount: Int
    public let observedWorkflowSHA256: String
    public let observedActiveGatePath: String
    public let observedActiveGateGitMode: String
    public let observedActiveGateGitBlob: String
    public let observedActiveGateByteCount: Int
    public let observedActiveGateSHA256: String
    public let observedLatinGatePath: String
    public let observedLatinGateGitMode: String
    public let observedLatinGateGitBlob: String
    public let observedLatinGateByteCount: Int
    public let observedLatinGateSHA256: String
    public let observedMetalLauncherPath: String
    public let observedMetalLauncherGitMode: String
    public let observedMetalLauncherGitBlob: String
    public let observedMetalLauncherByteCount: Int
    public let observedMetalLauncherSHA256: String

    public let observedDecoderSourceGitBlob: String
    public let observedDecoderSourceByteCount: Int
    public let observedDecoderSourceSHA256: String
    public let observedCheckpointSourceGitBlob: String
    public let observedCheckpointSourceByteCount: Int
    public let observedCheckpointSourceSHA256: String
    public let observedAuthorityTestSourceGitBlob: String
    public let observedAuthorityTestSourceByteCount: Int
    public let observedAuthorityTestSourceSHA256: String
    public let observedCheckpointTestSourceGitBlob: String
    public let observedCheckpointTestSourceByteCount: Int
    public let observedCheckpointTestSourceSHA256: String
    public let observedDecoderTestSourceGitBlob: String
    public let observedDecoderTestSourceByteCount: Int
    public let observedDecoderTestSourceSHA256: String

    public let workflowID: Int
    public let workflowName: String
    public let runID: Int
    public let runNumber: Int
    public let runAttempt: Int
    public let runEvent: String
    public let runURL: String
    public let runActor: String
    public let runTriggeringActor: String
    public let runCreatedAt: String
    public let runStartedAt: String
    public let runUpdatedAt: String
    public let runStatus: String
    public let runConclusion: String

    public let activeRootJobID: Int
    public let activeRootJobName: String
    public let activeRootJobURL: String
    public let activeRootJobStartedAt: String
    public let activeRootJobCompletedAt: String
    public let activeRootJobStatus: String
    public let activeRootJobConclusion: String
    public let activeRootRunnerLabel: String
    public let activeRootRunnerName: String
    public let activeRootRunnerGroupName: String
    public let activeRootRequiredSuccessfulStepNames: [String]

    public let reviewedMainJobID: Int
    public let reviewedMainJobName: String
    public let reviewedMainJobURL: String
    public let reviewedMainJobStartedAt: String
    public let reviewedMainJobCompletedAt: String
    public let reviewedMainJobStatus: String
    public let reviewedMainJobConclusion: String
    public let reviewedMainRunnerLabel: String
    public let reviewedMainRunnerName: String
    public let reviewedMainRunnerGroupName: String
    public let reviewedMainRequiredSuccessfulStepNames: [String]
    public let reviewedMainRanAfterActiveRootSuccess: Bool

    public let activeJobDownloadedLogByteCount: Int
    public let activeJobDownloadedLogSHA256: String
    public let reviewedMainJobDownloadedLogByteCount: Int
    public let reviewedMainJobDownloadedLogSHA256: String
    public let downloadedJobLogBindingKind: String
    public let downloadedJobLogResponsesBound: Bool
    public let rawGitHubLogArchiveBytesBound: Bool
    public let jobLogsRetainedInRepository: Bool
    public let durableJobLogPublicationEstablished: Bool
    public let jobLogHashAloneBindsRevisionOrTree: Bool
    public let publishedWorkflowArtifactCount: Int

    public let runnerVersion: String
    public let runnerProvisionerVersion: String
    public let runnerImage: String
    public let runnerImageVersion: String
    public let operatingSystemVersion: String
    public let operatingSystemBuild: String
    public let architecture: String
    public let xcodeVersion: String
    public let xcodeBuildVersion: String
    public let swiftVersion: String
    public let swiftTarget: String
    public let macOSSDKVersion: String
    public let swiftDriverVersion: String
    public let exactHostedRunnerImageRecorded: Bool
    public let exactPhysicalRunnerIdentityRecorded: Bool

    public let metalDeviceDiscoveryAPI: String
    public let metalDeviceName: String
    public let metalDeviceObserved: Bool
    public let metalDeviceNameRecorded: Bool
    public let physicalGPUModelIdentityRecorded: Bool
    public let paravirtualMetalDeviceObserved: Bool
    public let coreGraphicsBootstrapObserved: Bool

    public let exactMLXRepository: String
    public let exactMLXRevision: String
    public let exactMLXCoreRevision: String
    public let exactMLXCRevision: String
    public let donorMLXCheckoutExactAndClean: Bool
    public let swiftPMMLXCheckoutExactAndClean: Bool
    public let ciMechanicsPolicy:
        PrimeNativeDecoderCIMLXComputeEnvironmentPolicyDeclaration
    public let ciMechanicsPolicyAppliedBeforeFirstMetalOrMLXCall: Bool
    public let inProcessMechanicsPolicyPreflightObserved: Bool
    public let inheritedMLXDYLDAndLLVMOverridesAbsent: Bool

    public let generatedMetallibArtifactKind: String
    public let generatedMetallibByteCount: Int
    public let generatedMetallibSHA256: String
    public let freshCmlxDebugBuildObserved: Bool
    public let initiallyAbsentControlledMetallibScratchRootObserved: Bool
    public let exactlyOneNonemptyRegularMetallibObserved: Bool
    public let dualStagedMetallibCopiesByteEqual: Bool
    public let freshMetallibBuildAndByteExactStagingObserved: Bool
    public let freshMetallibBuildProvenanceObserved: Bool
    public let runtimeLoadedExactStagedMetallibIdentityIndependentlyObserved:
        Bool
    public let metallibBytesRetainedInRepository: Bool
    public let metallibArtifactPublished: Bool
    public let reproducibleSecondMetallibBuildObserved: Bool

    public let testBundleRebuiltFromObservedRevision: Bool
    public let testBundleLinkedCoreGraphicsAndMetal: Bool
    public let testBundleBinarySHA256Recorded: Bool
    public let testBundleBinaryProvenancePublished: Bool
    public let focusedSourceContractTestCount: Int
    public let focusedSourceContractFailureCount: Int
    public let executedAuthorityTestCount: Int
    public let executedCheckpointTestCount: Int
    public let executedDecoderTestCount: Int
    public let executedTotalTestCount: Int
    public let failureCount: Int
    public let unexpectedFailureCount: Int
    public let skipCount: Int
    public let requiredLiveMetalTestNames: [String]
    public let allRequiredLiveMetalTestsPassed: Bool

    public let exactRevisionCheckoutObserved: Bool
    public let exactRevisionCleanBeforeAndAfterObserved: Bool
    public let correctedActiveRootAndLatinGateSequenceObserved: Bool
    public let focusedSourceContractsObserved: Bool
    public let exactHeadAndCleanGateSequenceCompleted: Bool
    public let githubHostedMetalObserved: Bool
    public let exactReviewedMainSyntheticMechanicsObserved: Bool
    public let syntheticModelInitializationObserved: Bool
    public let forwardExecutionObserved: Bool
    public let gqaScalarParityObserved: Bool
    public let batchedRoPERegressionObserved: Bool
    public let cacheParityObserved: Bool
    public let gradientExecutionObserved: Bool
    public let deterministicRNGMechanicsObserved: Bool
    public let syntheticCheckpointRoundTripObserved: Bool
    public let checkpointFailurePathsObserved: Bool
    public let native300MModelAllocationObserved: Bool
    public let native300MCheckpointWriteObserved: Bool
    public let native300MCheckpointLoadObserved: Bool
    public let optimizerStepObserved: Bool
    public let trainingExecutionObserved: Bool
    public let thisObservationRuntimeValidationObserved: Bool

    public let checkpointV1HistoricalIdentityPreserved: Bool
    public let repairedCheckpointCompatibilityIdentityEstablished: Bool
    public let admittedRuntimeComputePolicyEstablished: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let native300MModelAllocationAuthorized: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let trainingResumeEstablished: Bool
    public let modelQualityEstablished: Bool
    public let functionalTrainingAuthorized: Bool
    public let longTrainingAuthorized: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let driverV2MutationAuthorized: Bool
    public let pmhnpMutationAuthorized: Bool
    public let geometryDependencyAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_reviewed_main_metal_execution_v1",
        observationKind:
            "github_reviewed_main_exact_head_fresh_metallib_live_metal_execution_observation",
        predecessorObservationID:
            PrimeNativeDecoderGateRepairExecutionObservationV1
                .frozenV1.observationID,
        predecessorRemainsFrozen: true,
        predecessorRequiredForConsumption: true,
        predecessorSourcePath:
            "Sources/PrimeCore/PrimeNativeDecoderGateRepairExecutionObservation.swift",
        predecessorSourceGitMode: "100644",
        predecessorSourceGitBlob:
            "3b242cd57b4f922ada466d8ae39b58424ff878c2",
        predecessorSourceByteCount: 19_780,
        predecessorSourceSHA256:
            "fcce012be39a0178ff22e21a4218e4384dea6d082733b45930c9b8133011de9d",

        authoritativeRepository: "Ergentics/ergentics-prime",
        observedPullRequestNumber: 69,
        observedRef: "refs/heads/main",
        observedRevision:
            "b7bad4db76a3ceadba69195ff218af64b19fb716",
        observedOrderedParentRevisions: [
            "209d619e6a3a297e7380591725776ac08c87a56f",
            "8b80e67cfa55c049c56c0232909f857f1aecaa3e",
        ],
        observedTree:
            "1090c59675474e7b9ae2fe1e65a14fe8af2362e9",
        reviewedPullRequestHeadRevision:
            "8b80e67cfa55c049c56c0232909f857f1aecaa3e",
        reviewedPullRequestHeadTree:
            "1090c59675474e7b9ae2fe1e65a14fe8af2362e9",
        observedEmbeddedSourceIdentitySHA256:
            "3c012abe2bba5a62c25eac0246e33327ad518ff4c9e9e400e4c5ff5188f35d2a",
        historyPreservingTwoParentMergeObserved: true,
        mergeTreeEqualsReviewedHeadTree: true,
        mergeAuthorizedByThisObservation: false,

        observedWorkflowPath:
            ".github/workflows/prime-active-root-quarantine.yml",
        observedWorkflowGitMode: "100644",
        observedWorkflowGitBlob:
            "847c620ea7447963e9bdb51c431a06a25fd799b0",
        observedWorkflowByteCount: 18_827,
        observedWorkflowSHA256:
            "7bdd92779304f5b04a8c4d1fae4d78a3a6ccde2c4edf4b9f0441a6a6957f8108",
        observedActiveGatePath:
            ".github/scripts/prime-ci-active-root-quarantine.sh",
        observedActiveGateGitMode: "100755",
        observedActiveGateGitBlob:
            "ca3359388a4ae8ad1fc4b6eca5c6ab9e222fa711",
        observedActiveGateByteCount: 34_864,
        observedActiveGateSHA256:
            "7651c2f6b5af6dbc57db7ed381de76398cd61215789c0932c0919ba8fab536de",
        observedLatinGatePath:
            ".github/scripts/prime-ci-latin-proposal-pair-capture.sh",
        observedLatinGateGitMode: "100755",
        observedLatinGateGitBlob:
            "9e9875551e5a8a9d64b3e803ce609049d6939e52",
        observedLatinGateByteCount: 107_424,
        observedLatinGateSHA256:
            "cf46741af3eefea49e241af6a8b1c304a5fcb7236fba3ee2e70cf45568bf4fea",
        observedMetalLauncherPath:
            ".github/scripts/prime-ci-native-decoder-metal.sh",
        observedMetalLauncherGitMode: "100755",
        observedMetalLauncherGitBlob:
            "418d2d2753cee38e0b3558ad45e1e09865ffd11d",
        observedMetalLauncherByteCount: 11_793,
        observedMetalLauncherSHA256:
            "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff",

        observedDecoderSourceGitBlob:
            "835a4826549e1f28ec27e3533f746218beb3bdf2",
        observedDecoderSourceByteCount: 39_050,
        observedDecoderSourceSHA256:
            "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
        observedCheckpointSourceGitBlob:
            "24de078fb6424123b8e6974588b4cc514219c026",
        observedCheckpointSourceByteCount: 39_956,
        observedCheckpointSourceSHA256:
            "a239d2dd4ea9cc794105e15c09457e7bda526d8e1dbafeb3383997bb14f89b8b",
        observedAuthorityTestSourceGitBlob:
            "25b7c9b99e789988fb7362b73a41d35eafba406d",
        observedAuthorityTestSourceByteCount: 34_555,
        observedAuthorityTestSourceSHA256:
            "28b146996a0dede2e6cd8e6d8116641a3a398bc5f845051a75cbbc977e9f48fe",
        observedCheckpointTestSourceGitBlob:
            "375a9278d6fe82b7033c731a8e4f7d51c5cc96b5",
        observedCheckpointTestSourceByteCount: 33_037,
        observedCheckpointTestSourceSHA256:
            "97944a997a389e6ea79ba92f9be965bc66230064e171c51c9150f6b1080b9172",
        observedDecoderTestSourceGitBlob:
            "0162a60c422de7d05abbdd6932420930adcd5813",
        observedDecoderTestSourceByteCount: 40_513,
        observedDecoderTestSourceSHA256:
            "ee612ac7b02e759fdb556d1f29d4f1327da3d9bb39f6e20090a8d862b2a5c53f",

        workflowID: 329_017_041,
        workflowName: "Prime active-root quarantine",
        runID: 31_361_320_313,
        runNumber: 35,
        runAttempt: 1,
        runEvent: "push",
        runURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31361320313",
        runActor: "psyop-archivist",
        runTriggeringActor: "psyop-archivist",
        runCreatedAt: "2026-08-10T06:15:58Z",
        runStartedAt: "2026-08-10T06:15:58Z",
        runUpdatedAt: "2026-08-10T06:24:51Z",
        runStatus: "completed",
        runConclusion: "success",

        activeRootJobID: 93_370_610_366,
        activeRootJobName: "First-party MLX / active-root quarantine",
        activeRootJobURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31361320313/job/93370610366",
        activeRootJobStartedAt: "2026-08-10T06:16:01Z",
        activeRootJobCompletedAt: "2026-08-10T06:18:03Z",
        activeRootJobStatus: "completed",
        activeRootJobConclusion: "success",
        activeRootRunnerLabel: "macos-15",
        activeRootRunnerName: "GitHub Actions 1000001641",
        activeRootRunnerGroupName: "GitHub Actions",
        activeRootRequiredSuccessfulStepNames: [
            "Check out the exact Prime revision",
            "Validate active metadata and preserved history",
            "Parse the changed Swift contracts without dependencies",
            "Validate isolated Latin capture and observation contracts",
            "Record the authority ceiling",
        ],

        reviewedMainJobID: 93_370_967_151,
        reviewedMainJobName: "Reviewed main / focused source contracts",
        reviewedMainJobURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31361320313/job/93370967151",
        reviewedMainJobStartedAt: "2026-08-10T06:18:06Z",
        reviewedMainJobCompletedAt: "2026-08-10T06:24:50Z",
        reviewedMainJobStatus: "completed",
        reviewedMainJobConclusion: "success",
        reviewedMainRunnerLabel: "macos-26",
        reviewedMainRunnerName: "GitHub Actions 1000001642",
        reviewedMainRunnerGroupName: "GitHub Actions",
        reviewedMainRequiredSuccessfulStepNames: [
            "Record the hosted Apple toolchain",
            "Check out reviewed main exactly",
            "Fetch the exact private dependency without evaluating Prime",
            "Compile and run the focused contracts without a credential",
            "Run the Prime-owned decoder on live Metal",
        ],
        reviewedMainRanAfterActiveRootSuccess: true,

        activeJobDownloadedLogByteCount: 215_028,
        activeJobDownloadedLogSHA256:
            "228bb96d71b8144090e6678a4c2584803c6a1d20a35f9ff4cde09aea66a7db92",
        reviewedMainJobDownloadedLogByteCount: 10_043_743,
        reviewedMainJobDownloadedLogSHA256:
            "c858a41a58dc8d2c1112e65b7d833807173fb9adc22e0c8478fc7e099bb88d3b",
        downloadedJobLogBindingKind:
            "github_rest_actions_job_logs_endpoint_followed_plain_response_bytes_hashed_without_text_normalization",
        downloadedJobLogResponsesBound: true,
        rawGitHubLogArchiveBytesBound: false,
        jobLogsRetainedInRepository: false,
        durableJobLogPublicationEstablished: false,
        jobLogHashAloneBindsRevisionOrTree: false,
        publishedWorkflowArtifactCount: 0,

        runnerVersion: "2.336.0",
        runnerProvisionerVersion: "20260707.563",
        runnerImage: "macos-26-arm64",
        runnerImageVersion: "20260728.0273.1",
        operatingSystemVersion: "26.5.2",
        operatingSystemBuild: "25F84",
        architecture: "arm64",
        xcodeVersion: "26.6",
        xcodeBuildVersion: "17F113",
        swiftVersion:
            "6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)",
        swiftTarget: "arm64-apple-macosx26.0",
        macOSSDKVersion: "26.5",
        swiftDriverVersion: "1.148.6",
        exactHostedRunnerImageRecorded: true,
        exactPhysicalRunnerIdentityRecorded: false,

        metalDeviceDiscoveryAPI: "MTLCreateSystemDefaultDevice",
        metalDeviceName: "Apple Paravirtual device",
        metalDeviceObserved: true,
        metalDeviceNameRecorded: true,
        physicalGPUModelIdentityRecorded: false,
        paravirtualMetalDeviceObserved: true,
        coreGraphicsBootstrapObserved: true,

        exactMLXRepository: "Ergentics/ergentics-mlx-swift",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        exactMLXCoreRevision:
            "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
        exactMLXCRevision:
            "0726ca922fc902c4c61ef9c27d94132be418e945",
        donorMLXCheckoutExactAndClean: true,
        swiftPMMLXCheckoutExactAndClean: true,
        ciMechanicsPolicy:
            PrimeNativeDecoderCIMLXComputeEnvironmentPolicy.frozenV1,
        ciMechanicsPolicyAppliedBeforeFirstMetalOrMLXCall: true,
        inProcessMechanicsPolicyPreflightObserved: true,
        inheritedMLXDYLDAndLLVMOverridesAbsent: true,

        generatedMetallibArtifactKind:
            "fresh_exact_pinned_mlx_default_metallib_not_prime_custom_language_kernel",
        generatedMetallibByteCount: 6_292_716,
        generatedMetallibSHA256:
            "bf45fbb69d87f3cc51b3f8d9ca8a3b114dd155a7a9eee5001092d8fd5f7a7f61",
        freshCmlxDebugBuildObserved: true,
        initiallyAbsentControlledMetallibScratchRootObserved: true,
        exactlyOneNonemptyRegularMetallibObserved: true,
        dualStagedMetallibCopiesByteEqual: true,
        freshMetallibBuildAndByteExactStagingObserved: true,
        freshMetallibBuildProvenanceObserved: true,
        runtimeLoadedExactStagedMetallibIdentityIndependentlyObserved: false,
        metallibBytesRetainedInRepository: false,
        metallibArtifactPublished: false,
        reproducibleSecondMetallibBuildObserved: false,

        testBundleRebuiltFromObservedRevision: true,
        testBundleLinkedCoreGraphicsAndMetal: true,
        testBundleBinarySHA256Recorded: false,
        testBundleBinaryProvenancePublished: false,
        focusedSourceContractTestCount: 31,
        focusedSourceContractFailureCount: 0,
        executedAuthorityTestCount: 11,
        executedCheckpointTestCount: 14,
        executedDecoderTestCount: 19,
        executedTotalTestCount: 44,
        failureCount: 0,
        unexpectedFailureCount: 0,
        skipCount: 0,
        requiredLiveMetalTestNames: [
            "testParameterInventoryIsExactAndOutputProjectionIsTied",
            "testUnequalHeadGQAForwardIsFiniteAndCausal",
            "testProjectedQKVHasExactHeadShapesAndRoPEOffsetScope",
            "testPinnedCausalSDPAMatchesScalarGQAReference",
            "testSeededConstructionIsDeterministicAndSeedSensitive",
            "testInputValidationRejectsUnsupportedSequences",
            "testCachePrefillAndSingleTokenDecodeMatchFullPrefix",
            "testCacheSupportsRectangularBatchAndCausalChunkContinuation",
            "testCacheCapacityGrowthPreservesPrefixAndParity",
            "testCacheRejectsParameterRevisionMixingUntilReset",
            "testCacheValidationFailsBeforeMutationAndResetReplays",
            "testCacheContextLimitFailsWithoutAdvancingState",
            "testCausalGQAAndRoPEAreDifferentiableWithoutTraining",
            "testSeededFactoryDoesNotConsumeGlobalRandomState",
            "testSyntheticBorrowedDescriptorRoundTripRestoresExactFreshModel",
            "testSyntheticLoadRejectsDifferentValidManifestBeforeRestore",
            "testSyntheticLoadRejectsMalformedMetadataAndTensorCatalog",
        ],
        allRequiredLiveMetalTestsPassed: true,

        exactRevisionCheckoutObserved: true,
        exactRevisionCleanBeforeAndAfterObserved: true,
        correctedActiveRootAndLatinGateSequenceObserved: true,
        focusedSourceContractsObserved: true,
        exactHeadAndCleanGateSequenceCompleted: true,
        githubHostedMetalObserved: true,
        exactReviewedMainSyntheticMechanicsObserved: true,
        syntheticModelInitializationObserved: true,
        forwardExecutionObserved: true,
        gqaScalarParityObserved: true,
        batchedRoPERegressionObserved: true,
        cacheParityObserved: true,
        gradientExecutionObserved: true,
        deterministicRNGMechanicsObserved: true,
        syntheticCheckpointRoundTripObserved: true,
        checkpointFailurePathsObserved: true,
        native300MModelAllocationObserved: false,
        native300MCheckpointWriteObserved: false,
        native300MCheckpointLoadObserved: false,
        optimizerStepObserved: false,
        trainingExecutionObserved: false,
        thisObservationRuntimeValidationObserved: false,

        checkpointV1HistoricalIdentityPreserved: true,
        repairedCheckpointCompatibilityIdentityEstablished: false,
        admittedRuntimeComputePolicyEstablished: false,
        runtimeDependencyClosureEstablished: false,
        runtimeInitializationEstablished: false,
        native300MModelAllocationAuthorized: false,
        native300MCheckpointWriteAuthorized: false,
        native300MCheckpointLoadAuthorized: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointAdmissionGranted: false,
        trainingResumeEstablished: false,
        modelQualityEstablished: false,
        functionalTrainingAuthorized: false,
        longTrainingAuthorized: false,
        candidateAdmissionGranted: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        driverV2MutationAuthorized: false,
        pmhnpMutationAuthorized: false,
        geometryDependencyAuthorized: false,
        status:
            "ABSTAIN_exact_reviewed_main_github_hosted_fresh_metallib_live_metal_decoder_mechanics_observed_repaired_checkpoint_runtime_and_training_unestablished",
        orderedNextActions: [
            "append_repaired_checkpoint_compatibility_identity",
            "append_admitted_runtime_compute_policy",
            "establish_runtime_dependency_metallib_device_and_initialization_closure",
            "establish_tokenizer_model_functional_compatibility",
            "define_bounded_native_profile_checkpoint_container_and_io_mechanics",
            "define_prime_owned_train_and_evaluate_surfaces",
            "persist_exact_optimizer_rng_and_data_cursor_state_before_training",
            "request_separate_bounded_training_authorization",
            "produce_and_bind_non_fixture_checkpoint_artifact_provenance",
        ]
    )

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let predecessor =
            PrimeNativeDecoderGateRepairExecutionObservationV1.frozenV1

        try predecessor.validateExactV1()

        guard self == expected,
              schemaVersion == 1,
              predecessorObservationID == predecessor.observationID,
              predecessorRemainsFrozen,
              predecessorRequiredForConsumption,
              predecessorSourceGitMode == "100644",
              predecessorSourceGitBlob.utf8.count == 40,
              predecessorSourceByteCount == 19_780,
              predecessorSourceSHA256.utf8.count == 64,
              authoritativeRepository == predecessor.authoritativeRepository,
              observedPullRequestNumber == 69,
              observedRef == "refs/heads/main",
              observedRevision.utf8.count == 40,
              observedOrderedParentRevisions.count == 2,
              observedOrderedParentRevisions.allSatisfy({
                  $0.utf8.count == 40
              }),
              observedTree.utf8.count == 40,
              reviewedPullRequestHeadRevision
                == observedOrderedParentRevisions[1],
              reviewedPullRequestHeadTree == observedTree,
              observedEmbeddedSourceIdentitySHA256.utf8.count == 64,
              historyPreservingTwoParentMergeObserved,
              mergeTreeEqualsReviewedHeadTree,
              !mergeAuthorizedByThisObservation,
              observedWorkflowGitMode == "100644",
              observedActiveGateGitMode == "100755",
              observedLatinGateGitMode == "100755",
              observedMetalLauncherGitMode == "100755",
              allSourceBindingsAreLowercaseHex,
              workflowID == 329_017_041,
              workflowName == "Prime active-root quarantine",
              runID == 31_361_320_313,
              runNumber == 35,
              runAttempt == 1,
              runEvent == "push",
              runActor == runTriggeringActor,
              runStatus == "completed",
              runConclusion == "success",
              activeRootJobID == 93_370_610_366,
              activeRootJobStatus == "completed",
              activeRootJobConclusion == "success",
              activeRootRunnerLabel == "macos-15",
              activeRootRequiredSuccessfulStepNames.count == 5,
              reviewedMainJobID == 93_370_967_151,
              reviewedMainJobStatus == "completed",
              reviewedMainJobConclusion == "success",
              reviewedMainRunnerLabel == "macos-26",
              reviewedMainRequiredSuccessfulStepNames.count == 5,
              reviewedMainRanAfterActiveRootSuccess,
              activeJobDownloadedLogByteCount == 215_028,
              activeJobDownloadedLogSHA256.utf8.count == 64,
              reviewedMainJobDownloadedLogByteCount == 10_043_743,
              reviewedMainJobDownloadedLogSHA256.utf8.count == 64,
              downloadedJobLogBindingKind
                == "github_rest_actions_job_logs_endpoint_followed_plain_response_bytes_hashed_without_text_normalization",
              downloadedJobLogResponsesBound,
              !rawGitHubLogArchiveBytesBound,
              !jobLogsRetainedInRepository,
              !durableJobLogPublicationEstablished,
              !jobLogHashAloneBindsRevisionOrTree,
              publishedWorkflowArtifactCount == 0,
              architecture == "arm64",
              exactHostedRunnerImageRecorded,
              !exactPhysicalRunnerIdentityRecorded,
              metalDeviceDiscoveryAPI == "MTLCreateSystemDefaultDevice",
              metalDeviceObserved,
              metalDeviceNameRecorded,
              !physicalGPUModelIdentityRecorded,
              paravirtualMetalDeviceObserved,
              coreGraphicsBootstrapObserved,
              exactMLXRevision == ciMechanicsPolicy.exactMLXRevision,
              ciMechanicsPolicy
                == PrimeNativeDecoderCIMLXComputeEnvironmentPolicy.frozenV1,
              donorMLXCheckoutExactAndClean,
              swiftPMMLXCheckoutExactAndClean,
              ciMechanicsPolicyAppliedBeforeFirstMetalOrMLXCall,
              inProcessMechanicsPolicyPreflightObserved,
              inheritedMLXDYLDAndLLVMOverridesAbsent,
              generatedMetallibByteCount == 6_292_716,
              generatedMetallibSHA256.utf8.count == 64,
              freshCmlxDebugBuildObserved,
              initiallyAbsentControlledMetallibScratchRootObserved,
              exactlyOneNonemptyRegularMetallibObserved,
              dualStagedMetallibCopiesByteEqual,
              freshMetallibBuildAndByteExactStagingObserved,
              freshMetallibBuildProvenanceObserved,
              !runtimeLoadedExactStagedMetallibIdentityIndependentlyObserved,
              !metallibBytesRetainedInRepository,
              !metallibArtifactPublished,
              !reproducibleSecondMetallibBuildObserved,
              testBundleRebuiltFromObservedRevision,
              testBundleLinkedCoreGraphicsAndMetal,
              !testBundleBinarySHA256Recorded,
              !testBundleBinaryProvenancePublished,
              focusedSourceContractTestCount == 31,
              focusedSourceContractFailureCount == 0,
              executedAuthorityTestCount == 11,
              executedCheckpointTestCount == 14,
              executedDecoderTestCount == 19,
              executedTotalTestCount
                == executedAuthorityTestCount
                    + executedCheckpointTestCount
                    + executedDecoderTestCount,
              executedTotalTestCount == 44,
              failureCount == 0,
              unexpectedFailureCount == 0,
              skipCount == 0,
              requiredLiveMetalTestNames.count == 17,
              Set(requiredLiveMetalTestNames).count == 17,
              allRequiredLiveMetalTestsPassed,
              exactRevisionCheckoutObserved,
              exactRevisionCleanBeforeAndAfterObserved,
              correctedActiveRootAndLatinGateSequenceObserved,
              focusedSourceContractsObserved,
              exactHeadAndCleanGateSequenceCompleted,
              githubHostedMetalObserved,
              exactReviewedMainSyntheticMechanicsObserved,
              syntheticModelInitializationObserved,
              forwardExecutionObserved,
              gqaScalarParityObserved,
              batchedRoPERegressionObserved,
              cacheParityObserved,
              gradientExecutionObserved,
              deterministicRNGMechanicsObserved,
              syntheticCheckpointRoundTripObserved,
              checkpointFailurePathsObserved,
              !native300MModelAllocationObserved,
              !native300MCheckpointWriteObserved,
              !native300MCheckpointLoadObserved,
              !optimizerStepObserved,
              !trainingExecutionObserved,
              !thisObservationRuntimeValidationObserved,
              checkpointV1HistoricalIdentityPreserved,
              !repairedCheckpointCompatibilityIdentityEstablished,
              !admittedRuntimeComputePolicyEstablished,
              !runtimeDependencyClosureEstablished,
              !runtimeInitializationEstablished,
              !native300MModelAllocationAuthorized,
              !native300MCheckpointWriteAuthorized,
              !native300MCheckpointLoadAuthorized,
              !checkpointArtifactProvenanceEstablished,
              !checkpointAdmissionGranted,
              !trainingResumeEstablished,
              !modelQualityEstablished,
              !functionalTrainingAuthorized,
              !longTrainingAuthorized,
              !candidateAdmissionGranted,
              !trialAuthorized,
              !canaryReplacementAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !publicationAuthorized,
              !driverV2MutationAuthorized,
              !pmhnpMutationAuthorized,
              !geometryDependencyAuthorized,
              status.hasPrefix("ABSTAIN_"),
              orderedNextActions == [
                  "append_repaired_checkpoint_compatibility_identity",
                  "append_admitted_runtime_compute_policy",
                  "establish_runtime_dependency_metallib_device_and_initialization_closure",
                  "establish_tokenizer_model_functional_compatibility",
                  "define_bounded_native_profile_checkpoint_container_and_io_mechanics",
                  "define_prime_owned_train_and_evaluate_surfaces",
                  "persist_exact_optimizer_rng_and_data_cursor_state_before_training",
                  "request_separate_bounded_training_authorization",
                  "produce_and_bind_non_fixture_checkpoint_artifact_provenance",
              ]
        else {
            throw PrimeNativeDecoderReviewedMainMetalExecutionObservationError
                .contractDrift
        }
    }

    private var allSourceBindingsAreLowercaseHex: Bool {
        let blobs = [
            predecessorSourceGitBlob,
            observedWorkflowGitBlob,
            observedActiveGateGitBlob,
            observedLatinGateGitBlob,
            observedMetalLauncherGitBlob,
            observedDecoderSourceGitBlob,
            observedCheckpointSourceGitBlob,
            observedAuthorityTestSourceGitBlob,
            observedCheckpointTestSourceGitBlob,
            observedDecoderTestSourceGitBlob,
        ]
        let hashes = [
            predecessorSourceSHA256,
            observedEmbeddedSourceIdentitySHA256,
            observedWorkflowSHA256,
            observedActiveGateSHA256,
            observedLatinGateSHA256,
            observedMetalLauncherSHA256,
            observedDecoderSourceSHA256,
            observedCheckpointSourceSHA256,
            observedAuthorityTestSourceSHA256,
            observedCheckpointTestSourceSHA256,
            observedDecoderTestSourceSHA256,
            activeJobDownloadedLogSHA256,
            reviewedMainJobDownloadedLogSHA256,
            generatedMetallibSHA256,
        ]
        return blobs.allSatisfy {
            $0.utf8.count == 40
                && $0.utf8.allSatisfy(
                    isPrimeNativeDecoderReviewedMainObservationLowercaseHex)
        } && hashes.allSatisfy {
            $0.utf8.count == 64
                && $0.utf8.allSatisfy(
                    isPrimeNativeDecoderReviewedMainObservationLowercaseHex)
        }
    }
}

private func isPrimeNativeDecoderReviewedMainObservationLowercaseHex(
    _ byte: UInt8
) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
