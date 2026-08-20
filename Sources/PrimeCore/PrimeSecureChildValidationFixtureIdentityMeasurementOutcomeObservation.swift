// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// Frozen, append-only evidence for the one authorized hosted validation-fixture
/// identity-measurement opportunity. Exact-main run 160 emitted one valid
/// `INVOCATION_ADMISSION_REFUSED` record before attempt consumption. It therefore
/// establishes neither a fixture identity nor repeat-build determinism nor a
/// relationship to the current Layer-A pin. The opportunity is retired without
/// repair, retry, rerun, or replacement. This Foundation/Codable value performs
/// no filesystem, build, compiler, evaluator, fixture, process, lease, model,
/// network, MLX, Metal, Python, or C++ operation.
public struct PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public struct FileIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let mechanicsGitStatus: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let crByteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct AuthorityClosure: Codable, Equatable, Sendable {
        public let authorityID: String
        public let canonicalByteCount: Int
        public let canonicalSHA256: String
        public let source: FileIdentity
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let pullRequestNumber: Int
        public let pullRequestRunID: Int
        public let pullRequestRunNumber: Int
        public let pullRequestCheckSuiteID: Int
        public let exactMainRunID: Int
        public let exactMainRunNumber: Int
        public let exactMainCheckSuiteID: Int
        public let exactMainActiveJobID: Int
        public let exactMainReviewedJobID: Int
        public let exactMainConclusion: String
        public let exactMainRootTestCount: Int
        public let exactMainIsolatedTestCount: Int
        public let exactMainFocusedWholeTestCount: Int
        public let exactMainRetainedLiveTestCount: Int
        public let exactMainAggregateTestCount: Int
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
        public let exactMainClosureEstablished: Bool
    }

    public struct MechanicsClosure: Codable, Equatable, Sendable {
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
        public let orderedMergeParentRevisions: [String]
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let historyPreservingTwoParentMergeObserved: Bool
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
        public let mergedAt: String
        public let exactChangedPathCount: Int
        public let changedManifestPathCount: Int
        public let changedLockPathCount: Int
        public let pullRequestRunID: Int
        public let pullRequestRunNumber: Int
        public let pullRequestRunAttempt: Int
        public let pullRequestCheckSuiteID: Int
        public let pullRequestConclusion: String
        public let pullRequestPreviousAttemptURL: String?
        public let matchingPullRequestRunCountForHead: Int
        public let pullRequestActiveJobID: Int
        public let pullRequestActiveJobConclusion: String
        public let pullRequestReviewedJobID: Int
        public let pullRequestReviewedJobConclusion: String
        public let pullRequestReviewedJobStepCount: Int
        public let pullRequestArtifactCount: Int
    }

    public struct WorkflowRun: Codable, Equatable, Sendable {
        public let workflowName: String
        public let workflowPath: String
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
        public let actionsArtifactCount: Int
        public let runURL: String
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
    }

    public struct SanitizedToolchainObservation: Codable, Equatable, Sendable {
        public let sourceJobID: Int
        public let sourceStepNumber: Int
        public let sourceStepName: String
        public let sourceStepConclusion: String
        public let sourceStepStartedAt: String
        public let sourceStepCompletedAt: String
        public let architecture: String
        public let productName: String
        public let productVersion: String
        public let buildVersion: String
        public let xcodeVersion: String
        public let xcodeBuildVersion: String
        public let swiftVersion: String
        public let swiftTarget: String
        public let swiftDriverVersionLine: String
        public let sdkVersion: String
        public let eachExactSanitizedLineOccurrenceCount: Int
        public let orderedRawSanitizedBlock: String
        public let rawSanitizedBlockByteCount: Int
        public let rawSanitizedBlockLFByteCount: Int
        public let rawSanitizedBlockSHA256: String
    }

    public struct TestAndOperationalObservation: Codable, Equatable, Sendable {
        public let activeLatinTestCount: Int
        public let activeLatinFailureCount: Int
        public let activeLatinSkipCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedMetalTestCount: Int
        public let retainedMaintainedRuntimeTestCount: Int
        public let retainedTokenizerTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let xctestFailureCount: Int
        public let xctestSkipCount: Int
        public let measurementLauncherInvocationCount: Int
        public let measurementStepFixtureProductBuildCommandAttemptCount: Int
        public let measurementStepShowBinPathCommandAttemptCount: Int
        public let measurementStepEvaluatorCompilerInvocationCount: Int
        public let measurementStepEvaluatorInvocationCount: Int
        public let measurementStepFixtureExecutionCount: Int
        public let measurementStepAdapterExecutionCount: Int
        public let measurementStepLeaseAcquisitionCount: Int
        public let measurementStepModelExecutionCount: Int
        public let measurementStepMLXExecutionCount: Int
        public let measurementStepMetalExecutionCount: Int
        public let measurementStepPythonInvocationCount: Int
        public let measurementStepCppInvocationCount: Int
    }

    public struct HostedRecord: Codable, Equatable, Sendable {
        public let actionsArtifact: Bool
        public let authorityCanonicalSHA256: String
        public let authorityID: String
        public let buildACommandState: String
        public let buildBCommandState: String
        public let byteCountEqual: String
        public let canaryExecutionPerformed: Bool
        public let currentPinByteCountMatch: String
        public let currentPinFullMatch: String
        public let currentPinSHA256Match: String
        public let durableEvidence: Bool
        public let evaluatorCommandState: String
        public let evaluatorCompileState: String
        public let evaluatorExecutionObservation: String
        public let evaluatorShellWaitStatus: Int?
        public let exactRevision: String
        public let fixtureABuildPlatformPacked: Int?
        public let fixtureAByteCount: Int?
        public let fixtureAMachOUUID: String?
        public let fixtureAMinimumOSPpacked: Int?
        public let fixtureASDKPacked: Int?
        public let fixtureASHA256: String?
        public let fixtureBBuildPlatformPacked: Int?
        public let fixtureBByteCount: Int?
        public let fixtureBMachOUUID: String?
        public let fixtureBMinimumOSPpacked: Int?
        public let fixtureBSDKPacked: Int?
        public let fixtureBSHA256: String?
        public let fixtureExecutionCount: Int
        public let fullBytesEqual: String
        public let machoIdentityEqual: String
        public let measurementAttemptConsumed: Bool
        public let opportunityState: String
        public let pinMutationPerformed: Bool
        public let rawBuildOutputOrErrorFieldCount: Int
        public let rawPathCount: Int
        public let resultCode: String
        public let schemaID: String
        public let schemaVersion: Int
        public let scientificOutcome: String
        public let sha256Equal: String
        public let showBinACommandState: String
        public let showBinBCommandState: String

        fileprivate enum CodingKeys: String, CodingKey {
            case actionsArtifact = "actions_artifact"
            case authorityCanonicalSHA256 = "authority_canonical_sha256"
            case authorityID = "authority_id"
            case buildACommandState = "build_a_command_state"
            case buildBCommandState = "build_b_command_state"
            case byteCountEqual = "byte_count_equal"
            case canaryExecutionPerformed = "canary_execution_performed"
            case currentPinByteCountMatch = "current_pin_byte_count_match"
            case currentPinFullMatch = "current_pin_full_match"
            case currentPinSHA256Match = "current_pin_sha256_match"
            case durableEvidence = "durable_evidence"
            case evaluatorCommandState = "evaluator_command_state"
            case evaluatorCompileState = "evaluator_compile_state"
            case evaluatorExecutionObservation = "evaluator_execution_observation"
            case evaluatorShellWaitStatus = "evaluator_shell_wait_status"
            case exactRevision = "exact_revision"
            case fixtureABuildPlatformPacked = "fixture_a_build_platform_packed"
            case fixtureAByteCount = "fixture_a_byte_count"
            case fixtureAMachOUUID = "fixture_a_macho_uuid"
            case fixtureAMinimumOSPpacked = "fixture_a_minimum_os_packed"
            case fixtureASDKPacked = "fixture_a_sdk_packed"
            case fixtureASHA256 = "fixture_a_sha256"
            case fixtureBBuildPlatformPacked = "fixture_b_build_platform_packed"
            case fixtureBByteCount = "fixture_b_byte_count"
            case fixtureBMachOUUID = "fixture_b_macho_uuid"
            case fixtureBMinimumOSPpacked = "fixture_b_minimum_os_packed"
            case fixtureBSDKPacked = "fixture_b_sdk_packed"
            case fixtureBSHA256 = "fixture_b_sha256"
            case fixtureExecutionCount = "fixture_execution_count"
            case fullBytesEqual = "full_bytes_equal"
            case machoIdentityEqual = "macho_identity_equal"
            case measurementAttemptConsumed = "measurement_attempt_consumed"
            case opportunityState = "opportunity_state"
            case pinMutationPerformed = "pin_mutation_performed"
            case rawBuildOutputOrErrorFieldCount =
                "raw_build_output_or_error_field_count"
            case rawPathCount = "raw_path_count"
            case resultCode = "result_code"
            case schemaID = "schema_id"
            case schemaVersion = "schema_version"
            case scientificOutcome = "scientific_outcome"
            case sha256Equal = "sha256_equal"
            case showBinACommandState = "show_bin_a_command_state"
            case showBinBCommandState = "show_bin_b_command_state"
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
        public let emittedAt: String
        public let physicalTimestampedLineReconstruction: String
        public let physicalTimestampedLineByteCountIncludingTerminalLF: Int
        public let physicalTimestampedLineSHA256IncludingTerminalLF: String
        public let reviewedDecodedLogPhysicalLineNumber: Int
        public let workflowConclusionMatchesResultInvariant: Bool
        public let acceptingRecord: Bool
        public let record: HostedRecord
    }

    public struct InvocationRefusalInference: Codable, Equatable, Sendable {
        public let resultCode: String
        public let hostedRecordPublishesFailedPredicate: Bool
        public let sanitizedReviewedLogPublishesFailedPredicate: Bool
        public let failureCauseDirectlyEstablished: Bool
        public let classification: String
        public let likelyCause: String
        public let inferenceBasis: [String]
        public let checkoutFetchDepth: Int
        public let exactRevision: String
        public let mechanicsSecondParentRevision: String
        public let authorityClosureRevision: String
        public let launcherRequiredRevisionExpression: String
        public let launcherRequiredExpressionExpectedRevision: String
        public let launcherSourceLine: Int
        public let authorityClosureWasExplicitProofOnlyWant: Bool
        public let mechanicsHeadWasExplicitProofOnlyWant: Bool
        public let inferenceAuthorizesRepairRetryRerunOrReplacement: Bool
    }

    public struct OutcomeDisposition: Codable, Equatable, Sendable {
        public let resultCode: String
        public let workflowConclusion: String
        public let category: String
        public let separateNoMutationConfirmationAuthorityEligible: Bool
        public let separatePinRepairAuthorityEligible: Bool
        public let canaryDirectlyAuthorized: Bool
    }

    public struct AbsentOrExternallyTerminatedRecordContract:
        Codable,
        Equatable,
        Sendable
    {
        public let externallyTerminatedRecordCardinality: String
        public let launcherNotReachedRecordCount: Int
        public let orderedPermittedClassifications: [String]
        public let causeMustNotBeInventedBeyondActionsAndSanitizedLog: Bool
        public let attemptConsumptionWithoutSeparateProof: String
        public let measurementEstablished: Bool
        public let fixtureIdentityEstablished: Bool
        public let repeatBuildDeterminismEstablished: Bool
        public let currentPinComparisonEstablished: Bool
        public let presentRecordUnderCancelledTimedOutOrNonmatchingConclusionAccepting:
            Bool
        public let opportunityRetired: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementMeasurementAuthorized: Bool
    }

    public struct OutcomeBoundary: Codable, Equatable, Sendable {
        public let resultCode: String
        public let classification: String
        public let launcherControlledTerminalRecordEstablished: Bool
        public let hostedRecordIntegrityEstablished: Bool
        public let workflowFailureEstablished: Bool
        public let measurementAttemptConsumed: Bool
        public let fixtureIdentityEstablished: Bool
        public let repeatBuildDeterminismEstablished: Bool
        public let currentPinByteCountMatchEstablished: Bool
        public let currentPinSHA256MatchEstablished: Bool
        public let currentPinFullMatchEstablished: Bool
        public let fixtureExecutionCount: Int
        public let scientificOutcome: String
        public let durableEvidenceEstablished: Bool
        public let actionsArtifactCount: Int
        public let opportunityState: String
        public let noRerunProof: [String]
    }

    public struct RetirementPath: Codable, Equatable, Sendable {
        public let ordinal: Int
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
        public let reviewedTimeoutBeforeMinutes: Int
        public let reviewedTimeoutAfterMinutes: Int
        public let activeTimeoutMinutes: Int
        public let expectedActiveLatinTestCount: Int
        public let expectedRootTestCount: Int
        public let expectedIsolatedGroupTestCounts: [Int]
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedEmbeddedProvenanceRecordCount: Int
        public let expectedMeasurementWorkflowStepCount: Int
        public let expectedLauncherWorkflowReferenceCount: Int
        public let expectedLauncherInvocationCount: Int
        public let expectedEvaluatorInvocationCount: Int
        public let expectedHostedRecordCount: Int
        public let launcherSourcePreservedForAudit: Bool
        public let evaluatorSourcePreservedForAudit: Bool
        public let launcherSource: FileIdentity
        public let evaluatorSource: FileIdentity
        public let sourceParserMayRetainEvaluatorPathWithoutInvokingIt: Bool
        public let measurementOpportunityRetired: Bool
        public let exactMainRetirementClosureRequired: Bool
        public let retryWithoutNewAuthorityPermitted: Bool
        public let rerunPermitted: Bool
        public let replacementMeasurementPermitted: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let measurementAuthorityExactMainGreenEstablished: Bool
        public let mechanicsExactMainClosureEstablished: Bool
        public let exactHostedRecordIntegrityEstablished: Bool
        public let invocationAdmissionRefusalEstablished: Bool
        public let likelyRefusalCauseIsInferenceOnly: Bool
        public let measurementOpportunityRetired: Bool
        public let exactRetirementRequired: Bool
        public let sanitizedToolchainObservationEstablished: Bool
        public let reviewedJobLogIdentityEstablished: Bool
        public let workflowFailureEstablished: Bool
        public let currentPatchAddsOnlyPureObservationPair: Bool
        public let filesystemReadAuthorizedByObservationValue: Bool
        public let filesystemWriteAuthorizedByObservationValue: Bool
        public let compilerInvocationAuthorized: Bool
        public let evaluatorInvocationAuthorized: Bool
        public let fixtureBuildAuthorized: Bool
        public let fixtureExecutionAuthorized: Bool
        public let adapterExecutionAuthorized: Bool
        public let leaseAcquisitionAuthorized: Bool
        public let modelExecutionAuthorized: Bool
        public let networkAuthorized: Bool
        public let measurementAttemptConsumed: Bool
        public let measuredFixtureIdentityEstablished: Bool
        public let repeatBuildDeterminismEstablished: Bool
        public let currentPinMatchEstablished: Bool
        public let currentPinMismatchEstablished: Bool
        public let fixturePinMutationAuthorized: Bool
        public let fixturePinMutationPerformed: Bool
        public let pinRepairAuthorityEstablished: Bool
        public let confirmationMeasurementAuthorized: Bool
        public let monitorHeldLeaseCanaryAuthorized: Bool
        public let monitorHeldLeaseCanaryPerformed: Bool
        public let durableEvidenceEstablished: Bool
        public let childLifetimeContinuityEstablished: Bool
        public let physicalMetalReservationEstablished: Bool
        public let mlxDeviceIdentityEstablished: Bool
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
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementMeasurementAuthorized: Bool
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let observationID: String
    public let observationKind: String
    public let authorityClosure: AuthorityClosure
    public let mechanicsSourceBindings: [FileIdentity]
    public let mechanicsClosure: MechanicsClosure
    public let workflowRun: WorkflowRun
    public let activeRootJob: Job
    public let activeRootConnectorDecodedJobLog: ConnectorDecodedUTF8JobLogIdentity
    public let reviewedMainJob: Job
    public let reviewedMainConnectorDecodedJobLog:
        ConnectorDecodedUTF8JobLogIdentity
    public let sanitizedToolchainObservation: SanitizedToolchainObservation
    public let testAndOperationalObservation: TestAndOperationalObservation
    public let hostedRecordIdentity: HostedRecordIdentity
    public let invocationRefusalInference: InvocationRefusalInference
    public let resultDispositions: [OutcomeDisposition]
    public let absentOrExternallyTerminatedRecordContract:
        AbsentOrExternallyTerminatedRecordContract
    public let outcomeBoundary: OutcomeBoundary
    public let retirementBoundary: RetirementBoundary
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalByteCount = 28_633
    public static let canonicalSHA256 =
        "d7042968a0c78d213c92d73d11d6637f3c03b0f758555376263b9d3aa8ec1a77"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_secure_child_validation_fixture_identity_measurement_outcome_observation_v1",
        observationID:
            "prime_secure_child_validation_fixture_identity_measurement_outcome_observation_v1",
        observationKind:
            "append_only_exact_main_invocation_admission_refusal_observation_and_irreversible_measurement_retirement",
        authorityClosure: .init(
            authorityID:
                "ergentics_prime_secure_child_validation_fixture_identity_measurement_authority_v1",
            canonicalByteCount: 66_632,
            canonicalSHA256:
                "67ad7808b54314b7dcd70a86b5504e7321c4c348a0ecb2ec172d5b72ee3f6d43",
            source: .init(
                path:
                    "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementAuthority.swift",
                mechanicsGitStatus: "A",
                gitMode: "100644",
                gitBlob: "1d81d4a29f06fbc18ca3c1a97742159b5280837e",
                byteCount: 124_073,
                lfByteCount: 2_175,
                crByteCount: 0,
                sha256:
                    "ff043520c144196532885ca79f0b2047cd8d28ac61ca544d259f140ed4e6aea4",
                role: "frozen_measurement_authority_source"),
            mergeRevision:
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
            mergeTree:
                "9b8a784e605967141f159a5f8c953a0096cf1f8d",
            orderedParentRevisions: [
                "75b14056b75e8af6af0c070453f7ef14ac10a063",
                "690b5047e553d6869e3dc7c97ad858a349175b2c",
            ],
            pullRequestNumber: 129,
            pullRequestRunID: 32_377_463_484,
            pullRequestRunNumber: 157,
            pullRequestCheckSuiteID: 87_769_199_371,
            exactMainRunID: 32_378_266_794,
            exactMainRunNumber: 158,
            exactMainCheckSuiteID: 87_771_501_000,
            exactMainActiveJobID: 96_454_836_227,
            exactMainReviewedJobID: 96_456_203_644,
            exactMainConclusion: "success",
            exactMainRootTestCount: 85,
            exactMainIsolatedTestCount: 6,
            exactMainFocusedWholeTestCount: 91,
            exactMainRetainedLiveTestCount: 46,
            exactMainAggregateTestCount: 137,
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-20T14:07:36Z",
            exactMainClosureEstablished: true),
        mechanicsSourceBindings: [
            .init(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                mechanicsGitStatus: "M", gitMode: "100755",
                gitBlob: "0ea5aefc1b5230f2719e5cc518b37d5e71d1b616",
                byteCount: 1_390_273, lfByteCount: 22_482,
                crByteCount: 0,
                sha256:
                    "affb0f018566539a855f7fbc66e8f189bcd8c215d0142960cfe4e3e196ec8085",
                role: "mechanics_gate"),
            .init(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                mechanicsGitStatus: "M", gitMode: "100644",
                gitBlob: "5998767711e6c841de0e7b4ee73fb68da2194554",
                byteCount: 173_732, lfByteCount: 741,
                crByteCount: 0,
                sha256:
                    "524cabec7a892b529ff50ce63428d76e882ebb24763562c64a6defddef51b1f9",
                role: "mechanics_workflow"),
            .init(
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                mechanicsGitStatus: "M", gitMode: "100644",
                gitBlob: "3fc893d5fc72455a933f74607b7ca1859e874ea6",
                byteCount: 546, lfByteCount: 13,
                crByteCount: 0,
                sha256:
                    "085ced5d5310f63fa47e609cb8ef2613fad45c3a77978665653658563b131886",
                role: "mechanics_provenance"),
            .init(
                path:
                    ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh",
                mechanicsGitStatus: "A", gitMode: "100755",
                gitBlob: "076e9dd60ed692689ebfe443b7911dd4acfe9bdc",
                byteCount: 72_908, lfByteCount: 1_468,
                crByteCount: 0,
                sha256:
                    "372a526f521a682d94e92733e15bfe2a2131426aefe8cc8809e35cd9e082b57c",
                role: "closed_bash_measurement_launcher"),
            .init(
                path:
                    "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift",
                mechanicsGitStatus: "A", gitMode: "100644",
                gitBlob: "ead815d5f051ed1308f360aa701a1a5d389556c6",
                byteCount: 16_967, lfByteCount: 473,
                crByteCount: 0,
                sha256:
                    "248ae56786dace0e7b19a9a82ee977b9a4fa705a63b9268e2ee058c180ddaa82",
                role: "standalone_swift_identity_evaluator"),
        ],
        mechanicsClosure: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            pullRequestNumber: 130,
            baseRevision: "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
            baseTree: "9b8a784e605967141f159a5f8c953a0096cf1f8d",
            reviewedHeadRevision:
                "f5db7101cf3538daae103ba56601a509ad8bad80",
            reviewedHeadTree:
                "9dd884bfe5b520a67c2944d8f8f79851a714519e",
            reviewedHeadOrderedParentRevisions: [
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
            ],
            mergeRevision: "5623872afda1895630ba0eacdfab76961c5e755b",
            mergeTree: "9dd884bfe5b520a67c2944d8f8f79851a714519e",
            orderedMergeParentRevisions: [
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
                "f5db7101cf3538daae103ba56601a509ad8bad80",
            ],
            mergeTreeEqualsReviewedHeadTree: true,
            historyPreservingTwoParentMergeObserved: true,
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-20T17:19:27Z",
            mergedAt: "2026-08-20T17:19:27Z",
            exactChangedPathCount: 5,
            changedManifestPathCount: 0,
            changedLockPathCount: 0,
            pullRequestRunID: 32_396_145_283,
            pullRequestRunNumber: 159,
            pullRequestRunAttempt: 1,
            pullRequestCheckSuiteID: 87_822_394_132,
            pullRequestConclusion: "success",
            pullRequestPreviousAttemptURL: nil,
            matchingPullRequestRunCountForHead: 1,
            pullRequestActiveJobID: 96_513_307_446,
            pullRequestActiveJobConclusion: "success",
            pullRequestReviewedJobID: 96_514_561_832,
            pullRequestReviewedJobConclusion: "skipped",
            pullRequestReviewedJobStepCount: 0,
            pullRequestArtifactCount: 0),
        workflowRun: .init(
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 32_396_967_956,
            runNumber: 160,
            runAttempt: 1,
            checkSuiteID: 87_824_712_564,
            event: "push",
            ref: "refs/heads/main",
            headSHA: "5623872afda1895630ba0eacdfab76961c5e755b",
            status: "completed",
            conclusion: "failure",
            createdAt: "2026-08-20T17:19:29Z",
            startedAt: "2026-08-20T17:19:29Z",
            updatedAt: "2026-08-20T18:10:40Z",
            previousAttemptURL: nil,
            matchingPushRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0,
            actionsArtifactCount: 0,
            runURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/32396967956"),
        activeRootJob: .init(
            jobID: 96_515_945_260,
            name: "First-party MLX / active-root quarantine",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-20T17:19:32Z",
            completedAt: "2026-08-20T17:24:01Z",
            steps: [
                step(1, "Set up job", "2026-08-20T17:19:32Z", "2026-08-20T17:19:32Z"),
                step(2, "Check out the exact Prime revision", "2026-08-20T17:19:32Z", "2026-08-20T17:19:36Z"),
                step(3, "Validate active metadata and preserved history", "2026-08-20T17:19:36Z", "2026-08-20T17:21:26Z"),
                step(4, "Parse the changed Swift contracts without dependencies", "2026-08-20T17:21:26Z", "2026-08-20T17:21:43Z"),
                step(5, "Validate isolated Latin capture and observation contracts", "2026-08-20T17:21:43Z", "2026-08-20T17:23:55Z"),
                step(6, "Record the authority ceiling", "2026-08-20T17:23:55Z", "2026-08-20T17:23:56Z"),
                step(7, "Complete job", "2026-08-20T17:23:56Z", "2026-08-20T17:23:59Z"),
            ]),
        activeRootConnectorDecodedJobLog: .init(
            jobID: 96_515_945_260,
            bindingKind: "connector_decoded_utf8_job_log",
            representation:
                "decoded_log_bytes_with_connector_utf8_bom_and_terminal_lf",
            byteCount: 353_434,
            lfByteCount: 1_909,
            crByteCount: 0,
            sha256:
                "458adafef5adfaa840c5b1b373f326bd4749c3e9465e4263f4ffd58c52a254dc",
            utf8BOMPresent: true,
            terminalLFPresent: true,
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        reviewedMainJob: .init(
            jobID: 96_517_280_624,
            name: "Reviewed main / focused source contracts",
            status: "completed",
            conclusion: "failure",
            startedAt: "2026-08-20T17:24:05Z",
            completedAt: "2026-08-20T18:10:39Z",
            steps: [
                step(1, "Set up job", "2026-08-20T17:24:05Z", "2026-08-20T17:24:05Z"),
                step(2, "Record the hosted Apple toolchain", "2026-08-20T17:24:05Z", "2026-08-20T17:24:10Z"),
                step(3, "Check out reviewed main exactly", "2026-08-20T17:24:10Z", "2026-08-20T17:24:15Z"),
                step(4, "Fetch the exact private dependency without evaluating Prime", "2026-08-20T17:24:15Z", "2026-08-20T17:24:27Z"),
                step(5, "Compile and run the focused contracts without a credential", "2026-08-20T17:24:27Z", "2026-08-20T17:48:10Z"),
                step(6, "Run the Prime-owned decoder on live Metal", "2026-08-20T17:48:10Z", "2026-08-20T18:10:23Z"),
                step(7, "Measure the native validation-fixture identity once", "2026-08-20T18:10:23Z", "2026-08-20T18:10:26Z", conclusion: "failure"),
                step(8, "Complete job", "2026-08-20T18:10:26Z", "2026-08-20T18:10:29Z"),
            ]),
        reviewedMainConnectorDecodedJobLog: .init(
            jobID: 96_517_280_624,
            bindingKind: "connector_decoded_utf8_job_log",
            representation:
                "decoded_log_bytes_with_connector_utf8_bom_and_terminal_lf",
            byteCount: 10_339_505,
            lfByteCount: 79_061,
            crByteCount: 0,
            sha256:
                "31fd2e9de6472f2e820acbd85ed0b44c994256e825f7a5372abfbbb9809ff633",
            utf8BOMPresent: true,
            terminalLFPresent: true,
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        sanitizedToolchainObservation: .init(
            sourceJobID: 96_517_280_624,
            sourceStepNumber: 2,
            sourceStepName: "Record the hosted Apple toolchain",
            sourceStepConclusion: "success",
            sourceStepStartedAt: "2026-08-20T17:24:05Z",
            sourceStepCompletedAt: "2026-08-20T17:24:10Z",
            architecture: "arm64",
            productName: "macOS",
            productVersion: "26.5.2",
            buildVersion: "25F84",
            xcodeVersion: "26.6",
            xcodeBuildVersion: "17F113",
            swiftVersion:
                "Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)",
            swiftTarget: "arm64-apple-macosx26.0",
            swiftDriverVersionLine: "swift-driver version: 1.148.6 ",
            sdkVersion: "26.5",
            eachExactSanitizedLineOccurrenceCount: 1,
            orderedRawSanitizedBlock:
                "arm64\nProductName:\t\tmacOS\nProductVersion:\t\t26.5.2\nBuildVersion:\t\t25F84\nXcode 26.6\nBuild version 17F113\nApple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)\nTarget: arm64-apple-macosx26.0\n26.5\nswift-driver version: 1.148.6 \n",
            rawSanitizedBlockByteCount: 237,
            rawSanitizedBlockLFByteCount: 10,
            rawSanitizedBlockSHA256:
                "1427ae05f58467e5c1f0f967405f022288d75d6e12b5382416e463d4ecf17e54"),
        testAndOperationalObservation: .init(
            activeLatinTestCount: 116,
            activeLatinFailureCount: 0,
            activeLatinSkipCount: 0,
            rootTestCount: 85,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 91,
            retainedMetalTestCount: 44,
            retainedMaintainedRuntimeTestCount: 1,
            retainedTokenizerTestCount: 1,
            retainedLiveTestCount: 46,
            aggregateTestCount: 137,
            xctestFailureCount: 0,
            xctestSkipCount: 0,
            measurementLauncherInvocationCount: 1,
            measurementStepFixtureProductBuildCommandAttemptCount: 0,
            measurementStepShowBinPathCommandAttemptCount: 0,
            measurementStepEvaluatorCompilerInvocationCount: 0,
            measurementStepEvaluatorInvocationCount: 0,
            measurementStepFixtureExecutionCount: 0,
            measurementStepAdapterExecutionCount: 0,
            measurementStepLeaseAcquisitionCount: 0,
            measurementStepModelExecutionCount: 0,
            measurementStepMLXExecutionCount: 0,
            measurementStepMetalExecutionCount: 0,
            measurementStepPythonInvocationCount: 0,
            measurementStepCppInvocationCount: 0),
        hostedRecordIdentity: .init(
            prefix:
                "prime-secure-child validation-fixture-identity measurement: ",
            prefixByteCount: 60,
            canonicalJSONByteCount: 1_682,
            canonicalJSONSHA256:
                "f90db08bab2216053fd4bc9cc4c1439da81fc0f3b3c62dccd9c06ed454591dd8",
            totalLineByteCountIncludingTerminalLF: 1_743,
            totalLineSHA256IncludingTerminalLF:
                "4da4a0ca7e0e2b2e09f96a9c1717faf632499e687b30e589c3c0339712fa27d0",
            exactOccurrenceCount: 1,
            exactFieldCount: 43,
            emittedAt: "2026-08-20T18:10:26.4744800Z",
            physicalTimestampedLineReconstruction:
                "emitted_at_then_one_ascii_space_then_prefix_then_canonical_json_then_one_lf",
            physicalTimestampedLineByteCountIncludingTerminalLF: 1_772,
            physicalTimestampedLineSHA256IncludingTerminalLF:
                "36ec9a6daebeea2b80c88c9667b6c0ade1fac3a0c24b763c825eb0707fce6447",
            reviewedDecodedLogPhysicalLineNumber: 79_059,
            workflowConclusionMatchesResultInvariant: true,
            acceptingRecord: true,
            record: .init(
                actionsArtifact: false,
                authorityCanonicalSHA256:
                    "67ad7808b54314b7dcd70a86b5504e7321c4c348a0ecb2ec172d5b72ee3f6d43",
                authorityID:
                    "ergentics_prime_secure_child_validation_fixture_identity_measurement_authority_v1",
                buildACommandState: "not_attempted",
                buildBCommandState: "not_attempted",
                byteCountEqual: "unavailable",
                canaryExecutionPerformed: false,
                currentPinByteCountMatch: "unavailable",
                currentPinFullMatch: "unavailable",
                currentPinSHA256Match: "unavailable",
                durableEvidence: false,
                evaluatorCommandState: "not_attempted",
                evaluatorCompileState: "not_attempted",
                evaluatorExecutionObservation: "observed_false",
                evaluatorShellWaitStatus: nil,
                exactRevision:
                    "5623872afda1895630ba0eacdfab76961c5e755b",
                fixtureABuildPlatformPacked: nil,
                fixtureAByteCount: nil,
                fixtureAMachOUUID: nil,
                fixtureAMinimumOSPpacked: nil,
                fixtureASDKPacked: nil,
                fixtureASHA256: nil,
                fixtureBBuildPlatformPacked: nil,
                fixtureBByteCount: nil,
                fixtureBMachOUUID: nil,
                fixtureBMinimumOSPpacked: nil,
                fixtureBSDKPacked: nil,
                fixtureBSHA256: nil,
                fixtureExecutionCount: 0,
                fullBytesEqual: "unavailable",
                machoIdentityEqual: "unavailable",
                measurementAttemptConsumed: false,
                opportunityState: "retired",
                pinMutationPerformed: false,
                rawBuildOutputOrErrorFieldCount: 0,
                rawPathCount: 0,
                resultCode: "INVOCATION_ADMISSION_REFUSED",
                schemaID:
                    "prime_secure_child_validation_fixture_identity_measurement_outer_observation_v1",
                schemaVersion: 1,
                scientificOutcome: "not_established",
                sha256Equal: "unavailable",
                showBinACommandState: "not_attempted",
                showBinBCommandState: "not_attempted")),
        invocationRefusalInference: .init(
            resultCode: "INVOCATION_ADMISSION_REFUSED",
            hostedRecordPublishesFailedPredicate: false,
            sanitizedReviewedLogPublishesFailedPredicate: false,
            failureCauseDirectlyEstablished: false,
            classification:
                "source_and_checkout_depth_semantics_inference_not_direct_hosted_observation",
            likelyCause:
                "depth_two_exact_main_checkout_left_the_mechanics_head_first_parent_edge_unavailable_to_the_launcher_revision_second_parent_first_parent_check",
            inferenceBasis: [
                "workflow_fetch_used_depth_two_for_exact_merge_revision",
                "workflow_explicit_proof_only_wants_included_75b14056_but_not_fe0ad36_or_f5db710",
                "launcher_required_exact_revision_second_parent_first_parent_equal_fe0ad36",
                "record_stopped_at_INVOCATION_ADMISSION_REFUSED_before_attempt_consumption",
                "record_and_sanitized_log_did_not_publish_the_specific_failed_predicate",
            ],
            checkoutFetchDepth: 2,
            exactRevision: "5623872afda1895630ba0eacdfab76961c5e755b",
            mechanicsSecondParentRevision:
                "f5db7101cf3538daae103ba56601a509ad8bad80",
            authorityClosureRevision:
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
            launcherRequiredRevisionExpression: "exact_revision^2^1",
            launcherRequiredExpressionExpectedRevision:
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
            launcherSourceLine: 765,
            authorityClosureWasExplicitProofOnlyWant: false,
            mechanicsHeadWasExplicitProofOnlyWant: false,
            inferenceAuthorizesRepairRetryRerunOrReplacement: false),
        resultDispositions: [
            disposition("PASS_IDENTICAL_CURRENT_PIN", "success", "identical_current_pin", confirmation: true),
            disposition("PASS_IDENTICAL_DIFFERENT_PIN", "success", "identical_different_pin", confirmation: true, pinRepair: true),
            disposition("NONDETERMINISTIC_BUILD", "failure", "nondeterministic"),
            disposition("INVOCATION_ADMISSION_REFUSED", "failure", "invocation_admission_refusal"),
            disposition("MEASUREMENT_ROOT_REFUSED", "failure", "admission_refusal"),
            disposition("SOURCE_ROOT_REFUSED", "failure", "admission_refusal"),
            disposition("BUILD_ROOT_REFUSED", "failure", "admission_refusal"),
            disposition("MIRROR_REFUSED", "failure", "admission_refusal"),
            disposition("BUILD_A_REFUSED", "failure", "build_refusal"),
            disposition("SHOW_BIN_A_REFUSED", "failure", "build_refusal"),
            disposition("SHOW_BIN_A_TRANSPORT_REFUSED", "failure", "transport_refusal"),
            disposition("ARTIFACT_A_ADMISSION_REFUSED", "failure", "admission_refusal"),
            disposition("BUILD_B_REFUSED", "failure", "build_refusal"),
            disposition("SHOW_BIN_B_REFUSED", "failure", "build_refusal"),
            disposition("SHOW_BIN_B_TRANSPORT_REFUSED", "failure", "transport_refusal"),
            disposition("ARTIFACT_B_ADMISSION_REFUSED", "failure", "admission_refusal"),
            disposition("EVALUATOR_ROOT_REFUSED", "failure", "evaluator_refusal"),
            disposition("EVALUATOR_SOURCE_REFUSED", "failure", "evaluator_refusal"),
            disposition("EVALUATOR_COMPILE_REFUSED", "failure", "evaluator_refusal"),
            disposition("EVALUATOR_ADMISSION_REFUSED", "failure", "evaluator_refusal"),
            disposition("EVALUATOR_TRANSPORT_REFUSED", "failure", "transport_refusal"),
            disposition("EVALUATOR_COMMAND_REFUSED", "failure", "evaluator_refusal"),
            disposition("EVALUATOR_CONTRACT_REFUSED", "failure", "evaluator_refusal"),
            disposition("CAPTURE_REFUSED", "failure", "capture_refusal"),
            disposition("UNCLASSIFIED", "failure", "fail_closed_pre_command_refusal"),
        ],
        absentOrExternallyTerminatedRecordContract: .init(
            externallyTerminatedRecordCardinality: "zero_or_one",
            launcherNotReachedRecordCount: 0,
            orderedPermittedClassifications: [
                "launcher_not_reached",
                "external_timeout_or_cancellation_after_launcher_start_only_when_actions_or_log_proves_it",
                "abrupt_process_host_or_runner_termination_only_when_actions_or_log_proves_it",
                "record_absent_cause_not_further_established",
            ],
            causeMustNotBeInventedBeyondActionsAndSanitizedLog: true,
            attemptConsumptionWithoutSeparateProof: "unavailable",
            measurementEstablished: false,
            fixtureIdentityEstablished: false,
            repeatBuildDeterminismEstablished: false,
            currentPinComparisonEstablished: false,
            presentRecordUnderCancelledTimedOutOrNonmatchingConclusionAccepting:
                false,
            opportunityRetired: true,
            retryAuthorized: false,
            rerunAuthorized: false,
            replacementMeasurementAuthorized: false),
        outcomeBoundary: .init(
            resultCode: "INVOCATION_ADMISSION_REFUSED",
            classification:
                "launcher_controlled_invocation_admission_refusal_before_measurement_attempt_consumption",
            launcherControlledTerminalRecordEstablished: true,
            hostedRecordIntegrityEstablished: true,
            workflowFailureEstablished: true,
            measurementAttemptConsumed: false,
            fixtureIdentityEstablished: false,
            repeatBuildDeterminismEstablished: false,
            currentPinByteCountMatchEstablished: false,
            currentPinSHA256MatchEstablished: false,
            currentPinFullMatchEstablished: false,
            fixtureExecutionCount: 0,
            scientificOutcome: "not_established",
            durableEvidenceEstablished: false,
            actionsArtifactCount: 0,
            opportunityState: "retired",
            noRerunProof: [
                "workflow_run_attempt_equals_one",
                "previous_attempt_url_is_null",
                "matching_push_run_count_for_exact_head_equals_one",
                "retry_count_equals_zero",
                "rerun_count_equals_zero",
                "authority_forbids_automatic_retry_workflow_rerun_and_replacement_measurement",
            ]),
        retirementBoundary: .init(
            retirementRequired: true,
            retirementObserved: false,
            exactOrderedChangedPaths: [
                .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitStatus: "M", gitMode: "100755", role: "remove_live_measurement_admission_and_freeze_observation_retirement"),
                .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitStatus: "M", gitMode: "100644", role: "remove_measurement_step_restore_reviewed_timeout_and_append_terminal_summary"),
                .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitStatus: "M", gitMode: "100644", role: "regenerate_embedded_provenance_for_exact_retirement_tree"),
                .init(ordinal: 4, path: "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservation.swift", gitStatus: "A", gitMode: "100644", role: "append_only_terminal_outcome_observation"),
                .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationTests.swift", gitStatus: "A", gitMode: "100644", role: "sole_pure_exhaustive_observation_test"),
            ],
            exactChangedPathCount: 5,
            reviewedTimeoutBeforeMinutes: 90,
            reviewedTimeoutAfterMinutes: 75,
            activeTimeoutMinutes: 45,
            expectedActiveLatinTestCount: 116,
            expectedRootTestCount: 86,
            expectedIsolatedGroupTestCounts: [1, 1, 2, 2],
            expectedIsolatedTestCount: 6,
            expectedFocusedWholeTestCount: 92,
            expectedRetainedLiveTestCount: 46,
            expectedAggregateTestCount: 138,
            expectedEmbeddedProvenanceRecordCount: 524,
            expectedMeasurementWorkflowStepCount: 0,
            expectedLauncherWorkflowReferenceCount: 0,
            expectedLauncherInvocationCount: 0,
            expectedEvaluatorInvocationCount: 0,
            expectedHostedRecordCount: 0,
            launcherSourcePreservedForAudit: true,
            evaluatorSourcePreservedForAudit: true,
            launcherSource: .init(
                path:
                    ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh",
                mechanicsGitStatus: "A",
                gitMode: "100755",
                gitBlob: "076e9dd60ed692689ebfe443b7911dd4acfe9bdc",
                byteCount: 72_908,
                lfByteCount: 1_468,
                crByteCount: 0,
                sha256:
                    "372a526f521a682d94e92733e15bfe2a2131426aefe8cc8809e35cd9e082b57c",
                role: "closed_bash_measurement_launcher"),
            evaluatorSource: .init(
                path:
                    "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift",
                mechanicsGitStatus: "A",
                gitMode: "100644",
                gitBlob: "ead815d5f051ed1308f360aa701a1a5d389556c6",
                byteCount: 16_967,
                lfByteCount: 473,
                crByteCount: 0,
                sha256:
                    "248ae56786dace0e7b19a9a82ee977b9a4fa705a63b9268e2ee058c180ddaa82",
                role: "standalone_swift_identity_evaluator"),
            sourceParserMayRetainEvaluatorPathWithoutInvokingIt: true,
            measurementOpportunityRetired: true,
            exactMainRetirementClosureRequired: true,
            retryWithoutNewAuthorityPermitted: false,
            rerunPermitted: false,
            replacementMeasurementPermitted: false),
        authorityCeiling: .init(
            measurementAuthorityExactMainGreenEstablished: true,
            mechanicsExactMainClosureEstablished: true,
            exactHostedRecordIntegrityEstablished: true,
            invocationAdmissionRefusalEstablished: true,
            likelyRefusalCauseIsInferenceOnly: true,
            measurementOpportunityRetired: true,
            exactRetirementRequired: true,
            sanitizedToolchainObservationEstablished: true,
            reviewedJobLogIdentityEstablished: true,
            workflowFailureEstablished: true,
            currentPatchAddsOnlyPureObservationPair: true,
            filesystemReadAuthorizedByObservationValue: false,
            filesystemWriteAuthorizedByObservationValue: false,
            compilerInvocationAuthorized: false,
            evaluatorInvocationAuthorized: false,
            fixtureBuildAuthorized: false,
            fixtureExecutionAuthorized: false,
            adapterExecutionAuthorized: false,
            leaseAcquisitionAuthorized: false,
            modelExecutionAuthorized: false,
            networkAuthorized: false,
            measurementAttemptConsumed: false,
            measuredFixtureIdentityEstablished: false,
            repeatBuildDeterminismEstablished: false,
            currentPinMatchEstablished: false,
            currentPinMismatchEstablished: false,
            fixturePinMutationAuthorized: false,
            fixturePinMutationPerformed: false,
            pinRepairAuthorityEstablished: false,
            confirmationMeasurementAuthorized: false,
            monitorHeldLeaseCanaryAuthorized: false,
            monitorHeldLeaseCanaryPerformed: false,
            durableEvidenceEstablished: false,
            childLifetimeContinuityEstablished: false,
            physicalMetalReservationEstablished: false,
            mlxDeviceIdentityEstablished: false,
            mlxExecutionAuthorized: false,
            metalExecutionAuthorized: false,
            native300MExecutionAuthorized: false,
            pythonAuthorized: false,
            cppAuthorized: false,
            checkpointAdmissionGranted: false,
            generalTrainingResumeAuthorized: false,
            modelQualityEstablished: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            retryAuthorized: false,
            rerunAuthorized: false,
            replacementMeasurementAuthorized: false),
        orderedRequiredSeparateActions: [
            "merge_exact_five_path_append_only_observation_and_irreversible_retirement_without_invoking_measurement",
            "establish_exact_main_retirement_closure_with_launcher_workflow_reference_and_invocation_count_zero",
            "stop_without_pin_repair_or_confirmation_because_run160_was_a_refusal_outcome",
            "do_not_retry_rerun_replace_or_repair_the_retired_measurement_opportunity",
            "separately_authorize_any_future_measurement_only_through_a_new_full_authority_not_this_observation",
            "do_not_authorize_monitor_held_lease_canary_or_durable_layer_b_from_this_refusal",
        ],
        status:
            "INVOCATION_ADMISSION_REFUSED_exact_main_run160_valid_record_attempt_unconsumed_fixture_identity_determinism_and_pin_relationship_unavailable_opportunity_retired_no_retry_rerun_replacement_repair_confirmation_or_canary")

    private static func step(
        _ number: Int,
        _ name: String,
        _ startedAt: String,
        _ completedAt: String,
        conclusion: String = "success"
    ) -> Step {
        .init(
            number: number,
            name: name,
            status: "completed",
            conclusion: conclusion,
            startedAt: startedAt,
            completedAt: completedAt)
    }

    private static func disposition(
        _ resultCode: String,
        _ workflowConclusion: String,
        _ category: String,
        confirmation: Bool = false,
        pinRepair: Bool = false
    ) -> OutcomeDisposition {
        .init(
            resultCode: resultCode,
            workflowConclusion: workflowConclusion,
            category: category,
            separateNoMutationConfirmationAuthorityEligible: confirmation,
            separatePinRepairAuthorityEligible: pinRepair,
            canaryDirectlyAuthorized: false)
    }

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 131_072 else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationError
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
            PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityV1
                .frozenV1
        try authority.validateExactV1()

        let record = hostedRecordIdentity.record
        let recordData = try record.canonicalData()
        var recordLine = Data(hostedRecordIdentity.prefix.utf8)
        recordLine.append(recordData)
        recordLine.append(0x0A)
        var physicalRecordLine = Data(hostedRecordIdentity.emittedAt.utf8)
        physicalRecordLine.append(0x20)
        physicalRecordLine.append(recordLine)
        let toolchainData = Data(
            sanitizedToolchainObservation.orderedRawSanitizedBlock.utf8)
        let canonical = try canonicalData()
        let falseCeilings = [
            authorityCeiling.filesystemReadAuthorizedByObservationValue,
            authorityCeiling.filesystemWriteAuthorizedByObservationValue,
            authorityCeiling.compilerInvocationAuthorized,
            authorityCeiling.evaluatorInvocationAuthorized,
            authorityCeiling.fixtureBuildAuthorized,
            authorityCeiling.fixtureExecutionAuthorized,
            authorityCeiling.adapterExecutionAuthorized,
            authorityCeiling.leaseAcquisitionAuthorized,
            authorityCeiling.modelExecutionAuthorized,
            authorityCeiling.networkAuthorized,
            authorityCeiling.measurementAttemptConsumed,
            authorityCeiling.measuredFixtureIdentityEstablished,
            authorityCeiling.repeatBuildDeterminismEstablished,
            authorityCeiling.currentPinMatchEstablished,
            authorityCeiling.currentPinMismatchEstablished,
            authorityCeiling.fixturePinMutationAuthorized,
            authorityCeiling.fixturePinMutationPerformed,
            authorityCeiling.pinRepairAuthorityEstablished,
            authorityCeiling.confirmationMeasurementAuthorized,
            authorityCeiling.monitorHeldLeaseCanaryAuthorized,
            authorityCeiling.monitorHeldLeaseCanaryPerformed,
            authorityCeiling.durableEvidenceEstablished,
            authorityCeiling.childLifetimeContinuityEstablished,
            authorityCeiling.physicalMetalReservationEstablished,
            authorityCeiling.mlxDeviceIdentityEstablished,
            authorityCeiling.mlxExecutionAuthorized,
            authorityCeiling.metalExecutionAuthorized,
            authorityCeiling.native300MExecutionAuthorized,
            authorityCeiling.pythonAuthorized,
            authorityCeiling.cppAuthorized,
            authorityCeiling.checkpointAdmissionGranted,
            authorityCeiling.generalTrainingResumeAuthorized,
            authorityCeiling.modelQualityEstablished,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
            authorityCeiling.retryAuthorized,
            authorityCeiling.rerunAuthorized,
            authorityCeiling.replacementMeasurementAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              schemaID == observationID,
              authorityClosure.authorityID == authority.authorityID,
              authorityClosure.canonicalByteCount
                == type(of: authority).canonicalByteCount,
              authorityClosure.canonicalSHA256
                == type(of: authority).canonicalSHA256,
              authorityClosure.orderedParentRevisions.count == 2,
              authorityClosure.exactMainConclusion == "success",
              authorityClosure.exactMainRootTestCount
                + authorityClosure.exactMainIsolatedTestCount
                == authorityClosure.exactMainFocusedWholeTestCount,
              authorityClosure.exactMainFocusedWholeTestCount
                + authorityClosure.exactMainRetainedLiveTestCount
                == authorityClosure.exactMainAggregateTestCount,
              authorityClosure.githubSignatureVerified,
              authorityClosure.githubSignatureReason == "valid",
              authorityClosure.exactMainClosureEstablished,
              mechanicsSourceBindings.count == 5,
              Set(mechanicsSourceBindings.map(\.path)).count == 5,
              mechanicsSourceBindings.map(\.mechanicsGitStatus)
                == ["M", "M", "M", "A", "A"],
              mechanicsSourceBindings.map(\.gitMode)
                == ["100755", "100644", "100644", "100755", "100644"],
              mechanicsSourceBindings.allSatisfy({
                  $0.gitBlob.utf8.count == 40
                      && $0.sha256.utf8.count == 64
                      && $0.byteCount > 0
                      && $0.lfByteCount > 0
                      && $0.crByteCount == 0
              }),
              mechanicsClosure.baseRevision == authorityClosure.mergeRevision,
              mechanicsClosure.reviewedHeadOrderedParentRevisions
                == [mechanicsClosure.baseRevision],
              mechanicsClosure.mergeTree
                == mechanicsClosure.reviewedHeadTree,
              mechanicsClosure.orderedMergeParentRevisions
                == [
                    mechanicsClosure.baseRevision,
                    mechanicsClosure.reviewedHeadRevision,
                ],
              mechanicsClosure.mergeTreeEqualsReviewedHeadTree,
              mechanicsClosure.historyPreservingTwoParentMergeObserved,
              mechanicsClosure.githubSignatureVerified,
              mechanicsClosure.githubSignatureReason == "valid",
              mechanicsClosure.exactChangedPathCount == 5,
              mechanicsClosure.changedManifestPathCount == 0,
              mechanicsClosure.changedLockPathCount == 0,
              mechanicsClosure.pullRequestRunAttempt == 1,
              mechanicsClosure.pullRequestConclusion == "success",
              mechanicsClosure.pullRequestPreviousAttemptURL == nil,
              mechanicsClosure.matchingPullRequestRunCountForHead == 1,
              mechanicsClosure.pullRequestActiveJobConclusion == "success",
              mechanicsClosure.pullRequestReviewedJobConclusion == "skipped",
              mechanicsClosure.pullRequestReviewedJobStepCount == 0,
              mechanicsClosure.pullRequestArtifactCount == 0,
              workflowRun.runAttempt == 1,
              workflowRun.headSHA == mechanicsClosure.mergeRevision,
              workflowRun.status == "completed",
              workflowRun.conclusion == "failure",
              workflowRun.previousAttemptURL == nil,
              workflowRun.matchingPushRunCountForHead == 1,
              workflowRun.retryCount == 0,
              workflowRun.rerunCount == 0,
              workflowRun.actionsArtifactCount == 0,
              activeRootJob.jobID
                == activeRootConnectorDecodedJobLog.jobID,
              activeRootJob.conclusion == "success",
              activeRootJob.steps.count == 7,
              activeRootJob.steps.map(\.number) == Array(1 ... 7),
              activeRootJob.steps.allSatisfy({
                  $0.status == "completed" && $0.conclusion == "success"
              }),
              reviewedMainJob.jobID
                == reviewedMainConnectorDecodedJobLog.jobID,
              reviewedMainJob.conclusion == "failure",
              reviewedMainJob.steps.count == 8,
              reviewedMainJob.steps.map(\.number) == Array(1 ... 8),
              reviewedMainJob.steps.filter({ $0.conclusion == "failure" })
                .map(\.number) == [7],
              reviewedMainJob.steps[6].name
                == "Measure the native validation-fixture identity once",
              activeRootConnectorDecodedJobLog.crByteCount == 0,
              activeRootConnectorDecodedJobLog.utf8BOMPresent,
              activeRootConnectorDecodedJobLog.terminalLFPresent,
              activeRootConnectorDecodedJobLog.repeatFetchExactlyEqual,
              !activeRootConnectorDecodedJobLog.rawArchiveBytesBound,
              !activeRootConnectorDecodedJobLog.rawArchiveRetained,
              reviewedMainConnectorDecodedJobLog.crByteCount == 0,
              reviewedMainConnectorDecodedJobLog.utf8BOMPresent,
              reviewedMainConnectorDecodedJobLog.terminalLFPresent,
              reviewedMainConnectorDecodedJobLog.repeatFetchExactlyEqual,
              !reviewedMainConnectorDecodedJobLog.rawArchiveBytesBound,
              !reviewedMainConnectorDecodedJobLog.rawArchiveRetained,
              sanitizedToolchainObservation.sourceJobID
                == reviewedMainJob.jobID,
              sanitizedToolchainObservation.sourceStepNumber == 2,
              sanitizedToolchainObservation.sourceStepConclusion == "success",
              sanitizedToolchainObservation
                .eachExactSanitizedLineOccurrenceCount == 1,
              toolchainData.count
                == sanitizedToolchainObservation.rawSanitizedBlockByteCount,
              sanitizedToolchainObservation.orderedRawSanitizedBlock
                .utf8.filter({ $0 == 0x0A }).count
                == sanitizedToolchainObservation.rawSanitizedBlockLFByteCount,
              PrimeSHA256.hexDigest(of: toolchainData)
                == sanitizedToolchainObservation.rawSanitizedBlockSHA256,
              testAndOperationalObservation.rootTestCount
                + testAndOperationalObservation.isolatedTestCount
                == testAndOperationalObservation.focusedWholeTestCount,
              testAndOperationalObservation.focusedWholeTestCount
                + testAndOperationalObservation.retainedLiveTestCount
                == testAndOperationalObservation.aggregateTestCount,
              testAndOperationalObservation.isolatedGroupTestCounts
                .reduce(0, +)
                == testAndOperationalObservation.isolatedTestCount,
              testAndOperationalObservation.retainedMetalTestCount
                + testAndOperationalObservation
                    .retainedMaintainedRuntimeTestCount
                + testAndOperationalObservation.retainedTokenizerTestCount
                == testAndOperationalObservation.retainedLiveTestCount,
              testAndOperationalObservation.xctestFailureCount == 0,
              testAndOperationalObservation.xctestSkipCount == 0,
              testAndOperationalObservation.measurementLauncherInvocationCount
                == 1,
              testAndOperationalObservation
                .measurementStepFixtureProductBuildCommandAttemptCount
                == 0,
              testAndOperationalObservation
                .measurementStepShowBinPathCommandAttemptCount == 0,
              testAndOperationalObservation
                .measurementStepEvaluatorCompilerInvocationCount
                == 0,
              testAndOperationalObservation
                .measurementStepEvaluatorInvocationCount == 0,
              testAndOperationalObservation
                .measurementStepFixtureExecutionCount == 0,
              testAndOperationalObservation
                .measurementStepAdapterExecutionCount == 0,
              testAndOperationalObservation
                .measurementStepLeaseAcquisitionCount == 0,
              testAndOperationalObservation
                .measurementStepModelExecutionCount == 0,
              testAndOperationalObservation
                .measurementStepMLXExecutionCount == 0,
              testAndOperationalObservation
                .measurementStepMetalExecutionCount == 0,
              testAndOperationalObservation
                .measurementStepPythonInvocationCount == 0,
              testAndOperationalObservation
                .measurementStepCppInvocationCount == 0,
              hostedRecordIdentity.prefix.utf8.count
                == hostedRecordIdentity.prefixByteCount,
              hostedRecordIdentity.exactOccurrenceCount == 1,
              hostedRecordIdentity.exactFieldCount == 43,
              hostedRecordIdentity.workflowConclusionMatchesResultInvariant,
              hostedRecordIdentity.acceptingRecord,
              recordData.count == hostedRecordIdentity.canonicalJSONByteCount,
              PrimeSHA256.hexDigest(of: recordData)
                == hostedRecordIdentity.canonicalJSONSHA256,
              recordLine.count
                == hostedRecordIdentity.totalLineByteCountIncludingTerminalLF,
              PrimeSHA256.hexDigest(of: recordLine)
                == hostedRecordIdentity.totalLineSHA256IncludingTerminalLF,
              hostedRecordIdentity.physicalTimestampedLineReconstruction
                == "emitted_at_then_one_ascii_space_then_prefix_then_canonical_json_then_one_lf",
              physicalRecordLine.count
                == hostedRecordIdentity
                    .physicalTimestampedLineByteCountIncludingTerminalLF,
              PrimeSHA256.hexDigest(of: physicalRecordLine)
                == hostedRecordIdentity
                    .physicalTimestampedLineSHA256IncludingTerminalLF,
              hostedRecordIdentity.reviewedDecodedLogPhysicalLineNumber
                == reviewedMainConnectorDecodedJobLog.lfByteCount - 2,
              record.authorityCanonicalSHA256
                == authorityClosure.canonicalSHA256,
              record.authorityID == authorityClosure.authorityID,
              record.exactRevision == workflowRun.headSHA,
              record.resultCode == "INVOCATION_ADMISSION_REFUSED",
              record.schemaVersion == 1,
              record.buildACommandState == "not_attempted",
              record.showBinACommandState == "not_attempted",
              record.buildBCommandState == "not_attempted",
              record.showBinBCommandState == "not_attempted",
              record.evaluatorCompileState == "not_attempted",
              record.evaluatorCommandState == "not_attempted",
              record.evaluatorExecutionObservation == "observed_false",
              record.evaluatorShellWaitStatus == nil,
              record.fixtureAByteCount == nil,
              record.fixtureASHA256 == nil,
              record.fixtureAMachOUUID == nil,
              record.fixtureABuildPlatformPacked == nil,
              record.fixtureAMinimumOSPpacked == nil,
              record.fixtureASDKPacked == nil,
              record.fixtureBByteCount == nil,
              record.fixtureBSHA256 == nil,
              record.fixtureBMachOUUID == nil,
              record.fixtureBBuildPlatformPacked == nil,
              record.fixtureBMinimumOSPpacked == nil,
              record.fixtureBSDKPacked == nil,
              record.byteCountEqual == "unavailable",
              record.sha256Equal == "unavailable",
              record.fullBytesEqual == "unavailable",
              record.machoIdentityEqual == "unavailable",
              record.currentPinByteCountMatch == "unavailable",
              record.currentPinSHA256Match == "unavailable",
              record.currentPinFullMatch == "unavailable",
              !record.measurementAttemptConsumed,
              record.opportunityState == "retired",
              record.fixtureExecutionCount == 0,
              record.rawPathCount == 0,
              record.rawBuildOutputOrErrorFieldCount == 0,
              record.scientificOutcome == "not_established",
              !record.actionsArtifact,
              !record.durableEvidence,
              !record.pinMutationPerformed,
              !record.canaryExecutionPerformed,
              invocationRefusalInference.resultCode == record.resultCode,
              !invocationRefusalInference
                .hostedRecordPublishesFailedPredicate,
              !invocationRefusalInference
                .sanitizedReviewedLogPublishesFailedPredicate,
              !invocationRefusalInference.failureCauseDirectlyEstablished,
              invocationRefusalInference.checkoutFetchDepth == 2,
              invocationRefusalInference.exactRevision == workflowRun.headSHA,
              invocationRefusalInference.mechanicsSecondParentRevision
                == mechanicsClosure.reviewedHeadRevision,
              invocationRefusalInference.authorityClosureRevision
                == authorityClosure.mergeRevision,
              invocationRefusalInference
                .launcherRequiredExpressionExpectedRevision
                == authorityClosure.mergeRevision,
              !invocationRefusalInference
                .inferenceAuthorizesRepairRetryRerunOrReplacement,
              resultDispositions.count == 25,
              Set(resultDispositions.map(\.resultCode)).count == 25,
              resultDispositions.map(\.resultCode)
                == authority.futureMeasurementContract.hostedRecord
                    .exactResultCodes,
              resultDispositions.prefix(2).allSatisfy({
                  $0.workflowConclusion == "success"
                      && $0.separateNoMutationConfirmationAuthorityEligible
                      && !$0.canaryDirectlyAuthorized
              }),
              resultDispositions[1].separatePinRepairAuthorityEligible,
              !resultDispositions[0].separatePinRepairAuthorityEligible,
              resultDispositions.dropFirst(2).allSatisfy({
                  $0.workflowConclusion == "failure"
                      && !$0.separateNoMutationConfirmationAuthorityEligible
                      && !$0.separatePinRepairAuthorityEligible
                      && !$0.canaryDirectlyAuthorized
              }),
              absentOrExternallyTerminatedRecordContract
                .externallyTerminatedRecordCardinality == "zero_or_one",
              absentOrExternallyTerminatedRecordContract
                .launcherNotReachedRecordCount == 0,
              absentOrExternallyTerminatedRecordContract
                .causeMustNotBeInventedBeyondActionsAndSanitizedLog,
              absentOrExternallyTerminatedRecordContract
                .attemptConsumptionWithoutSeparateProof == "unavailable",
              !absentOrExternallyTerminatedRecordContract
                .measurementEstablished,
              !absentOrExternallyTerminatedRecordContract
                .fixtureIdentityEstablished,
              !absentOrExternallyTerminatedRecordContract
                .repeatBuildDeterminismEstablished,
              !absentOrExternallyTerminatedRecordContract
                .currentPinComparisonEstablished,
              !absentOrExternallyTerminatedRecordContract
                .presentRecordUnderCancelledTimedOutOrNonmatchingConclusionAccepting,
              absentOrExternallyTerminatedRecordContract.opportunityRetired,
              !absentOrExternallyTerminatedRecordContract.retryAuthorized,
              !absentOrExternallyTerminatedRecordContract.rerunAuthorized,
              !absentOrExternallyTerminatedRecordContract
                .replacementMeasurementAuthorized,
              outcomeBoundary.resultCode == record.resultCode,
              outcomeBoundary.launcherControlledTerminalRecordEstablished,
              outcomeBoundary.hostedRecordIntegrityEstablished,
              outcomeBoundary.workflowFailureEstablished,
              !outcomeBoundary.measurementAttemptConsumed,
              !outcomeBoundary.fixtureIdentityEstablished,
              !outcomeBoundary.repeatBuildDeterminismEstablished,
              !outcomeBoundary.currentPinByteCountMatchEstablished,
              !outcomeBoundary.currentPinSHA256MatchEstablished,
              !outcomeBoundary.currentPinFullMatchEstablished,
              outcomeBoundary.fixtureExecutionCount == 0,
              outcomeBoundary.scientificOutcome == "not_established",
              !outcomeBoundary.durableEvidenceEstablished,
              outcomeBoundary.actionsArtifactCount == 0,
              outcomeBoundary.opportunityState == "retired",
              outcomeBoundary.noRerunProof.count == 6,
              retirementBoundary.retirementRequired,
              !retirementBoundary.retirementObserved,
              retirementBoundary.exactChangedPathCount == 5,
              retirementBoundary.exactOrderedChangedPaths.count == 5,
              retirementBoundary.exactOrderedChangedPaths.map(\.ordinal)
                == [1, 2, 3, 4, 5],
              retirementBoundary.exactOrderedChangedPaths.map(\.gitStatus)
                == ["M", "M", "M", "A", "A"],
              retirementBoundary.expectedRootTestCount
                + retirementBoundary.expectedIsolatedTestCount
                == retirementBoundary.expectedFocusedWholeTestCount,
              retirementBoundary.expectedFocusedWholeTestCount
                + retirementBoundary.expectedRetainedLiveTestCount
                == retirementBoundary.expectedAggregateTestCount,
              retirementBoundary.expectedMeasurementWorkflowStepCount == 0,
              retirementBoundary.expectedLauncherWorkflowReferenceCount == 0,
              retirementBoundary.expectedLauncherInvocationCount == 0,
              retirementBoundary.expectedEvaluatorInvocationCount == 0,
              retirementBoundary.expectedHostedRecordCount == 0,
              retirementBoundary.launcherSourcePreservedForAudit,
              retirementBoundary.evaluatorSourcePreservedForAudit,
              retirementBoundary.launcherSource == mechanicsSourceBindings[3],
              retirementBoundary.evaluatorSource == mechanicsSourceBindings[4],
              retirementBoundary
                .sourceParserMayRetainEvaluatorPathWithoutInvokingIt,
              retirementBoundary.measurementOpportunityRetired,
              retirementBoundary.exactMainRetirementClosureRequired,
              !retirementBoundary.retryWithoutNewAuthorityPermitted,
              !retirementBoundary.rerunPermitted,
              !retirementBoundary.replacementMeasurementPermitted,
              authorityCeiling.measurementAuthorityExactMainGreenEstablished,
              authorityCeiling.mechanicsExactMainClosureEstablished,
              authorityCeiling.exactHostedRecordIntegrityEstablished,
              authorityCeiling.invocationAdmissionRefusalEstablished,
              authorityCeiling.likelyRefusalCauseIsInferenceOnly,
              authorityCeiling.measurementOpportunityRetired,
              authorityCeiling.exactRetirementRequired,
              authorityCeiling.sanitizedToolchainObservationEstablished,
              authorityCeiling.reviewedJobLogIdentityEstablished,
              authorityCeiling.workflowFailureEstablished,
              authorityCeiling.currentPatchAddsOnlyPureObservationPair,
              falseCeilings.allSatisfy({ !$0 }),
              orderedRequiredSeparateActions.count == 6,
              canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256
        else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationError
                .contractDrift
        }
    }
}

