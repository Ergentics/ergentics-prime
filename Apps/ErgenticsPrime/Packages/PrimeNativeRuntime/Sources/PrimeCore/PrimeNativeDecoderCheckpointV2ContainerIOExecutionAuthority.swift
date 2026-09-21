// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Successor environment policy for one exact checkpoint write/load probe.
///
/// The maintained-runtime policy remains frozen. This policy reuses its
/// inherited and launched environment validation mechanics while widening
/// only the execution ceiling needed by this checkpoint probe.
public enum
    PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
{
    public static let declaration =
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1(
            schemaVersion: 1,
            policyID:
                "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_environment_v1",
            policyVersion: 1,
            scope:
                "one_seed42_native300m_v2_checkpoint_write_and_one_fresh_load",
            predecessorPolicyID:
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                    .declaration.policyID,
            predecessorPolicyVersion:
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
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
                "exact_manifest_catalog_shape_dtype_count_and_logical_tensor_hash_via_pinned_codec",
            authorityCeiling:
                "one_process_local_seed42_native300m_source_materialization_one_v2_write_one_fresh_v2_load_no_forward_backward_retry_artifact_admission_upload_or_retention"
        )

    @discardableResult
    public static func validateInherited(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        _ = try
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
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
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateLaunched(environment: environment)
        return declaration
    }

    /// Must run before any CoreGraphics, Metal, MLX, model, or checkpoint
    /// operation in the execution process.
    @discardableResult
    public static func validateLaunchedCurrentProcess(
        processInfo: ProcessInfo = .processInfo
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        try validateLaunched(environment: processInfo.environment)
    }
}

