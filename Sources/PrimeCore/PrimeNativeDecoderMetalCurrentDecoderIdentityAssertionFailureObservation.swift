// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1:
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

public struct PrimeNativeDecoderMetalIdentityFailureRepositoryIdentityV1:
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

public struct PrimeNativeDecoderMetalIdentityFailureRunIdentityV1:
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

public struct PrimeNativeDecoderMetalIdentityFailureJobStepV1:
    Codable,
    Equatable,
    Sendable
{
    public let number: Int
    public let name: String
    public let conclusion: String
}

public struct PrimeNativeDecoderMetalIdentityFailureJobObservationV1:
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
    public let orderedSteps: [PrimeNativeDecoderMetalIdentityFailureJobStepV1]
    public let checkAnnotationCount: Int
    public let checkAnnotationPath: String
    public let checkAnnotationStartLine: Int
    public let checkAnnotationEndLine: Int
    public let checkAnnotationLevel: String
    public let checkAnnotationMessage: String
}

public struct PrimeNativeDecoderMetalIdentityFailureRunnerToolchainV1:
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

public struct PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1:
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

public struct PrimeNativeDecoderMetalIdentityFailureArchiveMemberIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
}

public struct PrimeNativeDecoderMetalIdentityFailureLogArchiveIdentityV1:
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
    public let assertionStepMemberFirstDiagnosticTimestamp: String
    public let reviewedAggregateFirstDiagnosticTimestamp: String
    public let assertionStepMemberSecondDiagnosticTimestamp: String
    public let reviewedAggregateSecondDiagnosticTimestamp: String
    public let assertionStepMemberExitTimestamp: String
    public let reviewedAggregateExitTimestamp: String
    public let members: [PrimeNativeDecoderMetalIdentityFailureArchiveMemberIdentityV1]
}

public struct PrimeNativeDecoderMetalIdentityFailureExecutionBoundaryV1:
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
    public let securePrivateDependencyFetchInvocationCount: Int
    public let securePrivateDependencyFetchCompleted: Bool
    public let privateDependencyRevision: String
    public let privateDependencySubmoduleRevisions: [String]
    public let focusedRootRequiredTestCount: Int
    public let focusedRootInvocationCount: Int
    public let focusedRootCompletedTestCount: Int
    public let focusedRootFailureCount: Int
    public let focusedRootSkipCount: Int
    public let focusedRootSuccessSummaryCount: Int
    public let retainedLiveSequence: [String]
    public let retainedLiveSequenceWorkflowCounts: [Int]
    public let retainedLiveSequenceInvocationCounts: [Int]
    public let metallibBuildInvocationCount: Int
    public let metallibBuildCompleted: Bool
    public let metallibByteCount: Int
    public let metallibSHA256: String
    public let metalTestInvocationCount: Int
    public let metalStartedTestCount: Int
    public let metalPassedTestCount: Int
    public let metalFailedTestCount: Int
    public let metalAssertionFailureCount: Int
    public let metalSkipCount: Int
    public let metalFailureSummaryOccurrenceCount: Int
    public let runtimeClosureInvocationCount: Int
    public let runtimeAuthorityCompletedTestCount: Int
    public let runtimeReceiptCount: Int
    public let tokenizerCompatibilityInvocationCount: Int
    public let tokenizerAuthorityCompletedTestCount: Int
    public let tokenizerReceiptCount: Int
    public let stage2ValidationPackageCommandCount: Int
    public let stage2ValidationFilterCount: Int
    public let stage2ValidationLogPathCount: Int
    public let stage2ValidationScratchPathCount: Int
    public let stage2ValidationBuildPathCount: Int
    public let stage2ValidationCachePathCount: Int
    public let stage2ValidationConfigPathCount: Int
    public let stage2ValidationSecurityPathCount: Int
    public let stage2InvocationCount: Int
    public let retiredSeed42CheckpointCommandCount: Int
    public let retiredSeed43CheckpointCommandCount: Int
    public let checkpointReceiptMarkerCount: Int
    public let artifactUploadStepCount: Int
}

public struct PrimeNativeDecoderMetalIdentityFailureSourceDriftBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let decoderSourcePath: String
    public let frozenMetalAuthorityGitMode: String
    public let frozenMetalAuthorityGitBlob: String
    public let frozenMetalAuthorityByteCount: Int
    public let frozenMetalAuthoritySHA256: String
    public let currentDecoderGitMode: String
    public let currentDecoderGitBlob: String
    public let currentDecoderByteCount: Int
    public let currentDecoderSHA256: String
    public let currentMinusFrozenByteCount: Int
    public let stage2SeamIntroducingRevision: String
    public let stage2SeamMethod: String
    public let stage2SeamAddedLineCount: Int
    public let diffContainsOnlyStage2TrainingSeam: Bool
    public let frozenMetalAuthorityRemainsHistorical: Bool
    public let currentDecoderMatchesExactMergeTree: Bool
    public let observationMutatesNeitherIdentity: Bool
}

public struct PrimeNativeDecoderMetalIdentityFailureAssertionBoundaryV1:
    Codable,
    Equatable,
    Sendable
{
    public let failedJobStepNumber: Int
    public let failedJobStepName: String
    public let failedStepStartedAt: String
    public let failedStepCompletedAt: String
    public let failedSuite: String
    public let failedTestClass: String
    public let failedTestMethod: String
    public let failedTestSourcePath: String
    public let byteCountAssertionLine: Int
    public let sha256AssertionLine: Int
    public let exactByteCountAssertionMessage: String
    public let exactSHA256AssertionMessage: String
    public let assertionStepMemberFirstDiagnosticTimestamp: String
    public let reviewedAggregateFirstDiagnosticTimestamp: String
    public let assertionStepMemberSecondDiagnosticTimestamp: String
    public let reviewedAggregateSecondDiagnosticTimestamp: String
    public let failedTestCaseCount: Int
    public let assertionFailureCount: Int
    public let processExitCode: Int
    public let exactExitMessage: String
    public let assertionStepMemberExitTimestamp: String
    public let reviewedAggregateExitTimestamp: String
    public let failureClassification: String
}

