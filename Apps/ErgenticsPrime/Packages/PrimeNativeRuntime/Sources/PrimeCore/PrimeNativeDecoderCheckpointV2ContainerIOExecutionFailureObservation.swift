// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Append-only observation of the exhausted first Native-300M V2 I/O attempt.
///
/// Exact source and terminal-log binding permits a narrow source-pinned
/// control-flow inference: one seed-42 source decoder was constructed and
/// evaluated, and one public checkpoint write returned before the immediately
/// following artifact-root stable-object guard rejected the run. The process
/// emitted neither its root identities nor a typed evidence receipt. Therefore
/// the changed root field, artifact metadata, public load, parent verification,
/// and parent cleanup were not observed. A local APFS reproduction diagnosed a
/// directory link-count transition from two to three when the leaf was added;
/// that diagnosis is explicitly not telemetry from the failed hosted run.
///
/// The predecessor authority is consumed and cannot authorize a rerun. This
/// observation grants no checkpoint admission and establishes no checkpoint
/// retention or provenance; it grants no training, candidate, publication, or
/// product authority.
public struct
    PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorEvidenceID: String
    public let predecessorAuthorityRemainsFrozen: Bool
    public let predecessorAuthorityRequiredForConsumption: Bool
    public let predecessorAuthorityValidated: Bool
    public let predecessorBaseSourceBindingCount: Int
    public let predecessorNewExecutionSourceBindingCount: Int

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
    public let exactDirectSuccessorOfAuthorizedBaseObserved: Bool
    public let observedSourceBindings:
        [PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1]

    public let workflowID: Int
    public let workflowName: String
    public let runID: Int
    public let runNumber: Int
    public let runAttempt: Int
    public let runEvent: String
    public let runActor: String
    public let runTriggeringActor: String
    public let runURL: String
    public let runCreatedAt: String
    public let runStartedAt: String
    public let runCompletedAt: String
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
    public let activeRootOrderedStepNames: [String]
    public let activeRootOrderedStepConclusions: [String]
    public let activeRootJobSucceeded: Bool

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
    public let reviewedMainOrderedStepNames: [String]
    public let reviewedMainOrderedStepConclusions: [String]
    public let reviewedMainRanAfterActiveRootSuccess: Bool
    public let liveStepName: String
    public let liveStepStartedAt: String
    public let liveStepCompletedAt: String
    public let liveStepConclusion: String

    public let activeJobRenderedLogByteCount: Int
    public let activeJobRenderedLogLineCount: Int
    public let activeJobRenderedLogSHA256: String
    public let reviewedMainJobRenderedLogByteCount: Int
    public let reviewedMainJobRenderedLogLineCount: Int
    public let reviewedMainJobRenderedLogSHA256: String
    public let renderedJobLogBindingKind: String
    public let renderedJobLogsBound: Bool
    public let rawGitHubLogArchiveBytesBound: Bool
    public let jobLogsRetainedInRepository: Bool
    public let durableJobLogPublicationEstablished: Bool
    public let publishedWorkflowArtifactCount: Int
    public let checkpointArtifactUploaded: Bool

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
    public let metalDeviceName: String
    public let metalDeviceObservedBeforeFailure: Bool
    public let paravirtualMetalDeviceObserved: Bool
    public let physicalGPUIdentityRecorded: Bool

    public let exactMLXRepository: String
    public let exactMLXRevision: String
    public let exactMLXCoreRevision: String
    public let exactMLXCRevision: String
    public let exactSwiftNumericsRevision: String
    public let metallibArtifactRelativePath: String
    public let metallibByteCount: Int
    public let metallibSHA256: String
    public let freshMetallibBuildSucceeded: Bool
    public let metallibBytesRetainedInRepository: Bool
    public let metallibArtifactUploaded: Bool
    public let metallibArtifactProvenanceEstablished: Bool

    public let predecessorMetalGateSucceeded: Bool
    public let predecessorMaintainedRuntimeClosureSucceeded: Bool
    public let predecessorTokenizerCompatibilitySucceeded: Bool
    public let predecessorValidatedLogCount: Int
    public let predecessorValidatedReceiptCount: Int
    public let maintainedRuntimeReceiptMarker: String
    public let maintainedRuntimeReceiptAuthorityID: String
    public let maintainedRuntimeReceiptEvidenceID: String
    public let maintainedRuntimeReceiptByteCount: Int
    public let maintainedRuntimeReceiptSHA256: String
    public let tokenizerReceiptMarker: String
    public let tokenizerReceiptAuthorityID: String
    public let tokenizerReceiptEvidenceID: String
    public let tokenizerReceiptByteCount: Int
    public let tokenizerReceiptSHA256: String
    public let exactAuthorizedRunnerTemporaryPathCountReclaimed: Int
    public let authorizedRunnerTemporaryReclamationCompleted: Bool

    public let exactOrderedFailureLines: [String]
    public let probeProcessExitCode: Int
    public let receiptBeginMarkerCount: Int
    public let receiptChunkMarkerCount: Int
    public let receiptEndMarkerCount: Int
    public let executionEvidenceValueConstructed: Bool
    public let canonicalReceiptConstructed: Bool
    public let canonicalReceiptEmitted: Bool
    public let sourcePinnedInferenceBasis: String
    public let initializationSeed: UInt64
    public let callerSourceModelConstructionCountSourceInferred: Int
    public let initialParameterMaterializationEvaluationCountSourceInferred:
        Int
    public let initialParameterMaterializationEvaluationAPI: String
    public let memoryCacheLimitSourceInferred: Int
    public let memoryCacheClearInvocationCountSourceInferred: Int
    public let publicCheckpointWriteInvocationCountSourceInferred: Int
    public let publicCheckpointWriteCompletionCountSourceInferred: Int
    public let publicCheckpointLoadInvocationCountSourceInferred: Int
    public let publicCheckpointLoadCompletionCountSourceInferred: Int
    public let sourceModelLexicalScopeEndedBeforeFailureSourceInferred: Bool
    public let sourceModelARCDeallocationObserved: Bool
    public let postWriteRootStableObjectIdentityGuardPassed: Bool
    public let publishedArtifactPathInspectionCompleted: Bool
    public let artifactRootIdentityBeforeWriteEmitted: Bool
    public let artifactRootIdentityAfterWriteEmitted: Bool
    public let artifactRootChangedFieldIdentifiedByRun: Bool
    public let localDiagnosticKind: String
    public let localDiagnosticRootLinkCountBeforeLeafAddition: Int
    public let localDiagnosticRootLinkCountAfterLeafAddition: Int
    public let localDiagnosisIsFailedRunTelemetry: Bool
    public let parentReceiptVerificationCompleted: Bool
    public let parentArtifactUnlinkCompleted: Bool
    public let parentArtifactRootRmdirCompleted: Bool
    public let eventualRunnerVMCleanupObserved: Bool

    public let predecessorAuthorityAttemptConsumed: Bool
    public let predecessorAuthorityExhausted: Bool
    public let rerunObserved: Bool
    public let rerunAuthorized: Bool
    public let replacementExecutionAuthorityEstablished: Bool
    public let externalBindingReturnSourceInferred: Bool
    public let externalBindingFieldsIndependentlyObserved: Bool
    public let native300MModelAllocationIndependentlyObserved: Bool
    public let native300MCheckpointWriteIndependentlyObserved: Bool
    public let native300MCheckpointLoadObserved: Bool
    public let checkpointIORoundTripObserved: Bool
    public let checkpointArtifactAvailabilityEstablished: Bool
    public let checkpointArtifactRetentionEstablished: Bool
    public let checkpointArtifactRetentionAuthorized: Bool
    public let checkpointArtifactUploadAuthorized: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointContainerHashIndependentlyObserved: Bool
    public let checkpointAdmissionGranted: Bool
    public let checkpointDurabilityObserved: Bool
    public let logicalParameterRoundTripObserved: Bool
    public let checkpointLoadedForwardObserved: Bool
    public let checkpointRoundTripBehaviorParityEstablished: Bool
    public let optimizerStateInclusionObservedByCheckpointAttempt: Bool
    public let rngStateInclusionObservedByCheckpointAttempt: Bool
    public let dataCursorInclusionObservedByCheckpointAttempt: Bool
    public let kvCacheStateInclusionObservedByCheckpointAttempt: Bool
    public let decoderForwardObservedByCheckpointAttempt: Bool
    public let decoderKVCacheUsedByCheckpointAttempt: Bool
    public let backwardInvokedByCheckpointAttempt: Bool
    public let lossObservedByCheckpointAttempt: Bool
    public let optimizerStepObservedByCheckpointAttempt: Bool
    public let generationInvokedByCheckpointAttempt: Bool
    public let trainingExecutionObserved: Bool
    public let trainingResumeEstablished: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_failure_observation_v1",
        observationKind:
            "github_reviewed_main_exact_one_shot_checkpoint_v2_io_failure_observation",
        predecessorAuthorityID:
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_authority_v1",
        predecessorEvidenceID:
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_evidence_v1",
        predecessorAuthorityRemainsFrozen: true,
        predecessorAuthorityRequiredForConsumption: true,
        predecessorAuthorityValidated: true,
        predecessorBaseSourceBindingCount: 12,
        predecessorNewExecutionSourceBindingCount: 6,

        authoritativeRepository: "Ergentics/ergentics-prime",
        observedPullRequestNumber: 77,
        observedRef: "refs/heads/main",
        observedRevision:
            "27749af3347437daa693d4375acb759283923a4a",
        observedOrderedParentRevisions: [
            "b861fa8270cbdceefd6079f7e09fece495fc4b79",
            "93fdf5119a8c293412d1505288222699f657613d",
        ],
        observedTree:
            "a222082fa6b5c469cc4da967a77cbb7e4960e455",
        reviewedPullRequestHeadRevision:
            "93fdf5119a8c293412d1505288222699f657613d",
        reviewedPullRequestHeadTree:
            "a222082fa6b5c469cc4da967a77cbb7e4960e455",
        observedEmbeddedSourceIdentitySHA256:
            "0d5173da11223f9b8db98f9eff57bd3eefe3a087aa307a4185cfea566aad3110",
        historyPreservingTwoParentMergeObserved: true,
        mergeTreeEqualsReviewedHeadTree: true,
        exactDirectSuccessorOfAuthorizedBaseObserved: true,
        observedSourceBindings: [
            .init(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthority.swift",
                gitMode: "100644",
                gitBlob: "f82bd280fd1c269ce6a6e0392a8849630d0af124",
                byteCount: 60_654,
                sha256:
                    "d56febe490f6a774028c1bc1567f907f18b0f5591b78a24ad0ff0fe6947be62f"),
            .init(
                path:
                    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift",
                gitMode: "100644",
                gitBlob: "416423e41a072ab323a345a12782ac54faac57d8",
                byteCount: 52_898,
                sha256:
                    "bc5dc07a60dc2b3642bd5440857d32345a36b128283e0c200deb15889d388544"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift",
                gitMode: "100644",
                gitBlob: "233ab6e0a2c747ca2166a3ad0a8841ddd83a24b6",
                byteCount: 2_136,
                sha256:
                    "cfcde7c6ebf00a2aabe26aa1b4417a3cc5e7d4caf771fbd32cc7a2637be5d2b1"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved",
                gitMode: "100644",
                gitBlob: "9887e211ac39cdf8083419ba144f2ca26ffc44cd",
                byteCount: 645,
                sha256:
                    "538966e5f400f66e786b2946e4267ccf41e92ef4077a29c2358413792640e5b6"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift",
                gitMode: "100644",
                gitBlob: "71262c7794e5d47e0d8990346a0e6682f4fcd09b",
                byteCount: 40_914,
                sha256:
                    "a1a768c17e6fcb510b75468b81309863712cd3f07dc7dc4f41ba559f27d9fad9"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift",
                gitMode: "100644",
                gitBlob: "8b1c18b57c70dda967885c2737d0d4170c7e417a",
                byteCount: 27_448,
                sha256:
                    "869db27f80824cfa0a6420efac62237c389cbed692c3f119f47f07c5ff68db6f"),
            .init(
                path:
                    ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh",
                gitMode: "100755",
                gitBlob: "0683f4bfba4dc7929e4c397a499132f859a80b0e",
                byteCount: 60_125,
                sha256:
                    "824fe36fcb6e0707650868e1fbfc1bb67cf6ccace7a9c0ea21a60bead27bbe07"),
            .init(
                path:
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "baea5e62d9afbba135e510a1da2a0c4ceb6536c1",
                byteCount: 149_222,
                sha256:
                    "8aa4b8356570995b2ce0eea998a1b71b8199db744b475093c9dac0776f8418a7"),
            .init(
                path:
                    ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "c154efdb03b8f42a1c27374fc6bd9daf151da726",
                byteCount: 27_530,
                sha256:
                    "cb8830ba31ea7290df66cd612a4ffbafe4038f48893936c5032e39e239009377"),
            .init(
                path:
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitMode: "100644",
                gitBlob: "a11523078d0960e9996a0d9e5c99e136409cffba",
                byteCount: 546,
                sha256:
                    "8931459da093f8823eaceb794e01f9af24ea04362274cfb0c89f30b2ba2dd27f"),
        ],

        workflowID: 329_017_041,
        workflowName: "Prime active-root quarantine",
        runID: 31_472_165_002,
        runNumber: 51,
        runAttempt: 1,
        runEvent: "push",
        runActor: "psyop-archivist",
        runTriggeringActor: "psyop-archivist",
        runURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31472165002",
        runCreatedAt: "2026-08-11T08:12:05Z",
        runStartedAt: "2026-08-11T08:12:05Z",
        runCompletedAt: "2026-08-11T08:52:29Z",
        runUpdatedAt: "2026-08-11T08:52:29Z",
        runStatus: "completed",
        runConclusion: "failure",

        activeRootJobID: 93_717_678_740,
        activeRootJobName: "First-party MLX / active-root quarantine",
        activeRootJobURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31472165002/job/93717678740",
        activeRootJobStartedAt: "2026-08-11T08:12:08Z",
        activeRootJobCompletedAt: "2026-08-11T08:14:50Z",
        activeRootJobStatus: "completed",
        activeRootJobConclusion: "success",
        activeRootRunnerLabel: "macos-15",
        activeRootRunnerName: "GitHub Actions 1000001667",
        activeRootRunnerGroupName: "GitHub Actions",
        activeRootOrderedStepNames: [
            "Set up job",
            "Check out the exact Prime revision",
            "Validate active metadata and preserved history",
            "Parse the changed Swift contracts without dependencies",
            "Validate isolated Latin capture and observation contracts",
            "Record the authority ceiling",
            "Complete job",
        ],
        activeRootOrderedStepConclusions: [
            "success", "success", "success", "success", "success",
            "success", "success",
        ],
        activeRootJobSucceeded: true,

        reviewedMainJobID: 93_718_282_081,
        reviewedMainJobName: "Reviewed main / focused source contracts",
        reviewedMainJobURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31472165002/job/93718282081",
        reviewedMainJobStartedAt: "2026-08-11T08:14:53Z",
        reviewedMainJobCompletedAt: "2026-08-11T08:52:28Z",
        reviewedMainJobStatus: "completed",
        reviewedMainJobConclusion: "failure",
        reviewedMainRunnerLabel: "macos-26",
        reviewedMainRunnerName: "GitHub Actions 1000001668",
        reviewedMainRunnerGroupName: "GitHub Actions",
        reviewedMainOrderedStepNames: [
            "Set up job",
            "Record the hosted Apple toolchain",
            "Check out reviewed main exactly",
            "Fetch the exact private dependency without evaluating Prime",
            "Compile and run the focused contracts without a credential",
            "Run the Prime-owned decoder on live Metal",
            "Complete job",
        ],
        reviewedMainOrderedStepConclusions: [
            "success", "success", "success", "success", "success",
            "failure", "success",
        ],
        reviewedMainRanAfterActiveRootSuccess: true,
        liveStepName: "Run the Prime-owned decoder on live Metal",
        liveStepStartedAt: "2026-08-11T08:24:31Z",
        liveStepCompletedAt: "2026-08-11T08:52:23Z",
        liveStepConclusion: "failure",

        activeJobRenderedLogByteCount: 314_687,
        activeJobRenderedLogLineCount: 1_707,
        activeJobRenderedLogSHA256:
            "e227ed862544edeb3ed643a7d2dc0e669913529e5d43a585b609707136c688f2",
        reviewedMainJobRenderedLogByteCount: 14_369_398,
        reviewedMainJobRenderedLogLineCount: 77_706,
        reviewedMainJobRenderedLogSHA256:
            "252608a826ddbde07dec115f4ec5d8b3bd46faf317765ebf6beccb6d67edd44c",
        renderedJobLogBindingKind:
            "github_cli_run_view_job_log_rendered_bytes_hashed_without_text_normalization_v1",
        renderedJobLogsBound: true,
        rawGitHubLogArchiveBytesBound: false,
        jobLogsRetainedInRepository: false,
        durableJobLogPublicationEstablished: false,
        publishedWorkflowArtifactCount: 0,
        checkpointArtifactUploaded: false,

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
        metalDeviceName: "Apple Paravirtual device",
        metalDeviceObservedBeforeFailure: true,
        paravirtualMetalDeviceObserved: true,
        physicalGPUIdentityRecorded: false,

        exactMLXRepository: "Ergentics/ergentics-mlx-swift",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        exactMLXCoreRevision:
            "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
        exactMLXCRevision:
            "0726ca922fc902c4c61ef9c27d94132be418e945",
        exactSwiftNumericsRevision:
            "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
        metallibArtifactRelativePath:
            "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
        metallibByteCount: 6_292_716,
        metallibSHA256:
            "28f37e46c6fddadfe602a1534c1dacd337c2700908494c5eaeb3917f8c20de2b",
        freshMetallibBuildSucceeded: true,
        metallibBytesRetainedInRepository: false,
        metallibArtifactUploaded: false,
        metallibArtifactProvenanceEstablished: false,

        predecessorMetalGateSucceeded: true,
        predecessorMaintainedRuntimeClosureSucceeded: true,
        predecessorTokenizerCompatibilitySucceeded: true,
        predecessorValidatedLogCount: 8,
        predecessorValidatedReceiptCount: 2,
        maintainedRuntimeReceiptMarker:
            "PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=",
        maintainedRuntimeReceiptAuthorityID:
            "ergentics_prime_native_decoder_maintained_runtime_compute_v1",
        maintainedRuntimeReceiptEvidenceID:
            "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
        maintainedRuntimeReceiptByteCount: 6_853,
        maintainedRuntimeReceiptSHA256:
            "3183cf34d60a9d08132b573cd1817969d198f36c54deb4802a62b4b9cbfb40e6",
        tokenizerReceiptMarker:
            "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=",
        tokenizerReceiptAuthorityID:
            "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_v1",
        tokenizerReceiptEvidenceID:
            "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1",
        tokenizerReceiptByteCount: 7_182,
        tokenizerReceiptSHA256:
            "184ffeb8be052ff2972b6a2d2b45aa060ce013f3f4b6f914e66e3a66c6d7c9cd",
        exactAuthorizedRunnerTemporaryPathCountReclaimed: 24,
        authorizedRunnerTemporaryReclamationCompleted: true,

        exactOrderedFailureLines: [
            "prime-native-decoder-checkpoint-v2-io-execution-probe: contract drift: artifact root changed identity during write",
            "prime-native-decoder-checkpoint-v2-io: Release probe failed",
            "Process completed with exit code 2.",
        ],
        probeProcessExitCode: 2,
        receiptBeginMarkerCount: 0,
        receiptChunkMarkerCount: 0,
        receiptEndMarkerCount: 0,
        executionEvidenceValueConstructed: false,
        canonicalReceiptConstructed: false,
        canonicalReceiptEmitted: false,
        sourcePinnedInferenceBasis:
            "exact_bound_probe_source_control_flow_plus_exact_terminal_failure_lines_no_dynamic_receipt",
        initializationSeed: 42,
        callerSourceModelConstructionCountSourceInferred: 1,
        initialParameterMaterializationEvaluationCountSourceInferred: 1,
        initialParameterMaterializationEvaluationAPI: "MLX.checkedEval(model)",
        memoryCacheLimitSourceInferred: 0,
        memoryCacheClearInvocationCountSourceInferred: 1,
        publicCheckpointWriteInvocationCountSourceInferred: 1,
        publicCheckpointWriteCompletionCountSourceInferred: 1,
        publicCheckpointLoadInvocationCountSourceInferred: 0,
        publicCheckpointLoadCompletionCountSourceInferred: 0,
        sourceModelLexicalScopeEndedBeforeFailureSourceInferred: true,
        sourceModelARCDeallocationObserved: false,
        postWriteRootStableObjectIdentityGuardPassed: false,
        publishedArtifactPathInspectionCompleted: false,
        artifactRootIdentityBeforeWriteEmitted: false,
        artifactRootIdentityAfterWriteEmitted: false,
        artifactRootChangedFieldIdentifiedByRun: false,
        localDiagnosticKind:
            "local_apfs_reproduction_directory_link_count_changes_from_two_to_three_when_one_leaf_is_added_not_failed_run_telemetry",
        localDiagnosticRootLinkCountBeforeLeafAddition: 2,
        localDiagnosticRootLinkCountAfterLeafAddition: 3,
        localDiagnosisIsFailedRunTelemetry: false,
        parentReceiptVerificationCompleted: false,
        parentArtifactUnlinkCompleted: false,
        parentArtifactRootRmdirCompleted: false,
        eventualRunnerVMCleanupObserved: false,

        predecessorAuthorityAttemptConsumed: true,
        predecessorAuthorityExhausted: true,
        rerunObserved: false,
        rerunAuthorized: false,
        replacementExecutionAuthorityEstablished: false,
        externalBindingReturnSourceInferred: true,
        externalBindingFieldsIndependentlyObserved: false,
        native300MModelAllocationIndependentlyObserved: false,
        native300MCheckpointWriteIndependentlyObserved: false,
        native300MCheckpointLoadObserved: false,
        checkpointIORoundTripObserved: false,
        checkpointArtifactAvailabilityEstablished: false,
        checkpointArtifactRetentionEstablished: false,
        checkpointArtifactRetentionAuthorized: false,
        checkpointArtifactUploadAuthorized: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointContainerHashIndependentlyObserved: false,
        checkpointAdmissionGranted: false,
        checkpointDurabilityObserved: false,
        logicalParameterRoundTripObserved: false,
        checkpointLoadedForwardObserved: false,
        checkpointRoundTripBehaviorParityEstablished: false,
        optimizerStateInclusionObservedByCheckpointAttempt: false,
        rngStateInclusionObservedByCheckpointAttempt: false,
        dataCursorInclusionObservedByCheckpointAttempt: false,
        kvCacheStateInclusionObservedByCheckpointAttempt: false,
        decoderForwardObservedByCheckpointAttempt: false,
        decoderKVCacheUsedByCheckpointAttempt: false,
        backwardInvokedByCheckpointAttempt: false,
        lossObservedByCheckpointAttempt: false,
        optimizerStepObservedByCheckpointAttempt: false,
        generationInvokedByCheckpointAttempt: false,
        trainingExecutionObserved: false,
        trainingResumeEstablished: false,
        modelQualityEstablished: false,
        candidateAdmissionGranted: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        status:
            "ABSTAIN_seed42_public_write_return_source_inferred_postwrite_root_guard_failed_no_load_no_receipt_no_artifact_admission",
        orderedNextActions: [
            "append_exact_failed_attempt_observation_and_remove_exhausted_live_command",
            "repair_artifact_root_identity_semantics_without_reclassifying_the_failed_run",
            "require_a_separate_successor_execution_authority_before_any_new_attempt",
        ])

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let predecessor =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1
                .frozenV1

        do {
            try predecessor.validateExactV1()
            for source in observedSourceBindings {
                try source.validate()
            }
        } catch {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationError
                    .contractDrift
        }

        let expectedSourcePaths = [
            "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthority.swift",
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift",
            ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh",
            ".github/scripts/prime-ci-active-root-quarantine.sh",
            ".github/workflows/prime-active-root-quarantine.yml",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
        ]

        guard self == expected,
              schemaVersion == 1,
              observationID
                == "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_failure_observation_v1",
              observationKind
                == "github_reviewed_main_exact_one_shot_checkpoint_v2_io_failure_observation",
              predecessorAuthorityID == predecessor.authorityID,
              predecessorEvidenceID
                == "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_evidence_v1",
              predecessorAuthorityRemainsFrozen,
              predecessorAuthorityRequiredForConsumption,
              predecessorAuthorityValidated,
              predecessorBaseSourceBindingCount
                == predecessor.baseSourceBindings.count,
              predecessorBaseSourceBindingCount == 12,
              Set(predecessor.baseSourceBindings.map(\.path)).count == 12,
              predecessorNewExecutionSourceBindingCount
                == predecessor.newExecutionSourceBindings.count,
              predecessorNewExecutionSourceBindingCount == 6,
              Set(predecessor.newExecutionSourceBindings.map(\.path)).count
                == 6,
              Set(predecessor.baseSourceBindings.map(\.path)).isDisjoint(
                with: Set(predecessor.newExecutionSourceBindings.map(\.path))),
              authoritativeRepository == predecessor.authoritativeRepository,
              observedPullRequestNumber == 77,
              observedRef == "refs/heads/main",
              observedRevision.utf8.count == 40,
              observedOrderedParentRevisions == [
                  predecessor.baseRevision,
                  reviewedPullRequestHeadRevision,
              ],
              observedTree == reviewedPullRequestHeadTree,
              observedEmbeddedSourceIdentitySHA256.utf8.count == 64,
              historyPreservingTwoParentMergeObserved,
              mergeTreeEqualsReviewedHeadTree,
              exactDirectSuccessorOfAuthorizedBaseObserved,
              observedSourceBindings.count == 10,
              observedSourceBindings.map(\.path) == expectedSourcePaths,
              Set(observedSourceBindings.map(\.path)).count == 10,
              Set(observedSourceBindings.map(\.gitBlob)).count == 10,
              Set(observedSourceBindings.map(\.sha256)).count == 10,
              allObservedSourceHashesAreExactLowercaseHex,
              workflowID == 329_017_041,
              workflowName == "Prime active-root quarantine",
              runID == 31_472_165_002,
              runNumber == 51,
              runAttempt == 1,
              runEvent == predecessor.requiredExecutionEvent,
              runActor == runTriggeringActor,
              runCreatedAt == runStartedAt,
              runCompletedAt == runUpdatedAt,
              runStatus == "completed",
              runConclusion == "failure",
              activeRootJobID == 93_717_678_740,
              activeRootJobStatus == "completed",
              activeRootJobConclusion == "success",
              activeRootRunnerLabel == "macos-15",
              activeRootRunnerName == "GitHub Actions 1000001667",
              activeRootRunnerGroupName == "GitHub Actions",
              activeRootOrderedStepNames.count == 7,
              activeRootOrderedStepConclusions == Array(
                repeating: "success",
                count: activeRootOrderedStepNames.count),
              activeRootJobSucceeded,
              reviewedMainJobID == 93_718_282_081,
              reviewedMainJobStatus == "completed",
              reviewedMainJobConclusion == "failure",
              reviewedMainRunnerLabel == "macos-26",
              reviewedMainRunnerName == "GitHub Actions 1000001668",
              reviewedMainRunnerGroupName == "GitHub Actions",
              reviewedMainOrderedStepNames.count == 7,
              reviewedMainOrderedStepConclusions == [
                  "success", "success", "success", "success", "success",
                  "failure", "success",
              ],
              reviewedMainRanAfterActiveRootSuccess,
              liveStepName == reviewedMainOrderedStepNames[5],
              liveStepConclusion == "failure",
              activeJobRenderedLogByteCount == 314_687,
              activeJobRenderedLogLineCount == 1_707,
              reviewedMainJobRenderedLogByteCount == 14_369_398,
              reviewedMainJobRenderedLogLineCount == 77_706,
              renderedJobLogsBound,
              !rawGitHubLogArchiveBytesBound,
              !jobLogsRetainedInRepository,
              !durableJobLogPublicationEstablished,
              publishedWorkflowArtifactCount == 0,
              !checkpointArtifactUploaded,
              runnerVersion == "2.336.0",
              runnerProvisionerVersion == "20260707.563",
              runnerImage == "macos-26-arm64",
              architecture == "arm64",
              exactHostedRunnerImageRecorded,
              !exactPhysicalRunnerIdentityRecorded,
              metalDeviceName == "Apple Paravirtual device",
              metalDeviceObservedBeforeFailure,
              paravirtualMetalDeviceObserved,
              !physicalGPUIdentityRecorded,
              exactMLXRepository == predecessor.exactMLXRepository,
              exactMLXRevision == predecessor.exactMLXRevision,
              exactMLXCoreRevision == predecessor.exactMLXCoreRevision,
              exactMLXCRevision == predecessor.exactMLXCRevision,
              exactSwiftNumericsRevision
                == predecessor.exactSwiftNumericsRevision,
              metallibArtifactRelativePath
                == PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .artifactRelativePath,
              metallibByteCount == 6_292_716,
              freshMetallibBuildSucceeded,
              !metallibBytesRetainedInRepository,
              !metallibArtifactUploaded,
              !metallibArtifactProvenanceEstablished,
              predecessorMetalGateSucceeded,
              predecessorMaintainedRuntimeClosureSucceeded,
              predecessorTokenizerCompatibilitySucceeded,
              predecessorValidatedLogCount == 8,
              predecessorValidatedReceiptCount == 2,
              maintainedRuntimeReceiptAuthorityID
                == "ergentics_prime_native_decoder_maintained_runtime_compute_v1",
              maintainedRuntimeReceiptEvidenceID
                == "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
              maintainedRuntimeReceiptByteCount == 6_853,
              tokenizerReceiptAuthorityID
                == "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_v1",
              tokenizerReceiptEvidenceID
                == "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1",
              tokenizerReceiptByteCount == 7_182,
              exactAuthorizedRunnerTemporaryPathCountReclaimed == 24,
              authorizedRunnerTemporaryReclamationCompleted,
              exactOrderedFailureLines == [
                  "prime-native-decoder-checkpoint-v2-io-execution-probe: contract drift: artifact root changed identity during write",
                  "prime-native-decoder-checkpoint-v2-io: Release probe failed",
                  "Process completed with exit code 2.",
              ],
              probeProcessExitCode == 2,
              receiptBeginMarkerCount == 0,
              receiptChunkMarkerCount == 0,
              receiptEndMarkerCount == 0,
              !executionEvidenceValueConstructed,
              !canonicalReceiptConstructed,
              !canonicalReceiptEmitted,
              initializationSeed == predecessor.initializationSeed,
              callerSourceModelConstructionCountSourceInferred == 1,
              initialParameterMaterializationEvaluationCountSourceInferred
                == 1,
              initialParameterMaterializationEvaluationAPI
                == predecessor.initialParameterMaterializationEvaluationAPI,
              memoryCacheLimitSourceInferred == 0,
              memoryCacheClearInvocationCountSourceInferred == 1,
              publicCheckpointWriteInvocationCountSourceInferred == 1,
              publicCheckpointWriteCompletionCountSourceInferred == 1,
              publicCheckpointLoadInvocationCountSourceInferred == 0,
              publicCheckpointLoadCompletionCountSourceInferred == 0,
              sourceModelLexicalScopeEndedBeforeFailureSourceInferred,
              !sourceModelARCDeallocationObserved,
              !postWriteRootStableObjectIdentityGuardPassed,
              !publishedArtifactPathInspectionCompleted,
              !artifactRootIdentityBeforeWriteEmitted,
              !artifactRootIdentityAfterWriteEmitted,
              !artifactRootChangedFieldIdentifiedByRun,
              localDiagnosticRootLinkCountBeforeLeafAddition == 2,
              localDiagnosticRootLinkCountAfterLeafAddition == 3,
              !localDiagnosisIsFailedRunTelemetry,
              !parentReceiptVerificationCompleted,
              !parentArtifactUnlinkCompleted,
              !parentArtifactRootRmdirCompleted,
              !eventualRunnerVMCleanupObserved,
              predecessorAuthorityAttemptConsumed,
              predecessorAuthorityExhausted,
              !rerunObserved,
              !rerunAuthorized,
              !replacementExecutionAuthorityEstablished,
              externalBindingReturnSourceInferred,
              !externalBindingFieldsIndependentlyObserved,
              allCheckpointAdmissionTrainingAndProductCeilingsAreFalse,
              status
                == "ABSTAIN_seed42_public_write_return_source_inferred_postwrite_root_guard_failed_no_load_no_receipt_no_artifact_admission",
              orderedNextActions == [
                  "append_exact_failed_attempt_observation_and_remove_exhausted_live_command",
                  "repair_artifact_root_identity_semantics_without_reclassifying_the_failed_run",
                  "require_a_separate_successor_execution_authority_before_any_new_attempt",
              ]
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationError
                    .contractDrift
        }
    }

    private var allObservedSourceHashesAreExactLowercaseHex: Bool {
        let commitIDs = [
            observedRevision,
            reviewedPullRequestHeadRevision,
            observedTree,
            reviewedPullRequestHeadTree,
        ] + observedOrderedParentRevisions
            + observedSourceBindings.map(\.gitBlob)
        let sha256s = [
            observedEmbeddedSourceIdentitySHA256,
            activeJobRenderedLogSHA256,
            reviewedMainJobRenderedLogSHA256,
            metallibSHA256,
            maintainedRuntimeReceiptSHA256,
            tokenizerReceiptSHA256,
        ] + observedSourceBindings.map(\.sha256)
        return commitIDs.allSatisfy {
            $0.utf8.count == 40
                && $0.utf8.allSatisfy(
                    isPrimeNativeDecoderCheckpointV2FailureLowercaseHex)
        } && sha256s.allSatisfy {
            $0.utf8.count == 64
                && $0.utf8.allSatisfy(
                    isPrimeNativeDecoderCheckpointV2FailureLowercaseHex)
        }
    }

    private var allCheckpointAdmissionTrainingAndProductCeilingsAreFalse:
        Bool
    {
        !native300MModelAllocationIndependentlyObserved
            && externalBindingReturnSourceInferred
            && !externalBindingFieldsIndependentlyObserved
            && !native300MCheckpointWriteIndependentlyObserved
            && !native300MCheckpointLoadObserved
            && !checkpointIORoundTripObserved
            && !checkpointArtifactAvailabilityEstablished
            && !checkpointArtifactRetentionEstablished
            && !checkpointArtifactRetentionAuthorized
            && !checkpointArtifactUploadAuthorized
            && !checkpointArtifactProvenanceEstablished
            && !checkpointContainerHashIndependentlyObserved
            && !checkpointAdmissionGranted
            && !checkpointDurabilityObserved
            && !logicalParameterRoundTripObserved
            && !checkpointLoadedForwardObserved
            && !checkpointRoundTripBehaviorParityEstablished
            && !optimizerStateInclusionObservedByCheckpointAttempt
            && !rngStateInclusionObservedByCheckpointAttempt
            && !dataCursorInclusionObservedByCheckpointAttempt
            && !kvCacheStateInclusionObservedByCheckpointAttempt
            && !decoderForwardObservedByCheckpointAttempt
            && !decoderKVCacheUsedByCheckpointAttempt
            && !backwardInvokedByCheckpointAttempt
            && !lossObservedByCheckpointAttempt
            && !optimizerStepObservedByCheckpointAttempt
            && !generationInvokedByCheckpointAttempt
            && !trainingExecutionObserved
            && !trainingResumeEstablished
            && !modelQualityEstablished
            && !candidateAdmissionGranted
            && !trialAuthorized
            && !canaryReplacementAuthorized
            && !quantizationAuthorized
            && !productUseAuthorized
            && !publicationAuthorized
    }
}

private func isPrimeNativeDecoderCheckpointV2FailureLowercaseHex(
    _ byte: UInt8
) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
