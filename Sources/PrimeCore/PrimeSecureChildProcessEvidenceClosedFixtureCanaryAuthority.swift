// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

/// Pure authority for one later closed compatibility canary over the already
/// merged Prime secure-child process/evidence Layer A.
///
/// This value is data only. It contains no executable locator, argument,
/// environment, process, descriptor, filesystem, lease, diagnostic-output,
/// MLX, Metal, Native300M, Python, or C++ capability. In particular, this
/// authority PR does not execute the fixture canary. It freezes one separately
/// merged exact-three mechanics successor, followed by mandatory observation
/// and retirement, without widening the existing closed fixture API.
public struct PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1:
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
        public let role: String
    }

    public struct ImplementationAuthorityPredecessor:
        Codable,
        Equatable,
        Sendable
    {
        public let authorityID: String
        public let canonicalByteCount: Int
        public let canonicalSHA256: String
        public let source: SourceIdentity
        public let test: SourceIdentity
        public let implementationAuthorityEstablished: Bool
        public let implementationPatchAuthorizedByPredecessor: Bool
        public let liveCanaryAuthorizedByPredecessor: Bool
        public let separateCanaryAuthorityRequired: Bool
    }

    public struct LayerAExactMainClosure: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParents: [String]
        public let pullRequestNumber: Int
        public let pullRequestBaseRevision: String
        public let pullRequestHeadRevision: String
        public let signedMergeVerified: Bool
        public let mergeTimestampUTC: String
        public let signatureVerifiedAtUTC: String
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let previousAttemptURLIsNull: Bool
        public let workflowRerunCount: Int
        public let workflowConclusion: String
        public let workflowCreatedAtUTC: String
        public let workflowStartedAtUTC: String
        public let workflowUpdatedAtUTC: String
        public let activeJobID: Int
        public let activeJobConclusion: String
        public let activeRunnerLabel: String
        public let activeJobStartedAtUTC: String
        public let activeJobCompletedAtUTC: String
        public let activeLatinTestCount: Int
        public let activeLatinFailureCount: Int
        public let reviewedJobID: Int
        public let reviewedJobConclusion: String
        public let reviewedRunnerLabel: String
        public let reviewedJobStartedAtUTC: String
        public let reviewedJobCompletedAtUTC: String
        public let focusedTestsStartedAtUTC: String
        public let focusedTestsCompletedAtUTC: String
        public let retainedLiveTestsStartedAtUTC: String
        public let retainedLiveTestsCompletedAtUTC: String
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedMetalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let tokenizerTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let reviewedFailureCount: Int
        public let reviewedSkipCount: Int
        public let layerATestMethodStartCount: Int
        public let layerATestMethodPassCount: Int
        public let actionsArtifactCount: Int
        public let stage7JobCount: Int
        public let stage7LauncherInvocationCount: Int
        public let stage7ExecutableInvocationCount: Int
        public let stage7ReceiptCount: Int
        public let closedCanaryLauncherInvocationCount: Int
        public let integrationAdapterInvocationCount: Int
        public let capabilityPreparationCount: Int
        public let capabilityExecuteCallCount: Int
        public let successfulTopLevelCaptureCount: Int
        public let physicalFixtureProcessCount: Int
        public let leaseAcquisitionInvocationCount: Int
        public let pythonInterpreterInvocationCount: Int
        public let newCppImplementationInvocationCount: Int
        public let actionsArtifactUploadCount: Int
        public let embeddedSourceIdentitySHA256: String
        public let exactMainClosureEstablished: Bool
    }

    public struct AuthorityScaffold: Codable, Equatable, Sendable {
        public let exactOrderedChangedPaths: [String]
        public let exactPathCount: Int
        public let preservedIndexSHA256: String
        public let activeLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let embeddedProvenanceRecordCount: Int
        public let authorityTestMethodCount: Int
        public let processMechanicsInvocationCount: Int
        public let fixtureInvocationCount: Int
        public let leaseInvocationCount: Int
        public let hostedDiagnosticEmissionCount: Int
        public let filesystemMutationCount: Int
        public let networkInvocationCount: Int
        public let onlyExactFivePathsAuthorized: Bool
    }

    public struct FrozenLayerAInventory: Codable, Equatable, Sendable {
        public let orderedSourceIdentities: [SourceIdentity]
        public let exactIdentityCount: Int
        public let exactInternalTypeNames: [String]
        public let exactInternalTypeCount: Int
        public let exactInjectedTestMethodCount: Int
        public let publicFixtureModeCount: Int
        public let publicFixtureAPISpellingsPreserved: Bool
        public let newTypesRemainInternal: Bool
        public let trustedCaptureExactlyOneShot: Bool
        public let exactPIDReapRequired: Bool
        public let processGroupEmptyRequired: Bool
        public let terminalClosedDrainsRequired: Bool
        public let fixtureSuccessRequiresCleanEOFAndZeroErrors: Bool
        public let typedUnavailableDistinctFromObservedFalse: Bool
        public let capturedPrefixDistinctFromFullStreamDigest: Bool
        public let diagnosticMaximumCanonicalByteCount: Int
        public let diagnosticConstructionOnlyAfterContainment: Bool
        public let diagnosticEmissionAuthorized: Bool
        public let leaseSeamOnlyRetainsExternallyOwnedOpaqueCapability: Bool
        public let leaseSeamAcquiresOrTransfersCapability: Bool
        public let layerAMutationAuthorizedByThisAuthority: Bool
    }

    public struct FrozenValidationPayload: Codable, Equatable, Sendable {
        public let packageManifest: SourceIdentity
        public let packageResolved: SourceIdentity
        public let fixtureChildSource: SourceIdentity
        public let integrationSource: SourceIdentity
        public let fixtureProductName: String
        public let integrationProductName: String
        public let orderedProducts: [String]
        public let payloadSourceMutationAuthorized: Bool
        public let packageManifestMutationAuthorized: Bool
        public let packageResolvedMutationAuthorized: Bool
        public let newSwiftPMTargetAuthorized: Bool
        public let arbitraryExecutableAdapterAuthorized: Bool
    }

    public struct OrderedModeContract: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let mode: String
        public let expectedTopLevelCaptureCount: Int
        public let maximumWallNanoseconds: UInt64
        public let expectedCompletion: String
        public let expectedResult: String
        public let expectedArgumentZero: String
        public let expectedStandardOutputTotalByteCount: Int
        public let expectedStandardErrorTotalByteCount: Int
        public let expectedStandardOutputCapturedByteCount: Int
        public let expectedStandardErrorCapturedByteCount: Int
        public let expectedStandardOutputContract: String
        public let expectedStandardErrorContract: String
        public let standardOutputOverflowExpected: Bool
        public let standardErrorOverflowExpected: Bool
        public let expectedPreReapMembership: String
    }

    public struct DescendantDynamicOutputContract:
        Codable,
        Equatable,
        Sendable
    {
        public let mode: String
        public let standardOutputPrefix: String
        public let standardOutputTerminator: String
        public let exactLineCount: Int
        public let suffixEncoding: String
        public let suffixDigitsOnly: Bool
        public let suffixLeadingZeroAllowed: Bool
        public let suffixPlusSignAllowed: Bool
        public let suffixMinusSignAllowed: Bool
        public let minimumSuffixValue: Int
        public let maximumSuffixValue: Int
        public let minimumTotalByteCount: Int
        public let maximumTotalByteCount: Int
        public let capturedByteCountEqualsTotalByteCount: Bool
        public let fixedTotalByteCountAvailable: Bool
        public let fixedCapturedByteCountAvailable: Bool
        public let overflowExpected: Bool
        public let fixedStreamSHA256Available: Bool
        public let resultPIDMatchesOutputPIDAndMembershipPID: Bool
    }

    public struct ClosedCanaryContract: Codable, Equatable, Sendable {
        public let orderedModeContracts: [OrderedModeContract]
        public let exactModeCount: Int
        public let dynamicByteCountSentinel: Int
        public let descendantDynamicOutput: DescendantDynamicOutputContract
        public let expectedLauncherInvocationCount: Int
        public let expectedIntegrationAdapterInvocationCount: Int
        public let expectedCapabilityPreparationCount: Int
        public let expectedCapabilityExecuteCallCount: Int
        public let expectedSuccessfulTopLevelCaptureCount: Int
        public let expectedTopLevelFixtureProcessCount: Int
        public let expectedPhysicalFixtureProcessCount: Int
        public let expectedInternalDescendantProcessCount: Int
        public let expectedRejectedExecuteCallCount: Int
        public let expectedPreSpawnReplacementRejectionCount: Int
        public let expectedSequentialAlreadyConsumedRejectionCount: Int
        public let expectedConcurrentWinnerCount: Int
        public let expectedConcurrentAlreadyConsumedRejectionCount: Int
        public let allRejectedExecuteCallsSpawnNoProcess: Bool
        public let everySuccessfulReturnRequiresModeRoundTrip: Bool
        public let everySuccessfulReturnRequiresFixtureContract: Bool
        public let everySuccessfulReturnRequiresSessionAndGroupEqualPID: Bool
        public let everySuccessfulReturnRequiresDescriptorBackedJoins: Bool
        public let everySuccessfulReturnRequiresExactPIDReap: Bool
        public let everySuccessfulReturnRequiresEmptyProcessGroup: Bool
        public let everySuccessfulReturnRequiresTerminalClosedDrains: Bool
        public let everySuccessfulReturnRequiresCleanEOFAndZeroErrors: Bool
        public let typedLayerAEvidenceValidatedInternally: Bool
        public let diagnosticConstructedOnlyAfterContainment: Bool
        public let diagnosticEmittedByCanary: Bool
        public let expectedSuccessStandardOutput: String
        public let expectedSuccessStandardOutputByteCount: Int
        public let expectedSuccessStandardOutputLineCount: Int
        public let expectedSuccessStandardOutputSHA256: String
        public let expectedSuccessStandardErrorByteCount: Int
        public let expectedSuccessExitStatus: Int
        public let outputIsOperationalCompatibilityEvidenceOnly: Bool
        public let outputIsScientificEvidence: Bool
        public let outputIsDurableEvidence: Bool
    }

    public struct LocalBareMirrorContract: Codable, Equatable, Sendable {
        public let dependencyIdentity: String
        public let runnerTempPath: String
        public let fileURL: String
        public let exactOriginURL: String
        public let exactCommitSHA: String
        public let typedCommitExpression: String
        public let pinnedRefExpression: String
        public let pathMustExistAsDirectory: Bool
        public let symbolicLinkAuthorized: Bool
        public let physicalPathMustEqualExpandedRunnerTempPath: Bool
        public let absoluteGitDirectoryMustEqualPhysicalPath: Bool
        public let bareRepositoryRequired: Bool
        public let soleRemoteName: String
        public let exactOriginURLValueCount: Int
        public let revisionObjectType: String
        public let typedCommitMustResolveToExactCommit: Bool
        public let pinnedRefMustResolveToExactCommit: Bool
    }

    public struct FileURLInsteadOfMapping: Codable, Equatable, Sendable {
        public let localFileURL: String
        public let remoteURL: String
    }

    public struct MechanicsSuccessorPathContract:
        Codable,
        Equatable,
        Sendable
    {
        public let path: String
        public let gitStatus: String
        public let gitMode: String
    }

    public struct DeferredAuthorityExactMainGreenEvidence:
        Codable,
        Equatable,
        Sendable
    {
        public let evidenceAvailability: String
        public let signedAuthorityClosureRequired: Bool
        public let exactAuthorityClosureRevisionAndTreeRequired: Bool
        public let uniquePushWorkflowRunCount: Int
        public let exactWorkflowRunIDRequired: Bool
        public let exactWorkflowRunNumberRequired: Bool
        public let exactCheckSuiteIDRequired: Bool
        public let requiredWorkflowAttempt: Int
        public let previousAttemptURLMustBeNull: Bool
        public let workflowRerunCount: Int
        public let requiredWorkflowConclusion: String
        public let exactActiveJobIDRequired: Bool
        public let requiredActiveJobConclusion: String
        public let expectedActiveLatinTestCount: Int
        public let expectedActiveLatinFailureCount: Int
        public let exactReviewedJobIDRequired: Bool
        public let requiredReviewedJobConclusion: String
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedReviewedFailureCount: Int
        public let expectedReviewedSkipCount: Int
        public let expectedActionsArtifactCount: Int
        public let gateAndWorkflowFreezeExactValuesBeforeMechanics: Bool
        public let launcherClosureEvidenceAPIInvocationCount: Int
        public let launcherClosureEvidenceNetworkInvocationCount: Int
    }

    public struct OuterLauncherObservationContract:
        Codable,
        Equatable,
        Sendable
    {
        public let privateCaptureRootPath: String
        public let privateCaptureRootMustInitiallyNotExistOrBeSymbolicLink:
            Bool
        public let privateCaptureRootCreatedByExactPathMkdirWithoutParents:
            Bool
        public let privateCaptureRootMode: String
        public let privateCaptureRootMustBePhysicalDirectory: Bool
        public let privateCaptureRootSymbolicLinkAuthorized: Bool
        public let orderedCaptureStreamNames: [String]
        public let orderedFixedCaptureLeafNames: [String]
        public let fixedCaptureLeavesPrecreatedBeforeInvocation: Bool
        public let captureFileMode: String
        public let captureFilesMustBeRegular: Bool
        public let captureFileSymbolicLinksAuthorized: Bool
        public let captureFileLinkCount: Int
        public let perStreamCaptureByteCap: Int
        public let bash1024ByteFileSizeLimitBlockCount: Int
        public let layerACapturedPrefixByteCap: Int
        public let outerCaptureCapDistinctFromLayerACapturedPrefixCap: Bool
        public let rawStreamBytesForwarded: Bool
        public let rawStreamBytesIncludedInSummary: Bool
        public let rawStreamBytesUploadedAsArtifact: Bool
        public let exactAdapterCommandStates: [String]
        public let exactAdapterExecutionObservationStates: [String]
        public let shellWaitStatusObservationRequiredAfterSynchronousReturn:
            Bool
        public let shellWaitStatusAloneEstablishesAdapterExecution: Bool
        public let exactRecognizedAdapterEnvelopesMayEstablishExecution: Bool
        public let preCommandRefusalEstablishesAdapterExecutionObservedFalse:
            Bool
        public let noReportOrUnexpectedReportEstablishesAdapterExecution: Bool
        public let nativeWaiterUsed: Bool
        public let exactExitVersusSignalClassificationEstablished: Bool
        public let shellWaitStatusType: String
        public let shellWaitStatusMinimum: Int
        public let shellWaitStatusMaximum: Int
        public let shellWaitStatusZeroRequiresExpectedOutputContractForPass:
            Bool
        public let shellWaitStatusNonzeroUsesClosedDiagnosticClassification:
            Bool
        public let adapterReportedFailureAllowedShellStatuses: [Int]
        public let adapterReportedFailureStandardErrorPrefix: String
        public let adapterReportedFailureStandardErrorPrefixByteCount: Int
        public let layerAFailStopReportedShellStatus: Int
        public let layerAFailStopStandardErrorPrefix: String
        public let layerAFailStopStandardErrorPrefixByteCount: Int
        public let reportedFailureRequiresExactlyOneTerminalLF: Bool
        public let reportedFailureRequiresEmptyStandardOutput: Bool
        public let reportedFailureAllowsAdditionalLine: Bool
        public let reportedFailureAllowsCaptureCapReached: Bool
        public let adapterNoReportRequiresEmptyStandardOutput: Bool
        public let adapterNoReportRequiresEmptyStandardError: Bool
        public let unmatchedNonzeroReportResultCode: String
        public let statusZeroWrongOutputContractResultCode: String
        public let diagnosticClassifierUsesOnlyFixedByteOperations: Bool
        public let notAttemptedRequiresZeroCapturedByteCounts: Bool
        public let notAttemptedRequiredEmptyStreamSHA256: String
        public let notAttemptedRequiresCaptureCapNotReached: Bool
        public let perStreamCapturedByteCountRequired: Bool
        public let perStreamSHA256Required: Bool
        public let perStreamCaptureCapReachedStateRequired: Bool
        public let captureCapReachedTrueIffCapturedByteCountEqualsCap: Bool
        public let captureCapReachedEstablishesAttemptedExcessBytes: Bool
        public let outerStreamOverflowOrTruncationEstablished: Bool
        public let orderedProjectionPrerequisites: [String]
        public let captureCleanupAttemptBounded: Bool
        public let captureCleanupBoundIsExactOperationTopology: Bool
        public let exactCaptureLeafUnlinkAttemptCount: Int
        public let exactCaptureRootRmdirAttemptCount: Int
        public let recursiveDeletionInvocationCount: Int
        public let wildcardCleanupPathCount: Int
        public let cleanupDirectoryScanInvocationCount: Int
        public let cleanupSuccessRequiredBeforeProjection: Bool
        public let exactCaptureCleanupAbsenceStates: [String]
        public let captureCleanupFailureResultCode: String
        public let captureCleanupFailureRequiresNonzeroLauncherExit: Bool
        public let captureSetupRefusalResultCode: String
        public let captureSetupRefusalEstablishesAdapterExecutionObservedFalse:
            Bool
        public let cleanupFailureOverridesPrimaryResultOnlyWhenPrimaryWasPass:
            Bool
        public let nonPassPrimaryResultPreservedWhenCleanupFails: Bool
        public let cleanupFailureStillRecordsObservedFalseAbsence: Bool
        public let exactSanitizedResultCodes: [String]
        public let unknownRawErrorResultCode: String
        public let rawErrorTextInterpolatedIntoProjection: Bool
        public let hostedRecordPrefix: String
        public let hostedRecordPrefixByteCount: Int
        public let hostedRecordSchemaID: String
        public let hostedRecordSchemaVersion: Int
        public let hostedRecordCanonicalJSONRequired: Bool
        public let hostedRecordExactLineCount: Int
        public let hostedRecordTerminalLFRequired: Bool
        public let hostedRecordTerminalLFByteCount: Int
        public let hostedRecordMaximumCanonicalJSONByteCount: Int
        public let hostedRecordMaximumTotalLineByteCount: Int
        public let hostedRecordOrderedFieldTypeContracts: [String]
        public let hostedRecordExactFieldCount: Int
        public let hostedRecordExecutableIdentityFieldsNullableForPreCommandRefusal:
            Bool
        public let commandAttemptRecordRequiresBothExecutableIdentities: Bool
        public let identityOrPinRefusalRecordsMeasuredIdentitiesWhenAvailable:
            Bool
        public let nonnullFixtureIdentityMustMatchLayerAAcceptancePin: Bool
        public let hostedRecordAuthorityID: String
        public let hostedRecordAuthorityCanonicalSHA256ValueSource: String
        public let hostedRecordExactRevisionValueSource: String
        public let hostedRecordExactRevisionMustBeLowercaseGitSHA: Bool
        public let hostedRecordOpportunityState: String
        public let hostedRecordScientificOutcome: String
        public let hostedRecordDurableEvidenceValue: Bool
        public let hostedRecordActionsArtifactValue: Bool
        public let hostedRecordRawChildOutputOrErrorFieldCount: Int
        public let exactSanitizedOperationalRecordCountWhenProjectionSucceeds:
            Int
        public let projectionIsOuterOperationalCompatibilityEvidenceOnly: Bool
        public let projectionIsLayerADiagnostic: Bool
        public let projectionIsScientificEvidence: Bool
        public let projectionIsDurableEvidence: Bool
        public let hostedCancellationOrTimeoutObservedOnlyFromActionsMetadata:
            Bool
        public let hostedOperationalRecordMayBeAbsentOnAbruptHostOrRunnerLoss:
            Bool
        public let hostedOperationalRecordMayBeAbsentOnActiveRootAdmissionRefusal:
            Bool
        public let hostedOperationalRecordMayBeAbsentOnPreLauncherReviewedJobFailure:
            Bool
        public let hostedOperationalRecordMayBeAbsentOnLauncherReachedProjectionFailure:
            Bool
        public let exactHostedOperationalRecordAbsenceStates: [String]
        public let absentHostedOperationalRecordCount: Int
        public let orderedLauncherNotReachedCauses: [String]
        public let launcherNotReachedEstablishesAdapterNotInvoked: Bool
        public let launcherNotReachedHostedOperationalRecordCount: Int
        public let launcherNotReachedAdapterCommandAttemptCount: Int
        public let launcherNotReachedEstablishesAdapterTerminalState: Bool
        public let launcherNotReachedEstablishesContainmentOrCleanup: Bool
        public let launcherNotReachedRetiresMechanicsOpportunity: Bool
        public let launcherNotReachedPermitsRetryOrRerun: Bool
        public let orderedLauncherReachedRecordAbsentCauses: [String]
        public let launcherTrapAttemptsUNCLASSIFIEDRecord: Bool
        public let launcherTrapRecordEmissionGuaranteed: Bool
        public let launcherReachedRecordAbsentEstablishesAdapterExecution:
            Bool
        public let launcherReachedRecordAbsentEstablishesAdapterTerminalState:
            Bool
        public let launcherReachedRecordAbsentEstablishesContainmentOrCleanup:
            Bool
        public let launcherReachedRecordAbsentRetiresMechanicsOpportunity: Bool
        public let launcherReachedRecordAbsentPermitsRetryOrRerun: Bool
        public let absentHostedRecordObservedOnlyFromActionsRunJobStepMetadataAndLogs:
            Bool
        public let activeRootAdmissionRefusalOccursBeforeReviewedJob: Bool
        public let activeRootAdmissionRefusalEstablishesAdapterInvocation: Bool
        public let activeRootAdmissionRefusalRetiresMechanicsOpportunity: Bool
        public let activeRootAdmissionRefusalPermitsRetryOrRerun: Bool
        public let preLauncherReviewedJobFailureEstablishesAdapterNotInvoked:
            Bool
        public let preLauncherReviewedJobFailureRetiresMechanicsOpportunity:
            Bool
        public let preLauncherReviewedJobFailurePermitsAutomaticRerun: Bool
        public let absentHostedRecordEstablishesAdapterTerminalState: Bool
        public let absentHostedRecordEstablishesFixtureOrProcessContainment: Bool
        public let absentHostedRecordEstablishesCaptureCleanupAbsence: Bool
        public let absentHostedRecordRetiresMechanicsOpportunity: Bool
        public let absentHostedRecordPermitsRetryOrRerun: Bool
        public let hostedCancellationOrTimeoutEstablishesContainment: Bool
        public let actionsArtifactCount: Int
    }

    public struct MechanicsSuccessor: Codable, Equatable, Sendable {
        public let orderedMechanicsSuccessorPaths: [String]
        public let orderedMechanicsSuccessorPathContracts:
            [MechanicsSuccessorPathContract]
        public let exactPathCount: Int
        public let modifiedExistingPathCount: Int
        public let addedLauncherPathCount: Int
        public let authorityMayBeginAfterExactMainClosure: Bool
        public let authorizedOnlyAfterThisAuthorityExactMainGreen: Bool
        public let currentAuthorityExecutesMechanics: Bool
        public let mainPushOnly: Bool
        public let existingReviewedJobFinalForegroundStep: Bool
        public let newHostedJobAuthorized: Bool
        public let workflowFilePath: String
        public let workflowName: String
        public let reviewedJobID: String
        public let reviewedJobNeedsActiveRootSuccess: Bool
        public let requiredGitHubEventName: String
        public let requiredGitHubRef: String
        public let requiredGitHubRepository: String
        public let requiredGitHubRunAttempt: Int
        public let githubSHAEqualsExactRevisionAndCheckoutHEADRequired: Bool
        public let exactRevisionMustBeLowercaseGitSHA: Bool
        public let mechanicsRevisionMustBeDirectSuccessorOfAuthorityClosure:
            Bool
        public let mechanicsFirstParentMustEqualAuthorityClosureRevision: Bool
        public let mechanicsFirstParentTreeMustEqualAuthorityClosureTree: Bool
        public let expectedMechanicsMergeParentCount: Int
        public let authorityClosureRevisionAvailability: String
        public let authorityClosureTreeAvailability: String
        public let exactThreeDeltaMustEqualOrderedSuccessorPaths: Bool
        public let gateAndLauncherRevalidateExactStatusModeMapping: Bool
        public let gateAndLauncherFreezeClosureRevisionAndTreeAfterMerge: Bool
        public let launcherRevalidatesDirectParentAndExactThreeDelta: Bool
        public let laterDistinctMainPushMustRefuseBeforeAdapterInvocation: Bool
        public let laterDistinctMainPushAdapterInvocationAuthorized: Bool
        public let observationAndRetirementMustBeNextAuthorizedChange: Bool
        public let deferredAuthorityExactMainGreenEvidence:
            DeferredAuthorityExactMainGreenEvidence
        public let cleanDetachedCheckoutRequiredImmediatelyBeforeLauncher: Bool
        public let reviewedCheckoutFetchDepth: Int
        public let concurrencyCancelInProgress: Bool
        public let launcherMustBeLiteralFinalWorkflowStep: Bool
        public let launcherContinueOnError: Bool
        public let invocationAdmissionMismatchResultCode: String
        public let invocationAdmissionMismatchEstablishesAdapterInvocation:
            Bool
        public let invocationAdmissionMismatchRetiresMechanicsOpportunity: Bool
        public let buildConfiguration: String
        public let requiredArchitecture: String
        public let requiredOperatingSystem: String
        public let validationPackagePath: String
        public let validationPackagePhysicalPath: String
        public let validationPackageMustBePhysicalDirectory: Bool
        public let validationPackageSymbolicLinkAuthorized: Bool
        public let orderedSwiftBuildProducts: [String]
        public let expectedSwiftBuildProductCommandCount: Int
        public let expectedSwiftShowBinPathCommandCount: Int
        public let expectedSwiftRunCommandCount: Int
        public let expectedSwiftTestCommandCount: Int
        public let expectedSwiftBuildTestsCommandCount: Int
        public let orderedSwiftPMCommandRoles: [String]
        public let exactSwiftPMCommandCount: Int
        public let orderedCommonSwiftPMArgumentTemplates: [String]
        public let orderedRequiredLocalMirrorOrigins: [String]
        public let orderedRequiredLocalBareMirrors: [LocalBareMirrorContract]
        public let expectedLocalBareMirrorCount: Int
        public let alreadyValidatedLocalBareMirrorsRequired: Bool
        public let sameReviewedJobLocalBareMirrorsRequired: Bool
        public let localBareMirrorsRevalidatedImmediatelyBeforeMappingsAndBuilds:
            Bool
        public let runnerTempMustBeCanonicalAbsolutePhysicalDirectory: Bool
        public let orderedFileURLInsteadOfMappings: [FileURLInsteadOfMapping]
        public let exactFileURLInsteadOfMappingCount: Int
        public let protocolFileAllowAlwaysRequired: Bool
        public let forceResolvedVersionsRequired: Bool
        public let mirrorMismatchRequiresAppendOnlyObservation: Bool
        public let mirrorMismatchRetiresMechanicsOpportunity: Bool
        public let mirrorMismatchEstablishesAdapterInvocation: Bool
        public let mirrorMismatchPermitsRetryWithoutNewAuthority: Bool
        public let orderedFreshPrivateSwiftPMRootRoles: [String]
        public let orderedFreshPrivateSwiftPMRootPaths: [String]
        public let freshPrivateSwiftPMRootCount: Int
        public let freshPrivateSwiftPMRootMode: String
        public let freshPrivateSwiftPMRootsMustNotPreexistOrBeSymbolicLinks: Bool
        public let freshPrivateSwiftPMRootsMustBeCanonicalPhysicalDirectories:
            Bool
        public let disableDependencyCacheRequired: Bool
        public let manifestCacheMode: String
        public let disableNetrcRequired: Bool
        public let disableKeychainRequired: Bool
        public let disableSandboxAuthorized: Bool
        public let isolationFlagsRequiredOnEveryBuildAndShowBinPathCommand: Bool
        public let fileURLMappingsRequiredOnEveryBuildAndShowBinPathCommand: Bool
        public let swiftPMTMPDIR: String
        public let canonicalBinPathMustBePhysicalDescendantOfScratchPath: Bool
        public let showBinPathExactOutputLineCount: Int
        public let orderedExpectedExecutableLeafNames: [String]
        public let exactExpectedExecutableLeafCount: Int
        public let expectedExecutableLeavesMustBeRegular: Bool
        public let expectedExecutableLeafSymbolicLinksAuthorized: Bool
        public let expectedExecutableLeafLinkCount: Int
        public let expectedExecutableLeavesMustBeExecutable: Bool
        public let bothExecutableDescriptorMetadataAndSHA256Bound: Bool
        public let bothExecutableIdentitiesRevalidatedImmediatelyBeforeCall:
            Bool
        public let launcherFinalStepAfterRetainedLiveTestCount: Int
        public let dependencyNetworkInvocationCountAfterReviewedFetch: Int
        public let directAdapterArgumentCountExcludingArgumentZero: Int
        public let directAdapterProcessArgumentCountIncludingArgumentZero: Int
        public let directAdapterOnlyArgumentRole: String
        public let adapterExecutableAbsolutePathRequired: Bool
        public let fixtureArgumentCanonicalAbsolutePathRequired: Bool
        public let callerControlledEnvironmentAuthorized: Bool
        public let callerControlledCommandAuthorized: Bool
        public let evalInvocationCount: Int
        public let arbitraryShellExecInvocationCount: Int
        public let requiredLayerAAcceptanceFixtureExecutableByteCount: Int
        public let requiredLayerAAcceptanceFixtureExecutableSHA256: String
        public let acceptancePinKernelSourcePath: String
        public let acceptancePinHistoricalDocumentation: SourceIdentity
        public let historicalDocumentationReportedDisjointAbsolutePathReleaseBuildCount:
            Int
        public let historicalDocumentationReportsReleaseBuildsByteIdentical:
            Bool
        public let historicalDocumentationReportedMachOUUID: String
        public let historicalBinaryRetained: Bool
        public let futureHostedBuildMatchObserved: Bool
        public let futureHostedBuildMeasuredByteCount: String
        public let futureHostedBuildMeasuredSHA256: String
        public let fixtureExecutableBuildOutputIdentityCapturedImmediatelyBeforeInvocation: Bool
        public let fixtureExecutableDescriptorNameAndInodeJoinRequired: Bool
        public let measuredBuildMustMatchExistingLayerAAcceptancePin: Bool
        public let pinMismatchRefusesBeforeOneShotConsumption: Bool
        public let reviewedJobEpochFilePath: String
        public let reviewedJobEpochCreatedInFirstWorkflowUserStepBeforeToolchain:
            Bool
        public let reviewedJobEpochRepresentsGitHubJobStartTimestamp: Bool
        public let reviewedJobEpochFileMustInitiallyNotExistOrBeSymbolicLink:
            Bool
        public let reviewedJobEpochFileCreatedExclusiveNoClobber: Bool
        public let reviewedJobEpochFileKernelImmutableClaimed: Bool
        public let reviewedJobEpochFileReadOnlyByPolicy: Bool
        public let reviewedJobEpochFileMustBeRegular: Bool
        public let reviewedJobEpochFileSymbolicLinkAuthorized: Bool
        public let reviewedJobEpochFileMode: String
        public let reviewedJobEpochFileLinkCount: Int
        public let reviewedJobEpochFileOwnerUIDAndGIDBound: Bool
        public let reviewedJobEpochContentGrammar: String
        public let reviewedJobEpochContentLineCount: Int
        public let reviewedJobEpochMustBePositive: Bool
        public let reviewedJobEpochLeadingZeroAuthorized: Bool
        public let reviewedJobEpochDescriptorIdentityBoundByLauncher: Bool
        public let reviewedJobEpochMetadataBoundByLauncher: Bool
        public let reviewedJobEpochSHA256BoundByLauncher: Bool
        public let reviewedJobEpochRevalidatedUnchangedImmediatelyBeforeOneShot:
            Bool
        public let reviewedJobEpochMustNotBeFutureAtRevalidation: Bool
        public let preInvocationElapsedUsesWallClockEpochDifference: Bool
        public let continuousThroughSystemSleepClaimed: Bool
        public let predecessorReviewedJobElapsedSeconds: Int
        public let predecessorRetainedLiveCompletionElapsedSeconds: Int
        public let priorJobCeilingSeconds: Int
        public let predecessorRemainingSecondsUnderPriorCeiling: Int
        public let priorPreInvocationCutoffSeconds: Int
        public let predecessorRemainingSecondsUnderPriorCutoff: Int
        public let exactLaneReleaseBuildDurationBoundObserved: Bool
        public let sameJobDebugOrCacheStateEstablishesReleaseBuildBound: Bool
        public let expectedJobCeilingSeconds: Int
        public let maximumPreInvocationElapsedSeconds: Int
        public let requiredRemainingJobReserveSeconds: Int
        public let expectedCapturePhaseCeilingSeconds: Int
        public let expectedDeadlineCleanupCount: Int
        public let expectedPerDeadlineCleanupCeilingSeconds: Int
        public let expectedCaptureAndDeadlineCleanupBudgetSeconds: Int
        public let capabilityPreparationHashFilesystemAndReadyBarrierIncludedInBudget:
            Bool
        public let concurrentReadyBarrierMaximumSeconds: Int
        public let wholeAdapterWallCeilingEstablished: Bool
        public let remainingJobReserveIsPracticalNonGuaranteedOuterEnvelope:
            Bool
        public let directForegroundInvocationRequired: Bool
        public let backgroundWatchdogAuthorized: Bool
        public let shellKillOrProcessScanAuthorized: Bool
        public let mechanicsOpportunityConsumedImmediatelyBeforeAdapterCommandAttempt:
            Bool
        public let preCommandRefusalConsumesAdapterCommandAttemptOneShot: Bool
        public let preCommandRefusalEstablishesAdapterExecution: Bool
        public let preCommandRefusalRetiresMechanicsOpportunity: Bool
        public let automaticRetryAfterPreInvocationFailureAuthorized: Bool
        public let everyPostCommandAttemptOutcomeConsumesMechanicsOpportunity:
            Bool
        public let workflowRerunAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateXTestCount: Int
        public let expectedEmbeddedProvenanceRecordCountWithLauncherPresent: Int
        public let embeddedProvenanceBytesMustRemainIdentical: Bool
        public let outerLauncherObservation: OuterLauncherObservationContract
    }

    public struct EphemeralFilesystemBoundary:
        Codable,
        Equatable,
        Sendable
    {
        public let laterMechanicsMayCreatePrivateTemporaryRoot: Bool
        public let laterMechanicsMayCreateFixtureWorkingAndResultDirectories: Bool
        public let laterMechanicsMayWriteFixtureResultAndCapturedPrefixFiles: Bool
        public let laterMechanicsMayCopyAndMutatePrivateFixtureExecutable: Bool
        public let replacementMutationExistsOnlyToProvePreSpawnRejection: Bool
        public let replacementExecutableMayRun: Bool
        public let successfulCanaryAttemptsCleanupBeforeReporting: Bool
        public let privateRootAbsenceEstablishedAsDurableEvidence: Bool
        public let fsyncUseEstablishesDurableEvidence: Bool
        public let localPersistenceAuthorizedBeyondInvocation: Bool
        public let actionsArtifactUploadAuthorized: Bool
        public let retentionAuthorized: Bool
    }

    public struct RetirementBoundary: Codable, Equatable, Sendable {
        public let disposition: String
        public let appendOnlyObservationRequiredAfterEveryInvocation: Bool
        public let successRequiresObservationAndRetirement: Bool
        public let failureRequiresObservationAndRetirement: Bool
        public let cancellationRequiresObservationAndRetirement: Bool
        public let setupOutcomeRequiresObservation: Bool
        public let setupOutcomeRetiresMechanicsOpportunity: Bool
        public let setupOutcomeEstablishesCanaryExecution: Bool
        public let setupOutcomePermitsRetryWithoutNewAuthority: Bool
        public let monitorOrHostLossEstablishesContainment: Bool
        public let automaticRetryAuthorized: Bool
        public let workflowRerunAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let oldStage7WatchdogRepairAuthorized: Bool
        public let orderedLaterBoundaries: [String]
    }

    public struct LanguageBoundary: Codable, Equatable, Sendable {
        public let currentCanaryLanguage: String
        public let pythonPermitted: Bool
        public let pythonInvocationCount: Int
        public let pythonSourcePathCount: Int
        public let cppNewImplementationInvocationCount: Int
        public let cppNewSourcePathCount: Int
        public let retainedBaselineCppDependencyCompilationMayOccur: Bool
        public let cppFullNativeAlternativeSeparatelyPermissibleLater: Bool
        public let cppSwiftCABIAlternativeSeparatelyPermissibleLater: Bool
        public let cppAlternativeAuthorizedNow: Bool
        public let cppAlternativeRequiresSeparateAuthority: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let designAuthorityEstablished: Bool
        public let implementationAuthorityEstablished: Bool
        public let layerAExactMainClosureEstablished: Bool
        public let closedFixtureCanaryAuthorityEstablished: Bool
        public let exactThreeMechanicsSuccessorAuthorizedAfterClosure: Bool
        public let processExecutionAuthorizedInThisAuthorityPR: Bool
        public let liveFixtureExecutionAuthorizedInThisAuthorityPR: Bool
        public let integrationAdapterExecutionAuthorizedInThisAuthorityPR: Bool
        public let publicGenericExecutableAuthorityAdded: Bool
        public let publicArbitraryArgumentAuthorityAdded: Bool
        public let publicArbitraryEnvironmentAuthorityAdded: Bool
        public let publicFixtureAPIWideningAuthorized: Bool
        public let layerAMutationAuthorized: Bool
        public let duplicateSpawnWaitSignalImplementationAuthorized: Bool
        public let customDescriptorTransportAuthorized: Bool
        public let hostedDiagnosticProjectionAuthorized: Bool
        public let hostedDiagnosticEmissionAuthorized: Bool
        public let filesystemWriteAuthorizedInThisAuthorityPR: Bool
        public let localEvidencePersistenceAuthorized: Bool
        public let fsyncDurableEvidenceEstablished: Bool
        public let actionsArtifactUploadAuthorized: Bool
        public let retentionAuthorized: Bool
        public let durableEvidenceEstablished: Bool
        public let durableTransactionImplementationAuthorized: Bool
        public let leaseAcquisitionAuthorized: Bool
        public let leaseReleaseOrReacquisitionAuthorized: Bool
        public let leaseDescriptorTransferAuthorized: Bool
        public let leaseOwnerDeathContinuityEstablished: Bool
        public let physicalMetalReservationEstablished: Bool
        public let mlxDeviceIdentityEstablished: Bool
        public let crossHostOrCrossJobLeaseContinuityEstablished: Bool
        public let watchdogRepairAuthorized: Bool
        public let oldLauncherMutationAuthorized: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let mlxAuthorized: Bool
        public let metalAuthorized: Bool
        public let native300MExecutionAuthorized: Bool
        public let scientificOutcomeEstablished: Bool
        public let checkpointAdmissionGranted: Bool
        public let stage8Authorized: Bool
        public let stage8AuthorityEstablished: Bool
        public let generalTrainingResumeAuthorized: Bool
        public let modelQualityEstablished: Bool
        public let candidateAdmissionAuthorized: Bool
        public let downstreamTrialAuthorized: Bool
        public let productUseAuthorized: Bool
        public let quantizationAuthorized: Bool
        public let publicationAuthorized: Bool
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let implementationAuthorityPredecessor:
        ImplementationAuthorityPredecessor
    public let layerAExactMainClosure: LayerAExactMainClosure
    public let authorityScaffold: AuthorityScaffold
    public let frozenLayerAInventory: FrozenLayerAInventory
    public let frozenValidationPayload: FrozenValidationPayload
    public let closedCanaryContract: ClosedCanaryContract
    public let mechanicsSuccessor: MechanicsSuccessor
    public let ephemeralFilesystemBoundary: EphemeralFilesystemBoundary
    public let retirementBoundary: RetirementBoundary
    public let languageBoundary: LanguageBoundary
    public let authorityCeiling: AuthorityCeiling
    public let status: String

    public static let canonicalByteCount = 48_364
    public static let canonicalSHA256 =
        "29cd7cb18001da845021bc60f8f250a920f927cdc302e5d5071e95f049c3351f"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_secure_child_process_evidence_closed_fixture_canary_authority_schema_v1",
        authorityID:
            "prime_secure_child_process_evidence_closed_fixture_canary_authority_v1",
        authorityKind:
            "pure_exact5_authority_for_one_later_closed_fixture_canary_after_green_layer_a",
        implementationAuthorityPredecessor: .init(
            authorityID:
                "prime_secure_child_process_evidence_implementation_authority_v1",
            canonicalByteCount: 18_370,
            canonicalSHA256:
                "43c29ff6e225219bfd13b642bd9ba2121aae9d2591bd1d1af3cf4d3bb41f08db",
            source: source(
                "Sources/PrimeCore/PrimeSecureChildProcessEvidenceImplementationAuthority.swift",
                "100644", "23ec89e31f24ccc11673f63242c0ebeefd5265b8",
                52_912, 1_081,
                "1f75f558231cfb7eead325148220d4a392f358e9c94d3cdb921149c821a657c1",
                "frozen_layer_a_implementation_authority_source"),
            test: source(
                "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceImplementationAuthorityTests.swift",
                "100644", "36ec5d012a4d3c1a751d722e9d4cfd0d43cc7b42",
                26_756, 614,
                "47a290effef7c4512150f4fee1220dba96cd94f599783e01a0c5f1263c524a3f",
                "frozen_layer_a_implementation_authority_test"),
            implementationAuthorityEstablished: true,
            implementationPatchAuthorizedByPredecessor: true,
            liveCanaryAuthorizedByPredecessor: false,
            separateCanaryAuthorityRequired: true),
        layerAExactMainClosure: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            mergeRevision:
                "232a17e8f58a297919366d963ee1d7bc38cdbaee",
            mergeTree:
                "c2a351449824ec15bc3154158d10f28c8a8310ad",
            orderedParents: [
                "a4d8583fa7c59f885002ee06a07c1d5264c0c223",
                "960c705028f56d5bd4522f354632f3f14c869647",
            ],
            pullRequestNumber: 120,
            pullRequestBaseRevision:
                "a4d8583fa7c59f885002ee06a07c1d5264c0c223",
            pullRequestHeadRevision:
                "960c705028f56d5bd4522f354632f3f14c869647",
            signedMergeVerified: true,
            mergeTimestampUTC: "2026-08-16T06:21:51Z",
            signatureVerifiedAtUTC: "2026-08-16T06:21:52Z",
            workflowRunID: 31_931_241_261,
            workflowRunNumber: 138,
            workflowAttempt: 1,
            checkSuiteID: 86_594_321_030,
            event: "push",
            previousAttemptURLIsNull: true,
            workflowRerunCount: 0,
            workflowConclusion: "success",
            workflowCreatedAtUTC: "2026-08-16T06:21:53Z",
            workflowStartedAtUTC: "2026-08-16T06:21:53Z",
            workflowUpdatedAtUTC: "2026-08-16T07:17:50Z",
            activeJobID: 95_126_300_172,
            activeJobConclusion: "success",
            activeRunnerLabel: "macos-15",
            activeJobStartedAtUTC: "2026-08-16T06:21:57Z",
            activeJobCompletedAtUTC: "2026-08-16T06:26:24Z",
            activeLatinTestCount: 116,
            activeLatinFailureCount: 0,
            reviewedJobID: 95_126_735_634,
            reviewedJobConclusion: "success",
            reviewedRunnerLabel: "macos-26",
            reviewedJobStartedAtUTC: "2026-08-16T06:26:27Z",
            reviewedJobCompletedAtUTC: "2026-08-16T07:17:49Z",
            focusedTestsStartedAtUTC: "2026-08-16T06:26:43Z",
            focusedTestsCompletedAtUTC: "2026-08-16T06:57:03Z",
            retainedLiveTestsStartedAtUTC: "2026-08-16T06:57:03Z",
            retainedLiveTestsCompletedAtUTC: "2026-08-16T07:17:40Z",
            rootTestCount: 77,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 83,
            retainedMetalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            tokenizerTestCount: 1,
            retainedLiveTestCount: 46,
            aggregateTestCount: 129,
            reviewedFailureCount: 0,
            reviewedSkipCount: 0,
            layerATestMethodStartCount: 12,
            layerATestMethodPassCount: 12,
            actionsArtifactCount: 0,
            stage7JobCount: 0,
            stage7LauncherInvocationCount: 0,
            stage7ExecutableInvocationCount: 0,
            stage7ReceiptCount: 0,
            closedCanaryLauncherInvocationCount: 0,
            integrationAdapterInvocationCount: 0,
            capabilityPreparationCount: 0,
            capabilityExecuteCallCount: 0,
            successfulTopLevelCaptureCount: 0,
            physicalFixtureProcessCount: 0,
            leaseAcquisitionInvocationCount: 0,
            pythonInterpreterInvocationCount: 0,
            newCppImplementationInvocationCount: 0,
            actionsArtifactUploadCount: 0,
            embeddedSourceIdentitySHA256:
                "f9362d044dcac6120950be43d7e1a22094b38795dff456f0e81e698a91614b49",
            exactMainClosureEstablished: true),
        authorityScaffold: .init(
            exactOrderedChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthority.swift",
                "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityTests.swift",
            ],
            exactPathCount: 5,
            preservedIndexSHA256:
                "e8dd30060ea370f01e135f8c2e379ab2d9bb6138dca9d928c395cdd9f967f291",
            activeLatinTestCount: 116,
            rootTestCount: 78,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 84,
            retainedLiveTestCount: 46,
            aggregateTestCount: 130,
            embeddedProvenanceRecordCount: 507,
            authorityTestMethodCount: 1,
            processMechanicsInvocationCount: 0,
            fixtureInvocationCount: 0,
            leaseInvocationCount: 0,
            hostedDiagnosticEmissionCount: 0,
            filesystemMutationCount: 0,
            networkInvocationCount: 0,
            onlyExactFivePathsAuthorized: true),
        frozenLayerAInventory: .init(
            orderedSourceIdentities: layerAIdentities,
            exactIdentityCount: 11,
            exactInternalTypeNames: [
                "PrimeSecureChildProcessPlanV1",
                "PrimeSecureChildProcessEvidenceV1",
                "PrimeTrustedSecureChildProcessCapture",
                "PrimeSecureChildExecutionKernel",
                "PrimeSecureChildDiagnosticEnvelopeV1",
                "PrimeSecureChildDiagnosticProjection",
                "PrimeSecureChildLeaseRetention",
            ],
            exactInternalTypeCount: 7,
            exactInjectedTestMethodCount: 12,
            publicFixtureModeCount: 9,
            publicFixtureAPISpellingsPreserved: true,
            newTypesRemainInternal: true,
            trustedCaptureExactlyOneShot: true,
            exactPIDReapRequired: true,
            processGroupEmptyRequired: true,
            terminalClosedDrainsRequired: true,
            fixtureSuccessRequiresCleanEOFAndZeroErrors: true,
            typedUnavailableDistinctFromObservedFalse: true,
            capturedPrefixDistinctFromFullStreamDigest: true,
            diagnosticMaximumCanonicalByteCount: 4_096,
            diagnosticConstructionOnlyAfterContainment: true,
            diagnosticEmissionAuthorized: false,
            leaseSeamOnlyRetainsExternallyOwnedOpaqueCapability: true,
            leaseSeamAcquiresOrTransfersCapability: false,
            layerAMutationAuthorizedByThisAuthority: false),
        frozenValidationPayload: .init(
            packageManifest: source(
                "Tests/PrimeValidationWorkflow/Package.swift",
                "100644", "fe98104c7e812d0c44ee1e38dcc10857455bf54f",
                2_587, 88,
                "99354cfc3da2d75ac960d1c704257656eec563bc17344d694678626ae9c1f518",
                "frozen_validation_package_manifest"),
            packageResolved: source(
                "Tests/PrimeValidationWorkflow/Package.resolved",
                "100644", "69919288b1a5da256ff408a4d65106b23abc8f89",
                645, 23,
                "d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a",
                "frozen_validation_package_lock"),
            fixtureChildSource: source(
                "Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowFixtureChild/PrimeValidationWorkflowFixtureChild.swift",
                "100644", "5e45832ed046da7bfd4541ad362018fad97371f5",
                19_353, 614,
                "f016793fb012c9dc70a47b5ea0ba325f582d1e7c0c5a84b303855cc8543eb274",
                "frozen_closed_nine_mode_fixture_source"),
            integrationSource: source(
                "Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowSecureChildIntegration/PrimeValidationWorkflowSecureChildIntegration.swift",
                "100644", "cce94e857f770f8108d7a694675ca75386a40ddb",
                17_656, 537,
                "9404187780e89137686d036c6909c675608c8ebd3ca8077cafd5bb002debf5c2",
                "frozen_closed_fixture_integration_adapter_source"),
            fixtureProductName: "PrimeValidationWorkflowFixtureChild",
            integrationProductName:
                "PrimeValidationWorkflowSecureChildIntegration",
            orderedProducts: [
                "PrimeValidationWorkflowFixtureChild",
                "PrimeValidationWorkflowSecureChildIntegration",
            ],
            payloadSourceMutationAuthorized: false,
            packageManifestMutationAuthorized: false,
            packageResolvedMutationAuthorized: false,
            newSwiftPMTargetAuthorized: false,
            arbitraryExecutableAdapterAuthorized: false),
        closedCanaryContract: .init(
            orderedModeContracts: modeContracts,
            exactModeCount: 9,
            dynamicByteCountSentinel: -1,
            descendantDynamicOutput: .init(
                mode: "descendant-retains-streams",
                standardOutputPrefix: "spawned_descendant_pid=",
                standardOutputTerminator: "\n",
                exactLineCount: 1,
                suffixEncoding: "canonical_positive_base10_int32",
                suffixDigitsOnly: true,
                suffixLeadingZeroAllowed: false,
                suffixPlusSignAllowed: false,
                suffixMinusSignAllowed: false,
                minimumSuffixValue: 1,
                maximumSuffixValue: 2_147_483_647,
                minimumTotalByteCount: 25,
                maximumTotalByteCount: 34,
                capturedByteCountEqualsTotalByteCount: true,
                fixedTotalByteCountAvailable: false,
                fixedCapturedByteCountAvailable: false,
                overflowExpected: false,
                fixedStreamSHA256Available: false,
                resultPIDMatchesOutputPIDAndMembershipPID: true),
            expectedLauncherInvocationCount: 1,
            expectedIntegrationAdapterInvocationCount: 1,
            expectedCapabilityPreparationCount: 11,
            expectedCapabilityExecuteCallCount: 13,
            expectedSuccessfulTopLevelCaptureCount: 10,
            expectedTopLevelFixtureProcessCount: 10,
            expectedPhysicalFixtureProcessCount: 11,
            expectedInternalDescendantProcessCount: 1,
            expectedRejectedExecuteCallCount: 3,
            expectedPreSpawnReplacementRejectionCount: 1,
            expectedSequentialAlreadyConsumedRejectionCount: 1,
            expectedConcurrentWinnerCount: 1,
            expectedConcurrentAlreadyConsumedRejectionCount: 1,
            allRejectedExecuteCallsSpawnNoProcess: true,
            everySuccessfulReturnRequiresModeRoundTrip: true,
            everySuccessfulReturnRequiresFixtureContract: true,
            everySuccessfulReturnRequiresSessionAndGroupEqualPID: true,
            everySuccessfulReturnRequiresDescriptorBackedJoins: true,
            everySuccessfulReturnRequiresExactPIDReap: true,
            everySuccessfulReturnRequiresEmptyProcessGroup: true,
            everySuccessfulReturnRequiresTerminalClosedDrains: true,
            everySuccessfulReturnRequiresCleanEOFAndZeroErrors: true,
            typedLayerAEvidenceValidatedInternally: true,
            diagnosticConstructedOnlyAfterContainment: true,
            diagnosticEmittedByCanary: false,
            expectedSuccessStandardOutput:
                "prime-validation secure-child integration: PASS modes=9 logical_argv0=PASS one_shot=PASS executable_replacement=REJECTED\n",
            expectedSuccessStandardOutputByteCount: 121,
            expectedSuccessStandardOutputLineCount: 1,
            expectedSuccessStandardOutputSHA256:
                "933bf087c8b15408aef9aaca1447dfbc07c9685ca0fda451d9db7fda4c1198af",
            expectedSuccessStandardErrorByteCount: 0,
            expectedSuccessExitStatus: 0,
            outputIsOperationalCompatibilityEvidenceOnly: true,
            outputIsScientificEvidence: false,
            outputIsDurableEvidence: false),
        mechanicsSuccessor: .init(
            orderedMechanicsSuccessorPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
            ],
            orderedMechanicsSuccessorPathContracts: [
                .init(
                    path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                    gitStatus: "M",
                    gitMode: "100755"),
                .init(
                    path: ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
                    gitStatus: "A",
                    gitMode: "100755"),
                .init(
                    path: ".github/workflows/prime-active-root-quarantine.yml",
                    gitStatus: "M",
                    gitMode: "100644"),
            ],
            exactPathCount: 3,
            modifiedExistingPathCount: 2,
            addedLauncherPathCount: 1,
            authorityMayBeginAfterExactMainClosure: true,
            authorizedOnlyAfterThisAuthorityExactMainGreen: true,
            currentAuthorityExecutesMechanics: false,
            mainPushOnly: true,
            existingReviewedJobFinalForegroundStep: true,
            newHostedJobAuthorized: false,
            workflowFilePath:
                ".github/workflows/prime-active-root-quarantine.yml",
            workflowName: "Prime active-root quarantine",
            reviewedJobID: "trusted-main-compile",
            reviewedJobNeedsActiveRootSuccess: true,
            requiredGitHubEventName: "push",
            requiredGitHubRef: "refs/heads/main",
            requiredGitHubRepository: "Ergentics/ergentics-prime",
            requiredGitHubRunAttempt: 1,
            githubSHAEqualsExactRevisionAndCheckoutHEADRequired: true,
            exactRevisionMustBeLowercaseGitSHA: true,
            mechanicsRevisionMustBeDirectSuccessorOfAuthorityClosure: true,
            mechanicsFirstParentMustEqualAuthorityClosureRevision: true,
            mechanicsFirstParentTreeMustEqualAuthorityClosureTree: true,
            expectedMechanicsMergeParentCount: 2,
            authorityClosureRevisionAvailability:
                "unavailable_until_this_authority_exact_main_merge",
            authorityClosureTreeAvailability:
                "unavailable_until_this_authority_exact_main_merge",
            exactThreeDeltaMustEqualOrderedSuccessorPaths: true,
            gateAndLauncherRevalidateExactStatusModeMapping: true,
            gateAndLauncherFreezeClosureRevisionAndTreeAfterMerge: true,
            launcherRevalidatesDirectParentAndExactThreeDelta: true,
            laterDistinctMainPushMustRefuseBeforeAdapterInvocation: true,
            laterDistinctMainPushAdapterInvocationAuthorized: false,
            observationAndRetirementMustBeNextAuthorizedChange: true,
            deferredAuthorityExactMainGreenEvidence: .init(
                evidenceAvailability:
                    "unavailable_until_this_authority_exact_main_green_closure",
                signedAuthorityClosureRequired: true,
                exactAuthorityClosureRevisionAndTreeRequired: true,
                uniquePushWorkflowRunCount: 1,
                exactWorkflowRunIDRequired: true,
                exactWorkflowRunNumberRequired: true,
                exactCheckSuiteIDRequired: true,
                requiredWorkflowAttempt: 1,
                previousAttemptURLMustBeNull: true,
                workflowRerunCount: 0,
                requiredWorkflowConclusion: "success",
                exactActiveJobIDRequired: true,
                requiredActiveJobConclusion: "success",
                expectedActiveLatinTestCount: 116,
                expectedActiveLatinFailureCount: 0,
                exactReviewedJobIDRequired: true,
                requiredReviewedJobConclusion: "success",
                expectedRootTestCount: 78,
                expectedIsolatedTestCount: 6,
                expectedFocusedWholeTestCount: 84,
                expectedRetainedLiveTestCount: 46,
                expectedAggregateTestCount: 130,
                expectedReviewedFailureCount: 0,
                expectedReviewedSkipCount: 0,
                expectedActionsArtifactCount: 0,
                gateAndWorkflowFreezeExactValuesBeforeMechanics: true,
                launcherClosureEvidenceAPIInvocationCount: 0,
                launcherClosureEvidenceNetworkInvocationCount: 0),
            cleanDetachedCheckoutRequiredImmediatelyBeforeLauncher: true,
            reviewedCheckoutFetchDepth: 2,
            concurrencyCancelInProgress: false,
            launcherMustBeLiteralFinalWorkflowStep: true,
            launcherContinueOnError: false,
            invocationAdmissionMismatchResultCode:
                "INVOCATION_ADMISSION_REFUSED",
            invocationAdmissionMismatchEstablishesAdapterInvocation: false,
            invocationAdmissionMismatchRetiresMechanicsOpportunity: true,
            buildConfiguration: "release",
            requiredArchitecture: "arm64",
            requiredOperatingSystem: "macos_26",
            validationPackagePath: "Tests/PrimeValidationWorkflow",
            validationPackagePhysicalPath:
                "$GITHUB_WORKSPACE/ergentics-prime/Tests/PrimeValidationWorkflow",
            validationPackageMustBePhysicalDirectory: true,
            validationPackageSymbolicLinkAuthorized: false,
            orderedSwiftBuildProducts: [
                "PrimeValidationWorkflowFixtureChild",
                "PrimeValidationWorkflowSecureChildIntegration",
            ],
            expectedSwiftBuildProductCommandCount: 2,
            expectedSwiftShowBinPathCommandCount: 1,
            expectedSwiftRunCommandCount: 0,
            expectedSwiftTestCommandCount: 0,
            expectedSwiftBuildTestsCommandCount: 0,
            orderedSwiftPMCommandRoles: [
                "release_build_PrimeValidationWorkflowFixtureChild",
                "release_build_PrimeValidationWorkflowSecureChildIntegration",
                "release_show_bin_path_without_product_build",
            ],
            exactSwiftPMCommandCount: 3,
            orderedCommonSwiftPMArgumentTemplates: [
                "--package-path Tests/PrimeValidationWorkflow",
                "--configuration release",
                "--scratch-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-scratch",
                "--cache-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-cache",
                "--config-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-config",
                "--security-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-security",
                "--disable-dependency-cache",
                "--manifest-cache local",
                "--disable-netrc",
                "--disable-keychain",
                "--force-resolved-versions",
            ],
            orderedRequiredLocalMirrorOrigins: [
                "https://github.com/Ergentics/ergentics-mlx-swift",
                "https://github.com/apple/swift-numerics",
            ],
            orderedRequiredLocalBareMirrors: [
                .init(
                    dependencyIdentity: "ergentics_mlx_swift",
                    runnerTempPath:
                        "$RUNNER_TEMP/ergentics-mlx-swift.git",
                    fileURL:
                        "file://$RUNNER_TEMP/ergentics-mlx-swift.git/",
                    exactOriginURL:
                        "https://github.com/Ergentics/ergentics-mlx-swift",
                    exactCommitSHA:
                        "d37885a278f1c37484a94d0f401a418735e66519",
                    typedCommitExpression:
                        "d37885a278f1c37484a94d0f401a418735e66519^{commit}",
                    pinnedRefExpression:
                        "refs/heads/prime-pinned^{commit}",
                    pathMustExistAsDirectory: true,
                    symbolicLinkAuthorized: false,
                    physicalPathMustEqualExpandedRunnerTempPath: true,
                    absoluteGitDirectoryMustEqualPhysicalPath: true,
                    bareRepositoryRequired: true,
                    soleRemoteName: "origin",
                    exactOriginURLValueCount: 1,
                    revisionObjectType: "commit",
                    typedCommitMustResolveToExactCommit: true,
                    pinnedRefMustResolveToExactCommit: true),
                .init(
                    dependencyIdentity: "swift_numerics",
                    runnerTempPath:
                        "$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c",
                    fileURL:
                        "file://$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c/",
                    exactOriginURL:
                        "https://github.com/apple/swift-numerics",
                    exactCommitSHA:
                        "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
                    typedCommitExpression:
                        "0c0290ff6b24942dadb83a929ffaaa1481df04a2^{commit}",
                    pinnedRefExpression: "refs/tags/1.1.1^{commit}",
                    pathMustExistAsDirectory: true,
                    symbolicLinkAuthorized: false,
                    physicalPathMustEqualExpandedRunnerTempPath: true,
                    absoluteGitDirectoryMustEqualPhysicalPath: true,
                    bareRepositoryRequired: true,
                    soleRemoteName: "origin",
                    exactOriginURLValueCount: 1,
                    revisionObjectType: "commit",
                    typedCommitMustResolveToExactCommit: true,
                    pinnedRefMustResolveToExactCommit: true),
            ],
            expectedLocalBareMirrorCount: 2,
            alreadyValidatedLocalBareMirrorsRequired: true,
            sameReviewedJobLocalBareMirrorsRequired: true,
            localBareMirrorsRevalidatedImmediatelyBeforeMappingsAndBuilds:
                true,
            runnerTempMustBeCanonicalAbsolutePhysicalDirectory: true,
            orderedFileURLInsteadOfMappings: [
                .init(
                    localFileURL:
                        "file://$RUNNER_TEMP/ergentics-mlx-swift.git/",
                    remoteURL:
                        "https://github.com/Ergentics/ergentics-mlx-swift"),
                .init(
                    localFileURL:
                        "file://$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c/",
                    remoteURL:
                        "https://github.com/apple/swift-numerics"),
            ],
            exactFileURLInsteadOfMappingCount: 2,
            protocolFileAllowAlwaysRequired: true,
            forceResolvedVersionsRequired: true,
            mirrorMismatchRequiresAppendOnlyObservation: true,
            mirrorMismatchRetiresMechanicsOpportunity: true,
            mirrorMismatchEstablishesAdapterInvocation: false,
            mirrorMismatchPermitsRetryWithoutNewAuthority: false,
            orderedFreshPrivateSwiftPMRootRoles: [
                "scratch", "cache", "config", "security",
            ],
            orderedFreshPrivateSwiftPMRootPaths: [
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-scratch",
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-cache",
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-config",
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-security",
            ],
            freshPrivateSwiftPMRootCount: 4,
            freshPrivateSwiftPMRootMode: "0700",
            freshPrivateSwiftPMRootsMustNotPreexistOrBeSymbolicLinks: true,
            freshPrivateSwiftPMRootsMustBeCanonicalPhysicalDirectories: true,
            disableDependencyCacheRequired: true,
            manifestCacheMode: "local",
            disableNetrcRequired: true,
            disableKeychainRequired: true,
            disableSandboxAuthorized: false,
            isolationFlagsRequiredOnEveryBuildAndShowBinPathCommand: true,
            fileURLMappingsRequiredOnEveryBuildAndShowBinPathCommand: true,
            swiftPMTMPDIR: "$RUNNER_TEMP",
            canonicalBinPathMustBePhysicalDescendantOfScratchPath: true,
            showBinPathExactOutputLineCount: 1,
            orderedExpectedExecutableLeafNames: [
                "PrimeValidationWorkflowFixtureChild",
                "PrimeValidationWorkflowSecureChildIntegration",
            ],
            exactExpectedExecutableLeafCount: 2,
            expectedExecutableLeavesMustBeRegular: true,
            expectedExecutableLeafSymbolicLinksAuthorized: false,
            expectedExecutableLeafLinkCount: 1,
            expectedExecutableLeavesMustBeExecutable: true,
            bothExecutableDescriptorMetadataAndSHA256Bound: true,
            bothExecutableIdentitiesRevalidatedImmediatelyBeforeCall: true,
            launcherFinalStepAfterRetainedLiveTestCount: 46,
            dependencyNetworkInvocationCountAfterReviewedFetch: 0,
            directAdapterArgumentCountExcludingArgumentZero: 1,
            directAdapterProcessArgumentCountIncludingArgumentZero: 2,
            directAdapterOnlyArgumentRole:
                "canonical_absolute_path_to_measured_fixture_matching_existing_layer_a_pin",
            adapterExecutableAbsolutePathRequired: true,
            fixtureArgumentCanonicalAbsolutePathRequired: true,
            callerControlledEnvironmentAuthorized: false,
            callerControlledCommandAuthorized: false,
            evalInvocationCount: 0,
            arbitraryShellExecInvocationCount: 0,
            requiredLayerAAcceptanceFixtureExecutableByteCount: 89_632,
            requiredLayerAAcceptanceFixtureExecutableSHA256:
                "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd",
            acceptancePinKernelSourcePath:
                "Sources/PrimeCore/PrimeSecureChildKernel.swift",
            acceptancePinHistoricalDocumentation: source(
                "docs/PRIME-SWIFT-VALIDATION-DRIVER-V2-FOUNDATION-2026-08-02.md",
                "100644", "f37e4c90281b689927bd777e14d61bb139c7108b",
                13_615, 245,
                "6bd51d4446ea31f0f819e7f8aa522f3c6af5f6a075b9a34869cceb652bc6ef8b",
                "historical_two_build_fixture_binary_pin_provenance"),
            historicalDocumentationReportedDisjointAbsolutePathReleaseBuildCount:
                2,
            historicalDocumentationReportsReleaseBuildsByteIdentical: true,
            historicalDocumentationReportedMachOUUID:
                "6ABE4B24-C019-3372-8144-C85CCEE5BA19",
            historicalBinaryRetained: false,
            futureHostedBuildMatchObserved: false,
            futureHostedBuildMeasuredByteCount:
                "unavailable_until_exact_mechanics_lane_build",
            futureHostedBuildMeasuredSHA256:
                "unavailable_until_exact_mechanics_lane_build",
            fixtureExecutableBuildOutputIdentityCapturedImmediatelyBeforeInvocation:
                true,
            fixtureExecutableDescriptorNameAndInodeJoinRequired: true,
            measuredBuildMustMatchExistingLayerAAcceptancePin: true,
            pinMismatchRefusesBeforeOneShotConsumption: true,
            reviewedJobEpochFilePath:
                "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-reviewed-job-epoch",
            reviewedJobEpochCreatedInFirstWorkflowUserStepBeforeToolchain:
                true,
            reviewedJobEpochRepresentsGitHubJobStartTimestamp: false,
            reviewedJobEpochFileMustInitiallyNotExistOrBeSymbolicLink: true,
            reviewedJobEpochFileCreatedExclusiveNoClobber: true,
            reviewedJobEpochFileKernelImmutableClaimed: false,
            reviewedJobEpochFileReadOnlyByPolicy: true,
            reviewedJobEpochFileMustBeRegular: true,
            reviewedJobEpochFileSymbolicLinkAuthorized: false,
            reviewedJobEpochFileMode: "0400",
            reviewedJobEpochFileLinkCount: 1,
            reviewedJobEpochFileOwnerUIDAndGIDBound: true,
            reviewedJobEpochContentGrammar:
                "canonical_positive_base10_unix_epoch_seconds_lf",
            reviewedJobEpochContentLineCount: 1,
            reviewedJobEpochMustBePositive: true,
            reviewedJobEpochLeadingZeroAuthorized: false,
            reviewedJobEpochDescriptorIdentityBoundByLauncher: true,
            reviewedJobEpochMetadataBoundByLauncher: true,
            reviewedJobEpochSHA256BoundByLauncher: true,
            reviewedJobEpochRevalidatedUnchangedImmediatelyBeforeOneShot:
                true,
            reviewedJobEpochMustNotBeFutureAtRevalidation: true,
            preInvocationElapsedUsesWallClockEpochDifference: true,
            continuousThroughSystemSleepClaimed: false,
            predecessorReviewedJobElapsedSeconds: 3_082,
            predecessorRetainedLiveCompletionElapsedSeconds: 3_073,
            priorJobCeilingSeconds: 3_600,
            predecessorRemainingSecondsUnderPriorCeiling: 527,
            priorPreInvocationCutoffSeconds: 3_300,
            predecessorRemainingSecondsUnderPriorCutoff: 227,
            exactLaneReleaseBuildDurationBoundObserved: false,
            sameJobDebugOrCacheStateEstablishesReleaseBuildBound: false,
            expectedJobCeilingSeconds: 4_500,
            maximumPreInvocationElapsedSeconds: 4_200,
            requiredRemainingJobReserveSeconds: 300,
            expectedCapturePhaseCeilingSeconds: 82,
            expectedDeadlineCleanupCount: 2,
            expectedPerDeadlineCleanupCeilingSeconds: 9,
            expectedCaptureAndDeadlineCleanupBudgetSeconds: 100,
            capabilityPreparationHashFilesystemAndReadyBarrierIncludedInBudget:
                false,
            concurrentReadyBarrierMaximumSeconds: 3,
            wholeAdapterWallCeilingEstablished: false,
            remainingJobReserveIsPracticalNonGuaranteedOuterEnvelope: true,
            directForegroundInvocationRequired: true,
            backgroundWatchdogAuthorized: false,
            shellKillOrProcessScanAuthorized: false,
            mechanicsOpportunityConsumedImmediatelyBeforeAdapterCommandAttempt:
                true,
            preCommandRefusalConsumesAdapterCommandAttemptOneShot: false,
            preCommandRefusalEstablishesAdapterExecution: false,
            preCommandRefusalRetiresMechanicsOpportunity: true,
            automaticRetryAfterPreInvocationFailureAuthorized: false,
            everyPostCommandAttemptOutcomeConsumesMechanicsOpportunity: true,
            workflowRerunAuthorized: false,
            replacementExecutionAuthorized: false,
            expectedRootTestCount: 78,
            expectedIsolatedTestCount: 6,
            expectedFocusedWholeTestCount: 84,
            expectedRetainedLiveTestCount: 46,
            expectedAggregateXTestCount: 130,
            expectedEmbeddedProvenanceRecordCountWithLauncherPresent: 507,
            embeddedProvenanceBytesMustRemainIdentical: true,
            outerLauncherObservation: .init(
                privateCaptureRootPath:
                    "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-outer-capture",
                privateCaptureRootMustInitiallyNotExistOrBeSymbolicLink: true,
                privateCaptureRootCreatedByExactPathMkdirWithoutParents: true,
                privateCaptureRootMode: "0700",
                privateCaptureRootMustBePhysicalDirectory: true,
                privateCaptureRootSymbolicLinkAuthorized: false,
                orderedCaptureStreamNames: ["standard_output", "standard_error"],
                orderedFixedCaptureLeafNames: [
                    "standard-output.capture", "standard-error.capture",
                ],
                fixedCaptureLeavesPrecreatedBeforeInvocation: true,
                captureFileMode: "0600",
                captureFilesMustBeRegular: true,
                captureFileSymbolicLinksAuthorized: false,
                captureFileLinkCount: 1,
                perStreamCaptureByteCap: 131_072,
                bash1024ByteFileSizeLimitBlockCount: 128,
                layerACapturedPrefixByteCap: 65_536,
                outerCaptureCapDistinctFromLayerACapturedPrefixCap: true,
                rawStreamBytesForwarded: false,
                rawStreamBytesIncludedInSummary: false,
                rawStreamBytesUploadedAsArtifact: false,
                exactAdapterCommandStates: [
                    "not_attempted", "shell_command_returned",
                ],
                exactAdapterExecutionObservationStates: [
                    "observed_true", "observed_false", "unavailable",
                ],
                shellWaitStatusObservationRequiredAfterSynchronousReturn:
                    true,
                shellWaitStatusAloneEstablishesAdapterExecution: false,
                exactRecognizedAdapterEnvelopesMayEstablishExecution: true,
                preCommandRefusalEstablishesAdapterExecutionObservedFalse:
                    true,
                noReportOrUnexpectedReportEstablishesAdapterExecution: false,
                nativeWaiterUsed: false,
                exactExitVersusSignalClassificationEstablished: false,
                shellWaitStatusType: "null_or_uint8",
                shellWaitStatusMinimum: 0,
                shellWaitStatusMaximum: 255,
                shellWaitStatusZeroRequiresExpectedOutputContractForPass: true,
                shellWaitStatusNonzeroUsesClosedDiagnosticClassification:
                    true,
                adapterReportedFailureAllowedShellStatuses: [1, 2],
                adapterReportedFailureStandardErrorPrefix:
                    "prime-validation secure-child integration: FAIL ",
                adapterReportedFailureStandardErrorPrefixByteCount: 48,
                layerAFailStopReportedShellStatus: 70,
                layerAFailStopStandardErrorPrefix:
                    "prime-secure-child fail-stop: ",
                layerAFailStopStandardErrorPrefixByteCount: 30,
                reportedFailureRequiresExactlyOneTerminalLF: true,
                reportedFailureRequiresEmptyStandardOutput: true,
                reportedFailureAllowsAdditionalLine: false,
                reportedFailureAllowsCaptureCapReached: false,
                adapterNoReportRequiresEmptyStandardOutput: true,
                adapterNoReportRequiresEmptyStandardError: true,
                unmatchedNonzeroReportResultCode:
                    "ADAPTER_UNEXPECTED_REPORT",
                statusZeroWrongOutputContractResultCode:
                    "ADAPTER_OUTPUT_CONTRACT_MISMATCH",
                diagnosticClassifierUsesOnlyFixedByteOperations: true,
                notAttemptedRequiresZeroCapturedByteCounts: true,
                notAttemptedRequiredEmptyStreamSHA256:
                    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                notAttemptedRequiresCaptureCapNotReached: true,
                perStreamCapturedByteCountRequired: true,
                perStreamSHA256Required: true,
                perStreamCaptureCapReachedStateRequired: true,
                captureCapReachedTrueIffCapturedByteCountEqualsCap: true,
                captureCapReachedEstablishesAttemptedExcessBytes: false,
                outerStreamOverflowOrTruncationEstablished: false,
                orderedProjectionPrerequisites: [
                    "adapter_command_not_attempted_or_synchronous_shell_command_return_and_status",
                    "both_stream_counts_hashes_and_capture_cap_reached_states_captured",
                    "bounded_capture_cleanup_attempt_completed",
                ],
                captureCleanupAttemptBounded: true,
                captureCleanupBoundIsExactOperationTopology: true,
                exactCaptureLeafUnlinkAttemptCount: 2,
                exactCaptureRootRmdirAttemptCount: 1,
                recursiveDeletionInvocationCount: 0,
                wildcardCleanupPathCount: 0,
                cleanupDirectoryScanInvocationCount: 0,
                cleanupSuccessRequiredBeforeProjection: false,
                exactCaptureCleanupAbsenceStates: [
                    "observed_true", "observed_false", "unavailable",
                ],
                captureCleanupFailureResultCode: "CAPTURE_CLEANUP_FAILED",
                captureCleanupFailureRequiresNonzeroLauncherExit: true,
                captureSetupRefusalResultCode: "CAPTURE_SETUP_REFUSED",
                captureSetupRefusalEstablishesAdapterExecutionObservedFalse:
                    true,
                cleanupFailureOverridesPrimaryResultOnlyWhenPrimaryWasPass:
                    true,
                nonPassPrimaryResultPreservedWhenCleanupFails: true,
                cleanupFailureStillRecordsObservedFalseAbsence: true,
                exactSanitizedResultCodes: [
                    "PASS",
                    "INVOCATION_ADMISSION_REFUSED",
                    "EPOCH_REFUSED",
                    "PREINVOCATION_CUTOFF",
                    "PLATFORM_REFUSED",
                    "MIRROR_REFUSED",
                    "SWIFTPM_ROOT_REFUSED",
                    "ADAPTER_IDENTITY_REFUSED",
                    "BUILD_REFUSED",
                    "PIN_MISMATCH",
                    "CAPTURE_SETUP_REFUSED",
                    "ADAPTER_REPORTED_FAILURE",
                    "LAYER_A_FAIL_STOP_REPORTED",
                    "ADAPTER_NO_REPORT",
                    "ADAPTER_UNEXPECTED_REPORT",
                    "ADAPTER_OUTPUT_CONTRACT_MISMATCH",
                    "CAPTURE_CAP_REACHED",
                    "CAPTURE_CLEANUP_FAILED",
                    "UNCLASSIFIED",
                ],
                unknownRawErrorResultCode: "UNCLASSIFIED",
                rawErrorTextInterpolatedIntoProjection: false,
                hostedRecordPrefix:
                    "prime-secure-child closed-fixture-canary observation: ",
                hostedRecordPrefixByteCount: 54,
                hostedRecordSchemaID:
                    "prime_secure_child_process_evidence_closed_fixture_canary_outer_observation_v1",
                hostedRecordSchemaVersion: 1,
                hostedRecordCanonicalJSONRequired: true,
                hostedRecordExactLineCount: 1,
                hostedRecordTerminalLFRequired: true,
                hostedRecordTerminalLFByteCount: 1,
                hostedRecordMaximumCanonicalJSONByteCount: 4_041,
                hostedRecordMaximumTotalLineByteCount: 4_096,
                hostedRecordOrderedFieldTypeContracts: [
                    "actions_artifact:bool",
                    "adapter_command_attempt_one_shot_consumed:bool",
                    "adapter_command_state:enum_not_attempted_shell_command_returned",
                    "adapter_execution_observation:enum_observed_true_observed_false_unavailable",
                    "adapter_executable_byte_count:null_or_positive_int",
                    "adapter_executable_sha256:null_or_lowercase_hex_64",
                    "authority_canonical_sha256:lowercase_hex_64",
                    "authority_id:utf8_exact",
                    "capture_cleanup_absence:enum_observed_true_observed_false_unavailable",
                    "durable_evidence:bool",
                    "exact_revision:lowercase_git_sha_40",
                    "fixture_executable_byte_count:null_or_positive_int",
                    "fixture_executable_sha256:null_or_lowercase_hex_64",
                    "opportunity_state:enum_retired",
                    "result_code:closed_enum",
                    "schema_id:utf8_exact",
                    "schema_version:positive_int",
                    "scientific_outcome:enum_not_established",
                    "shell_wait_status:null_or_uint8",
                    "standard_error_byte_cap:positive_int",
                    "standard_error_captured_byte_count:nonnegative_int",
                    "standard_error_capture_cap_reached:bool",
                    "standard_error_sha256:lowercase_hex_64",
                    "standard_output_byte_cap:positive_int",
                    "standard_output_captured_byte_count:nonnegative_int",
                    "standard_output_capture_cap_reached:bool",
                    "standard_output_sha256:lowercase_hex_64",
                ],
                hostedRecordExactFieldCount: 27,
                hostedRecordExecutableIdentityFieldsNullableForPreCommandRefusal:
                    true,
                commandAttemptRecordRequiresBothExecutableIdentities: true,
                identityOrPinRefusalRecordsMeasuredIdentitiesWhenAvailable:
                    true,
                nonnullFixtureIdentityMustMatchLayerAAcceptancePin: true,
                hostedRecordAuthorityID:
                    "prime_secure_child_process_evidence_closed_fixture_canary_authority_v1",
                hostedRecordAuthorityCanonicalSHA256ValueSource:
                    "PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1.canonicalSHA256",
                hostedRecordExactRevisionValueSource:
                    "GITHUB_SHA_of_exact3_mechanics_main_push",
                hostedRecordExactRevisionMustBeLowercaseGitSHA: true,
                hostedRecordOpportunityState: "retired",
                hostedRecordScientificOutcome: "not_established",
                hostedRecordDurableEvidenceValue: false,
                hostedRecordActionsArtifactValue: false,
                hostedRecordRawChildOutputOrErrorFieldCount: 0,
                exactSanitizedOperationalRecordCountWhenProjectionSucceeds:
                    1,
                projectionIsOuterOperationalCompatibilityEvidenceOnly: true,
                projectionIsLayerADiagnostic: false,
                projectionIsScientificEvidence: false,
                projectionIsDurableEvidence: false,
                hostedCancellationOrTimeoutObservedOnlyFromActionsMetadata:
                    true,
                hostedOperationalRecordMayBeAbsentOnAbruptHostOrRunnerLoss:
                    true,
                hostedOperationalRecordMayBeAbsentOnActiveRootAdmissionRefusal:
                    true,
                hostedOperationalRecordMayBeAbsentOnPreLauncherReviewedJobFailure:
                    true,
                hostedOperationalRecordMayBeAbsentOnLauncherReachedProjectionFailure:
                    true,
                exactHostedOperationalRecordAbsenceStates: [
                    "launcher_not_reached",
                    "launcher_reached_record_absent",
                    "abrupt_host_or_runner_loss",
                ],
                absentHostedOperationalRecordCount: 0,
                orderedLauncherNotReachedCauses: [
                    "active_root_gate_failure_or_later_push_admission_refusal",
                    "reviewed_toolchain_failure",
                    "reviewed_checkout_failure",
                    "reviewed_private_dependency_fetch_failure",
                    "reviewed_focused_contract_failure",
                    "reviewed_retained_live_failure",
                ],
                launcherNotReachedEstablishesAdapterNotInvoked: true,
                launcherNotReachedHostedOperationalRecordCount: 0,
                launcherNotReachedAdapterCommandAttemptCount: 0,
                launcherNotReachedEstablishesAdapterTerminalState: false,
                launcherNotReachedEstablishesContainmentOrCleanup: false,
                launcherNotReachedRetiresMechanicsOpportunity: true,
                launcherNotReachedPermitsRetryOrRerun: false,
                orderedLauncherReachedRecordAbsentCauses: [
                    "ordinary_shell_failure",
                    "hash_failure",
                    "stat_failure",
                    "canonical_json_projection_failure",
                    "trap_projection_failure",
                ],
                launcherTrapAttemptsUNCLASSIFIEDRecord: true,
                launcherTrapRecordEmissionGuaranteed: false,
                launcherReachedRecordAbsentEstablishesAdapterExecution: false,
                launcherReachedRecordAbsentEstablishesAdapterTerminalState:
                    false,
                launcherReachedRecordAbsentEstablishesContainmentOrCleanup:
                    false,
                launcherReachedRecordAbsentRetiresMechanicsOpportunity: true,
                launcherReachedRecordAbsentPermitsRetryOrRerun: false,
                absentHostedRecordObservedOnlyFromActionsRunJobStepMetadataAndLogs:
                    true,
                activeRootAdmissionRefusalOccursBeforeReviewedJob: true,
                activeRootAdmissionRefusalEstablishesAdapterInvocation: false,
                activeRootAdmissionRefusalRetiresMechanicsOpportunity: true,
                activeRootAdmissionRefusalPermitsRetryOrRerun: false,
                preLauncherReviewedJobFailureEstablishesAdapterNotInvoked:
                    true,
                preLauncherReviewedJobFailureRetiresMechanicsOpportunity:
                    true,
                preLauncherReviewedJobFailurePermitsAutomaticRerun: false,
                absentHostedRecordEstablishesAdapterTerminalState: false,
                absentHostedRecordEstablishesFixtureOrProcessContainment: false,
                absentHostedRecordEstablishesCaptureCleanupAbsence: false,
                absentHostedRecordRetiresMechanicsOpportunity: true,
                absentHostedRecordPermitsRetryOrRerun: false,
                hostedCancellationOrTimeoutEstablishesContainment: false,
                actionsArtifactCount: 0)),
        ephemeralFilesystemBoundary: .init(
            laterMechanicsMayCreatePrivateTemporaryRoot: true,
            laterMechanicsMayCreateFixtureWorkingAndResultDirectories: true,
            laterMechanicsMayWriteFixtureResultAndCapturedPrefixFiles: true,
            laterMechanicsMayCopyAndMutatePrivateFixtureExecutable: true,
            replacementMutationExistsOnlyToProvePreSpawnRejection: true,
            replacementExecutableMayRun: false,
            successfulCanaryAttemptsCleanupBeforeReporting: true,
            privateRootAbsenceEstablishedAsDurableEvidence: false,
            fsyncUseEstablishesDurableEvidence: false,
            localPersistenceAuthorizedBeyondInvocation: false,
            actionsArtifactUploadAuthorized: false,
            retentionAuthorized: false),
        retirementBoundary: .init(
            disposition: "observe_once_then_retire",
            appendOnlyObservationRequiredAfterEveryInvocation: true,
            successRequiresObservationAndRetirement: true,
            failureRequiresObservationAndRetirement: true,
            cancellationRequiresObservationAndRetirement: true,
            setupOutcomeRequiresObservation: true,
            setupOutcomeRetiresMechanicsOpportunity: true,
            setupOutcomeEstablishesCanaryExecution: false,
            setupOutcomePermitsRetryWithoutNewAuthority: false,
            monitorOrHostLossEstablishesContainment: false,
            automaticRetryAuthorized: false,
            workflowRerunAuthorized: false,
            replacementExecutionAuthorized: false,
            oldStage7WatchdogRepairAuthorized: false,
            orderedLaterBoundaries: [
                "merge_and_close_this_pure_exact5_canary_authority",
                "merge_only_the_exact3_closed_fixture_canary_mechanics_successor",
                "consume_at_most_one_adapter_invocation_without_retry_or_rerun",
                "append_only_observe_and_retire_every_invoked_terminal_outcome",
                "separately_authorize_neutral_resource_lease_generalization",
                "separately_authorize_durable_transaction_layer_b",
                "separately_authorize_lease_containment_durability_composition",
                "only_then_review_any_mlx_metal_native300_or_cpp_adapter",
            ]),
        languageBoundary: .init(
            currentCanaryLanguage:
                "swift_existing_prime_darwin_secure_child_substrate",
            pythonPermitted: false,
            pythonInvocationCount: 0,
            pythonSourcePathCount: 0,
            cppNewImplementationInvocationCount: 0,
            cppNewSourcePathCount: 0,
            retainedBaselineCppDependencyCompilationMayOccur: true,
            cppFullNativeAlternativeSeparatelyPermissibleLater: true,
            cppSwiftCABIAlternativeSeparatelyPermissibleLater: true,
            cppAlternativeAuthorizedNow: false,
            cppAlternativeRequiresSeparateAuthority: true),
        authorityCeiling: .init(
            designAuthorityEstablished: true,
            implementationAuthorityEstablished: true,
            layerAExactMainClosureEstablished: true,
            closedFixtureCanaryAuthorityEstablished: true,
            exactThreeMechanicsSuccessorAuthorizedAfterClosure: true,
            processExecutionAuthorizedInThisAuthorityPR: false,
            liveFixtureExecutionAuthorizedInThisAuthorityPR: false,
            integrationAdapterExecutionAuthorizedInThisAuthorityPR: false,
            publicGenericExecutableAuthorityAdded: false,
            publicArbitraryArgumentAuthorityAdded: false,
            publicArbitraryEnvironmentAuthorityAdded: false,
            publicFixtureAPIWideningAuthorized: false,
            layerAMutationAuthorized: false,
            duplicateSpawnWaitSignalImplementationAuthorized: false,
            customDescriptorTransportAuthorized: false,
            hostedDiagnosticProjectionAuthorized: false,
            hostedDiagnosticEmissionAuthorized: false,
            filesystemWriteAuthorizedInThisAuthorityPR: false,
            localEvidencePersistenceAuthorized: false,
            fsyncDurableEvidenceEstablished: false,
            actionsArtifactUploadAuthorized: false,
            retentionAuthorized: false,
            durableEvidenceEstablished: false,
            durableTransactionImplementationAuthorized: false,
            leaseAcquisitionAuthorized: false,
            leaseReleaseOrReacquisitionAuthorized: false,
            leaseDescriptorTransferAuthorized: false,
            leaseOwnerDeathContinuityEstablished: false,
            physicalMetalReservationEstablished: false,
            mlxDeviceIdentityEstablished: false,
            crossHostOrCrossJobLeaseContinuityEstablished: false,
            watchdogRepairAuthorized: false,
            oldLauncherMutationAuthorized: false,
            retryAuthorized: false,
            rerunAuthorized: false,
            replacementExecutionAuthorized: false,
            mlxAuthorized: false,
            metalAuthorized: false,
            native300MExecutionAuthorized: false,
            scientificOutcomeEstablished: false,
            checkpointAdmissionGranted: false,
            stage8Authorized: false,
            stage8AuthorityEstablished: false,
            generalTrainingResumeAuthorized: false,
            modelQualityEstablished: false,
            candidateAdmissionAuthorized: false,
            downstreamTrialAuthorized: false,
            productUseAuthorized: false,
            quantizationAuthorized: false,
            publicationAuthorized: false),
        status:
            "AUTHORITY_ONLY_closed_nine_mode_fixture_canary_exact5_no_live_execution_exact3_successor_then_observe_and_retire_no_python_no_current_cpp")

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityError
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
            PrimeSecureChildProcessEvidenceImplementationAuthorityV1.frozenV1
        do {
            try predecessor.validateExactV1()
        } catch {
            throw PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityError
                .contractDrift
        }

        let closure = layerAExactMainClosure
        let scaffold = authorityScaffold
        let layerA = frozenLayerAInventory
        let payload = frozenValidationPayload
        let canary = closedCanaryContract
        let mechanics = mechanicsSuccessor
        let deferredClosure = mechanics.deferredAuthorityExactMainGreenEvidence
        let outer = mechanics.outerLauncherObservation
        let filesystem = ephemeralFilesystemBoundary
        let retirement = retirementBoundary
        let language = languageBoundary
        let ceiling = authorityCeiling
        let canonical = try canonicalData()
        let modes = canary.orderedModeContracts
        let descendantOutput = canary.descendantDynamicOutput
        let falseClaims = [
            ceiling.processExecutionAuthorizedInThisAuthorityPR,
            ceiling.liveFixtureExecutionAuthorizedInThisAuthorityPR,
            ceiling.integrationAdapterExecutionAuthorizedInThisAuthorityPR,
            ceiling.publicGenericExecutableAuthorityAdded,
            ceiling.publicArbitraryArgumentAuthorityAdded,
            ceiling.publicArbitraryEnvironmentAuthorityAdded,
            ceiling.publicFixtureAPIWideningAuthorized,
            ceiling.layerAMutationAuthorized,
            ceiling.duplicateSpawnWaitSignalImplementationAuthorized,
            ceiling.customDescriptorTransportAuthorized,
            ceiling.hostedDiagnosticProjectionAuthorized,
            ceiling.hostedDiagnosticEmissionAuthorized,
            ceiling.filesystemWriteAuthorizedInThisAuthorityPR,
            ceiling.localEvidencePersistenceAuthorized,
            ceiling.fsyncDurableEvidenceEstablished,
            ceiling.actionsArtifactUploadAuthorized,
            ceiling.retentionAuthorized,
            ceiling.durableEvidenceEstablished,
            ceiling.durableTransactionImplementationAuthorized,
            ceiling.leaseAcquisitionAuthorized,
            ceiling.leaseReleaseOrReacquisitionAuthorized,
            ceiling.leaseDescriptorTransferAuthorized,
            ceiling.leaseOwnerDeathContinuityEstablished,
            ceiling.physicalMetalReservationEstablished,
            ceiling.mlxDeviceIdentityEstablished,
            ceiling.crossHostOrCrossJobLeaseContinuityEstablished,
            ceiling.watchdogRepairAuthorized,
            ceiling.oldLauncherMutationAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.replacementExecutionAuthorized,
            ceiling.mlxAuthorized,
            ceiling.metalAuthorized,
            ceiling.native300MExecutionAuthorized,
            ceiling.scientificOutcomeEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.stage8Authorized,
            ceiling.stage8AuthorityEstablished,
            ceiling.generalTrainingResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionAuthorized,
            ceiling.downstreamTrialAuthorized,
            ceiling.productUseAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.publicationAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              implementationAuthorityPredecessor.authorityID
                == predecessor.authorityID,
              implementationAuthorityPredecessor.canonicalByteCount
                == type(of: predecessor).canonicalByteCount,
              implementationAuthorityPredecessor.canonicalSHA256
                == type(of: predecessor).canonicalSHA256,
              implementationAuthorityPredecessor
                .implementationAuthorityEstablished,
              implementationAuthorityPredecessor
                .implementationPatchAuthorizedByPredecessor,
              !implementationAuthorityPredecessor
                .liveCanaryAuthorizedByPredecessor,
              implementationAuthorityPredecessor
                .separateCanaryAuthorityRequired,
              closure.repository == "Ergentics/ergentics-prime",
              closure.ref == "refs/heads/main",
              closure.orderedParents.count == 2,
              closure.pullRequestNumber == 120,
              closure.signedMergeVerified,
              closure.workflowRunNumber == 138,
              closure.workflowAttempt == 1,
              closure.event == "push",
              closure.previousAttemptURLIsNull,
              closure.workflowRerunCount == 0,
              closure.workflowConclusion == "success",
              closure.activeLatinTestCount == 116,
              closure.activeLatinFailureCount == 0,
              closure.rootTestCount == 77,
              closure.isolatedGroupTestCounts == [1, 1, 2, 2],
              closure.isolatedTestCount
                == closure.isolatedGroupTestCounts.reduce(0, +),
              closure.focusedWholeTestCount
                == closure.rootTestCount + closure.isolatedTestCount,
              closure.retainedLiveTestCount
                == closure.retainedMetalTestCount
                    + closure.maintainedRuntimeTestCount
                    + closure.tokenizerTestCount,
              closure.aggregateTestCount
                == closure.focusedWholeTestCount
                    + closure.retainedLiveTestCount,
              closure.reviewedFailureCount == 0,
              closure.reviewedSkipCount == 0,
              closure.layerATestMethodStartCount == 12,
              closure.layerATestMethodPassCount == 12,
              closure.actionsArtifactCount == 0,
              closure.stage7JobCount == 0,
              closure.stage7LauncherInvocationCount == 0,
              closure.stage7ExecutableInvocationCount == 0,
              closure.stage7ReceiptCount == 0,
              closure.closedCanaryLauncherInvocationCount == 0,
              closure.integrationAdapterInvocationCount == 0,
              closure.capabilityPreparationCount == 0,
              closure.capabilityExecuteCallCount == 0,
              closure.successfulTopLevelCaptureCount == 0,
              closure.physicalFixtureProcessCount == 0,
              closure.leaseAcquisitionInvocationCount == 0,
              closure.pythonInterpreterInvocationCount == 0,
              closure.newCppImplementationInvocationCount == 0,
              closure.actionsArtifactUploadCount == 0,
              closure.embeddedSourceIdentitySHA256.count == 64,
              closure.exactMainClosureEstablished,
              scaffold.exactPathCount == 5,
              scaffold.exactOrderedChangedPaths.count == 5,
              Set(scaffold.exactOrderedChangedPaths).count == 5,
              scaffold.preservedIndexSHA256.count == 64,
              scaffold.rootTestCount == 78,
              scaffold.isolatedGroupTestCounts == [1, 1, 2, 2],
              scaffold.isolatedTestCount == 6,
              scaffold.focusedWholeTestCount
                == scaffold.rootTestCount + scaffold.isolatedTestCount,
              scaffold.aggregateTestCount
                == scaffold.focusedWholeTestCount
                    + scaffold.retainedLiveTestCount,
              scaffold.embeddedProvenanceRecordCount == 507,
              scaffold.authorityTestMethodCount == 1,
              scaffold.processMechanicsInvocationCount == 0,
              scaffold.fixtureInvocationCount == 0,
              scaffold.leaseInvocationCount == 0,
              scaffold.hostedDiagnosticEmissionCount == 0,
              scaffold.filesystemMutationCount == 0,
              scaffold.networkInvocationCount == 0,
              scaffold.onlyExactFivePathsAuthorized,
              layerA.exactIdentityCount == 11,
              layerA.orderedSourceIdentities.count == 11,
              Set(layerA.orderedSourceIdentities.map(\.path)).count == 11,
              layerA.orderedSourceIdentities.allSatisfy(Self.validSource),
              layerA.exactInternalTypeCount == 7,
              layerA.exactInternalTypeNames.count == 7,
              Set(layerA.exactInternalTypeNames).count == 7,
              layerA.exactInjectedTestMethodCount == 12,
              layerA.publicFixtureModeCount == 9,
              layerA.publicFixtureAPISpellingsPreserved,
              layerA.newTypesRemainInternal,
              layerA.trustedCaptureExactlyOneShot,
              layerA.exactPIDReapRequired,
              layerA.processGroupEmptyRequired,
              layerA.terminalClosedDrainsRequired,
              layerA.fixtureSuccessRequiresCleanEOFAndZeroErrors,
              layerA.typedUnavailableDistinctFromObservedFalse,
              layerA.capturedPrefixDistinctFromFullStreamDigest,
              layerA.diagnosticMaximumCanonicalByteCount == 4_096,
              layerA.diagnosticConstructionOnlyAfterContainment,
              !layerA.diagnosticEmissionAuthorized,
              layerA.leaseSeamOnlyRetainsExternallyOwnedOpaqueCapability,
              !layerA.leaseSeamAcquiresOrTransfersCapability,
              !layerA.layerAMutationAuthorizedByThisAuthority,
              Self.validSource(payload.packageManifest),
              Self.validSource(payload.packageResolved),
              Self.validSource(payload.fixtureChildSource),
              Self.validSource(payload.integrationSource),
              payload.orderedProducts.count == 2,
              !payload.payloadSourceMutationAuthorized,
              !payload.packageManifestMutationAuthorized,
              !payload.packageResolvedMutationAuthorized,
              !payload.newSwiftPMTargetAuthorized,
              !payload.arbitraryExecutableAdapterAuthorized,
              canary.exactModeCount == 9,
              modes.count == 9,
              canary.dynamicByteCountSentinel == -1,
              modes == Self.modeContracts,
              modes.map(\.ordinal) == Array(1 ... 9),
              Set(modes.map(\.mode)).count == 9,
              modes.map(\.expectedTopLevelCaptureCount).reduce(0, +)
                == canary.expectedSuccessfulTopLevelCaptureCount,
              modes[7].expectedStandardOutputTotalByteCount
                == canary.dynamicByteCountSentinel,
              modes[7].expectedStandardOutputCapturedByteCount
                == canary.dynamicByteCountSentinel,
              modes[7].expectedStandardErrorTotalByteCount == 0,
              modes[7].expectedStandardErrorCapturedByteCount == 0,
              !modes[7].standardOutputOverflowExpected,
              !modes[7].standardErrorOverflowExpected,
              descendantOutput.mode == modes[7].mode,
              descendantOutput.standardOutputPrefix
                == "spawned_descendant_pid=",
              Data(descendantOutput.standardOutputPrefix.utf8).count == 23,
              descendantOutput.standardOutputTerminator == "\n",
              descendantOutput.exactLineCount == 1,
              descendantOutput.suffixEncoding
                == "canonical_positive_base10_int32",
              descendantOutput.suffixDigitsOnly,
              !descendantOutput.suffixLeadingZeroAllowed,
              !descendantOutput.suffixPlusSignAllowed,
              !descendantOutput.suffixMinusSignAllowed,
              descendantOutput.minimumSuffixValue == 1,
              descendantOutput.maximumSuffixValue == Int(Int32.max),
              descendantOutput.minimumTotalByteCount == 25,
              descendantOutput.maximumTotalByteCount == 34,
              descendantOutput.capturedByteCountEqualsTotalByteCount,
              !descendantOutput.fixedTotalByteCountAvailable,
              !descendantOutput.fixedCapturedByteCountAvailable,
              !descendantOutput.overflowExpected,
              !descendantOutput.fixedStreamSHA256Available,
              descendantOutput.resultPIDMatchesOutputPIDAndMembershipPID,
              modes.map({
                  Int($0.maximumWallNanoseconds / 1_000_000_000)
                    * $0.expectedTopLevelCaptureCount
              }).reduce(0, +)
                == mechanics.expectedCapturePhaseCeilingSeconds,
              canary.expectedLauncherInvocationCount == 1,
              canary.expectedIntegrationAdapterInvocationCount == 1,
              canary.expectedCapabilityPreparationCount == 11,
              canary.expectedCapabilityExecuteCallCount == 13,
              canary.expectedSuccessfulTopLevelCaptureCount == 10,
              canary.expectedTopLevelFixtureProcessCount == 10,
              canary.expectedPhysicalFixtureProcessCount
                == canary.expectedTopLevelFixtureProcessCount
                    + canary.expectedInternalDescendantProcessCount,
              canary.expectedPhysicalFixtureProcessCount == 11,
              canary.expectedInternalDescendantProcessCount == 1,
              canary.expectedRejectedExecuteCallCount == 3,
              canary.expectedPreSpawnReplacementRejectionCount == 1,
              canary.expectedSequentialAlreadyConsumedRejectionCount == 1,
              canary.expectedConcurrentWinnerCount == 1,
              canary.expectedConcurrentAlreadyConsumedRejectionCount == 1,
              canary.allRejectedExecuteCallsSpawnNoProcess,
              canary.everySuccessfulReturnRequiresModeRoundTrip,
              canary.everySuccessfulReturnRequiresFixtureContract,
              canary.everySuccessfulReturnRequiresSessionAndGroupEqualPID,
              canary.everySuccessfulReturnRequiresDescriptorBackedJoins,
              canary.everySuccessfulReturnRequiresExactPIDReap,
              canary.everySuccessfulReturnRequiresEmptyProcessGroup,
              canary.everySuccessfulReturnRequiresTerminalClosedDrains,
              canary.everySuccessfulReturnRequiresCleanEOFAndZeroErrors,
              canary.typedLayerAEvidenceValidatedInternally,
              canary.diagnosticConstructedOnlyAfterContainment,
              !canary.diagnosticEmittedByCanary,
              Data(canary.expectedSuccessStandardOutput.utf8).count
                == canary.expectedSuccessStandardOutputByteCount,
              canary.expectedSuccessStandardOutputLineCount == 1,
              canary.expectedSuccessStandardOutput.hasSuffix("\n"),
              PrimeSHA256.hexDigest(
                  of: Data(canary.expectedSuccessStandardOutput.utf8))
                == canary.expectedSuccessStandardOutputSHA256,
              canary.expectedSuccessStandardErrorByteCount == 0,
              canary.expectedSuccessExitStatus == 0,
              canary.outputIsOperationalCompatibilityEvidenceOnly,
              !canary.outputIsScientificEvidence,
              !canary.outputIsDurableEvidence,
              mechanics.exactPathCount == 3,
              mechanics.orderedMechanicsSuccessorPaths.count == 3,
              Set(mechanics.orderedMechanicsSuccessorPaths).count == 3,
              mechanics.orderedMechanicsSuccessorPathContracts
                == [
                    .init(
                        path:
                            ".github/scripts/prime-ci-active-root-quarantine.sh",
                        gitStatus: "M",
                        gitMode: "100755"),
                    .init(
                        path:
                            ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
                        gitStatus: "A",
                        gitMode: "100755"),
                    .init(
                        path:
                            ".github/workflows/prime-active-root-quarantine.yml",
                        gitStatus: "M",
                        gitMode: "100644"),
                ],
              mechanics.orderedMechanicsSuccessorPathContracts.map(\.path)
                == mechanics.orderedMechanicsSuccessorPaths,
              mechanics.modifiedExistingPathCount == 2,
              mechanics.addedLauncherPathCount == 1,
              mechanics.authorityMayBeginAfterExactMainClosure,
              mechanics.authorizedOnlyAfterThisAuthorityExactMainGreen,
              !mechanics.currentAuthorityExecutesMechanics,
              mechanics.mainPushOnly,
              mechanics.existingReviewedJobFinalForegroundStep,
              !mechanics.newHostedJobAuthorized,
              mechanics.workflowFilePath
                == ".github/workflows/prime-active-root-quarantine.yml",
              mechanics.workflowName == "Prime active-root quarantine",
              mechanics.reviewedJobID == "trusted-main-compile",
              mechanics.reviewedJobNeedsActiveRootSuccess,
              mechanics.requiredGitHubEventName == "push",
              mechanics.requiredGitHubRef == "refs/heads/main",
              mechanics.requiredGitHubRepository
                == "Ergentics/ergentics-prime",
              mechanics.requiredGitHubRunAttempt == 1,
              mechanics.githubSHAEqualsExactRevisionAndCheckoutHEADRequired,
              mechanics.exactRevisionMustBeLowercaseGitSHA,
              mechanics
                .mechanicsRevisionMustBeDirectSuccessorOfAuthorityClosure,
              mechanics
                .mechanicsFirstParentMustEqualAuthorityClosureRevision,
              mechanics.mechanicsFirstParentTreeMustEqualAuthorityClosureTree,
              mechanics.expectedMechanicsMergeParentCount == 2,
              mechanics.authorityClosureRevisionAvailability
                == "unavailable_until_this_authority_exact_main_merge",
              mechanics.authorityClosureTreeAvailability
                == "unavailable_until_this_authority_exact_main_merge",
              mechanics.exactThreeDeltaMustEqualOrderedSuccessorPaths,
              mechanics.gateAndLauncherRevalidateExactStatusModeMapping,
              mechanics
                .gateAndLauncherFreezeClosureRevisionAndTreeAfterMerge,
              mechanics.launcherRevalidatesDirectParentAndExactThreeDelta,
              mechanics.laterDistinctMainPushMustRefuseBeforeAdapterInvocation,
              !mechanics.laterDistinctMainPushAdapterInvocationAuthorized,
              mechanics.observationAndRetirementMustBeNextAuthorizedChange,
              deferredClosure.evidenceAvailability
                == "unavailable_until_this_authority_exact_main_green_closure",
              deferredClosure.signedAuthorityClosureRequired,
              deferredClosure.exactAuthorityClosureRevisionAndTreeRequired,
              deferredClosure.uniquePushWorkflowRunCount == 1,
              deferredClosure.exactWorkflowRunIDRequired,
              deferredClosure.exactWorkflowRunNumberRequired,
              deferredClosure.exactCheckSuiteIDRequired,
              deferredClosure.requiredWorkflowAttempt == 1,
              deferredClosure.previousAttemptURLMustBeNull,
              deferredClosure.workflowRerunCount == 0,
              deferredClosure.requiredWorkflowConclusion == "success",
              deferredClosure.exactActiveJobIDRequired,
              deferredClosure.requiredActiveJobConclusion == "success",
              deferredClosure.expectedActiveLatinTestCount == 116,
              deferredClosure.expectedActiveLatinFailureCount == 0,
              deferredClosure.exactReviewedJobIDRequired,
              deferredClosure.requiredReviewedJobConclusion == "success",
              deferredClosure.expectedRootTestCount == 78,
              deferredClosure.expectedIsolatedTestCount == 6,
              deferredClosure.expectedFocusedWholeTestCount == 84,
              deferredClosure.expectedRetainedLiveTestCount == 46,
              deferredClosure.expectedAggregateTestCount == 130,
              deferredClosure.expectedReviewedFailureCount == 0,
              deferredClosure.expectedReviewedSkipCount == 0,
              deferredClosure.expectedActionsArtifactCount == 0,
              deferredClosure
                .gateAndWorkflowFreezeExactValuesBeforeMechanics,
              deferredClosure.launcherClosureEvidenceAPIInvocationCount == 0,
              deferredClosure.launcherClosureEvidenceNetworkInvocationCount
                == 0,
              mechanics.cleanDetachedCheckoutRequiredImmediatelyBeforeLauncher,
              mechanics.reviewedCheckoutFetchDepth == 2,
              !mechanics.concurrencyCancelInProgress,
              mechanics.launcherMustBeLiteralFinalWorkflowStep,
              !mechanics.launcherContinueOnError,
              mechanics.invocationAdmissionMismatchResultCode
                == "INVOCATION_ADMISSION_REFUSED",
              !mechanics
                .invocationAdmissionMismatchEstablishesAdapterInvocation,
              mechanics
                .invocationAdmissionMismatchRetiresMechanicsOpportunity,
              mechanics.buildConfiguration == "release",
              mechanics.requiredArchitecture == "arm64",
              mechanics.requiredOperatingSystem == "macos_26",
              mechanics.validationPackagePath == "Tests/PrimeValidationWorkflow",
              mechanics.validationPackagePhysicalPath
                == "$GITHUB_WORKSPACE/ergentics-prime/Tests/PrimeValidationWorkflow",
              mechanics.validationPackageMustBePhysicalDirectory,
              !mechanics.validationPackageSymbolicLinkAuthorized,
              mechanics.orderedSwiftBuildProducts
                == payload.orderedProducts,
              mechanics.expectedSwiftBuildProductCommandCount == 2,
              mechanics.expectedSwiftShowBinPathCommandCount == 1,
              mechanics.expectedSwiftRunCommandCount == 0,
              mechanics.expectedSwiftTestCommandCount == 0,
              mechanics.expectedSwiftBuildTestsCommandCount == 0,
              mechanics.orderedSwiftPMCommandRoles
                == [
                    "release_build_PrimeValidationWorkflowFixtureChild",
                    "release_build_PrimeValidationWorkflowSecureChildIntegration",
                    "release_show_bin_path_without_product_build",
                ],
              mechanics.exactSwiftPMCommandCount == 3,
              mechanics.exactSwiftPMCommandCount
                == mechanics.expectedSwiftBuildProductCommandCount
                    + mechanics.expectedSwiftShowBinPathCommandCount,
              mechanics.orderedCommonSwiftPMArgumentTemplates
                == [
                    "--package-path Tests/PrimeValidationWorkflow",
                    "--configuration release",
                    "--scratch-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-scratch",
                    "--cache-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-cache",
                    "--config-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-config",
                    "--security-path $RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-security",
                    "--disable-dependency-cache",
                    "--manifest-cache local",
                    "--disable-netrc",
                    "--disable-keychain",
                    "--force-resolved-versions",
                ],
              mechanics.orderedRequiredLocalMirrorOrigins
                == [
                    "https://github.com/Ergentics/ergentics-mlx-swift",
                    "https://github.com/apple/swift-numerics",
                ],
              mechanics.expectedLocalBareMirrorCount == 2,
              mechanics.orderedRequiredLocalBareMirrors.count == 2,
              mechanics.orderedRequiredLocalBareMirrors[0].dependencyIdentity
                == "ergentics_mlx_swift",
              mechanics.orderedRequiredLocalBareMirrors[0].runnerTempPath
                == "$RUNNER_TEMP/ergentics-mlx-swift.git",
              mechanics.orderedRequiredLocalBareMirrors[0].fileURL
                == "file://$RUNNER_TEMP/ergentics-mlx-swift.git/",
              mechanics.orderedRequiredLocalBareMirrors[0].exactOriginURL
                == mechanics.orderedRequiredLocalMirrorOrigins[0],
              mechanics.orderedRequiredLocalBareMirrors[0].exactCommitSHA
                == "d37885a278f1c37484a94d0f401a418735e66519",
              mechanics.orderedRequiredLocalBareMirrors[0]
                .typedCommitExpression
                == "d37885a278f1c37484a94d0f401a418735e66519^{commit}",
              mechanics.orderedRequiredLocalBareMirrors[0]
                .pinnedRefExpression
                == "refs/heads/prime-pinned^{commit}",
              mechanics.orderedRequiredLocalBareMirrors[1].dependencyIdentity
                == "swift_numerics",
              mechanics.orderedRequiredLocalBareMirrors[1].runnerTempPath
                == "$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c",
              mechanics.orderedRequiredLocalBareMirrors[1].fileURL
                == "file://$RUNNER_TEMP/prime-active-root-build/repositories/swift-numerics-d936ec6c/",
              mechanics.orderedRequiredLocalBareMirrors[1].exactOriginURL
                == mechanics.orderedRequiredLocalMirrorOrigins[1],
              mechanics.orderedRequiredLocalBareMirrors[1].exactCommitSHA
                == "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
              mechanics.orderedRequiredLocalBareMirrors[1]
                .typedCommitExpression
                == "0c0290ff6b24942dadb83a929ffaaa1481df04a2^{commit}",
              mechanics.orderedRequiredLocalBareMirrors[1]
                .pinnedRefExpression
                == "refs/tags/1.1.1^{commit}",
              mechanics.orderedRequiredLocalBareMirrors.allSatisfy({ mirror in
                  mirror.pathMustExistAsDirectory
                    && !mirror.symbolicLinkAuthorized
                    && mirror.physicalPathMustEqualExpandedRunnerTempPath
                    && mirror.absoluteGitDirectoryMustEqualPhysicalPath
                    && mirror.bareRepositoryRequired
                    && mirror.soleRemoteName == "origin"
                    && mirror.exactOriginURLValueCount == 1
                    && mirror.revisionObjectType == "commit"
                    && mirror.typedCommitMustResolveToExactCommit
                    && mirror.pinnedRefMustResolveToExactCommit
              }),
              mechanics.alreadyValidatedLocalBareMirrorsRequired,
              mechanics.sameReviewedJobLocalBareMirrorsRequired,
              mechanics
                .localBareMirrorsRevalidatedImmediatelyBeforeMappingsAndBuilds,
              mechanics.runnerTempMustBeCanonicalAbsolutePhysicalDirectory,
              mechanics.orderedFileURLInsteadOfMappings.count == 2,
              mechanics.orderedFileURLInsteadOfMappings[0].localFileURL
                == mechanics.orderedRequiredLocalBareMirrors[0].fileURL,
              mechanics.orderedFileURLInsteadOfMappings[0].remoteURL
                == mechanics.orderedRequiredLocalBareMirrors[0].exactOriginURL,
              mechanics.orderedFileURLInsteadOfMappings[1].localFileURL
                == mechanics.orderedRequiredLocalBareMirrors[1].fileURL,
              mechanics.orderedFileURLInsteadOfMappings[1].remoteURL
                == mechanics.orderedRequiredLocalBareMirrors[1].exactOriginURL,
              mechanics.exactFileURLInsteadOfMappingCount == 2,
              mechanics.exactFileURLInsteadOfMappingCount
                == mechanics.orderedFileURLInsteadOfMappings.count,
              mechanics.protocolFileAllowAlwaysRequired,
              mechanics.forceResolvedVersionsRequired,
              mechanics.mirrorMismatchRequiresAppendOnlyObservation,
              mechanics.mirrorMismatchRetiresMechanicsOpportunity,
              !mechanics.mirrorMismatchEstablishesAdapterInvocation,
              !mechanics.mirrorMismatchPermitsRetryWithoutNewAuthority,
              mechanics.orderedFreshPrivateSwiftPMRootRoles
                == ["scratch", "cache", "config", "security"],
              mechanics.orderedFreshPrivateSwiftPMRootPaths
                == [
                    "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-scratch",
                    "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-cache",
                    "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-config",
                    "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-security",
                ],
              mechanics.freshPrivateSwiftPMRootCount == 4,
              mechanics.freshPrivateSwiftPMRootCount
                == mechanics.orderedFreshPrivateSwiftPMRootRoles.count,
              mechanics.freshPrivateSwiftPMRootCount
                == mechanics.orderedFreshPrivateSwiftPMRootPaths.count,
              mechanics.freshPrivateSwiftPMRootMode == "0700",
              mechanics
                .freshPrivateSwiftPMRootsMustNotPreexistOrBeSymbolicLinks,
              mechanics
                .freshPrivateSwiftPMRootsMustBeCanonicalPhysicalDirectories,
              mechanics.disableDependencyCacheRequired,
              mechanics.manifestCacheMode == "local",
              mechanics.disableNetrcRequired,
              mechanics.disableKeychainRequired,
              !mechanics.disableSandboxAuthorized,
              mechanics
                .isolationFlagsRequiredOnEveryBuildAndShowBinPathCommand,
              mechanics.fileURLMappingsRequiredOnEveryBuildAndShowBinPathCommand,
              mechanics.swiftPMTMPDIR == "$RUNNER_TEMP",
              mechanics.canonicalBinPathMustBePhysicalDescendantOfScratchPath,
              mechanics.showBinPathExactOutputLineCount == 1,
              mechanics.orderedExpectedExecutableLeafNames
                == mechanics.orderedSwiftBuildProducts,
              mechanics.exactExpectedExecutableLeafCount == 2,
              mechanics.exactExpectedExecutableLeafCount
                == mechanics.orderedExpectedExecutableLeafNames.count,
              mechanics.expectedExecutableLeavesMustBeRegular,
              !mechanics.expectedExecutableLeafSymbolicLinksAuthorized,
              mechanics.expectedExecutableLeafLinkCount == 1,
              mechanics.expectedExecutableLeavesMustBeExecutable,
              mechanics.bothExecutableDescriptorMetadataAndSHA256Bound,
              mechanics
                .bothExecutableIdentitiesRevalidatedImmediatelyBeforeCall,
              mechanics.launcherFinalStepAfterRetainedLiveTestCount == 46,
              mechanics.launcherFinalStepAfterRetainedLiveTestCount
                == mechanics.expectedRetainedLiveTestCount,
              mechanics.dependencyNetworkInvocationCountAfterReviewedFetch
                == 0,
              mechanics.directAdapterArgumentCountExcludingArgumentZero == 1,
              mechanics.directAdapterProcessArgumentCountIncludingArgumentZero
                == 2,
              mechanics.directAdapterOnlyArgumentRole
                == "canonical_absolute_path_to_measured_fixture_matching_existing_layer_a_pin",
              mechanics.adapterExecutableAbsolutePathRequired,
              mechanics.fixtureArgumentCanonicalAbsolutePathRequired,
              !mechanics.callerControlledEnvironmentAuthorized,
              !mechanics.callerControlledCommandAuthorized,
              mechanics.evalInvocationCount == 0,
              mechanics.arbitraryShellExecInvocationCount == 0,
              mechanics.requiredLayerAAcceptanceFixtureExecutableByteCount
                == 89_632,
              mechanics.requiredLayerAAcceptanceFixtureExecutableSHA256
                == "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd",
              mechanics.acceptancePinKernelSourcePath
                == "Sources/PrimeCore/PrimeSecureChildKernel.swift",
              Self.validSource(
                  mechanics.acceptancePinHistoricalDocumentation),
              mechanics
                .historicalDocumentationReportedDisjointAbsolutePathReleaseBuildCount
                == 2,
              mechanics
                .historicalDocumentationReportsReleaseBuildsByteIdentical,
              mechanics.historicalDocumentationReportedMachOUUID
                == "6ABE4B24-C019-3372-8144-C85CCEE5BA19",
              !mechanics.historicalBinaryRetained,
              !mechanics.futureHostedBuildMatchObserved,
              mechanics.futureHostedBuildMeasuredByteCount
                == "unavailable_until_exact_mechanics_lane_build",
              mechanics.futureHostedBuildMeasuredSHA256
                == "unavailable_until_exact_mechanics_lane_build",
              mechanics
                .fixtureExecutableBuildOutputIdentityCapturedImmediatelyBeforeInvocation,
              mechanics.fixtureExecutableDescriptorNameAndInodeJoinRequired,
              mechanics.measuredBuildMustMatchExistingLayerAAcceptancePin,
              mechanics.pinMismatchRefusesBeforeOneShotConsumption,
              mechanics.reviewedJobEpochFilePath
                == "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-reviewed-job-epoch",
              mechanics
                .reviewedJobEpochCreatedInFirstWorkflowUserStepBeforeToolchain,
              !mechanics.reviewedJobEpochRepresentsGitHubJobStartTimestamp,
              mechanics
                .reviewedJobEpochFileMustInitiallyNotExistOrBeSymbolicLink,
              mechanics.reviewedJobEpochFileCreatedExclusiveNoClobber,
              !mechanics.reviewedJobEpochFileKernelImmutableClaimed,
              mechanics.reviewedJobEpochFileReadOnlyByPolicy,
              mechanics.reviewedJobEpochFileMustBeRegular,
              !mechanics.reviewedJobEpochFileSymbolicLinkAuthorized,
              mechanics.reviewedJobEpochFileMode == "0400",
              mechanics.reviewedJobEpochFileLinkCount == 1,
              mechanics.reviewedJobEpochFileOwnerUIDAndGIDBound,
              mechanics.reviewedJobEpochContentGrammar
                == "canonical_positive_base10_unix_epoch_seconds_lf",
              mechanics.reviewedJobEpochContentLineCount == 1,
              mechanics.reviewedJobEpochMustBePositive,
              !mechanics.reviewedJobEpochLeadingZeroAuthorized,
              mechanics.reviewedJobEpochDescriptorIdentityBoundByLauncher,
              mechanics.reviewedJobEpochMetadataBoundByLauncher,
              mechanics.reviewedJobEpochSHA256BoundByLauncher,
              mechanics
                .reviewedJobEpochRevalidatedUnchangedImmediatelyBeforeOneShot,
              mechanics.reviewedJobEpochMustNotBeFutureAtRevalidation,
              mechanics.preInvocationElapsedUsesWallClockEpochDifference,
              !mechanics.continuousThroughSystemSleepClaimed,
              mechanics.predecessorReviewedJobElapsedSeconds == 3_082,
              mechanics.predecessorRetainedLiveCompletionElapsedSeconds
                == 3_073,
              mechanics.priorJobCeilingSeconds == 3_600,
              mechanics.predecessorRemainingSecondsUnderPriorCeiling == 527,
              mechanics.priorPreInvocationCutoffSeconds == 3_300,
              mechanics.predecessorRemainingSecondsUnderPriorCutoff == 227,
              !mechanics.exactLaneReleaseBuildDurationBoundObserved,
              !mechanics
                .sameJobDebugOrCacheStateEstablishesReleaseBuildBound,
              mechanics.expectedJobCeilingSeconds == 4_500,
              mechanics.maximumPreInvocationElapsedSeconds == 4_200,
              mechanics.requiredRemainingJobReserveSeconds == 300,
              mechanics.maximumPreInvocationElapsedSeconds
                    + mechanics.requiredRemainingJobReserveSeconds
                == mechanics.expectedJobCeilingSeconds,
              mechanics.expectedCapturePhaseCeilingSeconds
                    + mechanics.expectedDeadlineCleanupCount
                        * mechanics.expectedPerDeadlineCleanupCeilingSeconds
                == mechanics.expectedCaptureAndDeadlineCleanupBudgetSeconds,
              mechanics.expectedCaptureAndDeadlineCleanupBudgetSeconds == 100,
              !mechanics
                .capabilityPreparationHashFilesystemAndReadyBarrierIncludedInBudget,
              mechanics.concurrentReadyBarrierMaximumSeconds == 3,
              !mechanics.wholeAdapterWallCeilingEstablished,
              mechanics
                .remainingJobReserveIsPracticalNonGuaranteedOuterEnvelope,
              mechanics.directForegroundInvocationRequired,
              !mechanics.backgroundWatchdogAuthorized,
              !mechanics.shellKillOrProcessScanAuthorized,
              mechanics
                .mechanicsOpportunityConsumedImmediatelyBeforeAdapterCommandAttempt,
              !mechanics
                .preCommandRefusalConsumesAdapterCommandAttemptOneShot,
              !mechanics.preCommandRefusalEstablishesAdapterExecution,
              mechanics.preCommandRefusalRetiresMechanicsOpportunity,
              !mechanics.automaticRetryAfterPreInvocationFailureAuthorized,
              mechanics
                .everyPostCommandAttemptOutcomeConsumesMechanicsOpportunity,
              !mechanics.workflowRerunAuthorized,
              !mechanics.replacementExecutionAuthorized,
              mechanics.expectedFocusedWholeTestCount
                == mechanics.expectedRootTestCount
                    + mechanics.expectedIsolatedTestCount,
              mechanics.expectedAggregateXTestCount
                == mechanics.expectedFocusedWholeTestCount
                    + mechanics.expectedRetainedLiveTestCount,
              mechanics.expectedEmbeddedProvenanceRecordCountWithLauncherPresent
                == 507,
              mechanics.embeddedProvenanceBytesMustRemainIdentical,
              outer.privateCaptureRootPath
                == "$RUNNER_TEMP/prime-secure-child-process-evidence-closed-fixture-canary-outer-capture",
              outer.privateCaptureRootMustInitiallyNotExistOrBeSymbolicLink,
              outer.privateCaptureRootCreatedByExactPathMkdirWithoutParents,
              outer.privateCaptureRootMode == "0700",
              outer.privateCaptureRootMustBePhysicalDirectory,
              !outer.privateCaptureRootSymbolicLinkAuthorized,
              outer.orderedCaptureStreamNames
                == ["standard_output", "standard_error"],
              outer.orderedFixedCaptureLeafNames
                == ["standard-output.capture", "standard-error.capture"],
              outer.fixedCaptureLeavesPrecreatedBeforeInvocation,
              outer.captureFileMode == "0600",
              outer.captureFilesMustBeRegular,
              !outer.captureFileSymbolicLinksAuthorized,
              outer.captureFileLinkCount == 1,
              outer.perStreamCaptureByteCap == 131_072,
              outer.bash1024ByteFileSizeLimitBlockCount == 128,
              outer.perStreamCaptureByteCap
                == outer.bash1024ByteFileSizeLimitBlockCount * 1_024,
              outer.layerACapturedPrefixByteCap == 65_536,
              outer.outerCaptureCapDistinctFromLayerACapturedPrefixCap,
              outer.perStreamCaptureByteCap
                > outer.layerACapturedPrefixByteCap,
              !outer.rawStreamBytesForwarded,
              !outer.rawStreamBytesIncludedInSummary,
              !outer.rawStreamBytesUploadedAsArtifact,
              outer.exactAdapterCommandStates
                == ["not_attempted", "shell_command_returned"],
              outer.exactAdapterExecutionObservationStates
                == ["observed_true", "observed_false", "unavailable"],
              outer
                .shellWaitStatusObservationRequiredAfterSynchronousReturn,
              !outer.shellWaitStatusAloneEstablishesAdapterExecution,
              outer.exactRecognizedAdapterEnvelopesMayEstablishExecution,
              outer
                .preCommandRefusalEstablishesAdapterExecutionObservedFalse,
              !outer.noReportOrUnexpectedReportEstablishesAdapterExecution,
              !outer.nativeWaiterUsed,
              !outer.exactExitVersusSignalClassificationEstablished,
              outer.shellWaitStatusType == "null_or_uint8",
              outer.shellWaitStatusMinimum == 0,
              outer.shellWaitStatusMaximum == 255,
              outer
                .shellWaitStatusZeroRequiresExpectedOutputContractForPass,
              outer
                .shellWaitStatusNonzeroUsesClosedDiagnosticClassification,
              outer.adapterReportedFailureAllowedShellStatuses == [1, 2],
              outer.adapterReportedFailureStandardErrorPrefix
                == "prime-validation secure-child integration: FAIL ",
              Data(outer.adapterReportedFailureStandardErrorPrefix.utf8).count
                == outer.adapterReportedFailureStandardErrorPrefixByteCount,
              outer.adapterReportedFailureStandardErrorPrefixByteCount == 48,
              outer.layerAFailStopReportedShellStatus == 70,
              outer.layerAFailStopStandardErrorPrefix
                == "prime-secure-child fail-stop: ",
              Data(outer.layerAFailStopStandardErrorPrefix.utf8).count
                == outer.layerAFailStopStandardErrorPrefixByteCount,
              outer.layerAFailStopStandardErrorPrefixByteCount == 30,
              outer.reportedFailureRequiresExactlyOneTerminalLF,
              outer.reportedFailureRequiresEmptyStandardOutput,
              !outer.reportedFailureAllowsAdditionalLine,
              !outer.reportedFailureAllowsCaptureCapReached,
              outer.adapterNoReportRequiresEmptyStandardOutput,
              outer.adapterNoReportRequiresEmptyStandardError,
              outer.unmatchedNonzeroReportResultCode
                == "ADAPTER_UNEXPECTED_REPORT",
              outer.statusZeroWrongOutputContractResultCode
                == "ADAPTER_OUTPUT_CONTRACT_MISMATCH",
              outer.diagnosticClassifierUsesOnlyFixedByteOperations,
              outer.notAttemptedRequiresZeroCapturedByteCounts,
              outer.notAttemptedRequiredEmptyStreamSHA256
                == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
              outer.notAttemptedRequiresCaptureCapNotReached,
              outer.perStreamCapturedByteCountRequired,
              outer.perStreamSHA256Required,
              outer.perStreamCaptureCapReachedStateRequired,
              outer.captureCapReachedTrueIffCapturedByteCountEqualsCap,
              !outer.captureCapReachedEstablishesAttemptedExcessBytes,
              !outer.outerStreamOverflowOrTruncationEstablished,
              outer.orderedProjectionPrerequisites
                == [
                    "adapter_command_not_attempted_or_synchronous_shell_command_return_and_status",
                    "both_stream_counts_hashes_and_capture_cap_reached_states_captured",
                    "bounded_capture_cleanup_attempt_completed",
                ],
              outer.captureCleanupAttemptBounded,
              outer.captureCleanupBoundIsExactOperationTopology,
              outer.exactCaptureLeafUnlinkAttemptCount == 2,
              outer.exactCaptureLeafUnlinkAttemptCount
                == outer.orderedFixedCaptureLeafNames.count,
              outer.exactCaptureRootRmdirAttemptCount == 1,
              outer.recursiveDeletionInvocationCount == 0,
              outer.wildcardCleanupPathCount == 0,
              outer.cleanupDirectoryScanInvocationCount == 0,
              !outer.cleanupSuccessRequiredBeforeProjection,
              outer.exactCaptureCleanupAbsenceStates
                == ["observed_true", "observed_false", "unavailable"],
              outer.captureCleanupFailureResultCode
                == "CAPTURE_CLEANUP_FAILED",
              outer.captureCleanupFailureRequiresNonzeroLauncherExit,
              outer.captureSetupRefusalResultCode == "CAPTURE_SETUP_REFUSED",
              outer
                .captureSetupRefusalEstablishesAdapterExecutionObservedFalse,
              outer
                .cleanupFailureOverridesPrimaryResultOnlyWhenPrimaryWasPass,
              outer.nonPassPrimaryResultPreservedWhenCleanupFails,
              outer.cleanupFailureStillRecordsObservedFalseAbsence,
              outer.exactSanitizedResultCodes
                == [
                    "PASS",
                    "INVOCATION_ADMISSION_REFUSED",
                    "EPOCH_REFUSED",
                    "PREINVOCATION_CUTOFF",
                    "PLATFORM_REFUSED",
                    "MIRROR_REFUSED",
                    "SWIFTPM_ROOT_REFUSED",
                    "ADAPTER_IDENTITY_REFUSED",
                    "BUILD_REFUSED",
                    "PIN_MISMATCH",
                    "CAPTURE_SETUP_REFUSED",
                    "ADAPTER_REPORTED_FAILURE",
                    "LAYER_A_FAIL_STOP_REPORTED",
                    "ADAPTER_NO_REPORT",
                    "ADAPTER_UNEXPECTED_REPORT",
                    "ADAPTER_OUTPUT_CONTRACT_MISMATCH",
                    "CAPTURE_CAP_REACHED",
                    "CAPTURE_CLEANUP_FAILED",
                    "UNCLASSIFIED",
                ],
              Set(outer.exactSanitizedResultCodes).count
                == outer.exactSanitizedResultCodes.count,
              outer.exactSanitizedResultCodes.contains(
                  mechanics.invocationAdmissionMismatchResultCode),
              outer.exactSanitizedResultCodes.contains(
                  outer.unmatchedNonzeroReportResultCode),
              outer.exactSanitizedResultCodes.contains(
                  outer.statusZeroWrongOutputContractResultCode),
              outer.exactSanitizedResultCodes.contains(
                  outer.captureCleanupFailureResultCode),
              outer.exactSanitizedResultCodes.contains(
                  outer.captureSetupRefusalResultCode),
              outer.unknownRawErrorResultCode == "UNCLASSIFIED",
              outer.exactSanitizedResultCodes.contains(
                  outer.unknownRawErrorResultCode),
              !outer.rawErrorTextInterpolatedIntoProjection,
              outer.hostedRecordPrefix
                == "prime-secure-child closed-fixture-canary observation: ",
              Data(outer.hostedRecordPrefix.utf8).count
                == outer.hostedRecordPrefixByteCount,
              outer.hostedRecordPrefixByteCount == 54,
              outer.hostedRecordSchemaID
                == "prime_secure_child_process_evidence_closed_fixture_canary_outer_observation_v1",
              outer.hostedRecordSchemaVersion == 1,
              outer.hostedRecordCanonicalJSONRequired,
              outer.hostedRecordExactLineCount == 1,
              outer.hostedRecordTerminalLFRequired,
              outer.hostedRecordTerminalLFByteCount == 1,
              outer.hostedRecordMaximumCanonicalJSONByteCount == 4_041,
              outer.hostedRecordMaximumTotalLineByteCount == 4_096,
              outer.hostedRecordPrefixByteCount
                    + outer.hostedRecordMaximumCanonicalJSONByteCount
                    + outer.hostedRecordTerminalLFByteCount
                == outer.hostedRecordMaximumTotalLineByteCount,
              outer.hostedRecordOrderedFieldTypeContracts
                == [
                    "actions_artifact:bool",
                    "adapter_command_attempt_one_shot_consumed:bool",
                    "adapter_command_state:enum_not_attempted_shell_command_returned",
                    "adapter_execution_observation:enum_observed_true_observed_false_unavailable",
                    "adapter_executable_byte_count:null_or_positive_int",
                    "adapter_executable_sha256:null_or_lowercase_hex_64",
                    "authority_canonical_sha256:lowercase_hex_64",
                    "authority_id:utf8_exact",
                    "capture_cleanup_absence:enum_observed_true_observed_false_unavailable",
                    "durable_evidence:bool",
                    "exact_revision:lowercase_git_sha_40",
                    "fixture_executable_byte_count:null_or_positive_int",
                    "fixture_executable_sha256:null_or_lowercase_hex_64",
                    "opportunity_state:enum_retired",
                    "result_code:closed_enum",
                    "schema_id:utf8_exact",
                    "schema_version:positive_int",
                    "scientific_outcome:enum_not_established",
                    "shell_wait_status:null_or_uint8",
                    "standard_error_byte_cap:positive_int",
                    "standard_error_captured_byte_count:nonnegative_int",
                    "standard_error_capture_cap_reached:bool",
                    "standard_error_sha256:lowercase_hex_64",
                    "standard_output_byte_cap:positive_int",
                    "standard_output_captured_byte_count:nonnegative_int",
                    "standard_output_capture_cap_reached:bool",
                    "standard_output_sha256:lowercase_hex_64",
                ],
              outer.hostedRecordExactFieldCount == 27,
              outer.hostedRecordExactFieldCount
                == outer.hostedRecordOrderedFieldTypeContracts.count,
              outer
                .hostedRecordExecutableIdentityFieldsNullableForPreCommandRefusal,
              outer.commandAttemptRecordRequiresBothExecutableIdentities,
              outer
                .identityOrPinRefusalRecordsMeasuredIdentitiesWhenAvailable,
              outer.nonnullFixtureIdentityMustMatchLayerAAcceptancePin,
              outer.hostedRecordAuthorityID == authorityID,
              outer.hostedRecordAuthorityCanonicalSHA256ValueSource
                == "PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityV1.canonicalSHA256",
              outer.hostedRecordExactRevisionValueSource
                == "GITHUB_SHA_of_exact3_mechanics_main_push",
              outer.hostedRecordExactRevisionMustBeLowercaseGitSHA,
              outer.hostedRecordOpportunityState == "retired",
              outer.hostedRecordScientificOutcome == "not_established",
              !outer.hostedRecordDurableEvidenceValue,
              !outer.hostedRecordActionsArtifactValue,
              outer.hostedRecordRawChildOutputOrErrorFieldCount == 0,
              outer.exactSanitizedOperationalRecordCountWhenProjectionSucceeds
                == 1,
              outer.projectionIsOuterOperationalCompatibilityEvidenceOnly,
              !outer.projectionIsLayerADiagnostic,
              !outer.projectionIsScientificEvidence,
              !outer.projectionIsDurableEvidence,
              outer
                .hostedCancellationOrTimeoutObservedOnlyFromActionsMetadata,
              outer
                .hostedOperationalRecordMayBeAbsentOnAbruptHostOrRunnerLoss,
              outer
                .hostedOperationalRecordMayBeAbsentOnActiveRootAdmissionRefusal,
              outer
                .hostedOperationalRecordMayBeAbsentOnPreLauncherReviewedJobFailure,
              outer
                .hostedOperationalRecordMayBeAbsentOnLauncherReachedProjectionFailure,
              outer.exactHostedOperationalRecordAbsenceStates
                == [
                    "launcher_not_reached",
                    "launcher_reached_record_absent",
                    "abrupt_host_or_runner_loss",
                ],
              outer.absentHostedOperationalRecordCount == 0,
              outer.orderedLauncherNotReachedCauses
                == [
                    "active_root_gate_failure_or_later_push_admission_refusal",
                    "reviewed_toolchain_failure",
                    "reviewed_checkout_failure",
                    "reviewed_private_dependency_fetch_failure",
                    "reviewed_focused_contract_failure",
                    "reviewed_retained_live_failure",
                ],
              outer.launcherNotReachedEstablishesAdapterNotInvoked,
              outer.launcherNotReachedHostedOperationalRecordCount == 0,
              outer.launcherNotReachedAdapterCommandAttemptCount == 0,
              !outer.launcherNotReachedEstablishesAdapterTerminalState,
              !outer.launcherNotReachedEstablishesContainmentOrCleanup,
              outer.launcherNotReachedRetiresMechanicsOpportunity,
              !outer.launcherNotReachedPermitsRetryOrRerun,
              outer.orderedLauncherReachedRecordAbsentCauses
                == [
                    "ordinary_shell_failure",
                    "hash_failure",
                    "stat_failure",
                    "canonical_json_projection_failure",
                    "trap_projection_failure",
                ],
              outer.launcherTrapAttemptsUNCLASSIFIEDRecord,
              !outer.launcherTrapRecordEmissionGuaranteed,
              !outer.launcherReachedRecordAbsentEstablishesAdapterExecution,
              !outer
                .launcherReachedRecordAbsentEstablishesAdapterTerminalState,
              !outer
                .launcherReachedRecordAbsentEstablishesContainmentOrCleanup,
              outer.launcherReachedRecordAbsentRetiresMechanicsOpportunity,
              !outer.launcherReachedRecordAbsentPermitsRetryOrRerun,
              outer
                .absentHostedRecordObservedOnlyFromActionsRunJobStepMetadataAndLogs,
              outer.activeRootAdmissionRefusalOccursBeforeReviewedJob,
              !outer.activeRootAdmissionRefusalEstablishesAdapterInvocation,
              outer.activeRootAdmissionRefusalRetiresMechanicsOpportunity,
              !outer.activeRootAdmissionRefusalPermitsRetryOrRerun,
              outer
                .preLauncherReviewedJobFailureEstablishesAdapterNotInvoked,
              outer
                .preLauncherReviewedJobFailureRetiresMechanicsOpportunity,
              !outer.preLauncherReviewedJobFailurePermitsAutomaticRerun,
              !outer.absentHostedRecordEstablishesAdapterTerminalState,
              !outer
                .absentHostedRecordEstablishesFixtureOrProcessContainment,
              !outer.absentHostedRecordEstablishesCaptureCleanupAbsence,
              outer.absentHostedRecordRetiresMechanicsOpportunity,
              !outer.absentHostedRecordPermitsRetryOrRerun,
              !outer.hostedCancellationOrTimeoutEstablishesContainment,
              outer.actionsArtifactCount == 0,
              filesystem.laterMechanicsMayCreatePrivateTemporaryRoot,
              filesystem
                .laterMechanicsMayCreateFixtureWorkingAndResultDirectories,
              filesystem
                .laterMechanicsMayWriteFixtureResultAndCapturedPrefixFiles,
              filesystem.laterMechanicsMayCopyAndMutatePrivateFixtureExecutable,
              filesystem
                .replacementMutationExistsOnlyToProvePreSpawnRejection,
              !filesystem.replacementExecutableMayRun,
              filesystem.successfulCanaryAttemptsCleanupBeforeReporting,
              !filesystem.privateRootAbsenceEstablishedAsDurableEvidence,
              !filesystem.fsyncUseEstablishesDurableEvidence,
              !filesystem.localPersistenceAuthorizedBeyondInvocation,
              !filesystem.actionsArtifactUploadAuthorized,
              !filesystem.retentionAuthorized,
              retirement.disposition == "observe_once_then_retire",
              retirement.appendOnlyObservationRequiredAfterEveryInvocation,
              retirement.successRequiresObservationAndRetirement,
              retirement.failureRequiresObservationAndRetirement,
              retirement.cancellationRequiresObservationAndRetirement,
              retirement.setupOutcomeRequiresObservation,
              retirement.setupOutcomeRetiresMechanicsOpportunity,
              !retirement.setupOutcomeEstablishesCanaryExecution,
              !retirement.setupOutcomePermitsRetryWithoutNewAuthority,
              !retirement.monitorOrHostLossEstablishesContainment,
              !retirement.automaticRetryAuthorized,
              !retirement.workflowRerunAuthorized,
              !retirement.replacementExecutionAuthorized,
              !retirement.oldStage7WatchdogRepairAuthorized,
              retirement.orderedLaterBoundaries.count == 8,
              !language.pythonPermitted,
              language.pythonInvocationCount == 0,
              language.pythonSourcePathCount == 0,
              language.cppNewImplementationInvocationCount == 0,
              language.cppNewSourcePathCount == 0,
              language.retainedBaselineCppDependencyCompilationMayOccur,
              language.cppFullNativeAlternativeSeparatelyPermissibleLater,
              language.cppSwiftCABIAlternativeSeparatelyPermissibleLater,
              !language.cppAlternativeAuthorizedNow,
              language.cppAlternativeRequiresSeparateAuthority,
              ceiling.designAuthorityEstablished,
              ceiling.implementationAuthorityEstablished,
              ceiling.layerAExactMainClosureEstablished,
              ceiling.closedFixtureCanaryAuthorityEstablished,
              ceiling.exactThreeMechanicsSuccessorAuthorizedAfterClosure,
              falseClaims.allSatisfy({ !$0 }),
              canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical)
                == Self.canonicalSHA256 else {
            throw PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityError
                .contractDrift
        }
    }

    private static let layerAIdentities: [SourceIdentity] = [
        source(
            "Sources/PrimeCore/PrimeSecureChildProcessPlan.swift",
            "100644", "f9bc922c90ad7b6ed5d8f28b2f0b6f5085043281",
            5_440, 148,
            "06e130d5f8367c2b5822a53787e610826c3b6dd7a3e8644cee7f0ba2384b0510",
            "layer_a_closed_process_plan"),
        source(
            "Sources/PrimeCore/PrimeSecureChildProcessEvidence.swift",
            "100644", "7ffa7711943e485f98e98ae8a862efb12f8a4516",
            38_655, 1_040,
            "950688d06bc4df919fe53fa4e1ea4711d704c968d4e9349fafe9c86ee5928b9b",
            "layer_a_typed_evidence_and_diagnostic_projection"),
        source(
            "Sources/PrimeCore/PrimeTrustedSecureChildProcessCapture.swift",
            "100644", "a289898d4b0239728bd882d14948d0ab01e91766",
            5_499, 167,
            "0cb4a2eb54b8b8a4baa0e1ffe4c17f05d407e91f316306426a0b611d54041b85",
            "layer_a_exactly_once_trusted_capture"),
        source(
            "Sources/PrimeCore/PrimeSecureChildExecutionKernel.swift",
            "100644", "616af54193830c897c634500ce294b827a3d9e22",
            11_167, 303,
            "bb62c691fa78428bacc5c1e26800692e07fb060214b4e73ce654629f833c559a",
            "layer_a_execution_kernel"),
        source(
            "Sources/PrimeCore/PrimeSecureChildDrains.swift",
            "100644", "6579b9a08dea19b7c4d4654ec3b9735d3cc0d8b4",
            17_440, 609,
            "8300f4845fc9861d78dd2bccfddc1d480920af74f0bd4cfa8f16dafd7ed5ecbe",
            "layer_a_terminal_closed_drains"),
        source(
            "Sources/PrimeCore/PrimeSecureChildSupervision.swift",
            "100644", "13d882363479143d2a207375ac3eb84971fabb35",
            24_830, 842,
            "700f64199ccfcfac2c21cd7e0e8145d6e72d3cc85ad64ee8781a08fc7dcc6caf",
            "layer_a_containment_supervision"),
        source(
            "Sources/PrimeCore/PrimeSecureChildKernel.swift",
            "100644", "bfa381796b9647863e704006dbaa1406c533c7c5",
            83_657, 2_327,
            "1ed890d017b67c97a0d980d58cb7614bb71362091c02b03d26a26222b24d5fcd",
            "layer_a_closed_fixture_adapter"),
        source(
            "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceTests.swift",
            "100644", "d612316fe0fbe9c835331a3f8fcae4477064bd73",
            45_527, 1_260,
            "28ac04ed21e23cd33585db753083b1e719ad3f7a7b00214d8d101eb361e60a04",
            "layer_a_injected_value_tests"),
        source(
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateSecureChildLifecycleTests.swift",
            "100644", "a6676c503f05004fcf0a8cb2202a1e627755c4cb",
            40_603, 1_393,
            "b8320df5c6f359911e34ddc69ab161f768a8cc8ca74e6a975a5b35d92acacd32",
            "layer_a_lifecycle_compatibility_tests"),
        source(
            "Tests/PrimeCoreTests/PrimeNativeNeuralGateSecureExternalChildCaptureTests.swift",
            "100644", "b2a1616bf234b4ef23316638efc12769f54294e1",
            93_996, 2_959,
            "0d655262702c560ba7211f3363a3790f76b8636905f22abfe491d2e6dd865209",
            "layer_a_external_capture_compatibility_test"),
        source(
            "Sources/PrimeCore/PrimeSecureChildLifecycle.swift",
            "100644", "e2b65441e015b7c4728f3bd3aaaf125ea21b137e",
            26_436, 1_000,
            "21fe130dbf1d4fc42437bfe6a9224d9f6d7f4568b7785c9dc5a0f8014538adb6",
            "unchanged_frozen_lifecycle_source"),
    ]

    private static let modeContracts: [OrderedModeContract] = [
        mode(1, "pass", 2, 10_000_000_000,
             "exited_status_0", "exact_fixture_result_present",
             "physical_executable_path", 0, 0, 0, 0, false,
             "exact_empty", "exact_empty", "top_level_child_only"),
        mode(2, "logical-argument-zero", 1, 10_000_000_000,
             "exited_status_0", "exact_logical_argument_zero_result",
             "swift-build_with_physical_mapped_image_join", 0, 0, 0, 0,
             false, "exact_empty", "exact_empty", "top_level_child_only"),
        mode(3, "nonzero-exit", 1, 10_000_000_000,
             "exited_status_23", "exact_fixture_result_present",
             "physical_executable_path", 0, 0, 0, 0, false,
             "exact_empty", "exact_empty", "top_level_child_only"),
        mode(4, "bounded-streams", 1, 10_000_000_000,
             "exited_status_0", "exact_fixture_result_present",
             "physical_executable_path", 4_096, 2_048, 4_096, 2_048,
             false, "exact_4096_uppercase_O_bytes",
             "exact_2048_uppercase_E_bytes", "top_level_child_only"),
        mode(5, "overflow", 1, 10_000_000_000,
             "exited_status_0", "exact_fixture_result_present",
             "physical_executable_path", 131_072, 131_072, 65_536,
             65_536, true, "exact_131072_uppercase_O_bytes_prefix_65536",
             "exact_131072_uppercase_E_bytes_prefix_65536",
             "top_level_child_only"),
        mode(6, "hang", 1, 1_000_000_000,
             "wall_clock_limit", "exact_fixture_result_present",
             "physical_executable_path", 0, 0, 0, 0, false,
             "exact_empty", "exact_empty", "exact_top_level_child"),
        mode(7, "self-signal", 1, 10_000_000_000,
             "signaled_sigterm_without_core", "exact_fixture_result_present",
             "physical_executable_path", 0, 0, 0, 0, false,
             "exact_empty", "exact_empty", "top_level_child_only"),
        mode(8, "descendant-retains-streams", 1, 1_000_000_000,
             "stream_containment_limit",
             "dynamic_exact_fixture_result_with_descendant_pid_matching_stdout_and_membership",
             "physical_executable_path", -1, 0, -1, 0, false,
             "spawned_descendant_pid_equals_positive_canonical_int32_then_one_lf_captured_equals_total",
             "exact_empty",
             "exact_top_level_child_and_one_internal_descendant"),
        mode(9, "exit-without-result", 1, 10_000_000_000,
             "exited_status_0", "no_result_binding_or_data",
             "physical_executable_path", 0, 0, 0, 0, false,
             "exact_empty", "exact_empty", "top_level_child_only"),
    ]

    private static func source(
        _ path: String,
        _ gitMode: String,
        _ gitBlob: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String,
        _ role: String
    ) -> SourceIdentity {
        SourceIdentity(
            path: path,
            gitMode: gitMode,
            gitBlob: gitBlob,
            byteCount: byteCount,
            lfByteCount: lfByteCount,
            sha256: sha256,
            role: role)
    }

    private static func mode(
        _ ordinal: Int,
        _ mode: String,
        _ captures: Int,
        _ maximumWallNanoseconds: UInt64,
        _ completion: String,
        _ result: String,
        _ argumentZero: String,
        _ stdoutTotal: Int,
        _ stderrTotal: Int,
        _ stdoutCaptured: Int,
        _ stderrCaptured: Int,
        _ overflow: Bool,
        _ stdoutContract: String,
        _ stderrContract: String,
        _ membership: String
    ) -> OrderedModeContract {
        OrderedModeContract(
            ordinal: ordinal,
            mode: mode,
            expectedTopLevelCaptureCount: captures,
            maximumWallNanoseconds: maximumWallNanoseconds,
            expectedCompletion: completion,
            expectedResult: result,
            expectedArgumentZero: argumentZero,
            expectedStandardOutputTotalByteCount: stdoutTotal,
            expectedStandardErrorTotalByteCount: stderrTotal,
            expectedStandardOutputCapturedByteCount: stdoutCaptured,
            expectedStandardErrorCapturedByteCount: stderrCaptured,
            expectedStandardOutputContract: stdoutContract,
            expectedStandardErrorContract: stderrContract,
            standardOutputOverflowExpected: overflow,
            standardErrorOverflowExpected: overflow,
            expectedPreReapMembership: membership)
    }

    private static func validSource(_ source: SourceIdentity) -> Bool {
        source.path.count > 3
            && !source.path.hasPrefix("/")
            && ["100644", "100755"].contains(source.gitMode)
            && source.gitBlob.count == 40
            && source.byteCount > 0
            && source.lfByteCount > 0
            && source.sha256.count == 64
            && !source.role.isEmpty
    }
}
