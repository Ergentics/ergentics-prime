// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityError:
    Error,
    Equatable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// Pure authority for one later native measurement of the fixed validation
/// fixture executable identity. This value performs no build, compiler,
/// evaluator, filesystem, descriptor, process, fixture, lease, launcher,
/// adapter, model, MLX, Metal, Python, or C++ operation.
public struct PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityV1:
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

    public struct RepositoryClosure: Codable, Equatable, Sendable {
        public let repository: String
        public let pullRequestNumber: Int
        public let baseRevision: String
        public let reviewedHeadRevision: String
        public let reviewedHeadSoleParentRevision: String
        public let reviewedHeadTree: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedMergeParentRevisions: [String]
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let reviewedHeadHasExactlyOneParentEqualBase: Bool
        public let historyPreservingTwoParentMergeObserved: Bool
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
        public let mergedAt: String
    }

    public struct WorkflowClosure: Codable, Equatable, Sendable {
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
        public let previousAttemptURL: String?
        public let matchingRunCountForHead: Int
        public let retryCount: Int
        public let rerunCount: Int
        public let actionsArtifactCount: Int
        public let activeRootJobID: Int
        public let activeRootJobConclusion: String
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let reviewedMainJobStepCount: Int
        public let activeRootLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedMetalTestCount: Int
        public let retainedMaintainedRuntimeTestCount: Int
        public let retainedTokenizerTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let soleA2ImplementationTestStartCount: Int
        public let soleA2ImplementationTestPassCount: Int
        public let createdAt: String
        public let startedAt: String
        public let updatedAt: String
    }

    public struct PINMismatchPredecessor: Codable, Equatable, Sendable {
        public let observationID: String
        public let observationCanonicalByteCount: Int
        public let observationCanonicalSHA256: String
        public let observationSource: FileIdentity
        public let mechanicsMergeRevision: String
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let checkSuiteID: Int
        public let activeRootJobID: Int
        public let reviewedMainJobID: Int
        public let workflowConclusion: String
        public let hostedRecordCount: Int
        public let resultCode: String
        public let configuredFixtureByteCount: Int
        public let configuredFixtureSHA256: String
        public let measuredFixtureByteCountPublished: Bool
        public let measuredFixtureSHA256Published: Bool
        public let mismatchDimensionEstablished: Bool
        public let adapterCommandAttemptCount: Int
        public let fixtureProcessExecutionCount: Int
        public let mechanicsOpportunityRetired: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let distinctMeasurementAuthorityRequired: Bool
    }

    public struct HistoricalPINOrigin: Codable, Equatable, Sendable {
        public let pullRequestNumber: Int
        public let integrationRevision: String
        public let integrationTree: String
        public let orderedParentRevisions: [String]
        public let integrationKind: String
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
        public let configuredFixtureByteCount: Int
        public let configuredFixtureSHA256: String
        public let historicalDocumentationReportedMachOUUID: String
        public let historicalMachOUUIDIsAcceptanceCriterion: Bool
        public let historicalManifest: FileIdentity
        public let historicalPackageLock: FileIdentity
        public let historicalMirrorConfiguration: FileIdentity
        public let historicalFixtureSource: FileIdentity
        public let historicalPINSource: FileIdentity
        public let manifestBlobUnchangedAtCurrentClosure: Bool
        public let fixtureSourceBlobUnchangedAtCurrentClosure: Bool
        public let packageLockBlobUnchangedAtCurrentClosure: Bool
        public let mirrorBlobUnchangedAtCurrentClosure: Bool
        public let compilerIdentityFrozenByHistoricalPIN: Bool
        public let sdkIdentityFrozenByHistoricalPIN: Bool
        public let buildEnvironmentFrozenByHistoricalPIN: Bool
        public let run143MismatchCauseEstablished: Bool
        public let unresolvedCauseEnvelope: [String]
    }

    public struct FixtureInputInventory: Codable, Equatable, Sendable {
        public let orderedFiles: [FileIdentity]
        public let exactFileCount: Int
        public let packagePath: String
        public let fixtureProductName: String
        public let fixtureTargetName: String
        public let fixtureExecutableLeaf: String
        public let currentAcceptancePinByteCount: Int
        public let currentAcceptancePinSHA256: String
        public let currentAcceptancePinSourceType: String
        public let currentAcceptancePinByteCountDeclaration: String
        public let currentAcceptancePinSHA256Prefix: String
        public let currentAcceptancePinSHA256Suffix: String
        public let packageMutationAuthorized: Bool
        public let lockMutationAuthorized: Bool
        public let mirrorMutationAuthorized: Bool
        public let fixtureSourceMutationAuthorized: Bool
        public let kernelMutationAuthorized: Bool
        public let pinMutationAuthorized: Bool
    }

    public struct PathContract: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let role: String
    }

    public struct AuthorityScope: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let activeRootLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let embeddedProvenanceRecordCount: Int
        public let soleAuthorityTestClassName: String
        public let soleAuthorityTestMethodName: String
        public let soleAuthorityTestExpectedStartCount: Int
        public let soleAuthorityTestExpectedPassCount: Int
        public let addedProofOnlyHistoricalWant: String
        public let addedProofOnlyWantCountPerExistingFetch: Int
        public let exactPrimeFetchInvocationCountPerCheckoutRemainsOne: Bool
        public let fetchDepthRemainsTwo: Bool
        public let workflowJobAndStepTopologyMustRemainUnchanged: Bool
        public let retainedLiveCommandsMustRemainByteIdentical: Bool
        public let packageManifestMustRemainByteIdentical: Bool
        public let packageLockMustRemainByteIdentical: Bool
        public let mirrorMustRemainByteIdentical: Bool
        public let fixtureSourceMustRemainByteIdentical: Bool
        public let secureChildKernelMustRemainByteIdentical: Bool
        public let a2ImplementationPairMustRemainByteIdentical: Bool
        public let implementationIncludedInThisPatch: Bool
        public let measurementAuthorizedOnlyAfterAuthorityExactMainGreen: Bool
        public let authorityExactMainGreenObservedAtAuthoring: Bool
    }

    public struct EvaluatorContract: Codable, Equatable, Sendable {
        public let sourcePath: String
        public let executableRole: String
        public let requiredImports: [String]
        public let compilerExecutablePath: String
        public let orderedCompilerArgumentPrefix: [String]
        public let orderedCompilerArgumentRolesAfterPrefix: [String]
        public let compilerAdditionalArgumentCount: Int
        public let compilerInvocationCount: Int
        public let evaluatorInvocationCount: Int
        public let compilerRunsAfterArtifactBAdmissionImmediatelyBeforeEvaluatorAdmissionAndInvocation:
            Bool
        public let evaluatorTrackedSourceMustMatchExactMechanicsRevisionImmediatelyBeforeCompiler:
            Bool
        public let evaluatorSourceExpectedIdentitySource: String
        public let evaluatorSourceExpectedGitMode: String
        public let evaluatorSourceAdmissionExecutablePath: String
        public let orderedEvaluatorSourceAdmissionArgumentRoles: [String]
        public let evaluatorSourceAdmissionInvocationCount: Int
        public let evaluatorSourceAdmissionRawOutputByteCount: Int
        public let evaluatorSourceAdmissionUsesStatusOnlyNoExternalDiffOrTextConversion:
            Bool
        public let evaluatorSourceAdmissionAndCompilerUseSameFixedCanonicalExactCheckoutRoot:
            Bool
        public let evaluatorSourceAdmissionImmediatelyPrecedesFixedCompilerInvocation:
            Bool
        public let evaluatorSourceAdmissionFailureResultCode: String
        public let evaluatorExecutableMustBeCanonicalAbsolutePrivateLeaf: Bool
        public let evaluatorPrivateRootLeaf: String
        public let evaluatorExecutableLeaf: String
        public let evaluatorPrivateRootMode: String
        public let evaluatorPrivateRootInitiallyAbsentAndNonlinkRequired: Bool
        public let evaluatorPrivateRootExclusiveCreationRequired: Bool
        public let evaluatorPrivateRootPhysicalOwnerDeviceAdmissionRequired:
            Bool
        public let evaluatorExecutableMustNotExistBeforeCompilerInvocation:
            Bool
        public let evaluatorPrivateRootLauncherCleanupInvocationCount: Int
        public let evaluatorPrivateRootRetainedOnlyUntilOrdinaryEphemeralRunnerTeardown:
            Bool
        public let evaluatorPrivateRootResidualFilesAreEvidence: Bool
        public let evaluatorPrivateRootReuseOrRetryAuthorized: Bool
        public let evaluatorExecutableRegularNonlinkSingleLinkOwnerExecutableRequired:
            Bool
        public let evaluatorEnvironmentLauncherPath: String
        public let evaluatorEnvironmentLauncherFixedArguments: [String]
        public let evaluatorEnvironmentLauncherInvocationCount: Int
        public let evaluatorEnvironmentMustBeEmpty: Bool
        public let evaluatorAllowedEnvironmentKeys: [String]
        public let evaluatorStdinPath: String
        public let evaluatorStdoutTransport: String
        public let evaluatorStderrPath: String
        public let unrelatedFileDescriptorsMustBeClosed: Bool
        public let orderedInvocationModes: [String]
        public let orderedArgumentCountsExcludingArgumentZero: [Int]
        public let orderedArgumentRolesByInvocation: [[String]]
        public let acceptsArbitraryExecutableAuthority: Bool
        public let measuredFixtureExecutionCount: Int
        public let openFlags: [String]
        public let descriptorMustBeCloseOnExec: Bool
        public let pathMustBeCanonicalAbsolute: Bool
        public let pathLStatRequired: Bool
        public let descriptorPreAndPostFStatRequired: Bool
        public let descriptorIdentityMustRemainStable: Bool
        public let descriptorAndNameIdentityJoinRequired: Bool
        public let descriptorAndNameJoinRequiredBeforeAndAfterRead: Bool
        public let distinctBuildDeviceInodeIdentityTupleRequired: Bool
        public let buildArtifactsMustShareTrustedLocalDevice: Bool
        public let buildArtifactInodesMustDiffer: Bool
        public let regularFileRequired: Bool
        public let symbolicLinkAuthorized: Bool
        public let hardLinkAuthorized: Bool
        public let exactLinkCount: Int
        public let ownerMustEqualEffectiveUser: Bool
        public let executableOwnerBitRequired: Bool
        public let maximumFixtureExecutableByteCount: Int
        public let signedOffTFileSizeMustBePositiveAndConvertExactlyThroughUInt64ToInt:
            Bool
        public let allocationAndOffsetArithmeticOnlyAfterSizeAdmission: Bool
        public let boundedStreamingReadRequired: Bool
        public let maximumReadChunkByteCount: Int
        public let accumulatedByteCountUsesCheckedArithmetic: Bool
        public let exactEOFRequiredAfterAdmittedByteCount: Bool
        public let exactFileByteCountReadRequired: Bool
        public let cryptoKitSHA256Required: Bool
        public let fullByteEqualityRequired: Bool
        public let thinMachORequired: Bool
        public let fatMachOAccepted: Bool
        public let requiredMachOMagic: String
        public let requiredCPUType: String
        public let requiredFileType: String
        public let loadCommandRegionBoundsChecked: Bool
        public let loadCommandWalkUsesCheckedIntegerArithmetic: Bool
        public let loadCommandCountAndRegionSizeMustMatchExactly: Bool
        public let eachLoadCommandHeaderAndCommandSizeBoundsChecked: Bool
        public let eachLoadCommandSizeAtLeastHeaderAndEightByteAligned: Bool
        public let minimumLoadCommandSizeByteCount: Int
        public let loadCommandSizeAlignmentByteCount: Int
        public let loadCommandOffsetSizeAndEndArithmeticUsesReportingOverflow:
            Bool
        public let exactLCUUIDCount: Int
        public let exactLCUUIDCommandSize: Int
        public let exactLCBuildVersionCount: Int
        public let minimumLCBuildVersionCommandSize: Int
        public let lcBuildVersionToolCountAndCommandSizeMustAgree: Bool
        public let lcBuildVersionToolEntryByteCount: Int
        public let lcBuildVersionExactCommandSizeFormula: String
        public let lcBuildVersionSizeArithmeticUsesCheckedMultiplyAndAdd: Bool
        public let entireLCBuildVersionCommandBytesEqualityRequired: Bool
        public let exactLCCodeSignatureCount: Int
        public let exactLCCodeSignatureCommandSize: Int
        public let codeSignatureDataRangeBoundsChecked: Bool
        public let codeSignatureValidityEstablished: Bool
        public let launchabilityEstablished: Bool
        public let requiredBuildPlatform: String
        public let buildMinimumOSObserved: Bool
        public let buildSDKObserved: Bool
        public let UUIDEqualityRequired: Bool
        public let buildVersionEqualityRequired: Bool
        public let evaluatorOutputCanonicalJSONOnly: Bool
        public let rawPathFieldCount: Int
        public let rawBuildOutputFieldCount: Int
        public let pythonImportOrInvocationCount: Int
        public let cppSourceOrInvocationCount: Int
    }

    public struct EvaluatorOutputContract: Codable, Equatable, Sendable {
        public let schemaID: String
        public let schemaVersion: Int
        public let canonicalJSONRequired: Bool
        public let terminalLFPermitted: Bool
        public let maximumCanonicalJSONByteCount: Int
        public let logicalFieldTypeContracts: [String]
        public let exactCanonicalWireOrderedKeys: [String]
        public let exactFieldCount: Int
        public let exactIdentityFieldCountPerArtifact: Int
        public let exactComparisonFieldCount: Int
        public let packedMachOVersionRepresentation: String
        public let exactCanonicalWireGrammar: String
        public let comparisonBooleansMustEqualDirectEvaluatorResults: Bool
        public let machoIdentityComparisonIncludesExactLCUUIDAndEntireLCBuildVersion:
            Bool
        public let fullByteInequalityIsAuthoritativeForNondeterminism: Bool
        public let fullBytesTrueRequiresAllOtherComparisonsTrue: Bool
        public let publishedIdentityEqualityMustMatchComparisonBooleans: Bool
        public let impossibleCrossFieldCombinationResultCode: String
        public let rawPathFieldCount: Int
        public let rawBuildOutputOrErrorFieldCount: Int
        public let launcherUsesGenericJSONDecoder: Bool
        public let launcherUsesExactBash32ASCIIHexLexicalParser: Bool
        public let exactBash32ExtendedRegex: String
        public let exactBash32CaptureGroupCount: Int
        public let orderedPostRegexNumericChecks: [String]
        public let launcherMustReconstructAndByteCompareCanonicalASCII: Bool
        public let launcherProjectionTargetSchemaID: String
        public let launcherProjectionPreservesIdentityAndComparisonValues: Bool
    }

    public struct BoundedCaptureContract: Codable, Equatable, Sendable {
        public let transport: String
        public let captureFilesystemPathCount: Int
        public let captureFilesystemCleanupRequired: Bool
        public let captureFilesystemAbsenceByConstruction: Bool
        public let boundedReaderExecutablePath: String
        public let exactBoundedReaderInvocationCount: Int
        public let byteEncoderExecutablePath: String
        public let orderedByteEncoderArguments: [String]
        public let byteEncoderExactLocaleEnvironment: String
        public let exactByteEncoderInvocationCount: Int
        public let byteEncoderOutputByteCountFormula: String
        public let byteEncoderSizeArithmeticUsesCheckedOperations: Bool
        public let exactPipelineStatusEnvelopeGrammar: String
        public let exactPipelineStatusEnvelopeByteCount: Int
        public let pipelineStatusesCapturedImmediatelyInsideSubshell: Bool
        public let producerNonzeroClassificationPrecedesOutputValidation: Bool
        public let capOverflowMayProduceSIGPIPENonzeroProducerStatus: Bool
        public let nonzeroProducerStatusResultCodes: [String]
        public let rawProducerBytesEnterCommandSubstitution: Bool
        public let fixedCaptureToolsAndNullDeviceAdmittedBeforeAttemptConsumption:
            Bool
        public let preAttemptCaptureAdmissionFailureResultCode: String
        public let showBinCaptureCount: Int
        public let showBinMaximumAcceptedByteCount: Int
        public let showBinReaderLimitByteCount: Int
        public let showBinByteEncoderOutputAtReaderLimitByteCount: Int
        public let showBinMaximumEncodedCaptureByteCount: Int
        public let showBinBytesPreservedBeforeShellStringNormalization: Bool
        public let showBinTerminalLFValidatedAsHex0ABeforePathBodyDecode: Bool
        public let showBinExactGrammar: String
        public let showBinZeroProducerStatusOutputValidationFailureResultCodes:
            [String]
        public let showBinUnavailableTransportResultCodes: [String]
        public let evaluatorStdoutMaximumAcceptedByteCount: Int
        public let evaluatorStdoutReaderLimitByteCount: Int
        public let evaluatorByteEncoderOutputAtReaderLimitByteCount: Int
        public let evaluatorStdoutMaximumEncodedCaptureByteCount: Int
        public let evaluatorStdoutTerminalLFPermitted: Bool
        public let evaluatorZeroProducerStatusReaderEncoderOrCapFailureResultCode:
            String
        public let evaluatorUnavailableTransportResultCode: String
        public let nonRecordRawStdoutForwardingByteCount: Int
        public let nonRecordRawStderrForwardingByteCount: Int
        public let nullDevicePath: String
        public let nullDeviceNameAndDescriptorJoinRequired: Bool
        public let nullDeviceCharacterDeviceRequired: Bool
        public let evaluatorStdinUsesVerifiedNullDevice: Bool
        public let evaluatorStderrUsesVerifiedNullDevice: Bool
        public let showBinStderrUsesVerifiedNullDevice: Bool
        public let fixtureBuildAndCompilerStdoutStderrUseVerifiedNullDevice:
            Bool
        public let fixtureBuildAndCompilerRawOutputForwardingByteCount: Int
        public let encodedCaptureExactASCIIHexTokenGrammarRequired: Bool
        public let encodedCaptureReconstructedOnlyAfterByteGrammarAdmission: Bool
        public let overflowDetectionUsesCapPlusOneByte: Bool
        public let noCommandSubstitutionMayReceiveUnboundedProducerOutput: Bool
    }

    public struct TimingAdmissionContract: Codable, Equatable, Sendable {
        public let predecessorRunID: Int
        public let predecessorReviewedJobObservedDurationSeconds: Int
        public let currentReviewedJobTimeoutMinutes: Int
        public let authorizedReviewedJobTimeoutMinutes: Int
        public let activeRootJobTimeoutMinutesRemains: Int
        public let soleWorkflowTimeoutMutationRequired: Bool
        public let workflowJobAdditionCount: Int
        public let workflowStepAdditionCount: Int
        public let authorizedReviewedJobCeilingSeconds: Int
        public let authorizedTimeoutIsPlatformCeilingNotCompletionGuarantee:
            Bool
        public let authorizedTimeoutPurpose: String
        public let timingMechanismIsWatchdog: Bool
        public let additionalTimingStatePathCount: Int
        public let preBuildTimingRefusalResultCodeCount: Int
        public let timeoutCancellationOrAbruptTerminationHostedRecordCardinality:
            String
        public let timeoutCancellationOrAbruptTerminationObservedOnlyFromActionsMetadata:
            Bool
        public let timeoutCancellationOrAbruptTerminationMeasurementAttemptConsumption:
            String
        public let timeoutCancellationOrAbruptTerminationEstablishesMeasurement:
            Bool
        public let timeoutCancellationOrAbruptTerminationEstablishesFixtureIdentity:
            Bool
        public let presentRecordUnderExternalTerminationRequiresMatchingCompletedWorkflowConclusionToBeAccepting:
            Bool
        public let timeoutCancellationOrAbruptTerminationRetiresOpportunity:
            Bool
    }

    public struct HostedRecordContract: Codable, Equatable, Sendable {
        public struct ResultStateInvariant: Codable, Equatable, Sendable {
            public let resultCode: String
            public let workflowConclusion: String
            public let measurementAttemptConsumed: Bool
            public let buildACommandState: String
            public let showBinACommandState: String
            public let buildBCommandState: String
            public let showBinBCommandState: String
            public let evaluatorCompileState: String
            public let evaluatorCommandState: String
            public let evaluatorExecutionObservation: String
            public let evaluatorShellWaitStatusContract: String
            public let identityFieldContract: String
            public let buildABComparisonContract: String
            public let currentPinComparisonContract: String
            public let additionalPredicate: String
        }

        public let prefix: String
        public let schemaID: String
        public let schemaVersion: Int
        public let canonicalJSONRequired: Bool
        public let exactLineCountWhenPresent: Int
        public let terminalLFRequiredWhenPresent: Bool
        public let maximumCanonicalJSONByteCount: Int
        public let maximumTotalLineByteCount: Int
        public let logicalFieldTypeContracts: [String]
        public let exactCanonicalWireOrderedKeys: [String]
        public let exactCanonicalWireGrammar: String
        public let exactFieldCount: Int
        public let exactResultCodes: [String]
        public let commandStateMembers: [String]
        public let executionObservationMembers: [String]
        public let comparisonStateMembers: [String]
        public let evaluatorCommandExecutionAndWaitFieldsApplyOnlyToSoleFixtureIdentityInvocation:
            Bool
        public let exactResultStateInvariants: [ResultStateInvariant]
        public let everyResultCodeCoveredExactlyOnce: Bool
        public let successResultCodes: [String]
        public let failureResultCodes: [String]
        public let onlySuccessResultCodesMayConcludeWorkflowSuccess: Bool
        public let everyFailureResultCodeRequiresNonzeroWorkflowConclusion: Bool
        public let presentRecordAcceptingOnlyWhenWorkflowConclusionMatchesResultInvariant:
            Bool
        public let identityFieldsNullableBeforeMeasurement: Bool
        public let identityFieldsRequiredAfterSuccessfulAcceptedEvaluatorReturn:
            Bool
        public let currentPinComparisonRequiredAfterFullyIdenticalEvaluatorReturn:
            Bool
        public let currentPinComparisonSemantics: String
        public let rawAbsolutePathFieldCount: Int
        public let rawBuildOutputOrErrorFieldCount: Int
        public let exactRecordCountForEveryLauncherControlledOutcome: Int
        public let launcherControlledReturnAlwaysProjectsExactlyOneRecord:
            Bool
        public let maximumRecordCountPerWorkflowRun: Int
        public let exactRecordCountOnReachedTerminalEvaluatorPath: Int
        public let boundedExitProjectionRequired: Bool
        public let exitProjectionMustBeIdempotentAndAtMostOnce: Bool
        public let preEvaluatorBuildOrCompileFailureMayHaveNoRecord: Bool
        public let recordMayBeAbsentOnExternalTimeoutCancellationAbruptProcessHostOrRunnerTerminationBeforeOrAfterLauncherStart:
            Bool
        public let launcherNotReachedHostedRecordCount: Int
        public let launcherNotReachedObservedOnlyFromActionsMetadata: Bool
        public let launcherNotReachedEstablishesMeasurementOrIdentity: Bool
        public let launcherNotReachedRetiresOpportunity: Bool
        public let actionsArtifactCount: Int
        public let scientificOutcome: String
        public let durableEvidence: Bool
        public let pinMutationPerformed: Bool
        public let canaryExecutionPerformed: Bool
        public let absentExternalTerminationMeasurementAttemptConsumption:
            String
        public let absentRecordEstablishesMeasurement: Bool
        public let absentRecordEstablishesFixtureIdentity: Bool
        public let everyRecordOrAbsentRecordOutcomeRetiresOpportunity: Bool
    }

    public struct MeasurementRootContract: Codable, Equatable, Sendable {
        public let runnerTempEnvironmentKey: String
        public let runnerTempMaximumUTF8ByteCount: Int
        public let runnerTempMustBeNonemptyCanonicalAbsolutePhysicalDirectory:
            Bool
        public let runnerTempMustBeNonlinkAndOwnedByEffectiveUser: Bool
        public let runnerTempPhysicalDeviceIdentityCaptured: Bool
        public let runnerTempDeviceMustEqualFixedCanonicalExactCheckoutRootDevice:
            Bool
        public let fixedCanonicalExactCheckoutRootDeviceIsTrustedLocalBoundary:
            Bool
        public let fixedCanonicalExactCheckoutRootNameAndDescriptorJoinRequired:
            Bool
        public let fixedCanonicalExactCheckoutRootJoinAlsoBindsEvaluatorSourceAnchor:
            Bool
        public let privateBaseLeaf: String
        public let privateBaseMode: String
        public let privateBaseMustInitiallyBeAbsentAndNonlink: Bool
        public let privateBaseCreatedExclusivelyWithOwnerOnlyUmask: Bool
        public let privateBaseMustBeCanonicalAbsolutePhysicalDirectory:
            Bool
        public let privateBaseMustBeOwnedByEffectiveUserAndShareRunnerTempDevice:
            Bool
        public let privateBaseExactModeRequired: Bool
        public let directoryAdmissionDescriptorNumber: Int
        public let metadataExecutablePath: String
        public let metadataExactLocaleEnvironment: String
        public let metadataFormat: String
        public let orderedDescriptorMetadataArguments: [String]
        public let descriptorMetadataUsesNoFileOperandAndStdinRedirectedFromFixedDirectoryFD:
            Bool
        public let orderedNameMetadataArgumentPrefix: [String]
        public let nameMetadataUsesOneFixedCanonicalAbsoluteDirectoryOperand:
            Bool
        public let exactDirectoryIdentityJoinCount: Int
        public let exactMetadataInvocationCountPerIdentityJoin: Int
        public let exactMetadataInvocationAndCaptureCount: Int
        public let metadataProducerMaximumByteCountIncludingTerminalLF: Int
        public let normalizedMetadataMaximumByteCount: Int
        public let normalizedMetadataExactASCIIGrammar: String
        public let metadataNumericConversionsUseCheckedExactWidths: String
        public let metadataProducerEmitsOneLFAndBashSubstitutionStripsOnlyThatLF:
            Bool
        public let directCommandSubstitutionAuthorizedOnlyForProvenFixedFormatBound:
            Bool
        public let metadataRawPathOutputFieldCount: Int
        public let metadataNonzeroStatusOverflowGrammarOrIdentityMismatchFailureMappingByRole:
            [String]
        public let runnerTempAndPrivateBaseNameAndDescriptorStatRequiredAtAdmission:
            Bool
        public let runnerTempAndPrivateBaseDescriptorNameDeviceInodeJoinRequired:
            Bool
        public let admittedDirectoryIdentityStabilityReliesOnTrustedNoHostileConcurrentSameUIDBoundary:
            Bool
        public let exactTreeSourceRootLeaves: [String]
        public let fixtureBuildRootSetLeaves: [String]
        public let evaluatorRootLeaf: String
        public let exactDirectChildRootLeafCount: Int
        public let derivedRootMode: String
        public let everyDerivedRootLeafMustBeSingleComponentWithoutSeparatorDotOrDotDot:
            Bool
        public let everyDerivedRootMustBeCanonicalAbsoluteDirectChildOfPrivateBase:
            Bool
        public let everyDerivedRootInitiallyAbsentAndNonlink: Bool
        public let everyDerivedRootCreatedExclusivelyAsApplicable: Bool
        public let everyDerivedRootOwnerDeviceModeAndDescriptorNameJoinRequired:
            Bool
        public let everyDerivedRootMustSharePrivateBaseDevice: Bool
        public let derivedRootDeviceInodeIdentityTuplesMustBePairwiseDistinct:
            Bool
        public let derivedRootHardLinkSharingAuthorized: Bool
        public let directoryLinkCountUsedAsStablePredicateAfterChildCreation:
            Bool
        public let evaluatorExecutableAbsolutePathMustDeriveOnlyFromPrivateBaseEvaluatorRootAndFixedLeaf:
            Bool
        public let allDirectoryAdmissionDescriptorsClosedBeforeEverySubsequentExternalCommand:
            Bool
        public let hostileConcurrentSameEffectiveUIDMutationOutsideThreatScope:
            Bool
    }

    public struct FutureMeasurementContract: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let modifiedExistingPathCount: Int
        public let addedPathCount: Int
        public let shellLauncherPath: String
        public let evaluator: EvaluatorContract
        public let evaluatorOutput: EvaluatorOutputContract
        public let boundedCapture: BoundedCaptureContract
        public let timingAdmission: TimingAdmissionContract
        public let measurementRoots: MeasurementRootContract
        public let authorizedOnlyAfterAuthorityExactMainGreen: Bool
        public let currentAuthorityExecutesMeasurement: Bool
        public let mainPushOnly: Bool
        public let requiredRepository: String
        public let requiredEvent: String
        public let requiredRef: String
        public let requiredRunAttempt: Int
        public let authorityClosureRevisionAvailability: String
        public let authorityClosureTreeAvailability: String
        public let mechanicsRevisionMustBeDirectSuccessorOfAuthorityClosure: Bool
        public let mechanicsFirstParentMustEqualAuthorityClosureRevision: Bool
        public let mechanicsFirstParentTreeMustEqualAuthorityClosureTree: Bool
        public let expectedMechanicsMergeParentCount: Int
        public let exactFiveDeltaRequired: Bool
        public let cleanDetachedCheckoutRequired: Bool
        public let twoDisjointExactTreeSourceRootsRequired: Bool
        public let sourceRootDeviceInodeIdentityTupleDisjointRequired: Bool
        public let sourceRootsMustShareTrustedLocalDevice: Bool
        public let sourceRootInodesMustDiffer: Bool
        public let sourceRootsMustResolveToExactRevisionAndTree: Bool
        public let sourceRootHardLinkSharingAuthorized: Bool
        public let twoDisjointBuildRootSetsRequired: Bool
        public let buildRootRoles: [String]
        public let buildRootMode: String
        public let buildRootsMustInitiallyNotExistOrBeSymbolicLinks: Bool
        public let measurementCreatedRootSetRoles: [String]
        public let measurementCreatedRootSetCount: Int
        public let measurementCreatedRootLauncherCleanupInvocationCount: Int
        public let measurementCreatedRootsRetainedOnlyUntilOrdinaryEphemeralRunnerTeardown:
            Bool
        public let measurementCreatedRootResidualFilesAreEvidence: Bool
        public let measurementCreatedRootReuseOrRetryAuthorized: Bool
        public let boundedRecordProjectionIsFinalDataProducingLauncherAction:
            Bool
        public let boundedRecordProjectionUsesSingleBashBuiltinPrintf: Bool
        public let onlyPostProjectionControlActionIsExactExitWithFrozenResultStatus:
            Bool
        public let successResultLauncherExitStatus: Int
        public let failureResultLauncherExitStatus: Int
        public let buildConfiguration: String
        public let buildArgumentsMustMatchRetiredCanaryFixtureBuildExactly: Bool
        public let additionalFixtureCompilerFlagCount: Int
        public let debugPrefixMapAuthorized: Bool
        public let expectedFixtureProductBuildCommandCount: Int
        public let expectedShowBinPathCommandCount: Int
        public let expectedSwiftRunCommandCount: Int
        public let expectedSwiftTestCommandCount: Int
        public let expectedFixtureExecutableInvocationCount: Int
        public let expectedAdapterInvocationCount: Int
        public let expectedLeaseAcquisitionCount: Int
        public let expectedModelExecutionCount: Int
        public let expectedMLXExecutionCount: Int
        public let expectedMetalExecutionCount: Int
        public let dependencyNetworkInvocationCount: Int
        public let exactLocalMirrorReuseRequired: Bool
        public let forceResolvedVersionsRequired: Bool
        public let swiftPMSandboxRetained: Bool
        public let fixtureTargetDirectDependencyCount: Int
        public let fixturePackagePluginTargetCount: Int
        public let fixturePackageMacroTargetCount: Int
        public let fixturePackageBinaryTargetCount: Int
        public let fixtureBuildGraphExecutesPackagePluginMacroOrBinaryTargetCode:
            Bool
        public let allFixtureBuildAndShowBinSubprocessesMustBeWaitedAndReapedBeforeEvaluatorSourceAdmission:
            Bool
        public let hostileConcurrentSameEffectiveUIDMutationWithinThreatScope:
            Bool
        public let privateMode0700ClaimedToProtectAgainstHostileSameEffectiveUID:
            Bool
        public let residualNameOpenTOCTOUAcceptedOnlyUnderTrustedNoHostileConcurrentSameUIDBoundary:
            Bool
        public let releaseBuildAAndBByteIdentityCompared: Bool
        public let releaseBuildAAndBSHA256Compared: Bool
        public let releaseBuildAAndBMachOIdentityCompared: Bool
        public let buildAndCompilerSubprocessesAreNotFixtureExecution: Bool
        public let measurementAttemptConsumedImmediatelyBeforeFirstBuild: Bool
        public let preBuildRefusalConsumesMeasurementAttempt: Bool
        public let everyPostConsumptionOutcomeRetiresOpportunity: Bool
        public let everyAdmissionSetupBuildEvaluatorOrAbsentOutcomeRetiresOpportunity:
            Bool
        public let automaticRetryAuthorized: Bool
        public let workflowRerunAuthorized: Bool
        public let replacementMeasurementAuthorized: Bool
        public let expectedActiveRootLatinTestCount: Int
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedEmbeddedProvenanceRecordCount: Int
        public let observationMustFreezeExistingSanitizedToolchainStepValues:
            Bool
        public let observationMustFreezeReviewedJobLogIdentity: Bool
        public let lcBuildVersionEstablishesSameCompilerIdentity: Bool
        public let hostedRecord: HostedRecordContract
    }

    public struct RetirementBoundary: Codable, Equatable, Sendable {
        public let disposition: String
        public let appendOnlyObservationRequiredAfterEveryOutcome: Bool
        public let successRequiresObservationAndRetirement: Bool
        public let buildFailureRequiresObservationAndRetirement: Bool
        public let evaluatorFailureRequiresObservationAndRetirement: Bool
        public let mismatchRequiresObservationAndRetirement: Bool
        public let cancellationRequiresObservationAndRetirement: Bool
        public let abruptHostLossRequiresObservationFromActionsMetadata: Bool
        public let observationAndRetirementMustBeNextAuthorizedChange: Bool
        public let launcherSourceRetainedForAuditAfterRetirement: Bool
        public let evaluatorSourceRetainedForAuditAfterRetirement: Bool
        public let currentPinPassRequiresSeparateNoMutationConfirmationAuthority:
            Bool
        public let currentPinPassConfirmationPinMutationCount: Int
        public let pinRepairAuthorityMustBeSeparate: Bool
        public let pinRepairImplementationMustNotLaunchFixture: Bool
        public let pinRepairExactMainIndependentHostedRemeasurementRequired:
            Bool
        public let pinRepairConfirmationFixtureExecutionCount: Int
        public let crossRunIdentityConfirmationFields: [String]
        public let crossRunSHA256EqualityCoversEveryArtifactByteIncludingLCBuildVersionTools:
            Bool
        public let crossRunIdentityMatchRequiredBeforeCanaryAuthority: Bool
        public let bothSuccessResultBranchesRequireCrossRunConfirmation: Bool
        public let successBranchConfirmationObservationAndRetirementRequired:
            Bool
        public let automaticRetryAuthorized: Bool
        public let workflowRerunAuthorized: Bool
        public let replacementMeasurementAuthorized: Bool
        public let orderedLaterBoundaries: [String]
    }

    public struct LanguageBoundary: Codable, Equatable, Sendable {
        public let authorityLanguage: String
        public let laterLauncherLanguage: String
        public let laterEvaluatorLanguage: String
        public let evaluatorUsesCryptoKit: Bool
        public let pythonPermitted: Bool
        public let pythonInvocationCount: Int
        public let pythonSourcePathCount: Int
        public let cppPermitted: Bool
        public let cppInvocationCount: Int
        public let cppSourcePathCount: Int
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let measurementAuthorityEstablished: Bool
        public let laterExactFiveMeasurementAuthorizedAfterClosure: Bool
        public let measurementMechanicsPerformed: Bool
        public let launcherSourceAdded: Bool
        public let evaluatorSourceAdded: Bool
        public let compilerInvocationAuthorizedInThisPatch: Bool
        public let evaluatorInvocationAuthorizedInThisPatch: Bool
        public let filesystemReadAuthorizedInThisPatch: Bool
        public let filesystemWriteAuthorizedInThisPatch: Bool
        public let descriptorInspectionAuthorizedInThisPatch: Bool
        public let processExecutionAuthorizedInThisPatch: Bool
        public let fixtureBuildAuthorizedInThisPatch: Bool
        public let fixtureExecutionAuthorizedInThisPatch: Bool
        public let adapterExecutionAuthorizedInThisPatch: Bool
        public let leaseAcquisitionAuthorizedInThisPatch: Bool
        public let modelExecutionAuthorizedInThisPatch: Bool
        public let networkAuthorizedInThisPatch: Bool
        public let measuredFixtureIdentityEstablished: Bool
        public let repeatBuildDeterminismEstablished: Bool
        public let currentPinMatchEstablished: Bool
        public let fixturePinMutationAuthorized: Bool
        public let fixturePinMutationPerformed: Bool
        public let fixturePinRepairAuthorityEstablished: Bool
        public let fixturePinRepairImplementationAuthorized: Bool
        public let layerAMutationAuthorized: Bool
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
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let status: String
    public let predecessorFiles: [FileIdentity]
    public let predecessorRepositoryClosure: RepositoryClosure
    public let predecessorPullRequestRun: WorkflowClosure
    public let predecessorPushMainRun: WorkflowClosure
    public let pinMismatchPredecessor: PINMismatchPredecessor
    public let historicalPINOrigin: HistoricalPINOrigin
    public let fixtureInputInventory: FixtureInputInventory
    public let authorityScope: AuthorityScope
    public let futureMeasurementContract: FutureMeasurementContract
    public let retirementBoundary: RetirementBoundary
    public let languageBoundary: LanguageBoundary
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]

    public static let canonicalByteCount = 66_632
    public static let canonicalSHA256 =
        "67ad7808b54314b7dcd70a86b5504e7321c4c348a0ecb2ec172d5b72ee3f6d43"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_secure_child_validation_fixture_identity_measurement_authority_v1",
        authorityID:
            "ergentics_prime_secure_child_validation_fixture_identity_measurement_authority_v1",
        authorityKind:
            "pure_authority_for_one_later_native_repeat_build_validation_fixture_identity_measurement",
        status:
            "AUTHORITY_ONLY_future_exact5_native_fixture_identity_measurement_no_current_mechanics_pin_repair_canary_false",
        predecessorFiles: [
            .init(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitStatus: "M", gitMode: "100755",
                gitBlob: "70d8946fb5fae117b67426a2c6b9c13935d4bee8",
                byteCount: 1_324_722, lfByteCount: 21_670,
                sha256: "3b6d68f95d98cd181aee28c2cb0d8be644a621493c93679136d7fef0bcc99c27",
                role: "a2_implementation_active_root_gate"),
            .init(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                gitStatus: "M", gitMode: "100644",
                gitBlob: "c2473bf53462e44e837429b7140320cede65d020",
                byteCount: 164_657, lfByteCount: 726,
                sha256: "cb8505522cf8bbff51517ae0158408048798cd41b9b2b632ebb1c0ddabbf7ce5",
                role: "a2_implementation_hosted_workflow"),
            .init(
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitStatus: "M", gitMode: "100644",
                gitBlob: "9be87f801ed0290659d612c6fd6453137a47a46c",
                byteCount: 546, lfByteCount: 13,
                sha256: "7b6ab69f587fb8b0b336cc983e126e7ea8b71664ec2a26e6f66dd794d2cc8cac",
                role: "a2_implementation_embedded_provenance_519_records"),
            .init(
                path: "Sources/PrimeCore/PrimeMonitorHeldLeaseSecureChildContainment.swift",
                gitStatus: "A", gitMode: "100644",
                gitBlob: "bc101249a70522ec0080c3064be7668c5cff1425",
                byteCount: 3_940, lfByteCount: 108,
                sha256: "5253f74c363825617dc25e8ef66f0fda95e285969d4b24fee0d975585fba7dba",
                role: "a2_closed_monitor_held_lease_containment_implementation"),
            .init(
                path: "Tests/PrimeCoreTests/PrimeMonitorHeldLeaseSecureChildContainmentTests.swift",
                gitStatus: "A", gitMode: "100644",
                gitBlob: "e16b70540ad3215984bf3389b4cb109e09c16368",
                byteCount: 4_018, lfByteCount: 116,
                sha256: "069e1091461ce680938185bfeca3001a3a164018d491a805782b52690109933c",
                role: "a2_sole_pure_implementation_test"),
        ],
        predecessorRepositoryClosure: .init(
            repository: "Ergentics/ergentics-prime",
            pullRequestNumber: 128,
            baseRevision: "3ad8087ed6e403ba81f46bba97ceb5d440979e0a",
            reviewedHeadRevision: "e1f9fa486ee5fadccc62cb795fea11fbf85ff394",
            reviewedHeadSoleParentRevision: "3ad8087ed6e403ba81f46bba97ceb5d440979e0a",
            reviewedHeadTree: "c3c325a0b24513030fd3e5228926094371f7a3a4",
            mergeRevision: "75b14056b75e8af6af0c070453f7ef14ac10a063",
            mergeTree: "c3c325a0b24513030fd3e5228926094371f7a3a4",
            orderedMergeParentRevisions: [
                "3ad8087ed6e403ba81f46bba97ceb5d440979e0a",
                "e1f9fa486ee5fadccc62cb795fea11fbf85ff394",
            ],
            mergeTreeEqualsReviewedHeadTree: true,
            reviewedHeadHasExactlyOneParentEqualBase: true,
            historyPreservingTwoParentMergeObserved: true,
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-20T08:24:07Z",
            mergedAt: "2026-08-20T08:24:07Z"),
        predecessorPullRequestRun: .init(
            workflowName: "Prime active-root quarantine",
            runID: 32_347_997_651, runNumber: 155, runAttempt: 1,
            checkSuiteID: 87_689_058_666,
            event: "pull_request", ref: "refs/pull/128/merge",
            headSHA: "e1f9fa486ee5fadccc62cb795fea11fbf85ff394",
            status: "completed", conclusion: "success",
            previousAttemptURL: nil, matchingRunCountForHead: 1,
            retryCount: 0, rerunCount: 0, actionsArtifactCount: 0,
            activeRootJobID: 96_360_762_572,
            activeRootJobConclusion: "success",
            reviewedMainJobID: 96_361_700_232,
            reviewedMainJobConclusion: "skipped",
            reviewedMainJobStepCount: 0,
            activeRootLatinTestCount: 116,
            rootTestCount: 0, isolatedGroupTestCounts: [],
            isolatedTestCount: 0, focusedWholeTestCount: 0,
            retainedMetalTestCount: 0,
            retainedMaintainedRuntimeTestCount: 0,
            retainedTokenizerTestCount: 0,
            retainedLiveTestCount: 0, aggregateTestCount: 0,
            failureCount: 0, skipCount: 0,
            soleA2ImplementationTestStartCount: 0,
            soleA2ImplementationTestPassCount: 0,
            createdAt: "2026-08-20T08:16:30Z",
            startedAt: "2026-08-20T08:16:30Z",
            updatedAt: "2026-08-20T08:20:14Z"),
        predecessorPushMainRun: .init(
            workflowName: "Prime active-root quarantine",
            runID: 32_348_627_200, runNumber: 156, runAttempt: 1,
            checkSuiteID: 87_690_727_033,
            event: "push", ref: "refs/heads/main",
            headSHA: "75b14056b75e8af6af0c070453f7ef14ac10a063",
            status: "completed", conclusion: "success",
            previousAttemptURL: nil, matchingRunCountForHead: 1,
            retryCount: 0, rerunCount: 0, actionsArtifactCount: 0,
            activeRootJobID: 96_362_688_446,
            activeRootJobConclusion: "success",
            reviewedMainJobID: 96_363_809_495,
            reviewedMainJobConclusion: "success",
            reviewedMainJobStepCount: 7,
            activeRootLatinTestCount: 116,
            rootTestCount: 84,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6, focusedWholeTestCount: 90,
            retainedMetalTestCount: 44,
            retainedMaintainedRuntimeTestCount: 1,
            retainedTokenizerTestCount: 1,
            retainedLiveTestCount: 46, aggregateTestCount: 136,
            failureCount: 0, skipCount: 0,
            soleA2ImplementationTestStartCount: 1,
            soleA2ImplementationTestPassCount: 1,
            createdAt: "2026-08-20T08:24:09Z",
            startedAt: "2026-08-20T08:24:09Z",
            updatedAt: "2026-08-20T09:22:12Z"),
        pinMismatchPredecessor: .init(
            observationID: "prime_secure_child_process_evidence_closed_fixture_canary_pin_mismatch_execution_observation_v1",
            observationCanonicalByteCount: 12_604,
            observationCanonicalSHA256: "327a3fedcd1fed6a936aa053c3882c770a106db7e2662e76815a2b5d21333e16",
            observationSource: .init(
                path: "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservation.swift",
                gitStatus: "A", gitMode: "100644",
                gitBlob: "bd84b810a1842635b7e874826b7c58cf42baacda",
                byteCount: 52_517, lfByteCount: 1_103,
                sha256: "739eed7ece6ea1b2f952d9f02ad613af15adc100788979a47f0edee4aedbb2f1",
                role: "append_only_run143_pin_mismatch_observation"),
            mechanicsMergeRevision: "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
            workflowRunID: 31_974_943_697,
            workflowRunNumber: 143,
            workflowRunAttempt: 1,
            checkSuiteID: 86_694_964_833,
            activeRootJobID: 95_232_879_059,
            reviewedMainJobID: 95_233_206_587,
            workflowConclusion: "failure",
            hostedRecordCount: 1,
            resultCode: "PIN_MISMATCH",
            configuredFixtureByteCount: 89_632,
            configuredFixtureSHA256: "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd",
            measuredFixtureByteCountPublished: false,
            measuredFixtureSHA256Published: false,
            mismatchDimensionEstablished: false,
            adapterCommandAttemptCount: 0,
            fixtureProcessExecutionCount: 0,
            mechanicsOpportunityRetired: true,
            retryAuthorized: false,
            rerunAuthorized: false,
            distinctMeasurementAuthorityRequired: true),
        historicalPINOrigin: .init(
            pullRequestNumber: 50,
            integrationRevision: "3605a076d119c2b0da4f592de1f950d071500c81",
            integrationTree: "633f74843024cd94bbe929dfc3b7615478a14fb0",
            orderedParentRevisions: [
                "d436c4f0c116d07ee8b4baea3ae4070207b8e325",
            ],
            integrationKind: "signed_one_parent_integration_revision",
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-03T11:49:49Z",
            configuredFixtureByteCount: 89_632,
            configuredFixtureSHA256:
                "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd",
            historicalDocumentationReportedMachOUUID:
                "6ABE4B24-C019-3372-8144-C85CCEE5BA19",
            historicalMachOUUIDIsAcceptanceCriterion: false,
            historicalManifest: .init(
                path: "Tests/PrimeValidationWorkflow/Package.swift",
                gitStatus: "historical_at_pin_origin", gitMode: "100644",
                gitBlob: "fe98104c7e812d0c44ee1e38dcc10857455bf54f",
                byteCount: 2_587, lfByteCount: 88,
                sha256: "99354cfc3da2d75ac960d1c704257656eec563bc17344d694678626ae9c1f518",
                role: "historical_validation_package_manifest"),
            historicalPackageLock: .init(
                path: "Tests/PrimeValidationWorkflow/Package.resolved",
                gitStatus: "historical_at_pin_origin", gitMode: "100644",
                gitBlob: "8f2126bdbb71142e78c69b5e4c670efac58daf37",
                byteCount: 1_182, lfByteCount: 41,
                sha256: "c1ced56010eab5cff45aa2eecfc9c8da22d1fb0b214cd361d35b3f3e60d8465b",
                role: "historical_validation_package_lock"),
            historicalMirrorConfiguration: .init(
                path:
                    "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json",
                gitStatus: "historical_at_pin_origin", gitMode: "100644",
                gitBlob: "92e6bf7a3f31367f87f6a4c69d7269d5c07848a0",
                byteCount: 182, lfByteCount: 9,
                sha256: "6124788421eab5803c52b508338ec085a95753b871582951acbb3005b1dc2cc6",
                role: "historical_validation_package_mirror_configuration"),
            historicalFixtureSource: .init(
                path:
                    "Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowFixtureChild/PrimeValidationWorkflowFixtureChild.swift",
                gitStatus: "historical_at_pin_origin", gitMode: "100644",
                gitBlob: "5e45832ed046da7bfd4541ad362018fad97371f5",
                byteCount: 19_353, lfByteCount: 614,
                sha256: "f016793fb012c9dc70a47b5ea0ba325f582d1e7c0c5a84b303855cc8543eb274",
                role: "historical_closed_fixture_source"),
            historicalPINSource: .init(
                path: "Sources/PrimeCore/PrimeSecureChildKernel.swift",
                gitStatus: "historical_at_pin_origin", gitMode: "100644",
                gitBlob: "b675cd443c5684933a3636d1e937aab74ed4b5dc",
                byteCount: 69_774, lfByteCount: 1_949,
                sha256: "772bcb75befb1748f9ff4a98f5033fe2ac24da9c799c6f31eee976b20dd418d6",
                role: "historical_fixture_acceptance_pin_source"),
            manifestBlobUnchangedAtCurrentClosure: true,
            fixtureSourceBlobUnchangedAtCurrentClosure: true,
            packageLockBlobUnchangedAtCurrentClosure: false,
            mirrorBlobUnchangedAtCurrentClosure: false,
            compilerIdentityFrozenByHistoricalPIN: false,
            sdkIdentityFrozenByHistoricalPIN: false,
            buildEnvironmentFrozenByHistoricalPIN: false,
            run143MismatchCauseEstablished: false,
            unresolvedCauseEnvelope: [
                "changed_dependency_resolution_or_mirror_graph",
                "unfrozen_compiler_identity",
                "unfrozen_sdk_identity",
                "unfrozen_hosted_build_environment",
            ]),
        fixtureInputInventory: .init(
            orderedFiles: [
                .init(path: "Tests/PrimeValidationWorkflow/Package.swift", gitStatus: "unchanged", gitMode: "100644", gitBlob: "fe98104c7e812d0c44ee1e38dcc10857455bf54f", byteCount: 2_587, lfByteCount: 88, sha256: "99354cfc3da2d75ac960d1c704257656eec563bc17344d694678626ae9c1f518", role: "fixed_validation_package_manifest"),
                .init(path: "Tests/PrimeValidationWorkflow/Package.resolved", gitStatus: "unchanged", gitMode: "100644", gitBlob: "69919288b1a5da256ff408a4d65106b23abc8f89", byteCount: 645, lfByteCount: 23, sha256: "d70a43567cbd3be75083ab147020b86b055513020d95632f8286f60913c9374a", role: "fixed_validation_package_lock"),
                .init(path: "Tests/PrimeValidationWorkflow/.swiftpm/configuration/mirrors.json", gitStatus: "unchanged", gitMode: "100644", gitBlob: "be0c6cc4685f3fde2b5c747118478397bc34dcf8", byteCount: 37, lfByteCount: 4, sha256: "b8476f18b4ee05b10e208cc37667d3c69e117bd5eda0162e77804570c5713a6b", role: "fixed_empty_validation_package_mirror_configuration"),
                .init(path: "Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowFixtureChild/PrimeValidationWorkflowFixtureChild.swift", gitStatus: "unchanged", gitMode: "100644", gitBlob: "5e45832ed046da7bfd4541ad362018fad97371f5", byteCount: 19_353, lfByteCount: 614, sha256: "f016793fb012c9dc70a47b5ea0ba325f582d1e7c0c5a84b303855cc8543eb274", role: "fixed_closed_fixture_source"),
                .init(path: "Sources/PrimeCore/PrimeSecureChildKernel.swift", gitStatus: "unchanged", gitMode: "100644", gitBlob: "bfa381796b9647863e704006dbaa1406c533c7c5", byteCount: 83_657, lfByteCount: 2_327, sha256: "1ed890d017b67c97a0d980d58cb7614bb71362091c02b03d26a26222b24d5fcd", role: "current_layer_a_fixture_acceptance_pin_source"),
            ],
            exactFileCount: 5,
            packagePath: "Tests/PrimeValidationWorkflow",
            fixtureProductName: "PrimeValidationWorkflowFixtureChild",
            fixtureTargetName: "PrimeValidationWorkflowFixtureChild",
            fixtureExecutableLeaf: "PrimeValidationWorkflowFixtureChild",
            currentAcceptancePinByteCount: 89_632,
            currentAcceptancePinSHA256: "eae9573027fe736cab0d4aa319ae43f22231eaef9c55af91d73fbe3d87bc9ebd",
            currentAcceptancePinSourceType: "PrimeSecureChildFixtureBinaryPin",
            currentAcceptancePinByteCountDeclaration: "static let byteCount: UInt64 = 89_632",
            currentAcceptancePinSHA256Prefix: "eae9573027fe736cab0d4aa319ae43f",
            currentAcceptancePinSHA256Suffix: "22231eaef9c55af91d73fbe3d87bc9ebd",
            packageMutationAuthorized: false,
            lockMutationAuthorized: false,
            mirrorMutationAuthorized: false,
            fixtureSourceMutationAuthorized: false,
            kernelMutationAuthorized: false,
            pinMutationAuthorized: false),
        authorityScope: .init(
            exactOrderedPaths: [
                .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitStatus: "M", gitMode: "100755", role: "bind_run156_closure_and_authority_exact5_ceiling"),
                .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitStatus: "M", gitMode: "100644", role: "integrate_sole_pure_measurement_authority_test"),
                .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitStatus: "M", gitMode: "100644", role: "bind_521_record_embedded_source_identity"),
                .init(ordinal: 4, path: "Sources/PrimeCore/PrimeSecureChildValidationFixtureIdentityMeasurementAuthority.swift", gitStatus: "A", gitMode: "100644", role: "pure_future_native_identity_measurement_authority"),
                .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityTests.swift", gitStatus: "A", gitMode: "100644", role: "sole_exhaustive_pure_authority_test"),
            ],
            exactPathCount: 5,
            activeRootLatinTestCount: 116,
            rootTestCount: 85,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 91,
            retainedLiveTestCount: 46,
            aggregateTestCount: 137,
            embeddedProvenanceRecordCount: 521,
            soleAuthorityTestClassName: "PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityTests",
            soleAuthorityTestMethodName: "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
            soleAuthorityTestExpectedStartCount: 1,
            soleAuthorityTestExpectedPassCount: 1,
            addedProofOnlyHistoricalWant: "3ad8087ed6e403ba81f46bba97ceb5d440979e0a",
            addedProofOnlyWantCountPerExistingFetch: 1,
            exactPrimeFetchInvocationCountPerCheckoutRemainsOne: true,
            fetchDepthRemainsTwo: true,
            workflowJobAndStepTopologyMustRemainUnchanged: true,
            retainedLiveCommandsMustRemainByteIdentical: true,
            packageManifestMustRemainByteIdentical: true,
            packageLockMustRemainByteIdentical: true,
            mirrorMustRemainByteIdentical: true,
            fixtureSourceMustRemainByteIdentical: true,
            secureChildKernelMustRemainByteIdentical: true,
            a2ImplementationPairMustRemainByteIdentical: true,
            implementationIncludedInThisPatch: false,
            measurementAuthorizedOnlyAfterAuthorityExactMainGreen: true,
            authorityExactMainGreenObservedAtAuthoring: false),
        futureMeasurementContract: .init(
            exactOrderedPaths: [
                .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitStatus: "M", gitMode: "100755", role: "bind_authority_closure_and_exact5_measurement_admission"),
                .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitStatus: "M", gitMode: "100644", role: "add_single_final_attempt1_main_measurement_invocation"),
                .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitStatus: "M", gitMode: "100644", role: "bind_standalone_evaluator_source_identity"),
                .init(ordinal: 4, path: ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh", gitStatus: "A", gitMode: "100755", role: "closed_native_repeat_build_measurement_launcher"),
                .init(ordinal: 5, path: "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift", gitStatus: "A", gitMode: "100644", role: "standalone_descriptor_rooted_macho_cryptokit_evaluator"),
            ],
            exactPathCount: 5,
            modifiedExistingPathCount: 3,
            addedPathCount: 2,
            shellLauncherPath: ".github/scripts/prime-ci-secure-child-validation-fixture-identity-measurement.sh",
            evaluator: .init(
                sourcePath: "Tests/PrimeValidationWorkflow/Tools/PrimeSecureChildValidationFixtureIdentityEvaluator.swift",
                executableRole: "fixed_identity_evaluator_never_fixture_or_adapter",
                requiredImports: ["CryptoKit", "Darwin", "Foundation", "MachO"],
                compilerExecutablePath: "/usr/bin/xcrun",
                orderedCompilerArgumentPrefix: ["swiftc"],
                orderedCompilerArgumentRolesAfterPrefix: [
                    "fixed_canonical_absolute_evaluator_source_under_exact_checkout_root",
                    "literal_-o",
                    "fixed_private_evaluator_output_path",
                ],
                compilerAdditionalArgumentCount: 0,
                compilerInvocationCount: 1,
                evaluatorInvocationCount: 1,
                compilerRunsAfterArtifactBAdmissionImmediatelyBeforeEvaluatorAdmissionAndInvocation:
                    true,
                evaluatorTrackedSourceMustMatchExactMechanicsRevisionImmediatelyBeforeCompiler:
                    true,
                evaluatorSourceExpectedIdentitySource:
                    "exact_embedded_mechanics_provenance_git_blob_byte_count_and_sha256",
                evaluatorSourceExpectedGitMode: "100644",
                evaluatorSourceAdmissionExecutablePath: "/usr/bin/git",
                orderedEvaluatorSourceAdmissionArgumentRoles: [
                    "literal_-C",
                    "fixed_canonical_exact_checkout_root",
                    "literal_diff",
                    "literal_--quiet",
                    "literal_--no-ext-diff",
                    "literal_--no-textconv",
                    "exact_mechanics_revision",
                    "literal_--",
                    "fixed_evaluator_source_path",
                ],
                evaluatorSourceAdmissionInvocationCount: 1,
                evaluatorSourceAdmissionRawOutputByteCount: 0,
                evaluatorSourceAdmissionUsesStatusOnlyNoExternalDiffOrTextConversion:
                    true,
                evaluatorSourceAdmissionAndCompilerUseSameFixedCanonicalExactCheckoutRoot:
                    true,
                evaluatorSourceAdmissionImmediatelyPrecedesFixedCompilerInvocation:
                    true,
                evaluatorSourceAdmissionFailureResultCode:
                    "EVALUATOR_SOURCE_REFUSED",
                evaluatorExecutableMustBeCanonicalAbsolutePrivateLeaf: true,
                evaluatorPrivateRootLeaf:
                    "prime-secure-child-validation-fixture-identity-evaluator-root-v1",
                evaluatorExecutableLeaf:
                    "prime-secure-child-validation-fixture-identity-evaluator-v1",
                evaluatorPrivateRootMode: "0700",
                evaluatorPrivateRootInitiallyAbsentAndNonlinkRequired: true,
                evaluatorPrivateRootExclusiveCreationRequired: true,
                evaluatorPrivateRootPhysicalOwnerDeviceAdmissionRequired: true,
                evaluatorExecutableMustNotExistBeforeCompilerInvocation: true,
                evaluatorPrivateRootLauncherCleanupInvocationCount: 0,
                evaluatorPrivateRootRetainedOnlyUntilOrdinaryEphemeralRunnerTeardown:
                    true,
                evaluatorPrivateRootResidualFilesAreEvidence: false,
                evaluatorPrivateRootReuseOrRetryAuthorized: false,
                evaluatorExecutableRegularNonlinkSingleLinkOwnerExecutableRequired:
                    true,
                evaluatorEnvironmentLauncherPath: "/usr/bin/env",
                evaluatorEnvironmentLauncherFixedArguments: ["-i"],
                evaluatorEnvironmentLauncherInvocationCount: 1,
                evaluatorEnvironmentMustBeEmpty: true,
                evaluatorAllowedEnvironmentKeys: [],
                evaluatorStdinPath: "/dev/null",
                evaluatorStdoutTransport: "bounded_anonymous_pipe",
                evaluatorStderrPath: "/dev/null",
                unrelatedFileDescriptorsMustBeClosed: true,
                orderedInvocationModes: [
                    "measure_fixture_identity",
                ],
                orderedArgumentCountsExcludingArgumentZero: [3],
                orderedArgumentRolesByInvocation: [
                    [
                        "fixed_measure_fixture_identity_mode",
                        "release_build_a_fixture_path",
                        "release_build_b_fixture_path",
                    ],
                ],
                acceptsArbitraryExecutableAuthority: false,
                measuredFixtureExecutionCount: 0,
                openFlags: ["O_RDONLY", "O_NOFOLLOW", "O_CLOEXEC"],
                descriptorMustBeCloseOnExec: true,
                pathMustBeCanonicalAbsolute: true,
                pathLStatRequired: true,
                descriptorPreAndPostFStatRequired: true,
                descriptorIdentityMustRemainStable: true,
                descriptorAndNameIdentityJoinRequired: true,
                descriptorAndNameJoinRequiredBeforeAndAfterRead: true,
                distinctBuildDeviceInodeIdentityTupleRequired: true,
                buildArtifactsMustShareTrustedLocalDevice: true,
                buildArtifactInodesMustDiffer: true,
                regularFileRequired: true,
                symbolicLinkAuthorized: false,
                hardLinkAuthorized: false,
                exactLinkCount: 1,
                ownerMustEqualEffectiveUser: true,
                executableOwnerBitRequired: true,
                maximumFixtureExecutableByteCount: 4_194_304,
                signedOffTFileSizeMustBePositiveAndConvertExactlyThroughUInt64ToInt:
                    true,
                allocationAndOffsetArithmeticOnlyAfterSizeAdmission: true,
                boundedStreamingReadRequired: true,
                maximumReadChunkByteCount: 65_536,
                accumulatedByteCountUsesCheckedArithmetic: true,
                exactEOFRequiredAfterAdmittedByteCount: true,
                exactFileByteCountReadRequired: true,
                cryptoKitSHA256Required: true,
                fullByteEqualityRequired: true,
                thinMachORequired: true,
                fatMachOAccepted: false,
                requiredMachOMagic: "MH_MAGIC_64",
                requiredCPUType: "CPU_TYPE_ARM64",
                requiredFileType: "MH_EXECUTE",
                loadCommandRegionBoundsChecked: true,
                loadCommandWalkUsesCheckedIntegerArithmetic: true,
                loadCommandCountAndRegionSizeMustMatchExactly: true,
                eachLoadCommandHeaderAndCommandSizeBoundsChecked: true,
                eachLoadCommandSizeAtLeastHeaderAndEightByteAligned: true,
                minimumLoadCommandSizeByteCount: 8,
                loadCommandSizeAlignmentByteCount: 8,
                loadCommandOffsetSizeAndEndArithmeticUsesReportingOverflow:
                    true,
                exactLCUUIDCount: 1,
                exactLCUUIDCommandSize: 24,
                exactLCBuildVersionCount: 1,
                minimumLCBuildVersionCommandSize: 24,
                lcBuildVersionToolCountAndCommandSizeMustAgree: true,
                lcBuildVersionToolEntryByteCount: 8,
                lcBuildVersionExactCommandSizeFormula:
                    "24_plus_ntools_times_8",
                lcBuildVersionSizeArithmeticUsesCheckedMultiplyAndAdd: true,
                entireLCBuildVersionCommandBytesEqualityRequired: true,
                exactLCCodeSignatureCount: 1,
                exactLCCodeSignatureCommandSize: 16,
                codeSignatureDataRangeBoundsChecked: true,
                codeSignatureValidityEstablished: false,
                launchabilityEstablished: false,
                requiredBuildPlatform: "PLATFORM_MACOS",
                buildMinimumOSObserved: true,
                buildSDKObserved: true,
                UUIDEqualityRequired: true,
                buildVersionEqualityRequired: true,
                evaluatorOutputCanonicalJSONOnly: true,
                rawPathFieldCount: 0,
                rawBuildOutputFieldCount: 0,
                pythonImportOrInvocationCount: 0,
                cppSourceOrInvocationCount: 0),
            evaluatorOutput: .init(
                schemaID:
                    "prime_secure_child_validation_fixture_identity_evaluator_output_v1",
                schemaVersion: 1,
                canonicalJSONRequired: true,
                terminalLFPermitted: false,
                maximumCanonicalJSONByteCount: 2_048,
                logicalFieldTypeContracts: [
                    "schema_id:string_exact",
                    "schema_version:int_1",
                    "fixture_a_byte_count:uint_1_through_4194304",
                    "fixture_a_sha256:lowercase_hex_64",
                    "fixture_a_macho_uuid:lowercase_hex_32",
                    "fixture_a_build_platform_packed:uint32_equal_PLATFORM_MACOS",
                    "fixture_a_minimum_os_packed:uint32",
                    "fixture_a_sdk_packed:uint32",
                    "fixture_b_byte_count:uint_1_through_4194304",
                    "fixture_b_sha256:lowercase_hex_64",
                    "fixture_b_macho_uuid:lowercase_hex_32",
                    "fixture_b_build_platform_packed:uint32_equal_PLATFORM_MACOS",
                    "fixture_b_minimum_os_packed:uint32",
                    "fixture_b_sdk_packed:uint32",
                    "byte_count_equal:bool",
                    "sha256_equal:bool",
                    "full_bytes_equal:bool",
                    "macho_identity_equal:bool",
                ],
                exactCanonicalWireOrderedKeys: [
                    "byte_count_equal",
                    "fixture_a_build_platform_packed",
                    "fixture_a_byte_count",
                    "fixture_a_macho_uuid",
                    "fixture_a_minimum_os_packed",
                    "fixture_a_sdk_packed",
                    "fixture_a_sha256",
                    "fixture_b_build_platform_packed",
                    "fixture_b_byte_count",
                    "fixture_b_macho_uuid",
                    "fixture_b_minimum_os_packed",
                    "fixture_b_sdk_packed",
                    "fixture_b_sha256",
                    "full_bytes_equal",
                    "macho_identity_equal",
                    "schema_id",
                    "schema_version",
                    "sha256_equal",
                ],
                exactFieldCount: 18,
                exactIdentityFieldCountPerArtifact: 6,
                exactComparisonFieldCount: 4,
                packedMachOVersionRepresentation:
                    "unsigned_32_bit_wire_value_0_through_UInt32_max",
                exactCanonicalWireGrammar:
                    "UTF8_ASCII_only_single_object_lexicographically_sorted_exact_keys_no_BOM_whitespace_escape_or_LF_exact_JSON_bool_and_canonical_unsigned_decimal_no_leading_zero_fixed_schema_hex_and_platform_values",
                comparisonBooleansMustEqualDirectEvaluatorResults: true,
                machoIdentityComparisonIncludesExactLCUUIDAndEntireLCBuildVersion:
                    true,
                fullByteInequalityIsAuthoritativeForNondeterminism: true,
                fullBytesTrueRequiresAllOtherComparisonsTrue: true,
                publishedIdentityEqualityMustMatchComparisonBooleans: true,
                impossibleCrossFieldCombinationResultCode:
                    "EVALUATOR_CONTRACT_REFUSED",
                rawPathFieldCount: 0,
                rawBuildOutputOrErrorFieldCount: 0,
                launcherUsesGenericJSONDecoder: false,
                launcherUsesExactBash32ASCIIHexLexicalParser: true,
                exactBash32ExtendedRegex:
                    "^\\{\"byte_count_equal\":(false|true),\"fixture_a_build_platform_packed\":(1),\"fixture_a_byte_count\":([1-9][0-9]{0,6}),\"fixture_a_macho_uuid\":\"([0-9a-f]{32})\",\"fixture_a_minimum_os_packed\":(0|[1-9][0-9]{0,9}),\"fixture_a_sdk_packed\":(0|[1-9][0-9]{0,9}),\"fixture_a_sha256\":\"([0-9a-f]{64})\",\"fixture_b_build_platform_packed\":(1),\"fixture_b_byte_count\":([1-9][0-9]{0,6}),\"fixture_b_macho_uuid\":\"([0-9a-f]{32})\",\"fixture_b_minimum_os_packed\":(0|[1-9][0-9]{0,9}),\"fixture_b_sdk_packed\":(0|[1-9][0-9]{0,9}),\"fixture_b_sha256\":\"([0-9a-f]{64})\",\"full_bytes_equal\":(false|true),\"macho_identity_equal\":(false|true),\"schema_id\":\"prime_secure_child_validation_fixture_identity_evaluator_output_v1\",\"schema_version\":1,\"sha256_equal\":(false|true)\\}$",
                exactBash32CaptureGroupCount: 16,
                orderedPostRegexNumericChecks: [
                    "fixture_a_byte_count_less_than_or_equal_4194304",
                    "fixture_b_byte_count_less_than_or_equal_4194304",
                    "fixture_a_minimum_os_packed_less_than_or_equal_4294967295",
                    "fixture_a_sdk_packed_less_than_or_equal_4294967295",
                    "fixture_b_minimum_os_packed_less_than_or_equal_4294967295",
                    "fixture_b_sdk_packed_less_than_or_equal_4294967295",
                ],
                launcherMustReconstructAndByteCompareCanonicalASCII: true,
                launcherProjectionTargetSchemaID:
                    "prime_secure_child_validation_fixture_identity_measurement_outer_observation_v1",
                launcherProjectionPreservesIdentityAndComparisonValues: true),
            boundedCapture: .init(
                transport:
                    "anonymous_pipe_cap_plus_one_then_fixed_hex_encoding_before_command_substitution",
                captureFilesystemPathCount: 0,
                captureFilesystemCleanupRequired: false,
                captureFilesystemAbsenceByConstruction: true,
                boundedReaderExecutablePath: "/usr/bin/head",
                exactBoundedReaderInvocationCount: 3,
                byteEncoderExecutablePath: "/usr/bin/od",
                orderedByteEncoderArguments: ["-An", "-tx1", "-v"],
                byteEncoderExactLocaleEnvironment: "LC_ALL=C",
                exactByteEncoderInvocationCount: 3,
                byteEncoderOutputByteCountFormula:
                    "raw_count_zero_yields_zero_else_74_times_ceiling_raw_count_divided_by_16_plus_1",
                byteEncoderSizeArithmeticUsesCheckedOperations: true,
                exactPipelineStatusEnvelopeGrammar:
                    "at_P_colon_uint8_3digits_comma_H_colon_uint8_3digits_comma_O_colon_uint8_3digits_at",
                exactPipelineStatusEnvelopeByteCount: 19,
                pipelineStatusesCapturedImmediatelyInsideSubshell: true,
                producerNonzeroClassificationPrecedesOutputValidation: true,
                capOverflowMayProduceSIGPIPENonzeroProducerStatus: true,
                nonzeroProducerStatusResultCodes: [
                    "SHOW_BIN_A_REFUSED",
                    "SHOW_BIN_B_REFUSED",
                    "EVALUATOR_COMMAND_REFUSED",
                ],
                rawProducerBytesEnterCommandSubstitution: false,
                fixedCaptureToolsAndNullDeviceAdmittedBeforeAttemptConsumption:
                    true,
                preAttemptCaptureAdmissionFailureResultCode:
                    "INVOCATION_ADMISSION_REFUSED",
                showBinCaptureCount: 2,
                showBinMaximumAcceptedByteCount: 1_024,
                showBinReaderLimitByteCount: 1_025,
                showBinByteEncoderOutputAtReaderLimitByteCount: 4_811,
                showBinMaximumEncodedCaptureByteCount: 4_830,
                showBinBytesPreservedBeforeShellStringNormalization: true,
                showBinTerminalLFValidatedAsHex0ABeforePathBodyDecode: true,
                showBinExactGrammar:
                    "one_nonempty_canonical_absolute_path_then_exactly_one_LF_no_CR_NUL_or_additional_byte",
                showBinZeroProducerStatusOutputValidationFailureResultCodes: [
                    "ARTIFACT_A_ADMISSION_REFUSED",
                    "ARTIFACT_B_ADMISSION_REFUSED",
                ],
                showBinUnavailableTransportResultCodes: [
                    "SHOW_BIN_A_TRANSPORT_REFUSED",
                    "SHOW_BIN_B_TRANSPORT_REFUSED",
                ],
                evaluatorStdoutMaximumAcceptedByteCount: 2_048,
                evaluatorStdoutReaderLimitByteCount: 2_049,
                evaluatorByteEncoderOutputAtReaderLimitByteCount: 9_547,
                evaluatorStdoutMaximumEncodedCaptureByteCount: 9_566,
                evaluatorStdoutTerminalLFPermitted: false,
                evaluatorZeroProducerStatusReaderEncoderOrCapFailureResultCode:
                    "CAPTURE_REFUSED",
                evaluatorUnavailableTransportResultCode:
                    "EVALUATOR_TRANSPORT_REFUSED",
                nonRecordRawStdoutForwardingByteCount: 0,
                nonRecordRawStderrForwardingByteCount: 0,
                nullDevicePath: "/dev/null",
                nullDeviceNameAndDescriptorJoinRequired: true,
                nullDeviceCharacterDeviceRequired: true,
                evaluatorStdinUsesVerifiedNullDevice: true,
                evaluatorStderrUsesVerifiedNullDevice: true,
                showBinStderrUsesVerifiedNullDevice: true,
                fixtureBuildAndCompilerStdoutStderrUseVerifiedNullDevice:
                    true,
                fixtureBuildAndCompilerRawOutputForwardingByteCount: 0,
                encodedCaptureExactASCIIHexTokenGrammarRequired: true,
                encodedCaptureReconstructedOnlyAfterByteGrammarAdmission: true,
                overflowDetectionUsesCapPlusOneByte: true,
                noCommandSubstitutionMayReceiveUnboundedProducerOutput: true),
            timingAdmission: .init(
                predecessorRunID: 32_348_627_200,
                predecessorReviewedJobObservedDurationSeconds: 3_210,
                currentReviewedJobTimeoutMinutes: 75,
                authorizedReviewedJobTimeoutMinutes: 90,
                activeRootJobTimeoutMinutesRemains: 45,
                soleWorkflowTimeoutMutationRequired: true,
                workflowJobAdditionCount: 0,
                workflowStepAdditionCount: 1,
                authorizedReviewedJobCeilingSeconds: 5_400,
                authorizedTimeoutIsPlatformCeilingNotCompletionGuarantee:
                    true,
                authorizedTimeoutPurpose:
                    "operational_margin_for_two_clean_release_builds_not_a_completion_or_retry_guarantee",
                timingMechanismIsWatchdog: false,
                additionalTimingStatePathCount: 0,
                preBuildTimingRefusalResultCodeCount: 0,
                timeoutCancellationOrAbruptTerminationHostedRecordCardinality:
                    "zero_or_one_based_on_whether_bounded_projection_completed_before_external_termination",
                timeoutCancellationOrAbruptTerminationObservedOnlyFromActionsMetadata:
                    true,
                timeoutCancellationOrAbruptTerminationMeasurementAttemptConsumption:
                    "unavailable_unless_separately_proved_by_sanitized_launcher_record_or_reviewed_log",
                timeoutCancellationOrAbruptTerminationEstablishesMeasurement:
                    false,
                timeoutCancellationOrAbruptTerminationEstablishesFixtureIdentity:
                    false,
                presentRecordUnderExternalTerminationRequiresMatchingCompletedWorkflowConclusionToBeAccepting:
                    true,
                timeoutCancellationOrAbruptTerminationRetiresOpportunity:
                    true),
            measurementRoots: .init(
                runnerTempEnvironmentKey: "RUNNER_TEMP",
                runnerTempMaximumUTF8ByteCount: 1_024,
                runnerTempMustBeNonemptyCanonicalAbsolutePhysicalDirectory:
                    true,
                runnerTempMustBeNonlinkAndOwnedByEffectiveUser: true,
                runnerTempPhysicalDeviceIdentityCaptured: true,
                runnerTempDeviceMustEqualFixedCanonicalExactCheckoutRootDevice:
                    true,
                fixedCanonicalExactCheckoutRootDeviceIsTrustedLocalBoundary:
                    true,
                fixedCanonicalExactCheckoutRootNameAndDescriptorJoinRequired:
                    true,
                fixedCanonicalExactCheckoutRootJoinAlsoBindsEvaluatorSourceAnchor:
                    true,
                privateBaseLeaf:
                    "prime-secure-child-validation-fixture-identity-measurement-root-v1",
                privateBaseMode: "0700",
                privateBaseMustInitiallyBeAbsentAndNonlink: true,
                privateBaseCreatedExclusivelyWithOwnerOnlyUmask: true,
                privateBaseMustBeCanonicalAbsolutePhysicalDirectory: true,
                privateBaseMustBeOwnedByEffectiveUserAndShareRunnerTempDevice:
                    true,
                privateBaseExactModeRequired: true,
                directoryAdmissionDescriptorNumber: 9,
                metadataExecutablePath: "/usr/bin/stat",
                metadataExactLocaleEnvironment: "LC_ALL=C",
                metadataFormat: "%d:%i:%u:%Lp",
                orderedDescriptorMetadataArguments: [
                    "literal_-f",
                    "literal_%d:%i:%u:%Lp",
                ],
                descriptorMetadataUsesNoFileOperandAndStdinRedirectedFromFixedDirectoryFD:
                    true,
                orderedNameMetadataArgumentPrefix: [
                    "literal_-f",
                    "literal_%d:%i:%u:%Lp",
                    "literal_--",
                ],
                nameMetadataUsesOneFixedCanonicalAbsoluteDirectoryOperand:
                    true,
                exactDirectoryIdentityJoinCount: 8,
                exactMetadataInvocationCountPerIdentityJoin: 2,
                exactMetadataInvocationAndCaptureCount: 16,
                metadataProducerMaximumByteCountIncludingTerminalLF: 58,
                normalizedMetadataMaximumByteCount: 57,
                normalizedMetadataExactASCIIGrammar:
                    "^(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,19}):(0|[1-9][0-9]{0,9}):[0-7]{3,4}$",
                metadataNumericConversionsUseCheckedExactWidths:
                    "device_UInt64_inode_UInt64_owner_UInt32_mode_UInt16",
                metadataProducerEmitsOneLFAndBashSubstitutionStripsOnlyThatLF:
                    true,
                directCommandSubstitutionAuthorizedOnlyForProvenFixedFormatBound:
                    true,
                metadataRawPathOutputFieldCount: 0,
                metadataNonzeroStatusOverflowGrammarOrIdentityMismatchFailureMappingByRole: [
                    "fixed_canonical_exact_checkout_root:MEASUREMENT_ROOT_REFUSED",
                    "runner_temp_or_private_base:MEASUREMENT_ROOT_REFUSED",
                    "exact_tree_source_a_or_b:SOURCE_ROOT_REFUSED",
                    "fixture_build_root_set_a_or_b:BUILD_ROOT_REFUSED",
                    "evaluator_root:EVALUATOR_ROOT_REFUSED",
                ],
                runnerTempAndPrivateBaseNameAndDescriptorStatRequiredAtAdmission:
                    true,
                runnerTempAndPrivateBaseDescriptorNameDeviceInodeJoinRequired:
                    true,
                admittedDirectoryIdentityStabilityReliesOnTrustedNoHostileConcurrentSameUIDBoundary:
                    true,
                exactTreeSourceRootLeaves: [
                    "exact-tree-source-a-v1",
                    "exact-tree-source-b-v1",
                ],
                fixtureBuildRootSetLeaves: [
                    "fixture-build-root-set-a-v1",
                    "fixture-build-root-set-b-v1",
                ],
                evaluatorRootLeaf:
                    "prime-secure-child-validation-fixture-identity-evaluator-root-v1",
                exactDirectChildRootLeafCount: 5,
                derivedRootMode: "0700",
                everyDerivedRootLeafMustBeSingleComponentWithoutSeparatorDotOrDotDot:
                    true,
                everyDerivedRootMustBeCanonicalAbsoluteDirectChildOfPrivateBase:
                    true,
                everyDerivedRootInitiallyAbsentAndNonlink: true,
                everyDerivedRootCreatedExclusivelyAsApplicable: true,
                everyDerivedRootOwnerDeviceModeAndDescriptorNameJoinRequired:
                    true,
                everyDerivedRootMustSharePrivateBaseDevice: true,
                derivedRootDeviceInodeIdentityTuplesMustBePairwiseDistinct:
                    true,
                derivedRootHardLinkSharingAuthorized: false,
                directoryLinkCountUsedAsStablePredicateAfterChildCreation:
                    false,
                evaluatorExecutableAbsolutePathMustDeriveOnlyFromPrivateBaseEvaluatorRootAndFixedLeaf:
                    true,
                allDirectoryAdmissionDescriptorsClosedBeforeEverySubsequentExternalCommand:
                    true,
                hostileConcurrentSameEffectiveUIDMutationOutsideThreatScope:
                    true),
            authorizedOnlyAfterAuthorityExactMainGreen: true,
            currentAuthorityExecutesMeasurement: false,
            mainPushOnly: true,
            requiredRepository: "Ergentics/ergentics-prime",
            requiredEvent: "push",
            requiredRef: "refs/heads/main",
            requiredRunAttempt: 1,
            authorityClosureRevisionAvailability: "deferred_until_signed_exact_main_merge",
            authorityClosureTreeAvailability: "deferred_until_signed_exact_main_merge",
            mechanicsRevisionMustBeDirectSuccessorOfAuthorityClosure: true,
            mechanicsFirstParentMustEqualAuthorityClosureRevision: true,
            mechanicsFirstParentTreeMustEqualAuthorityClosureTree: true,
            expectedMechanicsMergeParentCount: 2,
            exactFiveDeltaRequired: true,
            cleanDetachedCheckoutRequired: true,
            twoDisjointExactTreeSourceRootsRequired: true,
            sourceRootDeviceInodeIdentityTupleDisjointRequired: true,
            sourceRootsMustShareTrustedLocalDevice: true,
            sourceRootInodesMustDiffer: true,
            sourceRootsMustResolveToExactRevisionAndTree: true,
            sourceRootHardLinkSharingAuthorized: false,
            twoDisjointBuildRootSetsRequired: true,
            buildRootRoles: ["scratch", "cache", "config", "security"],
            buildRootMode: "0700",
            buildRootsMustInitiallyNotExistOrBeSymbolicLinks: true,
            measurementCreatedRootSetRoles: [
                "measurement_private_base",
                "exact_tree_source_a",
                "exact_tree_source_b",
                "fixture_build_root_set_a",
                "fixture_build_root_set_b",
                "evaluator_private_root",
            ],
            measurementCreatedRootSetCount: 6,
            measurementCreatedRootLauncherCleanupInvocationCount: 0,
            measurementCreatedRootsRetainedOnlyUntilOrdinaryEphemeralRunnerTeardown:
                true,
            measurementCreatedRootResidualFilesAreEvidence: false,
            measurementCreatedRootReuseOrRetryAuthorized: false,
            boundedRecordProjectionIsFinalDataProducingLauncherAction: true,
            boundedRecordProjectionUsesSingleBashBuiltinPrintf: true,
            onlyPostProjectionControlActionIsExactExitWithFrozenResultStatus:
                true,
            successResultLauncherExitStatus: 0,
            failureResultLauncherExitStatus: 1,
            buildConfiguration: "release",
            buildArgumentsMustMatchRetiredCanaryFixtureBuildExactly: true,
            additionalFixtureCompilerFlagCount: 0,
            debugPrefixMapAuthorized: false,
            expectedFixtureProductBuildCommandCount: 2,
            expectedShowBinPathCommandCount: 2,
            expectedSwiftRunCommandCount: 0,
            expectedSwiftTestCommandCount: 0,
            expectedFixtureExecutableInvocationCount: 0,
            expectedAdapterInvocationCount: 0,
            expectedLeaseAcquisitionCount: 0,
            expectedModelExecutionCount: 0,
            expectedMLXExecutionCount: 0,
            expectedMetalExecutionCount: 0,
            dependencyNetworkInvocationCount: 0,
            exactLocalMirrorReuseRequired: true,
            forceResolvedVersionsRequired: true,
            swiftPMSandboxRetained: true,
            fixtureTargetDirectDependencyCount: 0,
            fixturePackagePluginTargetCount: 0,
            fixturePackageMacroTargetCount: 0,
            fixturePackageBinaryTargetCount: 0,
            fixtureBuildGraphExecutesPackagePluginMacroOrBinaryTargetCode:
                false,
            allFixtureBuildAndShowBinSubprocessesMustBeWaitedAndReapedBeforeEvaluatorSourceAdmission:
                true,
            hostileConcurrentSameEffectiveUIDMutationWithinThreatScope:
                false,
            privateMode0700ClaimedToProtectAgainstHostileSameEffectiveUID:
                false,
            residualNameOpenTOCTOUAcceptedOnlyUnderTrustedNoHostileConcurrentSameUIDBoundary:
                true,
            releaseBuildAAndBByteIdentityCompared: true,
            releaseBuildAAndBSHA256Compared: true,
            releaseBuildAAndBMachOIdentityCompared: true,
            buildAndCompilerSubprocessesAreNotFixtureExecution: true,
            measurementAttemptConsumedImmediatelyBeforeFirstBuild: true,
            preBuildRefusalConsumesMeasurementAttempt: false,
            everyPostConsumptionOutcomeRetiresOpportunity: true,
            everyAdmissionSetupBuildEvaluatorOrAbsentOutcomeRetiresOpportunity:
                true,
            automaticRetryAuthorized: false,
            workflowRerunAuthorized: false,
            replacementMeasurementAuthorized: false,
            expectedActiveRootLatinTestCount: 116,
            expectedRootTestCount: 85,
            expectedIsolatedTestCount: 6,
            expectedFocusedWholeTestCount: 91,
            expectedRetainedLiveTestCount: 46,
            expectedAggregateTestCount: 137,
            expectedEmbeddedProvenanceRecordCount: 522,
            observationMustFreezeExistingSanitizedToolchainStepValues: true,
            observationMustFreezeReviewedJobLogIdentity: true,
            lcBuildVersionEstablishesSameCompilerIdentity: false,
            hostedRecord: .init(
                prefix: "prime-secure-child validation-fixture-identity measurement: ",
                schemaID: "prime_secure_child_validation_fixture_identity_measurement_outer_observation_v1",
                schemaVersion: 1,
                canonicalJSONRequired: true,
                exactLineCountWhenPresent: 1,
                terminalLFRequiredWhenPresent: true,
                maximumCanonicalJSONByteCount: 4_035,
                maximumTotalLineByteCount: 4_096,
                logicalFieldTypeContracts: [
                    "schema_id:string", "schema_version:int_1", "authority_id:string", "authority_canonical_sha256:lowercase_hex_64", "exact_revision:lowercase_git_sha_40", "opportunity_state:retired", "result_code:closed_enum", "measurement_attempt_consumed:bool", "build_a_command_state:closed_enum", "show_bin_a_command_state:closed_enum", "build_b_command_state:closed_enum", "show_bin_b_command_state:closed_enum", "evaluator_compile_state:closed_enum", "evaluator_command_state:closed_enum", "evaluator_execution_observation:closed_enum", "evaluator_shell_wait_status:null_or_uint8", "fixture_a_byte_count:null_or_int_1_through_4194304", "fixture_a_sha256:null_or_lowercase_hex_64", "fixture_a_macho_uuid:null_or_lowercase_hex_32", "fixture_a_build_platform_packed:null_or_uint32_equal_PLATFORM_MACOS", "fixture_a_minimum_os_packed:null_or_uint32", "fixture_a_sdk_packed:null_or_uint32", "fixture_b_byte_count:null_or_int_1_through_4194304", "fixture_b_sha256:null_or_lowercase_hex_64", "fixture_b_macho_uuid:null_or_lowercase_hex_32", "fixture_b_build_platform_packed:null_or_uint32_equal_PLATFORM_MACOS", "fixture_b_minimum_os_packed:null_or_uint32", "fixture_b_sdk_packed:null_or_uint32", "byte_count_equal:closed_enum", "sha256_equal:closed_enum", "full_bytes_equal:closed_enum", "macho_identity_equal:closed_enum", "current_pin_byte_count_match:closed_enum", "current_pin_sha256_match:closed_enum", "current_pin_full_match:closed_enum", "raw_path_count:int_0", "raw_build_output_or_error_field_count:int_0", "fixture_execution_count:int_0", "actions_artifact:bool_false", "scientific_outcome:not_established", "durable_evidence:bool_false", "pin_mutation_performed:bool_false", "canary_execution_performed:bool_false",
                ],
                exactCanonicalWireOrderedKeys: [
                    "actions_artifact",
                    "authority_canonical_sha256",
                    "authority_id",
                    "build_a_command_state",
                    "build_b_command_state",
                    "byte_count_equal",
                    "canary_execution_performed",
                    "current_pin_byte_count_match",
                    "current_pin_full_match",
                    "current_pin_sha256_match",
                    "durable_evidence",
                    "evaluator_command_state",
                    "evaluator_compile_state",
                    "evaluator_execution_observation",
                    "evaluator_shell_wait_status",
                    "exact_revision",
                    "fixture_a_build_platform_packed",
                    "fixture_a_byte_count",
                    "fixture_a_macho_uuid",
                    "fixture_a_minimum_os_packed",
                    "fixture_a_sdk_packed",
                    "fixture_a_sha256",
                    "fixture_b_build_platform_packed",
                    "fixture_b_byte_count",
                    "fixture_b_macho_uuid",
                    "fixture_b_minimum_os_packed",
                    "fixture_b_sdk_packed",
                    "fixture_b_sha256",
                    "fixture_execution_count",
                    "full_bytes_equal",
                    "macho_identity_equal",
                    "measurement_attempt_consumed",
                    "opportunity_state",
                    "pin_mutation_performed",
                    "raw_build_output_or_error_field_count",
                    "raw_path_count",
                    "result_code",
                    "schema_id",
                    "schema_version",
                    "scientific_outcome",
                    "sha256_equal",
                    "show_bin_a_command_state",
                    "show_bin_b_command_state",
                ],
                exactCanonicalWireGrammar:
                    "fixed_ASCII_prefix_then_UTF8_ASCII_only_single_object_lexicographically_sorted_exact_keys_no_BOM_or_whitespace_exact_JSON_bool_null_and_canonical_nonnegative_decimal_no_leading_zero_fixed_strings_enums_hex_and_platform_then_exactly_one_LF",
                exactFieldCount: 43,
                exactResultCodes: [
                    "PASS_IDENTICAL_CURRENT_PIN", "PASS_IDENTICAL_DIFFERENT_PIN", "NONDETERMINISTIC_BUILD", "INVOCATION_ADMISSION_REFUSED", "MEASUREMENT_ROOT_REFUSED", "SOURCE_ROOT_REFUSED", "BUILD_ROOT_REFUSED", "MIRROR_REFUSED", "BUILD_A_REFUSED", "SHOW_BIN_A_REFUSED", "SHOW_BIN_A_TRANSPORT_REFUSED", "ARTIFACT_A_ADMISSION_REFUSED", "BUILD_B_REFUSED", "SHOW_BIN_B_REFUSED", "SHOW_BIN_B_TRANSPORT_REFUSED", "ARTIFACT_B_ADMISSION_REFUSED", "EVALUATOR_ROOT_REFUSED", "EVALUATOR_SOURCE_REFUSED", "EVALUATOR_COMPILE_REFUSED", "EVALUATOR_ADMISSION_REFUSED", "EVALUATOR_TRANSPORT_REFUSED", "EVALUATOR_COMMAND_REFUSED", "EVALUATOR_CONTRACT_REFUSED", "CAPTURE_REFUSED", "UNCLASSIFIED",
                ],
                commandStateMembers: [
                    "not_attempted", "succeeded", "failed", "unavailable",
                ],
                executionObservationMembers: [
                    "observed_false", "observed_true", "unavailable",
                ],
                comparisonStateMembers: ["false", "true", "unavailable"],
                evaluatorCommandExecutionAndWaitFieldsApplyOnlyToSoleFixtureIdentityInvocation:
                    true,
                exactResultStateInvariants: [
                    resultInvariant(
                        "PASS_IDENTICAL_CURRENT_PIN",
                        consumed: true,
                        predicate:
                            "full_bytes_equal_and_each_artifact_matches_current_byte_count_and_sha256",
                        workflowConclusion: "success",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "succeeded", evaluator: "succeeded",
                        observation: "observed_true", wait: "uint8_zero",
                        identity: "both_artifacts_complete",
                        buildAB: "all_four_true", pin: "all_three_true"),
                    resultInvariant(
                        "PASS_IDENTICAL_DIFFERENT_PIN",
                        consumed: true,
                        predicate:
                            "full_bytes_equal_and_equal_artifacts_do_not_match_current_byte_count_or_sha256",
                        workflowConclusion: "success",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "succeeded", evaluator: "succeeded",
                        observation: "observed_true", wait: "uint8_zero",
                        identity: "both_artifacts_complete",
                        buildAB: "all_four_true",
                        pin:
                            "all_three_boolean_full_false_and_at_least_one_dimension_false"),
                    resultInvariant(
                        "NONDETERMINISTIC_BUILD",
                        consumed: true,
                        predicate:
                            "complete_artifacts_are_not_full_byte_equal_and_no_pin_repair_is_permitted",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "succeeded", evaluator: "succeeded",
                        observation: "observed_true", wait: "uint8_zero",
                        identity: "both_artifacts_complete",
                        buildAB:
                            "all_four_boolean_and_full_bytes_false_other_three_may_be_either_boolean"),
                    resultInvariant(
                        "INVOCATION_ADMISSION_REFUSED",
                        consumed: false,
                        predicate:
                            "repository_event_ref_revision_attempt_clean_checkout_or_fixed_capture_tool_null_device_admission_refused"),
                    resultInvariant(
                        "MEASUREMENT_ROOT_REFUSED",
                        consumed: false,
                        predicate:
                            "fixed_canonical_exact_checkout_root_or_canonical_physical_runner_temp_descriptor_name_identity_trusted_device_join_or_fixed_private_measurement_base_initial_absence_exclusive_creation_mode_owner_device_descriptor_name_identity_or_fixed_direct_child_leaf_grammar_and_lexical_derivation_refused_before_child_creation_and_first_build_actual_child_creation_maps_only_to_role_specific_refusal"),
                    resultInvariant(
                        "SOURCE_ROOT_REFUSED",
                        consumed: false,
                        predicate:
                            "exact_tree_source_root_identity_or_disjointness_refused_before_first_build"),
                    resultInvariant(
                        "BUILD_ROOT_REFUSED",
                        consumed: false,
                        predicate:
                            "private_fixture_build_root_identity_mode_or_disjointness_refused_before_first_build"),
                    resultInvariant(
                        "MIRROR_REFUSED",
                        consumed: false,
                        predicate:
                            "exact_local_mirror_or_force_resolved_admission_refused_before_first_build"),
                    resultInvariant(
                        "BUILD_A_REFUSED",
                        consumed: true,
                        predicate:
                            "first_exact_fixture_product_build_returned_nonzero",
                        buildA: "failed"),
                    resultInvariant(
                        "SHOW_BIN_A_REFUSED",
                        consumed: true,
                        predicate:
                            "valid_first_pipeline_status_envelope_established_show_bin_a_producer_nonzero_before_any_payload_validation",
                        buildA: "succeeded", showA: "failed"),
                    resultInvariant(
                        "SHOW_BIN_A_TRANSPORT_REFUSED",
                        consumed: true,
                        predicate:
                            "first_show_bin_pipeline_status_envelope_missing_or_invalid_so_producer_status_is_unavailable",
                        buildA: "succeeded", showA: "unavailable"),
                    resultInvariant(
                        "ARTIFACT_A_ADMISSION_REFUSED",
                        consumed: true,
                        predicate:
                            "valid_first_pipeline_status_envelope_established_producer_zero_but_reader_encoder_cap_payload_grammar_or_artifact_a_path_leaf_admission_failed",
                        buildA: "succeeded", showA: "succeeded"),
                    resultInvariant(
                        "BUILD_B_REFUSED",
                        consumed: true,
                        predicate:
                            "second_exact_fixture_product_build_returned_nonzero",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "failed"),
                    resultInvariant(
                        "SHOW_BIN_B_REFUSED",
                        consumed: true,
                        predicate:
                            "valid_second_pipeline_status_envelope_established_show_bin_b_producer_nonzero_before_any_payload_validation",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "failed"),
                    resultInvariant(
                        "SHOW_BIN_B_TRANSPORT_REFUSED",
                        consumed: true,
                        predicate:
                            "second_show_bin_pipeline_status_envelope_missing_or_invalid_so_producer_status_is_unavailable",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "unavailable"),
                    resultInvariant(
                        "ARTIFACT_B_ADMISSION_REFUSED",
                        consumed: true,
                        predicate:
                            "valid_second_pipeline_status_envelope_established_producer_zero_but_reader_encoder_cap_payload_grammar_or_artifact_b_path_leaf_admission_failed",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded"),
                    resultInvariant(
                        "EVALUATOR_ROOT_REFUSED",
                        consumed: true,
                        predicate:
                            "post_artifact_b_private_evaluator_root_initial_absence_exclusive_creation_mode_physical_owner_or_device_admission_refused",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded"),
                    resultInvariant(
                        "EVALUATOR_SOURCE_REFUSED",
                        consumed: true,
                        predicate:
                            "post_artifact_b_git_C_fixed_canonical_exact_checkout_root_status_only_no_external_diff_no_textconv_evaluator_source_match_against_exact_mechanics_revision_and_embedded_provenance_identity_refused_immediately_before_same_root_absolute_source_compiler_operand",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded"),
                    resultInvariant(
                        "EVALUATOR_COMPILE_REFUSED",
                        consumed: true,
                        predicate:
                            "post_artifact_b_fixed_swiftc_evaluator_compilation_returned_nonzero",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "failed"),
                    resultInvariant(
                        "EVALUATOR_ADMISSION_REFUSED",
                        consumed: true,
                        predicate:
                            "post_artifact_b_swiftc_returned_zero_but_canonical_private_regular_nonlink_single_link_owner_executable_evaluator_leaf_admission_refused",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "succeeded"),
                    resultInvariant(
                        "EVALUATOR_TRANSPORT_REFUSED",
                        consumed: true,
                        predicate:
                            "fixture_identity_pipeline_status_envelope_missing_or_invalid_so_evaluator_producer_status_and_invocation_are_unavailable",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "succeeded", evaluator: "unavailable",
                        observation: "unavailable", wait: "null"),
                    resultInvariant(
                        "EVALUATOR_COMMAND_REFUSED",
                        consumed: true,
                        predicate:
                            "valid_fixture_identity_pipeline_status_envelope_established_evaluator_producer_nonzero_or_signal_status_before_any_payload_validation_and_image_execution_is_not_established",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "succeeded", evaluator: "failed",
                        observation: "unavailable", wait: "uint8_nonzero"),
                    resultInvariant(
                        "EVALUATOR_CONTRACT_REFUSED",
                        consumed: true,
                        predicate:
                            "valid_fixture_identity_pipeline_status_envelope_established_producer_reader_encoder_zero_and_bounded_payload_failed_exact_canonical_schema_or_cross_field_validation",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "succeeded", evaluator: "succeeded",
                        observation: "observed_true", wait: "uint8_zero"),
                    resultInvariant(
                        "CAPTURE_REFUSED",
                        consumed: true,
                        predicate:
                            "valid_fixture_identity_pipeline_status_envelope_established_producer_zero_but_reader_encoder_or_cap_plus_one_payload_capture_refused_and_outer_exit_projection_succeeded_without_partial_identity",
                        buildA: "succeeded", showA: "succeeded",
                        buildB: "succeeded", showB: "succeeded",
                        compile: "succeeded", evaluator: "succeeded",
                        observation: "observed_true", wait: "uint8_zero"),
                    resultInvariant(
                        "UNCLASSIFIED",
                        consumed: false,
                        predicate:
                            "fail_closed_pre_command_state_only_and_never_a_post_attempt_wildcard"),
                ],
                everyResultCodeCoveredExactlyOnce: true,
                successResultCodes: [
                    "PASS_IDENTICAL_CURRENT_PIN",
                    "PASS_IDENTICAL_DIFFERENT_PIN",
                ],
                failureResultCodes: [
                    "NONDETERMINISTIC_BUILD",
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
                onlySuccessResultCodesMayConcludeWorkflowSuccess: true,
                everyFailureResultCodeRequiresNonzeroWorkflowConclusion: true,
                presentRecordAcceptingOnlyWhenWorkflowConclusionMatchesResultInvariant:
                    true,
                identityFieldsNullableBeforeMeasurement: true,
                identityFieldsRequiredAfterSuccessfulAcceptedEvaluatorReturn:
                    true,
                currentPinComparisonRequiredAfterFullyIdenticalEvaluatorReturn:
                    true,
                currentPinComparisonSemantics:
                    "only_after_full_byte_identity_both_artifacts_individually_match_current_byte_count_and_sha256_else_unavailable",
                rawAbsolutePathFieldCount: 0,
                rawBuildOutputOrErrorFieldCount: 0,
                exactRecordCountForEveryLauncherControlledOutcome: 1,
                launcherControlledReturnAlwaysProjectsExactlyOneRecord: true,
                maximumRecordCountPerWorkflowRun: 1,
                exactRecordCountOnReachedTerminalEvaluatorPath: 1,
                boundedExitProjectionRequired: true,
                exitProjectionMustBeIdempotentAndAtMostOnce: true,
                preEvaluatorBuildOrCompileFailureMayHaveNoRecord: false,
                recordMayBeAbsentOnExternalTimeoutCancellationAbruptProcessHostOrRunnerTerminationBeforeOrAfterLauncherStart:
                    true,
                launcherNotReachedHostedRecordCount: 0,
                launcherNotReachedObservedOnlyFromActionsMetadata: true,
                launcherNotReachedEstablishesMeasurementOrIdentity: false,
                launcherNotReachedRetiresOpportunity: true,
                actionsArtifactCount: 0,
                scientificOutcome: "not_established",
                durableEvidence: false,
                pinMutationPerformed: false,
                canaryExecutionPerformed: false,
                absentExternalTerminationMeasurementAttemptConsumption:
                    "unavailable_unless_separately_proved_by_sanitized_launcher_record_or_reviewed_log",
                absentRecordEstablishesMeasurement: false,
                absentRecordEstablishesFixtureIdentity: false,
                everyRecordOrAbsentRecordOutcomeRetiresOpportunity: true)),
        retirementBoundary: .init(
            disposition: "observe_once_then_irrevocably_retire",
            appendOnlyObservationRequiredAfterEveryOutcome: true,
            successRequiresObservationAndRetirement: true,
            buildFailureRequiresObservationAndRetirement: true,
            evaluatorFailureRequiresObservationAndRetirement: true,
            mismatchRequiresObservationAndRetirement: true,
            cancellationRequiresObservationAndRetirement: true,
            abruptHostLossRequiresObservationFromActionsMetadata: true,
            observationAndRetirementMustBeNextAuthorizedChange: true,
            launcherSourceRetainedForAuditAfterRetirement: true,
            evaluatorSourceRetainedForAuditAfterRetirement: true,
            currentPinPassRequiresSeparateNoMutationConfirmationAuthority:
                true,
            currentPinPassConfirmationPinMutationCount: 0,
            pinRepairAuthorityMustBeSeparate: true,
            pinRepairImplementationMustNotLaunchFixture: true,
            pinRepairExactMainIndependentHostedRemeasurementRequired: true,
            pinRepairConfirmationFixtureExecutionCount: 0,
            crossRunIdentityConfirmationFields: [
                "within_each_run_build_a_b_full_byte_equality",
                "cross_run_byte_count",
                "cross_run_sha256",
                "cross_run_macho_uuid",
                "cross_run_macho_platform_minimum_os_packed_sdk_packed",
            ],
            crossRunSHA256EqualityCoversEveryArtifactByteIncludingLCBuildVersionTools:
                true,
            crossRunIdentityMatchRequiredBeforeCanaryAuthority: true,
            bothSuccessResultBranchesRequireCrossRunConfirmation: true,
            successBranchConfirmationObservationAndRetirementRequired: true,
            automaticRetryAuthorized: false,
            workflowRerunAuthorized: false,
            replacementMeasurementAuthorized: false,
            orderedLaterBoundaries: [
                "append_only_measurement_observation_and_retirement",
                "pass_identical_current_pin_branch_separately_authorizes_no_pin_mutation_hosted_confirmation_run",
                "pass_identical_different_pin_branch_separately_authorizes_exact_pin_repair_and_nonlaunching_hosted_confirmation_run",
                "nondeterministic_or_refusal_branch_authorizes_no_pin_repair_confirmation_or_canary",
                "either_success_branch_requires_within_run_full_byte_equality_and_cross_run_record_identity_match",
                "observe_and_retire_the_branch_specific_confirmation_before_any_canary_authority",
                "separately_authorize_one_shot_real_monitor_held_lease_containment_canary",
                "observe_and_retire_that_canary_before_durable_layer_b",
            ]),
        languageBoundary: .init(
            authorityLanguage: "swift_foundation_codable_data_only",
            laterLauncherLanguage: "closed_bash",
            laterEvaluatorLanguage: "standalone_swift",
            evaluatorUsesCryptoKit: true,
            pythonPermitted: false,
            pythonInvocationCount: 0,
            pythonSourcePathCount: 0,
            cppPermitted: false,
            cppInvocationCount: 0,
            cppSourcePathCount: 0),
        authorityCeiling: .init(
            measurementAuthorityEstablished: true,
            laterExactFiveMeasurementAuthorizedAfterClosure: true,
            measurementMechanicsPerformed: false,
            launcherSourceAdded: false,
            evaluatorSourceAdded: false,
            compilerInvocationAuthorizedInThisPatch: false,
            evaluatorInvocationAuthorizedInThisPatch: false,
            filesystemReadAuthorizedInThisPatch: false,
            filesystemWriteAuthorizedInThisPatch: false,
            descriptorInspectionAuthorizedInThisPatch: false,
            processExecutionAuthorizedInThisPatch: false,
            fixtureBuildAuthorizedInThisPatch: false,
            fixtureExecutionAuthorizedInThisPatch: false,
            adapterExecutionAuthorizedInThisPatch: false,
            leaseAcquisitionAuthorizedInThisPatch: false,
            modelExecutionAuthorizedInThisPatch: false,
            networkAuthorizedInThisPatch: false,
            measuredFixtureIdentityEstablished: false,
            repeatBuildDeterminismEstablished: false,
            currentPinMatchEstablished: false,
            fixturePinMutationAuthorized: false,
            fixturePinMutationPerformed: false,
            fixturePinRepairAuthorityEstablished: false,
            fixturePinRepairImplementationAuthorized: false,
            layerAMutationAuthorized: false,
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
            publicationAuthorized: false),
        orderedRequiredSeparateActions: [
            "merge_and_close_this_pure_exact5_measurement_authority",
            "implement_only_the_separately_reviewed_exact5_native_measurement_mechanics",
            "observe_and_irrevocably_retire_every_measurement_outcome_without_retry_or_rerun",
            "for_pass_identical_current_pin_separately_authorize_no_mutation_hosted_identity_confirmation",
            "for_pass_identical_different_pin_separately_authorize_exact_pin_repair_plus_nonlaunching_hosted_identity_confirmation",
            "for_nondeterministic_or_refusal_stop_without_pin_repair_confirmation_or_canary",
            "observe_and_retire_the_success_branch_cross_run_confirmation_and_freeze_sanitized_toolchain_and_log_identity",
            "separately_authorize_the_monitor_held_lease_secure_child_containment_canary",
            "observe_and_retire_that_canary_before_durable_layer_b",
        ])

    private static func resultInvariant(
        _ resultCode: String,
        consumed: Bool,
        predicate: String,
        workflowConclusion: String = "failure",
        buildA: String = "not_attempted",
        showA: String = "not_attempted",
        buildB: String = "not_attempted",
        showB: String = "not_attempted",
        compile: String = "not_attempted",
        evaluator: String = "not_attempted",
        observation: String = "observed_false",
        wait: String = "null",
        identity: String = "all_identity_fields_null",
        buildAB: String = "all_four_unavailable",
        pin: String = "all_three_unavailable"
    ) -> HostedRecordContract.ResultStateInvariant {
        .init(
            resultCode: resultCode,
            workflowConclusion: workflowConclusion,
            measurementAttemptConsumed: consumed,
            buildACommandState: buildA,
            showBinACommandState: showA,
            buildBCommandState: buildB,
            showBinBCommandState: showB,
            evaluatorCompileState: compile,
            evaluatorCommandState: evaluator,
            evaluatorExecutionObservation: observation,
            evaluatorShellWaitStatusContract: wait,
            identityFieldContract: identity,
            buildABComparisonContract: buildAB,
            currentPinComparisonContract: pin,
            additionalPredicate: predicate)
    }

    public func canonicalData() throws -> Data {
        try validate()
        return try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 131_072 else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try PrimeCanonicalJSON.encode(value) == data else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityError
                .noncanonicalEncoding
        }
        return value
    }

    public func validate() throws {
        guard self == Self.frozenV1 else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityError
                .contractDrift
        }
    }

    public func validateExactV1() throws {
        try validate()
        let canonical = try PrimeCanonicalJSON.encode(self)
        guard canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256
        else {
            throw PrimeSecureChildValidationFixtureIdentityMeasurementAuthorityError
                .contractDrift
        }
    }
}
