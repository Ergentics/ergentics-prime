// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeExactRevisionTopologyVerifierAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// Pure authority for one later shared exact-revision topology verifier.
/// This Foundation/Codable value performs no filesystem, process, Git,
/// network, model, lease, fixture, compiler, evaluator, MLX, Metal, Python,
/// or C++ operation. Its canonical identity constants were bound only after
/// independent pre-freeze review accepted the value and its sole test.
public struct PrimeExactRevisionTopologyVerifierAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public struct FileIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
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

    public struct RetiredRun160Closure: Codable, Equatable, Sendable {
        public let observationID: String
        public let observationCanonicalByteCount: Int
        public let observationCanonicalSHA256: String
        public let mechanicsMergeRevision: String
        public let mechanicsMergeTree: String
        public let orderedMechanicsMergeParentOIDs: [String]
        public let mechanicsReviewedHeadRevision: String
        public let mechanicsReviewedHeadTree: String
        public let orderedMechanicsReviewedHeadParentOIDs: [String]
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let checkSuiteID: Int
        public let activeRootJobID: Int
        public let reviewedMainJobID: Int
        public let workflowConclusion: String
        public let resultCode: String
        public let hostedRecordCount: Int
        public let measurementAttemptConsumed: Bool
        public let opportunityState: String
        public let scientificOutcome: String
        public let fixtureExecutionCount: Int
        public let actionsArtifactCount: Int
        public let retryCount: Int
        public let rerunCount: Int
        public let likelyRefusalCauseClassification: String
        public let likelyRefusalCauseDirectlyEstablished: Bool
        public let depthTwoCheckoutObserved: Bool
        public let retiredLauncherUsedMultiHopAncestryRevspec: Bool
        public let rawCommitHeadersWouldExposeRequiredOIDs: Bool
        public let refusalAuthorizesRepairRetryRerunOrReplacement: Bool
        public let retirementMergedAndExactMainGreen: Bool
    }

    public struct CurrentExactMainClosure: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let pullRequestNumber: Int
        public let baseRevision: String
        public let reviewedHeadRevision: String
        public let reviewedHeadTree: String
        public let reviewedHeadOrderedParentOIDs: [String]
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedMergeParentOIDs: [String]
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let historyPreservingTwoParentMergeObserved: Bool
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
        public let pullRequestRunID: Int
        public let pullRequestRunNumber: Int
        public let pullRequestRunAttempt: Int
        public let pullRequestCheckSuiteID: Int
        public let pullRequestConclusion: String
        public let pullRequestPreviousAttemptURL: String?
        public let pullRequestActiveRootJobID: Int
        public let pullRequestActiveRootJobConclusion: String
        public let pullRequestReviewedMainJobID: Int
        public let pullRequestReviewedMainJobConclusion: String
        public let pullRequestReviewedMainJobStepCount: Int
        public let pullRequestActionsArtifactCount: Int
        public let exactMainRunID: Int
        public let exactMainRunNumber: Int
        public let exactMainRunAttempt: Int
        public let exactMainCheckSuiteID: Int
        public let exactMainConclusion: String
        public let exactMainActiveRootJobID: Int
        public let exactMainReviewedMainJobID: Int
        public let exactMainActiveRootJobConclusion: String
        public let exactMainReviewedMainJobConclusion: String
        public let exactMainActionsArtifactCount: Int
        public let retirementObservationSource: FileIdentity
        public let retirementObservationTest: FileIdentity
    }

    public struct VerificationRequest: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let objectRole: String
        public let literalCommitOID: String
        public let expectedTreeOID: String
        public let expectedOrderedParentOIDs: [String]
    }

    public struct CommitHeaderContract: Codable, Equatable, Sendable {
        public let repositoryObjectFormat: String
        public let literalOIDEncoding: String
        public let literalOIDCharacterCount: Int
        public let uppercaseOIDAccepted: Bool
        public let abbreviatedOIDAccepted: Bool
        public let symbolicRefAccepted: Bool
        public let refNameAccepted: Bool
        public let ancestryOperatorAccepted: Bool
        public let replaceObjectsDisabledEnvironment: String
        public let lazyFetchDisabledEnvironment: String
        public let replacementRefsMayAffectObservation: Bool
        public let graftsFileMayContributeTopologyFacts: Bool
        public let localeEnvironment: String
        public let fixedGitExecutablePath: String
        public let fixedBashExecutablePath: String
        public let fixedXcrunExecutablePath: String
        public let fixedEnvExecutablePath: String
        public let exactFixedToolPaths: [String]
        public let everyFixedToolMustBeExecutableRegularNonlink: Bool
        public let classifierSourcePath: String
        public let classifierRequiredImports: [String]
        public let classifierCompileArgumentVector: [String]
        public let classifierPrivateExecutableLeaf: String
        public let classifierSourceIdentityAdmissionRequired: Bool
        public let exactToolchainOverrideEnvironmentKeysRequiredUnset: [String]
        public let compilerAndClassifierUseEmptyEnvironment: Bool
        public let exactCleanEnvironmentAssignments: [String]
        public let compilerOrImportFailureResultCode: String
        public let classifierExecutionArgumentPrefix: [String]
        public let classifierCleanEnvironmentArgumentVectorPrefix: [String]
        public let classifierExactArgumentRoles: [String]
        public let topologyFactSource: String
        public let exactObjectPreprobeArgumentVector: [String]
        public let exactObjectPreprobeOutputGrammar: String
        public let exactGitObjectTypeTokens: [String]
        public let exactObjectPreprobeInputGrammar: String
        public let objectPreprobeInputUsesBashBuiltinPrintf: Bool
        public let objectPreprobeStatusRequired: Int
        public let maximumObjectPreprobeOutputByteCount: Int
        public let exactRepositoryFormatObservationArgumentVector: [String]
        public let exactRepositoryFormatSuccessOutput: String
        public let exactRawCatFileArgumentVector: [String]
        public let objectTypeRequired: String
        public let maximumCommitObjectByteCount: Int
        public let classifierBoundedReadLimitByteCount: Int
        public let maximumVerificationRequestCount: Int
        public let maximumParentCountPerCommit: Int
        public let classifierActualParsedParentCountBound: String
        public let requestRoleASCIIGrammar: String
        public let maximumRequestRoleUTF8ByteCount: Int
        public let rawCatFileContentInvocationCountPerParsedObject: Int
        public let exactCatFileArgumentRoles: [String]
        public let catFileStdoutPipedDirectlyToClassifierStdin: Bool
        public let filesystemCapturePathCount: Int
        public let classifierReadsLogicalStandardInputStreamOnceToEOF: Bool
        public let classifierDrainsStandardInputToEOFOnEveryNonReadFailureOutcome:
            Bool
        public let classifierRetriesInterruptedStandardInputReads: Bool
        public let classifierPerformsNoFilesystemOperation: Bool
        public let classifierGitObjectHashPrefixFormula: String
        public let classifierComputesSHA1OverPrefixAndExactWithinCapAdvertisedInputBytes: Bool
        public let classifierComputedOIDMustEqualLiteralOID: Bool
        public let classifierWithinCapExactAdvertisedInputByteArrayIsSoleHashAndParseSource: Bool
        public let classifierParsesBytesWithoutUTF8Decoding: Bool
        public let classifierUsesDarwinProcPIDInfoFDInventory: Bool
        public let classifierMaximumFDInventoryByteCount: Int
        public let classifierMaximumFDClosurePassCount: Int
        public let classifierFDInventoryAllocationSlackRecordCount: Int
        public let classifierFDInitialSizeUsesCheckedCapMinusSlackArithmetic:
            Bool
        public let classifierFDFilledSizeMustBeStrictlyBelowCapacity: Bool
        public let classifierFinalSnapshotMustBeCompleteAndExactlyFD012: Bool
        public let classifierFDInventoryRequiresNonnegativeMultipleOfStride:
            Bool
        public let classifierRejectsNegativeEnumeratedFD: Bool
        public let classifierClosesEveryEnumeratedDescriptorAtOrAbove: Int
        public let classifierAcceptedCloseResults: [String]
        public let classifierRequiresNoFDAtOrAbove3FixedPoint: Bool
        public let classifierFinalFDSet: [Int]
        public let classifierFDClosureClaimAppliesOnlyAtFinalSnapshot: Bool
        public let classifierIsSingleThreaded: Bool
        public let classifierInstallsSignalHandler: Bool
        public let classifierReadsRawBytesFromDarwinFD0AfterClosure: Bool
        public let classifierHasNoAdditionalStdinPipeWriterAtOrAboveFD3: Bool
        public let exactPipelineStatusCount: Int
        public let pipelineRunsUnderTemporarilyDisabledErrexit: Bool
        public let pipelineStatusesCapturedImmediatelyBeforeErrexitRestore: Bool
        public let gitNonzeroHasPrecedenceOverClassifierStatus: Bool
        public let classifierStdoutByteCount: Int
        public let classifierStderrByteCount: Int
        public let gitCatFileStderrPublished: Bool
        public let gitCatFileStderrSink: String
        public let exactTextCaptureStatusTrailerGrammar: String
        public let textCapturePreservesTerminalLFBeforeTrailerRemoval: Bool
        public let batchPreprobePipelineStatusCount: Int
        public let exactClassifierExitMappings: [ClassifierExitMapping]
        public let unknownClassifierExitMapsToObservationFailure: Bool
        public let compilerInvocationCount: Int
        public let compilerBaseEnvironmentKey: String
        public let compilerBaseAdmissionContract: String
        public let compilerBaseMaximumUTF8ByteCount: Int
        public let compilerBasePathGrammar: String
        public let compilerBaseRejectsLFCRAndControlBytes: Bool
        public let everyFilesystemPathPassedAsOneQuotedArgument: Bool
        public let compilerUmask: String
        public let compilerRootCreationArgumentVector: [String]
        public let compilerRootAdmissionArgumentVector: [String]
        public let compilerRootAdmissionOutputGrammar: String
        public let compilerRootMode: String
        public let compilerOutputLeaf: String
        public let compilerOutputInitiallyAbsentAndNonlink: Bool
        public let compilerStatusRequired: Int
        public let compilerStdoutByteCount: Int
        public let compilerStderrByteCount: Int
        public let compilerPrivateLifecycleContract: String
        public let compilerPrivateArtifactsPublishedOrEvidence: Bool
        public let compilerLauncherCleanupInvocationCount: Int
        public let classifierExecutableAdmissionRequired: Bool
        public let classifierExecutableMustBePrivateRegularNonlink: Bool
        public let classifierSelfTestRequiredBeforeRawObjectPipeline: Bool
        public let classifierSelfTestArgumentVector: [String]
        public let classifierSelfTestUsesEmptyStandardInput: Bool
        public let classifierSelfTestStandardInputSource: String
        public let classifierSelfTestConstructsVectorInternally: Bool
        public let classifierSelfTestPayloadBase64: String
        public let classifierSelfTestPayloadByteCount: Int
        public let classifierSelfTestGitObjectOID: String
        public let classifierSelfTestExpectedExitStatus: Int
        public let classifierSelfTestOutputByteCount: Int
        public let classifierSelfTestImmediatelyFollowsExecutableAdmission: Bool
        public let rawClassifierInvocationsRequireSuccessfulSelfTest: Bool
        public let noBuildOrUntrustedProcessBetweenSelfTestAndRawInvocations:
            Bool
        public let interveningBuildInvocationCount: Int
        public let allRequestPreprobesCompleteBeforeAnyClassifierInvocation:
            Bool
        public let exactPreprobeGuardPhaseRange: [Int]
        public let exactRawClassifierGuardPhaseRange: [Int]
        public let preprobeFailureRawClassifierInvocationCount: Int
        public let rawStageRequiresEveryRequestAvailableCommitWithinCap: Bool
        public let allEligibleClassifierOutcomesCollectedBeforeSelection: Bool
        public let globalFailureSelectionOrder: String
        public let stderrPublished: Bool
        public let commitHeaderEndsAtFirstEmptyLine: Bool
        public let commitMessageParsed: Bool
        public let treeHeaderMustBeFirst: Bool
        public let exactTreeHeaderCount: Int
        public let parentHeadersMustBeContiguousImmediatelyAfterTree: Bool
        public let parentHeaderOrderIsSemantic: Bool
        public let treeOrParentHeaderPermittedAfterOtherHeader: Bool
        public let treeAndParentValuesRequireLiteralLowercase40Hex: Bool
        public let signedHeaderContinuationBeginsWithOneSpace: Bool
        public let exactHeadersPermittingContinuationLines: [String]
        public let repeatedGPGSigHeaderAccepted: Bool
        public let repeatedGPGSigSHA256HeaderAccepted: Bool
        public let repeatedMergetagHeaderAccepted: Bool
        public let emptySignedContinuationPayloadAccepted: Bool
        public let signedHeaderContinuationContributesTopologyFacts: Bool
        public let unattachedContinuationAccepted: Bool
        public let carriageReturnAccepted: Bool
        public let NULAccepted: Bool
        public let exactHeaderByteGrammar: String
        public let wholeObjectNULPolicy: String
        public let carriageReturnPolicy: String
        public let repositoryNativeSHA1CompatibilityPurpose: String
        public let SHA1ClaimsCollisionResistance: Bool
        public let SHA1ClaimsAuthenticity: Bool
        public let SHA1ClaimsSignatureValidity: Bool
        public let SHA1ClaimsTopologyTrustWithoutTreeAndParents: Bool
        public let signedHeaderHandlingIsGrammarOnly: Bool
        public let SHA256FixtureDigestPurpose: String
        public let futureDualObjectFormatSupportInV1: Bool
        public let rawHeaderMustBeWellFormedBeforeSemanticComparison: Bool
        public let expectedTreeComparedByExactBytes: Bool
        public let expectedOrderedParentsComparedByExactBytes: Bool
        public let topologyHistoryTraversalInvocationCount: Int
        public let mergeBaseInvocationCount: Int
        public let revListInvocationCount: Int
        public let refResolutionInvocationCount: Int
        public let forbiddenTopologyMechanismNames: [String]
    }

    public struct GuardResultMapping: Codable, Equatable, Sendable {
        public let phaseOrdinal: Int
        public let guardID: String
        public let resultCode: String
    }

    public struct ClassifierExitMapping: Codable, Equatable, Sendable {
        public let exitStatus: Int
        public let resultCode: String
        public let firstFailedGuardID: String?
    }

    public struct ResultRecordNullabilityMapping:
        Codable,
        Equatable,
        Sendable
    {
        public let resultCode: String
        public let firstFailedGuardIDIsNull: Bool
        public let missingObjectRoleIsNonNull: Bool
    }

    public struct ResultClassificationContract:
        Codable,
        Equatable,
        Sendable
    {
        public let exactOrderedResultCodes: [String]
        public let successResultCode: String
        public let invalidInvocationResultCode: String
        public let verifierUnavailableResultCode: String
        public let objectUnavailableResultCode: String
        public let objectNotCommitResultCode: String
        public let objectUnsupportedResultCode: String
        public let repositoryUnsupportedResultCode: String
        public let observationFailedResultCode: String
        public let malformedHeaderResultCode: String
        public let topologyMismatchResultCode: String
        public let firstFailureWins: Bool
        public let exactClassificationPrecedence: [String]
        public let exactGuardResultMappings: [GuardResultMapping]
        public let phaseMajorThenRequestOrdinalMinorFirstFailureOrder: Bool
        public let invalidInvocationRejectedBeforeGit: Bool
        public let objectUnavailableRequiresPositiveMissingObservationForLiteralOID:
            Bool
        public let mismatchRequiresAvailableCommitAndSuccessfulHeaderParse: Bool
        public let noncommitNeverClassifiedAsObjectUnavailable: Bool
        public let malformedNeverClassifiedAsTopologyMismatch: Bool
        public let toolOrTransportFailureNeverClassifiedAsObjectUnavailable: Bool
        public let fixedToolAdmissionFailureResultCode: String
        public let unsupportedOrNULObjectNeverClassifiedAsTopologyMismatch: Bool
        public let rawDiagnosticPublished: Bool
        public let unknownFailureFailsClosed: Bool
    }

    public struct GitHubDepthTwoMultiWantMatrixCase:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let caseID: String
        public let fetchDepth: Int
        public let explicitWantOIDs: [String]
        public let suppliedRevisionToken: String
        public let verificationRequests: [VerificationRequest]
        public let availableObjectRoles: [String]
        public let executionKind: String
        public let privateGitRecipeID: String?
        public let shallowState: String
        public let injectedCondition: String
        public let legacyPorcelainAncestryProbeExpectedToResolve: Bool
        public let legacyPorcelainAncestryProbeExecuted: Bool
        public let legacyPorcelainProbeCommandContract: String?
        public let legacyPorcelainProbeRevspec: String?
        public let legacyPorcelainProbeMayContributeTopologyFacts: Bool
        public let rawCommitHeadersExpectedSufficient: Bool
        public let passedGuardIDs: [String]
        public let expectedResultCode: String?
        public let expectedFirstFailedGuardID: String?
        public let expectedMissingObjectRole: String?
        public let expectedClassifierExitStatus: Int?
        public let mutuallyExclusiveDualResultCode: String
        public let syntheticFixture: SyntheticFixtureContract?
    }

    public struct PrivateGitConstructionRecipe:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let recipeID: String
        public let recipeKind: String
        public let exactArgumentVectors: [[String]]
        public let exactExpectedStatuses: [Int]
        public let exactSemanticOutputs: [String]
        public let exactStandardInputDescriptors: [String]
        public let exactStdoutBase64: [String?]
        public let exactSourceObjectOIDs: [String]
        public let exactFixtureIDs: [String]
        public let exactSourceAvailabilityPreprobeArgumentVector: [String]
        public let exactSourceAvailabilityExpectedLines: [String]
        public let noNetwork: Bool
        public let usesOnlyPrivateTemporaryRepositories: Bool
        public let historicalEvidenceClaimedDynamicallyReplayed: Bool
    }

    public struct PrivateGitObjectFixture: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let fixtureID: String
        public let objectType: String
        public let fixture: SyntheticFixtureContract
    }

    public struct HistoricalGitHubShallowEvidence:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let evidenceID: String
        public let fetchDepth: Int
        public let explicitWantOIDs: [String]
        public let literalCommitOID: String
        public let rawHeaderTreeOID: String
        public let rawHeaderOrderedParentOIDs: [String]
        public let availableReferencedParentOIDs: [String]
        public let absentReferencedParentOIDs: [String]
        public let shallowBoundaryOIDs: [String]
        public let observedFact: String
        public let exactLegacyProbeCommandContract: String?
        public let exactLegacyProbeRevspec: String?
        public let legacyProbeResolved: Bool?
        public let rawHeadersProvidedTopologyFact: Bool
        public let diagnosticEvidenceOnly: Bool
        public let dynamicallyReplayedByFutureMatrix: Bool
    }

    public struct PredicateProofPair: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let checkID: String
        public let guardID: String
        public let positiveWitnessID: String
        public let negativeWitnessID: String
        public let predicatesAreDisjoint: Bool
        public let predicatesAreExhaustive: Bool
    }

    public struct PredicateWitness: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let witnessID: String
        public let guardID: String
        public let predicateValue: Bool
        public let witnessKind: String
        public let classifierCaseID: String?
        public let helperParserCaseID: String?
        public let privateGitMatrixCaseID: String?
        public let staticCheckID: String?
        public let verifiedBaselineID: String?
        public let passedGuardIDs: [String]
        public let expectedResultCode: String?
        public let expectedFirstFailedGuardID: String?
        public let syntheticOIDClaimedFetched: Bool
    }

    public struct VerifiedEndToEndBaseline: Codable, Equatable, Sendable {
        public let baselineID: String
        public let executionKind: String
        public let requestVector: [VerificationRequest]
        public let privateRepositoryConstructionRecipe: String
        public let exactPrivateRepositoryInitArgumentVector: [String]
        public let exactPrivateRepositoryInitStatus: Int
        public let exactCommitWriteArgumentVector: [String]
        public let exactCommitWriteStatus: Int
        public let exactCommitWriteStdoutBase64: String
        public let constructionUsesEmptyEnvironmentAndNoNetwork: Bool
        public let commitFixture: SyntheticFixtureContract
        public let exactRepositoryFormatStatus: Int
        public let exactRepositoryFormatStdoutBase64: String
        public let exactBatchPreprobeStatus: Int
        public let exactBatchPreprobeStdoutBase64: String
        public let exactRawGitArgumentVector: [String]
        public let exactClassifierArgumentVector: [String]
        public let expectedClassifierExitStatus: Int
        public let expectedResultCode: String
        public let expectedFirstFailedGuardID: String?
        public let expectedMissingObjectRole: String?
        public let passedGuardIDs: [String]
        public let deterministicAndDynamicallyExecutable: Bool
    }

    public struct StaticSourceContractCheck:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let checkID: String
        public let guardID: String
        public let predicateValue: Bool
        public let passedGuardIDs: [String]
        public let expectedResultCode: String
        public let futureComponentPath: String
        public let exactSymbolOrSourceAnchor: String
        public let exactInvariantOrBranchAnchor: String
        public let proofMethod: String
    }

    public struct ClassifierDirectFixtureCase:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let caseID: String
        public let guardID: String
        public let predicateValue: Bool
        public let passedGuardIDs: [String]
        public let fixture: SyntheticFixtureContract
        public let exactArgumentVector: [String]
        public let harnessSetupContract: String?
        public let expectedExitStatus: Int
        public let expectedResultCode: String
        public let expectedFirstFailedGuardID: String?
        public let dynamicallyExecutable: Bool
    }

    public struct HelperParserFixtureCase: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let caseID: String
        public let guardID: String
        public let predicateValue: Bool
        public let observationKind: String
        public let passedGuardIDs: [String]
        public let repositoryArgument: String
        public let requestVector: [VerificationRequest]
        public let savedGitStatus: Int?
        public let savedClassifierStatus: Int?
        public let boundedObservationStdoutBase64: String
        public let expectedResultCode: String?
        public let expectedFirstFailedGuardID: String?
    }

    public struct SyntheticFixtureContract: Codable, Equatable, Sendable {
        public let constructionKind: String
        public let payloadEncoding: String
        public let payloadRecipe: String
        public let payloadByteCount: Int
        public let payloadSHA256: String
        public let literalObjectOID: String
        public let privateRepositoryConstructionAPI: String
        public let objectWrittenIntoPrivateRepository: Bool
        public let literalOIDRecomputedAndRequiredEqualBeforeUse: Bool
    }

    public struct SanitizedRecordContract: Codable, Equatable, Sendable {
        public let schemaID: String
        public let schemaVersion: Int
        public let exactRequiredFieldNames: [String]
        public let firstFailedGuardIDField: String
        public let shallowStateField: String
        public let missingObjectRoleField: String
        public let exactShallowStateValues: [String]
        public let exactAllowedFirstFailedGuardIDs: [String]
        public let missingObjectRoleASCIIGrammar: String
        public let maximumMissingObjectRoleUTF8ByteCount: Int
        public let missingObjectRoleMustEqualOneSubmittedPrevalidatedRole: Bool
        public let shallowStateObservationCommand: String
        public let exactShallowStateObservationArgumentVector: [String]
        public let shallowStateObservationStatusRequired: Int
        public let maximumShallowStateObservationOutputByteCount: Int
        public let shallowStateTrueOutput: String
        public let shallowStateFalseOutput: String
        public let shallowStateFailureValue: String
        public let shallowStateIsDiagnosticOnly: Bool
        public let shallowStateObservationFailureChangesResultCode: Bool
        public let shallowStateObservationFailureChangesFirstFailedGuardID:
            Bool
        public let shallowStateObservationMaximumInvocationCount: Int
        public let shallowStateObservationRetryCount: Int
        public let shallowStateObservationInvocationCountIsZeroOrOne: Bool
        public let shallowStateObservationExactEligibilityAndSequence: String
        public let shallowStateNonzeroOrMalformedMapsToUnavailableExactlyOnce:
            Bool
        public let shallowStateObservationFailureAuthorizesRetry: Bool
        public let firstFailedGuardIDIsNullIfAndOnlyIfResultVerified: Bool
        public let missingObjectRoleIsNonNullIfAndOnlyIfResultObjectUnavailable:
            Bool
        public let exactResultRecordNullabilityMappings:
            [ResultRecordNullabilityMapping]
        public let objectIDsPublished: Bool
        public let repositoryPathsPublished: Bool
        public let refsPublished: Bool
        public let rawHeadersPublished: Bool
        public let rawStandardErrorPublished: Bool
        public let resultUsesExactTaxonomy: Bool
        public let canonicalSortedJSONRequired: Bool
        public let exactCanonicalJSONWireTemplate: String
        public let maximumCanonicalJSONByteCount: Int
        public let maximumLineByteCountIncludingTerminalLF: Int
        public let exactRecordCount: Int
        public let exactRecordCountScope: String
        public let admittedWritableStdoutRequiredForProjection: Bool
        public let projectionFailureValidCompleteRecordCount: Int
        public let projectionFailureMayLeavePhysicalPartialPrefix: Bool
        public let projectionFailureIsExternalTransportFailure: Bool
        public let projectionFailureAuthorizesTopologyRetry: Bool
        public let exitStatusesApplyOnlyAfterSuccessfulProjection: Bool
        public let gateAndV2CaptureAndValidateHelperRecordBeforeProjection: Bool
        public let successExitStatus: Int
        public let nonSuccessExitStatus: Int
        public let terminalLFRequired: Bool
    }

    public struct CurrentAuthorityPatch: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let modifiedExistingPathCount: Int
        public let addedPathCount: Int
        public let soleAuthorityTestClassName: String
        public let soleAuthorityTestMethodName: String
        public let soleAuthorityTestExpectedStartCount: Int
        public let soleAuthorityTestExpectedPassCount: Int
        public let expectedActiveRootLatinTestCount: Int
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedEmbeddedProvenanceRecordCount: Int
        public let implementationIncluded: Bool
        public let mechanicsIncluded: Bool
        public let canonicalIdentityConstantsIncludedBeforeIndependentReview: Bool
    }

    public struct SharedHelperAPIContract: Codable, Equatable, Sendable {
        public let sourcedFunctionName: String
        public let flatArgumentGrammar: String
        public let ordinalTokensAccepted: Bool
        public let requestOrdinalsDerivedFromPosition: Bool
        public let canonicalDecimalCountsRequired: Bool
        public let exactArgumentConsumptionRequired: Bool
        public let surplusArgumentsAccepted: Bool
        public let maximumRequestCount: Int
        public let maximumParentCount: Int
        public let exactAllowedAmbientInputNames: [String]
        public let stdoutRecordCount: Int
        public let stdoutGrammar: String
        public let stderrPublished: Bool
        public let successReturnStatus: Int
        public let everyEmittedNonSuccessReturnStatus: Int
        public let gateAndEveryFutureV2UseSameFunction: Bool
    }

    public struct BootstrapTrustContract: Codable, Equatable, Sendable {
        public let repositoryArgumentGrammar: String
        public let canonicalRepositoryRootRequired: Bool
        public let cleanExactHEADRequired: Bool
        public let exactTrackedPaths: [PathContract]
        public let everyPathMustBeRegularNonlink: Bool
        public let exactWorktreeHashArgumentVectorPattern: [String]
        public let worktreeBlobMustEqualExactIndexBlob: Bool
        public let admissionPrecedesHelperSourceAndClassifierCompile: Bool
        public let gateMayDuplicateOnlyMinimalSourceAdmission: Bool
        public let duplicatedTopologyParserCount: Int
        public let everyFutureV2PerformsEquivalentAdmission: Bool
        public let classifierCompiledFromValidatedAbsolutePath: Bool
        public let canonicalRepositoryRootWorkingDirectoryRequired: Bool
        public let hostileConcurrentSameEUIDMutationInScope: Bool
    }

    public struct FutureImplementationPatch: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let modifiedExistingPathCount: Int
        public let addedPathCount: Int
        public let classifierSourcePath: String
        public let sharedLibraryPath: String
        public let sharedLibraryTestPath: String
        public let gateMustSourceSharedLibrary: Bool
        public let everyFutureLiveV2GateMustSourceSharedLibrary: Bool
        public let everyFutureLiveV2LauncherMustSourceSharedLibrary: Bool
        public let privateLiveAdmissionTopologyParserCountAfterImplementation:
            Int
        public let preservedRetiredV1ParserBytesExcludedFromLiveDuplicateCount:
            Bool
        public let workflowGateInvocationLiteral: String
        public let workflowStepShellLiteral: String
        public let workflowStepAndJobCountsPreserved: Bool
        public let gateRequiresPrivilegedModeBeforeSourcingSharedLibrary: Bool
        public let privilegedModeShellOptionToken: String
        public let gatePrivilegedModeAdmissionLiteral: String
        public let helperFirstExecutableLineLiteral: String
        public let helperSecondExecutableLineLiteral: String
        public let helperDefinesNothingBeforePrivilegedModeAdmission: Bool
        public let gatePrivilegedAdmissionIsFirstExecutableStatement: Bool
        public let gateSecondExecutableStatementLiteral: String
        public let gateSetAndOptionsFollowPrivilegedAdmissionAndUnset: Bool
        public let everyChildBashParseArgumentPrefix: [String]
        public let preToolBootstrapUsesOnlyBashBuiltins: Bool
        public let preToolBootstrapReliesOnExactWorkingDirectory: Bool
        public let preToolBootstrapMayInvokeDirname: Bool
        public let innerBashGateInvocationForbidden: Bool
        public let matrixTestInvocationLiteral: String
        public let matrixTestFirstExecutableStatementLiteral: String
        public let matrixTestSecondExecutableStatementLiteral: String
        public let futureV2LauncherInvocationLiteralPattern: String
        public let futureV2LauncherFirstExecutableStatementLiteral: String
        public let futureV2LauncherSecondExecutableStatementLiteral: String
        public let matrixTestInvokedWithPrivilegedBash: Bool
        public let everyFutureV2LauncherInvokedWithPrivilegedBash: Bool
        public let matrixTestInvokedOnlyFromAdmittedPrivilegedGate: Bool
        public let separateActionsStepRequiresSamePrivilegedCustomShell: Bool
        public let sharedHelperAPIContract: SharedHelperAPIContract
        public let bootstrapTrustContract: BootstrapTrustContract
        public let testMayCreateOnlyPrivateTemporaryGitRepositories: Bool
        public let testMayUseNetwork: Bool
        public let liveTestMustExerciseExactMatrixCaseIDs: [String]
        public let pureSourceContractMustExerciseExactMatrixCaseIDs: [String]
        public let exactPredicateProofGuardIDs: [String]
        public let classifierDirectFixtureCaseIDs: [String]
        public let historicalEvidenceDynamicallyReplayedByFutureMatrix: Bool
        public let exactMainGreenRequiredBeforeV2MeasurementAuthority: Bool
        public let implementationIncludedInCurrentAuthorityPatch: Bool
    }

    public struct PreservationContract: Codable, Equatable, Sendable {
        public let exactRetiredV1Paths: [String]
        public let retiredV1PathCount: Int
        public let retiredV1LaunchersMustRemainByteIdentical: Bool
        public let retiredV1AuthoritiesMustRemainByteIdentical: Bool
        public let retiredV1ObservationsMustRemainByteIdentical: Bool
        public let retiredRun160RecordRemainsTerminal: Bool
        public let retiredRun160OpportunityRemainsRetired: Bool
        public let existingV1LaunchersRetrofittedToSharedLibrary: Bool
        public let packageManifestMutationAuthorized: Bool
        public let packageLockMutationAuthorized: Bool
        public let dependencyResolutionAuthorized: Bool
    }

    public struct PhaseABranchTransition: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let state: String
        public let measurementOutcome: String?
        public let pinRelation: String?
        public let prerequisite: String
        public let exactAllowedNextAuthorityOrActionIDs: [String]
        public let terminalAbsentNewAuthority: Bool
        public let retryRerunReplacementOrImplicitCanaryAuthorized: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let currentExactMainClosureEstablished: Bool
        public let retiredRun160ClosureEstablished: Bool
        public let run160FailureCauseRemainsInference: Bool
        public let currentPatchAddsOnlyPureAuthorityPair: Bool
        public let futureImplementationScopeFrozen: Bool
        public let futureImplementationMayProceedOnlyAfterAuthorityExactMainGreen:
            Bool
        public let filesystemReadPerformed: Bool
        public let filesystemWritePerformed: Bool
        public let processExecutionPerformed: Bool
        public let gitExecutionPerformed: Bool
        public let networkExecutionPerformed: Bool
        public let modelExecutionPerformed: Bool
        public let leaseExecutionPerformed: Bool
        public let verifierImplementationPerformed: Bool
        public let verifierMechanicsPerformed: Bool
        public let v2MeasurementAuthorityEstablished: Bool
        public let v2MeasurementMechanicsPerformed: Bool
        public let v2MeasurementObservationEstablished: Bool
        public let fixtureIdentityEstablished: Bool
        public let repeatBuildDeterminismEstablished: Bool
        public let currentPinMatchEstablished: Bool
        public let currentPinMismatchEstablished: Bool
        public let pinRepairAuthorized: Bool
        public let pinRepairPerformed: Bool
        public let confirmationAuthorized: Bool
        public let confirmationPerformed: Bool
        public let realCanaryAuthorized: Bool
        public let realCanaryPerformed: Bool
        public let retryOrRerunAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let retiredRun160Closure: RetiredRun160Closure
    public let currentExactMainClosure: CurrentExactMainClosure
    public let commitHeaderContract: CommitHeaderContract
    public let resultClassificationContract: ResultClassificationContract
    public let historicalGitHubShallowEvidence:
        [HistoricalGitHubShallowEvidence]
    public let githubDepthTwoMultiWantMatrix:
        [GitHubDepthTwoMultiWantMatrixCase]
    public let privateGitConstructionRecipes: [PrivateGitConstructionRecipe]
    public let privateGitObjectFixtures: [PrivateGitObjectFixture]
    public let verifierPredicateProofPairs: [PredicateProofPair]
    public let verifierPredicateWitnesses: [PredicateWitness]
    public let verifiedEndToEndBaseline: VerifiedEndToEndBaseline
    public let classifierDirectFixtureMatrix: [ClassifierDirectFixtureCase]
    public let helperParserFixtureMatrix: [HelperParserFixtureCase]
    public let staticSourceContractRegistry: [StaticSourceContractCheck]
    public let sanitizedRecordContract: SanitizedRecordContract
    public let currentAuthorityPatch: CurrentAuthorityPatch
    public let futureImplementationPatch: FutureImplementationPatch
    public let preservationContract: PreservationContract
    public let orderedPhaseASequence: [String]
    public let exactPhaseABranchTransitions: [PhaseABranchTransition]
    public let authorityCeiling: AuthorityCeiling
    public let status: String

    public static let canonicalByteCount = 410_281
    public static let canonicalSHA256 =
        "58409182a2be35e7d7874c0b672d4dbf53ab4bd0abc5574cbd598ad8849197d2"

    public static let frozenV1: Self = {
        let mechanicsMerge = request(
            1,
            "exact_revision",
            "5623872afda1895630ba0eacdfab76961c5e755b",
            "9dd884bfe5b520a67c2944d8f8f79851a714519e",
            [
                "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
                "f5db7101cf3538daae103ba56601a509ad8bad80",
            ])
        let mechanicsHead = request(
            2,
            "mechanics_head",
            "f5db7101cf3538daae103ba56601a509ad8bad80",
            "9dd884bfe5b520a67c2944d8f8f79851a714519e",
            ["fe0ad36a9163aaa0e03478f5556dfb34b70e24e7"])
        let authorityMerge = request(
            3,
            "authority_merge",
            "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
            "9b8a784e605967141f159a5f8c953a0096cf1f8d",
            [
                "75b14056b75e8af6af0c070453f7ef14ac10a063",
                "690b5047e553d6869e3dc7c97ad858a349175b2c",
            ])
        let authorityBaseMerge = request(
            4,
            "authority_base_merge",
            "75b14056b75e8af6af0c070453f7ef14ac10a063",
            "c3c325a0b24513030fd3e5228926094371f7a3a4",
            [
                "3ad8087ed6e403ba81f46bba97ceb5d440979e0a",
                "e1f9fa486ee5fadccc62cb795fea11fbf85ff394",
            ])
        let authorityHead = request(
            4,
            "authority_authoring_head",
            "690b5047e553d6869e3dc7c97ad858a349175b2c",
            "9b8a784e605967141f159a5f8c953a0096cf1f8d",
            ["75b14056b75e8af6af0c070453f7ef14ac10a063"])
        let currentMerge = request(
            1,
            "exact_revision",
            "6a811d3029bdb77e038750694fbf10eec0f358f8",
            "2d07d669ce804433f2c6fd15ca3ccca52f53bcf6",
            [
                "5623872afda1895630ba0eacdfab76961c5e755b",
                "57f4264dd865a47766e27a9dbc06a82dd1fbfe11",
            ])
        let currentHead = request(
            2,
            "retirement_observation_head",
            "57f4264dd865a47766e27a9dbc06a82dd1fbfe11",
            "2d07d669ce804433f2c6fd15ca3ccca52f53bcf6",
            ["5623872afda1895630ba0eacdfab76961c5e755b"])
        let run160Wants = [
            "5623872afda1895630ba0eacdfab76961c5e755b",
            "75b14056b75e8af6af0c070453f7ef14ac10a063",
        ]
        let currentWants = [
            "6a811d3029bdb77e038750694fbf10eec0f358f8",
            "75b14056b75e8af6af0c070453f7ef14ac10a063",
        ]
        let privateObjectFixtures = (1 ... 9).map {
            privateGraphFixture(ordinal: $0)
        }
        let privateTree = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
        let privateBase = request(
            1, "private_base", privateObjectFixtures[0].fixture.literalObjectOID,
            privateTree, [])
        let privateAuthorityHead = request(
            2, "private_authority_head",
            privateObjectFixtures[1].fixture.literalObjectOID, privateTree, [])
        let privateAuthorityMerge = request(
            3, "private_authority_merge",
            privateObjectFixtures[2].fixture.literalObjectOID, privateTree,
            [privateBase.literalCommitOID,
             privateAuthorityHead.literalCommitOID])
        let privateMechanicsHead = request(
            4, "private_mechanics_head",
            privateObjectFixtures[3].fixture.literalObjectOID, privateTree,
            [privateAuthorityMerge.literalCommitOID])
        let privateMechanicsMerge = request(
            5, "private_mechanics_merge",
            privateObjectFixtures[4].fixture.literalObjectOID, privateTree,
            [privateAuthorityMerge.literalCommitOID,
             privateMechanicsHead.literalCommitOID])
        let privateCurrentHead = request(
            6, "private_current_head",
            privateObjectFixtures[5].fixture.literalObjectOID, privateTree,
            [privateMechanicsMerge.literalCommitOID])
        let privateSignedMerge = request(
            7, "private_signed_merge",
            privateObjectFixtures[6].fixture.literalObjectOID, privateTree,
            [privateMechanicsMerge.literalCommitOID,
             privateCurrentHead.literalCommitOID])
        let privateUnrelatedOID =
            privateObjectFixtures[7].fixture.literalObjectOID
        let privateBlobOID = privateObjectFixtures[8].fixture.literalObjectOID
        let privateRun160Wants = [
            privateMechanicsMerge.literalCommitOID,
            privateBase.literalCommitOID,
        ]
        let privateCurrentWants = [
            privateSignedMerge.literalCommitOID,
            privateBase.literalCommitOID,
        ]

        let matrix: [GitHubDepthTwoMultiWantMatrixCase] = [
            matrixCase(
                1,
                "private_github_style_depth2_multi_want_porcelain_fails_raw_headers_verify",
                2,
                privateRun160Wants,
                privateMechanicsMerge.literalCommitOID,
                [rerole(1, "exact_revision", privateMechanicsMerge),
                 rerole(2, "mechanics_head", privateMechanicsHead),
                 rerole(3, "authority_merge", privateAuthorityMerge),
                 rerole(4, "authority_base_merge", privateBase)],
                ["exact_revision", "mechanics_head", "authority_merge", "authority_base_merge"],
                "shallow",
                "mechanics_head_and_authority_merge_are_shallow_boundaries_so_legacy_multi_hop_ancestry_resolution_fails_even_though_their_raw_headers_and_the_referenced_authority_merge_and_authority_base_merge_objects_are_available",
                false,
                true,
                "TOPOLOGY_VERIFIED",
                nil,
                nil),
            matrixCase(
                2,
                "private_github_style_depth2_signed_merge_continuation_headers_verify",
                2,
                privateCurrentWants,
                privateSignedMerge.literalCommitOID,
                [rerole(1, "exact_revision", privateSignedMerge),
                 rerole(2, "retirement_observation_head", privateCurrentHead)],
                ["exact_revision", "retirement_observation_head", "retired_mechanics_merge", "unrelated_proof_want"],
                "shallow",
                "github_gpgsig_header_and_all_space_prefixed_signature_continuation_lines_follow_tree_and_parent_headers",
                false,
                true,
                "TOPOLOGY_VERIFIED",
                nil,
                nil),
            matrixCase(
                3,
                "private_github_style_depth2_additional_unrelated_wants_do_not_change_topology",
                2,
                privateCurrentWants + [
                    privateAuthorityHead.literalCommitOID,
                    privateUnrelatedOID,
                ],
                privateSignedMerge.literalCommitOID,
                [rerole(1, "exact_revision", privateSignedMerge),
                 rerole(2, "retirement_observation_head", privateCurrentHead)],
                ["exact_revision", "retirement_observation_head", "unrelated_authority_want", "unrelated_containment_want"],
                "shallow",
                "two_additional_well_formed_unrelated_wants_are_available_but_are_not_verification_requests",
                false,
                true,
                "TOPOLOGY_VERIFIED",
                nil,
                nil),
            matrixCase(
                4,
                "private_github_style_depth1_required_child_object_unavailable",
                1,
                [privateMechanicsMerge.literalCommitOID],
                privateMechanicsMerge.literalCommitOID,
                [rerole(1, "exact_revision", privateMechanicsMerge),
                 rerole(2, "mechanics_head", privateMechanicsHead)],
                ["exact_revision"],
                "shallow",
                "exact_revision_header_is_available_but_the_separately_required_mechanics_head_object_is_absent",
                false,
                false,
                "TOPOLOGY_OBJECT_UNAVAILABLE",
                "required_object_availability",
                "mechanics_head"),
            matrixCase(
                5,
                "private_github_style_raw_header_names_genuinely_absent_parent_object",
                2,
                privateRun160Wants,
                privateAuthorityMerge.literalCommitOID,
                [
                    rerole(1, "authority_merge", privateAuthorityMerge),
                    rerole(2, "authority_authoring_head", privateAuthorityHead),
                ],
                ["authority_merge", "authority_base_merge"],
                "shallow",
                "authority_merge_raw_header_names_authority_authoring_head_but_that_separately_required_parent_object_is_genuinely_absent",
                false,
                false,
                "TOPOLOGY_OBJECT_UNAVAILABLE",
                "required_object_availability",
                "authority_authoring_head"),
            matrixCase(
                6,
                "well_formed_exact_revision_oid_is_absent",
                2,
                privateRun160Wants,
                "1111111111111111111111111111111111111111",
                [request(1, "exact_revision", "1111111111111111111111111111111111111111", privateTree, privateMechanicsMerge.expectedOrderedParentOIDs)],
                [],
                "shallow",
                "batch_check_positively_reports_missing_for_the_literal_well_formed_oid",
                false,
                false,
                "TOPOLOGY_OBJECT_UNAVAILABLE",
                "required_object_availability",
                "exact_revision"),
            matrixCase(
                7,
                "available_commit_has_reordered_parent_headers",
                0,
                [],
                "32c5e6d59819d83e270bdac42a21017ff6548fc7",
                [request(1, "synthetic_reordered_parent_commit", "32c5e6d59819d83e270bdac42a21017ff6548fc7", mechanicsMerge.expectedTreeOID, mechanicsMerge.expectedOrderedParentOIDs)],
                ["synthetic_reordered_parent_commit"],
                "complete",
                "parsed_ordered_parent_oids_are_mechanics_head_then_authority_merge",
                false,
                true,
                "TOPOLOGY_MISMATCH",
                "ordered_parent_oids_equal_expected",
                nil,
                "pure_source_contract"),
            matrixCase(
                8,
                "available_commit_has_extra_parent_header",
                0,
                [],
                "7c6b88b20b586dadb81de6685ba51cfb9ee1d93c",
                [request(1, "synthetic_extra_parent_commit", "7c6b88b20b586dadb81de6685ba51cfb9ee1d93c", mechanicsMerge.expectedTreeOID, mechanicsMerge.expectedOrderedParentOIDs)],
                ["synthetic_extra_parent_commit"],
                "complete",
                "parsed_ordered_parent_oids_append_unrelated_75b14056_oid",
                false,
                true,
                "TOPOLOGY_MISMATCH",
                "ordered_parent_oids_equal_expected",
                nil,
                "pure_source_contract"),
            matrixCase(
                9,
                "available_commit_has_wrong_tree_oid",
                0,
                [],
                "c0763d20513bfb5a4734df0a30745ae55b5f40bc",
                [request(1, "synthetic_wrong_tree_commit", "c0763d20513bfb5a4734df0a30745ae55b5f40bc", mechanicsMerge.expectedTreeOID, mechanicsMerge.expectedOrderedParentOIDs)],
                ["synthetic_wrong_tree_commit"],
                "complete",
                "parsed_tree_oid_is_9b8a784e605967141f159a5f8c953a0096cf1f8d_instead_of_expected",
                false,
                true,
                "TOPOLOGY_MISMATCH",
                "tree_oid_equals_expected",
                nil,
                "pure_source_contract"),
            matrixCase(
                10,
                "noncommit_object_at_literal_oid",
                2,
                privateCurrentWants + [privateBlobOID],
                privateBlobOID,
                [request(1, "exact_revision", privateBlobOID, privateTree, [])],
                ["exact_revision"],
                "shallow",
                "object_type_probe_returns_blob",
                false,
                false,
                "TOPOLOGY_OBJECT_NOT_COMMIT",
                "required_object_type_commit",
                nil),
            matrixCase(
                11,
                "malformed_header_tree_is_not_first",
                0,
                [],
                "28d89d60036ae440b8a45b54b6661dc6fca60dac",
                [request(1, "synthetic_malformed_header_commit", "28d89d60036ae440b8a45b54b6661dc6fca60dac", mechanicsMerge.expectedTreeOID, [])],
                ["synthetic_malformed_header_commit"],
                "complete",
                "author_header_precedes_tree_header_in_an_object_created_with_literal_malformed_commit_fixture_support",
                false,
                false,
                "TOPOLOGY_HEADER_MALFORMED",
                "tree_header_is_first_and_unique",
                nil,
                "pure_source_contract"),
            matrixCase(
                12,
                "nul_byte_in_commit_object_is_rejected_before_shell_parse",
                0,
                [],
                "69c4a7f67cf2a86ba9c9bdf3c37c4ca1eb824981",
                [request(1, "synthetic_nul_commit", "69c4a7f67cf2a86ba9c9bdf3c37c4ca1eb824981", mechanicsMerge.expectedTreeOID, [])],
                ["synthetic_nul_commit"],
                "complete",
                "raw_byte_count_exceeds_nul_stripped_byte_count",
                false,
                false,
                "TOPOLOGY_OBJECT_UNSUPPORTED",
                "classifier_input_is_nul_free",
                nil,
                "pure_source_contract"),
            matrixCase(
                13,
                "oversized_commit_object_is_rejected_before_raw_content_stream",
                0,
                [],
                "2df897f0b9eb39f944c1b868288d1632a8a81882",
                [request(1, "synthetic_oversized_commit", "2df897f0b9eb39f944c1b868288d1632a8a81882", mechanicsMerge.expectedTreeOID, [])],
                ["synthetic_oversized_commit"],
                "complete",
                "advertised_commit_object_size_exceeds_1048576_bytes",
                false,
                false,
                "TOPOLOGY_OBJECT_UNSUPPORTED",
                "object_size_within_bound",
                nil,
                "pure_source_contract"),
            matrixCase(
                14,
                "invalid_symbolic_ref_token_is_rejected_before_git",
                0,
                [],
                "HEAD",
                [request(1, "exact_revision", "HEAD", mechanicsMerge.expectedTreeOID, mechanicsMerge.expectedOrderedParentOIDs)],
                [],
                "unavailable",
                "negative_fixture_supplies_a_symbolic_ref_instead_of_a_literal_lowercase_40hex_oid",
                false,
                false,
                "TOPOLOGY_INVOCATION_INVALID",
                "literal_commit_oid_is_lowercase_40hex",
                nil,
                "pure_source_contract"),
            matrixCase(
                15,
                "fixed_git_verifier_is_unavailable",
                0,
                [],
                privateMechanicsMerge.literalCommitOID,
                [rerole(1, "exact_revision", privateMechanicsMerge)],
                [],
                "unavailable",
                "fixed_git_executable_admission_fails",
                false,
                false,
                "TOPOLOGY_VERIFIER_UNAVAILABLE",
                "fixed_verifier_tools_admitted",
                nil,
                "pure_source_contract"),
            matrixCase(
                16,
                "cat_file_observation_pipeline_fails",
                0,
                [],
                "a7c2690d6c945956b7c5b97442356665f6ea3279",
                [request(1, "synthetic_corrupted_commit", "a7c2690d6c945956b7c5b97442356665f6ea3279", mechanicsMerge.expectedTreeOID, [])],
                ["synthetic_corrupted_commit"],
                "unavailable",
                "object_was_positively_available_as_commit_but_a_later_cat_file_pipeline_status_is_nonzero",
                false,
                false,
                "TOPOLOGY_OBSERVATION_FAILED",
                "git_cat_file_transport_succeeded",
                nil,
                "pure_source_contract"),
            matrixCase(
                17,
                "replacement_ref_cannot_change_literal_object_topology",
                2,
                privateCurrentWants,
                privateSignedMerge.literalCommitOID,
                [rerole(1, "exact_revision", privateSignedMerge),
                 rerole(2, "retirement_observation_head", privateCurrentHead)],
                ["exact_revision", "retirement_observation_head", "replacement_target"],
                "shallow",
                "a_refs_replace_entry_for_exact_revision_exists_but_every_object_probe_and_cat_file_pass_sets_GIT_NO_REPLACE_OBJECTS_1",
                false,
                true,
                "TOPOLOGY_VERIFIED",
                nil,
                nil),
            matrixCase(
                18,
                "non_sha1_repository_object_format_is_unsupported",
                0,
                [],
                privateMechanicsMerge.literalCommitOID,
                [rerole(1, "exact_revision", privateMechanicsMerge)],
                ["exact_revision"],
                "unavailable",
                "repository_extensions_object_format_observation_is_sha256_instead_of_required_sha1",
                false,
                false,
                "TOPOLOGY_REPOSITORY_UNSUPPORTED",
                "repository_object_format_sha1",
                nil,
                "pure_source_contract"),
        ]
        let privateGitRecipes = matrix.filter {
            $0.executionKind == "live_private_repository"
        }.enumerated().map { index, matrixCase in
            privateGitRecipe(
                ordinal: index + 1,
                matrixCase: matrixCase,
                objectFixtures: privateObjectFixtures,
                replacementSourceOID: privateSignedMerge.literalCommitOID,
                replacementTargetOID: privateMechanicsMerge.literalCommitOID)
        }

        let currentPaths = [
            path(1, ".github/scripts/prime-ci-active-root-quarantine.sh", "M", "100755", "bind_and_parse_the_new_authority_without_running_topology_mechanics"),
            path(2, ".github/workflows/prime-active-root-quarantine.yml", "M", "100644", "parse_and_run_the_sole_pure_authority_test"),
            path(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", "M", "100644", "regenerate_embedded_provenance_for_the_exact_authority_tree"),
            path(4, "Sources/PrimeCore/PrimeExactRevisionTopologyVerifierAuthority.swift", "A", "100644", "pure_foundation_codable_topology_verifier_authority"),
            path(5, "Tests/PrimeCoreTests/PrimeExactRevisionTopologyVerifierAuthorityTests.swift", "A", "100644", "sole_pure_canonical_exhaustive_recursive_mutation_test"),
        ]
        let implementationPaths = [
            path(1, ".github/scripts/prime-ci-active-root-quarantine.sh", "M", "100755", "source_and_use_the_shared_verifier_instead_of_private_duplicate_topology_logic"),
            path(2, ".github/scripts/PrimeExactRevisionTopologyClassifier.swift", "A", "100644", "standalone_bounded_read_once_raw_commit_classifier"),
            path(3, ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", "A", "100755", "sole_shared_privileged_bash_topology_verifier_library"),
            path(4, ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh", "A", "100755", "realistic_private_git_and_pure_classifier_matrix_test"),
            path(5, ".github/workflows/prime-active-root-quarantine.yml", "M", "100644", "run_the_shared_verifier_matrix_without_changing_job_topology"),
        ]
        let resultsGuardIDs = resultGuardOrder
        let historicalEvidence: [HistoricalGitHubShallowEvidence] = [
            .init(
                ordinal: 1,
                evidenceID: "run160_depth2_shallow_hidden_multi_hop_edge",
                fetchDepth: 2,
                explicitWantOIDs: run160Wants,
                literalCommitOID: mechanicsMerge.literalCommitOID,
                rawHeaderTreeOID: mechanicsMerge.expectedTreeOID,
                rawHeaderOrderedParentOIDs:
                    mechanicsMerge.expectedOrderedParentOIDs,
                availableReferencedParentOIDs: [
                    mechanicsHead.literalCommitOID,
                    authorityMerge.literalCommitOID,
                    authorityBaseMerge.literalCommitOID,
                ],
                absentReferencedParentOIDs: [],
                shallowBoundaryOIDs: [
                    mechanicsHead.literalCommitOID,
                    authorityMerge.literalCommitOID,
                ],
                observedFact:
                    "raw_headers_and_referenced_parent_objects_are_available_but_the_exact_retired_multi_hop_porcelain_probe_fails_only_because_the_intermediate_commits_are_marked_shallow",
                exactLegacyProbeCommandContract:
                    "/usr/bin/git -C <repository> merge-base --is-ancestor <revision^2^1> <authority_closure_revision> then_the_same_fixed_argv_with_arguments_reversed",
                exactLegacyProbeRevspec:
                    "5623872afda1895630ba0eacdfab76961c5e755b^2^1",
                legacyProbeResolved: false,
                rawHeadersProvidedTopologyFact: true,
                diagnosticEvidenceOnly: true,
                dynamicallyReplayedByFutureMatrix: false),
            .init(
                ordinal: 2,
                evidenceID: "run160_depth2_genuinely_absent_second_parent_object",
                fetchDepth: 2,
                explicitWantOIDs: run160Wants,
                literalCommitOID: authorityMerge.literalCommitOID,
                rawHeaderTreeOID: authorityMerge.expectedTreeOID,
                rawHeaderOrderedParentOIDs:
                    authorityMerge.expectedOrderedParentOIDs,
                availableReferencedParentOIDs: [
                    authorityBaseMerge.literalCommitOID,
                ],
                absentReferencedParentOIDs: [
                    authorityHead.literalCommitOID,
                ],
                shallowBoundaryOIDs: [authorityMerge.literalCommitOID],
                observedFact:
                    "raw_header_names_the_second_parent_oid_but_the_parent_object_itself_is_genuinely_absent",
                exactLegacyProbeCommandContract: nil,
                exactLegacyProbeRevspec: nil,
                legacyProbeResolved: nil,
                rawHeadersProvidedTopologyFact: true,
                diagnosticEvidenceOnly: true,
                dynamicallyReplayedByFutureMatrix: false),
            .init(
                ordinal: 3,
                evidenceID: "current_signed_merge_raw_header_continuations",
                fetchDepth: 2,
                explicitWantOIDs: currentWants,
                literalCommitOID: currentMerge.literalCommitOID,
                rawHeaderTreeOID: currentMerge.expectedTreeOID,
                rawHeaderOrderedParentOIDs:
                    currentMerge.expectedOrderedParentOIDs,
                availableReferencedParentOIDs:
                    currentMerge.expectedOrderedParentOIDs,
                absentReferencedParentOIDs: [],
                shallowBoundaryOIDs: [currentHead.literalCommitOID],
                observedFact:
                    "github_gpgsig_and_space_prefixed_continuation_lines_follow_the_topology_headers_without_changing_tree_or_ordered_parents",
                exactLegacyProbeCommandContract: nil,
                exactLegacyProbeRevspec: nil,
                legacyProbeResolved: nil,
                rawHeadersProvidedTopologyFact: true,
                diagnosticEvidenceOnly: true,
                dynamicallyReplayedByFutureMatrix: false),
            .init(
                ordinal: 4,
                evidenceID: "current_depth2_unrelated_wants_do_not_change_topology",
                fetchDepth: 2,
                explicitWantOIDs: currentWants + [
                    "690b5047e553d6869e3dc7c97ad858a349175b2c",
                    "25449c716a82eb67494aaf45b308cac0aeda7817",
                ],
                literalCommitOID: currentMerge.literalCommitOID,
                rawHeaderTreeOID: currentMerge.expectedTreeOID,
                rawHeaderOrderedParentOIDs:
                    currentMerge.expectedOrderedParentOIDs,
                availableReferencedParentOIDs:
                    currentMerge.expectedOrderedParentOIDs,
                absentReferencedParentOIDs: [],
                shallowBoundaryOIDs: [currentHead.literalCommitOID],
                observedFact:
                    "additional_unrelated_wants_do_not_change_literal_commit_raw_header_topology",
                exactLegacyProbeCommandContract: nil,
                exactLegacyProbeRevspec: nil,
                legacyProbeResolved: nil,
                rawHeadersProvidedTopologyFact: true,
                diagnosticEvidenceOnly: true,
                dynamicallyReplayedByFutureMatrix: false),
            .init(
                ordinal: 5,
                evidenceID: "replace_ref_disabled_for_literal_topology_observation",
                fetchDepth: 2,
                explicitWantOIDs: currentWants,
                literalCommitOID: currentMerge.literalCommitOID,
                rawHeaderTreeOID: currentMerge.expectedTreeOID,
                rawHeaderOrderedParentOIDs:
                    currentMerge.expectedOrderedParentOIDs,
                availableReferencedParentOIDs:
                    currentMerge.expectedOrderedParentOIDs,
                absentReferencedParentOIDs: [],
                shallowBoundaryOIDs: [currentHead.literalCommitOID],
                observedFact:
                    "a_present_refs_replace_entry_cannot_change_the_observation_when_every_git_object_call_uses_GIT_NO_REPLACE_OBJECTS_1",
                exactLegacyProbeCommandContract: nil,
                exactLegacyProbeRevspec: nil,
                legacyProbeResolved: nil,
                rawHeadersProvidedTopologyFact: true,
                diagnosticEvidenceOnly: true,
                dynamicallyReplayedByFutureMatrix: false),
        ]
        let baselineFixture = verifiedBaselineFixture()
        let baselineRequest = request(
            1, "exact_revision", baselineFixture.literalObjectOID,
            "9dd884bfe5b520a67c2944d8f8f79851a714519e", [])
        let verifiedBaseline = VerifiedEndToEndBaseline(
            baselineID: "private_git_end_to_end_verified_baseline",
            executionKind: "private_git_end_to_end",
            requestVector: [baselineRequest],
            privateRepositoryConstructionRecipe:
                "create_private_sha1_repository_then_decode_exact_base64_commit_bytes_and_write_only_with_/usr/bin/git_hash-object_--literally_-t_commit_-w_--stdin_then_require_literal_oid_equal",
            exactPrivateRepositoryInitArgumentVector:
                cleanGitArgumentVector([
                    "init", "--object-format=sha1",
                    "<canonical_absolute_private_repository>",
                ]),
            exactPrivateRepositoryInitStatus: 0,
            exactCommitWriteArgumentVector: cleanGitArgumentVector([
                "-C", "<canonical_absolute_private_repository>",
                "hash-object", "--literally", "-t", "commit", "-w",
                "--stdin",
            ]),
            exactCommitWriteStatus: 0,
            exactCommitWriteStdoutBase64:
                "OTdmYzhjNjBiNjkzNDNiNGUwMGVmZDg1ZThmM2JhMTNmZDdlNjUyYQo=",
            constructionUsesEmptyEnvironmentAndNoNetwork: true,
            commitFixture: baselineFixture,
            exactRepositoryFormatStatus: 0,
            exactRepositoryFormatStdoutBase64: "c2hhMQo=",
            exactBatchPreprobeStatus: 0,
            exactBatchPreprobeStdoutBase64:
                "OTdmYzhjNjBiNjkzNDNiNGUwMGVmZDg1ZThmM2JhMTNmZDdlNjUyYSBjb21taXQgMjE3Cg==",
            exactRawGitArgumentVector: cleanGitArgumentVector([
                "-C", "<canonical_absolute_private_repository>",
                "cat-file", "commit", baselineFixture.literalObjectOID,
            ]),
            exactClassifierArgumentVector:
                classifierArguments(fixture: baselineFixture),
            expectedClassifierExitStatus: 0,
            expectedResultCode: "TOPOLOGY_VERIFIED",
            expectedFirstFailedGuardID: nil,
            expectedMissingObjectRole: nil,
            passedGuardIDs: resultsGuardIDs,
            deterministicAndDynamicallyExecutable: true)
        let predicateWitnesses = resultsGuardIDs.enumerated().flatMap {
            index, guardID in
            [
                predicateWitness(
                    ordinal: index * 2 + 1,
                    guardID: guardID,
                    predicateValue: true,
                    passedGuardIDs: resultsGuardIDs),
                predicateWitness(
                    ordinal: index * 2 + 2,
                    guardID: guardID,
                    predicateValue: false,
                    passedGuardIDs: Array(resultsGuardIDs.prefix(index))),
            ]
        }
        let classifierPath =
            ".github/scripts/PrimeExactRevisionTopologyClassifier.swift"
        let helperPath =
            ".github/scripts/prime-ci-exact-revision-topology-verifier.sh"
        let staticSourceRegistry: [StaticSourceContractCheck] = [
            .init(
                ordinal: 1,
                checkID:
                    "static_check_classifier_inherited_file_descriptors_closed_positive",
                guardID: "classifier_inherited_file_descriptors_closed",
                predicateValue: true,
                passedGuardIDs: [],
                expectedResultCode: "TOPOLOGY_VERIFIED",
                futureComponentPath: classifierPath,
                exactSymbolOrSourceAnchor:
                    "closeInheritedFileDescriptorsUsingProcPIDInfo()",
                exactInvariantOrBranchAnchor:
                    "complete_final_proc_pidinfo_snapshot_is_exactly_fd_0_1_2",
                proofMethod:
                    "future_matrix_static_AST_assertion_plus_dynamic_extra_fd_positive_fixture"),
            .init(
                ordinal: 2,
                checkID:
                    "static_check_classifier_inherited_file_descriptors_closed_negative",
                guardID: "classifier_inherited_file_descriptors_closed",
                predicateValue: false,
                passedGuardIDs:
                    guardsBefore("classifier_inherited_file_descriptors_closed"),
                expectedResultCode: "TOPOLOGY_OBSERVATION_FAILED",
                futureComponentPath: classifierPath,
                exactSymbolOrSourceAnchor:
                    "closeInheritedFileDescriptorsUsingProcPIDInfo()",
                exactInvariantOrBranchAnchor:
                    "proc_pidinfo_allocation_close_or_nonconvergence_failure_exits_27",
                proofMethod:
                    "future_matrix_static_AST_assertion_for_noninjectable_proc_inventory_faults"),
            .init(
                ordinal: 3,
                checkID:
                    "static_check_classifier_parser_internal_state_valid_positive",
                guardID: "classifier_parser_internal_state_valid",
                predicateValue: true,
                passedGuardIDs: [],
                expectedResultCode: "TOPOLOGY_VERIFIED",
                futureComponentPath: classifierPath,
                exactSymbolOrSourceAnchor:
                    "parseCommitObjectBytes(_:expectedTreeOID:expectedParentOIDs:)",
                exactInvariantOrBranchAnchor:
                    "bounded_byte_parser_reaches_one_closed_declared_classification",
                proofMethod:
                    "future_matrix_static_AST_totality_assertion_plus_all_reachable_exit_fixtures"),
            .init(
                ordinal: 4,
                checkID:
                    "static_check_classifier_parser_internal_state_valid_negative",
                guardID: "classifier_parser_internal_state_valid",
                predicateValue: false,
                passedGuardIDs:
                    guardsBefore("classifier_parser_internal_state_valid"),
                expectedResultCode: "TOPOLOGY_OBSERVATION_FAILED",
                futureComponentPath: classifierPath,
                exactSymbolOrSourceAnchor:
                    "parseCommitObjectBytes(_:expectedTreeOID:expectedParentOIDs:)",
                exactInvariantOrBranchAnchor:
                    "unreachable_parser_state_exits_26_before_topology_classification",
                proofMethod:
                    "future_matrix_static_AST_assertion_for_noninjectable_internal_invariant_failure"),
            .init(
                ordinal: 5,
                checkID: "static_check_fixed_verifier_tools_admitted_positive",
                guardID: "fixed_verifier_tools_admitted",
                predicateValue: true,
                passedGuardIDs: [],
                expectedResultCode: "TOPOLOGY_VERIFIED",
                futureComponentPath: helperPath,
                exactSymbolOrSourceAnchor:
                    "prime_admit_exact_revision_topology_tools_v1",
                exactInvariantOrBranchAnchor:
                    "every_fixed_tool_path_mode_and_owner_admission_succeeds",
                proofMethod:
                    "future_matrix_exact_Bash_function_source_contract_assertion"),
            .init(
                ordinal: 6,
                checkID: "static_check_fixed_verifier_tools_admitted_negative",
                guardID: "fixed_verifier_tools_admitted",
                predicateValue: false,
                passedGuardIDs: guardsBefore("fixed_verifier_tools_admitted"),
                expectedResultCode: "TOPOLOGY_VERIFIER_UNAVAILABLE",
                futureComponentPath: helperPath,
                exactSymbolOrSourceAnchor:
                    "prime_admit_exact_revision_topology_tools_v1",
                exactInvariantOrBranchAnchor:
                    "any_fixed_tool_admission_failure_selects_fixed_verifier_tools_admitted",
                proofMethod:
                    "future_matrix_static_Bash_branch_and_result_mapping_assertion"),
            .init(
                ordinal: 7,
                checkID:
                    "static_check_classifier_build_and_self_test_admitted_positive",
                guardID: "classifier_build_and_self_test_admitted",
                predicateValue: true,
                passedGuardIDs: [],
                expectedResultCode: "TOPOLOGY_VERIFIED",
                futureComponentPath: helperPath,
                exactSymbolOrSourceAnchor:
                    "prime_build_exact_revision_topology_classifier_v1",
                exactInvariantOrBranchAnchor:
                    "swiftc_binary_admission_and_empty_stdin_self_test_all_succeed",
                proofMethod:
                    "future_matrix_exact_Bash_function_source_contract_and_live_self_test"),
            .init(
                ordinal: 8,
                checkID:
                    "static_check_classifier_build_and_self_test_admitted_negative",
                guardID: "classifier_build_and_self_test_admitted",
                predicateValue: false,
                passedGuardIDs:
                    guardsBefore("classifier_build_and_self_test_admitted"),
                expectedResultCode: "TOPOLOGY_VERIFIER_UNAVAILABLE",
                futureComponentPath: helperPath,
                exactSymbolOrSourceAnchor:
                    "prime_build_exact_revision_topology_classifier_v1",
                exactInvariantOrBranchAnchor:
                    "compile_import_binary_admission_or_self_test_failure_selects_classifier_build_and_self_test_admitted",
                proofMethod:
                    "future_matrix_static_Bash_branch_and_result_mapping_assertion"),
        ]
        let proofPairs = resultsGuardIDs.enumerated().map { index, guardID in
            PredicateProofPair(
                ordinal: index + 1,
                checkID: "predicate_proof_\(guardID)",
                guardID: guardID,
                positiveWitnessID: "predicate_\(guardID)_positive",
                negativeWitnessID: "predicate_\(guardID)_negative",
                predicatesAreDisjoint: true,
                predicatesAreExhaustive: true)
        }
        let directGuardIDs = resultsGuardIDs.filter {
            predicateExecutionKind($0) == "direct_classifier_fixture"
        }
        let directProofCases = directGuardIDs.enumerated().flatMap {
            index, guardID in
            [true, false].map { predicateValue in
                classifierPredicateCase(
                    ordinal: index * 2 + (predicateValue ? 1 : 2),
                    guardID: guardID,
                    predicateValue: predicateValue)
            }
        }
        let directSupplementalCases: [ClassifierDirectFixtureCase] = [
            directFixtureCase(
                directProofCases.count + 1,
                "gpgsig_sha256_with_blank_continuation_is_accepted",
                "signed_header_continuations_are_allowed_and_attached", true,
                supplementalFixture("valid_gpgsig_sha256"),
                classifierArguments(
                    fixture: supplementalFixture("valid_gpgsig_sha256")), 0,
                "TOPOLOGY_VERIFIED", nil),
            directFixtureCase(
                directProofCases.count + 2,
                "repeated_mergetag_with_blank_continuation_is_accepted",
                "signed_header_continuations_are_allowed_and_attached", true,
                supplementalFixture("valid_repeated_mergetag"),
                classifierArguments(
                    fixture: supplementalFixture("valid_repeated_mergetag")), 0,
                "TOPOLOGY_VERIFIED", nil),
            directFixtureCase(
                directProofCases.count + 3, "repeated_gpgsig_is_rejected",
                "signed_header_continuations_are_allowed_and_attached", false,
                predicateFixture(
                    guardID:
                        "signed_header_continuations_are_allowed_and_attached",
                    predicateValue: false,
                    writesPrivateGitObject: false),
                classifierArguments(fixture: predicateFixture(
                    guardID:
                        "signed_header_continuations_are_allowed_and_attached",
                    predicateValue: false,
                    writesPrivateGitObject: false)), 34,
                "TOPOLOGY_HEADER_MALFORMED",
                "signed_header_continuations_are_allowed_and_attached"),
            directFixtureCase(
                directProofCases.count + 4,
                "unattached_continuation_is_rejected",
                "signed_header_continuations_are_allowed_and_attached", false,
                supplementalFixture("unattached_continuation"),
                classifierArguments(
                    fixture: supplementalFixture("unattached_continuation")), 34,
                "TOPOLOGY_HEADER_MALFORMED",
                "signed_header_continuations_are_allowed_and_attached"),
            directFixtureCase(
                directProofCases.count + 5,
                "missing_header_message_separator_is_rejected",
                "header_lines_and_separator_are_well_formed", false,
                supplementalFixture("missing_separator"),
                classifierArguments(
                    fixture: supplementalFixture("missing_separator")), 30,
                "TOPOLOGY_HEADER_MALFORMED",
                "header_lines_and_separator_are_well_formed"),
            directFixtureCase(
                directProofCases.count + 6,
                "zero_byte_commit_object_reaches_generic_header_guard",
                "header_lines_and_separator_are_well_formed", false,
                supplementalFixture("zero_byte_commit"),
                classifierArguments(
                    fixture: supplementalFixture("zero_byte_commit")),
                30, "TOPOLOGY_HEADER_MALFORMED",
                "header_lines_and_separator_are_well_formed"),
            directFixtureCase(
                directProofCases.count + 7,
                "inherited_extra_fd_is_closed_then_valid_object_verifies",
                "classifier_inherited_file_descriptors_closed", true,
                supplementalFixture("valid_gpgsig_sha256"),
                classifierArguments(
                    fixture: supplementalFixture("valid_gpgsig_sha256")),
                0, "TOPOLOGY_VERIFIED", nil,
                "fixture_parent_opens_private_fd9_without_cloexec_before_direct_invocation"),
            directFixtureCase(
                directProofCases.count + 8,
                "simultaneous_single_gpgsig_and_gpgsig_sha256_is_accepted",
                "signed_header_continuations_are_allowed_and_attached", true,
                supplementalFixture("valid_both_signatures"),
                classifierArguments(
                    fixture: supplementalFixture("valid_both_signatures")),
                0, "TOPOLOGY_VERIFIED", nil),
            directFixtureCase(
                directProofCases.count + 9,
                "repeated_gpgsig_sha256_is_rejected",
                "signed_header_continuations_are_allowed_and_attached", false,
                supplementalFixture("repeated_gpgsig_sha256"),
                classifierArguments(
                    fixture: supplementalFixture("repeated_gpgsig_sha256")),
                34, "TOPOLOGY_HEADER_MALFORMED",
                "signed_header_continuations_are_allowed_and_attached"),
            directFixtureCase(
                directProofCases.count + 10,
                "continuation_after_non_signed_header_is_rejected",
                "signed_header_continuations_are_allowed_and_attached", false,
                supplementalFixture("continuation_after_author"),
                classifierArguments(
                    fixture: supplementalFixture("continuation_after_author")),
                34, "TOPOLOGY_HEADER_MALFORMED",
                "signed_header_continuations_are_allowed_and_attached"),
            directFixtureCase(
                directProofCases.count + 11,
                "malformed_physical_header_field_is_rejected",
                "header_lines_and_separator_are_well_formed", false,
                supplementalFixture("malformed_physical_field"),
                classifierArguments(
                    fixture: supplementalFixture("malformed_physical_field")),
                30, "TOPOLOGY_HEADER_MALFORMED",
                "header_lines_and_separator_are_well_formed"),
            directFixtureCase(
                directProofCases.count + 12,
                "nul_in_opaque_message_is_rejected_as_unsupported",
                "classifier_input_is_nul_free", false,
                supplementalFixture("nul_message"),
                classifierArguments(
                    fixture: supplementalFixture("nul_message")),
                25, "TOPOLOGY_OBJECT_UNSUPPORTED",
                "classifier_input_is_nul_free"),
            directFixtureCase(
                directProofCases.count + 13,
                "carriage_return_in_header_is_rejected",
                "header_lines_and_separator_are_well_formed", false,
                supplementalFixture("cr_header"),
                classifierArguments(
                    fixture: supplementalFixture("cr_header")),
                30, "TOPOLOGY_HEADER_MALFORMED",
                "header_lines_and_separator_are_well_formed"),
            directFixtureCase(
                directProofCases.count + 14,
                "carriage_return_in_opaque_message_is_accepted",
                "header_lines_and_separator_are_well_formed", true,
                supplementalFixture("cr_message"),
                classifierArguments(
                    fixture: supplementalFixture("cr_message")),
                0, "TOPOLOGY_VERIFIED", nil),
            directFixtureCase(
                directProofCases.count + 15,
                "actual_nine_parent_commit_is_parsed_then_mismatches",
                "ordered_parent_oids_equal_expected", false,
                supplementalFixture("nine_actual_parents"),
                classifierArguments(
                    fixture: supplementalFixture("nine_actual_parents")),
                42, "TOPOLOGY_MISMATCH",
                "ordered_parent_oids_equal_expected"),
        ]
        let directFixtureMatrix = directProofCases + directSupplementalCases
        let helperGuardIDs = resultsGuardIDs.filter {
            predicateExecutionKind($0) == "direct_helper_parser_fixture"
        }
        let helperParserMatrix = helperGuardIDs.enumerated().flatMap {
            index, guardID in
            [true, false].map { predicateValue in
                helperParserCase(
                    ordinal: index * 2 + (predicateValue ? 1 : 2),
                    guardID: guardID,
                    predicateValue: predicateValue)
            }
        }

        return Self(
            schemaVersion: 1,
            schemaID: "prime_exact_revision_topology_verifier_authority_v1",
            authorityID: "ergentics_prime_exact_revision_topology_verifier_authority_v1",
            authorityKind: "pure_authority_for_one_later_shared_raw_commit_header_exact_revision_topology_verifier",
            retiredRun160Closure: .init(
                observationID: "prime_secure_child_validation_fixture_identity_measurement_outcome_observation_v1",
                observationCanonicalByteCount: 28_633,
                observationCanonicalSHA256: "d7042968a0c78d213c92d73d11d6637f3c03b0f758555376263b9d3aa8ec1a77",
                mechanicsMergeRevision: mechanicsMerge.literalCommitOID,
                mechanicsMergeTree: mechanicsMerge.expectedTreeOID,
                orderedMechanicsMergeParentOIDs: mechanicsMerge.expectedOrderedParentOIDs,
                mechanicsReviewedHeadRevision: mechanicsHead.literalCommitOID,
                mechanicsReviewedHeadTree: mechanicsHead.expectedTreeOID,
                orderedMechanicsReviewedHeadParentOIDs: mechanicsHead.expectedOrderedParentOIDs,
                workflowRunID: 32_396_967_956,
                workflowRunNumber: 160,
                workflowRunAttempt: 1,
                checkSuiteID: 87_824_712_564,
                activeRootJobID: 96_515_945_260,
                reviewedMainJobID: 96_517_280_624,
                workflowConclusion: "failure",
                resultCode: "INVOCATION_ADMISSION_REFUSED",
                hostedRecordCount: 1,
                measurementAttemptConsumed: false,
                opportunityState: "retired",
                scientificOutcome: "not_established",
                fixtureExecutionCount: 0,
                actionsArtifactCount: 0,
                retryCount: 0,
                rerunCount: 0,
                likelyRefusalCauseClassification: "inference_only_depth_two_shallow_boundary_broke_multi_hop_porcelain_ancestry_resolution",
                likelyRefusalCauseDirectlyEstablished: false,
                depthTwoCheckoutObserved: true,
                retiredLauncherUsedMultiHopAncestryRevspec: true,
                rawCommitHeadersWouldExposeRequiredOIDs: true,
                refusalAuthorizesRepairRetryRerunOrReplacement: false,
                retirementMergedAndExactMainGreen: true),
            currentExactMainClosure: .init(
                repository: "Ergentics/ergentics-prime",
                ref: "refs/heads/main",
                pullRequestNumber: 131,
                baseRevision: "5623872afda1895630ba0eacdfab76961c5e755b",
                reviewedHeadRevision: currentHead.literalCommitOID,
                reviewedHeadTree: currentHead.expectedTreeOID,
                reviewedHeadOrderedParentOIDs: currentHead.expectedOrderedParentOIDs,
                mergeRevision: currentMerge.literalCommitOID,
                mergeTree: currentMerge.expectedTreeOID,
                orderedMergeParentOIDs: currentMerge.expectedOrderedParentOIDs,
                mergeTreeEqualsReviewedHeadTree: true,
                historyPreservingTwoParentMergeObserved: true,
                githubSignatureVerified: true,
                githubSignatureReason: "valid",
                githubSignatureVerifiedAt: "2026-08-20T19:33:23Z",
                pullRequestRunID: 32_408_268_746,
                pullRequestRunNumber: 161,
                pullRequestRunAttempt: 1,
                pullRequestCheckSuiteID: 87_857_160_513,
                pullRequestConclusion: "success",
                pullRequestPreviousAttemptURL: nil,
                pullRequestActiveRootJobID: 96_552_418_667,
                pullRequestActiveRootJobConclusion: "success",
                pullRequestReviewedMainJobID: 96_553_842_289,
                pullRequestReviewedMainJobConclusion: "skipped",
                pullRequestReviewedMainJobStepCount: 0,
                pullRequestActionsArtifactCount: 0,
                exactMainRunID: 32_409_301_709,
                exactMainRunNumber: 162,
                exactMainRunAttempt: 1,
                exactMainCheckSuiteID: 87_860_204_169,
                exactMainConclusion: "success",
                exactMainActiveRootJobID: 96_555_737_682,
                exactMainReviewedMainJobID: 96_556_896_270,
                exactMainActiveRootJobConclusion: "success",
                exactMainReviewedMainJobConclusion: "success",
                exactMainActionsArtifactCount: 0,
                retirementObservationSource: .init(
                    path: "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservation.swift",
                    gitStatus: "A",
                    gitMode: "100644",
                    gitBlob: "4aeecf6c444bf4e229c06a5b5a14a806fca643e1",
                    byteCount: 84_126,
                    lfByteCount: 1_644,
                    sha256: "4cda5a461882c401864f11ff761de5ae50170199db56834bf74da9a8ba533232",
                    role: "append_only_retired_run160_outcome_observation"),
                retirementObservationTest: .init(
                    path: "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationTests.swift",
                    gitStatus: "A",
                    gitMode: "100644",
                    gitBlob: "b7125ce6e0986e849ae0032f4e15eafca37a5acb",
                    byteCount: 49_276,
                    lfByteCount: 1_121,
                    sha256: "cd94cc74781b3928625042e98d4c5767c382a0f3b6eb4db43d84573184a1c517",
                    role: "sole_pure_retired_run160_outcome_observation_test")),
            commitHeaderContract: .init(
                repositoryObjectFormat: "sha1",
                literalOIDEncoding: "lowercase_ascii_hex",
                literalOIDCharacterCount: 40,
                uppercaseOIDAccepted: false,
                abbreviatedOIDAccepted: false,
                symbolicRefAccepted: false,
                refNameAccepted: false,
                ancestryOperatorAccepted: false,
                replaceObjectsDisabledEnvironment: "GIT_NO_REPLACE_OBJECTS=1",
                lazyFetchDisabledEnvironment: "GIT_NO_LAZY_FETCH=1",
                replacementRefsMayAffectObservation: false,
                graftsFileMayContributeTopologyFacts: false,
                localeEnvironment: "LC_ALL=C",
                fixedGitExecutablePath: "/usr/bin/git",
                fixedBashExecutablePath: "/bin/bash",
                fixedXcrunExecutablePath: "/usr/bin/xcrun",
                fixedEnvExecutablePath: "/usr/bin/env",
                exactFixedToolPaths: [
                    "/bin/bash", "/usr/bin/git",
                    "/usr/bin/env", "/usr/bin/mktemp", "/usr/bin/stat",
                    "/usr/bin/xcrun",
                ],
                everyFixedToolMustBeExecutableRegularNonlink: true,
                classifierSourcePath:
                    ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                classifierRequiredImports: ["CryptoKit", "Darwin", "Foundation"],
                classifierCompileArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "CLANG_MODULE_CACHE_PATH=<validated_private_compiler_root>/clang-module-cache",
                    "/usr/bin/xcrun", "swiftc",
                    ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                    "-o",
                    "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                ],
                classifierPrivateExecutableLeaf:
                    "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                classifierSourceIdentityAdmissionRequired: true,
                exactToolchainOverrideEnvironmentKeysRequiredUnset: [
                    "DEVELOPER_DIR", "SDKROOT", "SWIFT_DRIVER_SWIFT_EXEC",
                    "SWIFT_DRIVER_SWIFT_FRONTEND_EXEC", "SWIFT_EXEC",
                    "TOOLCHAINS",
                ],
                compilerAndClassifierUseEmptyEnvironment: true,
                exactCleanEnvironmentAssignments: [
                    "LC_ALL=C", "TMPDIR=<validated_private_compiler_root>",
                    "CLANG_MODULE_CACHE_PATH=<validated_private_compiler_root>/clang-module-cache",
                ],
                compilerOrImportFailureResultCode:
                    "TOPOLOGY_VERIFIER_UNAVAILABLE",
                classifierExecutionArgumentPrefix: [
                    "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                ],
                classifierCleanEnvironmentArgumentVectorPrefix: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                ],
                classifierExactArgumentRoles: [
                    "literal_lowercase_40hex_commit_oid",
                    "advertised_canonical_nonnegative_base10_object_byte_count_0_through_1048576",
                    "expected_lowercase_40hex_tree_oid",
                    "expected_parent_count_base10",
                    "zero_or_more_ordered_lowercase_40hex_parent_oids",
                ],
                topologyFactSource: "one_explicit_type_git_cat_file_commit_content_stream_classified_from_one_bounded_in_memory_byte_array",
                exactObjectPreprobeArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "GIT_NO_REPLACE_OBJECTS=1", "GIT_NO_LAZY_FETCH=1",
                    "GIT_CONFIG_NOSYSTEM=1", "GIT_CONFIG_GLOBAL=/dev/null",
                    "GIT_TERMINAL_PROMPT=0", "GIT_OPTIONAL_LOCKS=0",
                    "/usr/bin/git", "-C", "<repository>", "cat-file",
                    "--batch-check=%(objectname) %(objecttype) %(objectsize)",
                ],
                exactObjectPreprobeOutputGrammar:
                    "phase13_requires_status0_exact_N_LF_records_in_request_order_same_literal_oid_and_only_two_token_<oid>_missing_or_three_token_<oid>_<raw_type_token>_<raw_size_token>_shape;phase14_interprets_only_exact_missing_as_absent;phase15_requires_present_raw_type_token_in_fixed_[blob_commit_tag_tree]enum;phase16_requires_type_commit;phase17_requires_raw_size_token_canonical_nonnegative_base10;phase18_requires_size_at_most_1048576",
                exactGitObjectTypeTokens: ["blob", "commit", "tag", "tree"],
                exactObjectPreprobeInputGrammar:
                    "one_prevalidated_literal_lowercase_40hex_oid_then_lf_per_request_in_ordinal_order",
                objectPreprobeInputUsesBashBuiltinPrintf: true,
                objectPreprobeStatusRequired: 0,
                maximumObjectPreprobeOutputByteCount: 1_024,
                exactRepositoryFormatObservationArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "GIT_NO_REPLACE_OBJECTS=1", "GIT_NO_LAZY_FETCH=1",
                    "GIT_CONFIG_NOSYSTEM=1", "GIT_CONFIG_GLOBAL=/dev/null",
                    "GIT_TERMINAL_PROMPT=0", "GIT_OPTIONAL_LOCKS=0",
                    "/usr/bin/git", "-C", "<repository>", "rev-parse",
                    "--show-object-format=storage",
                ],
                exactRepositoryFormatSuccessOutput: "sha1_one_lf",
                exactRawCatFileArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "GIT_NO_REPLACE_OBJECTS=1", "GIT_NO_LAZY_FETCH=1",
                    "GIT_CONFIG_NOSYSTEM=1", "GIT_CONFIG_GLOBAL=/dev/null",
                    "GIT_TERMINAL_PROMPT=0", "GIT_OPTIONAL_LOCKS=0",
                    "/usr/bin/git", "-C", "<repository>", "cat-file", "commit",
                    "<literal_lowercase_40hex_commit_oid>",
                ],
                objectTypeRequired: "commit",
                maximumCommitObjectByteCount: 1_048_576,
                classifierBoundedReadLimitByteCount: 1_048_577,
                maximumVerificationRequestCount: 8,
                maximumParentCountPerCommit: 8,
                classifierActualParsedParentCountBound:
                    "no_separate_count_cap_beyond_the_1048576_byte_object_bound;any_actual_count_above_the_admitted_expected_maximum_8_is_fully_parsed_and_exits_42_ordered_parent_mismatch",
                requestRoleASCIIGrammar: "^[a-z][a-z0-9_]{0,63}$",
                maximumRequestRoleUTF8ByteCount: 64,
                rawCatFileContentInvocationCountPerParsedObject: 1,
                exactCatFileArgumentRoles: [
                    "literal_-C", "repository_path", "literal_cat-file",
                    "literal_commit_type", "literal_lowercase_40hex_commit_oid",
                ],
                catFileStdoutPipedDirectlyToClassifierStdin: true,
                filesystemCapturePathCount: 0,
                classifierReadsLogicalStandardInputStreamOnceToEOF: true,
                classifierDrainsStandardInputToEOFOnEveryNonReadFailureOutcome:
                    true,
                classifierRetriesInterruptedStandardInputReads: true,
                classifierPerformsNoFilesystemOperation: true,
                classifierGitObjectHashPrefixFormula:
                    "ascii_commit_space_then_canonical_nonnegative_base10_byte_count_then_nul",
                classifierComputesSHA1OverPrefixAndExactWithinCapAdvertisedInputBytes: true,
                classifierComputedOIDMustEqualLiteralOID: true,
                classifierWithinCapExactAdvertisedInputByteArrayIsSoleHashAndParseSource: true,
                classifierParsesBytesWithoutUTF8Decoding: true,
                classifierUsesDarwinProcPIDInfoFDInventory: true,
                classifierMaximumFDInventoryByteCount: 16_384,
                classifierMaximumFDClosurePassCount: 4,
                classifierFDInventoryAllocationSlackRecordCount: 8,
                classifierFDInitialSizeUsesCheckedCapMinusSlackArithmetic:
                    true,
                classifierFDFilledSizeMustBeStrictlyBelowCapacity: true,
                classifierFinalSnapshotMustBeCompleteAndExactlyFD012: true,
                classifierFDInventoryRequiresNonnegativeMultipleOfStride: true,
                classifierRejectsNegativeEnumeratedFD: true,
                classifierClosesEveryEnumeratedDescriptorAtOrAbove: 3,
                classifierAcceptedCloseResults: ["0", "-1_with_errno_EBADF"],
                classifierRequiresNoFDAtOrAbove3FixedPoint: true,
                classifierFinalFDSet: [0, 1, 2],
                classifierFDClosureClaimAppliesOnlyAtFinalSnapshot: true,
                classifierIsSingleThreaded: true,
                classifierInstallsSignalHandler: false,
                classifierReadsRawBytesFromDarwinFD0AfterClosure: true,
                classifierHasNoAdditionalStdinPipeWriterAtOrAboveFD3: true,
                exactPipelineStatusCount: 2,
                pipelineRunsUnderTemporarilyDisabledErrexit: true,
                pipelineStatusesCapturedImmediatelyBeforeErrexitRestore: true,
                gitNonzeroHasPrecedenceOverClassifierStatus: true,
                classifierStdoutByteCount: 0,
                classifierStderrByteCount: 0,
                gitCatFileStderrPublished: false,
                gitCatFileStderrSink:
                    "private_nonpublished_status_governed_stderr_sink",
                exactTextCaptureStatusTrailerGrammar:
                    "terminal_LF_preserved_then_ASCII_RS_prime_status_colon_fixed_three_decimal_digits_ASCII_US_without_terminal_LF",
                textCapturePreservesTerminalLFBeforeTrailerRemoval: true,
                batchPreprobePipelineStatusCount: 2,
                exactClassifierExitMappings: [
                    .init(exitStatus: 0, resultCode: "TOPOLOGY_VERIFIED", firstFailedGuardID: nil),
                    .init(exitStatus: 20, resultCode: "TOPOLOGY_OBSERVATION_FAILED", firstFailedGuardID: "classifier_arguments_match_helper_protocol"),
                    .init(exitStatus: 21, resultCode: "TOPOLOGY_OBSERVATION_FAILED", firstFailedGuardID: "classifier_stdin_read_succeeded"),
                    .init(exitStatus: 22, resultCode: "TOPOLOGY_OBSERVATION_FAILED", firstFailedGuardID: "classifier_actual_size_within_bound"),
                    .init(exitStatus: 23, resultCode: "TOPOLOGY_OBSERVATION_FAILED", firstFailedGuardID: "classifier_actual_size_equals_advertised_size"),
                    .init(exitStatus: 24, resultCode: "TOPOLOGY_OBSERVATION_FAILED", firstFailedGuardID: "classifier_computed_oid_equals_literal_oid"),
                    .init(exitStatus: 25, resultCode: "TOPOLOGY_OBJECT_UNSUPPORTED", firstFailedGuardID: "classifier_input_is_nul_free"),
                    .init(exitStatus: 26, resultCode: "TOPOLOGY_OBSERVATION_FAILED", firstFailedGuardID: "classifier_parser_internal_state_valid"),
                    .init(exitStatus: 27, resultCode: "TOPOLOGY_OBSERVATION_FAILED", firstFailedGuardID: "classifier_inherited_file_descriptors_closed"),
                    .init(exitStatus: 30, resultCode: "TOPOLOGY_HEADER_MALFORMED", firstFailedGuardID: "header_lines_and_separator_are_well_formed"),
                    .init(exitStatus: 31, resultCode: "TOPOLOGY_HEADER_MALFORMED", firstFailedGuardID: "tree_header_is_first_and_unique"),
                    .init(exitStatus: 32, resultCode: "TOPOLOGY_HEADER_MALFORMED", firstFailedGuardID: "ordered_parent_headers_are_contiguous"),
                    .init(exitStatus: 33, resultCode: "TOPOLOGY_HEADER_MALFORMED", firstFailedGuardID: "topology_header_oids_are_lowercase_40hex"),
                    .init(exitStatus: 34, resultCode: "TOPOLOGY_HEADER_MALFORMED", firstFailedGuardID: "signed_header_continuations_are_allowed_and_attached"),
                    .init(exitStatus: 41, resultCode: "TOPOLOGY_MISMATCH", firstFailedGuardID: "tree_oid_equals_expected"),
                    .init(exitStatus: 42, resultCode: "TOPOLOGY_MISMATCH", firstFailedGuardID: "ordered_parent_oids_equal_expected"),
                ],
                unknownClassifierExitMapsToObservationFailure: true,
                compilerInvocationCount: 1,
                compilerBaseEnvironmentKey: "RUNNER_TEMP",
                compilerBaseAdmissionContract:
                    "absolute_owned_writable_directory_nonlink",
                compilerBaseMaximumUTF8ByteCount: 1_024,
                compilerBasePathGrammar:
                    "canonical_absolute_owned_writable_existing_directory_nonlink_without_dot_or_dotdot_components",
                compilerBaseRejectsLFCRAndControlBytes: true,
                everyFilesystemPathPassedAsOneQuotedArgument: true,
                compilerUmask: "0077",
                compilerRootCreationArgumentVector: [
                    "/usr/bin/mktemp", "-d",
                    "<validated_RUNNER_TEMP>/prime-topology-classifier.XXXXXXXX",
                ],
                compilerRootAdmissionArgumentVector: [
                    "/usr/bin/stat", "-f", "%u %p %HT", "--",
                    "<private_compiler_root>",
                ],
                compilerRootAdmissionOutputGrammar:
                    "effective_uid_space_exact_mode_40700_space_Directory_then_lf",
                compilerRootMode: "0700",
                compilerOutputLeaf: "prime-exact-revision-topology-classifier",
                compilerOutputInitiallyAbsentAndNonlink: true,
                compilerStatusRequired: 0,
                compilerStdoutByteCount: 0,
                compilerStderrByteCount: 0,
                compilerPrivateLifecycleContract:
                    "admit_absolute_owned_writable_nonlink_RUNNER_TEMP_then_umask_077_then_/usr/bin/mktemp_-d_RUNNER_TEMP/prime-topology-classifier.XXXXXXXX_status0_one_absolute_line_then_/usr/bin/stat_fixed_C_grammar_admits_owned_0700_nonlink_child_directory_then_require_absent_nonlink_output_leaf_then_/usr/bin/env_-i_exact_clean_assignments_/usr/bin/xcrun_swiftc_exact_argv_status0_stdout0_stderr0_then_/usr/bin/stat_fixed_C_grammar_admits_owned_executable_regular_nonlink_leaf_then_retain_non_evidence_until_ordinary_runner_teardown_only_and_exclude_hostile_concurrent_same_euid_mutation",
                compilerPrivateArtifactsPublishedOrEvidence: false,
                compilerLauncherCleanupInvocationCount: 0,
                classifierExecutableAdmissionRequired: true,
                classifierExecutableMustBePrivateRegularNonlink: true,
                classifierSelfTestRequiredBeforeRawObjectPipeline: true,
                classifierSelfTestArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                    "--self-test",
                ],
                classifierSelfTestUsesEmptyStandardInput: true,
                classifierSelfTestStandardInputSource: "/dev/null",
                classifierSelfTestConstructsVectorInternally: true,
                classifierSelfTestPayloadBase64:
                    "dHJlZSAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwCgo=",
                classifierSelfTestPayloadByteCount: 47,
                classifierSelfTestGitObjectOID:
                    "60bc2812cc97ab2d2f2c7168aa101f7bfabcbf88",
                classifierSelfTestExpectedExitStatus: 0,
                classifierSelfTestOutputByteCount: 0,
                classifierSelfTestImmediatelyFollowsExecutableAdmission: true,
                rawClassifierInvocationsRequireSuccessfulSelfTest: true,
                noBuildOrUntrustedProcessBetweenSelfTestAndRawInvocations:
                    true,
                interveningBuildInvocationCount: 0,
                allRequestPreprobesCompleteBeforeAnyClassifierInvocation:
                    true,
                exactPreprobeGuardPhaseRange: Array(13 ... 18),
                exactRawClassifierGuardPhaseRange: Array(19 ... 35),
                preprobeFailureRawClassifierInvocationCount: 0,
                rawStageRequiresEveryRequestAvailableCommitWithinCap: true,
                allEligibleClassifierOutcomesCollectedBeforeSelection: true,
                globalFailureSelectionOrder:
                    "lexicographically_smallest_phase_ordinal_then_request_ordinal",
                stderrPublished: false,
                commitHeaderEndsAtFirstEmptyLine: true,
                commitMessageParsed: false,
                treeHeaderMustBeFirst: true,
                exactTreeHeaderCount: 1,
                parentHeadersMustBeContiguousImmediatelyAfterTree: true,
                parentHeaderOrderIsSemantic: true,
                treeOrParentHeaderPermittedAfterOtherHeader: false,
                treeAndParentValuesRequireLiteralLowercase40Hex: true,
                signedHeaderContinuationBeginsWithOneSpace: true,
                exactHeadersPermittingContinuationLines: [
                    "gpgsig", "gpgsig-sha256", "mergetag",
                ],
                repeatedGPGSigHeaderAccepted: false,
                repeatedGPGSigSHA256HeaderAccepted: false,
                repeatedMergetagHeaderAccepted: true,
                emptySignedContinuationPayloadAccepted: true,
                signedHeaderContinuationContributesTopologyFacts: false,
                unattachedContinuationAccepted: false,
                carriageReturnAccepted: false,
                NULAccepted: false,
                exactHeaderByteGrammar:
                    "header_is_one_or_more_physical_lines_each_terminated_by_LF_then_one_empty_LF_line_then_opaque_message;field_line_is_name_SP_value;name_is_nonempty_ASCII_[a-z][a-z0-9-]*;value_may_be_empty_but_excludes_LF_CR_NUL;continuation_consumes_exactly_one_leading_SP_and_the_remaining_payload_is_opaque_and_may_begin_with_SP_only_when_attached_to_gpgsig_gpgsig-sha256_or_mergetag;tree_is_first_and_unique;parents_are_contiguous_and_ordered;gpgsig_and_gpgsig-sha256_each_at_most_once;mergetag_may_repeat",
                wholeObjectNULPolicy:
                    "any_NUL_in_header_or_opaque_commit_message_exits_25_object_unsupported_before_header_parse",
                carriageReturnPolicy:
                    "CR_in_header_framing_or_field_bytes_exits_30_header_malformed_but_CR_in_opaque_commit_message_is_accepted",
                repositoryNativeSHA1CompatibilityPurpose:
                    "CryptoKit_Insecure_SHA1_is_used_only_to_recompute_the_repository_native_commit_object_oid_and_is_not_security_or_evidence_strength",
                SHA1ClaimsCollisionResistance: false,
                SHA1ClaimsAuthenticity: false,
                SHA1ClaimsSignatureValidity: false,
                SHA1ClaimsTopologyTrustWithoutTreeAndParents: false,
                signedHeaderHandlingIsGrammarOnly: true,
                SHA256FixtureDigestPurpose:
                    "trusted_expected_SHA256_digests_identify_and_integrity_bind_frozen_authority_evidence_and_fixture_bytes_without_claiming_authorship_or_signature_authenticity_and_independently_of_required_tree_and_ordered_parent_byte_comparisons",
                futureDualObjectFormatSupportInV1: false,
                rawHeaderMustBeWellFormedBeforeSemanticComparison: true,
                expectedTreeComparedByExactBytes: true,
                expectedOrderedParentsComparedByExactBytes: true,
                topologyHistoryTraversalInvocationCount: 0,
                mergeBaseInvocationCount: 0,
                revListInvocationCount: 0,
                refResolutionInvocationCount: 0,
                forbiddenTopologyMechanismNames: [
                    "caret_ancestry_operator",
                    "tilde_ancestry_operator",
                    "merge_base",
                    "rev_list",
                    "symbolic_ref",
                    "abbreviated_oid",
                    "ambiguous_revision_expression",
                    "history_walk",
                ]),
            resultClassificationContract: .init(
                exactOrderedResultCodes: [
                    "TOPOLOGY_VERIFIED",
                    "TOPOLOGY_INVOCATION_INVALID",
                    "TOPOLOGY_VERIFIER_UNAVAILABLE",
                    "TOPOLOGY_OBJECT_UNAVAILABLE",
                    "TOPOLOGY_OBJECT_NOT_COMMIT",
                    "TOPOLOGY_OBJECT_UNSUPPORTED",
                    "TOPOLOGY_REPOSITORY_UNSUPPORTED",
                    "TOPOLOGY_OBSERVATION_FAILED",
                    "TOPOLOGY_HEADER_MALFORMED",
                    "TOPOLOGY_MISMATCH",
                ],
                successResultCode: "TOPOLOGY_VERIFIED",
                invalidInvocationResultCode: "TOPOLOGY_INVOCATION_INVALID",
                verifierUnavailableResultCode: "TOPOLOGY_VERIFIER_UNAVAILABLE",
                objectUnavailableResultCode: "TOPOLOGY_OBJECT_UNAVAILABLE",
                objectNotCommitResultCode: "TOPOLOGY_OBJECT_NOT_COMMIT",
                objectUnsupportedResultCode: "TOPOLOGY_OBJECT_UNSUPPORTED",
                repositoryUnsupportedResultCode:
                    "TOPOLOGY_REPOSITORY_UNSUPPORTED",
                observationFailedResultCode: "TOPOLOGY_OBSERVATION_FAILED",
                malformedHeaderResultCode: "TOPOLOGY_HEADER_MALFORMED",
                topologyMismatchResultCode: "TOPOLOGY_MISMATCH",
                firstFailureWins: true,
                exactClassificationPrecedence: [
                    "invocation_grammar",
                    "fixed_verifier_tool_admission",
                    "classifier_build_admission_and_self_test",
                    "repository_sha1_object_format",
                    "literal_object_availability",
                    "object_type_commit",
                    "object_size_observation_and_bound",
                    "raw_observation_transport",
                    "classifier_protocol_read_size_hash_and_supported_bytes",
                    "header_well_formedness",
                    "tree_and_ordered_parent_equality",
                ],
                exactGuardResultMappings: [
                    .init(phaseOrdinal: 1, guardID: "literal_commit_oid_is_lowercase_40hex", resultCode: "TOPOLOGY_INVOCATION_INVALID"),
                    .init(phaseOrdinal: 2, guardID: "expected_topology_oids_are_lowercase_40hex", resultCode: "TOPOLOGY_INVOCATION_INVALID"),
                    .init(phaseOrdinal: 3, guardID: "verification_request_count_nonzero", resultCode: "TOPOLOGY_INVOCATION_INVALID"),
                    .init(phaseOrdinal: 4, guardID: "verification_request_count_within_bound", resultCode: "TOPOLOGY_INVOCATION_INVALID"),
                    .init(phaseOrdinal: 5, guardID: "repository_argument_is_canonical_absolute_admitted_git_worktree", resultCode: "TOPOLOGY_INVOCATION_INVALID"),
                    .init(phaseOrdinal: 6, guardID: "request_role_matches_ascii_allowlist_grammar", resultCode: "TOPOLOGY_INVOCATION_INVALID"),
                    .init(phaseOrdinal: 7, guardID: "request_roles_are_unique", resultCode: "TOPOLOGY_INVOCATION_INVALID"),
                    .init(phaseOrdinal: 8, guardID: "expected_parent_count_within_bound", resultCode: "TOPOLOGY_INVOCATION_INVALID"),
                    .init(phaseOrdinal: 9, guardID: "fixed_verifier_tools_admitted", resultCode: "TOPOLOGY_VERIFIER_UNAVAILABLE"),
                    .init(phaseOrdinal: 10, guardID: "classifier_build_and_self_test_admitted", resultCode: "TOPOLOGY_VERIFIER_UNAVAILABLE"),
                    .init(phaseOrdinal: 11, guardID: "repository_object_format_observation_succeeded", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 12, guardID: "repository_object_format_sha1", resultCode: "TOPOLOGY_REPOSITORY_UNSUPPORTED"),
                    .init(phaseOrdinal: 13, guardID: "object_availability_observation_succeeded", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 14, guardID: "required_object_availability", resultCode: "TOPOLOGY_OBJECT_UNAVAILABLE"),
                    .init(phaseOrdinal: 15, guardID: "object_type_observation_succeeded", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 16, guardID: "required_object_type_commit", resultCode: "TOPOLOGY_OBJECT_NOT_COMMIT"),
                    .init(phaseOrdinal: 17, guardID: "object_size_observation_succeeded", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 18, guardID: "object_size_within_bound", resultCode: "TOPOLOGY_OBJECT_UNSUPPORTED"),
                    .init(phaseOrdinal: 19, guardID: "git_cat_file_transport_succeeded", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 20, guardID: "classifier_exit_status_known", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 21, guardID: "classifier_arguments_match_helper_protocol", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 22, guardID: "classifier_inherited_file_descriptors_closed", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 23, guardID: "classifier_stdin_read_succeeded", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 24, guardID: "classifier_actual_size_within_bound", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 25, guardID: "classifier_actual_size_equals_advertised_size", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 26, guardID: "classifier_computed_oid_equals_literal_oid", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 27, guardID: "classifier_input_is_nul_free", resultCode: "TOPOLOGY_OBJECT_UNSUPPORTED"),
                    .init(phaseOrdinal: 28, guardID: "classifier_parser_internal_state_valid", resultCode: "TOPOLOGY_OBSERVATION_FAILED"),
                    .init(phaseOrdinal: 29, guardID: "header_lines_and_separator_are_well_formed", resultCode: "TOPOLOGY_HEADER_MALFORMED"),
                    .init(phaseOrdinal: 30, guardID: "tree_header_is_first_and_unique", resultCode: "TOPOLOGY_HEADER_MALFORMED"),
                    .init(phaseOrdinal: 31, guardID: "ordered_parent_headers_are_contiguous", resultCode: "TOPOLOGY_HEADER_MALFORMED"),
                    .init(phaseOrdinal: 32, guardID: "topology_header_oids_are_lowercase_40hex", resultCode: "TOPOLOGY_HEADER_MALFORMED"),
                    .init(phaseOrdinal: 33, guardID: "signed_header_continuations_are_allowed_and_attached", resultCode: "TOPOLOGY_HEADER_MALFORMED"),
                    .init(phaseOrdinal: 34, guardID: "tree_oid_equals_expected", resultCode: "TOPOLOGY_MISMATCH"),
                    .init(phaseOrdinal: 35, guardID: "ordered_parent_oids_equal_expected", resultCode: "TOPOLOGY_MISMATCH"),
                ],
                phaseMajorThenRequestOrdinalMinorFirstFailureOrder: true,
                invalidInvocationRejectedBeforeGit: true,
                objectUnavailableRequiresPositiveMissingObservationForLiteralOID: true,
                mismatchRequiresAvailableCommitAndSuccessfulHeaderParse: true,
                noncommitNeverClassifiedAsObjectUnavailable: true,
                malformedNeverClassifiedAsTopologyMismatch: true,
                toolOrTransportFailureNeverClassifiedAsObjectUnavailable: true,
                fixedToolAdmissionFailureResultCode:
                    "TOPOLOGY_VERIFIER_UNAVAILABLE",
                unsupportedOrNULObjectNeverClassifiedAsTopologyMismatch: true,
                rawDiagnosticPublished: false,
                unknownFailureFailsClosed: true),
            historicalGitHubShallowEvidence: historicalEvidence,
            githubDepthTwoMultiWantMatrix: matrix,
            privateGitConstructionRecipes: privateGitRecipes,
            privateGitObjectFixtures: privateObjectFixtures,
            verifierPredicateProofPairs: proofPairs,
            verifierPredicateWitnesses: predicateWitnesses,
            verifiedEndToEndBaseline: verifiedBaseline,
            classifierDirectFixtureMatrix: directFixtureMatrix,
            helperParserFixtureMatrix: helperParserMatrix,
            staticSourceContractRegistry: staticSourceRegistry,
            sanitizedRecordContract: .init(
                schemaID: "prime_exact_revision_topology_verifier_result_v1",
                schemaVersion: 1,
                exactRequiredFieldNames: [
                    "first_failed_guard_id",
                    "missing_object_role",
                    "result_code",
                    "schema_id",
                    "schema_version",
                    "shallow_state",
                ],
                firstFailedGuardIDField: "first_failed_guard_id",
                shallowStateField: "shallow_state",
                missingObjectRoleField: "missing_object_role",
                exactShallowStateValues: ["complete", "shallow", "unavailable"],
                exactAllowedFirstFailedGuardIDs: resultsGuardIDs,
                missingObjectRoleASCIIGrammar: "^[a-z][a-z0-9_]{0,63}$",
                maximumMissingObjectRoleUTF8ByteCount: 64,
                missingObjectRoleMustEqualOneSubmittedPrevalidatedRole: true,
                shallowStateObservationCommand: "/usr/bin/git rev-parse --is-shallow-repository",
                exactShallowStateObservationArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "GIT_NO_REPLACE_OBJECTS=1", "GIT_NO_LAZY_FETCH=1",
                    "GIT_CONFIG_NOSYSTEM=1", "GIT_CONFIG_GLOBAL=/dev/null",
                    "GIT_TERMINAL_PROMPT=0", "GIT_OPTIONAL_LOCKS=0",
                    "/usr/bin/git", "-C", "<repository>", "rev-parse",
                    "--is-shallow-repository",
                ],
                shallowStateObservationStatusRequired: 0,
                maximumShallowStateObservationOutputByteCount: 6,
                shallowStateTrueOutput: "true_one_lf_maps_to_shallow",
                shallowStateFalseOutput: "false_one_lf_maps_to_complete",
                shallowStateFailureValue: "unavailable",
                shallowStateIsDiagnosticOnly: true,
                shallowStateObservationFailureChangesResultCode: false,
                shallowStateObservationFailureChangesFirstFailedGuardID: false,
                shallowStateObservationMaximumInvocationCount: 1,
                shallowStateObservationRetryCount: 0,
                shallowStateObservationInvocationCountIsZeroOrOne: true,
                shallowStateObservationExactEligibilityAndSequence:
                    "invocation_count_is_exactly_1_if_and_only_if_guards_1_through_12_all_pass_including_status0_exact_sha1_lf_storage_format_admission;otherwise_invocation_count_is_0;the_one_fixed_clean_environment_call_occurs_immediately_after_guard_12_and_before_guard_13",
                shallowStateNonzeroOrMalformedMapsToUnavailableExactlyOnce:
                    true,
                shallowStateObservationFailureAuthorizesRetry: false,
                firstFailedGuardIDIsNullIfAndOnlyIfResultVerified: true,
                missingObjectRoleIsNonNullIfAndOnlyIfResultObjectUnavailable:
                    true,
                exactResultRecordNullabilityMappings: [
                    .init(resultCode: "TOPOLOGY_VERIFIED", firstFailedGuardIDIsNull: true, missingObjectRoleIsNonNull: false),
                    .init(resultCode: "TOPOLOGY_INVOCATION_INVALID", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: false),
                    .init(resultCode: "TOPOLOGY_VERIFIER_UNAVAILABLE", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: false),
                    .init(resultCode: "TOPOLOGY_OBJECT_UNAVAILABLE", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: true),
                    .init(resultCode: "TOPOLOGY_OBJECT_NOT_COMMIT", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: false),
                    .init(resultCode: "TOPOLOGY_OBJECT_UNSUPPORTED", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: false),
                    .init(resultCode: "TOPOLOGY_REPOSITORY_UNSUPPORTED", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: false),
                    .init(resultCode: "TOPOLOGY_OBSERVATION_FAILED", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: false),
                    .init(resultCode: "TOPOLOGY_HEADER_MALFORMED", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: false),
                    .init(resultCode: "TOPOLOGY_MISMATCH", firstFailedGuardIDIsNull: false, missingObjectRoleIsNonNull: false),
                ],
                objectIDsPublished: false,
                repositoryPathsPublished: false,
                refsPublished: false,
                rawHeadersPublished: false,
                rawStandardErrorPublished: false,
                resultUsesExactTaxonomy: true,
                canonicalSortedJSONRequired: true,
                exactCanonicalJSONWireTemplate: "{\"first_failed_guard_id\":<null_or_allowed_guard_json_string>,\"missing_object_role\":<null_or_allowed_role_json_string>,\"result_code\":<allowed_result_json_string>,\"schema_id\":\"prime_exact_revision_topology_verifier_result_v1\",\"schema_version\":1,\"shallow_state\":<complete_shallow_or_unavailable_json_string>}",
                maximumCanonicalJSONByteCount: 512,
                maximumLineByteCountIncludingTerminalLF: 513,
                exactRecordCount: 1,
                exactRecordCountScope:
                    "one_complete_record_only_after_bounded_command_substitution_plus_fixed_nonnewline_status_trailer_capture_validates_exact_bytes_status_and_admitted_stdout_projection_succeeds",
                admittedWritableStdoutRequiredForProjection: true,
                projectionFailureValidCompleteRecordCount: 0,
                projectionFailureMayLeavePhysicalPartialPrefix: true,
                projectionFailureIsExternalTransportFailure: true,
                projectionFailureAuthorizesTopologyRetry: false,
                exitStatusesApplyOnlyAfterSuccessfulProjection: true,
                gateAndV2CaptureAndValidateHelperRecordBeforeProjection: true,
                successExitStatus: 0,
                nonSuccessExitStatus: 1,
                terminalLFRequired: true),
            currentAuthorityPatch: .init(
                exactOrderedPaths: currentPaths,
                exactPathCount: 5,
                modifiedExistingPathCount: 3,
                addedPathCount: 2,
                soleAuthorityTestClassName: "PrimeExactRevisionTopologyVerifierAuthorityTests",
                soleAuthorityTestMethodName: "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
                soleAuthorityTestExpectedStartCount: 1,
                soleAuthorityTestExpectedPassCount: 1,
                expectedActiveRootLatinTestCount: 116,
                expectedRootTestCount: 87,
                expectedIsolatedTestCount: 6,
                expectedFocusedWholeTestCount: 93,
                expectedRetainedLiveTestCount: 46,
                expectedAggregateTestCount: 139,
                expectedEmbeddedProvenanceRecordCount: 526,
                implementationIncluded: false,
                mechanicsIncluded: false,
                canonicalIdentityConstantsIncludedBeforeIndependentReview: false),
            futureImplementationPatch: .init(
                exactOrderedPaths: implementationPaths,
                exactPathCount: 5,
                modifiedExistingPathCount: 2,
                addedPathCount: 3,
                classifierSourcePath:
                    ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                sharedLibraryPath: ".github/scripts/prime-ci-exact-revision-topology-verifier.sh",
                sharedLibraryTestPath: ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
                gateMustSourceSharedLibrary: true,
                everyFutureLiveV2GateMustSourceSharedLibrary: true,
                everyFutureLiveV2LauncherMustSourceSharedLibrary: true,
                privateLiveAdmissionTopologyParserCountAfterImplementation: 0,
                preservedRetiredV1ParserBytesExcludedFromLiveDuplicateCount: true,
                workflowGateInvocationLiteral:
                    "source .github/scripts/prime-ci-active-root-quarantine.sh",
                workflowStepShellLiteral:
                    "/bin/bash --noprofile --norc -p -e -o pipefail -- \"{0}\"",
                workflowStepAndJobCountsPreserved: true,
                gateRequiresPrivilegedModeBeforeSourcingSharedLibrary: true,
                privilegedModeShellOptionToken: "p",
                gatePrivilegedModeAdmissionLiteral:
                    "[[ \"$-\" == *p* ]] || { builtin printf '%s\\n' 'privileged Bash mode required' >&2; exit 97; }",
                helperFirstExecutableLineLiteral:
                    "[[ \"$-\" == *p* ]] || return 97",
                helperSecondExecutableLineLiteral:
                    "builtin unset BASH_ENV ENV",
                helperDefinesNothingBeforePrivilegedModeAdmission: true,
                gatePrivilegedAdmissionIsFirstExecutableStatement: true,
                gateSecondExecutableStatementLiteral:
                    "builtin unset BASH_ENV ENV",
                gateSetAndOptionsFollowPrivilegedAdmissionAndUnset: true,
                everyChildBashParseArgumentPrefix: ["/bin/bash", "-p", "-n"],
                preToolBootstrapUsesOnlyBashBuiltins: true,
                preToolBootstrapReliesOnExactWorkingDirectory: true,
                preToolBootstrapMayInvokeDirname: false,
                innerBashGateInvocationForbidden: true,
                matrixTestInvocationLiteral:
                    "/bin/bash -p .github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
                matrixTestFirstExecutableStatementLiteral:
                    "[[ \"$-\" == *p* ]] || exit 97",
                matrixTestSecondExecutableStatementLiteral:
                    "builtin unset BASH_ENV ENV",
                futureV2LauncherInvocationLiteralPattern:
                    "/bin/bash -p <repository_relative_future_v2_launcher_path>",
                futureV2LauncherFirstExecutableStatementLiteral:
                    "[[ \"$-\" == *p* ]] || exit 97",
                futureV2LauncherSecondExecutableStatementLiteral:
                    "builtin unset BASH_ENV ENV",
                matrixTestInvokedWithPrivilegedBash: true,
                everyFutureV2LauncherInvokedWithPrivilegedBash: true,
                matrixTestInvokedOnlyFromAdmittedPrivilegedGate: true,
                separateActionsStepRequiresSamePrivilegedCustomShell: true,
                sharedHelperAPIContract: .init(
                    sourcedFunctionName:
                        "prime_verify_exact_revision_topology_v1",
                    flatArgumentGrammar:
                        "<canonical_absolute_repository> <canonical_request_count> then_for_each_position_1_through_count <role> <literal_commit_oid> <expected_tree_oid> <canonical_parent_count> <ordered_parent_oid_repeated_parent_count_times>",
                    ordinalTokensAccepted: false,
                    requestOrdinalsDerivedFromPosition: true,
                    canonicalDecimalCountsRequired: true,
                    exactArgumentConsumptionRequired: true,
                    surplusArgumentsAccepted: false,
                    maximumRequestCount: 8,
                    maximumParentCount: 8,
                    exactAllowedAmbientInputNames: ["RUNNER_TEMP"],
                    stdoutRecordCount: 1,
                    stdoutGrammar:
                        "one_bounded_canonical_sorted_six_field_JSON_record_plus_one_terminal_LF",
                    stderrPublished: false,
                    successReturnStatus: 0,
                    everyEmittedNonSuccessReturnStatus: 1,
                    gateAndEveryFutureV2UseSameFunction: true),
                bootstrapTrustContract: .init(
                    repositoryArgumentGrammar:
                        "canonical_absolute_owned_nonlink_git_worktree_root_without_dot_or_dotdot_components",
                    canonicalRepositoryRootRequired: true,
                    cleanExactHEADRequired: true,
                    exactTrackedPaths: Array(implementationPaths[1 ... 3]),
                    everyPathMustBeRegularNonlink: true,
                    exactWorktreeHashArgumentVectorPattern: [
                        "/usr/bin/git", "-C", "<canonical_repository_root>",
                        "hash-object", "--no-filters", "--", "<path>",
                    ],
                    worktreeBlobMustEqualExactIndexBlob: true,
                    admissionPrecedesHelperSourceAndClassifierCompile: true,
                    gateMayDuplicateOnlyMinimalSourceAdmission: true,
                    duplicatedTopologyParserCount: 0,
                    everyFutureV2PerformsEquivalentAdmission: true,
                    classifierCompiledFromValidatedAbsolutePath: true,
                    canonicalRepositoryRootWorkingDirectoryRequired: true,
                    hostileConcurrentSameEUIDMutationInScope: false),
                testMayCreateOnlyPrivateTemporaryGitRepositories: true,
                testMayUseNetwork: false,
                liveTestMustExerciseExactMatrixCaseIDs: matrix.filter {
                    $0.executionKind == "live_private_repository"
                }.map(\.caseID),
                pureSourceContractMustExerciseExactMatrixCaseIDs: matrix.filter {
                    $0.executionKind == "pure_source_contract"
                }.map(\.caseID),
                exactPredicateProofGuardIDs: proofPairs.map(\.guardID),
                classifierDirectFixtureCaseIDs:
                    directFixtureMatrix.map(\.caseID),
                historicalEvidenceDynamicallyReplayedByFutureMatrix: false,
                exactMainGreenRequiredBeforeV2MeasurementAuthority: true,
                implementationIncludedInCurrentAuthorityPatch: false),
            preservationContract: .init(
                exactRetiredV1Paths: [
                    ".github/scripts/prime-ci-secure-child-process-evidence-closed-fixture-canary.sh",
                    ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh",
                    "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthority.swift",
                    "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservation.swift",
                    "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementAuthority.swift",
                    "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservation.swift",
                    "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryAuthorityTests.swift",
                    "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests.swift",
                    "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityTests.swift",
                    "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementOutcomeObservationTests.swift",
                    "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift",
                ],
                retiredV1PathCount: 11,
                retiredV1LaunchersMustRemainByteIdentical: true,
                retiredV1AuthoritiesMustRemainByteIdentical: true,
                retiredV1ObservationsMustRemainByteIdentical: true,
                retiredRun160RecordRemainsTerminal: true,
                retiredRun160OpportunityRemainsRetired: true,
                existingV1LaunchersRetrofittedToSharedLibrary: false,
                packageManifestMutationAuthorized: false,
                packageLockMutationAuthorized: false,
                dependencyResolutionAuthorized: false),
            orderedPhaseASequence: [
                "implement_shared_topology_verifier_and_matrix_then_establish_exact_main_green",
                "authorize_v2_fixture_identity_measurement_in_a_new_pure_authority",
                "run_v2_fixture_identity_measurement_mechanics_once",
                "append_v2_measurement_observation_and_irreversibly_retire_the_opportunity",
                "if_measurement_is_DIFFERENT_UNAVAILABLE_or_failed_stop_terminally_without_repair_confirmation_rerun_replacement_or_canary",
                "if_measurement_is_IDENTICAL_and_current_pin_matches_authorize_no_repair_and_separately_authorize_one_no_mutation_confirmation",
                "if_measurement_is_IDENTICAL_and_current_pin_differs_separately_authorize_exact_pin_repair",
                "merge_only_the_separately_authorized_exact_pin_repair",
                "if_pin_repair_fails_stop_terminally_absent_new_authority",
                "after_identical_pin_match_or_successful_pin_repair_separately_authorize_one_no_mutation_confirmation",
                "run_the_one_separately_authorized_no_mutation_confirmation",
                "if_confirmation_fails_stop_terminally_absent_new_authority",
                "only_successful_confirmation_may_precede_a_separately_authorized_real_monitor_held_lease_canary",
                "every_failure_including_topology_helper_failure_is_terminal_and_authorizes_no_retry_or_rerun_absent_new_authority",
            ],
            exactPhaseABranchTransitions: [
                .init(ordinal: 1, state: "measurement_observed", measurementOutcome: "DIFFERENT", pinRelation: nil, prerequisite: "one_measurement_observation", exactAllowedNextAuthorityOrActionIDs: [], terminalAbsentNewAuthority: true, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 2, state: "measurement_observed", measurementOutcome: "UNAVAILABLE", pinRelation: nil, prerequisite: "one_measurement_observation", exactAllowedNextAuthorityOrActionIDs: [], terminalAbsentNewAuthority: true, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 3, state: "measurement_observed", measurementOutcome: "FAILURE", pinRelation: nil, prerequisite: "one_measurement_observation", exactAllowedNextAuthorityOrActionIDs: [], terminalAbsentNewAuthority: true, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 4, state: "measurement_observed", measurementOutcome: "IDENTICAL", pinRelation: "MATCH", prerequisite: "one_measurement_observation", exactAllowedNextAuthorityOrActionIDs: ["separate_no_mutation_confirmation_authority"], terminalAbsentNewAuthority: false, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 5, state: "measurement_observed", measurementOutcome: "IDENTICAL", pinRelation: "DIFFERENT", prerequisite: "one_measurement_observation", exactAllowedNextAuthorityOrActionIDs: ["separate_exact_pin_repair_authority"], terminalAbsentNewAuthority: false, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 6, state: "pin_repair_observed", measurementOutcome: nil, pinRelation: "REPAIRED", prerequisite: "separately_authorized_exact_pin_repair_succeeded", exactAllowedNextAuthorityOrActionIDs: ["separate_no_mutation_confirmation_authority"], terminalAbsentNewAuthority: false, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 7, state: "pin_repair_observed", measurementOutcome: nil, pinRelation: "REPAIR_FAILED", prerequisite: "separately_authorized_exact_pin_repair_failed", exactAllowedNextAuthorityOrActionIDs: [], terminalAbsentNewAuthority: true, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 8, state: "confirmation_observed", measurementOutcome: nil, pinRelation: nil, prerequisite: "separately_authorized_no_mutation_confirmation_succeeded", exactAllowedNextAuthorityOrActionIDs: ["separate_real_monitor_held_lease_canary_authority"], terminalAbsentNewAuthority: false, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 9, state: "confirmation_observed", measurementOutcome: nil, pinRelation: nil, prerequisite: "separately_authorized_no_mutation_confirmation_failed", exactAllowedNextAuthorityOrActionIDs: [], terminalAbsentNewAuthority: true, retryRerunReplacementOrImplicitCanaryAuthorized: false),
                .init(ordinal: 10, state: "topology_helper_failed", measurementOutcome: nil, pinRelation: nil, prerequisite: "any_topology_helper_failure", exactAllowedNextAuthorityOrActionIDs: [], terminalAbsentNewAuthority: true, retryRerunReplacementOrImplicitCanaryAuthorized: false),
            ],
            authorityCeiling: .init(
                currentExactMainClosureEstablished: true,
                retiredRun160ClosureEstablished: true,
                run160FailureCauseRemainsInference: true,
                currentPatchAddsOnlyPureAuthorityPair: true,
                futureImplementationScopeFrozen: true,
                futureImplementationMayProceedOnlyAfterAuthorityExactMainGreen: true,
                filesystemReadPerformed: false,
                filesystemWritePerformed: false,
                processExecutionPerformed: false,
                gitExecutionPerformed: false,
                networkExecutionPerformed: false,
                modelExecutionPerformed: false,
                leaseExecutionPerformed: false,
                verifierImplementationPerformed: false,
                verifierMechanicsPerformed: false,
                v2MeasurementAuthorityEstablished: false,
                v2MeasurementMechanicsPerformed: false,
                v2MeasurementObservationEstablished: false,
                fixtureIdentityEstablished: false,
                repeatBuildDeterminismEstablished: false,
                currentPinMatchEstablished: false,
                currentPinMismatchEstablished: false,
                pinRepairAuthorized: false,
                pinRepairPerformed: false,
                confirmationAuthorized: false,
                confirmationPerformed: false,
                realCanaryAuthorized: false,
                realCanaryPerformed: false,
                retryOrRerunAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false),
            status: "AUTHORITY_ONLY_current_signed_merge_run162_green_retired_run160_closed_future_shared_raw_header_topology_verifier_scope_frozen_no_mechanics_v2_measurement_pin_repair_confirmation_or_canary")
    }()

    private static func path(
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

    private static func resultCode(forGuard guardID: String) -> String {
        switch guardID {
        case "literal_commit_oid_is_lowercase_40hex",
             "expected_topology_oids_are_lowercase_40hex",
             "verification_request_count_nonzero",
             "verification_request_count_within_bound",
             "repository_argument_is_canonical_absolute_admitted_git_worktree",
             "request_role_matches_ascii_allowlist_grammar",
             "request_roles_are_unique",
             "expected_parent_count_within_bound":
            return "TOPOLOGY_INVOCATION_INVALID"
        case "fixed_verifier_tools_admitted",
             "classifier_build_and_self_test_admitted":
            return "TOPOLOGY_VERIFIER_UNAVAILABLE"
        case "repository_object_format_sha1":
            return "TOPOLOGY_REPOSITORY_UNSUPPORTED"
        case "required_object_availability":
            return "TOPOLOGY_OBJECT_UNAVAILABLE"
        case "required_object_type_commit":
            return "TOPOLOGY_OBJECT_NOT_COMMIT"
        case "object_size_within_bound", "classifier_input_is_nul_free":
            return "TOPOLOGY_OBJECT_UNSUPPORTED"
        case "header_lines_and_separator_are_well_formed",
             "tree_header_is_first_and_unique",
             "ordered_parent_headers_are_contiguous",
             "topology_header_oids_are_lowercase_40hex",
             "signed_header_continuations_are_allowed_and_attached":
            return "TOPOLOGY_HEADER_MALFORMED"
        case "tree_oid_equals_expected",
             "ordered_parent_oids_equal_expected":
            return "TOPOLOGY_MISMATCH"
        default:
            return "TOPOLOGY_OBSERVATION_FAILED"
        }
    }

    private static let resultGuardOrder = [
        "literal_commit_oid_is_lowercase_40hex",
        "expected_topology_oids_are_lowercase_40hex",
        "verification_request_count_nonzero",
        "verification_request_count_within_bound",
        "repository_argument_is_canonical_absolute_admitted_git_worktree",
        "request_role_matches_ascii_allowlist_grammar",
        "request_roles_are_unique",
        "expected_parent_count_within_bound",
        "fixed_verifier_tools_admitted",
        "classifier_build_and_self_test_admitted",
        "repository_object_format_observation_succeeded",
        "repository_object_format_sha1",
        "object_availability_observation_succeeded",
        "required_object_availability",
        "object_type_observation_succeeded",
        "required_object_type_commit",
        "object_size_observation_succeeded",
        "object_size_within_bound",
        "git_cat_file_transport_succeeded",
        "classifier_exit_status_known",
        "classifier_arguments_match_helper_protocol",
        "classifier_inherited_file_descriptors_closed",
        "classifier_stdin_read_succeeded",
        "classifier_actual_size_within_bound",
        "classifier_actual_size_equals_advertised_size",
        "classifier_computed_oid_equals_literal_oid",
        "classifier_input_is_nul_free",
        "classifier_parser_internal_state_valid",
        "header_lines_and_separator_are_well_formed",
        "tree_header_is_first_and_unique",
        "ordered_parent_headers_are_contiguous",
        "topology_header_oids_are_lowercase_40hex",
        "signed_header_continuations_are_allowed_and_attached",
        "tree_oid_equals_expected",
        "ordered_parent_oids_equal_expected",
    ]

    private static func guardsBefore(_ guardID: String) -> [String] {
        guard let index = resultGuardOrder.firstIndex(of: guardID) else {
            preconditionFailure("unknown guard")
        }
        return Array(resultGuardOrder.prefix(index))
    }

    private static func predicateExecutionKind(_ guardID: String) -> String {
        switch guardID {
        case "classifier_arguments_match_helper_protocol",
             "classifier_stdin_read_succeeded",
             "classifier_actual_size_within_bound",
             "classifier_actual_size_equals_advertised_size",
             "classifier_computed_oid_equals_literal_oid",
             "classifier_input_is_nul_free",
             "header_lines_and_separator_are_well_formed",
             "tree_header_is_first_and_unique",
             "ordered_parent_headers_are_contiguous",
             "topology_header_oids_are_lowercase_40hex",
             "signed_header_continuations_are_allowed_and_attached",
             "tree_oid_equals_expected",
             "ordered_parent_oids_equal_expected":
            return "direct_classifier_fixture"
        case "required_object_availability",
             "required_object_type_commit":
            return "private_git_end_to_end"
        case "classifier_parser_internal_state_valid",
             "classifier_inherited_file_descriptors_closed",
             "fixed_verifier_tools_admitted",
             "classifier_build_and_self_test_admitted":
            return "static_source_contract"
        default:
            return "direct_helper_parser_fixture"
        }
    }

    private static func predicateWitness(
        ordinal: Int,
        guardID: String,
        predicateValue: Bool,
        passedGuardIDs: [String]
    ) -> PredicateWitness {
        let kind = predicateExecutionKind(guardID)
        let expectedResult = predicateValue
            ? "TOPOLOGY_VERIFIED"
            : resultCode(forGuard: guardID)
        let polarity = predicateValue ? "positive" : "negative"
        return .init(
            ordinal: ordinal,
            witnessID: "predicate_\(guardID)_\(polarity)",
            guardID: guardID,
            predicateValue: predicateValue,
            witnessKind: predicateValue
                ? "private_git_end_to_end_verified_baseline" : kind,
            classifierCaseID: !predicateValue
                && kind == "direct_classifier_fixture"
                ? "classifier_predicate_\(guardID)_\(polarity)"
                : nil,
            helperParserCaseID: !predicateValue
                && kind == "direct_helper_parser_fixture"
                ? "helper_parser_predicate_\(guardID)_\(polarity)"
                : nil,
            privateGitMatrixCaseID: !predicateValue
                && kind == "private_git_end_to_end"
                ? privateGitNegativeCaseID(forGuard: guardID)
                : nil,
            staticCheckID: !predicateValue
                && kind == "static_source_contract"
                ? "static_check_\(guardID)_\(polarity)"
                : nil,
            verifiedBaselineID: predicateValue
                ? "private_git_end_to_end_verified_baseline" : nil,
            passedGuardIDs: passedGuardIDs,
            expectedResultCode: expectedResult,
            expectedFirstFailedGuardID: predicateValue ? nil : guardID,
            syntheticOIDClaimedFetched: false)
    }

    private static func privateGitNegativeCaseID(forGuard guardID: String)
        -> String
    {
        switch guardID {
        case "required_object_availability":
            return "well_formed_exact_revision_oid_is_absent"
        case "required_object_type_commit":
            return "noncommit_object_at_literal_oid"
        case "object_size_within_bound":
            return "oversized_commit_object_is_rejected_before_raw_content_stream"
        default:
            preconditionFailure("non-private guard")
        }
    }

    private static func classifierExitStatus(forGuard guardID: String) -> Int {
        switch guardID {
        case "classifier_arguments_match_helper_protocol": return 20
        case "classifier_stdin_read_succeeded": return 21
        case "classifier_actual_size_within_bound": return 22
        case "classifier_actual_size_equals_advertised_size": return 23
        case "classifier_computed_oid_equals_literal_oid": return 24
        case "classifier_input_is_nul_free": return 25
        case "header_lines_and_separator_are_well_formed": return 30
        case "tree_header_is_first_and_unique": return 31
        case "ordered_parent_headers_are_contiguous": return 32
        case "topology_header_oids_are_lowercase_40hex": return 33
        case "signed_header_continuations_are_allowed_and_attached": return 34
        case "tree_oid_equals_expected": return 41
        case "ordered_parent_oids_equal_expected": return 42
        default: return 26
        }
    }

    private static func predicateFixture(
        guardID: String,
        predicateValue: Bool,
        writesPrivateGitObject: Bool
    ) -> SyntheticFixtureContract {
        let values: (String, Int, String, String)
        switch (guardID, predicateValue) {
        case ("classifier_actual_size_within_bound", false):
            return .init(
                constructionKind: "base64_prefix_then_repeated_ascii_byte",
                payloadEncoding: "base64_prefix_plus_ascii_x_repeat",
                payloadRecipe: "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCg==_then_1048577_ascii_x_bytes",
                payloadByteCount: 1_048_725,
                payloadSHA256: "592feda5466a4618c63aba4e0fb7e79a8544add5db6f3136bbeef70ae2745517",
                literalObjectOID: "2df897f0b9eb39f944c1b868288d1632a8a81882",
                privateRepositoryConstructionAPI:
                    "direct_classifier_stdin_recipe_no_object_write",
                objectWrittenIntoPrivateRepository: false,
                literalOIDRecomputedAndRequiredEqualBeforeUse: true)
        case ("classifier_input_is_nul_free", false):
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKWABZCgpudWwK",
                156,
                "91d9163d6747a197317b27d49ae7a62973b0b69fadb38c89861693e31de208a2",
                "69c4a7f67cf2a86ba9c9bdf3c37c4ca1eb824981")
        case ("header_lines_and_separator_are_well_formed", false):
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvcgpjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKbWlzc2luZy1zZXBhcmF0b3I=",
                122,
                "d6860151f7ebeb89970af1a1f575862461c0af2c9b666c361ac7f6495b2bba6e",
                "f6ddbe0d01ecfe0c46bcb1d41f0d17b109fcb74c")
        case ("tree_header_is_first_and_unique", false):
            values = (
                "YXV0aG9yIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCnRyZWUgOWRkODg0YmZlNWI1MjBhNjdjMjk0NGQ4ZjhmNzk4NTFhNzE0NTE5ZQpjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm1hbGZvcm1lZCB0cmVlIG9yZGVyCg==",
                169,
                "1e8f63f3e256c84b0798cd1a36daae87bb3f3be2cc98f07eb30d4b290f1bc5ec",
                "28d89d60036ae440b8a45b54b6661dc6fca60dac")
        case ("ordered_parent_headers_are_contiguous", false):
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApwYXJlbnQgZjVkYjcxMDFjZjM1MzhkYWFlMTAzYmE1NjYwMWE1MDlhZDhiYWQ4MApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmludmFsaWQgcGFyZW50IG9yZGVyCg==",
                265,
                "762c664fe5e0a567ace046c3b06042010a2a400241dc8c27e9fc4add5a11628b",
                "2ec9cd64a02b6f74ff70c7f13f44bca335e28c9d")
        case ("topology_header_oids_are_lowercase_40hex", false):
            values = (
                "dHJlZSA5REQ4ODRCRkU1QjUyMEE2N0MyOTQ0RDhGOEY3OTg1MUE3MTQ1MTlFCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmludmFsaWQgb2lkCg==",
                160,
                "b4c2d6923e862dcdb4a7188ab806fb0590696598c5561577466d520a77128702",
                "53104c97a375dca311022fac179abe8cc10608c9")
        case ("signed_header_continuations_are_allowed_and_attached", false):
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmdwZ3NpZyBmaXJzdAogb25lCmdwZ3NpZyBzZWNvbmQKIHR3bwphdXRob3IgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKY29tbWl0dGVyIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCgppbnZhbGlkIHJlcGVhdGVkCg==",
                202,
                "72211b236486077b7f6dbecea3e3f6a186164d60f0c31904c6786d8d2a906b4b",
                "def052e18ac2935a3aa7be52e41b8769aed676b2")
        case ("tree_oid_equals_expected", false):
            values = (
                "dHJlZSA5YjhhNzg0ZTYwNTk2NzE0MWYxNTlhNWY4Yzk1M2EwMDk2Y2YxZjhkCnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmNWRiNzEwMWNmMzUzOGRhYWUxMDNiYTU2NjAxYTUwOWFkOGJhZDgwCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIHRyZWUK",
                255,
                "7d0faa211805a07faa4420ea7b07169ec65864b3ae3e87ff0d2d8b6cc1df25e8",
                "c0763d20513bfb5a4734df0a30745ae55b5f40bc")
        case ("ordered_parent_oids_equal_expected", false):
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCnBhcmVudCBmNWRiNzEwMWNmMzUzOGRhYWUxMDNiYTU2NjAxYTUwOWFkOGJhZDgwCnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnJlb3JkZXJlZCBwYXJlbnRzCg==",
                262,
                "573f031c9b397b18c21602c3e49e45665b77c4b1942cab5e11c1309d66ff5295",
                "32c5e6d59819d83e270bdac42a21017ff6548fc7")
        default:
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmdwZ3NpZy1zaGEyNTYgLS0tLS1CRUdJTiBTSUdOQVRVUkUtLS0tLQogY29udGludWF0aW9uCiAKYXV0aG9yIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCmNvbW1pdHRlciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMAoKdmFsaWQgc2lnbmVkCg==",
                217,
                "60de4641092d753b41c1ed3625aadb2fa0b3ae67317c0431ff06d1718524d6c0",
                "97fc8c60b69343b4e00efd85e8f3ba13fd7e652a")
        }
        return .init(
            constructionKind: "base64_exact_bytes",
            payloadEncoding: "base64_exact_bytes",
            payloadRecipe: values.0,
            payloadByteCount: values.1,
            payloadSHA256: values.2,
            literalObjectOID: values.3,
            privateRepositoryConstructionAPI: writesPrivateGitObject
                ? "/usr/bin/git hash-object --literally -t commit -w --stdin"
                : "direct_classifier_stdin_no_object_write",
            objectWrittenIntoPrivateRepository: writesPrivateGitObject,
            literalOIDRecomputedAndRequiredEqualBeforeUse: true)
    }

    private static func directFixtureCase(
        _ ordinal: Int,
        _ caseID: String,
        _ guardID: String,
        _ predicateValue: Bool,
        _ fixture: SyntheticFixtureContract,
        _ arguments: [String],
        _ exitStatus: Int,
        _ resultCode: String,
        _ failedGuardID: String?,
        _ harnessSetup: String? = nil
    ) -> ClassifierDirectFixtureCase {
        .init(
            ordinal: ordinal,
            caseID: caseID,
            guardID: guardID,
            predicateValue: predicateValue,
            passedGuardIDs: predicateValue ? [] : guardsBefore(guardID),
            fixture: fixture,
            exactArgumentVector: arguments,
            harnessSetupContract: harnessSetup,
            expectedExitStatus: exitStatus,
            expectedResultCode: resultCode,
            expectedFirstFailedGuardID: failedGuardID,
            dynamicallyExecutable: true)
    }

    private static func classifierPredicateCase(
        ordinal: Int,
        guardID: String,
        predicateValue: Bool
    ) -> ClassifierDirectFixtureCase {
        let fixture = predicateFixture(
            guardID: guardID,
            predicateValue: predicateValue,
            writesPrivateGitObject: false)
        var arguments = classifierArguments(fixture: fixture)
        if !predicateValue {
            switch guardID {
            case "classifier_arguments_match_helper_protocol":
                arguments.removeLast()
            case "classifier_actual_size_within_bound":
                arguments[2] = "1048576"
            case "classifier_actual_size_equals_advertised_size":
                arguments[2] = "216"
            case "classifier_computed_oid_equals_literal_oid":
                arguments[1] = "0000000000000000000000000000000000000000"
            case "ordered_parent_oids_equal_expected":
                arguments = [
                    arguments[0], fixture.literalObjectOID,
                    String(fixture.payloadByteCount),
                    "9dd884bfe5b520a67c2944d8f8f79851a714519e", "2",
                    "fe0ad36a9163aaa0e03478f5556dfb34b70e24e7",
                    "f5db7101cf3538daae103ba56601a509ad8bad80",
                ]
            default:
                break
            }
        }
        return directFixtureCase(
            ordinal,
            "classifier_predicate_\(guardID)_\(predicateValue ? "positive" : "negative")",
            guardID,
            predicateValue,
            fixture,
            arguments,
            predicateValue ? 0 : classifierExitStatus(forGuard: guardID),
            predicateValue ? "TOPOLOGY_VERIFIED" : resultCode(forGuard: guardID),
            predicateValue ? nil : guardID,
            !predicateValue && guardID == "classifier_stdin_read_succeeded"
                ? "invoke_with_fd0_open_read_only_on_private_directory_to_induce_Darwin_read_EISDIR"
                : nil)
    }

    private static func classifierArguments(
        fixture: SyntheticFixtureContract
    ) -> [String] {
        [
            "<validated_private_classifier_executable>",
            fixture.literalObjectOID,
            String(fixture.payloadByteCount),
            "9dd884bfe5b520a67c2944d8f8f79851a714519e",
            "0",
        ]
    }

    private static func helperParserCase(
        ordinal: Int,
        guardID: String,
        predicateValue: Bool
    ) -> HelperParserFixtureCase {
        let oid = "97fc8c60b69343b4e00efd85e8f3ba13fd7e652a"
        let tree = "9dd884bfe5b520a67c2944d8f8f79851a714519e"
        var requests = [request(1, "exact_revision", oid, tree, [])]
        var repositoryArgument = "/private/tmp/prime-topology-fixture/repository"
        let observationKind = helperObservationKind(guardID)
        var gitStatus: Int?
        var classifierStatus: Int?
        var output = ""
        switch observationKind {
        case "repository_format":
            gitStatus = 0
            output = "c2hhMQo="
        case "batch_preprobe":
            gitStatus = 0
            output = "OTdmYzhjNjBiNjkzNDNiNGUwMGVmZDg1ZThmM2JhMTNmZDdlNjUyYSBjb21taXQgMjE3Cg=="
        case "pipeline_status":
            gitStatus = 0
            classifierStatus = 0
        default:
            break
        }
        if !predicateValue {
            switch guardID {
            case "literal_commit_oid_is_lowercase_40hex":
                requests = [request(1, "exact_revision", "HEAD", tree, [])]
            case "expected_topology_oids_are_lowercase_40hex":
                requests = [request(1, "exact_revision", oid, "HEAD", [])]
            case "verification_request_count_nonzero":
                requests = []
            case "verification_request_count_within_bound":
                requests = (1 ... 9).map {
                    request($0, "request_\($0)", oid, tree, [])
                }
            case "repository_argument_is_canonical_absolute_admitted_git_worktree":
                repositoryArgument = "relative/repository"
            case "request_role_matches_ascii_allowlist_grammar":
                requests = [request(1, "BAD_ROLE", oid, tree, [])]
            case "request_roles_are_unique":
                requests = [
                    request(1, "exact_revision", oid, tree, []),
                    request(2, "exact_revision", oid, tree, []),
                ]
            case "expected_parent_count_within_bound":
                requests = [request(
                    1, "exact_revision", oid, tree,
                    Array(repeating: oid, count: 9))]
            case "repository_object_format_observation_succeeded":
                gitStatus = 1
                output = ""
            case "repository_object_format_sha1":
                output = "c2hhMjU2Cg=="
            case "object_availability_observation_succeeded":
                output = "OTdmYzhjNjBiNjkzNDNiNGUwMGVmZDg1ZThmM2JhMTNmZDdlNjUyYSBjb21taXQgMjE3IGV4dHJhCg=="
            case "object_type_observation_succeeded":
                output = "OTdmYzhjNjBiNjkzNDNiNGUwMGVmZDg1ZThmM2JhMTNmZDdlNjUyYSB3ZWlyZCAyMTcK"
            case "object_size_observation_succeeded":
                output = "OTdmYzhjNjBiNjkzNDNiNGUwMGVmZDg1ZThmM2JhMTNmZDdlNjUyYSBjb21taXQgMDIxNwo="
            case "object_size_within_bound":
                output = "OTdmYzhjNjBiNjkzNDNiNGUwMGVmZDg1ZThmM2JhMTNmZDdlNjUyYSBjb21taXQgMTA0ODU3Nwo="
            case "classifier_exit_status_known":
                classifierStatus = 19
            case "git_cat_file_transport_succeeded":
                gitStatus = 1
                classifierStatus = 0
            default:
                break
            }
        } else if guardID == "classifier_exit_status_known" {
            classifierStatus = 0
        }
        return .init(
            ordinal: ordinal,
            caseID:
                "helper_parser_predicate_\(guardID)_\(predicateValue ? "positive" : "negative")",
            guardID: guardID,
            predicateValue: predicateValue,
            observationKind: observationKind,
            passedGuardIDs: predicateValue ? [] : guardsBefore(guardID),
            repositoryArgument: repositoryArgument,
            requestVector: requests,
            savedGitStatus: gitStatus,
            savedClassifierStatus: classifierStatus,
            boundedObservationStdoutBase64: output,
            expectedResultCode: predicateValue
                ? nil : resultCode(forGuard: guardID),
            expectedFirstFailedGuardID: predicateValue ? nil : guardID)
    }

    private static let invocationGuardIDs: Set<String> = [
        "literal_commit_oid_is_lowercase_40hex",
        "expected_topology_oids_are_lowercase_40hex",
        "verification_request_count_nonzero",
        "verification_request_count_within_bound",
        "repository_argument_is_canonical_absolute_admitted_git_worktree",
        "request_role_matches_ascii_allowlist_grammar",
        "request_roles_are_unique",
        "expected_parent_count_within_bound",
    ]

    private static func helperObservationKind(_ guardID: String) -> String {
        if invocationGuardIDs.contains(guardID) { return "invocation" }
        if guardID == "repository_object_format_observation_succeeded"
            || guardID == "repository_object_format_sha1"
        {
            return "repository_format"
        }
        if guardID == "classifier_exit_status_known"
            || guardID == "git_cat_file_transport_succeeded"
        {
            return "pipeline_status"
        }
        return "batch_preprobe"
    }

    private static func verifiedBaselineFixture() -> SyntheticFixtureContract {
        .init(
            constructionKind: "base64_exact_bytes",
            payloadEncoding: "base64_exact_bytes",
            payloadRecipe:
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmdwZ3NpZy1zaGEyNTYgLS0tLS1CRUdJTiBTSUdOQVRVUkUtLS0tLQogY29udGludWF0aW9uCiAKYXV0aG9yIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCmNvbW1pdHRlciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMAoKdmFsaWQgc2lnbmVkCg==",
            payloadByteCount: 217,
            payloadSHA256:
                "60de4641092d753b41c1ed3625aadb2fa0b3ae67317c0431ff06d1718524d6c0",
            literalObjectOID:
                "97fc8c60b69343b4e00efd85e8f3ba13fd7e652a",
            privateRepositoryConstructionAPI:
                "/usr/bin/git hash-object --literally -t commit -w --stdin",
            objectWrittenIntoPrivateRepository: true,
            literalOIDRecomputedAndRequiredEqualBeforeUse: true)
    }

    private static func privateGraphFixture(
        ordinal: Int
    ) -> PrivateGitObjectFixture {
        let values: (String, String, String, Int, String, String)
        switch ordinal {
        case 1:
            values = ("base", "commit", "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmJhc2UK", 153, "1e862b9f8079de2cccabfef3d43c46c245c11e1d6feb08bb8dd7b8d602a8eaaf", "de16c5f7dd233165813ffa72719869e3181c554b")
        case 2:
            values = ("authority_head", "commit", "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmF1dGhvcml0eSBoZWFkCg==", 163, "313e05db107d4146979a2fca78ba1e52e1a8edac9e62d9be613b5d07c5d1aad6", "29f94086df954f31dd73f9fb353327c45b6ca734")
        case 3:
            values = ("authority_merge", "commit", "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCBkZTE2YzVmN2RkMjMzMTY1ODEzZmZhNzI3MTk4NjllMzE4MWM1NTRiCnBhcmVudCAyOWY5NDA4NmRmOTU0ZjMxZGQ3M2Y5ZmIzNTMzMjdjNDViNmNhNzM0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmF1dGhvcml0eSBtZXJnZQo=", 260, "1061893a2a8470ae4cfd144f979914e1c1b537b515586ce0c45c23a44e1e977b", "439babc1a7d1e964194ee16781af5d021ef87de0")
        case 4:
            values = ("mechanics_head", "commit", "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA0MzliYWJjMWE3ZDFlOTY0MTk0ZWUxNjc4MWFmNWQwMjFlZjg3ZGUwCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm1lY2hhbmljcyBoZWFkCg==", 211, "8672ba6440b127352b6bc2420bdb8a77261359411b55c0611a96bccd917a7aed", "10d6ac61fa70a42d79cad2b1312be27fc79a2285")
        case 5:
            values = ("mechanics_merge", "commit", "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA0MzliYWJjMWE3ZDFlOTY0MTk0ZWUxNjc4MWFmNWQwMjFlZjg3ZGUwCnBhcmVudCAxMGQ2YWM2MWZhNzBhNDJkNzljYWQyYjEzMTJiZTI3ZmM3OWEyMjg1CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm1lY2hhbmljcyBtZXJnZQo=", 260, "334cb8099cc863deb8e20ff4b27c3d0d983499e3845e7239ec1ed0a657e62249", "d55dc8f15242757e6e11c1e2d48c4f576647718b")
        case 6:
            values = ("current_head", "commit", "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCBkNTVkYzhmMTUyNDI3NTdlNmUxMWMxZTJkNDhjNGY1NzY2NDc3MThiCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmN1cnJlbnQgaGVhZAo=", 209, "a3921995faf4a6df40380ec6cdff63d045dcfd5450b22f3e5a18d90539f3015d", "f206f3b462c801eee54d5666376b04fd66cb1204")
        case 7:
            values = ("signed_current_merge", "commit", "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCBkNTVkYzhmMTUyNDI3NTdlNmUxMWMxZTJkNDhjNGY1NzY2NDc3MThiCnBhcmVudCBmMjA2ZjNiNDYyYzgwMWVlZTU0ZDU2NjYzNzZiMDRmZDY2Y2IxMjA0CmdwZ3NpZyAtLS0tLUJFR0lOIFNJR05BVFVSRS0tLS0tCiBjb250aW51YXRpb24KIApncGdzaWctc2hhMjU2IHNoYTI1Ni1zaWduYXR1cmUKIGNvbnRpbnVhdGlvbgphdXRob3IgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKY29tbWl0dGVyIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCgpzaWduZWQgY3VycmVudCBtZXJnZQo=", 359, "50fab27e875b39011e8a2226f0a19de68052bf1f0b861660f887fa8cb7038e24", "0ae1df33a6161b338d23011bad2d330efea7e1f8")
        case 8:
            values = ("unrelated", "commit", "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnVucmVsYXRlZAo=", 158, "f9ea564f1cd206fc34b0c6bcebcc989e27990c9bc4e02d79452bd4e7408988df", "2bd406f9651e236af795d8dfe65af46287e6653d")
        default:
            values = ("noncommit_blob", "blob", "YmxvYiBmaXh0dXJlCg==", 13, "98c86da8b401a0b26aafdb4dd03bf01f80980f4a027bad63bbc354164391fbeb", "12427a0d08f8767d46c01e41f86401ea3cb13126")
        }
        return .init(
            ordinal: ordinal,
            fixtureID: "private_git_object_\(values.0)",
            objectType: values.1,
            fixture: .init(
                constructionKind: "base64_exact_bytes",
                payloadEncoding: "base64_exact_bytes",
                payloadRecipe: values.2,
                payloadByteCount: values.3,
                payloadSHA256: values.4,
                literalObjectOID: values.5,
                privateRepositoryConstructionAPI:
                    "/usr/bin/git hash-object --literally -t \(values.1) -w --stdin",
                objectWrittenIntoPrivateRepository: true,
                literalOIDRecomputedAndRequiredEqualBeforeUse: true))
    }

    private static func cleanGitArgumentVector(_ suffix: [String]) -> [String] {
        [
            "/usr/bin/env", "-i", "LC_ALL=C",
            "TMPDIR=<validated_private_compiler_root>",
            "GIT_NO_REPLACE_OBJECTS=1", "GIT_NO_LAZY_FETCH=1",
            "GIT_CONFIG_NOSYSTEM=1", "GIT_CONFIG_GLOBAL=/dev/null",
            "GIT_TERMINAL_PROMPT=0", "GIT_OPTIONAL_LOCKS=0",
            "/usr/bin/git",
        ] + suffix
    }

    private static func supplementalFixture(
        _ fixtureID: String
    ) -> SyntheticFixtureContract {
        let values: (String, Int, String, String)
        switch fixtureID {
        case "valid_both_signatures":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmdwZ3NpZyBvbmUKIGNvbnRpbnVhdGlvbgpncGdzaWctc2hhMjU2IHR3bwogY29udGludWF0aW9uCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnZhbGlkIGJvdGgK",
                216,
                "aba82257728cc24179954c8fbe46e5a87bf0417c84fdd4b6cdd7199773f2bda1",
                "b49cbd0cbb5a0e812f1e7efa4dd03d54a3eb1866")
        case "repeated_gpgsig_sha256":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmdwZ3NpZy1zaGEyNTYgb25lCiB4CmdwZ3NpZy1zaGEyNTYgdHdvCiB5CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnJlcGVhdAo=",
                197,
                "8d2854636a729d26a441e146af6c25bb68ee8ca41cfc246504a776fb67744881",
                "9b5d8a3519f1706fa85a565db0f5cc65f47455d6")
        case "continuation_after_author":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMAogaW52YWxpZApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmJhZCBjb250aW51YXRpb24K",
                174,
                "f191a5d9ef2469404ddba84014d844501ce6ab1ba945b7592723bc5e260b870e",
                "5b9ed00816e31e9c582139b5d9db9358171ca73a")
        case "malformed_physical_field":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvcgpjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmJhZCBmaWVsZAo=",
                116,
                "0e5d5d0feecb9c4ea297f474a822d44f48ea440e55035016c1e22a1362e72ddc",
                "125be86b012c03fd7859d8faa2793fadbca6c6e0")
        case "missing_separator":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKbWlzc2luZyBzZXBhcmF0b3I=",
                164,
                "cbae63be85c035cbcec5fb691db855f757d8d1809835d4b52aea05a5efc00d68",
                "070b3117017a0026fc976d9c23b14fed379d24cc")
        case "nul_message":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm1lc3NhZ2UAbnVsCg==",
                160,
                "28e4b8db01a01dfcc4b58c96374783199bc11e977b6ba307250b38b27e62da56",
                "3d6e1d07509fa132d8b52dd7c1adfb0e3b887a4f")
        case "cr_header":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllDQphdXRob3IgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKY29tbWl0dGVyIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCgpiYWQgY3IK",
                156,
                "3f999e55a828daad57a86a6e5139d84dc17a022e37edfb9914e4366736228cd0",
                "db383f55c0d7c29edeb8854c0010f8ce261e29d5")
        case "cr_message":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm1lc3NhZ2UNYWNjZXB0ZWQK",
                165,
                "f94fe258e4143d5c950c9c447a3e7fd1a56ea71d0109b4c39244a73b2facf86f",
                "1a4291cb132ae10b0ac64ed5200df3ebcd6d779b")
        case "nine_actual_parents":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm5pbmUgcGFyZW50cwo=",
                593,
                "2b62be1d0957c8d78cbeb3dfaeda36d232d36b012de6f277166506ae20070346",
                "fe3063e42d3c1ded9591af9ea897f88f23f470ba")
        case "valid_repeated_mergetag":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCm1lcmdldGFnIG9iamVjdCAxMTExMTExMTExMTExMTExMTExMTExMTExMTExMTExMTExMTExMTExCiAKbWVyZ2V0YWcgb2JqZWN0IDIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIKIHNlY29uZAphdXRob3IgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKY29tbWl0dGVyIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCgp2YWxpZCB0YWdzCg==",
                283,
                "8373f0e27de6ab00dbab8445a283fa9677f77b10e870e7ad41c292333f24a7b6",
                "86bb2e2978346563fa8847a5394325d78aed688b")
        case "unattached_continuation":
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCiBvcnBoYW4KYXV0aG9yIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCmNvbW1pdHRlciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMAoKaW52YWxpZCBjb250aW51YXRpb24K",
                177,
                "5b877b7232e5a8e44ce6ef94e19295ce23c8c6996423d80106199a289e197655",
                "0c2ad297d272e8c725baa9ab44a4307c0d5a00a9")
        case "zero_byte_commit":
            values = (
                "", 0,
                "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                "dcf5b16e76cce7425d0beaef62d79a7d10fce1f5")
        default:
            values = (
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmdwZ3NpZy1zaGEyNTYgLS0tLS1CRUdJTiBTSUdOQVRVUkUtLS0tLQogY29udGludWF0aW9uCiAKYXV0aG9yIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCmNvbW1pdHRlciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMAoKdmFsaWQgc2lnbmVkCg==",
                217,
                "60de4641092d753b41c1ed3625aadb2fa0b3ae67317c0431ff06d1718524d6c0",
                "97fc8c60b69343b4e00efd85e8f3ba13fd7e652a")
        }
        return .init(
            constructionKind: "base64_exact_bytes",
            payloadEncoding: "base64_exact_bytes",
            payloadRecipe: values.0,
            payloadByteCount: values.1,
            payloadSHA256: values.2,
            literalObjectOID: values.3,
            privateRepositoryConstructionAPI:
                "direct_classifier_stdin_no_object_write",
            objectWrittenIntoPrivateRepository: false,
            literalOIDRecomputedAndRequiredEqualBeforeUse: true)
    }

    private static func request(
        _ ordinal: Int,
        _ role: String,
        _ oid: String,
        _ tree: String,
        _ parents: [String]
    ) -> VerificationRequest {
        .init(
            ordinal: ordinal,
            objectRole: role,
            literalCommitOID: oid,
            expectedTreeOID: tree,
            expectedOrderedParentOIDs: parents)
    }

    private static func rerole(
        _ ordinal: Int,
        _ role: String,
        _ value: VerificationRequest
    ) -> VerificationRequest {
        request(
            ordinal, role, value.literalCommitOID, value.expectedTreeOID,
            value.expectedOrderedParentOIDs)
    }

    private static func matrixCase(
        _ ordinal: Int,
        _ caseID: String,
        _ fetchDepth: Int,
        _ wants: [String],
        _ suppliedRevisionToken: String,
        _ requests: [VerificationRequest],
        _ availableRoles: [String],
        _ shallowState: String,
        _ injectedCondition: String,
        _ legacyPorcelainResolves: Bool,
        _ rawHeadersSufficient: Bool,
        _ resultCode: String,
        _ failedGuard: String?,
        _ missingRole: String?,
        _ executionKind: String = "live_private_repository"
    ) -> GitHubDepthTwoMultiWantMatrixCase {
        .init(
            ordinal: ordinal,
            caseID: caseID,
            fetchDepth: fetchDepth,
            explicitWantOIDs: wants,
            suppliedRevisionToken: suppliedRevisionToken,
            verificationRequests: requests,
            availableObjectRoles: availableRoles,
            executionKind: executionKind,
            privateGitRecipeID: privateGitRecipeID(
                caseID: caseID, executionKind: executionKind),
            shallowState: shallowState,
            injectedCondition: injectedCondition,
            legacyPorcelainAncestryProbeExpectedToResolve:
                legacyPorcelainResolves,
            legacyPorcelainAncestryProbeExecuted:
                caseID
                    == "private_github_style_depth2_multi_want_porcelain_fails_raw_headers_verify",
            legacyPorcelainProbeCommandContract:
                caseID
                    == "private_github_style_depth2_multi_want_porcelain_fails_raw_headers_verify"
                    ? "/usr/bin/git -C <repository> merge-base --is-ancestor <multi_hop_revision> <expected_revision> then_reverse_arguments"
                    : nil,
            legacyPorcelainProbeRevspec:
                caseID
                    == "private_github_style_depth2_multi_want_porcelain_fails_raw_headers_verify"
                    ? "5623872afda1895630ba0eacdfab76961c5e755b^2^1"
                    : nil,
            legacyPorcelainProbeMayContributeTopologyFacts: false,
            rawCommitHeadersExpectedSufficient: rawHeadersSufficient,
            passedGuardIDs: failedGuard.map(guardsBefore) ?? resultGuardOrder,
            expectedResultCode: resultCode,
            expectedFirstFailedGuardID: failedGuard,
            expectedMissingObjectRole: missingRole,
            expectedClassifierExitStatus:
                expectedClassifierExitStatus(caseID),
            mutuallyExclusiveDualResultCode:
                mutuallyExclusiveDual(resultCode),
            syntheticFixture: syntheticFixture(caseID))
    }

    private static func privateGitRecipeID(
        caseID: String,
        executionKind: String
    ) -> String? {
        guard executionKind == "live_private_repository" else { return nil }
        return "private_case_\(caseID)"
    }

    private static func privateGitRecipe(
        ordinal: Int,
        matrixCase: GitHubDepthTwoMultiWantMatrixCase,
        objectFixtures: [PrivateGitObjectFixture],
        replacementSourceOID: String,
        replacementTargetOID: String
    ) -> PrivateGitConstructionRecipe {
        var arguments = [
            cleanGitArgumentVector([
                "init", "--bare", "--object-format=sha1",
                "<private_bare_origin>",
            ]),
            cleanGitArgumentVector([
                "-C", "<private_bare_origin>", "config",
                "uploadpack.allowAnySHA1InWant", "true",
            ]),
            cleanGitArgumentVector([
                "-C", "<private_bare_origin>", "mktree",
            ]),
        ]
        arguments += objectFixtures.map { object in
            cleanGitArgumentVector([
                "-C", "<private_bare_origin>", "hash-object", "--literally",
                "-t", object.objectType, "-w", "--stdin",
            ])
        }
        arguments += [
            cleanGitArgumentVector([
                "init", "--object-format=sha1", "<private_destination>",
            ]),
            cleanGitArgumentVector([
                "-C", "<private_destination>", "fetch", "--no-tags",
                "--depth=\(matrixCase.fetchDepth)", "<private_bare_origin>",
            ] + matrixCase.explicitWantOIDs),
        ]
        var outputs = [
            "private_bare_sha1_origin_created",
            "literal_oid_wants_enabled_only_on_private_origin",
            "empty_stdin_writes_and_prints_4b825dc642cb6eb9a060e54bf8d69288fbee4904_one_lf",
        ]
        outputs += objectFixtures.map {
            "exact_\($0.fixtureID)_base64_bytes_write_and_print_\($0.fixture.literalObjectOID)_one_lf"
        }
        outputs += [
            "private_destination_sha1_repository_created",
            "exact_depth_and_literal_wants_fetch_succeeds_without_network",
        ]
        var standardInputs = ["none", "none", "empty"]
            + objectFixtures.map { "fixture:\($0.fixtureID)" }
            + ["none", "none"]
        var exactStdout: [String?] = [nil, nil, base64Line(
            "4b825dc642cb6eb9a060e54bf8d69288fbee4904")]
            + objectFixtures.map { base64Line($0.fixture.literalObjectOID) }
            + [nil, nil]
        if matrixCase.caseID
            == "replacement_ref_cannot_change_literal_object_topology"
        {
            arguments.append(cleanGitArgumentVector([
                "-C", "<private_destination>", "replace",
                replacementSourceOID, replacementTargetOID,
            ]))
            outputs.append(
                "exact_replacement_ref_created_but_GIT_NO_REPLACE_OBJECTS_1_observations_remain_literal")
            standardInputs.append("none")
            exactStdout.append(nil)
        }
        return .init(
            ordinal: ordinal,
            recipeID: "private_case_\(matrixCase.caseID)",
            recipeKind: "fully_concrete_private_sha1_graph_depth_want_case",
            exactArgumentVectors: arguments,
            exactExpectedStatuses: Array(repeating: 0, count: arguments.count),
            exactSemanticOutputs: outputs,
            exactStandardInputDescriptors: standardInputs,
            exactStdoutBase64: exactStdout,
            exactSourceObjectOIDs:
                ["4b825dc642cb6eb9a060e54bf8d69288fbee4904"]
                + objectFixtures.map(\.fixture.literalObjectOID),
            exactFixtureIDs: objectFixtures.map(\.fixtureID),
            exactSourceAvailabilityPreprobeArgumentVector:
                cleanGitArgumentVector([
                    "-C", "<private_bare_origin>", "cat-file",
                    "--batch-check=%(objectname) %(objecttype) %(objectsize)",
                ]),
            exactSourceAvailabilityExpectedLines:
                ["4b825dc642cb6eb9a060e54bf8d69288fbee4904 tree 0"]
                + objectFixtures.map {
                    "\($0.fixture.literalObjectOID) \($0.objectType) \($0.fixture.payloadByteCount)"
                },
            noNetwork: true,
            usesOnlyPrivateTemporaryRepositories: true,
            historicalEvidenceClaimedDynamicallyReplayed: false)
    }

    private static func base64Line(_ value: String) -> String {
        Data("\(value)\n".utf8).base64EncodedString()
    }

    private static func expectedClassifierExitStatus(
        _ caseID: String
    ) -> Int? {
        switch caseID {
        case "private_github_style_depth2_multi_want_porcelain_fails_raw_headers_verify",
             "private_github_style_depth2_signed_merge_continuation_headers_verify",
             "private_github_style_depth2_additional_unrelated_wants_do_not_change_topology",
             "replacement_ref_cannot_change_literal_object_topology":
            return 0
        case "available_commit_has_reordered_parent_headers",
             "available_commit_has_extra_parent_header":
            return 42
        case "available_commit_has_wrong_tree_oid":
            return 41
        case "malformed_header_tree_is_not_first":
            return 31
        case "nul_byte_in_commit_object_is_rejected_before_shell_parse":
            return 25
        default:
            return nil
        }
    }

    private static func mutuallyExclusiveDual(_ resultCode: String) -> String {
        switch resultCode {
        case "TOPOLOGY_VERIFIED": return "TOPOLOGY_MISMATCH"
        case "TOPOLOGY_OBJECT_UNAVAILABLE": return "TOPOLOGY_MISMATCH"
        case "TOPOLOGY_MISMATCH": return "TOPOLOGY_OBJECT_UNAVAILABLE"
        case "TOPOLOGY_HEADER_MALFORMED": return "TOPOLOGY_MISMATCH"
        case "TOPOLOGY_OBJECT_UNSUPPORTED":
            return "TOPOLOGY_HEADER_MALFORMED"
        default: return "TOPOLOGY_VERIFIED"
        }
    }

    private static func syntheticFixture(
        _ caseID: String
    ) -> SyntheticFixtureContract? {
        switch caseID {
        case "available_commit_has_reordered_parent_headers":
            return fixture(
                "base64_exact_bytes",
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCnBhcmVudCBmNWRiNzEwMWNmMzUzOGRhYWUxMDNiYTU2NjAxYTUwOWFkOGJhZDgwCnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnJlb3JkZXJlZCBwYXJlbnRzCg==",
                262,
                "573f031c9b397b18c21602c3e49e45665b77c4b1942cab5e11c1309d66ff5295",
                "32c5e6d59819d83e270bdac42a21017ff6548fc7")
        case "available_commit_has_extra_parent_header":
            return fixture(
                "base64_exact_bytes",
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmNWRiNzEwMWNmMzUzOGRhYWUxMDNiYTU2NjAxYTUwOWFkOGJhZDgwCnBhcmVudCA3NWIxNDA1NmI3NWU4YWY2YWYwYzA3MDQ1M2Y3ZWYxNGFjMTBhMDYzCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmV4dHJhIHBhcmVudAo=",
                305,
                "490e832ccc404b1293ca39ddd404d994c18d9d27ce5bdaf282d4f294a9b3b1af",
                "7c6b88b20b586dadb81de6685ba51cfb9ee1d93c")
        case "available_commit_has_wrong_tree_oid":
            return fixture(
                "base64_exact_bytes",
                "dHJlZSA5YjhhNzg0ZTYwNTk2NzE0MWYxNTlhNWY4Yzk1M2EwMDk2Y2YxZjhkCnBhcmVudCBmZTBhZDM2YTkxNjNhYWEwZTAzNDc4ZjU1NTZkZmIzNGI3MGUyNGU3CnBhcmVudCBmNWRiNzEwMWNmMzUzOGRhYWUxMDNiYTU2NjAxYTUwOWFkOGJhZDgwCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIHRyZWUK",
                255,
                "7d0faa211805a07faa4420ea7b07169ec65864b3ae3e87ff0d2d8b6cc1df25e8",
                "c0763d20513bfb5a4734df0a30745ae55b5f40bc")
        case "malformed_header_tree_is_not_first":
            return fixture(
                "base64_exact_bytes",
                "YXV0aG9yIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCnRyZWUgOWRkODg0YmZlNWI1MjBhNjdjMjk0NGQ4ZjhmNzk4NTFhNzE0NTE5ZQpjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm1hbGZvcm1lZCB0cmVlIG9yZGVyCg==",
                169,
                "1e8f63f3e256c84b0798cd1a36daae87bb3f3be2cc98f07eb30d4b290f1bc5ec",
                "28d89d60036ae440b8a45b54b6661dc6fca60dac")
        case "nul_byte_in_commit_object_is_rejected_before_shell_parse":
            return fixture(
                "base64_exact_bytes",
                "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKWABZCgpudWwK",
                156,
                "91d9163d6747a197317b27d49ae7a62973b0b69fadb38c89861693e31de208a2",
                "69c4a7f67cf2a86ba9c9bdf3c37c4ca1eb824981")
        case "oversized_commit_object_is_rejected_before_raw_content_stream":
            return .init(
                constructionKind: "base64_prefix_then_repeated_ascii_byte",
                payloadEncoding: "base64_prefix_plus_ascii_x_repeat",
                payloadRecipe: "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCg==_then_1048577_ascii_x_bytes",
                payloadByteCount: 1_048_725,
                payloadSHA256: "592feda5466a4618c63aba4e0fb7e79a8544add5db6f3136bbeef70ae2745517",
                literalObjectOID: "2df897f0b9eb39f944c1b868288d1632a8a81882",
                privateRepositoryConstructionAPI: "/usr/bin/git hash-object --literally -t commit -w --stdin",
                objectWrittenIntoPrivateRepository: true,
                literalOIDRecomputedAndRequiredEqualBeforeUse: true)
        case "cat_file_observation_pipeline_fails":
            return .init(
                constructionKind: "pure_classification_only_no_dynamic_corruption_seam",
                payloadEncoding: "base64_exact_bytes",
                payloadRecipe: "dHJlZSA5ZGQ4ODRiZmU1YjUyMGE2N2MyOTQ0ZDhmOGY3OTg1MWE3MTQ1MTllCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmNvcnJ1cHQgYWZ0ZXIgaGFzaAo=",
                payloadByteCount: 167,
                payloadSHA256: "76097dc7b0f0ec8a90987c0b385a6adf412b25e0b2580ebf606a7dd2494f77ad",
                literalObjectOID: "a7c2690d6c945956b7c5b97442356665f6ea3279",
                privateRepositoryConstructionAPI: "none_pure_classification_contract_only",
                objectWrittenIntoPrivateRepository: false,
                literalOIDRecomputedAndRequiredEqualBeforeUse: true)
        default:
            return nil
        }
    }

    private static func fixture(
        _ constructionKind: String,
        _ base64: String,
        _ byteCount: Int,
        _ sha256: String,
        _ oid: String
    ) -> SyntheticFixtureContract {
        .init(
            constructionKind: constructionKind,
            payloadEncoding: "base64_exact_bytes",
            payloadRecipe: base64,
            payloadByteCount: byteCount,
            payloadSHA256: sha256,
            literalObjectOID: oid,
            privateRepositoryConstructionAPI:
                "/usr/bin/git hash-object --literally -t commit -w --stdin",
            objectWrittenIntoPrivateRepository: true,
            literalOIDRecomputedAndRequiredEqualBeforeUse: true)
    }

    public func canonicalData() throws -> Data {
        try validateExactV1()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 524_288 else {
            throw PrimeExactRevisionTopologyVerifierAuthorityError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw PrimeExactRevisionTopologyVerifierAuthorityError
                .noncanonicalEncoding
        }
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let allRequests = githubDepthTwoMultiWantMatrix
            .flatMap(\.verificationRequests)
        let validRequests = githubDepthTwoMultiWantMatrix.filter {
            $0.expectedResultCode
                != resultClassificationContract.invalidInvocationResultCode
        }.flatMap(\.verificationRequests)
        let allLiteralOIDs = validRequests.flatMap {
            [$0.literalCommitOID, $0.expectedTreeOID]
                + $0.expectedOrderedParentOIDs
        }
        let allWantOIDs = githubDepthTwoMultiWantMatrix.flatMap(\.explicitWantOIDs)
        let validInvocationCases = githubDepthTwoMultiWantMatrix.filter {
            $0.expectedResultCode
                != resultClassificationContract.invalidInvocationResultCode
        }
        let unavailableCases = githubDepthTwoMultiWantMatrix.filter {
            $0.expectedResultCode
                == resultClassificationContract.objectUnavailableResultCode
        }
        let mismatchCases = githubDepthTwoMultiWantMatrix.filter {
            $0.expectedResultCode
                == resultClassificationContract.topologyMismatchResultCode
        }
        let falseCeilings = [
            authorityCeiling.filesystemReadPerformed,
            authorityCeiling.filesystemWritePerformed,
            authorityCeiling.processExecutionPerformed,
            authorityCeiling.gitExecutionPerformed,
            authorityCeiling.networkExecutionPerformed,
            authorityCeiling.modelExecutionPerformed,
            authorityCeiling.leaseExecutionPerformed,
            authorityCeiling.verifierImplementationPerformed,
            authorityCeiling.verifierMechanicsPerformed,
            authorityCeiling.v2MeasurementAuthorityEstablished,
            authorityCeiling.v2MeasurementMechanicsPerformed,
            authorityCeiling.v2MeasurementObservationEstablished,
            authorityCeiling.fixtureIdentityEstablished,
            authorityCeiling.repeatBuildDeterminismEstablished,
            authorityCeiling.currentPinMatchEstablished,
            authorityCeiling.currentPinMismatchEstablished,
            authorityCeiling.pinRepairAuthorized,
            authorityCeiling.pinRepairPerformed,
            authorityCeiling.confirmationAuthorized,
            authorityCeiling.confirmationPerformed,
            authorityCeiling.realCanaryAuthorized,
            authorityCeiling.realCanaryPerformed,
            authorityCeiling.retryOrRerunAuthorized,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              schemaID == "prime_exact_revision_topology_verifier_authority_v1",
              authorityID
                == "ergentics_prime_exact_revision_topology_verifier_authority_v1",
              retiredRun160Closure.workflowRunNumber == 160,
              retiredRun160Closure.workflowRunAttempt == 1,
              retiredRun160Closure.workflowConclusion == "failure",
              retiredRun160Closure.resultCode
                == "INVOCATION_ADMISSION_REFUSED",
              retiredRun160Closure.hostedRecordCount == 1,
              !retiredRun160Closure.measurementAttemptConsumed,
              retiredRun160Closure.opportunityState == "retired",
              retiredRun160Closure.scientificOutcome == "not_established",
              retiredRun160Closure.fixtureExecutionCount == 0,
              retiredRun160Closure.retryCount == 0,
              retiredRun160Closure.rerunCount == 0,
              !retiredRun160Closure.likelyRefusalCauseDirectlyEstablished,
              retiredRun160Closure.depthTwoCheckoutObserved,
              retiredRun160Closure.retiredLauncherUsedMultiHopAncestryRevspec,
              retiredRun160Closure.rawCommitHeadersWouldExposeRequiredOIDs,
              !retiredRun160Closure
                .refusalAuthorizesRepairRetryRerunOrReplacement,
              retiredRun160Closure.retirementMergedAndExactMainGreen,
              currentExactMainClosure.repository == "Ergentics/ergentics-prime",
              currentExactMainClosure.ref == "refs/heads/main",
              currentExactMainClosure.pullRequestNumber == 131,
              currentExactMainClosure.mergeTree
                == currentExactMainClosure.reviewedHeadTree,
              currentExactMainClosure.mergeTreeEqualsReviewedHeadTree,
              currentExactMainClosure.orderedMergeParentOIDs
                == [
                    currentExactMainClosure.baseRevision,
                    currentExactMainClosure.reviewedHeadRevision,
                ],
              currentExactMainClosure.reviewedHeadOrderedParentOIDs
                == [currentExactMainClosure.baseRevision],
              currentExactMainClosure.historyPreservingTwoParentMergeObserved,
              currentExactMainClosure.githubSignatureVerified,
              currentExactMainClosure.githubSignatureReason == "valid",
              currentExactMainClosure.pullRequestRunNumber == 161,
              currentExactMainClosure.pullRequestRunAttempt == 1,
              currentExactMainClosure.pullRequestConclusion == "success",
              currentExactMainClosure.pullRequestPreviousAttemptURL == nil,
              currentExactMainClosure.pullRequestActiveRootJobConclusion
                == "success",
              currentExactMainClosure.pullRequestReviewedMainJobConclusion
                == "skipped",
              currentExactMainClosure.pullRequestReviewedMainJobStepCount == 0,
              currentExactMainClosure.pullRequestActionsArtifactCount == 0,
              currentExactMainClosure.exactMainRunNumber == 162,
              currentExactMainClosure.exactMainRunAttempt == 1,
              currentExactMainClosure.exactMainConclusion == "success",
              currentExactMainClosure.exactMainActiveRootJobConclusion
                == "success",
              currentExactMainClosure.exactMainReviewedMainJobConclusion
                == "success",
              currentExactMainClosure.exactMainActionsArtifactCount == 0,
              commitHeaderContract.repositoryObjectFormat == "sha1",
              commitHeaderContract.literalOIDEncoding
                == "lowercase_ascii_hex",
              commitHeaderContract.literalOIDCharacterCount == 40,
              !commitHeaderContract.uppercaseOIDAccepted,
              !commitHeaderContract.abbreviatedOIDAccepted,
              !commitHeaderContract.symbolicRefAccepted,
              !commitHeaderContract.refNameAccepted,
              !commitHeaderContract.ancestryOperatorAccepted,
              commitHeaderContract.replaceObjectsDisabledEnvironment
                == "GIT_NO_REPLACE_OBJECTS=1",
              commitHeaderContract.lazyFetchDisabledEnvironment
                == "GIT_NO_LAZY_FETCH=1",
              !commitHeaderContract.replacementRefsMayAffectObservation,
              !commitHeaderContract.graftsFileMayContributeTopologyFacts,
              commitHeaderContract.localeEnvironment == "LC_ALL=C",
              commitHeaderContract.exactFixedToolPaths
                == [
                    "/bin/bash", "/usr/bin/git", "/usr/bin/env",
                    "/usr/bin/mktemp", "/usr/bin/stat", "/usr/bin/xcrun",
                ],
              commitHeaderContract
                .everyFixedToolMustBeExecutableRegularNonlink,
              commitHeaderContract.fixedGitExecutablePath == "/usr/bin/git",
              commitHeaderContract.fixedBashExecutablePath == "/bin/bash",
              commitHeaderContract.fixedXcrunExecutablePath == "/usr/bin/xcrun",
              commitHeaderContract.fixedEnvExecutablePath == "/usr/bin/env",
              commitHeaderContract.classifierSourcePath
                == ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
              commitHeaderContract.classifierRequiredImports
                == ["CryptoKit", "Darwin", "Foundation"],
              commitHeaderContract.classifierCompileArgumentVector
                == [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "CLANG_MODULE_CACHE_PATH=<validated_private_compiler_root>/clang-module-cache",
                    "/usr/bin/xcrun", "swiftc",
                    ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                    "-o",
                    "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                ],
              commitHeaderContract.classifierPrivateExecutableLeaf
                == "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
              commitHeaderContract.classifierCompileArgumentVector.last
                == commitHeaderContract.classifierPrivateExecutableLeaf,
              commitHeaderContract.classifierSourceIdentityAdmissionRequired,
              commitHeaderContract
                .exactToolchainOverrideEnvironmentKeysRequiredUnset
                == [
                    "DEVELOPER_DIR", "SDKROOT", "SWIFT_DRIVER_SWIFT_EXEC",
                    "SWIFT_DRIVER_SWIFT_FRONTEND_EXEC", "SWIFT_EXEC",
                    "TOOLCHAINS",
                ],
              commitHeaderContract.compilerOrImportFailureResultCode
                == resultClassificationContract.verifierUnavailableResultCode,
              commitHeaderContract.compilerAndClassifierUseEmptyEnvironment,
              commitHeaderContract.exactCleanEnvironmentAssignments
                == [
                    "LC_ALL=C", "TMPDIR=<validated_private_compiler_root>",
                    "CLANG_MODULE_CACHE_PATH=<validated_private_compiler_root>/clang-module-cache",
                ],
              commitHeaderContract.classifierExecutionArgumentPrefix
                == [
                    "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                ],
              commitHeaderContract.classifierExecutionArgumentPrefix.first
                == commitHeaderContract.classifierPrivateExecutableLeaf,
              commitHeaderContract
                .classifierCleanEnvironmentArgumentVectorPrefix.last
                == commitHeaderContract.classifierPrivateExecutableLeaf,
              commitHeaderContract.classifierExactArgumentRoles.count == 5,
              commitHeaderContract.objectTypeRequired == "commit",
              commitHeaderContract.exactObjectPreprobeArgumentVector.count
                == 15,
              commitHeaderContract.objectPreprobeInputUsesBashBuiltinPrintf,
              commitHeaderContract.exactGitObjectTypeTokens
                == ["blob", "commit", "tag", "tree"],
              commitHeaderContract.objectPreprobeStatusRequired == 0,
              commitHeaderContract.maximumObjectPreprobeOutputByteCount
                == 1_024,
              commitHeaderContract.exactRepositoryFormatObservationArgumentVector
                .last == "--show-object-format=storage",
              commitHeaderContract.exactRepositoryFormatSuccessOutput
                == "sha1_one_lf",
              Array(commitHeaderContract.exactRawCatFileArgumentVector.suffix(3))
                == ["cat-file", "commit", "<literal_lowercase_40hex_commit_oid>"],
              commitHeaderContract.maximumCommitObjectByteCount == 1_048_576,
              commitHeaderContract.classifierBoundedReadLimitByteCount
                == 1_048_577,
              commitHeaderContract.maximumVerificationRequestCount == 8,
              commitHeaderContract.maximumParentCountPerCommit == 8,
              commitHeaderContract.requestRoleASCIIGrammar
                == "^[a-z][a-z0-9_]{0,63}$",
              commitHeaderContract.maximumRequestRoleUTF8ByteCount == 64,
              commitHeaderContract
                .rawCatFileContentInvocationCountPerParsedObject == 1,
              commitHeaderContract.catFileStdoutPipedDirectlyToClassifierStdin,
              commitHeaderContract.filesystemCapturePathCount == 0,
              commitHeaderContract
                .classifierReadsLogicalStandardInputStreamOnceToEOF,
              commitHeaderContract
                .classifierDrainsStandardInputToEOFOnEveryNonReadFailureOutcome,
              commitHeaderContract.classifierRetriesInterruptedStandardInputReads,
              commitHeaderContract.classifierPerformsNoFilesystemOperation,
              commitHeaderContract
                .classifierComputesSHA1OverPrefixAndExactWithinCapAdvertisedInputBytes,
              commitHeaderContract.classifierComputedOIDMustEqualLiteralOID,
              commitHeaderContract
                .classifierWithinCapExactAdvertisedInputByteArrayIsSoleHashAndParseSource,
              commitHeaderContract.classifierParsesBytesWithoutUTF8Decoding,
              commitHeaderContract.classifierUsesDarwinProcPIDInfoFDInventory,
              commitHeaderContract.classifierMaximumFDInventoryByteCount
                == 16_384,
              commitHeaderContract.classifierMaximumFDClosurePassCount == 4,
              commitHeaderContract
                .classifierFDInventoryAllocationSlackRecordCount == 8,
              commitHeaderContract
                .classifierFDInitialSizeUsesCheckedCapMinusSlackArithmetic,
              commitHeaderContract
                .classifierFDFilledSizeMustBeStrictlyBelowCapacity,
              commitHeaderContract
                .classifierFinalSnapshotMustBeCompleteAndExactlyFD012,
              commitHeaderContract
                .classifierFDInventoryRequiresNonnegativeMultipleOfStride,
              commitHeaderContract.classifierRejectsNegativeEnumeratedFD,
              commitHeaderContract
                .classifierClosesEveryEnumeratedDescriptorAtOrAbove == 3,
              commitHeaderContract.classifierAcceptedCloseResults
                == ["0", "-1_with_errno_EBADF"],
              commitHeaderContract.classifierRequiresNoFDAtOrAbove3FixedPoint,
              commitHeaderContract.classifierFinalFDSet == [0, 1, 2],
              commitHeaderContract
                .classifierFDClosureClaimAppliesOnlyAtFinalSnapshot,
              commitHeaderContract.classifierIsSingleThreaded,
              !commitHeaderContract.classifierInstallsSignalHandler,
              commitHeaderContract
                .classifierReadsRawBytesFromDarwinFD0AfterClosure,
              commitHeaderContract
                .classifierHasNoAdditionalStdinPipeWriterAtOrAboveFD3,
              commitHeaderContract.exactPipelineStatusCount == 2,
              commitHeaderContract.pipelineRunsUnderTemporarilyDisabledErrexit,
              commitHeaderContract
                .pipelineStatusesCapturedImmediatelyBeforeErrexitRestore,
              commitHeaderContract.gitNonzeroHasPrecedenceOverClassifierStatus,
              commitHeaderContract.classifierStdoutByteCount == 0,
              commitHeaderContract.classifierStderrByteCount == 0,
              !commitHeaderContract.gitCatFileStderrPublished,
              commitHeaderContract.gitCatFileStderrSink
                == "private_nonpublished_status_governed_stderr_sink",
              commitHeaderContract.textCapturePreservesTerminalLFBeforeTrailerRemoval,
              commitHeaderContract.batchPreprobePipelineStatusCount == 2,
              commitHeaderContract.exactClassifierExitMappings.count == 16,
              Set(commitHeaderContract.exactClassifierExitMappings
                .map(\.exitStatus)).count == 16,
              commitHeaderContract.unknownClassifierExitMapsToObservationFailure,
              commitHeaderContract.compilerInvocationCount == 1,
              commitHeaderContract.compilerBaseEnvironmentKey == "RUNNER_TEMP",
              commitHeaderContract.compilerBaseMaximumUTF8ByteCount == 1_024,
              commitHeaderContract.compilerBaseRejectsLFCRAndControlBytes,
              commitHeaderContract.everyFilesystemPathPassedAsOneQuotedArgument,
              commitHeaderContract.compilerUmask == "0077",
              commitHeaderContract.compilerRootCreationArgumentVector
                == [
                    "/usr/bin/mktemp", "-d",
                    "<validated_RUNNER_TEMP>/prime-topology-classifier.XXXXXXXX",
                ],
              commitHeaderContract.compilerRootMode == "0700",
              commitHeaderContract.compilerOutputLeaf
                == "prime-exact-revision-topology-classifier",
              commitHeaderContract.compilerOutputInitiallyAbsentAndNonlink,
              commitHeaderContract.compilerStatusRequired == 0,
              commitHeaderContract.compilerStdoutByteCount == 0,
              commitHeaderContract.compilerStderrByteCount == 0,
              !commitHeaderContract.compilerPrivateArtifactsPublishedOrEvidence,
              commitHeaderContract.compilerLauncherCleanupInvocationCount == 0,
              commitHeaderContract.classifierExecutableAdmissionRequired,
              commitHeaderContract
                .classifierExecutableMustBePrivateRegularNonlink,
              commitHeaderContract
                .classifierSelfTestRequiredBeforeRawObjectPipeline,
              commitHeaderContract.classifierSelfTestArgumentVector
                == [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>",
                    "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                    "--self-test",
                ],
              commitHeaderContract.classifierSelfTestArgumentVector
                .dropLast().last
                == commitHeaderContract.classifierPrivateExecutableLeaf,
              commitHeaderContract.classifierSelfTestUsesEmptyStandardInput,
              commitHeaderContract.classifierSelfTestStandardInputSource
                == "/dev/null",
              commitHeaderContract.classifierSelfTestConstructsVectorInternally,
              commitHeaderContract.classifierSelfTestPayloadByteCount == 47,
              commitHeaderContract.classifierSelfTestGitObjectOID
                == "60bc2812cc97ab2d2f2c7168aa101f7bfabcbf88",
              commitHeaderContract.classifierSelfTestExpectedExitStatus == 0,
              commitHeaderContract.classifierSelfTestOutputByteCount == 0,
              commitHeaderContract
                .classifierSelfTestImmediatelyFollowsExecutableAdmission,
              commitHeaderContract
                .rawClassifierInvocationsRequireSuccessfulSelfTest,
              commitHeaderContract
                .noBuildOrUntrustedProcessBetweenSelfTestAndRawInvocations,
              commitHeaderContract.interveningBuildInvocationCount == 0,
              commitHeaderContract
                .allRequestPreprobesCompleteBeforeAnyClassifierInvocation,
              commitHeaderContract.exactPreprobeGuardPhaseRange
                == Array(13 ... 18),
              commitHeaderContract.exactRawClassifierGuardPhaseRange
                == Array(19 ... 35),
              commitHeaderContract.preprobeFailureRawClassifierInvocationCount
                == 0,
              commitHeaderContract
                .rawStageRequiresEveryRequestAvailableCommitWithinCap,
              commitHeaderContract
                .allEligibleClassifierOutcomesCollectedBeforeSelection,
              commitHeaderContract.globalFailureSelectionOrder
                == "lexicographically_smallest_phase_ordinal_then_request_ordinal",
              !commitHeaderContract.stderrPublished,
              commitHeaderContract.commitHeaderEndsAtFirstEmptyLine,
              !commitHeaderContract.commitMessageParsed,
              commitHeaderContract.treeHeaderMustBeFirst,
              commitHeaderContract.exactTreeHeaderCount == 1,
              commitHeaderContract
                .parentHeadersMustBeContiguousImmediatelyAfterTree,
              commitHeaderContract.parentHeaderOrderIsSemantic,
              !commitHeaderContract.treeOrParentHeaderPermittedAfterOtherHeader,
              commitHeaderContract
                .treeAndParentValuesRequireLiteralLowercase40Hex,
              commitHeaderContract
                .signedHeaderContinuationBeginsWithOneSpace,
              commitHeaderContract.exactHeadersPermittingContinuationLines
                == ["gpgsig", "gpgsig-sha256", "mergetag"],
              !commitHeaderContract.repeatedGPGSigHeaderAccepted,
              !commitHeaderContract.repeatedGPGSigSHA256HeaderAccepted,
              commitHeaderContract.repeatedMergetagHeaderAccepted,
              commitHeaderContract.emptySignedContinuationPayloadAccepted,
              !commitHeaderContract
                .signedHeaderContinuationContributesTopologyFacts,
              !commitHeaderContract.unattachedContinuationAccepted,
              !commitHeaderContract.carriageReturnAccepted,
              !commitHeaderContract.NULAccepted,
              !commitHeaderContract.SHA1ClaimsCollisionResistance,
              !commitHeaderContract.SHA1ClaimsAuthenticity,
              !commitHeaderContract.SHA1ClaimsSignatureValidity,
              !commitHeaderContract
                .SHA1ClaimsTopologyTrustWithoutTreeAndParents,
              commitHeaderContract.signedHeaderHandlingIsGrammarOnly,
              !commitHeaderContract.futureDualObjectFormatSupportInV1,
              commitHeaderContract
                .rawHeaderMustBeWellFormedBeforeSemanticComparison,
              commitHeaderContract.expectedTreeComparedByExactBytes,
              commitHeaderContract.expectedOrderedParentsComparedByExactBytes,
              commitHeaderContract.topologyHistoryTraversalInvocationCount == 0,
              commitHeaderContract.mergeBaseInvocationCount == 0,
              commitHeaderContract.revListInvocationCount == 0,
              commitHeaderContract.refResolutionInvocationCount == 0,
              resultClassificationContract.exactOrderedResultCodes.count == 10,
              Set(resultClassificationContract.exactOrderedResultCodes).count
                == 10,
              resultClassificationContract.firstFailureWins,
              resultClassificationContract.exactGuardResultMappings.count
                == 35,
              resultClassificationContract.exactGuardResultMappings
                .map(\.phaseOrdinal) == Array(1 ... 35),
              Set(resultClassificationContract.exactGuardResultMappings
                .map(\.guardID)).count == 35,
              resultClassificationContract
                .phaseMajorThenRequestOrdinalMinorFirstFailureOrder,
              resultClassificationContract.invalidInvocationRejectedBeforeGit,
              resultClassificationContract
                .objectUnavailableRequiresPositiveMissingObservationForLiteralOID,
              resultClassificationContract
                .mismatchRequiresAvailableCommitAndSuccessfulHeaderParse,
              resultClassificationContract
                .noncommitNeverClassifiedAsObjectUnavailable,
              resultClassificationContract
                .malformedNeverClassifiedAsTopologyMismatch,
              resultClassificationContract
                .toolOrTransportFailureNeverClassifiedAsObjectUnavailable,
              resultClassificationContract.fixedToolAdmissionFailureResultCode
                == resultClassificationContract.verifierUnavailableResultCode,
              resultClassificationContract
                .unsupportedOrNULObjectNeverClassifiedAsTopologyMismatch,
              !resultClassificationContract.rawDiagnosticPublished,
              resultClassificationContract.unknownFailureFailsClosed,
              historicalGitHubShallowEvidence.count == 5,
              historicalGitHubShallowEvidence.map(\.ordinal)
                == Array(1 ... 5),
              historicalGitHubShallowEvidence.allSatisfy({ evidence in
                  evidence.fetchDepth == 2
                      && Self.isLowercase40Hex(evidence.literalCommitOID)
                      && Self.isLowercase40Hex(evidence.rawHeaderTreeOID)
                      && evidence.explicitWantOIDs.allSatisfy(
                          Self.isLowercase40Hex)
                      && evidence.rawHeaderOrderedParentOIDs.allSatisfy(
                          Self.isLowercase40Hex)
                      && evidence.availableReferencedParentOIDs.allSatisfy(
                          Self.isLowercase40Hex)
                      && evidence.absentReferencedParentOIDs.allSatisfy(
                          Self.isLowercase40Hex)
                      && evidence.rawHeadersProvidedTopologyFact
                      && evidence.diagnosticEvidenceOnly
                      && !evidence.dynamicallyReplayedByFutureMatrix
              }),
              verifierPredicateProofPairs.count == 35,
              verifierPredicateProofPairs.map(\.ordinal)
                == Array(1 ... 35),
              verifierPredicateProofPairs.map(\.guardID)
                == resultClassificationContract.exactGuardResultMappings
                    .map(\.guardID),
              verifierPredicateWitnesses.count == 70,
              verifierPredicateWitnesses.map(\.ordinal)
                == Array(1 ... 70),
              Set(verifierPredicateWitnesses.map(\.witnessID)).count == 70,
              verifierPredicateWitnesses.allSatisfy({ witness in
                  let references = [
                      witness.classifierCaseID,
                      witness.helperParserCaseID,
                      witness.privateGitMatrixCaseID,
                      witness.staticCheckID,
                      witness.verifiedBaselineID,
                  ].compactMap({ $0 })
                  guard references.count == 1,
                        !witness.syntheticOIDClaimedFetched,
                        (witness.predicateValue
                        ? witness.expectedResultCode
                            == resultClassificationContract.successResultCode
                            && witness.expectedFirstFailedGuardID == nil
                            && witness.passedGuardIDs
                                == Self.resultGuardOrder
                        : witness.expectedResultCode
                            == resultClassificationContract
                                .exactGuardResultMappings.first(where: {
                                    $0.guardID == witness.guardID
                                })?.resultCode
                            && witness.expectedFirstFailedGuardID
                                == witness.guardID
                            && witness.passedGuardIDs
                                == Self.guardsBefore(witness.guardID))
                  else { return false }
                  switch witness.witnessKind {
                  case "private_git_end_to_end_verified_baseline":
                      return witness.predicateValue
                          && witness.verifiedBaselineID
                            == verifiedEndToEndBaseline.baselineID
                  case "direct_classifier_fixture":
                      return classifierDirectFixtureMatrix.filter {
                          $0.caseID == witness.classifierCaseID
                              && $0.guardID == witness.guardID
                              && $0.predicateValue == witness.predicateValue
                              && $0.passedGuardIDs == witness.passedGuardIDs
                              && $0.expectedResultCode
                                == witness.expectedResultCode
                              && $0.expectedFirstFailedGuardID
                                == witness.expectedFirstFailedGuardID
                      }.count == 1
                  case "direct_helper_parser_fixture":
                      return helperParserFixtureMatrix.filter {
                          $0.caseID == witness.helperParserCaseID
                              && $0.guardID == witness.guardID
                              && $0.predicateValue == witness.predicateValue
                              && $0.passedGuardIDs == witness.passedGuardIDs
                              && $0.expectedResultCode
                                == witness.expectedResultCode
                              && $0.expectedFirstFailedGuardID
                                == witness.expectedFirstFailedGuardID
                      }.count == 1
                  case "private_git_end_to_end":
                      return githubDepthTwoMultiWantMatrix.filter {
                          $0.caseID == witness.privateGitMatrixCaseID
                              && $0.passedGuardIDs == witness.passedGuardIDs
                              && $0.expectedResultCode
                                == witness.expectedResultCode
                              && $0.expectedFirstFailedGuardID
                                == witness.expectedFirstFailedGuardID
                      }.count == 1
                  case "static_source_contract":
                      return staticSourceContractRegistry.filter {
                          $0.checkID == witness.staticCheckID
                              && $0.guardID == witness.guardID
                              && $0.predicateValue == witness.predicateValue
                              && $0.passedGuardIDs == witness.passedGuardIDs
                              && $0.expectedResultCode
                                == witness.expectedResultCode
                      }.count == 1
                  default:
                      return false
                  }
              }),
              staticSourceContractRegistry.map(\.ordinal)
                == Array(1 ... staticSourceContractRegistry.count),
              staticSourceContractRegistry.count == 8,
              Set(staticSourceContractRegistry.map(\.checkID)).count
                == staticSourceContractRegistry.count,
              staticSourceContractRegistry.map(\.checkID) == [
                "static_check_classifier_inherited_file_descriptors_closed_positive",
                "static_check_classifier_inherited_file_descriptors_closed_negative",
                "static_check_classifier_parser_internal_state_valid_positive",
                "static_check_classifier_parser_internal_state_valid_negative",
                "static_check_fixed_verifier_tools_admitted_positive",
                "static_check_fixed_verifier_tools_admitted_negative",
                "static_check_classifier_build_and_self_test_admitted_positive",
                "static_check_classifier_build_and_self_test_admitted_negative",
              ],
              staticSourceContractRegistry.allSatisfy({ check in
                  let exactFuturePaths = futureImplementationPatch
                    .exactOrderedPaths.map(\.path)
                  let allowedSymbols = [
                    "closeInheritedFileDescriptorsUsingProcPIDInfo()",
                    "parseCommitObjectBytes(_:expectedTreeOID:expectedParentOIDs:)",
                    "prime_admit_exact_revision_topology_tools_v1",
                    "prime_build_exact_revision_topology_classifier_v1",
                  ]
                  let allowedBranches = [
                    "complete_final_proc_pidinfo_snapshot_is_exactly_fd_0_1_2",
                    "proc_pidinfo_allocation_close_or_nonconvergence_failure_exits_27",
                    "bounded_byte_parser_reaches_one_closed_declared_classification",
                    "unreachable_parser_state_exits_26_before_topology_classification",
                    "every_fixed_tool_path_mode_and_owner_admission_succeeds",
                    "any_fixed_tool_admission_failure_selects_fixed_verifier_tools_admitted",
                    "swiftc_binary_admission_and_empty_stdin_self_test_all_succeed",
                    "compile_import_binary_admission_or_self_test_failure_selects_classifier_build_and_self_test_admitted",
                  ]
                  let allowedProofMethods = [
                    "future_matrix_static_AST_assertion_plus_dynamic_extra_fd_positive_fixture",
                    "future_matrix_static_AST_assertion_for_noninjectable_proc_inventory_faults",
                    "future_matrix_static_AST_totality_assertion_plus_all_reachable_exit_fixtures",
                    "future_matrix_static_AST_assertion_for_noninjectable_internal_invariant_failure",
                    "future_matrix_exact_Bash_function_source_contract_assertion",
                    "future_matrix_static_Bash_branch_and_result_mapping_assertion",
                    "future_matrix_exact_Bash_function_source_contract_and_live_self_test",
                  ]
                  return Self.predicateExecutionKind(check.guardID)
                        == "static_source_contract"
                      && exactFuturePaths.contains(check.futureComponentPath)
                      && allowedSymbols.contains(check.exactSymbolOrSourceAnchor)
                      && allowedBranches.contains(
                          check.exactInvariantOrBranchAnchor)
                      && allowedProofMethods.contains(check.proofMethod)
                      && !check.futureComponentPath.isEmpty
                      && !check.exactSymbolOrSourceAnchor.isEmpty
                      && !check.exactInvariantOrBranchAnchor.isEmpty
                      && !check.proofMethod.isEmpty
                      && check.expectedResultCode
                        == (check.predicateValue
                            ? resultClassificationContract.successResultCode
                            : Self.resultCode(forGuard: check.guardID))
                      && check.passedGuardIDs
                        == (check.predicateValue
                            ? [] : Self.guardsBefore(check.guardID))
              }),
              verifierPredicateProofPairs.allSatisfy({ pair in
                  let positive = verifierPredicateWitnesses.filter {
                      $0.witnessID == pair.positiveWitnessID
                  }
                  let negative = verifierPredicateWitnesses.filter {
                      $0.witnessID == pair.negativeWitnessID
                  }
                  return pair.predicatesAreDisjoint
                      && pair.predicatesAreExhaustive
                      && positive.count == 1
                      && negative.count == 1
                      && positive[0].guardID == pair.guardID
                      && negative[0].guardID == pair.guardID
                      && positive[0].predicateValue
                      && !negative[0].predicateValue
                      && positive[0].verifiedBaselineID
                        == verifiedEndToEndBaseline.baselineID
              }),
              verifiedEndToEndBaseline.baselineID
                == "private_git_end_to_end_verified_baseline",
              verifiedEndToEndBaseline.executionKind
                == "private_git_end_to_end",
              verifiedEndToEndBaseline.requestVector.count == 1,
              verifiedEndToEndBaseline.commitFixture
                .objectWrittenIntoPrivateRepository,
              verifiedEndToEndBaseline.exactPrivateRepositoryInitStatus == 0,
              verifiedEndToEndBaseline.exactPrivateRepositoryInitArgumentVector
                .contains("--object-format=sha1"),
              verifiedEndToEndBaseline.exactCommitWriteStatus == 0,
              verifiedEndToEndBaseline.exactCommitWriteArgumentVector
                .suffix(6) == [
                    "hash-object", "--literally", "-t", "commit", "-w",
                    "--stdin",
                ],
              verifiedEndToEndBaseline
                .constructionUsesEmptyEnvironmentAndNoNetwork,
              verifiedEndToEndBaseline.commitFixture
                .literalOIDRecomputedAndRequiredEqualBeforeUse,
              verifiedEndToEndBaseline.exactRepositoryFormatStatus == 0,
              verifiedEndToEndBaseline.exactRepositoryFormatStdoutBase64
                == "c2hhMQo=",
              verifiedEndToEndBaseline.exactBatchPreprobeStatus == 0,
              verifiedEndToEndBaseline.expectedClassifierExitStatus == 0,
              verifiedEndToEndBaseline.expectedResultCode
                == resultClassificationContract.successResultCode,
              verifiedEndToEndBaseline.expectedFirstFailedGuardID == nil,
              verifiedEndToEndBaseline.expectedMissingObjectRole == nil,
              verifiedEndToEndBaseline.passedGuardIDs
                == Self.resultGuardOrder,
              verifiedEndToEndBaseline.deterministicAndDynamicallyExecutable,
              classifierDirectFixtureMatrix.count == 41,
              classifierDirectFixtureMatrix.map(\.ordinal)
                == Array(1 ... 41),
              Set(classifierDirectFixtureMatrix.map(\.caseID)).count == 41,
              classifierDirectFixtureMatrix.allSatisfy({ value in
                  value.dynamicallyExecutable
                      && Self.isLowercase40Hex(value.fixture.literalObjectOID)
                      && value.fixture.payloadSHA256.utf8.count == 64
                      && !value.fixture.objectWrittenIntoPrivateRepository
                      && value.fixture
                        .literalOIDRecomputedAndRequiredEqualBeforeUse
                      && (value.predicateValue
                        ? value.passedGuardIDs.isEmpty
                        : value.passedGuardIDs
                            == Self.guardsBefore(value.guardID))
                      && (value.expectedExitStatus == 0
                        ? value.expectedResultCode
                            == resultClassificationContract.successResultCode
                            && value.expectedFirstFailedGuardID == nil
                        : commitHeaderContract.exactClassifierExitMappings
                            .contains(where: {
                                $0.exitStatus == value.expectedExitStatus
                                    && $0.resultCode == value.expectedResultCode
                                    && $0.firstFailedGuardID
                                        == value.expectedFirstFailedGuardID
                            }))
              }),
              helperParserFixtureMatrix.count == 32,
              helperParserFixtureMatrix.map(\.ordinal)
                == Array(1 ... 32),
              Set(helperParserFixtureMatrix.map(\.caseID)).count == 32,
              helperParserFixtureMatrix.allSatisfy({ value in
                  (value.predicateValue
                    ? value.expectedResultCode == nil
                        && value.expectedFirstFailedGuardID == nil
                        && value.passedGuardIDs.isEmpty
                    : value.expectedResultCode
                        == resultClassificationContract
                            .exactGuardResultMappings.first(where: {
                                $0.guardID == value.guardID
                            })?.resultCode
                        && value.expectedFirstFailedGuardID == value.guardID
                        && value.passedGuardIDs
                            == Self.guardsBefore(value.guardID))
                      && ["invocation", "repository_format",
                          "batch_preprobe", "pipeline_status"]
                        .contains(value.observationKind)
              }),
              githubDepthTwoMultiWantMatrix.count == 18,
              githubDepthTwoMultiWantMatrix.map(\.ordinal)
                == Array(1 ... githubDepthTwoMultiWantMatrix.count),
              Set(githubDepthTwoMultiWantMatrix.map(\.caseID)).count
                == githubDepthTwoMultiWantMatrix.count,
              allLiteralOIDs.allSatisfy(Self.isLowercase40Hex),
              allWantOIDs.allSatisfy(Self.isLowercase40Hex),
              allRequests.count > 0,
              githubDepthTwoMultiWantMatrix.allSatisfy({
                  $0.verificationRequests.count
                    <= commitHeaderContract.maximumVerificationRequestCount
                      && ($0.verificationRequests.isEmpty
                        || $0.verificationRequests.map(\.ordinal)
                            == Array(1 ... $0.verificationRequests.count))
                      && $0.verificationRequests.allSatisfy {
                          Self.isAllowedRole($0.objectRole)
                              && $0.objectRole.utf8.count
                                <= commitHeaderContract
                                    .maximumRequestRoleUTF8ByteCount
                              && $0.expectedOrderedParentOIDs.count
                                <= commitHeaderContract
                                    .maximumParentCountPerCommit
                      }
              }),
              validInvocationCases.allSatisfy({
                  Self.isLowercase40Hex($0.suppliedRevisionToken)
              }),
              githubDepthTwoMultiWantMatrix.allSatisfy({
                  !$0.legacyPorcelainProbeMayContributeTopologyFacts
                      && sanitizedRecordContract.exactShallowStateValues
                        .contains($0.shallowState)
                      && ["live_private_repository", "pure_source_contract"]
                        .contains($0.executionKind)
              }),
              privateGitConstructionRecipes.count == 8,
              privateGitConstructionRecipes.map(\.ordinal)
                == Array(1 ... 8),
              Set(privateGitConstructionRecipes.map(\.recipeID)).count == 8,
              privateGitObjectFixtures.count == 9,
              privateGitObjectFixtures.map(\.ordinal) == Array(1 ... 9),
              Set(privateGitObjectFixtures.map(\.fixtureID)).count == 9,
              privateGitObjectFixtures.allSatisfy({ object in
                  ["blob", "commit"].contains(object.objectType)
                      && Self.isLowercase40Hex(
                        object.fixture.literalObjectOID)
                      && object.fixture.objectWrittenIntoPrivateRepository
                      && object.fixture
                        .literalOIDRecomputedAndRequiredEqualBeforeUse
              }),
              privateGitConstructionRecipes.allSatisfy({ recipe in
                  recipe.noNetwork
                      && recipe.usesOnlyPrivateTemporaryRepositories
                      && !recipe.historicalEvidenceClaimedDynamicallyReplayed
                      && recipe.exactArgumentVectors.count
                        == recipe.exactExpectedStatuses.count
                      && recipe.exactArgumentVectors.count
                        == recipe.exactSemanticOutputs.count
                      && recipe.exactArgumentVectors.count
                        == recipe.exactStandardInputDescriptors.count
                      && recipe.exactArgumentVectors.count
                        == recipe.exactStdoutBase64.count
                      && recipe.exactArgumentVectors.allSatisfy {
                          $0.prefix(2) == ["/usr/bin/env", "-i"]
                      }
                      && recipe.exactFixtureIDs
                        == privateGitObjectFixtures.map(\.fixtureID)
                      && Array(recipe.exactStandardInputDescriptors.prefix(3))
                        == ["none", "none", "empty"]
                      && Array(recipe.exactStandardInputDescriptors.dropFirst(3)
                        .prefix(privateGitObjectFixtures.count))
                        == privateGitObjectFixtures.map {
                            "fixture:\($0.fixtureID)"
                        }
                      && recipe.exactSourceObjectOIDs
                        == ["4b825dc642cb6eb9a060e54bf8d69288fbee4904"]
                            + privateGitObjectFixtures.map(
                                \.fixture.literalObjectOID)
                      && recipe.exactSourceAvailabilityExpectedLines.count
                        == recipe.exactSourceObjectOIDs.count
                      && recipe.exactSourceAvailabilityPreprobeArgumentVector
                        .last
                        == "--batch-check=%(objectname) %(objecttype) %(objectsize)"
              }),
              githubDepthTwoMultiWantMatrix.allSatisfy({ matrixCase in
                  if matrixCase.executionKind == "live_private_repository" {
                      return privateGitConstructionRecipes.filter {
                          $0.recipeID == matrixCase.privateGitRecipeID
                      }.count == 1
                  }
                  return matrixCase.privateGitRecipeID == nil
              }),
              githubDepthTwoMultiWantMatrix.allSatisfy({ value in
                  let isVerified = value.expectedResultCode
                    == resultClassificationContract.successResultCode
                  let isUnavailable = value.expectedResultCode
                    == resultClassificationContract.objectUnavailableResultCode
                  guard (value.expectedFirstFailedGuardID == nil) == isVerified,
                        (value.expectedMissingObjectRole != nil) == isUnavailable
                  else {
                      return false
                  }
                  if value.expectedResultCode
                        == resultClassificationContract.successResultCode
                  {
                      return value.expectedFirstFailedGuardID == nil
                          && value.expectedMissingObjectRole == nil
                          && value.passedGuardIDs == Self.resultGuardOrder
                  }
                  guard let guardID = value.expectedFirstFailedGuardID,
                        let mapping = resultClassificationContract
                            .exactGuardResultMappings.first(where: {
                                $0.guardID == guardID
                            })
                  else {
                      return false
                  }
                  return mapping.resultCode == value.expectedResultCode
                      && value.passedGuardIDs
                        == Self.guardsBefore(guardID)
              }),
              unavailableCases.count == 3,
              unavailableCases.allSatisfy({
                  $0.expectedFirstFailedGuardID
                    == "required_object_availability"
                      && $0.expectedMissingObjectRole != nil
              }),
              mismatchCases.count == 3,
              mismatchCases.allSatisfy({
                  $0.rawCommitHeadersExpectedSufficient
                      && $0.expectedMissingObjectRole == nil
              }),
              sanitizedRecordContract.exactRequiredFieldNames.count == 6,
              sanitizedRecordContract.exactRequiredFieldNames
                == sanitizedRecordContract.exactRequiredFieldNames.sorted(),
              sanitizedRecordContract.firstFailedGuardIDField
                == "first_failed_guard_id",
              sanitizedRecordContract.shallowStateField == "shallow_state",
              sanitizedRecordContract.missingObjectRoleField
                == "missing_object_role",
              sanitizedRecordContract.exactAllowedFirstFailedGuardIDs
                == resultClassificationContract.exactGuardResultMappings
                    .map(\.guardID),
              unavailableCases.compactMap(\.expectedMissingObjectRole)
                .allSatisfy({
                    allRequests.map(\.objectRole).contains($0)
                        && Self.isAllowedRole($0)
                }),
              sanitizedRecordContract.missingObjectRoleASCIIGrammar
                == "^[a-z][a-z0-9_]{0,63}$",
              sanitizedRecordContract.maximumMissingObjectRoleUTF8ByteCount
                == 64,
              sanitizedRecordContract
                .missingObjectRoleMustEqualOneSubmittedPrevalidatedRole,
              sanitizedRecordContract.shallowStateObservationCommand
                == "/usr/bin/git rev-parse --is-shallow-repository",
              sanitizedRecordContract
                .exactShallowStateObservationArgumentVector.last
                == "--is-shallow-repository",
              sanitizedRecordContract.shallowStateObservationStatusRequired
                == 0,
              sanitizedRecordContract
                .maximumShallowStateObservationOutputByteCount == 6,
              sanitizedRecordContract.shallowStateFailureValue
                == "unavailable",
              sanitizedRecordContract.shallowStateIsDiagnosticOnly,
              !sanitizedRecordContract
                .shallowStateObservationFailureChangesResultCode,
              !sanitizedRecordContract
                .shallowStateObservationFailureChangesFirstFailedGuardID,
              sanitizedRecordContract
                .shallowStateObservationMaximumInvocationCount == 1,
              sanitizedRecordContract.shallowStateObservationRetryCount == 0,
              sanitizedRecordContract
                .shallowStateObservationInvocationCountIsZeroOrOne,
              sanitizedRecordContract
                .shallowStateObservationExactEligibilityAndSequence
                == "invocation_count_is_exactly_1_if_and_only_if_guards_1_through_12_all_pass_including_status0_exact_sha1_lf_storage_format_admission;otherwise_invocation_count_is_0;the_one_fixed_clean_environment_call_occurs_immediately_after_guard_12_and_before_guard_13",
              sanitizedRecordContract
                .shallowStateNonzeroOrMalformedMapsToUnavailableExactlyOnce,
              !sanitizedRecordContract
                .shallowStateObservationFailureAuthorizesRetry,
              sanitizedRecordContract
                .firstFailedGuardIDIsNullIfAndOnlyIfResultVerified,
              sanitizedRecordContract
                .missingObjectRoleIsNonNullIfAndOnlyIfResultObjectUnavailable,
              sanitizedRecordContract.exactResultRecordNullabilityMappings
                .map(\.resultCode)
                == resultClassificationContract.exactOrderedResultCodes,
              Set(sanitizedRecordContract.exactResultRecordNullabilityMappings
                .map(\.resultCode)).count
                == resultClassificationContract.exactOrderedResultCodes.count,
              sanitizedRecordContract.exactResultRecordNullabilityMappings
                .allSatisfy({ mapping in
                    mapping.firstFailedGuardIDIsNull
                        == (mapping.resultCode
                            == resultClassificationContract.successResultCode)
                        && mapping.missingObjectRoleIsNonNull
                        == (mapping.resultCode
                            == resultClassificationContract
                                .objectUnavailableResultCode)
                }),
              !sanitizedRecordContract.objectIDsPublished,
              !sanitizedRecordContract.repositoryPathsPublished,
              !sanitizedRecordContract.refsPublished,
              !sanitizedRecordContract.rawHeadersPublished,
              !sanitizedRecordContract.rawStandardErrorPublished,
              sanitizedRecordContract.resultUsesExactTaxonomy,
              sanitizedRecordContract.canonicalSortedJSONRequired,
              sanitizedRecordContract.maximumCanonicalJSONByteCount == 512,
              sanitizedRecordContract.maximumLineByteCountIncludingTerminalLF
                == 513,
              sanitizedRecordContract.exactRecordCount == 1,
              sanitizedRecordContract.admittedWritableStdoutRequiredForProjection,
              sanitizedRecordContract.projectionFailureValidCompleteRecordCount
                == 0,
              sanitizedRecordContract
                .projectionFailureMayLeavePhysicalPartialPrefix,
              sanitizedRecordContract
                .projectionFailureIsExternalTransportFailure,
              !sanitizedRecordContract
                .projectionFailureAuthorizesTopologyRetry,
              sanitizedRecordContract
                .exitStatusesApplyOnlyAfterSuccessfulProjection,
              sanitizedRecordContract
                .gateAndV2CaptureAndValidateHelperRecordBeforeProjection,
              sanitizedRecordContract.successExitStatus == 0,
              sanitizedRecordContract.nonSuccessExitStatus == 1,
              sanitizedRecordContract.terminalLFRequired,
              currentAuthorityPatch.exactPathCount == 5,
              currentAuthorityPatch.exactOrderedPaths.count == 5,
              currentAuthorityPatch.exactOrderedPaths.map(\.ordinal)
                == [1, 2, 3, 4, 5],
              currentAuthorityPatch.exactOrderedPaths.map(\.gitStatus)
                == ["M", "M", "M", "A", "A"],
              currentAuthorityPatch.modifiedExistingPathCount == 3,
              currentAuthorityPatch.addedPathCount == 2,
              currentAuthorityPatch.soleAuthorityTestExpectedStartCount == 1,
              currentAuthorityPatch.soleAuthorityTestExpectedPassCount == 1,
              currentAuthorityPatch.expectedRootTestCount
                + currentAuthorityPatch.expectedIsolatedTestCount
                == currentAuthorityPatch.expectedFocusedWholeTestCount,
              currentAuthorityPatch.expectedFocusedWholeTestCount
                + currentAuthorityPatch.expectedRetainedLiveTestCount
                == currentAuthorityPatch.expectedAggregateTestCount,
              !currentAuthorityPatch.implementationIncluded,
              !currentAuthorityPatch.mechanicsIncluded,
              !currentAuthorityPatch
                .canonicalIdentityConstantsIncludedBeforeIndependentReview,
              futureImplementationPatch.exactPathCount == 5,
              futureImplementationPatch.exactOrderedPaths.count == 5,
              futureImplementationPatch.exactOrderedPaths.map(\.ordinal)
                == [1, 2, 3, 4, 5],
              futureImplementationPatch.exactOrderedPaths.map(\.gitStatus)
                == ["M", "A", "A", "A", "M"],
              futureImplementationPatch.exactOrderedPaths.map(\.gitMode)
                == ["100755", "100644", "100755", "100755", "100644"],
              futureImplementationPatch.modifiedExistingPathCount == 2,
              futureImplementationPatch.addedPathCount == 3,
              futureImplementationPatch.classifierSourcePath
                == ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
              futureImplementationPatch.gateMustSourceSharedLibrary,
              futureImplementationPatch.everyFutureLiveV2GateMustSourceSharedLibrary,
              futureImplementationPatch
                .everyFutureLiveV2LauncherMustSourceSharedLibrary,
              futureImplementationPatch
                .privateLiveAdmissionTopologyParserCountAfterImplementation
                == 0,
              futureImplementationPatch
                .preservedRetiredV1ParserBytesExcludedFromLiveDuplicateCount,
              futureImplementationPatch.workflowGateInvocationLiteral
                == "source .github/scripts/prime-ci-active-root-quarantine.sh",
              futureImplementationPatch.workflowStepShellLiteral
                == "/bin/bash --noprofile --norc -p -e -o pipefail -- \"{0}\"",
              futureImplementationPatch.workflowStepAndJobCountsPreserved,
              futureImplementationPatch
                .gateRequiresPrivilegedModeBeforeSourcingSharedLibrary,
              futureImplementationPatch.privilegedModeShellOptionToken == "p",
              futureImplementationPatch
                .gatePrivilegedAdmissionIsFirstExecutableStatement,
              futureImplementationPatch.gateSecondExecutableStatementLiteral
                == "builtin unset BASH_ENV ENV",
              futureImplementationPatch.helperSecondExecutableLineLiteral
                == "builtin unset BASH_ENV ENV",
              futureImplementationPatch
                .matrixTestFirstExecutableStatementLiteral
                == "[[ \"$-\" == *p* ]] || exit 97",
              futureImplementationPatch
                .matrixTestSecondExecutableStatementLiteral
                == "builtin unset BASH_ENV ENV",
              futureImplementationPatch
                .futureV2LauncherSecondExecutableStatementLiteral
                == "builtin unset BASH_ENV ENV",
              futureImplementationPatch
                .gateSetAndOptionsFollowPrivilegedAdmissionAndUnset,
              futureImplementationPatch.everyChildBashParseArgumentPrefix
                == ["/bin/bash", "-p", "-n"],
              futureImplementationPatch.preToolBootstrapUsesOnlyBashBuiltins,
              futureImplementationPatch
                .preToolBootstrapReliesOnExactWorkingDirectory,
              !futureImplementationPatch.preToolBootstrapMayInvokeDirname,
              futureImplementationPatch.innerBashGateInvocationForbidden,
              futureImplementationPatch.matrixTestInvokedWithPrivilegedBash,
              futureImplementationPatch
                .everyFutureV2LauncherInvokedWithPrivilegedBash,
              futureImplementationPatch
                .matrixTestInvokedOnlyFromAdmittedPrivilegedGate,
              futureImplementationPatch
                .separateActionsStepRequiresSamePrivilegedCustomShell,
              futureImplementationPatch.sharedHelperAPIContract
                .sourcedFunctionName
                == "prime_verify_exact_revision_topology_v1",
              !futureImplementationPatch.sharedHelperAPIContract
                .ordinalTokensAccepted,
              futureImplementationPatch.sharedHelperAPIContract
                .requestOrdinalsDerivedFromPosition,
              futureImplementationPatch.sharedHelperAPIContract
                .exactArgumentConsumptionRequired,
              !futureImplementationPatch.sharedHelperAPIContract
                .surplusArgumentsAccepted,
              futureImplementationPatch.sharedHelperAPIContract
                .stdoutRecordCount == 1,
              !futureImplementationPatch.sharedHelperAPIContract
                .stderrPublished,
              futureImplementationPatch.bootstrapTrustContract
                .canonicalRepositoryRootRequired,
              futureImplementationPatch.bootstrapTrustContract
                .cleanExactHEADRequired,
              futureImplementationPatch.bootstrapTrustContract
                .worktreeBlobMustEqualExactIndexBlob,
              futureImplementationPatch.bootstrapTrustContract
                .duplicatedTopologyParserCount == 0,
              !futureImplementationPatch.bootstrapTrustContract
                .hostileConcurrentSameEUIDMutationInScope,
              futureImplementationPatch
                .testMayCreateOnlyPrivateTemporaryGitRepositories,
              !futureImplementationPatch.testMayUseNetwork,
              futureImplementationPatch.liveTestMustExerciseExactMatrixCaseIDs
                == (githubDepthTwoMultiWantMatrix.filter {
                    $0.executionKind == "live_private_repository"
                }.map(\.caseID)),
              futureImplementationPatch
                .pureSourceContractMustExerciseExactMatrixCaseIDs
                == (githubDepthTwoMultiWantMatrix.filter {
                    $0.executionKind == "pure_source_contract"
                }.map(\.caseID)),
              futureImplementationPatch.exactPredicateProofGuardIDs
                == verifierPredicateProofPairs.map(\.guardID),
              futureImplementationPatch.classifierDirectFixtureCaseIDs
                == classifierDirectFixtureMatrix.map(\.caseID),
              !futureImplementationPatch
                .historicalEvidenceDynamicallyReplayedByFutureMatrix,
              futureImplementationPatch
                .exactMainGreenRequiredBeforeV2MeasurementAuthority,
              !futureImplementationPatch
                .implementationIncludedInCurrentAuthorityPatch,
              preservationContract.retiredV1PathCount == 11,
              preservationContract.exactRetiredV1Paths.count == 11,
              preservationContract.retiredV1LaunchersMustRemainByteIdentical,
              preservationContract.retiredV1AuthoritiesMustRemainByteIdentical,
              preservationContract.retiredV1ObservationsMustRemainByteIdentical,
              preservationContract.retiredRun160RecordRemainsTerminal,
              preservationContract.retiredRun160OpportunityRemainsRetired,
              !preservationContract.existingV1LaunchersRetrofittedToSharedLibrary,
              !preservationContract.packageManifestMutationAuthorized,
              !preservationContract.packageLockMutationAuthorized,
              !preservationContract.dependencyResolutionAuthorized,
              orderedPhaseASequence.count == 14,
              exactPhaseABranchTransitions.count == 10,
              exactPhaseABranchTransitions.map(\.ordinal)
                == Array(1 ... 10),
              Set(exactPhaseABranchTransitions.map {
                  [$0.state, $0.measurementOutcome ?? "null",
                   $0.pinRelation ?? "null", $0.prerequisite].joined(
                    separator: "|")
              }).count == 10,
              exactPhaseABranchTransitions.allSatisfy({ transition in
                  !transition
                    .retryRerunReplacementOrImplicitCanaryAuthorized
                      && (transition.terminalAbsentNewAuthority
                        == transition
                            .exactAllowedNextAuthorityOrActionIDs.isEmpty)
              }),
              (exactPhaseABranchTransitions.filter {
                  ["DIFFERENT", "UNAVAILABLE", "FAILURE"]
                    .contains($0.measurementOutcome ?? "")
              }.allSatisfy {
                  $0.terminalAbsentNewAuthority
                      && $0.exactAllowedNextAuthorityOrActionIDs.isEmpty
              }),
              authorityCeiling.currentExactMainClosureEstablished,
              authorityCeiling.retiredRun160ClosureEstablished,
              authorityCeiling.run160FailureCauseRemainsInference,
              authorityCeiling.currentPatchAddsOnlyPureAuthorityPair,
              authorityCeiling.futureImplementationScopeFrozen,
              authorityCeiling
                .futureImplementationMayProceedOnlyAfterAuthorityExactMainGreen,
              falseCeilings.allSatisfy({ !$0 })
        else {
            throw PrimeExactRevisionTopologyVerifierAuthorityError
                .contractDrift
        }
    }

    private static func isLowercase40Hex(_ value: String) -> Bool {
        value.utf8.count == 40
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }

    private static func isAllowedRole(_ value: String) -> Bool {
        guard !value.isEmpty, value.utf8.count <= 64,
              let first = value.unicodeScalars.first,
              first.value >= 97, first.value <= 122
        else {
            return false
        }
        return value.unicodeScalars.dropFirst().allSatisfy {
            ($0.value >= 97 && $0.value <= 122)
                || ($0.value >= 48 && $0.value <= 57)
                || $0.value == 95
        }
    }
}
