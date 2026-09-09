// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderMaintainedRuntimeExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Exact reviewed-main observation of the bounded maintained runtime closure.
///
/// The observed invocation bound one clean merge revision, one freshly built
/// pinned-MLX Metal library, one source-pinned exclusive loader-candidate
/// inference, one singleton Metal device set, and one exact FP32 MLX probe.
/// The receipt did not independently instrument the library path selected by
/// MLX and did not exercise decoder, checkpoint, training, or product work.
public struct PrimeNativeDecoderMaintainedRuntimeExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorRequiredForConsumption: Bool
    public let predecessorSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1

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

    public let observedWorkflowSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedActiveGateSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedFrozenMetalLauncherSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedRuntimeClosureLauncherSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedRootPackageManifestSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedRootPackageResolvedSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedRuntimeSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedRuntimeValidationManifestSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedRuntimeValidationResolvedSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedRuntimeValidationProbeSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedRuntimeValidationTestSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1

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
    public let publishedWorkflowArtifactCount: Int

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

    public let activeJobTransportDecodedUTF8LogByteCount: Int
    public let activeJobTransportDecodedUTF8LogSHA256: String
    public let reviewedMainJobTransportDecodedUTF8LogByteCount: Int
    public let reviewedMainJobTransportDecodedUTF8LogSHA256: String
    public let decodedJobLogBindingKind: String
    public let decodedJobLogsBound: Bool
    public let localGHCLIRunLogZIPByteCount: Int
    public let localGHCLIRunLogZIPSHA256: String
    public let localGHCLIRunLogZIPObserved: Bool
    public let rawHTTPResponseIdentityIndependentlyObserved: Bool
    public let jobLogsRetainedInRepository: Bool
    public let durableJobLogPublicationEstablished: Bool
    public let jobLogHashAloneBindsRevisionOrTree: Bool

    public let runnerVersion: String
    public let runnerProvisionerVersion: String
    public let runnerProvisionerCommit: String
    public let activeRunnerImage: String
    public let activeRunnerImageVersion: String
    public let activeOperatingSystemVersion: String
    public let activeOperatingSystemBuild: String
    public let reviewedRunnerImage: String
    public let reviewedRunnerImageVersion: String
    public let reviewedOperatingSystemVersion: String
    public let reviewedOperatingSystemBuild: String
    public let reviewedArchitecture: String
    public let xcodeVersion: String
    public let xcodeBuildVersion: String
    public let swiftVersion: String
    public let swiftTarget: String
    public let macOSSDKVersion: String
    public let swiftDriverVersion: String
    public let exactHostedRunnerImagesRecorded: Bool
    public let exactPhysicalRunnerIdentityRecorded: Bool

    public let exactMLXRepository: String
    public let exactMLXRevision: String
    public let exactMLXCoreRevision: String
    public let exactMLXCRevision: String
    public let exactSwiftNumericsRevision: String
    public let donorMLXCheckoutExactAndClean: Bool
    public let swiftPMMLXCheckoutExactAndClean: Bool
    public let swiftPMNumericsCheckoutExactAndClean: Bool
    public let maintainedEnvironmentPolicy:
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    public let inheritedOverridePrefixesAbsent: Bool
    public let launchedEnvironmentContainedSoleMLXKey: Bool
    public let launchedEnvironmentValidatedBeforeFrameworkAccess: Bool
    public let launchedEnvironmentRevalidatedAfterEvaluation: Bool

    public let generatedMetallibArtifactKind: String
    public let generatedMetallibByteCount: Int
    public let generatedMetallibSHA256: String
    public let freshCmlxDebugBuildObserved: Bool
    public let initiallyAbsentControlledMetallibScratchRootObserved: Bool
    public let exactlyOneNonemptyRegularMetallibObserved: Bool
    public let frozenAndRuntimeStagedMetallibCopiesByteEqual: Bool
    public let executionLocalFreshMetallibBuildProvenanceObserved: Bool
    public let runtimeExpectationBoundToFreshMetallib: Bool
    public let callerExpectationIsArtifactAdmission: Bool
    public let metallibArtifactProvenanceEstablished: Bool
    public let metallibArtifactRelativePath: String
    public let metallibDeviceID: UInt64
    public let metallibInode: UInt64
    public let uniqueCandidateCountBeforeExecution: Int
    public let uniqueCandidateCountAfterExecution: Int
    public let existingCandidateCountBeforeExecution: Int
    public let existingCandidateCountAfterExecution: Int
    public let metallibPathAndDescriptorReverified: Bool
    public let metalLibraryValidatedFromExactURL: Bool
    public let sourcePinnedLoaderIdentityClaimKind: String
    public let runtimeLoadedExactMetallibIdentityEstablished: Bool
    public let runtimeLoadedMetallibPathIndependentlyObserved: Bool
    public let metallibBytesRetainedInRepository: Bool
    public let metallibArtifactPublished: Bool
    public let reproducibleSecondMetallibBuildObserved: Bool

    public let metalDeviceEnumerationAPI: String
    public let metalDefaultDeviceAPI: String
    public let metalDeviceName: String
    public let metalDeviceArchitectureName: String
    public let metalDeviceRegistryID: UInt64
    public let enumeratedMetalDeviceCount: Int
    public let metalDeviceHasUnifiedMemory: Bool
    public let metalDeviceIsLowPower: Bool
    public let metalDeviceIsRemovable: Bool
    public let metalDeviceIsHeadless: Bool
    public let defaultDeviceMatchedIndexZero: Bool
    public let postflightDeviceReverified: Bool
    public let coreGraphicsBootstrapObserved: Bool
    public let mlxDeviceIdentityClaimKind: String
    public let paravirtualMetalDeviceObserved: Bool
    public let physicalGPUIdentityEstablished: Bool

    public let focusedSourceContractTestCount: Int
    public let focusedSourceContractFailureCount: Int
    public let checkpointCompatibilityTestCount: Int
    public let checkpointCompatibilityFailureCount: Int
    public let frozenAuthorityTestCount: Int
    public let frozenCheckpointTestCount: Int
    public let frozenDecoderTestCount: Int
    public let frozenTotalTestCount: Int
    public let frozenFailureCount: Int
    public let frozenSkipCount: Int
    public let runtimeAuthorityTestName: String
    public let runtimeAuthorityTestCount: Int
    public let runtimeAuthorityFailureCount: Int
    public let runtimeAuthoritySkipCount: Int
    public let runtimeProbeBuiltInReleaseConfiguration: Bool
    public let runtimeProbeLinkedCoreGraphicsAndMetal: Bool
    public let runtimeProbeDynamicallyLinkedMLXOrCmlx: Bool
    public let runtimeProbeExecutedExactlyOnce: Bool
    public let runtimeProbeReportedSkipOrError: Bool
    public let frozenSuiteRanBeforeRuntimeClosure: Bool

    public let receiptMarker: String
    public let receiptJSONPayloadByteCount: Int
    public let receiptJSONPayloadSHA256: String
    public let receiptCount: Int
    public let receiptExactKeySetsValidatedByLauncher: Bool
    public let receiptSchemaVersion: Int
    public let receiptEvidenceID: String
    public let receiptAuthorityID: String
    public let receiptPlanID: String
    public let receiptExecutableName: String
    public let receiptExecutableByteCount: Int
    public let receiptExecutableSHA256: String
    public let receiptExecutableDeviceID: UInt64
    public let receiptExecutableInode: UInt64
    public let receiptExecutableCaptureMethod: String
    public let receiptExecutablePathAndDescriptorReverified: Bool
    public let receiptReleaseInstrumentationInspectedImageScope: String
    public let receiptMainExecutableForbiddenInstrumentationEvidenceAbsent:
        Bool
    public let receiptCompatibilityIdentityCanonicalByteCount: Int
    public let receiptCompatibilityIdentitySHA256: String
    public let receiptNativeConfigurationParameterCount: Int
    public let mlxInitializationDeviceType: String
    public let mlxInitializationDeviceIndex: Int
    public let mlxInitializationOperation: String
    public let mlxInitializationDType: String
    public let mlxInitializationShape: [Int]
    public let mlxInitializationLeftFloat32BitPatterns: [UInt32]
    public let mlxInitializationRightFloat32BitPatterns: [UInt32]
    public let mlxInitializationOutputFloat32BitPatterns: [UInt32]
    public let mlxInitializationEvaluationAPI: String
    public let mlxInitializationReadbackAPI: String
    public let exactMLXInitializationOutputEstablished: Bool

    public let exactRevisionCheckoutObserved: Bool
    public let exactRevisionCleanBeforeAndAfterObserved: Bool
    public let exactActiveRootAndLatinGateSequenceObserved: Bool
    public let freshMetallibAndFrozenTestSequenceObserved: Bool
    public let exactReviewedMainRuntimeClosureObserved: Bool
    public let admittedRuntimeComputePolicyEstablished: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let sourcePinnedExclusiveCandidateInferenceEstablished: Bool
    public let runtimeMetalDeviceIdentityEstablished: Bool
    public let boundedMLXRuntimeInitializationEstablished: Bool
    public let tf32StaticValueDirectlyObserved: Bool
    public let tf32DifferentialObserved: Bool
    public let naxTF32ConsumerPathObserved: Bool
    public let decoderModelAllocationObserved: Bool
    public let decoderExecutionObserved: Bool
    public let v2ManifestDefined: Bool
    public let v2CodecDefined: Bool
    public let checkpointContainerIOImplemented: Bool
    public let checkpointArtifactAvailable: Bool
    public let checkpointIOObserved: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let native300MModelAllocationAuthorized: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let tokenizerFunctionalCompatibilityEstablished: Bool
    public let modelFunctionalCompatibilityEstablished: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let trainingResumeEstablished: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let optimizerStepObserved: Bool
    public let trainingExecutionObserved: Bool
    public let modelQualityEstablished: Bool
    public let functionalTrainingAuthorized: Bool
    public let longTrainingAuthorized: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let frozenSubsystemMutationAuthorized: Bool
    public let externalRenderingDependencyAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_maintained_runtime_execution_v1",
        observationKind:
            "github_reviewed_main_exact_runtime_dependency_device_and_bounded_mlx_initialization_observation",
        predecessorAuthorityID:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.authorityID,
        predecessorRemainsFrozen: true,
        predecessorRequiredForConsumption: true,
        predecessorSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeComputeAuthority.swift",
                gitMode: "100644",
                gitBlob:
                    "379c3e40ab24ae696c01da0b3f2116d0093cedb2",
                byteCount: 60_844,
                sha256:
                    "f53a7a055058fbf528d7a96b4111c673fa3bc2dbd2ae10bf5129aa8b828a2445"
            ),

        authoritativeRepository: "Ergentics/ergentics-prime",
        observedPullRequestNumber: 72,
        observedRef: "refs/heads/main",
        observedRevision:
            "b127b2f96c1bcbc8f2ee2017027898853c871469",
        observedOrderedParentRevisions: [
            "933347eca2f3a744efc8f6bc434fea87725d81e5",
            "140fb48dd3d0ed0e03ae572413a5db1352edefd8",
        ],
        observedTree:
            "d0f50f3bf1f8038542817dbed5f15381ddddc413",
        reviewedPullRequestHeadRevision:
            "140fb48dd3d0ed0e03ae572413a5db1352edefd8",
        reviewedPullRequestHeadTree:
            "d0f50f3bf1f8038542817dbed5f15381ddddc413",
        observedEmbeddedSourceIdentitySHA256:
            "cd86702e7e126f8512a4b359ad833e5e79cd69dfdab1403706920d81a0bda7de",
        historyPreservingTwoParentMergeObserved: true,
        mergeTreeEqualsReviewedHeadTree: true,
        mergeAuthorizedByThisObservation: false,

        observedWorkflowSource: .init(
            path: ".github/workflows/prime-active-root-quarantine.yml",
            gitMode: "100644",
            gitBlob: "b7ad4bb26ce355a195033ab325d7042b881e43de",
            byteCount: 22_018,
            sha256:
                "a080c5f6126f8f99345643f91be746a76895487d026d0de70dfd899a2c2c7d94"
        ),
        observedActiveGateSource: .init(
            path: ".github/scripts/prime-ci-active-root-quarantine.sh",
            gitMode: "100755",
            gitBlob: "45026e90257d8962961333482d328e8674dd2aa9",
            byteCount: 64_860,
            sha256:
                "12c4af29bab1ef42036506e2a29c55bd0771e96a2e10ef578b1e67c4af6c33eb"
        ),
        observedFrozenMetalLauncherSource: .init(
            path: ".github/scripts/prime-ci-native-decoder-metal.sh",
            gitMode: "100755",
            gitBlob: "418d2d2753cee38e0b3558ad45e1e09865ffd11d",
            byteCount: 11_793,
            sha256:
                "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff"
        ),
        observedRuntimeClosureLauncherSource:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.runtimeClosureLauncherSource,
        observedRootPackageManifestSource:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.successorRootPackageManifestSource,
        observedRootPackageResolvedSource:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.successorRootPackageResolvedSource,
        observedRuntimeSource:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.runtimeSource,
        observedRuntimeValidationManifestSource:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.runtimeValidationPackageManifestSource,
        observedRuntimeValidationResolvedSource:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.runtimeValidationPackageResolvedSource,
        observedRuntimeValidationProbeSource:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.runtimeValidationProbeSource,
        observedRuntimeValidationTestSource:
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1.runtimeValidationTestSource,

        workflowID: 329_017_041,
        workflowName: "Prime active-root quarantine",
        runID: 31_449_020_532,
        runNumber: 41,
        runAttempt: 1,
        runEvent: "push",
        runURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31449020532",
        runActor: "psyop-archivist",
        runTriggeringActor: "psyop-archivist",
        runCreatedAt: "2026-08-11T01:20:53Z",
        runStartedAt: "2026-08-11T01:20:53Z",
        runUpdatedAt: "2026-08-11T01:37:40Z",
        runStatus: "completed",
        runConclusion: "success",
        publishedWorkflowArtifactCount: 0,

        activeRootJobID: 93_649_296_403,
        activeRootJobName: "First-party MLX / active-root quarantine",
        activeRootJobURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31449020532/job/93649296403",
        activeRootJobStartedAt: "2026-08-11T01:20:55Z",
        activeRootJobCompletedAt: "2026-08-11T01:22:56Z",
        activeRootJobStatus: "completed",
        activeRootJobConclusion: "success",
        activeRootRunnerLabel: "macos-15",
        activeRootRunnerName: "GitHub Actions 1000001650",
        activeRootRunnerGroupName: "GitHub Actions",
        activeRootRequiredSuccessfulStepNames: [
            "Check out the exact Prime revision",
            "Validate active metadata and preserved history",
            "Parse the changed Swift contracts without dependencies",
            "Validate isolated Latin capture and observation contracts",
            "Record the authority ceiling",
        ],

        reviewedMainJobID: 93_649_608_696,
        reviewedMainJobName: "Reviewed main / focused source contracts",
        reviewedMainJobURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31449020532/job/93649608696",
        reviewedMainJobStartedAt: "2026-08-11T01:22:59Z",
        reviewedMainJobCompletedAt: "2026-08-11T01:37:39Z",
        reviewedMainJobStatus: "completed",
        reviewedMainJobConclusion: "success",
        reviewedMainRunnerLabel: "macos-26",
        reviewedMainRunnerName: "GitHub Actions 1000001651",
        reviewedMainRunnerGroupName: "GitHub Actions",
        reviewedMainRequiredSuccessfulStepNames: [
            "Record the hosted Apple toolchain",
            "Check out reviewed main exactly",
            "Fetch the exact private dependency without evaluating Prime",
            "Compile and run the focused contracts without a credential",
            "Run the Prime-owned decoder on live Metal",
        ],
        reviewedMainRanAfterActiveRootSuccess: true,

        activeJobTransportDecodedUTF8LogByteCount: 217_365,
        activeJobTransportDecodedUTF8LogSHA256:
            "54ac1a66f25ff15846075c80f42337218869d2382f91553cc159e257a7673016",
        reviewedMainJobTransportDecodedUTF8LogByteCount: 10_098_466,
        reviewedMainJobTransportDecodedUTF8LogSHA256:
            "bd1767a2b4b90fed9ecd411612fcf98ded97debd399cb76fbc929cdd37deef76",
        decodedJobLogBindingKind:
            "github_connector_returned_job_log_string_utf8_reencoding_including_leading_bom_not_raw_http_response_identity",
        decodedJobLogsBound: true,
        localGHCLIRunLogZIPByteCount: 1_279_678,
        localGHCLIRunLogZIPSHA256:
            "bb4dc05a5c9b9b8dc7cc42f7dabc0adbc4a0600c0fd2f655bcffe8c412e770a0",
        localGHCLIRunLogZIPObserved: true,
        rawHTTPResponseIdentityIndependentlyObserved: false,
        jobLogsRetainedInRepository: false,
        durableJobLogPublicationEstablished: false,
        jobLogHashAloneBindsRevisionOrTree: false,

        runnerVersion: "2.336.0",
        runnerProvisionerVersion: "20260707.563",
        runnerProvisionerCommit:
            "02667638d2b423fbc733a8e32a88b44996a3ba6e",
        activeRunnerImage: "macos-15-arm64",
        activeRunnerImageVersion: "20260727.0256.1",
        activeOperatingSystemVersion: "15.7.7",
        activeOperatingSystemBuild: "24G720",
        reviewedRunnerImage: "macos-26-arm64",
        reviewedRunnerImageVersion: "20260728.0273.1",
        reviewedOperatingSystemVersion: "26.5.2",
        reviewedOperatingSystemBuild: "25F84",
        reviewedArchitecture: "arm64",
        xcodeVersion: "26.6",
        xcodeBuildVersion: "17F113",
        swiftVersion:
            "6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)",
        swiftTarget: "arm64-apple-macosx26.0",
        macOSSDKVersion: "26.5",
        swiftDriverVersion: "1.148.6",
        exactHostedRunnerImagesRecorded: true,
        exactPhysicalRunnerIdentityRecorded: false,

        exactMLXRepository: "Ergentics/ergentics-mlx-swift",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        exactMLXCoreRevision:
            "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
        exactMLXCRevision:
            "0726ca922fc902c4c61ef9c27d94132be418e945",
        exactSwiftNumericsRevision:
            "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
        donorMLXCheckoutExactAndClean: true,
        swiftPMMLXCheckoutExactAndClean: true,
        swiftPMNumericsCheckoutExactAndClean: true,
        maintainedEnvironmentPolicy:
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .declaration,
        inheritedOverridePrefixesAbsent: true,
        launchedEnvironmentContainedSoleMLXKey: true,
        launchedEnvironmentValidatedBeforeFrameworkAccess: true,
        launchedEnvironmentRevalidatedAfterEvaluation: true,

        generatedMetallibArtifactKind:
            "fresh_exact_pinned_mlx_default_metallib_not_prime_custom_language_kernel",
        generatedMetallibByteCount: 6_292_684,
        generatedMetallibSHA256:
            "b7ea3fb0e851f4e2417f3e82be63deca8df627daf480cf04cc1b2b70195d7b87",
        freshCmlxDebugBuildObserved: true,
        initiallyAbsentControlledMetallibScratchRootObserved: true,
        exactlyOneNonemptyRegularMetallibObserved: true,
        frozenAndRuntimeStagedMetallibCopiesByteEqual: true,
        executionLocalFreshMetallibBuildProvenanceObserved: true,
        runtimeExpectationBoundToFreshMetallib: true,
        callerExpectationIsArtifactAdmission: false,
        metallibArtifactProvenanceEstablished: false,
        metallibArtifactRelativePath:
            "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
        metallibDeviceID: 16_777_233,
        metallibInode: 2_918_706,
        uniqueCandidateCountBeforeExecution: 5,
        uniqueCandidateCountAfterExecution: 5,
        existingCandidateCountBeforeExecution: 1,
        existingCandidateCountAfterExecution: 1,
        metallibPathAndDescriptorReverified: true,
        metalLibraryValidatedFromExactURL: true,
        sourcePinnedLoaderIdentityClaimKind:
            "source_pinned_exhaustive_loader_precedence_and_exclusive_candidate_inference_not_independent_instrumentation",
        runtimeLoadedExactMetallibIdentityEstablished: false,
        runtimeLoadedMetallibPathIndependentlyObserved: false,
        metallibBytesRetainedInRepository: false,
        metallibArtifactPublished: false,
        reproducibleSecondMetallibBuildObserved: false,

        metalDeviceEnumerationAPI: "MTLCopyAllDevices",
        metalDefaultDeviceAPI: "MTLCreateSystemDefaultDevice",
        metalDeviceName: "Apple Paravirtual device",
        metalDeviceArchitectureName: "air64_v27",
        metalDeviceRegistryID: 4_294_967_679,
        enumeratedMetalDeviceCount: 1,
        metalDeviceHasUnifiedMemory: true,
        metalDeviceIsLowPower: false,
        metalDeviceIsRemovable: false,
        metalDeviceIsHeadless: false,
        defaultDeviceMatchedIndexZero: true,
        postflightDeviceReverified: true,
        coreGraphicsBootstrapObserved: true,
        mlxDeviceIdentityClaimKind:
            "source_pinned_index_zero_inference_from_singleton_metal_device_set",
        paravirtualMetalDeviceObserved: true,
        physicalGPUIdentityEstablished: false,

        focusedSourceContractTestCount: 31,
        focusedSourceContractFailureCount: 0,
        checkpointCompatibilityTestCount: 1,
        checkpointCompatibilityFailureCount: 0,
        frozenAuthorityTestCount: 11,
        frozenCheckpointTestCount: 14,
        frozenDecoderTestCount: 19,
        frozenTotalTestCount: 44,
        frozenFailureCount: 0,
        frozenSkipCount: 0,
        runtimeAuthorityTestName:
            "testMaintainedRuntimeComputeAuthorityIsExactAndBounded",
        runtimeAuthorityTestCount: 1,
        runtimeAuthorityFailureCount: 0,
        runtimeAuthoritySkipCount: 0,
        runtimeProbeBuiltInReleaseConfiguration: true,
        runtimeProbeLinkedCoreGraphicsAndMetal: true,
        runtimeProbeDynamicallyLinkedMLXOrCmlx: false,
        runtimeProbeExecutedExactlyOnce: true,
        runtimeProbeReportedSkipOrError: false,
        frozenSuiteRanBeforeRuntimeClosure: true,

        receiptMarker:
            "PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=",
        receiptJSONPayloadByteCount: 6_853,
        receiptJSONPayloadSHA256:
            "7eb35759da975bd1219692cc7712e1c713d0429e0c620d0ee340997fb5bb665a",
        receiptCount: 1,
        receiptExactKeySetsValidatedByLauncher: true,
        receiptSchemaVersion: 1,
        receiptEvidenceID:
            "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
        receiptAuthorityID:
            "ergentics_prime_native_decoder_maintained_runtime_compute_v1",
        receiptPlanID:
            "ergentics_prime_native_decoder_maintained_runtime_plan_v1",
        receiptExecutableName:
            "PrimeNativeDecoderRuntimeClosureProbe",
        receiptExecutableByteCount: 42_735_896,
        receiptExecutableSHA256:
            "935344fdac6cfeaf75491f70cacf30807baae2ab2b54744cb270981fc6a7b6e5",
        receiptExecutableDeviceID: 16_777_233,
        receiptExecutableInode: 2_915_135,
        receiptExecutableCaptureMethod:
            "prime_secure_running_executable_capture_plus_retained_descriptor_v1",
        receiptExecutablePathAndDescriptorReverified: true,
        receiptReleaseInstrumentationInspectedImageScope:
            "dyld_main_executable_image_index_zero",
        receiptMainExecutableForbiddenInstrumentationEvidenceAbsent: true,
        receiptCompatibilityIdentityCanonicalByteCount: 30_553,
        receiptCompatibilityIdentitySHA256:
            "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843",
        receiptNativeConfigurationParameterCount: 271_107_072,
        mlxInitializationDeviceType: "gpu",
        mlxInitializationDeviceIndex: 0,
        mlxInitializationOperation:
            "mlx_gpu_index_zero_float32_2x2_matmul_checked_eval",
        mlxInitializationDType: "float32",
        mlxInitializationShape: [2, 2],
        mlxInitializationLeftFloat32BitPatterns: [
            3_209_481_421,
            1_045_220_557,
            1_050_253_722,
            3_201_092_813,
        ],
        mlxInitializationRightFloat32BitPatterns: [
            1_065_353_216,
            0,
            0,
            1_065_353_216,
        ],
        mlxInitializationOutputFloat32BitPatterns: [
            3_209_481_421,
            1_045_220_557,
            1_050_253_722,
            3_201_092_813,
        ],
        mlxInitializationEvaluationAPI:
            "MLX.matmul+MLX.withError+MLX.checkedEval",
        mlxInitializationReadbackAPI:
            "MLX.MLXArray.asArray(Float.self)",
        exactMLXInitializationOutputEstablished: true,

        exactRevisionCheckoutObserved: true,
        exactRevisionCleanBeforeAndAfterObserved: true,
        exactActiveRootAndLatinGateSequenceObserved: true,
        freshMetallibAndFrozenTestSequenceObserved: true,
        exactReviewedMainRuntimeClosureObserved: true,
        admittedRuntimeComputePolicyEstablished: true,
        runtimeDependencyClosureEstablished: true,
        sourcePinnedExclusiveCandidateInferenceEstablished: true,
        runtimeMetalDeviceIdentityEstablished: true,
        boundedMLXRuntimeInitializationEstablished: true,
        tf32StaticValueDirectlyObserved: false,
        tf32DifferentialObserved: false,
        naxTF32ConsumerPathObserved: false,
        decoderModelAllocationObserved: false,
        decoderExecutionObserved: false,
        v2ManifestDefined: false,
        v2CodecDefined: false,
        checkpointContainerIOImplemented: false,
        checkpointArtifactAvailable: false,
        checkpointIOObserved: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointAdmissionGranted: false,
        native300MModelAllocationAuthorized: false,
        native300MCheckpointWriteAuthorized: false,
        native300MCheckpointLoadAuthorized: false,
        tokenizerFunctionalCompatibilityEstablished: false,
        modelFunctionalCompatibilityEstablished: false,
        optimizerStateIncluded: false,
        rngStateIncluded: false,
        dataCursorIncluded: false,
        trainingResumeEstablished: false,
        trainEvaluateSurfaceEstablished: false,
        optimizerStepObserved: false,
        trainingExecutionObserved: false,
        modelQualityEstablished: false,
        functionalTrainingAuthorized: false,
        longTrainingAuthorized: false,
        candidateAdmissionGranted: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        frozenSubsystemMutationAuthorized: false,
        externalRenderingDependencyAuthorized: false,
        status:
            "ABSTAIN_exact_reviewed_main_maintained_runtime_dependency_device_and_bounded_mlx_initialization_observed_no_independently_observed_loaded_metallib_path_or_downstream_authority",
        orderedNextActions: [
            "establish_tokenizer_model_functional_compatibility",
            "define_bounded_v2_checkpoint_manifest_and_io_under_separate_authority",
            "define_generic_train_and_evaluate_surfaces",
            "establish_exact_optimizer_rng_and_data_cursor_resume",
            "request_separate_bounded_training_authorization",
        ]
    )

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let predecessor =
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1

        do {
            try predecessor.validateExactV1()
            for source in observedSourceBindings {
                try source.validate()
            }
        } catch {
            throw
                PrimeNativeDecoderMaintainedRuntimeExecutionObservationError
                    .contractDrift
        }

        guard self == expected,
              schemaVersion == 1,
              predecessorAuthorityID == predecessor.authorityID,
              predecessorRemainsFrozen,
              predecessorRequiredForConsumption,
              predecessorSource.path
                == "Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeComputeAuthority.swift",
              predecessorSource.gitMode == "100644",
              predecessorSource.byteCount == 60_844,
              authoritativeRepository == predecessor.authoritativeRepository,
              observedPullRequestNumber == 72,
              observedRef == "refs/heads/main",
              observedRevision.utf8.count == 40,
              observedOrderedParentRevisions.count == 2,
              reviewedPullRequestHeadRevision
                == observedOrderedParentRevisions[1],
              reviewedPullRequestHeadTree == observedTree,
              historyPreservingTwoParentMergeObserved,
              mergeTreeEqualsReviewedHeadTree,
              !mergeAuthorizedByThisObservation,
              allExactObjectIDsAndHashesAreLowercaseHex,
              observedRootPackageManifestSource
                == predecessor.successorRootPackageManifestSource,
              observedRootPackageResolvedSource
                == predecessor.successorRootPackageResolvedSource,
              observedRuntimeSource == predecessor.runtimeSource,
              observedRuntimeValidationManifestSource
                == predecessor.runtimeValidationPackageManifestSource,
              observedRuntimeValidationResolvedSource
                == predecessor.runtimeValidationPackageResolvedSource,
              observedRuntimeValidationProbeSource
                == predecessor.runtimeValidationProbeSource,
              observedRuntimeValidationTestSource
                == predecessor.runtimeValidationTestSource,
              observedRuntimeClosureLauncherSource
                == predecessor.runtimeClosureLauncherSource,
              workflowID == 329_017_041,
              runID == 31_449_020_532,
              runNumber == 41,
              runAttempt == 1,
              runEvent == "push",
              runActor == runTriggeringActor,
              runStatus == "completed",
              runConclusion == "success",
              publishedWorkflowArtifactCount == 0,
              activeRootJobID == 93_649_296_403,
              activeRootJobStatus == "completed",
              activeRootJobConclusion == "success",
              activeRootRunnerLabel == "macos-15",
              activeRootRequiredSuccessfulStepNames.count == 5,
              reviewedMainJobID == 93_649_608_696,
              reviewedMainJobStatus == "completed",
              reviewedMainJobConclusion == "success",
              reviewedMainRunnerLabel == "macos-26",
              reviewedMainRequiredSuccessfulStepNames.count == 5,
              reviewedMainRanAfterActiveRootSuccess,
              activeJobTransportDecodedUTF8LogByteCount == 217_365,
              reviewedMainJobTransportDecodedUTF8LogByteCount
                == 10_098_466,
              decodedJobLogsBound,
              localGHCLIRunLogZIPByteCount == 1_279_678,
              localGHCLIRunLogZIPObserved,
              !rawHTTPResponseIdentityIndependentlyObserved,
              !jobLogsRetainedInRepository,
              !durableJobLogPublicationEstablished,
              !jobLogHashAloneBindsRevisionOrTree,
              reviewedArchitecture == "arm64",
              exactHostedRunnerImagesRecorded,
              !exactPhysicalRunnerIdentityRecorded,
              exactMLXRevision == predecessor.exactMLXRevision,
              exactMLXCoreRevision == predecessor.exactMLXCoreRevision,
              exactMLXCRevision == predecessor.exactMLXCRevision,
              exactSwiftNumericsRevision
                == predecessor.exactSwiftNumericsRevision,
              donorMLXCheckoutExactAndClean,
              swiftPMMLXCheckoutExactAndClean,
              swiftPMNumericsCheckoutExactAndClean,
              maintainedEnvironmentPolicy
                == predecessor.maintainedComputeEnvironmentPolicy,
              inheritedOverridePrefixesAbsent,
              launchedEnvironmentContainedSoleMLXKey,
              launchedEnvironmentValidatedBeforeFrameworkAccess,
              launchedEnvironmentRevalidatedAfterEvaluation,
              generatedMetallibByteCount == 6_292_684,
              freshCmlxDebugBuildObserved,
              initiallyAbsentControlledMetallibScratchRootObserved,
              exactlyOneNonemptyRegularMetallibObserved,
              frozenAndRuntimeStagedMetallibCopiesByteEqual,
              executionLocalFreshMetallibBuildProvenanceObserved,
              runtimeExpectationBoundToFreshMetallib,
              !callerExpectationIsArtifactAdmission,
              !metallibArtifactProvenanceEstablished,
              metallibArtifactRelativePath
                == predecessor.metallibArtifactRelativePath,
              uniqueCandidateCountBeforeExecution == 5,
              uniqueCandidateCountAfterExecution == 5,
              existingCandidateCountBeforeExecution == 1,
              existingCandidateCountAfterExecution == 1,
              metallibPathAndDescriptorReverified,
              metalLibraryValidatedFromExactURL,
              sourcePinnedLoaderIdentityClaimKind
                == predecessor.loaderIdentityClaimKind,
              !runtimeLoadedExactMetallibIdentityEstablished,
              !runtimeLoadedMetallibPathIndependentlyObserved,
              !metallibBytesRetainedInRepository,
              !metallibArtifactPublished,
              !reproducibleSecondMetallibBuildObserved,
              metalDeviceEnumerationAPI
                == predecessor.metalDeviceEnumerationAPI,
              metalDefaultDeviceAPI == predecessor.metalDefaultDeviceAPI,
              metalDeviceName == "Apple Paravirtual device",
              metalDeviceArchitectureName == "air64_v27",
              enumeratedMetalDeviceCount == 1,
              metalDeviceHasUnifiedMemory,
              !metalDeviceIsLowPower,
              !metalDeviceIsRemovable,
              !metalDeviceIsHeadless,
              defaultDeviceMatchedIndexZero,
              postflightDeviceReverified,
              coreGraphicsBootstrapObserved,
              mlxDeviceIdentityClaimKind
                == predecessor.mlxDeviceIdentityClaimKind,
              paravirtualMetalDeviceObserved,
              !physicalGPUIdentityEstablished,
              focusedSourceContractTestCount == 31,
              focusedSourceContractFailureCount == 0,
              checkpointCompatibilityTestCount == 1,
              checkpointCompatibilityFailureCount == 0,
              frozenTotalTestCount
                == frozenAuthorityTestCount
                    + frozenCheckpointTestCount
                    + frozenDecoderTestCount,
              frozenTotalTestCount == 44,
              frozenFailureCount == 0,
              frozenSkipCount == 0,
              runtimeAuthorityTestCount == 1,
              runtimeAuthorityFailureCount == 0,
              runtimeAuthoritySkipCount == 0,
              runtimeProbeBuiltInReleaseConfiguration,
              runtimeProbeLinkedCoreGraphicsAndMetal,
              !runtimeProbeDynamicallyLinkedMLXOrCmlx,
              runtimeProbeExecutedExactlyOnce,
              !runtimeProbeReportedSkipOrError,
              frozenSuiteRanBeforeRuntimeClosure,
              receiptJSONPayloadByteCount == 6_853,
              receiptCount == 1,
              receiptExactKeySetsValidatedByLauncher,
              receiptSchemaVersion == 1,
              receiptAuthorityID == predecessor.authorityID,
              receiptExecutableByteCount == 42_735_896,
              receiptExecutablePathAndDescriptorReverified,
              receiptReleaseInstrumentationInspectedImageScope
                == "dyld_main_executable_image_index_zero",
              receiptMainExecutableForbiddenInstrumentationEvidenceAbsent,
              mlxInitializationDeviceType == "gpu",
              mlxInitializationDeviceIndex == predecessor.requiredMLXGPUIndex,
              mlxInitializationOperation
                == predecessor.initializationProbeOperation,
              mlxInitializationDType
                == predecessor.initializationProbeDType,
              mlxInitializationShape
                == predecessor.initializationProbeShape,
              mlxInitializationLeftFloat32BitPatterns
                == predecessor.initializationProbeLeftFloat32BitPatterns,
              mlxInitializationRightFloat32BitPatterns
                == predecessor.initializationProbeRightFloat32BitPatterns,
              mlxInitializationOutputFloat32BitPatterns
                == predecessor.initializationProbeExpectedFloat32BitPatterns,
              mlxInitializationEvaluationAPI
                == predecessor.initializationProbeEvaluationAPI,
              mlxInitializationReadbackAPI
                == predecessor.initializationProbeReadbackAPI,
              exactMLXInitializationOutputEstablished,
              exactRevisionCheckoutObserved,
              exactRevisionCleanBeforeAndAfterObserved,
              exactActiveRootAndLatinGateSequenceObserved,
              freshMetallibAndFrozenTestSequenceObserved,
              exactReviewedMainRuntimeClosureObserved,
              admittedRuntimeComputePolicyEstablished,
              runtimeDependencyClosureEstablished,
              sourcePinnedExclusiveCandidateInferenceEstablished,
              runtimeMetalDeviceIdentityEstablished,
              boundedMLXRuntimeInitializationEstablished,
              !tf32StaticValueDirectlyObserved,
              !tf32DifferentialObserved,
              !naxTF32ConsumerPathObserved,
              !decoderModelAllocationObserved,
              !decoderExecutionObserved,
              !v2ManifestDefined,
              !v2CodecDefined,
              !checkpointContainerIOImplemented,
              !checkpointArtifactAvailable,
              !checkpointIOObserved,
              !checkpointArtifactProvenanceEstablished,
              !checkpointAdmissionGranted,
              !native300MModelAllocationAuthorized,
              !native300MCheckpointWriteAuthorized,
              !native300MCheckpointLoadAuthorized,
              !tokenizerFunctionalCompatibilityEstablished,
              !modelFunctionalCompatibilityEstablished,
              !optimizerStateIncluded,
              !rngStateIncluded,
              !dataCursorIncluded,
              !trainingResumeEstablished,
              !trainEvaluateSurfaceEstablished,
              !optimizerStepObserved,
              !trainingExecutionObserved,
              !modelQualityEstablished,
              !functionalTrainingAuthorized,
              !longTrainingAuthorized,
              !candidateAdmissionGranted,
              !trialAuthorized,
              !canaryReplacementAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !publicationAuthorized,
              !frozenSubsystemMutationAuthorized,
              !externalRenderingDependencyAuthorized,
              status.hasPrefix("ABSTAIN_"),
              orderedNextActions.first
                == "establish_tokenizer_model_functional_compatibility"
        else {
            throw
                PrimeNativeDecoderMaintainedRuntimeExecutionObservationError
                    .contractDrift
        }
    }

    private var observedSourceBindings:
        [PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1]
    {
        [
            predecessorSource,
            observedWorkflowSource,
            observedActiveGateSource,
            observedFrozenMetalLauncherSource,
            observedRuntimeClosureLauncherSource,
            observedRootPackageManifestSource,
            observedRootPackageResolvedSource,
            observedRuntimeSource,
            observedRuntimeValidationManifestSource,
            observedRuntimeValidationResolvedSource,
            observedRuntimeValidationProbeSource,
            observedRuntimeValidationTestSource,
        ]
    }

    private var allExactObjectIDsAndHashesAreLowercaseHex: Bool {
        let objectIDs = observedSourceBindings.map(\.gitBlob)
            + [
                observedRevision,
                observedTree,
                reviewedPullRequestHeadRevision,
                reviewedPullRequestHeadTree,
                runnerProvisionerCommit,
            ]
            + observedOrderedParentRevisions
        let hashes = observedSourceBindings.map(\.sha256)
            + [
                observedEmbeddedSourceIdentitySHA256,
                activeJobTransportDecodedUTF8LogSHA256,
                reviewedMainJobTransportDecodedUTF8LogSHA256,
                localGHCLIRunLogZIPSHA256,
                generatedMetallibSHA256,
                receiptJSONPayloadSHA256,
                receiptExecutableSHA256,
                receiptCompatibilityIdentitySHA256,
            ]
        return objectIDs.allSatisfy(
            isPrimeNativeDecoderMaintainedRuntimeObservationGitID
        ) && hashes.allSatisfy(
            isPrimeNativeDecoderMaintainedRuntimeObservationSHA256
        )
    }
}

private func isPrimeNativeDecoderMaintainedRuntimeObservationGitID(
    _ value: String
) -> Bool {
    value.utf8.count == 40
        && value.utf8.allSatisfy(
            isPrimeNativeDecoderMaintainedRuntimeObservationLowercaseHex
        )
        && value != String(repeating: "0", count: 40)
}

private func isPrimeNativeDecoderMaintainedRuntimeObservationSHA256(
    _ value: String
) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy(
            isPrimeNativeDecoderMaintainedRuntimeObservationLowercaseHex
        )
        && value != String(repeating: "0", count: 64)
}

private func isPrimeNativeDecoderMaintainedRuntimeObservationLowercaseHex(
    _ byte: UInt8
) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
