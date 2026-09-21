// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionSourceIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
    public let claimScope: String
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionRepositoryIdentityV1:
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
    public let exactFirstParentChangedPaths: [String]
    public let exactFirstParentChangedStatuses: [String]
    public let mergedAt: String
    public let historyPreservingTwoParentMergeObserved: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
    public let mergeCommitSignatureVerified: Bool
    public let mergeCommitSignatureReason: String
    public let mergeCommitSignatureVerifiedAt: String
    public let exactMainRefStillMatchedAtAudit: Bool
    public let exactMainRefAuditedAt: String
    public let embeddedSourceIdentitySHA256: String
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionRunIdentityV1:
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

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionJobStepV1:
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

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionJobV1:
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
    public let orderedSteps: [PrimeNativeDecoderStage2EvidenceRepairExecutionJobStepV1]
    public let checkAnnotationCount: Int
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionToolchainV1:
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

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1:
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

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionArchiveMemberV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionLogArchiveV1:
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
    public let members: [PrimeNativeDecoderStage2EvidenceRepairExecutionArchiveMemberV1]
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionReceiptIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let scope: String
    public let prefix: String
    public let count: Int
    public let rawJSONByteCount: Int
    public let rawJSONSHA256: String
    public let canonicalJSONByteCount: Int
    public let canonicalJSONSHA256: String
    public let rawJSONWasCanonical: Bool
    public let receiptLineByteCount: Int
    public let receiptLineSHA256: String
    public let memberTimestamp: String
    public let aggregateTimestamp: String
    public let receiptOrEvidenceID: String
    public let statusOrOutcomeKind: String
    public let outcomeEstablished: Bool
    public let metallibByteCount: Int
    public let metallibSHA256: String
    public let loadedMetallibIdentityIndependentlyObserved: Bool
    public let metallibArtifactProvenanceEstablished: Bool
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionSecureFetchBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let invocationCount: Int
    public let completionCount: Int
    public let command: String
    public let workflowBlockSHA256: String
    public let workflowAuthoredRetryCount: Int
    public let separateRetryStepCount: Int
    public let gitInternalSubmoduleRetryCount: Int
    public let mlxSubmoduleCloneAttemptCount: Int
    public let mlxCSubmoduleCloneAttemptCount: Int
    public let gitSubmoduleTLSFailureCount: Int
    public let tlsVerificationBypassCount: Int
    public let customCAInstallationCount: Int
    public let privateDependencyRevision: String
    public let privateDependencySubmoduleRevisions: [String]
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionPredecessorBoundaryV1:
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
    public let focusedRootInvocationCount: Int
    public let focusedRootTestCount: Int
    public let focusedRootFailureCount: Int
    public let focusedRootSkipCount: Int
    public let focusedRootSuccessSummaryOccurrenceCount: Int
    public let isolatedCheckpointGroupTestCounts: [Int]
    public let focusedWholeStepTestCount: Int
    public let focusedWholeStepFailureCount: Int
    public let focusedWholeStepSkipCount: Int
    public let liveInvocationSequence: [String]
    public let liveInvocationCounts: [Int]
    public let metallibBuildInvocationCount: Int
    public let metallibBuildCompletionCount: Int
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
    public let runtimeReceipt: PrimeNativeDecoderStage2EvidenceRepairExecutionReceiptIdentityV1
    public let tokenizerInvocationCount: Int
    public let tokenizerTestCount: Int
    public let tokenizerFailureCount: Int
    public let tokenizerSkipCount: Int
    public let tokenizerReceipt: PrimeNativeDecoderStage2EvidenceRepairExecutionReceiptIdentityV1
    public let tokenizerExecutedRevision: String
    public let tokenizerExecutedTree: String
    public let tokenizerEmbeddedSourceIdentitySHA256: String
    public let validatedPredecessorLogCount: Int
    public let validatedPredecessorReceiptCount: Int
    public let predecessorArtifactSnapshotCount: Int
    public let predecessorArtifactRevalidationCountAfterXCTest: Int
    public let completedPreStage2TestCount: Int
    public let preStage2FailureCount: Int
    public let preStage2SkipCount: Int
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionMetalCaptureBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let fixedLogPath: String
    public let initialAbsenceRequired: Bool
    public let captureInvocationCount: Int
    public let teeInvocationCount: Int
    public let pipelineStatusElementCount: Int
    public let launcherPipelineStatus: Int
    public let teePipelineStatus: Int
    public let pipelineStatusCapturedImmediatelyAfterPipeline: Bool
    public let errexitRestoredImmediatelyAfterStatusCapture: Bool
    public let logRegularFileRequired: Bool
    public let logSymbolicLinkForbidden: Bool
    public let logNonemptyRequired: Bool
    public let logRequiredHardLinkCount: Int
    public let frozenLogPermissionMode: String
    public let identityLinePrefix: String
    public let exactDynamicIdentityLine: String
    public let fullOutputIdentityPrefixCount: Int
    public let fullOutputExactIdentityCount: Int
    public let xctestOnlyLogPath: String
    public let xctestOnlyIdentityPrefixCount: Int
    public let xctestOnlyExactIdentityCount: Int
    public let metalLauncherSourceChanged: Bool
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionStage2BoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let launcherPath: String
    public let launcherInvocationCount: Int
    public let launcherCommand: String
    public let stepNumber: Int
    public let stepName: String
    public let stepStartedAt: String
    public let stepCompletedAt: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let classifierCommand: String
    public let classifierRegex: String
    public let acceptanceFixtureCount: Int
    public let acceptanceFixtureMatchCount: Int
    public let rejectionFixtureCount: Int
    public let rejectionFixtureMatchCount: Int
    public let scannedLogCount: Int
    public let predecessorClassifierPassed: Bool
    public let freshSourceCandidateCount: Int
    public let freshSourceRegularFileIdentityValidated: Bool
    public let metallibIdentityInventoryCount: Int
    public let byteIdenticalComparisonCount: Int
    public let byteCountEqualityCount: Int
    public let sha256EqualityCount: Int
    public let metalBundleCandidateCount: Int
    public let runtimeBundleCandidateCount: Int
    public let tokenizerBundleCandidateCount: Int
    public let runtimeReceiptIdentityMatchCount: Int
    public let tokenizerReceiptIdentityMatchCount: Int
    public let sourceBoundEvidenceEstablished: Bool
    public let loadedMetallibPathInferred: Bool
    public let independentlyObservedLoadedMetallibIdentityEstablished: Bool
    public let buildCommand: String
    public let buildCommandCount: Int
    public let metallibBuiltByThisLauncher: Bool
    public let stagedDestinationCount: Int
    public let stagedCopyCount: Int
    public let stagedPermissionMode: String
    public let stagedRelativePaths: [String]
    public let stagedCopiesByteIdentical: Bool
    public let directXCTestInvocationCount: Int
    public let validationTestClass: String
    public let validationTestMethod: String
    public let validationTestFilter: String
    public let testStartCount: Int
    public let testPassCount: Int
    public let testFailureCount: Int
    public let testSkipCount: Int
    public let privateWorkingDirectoryEmptyBeforeAndAfter: Bool
    public let receipt: PrimeNativeDecoderStage2EvidenceRepairExecutionReceiptIdentityV1
    public let trustedCompletedTestCount: Int
    public let mechanicsExecutionEstablished: Bool
    public let defaultMetallibBootstrapRepairEstablished: Bool
    public let freshMetallibEvidenceSurfaceRepairEstablished: Bool
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionArtifactBoundaryV1:
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
    public let stage2ReceiptEmitted: Bool
    public let checkpointArtifactCreated: Bool
    public let checkpointArtifactUploaded: Bool
    public let checkpointArtifactRetained: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
}

