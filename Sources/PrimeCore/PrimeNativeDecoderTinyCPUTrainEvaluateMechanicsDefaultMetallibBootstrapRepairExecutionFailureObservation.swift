// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderStage2BootstrapFailureSourceIdentityV1:
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

public struct PrimeNativeDecoderStage2BootstrapFailureRepositoryIdentityV1:
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

public struct PrimeNativeDecoderStage2BootstrapFailureRunIdentityV1:
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

public struct PrimeNativeDecoderStage2BootstrapFailureJobStepV1:
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

public struct PrimeNativeDecoderStage2BootstrapFailureJobObservationV1:
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
    public let orderedSteps: [PrimeNativeDecoderStage2BootstrapFailureJobStepV1]
    public let checkAnnotationCount: Int
    public let checkAnnotationPath: String
    public let checkAnnotationStartLine: Int
    public let checkAnnotationEndLine: Int
    public let checkAnnotationLevel: String
    public let checkAnnotationMessage: String
}

public struct PrimeNativeDecoderStage2BootstrapFailureRunnerToolchainV1:
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

public struct PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1:
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

public struct PrimeNativeDecoderStage2BootstrapFailureArchiveMemberIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
}

public struct PrimeNativeDecoderStage2BootstrapFailureLogArchiveIdentityV1:
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
        [PrimeNativeDecoderStage2BootstrapFailureArchiveMemberIdentityV1]
}

public struct PrimeNativeDecoderStage2BootstrapFailureReceiptIdentityV1:
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

public struct PrimeNativeDecoderStage2BootstrapFailurePredecessorBoundaryV1:
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
    public let securePrivateDependencyFetchRetryCount: Int
    public let tlsVerificationBypassCount: Int
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
    public let offendingPredecessorPackageTestCount: Int
    public let offendingPredecessorPackageFailureCount: Int
    public let offendingPredecessorPackageSkipCount: Int
    public let offendingPredecessorMethodStartCount: Int
    public let offendingPredecessorMethodPassCount: Int
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
        PrimeNativeDecoderStage2BootstrapFailureReceiptIdentityV1
    public let tokenizerInvocationCount: Int
    public let tokenizerTestCount: Int
    public let tokenizerFailureCount: Int
    public let tokenizerSkipCount: Int
    public let tokenizerReceipt:
        PrimeNativeDecoderStage2BootstrapFailureReceiptIdentityV1
    public let tokenizerExecutedRevision: String
    public let tokenizerExecutedTree: String
    public let tokenizerEmbeddedSourceIdentitySHA256: String
    public let predecessorLogInventoryCount: Int
    public let emittedPredecessorReceiptCount: Int
    public let completedPreStage2TestCount: Int
    public let preStage2FailureCount: Int
    public let preStage2SkipCount: Int
}

public struct PrimeNativeDecoderStage2BootstrapFailureLauncherBoundaryV1:
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
    public let guardCommand: String
    public let guardRegex: String
    public let guardCaseInsensitive: Bool
    public let guardRegexUnboundedBeforeFailedSubstring: Bool
    public let guardFailureSourceLine: Int
    public let predecessorReceiptValidationSourceLine: Int
    public let stage2MetallibDiscoverySourceLine: Int
    public let stage2FreshPathAbsenceGuardSourceLine: Int
    public let stage2WorkspaceCreationSourceLine: Int
    public let matchedPredecessorLogPath: String
    public let matchedPredecessorLogOrdinal: Int
    public let completedPredecessorLogScanCountBeforeFalsePositive: Int
    public let matchedPassingIdentifier: String
    public let matchedStartedLine: String
    public let matchedPassedLine: String
    public let matchedStartedMemberTimestamp: String
    public let matchedStartedAggregateTimestamp: String
    public let matchedPassedMemberTimestamp: String
    public let matchedPassedAggregateTimestamp: String
    public let matchedIdentifierStartCount: Int
    public let matchedIdentifierPassCount: Int
    public let matchedPackageTestCount: Int
    public let matchedPackageFailureCount: Int
    public let matchedPackageSkipCount: Int
    public let falsePositiveCause: String
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

public struct PrimeNativeDecoderStage2BootstrapFailureArtifactBoundaryV1:
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

public struct PrimeNativeDecoderStage2BootstrapFailureAuthorityCeilingV1:
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

