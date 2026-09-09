// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

/// Frozen evidence for the consumed exact-main Stage-7 opportunity in run 129.
///
/// Release construction and the execution-pure contract succeeded before the
/// sole supervisor invocation returned nonzero. The launcher intentionally
/// disclosed neither private frame nor private stderr, so the underlying
/// worker/supervisor cause and every scientific/resource/checkpoint result are
/// unrecoverable. GitHub separately observed and terminated one orphan process
/// named `sleep`; attributing that process to the launcher watchdog is only a
/// source-consistent inference, not a directly observed process lineage.
public struct
    PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public struct SourceIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let sha256: String
        public let claimScope: String
    }

    public struct RepositoryIdentity: Codable, Equatable, Sendable {
        public let repository: String
        public let pullRequestNumber: Int
        public let ref: String
        public let baseRevision: String
        public let baseTree: String
        public let reviewedHeadRevision: String
        public let reviewedHeadTree: String
        public let reviewedHeadOrderedParents: [String]
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let mergeCommitterAt: String
        public let mergedAt: String
        public let mergeCommitSignatureVerified: Bool
        public let mergeCommitSignatureReason: String
        public let historyPreservingTwoParentMergeObserved: Bool
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let exactMainRefMatchedAtTerminalAudit: Bool
        public let changedPathCount: Int
        public let changedManifestPathCount: Int
        public let changedLockPathCount: Int
        public let rootManifestPreserved: Bool
        public let rootLockPreserved: Bool
        public let validationLockPreserved: Bool
        public let embeddedSourceIdentitySHA256: String
    }

    public struct ReviewBoundary: Codable, Equatable, Sendable {
        public let pullRequestCreatedAt: String
        public let pullRequestMergedAt: String
        public let pullRequestCommitCount: Int
        public let pullRequestChangedPathCount: Int
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let workflowEvent: String
        public let workflowHeadRevision: String
        public let workflowCheckSuiteID: Int
        public let workflowCreatedAt: String
        public let workflowStartedAt: String
        public let workflowUpdatedAt: String
        public let workflowStatus: String
        public let workflowConclusion: String
        public let previousAttemptURLWasNull: Bool
        public let activeRootJobID: Int
        public let activeRootJobStartedAt: String
        public let activeRootJobCompletedAt: String
        public let activeRootJobConclusion: String
        public let activeRootRunnerID: Int
        public let activeRootTestStartCount: Int
        public let activeRootTestPassCount: Int
        public let activeRootTestFailureCount: Int
        public let activeRootTestSkipCount: Int
        public let reviewedMainCompileJobID: Int
        public let reviewedMainCompileConclusion: String
        public let reviewedMainCompileStepCount: Int
        public let stage7JobID: Int
        public let stage7JobConclusion: String
        public let stage7JobStepCount: Int
        public let stage7LauncherInvocationCount: Int
        public let stage7ContractInvocationCount: Int
        public let stage7ExecutableInvocationCount: Int
        public let stage7ReceiptCount: Int
        public let metalOrNative300MechanicsInvocationCount: Int
        public let actionsArtifactCount: Int
        public let rerunCount: Int
    }

    public struct RunIdentity: Codable, Equatable, Sendable {
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
        public let createdAt: String
        public let startedAt: String
        public let terminalUpdatedAt: String
        public let status: String
        public let conclusion: String
        public let checkSuiteID: Int
        public let exactHeadPushRunCount: Int
        public let previousAttemptURLWasNull: Bool
        public let rerunCount: Int
        public let rerunObserved: Bool
        public let rerunAuthorized: Bool
        public let runURL: String
    }

    public struct JobIdentity: Codable, Equatable, Sendable {
        public let id: Int
        public let name: String
        public let status: String
        public let conclusion: String
        public let startedAt: String
        public let completedAt: String
        public let runnerID: Int
        public let runnerName: String
        public let runnerGroupName: String
        public let runnerLabel: String
        public let orderedStepNames: [String]
        public let orderedStepConclusions: [String]
        public let orderedStepStartedAt: [String]
        public let orderedStepCompletedAt: [String]
        public let checkAnnotationCount: Int
        public let checkAnnotationPath: String
        public let checkAnnotationLine: Int
        public let checkAnnotationMessage: String
        public let jobURL: String
    }

    public struct RawLogIdentity: Codable, Equatable, Sendable {
        public let byteCount: Int
        public let lfByteCount: Int
        public let newlineDelimitedComponentCountIncludingTerminalEmpty: Int
        public let utf8BOMHex: String
        public let startsWithUTF8BOM: Bool
        public let usesLFOnly: Bool
        public let endsWithLF: Bool
        public let sha256: String
        public let repeatFetchExactlyEqual: Bool
        public let bindingKind: String
        public let rawGitHubLogArchiveBytesBound: Bool
        public let retainedInRepository: Bool
    }

    public struct TestTopology: Codable, Equatable, Sendable {
        public let activeLatinTestStartCount: Int
        public let activeLatinTestPassCount: Int
        public let activeLatinFailureCount: Int
        public let activeLatinSkipCount: Int
        public let focusedRootTestCount: Int
        public let isolatedCheckpointGroupTestCounts: [Int]
        public let isolatedCheckpointTestCount: Int
        public let focusedStage7ContractTestCount: Int
        public let focusedWholeStepTestCount: Int
        public let metalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let tokenizerTestCount: Int
        public let liveTestCount: Int
        public let reviewedCompileTestCount: Int
        public let reviewedCompileFailureCount: Int
        public let reviewedCompileSkipCount: Int
        public let stage7LauncherLocalContractTestCount: Int
        public let stage7LauncherLocalContractPassCount: Int
        public let aggregateReviewedXCTestCount: Int
        public let directOperationalProbeInvocationCount: Int
        public let directOperationalProbeSuccessCount: Int
        public let observedLiveExecutionOrder: [String]
    }

    public struct ExecutionFailureBoundary: Codable, Equatable, Sendable {
        public let failedJobStepNumber: Int
        public let failedJobStepName: String
        public let failedJobStepStartedAt: String
        public let failedJobStepCompletedAt: String
        public let releaseBuildInvocationCount: Int
        public let releaseBuildCompletionCount: Int
        public let releaseBuildDurationMilliseconds: Int
        public let launcherLocalPureContractInvocationCount: Int
        public let launcherLocalPureContractStartCount: Int
        public let launcherLocalPureContractPassCount: Int
        public let launcherLocalPureContractFailureCount: Int
        public let launcherLocalPureContractSkipCount: Int
        public let launcherLocalPureContractDurationMilliseconds: Int
        public let launcherInvocationCount: Int
        public let directSupervisorExecutableInvocationCount: Int
        public let oneShotBoundaryReached: Bool
        public let oneShotConsumed: Bool
        public let oneShotExhausted: Bool
        public let supervisorNonzeroMarkerLine: String
        public let supervisorNonzeroMarkerOccurrenceCount: Int
        public let exactSupervisorExitStatusEvidence: String
        public let launcherExitCode: Int
        public let workflowProcessExitMessage: String
        public let workflowProcessExitMessageOccurrenceCount: Int
        public let publicReceiptPrefix: String
        public let hostedLogPublicReceiptPrefixOccurrenceCount: Int
        public let privateCandidateSchemaID: String
        public let hostedLogPrivateCandidateSchemaIDOccurrenceCount: Int
        public let privateTerminalSchemaID: String
        public let hostedLogPrivateTerminalSchemaIDOccurrenceCount: Int
        public let publicReceiptSchemaID: String
        public let hostedLogPublicReceiptSchemaIDOccurrenceCount: Int
        public let hostedLogExternalFailsafeStartedMarkerCount: Int
        public let hostedLogExternalFailsafeFailedMarkerCount: Int
        public let privateSupervisorCauseRecoverable: Bool
        public let privateSupervisorCauseEvidence: String
        public let supervisorStdoutEvidence: String
        public let supervisorStderrEvidence: String
        public let privateCandidateFrameEvidence: String
        public let privateTerminalFrameEvidence: String
        public let workerProcessEvidence: String
        public let releaseVerifierProcessEvidence: String
        public let leaseEvidence: String
        public let checkpointPublicationEvidence: String
        public let comparisonDomainEvidence: String
        public let resourcePhaseEvidence: String
        public let artifactCleanupAndAbsenceEvidence: String
        public let scientificOutcomeEvidence: String
        public let resourceOutcomeEvidence: String
        public let exactResumeEvidence: String
        public let validPublicTerminalEstablished: Bool
        public let mechanicsSuccessEstablished: Bool
        public let workflowFailureEstablished: Bool
        public let integrityClosureEstablished: Bool
    }

    public struct OrphanProcessBoundary: Codable, Equatable, Sendable {
        public let githubRunnerOrphanCleanupObserved: Bool
        public let observedOrphanProcessCount: Int
        public let observedOrphanPID: Int
        public let observedOrphanProcessName: String
        public let observedOrphanTerminationLine: String
        public let observedOrphanTerminationLineOccurrenceCount: Int
        public let observedOrphanTerminationAt: String
        public let noOrphanClosureEstablished: Bool
        public let observedProcessRoleEvidence: String
        public let watchdogChildAttributionDirectlyObserved: Bool
        public let watchdogChildExplanation: String
        public let watchdogChildExplanationIsInferenceOnly: Bool
        public let watchdogSleepSecondsInFrozenSource: Int
        public let explanationConsistentWithFrozenSource: Bool
        public let supervisorWorkerOrVerifierOrphanEstablished: Bool
    }

    public struct ArtifactAndLineageBoundary: Codable, Equatable, Sendable {
        public let pullRequestRunArtifactCount: Int
        public let exactMainRunArtifactCount: Int
        public let artifactUploadStepCount: Int
        public let exactMainRunCountForHead: Int
        public let runAttemptCount: Int
        public let previousAttemptURLWasNull: Bool
        public let retryCount: Int
        public let rerunCount: Int
        public let replacementExecutionCount: Int
        public let publicReceiptCount: Int
        public let retainedArtifactEstablished: Bool
        public let runnerLocalArtifactAbsenceEstablished: Bool
        public let checkpointCleanupEstablished: Bool
        public let durableFailureReceiptPublished: Bool
    }

    public struct RetirementBoundary: Codable, Equatable, Sendable {
        public let retirementRequired: Bool
        public let retirementObserved: Bool
        public let exactChangedPathCount: Int
        public let exactOrderedChangedPaths: [String]
        public let expectedActiveLatinTestCount: Int
        public let expectedRootTestCount: Int
        public let expectedIsolatedCheckpointGroupTestCounts: [Int]
        public let expectedIsolatedCheckpointTestCount: Int
        public let expectedFocusedWholeStepTestCount: Int
        public let expectedMetalTestCount: Int
        public let expectedRuntimeTestCount: Int
        public let expectedTokenizerTestCount: Int
        public let expectedLiveTestCount: Int
        public let expectedTotalTestCount: Int
        public let expectedStage7JobCount: Int
        public let expectedStage7FocusedContractInvocationCount: Int
        public let expectedStage7LauncherLocalContractInvocationCount: Int
        public let expectedStage7LauncherInvocationCount: Int
        public let expectedStage7ExecutableInvocationCount: Int
        public let expectedStage7ReceiptCount: Int
        public let stage7MechanicsPayloadsMustRemainPreserved: Bool
        public let replacementOrRepairExecutionPermittedByRetirement: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let oneShotExecutionConsumed: Bool
        public let oneShotExecutionExhausted: Bool
        public let failureObservationAuthorizesNothing: Bool
        public let exactRetirementRequired: Bool
        public let mechanicsPayloadPreservationRequired: Bool
        public let workflowFailureEstablished: Bool
        public let requiredPublicTerminalIntegrityClosureFailureEstablished: Bool
        public let privateFailureCauseRecovered: Bool
        public let validStage7TerminalEstablished: Bool
        public let stage7MechanicsSuccessEstablished: Bool
        public let passExactEstablished: Bool
        public let measuredExactMismatchEstablished: Bool
        public let abstainResourceEstablished: Bool
        public let abstainIntegrityEstablished: Bool
        public let scientificOutcomeEstablished: Bool
        public let resourceOutcomeEstablished: Bool
        public let exactResumeEstablished: Bool
        public let checkpointBindingEstablished: Bool
        public let checkpointCleanupAndAbsenceEstablished: Bool
        public let releaseVerifierClosureEstablished: Bool
        public let noOrphanClosureEstablished: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let launcherMutationAuthorized: Bool
        public let additionalNative300MExecutionAuthorized: Bool
        public let checkpointAdmissionGranted: Bool
        public let generalTrainingResumeEstablished: Bool
        public let modelQualityEstablished: Bool
        public let candidateAdmissionGranted: Bool
        public let stage8AuthorityEstablished: Bool
        public let stage8Authorized: Bool
        public let downstreamTrialAuthorized: Bool
        public let canaryAuthorized: Bool
        public let quantizationAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
    }

    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let repositoryIdentity: RepositoryIdentity
    public let mechanicsSourceBindings: [SourceIdentity]
    public let pullRequestReviewBoundary: ReviewBoundary
    public let pullRequestActiveRootRawLog: RawLogIdentity
    public let exactMainRunIdentity: RunIdentity
    public let activeRootJob: JobIdentity
    public let reviewedMainCompileJob: JobIdentity
    public let stage7Job: JobIdentity
    public let activeRootRawLog: RawLogIdentity
    public let reviewedMainCompileRawLog: RawLogIdentity
    public let stage7RawLog: RawLogIdentity
    public let testTopology: TestTopology
    public let executionFailureBoundary: ExecutionFailureBoundary
    public let orphanProcessBoundary: OrphanProcessBoundary
    public let artifactAndLineageBoundary: ArtifactAndLineageBoundary
    public let retirementBoundary: RetirementBoundary
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalByteCount = 20_617
    public static let canonicalSHA256 =
        "0a188a5a99d90d90828dca5eadeb0a167a71c6a9348201ff103be042d60ccf97"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_b_specific_native300m_trajectory_checkpoint_execution_failure_observation_v1",
        observationKind:
            "terminal_exact_main_stage7_supervisor_nonzero_no_public_receipt_orphan_sleep_observed_private_cause_unrecoverable",
        predecessorAuthorityID:
            "prime_native_decoder_native300m_trajectory_checkpoint_execution_authority_v1",
        predecessorAuthorityCanonicalSHA256:
            "4d995b21a20424f1b05fbcb9fbe33780dbd7af03cbf68047270db4aae192caa4",
        repositoryIdentity: .init(
            repository: "Ergentics/ergentics-prime",
            pullRequestNumber: 116,
            ref: "refs/heads/main",
            baseRevision: "300bad298bc9ff6f2752d1409639ff9e99318db6",
            baseTree: "d7c57b442e6c9a278b2ab58142ac86cbfa622930",
            reviewedHeadRevision:
                "c2077a68d5ac684528bf948cef3d3fa38b823a02",
            reviewedHeadTree: "63019d792346f8a6aeec461bdfc06721671385e8",
            reviewedHeadOrderedParents: [
                "300bad298bc9ff6f2752d1409639ff9e99318db6",
            ],
            mergeRevision: "88e001083c19f995f5ef5bd7c36f48356a90b997",
            mergeTree: "63019d792346f8a6aeec461bdfc06721671385e8",
            orderedParentRevisions: [
                "300bad298bc9ff6f2752d1409639ff9e99318db6",
                "c2077a68d5ac684528bf948cef3d3fa38b823a02",
            ],
            mergeCommitterAt: "2026-08-15T11:54:43Z",
            mergedAt: "2026-08-15T11:54:44Z",
            mergeCommitSignatureVerified: true,
            mergeCommitSignatureReason: "valid",
            historyPreservingTwoParentMergeObserved: true,
            mergeTreeEqualsReviewedHeadTree: true,
            exactMainRefMatchedAtTerminalAudit: true,
            changedPathCount: 9,
            changedManifestPathCount: 1,
            changedLockPathCount: 0,
            rootManifestPreserved: true,
            rootLockPreserved: true,
            validationLockPreserved: true,
            embeddedSourceIdentitySHA256:
                "026ac33c426c8368e3eecfc327637580590b580c9b094af7aef61a7158c9906a"),
        mechanicsSourceBindings: [
            source(
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                "100755", "d1c9cac53aec04645934bbafdc366db57e5b8255",
                983_780, 16_772,
                "dc36124507a78cd99c4e883f45513cd8085219243b5c5a759f0c06e50c36f0b6",
                "stage7_mechanics_active_gate"),
            source(
                ".github/scripts/prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution.sh",
                "100755", "6222fcc7d41e596116c54c2b7fecabb749bac31c",
                186_086, 3_486,
                "5d7a2d1a84996064923f1ffb027c321368399d9dd03a5ece10fee4d7e749f6de",
                "consumed_stage7_launcher_preserved_for_audit"),
            source(
                ".github/workflows/prime-active-root-quarantine.yml",
                "100644", "02775347d217695a3a8da92c69718dbb980f2158",
                118_793, 775,
                "e26b0b0a581c38ff698e4bebe13a4c57e33983d790ab462c65d79c086e62103a",
                "exact_main_stage7_split_workflow"),
            source(
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "100644", "d3593c1103941defafd203abdbd5a0517e3485bb",
                546, 13,
                "4e56c1f104b1fcd2dfb023f29e84b7084cefd086030dd9978d34b1ff13c46dfb",
                "embedded_changed_source_identity"),
            source(
                "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderNative300MTrajectoryCheckpointV1.swift",
                "100644", "994b11884ad271b796baf8298182a014324efc44",
                103_580, 2_428,
                "c410a41ac9dc00e5c3e530021cb5884c9e5d6a292099a62e648f5542ca75692e",
                "stage7_checkpoint_codec_mechanics"),
            source(
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
                "100644", "939b949cd86741e98cdb389863f1b9378107b78f",
                311_307, 7_129,
                "15d2407998ac485ba0603cdd0f0318f06e2b668e79e87df5675429a145dd5238",
                "stage7_supervisor_worker_verifier_mechanics"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "100644", "482a3c1a6bfbf0a5f853ae554b1e37f2badf21e8",
                3_619, 115,
                "f9faef3dd3247f1c1da302184aecfdc4e55f54580ea4e00ab9fd0c20b45eb362",
                "stage7_validation_manifest"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution/main.swift",
                "100644", "26e16be125faca470c81c6909c06a71d65f91829",
                250, 8,
                "0b6ec9c781ca0839df9a02a2e2e5f4caa49ae38e0c7f3f8a187bf338ec459ad4",
                "stage7_direct_executable_entry"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionContractTests.swift",
                "100644", "10dae9f4911b8965e700de7ae7160f730888fdc7",
                132_644, 2_875,
                "9dcdf7856814f3e7bf624c6a61c2eab191e7ecb759e50a4e11a3d84aaa7e303a",
                "stage7_execution_pure_contract"),
        ],
        pullRequestReviewBoundary: .init(
            pullRequestCreatedAt: "2026-08-15T11:46:31Z",
            pullRequestMergedAt: "2026-08-15T11:54:44Z",
            pullRequestCommitCount: 1,
            pullRequestChangedPathCount: 9,
            workflowRunID: 31_882_905_671,
            workflowRunNumber: 128,
            workflowRunAttempt: 1,
            workflowEvent: "pull_request",
            workflowHeadRevision:
                "c2077a68d5ac684528bf948cef3d3fa38b823a02",
            workflowCheckSuiteID: 86_483_861_376,
            workflowCreatedAt: "2026-08-15T11:46:34Z",
            workflowStartedAt: "2026-08-15T11:46:34Z",
            workflowUpdatedAt: "2026-08-15T11:49:30Z",
            workflowStatus: "completed",
            workflowConclusion: "success",
            previousAttemptURLWasNull: true,
            activeRootJobID: 95_007_853_688,
            activeRootJobStartedAt: "2026-08-15T11:46:37Z",
            activeRootJobCompletedAt: "2026-08-15T11:49:28Z",
            activeRootJobConclusion: "success",
            activeRootRunnerID: 1_000_001_783,
            activeRootTestStartCount: 116,
            activeRootTestPassCount: 116,
            activeRootTestFailureCount: 0,
            activeRootTestSkipCount: 0,
            reviewedMainCompileJobID: 95_008_130_205,
            reviewedMainCompileConclusion: "skipped",
            reviewedMainCompileStepCount: 0,
            stage7JobID: 95_008_130_384,
            stage7JobConclusion: "skipped",
            stage7JobStepCount: 0,
            stage7LauncherInvocationCount: 0,
            stage7ContractInvocationCount: 0,
            stage7ExecutableInvocationCount: 0,
            stage7ReceiptCount: 0,
            metalOrNative300MechanicsInvocationCount: 0,
            actionsArtifactCount: 0,
            rerunCount: 0),
        pullRequestActiveRootRawLog: rawLog(
            292_354, 1_846,
            "9f4a4beba90cbc170a74eda15fd7ad16daa549395cca658a5f02a62c9bf9e10f"),
        exactMainRunIdentity: .init(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_883_255_378,
            runNumber: 129,
            runAttempt: 1,
            event: "push",
            headBranch: "main",
            headRevision: "88e001083c19f995f5ef5bd7c36f48356a90b997",
            actor: "psyop-archivist",
            triggeringActor: "psyop-archivist",
            createdAt: "2026-08-15T11:54:46Z",
            startedAt: "2026-08-15T11:54:46Z",
            terminalUpdatedAt: "2026-08-15T13:03:57Z",
            status: "completed",
            conclusion: "failure",
            checkSuiteID: 86_484_623_523,
            exactHeadPushRunCount: 1,
            previousAttemptURLWasNull: true,
            rerunCount: 0,
            rerunObserved: false,
            rerunAuthorized: false,
            runURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31883255378"),
        activeRootJob: job(
            95_008_665_011,
            "First-party MLX / active-root quarantine", "success",
            "2026-08-15T11:54:49Z", "2026-08-15T11:58:02Z",
            1_000_001_784, "macos-15",
            [
                "Set up job",
                "Check out the exact Prime revision",
                "Validate active metadata and preserved history",
                "Parse the changed Swift contracts without dependencies",
                "Validate isolated Latin capture and observation contracts",
                "Record the authority ceiling",
                "Complete job",
            ],
            Array(repeating: "success", count: 7),
            [
                "2026-08-15T11:54:49Z", "2026-08-15T11:54:49Z",
                "2026-08-15T11:54:54Z", "2026-08-15T11:55:54Z",
                "2026-08-15T11:56:04Z", "2026-08-15T11:57:58Z",
                "2026-08-15T11:57:58Z",
            ],
            [
                "2026-08-15T11:54:49Z", "2026-08-15T11:54:54Z",
                "2026-08-15T11:55:54Z", "2026-08-15T11:56:04Z",
                "2026-08-15T11:57:58Z", "2026-08-15T11:57:58Z",
                "2026-08-15T11:57:59Z",
            ],
            0, "", 0, ""),
        reviewedMainCompileJob: job(
            95_008_982_463,
            "Reviewed main / focused source contracts", "success",
            "2026-08-15T11:58:04Z", "2026-08-15T12:46:27Z",
            1_000_001_785, "macos-26",
            [
                "Set up job", "Record the hosted Apple toolchain",
                "Check out reviewed main exactly",
                "Fetch the exact private dependency without evaluating Prime",
                "Compile and run the focused contracts without a credential",
                "Run the Prime-owned decoder on live Metal",
                "Complete job",
            ],
            Array(repeating: "success", count: 7),
            [
                "2026-08-15T11:58:04Z", "2026-08-15T11:58:05Z",
                "2026-08-15T11:58:08Z", "2026-08-15T11:58:12Z",
                "2026-08-15T11:58:21Z", "2026-08-15T12:22:56Z",
                "2026-08-15T12:46:12Z",
            ],
            [
                "2026-08-15T11:58:05Z", "2026-08-15T11:58:08Z",
                "2026-08-15T11:58:12Z", "2026-08-15T11:58:21Z",
                "2026-08-15T12:22:56Z", "2026-08-15T12:46:12Z",
                "2026-08-15T12:46:14Z",
            ],
            0, "", 0, ""),
        stage7Job: job(
            95_013_990_901,
            "Reviewed main / Stage-7 Native-300M trajectory checkpoint",
            "failure",
            "2026-08-15T12:46:29Z", "2026-08-15T13:03:56Z",
            1_000_001_786, "macos-26",
            [
                "Set up job",
                "Record the immutable Stage-7 job budget epoch",
                "Check out exact main for Stage-7",
                "Fetch the exact Stage-7 private dependency without evaluating Prime",
                "Reconstruct exact Stage-7 inputs and invoke the sole launcher",
                "Complete job",
            ],
            ["success", "success", "success", "success", "failure", "success"],
            [
                "2026-08-15T12:46:29Z", "2026-08-15T12:46:29Z",
                "2026-08-15T12:46:30Z", "2026-08-15T12:46:33Z",
                "2026-08-15T12:46:43Z", "2026-08-15T13:03:50Z",
            ],
            [
                "2026-08-15T12:46:29Z", "2026-08-15T12:46:30Z",
                "2026-08-15T12:46:33Z", "2026-08-15T12:46:43Z",
                "2026-08-15T13:03:50Z", "2026-08-15T13:03:53Z",
            ],
            1, ".github", 74_288,
            "Process completed with exit code 2."),
        activeRootRawLog: rawLog(
            292_453, 1_847,
            "36f626e4a038d513fbb0629db54c9806690eb644135bfdd13009a8abeb1cb584"),
        reviewedMainCompileRawLog: rawLog(
            10_348_477, 79_295,
            "c565edf57bba08e2430ec82570a75604f9b9730300fe17102eac4cb4ff337e22"),
        stage7RawLog: rawLog(
            9_829_534, 74_429,
            "b446819db9570743f162d9ea9015d4927689e854d5aba16f9c4ce65543e59be2"),
        testTopology: .init(
            activeLatinTestStartCount: 116,
            activeLatinTestPassCount: 116,
            activeLatinFailureCount: 0,
            activeLatinSkipCount: 0,
            focusedRootTestCount: 62,
            isolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
            isolatedCheckpointTestCount: 6,
            focusedStage7ContractTestCount: 1,
            focusedWholeStepTestCount: 69,
            metalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            tokenizerTestCount: 1,
            liveTestCount: 46,
            reviewedCompileTestCount: 115,
            reviewedCompileFailureCount: 0,
            reviewedCompileSkipCount: 0,
            stage7LauncherLocalContractTestCount: 1,
            stage7LauncherLocalContractPassCount: 1,
            aggregateReviewedXCTestCount: 116,
            directOperationalProbeInvocationCount: 1,
            directOperationalProbeSuccessCount: 0,
            observedLiveExecutionOrder: [
                "focused", "metal", "maintained_runtime", "tokenizer",
                "stage7_launcher_local_contract", "stage7_supervisor",
            ]),
        executionFailureBoundary: .init(
            failedJobStepNumber: 5,
            failedJobStepName:
                "Reconstruct exact Stage-7 inputs and invoke the sole launcher",
            failedJobStepStartedAt: "2026-08-15T12:46:43Z",
            failedJobStepCompletedAt: "2026-08-15T13:03:50Z",
            releaseBuildInvocationCount: 1,
            releaseBuildCompletionCount: 1,
            releaseBuildDurationMilliseconds: 633_920,
            launcherLocalPureContractInvocationCount: 1,
            launcherLocalPureContractStartCount: 1,
            launcherLocalPureContractPassCount: 1,
            launcherLocalPureContractFailureCount: 0,
            launcherLocalPureContractSkipCount: 0,
            launcherLocalPureContractDurationMilliseconds: 8_901,
            launcherInvocationCount: 1,
            directSupervisorExecutableInvocationCount: 1,
            oneShotBoundaryReached: true,
            oneShotConsumed: true,
            oneShotExhausted: true,
            supervisorNonzeroMarkerLine:
                "swift-driver version: 1.148.6 prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution: sole supervisor invocation did not exit zero",
            supervisorNonzeroMarkerOccurrenceCount: 1,
            exactSupervisorExitStatusEvidence:
                "unknown_nonzero_launcher_disclosed_no_numeric_supervisor_status",
            launcherExitCode: 2,
            workflowProcessExitMessage: "Process completed with exit code 2.",
            workflowProcessExitMessageOccurrenceCount: 1,
            publicReceiptPrefix:
                "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RECEIPT_V1=",
            hostedLogPublicReceiptPrefixOccurrenceCount: 0,
            privateCandidateSchemaID:
                "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_candidate_v1",
            hostedLogPrivateCandidateSchemaIDOccurrenceCount: 0,
            privateTerminalSchemaID:
                "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_terminal_v1",
            hostedLogPrivateTerminalSchemaIDOccurrenceCount: 0,
            publicReceiptSchemaID:
                "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_receipt_v1",
            hostedLogPublicReceiptSchemaIDOccurrenceCount: 0,
            hostedLogExternalFailsafeStartedMarkerCount: 0,
            hostedLogExternalFailsafeFailedMarkerCount: 0,
            privateSupervisorCauseRecoverable: false,
            privateSupervisorCauseEvidence:
                "unrecoverable_private_stdout_stderr_and_frames_not_published",
            supervisorStdoutEvidence:
                "unknown_private_capture_not_published",
            supervisorStderrEvidence:
                "unknown_private_capture_not_published",
            privateCandidateFrameEvidence:
                "unknown_no_publicly_recoverable_frame",
            privateTerminalFrameEvidence:
                "unknown_no_publicly_recoverable_frame",
            workerProcessEvidence: "unknown",
            releaseVerifierProcessEvidence: "unknown",
            leaseEvidence: "unknown",
            checkpointPublicationEvidence: "unknown",
            comparisonDomainEvidence: "unknown",
            resourcePhaseEvidence: "unknown",
            artifactCleanupAndAbsenceEvidence: "unknown",
            scientificOutcomeEvidence:
                "unknown_not_a_valid_terminal_scientific_classification",
            resourceOutcomeEvidence: "unknown",
            exactResumeEvidence: "unknown",
            validPublicTerminalEstablished: false,
            mechanicsSuccessEstablished: false,
            workflowFailureEstablished: true,
            integrityClosureEstablished: false),
        orphanProcessBoundary: .init(
            githubRunnerOrphanCleanupObserved: true,
            observedOrphanProcessCount: 1,
            observedOrphanPID: 29_906,
            observedOrphanProcessName: "sleep",
            observedOrphanTerminationLine:
                "Terminate orphan process: pid (29906) (sleep)",
            observedOrphanTerminationLineOccurrenceCount: 1,
            observedOrphanTerminationAt: "2026-08-15T13:03:51.2835430Z",
            noOrphanClosureEstablished: false,
            observedProcessRoleEvidence: "unknown_unattributed_sleep_process",
            watchdogChildAttributionDirectlyObserved: false,
            watchdogChildExplanation:
                "source_consistent_external_watchdog_sleep_child_survived_watchdog_subshell_termination",
            watchdogChildExplanationIsInferenceOnly: true,
            watchdogSleepSecondsInFrozenSource: 5_120,
            explanationConsistentWithFrozenSource: true,
            supervisorWorkerOrVerifierOrphanEstablished: false),
        artifactAndLineageBoundary: .init(
            pullRequestRunArtifactCount: 0,
            exactMainRunArtifactCount: 0,
            artifactUploadStepCount: 0,
            exactMainRunCountForHead: 1,
            runAttemptCount: 1,
            previousAttemptURLWasNull: true,
            retryCount: 0,
            rerunCount: 0,
            replacementExecutionCount: 0,
            publicReceiptCount: 0,
            retainedArtifactEstablished: false,
            runnerLocalArtifactAbsenceEstablished: false,
            checkpointCleanupEstablished: false,
            durableFailureReceiptPublished: false),
        retirementBoundary: .init(
            retirementRequired: true,
            retirementObserved: false,
            exactChangedPathCount: 5,
            exactOrderedChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationTests.swift",
            ],
            expectedActiveLatinTestCount: 116,
            expectedRootTestCount: 63,
            expectedIsolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
            expectedIsolatedCheckpointTestCount: 6,
            expectedFocusedWholeStepTestCount: 69,
            expectedMetalTestCount: 44,
            expectedRuntimeTestCount: 1,
            expectedTokenizerTestCount: 1,
            expectedLiveTestCount: 46,
            expectedTotalTestCount: 115,
            expectedStage7JobCount: 0,
            expectedStage7FocusedContractInvocationCount: 0,
            expectedStage7LauncherLocalContractInvocationCount: 0,
            expectedStage7LauncherInvocationCount: 0,
            expectedStage7ExecutableInvocationCount: 0,
            expectedStage7ReceiptCount: 0,
            stage7MechanicsPayloadsMustRemainPreserved: true,
            replacementOrRepairExecutionPermittedByRetirement: false),
        authorityCeiling: .init(
            oneShotExecutionConsumed: true,
            oneShotExecutionExhausted: true,
            failureObservationAuthorizesNothing: true,
            exactRetirementRequired: true,
            mechanicsPayloadPreservationRequired: true,
            workflowFailureEstablished: true,
            requiredPublicTerminalIntegrityClosureFailureEstablished: true,
            privateFailureCauseRecovered: false,
            validStage7TerminalEstablished: false,
            stage7MechanicsSuccessEstablished: false,
            passExactEstablished: false,
            measuredExactMismatchEstablished: false,
            abstainResourceEstablished: false,
            abstainIntegrityEstablished: false,
            scientificOutcomeEstablished: false,
            resourceOutcomeEstablished: false,
            exactResumeEstablished: false,
            checkpointBindingEstablished: false,
            checkpointCleanupAndAbsenceEstablished: false,
            releaseVerifierClosureEstablished: false,
            noOrphanClosureEstablished: false,
            retryAuthorized: false,
            rerunAuthorized: false,
            replacementExecutionAuthorized: false,
            launcherMutationAuthorized: false,
            additionalNative300MExecutionAuthorized: false,
            checkpointAdmissionGranted: false,
            generalTrainingResumeEstablished: false,
            modelQualityEstablished: false,
            candidateAdmissionGranted: false,
            stage8AuthorityEstablished: false,
            stage8Authorized: false,
            downstreamTrialAuthorized: false,
            canaryAuthorized: false,
            quantizationAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        orderedRequiredSeparateActions: [
            "retire_consumed_stage7_invocation_without_retry_rerun_or_replacement",
            "preserve_exact_nine_stage7_mechanics_payloads_for_audit",
            "freeze_private_supervisor_worker_verifier_and_scientific_cause_as_unrecoverable",
            "record_orphan_sleep_as_observed_and_watchdog_child_attribution_as_inference_only",
            "require_separate_authority_before_any_watchdog_repair_or_native300m_execution",
            "keep_stage8_and_all_downstream_authority_false",
        ],
        status:
            "FAIL_exact_main_stage7_release_and_pure_pass_supervisor_nonzero_no_public_receipt_private_cause_unrecoverable_orphan_sleep_observed_one_shot_consumed_no_retry_no_stage8")

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationError
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
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            guard predecessorAuthorityID == predecessor.authorityID,
                  predecessorAuthorityCanonicalSHA256
                    == PrimeSHA256.hexDigest(
                        of: try predecessor.canonicalData()),
                  predecessorAuthorityCanonicalSHA256
                    == PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                        .canonicalSHA256 else {
                throw
                    PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationError
                        .contractDrift
            }
        } catch {
            throw
                PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationError
                    .contractDrift
        }

        let repository = repositoryIdentity
        let review = pullRequestReviewBoundary
        let run = exactMainRunIdentity
        let topology = testTopology
        let failure = executionFailureBoundary
        let orphan = orphanProcessBoundary
        let lineage = artifactAndLineageBoundary
        let retirement = retirementBoundary
        let ceiling = authorityCeiling
        let canonical = try canonicalData()
        let falseClaims = [
            ceiling.privateFailureCauseRecovered,
            ceiling.validStage7TerminalEstablished,
            ceiling.stage7MechanicsSuccessEstablished,
            ceiling.passExactEstablished,
            ceiling.measuredExactMismatchEstablished,
            ceiling.abstainResourceEstablished,
            ceiling.abstainIntegrityEstablished,
            ceiling.scientificOutcomeEstablished,
            ceiling.resourceOutcomeEstablished,
            ceiling.exactResumeEstablished,
            ceiling.checkpointBindingEstablished,
            ceiling.checkpointCleanupAndAbsenceEstablished,
            ceiling.releaseVerifierClosureEstablished,
            ceiling.noOrphanClosureEstablished,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.replacementExecutionAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.additionalNative300MExecutionAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.generalTrainingResumeEstablished,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.stage8AuthorityEstablished,
            ceiling.stage8Authorized,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256,
              repository.reviewedHeadOrderedParents == [repository.baseRevision],
              repository.orderedParentRevisions
                == [repository.baseRevision, repository.reviewedHeadRevision],
              repository.mergeTree == repository.reviewedHeadTree,
              repository.mergeRevision == run.headRevision,
              repository.changedPathCount == mechanicsSourceBindings.count,
              repository.changedManifestPathCount == 1,
              repository.changedLockPathCount == 0,
              repository.rootManifestPreserved,
              repository.rootLockPreserved,
              repository.validationLockPreserved,
              mechanicsSourceBindings.count == 9,
              Set(mechanicsSourceBindings.map(\.path)).count == 9,
              mechanicsSourceBindings.allSatisfy(Self.validSource),
              review.pullRequestChangedPathCount
                == repository.changedPathCount,
              review.workflowRunAttempt == 1,
              review.workflowConclusion == "success",
              review.activeRootTestStartCount == 116,
              review.activeRootTestPassCount == 116,
              review.activeRootTestFailureCount == 0,
              review.activeRootTestSkipCount == 0,
              review.reviewedMainCompileConclusion == "skipped",
              review.reviewedMainCompileStepCount == 0,
              review.stage7JobConclusion == "skipped",
              review.stage7JobStepCount == 0,
              review.stage7LauncherInvocationCount == 0,
              review.stage7ContractInvocationCount == 0,
              review.stage7ExecutableInvocationCount == 0,
              review.stage7ReceiptCount == 0,
              review.metalOrNative300MechanicsInvocationCount == 0,
              review.actionsArtifactCount == 0,
              review.rerunCount == 0,
              Self.validRawLog(pullRequestActiveRootRawLog),
              run.runAttempt == 1,
              run.exactHeadPushRunCount == 1,
              run.previousAttemptURLWasNull,
              run.rerunCount == 0,
              !run.rerunObserved,
              !run.rerunAuthorized,
              activeRootJob.orderedStepConclusions
                == Array(repeating: "success", count: 7),
              reviewedMainCompileJob.orderedStepConclusions
                == Array(repeating: "success", count: 7),
              stage7Job.orderedStepConclusions
                == ["success", "success", "success", "success", "failure", "success"],
              Self.validJob(activeRootJob),
              Self.validJob(reviewedMainCompileJob),
              Self.validJob(stage7Job),
              Self.validRawLog(activeRootRawLog),
              Self.validRawLog(reviewedMainCompileRawLog),
              Self.validRawLog(stage7RawLog),
              topology.activeLatinTestStartCount == 116,
              topology.activeLatinTestPassCount == 116,
              topology.activeLatinFailureCount == 0,
              topology.activeLatinSkipCount == 0,
              topology.isolatedCheckpointGroupTestCounts == [1, 1, 2, 2],
              topology.isolatedCheckpointTestCount
                == topology.isolatedCheckpointGroupTestCounts.reduce(0, +),
              topology.focusedWholeStepTestCount
                == topology.focusedRootTestCount
                    + topology.isolatedCheckpointTestCount
                    + topology.focusedStage7ContractTestCount,
              topology.liveTestCount
                == topology.metalTestCount
                    + topology.maintainedRuntimeTestCount
                    + topology.tokenizerTestCount,
              topology.reviewedCompileTestCount
                == topology.focusedWholeStepTestCount + topology.liveTestCount,
              topology.aggregateReviewedXCTestCount
                == topology.reviewedCompileTestCount
                    + topology.stage7LauncherLocalContractTestCount,
              topology.reviewedCompileFailureCount == 0,
              topology.reviewedCompileSkipCount == 0,
              topology.stage7LauncherLocalContractTestCount == 1,
              topology.stage7LauncherLocalContractPassCount == 1,
              topology.directOperationalProbeInvocationCount == 1,
              topology.directOperationalProbeSuccessCount == 0,
              failure.failedJobStepNumber == 5,
              failure.releaseBuildInvocationCount == 1,
              failure.releaseBuildCompletionCount == 1,
              failure.launcherLocalPureContractInvocationCount == 1,
              failure.launcherLocalPureContractStartCount == 1,
              failure.launcherLocalPureContractPassCount == 1,
              failure.launcherLocalPureContractFailureCount == 0,
              failure.launcherLocalPureContractSkipCount == 0,
              failure.launcherInvocationCount == 1,
              failure.directSupervisorExecutableInvocationCount == 1,
              failure.oneShotBoundaryReached,
              failure.oneShotConsumed,
              failure.oneShotExhausted,
              failure.supervisorNonzeroMarkerOccurrenceCount == 1,
              failure.exactSupervisorExitStatusEvidence
                == "unknown_nonzero_launcher_disclosed_no_numeric_supervisor_status",
              failure.launcherExitCode == 2,
              failure.workflowProcessExitMessageOccurrenceCount == 1,
              failure.publicReceiptPrefix
                == predecessor.integrity.publicReceiptPrefix,
              failure.hostedLogPublicReceiptPrefixOccurrenceCount == 0,
              failure.privateCandidateSchemaID
                == predecessor.integrity.privateCandidateSchemaID,
              failure.hostedLogPrivateCandidateSchemaIDOccurrenceCount == 0,
              failure.privateTerminalSchemaID
                == predecessor.integrity.privateTerminalSchemaID,
              failure.hostedLogPrivateTerminalSchemaIDOccurrenceCount == 0,
              failure.publicReceiptSchemaID
                == predecessor.integrity.publicReceiptSchemaID,
              failure.hostedLogPublicReceiptSchemaIDOccurrenceCount == 0,
              failure.hostedLogExternalFailsafeStartedMarkerCount == 0,
              failure.hostedLogExternalFailsafeFailedMarkerCount == 0,
              !failure.privateSupervisorCauseRecoverable,
              failure.workerProcessEvidence == "unknown",
              failure.releaseVerifierProcessEvidence == "unknown",
              failure.leaseEvidence == "unknown",
              failure.checkpointPublicationEvidence == "unknown",
              failure.comparisonDomainEvidence == "unknown",
              failure.resourcePhaseEvidence == "unknown",
              failure.artifactCleanupAndAbsenceEvidence == "unknown",
              failure.resourceOutcomeEvidence == "unknown",
              failure.exactResumeEvidence == "unknown",
              !failure.validPublicTerminalEstablished,
              !failure.mechanicsSuccessEstablished,
              failure.workflowFailureEstablished,
              !failure.integrityClosureEstablished,
              orphan.githubRunnerOrphanCleanupObserved,
              orphan.observedOrphanProcessCount == 1,
              orphan.observedOrphanPID == 29_906,
              orphan.observedOrphanProcessName == "sleep",
              orphan.observedOrphanTerminationLineOccurrenceCount == 1,
              !orphan.noOrphanClosureEstablished,
              orphan.observedProcessRoleEvidence
                == "unknown_unattributed_sleep_process",
              !orphan.watchdogChildAttributionDirectlyObserved,
              orphan.watchdogChildExplanationIsInferenceOnly,
              orphan.explanationConsistentWithFrozenSource,
              !orphan.supervisorWorkerOrVerifierOrphanEstablished,
              lineage.pullRequestRunArtifactCount == 0,
              lineage.exactMainRunArtifactCount == 0,
              lineage.artifactUploadStepCount == 0,
              lineage.exactMainRunCountForHead == 1,
              lineage.runAttemptCount == 1,
              lineage.previousAttemptURLWasNull,
              lineage.retryCount == 0,
              lineage.rerunCount == 0,
              lineage.replacementExecutionCount == 0,
              lineage.publicReceiptCount == 0,
              !lineage.retainedArtifactEstablished,
              !lineage.runnerLocalArtifactAbsenceEstablished,
              !lineage.checkpointCleanupEstablished,
              !lineage.durableFailureReceiptPublished,
              retirement.retirementRequired,
              !retirement.retirementObserved,
              retirement.exactChangedPathCount
                == retirement.exactOrderedChangedPaths.count,
              Set(retirement.exactOrderedChangedPaths).count == 5,
              retirement.expectedActiveLatinTestCount == 116,
              retirement.expectedActiveLatinTestCount
                == topology.activeLatinTestStartCount,
              retirement.expectedActiveLatinTestCount
                == topology.activeLatinTestPassCount,
              retirement.expectedIsolatedCheckpointGroupTestCounts
                == [1, 1, 2, 2],
              retirement.expectedIsolatedCheckpointTestCount == 6,
              retirement.expectedFocusedWholeStepTestCount
                == retirement.expectedRootTestCount
                    + retirement.expectedIsolatedCheckpointTestCount,
              retirement.expectedLiveTestCount
                == retirement.expectedMetalTestCount
                    + retirement.expectedRuntimeTestCount
                    + retirement.expectedTokenizerTestCount,
              retirement.expectedTotalTestCount
                == retirement.expectedFocusedWholeStepTestCount
                    + retirement.expectedLiveTestCount,
              retirement.expectedStage7JobCount == 0,
              retirement.expectedStage7FocusedContractInvocationCount == 0,
              retirement.expectedStage7LauncherLocalContractInvocationCount == 0,
              retirement.expectedStage7LauncherInvocationCount == 0,
              retirement.expectedStage7ExecutableInvocationCount == 0,
              retirement.expectedStage7ReceiptCount == 0,
              retirement.stage7MechanicsPayloadsMustRemainPreserved,
              !retirement.replacementOrRepairExecutionPermittedByRetirement,
              ceiling.oneShotExecutionConsumed,
              ceiling.oneShotExecutionExhausted,
              ceiling.failureObservationAuthorizesNothing,
              ceiling.exactRetirementRequired,
              ceiling.mechanicsPayloadPreservationRequired,
              ceiling.workflowFailureEstablished,
              ceiling.requiredPublicTerminalIntegrityClosureFailureEstablished,
              falseClaims.allSatisfy({ !$0 }) else {
            throw
                PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationError
                    .contractDrift
        }
    }

    private static func source(
        _ path: String,
        _ mode: String,
        _ blob: String,
        _ bytes: Int,
        _ lines: Int,
        _ sha256: String,
        _ scope: String
    ) -> SourceIdentity {
        .init(
            path: path,
            gitMode: mode,
            gitBlob: blob,
            byteCount: bytes,
            lfByteCount: lines,
            sha256: sha256,
            claimScope: scope)
    }

    private static func job(
        _ id: Int,
        _ name: String,
        _ conclusion: String,
        _ startedAt: String,
        _ completedAt: String,
        _ runnerID: Int,
        _ runnerLabel: String,
        _ stepNames: [String],
        _ stepConclusions: [String],
        _ stepStartedAt: [String],
        _ stepCompletedAt: [String],
        _ annotationCount: Int,
        _ annotationPath: String,
        _ annotationLine: Int,
        _ annotationMessage: String
    ) -> JobIdentity {
        .init(
            id: id,
            name: name,
            status: "completed",
            conclusion: conclusion,
            startedAt: startedAt,
            completedAt: completedAt,
            runnerID: runnerID,
            runnerName: "GitHub Actions \(runnerID)",
            runnerGroupName: "GitHub Actions",
            runnerLabel: runnerLabel,
            orderedStepNames: stepNames,
            orderedStepConclusions: stepConclusions,
            orderedStepStartedAt: stepStartedAt,
            orderedStepCompletedAt: stepCompletedAt,
            checkAnnotationCount: annotationCount,
            checkAnnotationPath: annotationPath,
            checkAnnotationLine: annotationLine,
            checkAnnotationMessage: annotationMessage,
            jobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31883255378/job/\(id)")
    }

    private static func rawLog(
        _ bytes: Int,
        _ lines: Int,
        _ sha256: String
    ) -> RawLogIdentity {
        .init(
            byteCount: bytes,
            lfByteCount: lines,
            newlineDelimitedComponentCountIncludingTerminalEmpty: lines + 1,
            utf8BOMHex: "efbbbf",
            startsWithUTF8BOM: true,
            usesLFOnly: true,
            endsWithLF: true,
            sha256: sha256,
            repeatFetchExactlyEqual: true,
            bindingKind: "github_job_log_endpoint_decoded_utf8_bytes_v1",
            rawGitHubLogArchiveBytesBound: false,
            retainedInRepository: false)
    }

    private static func validSource(_ source: SourceIdentity) -> Bool {
        !source.path.isEmpty
            && ["100644", "100755"].contains(source.gitMode)
            && validLowercaseHex(source.gitBlob, count: 40)
            && source.byteCount > 0
            && source.lfByteCount > 0
            && validLowercaseHex(source.sha256, count: 64)
            && !source.claimScope.isEmpty
    }

    private static func validJob(_ job: JobIdentity) -> Bool {
        job.id > 0
            && job.status == "completed"
            && ["success", "failure"].contains(job.conclusion)
            && job.runnerID > 0
            && job.runnerName == "GitHub Actions \(job.runnerID)"
            && job.runnerGroupName == "GitHub Actions"
            && ["macos-15", "macos-26"].contains(job.runnerLabel)
            && !job.orderedStepNames.isEmpty
            && job.orderedStepNames.count == job.orderedStepConclusions.count
            && job.orderedStepNames.count == job.orderedStepStartedAt.count
            && job.orderedStepNames.count == job.orderedStepCompletedAt.count
            && job.orderedStepNames.allSatisfy({ !$0.isEmpty })
            && job.orderedStepConclusions.allSatisfy {
                ["success", "failure"].contains($0)
            }
    }

    private static func validRawLog(_ log: RawLogIdentity) -> Bool {
        log.byteCount > 0
            && log.lfByteCount > 0
            && log.newlineDelimitedComponentCountIncludingTerminalEmpty
                == log.lfByteCount + 1
            && log.utf8BOMHex == "efbbbf"
            && log.startsWithUTF8BOM
            && log.usesLFOnly
            && log.endsWithLF
            && validLowercaseHex(log.sha256, count: 64)
            && log.repeatFetchExactlyEqual
            && !log.rawGitHubLogArchiveBytesBound
            && !log.retainedInRepository
    }

    private static func validLowercaseHex(
        _ value: String,
        count: Int
    ) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy { scalar in
                (scalar.value >= 48 && scalar.value <= 57)
                    || (scalar.value >= 97 && scalar.value <= 102)
            }
    }
}
