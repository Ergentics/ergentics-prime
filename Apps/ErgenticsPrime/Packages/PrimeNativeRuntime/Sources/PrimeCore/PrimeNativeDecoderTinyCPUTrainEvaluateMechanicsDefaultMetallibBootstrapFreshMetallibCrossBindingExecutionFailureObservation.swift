// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureSourceIdentityV1:
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

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureRepositoryIdentityV1:
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
    public let mergedAt: String
    public let historyPreservingTwoParentMergeObserved: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
    public let mergeCommitSignatureVerified: Bool
    public let mergeCommitSignatureReason: String
    public let mergeCommitSignatureVerifiedAt: String
    public let exactMainRefStillMatchedAtAudit: Bool
    public let embeddedSourceIdentitySHA256: String
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureRunIdentityV1:
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
    public let terminalUpdatedAt: String
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

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureJobStepV1:
    Codable,
    Equatable,
    Sendable
{
    public let number: Int
    public let name: String
    public let startedAt: String
    public let completedAt: String
    public let conclusion: String
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureJobObservationV1:
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
    public let runnerID: Int
    public let runnerName: String
    public let runnerGroupName: String
    public let orderedSteps: [PrimeNativeDecoderStage2FreshCrossBindingFailureJobStepV1]
    public let checkAnnotationCount: Int
    public let checkAnnotationPath: String
    public let checkAnnotationStartLine: Int
    public let checkAnnotationEndLine: Int
    public let checkAnnotationLevel: String
    public let checkAnnotationMessage: String
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureRunnerToolchainV1:
    Codable,
    Equatable,
    Sendable
{
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
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1:
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

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureArchiveMemberIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureLogArchiveIdentityV1:
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
    public let runtimeReceiptMemberTimestamp: String
    public let runtimeReceiptAggregateTimestamp: String
    public let tokenizerReceiptMemberTimestamp: String
    public let tokenizerReceiptAggregateTimestamp: String
    public let stage2DiagnosticMemberTimestamp: String
    public let stage2DiagnosticAggregateTimestamp: String
    public let stage2ExitMemberTimestamp: String
    public let stage2ExitAggregateTimestamp: String
    public let members:
        [PrimeNativeDecoderStage2FreshCrossBindingFailureArchiveMemberIdentityV1]
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureReceiptIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let scope: String
    public let prefix: String
    public let count: Int
    public let jsonByteCount: Int
    public let jsonSHA256: String
    public let memberTimestamp: String
    public let aggregateTimestamp: String
    public let evidenceID: String
    public let outcomeKind: String
    public let outcomeEstablished: Bool
    public let metallibByteCount: Int
    public let metallibSHA256: String
    public let loadedMetallibIdentityIndependentlyObserved: Bool
    public let metallibArtifactProvenanceEstablished: Bool
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailurePredecessorBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let activeRootGatePassed: Bool
    public let dependencyFreeSwiftParsePassed: Bool
    public let latinInvocationCount: Int
    public let latinCompletedTestCount: Int
    public let latinFailureCount: Int
    public let latinSkipCount: Int
    public let latinFinalSummaryOccurrenceCount: Int
    public let securePrivateDependencyFetchInvocationCount: Int
    public let securePrivateDependencyFetchCompletionCount: Int
    public let workflowAuthoredRetryCount: Int
    public let separateSecureFetchRetryStepCount: Int
    public let gitInternalSubmoduleRetryCount: Int
    public let priorRunGitInternalSubmoduleRetryCount: Int
    public let mlxSubmoduleCloneAttemptCount: Int
    public let mlxCSubmoduleCloneAttemptCount: Int
    public let gitSubmoduleTLSFailureCount: Int
    public let secureFetchWorkflowBlockSHA256: String
    public let tlsVerificationBypassCount: Int
    public let customCAInstallationCount: Int
    public let privateDependencyRevision: String
    public let privateDependencySubmoduleRevisions: [String]
    public let focusedRootInvocationCount: Int
    public let focusedRootTestCount: Int
    public let focusedRootFailureCount: Int
    public let focusedRootSkipCount: Int
    public let focusedRootSuccessSummaryOccurrenceCount: Int
    public let isolatedCheckpointGroupTestCounts: [Int]
    public let focusedWholeStepTestCount: Int
    public let focusedWholeStepFailureCount: Int
    public let focusedWholeStepSkipCount: Int
    public let observedLiveInvocationSequence: [String]
    public let observedLiveInvocationCounts: [Int]
    public let greenPredecessorLiveSequence: [String]
    public let greenPredecessorLiveSuccessCounts: [Int]
    public let metallibBuildInvocationCount: Int
    public let metallibBuildCompletionCount: Int
    public let freshMetallibFileName: String
    public let freshMetallibCandidateCount: Int
    public let freshMetallibByteCount: Int
    public let freshMetallibSHA256: String
    public let metalGroupTestCounts: [Int]
    public let metalTestCount: Int
    public let metalFailureCount: Int
    public let metalSkipCount: Int
    public let runtimeInvocationCount: Int
    public let runtimeTestCount: Int
    public let runtimeFailureCount: Int
    public let runtimeSkipCount: Int
    public let runtimeReceipt:
        PrimeNativeDecoderStage2FreshCrossBindingFailureReceiptIdentityV1
    public let tokenizerInvocationCount: Int
    public let tokenizerTestCount: Int
    public let tokenizerFailureCount: Int
    public let tokenizerSkipCount: Int
    public let tokenizerReceipt:
        PrimeNativeDecoderStage2FreshCrossBindingFailureReceiptIdentityV1
    public let tokenizerExecutedRevision: String
    public let tokenizerExecutedTree: String
    public let tokenizerEmbeddedSourceIdentitySHA256: String
    public let predecessorLogInventoryCount: Int
    public let emittedPredecessorReceiptCount: Int
    public let completedPreStage2TestCount: Int
    public let preStage2FailureCount: Int
    public let preStage2SkipCount: Int
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureLauncherBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let workflowOutcome: String
    public let stage2Disposition: String
    public let failedJobStepNumber: Int
    public let failedJobStepName: String
    public let failedStepStartedAt: String
    public let failedStepCompletedAt: String
    public let launcherPath: String
    public let launcherInvocationCount: Int
    public let launcherCommand: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let validationTestClass: String
    public let validationTestMethod: String
    public let validationTestFilter: String
    public let intendedBuildCommand: String
    public let classifierCommand: String
    public let classifierRegex: String
    public let classifierAcceptedFixtureCount: Int
    public let classifierRejectedFixtureCount: Int
    public let predecessorLogInventoryCount: Int
    public let predecessorLogScanCount: Int
    public let predecessorLogClassifierPassed: Bool
    public let stage2MetallibDiscoverySourceLine: Int
    public let stage2MetallibHashSourceLine: Int
    public let metalAggregateIdentityEmissionSourceLine: Int
    public let metalXCTestTeeSourceLines: [Int]
    public let crossBindingGuardSourceLines: [Int]
    public let predecessorReceiptValidationSourceLine: Int
    public let stage2FreshPathAbsenceGuardSourceLine: Int
    public let stage2WorkspaceCreationSourceLine: Int
    public let stage2BuildSourceLine: Int
    public let stage2CopySourceLines: [Int]
    public let stage2DirectXCTestSourceLines: [Int]
    public let metalXCTestLogPath: String
    public let aggregateMetalIdentityLine: String
    public let aggregateMetalIdentityCount: Int
    public let metalXCTestLogIdentityCount: Int
    public let discoveredMetallibByteCount: Int
    public let discoveredMetallibSHA256: String
    public let runtimeReceiptMetallibIdentityMatched: Bool
    public let tokenizerReceiptMetallibIdentityMatched: Bool
    public let metallibIdentityDivergenceObserved: Bool
    public let deterministicLogChannelCause: String
    public let failureClassification: String
    public let exactDiagnostic: String
    public let diagnosticMemberTimestamp: String
    public let diagnosticAggregateTimestamp: String
    public let processExitCode: Int
    public let exactExitMessage: String
    public let exitMemberTimestamp: String
    public let exitAggregateTimestamp: String
    public let predecessorReceiptValidationReached: Bool
    public let sameJobFreshMetallibWasAvailableFromPredecessor: Bool
    public let sameJobFreshMetallibWasInspectedByStage2Launcher: Bool
    public let stage2RepairLauncherReachedFreshMetallibDiscovery: Bool
    public let stage2MetallibDiscoveryCount: Int
    public let stage2MetallibCandidateCount: Int
    public let stage2StagedDestinationCount: Int
    public let stage2MetallibCopyCount: Int
    public let stage2ScratchPathCreationCount: Int
    public let stage2CachePathCreationCount: Int
    public let stage2ConfigPathCreationCount: Int
    public let stage2SecurityPathCreationCount: Int
    public let stage2PrivateWorkingDirectoryCreationCount: Int
    public let stage2TestLogPathCreationCount: Int
    public let stage2BuildInvocationCount: Int
    public let stage2BuildTestsInvocationCount: Int
    public let stage2DirectXCTestInvocationCount: Int
    public let stage2TestStartCount: Int
    public let stage2TestPassCount: Int
    public let stage2TestFailureCount: Int
    public let stage2TestSkipCount: Int
    public let stage2RepairReceiptCount: Int
    public let stage2MechanicsEstablished: Bool
    public let stage2BootstrapRepairEstablished: Bool
    public let failureOccurredAfterGreenPredecessors: Bool
    public let failureOccurredBeforeTargetTestBundleResolution: Bool
    public let predecessorTestFailureObserved: Bool
    public let stage2MechanicsTestFailureObserved: Bool
    public let metallibDiscoveryOrBuildFailureObserved: Bool
    public let launcherClassifierFalsePositiveObserved: Bool
    public let launcherSourceMutationPerformed: Bool
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureArtifactBoundaryV1:
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
    public let freshMetallibRetainedAfterJob: Bool
    public let freshMetallibArtifactProvenanceEstablished: Bool
    public let runtimeReceiptEmitted: Bool
    public let tokenizerReceiptEmitted: Bool
    public let stage2RepairReceiptEmitted: Bool
    public let checkpointArtifactCreated: Bool
    public let checkpointArtifactUploaded: Bool
    public let checkpointArtifactRetained: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
}

public struct PrimeNativeDecoderStage2FreshCrossBindingFailureAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let predecessorExecutionAuthorityConsumed: Bool
    public let predecessorExecutionAuthorityExhausted: Bool
    public let failureObservationAuthorizesNothing: Bool
    public let distinctRepairAuthorityRequired: Bool
    public let launcherSourceMustRemainPreservedForAudit: Bool
    public let stage3RemainsBlocked: Bool
    public let rerunAuthorized: Bool
    public let retryAuthorized: Bool
    public let replacementRunAuthorized: Bool
    public let consumedStage2LiveInvocationRetirementRequired: Bool
    public let workflowMutationBeyondRequiredRetirementAuthorized: Bool
    public let launcherMutationAuthorized: Bool
    public let predecessorLogClassifierRepairAuthorized: Bool
    public let freshMetallibCrossBindingRepairAuthorized: Bool
    public let tlsVerificationBypassAuthorized: Bool
    public let credentialMutationAuthorized: Bool
    public let newMetallibBuildAuthorized: Bool
    public let stage2ReexecutionAuthorized: Bool
    public let stage2SuccessEstablished: Bool
    public let stage2RepairReceiptPublicationAuthorized: Bool
    public let workflowArtifactUploadAuthorized: Bool
    public let checkpointReadEstablished: Bool
    public let checkpointWriteEstablished: Bool
    public let checkpointRoundTripEstablished: Bool
    public let checkpointArtifactAvailabilityEstablished: Bool
    public let checkpointArtifactRetentionEstablished: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
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
    public let stage3AuthorityEstablished: Bool
}

