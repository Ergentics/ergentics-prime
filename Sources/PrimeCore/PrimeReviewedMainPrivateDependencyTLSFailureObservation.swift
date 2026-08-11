// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeReviewedMainPrivateDependencyTLSFailureObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct PrimeReviewedMainTLSFailureSourceIdentityV1:
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

public struct PrimeReviewedMainTLSFailureRepositoryIdentityV1:
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

public struct PrimeReviewedMainTLSFailureRunIdentityV1:
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

public struct PrimeReviewedMainTLSFailureJobStepV1:
    Codable,
    Equatable,
    Sendable
{
    public let number: Int
    public let name: String
    public let conclusion: String
}

public struct PrimeReviewedMainTLSFailureJobObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let id: Int
    public let name: String
    public let url: String
    public let createdAt: String
    public let startedAt: String
    public let completedAt: String
    public let status: String
    public let conclusion: String
    public let runnerLabel: String
    public let runnerName: String
    public let runnerGroupName: String
    public let orderedSteps: [PrimeReviewedMainTLSFailureJobStepV1]
    public let checkAnnotationCount: Int
    public let checkAnnotationPath: String
    public let checkAnnotationStartLine: Int
    public let checkAnnotationEndLine: Int
    public let checkAnnotationLevel: String
    public let checkAnnotationMessage: String
}

public struct PrimeReviewedMainTLSFailureRunnerToolchainV1:
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

public struct PrimeReviewedMainTLSFailureRawLogIdentityV1:
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

public struct PrimeReviewedMainTLSFailureArchiveMemberIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
}

public struct PrimeReviewedMainTLSFailureLogArchiveIdentityV1:
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
    public let skippedReviewedStepMembersAbsent: Bool
    public let failureStepMemberDiagnosticTimestamp: String
    public let reviewedAggregateDiagnosticTimestamp: String
    public let failureStepMemberExitTimestamp: String
    public let reviewedAggregateExitTimestamp: String
    public let members: [PrimeReviewedMainTLSFailureArchiveMemberIdentityV1]
}

public struct PrimeReviewedMainTLSFailureExecutionBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let activeRootGatePassed: Bool
    public let dependencyFreeSwiftParsePassed: Bool
    public let latinTestInvocationCount: Int
    public let latinCompletedTestCount: Int
    public let latinFailureCount: Int
    public let latinSkipCount: Int
    public let latinFinalSummaryOccurrenceCount: Int
    public let focusedContractsStepNumber: Int
    public let focusedContractsStepConclusion: String
    public let requiredFocusedRootTestCount: Int
    public let focusedRootInvocationCount: Int
    public let focusedRootCompletedTestCount: Int
    public let focusedRootFailureCount: Int
    public let focusedRootSkipCount: Int
    public let focusedRootSuccessSummaryCount: Int
    public let retainedLiveStepNumber: Int
    public let retainedLiveStepConclusion: String
    public let retainedLiveSequence: [String]
    public let retainedLiveSequenceWorkflowCounts: [Int]
    public let retainedLiveSequenceInvocationCounts: [Int]
    public let requiredMetalTestCount: Int
    public let completedMetalTestCount: Int
    public let metalFailureCount: Int
    public let metalSkipCount: Int
    public let runtimeReceiptCount: Int
    public let tokenizerReceiptCount: Int
    public let stage2ValidationPackageCommandCount: Int
    public let stage2ValidationFilterCount: Int
    public let stage2ValidationLogPathCount: Int
    public let stage2ValidationScratchPathCount: Int
    public let stage2InvocationCount: Int
    public let stage2TestStartCount: Int
    public let stage2CompletedPassCount: Int
    public let stage2CompletedFailureCount: Int
    public let stage2CompletedSkipCount: Int
    public let retiredSeed42CheckpointCommandCount: Int
    public let retiredSeed43CheckpointCommandCount: Int
    public let checkpointReceiptMarkerCount: Int
    public let artifactUploadStepCount: Int
}

public struct PrimeReviewedMainTLSFailureBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let failedJobStepNumber: Int
    public let failedJobStepName: String
    public let failedStepStartedAt: String
    public let failedStepCompletedAt: String
    public let privateDependencyRepository: String
    public let privateDependencyRevision: String
    public let exactFetchCommand: String
    public let credentialNonemptyPreconditionReturned: Bool
    public let credentialWasMaskedInLog: Bool
    public let credentialValueDisclosed: Bool
    public let bareRepositoryInitializationCompleted: Bool
    public let privateDependencyRemoteAdded: Bool
    public let credentialURLRewriteConfigured: Bool
    public let transportFetchInvocationCount: Int
    public let dependencyFetchCompleted: Bool
    public let fetchHeadValidationCount: Int
    public let pinnedReferenceUpdateCount: Int
    public let dependencyWorktreeAddCount: Int
    public let dependencySubmoduleUpdateCount: Int
    public let dependencyPackageEvaluationCount: Int
    public let credentialLeakScanCount: Int
    public let exactDiagnostic: String
    public let failureStepMemberDiagnosticTimestamp: String
    public let reviewedAggregateDiagnosticTimestamp: String
    public let diagnosticOccurrenceCount: Int
    public let processExitCode: Int
    public let exactExitMessage: String
    public let failureStepMemberExitTimestamp: String
    public let reviewedAggregateExitTimestamp: String
    public let exactMergeCheckoutCompleted: Bool
    public let exactMergeCheckoutRemainedClean: Bool
    public let failureClassification: String
}

