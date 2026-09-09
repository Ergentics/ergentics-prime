// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Exact environment policy for the separately authorized seed-43 repair.
///
/// The exhausted seed-42 policy remains frozen. This declaration reuses its
/// environment checks while granting only one new source materialization,
/// one public V2 write, and one public V2 fresh load.
public enum
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEnvironmentPolicyV1
{
    public static let declaration =
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1(
            schemaVersion: 1,
            policyID:
                "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_environment_v1",
            policyVersion: 1,
            scope:
                "one_seed43_native300m_v2_checkpoint_root_identity_repair_write_and_one_fresh_load",
            predecessorPolicyID:
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
                    .declaration.policyID,
            predecessorPolicyVersion:
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
                    .declaration.policyVersion,
            predecessorRemainsFrozen: true,
            exactMLXRevision:
                "d37885a278f1c37484a94d0f401a418735e66519",
            requiredEnvironmentKey: "MLX_ENABLE_TF32",
            requiredEnvironmentValue: "0",
            exclusiveEnvironmentKeyPrefix: "MLX_",
            forbiddenEnvironmentKeyPrefixes: [
                "DYLD_",
                "LLVM_PROFILE_",
            ],
            numericMode:
                "float32_checkpoint_materialization_tf32_disabled",
            comparisonPolicy:
                "exact_manifest_catalog_shape_dtype_count_and_logical_tensor_hash_via_pinned_codec_with_repaired_root_publication_snapshot",
            authorityCeiling:
                "one_process_local_seed43_native300m_source_materialization_one_v2_write_one_fresh_v2_load_no_forward_backward_retry_artifact_admission_upload_or_retention"
        )

    @discardableResult
    public static func validateInherited(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        _ = try
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
                .validateInherited(environment: environment)
        return declaration
    }

    @discardableResult
    public static func validateLaunched(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        _ = try
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
                .validateLaunched(environment: environment)
        return declaration
    }

    /// Must precede CoreGraphics, Metal, MLX, model, or checkpoint access.
    @discardableResult
    public static func validateLaunchedCurrentProcess(
        processInfo: ProcessInfo = .processInfo
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        try validateLaunched(environment: processInfo.environment)
    }
}

/// Execution-observed snapshot of the private ephemeral artifact root.
///
/// Publication may legitimately change a directory's link count and its
/// modification/change timestamps. Those fields remain positive/valid
/// telemetry, but they are deliberately excluded from the pre-write to
/// post-write stable-object comparison. A read-only load must leave the full
/// post-write snapshot unchanged.
public struct
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let deviceID: UInt64
    public let inode: UInt64
    public let ownerUserID: UInt32
    public let ownerGroupID: UInt32
    public let permissionMode: UInt16
    public let linkCount: UInt64
    public let modificationTimeSeconds: Int64
    public let modificationTimeNanoseconds: Int64
    public let changeTimeSeconds: Int64
    public let changeTimeNanoseconds: Int64

    public init(
        deviceID: UInt64,
        inode: UInt64,
        ownerUserID: UInt32,
        ownerGroupID: UInt32,
        permissionMode: UInt16,
        linkCount: UInt64,
        modificationTimeSeconds: Int64,
        modificationTimeNanoseconds: Int64,
        changeTimeSeconds: Int64,
        changeTimeNanoseconds: Int64
    ) {
        self.deviceID = deviceID
        self.inode = inode
        self.ownerUserID = ownerUserID
        self.ownerGroupID = ownerGroupID
        self.permissionMode = permissionMode
        self.linkCount = linkCount
        self.modificationTimeSeconds = modificationTimeSeconds
        self.modificationTimeNanoseconds = modificationTimeNanoseconds
        self.changeTimeSeconds = changeTimeSeconds
        self.changeTimeNanoseconds = changeTimeNanoseconds
    }

    public func validatePrivateDirectory() throws {
        guard deviceID > 0,
              inode > 0,
              permissionMode == 0o700,
              linkCount > 0,
              (0 ..< 1_000_000_000).contains(
                  modificationTimeNanoseconds),
              (0 ..< 1_000_000_000).contains(changeTimeNanoseconds)
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
    }

    /// Stable identity/access-policy fields across publication. Directory
    /// link count and timestamps are intentionally excluded.
    public func publicationStableObjectFieldsEqual(
        to other: Self
    ) -> Bool {
        linkCount > 0
            && other.linkCount > 0
            && deviceID == other.deviceID
            && inode == other.inode
            && ownerUserID == other.ownerUserID
            && ownerGroupID == other.ownerGroupID
            && permissionMode == other.permissionMode
    }

    /// The public load is read-only, so every recorded root field must match.
    public func readOnlyFullIdentityEqual(
        to other: Self
    ) -> Bool {
        self == other
    }

    private enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case inode
        case ownerUserID = "owner_user_id"
        case ownerGroupID = "owner_group_id"
        case permissionMode = "permission_mode"
        case linkCount = "link_count"
        case modificationTimeSeconds = "modification_time_seconds"
        case modificationTimeNanoseconds =
            "modification_time_nanoseconds"
        case changeTimeSeconds = "change_time_seconds"
        case changeTimeNanoseconds = "change_time_nanoseconds"
    }
}

