// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderTinyCPUFailureSourceIdentityV1:
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

public struct PrimeNativeDecoderTinyCPUFailureRepositoryIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let pullRequestNumber: Int
    public let ref: String
    public let revision: String
    public let orderedParentRevisions: [String]
    public let tree: String
    public let reviewedHeadRevision: String
    public let reviewedHeadTree: String
    public let mergeCommitSignatureVerified: Bool
    public let mergeCommitSignatureReason: String
    public let mergedAt: String
    public let historyPreservingTwoParentMergeObserved: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
    public let exactMainRefStillMatchedAtAudit: Bool
    public let embeddedSourceIdentitySHA256: String
}

public struct PrimeNativeDecoderTinyCPUFailureRunIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let workflowID: Int
    public let workflowName: String
    public let workflowPath: String
    public let runID: Int
    public let runNumber: Int
    public let runAttempt: Int
    public let event: String
    public let headBranch: String
    public let headRevision: String
    public let actor: String
    public let triggeringActor: String
    public let url: String
    public let createdAt: String
    public let startedAt: String
    public let completedAt: String
    public let updatedAt: String
    public let status: String
    public let conclusion: String
    public let checkSuiteID: Int
    public let exactHeadPushRunCount: Int
    public let previousAttemptURLWasNull: Bool
    public let secondAttemptEndpointHTTPStatus: Int
    public let rerunCount: Int
    public let rerunObserved: Bool
    public let rerunAuthorized: Bool
}

public struct PrimeNativeDecoderTinyCPUFailureJobStepV1:
    Codable,
    Equatable,
    Sendable
{
    public let number: Int
    public let name: String
    public let conclusion: String
}

public struct PrimeNativeDecoderTinyCPUFailureJobObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let id: Int
    public let name: String
    public let url: String
    public let startedAt: String
    public let completedAt: String
    public let status: String
    public let conclusion: String
    public let runnerLabel: String
    public let runnerName: String
    public let runnerGroupName: String
    public let orderedSteps: [PrimeNativeDecoderTinyCPUFailureJobStepV1]
    public let checkAnnotationCount: Int
    public let checkAnnotationPath: String
    public let checkAnnotationStartLine: Int
    public let checkAnnotationEndLine: Int
    public let checkAnnotationLevel: String
    public let checkAnnotationMessage: String
}

public struct PrimeNativeDecoderTinyCPUFailureRunnerToolchainV1:
    Codable,
    Equatable,
    Sendable
{
    public let runnerVersion: String
    public let runnerProvisionerVersion: String
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
}

public struct PrimeNativeDecoderTinyCPUFailureRawLogIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let scope: String
    public let byteCount: Int
    public let sha256: String
    public let utf8BOMHex: String
    public let startsWithUTF8BOM: Bool
    public let usesLFOnly: Bool
    public let endsWithLF: Bool
    public let lfByteCount: Int
    public let splitLineCountExcludingTerminalEmpty: Int
    public let newlineDelimitedComponentCountIncludingTerminalEmpty: Int
    public let lineCountSemantics: String
    public let firstTimestamp: String
    public let lastTimestamp: String
}

public struct PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
}

public struct PrimeNativeDecoderTinyCPUFailureLogArchiveIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let byteCount: Int
    public let sha256: String
    public let memberCount: Int
    public let uncompressedByteCount: Int
    public let repeatedDownloadsWereByteIdentical: Bool
    public let memberTimestampsAreDOSZero: Bool
    public let skippedReviewedStepMemberAbsent: Bool
    public let focusedStepMemberFirstTimestamp: String
    public let focusedStepMemberDiagnosticTimestamp: String
    public let focusedStepMemberExitTimestamp: String
    public let members:
        [PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1]
}

public struct PrimeNativeDecoderTinyCPUFailureTestGroupV1:
    Codable,
    Equatable,
    Sendable
{
    public let name: String
    public let completedTestCount: Int
    public let failureCount: Int
    public let skipCount: Int
}

public struct PrimeNativeDecoderTinyCPUFailureFocusedExecutionV1:
    Codable,
    Equatable,
    Sendable
{
    public let completedGroups: [PrimeNativeDecoderTinyCPUFailureTestGroupV1]
    public let completedTestCountBeforeStage2Termination: Int
    public let completedFailureCountBeforeStage2Termination: Int
    public let completedSkipCountBeforeStage2Termination: Int
    public let stage2TestClass: String
    public let stage2TestMethod: String
    public let stage2TestInvocationCount: Int
    public let stage2TestStartCount: Int
    public let stage2CompletedPassCount: Int
    public let stage2CompletedFailureCount: Int
    public let stage2CompletedSkipCount: Int
    public let swiftTestingAuxiliaryTestCount: Int
    public let swiftTestingAuxiliarySuiteCount: Int
    public let swiftTestingAuxiliaryOutputIsStage2CompletionEvidence: Bool
    public let hostedRequiredStage2TestCount: Int
    public let hostedRequiredStage2FailureCount: Int
    public let hostedRequiredStage2SkipCount: Int
    public let hostedStage2RequirementSatisfied: Bool
    public let retainedLiveSequence: [String]
    public let retainedLiveSequenceInvocationCounts: [Int]
    public let runtimeReceiptCount: Int
    public let tokenizerReceiptCount: Int
    public let retiredSeed42CheckpointCommandCount: Int
    public let retiredSeed43CheckpointCommandCount: Int
    public let checkpointReceiptMarkerCount: Int
    public let checkpointFilenameCount: Int
    public let oldOneShotSuccessMarkerCount: Int
    public let artifactUploadStepCount: Int
}

