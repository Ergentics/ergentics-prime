// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// Pure data authority for one later V2 repeat-build measurement of the fixed
/// validation-fixture executable identity. Constructing, encoding, decoding,
/// or validating this value performs no filesystem, Git, process, compiler,
/// verifier, build, evaluator, fixture, lease, network, model, MLX, Metal,
/// Python, C++, canary, pin-repair, or confirmation operation.
public struct PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityV1:
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
    }

    public struct WorkflowRunClosure: Codable, Equatable, Sendable {
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

    public struct JobClosure: Codable, Equatable, Sendable {
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
        public let terminalLFPresent: Bool
        public let sha256: String
        public let repeatFetchExactlyEqual: Bool
        public let rawArchiveBytesBound: Bool
        public let rawArchiveRetained: Bool
    }

    public struct TestClosure: Codable, Equatable, Sendable {
        public let activeLatinTestCount: Int
        public let activeLatinPassCount: Int
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
        public let aggregateFailureCount: Int
        public let aggregateSkipCount: Int
    }

    public struct TopologyVerificationClosure:
        Codable,
        Equatable,
        Sendable
    {
        public let implementationMergeRevision: String
        public let implementationMergeTree: String
        public let implementationExactFiles: [FileIdentity]
        public let helperFunctionName: String
        public let helperResultSchemaID: String
        public let helperResultSchemaVersion: Int
        public let observedResultCode: String
        public let observedRecordCount: Int
        public let observedHelperReturnStatus: Int
        public let firstFailedGuardIDWasNull: Bool
        public let missingObjectRoleWasNull: Bool
        public let matrixPredecessorPrivateCaseCount: Int
        public let matrixPredecessorPureCaseCount: Int
        public let matrixClassifierDirectCaseCount: Int
        public let matrixHelperParserCaseCount: Int
        public let matrixStaticSourceCaseCount: Int
        public let matrixRelationBindingCount: Int
        public let matrixRelationHelperBindingCount: Int
        public let matrixGateBindingCount: Int
        public let matrixAttemptCount: Int
        public let matrixComponentHarnessCount: Int
        public let matrixPublicHelperCaseCount: Int
        public let matrixRawStreamCaseCount: Int
        public let matrixClosedChildCaseCount: Int
        public let matrixLiveEPIPECaseCount: Int
        public let matrixPostRawMutationCaseCount: Int
        public let matrixPassed: Bool
        public let postMatrixGatePassed: Bool
    }

    public struct RetiredV1Closure: Codable, Equatable, Sendable {
        public let exactFiles: [FileIdentity]
        public let exactFileCount: Int
        public let measurementAuthorityCanonicalByteCount: Int
        public let measurementAuthorityCanonicalSHA256: String
        public let measurementObservationCanonicalByteCount: Int
        public let measurementObservationCanonicalSHA256: String
        public let measurementMechanicsMergeRevision: String
        public let measurementRunID: Int
        public let measurementRunNumber: Int
        public let measurementRunAttempt: Int
        public let measurementCheckSuiteID: Int
        public let resultCode: String
        public let measurementAttemptConsumed: Bool
        public let fixtureExecutionCount: Int
        public let fixtureIdentityEstablished: Bool
        public let repeatBuildDeterminismEstablished: Bool
        public let currentPinRelationEstablished: Bool
        public let oldFailureCauseRemainsInference: Bool
        public let opportunityRetired: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementAuthorized: Bool
        public let allRetiredFilesMustRemainByteIdentical: Bool
        public let anyRetiredLauncherOrEvaluatorInvokedByV2: Bool
    }

    public struct FixtureInputInventory: Codable, Equatable, Sendable {
        public let exactFiles: [FileIdentity]
        public let exactFileCount: Int
        public let packagePath: String
        public let fixtureProductName: String
        public let fixtureTargetName: String
        public let fixtureExecutableLeaf: String
        public let currentAcceptancePinByteCount: Int
        public let currentAcceptancePinSHA256: String
        public let currentAcceptancePinSourceType: String
        public let packageManifestMutationAuthorized: Bool
        public let packageLockMutationAuthorized: Bool
        public let mirrorMutationAuthorized: Bool
        public let fixtureSourceMutationAuthorized: Bool
        public let secureChildKernelMutationAuthorized: Bool
        public let currentPinMutationAuthorized: Bool
    }

    public struct SharedTopologyHelperContract:
        Codable,
        Equatable,
        Sendable
    {
        public let classifierSource: FileIdentity
        public let helperSource: FileIdentity
        public let matrixSource: FileIdentity
        public let sourcedFunctionName: String
        public let helperFirstExecutableStatement: String
        public let helperSecondExecutableStatement: String
        public let ordinaryFlatArgumentGrammar: String
        public let optionalRelationSuffixMarker: String
        public let optionalRelationSuffixGrammar: String
        public let currentIndexMarker: String
        public let currentIndexMarkerGrammar: String
        public let maximumOrdinaryExplicitRequestCount: Int
        public let maximumRelationExplicitRequestCount: Int
        public let exactRelationImplicitObjectCount: Int
        public let maximumTotalObjectCount: Int
        public let maximumParentCount: Int
        public let exactAllowedAmbientInputNames: [String]
        public let successResultCode: String
        public let successReturnStatus: Int
        public let emittedFailureReturnStatus: Int
        public let internalNoRecordFailureReturnStatus: Int
        public let maximumCanonicalRecordByteCount: Int
        public let recordHasOneTerminalLF: Bool
        public let stderrPublished: Bool
        public let relationBindsOrderedMergeAndDiscoveredChild: Bool
        public let activatedMarkerBindsHEADCleanStatusAndIndexTreeBeforeAndAfterRawObservation: Bool
        public let sameEUIDConcurrentMutationInScope: Bool
    }

    public struct CurrentAuthorityTopologyCallContract:
        Codable,
        Equatable,
        Sendable
    {
        public let unchangedFetchDepth: Int
        public let unchangedFetchesGuaranteeHistoricalReviewedHeadAvailability: Bool
        public let reviewedHeadDirectChildAndSameTreeBoundByFrozenRun170AndRun171Evidence: Bool
        public let frozenExternalEvidenceRunNumbers: [Int]
        public let availableImplementationBaseRevision: String
        public let availableImplementationBaseTree: String
        public let availableImplementationBaseOrderedParentRevisions: [String]
        public let helperReprovesHistoricalReviewedHeadAvailability: Bool
        public let availableImplementationBaseUsesRawReplacementDisabledSHAReboundHelperProof: Bool
        public let pullRequestExplicitRequestCount: Int
        public let pullRequestCurrentExactRevisionRequestOrdinal: Int
        public let pullRequestVerifiedImplementationBaseRequestOrdinal: Int
        public let pullRequestExactFunctionArgumentVector: [String]
        public let pushExplicitRequestCount: Int
        public let pushVerifiedImplementationBaseRequestOrdinal: Int
        public let pushExactFunctionArgumentVector: [String]
        public let pullRequestUsesCurrentIndexMarker: Bool
        public let pushUsesOrderedMergeChildRelationSuffix: Bool
        public let legacyExactCommitChecksAreCumulativeConsistencyOnly: Bool
        public let legacyExactCommitChecksProvideRawReplacementDisabledSHAReboundProof: Bool
        public let fetchVectorChangeAuthorized: Bool
    }

    public struct AuthorityPatchContract: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let modifiedExistingPathCount: Int
        public let addedPathCount: Int
        public let soleAuthorityTestClassName: String
        public let soleAuthorityTestMethodName: String
        public let soleAuthorityTestExpectedStartCount: Int
        public let soleAuthorityTestExpectedPassCount: Int
        public let expectedActiveLatinTestCount: Int
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedEmbeddedProvenanceRecordCount: Int
        public let activeRootTimeoutMinutes: Int
        public let reviewedMainTimeoutMinutes: Int
        public let workflowJobCount: Int
        public let activeRootUserStepCount: Int
        public let reviewedMainUserStepCount: Int
        public let workflowJobAndStepTopologyMustRemainUnchanged: Bool
        public let fetchVectorsMustRemainByteIdentical: Bool
        public let retainedLiveCommandsMustRemainByteIdentical: Bool
        public let packageManifestMustRemainByteIdentical: Bool
        public let packageLockMustRemainByteIdentical: Bool
        public let currentHelperImplementationMustRemainByteIdentical: Bool
        public let baselineHostedGateMatrixTestsAndRetainedLiveCommandsStillExecute: Bool
        public let currentPatchExecutesMeasurement: Bool
    }

    public struct FutureMechanicsPatchContract:
        Codable,
        Equatable,
        Sendable
    {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let modifiedExistingPathCount: Int
        public let addedPathCount: Int
        public let launcherPath: String
        public let evaluatorPath: String
        public let exactMainGreenRequiredBeforeImplementation: Bool
        public let authorityMergeRevisionAvailableOnlyAfterClosure: Bool
        public let authorityMergeTreeAvailableOnlyAfterClosure: Bool
        public let futureMechanicsPullRequestHeadFrozenHere: Bool
        public let futureMechanicsMergeRevisionFrozenHere: Bool
        public let futureMechanicsMergeTreeFrozenHere: Bool
        public let futureMechanicsWorkflowRunFrozenHere: Bool
        public let mechanicsPullRequestHeadMustBeDirectChildOfAuthorityMerge: Bool
        public let mechanicsMergeMustBeSignedTwoParentSameTreeMerge: Bool
        public let noInterveningMainCommitAuthorized: Bool
        public let mainPushOnly: Bool
        public let requiredRepository: String
        public let requiredEvent: String
        public let requiredRef: String
        public let requiredRunAttempt: Int
        public let privilegedBashInvocationPattern: String
        public let launcherFirstExecutableStatement: String
        public let launcherSecondExecutableStatement: String
        public let bootstrapUsesOnlyBashBuiltinsBeforeToolAdmission: Bool
        public let launcherMustPerformEquivalentThreePathSourceAdmission: Bool
        public let launcherMustSourceSharedHelper: Bool
        public let duplicatedPrivateTopologyParserCount: Int
        public let helperRelationArgumentVector: [String]
        public let helperFixedAuthorityBaseExplicitRequestCount: Int
        public let helperFixedAuthorityBaseExplicitRequestOrdinal: Int
        public let helperUsesOrderedMergeChildRelationSuffix: Bool
        public let helperFixedAuthorityBaseUsesRawReplacementDisabledSHAReboundProof: Bool
        public let helperCallCount: Int
        public let helperRecordCapturedBoundedlyAndNotRepublishedRaw: Bool
        public let helperFailureProjectedAsOneSanitizedMeasurementRecordWhenLauncherControlsReturn: Bool
        public let anyTopologyHelperFailureIsTerminal: Bool
        public let topologyFailureConsumesBuildAttempt: Bool
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedEmbeddedProvenanceRecordCount: Int
        public let reviewedUserStepAdditionCount: Int
        public let activeRootTimeoutMinutesRemains: Int
        public let reviewedMainTimeoutMinutesRemains: Int
        public let predecessorReviewedDurationSeconds: Int
        public let predecessorReviewedTimeoutHeadroomSeconds: Int
        public let timingHeadroomGuaranteesFutureMeasurementCompletion: Bool
        public let insufficientTimingRequiresSeparateAuthorityBeforeConsumption: Bool
    }

    public struct MeasurementExecutionContract:
        Codable,
        Equatable,
        Sendable
    {
        public let privateBaseLeaf: String
        public let exactTreeSourceRootLeaves: [String]
        public let fixtureBuildRootSetLeaves: [String]
        public let evaluatorRootLeaf: String
        public let evaluatorExecutableLeaf: String
        public let buildConfiguration: String
        public let independentExactTreeSourceRootCount: Int
        public let independentBuildRootSetCount: Int
        public let fixtureProductBuildCommandCount: Int
        public let showBinPathCommandCount: Int
        public let evaluatorCompileCommandCount: Int
        public let evaluatorCommandCount: Int
        public let fixtureExecutableInvocationCount: Int
        public let adapterInvocationCount: Int
        public let leaseAcquisitionCount: Int
        public let modelExecutionCount: Int
        public let mlxExecutionCount: Int
        public let metalExecutionCount: Int
        public let pythonInvocationCount: Int
        public let cppInvocationCount: Int
        public let dependencyNetworkInvocationCount: Int
        public let maximumFixtureExecutableByteCount: Int
        public let maximumShowBinAcceptedByteCount: Int
        public let maximumEvaluatorJSONByteCount: Int
        public let maximumPublishedRecordLineByteCount: Int
        public let maximumReadChunkByteCount: Int
        public let evaluatorRequiredImports: [String]
        public let evaluatorOpenFlags: [String]
        public let cryptoKitSHA256Required: Bool
        public let fullByteEqualityRequired: Bool
        public let thinArm64MachORequired: Bool
        public let exactLCUUIDCount: Int
        public let exactLCBuildVersionCount: Int
        public let entireLCBuildVersionCommandBytesCompared: Bool
        public let codeSignatureValidityEstablished: Bool
        public let launchabilityEstablished: Bool
        public let attemptConsumedImmediatelyBeforeFirstBuild: Bool
        public let preBuildTopologyFailureConsumesAttempt: Bool
        public let createdRootsRetainedOnlyUntilEphemeralRunnerTeardown: Bool
        public let createdRootReuseAuthorized: Bool
        public let actionsArtifactCount: Int
        public let durableEvidenceEstablishedByLauncher: Bool
    }

    public struct MeasurementOutputContract:
        Codable,
        Equatable,
        Sendable
    {
        public struct ResultMapping: Codable, Equatable, Sendable {
            public let lowLevelResultCode: String
            public let recordCardinality: String
            public let attemptConsumed: String
            public let measurementOutcome: String
            public let pinRelation: String?
            public let workflowConclusion: String
            public let terminallyRetiresMeasurementOpportunity: Bool
        }

        public let prefix: String
        public let schemaID: String
        public let schemaVersion: Int
        public let canonicalJSONRequired: Bool
        public let exactLineCountWhenPresent: Int
        public let terminalLFRequiredWhenPresent: Bool
        public let maximumLineByteCount: Int
        public let measurementOutcomeMembers: [String]
        public let observationOutcomeMembers: [String]
        public let pinRelationMembers: [String]
        public let identicalResultCodes: [String]
        public let differentResultCode: String
        public let unavailableResultCodes: [String]
        public let failureResultCodes: [String]
        public let topologyFailureResultCode: String
        public let exactLowLevelResultMappings: [ResultMapping]
        public let everyLowLevelResultMappedExactlyOnce: Bool
        public let identicalDefinition: String
        public let differentDefinition: String
        public let pinMatchDefinition: String
        public let pinDifferentDefinition: String
        public let failureDefinition: String
        public let differentBuildIsTerminal: Bool
        public let identicalDifferentPinIsNotDifferentMeasurement: Bool
        public let identityFieldsRequiredForIdenticalOrDifferent: Bool
        public let pinRelationNullableUnlessOutcomeIdentical: Bool
        public let rawAbsolutePathFieldCount: Int
        public let rawBuildOutputOrErrorFieldCount: Int
        public let exactRecordCountForEveryLauncherControlledOutcome: Int
        public let recordMayBeAbsentOnlyAfterExternalTimeoutCancellationHostLossLauncherNotReachedExitProjectionFailureOrCauseUnestablished: Bool
        public let absentRecordCauseClassificationRequiresPositiveEvidence: Bool
        public let absentRecordCauseMustNeverBeInferredOrInvented: Bool
        public let unclassifiedAbsentRecordResultCode: String
        public let absentRecordAttemptConsumptionWithoutSeparateProof: String
        public let failureOutcomesEstablishMeasurement: Bool
        public let failureOutcomesEstablishFixtureIdentity: Bool
        public let failureOutcomesAuthorizeRetryRerunOrReplacement: Bool
        public let captureRefusedIsLauncherControlledExactlyOneRecord: Bool
        public let everyRecordOrAbsentOutcomeRequiresAppendOnlyObservationAndRetirement: Bool
        public let falseAttemptConsumptionStillRetiresOpportunity: Bool
    }

    public struct PhaseTransition: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let measurementOutcome: String
        public let pinRelation: String?
        public let exactAllowedNextAuthorityIDs: [String]
        public let terminalAbsentNewAuthority: Bool
        public let retryRerunReplacementOrImplicitCanaryAuthorized: Bool
    }

    public struct PreservationContract: Codable, Equatable, Sendable {
        public let retiredV1PathsMustRemainByteIdentical: Bool
        public let retiredRun160RemainsTerminal: Bool
        public let topologyImplementationFilesMustRemainByteIdentical: Bool
        public let topologyAuthorityPairsMustRemainByteIdentical: Bool
        public let packageManifestMutationAuthorized: Bool
        public let packageLockMutationAuthorized: Bool
        public let dependencyResolutionMutationAuthorized: Bool
        public let secureChildKernelMutationAuthorized: Bool
        public let currentPinMutationAuthorized: Bool
        public let existingV1LauncherRetrofittedOrReactivated: Bool
        public let existingV1EvaluatorRetrofittedOrReactivated: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let predecessorExactMainClosureEstablished: Bool
        public let predecessorTopologyVerificationEstablished: Bool
        public let retiredV1ClosurePreserved: Bool
        public let v2MeasurementAuthorityEstablished: Bool
        public let exactlyOneFutureMechanicsAttemptAuthorizedAfterClosure: Bool
        public let currentPatchIsPureDataOnly: Bool
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
        public let currentPinMatchEstablished: Bool
        public let currentPinMismatchEstablished: Bool
        public let pinRepairAuthorized: Bool
        public let pinRepairPerformed: Bool
        public let noMutationConfirmationAuthorized: Bool
        public let noMutationConfirmationPerformed: Bool
        public let realMonitorHeldLeaseCanaryAuthorized: Bool
        public let realMonitorHeldLeaseCanaryPerformed: Bool
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
    public let predecessorRepositoryClosure: RepositoryClosure
    public let predecessorPullRequestRun: WorkflowRunClosure
    public let predecessorPullRequestActiveJob: JobClosure
    public let predecessorPullRequestReviewedJob: JobClosure
    public let predecessorPullRequestActiveLog: ConnectorDecodedLogIdentity
    public let predecessorWorkflowRun: WorkflowRunClosure
    public let predecessorActiveJob: JobClosure
    public let predecessorReviewedJob: JobClosure
    public let predecessorActiveLog: ConnectorDecodedLogIdentity
    public let predecessorReviewedLog: ConnectorDecodedLogIdentity
    public let predecessorTests: TestClosure
    public let topologyVerificationClosure: TopologyVerificationClosure
    public let retiredV1Closure: RetiredV1Closure
    public let fixtureInputInventory: FixtureInputInventory
    public let sharedTopologyHelperContract: SharedTopologyHelperContract
    public let currentAuthorityTopologyCallContract: CurrentAuthorityTopologyCallContract
    public let authorityPatchContract: AuthorityPatchContract
    public let futureMechanicsPatchContract: FutureMechanicsPatchContract
    public let measurementExecutionContract: MeasurementExecutionContract
    public let measurementOutputContract: MeasurementOutputContract
    public let exactPhaseTransitions: [PhaseTransition]
    public let preservationContract: PreservationContract
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]

    public static let canonicalByteCount = 41_626
    public static let canonicalSHA256 =
        "d32cc3d90e5476e6f279d24bcb392f570358836c702429ecebf27dc1458077c4"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_secure_child_validation_fixture_identity_measurement_v2_authority_v1",
        authorityID:
            "ergentics_prime_secure_child_validation_fixture_identity_measurement_v2_authority_v1",
        authorityKind:
            "pure_authority_for_one_later_topology_bound_native_repeat_build_validation_fixture_identity_measurement_v2",
        status:
            "PURE_V2_MEASUREMENT_AUTHORITY_ONLY_exact_main_run171_topology_verified_future_one_shot_measurement_no_current_mechanics_identity_pin_repair_confirmation_or_canary",
        predecessorRepositoryClosure: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            pullRequestNumber: 135,
            baseRevision: "b7808f39815ebf639b183e00d2cd769a29ebad18",
            reviewedHeadRevision: "8167f1eafdedf6e9344fde7a6542bd7e07600d8e",
            reviewedHeadTree: "354265ca2344246abc33ce1e33ba56f749b16797",
            reviewedHeadOrderedParentRevisions: [
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
            ],
            mergeRevision: "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
            mergeTree: "354265ca2344246abc33ce1e33ba56f749b16797",
            orderedMergeParentRevisions: [
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
                "8167f1eafdedf6e9344fde7a6542bd7e07600d8e",
            ],
            mergeTreeEqualsReviewedHeadTree: true,
            reviewedHeadIsDirectChildOfBase: true,
            historyPreservingTwoParentMergeObserved: true,
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-21T23:34:30Z",
            mergedAt: "2026-08-21T23:34:30Z"),
        predecessorPullRequestRun: .init(
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 32_536_596_669,
            runNumber: 170,
            runAttempt: 1,
            checkSuiteID: 88_200_731_091,
            event: "pull_request",
            ref: "refs/pull/135/merge",
            headSHA: "8167f1eafdedf6e9344fde7a6542bd7e07600d8e",
            status: "completed",
            conclusion: "success",
            createdAt: "2026-08-21T23:22:04Z",
            startedAt: "2026-08-21T23:22:04Z",
            updatedAt: "2026-08-21T23:31:00Z",
            previousAttemptURL: nil,
            matchingRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0,
            actionsArtifactCount: 0),
        predecessorPullRequestActiveJob: .init(
            jobID: 96_938_589_193,
            name: "First-party MLX / active-root quarantine",
            runnerLabel: "macos-15",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-21T23:22:07Z",
            completedAt: "2026-08-21T23:30:59Z",
            durationSeconds: 532,
            userStepCount: 5,
            successfulUserStepCount: 5,
            failedUserStepCount: 0,
            skippedUserStepCount: 0),
        predecessorPullRequestReviewedJob: .init(
            jobID: 96_940_077_274,
            name: "Reviewed main / focused source contracts",
            runnerLabel: "macos-26",
            status: "completed",
            conclusion: "skipped",
            startedAt: "2026-08-21T23:30:59Z",
            completedAt: "2026-08-21T23:30:59Z",
            durationSeconds: 0,
            userStepCount: 0,
            successfulUserStepCount: 0,
            failedUserStepCount: 0,
            skippedUserStepCount: 0),
        predecessorPullRequestActiveLog: .init(
            jobID: 96_938_589_193,
            representation:
                "connector_decoded_utf8_job_log_with_leading_bom_and_terminal_lf",
            byteCount: 393_783,
            lfByteCount: 1_929,
            crByteCount: 0,
            utf8BOMCount: 1,
            terminalLFPresent: true,
            sha256:
                "4edb6534f4eb7d34be58017a89d043a3e24036f5ca87cf5306dad104ef9f0cf6",
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        predecessorWorkflowRun: .init(
            workflowName: "Prime active-root quarantine",
            workflowPath: ".github/workflows/prime-active-root-quarantine.yml",
            runID: 32_537_357_695,
            runNumber: 171,
            runAttempt: 1,
            checkSuiteID: 88_202_577_325,
            event: "push",
            ref: "refs/heads/main",
            headSHA: "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
            status: "completed",
            conclusion: "success",
            createdAt: "2026-08-21T23:34:34Z",
            startedAt: "2026-08-21T23:34:34Z",
            updatedAt: "2026-08-22T00:54:06Z",
            previousAttemptURL: nil,
            matchingRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0,
            actionsArtifactCount: 0),
        predecessorActiveJob: .init(
            jobID: 96_940_664_684,
            name: "First-party MLX / active-root quarantine",
            runnerLabel: "macos-15",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-21T23:34:36Z",
            completedAt: "2026-08-21T23:46:36Z",
            durationSeconds: 720,
            userStepCount: 5,
            successfulUserStepCount: 5,
            failedUserStepCount: 0,
            skippedUserStepCount: 0),
        predecessorReviewedJob: .init(
            jobID: 96_942_618_564,
            name: "Reviewed main / focused source contracts",
            runnerLabel: "macos-26",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-21T23:46:39Z",
            completedAt: "2026-08-22T00:54:05Z",
            durationSeconds: 4_046,
            userStepCount: 5,
            successfulUserStepCount: 5,
            failedUserStepCount: 0,
            skippedUserStepCount: 0),
        predecessorActiveLog: .init(
            jobID: 96_940_664_684,
            representation:
                "connector_decoded_utf8_job_log_with_leading_bom_and_terminal_lf",
            byteCount: 393_906,
            lfByteCount: 1_929,
            crByteCount: 0,
            utf8BOMCount: 1,
            terminalLFPresent: true,
            sha256:
                "671f797da021f6ffc2798d4afc482fa69691e0fd48eb662f6e3b0f483b20bc89",
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        predecessorReviewedLog: .init(
            jobID: 96_942_618_564,
            representation:
                "connector_decoded_utf8_job_log_with_chunk_boms_and_terminal_lf",
            byteCount: 10_346_720,
            lfByteCount: 79_116,
            crByteCount: 0,
            utf8BOMCount: 5,
            terminalLFPresent: true,
            sha256:
                "412797e5b2420d2af3184bf06df96052db631489472eeba584d03d75387da9a1",
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false),
        predecessorTests: .init(
            activeLatinTestCount: 116,
            activeLatinPassCount: 116,
            activeLatinFailureCount: 0,
            activeLatinSkipCount: 0,
            rootTestCount: 89,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 95,
            retainedMetalTestCount: 44,
            retainedMaintainedRuntimeTestCount: 1,
            retainedTokenizerTestCount: 1,
            retainedLiveTestCount: 46,
            aggregateTestCount: 141,
            aggregateFailureCount: 0,
            aggregateSkipCount: 0),
        topologyVerificationClosure: .init(
            implementationMergeRevision:
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
            implementationMergeTree:
                "354265ca2344246abc33ce1e33ba56f749b16797",
            implementationExactFiles: implementationFiles,
            helperFunctionName: "prime_verify_exact_revision_topology_v1",
            helperResultSchemaID: "prime_exact_revision_topology_verifier_result_v1",
            helperResultSchemaVersion: 1,
            observedResultCode: "TOPOLOGY_VERIFIED",
            observedRecordCount: 1,
            observedHelperReturnStatus: 0,
            firstFailedGuardIDWasNull: true,
            missingObjectRoleWasNull: true,
            matrixPredecessorPrivateCaseCount: 8,
            matrixPredecessorPureCaseCount: 10,
            matrixClassifierDirectCaseCount: 41,
            matrixHelperParserCaseCount: 32,
            matrixStaticSourceCaseCount: 8,
            matrixRelationBindingCount: 135,
            matrixRelationHelperBindingCount: 129,
            matrixGateBindingCount: 6,
            matrixAttemptCount: 143,
            matrixComponentHarnessCount: 6,
            matrixPublicHelperCaseCount: 22,
            matrixRawStreamCaseCount: 5,
            matrixClosedChildCaseCount: 4,
            matrixLiveEPIPECaseCount: 1,
            matrixPostRawMutationCaseCount: 1,
            matrixPassed: true,
            postMatrixGatePassed: true),
        retiredV1Closure: .init(
            exactFiles: retiredV1Files,
            exactFileCount: 11,
            measurementAuthorityCanonicalByteCount: 66_632,
            measurementAuthorityCanonicalSHA256:
                "67ad7808b54314b7dcd70a86b5504e7321c4c348a0ecb2ec172d5b72ee3f6d43",
            measurementObservationCanonicalByteCount: 28_633,
            measurementObservationCanonicalSHA256:
                "d7042968a0c78d213c92d73d11d6637f3c03b0f758555376263b9d3aa8ec1a77",
            measurementMechanicsMergeRevision:
                "5623872afda1895630ba0eacdfab76961c5e755b",
            measurementRunID: 32_396_967_956,
            measurementRunNumber: 160,
            measurementRunAttempt: 1,
            measurementCheckSuiteID: 87_824_712_564,
            resultCode: "INVOCATION_ADMISSION_REFUSED",
            measurementAttemptConsumed: false,
            fixtureExecutionCount: 0,
            fixtureIdentityEstablished: false,
            repeatBuildDeterminismEstablished: false,
            currentPinRelationEstablished: false,
            oldFailureCauseRemainsInference: true,
            opportunityRetired: true,
            retryAuthorized: false,
            rerunAuthorized: false,
            replacementAuthorized: false,
            allRetiredFilesMustRemainByteIdentical: true,
            anyRetiredLauncherOrEvaluatorInvokedByV2: false),
        fixtureInputInventory: .init(
            exactFiles: fixtureInputFiles,
            exactFileCount: 5,
            packagePath: "Tests/PrimeValidationWorkflow",
            fixtureProductName: "PrimeValidationWorkflowFixtureChild",
            fixtureTargetName: "PrimeValidationWorkflowFixtureChild",
            fixtureExecutableLeaf: "PrimeValidationWorkflowFixtureChild",
            currentAcceptancePinByteCount: 89_632,
            currentAcceptancePinSHA256:
                "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd",
            currentAcceptancePinSourceType: "PrimeSecureChildFixtureBinaryPin",
            packageManifestMutationAuthorized: false,
            packageLockMutationAuthorized: false,
            mirrorMutationAuthorized: false,
            fixtureSourceMutationAuthorized: false,
            secureChildKernelMutationAuthorized: false,
            currentPinMutationAuthorized: false),
        sharedTopologyHelperContract: .init(
            classifierSource: implementationFiles[0],
            helperSource: implementationFiles[3],
            matrixSource: implementationFiles[2],
            sourcedFunctionName: "prime_verify_exact_revision_topology_v1",
            helperFirstExecutableStatement: "[[ \"$-\" == *p* ]] || return 97",
            helperSecondExecutableStatement: "builtin unset BASH_ENV ENV",
            ordinaryFlatArgumentGrammar:
                "<canonical_absolute_repository> <canonical_request_count> then_each <role> <literal_commit_oid> <expected_tree_oid> <canonical_parent_count> <ordered_parent_oid_repeated_parent_count_times>",
            optionalRelationSuffixMarker: "--ordered-merge-child-relation",
            optionalRelationSuffixGrammar:
                "--ordered-merge-child-relation <merge_role> <literal_merge_oid> <independently_admitted_index_tree_oid> <fixed_parent1_oid> <child_role>",
            currentIndexMarker: "--current-index-exact-revision",
            currentIndexMarkerGrammar:
                "zero_operand_terminal_marker_selecting_explicit_request_ordinal_1",
            maximumOrdinaryExplicitRequestCount: 8,
            maximumRelationExplicitRequestCount: 6,
            exactRelationImplicitObjectCount: 2,
            maximumTotalObjectCount: 8,
            maximumParentCount: 8,
            exactAllowedAmbientInputNames: ["RUNNER_TEMP"],
            successResultCode: "TOPOLOGY_VERIFIED",
            successReturnStatus: 0,
            emittedFailureReturnStatus: 1,
            internalNoRecordFailureReturnStatus: 2,
            maximumCanonicalRecordByteCount: 512,
            recordHasOneTerminalLF: true,
            stderrPublished: false,
            relationBindsOrderedMergeAndDiscoveredChild: true,
            activatedMarkerBindsHEADCleanStatusAndIndexTreeBeforeAndAfterRawObservation:
                true,
            sameEUIDConcurrentMutationInScope: false),
        currentAuthorityTopologyCallContract: .init(
            unchangedFetchDepth: 2,
            unchangedFetchesGuaranteeHistoricalReviewedHeadAvailability: false,
            reviewedHeadDirectChildAndSameTreeBoundByFrozenRun170AndRun171Evidence:
                true,
            frozenExternalEvidenceRunNumbers: [170, 171],
            availableImplementationBaseRevision:
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
            availableImplementationBaseTree:
                "354265ca2344246abc33ce1e33ba56f749b16797",
            availableImplementationBaseOrderedParentRevisions: [
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
                "8167f1eafdedf6e9344fde7a6542bd7e07600d8e",
            ],
            helperReprovesHistoricalReviewedHeadAvailability: false,
            availableImplementationBaseUsesRawReplacementDisabledSHAReboundHelperProof:
                true,
            pullRequestExplicitRequestCount: 2,
            pullRequestCurrentExactRevisionRequestOrdinal: 1,
            pullRequestVerifiedImplementationBaseRequestOrdinal: 2,
            pullRequestExactFunctionArgumentVector: [
                "prime_verify_exact_revision_topology_v1",
                "<canonical_exact_checkout_root>", "2",
                "current_exact_revision", "<github.event.pull_request.head.sha>",
                "<independently_admitted_current_index_tree>", "1",
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
                "verified_implementation_base",
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
                "354265ca2344246abc33ce1e33ba56f749b16797", "2",
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
                "8167f1eafdedf6e9344fde7a6542bd7e07600d8e",
                "--current-index-exact-revision",
            ],
            pushExplicitRequestCount: 1,
            pushVerifiedImplementationBaseRequestOrdinal: 1,
            pushExactFunctionArgumentVector: [
                "prime_verify_exact_revision_topology_v1",
                "<canonical_exact_checkout_root>", "1",
                "verified_implementation_base",
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
                "354265ca2344246abc33ce1e33ba56f749b16797", "2",
                "b7808f39815ebf639b183e00d2cd769a29ebad18",
                "8167f1eafdedf6e9344fde7a6542bd7e07600d8e",
                "--ordered-merge-child-relation",
                "current_exact_revision", "<github.sha>",
                "<independently_admitted_current_index_tree>",
                "8dbbe8987da06b7e6cb9279e65a339595b77ca3b",
                "current_reviewed_child",
            ],
            pullRequestUsesCurrentIndexMarker: true,
            pushUsesOrderedMergeChildRelationSuffix: true,
            legacyExactCommitChecksAreCumulativeConsistencyOnly: true,
            legacyExactCommitChecksProvideRawReplacementDisabledSHAReboundProof:
                false,
            fetchVectorChangeAuthorized: false),
        authorityPatchContract: .init(
            exactOrderedPaths: authorityPaths,
            exactPathCount: 5,
            modifiedExistingPathCount: 3,
            addedPathCount: 2,
            soleAuthorityTestClassName:
                "PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityTests",
            soleAuthorityTestMethodName:
                "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
            soleAuthorityTestExpectedStartCount: 1,
            soleAuthorityTestExpectedPassCount: 1,
            expectedActiveLatinTestCount: 116,
            expectedRootTestCount: 90,
            expectedIsolatedTestCount: 6,
            expectedFocusedWholeTestCount: 96,
            expectedRetainedLiveTestCount: 46,
            expectedAggregateTestCount: 142,
            expectedEmbeddedProvenanceRecordCount: 532,
            activeRootTimeoutMinutes: 45,
            reviewedMainTimeoutMinutes: 90,
            workflowJobCount: 2,
            activeRootUserStepCount: 5,
            reviewedMainUserStepCount: 5,
            workflowJobAndStepTopologyMustRemainUnchanged: true,
            fetchVectorsMustRemainByteIdentical: true,
            retainedLiveCommandsMustRemainByteIdentical: true,
            packageManifestMustRemainByteIdentical: true,
            packageLockMustRemainByteIdentical: true,
            currentHelperImplementationMustRemainByteIdentical: true,
            baselineHostedGateMatrixTestsAndRetainedLiveCommandsStillExecute: true,
            currentPatchExecutesMeasurement: false),
        futureMechanicsPatchContract: .init(
            exactOrderedPaths: mechanicsPaths,
            exactPathCount: 5,
            modifiedExistingPathCount: 3,
            addedPathCount: 2,
            launcherPath:
                ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement-v2.sh",
            evaluatorPath:
                "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluatorV2.swift",
            exactMainGreenRequiredBeforeImplementation: true,
            authorityMergeRevisionAvailableOnlyAfterClosure: true,
            authorityMergeTreeAvailableOnlyAfterClosure: true,
            futureMechanicsPullRequestHeadFrozenHere: false,
            futureMechanicsMergeRevisionFrozenHere: false,
            futureMechanicsMergeTreeFrozenHere: false,
            futureMechanicsWorkflowRunFrozenHere: false,
            mechanicsPullRequestHeadMustBeDirectChildOfAuthorityMerge: true,
            mechanicsMergeMustBeSignedTwoParentSameTreeMerge: true,
            noInterveningMainCommitAuthorized: true,
            mainPushOnly: true,
            requiredRepository: "Ergentics/ergentics-prime",
            requiredEvent: "push",
            requiredRef: "refs/heads/main",
            requiredRunAttempt: 1,
            privilegedBashInvocationPattern:
                "/bin/bash -p .github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement-v2.sh",
            launcherFirstExecutableStatement: "[[ \"$-\" == *p* ]] || exit 97",
            launcherSecondExecutableStatement: "builtin unset BASH_ENV ENV",
            bootstrapUsesOnlyBashBuiltinsBeforeToolAdmission: true,
            launcherMustPerformEquivalentThreePathSourceAdmission: true,
            launcherMustSourceSharedHelper: true,
            duplicatedPrivateTopologyParserCount: 0,
            helperRelationArgumentVector: [
                "<canonical_exact_checkout_root>", "1",
                "verified_authority_base", "<authority_merge_revision>",
                "<authority_merge_tree>", "2",
                "<authority_merge_parent1>", "<authority_merge_parent2>",
                "--ordered-merge-child-relation",
                "current_exact_revision", "<mechanics_merge_revision>",
                "<independently_admitted_current_index_tree>",
                "<authority_merge_revision>", "current_reviewed_child",
            ],
            helperFixedAuthorityBaseExplicitRequestCount: 1,
            helperFixedAuthorityBaseExplicitRequestOrdinal: 1,
            helperUsesOrderedMergeChildRelationSuffix: true,
            helperFixedAuthorityBaseUsesRawReplacementDisabledSHAReboundProof:
                true,
            helperCallCount: 1,
            helperRecordCapturedBoundedlyAndNotRepublishedRaw: true,
            helperFailureProjectedAsOneSanitizedMeasurementRecordWhenLauncherControlsReturn:
                true,
            anyTopologyHelperFailureIsTerminal: true,
            topologyFailureConsumesBuildAttempt: false,
            expectedRootTestCount: 90,
            expectedIsolatedTestCount: 6,
            expectedFocusedWholeTestCount: 96,
            expectedRetainedLiveTestCount: 46,
            expectedAggregateTestCount: 142,
            expectedEmbeddedProvenanceRecordCount: 534,
            reviewedUserStepAdditionCount: 1,
            activeRootTimeoutMinutesRemains: 45,
            reviewedMainTimeoutMinutesRemains: 90,
            predecessorReviewedDurationSeconds: 4_046,
            predecessorReviewedTimeoutHeadroomSeconds: 1_354,
            timingHeadroomGuaranteesFutureMeasurementCompletion: false,
            insufficientTimingRequiresSeparateAuthorityBeforeConsumption: true),
        measurementExecutionContract: .init(
            privateBaseLeaf:
                "prime-secure-child-validation-fixture-identity-measurement-root-v2",
            exactTreeSourceRootLeaves: [
                "exact-tree-source-a-v2", "exact-tree-source-b-v2",
            ],
            fixtureBuildRootSetLeaves: [
                "fixture-build-root-set-a-v2", "fixture-build-root-set-b-v2",
            ],
            evaluatorRootLeaf:
                "prime-secure-child-validation-fixture-identity-evaluator-root-v2",
            evaluatorExecutableLeaf:
                "prime-secure-child-validation-fixture-identity-evaluator-v2",
            buildConfiguration: "release",
            independentExactTreeSourceRootCount: 2,
            independentBuildRootSetCount: 2,
            fixtureProductBuildCommandCount: 2,
            showBinPathCommandCount: 2,
            evaluatorCompileCommandCount: 1,
            evaluatorCommandCount: 1,
            fixtureExecutableInvocationCount: 0,
            adapterInvocationCount: 0,
            leaseAcquisitionCount: 0,
            modelExecutionCount: 0,
            mlxExecutionCount: 0,
            metalExecutionCount: 0,
            pythonInvocationCount: 0,
            cppInvocationCount: 0,
            dependencyNetworkInvocationCount: 0,
            maximumFixtureExecutableByteCount: 4_194_304,
            maximumShowBinAcceptedByteCount: 1_024,
            maximumEvaluatorJSONByteCount: 2_048,
            maximumPublishedRecordLineByteCount: 4_096,
            maximumReadChunkByteCount: 65_536,
            evaluatorRequiredImports: ["CryptoKit", "Darwin", "Foundation", "MachO"],
            evaluatorOpenFlags: ["O_RDONLY", "O_NOFOLLOW", "O_CLOEXEC"],
            cryptoKitSHA256Required: true,
            fullByteEqualityRequired: true,
            thinArm64MachORequired: true,
            exactLCUUIDCount: 1,
            exactLCBuildVersionCount: 1,
            entireLCBuildVersionCommandBytesCompared: true,
            codeSignatureValidityEstablished: false,
            launchabilityEstablished: false,
            attemptConsumedImmediatelyBeforeFirstBuild: true,
            preBuildTopologyFailureConsumesAttempt: false,
            createdRootsRetainedOnlyUntilEphemeralRunnerTeardown: true,
            createdRootReuseAuthorized: false,
            actionsArtifactCount: 0,
            durableEvidenceEstablishedByLauncher: false),
        measurementOutputContract: .init(
            prefix:
                "prime-secure-child validation-fixture-identity measurement-v2: ",
            schemaID:
                "prime_secure_child_validation_fixture_identity_measurement_v2_outer_observation_v1",
            schemaVersion: 1,
            canonicalJSONRequired: true,
            exactLineCountWhenPresent: 1,
            terminalLFRequiredWhenPresent: true,
            maximumLineByteCount: 4_096,
            measurementOutcomeMembers: ["IDENTICAL", "DIFFERENT", "UNAVAILABLE"],
            observationOutcomeMembers: [
                "IDENTICAL", "DIFFERENT", "UNAVAILABLE", "FAILURE",
            ],
            pinRelationMembers: ["MATCH", "DIFFERENT"],
            identicalResultCodes: [
                "PASS_IDENTICAL_CURRENT_PIN",
                "PASS_IDENTICAL_DIFFERENT_PIN",
            ],
            differentResultCode: "DIFFERENT_BUILD",
            unavailableResultCodes: [
                "TOPOLOGY_REFUSED",
                "INVOCATION_ADMISSION_REFUSED",
                "MEASUREMENT_ROOT_REFUSED",
                "SOURCE_ROOT_REFUSED",
                "BUILD_ROOT_REFUSED",
                "MIRROR_REFUSED",
                "BUILD_A_REFUSED",
                "SHOW_BIN_A_REFUSED",
                "SHOW_BIN_A_TRANSPORT_REFUSED",
                "ARTIFACT_A_ADMISSION_REFUSED",
                "BUILD_B_REFUSED",
                "SHOW_BIN_B_REFUSED",
                "SHOW_BIN_B_TRANSPORT_REFUSED",
                "ARTIFACT_B_ADMISSION_REFUSED",
                "EVALUATOR_ROOT_REFUSED",
                "EVALUATOR_SOURCE_REFUSED",
                "EVALUATOR_COMPILE_REFUSED",
                "EVALUATOR_ADMISSION_REFUSED",
                "EVALUATOR_TRANSPORT_REFUSED",
                "EVALUATOR_COMMAND_REFUSED",
                "EVALUATOR_CONTRACT_REFUSED",
                "CAPTURE_REFUSED",
                "UNCLASSIFIED",
            ],
            failureResultCodes: [
                "LAUNCHER_NOT_REACHED",
                "EXTERNAL_TIMEOUT",
                "EXTERNAL_CANCELLATION",
                "EXIT_PROJECTION_FAILURE",
                "ABRUPT_HOST_LOSS",
                "RECORD_ABSENT_CAUSE_UNESTABLISHED",
            ],
            topologyFailureResultCode: "TOPOLOGY_REFUSED",
            exactLowLevelResultMappings: lowLevelResultMappings,
            everyLowLevelResultMappedExactlyOnce: true,
            identicalDefinition:
                "release_build_a_and_b_have_exact_full_byte_equality",
            differentDefinition:
                "release_build_a_and_b_have_exact_full_byte_inequality",
            pinMatchDefinition:
                "only_after_IDENTICAL_both_artifacts_match_configured_byte_count_and_sha256",
            pinDifferentDefinition:
                "only_after_IDENTICAL_at_least_one_configured_byte_count_or_sha256_dimension_differs",
            failureDefinition:
                "launcher_not_reached_OR_external_timeout_OR_external_cancellation_OR_exit_projection_failure_OR_abrupt_host_loss_OR_record_absent_cause_unestablished",
            differentBuildIsTerminal: true,
            identicalDifferentPinIsNotDifferentMeasurement: true,
            identityFieldsRequiredForIdenticalOrDifferent: true,
            pinRelationNullableUnlessOutcomeIdentical: true,
            rawAbsolutePathFieldCount: 0,
            rawBuildOutputOrErrorFieldCount: 0,
            exactRecordCountForEveryLauncherControlledOutcome: 1,
            recordMayBeAbsentOnlyAfterExternalTimeoutCancellationHostLossLauncherNotReachedExitProjectionFailureOrCauseUnestablished:
                true,
            absentRecordCauseClassificationRequiresPositiveEvidence: true,
            absentRecordCauseMustNeverBeInferredOrInvented: true,
            unclassifiedAbsentRecordResultCode:
                "RECORD_ABSENT_CAUSE_UNESTABLISHED",
            absentRecordAttemptConsumptionWithoutSeparateProof: "unavailable",
            failureOutcomesEstablishMeasurement: false,
            failureOutcomesEstablishFixtureIdentity: false,
            failureOutcomesAuthorizeRetryRerunOrReplacement: false,
            captureRefusedIsLauncherControlledExactlyOneRecord: true,
            everyRecordOrAbsentOutcomeRequiresAppendOnlyObservationAndRetirement:
                true,
            falseAttemptConsumptionStillRetiresOpportunity: true),
        exactPhaseTransitions: phaseTransitions,
        preservationContract: .init(
            retiredV1PathsMustRemainByteIdentical: true,
            retiredRun160RemainsTerminal: true,
            topologyImplementationFilesMustRemainByteIdentical: true,
            topologyAuthorityPairsMustRemainByteIdentical: true,
            packageManifestMutationAuthorized: false,
            packageLockMutationAuthorized: false,
            dependencyResolutionMutationAuthorized: false,
            secureChildKernelMutationAuthorized: false,
            currentPinMutationAuthorized: false,
            existingV1LauncherRetrofittedOrReactivated: false,
            existingV1EvaluatorRetrofittedOrReactivated: false),
        authorityCeiling: .init(
            predecessorExactMainClosureEstablished: true,
            predecessorTopologyVerificationEstablished: true,
            retiredV1ClosurePreserved: true,
            v2MeasurementAuthorityEstablished: true,
            exactlyOneFutureMechanicsAttemptAuthorizedAfterClosure: true,
            currentPatchIsPureDataOnly: true,
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
            currentPinMatchEstablished: false,
            currentPinMismatchEstablished: false,
            pinRepairAuthorized: false,
            pinRepairPerformed: false,
            noMutationConfirmationAuthorized: false,
            noMutationConfirmationPerformed: false,
            realMonitorHeldLeaseCanaryAuthorized: false,
            realMonitorHeldLeaseCanaryPerformed: false,
            retryOrRerunAuthorized: false,
            modelExecutionAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        orderedRequiredSeparateActions: [
            "merge_this_pure_exact5_v2_measurement_authority_and_observe_exact_main_green",
            "implement_only_the_separately_reviewed_exact5_v2_measurement_mechanics_once",
            "append_the_v2_measurement_observation_and_irreversibly_retire_the_opportunity",
            "for_DIFFERENT_UNAVAILABLE_FAILURE_or_topology_helper_failure_stop_terminally_without_repair_confirmation_rerun_replacement_or_canary",
            "for_IDENTICAL_MATCH_separately_authorize_one_no_mutation_confirmation",
            "for_IDENTICAL_DIFFERENT_separately_authorize_exact_pin_repair",
            "merge_only_a_separately_authorized_exact_pin_repair",
            "after_pin_match_or_successful_repair_separately_authorize_one_no_mutation_confirmation",
            "only_successful_separately_observed_confirmation_may_precede_a_separate_real_monitor_held_lease_canary_authority",
        ])

    public func canonicalData() throws -> Data {
        try validate()
        return try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 131_072 else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try PrimeCanonicalJSON.encode(value) == data else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityError
                .noncanonicalEncoding
        }
        return value
    }

    public func validate() throws {
        guard self == Self.frozenV1 else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityError
                .contractDrift
        }
    }

    public func validateExactV1() throws {
        try validate()
        let canonical = try PrimeCanonicalJSON.encode(self)
        guard Self.canonicalByteCount > 0,
              Self.canonicalSHA256.utf8.count == 64,
              canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256
        else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityError
                .contractDrift
        }
    }
}