public enum
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityComparatorV1
{
    public static func validatePublicationTransition(
        beforeWrite: PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1,
        afterWrite: PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1
    ) throws {
        do {
            try beforeWrite.validatePrivateDirectory()
            try afterWrite.validatePrivateDirectory()
        } catch {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
        guard beforeWrite.publicationStableObjectFieldsEqual(
                to: afterWrite)
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
    }

    public static func validateReadOnlyTransition(
        afterWrite: PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1,
        afterLoad: PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1
    ) throws {
        do {
            try afterWrite.validatePrivateDirectory()
            try afterLoad.validatePrivateDirectory()
        } catch {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
        guard afterWrite.readOnlyFullIdentityEqual(to: afterLoad) else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
    }
}

/// Pure local fixture proving the precise comparator delta. The 2 -> 3 -> 3
/// link-count sequence is a diagnosed APFS fixture, not hosted-run telemetry.
public struct
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairComparatorProofV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let proofID: String
    public let fixtureKind: String
    public let fixtureIsFailedHostedRunTelemetry: Bool
    public let linkCountBeforeWrite: UInt64
    public let linkCountAfterWrite: UInt64
    public let linkCountAfterLoad: UInt64
    public let oldComparatorRejectedPublicationTransition: Bool
    public let oldComparatorAcceptedReadOnlyTransition: Bool
    public let repairedComparatorAcceptedPublicationTransition: Bool
    public let repairedComparatorAcceptedReadOnlyTransition: Bool

    public static let frozenV1: Self = {
        let oldBefore =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1(
                deviceID: 1,
                inode: 2,
                ownerUserID: 501,
                ownerGroupID: 20,
                permissionMode: 0o700,
                linkCount: 2,
                modificationTimeSeconds: 3,
                modificationTimeNanoseconds: 4,
                changeTimeSeconds: 5,
                changeTimeNanoseconds: 6)
        let oldAfterWrite =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1(
                deviceID: 1,
                inode: 2,
                ownerUserID: 501,
                ownerGroupID: 20,
                permissionMode: 0o700,
                linkCount: 3,
                modificationTimeSeconds: 7,
                modificationTimeNanoseconds: 8,
                changeTimeSeconds: 9,
                changeTimeNanoseconds: 10)
        let repairedBefore =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1(
                deviceID: 1,
                inode: 2,
                ownerUserID: 501,
                ownerGroupID: 20,
                permissionMode: 0o700,
                linkCount: 2,
                modificationTimeSeconds: 3,
                modificationTimeNanoseconds: 4,
                changeTimeSeconds: 5,
                changeTimeNanoseconds: 6)
        let repairedAfterWrite =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1(
                deviceID: 1,
                inode: 2,
                ownerUserID: 501,
                ownerGroupID: 20,
                permissionMode: 0o700,
                linkCount: 3,
                modificationTimeSeconds: 7,
                modificationTimeNanoseconds: 8,
                changeTimeSeconds: 9,
                changeTimeNanoseconds: 10)
        return Self(
            schemaVersion: 1,
            proofID:
                "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_comparator_proof_v1",
            fixtureKind:
                "local_apfs_directory_single_regular_leaf_addition_2_to_3_then_read_only_3",
            fixtureIsFailedHostedRunTelemetry: false,
            linkCountBeforeWrite: 2,
            linkCountAfterWrite: 3,
            linkCountAfterLoad: 3,
            oldComparatorRejectedPublicationTransition:
                !oldBefore.stableObjectFieldsEqual(to: oldAfterWrite),
            oldComparatorAcceptedReadOnlyTransition:
                oldAfterWrite.stableObjectFieldsEqual(to: oldAfterWrite),
            repairedComparatorAcceptedPublicationTransition:
                repairedBefore.publicationStableObjectFieldsEqual(
                    to: repairedAfterWrite),
            repairedComparatorAcceptedReadOnlyTransition:
                repairedAfterWrite.readOnlyFullIdentityEqual(
                    to: repairedAfterWrite))
    }()

    public func validateExactV1() throws {
        guard self == Self.frozenV1,
              schemaVersion == 1,
              !fixtureIsFailedHostedRunTelemetry,
              linkCountBeforeWrite == 2,
              linkCountAfterWrite == 3,
              linkCountAfterLoad == 3,
              oldComparatorRejectedPublicationTransition,
              oldComparatorAcceptedReadOnlyTransition,
              repairedComparatorAcceptedPublicationTransition,
              repairedComparatorAcceptedReadOnlyTransition
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
    }
}

/// Append-only authority for the one exact seed-43 root-identity repair run.
///
/// The failed seed-42 attempt is consumed and cannot be rerun. This plan is
/// valid only for attempt one of the direct reviewed-main successor of the
/// failure-observation merge. It authorizes one new write and one new load,
/// and observes neither. Its artifact is process/job-local and must be removed
/// only by the bounded supervisor after a successful receipt is validated, or
/// by the conservative fixed-root failure trap without producing success
/// evidence.
public struct
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let predecessorFailureObservationID: String
    public let exhaustedPredecessorAuthorityID: String
    public let exhaustedPredecessorEvidenceID: String
    public let predecessorFailureObservationRemainsFrozen: Bool
    public let predecessorFailureObservationRequiredForConsumption: Bool
    public let exhaustedPredecessorAttemptCannotBeRerun: Bool

    public let authoritativeRepository: String
    public let baseRef: String
    public let baseRevision: String
    public let baseOrderedParentRevisions: [String]
    public let baseTree: String
    public let baseReviewedPullRequestHeadRevision: String
    public let baseReviewedPullRequestHeadTree: String
    public let baseEmbeddedSourceIdentitySHA256: String
    public let basePullRequestNumber: Int
    public let baseHistoryPreservingTwoParentMerge: Bool
    public let baseSourceBindings:
        [PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1]

    public let exactMLXRepository: String
    public let exactMLXRevision: String
    public let exactMLXCoreRevision: String
    public let exactMLXCRevision: String
    public let exactSwiftNumericsRevision: String
    public let environmentPolicy:
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1

    public let authoritativeExecutionPackagePath: String
    public let authoritativeExecutionProduct: String
    public let authoritativeExecutionTarget: String
    public let authoritativeExecutionTargetDependencies: [String]
    public let authorityTestTarget: String
    public let executionProbeSourcePath: String
    public let authorityTestSourcePath: String
    public let executionPackageManifestPath: String
    public let executionPackageResolvedPath: String
    public let executionLauncherPath: String
    public let executionEvidenceSourcePath: String
    public let publicExecutionEvidenceType: String
    public let publicExternalBindingType: String
    public let publicRootIdentityType: String
    public let publicRootIdentityComparatorType: String
    public let publicEnvironmentPolicyType: String
    public let publicCanonicalReceiptDeclaration: String
    public let publicCanonicalReceiptDecodeDeclaration: String
    public let newExecutionSourceIdentityStatus: String
    public let newExecutionSourceBindings:
        [PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1]

    public let configuration:
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityConfigurationV1
    public let initializationSeed: UInt64
    public let compatibilityIdentitySchema: String
    public let compatibilityIdentityCanonicalByteCount: Int
    public let compatibilityIdentitySHA256: String
    public let parameterDescriptorCount: Int
    public let parameterCatalogCanonicalByteCount: Int
    public let parameterCatalogSHA256: String
    public let totalParameterCount: UInt64
    public let totalParameterByteCount: UInt64

    public let artifactRootRunnerTemporaryRelativePath: String
    public let artifactRelativePath: String
    public let artifactPurpose: String
    public let maximumCheckpointByteCount: UInt64
    public let maximumManifestByteCount: UInt64
    public let requiredArtifactRootMode: UInt16
    public let requiredPublishedArtifactMode: UInt16
    public let requiredPublishedArtifactLinkCount: UInt64
    public let requiredArtifactRootEntryCountBeforeWrite: Int
    public let requiredArtifactRootEntryCountAfterWrite: Int
    public let requiredArtifactRootEntryNamesBeforeWrite: [String]
    public let requiredArtifactRootEntryNamesAfterWrite: [String]
    public let publishedArtifactMustBeRegularFile: Bool
    public let publishedArtifactMustNotBeSymbolicLink: Bool
    public let publishedArtifactDeviceMustMatchRoot: Bool
    public let publishedArtifactOwnerMustMatchEffectiveUser: Bool
    public let rootLinkCountMustRemainPositive: Bool
    public let rootLinkCountEqualityAcrossPublicationRequired: Bool
    public let rootTimestampsEqualityAcrossPublicationRequired: Bool
    public let rootFullIdentityEqualityAcrossReadOnlyLoadRequired: Bool
    public let requiredFreeSpaceMultiplier: UInt64
    public let requiredAvailableFilesystemBytesAfterBuild: UInt64
    public let requiredMemoryCacheLimit: Int
    public let requiredMemoryCacheClearCount: Int

    public let requiredCallerSourceModelConstructionCount: Int
    public let requiredInitialParameterMaterializationEvaluationCount: Int
    public let initialParameterMaterializationEvaluationAPI: String
    public let requiredPublicWriteInvocationCount: Int
    public let requiredPublicWriteCompletionCount: Int
    public let requiredPublicLoadInvocationCount: Int
    public let requiredPublicLoadCompletionCount: Int
    public let exhaustedSeed42PublicWriteCompletionCountSourceInferred: Int
    public let exhaustedSeed42PublicLoadCompletionCountSourceInferred: Int
    public let cumulativePublicWriteCompletionCountSourceInferredAfterSuccess:
        Int
    public let cumulativePublicLoadCompletionCountSourceInferredAfterSuccess:
        Int
    public let totalDecoderConstructionCountIsSourceInferredOnly: Bool
    public let sourceInferredDecoderConstructionCountForRepairJob: Int
    public let containerMaterializationCountRequiredByPinnedCodec: Int
    public let writerHiddenDescriptorRestoreRequiredByPinnedCodec: Bool
    public let writerPostRestoreReinspectionRequiredByPinnedCodec: Bool
    public let publicLoadCompleteMaterializationInsideHeldCapabilityRequired:
        Bool
    public let publicLoadPreAndPostWholeContainerVerificationRequired: Bool
    public let independentPostLoadTensorHashReplayRequired: Bool
    public let independentPostLoadArtifactRootVerifyRequired: Bool
    public let executionFailureEmitsReceipt: Bool
    public let executionRetryAuthorized: Bool

    public let predecessorValidatedLogCount: Int
    public let predecessorValidatedReceiptCount: Int
    public let runnerTemporaryReclamationAuthorized: Bool
    public let runnerTemporaryReclamationScope: String
    public let reclaimableRunnerTemporaryRelativePaths: [String]
    public let recursiveDeletionAuthorizedOnlyForExactAllowlist: Bool
    public let symlinkReclamationAuthorized: Bool
    public let nonOwnedPathReclamationAuthorized: Bool
    public let repositoryPathReclamationAuthorized: Bool
    public let dependencyBareRepositoryReclamationAuthorized: Bool
    public let dependencyWorktreeReclamationAuthorized: Bool
    public let metallibRootReclamationAuthorized: Bool
    public let predecessorLogReclamationAuthorized: Bool

    public let requiredGitHubActionsValue: String
    public let requiredRunnerEnvironment: String
    public let requiredExecutionEvent: String
    public let requiredExecutionRef: String
    public let requiredExecutionRunAttempt: Int
    public let githubSHAEqualsExactRevisionRequired: Bool
    public let macOSRequired: Bool
    public let requiredDirectSuccessorFirstParentRevision: String
    public let requiredExecutedCommitParentCount: Int
    public let executedTreeMustEqualReviewedSecondParentTree: Bool
    public let directSuccessorValidationRequiredBeforeDeletionBuildOrModel:
        Bool
    public let localOrManualExecutionAuthorized: Bool
    public let rerunExecutionAuthorized: Bool
    public let laterMainExecutionAuthorized: Bool
    public let observationSuccessorMustRemoveLiveLauncherCommandBeforeMerge:
        Bool

    public let receiptTransportSchema: String
    public let receiptBeginMarker: String
    public let receiptChunkMarker: String
    public let receiptEndMarker: String
    public let receiptTransportEncoding: String
    public let receiptChunkCharacterCount: Int
    public let receiptChunkOrdinalWidth: Int
    public let maximumReceiptChunkCount: Int
    public let maximumReceiptTransportLineByteCount: Int
    public let maximumCanonicalReceiptByteCount: UInt64
    public let receiptBeginLineCount: Int
    public let receiptEndLineCount: Int
    public let receiptChunksMustBeContiguousAndOrdered: Bool
    public let receiptBeginMustBindPayloadByteCountSHA256ChunkCountAndIDs:
        Bool
    public let receiptEndMustRepeatChunkCountAndPayloadSHA256: Bool
    public let singleLineReceiptPayloadAuthorized: Bool
    public let receiptMayContainAbsoluteRunnerPaths: Bool
    public let receiptMayContainRawArtifactBytes: Bool

    public let supervisorPostReceiptIndependentWholeFileHashAuthorized: Bool
    public let supervisorPostReceiptRootIdentityAndInventoryVerificationAuthorized:
        Bool
    public let supervisorLiteralArtifactCleanupRequired: Bool
    public let supervisorCleanupLstatRequired: Bool
    public let supervisorCleanupUnlinkCount: Int
    public let supervisorCleanupRmdirCount: Int
    public let supervisorCleanupRecursiveDeletionAuthorized: Bool
    public let supervisorCleanupAbsencePostconditionRequired: Bool
    public let parentReceiptVerificationRequiredBeforeSuccessCleanup: Bool
    public let receiptMayClaimSuccessCleanupCompleted: Bool
    public let boundedFailureCleanupAuthorized: Bool
    public let boundedFailureCleanupRequiresExactKnownRoot: Bool
    public let boundedFailureCleanupAllowsOnlyEmptyRootOrFixedLeaf: Bool
    public let boundedFailureCleanupRecursiveDeletionAuthorized: Bool
    public let boundedFailureCleanupProducesSuccessEvidence: Bool
    public let unexpectedFailureInventoryMustRemainForRunnerTeardown: Bool

    public let exactRevisionCheckoutRequired: Bool
    public let cleanCheckoutBeforeAndAfterRequired: Bool
    public let releaseConfigurationRequired: Bool
    public let releaseInstrumentationEvidenceAbsentRequired: Bool
    public let arm64Required: Bool
    public let singleMetalDeviceRequired: Bool
    public let mlxGPUDeviceIndex: Int
    public let metalLeaseHeldAcrossCheckpointExecutionRequired: Bool
    public let exactFreshMetallibRequired: Bool
    public let launchedEnvironmentRevalidationRequired: Bool
    public let callerSourceModelLexicallyScopedThroughWriteOnlyRequired: Bool
    public let sourceModelARCDeallocationObservationRequired: Bool
    public let memoryCacheClearBetweenSourceWriteAndPublicLoadRequired: Bool
    public let processExitRequiredAfterReceipt: Bool

    public let authoritySourceAdditionAuthorized: Bool
    public let evidenceSourceAdditionAuthorized: Bool
    public let isolatedExecutionPackageAdditionAuthorized: Bool
    public let isolatedExecutionLauncherAdditionAuthorized: Bool
    public let workflowCommandListExtensionAuthorized: Bool
    public let workflowTopologyMutationAuthorized: Bool
    public let workflowJobInventoryMutationAuthorized: Bool
    public let workflowStepInventoryMutationAuthorized: Bool
    public let workflowRunnerMutationAuthorized: Bool
    public let workflowExecutionOrderMutationAuthorized: Bool
    public let reviewedMainTimeoutExtensionAuthorized: Bool
    public let reviewedMainTimeoutBeforeMinutes: Int
    public let reviewedMainTimeoutAfterMinutes: Int
    public let reviewedMainCheckoutFetchDepthBefore: Int
    public let reviewedMainCheckoutFetchDepthDuringExecution: Int
    public let reviewedMainCheckoutFetchDepthAfterObservation: Int
    public let reviewedMainCheckoutFetchDepthExtensionAuthorized: Bool
    public let sourceGatePinExtensionAuthorized: Bool
    public let embeddedBuildProvenanceUpdateAuthorized: Bool
    public let documentationUpdateAuthorized: Bool
    public let exactReviewedMainExecutionAuthorized: Bool
    public let rootPackageManifestMutationAuthorized: Bool
    public let rootPackageResolvedMutationAuthorized: Bool
    public let newExternalDependencyAuthorized: Bool
    public let predecessorAuthorityMutationAuthorized: Bool
    public let predecessorFailureObservationMutationAuthorized: Bool
    public let checkpointCodecMutationAuthorized: Bool
    public let repairedDecoderMutationAuthorized: Bool
    public let compatibilityIdentityMutationAuthorized: Bool
    public let maintainedRuntimeMutationAuthorized: Bool
    public let frozenMetalLauncherMutationAuthorized: Bool
    public let existingRuntimeLauncherMutationAuthorized: Bool
    public let existingTokenizerLauncherMutationAuthorized: Bool
    public let existingValidationMutationAuthorized: Bool
    public let frozen44TestInventoryMutationAuthorized: Bool

    public let native300MModelAllocationAuthorized: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let ephemeralArtifactRootIOAuthorized: Bool
    public let exclusiveNoReplacePublicationAuthorized: Bool
    public let generatedFileAndParentSynchronizationRequired: Bool
    public let externalWholeContainerBindingRequired: Bool
    public let checkpointArtifactRetentionAuthorized: Bool
    public let checkpointArtifactUploadAuthorized: Bool
    public let checkpointArtifactAdmissionAuthorized: Bool
    public let checkpointReplacementAuthorized: Bool
    public let failedWriteRecoveryExperimentAuthorized: Bool
    public let existingCheckpointArtifactConsumptionAuthorized: Bool
    public let decoderForwardAuthorized: Bool
    public let decoderKVCacheUseAuthorized: Bool
    public let backwardAuthorized: Bool
    public let lossAuthorized: Bool
    public let optimizerStepAuthorized: Bool
    public let generationAuthorized: Bool
    public let trainingAuthorized: Bool
    public let trainingResumeAuthorized: Bool
    public let candidateAdmissionAuthorized: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool

    public let native300MModelAllocationObserved: Bool
    public let native300MCheckpointWriteObserved: Bool
    public let native300MCheckpointLoadObserved: Bool
    public let checkpointIOObserved: Bool
    public let checkpointArtifactAvailable: Bool
    public let checkpointArtifactRetained: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointContainerHashBound: Bool
    public let checkpointAdmissionGranted: Bool
    public let checkpointDurabilityObserved: Bool
    public let logicalParameterRoundTripObserved: Bool
    public let runtimeDependencyClosureReobservedForCheckpointIO: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_authority_v1",
        authorityKind:
            "append_only_exact_process_local_seed43_native300m_v2_checkpoint_io_root_identity_repair_execution_authority",
        predecessorFailureObservationID:
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1
                .frozenV1.observationID,
        exhaustedPredecessorAuthorityID:
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1
                .frozenV1.authorityID,
        exhaustedPredecessorEvidenceID:
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_evidence_v1",
        predecessorFailureObservationRemainsFrozen: true,
        predecessorFailureObservationRequiredForConsumption: true,
        exhaustedPredecessorAttemptCannotBeRerun: true,
        authoritativeRepository: "Ergentics/ergentics-prime",
        baseRef: "refs/heads/main",
        baseRevision:
            "1a69407a8fbd5f141e8ece584066b8dcfa6f606f",
        baseOrderedParentRevisions: [
            "27749af3347437daa693d4375acb759283923a4a",
            "3ac964a2430c298c23866a61ca9437b3a7f6ee59",
        ],
        baseTree:
            "1f33f04aab657a68ca0fcdd68c13f5f69181df33",
        baseReviewedPullRequestHeadRevision:
            "3ac964a2430c298c23866a61ca9437b3a7f6ee59",
        baseReviewedPullRequestHeadTree:
            "1f33f04aab657a68ca0fcdd68c13f5f69181df33",
        baseEmbeddedSourceIdentitySHA256:
            "d2c8e4f4f147b01b962e0a57b154dbe4874456777b0d659cd76253bf2f115bd9",
        basePullRequestNumber: 78,
        baseHistoryPreservingTwoParentMerge: true,
        baseSourceBindings: [
            .init(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthority.swift",
                gitMode: "100644",
                gitBlob: "f82bd280fd1c269ce6a6e0392a8849630d0af124",
                byteCount: 60_654,
                sha256:
                    "d56febe490f6a774028c1bc1567f907f18b0f5591b78a24ad0ff0fe6947be62f"),
            .init(
                path:
                    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift",
                gitMode: "100644",
                gitBlob: "416423e41a072ab323a345a12782ac54faac57d8",
                byteCount: 52_898,
                sha256:
                    "bc5dc07a60dc2b3642bd5440857d32345a36b128283e0c200deb15889d388544"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift",
                gitMode: "100644",
                gitBlob: "233ab6e0a2c747ca2166a3ad0a8841ddd83a24b6",
                byteCount: 2_136,
                sha256:
                    "cfcde7c6ebf00a2aabe26aa1b4417a3cc5e7d4caf771fbd32cc7a2637be5d2b1"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved",
                gitMode: "100644",
                gitBlob: "9887e211ac39cdf8083419ba144f2ca26ffc44cd",
                byteCount: 645,
                sha256:
                    "538966e5f400f66e786b2946e4267ccf41e92ef4077a29c2358413792640e5b6"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift",
                gitMode: "100644",
                gitBlob: "71262c7794e5d47e0d8990346a0e6682f4fcd09b",
                byteCount: 40_914,
                sha256:
                    "a1a768c17e6fcb510b75468b81309863712cd3f07dc7dc4f41ba559f27d9fad9"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift",
                gitMode: "100644",
                gitBlob: "8b1c18b57c70dda967885c2737d0d4170c7e417a",
                byteCount: 27_448,
                sha256:
                    "869db27f80824cfa0a6420efac62237c389cbed692c3f119f47f07c5ff68db6f"),
            .init(
                path:
                    ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh",
                gitMode: "100755",
                gitBlob: "0683f4bfba4dc7929e4c397a499132f859a80b0e",
                byteCount: 60_125,
                sha256:
                    "824fe36fcb6e0707650868e1fbfc1bb67cf6ccace7a9c0ea21a60bead27bbe07"),
            .init(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservation.swift",
                gitMode: "100644",
                gitBlob: "ab6212e0499ae7aaa1da2cc66be8b67026f504c1",
                byteCount: 44_667,
                sha256:
                    "e35bb2770a0b668fac0b9d26ea057ffe1837210abea0e30d8beb4ad4838e522f"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionFailureObservationTests.swift",
                gitMode: "100644",
                gitBlob: "0ed3aa83f0dc16b0893655b9582985947509b919",
                byteCount: 16_695,
                sha256:
                    "89ff93473e36ecc8a1fad38ef46c792ad0d12edee2508d91101d4df336cf7c2c"),
            .init(
                path:
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "38f16f6c2fc19575a2dc234f5b37d0deb2cd5e06",
                byteCount: 160_618,
                sha256:
                    "42f68938445ec4dca287e2e88ab71448161171a148f8b5a97c1ecbb0939c63b9"),
            .init(
                path:
                    ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "a51c90e692aadf8ea6753a3d021f8a35171453f7",
                byteCount: 30_261,
                sha256:
                    "8f15b8dfa9fc4850f63ff292df6337e51472a3f7c2dd3145d121cde37001d9dc"),
            .init(
                path:
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitMode: "100644",
                gitBlob: "7102be21e6d5b0b6d99f42e02e6a216294947102",
                byteCount: 546,
                sha256:
                    "38d7fa0a2bab051017bfb4066f88aaa24769fd09d5818763504e0e557000e87b"),
        ],
        exactMLXRepository: "Ergentics/ergentics-mlx-swift",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        exactMLXCoreRevision:
            "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
        exactMLXCRevision:
            "0726ca922fc902c4c61ef9c27d94132be418e945",
        exactSwiftNumericsRevision:
            "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
        environmentPolicy:
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEnvironmentPolicyV1
                .declaration,
        authoritativeExecutionPackagePath:
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation",
        authoritativeExecutionProduct:
            "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe",
        authoritativeExecutionTarget:
            "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe",
        authoritativeExecutionTargetDependencies: [
            "PrimeCore",
            "PrimeNativeDecoder",
            "PrimeNativeDecoderCheckpoint",
            "MLX",
            "MLXNN",
        ],
        authorityTestTarget:
            "PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests",
        executionProbeSourcePath:
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift",
        authorityTestSourcePath:
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift",
        executionPackageManifestPath:
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift",
        executionPackageResolvedPath:
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved",
        executionLauncherPath:
            ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
        executionEvidenceSourcePath:
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift",
        publicExecutionEvidenceType:
            "PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1",
        publicExternalBindingType:
            "PrimeNativeDecoderCheckpointExternalBindingV2",
        publicRootIdentityType:
            "PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityV1",
        publicRootIdentityComparatorType:
            "PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairRootIdentityComparatorV1",
        publicEnvironmentPolicyType:
            "PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEnvironmentPolicyV1",
        publicCanonicalReceiptDeclaration:
            "PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1.canonicalReceiptData()",
        publicCanonicalReceiptDecodeDeclaration:
            "PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1.decodeCanonicalReceipt(from:)",
        newExecutionSourceIdentityStatus:
            "PINNED_AFTER_SOURCE_STABILIZATION",
        newExecutionSourceBindings: [
            .init(
                path:
                    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift",
                gitMode: "100644",
                gitBlob: "6edb77813df76adb8d7c84d8faf451e325634433",
                byteCount: 62_078,
                sha256:
                    "3bd2fa7bd7ada430b05e16e28242e452ebcd8bd0fb8165ee17723efd44096de8"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift",
                gitMode: "100644",
                gitBlob: "1cc830db123defbf6a8c0f1362d6d2bb9d754d34",
                byteCount: 2_226,
                sha256:
                    "0caa578cf38870dec6b12cced51859ebb5e3a75ecd30257b76e94c520690c1a4"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved",
                gitMode: "100644",
                gitBlob: "315cda0e2afccd6fd0acac96e6a0b9bf76afbeca",
                byteCount: 645,
                sha256:
                    "b93b010098821b26f2efe368e71d1fcf6a2dcb83403962140dfb61f2f70b4c34"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift",
                gitMode: "100644",
                gitBlob: "61f029352f7a27fa95b4a7b7238d58f1db834387",
                byteCount: 41_866,
                sha256:
                    "bac43ad7e9e44cc02b3b2e51ecf17d1ffb184a086e3c0c5854c8f2ba67b7a504"),
            .init(
                path:
                    "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift",
                gitMode: "100644",
                gitBlob: "8a7bbb1c147555a04e77937eda47b9938c6f742d",
                byteCount: 41_659,
                sha256:
                    "07575be036b7901ac9c8adba11d1d35a71df453a00bf62e2a8435a6af3e86373"),
            .init(
                path:
                    ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
                gitMode: "100755",
                gitBlob: "ed7852704219f61bc29841641257da697389458c",
                byteCount: 66_828,
                sha256:
                    "f56adf9d50d96fc8d06bfbf1bbebd9ce054f4de4f2577e778fc5afb24bd93f7b"),
        ],
        configuration: .native300MByte512,
        initializationSeed: 43,
        compatibilityIdentitySchema:
            "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
        compatibilityIdentityCanonicalByteCount: 30_553,
        compatibilityIdentitySHA256:
            "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843",
        parameterDescriptorCount: 218,
        parameterCatalogCanonicalByteCount: 28_951,
        parameterCatalogSHA256:
            "69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1",
        totalParameterCount: 271_107_072,
        totalParameterByteCount: 1_084_428_288,
        artifactRootRunnerTemporaryRelativePath:
            "prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-artifact-root",
        artifactRelativePath:
            "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors",
        artifactPurpose: "immutable_data",
        maximumCheckpointByteCount: 1_101_205_504,
        maximumManifestByteCount: 16_777_216,
        requiredArtifactRootMode: 0o700,
        requiredPublishedArtifactMode: 0o444,
        requiredPublishedArtifactLinkCount: 1,
        requiredArtifactRootEntryCountBeforeWrite: 0,
        requiredArtifactRootEntryCountAfterWrite: 1,
        requiredArtifactRootEntryNamesBeforeWrite: [],
        requiredArtifactRootEntryNamesAfterWrite: [
            "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors",
        ],
        publishedArtifactMustBeRegularFile: true,
        publishedArtifactMustNotBeSymbolicLink: true,
        publishedArtifactDeviceMustMatchRoot: true,
        publishedArtifactOwnerMustMatchEffectiveUser: true,
        rootLinkCountMustRemainPositive: true,
        rootLinkCountEqualityAcrossPublicationRequired: false,
        rootTimestampsEqualityAcrossPublicationRequired: false,
        rootFullIdentityEqualityAcrossReadOnlyLoadRequired: true,
        requiredFreeSpaceMultiplier: 3,
        requiredAvailableFilesystemBytesAfterBuild: 3_303_616_512,
        requiredMemoryCacheLimit: 0,
        requiredMemoryCacheClearCount: 2,
        requiredCallerSourceModelConstructionCount: 1,
        requiredInitialParameterMaterializationEvaluationCount: 1,
        initialParameterMaterializationEvaluationAPI:
            "MLX.checkedEval(model)",
        requiredPublicWriteInvocationCount: 1,
        requiredPublicWriteCompletionCount: 1,
        requiredPublicLoadInvocationCount: 1,
        requiredPublicLoadCompletionCount: 1,
        exhaustedSeed42PublicWriteCompletionCountSourceInferred: 1,
        exhaustedSeed42PublicLoadCompletionCountSourceInferred: 0,
        cumulativePublicWriteCompletionCountSourceInferredAfterSuccess: 2,
        cumulativePublicLoadCompletionCountSourceInferredAfterSuccess: 1,
        totalDecoderConstructionCountIsSourceInferredOnly: true,
        sourceInferredDecoderConstructionCountForRepairJob: 3,
        containerMaterializationCountRequiredByPinnedCodec: 2,
        writerHiddenDescriptorRestoreRequiredByPinnedCodec: true,
        writerPostRestoreReinspectionRequiredByPinnedCodec: true,
        publicLoadCompleteMaterializationInsideHeldCapabilityRequired: true,
        publicLoadPreAndPostWholeContainerVerificationRequired: true,
        independentPostLoadTensorHashReplayRequired: false,
        independentPostLoadArtifactRootVerifyRequired: false,
        executionFailureEmitsReceipt: false,
        executionRetryAuthorized: false,
        predecessorValidatedLogCount: 10,
        predecessorValidatedReceiptCount: 2,
        runnerTemporaryReclamationAuthorized: true,
        runnerTemporaryReclamationScope:
            "exact_owned_direct_children_of_runner_temp_after_ten_predecessor_logs_and_two_receipts_validate_only",
        reclaimableRunnerTemporaryRelativePaths: [
            "prime-active-root-build",
            "prime-active-root-cache",
            "prime-active-root-config",
            "prime-active-root-security",
            "prime-checkpoint-v2-build",
            "prime-checkpoint-v2-cache",
            "prime-checkpoint-v2-config",
            "prime-checkpoint-v2-security",
            "prime-checkpoint-v2-io-build",
            "prime-checkpoint-v2-io-cache",
            "prime-checkpoint-v2-io-config",
            "prime-checkpoint-v2-io-security",
            "prime-checkpoint-v2-io-execution-pure-build",
            "prime-checkpoint-v2-io-execution-pure-cache",
            "prime-checkpoint-v2-io-execution-pure-config",
            "prime-checkpoint-v2-io-execution-pure-security",
            "prime-checkpoint-v2-io-root-identity-repair-execution-pure-build",
            "prime-checkpoint-v2-io-root-identity-repair-execution-pure-cache",
            "prime-checkpoint-v2-io-root-identity-repair-execution-pure-config",
            "prime-checkpoint-v2-io-root-identity-repair-execution-pure-security",
            "prime-native-decoder-build",
            "prime-native-decoder-cache",
            "prime-native-decoder-config",
            "prime-native-decoder-security",
            "prime-native-decoder-runtime-closure-build",
            "prime-native-decoder-runtime-closure-cache",
            "prime-native-decoder-runtime-closure-config",
            "prime-native-decoder-runtime-closure-security",
            "prime-native-decoder-tokenizer-compatibility-build",
            "prime-native-decoder-tokenizer-compatibility-cache",
            "prime-native-decoder-tokenizer-compatibility-config",
            "prime-native-decoder-tokenizer-compatibility-security",
        ],
        recursiveDeletionAuthorizedOnlyForExactAllowlist: true,
        symlinkReclamationAuthorized: false,
        nonOwnedPathReclamationAuthorized: false,
        repositoryPathReclamationAuthorized: false,
        dependencyBareRepositoryReclamationAuthorized: false,
        dependencyWorktreeReclamationAuthorized: false,
        metallibRootReclamationAuthorized: false,
        predecessorLogReclamationAuthorized: false,
        requiredGitHubActionsValue: "true",
        requiredRunnerEnvironment: "github-hosted",
        requiredExecutionEvent: "push",
        requiredExecutionRef: "refs/heads/main",
        requiredExecutionRunAttempt: 1,
        githubSHAEqualsExactRevisionRequired: true,
        macOSRequired: true,
        requiredDirectSuccessorFirstParentRevision:
            "1a69407a8fbd5f141e8ece584066b8dcfa6f606f",
        requiredExecutedCommitParentCount: 2,
        executedTreeMustEqualReviewedSecondParentTree: true,
        directSuccessorValidationRequiredBeforeDeletionBuildOrModel: true,
        localOrManualExecutionAuthorized: false,
        rerunExecutionAuthorized: false,
        laterMainExecutionAuthorized: false,
        observationSuccessorMustRemoveLiveLauncherCommandBeforeMerge: true,
        receiptTransportSchema:
            "canonical_json_rfc4648_base64_chunk_transport_v1",
        receiptBeginMarker:
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_BEGIN=",
        receiptChunkMarker:
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_CHUNK=",
        receiptEndMarker:
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_END=",
        receiptTransportEncoding: "rfc4648_base64_no_wrap",
        receiptChunkCharacterCount: 4_096,
        receiptChunkOrdinalWidth: 6,
        maximumReceiptChunkCount: 86,
        maximumReceiptTransportLineByteCount: 16_384,
        maximumCanonicalReceiptByteCount: 262_144,
        receiptBeginLineCount: 1,
        receiptEndLineCount: 1,
        receiptChunksMustBeContiguousAndOrdered: true,
        receiptBeginMustBindPayloadByteCountSHA256ChunkCountAndIDs: true,
        receiptEndMustRepeatChunkCountAndPayloadSHA256: true,
        singleLineReceiptPayloadAuthorized: false,
        receiptMayContainAbsoluteRunnerPaths: false,
        receiptMayContainRawArtifactBytes: false,
        supervisorPostReceiptIndependentWholeFileHashAuthorized: false,
        supervisorPostReceiptRootIdentityAndInventoryVerificationAuthorized:
            true,
        supervisorLiteralArtifactCleanupRequired: true,
        supervisorCleanupLstatRequired: true,
        supervisorCleanupUnlinkCount: 1,
        supervisorCleanupRmdirCount: 1,
        supervisorCleanupRecursiveDeletionAuthorized: false,
        supervisorCleanupAbsencePostconditionRequired: true,
        parentReceiptVerificationRequiredBeforeSuccessCleanup: true,
        receiptMayClaimSuccessCleanupCompleted: false,
        boundedFailureCleanupAuthorized: true,
        boundedFailureCleanupRequiresExactKnownRoot: true,
        boundedFailureCleanupAllowsOnlyEmptyRootOrFixedLeaf: true,
        boundedFailureCleanupRecursiveDeletionAuthorized: false,
        boundedFailureCleanupProducesSuccessEvidence: false,
        unexpectedFailureInventoryMustRemainForRunnerTeardown: true,
        exactRevisionCheckoutRequired: true,
        cleanCheckoutBeforeAndAfterRequired: true,
        releaseConfigurationRequired: true,
        releaseInstrumentationEvidenceAbsentRequired: true,
        arm64Required: true,
        singleMetalDeviceRequired: true,
        mlxGPUDeviceIndex: 0,
        metalLeaseHeldAcrossCheckpointExecutionRequired: true,
        exactFreshMetallibRequired: true,
        launchedEnvironmentRevalidationRequired: true,
        callerSourceModelLexicallyScopedThroughWriteOnlyRequired: true,
        sourceModelARCDeallocationObservationRequired: false,
        memoryCacheClearBetweenSourceWriteAndPublicLoadRequired: true,
        processExitRequiredAfterReceipt: true,
        authoritySourceAdditionAuthorized: true,
        evidenceSourceAdditionAuthorized: true,
        isolatedExecutionPackageAdditionAuthorized: true,
        isolatedExecutionLauncherAdditionAuthorized: true,
        workflowCommandListExtensionAuthorized: true,
        workflowTopologyMutationAuthorized: false,
        workflowJobInventoryMutationAuthorized: false,
        workflowStepInventoryMutationAuthorized: false,
        workflowRunnerMutationAuthorized: false,
        workflowExecutionOrderMutationAuthorized: false,
        reviewedMainTimeoutExtensionAuthorized: true,
        reviewedMainTimeoutBeforeMinutes: 45,
        reviewedMainTimeoutAfterMinutes: 90,
        reviewedMainCheckoutFetchDepthBefore: 1,
        reviewedMainCheckoutFetchDepthDuringExecution: 2,
        reviewedMainCheckoutFetchDepthAfterObservation: 1,
        reviewedMainCheckoutFetchDepthExtensionAuthorized: true,
        sourceGatePinExtensionAuthorized: true,
        embeddedBuildProvenanceUpdateAuthorized: true,
        documentationUpdateAuthorized: true,
        exactReviewedMainExecutionAuthorized: true,
        rootPackageManifestMutationAuthorized: false,
        rootPackageResolvedMutationAuthorized: false,
        newExternalDependencyAuthorized: false,
        predecessorAuthorityMutationAuthorized: false,
        predecessorFailureObservationMutationAuthorized: false,
        checkpointCodecMutationAuthorized: false,
        repairedDecoderMutationAuthorized: false,
        compatibilityIdentityMutationAuthorized: false,
        maintainedRuntimeMutationAuthorized: false,
        frozenMetalLauncherMutationAuthorized: false,
        existingRuntimeLauncherMutationAuthorized: false,
        existingTokenizerLauncherMutationAuthorized: false,
        existingValidationMutationAuthorized: false,
        frozen44TestInventoryMutationAuthorized: false,
        native300MModelAllocationAuthorized: true,
        native300MCheckpointWriteAuthorized: true,
        native300MCheckpointLoadAuthorized: true,
        ephemeralArtifactRootIOAuthorized: true,
        exclusiveNoReplacePublicationAuthorized: true,
        generatedFileAndParentSynchronizationRequired: true,
        externalWholeContainerBindingRequired: true,
        checkpointArtifactRetentionAuthorized: false,
        checkpointArtifactUploadAuthorized: false,
        checkpointArtifactAdmissionAuthorized: false,
        checkpointReplacementAuthorized: false,
        failedWriteRecoveryExperimentAuthorized: false,
        existingCheckpointArtifactConsumptionAuthorized: false,
        decoderForwardAuthorized: false,
        decoderKVCacheUseAuthorized: false,
        backwardAuthorized: false,
        lossAuthorized: false,
        optimizerStepAuthorized: false,
        generationAuthorized: false,
        trainingAuthorized: false,
        trainingResumeAuthorized: false,
        candidateAdmissionAuthorized: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        native300MModelAllocationObserved: false,
        native300MCheckpointWriteObserved: false,
        native300MCheckpointLoadObserved: false,
        checkpointIOObserved: false,
        checkpointArtifactAvailable: false,
        checkpointArtifactRetained: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointContainerHashBound: false,
        checkpointAdmissionGranted: false,
        checkpointDurabilityObserved: false,
        logicalParameterRoundTripObserved: false,
        runtimeDependencyClosureReobservedForCheckpointIO: false,
        status:
            "ABSTAIN_exact_seed43_native300m_v2_checkpoint_root_identity_repair_one_write_one_load_authorized_not_observed_no_artifact_admission",
        orderedNextActions: [
            "run_exact_clean_reviewed_main_direct_successor_attempt_one",
            "verify_chunked_canonical_receipt_then_cleanup_fixed_ephemeral_artifact",
            "append_exact_success_or_failure_observation_and_remove_live_command",
        ])

    public func validateExactV1() throws {
        let predecessor =
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionFailureObservationV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            try configuration.validateExactNative300MByte512()
            try
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairComparatorProofV1
                    .frozenV1.validateExactV1()
            for source in baseSourceBindings + newExecutionSourceBindings {
                try source.validate()
            }
        } catch {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }

        let expectedNewPaths = [
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved",
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift",
            ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
        ]
        let pinnedBindings =
            newExecutionSourceIdentityStatus
                == "PINNED_AFTER_SOURCE_STABILIZATION"
                && newExecutionSourceBindings.map(\.path) == expectedNewPaths
                && Set(newExecutionSourceBindings.map(\.path)).count == 6

        guard self == Self.frozenV1,
              schemaVersion == 1,
              predecessorFailureObservationID == predecessor.observationID,
              predecessorFailureObservationRemainsFrozen,
              predecessorFailureObservationRequiredForConsumption,
              exhaustedPredecessorAttemptCannotBeRerun,
              authoritativeRepository == "Ergentics/ergentics-prime",
              baseRef == "refs/heads/main",
              baseRevision
                == "1a69407a8fbd5f141e8ece584066b8dcfa6f606f",
              baseOrderedParentRevisions == [
                  "27749af3347437daa693d4375acb759283923a4a",
                  "3ac964a2430c298c23866a61ca9437b3a7f6ee59",
              ],
              baseTree
                == "1f33f04aab657a68ca0fcdd68c13f5f69181df33",
              baseReviewedPullRequestHeadTree == baseTree,
              baseEmbeddedSourceIdentitySHA256
                == "d2c8e4f4f147b01b962e0a57b154dbe4874456777b0d659cd76253bf2f115bd9",
              basePullRequestNumber == 78,
              baseHistoryPreservingTwoParentMerge,
              baseSourceBindings.count == 12,
              Set(baseSourceBindings.map(\.path)).count == 12,
              environmentPolicy
                == PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEnvironmentPolicyV1
                    .declaration,
              authoritativeExecutionProduct == authoritativeExecutionTarget,
              authoritativeExecutionTargetDependencies == [
                  "PrimeCore", "PrimeNativeDecoder",
                  "PrimeNativeDecoderCheckpoint", "MLX", "MLXNN",
              ],
              pinnedBindings,
              initializationSeed == 43,
              artifactRootRunnerTemporaryRelativePath
                == "prime-native-decoder-checkpoint-v2-io-root-identity-repair-execution-artifact-root",
              artifactRelativePath
                == "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors",
              requiredArtifactRootEntryNamesBeforeWrite.isEmpty,
              requiredArtifactRootEntryNamesAfterWrite
                == [artifactRelativePath],
              requiredArtifactRootEntryCountBeforeWrite == 0,
              requiredArtifactRootEntryCountAfterWrite == 1,
              publishedArtifactMustBeRegularFile,
              publishedArtifactMustNotBeSymbolicLink,
              publishedArtifactDeviceMustMatchRoot,
              publishedArtifactOwnerMustMatchEffectiveUser,
              rootLinkCountMustRemainPositive,
              !rootLinkCountEqualityAcrossPublicationRequired,
              !rootTimestampsEqualityAcrossPublicationRequired,
              rootFullIdentityEqualityAcrossReadOnlyLoadRequired,
              requiredAvailableFilesystemBytesAfterBuild
                == requiredFreeSpaceMultiplier * maximumCheckpointByteCount,
              requiredPublicWriteInvocationCount == 1,
              requiredPublicWriteCompletionCount == 1,
              requiredPublicLoadInvocationCount == 1,
              requiredPublicLoadCompletionCount == 1,
              exhaustedSeed42PublicWriteCompletionCountSourceInferred == 1,
              exhaustedSeed42PublicLoadCompletionCountSourceInferred == 0,
              cumulativePublicWriteCompletionCountSourceInferredAfterSuccess
                == 2,
              cumulativePublicLoadCompletionCountSourceInferredAfterSuccess
                == 1,
              predecessorValidatedLogCount == 10,
              predecessorValidatedReceiptCount == 2,
              reclaimableRunnerTemporaryRelativePaths.count == 32,
              Set(reclaimableRunnerTemporaryRelativePaths).count == 32,
              requiredExecutionEvent == "push",
              requiredExecutionRef == "refs/heads/main",
              requiredExecutionRunAttempt == 1,
              requiredDirectSuccessorFirstParentRevision == baseRevision,
              requiredExecutedCommitParentCount == 2,
              !localOrManualExecutionAuthorized,
              !rerunExecutionAuthorized,
              !laterMainExecutionAuthorized,
              !executionRetryAuthorized,
              reviewedMainTimeoutBeforeMinutes == 45,
              reviewedMainTimeoutAfterMinutes == 90,
              reviewedMainCheckoutFetchDepthBefore == 1,
              reviewedMainCheckoutFetchDepthDuringExecution == 2,
              reviewedMainCheckoutFetchDepthAfterObservation == 1,
              parentReceiptVerificationRequiredBeforeSuccessCleanup,
              !receiptMayClaimSuccessCleanupCompleted,
              boundedFailureCleanupAuthorized,
              boundedFailureCleanupRequiresExactKnownRoot,
              boundedFailureCleanupAllowsOnlyEmptyRootOrFixedLeaf,
              !boundedFailureCleanupRecursiveDeletionAuthorized,
              !boundedFailureCleanupProducesSuccessEvidence,
              unexpectedFailureInventoryMustRemainForRunnerTeardown,
              native300MModelAllocationAuthorized,
              native300MCheckpointWriteAuthorized,
              native300MCheckpointLoadAuthorized,
              ephemeralArtifactRootIOAuthorized,
              !checkpointArtifactRetentionAuthorized,
              !checkpointArtifactUploadAuthorized,
              !checkpointArtifactAdmissionAuthorized,
              !decoderForwardAuthorized,
              !backwardAuthorized,
              !trainingAuthorized,
              !productUseAuthorized,
              !publicationAuthorized,
              !native300MModelAllocationObserved,
              !native300MCheckpointWriteObserved,
              !native300MCheckpointLoadObserved,
              !checkpointIOObserved,
              !checkpointArtifactAvailable,
              !checkpointArtifactRetained,
              !checkpointArtifactProvenanceEstablished
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityError
                    .contractDrift
        }
    }
}
