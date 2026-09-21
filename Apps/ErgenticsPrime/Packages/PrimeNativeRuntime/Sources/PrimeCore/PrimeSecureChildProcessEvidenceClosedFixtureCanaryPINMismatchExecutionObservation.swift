// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

/// Frozen, append-only evidence for the sole exact-main closed-fixture canary
/// opportunity in workflow run 143.
///
/// The hosted launcher emitted one valid outer record with `PIN_MISMATCH`
/// before the adapter command was attempted. The record intentionally withheld
/// the observed fixture identity, so it does not establish whether the byte
/// count, SHA-256, or both differed from the frozen Layer-A acceptance pin.
/// The command-attempt one-shot remains unconsumed, while the broader mechanics
/// opportunity is retired without retry or rerun. This Foundation/Codable value
/// performs no filesystem, fixture, adapter, process, lease, network, MLX,
/// Metal, artifact, or durable-evidence operation.
public struct
    PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public struct AuthorityClosure: Codable, Equatable, Sendable {
        public let authorityID: String
        public let canonicalByteCount: Int
        public let canonicalSHA256: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let pullRequestNumber: Int
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let checkSuiteID: Int
        public let activeRootJobID: Int
        public let reviewedMainJobID: Int
        public let activeRootJobConclusion: String
        public let reviewedMainJobConclusion: String
        public let activeLatinTestCount: Int
        public let focusedRootTestCount: Int
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let reviewedFailureCount: Int
        public let reviewedSkipCount: Int
        public let workflowRerunCount: Int
        public let actionsArtifactCount: Int
        public let exactMainClosureEstablished: Bool
    }

    public struct MechanicsSourceIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let mechanicsGitStatus: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct RepositoryIdentity: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let pullRequestNumber: Int
        public let baseRevision: String
        public let baseTree: String
        public let reviewedHeadRevision: String
        public let reviewedHeadTree: String
        public let reviewedHeadOrderedParentRevisions: [String]
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let mergeCommitSignatureVerified: Bool
        public let mergeCommitSignatureReason: String
        public let historyPreservingTwoParentMergeObserved: Bool
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let exactMainRefMatchedAtTerminalAudit: Bool
        public let exactChangedPathCount: Int
        public let changedManifestPathCount: Int
        public let changedLockPathCount: Int
    }

    public struct PullRequestLane: Codable, Equatable, Sendable {
        public let workflowID: Int
        public let workflowName: String
        public let workflowPath: String
        public let runID: Int
        public let runNumber: Int
        public let runAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let headBranch: String
        public let headRevision: String
        public let status: String
        public let conclusion: String
        public let exactHeadRunCount: Int
        public let previousAttemptURLWasNull: Bool
        public let retryCount: Int
        public let rerunCount: Int
        public let artifactCount: Int
        public let activeRootJobID: Int
        public let activeRootJobConclusion: String
        public let activeLatinTestCount: Int
        public let activeLatinFailureCount: Int
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let reviewedMainJobStepCount: Int
        public let launcherInvocationCount: Int
        public let adapterCommandAttemptCount: Int
        public let hostedRecordCount: Int
        public let runURL: String
    }

    public struct ExactMainLane: Codable, Equatable, Sendable {
        public let workflowID: Int
        public let workflowName: String
        public let workflowPath: String
        public let runID: Int
        public let runNumber: Int
        public let runAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let headBranch: String
        public let headRevision: String
        public let status: String
        public let conclusion: String
        public let exactHeadRunCount: Int
        public let previousAttemptURLWasNull: Bool
        public let retryCount: Int
        public let rerunCount: Int
        public let artifactCount: Int
        public let activeRootJobID: Int
        public let activeRootJobConclusion: String
        public let activeLatinTestCount: Int
        public let activeLatinFailureCount: Int
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let focusedRootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedMetalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let tokenizerTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let xctestFailureCount: Int
        public let xctestSkipCount: Int
        public let orderedReviewedExecutionRoles: [String]
        public let swiftReleaseBuildProductCommandCount: Int
        public let swiftReleaseShowBinPathCommandCount: Int
        public let exactSwiftPMCommandCount: Int
        public let launcherInvocationCount: Int
        public let adapterCommandAttemptCount: Int
        public let fixtureProcessExecutionCount: Int
        public let hostedRecordCount: Int
        public let runURL: String
    }

    public struct HostedRecord: Codable, Equatable, Sendable {
        public let actionsArtifact: Bool
        public let adapterCommandAttemptOneShotConsumed: Bool
        public let adapterCommandState: String
        public let adapterExecutableByteCount: Int?
        public let adapterExecutableSHA256: String?
        public let adapterExecutionObservation: String
        public let authorityCanonicalSHA256: String
        public let authorityID: String
        public let captureCleanupAbsence: String
        public let durableEvidence: Bool
        public let exactRevision: String
        public let fixtureExecutableByteCount: Int?
        public let fixtureExecutableSHA256: String?
        public let opportunityState: String
        public let resultCode: String
        public let schemaID: String
        public let schemaVersion: Int
        public let scientificOutcome: String
        public let shellWaitStatus: Int?
        public let standardErrorByteCap: Int
        public let standardErrorCaptureCapReached: Bool
        public let standardErrorCapturedByteCount: Int
        public let standardErrorSHA256: String
        public let standardOutputByteCap: Int
        public let standardOutputCaptureCapReached: Bool
        public let standardOutputCapturedByteCount: Int
        public let standardOutputSHA256: String

        private enum CodingKeys: String, CodingKey {
            case actionsArtifact = "actions_artifact"
            case adapterCommandAttemptOneShotConsumed =
                "adapter_command_attempt_one_shot_consumed"
            case adapterCommandState = "adapter_command_state"
            case adapterExecutableByteCount = "adapter_executable_byte_count"
            case adapterExecutableSHA256 = "adapter_executable_sha256"
            case adapterExecutionObservation = "adapter_execution_observation"
            case authorityCanonicalSHA256 = "authority_canonical_sha256"
            case authorityID = "authority_id"
            case captureCleanupAbsence = "capture_cleanup_absence"
            case durableEvidence = "durable_evidence"
            case exactRevision = "exact_revision"
            case fixtureExecutableByteCount = "fixture_executable_byte_count"
            case fixtureExecutableSHA256 = "fixture_executable_sha256"
            case opportunityState = "opportunity_state"
            case resultCode = "result_code"
            case schemaID = "schema_id"
            case schemaVersion = "schema_version"
            case scientificOutcome = "scientific_outcome"
            case shellWaitStatus = "shell_wait_status"
            case standardErrorByteCap = "standard_error_byte_cap"
            case standardErrorCaptureCapReached =
                "standard_error_capture_cap_reached"
            case standardErrorCapturedByteCount =
                "standard_error_captured_byte_count"
            case standardErrorSHA256 = "standard_error_sha256"
            case standardOutputByteCap = "standard_output_byte_cap"
            case standardOutputCaptureCapReached =
                "standard_output_capture_cap_reached"
            case standardOutputCapturedByteCount =
                "standard_output_captured_byte_count"
            case standardOutputSHA256 = "standard_output_sha256"
        }

        public func canonicalData() throws -> Data {
            try PrimeCanonicalJSON.encode(self)
        }
    }

    public struct HostedRecordIdentity: Codable, Equatable, Sendable {
        public let prefix: String
        public let prefixByteCount: Int
        public let canonicalJSONByteCount: Int
        public let canonicalJSONSHA256: String
        public let totalLineByteCountIncludingTerminalLF: Int
        public let totalLineSHA256IncludingTerminalLF: String
        public let exactOccurrenceCount: Int
        public let exactFieldCount: Int
        public let rawChildOutputOrErrorFieldCount: Int
        public let record: HostedRecord
    }

    public struct PINMismatchBoundary: Codable, Equatable, Sendable {
        public let resultCode: String
        public let classification: String
        public let setupOutcomeEstablished: Bool
        public let configuredFixturePinByteCount: Int
        public let configuredFixturePinSHA256: String
        public let adapterExecutableIdentityObserved: Bool
        public let fixtureExecutableIdentityPublished: Bool
        public let observedFixtureExecutableByteCount: Int?
        public let observedFixtureExecutableSHA256: String?
        public let mismatchDimensionEvidence: String
        public let byteCountMismatchEstablished: Bool
        public let sha256MismatchEstablished: Bool
        public let bothDimensionsMismatchEstablished: Bool
        public let adapterCommandState: String
        public let adapterCommandAttemptOneShotConsumed: Bool
        public let adapterExecutionObservation: String
        public let adapterCommandAttemptCount: Int
        public let fixtureProcessExecutionCount: Int
        public let processContainmentEstablished: Bool
        public let captureCleanupAbsenceEvidence: String
        public let scientificOutcome: String
        public let durableEvidenceEstablished: Bool
        public let actionsArtifactCount: Int
        public let mechanicsOpportunityState: String
        public let workflowFailureEstablished: Bool
    }

    public struct RetirementPath: Codable, Equatable, Sendable {
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let role: String
    }

    public struct RetirementBoundary: Codable, Equatable, Sendable {
        public let retirementRequired: Bool
        public let retirementObserved: Bool
        public let exactOrderedChangedPaths: [RetirementPath]
        public let exactChangedPathCount: Int
        public let expectedActiveLatinTestCount: Int
        public let expectedRootTestCount: Int
        public let expectedIsolatedGroupTestCounts: [Int]
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedCanaryLauncherWorkflowReferenceCount: Int
        public let expectedCanaryLauncherInvocationCount: Int
        public let expectedAdapterCommandAttemptCount: Int
        public let expectedHostedRecordCount: Int
        public let launcherSourcePreservedForAudit: Bool
        public let launcherPath: String
        public let launcherGitMode: String
        public let launcherGitBlob: String
        public let launcherByteCount: Int
        public let launcherLFByteCount: Int
        public let launcherSHA256: String
        public let commandAttemptOneShotUnconsumed: Bool
        public let mechanicsOpportunityRetired: Bool
        public let exactMainRetirementClosureRequired: Bool
        public let retryWithoutNewAuthorityPermitted: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let exactHostedRecordIntegrityEstablished: Bool
        public let pinMismatchEstablished: Bool
        public let setupOutcomeEstablished: Bool
        public let adapterExecutableIdentityEstablished: Bool
        public let mechanicsOpportunityRetired: Bool
        public let failureObservationAuthorizesNothing: Bool
        public let exactRetirementRequired: Bool
        public let workflowFailureEstablished: Bool
        public let fixtureExecutableObservedByteCountEstablished: Bool
        public let fixtureExecutableObservedSHA256Established: Bool
        public let fixturePinByteCountMismatchEstablished: Bool
        public let fixturePinSHA256MismatchEstablished: Bool
        public let bothFixturePinDimensionsMismatchEstablished: Bool
        public let adapterCommandAttempted: Bool
        public let adapterCommandOneShotConsumed: Bool
        public let adapterExecuted: Bool
        public let fixtureProcessExecuted: Bool
        public let processContainmentEstablished: Bool
        public let captureCleanupAbsenceEstablished: Bool
        public let operationalCompatibilityEstablished: Bool
        public let scientificOutcomeEstablished: Bool
        public let durableEvidenceEstablished: Bool
        public let actionsArtifactPublished: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let canaryMechanicsRepairOrReplacementAuthorized: Bool
        public let launcherMutationAuthorized: Bool
        public let fixtureMutationAuthorized: Bool
        public let adapterMutationAuthorized: Bool
        public let processLayerMutationAuthorized: Bool
        public let leaseMutationAuthorized: Bool
        public let additionalMLXExecutionAuthorized: Bool
        public let additionalMetalExecutionAuthorized: Bool
        public let native300MExecutionAuthorized: Bool
        public let newCppImplementationAuthorized: Bool
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
    public let authorityClosure: AuthorityClosure
    public let mechanicsSourceBindings: [MechanicsSourceIdentity]
    public let repositoryIdentity: RepositoryIdentity
    public let pullRequestLane: PullRequestLane
    public let exactMainLane: ExactMainLane
    public let hostedRecordIdentity: HostedRecordIdentity
    public let pinMismatchBoundary: PINMismatchBoundary
    public let retirementBoundary: RetirementBoundary
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalByteCount = 12_604
    public static let canonicalSHA256 =
        "327a3fedcd1fed6a936aa053c3882c770a106db7e2662e76815a2b5d21333e16"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_secure_child_process_evidence_closed_fixture_canary_pin_mismatch_execution_observation_schema_v1",
        observationID:
            "prime_secure_child_process_evidence_closed_fixture_canary_pin_mismatch_execution_observation_v1",
        observationKind:
            "terminal_exact_main_closed_fixture_canary_pin_mismatch_adapter_not_attempted_opportunity_retired_no_retry",
        authorityClosure: .init(
            authorityID:
                "prime_secure_child_process_evidence_closed_fixture_canary_authority_v1",
            canonicalByteCount: 48_364,
            canonicalSHA256:
                "29cd7cb18001da845021bc60f8f250a920f927cdc302e5d5071e95f049c3351f",
            mergeRevision:
                "b3402efd96d3ff893a0c2b73897cf48c9b313c8c",
            mergeTree:
                "7fb3f5505796a43c9db1537ca72f81e19367365f",
            orderedParentRevisions: [
                "232a17e8f58a297919366d963ee1d7bc38cdbaee",
                "82ae2c2611e62144c066db990be6eaf48fdff47a",
            ],
            pullRequestNumber: 121,
            workflowRunID: 31_957_009_710,
            workflowRunNumber: 141,
            workflowRunAttempt: 1,
            checkSuiteID: 86_653_677_663,
            activeRootJobID: 95_189_063_495,
            reviewedMainJobID: 95_189_438_167,
            activeRootJobConclusion: "success",
            reviewedMainJobConclusion: "success",
            activeLatinTestCount: 116,
            focusedRootTestCount: 78,
            isolatedTestCount: 6,
            focusedWholeTestCount: 84,
            retainedLiveTestCount: 46,
            aggregateTestCount: 130,
            reviewedFailureCount: 0,
            reviewedSkipCount: 0,
            workflowRerunCount: 0,
            actionsArtifactCount: 0,
            exactMainClosureEstablished: true),
        mechanicsSourceBindings: [
            .init(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                mechanicsGitStatus: "M",
                gitMode: "100755",
                gitBlob: "f4993235980958140ffd079818b337fb04323177",
                byteCount: 1_187_421,
                lfByteCount: 19_816,
                sha256:
                    "86b577a109d4fed36cf05c6859055cba9b5449b4673786575b07eee27375be15",
                role: "exact_gate_binding_for_single_main_push_canary"),
            .init(
                path:
                    ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
                mechanicsGitStatus: "A",
                gitMode: "100755",
                gitBlob: "2b4cd9ca38410eed6661c1de50fcdab595c24b77",
                byteCount: 57_143,
                lfByteCount: 1_204,
                sha256:
                    "0c00a5ff7b5752be59d674699b7dca4bfa5b3fe973ab96e7cf8a0f455b9f2eea",
                role: "closed_outer_launcher_preserved_for_audit"),
            .init(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                mechanicsGitStatus: "M",
                gitMode: "100644",
                gitBlob: "e0a1678488ccef7aa70090e4fa5c83384edf1e49",
                byteCount: 140_991,
                lfByteCount: 722,
                sha256:
                    "9f5441aab18be449f4c8292e49f8da99fed36abf322e0c4cdbfba9438177c100",
                role: "literal_final_reviewed_job_invocation_on_exact_main"),
        ],
        repositoryIdentity: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            pullRequestNumber: 122,
            baseRevision:
                "b3402efd96d3ff893a0c2b73897cf48c9b313c8c",
            baseTree:
                "7fb3f5505796a43c9db1537ca72f81e19367365f",
            reviewedHeadRevision:
                "72f8d7ec790d5761e83aed0e086599eaf2cd42d9",
            reviewedHeadTree:
                "e01bb064bc40fd4a3d875e8506f3088424ab773b",
            reviewedHeadOrderedParentRevisions: [
                "b3402efd96d3ff893a0c2b73897cf48c9b313c8c",
            ],
            mergeRevision:
                "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
            mergeTree:
                "e01bb064bc40fd4a3d875e8506f3088424ab773b",
            orderedParentRevisions: [
                "b3402efd96d3ff893a0c2b73897cf48c9b313c8c",
                "72f8d7ec790d5761e83aed0e086599eaf2cd42d9",
            ],
            mergeCommitSignatureVerified: true,
            mergeCommitSignatureReason: "valid",
            historyPreservingTwoParentMergeObserved: true,
            mergeTreeEqualsReviewedHeadTree: true,
            exactMainRefMatchedAtTerminalAudit: true,
            exactChangedPathCount: 3,
            changedManifestPathCount: 0,
            changedLockPathCount: 0),
        pullRequestLane: .init(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath:
                ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_965_892_051,
            runNumber: 142,
            runAttempt: 1,
            checkSuiteID: 86_674_348_466,
            event: "pull_request",
            headBranch:
                "agent/prime-secure-child-process-evidence-closed-fixture-canary",
            headRevision:
                "72f8d7ec790d5761e83aed0e086599eaf2cd42d9",
            status: "completed",
            conclusion: "success",
            exactHeadRunCount: 1,
            previousAttemptURLWasNull: true,
            retryCount: 0,
            rerunCount: 0,
            artifactCount: 0,
            activeRootJobID: 95_210_894_514,
            activeRootJobConclusion: "success",
            activeLatinTestCount: 116,
            activeLatinFailureCount: 0,
            reviewedMainJobID: 95_211_273_235,
            reviewedMainJobConclusion: "skipped",
            reviewedMainJobStepCount: 0,
            launcherInvocationCount: 0,
            adapterCommandAttemptCount: 0,
            hostedRecordCount: 0,
            runURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31965892051"),
        exactMainLane: .init(
            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath:
                ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_974_943_697,
            runNumber: 143,
            runAttempt: 1,
            checkSuiteID: 86_694_964_833,
            event: "push",
            headBranch: "main",
            headRevision:
                "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
            status: "completed",
            conclusion: "failure",
            exactHeadRunCount: 1,
            previousAttemptURLWasNull: true,
            retryCount: 0,
            rerunCount: 0,
            artifactCount: 0,
            activeRootJobID: 95_232_879_059,
            activeRootJobConclusion: "success",
            activeLatinTestCount: 116,
            activeLatinFailureCount: 0,
            reviewedMainJobID: 95_233_206_587,
            reviewedMainJobConclusion: "failure",
            focusedRootTestCount: 78,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 84,
            retainedMetalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            tokenizerTestCount: 1,
            retainedLiveTestCount: 46,
            aggregateTestCount: 130,
            xctestFailureCount: 0,
            xctestSkipCount: 0,
            orderedReviewedExecutionRoles: [
                "focused",
                "metal",
                "maintained_runtime",
                "tokenizer",
                "closed_fixture_canary",
            ],
            swiftReleaseBuildProductCommandCount: 2,
            swiftReleaseShowBinPathCommandCount: 1,
            exactSwiftPMCommandCount: 3,
            launcherInvocationCount: 1,
            adapterCommandAttemptCount: 0,
            fixtureProcessExecutionCount: 0,
            hostedRecordCount: 1,
            runURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31974943697"),
        hostedRecordIdentity: .init(
            prefix:
                "prime-secure-child closed-fixture-canary observation: ",
            prefixByteCount: 54,
            canonicalJSONByteCount: 1_331,
            canonicalJSONSHA256:
                "1980a1227fba50e1bfab9268b82fee1de6255d843fbf065ff72ad4e0d4398821",
            totalLineByteCountIncludingTerminalLF: 1_386,
            totalLineSHA256IncludingTerminalLF:
                "3a507dfb0941cd662037da3c0a681216dc13d9804e58624fb9fba4e1670f7f0a",
            exactOccurrenceCount: 1,
            exactFieldCount: 27,
            rawChildOutputOrErrorFieldCount: 0,
            record: .init(
                actionsArtifact: false,
                adapterCommandAttemptOneShotConsumed: false,
                adapterCommandState: "not_attempted",
                adapterExecutableByteCount: 37_533_680,
                adapterExecutableSHA256:
                    "dc77edad4a9b66e48a7322bbc69717a9467ce5e20527b940e66b9061ec50c460",
                adapterExecutionObservation: "observed_false",
                authorityCanonicalSHA256:
                    "29cd7cb18001da845021bc60f8f250a920f927cdc302e5d5071e95f049c3351f",
                authorityID:
                    "prime_secure_child_process_evidence_closed_fixture_canary_authority_v1",
                captureCleanupAbsence: "unavailable",
                durableEvidence: false,
                exactRevision:
                    "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
                fixtureExecutableByteCount: nil,
                fixtureExecutableSHA256: nil,
                opportunityState: "retired",
                resultCode: "PIN_MISMATCH",
                schemaID:
                    "prime_secure_child_process_evidence_closed_fixture_canary_outer_observation_v1",
                schemaVersion: 1,
                scientificOutcome: "not_established",
                shellWaitStatus: nil,
                standardErrorByteCap: 131_072,
                standardErrorCaptureCapReached: false,
                standardErrorCapturedByteCount: 0,
                standardErrorSHA256:
                    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                standardOutputByteCap: 131_072,
                standardOutputCaptureCapReached: false,
                standardOutputCapturedByteCount: 0,
                standardOutputSHA256:
                    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")),
        pinMismatchBoundary: .init(
            resultCode: "PIN_MISMATCH",
            classification:
                "setup_refusal_before_adapter_command_due_to_frozen_fixture_identity_pin_mismatch",
            setupOutcomeEstablished: true,
            configuredFixturePinByteCount: 89_632,
            configuredFixturePinSHA256:
                "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd",
            adapterExecutableIdentityObserved: true,
            fixtureExecutableIdentityPublished: false,
            observedFixtureExecutableByteCount: nil,
            observedFixtureExecutableSHA256: nil,
            mismatchDimensionEvidence:
                "unavailable_size_sha256_or_both_not_disclosed_by_hosted_record",
            byteCountMismatchEstablished: false,
            sha256MismatchEstablished: false,
            bothDimensionsMismatchEstablished: false,
            adapterCommandState: "not_attempted",
            adapterCommandAttemptOneShotConsumed: false,
            adapterExecutionObservation: "observed_false",
            adapterCommandAttemptCount: 0,
            fixtureProcessExecutionCount: 0,
            processContainmentEstablished: false,
            captureCleanupAbsenceEvidence: "unavailable",
            scientificOutcome: "not_established",
            durableEvidenceEstablished: false,
            actionsArtifactCount: 0,
            mechanicsOpportunityState: "retired",
            workflowFailureEstablished: true),
        retirementBoundary: .init(
            retirementRequired: true,
            retirementObserved: false,
            exactOrderedChangedPaths: [
                .init(
                    path:
                        ".github/scripts/prime-ci-active-root-quarantine.sh",
                    gitStatus: "M",
                    gitMode: "100755",
                    role:
                        "remove_single_canary_admission_and_freeze_observation_retirement"),
                .init(
                    path:
                        ".github/workflows/prime-active-root-quarantine.yml",
                    gitStatus: "M",
                    gitMode: "100644",
                    role:
                        "remove_canary_environment_epoch_and_literal_final_invocation"),
                .init(
                    path:
                        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    gitStatus: "M",
                    gitMode: "100644",
                    role: "refresh_embedded_source_identity_only"),
                .init(
                    path:
                        "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservation.swift",
                    gitStatus: "A",
                    gitMode: "100644",
                    role: "append_only_terminal_observation_and_retirement"),
                .init(
                    path:
                        "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests.swift",
                    gitStatus: "A",
                    gitMode: "100644",
                    role: "pure_canonical_codable_exhaustive_contract"),
            ],
            exactChangedPathCount: 5,
            expectedActiveLatinTestCount: 116,
            expectedRootTestCount: 79,
            expectedIsolatedGroupTestCounts: [1, 1, 2, 2],
            expectedIsolatedTestCount: 6,
            expectedFocusedWholeTestCount: 85,
            expectedRetainedLiveTestCount: 46,
            expectedAggregateTestCount: 131,
            expectedCanaryLauncherWorkflowReferenceCount: 0,
            expectedCanaryLauncherInvocationCount: 0,
            expectedAdapterCommandAttemptCount: 0,
            expectedHostedRecordCount: 0,
            launcherSourcePreservedForAudit: true,
            launcherPath:
                ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
            launcherGitMode: "100755",
            launcherGitBlob:
                "2b4cd9ca38410eed6661c1de50fcdab595c24b77",
            launcherByteCount: 57_143,
            launcherLFByteCount: 1_204,
            launcherSHA256:
                "0c00a5ff7b5752be59d674699b7dca4bfa5b3fe973ab96e7cf8a0f455b9f2eea",
            commandAttemptOneShotUnconsumed: true,
            mechanicsOpportunityRetired: true,
            exactMainRetirementClosureRequired: true,
            retryWithoutNewAuthorityPermitted: false),
        authorityCeiling: .init(
            exactHostedRecordIntegrityEstablished: true,
            pinMismatchEstablished: true,
            setupOutcomeEstablished: true,
            adapterExecutableIdentityEstablished: true,
            mechanicsOpportunityRetired: true,
            failureObservationAuthorizesNothing: true,
            exactRetirementRequired: true,
            workflowFailureEstablished: true,
            fixtureExecutableObservedByteCountEstablished: false,
            fixtureExecutableObservedSHA256Established: false,
            fixturePinByteCountMismatchEstablished: false,
            fixturePinSHA256MismatchEstablished: false,
            bothFixturePinDimensionsMismatchEstablished: false,
            adapterCommandAttempted: false,
            adapterCommandOneShotConsumed: false,
            adapterExecuted: false,
            fixtureProcessExecuted: false,
            processContainmentEstablished: false,
            captureCleanupAbsenceEstablished: false,
            operationalCompatibilityEstablished: false,
            scientificOutcomeEstablished: false,
            durableEvidenceEstablished: false,
            actionsArtifactPublished: false,
            retryAuthorized: false,
            rerunAuthorized: false,
            replacementExecutionAuthorized: false,
            canaryMechanicsRepairOrReplacementAuthorized: false,
            launcherMutationAuthorized: false,
            fixtureMutationAuthorized: false,
            adapterMutationAuthorized: false,
            processLayerMutationAuthorized: false,
            leaseMutationAuthorized: false,
            additionalMLXExecutionAuthorized: false,
            additionalMetalExecutionAuthorized: false,
            native300MExecutionAuthorized: false,
            newCppImplementationAuthorized: false,
            checkpointAdmissionGranted: false,
            generalTrainingResumeAuthorized: false,
            modelQualityEstablished: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        orderedRequiredSeparateActions: [
            "merge_exact_five_path_observation_and_retirement_without_running_canary",
            "establish_exact_main_retirement_closure",
            "separately_authorize_any_new_fixture_pin_investigation",
            "separately_authorize_neutral_resource_lease_generalization",
            "separately_authorize_durable_transaction_layer_b",
            "only_then_review_any_mlx_metal_native300m_or_cpp_adapter",
        ],
        status:
            "PIN_MISMATCH_exact_main_run143_valid_outer_record_adapter_not_attempted_command_one_shot_unconsumed_mechanics_opportunity_retired_fixture_identity_unavailable_no_retry_no_scientific_or_durable_evidence")

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationError
                .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let authority =
            PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1
                .frozenV1
        try authority.validateExactV1()

        let recordData = try hostedRecordIdentity.record.canonicalData()
        let canonical = try canonicalData()
        let falseCeilings = [
            authorityCeiling.fixtureExecutableObservedByteCountEstablished,
            authorityCeiling.fixtureExecutableObservedSHA256Established,
            authorityCeiling.fixturePinByteCountMismatchEstablished,
            authorityCeiling.fixturePinSHA256MismatchEstablished,
            authorityCeiling.bothFixturePinDimensionsMismatchEstablished,
            authorityCeiling.adapterCommandAttempted,
            authorityCeiling.adapterCommandOneShotConsumed,
            authorityCeiling.adapterExecuted,
            authorityCeiling.fixtureProcessExecuted,
            authorityCeiling.processContainmentEstablished,
            authorityCeiling.captureCleanupAbsenceEstablished,
            authorityCeiling.operationalCompatibilityEstablished,
            authorityCeiling.scientificOutcomeEstablished,
            authorityCeiling.durableEvidenceEstablished,
            authorityCeiling.actionsArtifactPublished,
            authorityCeiling.retryAuthorized,
            authorityCeiling.rerunAuthorized,
            authorityCeiling.replacementExecutionAuthorized,
            authorityCeiling.canaryMechanicsRepairOrReplacementAuthorized,
            authorityCeiling.launcherMutationAuthorized,
            authorityCeiling.fixtureMutationAuthorized,
            authorityCeiling.adapterMutationAuthorized,
            authorityCeiling.processLayerMutationAuthorized,
            authorityCeiling.leaseMutationAuthorized,
            authorityCeiling.additionalMLXExecutionAuthorized,
            authorityCeiling.additionalMetalExecutionAuthorized,
            authorityCeiling.native300MExecutionAuthorized,
            authorityCeiling.newCppImplementationAuthorized,
            authorityCeiling.checkpointAdmissionGranted,
            authorityCeiling.generalTrainingResumeAuthorized,
            authorityCeiling.modelQualityEstablished,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              authorityClosure.authorityID == authority.authorityID,
              authorityClosure.canonicalByteCount
                == type(of: authority).canonicalByteCount,
              authorityClosure.canonicalSHA256
                == type(of: authority).canonicalSHA256,
              authorityClosure.orderedParentRevisions.count == 2,
              authorityClosure.workflowRunAttempt == 1,
              authorityClosure.workflowRerunCount == 0,
              authorityClosure.actionsArtifactCount == 0,
              authorityClosure.exactMainClosureEstablished,
              mechanicsSourceBindings.count == 3,
              Set(mechanicsSourceBindings.map(\.path)).count == 3,
              mechanicsSourceBindings.map(\.mechanicsGitStatus)
                == ["M", "A", "M"],
              mechanicsSourceBindings.map(\.gitMode)
                == ["100755", "100755", "100644"],
              mechanicsSourceBindings.allSatisfy({
                  $0.gitBlob.utf8.count == 40
                      && $0.sha256.utf8.count == 64
                      && $0.byteCount > 0
                      && $0.lfByteCount > 0
              }),
              repositoryIdentity.reviewedHeadOrderedParentRevisions
                == [repositoryIdentity.baseRevision],
              repositoryIdentity.mergeTree
                == repositoryIdentity.reviewedHeadTree,
              repositoryIdentity.orderedParentRevisions
                == [
                    repositoryIdentity.baseRevision,
                    repositoryIdentity.reviewedHeadRevision,
                ],
              repositoryIdentity.mergeCommitSignatureVerified,
              repositoryIdentity.mergeCommitSignatureReason == "valid",
              repositoryIdentity.historyPreservingTwoParentMergeObserved,
              repositoryIdentity.mergeTreeEqualsReviewedHeadTree,
              repositoryIdentity.exactMainRefMatchedAtTerminalAudit,
              repositoryIdentity.exactChangedPathCount == 3,
              repositoryIdentity.changedManifestPathCount == 0,
              repositoryIdentity.changedLockPathCount == 0,
              pullRequestLane.runNumber == 142,
              pullRequestLane.runAttempt == 1,
              pullRequestLane.conclusion == "success",
              pullRequestLane.exactHeadRunCount == 1,
              pullRequestLane.previousAttemptURLWasNull,
              pullRequestLane.retryCount == 0,
              pullRequestLane.rerunCount == 0,
              pullRequestLane.artifactCount == 0,
              pullRequestLane.activeRootJobConclusion == "success",
              pullRequestLane.reviewedMainJobConclusion == "skipped",
              pullRequestLane.reviewedMainJobStepCount == 0,
              pullRequestLane.launcherInvocationCount == 0,
              pullRequestLane.adapterCommandAttemptCount == 0,
              pullRequestLane.hostedRecordCount == 0,
              exactMainLane.runNumber == 143,
              exactMainLane.runAttempt == 1,
              exactMainLane.headRevision == repositoryIdentity.mergeRevision,
              exactMainLane.conclusion == "failure",
              exactMainLane.exactHeadRunCount == 1,
              exactMainLane.previousAttemptURLWasNull,
              exactMainLane.retryCount == 0,
              exactMainLane.rerunCount == 0,
              exactMainLane.artifactCount == 0,
              exactMainLane.activeRootJobConclusion == "success",
              exactMainLane.reviewedMainJobConclusion == "failure",
              exactMainLane.activeLatinTestCount == 116,
              exactMainLane.activeLatinFailureCount == 0,
              exactMainLane.focusedRootTestCount
                + exactMainLane.isolatedTestCount
                == exactMainLane.focusedWholeTestCount,
              exactMainLane.retainedMetalTestCount
                + exactMainLane.maintainedRuntimeTestCount
                + exactMainLane.tokenizerTestCount
                == exactMainLane.retainedLiveTestCount,
              exactMainLane.focusedWholeTestCount
                + exactMainLane.retainedLiveTestCount
                == exactMainLane.aggregateTestCount,
              exactMainLane.xctestFailureCount == 0,
              exactMainLane.xctestSkipCount == 0,
              exactMainLane.swiftReleaseBuildProductCommandCount == 2,
              exactMainLane.swiftReleaseShowBinPathCommandCount == 1,
              exactMainLane.exactSwiftPMCommandCount == 3,
              exactMainLane.swiftReleaseBuildProductCommandCount
                + exactMainLane.swiftReleaseShowBinPathCommandCount
                == exactMainLane.exactSwiftPMCommandCount,
              exactMainLane.launcherInvocationCount == 1,
              exactMainLane.adapterCommandAttemptCount == 0,
              exactMainLane.fixtureProcessExecutionCount == 0,
              exactMainLane.hostedRecordCount == 1,
              hostedRecordIdentity.prefixByteCount == 54,
              hostedRecordIdentity.canonicalJSONByteCount == 1_331,
              hostedRecordIdentity.totalLineByteCountIncludingTerminalLF
                == hostedRecordIdentity.prefixByteCount
                    + hostedRecordIdentity.canonicalJSONByteCount + 1,
              hostedRecordIdentity.exactOccurrenceCount == 1,
              hostedRecordIdentity.exactFieldCount == 27,
              hostedRecordIdentity.rawChildOutputOrErrorFieldCount == 0,
              recordData.count == hostedRecordIdentity.canonicalJSONByteCount,
              PrimeSHA256.hexDigest(of: recordData)
                == hostedRecordIdentity.canonicalJSONSHA256,
              hostedRecordIdentity.record.resultCode == "PIN_MISMATCH",
              hostedRecordIdentity.record.adapterCommandState
                == "not_attempted",
              !hostedRecordIdentity.record
                .adapterCommandAttemptOneShotConsumed,
              hostedRecordIdentity.record.adapterExecutionObservation
                == "observed_false",
              hostedRecordIdentity.record.adapterExecutableByteCount != nil,
              hostedRecordIdentity.record.adapterExecutableSHA256 != nil,
              hostedRecordIdentity.record.fixtureExecutableByteCount == nil,
              hostedRecordIdentity.record.fixtureExecutableSHA256 == nil,
              hostedRecordIdentity.record.shellWaitStatus == nil,
              hostedRecordIdentity.record.captureCleanupAbsence
                == "unavailable",
              hostedRecordIdentity.record.opportunityState == "retired",
              hostedRecordIdentity.record.scientificOutcome
                == "not_established",
              !hostedRecordIdentity.record.durableEvidence,
              !hostedRecordIdentity.record.actionsArtifact,
              pinMismatchBoundary.resultCode == "PIN_MISMATCH",
              pinMismatchBoundary.setupOutcomeEstablished,
              pinMismatchBoundary.adapterExecutableIdentityObserved,
              !pinMismatchBoundary.fixtureExecutableIdentityPublished,
              pinMismatchBoundary.observedFixtureExecutableByteCount == nil,
              pinMismatchBoundary.observedFixtureExecutableSHA256 == nil,
              !pinMismatchBoundary.byteCountMismatchEstablished,
              !pinMismatchBoundary.sha256MismatchEstablished,
              !pinMismatchBoundary.bothDimensionsMismatchEstablished,
              pinMismatchBoundary.adapterCommandState == "not_attempted",
              !pinMismatchBoundary.adapterCommandAttemptOneShotConsumed,
              pinMismatchBoundary.adapterExecutionObservation
                == "observed_false",
              pinMismatchBoundary.adapterCommandAttemptCount == 0,
              pinMismatchBoundary.fixtureProcessExecutionCount == 0,
              !pinMismatchBoundary.processContainmentEstablished,
              pinMismatchBoundary.captureCleanupAbsenceEvidence
                == "unavailable",
              pinMismatchBoundary.scientificOutcome == "not_established",
              !pinMismatchBoundary.durableEvidenceEstablished,
              pinMismatchBoundary.actionsArtifactCount == 0,
              pinMismatchBoundary.mechanicsOpportunityState == "retired",
              pinMismatchBoundary.workflowFailureEstablished,
              retirementBoundary.retirementRequired,
              !retirementBoundary.retirementObserved,
              retirementBoundary.exactChangedPathCount
                == retirementBoundary.exactOrderedChangedPaths.count,
              retirementBoundary.exactChangedPathCount == 5,
              Set(retirementBoundary.exactOrderedChangedPaths.map(\.path))
                .count == 5,
              retirementBoundary.exactOrderedChangedPaths.map(\.gitStatus)
                == ["M", "M", "M", "A", "A"],
              retirementBoundary.exactOrderedChangedPaths.map(\.gitMode)
                == ["100755", "100644", "100644", "100644", "100644"],
              retirementBoundary.expectedRootTestCount
                + retirementBoundary.expectedIsolatedTestCount
                == retirementBoundary.expectedFocusedWholeTestCount,
              retirementBoundary.expectedFocusedWholeTestCount
                + retirementBoundary.expectedRetainedLiveTestCount
                == retirementBoundary.expectedAggregateTestCount,
              retirementBoundary.expectedCanaryLauncherWorkflowReferenceCount
                == 0,
              retirementBoundary.expectedCanaryLauncherInvocationCount == 0,
              retirementBoundary.expectedAdapterCommandAttemptCount == 0,
              retirementBoundary.expectedHostedRecordCount == 0,
              retirementBoundary.launcherSourcePreservedForAudit,
              retirementBoundary.commandAttemptOneShotUnconsumed,
              retirementBoundary.mechanicsOpportunityRetired,
              retirementBoundary.exactMainRetirementClosureRequired,
              !retirementBoundary.retryWithoutNewAuthorityPermitted,
              authorityCeiling.exactHostedRecordIntegrityEstablished,
              authorityCeiling.pinMismatchEstablished,
              authorityCeiling.setupOutcomeEstablished,
              authorityCeiling.adapterExecutableIdentityEstablished,
              authorityCeiling.mechanicsOpportunityRetired,
              authorityCeiling.failureObservationAuthorizesNothing,
              authorityCeiling.exactRetirementRequired,
              authorityCeiling.workflowFailureEstablished,
              falseCeilings.allSatisfy({ !$0 }),
              canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256
        else {
            throw PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationError
                .contractDrift
        }
    }
}

extension
    PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationV1
        .HostedRecord
{
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actionsArtifact, forKey: .actionsArtifact)
        try container.encode(
            adapterCommandAttemptOneShotConsumed,
            forKey: .adapterCommandAttemptOneShotConsumed)
        try container.encode(adapterCommandState, forKey: .adapterCommandState)
        if let adapterExecutableByteCount {
            try container.encode(
                adapterExecutableByteCount,
                forKey: .adapterExecutableByteCount)
        } else {
            try container.encodeNil(forKey: .adapterExecutableByteCount)
        }
        if let adapterExecutableSHA256 {
            try container.encode(
                adapterExecutableSHA256,
                forKey: .adapterExecutableSHA256)
        } else {
            try container.encodeNil(forKey: .adapterExecutableSHA256)
        }
        try container.encode(
            adapterExecutionObservation,
            forKey: .adapterExecutionObservation)
        try container.encode(
            authorityCanonicalSHA256,
            forKey: .authorityCanonicalSHA256)
        try container.encode(authorityID, forKey: .authorityID)
        try container.encode(
            captureCleanupAbsence,
            forKey: .captureCleanupAbsence)
        try container.encode(durableEvidence, forKey: .durableEvidence)
        try container.encode(exactRevision, forKey: .exactRevision)
        if let fixtureExecutableByteCount {
            try container.encode(
                fixtureExecutableByteCount,
                forKey: .fixtureExecutableByteCount)
        } else {
            try container.encodeNil(forKey: .fixtureExecutableByteCount)
        }
        if let fixtureExecutableSHA256 {
            try container.encode(
                fixtureExecutableSHA256,
                forKey: .fixtureExecutableSHA256)
        } else {
            try container.encodeNil(forKey: .fixtureExecutableSHA256)
        }
        try container.encode(opportunityState, forKey: .opportunityState)
        try container.encode(resultCode, forKey: .resultCode)
        try container.encode(schemaID, forKey: .schemaID)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(scientificOutcome, forKey: .scientificOutcome)
        if let shellWaitStatus {
            try container.encode(shellWaitStatus, forKey: .shellWaitStatus)
        } else {
            try container.encodeNil(forKey: .shellWaitStatus)
        }
        try container.encode(
            standardErrorByteCap,
            forKey: .standardErrorByteCap)
        try container.encode(
            standardErrorCaptureCapReached,
            forKey: .standardErrorCaptureCapReached)
        try container.encode(
            standardErrorCapturedByteCount,
            forKey: .standardErrorCapturedByteCount)
        try container.encode(
            standardErrorSHA256,
            forKey: .standardErrorSHA256)
        try container.encode(
            standardOutputByteCap,
            forKey: .standardOutputByteCap)
        try container.encode(
            standardOutputCaptureCapReached,
            forKey: .standardOutputCaptureCapReached)
        try container.encode(
            standardOutputCapturedByteCount,
            forKey: .standardOutputCapturedByteCount)
        try container.encode(
            standardOutputSHA256,
            forKey: .standardOutputSHA256)
    }
}