private extension PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityV1 {
    static let implementationFiles: [FileIdentity] = [
        file(1, ".github/scripts/PrimeExactRevisionTopologyClassifier.swift", "100644", "853f893a057da09e7ce2b0fda873cd944cb45907", 25_327, 751, "e2ae76e886deb1ec970c10a2d10dbadc79c8f4a3358533c68aea748ba184c4cb", "exact_revision_topology_classifier"),
        file(2, ".github/scripts/prime-ci-active-root-quarantine.sh", "100755", "3cb6fb84fc6bb38231606a710a772fec5aa5767e", 1_579_939, 24_998, "7562f0f075ad8bb0d50ccff1ae16018240f4f0c2899604320345f989a2899bf0", "topology_bound_active_root_gate"),
        file(3, ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh", "100755", "dd660a068c6645957567b97eeff917907e365966", 138_129, 2_614, "37233f80067bd3aebc82a1fad8fc00d27b89d82278bbc23a5f66c1067dd6e0f2", "exact_revision_topology_matrix"),
        file(4, ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", "100755", "73533fa440b29c5eae6f4ecc5fbde078a747636f", 101_131, 2_262, "78c7ea04310ba5f531f626e320c0a959554c97caf3cec640360b292869d611f1", "shared_exact_revision_topology_helper"),
        file(5, ".github/workflows/prime-active-root-quarantine.yml", "100644", "9470bba66c913d6cbb18348c1c50ffac93e1dd2c", 214_709, 771, "58ac13432cddd236ae71fc1de55ca1541f14996b430dd80f26708586a30f864d", "topology_bound_hosted_workflow"),
    ]

    static let retiredV1Files: [FileIdentity] = [
        file(1, ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh", "100755", "2b4cd9ca38410eed6661c1de50fcdab595c24b77", 57_143, 1_204, "0c00a5ff7b5752be59d674699b7dca4bfa5b3fe973ab96e7cf8a0f455b9f2eea", "retired_v1_canary_launcher"),
        file(2, ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh", "100755", "076e9dd60ed692689ebfe443b7911dd4acfe9bdc", 72_908, 1_468, "372a526f521a682d94e92733e15bfe2a2131426aefe8cc8809e35cd9e082b57c", "retired_v1_measurement_launcher"),
        file(3, "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthority.swift", "100644", "75eb75e5fd50f5ca62690d8a32ac666255437b34", 163_973, 3_006, "ab0348a46627d69dc2ab5280cfccfad8cc855f97c8c4100d912f4a79e1f5053e", "retired_v1_canary_authority"),
        file(4, "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservation.swift", "100644", "bd84b810a1842635b7e874826b7c58cf42baacda", 52_517, 1_103, "739eed7ece6ea1b2f952d9f02ad613af15adc100788979a47f0edee4aedbb2f1", "retired_v1_pin_mismatch_observation"),
        file(5, "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementAuthority.swift", "100644", "1d81d4a29f06fbc18ca3c1a97742159b5280837e", 124_073, 2_175, "ff043520c144196532885ca79f0b2047cd8d28ac61ca544d259f140ed4e6aea4", "retired_v1_measurement_authority"),
        file(6, "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservation.swift", "100644", "4aeecf6c444bf4e229c06a5b5a14a806fca643e1", 84_126, 1_644, "4cda5a461882c401864f11ff761de5ae50170199db56834bf74da9a8ba533232", "retired_v1_measurement_observation"),
        file(7, "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityTests.swift", "100644", "4dded5edd6d43802e3e7341ee5b4b6d2cce531b4", 74_789, 1_538, "73a6d64a509b2fa47fae6df593c0d10e7ab3cf44fb2921d585d2f8ffca838682", "retired_v1_canary_authority_test"),
        file(8, "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests.swift", "100644", "01ee01a48eb24bf25139c01db2b4ec80196712a1", 36_265, 811, "bb89e3b5072622d594383143720db99411746766e55cca229cde44724b244671", "retired_v1_pin_mismatch_observation_test"),
        file(9, "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityTests.swift", "100644", "1c5f39805556b5e7e99982fae2ec101336585376", 88_558, 2_009, "de2470b5657520509c1208f89c55b7cd46a4bfd9bcb1fc885c3ae92746a2fba0", "retired_v1_measurement_authority_test"),
        file(10, "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationTests.swift", "100644", "b7125ce6e0986e849ae0032f4e15eafca37a5acb", 49_276, 1_121, "cd94cc74781b3928625042e98d4c5767c382a0f3b6eb4db43d84573184a1c517", "retired_v1_measurement_observation_test"),
        file(11, "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift", "100644", "ead815d5f051ed1308f360aa701a1a5d389556c6", 16_967, 473, "248ae56786dace0e7b19a9a82ee977b9a4fa705a63b9268e2ee058c180ddaa82", "retired_v1_measurement_evaluator"),
    ]

    static let fixtureInputFiles: [FileIdentity] = [
        file(1, "Tests/PrimeValidationWorkflow/Package.swift", "100644", "fe98104c7e812d0c44ee1e38dcc10857455bf54f", 2_587, 88, "99354cfc3da2d75ac960d1c704257656eec563bc17344d694678626ae9c1f518", "fixed_validation_package_manifest"),
        file(2, "Tests/PrimeValidationWorkflow/Package.resolved", "100644", "69919288b1a5da256ff408a4d65106b23abc8f89", 645, 23, "d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a", "fixed_validation_package_lock"),
        file(3, "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json", "100644", "be0c6cc4685f3fde2b5c747118478397bc34dcf8", 37, 4, "b8476f18b4ee05b10e208cc37667d3c69e117bd5eda0162e77804570c5713a6b", "fixed_empty_mirror_configuration"),
        file(4, "Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowFixtureChild/PrimeValidationWorkflowFixtureChild.swift", "100644", "5e45832ed046da7bfd4541ad362018fad97371f5", 19_353, 614, "f016793fb012c9dc70a47b5ea0ba325f582d1e7c0c5a84b303855cc8543eb274", "fixed_closed_fixture_source"),
        file(5, "Sources/PrimeCore/PrimeSecureChildKernel.swift", "100644", "bfa381796b9647863e704006dbaa1406c533c7c5", 83_657, 2_327, "1ed890d017b67c97a0d980d58cb7614bb71362091c02b03d26a26222b24d5fcd", "current_layer_a_fixture_pin_source"),
    ]

    static let authorityPaths: [PathContract] = [
        path(1, ".github/scripts/prime-ci-active-root-quarantine.sh", "M", "100755", "bind_run171_and_exact5_v2_authority_ceiling"),
        path(2, ".github/workflows/prime-active-root-quarantine.yml", "M", "100644", "integrate_sole_pure_v2_authority_test"),
        path(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", "M", "100644", "bind_532_record_source_identity"),
        path(4, "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementV2Authority.swift", "A", "100644", "pure_v2_measurement_authority"),
        path(5, "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementV2AuthorityTests.swift", "A", "100644", "sole_exhaustive_pure_authority_test"),
    ]

    static let mechanicsPaths: [PathContract] = [
        path(1, ".github/scripts/prime-ci-active-root-quarantine.sh", "M", "100755", "bind_authority_closure_and_exact5_v2_mechanics"),
        path(2, ".github/workflows/prime-active-root-quarantine.yml", "M", "100644", "invoke_one_main_push_v2_measurement_after_retained_live"),
        path(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", "M", "100644", "bind_new_launcher_and_evaluator_source_identities"),
        path(4, ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement-v2.sh", "A", "100755", "topology_bound_closed_native_repeat_build_launcher"),
        path(5, "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluatorV2.swift", "A", "100644", "standalone_descriptor_rooted_macho_crypto_evaluator_v2"),
    ]

    static let lowLevelResultMappings: [MeasurementOutputContract.ResultMapping] = [
        mapping("PASS_IDENTICAL_CURRENT_PIN", "one", "true", "IDENTICAL", "MATCH", "success"),
        mapping("PASS_IDENTICAL_DIFFERENT_PIN", "one", "true", "IDENTICAL", "DIFFERENT", "success"),
        mapping("DIFFERENT_BUILD", "one", "true", "DIFFERENT", nil, "failure"),
        mapping("TOPOLOGY_REFUSED", "one", "false", "UNAVAILABLE", nil, "failure"),
        mapping("INVOCATION_ADMISSION_REFUSED", "one", "false", "UNAVAILABLE", nil, "failure"),
        mapping("MEASUREMENT_ROOT_REFUSED", "one", "false", "UNAVAILABLE", nil, "failure"),
        mapping("SOURCE_ROOT_REFUSED", "one", "false", "UNAVAILABLE", nil, "failure"),
        mapping("BUILD_ROOT_REFUSED", "one", "false", "UNAVAILABLE", nil, "failure"),
        mapping("MIRROR_REFUSED", "one", "false", "UNAVAILABLE", nil, "failure"),
        mapping("BUILD_A_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("SHOW_BIN_A_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("SHOW_BIN_A_TRANSPORT_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("ARTIFACT_A_ADMISSION_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("BUILD_B_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("SHOW_BIN_B_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("SHOW_BIN_B_TRANSPORT_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("ARTIFACT_B_ADMISSION_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("EVALUATOR_ROOT_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("EVALUATOR_SOURCE_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("EVALUATOR_COMPILE_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("EVALUATOR_ADMISSION_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("EVALUATOR_TRANSPORT_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("EVALUATOR_COMMAND_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("EVALUATOR_CONTRACT_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("CAPTURE_REFUSED", "one", "true", "UNAVAILABLE", nil, "failure"),
        mapping("UNCLASSIFIED", "one", "false", "UNAVAILABLE", nil, "failure"),
        mapping("LAUNCHER_NOT_REACHED", "zero", "unavailable", "FAILURE", nil, "failure"),
        mapping("EXTERNAL_TIMEOUT", "zero_or_one_nonaccepting", "unavailable", "FAILURE", nil, "timed_out"),
        mapping("EXTERNAL_CANCELLATION", "zero_or_one_nonaccepting", "unavailable", "FAILURE", nil, "cancelled"),
        mapping("EXIT_PROJECTION_FAILURE", "zero_or_one_nonaccepting", "unavailable", "FAILURE", nil, "failure"),
        mapping("ABRUPT_HOST_LOSS", "zero_or_one_nonaccepting", "unavailable", "FAILURE", nil, "failure"),
        mapping("RECORD_ABSENT_CAUSE_UNESTABLISHED", "zero", "unavailable", "FAILURE", nil, "failure"),
    ]

    static let phaseTransitions: [PhaseTransition] = [
        transition(1, "DIFFERENT", nil, [], true),
        transition(2, "UNAVAILABLE", nil, [], true),
        transition(3, "FAILURE", nil, [], true),
        transition(4, "IDENTICAL", "MATCH", ["separate_no_mutation_confirmation_authority"], false),
        transition(5, "IDENTICAL", "DIFFERENT", ["separate_exact_pin_repair_authority"], false),
    ]

    static func file(
        _ ordinal: Int,
        _ path: String,
        _ mode: String,
        _ blob: String,
        _ bytes: Int,
        _ lf: Int,
        _ sha256: String,
        _ role: String
    ) -> FileIdentity {
        .init(
            ordinal: ordinal,
            path: path,
            gitMode: mode,
            gitBlob: blob,
            byteCount: bytes,
            lfByteCount: lf,
            crByteCount: 0,
            sha256: sha256,
            role: role)
    }

    static func path(
        _ ordinal: Int,
        _ path: String,
        _ status: String,
        _ mode: String,
        _ role: String
    ) -> PathContract {
        .init(
            ordinal: ordinal,
            path: path,
            gitStatus: status,
            gitMode: mode,
            role: role)
    }

    static func transition(
        _ ordinal: Int,
        _ outcome: String,
        _ pin: String?,
        _ next: [String],
        _ terminal: Bool
    ) -> PhaseTransition {
        .init(
            ordinal: ordinal,
            measurementOutcome: outcome,
            pinRelation: pin,
            exactAllowedNextAuthorityIDs: next,
            terminalAbsentNewAuthority: terminal,
            retryRerunReplacementOrImplicitCanaryAuthorized: false)
    }

    static func mapping(
        _ resultCode: String,
        _ recordCardinality: String,
        _ attemptConsumed: String,
        _ outcome: String,
        _ pin: String?,
        _ workflowConclusion: String
    ) -> MeasurementOutputContract.ResultMapping {
        .init(
            lowLevelResultCode: resultCode,
            recordCardinality: recordCardinality,
            attemptConsumed: attemptConsumed,
            measurementOutcome: outcome,
            pinRelation: pin,
            workflowConclusion: workflowConclusion,
            terminallyRetiresMeasurementOpportunity: true)
    }
}
