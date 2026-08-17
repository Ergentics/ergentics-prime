// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationError:
    Error,
    Equatable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

public struct PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public struct FileIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct RepositoryIdentity: Codable, Equatable, Sendable {
        public let repository: String
        public let pullRequestNumber: Int
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let reviewedHeadRevision: String
        public let reviewedHeadTree: String
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let historyPreservingTwoParentMergeObserved: Bool
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
    }

    public struct PullRequestClosure: Codable, Equatable, Sendable {
        public let headRevision: String
        public let headTree: String
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let activeRootJobID: Int
        public let activeRootJobConclusion: String
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let reviewedMainJobStepCount: Int
        public let matchingPullRequestRunCountForHead: Int
        public let actionsArtifactCount: Int
        public let consumedAuthorizedExactMainCompletion: Bool
    }

    public struct WorkflowRun: Codable, Equatable, Sendable {
        public let workflowName: String
        public let runID: Int
        public let runNumber: Int
        public let runAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let ref: String
        public let headSHA: String
        public let status: String
        public let conclusion: String
        public let createdAt: String
        public let startedAt: String
        public let updatedAt: String
        public let previousAttemptURL: String?
        public let matchingPushRunCountForHead: Int
        public let retryCount: Int
        public let rerunCount: Int
    }

    public struct Step: Codable, Equatable, Sendable {
        public let number: Int
        public let name: String
        public let status: String
        public let conclusion: String
        public let startedAt: String
        public let completedAt: String
    }

    public struct Job: Codable, Equatable, Sendable {
        public let jobID: Int
        public let name: String
        public let runnerLabel: String
        public let status: String
        public let conclusion: String
        public let startedAt: String
        public let completedAt: String
        public let steps: [Step]
    }

    public struct ConnectorDecodedUTF8JobLogIdentity:
        Codable,
        Equatable,
        Sendable
    {
        public let jobID: Int
        public let bindingKind: String
        public let representation: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let crByteCount: Int
        public let sha256: String
        public let utf8BOMPresent: Bool
        public let terminalLFPresent: Bool
        public let repeatFetchExactlyEqual: Bool
        public let rawArchiveBytesBound: Bool
        public let rawArchiveRetained: Bool
        public let firstTimestamp: String
        public let lastTimestamp: String
    }

    public struct TimeoutEvidence: Codable, Equatable, Sendable {
        public let configuredReviewedMainTimeoutMinutes: Int
        public let proposedReviewedMainTimeoutMinutes: Int
        public let reviewedJobAPIDurationSeconds: Int
        public let configuredTimeoutBoundaryReached: Bool
        public let maximumExecutionTimeAnnotation: String
        public let maximumExecutionTimeAnnotationCount: Int
        public let cancellationAnnotation: String
        public let cancellationAnnotationCount: Int
        public let exactCancellationLogLine: String
        public let exactCancellationLogLineCount: Int
        public let classificationBasis: [String]
        public let timeoutIncompleteNotSemanticFailure: Bool
        public let partialSuccessDoesNotCompleteReviewedMain: Bool
        public let observedRunMayNotBeRerunOrRetried: Bool
    }

    public struct FocusedObservation: Codable, Equatable, Sendable {
        public let startedAt: String
        public let completedAt: String
        public let durationSeconds: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let allFiveCommandsCompleted: Bool
        public let neutralAuthorityTestClassName: String
        public let neutralAuthorityTestMethodName: String
        public let neutralAuthorityTestStartCount: Int
        public let neutralAuthorityTestPassCount: Int
        public let neutralAuthorityTestFailureCount: Int
        public let neutralAuthorityTestSkipCount: Int
        public let neutralAuthorityTestDurationMilliseconds: Int
    }

    public struct RetainedCommandObservation: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let command: String
        public let classification: String
        public let testCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let receiptCount: Int
        public let okMarkerCount: Int
        public let completed: Bool
        public let cancelled: Bool
        public let runtimeCapabilityReached: Bool
    }

    public struct RetainedLiveObservation: Codable, Equatable, Sendable {
        public let stepStartedAt: String
        public let stepCompletedAt: String
        public let stepDurationSeconds: Int
        public let commandOrder: [String]
        public let metal: RetainedCommandObservation
        public let maintainedRuntime: RetainedCommandObservation
        public let tokenizer: RetainedCommandObservation
        public let tokenizerLastCompileProgress: String
        public let tokenizerTestProcessStarted: Bool
        public let tokenizerNative300MAllocationObserved: Bool
        public let completedLiveTestCount: Int
        public let expectedCompleteLiveTestCount: Int
        public let completedAggregateTestCount: Int
        public let expectedCompleteAggregateTestCount: Int
        public let retainedBaselineChanged: Bool
        public let retainedPartialSuccessPreservedAsObservation: Bool
    }

    public struct AbsenceEvidence: Codable, Equatable, Sendable {
        public let actionsAPIArtifactCount: Int
        public let workflowOperationalSurfaceCorpus: String
        public let workflowArtifactUploadActionNeedle: String
        public let workflowArtifactUploadActionReferenceCount: Int
        public let workflowExactClosedCanaryLauncherPath: String
        public let workflowExactClosedCanaryLauncherPathReferenceCount: Int
        public let workflowExecutableClosedCanaryLauncherCommandNeedle: String
        public let workflowExecutableClosedCanaryLauncherCommandCount: Int
        public let workflowExecutableSecureChildAdapterProductBuildCommandNeedle:
            String
        public let workflowExecutableSecureChildAdapterProductBuildCommandCount: Int
        public let workflowExecutableFixtureChildProductBuildCommandNeedle: String
        public let workflowExecutableFixtureChildProductBuildCommandCount: Int
        public let patchImplementationSourceAddedCount: Int
        public let patchImplementationTestAddedCount: Int
        public let observationSourceRuntimeCapabilityCount: Int
    }

    public struct PathContract: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let role: String
    }

    public struct RepairAuthority: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let workflowSoleTestExecutionBudgetChange: String
        public let workflowSoleTestExecutionBudgetChangeOccurrenceCount: Int
        public let activeRootTimeoutMinutes: Int
        public let reviewedMainTimeoutBeforeMinutes: Int
        public let reviewedMainTimeoutAfterMinutes: Int
        public let reviewedMainTimeoutDeltaMinutes: Int
        public let activeRootPrimeFetchDepth: Int
        public let reviewedMainPrimeFetchDepth: Int
        public let reviewedMainMLXFetchDepth: Int
        public let workflowJobCount: Int
        public let reviewedMainNeedsActiveRoot: Bool
        public let workflowJobAndStepOrderMustRemainUnchanged: Bool
        public let retainedLiveCommandSequenceMustRemainByteIdentical: Bool
        public let workflowJobTopologyMustRemainUnchanged: Bool
        public let historicalAuthorityBaseObjectID: String
        public let activeRootExistingFetchAddsOnlyHistoricalAuthorityBaseObject: Bool
        public let reviewedMainExistingFetchAddsOnlyHistoricalAuthorityBaseObject: Bool
        public let addedImmutableProofWantCountPerExistingFetch: Int
        public let exactPrimeFetchInvocationCountPerCheckoutStepRemainsOne: Bool
        public let additionalFetchStepCount: Int
        public let additionalPrimeFetchInvocationCountPerCheckoutStep: Int
        public let additionalMutableRefCount: Int
        public let historicalAuthorityBaseObjectIsExistingFetchInput: Bool
        public let historicalAuthorityBaseObjectIsDetachedWorktreeCheckoutTarget: Bool
        public let historicalAuthorityBaseObjectIsTestOrLiveExecutionInput: Bool
        public let lineageHydrationAddsMechanics: Bool
        public let existingRetainedLiveScriptsMustRemainByteIdentical: Bool
        public let originalAuthorityPairMustRemainByteIdentical: Bool
        public let readmeMustRemainByteIdentical: Bool
        public let packageManifestMustRemainByteIdentical: Bool
        public let packageLockMustRemainByteIdentical: Bool
        public let canaryLauncherMustRemainByteIdentical: Bool
        public let oneDistinctDirectSuccessorCompletionAuthorized: Bool
        public let directSuccessorAuthorizedOnlyAfterExactFiveClosure: Bool
        public let directSuccessorEvent: String
        public let directSuccessorRef: String
        public let directSuccessorRequiredRunAttempt: Int
        public let directSuccessorMaximumAuthorizedRunCount: Int
        public let pullRequestValidationConsumesDirectSuccessor: Bool
        public let observedRunRerunAuthorized: Bool
        public let observedRunRetryAuthorized: Bool
        public let additionalSuccessorAttemptAuthorized: Bool
        public let replacementExecutionCommandAuthorized: Bool
        public let implementationIncluded: Bool
        public let implementationAuthorizedByThisObservation: Bool
        public let downstreamAuthorityGranted: Bool
    }

    public struct ExpectedClosure: Codable, Equatable, Sendable {
        public let activeLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let embeddedProvenanceRecordCount: Int
        public let timeoutMinutes: Int
        public let neutralTimeoutObservationTestCount: Int
        public let newMechanicsInvocationCount: Int
        public let actionsArtifactCount: Int
        public let requiredRunAttempt: Int
        public let requiredPreviousAttemptURLIsNull: Bool
        public let uniquePushRunRequired: Bool
        public let implementationMayOnlyBeSeparatelyReviewedAfterGreen: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let timeoutObservationEstablished: Bool
        public let boundedTimeoutRepairAuthorized: Bool
        public let oneDistinctDirectSuccessorCompletionAuthorized: Bool
        public let semanticFailureEstablished: Bool
        public let originalAuthorityInvalidated: Bool
        public let originalAuthorityExactMainGreenEstablished: Bool
        public let neutralLeaseImplementationPerformed: Bool
        public let leaseAcquisitionAuthorized: Bool
        public let leaseReleaseAuthorized: Bool
        public let leaseReacquisitionAuthorized: Bool
        public let descriptorInspectionAuthorized: Bool
        public let descriptorTransferAuthorized: Bool
        public let processExecutionAuthorized: Bool
        public let fixtureExecutionAuthorized: Bool
        public let adapterExecutionAuthorized: Bool
        public let canaryExecutionAuthorized: Bool
        public let canaryRetryAuthorized: Bool
        public let canaryRerunAuthorized: Bool
        public let filesystemWriteAuthorized: Bool
        public let networkAuthorized: Bool
        public let layerAMutationAuthorized: Bool
        public let secureChildCompositionAuthorized: Bool
        public let durableTransactionLayerBAuthorized: Bool
        public let durableEvidenceEstablished: Bool
        public let physicalMetalReservationEstablished: Bool
        public let mlxExecutionAuthorized: Bool
        public let metalExecutionAuthorized: Bool
        public let native300MExecutionAuthorized: Bool
        public let pythonAuthorized: Bool
        public let cppAuthorized: Bool
        public let checkpointAdmissionGranted: Bool
        public let generalTrainingResumeAuthorized: Bool
        public let modelQualityEstablished: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let observationID: String
    public let observationKind: String
    public let classification: String
    public let originalAuthorityID: String
    public let originalAuthorityStatus: String
    public let originalAuthorityCanonicalByteCount: Int
    public let originalAuthorityCanonicalSHA256: String
    public let originalAuthorityRemainsFrozen: Bool
    public let originalAuthorityExactMainGreen: Bool
    public let originalAuthoritySemanticContractInvalidated: Bool
    public let frozenFiles: [FileIdentity]
    public let repositoryIdentity: RepositoryIdentity
    public let pullRequestClosure: PullRequestClosure
    public let workflowRun: WorkflowRun
    public let activeRootJob: Job
    public let activeRootConnectorDecodedJobLog: ConnectorDecodedUTF8JobLogIdentity
    public let activeRootLatinTestCount: Int
    public let activeRootLatinFailureCount: Int
    public let activeRootLatinSkipCount: Int
    public let reviewedMainJob: Job
    public let reviewedMainConnectorDecodedJobLog:
        ConnectorDecodedUTF8JobLogIdentity
    public let timeoutEvidence: TimeoutEvidence
    public let focusedObservation: FocusedObservation
    public let retainedLiveObservation: RetainedLiveObservation
    public let absenceEvidence: AbsenceEvidence
    public let repairAuthority: RepairAuthority
    public let expectedRepairClosure: ExpectedClosure
    public let authorityCeiling: AuthorityCeiling
    public let status: String
    public let orderedNextActions: [String]

    public static let canonicalByteCount = 18_232
    public static let canonicalSHA256 =
        "366c46a3531b292451bbd5ebecc1110ae5f0b78f29b23e49f7df03d59ae64baf"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_neutral_resource_lease_generalization_authority_reviewed_main_timeout_observation_v1",
        observationID:
            "ergentics_prime_neutral_resource_lease_generalization_authority_reviewed_main_timeout_run148_v1",
        observationKind:
            "append_only_reviewed_main_timeout_observation_and_bounded_repair_authority",
        classification: "timeout_incomplete_not_semantic_failure",
        originalAuthorityID:
            "ergentics_prime_neutral_resource_lease_generalization_authority_v1",
        originalAuthorityStatus:
            "AUTHORITY_ONLY_neutral_resource_lease_alias_and_typed_retention_exact5_no_implementation_no_mechanics_legacy_b_mlx_layer_a_preserved",
        originalAuthorityCanonicalByteCount: 27_174,
        originalAuthorityCanonicalSHA256:
            "ae5b5a73861bbd1584510f0adf358eee32ddb478878597272dc8b0a67c0142cb",
        originalAuthorityRemainsFrozen: true,
        originalAuthorityExactMainGreen: false,
        originalAuthoritySemanticContractInvalidated: false,
        frozenFiles: [
            .init(
                path:
                    "Sources/PrimeCore/PrimeNeutralResourceLeaseGeneralizationAuthority.swift",
                gitMode: "100644",
                gitBlob: "2d1a91b1d428b3d47698ed16e57392a0aba8695a",
                byteCount: 71_435,
                lfByteCount: 1_367,
                sha256:
                    "ea0353cfed507cc50889ab3555105ebacb3cd4cef1486294b5b8ae51254a53b1",
                role: "original_neutral_resource_lease_generalization_authority"
            ),
            .init(
                path:
                    "Tests/PrimeCoreTests/PrimeNeutralResourceLeaseGeneralizationAuthorityTests.swift",
                gitMode: "100644",
                gitBlob: "eb35192c9fd4eac162195f73788b73df71d31e8a",
                byteCount: 52_630,
                lfByteCount: 1_205,
                sha256:
                    "0f074a097f3fdaa9917ede0fe8acb4819231f6d765030199710e8a7d0cefcf7a",
                role: "original_neutral_resource_lease_generalization_authority_test"
            ),
            .init(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "90df96e4909d01ac073eff79bfb1321323419f81",
                byteCount: 1_230_079,
                lfByteCount: 20_419,
                sha256:
                    "e0eee1a0b224a7f67650dc3276f66d2e4ac498a3d4133441a3e228afa140a968",
                role: "observed_run148_active_root_gate"
            ),
            .init(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "b5b3dee162db46a1456756bef185dcf40849a79e",
                byteCount: 146_013,
                lfByteCount: 694,
                sha256:
                    "b4e20c181e8ca4f6d002f8a521025d89750c053510745bcf2ec3773b0fa43d78",
                role: "observed_run148_workflow_with_60_minute_reviewed_main_timeout"
            ),
            .init(
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitMode: "100644",
                gitBlob: "fd966bf2f11acebe1e4ab0a4df2e7aad1a2db28e",
                byteCount: 546,
                lfByteCount: 13,
                sha256:
                    "272332346a40372e5a4bd8c466bbab4e6c65a67be58a6e352c2a9f233cd6230b",
                role: "observed_run148_embedded_provenance_511_records"
            ),
        ],
        repositoryIdentity: .init(
            repository: "Ergentics/ergentics-prime",
            pullRequestNumber: 124,
            mergeRevision: "0abcb4ad5487a775627bbb587184c375dd691978",
            mergeTree: "94e16511f39fc79b2854423bc82b763974a9cc46",
            orderedParentRevisions: [
                "4570716892722873757de6eae1bd897167d674eb",
                "3258f3d8b8d79df7e2b152c4bdb9eac77223bb78",
            ],
            reviewedHeadRevision:
                "3258f3d8b8d79df7e2b152c4bdb9eac77223bb78",
            reviewedHeadTree: "94e16511f39fc79b2854423bc82b763974a9cc46",
            mergeTreeEqualsReviewedHeadTree: true,
            historyPreservingTwoParentMergeObserved: true,
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-17T03:15:14Z"
        ),
        pullRequestClosure: .init(
            headRevision: "3258f3d8b8d79df7e2b152c4bdb9eac77223bb78",
            headTree: "94e16511f39fc79b2854423bc82b763974a9cc46",
            workflowRunID: 31_989_606_001,
            workflowRunNumber: 147,
            workflowRunAttempt: 1,
            activeRootJobID: 95_270_648_656,
            activeRootJobConclusion: "success",
            reviewedMainJobID: 95_271_322_489,
            reviewedMainJobConclusion: "skipped",
            reviewedMainJobStepCount: 0,
            matchingPullRequestRunCountForHead: 1,
            actionsArtifactCount: 0,
            consumedAuthorizedExactMainCompletion: false
        ),
        workflowRun: .init(
            workflowName: "Prime active-root quarantine",
            runID: 31_990_567_513,
            runNumber: 148,
            runAttempt: 1,
            checkSuiteID: 86_731_396_865,
            event: "push",
            ref: "refs/heads/main",
            headSHA: "0abcb4ad5487a775627bbb587184c375dd691978",
            status: "completed",
            conclusion: "cancelled",
            createdAt: "2026-08-17T03:15:17Z",
            startedAt: "2026-08-17T03:15:17Z",
            updatedAt: "2026-08-17T04:20:28Z",
            previousAttemptURL: nil,
            matchingPushRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0
        ),
        activeRootJob: .init(
            jobID: 95_273_237_917,
            name: "First-party MLX / active-root quarantine",
            runnerLabel: "macos-15",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-17T03:15:20Z",
            completedAt: "2026-08-17T03:19:57Z",
            steps: [
                .init(number: 1, name: "Set up job", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:15:21Z", completedAt: "2026-08-17T03:15:21Z"),
                .init(number: 2, name: "Check out the exact Prime revision", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:15:21Z", completedAt: "2026-08-17T03:15:26Z"),
                .init(number: 3, name: "Validate active metadata and preserved history", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:15:26Z", completedAt: "2026-08-17T03:17:15Z"),
                .init(number: 4, name: "Parse the changed Swift contracts without dependencies", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:17:15Z", completedAt: "2026-08-17T03:17:31Z"),
                .init(number: 5, name: "Validate isolated Latin capture and observation contracts", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:17:31Z", completedAt: "2026-08-17T03:19:53Z"),
                .init(number: 6, name: "Record the authority ceiling", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:19:53Z", completedAt: "2026-08-17T03:19:53Z"),
                .init(number: 7, name: "Complete job", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:19:53Z", completedAt: "2026-08-17T03:19:55Z"),
            ]
        ),
        activeRootConnectorDecodedJobLog: .init(
            jobID: 95_273_237_917,
            bindingKind:
                "github_connector_decoded_utf8_job_log_aggregate_identity",
            representation:
                "github_connector_decoded_utf8_job_log_aggregate_not_raw_zip",
            byteCount: 327_304,
            lfByteCount: 1_886,
            crByteCount: 0,
            sha256:
                "518d82f2e9c687bcfca06bc1ae583904f99e5acbaaef9168dda528ce161e319b",
            utf8BOMPresent: true,
            terminalLFPresent: true,
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false,
            firstTimestamp: "2026-08-17T03:15:21.1771230Z",
            lastTimestamp: "2026-08-17T03:19:53.3499490Z"
        ),
        activeRootLatinTestCount: 116,
        activeRootLatinFailureCount: 0,
        activeRootLatinSkipCount: 0,
        reviewedMainJob: .init(
            jobID: 95_273_924_450,
            name: "Reviewed main / focused source contracts",
            runnerLabel: "macos-26",
            status: "completed",
            conclusion: "cancelled",
            startedAt: "2026-08-17T03:20:00Z",
            completedAt: "2026-08-17T04:20:27Z",
            steps: [
                .init(number: 1, name: "Set up job", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:20:01Z", completedAt: "2026-08-17T03:20:01Z"),
                .init(number: 2, name: "Record the hosted Apple toolchain", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:20:01Z", completedAt: "2026-08-17T03:20:06Z"),
                .init(number: 3, name: "Check out reviewed main exactly", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:20:06Z", completedAt: "2026-08-17T03:20:10Z"),
                .init(number: 4, name: "Fetch the exact private dependency without evaluating Prime", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:20:10Z", completedAt: "2026-08-17T03:20:20Z"),
                .init(number: 5, name: "Compile and run the focused contracts without a credential", status: "completed", conclusion: "success", startedAt: "2026-08-17T03:20:20Z", completedAt: "2026-08-17T03:53:28Z"),
                .init(number: 6, name: "Run the Prime-owned decoder on live Metal", status: "completed", conclusion: "cancelled", startedAt: "2026-08-17T03:53:28Z", completedAt: "2026-08-17T04:20:13Z"),
                .init(number: 7, name: "Complete job", status: "completed", conclusion: "success", startedAt: "2026-08-17T04:20:13Z", completedAt: "2026-08-17T04:20:16Z"),
            ]
        ),
        reviewedMainConnectorDecodedJobLog: .init(
            jobID: 95_273_924_450,
            bindingKind:
                "github_connector_decoded_utf8_job_log_aggregate_identity",
            representation:
                "github_connector_decoded_utf8_job_log_aggregate_not_raw_zip",
            byteCount: 10_316_082,
            lfByteCount: 78_941,
            crByteCount: 0,
            sha256:
                "125d6f45ce2ca3ad688a66795ab85e8dbb5e79ed661ed921c7fae7a3cdd324fd",
            utf8BOMPresent: true,
            terminalLFPresent: true,
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false,
            firstTimestamp: "2026-08-17T03:20:01.8671540Z",
            lastTimestamp: "2026-08-17T04:20:14.0529700Z"
        ),
        timeoutEvidence: .init(
            configuredReviewedMainTimeoutMinutes: 60,
            proposedReviewedMainTimeoutMinutes: 75,
            reviewedJobAPIDurationSeconds: 3_627,
            configuredTimeoutBoundaryReached: true,
            maximumExecutionTimeAnnotation:
                "The job has exceeded the maximum execution time of 1h0m0s",
            maximumExecutionTimeAnnotationCount: 1,
            cancellationAnnotation: "The operation was canceled.",
            cancellationAnnotationCount: 1,
            exactCancellationLogLine:
                "2026-08-17T04:20:13.8459900Z ##[error]The operation was canceled.",
            exactCancellationLogLineCount: 1,
            classificationBasis: [
                "workflow_reviewed_main_timeout_minutes_60",
                "reviewed_main_job_api_duration_3627_seconds",
                "github_maximum_execution_time_annotation_1h0m0s",
                "github_job_conclusion_cancelled",
                "sole_runtime_error_operation_was_canceled",
                "tokenizer_build_was_progressing_at_197_of_199_without_test_failure",
            ],
            timeoutIncompleteNotSemanticFailure: true,
            partialSuccessDoesNotCompleteReviewedMain: true,
            observedRunMayNotBeRerunOrRetried: true
        ),
        focusedObservation: .init(
            startedAt: "2026-08-17T03:20:20Z",
            completedAt: "2026-08-17T03:53:28Z",
            durationSeconds: 1_988,
            rootTestCount: 80,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 86,
            failureCount: 0,
            skipCount: 0,
            allFiveCommandsCompleted: true,
            neutralAuthorityTestClassName:
                "PrimeNeutralResourceLeaseGeneralizationAuthorityTests",
            neutralAuthorityTestMethodName:
                "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
            neutralAuthorityTestStartCount: 1,
            neutralAuthorityTestPassCount: 1,
            neutralAuthorityTestFailureCount: 0,
            neutralAuthorityTestSkipCount: 0,
            neutralAuthorityTestDurationMilliseconds: 2_397
        ),
        retainedLiveObservation: .init(
            stepStartedAt: "2026-08-17T03:53:28Z",
            stepCompletedAt: "2026-08-17T04:20:13Z",
            stepDurationSeconds: 1_605,
            commandOrder: [
                "bash .github/scripts/prime-ci-native-decoder-metal.sh",
                "bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh",
                "bash .github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
            ],
            metal: .init(
                ordinal: 1,
                command: "bash .github/scripts/prime-ci-native-decoder-metal.sh",
                classification: "completed_success_retained_baseline",
                testCount: 44,
                failureCount: 0,
                skipCount: 0,
                receiptCount: 0,
                okMarkerCount: 1,
                completed: true,
                cancelled: false,
                runtimeCapabilityReached: true
            ),
            maintainedRuntime: .init(
                ordinal: 2,
                command:
                    "bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh",
                classification: "completed_success_retained_baseline",
                testCount: 1,
                failureCount: 0,
                skipCount: 0,
                receiptCount: 1,
                okMarkerCount: 1,
                completed: true,
                cancelled: false,
                runtimeCapabilityReached: true
            ),
            tokenizer: .init(
                ordinal: 3,
                command:
                    "bash .github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
                classification:
                    "cancelled_at_job_timeout_during_build_before_test_or_runtime",
                testCount: 0,
                failureCount: 0,
                skipCount: 0,
                receiptCount: 0,
                okMarkerCount: 0,
                completed: false,
                cancelled: true,
                runtimeCapabilityReached: false
            ),
            tokenizerLastCompileProgress:
                "[197/199] Compiling PrimeNativeDecoder PrimeNativeGQADecoder.swift",
            tokenizerTestProcessStarted: false,
            tokenizerNative300MAllocationObserved: false,
            completedLiveTestCount: 45,
            expectedCompleteLiveTestCount: 46,
            completedAggregateTestCount: 131,
            expectedCompleteAggregateTestCount: 132,
            retainedBaselineChanged: false,
            retainedPartialSuccessPreservedAsObservation: true
        ),
        absenceEvidence: .init(
            actionsAPIArtifactCount: 0,
            workflowOperationalSurfaceCorpus:
                "parsed_workflow_executable_run_script_and_uses_nodes_excluding_echo_payload_text",
            workflowArtifactUploadActionNeedle:
                "uses: actions/upload-artifact@",
            workflowArtifactUploadActionReferenceCount: 0,
            workflowExactClosedCanaryLauncherPath:
                ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
            workflowExactClosedCanaryLauncherPathReferenceCount: 0,
            workflowExecutableClosedCanaryLauncherCommandNeedle:
                "run: bash .github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
            workflowExecutableClosedCanaryLauncherCommandCount: 0,
            workflowExecutableSecureChildAdapterProductBuildCommandNeedle:
                "swift build --product PrimeValidationWorkflowSecureChildIntegration",
            workflowExecutableSecureChildAdapterProductBuildCommandCount: 0,
            workflowExecutableFixtureChildProductBuildCommandNeedle:
                "swift build --product PrimeValidationWorkflowFixtureChild",
            workflowExecutableFixtureChildProductBuildCommandCount: 0,
            patchImplementationSourceAddedCount: 0,
            patchImplementationTestAddedCount: 0,
            observationSourceRuntimeCapabilityCount: 0
        ),
        repairAuthority: .init(
            exactOrderedPaths: [
                .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitStatus: "M", gitMode: "100755", role: "bind_run148_and_timeout_repair_exact_topology"),
                .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitStatus: "M", gitMode: "100644", role: "raise_only_reviewed_main_timeout_and_integrate_pure_test"),
                .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitStatus: "M", gitMode: "100644", role: "bind_513_record_embedded_source_identity"),
                .init(ordinal: 4, path: "Sources/PrimeCore/PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservation.swift", gitStatus: "A", gitMode: "100644", role: "pure_timeout_observation_and_bounded_repair_authority"),
                .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationTests.swift", gitStatus: "A", gitMode: "100644", role: "sole_exhaustive_pure_timeout_observation_test"),
            ],
            exactPathCount: 5,
            workflowSoleTestExecutionBudgetChange:
                "trusted_main_compile_timeout_minutes_60_to_75",
            workflowSoleTestExecutionBudgetChangeOccurrenceCount: 1,
            activeRootTimeoutMinutes: 45,
            reviewedMainTimeoutBeforeMinutes: 60,
            reviewedMainTimeoutAfterMinutes: 75,
            reviewedMainTimeoutDeltaMinutes: 15,
            activeRootPrimeFetchDepth: 2,
            reviewedMainPrimeFetchDepth: 2,
            reviewedMainMLXFetchDepth: 1,
            workflowJobCount: 2,
            reviewedMainNeedsActiveRoot: true,
            workflowJobAndStepOrderMustRemainUnchanged: true,
            retainedLiveCommandSequenceMustRemainByteIdentical: true,
            workflowJobTopologyMustRemainUnchanged: true,
            historicalAuthorityBaseObjectID:
                "4570716892722873757de6eae1bd897167d674eb",
            activeRootExistingFetchAddsOnlyHistoricalAuthorityBaseObject: true,
            reviewedMainExistingFetchAddsOnlyHistoricalAuthorityBaseObject: true,
            addedImmutableProofWantCountPerExistingFetch: 1,
            exactPrimeFetchInvocationCountPerCheckoutStepRemainsOne: true,
            additionalFetchStepCount: 0,
            additionalPrimeFetchInvocationCountPerCheckoutStep: 0,
            additionalMutableRefCount: 0,
            historicalAuthorityBaseObjectIsExistingFetchInput: true,
            historicalAuthorityBaseObjectIsDetachedWorktreeCheckoutTarget: false,
            historicalAuthorityBaseObjectIsTestOrLiveExecutionInput: false,
            lineageHydrationAddsMechanics: false,
            existingRetainedLiveScriptsMustRemainByteIdentical: true,
            originalAuthorityPairMustRemainByteIdentical: true,
            readmeMustRemainByteIdentical: true,
            packageManifestMustRemainByteIdentical: true,
            packageLockMustRemainByteIdentical: true,
            canaryLauncherMustRemainByteIdentical: true,
            oneDistinctDirectSuccessorCompletionAuthorized: true,
            directSuccessorAuthorizedOnlyAfterExactFiveClosure: true,
            directSuccessorEvent: "push",
            directSuccessorRef: "refs/heads/main",
            directSuccessorRequiredRunAttempt: 1,
            directSuccessorMaximumAuthorizedRunCount: 1,
            pullRequestValidationConsumesDirectSuccessor: false,
            observedRunRerunAuthorized: false,
            observedRunRetryAuthorized: false,
            additionalSuccessorAttemptAuthorized: false,
            replacementExecutionCommandAuthorized: false,
            implementationIncluded: false,
            implementationAuthorizedByThisObservation: false,
            downstreamAuthorityGranted: false
        ),
        expectedRepairClosure: .init(
            activeLatinTestCount: 116,
            rootTestCount: 81,
            isolatedTestCount: 6,
            focusedWholeTestCount: 87,
            retainedLiveTestCount: 46,
            aggregateTestCount: 133,
            failureCount: 0,
            skipCount: 0,
            embeddedProvenanceRecordCount: 513,
            timeoutMinutes: 75,
            neutralTimeoutObservationTestCount: 1,
            newMechanicsInvocationCount: 0,
            actionsArtifactCount: 0,
            requiredRunAttempt: 1,
            requiredPreviousAttemptURLIsNull: true,
            uniquePushRunRequired: true,
            implementationMayOnlyBeSeparatelyReviewedAfterGreen: true
        ),
        authorityCeiling: .init(
            timeoutObservationEstablished: true,
            boundedTimeoutRepairAuthorized: true,
            oneDistinctDirectSuccessorCompletionAuthorized: true,
            semanticFailureEstablished: false,
            originalAuthorityInvalidated: false,
            originalAuthorityExactMainGreenEstablished: false,
            neutralLeaseImplementationPerformed: false,
            leaseAcquisitionAuthorized: false,
            leaseReleaseAuthorized: false,
            leaseReacquisitionAuthorized: false,
            descriptorInspectionAuthorized: false,
            descriptorTransferAuthorized: false,
            processExecutionAuthorized: false,
            fixtureExecutionAuthorized: false,
            adapterExecutionAuthorized: false,
            canaryExecutionAuthorized: false,
            canaryRetryAuthorized: false,
            canaryRerunAuthorized: false,
            filesystemWriteAuthorized: false,
            networkAuthorized: false,
            layerAMutationAuthorized: false,
            secureChildCompositionAuthorized: false,
            durableTransactionLayerBAuthorized: false,
            durableEvidenceEstablished: false,
            physicalMetalReservationEstablished: false,
            mlxExecutionAuthorized: false,
            metalExecutionAuthorized: false,
            native300MExecutionAuthorized: false,
            pythonAuthorized: false,
            cppAuthorized: false,
            checkpointAdmissionGranted: false,
            generalTrainingResumeAuthorized: false,
            modelQualityEstablished: false,
            productUseAuthorized: false,
            publicationAuthorized: false
        ),
        status:
            "OBSERVED_TIMEOUT_INCOMPLETE_REPAIR_AUTHORIZED_exact5_timeout_60_to_75_no_implementation_no_new_mechanics",
        orderedNextActions: [
            "merge_only_this_pure_exact5_timeout_observation_and_repair",
            "require_one_unique_attempt1_direct_successor_exact_main_completion_at_75_minutes",
            "do_not_rerun_retry_or_recover_run148",
            "require_root81_isolated6_focused87_live46_aggregate133_and_provenance513",
            "only_after_green_separately_review_the_neutral_alias_and_typed_retention_implementation",
            "do_not_collapse_monitor_composition_durability_or_adapter_work_into_this_repair",
        ]
    )

    public func canonicalData() throws -> Data {
        try validate()
        return try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 131_072 else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try PrimeCanonicalJSON.encode(value) == data else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationError
                .noncanonicalEncoding
        }
        return value
    }

    public func validate() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationError
                .contractDrift
        }
    }

    public func validateExactV1() throws {
        try validate()
        let canonical = try PrimeCanonicalJSON.encode(self)
        guard canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256
        else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityReviewedMainTimeoutObservationError
                .contractDrift
        }
    }
}