/// Append-only observation of the first and only exact-main execution under the
/// predecessor-log classifier repair authority. Active validation, secure
/// fetch, root 41, the isolated checkpoint suites, Metal 44, maintained
/// runtime, and tokenizer compatibility all passed. The repaired classifier
/// accepted every predecessor log, and the launcher discovered and hashed the
/// same-job fresh metallib. It then required the Metal identity line in the
/// xctest-only Metal log even though the Metal launcher emitted that line before
/// starting the xctest-to-log tee. The aggregate output and both receipts bind
/// exactly the same metallib; no identity divergence was observed.
///
/// Workflow failure and Stage-2 test disposition are deliberately separate.
/// No Stage-2 build, copy, direct test, test outcome, or repair receipt occurred.
/// This observation does not retry the consumed execution, mutate either
/// launcher, publish an artifact, or authorize Stage 3.
public struct
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let repositoryIdentity:
        PrimeNativeDecoderStage2FreshCrossBindingFailureRepositoryIdentityV1
    public let observedSourceBindings:
        [PrimeNativeDecoderStage2FreshCrossBindingFailureSourceIdentityV1]
    public let runIdentity:
        PrimeNativeDecoderStage2FreshCrossBindingFailureRunIdentityV1
    public let activeRootJob:
        PrimeNativeDecoderStage2FreshCrossBindingFailureJobObservationV1
    public let reviewedMainJob:
        PrimeNativeDecoderStage2FreshCrossBindingFailureJobObservationV1
    public let runnerToolchain:
        PrimeNativeDecoderStage2FreshCrossBindingFailureRunnerToolchainV1
    public let activeRootRawLog:
        PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1
    public let reviewedMainRawLog:
        PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1
    public let secureFetchStepRawLog:
        PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1
    public let focusedContractsStepRawLog:
        PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1
    public let liveStage2StepRawLog:
        PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1
    public let rawLogArchive:
        PrimeNativeDecoderStage2FreshCrossBindingFailureLogArchiveIdentityV1
    public let predecessorBoundary:
        PrimeNativeDecoderStage2FreshCrossBindingFailurePredecessorBoundaryV1
    public let launcherFailureBoundary:
        PrimeNativeDecoderStage2FreshCrossBindingFailureLauncherBoundaryV1
    public let artifactBoundary:
        PrimeNativeDecoderStage2FreshCrossBindingFailureArtifactBoundaryV1
    public let authorityCeiling:
        PrimeNativeDecoderStage2FreshCrossBindingFailureAuthorityCeilingV1
    public let status: String
    public let orderedRequiredSeparateActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_cross_binding_execution_failure_observation_v1",
        observationKind:
            "exact_main_stage2_fresh_metallib_cross_binding_evidence_surface_failure_observation",
        predecessorAuthorityID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_predecessor_log_classifier_repair_authority_v1",
        predecessorAuthorityCanonicalSHA256:
            "9c94ceeca77c3fc5173adfa41f9965d33c3a78f8d975b639dd3dc0aa2c2ed99b",
        repositoryIdentity:
            PrimeNativeDecoderStage2FreshCrossBindingFailureRepositoryIdentityV1(
                repository: "Ergentics/ergentics-prime",
                pullRequestNumber: 89,
                ref: "refs/heads/main",
                revision: "050c0e4c60df4a1d0bd3dbba1f194f425609cb1b",
                orderedParentRevisions: [
                    "775b247fb8c1f0e3c28d01fce281d8d29bbb4dd1",
                    "f34057921b53af80ddb40c0fd89fa4ee0ddbce85",
                ],
                tree: "ea5a8da68dd9539cdb78b5203da796941c5495a8",
                reviewedHeadRevision:
                    "f34057921b53af80ddb40c0fd89fa4ee0ddbce85",
                reviewedHeadTree:
                    "ea5a8da68dd9539cdb78b5203da796941c5495a8",
                mergedAt: "2026-08-12T01:59:55Z",
                historyPreservingTwoParentMergeObserved: true,
                mergeTreeEqualsReviewedHeadTree: true,
                mergeCommitSignatureVerified: true,
                mergeCommitSignatureReason: "valid",
                mergeCommitSignatureVerifiedAt: "2026-08-12T02:00:42Z",
                exactMainRefStillMatchedAtAudit: true,
                embeddedSourceIdentitySHA256:
                    "643c3de86ac22c478750f052bdf1db77bb3e634623154e8898044792ef09d02f"),
        observedSourceBindings: [
            source(
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                "100755", "4ee3891f06d7e4b9e0e7cfdee93a0f5ed90ae3b0",
                378_176,
                "e138a8fe89b6aaffcc82dfbe3f8b0631587cb1485c17cf415a631e6d9d637ee7",
                "exact_consumed_root41_gate"),
            source(
                ".github/scripts/prime-ci-native-decoder-metal.sh",
                "100755", "418d2d2753cee38e0b3558ad45e1e09865ffd11d",
                11_793,
                "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff",
                "exact_metal_identity_emission_and_xctest_log_capture_boundaries"),
            source(
                ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                "100755", "45fc1f82ecfe14a6a9e98c345706f75b37c2d1cb",
                44_691,
                "3b8a0790b521de9c6ca03760aef8e9bbece4d46f6d1f8505dae44fc9a559d185",
                "exact_failed_launcher_classifier_and_cross_binding_guard"),
            source(
                ".github/workflows/prime-active-root-quarantine.yml",
                "100644", "aa71ada76c09fcb68a4795fc37e3e9dbea0e56ea",
                46_747,
                "6bfebb329e9acfed6336f7d8772f076c466de4cf02e8dbde606a2fbd65b238dd",
                "exact_failed_workflow_topology_and_order"),
            source(
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "100644", "9bd9a2e6b32089e67564223cf668398b7734cee3",
                546,
                "fc432898622d1973287d7faec759868827a80241b59712ea35861341bdc48677",
                "exact_consumed_embedded_source_identity"),
            source(
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift",
                "100644", "b3b42c285c8fe048d4eeea111f3f9f9bab37707d",
                66_167,
                "2f97065f3c09f69d2ce38774a16a5d4dcb9deb20899cdeb1f8821334d2486983",
                "consumed_predecessor_execution_authority"),
            source(
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift",
                "100644", "15164c2256129816789fd2408f73f7b1c7eaccbd",
                35_453,
                "2600a86636c5440ddd010e10a0928fd7f49b96d2926536d881364e524630d187",
                "consumed_predecessor_authority_test"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "100644", "9f05e5a17426f00adf9dad7b55d84057122e98f9",
                1_054,
                "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45",
                "unreached_stage2_validation_manifest_after_cross_binding_failure"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                "100644", "8bf05edf1ea8789e7683e72fe756d79aaaa61320",
                645,
                "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225",
                "unreached_stage2_validation_lock_after_cross_binding_failure"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
                "100644", "61e86200c508526ae2ab66e359d771841f7208db",
                30_214,
                "29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96",
                "unreached_exact_stage2_validation_test_after_cross_binding_failure"),
        ],
        runIdentity: PrimeNativeDecoderStage2FreshCrossBindingFailureRunIdentityV1(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_555_440_908,
            runNumber: 75,
            runAttempt: 1,
            event: "push",
            headBranch: "main",
            headRevision: "050c0e4c60df4a1d0bd3dbba1f194f425609cb1b",
            actor: "psyop-archivist",
            triggeringActor: "psyop-archivist",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31555440908",
            createdAt: "2026-08-12T01:59:57Z",
            startedAt: "2026-08-12T01:59:57Z",
            terminalUpdatedAt: "2026-08-12T02:42:08Z",
            status: "completed",
            conclusion: "failure",
            checkSuiteID: 85_598_166_484,
            exactHeadPushRunCount: 1,
            previousAttemptURLWasNull: true,
            secondAttemptEndpointHTTPStatus: 404,
            rerunCount: 0,
            rerunObserved: false,
            rerunAuthorized: false),
        activeRootJob: job(
            id: 93_986_794_547,
            name: "First-party MLX / active-root quarantine",
            startedAt: "2026-08-12T02:00:00Z",
            completedAt: "2026-08-12T02:02:41Z",
            conclusion: "success",
            runnerLabel: "macos-15",
            runnerID: 1_000_001_703,
            runnerName: "GitHub Actions 1000001703",
            steps: [
                step(1, "Set up job", "2026-08-12T02:00:01Z", "2026-08-12T02:00:01Z", "success"),
                step(2, "Check out the exact Prime revision", "2026-08-12T02:00:01Z", "2026-08-12T02:00:05Z", "success"),
                step(3, "Validate active metadata and preserved history", "2026-08-12T02:00:05Z", "2026-08-12T02:00:38Z", "success"),
                step(4, "Parse the changed Swift contracts without dependencies", "2026-08-12T02:00:38Z", "2026-08-12T02:00:46Z", "success"),
                step(5, "Validate isolated Latin capture and observation contracts", "2026-08-12T02:00:46Z", "2026-08-12T02:02:37Z", "success"),
                step(6, "Record the authority ceiling", "2026-08-12T02:02:37Z", "2026-08-12T02:02:37Z", "success"),
                step(7, "Complete job", "2026-08-12T02:02:37Z", "2026-08-12T02:02:38Z", "success"),
            ]),
        reviewedMainJob: job(
            id: 93_987_253_841,
            name: "Reviewed main / focused source contracts",
            startedAt: "2026-08-12T02:02:43Z",
            completedAt: "2026-08-12T02:42:07Z",
            conclusion: "failure",
            runnerLabel: "macos-26",
            runnerID: 1_000_001_704,
            runnerName: "GitHub Actions 1000001704",
            steps: [
                step(1, "Set up job", "2026-08-12T02:02:43Z", "2026-08-12T02:02:43Z", "success"),
                step(2, "Record the hosted Apple toolchain", "2026-08-12T02:02:43Z", "2026-08-12T02:02:47Z", "success"),
                step(3, "Check out reviewed main exactly", "2026-08-12T02:02:47Z", "2026-08-12T02:02:51Z", "success"),
                step(4, "Fetch the exact private dependency without evaluating Prime", "2026-08-12T02:02:51Z", "2026-08-12T02:03:02Z", "success"),
                step(5, "Compile and run the focused contracts without a credential", "2026-08-12T02:03:02Z", "2026-08-12T02:21:56Z", "success"),
                step(6, "Run the Prime-owned decoder on live Metal", "2026-08-12T02:21:56Z", "2026-08-12T02:41:56Z", "failure"),
                step(7, "Complete job", "2026-08-12T02:41:56Z", "2026-08-12T02:41:58Z", "success"),
            ],
            annotationLine: 74_948,
            annotationMessage: "Process completed with exit code 2."),
        runnerToolchain:
            PrimeNativeDecoderStage2FreshCrossBindingFailureRunnerToolchainV1(
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
                    "Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)",
                swiftTarget: "arm64-apple-macosx26.0",
                macOSSDKVersion: "26.5",
                swiftDriverVersion: "1.148.6",
                exactHostedRunnerImagesRecorded: true,
                exactPhysicalRunnerIdentityRecorded: false),
        activeRootRawLog: rawLog(
            "sealed_raw_active_job_log", 236_478, 1_755,
            "2d0839aafcb251a967a181907251ef5f26f4b5d85f4ad69f8c6fcbb38222bf61",
            "2026-08-12T02:00:01.9086930Z",
            "2026-08-12T02:02:37.5301010Z"),
        reviewedMainRawLog: rawLog(
            "sealed_raw_reviewed_job_log", 10_250_415, 78_468,
            "8ebdef95e509637be4286d5d2dc3533805c97c63d7f626402e991a970838237b",
            "2026-08-12T02:02:43.4741350Z",
            "2026-08-12T02:41:56.3447960Z"),
        secureFetchStepRawLog: rawLog(
            "sealed_raw_secure_fetch_step_log", 4_893, 54,
            "63625513e2a698f208d6fd3783036842ab0d53f976ac6af8e1714c16f78af11f",
            "2026-08-12T02:02:51.2031240Z",
            "2026-08-12T02:03:01.3736420Z"),
        focusedContractsStepRawLog: rawLog(
            "sealed_raw_focused_contracts_step_log", 348_841, 3_378,
            "fcaf74ba6119764649030408235e13e662b57988e68acb9c98d4f3d4515636cd",
            "2026-08-12T02:03:02.5690130Z",
            "2026-08-12T02:21:56.7400810Z"),
        liveStage2StepRawLog: rawLog(
            "sealed_raw_metal_runtime_tokenizer_stage2_step_log",
            9_890_533, 74_948,
            "278f5f0b53e71489bee1da2c9ab780563e8f2a8800c31a66ad47464455219eba",
            "2026-08-12T02:21:56.8994530Z",
            "2026-08-12T02:41:56.3130680Z"),
        rawLogArchive:
            PrimeNativeDecoderStage2FreshCrossBindingFailureLogArchiveIdentityV1(
                byteCount: 1_341_817,
                sha256:
                    "c7ce5e5ee05c21795ba15a235038ae9a23b66fb486e5a3448c3905a86bf6d214",
                memberCount: 18,
                uncompressedByteCount: 20_975_223,
                repeatedDownloadsWereByteIdentical: true,
                memberTimestampsAreDOSZero: true,
                runtimeReceiptMemberTimestamp:
                    "2026-08-12T02:33:50.9643330Z",
                runtimeReceiptAggregateTimestamp:
                    "2026-08-12T02:33:50.9652700Z",
                tokenizerReceiptMemberTimestamp:
                    "2026-08-12T02:41:53.7534960Z",
                tokenizerReceiptAggregateTimestamp:
                    "2026-08-12T02:41:53.7536620Z",
                stage2DiagnosticMemberTimestamp:
                    "2026-08-12T02:41:56.3016570Z",
                stage2DiagnosticAggregateTimestamp:
                    "2026-08-12T02:41:56.3016630Z",
                stage2ExitMemberTimestamp:
                    "2026-08-12T02:41:56.3130680Z",
                stage2ExitAggregateTimestamp:
                    "2026-08-12T02:41:56.3130710Z",
                members: [
                    member("0_Reviewed main _ focused source contracts.txt", 10_250_415, 78_468, "8ebdef95e509637be4286d5d2dc3533805c97c63d7f626402e991a970838237b"),
                    member("1_First-party MLX _ active-root quarantine.txt", 236_478, 1_755, "2d0839aafcb251a967a181907251ef5f26f4b5d85f4ad69f8c6fcbb38222bf61"),
                    member("First-party MLX _ active-root quarantine/1_Set up job.txt", 1_681, 28, "391f6010086d262ff254427343ae4c0c15a2783be5daa33eebfb0b53f023a139"),
                    member("First-party MLX _ active-root quarantine/2_Check out the exact Prime revision.txt", 3_054, 36, "c8234e29b8807a0f20077b8043fdc0d6627214b09685f29dd2be5ad812a6591d"),
                    member("First-party MLX _ active-root quarantine/3_Validate active metadata and preserved history.txt", 706, 8, "edaf3db7ac820b1e7e577b7561df2d821f74401ad9eb23817a359eed7ef70112"),
                    member("First-party MLX _ active-root quarantine/4_Parse the changed Swift contracts without dependencies.txt", 14_319, 105, "80246f7290fb2eeeff88b7f048f8ccf2a9d52361a32423cdf50586b9529d9623"),
                    member("First-party MLX _ active-root quarantine/5_Validate isolated Latin capture and observation contracts.txt", 196_157, 1_520, "d3a4b20d4167321b8429add31f4020164ff412b5e26941d2c3413ac815fce7c0"),
                    member("First-party MLX _ active-root quarantine/6_Record the authority ceiling.txt", 20_518, 57, "b9cc31bfb64fb032e65e97acc70dfbb66c62a2385725f91e5601f59963f39616"),
                    member("First-party MLX _ active-root quarantine/7_Complete job.txt", 61, 1, "ed83ecc2feec31175d679fbc23781828115534e38c7ef972fe9314243b231f2b"),
                    member("First-party MLX _ active-root quarantine/system.txt", 601, 7, "d03e5ab6e77f636af31c21c236ada94994c783459f4504620610f503f62db9ee"),
                    member("Reviewed main _ focused source contracts/1_Set up job.txt", 1_680, 28, "f7a6c8b350897b1cc73271b789a808f1f977c1553b4ea09a283872969c73ff01"),
                    member("Reviewed main _ focused source contracts/2_Record the hosted Apple toolchain.txt", 1_279, 22, "d508ef2c3c5828ef860a9df29959d7ae3d5e954d30415889ab8c38df9f7b670d"),
                    member("Reviewed main _ focused source contracts/3_Check out reviewed main exactly.txt", 3_146, 37, "ded4cfee5ecaa4db47bd315c8a8d21f69d4249387d88c2bb1e344b2f63782a68"),
                    member("Reviewed main _ focused source contracts/4_Fetch the exact private dependency without evaluating Prime.txt", 4_893, 54, "63625513e2a698f208d6fd3783036842ab0d53f976ac6af8e1714c16f78af11f"),
                    member("Reviewed main _ focused source contracts/5_Compile and run the focused contracts without a credential.txt", 348_841, 3_378, "fcaf74ba6119764649030408235e13e662b57988e68acb9c98d4f3d4515636cd"),
                    member("Reviewed main _ focused source contracts/6_Run the Prime-owned decoder on live Metal.txt", 9_890_533, 74_948, "278f5f0b53e71489bee1da2c9ab780563e8f2a8800c31a66ad47464455219eba"),
                    member("Reviewed main _ focused source contracts/7_Complete job.txt", 61, 1, "c367b769bb1e0bb923b235229368c739ef4d0a1a65d87ba087a309f5f8a3f42b"),
                    member("Reviewed main _ focused source contracts/system.txt", 800, 8, "1bd6802fc967d5674de8c62d00452fa5fc7561057fcd4a63503549c54b8060a2"),
                ]),
        predecessorBoundary:
            PrimeNativeDecoderStage2FreshCrossBindingFailurePredecessorBoundaryV1(
                activeRootGatePassed: true,
                dependencyFreeSwiftParsePassed: true,
                latinInvocationCount: 1,
                latinCompletedTestCount: 116,
                latinFailureCount: 0,
                latinSkipCount: 0,
                latinFinalSummaryOccurrenceCount: 2,
                securePrivateDependencyFetchInvocationCount: 1,
                securePrivateDependencyFetchCompletionCount: 1,
                workflowAuthoredRetryCount: 0,
                separateSecureFetchRetryStepCount: 0,
                gitInternalSubmoduleRetryCount: 0,
                priorRunGitInternalSubmoduleRetryCount: 1,
                mlxSubmoduleCloneAttemptCount: 1,
                mlxCSubmoduleCloneAttemptCount: 1,
                gitSubmoduleTLSFailureCount: 0,
                secureFetchWorkflowBlockSHA256:
                    "ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847",
                tlsVerificationBypassCount: 0,
                customCAInstallationCount: 0,
                privateDependencyRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                privateDependencySubmoduleRevisions: [
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                    "0726ca922fc902c4c61ef9c27d94132be418e945",
                ],
                focusedRootInvocationCount: 1,
                focusedRootTestCount: 41,
                focusedRootFailureCount: 0,
                focusedRootSkipCount: 0,
                focusedRootSuccessSummaryOccurrenceCount: 2,
                isolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
                focusedWholeStepTestCount: 47,
                focusedWholeStepFailureCount: 0,
                focusedWholeStepSkipCount: 0,
                observedLiveInvocationSequence: [
                    "metal", "maintained_runtime", "tokenizer", "stage2",
                ],
                observedLiveInvocationCounts: [1, 1, 1, 1],
                greenPredecessorLiveSequence: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                greenPredecessorLiveSuccessCounts: [1, 1, 1],
                metallibBuildInvocationCount: 1,
                metallibBuildCompletionCount: 1,
                freshMetallibFileName: "default.metallib",
                freshMetallibCandidateCount: 1,
                freshMetallibByteCount: 6_292_684,
                freshMetallibSHA256:
                    "0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994",
                metalGroupTestCounts: [11, 14, 19],
                metalTestCount: 44,
                metalFailureCount: 0,
                metalSkipCount: 0,
                runtimeInvocationCount: 1,
                runtimeTestCount: 1,
                runtimeFailureCount: 0,
                runtimeSkipCount: 0,
                runtimeReceipt: receipt(
                    "maintained_runtime",
                    "PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=",
                    6_853,
                    "ee8dc3c019344a781d2d4bf04bd944a7348522e6b02de85a9a6beff180635e23",
                    "2026-08-12T02:33:50.9643330Z",
                    "2026-08-12T02:33:50.9652700Z",
                    "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
                    "bounded_mlx_runtime_initialization",
                    6_292_684,
                    "0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994"),
                tokenizerInvocationCount: 1,
                tokenizerTestCount: 1,
                tokenizerFailureCount: 0,
                tokenizerSkipCount: 0,
                tokenizerReceipt: receipt(
                    "tokenizer_compatibility",
                    "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=",
                    7_182,
                    "665878cbd3b2edf76d684f4185601fd3cb676320256d2d4e00d40f66d38b74a2",
                    "2026-08-12T02:41:53.7534960Z",
                    "2026-08-12T02:41:53.7536620Z",
                    "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1",
                    "tokenizer_functional_compatibility",
                    6_292_684,
                    "0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994"),
                tokenizerExecutedRevision:
                    "050c0e4c60df4a1d0bd3dbba1f194f425609cb1b",
                tokenizerExecutedTree:
                    "ea5a8da68dd9539cdb78b5203da796941c5495a8",
                tokenizerEmbeddedSourceIdentitySHA256:
                    "643c3de86ac22c478750f052bdf1db77bb3e634623154e8898044792ef09d02f",
                predecessorLogInventoryCount: 10,
                emittedPredecessorReceiptCount: 2,
                completedPreStage2TestCount: 93,
                preStage2FailureCount: 0,
                preStage2SkipCount: 0),
        launcherFailureBoundary:
            PrimeNativeDecoderStage2FreshCrossBindingFailureLauncherBoundaryV1(
                workflowOutcome: "failure",
                stage2Disposition:
                    "fresh_metallib_discovery_completed_then_cross_binding_log_channel_guard_failed_before_receipt_validation_staging_build_or_test",
                failedJobStepNumber: 6,
                failedJobStepName:
                    "Run the Prime-owned decoder on live Metal",
                failedStepStartedAt: "2026-08-12T02:21:56Z",
                failedStepCompletedAt: "2026-08-12T02:41:56Z",
                launcherPath:
                    ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                launcherInvocationCount: 1,
                launcherCommand:
                    "bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                predecessorAuthorityID:
                    "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_predecessor_log_classifier_repair_authority_v1",
                predecessorAuthorityCanonicalSHA256:
                    "9c94ceeca77c3fc5173adfa41f9965d33c3a78f8d975b639dd3dc0aa2c2ed99b",
                validationTestClass: "PrimeNativeDecoderTrainingTests",
                validationTestMethod:
                    "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                validationTestFilter:
                    "PrimeNativeDecoderTrainingTests/testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                intendedBuildCommand: "swift build --build-tests",
                classifierCommand: "grep -Eq",
                classifierRegex:
                    "^Test Case '[^']+' failed \\(\u{7c}^Test Suite '[^']+' failed at \u{7c}^error:\u{7c}^Test Case '[^']+' skipped \\(\u{7c} : Test skipped - ",
                classifierAcceptedFixtureCount: 8,
                classifierRejectedFixtureCount: 5,
                predecessorLogInventoryCount: 10,
                predecessorLogScanCount: 8,
                predecessorLogClassifierPassed: true,
                stage2MetallibDiscoverySourceLine: 437,
                stage2MetallibHashSourceLine: 465,
                metalAggregateIdentityEmissionSourceLine: 159,
                metalXCTestTeeSourceLines: [162, 163],
                crossBindingGuardSourceLines: [471, 472, 473],
                predecessorReceiptValidationSourceLine: 475,
                stage2FreshPathAbsenceGuardSourceLine: 549,
                stage2WorkspaceCreationSourceLine: 555,
                stage2BuildSourceLine: 585,
                stage2CopySourceLines: [642, 643],
                stage2DirectXCTestSourceLines: [674, 675, 676],
                metalXCTestLogPath:
                    "/Users/runner/work/_temp/prime-native-decoder-metal-tests.log",
                aggregateMetalIdentityLine:
                    "Prime decoder Metal gate: metallib_sha256=0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994 metallib_bytes=6292684",
                aggregateMetalIdentityCount: 1,
                metalXCTestLogIdentityCount: 0,
                discoveredMetallibByteCount: 6_292_684,
                discoveredMetallibSHA256:
                    "0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994",
                runtimeReceiptMetallibIdentityMatched: true,
                tokenizerReceiptMetallibIdentityMatched: true,
                metallibIdentityDivergenceObserved: false,
                deterministicLogChannelCause:
                    "metal_identity_bare_echo_precedes_xctest_tee_so_aggregate_has_identity_but_xctest_only_metal_log_does_not",
                failureClassification:
                    "deterministic_evidence_capture_scope_mismatch_after_fresh_metallib_discovery_no_identity_divergence",
                exactDiagnostic:
                    "prime-native-decoder-stage2-metallib-bootstrap-repair: Metal log does not bind the fresh metallib",
                diagnosticMemberTimestamp:
                    "2026-08-12T02:41:56.3016570Z",
                diagnosticAggregateTimestamp:
                    "2026-08-12T02:41:56.3016630Z",
                processExitCode: 2,
                exactExitMessage: "Process completed with exit code 2.",
                exitMemberTimestamp: "2026-08-12T02:41:56.3130680Z",
                exitAggregateTimestamp: "2026-08-12T02:41:56.3130710Z",
                predecessorReceiptValidationReached: false,
                sameJobFreshMetallibWasAvailableFromPredecessor: true,
                sameJobFreshMetallibWasInspectedByStage2Launcher: true,
                stage2RepairLauncherReachedFreshMetallibDiscovery: true,
                stage2MetallibDiscoveryCount: 1,
                stage2MetallibCandidateCount: 1,
                stage2StagedDestinationCount: 0,
                stage2MetallibCopyCount: 0,
                stage2ScratchPathCreationCount: 0,
                stage2CachePathCreationCount: 0,
                stage2ConfigPathCreationCount: 0,
                stage2SecurityPathCreationCount: 0,
                stage2PrivateWorkingDirectoryCreationCount: 0,
                stage2TestLogPathCreationCount: 0,
                stage2BuildInvocationCount: 0,
                stage2BuildTestsInvocationCount: 0,
                stage2DirectXCTestInvocationCount: 0,
                stage2TestStartCount: 0,
                stage2TestPassCount: 0,
                stage2TestFailureCount: 0,
                stage2TestSkipCount: 0,
                stage2RepairReceiptCount: 0,
                stage2MechanicsEstablished: false,
                stage2BootstrapRepairEstablished: false,
                failureOccurredAfterGreenPredecessors: true,
                failureOccurredBeforeTargetTestBundleResolution: true,
                predecessorTestFailureObserved: false,
                stage2MechanicsTestFailureObserved: false,
                metallibDiscoveryOrBuildFailureObserved: false,
                launcherClassifierFalsePositiveObserved: false,
                launcherSourceMutationPerformed: false),
        artifactBoundary:
            PrimeNativeDecoderStage2FreshCrossBindingFailureArtifactBoundaryV1(
                actionsArtifactsEndpoint:
                    "https://api.github.com/repos/Ergentics/ergentics-prime/actions/runs/31555440908/artifacts",
                actionsArtifactsTotalCount: 0,
                actionsArtifactsArrayExactlyEmpty: true,
                publishedWorkflowArtifactCount: 0,
                artifactUploadStepCount: 0,
                runLogArchiveObserved: true,
                runLogArchiveIsActionsArtifact: false,
                jobLogsRetainedInRepository: false,
                durableJobLogPublicationEstablished: false,
                freshMetallibRetainedAfterJob: false,
                freshMetallibArtifactProvenanceEstablished: false,
                runtimeReceiptEmitted: true,
                tokenizerReceiptEmitted: true,
                stage2RepairReceiptEmitted: false,
                checkpointArtifactCreated: false,
                checkpointArtifactUploaded: false,
                checkpointArtifactRetained: false,
                checkpointArtifactProvenanceEstablished: false),
        authorityCeiling:
            PrimeNativeDecoderStage2FreshCrossBindingFailureAuthorityCeilingV1(
                predecessorExecutionAuthorityConsumed: true,
                predecessorExecutionAuthorityExhausted: true,
                failureObservationAuthorizesNothing: true,
                distinctRepairAuthorityRequired: true,
                launcherSourceMustRemainPreservedForAudit: true,
                stage3RemainsBlocked: true,
                rerunAuthorized: false,
                retryAuthorized: false,
                replacementRunAuthorized: false,
                consumedStage2LiveInvocationRetirementRequired: true,
                workflowMutationBeyondRequiredRetirementAuthorized: false,
                launcherMutationAuthorized: false,
                predecessorLogClassifierRepairAuthorized: false,
                freshMetallibCrossBindingRepairAuthorized: false,
                tlsVerificationBypassAuthorized: false,
                credentialMutationAuthorized: false,
                newMetallibBuildAuthorized: false,
                stage2ReexecutionAuthorized: false,
                stage2SuccessEstablished: false,
                stage2RepairReceiptPublicationAuthorized: false,
                workflowArtifactUploadAuthorized: false,
                checkpointReadEstablished: false,
                checkpointWriteEstablished: false,
                checkpointRoundTripEstablished: false,
                checkpointArtifactAvailabilityEstablished: false,
                checkpointArtifactRetentionEstablished: false,
                checkpointArtifactProvenanceEstablished: false,
                checkpointAdmissionGranted: false,
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
                stage3AuthorityEstablished: false),
        status:
            "FAIL_exact_main_stage2_fresh_metallib_cross_binding_log_channel_guard_no_stage2_build_test_or_receipt_no_rerun_no_artifact_no_downstream_authority",
        orderedRequiredSeparateActions: [
            "retire_consumed_stage2_live_invocation_without_rerun",
            "preserve_metal_and_failed_stage2_launcher_sources_and_immutable_evidence",
            "separately_authorize_bounded_fresh_metallib_cross_binding_evidence_surface_repair",
            "require_distinct_exact_main_closure_before_any_stage2_success_observation",
            "keep_stage3_blocked",
        ])

    private static func source(
        _ path: String,
        _ mode: String,
        _ blob: String,
        _ byteCount: Int,
        _ sha256: String,
        _ claimScope: String
    ) -> PrimeNativeDecoderStage2FreshCrossBindingFailureSourceIdentityV1 {
        PrimeNativeDecoderStage2FreshCrossBindingFailureSourceIdentityV1(
            path: path,
            gitMode: mode,
            gitBlob: blob,
            byteCount: byteCount,
            sha256: sha256,
            claimScope: claimScope)
    }

    private static func step(
        _ number: Int,
        _ name: String,
        _ startedAt: String,
        _ completedAt: String,
        _ conclusion: String
    ) -> PrimeNativeDecoderStage2FreshCrossBindingFailureJobStepV1 {
        PrimeNativeDecoderStage2FreshCrossBindingFailureJobStepV1(
            number: number,
            name: name,
            startedAt: startedAt,
            completedAt: completedAt,
            conclusion: conclusion)
    }

    private static func job(
        id: Int,
        name: String,
        startedAt: String,
        completedAt: String,
        conclusion: String,
        runnerLabel: String,
        runnerID: Int,
        runnerName: String,
        steps: [PrimeNativeDecoderStage2FreshCrossBindingFailureJobStepV1],
        annotationLine: Int = 0,
        annotationMessage: String = ""
    ) -> PrimeNativeDecoderStage2FreshCrossBindingFailureJobObservationV1 {
        PrimeNativeDecoderStage2FreshCrossBindingFailureJobObservationV1(
            id: id,
            name: name,
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31555440908/job/\(id)",
            startedAt: startedAt,
            completedAt: completedAt,
            status: "completed",
            conclusion: conclusion,
            runnerLabel: runnerLabel,
            runnerID: runnerID,
            runnerName: runnerName,
            runnerGroupName: "GitHub Actions",
            orderedSteps: steps,
            checkAnnotationCount: annotationLine == 0 ? 0 : 1,
            checkAnnotationPath: annotationLine == 0 ? "" : ".github",
            checkAnnotationStartLine: annotationLine,
            checkAnnotationEndLine: annotationLine,
            checkAnnotationLevel: annotationLine == 0 ? "" : "failure",
            checkAnnotationMessage: annotationMessage)
    }

    private static func rawLog(
        _ scope: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String,
        _ firstTimestamp: String,
        _ lastTimestamp: String
    ) -> PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1 {
        PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1(
            scope: scope,
            byteCount: byteCount,
            sha256: sha256,
            utf8BOMHex: "efbbbf",
            startsWithUTF8BOM: true,
            usesLFOnly: true,
            endsWithLF: true,
            lfByteCount: lfByteCount,
            splitLineCountExcludingTerminalEmpty: lfByteCount,
            newlineDelimitedComponentCountIncludingTerminalEmpty:
                lfByteCount + 1,
            lineCountSemantics:
                "lf_bytes_equal_nonempty_newline_delimited_lines_terminal_empty_component_retained_only_by_split",
            firstTimestamp: firstTimestamp,
            lastTimestamp: lastTimestamp)
    }

    private static func member(
        _ path: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String
    ) -> PrimeNativeDecoderStage2FreshCrossBindingFailureArchiveMemberIdentityV1 {
        PrimeNativeDecoderStage2FreshCrossBindingFailureArchiveMemberIdentityV1(
            path: path,
            byteCount: byteCount,
            lfByteCount: lfByteCount,
            sha256: sha256)
    }

    private static func receipt(
        _ scope: String,
        _ prefix: String,
        _ jsonByteCount: Int,
        _ jsonSHA256: String,
        _ memberTimestamp: String,
        _ aggregateTimestamp: String,
        _ evidenceID: String,
        _ outcomeKind: String,
        _ metallibByteCount: Int,
        _ metallibSHA256: String
    ) -> PrimeNativeDecoderStage2FreshCrossBindingFailureReceiptIdentityV1 {
        PrimeNativeDecoderStage2FreshCrossBindingFailureReceiptIdentityV1(
            scope: scope,
            prefix: prefix,
            count: 1,
            jsonByteCount: jsonByteCount,
            jsonSHA256: jsonSHA256,
            memberTimestamp: memberTimestamp,
            aggregateTimestamp: aggregateTimestamp,
            evidenceID: evidenceID,
            outcomeKind: outcomeKind,
            outcomeEstablished: true,
            metallibByteCount: metallibByteCount,
            metallibSHA256: metallibSHA256,
            loadedMetallibIdentityIndependentlyObserved: false,
            metallibArtifactProvenanceEstablished: false)
    }

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationError
                    .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let predecessor =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            guard predecessorAuthorityID == predecessor.authorityID,
                  predecessorAuthorityCanonicalSHA256
                    == PrimeSHA256.hexDigest(
                        of: try predecessor.canonicalData()) else {
                throw
                    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationError
                        .contractDrift
            }
        } catch {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationError
                    .contractDrift
        }

        let repository = repositoryIdentity
        let archive = rawLogArchive
        let predecessorBoundary = predecessorBoundary
        let failure = launcherFailureBoundary
        let artifacts = artifactBoundary
        let ceiling = authorityCeiling
        let authorityFalseClaims = [
            ceiling.rerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.workflowMutationBeyondRequiredRetirementAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.predecessorLogClassifierRepairAuthorized,
            ceiling.freshMetallibCrossBindingRepairAuthorized,
            ceiling.tlsVerificationBypassAuthorized,
            ceiling.credentialMutationAuthorized,
            ceiling.newMetallibBuildAuthorized,
            ceiling.stage2ReexecutionAuthorized,
            ceiling.stage2SuccessEstablished,
            ceiling.stage2RepairReceiptPublicationAuthorized,
            ceiling.workflowArtifactUploadAuthorized,
            ceiling.checkpointReadEstablished,
            ceiling.checkpointWriteEstablished,
            ceiling.checkpointRoundTripEstablished,
            ceiling.checkpointArtifactAvailabilityEstablished,
            ceiling.checkpointArtifactRetentionEstablished,
            ceiling.checkpointArtifactProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.native300MTrainingEstablished,
            ceiling.trajectoryExactResumeEstablished,
            ceiling.trainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage3AuthorityEstablished,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              repository.orderedParentRevisions.count == 2,
              repository.tree == repository.reviewedHeadTree,
              repository.revision == runIdentity.headRevision,
              observedSourceBindings.count == 10,
              Set(observedSourceBindings.map(\.path)).count == 10,
              observedSourceBindings.allSatisfy(Self.validSourceIdentity),
              runIdentity.runAttempt == 1,
              runIdentity.exactHeadPushRunCount == 1,
              runIdentity.rerunCount == 0,
              !runIdentity.rerunObserved,
              !runIdentity.rerunAuthorized,
              activeRootJob.orderedSteps.map(\.number) == Array(1 ... 7),
              activeRootJob.orderedSteps.allSatisfy({
                  $0.conclusion == "success"
              }),
              reviewedMainJob.orderedSteps.map(\.number) == Array(1 ... 7),
              reviewedMainJob.orderedSteps.map(\.conclusion)
                == [
                    "success", "success", "success", "success", "success",
                    "failure", "success",
                ],
              Self.validRawLog(activeRootRawLog),
              Self.validRawLog(reviewedMainRawLog),
              Self.validRawLog(secureFetchStepRawLog),
              Self.validRawLog(focusedContractsStepRawLog),
              Self.validRawLog(liveStage2StepRawLog),
              archive.members.count == archive.memberCount,
              archive.members.reduce(0, { $0 + $1.byteCount })
                == archive.uncompressedByteCount,
              Set(archive.members.map(\.path)).count == archive.memberCount,
              archive.runtimeReceiptMemberTimestamp
                == predecessorBoundary.runtimeReceipt.memberTimestamp,
              archive.runtimeReceiptAggregateTimestamp
                == predecessorBoundary.runtimeReceipt.aggregateTimestamp,
              archive.tokenizerReceiptMemberTimestamp
                == predecessorBoundary.tokenizerReceipt.memberTimestamp,
              archive.tokenizerReceiptAggregateTimestamp
                == predecessorBoundary.tokenizerReceipt.aggregateTimestamp,
              archive.stage2DiagnosticMemberTimestamp
                == failure.diagnosticMemberTimestamp,
              archive.stage2DiagnosticAggregateTimestamp
                == failure.diagnosticAggregateTimestamp,
              archive.stage2ExitMemberTimestamp == failure.exitMemberTimestamp,
              archive.stage2ExitAggregateTimestamp
                == failure.exitAggregateTimestamp,
              predecessorBoundary.activeRootGatePassed,
              predecessorBoundary.dependencyFreeSwiftParsePassed,
              predecessorBoundary.latinInvocationCount == 1,
              predecessorBoundary.latinCompletedTestCount == 116,
              predecessorBoundary.latinFailureCount == 0,
              predecessorBoundary.latinSkipCount == 0,
              predecessorBoundary.securePrivateDependencyFetchInvocationCount
                == 1,
              predecessorBoundary.securePrivateDependencyFetchCompletionCount
                == 1,
              predecessorBoundary.workflowAuthoredRetryCount == 0,
              predecessorBoundary.separateSecureFetchRetryStepCount == 0,
              predecessorBoundary.gitInternalSubmoduleRetryCount == 0,
              predecessorBoundary.priorRunGitInternalSubmoduleRetryCount
                == predecessor.greenPrerequisite
                    .gitInternalSubmoduleRetryScheduledCount,
              predecessorBoundary.mlxSubmoduleCloneAttemptCount == 1,
              predecessorBoundary.mlxCSubmoduleCloneAttemptCount == 1,
              predecessorBoundary.gitSubmoduleTLSFailureCount == 0,
              predecessorBoundary.secureFetchWorkflowBlockSHA256
                == predecessor.greenPrerequisite.secureFetchWorkflowBlockSHA256,
              predecessorBoundary.tlsVerificationBypassCount == 0,
              predecessorBoundary.customCAInstallationCount == 0,
              predecessorBoundary.focusedRootInvocationCount == 1,
              predecessorBoundary.focusedRootTestCount == 41,
              predecessorBoundary.focusedRootFailureCount == 0,
              predecessorBoundary.focusedRootSkipCount == 0,
              predecessorBoundary.isolatedCheckpointGroupTestCounts
                == [1, 1, 2, 2],
              predecessorBoundary.focusedWholeStepTestCount
                == predecessorBoundary.focusedRootTestCount
                    + predecessorBoundary.isolatedCheckpointGroupTestCounts
                        .reduce(0, +),
              predecessorBoundary.focusedWholeStepTestCount == 47,
              predecessorBoundary.focusedWholeStepFailureCount == 0,
              predecessorBoundary.focusedWholeStepSkipCount == 0,
              predecessorBoundary.observedLiveInvocationSequence
                == ["metal", "maintained_runtime", "tokenizer", "stage2"],
              predecessorBoundary.observedLiveInvocationCounts
                == [1, 1, 1, 1],
              predecessorBoundary.greenPredecessorLiveSequence
                == ["metal", "maintained_runtime", "tokenizer"],
              predecessorBoundary.greenPredecessorLiveSuccessCounts
                == [1, 1, 1],
              predecessorBoundary.metallibBuildInvocationCount == 1,
              predecessorBoundary.metallibBuildCompletionCount == 1,
              predecessorBoundary.freshMetallibCandidateCount == 1,
              predecessorBoundary.freshMetallibByteCount == 6_292_684,
              predecessorBoundary.freshMetallibSHA256
                == "0869cdd569064cb534e72fbd2d6cef5d1cd7dc002a681bebbb8b8f43ae794994",
              predecessorBoundary.metalGroupTestCounts == [11, 14, 19],
              predecessorBoundary.metalGroupTestCounts.reduce(0, +) == 44,
              predecessorBoundary.metalTestCount == 44,
              predecessorBoundary.metalFailureCount == 0,
              predecessorBoundary.metalSkipCount == 0,
              predecessorBoundary.runtimeInvocationCount == 1,
              predecessorBoundary.runtimeTestCount == 1,
              predecessorBoundary.runtimeFailureCount == 0,
              predecessorBoundary.runtimeSkipCount == 0,
              Self.validReceipt(predecessorBoundary.runtimeReceipt),
              predecessorBoundary.tokenizerInvocationCount == 1,
              predecessorBoundary.tokenizerTestCount == 1,
              predecessorBoundary.tokenizerFailureCount == 0,
              predecessorBoundary.tokenizerSkipCount == 0,
              Self.validReceipt(predecessorBoundary.tokenizerReceipt),
              predecessorBoundary.runtimeReceipt.metallibByteCount
                == predecessorBoundary.freshMetallibByteCount,
              predecessorBoundary.tokenizerReceipt.metallibByteCount
                == predecessorBoundary.freshMetallibByteCount,
              predecessorBoundary.runtimeReceipt.metallibSHA256
                == predecessorBoundary.freshMetallibSHA256,
              predecessorBoundary.tokenizerReceipt.metallibSHA256
                == predecessorBoundary.freshMetallibSHA256,
              predecessorBoundary.tokenizerExecutedRevision
                == repository.revision,
              predecessorBoundary.tokenizerExecutedTree == repository.tree,
              predecessorBoundary.tokenizerEmbeddedSourceIdentitySHA256
                == repository.embeddedSourceIdentitySHA256,
              predecessorBoundary.predecessorLogInventoryCount == 10,
              predecessorBoundary.emittedPredecessorReceiptCount == 2,
              predecessorBoundary.completedPreStage2TestCount
                == predecessorBoundary.focusedWholeStepTestCount
                    + predecessorBoundary.metalTestCount
                    + predecessorBoundary.runtimeTestCount
                    + predecessorBoundary.tokenizerTestCount,
              predecessorBoundary.completedPreStage2TestCount == 93,
              predecessorBoundary.preStage2FailureCount == 0,
              predecessorBoundary.preStage2SkipCount == 0,
              failure.workflowOutcome == runIdentity.conclusion,
              failure.stage2Disposition
                == "fresh_metallib_discovery_completed_then_cross_binding_log_channel_guard_failed_before_receipt_validation_staging_build_or_test",
              failure.failedJobStepNumber == 6,
              failure.launcherInvocationCount == 1,
              failure.predecessorAuthorityID == predecessorAuthorityID,
              failure.predecessorAuthorityCanonicalSHA256
                == predecessorAuthorityCanonicalSHA256,
              failure.classifierCommand == "grep -Eq",
              failure.classifierAcceptedFixtureCount == 8,
              failure.classifierRejectedFixtureCount == 5,
              failure.predecessorLogInventoryCount == 10,
              failure.predecessorLogScanCount == 8,
              failure.predecessorLogInventoryCount == 10,
              failure.predecessorLogClassifierPassed,
              failure.stage2MetallibDiscoverySourceLine == 437,
              failure.stage2MetallibHashSourceLine == 465,
              failure.metalAggregateIdentityEmissionSourceLine == 159,
              failure.metalXCTestTeeSourceLines == [162, 163],
              failure.crossBindingGuardSourceLines == [471, 472, 473],
              failure.predecessorReceiptValidationSourceLine == 475,
              failure.stage2FreshPathAbsenceGuardSourceLine == 549,
              failure.stage2WorkspaceCreationSourceLine == 555,
              failure.stage2BuildSourceLine == 585,
              failure.stage2CopySourceLines == [642, 643],
              failure.stage2DirectXCTestSourceLines == [674, 675, 676],
              failure.aggregateMetalIdentityLine.contains(
                failure.discoveredMetallibSHA256),
              failure.aggregateMetalIdentityLine.contains(
                "metallib_bytes=\(failure.discoveredMetallibByteCount)"),
              failure.aggregateMetalIdentityCount == 1,
              failure.metalXCTestLogIdentityCount == 0,
              failure.discoveredMetallibByteCount
                == predecessorBoundary.freshMetallibByteCount,
              failure.discoveredMetallibSHA256
                == predecessorBoundary.freshMetallibSHA256,
              failure.runtimeReceiptMetallibIdentityMatched,
              failure.tokenizerReceiptMetallibIdentityMatched,
              !failure.metallibIdentityDivergenceObserved,
              failure.failureClassification
                == "deterministic_evidence_capture_scope_mismatch_after_fresh_metallib_discovery_no_identity_divergence",
              failure.processExitCode == 2,
              !failure.predecessorReceiptValidationReached,
              failure.sameJobFreshMetallibWasAvailableFromPredecessor,
              failure.sameJobFreshMetallibWasInspectedByStage2Launcher,
              failure.stage2RepairLauncherReachedFreshMetallibDiscovery,
              failure.stage2MetallibDiscoveryCount == 1,
              failure.stage2MetallibCandidateCount == 1,
              failure.stage2StagedDestinationCount == 0,
              failure.stage2MetallibCopyCount == 0,
              failure.stage2ScratchPathCreationCount == 0,
              failure.stage2CachePathCreationCount == 0,
              failure.stage2ConfigPathCreationCount == 0,
              failure.stage2SecurityPathCreationCount == 0,
              failure.stage2PrivateWorkingDirectoryCreationCount == 0,
              failure.stage2TestLogPathCreationCount == 0,
              failure.stage2BuildInvocationCount == 0,
              failure.stage2BuildTestsInvocationCount == 0,
              failure.stage2DirectXCTestInvocationCount == 0,
              failure.stage2TestStartCount == 0,
              failure.stage2TestPassCount == 0,
              failure.stage2TestFailureCount == 0,
              failure.stage2TestSkipCount == 0,
              failure.stage2RepairReceiptCount == 0,
              !failure.stage2MechanicsEstablished,
              !failure.stage2BootstrapRepairEstablished,
              failure.failureOccurredAfterGreenPredecessors,
              failure.failureOccurredBeforeTargetTestBundleResolution,
              !failure.predecessorTestFailureObserved,
              !failure.stage2MechanicsTestFailureObserved,
              !failure.metallibDiscoveryOrBuildFailureObserved,
              !failure.launcherClassifierFalsePositiveObserved,
              !failure.launcherSourceMutationPerformed,
              artifacts.actionsArtifactsTotalCount == 0,
              artifacts.actionsArtifactsArrayExactlyEmpty,
              artifacts.publishedWorkflowArtifactCount == 0,
              artifacts.artifactUploadStepCount == 0,
              artifacts.runLogArchiveObserved,
              !artifacts.runLogArchiveIsActionsArtifact,
              artifacts.runtimeReceiptEmitted,
              artifacts.tokenizerReceiptEmitted,
              !artifacts.stage2RepairReceiptEmitted,
              !artifacts.checkpointArtifactCreated,
              !artifacts.checkpointArtifactUploaded,
              !artifacts.checkpointArtifactRetained,
              !artifacts.checkpointArtifactProvenanceEstablished,
              ceiling.predecessorExecutionAuthorityConsumed,
              ceiling.predecessorExecutionAuthorityExhausted,
              ceiling.failureObservationAuthorizesNothing,
              ceiling.distinctRepairAuthorityRequired,
              ceiling.launcherSourceMustRemainPreservedForAudit,
              ceiling.consumedStage2LiveInvocationRetirementRequired,
              ceiling.stage3RemainsBlocked,
              authorityFalseClaims.allSatisfy({ !$0 }) else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationError
                    .contractDrift
        }
    }

    private static func validSourceIdentity(
        _ identity: PrimeNativeDecoderStage2FreshCrossBindingFailureSourceIdentityV1
    ) -> Bool {
        ["100644", "100755"].contains(identity.gitMode)
            && identity.gitBlob.utf8.count == 40
            && identity.byteCount > 0
            && identity.sha256.utf8.count == 64
            && !identity.claimScope.isEmpty
    }

    private static func validRawLog(
        _ log: PrimeNativeDecoderStage2FreshCrossBindingFailureRawLogIdentityV1
    ) -> Bool {
        log.byteCount > 0
            && log.sha256.utf8.count == 64
            && log.utf8BOMHex == "efbbbf"
            && log.startsWithUTF8BOM
            && log.usesLFOnly
            && log.endsWithLF
            && log.lfByteCount == log.splitLineCountExcludingTerminalEmpty
            && log.newlineDelimitedComponentCountIncludingTerminalEmpty
                == log.lfByteCount + 1
    }

    private static func validReceipt(
        _ receipt: PrimeNativeDecoderStage2FreshCrossBindingFailureReceiptIdentityV1
    ) -> Bool {
        receipt.count == 1
            && receipt.jsonByteCount > 0
            && receipt.jsonSHA256.utf8.count == 64
            && receipt.outcomeEstablished
            && receipt.metallibByteCount > 0
            && receipt.metallibSHA256.utf8.count == 64
            && !receipt.loadedMetallibIdentityIndependentlyObserved
            && !receipt.metallibArtifactProvenanceEstablished
    }
}