public struct PrimeNativeDecoderMetalIdentityFailureSemanticsV1:
    Codable,
    Equatable,
    Sendable
{
    public let inferenceBasis: String
    public let secureDependencyFetchSuccessObserved: Bool
    public let predecessorTLSFailureWasNotRepeated: Bool
    public let focusedRootSuccessObserved: Bool
    public let freshMetallibBuildObserved: Bool
    public let frozenMetalAuthorityIdentityAssertionFailureObserved: Bool
    public let currentDecoderStage2SeamDriftEstablished: Bool
    public let failureLimitedToCurrentDecoderIdentityAssertion: Bool
    public let runtimeAndTokenizerBlockedByOrderedFailClosedSequence: Bool
    public let predecessorTLSObservationRemainsFrozen: Bool
    public let predecessorStage2FailureObservationRemainsFrozen: Bool
    public let predecessorStage2AttemptRemainsExhausted: Bool
    public let separateIdentityAssertionRepairRequired: Bool
    public let stage3RemainsBlocked: Bool
    public let privateDependencyTLSFailureObserved: Bool
    public let metallibBuildFailureObserved: Bool
    public let metalFunctionalRegressionEstablished: Bool
    public let frozenMetalAuthorityMutationPerformed: Bool
    public let decoderSourceMutationPerformed: Bool
    public let currentDecoderIdentityRepairAttempted: Bool
    public let currentDecoderIdentityRepairEstablished: Bool
    public let metalValidationEstablished: Bool
    public let runtimeClosureEvaluated: Bool
    public let runtimeClosureEstablished: Bool
    public let tokenizerCompatibilityEvaluated: Bool
    public let tokenizerCompatibilityEstablished: Bool
    public let stage2ExecutionEvaluated: Bool
    public let stage2ExecutionEstablished: Bool
    public let stage2BootstrapRepairEstablished: Bool
    public let stage3AuthorityEstablished: Bool
}

public struct PrimeNativeDecoderMetalIdentityFailureArtifactBoundaryV1:
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

public struct PrimeNativeDecoderMetalIdentityFailureAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let rerunAuthorized: Bool
    public let replacementRunAuthorized: Bool
    public let workflowMutationAuthorized: Bool
    public let frozenMetalAuthorityMutationAuthorized: Bool
    public let decoderSourceReversionAuthorized: Bool
    public let currentDecoderIdentityAssertionRepairAuthorized: Bool
    public let currentDecoderIdentityAssertionRepairEstablished: Bool
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

