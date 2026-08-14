// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

/// Frozen evidence for the exhausted run-105 Stage-5 execution.
///
/// The sole XCTest failed a three-conjunct source-step guard inside an
/// unlogged three-trial loop. The log therefore proves neither which conjunct
/// failed nor the failing trial ordinal. It emitted no Stage-5 receipt and
/// establishes no repeated-trajectory determinism or downstream authority.
public struct
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationV1:
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
        public let mergeRevision: String
        public let orderedParentRevisions: [String]
        public let mergeTree: String
        public let reviewedHeadTree: String
        public let mergedAt: String
        public let mergeCommitSignatureVerified: Bool
        public let mergeCommitSignatureReason: String
        public let historyPreservingTwoParentMergeObserved: Bool
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let exactMainRefMatchedAtTerminalAudit: Bool
        public let changedPathCount: Int
        public let manifestOrLockChangedPathCount: Int
        public let embeddedSourceIdentitySHA256: String
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
        public let bindingKind: String
        public let rawGitHubLogArchiveBytesBound: Bool
        public let retainedInRepository: Bool
    }

    public struct RepairClosureBoundary: Codable, Equatable, Sendable {
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let checkSuiteID: Int
        public let stage5AuthorityID: String
        public let stage5AuthorityCanonicalSHA256: String
        public let immediateRepairAuthorityID: String
        public let immediateRepairAuthorityCanonicalSHA256: String
        public let exactMLXRevision: String
        public let exactSwiftNumericsRevision: String
        public let frozenByConsumedLauncher: Bool
    }

    public struct PreStage5Boundary: Codable, Equatable, Sendable {
        public let activeRootGatePassed: Bool
        public let dependencyFreeSwiftParsePassed: Bool
        public let latinInvocationCount: Int
        public let latinTestCount: Int
        public let latinFailureCount: Int
        public let latinSkipCount: Int
        public let focusedRootInvocationCount: Int
        public let focusedRootTestCount: Int
        public let isolatedCheckpointGroupTestCounts: [Int]
        public let isolatedCheckpointTestCount: Int
        public let focusedWholeStepTestCount: Int
        public let focusedFailureCount: Int
        public let focusedSkipCount: Int
        public let depthOneCheckoutCount: Int
        public let securePrivateDependencyFetchInvocationCount: Int
        public let securePrivateDependencyFetchCompletionCount: Int
        public let authenticatedDepthOneFetchCount: Int
        public let submoduleUpdateCount: Int
        public let mlxCloneCount: Int
        public let mlxCCloneCount: Int
        public let workflowAuthoredFetchRetryCount: Int
        public let gitInternalFetchRetryCount: Int
        public let tlsVerificationFailureCount: Int
        public let tlsVerificationBypassCount: Int
        public let customCertificateAuthorityCount: Int
        public let swiftNumericsCacheMappingValidated: Bool
        public let swiftNumericsCacheMappingCount: Int
        public let swiftNumericsCacheFetchCompletionCount: Int
        public let swiftNumericsMappedIsolatedInvocationCount: Int
        public let metallibPublicSwiftNumericsFetchCount: Int
        public let metallibPublicSwiftNumericsCheckoutCount: Int
        public let metallibPublicSwiftNumericsResolutionSucceeded: Bool
        public let swiftNumericsResolvedRevision: String
        public let observedLiveExecutionOrder: [String]
        public let metalInvocationCount: Int
        public let metalTestCount: Int
        public let metalFailureCount: Int
        public let metalSkipCount: Int
        public let runtimeInvocationCount: Int
        public let runtimeTestCount: Int
        public let runtimeFailureCount: Int
        public let runtimeSkipCount: Int
        public let runtimeReceiptCount: Int
        public let tokenizerInvocationCount: Int
        public let tokenizerTestCount: Int
        public let tokenizerFailureCount: Int
        public let tokenizerSkipCount: Int
        public let tokenizerReceiptCount: Int
        public let preStage5TestCount: Int
        public let preStage5FailureCount: Int
        public let preStage5SkipCount: Int
        public let predecessorStage3TypedInMemoryResumeRemainsEstablished: Bool
        public let predecessorStage4DurableRoundTripRemainsEstablished: Bool
        public let stage4LauncherInvocationCount: Int
        public let stage6LauncherInvocationCount: Int
    }

    public struct AssayFailureBoundary: Codable, Equatable, Sendable {
        public let failedJobStepNumber: Int
        public let failedJobStepName: String
        public let failedJobStepStartedAt: String
        public let failedJobStepCompletedAt: String
        public let stage5LauncherInvocationCount: Int
        public let stage5BuildInvocationCount: Int
        public let stage5BuildCompletionCount: Int
        public let stage5BuildDurationMilliseconds: Int
        public let stage5DirectXCTestInvocationCount: Int
        public let testFile: String
        public let failureSourceLine: Int
        public let testClass: String
        public let testMethod: String
        public let testFilter: String
        public let testStartCount: Int
        public let testPassCount: Int
        public let testFailureCount: Int
        public let testSkipCount: Int
        public let allReviewedTestStartCount: Int
        public let allReviewedTestPassCount: Int
        public let allReviewedTestFailureCount: Int
        public let allReviewedTestSkipCount: Int
        public let exactFailureSummaryOccurrenceCount: Int
        public let testDurationMilliseconds: Int
        public let outerSummaryDurationMilliseconds: Int
        public let exactThrownError: String
        public let exactThrownErrorOccurrenceCount: Int
        public let combinedGuardConjuncts: [String]
        public let combinedGuardFailed: Bool
        public let failedConjunctIdentified: Bool
        public let sourceStepEqualityEstablished: Bool
        public let sourceStepEqualityDisproved: Bool
        public let globalStepOneEstablished: Bool
        public let globalStepOneDisproved: Bool
        public let selectedTargetCountSixEstablished: Bool
        public let selectedTargetCountSixDisproved: Bool
        public let failingTrialOrdinalEstablished: Bool
        public let failingTrialOrdinalMinimum: Int
        public let failingTrialOrdinalMaximum: Int
        public let priorCompletedTrialCountEstablished: Bool
        public let priorCompletedTrialCountMinimum: Int
        public let priorCompletedTrialCountMaximum: Int
        public let globalCompletedBranchCountEstablished: Bool
        public let freshSourceObjectsGuardPassedInFailingTrial: Bool
        public let bothFirstStepCallsReturnedInFailingTrial: Bool
        public let tinyStage5TrainingExecutionObserved: Bool
        public let failingTrialEvaluationReached: Bool
        public let failingTrialSnapshotReached: Bool
        public let receiptPostflightAfterLoopReached: Bool
        public let stage5ReceiptAnchoredCount: Int
        public let stage5ReceiptTotalOccurrenceCount: Int
        public let stage5ReceiptConstructed: Bool
        public let stage5ReceiptEmitted: Bool
        public let stage5DeterminismEstablished: Bool
        public let launcherExitCode: Int
        public let launcherFailureLine: String
        public let launcherFailureLineOccurrenceCount: Int
        public let workflowProcessExitCode: Int
        public let workflowExitMessage: String
        public let workflowExitAnnotationOccurrenceCount: Int
    }

    public struct LeaseBoundary: Codable, Equatable, Sendable {
        public let environmentKey: String
        public let parentPath: String
        public let path: String
        public let acquiredBeforeCoreGraphicsMetalOrMLXAccessSourceInferred: Bool
        public let heldAtFailedGuardSourceInferred: Bool
        public let acquisitionFailureObserved: Bool
        public let receiptEmittedWhileHeld: Bool
        public let receiptFlushedWhileHeld: Bool
        public let explicitReleaseImmediatelyAfterReceiptReached: Bool
        public let deinitCallsReleaseInFrozenSource: Bool
        public let deinitReleaseObservedInTerminalLog: Bool
        public let processTerminationReleasesKernelFlock: Bool
        public let launcherPostSuccessLeaseFileCleanupReached: Bool
        public let leaseFileDeletionObserved: Bool
        public let leaseParentDeletionObserved: Bool
        public let leaseHeldAfterXCTestProcessExit: Bool
    }

    public struct ArtifactBoundary: Codable, Equatable, Sendable {
        public let actionsArtifactsTotalCount: Int
        public let actionsArtifactsArrayExactlyEmpty: Bool
        public let artifactUploadStepCount: Int
        public let stage5ReceiptArtifactCreated: Bool
        public let stage5ReceiptArtifactUploaded: Bool
        public let stage5ReceiptRetainedInRepository: Bool
        public let durableJobLogPublicationEstablished: Bool
    }

    public struct RetirementBoundary: Codable, Equatable, Sendable {
        public let retirementRequired: Bool
        public let retirementObserved: Bool
        public let exactChangedPathCount: Int
        public let exactOrderedChangedPaths: [String]
        public let expectedRootTestCount: Int
        public let expectedIsolatedCheckpointGroupTestCounts: [Int]
        public let expectedIsolatedCheckpointTestCount: Int
        public let expectedFocusedWholeStepTestCount: Int
        public let expectedMetalTestCount: Int
        public let expectedRuntimeTestCount: Int
        public let expectedTokenizerTestCount: Int
        public let expectedLiveExecutionOrder: [String]
        public let expectedTotalTestCount: Int
        public let expectedDepthOneCheckoutCount: Int
        public let expectedStage4LauncherInvocationCount: Int
        public let expectedStage5LauncherInvocationCount: Int
        public let expectedStage5ReceiptCount: Int
        public let expectedStage6LauncherInvocationCount: Int
        public let stage5LauncherMustRemainPreserved: Bool
        public let stage5LauncherPath: String
        public let stage5LauncherGitMode: String
        public let stage5LauncherGitBlob: String
        public let stage5LauncherByteCount: Int
        public let stage5LauncherLFByteCount: Int
        public let stage5LauncherSHA256: String
        public let replacementLiveExecutionPermittedByRetirement: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let oneShotExecutionConsumed: Bool
        public let oneShotExecutionExhausted: Bool
        public let failureObservationAuthorizesNothing: Bool
        public let exactRetirementRequired: Bool
        public let launcherPreservationRequired: Bool
        public let mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: Bool
        public let oneExactMainExecutionOpportunityAuthorized: Bool
        public let threeBoundedSameProcessAssayTrialsAuthorized: Bool
        public let inMemorySourceSnapshotAuthorized: Bool
        public let rerunAuthorized: Bool
        public let retryAuthorized: Bool
        public let replacementRunAuthorized: Bool
        public let launcherMutationAuthorized: Bool
        public let additionalExecutionOrRerunAuthorized: Bool
        public let stage4RerunAuthorized: Bool
        public let stage5ReceiptEstablished: Bool
        public let stage5MechanicsExecuted: Bool
        public let stage5ResultEstablished: Bool
        public let stage5MechanicsSuccessEstablished: Bool
        public let repeatedTrajectoryDeterminismEstablished: Bool
        public let stage5AssayCheckpointResumeEstablished: Bool
        public let stage5AssayDurableCheckpointIOObserved: Bool
        public let durableCheckpointIOAuthorized: Bool
        public let retainedCheckpointArtifactAuthorized: Bool
        public let retainedArtifactAuthorized: Bool
        public let checkpointArtifactUploadAuthorized: Bool
        public let artifactUploadAuthorized: Bool
        public let crossDeviceDeterminismEstablished: Bool
        public let crossDeviceClaimAuthorized: Bool
        public let exactMetalGradientBytesEstablished: Bool
        public let metalDeterminismEstablished: Bool
        public let trainingExecutionObserved: Bool
        public let stage5AssayNative300MModelAllocationObserved: Bool
        public let native300MAllocationAuthorized: Bool
        public let native300MTrainingEstablished: Bool
        public let native300MTrainingAuthorized: Bool
        public let native300MTrainingObserved: Bool
        public let generalTrainingEstablished: Bool
        public let generalTrainingAuthorized: Bool
        public let stage5AssayTrainingResumeEstablished: Bool
        public let generalTrainingResumeEstablished: Bool
        public let checkpointAdmissionGranted: Bool
        public let modelQualityEstablished: Bool
        public let candidateAdmissionGranted: Bool
        public let downstreamTrialAuthorized: Bool
        public let canaryAuthorized: Bool
        public let quantizationAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
        public let stage6AuthorityEstablished: Bool
        public let stage6Authorized: Bool
    }

    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let repositoryIdentity: RepositoryIdentity
    public let observedSourceBindings: [SourceIdentity]
    public let runIdentity: RunIdentity
    public let activeRootJob: JobIdentity
    public let reviewedMainJob: JobIdentity
    public let activeRootRawLog: RawLogIdentity
    public let reviewedMainRawLog: RawLogIdentity
    public let repairClosureBoundary: RepairClosureBoundary
    public let preStage5Boundary: PreStage5Boundary
    public let assayFailureBoundary: AssayFailureBoundary
    public let leaseBoundary: LeaseBoundary
    public let artifactBoundary: ArtifactBoundary
    public let retirementBoundary: RetirementBoundary
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_execution_failure_observation_v1",
        observationKind:
            "terminal_exact_main_one_shot_stage5_combined_source_step_guard_failure",
        predecessorAuthorityID:
            "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_exact_main_swift_numerics_resolution_repair_authority_v1",
        predecessorAuthorityCanonicalSHA256:
            "a5a8e5300ea8413e738fddd4b8fed930dcc9983d5a29eea102862f9744b50fff",
        repositoryIdentity: .init(
            repository: "Ergentics/ergentics-prime",
            pullRequestNumber: 104,
            ref: "refs/heads/main",
            baseRevision: "522e4620596eed909822b80b782d74d282f429c5",
            baseTree: "d0304aadcf533a341d89df262f8cbe74c1c13b90",
            reviewedHeadRevision: "ed4833a3a90b265f61a06b6ab25547010bba8807",
            mergeRevision: "8bdf6abe15d7f9a83045a3f9ee21fcc28f7ee91d",
            orderedParentRevisions: [
                "522e4620596eed909822b80b782d74d282f429c5",
                "ed4833a3a90b265f61a06b6ab25547010bba8807",
            ],
            mergeTree: "f7dbc81e4f7e8ccebdf39f0fb5200a7780be91dc",
            reviewedHeadTree: "f7dbc81e4f7e8ccebdf39f0fb5200a7780be91dc",
            mergedAt: "2026-08-14T00:08:17Z",
            mergeCommitSignatureVerified: true,
            mergeCommitSignatureReason: "valid",
            historyPreservingTwoParentMergeObserved: true,
            mergeTreeEqualsReviewedHeadTree: true,
            exactMainRefMatchedAtTerminalAudit: true,
            changedPathCount: 6,
            manifestOrLockChangedPathCount: 0,
            embeddedSourceIdentitySHA256:
                "4f8d6f238fcdeaf800d7a12af76be6082682b42b38d79c9b9bfe0f490309c791"),
        observedSourceBindings: [
            source(
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                "100755", "51b587dc62d3a8a682b5a1bc2e69368e98dbad01",
                570_942, 9_987,
                "32595f6f9cae256365f5003d4d5051f40780fe04dcf64851d80bebade2645b87",
                "consumed_stage5_mechanics_active_gate"),
            source(
                ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh",
                "100755", "6547ee06663c1ea409a6256e48f6111245056020",
                48_869, 830,
                "c639cfcb4d1d0a103b285ed38849565f16b00932fc3b9d921febbf798c30d5f9",
                "consumed_launcher_preserved_for_audit"),
            source(
                ".github/workflows/prime-active-root-quarantine.yml",
                "100644", "241f65ff275bbe401c4a86adea2b3cf3150dc939",
                70_447, 557,
                "697e64f4a46ae4b650d6bd00f642c0ee80fa155d7cc04103a5a5ed5a96fc1bf4",
                "exact_main_one_shot_workflow"),
            source(
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "100644", "ba6188767be6d1f3c027c800ae5322c9238944a2",
                546, 13,
                "6240657510b9983caf6b459d950945df67a6251bd0bac0a666130f62d542de9b",
                "embedded_changed_source_identity"),
            source(
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "100644", "271b7fe4a856a76a00730954c23bdca3b33e761d",
                86_387, 2_173,
                "f49b946e5272992f09ecf7b1dd8439bda15c5ac696a4f6298bafa19994f2b4c2",
                "stage5_training_mechanics"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
                "100644", "46f91f32e91870d21c46cd318972a857b8ef6e12",
                28_292, 606,
                "50b19a0bfe8752d2b80c09527b70731d906e8064c8e2d49a758c8c48b48f4398",
                "sole_stage5_live_xctest"),
        ],
        runIdentity: .init(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_756_331_438,
            runNumber: 105,
            runAttempt: 1,
            event: "push",
            headBranch: "main",
            headRevision: "8bdf6abe15d7f9a83045a3f9ee21fcc28f7ee91d",
            actor: "psyop-archivist",
            triggeringActor: "psyop-archivist",
            createdAt: "2026-08-14T00:08:19Z",
            startedAt: "2026-08-14T00:08:19Z",
            terminalUpdatedAt: "2026-08-14T00:55:28Z",
            status: "completed",
            conclusion: "failure",
            checkSuiteID: 86_154_359_326,
            exactHeadPushRunCount: 1,
            previousAttemptURLWasNull: true,
            rerunCount: 0,
            rerunObserved: false,
            rerunAuthorized: false,
            runURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31756331438"),
        activeRootJob: job(
            94_632_729_903,
            "First-party MLX / active-root quarantine", "success",
            "2026-08-14T00:08:22Z", "2026-08-14T00:12:10Z",
            1_000_001_748, "GitHub Actions 1000001748", "macos-15",
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
            0, "", 0, "",
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31756331438/job/94632729903"),
        reviewedMainJob: job(
            94_633_409_696,
            "Reviewed main / focused source contracts", "failure",
            "2026-08-14T00:12:13Z", "2026-08-14T00:55:27Z",
            1_000_001_749, "GitHub Actions 1000001749", "macos-26",
            [
                "Set up job",
                "Record the hosted Apple toolchain",
                "Check out reviewed main exactly",
                "Fetch the exact private dependency without evaluating Prime",
                "Compile and run the focused contracts without a credential",
                "Run the Prime-owned decoder on live Metal",
                "Complete job",
            ],
            [
                "success", "success", "success", "success", "success",
                "failure", "success",
            ],
            1, ".github", 75_376, "Process completed with exit code 2.",
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31756331438/job/94633409696"),
        activeRootRawLog: rawLog(
            254_662, 1_797,
            "9d891c4dc94e2fdfc2422c08a1455d7841bdd8431538dad07a1acacfdb0aff04"),
        reviewedMainRawLog: rawLog(
            10_320_159, 79_103,
            "9141883d20c03c210a6d544256dd89b4bfa31406230dd372b4d44df65b27f16c"),
        repairClosureBoundary: .init(
            workflowRunID: 31_750_678_556,
            workflowRunNumber: 103,
            checkSuiteID: 86_139_786_214,
            stage5AuthorityID:
                "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_authority_v1",
            stage5AuthorityCanonicalSHA256:
                "00c49e63315b2aacb439204e778f54bcf63c2fdf643282f3bd64e2b3b4094089",
            immediateRepairAuthorityID:
                "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_exact_main_swift_numerics_resolution_repair_authority_v1",
            immediateRepairAuthorityCanonicalSHA256:
                "a5a8e5300ea8413e738fddd4b8fed930dcc9983d5a29eea102862f9744b50fff",
            exactMLXRevision: "d37885a278f1c37484a94d0f401a418735e66519",
            exactSwiftNumericsRevision:
                "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
            frozenByConsumedLauncher: true),
        preStage5Boundary: .init(
            activeRootGatePassed: true,
            dependencyFreeSwiftParsePassed: true,
            latinInvocationCount: 1,
            latinTestCount: 116,
            latinFailureCount: 0,
            latinSkipCount: 0,
            focusedRootInvocationCount: 1,
            focusedRootTestCount: 53,
            isolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
            isolatedCheckpointTestCount: 6,
            focusedWholeStepTestCount: 59,
            focusedFailureCount: 0,
            focusedSkipCount: 0,
            depthOneCheckoutCount: 2,
            securePrivateDependencyFetchInvocationCount: 1,
            securePrivateDependencyFetchCompletionCount: 1,
            authenticatedDepthOneFetchCount: 1,
            submoduleUpdateCount: 1,
            mlxCloneCount: 1,
            mlxCCloneCount: 1,
            workflowAuthoredFetchRetryCount: 0,
            gitInternalFetchRetryCount: 0,
            tlsVerificationFailureCount: 0,
            tlsVerificationBypassCount: 0,
            customCertificateAuthorityCount: 0,
            swiftNumericsCacheMappingValidated: true,
            swiftNumericsCacheMappingCount: 1,
            swiftNumericsCacheFetchCompletionCount: 9,
            swiftNumericsMappedIsolatedInvocationCount: 4,
            metallibPublicSwiftNumericsFetchCount: 1,
            metallibPublicSwiftNumericsCheckoutCount: 1,
            metallibPublicSwiftNumericsResolutionSucceeded: true,
            swiftNumericsResolvedRevision:
                "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
            observedLiveExecutionOrder: [
                "metal", "maintained_runtime", "tokenizer",
            ],
            metalInvocationCount: 1,
            metalTestCount: 44,
            metalFailureCount: 0,
            metalSkipCount: 0,
            runtimeInvocationCount: 1,
            runtimeTestCount: 1,
            runtimeFailureCount: 0,
            runtimeSkipCount: 0,
            runtimeReceiptCount: 1,
            tokenizerInvocationCount: 1,
            tokenizerTestCount: 1,
            tokenizerFailureCount: 0,
            tokenizerSkipCount: 0,
            tokenizerReceiptCount: 1,
            preStage5TestCount: 105,
            preStage5FailureCount: 0,
            preStage5SkipCount: 0,
            predecessorStage3TypedInMemoryResumeRemainsEstablished: true,
            predecessorStage4DurableRoundTripRemainsEstablished: true,
            stage4LauncherInvocationCount: 0,
            stage6LauncherInvocationCount: 0),
        assayFailureBoundary: .init(
            failedJobStepNumber: 6,
            failedJobStepName: "Run the Prime-owned decoder on live Metal",
            failedJobStepStartedAt: "2026-08-14T00:33:22Z",
            failedJobStepCompletedAt: "2026-08-14T00:55:17Z",
            stage5LauncherInvocationCount: 1,
            stage5BuildInvocationCount: 1,
            stage5BuildCompletionCount: 1,
            stage5BuildDurationMilliseconds: 179_580,
            stage5DirectXCTestInvocationCount: 1,
            testFile:
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
            failureSourceLine: 135,
            testClass:
                "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests",
            testMethod:
                "testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes",
            testFilter:
                "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests/testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes",
            testStartCount: 1,
            testPassCount: 0,
            testFailureCount: 1,
            testSkipCount: 0,
            allReviewedTestStartCount: 106,
            allReviewedTestPassCount: 105,
            allReviewedTestFailureCount: 1,
            allReviewedTestSkipCount: 0,
            exactFailureSummaryOccurrenceCount: 3,
            testDurationMilliseconds: 2_205,
            outerSummaryDurationMilliseconds: 2_208,
            exactThrownError: "contractDrift(\"source-step exact bytes\")",
            exactThrownErrorOccurrenceCount: 1,
            combinedGuardConjuncts: [
                "uninterruptedSourceStep == sourceSnapshotSourceStep",
                "uninterruptedSourceStep.result.globalStep == 1",
                "uninterruptedSourceStep.result.selectedTargetCount == 6",
            ],
            combinedGuardFailed: true,
            failedConjunctIdentified: false,
            sourceStepEqualityEstablished: false,
            sourceStepEqualityDisproved: false,
            globalStepOneEstablished: false,
            globalStepOneDisproved: false,
            selectedTargetCountSixEstablished: false,
            selectedTargetCountSixDisproved: false,
            failingTrialOrdinalEstablished: false,
            failingTrialOrdinalMinimum: 1,
            failingTrialOrdinalMaximum: 3,
            priorCompletedTrialCountEstablished: false,
            priorCompletedTrialCountMinimum: 0,
            priorCompletedTrialCountMaximum: 2,
            globalCompletedBranchCountEstablished: false,
            freshSourceObjectsGuardPassedInFailingTrial: true,
            bothFirstStepCallsReturnedInFailingTrial: true,
            tinyStage5TrainingExecutionObserved: true,
            failingTrialEvaluationReached: false,
            failingTrialSnapshotReached: false,
            receiptPostflightAfterLoopReached: false,
            stage5ReceiptAnchoredCount: 0,
            stage5ReceiptTotalOccurrenceCount: 0,
            stage5ReceiptConstructed: false,
            stage5ReceiptEmitted: false,
            stage5DeterminismEstablished: false,
            launcherExitCode: 2,
            launcherFailureLine:
                "swift-driver version: 1.148.6 prime-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism: Stage-5 direct XCTest or log capture failed",
            launcherFailureLineOccurrenceCount: 1,
            workflowProcessExitCode: 2,
            workflowExitMessage: "Process completed with exit code 2.",
            workflowExitAnnotationOccurrenceCount: 1),
        leaseBoundary: .init(
            environmentKey: "PRIME_NATIVE_DECODER_STAGE5_METAL_LEASE_PATH",
            parentPath:
                "/Users/runner/work/_temp/prime-native-decoder-stage5-metal-lease",
            path:
                "/Users/runner/work/_temp/prime-native-decoder-stage5-metal-lease/device-0.lock",
            acquiredBeforeCoreGraphicsMetalOrMLXAccessSourceInferred: true,
            heldAtFailedGuardSourceInferred: true,
            acquisitionFailureObserved: false,
            receiptEmittedWhileHeld: false,
            receiptFlushedWhileHeld: false,
            explicitReleaseImmediatelyAfterReceiptReached: false,
            deinitCallsReleaseInFrozenSource: true,
            deinitReleaseObservedInTerminalLog: false,
            processTerminationReleasesKernelFlock: true,
            launcherPostSuccessLeaseFileCleanupReached: false,
            leaseFileDeletionObserved: false,
            leaseParentDeletionObserved: false,
            leaseHeldAfterXCTestProcessExit: false),
        artifactBoundary: .init(
            actionsArtifactsTotalCount: 0,
            actionsArtifactsArrayExactlyEmpty: true,
            artifactUploadStepCount: 0,
            stage5ReceiptArtifactCreated: false,
            stage5ReceiptArtifactUploaded: false,
            stage5ReceiptRetainedInRepository: false,
            durableJobLogPublicationEstablished: false),
        retirementBoundary: .init(
            retirementRequired: true,
            retirementObserved: false,
            exactChangedPathCount: 5,
            exactOrderedChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationTests.swift",
            ],
            expectedRootTestCount: 54,
            expectedIsolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
            expectedIsolatedCheckpointTestCount: 6,
            expectedFocusedWholeStepTestCount: 60,
            expectedMetalTestCount: 44,
            expectedRuntimeTestCount: 1,
            expectedTokenizerTestCount: 1,
            expectedLiveExecutionOrder: [
                "metal", "maintained_runtime", "tokenizer",
            ],
            expectedTotalTestCount: 106,
            expectedDepthOneCheckoutCount: 2,
            expectedStage4LauncherInvocationCount: 0,
            expectedStage5LauncherInvocationCount: 0,
            expectedStage5ReceiptCount: 0,
            expectedStage6LauncherInvocationCount: 0,
            stage5LauncherMustRemainPreserved: true,
            stage5LauncherPath:
                ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh",
            stage5LauncherGitMode: "100755",
            stage5LauncherGitBlob: "6547ee06663c1ea409a6256e48f6111245056020",
            stage5LauncherByteCount: 48_869,
            stage5LauncherLFByteCount: 830,
            stage5LauncherSHA256:
                "c639cfcb4d1d0a103b285ed38849565f16b00932fc3b9d921febbf798c30d5f9",
            replacementLiveExecutionPermittedByRetirement: false),
        authorityCeiling: .init(
            oneShotExecutionConsumed: true,
            oneShotExecutionExhausted: true,
            failureObservationAuthorizesNothing: true,
            exactRetirementRequired: true,
            launcherPreservationRequired: true,
            mechanicsImplementationAuthorizedAfterGreenAuthorityClosure: false,
            oneExactMainExecutionOpportunityAuthorized: false,
            threeBoundedSameProcessAssayTrialsAuthorized: false,
            inMemorySourceSnapshotAuthorized: false,
            rerunAuthorized: false,
            retryAuthorized: false,
            replacementRunAuthorized: false,
            launcherMutationAuthorized: false,
            additionalExecutionOrRerunAuthorized: false,
            stage4RerunAuthorized: false,
            stage5ReceiptEstablished: false,
            stage5MechanicsExecuted: true,
            stage5ResultEstablished: false,
            stage5MechanicsSuccessEstablished: false,
            repeatedTrajectoryDeterminismEstablished: false,
            stage5AssayCheckpointResumeEstablished: false,
            stage5AssayDurableCheckpointIOObserved: false,
            durableCheckpointIOAuthorized: false,
            retainedCheckpointArtifactAuthorized: false,
            retainedArtifactAuthorized: false,
            checkpointArtifactUploadAuthorized: false,
            artifactUploadAuthorized: false,
            crossDeviceDeterminismEstablished: false,
            crossDeviceClaimAuthorized: false,
            exactMetalGradientBytesEstablished: false,
            metalDeterminismEstablished: false,
            trainingExecutionObserved: true,
            stage5AssayNative300MModelAllocationObserved: false,
            native300MAllocationAuthorized: false,
            native300MTrainingEstablished: false,
            native300MTrainingAuthorized: false,
            native300MTrainingObserved: false,
            generalTrainingEstablished: false,
            generalTrainingAuthorized: false,
            stage5AssayTrainingResumeEstablished: false,
            generalTrainingResumeEstablished: false,
            checkpointAdmissionGranted: false,
            modelQualityEstablished: false,
            candidateAdmissionGranted: false,
            downstreamTrialAuthorized: false,
            canaryAuthorized: false,
            quantizationAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            stage6AuthorityEstablished: false,
            stage6Authorized: false),
        orderedRequiredSeparateActions: [
            "retire_consumed_stage5_live_invocation_without_rerun",
            "preserve_stage5_launcher_bytes_for_audit",
            "retain_combined_guard_and_trial_ordinal_ambiguity",
            "require_separate_authority_for_any_replacement_execution",
            "keep_stage6_and_all_downstream_authority_false",
        ],
        status:
            "FAIL_exact_main_stage5_combined_source_step_guard_one_test_one_failure_no_receipt_no_explicit_cleanup_no_determinism_one_shot_consumed_no_retry_no_stage6")

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationError
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
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExactMainSwiftNumericsResolutionRepairAuthorityV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            guard predecessorAuthorityID == predecessor.authorityID,
                  predecessorAuthorityCanonicalSHA256
                    == PrimeSHA256.hexDigest(
                        of: try predecessor.canonicalData()) else {
                throw
                    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationError
                        .contractDrift
            }
        } catch {
            throw
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationError
                    .contractDrift
        }

        let repository = repositoryIdentity
        let run = runIdentity
        let pre = preStage5Boundary
        let failure = assayFailureBoundary
        let lease = leaseBoundary
        let artifacts = artifactBoundary
        let retirement = retirementBoundary
        let ceiling = authorityCeiling
        let falseClaims = [
            ceiling.mechanicsImplementationAuthorizedAfterGreenAuthorityClosure,
            ceiling.oneExactMainExecutionOpportunityAuthorized,
            ceiling.threeBoundedSameProcessAssayTrialsAuthorized,
            ceiling.inMemorySourceSnapshotAuthorized,
            ceiling.rerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.replacementRunAuthorized,
            ceiling.launcherMutationAuthorized,
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.stage4RerunAuthorized,
            ceiling.stage5ReceiptEstablished,
            ceiling.stage5ResultEstablished,
            ceiling.stage5MechanicsSuccessEstablished,
            ceiling.repeatedTrajectoryDeterminismEstablished,
            ceiling.stage5AssayCheckpointResumeEstablished,
            ceiling.stage5AssayDurableCheckpointIOObserved,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedCheckpointArtifactAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.checkpointArtifactUploadAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.crossDeviceDeterminismEstablished,
            ceiling.crossDeviceClaimAuthorized,
            ceiling.exactMetalGradientBytesEstablished,
            ceiling.metalDeterminismEstablished,
            ceiling.stage5AssayNative300MModelAllocationObserved,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingEstablished,
            ceiling.native300MTrainingAuthorized,
            ceiling.native300MTrainingObserved,
            ceiling.generalTrainingEstablished,
            ceiling.generalTrainingAuthorized,
            ceiling.stage5AssayTrainingResumeEstablished,
            ceiling.generalTrainingResumeEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage6AuthorityEstablished,
            ceiling.stage6Authorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              repository.orderedParentRevisions.count == 2,
              repository.orderedParentRevisions[0] == repository.baseRevision,
              repository.mergeTree == repository.reviewedHeadTree,
              repository.mergeRevision == run.headRevision,
              repository.changedPathCount == observedSourceBindings.count,
              repository.manifestOrLockChangedPathCount == 0,
              Set(observedSourceBindings.map(\.path)).count == 6,
              observedSourceBindings.allSatisfy(Self.validSource),
              run.runAttempt == 1,
              run.exactHeadPushRunCount == 1,
              run.rerunCount == 0,
              !run.rerunObserved,
              !run.rerunAuthorized,
              activeRootJob.orderedStepNames.count == 7,
              activeRootJob.orderedStepConclusions
                == Array(repeating: "success", count: 7),
              reviewedMainJob.orderedStepNames.count == 7,
              reviewedMainJob.orderedStepConclusions
                == [
                    "success", "success", "success", "success", "success",
                    "failure", "success",
                ],
              Self.validRawLog(activeRootRawLog),
              Self.validRawLog(reviewedMainRawLog),
              pre.securePrivateDependencyFetchInvocationCount == 1,
              pre.securePrivateDependencyFetchCompletionCount == 1,
              pre.authenticatedDepthOneFetchCount == 1,
              pre.submoduleUpdateCount == 1,
              pre.mlxCloneCount == 1,
              pre.mlxCCloneCount == 1,
              pre.workflowAuthoredFetchRetryCount == 0,
              pre.gitInternalFetchRetryCount == 0,
              pre.tlsVerificationFailureCount == 0,
              pre.tlsVerificationBypassCount == 0,
              pre.customCertificateAuthorityCount == 0,
              pre.swiftNumericsCacheMappingValidated,
              pre.swiftNumericsCacheMappingCount == 1,
              pre.swiftNumericsCacheFetchCompletionCount == 9,
              pre.swiftNumericsMappedIsolatedInvocationCount == 4,
              pre.metallibPublicSwiftNumericsFetchCount == 1,
              pre.metallibPublicSwiftNumericsCheckoutCount == 1,
              pre.metallibPublicSwiftNumericsResolutionSucceeded,
              pre.swiftNumericsResolvedRevision
                == repairClosureBoundary.exactSwiftNumericsRevision,
              pre.observedLiveExecutionOrder
                == ["metal", "maintained_runtime", "tokenizer"],
              pre.isolatedCheckpointGroupTestCounts == [1, 1, 2, 2],
              pre.isolatedCheckpointTestCount
                == pre.isolatedCheckpointGroupTestCounts.reduce(0, +),
              pre.focusedWholeStepTestCount
                == pre.focusedRootTestCount + pre.isolatedCheckpointTestCount,
              pre.preStage5TestCount
                == pre.focusedWholeStepTestCount + pre.metalTestCount
                    + pre.runtimeTestCount + pre.tokenizerTestCount,
              pre.predecessorStage3TypedInMemoryResumeRemainsEstablished,
              pre.predecessorStage4DurableRoundTripRemainsEstablished,
              pre.stage6LauncherInvocationCount == 0,
              failure.stage5LauncherInvocationCount == 1,
              failure.stage5BuildInvocationCount == 1,
              failure.stage5BuildCompletionCount == 1,
              failure.stage5BuildDurationMilliseconds == 179_580,
              failure.stage5DirectXCTestInvocationCount == 1,
              failure.testStartCount == 1,
              failure.testPassCount == 0,
              failure.testFailureCount == 1,
              failure.testSkipCount == 0,
              failure.allReviewedTestStartCount
                == pre.preStage5TestCount + failure.testStartCount,
              failure.allReviewedTestPassCount == pre.preStage5TestCount,
              failure.allReviewedTestFailureCount == 1,
              failure.allReviewedTestSkipCount == 0,
              failure.exactThrownErrorOccurrenceCount == 1,
              failure.combinedGuardConjuncts.count == 3,
              failure.combinedGuardFailed,
              !failure.failedConjunctIdentified,
              !failure.sourceStepEqualityEstablished,
              !failure.sourceStepEqualityDisproved,
              !failure.globalStepOneEstablished,
              !failure.globalStepOneDisproved,
              !failure.selectedTargetCountSixEstablished,
              !failure.selectedTargetCountSixDisproved,
              !failure.failingTrialOrdinalEstablished,
              failure.failingTrialOrdinalMinimum == 1,
              failure.failingTrialOrdinalMaximum == 3,
              !failure.priorCompletedTrialCountEstablished,
              failure.priorCompletedTrialCountMinimum == 0,
              failure.priorCompletedTrialCountMaximum == 2,
              !failure.globalCompletedBranchCountEstablished,
              failure.freshSourceObjectsGuardPassedInFailingTrial,
              failure.bothFirstStepCallsReturnedInFailingTrial,
              failure.tinyStage5TrainingExecutionObserved,
              !failure.failingTrialEvaluationReached,
              !failure.failingTrialSnapshotReached,
              !failure.receiptPostflightAfterLoopReached,
              failure.stage5ReceiptAnchoredCount == 0,
              failure.stage5ReceiptTotalOccurrenceCount == 0,
              !failure.stage5ReceiptConstructed,
              !failure.stage5ReceiptEmitted,
              !failure.stage5DeterminismEstablished,
              failure.launcherFailureLineOccurrenceCount == 1,
              failure.workflowExitAnnotationOccurrenceCount == 1,
              lease.acquiredBeforeCoreGraphicsMetalOrMLXAccessSourceInferred,
              lease.heldAtFailedGuardSourceInferred,
              !lease.acquisitionFailureObserved,
              !lease.receiptEmittedWhileHeld,
              !lease.receiptFlushedWhileHeld,
              !lease.explicitReleaseImmediatelyAfterReceiptReached,
              lease.deinitCallsReleaseInFrozenSource,
              !lease.deinitReleaseObservedInTerminalLog,
              lease.processTerminationReleasesKernelFlock,
              !lease.launcherPostSuccessLeaseFileCleanupReached,
              !lease.leaseFileDeletionObserved,
              !lease.leaseParentDeletionObserved,
              !lease.leaseHeldAfterXCTestProcessExit,
              artifacts.actionsArtifactsTotalCount == 0,
              artifacts.actionsArtifactsArrayExactlyEmpty,
              artifacts.artifactUploadStepCount == 0,
              !artifacts.stage5ReceiptArtifactCreated,
              !artifacts.stage5ReceiptArtifactUploaded,
              !artifacts.stage5ReceiptRetainedInRepository,
              !artifacts.durableJobLogPublicationEstablished,
              retirement.retirementRequired,
              !retirement.retirementObserved,
              retirement.exactChangedPathCount
                == retirement.exactOrderedChangedPaths.count,
              Set(retirement.exactOrderedChangedPaths).count == 5,
              retirement.expectedIsolatedCheckpointGroupTestCounts
                == [1, 1, 2, 2],
              retirement.expectedFocusedWholeStepTestCount
                == retirement.expectedRootTestCount
                    + retirement.expectedIsolatedCheckpointTestCount,
              retirement.expectedLiveExecutionOrder
                == pre.observedLiveExecutionOrder,
              retirement.expectedTotalTestCount
                == retirement.expectedFocusedWholeStepTestCount
                    + retirement.expectedMetalTestCount
                    + retirement.expectedRuntimeTestCount
                    + retirement.expectedTokenizerTestCount,
              retirement.expectedDepthOneCheckoutCount == 2,
              retirement.expectedStage4LauncherInvocationCount == 0,
              retirement.expectedStage5LauncherInvocationCount == 0,
              retirement.expectedStage5ReceiptCount == 0,
              retirement.expectedStage6LauncherInvocationCount == 0,
              retirement.stage5LauncherMustRemainPreserved,
              !retirement.replacementLiveExecutionPermittedByRetirement,
              ceiling.oneShotExecutionConsumed,
              ceiling.oneShotExecutionExhausted,
              ceiling.failureObservationAuthorizesNothing,
              ceiling.exactRetirementRequired,
              ceiling.launcherPreservationRequired,
              ceiling.stage5MechanicsExecuted,
              ceiling.trainingExecutionObserved,
              falseClaims.allSatisfy({ !$0 }) else {
            throw
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayExecutionFailureObservationError
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
        _ runnerName: String,
        _ runnerLabel: String,
        _ stepNames: [String],
        _ stepConclusions: [String],
        _ annotationCount: Int,
        _ annotationPath: String,
        _ annotationLine: Int,
        _ annotationMessage: String,
        _ url: String
    ) -> JobIdentity {
        .init(
            id: id,
            name: name,
            status: "completed",
            conclusion: conclusion,
            startedAt: startedAt,
            completedAt: completedAt,
            runnerID: runnerID,
            runnerName: runnerName,
            runnerGroupName: "GitHub Actions",
            runnerLabel: runnerLabel,
            orderedStepNames: stepNames,
            orderedStepConclusions: stepConclusions,
            checkAnnotationCount: annotationCount,
            checkAnnotationPath: annotationPath,
            checkAnnotationLine: annotationLine,
            checkAnnotationMessage: annotationMessage,
            jobURL: url)
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