/// Append-only observation of the first and only exact-main execution of the
/// default-metallib bootstrap-repair launcher. Active validation, secure fetch,
/// root 39, the isolated checkpoint suites, Metal 44, maintained runtime, and
/// tokenizer compatibility all passed. The launcher then rejected a passing
/// predecessor log before inspecting the same-job metallib or building the
/// Stage-2 test bundle: a case-insensitive, unbounded `failed` alternative
/// matched `testFailedAttemptObservationIsExactExhaustedAndPure`.
///
/// Workflow failure and Stage-2 test disposition are deliberately separate.
/// No Stage-2 test started, failed, passed, or skipped; no repair receipt was
/// emitted. This observation does not retry the consumed execution, mutate the
/// launcher, publish an artifact, or authorize Stage 3.
public struct
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationV1:
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
        PrimeNativeDecoderStage2BootstrapFailureRepositoryIdentityV1
    public let observedSourceBindings:
        [PrimeNativeDecoderStage2BootstrapFailureSourceIdentityV1]
    public let runIdentity:
        PrimeNativeDecoderStage2BootstrapFailureRunIdentityV1
    public let activeRootJob:
        PrimeNativeDecoderStage2BootstrapFailureJobObservationV1
    public let reviewedMainJob:
        PrimeNativeDecoderStage2BootstrapFailureJobObservationV1
    public let runnerToolchain:
        PrimeNativeDecoderStage2BootstrapFailureRunnerToolchainV1
    public let activeRootRawLog:
        PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1
    public let reviewedMainRawLog:
        PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1
    public let secureFetchStepRawLog:
        PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1
    public let focusedContractsStepRawLog:
        PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1
    public let liveStage2StepRawLog:
        PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1
    public let rawLogArchive:
        PrimeNativeDecoderStage2BootstrapFailureLogArchiveIdentityV1
    public let predecessorBoundary:
        PrimeNativeDecoderStage2BootstrapFailurePredecessorBoundaryV1
    public let launcherFailureBoundary:
        PrimeNativeDecoderStage2BootstrapFailureLauncherBoundaryV1
    public let artifactBoundary:
        PrimeNativeDecoderStage2BootstrapFailureArtifactBoundaryV1
    public let authorityCeiling:
        PrimeNativeDecoderStage2BootstrapFailureAuthorityCeilingV1
    public let status: String
    public let orderedRequiredSeparateActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_repair_execution_failure_observation_v1",
        observationKind:
            "exact_main_stage2_metallib_bootstrap_repair_launcher_preflight_false_positive_observation",
        predecessorAuthorityID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_repair_authority_v1",
        predecessorAuthorityCanonicalSHA256:
            "2c397195129a550817996f8914c036ae39ede13d5c67186fe0c74a2daf99f7de",
        repositoryIdentity:
            PrimeNativeDecoderStage2BootstrapFailureRepositoryIdentityV1(
                repository: "Ergentics/ergentics-prime",
                pullRequestNumber: 87,
                ref: "refs/heads/main",
                revision: "6b5233ae0589de539e91f613e7990de3ca5b5833",
                orderedParentRevisions: [
                    "8504f0af692e19d3337cec00f2c624537bc7386a",
                    "cf93879f650f1708e51478cc630ac9a753226471",
                ],
                tree: "8d8944b8b73547c97822b50e06da895a1fb29f1f",
                reviewedHeadRevision:
                    "cf93879f650f1708e51478cc630ac9a753226471",
                reviewedHeadTree:
                    "8d8944b8b73547c97822b50e06da895a1fb29f1f",
                mergedAt: "2026-08-11T22:59:38Z",
                historyPreservingTwoParentMergeObserved: true,
                mergeTreeEqualsReviewedHeadTree: true,
                mergeCommitSignatureVerified: true,
                mergeCommitSignatureReason: "valid",
                mergeCommitSignatureVerifiedAt: "2026-08-11T23:42:09Z",
                exactMainRefStillMatchedAtAudit: true,
                embeddedSourceIdentitySHA256:
                    "bdb0a217ec36611373ed7b25b982d78ee97f9f82d9ab274507978ab728194c2d"),
        observedSourceBindings: [
            source(
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                "100755", "ab69f596f6b77ac51a5ccbbb3f8ad95c610308a5",
                345_093,
                "d92e5dc58964a6122c75590033993b905b90fce2a7f96598d9096f8cfde85df4",
                "exact_consumed_root39_gate"),
            source(
                ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                "100755", "fd339c3819059050dcd31112023e169e22f9fbac",
                40_231,
                "a7d363ebe108aedaed1a83bc79429e87e60f5a1f9d3b992704b5a4617add9367",
                "exact_failed_launcher_and_false_positive_guard"),
            source(
                ".github/workflows/prime-active-root-quarantine.yml",
                "100644", "b3c943d2bce9fd6d8b32dcd885fc67768760327f",
                44_168,
                "ec86bb83f812ab74cc6ce5b3aeb82d4dfbe68a5b67685a10d3c1ac691fa38bf2",
                "exact_failed_workflow_topology_and_order"),
            source(
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "100644", "1918a888588f70284d9601d4d4f1ee4c499f4b98",
                546,
                "43bc6d49e2650af55fcb728b0002d994ead0c4d63e12b85ef9d601d56fc5a1f5",
                "exact_consumed_embedded_source_identity"),
            source(
                "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthority.swift",
                "100644", "b1c07a407f05fe7058c43656451f428ab794543e",
                51_385,
                "ecd9d25354e6e74fe8aeb8421fb5dcc92c1f51309b0ce1f2c2791423be435293",
                "consumed_predecessor_execution_authority"),
            source(
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityTests.swift",
                "100644", "f84eefb6428187ba4e08b3febf0c87256bd7788c",
                29_596,
                "f17aa6fedf3f460de44f706c9fe9d6ebb5cd9b690936d4fb5a5947765c8ddfd3",
                "consumed_predecessor_authority_test"),
            source(
                "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests.swift",
                "100644", "0ed3aa83f0dc16b0893655b9582985947509b919",
                16_695,
                "89ff93473e36ecc8a1fad38ef46c792ad0d12edee2508d91101d4df336cf7c2c",
                "passing_identifier_that_triggered_false_positive"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "100644", "9f05e5a17426f00adf9dad7b55d84057122e98f9",
                1_054,
                "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45",
                "unreached_stage2_validation_manifest"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                "100644", "8bf05edf1ea8789e7683e72fe756d79aaaa61320",
                645,
                "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225",
                "unreached_stage2_validation_lock"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
                "100644", "61e86200c508526ae2ab66e359d771841f7208db",
                30_214,
                "29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96",
                "unreached_exact_stage2_validation_test"),
        ],
        runIdentity: PrimeNativeDecoderStage2BootstrapFailureRunIdentityV1(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_544_702_133,
            runNumber: 71,
            runAttempt: 1,
            event: "push",
            headBranch: "main",
            headRevision: "6b5233ae0589de539e91f613e7990de3ca5b5833",
            actor: "psyop-archivist",
            triggeringActor: "psyop-archivist",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31544702133",
            createdAt: "2026-08-11T22:59:40Z",
            startedAt: "2026-08-11T22:59:40Z",
            terminalUpdatedAt: "2026-08-11T23:41:02Z",
            status: "completed",
            conclusion: "failure",
            checkSuiteID: 85_570_388_096,
            exactHeadPushRunCount: 1,
            previousAttemptURLWasNull: true,
            secondAttemptEndpointHTTPStatus: 404,
            rerunCount: 0,
            rerunObserved: false,
            rerunAuthorized: false),
        activeRootJob: job(
            id: 93_954_592_456,
            name: "First-party MLX / active-root quarantine",
            startedAt: "2026-08-11T22:59:43Z",
            completedAt: "2026-08-11T23:02:04Z",
            conclusion: "success",
            runnerLabel: "macos-15",
            runnerID: 1_000_001_697,
            runnerName: "GitHub Actions 1000001697",
            steps: [
                step(1, "Set up job", "2026-08-11T22:59:43Z", "2026-08-11T22:59:43Z", "success"),
                step(2, "Check out the exact Prime revision", "2026-08-11T22:59:43Z", "2026-08-11T22:59:47Z", "success"),
                step(3, "Validate active metadata and preserved history", "2026-08-11T22:59:47Z", "2026-08-11T23:00:13Z", "success"),
                step(4, "Parse the changed Swift contracts without dependencies", "2026-08-11T23:00:13Z", "2026-08-11T23:00:19Z", "success"),
                step(5, "Validate isolated Latin capture and observation contracts", "2026-08-11T23:00:19Z", "2026-08-11T23:02:00Z", "success"),
                step(6, "Record the authority ceiling", "2026-08-11T23:02:00Z", "2026-08-11T23:02:00Z", "success"),
                step(7, "Complete job", "2026-08-11T23:02:00Z", "2026-08-11T23:02:01Z", "success"),
            ]),
        reviewedMainJob: job(
            id: 93_955_091_811,
            name: "Reviewed main / focused source contracts",
            startedAt: "2026-08-11T23:02:07Z",
            completedAt: "2026-08-11T23:41:01Z",
            conclusion: "failure",
            runnerLabel: "macos-26",
            runnerID: 1_000_001_698,
            runnerName: "GitHub Actions 1000001698",
            steps: [
                step(1, "Set up job", "2026-08-11T23:02:08Z", "2026-08-11T23:02:08Z", "success"),
                step(2, "Record the hosted Apple toolchain", "2026-08-11T23:02:08Z", "2026-08-11T23:02:11Z", "success"),
                step(3, "Check out reviewed main exactly", "2026-08-11T23:02:11Z", "2026-08-11T23:02:14Z", "success"),
                step(4, "Fetch the exact private dependency without evaluating Prime", "2026-08-11T23:02:14Z", "2026-08-11T23:02:23Z", "success"),
                step(5, "Compile and run the focused contracts without a credential", "2026-08-11T23:02:23Z", "2026-08-11T23:22:50Z", "success"),
                step(6, "Run the Prime-owned decoder on live Metal", "2026-08-11T23:22:50Z", "2026-08-11T23:40:53Z", "failure"),
                step(7, "Complete job", "2026-08-11T23:40:53Z", "2026-08-11T23:40:54Z", "success"),
            ],
            annotationLine: 74_946,
            annotationMessage: "Process completed with exit code 2."),
        runnerToolchain:
            PrimeNativeDecoderStage2BootstrapFailureRunnerToolchainV1(
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
            "sealed_raw_active_job_log", 234_526, 1_749,
            "4f8f50aa9bc9df36a4389e2d87b0eb91baed8ebf7761cb54729688ca3656e7e5",
            "2026-08-11T22:59:43.7017210Z",
            "2026-08-11T23:02:00.7913460Z"),
        reviewedMainRawLog: rawLog(
            "sealed_raw_reviewed_job_log", 10_245_450, 78_438,
            "53a5f1f178e1f6d46a8b14aecca09b95b79fc9121fc9f3c3a1985528e5b6efec",
            "2026-08-11T23:02:08.0443390Z",
            "2026-08-11T23:40:53.2108190Z"),
        secureFetchStepRawLog: rawLog(
            "sealed_raw_secure_fetch_step_log", 4_893, 54,
            "a9e9797d237f18227eac1e1a1d71c46fb6ff937637ef94383c89bc26acb34b2c",
            "2026-08-11T23:02:14.9735440Z",
            "2026-08-11T23:02:22.3121430Z"),
        focusedContractsStepRawLog: rawLog(
            "sealed_raw_focused_contracts_step_log", 344_155, 3_350,
            "6858e8f204000409cbbbbb023a667c57e1684fca8280ea43f693f3457e18de43",
            "2026-08-11T23:02:23.5114790Z",
            "2026-08-11T23:22:50.3601420Z"),
        liveStage2StepRawLog: rawLog(
            "sealed_raw_metal_runtime_tokenizer_stage2_step_log",
            9_890_254, 74_946,
            "b122f61be5b1811176ce6a69878ac1693de1c3ee2e049f6444c5f8892ca9cb3b",
            "2026-08-11T23:22:50.6112880Z",
            "2026-08-11T23:40:53.1818180Z"),
        rawLogArchive:
            PrimeNativeDecoderStage2BootstrapFailureLogArchiveIdentityV1(
                byteCount: 1_348_689,
                sha256:
                    "54a7d35df9485108b3f084fc5508bdc5887b8dccb89beee2ce1fa0a6c048bd17",
                memberCount: 18,
                uncompressedByteCount: 20_961_389,
                repeatedDownloadsWereByteIdentical: true,
                memberTimestampsAreDOSZero: true,
                runtimeReceiptMemberTimestamp:
                    "2026-08-11T23:34:35.1124100Z",
                runtimeReceiptAggregateTimestamp:
                    "2026-08-11T23:34:35.1125840Z",
                tokenizerReceiptMemberTimestamp:
                    "2026-08-11T23:40:51.1581230Z",
                tokenizerReceiptAggregateTimestamp:
                    "2026-08-11T23:40:51.1582650Z",
                stage2DiagnosticMemberTimestamp:
                    "2026-08-11T23:40:53.1705710Z",
                stage2DiagnosticAggregateTimestamp:
                    "2026-08-11T23:40:53.1706100Z",
                stage2ExitMemberTimestamp:
                    "2026-08-11T23:40:53.1818180Z",
                stage2ExitAggregateTimestamp:
                    "2026-08-11T23:40:53.1818210Z",
                members: [
                    member("0_Reviewed main _ focused source contracts.txt", 10_245_450, 78_438, "53a5f1f178e1f6d46a8b14aecca09b95b79fc9121fc9f3c3a1985528e5b6efec"),
                    member("1_First-party MLX _ active-root quarantine.txt", 234_526, 1_749, "4f8f50aa9bc9df36a4389e2d87b0eb91baed8ebf7761cb54729688ca3656e7e5"),
                    member("First-party MLX _ active-root quarantine/1_Set up job.txt", 1_681, 28, "70cd1e8ecbcf59af5b35a64e12a6b2e7a2e2ec6b1cb73c40d2233aba32c761d9"),
                    member("First-party MLX _ active-root quarantine/2_Check out the exact Prime revision.txt", 3_054, 36, "085bf9e2883684ea570718fb9467be425c1c9eca5ca2b56d47bea7a59479fd17"),
                    member("First-party MLX _ active-root quarantine/3_Validate active metadata and preserved history.txt", 706, 8, "a849fe3d99e6019e2c4b3d62361289575a315d8f63c944b2ef01f941b05bb6c1"),
                    member("First-party MLX _ active-root quarantine/4_Parse the changed Swift contracts without dependencies.txt", 13_599, 101, "be027bbaabcce44f629e998eb6dcf63385f26b91788e31c841e62e1f945f5d08"),
                    member("First-party MLX _ active-root quarantine/5_Validate isolated Latin capture and observation contracts.txt", 196_243, 1_520, "5ad8b8e2160139f25d88a08128829d0489413c4a8447ff65ed43005d6d177394"),
                    member("First-party MLX _ active-root quarantine/6_Record the authority ceiling.txt", 19_200, 55, "7cbba69a98f9fa799ffd0b3265605801c86dc4ed0044670353031cda4bd3c50d"),
                    member("First-party MLX _ active-root quarantine/7_Complete job.txt", 61, 1, "5ba82e9d6be07aa06390c3eb36a1538a74e0a193ff0a245bec0f7490a48a5e05"),
                    member("First-party MLX _ active-root quarantine/system.txt", 601, 7, "01de0cc22c8ffac292fc2ad95560d498a184175cb61dfaee5cabf6d9d8414b08"),
                    member("Reviewed main _ focused source contracts/1_Set up job.txt", 1_680, 28, "0ac904ed4df53d9569d617d852f4d73464fff3067148fccd15046ad2e6a4e430"),
                    member("Reviewed main _ focused source contracts/2_Record the hosted Apple toolchain.txt", 1_279, 22, "1dccc0e3f02b1382b11f4ab56c1c0f7094bbd336e07aa726ea5ef68a23113b40"),
                    member("Reviewed main _ focused source contracts/3_Check out reviewed main exactly.txt", 3_146, 37, "af1e9ccdac5cb996dc4cec753203366724df09a4cc98f8ef07782e595d54a5ee"),
                    member("Reviewed main _ focused source contracts/4_Fetch the exact private dependency without evaluating Prime.txt", 4_893, 54, "a9e9797d237f18227eac1e1a1d71c46fb6ff937637ef94383c89bc26acb34b2c"),
                    member("Reviewed main _ focused source contracts/5_Compile and run the focused contracts without a credential.txt", 344_155, 3_350, "6858e8f204000409cbbbbb023a667c57e1684fca8280ea43f693f3457e18de43"),
                    member("Reviewed main _ focused source contracts/6_Run the Prime-owned decoder on live Metal.txt", 9_890_254, 74_946, "b122f61be5b1811176ce6a69878ac1693de1c3ee2e049f6444c5f8892ca9cb3b"),
                    member("Reviewed main _ focused source contracts/7_Complete job.txt", 61, 1, "087d532abdc793b8d3fe65c2d566fcb01fcf628c29208194706a6f3f9c20c7d9"),
                    member("Reviewed main _ focused source contracts/system.txt", 800, 8, "b11fd7c155b581510c3a606765ba10cb9d2bba6a0cbeaca5473437c1dd85fdee"),
                ]),
        predecessorBoundary:
            PrimeNativeDecoderStage2BootstrapFailurePredecessorBoundaryV1(
                activeRootGatePassed: true,
                dependencyFreeSwiftParsePassed: true,
                latinInvocationCount: 1,
                latinCompletedTestCount: 116,
                latinFailureCount: 0,
                latinSkipCount: 0,
                latinFinalSummaryOccurrenceCount: 2,
                securePrivateDependencyFetchInvocationCount: 1,
                securePrivateDependencyFetchCompletionCount: 1,
                securePrivateDependencyFetchRetryCount: 0,
                tlsVerificationBypassCount: 0,
                privateDependencyRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                privateDependencySubmoduleRevisions: [
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                    "0726ca922fc902c4c61ef9c27d94132be418e945",
                ],
                focusedRootInvocationCount: 1,
                focusedRootTestCount: 39,
                focusedRootFailureCount: 0,
                focusedRootSkipCount: 0,
                focusedRootSuccessSummaryOccurrenceCount: 2,
                isolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
                focusedWholeStepTestCount: 45,
                focusedWholeStepFailureCount: 0,
                focusedWholeStepSkipCount: 0,
                offendingPredecessorPackageTestCount: 2,
                offendingPredecessorPackageFailureCount: 0,
                offendingPredecessorPackageSkipCount: 0,
                offendingPredecessorMethodStartCount: 1,
                offendingPredecessorMethodPassCount: 1,
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
                freshMetallibByteCount: 6_292_716,
                freshMetallibSHA256:
                    "c77ef927122ee30ece82d983db66b4b83b5a04a3977cafb07f5940a7d0255255",
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
                    "5df550107d486819d132a66de422de8929ecba9a750aec528b2b1bfff9ccc90f",
                    "2026-08-11T23:34:35.1124100Z",
                    "2026-08-11T23:34:35.1125840Z",
                    "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
                    "bounded_mlx_runtime_initialization",
                    6_292_716,
                    "c77ef927122ee30ece82d983db66b4b83b5a04a3977cafb07f5940a7d0255255"),
                tokenizerInvocationCount: 1,
                tokenizerTestCount: 1,
                tokenizerFailureCount: 0,
                tokenizerSkipCount: 0,
                tokenizerReceipt: receipt(
                    "tokenizer_compatibility",
                    "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=",
                    7_182,
                    "ceba20f60d3fd6d1afc0eb56bc28372aa93d52b9f3fd53b8b506d9aeda8ed0dd",
                    "2026-08-11T23:40:51.1581230Z",
                    "2026-08-11T23:40:51.1582650Z",
                    "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1",
                    "tokenizer_functional_compatibility",
                    6_292_716,
                    "c77ef927122ee30ece82d983db66b4b83b5a04a3977cafb07f5940a7d0255255"),
                tokenizerExecutedRevision:
                    "6b5233ae0589de539e91f613e7990de3ca5b5833",
                tokenizerExecutedTree:
                    "8d8944b8b73547c97822b50e06da895a1fb29f1f",
                tokenizerEmbeddedSourceIdentitySHA256:
                    "bdb0a217ec36611373ed7b25b982d78ee97f9f82d9ab274507978ab728194c2d",
                predecessorLogInventoryCount: 10,
                emittedPredecessorReceiptCount: 2,
                completedPreStage2TestCount: 91,
                preStage2FailureCount: 0,
                preStage2SkipCount: 0),
        launcherFailureBoundary:
            PrimeNativeDecoderStage2BootstrapFailureLauncherBoundaryV1(
                workflowOutcome: "failure",
                stage2Disposition:
                    "launcher_preflight_false_positive_before_metallib_discovery_staging_build_or_test",
                failedJobStepNumber: 6,
                failedJobStepName:
                    "Run the Prime-owned decoder on live Metal",
                failedStepStartedAt: "2026-08-11T23:22:50Z",
                failedStepCompletedAt: "2026-08-11T23:40:53Z",
                launcherPath:
                    ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                launcherInvocationCount: 1,
                launcherCommand:
                    "bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                predecessorAuthorityID:
                    "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_repair_authority_v1",
                predecessorAuthorityCanonicalSHA256:
                    "2c397195129a550817996f8914c036ae39ede13d5c67186fe0c74a2daf99f7de",
                validationTestClass: "PrimeNativeDecoderTrainingTests",
                validationTestMethod:
                    "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                validationTestFilter:
                    "PrimeNativeDecoderTrainingTests/testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                intendedBuildCommand: "swift build --build-tests",
                guardCommand: "grep -Eiq",
                guardRegex:
                    "^Test (Case|Suite).*failed|^error:|skipped|Test skipped",
                guardCaseInsensitive: true,
                guardRegexUnboundedBeforeFailedSubstring: true,
                guardFailureSourceLine: 374,
                predecessorReceiptValidationSourceLine: 376,
                stage2MetallibDiscoverySourceLine: 383,
                stage2FreshPathAbsenceGuardSourceLine: 495,
                stage2WorkspaceCreationSourceLine: 501,
                matchedPredecessorLogPath:
                    "/Users/runner/work/_temp/prime-checkpoint-v2-io-execution-pure-tests.log",
                matchedPredecessorLogOrdinal: 4,
                completedPredecessorLogScanCountBeforeFalsePositive: 3,
                matchedPassingIdentifier:
                    "testFailedAttemptObservationIsExactExhaustedAndPure",
                matchedStartedLine:
                    "Test Case '-[PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests testFailedAttemptObservationIsExactExhaustedAndPure]' started.",
                matchedPassedLine:
                    "Test Case '-[PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests testFailedAttemptObservationIsExactExhaustedAndPure]' passed (0.860 seconds).",
                matchedStartedMemberTimestamp:
                    "2026-08-11T23:17:30.3633930Z",
                matchedStartedAggregateTimestamp:
                    "2026-08-11T23:17:30.3633940Z",
                matchedPassedMemberTimestamp:
                    "2026-08-11T23:17:30.3635720Z",
                matchedPassedAggregateTimestamp:
                    "2026-08-11T23:17:30.3635730Z",
                matchedIdentifierStartCount: 1,
                matchedIdentifierPassCount: 1,
                matchedPackageTestCount: 2,
                matchedPackageFailureCount: 0,
                matchedPackageSkipCount: 0,
                falsePositiveCause:
                    "case_insensitive_unbounded_failed_substring_matched_passed_test_identifier",
                failureClassification:
                    "predecessor_log_validation_false_positive_after_green_predecessors_before_stage2_metallib_discovery_or_build",
                exactDiagnostic:
                    "prime-native-decoder-stage2-metallib-bootstrap-repair: predecessor test log failed or skipped: /Users/runner/work/_temp/prime-checkpoint-v2-io-execution-pure-tests.log",
                diagnosticMemberTimestamp:
                    "2026-08-11T23:40:53.1705710Z",
                diagnosticAggregateTimestamp:
                    "2026-08-11T23:40:53.1706100Z",
                processExitCode: 2,
                exactExitMessage: "Process completed with exit code 2.",
                exitMemberTimestamp: "2026-08-11T23:40:53.1818180Z",
                exitAggregateTimestamp: "2026-08-11T23:40:53.1818210Z",
                predecessorReceiptValidationReached: false,
                sameJobFreshMetallibWasAvailableFromPredecessor: true,
                sameJobFreshMetallibWasInspectedByStage2Launcher: false,
                stage2RepairLauncherReachedFreshMetallibDiscovery: false,
                stage2MetallibDiscoveryCount: 0,
                stage2MetallibCandidateCount: 0,
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
                launcherClassifierFalsePositiveObserved: true,
                launcherSourceMutationPerformed: false),
        artifactBoundary:
            PrimeNativeDecoderStage2BootstrapFailureArtifactBoundaryV1(
                actionsArtifactsEndpoint:
                    "https://api.github.com/repos/Ergentics/ergentics-prime/actions/runs/31544702133/artifacts",
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
            PrimeNativeDecoderStage2BootstrapFailureAuthorityCeilingV1(
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
            "FAIL_exact_main_stage2_launcher_preflight_false_positive_no_stage2_test_no_receipt_no_rerun_no_actions_or_stage2_artifact_no_downstream_authority",
        orderedRequiredSeparateActions: [
            "retire_consumed_stage2_live_invocation_without_rerun",
            "preserve_failed_launcher_source_and_immutable_evidence",
            "separately_authorize_bounded_predecessor_log_classifier_repair",
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
    ) -> PrimeNativeDecoderStage2BootstrapFailureSourceIdentityV1 {
        PrimeNativeDecoderStage2BootstrapFailureSourceIdentityV1(
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
    ) -> PrimeNativeDecoderStage2BootstrapFailureJobStepV1 {
        PrimeNativeDecoderStage2BootstrapFailureJobStepV1(
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
        steps: [PrimeNativeDecoderStage2BootstrapFailureJobStepV1],
        annotationLine: Int = 0,
        annotationMessage: String = ""
    ) -> PrimeNativeDecoderStage2BootstrapFailureJobObservationV1 {
        PrimeNativeDecoderStage2BootstrapFailureJobObservationV1(
            id: id,
            name: name,
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31544702133/job/\(id)",
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
    ) -> PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1 {
        PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1(
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
    ) -> PrimeNativeDecoderStage2BootstrapFailureArchiveMemberIdentityV1 {
        PrimeNativeDecoderStage2BootstrapFailureArchiveMemberIdentityV1(
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
    ) -> PrimeNativeDecoderStage2BootstrapFailureReceiptIdentityV1 {
        PrimeNativeDecoderStage2BootstrapFailureReceiptIdentityV1(
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
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationError
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
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairAuthorityV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            guard predecessorAuthorityID == predecessor.authorityID,
                  predecessorAuthorityCanonicalSHA256
                    == PrimeSHA256.hexDigest(
                        of: try predecessor.canonicalData()) else {
                throw
                    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationError
                        .contractDrift
            }
        } catch {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationError
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
              predecessorBoundary.securePrivateDependencyFetchRetryCount == 0,
              predecessorBoundary.tlsVerificationBypassCount == 0,
              predecessorBoundary.focusedRootInvocationCount == 1,
              predecessorBoundary.focusedRootTestCount == 39,
              predecessorBoundary.focusedRootFailureCount == 0,
              predecessorBoundary.focusedRootSkipCount == 0,
              predecessorBoundary.isolatedCheckpointGroupTestCounts
                == [1, 1, 2, 2],
              predecessorBoundary.focusedWholeStepTestCount
                == predecessorBoundary.focusedRootTestCount
                    + predecessorBoundary.isolatedCheckpointGroupTestCounts
                        .reduce(0, +),
              predecessorBoundary.focusedWholeStepTestCount == 45,
              predecessorBoundary.focusedWholeStepFailureCount == 0,
              predecessorBoundary.focusedWholeStepSkipCount == 0,
              predecessorBoundary.offendingPredecessorPackageTestCount == 2,
              predecessorBoundary.offendingPredecessorPackageFailureCount == 0,
              predecessorBoundary.offendingPredecessorPackageSkipCount == 0,
              predecessorBoundary.offendingPredecessorMethodStartCount == 1,
              predecessorBoundary.offendingPredecessorMethodPassCount == 1,
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
              predecessorBoundary.completedPreStage2TestCount == 91,
              predecessorBoundary.preStage2FailureCount == 0,
              predecessorBoundary.preStage2SkipCount == 0,
              failure.workflowOutcome == runIdentity.conclusion,
              failure.stage2Disposition
                == "launcher_preflight_false_positive_before_metallib_discovery_staging_build_or_test",
              failure.failedJobStepNumber == 6,
              failure.launcherInvocationCount == 1,
              failure.predecessorAuthorityID == predecessorAuthorityID,
              failure.predecessorAuthorityCanonicalSHA256
                == predecessorAuthorityCanonicalSHA256,
              failure.guardCommand == "grep -Eiq",
              failure.guardCaseInsensitive,
              failure.guardRegexUnboundedBeforeFailedSubstring,
              failure.guardFailureSourceLine == 374,
              failure.predecessorReceiptValidationSourceLine == 376,
              failure.stage2MetallibDiscoverySourceLine == 383,
              failure.stage2FreshPathAbsenceGuardSourceLine == 495,
              failure.stage2WorkspaceCreationSourceLine == 501,
              failure.matchedPredecessorLogOrdinal == 4,
              failure.completedPredecessorLogScanCountBeforeFalsePositive == 3,
              failure.matchedPassingIdentifier.lowercased()
                .contains("failed"),
              failure.matchedIdentifierStartCount == 1,
              failure.matchedIdentifierPassCount == 1,
              failure.matchedPackageTestCount == 2,
              failure.matchedPackageFailureCount == 0,
              failure.matchedPackageSkipCount == 0,
              failure.falsePositiveCause
                == "case_insensitive_unbounded_failed_substring_matched_passed_test_identifier",
              failure.failureClassification
                == "predecessor_log_validation_false_positive_after_green_predecessors_before_stage2_metallib_discovery_or_build",
              failure.processExitCode == 2,
              !failure.predecessorReceiptValidationReached,
              failure.sameJobFreshMetallibWasAvailableFromPredecessor,
              !failure.sameJobFreshMetallibWasInspectedByStage2Launcher,
              !failure.stage2RepairLauncherReachedFreshMetallibDiscovery,
              failure.stage2MetallibDiscoveryCount == 0,
              failure.stage2MetallibCandidateCount == 0,
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
              failure.launcherClassifierFalsePositiveObserved,
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
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapRepairExecutionFailureObservationError
                    .contractDrift
        }
    }

    private static func validSourceIdentity(
        _ identity: PrimeNativeDecoderStage2BootstrapFailureSourceIdentityV1
    ) -> Bool {
        ["100644", "100755"].contains(identity.gitMode)
            && identity.gitBlob.utf8.count == 40
            && identity.byteCount > 0
            && identity.sha256.utf8.count == 64
            && !identity.claimScope.isEmpty
    }

    private static func validRawLog(
        _ log: PrimeNativeDecoderStage2BootstrapFailureRawLogIdentityV1
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
        _ receipt: PrimeNativeDecoderStage2BootstrapFailureReceiptIdentityV1
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