/// Process-observed identity for the private ephemeral artifact-root
/// directory. Publication intentionally changes directory timestamps, so
/// pre-write comparisons use `stableObjectFieldsEqual(to:)`. The full value
/// must remain equal from post-write through the read-only public load.
public struct
    PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1:
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
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityError
                    .contractDrift
        }
    }

    public func stableObjectFieldsEqual(
        to other: Self
    ) -> Bool {
        deviceID == other.deviceID
            && inode == other.inode
            && ownerUserID == other.ownerUserID
            && ownerGroupID == other.ownerGroupID
            && permissionMode == other.permissionMode
            && linkCount == other.linkCount
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

/// Append-only authority for one exact execution-local checkpoint round trip.
///
/// This plan authorizes one seed-42 Native-300M source materialization, one
/// successful public V2 write, and one successful public V2 load into a fresh
/// decoder under one private ephemeral `PrimeArtifactRoot`. It observes none
/// of those operations. A dynamic typed receipt remains execution/job-local
/// and is not durable repository authority until a later append-only
/// reviewed-main observation binds it.
public struct
    PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityPlanV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let predecessorAuthorityID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorRequiredForConsumption: Bool

    public let authoritativeRepository: String
    public let baseRef: String
    public let baseRevision: String
    public let baseOrderedParentRevisions: [String]
    public let baseTree: String
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

    public let artifactRelativePath: String
    public let artifactPurpose: String
    public let maximumCheckpointByteCount: UInt64
    public let maximumManifestByteCount: UInt64
    public let requiredArtifactRootMode: UInt16
    public let requiredPublishedArtifactMode: UInt16
    public let requiredPublishedArtifactLinkCount: UInt64
    public let requiredArtifactRootEntryCountBeforeWrite: Int
    public let requiredArtifactRootEntryCountAfterWrite: Int
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
    public let totalDecoderConstructionCountIsSourceInferredOnly: Bool
    public let sourceInferredDecoderConstructionCount: Int
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

    public let predecessorReceiptCompletionRequiredBeforeReclamation: Bool
    public let runnerTemporaryReclamationAuthorized: Bool
    public let runnerTemporaryReclamationScope: String
    public let reclaimableRunnerTemporaryRelativePaths: [String]
    public let preservedRunnerTemporaryRelativePaths: [String]
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
    public let reclamationOccurredClaimIsLauncherLogEvidenceOnly: Bool
    public let receiptClaimsOnlyReclaimedPathsAbsentBeforeProbe: Bool

    public let supervisorPostReceiptIndependentWholeFileHashAuthorized: Bool
    public let supervisorPostReceiptArtifactRootVerifyAuthorized: Bool
    public let supervisorLiteralArtifactCleanupRequired: Bool
    public let supervisorCleanupLstatRequired: Bool
    public let supervisorCleanupUnlinkCount: Int
    public let supervisorCleanupRmdirCount: Int
    public let supervisorCleanupRecursiveDeletionAuthorized: Bool
    public let supervisorCleanupAbsencePostconditionRequired: Bool

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
    public let parentReceiptVerificationRequiredBeforeArtifactCleanup: Bool
    public let artifactAndRootCleanupRequiredAfterParentVerification: Bool

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
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_authority_v1",
        authorityKind:
            "append_only_exact_process_local_native300m_v2_checkpoint_io_execution_authority",
        predecessorAuthorityID:
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1.authorityID,
        predecessorRemainsFrozen: true,
        predecessorRequiredForConsumption: true,
        authoritativeRepository: "Ergentics/ergentics-prime",
        baseRef: "refs/heads/main",
        baseRevision:
            "b861fa8270cbdceefd6079f7e09fece495fc4b79",
        baseOrderedParentRevisions: [
            "15f858f4a8fa74a7b6a29b55da59d4660c50ff01",
            "15d5f27f8284e80523c250133c4abf4de75d867a",
        ],
        baseTree:
            "7b8a1be7f34b28501178d5f8e7d78abb5d7dcb14",
        baseEmbeddedSourceIdentitySHA256:
            "efb9bd25738c946b0326241f492f6f576dfeef36481a373410b3951bc88aaeb7",
        basePullRequestNumber: 76,
        baseHistoryPreservingTwoParentMerge: true,
        baseSourceBindings: [
            .init(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIOAuthority.swift",
                gitMode: "100644",
                gitBlob: "f0d010959aaf20fddb755aec7a1b61550dec93dd",
                byteCount: 40_522,
                sha256:
                    "8d3626aacfce1fd0350b79872b829df4322695981eaebcf88bc4f38ec2973880"),
            .init(
                path:
                    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift",
                gitMode: "100644",
                gitBlob: "105af3f93acf9358e7b66c3a327e45a931deab8b",
                byteCount: 54_880,
                sha256:
                    "39f74373923fcbb56eae5da2038795668c3347115c854a219374d1b797c9761d"),
            .init(
                path: "Sources/PrimeCore/PrimeDurableArtifacts.swift",
                gitMode: "100644",
                gitBlob: "e9e462aa17ae1d4393c77cf953b3c7d44abfcd1e",
                byteCount: 144_993,
                sha256:
                    "faa8254ee6ecd97f064a6553efba8158fff6a33fc882607444ba117d56328430"),
            .init(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeComputeAuthority.swift",
                gitMode: "100644",
                gitBlob: "379c3e40ab24ae696c01da0b3f2116d0093cedb2",
                byteCount: 60_844,
                sha256:
                    "f53a7a055058fbf528d7a96b4111c673fa3bc2dbd2ae10bf5129aa8b828a2445"),
            .init(
                path:
                    "Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift",
                gitMode: "100644",
                gitBlob: "dd3ca76ba7799c6deb0012276967c07bee3644d0",
                byteCount: 55_550,
                sha256:
                    "71d312d03f81509ece6234067a8b5f43c410ca2941da658134921141037fa981"),
            .init(
                path:
                    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                gitMode: "100644",
                gitBlob: "835a4826549e1f28ec27e3533f746218beb3bdf2",
                byteCount: 39_050,
                sha256:
                    "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b"),
            .init(
                path:
                    "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift",
                gitMode: "100644",
                gitBlob: "7e993df79cc3a7c37d130c9eb5e7f30f63a6c386",
                byteCount: 9_228,
                sha256:
                    "2b73886d067015ea65a71944bdc9d0f06025ee65858e9cfccf9a8f0936cf36f3"),
            .init(
                path:
                    "Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservation.swift",
                gitMode: "100644",
                gitBlob: "92bc5e2f1e802c37d2b3b6ac07c6b60ce483328c",
                byteCount: 48_237,
                sha256:
                    "62eb03797435a40b7c3265b2d9886f58b1b9a5be3f7759804daa6b1bcf2e94a4"),
            .init(
                path: "Package.swift",
                gitMode: "100644",
                gitBlob: "f201abbf928e5e3d6b0c7785110539cdaeee911b",
                byteCount: 32_082,
                sha256:
                    "db81e337640b8eb923dbc90b9e22ce898c371ccffe08eed08050e45c34551400"),
            .init(
                path: "Package.resolved",
                gitMode: "100644",
                gitBlob: "dcd0192f705c22378f2d9e871a240c0493ad8a80",
                byteCount: 645,
                sha256:
                    "a18ded75fe953803945898aba0b04a9cec4fca674f38bf914e5fa45dfdb70741"),
            .init(
                path:
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitMode: "100755",
                gitBlob: "e15c0929418e3523f52d332bee8a838c9fc5df16",
                byteCount: 104_399,
                sha256:
                    "d8964b1830a0377a6c3ddeba4e772cddec693b5e868247c388e2a4f3b9c318bc"),
            .init(
                path:
                    ".github/workflows/prime-active-root-quarantine.yml",
                gitMode: "100644",
                gitBlob: "cf32011a826d060d89be90dd7dc731752465d1ca",
                byteCount: 26_528,
                sha256:
                    "4d2044d745f5d035256a785d6ded47f79c8b5dd9138aa4df0d5768e906dbca9a"),
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
            PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
                .declaration,
        authoritativeExecutionPackagePath:
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation",
        authoritativeExecutionProduct:
            "PrimeNativeDecoderCheckpointV2IOExecutionProbe",
        authoritativeExecutionTarget:
            "PrimeNativeDecoderCheckpointV2IOExecutionProbe",
        authoritativeExecutionTargetDependencies: [
            "PrimeCore",
            "PrimeNativeDecoder",
            "PrimeNativeDecoderCheckpoint",
            "MLX",
            "MLXNN",
        ],
        authorityTestTarget:
            "PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests",
        executionProbeSourcePath:
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift",
        authorityTestSourcePath:
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift",
        executionPackageManifestPath:
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift",
        executionPackageResolvedPath:
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved",
        executionLauncherPath:
            ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh",
        executionEvidenceSourcePath:
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift",
        publicExecutionEvidenceType:
            "PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1",
        publicExternalBindingType:
            "PrimeNativeDecoderCheckpointExternalBindingV2",
        publicRootIdentityType:
            "PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1",
        publicEnvironmentPolicyType:
            "PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1",
        publicCanonicalReceiptDeclaration:
            "PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1.canonicalReceiptData()",
        publicCanonicalReceiptDecodeDeclaration:
            "PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1.decodeCanonicalReceipt(from:)",
        newExecutionSourceIdentityStatus:
            "PINNED_AFTER_SOURCE_STABILIZATION",
        newExecutionSourceBindings: [
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
        ],
        configuration: .native300MByte512,
        initializationSeed: 42,
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
        artifactRelativePath:
            "checkpoint-v2-native300m-seed42.safetensors",
        artifactPurpose: "immutable_data",
        maximumCheckpointByteCount: 1_101_205_504,
        maximumManifestByteCount: 16_777_216,
        requiredArtifactRootMode: 0o700,
        requiredPublishedArtifactMode: 0o444,
        requiredPublishedArtifactLinkCount: 1,
        requiredArtifactRootEntryCountBeforeWrite: 0,
        requiredArtifactRootEntryCountAfterWrite: 1,
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
        totalDecoderConstructionCountIsSourceInferredOnly: true,
        sourceInferredDecoderConstructionCount: 3,
        containerMaterializationCountRequiredByPinnedCodec: 2,
        writerHiddenDescriptorRestoreRequiredByPinnedCodec: true,
        writerPostRestoreReinspectionRequiredByPinnedCodec: true,
        publicLoadCompleteMaterializationInsideHeldCapabilityRequired: true,
        publicLoadPreAndPostWholeContainerVerificationRequired: true,
        independentPostLoadTensorHashReplayRequired: false,
        independentPostLoadArtifactRootVerifyRequired: false,
        executionFailureEmitsReceipt: false,
        executionRetryAuthorized: false,
        predecessorReceiptCompletionRequiredBeforeReclamation: true,
        runnerTemporaryReclamationAuthorized: true,
        runnerTemporaryReclamationScope:
            "exact_owned_direct_children_of_runner_temp_after_predecessor_log_and_receipt_validation_only",
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
        preservedRunnerTemporaryRelativePaths: [
            "ergentics-mlx-swift.git",
            "ergentics-mlx-swift",
            "prime-active-root-tests.log",
            "prime-checkpoint-v2-tests.log",
            "prime-checkpoint-v2-io-tests.log",
            "prime-native-decoder-metallib",
            "prime-native-decoder-metal-tests.log",
            "prime-native-decoder-runtime-closure-authority-tests.log",
            "prime-native-decoder-runtime-closure-probe.log",
            "prime-native-decoder-tokenizer-compatibility-authority-tests.log",
            "prime-native-decoder-tokenizer-compatibility-probe.log",
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
            "b861fa8270cbdceefd6079f7e09fece495fc4b79",
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
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_BEGIN=",
        receiptChunkMarker:
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_CHUNK=",
        receiptEndMarker:
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_END=",
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
        reclamationOccurredClaimIsLauncherLogEvidenceOnly: true,
        receiptClaimsOnlyReclaimedPathsAbsentBeforeProbe: true,
        supervisorPostReceiptIndependentWholeFileHashAuthorized: false,
        supervisorPostReceiptArtifactRootVerifyAuthorized: false,
        supervisorLiteralArtifactCleanupRequired: true,
        supervisorCleanupLstatRequired: true,
        supervisorCleanupUnlinkCount: 1,
        supervisorCleanupRmdirCount: 1,
        supervisorCleanupRecursiveDeletionAuthorized: false,
        supervisorCleanupAbsencePostconditionRequired: true,
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
        parentReceiptVerificationRequiredBeforeArtifactCleanup: true,
        artifactAndRootCleanupRequiredAfterParentVerification: true,
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
            "ABSTAIN_exact_seed42_native300m_v2_checkpoint_one_write_one_load_authorized_not_observed_no_artifact_admission",
        orderedNextActions: [
            "run_exact_clean_reviewed_main_one_write_one_fresh_load",
            "verify_canonical_receipt_and_cleanup_ephemeral_artifact_root",
            "append_exact_execution_observation_without_artifact_admission",
        ])

    public func validateExactV1() throws {
        let predecessor =
            PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            try configuration.validateExactNative300MByte512()
            for source in baseSourceBindings + newExecutionSourceBindings {
                try source.validate()
            }
        } catch {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityError
                    .contractDrift
        }

        let expectedReclaimable = [
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
        ]
        let expectedNewExecutionSourcePaths = [
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidence.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Package.resolved",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IOExecutionProbe/main.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IOExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IOExecutionAuthorityTests.swift",
            ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh",
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              predecessorAuthorityID == predecessor.authorityID,
              predecessorRemainsFrozen,
              predecessorRequiredForConsumption,
              authoritativeRepository == "Ergentics/ergentics-prime",
              baseRef == "refs/heads/main",
              baseRevision
                == "b861fa8270cbdceefd6079f7e09fece495fc4b79",
              baseOrderedParentRevisions == [
                  "15f858f4a8fa74a7b6a29b55da59d4660c50ff01",
                  "15d5f27f8284e80523c250133c4abf4de75d867a",
              ],
              baseTree
                == "7b8a1be7f34b28501178d5f8e7d78abb5d7dcb14",
              baseEmbeddedSourceIdentitySHA256
                == "efb9bd25738c946b0326241f492f6f576dfeef36481a373410b3951bc88aaeb7",
              basePullRequestNumber == 76,
              baseHistoryPreservingTwoParentMerge,
              baseSourceBindings.count == 12,
              Set(baseSourceBindings.map(\.path)).count
                == baseSourceBindings.count,
              exactMLXRevision == predecessor.exactMLXRevision,
              environmentPolicy
                == PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1
                    .declaration,
              authoritativeExecutionProduct
                == authoritativeExecutionTarget,
              authoritativeExecutionTargetDependencies == [
                  "PrimeCore",
                  "PrimeNativeDecoder",
                  "PrimeNativeDecoderCheckpoint",
                  "MLX",
                  "MLXNN",
              ],
              publicExecutionEvidenceType
                == "PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1",
              publicExternalBindingType
                == "PrimeNativeDecoderCheckpointExternalBindingV2",
              publicRootIdentityType
                == "PrimeNativeDecoderCheckpointV2ContainerIOExecutionRootIdentityV1",
              publicEnvironmentPolicyType
                == "PrimeNativeDecoderCheckpointV2ContainerIOExecutionEnvironmentPolicyV1",
              publicCanonicalReceiptDeclaration
                == "PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1.canonicalReceiptData()",
              publicCanonicalReceiptDecodeDeclaration
                == "PrimeNativeDecoderCheckpointV2ContainerIOExecutionEvidenceV1.decodeCanonicalReceipt(from:)",
              newExecutionSourceIdentityStatus
                == "PINNED_AFTER_SOURCE_STABILIZATION",
              newExecutionSourceBindings.count == 6,
              newExecutionSourceBindings.map(\.path)
                == expectedNewExecutionSourcePaths,
              Set(newExecutionSourceBindings.map(\.path)).count
                == newExecutionSourceBindings.count,
              initializationSeed == 42,
              compatibilityIdentityCanonicalByteCount
                == predecessor.publicCompatibilityIdentityCanonicalByteCount,
              compatibilityIdentitySHA256
                == predecessor.publicCompatibilityIdentitySHA256,
              parameterDescriptorCount == predecessor.parameterDescriptorCount,
              parameterCatalogCanonicalByteCount
                == predecessor.parameterCatalogCanonicalByteCount,
              parameterCatalogSHA256 == predecessor.parameterCatalogSHA256,
              totalParameterCount == predecessor.totalParameterCount,
              totalParameterByteCount == predecessor.totalParameterByteCount,
              maximumCheckpointByteCount
                == predecessor.maximumCheckpointByteCount,
              artifactRelativePath
                == "checkpoint-v2-native300m-seed42.safetensors",
              requiredArtifactRootMode == 0o700,
              requiredPublishedArtifactMode == 0o444,
              requiredPublishedArtifactLinkCount == 1,
              requiredArtifactRootEntryCountBeforeWrite == 0,
              requiredArtifactRootEntryCountAfterWrite == 1,
              requiredFreeSpaceMultiplier == 3,
              requiredAvailableFilesystemBytesAfterBuild
                == requiredFreeSpaceMultiplier * maximumCheckpointByteCount,
              requiredMemoryCacheLimit == 0,
              requiredMemoryCacheClearCount == 2,
              requiredCallerSourceModelConstructionCount == 1,
              requiredInitialParameterMaterializationEvaluationCount == 1,
              requiredPublicWriteInvocationCount == 1,
              requiredPublicWriteCompletionCount == 1,
              requiredPublicLoadInvocationCount == 1,
              requiredPublicLoadCompletionCount == 1,
              totalDecoderConstructionCountIsSourceInferredOnly,
              sourceInferredDecoderConstructionCount == 3,
              containerMaterializationCountRequiredByPinnedCodec == 2,
              writerHiddenDescriptorRestoreRequiredByPinnedCodec,
              writerPostRestoreReinspectionRequiredByPinnedCodec,
              publicLoadCompleteMaterializationInsideHeldCapabilityRequired,
              publicLoadPreAndPostWholeContainerVerificationRequired,
              !independentPostLoadTensorHashReplayRequired,
              !independentPostLoadArtifactRootVerifyRequired,
              !executionFailureEmitsReceipt,
              !executionRetryAuthorized,
              predecessorReceiptCompletionRequiredBeforeReclamation,
              runnerTemporaryReclamationAuthorized,
              reclaimableRunnerTemporaryRelativePaths
                == expectedReclaimable,
              Set(reclaimableRunnerTemporaryRelativePaths).count == 24,
              Set(reclaimableRunnerTemporaryRelativePaths)
                .isDisjoint(with: preservedRunnerTemporaryRelativePaths),
              reclaimableRunnerTemporaryRelativePaths.allSatisfy({ path in
                  !path.isEmpty
                      && !path.contains("/")
                      && path != "."
                      && path != ".."
              }),
              recursiveDeletionAuthorizedOnlyForExactAllowlist,
              !symlinkReclamationAuthorized,
              !nonOwnedPathReclamationAuthorized,
              !repositoryPathReclamationAuthorized,
              !dependencyBareRepositoryReclamationAuthorized,
              !dependencyWorktreeReclamationAuthorized,
              !metallibRootReclamationAuthorized,
              !predecessorLogReclamationAuthorized,
              requiredGitHubActionsValue == "true",
              requiredRunnerEnvironment == "github-hosted",
              requiredExecutionEvent == "push",
              requiredExecutionRef == "refs/heads/main",
              requiredExecutionRunAttempt == 1,
              githubSHAEqualsExactRevisionRequired,
              macOSRequired,
              requiredDirectSuccessorFirstParentRevision == baseRevision,
              requiredExecutedCommitParentCount == 2,
              executedTreeMustEqualReviewedSecondParentTree,
              directSuccessorValidationRequiredBeforeDeletionBuildOrModel,
              !localOrManualExecutionAuthorized,
              !rerunExecutionAuthorized,
              !laterMainExecutionAuthorized,
              observationSuccessorMustRemoveLiveLauncherCommandBeforeMerge,
              receiptTransportSchema
                == "canonical_json_rfc4648_base64_chunk_transport_v1",
              receiptTransportEncoding == "rfc4648_base64_no_wrap",
              receiptChunkCharacterCount == 4_096,
              receiptChunkCharacterCount.isMultiple(of: 4),
              receiptChunkOrdinalWidth == 6,
              maximumReceiptChunkCount == 86,
              maximumReceiptChunkCount
                == Int(
                    ((4 * ((maximumCanonicalReceiptByteCount + 2) / 3))
                        + UInt64(receiptChunkCharacterCount) - 1)
                        / UInt64(receiptChunkCharacterCount)),
              maximumReceiptTransportLineByteCount == 16_384,
              receiptBeginMarker.utf8.count
                    + receiptChunkCharacterCount
                < maximumReceiptTransportLineByteCount,
              receiptChunkMarker.utf8.count
                    + receiptChunkOrdinalWidth + 1
                    + receiptChunkCharacterCount
                < maximumReceiptTransportLineByteCount,
              receiptEndMarker.utf8.count
                    + receiptChunkCharacterCount
                < maximumReceiptTransportLineByteCount,
              maximumCanonicalReceiptByteCount == 262_144,
              receiptBeginLineCount == 1,
              receiptEndLineCount == 1,
              receiptChunksMustBeContiguousAndOrdered,
              receiptBeginMustBindPayloadByteCountSHA256ChunkCountAndIDs,
              receiptEndMustRepeatChunkCountAndPayloadSHA256,
              !singleLineReceiptPayloadAuthorized,
              !receiptMayContainAbsoluteRunnerPaths,
              !receiptMayContainRawArtifactBytes,
              reclamationOccurredClaimIsLauncherLogEvidenceOnly,
              receiptClaimsOnlyReclaimedPathsAbsentBeforeProbe,
              !supervisorPostReceiptIndependentWholeFileHashAuthorized,
              !supervisorPostReceiptArtifactRootVerifyAuthorized,
              supervisorLiteralArtifactCleanupRequired,
              supervisorCleanupLstatRequired,
              supervisorCleanupUnlinkCount == 1,
              supervisorCleanupRmdirCount == 1,
              !supervisorCleanupRecursiveDeletionAuthorized,
              supervisorCleanupAbsencePostconditionRequired,
              exactRevisionCheckoutRequired,
              cleanCheckoutBeforeAndAfterRequired,
              releaseConfigurationRequired,
              releaseInstrumentationEvidenceAbsentRequired,
              arm64Required,
              singleMetalDeviceRequired,
              mlxGPUDeviceIndex == 0,
              metalLeaseHeldAcrossCheckpointExecutionRequired,
              exactFreshMetallibRequired,
              launchedEnvironmentRevalidationRequired,
              callerSourceModelLexicallyScopedThroughWriteOnlyRequired,
              !sourceModelARCDeallocationObservationRequired,
              memoryCacheClearBetweenSourceWriteAndPublicLoadRequired,
              processExitRequiredAfterReceipt,
              parentReceiptVerificationRequiredBeforeArtifactCleanup,
              artifactAndRootCleanupRequiredAfterParentVerification,
              authoritySourceAdditionAuthorized,
              evidenceSourceAdditionAuthorized,
              isolatedExecutionPackageAdditionAuthorized,
              isolatedExecutionLauncherAdditionAuthorized,
              workflowCommandListExtensionAuthorized,
              !workflowTopologyMutationAuthorized,
              !workflowJobInventoryMutationAuthorized,
              !workflowStepInventoryMutationAuthorized,
              !workflowRunnerMutationAuthorized,
              !workflowExecutionOrderMutationAuthorized,
              reviewedMainTimeoutExtensionAuthorized,
              reviewedMainTimeoutBeforeMinutes == 45,
              reviewedMainTimeoutAfterMinutes == 90,
              reviewedMainCheckoutFetchDepthBefore == 1,
              reviewedMainCheckoutFetchDepthDuringExecution == 2,
              reviewedMainCheckoutFetchDepthAfterObservation == 1,
              reviewedMainCheckoutFetchDepthExtensionAuthorized,
              sourceGatePinExtensionAuthorized,
              embeddedBuildProvenanceUpdateAuthorized,
              documentationUpdateAuthorized,
              exactReviewedMainExecutionAuthorized,
              !rootPackageManifestMutationAuthorized,
              !rootPackageResolvedMutationAuthorized,
              !newExternalDependencyAuthorized,
              !predecessorAuthorityMutationAuthorized,
              !checkpointCodecMutationAuthorized,
              !repairedDecoderMutationAuthorized,
              !compatibilityIdentityMutationAuthorized,
              !maintainedRuntimeMutationAuthorized,
              !frozenMetalLauncherMutationAuthorized,
              !existingRuntimeLauncherMutationAuthorized,
              !existingTokenizerLauncherMutationAuthorized,
              !existingValidationMutationAuthorized,
              !frozen44TestInventoryMutationAuthorized,
              native300MModelAllocationAuthorized,
              native300MCheckpointWriteAuthorized,
              native300MCheckpointLoadAuthorized,
              ephemeralArtifactRootIOAuthorized,
              exclusiveNoReplacePublicationAuthorized,
              generatedFileAndParentSynchronizationRequired,
              externalWholeContainerBindingRequired,
              falseAuthorityCeilingsAreExact,
              falseObservationCeilingsAreExact,
              status
                == "ABSTAIN_exact_seed42_native300m_v2_checkpoint_one_write_one_load_authorized_not_observed_no_artifact_admission",
              orderedNextActions == [
                  "run_exact_clean_reviewed_main_one_write_one_fresh_load",
                  "verify_canonical_receipt_and_cleanup_ephemeral_artifact_root",
                  "append_exact_execution_observation_without_artifact_admission",
              ]
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIOExecutionAuthorityError
                    .contractDrift
        }
    }

    private var falseAuthorityCeilingsAreExact: Bool {
        !checkpointArtifactRetentionAuthorized
            && !checkpointArtifactUploadAuthorized
            && !checkpointArtifactAdmissionAuthorized
            && !checkpointReplacementAuthorized
            && !failedWriteRecoveryExperimentAuthorized
            && !existingCheckpointArtifactConsumptionAuthorized
            && !decoderForwardAuthorized
            && !decoderKVCacheUseAuthorized
            && !backwardAuthorized
            && !lossAuthorized
            && !optimizerStepAuthorized
            && !generationAuthorized
            && !trainingAuthorized
            && !trainingResumeAuthorized
            && !candidateAdmissionAuthorized
            && !trialAuthorized
            && !canaryReplacementAuthorized
            && !quantizationAuthorized
            && !productUseAuthorized
            && !publicationAuthorized
    }

    private var falseObservationCeilingsAreExact: Bool {
        !native300MModelAllocationObserved
            && !native300MCheckpointWriteObserved
            && !native300MCheckpointLoadObserved
            && !checkpointIOObserved
            && !checkpointArtifactAvailable
            && !checkpointArtifactRetained
            && !checkpointArtifactProvenanceEstablished
            && !checkpointContainerHashBound
            && !checkpointAdmissionGranted
            && !checkpointDurabilityObserved
            && !logicalParameterRoundTripObserved
            && !runtimeDependencyClosureReobservedForCheckpointIO
    }
}
