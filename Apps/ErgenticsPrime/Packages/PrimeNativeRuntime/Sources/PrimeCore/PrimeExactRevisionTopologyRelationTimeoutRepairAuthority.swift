// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// Pure append-only evidence and authority for the narrowly bounded reviewed-
/// main timeout repair after exact-main run 166. Constructing, encoding,
/// decoding, or validating this value performs no filesystem, process, Git,
/// compiler, verifier, network, test, model, lease, or workflow operation.
public struct PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public struct FileIdentity: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let crByteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct PathContract: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let role: String
    }

    public struct FrozenRun166ExactFiveIdentity:
        Codable,
        Equatable,
        Sendable
    {
        public let exactMainRevision: String
        public let exactMainTree: String
        public let exactFiles: [FileIdentity]
        public let exactFiveExcludedIndexSHA256: String
        public let relationAuthorityCanonicalByteCount: Int
        public let relationAuthorityCanonicalSHA256: String
        public let relationAuthorityPairMustRemainByteIdentical: Bool
        public let relationAuthorityPairSuperseded: Bool
    }

    public struct RepositoryIdentity: Codable, Equatable, Sendable {
        public let repository: String
        public let pullRequestNumber: Int
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let historyPreservingTwoParentMergeObserved: Bool
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
        public let gitObjectIdentityAlgorithm: String
        public let gitObjectIdentityPurpose: String
        public let sha256EvidenceDigestPurpose: String
        public let gitSHA1MakesNoAuthenticityOrCollisionResistanceClaim: Bool
        public let syntheticGitEvidenceCount: Int
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
        public let startedAt: String
        public let completedAt: String
        public let durationSeconds: Int
        public let previousAttemptURL: String?
        public let matchingPushRunCountForHead: Int
        public let retryCount: Int
        public let rerunCount: Int
        public let actionsArtifactCount: Int
    }

    public struct Job: Codable, Equatable, Sendable {
        public let jobID: Int
        public let name: String
        public let runnerLabel: String
        public let status: String
        public let conclusion: String
        public let startedAt: String
        public let completedAt: String
        public let durationSeconds: Int
    }

    public struct ActiveRootTestObservation:
        Codable,
        Equatable,
        Sendable
    {
        public let jobID: Int
        public let latinTestCount: Int
        public let passCount: Int
        public let failureCount: Int
        public let skipCount: Int
    }

    public struct ConnectorDecodedUTF8LogIdentity:
        Codable,
        Equatable,
        Sendable
    {
        public let jobID: Int
        public let representation: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let crByteCount: Int
        public let terminalLFPresent: Bool
        public let utf8BOMCount: Int
        public let utf8BOMByteOffsets: [Int]
        public let utf8BOMByteOffsetsAreBound: Bool
        public let sha256: String
        public let repeatFetchExactlyEqual: Bool
        public let rawArchiveBytesBound: Bool
        public let rawArchiveRetained: Bool
    }

    public struct ExactTextEvidence: Codable, Equatable, Sendable {
        public let evidenceID: String
        public let text: String
        public let utf8ByteCount: Int
        public let sha256: String
        public let exactOccurrenceCount: Int
        public let oneBasedLineNumber: Int?
        public let zeroBasedByteOffset: Int?
    }

    public struct FocusedObservation: Codable, Equatable, Sendable {
        public let startedAt: String
        public let completedAt: String
        public let durationSeconds: Int
        public let rootTestCount: Int
        public let isolatedTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let focusedWholeTestCount: Int
        public let passCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let relationAuthorityTestClassName: String
        public let relationAuthorityTestMethodName: String
        public let relationAuthorityTestStartCount: Int
        public let relationAuthorityTestPassCount: Int
        public let relationAuthorityTestFailureCount: Int
        public let relationAuthorityTestSkipCount: Int
        public let relationAuthorityTestDurationMilliseconds: Int
    }

    public struct RetainedCommandObservation:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let command: String
        public let classification: String
        public let testCount: Int
        public let passCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let receiptCount: Int
        public let completed: Bool
        public let cancelled: Bool
        public let semanticOutcomeEstablished: Bool
    }

    public struct PartialLiveObservation: Codable, Equatable, Sendable {
        public let startedAt: String
        public let completedAt: String
        public let durationSeconds: Int
        public let commandOrder: [String]
        public let metal: RetainedCommandObservation
        public let maintainedRuntime: RetainedCommandObservation
        public let tokenizer: RetainedCommandObservation
        public let metalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let maintainedRuntimeReceiptCount: Int
        public let tokenizerTestCount: Int
        public let completedLiveTestCount: Int
        public let completedLivePassCount: Int
        public let expectedCompleteLiveTestCount: Int
        public let completedAggregateTestCount: Int
        public let expectedCompleteAggregateTestCount: Int
        public let missingLiveTestCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let lastTokenizerBuildProgressLine: String
        public let lastTokenizerBuildProgressAt: String
        public let tokenizerBuildProcessStarted: Bool
        public let tokenizerTestCaseExecutionStarted: Bool
        public let retainedPartialSuccessPreservedAsObservation: Bool
    }

    public struct SuccessfulLiveBaseline: Codable, Equatable, Sendable {
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let checkSuiteID: Int
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let liveDurationSeconds: Int
        public let postLiveDurationSeconds: Int
        public let completedLiveTestCount: Int
        public let expectedCompleteLiveTestCount: Int
        public let reviewedLogIdentity: ConnectorDecodedUTF8LogIdentity
        public let baselineIsSuccessfulAndComplete: Bool
    }

    public struct TimeoutClassification: Codable, Equatable, Sendable {
        public let configuredReviewedMainTimeoutMinutes: Int
        public let proposedReviewedMainTimeoutMinutes: Int
        public let configuredTimeoutSeconds: Int
        public let proposedTimeoutSeconds: Int
        public let exactClassification: String
        public let soleObservedTerminalCause: String
        public let configuredTimeoutBoundaryAnnotationObserved: Bool
        public let cancellationAnnotationObserved: Bool
        public let cancellationLogLineObserved: Bool
        public let allCompletedTestsPassed: Bool
        public let incompleteCommandHasNoSemanticOutcome: Bool
        public let timeoutIncompleteNotSemanticFailure: Bool
        public let observedRunMayBeRerunOrRetried: Bool
        public let successorMechanicsAuthorized: Bool
    }

    public struct RuntimeDerivation: Codable, Equatable, Sendable {
        public let preFocusedOverheadSeconds: Int
        public let observedFocusedSeconds: Int
        public let frozenSuccessfulLiveBaselineSeconds: Int
        public let postLiveOverheadSeconds: Int
        public let evidenceDerivedLowerBoundSeconds: Int
        public let configured75MinuteSeconds: Int
        public let configured75MinuteLowerBoundDeficitSeconds: Int
        public let proposed90MinuteSeconds: Int
        public let proposed90MinuteUnallocatedHeadroomBeforeNewTestSeconds: Int
        public let newAuthorityTestMaximumSeconds: Int
        public let preFreezeMaximumObservedAuthorityTestCeilingSeconds: Int
        public let lowerBoundWithNewAuthorityTestCeilingSeconds: Int
        public let configured75MinuteLowerBoundDeficitWithTestCeilingSeconds:
            Int
        public let proposed90MinuteRemainingUnallocatedCompileAndVarianceAllowanceSeconds:
            Int
        public let lowerBoundWithPreFreezeMaximumObservedAuthorityTestSeconds:
            Int
        public let proposed90MinuteUnallocatedHeadroomWithPreFreezeMaximumObservedAuthorityTestSeconds:
            Int
        public let eightyOneMinuteSeconds: Int
        public let eightyOneMinuteUnallocatedHeadroomBeforeNewTestSeconds: Int
        public let smallestWholeMinuteCoveringLowerBoundWithTestCeiling: Int
        public let nextExistingFifteenMinuteBoundary: Int
        public let compileAndRuntimeVarianceMeasured: Bool
        public let arithmeticHeadroomGuaranteesCompletion: Bool
        public let exactMainSuccessMustBeObserved: Bool
        public let arithmeticUsesCheckedIntegerInputsOnly: Bool
    }

    public struct RepairAuthority: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let modifiedExistingPathCount: Int
        public let addedPathCount: Int
        public let workflowTimeoutLiteralBefore: String
        public let workflowTimeoutLiteralAfter: String
        public let workflowTimeoutLiteralChangeOccurrenceCount: Int
        public let activeRootTimeoutMinutes: Int
        public let reviewedMainTimeoutBeforeMinutes: Int
        public let reviewedMainTimeoutAfterMinutes: Int
        public let reviewedMainTimeoutDeltaMinutes: Int
        public let workflowJobCount: Int
        public let workflowJobAndStepOrderMustRemainUnchanged: Bool
        public let retainedLiveCommandSequenceMustRemainByteIdentical: Bool
        public let topologyVerifierImplementationMustRemainByteIdentical: Bool
        public let relationAuthorityPairMustRemainByteIdentical: Bool
        public let packageManifestMustRemainByteIdentical: Bool
        public let packageLockMustRemainByteIdentical: Bool
        public let existingRetiredV1BytesMustRemainByteIdentical: Bool
        public let newSuccessorRelationMechanicsInvocationCount: Int
        public let authorizedTimeoutRepairMergeAttemptCount: Int
        public let observedRunRerunAuthorized: Bool
        public let observedRunRetryAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let successorMechanicsAuthorized: Bool
        public let exactFiveIncludesTimeoutRepairImplementation: Bool
        public let successorRelationImplementationIncluded: Bool
    }

    public struct SuccessorSequenceAmendment:
        Codable,
        Equatable,
        Sendable
    {
        public let predecessorRelationAuthorityRequiresNoInterveningMainCommit:
            Bool
        public let predecessorBaseRevision: String
        public let narrowlySupersededRuleID: String
        public let narrowlySupersededRuleCount: Int
        public let predecessorAuthorityPairRemainsByteIdentical: Bool
        public let allRelationAPISemanticAndSecurityContractsRemainUnchanged:
            Bool
        public let timeoutRepairIsTheOnlyAuthorizedInterveningPatch: Bool
        public let timeoutRepairMergeRevision: String?
        public let requiredClosureHeadEqualsObservedTimeoutRepairMerge: Bool
        public let requiredRepairMergeSignatureVerified: Bool
        public let requiredRepairMergeSignatureReason: String
        public let requiredRepairMergeHistoryPreservingTwoParentShape: Bool
        public let requiredRepairMergeParentCount: Int
        public let requiredRepairMergeParent1Revision: String
        public let requiredRepairMergeParent2DirectChildOfParent1: Bool
        public let requiredRepairMergeParent2TreeEqualsMergeTree: Bool
        public let requiredRepairMergeTreeEqualsReviewedHeadTree: Bool
        public let requiredClosureRunEvent: String
        public let requiredClosureRunRef: String
        public let requiredClosureRunAttempt: Int
        public let requiredClosureMatchingRunCount: Int
        public let requiredClosureConclusion: String
        public let pullRequestGreenIsInsufficient: Bool
        public let currentSuccessorMechanicsAuthorized: Bool
        public let currentSuccessorImplementationAuthorized: Bool
        public let conditionalPostClosureSuccessorRebuildAuthorized: Bool
        public let conditionalAuthorizationPredicate: String
        public let conditionalAuthorizationRequiresAllTopologyAndRunFacts: Bool
        public let separateImplementationReviewAndTestingRequired: Bool
        public let separatePostClosureAuthorityPairRequired: Bool
        public let rebuiltSuccessorFixedParent1Source: String
    }

    public struct ExpectedRepairClosure: Codable, Equatable, Sendable {
        public let activeLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let embeddedProvenanceRecordCount: Int
        public let predecessorEmbeddedProvenanceRecordCount: Int
        public let newEmbeddedSourceRecordCount: Int
        public let timeoutMinutes: Int
        public let repairAuthorityTestCount: Int
        public let newSuccessorRelationMechanicsInvocationCount: Int
        public let actionsArtifactCount: Int
        public let closureIsExpectedNotObserved: Bool
        public let closureSuccessEstablished: Bool
    }

    public struct AuthorityTestWorkCeiling: Codable, Equatable, Sendable {
        public let soleTestClassName: String
        public let soleTestMethodName: String
        public let maximumExternalFocusedTestDurationMilliseconds: Int
        public let preFreezeFocusedTestDurationMillisecondsSamples: [Int]
        public let preFreezeMaximumObservedFocusedTestDurationMilliseconds: Int
        public let externalMeasurementRequiredBeforeCanonicalFreeze: Bool
        public let preFreezeExternalMeasurementRequirementSatisfied: Bool
        public let samplesApplyToPremeasurementCandidates: Bool
        public let finalPinnedByteRuntimeRequiresExternalValidation: Bool
        public let finalPinnedByteExternalValidationCompleted: Bool
        public let externalMeasurementFilter: String
        public let externalMeasurementPassCount: Int
        public let externalMeasurementFailureCount: Int
        public let externalMeasurementUsedCachedDependencies: Bool
        public let externalMeasurementWasHosted: Bool
        public let externalMeasurementWasCleanBuildDelta: Bool
        public let wallClockAssertionInsideTest: Bool
        public let boundedMutationCaseCount: Int
        public let maximumBoundedMutationCaseCount: Int
        public let recursiveJSONValuePathEnumerationCount: Int
        public let validCanonicalRoundTripCount: Int
        public let oversizedDecodeRejectionCount: Int
        public let deterministicWorkCeilingEnforcedByTest: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let exactMainRun166EvidenceEstablished: Bool
        public let boundedTimeoutRepairAuthorized: Bool
        public let relationAuthorityPairPreserved: Bool
        public let semanticFailureEstablished: Bool
        public let relationImplementationPerformedByAuthorityValue: Bool
        public let topologyVerifierExecutionPerformedByAuthorityValue: Bool
        public let helperExecutionPerformedByAuthorityValue: Bool
        public let classifierExecutionPerformedByAuthorityValue: Bool
        public let matrixExecutionPerformedByAuthorityValue: Bool
        public let filesystemReadPerformedByAuthorityValue: Bool
        public let filesystemWritePerformedByAuthorityValue: Bool
        public let processExecutionPerformedByAuthorityValue: Bool
        public let gitExecutionPerformedByAuthorityValue: Bool
        public let compilerExecutionPerformedByAuthorityValue: Bool
        public let networkExecutionPerformedByAuthorityValue: Bool
        public let modelExecutionPerformedByAuthorityValue: Bool
        public let leaseExecutionPerformedByAuthorityValue: Bool
        public let fixtureExecutionPerformedByAuthorityValue: Bool
        public let rerunAuthorized: Bool
        public let retryAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let successorMechanicsAuthorized: Bool
        public let successorRelationMeasurementAuthorized: Bool
        public let successorRelationConfirmationAuthorized: Bool
        public let successorRelationCanaryAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let frozenRun166ExactFiveIdentity: FrozenRun166ExactFiveIdentity
    public let repositoryIdentity: RepositoryIdentity
    public let workflowRun: WorkflowRun
    public let activeRootJob: Job
    public let reviewedMainJob: Job
    public let activeRootTestObservation: ActiveRootTestObservation
    public let activeRootLogIdentity: ConnectorDecodedUTF8LogIdentity
    public let reviewedMainLogIdentity: ConnectorDecodedUTF8LogIdentity
    public let maximumExecutionTimeAnnotation: ExactTextEvidence
    public let cancellationAnnotation: ExactTextEvidence
    public let cancellationLogLine: ExactTextEvidence
    public let focusedObservation: FocusedObservation
    public let partialLiveObservation: PartialLiveObservation
    public let successfulLiveBaseline: SuccessfulLiveBaseline
    public let timeoutClassification: TimeoutClassification
    public let runtimeDerivation: RuntimeDerivation
    public let repairAuthority: RepairAuthority
    public let successorSequenceAmendment: SuccessorSequenceAmendment
    public let expectedRepairClosure: ExpectedRepairClosure
    public let authorityTestWorkCeiling: AuthorityTestWorkCeiling
    public let authorityCeiling: AuthorityCeiling
    public let orderedNextActions: [String]
    public let status: String

    // Bound after independent PRE-FREEZE review cleared the exact value.
    public static let canonicalByteCount = 18_515
    public static let canonicalSHA256 =
        "667a8c408635407eecb5cc2fd8381baf1cc1f28fc771ff541c66b3816b97a5f4"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_exact_revision_topology_relation_timeout_repair_authority_v1",
        authorityID:
            "ergentics_prime_exact_revision_topology_relation_timeout_repair_authority_v1",
        authorityKind:
            "append_only_run166_reviewed_main_timeout_evidence_and_bounded_75_to_90_minute_repair_authority",
        frozenRun166ExactFiveIdentity: .init(
            exactMainRevision:
                "444cd402c966521f6163f4949b4a73f9a5184e29",
            exactMainTree:
                "2471a8610f4081c8a181daf9ac1d6d4ae8ec5f37",
            exactFiles: [
                .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitMode: "100755", gitBlob: "bc1d55368818a999976cffa8fb7e0f1ba47a5b83", byteCount: 1_511_716, lfByteCount: 23_972, crByteCount: 0, sha256: "9e884a15e1ab45489554f8c1cb5ec7a2dd652739b8f0e0bbcfdc002d8dcb6b83", role: "run166_gate"),
                .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitMode: "100644", gitBlob: "0b75726844c901def086d7e2dc6a062307731c6b", byteCount: 206_489, lfByteCount: 761, crByteCount: 0, sha256: "c3e57cc86c675a4f888a85641ff6b03fdbe169fd300016bbd2f0269c8ff8fe81", role: "run166_workflow"),
                .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitMode: "100644", gitBlob: "8e6f105c2088fd5717fb54132a496e8507996c10", byteCount: 546, lfByteCount: 13, crByteCount: 0, sha256: "bd6ffedc401a9e8be25bab3239ca9603b749361cda0257b45a9a13d733293bc9", role: "run166_provenance_528"),
                .init(ordinal: 4, path: "Sources/PrimeCore/PrimeExactRevisionTopologyRelationAmendmentAuthority.swift", gitMode: "100644", gitBlob: "bd063eb9f7998b1d95180c5cb5df0c49096af246", byteCount: 340_871, lfByteCount: 5_530, crByteCount: 0, sha256: "1d2680cc7e4faf17b14cb2ad673488013ea74da20cfc97b03ab7345cc3db0629", role: "frozen_relation_amendment_authority"),
                .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeExactRevisionTopologyRelationAmendmentAuthorityTests.swift", gitMode: "100644", gitBlob: "be1b09bc9cde1f3e251791aa21b3e966ed4e8050", byteCount: 173_242, lfByteCount: 3_685, crByteCount: 0, sha256: "d87d226131696e67b48b3cd548f2af4d810eca05de134cf0ad50ed234d1d906a", role: "frozen_relation_amendment_authority_test"),
            ],
            exactFiveExcludedIndexSHA256:
                "915fe480012287f0620a38c0f298618966b1437fbca8038e35d53929a8c20d36",
            relationAuthorityCanonicalByteCount: 467_184,
            relationAuthorityCanonicalSHA256:
                "ae13d26870b73515bf76018d2f0c1f10d13edf0a59c38857e5767f1abc668a98",
            relationAuthorityPairMustRemainByteIdentical: true,
            relationAuthorityPairSuperseded: false),
        repositoryIdentity: .init(
            repository: "Ergentics/ergentics-prime",
            pullRequestNumber: 133,
            mergeRevision: "444cd402c966521f6163f4949b4a73f9a5184e29",
            mergeTree: "2471a8610f4081c8a181daf9ac1d6d4ae8ec5f37",
            orderedParentRevisions: [
                "3c40cce6350da7ed0ce0f5ccb0620f76feff0501",
                "2aa0185f43a470669fcabd160d897680d35a1b66",
            ],
            historyPreservingTwoParentMergeObserved: true,
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-21T14:10:00Z",
            gitObjectIdentityAlgorithm: "sha1",
            gitObjectIdentityPurpose:
                "repository_native_Git_object_identity_only",
            sha256EvidenceDigestPurpose:
                "frozen_evidence_and_file_byte_integrity_identity",
            gitSHA1MakesNoAuthenticityOrCollisionResistanceClaim: true,
            syntheticGitEvidenceCount: 0),
        workflowRun: .init(
            workflowName: "Prime active-root quarantine",
            runID: 32_490_668_515,
            runNumber: 166,
            runAttempt: 1,
            checkSuiteID: 88_074_911_774,
            event: "push",
            ref: "refs/heads/main",
            headSHA: "444cd402c966521f6163f4949b4a73f9a5184e29",
            status: "completed",
            conclusion: "cancelled",
            startedAt: "2026-08-21T14:10:02Z",
            completedAt: "2026-08-21T15:30:05Z",
            durationSeconds: 4_803,
            previousAttemptURL: nil,
            matchingPushRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0,
            actionsArtifactCount: 0),
        activeRootJob: .init(
            jobID: 96_797_271_270,
            name: "First-party MLX / active-root quarantine",
            runnerLabel: "macos-15",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-21T14:10:05Z",
            completedAt: "2026-08-21T14:14:33Z",
            durationSeconds: 268),
        reviewedMainJob: .init(
            jobID: 96_798_603_025,
            name: "Reviewed main / focused source contracts",
            runnerLabel: "macos-26",
            status: "completed",
            conclusion: "cancelled",
            startedAt: "2026-08-21T14:14:37Z",
            completedAt: "2026-08-21T15:30:04Z",
            durationSeconds: 4_527),
        activeRootTestObservation: .init(
            jobID: 96_797_271_270,
            latinTestCount: 116,
            passCount: 116,
            failureCount: 0,
            skipCount: 0),
        activeRootLogIdentity: .init(
            jobID: 96_797_271_270,
            representation: "connector_decoded_UTF8_job_log",
            byteCount: 385_283,
            lfByteCount: 1_922,
            crByteCount: 0,
            terminalLFPresent: true,
            utf8BOMCount: 1,
            utf8BOMByteOffsets: [0],
            utf8BOMByteOffsetsAreBound: true,
            sha256:
                "6ebc29a465f49b11469f25f43d893b4684ddb4abc674fbca608e5f6e659259fd",
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        reviewedMainLogIdentity: .init(
            jobID: 96_798_603_025,
            representation: "connector_decoded_UTF8_job_log",
            byteCount: 10_328_495,
            lfByteCount: 78_979,
            crByteCount: 0,
            terminalLFPresent: true,
            utf8BOMCount: 5,
            utf8BOMByteOffsets: [0, 2_112_582, 4_225_492, 6_338_188, 8_452_737],
            utf8BOMByteOffsetsAreBound: true,
            sha256:
                "2e4a205cab29a6db3a56dd993c62c92570cc9c1d250bf8015329cef22b636380",
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        maximumExecutionTimeAnnotation: .init(
            evidenceID: "run166_maximum_execution_time_annotation",
            text: "The job has exceeded the maximum execution time of 1h15m0s",
            utf8ByteCount: 58,
            sha256:
                "4a373f31128d7837a6248f4969b8c56aa5e328eba65ecb114c71ac29a8950faf",
            exactOccurrenceCount: 1,
            oneBasedLineNumber: nil,
            zeroBasedByteOffset: nil),
        cancellationAnnotation: .init(
            evidenceID: "run166_cancellation_annotation",
            text: "The operation was canceled.",
            utf8ByteCount: 27,
            sha256:
                "71f739a80227fe65631c8cc4f6f0ca8327b4a3bfbd2bbc3bf0f13da06c056766",
            exactOccurrenceCount: 1,
            oneBasedLineNumber: nil,
            zeroBasedByteOffset: nil),
        cancellationLogLine: .init(
            evidenceID: "run166_exact_cancellation_log_line",
            text:
                "2026-08-21T15:29:50.1841720Z ##[error]The operation was canceled.\n",
            utf8ByteCount: 66,
            sha256:
                "10ac42948e70289b86176025f1672bf84201fc618daf62471376a574ca671575",
            exactOccurrenceCount: 1,
            oneBasedLineNumber: 78_976,
            zeroBasedByteOffset: 10_328_221),
        focusedObservation: .init(
            startedAt: "2026-08-21T14:14:56Z",
            completedAt: "2026-08-21T15:08:33Z",
            durationSeconds: 3_217,
            rootTestCount: 88,
            isolatedTestCount: 6,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            focusedWholeTestCount: 94,
            passCount: 94,
            failureCount: 0,
            skipCount: 0,
            relationAuthorityTestClassName:
                "PrimeExactRevisionTopologyRelationAmendmentAuthorityTests",
            relationAuthorityTestMethodName:
                "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
            relationAuthorityTestStartCount: 1,
            relationAuthorityTestPassCount: 1,
            relationAuthorityTestFailureCount: 0,
            relationAuthorityTestSkipCount: 0,
            relationAuthorityTestDurationMilliseconds: 1_077_052),
        partialLiveObservation: .init(
            startedAt: "2026-08-21T15:08:33Z",
            completedAt: "2026-08-21T15:29:50Z",
            durationSeconds: 1_277,
            commandOrder: [
                "bash .github/scripts/prime-ci-native-decoder-metal.sh",
                "bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh",
                "bash .github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
            ],
            metal: .init(
                ordinal: 1,
                command:
                    "bash .github/scripts/prime-ci-native-decoder-metal.sh",
                classification: "completed_success_retained_live_command",
                testCount: 44,
                passCount: 44,
                failureCount: 0,
                skipCount: 0,
                receiptCount: 0,
                completed: true,
                cancelled: false,
                semanticOutcomeEstablished: true),
            maintainedRuntime: .init(
                ordinal: 2,
                command:
                    "bash .github/scripts/prime-ci-native-decoder-runtime-closure.sh",
                classification: "completed_success_retained_live_command",
                testCount: 1,
                passCount: 1,
                failureCount: 0,
                skipCount: 0,
                receiptCount: 1,
                completed: true,
                cancelled: false,
                semanticOutcomeEstablished: true),
            tokenizer: .init(
                ordinal: 3,
                command:
                    "bash .github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
                classification:
                    "cancelled_at_job_timeout_during_build_before_test_case_execution",
                testCount: 0,
                passCount: 0,
                failureCount: 0,
                skipCount: 0,
                receiptCount: 0,
                completed: false,
                cancelled: true,
                semanticOutcomeEstablished: false),
            metalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            maintainedRuntimeReceiptCount: 1,
            tokenizerTestCount: 0,
            completedLiveTestCount: 45,
            completedLivePassCount: 45,
            expectedCompleteLiveTestCount: 46,
            completedAggregateTestCount: 139,
            expectedCompleteAggregateTestCount: 140,
            missingLiveTestCount: 1,
            failureCount: 0,
            skipCount: 0,
            lastTokenizerBuildProgressLine: "[99/196] Compiling bnns.cpp",
            lastTokenizerBuildProgressAt:
                "2026-08-21T15:29:44.5375900Z",
            tokenizerBuildProcessStarted: true,
            tokenizerTestCaseExecutionStarted: false,
            retainedPartialSuccessPreservedAsObservation: true),
        successfulLiveBaseline: .init(
            workflowRunID: 32_434_498_068,
            workflowRunNumber: 164,
            checkSuiteID: 87_927_821_060,
            reviewedMainJobID: 96_633_611_089,
            reviewedMainJobConclusion: "success",
            liveDurationSeconds: 1_609,
            postLiveDurationSeconds: 14,
            completedLiveTestCount: 46,
            expectedCompleteLiveTestCount: 46,
            reviewedLogIdentity: .init(
                jobID: 96_633_611_089,
                representation: "connector_decoded_UTF8_job_log",
                byteCount: 10_341_953,
                lfByteCount: 79_079,
                crByteCount: 0,
                terminalLFPresent: true,
                utf8BOMCount: 5,
                utf8BOMByteOffsets: [],
                utf8BOMByteOffsetsAreBound: false,
                sha256:
                    "0149f6b4312df9570dbeaf652c9fecd368ca9f9b446b9b2cc14cc1d61d717c4f",
                repeatFetchExactlyEqual: true,
                rawArchiveBytesBound: false,
                rawArchiveRetained: false),
            baselineIsSuccessfulAndComplete: true),
        timeoutClassification: .init(
            configuredReviewedMainTimeoutMinutes: 75,
            proposedReviewedMainTimeoutMinutes: 90,
            configuredTimeoutSeconds: 4_500,
            proposedTimeoutSeconds: 5_400,
            exactClassification: "timeout_incomplete_not_semantic_failure",
            soleObservedTerminalCause:
                "reviewed_main_configured_75_minute_execution_ceiling",
            configuredTimeoutBoundaryAnnotationObserved: true,
            cancellationAnnotationObserved: true,
            cancellationLogLineObserved: true,
            allCompletedTestsPassed: true,
            incompleteCommandHasNoSemanticOutcome: true,
            timeoutIncompleteNotSemanticFailure: true,
            observedRunMayBeRerunOrRetried: false,
            successorMechanicsAuthorized: false),
        runtimeDerivation: .init(
            preFocusedOverheadSeconds: 19,
            observedFocusedSeconds: 3_217,
            frozenSuccessfulLiveBaselineSeconds: 1_609,
            postLiveOverheadSeconds: 14,
            evidenceDerivedLowerBoundSeconds: 4_859,
            configured75MinuteSeconds: 4_500,
            configured75MinuteLowerBoundDeficitSeconds: 359,
            proposed90MinuteSeconds: 5_400,
            proposed90MinuteUnallocatedHeadroomBeforeNewTestSeconds: 541,
            newAuthorityTestMaximumSeconds: 5,
            preFreezeMaximumObservedAuthorityTestCeilingSeconds: 1,
            lowerBoundWithNewAuthorityTestCeilingSeconds: 4_864,
            configured75MinuteLowerBoundDeficitWithTestCeilingSeconds: 364,
            proposed90MinuteRemainingUnallocatedCompileAndVarianceAllowanceSeconds:
                536,
            lowerBoundWithPreFreezeMaximumObservedAuthorityTestSeconds: 4_860,
            proposed90MinuteUnallocatedHeadroomWithPreFreezeMaximumObservedAuthorityTestSeconds:
                540,
            eightyOneMinuteSeconds: 4_860,
            eightyOneMinuteUnallocatedHeadroomBeforeNewTestSeconds: 1,
            smallestWholeMinuteCoveringLowerBoundWithTestCeiling: 82,
            nextExistingFifteenMinuteBoundary: 90,
            compileAndRuntimeVarianceMeasured: false,
            arithmeticHeadroomGuaranteesCompletion: false,
            exactMainSuccessMustBeObserved: true,
            arithmeticUsesCheckedIntegerInputsOnly: true),
        repairAuthority: .init(
            exactOrderedPaths: [
                .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitStatus: "M", gitMode: "100755", role: "bind_run166_timeout_evidence_and_repair_authority"),
                .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitStatus: "M", gitMode: "100644", role: "raise_only_reviewed_main_timeout_75_to_90_and_run_fast_pure_test"),
                .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitStatus: "M", gitMode: "100644", role: "regenerate_530_record_embedded_source_identity"),
                .init(ordinal: 4, path: "Sources/PrimeCore/PrimeExactRevisionTopologyRelationTimeoutRepairAuthority.swift", gitStatus: "A", gitMode: "100644", role: "pure_run166_timeout_evidence_and_repair_authority"),
                .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityTests.swift", gitStatus: "A", gitMode: "100644", role: "sole_fast_bounded_pure_authority_test"),
            ],
            exactPathCount: 5,
            modifiedExistingPathCount: 3,
            addedPathCount: 2,
            workflowTimeoutLiteralBefore: "timeout-minutes: 75",
            workflowTimeoutLiteralAfter: "timeout-minutes: 90",
            workflowTimeoutLiteralChangeOccurrenceCount: 1,
            activeRootTimeoutMinutes: 45,
            reviewedMainTimeoutBeforeMinutes: 75,
            reviewedMainTimeoutAfterMinutes: 90,
            reviewedMainTimeoutDeltaMinutes: 15,
            workflowJobCount: 2,
            workflowJobAndStepOrderMustRemainUnchanged: true,
            retainedLiveCommandSequenceMustRemainByteIdentical: true,
            topologyVerifierImplementationMustRemainByteIdentical: true,
            relationAuthorityPairMustRemainByteIdentical: true,
            packageManifestMustRemainByteIdentical: true,
            packageLockMustRemainByteIdentical: true,
            existingRetiredV1BytesMustRemainByteIdentical: true,
            newSuccessorRelationMechanicsInvocationCount: 0,
            authorizedTimeoutRepairMergeAttemptCount: 1,
            observedRunRerunAuthorized: false,
            observedRunRetryAuthorized: false,
            replacementExecutionAuthorized: false,
            successorMechanicsAuthorized: false,
            exactFiveIncludesTimeoutRepairImplementation: true,
            successorRelationImplementationIncluded: false),
        successorSequenceAmendment: .init(
            predecessorRelationAuthorityRequiresNoInterveningMainCommit: true,
            predecessorBaseRevision:
                "444cd402c966521f6163f4949b4a73f9a5184e29",
            narrowlySupersededRuleID:
                "successor_implementation_requires_no_intervening_main_commit_from_444cd402c966521f6163f4949b4a73f9a5184e29",
            narrowlySupersededRuleCount: 1,
            predecessorAuthorityPairRemainsByteIdentical: true,
            allRelationAPISemanticAndSecurityContractsRemainUnchanged: true,
            timeoutRepairIsTheOnlyAuthorizedInterveningPatch: true,
            timeoutRepairMergeRevision: nil,
            requiredClosureHeadEqualsObservedTimeoutRepairMerge: true,
            requiredRepairMergeSignatureVerified: true,
            requiredRepairMergeSignatureReason: "valid",
            requiredRepairMergeHistoryPreservingTwoParentShape: true,
            requiredRepairMergeParentCount: 2,
            requiredRepairMergeParent1Revision:
                "444cd402c966521f6163f4949b4a73f9a5184e29",
            requiredRepairMergeParent2DirectChildOfParent1: true,
            requiredRepairMergeParent2TreeEqualsMergeTree: true,
            requiredRepairMergeTreeEqualsReviewedHeadTree: true,
            requiredClosureRunEvent: "push",
            requiredClosureRunRef: "refs/heads/main",
            requiredClosureRunAttempt: 1,
            requiredClosureMatchingRunCount: 1,
            requiredClosureConclusion: "success",
            pullRequestGreenIsInsufficient: true,
            currentSuccessorMechanicsAuthorized: false,
            currentSuccessorImplementationAuthorized: false,
            conditionalPostClosureSuccessorRebuildAuthorized: true,
            conditionalAuthorizationPredicate:
                "unique_attempt1_direct_push_main_run_for_observed_timeout_repair_merge_is_successful",
            conditionalAuthorizationRequiresAllTopologyAndRunFacts: true,
            separateImplementationReviewAndTestingRequired: true,
            separatePostClosureAuthorityPairRequired: false,
            rebuiltSuccessorFixedParent1Source:
                "future_observed_timeout_repair_merge_revision_after_unique_attempt1_direct_push_main_success"),
        expectedRepairClosure: .init(
            activeLatinTestCount: 116,
            rootTestCount: 89,
            isolatedTestCount: 6,
            focusedWholeTestCount: 95,
            retainedLiveTestCount: 46,
            aggregateTestCount: 141,
            failureCount: 0,
            skipCount: 0,
            embeddedProvenanceRecordCount: 530,
            predecessorEmbeddedProvenanceRecordCount: 528,
            newEmbeddedSourceRecordCount: 2,
            timeoutMinutes: 90,
            repairAuthorityTestCount: 1,
            newSuccessorRelationMechanicsInvocationCount: 0,
            actionsArtifactCount: 0,
            closureIsExpectedNotObserved: true,
            closureSuccessEstablished: false),
        authorityTestWorkCeiling: .init(
            soleTestClassName:
                "PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityTests",
            soleTestMethodName:
                "testFrozenV1CanonicalCodableBoundedMutationAndTimeoutRepairCeiling",
            maximumExternalFocusedTestDurationMilliseconds: 5_000,
            preFreezeFocusedTestDurationMillisecondsSamples: [15, 18],
            preFreezeMaximumObservedFocusedTestDurationMilliseconds: 18,
            externalMeasurementRequiredBeforeCanonicalFreeze: true,
            preFreezeExternalMeasurementRequirementSatisfied: true,
            samplesApplyToPremeasurementCandidates: true,
            finalPinnedByteRuntimeRequiresExternalValidation: true,
            finalPinnedByteExternalValidationCompleted: false,
            externalMeasurementFilter:
                "PrimeCoreTests.PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityTests/testFrozenV1CanonicalCodableBoundedMutationAndTimeoutRepairCeiling",
            externalMeasurementPassCount: 2,
            externalMeasurementFailureCount: 0,
            externalMeasurementUsedCachedDependencies: true,
            externalMeasurementWasHosted: false,
            externalMeasurementWasCleanBuildDelta: false,
            wallClockAssertionInsideTest: false,
            boundedMutationCaseCount: 32,
            maximumBoundedMutationCaseCount: 32,
            recursiveJSONValuePathEnumerationCount: 0,
            validCanonicalRoundTripCount: 1,
            oversizedDecodeRejectionCount: 1,
            deterministicWorkCeilingEnforcedByTest: true),
        authorityCeiling: .init(
            exactMainRun166EvidenceEstablished: true,
            boundedTimeoutRepairAuthorized: true,
            relationAuthorityPairPreserved: true,
            semanticFailureEstablished: false,
            relationImplementationPerformedByAuthorityValue: false,
            topologyVerifierExecutionPerformedByAuthorityValue: false,
            helperExecutionPerformedByAuthorityValue: false,
            classifierExecutionPerformedByAuthorityValue: false,
            matrixExecutionPerformedByAuthorityValue: false,
            filesystemReadPerformedByAuthorityValue: false,
            filesystemWritePerformedByAuthorityValue: false,
            processExecutionPerformedByAuthorityValue: false,
            gitExecutionPerformedByAuthorityValue: false,
            compilerExecutionPerformedByAuthorityValue: false,
            networkExecutionPerformedByAuthorityValue: false,
            modelExecutionPerformedByAuthorityValue: false,
            leaseExecutionPerformedByAuthorityValue: false,
            fixtureExecutionPerformedByAuthorityValue: false,
            rerunAuthorized: false,
            retryAuthorized: false,
            replacementExecutionAuthorized: false,
            successorMechanicsAuthorized: false,
            successorRelationMeasurementAuthorized: false,
            successorRelationConfirmationAuthorized: false,
            successorRelationCanaryAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        orderedNextActions: [
            "independent_PRE_FREEZE_review_then_bind_canonical_identity",
            "merge_only_the_pure_exact_five_75_to_90_minute_timeout_repair",
            "do_not_rerun_retry_or_replace_run166",
            "do_not_authorize_or_invoke_successor_relation_mechanics",
            "observe_the_repair_merge_exact_main_run_as_a_later_factual_closure_only",
            "only_after_unique_attempt1_direct_push_main_success_may_the_previously_authorized_successor_be_rebuilt_with_the_observed_repair_merge_as_fixed_parent1_subject_to_separate_implementation_review_and_testing",
        ],
        status:
            "RUN166_TIMEOUT_INCOMPLETE_NOT_SEMANTIC_FAILURE_exact_139_of_140_bounded_75_to_90_repair_no_rerun_or_successor_mechanics")

    public func canonicalData() throws -> Data {
        try validateExactV1()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 131_072 else {
            throw
                PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw
                PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityError
                .noncanonicalEncoding
        }
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let run = workflowRun
        let activeTests = activeRootTestObservation
        let focused = focusedObservation
        let partial = partialLiveObservation
        let baseline = successfulLiveBaseline
        let runtime = runtimeDerivation
        let repair = repairAuthority
        let sequence = successorSequenceAmendment
        let closure = expectedRepairClosure
        let testWork = authorityTestWorkCeiling
        let ceilingFalse = [
            authorityCeiling.semanticFailureEstablished,
            authorityCeiling.relationImplementationPerformedByAuthorityValue,
            authorityCeiling.topologyVerifierExecutionPerformedByAuthorityValue,
            authorityCeiling.helperExecutionPerformedByAuthorityValue,
            authorityCeiling.classifierExecutionPerformedByAuthorityValue,
            authorityCeiling.matrixExecutionPerformedByAuthorityValue,
            authorityCeiling.filesystemReadPerformedByAuthorityValue,
            authorityCeiling.filesystemWritePerformedByAuthorityValue,
            authorityCeiling.processExecutionPerformedByAuthorityValue,
            authorityCeiling.gitExecutionPerformedByAuthorityValue,
            authorityCeiling.compilerExecutionPerformedByAuthorityValue,
            authorityCeiling.networkExecutionPerformedByAuthorityValue,
            authorityCeiling.modelExecutionPerformedByAuthorityValue,
            authorityCeiling.leaseExecutionPerformedByAuthorityValue,
            authorityCeiling.fixtureExecutionPerformedByAuthorityValue,
            authorityCeiling.rerunAuthorized,
            authorityCeiling.retryAuthorized,
            authorityCeiling.replacementExecutionAuthorized,
            authorityCeiling.successorMechanicsAuthorized,
            authorityCeiling.successorRelationMeasurementAuthorized,
            authorityCeiling.successorRelationConfirmationAuthorized,
            authorityCeiling.successorRelationCanaryAuthorized,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
        ]
        guard self == Self.frozenV1,
              schemaVersion == 1,
              frozenRun166ExactFiveIdentity.exactFiles.map(\.ordinal)
                == [1, 2, 3, 4, 5],
              Set(frozenRun166ExactFiveIdentity.exactFiles.map(\.path)).count
                == 5,
              frozenRun166ExactFiveIdentity.exactFiles.allSatisfy({ file in
                  file.crByteCount == 0
                      && Self.isLowercaseHex(file.gitBlob, count: 40)
                      && Self.isLowercaseHex(file.sha256, count: 64)
              }),
              frozenRun166ExactFiveIdentity.exactFiles[3].path
                == "Sources/PrimeCore/PrimeExactRevisionTopologyRelationAmendmentAuthority.swift",
              frozenRun166ExactFiveIdentity.exactFiles[4].path
                == "Tests/PrimeCoreTests/PrimeExactRevisionTopologyRelationAmendmentAuthorityTests.swift",
              frozenRun166ExactFiveIdentity
                .relationAuthorityPairMustRemainByteIdentical,
              !frozenRun166ExactFiveIdentity.relationAuthorityPairSuperseded,
              repositoryIdentity.mergeRevision == run.headSHA,
              repositoryIdentity.mergeRevision
                == frozenRun166ExactFiveIdentity.exactMainRevision,
              repositoryIdentity.mergeTree
                == frozenRun166ExactFiveIdentity.exactMainTree,
              repositoryIdentity.orderedParentRevisions.count == 2,
              repositoryIdentity.orderedParentRevisions.allSatisfy({
                  Self.isLowercaseHex($0, count: 40)
              }),
              repositoryIdentity.historyPreservingTwoParentMergeObserved,
              repositoryIdentity.githubSignatureVerified,
              repositoryIdentity.gitObjectIdentityAlgorithm == "sha1",
              repositoryIdentity.gitObjectIdentityPurpose
                == "repository_native_Git_object_identity_only",
              repositoryIdentity.sha256EvidenceDigestPurpose
                == "frozen_evidence_and_file_byte_integrity_identity",
              repositoryIdentity
                .gitSHA1MakesNoAuthenticityOrCollisionResistanceClaim,
              repositoryIdentity.syntheticGitEvidenceCount == 0,
              run.runNumber == 166,
              run.runAttempt == 1,
              run.event == "push",
              run.ref == "refs/heads/main",
              run.status == "completed",
              run.conclusion == "cancelled",
              run.previousAttemptURL == nil,
              run.matchingPushRunCountForHead == 1,
              run.retryCount == 0,
              run.rerunCount == 0,
              run.actionsArtifactCount == 0,
              Self.seconds(from: run.startedAt, to: run.completedAt)
                == run.durationSeconds,
              Self.seconds(
                from: activeRootJob.startedAt,
                to: activeRootJob.completedAt) == activeRootJob.durationSeconds,
              Self.seconds(
                from: reviewedMainJob.startedAt,
                to: reviewedMainJob.completedAt)
                == reviewedMainJob.durationSeconds,
              activeRootJob.conclusion == "success",
              reviewedMainJob.conclusion == "cancelled",
              activeTests.jobID == activeRootJob.jobID,
              activeTests.latinTestCount == 116,
              activeTests.passCount + activeTests.failureCount
                + activeTests.skipCount == activeTests.latinTestCount,
              activeTests.passCount == activeTests.latinTestCount,
              activeTests.failureCount == 0,
              activeTests.skipCount == 0,
              activeRootLogIdentity.jobID == activeRootJob.jobID,
              reviewedMainLogIdentity.jobID == reviewedMainJob.jobID,
              Self.validLogIdentity(activeRootLogIdentity),
              Self.validLogIdentity(reviewedMainLogIdentity),
              Self.validLogIdentity(baseline.reviewedLogIdentity),
              maximumExecutionTimeAnnotation.utf8ByteCount
                == maximumExecutionTimeAnnotation.text.utf8.count,
              cancellationAnnotation.utf8ByteCount
                == cancellationAnnotation.text.utf8.count,
              cancellationLogLine.utf8ByteCount
                == cancellationLogLine.text.utf8.count,
              maximumExecutionTimeAnnotation.exactOccurrenceCount == 1,
              cancellationAnnotation.exactOccurrenceCount == 1,
              cancellationLogLine.exactOccurrenceCount == 1,
              cancellationLogLine.oneBasedLineNumber == 78_976,
              cancellationLogLine.zeroBasedByteOffset == 10_328_221,
              Self.seconds(from: focused.startedAt, to: focused.completedAt)
                == focused.durationSeconds,
              focused.rootTestCount + focused.isolatedTestCount
                == focused.focusedWholeTestCount,
              focused.isolatedGroupTestCounts == [1, 1, 2, 2],
              focused.isolatedGroupTestCounts.reduce(0, +)
                == focused.isolatedTestCount,
              focused.passCount + focused.failureCount + focused.skipCount
                == focused.focusedWholeTestCount,
              focused.passCount == focused.focusedWholeTestCount,
              focused.failureCount == 0,
              focused.skipCount == 0,
              focused.relationAuthorityTestStartCount == 1,
              focused.relationAuthorityTestPassCount == 1,
              focused.relationAuthorityTestFailureCount == 0,
              focused.relationAuthorityTestSkipCount == 0,
              Self.seconds(
                from: partial.startedAt,
                to: partial.completedAt) == partial.durationSeconds,
              focused.completedAt == partial.startedAt,
              partial.commandOrder
                == [
                    partial.metal.command,
                    partial.maintainedRuntime.command,
                    partial.tokenizer.command,
                ],
              [partial.metal.ordinal, partial.maintainedRuntime.ordinal,
                partial.tokenizer.ordinal] == [1, 2, 3],
              partial.metal.completed,
              !partial.metal.cancelled,
              partial.metal.semanticOutcomeEstablished,
              partial.maintainedRuntime.completed,
              !partial.maintainedRuntime.cancelled,
              partial.maintainedRuntime.semanticOutcomeEstablished,
              !partial.tokenizer.completed,
              partial.tokenizer.cancelled,
              !partial.tokenizer.semanticOutcomeEstablished,
              partial.metal.passCount + partial.metal.failureCount
                + partial.metal.skipCount == partial.metal.testCount,
              partial.maintainedRuntime.passCount
                + partial.maintainedRuntime.failureCount
                + partial.maintainedRuntime.skipCount
                == partial.maintainedRuntime.testCount,
              partial.tokenizer.passCount + partial.tokenizer.failureCount
                + partial.tokenizer.skipCount == partial.tokenizer.testCount,
              partial.metal.testCount == partial.metalTestCount,
              partial.maintainedRuntime.testCount
                == partial.maintainedRuntimeTestCount,
              partial.maintainedRuntime.receiptCount
                == partial.maintainedRuntimeReceiptCount,
              partial.tokenizer.testCount == partial.tokenizerTestCount,
              partial.metalTestCount + partial.maintainedRuntimeTestCount
                + partial.tokenizerTestCount == partial.completedLiveTestCount,
              partial.completedLivePassCount + partial.failureCount
                + partial.skipCount == partial.completedLiveTestCount,
              partial.completedLivePassCount
                == partial.completedLiveTestCount,
              partial.expectedCompleteLiveTestCount
                - partial.completedLiveTestCount == partial.missingLiveTestCount,
              focused.focusedWholeTestCount + partial.completedLiveTestCount
                == partial.completedAggregateTestCount,
              focused.focusedWholeTestCount
                + partial.expectedCompleteLiveTestCount
                == partial.expectedCompleteAggregateTestCount,
              partial.completedAggregateTestCount == 139,
              partial.expectedCompleteAggregateTestCount == 140,
              partial.missingLiveTestCount == 1,
              partial.failureCount == 0,
              partial.skipCount == 0,
              partial.tokenizerBuildProcessStarted,
              !partial.tokenizerTestCaseExecutionStarted,
              baseline.reviewedMainJobConclusion == "success",
              baseline.completedLiveTestCount
                == baseline.expectedCompleteLiveTestCount,
              baseline.completedLiveTestCount == 46,
              baseline.baselineIsSuccessfulAndComplete,
              timeoutClassification.configuredTimeoutSeconds
                == timeoutClassification.configuredReviewedMainTimeoutMinutes
                    * 60,
              timeoutClassification.proposedTimeoutSeconds
                == timeoutClassification.proposedReviewedMainTimeoutMinutes
                    * 60,
              timeoutClassification.configuredTimeoutBoundaryAnnotationObserved,
              timeoutClassification.cancellationAnnotationObserved,
              timeoutClassification.cancellationLogLineObserved,
              timeoutClassification.allCompletedTestsPassed
                == (activeTests.passCount == activeTests.latinTestCount
                    && activeTests.failureCount == 0
                    && activeTests.skipCount == 0
                    && focused.passCount == focused.focusedWholeTestCount
                    && focused.failureCount == 0
                    && focused.skipCount == 0
                    && partial.completedLivePassCount
                        == partial.completedLiveTestCount
                    && partial.failureCount == 0
                    && partial.skipCount == 0),
              timeoutClassification.allCompletedTestsPassed,
              timeoutClassification.incompleteCommandHasNoSemanticOutcome,
              timeoutClassification.timeoutIncompleteNotSemanticFailure,
              !timeoutClassification.observedRunMayBeRerunOrRetried,
              !timeoutClassification.successorMechanicsAuthorized,
              runtime.preFocusedOverheadSeconds
                == Self.seconds(
                    from: reviewedMainJob.startedAt, to: focused.startedAt),
              runtime.observedFocusedSeconds == focused.durationSeconds,
              runtime.frozenSuccessfulLiveBaselineSeconds
                == baseline.liveDurationSeconds,
              runtime.postLiveOverheadSeconds
                == baseline.postLiveDurationSeconds,
              runtime.evidenceDerivedLowerBoundSeconds
                == runtime.preFocusedOverheadSeconds
                    + runtime.observedFocusedSeconds
                    + runtime.frozenSuccessfulLiveBaselineSeconds
                    + runtime.postLiveOverheadSeconds,
              runtime.configured75MinuteSeconds == 75 * 60,
              runtime.configured75MinuteLowerBoundDeficitSeconds
                == runtime.evidenceDerivedLowerBoundSeconds
                    - runtime.configured75MinuteSeconds,
              runtime.proposed90MinuteSeconds == 90 * 60,
              runtime.proposed90MinuteUnallocatedHeadroomBeforeNewTestSeconds
                == runtime.proposed90MinuteSeconds
                    - runtime.evidenceDerivedLowerBoundSeconds,
              runtime.newAuthorityTestMaximumSeconds
                == testWork.maximumExternalFocusedTestDurationMilliseconds
                    / 1_000,
              runtime.preFreezeMaximumObservedAuthorityTestCeilingSeconds
                == (testWork
                    .preFreezeMaximumObservedFocusedTestDurationMilliseconds
                    + 999) / 1_000,
              runtime.lowerBoundWithNewAuthorityTestCeilingSeconds
                == runtime.evidenceDerivedLowerBoundSeconds
                    + runtime.newAuthorityTestMaximumSeconds,
              runtime
                .configured75MinuteLowerBoundDeficitWithTestCeilingSeconds
                == runtime.lowerBoundWithNewAuthorityTestCeilingSeconds
                    - runtime.configured75MinuteSeconds,
              runtime
                .proposed90MinuteRemainingUnallocatedCompileAndVarianceAllowanceSeconds
                == runtime.proposed90MinuteSeconds
                    - runtime.lowerBoundWithNewAuthorityTestCeilingSeconds,
              runtime.lowerBoundWithPreFreezeMaximumObservedAuthorityTestSeconds
                == runtime.evidenceDerivedLowerBoundSeconds
                    + runtime
                        .preFreezeMaximumObservedAuthorityTestCeilingSeconds,
              runtime
                .proposed90MinuteUnallocatedHeadroomWithPreFreezeMaximumObservedAuthorityTestSeconds
                == runtime.proposed90MinuteSeconds
                    - runtime
                        .lowerBoundWithPreFreezeMaximumObservedAuthorityTestSeconds,
              runtime.eightyOneMinuteSeconds == 81 * 60,
              runtime.eightyOneMinuteUnallocatedHeadroomBeforeNewTestSeconds
                == runtime.eightyOneMinuteSeconds
                    - runtime.evidenceDerivedLowerBoundSeconds,
              runtime.smallestWholeMinuteCoveringLowerBoundWithTestCeiling
                == (runtime.lowerBoundWithNewAuthorityTestCeilingSeconds + 59)
                    / 60,
              runtime.smallestWholeMinuteCoveringLowerBoundWithTestCeiling
                == 82,
              runtime.nextExistingFifteenMinuteBoundary == 90,
              !runtime.compileAndRuntimeVarianceMeasured,
              !runtime.arithmeticHeadroomGuaranteesCompletion,
              runtime.exactMainSuccessMustBeObserved,
              runtime.arithmeticUsesCheckedIntegerInputsOnly,
              repair.exactPathCount == 5,
              repair.exactOrderedPaths.count == 5,
              repair.exactOrderedPaths.map(\.ordinal) == [1, 2, 3, 4, 5],
              repair.exactOrderedPaths.map(\.gitStatus)
                == ["M", "M", "M", "A", "A"],
              repair.modifiedExistingPathCount == 3,
              repair.addedPathCount == 2,
              repair.workflowTimeoutLiteralChangeOccurrenceCount == 1,
              repair.reviewedMainTimeoutBeforeMinutes == 75,
              repair.reviewedMainTimeoutAfterMinutes == 90,
              repair.reviewedMainTimeoutDeltaMinutes == 15,
              repair.workflowJobCount == 2,
              repair.workflowJobAndStepOrderMustRemainUnchanged,
              repair.retainedLiveCommandSequenceMustRemainByteIdentical,
              repair.topologyVerifierImplementationMustRemainByteIdentical,
              repair.relationAuthorityPairMustRemainByteIdentical,
              repair.packageManifestMustRemainByteIdentical,
              repair.packageLockMustRemainByteIdentical,
              repair.existingRetiredV1BytesMustRemainByteIdentical,
              repair.newSuccessorRelationMechanicsInvocationCount == 0,
              repair.authorizedTimeoutRepairMergeAttemptCount == 1,
              !repair.observedRunRerunAuthorized,
              !repair.observedRunRetryAuthorized,
              !repair.replacementExecutionAuthorized,
              !repair.successorMechanicsAuthorized,
              repair.exactFiveIncludesTimeoutRepairImplementation,
              !repair.successorRelationImplementationIncluded,
              sequence
                .predecessorRelationAuthorityRequiresNoInterveningMainCommit,
              sequence.predecessorBaseRevision
                == frozenRun166ExactFiveIdentity.exactMainRevision,
              sequence.narrowlySupersededRuleCount == 1,
              sequence.predecessorAuthorityPairRemainsByteIdentical,
              sequence
                .allRelationAPISemanticAndSecurityContractsRemainUnchanged,
              sequence.timeoutRepairIsTheOnlyAuthorizedInterveningPatch,
              sequence.timeoutRepairMergeRevision == nil,
              sequence.requiredClosureHeadEqualsObservedTimeoutRepairMerge,
              sequence.requiredRepairMergeSignatureVerified,
              sequence.requiredRepairMergeSignatureReason == "valid",
              sequence.requiredRepairMergeHistoryPreservingTwoParentShape,
              sequence.requiredRepairMergeParentCount == 2,
              sequence.requiredRepairMergeParent1Revision
                == frozenRun166ExactFiveIdentity.exactMainRevision,
              sequence.requiredRepairMergeParent2DirectChildOfParent1,
              sequence.requiredRepairMergeParent2TreeEqualsMergeTree,
              sequence.requiredRepairMergeTreeEqualsReviewedHeadTree,
              sequence.requiredClosureRunEvent == "push",
              sequence.requiredClosureRunRef == "refs/heads/main",
              sequence.requiredClosureRunAttempt == 1,
              sequence.requiredClosureMatchingRunCount == 1,
              sequence.requiredClosureConclusion == "success",
              sequence.pullRequestGreenIsInsufficient,
              !sequence.currentSuccessorMechanicsAuthorized,
              !sequence.currentSuccessorImplementationAuthorized,
              sequence.conditionalPostClosureSuccessorRebuildAuthorized,
              sequence.conditionalAuthorizationPredicate
                == "unique_attempt1_direct_push_main_run_for_observed_timeout_repair_merge_is_successful",
              sequence
                .conditionalAuthorizationRequiresAllTopologyAndRunFacts,
              sequence.separateImplementationReviewAndTestingRequired,
              !sequence.separatePostClosureAuthorityPairRequired,
              sequence.rebuiltSuccessorFixedParent1Source
                == "future_observed_timeout_repair_merge_revision_after_unique_attempt1_direct_push_main_success",
              closure.rootTestCount == focused.rootTestCount + 1,
              closure.focusedWholeTestCount
                == closure.rootTestCount + closure.isolatedTestCount,
              closure.retainedLiveTestCount
                == baseline.completedLiveTestCount,
              closure.aggregateTestCount
                == closure.focusedWholeTestCount + closure.retainedLiveTestCount,
              closure.embeddedProvenanceRecordCount == 530,
              closure.predecessorEmbeddedProvenanceRecordCount == 528,
              closure.newEmbeddedSourceRecordCount == 2,
              closure.embeddedProvenanceRecordCount
                == closure.predecessorEmbeddedProvenanceRecordCount
                    + closure.newEmbeddedSourceRecordCount,
              closure.activeLatinTestCount == activeTests.latinTestCount,
              closure.timeoutMinutes == repair.reviewedMainTimeoutAfterMinutes,
              closure.repairAuthorityTestCount == 1,
              closure.newSuccessorRelationMechanicsInvocationCount == 0,
              closure.actionsArtifactCount == 0,
              closure.closureIsExpectedNotObserved,
              !closure.closureSuccessEstablished,
              testWork.maximumExternalFocusedTestDurationMilliseconds == 5_000,
              testWork.preFreezeFocusedTestDurationMillisecondsSamples
                == [15, 18],
              testWork
                .preFreezeMaximumObservedFocusedTestDurationMilliseconds
                == testWork.preFreezeFocusedTestDurationMillisecondsSamples.max(),
              testWork
                .preFreezeMaximumObservedFocusedTestDurationMilliseconds
                <= testWork.maximumExternalFocusedTestDurationMilliseconds,
              testWork.externalMeasurementRequiredBeforeCanonicalFreeze,
              testWork.preFreezeExternalMeasurementRequirementSatisfied,
              testWork.samplesApplyToPremeasurementCandidates,
              testWork.finalPinnedByteRuntimeRequiresExternalValidation,
              !testWork.finalPinnedByteExternalValidationCompleted,
              testWork.externalMeasurementPassCount == 2,
              testWork.externalMeasurementFailureCount == 0,
              testWork.externalMeasurementUsedCachedDependencies,
              !testWork.externalMeasurementWasHosted,
              !testWork.externalMeasurementWasCleanBuildDelta,
              !testWork.wallClockAssertionInsideTest,
              testWork.boundedMutationCaseCount == 32,
              testWork.maximumBoundedMutationCaseCount == 32,
              testWork.recursiveJSONValuePathEnumerationCount == 0,
              testWork.validCanonicalRoundTripCount == 1,
              testWork.oversizedDecodeRejectionCount == 1,
              testWork.deterministicWorkCeilingEnforcedByTest,
              authorityCeiling.exactMainRun166EvidenceEstablished,
              authorityCeiling.boundedTimeoutRepairAuthorized,
              authorityCeiling.relationAuthorityPairPreserved,
              ceilingFalse.allSatisfy({ !$0 }),
              Self.canonicalByteCount == 18_515,
              Self.canonicalSHA256
                == "667a8c408635407eecb5cc2fd8381baf1cc1f28fc771ff541c66b3816b97a5f4" else {
            throw
                PrimeExactRevisionTopologyRelationTimeoutRepairAuthorityError
                .contractDrift
        }
    }

    private static func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.utf8.allSatisfy {
                (48 ... 57).contains($0) || (97 ... 102).contains($0)
            }
    }

    private static func validLogIdentity(
        _ value: ConnectorDecodedUTF8LogIdentity
    ) -> Bool {
        value.byteCount > 0
            && value.lfByteCount > 0
            && value.crByteCount == 0
            && value.terminalLFPresent
            && (value.utf8BOMByteOffsetsAreBound
                ? value.utf8BOMCount == value.utf8BOMByteOffsets.count
                    && value.utf8BOMByteOffsets
                        == value.utf8BOMByteOffsets.sorted()
                    && value.utf8BOMByteOffsets.allSatisfy {
                        $0 >= 0 && $0 < value.byteCount
                    }
                : value.utf8BOMByteOffsets.isEmpty)
            && isLowercaseHex(value.sha256, count: 64)
            && value.repeatFetchExactlyEqual
            && !value.rawArchiveBytesBound
            && !value.rawArchiveRetained
    }

    private static func seconds(from start: String, to end: String) -> Int? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        guard let startDate = formatter.date(from: start),
              let endDate = formatter.date(from: end)
        else {
            return nil
        }
        return Int(endDate.timeIntervalSince(startDate))
    }
}