/// Append-only observation of the first and only exact-main attempt after the
/// private-dependency TLS failure. The distinct run fetched the pinned donor,
/// passed active root and the focused 36-test root, and built one fresh
/// default.metallib. The first retained launcher then executed all 44 Metal
/// tests. One authority test produced two assertions because its historical
/// repaired-decoder identity predates the package-only Stage-2 training-logits
/// seam now present in the exact merge tree.
///
/// This observation does not rewrite either identity, retry the run, or treat
/// the other 43 passing tests as whole-suite validation. Fail-closed ordering
/// prevented runtime and tokenizer execution. Stage-2 live validation and both
/// checkpoint one-shots remained absent, no Actions artifact existed, and all
/// downstream authority remains false.
public struct
    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorObservationID: String
    public let predecessorCanonicalSHA256: String
    public let repositoryIdentity:
        PrimeNativeDecoderMetalIdentityFailureRepositoryIdentityV1
    public let observedSourceBindings:
        [PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1]
    public let runIdentity: PrimeNativeDecoderMetalIdentityFailureRunIdentityV1
    public let activeRootJob:
        PrimeNativeDecoderMetalIdentityFailureJobObservationV1
    public let reviewedMainJob:
        PrimeNativeDecoderMetalIdentityFailureJobObservationV1
    public let runnerToolchain:
        PrimeNativeDecoderMetalIdentityFailureRunnerToolchainV1
    public let activeRootRawLog:
        PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1
    public let reviewedMainRawLog:
        PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1
    public let secureFetchStepRawLog:
        PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1
    public let focusedContractsStepRawLog:
        PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1
    public let liveMetalStepRawLog:
        PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1
    public let rawLogArchive:
        PrimeNativeDecoderMetalIdentityFailureLogArchiveIdentityV1
    public let executionBoundary:
        PrimeNativeDecoderMetalIdentityFailureExecutionBoundaryV1
    public let sourceDriftBoundary:
        PrimeNativeDecoderMetalIdentityFailureSourceDriftBoundaryV1
    public let assertionFailureBoundary:
        PrimeNativeDecoderMetalIdentityFailureAssertionBoundaryV1
    public let failureSemantics:
        PrimeNativeDecoderMetalIdentityFailureSemanticsV1
    public let artifactBoundary:
        PrimeNativeDecoderMetalIdentityFailureArtifactBoundaryV1
    public let authorityCeiling:
        PrimeNativeDecoderMetalIdentityFailureAuthorityCeilingV1
    public let status: String
    public let orderedRequiredSeparateActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_metal_current_decoder_identity_assertion_failure_observation_v1",
        observationKind:
            "exact_main_metal_current_decoder_identity_assertion_failure_after_root36",
        predecessorObservationID:
            "ergentics_prime_reviewed_main_private_dependency_tls_failure_observation_v1",
        predecessorCanonicalSHA256:
            "44917549689204bb9aabbd24b642d491a26fa501c3828cbc82009aa5e157a35d",
        repositoryIdentity:
            PrimeNativeDecoderMetalIdentityFailureRepositoryIdentityV1(
                repository: "Ergentics/ergentics-prime",
                pullRequestNumber: 85,
                ref: "refs/heads/main",
                revision: "2d0464ca35212d3d84781654b6a4e08158f27eab",
                orderedParentRevisions: [
                    "e540b73f6a46cf6e0de5b932d7167f178d4ac6fb",
                    "5198f5da94977d11f5fcfabf65bb55a62cb31f26",
                ],
                tree: "be66df2affb85e2d846ba6f5f51e540d17864796",
                reviewedHeadRevision:
                    "5198f5da94977d11f5fcfabf65bb55a62cb31f26",
                reviewedHeadTree:
                    "be66df2affb85e2d846ba6f5f51e540d17864796",
                mergedAt: "2026-08-11T20:34:49Z",
                historyPreservingTwoParentMergeObserved: true,
                mergeTreeEqualsReviewedHeadTree: true,
                mergeCommitSignatureVerified: true,
                mergeCommitSignatureReason: "valid",
                mergeCommitSignatureVerifiedAt: "2026-08-11T20:35:36Z",
                exactMainRefStillMatchedAtAudit: true,
                embeddedSourceIdentitySHA256:
                    "bb94b8a0e846639e2260bbe50d352b797e37b64f6318d13b28f3cbc5e1cc8f43"),
        observedSourceBindings: [
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "17cd469ea8ee75c070a404390abd2319c782f5e0",
                byteCount: 40_914,
                sha256:
                    "e6e4543cbe372e1222c16219330462a6fe0c14685afbe396d5749ba3f6e4ef95",
                claimScope: "exact_failed_workflow_topology_and_order"),
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "da6389dfa57c0a67268dd441fe418ed1fc6ff521",
                byteCount: 295_609,
                sha256:
                    "ef455437eb6efa4b8bb54d3091ba08acb0fa34283badef4f40e97cce1a8331c5",
                claimScope: "exact_active_gate_and_retired_surface_assertions"),
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path: ".github/scripts/prime-ci-native-decoder-metal.sh",
                gitMode: "100755",
                gitBlob: "418d2d2753cee38e0b3558ad45e1e09865ffd11d",
                byteCount: 11_793,
                sha256:
                    "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff",
                claimScope: "exact_failed_metal_launcher"),
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitMode: "100644",
                gitBlob: "f9969e70df8cf29d8e52990e57f438bef8baf76f",
                byteCount: 546,
                sha256:
                    "04b37e30b93974cdc67b6b6299eddf26ea6f7da34b133167ace4e800962e2136",
                claimScope: "exact_merge_embedded_source_identity"),
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path:
                    "Sources/PrimeCore/PrimeReviewedMainPrivateDependencyTLSFailureObservation.swift",
                gitMode: "100644",
                gitBlob: "4601692d5a52cbe1ae012e81ea5d86394e5ffadf",
                byteCount: 56_027,
                sha256:
                    "e5092d50858d4fad76b229cc4b954d445df221d7019b06cb930c792370eddf6d",
                claimScope: "frozen_predecessor_tls_failure_observation"),
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path:
                    "Tests/PrimeCoreTests/PrimeReviewedMainPrivateDependencyTLSFailureObservationTests.swift",
                gitMode: "100644",
                gitBlob: "b9d63cc1e4f6a60c99f1157bf08524befcc3f59a",
                byteCount: 32_599,
                sha256:
                    "b53318309597cb3d3e270bb978d0f0f96661dbbb47eda374a7753de9c9795655",
                claimScope: "frozen_predecessor_tls_failure_test"),
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift",
                gitMode: "100644",
                gitBlob: "f284cb6d9bfdd37add9273f3e0eecd69e13cd134",
                byteCount: 26_865,
                sha256:
                    "5e88a1a191f94daac01f86e5dbad48ebfcdd50957ac17acf6f404ac8dd0a97ac",
                claimScope: "frozen_historical_metal_repair_identity"),
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path: "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                gitMode: "100644",
                gitBlob: "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f",
                byteCount: 39_598,
                sha256:
                    "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
                claimScope: "exact_current_decoder_with_stage2_training_seam"),
            PrimeNativeDecoderMetalIdentityFailureSourceIdentityV1(
                path:
                    "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift",
                gitMode: "100644",
                gitBlob: "25b7c9b99e789988fb7362b73a41d35eafba406d",
                byteCount: 34_555,
                sha256:
                    "28b146996a0dede2e6cd8e6d8116641a3a398bc5f845051a75cbbc977e9f48fe",
                claimScope: "exact_failed_identity_assertion_test"),
        ],
        runIdentity: PrimeNativeDecoderMetalIdentityFailureRunIdentityV1(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_533_658_617,
            runNumber: 67,
            runAttempt: 1,
            event: "push",
            headBranch: "main",
            headRevision: "2d0464ca35212d3d84781654b6a4e08158f27eab",
            actor: "psyop-archivist",
            triggeringActor: "psyop-archivist",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31533658617",
            createdAt: "2026-08-11T20:34:52Z",
            startedAt: "2026-08-11T20:34:52Z",
            terminalUpdatedAt: "2026-08-11T21:00:56Z",
            status: "completed",
            conclusion: "failure",
            checkSuiteID: 85_540_241_762,
            exactHeadPushRunCount: 1,
            previousAttemptURLWasNull: true,
            secondAttemptEndpointHTTPStatus: 404,
            rerunCount: 0,
            rerunObserved: false,
            rerunAuthorized: false),
        activeRootJob: PrimeNativeDecoderMetalIdentityFailureJobObservationV1(
            id: 93_919_471_247,
            name: "First-party MLX / active-root quarantine",
            url:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31533658617/job/93919471247",
            startedAt: "2026-08-11T20:34:54Z",
            completedAt: "2026-08-11T20:36:58Z",
            status: "completed",
            conclusion: "success",
            runnerLabel: "macos-15",
            runnerName: "GitHub Actions 1000001691",
            runnerGroupName: "GitHub Actions",
            orderedSteps: [
                PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                    number: 1, name: "Set up job", conclusion: "success"),
                PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                    number: 2,
                    name: "Check out the exact Prime revision",
                    conclusion: "success"),
                PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                    number: 3,
                    name: "Validate active metadata and preserved history",
                    conclusion: "success"),
                PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                    number: 4,
                    name: "Parse the changed Swift contracts without dependencies",
                    conclusion: "success"),
                PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                    number: 5,
                    name: "Validate isolated Latin capture and observation contracts",
                    conclusion: "success"),
                PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                    number: 6,
                    name: "Record the authority ceiling",
                    conclusion: "success"),
                PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                    number: 7, name: "Complete job", conclusion: "success"),
            ],
            checkAnnotationCount: 0,
            checkAnnotationPath: "",
            checkAnnotationStartLine: 0,
            checkAnnotationEndLine: 0,
            checkAnnotationLevel: "",
            checkAnnotationMessage: ""),
        reviewedMainJob:
            PrimeNativeDecoderMetalIdentityFailureJobObservationV1(
                id: 93_920_049_786,
                name: "Reviewed main / focused source contracts",
                url:
                    "https://github.com/Ergentics/ergentics-prime/actions/runs/31533658617/job/93920049786",
                startedAt: "2026-08-11T20:37:00Z",
                completedAt: "2026-08-11T21:00:56Z",
                status: "completed",
                conclusion: "failure",
                runnerLabel: "macos-26",
                runnerName: "GitHub Actions 1000001692",
                runnerGroupName: "GitHub Actions",
                orderedSteps: [
                    PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                        number: 1,
                        name: "Set up job",
                        conclusion: "success"),
                    PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                        number: 2,
                        name: "Record the hosted Apple toolchain",
                        conclusion: "success"),
                    PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                        number: 3,
                        name: "Check out reviewed main exactly",
                        conclusion: "success"),
                    PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                        number: 4,
                        name:
                            "Fetch the exact private dependency without evaluating Prime",
                        conclusion: "success"),
                    PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                        number: 5,
                        name:
                            "Compile and run the focused contracts without a credential",
                        conclusion: "success"),
                    PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                        number: 6,
                        name: "Run the Prime-owned decoder on live Metal",
                        conclusion: "failure"),
                    PrimeNativeDecoderMetalIdentityFailureJobStepV1(
                        number: 7,
                        name: "Complete job",
                        conclusion: "success"),
                ],
                checkAnnotationCount: 1,
                checkAnnotationPath: ".github",
                checkAnnotationStartLine: 74_480,
                checkAnnotationEndLine: 74_480,
                checkAnnotationLevel: "failure",
                checkAnnotationMessage: "Process completed with exit code 2."),
        runnerToolchain:
            PrimeNativeDecoderMetalIdentityFailureRunnerToolchainV1(
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
        activeRootRawLog: Self.rawLog(
            scope: "sealed_raw_active_root_whole_job_log",
            byteCount: 232_035,
            sha256:
                "46187396b65c13adf6e1da20d625890eb804f6b4ba476615ed0a532a55c89682",
            lfByteCount: 1_740,
            firstTimestamp: "2026-08-11T20:34:55.1323780Z",
            lastTimestamp: "2026-08-11T20:36:55.6644370Z"),
        reviewedMainRawLog: Self.rawLog(
            scope: "sealed_raw_reviewed_main_whole_job_log",
            byteCount: 10_192_525,
            sha256:
                "0b2d720a64c341dc874f3271b0e4a5792c6d7af36337f1d15f1641d27937ef16",
            lfByteCount: 77_932,
            firstTimestamp: "2026-08-11T20:37:01.4315430Z",
            lastTimestamp: "2026-08-11T21:00:44.4333680Z"),
        secureFetchStepRawLog: Self.rawLog(
            scope: "sealed_raw_secure_private_dependency_fetch_step_log",
            byteCount: 4_893,
            sha256:
                "7c50a7eddd18f8c8049ef431164da6175ffae284140dfd68a9062d8d0bc701a2",
            lfByteCount: 54,
            firstTimestamp: "2026-08-11T20:37:11.0128870Z",
            lastTimestamp: "2026-08-11T20:37:23.7655030Z"),
        focusedContractsStepRawLog: Self.rawLog(
            scope: "sealed_raw_focused_contracts_step_log",
            byteCount: 337_696,
            sha256:
                "f972a9fe4bf0f00c467dd90f43a60cc594f2228cec6e720d8acfd2816b6f61e1",
            lfByteCount: 3_310,
            firstTimestamp: "2026-08-11T20:37:25.7298400Z",
            lastTimestamp: "2026-08-11T20:55:27.2252780Z"),
        liveMetalStepRawLog: Self.rawLog(
            scope: "sealed_raw_live_metal_step_log",
            byteCount: 9_843_772,
            sha256:
                "343c5ae69d86eb6ba16d1ab0fe72663651c3ca3d4ae921e632c355e2f7506f6a",
            lfByteCount: 74_480,
            firstTimestamp: "2026-08-11T20:55:27.5642320Z",
            lastTimestamp: "2026-08-11T21:00:44.4133280Z"),
        rawLogArchive:
            PrimeNativeDecoderMetalIdentityFailureLogArchiveIdentityV1(
                byteCount: 1_311_898,
                sha256:
                    "7ab28a53a38c61145065a921c53414d5ce15fe40a6db66b678c65b3c93e05736",
                memberCount: 18,
                uncompressedByteCount: 20_850_557,
                repeatedDownloadsWereByteIdentical: true,
                memberTimestampsAreDOSZero: true,
                assertionStepMemberFirstDiagnosticTimestamp:
                    "2026-08-11T21:00:38.2311960Z",
                reviewedAggregateFirstDiagnosticTimestamp:
                    "2026-08-11T21:00:38.2312020Z",
                assertionStepMemberSecondDiagnosticTimestamp:
                    "2026-08-11T21:00:38.2314750Z",
                reviewedAggregateSecondDiagnosticTimestamp:
                    "2026-08-11T21:00:38.2314770Z",
                assertionStepMemberExitTimestamp:
                    "2026-08-11T21:00:44.4133280Z",
                reviewedAggregateExitTimestamp:
                    "2026-08-11T21:00:44.4133330Z",
                members: Self.archiveMembers),
        executionBoundary:
            PrimeNativeDecoderMetalIdentityFailureExecutionBoundaryV1(
                activeRootGatePassed: true,
                dependencyFreeSwiftParsePassed: true,
                latinTestInvocationCount: 1,
                latinCompletedTestCount: 116,
                latinFailureCount: 0,
                latinSkipCount: 0,
                latinFinalSummaryOccurrenceCount: 2,
                securePrivateDependencyFetchInvocationCount: 1,
                securePrivateDependencyFetchCompleted: true,
                privateDependencyRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                privateDependencySubmoduleRevisions: [
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                    "0726ca922fc902c4c61ef9c27d94132be418e945",
                ],
                focusedRootRequiredTestCount: 36,
                focusedRootInvocationCount: 1,
                focusedRootCompletedTestCount: 36,
                focusedRootFailureCount: 0,
                focusedRootSkipCount: 0,
                focusedRootSuccessSummaryCount: 2,
                retainedLiveSequence: [
                    "prime-ci-native-decoder-metal.sh",
                    "prime-ci-native-decoder-runtime-closure.sh",
                    "prime-ci-native-decoder-tokenizer-compatibility.sh",
                ],
                retainedLiveSequenceWorkflowCounts: [1, 1, 1],
                retainedLiveSequenceInvocationCounts: [1, 0, 0],
                metallibBuildInvocationCount: 1,
                metallibBuildCompleted: true,
                metallibByteCount: 6_292_732,
                metallibSHA256:
                    "53aa69728711f18cdf0886e2397bc1f8777b02c00d2235f83c03f71599470083",
                metalTestInvocationCount: 1,
                metalStartedTestCount: 44,
                metalPassedTestCount: 43,
                metalFailedTestCount: 1,
                metalAssertionFailureCount: 2,
                metalSkipCount: 0,
                metalFailureSummaryOccurrenceCount: 2,
                runtimeClosureInvocationCount: 0,
                runtimeAuthorityCompletedTestCount: 0,
                runtimeReceiptCount: 0,
                tokenizerCompatibilityInvocationCount: 0,
                tokenizerAuthorityCompletedTestCount: 0,
                tokenizerReceiptCount: 0,
                stage2ValidationPackageCommandCount: 0,
                stage2ValidationFilterCount: 0,
                stage2ValidationLogPathCount: 0,
                stage2ValidationScratchPathCount: 0,
                stage2ValidationBuildPathCount: 0,
                stage2ValidationCachePathCount: 0,
                stage2ValidationConfigPathCount: 0,
                stage2ValidationSecurityPathCount: 0,
                stage2InvocationCount: 0,
                retiredSeed42CheckpointCommandCount: 0,
                retiredSeed43CheckpointCommandCount: 0,
                checkpointReceiptMarkerCount: 0,
                artifactUploadStepCount: 0),
        sourceDriftBoundary:
            PrimeNativeDecoderMetalIdentityFailureSourceDriftBoundaryV1(
                decoderSourcePath:
                    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                frozenMetalAuthorityGitMode: "100644",
                frozenMetalAuthorityGitBlob:
                    "835a4826549e1f28ec27e3533f746218beb3bdf2",
                frozenMetalAuthorityByteCount: 39_050,
                frozenMetalAuthoritySHA256:
                    "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
                currentDecoderGitMode: "100644",
                currentDecoderGitBlob:
                    "0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f",
                currentDecoderByteCount: 39_598,
                currentDecoderSHA256:
                    "d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994",
                currentMinusFrozenByteCount: 548,
                stage2SeamIntroducingRevision:
                    "f13322ebc368c639a0f04b7570af093cc57ec22b",
                stage2SeamMethod:
                    "package func trainingLogitsNoCache(_ rankTwoTokenIDs: MLXArray) -> MLXArray",
                stage2SeamAddedLineCount: 14,
                diffContainsOnlyStage2TrainingSeam: true,
                frozenMetalAuthorityRemainsHistorical: true,
                currentDecoderMatchesExactMergeTree: true,
                observationMutatesNeitherIdentity: true),
        assertionFailureBoundary:
            PrimeNativeDecoderMetalIdentityFailureAssertionBoundaryV1(
                failedJobStepNumber: 6,
                failedJobStepName:
                    "Run the Prime-owned decoder on live Metal",
                failedStepStartedAt: "2026-08-11T20:55:27Z",
                failedStepCompletedAt: "2026-08-11T21:00:44Z",
                failedSuite: "PrimeNativeDecoderAuthorityTests",
                failedTestClass: "PrimeNativeDecoderAuthorityTests",
                failedTestMethod:
                    "testMetalRepairAuthorityIsAppendOnlyAndSourceExact",
                failedTestSourcePath:
                    "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift",
                byteCountAssertionLine: 338,
                sha256AssertionLine: 339,
                exactByteCountAssertionMessage:
                    "XCTAssertEqual failed: (\"39598\") is not equal to (\"39050\")",
                exactSHA256AssertionMessage:
                    "XCTAssertEqual failed: (\"d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994\") is not equal to (\"058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b\")",
                assertionStepMemberFirstDiagnosticTimestamp:
                    "2026-08-11T21:00:38.2311960Z",
                reviewedAggregateFirstDiagnosticTimestamp:
                    "2026-08-11T21:00:38.2312020Z",
                assertionStepMemberSecondDiagnosticTimestamp:
                    "2026-08-11T21:00:38.2314750Z",
                reviewedAggregateSecondDiagnosticTimestamp:
                    "2026-08-11T21:00:38.2314770Z",
                failedTestCaseCount: 1,
                assertionFailureCount: 2,
                processExitCode: 2,
                exactExitMessage: "Process completed with exit code 2.",
                assertionStepMemberExitTimestamp:
                    "2026-08-11T21:00:44.4133280Z",
                reviewedAggregateExitTimestamp:
                    "2026-08-11T21:00:44.4133330Z",
                failureClassification:
                    "metal_authority_current_decoder_identity_assertion_stale_after_stage2_package_only_seam"),
        failureSemantics:
            PrimeNativeDecoderMetalIdentityFailureSemanticsV1(
                inferenceBasis:
                    "exact_run_job_step_annotation_APIs_plus_two_byte_identical_raw_log_archive_downloads_and_exact_blob_diff",
                secureDependencyFetchSuccessObserved: true,
                predecessorTLSFailureWasNotRepeated: true,
                focusedRootSuccessObserved: true,
                freshMetallibBuildObserved: true,
                frozenMetalAuthorityIdentityAssertionFailureObserved: true,
                currentDecoderStage2SeamDriftEstablished: true,
                failureLimitedToCurrentDecoderIdentityAssertion: true,
                runtimeAndTokenizerBlockedByOrderedFailClosedSequence: true,
                predecessorTLSObservationRemainsFrozen: true,
                predecessorStage2FailureObservationRemainsFrozen: true,
                predecessorStage2AttemptRemainsExhausted: true,
                separateIdentityAssertionRepairRequired: true,
                stage3RemainsBlocked: true,
                privateDependencyTLSFailureObserved: false,
                metallibBuildFailureObserved: false,
                metalFunctionalRegressionEstablished: false,
                frozenMetalAuthorityMutationPerformed: false,
                decoderSourceMutationPerformed: false,
                currentDecoderIdentityRepairAttempted: false,
                currentDecoderIdentityRepairEstablished: false,
                metalValidationEstablished: false,
                runtimeClosureEvaluated: false,
                runtimeClosureEstablished: false,
                tokenizerCompatibilityEvaluated: false,
                tokenizerCompatibilityEstablished: false,
                stage2ExecutionEvaluated: false,
                stage2ExecutionEstablished: false,
                stage2BootstrapRepairEstablished: false,
                stage3AuthorityEstablished: false),
        artifactBoundary:
            PrimeNativeDecoderMetalIdentityFailureArtifactBoundaryV1(
                actionsArtifactsEndpoint:
                    "https://api.github.com/repos/Ergentics/ergentics-prime/actions/runs/31533658617/artifacts",
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
        authorityCeiling:
            PrimeNativeDecoderMetalIdentityFailureAuthorityCeilingV1(
                rerunAuthorized: false,
                replacementRunAuthorized: false,
                workflowMutationAuthorized: false,
                frozenMetalAuthorityMutationAuthorized: false,
                decoderSourceReversionAuthorized: false,
                currentDecoderIdentityAssertionRepairAuthorized: false,
                currentDecoderIdentityAssertionRepairEstablished: false,
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
            "ABSTAIN_exact_main_root36_and_fresh_metallib_passed_metal44_current_decoder_identity_assertion_failed_runtime_tokenizer_stage2_checkpoint_absent_no_rerun_no_artifact_no_downstream_authority",
        orderedRequiredSeparateActions: [
            "preserve_run_31533658617_attempt_1_as_terminal_current_decoder_identity_assertion_failure_evidence",
            "preserve_the_frozen_historical_metal_repair_identity_and_current_stage2_decoder_seam",
            "separately_authorize_a_current_decoder_identity_assertion_successor_without_rerunning_this_attempt",
            "require_root37_then_metal44_then_runtime1_then_tokenizer1_before_any_success_observation",
            "keep_stage2_retired_and_stage3_blocked_pending_separate_default_metallib_bootstrap_repair_authority",
        ])

    private static func rawLog(
        scope: String,
        byteCount: Int,
        sha256: String,
        lfByteCount: Int,
        firstTimestamp: String,
        lastTimestamp: String
    ) -> PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1 {
        PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1(
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
                "LF_byte_count_equals_split_lines_excluding_terminal_empty_and_components_include_terminal_empty",
            firstTimestamp: firstTimestamp,
            lastTimestamp: lastTimestamp)
    }

    private static let archiveMembers = [
        Self.member(
            "0_Reviewed main _ focused source contracts.txt",
            10_192_525, 77_932,
            "0b2d720a64c341dc874f3271b0e4a5792c6d7af36337f1d15f1641d27937ef16"),
        Self.member(
            "Reviewed main _ focused source contracts/system.txt",
            800, 8,
            "3ddf9da8b176428891759d2168c13b64742b35026aedad701c9b8475175bc2ce"),
        Self.member(
            "Reviewed main _ focused source contracts/1_Set up job.txt",
            1_680, 28,
            "f3940f5209d7d016d096dc877f9f21158073b16496ee76efe45df3159d49bac4"),
        Self.member(
            "Reviewed main _ focused source contracts/2_Record the hosted Apple toolchain.txt",
            1_279, 22,
            "df831d21fe81a950c7e9b6546371b64a8452172a88d1fac8fc500c40fe9ca433"),
        Self.member(
            "Reviewed main _ focused source contracts/3_Check out reviewed main exactly.txt",
            3_162, 37,
            "0984e28628508e74ea3e7685f4167dc36963aa226b4b7ead7e4a31cf50c86652"),
        Self.member(
            "Reviewed main _ focused source contracts/4_Fetch the exact private dependency without evaluating Prime.txt",
            4_893, 54,
            "7c50a7eddd18f8c8049ef431164da6175ffae284140dfd68a9062d8d0bc701a2"),
        Self.member(
            "Reviewed main _ focused source contracts/5_Compile and run the focused contracts without a credential.txt",
            337_696, 3_310,
            "f972a9fe4bf0f00c467dd90f43a60cc594f2228cec6e720d8acfd2816b6f61e1"),
        Self.member(
            "Reviewed main _ focused source contracts/6_Run the Prime-owned decoder on live Metal.txt",
            9_843_772, 74_480,
            "343c5ae69d86eb6ba16d1ab0fe72663651c3ca3d4ae921e632c355e2f7506f6a"),
        Self.member(
            "Reviewed main _ focused source contracts/7_Complete job.txt",
            61, 1,
            "234e771a54d449185fe62a7808f3923a2857960f167b93d601fad9711c398a42"),
        Self.member(
            "1_First-party MLX _ active-root quarantine.txt",
            232_035, 1_740,
            "46187396b65c13adf6e1da20d625890eb804f6b4ba476615ed0a532a55c89682"),
        Self.member(
            "First-party MLX _ active-root quarantine/system.txt",
            601, 7,
            "5c523ec26cce6e10f2969b7a3f5fe8b496faa4c6d33e3dfbf2bd2e8fcbe8db46"),
        Self.member(
            "First-party MLX _ active-root quarantine/1_Set up job.txt",
            1_681, 28,
            "39673f32e2135fa3033236cf27bbad5b7937848d56ac704828b78d9528fa73e5"),
        Self.member(
            "First-party MLX _ active-root quarantine/2_Check out the exact Prime revision.txt",
            3_070, 36,
            "8610af3c6112c646c0f069a61c09b45ae6b325c0141af88c83fedbbd5dac77b8"),
        Self.member(
            "First-party MLX _ active-root quarantine/3_Validate active metadata and preserved history.txt",
            706, 8,
            "ab57d3f2335adb51dcab98b0dad3ea157b31c52c27a5626fb05029145cc239b8"),
        Self.member(
            "First-party MLX _ active-root quarantine/4_Parse the changed Swift contracts without dependencies.txt",
            12_707, 95,
            "5388b792304c2e58db8ba9ec0eed5a8a6cf476133e70e5d5931477899887d4ee"),
        Self.member(
            "First-party MLX _ active-root quarantine/5_Validate isolated Latin capture and observation contracts.txt",
            196_157, 1_520,
            "9b85bc4ffa36285d9a6a5ae0b56bcad21a120af4e63fca91ef913fe729236ade"),
        Self.member(
            "First-party MLX _ active-root quarantine/6_Record the authority ceiling.txt",
            17_671, 52,
            "c3d1855e7bcaacdf37caad12ceb09cea5a06945d829b83254aacbd16cf7b640e"),
        Self.member(
            "First-party MLX _ active-root quarantine/7_Complete job.txt",
            61, 1,
            "80f3499edc94280b74a92a364cbfb7ec22864d7b1cd32d2a4b4db0f765768cd3"),
    ]

    private static func member(
        _ path: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String
    ) -> PrimeNativeDecoderMetalIdentityFailureArchiveMemberIdentityV1 {
        PrimeNativeDecoderMetalIdentityFailureArchiveMemberIdentityV1(
            path: path,
            byteCount: byteCount,
            lfByteCount: lfByteCount,
            sha256: sha256)
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
                PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationError
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
            PrimeReviewedMainPrivateDependencyTLSFailureObservationV1.frozenV1
        do {
            try predecessor.validateExactV1()
            guard predecessorObservationID == predecessor.observationID,
                  predecessorCanonicalSHA256
                    == PrimeSHA256.hexDigest(
                        of: try predecessor.canonicalData()) else {
                throw
                    PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationError
                        .contractDrift
            }
        } catch {
            throw
                PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationError
                    .contractDrift
        }

        let execution = executionBoundary
        let drift = sourceDriftBoundary
        let assertion = assertionFailureBoundary
        let semantics = failureSemantics
        let artifacts = artifactBoundary
        let ceiling = authorityCeiling
        let semanticFalseClaims = [
            semantics.privateDependencyTLSFailureObserved,
            semantics.metallibBuildFailureObserved,
            semantics.metalFunctionalRegressionEstablished,
            semantics.frozenMetalAuthorityMutationPerformed,
            semantics.decoderSourceMutationPerformed,
            semantics.currentDecoderIdentityRepairAttempted,
            semantics.currentDecoderIdentityRepairEstablished,
            semantics.metalValidationEstablished,
            semantics.runtimeClosureEvaluated,
            semantics.runtimeClosureEstablished,
            semantics.tokenizerCompatibilityEvaluated,
            semantics.tokenizerCompatibilityEstablished,
            semantics.stage2ExecutionEvaluated,
            semantics.stage2ExecutionEstablished,
            semantics.stage2BootstrapRepairEstablished,
            semantics.stage3AuthorityEstablished,
        ]
        let artifactFalseClaims = [
            artifacts.runLogArchiveIsActionsArtifact,
            artifacts.jobLogsRetainedInRepository,
            artifacts.durableJobLogPublicationEstablished,
            artifacts.runtimeReceiptEmitted,
            artifacts.tokenizerReceiptEmitted,
            artifacts.checkpointReceiptEmitted,
            artifacts.checkpointArtifactCreated,
            artifacts.checkpointArtifactUploaded,
            artifacts.checkpointArtifactRetained,
            artifacts.checkpointArtifactProvenanceEstablished,
        ]
        let authorityClaims = [
            ceiling.rerunAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.workflowMutationAuthorized,
            ceiling.frozenMetalAuthorityMutationAuthorized,
            ceiling.decoderSourceReversionAuthorized,
            ceiling.currentDecoderIdentityAssertionRepairAuthorized,
            ceiling.currentDecoderIdentityAssertionRepairEstablished,
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
              observedSourceBindings.count == 9,
              Set(observedSourceBindings.map(\.path)).count == 9,
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
              Self.validRawLog(liveMetalStepRawLog),
              rawLogArchive.members.count == rawLogArchive.memberCount,
              rawLogArchive.members.reduce(0, { $0 + $1.byteCount })
                == rawLogArchive.uncompressedByteCount,
              Set(rawLogArchive.members.map(\.path)).count
                == rawLogArchive.memberCount,
              rawLogArchive.assertionStepMemberFirstDiagnosticTimestamp
                == assertion.assertionStepMemberFirstDiagnosticTimestamp,
              rawLogArchive.reviewedAggregateFirstDiagnosticTimestamp
                == assertion.reviewedAggregateFirstDiagnosticTimestamp,
              rawLogArchive.assertionStepMemberSecondDiagnosticTimestamp
                == assertion.assertionStepMemberSecondDiagnosticTimestamp,
              rawLogArchive.reviewedAggregateSecondDiagnosticTimestamp
                == assertion.reviewedAggregateSecondDiagnosticTimestamp,
              rawLogArchive.assertionStepMemberExitTimestamp
                == assertion.assertionStepMemberExitTimestamp,
              rawLogArchive.reviewedAggregateExitTimestamp
                == assertion.reviewedAggregateExitTimestamp,
              execution.activeRootGatePassed,
              execution.dependencyFreeSwiftParsePassed,
              execution.latinTestInvocationCount == 1,
              execution.latinCompletedTestCount == 116,
              execution.latinFailureCount == 0,
              execution.latinSkipCount == 0,
              execution.securePrivateDependencyFetchInvocationCount == 1,
              execution.securePrivateDependencyFetchCompleted,
              execution.focusedRootRequiredTestCount == 36,
              execution.focusedRootInvocationCount == 1,
              execution.focusedRootCompletedTestCount == 36,
              execution.focusedRootFailureCount == 0,
              execution.focusedRootSkipCount == 0,
              execution.retainedLiveSequence.count == 3,
              execution.retainedLiveSequenceWorkflowCounts == [1, 1, 1],
              execution.retainedLiveSequenceInvocationCounts == [1, 0, 0],
              execution.metallibBuildInvocationCount == 1,
              execution.metallibBuildCompleted,
              execution.metalTestInvocationCount == 1,
              execution.metalStartedTestCount == 44,
              execution.metalPassedTestCount == 43,
              execution.metalFailedTestCount == 1,
              execution.metalAssertionFailureCount == 2,
              execution.metalSkipCount == 0,
              execution.runtimeClosureInvocationCount == 0,
              execution.runtimeReceiptCount == 0,
              execution.tokenizerCompatibilityInvocationCount == 0,
              execution.tokenizerReceiptCount == 0,
              execution.stage2ValidationPackageCommandCount == 0,
              execution.stage2ValidationFilterCount == 0,
              execution.stage2ValidationLogPathCount == 0,
              execution.stage2ValidationScratchPathCount == 0,
              execution.stage2InvocationCount == 0,
              execution.retiredSeed42CheckpointCommandCount == 0,
              execution.retiredSeed43CheckpointCommandCount == 0,
              execution.checkpointReceiptMarkerCount == 0,
              execution.artifactUploadStepCount == 0,
              drift.currentDecoderByteCount - drift.frozenMetalAuthorityByteCount
                == drift.currentMinusFrozenByteCount,
              drift.currentMinusFrozenByteCount == 548,
              drift.diffContainsOnlyStage2TrainingSeam,
              drift.frozenMetalAuthorityRemainsHistorical,
              drift.currentDecoderMatchesExactMergeTree,
              drift.observationMutatesNeitherIdentity,
              assertion.failedJobStepNumber == 6,
              assertion.failedTestCaseCount == 1,
              assertion.assertionFailureCount == 2,
              assertion.processExitCode == 2,
              semantics.secureDependencyFetchSuccessObserved,
              semantics.predecessorTLSFailureWasNotRepeated,
              semantics.focusedRootSuccessObserved,
              semantics.freshMetallibBuildObserved,
              semantics.frozenMetalAuthorityIdentityAssertionFailureObserved,
              semantics.currentDecoderStage2SeamDriftEstablished,
              semantics.failureLimitedToCurrentDecoderIdentityAssertion,
              semantics.runtimeAndTokenizerBlockedByOrderedFailClosedSequence,
              semantics.predecessorTLSObservationRemainsFrozen,
              semantics.predecessorStage2FailureObservationRemainsFrozen,
              semantics.predecessorStage2AttemptRemainsExhausted,
              semantics.separateIdentityAssertionRepairRequired,
              semantics.stage3RemainsBlocked,
              semanticFalseClaims.allSatisfy({ !$0 }),
              artifacts.actionsArtifactsTotalCount == 0,
              artifacts.actionsArtifactsArrayExactlyEmpty,
              artifacts.publishedWorkflowArtifactCount == 0,
              artifacts.artifactUploadStepCount == 0,
              artifactFalseClaims.allSatisfy({ !$0 }),
              authorityClaims.allSatisfy({ !$0 }) else {
            throw
                PrimeNativeDecoderMetalCurrentDecoderIdentityAssertionFailureObservationError
                    .contractDrift
        }
    }

    private static func validRawLog(
        _ log: PrimeNativeDecoderMetalIdentityFailureRawLogIdentityV1
    ) -> Bool {
        log.byteCount > 0
            && log.sha256.utf8.count == 64
            && log.utf8BOMHex == "efbbbf"
            && log.startsWithUTF8BOM
            && log.usesLFOnly
            && log.endsWithLF
            && log.lfByteCount
                == log.splitLineCountExcludingTerminalEmpty
            && log.newlineDelimitedComponentCountIncludingTerminalEmpty
                == log.lfByteCount + 1
    }
}
