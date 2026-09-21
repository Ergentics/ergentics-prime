// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Durable binding for one exact reviewed-main tokenizer-to-decoder witness.
///
/// The observed run encoded and decoded one fixed fixture, materialized one
/// random-initialized Native-300M model, matched its live parameter catalog,
/// and completed one full-prefix, no-cache forward with finite FP32 logits.
/// The output digest records that single execution; it is not an expected
/// output, a determinism claim, or semantic/model-quality evidence.
public struct
    PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservationV1:
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
    public let predecessorAuthoritySource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedWorkflowSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedActiveGateSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let observedCompatibilityLauncherSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1

    public let authoritativeRepository: String
    public let observedPullRequestNumber: Int
    public let observedPullRequestURL: String
    public let observedPullRequestMergedAt: String
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
    public let activeRootOrderedSuccessfulStepNames: [String]

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
    public let reviewedMainOrderedSuccessfulStepNames: [String]
    public let reviewedMainRanAfterActiveRootSuccess: Bool

    public let activeJobTransportDecodedUTF8LogByteCount: Int
    public let activeJobTransportDecodedUTF8LogSHA256: String
    public let reviewedMainJobTransportDecodedUTF8LogByteCount: Int
    public let reviewedMainJobTransportDecodedUTF8LogSHA256: String
    public let decodedJobLogBindingKind: String
    public let decodedJobLogsBound: Bool
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
    public let compatibilityMLXCheckoutExactAndClean: Bool
    public let compatibilityNumericsCheckoutExactAndClean: Bool
    public let environmentPolicy:
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    public let inheritedOverridePrefixesAbsent: Bool
    public let launchedEnvironmentContainedSoleMLXKey: Bool
    public let launchedEnvironmentValidatedBeforeFrameworkAccess: Bool
    public let launchedEnvironmentRevalidatedAfterEvaluation: Bool

    public let generatedMetallibArtifactKind: String
    public let generatedMetallibByteCount: UInt64
    public let generatedMetallibSHA256: String
    public let freshCmlxDebugBuildObserved: Bool
    public let exactlyOneSameJobFreshMetallibObserved: Bool
    public let compatibilityStagedMetallibByteEqual: Bool
    public let metallibArtifactRelativePath: String
    public let existingMetallibCandidateCountBeforeExecution: Int
    public let existingMetallibCandidateCountAfterExecution: Int
    public let metallibPathAndDescriptorReverified: Bool
    public let metalLibraryValidatedFromExactURL: Bool
    public let sourcePinnedLoaderIdentityClaimKind: String
    public let callerSuppliedRevisionBindingIsIndependentObservation: Bool
    public let callerExpectationIsArtifactAdmission: Bool
    public let metallibArtifactProvenanceEstablished: Bool
    public let loadedMetallibIdentityIndependentlyObserved: Bool
    public let runtimeLoadedExactMetallibIdentityEstablished: Bool
    public let runtimeLoadedMetallibPathIndependentlyObserved: Bool
    public let metallibBytesRetainedInRepository: Bool
    public let metallibArtifactPublished: Bool
    public let reproducibleSecondMetallibBuildObserved: Bool

    public let sameJobMetalDeviceName: String
    public let sameJobMetalDeviceArchitectureName: String
    public let sameJobMetalDeviceRegistryID: UInt64
    public let sameJobMetalDeviceDetailSource: String
    public let enumeratedMetalDeviceCount: Int
    public let defaultMetalDeviceMatchedIndexZero: Bool
    public let mlxDeviceType: String
    public let mlxDeviceIndex: Int
    public let coreGraphicsBootstrapObserved: Bool
    public let metalLeaseHeldBeforeAndAfterEvaluation: Bool
    public let paravirtualMetalDeviceObserved: Bool
    public let compatibilityProcessExactMetalDeviceIdentityIndependentlyObserved:
        Bool
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
    public let runtimeAuthorityTestCount: Int
    public let runtimeAuthorityFailureCount: Int
    public let runtimeAuthoritySkipCount: Int
    public let compatibilityAuthorityTestName: String
    public let compatibilityAuthorityTestCount: Int
    public let compatibilityAuthorityFailureCount: Int
    public let compatibilityAuthoritySkipCount: Int
    public let compatibilityProbeBuiltInReleaseConfiguration: Bool
    public let compatibilityProbeLinkedCoreGraphicsAndMetal: Bool
    public let compatibilityProbeDynamicallyLinkedMLXOrCmlx: Bool
    public let compatibilityProbeExecutedExactlyOnce: Bool
    public let compatibilityProbeReportedSkipOrError: Bool
    public let frozenSuiteRanBeforeRuntimeClosure: Bool
    public let runtimeClosureRanBeforeCompatibilityWitness: Bool

    public let receiptMarker: String
    public let receiptJSONPayloadByteCount: Int
    public let receiptJSONPayloadSHA256: String
    public let receiptCount: Int
    public let receiptExactKeySetsValidatedByLauncher: Bool
    public let receiptEvidence:
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1

    public let exactRevisionCheckoutObserved: Bool
    public let exactRevisionCleanBeforeAndAfterObserved: Bool
    public let exactActiveRootGateSequenceObserved: Bool
    public let maintainedRuntimeClosureObservedInSameJob: Bool
    public let boundedMLXRuntimeInitializationObservedInSameJob: Bool
    public let exactReviewedMainCompatibilityExecutionObserved: Bool
    public let tokenizerSequenceMechanicsCompatibilityEstablished: Bool
    public let tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished:
        Bool
    public let tokenizerFunctionalCompatibilityEstablished: Bool
    public let native300MModelAllocationObserved: Bool
    public let decoderForwardObserved: Bool
    public let actualParameterCatalogProjectionObserved: Bool
    public let outputShapeDTypeAndFinitenessObserved: Bool
    public let outputFloat32BitPatternSHA256: String
    public let outputDigestRecordsSingleExecutionOnly: Bool
    public let outputDigestIsExpectedValueOrDeterminismClaim: Bool
    public let decoderKVCacheUsed: Bool
    public let backwardInvoked: Bool
    public let generationInvoked: Bool
    public let processExitRequiredAfterReceipt: Bool

    public let modelFunctionalCompatibilityEstablished: Bool
    public let semanticModelCompatibilityEstablished: Bool
    public let deterministicSeedReplayObserved: Bool
    public let tf32StaticValueDirectlyObserved: Bool
    public let tf32DifferentialObserved: Bool
    public let naxTF32ConsumerPathObserved: Bool
    public let paddingMaskingOrRaggedBatchCompatibilityEstablished: Bool
    public let kvCacheCompatibilityEstablished: Bool
    public let generatedTokenDetokenizationObserved: Bool
    public let v2ManifestDefined: Bool
    public let v2CodecDefined: Bool
    public let checkpointContainerIOImplemented: Bool
    public let checkpointArtifactAvailable: Bool
    public let checkpointIOObserved: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let lossBackwardOrGradientObserved: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let optimizerStepObserved: Bool
    public let trainingResumeEstablished: Bool
    public let trainingExecutionObserved: Bool
    public let functionalTrainingAuthorized: Bool
    public let longTrainingAuthorized: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let frozenSubsystemMutationAuthorized: Bool
    public let externalRenderingDependencyAuthorized: Bool
    public let newExternalDependencyAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1: Self = {
        let authority =
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
                .frozenV1
        let evidence: PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1
        do {
            evidence = try .init(
                executedRevision:
                    "16dbcb3bad551bc6fd94f02dc3289dff60a94f24",
                executedTree:
                    "117cc63a8de0850251c23954ff9e240bff615907",
                executedEmbeddedSourceIdentitySHA256:
                    "a707d2469645c8635d273e9ebd20964de10a5b87c842b1052d24b029536fdf51",
                environmentPolicy: authority.environmentPolicy,
                launchedEnvironmentValidatedBeforeFrameworkAccess: true,
                launchedEnvironmentRevalidatedAfterEvaluation: true,
                releaseInstrumentationEvidenceAbsent: true,
                coreGraphicsBootstrapObserved: true,
                enumeratedMetalDeviceCount: 1,
                defaultMetalDeviceMatchedIndexZero: true,
                mlxDeviceType: "gpu",
                mlxDeviceIndex: 0,
                metalLeaseHeldBeforeAndAfterEvaluation: true,
                tokenizerManifestSHA256: authority.tokenizerManifestSHA256,
                tokenizerReplayProbeSHA256:
                    authority.tokenizerReplayProbeSHA256,
                tokenizerManifestAndReplayValidated: true,
                sourceText: authority.sourceText,
                sourceUTF8SHA256: authority.sourceUTF8SHA256,
                canonicalText: authority.canonicalText,
                canonicalUTF8SHA256: authority.canonicalUTF8SHA256,
                primarySequenceTokenIDs: authority.sequenceTokenIDs,
                independentSequenceTokenIDs: authority.sequenceTokenIDs,
                sequenceTokenIDsSHA256: authority.sequenceTokenIDsSHA256,
                primaryAndIndependentTokenPathsAgree: true,
                decodedText: authority.canonicalText,
                decodeRoundTripEstablished: true,
                compatibilityIdentityCanonicalByteCount:
                    authority.compatibilityIdentityCanonicalByteCount,
                compatibilityIdentitySHA256:
                    authority.compatibilityIdentitySHA256,
                compatibilityIdentityValidated: true,
                configuration: authority.configuration,
                initializationSeed: authority.initializationSeed,
                modelConstructionCount:
                    authority.requiredModelConstructionCount,
                parameterDescriptorCount: authority.parameterDescriptorCount,
                parameterCatalogCanonicalByteCount:
                    authority.parameterCatalogCanonicalByteCount,
                parameterCatalogSHA256: authority.parameterCatalogSHA256,
                parameterPathSetMatches: true,
                parameterPathOrderMatches: true,
                parameterPathOrder:
                    "global_lexicographic_ascending_utf8_v1",
                parameterShapesMatch: true,
                parameterDTypesMatch: true,
                observedParameterCount: authority.totalParameterCount,
                observedParameterByteCount: authority.totalParameterByteCount,
                forwardInvocationCount:
                    authority.requiredForwardInvocationCount,
                forwardMode: authority.requiredForwardMode,
                decoderKVCacheUsed: false,
                backwardInvoked: false,
                checkpointIOObserved: false,
                generationInvoked: false,
                memoryCacheLimit: authority.requiredMemoryCacheLimit,
                memoryCacheClearCount:
                    authority.requiredMemoryCacheClearCount,
                cacheClearedBeforeParameterMaterialization: true,
                parameterMaterializationEvaluationCount:
                    authority.requiredParameterMaterializationEvaluationCount,
                parameterMaterializationEvaluationAPI:
                    authority.parameterMaterializationEvaluationAPI,
                parametersMaterializedBeforeForward: true,
                cacheClearedAfterParameterMaterialization: true,
                cacheClearedBeforeForwardOutputEvaluation: true,
                forwardOutputEvaluationCount:
                    authority.requiredForwardOutputEvaluationCount,
                forwardOutputEvaluationAPI:
                    authority.forwardOutputEvaluationAPI,
                cacheClearedAfterForwardOutputEvaluation: true,
                logitsReadbackCount: authority.requiredLogitsReadbackCount,
                logitsReadbackAPI: authority.logitsReadbackAPI,
                outputShape: authority.expectedOutputShape,
                outputDType: authority.expectedOutputDType,
                outputElementCount: authority.expectedOutputElementCount,
                outputByteCount: authority.expectedOutputByteCount,
                outputAllFinite: true,
                outputFiniteValueCount: authority.expectedOutputElementCount,
                outputHashEncoding: authority.outputHashEncoding,
                outputFloat32BitPatternSHA256:
                    "b3679db619f92575e87d48a7633d432b194b5b641ca6c54b1cc6996216ebb223",
                metallibArtifactRelativePath:
                    PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                        .artifactRelativePath,
                metallibByteCount: 6_292_716,
                metallibSHA256:
                    "e76ce19a7bf47f6087a8dde1f5243fc6eee81c81c55d1d35e2eccbe44701d175",
                existingMetallibCandidateCountBeforeExecution: 1,
                existingMetallibCandidateCountAfterExecution: 1,
                metallibPathAndDescriptorReverified: true,
                metalLibraryValidatedFromExactURL: true
            )
        } catch {
            preconditionFailure("invalid frozen tokenizer compatibility evidence")
        }

        return Self(
            schemaVersion: 1,
            observationID:
                "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_execution_v1",
            observationKind:
                "github_reviewed_main_exact_tokenizer_to_random_initialized_native300m_full_prefix_forward_observation",
            predecessorAuthorityID: authority.authorityID,
            predecessorRemainsFrozen: true,
            predecessorRequiredForConsumption: true,
            predecessorAuthoritySource: .init(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthority.swift",
                gitMode: "100644",
                gitBlob: "a14d52e2af3dee3c39d8bb6cb017995cf3a4aa0c",
                byteCount: 66_000,
                sha256:
                    "0ff6ee0e74176d6b059c9f97932301ecc3f62f8c3ea23103b69952b1eaad4efe"
            ),
            observedWorkflowSource: .init(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "673f5774fdba9b4ac9c216a1cda9755a0642e4b5",
                byteCount: 23_721,
                sha256:
                    "12e8c0130f1f0ef51d5269f31390e7d7b5503983e2bb635b9054332858ae3ef5"
            ),
            observedActiveGateSource: .init(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "cb4ed0511641e81839773afd2fddfc51175313be",
                byteCount: 87_883,
                sha256:
                    "795ee96bc86b47dd2220ecfa833b9d2adda88ce8437431ce6a772984fa4851a2"
            ),
            observedCompatibilityLauncherSource: .init(
                path:
                    ".github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
                gitMode: "100755",
                gitBlob: "b12d52802e7f24be7a905ae0cbceeed945fcc11a",
                byteCount: 33_174,
                sha256:
                    "0c70d3cd538e297cf629707a51bcc8ede87b42e488369ffd321ac3c44062f06a"
            ),

            authoritativeRepository: "Ergentics/ergentics-prime",
            observedPullRequestNumber: 74,
            observedPullRequestURL:
                "https://github.com/Ergentics/ergentics-prime/pull/74",
            observedPullRequestMergedAt: "2026-08-11T04:01:40Z",
            observedRef: "refs/heads/main",
            observedRevision:
                "16dbcb3bad551bc6fd94f02dc3289dff60a94f24",
            observedOrderedParentRevisions: [
                "0760bb2dfea79006e1e588dcb17ac4bab449b069",
                "33a9557f9d05997e16086c3a912f1c93c0fc92a3",
            ],
            observedTree:
                "117cc63a8de0850251c23954ff9e240bff615907",
            reviewedPullRequestHeadRevision:
                "33a9557f9d05997e16086c3a912f1c93c0fc92a3",
            reviewedPullRequestHeadTree:
                "117cc63a8de0850251c23954ff9e240bff615907",
            observedEmbeddedSourceIdentitySHA256:
                "a707d2469645c8635d273e9ebd20964de10a5b87c842b1052d24b029536fdf51",
            historyPreservingTwoParentMergeObserved: true,
            mergeTreeEqualsReviewedHeadTree: true,
            mergeAuthorizedByThisObservation: false,

            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            runID: 31_457_183_699,
            runNumber: 45,
            runAttempt: 1,
            runEvent: "push",
            runURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31457183699",
            runActor: "psyop-archivist",
            runTriggeringActor: "psyop-archivist",
            runCreatedAt: "2026-08-11T04:01:42Z",
            runStartedAt: "2026-08-11T04:01:42Z",
            runUpdatedAt: "2026-08-11T04:32:04Z",
            runStatus: "completed",
            runConclusion: "success",
            publishedWorkflowArtifactCount: 0,

            activeRootJobID: 93_673_351_673,
            activeRootJobName: "First-party MLX / active-root quarantine",
            activeRootJobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31457183699/job/93673351673",
            activeRootJobStartedAt: "2026-08-11T04:01:46Z",
            activeRootJobCompletedAt: "2026-08-11T04:04:22Z",
            activeRootJobStatus: "completed",
            activeRootJobConclusion: "success",
            activeRootRunnerLabel: "macos-15",
            activeRootRunnerName: "GitHub Actions 1000001656",
            activeRootRunnerGroupName: "GitHub Actions",
            activeRootOrderedSuccessfulStepNames: [
                "Set up job",
                "Check out the exact Prime revision",
                "Validate active metadata and preserved history",
                "Parse the changed Swift contracts without dependencies",
                "Validate isolated Latin capture and observation contracts",
                "Record the authority ceiling",
                "Complete job",
            ],

            reviewedMainJobID: 93_673_756_089,
            reviewedMainJobName: "Reviewed main / focused source contracts",
            reviewedMainJobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31457183699/job/93673756089",
            reviewedMainJobStartedAt: "2026-08-11T04:04:25Z",
            reviewedMainJobCompletedAt: "2026-08-11T04:32:03Z",
            reviewedMainJobStatus: "completed",
            reviewedMainJobConclusion: "success",
            reviewedMainRunnerLabel: "macos-26",
            reviewedMainRunnerName: "GitHub Actions 1000001657",
            reviewedMainRunnerGroupName: "GitHub Actions",
            reviewedMainOrderedSuccessfulStepNames: [
                "Set up job",
                "Record the hosted Apple toolchain",
                "Check out reviewed main exactly",
                "Fetch the exact private dependency without evaluating Prime",
                "Compile and run the focused contracts without a credential",
                "Run the Prime-owned decoder on live Metal",
                "Complete job",
            ],
            reviewedMainRanAfterActiveRootSuccess: true,

            activeJobTransportDecodedUTF8LogByteCount: 219_173,
            activeJobTransportDecodedUTF8LogSHA256:
                "5825d4786d16e9a346ec034503aaa40b71205bbbfdf25267492f710d75827164",
            reviewedMainJobTransportDecodedUTF8LogByteCount: 10_122_652,
            reviewedMainJobTransportDecodedUTF8LogSHA256:
                "be02c6247195d5cd2ba3f919381c0aa5f3e80668b49f5170bec3420a1738b006",
            decodedJobLogBindingKind:
                "github_actions_job_logs_api_transport_decoded_utf8_including_leading_bom_not_raw_http_response_identity",
            decodedJobLogsBound: true,
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
            exactMLXRevision: authority.exactMLXRevision,
            exactMLXCoreRevision: authority.exactMLXCoreRevision,
            exactMLXCRevision: authority.exactMLXCRevision,
            exactSwiftNumericsRevision: authority.exactSwiftNumericsRevision,
            donorMLXCheckoutExactAndClean: true,
            compatibilityMLXCheckoutExactAndClean: true,
            compatibilityNumericsCheckoutExactAndClean: true,
            environmentPolicy: authority.environmentPolicy,
            inheritedOverridePrefixesAbsent: true,
            launchedEnvironmentContainedSoleMLXKey: true,
            launchedEnvironmentValidatedBeforeFrameworkAccess: true,
            launchedEnvironmentRevalidatedAfterEvaluation: true,

            generatedMetallibArtifactKind:
                "fresh_exact_pinned_mlx_default_metallib_not_prime_custom_language_kernel",
            generatedMetallibByteCount: 6_292_716,
            generatedMetallibSHA256:
                "e76ce19a7bf47f6087a8dde1f5243fc6eee81c81c55d1d35e2eccbe44701d175",
            freshCmlxDebugBuildObserved: true,
            exactlyOneSameJobFreshMetallibObserved: true,
            compatibilityStagedMetallibByteEqual: true,
            metallibArtifactRelativePath:
                PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .artifactRelativePath,
            existingMetallibCandidateCountBeforeExecution: 1,
            existingMetallibCandidateCountAfterExecution: 1,
            metallibPathAndDescriptorReverified: true,
            metalLibraryValidatedFromExactURL: true,
            sourcePinnedLoaderIdentityClaimKind:
                "source_pinned_exhaustive_loader_precedence_and_exclusive_candidate_inference_not_independent_instrumentation",
            callerSuppliedRevisionBindingIsIndependentObservation: false,
            callerExpectationIsArtifactAdmission: false,
            metallibArtifactProvenanceEstablished: false,
            loadedMetallibIdentityIndependentlyObserved: false,
            runtimeLoadedExactMetallibIdentityEstablished: false,
            runtimeLoadedMetallibPathIndependentlyObserved: false,
            metallibBytesRetainedInRepository: false,
            metallibArtifactPublished: false,
            reproducibleSecondMetallibBuildObserved: false,

            sameJobMetalDeviceName: "Apple Paravirtual device",
            sameJobMetalDeviceArchitectureName: "air64_v27",
            sameJobMetalDeviceRegistryID: 4_294_967_703,
            sameJobMetalDeviceDetailSource:
                "preceding_same_job_maintained_runtime_receipt_not_compatibility_receipt",
            enumeratedMetalDeviceCount: 1,
            defaultMetalDeviceMatchedIndexZero: true,
            mlxDeviceType: "gpu",
            mlxDeviceIndex: 0,
            coreGraphicsBootstrapObserved: true,
            metalLeaseHeldBeforeAndAfterEvaluation: true,
            paravirtualMetalDeviceObserved: true,
            compatibilityProcessExactMetalDeviceIdentityIndependentlyObserved:
                false,
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
            runtimeAuthorityTestCount: 1,
            runtimeAuthorityFailureCount: 0,
            runtimeAuthoritySkipCount: 0,
            compatibilityAuthorityTestName:
                "testTokenizerModelFunctionalCompatibilityAuthorityIsExactAndBounded",
            compatibilityAuthorityTestCount: 1,
            compatibilityAuthorityFailureCount: 0,
            compatibilityAuthoritySkipCount: 0,
            compatibilityProbeBuiltInReleaseConfiguration: true,
            compatibilityProbeLinkedCoreGraphicsAndMetal: true,
            compatibilityProbeDynamicallyLinkedMLXOrCmlx: false,
            compatibilityProbeExecutedExactlyOnce: true,
            compatibilityProbeReportedSkipOrError: false,
            frozenSuiteRanBeforeRuntimeClosure: true,
            runtimeClosureRanBeforeCompatibilityWitness: true,

            receiptMarker:
                "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=",
            receiptJSONPayloadByteCount: 7_182,
            receiptJSONPayloadSHA256:
                "ca68ba7807aa3a52857f8fefe3637e783b0b3c3b9952c5e1b8af1128dc3530e2",
            receiptCount: 1,
            receiptExactKeySetsValidatedByLauncher: true,
            receiptEvidence: evidence,

            exactRevisionCheckoutObserved: true,
            exactRevisionCleanBeforeAndAfterObserved: true,
            exactActiveRootGateSequenceObserved: true,
            maintainedRuntimeClosureObservedInSameJob: true,
            boundedMLXRuntimeInitializationObservedInSameJob: true,
            exactReviewedMainCompatibilityExecutionObserved: true,
            tokenizerSequenceMechanicsCompatibilityEstablished: true,
            tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished:
                true,
            tokenizerFunctionalCompatibilityEstablished: true,
            native300MModelAllocationObserved: true,
            decoderForwardObserved: true,
            actualParameterCatalogProjectionObserved: true,
            outputShapeDTypeAndFinitenessObserved: true,
            outputFloat32BitPatternSHA256:
                "b3679db619f92575e87d48a7633d432b194b5b641ca6c54b1cc6996216ebb223",
            outputDigestRecordsSingleExecutionOnly: true,
            outputDigestIsExpectedValueOrDeterminismClaim: false,
            decoderKVCacheUsed: false,
            backwardInvoked: false,
            generationInvoked: false,
            processExitRequiredAfterReceipt: true,

            modelFunctionalCompatibilityEstablished: false,
            semanticModelCompatibilityEstablished: false,
            deterministicSeedReplayObserved: false,
            tf32StaticValueDirectlyObserved: false,
            tf32DifferentialObserved: false,
            naxTF32ConsumerPathObserved: false,
            paddingMaskingOrRaggedBatchCompatibilityEstablished: false,
            kvCacheCompatibilityEstablished: false,
            generatedTokenDetokenizationObserved: false,
            v2ManifestDefined: false,
            v2CodecDefined: false,
            checkpointContainerIOImplemented: false,
            checkpointArtifactAvailable: false,
            checkpointIOObserved: false,
            checkpointArtifactProvenanceEstablished: false,
            checkpointAdmissionGranted: false,
            native300MCheckpointWriteAuthorized: false,
            native300MCheckpointLoadAuthorized: false,
            optimizerStateIncluded: false,
            rngStateIncluded: false,
            dataCursorIncluded: false,
            lossBackwardOrGradientObserved: false,
            trainEvaluateSurfaceEstablished: false,
            optimizerStepObserved: false,
            trainingResumeEstablished: false,
            trainingExecutionObserved: false,
            functionalTrainingAuthorized: false,
            longTrainingAuthorized: false,
            modelQualityEstablished: false,
            candidateAdmissionGranted: false,
            trialAuthorized: false,
            canaryReplacementAuthorized: false,
            quantizationAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            frozenSubsystemMutationAuthorized: false,
            externalRenderingDependencyAuthorized: false,
            newExternalDependencyAuthorized: false,
            status:
                "ABSTAIN_reviewed_main_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_observed_no_broad_model_functional_semantic_checkpoint_training_or_product_authority",
            orderedNextActions: [
                "define_bounded_v2_checkpoint_manifest_and_io_under_separate_authority",
                "retain_random_initialization_output_digest_as_observation_only",
                "preserve_all_training_quality_trial_canary_product_and_publication_ceilings",
            ]
        )
    }()

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let authority =
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
                .frozenV1
        let receiptCanonicalData: Data
        do {
            try authority.validateExactV1()
            try predecessorAuthoritySource.validate()
            try observedWorkflowSource.validate()
            try observedActiveGateSource.validate()
            try observedCompatibilityLauncherSource.validate()
            try receiptEvidence.validate()
            receiptCanonicalData = try PrimeCanonicalJSON.encode(
                receiptEvidence
            )
        } catch {
            throw
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservationError
                    .contractDrift
        }

        guard self == expected,
              schemaVersion == 1,
              predecessorAuthorityID == authority.authorityID,
              predecessorRemainsFrozen,
              predecessorRequiredForConsumption,
              predecessorAuthoritySource.path
                == "Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthority.swift",
              predecessorAuthoritySource.gitMode == "100644",
              predecessorAuthoritySource.gitBlob
                == "a14d52e2af3dee3c39d8bb6cb017995cf3a4aa0c",
              predecessorAuthoritySource.byteCount == 66_000,
              authoritativeRepository == authority.authoritativeRepository,
              observedPullRequestNumber == 74,
              observedRef == "refs/heads/main",
              observedOrderedParentRevisions.count == 2,
              reviewedPullRequestHeadRevision
                == observedOrderedParentRevisions[1],
              reviewedPullRequestHeadTree == observedTree,
              historyPreservingTwoParentMergeObserved,
              mergeTreeEqualsReviewedHeadTree,
              !mergeAuthorizedByThisObservation,
              exactObjectIDsAndHashesAreLowercaseHex,
              workflowID == 329_017_041,
              runID == 31_457_183_699,
              runNumber == 45,
              runAttempt == 1,
              runEvent == "push",
              runActor == runTriggeringActor,
              runStatus == "completed",
              runConclusion == "success",
              publishedWorkflowArtifactCount == 0,
              activeRootJobID == 93_673_351_673,
              activeRootJobStatus == "completed",
              activeRootJobConclusion == "success",
              activeRootOrderedSuccessfulStepNames.count == 7,
              reviewedMainJobID == 93_673_756_089,
              reviewedMainJobStatus == "completed",
              reviewedMainJobConclusion == "success",
              reviewedMainOrderedSuccessfulStepNames.count == 7,
              reviewedMainRanAfterActiveRootSuccess,
              activeJobTransportDecodedUTF8LogByteCount == 219_173,
              reviewedMainJobTransportDecodedUTF8LogByteCount
                == 10_122_652,
              decodedJobLogsBound,
              !rawHTTPResponseIdentityIndependentlyObserved,
              !jobLogsRetainedInRepository,
              !durableJobLogPublicationEstablished,
              !jobLogHashAloneBindsRevisionOrTree,
              reviewedArchitecture == "arm64",
              exactHostedRunnerImagesRecorded,
              !exactPhysicalRunnerIdentityRecorded,
              exactMLXRevision == authority.exactMLXRevision,
              exactMLXCoreRevision == authority.exactMLXCoreRevision,
              exactMLXCRevision == authority.exactMLXCRevision,
              exactSwiftNumericsRevision
                == authority.exactSwiftNumericsRevision,
              donorMLXCheckoutExactAndClean,
              compatibilityMLXCheckoutExactAndClean,
              compatibilityNumericsCheckoutExactAndClean,
              environmentPolicy == authority.environmentPolicy,
              inheritedOverridePrefixesAbsent,
              launchedEnvironmentContainedSoleMLXKey,
              launchedEnvironmentValidatedBeforeFrameworkAccess,
              launchedEnvironmentRevalidatedAfterEvaluation,
              generatedMetallibByteCount == 6_292_716,
              exactlyOneSameJobFreshMetallibObserved,
              compatibilityStagedMetallibByteEqual,
              metallibArtifactRelativePath
                == PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .artifactRelativePath,
              existingMetallibCandidateCountBeforeExecution == 1,
              existingMetallibCandidateCountAfterExecution == 1,
              metallibPathAndDescriptorReverified,
              metalLibraryValidatedFromExactURL,
              !callerSuppliedRevisionBindingIsIndependentObservation,
              !callerExpectationIsArtifactAdmission,
              !metallibArtifactProvenanceEstablished,
              !loadedMetallibIdentityIndependentlyObserved,
              !runtimeLoadedExactMetallibIdentityEstablished,
              !runtimeLoadedMetallibPathIndependentlyObserved,
              !metallibBytesRetainedInRepository,
              !metallibArtifactPublished,
              !reproducibleSecondMetallibBuildObserved,
              sameJobMetalDeviceName == "Apple Paravirtual device",
              enumeratedMetalDeviceCount == 1,
              defaultMetalDeviceMatchedIndexZero,
              mlxDeviceType == "gpu",
              mlxDeviceIndex == 0,
              coreGraphicsBootstrapObserved,
              metalLeaseHeldBeforeAndAfterEvaluation,
              paravirtualMetalDeviceObserved,
              !compatibilityProcessExactMetalDeviceIdentityIndependentlyObserved,
              !physicalGPUIdentityEstablished,
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
              compatibilityAuthorityTestCount == 1,
              compatibilityAuthorityFailureCount == 0,
              compatibilityAuthoritySkipCount == 0,
              compatibilityProbeBuiltInReleaseConfiguration,
              compatibilityProbeLinkedCoreGraphicsAndMetal,
              !compatibilityProbeDynamicallyLinkedMLXOrCmlx,
              compatibilityProbeExecutedExactlyOnce,
              !compatibilityProbeReportedSkipOrError,
              frozenSuiteRanBeforeRuntimeClosure,
              runtimeClosureRanBeforeCompatibilityWitness,
              receiptJSONPayloadByteCount == 7_182,
              receiptCanonicalData.count == receiptJSONPayloadByteCount,
              PrimeSHA256.hexDigest(of: receiptCanonicalData)
                == receiptJSONPayloadSHA256,
              receiptCount == 1,
              receiptExactKeySetsValidatedByLauncher,
              receiptEvidence.executedRevision == observedRevision,
              receiptEvidence.executedTree == observedTree,
              receiptEvidence.executedEmbeddedSourceIdentitySHA256
                == observedEmbeddedSourceIdentitySHA256,
              receiptEvidence.outputFloat32BitPatternSHA256
                == outputFloat32BitPatternSHA256,
              exactRevisionCheckoutObserved,
              exactRevisionCleanBeforeAndAfterObserved,
              exactActiveRootGateSequenceObserved,
              maintainedRuntimeClosureObservedInSameJob,
              boundedMLXRuntimeInitializationObservedInSameJob,
              exactReviewedMainCompatibilityExecutionObserved,
              tokenizerSequenceMechanicsCompatibilityEstablished,
              tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished,
              tokenizerFunctionalCompatibilityEstablished,
              native300MModelAllocationObserved,
              decoderForwardObserved,
              actualParameterCatalogProjectionObserved,
              outputShapeDTypeAndFinitenessObserved,
              outputDigestRecordsSingleExecutionOnly,
              !outputDigestIsExpectedValueOrDeterminismClaim,
              !decoderKVCacheUsed,
              !backwardInvoked,
              !generationInvoked,
              processExitRequiredAfterReceipt,
              falseCeilingsAreExact,
              receiptEvidence.status
                == "PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only",
              status
                == "ABSTAIN_reviewed_main_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_observed_no_broad_model_functional_semantic_checkpoint_training_or_product_authority",
              orderedNextActions.first
                == "define_bounded_v2_checkpoint_manifest_and_io_under_separate_authority"
        else {
            throw
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservationError
                    .contractDrift
        }
    }

    private var exactObjectIDsAndHashesAreLowercaseHex: Bool {
        let objectIDs = [
            predecessorAuthoritySource.gitBlob,
            observedWorkflowSource.gitBlob,
            observedActiveGateSource.gitBlob,
            observedCompatibilityLauncherSource.gitBlob,
            observedRevision,
            observedTree,
            reviewedPullRequestHeadRevision,
            reviewedPullRequestHeadTree,
            runnerProvisionerCommit,
        ] + observedOrderedParentRevisions
        let hashes = [
            predecessorAuthoritySource.sha256,
            observedWorkflowSource.sha256,
            observedActiveGateSource.sha256,
            observedCompatibilityLauncherSource.sha256,
            observedEmbeddedSourceIdentitySHA256,
            activeJobTransportDecodedUTF8LogSHA256,
            reviewedMainJobTransportDecodedUTF8LogSHA256,
            generatedMetallibSHA256,
            receiptJSONPayloadSHA256,
            outputFloat32BitPatternSHA256,
        ]
        return objectIDs.allSatisfy {
            isExactLowercaseHex($0, count: 40)
        } && hashes.allSatisfy {
            isExactLowercaseHex($0, count: 64)
        }
    }

    private func isExactLowercaseHex(
        _ value: String,
        count: Int
    ) -> Bool {
        value.utf8.count == count
            && value.utf8.allSatisfy {
                ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
            }
    }

    private var falseCeilingsAreExact: Bool {
        !modelFunctionalCompatibilityEstablished
            && !semanticModelCompatibilityEstablished
            && !callerSuppliedRevisionBindingIsIndependentObservation
            && !callerExpectationIsArtifactAdmission
            && !metallibArtifactProvenanceEstablished
            && !loadedMetallibIdentityIndependentlyObserved
            && !runtimeLoadedExactMetallibIdentityEstablished
            && !runtimeLoadedMetallibPathIndependentlyObserved
            && !physicalGPUIdentityEstablished
            && !deterministicSeedReplayObserved
            && !tf32StaticValueDirectlyObserved
            && !tf32DifferentialObserved
            && !naxTF32ConsumerPathObserved
            && !paddingMaskingOrRaggedBatchCompatibilityEstablished
            && !kvCacheCompatibilityEstablished
            && !generatedTokenDetokenizationObserved
            && !decoderKVCacheUsed
            && !backwardInvoked
            && !generationInvoked
            && !v2ManifestDefined
            && !v2CodecDefined
            && !checkpointContainerIOImplemented
            && !checkpointArtifactAvailable
            && !checkpointIOObserved
            && !checkpointArtifactProvenanceEstablished
            && !checkpointAdmissionGranted
            && !native300MCheckpointWriteAuthorized
            && !native300MCheckpointLoadAuthorized
            && !optimizerStateIncluded
            && !rngStateIncluded
            && !dataCursorIncluded
            && !lossBackwardOrGradientObserved
            && !trainEvaluateSurfaceEstablished
            && !optimizerStepObserved
            && !trainingResumeEstablished
            && !trainingExecutionObserved
            && !functionalTrainingAuthorized
            && !longTrainingAuthorized
            && !modelQualityEstablished
            && !candidateAdmissionGranted
            && !trialAuthorized
            && !canaryReplacementAuthorized
            && !quantizationAuthorized
            && !productUseAuthorized
            && !publicationAuthorized
            && !frozenSubsystemMutationAuthorized
            && !externalRenderingDependencyAuthorized
            && !newExternalDependencyAuthorized
    }
}