public struct PrimeNativeDecoderStage2EvidenceRepairExecutionAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let predecessorRepairAuthorityConsumed: Bool
    public let predecessorRepairAuthorityExhausted: Bool
    public let successObservationAuthorizesNothing: Bool
    public let consumedStage2LiveInvocationRetirementRequired: Bool
    public let launcherSourceMustRemainPreservedForAudit: Bool
    public let stage3RemainsBlocked: Bool
    public let rerunAuthorized: Bool
    public let retryAuthorized: Bool
    public let replacementRunAuthorized: Bool
    public let workflowMutationBeyondRequiredRetirementAuthorized: Bool
    public let launcherMutationAuthorized: Bool
    public let tlsVerificationBypassAuthorized: Bool
    public let credentialMutationAuthorized: Bool
    public let newMetallibBuildAuthorized: Bool
    public let additionalStage2ExecutionAuthorized: Bool
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

/// Append-only observation of the first and only exact-main execution under
/// the bounded fresh-metallib evidence-surface repair authority. Root 43,
/// Metal 44, maintained runtime, tokenizer compatibility, and the one direct
/// Stage-2 mechanics test all passed. The fixed full-output log captured the
/// fresh identity once while the xctest-only Metal log correctly contained no
/// identity line; the same bytes and SHA-256 were then cross-bound through the
/// fresh file, two Metal bundles, runtime receipt, and tokenizer receipt.
///
/// The receipt does not independently establish which metallib MLX loaded and
/// grants no retry, artifact, checkpoint, training, product, publication, or
/// Stage-3 authority.
public struct
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let repositoryIdentity: PrimeNativeDecoderStage2EvidenceRepairExecutionRepositoryIdentityV1
    public let observedSourceBindings: [PrimeNativeDecoderStage2EvidenceRepairExecutionSourceIdentityV1]
    public let runIdentity: PrimeNativeDecoderStage2EvidenceRepairExecutionRunIdentityV1
    public let activeRootJob: PrimeNativeDecoderStage2EvidenceRepairExecutionJobV1
    public let reviewedMainJob: PrimeNativeDecoderStage2EvidenceRepairExecutionJobV1
    public let runnerToolchain: PrimeNativeDecoderStage2EvidenceRepairExecutionToolchainV1
    public let activeRootRawLog: PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1
    public let reviewedMainRawLog: PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1
    public let secureFetchStepRawLog: PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1
    public let focusedContractsStepRawLog: PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1
    public let liveStage2StepRawLog: PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1
    public let rawLogArchive: PrimeNativeDecoderStage2EvidenceRepairExecutionLogArchiveV1
    public let secureFetchBoundary: PrimeNativeDecoderStage2EvidenceRepairExecutionSecureFetchBoundaryV1
    public let predecessorBoundary: PrimeNativeDecoderStage2EvidenceRepairExecutionPredecessorBoundaryV1
    public let metalCaptureBoundary: PrimeNativeDecoderStage2EvidenceRepairExecutionMetalCaptureBoundaryV1
    public let stage2Boundary: PrimeNativeDecoderStage2EvidenceRepairExecutionStage2BoundaryV1
    public let artifactBoundary: PrimeNativeDecoderStage2EvidenceRepairExecutionArtifactBoundaryV1
    public let authorityCeiling: PrimeNativeDecoderStage2EvidenceRepairExecutionAuthorityCeilingV1
    public let status: String
    public let orderedRequiredSeparateActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_execution_observation_v1",
        observationKind:
            "exact_main_stage2_fresh_metallib_evidence_surface_repair_execution_success_observation",
        predecessorAuthorityID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_authority_v1",
        predecessorAuthorityCanonicalSHA256:
            "bc6aa0630196e1c02814834ffb3f8502ae51bcdc751ecbc37cb9bb5dd22c502a",
        repositoryIdentity:
            PrimeNativeDecoderStage2EvidenceRepairExecutionRepositoryIdentityV1(
                repository: "Ergentics/ergentics-prime",
                pullRequestNumber: 91,
                ref: "refs/heads/main",
                revision: "5c1b7c4f7a7689cba53ded11dd8b12a0f1a3229d",
                orderedParentRevisions: [
                    "075922cec8361c0085d5b2c6d000828e3c0bfc35",
                    "f2d04016463133854995d2523770bb19cfe2eef4",
                ],
                tree: "d673bcbfa13b660b7fe898dc127186e8da1aaa6b",
                reviewedHeadRevision:
                    "f2d04016463133854995d2523770bb19cfe2eef4",
                reviewedHeadTree:
                    "d673bcbfa13b660b7fe898dc127186e8da1aaa6b",
                exactFirstParentChangedPaths: [
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                    ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                    ".github/workflows/prime-active-root-quarantine.yml",
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift",
                    "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift",
                ],
                exactFirstParentChangedStatuses: [
                    "M", "M", "M", "M", "A", "A",
                ],
                mergedAt: "2026-08-12T05:00:12Z",
                historyPreservingTwoParentMergeObserved: true,
                mergeTreeEqualsReviewedHeadTree: true,
                mergeCommitSignatureVerified: true,
                mergeCommitSignatureReason: "valid",
                mergeCommitSignatureVerifiedAt: "2026-08-12T05:01:03Z",
                exactMainRefStillMatchedAtAudit: true,
                exactMainRefAuditedAt: "2026-08-12T05:57:23Z",
                embeddedSourceIdentitySHA256:
                    "2e9a9da262a8c6a6b3e12b2d71e42627fc46bbc6bffd60c7791d5a5812ce58d7"),
        observedSourceBindings: sourceBindings,
        runIdentity:
            PrimeNativeDecoderStage2EvidenceRepairExecutionRunIdentityV1(
                workflowID: 329_017_041,
                workflowName: "Prime active-root quarantine",
                workflowPath:
                    ".github/workflows/prime-active-root-quarantine.yml",
                runID: 31_565_094_400,
                runNumber: 79,
                runAttempt: 1,
                event: "push",
                headBranch: "main",
                headRevision:
                    "5c1b7c4f7a7689cba53ded11dd8b12a0f1a3229d",
                actor: "psyop-archivist",
                triggeringActor: "psyop-archivist",
                url:
                    "https://github.com/Ergentics/ergentics-prime/actions/runs/31565094400",
                createdAt: "2026-08-12T05:00:18Z",
                startedAt: "2026-08-12T05:00:18Z",
                terminalUpdatedAt: "2026-08-12T05:51:30Z",
                status: "completed",
                conclusion: "success",
                checkSuiteID: 85_623_258_434,
                exactHeadPushRunCount: 1,
                previousAttemptURLWasNull: true,
                secondAttemptEndpointHTTPStatus: 404,
                rerunCount: 0,
                rerunObserved: false,
                rerunAuthorized: false),
        activeRootJob:
            job(
                id: 94_015_181_778,
                name: "First-party MLX / active-root quarantine",
                url:
                    "https://github.com/Ergentics/ergentics-prime/actions/runs/31565094400/job/94015181778",
                startedAt: "2026-08-12T05:00:21Z",
                completedAt: "2026-08-12T05:03:04Z",
                runnerLabel: "macos-15",
                runnerID: 1_000_001_709,
                runnerName: "GitHub Actions 1000001709",
                steps: [
                    step(1, "Set up job", "2026-08-12T05:00:22Z", "2026-08-12T05:00:22Z"),
                    step(2, "Check out the exact Prime revision", "2026-08-12T05:00:22Z", "2026-08-12T05:00:29Z"),
                    step(3, "Validate active metadata and preserved history", "2026-08-12T05:00:29Z", "2026-08-12T05:00:58Z"),
                    step(4, "Parse the changed Swift contracts without dependencies", "2026-08-12T05:00:58Z", "2026-08-12T05:01:05Z"),
                    step(5, "Validate isolated Latin capture and observation contracts", "2026-08-12T05:01:05Z", "2026-08-12T05:03:01Z"),
                    step(6, "Record the authority ceiling", "2026-08-12T05:03:01Z", "2026-08-12T05:03:01Z"),
                    step(7, "Complete job", "2026-08-12T05:03:01Z", "2026-08-12T05:03:03Z"),
                ]),
        reviewedMainJob:
            job(
                id: 94_015_642_394,
                name: "Reviewed main / focused source contracts",
                url:
                    "https://github.com/Ergentics/ergentics-prime/actions/runs/31565094400/job/94015642394",
                startedAt: "2026-08-12T05:03:07Z",
                completedAt: "2026-08-12T05:51:29Z",
                runnerLabel: "macos-26",
                runnerID: 1_000_001_710,
                runnerName: "GitHub Actions 1000001710",
                steps: [
                    step(1, "Set up job", "2026-08-12T05:03:08Z", "2026-08-12T05:03:08Z"),
                    step(2, "Record the hosted Apple toolchain", "2026-08-12T05:03:08Z", "2026-08-12T05:03:11Z"),
                    step(3, "Check out reviewed main exactly", "2026-08-12T05:03:11Z", "2026-08-12T05:03:14Z"),
                    step(4, "Fetch the exact private dependency without evaluating Prime", "2026-08-12T05:03:14Z", "2026-08-12T05:03:24Z"),
                    step(5, "Compile and run the focused contracts without a credential", "2026-08-12T05:03:24Z", "2026-08-12T05:27:49Z"),
                    step(6, "Run the Prime-owned decoder on live Metal", "2026-08-12T05:27:49Z", "2026-08-12T05:51:16Z"),
                    step(7, "Complete job", "2026-08-12T05:51:16Z", "2026-08-12T05:51:17Z"),
                ]),
        runnerToolchain:
            PrimeNativeDecoderStage2EvidenceRepairExecutionToolchainV1(
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
                exactPhysicalRunnerIdentityRecorded: false),
        activeRootRawLog:
            rawLog(
                "active_root_job_aggregate",
                238_922,
                "680fc1b1672db3ef0d2bab7d7e8599d6d176d3929d14aeeef4f03197cdc7cce4",
                1_761,
                "2026-08-12T05:00:22.1512790Z",
                "2026-08-12T05:03:01.2969920Z"),
        reviewedMainRawLog:
            rawLog(
                "reviewed_main_job_aggregate",
                10_294_957,
                "019f6ba8535ddaca21b49ecc289b91cb09679552cb597c99d634139646ff7c3a",
                78_905,
                "2026-08-12T05:03:08.0490020Z",
                "2026-08-12T05:51:16.9487730Z"),
        secureFetchStepRawLog:
            rawLog(
                "reviewed_main_secure_fetch_step_member",
                4_893,
                "457781579fa43d313886ca57c887fd5a42d828a6b97e33cec5fc682181d3caf7",
                54,
                "2026-08-12T05:03:14.9119340Z",
                "2026-08-12T05:03:23.3807710Z"),
        focusedContractsStepRawLog:
            rawLog(
                "reviewed_main_root43_focused_step_member",
                353_901,
                "c21ee98599a75671bfe125cf100a42d02131acedb0dd5265c050177d074e79ac",
                3_403,
                "2026-08-12T05:03:24.7564930Z",
                "2026-08-12T05:27:49.2085460Z"),
        liveStage2StepRawLog:
            rawLog(
                "reviewed_main_metal_runtime_tokenizer_stage2_step_member",
                9_930_010,
                "6327bf59a8f84557af8d9cc01f4274114e48e47238379139752bd2b94e3df583",
                75_360,
                "2026-08-12T05:27:49.6397190Z",
                "2026-08-12T05:51:16.9057860Z"),
        rawLogArchive:
            PrimeNativeDecoderStage2EvidenceRepairExecutionLogArchiveV1(
                byteCount: 1_357_752,
                sha256:
                    "02e8588ba5ac1190ce309cd1a7b92fc8fc04e383e5ffb101acb07df17590dfb3",
                memberCount: 18,
                uncompressedByteCount: 21_069_195,
                repeatedDownloadsWereByteIdentical: true,
                memberTimestampsAreDOSZero: true,
                members: archiveMembers),
        secureFetchBoundary:
            PrimeNativeDecoderStage2EvidenceRepairExecutionSecureFetchBoundaryV1(
                invocationCount: 1,
                completionCount: 1,
                command: "git -C \"$mlx_source\" submodule update --init --recursive",
                workflowBlockSHA256:
                    "ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847",
                workflowAuthoredRetryCount: 0,
                separateRetryStepCount: 0,
                gitInternalSubmoduleRetryCount: 0,
                mlxSubmoduleCloneAttemptCount: 1,
                mlxCSubmoduleCloneAttemptCount: 1,
                gitSubmoduleTLSFailureCount: 0,
                tlsVerificationBypassCount: 0,
                customCAInstallationCount: 0,
                privateDependencyRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                privateDependencySubmoduleRevisions: [
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                    "0726ca922fc902c4c61ef9c27d94132be418e945",
                ]),
        predecessorBoundary:
            PrimeNativeDecoderStage2EvidenceRepairExecutionPredecessorBoundaryV1(
                activeRootGatePassed: true,
                dependencyFreeSwiftParsePassed: true,
                latinInvocationCount: 1,
                latinCompletedTestCount: 116,
                latinFailureCount: 0,
                latinSkipCount: 0,
                latinFinalSummaryOccurrenceCount: 2,
                focusedRootInvocationCount: 1,
                focusedRootTestCount: 43,
                focusedRootFailureCount: 0,
                focusedRootSkipCount: 0,
                focusedRootSuccessSummaryOccurrenceCount: 2,
                isolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
                focusedWholeStepTestCount: 49,
                focusedWholeStepFailureCount: 0,
                focusedWholeStepSkipCount: 0,
                liveInvocationSequence: [
                    "metal", "maintained_runtime", "tokenizer", "stage2",
                ],
                liveInvocationCounts: [1, 1, 1, 1],
                metallibBuildInvocationCount: 1,
                metallibBuildCompletionCount: 1,
                freshMetallibCandidateCount: 1,
                freshMetallibByteCount: 6_292_732,
                freshMetallibSHA256:
                    "54b57ce3dea5c648cbee3096602cf51791033badb2fbbdc632741bb3b1b5f7d6",
                metalGroupTestCounts: [11, 14, 19],
                metalTestCount: 44,
                metalFailureCount: 0,
                metalSkipCount: 0,
                runtimeInvocationCount: 1,
                runtimeTestCount: 1,
                runtimeFailureCount: 0,
                runtimeSkipCount: 0,
                runtimeReceipt:
                    receipt(
                        scope: "maintained_runtime",
                        prefix: "PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=",
                        rawBytes: 6_853,
                        rawSHA:
                            "1e03e85dd25c553d46d181c148b8b45bb7e701498cb335f2a07b4596b32bb619",
                        lineBytes: 6_898,
                        lineSHA:
                            "aa8a9c7c670ab405a12d543b6c86f13deaf2621aa785c1dcb9b4344cb7f9b0ad",
                        memberTimestamp: "2026-08-12T05:40:20.0434590Z",
                        aggregateTimestamp: "2026-08-12T05:40:20.0439500Z",
                        id:
                            "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
                        status: "bounded_runtime_dependency_closure_established"),
                tokenizerInvocationCount: 1,
                tokenizerTestCount: 1,
                tokenizerFailureCount: 0,
                tokenizerSkipCount: 0,
                tokenizerReceipt:
                    receipt(
                        scope: "tokenizer_compatibility",
                        prefix: "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=",
                        rawBytes: 7_182,
                        rawSHA:
                            "102ccf73a7e4c527dfbdce70d52946e570f4c2677e50e189e0a41c82705baca7",
                        lineBytes: 7_235,
                        lineSHA:
                            "9ee3497157ebe20bab877722e750a4bcc9651df378f97fda2f4562fcd09bca24",
                        memberTimestamp: "2026-08-12T05:47:49.7845770Z",
                        aggregateTimestamp: "2026-08-12T05:47:49.7849520Z",
                        id:
                            "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1",
                        status:
                            "PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only"),
                tokenizerExecutedRevision:
                    "5c1b7c4f7a7689cba53ded11dd8b12a0f1a3229d",
                tokenizerExecutedTree:
                    "d673bcbfa13b660b7fe898dc127186e8da1aaa6b",
                tokenizerEmbeddedSourceIdentitySHA256:
                    "2e9a9da262a8c6a6b3e12b2d71e42627fc46bbc6bffd60c7791d5a5812ce58d7",
                validatedPredecessorLogCount: 11,
                validatedPredecessorReceiptCount: 2,
                predecessorArtifactSnapshotCount: 16,
                predecessorArtifactRevalidationCountAfterXCTest: 16,
                completedPreStage2TestCount: 95,
                preStage2FailureCount: 0,
                preStage2SkipCount: 0),
        metalCaptureBoundary:
            PrimeNativeDecoderStage2EvidenceRepairExecutionMetalCaptureBoundaryV1(
                fixedLogPath:
                    "$RUNNER_TEMP/prime-native-decoder-metal-full-output.log",
                initialAbsenceRequired: true,
                captureInvocationCount: 1,
                teeInvocationCount: 1,
                pipelineStatusElementCount: 2,
                launcherPipelineStatus: 0,
                teePipelineStatus: 0,
                pipelineStatusCapturedImmediatelyAfterPipeline: true,
                errexitRestoredImmediatelyAfterStatusCapture: true,
                logRegularFileRequired: true,
                logSymbolicLinkForbidden: true,
                logNonemptyRequired: true,
                logRequiredHardLinkCount: 1,
                frozenLogPermissionMode: "444",
                identityLinePrefix:
                    "Prime decoder Metal gate: metallib_sha256=",
                exactDynamicIdentityLine:
                    "Prime decoder Metal gate: metallib_sha256=54b57ce3dea5c648cbee3096602cf51791033badb2fbbdc632741bb3b1b5f7d6 metallib_bytes=6292732",
                fullOutputIdentityPrefixCount: 1,
                fullOutputExactIdentityCount: 1,
                xctestOnlyLogPath:
                    "$RUNNER_TEMP/prime-native-decoder-metal-tests.log",
                xctestOnlyIdentityPrefixCount: 0,
                xctestOnlyExactIdentityCount: 0,
                metalLauncherSourceChanged: false),
        stage2Boundary:
            PrimeNativeDecoderStage2EvidenceRepairExecutionStage2BoundaryV1(
                launcherPath:
                    ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                launcherInvocationCount: 1,
                launcherCommand:
                    "bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                stepNumber: 6,
                stepName: "Run the Prime-owned decoder on live Metal",
                stepStartedAt: "2026-08-12T05:27:49Z",
                stepCompletedAt: "2026-08-12T05:51:16Z",
                predecessorAuthorityID:
                    "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_authority_v1",
                predecessorAuthorityCanonicalSHA256:
                    "bc6aa0630196e1c02814834ffb3f8502ae51bcdc751ecbc37cb9bb5dd22c502a",
                classifierCommand: "grep -Eq",
                classifierRegex:
                    "^Test Case '[^']+' failed \\(|^Test Suite '[^']+' failed at |^error:|^Test Case '[^']+' skipped \\(| : Test skipped - ",
                acceptanceFixtureCount: 8,
                acceptanceFixtureMatchCount: 0,
                rejectionFixtureCount: 5,
                rejectionFixtureMatchCount: 5,
                scannedLogCount: 8,
                predecessorClassifierPassed: true,
                freshSourceCandidateCount: 1,
                freshSourceRegularFileIdentityValidated: true,
                metallibIdentityInventoryCount: 5,
                byteIdenticalComparisonCount: 5,
                byteCountEqualityCount: 5,
                sha256EqualityCount: 5,
                metalBundleCandidateCount: 2,
                runtimeBundleCandidateCount: 1,
                tokenizerBundleCandidateCount: 1,
                runtimeReceiptIdentityMatchCount: 1,
                tokenizerReceiptIdentityMatchCount: 1,
                sourceBoundEvidenceEstablished: true,
                loadedMetallibPathInferred: false,
                independentlyObservedLoadedMetallibIdentityEstablished: false,
                buildCommand: "swift build --build-tests",
                buildCommandCount: 1,
                metallibBuiltByThisLauncher: false,
                stagedDestinationCount: 2,
                stagedCopyCount: 2,
                stagedPermissionMode: "444",
                stagedRelativePaths: [
                    "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
                    "PrimeNativeDecoderTrainingValidationPackageTests.xctest/Contents/Resources/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
                ],
                stagedCopiesByteIdentical: true,
                directXCTestInvocationCount: 1,
                validationTestClass: "PrimeNativeDecoderTrainingTests",
                validationTestMethod:
                    "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                validationTestFilter:
                    "PrimeNativeDecoderTrainingTests/testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                testStartCount: 1,
                testPassCount: 1,
                testFailureCount: 0,
                testSkipCount: 0,
                privateWorkingDirectoryEmptyBeforeAndAfter: true,
                receipt:
                    receipt(
                        scope: "stage2_evidence_surface_repair",
                        prefix:
                            "PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_FRESH_METALLIB_EVIDENCE_SURFACE_REPAIR_RECEIPT=",
                        rawBytes: 6_428,
                        rawSHA:
                            "5c7a1cb1cec4a66517e5e1fc382ae757f6d6b6460d1f55b963040b958d907a78",
                        lineBytes: 6_522,
                        lineSHA:
                            "5d4f75241c28ba8d47ad048b2297387411822f85131832d271eb8605f906cdc8",
                        memberTimestamp: "2026-08-12T05:51:16.9027000Z",
                        aggregateTimestamp: "2026-08-12T05:51:16.9027410Z",
                        id:
                            "ergentics_prime_native_decoder_stage2_metallib_bootstrap_fresh_metallib_evidence_surface_repair_receipt_v1",
                        status:
                            "PASS_exact_main_stage2_same_job_fresh_metallib_evidence_surface_repair_one_test_zero_failure_zero_skip"),
                trustedCompletedTestCount: 96,
                mechanicsExecutionEstablished: true,
                defaultMetallibBootstrapRepairEstablished: true,
                freshMetallibEvidenceSurfaceRepairEstablished: true),
        artifactBoundary:
            PrimeNativeDecoderStage2EvidenceRepairExecutionArtifactBoundaryV1(
                actionsArtifactsEndpoint:
                    "https://api.github.com/repos/Ergentics/ergentics-prime/actions/runs/31565094400/artifacts",
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
                stage2ReceiptEmitted: true,
                checkpointArtifactCreated: false,
                checkpointArtifactUploaded: false,
                checkpointArtifactRetained: false,
                checkpointArtifactProvenanceEstablished: false),
        authorityCeiling:
            PrimeNativeDecoderStage2EvidenceRepairExecutionAuthorityCeilingV1(
                predecessorRepairAuthorityConsumed: true,
                predecessorRepairAuthorityExhausted: true,
                successObservationAuthorizesNothing: true,
                consumedStage2LiveInvocationRetirementRequired: true,
                launcherSourceMustRemainPreservedForAudit: true,
                stage3RemainsBlocked: true,
                rerunAuthorized: false,
                retryAuthorized: false,
                replacementRunAuthorized: false,
                workflowMutationBeyondRequiredRetirementAuthorized: false,
                launcherMutationAuthorized: false,
                tlsVerificationBypassAuthorized: false,
                credentialMutationAuthorized: false,
                newMetallibBuildAuthorized: false,
                additionalStage2ExecutionAuthorized: false,
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
            "PASS_exact_main_stage2_fresh_metallib_evidence_surface_repair_one_test_zero_failure_zero_skip_no_rerun_no_artifact_no_stage3_authority",
        orderedRequiredSeparateActions: [
            "retire_consumed_stage2_live_invocation_without_rerun",
            "preserve_frozen_stage2_launcher_and_immutable_execution_evidence",
            "append_success_observation_and_exhaustive_pure_test",
            "reclose_active_root_and_embedded_source_provenance",
            "keep_stage3_blocked_until_distinct_authority",
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
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationError
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
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            guard predecessorAuthorityID == predecessor.authorityID,
                  predecessorAuthorityCanonicalSHA256
                    == PrimeSHA256.hexDigest(
                        of: try predecessor.canonicalData()) else {
                throw
                    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationError
                        .contractDrift
            }
        } catch {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationError
                    .contractDrift
        }

        let repository = repositoryIdentity
        let run = runIdentity
        let green = predecessor.greenPrerequisite
        let design = predecessor.repairDesign
        let predecessorBoundary = predecessorBoundary
        let metal = metalCaptureBoundary
        let stage2 = stage2Boundary
        let artifacts = artifactBoundary
        let ceiling = authorityCeiling
        let authorityFalseClaims = [
            ceiling.rerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.workflowMutationBeyondRequiredRetirementAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.tlsVerificationBypassAuthorized,
            ceiling.credentialMutationAuthorized,
            ceiling.newMetallibBuildAuthorized,
            ceiling.additionalStage2ExecutionAuthorized,
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
        let artifactFalseClaims = [
            artifacts.runLogArchiveIsActionsArtifact,
            artifacts.jobLogsRetainedInRepository,
            artifacts.durableJobLogPublicationEstablished,
            artifacts.freshMetallibRetainedAfterJob,
            artifacts.freshMetallibArtifactProvenanceEstablished,
            artifacts.checkpointArtifactCreated,
            artifacts.checkpointArtifactUploaded,
            artifacts.checkpointArtifactRetained,
            artifacts.checkpointArtifactProvenanceEstablished,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              repository.orderedParentRevisions.count == 2,
              repository.tree == repository.reviewedHeadTree,
              repository.revision == run.headRevision,
              repository.exactFirstParentChangedPaths
                == design.exactDirectSuccessorChangedPaths,
              repository.exactFirstParentChangedStatuses
                == design.exactDirectSuccessorChangedStatuses,
              repository.exactFirstParentChangedPaths.count == 6,
              Set(repository.exactFirstParentChangedPaths).count == 6,
              repository.orderedParentRevisions.count
                == design.requiredExecutionCommitParentCount,
              repository.orderedParentRevisions.first
                == design.requiredFirstParentRevision,
              repository.historyPreservingTwoParentMergeObserved,
              repository.mergeTreeEqualsReviewedHeadTree,
              repository.mergeCommitSignatureVerified,
              repository.exactMainRefStillMatchedAtAudit,
              observedSourceBindings.count == 18,
              Set(observedSourceBindings.map(\.path)).count == 18,
              observedSourceBindings.allSatisfy(Self.validSourceIdentity),
              run.runAttempt == 1,
              run.status == "completed",
              run.conclusion == "success",
              run.exactHeadPushRunCount == 1,
              run.previousAttemptURLWasNull,
              run.secondAttemptEndpointHTTPStatus == 404,
              run.rerunCount == 0,
              !run.rerunObserved,
              !run.rerunAuthorized,
              Self.validSuccessfulJob(activeRootJob),
              Self.validSuccessfulJob(reviewedMainJob),
              activeRootJob.runnerID != reviewedMainJob.runnerID,
              activeRootJob.completedAt < reviewedMainJob.startedAt,
              Self.validRawLog(activeRootRawLog),
              Self.validRawLog(reviewedMainRawLog),
              Self.validRawLog(secureFetchStepRawLog),
              Self.validRawLog(focusedContractsStepRawLog),
              Self.validRawLog(liveStage2StepRawLog),
              rawLogArchive.members.count == rawLogArchive.memberCount,
              rawLogArchive.members.reduce(0, { $0 + $1.byteCount })
                == rawLogArchive.uncompressedByteCount,
              Set(rawLogArchive.members.map(\.path)).count
                == rawLogArchive.memberCount,
              rawLogArchive.repeatedDownloadsWereByteIdentical,
              rawLogArchive.memberTimestampsAreDOSZero,
              secureFetchBoundary.invocationCount == 1,
              secureFetchBoundary.completionCount == 1,
              secureFetchBoundary.workflowBlockSHA256
                == green.secureFetchWorkflowBlockSHA256,
              secureFetchBoundary.workflowAuthoredRetryCount == 0,
              secureFetchBoundary.separateRetryStepCount == 0,
              secureFetchBoundary.gitInternalSubmoduleRetryCount == 0,
              secureFetchBoundary.mlxSubmoduleCloneAttemptCount == 1,
              secureFetchBoundary.mlxCSubmoduleCloneAttemptCount == 1,
              secureFetchBoundary.gitSubmoduleTLSFailureCount == 0,
              secureFetchBoundary.tlsVerificationBypassCount == 0,
              secureFetchBoundary.customCAInstallationCount == 0,
              predecessorBoundary.activeRootGatePassed,
              predecessorBoundary.dependencyFreeSwiftParsePassed,
              predecessorBoundary.latinInvocationCount == 1,
              predecessorBoundary.latinCompletedTestCount == 116,
              predecessorBoundary.latinFailureCount == 0,
              predecessorBoundary.latinSkipCount == 0,
              predecessorBoundary.focusedRootInvocationCount == 1,
              predecessorBoundary.focusedRootTestCount == 43,
              predecessorBoundary.focusedRootTestCount
                == design.requiredFocusedRootTestCount,
              predecessorBoundary.focusedRootFailureCount == 0,
              predecessorBoundary.focusedRootSkipCount == 0,
              predecessorBoundary.isolatedCheckpointGroupTestCounts
                == [1, 1, 2, 2],
              predecessorBoundary.focusedWholeStepTestCount
                == predecessorBoundary.focusedRootTestCount
                    + predecessorBoundary.isolatedCheckpointGroupTestCounts
                        .reduce(0, +),
              predecessorBoundary.focusedWholeStepTestCount == 49,
              predecessorBoundary.focusedWholeStepTestCount
                == design.requiredFocusedWholeStepTestCount,
              predecessorBoundary.focusedWholeStepFailureCount == 0,
              predecessorBoundary.focusedWholeStepSkipCount == 0,
              predecessorBoundary.liveInvocationSequence
                == ["metal", "maintained_runtime", "tokenizer", "stage2"],
              predecessorBoundary.liveInvocationCounts == [1, 1, 1, 1],
              predecessorBoundary.metallibBuildInvocationCount == 1,
              predecessorBoundary.metallibBuildCompletionCount == 1,
              predecessorBoundary.freshMetallibCandidateCount == 1,
              predecessorBoundary.metalGroupTestCounts == [11, 14, 19],
              predecessorBoundary.metalGroupTestCounts.reduce(0, +) == 44,
              predecessorBoundary.metalTestCount == 44,
              predecessorBoundary.metalTestCount
                == design.requiredMetalTestCount,
              predecessorBoundary.metalFailureCount == 0,
              predecessorBoundary.metalSkipCount == 0,
              predecessorBoundary.runtimeInvocationCount == 1,
              predecessorBoundary.runtimeTestCount == 1,
              predecessorBoundary.runtimeTestCount
                == design.requiredRuntimeTestCount,
              predecessorBoundary.runtimeFailureCount == 0,
              predecessorBoundary.runtimeSkipCount == 0,
              Self.validReceipt(predecessorBoundary.runtimeReceipt),
              predecessorBoundary.tokenizerInvocationCount == 1,
              predecessorBoundary.tokenizerTestCount == 1,
              predecessorBoundary.tokenizerTestCount
                == design.requiredTokenizerTestCount,
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
              predecessorBoundary.validatedPredecessorLogCount == 11,
              predecessorBoundary.validatedPredecessorLogCount
                == design.requiredPredecessorLogCount,
              predecessorBoundary.validatedPredecessorReceiptCount == 2,
              predecessorBoundary.validatedPredecessorReceiptCount
                == design.requiredPredecessorReceiptCount,
              predecessorBoundary.predecessorArtifactSnapshotCount == 16,
              predecessorBoundary.predecessorArtifactSnapshotCount
                == design.predecessorArtifactSnapshotCount,
              predecessorBoundary.predecessorArtifactRevalidationCountAfterXCTest
                == 16,
              predecessorBoundary.predecessorArtifactRevalidationCountAfterXCTest
                == design.predecessorArtifactRevalidationCountAfterXCTest,
              predecessorBoundary.completedPreStage2TestCount
                == predecessorBoundary.focusedWholeStepTestCount
                    + predecessorBoundary.metalTestCount
                    + predecessorBoundary.runtimeTestCount
                    + predecessorBoundary.tokenizerTestCount,
              predecessorBoundary.completedPreStage2TestCount == 95,
              predecessorBoundary.completedPreStage2TestCount
                == design.requiredPreStage2CompletedTestCount,
              predecessorBoundary.preStage2FailureCount == 0,
              predecessorBoundary.preStage2SkipCount == 0,
              metal.captureInvocationCount == 1,
              metal.captureInvocationCount
                == design.metalFullOutputLogCaptureInvocationCount,
              metal.teeInvocationCount == 1,
              metal.teeInvocationCount
                == design.metalFullOutputLogTeeInvocationCount,
              metal.pipelineStatusElementCount == 2,
              metal.launcherPipelineStatus == 0,
              metal.teePipelineStatus == 0,
              metal.pipelineStatusCapturedImmediatelyAfterPipeline,
              metal.errexitRestoredImmediatelyAfterStatusCapture,
              metal.logRegularFileRequired,
              metal.logSymbolicLinkForbidden,
              metal.logNonemptyRequired,
              metal.logRequiredHardLinkCount == 1,
              metal.frozenLogPermissionMode == "444",
              metal.exactDynamicIdentityLine.contains(
                predecessorBoundary.freshMetallibSHA256),
              metal.exactDynamicIdentityLine.contains(
                "metallib_bytes=\(predecessorBoundary.freshMetallibByteCount)"),
              metal.fullOutputIdentityPrefixCount == 1,
              metal.fullOutputIdentityPrefixCount
                == design.metalFullOutputLogIdentityPrefixCount,
              metal.fullOutputExactIdentityCount == 1,
              metal.fullOutputExactIdentityCount
                == design.metalFullOutputLogFreshIdentityCount,
              metal.xctestOnlyIdentityPrefixCount == 0,
              metal.xctestOnlyIdentityPrefixCount
                == design.metalXCTestLogIdentityPrefixCount,
              metal.xctestOnlyExactIdentityCount == 0,
              metal.xctestOnlyExactIdentityCount
                == design.metalXCTestLogFreshIdentityCount,
              !metal.metalLauncherSourceChanged,
              stage2.launcherInvocationCount == 1,
              stage2.launcherPath == design.launcherPath,
              stage2.launcherCommand == design.launcherInvocation,
              stage2.stepNumber == 6,
              stage2.stepName == reviewedMainJob.orderedSteps[5].name,
              stage2.predecessorAuthorityID == predecessorAuthorityID,
              stage2.predecessorAuthorityCanonicalSHA256
                == predecessorAuthorityCanonicalSHA256,
              stage2.classifierCommand == "grep -Eq",
              stage2.acceptanceFixtureCount == 8,
              stage2.acceptanceFixtureCount
                == design.classifierAcceptedFixtureCount,
              stage2.acceptanceFixtureMatchCount == 0,
              stage2.rejectionFixtureCount == 5,
              stage2.rejectionFixtureCount
                == design.classifierRejectedFixtureCount,
              stage2.rejectionFixtureMatchCount == 5,
              stage2.scannedLogCount == 8,
              stage2.scannedLogCount
                == design.requiredClassifierScannedLogCount,
              stage2.predecessorClassifierPassed,
              stage2.freshSourceCandidateCount == 1,
              stage2.freshSourceRegularFileIdentityValidated,
              stage2.metallibIdentityInventoryCount == 5,
              stage2.metallibIdentityInventoryCount
                == design.requiredMetallibIdentityInventoryCount,
              stage2.byteIdenticalComparisonCount == 5,
              stage2.byteCountEqualityCount == 5,
              stage2.sha256EqualityCount == 5,
              stage2.metalBundleCandidateCount == 2,
              stage2.runtimeBundleCandidateCount == 1,
              stage2.tokenizerBundleCandidateCount == 1,
              stage2.runtimeReceiptIdentityMatchCount == 1,
              stage2.tokenizerReceiptIdentityMatchCount == 1,
              stage2.sourceBoundEvidenceEstablished,
              !stage2.loadedMetallibPathInferred,
              !stage2.independentlyObservedLoadedMetallibIdentityEstablished,
              stage2.buildCommand == "swift build --build-tests",
              stage2.buildCommandCount == 1,
              stage2.buildCommandCount == design.swiftBuildInvocationCount,
              !stage2.metallibBuiltByThisLauncher,
              stage2.stagedDestinationCount == 2,
              stage2.stagedCopyCount == 2,
              stage2.stagedCopyCount == design.stagedMetallibCopyCount,
              stage2.stagedPermissionMode == "444",
              stage2.stagedRelativePaths.count == 2,
              stage2.stagedCopiesByteIdentical,
              stage2.directXCTestInvocationCount == 1,
              stage2.directXCTestInvocationCount
                == design.directXCTestInvocationCount,
              stage2.testStartCount == 1,
              stage2.testPassCount == 1,
              stage2.testFailureCount == 0,
              stage2.testSkipCount == 0,
              stage2.privateWorkingDirectoryEmptyBeforeAndAfter,
              Self.validReceipt(stage2.receipt),
              stage2.receipt.prefix == design.receiptPrefix,
              stage2.receipt.receiptOrEvidenceID == design.receiptID,
              stage2.receipt.statusOrOutcomeKind == design.receiptStatus,
              stage2.receipt.metallibByteCount
                == predecessorBoundary.freshMetallibByteCount,
              stage2.receipt.metallibSHA256
                == predecessorBoundary.freshMetallibSHA256,
              stage2.trustedCompletedTestCount
                == predecessorBoundary.completedPreStage2TestCount + 1,
              stage2.trustedCompletedTestCount == 96,
              stage2.trustedCompletedTestCount
                == design.requiredTrustedCompletedTestCount,
              stage2.mechanicsExecutionEstablished,
              stage2.defaultMetallibBootstrapRepairEstablished,
              stage2.freshMetallibEvidenceSurfaceRepairEstablished,
              artifacts.actionsArtifactsTotalCount == 0,
              artifacts.actionsArtifactsArrayExactlyEmpty,
              artifacts.publishedWorkflowArtifactCount == 0,
              artifacts.artifactUploadStepCount == 0,
              artifacts.runLogArchiveObserved,
              artifacts.runtimeReceiptEmitted,
              artifacts.tokenizerReceiptEmitted,
              artifacts.stage2ReceiptEmitted,
              artifactFalseClaims.allSatisfy({ !$0 }),
              ceiling.predecessorRepairAuthorityConsumed,
              ceiling.predecessorRepairAuthorityExhausted,
              ceiling.successObservationAuthorizesNothing,
              ceiling.consumedStage2LiveInvocationRetirementRequired,
              ceiling.launcherSourceMustRemainPreservedForAudit,
              ceiling.stage3RemainsBlocked,
              authorityFalseClaims.allSatisfy({ !$0 }) else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairExecutionObservationError
                    .contractDrift
        }
    }

    private static let sourceBindings = [
        source(".github/scripts/prime-ci-active-root-quarantine.sh", "100755", "9e672102963536627599940f5ec899b131651bc4", 410_341, 7_403, "ace11ba6b9a80f7848990dacd6d1a13f454940fbdd03f22884419bdaec78e7f2", "exact_root43_gate"),
        source(".github/scripts/prime-ci-native-decoder-metal.sh", "100755", "418d2d2753cee38e0b3558ad45e1e09865ffd11d", 11_793, 230, "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff", "preserved_metal_launcher"),
        source(".github/scripts/prime-ci-native-decoder-runtime-closure.sh", "100755", "f1c3041d7e47fa315f60c889a736a412640e8710", 26_614, 569, "aac5421ec7b1465bb746079bf5ea2634e20b9456099b33ce0271228638342cc5", "preserved_runtime_launcher"),
        source(".github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh", "100755", "b12d52802e7f24be7a905ae0cbceeed945fcc11a", 33_174, 678, "0c70d3cd538e297cf629707a51bcc8ede87b42e488369ffd321ac3c44062f06a", "preserved_tokenizer_launcher"),
        source(".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh", "100755", "6a50cc027a566104a1d9d505add93b619f1a32f5", 53_660, 1_026, "27c276d9acf9662ff315dccb849304aa61b44dfad67237120eeb9dd97324a840", "executed_evidence_surface_repair_launcher"),
        source(".github/workflows/prime-active-root-quarantine.yml", "100644", "0fe28060b356e4aac1fb5109d23777dca1adba33", 50_571, 470, "346364a1e454018cf156759d9666d9759dc1e5827fde1dcd9389f741d50d23c2", "exact_root43_workflow_and_full_output_wrapper"),
        source("Package.swift", "100644", "765d3c88139bc1f74af16b77b2f3b06d33f66f75", 32_795, 933, "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2", "unchanged_root_manifest"),
        source("Package.resolved", "100644", "14d804bb4291720477240c27e24de6fbdc876b3b", 645, 23, "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375", "unchanged_root_lock"),
        source("Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", "100644", "d7a025193c0dafe405f12f33aa4a0e5b91c827c4", 546, 13, "35c55b2f819b4a43181f988a278699ecfc486295e28241ad5d5f33db9f4e782b", "exact_embedded_source_identity"),
        source("Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift", "100644", "b3b42c285c8fe048d4eeea111f3f9f9bab37707d", 66_167, 1_250, "2f97065f3c09f69d2ce38774a16a5d4dcb9deb20899cdeb1f8821334d2486983", "preserved_classifier_repair_authority"),
        source("Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift", "100644", "15164c2256129816789fd2408f73f7b1c7eaccbd", 35_453, 841, "2600a86636c5440ddd010e10a0928fd7f49b96d2926536d881364e524630d187", "preserved_classifier_repair_authority_test"),
        source("Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservation.swift", "100644", "35ca8e0d056ea9cffce532f2882c9d13d622e5cf", 76_806, 1_526, "3fbd5f40b70a589e38393468df526da7a128e427d9fbf9a83462efd80d35fe93", "consumed_cross_binding_failure_observation"),
        source("Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests.swift", "100644", "c176a50a7ac7367cbd7f66e6003613ba597adb43", 41_359, 945, "c7fd5fcd2c1422cece77d34f45e70f5778c29bbf258972c9b9b30b5e6d3f8e2e", "consumed_cross_binding_failure_observation_test"),
        source("Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift", "100644", "523d30f7bd42d67276476ee545cc2f62c4a5b361", 63_673, 1_207, "cb1e143d35c553514aec2e715a0e6beb87fc63b212be390bb1bd50ca630f14e0", "consumed_evidence_surface_repair_authority"),
        source("Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift", "100644", "cb5e9301694ae6f37d0d2001fecabe589d563c6c", 33_534, 778, "03b25be292a00917320d208333e1bfd820042dd8e44ba440f736db0d7363ece3", "consumed_evidence_surface_repair_authority_test"),
        source("Tests/PrimeNativeDecoderTrainingValidation/Package.swift", "100644", "9f05e5a17426f00adf9dad7b55d84057122e98f9", 1_054, 40, "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45", "unchanged_stage2_manifest"),
        source("Tests/PrimeNativeDecoderTrainingValidation/Package.resolved", "100644", "8bf05edf1ea8789e7683e72fe756d79aaaa61320", 645, 23, "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225", "unchanged_stage2_lock"),
        source("Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift", "100644", "61e86200c508526ae2ab66e359d771841f7208db", 30_214, 796, "29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96", "executed_stage2_test_source"),
    ]

    private static let archiveMembers = [
        member("0_Reviewed main _ focused source contracts.txt", 10_294_957, 78_905, "019f6ba8535ddaca21b49ecc289b91cb09679552cb597c99d634139646ff7c3a"),
        member("Reviewed main _ focused source contracts/system.txt", 800, 8, "7f79ff052952cb8a796a5f2f1cfb1573acacada63fab6a8879acfafe7d2dae41"),
        member("Reviewed main _ focused source contracts/1_Set up job.txt", 1_680, 28, "e0ed9ef47a6c6643fce881b68dbba2be06bc4bd5cd011e9c65d84d0b634b766a"),
        member("Reviewed main _ focused source contracts/2_Record the hosted Apple toolchain.txt", 1_279, 22, "eefed22ec734ca0e5281030308e01ca79258c1149f7e7148b5dde8377a3118fc"),
        member("Reviewed main _ focused source contracts/3_Check out reviewed main exactly.txt", 3_151, 37, "d26b8fcbb082b5accd5328ffe2b95308815adffbf0895626a4ce482f0ac26c6a"),
        member("Reviewed main _ focused source contracts/4_Fetch the exact private dependency without evaluating Prime.txt", 4_893, 54, "457781579fa43d313886ca57c887fd5a42d828a6b97e33cec5fc682181d3caf7"),
        member("Reviewed main _ focused source contracts/5_Compile and run the focused contracts without a credential.txt", 353_901, 3_403, "c21ee98599a75671bfe125cf100a42d02131acedb0dd5265c050177d074e79ac"),
        member("Reviewed main _ focused source contracts/6_Run the Prime-owned decoder on live Metal.txt", 9_930_010, 75_360, "6327bf59a8f84557af8d9cc01f4274114e48e47238379139752bd2b94e3df583"),
        member("Reviewed main _ focused source contracts/7_Complete job.txt", 61, 1, "a078097a88e3d048dee1cb2105d0923ae11c755e0ad591b8fcadd4026f670256"),
        member("1_First-party MLX _ active-root quarantine.txt", 238_922, 1_761, "680fc1b1672db3ef0d2bab7d7e8599d6d176d3929d14aeeef4f03197cdc7cce4"),
        member("First-party MLX _ active-root quarantine/system.txt", 601, 7, "95b347a5300418457fa2a67ac107bc1baac84c6480759a3bd6343504ab93906a"),
        member("First-party MLX _ active-root quarantine/1_Set up job.txt", 1_681, 28, "779e619ac14be9b363c485253e0993c86f66ba1315159c3c979eb31bf329bd16"),
        member("First-party MLX _ active-root quarantine/2_Check out the exact Prime revision.txt", 3_059, 36, "c0305f0fa13a673fa77e7d82b49f33f708225a11391b65715441c44f778112a8"),
        member("First-party MLX _ active-root quarantine/3_Validate active metadata and preserved history.txt", 706, 8, "ec94205d0934ff890ec878135a932625e33435e79221c34f8e6a9d91e2833059"),
        member("First-party MLX _ active-root quarantine/4_Parse the changed Swift contracts without dependencies.txt", 15_085, 109, "73ac49d4585bf0eaf2452390090fff01daeb14a476f30200904c1f86e2744e9d"),
        member("First-party MLX _ active-root quarantine/5_Validate isolated Latin capture and observation contracts.txt", 196_156, 1_520, "bac78300a80a7b582e9f62d784b9f6e475bb176389a5f62bee95266611e6b336"),
        member("First-party MLX _ active-root quarantine/6_Record the authority ceiling.txt", 22_192, 59, "8924cd716057f7b0cdffd3ab4946aeca923f20b418f7e1086190c403244733cf"),
        member("First-party MLX _ active-root quarantine/7_Complete job.txt", 61, 1, "6c8970f31e1581444907451c7e8914ca8d774a7a2329121b1003b60581bce0a3"),
    ]

    private static func source(
        _ path: String,
        _ gitMode: String,
        _ gitBlob: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String,
        _ claimScope: String
    ) -> PrimeNativeDecoderStage2EvidenceRepairExecutionSourceIdentityV1 {
        .init(
            path: path,
            gitMode: gitMode,
            gitBlob: gitBlob,
            byteCount: byteCount,
            lfByteCount: lfByteCount,
            sha256: sha256,
            claimScope: claimScope)
    }

    private static func step(
        _ number: Int,
        _ name: String,
        _ startedAt: String,
        _ completedAt: String
    ) -> PrimeNativeDecoderStage2EvidenceRepairExecutionJobStepV1 {
        .init(
            number: number,
            name: name,
            startedAt: startedAt,
            completedAt: completedAt,
            conclusion: "success")
    }

    private static func job(
        id: Int,
        name: String,
        url: String,
        startedAt: String,
        completedAt: String,
        runnerLabel: String,
        runnerID: Int,
        runnerName: String,
        steps: [PrimeNativeDecoderStage2EvidenceRepairExecutionJobStepV1]
    ) -> PrimeNativeDecoderStage2EvidenceRepairExecutionJobV1 {
        .init(
            id: id,
            name: name,
            url: url,
            startedAt: startedAt,
            completedAt: completedAt,
            status: "completed",
            conclusion: "success",
            runnerLabel: runnerLabel,
            runnerID: runnerID,
            runnerName: runnerName,
            runnerGroupName: "GitHub Actions",
            orderedSteps: steps,
            checkAnnotationCount: 0)
    }

    private static func rawLog(
        _ scope: String,
        _ byteCount: Int,
        _ sha256: String,
        _ lfByteCount: Int,
        _ firstTimestamp: String,
        _ lastTimestamp: String
    ) -> PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1 {
        .init(
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
                "lf_bytes_equal_split_lines_excluding_terminal_empty_component",
            firstTimestamp: firstTimestamp,
            lastTimestamp: lastTimestamp)
    }

    private static func member(
        _ path: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String
    ) -> PrimeNativeDecoderStage2EvidenceRepairExecutionArchiveMemberV1 {
        .init(
            path: path,
            byteCount: byteCount,
            lfByteCount: lfByteCount,
            sha256: sha256)
    }

    private static func receipt(
        scope: String,
        prefix: String,
        rawBytes: Int,
        rawSHA: String,
        lineBytes: Int,
        lineSHA: String,
        memberTimestamp: String,
        aggregateTimestamp: String,
        id: String,
        status: String
    ) -> PrimeNativeDecoderStage2EvidenceRepairExecutionReceiptIdentityV1 {
        .init(
            scope: scope,
            prefix: prefix,
            count: 1,
            rawJSONByteCount: rawBytes,
            rawJSONSHA256: rawSHA,
            canonicalJSONByteCount: rawBytes,
            canonicalJSONSHA256: rawSHA,
            rawJSONWasCanonical: true,
            receiptLineByteCount: lineBytes,
            receiptLineSHA256: lineSHA,
            memberTimestamp: memberTimestamp,
            aggregateTimestamp: aggregateTimestamp,
            receiptOrEvidenceID: id,
            statusOrOutcomeKind: status,
            outcomeEstablished: true,
            metallibByteCount: 6_292_732,
            metallibSHA256:
                "54b57ce3dea5c648cbee3096602cf51791033badb2fbbdc632741bb3b1b5f7d6",
            loadedMetallibIdentityIndependentlyObserved: false,
            metallibArtifactProvenanceEstablished: false)
    }

    private static func validSourceIdentity(
        _ source: PrimeNativeDecoderStage2EvidenceRepairExecutionSourceIdentityV1
    ) -> Bool {
        ["100644", "100755"].contains(source.gitMode)
            && source.gitBlob.utf8.count == 40
            && source.byteCount > 0
            && source.lfByteCount > 0
            && source.sha256.utf8.count == 64
            && !source.claimScope.isEmpty
    }

    private static func validSuccessfulJob(
        _ job: PrimeNativeDecoderStage2EvidenceRepairExecutionJobV1
    ) -> Bool {
        job.status == "completed"
            && job.conclusion == "success"
            && job.orderedSteps.map(\.number) == Array(1 ... 7)
            && job.orderedSteps.allSatisfy({ $0.conclusion == "success" })
            && job.checkAnnotationCount == 0
    }

    private static func validRawLog(
        _ log: PrimeNativeDecoderStage2EvidenceRepairExecutionRawLogIdentityV1
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
        _ receipt: PrimeNativeDecoderStage2EvidenceRepairExecutionReceiptIdentityV1
    ) -> Bool {
        receipt.count == 1
            && receipt.rawJSONByteCount > 0
            && receipt.rawJSONSHA256.utf8.count == 64
            && receipt.canonicalJSONByteCount == receipt.rawJSONByteCount
            && receipt.canonicalJSONSHA256 == receipt.rawJSONSHA256
            && receipt.rawJSONWasCanonical
            && receipt.receiptLineByteCount
                == receipt.prefix.utf8.count + receipt.rawJSONByteCount
            && receipt.receiptLineSHA256.utf8.count == 64
            && receipt.outcomeEstablished
            && receipt.metallibByteCount > 0
            && receipt.metallibSHA256.utf8.count == 64
            && !receipt.loadedMetallibIdentityIndependentlyObserved
            && !receipt.metallibArtifactProvenanceEstablished
    }
}