extension
    PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationV1
        .HostedRecord
{
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actionsArtifact, forKey: .actionsArtifact)
        try container.encode(
            authorityCanonicalSHA256,
            forKey: .authorityCanonicalSHA256)
        try container.encode(authorityID, forKey: .authorityID)
        try container.encode(buildACommandState, forKey: .buildACommandState)
        try container.encode(buildBCommandState, forKey: .buildBCommandState)
        try container.encode(byteCountEqual, forKey: .byteCountEqual)
        try container.encode(
            canaryExecutionPerformed,
            forKey: .canaryExecutionPerformed)
        try container.encode(
            currentPinByteCountMatch,
            forKey: .currentPinByteCountMatch)
        try container.encode(currentPinFullMatch, forKey: .currentPinFullMatch)
        try container.encode(
            currentPinSHA256Match,
            forKey: .currentPinSHA256Match)
        try container.encode(durableEvidence, forKey: .durableEvidence)
        try container.encode(
            evaluatorCommandState,
            forKey: .evaluatorCommandState)
        try container.encode(
            evaluatorCompileState,
            forKey: .evaluatorCompileState)
        try container.encode(
            evaluatorExecutionObservation,
            forKey: .evaluatorExecutionObservation)
        try container.encode(
            evaluatorShellWaitStatus,
            forKey: .evaluatorShellWaitStatus)
        try container.encode(exactRevision, forKey: .exactRevision)
        try container.encode(
            fixtureABuildPlatformPacked,
            forKey: .fixtureABuildPlatformPacked)
        try container.encode(fixtureAByteCount, forKey: .fixtureAByteCount)
        try container.encode(fixtureAMachOUUID, forKey: .fixtureAMachOUUID)
        try container.encode(
            fixtureAMinimumOSPpacked,
            forKey: .fixtureAMinimumOSPpacked)
        try container.encode(fixtureASDKPacked, forKey: .fixtureASDKPacked)
        try container.encode(fixtureASHA256, forKey: .fixtureASHA256)
        try container.encode(
            fixtureBBuildPlatformPacked,
            forKey: .fixtureBBuildPlatformPacked)
        try container.encode(fixtureBByteCount, forKey: .fixtureBByteCount)
        try container.encode(fixtureBMachOUUID, forKey: .fixtureBMachOUUID)
        try container.encode(
            fixtureBMinimumOSPpacked,
            forKey: .fixtureBMinimumOSPpacked)
        try container.encode(fixtureBSDKPacked, forKey: .fixtureBSDKPacked)
        try container.encode(fixtureBSHA256, forKey: .fixtureBSHA256)
        try container.encode(
            fixtureExecutionCount,
            forKey: .fixtureExecutionCount)
        try container.encode(fullBytesEqual, forKey: .fullBytesEqual)
        try container.encode(machoIdentityEqual, forKey: .machoIdentityEqual)
        try container.encode(
            measurementAttemptConsumed,
            forKey: .measurementAttemptConsumed)
        try container.encode(opportunityState, forKey: .opportunityState)
        try container.encode(pinMutationPerformed, forKey: .pinMutationPerformed)
        try container.encode(
            rawBuildOutputOrErrorFieldCount,
            forKey: .rawBuildOutputOrErrorFieldCount)
        try container.encode(rawPathCount, forKey: .rawPathCount)
        try container.encode(resultCode, forKey: .resultCode)
        try container.encode(schemaID, forKey: .schemaID)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(scientificOutcome, forKey: .scientificOutcome)
        try container.encode(sha256Equal, forKey: .sha256Equal)
        try container.encode(
            showBinACommandState,
            forKey: .showBinACommandState)
        try container.encode(
            showBinBCommandState,
            forKey: .showBinBCommandState)
    }
}
