// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// Pure append-only authority for one temporary reviewed-main operational-
/// margin and base-continuity amendment after the V2 measurement authority
/// closed successfully. Run 174 completed within 90 minutes; this authority
/// therefore makes no claim that 90 minutes was insufficient.
/// This value is an evidence record and invariant ledger only. Constructing,
/// encoding, decoding, or validating it performs no filesystem, process, Git,
/// compiler, verifier, workflow, fixture, measurement, or model operation.
public struct PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityV1:
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

    public struct RepositoryClosure: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let pullRequestNumber: Int
        public let baseRevision: String
        public let reviewedHeadRevision: String
        public let reviewedHeadTree: String
        public let reviewedHeadOrderedParentRevisions: [String]
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedMergeParentRevisions: [String]
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let reviewedHeadIsDirectChildOfBase: Bool
        public let historyPreservingTwoParentMergeObserved: Bool
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
        public let mergedAt: String
        public let gitObjectIdentityAlgorithm: String
        public let gitObjectIdentityPurpose: String
        public let sha256EvidenceDigestPurpose: String
        public let gitSHA1MakesNoAuthenticityOrCollisionResistanceClaim: Bool
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
        public let matchingRunCountForHead: Int
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
        public let userStepCount: Int
        public let successfulUserStepCount: Int
        public let failedUserStepCount: Int
        public let skippedUserStepCount: Int
    }

    public struct ConnectorDecodedLogIdentity:
        Codable,
        Equatable,
        Sendable
    {
        public let jobID: Int
        public let representation: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let crByteCount: Int
        public let utf8BOMCount: Int
        public let utf8BOMByteOffsets: [Int]
        public let utf8BOMByteOffsetsAreBound: Bool
        public let terminalLFPresent: Bool
        public let sha256: String
        public let repeatFetchExactlyEqual: Bool
        public let rawArchiveBytesBound: Bool
        public let rawArchiveRetained: Bool
    }

    public struct ExactMainTestClosure: Codable, Equatable, Sendable {
        public let activeLatinTestCount: Int
        public let activeFailureCount: Int
        public let activeSkipCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedMetalTestCount: Int
        public let retainedRuntimeTestCount: Int
        public let retainedTokenizerTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let reviewedFailureCount: Int
        public let reviewedSkipCount: Int
        public let v2AuthorityTestClassName: String
        public let v2AuthorityTestMethodName: String
        public let v2AuthorityTestStartCount: Int
        public let v2AuthorityTestPassCount: Int
        public let v2LauncherInvocationCount: Int
        public let v2EvaluatorInvocationCount: Int
        public let v2MeasurementRecordCount: Int
    }

    public struct HistoricalTimingReference:
        Codable,
        Equatable,
        Sendable
    {
        public let sourceAuthorityID: String
        public let sourceCanonicalByteCount: Int
        public let sourceCanonicalSHA256: String
        public let sourceGitBlob: String
        public let sourceByteCount: Int
        public let sourceLFByteCount: Int
        public let sourceSHA256: String
        public let evidenceDerivedLowerBoundSeconds: Int
        public let historicalCompileAndRuntimeVarianceMeasured: Bool
        public let historicalArithmeticGuaranteedCompletion: Bool
    }

    /// A discrete before/after accounting identity. It is intentionally not a
    /// claim of gauge redundancy or a Noether charge: changing the Git base is
    /// a security-relevant transition. The ledger conserves only explicit
    /// authority, opportunity count, and checked timeout arithmetic.
    public struct ConservationLedger: Codable, Equatable, Sendable {
        public let configuredReviewedMainTimeoutMinutes: Int
        public let configuredReviewedMainTimeoutSeconds: Int
        public let proposedReviewedMainTimeoutMinutes: Int
        public let proposedReviewedMainTimeoutSeconds: Int
        public let timeoutDeltaMinutes: Int
        public let timeoutDeltaSeconds: Int
        public let run174ReviewedDurationSeconds: Int
        public let run171ReviewedDurationSeconds: Int
        public let run174MinusRun171DriftSeconds: Int
        public let run174HeadroomBeforeSeconds: Int
        public let run174HeadroomAfterSeconds: Int
        public let historicalLowerBoundSeconds: Int
        public let historicalHeadroomBeforeSeconds: Int
        public let historicalHeadroomAfterSeconds: Int
        public let selectedReferenceSeconds: Int
        public let selectedReferenceRule: String
        public let selectedReferenceHeadroomAfterSeconds: Int
        public let repairAuthorityTestNominalCompileExcludedAllocationSeconds: Int
        public let repairAuthorityTestHostedReviewedMainRuntimeMeasured: Bool
        public let repairAuthorityTestAllocationExternallyEnforced: Bool
        public let run174PlusNominalRepairTestAllocationSeconds: Int
        public let headroomAfterNominalRepairTestAllocationAt90Seconds: Int
        public let headroomAfterNominalRepairTestAllocationAt120Seconds: Int
        public let selectedReferencePlusNominalRepairTestAllocationSeconds: Int
        public let selectedReferenceAndAllocationHeadroomAt90Seconds: Int
        public let selectedReferenceAndAllocationHeadroomAt120Seconds: Int
        public let futureIndependentReleaseBuildCount: Int
        public let futureEvaluatorCompileCount: Int
        public let futureEvaluatorExecutionCount: Int
        public let futureMeasurementDurationMeasured: Bool
        public let futureMeasurementFitsConfiguredTimeoutEstablished: Bool
        public let futureMeasurementFitsProposedTimeoutGuaranteed: Bool
        public let timeoutIsCeilingNotRuntimeTarget: Bool
        public let demonstrated90MinuteInsufficiencyEstablished: Bool
        public let minimumNecessaryTimeoutEstablished: Bool
        public let boundedOperationalMarginAuthorized: Bool
        public let arithmeticGuaranteesMeasurementCompletion: Bool
        public let mechanicsRuntimeMeasured: Bool
        public let permanentBaselineIncreaseAuthorized: Bool
        public let observationMustRestoreReviewedMainTimeoutMinutes: Int
        public let conservationEquationID: String
        public let arithmeticUsesCheckedIntegerInputsOnly: Bool
    }

    public struct RepairPatchContract: Codable, Equatable, Sendable {
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
        public let workflowJobCount: Int
        public let activeRootUserStepCount: Int
        public let reviewedMainUserStepCount: Int
        public let workflowJobAndStepOrderMustRemainUnchanged: Bool
        public let fetchInvocationCountAndDepthMustRemainUnchanged: Bool
        public let existingFetchDepth: Int
        public let fetchCheckoutTargetsMustRemainUnchanged: Bool
        public let fetchCredentialHandlingMustRemainUnchanged: Bool
        public let existingFetchWantOrderMustRemainUnchanged: Bool
        public let existingOrderedImmutableWantRevisions: [String]
        public let immutableWantPrefixBeforeAdditions: [String]
        public let addedImmutableFetchWantRevisions: [String]
        public let addedImmutableFetchWantCountPerExistingFetch: Int
        public let existingFetchInvocationCount: Int
        public let totalAddedImmutableFetchWantOccurrenceCount: Int
        public let addedWantsRequireRawObjectVerification: Bool
        public let rawObjectVerificationPerformsNoAncestryTraversal: Bool
        public let rawSignaturePresenceDoesNotReverifyGitHubSignature: Bool
        public let additionalFetchInvocationCount: Int
        public let retainedLiveCommandSequenceMustRemainByteIdentical: Bool
        public let v2AuthorityPairMustRemainByteIdentical: Bool
        public let topologyHelperClassifierAndMatrixMustRemainByteIdentical: Bool
        public let topologyHelperInvocationCountPerGate: Int
        public let pullRequestTopologyExplicitRequestRoles: [String]
        public let pushMainTopologyExplicitRequestRoles: [String]
        public let topologyRelationFixedParent1Revision: String
        public let topologyRequestsPerformNoAncestryTraversal: Bool
        public let retiredV1FilesMustRemainByteIdentical: Bool
        public let fixtureInputsMustRemainByteIdentical: Bool
        public let packageManifestMustRemainByteIdentical: Bool
        public let packageLockMustRemainByteIdentical: Bool
        public let v2MechanicsPathCountAddedNow: Int
        public let v2MechanicsInvocationCountNow: Int
        public let actionsArtifactCount: Int
        public let newDependencyNetworkInvocationCount: Int
    }

    public struct BaseContinuityAmendment:
        Codable,
        Equatable,
        Sendable
    {
        public let predecessorRequiresMechanicsDirectChildOfAuthorityMerge: Bool
        public let predecessorForbidsInterveningMainCommit: Bool
        public let predecessorAuthorityMergeRevision: String
        public let narrowlySupersededRuleID: String
        public let narrowlySupersededRuleCount: Int
        public let timingRepairIsOnlyAuthorizedInterveningPatch: Bool
        public let predecessorV2AuthorityPairRemainsByteIdentical: Bool
        public let allOtherV2MeasurementSemanticAndSecurityContractsRemainUnchanged: Bool
        public let exact32CodeOutcomeTaxonomyRemainsUnchanged: Bool
        public let oneShotOpportunityCountBefore: Int
        public let oneShotOpportunityConsumedByRepair: Int
        public let oneShotOpportunityCountAfter: Int
        public let authorizedMechanicsAttemptCountBefore: Int
        public let mechanicsAttemptsCreatedByRepair: Int
        public let authorizedMechanicsAttemptCountAfter: Int
        public let timingRepairCreatesAdditionalOpportunity: Bool
        public let timingRepairMergeRevision: String?
        public let timingRepairReviewedHeadRevision: String?
        public let timingRepairMergeTree: String?
        public let timingRepairClosureRunID: Int?
        public let requiredRepairMergeParent1Revision: String
        public let requiredRepairMergeOrderedParentCount: Int
        public let requiredTimingRepairReviewedHeadDirectChildOfParent1: Bool
        public let requiredTimingRepairReviewedHeadTreeEqualsMergeTree: Bool
        public let requiredRepairMergeTreeEqualsTimingRepairReviewedHeadTree: Bool
        public let requiredRepairMergeParent2EqualsTimingRepairReviewedHead: Bool
        public let requiredRepairMergeSignatureVerified: Bool
        public let requiredRepairMergeSignatureReason: String
        public let requiredClosureEvent: String
        public let requiredClosureRef: String
        public let requiredClosureRunAttempt: Int
        public let requiredClosureMatchingRunCount: Int
        public let requiredClosurePreviousAttemptURLMustBeNil: Bool
        public let requiredClosureRetryCount: Int
        public let requiredClosureRerunCount: Int
        public let requiredClosureActionsArtifactCount: Int
        public let requiredClosureConclusion: String
        public let requiredClosureRunHeadSHAEqualsObservedRepairMerge: Bool
        public let pullRequestGreenIsInsufficient: Bool
        public let currentV2MechanicsAuthorized: Bool
        public let conditionalPostClosureMechanicsRebuildAuthorized: Bool
        public let conditionalAuthorizationPredicate: String
        public let rebuiltMechanicsFixedParent1Source: String
        public let requiredFutureMechanicsHeadDirectChildOfObservedRepairMerge: Bool
        public let requiredFutureMechanicsMergeParent1EqualsObservedRepairMerge: Bool
        public let requiredFutureMechanicsMergeParent2EqualsMechanicsHead: Bool
        public let requiredFutureMechanicsMergeTreeEqualsMechanicsHeadTree: Bool
        public let staleMechanicsBasedOnPredecessorMergeMayMerge: Bool
        public let separateMechanicsReviewAndTestingRequired: Bool
        public let separatePostClosureAuthorityPairRequired: Bool
    }

    /// A total transition policy for the elevated reviewed-main ceiling. The
    /// policy is lifecycle-bounded rather than wall-clock-timed: every path
    /// that does not proceed directly from a valid repair closure into the
    /// separately reviewed mechanics must make restoration the next roadmap
    /// mutation, while every mechanics outcome restores through observation
    /// and retirement.
    public struct TimeoutRestorationPolicy:
        Codable,
        Equatable,
        Sendable
    {
        public let elevatedTimeoutLifecycleID: String
        public let targetReviewedMainTimeoutMinutes: Int
        public let exactTerminalTriggerIDsInOrder: [String]
        public let exactTerminalTriggerCount: Int
        public let repairClosureDisqualificationCovered: Bool
        public let interveningMainBeforeMechanicsCovered: Bool
        public let mechanicsAbandonmentOrBroaderSurfaceCovered: Bool
        public let everyMechanicsOutcomeCovered: Bool
        public let validClosurePermitsOnlyMechanicsOrRestoreOnlyAsNextRoadmapMutation: Bool
        public let restoreOnlyTransitionMustBeNextRoadmapMutation: Bool
        public let restorationTransitionRole: String
        public let restorationTransitionRequiresSeparateReviewAndTesting: Bool
        public let restorationTransitionConsumesMeasurementOpportunity: Bool
        public let restorationTransitionConsumesMechanicsAttempt: Bool
        public let restorationTransitionCreatesMeasurementOpportunity: Bool
        public let restorationTransitionAuthorizesMechanics: Bool
        public let failedRepairClosureAuthorizesMechanics: Bool
        public let wallClockRestorationDeadlineEstablished: Bool
        public let indefiniteElevatedBaselineAuthorized: Bool
    }

    public struct PreservedV2Semantics: Codable, Equatable, Sendable {
        public let predecessorAuthorityCanonicalByteCount: Int
        public let predecessorAuthorityCanonicalSHA256: String
        public let predecessorAuthoritySourceGitBlob: String
        public let predecessorAuthorityTestGitBlob: String
        public let fixtureInputSHA256InOrdinalOrder: [String]
        public let fixtureInputCount: Int
        public let currentAcceptancePinByteCount: Int
        public let currentAcceptancePinSHA256: String
        public let phaseTransitionKeysInOrdinalOrder: [String]
        public let phaseTransitionCount: Int
        public let exactLowLevelResultCodeCount: Int
        public let preservationIsSemanticAndByteIdentityOnly: Bool
        public let preservationPerformsNoExecution: Bool
    }

    public struct OpportunityPreservation: Codable, Equatable, Sendable {
        public let exactLowLevelResultCodeCount: Int
        public let identicalResultCodeCount: Int
        public let differentResultCodeCount: Int
        public let unavailableResultCodeCount: Int
        public let failureResultCodeCount: Int
        public let attemptConsumptionBoundary: String
        public let preBuildTopologyFailureConsumesAttempt: Bool
        public let falseAttemptConsumptionStillRetiresOpportunity: Bool
        public let everyOutcomeRequiresAppendOnlyObservationAndRetirement: Bool
        public let absentRecordCauseRequiresPositiveEvidence: Bool
        public let absentRecordCauseMayBeInferredOrInvented: Bool
        public let timeoutOrAbsentRecordAuthorizesRetry: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementAuthorized: Bool
    }

    public struct ExpectedClosureCounts: Codable, Equatable, Sendable {
        public let activeLatinTestCount: Int
        public let predecessorRootTestCount: Int
        public let repairRootTestCount: Int
        public let isolatedTestCount: Int
        public let repairFocusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let repairAggregateTestCount: Int
        public let predecessorEmbeddedProvenanceRecordCount: Int
        public let repairEmbeddedProvenanceRecordCount: Int
        public let repairNewEmbeddedSourceRecordCount: Int
        public let futureMechanicsRootTestCount: Int
        public let futureMechanicsFocusedWholeTestCount: Int
        public let futureMechanicsAggregateTestCount: Int
        public let futureMechanicsEmbeddedProvenanceRecordCount: Int
        public let futureMechanicsActiveRootUserStepCount: Int
        public let futureMechanicsReviewedMainUserStepCount: Int
        public let repairAuthorityTestCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let actionsArtifactCount: Int
        public let expectedNotObserved: Bool
        public let successEstablished: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let v2AuthorityExactMainClosureEstablished: Bool
        public let exactMainRun174EvidenceEstablished: Bool
        public let boundedTimingAndBaseContinuityRepairAuthorized: Bool
        public let predecessorV2AuthorityPreserved: Bool
        public let filesystemReadPerformedByAuthorityValue: Bool
        public let filesystemWritePerformedByAuthorityValue: Bool
        public let processExecutionPerformedByAuthorityValue: Bool
        public let gitExecutionPerformedByAuthorityValue: Bool
        public let compilerExecutionPerformedByAuthorityValue: Bool
        public let verifierExecutionPerformedByAuthorityValue: Bool
        public let networkExecutionPerformedByAuthorityValue: Bool
        public let fixtureBuildPerformed: Bool
        public let fixtureExecutionPerformed: Bool
        public let evaluatorExecutionPerformed: Bool
        public let measurementMechanicsPerformed: Bool
        public let measurementObservationEstablished: Bool
        public let measurementOutcomeEstablished: Bool
        public let fixtureIdentityEstablished: Bool
        public let repeatBuildDeterminismEstablished: Bool
        public let pinRelationEstablished: Bool
        public let pinRepairAuthorized: Bool
        public let noMutationConfirmationAuthorized: Bool
        public let realMonitorHeldLeaseCanaryAuthorized: Bool
        public let additionalMeasurementOpportunityAuthorized: Bool
        public let retryOrRerunAuthorized: Bool
        public let modelExecutionAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let status: String
    public let v2AuthorityExactFiveIdentity: [FileIdentity]
    public let v2AuthorityExactFiveExcludedIndexSHA256: String
    public let repairExactFiveExcludedIndexSHA256: String
    public let repositoryClosure: RepositoryClosure
    public let pullRequestRun: WorkflowRun
    public let pullRequestActiveJob: Job
    public let pullRequestReviewedJob: Job
    public let pullRequestReviewedJobConnectorTimestampOrderingAnomalyObserved: Bool
    public let pullRequestReviewedJobDurationDerivedFromTimestamps: Bool
    public let exactMainRun: WorkflowRun
    public let exactMainActiveJob: Job
    public let exactMainReviewedJob: Job
    public let exactMainActiveLog: ConnectorDecodedLogIdentity
    public let exactMainReviewedLog: ConnectorDecodedLogIdentity
    public let exactMainTests: ExactMainTestClosure
    public let historicalTimingReference: HistoricalTimingReference
    public let conservationLedger: ConservationLedger
    public let repairPatchContract: RepairPatchContract
    public let baseContinuityAmendment: BaseContinuityAmendment
    public let timeoutRestorationPolicy: TimeoutRestorationPolicy
    public let preservedV2Semantics: PreservedV2Semantics
    public let opportunityPreservation: OpportunityPreservation
    public let expectedClosureCounts: ExpectedClosureCounts
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]

    public static let canonicalByteCount = 23_495
    public static let canonicalSHA256 =
        "b77598fda922e6f3a925a4948ff834286664cf7df7bf4edcff1dadd275b2961c"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_secure_child_validation_fixture_identity_measurement_v2_timing_repair_authority_v1",
        authorityID:
            "ergentics_prime_secure_child_validation_fixture_identity_measurement_v2_timing_repair_authority_v1",
        authorityKind:
            "append_only_dependency_free_nonexecuting_lifecycle_bounded_reviewed_main_operational_margin_and_base_continuity_amendment_authority",
        status:
            "PRECONSUMPTION_V2_TIMING_MARGIN_AMENDMENT_ONLY_exact_main_run174_success_lifecycle_bounded_90_to_120_base_rebind_conditional_no_mechanics_measurement_outcome_or_retry",
        v2AuthorityExactFiveIdentity: v2AuthorityFiles,
        v2AuthorityExactFiveExcludedIndexSHA256:
            "4f528c8a72027a1cd46f6bac6ac40c3d8732a82f0de398f3d3bd1668ec0c48c0",
        repairExactFiveExcludedIndexSHA256:
            "a914a9886f2c9396815fe7235c42532bd229185e342c45322bc078b8c8cf9088",
        repositoryClosure: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            pullRequestNumber: 136,
            baseRevision: "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
            reviewedHeadRevision: "16908cbe5386f07cbc63d8744e768e82775bed31",
            reviewedHeadTree: "4c1a528ab5b5f53a26c9278e627c3d57b2d938cc",
            reviewedHeadOrderedParentRevisions: [
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
            ],
            mergeRevision: "3f69d6e911ca48c39edc55508e93fed64fc48732",
            mergeTree: "4c1a528ab5b5f53a26c9278e627c3d57b2d938cc",
            orderedMergeParentRevisions: [
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
                "16908cbe5386f07cbc63d8744e768e82775bed31",
            ],
            mergeTreeEqualsReviewedHeadTree: true,
            reviewedHeadIsDirectChildOfBase: true,
            historyPreservingTwoParentMergeObserved: true,
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-22T02:32:04Z",
            mergedAt: "2026-08-22T02:32:04Z",
            gitObjectIdentityAlgorithm: "sha1",
            gitObjectIdentityPurpose:
                "repository_native_Git_object_identity_only",
            sha256EvidenceDigestPurpose:
                "frozen_evidence_and_file_byte_integrity_identity",
            gitSHA1MakesNoAuthenticityOrCollisionResistanceClaim: true),
        pullRequestRun: .init(
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 32_546_060_670,
            runNumber: 173,
            runAttempt: 1,
            checkSuiteID: 88_223_758_722,
            event: "pull_request",
            ref: "refs/pull/136/merge",
            headSHA: "16908cbe5386f07cbc63d8744e768e82775bed31",
            status: "completed",
            conclusion: "success",
            createdAt: "2026-08-22T02:22:10Z",
            startedAt: "2026-08-22T02:22:10Z",
            updatedAt: "2026-08-22T02:31:16Z",
            previousAttemptURL: nil,
            matchingRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0,
            actionsArtifactCount: 0),
        pullRequestActiveJob: .init(
            jobID: 96_964_562_115,
            name: "First-party MLX / active-root quarantine",
            runnerLabel: "macos-15",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-22T02:22:13Z",
            completedAt: "2026-08-22T02:31:15Z",
            durationSeconds: 542,
            userStepCount: 5,
            successfulUserStepCount: 5,
            failedUserStepCount: 0,
            skippedUserStepCount: 0),
        pullRequestReviewedJob: .init(
            jobID: 96_965_720_182,
            name: "Reviewed main / focused source contracts",
            runnerLabel: "macos-26",
            status: "completed",
            conclusion: "skipped",
            startedAt: "2026-08-22T02:31:16Z",
            completedAt: "2026-08-22T02:31:15Z",
            durationSeconds: 0,
            userStepCount: 0,
            successfulUserStepCount: 0,
            failedUserStepCount: 0,
            skippedUserStepCount: 0),
        pullRequestReviewedJobConnectorTimestampOrderingAnomalyObserved: true,
        pullRequestReviewedJobDurationDerivedFromTimestamps: false,
        exactMainRun: .init(
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 32_546_516_122,
            runNumber: 174,
            runAttempt: 1,
            checkSuiteID: 88_224_868_710,
            event: "push",
            ref: "refs/heads/main",
            headSHA: "3f69d6e911ca48c39edc55508e93fed64fc48732",
            status: "completed",
            conclusion: "success",
            createdAt: "2026-08-22T02:32:06Z",
            startedAt: "2026-08-22T02:32:06Z",
            updatedAt: "2026-08-22T03:58:07Z",
            previousAttemptURL: nil,
            matchingRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0,
            actionsArtifactCount: 0),
        exactMainActiveJob: .init(
            jobID: 96_965_818_328,
            name: "First-party MLX / active-root quarantine",
            runnerLabel: "macos-15",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-22T02:32:09Z",
            completedAt: "2026-08-22T02:43:01Z",
            durationSeconds: 652,
            userStepCount: 5,
            successfulUserStepCount: 5,
            failedUserStepCount: 0,
            skippedUserStepCount: 0),
        exactMainReviewedJob: .init(
            jobID: 96_967_143_447,
            name: "Reviewed main / focused source contracts",
            runnerLabel: "macos-26",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-22T02:43:05Z",
            completedAt: "2026-08-22T03:58:06Z",
            durationSeconds: 4_501,
            userStepCount: 5,
            successfulUserStepCount: 5,
            failedUserStepCount: 0,
            skippedUserStepCount: 0),
        exactMainActiveLog: .init(
            jobID: 96_965_818_328,
            representation:
                "connector_decoded_utf8_job_log_with_leading_bom_and_terminal_lf",
            byteCount: 401_541,
            lfByteCount: 1_934,
            crByteCount: 0,
            utf8BOMCount: 1,
            utf8BOMByteOffsets: [0],
            utf8BOMByteOffsetsAreBound: true,
            terminalLFPresent: true,
            sha256:
                "d1dc2560122658574b903c5a2607af92ec4bd686ab432a36dd10bf335301b99a",
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        exactMainReviewedLog: .init(
            jobID: 96_967_143_447,
            representation:
                "connector_decoded_utf8_job_log_with_chunk_boms_and_terminal_lf",
            byteCount: 10_348_696,
            lfByteCount: 79_127,
            crByteCount: 0,
            utf8BOMCount: 5,
            utf8BOMByteOffsets: [0, 2_112_505, 4_225_437, 6_338_033, 8_452_544],
            utf8BOMByteOffsetsAreBound: true,
            terminalLFPresent: true,
            sha256:
                "70e6c5d538857e1da1b77a67ef52697ce5d444be25918de8cb3fa9f43b09724f",
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        exactMainTests: .init(
            activeLatinTestCount: 116,
            activeFailureCount: 0,
            activeSkipCount: 0,
            rootTestCount: 90,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 96,
            retainedMetalTestCount: 44,
            retainedRuntimeTestCount: 1,
            retainedTokenizerTestCount: 1,
            retainedLiveTestCount: 46,
            aggregateTestCount: 142,
            reviewedFailureCount: 0,
            reviewedSkipCount: 0,
            v2AuthorityTestClassName:
                "PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityTests",
            v2AuthorityTestMethodName:
                "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
            v2AuthorityTestStartCount: 1,
            v2AuthorityTestPassCount: 1,
            v2LauncherInvocationCount: 0,
            v2EvaluatorInvocationCount: 0,
            v2MeasurementRecordCount: 0),
        historicalTimingReference: .init(
            sourceAuthorityID:
                "ergentics_prime_exact_revision_topology_relation_timeout_repair_authority_v1",
            sourceCanonicalByteCount: 18_515,
            sourceCanonicalSHA256:
                "667a8c408635407eecb5cc2fd8381baf1cc1f28fc771ff541c66b3816b97a5f4",
            sourceGitBlob: "ff4d218de7b95a908d75e70037ae3e5f651eaa0c",
            sourceByteCount: 70_984,
            sourceLFByteCount: 1_386,
            sourceSHA256:
                "3de1ce8ffd050dd47f1913eaaaf05459e9bf3a6a5b76a81574c8b0ca679943f4",
            evidenceDerivedLowerBoundSeconds: 4_859,
            historicalCompileAndRuntimeVarianceMeasured: false,
            historicalArithmeticGuaranteedCompletion: false),
        conservationLedger: .init(
            configuredReviewedMainTimeoutMinutes: 90,
            configuredReviewedMainTimeoutSeconds: 5_400,
            proposedReviewedMainTimeoutMinutes: 120,
            proposedReviewedMainTimeoutSeconds: 7_200,
            timeoutDeltaMinutes: 30,
            timeoutDeltaSeconds: 1_800,
            run174ReviewedDurationSeconds: 4_501,
            run171ReviewedDurationSeconds: 4_046,
            run174MinusRun171DriftSeconds: 455,
            run174HeadroomBeforeSeconds: 899,
            run174HeadroomAfterSeconds: 2_699,
            historicalLowerBoundSeconds: 4_859,
            historicalHeadroomBeforeSeconds: 541,
            historicalHeadroomAfterSeconds: 2_341,
            selectedReferenceSeconds: 4_859,
            selectedReferenceRule:
                "maximum_of_run174_reviewed_duration_and_frozen_historical_complete_composition_lower_bound",
            selectedReferenceHeadroomAfterSeconds: 2_341,
            repairAuthorityTestNominalCompileExcludedAllocationSeconds: 10,
            repairAuthorityTestHostedReviewedMainRuntimeMeasured: false,
            repairAuthorityTestAllocationExternallyEnforced: false,
            run174PlusNominalRepairTestAllocationSeconds: 4_511,
            headroomAfterNominalRepairTestAllocationAt90Seconds: 889,
            headroomAfterNominalRepairTestAllocationAt120Seconds: 2_689,
            selectedReferencePlusNominalRepairTestAllocationSeconds: 4_869,
            selectedReferenceAndAllocationHeadroomAt90Seconds: 531,
            selectedReferenceAndAllocationHeadroomAt120Seconds: 2_331,
            futureIndependentReleaseBuildCount: 2,
            futureEvaluatorCompileCount: 1,
            futureEvaluatorExecutionCount: 1,
            futureMeasurementDurationMeasured: false,
            futureMeasurementFitsConfiguredTimeoutEstablished: false,
            futureMeasurementFitsProposedTimeoutGuaranteed: false,
            timeoutIsCeilingNotRuntimeTarget: true,
            demonstrated90MinuteInsufficiencyEstablished: false,
            minimumNecessaryTimeoutEstablished: false,
            boundedOperationalMarginAuthorized: true,
            arithmeticGuaranteesMeasurementCompletion: false,
            mechanicsRuntimeMeasured: false,
            permanentBaselineIncreaseAuthorized: false,
            observationMustRestoreReviewedMainTimeoutMinutes: 90,
            conservationEquationID:
                "proposed_timeout_seconds_equals_selected_reference_seconds_plus_nominal_repair_test_allocation_seconds_plus_unallocated_headroom_seconds",
            arithmeticUsesCheckedIntegerInputsOnly: true),
        repairPatchContract: .init(
            exactOrderedPaths: repairPaths,
            exactPathCount: 5,
            modifiedExistingPathCount: 3,
            addedPathCount: 2,
            workflowTimeoutLiteralBefore: "timeout-minutes: 90",
            workflowTimeoutLiteralAfter: "timeout-minutes: 120",
            workflowTimeoutLiteralChangeOccurrenceCount: 1,
            activeRootTimeoutMinutes: 45,
            reviewedMainTimeoutBeforeMinutes: 90,
            reviewedMainTimeoutAfterMinutes: 120,
            workflowJobCount: 2,
            activeRootUserStepCount: 5,
            reviewedMainUserStepCount: 5,
            workflowJobAndStepOrderMustRemainUnchanged: true,
            fetchInvocationCountAndDepthMustRemainUnchanged: true,
            existingFetchDepth: 2,
            fetchCheckoutTargetsMustRemainUnchanged: true,
            fetchCredentialHandlingMustRemainUnchanged: true,
            existingFetchWantOrderMustRemainUnchanged: true,
            existingOrderedImmutableWantRevisions: [
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
                "444cd402c966521f6163f4949b4a73f9a5184e29",
                "1bc2471d12f034d51ae6eb8c977198635bc37717",
                "3c40cce6350da7ed0ce0f5ccb0620f76feff0501",
                "3d2148227d264502010e64a0c0db70bc1362c50c",
                "6a811d3029bdb77e038750694fbf10eec0f358f8",
                "5623872afda1895630ba0eacdfab76961c5e755b",
                "57f4264dd865a47766e27a9dbc06a82dd1fbfe11",
                "f5db7101cf3538daae103ba56601a509ad8bad80",
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
                "75b14056b75e8af6af0c070453f7ef14ac10a063",
                "3ad8087ed6e403ba81f46bba97ceb5d440979e0a",
                "ef64686e76d2d67e46deb696bfeef18ea96c96a2",
                "e1d90e3f2ae6c4d3c279bf5fb64ce3baafc1f540",
                "0abcb4ad5487a775627bbb587184c375dd691978",
                "4570716892722873757de6eae1bd897167d674eb",
                "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
                "b3402efd96d3ff893a0c2b73897cf48c9b313c8c",
                "232a17e8f58a297919366d963ee1d7bc38cdbaee",
                "a4d8583fa7c59f885002ee06a07c1d5264c0c223",
            ],
            immutableWantPrefixBeforeAdditions: [
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
                "444cd402c966521f6163f4949b4a73f9a5184e29",
                "1bc2471d12f034d51ae6eb8c977198635bc37717",
            ],
            addedImmutableFetchWantRevisions: [
                "3f69d6e911ca48c39edc55508e93fed64fc48732",
                "16908cbe5386f07cbc63d8744e768e82775bed31",
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
            ],
            addedImmutableFetchWantCountPerExistingFetch: 3,
            existingFetchInvocationCount: 2,
            totalAddedImmutableFetchWantOccurrenceCount: 6,
            addedWantsRequireRawObjectVerification: true,
            rawObjectVerificationPerformsNoAncestryTraversal: true,
            rawSignaturePresenceDoesNotReverifyGitHubSignature: true,
            additionalFetchInvocationCount: 0,
            retainedLiveCommandSequenceMustRemainByteIdentical: true,
            v2AuthorityPairMustRemainByteIdentical: true,
            topologyHelperClassifierAndMatrixMustRemainByteIdentical: true,
            topologyHelperInvocationCountPerGate: 1,
            pullRequestTopologyExplicitRequestRoles: [
                "current_exact_revision",
                "verified_v2_authority_base",
                "verified_implementation_base",
            ],
            pushMainTopologyExplicitRequestRoles: [
                "verified_v2_authority_base",
                "verified_implementation_base",
            ],
            topologyRelationFixedParent1Revision:
                "3f69d6e911ca48c39edc55508e93fed64fc48732",
            topologyRequestsPerformNoAncestryTraversal: true,
            retiredV1FilesMustRemainByteIdentical: true,
            fixtureInputsMustRemainByteIdentical: true,
            packageManifestMustRemainByteIdentical: true,
            packageLockMustRemainByteIdentical: true,
            v2MechanicsPathCountAddedNow: 0,
            v2MechanicsInvocationCountNow: 0,
            actionsArtifactCount: 0,
            newDependencyNetworkInvocationCount: 0),
        baseContinuityAmendment: .init(
            predecessorRequiresMechanicsDirectChildOfAuthorityMerge: true,
            predecessorForbidsInterveningMainCommit: true,
            predecessorAuthorityMergeRevision:
                "3f69d6e911ca48c39edc55508e93fed64fc48732",
            narrowlySupersededRuleID:
                "v2_mechanics_direct_child_and_no_intervening_main_base_literal_3f69d6e911ca48c39edc55508e93fed64fc48732",
            narrowlySupersededRuleCount: 1,
            timingRepairIsOnlyAuthorizedInterveningPatch: true,
            predecessorV2AuthorityPairRemainsByteIdentical: true,
            allOtherV2MeasurementSemanticAndSecurityContractsRemainUnchanged: true,
            exact32CodeOutcomeTaxonomyRemainsUnchanged: true,
            oneShotOpportunityCountBefore: 1,
            oneShotOpportunityConsumedByRepair: 0,
            oneShotOpportunityCountAfter: 1,
            authorizedMechanicsAttemptCountBefore: 1,
            mechanicsAttemptsCreatedByRepair: 0,
            authorizedMechanicsAttemptCountAfter: 1,
            timingRepairCreatesAdditionalOpportunity: false,
            timingRepairMergeRevision: nil,
            timingRepairReviewedHeadRevision: nil,
            timingRepairMergeTree: nil,
            timingRepairClosureRunID: nil,
            requiredRepairMergeParent1Revision:
                "3f69d6e911ca48c39edc55508e93fed64fc48732",
            requiredRepairMergeOrderedParentCount: 2,
            requiredTimingRepairReviewedHeadDirectChildOfParent1: true,
            requiredTimingRepairReviewedHeadTreeEqualsMergeTree: true,
            requiredRepairMergeTreeEqualsTimingRepairReviewedHeadTree: true,
            requiredRepairMergeParent2EqualsTimingRepairReviewedHead: true,
            requiredRepairMergeSignatureVerified: true,
            requiredRepairMergeSignatureReason: "valid",
            requiredClosureEvent: "push",
            requiredClosureRef: "refs/heads/main",
            requiredClosureRunAttempt: 1,
            requiredClosureMatchingRunCount: 1,
            requiredClosurePreviousAttemptURLMustBeNil: true,
            requiredClosureRetryCount: 0,
            requiredClosureRerunCount: 0,
            requiredClosureActionsArtifactCount: 0,
            requiredClosureConclusion: "success",
            requiredClosureRunHeadSHAEqualsObservedRepairMerge: true,
            pullRequestGreenIsInsufficient: true,
            currentV2MechanicsAuthorized: false,
            conditionalPostClosureMechanicsRebuildAuthorized: true,
            conditionalAuthorizationPredicate:
                "unique_attempt1_direct_push_main_run_for_observed_timing_repair_merge_is_successful",
            rebuiltMechanicsFixedParent1Source:
                "future_observed_timing_repair_merge_revision_after_unique_attempt1_direct_push_main_success",
            requiredFutureMechanicsHeadDirectChildOfObservedRepairMerge: true,
            requiredFutureMechanicsMergeParent1EqualsObservedRepairMerge: true,
            requiredFutureMechanicsMergeParent2EqualsMechanicsHead: true,
            requiredFutureMechanicsMergeTreeEqualsMechanicsHeadTree: true,
            staleMechanicsBasedOnPredecessorMergeMayMerge: false,
            separateMechanicsReviewAndTestingRequired: true,
            separatePostClosureAuthorityPairRequired: false),
        timeoutRestorationPolicy: .init(
            elevatedTimeoutLifecycleID:
                "reviewed_main_120_from_repair_merge_until_mechanics_observation_or_restore_only_abort",
            targetReviewedMainTimeoutMinutes: 90,
            exactTerminalTriggerIDsInOrder: [
                "repair_closure_cannot_establish_unique_attempt1_direct_push_main_success",
                "main_intervenes_after_valid_closure_before_mechanics",
                "mechanics_is_abandoned_or_requires_broader_surface",
                "mechanics_reaches_any_terminal_outcome",
            ],
            exactTerminalTriggerCount: 4,
            repairClosureDisqualificationCovered: true,
            interveningMainBeforeMechanicsCovered: true,
            mechanicsAbandonmentOrBroaderSurfaceCovered: true,
            everyMechanicsOutcomeCovered: true,
            validClosurePermitsOnlyMechanicsOrRestoreOnlyAsNextRoadmapMutation: true,
            restoreOnlyTransitionMustBeNextRoadmapMutation: true,
            restorationTransitionRole:
                "append_only_exact5_restore_only_observation_or_abandonment_transition",
            restorationTransitionRequiresSeparateReviewAndTesting: true,
            restorationTransitionConsumesMeasurementOpportunity: false,
            restorationTransitionConsumesMechanicsAttempt: false,
            restorationTransitionCreatesMeasurementOpportunity: false,
            restorationTransitionAuthorizesMechanics: false,
            failedRepairClosureAuthorizesMechanics: false,
            wallClockRestorationDeadlineEstablished: false,
            indefiniteElevatedBaselineAuthorized: false),
        preservedV2Semantics: .init(
            predecessorAuthorityCanonicalByteCount: 41_626,
            predecessorAuthorityCanonicalSHA256:
                "d32cc3d90e5476e6f279d24bcb392f570358836c702429ecebf27dc1458077c4",
            predecessorAuthoritySourceGitBlob:
                "44dac55cb6620f9f667cf564efb137102e1546c8",
            predecessorAuthorityTestGitBlob:
                "a7f5624d2147f4852b2b0422a90c14776689b4b2",
            fixtureInputSHA256InOrdinalOrder: [
                "99354cfc3da2d75ac960d1c704257656eec563bc17344d694678626ae9c1f518",
                "d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a",
                "b8476f18b4ee05b10e208cc37667d3c69e117bd5eda0162e77804570c5713a6b",
                "f016793fb012c9dc70a47b5ea0ba325f582d1e7c0c5a84b303855cc8543eb274",
                "1ed890d017b67c97a0d980d58cb7614bb71362091c02b03d26a26222b24d5fcd",
            ],
            fixtureInputCount: 5,
            currentAcceptancePinByteCount: 89_632,
            currentAcceptancePinSHA256:
                "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd",
            phaseTransitionKeysInOrdinalOrder: [
                "DIFFERENT:nil:terminal",
                "UNAVAILABLE:nil:terminal",
                "FAILURE:nil:terminal",
                "IDENTICAL:MATCH:separate_no_mutation_confirmation_authority",
                "IDENTICAL:DIFFERENT:separate_exact_pin_repair_authority",
            ],
            phaseTransitionCount: 5,
            exactLowLevelResultCodeCount: 32,
            preservationIsSemanticAndByteIdentityOnly: true,
            preservationPerformsNoExecution: true),
        opportunityPreservation: .init(
            exactLowLevelResultCodeCount: 32,
            identicalResultCodeCount: 2,
            differentResultCodeCount: 1,
            unavailableResultCodeCount: 23,
            failureResultCodeCount: 6,
            attemptConsumptionBoundary:
                "immediately_before_first_of_two_independent_release_fixture_builds",
            preBuildTopologyFailureConsumesAttempt: false,
            falseAttemptConsumptionStillRetiresOpportunity: true,
            everyOutcomeRequiresAppendOnlyObservationAndRetirement: true,
            absentRecordCauseRequiresPositiveEvidence: true,
            absentRecordCauseMayBeInferredOrInvented: false,
            timeoutOrAbsentRecordAuthorizesRetry: false,
            retryAuthorized: false,
            rerunAuthorized: false,
            replacementAuthorized: false),
        expectedClosureCounts: .init(
            activeLatinTestCount: 116,
            predecessorRootTestCount: 90,
            repairRootTestCount: 91,
            isolatedTestCount: 6,
            repairFocusedWholeTestCount: 97,
            retainedLiveTestCount: 46,
            repairAggregateTestCount: 143,
            predecessorEmbeddedProvenanceRecordCount: 532,
            repairEmbeddedProvenanceRecordCount: 534,
            repairNewEmbeddedSourceRecordCount: 2,
            futureMechanicsRootTestCount: 91,
            futureMechanicsFocusedWholeTestCount: 97,
            futureMechanicsAggregateTestCount: 143,
            futureMechanicsEmbeddedProvenanceRecordCount: 536,
            futureMechanicsActiveRootUserStepCount: 5,
            futureMechanicsReviewedMainUserStepCount: 6,
            repairAuthorityTestCount: 1,
            failureCount: 0,
            skipCount: 0,
            actionsArtifactCount: 0,
            expectedNotObserved: true,
            successEstablished: false),
        authorityCeiling: .init(
            v2AuthorityExactMainClosureEstablished: true,
            exactMainRun174EvidenceEstablished: true,
            boundedTimingAndBaseContinuityRepairAuthorized: true,
            predecessorV2AuthorityPreserved: true,
            filesystemReadPerformedByAuthorityValue: false,
            filesystemWritePerformedByAuthorityValue: false,
            processExecutionPerformedByAuthorityValue: false,
            gitExecutionPerformedByAuthorityValue: false,
            compilerExecutionPerformedByAuthorityValue: false,
            verifierExecutionPerformedByAuthorityValue: false,
            networkExecutionPerformedByAuthorityValue: false,
            fixtureBuildPerformed: false,
            fixtureExecutionPerformed: false,
            evaluatorExecutionPerformed: false,
            measurementMechanicsPerformed: false,
            measurementObservationEstablished: false,
            measurementOutcomeEstablished: false,
            fixtureIdentityEstablished: false,
            repeatBuildDeterminismEstablished: false,
            pinRelationEstablished: false,
            pinRepairAuthorized: false,
            noMutationConfirmationAuthorized: false,
            realMonitorHeldLeaseCanaryAuthorized: false,
            additionalMeasurementOpportunityAuthorized: false,
            retryOrRerunAuthorized: false,
            modelExecutionAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        orderedRequiredSeparateActions: [
            "independently_review_and_bind_the_canonical_source_test_and_exact_main_evidence_pins",
            "merge_only_this_pure_exact5_90_to_120_minute_timing_and_base_continuity_repair",
            "observe_one_unique_attempt1_direct_push_main_exact_main_closure",
            "do_not_invoke_build_or_consume_the_v2_measurement_opportunity_in_this_repair",
            "only_after_green_closure_rebuild_the_previously_authorized_exact5_v2_mechanics_with_the_observed_repair_merge_as_fixed_parent1",
            "preserve_the_single_opportunity_exact32_outcome_taxonomy_and_terminal_no_retry_semantics",
            "if_repair_closure_cannot_establish_unique_attempt1_direct_push_main_success_make_the_next_roadmap_mutation_append_only_restore_only_to_90_and_do_not_authorize_mechanics",
            "if_main_intervenes_or_mechanics_is_abandoned_or_requires_broader_surface_make_the_next_roadmap_mutation_append_only_restore_only_to_90",
            "after_the_one_shot_mechanics_immediately_append_outcome_and_retirement_and_restore_reviewed_main_timeout_to_90_minutes",
            "every_restore_only_transition_consumes_neither_the_measurement_opportunity_nor_the_mechanics_attempt_and_authorizes_no_mechanics",
            "no_terminal_path_may_leave_120_as_an_indefinite_reviewed_main_baseline",
        ])

    public func canonicalData() throws -> Data {
        try validateExactV1()
        return try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 131_072 else {
            throw
                PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw
                PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityError
                .noncanonicalEncoding
        }
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        try validateRelationsV1()
        guard self == Self.frozenV1 else {
            throw
                PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityError
                .contractDrift
        }
    }

    /// Validates the correlated semantic relations without relying on frozen
    /// whole-value equality. The exhaustive test invokes this entry directly
    /// on plain-decoded mutations so each conservation, topology, and
    /// restoration predicate remains independently exercised.
    func validateRelationsV1() throws {
        let files = v2AuthorityExactFiveIdentity
        let closure = repositoryClosure
        let tests = exactMainTests
        let history = historicalTimingReference
        let ledger = conservationLedger
        let patch = repairPatchContract
        let continuity = baseContinuityAmendment
        let restoration = timeoutRestorationPolicy
        let preserved = preservedV2Semantics
        let opportunity = opportunityPreservation
        let counts = expectedClosureCounts
        let falseCeilingClaims = [
            authorityCeiling.filesystemReadPerformedByAuthorityValue,
            authorityCeiling.filesystemWritePerformedByAuthorityValue,
            authorityCeiling.processExecutionPerformedByAuthorityValue,
            authorityCeiling.gitExecutionPerformedByAuthorityValue,
            authorityCeiling.compilerExecutionPerformedByAuthorityValue,
            authorityCeiling.verifierExecutionPerformedByAuthorityValue,
            authorityCeiling.networkExecutionPerformedByAuthorityValue,
            authorityCeiling.fixtureBuildPerformed,
            authorityCeiling.fixtureExecutionPerformed,
            authorityCeiling.evaluatorExecutionPerformed,
            authorityCeiling.measurementMechanicsPerformed,
            authorityCeiling.measurementObservationEstablished,
            authorityCeiling.measurementOutcomeEstablished,
            authorityCeiling.fixtureIdentityEstablished,
            authorityCeiling.repeatBuildDeterminismEstablished,
            authorityCeiling.pinRelationEstablished,
            authorityCeiling.pinRepairAuthorized,
            authorityCeiling.noMutationConfirmationAuthorized,
            authorityCeiling.realMonitorHeldLeaseCanaryAuthorized,
            authorityCeiling.additionalMeasurementOpportunityAuthorized,
            authorityCeiling.retryOrRerunAuthorized,
            authorityCeiling.modelExecutionAuthorized,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
        ]
        guard schemaVersion == 1,
              files.count == 5,
              files.map(\.ordinal) == [1, 2, 3, 4, 5],
              Set(files.map(\.path)).count == 5,
              files.map(\.gitMode)
                == ["100755", "100644", "100644", "100644", "100644"],
              files.allSatisfy({
                  $0.byteCount > 0 && $0.lfByteCount > 0
                      && $0.crByteCount == 0
                      && Self.isLowercaseHex($0.gitBlob, count: 40)
                      && Self.isLowercaseHex($0.sha256, count: 64)
              }),
              Self.isLowercaseHex(
                  v2AuthorityExactFiveExcludedIndexSHA256,
                  count: 64),
              Self.isLowercaseHex(
                  repairExactFiveExcludedIndexSHA256,
                  count: 64),
              closure.mergeRevision == exactMainRun.headSHA,
              closure.mergeTree == closure.reviewedHeadTree,
              closure.orderedMergeParentRevisions
                == [closure.baseRevision, closure.reviewedHeadRevision],
              closure.reviewedHeadOrderedParentRevisions
                == [closure.baseRevision],
              closure.mergeTreeEqualsReviewedHeadTree,
              closure.reviewedHeadIsDirectChildOfBase,
              closure.historyPreservingTwoParentMergeObserved,
              closure.githubSignatureVerified,
              closure.githubSignatureReason == "valid",
              closure.gitObjectIdentityAlgorithm == "sha1",
              closure.gitSHA1MakesNoAuthenticityOrCollisionResistanceClaim,
              Self.validRun(pullRequestRun, event: "pull_request"),
              Self.validRun(exactMainRun, event: "push"),
              pullRequestRun.headSHA == closure.reviewedHeadRevision,
              exactMainRun.headSHA == closure.mergeRevision,
              pullRequestRun.runNumber == 173,
              exactMainRun.runNumber == 174,
              Self.validJob(pullRequestActiveJob, expectedDuration: 542),
              pullRequestReviewedJob.conclusion == "skipped",
              pullRequestReviewedJob.durationSeconds == 0,
              pullRequestReviewedJob.userStepCount == 0,
              pullRequestReviewedJobConnectorTimestampOrderingAnomalyObserved,
              !pullRequestReviewedJobDurationDerivedFromTimestamps,
              Self.validJob(exactMainActiveJob, expectedDuration: 652),
              Self.validJob(exactMainReviewedJob, expectedDuration: 4_501),
              Self.validLog(exactMainActiveLog),
              Self.validLog(exactMainReviewedLog),
              exactMainActiveLog.jobID == exactMainActiveJob.jobID,
              exactMainReviewedLog.jobID == exactMainReviewedJob.jobID,
              tests.activeLatinTestCount == 116,
              tests.activeFailureCount == 0,
              tests.activeSkipCount == 0,
              tests.isolatedGroupTestCounts == [1, 1, 2, 2],
              Self.checkedSum(tests.isolatedGroupTestCounts)
                == tests.isolatedTestCount,
              Self.checkedAdd(tests.rootTestCount, tests.isolatedTestCount)
                == tests.focusedWholeTestCount,
              Self.checkedSum([
                  tests.retainedMetalTestCount,
                  tests.retainedRuntimeTestCount,
                  tests.retainedTokenizerTestCount,
              ]) == tests.retainedLiveTestCount,
              Self.checkedAdd(tests.focusedWholeTestCount, tests.retainedLiveTestCount)
                == tests.aggregateTestCount,
              tests.reviewedFailureCount == 0,
              tests.reviewedSkipCount == 0,
              tests.v2AuthorityTestStartCount == 1,
              tests.v2AuthorityTestPassCount == 1,
              tests.v2LauncherInvocationCount == 0,
              tests.v2EvaluatorInvocationCount == 0,
              tests.v2MeasurementRecordCount == 0,
              history.sourceAuthorityID
                == "ergentics_prime_exact_revision_topology_relation_timeout_repair_authority_v1",
              history.sourceCanonicalByteCount == 18_515,
              history.sourceCanonicalSHA256
                == "667a8c408635407eecb5cc2fd8381baf1cc1f28fc771ff541c66b3816b97a5f4",
              history.sourceGitBlob
                == "ff4d218de7b95a908d75e70037ae3e5f651eaa0c",
              history.sourceByteCount == 70_984,
              history.sourceLFByteCount == 1_386,
              history.sourceSHA256
                == "3de1ce8ffd050dd47f1913eaaaf05459e9bf3a6a5b76a81574c8b0ca679943f4",
              history.evidenceDerivedLowerBoundSeconds == 4_859,
              !history.historicalCompileAndRuntimeVarianceMeasured,
              !history.historicalArithmeticGuaranteedCompletion,
              Self.checkedMultiply(
                  ledger.configuredReviewedMainTimeoutMinutes,
                  60) == ledger.configuredReviewedMainTimeoutSeconds,
              Self.checkedMultiply(
                  ledger.proposedReviewedMainTimeoutMinutes,
                  60) == ledger.proposedReviewedMainTimeoutSeconds,
              Self.checkedSubtract(
                  ledger.proposedReviewedMainTimeoutMinutes,
                  ledger.configuredReviewedMainTimeoutMinutes)
                == ledger.timeoutDeltaMinutes,
              Self.checkedSubtract(
                  ledger.proposedReviewedMainTimeoutSeconds,
                  ledger.configuredReviewedMainTimeoutSeconds)
                == ledger.timeoutDeltaSeconds,
              ledger.run174ReviewedDurationSeconds
                == exactMainReviewedJob.durationSeconds,
              ledger.run171ReviewedDurationSeconds == 4_046,
              Self.checkedSubtract(
                  ledger.run174ReviewedDurationSeconds,
                  ledger.run171ReviewedDurationSeconds)
                == ledger.run174MinusRun171DriftSeconds,
              Self.checkedSubtract(
                  ledger.configuredReviewedMainTimeoutSeconds,
                  ledger.run174ReviewedDurationSeconds)
                == ledger.run174HeadroomBeforeSeconds,
              Self.checkedSubtract(
                  ledger.proposedReviewedMainTimeoutSeconds,
                  ledger.run174ReviewedDurationSeconds)
                == ledger.run174HeadroomAfterSeconds,
              ledger.historicalLowerBoundSeconds
                == history.evidenceDerivedLowerBoundSeconds,
              Self.checkedSubtract(
                  ledger.configuredReviewedMainTimeoutSeconds,
                  ledger.historicalLowerBoundSeconds)
                == ledger.historicalHeadroomBeforeSeconds,
              Self.checkedSubtract(
                  ledger.proposedReviewedMainTimeoutSeconds,
                  ledger.historicalLowerBoundSeconds)
                == ledger.historicalHeadroomAfterSeconds,
              ledger.selectedReferenceSeconds
                == max(
                    ledger.run174ReviewedDurationSeconds,
                    ledger.historicalLowerBoundSeconds),
              ledger.selectedReferenceRule
                == "maximum_of_run174_reviewed_duration_and_frozen_historical_complete_composition_lower_bound",
              Self.checkedSubtract(
                  ledger.proposedReviewedMainTimeoutSeconds,
                  ledger.selectedReferenceSeconds)
                == ledger.selectedReferenceHeadroomAfterSeconds,
              ledger.repairAuthorityTestNominalCompileExcludedAllocationSeconds == 10,
              !ledger.repairAuthorityTestHostedReviewedMainRuntimeMeasured,
              !ledger.repairAuthorityTestAllocationExternallyEnforced,
              Self.checkedAdd(
                  ledger.run174ReviewedDurationSeconds,
                  ledger.repairAuthorityTestNominalCompileExcludedAllocationSeconds)
                == ledger.run174PlusNominalRepairTestAllocationSeconds,
              Self.checkedSubtract(
                  ledger.configuredReviewedMainTimeoutSeconds,
                  ledger.run174PlusNominalRepairTestAllocationSeconds)
                == ledger.headroomAfterNominalRepairTestAllocationAt90Seconds,
              Self.checkedSubtract(
                  ledger.proposedReviewedMainTimeoutSeconds,
                  ledger.run174PlusNominalRepairTestAllocationSeconds)
                == ledger.headroomAfterNominalRepairTestAllocationAt120Seconds,
              Self.checkedAdd(
                  ledger.selectedReferenceSeconds,
                  ledger.repairAuthorityTestNominalCompileExcludedAllocationSeconds)
                == ledger.selectedReferencePlusNominalRepairTestAllocationSeconds,
              Self.checkedSubtract(
                  ledger.configuredReviewedMainTimeoutSeconds,
                  ledger.selectedReferencePlusNominalRepairTestAllocationSeconds)
                == ledger.selectedReferenceAndAllocationHeadroomAt90Seconds,
              Self.checkedSubtract(
                  ledger.proposedReviewedMainTimeoutSeconds,
                  ledger.selectedReferencePlusNominalRepairTestAllocationSeconds)
                == ledger.selectedReferenceAndAllocationHeadroomAt120Seconds,
              Self.checkedSum([
                  ledger.selectedReferenceSeconds,
                  ledger.repairAuthorityTestNominalCompileExcludedAllocationSeconds,
                  ledger.selectedReferenceAndAllocationHeadroomAt120Seconds,
              ]) == ledger.proposedReviewedMainTimeoutSeconds,
              ledger.futureIndependentReleaseBuildCount == 2,
              ledger.futureEvaluatorCompileCount == 1,
              ledger.futureEvaluatorExecutionCount == 1,
              !ledger.futureMeasurementDurationMeasured,
              !ledger.futureMeasurementFitsConfiguredTimeoutEstablished,
              !ledger.futureMeasurementFitsProposedTimeoutGuaranteed,
              ledger.timeoutIsCeilingNotRuntimeTarget,
              !ledger.demonstrated90MinuteInsufficiencyEstablished,
              !ledger.minimumNecessaryTimeoutEstablished,
              ledger.boundedOperationalMarginAuthorized,
              !ledger.arithmeticGuaranteesMeasurementCompletion,
              !ledger.mechanicsRuntimeMeasured,
              !ledger.permanentBaselineIncreaseAuthorized,
              ledger.observationMustRestoreReviewedMainTimeoutMinutes
                == ledger.configuredReviewedMainTimeoutMinutes,
              ledger.conservationEquationID
                == "proposed_timeout_seconds_equals_selected_reference_seconds_plus_nominal_repair_test_allocation_seconds_plus_unallocated_headroom_seconds",
              ledger.arithmeticUsesCheckedIntegerInputsOnly,
              patch.exactPathCount == 5,
              patch.exactOrderedPaths.count == 5,
              patch.exactOrderedPaths.map(\.ordinal) == [1, 2, 3, 4, 5],
              patch.exactOrderedPaths.map(\.gitStatus) == ["M", "M", "M", "A", "A"],
              patch.exactOrderedPaths.map(\.gitMode)
                == ["100755", "100644", "100644", "100644", "100644"],
              Set(patch.exactOrderedPaths.map(\.path)).count == 5,
              patch.modifiedExistingPathCount == 3,
              patch.addedPathCount == 2,
              patch.workflowTimeoutLiteralChangeOccurrenceCount == 1,
              patch.activeRootTimeoutMinutes == 45,
              patch.reviewedMainTimeoutBeforeMinutes
                == ledger.configuredReviewedMainTimeoutMinutes,
              patch.reviewedMainTimeoutAfterMinutes
                == ledger.proposedReviewedMainTimeoutMinutes,
              patch.workflowJobCount == 2,
              patch.activeRootUserStepCount == 5,
              patch.reviewedMainUserStepCount == 5,
              patch.workflowJobAndStepOrderMustRemainUnchanged,
              patch.fetchInvocationCountAndDepthMustRemainUnchanged,
              patch.existingFetchDepth == 2,
              patch.fetchCheckoutTargetsMustRemainUnchanged,
              patch.fetchCredentialHandlingMustRemainUnchanged,
              patch.existingFetchWantOrderMustRemainUnchanged,
              patch.existingOrderedImmutableWantRevisions
                == [
                    "b7808f39815ebf639b183e00d2cd769a29ebad18",
                    "444cd402c966521f6163f4949b4a73f9a5184e29",
                    "1bc2471d12f034d51ae6eb8c977198635bc37717",
                    "3c40cce6350da7ed0ce0f5ccb0620f76feff0501",
                    "3d2148227d264502010e64a0c0db70bc1362c50c",
                    "6a811d3029bdb77e038750694fbf10eec0f358f8",
                    "5623872afda1895630ba0eacdfab76961c5e755b",
                    "57f4264dd865a47766e27a9dbc06a82dd1fbfe11",
                    "f5db7101cf3538daae103ba56601a509ad8bad80",
                    "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
                    "75b14056b75e8af6af0c070453f7ef14ac10a063",
                    "3ad8087ed6e403ba81f46bba97ceb5d440979e0a",
                    "ef64686e76d2d67e46deb696bfeef18ea96c96a2",
                    "e1d90e3f2ae6c4d3c279bf5fb64ce3baafc1f540",
                    "0abcb4ad5487a775627bbb587184c375dd691978",
                    "4570716892722873757de6eae1bd897167d674eb",
                    "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
                    "b3402efd96d3ff893a0c2b73897cf48c9b313c8c",
                    "232a17e8f58a297919366d963ee1d7bc38cdbaee",
                    "a4d8583fa7c59f885002ee06a07c1d5264c0c223",
                ],
              patch.immutableWantPrefixBeforeAdditions
                == [
                    "b7808f39815ebf639b183e00d2cd769a29ebad18",
                    "444cd402c966521f6163f4949b4a73f9a5184e29",
                    "1bc2471d12f034d51ae6eb8c977198635bc37717",
                ],
              patch.addedImmutableFetchWantRevisions
                == [
                    closure.mergeRevision,
                    closure.reviewedHeadRevision,
                    closure.baseRevision,
                ],
              patch.addedImmutableFetchWantCountPerExistingFetch
                == patch.addedImmutableFetchWantRevisions.count,
              patch.existingFetchInvocationCount == 2,
              Self.checkedMultiply(
                  patch.addedImmutableFetchWantCountPerExistingFetch,
                  patch.existingFetchInvocationCount)
                == patch.totalAddedImmutableFetchWantOccurrenceCount,
              patch.addedWantsRequireRawObjectVerification,
              patch.rawObjectVerificationPerformsNoAncestryTraversal,
              patch.rawSignaturePresenceDoesNotReverifyGitHubSignature,
              patch.additionalFetchInvocationCount == 0,
              patch.retainedLiveCommandSequenceMustRemainByteIdentical,
              patch.v2AuthorityPairMustRemainByteIdentical,
              patch.topologyHelperClassifierAndMatrixMustRemainByteIdentical,
              patch.topologyHelperInvocationCountPerGate == 1,
              patch.pullRequestTopologyExplicitRequestRoles
                == [
                    "current_exact_revision",
                    "verified_v2_authority_base",
                    "verified_implementation_base",
                ],
              patch.pushMainTopologyExplicitRequestRoles
                == [
                    "verified_v2_authority_base",
                    "verified_implementation_base",
                ],
              patch.topologyRelationFixedParent1Revision == closure.mergeRevision,
              patch.topologyRequestsPerformNoAncestryTraversal,
              patch.retiredV1FilesMustRemainByteIdentical,
              patch.fixtureInputsMustRemainByteIdentical,
              patch.packageManifestMustRemainByteIdentical,
              patch.packageLockMustRemainByteIdentical,
              patch.v2MechanicsPathCountAddedNow == 0,
              patch.v2MechanicsInvocationCountNow == 0,
              patch.actionsArtifactCount == 0,
              patch.newDependencyNetworkInvocationCount == 0,
              continuity.predecessorRequiresMechanicsDirectChildOfAuthorityMerge,
              continuity.predecessorForbidsInterveningMainCommit,
              continuity.predecessorAuthorityMergeRevision == closure.mergeRevision,
              continuity.narrowlySupersededRuleCount == 1,
              continuity.timingRepairIsOnlyAuthorizedInterveningPatch,
              continuity.predecessorV2AuthorityPairRemainsByteIdentical,
              continuity.allOtherV2MeasurementSemanticAndSecurityContractsRemainUnchanged,
              continuity.exact32CodeOutcomeTaxonomyRemainsUnchanged,
              continuity.oneShotOpportunityCountBefore == 1,
              continuity.oneShotOpportunityConsumedByRepair == 0,
              Self.checkedAdd(
                  continuity.oneShotOpportunityConsumedByRepair,
                  continuity.oneShotOpportunityCountAfter)
                == continuity.oneShotOpportunityCountBefore,
              continuity.authorizedMechanicsAttemptCountBefore == 1,
              continuity.mechanicsAttemptsCreatedByRepair == 0,
              Self.checkedAdd(
                  continuity.authorizedMechanicsAttemptCountBefore,
                  continuity.mechanicsAttemptsCreatedByRepair)
                == continuity.authorizedMechanicsAttemptCountAfter,
              !continuity.timingRepairCreatesAdditionalOpportunity,
              continuity.timingRepairMergeRevision == nil,
              continuity.timingRepairReviewedHeadRevision == nil,
              continuity.timingRepairMergeTree == nil,
              continuity.timingRepairClosureRunID == nil,
              continuity.requiredRepairMergeParent1Revision == closure.mergeRevision,
              continuity.requiredRepairMergeOrderedParentCount == 2,
              continuity.requiredTimingRepairReviewedHeadDirectChildOfParent1,
              continuity.requiredTimingRepairReviewedHeadTreeEqualsMergeTree,
              continuity.requiredRepairMergeTreeEqualsTimingRepairReviewedHeadTree,
              continuity.requiredRepairMergeParent2EqualsTimingRepairReviewedHead,
              continuity.requiredRepairMergeSignatureVerified,
              continuity.requiredRepairMergeSignatureReason == "valid",
              continuity.requiredClosureEvent == "push",
              continuity.requiredClosureRef == "refs/heads/main",
              continuity.requiredClosureRunAttempt == 1,
              continuity.requiredClosureMatchingRunCount == 1,
              continuity.requiredClosurePreviousAttemptURLMustBeNil,
              continuity.requiredClosureRetryCount == 0,
              continuity.requiredClosureRerunCount == 0,
              continuity.requiredClosureActionsArtifactCount == 0,
              continuity.requiredClosureConclusion == "success",
              continuity.requiredClosureRunHeadSHAEqualsObservedRepairMerge,
              continuity.pullRequestGreenIsInsufficient,
              !continuity.currentV2MechanicsAuthorized,
              continuity.conditionalPostClosureMechanicsRebuildAuthorized,
              continuity.conditionalAuthorizationPredicate
                == "unique_attempt1_direct_push_main_run_for_observed_timing_repair_merge_is_successful",
              continuity.rebuiltMechanicsFixedParent1Source
                == "future_observed_timing_repair_merge_revision_after_unique_attempt1_direct_push_main_success",
              continuity.requiredFutureMechanicsHeadDirectChildOfObservedRepairMerge,
              continuity.requiredFutureMechanicsMergeParent1EqualsObservedRepairMerge,
              continuity.requiredFutureMechanicsMergeParent2EqualsMechanicsHead,
              continuity.requiredFutureMechanicsMergeTreeEqualsMechanicsHeadTree,
              !continuity.staleMechanicsBasedOnPredecessorMergeMayMerge,
              continuity.separateMechanicsReviewAndTestingRequired,
              !continuity.separatePostClosureAuthorityPairRequired,
              restoration.elevatedTimeoutLifecycleID
                == "reviewed_main_120_from_repair_merge_until_mechanics_observation_or_restore_only_abort",
              restoration.targetReviewedMainTimeoutMinutes
                == ledger.configuredReviewedMainTimeoutMinutes,
              restoration.exactTerminalTriggerIDsInOrder
                == [
                    "repair_closure_cannot_establish_unique_attempt1_direct_push_main_success",
                    "main_intervenes_after_valid_closure_before_mechanics",
                    "mechanics_is_abandoned_or_requires_broader_surface",
                    "mechanics_reaches_any_terminal_outcome",
                ],
              restoration.exactTerminalTriggerCount
                == restoration.exactTerminalTriggerIDsInOrder.count,
              restoration.repairClosureDisqualificationCovered,
              restoration.interveningMainBeforeMechanicsCovered,
              restoration.mechanicsAbandonmentOrBroaderSurfaceCovered,
              restoration.everyMechanicsOutcomeCovered,
              restoration.validClosurePermitsOnlyMechanicsOrRestoreOnlyAsNextRoadmapMutation,
              restoration.restoreOnlyTransitionMustBeNextRoadmapMutation,
              restoration.restorationTransitionRole
                == "append_only_exact5_restore_only_observation_or_abandonment_transition",
              restoration.restorationTransitionRequiresSeparateReviewAndTesting,
              !restoration.restorationTransitionConsumesMeasurementOpportunity,
              !restoration.restorationTransitionConsumesMechanicsAttempt,
              !restoration.restorationTransitionCreatesMeasurementOpportunity,
              !restoration.restorationTransitionAuthorizesMechanics,
              !restoration.failedRepairClosureAuthorizesMechanics,
              !restoration.wallClockRestorationDeadlineEstablished,
              !restoration.indefiniteElevatedBaselineAuthorized,
              preserved.predecessorAuthorityCanonicalByteCount == 41_626,
              preserved.predecessorAuthorityCanonicalSHA256
                == "d32cc3d90e5476e6f279d24bcb392f570358836c702429ecebf27dc1458077c4",
              preserved.predecessorAuthoritySourceGitBlob == files[3].gitBlob,
              preserved.predecessorAuthorityTestGitBlob == files[4].gitBlob,
              preserved.fixtureInputCount == 5,
              preserved.fixtureInputSHA256InOrdinalOrder.count
                == preserved.fixtureInputCount,
              preserved.fixtureInputSHA256InOrdinalOrder.allSatisfy({
                  Self.isLowercaseHex($0, count: 64)
              }),
              preserved.currentAcceptancePinByteCount == 89_632,
              Self.isLowercaseHex(
                  preserved.currentAcceptancePinSHA256,
                  count: 64),
              preserved.phaseTransitionCount == 5,
              preserved.phaseTransitionKeysInOrdinalOrder.count
                == preserved.phaseTransitionCount,
              preserved.exactLowLevelResultCodeCount == 32,
              preserved.preservationIsSemanticAndByteIdentityOnly,
              preserved.preservationPerformsNoExecution,
              Self.checkedSum([
                  opportunity.identicalResultCodeCount,
                  opportunity.differentResultCodeCount,
                  opportunity.unavailableResultCodeCount,
                  opportunity.failureResultCodeCount,
              ]) == opportunity.exactLowLevelResultCodeCount,
              opportunity.exactLowLevelResultCodeCount == 32,
              opportunity.exactLowLevelResultCodeCount
                == preserved.exactLowLevelResultCodeCount,
              opportunity.attemptConsumptionBoundary
                == "immediately_before_first_of_two_independent_release_fixture_builds",
              !opportunity.preBuildTopologyFailureConsumesAttempt,
              opportunity.falseAttemptConsumptionStillRetiresOpportunity,
              opportunity.everyOutcomeRequiresAppendOnlyObservationAndRetirement,
              opportunity.absentRecordCauseRequiresPositiveEvidence,
              !opportunity.absentRecordCauseMayBeInferredOrInvented,
              !opportunity.timeoutOrAbsentRecordAuthorizesRetry,
              !opportunity.retryAuthorized,
              !opportunity.rerunAuthorized,
              !opportunity.replacementAuthorized,
              counts.activeLatinTestCount == tests.activeLatinTestCount,
              counts.predecessorRootTestCount == tests.rootTestCount,
              Self.checkedAdd(counts.predecessorRootTestCount, 1)
                == counts.repairRootTestCount,
              Self.checkedAdd(counts.repairRootTestCount, counts.isolatedTestCount)
                == counts.repairFocusedWholeTestCount,
              counts.retainedLiveTestCount == tests.retainedLiveTestCount,
              Self.checkedAdd(
                  counts.repairFocusedWholeTestCount,
                  counts.retainedLiveTestCount)
                == counts.repairAggregateTestCount,
              Self.checkedAdd(
                  counts.predecessorEmbeddedProvenanceRecordCount,
                  counts.repairNewEmbeddedSourceRecordCount)
                == counts.repairEmbeddedProvenanceRecordCount,
              counts.repairNewEmbeddedSourceRecordCount == 2,
              counts.futureMechanicsRootTestCount == counts.repairRootTestCount,
              counts.futureMechanicsFocusedWholeTestCount
                == counts.repairFocusedWholeTestCount,
              counts.futureMechanicsAggregateTestCount
                == counts.repairAggregateTestCount,
              Self.checkedAdd(counts.repairEmbeddedProvenanceRecordCount, 2)
                == counts.futureMechanicsEmbeddedProvenanceRecordCount,
              counts.futureMechanicsActiveRootUserStepCount == 5,
              counts.futureMechanicsReviewedMainUserStepCount == 6,
              counts.repairAuthorityTestCount == 1,
              counts.failureCount == 0,
              counts.skipCount == 0,
              counts.actionsArtifactCount == 0,
              counts.expectedNotObserved,
              !counts.successEstablished,
              authorityCeiling.v2AuthorityExactMainClosureEstablished,
              authorityCeiling.exactMainRun174EvidenceEstablished,
              authorityCeiling.boundedTimingAndBaseContinuityRepairAuthorized,
              authorityCeiling.predecessorV2AuthorityPreserved,
              falseCeilingClaims.allSatisfy({ !$0 }),
              Self.canonicalByteCount == 23_495,
              Self.canonicalSHA256
                == "b77598fda922e6f3a925a4948ff834286664cf7df7bf4edcff1dadd275b2961c" else {
            throw
                PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityError
                .contractDrift
        }
    }

    private static func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.utf8.allSatisfy {
                (48 ... 57).contains($0) || (97 ... 102).contains($0)
            }
    }

    private static func validRun(_ run: WorkflowRun, event: String) -> Bool {
        run.runAttempt == 1
            && run.event == event
            && run.status == "completed"
            && run.conclusion == "success"
            && run.previousAttemptURL == nil
            && run.matchingRunCountForHead == 1
            && run.retryCount == 0
            && run.rerunCount == 0
            && run.actionsArtifactCount == 0
            && isLowercaseHex(run.headSHA, count: 40)
    }

    private static func validJob(
        _ job: Job,
        expectedDuration: Int
    ) -> Bool {
        job.status == "completed"
            && job.conclusion == "success"
            && seconds(from: job.startedAt, to: job.completedAt)
                == expectedDuration
            && job.durationSeconds == expectedDuration
            && job.userStepCount == 5
            && job.successfulUserStepCount == 5
            && job.failedUserStepCount == 0
            && job.skippedUserStepCount == 0
    }

    private static func validLog(_ value: ConnectorDecodedLogIdentity) -> Bool {
        value.byteCount > 0
            && value.lfByteCount > 0
            && value.crByteCount == 0
            && value.utf8BOMCount > 0
            && value.utf8BOMByteOffsetsAreBound
            && value.utf8BOMByteOffsets.count == value.utf8BOMCount
            && value.utf8BOMByteOffsets
                == value.utf8BOMByteOffsets.sorted()
            && value.terminalLFPresent
            && isLowercaseHex(value.sha256, count: 64)
            && value.repeatFetchExactlyEqual
            && !value.rawArchiveBytesBound
            && !value.rawArchiveRetained
    }

    static func checkedAdd(_ lhs: Int, _ rhs: Int) -> Int? {
        let (value, overflow) = lhs.addingReportingOverflow(rhs)
        return overflow ? nil : value
    }

    static func checkedSubtract(_ lhs: Int, _ rhs: Int) -> Int? {
        let (value, overflow) = lhs.subtractingReportingOverflow(rhs)
        return overflow ? nil : value
    }

    static func checkedMultiply(_ lhs: Int, _ rhs: Int) -> Int? {
        let (value, overflow) = lhs.multipliedReportingOverflow(by: rhs)
        return overflow ? nil : value
    }

    static func checkedSum(_ values: [Int]) -> Int? {
        var total = 0
        for value in values {
            let (next, overflow) = total.addingReportingOverflow(value)
            guard !overflow else { return nil }
            total = next
        }
        return total
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

    private static func file(
        _ ordinal: Int,
        _ path: String,
        _ gitMode: String,
        _ gitBlob: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String,
        _ role: String
    ) -> FileIdentity {
        .init(
            ordinal: ordinal,
            path: path,
            gitMode: gitMode,
            gitBlob: gitBlob,
            byteCount: byteCount,
            lfByteCount: lfByteCount,
            crByteCount: 0,
            sha256: sha256,
            role: role)
    }

    private static func path(
        _ ordinal: Int,
        _ path: String,
        _ gitStatus: String,
        _ gitMode: String,
        _ role: String
    ) -> PathContract {
        .init(
            ordinal: ordinal,
            path: path,
            gitStatus: gitStatus,
            gitMode: gitMode,
            role: role)
    }

    private static let v2AuthorityFiles: [FileIdentity] = [
        file(1, ".github/scripts/prime-ci-active-root-quarantine.sh", "100755", "11d9fb7b38e162168014831e55ef3016ea4a8869", 1_623_267, 25_502, "4cf008ed967c30f1636772d3fda75c91145f74a80929c16df7833adc5377fc53", "frozen_v2_authority_gate"),
        file(2, ".github/workflows/prime-active-root-quarantine.yml", "100644", "a18a517bdbb31c0f452ac8d4d13068441500aa02", 222_682, 780, "ee501dc525924918b7706b1c929696f92e87ec50961d1a82079a1bf1f1f4f915", "frozen_v2_authority_workflow"),
        file(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", "100644", "2e2cb7cfb1ede79e30a97db1a4d8ee675f961703", 546, 13, "e8be1c58d823c05997b9ac3aa3196e5970836d985fc20eac8737456253915b9b", "frozen_v2_authority_embedded_provenance"),
        file(4, "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementV2Authority.swift", "100644", "44dac55cb6620f9f667cf564efb137102e1546c8", 73_439, 1_408, "0ce03a04ffd3fac1dfd71c91d5a0353747916ed90f7b0c7fb8c14371e28d2438", "frozen_v2_measurement_authority"),
        file(5, "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityTests.swift", "100644", "a7f5624d2147f4852b2b0422a90c14776689b4b2", 52_465, 1_178, "8a442a5cd17b18ebb7379ceec53384b252be9b980048a392ed5e9d89e9299db2", "frozen_v2_measurement_authority_test"),
    ]

    private static let repairPaths: [PathContract] = [
        path(1, ".github/scripts/prime-ci-active-root-quarantine.sh", "M", "100755", "bind_run174_timing_evidence_and_base_continuity_repair"),
        path(2, ".github/workflows/prime-active-root-quarantine.yml", "M", "100644", "raise_only_reviewed_main_timeout_90_to_120_and_integrate_pure_test"),
        path(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", "M", "100644", "bind_534_record_source_identity"),
        path(4, "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthority.swift", "A", "100644", "pure_timing_and_base_continuity_repair_authority"),
        path(5, "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementV2TimingRepairAuthorityTests.swift", "A", "100644", "sole_exhaustive_pure_repair_authority_test"),
    ]
}