public struct PrimeReviewedMainTLSFailureSemanticsV1:
    Codable,
    Equatable,
    Sendable
{
    public let inferenceBasis: String
    public let externalTLSFailureObserved: Bool
    public let selfSignedCertificateDiagnosticObserved: Bool
    public let gitTransportFailureObserved: Bool
    public let certificateVerificationFailureObserved: Bool
    public let failurePrecedesDependencyEvaluation: Bool
    public let failurePrecedesReviewedMainSwiftCompilation: Bool
    public let failurePrecedesFocusedRootExecution: Bool
    public let failurePrecedesRetainedLiveSequence: Bool
    public let predecessorStage2ObservationRemainsFrozen: Bool
    public let predecessorStage2AttemptRemainsExhausted: Bool
    public let runnerTLSRepairRequiredBeforeDistinctRun: Bool
    public let stage3RemainsBlocked: Bool
    public let repositorySourceDefectEstablished: Bool
    public let workflowSourceDefectEstablished: Bool
    public let dependencyRevisionDefectEstablished: Bool
    public let dependencyRepositoryAbsenceEstablished: Bool
    public let credentialAbsenceEstablished: Bool
    public let credentialRejectionObserved: Bool
    public let credentialValidityEstablished: Bool
    public let stage2SemanticsEvaluated: Bool
    public let stage2SemanticFailureObserved: Bool
    public let stage2BootstrapFailureObserved: Bool
    public let stage2RepairAttempted: Bool
    public let stage2OutcomeEstablished: Bool
    public let runnerTLSRepairEstablished: Bool
    public let failureClassificationLimitedToObservedExternalTLSBoundary: Bool
}

public struct PrimeReviewedMainTLSFailureArtifactBoundaryV1:
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

public struct PrimeReviewedMainTLSFailureAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let rerunAuthorized: Bool
    public let replacementRunAuthorized: Bool
    public let runnerTLSRepairAuthorized: Bool
    public let TLSVerificationBypassAuthorized: Bool
    public let customCAInstallationAuthorized: Bool
    public let workflowMutationAuthorized: Bool
    public let repositorySourceCorrectionAuthorized: Bool
    public let credentialRotationAuthorized: Bool
    public let credentialMutationAuthorized: Bool
    public let dependencyRevisionChangeAuthorized: Bool
    public let focusedRootContractsEstablished: Bool
    public let metalValidationEstablished: Bool
    public let runtimeClosureEstablished: Bool
    public let tokenizerCompatibilityEstablished: Bool
    public let stage2ExecutionEstablished: Bool
    public let stage2BootstrapRepairEstablished: Bool
    public let stage2SuccessEstablished: Bool
    public let stage3AuthorityEstablished: Bool
    public let checkpointReadEstablished: Bool
    public let checkpointWriteEstablished: Bool
    public let checkpointRoundTripEstablished: Bool
    public let checkpointArtifactAvailabilityEstablished: Bool
    public let checkpointArtifactRetentionEstablished: Bool
    public let checkpointArtifactUploadAuthorized: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let metalTensorExecutionEstablished: Bool
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
}

