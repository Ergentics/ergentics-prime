// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeExactRevisionTopologyRelationAmendmentAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// Pure data authority for one later, separately reviewed relation-mode
/// amendment to the frozen exact-revision topology verifier. Constructing,
/// encoding, decoding, or validating this value performs no filesystem,
/// process, Git, compiler, network, fixture, measurement, or canary action.
public struct PrimeExactRevisionTopologyRelationAmendmentAuthorityV1:
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

    public struct PredecessorExactMainClosure:
        Codable,
        Equatable,
        Sendable
    {
        public let repository: String
        public let ref: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedMergeParentOIDs: [String]
        public let historyPreservingTwoParentMergeObserved: Bool
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAtFrozen: Bool
        public let githubSignatureVerifiedAt: String?
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let workflowPreviousAttemptURL: String?
        public let checkSuiteID: Int
        public let workflowConclusion: String
        public let activeRootJobID: Int
        public let activeRootJobConclusion: String
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let actionsArtifactCount: Int
        public let activeLogByteCount: Int
        public let activeLogLFByteCount: Int
        public let activeLogSHA256: String
        public let reviewedLogByteCount: Int
        public let reviewedLogLFByteCount: Int
        public let reviewedLogSHA256: String
        public let activeLatinTestCount: Int
        public let activeLatinFailureCount: Int
        public let rootTestCount: Int
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let aggregateFailureCount: Int
        public let aggregateSkipCount: Int
        public let predecessorAuthorityTestStartCount: Int
        public let predecessorAuthorityTestPassCount: Int
        public let predecessorAuthorityTestDurationSeconds: String
        public let relationImplementationWasPresent: Bool
        public let relationMechanicsRan: Bool
    }

    public struct PredecessorAuthorityIdentity:
        Codable,
        Equatable,
        Sendable
    {
        public let schemaID: String
        public let authorityID: String
        public let canonicalByteCount: Int
        public let canonicalSHA256: String
        public let exactMainRevision: String
        public let exactMainTree: String
        public let exactFileIdentities: [FileIdentity]
        public let embeddedProvenanceRecordCount: Int
        public let embeddedProvenanceSHA256: String
        public let authorityPairMustRemainByteIdentical: Bool
        public let authorityPairSuperseded: Bool
        public let ordinaryFlatAPIWithdrawn: Bool
    }

    public struct RelationAPIContract: Codable, Equatable, Sendable {
        public let sourcedFunctionName: String
        public let ordinaryFlatArgumentGrammar: String
        public let ordinaryFlatCallsWithoutEitherMarkerRemainAcceptedByteForByte: Bool
        public let existingNoMarkerRoleSemanticsSuperseded: Bool
        public let optionalSuffixMarker: String
        public let exactOptionalSuffixGrammar: String
        public let suffixMayOccurAtMostOnce: Bool
        public let suffixMustBeTerminal: Bool
        public let suffixSurplusArgumentsAccepted: Bool
        public let currentIndexMarker: String
        public let exactCurrentIndexMarkerGrammar: String
        public let currentIndexMarkerMayOccurAtMostOnce: Bool
        public let currentIndexMarkerMustBeTerminal: Bool
        public let currentIndexMarkerMutuallyExclusiveWithRelationSuffix: Bool
        public let currentIndexMarkerAddsObjectCount: Int
        public let currentIndexMarkerDuplicatesOIDOrTreeOperand: Bool
        public let currentIndexMarkerSelectsExplicitRequestOrdinal: Int
        public let currentIndexMarkerFailureGuardID: String
        public let ordinaryExplicitRequestMinimum: Int
        public let ordinaryExplicitRequestMaximumWithoutRelationSuffix: Int
        public let ordinaryExplicitRequestMaximumWithSuffix: Int
        public let exactImplicitRelationObjectCount: Int
        public let maximumTotalObjectCount: Int
        public let exactTotalCountFormula: String
        public let mergeAndChildAreAdditionalImplicitObjects: Bool
        public let mergeOrChildAliasesOrdinaryRequestObject: Bool
        public let mergeAndChildAliasEachOther: Bool
        public let fixedParentMayEqualOrdinaryRequestObject: Bool
        public let exactPhysicalOIDDistinctnessRule: String
        public let explicitAndImplicitRolesMustBeUnique: Bool
        public let roleASCIIGrammar: String
        public let maximumRoleUTF8ByteCount: Int
        public let literalOIDGrammar: String
        public let pullRequestCurrentRole: String
        public let pushMergeRole: String
        public let discoveredChildRole: String
        public let mergeMissingRoleSource: String
        public let childMissingRoleSource: String
        public let mergeRelationClassifierModeToken: String
        public let mergeRawStreamInvocationCount: Int
        public let childRawStreamInvocationCount: Int
        public let futureMergeOrChildOIDFrozenHere: Bool
        public let futureImplementationTreeFrozenHere: Bool
        public let exactSupersededPredecessorClauses: [String]
        public let exactForbiddenDesigns: [String]
    }

    public struct EventAdmissionContract: Codable, Equatable, Sendable {
        public let admittedEventKinds: [String]
        public let pullRequestCurrentOIDSource: String
        public let pushCurrentOIDSource: String
        public let workflowDispatchPolicy: String
        public let workflowDispatchHelperInvocationCount: Int
        public let workflowDispatchValidRecordCount: Int
        public let pullRequestUsesOrdinaryFlatRequestAndClassifierModePlusCurrentIndexMarker: Bool
        public let pullRequestCurrentRole: String
        public let pullRequestCurrentRequestOccurrenceCount: Int
        public let pullRequestCurrentRequestExpectedParentCount: Int
        public let pullRequestCurrentRequestExpectedSoleParentSource: String
        public let pullRequestExactFunctionArgumentVector: [String]
        public let pushUsesRelationSuffix: Bool
        public let pushMergeRole: String
        public let pushDiscoveredChildRole: String
        public let pushExactFunctionArgumentVector: [String]
        public let activatedCurrentIndexHelperRequiresExactHEADMatchBeforeObservation: Bool
        public let pullRequestHelperBindsRoleLiteralToHEADAndEvent: Bool
        public let pullRequestHelperBindsRoleTreeToAllIndexTrees: Bool
        public let pushHelperBindsMergeLiteralToHEADAndEvent: Bool
        public let pushHelperBindsSuffixTreeToAllIndexTrees: Bool
        public let eventBeforeMaySupplyTopologyFact: Bool
        public let eventRefMaySupplyTopologyFact: Bool
        public let eventParent2MaySupplyTopologyFact: Bool
        public let currentIndexBarrierActivationPredicate: String
        public let suffixPresentAlwaysActivatesCurrentIndexBarrier: Bool
        public let currentIndexMarkerSelectedExplicitRequestOrdinal: Int
        public let currentIndexMarkerFailureGuardID: String
        public let noMarkerFlatCallUsesLegacySemanticsForEveryRoleSpelling: Bool
        public let legacyFlatHEADInvocationCount: Int
        public let legacyFlatCleanStatusInvocationCount: Int
        public let legacyFlatWriteTreeInvocationCount: Int
        public let legacyNoMarkerTopologyRepositoryMayBeNonHEADOrDirtyWithoutNewBarrier: Bool
    }

    public struct GatePrivateRootContract: Codable, Equatable, Sendable {
        public struct CaptureVector: Codable, Equatable, Sendable {
            public let ordinal: Int
            public let fixtureID: String
            public let constructionKind: String
            public let publicGateOrToolInvocationCount: Int
            public let futurePrivateMatrixRequired: Bool
            public let probeKind: String
            public let producerStatus: Int
            public let consumerStatus: Int
            public let outerSubstitutionStatus: Int
            public let bodyBase64: String
            public let bodyByteCount: Int
            public let bodySHA256: String
            public let trailerBase64: String
            public let trailerByteCount: Int
            public let trailerSHA256: String
            public let captureBase64: String
            public let captureByteCount: Int
            public let captureSHA256: String
            public let accepted: Bool
            public let expectedSanitizedClassification: String
            public let expectedParsedValue: String
        }

        public let runnerTempSource: String
        public let successorGateCopiesAndAdmitsRunnerTempOnceUnderPredecessorContract: Bool
        public let runnerTempMaximumUTF8ByteCount: Int
        public let runnerTempCanonicalAbsoluteOwnedWritableDirectoryNonlink: Bool
        public let runnerTempEnvironmentReadCountAfterAdmission: Int
        public let admittedFixedPaths: [String]
        public let exactUmask: String
        public let exactMktempArgumentVector: [String]
        public let mktempStderrMergedIntoStdoutBeforeBoundedConsumer: Bool
        public let exactPathConsumerArgumentVector: [String]
        public let pathConsumerStderrSink: String
        public let pathCapturePipelineProcessCount: Int
        public let capturesRunUnderLocallyDisabledErrexit: Bool
        public let exactlyTwoPipelineStatusesCaptured: Bool
        public let pathCaptureStatusesSavedImmediately: Bool
        public let statusesCapturedBeforeAnyBuiltinOrErrexitRestore: Bool
        public let exactPathStatusTrailerNotation: String
        public let pathStatusTrailerByteCount: Int
        public let maximumPathBodyReadByteCount: Int
        public let acceptedPathBodyByteCountRange: [Int]
        public let maximumPathCaptureByteCount: Int
        public let acceptedMktempProducerStatus: Int
        public let acceptedPathConsumerStatus: Int
        public let outerPathCommandSubstitutionRequiredStatus: Int
        public let exactPathPrefix: String
        public let exactLeafASCIIRegex: String
        public let pathBodyRequiresExactlyOneTerminalLF: Bool
        public let rootMustBeDirectoryWritableAndFinalComponentNonlink: Bool
        public let exactStatArgumentVector: [String]
        public let exactStatOutputGrammar: String
        public let exactStatConsumerArgumentVector: [String]
        public let statStderrMergedIntoStdoutBeforeBoundedConsumer: Bool
        public let statConsumerStderrSink: String
        public let statCapturePipelineProcessCount: Int
        public let statCaptureStatusesSavedImmediately: Bool
        public let exactStatStatusTrailerNotation: String
        public let statStatusTrailerByteCount: Int
        public let acceptedStatProducerStatus: Int
        public let acceptedStatConsumerStatus: Int
        public let outerStatCommandSubstitutionRequiredStatus: Int
        public let maximumStatBodyReadByteCount: Int
        public let maximumStatCaptureByteCount: Int
        public let expectedStatType: String
        public let expectedStatMode: String
        public let expectedStatOwner: String
        public let gateRootDistinctFromHelperCompilerRoot: Bool
        public let gateRootTMPDIRUseScope: String
        public let retainedUntilJobExitAsNonEvidence: Bool
        public let cleanupInvocationCount: Int
        public let sameEUIDConcurrentMutationInScope: Bool
        public let anyFailureKind: String
        public let anyFailureValidHelperRecordCount: Int
        public let exactCaptureVectors: [CaptureVector]
    }

    public struct PureTestHookContract: Codable, Equatable, Sendable {
        public struct FixtureBinding: Codable, Equatable, Sendable {
            public let ordinal: Int
            public let fixtureRegistry: String
            public let fixtureID: String
            public let hookFunctionName: String
            public let hookMode: String
            public let fixtureSubmode: String
            public let exactInvocationCount: Int
        }

        public let gateProductionFunctionName: String
        public let exactGateProductionFunctionGrammar: String
        public let gateProductionResetsFixedGlobals: Bool
        public let gateProductionUsesSameLiveFramedCaptureParser: Bool
        public let gateProductionClassifiedStatus: Int
        public let gateProductionMisuseStatus: Int
        public let gateProductionStdoutByteCount: Int
        public let gateProductionStderrByteCount: Int
        public let gatePrivateProcessEntryToken: String
        public let gatePrivateProcessWorkingDirectory: String
        public let exactGatePrivateProcessEntryGrammar: String
        public let gateRelativeScriptTokenResolvesToAdmittedAbsoluteIdentity: Bool
        public let gateEntryRunsAfterPrivilegedAndUnsetBootstrap: Bool
        public let normalGateArgumentCount: Int
        public let gateEntryExpectedFieldsAreTestOnlyAndNotPassedToProductionParser: Bool
        public let gateEntryMatchStatus: Int
        public let gateEntryMismatchOrMisuseStatus: Int
        public let gateEntryStdoutByteCount: Int
        public let gateEntryStderrByteCount: Int
        public let liveGateCapturesUsePrivateTestEntry: Bool
        public let helperHookFunctionName: String
        public let exactHelperHookGrammar: String
        public let exactHelperHookModes: [String]
        public let exactHelperModeGrammars: [String]
        public let exactSelectorTupleGrammar: String
        public let selectorHookComparesProductionSelectedMissingRoleToExpectedTupleIncludingEmpty:
            Bool
        public let rawCaptureIsOneNULFreeArgument: Bool
        public let helperHookResetsFixedGlobals: Bool
        public let exactSanitizedHelperGlobalNames: [String]
        public let privateCandidateGlobalName: String
        public let privateCandidateMayBePublished: Bool
        public let traceAdmissionRunsBeforePrivateCandidate: Bool
        public let exactRequiredSharedProductionSymbols: [String]
        public let copiedParserOrSelectorLogicCount: Int
        public let helperHookClassifiedStatus: Int
        public let helperHookMisuseStatus: Int
        public let helperHookStdoutByteCount: Int
        public let helperHookStderrByteCount: Int
        public let gitInvocationCount: Int
        public let toolInvocationCount: Int
        public let filesystemInvocationCount: Int
        public let publicHelperRecordCount: Int
        public let projectionInvocationCount: Int
        public let witnessPublicationCount: Int
        public let exactOneHookCallPerFixture: Bool
        public let exactFixtureBindings: [FixtureBinding]
    }

    public struct IndexObservationContract: Codable, Equatable, Sendable {
        public struct ProbeCaptureVector: Codable, Equatable, Sendable {
            public let ordinal: Int
            public let fixtureID: String
            public let probeKind: String
            public let producerStatus: Int
            public let consumerStatus: Int
            public let outerSubstitutionStatus: Int
            public let bodyBase64: String
            public let bodyByteCount: Int
            public let bodySHA256: String
            public let trailerBase64: String
            public let trailerByteCount: Int
            public let trailerSHA256: String
            public let captureBase64: String
            public let captureByteCount: Int
            public let captureSHA256: String
            public let accepted: Bool
            public let expectedExternalAdmissionFailure: Bool
            public let failureValidHelperRecordCount: Int?
        }

        public let cleanEnvironmentPrefix: [String]
        public let exactHEADArgumentVector: [String]
        public let exactCleanStatusArgumentVector: [String]
        public let exactWriteTreeArgumentVector: [String]
        public let exactGateCleanStatusArgumentVector: [String]
        public let exactGateWriteTreeArgumentVector: [String]
        public let exactHelperHEADArgumentVector: [String]
        public let exactHelperCleanStatusArgumentVector: [String]
        public let exactHelperWriteTreeArgumentVector: [String]
        public let gateAndHelperPrivateRootsAreDistinct: Bool
        public let exactHEADOutputGrammar: String
        public let exactCleanStatusSuccessOutputByteCount: Int
        public let exactWriteTreeOutputGrammar: String
        public let maximumHEADOutputByteCount: Int
        public let maximumCleanStatusOutputByteCount: Int
        public let maximumWriteTreeOutputByteCount: Int
        public let gateHEADInvocationCount: Int
        public let gateCleanStatusInvocationCount: Int
        public let gateWriteTreeInvocationCount: Int
        public let helperPreHEADInvocationCount: Int
        public let helperPreCleanStatusInvocationCount: Int
        public let helperPreWriteTreeInvocationCount: Int
        public let helperPostHEADInvocationCount: Int
        public let helperPostCleanStatusInvocationCount: Int
        public let helperPostWriteTreeInvocationCount: Int
        public let exactActorOrder: [String]
        public let exactInvocationCountScope: String
        public let allThreeWriteTreeOIDsMustEqual: Bool
        public let bothHelperCleanStatusesRequired: Bool
        public let helperEmitsRecordOnlyAfterPostObservationPasses: Bool
        public let gateCaptureCompletesOnlyAfterHelperReturns: Bool
        public let gateValidatesBeforeProjection: Bool
        public let indexAdmissionFailureValidHelperRecordCount: Int
        public let indexAdmissionFailureKind: String
        public let writeTreeIsPureObservation: Bool
        public let writeTreeMayMaterializeTreeObject: Bool
        public let indexTreeIsTopologyFactByItself: Bool
        public let rawMergeAndChildTreesMustEqualIndexTree: Bool
        public let fixedBoundedConsumerPath: String
        public let fixedDiagnosticSinkPath: String
        public let consumerAndSinkIdentitiesAdmittedBeforeFirstProbe: Bool
        public let exactHEADConsumerArgumentVector: [String]
        public let exactCleanStatusConsumerArgumentVector: [String]
        public let exactWriteTreeConsumerArgumentVector: [String]
        public let gitStderrMergedIntoStdoutBeforeBoundedConsumer: Bool
        public let boundedConsumerStderrRedirectedToFixedDiagnosticSink: Bool
        public let probePipelineProcessCount: Int
        public let probePipelineRunsUnderLocallyDisabledErrexit: Bool
        public let probePipelineStatusesCapturedImmediately: Bool
        public let probeStatusesCapturedBeforeErrexitRestore: Bool
        public let exactProbeStatusTrailerNotation: String
        public let probeStatusTrailerByteCount: Int
        public let outerCommandSubstitutionRequiredStatus: Int
        public let exactProbeKinds: [String]
        public let exactProbeBodyReadCaps: [Int]
        public let exactAcceptedProbeBodyByteCounts: [Int]
        public let exactMaximumProbeCaptureByteCounts: [Int]
        public let acceptedProbeProducerStatus: Int
        public let acceptedProbeConsumerStatus: Int
        public let producerOrConsumerStderrPublished: Bool
        public let probeFailureKind: String
        public let probeFailureValidHelperRecordCount: Int
        public let exactProbeCaptureVectors: [ProbeCaptureVector]
    }

    public struct PostRawIndexMutationTestSeamContract:
        Codable,
        Equatable,
        Sendable
    {
        public let productionCoreFunctionName: String
        public let publicSourcedFunctionName: String
        public let matrixOnlyWrapperFunctionName: String
        public let exactClosedCoreModes: [String]
        public let publicWrapperCoreMode: String
        public let matrixWrapperCoreMode: String
        public let publicWrapperCallsCoreExactlyOnce: Bool
        public let matrixWrapperCallsCoreExactlyOnce: Bool
        public let internalCoreIsExported: Bool
        public let exactModeBranchCount: Int
        public let modeSelectionIsOneStaticClosedCaseBranch: Bool
        public let normalPublicCallsAlwaysUseNone: Bool
        public let mutationCallbackInvocationCount: Int
        public let evalInvocationCount: Int
        public let sourceInvocationCount: Int
        public let environmentHookReadCount: Int
        public let globalHookReadCount: Int
        public let arbitraryMutationCommandArgumentCount: Int
        public let arbitraryMutationPathArgumentCount: Int
        public let arbitraryMutationOIDArgumentCount: Int
        public let gateMutationSeamInvocationCount: Int
        public let mutationModeAdditionalPublicAPIArgumentCount: Int
        public let standardVerifierArgumentsForwardedUnchanged: Bool
        public let exactMutationTiming: String
        public let alternateTreeFixtureID: String
        public let exactReadTreeArgumentVector: [String]
        public let readTreeExpectedStatus: Int
        public let readTreeExpectedStdinByteCount: Int
        public let readTreeExpectedStdoutByteCount: Int
        public let readTreeExpectedStderrByteCount: Int
        public let readTreeInvocationCountInNoneMode: Int
        public let readTreeInvocationCountInAlternateMode: Int
        public let HEADMutationInvocationCount: Int
        public let exactPostHEADBodySource: String
        public let exactPostHEADProbeStatusPair: String
        public let postHEADOuterSubstitutionStatus: Int
        public let exactPostCleanStatusProbeFixtureID: String
        public let exactPostCleanStatusBody: String
        public let exactPostCleanStatusProbeStatusPair: String
        public let postCleanStatusOuterSubstitutionStatus: Int
        public let postWriteTreeInvocationCountAfterStatusFailure: Int
        public let expectedExternalAdmissionFailure: Bool
        public let expectedValidHelperRecordCount: Int
        public let expectedProjectionInvocationCount: Int
        public let futureMatrixComponentPath: String
        public let futureMatrixFunctionName: String
        public let exactFutureMatrixFunctionGrammar: String
        public let exactFutureMatrixCallSiteLiteral: String
        public let exactFutureMatrixCallSiteCount: Int
        public let futurePrivateMatrixInvocationCount: Int
    }

    public struct PreprobeWaveContract: Codable, Equatable, Sendable {
        public let wave1Objects: String
        public let wave1GuardPhaseRangeInFlatSchedule: [Int]
        public let wave1GuardPhaseRangeInRelationSchedule: [Int]
        public let wave1FailureRawStreamCount: Int
        public let afterWave1ExactCollection: String
        public let flatPhase19OrLaterExplicitFailureCausesEarlyReturn: Bool
        public let relationPhase20OrLaterExplicitFailureCausesEarlyReturn: Bool
        public let safeParent2StillTriggersWave2AfterEarlierRawFailure: Bool
        public let wave2Objects: String
        public let wave2BeginsOnlyAfterExactWitnessFrame: Bool
        public let wave2GuardPhaseRangeInRelationSchedule: [Int]
        public let wave2FailureChildRawStreamCount: Int
        public let noSafeParent2ChildPreprobeCount: Int
        public let noSafeParent2ChildRawStreamCount: Int
        public let allEligibleOutcomesCollectedBeforeSelection: Bool
        public let firstFailureOrder: String
    }

    public struct ClassifierBuildAdmissionContract:
        Codable,
        Equatable,
        Sendable
    {
        public let existingSelfTestArgumentVector: [String]
        public let additionalSelfTestArgumentVectorCount: Int
        public let expectedStatus: Int
        public let expectedStdoutByteCount: Int
        public let expectedStderrByteCount: Int
        public let sameOrdinaryParserAndClassifierFunctionsCalled: Bool
        public let sameRelationEvaluatorAndWitnessConstructorCalled: Bool
        public let duplicateParserOrConstantsPermitted: Bool
        public let relationWitnessComparedOnlyInMemory: Bool
        public let selfTestStdoutEmitterInvocationCount: Int
        public let exactMinimumInternalVectors: [String]
        public let liveWriteAndEPIPECoveredBySelfTest: Bool
        public let liveWriteAndEPIPECoveredByPrivateMatrix: Bool
        public let successfulSelfTestRequiredBeforeOrdinaryOrRelationRawStream: Bool
    }

    public struct StatusPayloadRule: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let mode: String
        public let classifierStatuses: [Int]
        public let exactEligibility: String
        public let bodyRule: String
        public let minimumBodyByteCount: Int
        public let maximumBodyByteCount: Int
        public let bodyMayBecomeChildOID: Bool
        public let mappedGuardID: String?
    }

    public struct RelationClassifierContract:
        Codable,
        Equatable,
        Sendable
    {
        public let sourcePath: String
        public let ordinaryModePreserved: Bool
        public let relationModeToken: String
        public let exactRelationArgumentVector: [String]
        public let exactKnownExitStatuses: [Int]
        public let exactStatusPayloadRules: [StatusPayloadRule]
        public let usesSamePrivateAdmittedExecutable: Bool
        public let usesSameEmptyEnvironment: Bool
        public let usesSameProcPIDInfoFDClosure: Bool
        public let exactFinalFDSet: [Int]
        public let usesSameSingleLogicalFD0ReadToEOF: Bool
        public let usesSameBoundedDrain: Bool
        public let maximumCommitObjectByteCount: Int
        public let boundedReadLimitByteCount: Int
        public let usesSHA1RawCommitIdentityRebinding: Bool
        public let SHA1Purpose: String
        public let SHA1ClaimsSecurityStrength: Bool
        public let usesSameNULAndHeaderGrammar: Bool
        public let commitMessageParsed: Bool
        public let safeWitnessRequiresBaseFlatHeaderPhaseRange: [Int]
        public let safeWitnessRequiresRelationHeaderPhaseRange: [Int]
        public let safeWitnessRequiresActualParentCountAtLeast: Int
        public let safeParent2TreeAndParentMismatchesDeferredUntilAfterDiscovery: Bool
        public let discoveredParent2RequiresLowercase40Hex: Bool
        public let exactWitnessGrammar: String
        public let exactWitnessByteCount: Int
        public let ordinaryModeStdoutByteCount: Int
        public let stderrByteCountEveryOutcome: Int
        public let stdoutFcntlCommand: String
        public let signalHandlerInstalled: Bool
        public let exactLogicalWriteOperationCount: Int
        public let physicalWriteSyscallInvocationCount: String
        public let intendedBlockingWriteByteCount: Int
        public let writeRetryCondition: String
        public let shortZeroOrErrorWriteExitStatus: Int
        public let exit28IsLastFallibleClassifierOutcome: Bool
        public let exit28PrefixEverConsumed: Bool
    }

    public struct RelationCaptureContract: Codable, Equatable, Sendable {
        public let classifierStdoutFilesystemCaptureCount: Int
        public let commandSubstitutionCaptureRequired: Bool
        public let pipelineProcessCount: Int
        public let pipelineRunsUnderLocallyDisabledErrexit: Bool
        public let pipelineStatusesCapturedImmediately: Bool
        public let statusesCapturedBeforeErrexitRestore: Bool
        public let exactStatusTrailerNotation: String
        public let exactStatusTrailerASCIIRegex: String
        public let statusTrailerByteCount: Int
        public let maximumBodyByteCount: Int
        public let maximumCaptureByteCount: Int
        public let witnessTerminalLFPreservedBeforeTrailer: Bool
        public let gitNonzeroHasPrecedence: Bool
        public let rawWitnessPublished: Bool
        public let rawWitnessStoredAsDurableEvidence: Bool
        public let exactFrameGuardID: String
        public let exactFrameFailureResultCode: String
        public let frameCheckedBeforeChildPreprobe: Bool
        public let exit28AdmittedPrefixLengths: [Int]
        public let exit28AdmittedPrefixLengthCount: Int
        public let exit28EveryAdmittedPrefixNeverConsumed: Bool
        public let exit28Exact41BodyRejected: Bool
        public let trailerSyntaxValidatedBeforeClassifierStatusMembership: Bool
        public let unknownClassifierStatusGuardID: String
        public let xtraceAndVerboseDisabledAndVerifiedBeforeWitness: Bool
        public let debugAndReturnTrapsAbsentBeforeWitness: Bool
        public let errTrapAbsentBeforeWitness: Bool
        public let errtraceAndFunctraceDisabledAndVerifiedBeforeWitness: Bool
        public let bashXtraceFDUnsetBeforeWitness: Bool
        public let PS4InfluenceNeutralizedBeforeWitness: Bool
        public let hostileTraceStateFailsBeforeWitnessEntersShellState: Bool
        public let hostileTraceStateValidHelperRecordCount: Int
        public let hostileTraceMatrixRequired: Bool
        public let privateWitnessMayAppearInTraceOrStderr: Bool
    }

    public struct DependentChildContract: Codable, Equatable, Sendable {
        public let childRoleSource: String
        public let childLiteralOIDSource: String
        public let childPreprobeOccursAfterDistinctnessGuard: Bool
        public let childPreprobeInvocationCountOnSafeDistinctWitness: Int
        public let childRawStreamInvocationCountAfterPassingPreprobe: Int
        public let childUsesOrdinaryClassifierMode: Bool
        public let childExpectedTreeSource: String
        public let childExpectedParentCount: Int
        public let childExpectedSoleParentSource: String
        public let childMissingRoleSource: String
        public let childTreeFailureGuardID: String
        public let childParentFailureGuardID: String
        public let childObservationUsesCleanGitEnvironment: Bool
        public let childObservationUsesReplacementDisabled: Bool
        public let childObservationUsesLazyFetchDisabled: Bool
        public let childObservationMayUseHistoryTraversal: Bool
    }

    public struct GuardMapping: Codable, Equatable, Sendable {
        public let phaseOrdinal: Int
        public let guardID: String
        public let resultCode: String
        public let scope: String
    }

    public struct NewGuardContract: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let guardID: String
        public let relationPhaseOrdinal: Int
        public let resultCode: String
        public let exactScope: String
    }

    public struct ResultContract: Codable, Equatable, Sendable {
        public let exactOrderedResultCodes: [String]
        public let resultTaxonomyCount: Int
        public let predecessorResultTaxonomyPreserved: Bool
        public let exactFlatGuardMappings: [GuardMapping]
        public let exactFlatGuardCount: Int
        public let exactRelationGuardMappings: [GuardMapping]
        public let exactRelationGuardCount: Int
        public let exactNewGuards: [NewGuardContract]
        public let phaseMajorThenLogicalObjectOrdinalMinor: Bool
        public let explicitObjectOrdinalFormula: String
        public let mergeObjectOrdinalFormula: String
        public let childObjectOrdinalFormula: String
        public let relationPhase14ChildFailureMayOutrankEarlierPhase20OrLaterExplicitFailure: Bool
        public let treeGuardAppliedIndependentlyToMergeAndChild: Bool
        public let parentGuardAppliedIndependentlyToMergeAndChild: Bool
        public let mergePostDiscoveryExpectedOrderedParentsProjection: String
        public let childExpectedOrderedParents: String
        public let malformedWitnessGuardID: String
        public let sanitizedRecordSchemaUnchanged: Bool
        public let exactRecordCountAfterCompleteAdmission: Int
        public let successReturnStatusUnchanged: Int
        public let nonSuccessReturnStatusUnchanged: Int
    }

    public struct SyntheticGitObjectFixture:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let fixtureID: String
        public let objectType: String
        public let payloadEncoding: String
        public let payloadBase64: String
        public let payloadByteCount: Int
        public let payloadSHA256: String
        public let literalObjectOID: String
        public let parsedTreeOID: String?
        public let parsedOrderedParentOIDs: [String]
        public let structurallyValidHeader: Bool?
        public let destinationDisposition: String
        public let expectedDestinationInventoryPresent: Bool
        public let expectedPreprobeAvailability: String
        public let literalOIDRecomputedAndRequiredEqualBeforeUse: Bool
        public let noNetwork: Bool
    }

    public struct FixtureInventoryRow: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let fixtureID: String
        public let literalObjectOID: String
        public let expectedPresent: Bool
        public let expectedExactPreprobeLine: String
        public let expectedExactGitBatchCheckLine: String
    }

    public struct PrivateFixtureRepositoryContract:
        Codable,
        Equatable,
        Sendable
    {
        public let objectFormat: String
        public let noNetwork: Bool
        public let privateTemporaryRepositoryOnly: Bool
        public let exactWriteAPI: String
        public let exactWrittenFixtureIDs: [String]
        public let exactWithheldFixtureIDs: [String]
        public let withheldFixtureWriteInvocationCount: Int
        public let exactInventoryRows: [FixtureInventoryRow]
        public let exactInventoryArgumentVector: [String]
        public let inventoryStdinBase64: String
        public let inventoryStdinByteCount: Int
        public let inventoryStdinSHA256: String
        public let inventoryExpectedStatus: Int
        public let inventoryExpectedStdoutBase64: String
        public let inventoryExpectedStdoutByteCount: Int
        public let inventoryExpectedStdoutSHA256: String
        public let inventoryExpectedStderrByteCount: Int
        public let inventoryRunsBeforeOntologyCases: Bool
        public let inventoryMustMatchExactly: Bool
    }

    public struct PrivateRepositoryExecutionRecipe:
        Codable,
        Equatable,
        Sendable
    {
        public let ordinal: Int
        public let recipeID: String
        public let ontologyCaseID: String
        public let exactInitArgumentVector: [String]
        public let initExpectedStatus: Int
        public let initExpectedStdinByteCount: Int
        public let initExpectedStdoutByteCount: Int
        public let initExpectedStderrByteCount: Int
        public let exactWrittenFixtureIDs: [String]
        public let exactObjectWriteArgumentVectorTemplate: [String]
        public let objectWriteStdinSource: String
        public let everyObjectWriteExpectedStatus: Int
        public let everyObjectWriteExpectedStdout: String
        public let everyObjectWriteExpectedStderrByteCount: Int
        public let exactWithheldFixtureIDs: [String]
        public let withheldFixtureWriteInvocationCount: Int
        public let exactUpdateRefHEADArgumentVector: [String]
        public let eventCurrentFixtureID: String
        public let updateRefExpectedStatus: Int
        public let updateRefExpectedStdinByteCount: Int
        public let updateRefExpectedStdoutByteCount: Int
        public let updateRefExpectedStderrByteCount: Int
        public let exactReadTreeArgumentVector: [String]
        public let independentIndexTreeFixtureID: String
        public let readTreeExpectedStatus: Int
        public let readTreeExpectedStdinByteCount: Int
        public let readTreeExpectedStdoutByteCount: Int
        public let readTreeExpectedStderrByteCount: Int
        public let typedMutationTokens: [String]
        public let exactExpectedGateProbeBodies: [String]
        public let exactExpectedHelperPreProbeBodies: [String]
        public let exactExpectedHelperPostProbeBodies: [String]
        public let exactExpectedProbeStatusPairs: [String]
        public let inventoryRequiredBeforeCase: Bool
        public let expectedHelperInvocationCount: Int
        public let expectedValidHelperRecordCount: Int
    }

    public struct ComponentHarnessRecipe: Codable, Equatable, Sendable {
        public struct Step: Codable, Equatable, Sendable {
            public let ordinal: Int
            public let stepKind: String
            public let executionKind: String
            public let exactContractSource: String
            public let literalObjectOID: String?
            public let logicalObjectOrdinal: Int?
            public let classifierMode: String?
            public let expectedTreeOID: String?
            public let fixedParentOID: String?
            public let advertisedObjectByteCount: Int?
            public let exactGitArgumentVector: [String]
            public let exactClassifierArgumentVector: [String]
            public let exactPreprobeStdin: String?
            public let stdinFixtureID: String?
            public let exactPreprobeLine: String?
            public let producerStatus: Int?
            public let classifierStatus: Int?
            public let captureFixtureID: String?
            public let exactDistinctnessComparisonOIDs: [String]
            public let distinctnessExpectedPass: Bool?
            public let physicalGitInvocationCount: Int
            public let physicalClassifierInvocationCount: Int
            public let productionFrameAdmissionInvocationCount: Int
            public let pureFrameInjectionHookInvocationCount: Int
        }

        public let ordinal: Int
        public let recipeID: String
        public let ontologyCaseID: String
        public let privateRepositoryRecipeID: String
        public let constructionKind: String
        public let futureMatrixComponentPath: String
        public let futureMatrixFunctionName: String
        public let exactFutureMatrixFunctionGrammar: String
        public let exactFutureMatrixCallSiteLiteral: String
        public let exactFutureMatrixCallSiteCount: Int
        public let publicHelperInvocationCount: Int
        public let gateInvocationCount: Int
        public let indexBarrierInvocationCount: Int
        public let validHelperRecordCount: Int
        public let projectionInvocationCount: Int
        public let classifierBuildInvocationCount: Int
        public let reusesAdmittedSelfTestedClassifier: Bool
        public let exactOrderedSteps: [Step]
        public let exactSelectorCandidateTuples: [String]
        public let successfulCandidateTupleCount: Int
        public let selectorHookInvocationCount: Int
        public let expectedResultCode: String
        public let expectedFirstFailedGuardID: String?
        public let expectedFirstFailedPhaseOrdinal: Int?
        public let expectedFirstFailureObjectOrdinal: Int?
        public let expectedMissingObjectRole: String?
        public let rawParent2CaptureAndChildLiteralMustEqual: Bool
        public let childDistinctnessStepPrecedesChildPreprobeAndAllComparedOIDsDiffer:
            Bool
    }

    public struct DeterministicLiveEPIPERecipe:
        Codable,
        Equatable,
        Sendable
    {
        public let recipeID: String
        public let executionKind: String
        public let futureMatrixComponentPath: String
        public let futureMatrixFunctionName: String
        public let exactFutureMatrixFunctionGrammar: String
        public let exactFutureMatrixCallSiteLiteral: String
        public let exactFutureMatrixCallSiteCount: Int
        public let futurePrivateMatrixInvocationCount: Int
        public let publicHelperInvocationCount: Int
        public let gateInvocationCount: Int
        public let validHelperRecordCount: Int
        public let projectionInvocationCount: Int
        public let witnessPublicationCount: Int
        public let validatedPrivateMatrixRootRequired: Bool
        public let exactUmask: String
        public let exactAdmittedToolPaths: [String]
        public let fifoPath: String
        public let fifoLeafASCIIRegex: String
        public let fifoMustBeAbsentAndFinalComponentNonlinkBeforeCreation: Bool
        public let exactMkfifoArgumentVector: [String]
        public let mkfifoExpectedStatus: Int
        public let mkfifoExpectedStdoutByteCount: Int
        public let mkfifoExpectedStderrByteCount: Int
        public let exactFifoStatArgumentVector: [String]
        public let exactFifoStatOutput: String
        public let fifoStatExpectedStatus: Int
        public let fifoOwnerMustEqualEffectiveUID: Bool
        public let fifoReaderProcessCount: Int
        public let readerOpenDescriptor: Int
        public let parentWriterDescriptor: Int
        public let exactReaderLaunchGrammar: String
        public let exactClassifierLaunchGrammar: String
        public let exactHandshakeOrder: [String]
        public let readerExpectedStatus: Int
        public let readerIsWaitedAndClosedBeforeClassifierLaunch: Bool
        public let zeroFIFOReadersProvedBeforeClassifierLaunch: Bool
        public let classifierStandardOutputDuplicatesWriterDescriptor: Bool
        public let requiredClassifierInheritedFDSubsetBeforeProductionClosure: [Int]
        public let additionalInheritedDescriptorsMayExistAndMustBeClosed: Bool
        public let exactClassifierFinalFDsAfterProductionClosure: [Int]
        public let stdinFixtureID: String
        public let stdinFixturePayloadByteCount: Int
        public let stdinFixturePayloadSHA256: String
        public let exactClassifierArgumentVector: [String]
        public let exactExpectedClassifierStatus: Int
        public let exactExpectedClassifierStdoutBodyByteCount: Int
        public let exactExpectedClassifierStderrByteCount: Int
        public let expectedStatusPayloadFixtureID: String
        public let exercisesProductionFSETNOSIGPIPEPath: Bool
        public let signalHandlerInstalled: Bool
        public let classifierOrParentShellSIGPIPECount: Int
        public let writeReturnsEPIPEBeforeAnyProgress: Bool
        public let exactLogicalWitnessWriteOperationCount: Int
        public let classifierWaitStatusCapturedExactlyOnce: Bool
        public let partialPrefixLengthsOneThroughFortyArePureInjectionsOnly: Bool
        public let exactCleanupArgumentVector: [String]
        public let cleanupExpectedStatus: Int
        public let cleanupInvocationCount: Int
        public let noNetwork: Bool
        public let sameEUIDConcurrentMutationInScope: Bool
    }

    public struct CaptureFixture: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let fixtureID: String
        public let mode: String
        public let gitStatus: Int
        public let classifierStatus: Int
        public let bodyBase64: String
        public let bodyByteCount: Int
        public let bodySHA256: String
        public let trailerBase64: String
        public let trailerByteCount: Int
        public let trailerSHA256: String
        public let captureBase64: String
        public let captureByteCount: Int
        public let captureSHA256: String
        public let statusPayloadPairAdmitted: Bool
        public let bodyConsumedAsChildOID: Bool
        public let expectedResultCode: String
        public let expectedFirstFailedGuardID: String?
    }

    public struct ValueDomainFixture: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let fixtureID: String
        public let constructionKind: String
        public let exactCondition: String
        public let rawGitFixtureClaimed: Bool
        public let expectedResultCode: String
        public let expectedFirstFailedGuardID: String
    }

    public struct InvocationParserVector: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let fixtureID: String
        public let executionKind: String
        public let expectedMode: String
        public let exactArgumentTokens: [String]
        public let expectedAccepted: Bool
        public let expectedResultCode: String
        public let expectedFirstFailedGuardID: String?
        public let expectedFirstFailedPhaseOrdinal: Int?
        public let expectedFirstFailureObjectOrdinal: Int?
        public let expectedGitInvocationCount: Int
        public let expectedValidHelperRecordCount: Int
        public let futurePrivateMatrixRequired: Bool
    }

    public struct RelationOntologyCase: Codable, Equatable, Sendable {
        public struct InvocationRecipe: Codable, Equatable, Sendable {
            public let recipeKind: String
            public let repositoryArgumentToken: String
            public let exactHelperArgumentTokens: [String]
            public let exactPureHookStimulusTokens: [String]
            public let exactExternalStateTokens: [String]
            public let referencedFixtureIDs: [String]
        }

        public let ordinal: Int
        public let caseID: String
        public let executionKind: String
        public let eventKind: String
        public let suffixEnabled: Bool
        public let currentIndexMarkerOccurrenceCount: Int
        public let relationSuffixOccurrenceCount: Int
        public let validatedSuffixMergeRole: String?
        public let validatedSuffixChildRole: String?
        public let invocationRecipe: InvocationRecipe
        public let privateRepositoryRecipeID: String?
        public let explicitFixtureIDs: [String]
        public let relationMergeFixtureID: String?
        public let discoveredChildFixtureID: String?
        public let captureFixtureID: String?
        public let valueDomainFixtureID: String?
        public let exactInjectedCondition: String
        public let expectedResultCode: String
        public let expectedFirstFailedGuardID: String?
        public let expectedFirstFailedPhaseOrdinal: Int?
        public let expectedMissingObjectRole: String?
        public let expectedFirstFailureObjectOrdinal: Int?
        public let expectedRelationClassifierStatus: Int?
        public let expectedPublicExplicitRawStreamCount: Int
        public let expectedPublicMergeRawStreamCount: Int
        public let expectedPublicChildPreprobeCount: Int
        public let expectedPublicChildRawStreamCount: Int
        public let expectedComponentExplicitPreprobeGitInvocationCount: Int
        public let expectedComponentExplicitRawGitInvocationCount: Int
        public let expectedComponentExplicitClassifierInvocationCount: Int
        public let expectedComponentExplicitFrameInjectionCount: Int
        public let expectedComponentMergePreprobeGitInvocationCount: Int
        public let expectedComponentMergeRawGitInvocationCount: Int
        public let expectedComponentMergeClassifierInvocationCount: Int
        public let expectedComponentChildPreprobeGitInvocationCount: Int
        public let expectedComponentChildRawGitInvocationCount: Int
        public let expectedComponentChildClassifierInvocationCount: Int
        public let expectedPureRelationFrameInjectionCount: Int
        public let expectedPublicHelperInvocationCount: Int
        public let expectedValidHelperRecordCount: Int
        public let isolatedPredicateID: String
        public let reproducibleRawBytesRequired: Bool
    }

    public struct OntologyProofPair: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let pairID: String
        public let predicateID: String
        public let positiveCaseID: String
        public let negativeCaseID: String
        public let expectedDifferingSemanticFactIDs: [String]
        public let predicatesAreDisjoint: Bool
        public let predicatesAreExhaustive: Bool
        public let negativeUsesReproducibleRawBytesOrTruthfulPureDomain: Bool
    }

    public struct TOCTOUContract: Codable, Equatable, Sendable {
        public let admittedSourcePaths: [String]
        public let everySourcePathRegularNonlink: Bool
        public let worktreeBlobMustEqualIndexBlob: Bool
        public let compilerUsesAdmittedRelativeTokenAtCanonicalRoot: Bool
        public let gateAndHelperIndexTreesCompared: Bool
        public let helperIndexTreeObservedBeforeAndAfter: Bool
        public let helperCleanStatusObservedBeforeAndAfter: Bool
        public let rawMergeOIDReboundFromExactStream: Bool
        public let rawChildOIDReboundFromExactStream: Bool
        public let replacementObjectsDisabledEverywhere: Bool
        public let lazyFetchDisabledEverywhere: Bool
        public let witnessSanitizedBeforeShellReuse: Bool
        public let witnessMayContainPathRefOrDiagnostic: Bool
        public let relationObjectsAddressedOnlyByLiteralOIDs: Bool
        public let historyTraversalInvocationCount: Int
        public let privateDuplicateTopologyParserCount: Int
        public let sameEUIDConcurrentMutationInScope: Bool
        public let sameEUIDBoundaryReason: String
        public let detectedIndexMutationOutcome: String
        public let detectedObjectTransportMutationOutcome: String
        public let retryAfterDetectedMutationAuthorized: Bool
    }

    public struct ExternalClosureRequirement:
        Codable,
        Equatable,
        Sendable
    {
        public let amendmentOwnPRHeadRevisionFrozen: Bool
        public let amendmentOwnPRHeadTreeFrozen: Bool
        public let amendmentOwnMergeRevisionFrozen: Bool
        public let amendmentOwnMergeTreeFrozen: Bool
        public let amendmentOwnExactMainRunFrozen: Bool
        public let externalPRAndExactMainClosureRequiredBeforeImplementation: Bool
        public let futureImplementationFixedParentSource: String
        public let futureImplementationMayBindHistoricalAmendmentClosure: Bool
        public let futureImplementationMayFreezeItsOwnFutureHeadOrTree: Bool
        public let successorImplementationRequiresNoInterveningMainCommit: Bool
    }

    public struct PatchContract: Codable, Equatable, Sendable {
        public let exactOrderedCurrentPaths: [PathContract]
        public let exactCurrentPathCount: Int
        public let currentModifiedExistingPathCount: Int
        public let currentAddedPathCount: Int
        public let soleTestClassName: String
        public let soleTestMethodName: String
        public let soleTestExpectedStartCount: Int
        public let soleTestExpectedPassCount: Int
        public let expectedActiveLatinTestCount: Int
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedEmbeddedProvenanceRecordCount: Int
        public let exactOrderedFutureImplementationPaths: [PathContract]
        public let exactFutureImplementationPathCount: Int
        public let futureImplementationExactFiveUnchanged: Bool
        public let existingAuthoritySourcePath: String
        public let existingAuthorityTestPath: String
        public let existingAuthorityPairMustRemainByteIdentical: Bool
        public let packageManifestMutationAuthorized: Bool
        public let packageLockMutationAuthorized: Bool
        public let dependencyResolutionAuthorized: Bool
    }

    public struct StaticSourceContract: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let componentPath: String
        public let requiredSymbolOrLiteral: String
        public let requiredInvariantOrBranchAnchor: String
        public let proofKind: String
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let predecessorExactMainClosureEstablished: Bool
        public let predecessorAuthorityIdentityEstablished: Bool
        public let amendmentIsPureData: Bool
        public let amendmentAddsImplementation: Bool
        public let amendmentRunsMechanics: Bool
        public let filesystemReadPerformed: Bool
        public let filesystemWritePerformed: Bool
        public let processExecutionPerformed: Bool
        public let gitExecutionPerformed: Bool
        public let networkExecutionPerformed: Bool
        public let compilerExecutionPerformed: Bool
        public let verifierExecutionPerformed: Bool
        public let fixtureExecutionPerformed: Bool
        public let measurementAuthorityEstablished: Bool
        public let measurementMechanicsPerformed: Bool
        public let confirmationAuthorized: Bool
        public let realCanaryAuthorized: Bool
        public let retryOrRerunAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
        public let futureImplementationScopeNarrowlyAmended: Bool
        public let externalClosureRequired: Bool
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let predecessorExactMainClosure: PredecessorExactMainClosure
    public let predecessorAuthorityIdentity: PredecessorAuthorityIdentity
    public let relationAPIContract: RelationAPIContract
    public let eventAdmissionContract: EventAdmissionContract
    public let gatePrivateRootContract: GatePrivateRootContract
    public let pureTestHookContract: PureTestHookContract
    public let indexObservationContract: IndexObservationContract
    public let postRawIndexMutationTestSeamContract:
        PostRawIndexMutationTestSeamContract
    public let preprobeWaveContract: PreprobeWaveContract
    public let classifierBuildAdmissionContract: ClassifierBuildAdmissionContract
    public let relationClassifierContract: RelationClassifierContract
    public let relationCaptureContract: RelationCaptureContract
    public let dependentChildContract: DependentChildContract
    public let resultContract: ResultContract
    public let syntheticGitObjectFixtures: [SyntheticGitObjectFixture]
    public let privateFixtureRepositoryContract: PrivateFixtureRepositoryContract
    public let privateRepositoryExecutionRecipes: [PrivateRepositoryExecutionRecipe]
    public let componentHarnessRecipes: [ComponentHarnessRecipe]
    public let deterministicLiveEPIPERecipe: DeterministicLiveEPIPERecipe
    public let captureFixtures: [CaptureFixture]
    public let valueDomainFixtures: [ValueDomainFixture]
    public let invocationParserVectors: [InvocationParserVector]
    public let relationOntologyCases: [RelationOntologyCase]
    public let ontologyProofPairs: [OntologyProofPair]
    public let toctouContract: TOCTOUContract
    public let externalClosureRequirement: ExternalClosureRequirement
    public let patchContract: PatchContract
    public let staticSourceContracts: [StaticSourceContract]
    public let authorityCeiling: AuthorityCeiling
    public let exactAuthorizedNextActionIDs: [String]
    public let status: String

    // Bound only after an independent PRE-FREEZE review clears the exact value.
    public static let canonicalByteCount = 467_184
    public static let canonicalSHA256 =
        "ae13d26870b73515bf76018d2f0c1f10d13edf0a59c38857e5767f1abc668a98"
}

private extension PrimeExactRevisionTopologyRelationAmendmentAuthorityV1 {
    static let resultCodes = [
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
    ]

    static func flatGuardMappings() -> [GuardMapping] {
        let values: [(String, String, String)] = [
            ("literal_commit_oid_is_lowercase_40hex", "TOPOLOGY_INVOCATION_INVALID", "every_ordinary_requested_commit_literal"),
            ("expected_topology_oids_are_lowercase_40hex", "TOPOLOGY_INVOCATION_INVALID", "ordinary_expected_tree_and_parent_literals"),
            ("verification_request_count_nonzero", "TOPOLOGY_INVOCATION_INVALID", "ordinary_explicit_request_count"),
            ("verification_request_count_within_bound", "TOPOLOGY_INVOCATION_INVALID", "ordinary_explicit_request_count_at_most_eight"),
            ("repository_argument_is_canonical_absolute_admitted_git_worktree", "TOPOLOGY_INVOCATION_INVALID", "repository_argument"),
            ("request_role_matches_ascii_allowlist_grammar", "TOPOLOGY_INVOCATION_INVALID", "ordinary_explicit_roles"),
            ("request_roles_are_unique", "TOPOLOGY_INVOCATION_INVALID", "ordinary_explicit_roles"),
            ("expected_parent_count_within_bound", "TOPOLOGY_INVOCATION_INVALID", "ordinary_flat_request_shape_and_parent_count"),
            ("fixed_verifier_tools_admitted", "TOPOLOGY_VERIFIER_UNAVAILABLE", "fixed_tools"),
            ("classifier_build_and_self_test_admitted", "TOPOLOGY_VERIFIER_UNAVAILABLE", "one_build_and_existing_self_test"),
            ("repository_object_format_observation_succeeded", "TOPOLOGY_OBSERVATION_FAILED", "repository_storage_format_observation"),
            ("repository_object_format_sha1", "TOPOLOGY_REPOSITORY_UNSUPPORTED", "repository_storage_format"),
            ("object_availability_observation_succeeded", "TOPOLOGY_OBSERVATION_FAILED", "each_requested_object_preprobe"),
            ("required_object_availability", "TOPOLOGY_OBJECT_UNAVAILABLE", "each_requested_object_preprobe"),
            ("object_type_observation_succeeded", "TOPOLOGY_OBSERVATION_FAILED", "each_requested_object_preprobe"),
            ("required_object_type_commit", "TOPOLOGY_OBJECT_NOT_COMMIT", "each_requested_object_preprobe"),
            ("object_size_observation_succeeded", "TOPOLOGY_OBSERVATION_FAILED", "each_requested_object_preprobe"),
            ("object_size_within_bound", "TOPOLOGY_OBJECT_UNSUPPORTED", "each_requested_object_preprobe"),
            ("git_cat_file_transport_succeeded", "TOPOLOGY_OBSERVATION_FAILED", "each_raw_commit_stream"),
            ("classifier_exit_status_known", "TOPOLOGY_OBSERVATION_FAILED", "each_classifier_status"),
            ("classifier_arguments_match_helper_protocol", "TOPOLOGY_OBSERVATION_FAILED", "ordinary_flat_classifier_argv"),
            ("classifier_inherited_file_descriptors_closed", "TOPOLOGY_OBSERVATION_FAILED", "each_classifier_process"),
            ("classifier_stdin_read_succeeded", "TOPOLOGY_OBSERVATION_FAILED", "each_classifier_process"),
            ("classifier_actual_size_within_bound", "TOPOLOGY_OBSERVATION_FAILED", "each_raw_commit_stream"),
            ("classifier_actual_size_equals_advertised_size", "TOPOLOGY_OBSERVATION_FAILED", "each_raw_commit_stream"),
            ("classifier_computed_oid_equals_literal_oid", "TOPOLOGY_OBSERVATION_FAILED", "each_raw_commit_stream"),
            ("classifier_input_is_nul_free", "TOPOLOGY_OBJECT_UNSUPPORTED", "each_raw_commit_stream"),
            ("classifier_parser_internal_state_valid", "TOPOLOGY_OBSERVATION_FAILED", "each_classifier_process"),
            ("header_lines_and_separator_are_well_formed", "TOPOLOGY_HEADER_MALFORMED", "each_commit_header"),
            ("tree_header_is_first_and_unique", "TOPOLOGY_HEADER_MALFORMED", "each_commit_header"),
            ("ordered_parent_headers_are_contiguous", "TOPOLOGY_HEADER_MALFORMED", "each_commit_header"),
            ("topology_header_oids_are_lowercase_40hex", "TOPOLOGY_HEADER_MALFORMED", "each_commit_header"),
            ("signed_header_continuations_are_allowed_and_attached", "TOPOLOGY_HEADER_MALFORMED", "each_commit_header"),
            ("tree_oid_equals_expected", "TOPOLOGY_MISMATCH", "each_ordinary_requested_commit"),
            ("ordered_parent_oids_equal_expected", "TOPOLOGY_MISMATCH", "each_ordinary_requested_commit"),
        ]
        return values.enumerated().map {
            .init(
                phaseOrdinal: $0.offset + 1,
                guardID: $0.element.0,
                resultCode: $0.element.1,
                scope: $0.element.2)
        }
    }

    static func relationGuardMappings() -> [GuardMapping] {
        let flat = flatGuardMappings()
        var values: [GuardMapping] = []
        for mapping in flat.prefix(2) {
            values.append(.init(
                phaseOrdinal: values.count + 1,
                guardID: mapping.guardID,
                resultCode: mapping.resultCode,
                scope: mapping.guardID == "literal_commit_oid_is_lowercase_40hex"
                    ? "ordinary_target_literals_plus_relation_merge_target_literal"
                    : "ordinary_expected_literals_plus_relation_index_tree_and_fixed_parent"))
        }
        values.append(.init(
            phaseOrdinal: 3,
            guardID:
                "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids",
            resultCode: "TOPOLOGY_INVOCATION_INVALID",
            scope:
                "merge_literal_differs_from_fixed_parent_and_every_ordinary_literal_commit_oid_fixed_parent_may_equal_an_ordinary_literal"))
        for mapping in flat[2 ... 20] {
            let scope: String
            switch mapping.guardID {
            case "verification_request_count_within_bound":
                scope = "ordinary_explicit_count_plus_exactly_two_implicit_objects_at_most_eight"
            case "request_role_matches_ascii_allowlist_grammar":
                scope = "ordinary_merge_and_child_roles"
            case "request_roles_are_unique":
                scope = "ordinary_merge_and_child_roles_all_unique"
            case "expected_parent_count_within_bound":
                scope = "ordinary_requests_plus_exact_terminal_suffix_shape"
            case "object_availability_observation_succeeded",
                 "required_object_availability",
                 "object_type_observation_succeeded",
                 "required_object_type_commit",
                 "object_size_observation_succeeded",
                 "object_size_within_bound":
                scope = "wave1_ordinary_and_merge_then_wave2_discovered_child"
            case "classifier_arguments_match_helper_protocol":
                scope = "ordinary_and_relation_exact_argv_only"
            default:
                scope = mapping.scope
            }
            values.append(.init(
                phaseOrdinal: values.count + 1,
                guardID: mapping.guardID,
                resultCode: mapping.resultCode,
                scope: scope))
        }
        values.append(.init(
            phaseOrdinal: 23,
            guardID: "classifier_relation_witness_frame_is_exact",
            resultCode: "TOPOLOGY_OBSERVATION_FAILED",
            scope:
                "relation_only_exact_status_payload_union_terminal_lf_and_private_two_status_trailer"))
        for mapping in flat[21 ... 32] {
            values.append(.init(
                phaseOrdinal: values.count + 1,
                guardID: mapping.guardID,
                resultCode: mapping.resultCode,
                scope: mapping.scope))
        }
        values.append(.init(
            phaseOrdinal: 36,
            guardID:
                "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids",
            resultCode: "TOPOLOGY_MISMATCH",
            scope:
                "safe_parent2_differs_from_merge_fixed_parent_and_every_ordinary_literal_commit_oid_before_child_preprobe"))
        values.append(.init(
            phaseOrdinal: 37,
            guardID: flat[33].guardID,
            resultCode: flat[33].resultCode,
            scope: "independently_applied_to_relation_merge_and_discovered_child_against_index_tree"))
        values.append(.init(
            phaseOrdinal: 38,
            guardID: flat[34].guardID,
            resultCode: flat[34].resultCode,
            scope: "independently_applied_to_merge_expected_fixed_then_child_and_child_expected_sole_fixed"))
        return values
    }

    static func cleanGit(_ suffix: [String]) -> [String] {
        cleanGitAt("<actor_validated_private_root>", suffix)
    }

    static func cleanGitAt(_ rootToken: String, _ suffix: [String]) -> [String] {
        [
            "/usr/bin/env", "-i", "LC_ALL=C",
            "TMPDIR=\(rootToken)",
            "GIT_NO_REPLACE_OBJECTS=1", "GIT_NO_LAZY_FETCH=1",
            "GIT_CONFIG_NOSYSTEM=1", "GIT_CONFIG_GLOBAL=/dev/null",
            "GIT_TERMINAL_PROMPT=0", "GIT_OPTIONAL_LOCKS=0",
            "/usr/bin/git",
        ] + suffix
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

    static func probeCapture(
        _ ordinal: Int,
        _ fixtureID: String,
        _ probeKind: String,
        _ producerStatus: Int,
        _ consumerStatus: Int,
        _ outerStatus: Int,
        _ bodyBase64: String,
        _ bodyByteCount: Int,
        _ bodySHA256: String,
        _ trailerBase64: String,
        _ trailerSHA256: String,
        _ captureBase64: String,
        _ captureByteCount: Int,
        _ captureSHA256: String,
        _ accepted: Bool
    ) -> IndexObservationContract.ProbeCaptureVector {
        .init(
            ordinal: ordinal,
            fixtureID: fixtureID,
            probeKind: probeKind,
            producerStatus: producerStatus,
            consumerStatus: consumerStatus,
            outerSubstitutionStatus: outerStatus,
            bodyBase64: bodyBase64,
            bodyByteCount: bodyByteCount,
            bodySHA256: bodySHA256,
            trailerBase64: trailerBase64,
            trailerByteCount: 22,
            trailerSHA256: trailerSHA256,
            captureBase64: captureBase64,
            captureByteCount: captureByteCount,
            captureSHA256: captureSHA256,
            accepted: accepted,
            expectedExternalAdmissionFailure: !accepted,
            failureValidHelperRecordCount: accepted ? nil : 0)
    }

    static func gateRootCapture(
        _ ordinal: Int,
        _ fixtureID: String,
        _ probeKind: String,
        _ producerStatus: Int,
        _ consumerStatus: Int,
        _ outerStatus: Int,
        _ bodyBase64: String,
        _ bodyByteCount: Int,
        _ bodySHA256: String,
        _ trailerBase64: String,
        _ trailerSHA256: String,
        _ captureBase64: String,
        _ captureByteCount: Int,
        _ captureSHA256: String,
        _ accepted: Bool
    ) -> GatePrivateRootContract.CaptureVector {
        .init(
            ordinal: ordinal,
            fixtureID: fixtureID,
            constructionKind: "pure_framed_capture_parser_injection",
            publicGateOrToolInvocationCount: 0,
            futurePrivateMatrixRequired: true,
            probeKind: probeKind,
            producerStatus: producerStatus,
            consumerStatus: consumerStatus,
            outerSubstitutionStatus: outerStatus,
            bodyBase64: bodyBase64,
            bodyByteCount: bodyByteCount,
            bodySHA256: bodySHA256,
            trailerBase64: trailerBase64,
            trailerByteCount: 22,
            trailerSHA256: trailerSHA256,
            captureBase64: captureBase64,
            captureByteCount: captureByteCount,
            captureSHA256: captureSHA256,
            accepted: accepted,
            expectedSanitizedClassification:
                accepted ? "accepted" : "external_failure",
            expectedParsedValue: accepted
                ? (probeKind == "mktemp_path"
                    ? "/private/tmp/prime-topology-gate.A1b2C3d4"
                    : "501:40700:Directory")
                : "")
    }

    static func object(
        _ ordinal: Int,
        _ fixtureID: String,
        _ objectType: String,
        _ byteCount: Int,
        _ sha256: String,
        _ oid: String,
        _ tree: String?,
        _ parents: [String],
        _ structurallyValid: Bool?,
        _ disposition: String,
        _ base64: String
    ) -> SyntheticGitObjectFixture {
        let present = disposition == "write_to_destination_object_database"
        return .init(
            ordinal: ordinal,
            fixtureID: fixtureID,
            objectType: objectType,
            payloadEncoding: "base64_exact_bytes",
            payloadBase64: base64,
            payloadByteCount: byteCount,
            payloadSHA256: sha256,
            literalObjectOID: oid,
            parsedTreeOID: tree,
            parsedOrderedParentOIDs: parents,
            structurallyValidHeader: structurallyValid,
            destinationDisposition: disposition,
            expectedDestinationInventoryPresent: present,
            expectedPreprobeAvailability: present ? "present" : "missing",
            literalOIDRecomputedAndRequiredEqualBeforeUse: true,
            noNetwork: true)
    }

    static func exactObjectFixtures() -> [SyntheticGitObjectFixture] {
        let emptyTree = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
        let alternateTree = "a8b941f979c6752d954e44f12986dcda9dd54417"
        let fixed = "78625e93e79913269c43412b20cd360f42b53534"
        let unrelated = "2bd406f9651e236af795d8dfe65af46287e6653d"
        let child = "b31a7a047572316879d5f6ba7f50ccb027b29d40"
        let wrongTreeChild = "0ebc659e50c91a0bf86f7a984242427ab62ecd3e"
        let wrongParentChild = "c632c1eda2ff47b01038ff1bc8da1e29faa3a56b"
        let withheldChild = "b23f7f9cf8fe40a00e95d1b5eb3e20366ef271d6"
        let write = "write_to_destination_object_database"
        let withhold =
            "intentionally_withheld_from_destination_object_database"
        return [
            object(
                1, "empty_tree", "tree", 0,
                "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                emptyTree, nil, [], nil, write, ""),
            object(
                2, "alternate_tree", "tree", 35,
                "730d6d4c39ebf7133ee4e278015c07fd1c622f076a062dfee07a59cba42e2e8a",
                alternateTree, nil, [], nil, write,
                "MTAwNjQ0IGZpeHR1cmUA7owe5JtHmbvRcCM5FaiXwZ47VeE="),
            object(
                3, "fixed_parent", "commit", 161,
                "37278718cbb625057a1ba03ec6a4494a38c70dd8a34773439aeb8bc051e405f0",
                fixed, emptyTree, [], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmZpeGVkIHBhcmVudAo="),
            object(
                4, "unrelated", "commit", 158,
                "f9ea564f1cd206fc34b0c6bcebcc989e27990c9bc4e02d79452bd4e7408988df",
                unrelated, emptyTree, [], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnVucmVsYXRlZAo="),
            object(
                5, "valid_child", "commit", 208,
                "741ef6c39ad69e236ec087f36d4f5f01cf785dfd11e9457ce3c39a2e62dd293e",
                child, emptyTree, [fixed], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnZhbGlkIGNoaWxkCg=="),
            object(
                6, "valid_relation_merge", "commit", 265,
                "1f97d6b08c287ba77fea701eac012bea9b8f3dbe78df8ec78493beef3f16b7d6",
                "71f8a1d0c9fcdb628ddd23f12e30393ffec514a5", emptyTree,
                [fixed, child], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBiMzFhN2EwNDc1NzIzMTY4NzlkNWY2YmE3ZjUwY2NiMDI3YjI5ZDQwCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnZhbGlkIHJlbGF0aW9uIG1lcmdlCg=="),
            object(
                7, "wrong_tree_child", "commit", 213,
                "b19be123e0cce851597f9f365451dcd2905c5f2016232f0252770b7a70e9578d",
                wrongTreeChild, alternateTree, [fixed], true, write,
                "dHJlZSBhOGI5NDFmOTc5YzY3NTJkOTU0ZTQ0ZjEyOTg2ZGNkYTlkZDU0NDE3CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIHRyZWUgY2hpbGQK"),
            object(
                8, "wrong_tree_child_merge", "commit", 267,
                "ec0e223067cc6b6a6d684c6d2842772825154bf13e35b4884b1b708305bc999d",
                "2eafec5b40e2dc2cf6e3fb478e56fdc760d53b25", emptyTree,
                [fixed, wrongTreeChild], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCAwZWJjNjU5ZTUwYzkxYTBiZjg2ZjdhOTg0MjQyNDI3YWI2MmVjZDNlCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIHRyZWUgY2hpbGQgbWVyZ2UK"),
            object(
                9, "wrong_tree_relation_merge", "commit", 270,
                "dd6458ecd5607627f16cb6059b89a23807a71b7bc1d9cedb950683a1c5aabad3",
                "2fef805750d29ef31cde54133d50300e1b96496e", alternateTree,
                [fixed, child], true, write,
                "dHJlZSBhOGI5NDFmOTc5YzY3NTJkOTU0ZTQ0ZjEyOTg2ZGNkYTlkZDU0NDE3CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBiMzFhN2EwNDc1NzIzMTY4NzlkNWY2YmE3ZjUwY2NiMDI3YjI5ZDQwCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIHRyZWUgcmVsYXRpb24gbWVyZ2UK"),
            object(
                10, "wrong_parent_child", "commit", 215,
                "09be27915b28e1976dc8dbeca5756780f6ea746fb12f88d717675d9ed95551cb",
                wrongParentChild, emptyTree, [unrelated], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCAyYmQ0MDZmOTY1MWUyMzZhZjc5NWQ4ZGZlNjVhZjQ2Mjg3ZTY2NTNkCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIHBhcmVudCBjaGlsZAo="),
            object(
                11, "wrong_parent_child_merge", "commit", 269,
                "624ff928a6669debfc9e72e96506f87485a4a2f1eeaa25ece5cb523f9530c3f8",
                "e4bea13761e5bb9dc4fe2bc341673945615add75", emptyTree,
                [fixed, wrongParentChild], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBjNjMyYzFlZGEyZmY0N2IwMTAzOGZmMWJjOGRhMWUyOWZhYTNhNTZiCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIHBhcmVudCBjaGlsZCBtZXJnZQo="),
            object(
                12, "wrong_first_parent_relation_merge", "commit", 278,
                "cdb2600829cf79e9efa767a2127bd6e69ae3c382708905aec977902a7c223c68",
                "c70c267a263aa4ab3d7f42d1f55fcb8deca18f53", emptyTree,
                [unrelated, child], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCAyYmQ0MDZmOTY1MWUyMzZhZjc5NWQ4ZGZlNjVhZjQ2Mjg3ZTY2NTNkCnBhcmVudCBiMzFhN2EwNDc1NzIzMTY4NzlkNWY2YmE3ZjUwY2NiMDI3YjI5ZDQwCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIGZpcnN0IHBhcmVudCByZWxhdGlvbiBtZXJnZQo="),
            object(
                13, "three_parent_relation_merge", "commit", 320,
                "6b8c76d2d1a91d5ec000b43123365fa7936e9685b6b0c496eb878f4a23a192c7",
                "536d17a40b327ba607413daddfeea5fc7c178a0a", emptyTree,
                [fixed, child, unrelated], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBiMzFhN2EwNDc1NzIzMTY4NzlkNWY2YmE3ZjUwY2NiMDI3YjI5ZDQwCnBhcmVudCAyYmQ0MDZmOTY1MWUyMzZhZjc5NWQ4ZGZlNjVhZjQ2Mjg3ZTY2NTNkCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnRocmVlIHBhcmVudCByZWxhdGlvbiBtZXJnZQo="),
            object(
                14, "duplicate_fixed_parent_relation_merge", "commit", 282,
                "74b352bc65e52b7bd66e5c14052b5890263b3946b9b12c42f6119c32e5cf916d",
                "ba5f7eac164462e97cffd8d97e128caa50c19a6b", emptyTree,
                [fixed, fixed], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmR1cGxpY2F0ZSBmaXhlZCBwYXJlbnQgcmVsYXRpb24gbWVyZ2UK"),
            object(
                15, "withheld_child", "commit", 211,
                "9c375740190cebc7e493382923e7d4259edba07c27cd03bfe578c66ee4254277",
                withheldChild, emptyTree, [fixed], true, withhold,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndpdGhoZWxkIGNoaWxkCg=="),
            object(
                16, "missing_child_relation_merge", "commit", 273,
                "dfb04fe5b32579494da04f2c13350d63142ee5e8ee3222c37ebd880515d85e9f",
                "b715fc40d4a8f014e2ad0494289ff57b45e5b361", emptyTree,
                [fixed, withheldChild], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBiMjNmN2Y5Y2Y4ZmU0MGEwMGU5NWQxYjVlYjNlMjAzNjZlZjI3MWQ2CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm1pc3NpbmcgY2hpbGQgcmVsYXRpb24gbWVyZ2UK"),
            object(
                17, "malformed_relation_merge", "commit", 269,
                "acc905507547af2cb411292aff55eebad4a9fa93099f6fd156ba3ca96ab07a1a",
                "4265d3c61b14a1af7fe6b90e5d17b3c710824c0d", emptyTree,
                [fixed, child], false, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApwYXJlbnQgYjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm1hbGZvcm1lZCByZWxhdGlvbiBtZXJnZQo="),
            object(
                18, "noncommit_child_relation_merge", "commit", 275,
                "ca7041733e1d1193e503fc659aba4d51a43717ed8da58695121a2ccffa3e6f1c",
                "e906212a3fd3d6d7c44cd02213b9b507062d3bc2", emptyTree,
                [fixed, emptyTree], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm5vbmNvbW1pdCBjaGlsZCByZWxhdGlvbiBtZXJnZQo="),
            object(
                19, "signed_relation_merge", "commit", 315,
                "8a1ed62d853b740dd8e223c37adbecaead35511feb194e33fbdc74a8e8307ed6",
                "7366eebc97348eea7849f79d5d6a175d07dc5c84", emptyTree,
                [fixed, child], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBiMzFhN2EwNDc1NzIzMTY4NzlkNWY2YmE3ZjUwY2NiMDI3YjI5ZDQwCmdwZ3NpZyAtLS0tLUJFR0lOIFNJR05BVFVSRS0tLS0tCiBjb250aW51YXRpb24KIAphdXRob3IgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKY29tbWl0dGVyIEZpeHR1cmUgPGZpeHR1cmVAZXhhbXBsZS5pbnZhbGlkPiAwICswMDAwCgpzaWduZWQgcmVsYXRpb24gbWVyZ2UK"),
            object(
                20, "present_noncommit_blob", "blob", 8,
                "e80b71cd14d3cbd65f4173abcbfcf01a545dbca32a72d575108b553a648cc96f",
                "ee8c1ee49b4799bbd170233915a897c19e3b55e1", nil, [], nil, write,
                "Zml4dHVyZQo="),
            object(
                21, "blob_child_relation_merge", "commit", 270,
                "4ae694f74b2b3b9d5866423c7ba1d8bddaa5157f4b4b8250c5bbd8e35ed19fc2",
                "d77f233ef96abdecf567cad5c5a9256b50a9aa1c", emptyTree,
                [fixed, "ee8c1ee49b4799bbd170233915a897c19e3b55e1"], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBlZThjMWVlNDliNDc5OWJiZDE3MDIzMzkxNWE4OTdjMTllM2I1NWUxCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCmJsb2IgY2hpbGQgcmVsYXRpb24gbWVyZ2UK"),
            object(
                22, "orphan_continuation_relation_merge", "commit", 300,
                "81ad50cc0844664b7eb68f7cc12c4c6adebf324161630dd6ffc92c2c900e7978",
                "8abb4062359a1421987cc5cbb1da62d0f9a1af06", emptyTree,
                [fixed, child], false, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBiMzFhN2EwNDc1NzIzMTY4NzlkNWY2YmE3ZjUwY2NiMDI3YjI5ZDQwCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMAogb3JwaGFuLWNvbnRpbnVhdGlvbgpjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCm9ycGhhbiBjb250aW51YXRpb24gcmVsYXRpb24gbWVyZ2UK"),
            object(
                23, "wrong_tree_missing_child_relation_merge", "commit", 284,
                "09b0b3a7898bc674de3f43dc964ef33f3712a2aa58e16dcc504f6bf0dc23bb3b",
                "a3a12f4f13d885f409e27ce85d8b0c4681199a9f", alternateTree,
                [fixed, withheldChild], true, write,
                "dHJlZSBhOGI5NDFmOTc5YzY3NTJkOTU0ZTQ0ZjEyOTg2ZGNkYTlkZDU0NDE3CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBiMjNmN2Y5Y2Y4ZmU0MGEwMGU5NWQxYjVlYjNlMjAzNjZlZjI3MWQ2CmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCndyb25nIHRyZWUgbWlzc2luZyBjaGlsZCByZWxhdGlvbiBtZXJnZQo="),
            object(
                24, "three_parent_blob_child_relation_merge", "commit", 331,
                "b4c52127c6d2089150fa597f7b158c3b862eef3caac3424dfc933385d152617f",
                "7e4a5ecfe0b22a01df9b89476faeec33c6b53830", emptyTree,
                [fixed, "ee8c1ee49b4799bbd170233915a897c19e3b55e1", unrelated], true, write,
                "dHJlZSA0YjgyNWRjNjQyY2I2ZWI5YTA2MGU1NGJmOGQ2OTI4OGZiZWU0OTA0CnBhcmVudCA3ODYyNWU5M2U3OTkxMzI2OWM0MzQxMmIyMGNkMzYwZjQyYjUzNTM0CnBhcmVudCBlZThjMWVlNDliNDc5OWJiZDE3MDIzMzkxNWE4OTdjMTllM2I1NWUxCnBhcmVudCAyYmQ0MDZmOTY1MWUyMzZhZjc5NWQ4ZGZlNjVhZjQ2Mjg3ZTY2NTNkCmF1dGhvciBGaXh0dXJlIDxmaXh0dXJlQGV4YW1wbGUuaW52YWxpZD4gMCArMDAwMApjb21taXR0ZXIgRml4dHVyZSA8Zml4dHVyZUBleGFtcGxlLmludmFsaWQ+IDAgKzAwMDAKCnRocmVlIHBhcmVudCBibG9iIGNoaWxkIHJlbGF0aW9uIG1lcmdlCg=="),
        ]
    }

    static func capture(
        _ ordinal: Int,
        _ fixtureID: String,
        _ mode: String,
        _ gitStatus: Int,
        _ classifierStatus: Int,
        _ bodyByteCount: Int,
        _ bodySHA256: String,
        _ bodyBase64: String,
        _ trailerSHA256: String,
        _ trailerBase64: String,
        _ captureByteCount: Int,
        _ captureSHA256: String,
        _ captureBase64: String,
        _ pairAdmitted: Bool,
        _ bodyConsumed: Bool,
        _ result: String,
        _ guardID: String?
    ) -> CaptureFixture {
        .init(
            ordinal: ordinal,
            fixtureID: fixtureID,
            mode: mode,
            gitStatus: gitStatus,
            classifierStatus: classifierStatus,
            bodyBase64: bodyBase64,
            bodyByteCount: bodyByteCount,
            bodySHA256: bodySHA256,
            trailerBase64: trailerBase64,
            trailerByteCount: 22,
            trailerSHA256: trailerSHA256,
            captureBase64: captureBase64,
            captureByteCount: captureByteCount,
            captureSHA256: captureSHA256,
            statusPayloadPairAdmitted: pairAdmitted,
            bodyConsumedAsChildOID: bodyConsumed,
            expectedResultCode: result,
            expectedFirstFailedGuardID: guardID)
    }

    static func exactCaptureFixtures() -> [CaptureFixture] {
        let emptySHA =
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        let witnessSHA =
            "f3c4d3a8c94a2998fab4c4624dc0d5e038b93c48d4133ef2f1261cb9ef86c1b5"
        let witness =
            "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAo="
        return [
            capture(1, "relation_success_exact_witness", "relation", 0, 0, 41, witnessSHA, witness,
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==", 63,
                "2afc3de151751525db114679c0a6fa4477675ad5d4c5f3b27ebbd47c73b9f5dd", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVzOjAwMDowMDAf",
                true, true, "TOPOLOGY_VERIFIED", nil),
            capture(2, "relation_tree_mismatch_deferred", "relation", 0, 41, 41, witnessSHA, witness,
                "c83e2b8a23d93a07be8e19ad2af5f98f1d51fdc7a4d3f815f40647f06f68d81d", "HnByaW1lX3N0YXR1czowMDA6MDQxHw==", 63,
                "b5cf6a8d593675e5fea6018386865d6c8cc6aaaba5fcf80ad09ec4eee82b7b77", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVzOjAwMDowNDEf",
                true, true, "TOPOLOGY_MISMATCH", "tree_oid_equals_expected"),
            capture(3, "relation_parent_mismatch_deferred", "relation", 0, 42, 41, witnessSHA, witness,
                "35ee61e011350b5e6cc8997a7e9c94904eb3237347613f4d14fdc553dc31ef57", "HnByaW1lX3N0YXR1czowMDA6MDQyHw==", 63,
                "36ad74166092518deb008a366742f0507f02cbb7eff20e94b6c7109428f5e225", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVzOjAwMDowNDIf",
                true, true, "TOPOLOGY_MISMATCH", "ordered_parent_oids_equal_expected"),
            capture(4, "relation_zero_or_one_parent_terminal", "relation", 0, 42, 0, emptySHA, "",
                "35ee61e011350b5e6cc8997a7e9c94904eb3237347613f4d14fdc553dc31ef57", "HnByaW1lX3N0YXR1czowMDA6MDQyHw==", 22,
                "35ee61e011350b5e6cc8997a7e9c94904eb3237347613f4d14fdc553dc31ef57", "HnByaW1lX3N0YXR1czowMDA6MDQyHw==",
                true, false, "TOPOLOGY_MISMATCH", "ordered_parent_oids_equal_expected"),
            capture(5, "relation_exit28_empty_prefix", "relation", 0, 28, 0, emptySHA, "",
                "427857f84ba48f337ec23d250a57034a9a630cf6eb2cdab0885a2e3f10dda750", "HnByaW1lX3N0YXR1czowMDA6MDI4Hw==", 22,
                "427857f84ba48f337ec23d250a57034a9a630cf6eb2cdab0885a2e3f10dda750", "HnByaW1lX3N0YXR1czowMDA6MDI4Hw==",
                true, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(6, "relation_exit28_one_byte_prefix", "relation", 0, 28, 1,
                "3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d", "Yg==",
                "427857f84ba48f337ec23d250a57034a9a630cf6eb2cdab0885a2e3f10dda750", "HnByaW1lX3N0YXR1czowMDA6MDI4Hw==", 23,
                "d0ef392a8e5d07d3a34bd63e132e0f4570c144e863c3a949ca5b7c823f27948b", "Yh5wcmltZV9zdGF0dXM6MDAwOjAyOB8=",
                true, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(7, "relation_exit28_forty_byte_prefix", "relation", 0, 28, 40,
                "c0453f36abca09043b6576773cee0fe730544760998d73b79471ab02e68f3d24", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MA==",
                "427857f84ba48f337ec23d250a57034a9a630cf6eb2cdab0885a2e3f10dda750", "HnByaW1lX3N0YXR1czowMDA6MDI4Hw==", 62,
                "6a6e690fdd993da8124a76bd4ca9caf949442d9699079c2fd565272264b4195c", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MB5wcmltZV9zdGF0dXM6MDAwOjAyOB8=",
                true, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(8, "relation_structural_failure_zero_body", "relation", 0, 32, 0, emptySHA, "",
                "c42d928c09235565d83a6653a08f48c3d1356104b52cd7746b1d8044d91e8d7d", "HnByaW1lX3N0YXR1czowMDA6MDMyHw==", 22,
                "c42d928c09235565d83a6653a08f48c3d1356104b52cd7746b1d8044d91e8d7d", "HnByaW1lX3N0YXR1czowMDA6MDMyHw==",
                true, false, "TOPOLOGY_HEADER_MALFORMED", "ordered_parent_headers_are_contiguous"),
            capture(9, "relation_exit28_full_witness_rejected", "relation", 0, 28, 41, witnessSHA, witness,
                "427857f84ba48f337ec23d250a57034a9a630cf6eb2cdab0885a2e3f10dda750", "HnByaW1lX3N0YXR1czowMDA6MDI4Hw==", 63,
                "430220ae9df03d1539e0f6fb225bd8afccc4304ff3af80127a80c90e5f756598", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVzOjAwMDowMjgf",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(10, "relation_success_empty_body_rejected", "relation", 0, 0, 0, emptySHA, "",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==", 22,
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(11, "relation_success_uppercase_body_rejected", "relation", 0, 0, 41,
                "38ffde5c044ed3daad719b453f3e1ca2e85c5f717b392ce4612f864f33327a18", "QjMxQTdBMDQ3NTcyMzE2ODc5RDVGNkJBN0Y1MENDQjAyN0IyOUQ0MAo=",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==", 63,
                "b3a38f99ec01a65a47342fb19acfc4ec5f64224eb72bee900ec4c10b9fdf1841", "QjMxQTdBMDQ3NTcyMzE2ODc5RDVGNkJBN0Y1MENDQjAyN0IyOUQ0MAoecHJpbWVfc3RhdHVzOjAwMDowMDAf",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(12, "relation_tree_missing_lf_rejected", "relation", 0, 41, 40,
                "c0453f36abca09043b6576773cee0fe730544760998d73b79471ab02e68f3d24", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MA==",
                "c83e2b8a23d93a07be8e19ad2af5f98f1d51fdc7a4d3f815f40647f06f68d81d", "HnByaW1lX3N0YXR1czowMDA6MDQxHw==", 62,
                "92e27050359c7cc1c72d2c824f7f1b8698234ec27eee3d0f8442935c92936db6", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MB5wcmltZV9zdGF0dXM6MDAwOjA0MR8=",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(13, "relation_parent_double_lf_rejected", "relation", 0, 42, 42,
                "00d25a5f65bd117183400f0940cb563c5f91c4f0b70fe2ee7b25631afe0f7393", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoK",
                "35ee61e011350b5e6cc8997a7e9c94904eb3237347613f4d14fdc553dc31ef57", "HnByaW1lX3N0YXR1czowMDA6MDQyHw==", 64,
                "9bfcb3af270d8cfbc2e0707eaafda53ee7880f8830059698c5be54f442a3969b", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoKHnByaW1lX3N0YXR1czowMDA6MDQyHw==",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(14, "relation_structural_failure_body_rejected", "relation", 0, 32, 41, witnessSHA, witness,
                "c42d928c09235565d83a6653a08f48c3d1356104b52cd7746b1d8044d91e8d7d", "HnByaW1lX3N0YXR1czowMDA6MDMyHw==", 63,
                "e5b4626de0d1fb415685c91b7a396a4730d6a1709d430daba72d6df5a9c7df6e", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVzOjAwMDowMzIf",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(15, "relation_git_failure_precedes_classifier", "relation", 1, 32, 0, emptySHA, "",
                "afe56030d1735b469d5e41e6a61b725c3b87d394b2ccc8c051818251a8e28098", "HnByaW1lX3N0YXR1czowMDE6MDMyHw==", 22,
                "afe56030d1735b469d5e41e6a61b725c3b87d394b2ccc8c051818251a8e28098", "HnByaW1lX3N0YXR1czowMDE6MDMyHw==",
                true, false, "TOPOLOGY_OBSERVATION_FAILED", "git_cat_file_transport_succeeded"),
            capture(16, "ordinary_success_zero_body", "ordinary", 0, 0, 0, emptySHA, "",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==", 22,
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                true, false, "TOPOLOGY_VERIFIED", nil),
            capture(17, "ordinary_tree_mismatch_zero_body", "ordinary", 0, 41, 0, emptySHA, "",
                "c83e2b8a23d93a07be8e19ad2af5f98f1d51fdc7a4d3f815f40647f06f68d81d", "HnByaW1lX3N0YXR1czowMDA6MDQxHw==", 22,
                "c83e2b8a23d93a07be8e19ad2af5f98f1d51fdc7a4d3f815f40647f06f68d81d", "HnByaW1lX3N0YXR1czowMDA6MDQxHw==",
                true, false, "TOPOLOGY_MISMATCH", "tree_oid_equals_expected"),
            capture(18, "ordinary_nonzero_body_rejected", "ordinary", 0, 0, 41, witnessSHA, witness,
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==", 63,
                "2afc3de151751525db114679c0a6fa4477675ad5d4c5f3b27ebbd47c73b9f5dd", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVzOjAwMDowMDAf",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_arguments_match_helper_protocol"),
            capture(19, "relation_tree_mismatch_without_parent2", "relation", 0, 41, 0, emptySHA, "",
                "c83e2b8a23d93a07be8e19ad2af5f98f1d51fdc7a4d3f815f40647f06f68d81d", "HnByaW1lX3N0YXR1czowMDA6MDQxHw==", 22,
                "c83e2b8a23d93a07be8e19ad2af5f98f1d51fdc7a4d3f815f40647f06f68d81d", "HnByaW1lX3N0YXR1czowMDA6MDQxHw==",
                true, false, "TOPOLOGY_MISMATCH", "tree_oid_equals_expected"),
            capture(20, "relation_unknown_classifier_status_exact_trailer", "relation", 0, 29, 0, emptySHA, "",
                "6230d374703510c7af161335b8709c7e2d7c836c0767f2527ee5caecae86267a", "HnByaW1lX3N0YXR1czowMDA6MDI5Hw==", 22,
                "6230d374703510c7af161335b8709c7e2d7c836c0767f2527ee5caecae86267a", "HnByaW1lX3N0YXR1czowMDA6MDI5Hw==",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_exit_status_known"),
            capture(21, "relation_malformed_trailer_magic", "relation", 0, 0, 0, emptySHA, "",
                "3f3cb30cb51216f8ea28200d5ccd82f7256996017827a9ba97d5fc9eaa8f02d1", "HnByaW1lX3N0YXR1WDowMDA6MDAwHw==", 22,
                "3f3cb30cb51216f8ea28200d5ccd82f7256996017827a9ba97d5fc9eaa8f02d1", "HnByaW1lX3N0YXR1WDowMDA6MDAwHw==",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(22, "relation_orphan_continuation_status34", "relation", 0, 34, 0, emptySHA, "",
                "342f3cf8fa06fd9357d6886821781ae2eb63715e367ac44652c4caedc8a3fbb9", "HnByaW1lX3N0YXR1czowMDA6MDM0Hw==", 22,
                "342f3cf8fa06fd9357d6886821781ae2eb63715e367ac44652c4caedc8a3fbb9", "HnByaW1lX3N0YXR1czowMDA6MDM0Hw==",
                true, false, "TOPOLOGY_HEADER_MALFORMED", "signed_header_continuations_are_allowed_and_attached"),
            capture(23, "relation_duplicate_fixed_parent_exact_witness", "relation", 0, 0, 41,
                "ca1707f3876e4349bdc0e908e8d1991cef85f75e9521808ebd69f8d4a8f93ca7", "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAo=",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==", 63,
                "9ec2270a08fdabdb1e5d0c15852aae87250d7e54faec56b1bc801993d67ffcc2", "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAoecHJpbWVfc3RhdHVzOjAwMDowMDAf",
                true, true, "TOPOLOGY_MISMATCH", "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids"),
            capture(24, "relation_wrong_tree_withheld_child_witness", "relation", 0, 41, 41,
                "4f6168f510e6189f53b3fbac24618081878ed46b3c18d019c1107ca48262e0db", "YjIzZjdmOWNmOGZlNDBhMDBlOTVkMWI1ZWIzZTIwMzY2ZWYyNzFkNgo=",
                "c83e2b8a23d93a07be8e19ad2af5f98f1d51fdc7a4d3f815f40647f06f68d81d", "HnByaW1lX3N0YXR1czowMDA6MDQxHw==", 63,
                "fc66a5d4df7cfd35ca2641a3f45cceafce017765807aedbb663c96918b766358", "YjIzZjdmOWNmOGZlNDBhMDBlOTVkMWI1ZWIzZTIwMzY2ZWYyNzFkNgoecHJpbWVfc3RhdHVzOjAwMDowNDEf",
                true, true, "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability"),
            capture(25, "relation_three_parent_blob_child_witness", "relation", 0, 42, 41,
                "e0e408c5e0bc2a77f39d6fa6c9715cccf107eb39fb2ef654f9ff838a67d5bd5e", "ZWU4YzFlZTQ5YjQ3OTliYmQxNzAyMzM5MTVhODk3YzE5ZTNiNTVlMQo=",
                "35ee61e011350b5e6cc8997a7e9c94904eb3237347613f4d14fdc553dc31ef57", "HnByaW1lX3N0YXR1czowMDA6MDQyHw==", 63,
                "fcf9506aa55a975056f4bdcbb16a4ac60aa0b3fb7fae97646a2c1834d4384d0a", "ZWU4YzFlZTQ5YjQ3OTliYmQxNzAyMzM5MTVhODk3YzE5ZTNiNTVlMQoecHJpbWVfc3RhdHVzOjAwMDowNDIf",
                true, true, "TOPOLOGY_OBJECT_NOT_COMMIT", "required_object_type_commit"),
            capture(26, "relation_git_failure_with_valid_witness_not_consumed", "relation", 1, 0, 41,
                witnessSHA, witness,
                "0899433b330bcf623102c1324b4f0737edb5dcbffa29165e97b46c557e9010fe", "HnByaW1lX3N0YXR1czowMDE6MDAwHw==", 63,
                "ad4650d2e79c543f58f0ecd01423178c27615e7df5c1270c6f3096f18f37d445", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVzOjAwMTowMDAf",
                true, false, "TOPOLOGY_OBSERVATION_FAILED", "git_cat_file_transport_succeeded"),
            capture(27, "relation_unknown_status_with_valid_witness_not_consumed", "relation", 0, 29, 41,
                witnessSHA, witness,
                "6230d374703510c7af161335b8709c7e2d7c836c0767f2527ee5caecae86267a", "HnByaW1lX3N0YXR1czowMDA6MDI5Hw==", 63,
                "88f45089956a074b1140d81b42f82e1bee43dca5273c0119603bae7929619654", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVzOjAwMDowMjkf",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_exit_status_known"),
            capture(28, "relation_malformed_trailer_with_valid_witness_not_consumed", "relation", 0, 0, 41,
                witnessSHA, witness,
                "3f3cb30cb51216f8ea28200d5ccd82f7256996017827a9ba97d5fc9eaa8f02d1", "HnByaW1lX3N0YXR1WDowMDA6MDAwHw==", 63,
                "a71d03fb8a53ab835930c75bab2b7bd6d2ba976a2ba0c97d9cc514c6c5f3489d", "YjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MAoecHJpbWVfc3RhdHVYOjAwMDowMDAf",
                false, false, "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact"),
            capture(29, "relation_success_withheld_child_witness", "relation", 0, 0, 41,
                "4f6168f510e6189f53b3fbac24618081878ed46b3c18d019c1107ca48262e0db", "YjIzZjdmOWNmOGZlNDBhMDBlOTVkMWI1ZWIzZTIwMzY2ZWYyNzFkNgo=",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", "HnByaW1lX3N0YXR1czowMDA6MDAwHw==", 63,
                "5d0bd30db3b76ca96af972464f6f00ad03db7b1ac6fbbe33544f6f13b02f87e9", "YjIzZjdmOWNmOGZlNDBhMDBlOTVkMWI1ZWIzZTIwMzY2ZWYyNzFkNgoecHJpbWVfc3RhdHVzOjAwMDowMDAf",
                true, true, "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability"),
            capture(30, "ordinary_git_transport_failure_zero_body", "ordinary", 1, 0, 0,
                emptySHA, "",
                "0899433b330bcf623102c1324b4f0737edb5dcbffa29165e97b46c557e9010fe", "HnByaW1lX3N0YXR1czowMDE6MDAwHw==", 22,
                "0899433b330bcf623102c1324b4f0737edb5dcbffa29165e97b46c557e9010fe", "HnByaW1lX3N0YXR1czowMDE6MDAwHw==",
                true, false, "TOPOLOGY_OBSERVATION_FAILED", "git_cat_file_transport_succeeded"),
        ]
    }

    static func ontologyInvocationRecipe(
        caseID: String,
        executionKind: String,
        eventKind: String,
        explicitFixtureIDs: [String],
        mergeFixtureID: String?,
        childFixtureID: String?,
        captureFixtureID: String?,
        valueFixtureID: String?,
        currentIndexMarkerOccurrenceCount: Int,
        relationSuffixOccurrenceCount: Int
    ) -> RelationOntologyCase.InvocationRecipe {
        let objectByID = Dictionary(
            uniqueKeysWithValues: exactObjectFixtures().map { ($0.fixtureID, $0) }
        )
        let repository = "<private_repository>"
        let fixed = objectByID["fixed_parent"]!.literalObjectOID
        let indexTree = objectByID["empty_tree"]!.literalObjectOID
        var arguments = [repository, String(explicitFixtureIDs.count)]
        for (offset, fixtureID) in explicitFixtureIDs.enumerated() {
            let fixture = objectByID[fixtureID]!
            let role: String
            if caseID == "relation_role_collision_rejected_before_git" {
                role = "current_exact_revision"
            } else if (eventKind == "pull_request" && offset == 0)
                || [
                    "legacy_flat_nonHEAD_dirty_repository_remains_legacy",
                    "current_index_marker_nonHEAD_dirty_repository_rejected",
                ].contains(caseID)
            {
                role = "current_exact_revision"
            } else {
                role = "requested_object_\(offset + 1)"
            }
            let expectedParents = (eventKind == "pull_request" && offset == 0)
                || caseID
                    == "relation_explicit_wrong_parent_rejected_after_complete_collection"
                ? [fixed]
                : fixture.parsedOrderedParentOIDs
            arguments += [
                role,
                fixture.literalObjectOID,
                indexTree,
                String(expectedParents.count),
            ] + expectedParents
        }

        for _ in 0 ..< currentIndexMarkerOccurrenceCount {
            arguments.append("--current-index-exact-revision")
        }
        if caseID == "current_index_marker_surplus_rejected" {
            arguments.append("surplus_token")
        }
        if relationSuffixOccurrenceCount > 0 {
            let mergeOID: String
            if let mergeFixtureID {
                mergeOID = objectByID[mergeFixtureID]!.literalObjectOID
            } else if caseID == "merge_equals_fixed_rejected_before_git" {
                mergeOID = fixed
            } else if caseID == "merge_equals_explicit_rejected_before_git" {
                mergeOID = objectByID[explicitFixtureIDs[0]]!.literalObjectOID
            } else {
                mergeOID = objectByID["valid_relation_merge"]!.literalObjectOID
            }
            let mergeRole = caseID
                == "alternate_valid_merge_role_missing_is_selected"
                ? "alternate_merge_role" : "current_exact_revision"
            let childRole = caseID
                == "alternate_valid_child_role_missing_is_projected"
                ? "alternate_child_role" : "current_reviewed_child"
            for _ in 0 ..< relationSuffixOccurrenceCount {
                arguments += [
                    "--ordered-merge-child-relation",
                    mergeRole,
                    mergeOID,
                    indexTree,
                    fixed,
                    childRole,
                ]
            }
        }

        let pureInvocationHook = ["pure_value_domain", "pure_invocation"]
            .contains(executionKind)
        let directPureHook = executionKind == "direct_helper_parser_fixture"
            || executionKind == "direct_component_harness"
            || caseID
            == "discovered_child_equal_merge_rejected_truthfully"
            || executionKind == "pure_capture"
            || pureInvocationHook
        let privateComponentHarness = executionKind
            == "private_repository_with_transport_injection"
        let gateRejectsBeforeHelper = caseID
            == "workflow_dispatch_terminates_before_relation_call"
        let externalState: [String]
        switch caseID {
        case "wave2_phase15_outweighs_earlier_explicit_raw_failure":
            externalState = [
                "transport_hook:ordinary_explicit_ordinal1_git_cat_file_status001_classifier_status000_body0",
                "merge_relation_stream:execute_exact_raw_fixture_and_capture_safe_parent2",
                "wave2_child_preprobe:execute_exact_withheld_inventory_row",
            ]
        case "post_index_change_emits_zero_helper_records":
            externalState = [
                "internal_core_mode:post_raw_read_tree_alternate",
                "alternate_tree_fixture:alternate_tree",
                "mutation_timing:after_all_raw_outcomes_before_first_post_HEAD",
                "post_HEAD:unchanged_exact41_and_pair000:000",
                "post_clean_status:bounded_body_A_and_pair000:000_external_failure",
                "post_write_tree_invocation_count:0",
                "expected_helper_record_count:0",
            ]
        case "workflow_dispatch_terminates_before_relation_call":
            externalState = [
                "event_kind:workflow_dispatch",
                "expected_helper_invocation_count:0",
            ]
        case "hostile_trace_state_fails_before_private_witness":
            externalState = [
                "hostile_trace_variants:xtrace,verbose,DEBUG,RETURN,ERR,errtrace,functrace,BASH_XTRACEFD,PS4",
                "expected_private_witness_byte_count:0",
            ]
        case "current_index_marker_nonHEAD_dirty_repository_rejected":
            externalState = [
                "target_repository_HEAD_differs_from_requested_literal_oid",
                "target_repository_status_porcelain_v1_untracked_files_all_is_nonempty",
                "current_index_marker_occurrence_count:1",
                "relation_suffix_occurrence_count:0",
                "direct_helper_pre_HEAD_mismatch_stops_before_clean_status",
                "expected_helper_invocation_count:1",
            ]
        case "legacy_flat_nonHEAD_dirty_repository_remains_legacy":
            externalState = [
                "target_repository_HEAD_differs_from_requested_literal_oid",
                "target_repository_status_porcelain_v1_untracked_files_all_is_nonempty",
                "current_index_marker_occurrence_count:0",
                "relation_suffix_occurrence_count:0",
                "new_HEAD_status_write_tree_barrier_invocation_count:0",
            ]
        default:
            externalState = []
        }
        let pureStimulus: [String]
        switch caseID {
        case "wave1_missing_merge_stops_all_raw":
            pureStimulus = [
                "observation_kind:relation_preprobe_and_result_selector",
                "merge_fixture:withheld_child",
                "merge_object_ordinal:2",
                "merge_inventory:missing",
                "merge_required_availability_relation_phase:15",
                "merge_raw_stream_count:0",
                "expected_selected_relation_phase:15",
            ]
        case "merge_wrong_tree_isolated":
            pureStimulus = [
                "observation_kind:relation_classifier_child_and_result_selector",
                "merge_fixture:wrong_tree_relation_merge",
                "merge_capture_fixture:relation_tree_mismatch_deferred",
                "merge_classifier_status:41",
                "merge_competing_tree_phase:37",
                "discovered_child_fixture:valid_child",
                "child_preprobe:present_commit_within_bound",
                "child_raw_classifier_status:0",
                "expected_selected_relation_phase:37",
            ]
        case "wrong_tree_one_parent_selects_tree_without_witness":
            pureStimulus = [
                "observation_kind:relation_classifier_and_result_selector",
                "merge_fixture:wrong_tree_child",
                "merge_capture_fixture:relation_tree_mismatch_without_parent2",
                "merge_classifier_status:41",
                "merge_body_byte_count:0",
                "child_preprobe_count:0",
                "child_raw_stream_count:0",
                "expected_selected_relation_phase:37",
            ]
        case "child_phase15_beats_merge_phase37":
            pureStimulus = [
                "observation_kind:relation_classifier_child_preprobe_and_result_selector",
                "merge_fixture:wrong_tree_missing_child_relation_merge",
                "merge_capture_fixture:relation_wrong_tree_withheld_child_witness",
                "merge_classifier_status:41",
                "merge_competing_tree_phase:37",
                "discovered_child_fixture:withheld_child",
                "discovered_child_object_ordinal:3",
                "child_inventory:missing",
                "child_required_availability_relation_phase:15",
                "child_raw_stream_count:0",
                "expected_selected_relation_phase:15",
            ]
        case "wave2_phase15_outweighs_earlier_explicit_raw_failure":
            pureStimulus = [
                "observation_kind:private_component_harness_and_result_selector",
                "ordinary_explicit_object_ordinal:1",
                "ordinary_explicit_git_status:1",
                "ordinary_explicit_classifier_status:0",
                "ordinary_explicit_body_byte_count:0",
                "ordinary_explicit_competing_relation_phase:20",
                "merge_fixture:missing_child_relation_merge",
                "merge_classifier_status:0",
                "merge_capture_fixture:relation_success_withheld_child_witness",
                "discovered_child_fixture:withheld_child",
                "discovered_child_object_ordinal:3",
                "child_inventory:missing",
                "child_required_availability_relation_phase:15",
                "child_raw_stream_count:0",
                "expected_selected_relation_phase:15",
            ]
        default:
            if let captureFixtureID, directPureHook {
            pureStimulus = [
                "observation_kind:relation_capture",
                "capture_fixture:\(captureFixtureID)",
            ]
            } else if let valueFixtureID, directPureHook {
            pureStimulus = [
                "observation_kind:relation_value_domain",
                "value_fixture:\(valueFixtureID)",
            ]
            } else if directPureHook {
            pureStimulus = [
                "observation_kind:relation_classifier_and_result_selector",
                "ontology_case:\(caseID)",
            ]
            } else {
            pureStimulus = []
            }
        }
        let kind: String
        if executionKind == "direct_component_harness" {
            kind = "direct_component_harness_and_result_selector"
        } else if directPureHook {
            kind = "direct_helper_parser_fixture"
        } else if privateComponentHarness {
            kind = "private_component_harness_and_result_selector"
        } else if gateRejectsBeforeHelper {
            kind = "external_gate_admission_no_helper_invocation"
        } else if externalState.isEmpty {
            kind = "executable_helper_argv"
        } else {
            kind = "executable_helper_argv_with_typed_external_state"
        }
        var references = explicitFixtureIDs
        references += [mergeFixtureID, childFixtureID, captureFixtureID, valueFixtureID]
            .compactMap { $0 }
        return .init(
            recipeKind: kind,
            repositoryArgumentToken: repository,
            exactHelperArgumentTokens:
                caseID == "workflow_dispatch_terminates_before_relation_call"
                    ? [] : arguments,
            exactPureHookStimulusTokens: pureStimulus,
            exactExternalStateTokens: externalState,
            referencedFixtureIDs: references)
    }

    static func ontology(
        _ ordinal: Int,
        _ caseID: String,
        _ executionKind: String,
        _ eventKind: String,
        _ suffixEnabled: Bool,
        _ explicitFixtureIDs: [String],
        _ mergeFixtureID: String?,
        _ childFixtureID: String?,
        _ captureFixtureID: String?,
        _ valueFixtureID: String?,
        _ condition: String,
        _ result: String,
        _ guardID: String?,
        _ missingRole: String?,
        _ objectOrdinal: Int?,
        _ classifierStatus: Int?,
        _ mergeStreams: Int,
        _ childPreprobes: Int,
        _ childStreams: Int,
        _ recordCount: Int,
        _ predicateID: String,
        _ rawBytesRequired: Bool,
        _ currentIndexMarkerOccurrenceCount: Int = 0,
        _ relationSuffixOccurrenceCount: Int? = nil
    ) -> RelationOntologyCase {
        let suffixCount = relationSuffixOccurrenceCount
            ?? (suffixEnabled ? 1 : 0)
        let liveRepositoryCase = [
            "private_sha1_repository",
            "private_repository_with_transport_injection",
            "direct_component_harness",
        ].contains(executionKind) || [
            "post_index_change_emits_zero_helper_records",
            "hostile_trace_state_fails_before_private_witness",
            "current_index_marker_nonHEAD_dirty_repository_rejected",
        ].contains(caseID)
        let publicHelperInvocationCount = executionKind
            == "direct_helper_parser_fixture"
            || executionKind == "direct_component_harness"
            || executionKind == "pure_capture"
            || executionKind == "pure_value_domain"
            || executionKind == "pure_invocation"
            || executionKind == "private_repository_with_transport_injection"
            || caseID == "discovered_child_equal_merge_rejected_truthfully"
            || [
                "workflow_dispatch_terminates_before_relation_call",
            ].contains(caseID)
            ? 0 : 1
        let directComponentHarness = [
            "direct_component_harness",
            "private_repository_with_transport_injection",
        ].contains(executionKind)
        let publicRawObservationBlocked = [
            "hostile_trace_state_fails_before_private_witness",
            "current_index_marker_nonHEAD_dirty_repository_rejected",
        ].contains(caseID)
        let expectedPhase = guardID.flatMap { expectedGuardID in
            let mappings = suffixCount > 0
                ? relationGuardMappings() : flatGuardMappings()
            return mappings.first(where: { $0.guardID == expectedGuardID })?
                .phaseOrdinal
        }
        return .init(
            ordinal: ordinal,
            caseID: caseID,
            executionKind: executionKind,
            eventKind: eventKind,
            suffixEnabled: suffixEnabled,
            currentIndexMarkerOccurrenceCount:
                currentIndexMarkerOccurrenceCount,
            relationSuffixOccurrenceCount: suffixCount,
            validatedSuffixMergeRole: suffixCount == 1
                ? (caseID == "alternate_valid_merge_role_missing_is_selected"
                    ? "alternate_merge_role" : "current_exact_revision")
                : nil,
            validatedSuffixChildRole: suffixCount == 1
                ? (caseID == "alternate_valid_child_role_missing_is_projected"
                    ? "alternate_child_role" : "current_reviewed_child")
                : nil,
            invocationRecipe: ontologyInvocationRecipe(
                caseID: caseID,
                executionKind: executionKind,
                eventKind: eventKind,
                explicitFixtureIDs: explicitFixtureIDs,
                mergeFixtureID: mergeFixtureID,
                childFixtureID: childFixtureID,
                captureFixtureID: captureFixtureID,
                valueFixtureID: valueFixtureID,
                currentIndexMarkerOccurrenceCount:
                    currentIndexMarkerOccurrenceCount,
                relationSuffixOccurrenceCount: suffixCount),
            privateRepositoryRecipeID: liveRepositoryCase
                ? "private_repo_recipe_\(caseID)" : nil,
            explicitFixtureIDs: explicitFixtureIDs,
            relationMergeFixtureID: mergeFixtureID,
            discoveredChildFixtureID: childFixtureID,
            captureFixtureID: captureFixtureID,
            valueDomainFixtureID: valueFixtureID,
            exactInjectedCondition: condition,
            expectedResultCode: result,
            expectedFirstFailedGuardID: guardID,
            expectedFirstFailedPhaseOrdinal: expectedPhase,
            expectedMissingObjectRole: missingRole,
            expectedFirstFailureObjectOrdinal: objectOrdinal,
            expectedRelationClassifierStatus: classifierStatus,
            expectedPublicExplicitRawStreamCount:
                publicHelperInvocationCount == 1 && !publicRawObservationBlocked
                    ? explicitFixtureIDs.count : 0,
            expectedPublicMergeRawStreamCount:
                directComponentHarness ? 0 : mergeStreams,
            expectedPublicChildPreprobeCount:
                directComponentHarness ? 0 : childPreprobes,
            expectedPublicChildRawStreamCount:
                directComponentHarness ? 0 : childStreams,
            expectedComponentExplicitPreprobeGitInvocationCount: 0,
            expectedComponentExplicitRawGitInvocationCount: 0,
            expectedComponentExplicitClassifierInvocationCount: 0,
            expectedComponentExplicitFrameInjectionCount:
                caseID == "wave2_phase15_outweighs_earlier_explicit_raw_failure"
                    ? 1 : 0,
            expectedComponentMergePreprobeGitInvocationCount:
                directComponentHarness && suffixCount == 1 ? 1 : 0,
            expectedComponentMergeRawGitInvocationCount:
                directComponentHarness ? mergeStreams : 0,
            expectedComponentMergeClassifierInvocationCount:
                directComponentHarness ? mergeStreams : 0,
            expectedComponentChildPreprobeGitInvocationCount:
                directComponentHarness ? childPreprobes : 0,
            expectedComponentChildRawGitInvocationCount:
                directComponentHarness ? childStreams : 0,
            expectedComponentChildClassifierInvocationCount:
                directComponentHarness ? childStreams : 0,
            expectedPureRelationFrameInjectionCount:
                executionKind == "pure_capture" ? 1 : 0,
            expectedPublicHelperInvocationCount: publicHelperInvocationCount,
            expectedValidHelperRecordCount: recordCount,
            isolatedPredicateID: predicateID,
            reproducibleRawBytesRequired: rawBytesRequired)
    }

    static func parserVector(
        _ ordinal: Int,
        _ fixtureID: String,
        _ mode: String,
        _ tokens: [String],
        _ accepted: Bool,
        _ guardID: String? = nil,
        _ phase: Int? = nil,
        _ objectOrdinal: Int? = nil
    ) -> InvocationParserVector {
        .init(
            ordinal: ordinal,
            fixtureID: fixtureID,
            executionKind: "direct_helper_parser_fixture_no_git_or_record",
            expectedMode: mode,
            exactArgumentTokens: tokens,
            expectedAccepted: accepted,
            expectedResultCode:
                accepted ? "PARSER_ACCEPTED" : "TOPOLOGY_INVOCATION_INVALID",
            expectedFirstFailedGuardID: guardID,
            expectedFirstFailedPhaseOrdinal: phase,
            expectedFirstFailureObjectOrdinal: objectOrdinal,
            expectedGitInvocationCount: 0,
            expectedValidHelperRecordCount: 0,
            futurePrivateMatrixRequired: true)
    }

    static func exactInvocationParserVectors() -> [InvocationParserVector] {
        let objects = Dictionary(
            uniqueKeysWithValues: exactObjectFixtures().map { ($0.fixtureID, $0) }
        )
        let repository = "<private_repository>"
        let fixed = objects["fixed_parent"]!.literalObjectOID
        let child = objects["valid_child"]!.literalObjectOID
        let tree = objects["empty_tree"]!.literalObjectOID
        let merge = objects["valid_relation_merge"]!.literalObjectOID
        func request(_ ordinal: Int, role: String? = nil) -> [String] {
            [role ?? "requested_object_\(ordinal)", fixed, tree, "0"]
        }
        func requests(_ count: Int) -> [String] {
            (1 ... max(count, 1)).flatMap { request($0) }
                .prefix(count * 4).map { $0 }
        }
        func suffix(
            mergeRole: String = "current_exact_revision",
            mergeOID: String? = nil,
            indexTree: String? = nil,
            fixedParent: String? = nil,
            childRole: String = "current_reviewed_child"
        ) -> [String] {
            [
                "--ordered-merge-child-relation",
                mergeRole,
                mergeOID ?? merge,
                indexTree ?? tree,
                fixedParent ?? fixed,
                childRole,
            ]
        }
        let relationShape = "expected_parent_count_within_bound"
        let roleGrammar = "request_role_matches_ascii_allowlist_grammar"
        let roleUnique = "request_roles_are_unique"
        let oidLiteral = "literal_commit_oid_is_lowercase_40hex"
        let expectedOID = "expected_topology_oids_are_lowercase_40hex"
        var values: [InvocationParserVector] = []
        func add(
            _ id: String,
            _ mode: String,
            _ tokens: [String],
            _ accepted: Bool,
            _ guardID: String? = nil,
            _ phase: Int? = nil,
            _ objectOrdinal: Int? = nil
        ) {
            values.append(parserVector(
                values.count + 1, id, mode, tokens, accepted, guardID, phase,
                objectOrdinal
            ))
        }
        add("relation_explicit_count1_valid", "relation", [repository, "1"] + requests(1) + suffix(), true)
        add("relation_explicit_count6_valid", "relation", [repository, "6"] + requests(6) + suffix(), true)
        add("relation_explicit_count0_rejected", "relation", [repository, "0"] + suffix(), false, "verification_request_count_nonzero", 4)
        add("relation_explicit_count7_rejected", "relation", [repository, "7"] + requests(7) + suffix(), false, "verification_request_count_within_bound", 5)
        add("relation_suffix_repeated_full_rejected", "relation", [repository, "1"] + requests(1) + suffix() + suffix(), false, relationShape, 9)
        add("relation_suffix_surplus_nonterminal_rejected", "relation", [repository, "1"] + requests(1) + suffix() + ["surplus_token"], false, relationShape, 9)
        for operandCount in 0 ... 4 {
            add(
                "relation_suffix_truncated_after_\(operandCount)_operands",
                "relation",
                [repository, "1"] + requests(1)
                    + Array(suffix().prefix(1 + operandCount)),
                false,
                relationShape,
                9
            )
        }
        add("relation_marker_inside_declared_request_region", "relation", [repository, "2"] + requests(1) + ["--current-index-exact-revision"] + suffix(), false, relationShape, 9)
        add("relation_declared_count_underflow", "relation", [repository, "2"] + requests(1) + suffix(), false, relationShape, 9)
        add("relation_declared_count_overflow", "relation", [repository, "1"] + requests(2) + suffix(), false, relationShape, 9)
        add("relation_count_leading_zero_rejected", "relation", [repository, "01"] + requests(1) + suffix(), false, "verification_request_count_nonzero", 4)
        add("relation_count_plus_prefix_rejected", "relation", [repository, "+1"] + requests(1) + suffix(), false, "verification_request_count_nonzero", 4)
        add("relation_count_nondigit_rejected", "relation", [repository, "one"] + requests(1) + suffix(), false, "verification_request_count_nonzero", 4)
        add("relation_invalid_merge_role_rejected", "relation", [repository, "1"] + requests(1) + suffix(mergeRole: "Invalid"), false, roleGrammar, 7, 2)
        add("relation_invalid_child_role_rejected", "relation", [repository, "1"] + requests(1) + suffix(childRole: "Invalid"), false, roleGrammar, 7, 3)
        add("relation_merge_role_equals_child_role", "relation", [repository, "1"] + requests(1) + suffix(childRole: "current_exact_revision"), false, roleUnique, 8, 3)
        add("relation_child_role_equals_explicit_role", "relation", [repository, "1"] + request(1, role: "current_reviewed_child") + suffix(), false, roleUnique, 8, 3)
        add("relation_invalid_merge_oid_rejected", "relation", [repository, "1"] + requests(1) + suffix(mergeOID: String(repeating: "A", count: 40)), false, oidLiteral, 1, 2)
        add("relation_invalid_index_tree_oid_rejected", "relation", [repository, "1"] + requests(1) + suffix(indexTree: String(repeating: "A", count: 40)), false, expectedOID, 2, 2)
        add("relation_invalid_fixed_parent_oid_rejected", "relation", [repository, "1"] + requests(1) + suffix(fixedParent: String(repeating: "A", count: 40)), false, expectedOID, 2, 2)
        add("relation_and_current_index_markers_mixed", "relation", [repository, "1"] + requests(1) + ["--current-index-exact-revision"] + suffix(), false, relationShape, 9)
        add("current_index_explicit_count8_valid", "current_index", [repository, "8"] + requests(8) + ["--current-index-exact-revision"], true)
        add("current_index_PR_explicit_count1_valid", "current_index", [repository, "1", "current_exact_revision", child, tree, "1", fixed, "--current-index-exact-revision"], true)
        add(
            "combined_bad_merge_oid_and_count0_selects_phase1",
            "relation",
            [repository, "0"] + suffix(mergeOID: String(repeating: "A", count: 40)),
            false, oidLiteral, 1, 1
        )
        add(
            "combined_bad_index_and_fixed_oids_and_count7_selects_phase2",
            "relation",
            [repository, "7"] + requests(7) + suffix(
                indexTree: String(repeating: "A", count: 40),
                fixedParent: String(repeating: "B", count: 40)
            ),
            false, expectedOID, 2, 8
        )
        add(
            "combined_merge_equals_fixed_and_count7_selects_phase3",
            "relation",
            [repository, "7"] + requests(7) + suffix(mergeOID: fixed),
            false,
            "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids",
            3, 8
        )
        add(
            "combined_count7_and_bad_merge_role_selects_phase5",
            "relation",
            [repository, "7"] + requests(7) + suffix(mergeRole: "Invalid"),
            false, "verification_request_count_within_bound", 5
        )
        add(
            "combined_bad_explicit_role_and_duplicate_merge_role_selects_phase7",
            "relation",
            [repository, "1"] + request(1, role: "Invalid")
                + suffix(mergeRole: "Invalid"),
            false, roleGrammar, 7, 1
        )
        add(
            "combined_duplicate_merge_role_and_surplus_selects_phase8",
            "relation",
            [repository, "1"] + request(1, role: "current_exact_revision")
                + suffix() + ["surplus_token"],
            false, roleUnique, 8, 2
        )
        add(
            "tie_invalid_explicit_and_merge_oids_selects_explicit_ordinal1",
            "relation",
            [repository, "1", "requested_object_1",
             String(repeating: "A", count: 40), tree, "0"]
                + suffix(mergeOID: String(repeating: "B", count: 40)),
            false, oidLiteral, 1, 1
        )
        add(
            "tie_invalid_merge_and_child_roles_selects_merge_ordinal2",
            "relation",
            [repository, "1"] + requests(1)
                + suffix(
                    mergeRole: "InvalidMerge",
                    childRole: "Invalid"
                ),
            false, roleGrammar, 7, 2
        )
        add(
            "ordinary_suffix_free_count1_valid_legacy_mode",
            "ordinary",
            [repository, "1"] + requests(1),
            true
        )
        add(
            "current_index_marker_repeated_rejected",
            "current_index",
            [repository, "1"] + requests(1)
                + ["--current-index-exact-revision", "--current-index-exact-revision"],
            false, relationShape, 8
        )
        add(
            "current_index_marker_surplus_rejected",
            "current_index",
            [repository, "1"] + requests(1)
                + ["--current-index-exact-revision", "surplus_token"],
            false, relationShape, 8
        )
        add(
            "relation_marker_spelling_as_expected_parent_is_ordinary_phase2",
            "ordinary",
            [repository, "1", "requested_object_1", fixed, tree, "1",
             "--ordered-merge-child-relation"],
            false, expectedOID, 2, 1
        )
        add(
            "current_marker_spelling_as_expected_parent_is_ordinary_phase2",
            "ordinary",
            [repository, "1", "requested_object_1", fixed, tree, "1",
             "--current-index-exact-revision"],
            false, expectedOID, 2, 1
        )
        add(
            "relation_marker_spelling_as_explicit_role_is_ordinary_phase6",
            "ordinary",
            [repository, "1", "--ordered-merge-child-relation", fixed, tree, "0"],
            false, roleGrammar, 6, 1
        )
        add(
            "current_marker_spelling_as_explicit_role_is_ordinary_phase6",
            "ordinary",
            [repository, "1", "--current-index-exact-revision", fixed, tree, "0"],
            false, roleGrammar, 6, 1
        )
        add(
            "arbitrary_dashed_explicit_role_is_ordinary_phase6",
            "ordinary",
            [repository, "1", "--bad", fixed, tree, "0"],
            false, roleGrammar, 6, 1
        )
        add(
            "relation_marker_spelling_as_parent_count_is_ordinary_phase8",
            "ordinary",
            [repository, "1", "requested_object_1", fixed, tree,
             "--ordered-merge-child-relation"],
            false, relationShape, 8
        )
        add(
            "current_marker_spelling_as_parent_count_is_ordinary_phase8",
            "ordinary",
            [repository, "1", "requested_object_1", fixed, tree,
             "--current-index-exact-revision"],
            false, relationShape, 8
        )
        add(
            "relation_alternate_valid_merge_role_accepted",
            "relation",
            [repository, "1"] + requests(1)
                + suffix(mergeRole: "alternate_merge_role"),
            true
        )
        add(
            "relation_alternate_valid_child_role_accepted",
            "relation",
            [repository, "1"] + requests(1)
                + suffix(childRole: "alternate_child_role"),
            true
        )
        return values
    }

    static func exactPrivateRepositoryExecutionRecipes(
        _ cases: [RelationOntologyCase]
    ) -> [PrivateRepositoryExecutionRecipe] {
        let objects = exactObjectFixtures()
        let objectByID = Dictionary(
            uniqueKeysWithValues: objects.map { ($0.fixtureID, $0) }
        )
        let written = objects.filter(\.expectedDestinationInventoryPresent)
            .map(\.fixtureID)
        let withheld = objects.filter { !$0.expectedDestinationInventoryPresent }
            .map(\.fixtureID)
        let tree = objectByID["empty_tree"]!.literalObjectOID
        let alternateTree = objectByID["alternate_tree"]!.literalObjectOID
        let live = cases.filter { $0.privateRepositoryRecipeID != nil }
        return live.enumerated().map { offset, ontologyCase in
            let currentFixtureID: String
            if [
                "legacy_flat_nonHEAD_dirty_repository_remains_legacy",
                "current_index_marker_nonHEAD_dirty_repository_rejected",
            ].contains(ontologyCase.caseID)
            {
                currentFixtureID = "unrelated"
            } else if ontologyCase.executionKind == "direct_component_harness" {
                currentFixtureID = "valid_relation_merge"
            } else if ontologyCase.eventKind == "pull_request" {
                currentFixtureID = ontologyCase.explicitFixtureIDs[0]
            } else {
                currentFixtureID = ontologyCase.relationMergeFixtureID!
            }
            let currentOID = objectByID[currentFixtureID]!.literalObjectOID
            let gateBodies: [String]
            let helperPreBodies: [String]
            let helperPostBodies: [String]
            let mutation: [String]
            switch ontologyCase.caseID {
            case "wave1_missing_merge_stops_all_raw",
                 "merge_wrong_tree_isolated",
                 "wrong_tree_one_parent_selects_tree_without_witness",
                 "child_phase15_beats_merge_phase37",
                 "alternate_valid_merge_role_missing_is_selected":
                gateBodies = []
                helperPreBodies = []
                helperPostBodies = []
                mutation = []
            case "legacy_flat_nonHEAD_dirty_repository_remains_legacy":
                gateBodies = []
                helperPreBodies = []
                helperPostBodies = []
                mutation = [
                    "mutation_kind:bash_builtin_printf_empty_redirect_new_regular_file",
                    "mutation_timing:immediately_before_gate_or_legacy_helper_call",
                    "relative_path:prime-dirty-probe",
                    "expected_full_status_body:?? prime-dirty-probe\\n",
                ]
            case "current_index_marker_nonHEAD_dirty_repository_rejected":
                gateBodies = []
                helperPreBodies = [currentOID + "\n"]
                helperPostBodies = []
                mutation = [
                    "mutation_kind:bash_builtin_printf_empty_redirect_new_regular_file",
                    "mutation_timing:immediately_before_gate_or_legacy_helper_call",
                    "relative_path:prime-dirty-probe",
                    "expected_full_status_body:?? prime-dirty-probe\\n",
                ]
            case "post_index_change_emits_zero_helper_records":
                gateBodies = ["", tree + "\n"]
                helperPreBodies = [currentOID + "\n", "", tree + "\n"]
                helperPostBodies = [currentOID + "\n", "A"]
                mutation = [
                    "internal_core_mode:post_raw_read_tree_alternate",
                    "timing:after_all_raw_outcomes_before_first_post_HEAD",
                    "exact_argument_vector_begin",
                ] + cleanGitAt("<validated_private_compiler_root>", [
                    "-C", "<private_repository>", "read-tree", alternateTree,
                ]) + [
                    "exact_argument_vector_end",
                    "expected_status:0", "expected_stdout_bytes:0",
                    "expected_stderr_bytes:0",
                    "HEAD_mutation_invocation_count:0",
                    "post_HEAD_body:" + currentOID + "\\n",
                    "post_HEAD_status_pair:000:000",
                    "post_clean_status_body:A",
                    "post_clean_status_status_pair:000:000",
                    "post_write_tree_invocation_count:0",
                ]
            case "hostile_trace_state_fails_before_private_witness":
                gateBodies = ["", tree + "\n"]
                helperPreBodies = [currentOID + "\n", "", tree + "\n"]
                helperPostBodies = []
                mutation = [
                    "before_witness:hostile_trace_variants",
                    "xtrace", "verbose", "DEBUG", "RETURN", "ERR",
                    "errtrace", "functrace", "BASH_XTRACEFD", "PS4",
                ]
            case "wave2_phase15_outweighs_earlier_explicit_raw_failure":
                gateBodies = []
                helperPreBodies = []
                helperPostBodies = []
                mutation = ontologyCase.invocationRecipe.exactExternalStateTokens
            default:
                gateBodies = ["", tree + "\n"]
                helperPreBodies = [currentOID + "\n", "", tree + "\n"]
                helperPostBodies = [currentOID + "\n", "", tree + "\n"]
                mutation = []
            }
            let statusPairs = Array(
                repeating: "000:000",
                count: gateBodies.count + helperPreBodies.count
                    + helperPostBodies.count
            )
            return .init(
                ordinal: offset + 1,
                recipeID: ontologyCase.privateRepositoryRecipeID!,
                ontologyCaseID: ontologyCase.caseID,
                exactInitArgumentVector: cleanGit([
                    "init", "-q",
                    "--initial-branch=main", "--object-format=sha1",
                    "<private_repository>",
                ]),
                initExpectedStatus: 0,
                initExpectedStdinByteCount: 0,
                initExpectedStdoutByteCount: 0,
                initExpectedStderrByteCount: 0,
                exactWrittenFixtureIDs: written,
                exactObjectWriteArgumentVectorTemplate: cleanGit([
                    "-C", "<private_repository>",
                    "hash-object", "--literally", "-t", "<object_type>",
                    "-w", "--stdin",
                ]),
                objectWriteStdinSource:
                    "exact_base64_decoded_payload_bytes_for_each_exactWrittenFixtureID",
                everyObjectWriteExpectedStatus: 0,
                everyObjectWriteExpectedStdout:
                    "that_fixture_literal_object_oid_plus_one_lf",
                everyObjectWriteExpectedStderrByteCount: 0,
                exactWithheldFixtureIDs: withheld,
                withheldFixtureWriteInvocationCount: 0,
                exactUpdateRefHEADArgumentVector: cleanGit([
                    "-C", "<private_repository>",
                    "update-ref", "HEAD", currentOID,
                ]),
                eventCurrentFixtureID: currentFixtureID,
                updateRefExpectedStatus: 0,
                updateRefExpectedStdinByteCount: 0,
                updateRefExpectedStdoutByteCount: 0,
                updateRefExpectedStderrByteCount: 0,
                exactReadTreeArgumentVector: cleanGit([
                    "-C", "<private_repository>",
                    "read-tree", tree,
                ]),
                independentIndexTreeFixtureID: "empty_tree",
                readTreeExpectedStatus: 0,
                readTreeExpectedStdinByteCount: 0,
                readTreeExpectedStdoutByteCount: 0,
                readTreeExpectedStderrByteCount: 0,
                typedMutationTokens: mutation,
                exactExpectedGateProbeBodies: gateBodies,
                exactExpectedHelperPreProbeBodies: helperPreBodies,
                exactExpectedHelperPostProbeBodies: helperPostBodies,
                exactExpectedProbeStatusPairs: statusPairs,
                inventoryRequiredBeforeCase: true,
                expectedHelperInvocationCount:
                    ontologyCase.expectedPublicHelperInvocationCount,
                expectedValidHelperRecordCount:
                    ontologyCase.expectedValidHelperRecordCount)
        }
    }

    static func exactComponentHarnessRecipes(
        _ cases: [RelationOntologyCase]
    ) -> [ComponentHarnessRecipe] {
        let objects = Dictionary(
            uniqueKeysWithValues: exactObjectFixtures().map { ($0.fixtureID, $0) }
        )
        let fixedOID = objects["fixed_parent"]!.literalObjectOID
        let indexTreeOID = objects["empty_tree"]!.literalObjectOID
        let classifier =
            "<validated_private_compiler_root>/prime-exact-revision-topology-classifier"
        let selectedCaseIDs = [
            "wave1_missing_merge_stops_all_raw",
            "merge_wrong_tree_isolated",
            "wave2_phase15_outweighs_earlier_explicit_raw_failure",
            "wrong_tree_one_parent_selects_tree_without_witness",
            "child_phase15_beats_merge_phase37",
            "alternate_valid_merge_role_missing_is_selected",
        ]
        let selected = selectedCaseIDs.map { caseID in
            cases.first(where: { $0.caseID == caseID })!
        }
        func preprobeLine(_ fixtureID: String) -> String {
            let fixture = objects[fixtureID]!
            return fixture.literalObjectOID
                + (fixture.expectedDestinationInventoryPresent
                    ? " \(fixture.objectType) \(fixture.payloadByteCount)\n"
                    : " missing\n")
        }
        func preprobeStep(
            _ ordinal: Int,
            _ kind: String,
            _ fixtureID: String,
            _ objectOrdinal: Int
        ) -> ComponentHarnessRecipe.Step {
            let fixture = objects[fixtureID]!
            return .init(
                ordinal: ordinal,
                stepKind: kind,
                executionKind: "live_inherited_exact_object_batch_preprobe",
                exactContractSource:
                    "PrimeExactRevisionTopologyVerifierAuthorityV1.commitHeaderContract.exactObjectPreprobeArgumentVector",
                literalObjectOID: fixture.literalObjectOID,
                logicalObjectOrdinal: objectOrdinal,
                classifierMode: nil,
                expectedTreeOID: nil,
                fixedParentOID: nil,
                advertisedObjectByteCount: nil,
                exactGitArgumentVector: cleanGitAt(
                    "<validated_private_compiler_root>", [
                        "-C", "<private_repository>", "cat-file",
                        "--batch-check=%(objectname) %(objecttype) %(objectsize)",
                    ]
                ),
                exactClassifierArgumentVector: [],
                exactPreprobeStdin: fixture.literalObjectOID + "\n",
                stdinFixtureID: nil,
                exactPreprobeLine: preprobeLine(fixtureID),
                producerStatus: 0,
                classifierStatus: nil,
                captureFixtureID: nil,
                exactDistinctnessComparisonOIDs: [],
                distinctnessExpectedPass: nil,
                physicalGitInvocationCount: 1,
                physicalClassifierInvocationCount: 0,
                productionFrameAdmissionInvocationCount: 0,
                pureFrameInjectionHookInvocationCount: 0
            )
        }
        func rawStep(
            _ ordinal: Int,
            _ kind: String,
            _ fixtureID: String,
            _ objectOrdinal: Int,
            _ mode: String,
            _ classifierStatus: Int,
            _ captureFixtureID: String,
            expectedParentOIDs: [String]
        ) -> ComponentHarnessRecipe.Step {
            let fixture = objects[fixtureID]!
            let classifierArguments: [String]
            let source: String
            if mode == "relation" {
                classifierArguments = [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>", classifier,
                    "--ordered-merge-child-relation",
                    fixture.literalObjectOID,
                    String(fixture.payloadByteCount), indexTreeOID, fixedOID,
                ]
                source =
                    "PrimeExactRevisionTopologyRelationAmendmentAuthorityV1.relationClassifierContract.exactRelationArgumentVector"
            } else {
                classifierArguments = [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>", classifier,
                    fixture.literalObjectOID,
                    String(fixture.payloadByteCount), indexTreeOID,
                    String(expectedParentOIDs.count),
                ] + expectedParentOIDs
                source =
                    "PrimeExactRevisionTopologyVerifierAuthorityV1.commitHeaderContract.exactRawCatFileArgumentVector_and_classifierCleanEnvironmentArgumentVectorPrefix"
            }
            return .init(
                ordinal: ordinal,
                stepKind: kind,
                executionKind: "live_git_raw_stream_into_admitted_classifier",
                exactContractSource: source,
                literalObjectOID: fixture.literalObjectOID,
                logicalObjectOrdinal: objectOrdinal,
                classifierMode: mode,
                expectedTreeOID: indexTreeOID,
                fixedParentOID: mode == "relation" ? fixedOID : nil,
                advertisedObjectByteCount: fixture.payloadByteCount,
                exactGitArgumentVector: cleanGitAt(
                    "<validated_private_compiler_root>", [
                        "-C", "<private_repository>", "cat-file", "commit",
                        fixture.literalObjectOID,
                    ]
                ),
                exactClassifierArgumentVector: classifierArguments,
                exactPreprobeStdin: nil,
                stdinFixtureID: fixtureID,
                exactPreprobeLine: nil,
                producerStatus: 0,
                classifierStatus: classifierStatus,
                captureFixtureID: captureFixtureID,
                exactDistinctnessComparisonOIDs: [],
                distinctnessExpectedPass: nil,
                physicalGitInvocationCount: 1,
                physicalClassifierInvocationCount: 1,
                productionFrameAdmissionInvocationCount: 1,
                pureFrameInjectionHookInvocationCount: 0
            )
        }
        func explicitTransportInjectionStep(
            _ ordinal: Int,
            _ fixtureID: String,
            _ objectOrdinal: Int
        ) -> ComponentHarnessRecipe.Step {
            let fixture = objects[fixtureID]!
            return .init(
                ordinal: ordinal,
                stepKind: "explicit_ordinary_transport_frame_injection",
                executionKind:
                    "pure_framed_transport_injection_same_production_frame_parser_no_git_or_classifier",
                exactContractSource:
                    "PrimeExactRevisionTopologyRelationAmendmentAuthorityV1.pureTestHookContract.relation_frame",
                literalObjectOID: fixture.literalObjectOID,
                logicalObjectOrdinal: objectOrdinal,
                classifierMode: "ordinary",
                expectedTreeOID: indexTreeOID,
                fixedParentOID: nil,
                advertisedObjectByteCount: fixture.payloadByteCount,
                exactGitArgumentVector: cleanGitAt(
                    "<validated_private_compiler_root>", [
                        "-C", "<private_repository>", "cat-file", "commit",
                        fixture.literalObjectOID,
                    ]
                ),
                exactClassifierArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "TMPDIR=<validated_private_compiler_root>", classifier,
                    fixture.literalObjectOID,
                    String(fixture.payloadByteCount), indexTreeOID,
                    String(fixture.parsedOrderedParentOIDs.count),
                ] + fixture.parsedOrderedParentOIDs,
                exactPreprobeStdin: nil,
                stdinFixtureID: nil,
                exactPreprobeLine: nil,
                producerStatus: 1,
                classifierStatus: 0,
                captureFixtureID: "ordinary_git_transport_failure_zero_body",
                exactDistinctnessComparisonOIDs: [],
                distinctnessExpectedPass: nil,
                physicalGitInvocationCount: 0,
                physicalClassifierInvocationCount: 0,
                productionFrameAdmissionInvocationCount: 1,
                pureFrameInjectionHookInvocationCount: 1
            )
        }
        func distinctnessStep(
            _ ordinal: Int,
            mergeFixtureID: String,
            childFixtureID: String,
            explicitFixtureIDs: [String]
        ) -> ComponentHarnessRecipe.Step {
            let childOID = objects[childFixtureID]!.literalObjectOID
            let compared = [
                objects[mergeFixtureID]!.literalObjectOID, fixedOID,
            ] + explicitFixtureIDs.map { objects[$0]!.literalObjectOID }
            return .init(
                ordinal: ordinal,
                stepKind: "child_distinctness_guard",
                executionKind: "production_value_guard_no_git_or_classifier",
                exactContractSource:
                    "PrimeExactRevisionTopologyRelationAmendmentAuthorityV1.resultContract.discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids",
                literalObjectOID: childOID,
                logicalObjectOrdinal: explicitFixtureIDs.count + 2,
                classifierMode: nil,
                expectedTreeOID: nil,
                fixedParentOID: fixedOID,
                advertisedObjectByteCount: nil,
                exactGitArgumentVector: [],
                exactClassifierArgumentVector: [],
                exactPreprobeStdin: nil,
                stdinFixtureID: nil,
                exactPreprobeLine: nil,
                producerStatus: nil,
                classifierStatus: nil,
                captureFixtureID: nil,
                exactDistinctnessComparisonOIDs: compared,
                distinctnessExpectedPass: !compared.contains(childOID),
                physicalGitInvocationCount: 0,
                physicalClassifierInvocationCount: 0,
                productionFrameAdmissionInvocationCount: 0,
                pureFrameInjectionHookInvocationCount: 0
            )
        }
        func selectorStep(_ ordinal: Int) -> ComponentHarnessRecipe.Step {
            .init(
                ordinal: ordinal,
                stepKind: "selector_hook",
                executionKind: "pure_shared_production_selector_hook",
                exactContractSource:
                    "PrimeExactRevisionTopologyRelationAmendmentAuthorityV1.pureTestHookContract.selector",
                literalObjectOID: nil,
                logicalObjectOrdinal: nil,
                classifierMode: nil,
                expectedTreeOID: nil,
                fixedParentOID: nil,
                advertisedObjectByteCount: nil,
                exactGitArgumentVector: [],
                exactClassifierArgumentVector: [],
                exactPreprobeStdin: nil,
                stdinFixtureID: nil,
                exactPreprobeLine: nil,
                producerStatus: nil,
                classifierStatus: nil,
                captureFixtureID: nil,
                exactDistinctnessComparisonOIDs: [],
                distinctnessExpectedPass: nil,
                physicalGitInvocationCount: 0,
                physicalClassifierInvocationCount: 0,
                productionFrameAdmissionInvocationCount: 0,
                pureFrameInjectionHookInvocationCount: 0
            )
        }
        func tuple(
            _ phase: Int,
            _ object: Int,
            _ result: String,
            _ guardID: String,
            _ missingRole: String = ""
        ) -> String {
            "\(phase)|\(object)|\(result)|\(guardID)|\(missingRole)"
        }
        return selected.enumerated().map { offset, ontologyCase in
            let steps: [ComponentHarnessRecipe.Step]
            let tuples: [String]
            switch ontologyCase.caseID {
            case "wave1_missing_merge_stops_all_raw",
                 "alternate_valid_merge_role_missing_is_selected":
                steps = [
                    preprobeStep(1, "merge_preprobe", "withheld_child", 2),
                    selectorStep(2),
                ]
                tuples = [tuple(
                    15, 2, "TOPOLOGY_OBJECT_UNAVAILABLE",
                    "required_object_availability",
                    ontologyCase.expectedMissingObjectRole!
                )]
            case "merge_wrong_tree_isolated":
                steps = [
                    preprobeStep(1, "merge_preprobe", "wrong_tree_relation_merge", 2),
                    rawStep(2, "merge_relation_raw", "wrong_tree_relation_merge", 2, "relation", 41, "relation_tree_mismatch_deferred", expectedParentOIDs: [fixedOID, objects["valid_child"]!.literalObjectOID]),
                    distinctnessStep(3, mergeFixtureID: "wrong_tree_relation_merge", childFixtureID: "valid_child", explicitFixtureIDs: ontologyCase.explicitFixtureIDs),
                    preprobeStep(4, "child_preprobe", "valid_child", 3),
                    rawStep(5, "child_ordinary_raw", "valid_child", 3, "ordinary", 0, "ordinary_success_zero_body", expectedParentOIDs: [fixedOID]),
                    selectorStep(6),
                ]
                tuples = [tuple(
                    37, 2, "TOPOLOGY_MISMATCH", "tree_oid_equals_expected"
                )]
            case "wave2_phase15_outweighs_earlier_explicit_raw_failure":
                steps = [
                    preprobeStep(1, "merge_preprobe", "missing_child_relation_merge", 2),
                    explicitTransportInjectionStep(2, "fixed_parent", 1),
                    rawStep(3, "merge_relation_raw", "missing_child_relation_merge", 2, "relation", 0, "relation_success_withheld_child_witness", expectedParentOIDs: [fixedOID, objects["withheld_child"]!.literalObjectOID]),
                    distinctnessStep(4, mergeFixtureID: "missing_child_relation_merge", childFixtureID: "withheld_child", explicitFixtureIDs: ontologyCase.explicitFixtureIDs),
                    preprobeStep(5, "child_preprobe", "withheld_child", 3),
                    selectorStep(6),
                ]
                tuples = [
                    tuple(20, 1, "TOPOLOGY_OBSERVATION_FAILED", "git_cat_file_transport_succeeded"),
                    tuple(15, 3, "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability", ontologyCase.expectedMissingObjectRole!),
                ]
            case "wrong_tree_one_parent_selects_tree_without_witness":
                steps = [
                    preprobeStep(1, "merge_preprobe", "wrong_tree_child", 2),
                    rawStep(2, "merge_relation_raw", "wrong_tree_child", 2, "relation", 41, "relation_tree_mismatch_without_parent2", expectedParentOIDs: [fixedOID]),
                    selectorStep(3),
                ]
                tuples = [tuple(
                    37, 2, "TOPOLOGY_MISMATCH", "tree_oid_equals_expected"
                )]
            default:
                steps = [
                    preprobeStep(1, "merge_preprobe", "wrong_tree_missing_child_relation_merge", 2),
                    rawStep(2, "merge_relation_raw", "wrong_tree_missing_child_relation_merge", 2, "relation", 41, "relation_wrong_tree_withheld_child_witness", expectedParentOIDs: [fixedOID, objects["withheld_child"]!.literalObjectOID]),
                    distinctnessStep(3, mergeFixtureID: "wrong_tree_missing_child_relation_merge", childFixtureID: "withheld_child", explicitFixtureIDs: ontologyCase.explicitFixtureIDs),
                    preprobeStep(4, "child_preprobe", "withheld_child", 3),
                    selectorStep(5),
                ]
                tuples = [
                    tuple(37, 2, "TOPOLOGY_MISMATCH", "tree_oid_equals_expected"),
                    tuple(15, 3, "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability", ontologyCase.expectedMissingObjectRole!),
                ]
            }
            return .init(
                ordinal: offset + 1,
                recipeID: "component_harness_\(ontologyCase.caseID)",
                ontologyCaseID: ontologyCase.caseID,
                privateRepositoryRecipeID: ontologyCase.privateRepositoryRecipeID!,
                constructionKind: "private_repository_component_harness",
                futureMatrixComponentPath:
                    ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
                futureMatrixFunctionName:
                    "prime_test_exact_revision_topology_component_harness_v1",
                exactFutureMatrixFunctionGrammar:
                    "prime_test_exact_revision_topology_component_harness_v1 <component_recipe_id>",
                exactFutureMatrixCallSiteLiteral:
                    "prime_test_exact_revision_topology_component_harness_v1 \"component_harness_\(ontologyCase.caseID)\"",
                exactFutureMatrixCallSiteCount: 1,
                publicHelperInvocationCount: 0,
                gateInvocationCount: 0,
                indexBarrierInvocationCount: 0,
                validHelperRecordCount: 0,
                projectionInvocationCount: 0,
                classifierBuildInvocationCount: 0,
                reusesAdmittedSelfTestedClassifier: true,
                exactOrderedSteps: steps,
                exactSelectorCandidateTuples: tuples,
                successfulCandidateTupleCount: 0,
                selectorHookInvocationCount: 1,
                expectedResultCode: ontologyCase.expectedResultCode,
                expectedFirstFailedGuardID:
                    ontologyCase.expectedFirstFailedGuardID,
                expectedFirstFailedPhaseOrdinal:
                    ontologyCase.expectedFirstFailedPhaseOrdinal,
                expectedFirstFailureObjectOrdinal:
                    ontologyCase.expectedFirstFailureObjectOrdinal,
                expectedMissingObjectRole:
                    ontologyCase.expectedMissingObjectRole,
                rawParent2CaptureAndChildLiteralMustEqual: [
                    "merge_wrong_tree_isolated",
                    "wave2_phase15_outweighs_earlier_explicit_raw_failure",
                    "child_phase15_beats_merge_phase37",
                ].contains(ontologyCase.caseID),
                childDistinctnessStepPrecedesChildPreprobeAndAllComparedOIDsDiffer:
                    steps.firstIndex(where: {
                        $0.stepKind == "child_distinctness_guard"
                    }).map { distinctnessIndex in
                        steps.firstIndex(where: {
                            $0.stepKind == "child_preprobe"
                        }).map { childIndex in
                            distinctnessIndex < childIndex
                                && steps[distinctnessIndex]
                                    .distinctnessExpectedPass == true
                        } ?? false
                    } ?? !steps.contains(where: {
                        $0.stepKind == "child_preprobe"
                    })
            )
        }
    }

    static func pair(
        _ ordinal: Int,
        _ pairID: String,
        _ predicateID: String,
        _ positive: String,
        _ negative: String,
        _ expectedDifferingSemanticFactIDs: [String]? = nil
    ) -> OntologyProofPair {
        .init(
            ordinal: ordinal,
            pairID: pairID,
            predicateID: predicateID,
            positiveCaseID: positive,
            negativeCaseID: negative,
            expectedDifferingSemanticFactIDs:
                expectedDifferingSemanticFactIDs ?? [predicateID],
            predicatesAreDisjoint: true,
            predicatesAreExhaustive: true,
            negativeUsesReproducibleRawBytesOrTruthfulPureDomain: true)
    }
}

public extension PrimeExactRevisionTopologyRelationAmendmentAuthorityV1 {
    static let frozenV1: Self = {
        let emptyTree = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"
        let alternateTree = "a8b941f979c6752d954e44f12986dcda9dd54417"
        let fixed = "78625e93e79913269c43412b20cd360f42b53534"
        let child = "b31a7a047572316879d5f6ba7f50ccb027b29d40"
        let objects = exactObjectFixtures()
        let captures = exactCaptureFixtures()
        let parserVectors = exactInvocationParserVectors()
        let gateRootCaptures: [GatePrivateRootContract.CaptureVector] = [
            gateRootCapture(1, "gate_root_path_valid", "mktemp_path", 0, 0, 0,
                "L3ByaXZhdGUvdG1wL3ByaW1lLXRvcG9sb2d5LWdhdGUuQTFiMkMzZDQK", 42,
                "113a30c7c73e214fab185adce1d0a382e7abf90d00ea3ecad6837c0ab810ed26",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "L3ByaXZhdGUvdG1wL3ByaW1lLXRvcG9sb2d5LWdhdGUuQTFiMkMzZDQKHnByaW1lX3N0YXR1czowMDA6MDAwHw==", 64,
                "cd7012ddf53158ca22dd346413d088676aa63c639895134a1ea3355ed6acef8a", true),
            gateRootCapture(2, "gate_root_path_wrong_leaf_rejected", "mktemp_path", 0, 0, 0,
                "L3ByaXZhdGUvdG1wL25vdC1wcmltZS10b3BvbG9neS5BMWIyQzNkNAo=", 41,
                "1fcce6a5ee8a9a7c71446eaa00b7f0cf809dbc576f8caeb7049bc2f1afb3e330",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "L3ByaXZhdGUvdG1wL25vdC1wcmltZS10b3BvbG9neS5BMWIyQzNkNAoecHJpbWVfc3RhdHVzOjAwMDowMDAf", 63,
                "863f6972a249822ab588339f6482464eff7677c2d3c1d478087270af61ade9fa", false),
            gateRootCapture(3, "gate_root_path_producer_nonzero_rejected", "mktemp_path", 1, 0, 0,
                "L3ByaXZhdGUvdG1wL3ByaW1lLXRvcG9sb2d5LWdhdGUuQTFiMkMzZDQK", 42,
                "113a30c7c73e214fab185adce1d0a382e7abf90d00ea3ecad6837c0ab810ed26",
                "HnByaW1lX3N0YXR1czowMDE6MDAwHw==",
                "0899433b330bcf623102c1324b4f0737edb5dcbffa29165e97b46c557e9010fe",
                "L3ByaXZhdGUvdG1wL3ByaW1lLXRvcG9sb2d5LWdhdGUuQTFiMkMzZDQKHnByaW1lX3N0YXR1czowMDE6MDAwHw==", 64,
                "0d38c3fe6778dd6578c043941ee67d0da19a6f3c4335ef77e795c3170622d6a5", false),
            gateRootCapture(4, "gate_root_stat_valid", "stat_metadata", 0, 0, 0,
                "NTAxIDQwNzAwIERpcmVjdG9yeQo=", 20,
                "ec3d039084c7209300ee9e83246db81794ba2e085421e433eff785aa62ac23c7",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "NTAxIDQwNzAwIERpcmVjdG9yeQoecHJpbWVfc3RhdHVzOjAwMDowMDAf", 42,
                "0ca3cd52034f9fc05c836daae25c6e0aead666153ca38c28e5b69f05f5c6621b", true),
            gateRootCapture(5, "gate_root_stat_wrong_mode_rejected", "stat_metadata", 0, 0, 0,
                "NTAxIDQwNzU1IERpcmVjdG9yeQo=", 20,
                "aef1432b92be85cbbcd29f1ab1f00a7551ac2977e1616afca453e844752f894a",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "NTAxIDQwNzU1IERpcmVjdG9yeQoecHJpbWVfc3RhdHVzOjAwMDowMDAf", 42,
                "4f9508de81bf892025e78c8b43f996ad92309772e7ce913faabaf6c1142f3447", false),
            gateRootCapture(6, "gate_root_stat_producer_nonzero_rejected", "stat_metadata", 1, 0, 0,
                "NTAxIDQwNzAwIERpcmVjdG9yeQo=", 20,
                "ec3d039084c7209300ee9e83246db81794ba2e085421e433eff785aa62ac23c7",
                "HnByaW1lX3N0YXR1czowMDE6MDAwHw==",
                "0899433b330bcf623102c1324b4f0737edb5dcbffa29165e97b46c557e9010fe",
                "NTAxIDQwNzAwIERpcmVjdG9yeQoecHJpbWVfc3RhdHVzOjAwMTowMDAf", 42,
                "eb34baf8e7c02c7ee40075d2addd8af30f0ac6c021a8944880b601bcc393cea1", false),
        ]
        let probeCaptures: [IndexObservationContract.ProbeCaptureVector] = [
            probeCapture(1, "HEAD_exact41_success", "HEAD", 0, 0, 0,
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAo=", 41,
                "ca1707f3876e4349bdc0e908e8d1991cef85f75e9521808ebd69f8d4a8f93ca7",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAoecHJpbWVfc3RhdHVzOjAwMDowMDAf", 63,
                "9ec2270a08fdabdb1e5d0c15852aae87250d7e54faec56b1bc801993d67ffcc2", true),
            probeCapture(2, "clean_status_exact0_success", "clean_status", 0, 0, 0,
                "", 0,
                "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==", 22,
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b", true),
            probeCapture(3, "write_tree_exact41_success", "write_tree", 0, 0, 0,
                "NGI4MjVkYzY0MmNiNmViOWEwNjBlNTRiZjhkNjkyODhmYmVlNDkwNAo=", 41,
                "e18e352499e45bbb96e2d3aae6b5069f73b1c8828f6f159571250d13443157ad",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "NGI4MjVkYzY0MmNiNmViOWEwNjBlNTRiZjhkNjkyODhmYmVlNDkwNAoecHJpbWVfc3RhdHVzOjAwMDowMDAf", 63,
                "520c6176188614e9a0584e98402ee8467fb6503cb3f6f4b90a60f04bbf6255ef", true),
            probeCapture(4, "HEAD_git_diagnostic_and_nonzero_rejected", "HEAD", 1, 0, 0,
                "ZmF0YWwK", 6,
                "51c68904e50a93405196aeedb03f85d5b6f092ddd2c57e04adafdebf0703cc08",
                "HnByaW1lX3N0YXR1czowMDE6MDAwHw==",
                "0899433b330bcf623102c1324b4f0737edb5dcbffa29165e97b46c557e9010fe",
                "ZmF0YWwKHnByaW1lX3N0YXR1czowMDE6MDAwHw==", 28,
                "a106c3087f2d81af3780d35488e9ccdc90ca504999d0ec59224c9f658fc06536", false),
            probeCapture(5, "clean_status_one_byte_dirty_rejected", "clean_status", 0, 0, 0,
                "Pw==", 1,
                "8a8de823d5ed3e12746a62ef169bcf372be0ca44f0a1236abc35df05d96928e1",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "Px5wcmltZV9zdGF0dXM6MDAwOjAwMB8=", 23,
                "3ef2e0f2495af8635179f05f9dcd8ffbf779a60ab55b779f465dd4dc99d0852c", false),
            probeCapture(6, "write_tree_body_at_cap42_rejected", "write_tree", 0, 0, 0,
                "NGI4MjVkYzY0MmNiNmViOWEwNjBlNTRiZjhkNjkyODhmYmVlNDkwNApY", 42,
                "e3945ef90453c9a1816feabaeff608138cbe638475b66ca8621bed049ab06c96",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "NGI4MjVkYzY0MmNiNmViOWEwNjBlNTRiZjhkNjkyODhmYmVlNDkwNApYHnByaW1lX3N0YXR1czowMDA6MDAwHw==", 64,
                "763082930f33c8d8af0fc40a60bb2944e2826af56bf8199c81cf15781adf6665", false),
            probeCapture(7, "HEAD_consumer_nonzero_rejected", "HEAD", 0, 1, 0,
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAo=", 41,
                "ca1707f3876e4349bdc0e908e8d1991cef85f75e9521808ebd69f8d4a8f93ca7",
                "HnByaW1lX3N0YXR1czowMDA6MDAxHw==",
                "3d71762bce20b07c11c7f6826ed16126f89cedf7ee1c361a6a2bbc3e4c63c830",
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAoecHJpbWVfc3RhdHVzOjAwMDowMDEf", 63,
                "166fc115f1c94def1cca45b3ec765806625e6674268ca3c09cb8d205e54b64c1", false),
            probeCapture(8, "HEAD_malformed_status_trailer_rejected", "HEAD", 0, 0, 0,
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAo=", 41,
                "ca1707f3876e4349bdc0e908e8d1991cef85f75e9521808ebd69f8d4a8f93ca7",
                "HnByaW1lX3N0YXR1WDowMDA6MDAwHw==",
                "3f3cb30cb51216f8ea28200d5ccd82f7256996017827a9ba97d5fc9eaa8f02d1",
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAoecHJpbWVfc3RhdHVYOjAwMDowMDAf", 63,
                "35b4007f54b3ba61f46ee87bcb7372c7e9a2f09f2b4370afbf946d5c498da8cc", false),
            probeCapture(9, "HEAD_outer_substitution_nonzero_rejected", "HEAD", 0, 0, 1,
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAo=", 41,
                "ca1707f3876e4349bdc0e908e8d1991cef85f75e9521808ebd69f8d4a8f93ca7",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAoecHJpbWVfc3RhdHVzOjAwMDowMDAf", 63,
                "9ec2270a08fdabdb1e5d0c15852aae87250d7e54faec56b1bc801993d67ffcc2", false),
            probeCapture(10, "HEAD_exact41_producer_nonzero_isolated_rejected", "HEAD", 1, 0, 0,
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAo=", 41,
                "ca1707f3876e4349bdc0e908e8d1991cef85f75e9521808ebd69f8d4a8f93ca7",
                "HnByaW1lX3N0YXR1czowMDE6MDAwHw==",
                "0899433b330bcf623102c1324b4f0737edb5dcbffa29165e97b46c557e9010fe",
                "Nzg2MjVlOTNlNzk5MTMyNjljNDM0MTJiMjBjZDM2MGY0MmI1MzUzNAoecHJpbWVfc3RhdHVzOjAwMTowMDAf", 63,
                "521f622b7cc90b9c0e0b61db855e18287c9b779ec55ae8260e047230dd82a723", false),
            probeCapture(11, "clean_status_post_raw_alternate_tree_prefix_A_rejected", "clean_status", 0, 0, 0,
                "QQ==", 1,
                "559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd",
                "HnByaW1lX3N0YXR1czowMDA6MDAwHw==",
                "5c90f0488321c5c2f0ff79828eff2b4304be3954a381e8c14db91aebaf39ee8b",
                "QR5wcmltZV9zdGF0dXM6MDAwOjAwMB8=", 23,
                "afa2732b50f82de3143965b7617b8b51d0b5d2c37e6725b28bef8340474dfead", false),
        ]
        let flatGuards = flatGuardMappings()
        let relationGuards = relationGuardMappings()
        let inventory = objects.map {
            FixtureInventoryRow(
                ordinal: $0.ordinal,
                fixtureID: $0.fixtureID,
                literalObjectOID: $0.literalObjectOID,
                expectedPresent: $0.expectedDestinationInventoryPresent,
                expectedExactPreprobeLine:
                    "\($0.fixtureID)\t\($0.literalObjectOID)\t"
                    + ($0.expectedDestinationInventoryPresent
                        ? "present\n" : "missing\n"),
                expectedExactGitBatchCheckLine:
                    $0.literalObjectOID + ($0.expectedDestinationInventoryPresent
                        ? " \($0.objectType) \($0.payloadByteCount)\n"
                        : " missing\n"))
        }
        let valueFixtures: [ValueDomainFixture] = [
            .init(
                ordinal: 1,
                fixtureID: "merge_equals_fixed_parent",
                constructionKind: "pure_invocation_value_domain",
                exactCondition:
                    "literal_merge_oid_equals_fixed_parent1_oid",
                rawGitFixtureClaimed: false,
                expectedResultCode: "TOPOLOGY_INVOCATION_INVALID",
                expectedFirstFailedGuardID:
                    "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids"),
            .init(
                ordinal: 2,
                fixtureID: "merge_equals_ordinary_request_literal",
                constructionKind: "pure_invocation_value_domain",
                exactCondition:
                    "literal_merge_oid_equals_one_ordinary_literal_commit_oid",
                rawGitFixtureClaimed: false,
                expectedResultCode: "TOPOLOGY_INVOCATION_INVALID",
                expectedFirstFailedGuardID:
                    "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids"),
            .init(
                ordinal: 3,
                fixtureID: "discovered_child_equals_merge",
                constructionKind:
                    "pure_post_parse_value_domain_not_fake_git_sha1_fixed_point_fixture",
                exactCondition:
                    "safely_parsed_parent2_oid_equals_literal_merge_oid",
                rawGitFixtureClaimed: false,
                expectedResultCode: "TOPOLOGY_MISMATCH",
                expectedFirstFailedGuardID:
                    "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids"),
            .init(
                ordinal: 4,
                fixtureID: "current_index_marker_repeated",
                constructionKind: "pure_invocation_value_domain",
                exactCondition:
                    "zero_operand_current_index_marker_occurs_twice",
                rawGitFixtureClaimed: false,
                expectedResultCode: "TOPOLOGY_INVOCATION_INVALID",
                expectedFirstFailedGuardID:
                    "expected_parent_count_within_bound"),
            .init(
                ordinal: 5,
                fixtureID: "both_terminal_markers_present",
                constructionKind: "pure_invocation_value_domain",
                exactCondition:
                    "current_index_marker_and_relation_suffix_both_present",
                rawGitFixtureClaimed: false,
                expectedResultCode: "TOPOLOGY_INVOCATION_INVALID",
                expectedFirstFailedGuardID:
                    "expected_parent_count_within_bound"),
            .init(
                ordinal: 6,
                fixtureID: "current_index_marker_has_surplus",
                constructionKind: "pure_invocation_value_domain",
                exactCondition:
                    "one_token_follows_zero_operand_terminal_current_index_marker",
                rawGitFixtureClaimed: false,
                expectedResultCode: "TOPOLOGY_INVOCATION_INVALID",
                expectedFirstFailedGuardID:
                    "expected_parent_count_within_bound"),
        ]

        let cases: [RelationOntologyCase] = [
            ontology(1, "pull_request_direct_child_verified", "private_sha1_repository", "pull_request", false,
                ["valid_child"], nil, nil, "ordinary_success_zero_body", nil,
                "current_exact_revision_tree_is_index_tree_and_sole_parent_is_fixed", "TOPOLOGY_VERIFIED", nil, nil, nil, nil,
                0, 0, 0, 1, "pull_request_current_is_direct_child", true, 1),
            ontology(2, "pull_request_wrong_parent_rejected", "private_sha1_repository", "pull_request", false,
                ["unrelated"], nil, nil, nil, nil,
                "current_exact_revision_has_zero_parents_instead_of_sole_fixed", "TOPOLOGY_MISMATCH", "ordered_parent_oids_equal_expected", nil, 1, nil,
                0, 0, 0, 1, "pull_request_current_is_direct_child", true, 1),
            ontology(3, "push_relation_verified", "private_sha1_repository", "push", true,
                ["fixed_parent"], "valid_relation_merge", "valid_child", "relation_success_exact_witness", nil,
                "merge_and_child_each_match_index_tree_with_fixed_then_child_and_child_sole_fixed", "TOPOLOGY_VERIFIED", nil, nil, nil, 0,
                1, 1, 1, 1, "ordered_merge_child_relation", true),
            ontology(4, "merge_equals_fixed_rejected_before_git", "pure_value_domain", "push", true,
                ["unrelated"], nil, nil, nil, "merge_equals_fixed_parent",
                "merge_literal_equals_fixed_parent", "TOPOLOGY_INVOCATION_INVALID", "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids", nil, 2, nil,
                0, 0, 0, 0, "merge_differs_from_fixed", false),
            ontology(5, "merge_equals_explicit_rejected_before_git", "pure_value_domain", "push", true,
                ["unrelated"], nil, nil, nil, "merge_equals_ordinary_request_literal",
                "merge_literal_equals_explicit_requested_object_literal", "TOPOLOGY_INVOCATION_INVALID", "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids", nil, 2, nil,
                0, 0, 0, 0, "merge_differs_from_explicit_literals", false),
            ontology(6, "relation_role_collision_rejected_before_git", "pure_invocation", "push", true,
                ["fixed_parent"], nil, nil, nil, nil,
                "current_exact_revision_merge_role_is_reused_by_an_explicit_request", "TOPOLOGY_INVOCATION_INVALID", "request_roles_are_unique", nil, 2, nil,
                0, 0, 0, 0, "relation_roles_unique", false),
            ontology(7, "relation_total_object_count_nine_rejected_before_git", "pure_invocation", "push", true,
                Array(repeating: "fixed_parent", count: 7), nil, nil, nil, nil,
                "seven_explicit_plus_two_implicit_objects_equals_nine", "TOPOLOGY_INVOCATION_INVALID", "verification_request_count_within_bound", nil, nil, nil,
                0, 0, 0, 0, "relation_total_object_bound", false),
            ontology(8, "wave1_missing_merge_stops_all_raw", "direct_component_harness", "push", true,
                ["fixed_parent"], "withheld_child", nil, nil, nil,
                "the_exact_recomputed_merge_commit_bytes_are_intentionally_withheld_from_the_component_repository_and_the_live_preprobe_reports_that_literal_oid_missing", "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability", "current_exact_revision", 2, nil,
                0, 0, 0, 0, "wave1_merge_available", true),
            ontology(9, "malformed_merge_emits_no_witness", "private_sha1_repository", "push", true,
                ["fixed_parent"], "malformed_relation_merge", nil, "relation_structural_failure_zero_body", nil,
                "parent_header_after_author_is_not_contiguous", "TOPOLOGY_HEADER_MALFORMED", "ordered_parent_headers_are_contiguous", nil, 2, 32,
                1, 0, 0, 1, "relation_header_structurally_valid", true),
            ontology(10, "one_parent_merge_is_terminal_without_child", "private_sha1_repository", "push", true,
                ["fixed_parent"], "valid_child", nil, "relation_zero_or_one_parent_terminal", nil,
                "relation_merge_has_only_one_parent_and_no_safe_parent2", "TOPOLOGY_MISMATCH", "ordered_parent_oids_equal_expected", nil, 2, 42,
                1, 0, 0, 1, "relation_merge_has_parent2", true),
            ontology(11, "merge_wrong_tree_isolated", "direct_component_harness", "push", true,
                ["fixed_parent"], "wrong_tree_relation_merge", "valid_child", "relation_tree_mismatch_deferred", nil,
                "merge_has_alternate_tree_but_exact_fixed_then_valid_child", "TOPOLOGY_MISMATCH", "tree_oid_equals_expected", nil, 2, 41,
                1, 1, 1, 0, "merge_tree_equals_index", true),
            ontology(12, "child_wrong_tree_isolated", "private_sha1_repository", "push", true,
                ["fixed_parent"], "wrong_tree_child_merge", "wrong_tree_child", nil, nil,
                "merge_is_valid_and_child_has_alternate_tree_with_correct_sole_fixed_parent", "TOPOLOGY_MISMATCH", "tree_oid_equals_expected", nil, 3, 0,
                1, 1, 1, 1, "child_tree_equals_index", true),
            ontology(13, "merge_wrong_first_parent_isolated", "private_sha1_repository", "push", true,
                ["fixed_parent"], "wrong_first_parent_relation_merge", "valid_child", "relation_parent_mismatch_deferred", nil,
                "merge_parent1_is_unrelated_while_parent2_is_distinct_valid_child", "TOPOLOGY_MISMATCH", "ordered_parent_oids_equal_expected", nil, 2, 42,
                1, 1, 1, 1, "merge_ordered_parents_equal_fixed_then_child", true),
            ontology(14, "child_wrong_parent_isolated", "private_sha1_repository", "push", true,
                ["fixed_parent"], "wrong_parent_child_merge", "wrong_parent_child", nil, nil,
                "merge_is_valid_and_child_tree_matches_but_sole_parent_is_unrelated", "TOPOLOGY_MISMATCH", "ordered_parent_oids_equal_expected", nil, 3, 0,
                1, 1, 1, 1, "child_ordered_parents_equal_sole_fixed", true),
            ontology(15, "three_parent_merge_discovers_child_then_rejects", "private_sha1_repository", "push", true,
                ["fixed_parent"], "three_parent_relation_merge", "valid_child", "relation_parent_mismatch_deferred", nil,
                "structurally_valid_three_parent_merge_emits_parent2_and_defers_count_mismatch", "TOPOLOGY_MISMATCH", "ordered_parent_oids_equal_expected", nil, 2, 42,
                1, 1, 1, 1, "merge_has_exactly_two_ordered_parents", true),
            ontology(16, "duplicate_fixed_parent_child_rejected_before_child_preprobe", "private_sha1_repository", "push", true,
                ["unrelated"], "duplicate_fixed_parent_relation_merge", nil, "relation_duplicate_fixed_parent_exact_witness", nil,
                "raw_merge_has_duplicate_parent_lines_tree_matches_count_is_two_and_parent1_is_fixed_so_classifier_status0_witness_is_then_rejected_by_phase36", "TOPOLOGY_MISMATCH", "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids", nil, 3, 0,
                1, 0, 0, 1, "child_differs_from_fixed", true),
            ontology(17, "discovered_child_equal_explicit_literal_rejected", "private_sha1_repository", "push", true,
                ["fixed_parent", "valid_child"], "valid_relation_merge", nil, nil, nil,
                "safe_parent2_equals_the_second_ordinary_requested_object_literal", "TOPOLOGY_MISMATCH", "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids", nil, 4, 0,
                1, 0, 0, 1, "child_differs_from_explicit_literals", true),
            ontology(18, "discovered_child_equal_merge_rejected_truthfully", "pure_value_domain", "push", true,
                ["fixed_parent"], nil, nil, nil, "discovered_child_equals_merge",
                "post_parse_value_domain_has_parent2_equal_merge_without_claiming_sha1_fixed_point_bytes", "TOPOLOGY_MISMATCH", "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids", nil, 3, nil,
                0, 0, 0, 0, "child_differs_from_merge", false),
            ontology(19, "withheld_discovered_child_is_exactly_missing", "private_sha1_repository", "push", true,
                ["fixed_parent"], "missing_child_relation_merge", "withheld_child", "relation_success_withheld_child_witness", nil,
                "merge_witness_names_recomputed_child_bytes_that_inventory_proves_withheld", "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability", "current_reviewed_child", 3, 0,
                1, 1, 0, 1, "discovered_child_available", true),
            ontology(20, "exit28_partial_prefix_never_becomes_child", "pure_capture", "push", true,
                ["fixed_parent"], "valid_relation_merge", nil, "relation_exit28_forty_byte_prefix", nil,
                "exit28_body_is_exact_40_byte_prefix_but_is_never_consumed", "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact", nil, 2, 28,
                0, 0, 0, 0, "relation_frame_exact_and_usable", false),
            ontology(21, "uppercase_relation_witness_rejected", "pure_capture", "push", true,
                ["fixed_parent"], "valid_relation_merge", nil, "relation_success_uppercase_body_rejected", nil,
                "status0_body_is_not_exact_lowercase40hex_plus_lf", "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact", nil, 2, 0,
                0, 0, 0, 0, "relation_frame_exact_and_usable", false),
            ontology(22, "wave2_phase15_outweighs_earlier_explicit_raw_failure", "private_repository_with_transport_injection", "push", true,
                ["fixed_parent"], "missing_child_relation_merge", "withheld_child", "relation_success_withheld_child_witness", nil,
                "relation_wave1_phases14_through19_pass_then_explicit_phase20_transport_failure_and_safe_merge_witness_are_collected_then_child_relation_phase15_missing_wins", "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability", "current_reviewed_child", 3, 0,
                1, 1, 0, 0, "two_wave_phase_major_selection", true),
            ontology(23, "post_index_change_emits_zero_helper_records", "external_gate_admission", "push", true,
                ["fixed_parent"], "valid_relation_merge", "valid_child", nil, nil,
                "helper_post_clean_or_HEAD_or_write_tree_differs_after_raw_observation", "EXTERNAL_ADMISSION_FAILURE", nil, nil, nil, 0,
                1, 1, 1, 0, "index_and_HEAD_stable_through_helper", true),
            ontology(24, "workflow_dispatch_terminates_before_relation_call", "external_gate_admission", "workflow_dispatch", false,
                [], nil, nil, nil, nil,
                "workflow_dispatch_is_not_an_admitted_relation_event", "EXTERNAL_ADMISSION_FAILURE", nil, nil, nil, nil,
                0, 0, 0, 0, "event_kind_admitted", false),
            ontology(25, "present_blob_discovered_child_is_not_commit", "private_sha1_repository", "push", true,
                ["fixed_parent"], "blob_child_relation_merge", "present_noncommit_blob", nil, nil,
                "safe_parent2_names_the_inventory_present_exact_blob_object", "TOPOLOGY_OBJECT_NOT_COMMIT", "required_object_type_commit", nil, 3, 0,
                1, 1, 0, 1, "discovered_child_is_commit", true),
            ontology(26, "signed_relation_merge_extracts_same_witness", "private_sha1_repository", "push", true,
                ["fixed_parent"], "signed_relation_merge", "valid_child", "relation_success_exact_witness", nil,
                "attached_gpgsig_continuations_are_grammar_only_and_parent2_is_unchanged", "TOPOLOGY_VERIFIED", nil, nil, nil, 0,
                1, 1, 1, 1, "signed_header_continuations_preserve_relation", true),
            ontology(27, "wrong_tree_one_parent_selects_tree_without_witness", "direct_component_harness", "push", true,
                ["fixed_parent"], "wrong_tree_child", nil, "relation_tree_mismatch_without_parent2", nil,
                "structurally_valid_one_parent_relation_has_wrong_tree_and_no_parent2_so_status41_body0", "TOPOLOGY_MISMATCH", "tree_oid_equals_expected", nil, 2, 41,
                1, 0, 0, 0, "tree_guard_precedes_parent_guard_without_parent2", true),
            ontology(28, "hostile_trace_state_fails_before_private_witness", "external_helper_admission", "push", true,
                ["fixed_parent"], "valid_relation_merge", nil, nil, nil,
                "xtrace_or_verbose_or_DEBUG_RETURN_ERR_trap_or_errtrace_functrace_or_BASH_XTRACEFD_or_hostile_PS4_is_present_before_relation_capture", "EXTERNAL_ADMISSION_FAILURE", nil, nil, nil, nil,
                0, 0, 0, 0, "trace_state_admitted", false),
            ontology(29, "legacy_flat_nonHEAD_dirty_repository_remains_legacy", "private_sha1_repository", "legacy_flat_caller", false,
                ["fixed_parent"], nil, nil, "ordinary_success_zero_body", nil,
                "ordinary_request_role_is_current_exact_revision_but_no_marker_or_suffix_exists_so_nonHEAD_dirty_repository_remains_frozen_legacy", "TOPOLOGY_VERIFIED", nil, nil, nil, nil,
                0, 0, 0, 1, "legacy_flat_without_marker_unchanged", true),
            ontology(30, "current_index_marker_repeated_rejected", "pure_value_domain", "pull_request", false,
                ["valid_child"], nil, nil, nil, "current_index_marker_repeated",
                "zero_operand_current_index_marker_occurs_twice", "TOPOLOGY_INVOCATION_INVALID", "expected_parent_count_within_bound", nil, nil, nil,
                0, 0, 0, 0, "current_index_marker_at_most_once", false, 2),
            ontology(31, "current_index_and_relation_markers_rejected", "pure_value_domain", "push", true,
                ["fixed_parent"], nil, nil, nil, "both_terminal_markers_present",
                "zero_operand_current_index_marker_and_relation_suffix_are_both_present", "TOPOLOGY_INVOCATION_INVALID", "expected_parent_count_within_bound", nil, nil, nil,
                0, 0, 0, 0, "terminal_markers_mutually_exclusive", false, 1),
            ontology(32, "current_index_marker_surplus_rejected", "pure_value_domain", "pull_request", false,
                ["valid_child"], nil, nil, nil, "current_index_marker_has_surplus",
                "one_surplus_token_follows_zero_operand_terminal_current_index_marker", "TOPOLOGY_INVOCATION_INVALID", "expected_parent_count_within_bound", nil, nil, nil,
                0, 0, 0, 0, "current_index_marker_is_terminal", false, 1),
            ontology(33, "unknown_classifier_status_with_exact_trailer_rejected", "pure_capture", "push", true,
                ["fixed_parent"], "valid_relation_merge", "valid_child", "relation_unknown_status_with_valid_witness_not_consumed", nil,
                "trailer_is_syntactically_exact_but_classifier_status029_is_not_in_the_closed_known_set", "TOPOLOGY_OBSERVATION_FAILED", "classifier_exit_status_known", nil, 2, 29,
                0, 0, 0, 0, "classifier_exit_status_is_known", false),
            ontology(34, "malformed_private_status_trailer_rejected", "pure_capture", "push", true,
                ["fixed_parent"], "valid_relation_merge", "valid_child", "relation_malformed_trailer_with_valid_witness_not_consumed", nil,
                "bounded_22_byte_trailer_has_wrong_magic_and_is_rejected_before_status_membership_or_body_use", "TOPOLOGY_OBSERVATION_FAILED", "classifier_relation_witness_frame_is_exact", nil, 2, 0,
                0, 0, 0, 0, "relation_status_trailer_frame_is_exact", false),
            ontology(35, "orphan_signed_header_continuation_rejected", "private_sha1_repository", "push", true,
                ["fixed_parent"], "orphan_continuation_relation_merge", nil, "relation_orphan_continuation_status34", nil,
                "tree_two_parents_and_prior_header_predicates_pass_but_space_continuation_is_attached_to_author_not_gpgsig", "TOPOLOGY_HEADER_MALFORMED", "signed_header_continuations_are_allowed_and_attached", nil, 2, 34,
                1, 0, 0, 1, "signed_header_continuations_preserve_relation", true),
            ontology(36, "current_index_marker_nonHEAD_dirty_repository_rejected", "private_sha1_repository", "legacy_flat_caller", false,
                ["fixed_parent"], nil, nil, nil, nil,
                "same_nonHEAD_or_dirty_topology_repository_is_now_explicitly_current_index_activated_by_the_zero_operand_marker", "EXTERNAL_ADMISSION_FAILURE", nil, nil, nil, nil,
                0, 0, 0, 0, "legacy_flat_without_marker_unchanged", false, 1),
            ontology(37, "child_phase15_beats_merge_phase37", "direct_component_harness", "push", true,
                ["fixed_parent"], "wrong_tree_missing_child_relation_merge", "withheld_child", "relation_wrong_tree_withheld_child_witness", nil,
                "merge_tree_mismatch_is_deferred_as_relation_phase37_but_exact_withheld_parent2_fails_child_availability_at_relation_phase15", "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability", "current_reviewed_child", 3, 41,
                1, 1, 0, 0, "child_phase15_outweighs_merge_phase37", true),
            ontology(38, "child_phase17_beats_merge_phase38", "private_sha1_repository", "push", true,
                ["fixed_parent"], "three_parent_blob_child_relation_merge", "present_noncommit_blob", "relation_three_parent_blob_child_witness", nil,
                "merge_three_parent_mismatch_is_deferred_as_relation_phase38_but_inventory_present_blob_parent2_fails_child_commit_type_at_relation_phase17", "TOPOLOGY_OBJECT_NOT_COMMIT", "required_object_type_commit", nil, 3, 42,
                1, 1, 0, 1, "child_phase17_outweighs_merge_phase38", true),
            ontology(39, "relation_explicit_wrong_parent_rejected_after_complete_collection", "private_sha1_repository", "push", true,
                ["unrelated"], "valid_relation_merge", "valid_child", "relation_success_exact_witness", nil,
                "ordinary_explicit_object_is_raw_streamed_in_relation_mode_and_has_zero_parents_instead_of_the_supplied_sole_fixed_parent_while_merge_and_child_pass", "TOPOLOGY_MISMATCH", "ordered_parent_oids_equal_expected", nil, 1, 0,
                1, 1, 1, 1, "relation_explicit_topology_matches_expected", true),
            ontology(40, "alternate_valid_merge_role_missing_is_selected", "direct_component_harness", "push", true,
                ["fixed_parent"], "withheld_child", nil, nil, nil,
                "validated_caller_suffix_merge_role_alternate_merge_role_propagates_to_the_production_selector_missing_role_field", "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability", "alternate_merge_role", 2, nil,
                0, 0, 0, 0, "alternate_valid_merge_role_is_selected_on_missing_merge", true),
            ontology(41, "alternate_valid_child_role_missing_is_projected", "private_sha1_repository", "push", true,
                ["fixed_parent"], "missing_child_relation_merge", "withheld_child", "relation_success_withheld_child_witness", nil,
                "validated_caller_suffix_child_role_alternate_child_role_is_preserved_in_the_missing_child_result", "TOPOLOGY_OBJECT_UNAVAILABLE", "required_object_availability", "alternate_child_role", 3, 0,
                1, 1, 0, 1, "alternate_valid_child_role_is_projected_on_missing_child", true),
        ]

        let proofPairs: [OntologyProofPair] = [
            pair(1, "pr_direct_child", "pull_request_current_is_direct_child", "pull_request_direct_child_verified", "pull_request_wrong_parent_rejected", ["pull_request_current_is_direct_child", "relation_explicit_topology_matches_expected"]),
            pair(2, "merge_not_fixed", "merge_differs_from_fixed", "push_relation_verified", "merge_equals_fixed_rejected_before_git"),
            pair(3, "merge_not_explicit", "merge_differs_from_explicit_literals", "push_relation_verified", "merge_equals_explicit_rejected_before_git"),
            pair(4, "roles_unique", "relation_roles_unique", "push_relation_verified", "relation_role_collision_rejected_before_git"),
            pair(5, "total_bound", "relation_total_object_bound", "push_relation_verified", "relation_total_object_count_nine_rejected_before_git"),
            pair(6, "merge_available", "wave1_merge_available", "push_relation_verified", "wave1_missing_merge_stops_all_raw"),
            pair(7, "header_valid", "relation_header_structurally_valid", "push_relation_verified", "malformed_merge_emits_no_witness", ["relation_header_structurally_valid", "relation_frame_exact_and_usable"]),
            pair(8, "parent2_exists", "relation_merge_has_parent2", "push_relation_verified", "one_parent_merge_is_terminal_without_child", ["relation_merge_has_parent2", "merge_has_exactly_two_ordered_parents", "merge_ordered_parents_equal_fixed_then_child", "relation_frame_exact_and_usable"]),
            pair(9, "merge_tree", "merge_tree_equals_index", "push_relation_verified", "merge_wrong_tree_isolated"),
            pair(10, "child_tree", "child_tree_equals_index", "push_relation_verified", "child_wrong_tree_isolated"),
            pair(11, "merge_parents", "merge_ordered_parents_equal_fixed_then_child", "push_relation_verified", "merge_wrong_first_parent_isolated"),
            pair(12, "child_parent", "child_ordered_parents_equal_sole_fixed", "push_relation_verified", "child_wrong_parent_isolated"),
            pair(13, "child_not_fixed", "child_differs_from_fixed", "push_relation_verified", "duplicate_fixed_parent_child_rejected_before_child_preprobe"),
            pair(14, "child_not_explicit", "child_differs_from_explicit_literals", "push_relation_verified", "discovered_child_equal_explicit_literal_rejected"),
            pair(15, "child_not_merge", "child_differs_from_merge", "push_relation_verified", "discovered_child_equal_merge_rejected_truthfully"),
            pair(16, "witness_frame", "relation_frame_exact_and_usable", "push_relation_verified", "uppercase_relation_witness_rejected"),
            pair(17, "child_commit_type", "discovered_child_is_commit", "push_relation_verified", "present_blob_discovered_child_is_not_commit"),
            pair(18, "signed_header_relation", "signed_header_continuations_preserve_relation", "signed_relation_merge_extracts_same_witness", "orphan_signed_header_continuation_rejected", ["signed_header_continuations_preserve_relation", "relation_header_structurally_valid", "relation_frame_exact_and_usable"]),
            pair(19, "tree_precedes_parent_without_p2", "tree_guard_precedes_parent_guard_without_parent2", "one_parent_merge_is_terminal_without_child", "wrong_tree_one_parent_selects_tree_without_witness", ["tree_guard_precedes_parent_guard_without_parent2", "merge_tree_equals_index"]),
            pair(20, "trace_state_admission", "trace_state_admitted", "push_relation_verified", "hostile_trace_state_fails_before_private_witness"),
            pair(21, "current_marker_once", "current_index_marker_at_most_once", "pull_request_direct_child_verified", "current_index_marker_repeated_rejected"),
            pair(22, "markers_exclusive", "terminal_markers_mutually_exclusive", "pull_request_direct_child_verified", "current_index_and_relation_markers_rejected", ["terminal_markers_mutually_exclusive", "current_index_marker_is_terminal"]),
            pair(23, "current_marker_terminal", "current_index_marker_is_terminal", "pull_request_direct_child_verified", "current_index_marker_surplus_rejected"),
            pair(24, "classifier_status_membership", "classifier_exit_status_is_known", "push_relation_verified", "unknown_classifier_status_with_exact_trailer_rejected", ["classifier_exit_status_is_known", "relation_frame_exact_and_usable"]),
            pair(25, "private_trailer_syntax", "relation_status_trailer_frame_is_exact", "push_relation_verified", "malformed_private_status_trailer_rejected", ["relation_status_trailer_frame_is_exact", "relation_frame_exact_and_usable"]),
            pair(26, "merge_parent_count", "merge_has_exactly_two_ordered_parents", "push_relation_verified", "three_parent_merge_discovers_child_then_rejects", ["merge_has_exactly_two_ordered_parents", "merge_ordered_parents_equal_fixed_then_child"]),
            pair(27, "child_availability", "discovered_child_available", "push_relation_verified", "withheld_discovered_child_is_exactly_missing"),
            pair(28, "two_wave_selection", "relation_has_no_competing_wave2_lower_phase_failure", "push_relation_verified", "wave2_phase15_outweighs_earlier_explicit_raw_failure", ["relation_has_no_competing_wave2_lower_phase_failure", "discovered_child_available"]),
            pair(29, "index_HEAD_stability", "index_and_HEAD_stable_through_helper", "push_relation_verified", "post_index_change_emits_zero_helper_records"),
            pair(30, "event_admission", "event_kind_admitted", "push_relation_verified", "workflow_dispatch_terminates_before_relation_call"),
            pair(31, "legacy_no_marker", "legacy_flat_without_marker_unchanged", "legacy_flat_nonHEAD_dirty_repository_remains_legacy", "current_index_marker_nonHEAD_dirty_repository_rejected"),
            pair(32, "exit28_nonconsumption", "relation_frame_exact_and_usable", "push_relation_verified", "exit28_partial_prefix_never_becomes_child"),
            pair(33, "relation_explicit_stream", "relation_explicit_topology_matches_expected", "push_relation_verified", "relation_explicit_wrong_parent_rejected_after_complete_collection"),
            pair(34, "alternate_merge_role_selector_propagation", "alternate_valid_merge_role_is_selected_on_missing_merge", "alternate_valid_merge_role_missing_is_selected", "wave1_missing_merge_stops_all_raw"),
            pair(35, "alternate_child_role_projection", "alternate_valid_child_role_is_projected_on_missing_child", "alternate_valid_child_role_missing_is_projected", "withheld_discovered_child_is_exactly_missing"),
        ]
        let executionRecipes = exactPrivateRepositoryExecutionRecipes(cases)
        let componentRecipes = exactComponentHarnessRecipes(cases)
        let liveEPIPEMerge = objects.first {
            $0.fixtureID == "valid_relation_merge"
        }!
        let liveEPIPERecipe = DeterministicLiveEPIPERecipe(
            recipeID: "live_relation_witness_F_SETNOSIGPIPE_EPIPE",
            executionKind:
                "future_private_matrix_deterministic_live_classifier_fifo_epipe",
            futureMatrixComponentPath:
                ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
            futureMatrixFunctionName:
                "prime_test_live_relation_classifier_epipe_v1",
            exactFutureMatrixFunctionGrammar:
                "prime_test_live_relation_classifier_epipe_v1 <validated_private_matrix_root> <admitted_classifier_path>",
            exactFutureMatrixCallSiteLiteral:
                "prime_test_live_relation_classifier_epipe_v1 \"${prime_private_matrix_root}\" \"${prime_classifier_path}\"",
            exactFutureMatrixCallSiteCount: 1,
            futurePrivateMatrixInvocationCount: 1,
            publicHelperInvocationCount: 0,
            gateInvocationCount: 0,
            validHelperRecordCount: 0,
            projectionInvocationCount: 0,
            witnessPublicationCount: 0,
            validatedPrivateMatrixRootRequired: true,
            exactUmask: "0077",
            exactAdmittedToolPaths: [
                "/bin/bash", "/bin/rm", "/usr/bin/env", "/usr/bin/mkfifo",
                "/usr/bin/stat",
            ],
            fifoPath:
                "<validated_private_matrix_root>/prime-topology-epipe.fifo",
            fifoLeafASCIIRegex: "^prime-topology-epipe\\.fifo$",
            fifoMustBeAbsentAndFinalComponentNonlinkBeforeCreation: true,
            exactMkfifoArgumentVector: [
                "/usr/bin/mkfifo", "-m", "0600",
                "<validated_private_matrix_root>/prime-topology-epipe.fifo",
            ],
            mkfifoExpectedStatus: 0,
            mkfifoExpectedStdoutByteCount: 0,
            mkfifoExpectedStderrByteCount: 0,
            exactFifoStatArgumentVector: [
                "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/stat",
                "-f", "%u %p %HT", "--",
                "<validated_private_matrix_root>/prime-topology-epipe.fifo",
            ],
            exactFifoStatOutput: "<decimal_effective_uid> 10600 Fifo File\n",
            fifoStatExpectedStatus: 0,
            fifoOwnerMustEqualEffectiveUID: true,
            fifoReaderProcessCount: 1,
            readerOpenDescriptor: 3,
            parentWriterDescriptor: 4,
            exactReaderLaunchGrammar:
                "/bin/bash -p -c 'exec 3<\"$1\"; exec 3<&-' prime-epipe-reader <validated_private_matrix_root>/prime-topology-epipe.fifo",
            exactClassifierLaunchGrammar:
                "exact_in_memory_decoded_valid_relation_merge_payload_to_fd0;fd1_dup_from_parent_fd4;fd2_private_bounded_capture;then_exactClassifierArgumentVector",
            exactHandshakeOrder: [
                "spawn_one_private_bash_reader_that_blocks_opening_fifo_fd3_read_only",
                "parent_opens_fifo_fd4_write_only_unblocking_both_opens",
                "reader_closes_fd3_and_exits_status0_without_reading",
                "parent_waits_reader_and_requires_status0_before_classifier_launch",
                "parent_duplicates_open_fifo_writer_fd4_to_classifier_fd1",
                "classifier_production_fd_closure_closes_inherited_fd4_but_keeps_fd1",
                "classifier_reads_exact_stdin_to_eof_then_F_SETNOSIGPIPE_write_gets_EPIPE",
                "parent_waits_classifier_once_and_requires_status28",
            ],
            readerExpectedStatus: 0,
            readerIsWaitedAndClosedBeforeClassifierLaunch: true,
            zeroFIFOReadersProvedBeforeClassifierLaunch: true,
            classifierStandardOutputDuplicatesWriterDescriptor: true,
            requiredClassifierInheritedFDSubsetBeforeProductionClosure: [0, 1, 2, 4],
            additionalInheritedDescriptorsMayExistAndMustBeClosed: true,
            exactClassifierFinalFDsAfterProductionClosure: [0, 1, 2],
            stdinFixtureID: liveEPIPEMerge.fixtureID,
            stdinFixturePayloadByteCount: liveEPIPEMerge.payloadByteCount,
            stdinFixturePayloadSHA256: liveEPIPEMerge.payloadSHA256,
            exactClassifierArgumentVector: [
                "/usr/bin/env", "-i", "LC_ALL=C",
                "TMPDIR=<validated_private_compiler_root>",
                "<validated_private_compiler_root>/prime-exact-revision-topology-classifier",
                "--ordered-merge-child-relation",
                liveEPIPEMerge.literalObjectOID,
                String(liveEPIPEMerge.payloadByteCount), emptyTree, fixed,
            ],
            exactExpectedClassifierStatus: 28,
            exactExpectedClassifierStdoutBodyByteCount: 0,
            exactExpectedClassifierStderrByteCount: 0,
            expectedStatusPayloadFixtureID: "relation_exit28_empty_prefix",
            exercisesProductionFSETNOSIGPIPEPath: true,
            signalHandlerInstalled: false,
            classifierOrParentShellSIGPIPECount: 0,
            writeReturnsEPIPEBeforeAnyProgress: true,
            exactLogicalWitnessWriteOperationCount: 1,
            classifierWaitStatusCapturedExactlyOnce: true,
            partialPrefixLengthsOneThroughFortyArePureInjectionsOnly: true,
            exactCleanupArgumentVector: [
                "/bin/rm", "-f", "--",
                "<validated_private_matrix_root>/prime-topology-epipe.fifo",
            ],
            cleanupExpectedStatus: 0,
            cleanupInvocationCount: 1,
            noNetwork: true,
            sameEUIDConcurrentMutationInScope: false)
        var hookBindings: [PureTestHookContract.FixtureBinding] = []
        func appendHookBinding(
            registry: String,
            fixtureID: String,
            function: String,
            mode: String,
            submode: String
        ) {
            hookBindings.append(.init(
                ordinal: hookBindings.count + 1,
                fixtureRegistry: registry,
                fixtureID: fixtureID,
                hookFunctionName: function,
                hookMode: mode,
                fixtureSubmode: submode,
                exactInvocationCount: 1
            ))
        }
        for vector in parserVectors {
            appendHookBinding(
                registry: "invocationParserVectors",
                fixtureID: vector.fixtureID,
                function: "prime_test_exact_revision_topology_v1",
                mode: "invocation",
                submode: vector.expectedMode
            )
        }
        for vector in probeCaptures {
            appendHookBinding(
                registry: "indexObservationContract.exactProbeCaptureVectors",
                fixtureID: vector.fixtureID,
                function: "prime_test_exact_revision_topology_v1",
                mode: "probe",
                submode: vector.probeKind
            )
        }
        for fixture in captures {
            appendHookBinding(
                registry: "captureFixtures",
                fixtureID: fixture.fixtureID,
                function: "prime_test_exact_revision_topology_v1",
                mode: "relation_frame",
                submode: fixture.mode
            )
        }
        for ontologyCase in cases {
            appendHookBinding(
                registry: "relationOntologyCases",
                fixtureID: ontologyCase.caseID,
                function: "prime_test_exact_revision_topology_v1",
                mode: "selector",
                submode: ontologyCase.executionKind
            )
        }
        for vector in gateRootCaptures {
            appendHookBinding(
                registry: "gatePrivateRootContract.exactCaptureVectors",
                fixtureID: vector.fixtureID,
                function: "--prime-internal-test-gate-root-capture-v1",
                mode: vector.probeKind,
                submode: "pure_framed_capture_parser_injection"
            )
        }

        let currentPaths = [
            path(1, ".github/scripts/prime-ci-active-root-quarantine.sh", "M", "100755", "bind_pure_relation_amendment_authority"),
            path(2, ".github/workflows/prime-active-root-quarantine.yml", "M", "100644", "run_sole_pure_authority_test"),
            path(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", "M", "100644", "regenerate_exact_authority_provenance"),
            path(4, "Sources/PrimeCore/PrimeExactRevisionTopologyRelationAmendmentAuthority.swift", "A", "100644", "pure_additive_relation_amendment_authority"),
            path(5, "Tests/PrimeCoreTests/PrimeExactRevisionTopologyRelationAmendmentAuthorityTests.swift", "A", "100644", "sole_exhaustive_recursive_codable_test"),
        ]
        let futurePaths = [
            path(1, ".github/scripts/prime-ci-active-root-quarantine.sh", "M", "100755", "source_and_call_shared_relation_verifier"),
            path(2, ".github/scripts/PrimeExactRevisionTopologyClassifier.swift", "A", "100644", "bounded_raw_commit_classifier_with_relation_mode"),
            path(3, ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", "A", "100755", "sole_shared_privileged_verifier"),
            path(4, ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh", "A", "100755", "private_git_and_capture_matrix"),
            path(5, ".github/workflows/prime-active-root-quarantine.yml", "M", "100644", "run_matrix_and_event_specific_gate_calls"),
        ]

        return Self(
            schemaVersion: 1,
            schemaID:
                "prime_exact_revision_topology_relation_amendment_authority_v1",
            authorityID:
                "ergentics_prime_exact_revision_topology_relation_amendment_authority_v1",
            authorityKind:
                "pure_additive_nonselfreferential_exact_revision_ordered_merge_child_relation_authority",
            predecessorExactMainClosure: .init(
                repository: "Ergentics/ergentics-prime",
                ref: "refs/heads/main",
                mergeRevision:
                    "3c40cce6350da7ed0ce0f5ccb0620f76feff0501",
                mergeTree:
                    "f35ea92670fe578b1d5fc6945aa7ab58697dce5a",
                orderedMergeParentOIDs: [
                    "6a811d3029bdb77e038750694fbf10eec0f358f8",
                    "3d2148227d264502010e64a0c0db70bc1362c50c",
                ],
                historyPreservingTwoParentMergeObserved: true,
                githubSignatureVerified: true,
                githubSignatureReason: "valid",
                githubSignatureVerifiedAtFrozen: false,
                githubSignatureVerifiedAt: nil,
                workflowRunID: 32_434_498_068,
                workflowRunNumber: 164,
                workflowRunAttempt: 1,
                workflowPreviousAttemptURL: nil,
                checkSuiteID: 87_927_821_060,
                workflowConclusion: "success",
                activeRootJobID: 96_632_809_709,
                activeRootJobConclusion: "success",
                reviewedMainJobID: 96_633_611_089,
                reviewedMainJobConclusion: "success",
                actionsArtifactCount: 0,
                activeLogByteCount: 363_666,
                activeLogLFByteCount: 1_918,
                activeLogSHA256:
                    "da597b220130b4f46582fbb28412b63d5510da8d0f236e909c3613f98310b8bc",
                reviewedLogByteCount: 10_341_953,
                reviewedLogLFByteCount: 79_079,
                reviewedLogSHA256:
                    "0149f6b4312df9570dbeaf652c9fecd368ca9f9b446b9b2cc14cc1d61d717c4f",
                activeLatinTestCount: 116,
                activeLatinFailureCount: 0,
                rootTestCount: 87,
                isolatedTestCount: 6,
                focusedWholeTestCount: 93,
                retainedLiveTestCount: 46,
                aggregateTestCount: 139,
                aggregateFailureCount: 0,
                aggregateSkipCount: 0,
                predecessorAuthorityTestStartCount: 1,
                predecessorAuthorityTestPassCount: 1,
                predecessorAuthorityTestDurationSeconds: "518.227",
                relationImplementationWasPresent: false,
                relationMechanicsRan: false),
            predecessorAuthorityIdentity: .init(
                schemaID: "prime_exact_revision_topology_verifier_authority_v1",
                authorityID: "ergentics_prime_exact_revision_topology_verifier_authority_v1",
                canonicalByteCount: 410_281,
                canonicalSHA256:
                    "58409182a2be35e7d7874c0b672d4dbf53ab4bd0abc5574cbd598ad8849197d2",
                exactMainRevision:
                    "3c40cce6350da7ed0ce0f5ccb0620f76feff0501",
                exactMainTree:
                    "f35ea92670fe578b1d5fc6945aa7ab58697dce5a",
                exactFileIdentities: [
                    .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitMode: "100755", gitBlob: "f5cb812693e717fb410bd857c7905d1ade3636bd", byteCount: 1_455_095, lfByteCount: 23_331, sha256: "4e84b339d0709e81c0681b1b93b3f3a95a799f82d5758c51ad3898aa68d6f0cc", role: "gate"),
                    .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitMode: "100644", gitBlob: "22066eb8ae7154cdebd3dc688b8c4685c93e0c62", byteCount: 184_404, lfByteCount: 753, sha256: "db374f7eb41b00224b769e2a029020bc01c4ad607275644684398133ec53330a", role: "workflow"),
                    .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitMode: "100644", gitBlob: "15df07ed5cf03ecce50ec4d3a3a5660ec0174ec0", byteCount: 546, lfByteCount: 13, sha256: "2f4c88676f8cd4137ee458770ed44b19750741e230b39407dd38160ca5b6c5e1", role: "provenance"),
                    .init(ordinal: 4, path: "Sources/PrimeCore/PrimeExactRevisionTopologyVerifierAuthority.swift", gitMode: "100644", gitBlob: "f1a92143fc32856bce7bbe785657bdcc75da61fe", byteCount: 260_476, lfByteCount: 4_607, sha256: "4e1a1a4a772f7501e6fcde7116aca8d82f1e164dd09d7965d448ff882e0839b4", role: "predecessor_authority"),
                    .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeExactRevisionTopologyVerifierAuthorityTests.swift", gitMode: "100644", gitBlob: "28cc81db16dfa339d89679c5f23ab9052eeecbbf", byteCount: 63_944, lfByteCount: 1_331, sha256: "630b5b5ba2dee49051b77b52604164189624e71479f1af9aa04058b5e19e8eb7", role: "predecessor_test"),
                ],
                embeddedProvenanceRecordCount: 526,
                embeddedProvenanceSHA256:
                    "73c800516a3a5ac222db9051555dfaf738250ef0a1636dc3b1fd2eacef849ed4",
                authorityPairMustRemainByteIdentical: true,
                authorityPairSuperseded: false,
                ordinaryFlatAPIWithdrawn: false),
            relationAPIContract: .init(
                sourcedFunctionName:
                    "prime_verify_exact_revision_topology_v1",
                ordinaryFlatArgumentGrammar:
                    "<canonical_absolute_repository> <canonical_request_count> (<role> <literal_commit_oid> <expected_tree_oid> <expected_parent_count> <ordered_expected_parent_oids...>){request_count}",
                ordinaryFlatCallsWithoutEitherMarkerRemainAcceptedByteForByte: true,
                existingNoMarkerRoleSemanticsSuperseded: false,
                optionalSuffixMarker:
                    "--ordered-merge-child-relation",
                exactOptionalSuffixGrammar:
                    "--ordered-merge-child-relation <merge_role> <literal_merge_oid> <independently_admitted_index_tree_oid> <fixed_parent1_oid> <child_role>",
                suffixMayOccurAtMostOnce: true,
                suffixMustBeTerminal: true,
                suffixSurplusArgumentsAccepted: false,
                currentIndexMarker: "--current-index-exact-revision",
                exactCurrentIndexMarkerGrammar:
                    "--current-index-exact-revision",
                currentIndexMarkerMayOccurAtMostOnce: true,
                currentIndexMarkerMustBeTerminal: true,
                currentIndexMarkerMutuallyExclusiveWithRelationSuffix: true,
                currentIndexMarkerAddsObjectCount: 0,
                currentIndexMarkerDuplicatesOIDOrTreeOperand: false,
                currentIndexMarkerSelectsExplicitRequestOrdinal: 1,
                currentIndexMarkerFailureGuardID:
                    "expected_parent_count_within_bound",
                ordinaryExplicitRequestMinimum: 1,
                ordinaryExplicitRequestMaximumWithoutRelationSuffix: 8,
                ordinaryExplicitRequestMaximumWithSuffix: 6,
                exactImplicitRelationObjectCount: 2,
                maximumTotalObjectCount: 8,
                exactTotalCountFormula:
                    "ordinary_explicit_request_count_plus_two_implicit_relation_objects",
                mergeAndChildAreAdditionalImplicitObjects: true,
                mergeOrChildAliasesOrdinaryRequestObject: false,
                mergeAndChildAliasEachOther: false,
                fixedParentMayEqualOrdinaryRequestObject: true,
                exactPhysicalOIDDistinctnessRule:
                    "merge_differs_from_fixed_and_every_ordinary_literal_commit_oid;child_differs_from_merge_fixed_and_every_ordinary_literal_commit_oid;fixed_may_equal_an_ordinary_literal",
                explicitAndImplicitRolesMustBeUnique: true,
                roleASCIIGrammar: "^[a-z][a-z0-9_]{0,63}$",
                maximumRoleUTF8ByteCount: 64,
                literalOIDGrammar: "^[0-9a-f]{40}$",
                pullRequestCurrentRole: "current_exact_revision",
                pushMergeRole: "current_exact_revision",
                discoveredChildRole: "current_reviewed_child",
                mergeMissingRoleSource:
                    "validated_caller_suffix_merge_role",
                childMissingRoleSource:
                    "validated_caller_suffix_child_role",
                mergeRelationClassifierModeToken:
                    "--ordered-merge-child-relation",
                mergeRawStreamInvocationCount: 1,
                childRawStreamInvocationCount: 1,
                futureMergeOrChildOIDFrozenHere: false,
                futureImplementationTreeFrozenHere: false,
                exactSupersededPredecessorClauses: [
                    "flat_surplus_rejection_now_allows_only_the_exact_terminal_suffix",
                    "ordinary_classifier_stdout_remains_zero_while_relation_mode_has_the_closed_private_status_payload_union",
                    "all_known_request_preprobes_before_raw_now_adds_one_dependent_child_preprobe_wave_after_safe_discovery",
                    "flat_surplus_rejection_now_also_allows_the_exact_terminal_current_index_marker",
                ],
                exactForbiddenDesigns: [
                    "github_event_before_as_topology_or_parent_fact",
                    "github_event_ref_as_topology_or_parent_fact",
                    "github_event_parent2_as_topology_or_parent_fact",
                    "ref_resolution_for_topology_or_parent_discovery_HEAD_admission_only_is_permitted",
                    "git_history_traversal_merge_base_or_rev_list_discovery",
                    "private_duplicate_commit_header_or_topology_parser",
                    "published_or_durable_parent2_witness",
                    "future_implementation_head_tree_merge_or_run_self_pin_in_this_authority",
                    "workflow_dispatch_relation_admission",
                    "push_main_deferral_or_weakened_exact_main_prerequisite",
                ]),
            eventAdmissionContract: .init(
                admittedEventKinds: ["pull_request", "push"],
                pullRequestCurrentOIDSource:
                    "github.event.pull_request.head.sha",
                pushCurrentOIDSource: "github.sha",
                workflowDispatchPolicy:
                    "terminal_fail_closed_before_any_topology_helper_call",
                workflowDispatchHelperInvocationCount: 0,
                workflowDispatchValidRecordCount: 0,
                pullRequestUsesOrdinaryFlatRequestAndClassifierModePlusCurrentIndexMarker: true,
                pullRequestCurrentRole: "current_exact_revision",
                pullRequestCurrentRequestOccurrenceCount: 1,
                pullRequestCurrentRequestExpectedParentCount: 1,
                pullRequestCurrentRequestExpectedSoleParentSource:
                    "historical_amendment_exact_main_merge_revision_observed_after_external_closure",
                pullRequestExactFunctionArgumentVector: [
                    "prime_verify_exact_revision_topology_v1",
                    "<canonical_repository>",
                    "1",
                    "current_exact_revision",
                    "<github.event.pull_request.head.sha>",
                    "<gate_admitted_index_tree_oid>",
                    "1",
                    "<historical_amendment_exact_main_merge_revision>",
                    "--current-index-exact-revision",
                ],
                pushUsesRelationSuffix: true,
                pushMergeRole: "current_exact_revision",
                pushDiscoveredChildRole: "current_reviewed_child",
                pushExactFunctionArgumentVector: [
                    "prime_verify_exact_revision_topology_v1",
                    "<canonical_repository>",
                    "<canonical_ordinary_request_count_1_through_6>",
                    "<ordinary_flat_requests_1_through_6>",
                    "--ordered-merge-child-relation",
                    "current_exact_revision",
                    "<github.sha>",
                    "<gate_admitted_index_tree_oid>",
                    "<historical_amendment_exact_main_merge_revision>",
                    "current_reviewed_child",
                ],
                activatedCurrentIndexHelperRequiresExactHEADMatchBeforeObservation: true,
                pullRequestHelperBindsRoleLiteralToHEADAndEvent: true,
                pullRequestHelperBindsRoleTreeToAllIndexTrees: true,
                pushHelperBindsMergeLiteralToHEADAndEvent: true,
                pushHelperBindsSuffixTreeToAllIndexTrees: true,
                eventBeforeMaySupplyTopologyFact: false,
                eventRefMaySupplyTopologyFact: false,
                eventParent2MaySupplyTopologyFact: false,
                currentIndexBarrierActivationPredicate:
                    "relation_suffix_is_present_OR_zero_operand_exact_terminal_current_index_marker_selects_ordinary_explicit_request_ordinal1",
                suffixPresentAlwaysActivatesCurrentIndexBarrier: true,
                currentIndexMarkerSelectedExplicitRequestOrdinal: 1,
                currentIndexMarkerFailureGuardID:
                    "expected_parent_count_within_bound",
                noMarkerFlatCallUsesLegacySemanticsForEveryRoleSpelling: true,
                legacyFlatHEADInvocationCount: 0,
                legacyFlatCleanStatusInvocationCount: 0,
                legacyFlatWriteTreeInvocationCount: 0,
                legacyNoMarkerTopologyRepositoryMayBeNonHEADOrDirtyWithoutNewBarrier: true),
            gatePrivateRootContract: .init(
                runnerTempSource:
                    "successor_gate_shall_copy_and_admit_RUNNER_TEMP_once_under_inherited_predecessor_contract_before_constructing_distinct_gate_and_helper_roots",
                successorGateCopiesAndAdmitsRunnerTempOnceUnderPredecessorContract: true,
                runnerTempMaximumUTF8ByteCount: 1_024,
                runnerTempCanonicalAbsoluteOwnedWritableDirectoryNonlink: true,
                runnerTempEnvironmentReadCountAfterAdmission: 0,
                admittedFixedPaths: [
                    "/usr/bin/mktemp", "/usr/bin/stat", "/usr/bin/head",
                    "/usr/bin/env", "/dev/null",
                ],
                exactUmask: "0077",
                exactMktempArgumentVector: [
                    "/usr/bin/mktemp", "-d",
                    "<validated_RUNNER_TEMP>/prime-topology-gate.XXXXXXXX",
                ],
                mktempStderrMergedIntoStdoutBeforeBoundedConsumer: true,
                exactPathConsumerArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "/usr/bin/head", "-c", "1055",
                ],
                pathConsumerStderrSink: "/dev/null",
                pathCapturePipelineProcessCount: 2,
                capturesRunUnderLocallyDisabledErrexit: true,
                exactlyTwoPipelineStatusesCaptured: true,
                pathCaptureStatusesSavedImmediately: true,
                statusesCapturedBeforeAnyBuiltinOrErrexitRestore: true,
                exactPathStatusTrailerNotation:
                    "ASCII_RS + prime_status:DDD:DDD + ASCII_US",
                pathStatusTrailerByteCount: 22,
                maximumPathBodyReadByteCount: 1_055,
                acceptedPathBodyByteCountRange: Array(32 ... 1_054),
                maximumPathCaptureByteCount: 1_077,
                acceptedMktempProducerStatus: 0,
                acceptedPathConsumerStatus: 0,
                outerPathCommandSubstitutionRequiredStatus: 0,
                exactPathPrefix: "<validated_RUNNER_TEMP>/prime-topology-gate.",
                exactLeafASCIIRegex:
                    "^prime-topology-gate\\.[A-Za-z0-9]{8}$",
                pathBodyRequiresExactlyOneTerminalLF: true,
                rootMustBeDirectoryWritableAndFinalComponentNonlink: true,
                exactStatArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/stat",
                    "-f", "%u %p %HT", "--", "<validated_gate_private_root>",
                ],
                exactStatOutputGrammar:
                    "<decimal_effective_uid> 40700 Directory\\n",
                exactStatConsumerArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "/usr/bin/head", "-c", "38",
                ],
                statStderrMergedIntoStdoutBeforeBoundedConsumer: true,
                statConsumerStderrSink: "/dev/null",
                statCapturePipelineProcessCount: 2,
                statCaptureStatusesSavedImmediately: true,
                exactStatStatusTrailerNotation:
                    "ASCII_RS + prime_status:DDD:DDD + ASCII_US",
                statStatusTrailerByteCount: 22,
                acceptedStatProducerStatus: 0,
                acceptedStatConsumerStatus: 0,
                outerStatCommandSubstitutionRequiredStatus: 0,
                maximumStatBodyReadByteCount: 38,
                maximumStatCaptureByteCount: 60,
                expectedStatType: "Directory",
                expectedStatMode: "40700",
                expectedStatOwner: "decimal_effective_uid",
                gateRootDistinctFromHelperCompilerRoot: true,
                gateRootTMPDIRUseScope:
                    "gate_clean_status_and_gate_write_tree_only_not_helper_compiler_or_evidence",
                retainedUntilJobExitAsNonEvidence: true,
                cleanupInvocationCount: 0,
                sameEUIDConcurrentMutationInScope: false,
                anyFailureKind:
                    "external_admission_failure_not_a_topology_result",
                anyFailureValidHelperRecordCount: 0,
                exactCaptureVectors: gateRootCaptures),
            pureTestHookContract: .init(
                gateProductionFunctionName:
                    "prime_gate_admit_private_root_capture_v1",
                exactGateProductionFunctionGrammar:
                    "prime_gate_admit_private_root_capture_v1 <mktemp_path|stat_metadata> <validated_runner_temp> <decimal_euid> <outer_status> <raw_capture_one_nul_free_argv>",
                gateProductionResetsFixedGlobals: true,
                gateProductionUsesSameLiveFramedCaptureParser: true,
                gateProductionClassifiedStatus: 0,
                gateProductionMisuseStatus: 2,
                gateProductionStdoutByteCount: 0,
                gateProductionStderrByteCount: 0,
                gatePrivateProcessEntryToken:
                    "--prime-internal-test-gate-root-capture-v1",
                gatePrivateProcessWorkingDirectory:
                    "<canonical_repository_root>",
                exactGatePrivateProcessEntryGrammar:
                    "/bin/bash -p .github/scripts/prime-ci-active-root-quarantine.sh --prime-internal-test-gate-root-capture-v1 <mktemp_path|stat_metadata> <validated_runner_temp> <decimal_euid> <outer_status> <raw_capture_one_nul_free_argv> <expected_accepted|external_failure> <expected_parsed_value_or_empty>",
                gateRelativeScriptTokenResolvesToAdmittedAbsoluteIdentity: true,
                gateEntryRunsAfterPrivilegedAndUnsetBootstrap: true,
                normalGateArgumentCount: 0,
                gateEntryExpectedFieldsAreTestOnlyAndNotPassedToProductionParser: true,
                gateEntryMatchStatus: 0,
                gateEntryMismatchOrMisuseStatus: 2,
                gateEntryStdoutByteCount: 0,
                gateEntryStderrByteCount: 0,
                liveGateCapturesUsePrivateTestEntry: false,
                helperHookFunctionName:
                    "prime_test_exact_revision_topology_v1",
                exactHelperHookGrammar:
                    "prime_test_exact_revision_topology_v1 <invocation|probe|relation_frame|selector> <that_modes_exact_arguments>",
                exactHelperHookModes: [
                    "invocation", "probe", "relation_frame", "selector",
                ],
                exactHelperModeGrammars: [
                    "prime_test_exact_revision_topology_v1 invocation <argument_token_count_decimal> <exact_helper_argument_tokens...>",
                    "prime_test_exact_revision_topology_v1 probe <HEAD|clean_status|write_tree> <outer_substitution_status_decimal> <raw_capture_one_nul_free_argv>",
                    "prime_test_exact_revision_topology_v1 relation_frame <ordinary|relation> <outer_substitution_status_decimal> <raw_capture_one_nul_free_argv>",
                    "prime_test_exact_revision_topology_v1 selector <candidate_count> (<phase_decimal> <logical_object_ordinal_or_0> <result_code> <guard_id_or_empty> <missing_role_or_empty>){candidate_count}",
                ],
                exactSelectorTupleGrammar:
                    "<candidate_count> (<phase_decimal> <logical_object_ordinal_or_0> <result_code> <guard_id_or_empty> <missing_role_or_empty>){candidate_count}",
                selectorHookComparesProductionSelectedMissingRoleToExpectedTupleIncludingEmpty:
                    true,
                rawCaptureIsOneNULFreeArgument: true,
                helperHookResetsFixedGlobals: true,
                exactSanitizedHelperGlobalNames: [
                    "PRIME_TEST_MODE",
                    "PRIME_TEST_ACCEPTED",
                    "PRIME_TEST_RESULT_CODE",
                    "PRIME_TEST_GUARD_ID",
                    "PRIME_TEST_PHASE_ORDINAL",
                    "PRIME_TEST_OBJECT_ORDINAL",
                    "PRIME_TEST_CLASSIFIER_STATUS",
                    "PRIME_TEST_CANDIDATE_PRESENT",
                    "PRIME_TEST_MISSING_ROLE",
                ],
                privateCandidateGlobalName:
                    "PRIME_TEST_PRIVATE_CANDIDATE_OID",
                privateCandidateMayBePublished: false,
                traceAdmissionRunsBeforePrivateCandidate: true,
                exactRequiredSharedProductionSymbols: [
                    "prime_parse_exact_revision_topology_invocation_v1",
                    "prime_parse_bounded_status_capture_v1",
                    "prime_select_exact_revision_topology_result_v1",
                    "prime_gate_admit_private_root_capture_v1",
                ],
                copiedParserOrSelectorLogicCount: 0,
                helperHookClassifiedStatus: 0,
                helperHookMisuseStatus: 2,
                helperHookStdoutByteCount: 0,
                helperHookStderrByteCount: 0,
                gitInvocationCount: 0,
                toolInvocationCount: 0,
                filesystemInvocationCount: 0,
                publicHelperRecordCount: 0,
                projectionInvocationCount: 0,
                witnessPublicationCount: 0,
                exactOneHookCallPerFixture: true,
                exactFixtureBindings: hookBindings),
            indexObservationContract: .init(
                cleanEnvironmentPrefix: cleanGit([]),
                exactHEADArgumentVector:
                    cleanGit(["-C", "<repository>", "rev-parse", "--verify", "HEAD"]),
                exactCleanStatusArgumentVector:
                    cleanGit(["-C", "<repository>", "status", "--porcelain=v1", "--untracked-files=all"]),
                exactWriteTreeArgumentVector:
                    cleanGit(["-C", "<repository>", "write-tree"]),
                exactGateCleanStatusArgumentVector:
                    cleanGitAt("<validated_gate_private_root>", [
                        "-C", "<repository>", "status", "--porcelain=v1",
                        "--untracked-files=all",
                    ]),
                exactGateWriteTreeArgumentVector:
                    cleanGitAt("<validated_gate_private_root>", [
                        "-C", "<repository>", "write-tree",
                    ]),
                exactHelperHEADArgumentVector:
                    cleanGitAt("<validated_private_compiler_root>", [
                        "-C", "<repository>", "rev-parse", "--verify", "HEAD",
                    ]),
                exactHelperCleanStatusArgumentVector:
                    cleanGitAt("<validated_private_compiler_root>", [
                        "-C", "<repository>", "status", "--porcelain=v1",
                        "--untracked-files=all",
                    ]),
                exactHelperWriteTreeArgumentVector:
                    cleanGitAt("<validated_private_compiler_root>", [
                        "-C", "<repository>", "write-tree",
                    ]),
                gateAndHelperPrivateRootsAreDistinct: true,
                exactHEADOutputGrammar:
                    "one_lowercase40hex_commit_oid_plus_one_lf",
                exactCleanStatusSuccessOutputByteCount: 0,
                exactWriteTreeOutputGrammar:
                    "one_lowercase40hex_tree_oid_plus_one_lf",
                maximumHEADOutputByteCount: 42,
                maximumCleanStatusOutputByteCount: 1,
                maximumWriteTreeOutputByteCount: 42,
                gateHEADInvocationCount: 0,
                gateCleanStatusInvocationCount: 1,
                gateWriteTreeInvocationCount: 1,
                helperPreHEADInvocationCount: 1,
                helperPreCleanStatusInvocationCount: 1,
                helperPreWriteTreeInvocationCount: 1,
                helperPostHEADInvocationCount: 1,
                helperPostCleanStatusInvocationCount: 1,
                helperPostWriteTreeInvocationCount: 1,
                exactActorOrder: [
                    "gate_admits_trusted_event_literal",
                    "gate_clean_status_zero_then_gate_write_tree_exact41",
                    "gate_starts_bounded_helper_command_substitution",
                    "helper_pre_HEAD_equals_event_literal_then_clean_status_zero_then_write_tree_equals_gate_argument",
                    "helper_runs_frozen_ordinary_explicit_raw_observation_for_current_index_marker_OR_two_wave_raw_relation_observation_for_relation_suffix",
                    "helper_post_HEAD_equals_same_event_literal_then_clean_status_zero_then_write_tree_equals_gate_and_pre_tree",
                    "helper_emits_exactly_one_sanitized_record_only_after_all_post_checks_pass",
                    "gate_capture_completes_after_helper_return",
                    "gate_validates_complete_record_then_projects_once",
                ],
                exactInvocationCountScope:
                    "one_activated_current_index_call_only_relation_suffix_or_exact_current_index_marker_excludes_no_marker_legacy_calls_and_distinct_script_bootstrap_probes",
                allThreeWriteTreeOIDsMustEqual: true,
                bothHelperCleanStatusesRequired: true,
                helperEmitsRecordOnlyAfterPostObservationPasses: true,
                gateCaptureCompletesOnlyAfterHelperReturns: true,
                gateValidatesBeforeProjection: true,
                indexAdmissionFailureValidHelperRecordCount: 0,
                indexAdmissionFailureKind:
                    "external_admission_failure_not_a_topology_result",
                writeTreeIsPureObservation: false,
                writeTreeMayMaterializeTreeObject: true,
                indexTreeIsTopologyFactByItself: false,
                rawMergeAndChildTreesMustEqualIndexTree: true,
                fixedBoundedConsumerPath: "/usr/bin/head",
                fixedDiagnosticSinkPath: "/dev/null",
                consumerAndSinkIdentitiesAdmittedBeforeFirstProbe: true,
                exactHEADConsumerArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "/usr/bin/head", "-c", "42",
                ],
                exactCleanStatusConsumerArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "/usr/bin/head", "-c", "1",
                ],
                exactWriteTreeConsumerArgumentVector: [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "/usr/bin/head", "-c", "42",
                ],
                gitStderrMergedIntoStdoutBeforeBoundedConsumer: true,
                boundedConsumerStderrRedirectedToFixedDiagnosticSink: true,
                probePipelineProcessCount: 2,
                probePipelineRunsUnderLocallyDisabledErrexit: true,
                probePipelineStatusesCapturedImmediately: true,
                probeStatusesCapturedBeforeErrexitRestore: true,
                exactProbeStatusTrailerNotation:
                    "ASCII_RS + prime_status:DDD:DDD + ASCII_US",
                probeStatusTrailerByteCount: 22,
                outerCommandSubstitutionRequiredStatus: 0,
                exactProbeKinds: ["HEAD", "clean_status", "write_tree"],
                exactProbeBodyReadCaps: [42, 1, 42],
                exactAcceptedProbeBodyByteCounts: [41, 0, 41],
                exactMaximumProbeCaptureByteCounts: [64, 23, 64],
                acceptedProbeProducerStatus: 0,
                acceptedProbeConsumerStatus: 0,
                producerOrConsumerStderrPublished: false,
                probeFailureKind:
                    "external_admission_failure_not_a_topology_result",
                probeFailureValidHelperRecordCount: 0,
                exactProbeCaptureVectors: probeCaptures),
            postRawIndexMutationTestSeamContract: .init(
                productionCoreFunctionName:
                    "prime_verify_exact_revision_topology_core_v1",
                publicSourcedFunctionName:
                    "prime_verify_exact_revision_topology_v1",
                matrixOnlyWrapperFunctionName:
                    "prime_test_exact_revision_topology_post_raw_index_mutation_v1",
                exactClosedCoreModes: [
                    "none", "post_raw_read_tree_alternate",
                ],
                publicWrapperCoreMode: "none",
                matrixWrapperCoreMode: "post_raw_read_tree_alternate",
                publicWrapperCallsCoreExactlyOnce: true,
                matrixWrapperCallsCoreExactlyOnce: true,
                internalCoreIsExported: false,
                exactModeBranchCount: 1,
                modeSelectionIsOneStaticClosedCaseBranch: true,
                normalPublicCallsAlwaysUseNone: true,
                mutationCallbackInvocationCount: 0,
                evalInvocationCount: 0,
                sourceInvocationCount: 0,
                environmentHookReadCount: 0,
                globalHookReadCount: 0,
                arbitraryMutationCommandArgumentCount: 0,
                arbitraryMutationPathArgumentCount: 0,
                arbitraryMutationOIDArgumentCount: 0,
                gateMutationSeamInvocationCount: 0,
                mutationModeAdditionalPublicAPIArgumentCount: 0,
                standardVerifierArgumentsForwardedUnchanged: true,
                exactMutationTiming:
                    "once_after_all_raw_outcomes_and_before_first_post_HEAD_probe",
                alternateTreeFixtureID: "alternate_tree",
                exactReadTreeArgumentVector:
                    cleanGitAt("<validated_private_compiler_root>", [
                        "-C", "<private_repository>", "read-tree",
                        alternateTree,
                    ]),
                readTreeExpectedStatus: 0,
                readTreeExpectedStdinByteCount: 0,
                readTreeExpectedStdoutByteCount: 0,
                readTreeExpectedStderrByteCount: 0,
                readTreeInvocationCountInNoneMode: 0,
                readTreeInvocationCountInAlternateMode: 1,
                HEADMutationInvocationCount: 0,
                exactPostHEADBodySource:
                    "unchanged_relation_merge_literal_lowercase40hex_plus_lf_exact41",
                exactPostHEADProbeStatusPair: "000:000",
                postHEADOuterSubstitutionStatus: 0,
                exactPostCleanStatusProbeFixtureID:
                    "clean_status_post_raw_alternate_tree_prefix_A_rejected",
                exactPostCleanStatusBody: "A",
                exactPostCleanStatusProbeStatusPair: "000:000",
                postCleanStatusOuterSubstitutionStatus: 0,
                postWriteTreeInvocationCountAfterStatusFailure: 0,
                expectedExternalAdmissionFailure: true,
                expectedValidHelperRecordCount: 0,
                expectedProjectionInvocationCount: 0,
                futureMatrixComponentPath:
                    ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
                futureMatrixFunctionName:
                    "prime_test_exact_revision_topology_post_raw_index_mutation_v1",
                exactFutureMatrixFunctionGrammar:
                    "prime_test_exact_revision_topology_post_raw_index_mutation_v1 <the_same_exact_shared_helper_arguments>",
                exactFutureMatrixCallSiteLiteral:
                    "prime_test_exact_revision_topology_post_raw_index_mutation_v1 \"${prime_case23_exact_helper_arguments[@]}\"",
                exactFutureMatrixCallSiteCount: 1,
                futurePrivateMatrixInvocationCount: 1),
            preprobeWaveContract: .init(
                wave1Objects:
                    "every_ordinary_explicit_request_in_ordinal_order_then_implicit_merge",
                wave1GuardPhaseRangeInFlatSchedule: Array(13 ... 18),
                wave1GuardPhaseRangeInRelationSchedule: Array(14 ... 19),
                wave1FailureRawStreamCount: 0,
                afterWave1ExactCollection:
                    "collect_all_ordinary_explicit_raw_outcomes_and_the_merge_relation_raw_outcome_without_phase20_plus_early_return",
                flatPhase19OrLaterExplicitFailureCausesEarlyReturn: false,
                relationPhase20OrLaterExplicitFailureCausesEarlyReturn: false,
                safeParent2StillTriggersWave2AfterEarlierRawFailure: true,
                wave2Objects: "exactly_the_safely_discovered_child",
                wave2BeginsOnlyAfterExactWitnessFrame: true,
                wave2GuardPhaseRangeInRelationSchedule: Array(14 ... 19),
                wave2FailureChildRawStreamCount: 0,
                noSafeParent2ChildPreprobeCount: 0,
                noSafeParent2ChildRawStreamCount: 0,
                allEligibleOutcomesCollectedBeforeSelection: true,
                firstFailureOrder:
                    "lexicographically_smallest_guard_phase_ordinal_then_logical_object_ordinal"),
            classifierBuildAdmissionContract: .init(
                existingSelfTestArgumentVector: [
                    "<private_admitted_classifier>", "--self-test",
                ],
                additionalSelfTestArgumentVectorCount: 0,
                expectedStatus: 0,
                expectedStdoutByteCount: 0,
                expectedStderrByteCount: 0,
                sameOrdinaryParserAndClassifierFunctionsCalled: true,
                sameRelationEvaluatorAndWitnessConstructorCalled: true,
                duplicateParserOrConstantsPermitted: false,
                relationWitnessComparedOnlyInMemory: true,
                selfTestStdoutEmitterInvocationCount: 0,
                exactMinimumInternalVectors: [
                    "ordinary_valid_maps_0_plus_body0",
                    "relation_valid_maps_0_plus_exact41_in_memory",
                    "relation_wrong_tree_two_parent_maps_41_plus_same_exact41_in_memory",
                    "relation_wrong_tree_one_parent_maps_41_plus_body0_in_memory",
                    "relation_wrong_parent_or_count_with_safe_parent2_maps_42_plus_exact41_in_memory",
                    "relation_three_parent_maps_42_plus_exact41_in_memory",
                    "relation_structural_malformed_maps_existing_status_plus_body0_in_memory",
                    "relation_one_parent_correct_tree_maps_42_plus_body0_in_memory",
                ],
                liveWriteAndEPIPECoveredBySelfTest: false,
                liveWriteAndEPIPECoveredByPrivateMatrix: true,
                successfulSelfTestRequiredBeforeOrdinaryOrRelationRawStream: true),
            relationClassifierContract: .init(
                sourcePath:
                    ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                ordinaryModePreserved: true,
                relationModeToken: "--ordered-merge-child-relation",
                exactRelationArgumentVector: [
                    "<private_admitted_classifier>",
                    "--ordered-merge-child-relation",
                    "<literal_lowercase40hex_merge_oid>",
                    "<canonical_advertised_decimal_byte_count_0_through_1048576>",
                    "<independently_admitted_lowercase40hex_index_tree_oid>",
                    "<literal_lowercase40hex_fixed_parent1_oid>",
                ],
                exactKnownExitStatuses: [
                    0, 20, 21, 22, 23, 24, 25, 26, 27, 28,
                    30, 31, 32, 33, 34, 41, 42,
                ],
                exactStatusPayloadRules: [
                    .init(ordinal: 1, mode: "ordinary", classifierStatuses: [0, 20, 21, 22, 23, 24, 25, 26, 27, 30, 31, 32, 33, 34, 41, 42], exactEligibility: "every_ordinary_outcome", bodyRule: "exactly_zero_bytes", minimumBodyByteCount: 0, maximumBodyByteCount: 0, bodyMayBecomeChildOID: false, mappedGuardID: nil),
                    .init(ordinal: 2, mode: "relation", classifierStatuses: [0], exactEligibility: "whole_header_structurally_valid_tree_equals_index_parent_count_equals_two_and_parent1_equals_fixed", bodyRule: "exact_parent2_lowercase40hex_plus_lf", minimumBodyByteCount: 41, maximumBodyByteCount: 41, bodyMayBecomeChildOID: true, mappedGuardID: nil),
                    .init(ordinal: 3, mode: "relation", classifierStatuses: [41], exactEligibility: "whole_header_structurally_valid_parent_count_at_least_two_tree_mismatch", bodyRule: "exact_parent2_lowercase40hex_plus_lf", minimumBodyByteCount: 41, maximumBodyByteCount: 41, bodyMayBecomeChildOID: true, mappedGuardID: "tree_oid_equals_expected"),
                    .init(ordinal: 4, mode: "relation", classifierStatuses: [42], exactEligibility: "whole_header_structurally_valid_tree_equals_index_parent_count_at_least_two_and_either_parent_count_not_two_or_parent1_not_fixed", bodyRule: "exact_parent2_lowercase40hex_plus_lf", minimumBodyByteCount: 41, maximumBodyByteCount: 41, bodyMayBecomeChildOID: true, mappedGuardID: "ordered_parent_oids_equal_expected"),
                    .init(ordinal: 5, mode: "relation", classifierStatuses: [41], exactEligibility: "whole_header_structurally_valid_parent_count_below_two_and_tree_mismatch", bodyRule: "exactly_zero_bytes_no_parent2_exists", minimumBodyByteCount: 0, maximumBodyByteCount: 0, bodyMayBecomeChildOID: false, mappedGuardID: "tree_oid_equals_expected"),
                    .init(ordinal: 6, mode: "relation", classifierStatuses: [42], exactEligibility: "whole_header_structurally_valid_parent_count_below_two_tree_matches", bodyRule: "exactly_zero_bytes_no_parent2_exists", minimumBodyByteCount: 0, maximumBodyByteCount: 0, bodyMayBecomeChildOID: false, mappedGuardID: "ordered_parent_oids_equal_expected"),
                    .init(ordinal: 7, mode: "relation", classifierStatuses: [28], exactEligibility: "safe_exact_witness_constructed_then_F_SETNOSIGPIPE_setup_or_single_logical_write_fails", bodyRule: "exact_prefix_length_zero_through_forty_of_intended_parent2_plus_lf_never_consumed", minimumBodyByteCount: 0, maximumBodyByteCount: 40, bodyMayBecomeChildOID: false, mappedGuardID: "classifier_relation_witness_frame_is_exact"),
                    .init(ordinal: 8, mode: "relation", classifierStatuses: [20, 21, 22, 23, 24, 25, 26, 27, 30, 31, 32, 33, 34], exactEligibility: "known_protocol_identity_read_size_or_structural_failure", bodyRule: "exactly_zero_bytes", minimumBodyByteCount: 0, maximumBodyByteCount: 0, bodyMayBecomeChildOID: false, mappedGuardID: nil),
                ],
                usesSamePrivateAdmittedExecutable: true,
                usesSameEmptyEnvironment: true,
                usesSameProcPIDInfoFDClosure: true,
                exactFinalFDSet: [0, 1, 2],
                usesSameSingleLogicalFD0ReadToEOF: true,
                usesSameBoundedDrain: true,
                maximumCommitObjectByteCount: 1_048_576,
                boundedReadLimitByteCount: 1_048_577,
                usesSHA1RawCommitIdentityRebinding: true,
                SHA1Purpose:
                    "repository_native_sha1_commit_storage_identity_rebinding_only_not_security",
                SHA1ClaimsSecurityStrength: false,
                usesSameNULAndHeaderGrammar: true,
                commitMessageParsed: false,
                safeWitnessRequiresBaseFlatHeaderPhaseRange: Array(29 ... 33),
                safeWitnessRequiresRelationHeaderPhaseRange: Array(31 ... 35),
                safeWitnessRequiresActualParentCountAtLeast: 2,
                safeParent2TreeAndParentMismatchesDeferredUntilAfterDiscovery: true,
                discoveredParent2RequiresLowercase40Hex: true,
                exactWitnessGrammar: "^[0-9a-f]{40}\\n$",
                exactWitnessByteCount: 41,
                ordinaryModeStdoutByteCount: 0,
                stderrByteCountEveryOutcome: 0,
                stdoutFcntlCommand:
                    "fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1)",
                signalHandlerInstalled: false,
                exactLogicalWriteOperationCount: 1,
                physicalWriteSyscallInvocationCount:
                    "one_or_more_only_while_every_prior_return_is_minus1_EINTR",
                intendedBlockingWriteByteCount: 41,
                writeRetryCondition:
                    "EINTR_only_before_progress_otherwise_short_zero_or_error_is_terminal_28",
                shortZeroOrErrorWriteExitStatus: 28,
                exit28IsLastFallibleClassifierOutcome: true,
                exit28PrefixEverConsumed: false),
            relationCaptureContract: .init(
                classifierStdoutFilesystemCaptureCount: 0,
                commandSubstitutionCaptureRequired: true,
                pipelineProcessCount: 2,
                pipelineRunsUnderLocallyDisabledErrexit: true,
                pipelineStatusesCapturedImmediately: true,
                statusesCapturedBeforeErrexitRestore: true,
                exactStatusTrailerNotation:
                    "ASCII_RS + prime_status:DDD:DDD + ASCII_US",
                exactStatusTrailerASCIIRegex:
                    "^\\x1eprime_status:[0-9]{3}:[0-9]{3}\\x1f$",
                statusTrailerByteCount: 22,
                maximumBodyByteCount: 41,
                maximumCaptureByteCount: 63,
                witnessTerminalLFPreservedBeforeTrailer: true,
                gitNonzeroHasPrecedence: true,
                rawWitnessPublished: false,
                rawWitnessStoredAsDurableEvidence: false,
                exactFrameGuardID:
                    "classifier_relation_witness_frame_is_exact",
                exactFrameFailureResultCode:
                    "TOPOLOGY_OBSERVATION_FAILED",
                frameCheckedBeforeChildPreprobe: true,
                exit28AdmittedPrefixLengths: Array(0 ... 40),
                exit28AdmittedPrefixLengthCount: 41,
                exit28EveryAdmittedPrefixNeverConsumed: true,
                exit28Exact41BodyRejected: true,
                trailerSyntaxValidatedBeforeClassifierStatusMembership: true,
                unknownClassifierStatusGuardID:
                    "classifier_exit_status_known",
                xtraceAndVerboseDisabledAndVerifiedBeforeWitness: true,
                debugAndReturnTrapsAbsentBeforeWitness: true,
                errTrapAbsentBeforeWitness: true,
                errtraceAndFunctraceDisabledAndVerifiedBeforeWitness: true,
                bashXtraceFDUnsetBeforeWitness: true,
                PS4InfluenceNeutralizedBeforeWitness: true,
                hostileTraceStateFailsBeforeWitnessEntersShellState: true,
                hostileTraceStateValidHelperRecordCount: 0,
                hostileTraceMatrixRequired: true,
                privateWitnessMayAppearInTraceOrStderr: false),
            dependentChildContract: .init(
                childRoleSource: "caller_suffix_child_role",
                childLiteralOIDSource:
                    "validated_exact41_private_relation_witness",
                childPreprobeOccursAfterDistinctnessGuard: true,
                childPreprobeInvocationCountOnSafeDistinctWitness: 1,
                childRawStreamInvocationCountAfterPassingPreprobe: 1,
                childUsesOrdinaryClassifierMode: true,
                childExpectedTreeSource:
                    "independently_admitted_gate_helper_pre_helper_post_equal_index_tree",
                childExpectedParentCount: 1,
                childExpectedSoleParentSource: "fixed_parent1_oid",
                childMissingRoleSource:
                    "validated_caller_suffix_child_role_not_gate_default_literal",
                childTreeFailureGuardID: "tree_oid_equals_expected",
                childParentFailureGuardID:
                    "ordered_parent_oids_equal_expected",
                childObservationUsesCleanGitEnvironment: true,
                childObservationUsesReplacementDisabled: true,
                childObservationUsesLazyFetchDisabled: true,
                childObservationMayUseHistoryTraversal: false),
            resultContract: .init(
                exactOrderedResultCodes: resultCodes,
                resultTaxonomyCount: 10,
                predecessorResultTaxonomyPreserved: true,
                exactFlatGuardMappings: flatGuards,
                exactFlatGuardCount: 35,
                exactRelationGuardMappings: relationGuards,
                exactRelationGuardCount: 38,
                exactNewGuards: [
                    .init(ordinal: 1, guardID: "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids", relationPhaseOrdinal: 3, resultCode: "TOPOLOGY_INVOCATION_INVALID", exactScope: "merge_differs_from_fixed_and_every_ordinary_literal_commit_oid_fixed_may_equal_ordinary_literal"),
                    .init(ordinal: 2, guardID: "classifier_relation_witness_frame_is_exact", relationPhaseOrdinal: 23, resultCode: "TOPOLOGY_OBSERVATION_FAILED", exactScope: "relation_only_exact_mode_status_payload_and_private_trailer_frame"),
                    .init(ordinal: 3, guardID: "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids", relationPhaseOrdinal: 36, resultCode: "TOPOLOGY_MISMATCH", exactScope: "safe_parent2_differs_from_merge_fixed_and_every_ordinary_literal_before_child_preprobe"),
                ],
                phaseMajorThenLogicalObjectOrdinalMinor: true,
                explicitObjectOrdinalFormula: "1_through_N",
                mergeObjectOrdinalFormula: "N_plus_1",
                childObjectOrdinalFormula: "N_plus_2",
                relationPhase14ChildFailureMayOutrankEarlierPhase20OrLaterExplicitFailure: true,
                treeGuardAppliedIndependentlyToMergeAndChild: true,
                parentGuardAppliedIndependentlyToMergeAndChild: true,
                mergePostDiscoveryExpectedOrderedParentsProjection:
                    "[fixed_parent1_oid,discovered_parent2_oid]_projection_after_parent2_is_independently_parsed_not_an_input_expectation",
                childExpectedOrderedParents: "[fixed_parent1_oid]",
                malformedWitnessGuardID:
                    "classifier_relation_witness_frame_is_exact",
                sanitizedRecordSchemaUnchanged: true,
                exactRecordCountAfterCompleteAdmission: 1,
                successReturnStatusUnchanged: 0,
                nonSuccessReturnStatusUnchanged: 1),
            syntheticGitObjectFixtures: objects,
            privateFixtureRepositoryContract: .init(
                objectFormat: "sha1",
                noNetwork: true,
                privateTemporaryRepositoryOnly: true,
                exactWriteAPI:
                    "/usr/bin/git hash-object --literally -t <object_type> -w --stdin",
                exactWrittenFixtureIDs: objects.filter(\.expectedDestinationInventoryPresent).map(\.fixtureID),
                exactWithheldFixtureIDs: objects.filter { !$0.expectedDestinationInventoryPresent }.map(\.fixtureID),
                withheldFixtureWriteInvocationCount: 0,
                exactInventoryRows: inventory,
                exactInventoryArgumentVector: cleanGit([
                    "-C", "<private_repository>",
                    "cat-file", "--batch-check=%(objectname) %(objecttype) %(objectsize)",
                ]),
                inventoryStdinBase64:
                    "NGI4MjVkYzY0MmNiNmViOWEwNjBlNTRiZjhkNjkyODhmYmVlNDkwNAphOGI5NDFmOTc5YzY3NTJkOTU0ZTQ0ZjEyOTg2ZGNkYTlkZDU0NDE3Cjc4NjI1ZTkzZTc5OTEzMjY5YzQzNDEyYjIwY2QzNjBmNDJiNTM1MzQKMmJkNDA2Zjk2NTFlMjM2YWY3OTVkOGRmZTY1YWY0NjI4N2U2NjUzZApiMzFhN2EwNDc1NzIzMTY4NzlkNWY2YmE3ZjUwY2NiMDI3YjI5ZDQwCjcxZjhhMWQwYzlmY2RiNjI4ZGRkMjNmMTJlMzAzOTNmZmVjNTE0YTUKMGViYzY1OWU1MGM5MWEwYmY4NmY3YTk4NDI0MjQyN2FiNjJlY2QzZQoyZWFmZWM1YjQwZTJkYzJjZjZlM2ZiNDc4ZTU2ZmRjNzYwZDUzYjI1CjJmZWY4MDU3NTBkMjllZjMxY2RlNTQxMzNkNTAzMDBlMWI5NjQ5NmUKYzYzMmMxZWRhMmZmNDdiMDEwMzhmZjFiYzhkYTFlMjlmYWEzYTU2YgplNGJlYTEzNzYxZTViYjlkYzRmZTJiYzM0MTY3Mzk0NTYxNWFkZDc1CmM3MGMyNjdhMjYzYWE0YWIzZDdmNDJkMWY1NWZjYjhkZWNhMThmNTMKNTM2ZDE3YTQwYjMyN2JhNjA3NDEzZGFkZGZlZWE1ZmM3YzE3OGEwYQpiYTVmN2VhYzE2NDQ2MmU5N2NmZmQ4ZDk3ZTEyOGNhYTUwYzE5YTZiCmIyM2Y3ZjljZjhmZTQwYTAwZTk1ZDFiNWViM2UyMDM2NmVmMjcxZDYKYjcxNWZjNDBkNGE4ZjAxNGUyYWQwNDk0Mjg5ZmY1N2I0NWU1YjM2MQo0MjY1ZDNjNjFiMTRhMWFmN2ZlNmI5MGU1ZDE3YjNjNzEwODI0YzBkCmU5MDYyMTJhM2ZkM2Q2ZDdjNDRjZDAyMjEzYjliNTA3MDYyZDNiYzIKNzM2NmVlYmM5NzM0OGVlYTc4NDlmNzlkNWQ2YTE3NWQwN2RjNWM4NAplZThjMWVlNDliNDc5OWJiZDE3MDIzMzkxNWE4OTdjMTllM2I1NWUxCmQ3N2YyMzNlZjk2YWJkZWNmNTY3Y2FkNWM1YTkyNTZiNTBhOWFhMWMKOGFiYjQwNjIzNTlhMTQyMTk4N2NjNWNiYjFkYTYyZDBmOWExYWYwNgphM2ExMmY0ZjEzZDg4NWY0MDllMjdjZTg1ZDhiMGM0NjgxMTk5YTlmCjdlNGE1ZWNmZTBiMjJhMDFkZjliODk0NzZmYWVlYzMzYzZiNTM4MzAK",
                inventoryStdinByteCount: 984,
                inventoryStdinSHA256:
                    "b13a6f3708d53441974f6b1442c488c7fba2ecb9d95ab174fdcb12e4d3fc91ed",
                inventoryExpectedStatus: 0,
                inventoryExpectedStdoutBase64:
                    "NGI4MjVkYzY0MmNiNmViOWEwNjBlNTRiZjhkNjkyODhmYmVlNDkwNCB0cmVlIDAKYThiOTQxZjk3OWM2NzUyZDk1NGU0NGYxMjk4NmRjZGE5ZGQ1NDQxNyB0cmVlIDM1Cjc4NjI1ZTkzZTc5OTEzMjY5YzQzNDEyYjIwY2QzNjBmNDJiNTM1MzQgY29tbWl0IDE2MQoyYmQ0MDZmOTY1MWUyMzZhZjc5NWQ4ZGZlNjVhZjQ2Mjg3ZTY2NTNkIGNvbW1pdCAxNTgKYjMxYTdhMDQ3NTcyMzE2ODc5ZDVmNmJhN2Y1MGNjYjAyN2IyOWQ0MCBjb21taXQgMjA4CjcxZjhhMWQwYzlmY2RiNjI4ZGRkMjNmMTJlMzAzOTNmZmVjNTE0YTUgY29tbWl0IDI2NQowZWJjNjU5ZTUwYzkxYTBiZjg2ZjdhOTg0MjQyNDI3YWI2MmVjZDNlIGNvbW1pdCAyMTMKMmVhZmVjNWI0MGUyZGMyY2Y2ZTNmYjQ3OGU1NmZkYzc2MGQ1M2IyNSBjb21taXQgMjY3CjJmZWY4MDU3NTBkMjllZjMxY2RlNTQxMzNkNTAzMDBlMWI5NjQ5NmUgY29tbWl0IDI3MApjNjMyYzFlZGEyZmY0N2IwMTAzOGZmMWJjOGRhMWUyOWZhYTNhNTZiIGNvbW1pdCAyMTUKZTRiZWExMzc2MWU1YmI5ZGM0ZmUyYmMzNDE2NzM5NDU2MTVhZGQ3NSBjb21taXQgMjY5CmM3MGMyNjdhMjYzYWE0YWIzZDdmNDJkMWY1NWZjYjhkZWNhMThmNTMgY29tbWl0IDI3OAo1MzZkMTdhNDBiMzI3YmE2MDc0MTNkYWRkZmVlYTVmYzdjMTc4YTBhIGNvbW1pdCAzMjAKYmE1ZjdlYWMxNjQ0NjJlOTdjZmZkOGQ5N2UxMjhjYWE1MGMxOWE2YiBjb21taXQgMjgyCmIyM2Y3ZjljZjhmZTQwYTAwZTk1ZDFiNWViM2UyMDM2NmVmMjcxZDYgbWlzc2luZwpiNzE1ZmM0MGQ0YThmMDE0ZTJhZDA0OTQyODlmZjU3YjQ1ZTViMzYxIGNvbW1pdCAyNzMKNDI2NWQzYzYxYjE0YTFhZjdmZTZiOTBlNWQxN2IzYzcxMDgyNGMwZCBjb21taXQgMjY5CmU5MDYyMTJhM2ZkM2Q2ZDdjNDRjZDAyMjEzYjliNTA3MDYyZDNiYzIgY29tbWl0IDI3NQo3MzY2ZWViYzk3MzQ4ZWVhNzg0OWY3OWQ1ZDZhMTc1ZDA3ZGM1Yzg0IGNvbW1pdCAzMTUKZWU4YzFlZTQ5YjQ3OTliYmQxNzAyMzM5MTVhODk3YzE5ZTNiNTVlMSBibG9iIDgKZDc3ZjIzM2VmOTZhYmRlY2Y1NjdjYWQ1YzVhOTI1NmI1MGE5YWExYyBjb21taXQgMjcwCjhhYmI0MDYyMzU5YTE0MjE5ODdjYzVjYmIxZGE2MmQwZjlhMWFmMDYgY29tbWl0IDMwMAphM2ExMmY0ZjEzZDg4NWY0MDllMjdjZTg1ZDhiMGM0NjgxMTk5YTlmIGNvbW1pdCAyODQKN2U0YTVlY2ZlMGIyMmEwMWRmOWI4OTQ3NmZhZWVjMzNjNmI1MzgzMCBjb21taXQgMzMxCg==",
                inventoryExpectedStdoutByteCount: 1_234,
                inventoryExpectedStdoutSHA256:
                    "e8ee2d23147581a0769e9bfc37454e50c58809d3f30553a95b09f9a01ef85027",
                inventoryExpectedStderrByteCount: 0,
                inventoryRunsBeforeOntologyCases: true,
                inventoryMustMatchExactly: true),
            privateRepositoryExecutionRecipes: executionRecipes,
            componentHarnessRecipes: componentRecipes,
            deterministicLiveEPIPERecipe: liveEPIPERecipe,
            captureFixtures: captures,
            valueDomainFixtures: valueFixtures,
            invocationParserVectors: parserVectors,
            relationOntologyCases: cases,
            ontologyProofPairs: proofPairs,
            toctouContract: .init(
                admittedSourcePaths: [
                    ".github/scripts/PrimeExactRevisionTopologyClassifier.swift",
                    ".github/scripts/prime-ci-exact-revision-topology-verifier.sh",
                    ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
                ],
                everySourcePathRegularNonlink: true,
                worktreeBlobMustEqualIndexBlob: true,
                compilerUsesAdmittedRelativeTokenAtCanonicalRoot: true,
                gateAndHelperIndexTreesCompared: true,
                helperIndexTreeObservedBeforeAndAfter: true,
                helperCleanStatusObservedBeforeAndAfter: true,
                rawMergeOIDReboundFromExactStream: true,
                rawChildOIDReboundFromExactStream: true,
                replacementObjectsDisabledEverywhere: true,
                lazyFetchDisabledEverywhere: true,
                witnessSanitizedBeforeShellReuse: true,
                witnessMayContainPathRefOrDiagnostic: false,
                relationObjectsAddressedOnlyByLiteralOIDs: true,
                historyTraversalInvocationCount: 0,
                privateDuplicateTopologyParserCount: 0,
                sameEUIDConcurrentMutationInScope: false,
                sameEUIDBoundaryReason:
                    "hostile_concurrent_same_euid_mutation_is_excluded_while_independent_gate_helper_pre_helper_post_index_and_HEAD_admission_plus_raw_SHA1_rebinding_detect_accidental_or_out_of_boundary_change",
                detectedIndexMutationOutcome:
                    "external_admission_failure_with_zero_valid_helper_records",
                detectedObjectTransportMutationOutcome:
                    "TOPOLOGY_OBSERVATION_FAILED",
                retryAfterDetectedMutationAuthorized: false),
            externalClosureRequirement: .init(
                amendmentOwnPRHeadRevisionFrozen: false,
                amendmentOwnPRHeadTreeFrozen: false,
                amendmentOwnMergeRevisionFrozen: false,
                amendmentOwnMergeTreeFrozen: false,
                amendmentOwnExactMainRunFrozen: false,
                externalPRAndExactMainClosureRequiredBeforeImplementation: true,
                futureImplementationFixedParentSource:
                    "signed_historical_exact_main_merge_of_this_amendment_observed_externally_after_merge",
                futureImplementationMayBindHistoricalAmendmentClosure: true,
                futureImplementationMayFreezeItsOwnFutureHeadOrTree: false,
                successorImplementationRequiresNoInterveningMainCommit: true),
            patchContract: .init(
                exactOrderedCurrentPaths: currentPaths,
                exactCurrentPathCount: 5,
                currentModifiedExistingPathCount: 3,
                currentAddedPathCount: 2,
                soleTestClassName:
                    "PrimeExactRevisionTopologyRelationAmendmentAuthorityTests",
                soleTestMethodName:
                    "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
                soleTestExpectedStartCount: 1,
                soleTestExpectedPassCount: 1,
                expectedActiveLatinTestCount: 116,
                expectedRootTestCount: 88,
                expectedIsolatedTestCount: 6,
                expectedFocusedWholeTestCount: 94,
                expectedRetainedLiveTestCount: 46,
                expectedAggregateTestCount: 140,
                expectedEmbeddedProvenanceRecordCount: 528,
                exactOrderedFutureImplementationPaths: futurePaths,
                exactFutureImplementationPathCount: 5,
                futureImplementationExactFiveUnchanged: true,
                existingAuthoritySourcePath:
                    "Sources/PrimeCore/PrimeExactRevisionTopologyVerifierAuthority.swift",
                existingAuthorityTestPath:
                    "Tests/PrimeCoreTests/PrimeExactRevisionTopologyVerifierAuthorityTests.swift",
                existingAuthorityPairMustRemainByteIdentical: true,
                packageManifestMutationAuthorized: false,
                packageLockMutationAuthorized: false,
                dependencyResolutionAuthorized: false),
            staticSourceContracts: [
                .init(ordinal: 1, componentPath: ".github/scripts/PrimeExactRevisionTopologyClassifier.swift", requiredSymbolOrLiteral: "classifyOrderedMergeChildRelation", requiredInvariantOrBranchAnchor: "relation_safe_parent2_requires_base_flat_phases29_through33_equal_relation_phases31_through35", proofKind: "future_swift_AST_and_direct_fixture_matrix"),
                .init(ordinal: 2, componentPath: ".github/scripts/PrimeExactRevisionTopologyClassifier.swift", requiredSymbolOrLiteral: "writeExactRelationWitness", requiredInvariantOrBranchAnchor: "relation_witness_F_SETNOSIGPIPE_EINTR_short_write_exit28", proofKind: "future_swift_AST_live_pipe_and_EPIPE_matrix"),
                .init(ordinal: 3, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", requiredSymbolOrLiteral: "prime_parse_exact_revision_topology_relation_suffix_v1", requiredInvariantOrBranchAnchor: "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids", proofKind: "future_bash_function_delimited_source_and_invocation_matrix"),
                .init(ordinal: 4, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", requiredSymbolOrLiteral: "prime_capture_exact_revision_topology_relation_witness_v1", requiredInvariantOrBranchAnchor: "classifier_relation_witness_frame_is_exact", proofKind: "future_bash_function_delimited_source_and_capture_matrix"),
                .init(ordinal: 5, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", requiredSymbolOrLiteral: "prime_preprobe_exact_revision_topology_objects_v1", requiredInvariantOrBranchAnchor: "relation_two_wave_preprobe_phase14_through19_before_phase20_plus_selection", proofKind: "future_bash_function_delimited_source_and_private_git_matrix"),
                .init(ordinal: 6, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", requiredSymbolOrLiteral: "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids", requiredInvariantOrBranchAnchor: "validated_caller_suffix_child_role_preprobe_occurs_only_after_exact_safe_distinct_witness", proofKind: "future_bash_function_delimited_source_and_value_domain_matrix"),
                .init(ordinal: 7, componentPath: ".github/scripts/prime-ci-active-root-quarantine.sh", requiredSymbolOrLiteral: "current_exact_revision", requiredInvariantOrBranchAnchor: "gate_helper_HEAD2_status3_write_tree3_before_emit_capture_validate_project", proofKind: "future_gate_source_and_event_matrix"),
                .init(ordinal: 8, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh", requiredSymbolOrLiteral: "push_relation_verified", requiredInvariantOrBranchAnchor: "every_relation_ontology_case_capture_fixture_and_object_identity_is_exercised", proofKind: "future_private_sha1_repository_and_pure_matrix"),
                .init(ordinal: 9, componentPath: ".github/workflows/prime-active-root-quarantine.yml", requiredSymbolOrLiteral: "workflow_dispatch", requiredInvariantOrBranchAnchor: "workflow_dispatch_relation_helper_invocation_count_zero", proofKind: "future_workflow_static_event_branch_check"),
                .init(ordinal: 10, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", requiredSymbolOrLiteral: "prime_admit_exact_revision_topology_trace_state_v1", requiredInvariantOrBranchAnchor: "private_parent2_never_enters_xtrace_verbose_DEBUG_RETURN_ERR_errtrace_functrace_BASH_XTRACEFD_or_PS4_output", proofKind: "future_bash_hostile_ambient_trace_matrix"),
                .init(ordinal: 11, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", requiredSymbolOrLiteral: "--current-index-exact-revision", requiredInvariantOrBranchAnchor: "zero_operand_terminal_marker_selects_explicit_request_ordinal1_and_no_marker_flat_calls_are_legacy", proofKind: "future_bash_parser_value_domain_and_nonHEAD_dirty_regression_matrix"),
                .init(ordinal: 12, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh", requiredSymbolOrLiteral: "prime_test_live_relation_classifier_epipe_v1", requiredInvariantOrBranchAnchor: "prime_test_live_relation_classifier_epipe_v1 \"${prime_private_matrix_root}\" \"${prime_classifier_path}\"", proofKind: "future_bash_exact_one_live_FIFO_closed_reader_F_SETNOSIGPIPE_EPIPE_call"),
                .init(ordinal: 13, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh", requiredSymbolOrLiteral: "prime_test_exact_revision_topology_component_harness_v1", requiredInvariantOrBranchAnchor: "prime_component_harness_matrix_exact_call_count_6_cases_8_11_22_27_37_40", proofKind: "future_bash_exact_six_typed_component_recipe_calls_and_step_counter_matrix"),
                .init(ordinal: 14, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier.sh", requiredSymbolOrLiteral: "prime_verify_exact_revision_topology_core_v1", requiredInvariantOrBranchAnchor: "prime_exact_revision_topology_post_raw_mutation_mode_none_or_post_raw_read_tree_alternate", proofKind: "future_bash_one_closed_static_branch_public_none_and_matrix_alternate"),
                .init(ordinal: 15, componentPath: ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh", requiredSymbolOrLiteral: "prime_test_exact_revision_topology_post_raw_index_mutation_v1", requiredInvariantOrBranchAnchor: "prime_test_exact_revision_topology_post_raw_index_mutation_v1 \"${prime_case23_exact_helper_arguments[@]}\"", proofKind: "future_bash_exact_one_post_raw_read_tree_alternate_matrix_call"),
            ],
            authorityCeiling: .init(
                predecessorExactMainClosureEstablished: true,
                predecessorAuthorityIdentityEstablished: true,
                amendmentIsPureData: true,
                amendmentAddsImplementation: false,
                amendmentRunsMechanics: false,
                filesystemReadPerformed: false,
                filesystemWritePerformed: false,
                processExecutionPerformed: false,
                gitExecutionPerformed: false,
                networkExecutionPerformed: false,
                compilerExecutionPerformed: false,
                verifierExecutionPerformed: false,
                fixtureExecutionPerformed: false,
                measurementAuthorityEstablished: false,
                measurementMechanicsPerformed: false,
                confirmationAuthorized: false,
                realCanaryAuthorized: false,
                retryOrRerunAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false,
                futureImplementationScopeNarrowlyAmended: true,
                externalClosureRequired: true),
            exactAuthorizedNextActionIDs: [
                "independent_PRE_FREEZE_review_then_bind_canonical_identity",
                "merge_only_the_pure_amendment_after_exact_PR_green",
                "observe_external_signed_amendment_exact_main_closure",
                "only_then_authorize_the_unchanged_exact_five_implementation_patch",
            ],
            status:
                "PURE_RELATION_AMENDMENT_ONLY_predecessor_run164_green_external_closure_required_no_self_pins_mechanics_measurement_confirmation_or_canary")
    }()

    func canonicalData() throws -> Data {
        try validateExactV1()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 524_288 else {
            throw
                PrimeExactRevisionTopologyRelationAmendmentAuthorityError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw
                PrimeExactRevisionTopologyRelationAmendmentAuthorityError
                .noncanonicalEncoding
        }
        return value
    }

    func validate() throws {
        try validateExactV1()
    }

    func validateExactV1() throws {
        let objectIDs = syntheticGitObjectFixtures.map(\.fixtureID)
        let objectOIDs = syntheticGitObjectFixtures.map(\.literalObjectOID)
        let captureIDs = captureFixtures.map(\.fixtureID)
        let valueIDs = valueDomainFixtures.map(\.fixtureID)
        let parserVectorIDs = invocationParserVectors.map(\.fixtureID)
        let repositoryRecipeIDs = privateRepositoryExecutionRecipes.map(\.recipeID)
        let caseIDs = relationOntologyCases.map(\.caseID)
        let flat = resultContract.exactFlatGuardMappings
        let relation = resultContract.exactRelationGuardMappings
        let falseCeilings = [
            authorityCeiling.amendmentAddsImplementation,
            authorityCeiling.amendmentRunsMechanics,
            authorityCeiling.filesystemReadPerformed,
            authorityCeiling.filesystemWritePerformed,
            authorityCeiling.processExecutionPerformed,
            authorityCeiling.gitExecutionPerformed,
            authorityCeiling.networkExecutionPerformed,
            authorityCeiling.compilerExecutionPerformed,
            authorityCeiling.verifierExecutionPerformed,
            authorityCeiling.fixtureExecutionPerformed,
            authorityCeiling.measurementAuthorityEstablished,
            authorityCeiling.measurementMechanicsPerformed,
            authorityCeiling.confirmationAuthorized,
            authorityCeiling.realCanaryAuthorized,
            authorityCeiling.retryOrRerunAuthorized,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
        ]
        func validatedSuffixRoles(
            _ value: RelationOntologyCase
        ) -> [String] {
            let tokens = value.invocationRecipe.exactHelperArgumentTokens
            guard let marker = tokens.firstIndex(
                of: relationAPIContract.optionalSuffixMarker
            ), marker + 5 < tokens.count
            else { return [] }
            return [tokens[marker + 1], tokens[marker + 5]]
        }
        guard schemaVersion == 1,
              schemaID
                == "prime_exact_revision_topology_relation_amendment_authority_v1",
              authorityID
                == "ergentics_prime_exact_revision_topology_relation_amendment_authority_v1",
              predecessorExactMainClosure.mergeRevision
                == "3c40cce6350da7ed0ce0f5ccb0620f76feff0501",
              predecessorExactMainClosure.mergeTree
                == "f35ea92670fe578b1d5fc6945aa7ab58697dce5a",
              predecessorExactMainClosure.orderedMergeParentOIDs.count == 2,
              predecessorExactMainClosure.orderedMergeParentOIDs
                == [
                    "6a811d3029bdb77e038750694fbf10eec0f358f8",
                    "3d2148227d264502010e64a0c0db70bc1362c50c",
                ],
              predecessorExactMainClosure.githubSignatureVerified,
              predecessorExactMainClosure.githubSignatureReason == "valid",
              !predecessorExactMainClosure.githubSignatureVerifiedAtFrozen,
              predecessorExactMainClosure.githubSignatureVerifiedAt == nil,
              predecessorExactMainClosure.workflowRunNumber == 164,
              predecessorExactMainClosure.workflowRunAttempt == 1,
              predecessorExactMainClosure.workflowPreviousAttemptURL == nil,
              predecessorExactMainClosure.workflowConclusion == "success",
              predecessorExactMainClosure.activeRootJobConclusion == "success",
              predecessorExactMainClosure.reviewedMainJobConclusion == "success",
              predecessorExactMainClosure.actionsArtifactCount == 0,
              predecessorExactMainClosure.activeLatinTestCount == 116,
              predecessorExactMainClosure.aggregateTestCount == 139,
              predecessorExactMainClosure.aggregateFailureCount == 0,
              predecessorExactMainClosure.aggregateSkipCount == 0,
              predecessorExactMainClosure.predecessorAuthorityTestStartCount == 1,
              predecessorExactMainClosure.predecessorAuthorityTestPassCount == 1,
              !predecessorExactMainClosure.relationImplementationWasPresent,
              !predecessorExactMainClosure.relationMechanicsRan,
              predecessorAuthorityIdentity.canonicalByteCount == 410_281,
              isLowercaseHex(predecessorAuthorityIdentity.canonicalSHA256, 64),
              predecessorAuthorityIdentity.exactFileIdentities.count == 5,
              predecessorAuthorityIdentity.exactFileIdentities.map(\.ordinal)
                == Array(1 ... 5),
              predecessorAuthorityIdentity.exactFileIdentities.allSatisfy({
                  isLowercaseHex($0.gitBlob, 40)
                      && isLowercaseHex($0.sha256, 64)
                      && $0.byteCount > 0
                      && $0.lfByteCount > 0
              }),
              predecessorAuthorityIdentity.authorityPairMustRemainByteIdentical,
              !predecessorAuthorityIdentity.authorityPairSuperseded,
              !predecessorAuthorityIdentity.ordinaryFlatAPIWithdrawn,
              relationAPIContract.sourcedFunctionName
                == "prime_verify_exact_revision_topology_v1",
              relationAPIContract.ordinaryFlatCallsWithoutEitherMarkerRemainAcceptedByteForByte,
              !relationAPIContract.existingNoMarkerRoleSemanticsSuperseded,
              relationAPIContract.optionalSuffixMarker
                == "--ordered-merge-child-relation",
              relationAPIContract.currentIndexMarker
                == "--current-index-exact-revision",
              relationAPIContract.exactCurrentIndexMarkerGrammar
                == "--current-index-exact-revision",
              relationAPIContract.currentIndexMarkerMayOccurAtMostOnce,
              relationAPIContract.currentIndexMarkerMustBeTerminal,
              relationAPIContract.currentIndexMarkerMutuallyExclusiveWithRelationSuffix,
              relationAPIContract.currentIndexMarkerAddsObjectCount == 0,
              !relationAPIContract.currentIndexMarkerDuplicatesOIDOrTreeOperand,
              relationAPIContract.currentIndexMarkerSelectsExplicitRequestOrdinal == 1,
              relationAPIContract.currentIndexMarkerFailureGuardID
                == "expected_parent_count_within_bound",
              relationAPIContract.ordinaryExplicitRequestMaximumWithoutRelationSuffix
                == 8,
              relationAPIContract.ordinaryExplicitRequestMaximumWithSuffix
                + relationAPIContract.exactImplicitRelationObjectCount
                == relationAPIContract.maximumTotalObjectCount,
              relationAPIContract.maximumTotalObjectCount == 8,
              relationAPIContract.mergeAndChildAreAdditionalImplicitObjects,
              !relationAPIContract.mergeOrChildAliasesOrdinaryRequestObject,
              !relationAPIContract.mergeAndChildAliasEachOther,
              relationAPIContract.fixedParentMayEqualOrdinaryRequestObject,
              relationAPIContract.explicitAndImplicitRolesMustBeUnique,
              relationAPIContract.pullRequestCurrentRole
                == "current_exact_revision",
              relationAPIContract.pushMergeRole == "current_exact_revision",
              relationAPIContract.discoveredChildRole
                == "current_reviewed_child",
              relationAPIContract.mergeMissingRoleSource
                == "validated_caller_suffix_merge_role",
              relationAPIContract.childMissingRoleSource
                == "validated_caller_suffix_child_role",
              !relationAPIContract.futureMergeOrChildOIDFrozenHere,
              !relationAPIContract.futureImplementationTreeFrozenHere,
              eventAdmissionContract.admittedEventKinds
                == ["pull_request", "push"],
              eventAdmissionContract.workflowDispatchHelperInvocationCount == 0,
              eventAdmissionContract.workflowDispatchValidRecordCount == 0,
              eventAdmissionContract.pullRequestCurrentRequestOccurrenceCount == 1,
              eventAdmissionContract.pullRequestCurrentRole
                == "current_exact_revision",
              eventAdmissionContract.pushMergeRole
                == "current_exact_revision",
              eventAdmissionContract.pushDiscoveredChildRole
                == "current_reviewed_child",
              !eventAdmissionContract.eventBeforeMaySupplyTopologyFact,
              !eventAdmissionContract.eventRefMaySupplyTopologyFact,
              !eventAdmissionContract.eventParent2MaySupplyTopologyFact,
              eventAdmissionContract.suffixPresentAlwaysActivatesCurrentIndexBarrier,
              eventAdmissionContract.currentIndexMarkerSelectedExplicitRequestOrdinal == 1,
              eventAdmissionContract.currentIndexMarkerFailureGuardID
                == "expected_parent_count_within_bound",
              eventAdmissionContract.noMarkerFlatCallUsesLegacySemanticsForEveryRoleSpelling,
              eventAdmissionContract.legacyFlatHEADInvocationCount == 0,
              eventAdmissionContract.legacyFlatCleanStatusInvocationCount == 0,
              eventAdmissionContract.legacyFlatWriteTreeInvocationCount == 0,
              eventAdmissionContract.legacyNoMarkerTopologyRepositoryMayBeNonHEADOrDirtyWithoutNewBarrier,
              gatePrivateRootContract
                .successorGateCopiesAndAdmitsRunnerTempOnceUnderPredecessorContract,
              gatePrivateRootContract.runnerTempMaximumUTF8ByteCount == 1_024,
              gatePrivateRootContract.runnerTempCanonicalAbsoluteOwnedWritableDirectoryNonlink,
              gatePrivateRootContract.runnerTempEnvironmentReadCountAfterAdmission == 0,
              gatePrivateRootContract.admittedFixedPaths == [
                  "/usr/bin/mktemp", "/usr/bin/stat", "/usr/bin/head",
                  "/usr/bin/env", "/dev/null",
              ],
              gatePrivateRootContract.exactUmask == "0077",
              gatePrivateRootContract.exactMktempArgumentVector == [
                  "/usr/bin/mktemp", "-d",
                  "<validated_RUNNER_TEMP>/prime-topology-gate.XXXXXXXX",
              ],
              gatePrivateRootContract.mktempStderrMergedIntoStdoutBeforeBoundedConsumer,
              gatePrivateRootContract.exactPathConsumerArgumentVector == [
                  "/usr/bin/env", "-i", "LC_ALL=C",
                  "/usr/bin/head", "-c", "1055",
              ],
              gatePrivateRootContract.pathConsumerStderrSink == "/dev/null",
              gatePrivateRootContract.pathCapturePipelineProcessCount == 2,
              gatePrivateRootContract.capturesRunUnderLocallyDisabledErrexit,
              gatePrivateRootContract.exactlyTwoPipelineStatusesCaptured,
              gatePrivateRootContract.pathCaptureStatusesSavedImmediately,
              gatePrivateRootContract.statusesCapturedBeforeAnyBuiltinOrErrexitRestore,
              gatePrivateRootContract.pathStatusTrailerByteCount == 22,
              gatePrivateRootContract.maximumPathBodyReadByteCount == 1_055,
              gatePrivateRootContract.acceptedPathBodyByteCountRange
                == Array(32 ... 1_054),
              gatePrivateRootContract.maximumPathCaptureByteCount == 1_077,
              gatePrivateRootContract.acceptedMktempProducerStatus == 0,
              gatePrivateRootContract.acceptedPathConsumerStatus == 0,
              gatePrivateRootContract.outerPathCommandSubstitutionRequiredStatus == 0,
              gatePrivateRootContract.pathBodyRequiresExactlyOneTerminalLF,
              gatePrivateRootContract.rootMustBeDirectoryWritableAndFinalComponentNonlink,
              gatePrivateRootContract.exactStatArgumentVector == [
                  "/usr/bin/env", "-i", "LC_ALL=C", "/usr/bin/stat",
                  "-f", "%u %p %HT", "--", "<validated_gate_private_root>",
              ],
              gatePrivateRootContract.exactStatConsumerArgumentVector == [
                  "/usr/bin/env", "-i", "LC_ALL=C",
                  "/usr/bin/head", "-c", "38",
              ],
              gatePrivateRootContract.statStderrMergedIntoStdoutBeforeBoundedConsumer,
              gatePrivateRootContract.statConsumerStderrSink == "/dev/null",
              gatePrivateRootContract.statCapturePipelineProcessCount == 2,
              gatePrivateRootContract.statCaptureStatusesSavedImmediately,
              gatePrivateRootContract.exactStatStatusTrailerNotation
                == "ASCII_RS + prime_status:DDD:DDD + ASCII_US",
              gatePrivateRootContract.exactStatStatusTrailerNotation
                == gatePrivateRootContract.exactPathStatusTrailerNotation,
              gatePrivateRootContract.statStatusTrailerByteCount == 22,
              gatePrivateRootContract.acceptedStatProducerStatus == 0,
              gatePrivateRootContract.acceptedStatConsumerStatus == 0,
              gatePrivateRootContract.outerStatCommandSubstitutionRequiredStatus == 0,
              gatePrivateRootContract.maximumStatBodyReadByteCount == 38,
              gatePrivateRootContract.maximumStatCaptureByteCount == 60,
              gatePrivateRootContract.expectedStatType == "Directory",
              gatePrivateRootContract.expectedStatMode == "40700",
              gatePrivateRootContract.expectedStatOwner == "decimal_effective_uid",
              gatePrivateRootContract.gateRootDistinctFromHelperCompilerRoot,
              gatePrivateRootContract.retainedUntilJobExitAsNonEvidence,
              gatePrivateRootContract.cleanupInvocationCount == 0,
              !gatePrivateRootContract.sameEUIDConcurrentMutationInScope,
              gatePrivateRootContract.anyFailureValidHelperRecordCount == 0,
              gatePrivateRootContract.exactCaptureVectors.count == 6,
              gatePrivateRootContract.exactCaptureVectors.map(\.ordinal)
                == Array(1 ... 6),
              gatePrivateRootContract.exactCaptureVectors.filter(\.accepted).count == 2,
              gatePrivateRootContract.exactCaptureVectors.allSatisfy({ vector in
                  vector.constructionKind
                    == "pure_framed_capture_parser_injection"
                      && vector.publicGateOrToolInvocationCount == 0
                      && vector.futurePrivateMatrixRequired
                      && Data(base64Encoded: vector.bodyBase64)?.count
                    == vector.bodyByteCount
                      && Data(base64Encoded: vector.trailerBase64)?.count == 22
                      && Data(base64Encoded: vector.captureBase64)?.count
                        == vector.captureByteCount
                      && isLowercaseHex(vector.bodySHA256, 64)
                      && isLowercaseHex(vector.trailerSHA256, 64)
                      && isLowercaseHex(vector.captureSHA256, 64)
                      && vector.expectedSanitizedClassification
                        == (vector.accepted ? "accepted" : "external_failure")
                      && (vector.accepted
                          ? !vector.expectedParsedValue.isEmpty
                          : vector.expectedParsedValue.isEmpty)
              }),
              pureTestHookContract.gateProductionFunctionName
                == "prime_gate_admit_private_root_capture_v1",
              pureTestHookContract.gateProductionResetsFixedGlobals,
              pureTestHookContract.gateProductionUsesSameLiveFramedCaptureParser,
              pureTestHookContract.gateProductionClassifiedStatus == 0,
              pureTestHookContract.gateProductionMisuseStatus == 2,
              pureTestHookContract.gateProductionStdoutByteCount == 0,
              pureTestHookContract.gateProductionStderrByteCount == 0,
              pureTestHookContract.gatePrivateProcessEntryToken
                == "--prime-internal-test-gate-root-capture-v1",
              pureTestHookContract.gatePrivateProcessWorkingDirectory
                == "<canonical_repository_root>",
              pureTestHookContract
                .gateRelativeScriptTokenResolvesToAdmittedAbsoluteIdentity,
              pureTestHookContract.gateEntryRunsAfterPrivilegedAndUnsetBootstrap,
              pureTestHookContract.normalGateArgumentCount == 0,
              pureTestHookContract
                .gateEntryExpectedFieldsAreTestOnlyAndNotPassedToProductionParser,
              pureTestHookContract.gateEntryMatchStatus == 0,
              pureTestHookContract.gateEntryMismatchOrMisuseStatus == 2,
              pureTestHookContract.gateEntryStdoutByteCount == 0,
              pureTestHookContract.gateEntryStderrByteCount == 0,
              !pureTestHookContract.liveGateCapturesUsePrivateTestEntry,
              pureTestHookContract.helperHookFunctionName
                == "prime_test_exact_revision_topology_v1",
              pureTestHookContract.exactHelperHookModes
                == ["invocation", "probe", "relation_frame", "selector"],
              pureTestHookContract.exactHelperModeGrammars == [
                  "prime_test_exact_revision_topology_v1 invocation <argument_token_count_decimal> <exact_helper_argument_tokens...>",
                  "prime_test_exact_revision_topology_v1 probe <HEAD|clean_status|write_tree> <outer_substitution_status_decimal> <raw_capture_one_nul_free_argv>",
                  "prime_test_exact_revision_topology_v1 relation_frame <ordinary|relation> <outer_substitution_status_decimal> <raw_capture_one_nul_free_argv>",
                  "prime_test_exact_revision_topology_v1 selector <candidate_count> (<phase_decimal> <logical_object_ordinal_or_0> <result_code> <guard_id_or_empty> <missing_role_or_empty>){candidate_count}",
              ],
              pureTestHookContract.rawCaptureIsOneNULFreeArgument,
              pureTestHookContract.selectorHookComparesProductionSelectedMissingRoleToExpectedTupleIncludingEmpty,
              pureTestHookContract.helperHookResetsFixedGlobals,
              pureTestHookContract.exactSanitizedHelperGlobalNames == [
                  "PRIME_TEST_MODE",
                  "PRIME_TEST_ACCEPTED",
                  "PRIME_TEST_RESULT_CODE",
                  "PRIME_TEST_GUARD_ID",
                  "PRIME_TEST_PHASE_ORDINAL",
                  "PRIME_TEST_OBJECT_ORDINAL",
                  "PRIME_TEST_CLASSIFIER_STATUS",
                  "PRIME_TEST_CANDIDATE_PRESENT",
                  "PRIME_TEST_MISSING_ROLE",
              ],
              pureTestHookContract.privateCandidateGlobalName
                == "PRIME_TEST_PRIVATE_CANDIDATE_OID",
              !pureTestHookContract.privateCandidateMayBePublished,
              pureTestHookContract.traceAdmissionRunsBeforePrivateCandidate,
              pureTestHookContract.copiedParserOrSelectorLogicCount == 0,
              pureTestHookContract.helperHookClassifiedStatus == 0,
              pureTestHookContract.helperHookMisuseStatus == 2,
              pureTestHookContract.helperHookStdoutByteCount == 0,
              pureTestHookContract.helperHookStderrByteCount == 0,
              pureTestHookContract.gitInvocationCount == 0,
              pureTestHookContract.toolInvocationCount == 0,
              pureTestHookContract.filesystemInvocationCount == 0,
              pureTestHookContract.publicHelperRecordCount == 0,
              pureTestHookContract.projectionInvocationCount == 0,
              pureTestHookContract.witnessPublicationCount == 0,
              pureTestHookContract.exactOneHookCallPerFixture,
              pureTestHookContract.exactFixtureBindings.count == 135,
              pureTestHookContract.exactFixtureBindings.map(\.ordinal)
                == Array(1 ... 135),
              pureTestHookContract.exactFixtureBindings.allSatisfy({ binding in
                  binding.exactInvocationCount == 1
                      && !binding.fixtureID.isEmpty
                      && !binding.fixtureRegistry.isEmpty
                      && !binding.fixtureSubmode.isEmpty
                      && ((binding.fixtureRegistry
                            == "gatePrivateRootContract.exactCaptureVectors"
                          && binding.hookFunctionName
                            == "--prime-internal-test-gate-root-capture-v1"
                          && ["mktemp_path", "stat_metadata"]
                            .contains(binding.hookMode))
                          || (binding.fixtureRegistry
                                != "gatePrivateRootContract.exactCaptureVectors"
                              && binding.hookFunctionName
                                == "prime_test_exact_revision_topology_v1"
                              && pureTestHookContract.exactHelperHookModes
                                .contains(binding.hookMode)))
              }),
              indexObservationContract.exactCleanStatusArgumentVector.suffix(3)
                == ["status", "--porcelain=v1", "--untracked-files=all"],
              indexObservationContract.exactGateCleanStatusArgumentVector
                == Self.cleanGitAt("<validated_gate_private_root>", [
                    "-C", "<repository>", "status", "--porcelain=v1",
                    "--untracked-files=all",
                ]),
              indexObservationContract.exactGateWriteTreeArgumentVector
                == Self.cleanGitAt("<validated_gate_private_root>", [
                    "-C", "<repository>", "write-tree",
                ]),
              indexObservationContract.exactHelperHEADArgumentVector
                == Self.cleanGitAt("<validated_private_compiler_root>", [
                    "-C", "<repository>", "rev-parse", "--verify", "HEAD",
                ]),
              indexObservationContract.exactHelperCleanStatusArgumentVector
                == Self.cleanGitAt("<validated_private_compiler_root>", [
                    "-C", "<repository>", "status", "--porcelain=v1",
                    "--untracked-files=all",
                ]),
              indexObservationContract.exactHelperWriteTreeArgumentVector
                == Self.cleanGitAt("<validated_private_compiler_root>", [
                    "-C", "<repository>", "write-tree",
                ]),
              indexObservationContract.gateAndHelperPrivateRootsAreDistinct,
              indexObservationContract.gateHEADInvocationCount == 0,
              indexObservationContract.gateCleanStatusInvocationCount == 1,
              indexObservationContract.gateWriteTreeInvocationCount == 1,
              indexObservationContract.helperPreHEADInvocationCount == 1,
              indexObservationContract.helperPreCleanStatusInvocationCount == 1,
              indexObservationContract.helperPreWriteTreeInvocationCount == 1,
              indexObservationContract.helperPostHEADInvocationCount == 1,
              indexObservationContract.helperPostCleanStatusInvocationCount == 1,
              indexObservationContract.helperPostWriteTreeInvocationCount == 1,
              indexObservationContract.allThreeWriteTreeOIDsMustEqual,
              indexObservationContract.bothHelperCleanStatusesRequired,
              indexObservationContract.helperEmitsRecordOnlyAfterPostObservationPasses,
              indexObservationContract.gateCaptureCompletesOnlyAfterHelperReturns,
              indexObservationContract.gateValidatesBeforeProjection,
              indexObservationContract.indexAdmissionFailureValidHelperRecordCount == 0,
              !indexObservationContract.writeTreeIsPureObservation,
              indexObservationContract.writeTreeMayMaterializeTreeObject,
              !indexObservationContract.indexTreeIsTopologyFactByItself,
              indexObservationContract.fixedBoundedConsumerPath
                == "/usr/bin/head",
              indexObservationContract.fixedDiagnosticSinkPath == "/dev/null",
              indexObservationContract.consumerAndSinkIdentitiesAdmittedBeforeFirstProbe,
              indexObservationContract.exactHEADConsumerArgumentVector
                == [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "/usr/bin/head", "-c", "42",
                ],
              indexObservationContract.exactCleanStatusConsumerArgumentVector
                == [
                    "/usr/bin/env", "-i", "LC_ALL=C",
                    "/usr/bin/head", "-c", "1",
                ],
              indexObservationContract.exactWriteTreeConsumerArgumentVector
                == indexObservationContract.exactHEADConsumerArgumentVector,
              indexObservationContract.gitStderrMergedIntoStdoutBeforeBoundedConsumer,
              indexObservationContract.boundedConsumerStderrRedirectedToFixedDiagnosticSink,
              indexObservationContract.probePipelineProcessCount == 2,
              indexObservationContract.probePipelineRunsUnderLocallyDisabledErrexit,
              indexObservationContract.probePipelineStatusesCapturedImmediately,
              indexObservationContract.probeStatusesCapturedBeforeErrexitRestore,
              indexObservationContract.probeStatusTrailerByteCount == 22,
              indexObservationContract.outerCommandSubstitutionRequiredStatus == 0,
              indexObservationContract.exactProbeKinds
                == ["HEAD", "clean_status", "write_tree"],
              indexObservationContract.exactProbeBodyReadCaps == [42, 1, 42],
              indexObservationContract.exactAcceptedProbeBodyByteCounts
                == [41, 0, 41],
              indexObservationContract.exactMaximumProbeCaptureByteCounts
                == [64, 23, 64],
              indexObservationContract.acceptedProbeProducerStatus == 0,
              indexObservationContract.acceptedProbeConsumerStatus == 0,
              !indexObservationContract.producerOrConsumerStderrPublished,
              indexObservationContract.probeFailureValidHelperRecordCount == 0,
              indexObservationContract.exactProbeCaptureVectors.count == 11,
              indexObservationContract.exactProbeCaptureVectors.map(\.ordinal)
                == Array(1 ... 11),
              indexObservationContract.exactProbeCaptureVectors
                .filter(\.accepted).count == 3,
              indexObservationContract.exactProbeCaptureVectors.allSatisfy({
                  Data(base64Encoded: $0.bodyBase64)?.count
                    == $0.bodyByteCount
                      && Data(base64Encoded: $0.trailerBase64)?.count == 22
                      && Data(base64Encoded: $0.captureBase64)?.count
                        == $0.captureByteCount
                      && ($0.accepted
                          ? (!$0.expectedExternalAdmissionFailure
                              && $0.failureValidHelperRecordCount == nil)
                          : ($0.expectedExternalAdmissionFailure
                              && $0.failureValidHelperRecordCount == 0))
              }),
              postRawIndexMutationTestSeamContract.productionCoreFunctionName
                == "prime_verify_exact_revision_topology_core_v1",
              postRawIndexMutationTestSeamContract.publicSourcedFunctionName
                == relationAPIContract.sourcedFunctionName,
              postRawIndexMutationTestSeamContract.matrixOnlyWrapperFunctionName
                == "prime_test_exact_revision_topology_post_raw_index_mutation_v1",
              postRawIndexMutationTestSeamContract.exactClosedCoreModes
                == ["none", "post_raw_read_tree_alternate"],
              postRawIndexMutationTestSeamContract.publicWrapperCoreMode
                == "none",
              postRawIndexMutationTestSeamContract.matrixWrapperCoreMode
                == "post_raw_read_tree_alternate",
              postRawIndexMutationTestSeamContract.publicWrapperCallsCoreExactlyOnce,
              postRawIndexMutationTestSeamContract.matrixWrapperCallsCoreExactlyOnce,
              !postRawIndexMutationTestSeamContract.internalCoreIsExported,
              postRawIndexMutationTestSeamContract.exactModeBranchCount == 1,
              postRawIndexMutationTestSeamContract
                .modeSelectionIsOneStaticClosedCaseBranch,
              postRawIndexMutationTestSeamContract.normalPublicCallsAlwaysUseNone,
              postRawIndexMutationTestSeamContract.mutationCallbackInvocationCount == 0,
              postRawIndexMutationTestSeamContract.evalInvocationCount == 0,
              postRawIndexMutationTestSeamContract.sourceInvocationCount == 0,
              postRawIndexMutationTestSeamContract.environmentHookReadCount == 0,
              postRawIndexMutationTestSeamContract.globalHookReadCount == 0,
              postRawIndexMutationTestSeamContract
                .arbitraryMutationCommandArgumentCount == 0,
              postRawIndexMutationTestSeamContract
                .arbitraryMutationPathArgumentCount == 0,
              postRawIndexMutationTestSeamContract
                .arbitraryMutationOIDArgumentCount == 0,
              postRawIndexMutationTestSeamContract.gateMutationSeamInvocationCount == 0,
              postRawIndexMutationTestSeamContract
                .mutationModeAdditionalPublicAPIArgumentCount == 0,
              postRawIndexMutationTestSeamContract
                .standardVerifierArgumentsForwardedUnchanged,
              postRawIndexMutationTestSeamContract.exactMutationTiming
                == "once_after_all_raw_outcomes_and_before_first_post_HEAD_probe",
              postRawIndexMutationTestSeamContract.alternateTreeFixtureID
                == "alternate_tree",
              postRawIndexMutationTestSeamContract.exactReadTreeArgumentVector
                == Self.cleanGitAt("<validated_private_compiler_root>", [
                    "-C", "<private_repository>", "read-tree",
                    "a8b941f979c6752d954e44f12986dcda9dd54417",
                ]),
              postRawIndexMutationTestSeamContract.readTreeExpectedStatus == 0,
              postRawIndexMutationTestSeamContract.readTreeExpectedStdinByteCount == 0,
              postRawIndexMutationTestSeamContract.readTreeExpectedStdoutByteCount == 0,
              postRawIndexMutationTestSeamContract.readTreeExpectedStderrByteCount == 0,
              postRawIndexMutationTestSeamContract.readTreeInvocationCountInNoneMode == 0,
              postRawIndexMutationTestSeamContract
                .readTreeInvocationCountInAlternateMode == 1,
              postRawIndexMutationTestSeamContract.HEADMutationInvocationCount == 0,
              postRawIndexMutationTestSeamContract.exactPostHEADProbeStatusPair
                == "000:000",
              postRawIndexMutationTestSeamContract.postHEADOuterSubstitutionStatus == 0,
              postRawIndexMutationTestSeamContract.exactPostCleanStatusProbeFixtureID
                == "clean_status_post_raw_alternate_tree_prefix_A_rejected",
              postRawIndexMutationTestSeamContract.exactPostCleanStatusBody == "A",
              postRawIndexMutationTestSeamContract
                .exactPostCleanStatusProbeStatusPair == "000:000",
              postRawIndexMutationTestSeamContract
                .postCleanStatusOuterSubstitutionStatus == 0,
              postRawIndexMutationTestSeamContract
                .postWriteTreeInvocationCountAfterStatusFailure == 0,
              postRawIndexMutationTestSeamContract.expectedExternalAdmissionFailure,
              postRawIndexMutationTestSeamContract.expectedValidHelperRecordCount == 0,
              postRawIndexMutationTestSeamContract.expectedProjectionInvocationCount == 0,
              postRawIndexMutationTestSeamContract.exactFutureMatrixCallSiteCount == 1,
              postRawIndexMutationTestSeamContract.futurePrivateMatrixInvocationCount == 1,
              preprobeWaveContract.wave1GuardPhaseRangeInFlatSchedule
                == Array(13 ... 18),
              preprobeWaveContract.wave1GuardPhaseRangeInRelationSchedule
                == Array(14 ... 19),
              !preprobeWaveContract.flatPhase19OrLaterExplicitFailureCausesEarlyReturn,
              !preprobeWaveContract.relationPhase20OrLaterExplicitFailureCausesEarlyReturn,
              preprobeWaveContract.safeParent2StillTriggersWave2AfterEarlierRawFailure,
              preprobeWaveContract.wave2GuardPhaseRangeInRelationSchedule
                == Array(14 ... 19),
              classifierBuildAdmissionContract.additionalSelfTestArgumentVectorCount == 0,
              classifierBuildAdmissionContract.expectedStatus == 0,
              classifierBuildAdmissionContract.expectedStdoutByteCount == 0,
              classifierBuildAdmissionContract.expectedStderrByteCount == 0,
              classifierBuildAdmissionContract.sameOrdinaryParserAndClassifierFunctionsCalled,
              classifierBuildAdmissionContract.sameRelationEvaluatorAndWitnessConstructorCalled,
              !classifierBuildAdmissionContract.duplicateParserOrConstantsPermitted,
              classifierBuildAdmissionContract.relationWitnessComparedOnlyInMemory,
              classifierBuildAdmissionContract.selfTestStdoutEmitterInvocationCount == 0,
              !classifierBuildAdmissionContract.liveWriteAndEPIPECoveredBySelfTest,
              classifierBuildAdmissionContract.liveWriteAndEPIPECoveredByPrivateMatrix,
              deterministicLiveEPIPERecipe.recipeID
                == "live_relation_witness_F_SETNOSIGPIPE_EPIPE",
              deterministicLiveEPIPERecipe.executionKind
                == "future_private_matrix_deterministic_live_classifier_fifo_epipe",
              deterministicLiveEPIPERecipe.futureMatrixComponentPath
                == ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh",
              deterministicLiveEPIPERecipe.futureMatrixFunctionName
                == "prime_test_live_relation_classifier_epipe_v1",
              deterministicLiveEPIPERecipe.exactFutureMatrixFunctionGrammar
                == "prime_test_live_relation_classifier_epipe_v1 <validated_private_matrix_root> <admitted_classifier_path>",
              deterministicLiveEPIPERecipe.exactFutureMatrixCallSiteCount == 1,
              deterministicLiveEPIPERecipe.futurePrivateMatrixInvocationCount == 1,
              deterministicLiveEPIPERecipe.publicHelperInvocationCount == 0,
              deterministicLiveEPIPERecipe.gateInvocationCount == 0,
              deterministicLiveEPIPERecipe.validHelperRecordCount == 0,
              deterministicLiveEPIPERecipe.projectionInvocationCount == 0,
              deterministicLiveEPIPERecipe.witnessPublicationCount == 0,
              deterministicLiveEPIPERecipe.validatedPrivateMatrixRootRequired,
              deterministicLiveEPIPERecipe.exactUmask == "0077",
              deterministicLiveEPIPERecipe.exactAdmittedToolPaths == [
                  "/bin/bash", "/bin/rm", "/usr/bin/env", "/usr/bin/mkfifo",
                  "/usr/bin/stat",
              ],
              deterministicLiveEPIPERecipe.fifoPath
                == "<validated_private_matrix_root>/prime-topology-epipe.fifo",
              deterministicLiveEPIPERecipe.fifoMustBeAbsentAndFinalComponentNonlinkBeforeCreation,
              deterministicLiveEPIPERecipe.mkfifoExpectedStatus == 0,
              deterministicLiveEPIPERecipe.mkfifoExpectedStdoutByteCount == 0,
              deterministicLiveEPIPERecipe.mkfifoExpectedStderrByteCount == 0,
              deterministicLiveEPIPERecipe.exactFifoStatOutput
                == "<decimal_effective_uid> 10600 Fifo File\n",
              deterministicLiveEPIPERecipe.fifoStatExpectedStatus == 0,
              deterministicLiveEPIPERecipe.fifoOwnerMustEqualEffectiveUID,
              deterministicLiveEPIPERecipe.fifoReaderProcessCount == 1,
              deterministicLiveEPIPERecipe.readerOpenDescriptor == 3,
              deterministicLiveEPIPERecipe.parentWriterDescriptor == 4,
              deterministicLiveEPIPERecipe.exactReaderLaunchGrammar.hasPrefix(
                  "/bin/bash -p -c"
              ),
              deterministicLiveEPIPERecipe.exactClassifierLaunchGrammar
                == "exact_in_memory_decoded_valid_relation_merge_payload_to_fd0;fd1_dup_from_parent_fd4;fd2_private_bounded_capture;then_exactClassifierArgumentVector",
              deterministicLiveEPIPERecipe.exactHandshakeOrder.count == 8,
              deterministicLiveEPIPERecipe.readerExpectedStatus == 0,
              deterministicLiveEPIPERecipe.readerIsWaitedAndClosedBeforeClassifierLaunch,
              deterministicLiveEPIPERecipe.zeroFIFOReadersProvedBeforeClassifierLaunch,
              deterministicLiveEPIPERecipe.classifierStandardOutputDuplicatesWriterDescriptor,
              deterministicLiveEPIPERecipe.requiredClassifierInheritedFDSubsetBeforeProductionClosure
                == [0, 1, 2, 4],
              deterministicLiveEPIPERecipe.additionalInheritedDescriptorsMayExistAndMustBeClosed,
              deterministicLiveEPIPERecipe.exactClassifierFinalFDsAfterProductionClosure
                == [0, 1, 2],
              deterministicLiveEPIPERecipe.stdinFixtureID
                == "valid_relation_merge",
              deterministicLiveEPIPERecipe.stdinFixturePayloadByteCount == 265,
              isLowercaseHex(
                  deterministicLiveEPIPERecipe.stdinFixturePayloadSHA256, 64
              ),
              deterministicLiveEPIPERecipe.exactExpectedClassifierStatus == 28,
              deterministicLiveEPIPERecipe.exactExpectedClassifierStdoutBodyByteCount == 0,
              deterministicLiveEPIPERecipe.exactExpectedClassifierStderrByteCount == 0,
              deterministicLiveEPIPERecipe.expectedStatusPayloadFixtureID
                == "relation_exit28_empty_prefix",
              deterministicLiveEPIPERecipe.exercisesProductionFSETNOSIGPIPEPath,
              !deterministicLiveEPIPERecipe.signalHandlerInstalled,
              deterministicLiveEPIPERecipe.classifierOrParentShellSIGPIPECount == 0,
              deterministicLiveEPIPERecipe.writeReturnsEPIPEBeforeAnyProgress,
              deterministicLiveEPIPERecipe.exactLogicalWitnessWriteOperationCount == 1,
              deterministicLiveEPIPERecipe.classifierWaitStatusCapturedExactlyOnce,
              deterministicLiveEPIPERecipe.partialPrefixLengthsOneThroughFortyArePureInjectionsOnly,
              deterministicLiveEPIPERecipe.cleanupExpectedStatus == 0,
              deterministicLiveEPIPERecipe.cleanupInvocationCount == 1,
              deterministicLiveEPIPERecipe.noNetwork,
              !deterministicLiveEPIPERecipe.sameEUIDConcurrentMutationInScope,
              relationClassifierContract.relationModeToken
                == "--ordered-merge-child-relation",
              relationClassifierContract.exactKnownExitStatuses
                == [
                    0, 20, 21, 22, 23, 24, 25, 26, 27, 28,
                    30, 31, 32, 33, 34, 41, 42,
                ],
              relationClassifierContract.exactStatusPayloadRules.count == 8,
              relationClassifierContract.exactStatusPayloadRules.map(\.ordinal)
                == Array(1 ... 8),
              relationClassifierContract.usesSHA1RawCommitIdentityRebinding,
              !relationClassifierContract.SHA1ClaimsSecurityStrength,
              relationClassifierContract.safeWitnessRequiresBaseFlatHeaderPhaseRange
                == Array(29 ... 33),
              relationClassifierContract.safeWitnessRequiresRelationHeaderPhaseRange
                == Array(31 ... 35),
              relationClassifierContract.safeWitnessRequiresActualParentCountAtLeast == 2,
              relationClassifierContract.exactWitnessByteCount == 41,
              relationClassifierContract.ordinaryModeStdoutByteCount == 0,
              relationClassifierContract.stderrByteCountEveryOutcome == 0,
              relationClassifierContract.stdoutFcntlCommand
                == "fcntl(STDOUT_FILENO, F_SETNOSIGPIPE, 1)",
              !relationClassifierContract.signalHandlerInstalled,
              relationClassifierContract.exactLogicalWriteOperationCount == 1,
              relationClassifierContract.intendedBlockingWriteByteCount == 41,
              relationClassifierContract.shortZeroOrErrorWriteExitStatus == 28,
              relationClassifierContract.exit28IsLastFallibleClassifierOutcome,
              !relationClassifierContract.exit28PrefixEverConsumed,
              relationCaptureContract.statusTrailerByteCount == 22,
              relationCaptureContract.maximumBodyByteCount == 41,
              relationCaptureContract.maximumCaptureByteCount == 63,
              relationCaptureContract.gitNonzeroHasPrecedence,
              !relationCaptureContract.rawWitnessPublished,
              !relationCaptureContract.rawWitnessStoredAsDurableEvidence,
              relationCaptureContract.exactFrameGuardID
                == "classifier_relation_witness_frame_is_exact",
              relationCaptureContract.exit28AdmittedPrefixLengths
                == Array(0 ... 40),
              relationCaptureContract.exit28AdmittedPrefixLengthCount == 41,
              relationCaptureContract.exit28EveryAdmittedPrefixNeverConsumed,
              relationCaptureContract.exit28Exact41BodyRejected,
              relationCaptureContract.trailerSyntaxValidatedBeforeClassifierStatusMembership,
              relationCaptureContract.unknownClassifierStatusGuardID
                == "classifier_exit_status_known",
              relationCaptureContract.xtraceAndVerboseDisabledAndVerifiedBeforeWitness,
              relationCaptureContract.debugAndReturnTrapsAbsentBeforeWitness,
              relationCaptureContract.errTrapAbsentBeforeWitness,
              relationCaptureContract.errtraceAndFunctraceDisabledAndVerifiedBeforeWitness,
              relationCaptureContract.bashXtraceFDUnsetBeforeWitness,
              relationCaptureContract.PS4InfluenceNeutralizedBeforeWitness,
              relationCaptureContract.hostileTraceStateFailsBeforeWitnessEntersShellState,
              relationCaptureContract.hostileTraceStateValidHelperRecordCount == 0,
              relationCaptureContract.hostileTraceMatrixRequired,
              !relationCaptureContract.privateWitnessMayAppearInTraceOrStderr,
              dependentChildContract.childPreprobeOccursAfterDistinctnessGuard,
              dependentChildContract.childPreprobeInvocationCountOnSafeDistinctWitness == 1,
              dependentChildContract.childRawStreamInvocationCountAfterPassingPreprobe == 1,
              dependentChildContract.childUsesOrdinaryClassifierMode,
              dependentChildContract.childExpectedParentCount == 1,
              dependentChildContract.childRoleSource
                == "caller_suffix_child_role",
              dependentChildContract.childMissingRoleSource
                == "validated_caller_suffix_child_role_not_gate_default_literal",
              !dependentChildContract.childObservationMayUseHistoryTraversal,
              resultContract.exactOrderedResultCodes == Self.resultCodes,
              resultContract.resultTaxonomyCount == 10,
              resultContract.exactFlatGuardCount == 35,
              flat.count == 35,
              flat.map(\.phaseOrdinal) == Array(1 ... 35),
              Set(flat.map(\.guardID)).count == 35,
              resultContract.exactRelationGuardCount == 38,
              relation.count == 38,
              relation.map(\.phaseOrdinal) == Array(1 ... 38),
              Set(relation.map(\.guardID)).count == 38,
              resultContract.exactNewGuards.count == 3,
              resultContract.exactNewGuards.map(\.relationPhaseOrdinal)
                == [3, 23, 36],
              resultContract.exactNewGuards.map(\.guardID)
                == [
                    "relation_merge_oid_differs_from_fixed_parent_and_explicit_request_oids",
                    "classifier_relation_witness_frame_is_exact",
                    "discovered_child_oid_differs_from_merge_fixed_parent_and_explicit_request_oids",
                ],
              resultContract.relationPhase14ChildFailureMayOutrankEarlierPhase20OrLaterExplicitFailure,
              resultContract.treeGuardAppliedIndependentlyToMergeAndChild,
              resultContract.parentGuardAppliedIndependentlyToMergeAndChild,
              syntheticGitObjectFixtures.count == 24,
              syntheticGitObjectFixtures.map(\.ordinal) == Array(1 ... 24),
              Set(objectIDs).count == objectIDs.count,
              Set(objectOIDs).count == objectOIDs.count,
              syntheticGitObjectFixtures.allSatisfy({
                  ["blob", "commit", "tree"].contains($0.objectType)
                      && $0.payloadEncoding == "base64_exact_bytes"
                      && Data(base64Encoded: $0.payloadBase64)?.count
                        == $0.payloadByteCount
                      && isLowercaseHex($0.payloadSHA256, 64)
                      && isLowercaseHex($0.literalObjectOID, 40)
                      && $0.parsedTreeOID.map { isLowercaseHex($0, 40) }
                        ?? true
                      && $0.parsedOrderedParentOIDs.allSatisfy({
                          isLowercaseHex($0, 40)
                      })
                      && $0.literalOIDRecomputedAndRequiredEqualBeforeUse
                      && $0.noNetwork
              }),
              syntheticGitObjectFixtures.filter({ $0.objectType == "tree" }).count == 2,
              syntheticGitObjectFixtures.filter({ $0.objectType == "blob" }).count == 1,
              syntheticGitObjectFixtures.filter({ $0.objectType == "commit" }).count == 21,
              privateFixtureRepositoryContract.objectFormat == "sha1",
              privateFixtureRepositoryContract.exactWithheldFixtureIDs
                == ["withheld_child"],
              privateFixtureRepositoryContract.withheldFixtureWriteInvocationCount == 0,
              privateFixtureRepositoryContract.exactInventoryRows.count == 24,
              privateFixtureRepositoryContract.exactInventoryRows.map(\.ordinal)
                == Array(1 ... 24),
              privateFixtureRepositoryContract.exactInventoryRows.allSatisfy({ row in
                  syntheticGitObjectFixtures.contains(where: { fixture in
                      fixture.fixtureID == row.fixtureID
                          && fixture.literalObjectOID == row.literalObjectOID
                          && row.expectedExactGitBatchCheckLine
                            == fixture.literalObjectOID
                              + (fixture.expectedDestinationInventoryPresent
                                  ? " \(fixture.objectType) \(fixture.payloadByteCount)\n"
                                  : " missing\n")
                  })
              }),
              privateFixtureRepositoryContract.exactInventoryArgumentVector
                == Self.cleanGit([
                    "-C", "<private_repository>",
                    "cat-file", "--batch-check=%(objectname) %(objecttype) %(objectsize)",
                ]),
              Data(base64Encoded:
                    privateFixtureRepositoryContract.inventoryStdinBase64)?.count
                == privateFixtureRepositoryContract.inventoryStdinByteCount,
              privateFixtureRepositoryContract.inventoryStdinByteCount == 984,
              isLowercaseHex(
                  privateFixtureRepositoryContract.inventoryStdinSHA256, 64
              ),
              privateFixtureRepositoryContract.inventoryExpectedStatus == 0,
              Data(base64Encoded:
                    privateFixtureRepositoryContract.inventoryExpectedStdoutBase64)?.count
                == privateFixtureRepositoryContract.inventoryExpectedStdoutByteCount,
              privateFixtureRepositoryContract.inventoryExpectedStdoutByteCount
                == 1_234,
              isLowercaseHex(
                  privateFixtureRepositoryContract.inventoryExpectedStdoutSHA256,
                  64
              ),
              privateFixtureRepositoryContract.inventoryExpectedStderrByteCount == 0,
              !privateRepositoryExecutionRecipes.isEmpty,
              privateRepositoryExecutionRecipes.map(\.ordinal)
                == Array(1 ... privateRepositoryExecutionRecipes.count),
              Set(repositoryRecipeIDs).count == repositoryRecipeIDs.count,
              Set(relationOntologyCases.compactMap(\.privateRepositoryRecipeID))
                == Set(repositoryRecipeIDs),
              privateRepositoryExecutionRecipes.allSatisfy({ recipe in
                  caseIDs.contains(recipe.ontologyCaseID)
                      && recipe.initExpectedStatus == 0
                      && recipe.initExpectedStdinByteCount == 0
                      && recipe.initExpectedStdoutByteCount == 0
                      && recipe.initExpectedStderrByteCount == 0
                      && recipe.exactWrittenFixtureIDs
                        == privateFixtureRepositoryContract.exactWrittenFixtureIDs
                      && recipe.exactWithheldFixtureIDs == ["withheld_child"]
                      && recipe.withheldFixtureWriteInvocationCount == 0
                      && objectIDs.contains(recipe.eventCurrentFixtureID)
                      && recipe.updateRefExpectedStatus == 0
                      && recipe.updateRefExpectedStdinByteCount == 0
                      && recipe.updateRefExpectedStdoutByteCount == 0
                      && recipe.updateRefExpectedStderrByteCount == 0
                      && recipe.independentIndexTreeFixtureID == "empty_tree"
                      && recipe.readTreeExpectedStatus == 0
                      && recipe.readTreeExpectedStdinByteCount == 0
                      && recipe.readTreeExpectedStdoutByteCount == 0
                      && recipe.readTreeExpectedStderrByteCount == 0
                      && recipe.inventoryRequiredBeforeCase
                      && recipe.exactExpectedProbeStatusPairs.count
                        == recipe.exactExpectedGateProbeBodies.count
                          + recipe.exactExpectedHelperPreProbeBodies.count
                          + recipe.exactExpectedHelperPostProbeBodies.count
                      && recipe.exactExpectedProbeStatusPairs
                        .allSatisfy({ $0 == "000:000" })
              }),
              componentHarnessRecipes.count == 6,
              componentHarnessRecipes.map(\.ordinal) == Array(1 ... 6),
              componentHarnessRecipes.map(\.ontologyCaseID) == [
                  "wave1_missing_merge_stops_all_raw",
                  "merge_wrong_tree_isolated",
                  "wave2_phase15_outweighs_earlier_explicit_raw_failure",
                  "wrong_tree_one_parent_selects_tree_without_witness",
                  "child_phase15_beats_merge_phase37",
                  "alternate_valid_merge_role_missing_is_selected",
              ],
              componentHarnessRecipes.allSatisfy({ recipe in
                  recipe.constructionKind
                    == "private_repository_component_harness"
                      && recipe.futureMatrixComponentPath
                        == ".github/scripts/prime-ci-exact-revision-topology-verifier-test.sh"
                      && recipe.futureMatrixFunctionName
                        == "prime_test_exact_revision_topology_component_harness_v1"
                      && recipe.exactFutureMatrixFunctionGrammar
                        == "prime_test_exact_revision_topology_component_harness_v1 <component_recipe_id>"
                      && recipe.exactFutureMatrixCallSiteLiteral
                        == "prime_test_exact_revision_topology_component_harness_v1 \"\(recipe.recipeID)\""
                      && recipe.exactFutureMatrixCallSiteCount == 1
                      && repositoryRecipeIDs.contains(
                          recipe.privateRepositoryRecipeID
                      )
                      && recipe.publicHelperInvocationCount == 0
                      && recipe.gateInvocationCount == 0
                      && recipe.indexBarrierInvocationCount == 0
                      && recipe.validHelperRecordCount == 0
                      && recipe.projectionInvocationCount == 0
                      && recipe.classifierBuildInvocationCount == 0
                      && recipe.reusesAdmittedSelfTestedClassifier
                      && recipe.exactOrderedSteps.map(\.ordinal)
                        == Array(1 ... recipe.exactOrderedSteps.count)
                      && recipe.exactOrderedSteps.allSatisfy({ step in
                          [
                              "explicit_ordinary_transport_frame_injection",
                              "merge_preprobe", "merge_relation_raw",
                              "child_distinctness_guard",
                              "child_preprobe", "child_ordinary_raw",
                              "selector_hook",
                          ].contains(step.stepKind)
                              && (0 ... 1).contains(
                                  step.physicalGitInvocationCount
                              )
                              && (0 ... 1).contains(
                                  step.physicalClassifierInvocationCount
                              )
                      })
                      && recipe.successfulCandidateTupleCount == 0
                      && recipe.selectorHookInvocationCount == 1
                      && !recipe.exactSelectorCandidateTuples.isEmpty
                      && relationOntologyCases.contains(where: { value in
                          value.caseID == recipe.ontologyCaseID
                              && value.expectedResultCode
                                == recipe.expectedResultCode
                              && value.expectedFirstFailedGuardID
                                == recipe.expectedFirstFailedGuardID
                              && value.expectedFirstFailedPhaseOrdinal
                                == recipe.expectedFirstFailedPhaseOrdinal
                              && value.expectedFirstFailureObjectOrdinal
                                == recipe.expectedFirstFailureObjectOrdinal
                              && value.expectedMissingObjectRole
                                == recipe.expectedMissingObjectRole
                      })
              }),
              captureFixtures.count == 30,
              captureFixtures.map(\.ordinal) == Array(1 ... 30),
              Set(captureIDs).count == captureIDs.count,
              captureFixtures.allSatisfy({
                  Data(base64Encoded: $0.bodyBase64)?.count == $0.bodyByteCount
                      && Data(base64Encoded: $0.trailerBase64)?.count == 22
                      && Data(base64Encoded: $0.captureBase64)?.count
                        == $0.captureByteCount
                      && isLowercaseHex($0.bodySHA256, 64)
                      && isLowercaseHex($0.trailerSHA256, 64)
                      && isLowercaseHex($0.captureSHA256, 64)
              }),
              valueDomainFixtures.count == 6,
              valueDomainFixtures.map(\.ordinal) == Array(1 ... 6),
              Set(valueIDs).count == valueIDs.count,
              valueDomainFixtures.allSatisfy({ !$0.rawGitFixtureClaimed }),
              invocationParserVectors.count == 47,
              invocationParserVectors.map(\.ordinal) == Array(1 ... 47),
              Set(parserVectorIDs).count == parserVectorIDs.count,
              invocationParserVectors.allSatisfy({ vector in
                  vector.executionKind
                    == "direct_helper_parser_fixture_no_git_or_record"
                      && vector.exactArgumentTokens.first
                        == "<private_repository>"
                      && vector.expectedGitInvocationCount == 0
                      && vector.expectedValidHelperRecordCount == 0
                      && vector.futurePrivateMatrixRequired
                      && (vector.expectedAccepted
                          ? (vector.expectedResultCode == "PARSER_ACCEPTED"
                              && vector.expectedFirstFailedGuardID == nil
                              && vector.expectedFirstFailedPhaseOrdinal == nil
                              && vector.expectedFirstFailureObjectOrdinal == nil)
                          : (vector.expectedResultCode
                                == "TOPOLOGY_INVOCATION_INVALID"
                              && vector.expectedFirstFailedGuardID != nil
                              && vector.expectedFirstFailedPhaseOrdinal != nil))
              }),
              relationOntologyCases.count == 41,
              relationOntologyCases.map(\.ordinal) == Array(1 ... 41),
              Set(caseIDs).count == caseIDs.count,
              relationOntologyCases.allSatisfy({ value in
                  value.explicitFixtureIDs.allSatisfy(objectIDs.contains)
                      && value.suffixEnabled
                        == (value.relationSuffixOccurrenceCount > 0)
                      && (0 ... 2).contains(
                          value.currentIndexMarkerOccurrenceCount
                      )
                      && (0 ... 1).contains(
                          value.relationSuffixOccurrenceCount
                      )
                      && (value.relationSuffixOccurrenceCount == 1
                          ? (value.validatedSuffixMergeRole != nil
                              && value.validatedSuffixChildRole != nil)
                          : (value.validatedSuffixMergeRole == nil
                              && value.validatedSuffixChildRole == nil))
                      && validatedSuffixRoles(value)
                        == [
                            value.validatedSuffixMergeRole,
                            value.validatedSuffixChildRole,
                        ].compactMap({ $0 })
                      && value.invocationRecipe.referencedFixtureIDs
                        .allSatisfy({
                            objectIDs.contains($0)
                                || captureIDs.contains($0)
                                || valueIDs.contains($0)
                        })
                      && Set(value.invocationRecipe.referencedFixtureIDs)
                        .isSubset(of: Set(
                            value.explicitFixtureIDs
                                + [
                                    value.relationMergeFixtureID,
                                    value.discoveredChildFixtureID,
                                    value.captureFixtureID,
                                    value.valueDomainFixtureID,
                                ].compactMap { $0 }
                        ))
                      && value.invocationRecipe.exactHelperArgumentTokens
                        .first.map({
                            $0 == value.invocationRecipe.repositoryArgumentToken
                        }) ?? value.invocationRecipe.exactHelperArgumentTokens.isEmpty
                      && value.relationMergeFixtureID.map(objectIDs.contains)
                        ?? true
                      && value.discoveredChildFixtureID.map(objectIDs.contains)
                        ?? true
                      && value.captureFixtureID.map(captureIDs.contains)
                        ?? true
                      && value.valueDomainFixtureID.map(valueIDs.contains)
                        ?? true
                      && value.expectedFirstFailedPhaseOrdinal
                        == value.expectedFirstFailedGuardID.flatMap({ guardID in
                            let mappings = value.relationSuffixOccurrenceCount > 0
                                ? relation : flat
                            return mappings.first(where: {
                                $0.guardID == guardID
                            })?.phaseOrdinal
                        })
                      && (value.expectedValidHelperRecordCount == 0
                          ? (value.expectedResultCode
                                == "EXTERNAL_ADMISSION_FAILURE"
                              || (value.invocationRecipe.recipeKind
                                    == "direct_helper_parser_fixture"
                                  || value.invocationRecipe.recipeKind
                                    == "direct_component_harness_and_result_selector"
                                  || value.invocationRecipe.recipeKind
                                    == "private_component_harness_and_result_selector")
                              && Self.resultCodes.contains(
                                  value.expectedResultCode
                              ))
                          : Self.resultCodes.contains(value.expectedResultCode))
              }),
              ontologyProofPairs.count == 35,
              ontologyProofPairs.map(\.ordinal) == Array(1 ... 35),
              ontologyProofPairs.allSatisfy({
                  caseIDs.contains($0.positiveCaseID)
                      && caseIDs.contains($0.negativeCaseID)
                      && $0.expectedDifferingSemanticFactIDs
                        .contains($0.predicateID)
                      && !$0.expectedDifferingSemanticFactIDs.isEmpty
                      && Set($0.expectedDifferingSemanticFactIDs).count
                        == $0.expectedDifferingSemanticFactIDs.count
                      && $0.predicatesAreDisjoint
                      && $0.predicatesAreExhaustive
                      && $0.negativeUsesReproducibleRawBytesOrTruthfulPureDomain
              }),
              toctouContract.historyTraversalInvocationCount == 0,
              toctouContract.privateDuplicateTopologyParserCount == 0,
              !toctouContract.sameEUIDConcurrentMutationInScope,
              !toctouContract.retryAfterDetectedMutationAuthorized,
              !externalClosureRequirement.amendmentOwnPRHeadRevisionFrozen,
              !externalClosureRequirement.amendmentOwnPRHeadTreeFrozen,
              !externalClosureRequirement.amendmentOwnMergeRevisionFrozen,
              !externalClosureRequirement.amendmentOwnMergeTreeFrozen,
              !externalClosureRequirement.amendmentOwnExactMainRunFrozen,
              externalClosureRequirement.externalPRAndExactMainClosureRequiredBeforeImplementation,
              !externalClosureRequirement.futureImplementationMayFreezeItsOwnFutureHeadOrTree,
              externalClosureRequirement
                .successorImplementationRequiresNoInterveningMainCommit,
              patchContract.exactCurrentPathCount == 5,
              patchContract.exactOrderedCurrentPaths.map(\.ordinal)
                == Array(1 ... 5),
              patchContract.currentModifiedExistingPathCount == 3,
              patchContract.currentAddedPathCount == 2,
              patchContract.expectedActiveLatinTestCount == 116,
              patchContract.expectedRootTestCount == 88,
              patchContract.expectedFocusedWholeTestCount == 94,
              patchContract.expectedRetainedLiveTestCount == 46,
              patchContract.expectedAggregateTestCount == 140,
              patchContract.expectedEmbeddedProvenanceRecordCount == 528,
              patchContract.exactFutureImplementationPathCount == 5,
              patchContract.exactOrderedFutureImplementationPaths.map(\.ordinal)
                == Array(1 ... 5),
              patchContract.futureImplementationExactFiveUnchanged,
              patchContract.existingAuthorityPairMustRemainByteIdentical,
              !patchContract.packageManifestMutationAuthorized,
              !patchContract.packageLockMutationAuthorized,
              !patchContract.dependencyResolutionAuthorized,
              staticSourceContracts.count == 15,
              staticSourceContracts.map(\.ordinal) == Array(1 ... 15),
              authorityCeiling.predecessorExactMainClosureEstablished,
              authorityCeiling.predecessorAuthorityIdentityEstablished,
              authorityCeiling.amendmentIsPureData,
              authorityCeiling.futureImplementationScopeNarrowlyAmended,
              authorityCeiling.externalClosureRequired,
              falseCeilings.allSatisfy({ !$0 }),
              self == Self.frozenV1
        else {
            throw
                PrimeExactRevisionTopologyRelationAmendmentAuthorityError
                .contractDrift
        }
    }

    private func isLowercaseHex(_ value: String, _ count: Int) -> Bool {
        value.utf8.count == count
            && value.utf8.allSatisfy {
                (0x30 ... 0x39).contains($0)
                    || (0x61 ... 0x66).contains($0)
            }
    }
}