public struct PrimeNativeDecoderTinyCPUFailureBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let failedJobStepNumber: Int
    public let failedJobStepName: String
    public let skippedLiveStepNumber: Int
    public let skippedLiveStepName: String
    public let derivedRunnerSourcePath: String
    public let derivedRunnerSourcePathFirstObservedAt: String
    public let linkCompletedAt: String
    public let buildCompletedAt: String
    public let buildCompletionDurationMilliseconds: Int
    public let methodAggregateLogStartTimestamp: String
    public let diagnosticFocusedArchiveMemberTimestamp: String
    public let diagnosticAggregateLogTimestamp: String
    public let exactDiagnostic: String
    public let libraryNotFoundOccurrenceCount: Int
    public let failureSourceRepository: String
    public let failureSourceRevision: String
    public let failureSourcePath: String
    public let failureSourceLine: Int
    public let focusedArchiveMemberExitTimestamp: String
    public let aggregateLogExitTimestamp: String
    public let processExitCode: Int
    public let processExitMessage: String
    public let aggregateLogOrphanCleanupTimestamp: String
    public let failureClassification: String
    public let hostedBootstrapFailureObserved: Bool
    public let CPUTrainEvaluateSemanticFailureObserved: Bool
    public let CPUTrainEvaluateMechanicsPassObserved: Bool
}

public struct PrimeNativeDecoderTinyCPUFailureControlFlowV1:
    Codable,
    Equatable,
    Sendable
{
    public let inferenceBasis: String
    public let orderedPreMLXReturnedPhases: [String]
    public let configurationAssertionsReturnedSourceInferred: Bool
    public let batchRejectionCallCountSourceInferred: Int
    public let gradientClipCallCountSourceInferred: Int
    public let validBatchConstructionCountSourceInferred: Int
    public let selectedTargetCountAssertionsReturnedSourceInferred: Bool
    public let coreGraphicsDiscoveryReturnedSourceInferred: Bool
    public let metalDeviceEnumerationReturnedSourceInferred: Bool
    public let metalDefaultDeviceDiscoveryReturnedSourceInferred: Bool
    public let metalCapabilityGuardAdmittedHostSourceInferred: Bool
    public let localNoMetalDeviceSkipPathTaken: Bool
    public let discoveryPerformedTensorComputation: Bool
    public let deviceWithDefaultDeviceCallExpressionReachedSourceInferred: Bool
    public let CPUDeviceArgumentEvaluationReachedSourceInferred: Bool
    public let pinnedSchedulerInitializesGPUDefaultStreamBeforeCPUStream: Bool
    public let defaultMetallibDiscoveryAttemptedSourceInferred: Bool
    public let stage2WorkflowMetallibBuildCommandCount: Int
    public let stage2WorkflowMetallibStageCommandCount: Int
    public let loadableDefaultMetallibDiscovered: Bool
    public let withDefaultDeviceClosureEntryCount: Int
    public let requireCPUDefaultInvocationCount: Int
    public let CPUDeviceEstablished: Bool
    public let CPUDefaultStreamEstablished: Bool
    public let trainerConstructionCount: Int
    public let decoderModelAllocationCount: Int
    public let validationSnapshotCount: Int
    public let trainInvocationCount: Int
    public let completedOptimizerStepCount: Int
    public let evaluationInvocationCount: Int
    public let evaluationCompletionCount: Int
    public let twoTrainerEqualityAssertionCount: Int
    public let initialSnapshotEqualityAssertionCount: Int
    public let firstStepResultEqualityAssertionCount: Int
    public let secondStepResultEqualityAssertionCount: Int
    public let evaluationResultEqualityAssertionCount: Int
    public let evaluationSharedPrefixSelectedLossEqualityAssertionCount: Int
    public let globalMeanLossAssertionCount: Int
    public let thirdStepRejectionGuardInvocationCount: Int
    public let parameterDigestObservationCount: Int
    public let momentDigestObservationCount: Int
    public let gradientObservationCount: Int
    public let observedRuntimeDigestValueCount: Int
    public let observedFloat32BitPatternValueCount: Int
    public let MLXTensorComputationObserved: Bool
    public let metalTensorSubmissionObserved: Bool
    public let failurePrecedesCPUMechanics: Bool
}

public struct PrimeNativeDecoderTinyCPUFailureArtifactBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let actionsArtifactsEndpoint: String
    public let actionsArtifactsTotalCount: Int
    public let actionsArtifactsArrayExactlyEmpty: Bool
    public let publishedWorkflowArtifactCount: Int
    public let artifactUploadStepCount: Int
    public let runLogArchiveObserved: Bool
    public let runLogArchiveIsActionsArtifact: Bool
    public let jobLogsRetainedInRepository: Bool
    public let durableJobLogPublicationEstablished: Bool
    public let runtimeReceiptEmitted: Bool
    public let tokenizerReceiptEmitted: Bool
    public let checkpointReceiptEmitted: Bool
    public let checkpointArtifactCreated: Bool
    public let checkpointArtifactUploaded: Bool
    public let checkpointArtifactRetained: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
}