/// Append-only terminal observation of an exact-main reviewed-lane transport
/// failure. The merge and active-root job were exact and clean. Reviewed main
/// then failed while Git fetched the pinned private MLX dependency because the
/// hosted transport rejected a self-signed TLS certificate.
///
/// The nonempty credential precondition returned and its value remained
/// masked. The transport failed before dependency evaluation, reviewed-main
/// Swift compilation, the focused 35-test root suite, or the retained live
/// Metal-runtime-tokenizer sequence. The exhausted Stage-2 invocation remained
/// absent. This observation therefore establishes neither a repository-source
/// defect, a credential rejection, Stage-2 semantics, a repair, a retry, nor
/// any downstream authority.
public struct PrimeReviewedMainPrivateDependencyTLSFailureObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorObservationID: String
    public let predecessorCanonicalSHA256: String
    public let repositoryIdentity: PrimeReviewedMainTLSFailureRepositoryIdentityV1
    public let observedSourceBindings: [PrimeReviewedMainTLSFailureSourceIdentityV1]
    public let runIdentity: PrimeReviewedMainTLSFailureRunIdentityV1
    public let activeRootJob: PrimeReviewedMainTLSFailureJobObservationV1
    public let reviewedMainJob: PrimeReviewedMainTLSFailureJobObservationV1
    public let runnerToolchain: PrimeReviewedMainTLSFailureRunnerToolchainV1
    public let activeRootRawLog: PrimeReviewedMainTLSFailureRawLogIdentityV1
    public let reviewedMainRawLog: PrimeReviewedMainTLSFailureRawLogIdentityV1
    public let failureStepRawLog: PrimeReviewedMainTLSFailureRawLogIdentityV1
    public let rawLogArchive: PrimeReviewedMainTLSFailureLogArchiveIdentityV1
    public let executionBoundary: PrimeReviewedMainTLSFailureExecutionBoundaryV1
    public let failureBoundary: PrimeReviewedMainTLSFailureBoundaryV1
    public let failureSemantics: PrimeReviewedMainTLSFailureSemanticsV1
    public let artifactBoundary: PrimeReviewedMainTLSFailureArtifactBoundaryV1
    public let authorityCeiling: PrimeReviewedMainTLSFailureAuthorityCeilingV1
    public let status: String
    public let orderedRequiredSeparateActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_reviewed_main_private_dependency_tls_failure_observation_v1",
        observationKind:
            "exact_main_external_tls_failure_before_private_dependency_evaluation",
        predecessorObservationID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_execution_failure_observation_v1",
        predecessorCanonicalSHA256:
            "3822447081af914836f0c158adfb6fd5cbad611a24082ebffd516bffc0f0f002",
        repositoryIdentity: PrimeReviewedMainTLSFailureRepositoryIdentityV1(
            repository: "Ergentics/ergentics-prime",
            pullRequestNumber: 84,
            ref: "refs/heads/main",
            revision: "e540b73f6a46cf6e0de5b932d7167f178d4ac6fb",
            orderedParentRevisions: [
                "8d544c34a09a770198b50126f50adb766f234a8f",
                "64eed284f0b5630a23feeea1e74dcd74fe275571",
            ],
            tree: "7f983f66b05c338464662f741d410ae70b1e662a",
            reviewedHeadRevision:
                "64eed284f0b5630a23feeea1e74dcd74fe275571",
            reviewedHeadTree:
                "7f983f66b05c338464662f741d410ae70b1e662a",
            mergedAt: "2026-08-11T19:59:59Z",
            historyPreservingTwoParentMergeObserved: true,
            mergeTreeEqualsReviewedHeadTree: true,
            mergeCommitSignatureVerified: true,
            mergeCommitSignatureReason: "valid",
            mergeCommitSignatureVerifiedAt: "2026-08-11T20:00:35Z",
            exactMainRefStillMatchedAtAudit: true,
            embeddedSourceIdentitySHA256:
                "4790206681d2c41ffadbed2b774377fcdd2ef2e89c671f14d39026cc0018c2c8"),
        observedSourceBindings: [
            PrimeReviewedMainTLSFailureSourceIdentityV1(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "67725e1ca68e64bbe83e4d0eec2e2708e94fbcfd",
                byteCount: 40_126,
                sha256:
                    "1121fdea67a685ddc23ed71399d044eed6b1b1ac594c873406fb388ee7822ac9",
                claimScope: "exact_failed_workflow_topology_and_commands"),
            PrimeReviewedMainTLSFailureSourceIdentityV1(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "4be271d7a03709209e0e4648643984631d40fa92",
                byteCount: 281_717,
                sha256:
                    "331fb4fddf6301ae8009dbabc325f2e333131fbfe1197028f07df026f9434d2e",
                claimScope: "exact_active_gate_and_retirement_assertions"),
            PrimeReviewedMainTLSFailureSourceIdentityV1(
                path: "Package.swift",
                gitMode: "100644",
                gitBlob: "765d3c88139bc1f74af16b77b2f3b06d33f66f75",
                byteCount: 32_795,
                sha256:
                    "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2",
                claimScope: "exact_root_dependency_graph_not_evaluated"),
            PrimeReviewedMainTLSFailureSourceIdentityV1(
                path: "Package.resolved",
                gitMode: "100644",
                gitBlob: "14d804bb4291720477240c27e24de6fbdc876b3b",
                byteCount: 645,
                sha256:
                    "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375",
                claimScope: "exact_pinned_private_dependency_revision"),
            PrimeReviewedMainTLSFailureSourceIdentityV1(
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitMode: "100644",
                gitBlob: "e72fdb2ffa8cf162b81e7e9fc8019cecf70b2b41",
                byteCount: 546,
                sha256:
                    "f72f6df174c6f935c415a6ec9faadd6f3a9793870d8a580ea5e5c47ac2d64aa7",
                claimScope: "exact_failed_merge_embedded_source_identity"),
            PrimeReviewedMainTLSFailureSourceIdentityV1(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservation.swift",
                gitMode: "100644",
                gitBlob: "4fa7b0a7d32a997d0ab3a5bc89aa5dd4bd6f9909",
                byteCount: 56_633,
                sha256:
                    "52ff3b2a9fcd0ad1a16c4dca467b4fbf1c14dc73f24c29284e9b27ec225635ef",
                claimScope:
                    "frozen_predecessor_stage2_execution_failure_observation"),
            PrimeReviewedMainTLSFailureSourceIdentityV1(
                path:
                    "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationTests.swift",
                gitMode: "100644",
                gitBlob: "3ce9adbe899e7a7e3af3f281e172a4b80a7d0558",
                byteCount: 32_000,
                sha256:
                    "1b54d3630f2881f1b78a362094954fbe0d816a3a1ad8216405404861c21e64cb",
                claimScope:
                    "frozen_predecessor_stage2_execution_failure_observation_test"),
        ],
        runIdentity: PrimeReviewedMainTLSFailureRunIdentityV1(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_530_684_844,
            runNumber: 65,
            runAttempt: 1,
            event: "push",
            headBranch: "main",
            headRevision: "e540b73f6a46cf6e0de5b932d7167f178d4ac6fb",
            actor: "psyop-archivist",
            triggeringActor: "psyop-archivist",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31530684844",
            createdAt: "2026-08-11T20:00:02Z",
            startedAt: "2026-08-11T20:00:02Z",
            terminalUpdatedAt: "2026-08-11T20:03:08Z",
            status: "completed",
            conclusion: "failure",
            checkSuiteID: 85_531_798_174,
            exactHeadPushRunCount: 1,
            previousAttemptURLWasNull: true,
            secondAttemptEndpointHTTPStatus: 404,
            rerunCount: 0,
            rerunObserved: false,
            rerunAuthorized: false),
        activeRootJob: PrimeReviewedMainTLSFailureJobObservationV1(
            id: 93_909_705_892,
            name: "First-party MLX / active-root quarantine",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31530684844/job/93909705892",
            createdAt: "2026-08-11T20:00:02Z",
            startedAt: "2026-08-11T20:00:05Z",
            completedAt: "2026-08-11T20:02:50Z",
            status: "completed",
            conclusion: "success",
            runnerLabel: "macos-15",
            runnerName: "GitHub Actions 1000001688",
            runnerGroupName: "GitHub Actions",
            orderedSteps: [
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 1,
                    name: "Set up job",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 2,
                    name: "Check out the exact Prime revision",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 3,
                    name: "Validate active metadata and preserved history",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 4,
                    name: "Parse the changed Swift contracts without dependencies",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 5,
                    name: "Validate isolated Latin capture and observation contracts",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 6,
                    name: "Record the authority ceiling",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
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
        reviewedMainJob: PrimeReviewedMainTLSFailureJobObservationV1(
            id: 93_910_498_134,
            name: "Reviewed main / focused source contracts",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31530684844/job/93910498134",
            createdAt: "2026-08-11T20:02:50Z",
            startedAt: "2026-08-11T20:02:52Z",
            completedAt: "2026-08-11T20:03:07Z",
            status: "completed",
            conclusion: "failure",
            runnerLabel: "macos-26",
            runnerName: "GitHub Actions 1000001689",
            runnerGroupName: "GitHub Actions",
            orderedSteps: [
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 1,
                    name: "Set up job",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 2,
                    name: "Record the hosted Apple toolchain",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 3,
                    name: "Check out reviewed main exactly",
                    conclusion: "success"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 4,
                    name: "Fetch the exact private dependency without evaluating Prime",
                    conclusion: "failure"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 5,
                    name: "Compile and run the focused contracts without a credential",
                    conclusion: "skipped"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 6,
                    name: "Run the Prime-owned decoder on live Metal",
                    conclusion: "skipped"),
                PrimeReviewedMainTLSFailureJobStepV1(
                    number: 7,
                    name: "Complete job",
                    conclusion: "success"),
            ],
            checkAnnotationCount: 1,
            checkAnnotationPath: ".github",
            checkAnnotationStartLine: 46,
            checkAnnotationEndLine: 46,
            checkAnnotationLevel: "failure",
            checkAnnotationMessage: "Process completed with exit code 128."),
        runnerToolchain: PrimeReviewedMainTLSFailureRunnerToolchainV1(
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
        activeRootRawLog: PrimeReviewedMainTLSFailureRawLogIdentityV1(
            scope: "sealed_raw_active_root_whole_job_log",
            byteCount: 231_409,
            sha256:
                "9df1918e7a6bdd24ba52386a1878114029642d57ce1f739c7523e2071e9772a7",
            utf8BOMHex: "efbbbf",
            startsWithUTF8BOM: true,
            usesLFOnly: true,
            endsWithLF: true,
            lfByteCount: 1_737,
            splitLineCountExcludingTerminalEmpty: 1_737,
            newlineDelimitedComponentCountIncludingTerminalEmpty: 1_738,
            lineCountSemantics:
                "LF_bytes_equal_split_lines_excluding_terminal_empty_component",
            firstTimestamp: "2026-08-11T20:00:05.3250910Z",
            lastTimestamp: "2026-08-11T20:02:46.4902350Z"),
        reviewedMainRawLog: PrimeReviewedMainTLSFailureRawLogIdentityV1(
            scope: "sealed_raw_reviewed_main_whole_job_log",
            byteCount: 10_195,
            sha256:
                "763401f815fa31f7e3a8fb76468ac30b983580a84e3603b6219deaa8e3a79a2e",
            utf8BOMHex: "efbbbf",
            startsWithUTF8BOM: true,
            usesLFOnly: true,
            endsWithLF: true,
            lfByteCount: 134,
            splitLineCountExcludingTerminalEmpty: 134,
            newlineDelimitedComponentCountIncludingTerminalEmpty: 135,
            lineCountSemantics:
                "LF_bytes_equal_split_lines_excluding_terminal_empty_component",
            firstTimestamp: "2026-08-11T20:02:54.3814610Z",
            lastTimestamp: "2026-08-11T20:03:04.6587450Z"),
        failureStepRawLog: PrimeReviewedMainTLSFailureRawLogIdentityV1(
            scope:
                "sealed_raw_fetch_exact_private_dependency_step_log",
            byteCount: 4_024,
            sha256:
                "c347aee0e6e114955166c8418967817631ef9fa5befec474fd96379a051a4da9",
            utf8BOMHex: "efbbbf",
            startsWithUTF8BOM: true,
            usesLFOnly: true,
            endsWithLF: true,
            lfByteCount: 46,
            splitLineCountExcludingTerminalEmpty: 46,
            newlineDelimitedComponentCountIncludingTerminalEmpty: 47,
            lineCountSemantics:
                "LF_bytes_equal_split_lines_excluding_terminal_empty_component",
            firstTimestamp: "2026-08-11T20:03:04.5017820Z",
            lastTimestamp: "2026-08-11T20:03:04.6496520Z"),
        rawLogArchive: PrimeReviewedMainTLSFailureLogArchiveIdentityV1(
            byteCount: 66_580,
            sha256:
                "642d3b1d139c840c3f02a93fd96d03b3504e9ccf5340b1a05900dedda441e2fc",
            memberCount: 16,
            uncompressedByteCount: 484_639,
            repeatedDownloadsWereByteIdentical: true,
            memberTimestampsAreDOSZero: true,
            skippedReviewedStepMembersAbsent: true,
            failureStepMemberDiagnosticTimestamp:
                "2026-08-11T20:03:04.6476270Z",
            reviewedAggregateDiagnosticTimestamp:
                "2026-08-11T20:03:04.6476320Z",
            failureStepMemberExitTimestamp:
                "2026-08-11T20:03:04.6496520Z",
            reviewedAggregateExitTimestamp:
                "2026-08-11T20:03:04.6496540Z",
            members: [
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path: "0_Reviewed main _ focused source contracts.txt",
                    byteCount: 10_195,
                    lfByteCount: 134,
                    sha256:
                        "763401f815fa31f7e3a8fb76468ac30b983580a84e3603b6219deaa8e3a79a2e"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path: "Reviewed main _ focused source contracts/system.txt",
                    byteCount: 800,
                    lfByteCount: 8,
                    sha256:
                        "1abb34c8c7862fb38f11d57938512f6577f8885be1141700452dab46c4b2357a"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/1_Set up job.txt",
                    byteCount: 1_680,
                    lfByteCount: 28,
                    sha256:
                        "6bcdf65669dc83d765cb415aef0382c87f4697ce6dfb2fe7f53b1271410c7a32"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/2_Record the hosted Apple toolchain.txt",
                    byteCount: 1_279,
                    lfByteCount: 22,
                    sha256:
                        "2c1f754a429c8a9c73821ad4ba7fd9c6cdcaa7f5386e173fe7fc701a143e11a0"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/3_Check out reviewed main exactly.txt",
                    byteCount: 3_163,
                    lfByteCount: 37,
                    sha256:
                        "70b2a48a5d8aed05484bdbc6fabf6796590558208cc1e4c8d7e81e6338f19ed7"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/4_Fetch the exact private dependency without evaluating Prime.txt",
                    byteCount: 4_024,
                    lfByteCount: 46,
                    sha256:
                        "c347aee0e6e114955166c8418967817631ef9fa5befec474fd96379a051a4da9"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "Reviewed main _ focused source contracts/7_Complete job.txt",
                    byteCount: 61,
                    lfByteCount: 1,
                    sha256:
                        "085a5c2c04d41b488b8b48a74e5f5faf89e496dcce0b128c2068ec329cc4665d"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path: "1_First-party MLX _ active-root quarantine.txt",
                    byteCount: 231_409,
                    lfByteCount: 1_737,
                    sha256:
                        "9df1918e7a6bdd24ba52386a1878114029642d57ce1f739c7523e2071e9772a7"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/system.txt",
                    byteCount: 601,
                    lfByteCount: 7,
                    sha256:
                        "25e0ce39363541032e0e42621bee8b90385accf0a8f7101c1052992aaef41492"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/1_Set up job.txt",
                    byteCount: 1_681,
                    lfByteCount: 28,
                    sha256:
                        "f3a5e322093eeae1b659cf7c42520f735908094910e46882535323c38d6ef75c"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/2_Check out the exact Prime revision.txt",
                    byteCount: 3_071,
                    lfByteCount: 36,
                    sha256:
                        "1238c55d1f3dab2de8dce767f1eda3ac56db32ce2566cfbc7c64fdff9137d950"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/3_Validate active metadata and preserved history.txt",
                    byteCount: 706,
                    lfByteCount: 8,
                    sha256:
                        "9c463845054dddba6003c2800dd1ffc8ab6095cda75e2bb6378957247e086356"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/4_Parse the changed Swift contracts without dependencies.txt",
                    byteCount: 12_451,
                    lfByteCount: 93,
                    sha256:
                        "8abb62b75460a98e81396d1070e47b924df6ef0d74b6c22231943f68ba2223cd"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/5_Validate isolated Latin capture and observation contracts.txt",
                    byteCount: 196_151,
                    lfByteCount: 1_520,
                    sha256:
                        "219355fb4e3035f79ab82b037ef94bb8057114ccb51f91bb3a79e3c3c961476e"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/6_Record the authority ceiling.txt",
                    byteCount: 17_306,
                    lfByteCount: 51,
                    sha256:
                        "9798dd16e7f2f50af699993425ed54ef4729b1ac5df9f1fbd58f4dcf26c7906e"),
                PrimeReviewedMainTLSFailureArchiveMemberIdentityV1(
                    path:
                        "First-party MLX _ active-root quarantine/7_Complete job.txt",
                    byteCount: 61,
                    lfByteCount: 1,
                    sha256:
                        "3041b5ac3615484d3656f77777ca14005c576fa3522916b2f90a3777dc6d53a9"),
            ]),
        executionBoundary: PrimeReviewedMainTLSFailureExecutionBoundaryV1(
            activeRootGatePassed: true,
            dependencyFreeSwiftParsePassed: true,
            latinTestInvocationCount: 1,
            latinCompletedTestCount: 116,
            latinFailureCount: 0,
            latinSkipCount: 0,
            latinFinalSummaryOccurrenceCount: 2,
            focusedContractsStepNumber: 5,
            focusedContractsStepConclusion: "skipped",
            requiredFocusedRootTestCount: 35,
            focusedRootInvocationCount: 0,
            focusedRootCompletedTestCount: 0,
            focusedRootFailureCount: 0,
            focusedRootSkipCount: 0,
            focusedRootSuccessSummaryCount: 0,
            retainedLiveStepNumber: 6,
            retainedLiveStepConclusion: "skipped",
            retainedLiveSequence: [
                "prime-ci-native-decoder-metal.sh",
                "prime-ci-native-decoder-runtime-closure.sh",
                "prime-ci-native-decoder-tokenizer-compatibility.sh",
            ],
            retainedLiveSequenceWorkflowCounts: [1, 1, 1],
            retainedLiveSequenceInvocationCounts: [0, 0, 0],
            requiredMetalTestCount: 44,
            completedMetalTestCount: 0,
            metalFailureCount: 0,
            metalSkipCount: 0,
            runtimeReceiptCount: 0,
            tokenizerReceiptCount: 0,
            stage2ValidationPackageCommandCount: 0,
            stage2ValidationFilterCount: 0,
            stage2ValidationLogPathCount: 0,
            stage2ValidationScratchPathCount: 0,
            stage2InvocationCount: 0,
            stage2TestStartCount: 0,
            stage2CompletedPassCount: 0,
            stage2CompletedFailureCount: 0,
            stage2CompletedSkipCount: 0,
            retiredSeed42CheckpointCommandCount: 0,
            retiredSeed43CheckpointCommandCount: 0,
            checkpointReceiptMarkerCount: 0,
            artifactUploadStepCount: 0),
        failureBoundary: PrimeReviewedMainTLSFailureBoundaryV1(
            failedJobStepNumber: 4,
            failedJobStepName:
                "Fetch the exact private dependency without evaluating Prime",
            failedStepStartedAt: "2026-08-11T20:03:04Z",
            failedStepCompletedAt: "2026-08-11T20:03:04Z",
            privateDependencyRepository:
                "https://github.com/Ergentics/ergentics-mlx-swift",
            privateDependencyRevision:
                "d37885a278f1c37484a94d0f401a418735e66519",
            exactFetchCommand:
                "git --git-dir=\"$mlx_bare\" fetch --depth=1 --no-tags origin \"$PRIME_MLX_REVISION\"",
            credentialNonemptyPreconditionReturned: true,
            credentialWasMaskedInLog: true,
            credentialValueDisclosed: false,
            bareRepositoryInitializationCompleted: true,
            privateDependencyRemoteAdded: true,
            credentialURLRewriteConfigured: true,
            transportFetchInvocationCount: 1,
            dependencyFetchCompleted: false,
            fetchHeadValidationCount: 0,
            pinnedReferenceUpdateCount: 0,
            dependencyWorktreeAddCount: 0,
            dependencySubmoduleUpdateCount: 0,
            dependencyPackageEvaluationCount: 0,
            credentialLeakScanCount: 0,
            exactDiagnostic:
                "fatal: unable to access 'https://github.com/Ergentics/ergentics-mlx-swift/': SSL certificate problem: self signed certificate",
            failureStepMemberDiagnosticTimestamp:
                "2026-08-11T20:03:04.6476270Z",
            reviewedAggregateDiagnosticTimestamp:
                "2026-08-11T20:03:04.6476320Z",
            diagnosticOccurrenceCount: 2,
            processExitCode: 128,
            exactExitMessage: "Process completed with exit code 128.",
            failureStepMemberExitTimestamp:
                "2026-08-11T20:03:04.6496520Z",
            reviewedAggregateExitTimestamp:
                "2026-08-11T20:03:04.6496540Z",
            exactMergeCheckoutCompleted: true,
            exactMergeCheckoutRemainedClean: true,
            failureClassification:
                "git_https_tls_self_signed_certificate_before_private_dependency_fetch_completion"),
        failureSemantics: PrimeReviewedMainTLSFailureSemanticsV1(
            inferenceBasis:
                "exact_run_job_step_APIs_plus_two_byte_identical_raw_log_archive_downloads_and_source_pinned_control_flow",
            externalTLSFailureObserved: true,
            selfSignedCertificateDiagnosticObserved: true,
            gitTransportFailureObserved: true,
            certificateVerificationFailureObserved: true,
            failurePrecedesDependencyEvaluation: true,
            failurePrecedesReviewedMainSwiftCompilation: true,
            failurePrecedesFocusedRootExecution: true,
            failurePrecedesRetainedLiveSequence: true,
            predecessorStage2ObservationRemainsFrozen: true,
            predecessorStage2AttemptRemainsExhausted: true,
            runnerTLSRepairRequiredBeforeDistinctRun: true,
            stage3RemainsBlocked: true,
            repositorySourceDefectEstablished: false,
            workflowSourceDefectEstablished: false,
            dependencyRevisionDefectEstablished: false,
            dependencyRepositoryAbsenceEstablished: false,
            credentialAbsenceEstablished: false,
            credentialRejectionObserved: false,
            credentialValidityEstablished: false,
            stage2SemanticsEvaluated: false,
            stage2SemanticFailureObserved: false,
            stage2BootstrapFailureObserved: false,
            stage2RepairAttempted: false,
            stage2OutcomeEstablished: false,
            runnerTLSRepairEstablished: false,
            failureClassificationLimitedToObservedExternalTLSBoundary: true),
        artifactBoundary: PrimeReviewedMainTLSFailureArtifactBoundaryV1(
            actionsArtifactsEndpoint:
                "https://api.github.com/repos/Ergentics/ergentics-prime/actions/runs/31530684844/artifacts",
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
        authorityCeiling: PrimeReviewedMainTLSFailureAuthorityCeilingV1(
            rerunAuthorized: false,
            replacementRunAuthorized: false,
            runnerTLSRepairAuthorized: false,
            TLSVerificationBypassAuthorized: false,
            customCAInstallationAuthorized: false,
            workflowMutationAuthorized: false,
            repositorySourceCorrectionAuthorized: false,
            credentialRotationAuthorized: false,
            credentialMutationAuthorized: false,
            dependencyRevisionChangeAuthorized: false,
            focusedRootContractsEstablished: false,
            metalValidationEstablished: false,
            runtimeClosureEstablished: false,
            tokenizerCompatibilityEstablished: false,
            stage2ExecutionEstablished: false,
            stage2BootstrapRepairEstablished: false,
            stage2SuccessEstablished: false,
            stage3AuthorityEstablished: false,
            checkpointReadEstablished: false,
            checkpointWriteEstablished: false,
            checkpointRoundTripEstablished: false,
            checkpointArtifactAvailabilityEstablished: false,
            checkpointArtifactRetentionEstablished: false,
            checkpointArtifactUploadAuthorized: false,
            checkpointArtifactProvenanceEstablished: false,
            checkpointAdmissionGranted: false,
            metalTensorExecutionEstablished: false,
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
            publicationAuthorized: false),
        status:
            "ABSTAIN_exact_main_private_dependency_external_tls_failure_before_dependency_evaluation_root35_live_sequence_or_stage2_no_rerun_no_artifact_no_downstream_authority",
        orderedRequiredSeparateActions: [
            "preserve_run_31530684844_attempt_1_as_terminal_external_tls_failure_evidence",
            "separately_authorize_and_bind_any_runner_tls_trust_repair",
            "require_a_distinct_exact_main_run_without_rerunning_this_attempt",
            "require_root36_then_metal44_then_runtime1_then_tokenizer1_before_any_success_observation",
            "keep_stage2_retired_and_stage3_blocked_pending_separate_default_metallib_repair_authority",
        ])

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeReviewedMainPrivateDependencyTLSFailureObservationError
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
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsExecutionFailureObservationV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            let predecessorHash = PrimeSHA256.hexDigest(
                of: try predecessor.canonicalData()
            )
            guard predecessorObservationID == predecessor.observationID,
                  predecessorCanonicalSHA256 == predecessorHash else {
                throw
                    PrimeReviewedMainPrivateDependencyTLSFailureObservationError
                        .contractDrift
            }
        } catch {
            throw PrimeReviewedMainPrivateDependencyTLSFailureObservationError
                .contractDrift
        }
        let execution = executionBoundary
        let failure = failureBoundary
        let semantics = failureSemantics
        let artifacts = artifactBoundary
        let ceiling = authorityCeiling
        let authorityClaims = [
            ceiling.rerunAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.runnerTLSRepairAuthorized,
            ceiling.TLSVerificationBypassAuthorized,
            ceiling.customCAInstallationAuthorized,
            ceiling.workflowMutationAuthorized,
            ceiling.repositorySourceCorrectionAuthorized,
            ceiling.credentialRotationAuthorized,
            ceiling.credentialMutationAuthorized,
            ceiling.dependencyRevisionChangeAuthorized,
            ceiling.focusedRootContractsEstablished,
            ceiling.metalValidationEstablished,
            ceiling.runtimeClosureEstablished,
            ceiling.tokenizerCompatibilityEstablished,
            ceiling.stage2ExecutionEstablished,
            ceiling.stage2BootstrapRepairEstablished,
            ceiling.stage2SuccessEstablished,
            ceiling.stage3AuthorityEstablished,
            ceiling.checkpointReadEstablished,
            ceiling.checkpointWriteEstablished,
            ceiling.checkpointRoundTripEstablished,
            ceiling.checkpointArtifactAvailabilityEstablished,
            ceiling.checkpointArtifactRetentionEstablished,
            ceiling.checkpointArtifactUploadAuthorized,
            ceiling.checkpointArtifactProvenanceEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.metalTensorExecutionEstablished,
            ceiling.native300MAllocationEstablished,
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
        ]
        guard self == Self.frozenV1,
              schemaVersion == 1,
              repositoryIdentity.orderedParentRevisions.count == 2,
              repositoryIdentity.tree == repositoryIdentity.reviewedHeadTree,
              repositoryIdentity.revision == runIdentity.headRevision,
              observedSourceBindings.count == 7,
              activeRootJob.orderedSteps.map(\.number) == Array(1 ... 7),
              activeRootJob.orderedSteps.allSatisfy({
                  $0.conclusion == "success"
              }),
              reviewedMainJob.orderedSteps.map(\.number) == Array(1 ... 7),
              reviewedMainJob.orderedSteps.map(\.conclusion)
                == [
                    "success",
                    "success",
                    "success",
                    "failure",
                    "skipped",
                    "skipped",
                    "success",
                ],
              activeRootRawLog.lfByteCount
                == activeRootRawLog.splitLineCountExcludingTerminalEmpty,
              activeRootRawLog.newlineDelimitedComponentCountIncludingTerminalEmpty
                == activeRootRawLog.lfByteCount + 1,
              reviewedMainRawLog.lfByteCount
                == reviewedMainRawLog.splitLineCountExcludingTerminalEmpty,
              reviewedMainRawLog.newlineDelimitedComponentCountIncludingTerminalEmpty
                == reviewedMainRawLog.lfByteCount + 1,
              failureStepRawLog.lfByteCount
                == failureStepRawLog.splitLineCountExcludingTerminalEmpty,
              failureStepRawLog.newlineDelimitedComponentCountIncludingTerminalEmpty
                == failureStepRawLog.lfByteCount + 1,
              rawLogArchive.members.count == rawLogArchive.memberCount,
              rawLogArchive.members.reduce(0, { $0 + $1.byteCount })
                == rawLogArchive.uncompressedByteCount,
              Set(rawLogArchive.members.map(\.path)).count
                == rawLogArchive.memberCount,
              rawLogArchive.failureStepMemberDiagnosticTimestamp
                == failure.failureStepMemberDiagnosticTimestamp,
              rawLogArchive.reviewedAggregateDiagnosticTimestamp
                == failure.reviewedAggregateDiagnosticTimestamp,
              rawLogArchive.failureStepMemberExitTimestamp
                == failure.failureStepMemberExitTimestamp,
              rawLogArchive.reviewedAggregateExitTimestamp
                == failure.reviewedAggregateExitTimestamp,
              execution.activeRootGatePassed,
              execution.dependencyFreeSwiftParsePassed,
              execution.latinCompletedTestCount == 116,
              execution.latinFailureCount == 0,
              execution.latinSkipCount == 0,
              execution.focusedRootInvocationCount == 0,
              execution.focusedRootCompletedTestCount == 0,
              execution.retainedLiveSequence.count == 3,
              execution.retainedLiveSequenceWorkflowCounts == [1, 1, 1],
              execution.retainedLiveSequenceInvocationCounts == [0, 0, 0],
              execution.stage2ValidationPackageCommandCount == 0,
              execution.stage2ValidationFilterCount == 0,
              execution.stage2InvocationCount == 0,
              failure.failedJobStepNumber == 4,
              failure.credentialNonemptyPreconditionReturned,
              !failure.credentialValueDisclosed,
              failure.privateDependencyRemoteAdded,
              failure.credentialURLRewriteConfigured,
              failure.transportFetchInvocationCount == 1,
              !failure.dependencyFetchCompleted,
              failure.fetchHeadValidationCount == 0,
              failure.pinnedReferenceUpdateCount == 0,
              failure.dependencyWorktreeAddCount == 0,
              failure.dependencySubmoduleUpdateCount == 0,
              failure.dependencyPackageEvaluationCount == 0,
              failure.credentialLeakScanCount == 0,
              failure.processExitCode == 128,
              semantics.externalTLSFailureObserved,
              semantics.selfSignedCertificateDiagnosticObserved,
              semantics.gitTransportFailureObserved,
              semantics.certificateVerificationFailureObserved,
              semantics.failurePrecedesDependencyEvaluation,
              semantics.failurePrecedesFocusedRootExecution,
              semantics.failurePrecedesRetainedLiveSequence,
              semantics.predecessorStage2ObservationRemainsFrozen,
              semantics.predecessorStage2AttemptRemainsExhausted,
              semantics.runnerTLSRepairRequiredBeforeDistinctRun,
              semantics.stage3RemainsBlocked,
              !semantics.repositorySourceDefectEstablished,
              !semantics.credentialRejectionObserved,
              !semantics.stage2SemanticsEvaluated,
              !semantics.stage2OutcomeEstablished,
              semantics.failureClassificationLimitedToObservedExternalTLSBoundary,
              artifacts.actionsArtifactsTotalCount == 0,
              artifacts.actionsArtifactsArrayExactlyEmpty,
              artifacts.publishedWorkflowArtifactCount == 0,
              artifacts.artifactUploadStepCount == 0,
              authorityClaims.allSatisfy({ !$0 }) else {
            throw PrimeReviewedMainPrivateDependencyTLSFailureObservationError
                .contractDrift
        }
    }
}