public struct PrimeNativeDecoderTinyCPUFailureAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let predecessorAuthorityRemainsFrozen: Bool
    public let predecessorAuthorityValidatedForConsumption: Bool
    public let predecessorExecutionAttemptConsumed: Bool
    public let predecessorExecutionAuthorityExhausted: Bool
    public let rerunObserved: Bool
    public let rerunAuthorized: Bool
    public let failedAttemptRecoverable: Bool
    public let replacementExecutionAuthorityEstablished: Bool
    public let implementationSourceRemainsFrozen: Bool
    public let validationManifestRemainsFrozen: Bool
    public let validationLockRemainsFrozen: Bool
    public let failedValidationSourceRemainsFrozen: Bool
    public let failedWorkflowInvocationRemainsLive: Bool
    public let bootstrapRepairRequiredBeforeAnotherAttempt: Bool
    public let bootstrapRepairAuthorizedByThisObservation: Bool
    public let tinyCPUTrainEvaluateExecutionEstablished: Bool
    public let tinyCPUCPUDeviceEstablished: Bool
    public let tinyCPUTrainerInitializationEstablished: Bool
    public let tinyCPUModelAllocationEstablished: Bool
    public let tinyCPUOptimizerStepEstablished: Bool
    public let tinyCPUEvaluationEstablished: Bool
    public let explicitRNGStateEstablished: Bool
    public let deterministicDataCursorEstablished: Bool
    public let interruptionBoundaryEstablished: Bool
    public let resumeExecutionEstablished: Bool
    public let checkpointReadEstablished: Bool
    public let checkpointWriteEstablished: Bool
    public let checkpointRoundTripEstablished: Bool
    public let checkpointArtifactAvailabilityEstablished: Bool
    public let checkpointArtifactRetentionEstablished: Bool
    public let checkpointArtifactUploadAuthorized: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let metalTensorExecutionEstablished: Bool
    public let metalDeterminismEstablished: Bool
    public let native300MAllocationEstablished: Bool
    public let native300MTrainingEstablished: Bool
    public let trajectoryExactResumeEstablished: Bool
    public let trainingResumeEstablished: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let stage3Blocked: Bool
}

/// Append-only terminal observation of the exhausted first Stage-2 attempt.
///
/// The exact source and sealed logs establish that the pure configuration,
/// batch, clipping, CoreGraphics, and Metal-discovery prefix returned. The
/// subsequent pinned-MLX CPU-device argument evaluation attempted to create
/// the scheduler's GPU default stream and terminated because no staged
/// `default.metallib` was discoverable. The CPU-scoped closure never began:
/// no CPU default, trainer, decoder, model, step, evaluation, or third-step
/// guard was observed.
///
/// The predecessor's sole execution opportunity is consumed and exhausted.
/// This observation is not a retry, repair authority, checkpoint or artifact
/// receipt, resume claim, mechanics pass, semantic mechanics failure, or any
/// downstream admission.
public struct
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let repositoryIdentity:
        PrimeNativeDecoderTinyCPUFailureRepositoryIdentityV1
    public let observedSourceBindings:
        [PrimeNativeDecoderTinyCPUFailureSourceIdentityV1]
    public let runIdentity: PrimeNativeDecoderTinyCPUFailureRunIdentityV1
    public let activeRootJob:
        PrimeNativeDecoderTinyCPUFailureJobObservationV1
    public let reviewedMainJob:
        PrimeNativeDecoderTinyCPUFailureJobObservationV1
    public let runnerToolchain:
        PrimeNativeDecoderTinyCPUFailureRunnerToolchainV1
    public let activeRootRawLog:
        PrimeNativeDecoderTinyCPUFailureRawLogIdentityV1
    public let reviewedMainRawLog:
        PrimeNativeDecoderTinyCPUFailureRawLogIdentityV1
    public let rawLogArchive:
        PrimeNativeDecoderTinyCPUFailureLogArchiveIdentityV1
    public let focusedExecution:
        PrimeNativeDecoderTinyCPUFailureFocusedExecutionV1
    public let failureBoundary: PrimeNativeDecoderTinyCPUFailureBoundaryV1
    public let controlFlow: PrimeNativeDecoderTinyCPUFailureControlFlowV1
    public let artifactBoundary:
        PrimeNativeDecoderTinyCPUFailureArtifactBoundaryV1
    public let authorityCeiling:
        PrimeNativeDecoderTinyCPUFailureAuthorityCeilingV1
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_execution_failure_observation_v1",
        observationKind:
            "exhausted_exact_main_stage2_hosted_metallib_bootstrap_failure",
        predecessorAuthorityID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_authority_v1",
        repositoryIdentity:
            PrimeNativeDecoderTinyCPUFailureRepositoryIdentityV1(
                repository: "Ergentics/ergentics-prime",
                pullRequestNumber: 83,
                ref: "refs/heads/main",
                revision:
                    "8d544c34a09a770198b50126f50adb766f234a8f",
                orderedParentRevisions: [
                    "605d47dde85715f356e4d6e11beb3a3262cc4e7e",
                    "f13322ebc368c639a0f04b7570af093cc57ec22b",
                ],
                tree:
                    "c5b776a9ad25375ef681de3041ef6259ac84dc4a",
                reviewedHeadRevision:
                    "f13322ebc368c639a0f04b7570af093cc57ec22b",
                reviewedHeadTree:
                    "c5b776a9ad25375ef681de3041ef6259ac84dc4a",
                mergeCommitSignatureVerified: true,
                mergeCommitSignatureReason: "valid",
                mergedAt: "2026-08-11T19:00:08Z",
                historyPreservingTwoParentMergeObserved: true,
                mergeTreeEqualsReviewedHeadTree: true,
                exactMainRefStillMatchedAtAudit: true,
                embeddedSourceIdentitySHA256:
                    "3d5316d3e3852eb205fee00ebd595a36f5cada16f404a1c3d05f2546b2e67f7e"),
        observedSourceBindings: [
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "b36bb8584b48720b3e2a93549d165732139a933e",
                byteCount: 39_979,
                sha256:
                    "a0c53285aeb1d7bcc9c174e09dfd8420579035a2a09520be76af423d79dd0ea0",
                claimScope: "exact_failed_workflow_topology_and_commands"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "ff1068f3eb6d5aef0e4dfc53a5db09603044af3c",
                byteCount: 268_250,
                sha256:
                    "ac74ab58c884f7dfe2ebc9e30e1dfe757738be484d1c0cffc0d7362ce3697c84",
                claimScope: "exact_failed_active_root_gate"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path: "Package.swift",
                gitMode: "100644",
                gitBlob: "765d3c88139bc1f74af16b77b2f3b06d33f66f75",
                byteCount: 32_795,
                sha256:
                    "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2",
                claimScope: "exact_root_target_and_dependency_graph"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path: "Package.resolved",
                gitMode: "100644",
                gitBlob: "14d804bb4291720477240c27e24de6fbdc876b3b",
                byteCount: 645,
                sha256:
                    "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375",
                claimScope: "exact_root_dependency_resolution"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitMode: "100644",
                gitBlob: "afc0182aeb4e9bd15fb91c45029ab10a77f97805",
                byteCount: 546,
                sha256:
                    "5cd23ce3656badd6d309797f257aeeec7dc66d0807df7f2845b75f8a1699c079",
                claimScope: "exact_failed_run_embedded_source_identity"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthority.swift",
                gitMode: "100644",
                gitBlob: "c24af7fab204b8139e4d6f919e9c04ade48bfe6b",
                byteCount: 98_327,
                sha256:
                    "ed0f66770a3cf772af264c5bd7f592a433ee48574d80f98664bc8421c32db5e1",
                claimScope: "consumed_predecessor_stage2_authority"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path:
                    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                gitMode: "100644",
                gitBlob: "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f",
                byteCount: 39_598,
                sha256:
                    "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
                claimScope: "exact_stage2_decoder_training_seam"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path:
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                gitMode: "100644",
                gitBlob: "e160cc829f8498abafd100f3f0444742058f0479",
                byteCount: 37_829,
                sha256:
                    "5e6810a6bd5a9dc0bbe6d6369cec3db6dc84068dc9b415413aafb03f311211dc",
                claimScope: "exact_stage2_training_implementation"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path:
                    "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityTests.swift",
                gitMode: "100644",
                gitBlob: "3ea30af2bbd8b4e77f69a55e910a04b9b82b34dc",
                byteCount: 37_484,
                sha256:
                    "1aa3485ed39cf21a3a6fb2417b1d70903c9d2e74e0faa404696e70c8bcfb1f7a",
                claimScope: "exact_pure_stage2_authority_contract"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path:
                    "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                gitMode: "100644",
                gitBlob: "9f05e5a17426f00adf9dad7b55d84057122e98f9",
                byteCount: 1_054,
                sha256:
                    "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45",
                claimScope: "exact_failed_isolated_validation_manifest"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path:
                    "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                gitMode: "100644",
                gitBlob: "8bf05edf1ea8789e7683e72fe756d79aaaa61320",
                byteCount: 645,
                sha256:
                    "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225",
                claimScope: "exact_failed_isolated_validation_resolution"),
            PrimeNativeDecoderTinyCPUFailureSourceIdentityV1(
                path:
                    "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
                gitMode: "100644",
                gitBlob: "61e86200c508526ae2ab66e359d771841f7208db",
                byteCount: 30_214,
                sha256:
                    "29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96",
                claimScope:
                    "exact_failed_method_and_source_order_control_flow"),
        ],
        runIdentity: PrimeNativeDecoderTinyCPUFailureRunIdentityV1(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_525_634_838,
            runNumber: 63,
            runAttempt: 1,
            event: "push",
            headBranch: "main",
            headRevision: "8d544c34a09a770198b50126f50adb766f234a8f",
            actor: "psyop-archivist",
            triggeringActor: "psyop-archivist",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31525634838",
            createdAt: "2026-08-11T19:00:12Z",
            startedAt: "2026-08-11T19:00:12Z",
            completedAt: "2026-08-11T19:24:50Z",
            updatedAt: "2026-08-11T19:24:50Z",
            status: "completed",
            conclusion: "failure",
            checkSuiteID: 85_517_285_576,
            exactHeadPushRunCount: 1,
            previousAttemptURLWasNull: true,
            secondAttemptEndpointHTTPStatus: 404,
            rerunCount: 0,
            rerunObserved: false,
            rerunAuthorized: false),
        activeRootJob: PrimeNativeDecoderTinyCPUFailureJobObservationV1(
            id: 93_893_140_174,
            name: "First-party MLX / active-root quarantine",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31525634838/job/93893140174",
            startedAt: "2026-08-11T19:00:15Z",
            completedAt: "2026-08-11T19:02:52Z",
            status: "completed",
            conclusion: "success",
            runnerLabel: "macos-15",
            runnerName: "GitHub Actions 1000001685",
            runnerGroupName: "GitHub Actions",
            orderedSteps: [
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 1,
                    name: "Set up job",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 2,
                    name: "Check out the exact Prime revision",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 3,
                    name: "Validate active metadata and preserved history",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 4,
                    name: "Parse the changed Swift contracts without dependencies",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 5,
                    name: "Validate isolated Latin capture and observation contracts",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 6,
                    name: "Record the authority ceiling",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 7,
                    name: "Complete job",
                    conclusion: "success"),
            ],
            checkAnnotationCount: 0,
            checkAnnotationPath: "",
            checkAnnotationStartLine: 0,
            checkAnnotationEndLine: 0,
            checkAnnotationLevel: "",
            checkAnnotationMessage: ""),
        reviewedMainJob: PrimeNativeDecoderTinyCPUFailureJobObservationV1(
            id: 93_893_902_353,
            name: "Reviewed main / focused source contracts",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31525634838/job/93893902353",
            startedAt: "2026-08-11T19:02:54Z",
            completedAt: "2026-08-11T19:24:49Z",
            status: "completed",
            conclusion: "failure",
            runnerLabel: "macos-26",
            runnerName: "GitHub Actions 1000001686",
            runnerGroupName: "GitHub Actions",
            orderedSteps: [
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 1,
                    name: "Set up job",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 2,
                    name: "Record the hosted Apple toolchain",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 3,
                    name: "Check out reviewed main exactly",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 4,
                    name:
                        "Fetch the exact private dependency without evaluating Prime",
                    conclusion: "success"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 5,
                    name:
                        "Compile and run the focused contracts without a credential",
                    conclusion: "failure"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 6,
                    name: "Run the Prime-owned decoder on live Metal",
                    conclusion: "skipped"),
                PrimeNativeDecoderTinyCPUFailureJobStepV1(
                    number: 7,
                    name: "Complete job",
                    conclusion: "success"),
            ],
            checkAnnotationCount: 1,
            checkAnnotationPath: ".github",
            checkAnnotationStartLine: 3_687,
            checkAnnotationEndLine: 3_687,
            checkAnnotationLevel: "failure",
            checkAnnotationMessage: "Process completed with exit code 1."),
        runnerToolchain: PrimeNativeDecoderTinyCPUFailureRunnerToolchainV1(
            runnerVersion: "2.336.0",
            runnerProvisionerVersion: "20260707.563",
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
            swiftVersion: "6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)",
            swiftTarget: "arm64-apple-macosx26.0",
            macOSSDKVersion: "26.5",
            swiftDriverVersion: "1.148.6",
            exactHostedRunnerImagesRecorded: true,
            exactPhysicalRunnerIdentityRecorded: false),
        activeRootRawLog: PrimeNativeDecoderTinyCPUFailureRawLogIdentityV1(
            scope: "active_root_aggregate_raw_job_log",
            byteCount: 230_005,
            sha256:
                "e1cc35d3a637432d22cbbb199b0227f1401d675f43231214081e00e30be11c65",
            utf8BOMHex: "efbbbf",
            startsWithUTF8BOM: true,
            usesLFOnly: true,
            endsWithLF: true,
            lfByteCount: 1_733,
            splitLineCountExcludingTerminalEmpty: 1_733,
            newlineDelimitedComponentCountIncludingTerminalEmpty: 1_734,
            lineCountSemantics:
                "lf_byte_count_and_split_lines_exclude_the_terminal_empty_component",
            firstTimestamp: "2026-08-11T19:00:15.7720100Z",
            lastTimestamp: "2026-08-11T19:02:47.1671810Z"),
        reviewedMainRawLog:
            PrimeNativeDecoderTinyCPUFailureRawLogIdentityV1(
                scope: "reviewed_main_aggregate_raw_job_log",
                byteCount: 377_065,
                sha256:
                    "820af763e807444722af2390e29efa782ee12841ffbeeebc1591b751908527d4",
                utf8BOMHex: "efbbbf",
                startsWithUTF8BOM: true,
                usesLFOnly: true,
                endsWithLF: true,
                lfByteCount: 3_829,
                splitLineCountExcludingTerminalEmpty: 3_829,
                newlineDelimitedComponentCountIncludingTerminalEmpty: 3_830,
                lineCountSemantics:
                    "lf_byte_count_and_split_lines_exclude_the_terminal_empty_component",
                firstTimestamp: "2026-08-11T19:02:55.1827780Z",
                lastTimestamp: "2026-08-11T19:24:39.4614180Z"),
        rawLogArchive: PrimeNativeDecoderTinyCPUFailureLogArchiveIdentityV1(
            byteCount: 168_501,
            sha256:
                "431d7afb7ab70ce0b60b3b04da0969317a5734d562c2a461a2be7c5196b015ef",
            memberCount: 17,
            uncompressedByteCount: 1_215_574,
            repeatedDownloadsWereByteIdentical: true,
            memberTimestampsAreDOSZero: true,
            skippedReviewedStepMemberAbsent: true,
            focusedStepMemberFirstTimestamp:
                "2026-08-11T19:03:11.7867760Z",
            focusedStepMemberDiagnosticTimestamp:
                "2026-08-11T19:24:39.4258430Z",
            focusedStepMemberExitTimestamp:
                "2026-08-11T19:24:39.4416120Z",
            members: [
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "0_Reviewed main _ focused source contracts.txt",
                    byteCount: 377_065,
                    lfByteCount: 3_829,
                    sha256:
                        "820af763e807444722af2390e29efa782ee12841ffbeeebc1591b751908527d4"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/system.txt",
                    byteCount: 800,
                    lfByteCount: 8,
                    sha256:
                        "745d1727476091a20acc4c1669070ce7ca5b1bd17c43d959dff1c07a1e247e13"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/1_Set up job.txt",
                    byteCount: 1_680,
                    lfByteCount: 28,
                    sha256:
                        "1c8355c0b33cca6587376b36c55297b69d71f19837addc6456626527db7794ec"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/2_Record the hosted Apple toolchain.txt",
                    byteCount: 1_279,
                    lfByteCount: 22,
                    sha256:
                        "9d2637ab3385c9c8a784aa26dda2da80f2478b55a717ce3112db05c54bb0766e"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/3_Check out reviewed main exactly.txt",
                    byteCount: 3_139,
                    lfByteCount: 37,
                    sha256:
                        "d97398623b3eceb0734e5061c65767759f7cc1d35572fef1e5463059ec5465af"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/4_Fetch the exact private dependency without evaluating Prime.txt",
                    byteCount: 4_893,
                    lfByteCount: 54,
                    sha256:
                        "8add9d7789712deb2d2dc3f467784c5697557a06e1d82a349377e7069638d801"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/5_Compile and run the focused contracts without a credential.txt",
                    byteCount: 366_028,
                    lfByteCount: 3_687,
                    sha256:
                        "c19abc615ccff4cfced988c1b9b52956371d71c0116d26375ec94078586e2971"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/7_Complete job.txt",
                    byteCount: 61,
                    lfByteCount: 1,
                    sha256:
                        "e3d81478801a6283a697ca7e1b96c6bcaadcce49aae8e30d4f696c50416fe200"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path: "1_First-party MLX _ active-root quarantine.txt",
                    byteCount: 230_005,
                    lfByteCount: 1_733,
                    sha256:
                        "e1cc35d3a637432d22cbbb199b0227f1401d675f43231214081e00e30be11c65"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/system.txt",
                    byteCount: 601,
                    lfByteCount: 7,
                    sha256:
                        "ca9f502be2297a628dc67f0ff54cb28b383f837811db0dcd04c1fb5fe4857339"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/1_Set up job.txt",
                    byteCount: 1_681,
                    lfByteCount: 28,
                    sha256:
                        "005d44b653a065ef9a3874ed7c48ebdfd609577f3c0b3c184222af57550236e7"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/2_Check out the exact Prime revision.txt",
                    byteCount: 3_047,
                    lfByteCount: 36,
                    sha256:
                        "048d0caadca5d6a865c54576cf6de8e2cba41784672c43e2a790bee0e0c6413e"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/3_Validate active metadata and preserved history.txt",
                    byteCount: 706,
                    lfByteCount: 8,
                    sha256:
                        "b5141573ff54a1d4cbbefa6e6bf2fab9ddd51f8e0dfb95e891355ba3ae444ade"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/4_Parse the changed Swift contracts without dependencies.txt",
                    byteCount: 12_157,
                    lfByteCount: 91,
                    sha256:
                        "f9c3dd599d573ccc18e30e6cbaf63f16ac672ebdef6f0d1c1da5f64daeb41ed5"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/5_Validate isolated Latin capture and observation contracts.txt",
                    byteCount: 196_153,
                    lfByteCount: 1_520,
                    sha256:
                        "3b8265faa90eb9fbae1331baeb99c49f017c369dd0caa0a3bb176a477e723390"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/6_Record the authority ceiling.txt",
                    byteCount: 16_218,
                    lfByteCount: 49,
                    sha256:
                        "70b32fcce8b761b4c2166c390ef3893287cacc59681a3ed945629bf17086db17"),
                PrimeNativeDecoderTinyCPUFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/7_Complete job.txt",
                    byteCount: 61,
                    lfByteCount: 1,
                    sha256:
                        "4e75f646e9c4631679613b5575a2d522e51e9908262a28a892bfccb087e46e57"),
            ]),
        focusedExecution: PrimeNativeDecoderTinyCPUFailureFocusedExecutionV1(
            completedGroups: [
                PrimeNativeDecoderTinyCPUFailureTestGroupV1(
                    name: "root_focused_contracts",
                    completedTestCount: 34,
                    failureCount: 0,
                    skipCount: 0),
                PrimeNativeDecoderTinyCPUFailureTestGroupV1(
                    name: "checkpoint_compatibility_v2",
                    completedTestCount: 1,
                    failureCount: 0,
                    skipCount: 0),
                PrimeNativeDecoderTinyCPUFailureTestGroupV1(
                    name: "checkpoint_v2_io",
                    completedTestCount: 1,
                    failureCount: 0,
                    skipCount: 0),
                PrimeNativeDecoderTinyCPUFailureTestGroupV1(
                    name: "checkpoint_v2_io_execution_pure",
                    completedTestCount: 2,
                    failureCount: 0,
                    skipCount: 0),
                PrimeNativeDecoderTinyCPUFailureTestGroupV1(
                    name: "checkpoint_v2_io_root_identity_repair_pure",
                    completedTestCount: 2,
                    failureCount: 0,
                    skipCount: 0),
            ],
            completedTestCountBeforeStage2Termination: 40,
            completedFailureCountBeforeStage2Termination: 0,
            completedSkipCountBeforeStage2Termination: 0,
            stage2TestClass: "PrimeNativeDecoderTrainingTests",
            stage2TestMethod:
                "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
            stage2TestInvocationCount: 1,
            stage2TestStartCount: 1,
            stage2CompletedPassCount: 0,
            stage2CompletedFailureCount: 0,
            stage2CompletedSkipCount: 0,
            swiftTestingAuxiliaryTestCount: 0,
            swiftTestingAuxiliarySuiteCount: 0,
            swiftTestingAuxiliaryOutputIsStage2CompletionEvidence: false,
            hostedRequiredStage2TestCount: 1,
            hostedRequiredStage2FailureCount: 0,
            hostedRequiredStage2SkipCount: 0,
            hostedStage2RequirementSatisfied: false,
            retainedLiveSequence: [
                "metal_44_of_44",
                "maintained_runtime_receipt",
                "tokenizer_receipt",
            ],
            retainedLiveSequenceInvocationCounts: [0, 0, 0],
            runtimeReceiptCount: 0,
            tokenizerReceiptCount: 0,
            retiredSeed42CheckpointCommandCount: 0,
            retiredSeed43CheckpointCommandCount: 0,
            checkpointReceiptMarkerCount: 0,
            checkpointFilenameCount: 0,
            oldOneShotSuccessMarkerCount: 0,
            artifactUploadStepCount: 0),
        failureBoundary: PrimeNativeDecoderTinyCPUFailureBoundaryV1(
            failedJobStepNumber: 5,
            failedJobStepName:
                "Compile and run the focused contracts without a credential",
            skippedLiveStepNumber: 6,
            skippedLiveStepName: "Run the Prime-owned decoder on live Metal",
            derivedRunnerSourcePath:
                "/Users/runner/work/_temp/prime-native-decoder-training-build/arm64-apple-macosx/debug/PrimeNativeDecoderTrainingValidationPackageTests.derived/runner.swift",
            derivedRunnerSourcePathFirstObservedAt:
                "2026-08-11T19:21:56.2597510Z",
            linkCompletedAt: "2026-08-11T19:24:38.3921050Z",
            buildCompletedAt: "2026-08-11T19:24:38.4015710Z",
            buildCompletionDurationMilliseconds: 174_790,
            methodAggregateLogStartTimestamp:
                "2026-08-11T19:24:39.4257140Z",
            diagnosticFocusedArchiveMemberTimestamp:
                "2026-08-11T19:24:39.4258430Z",
            diagnosticAggregateLogTimestamp:
                "2026-08-11T19:24:39.4258460Z",
            exactDiagnostic:
                "MLX error: Failed to load the default metallib. library not found library not found library not found library not found  at /Users/runner/work/_temp/prime-native-decoder-training-build/checkouts/ergentics-mlx-swift/Source/Cmlx/mlx-c/mlx/c/stream.cpp:106",
            libraryNotFoundOccurrenceCount: 4,
            failureSourceRepository: "ml-explore/mlx-c",
            failureSourceRevision:
                "0726ca922fc902c4c61ef9c27d94132be418e945",
            failureSourcePath: "mlx/c/stream.cpp",
            failureSourceLine: 106,
            focusedArchiveMemberExitTimestamp:
                "2026-08-11T19:24:39.4416120Z",
            aggregateLogExitTimestamp:
                "2026-08-11T19:24:39.4416130Z",
            processExitCode: 1,
            processExitMessage: "Process completed with exit code 1.",
            aggregateLogOrphanCleanupTimestamp:
                "2026-08-11T19:24:39.4614180Z",
            failureClassification:
                "pinned_mlx_default_metallib_bootstrap_failure_before_cpu_mechanics",
            hostedBootstrapFailureObserved: true,
            CPUTrainEvaluateSemanticFailureObserved: false,
            CPUTrainEvaluateMechanicsPassObserved: false),
        controlFlow: PrimeNativeDecoderTinyCPUFailureControlFlowV1(
            inferenceBasis:
                "exact_frozen_source_order_plus_terminal_aggregate_and_archive_member_logs",
            orderedPreMLXReturnedPhases: [
                "frozen_configuration_assertions",
                "seventeen_batch_rejection_contracts",
                "seven_gradient_clip_boundary_contracts",
                "valid_prefix_zero_batch_construction",
                "first_training_batch_construction",
                "second_training_batch_construction",
                "evaluation_batch_construction",
                "selected_target_count_assertions",
                "core_graphics_rgb_color_space_discovery",
                "metal_device_enumeration",
                "metal_default_device_discovery",
                "metal_capability_guard_admitted_host",
            ],
            configurationAssertionsReturnedSourceInferred: true,
            batchRejectionCallCountSourceInferred: 17,
            gradientClipCallCountSourceInferred: 7,
            validBatchConstructionCountSourceInferred: 4,
            selectedTargetCountAssertionsReturnedSourceInferred: true,
            coreGraphicsDiscoveryReturnedSourceInferred: true,
            metalDeviceEnumerationReturnedSourceInferred: true,
            metalDefaultDeviceDiscoveryReturnedSourceInferred: true,
            metalCapabilityGuardAdmittedHostSourceInferred: true,
            localNoMetalDeviceSkipPathTaken: false,
            discoveryPerformedTensorComputation: false,
            deviceWithDefaultDeviceCallExpressionReachedSourceInferred: true,
            CPUDeviceArgumentEvaluationReachedSourceInferred: true,
            pinnedSchedulerInitializesGPUDefaultStreamBeforeCPUStream: true,
            defaultMetallibDiscoveryAttemptedSourceInferred: true,
            stage2WorkflowMetallibBuildCommandCount: 0,
            stage2WorkflowMetallibStageCommandCount: 0,
            loadableDefaultMetallibDiscovered: false,
            withDefaultDeviceClosureEntryCount: 0,
            requireCPUDefaultInvocationCount: 0,
            CPUDeviceEstablished: false,
            CPUDefaultStreamEstablished: false,
            trainerConstructionCount: 0,
            decoderModelAllocationCount: 0,
            validationSnapshotCount: 0,
            trainInvocationCount: 0,
            completedOptimizerStepCount: 0,
            evaluationInvocationCount: 0,
            evaluationCompletionCount: 0,
            twoTrainerEqualityAssertionCount: 0,
            initialSnapshotEqualityAssertionCount: 0,
            firstStepResultEqualityAssertionCount: 0,
            secondStepResultEqualityAssertionCount: 0,
            evaluationResultEqualityAssertionCount: 0,
            evaluationSharedPrefixSelectedLossEqualityAssertionCount: 0,
            globalMeanLossAssertionCount: 0,
            thirdStepRejectionGuardInvocationCount: 0,
            parameterDigestObservationCount: 0,
            momentDigestObservationCount: 0,
            gradientObservationCount: 0,
            observedRuntimeDigestValueCount: 0,
            observedFloat32BitPatternValueCount: 0,
            MLXTensorComputationObserved: false,
            metalTensorSubmissionObserved: false,
            failurePrecedesCPUMechanics: true),
        artifactBoundary: PrimeNativeDecoderTinyCPUFailureArtifactBoundaryV1(
            actionsArtifactsEndpoint:
                "https://api.github.com/repos/Ergentics/ergentics-prime/actions/runs/31525634838/artifacts",
            actionsArtifactsTotalCount: 0,
            actionsArtifactsArrayExactlyEmpty: true,
            publishedWorkflowArtifactCount: 0,
            artifactUploadStepCount: 0,
            runLogArchiveObserved: true,
            runLogArchiveIsActionsArtifact: false,
            jobLogsRetainedInRepository: false,
            durableJobLogPublicationEstablished: false,
            runtimeReceiptEmitted: false,
            tokenizerReceiptEmitted: false,
            checkpointReceiptEmitted: false,
            checkpointArtifactCreated: false,
            checkpointArtifactUploaded: false,
            checkpointArtifactRetained: false,
            checkpointArtifactProvenanceEstablished: false),
        authorityCeiling: PrimeNativeDecoderTinyCPUFailureAuthorityCeilingV1(
            predecessorAuthorityRemainsFrozen: true,
            predecessorAuthorityValidatedForConsumption: true,
            predecessorExecutionAttemptConsumed: true,
            predecessorExecutionAuthorityExhausted: true,
            rerunObserved: false,
            rerunAuthorized: false,
            failedAttemptRecoverable: false,
            replacementExecutionAuthorityEstablished: false,
            implementationSourceRemainsFrozen: true,
            validationManifestRemainsFrozen: true,
            validationLockRemainsFrozen: true,
            failedValidationSourceRemainsFrozen: true,
            failedWorkflowInvocationRemainsLive: false,
            bootstrapRepairRequiredBeforeAnotherAttempt: true,
            bootstrapRepairAuthorizedByThisObservation: false,
            tinyCPUTrainEvaluateExecutionEstablished: false,
            tinyCPUCPUDeviceEstablished: false,
            tinyCPUTrainerInitializationEstablished: false,
            tinyCPUModelAllocationEstablished: false,
            tinyCPUOptimizerStepEstablished: false,
            tinyCPUEvaluationEstablished: false,
            explicitRNGStateEstablished: false,
            deterministicDataCursorEstablished: false,
            interruptionBoundaryEstablished: false,
            resumeExecutionEstablished: false,
            checkpointReadEstablished: false,
            checkpointWriteEstablished: false,
            checkpointRoundTripEstablished: false,
            checkpointArtifactAvailabilityEstablished: false,
            checkpointArtifactRetentionEstablished: false,
            checkpointArtifactUploadAuthorized: false,
            checkpointArtifactProvenanceEstablished: false,
            checkpointAdmissionGranted: false,
            metalTensorExecutionEstablished: false,
            metalDeterminismEstablished: false,
            native300MAllocationEstablished: false,
            native300MTrainingEstablished: false,
            trajectoryExactResumeEstablished: false,
            trainingResumeEstablished: false,
            modelQualityEstablished: false,
            candidateAdmissionGranted: false,
            trialAuthorized: false,
            canaryReplacementAuthorized: false,
            quantizationAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            stage3Blocked: true),
        status:
            "ABSTAIN_stage2_attempt_consumed_hosted_default_metallib_bootstrap_failed_before_cpu_trainer_model_step_or_evaluation_no_rerun_no_actions_or_checkpoint_artifact_no_downstream_authority",
        orderedNextActions: [
            "keep_the_failed_stage2_implementation_manifest_lock_and_validation_source_frozen",
            "keep_the_exhausted_invocation_filter_log_and_scratch_paths_retired",
            "separately_authorize_a_pinned_source_default_metallib_bootstrap_repair",
            "stage_and_bind_the_exact_default_metallib_before_a_distinct_new_attempt",
            "require_one_successful_stage2_test_with_zero_skips_and_zero_failures_before_stage3",
        ])

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationError
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
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationError
                    .contractDrift
        }
        do {
            try PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1
                .frozenV1.validateExactV1()
        } catch {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationError
                    .contractDrift
        }
        guard predecessorAuthorityID
                == PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsAuthorityV1
                    .frozenV1.authorityID,
              observedSourceBindings.count == 12,
              rawLogArchive.members.count == 17,
              focusedExecution.completedGroups.map(\.completedTestCount)
                == [34, 1, 1, 2, 2],
              focusedExecution.completedTestCountBeforeStage2Termination
                == focusedExecution.completedGroups.reduce(0, {
                    $0 + $1.completedTestCount
                }),
              activeRootRawLog.lfByteCount
                == activeRootRawLog.splitLineCountExcludingTerminalEmpty,
              activeRootRawLog.newlineDelimitedComponentCountIncludingTerminalEmpty
                == activeRootRawLog.lfByteCount + 1,
              reviewedMainRawLog.lfByteCount
                == reviewedMainRawLog.splitLineCountExcludingTerminalEmpty,
              reviewedMainRawLog.newlineDelimitedComponentCountIncludingTerminalEmpty
                == reviewedMainRawLog.lfByteCount + 1,
              failureBoundary.diagnosticFocusedArchiveMemberTimestamp
                == rawLogArchive.focusedStepMemberDiagnosticTimestamp,
              failureBoundary.focusedArchiveMemberExitTimestamp
                == rawLogArchive.focusedStepMemberExitTimestamp,
              authorityCeiling.predecessorExecutionAttemptConsumed,
              authorityCeiling.predecessorExecutionAuthorityExhausted,
              authorityCeiling.stage3Blocked else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationError
                    .contractDrift
        }
    }
}
