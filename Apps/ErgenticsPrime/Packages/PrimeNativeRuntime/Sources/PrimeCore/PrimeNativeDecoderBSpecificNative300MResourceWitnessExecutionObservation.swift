// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift(String)
    case noncanonicalEncoding
}

/// Frozen, append-only evidence for the sole run-123 B-specific Native-300M
/// resource-witness execution.
///
/// This Foundation/Codable value records the exact public PASS receipt and
/// keeps the scientific resource result, supervisor-integrity closure, and
/// outer workflow closure separate. It performs no filesystem, process,
/// network, Metal, MLX, model, launcher, witness, or artifact operation.
/// The one-shot is consumed and Stage 7 remains unauthorized.
public struct
    PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public struct SourceIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct RepositoryIdentity: Codable, Equatable, Sendable {
        public let repository: String
        public let pullRequestNumber: Int
        public let ref: String
        public let baseRevision: String
        public let reviewedHeadRevision: String
        public let reviewedHeadTree: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let mergedAt: String
        public let mergeCommitSignatureVerified: Bool
        public let mergeCommitSignatureReason: String
        public let mergeCommitSignatureVerifiedAt: String
        public let historyPreservingTwoParentMergeObserved: Bool
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let exactMainRefMatchedAtTerminalAudit: Bool
        public let changedPathCount: Int
        public let manifestOrLockChangedPathCount: Int
    }

    public struct JobIdentity: Codable, Equatable, Sendable {
        public let id: Int
        public let name: String
        public let status: String
        public let conclusion: String
        public let startedAt: String
        public let completedAt: String
        public let runnerID: Int?
        public let runnerName: String?
        public let runnerGroupName: String?
        public let runnerLabel: String
        public let orderedStepNames: [String]
        public let orderedStepConclusions: [String]
        public let jobURL: String
    }

    public struct PullRequestLane: Codable, Equatable, Sendable {
        public let workflowID: Int
        public let workflowName: String
        public let workflowPath: String
        public let runID: Int
        public let runNumber: Int
        public let runAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let headBranch: String
        public let headRevision: String
        public let headTree: String
        public let orderedParentRevisions: [String]
        public let createdAt: String
        public let startedAt: String
        public let terminalUpdatedAt: String
        public let status: String
        public let conclusion: String
        public let exactHeadPullRequestRunCount: Int
        public let previousAttemptURLWasNull: Bool
        public let retryCount: Int
        public let rerunCount: Int
        public let artifactCount: Int
        public let activeRootJob: JobIdentity
        public let reviewedMainJob: JobIdentity
        public let launcherInvocationCount: Int
        public let directExecutableProbeCount: Int
        public let witnessExecutionCount: Int
        public let metalExecutionCount: Int
        public let native300MMechanicsExecutionCount: Int
        public let relevantReceiptCount: Int
        public let runURL: String
    }

    public struct RunIdentity: Codable, Equatable, Sendable {
        public let workflowID: Int
        public let workflowName: String
        public let workflowPath: String
        public let runID: Int
        public let runNumber: Int
        public let runAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let headBranch: String
        public let headRevision: String
        public let actor: String
        public let triggeringActor: String
        public let createdAt: String
        public let startedAt: String
        public let terminalUpdatedAt: String
        public let status: String
        public let conclusion: String
        public let exactHeadPushRunCount: Int
        public let previousAttemptURLWasNull: Bool
        public let retryCount: Int
        public let rerunCount: Int
        public let rerunObserved: Bool
        public let rerunAuthorized: Bool
        public let artifactCount: Int
        public let runURL: String
    }

    public struct RawLogIdentity: Codable, Equatable, Sendable {
        public let codeUnitCount: Int
        public let byteCount: Int
        public let lfByteCount: Int
        public let newlineDelimitedComponentCountIncludingTerminalEmpty: Int
        public let utf8BOMHex: String
        public let startsWithUTF8BOM: Bool
        public let usesLFOnly: Bool
        public let endsWithLF: Bool
        public let sha256: String
        public let publicReceiptOccurrenceCount: Int
        public let internalCandidatePrefixOccurrenceCount: Int
        public let internalTerminalPrefixOccurrenceCount: Int
        public let rawGitHubLogArchiveBytesBound: Bool
        public let retainedInRepository: Bool
    }

    public struct TestTopology: Codable, Equatable, Sendable {
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedBContractTestCount: Int
        public let focusedStepXCTestCount: Int
        public let metalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let tokenizerTestCount: Int
        public let launcherLocalBContractTestCount: Int
        public let liveStepXCTestCount: Int
        public let totalXCTestCount: Int
        public let totalFailureCount: Int
        public let totalSkipCount: Int
        public let bContractStartCount: Int
        public let bContractPassCount: Int
        public let bContractFailureCount: Int
        public let bContractSkipCount: Int
        public let launcherInvocationCount: Int
        public let buildInvocationCount: Int
        public let directXCTestInvocationCount: Int
        public let directExecutableProbeCount: Int
        public let privateCandidateCount: Int
        public let privateTerminalCount: Int
        public let publicReceiptCount: Int
        public let aggregateInvocationCount: Int
        public let originalStage5LauncherInvocationCount: Int
        public let replacementStage5LauncherInvocationCount: Int
        public let historicalStage6LauncherInvocationCount: Int
        public let originalStage5ReceiptCount: Int
        public let replacementStage5ReceiptCount: Int
        public let historicalStage6ReceiptCount: Int
        public let observedLiveOrder: [String]
        public let observedBInternalOrder: [String]
    }

    public struct RetirementPathIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitMode: String
        public let role: String
    }

    public struct RetirementBoundary: Codable, Equatable, Sendable {
        public let retirementRequired: Bool
        public let retirementObserved: Bool
        public let successfulAttemptConsumed: Bool
        public let exactMainClosureRequired: Bool
        public let exactChangedPaths: [RetirementPathIdentity]
        public let expectedRootTestCount: Int
        public let expectedIsolatedGroupTestCounts: [Int]
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedMetalTestCount: Int
        public let expectedMaintainedRuntimeTestCount: Int
        public let expectedTokenizerTestCount: Int
        public let expectedLiveStepXCTestCount: Int
        public let expectedTotalXCTestCount: Int
        public let expectedBFocusedContractTestCount: Int
        public let expectedBLauncherLocalContractTestCount: Int
        public let expectedBDirectExecutableProbeCount: Int
        public let expectedBLauncherInvocationCount: Int
        public let expectedBInternalCandidatePrefixCount: Int
        public let expectedBInternalTerminalPrefixCount: Int
        public let expectedBPublicReceiptCount: Int
        public let expectedOriginalStage5LauncherInvocationCount: Int
        public let expectedReplacementStage5LauncherInvocationCount: Int
        public let expectedHistoricalStage6LauncherInvocationCount: Int
        public let expectedOriginalStage5ReceiptCount: Int
        public let expectedReplacementStage5ReceiptCount: Int
        public let expectedHistoricalStage6ReceiptCount: Int
        public let expectedMaintainedRuntimeReceiptCount: Int
        public let expectedTokenizerReceiptCount: Int
        public let expectedLiveOrder: [String]
        public let mechanicsSourcesPreservedForAudit: Bool
    }

    public struct ReceiptIdentity: Codable, Equatable, Sendable {
        public let prefix: String
        public let prefixByteCount: Int
        public let canonicalJSON: String
        public let canonicalJSONByteCount: Int
        public let canonicalJSONSHA256: String
        public let storageByteCountIncludingLF: Int
        public let storageSHA256IncludingLF: String
        public let prefixedCanonicalByteCount: Int
        public let prefixedCanonicalSHA256: String
        public let prefixedCanonicalLFByteCount: Int
        public let prefixedCanonicalLFSHA256: String
        public let emittedAt: String
        public let fullTimestampedLineByteCount: Int
        public let fullTimestampedLineSHA256: String
        public let logLineNumber: Int
        public let exactOccurrenceCount: Int
        public let topLevelKeyCount: Int
        public let candidateKeyCount: Int
        public let terminalKeyCount: Int
        public let receiptID: String
        public let schemaVersion: Int
        public let status: String
        public let classification: String
        public let candidateCanonicalByteCount: Int
        public let candidateSHA256: String
        public let terminalCanonicalByteCount: Int
        public let terminalSHA256: String
    }

    public struct ResourcePassBoundary: Codable, Equatable, Sendable {
        public let candidatePresent: Bool
        public let candidateScientificStatus: String
        public let candidateClassification: String
        public let resourceProbeExecuted: Bool
        public let resourceEnvelopeEstablished: Bool
        public let bSpecificNative300MResourceWitnessEstablished: Bool
        public let bSpecificNative300MResourceClearanceEstablished: Bool
        public let runnerMemoryCapacityEstablished: Bool
        public let updateOccurred: Bool
        public let directPackageBTrainingLogitsAPICallCount: Int
        public let denseEmbeddingConstructionCount: Int
        public let maintainedGatherTrainingLogitsCount: Int
        public let inputEmbeddingForwardPairDiagnosticInvocationCount: Int
        public let tinyTrainingSelectorInvocationCount: Int
        public let checkedEvaluationBarrierCount: Int
        public let gpuSynchronizationBarrierCount: Int
        public let lossFloat32Bits: UInt32
        public let rawGradientNormFloat32Bits: UInt32
        public let gradientClipScaleFloat32Bits: UInt32
        public let parameterFingerprintBefore: String
        public let parameterFingerprintAfter: String
        public let parameterFingerprintSamplePlanSHA256: String
        public let parameterFingerprintSampleCount: Int
        public let phaseNames: [String]
        public let finalElapsedNanoseconds: UInt64
        public let peakMLXBytes: UInt64
        public let mlxMemoryHeadroomBytes: UInt64
        public let physicalMemoryCapacityBytes: UInt64
        public let configuredMemoryLimitBytes: UInt64
        public let runtimeMetallibByteCount: Int
        public let runtimeMetallibSHA256: String
    }

    public struct IntegrityPassBoundary: Codable, Equatable, Sendable {
        public let terminalStatus: String
        public let classification: String
        public let leaseAcquired: Bool
        public let releaseVerifierExitZero: Bool
        public let supervisorIntegrityGuardCount: Int
        public let firstFailedGuardID: String?
        public let errnoAvailability: String
        public let errno: Int?
        public let actualMetadataAvailability: String
        public let actualMetadataPresent: Bool
        public let actualMetadataUnavailableReason: String?
        public let supervisorPostCandidateInventory: [String]
        public let verifierInventory: [String]
        public let leaseTupleStableThroughVerifier: Bool
        public let leaseDeviceID: UInt64
        public let leaseInode: UInt64
        public let leaseUID: Int
        public let leaseGID: Int
        public let leaseMode: String
        public let leaseObservedNlink: Int
        public let leaseByteCount: Int
        public let leaseFileType: String
        public let parentStableFieldsMatchPreflightAndVerifier: Bool
        public let parentPhysicalPath: String
        public let parentDeviceID: UInt64
        public let parentInode: UInt64
        public let parentUID: Int
        public let parentGID: Int
        public let parentMode: String
        public let parentPreflightObservedNlink: Int
        public let parentPostCandidateObservedNlink: Int
        public let parentVerifierObservedNlink: Int
    }

    public struct WorkflowClosureBoundary: Codable, Equatable, Sendable {
        public let workflowConclusion: String
        public let activeRootJobConclusion: String
        public let reviewedMainJobConclusion: String
        public let launcherExitCode: Int
        public let launcherExitedZero: Bool
        public let launcherClosureEstablished: Bool
        public let publicReceiptWasLastLauncherOutput: Bool
        public let onlyPostReceiptRunnerLine: String
        public let postReceiptRunnerLineNumber: Int
        public let receiptDoesNotClaimMechanicsSuccess: Bool
        public let receiptDoesNotClaimWorkflowSuccess: Bool
        public let artifactUploadInvoked: Bool
        public let retainedArtifactObserved: Bool
        public let retryObserved: Bool
        public let rerunObserved: Bool
        public let outerJobClosedAfterReceipt: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let oneShotConsumed: Bool
        public let oneShotExhausted: Bool
        public let stage5MechanicsSuccessEstablished: Bool
        public let stage5ResultEstablished: Bool
        public let stage5AssayClearanceEstablished: Bool
        public let repeatedSameDeviceBPathDeterminismEstablished: Bool
        public let exactSameDeviceBPathGradientBytesEstablished: Bool
        public let bSpecificNative300MResourceWitnessEstablished: Bool
        public let bSpecificNative300MResourceClearanceEstablished: Bool
        public let historicalStage6ResourceClearanceRemainsEstablished: Bool
        public let additionalExecutionAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let additionalNative300MAllocationAuthorized: Bool
        public let additionalNative300MExecutionAuthorized: Bool
        public let additionalBResourceWitnessExecutionAuthorized: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let artifactUploadAuthorized: Bool
        public let retainedArtifactAuthorized: Bool
        public let ordinaryJobFitEstablished: Bool
        public let historicalStage6ResourceClearanceAppliesToBPath: Bool
        public let broadNative300MTrainingAuthorized: Bool
        public let generalTrainingResumeEstablished: Bool
        public let native300MTrajectoryTrainingResumeEstablished: Bool
        public let durableCheckpointIOAuthorized: Bool
        public let checkpointAdmissionGranted: Bool
        public let candidateAdmissionGranted: Bool
        public let modelQualityEstablished: Bool
        public let downstreamTrialAuthorized: Bool
        public let canaryAuthorized: Bool
        public let quantizationAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
        public let stage7RequiresSeparateAuthorityAfterWitness: Bool
        public let stage7AuthorityEstablished: Bool
        public let stage7Authorized: Bool
    }

    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let repositoryIdentity: RepositoryIdentity
    public let observedSourceBindings: [SourceIdentity]
    public let pullRequestLane: PullRequestLane
    public let runIdentity: RunIdentity
    public let activeRootJob: JobIdentity
    public let reviewedMainJob: JobIdentity
    public let activeRootRawLog: RawLogIdentity
    public let reviewedMainRawLog: RawLogIdentity
    public let testTopology: TestTopology
    public let retirementBoundary: RetirementBoundary
    public let receiptIdentity: ReceiptIdentity
    public let resourcePassBoundary: ResourcePassBoundary
    public let integrityPassBoundary: IntegrityPassBoundary
    public let workflowClosureBoundary: WorkflowClosureBoundary
    public let authorityCeiling: AuthorityCeiling
    public let status: String

    public static let canonicalSHA256 =
        "da9edca25faaef6ae6fae38669692603faeb7c29f4995a0fce4a096015a49a88"

    public static let frozenReceiptCanonicalJSON = #"""
{"actual_metadata":null,"actual_metadata_availability":"not_applicable","actual_metadata_unavailable_reason":null,"artifact_upload_authorized":false,"authority_canonical_sha256":"15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba","authority_id":"prime_native_decoder_b_specific_native300m_resource_witness_authority_v1","b_specific_native300m_resource_clearance":true,"b_specific_native300m_resource_witness":true,"candidate_canonical_byte_count":8397,"candidate_present":true,"candidate_scientific_status":"PASS","candidate_sha256":"aad81c55024652ef594e65dfbfbbba74f34176c6cf1792b45676cbbdaacfbba8","classification":"pass","errno":null,"errno_availability":"not_applicable","exact_changed_source_identities":[{"byte_count":801935,"git_blob":"401d0177d98e62da16c2d386c70a12baf9bc686a","mode":"100755","path":".github/scripts/prime-ci-active-root-quarantine.sh","sha256":"916399c9713d00af45a1fa87b338bcab6c9573ebc4d1b3695320933bdfbdccf6"},{"byte_count":137210,"git_blob":"b621916a678e6a2eb492504e3f63994d2d561491","mode":"100755","path":".github/scripts/prime-ci-native-decoder-b-specific-native300m-resource-witness.sh","sha256":"08dc6e648b81fee6f59b46b7009a74eb2f8e20ac2616c8d81a8a54f90c9597b4"},{"byte_count":100706,"git_blob":"8b461c5ac489c6f224882822b359c309992ce581","mode":"100644","path":".github/workflows/prime-active-root-quarantine.yml","sha256":"34d7871c162015416b28f35ba5fb0a2450d4a358873bf64958e104993dadf82a"},{"byte_count":546,"git_blob":"04085f3be80123e41b1dfed54360f02c24107ab2","mode":"100644","path":"Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift","sha256":"e56e3de248d0546541e7ddb7ef480727b8e7fba1999932147fe3fe05e6a56b23"},{"byte_count":225960,"git_blob":"cf3d743d121f4eaa028e0e392e04587bcd0b93d8","mode":"100644","path":"Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift","sha256":"77fbe6b5e9548d84af30c95ba4ca0cfa2d03d5e1884c74d0a9ae297b109eed8b"},{"byte_count":2778,"git_blob":"08b732f88ce3be0cd86905df8b78f2492c7ca557","mode":"100644","path":"Tests/PrimeNativeDecoderTrainingValidation/Package.swift","sha256":"46fca0c696a46ccc9e22180ca5ec80cffc202a43b68b5f8c9568051e8e71348e"},{"byte_count":231,"git_blob":"a8d85ea641b5442475893d97631fc3d1f886b9b9","mode":"100644","path":"Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MResourceWitness/main.swift","sha256":"d10ebc104e8fa883509e4f42a7185484004ad37bc1f9d69c91cdd0e6c4695f51"},{"byte_count":30202,"git_blob":"b78613e392ab20df0d11a2546aadf484e419b75c","mode":"100644","path":"Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests.swift","sha256":"fb3abc5d6377867d438b8c48fd9cbeab3549f4570ded7570cf4bc9f585c1d8a7"}],"first_failed_guard_id":null,"historical_stage6_resource_clearance_applies_to_b_path":false,"lease_acquired":true,"mechanics_revision":"bf98ddb13f6f6128a185b2f553b5cb3f1e30904b","mechanics_run_attempt":1,"mechanics_run_id":31859699200,"mechanics_run_number":123,"mechanics_tree":"2ef7501506f19b9d9734dbc63ccacc62182c3952","one_shot_consumed":true,"ordinary_job_fit_established":false,"release_verifier_exit_zero":true,"rerun_authorized":false,"retained_artifact_authorized":false,"retry_authorized":false,"schema_id":"ergentics_prime_native_decoder_b_specific_native300m_resource_witness_receipt_v1","schema_version":1,"stage7_authorized":false,"status":"PASS","supervisor_integrity_guard_count":13,"terminal_canonical_byte_count":2425,"terminal_sha256":"ec960f822eab44b516273f19205246de5cb4bd544da7312b1396f60ceb48c2a4","validated_private_candidate":{"authority_canonical_sha256":"15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba","authority_id":"prime_native_decoder_b_specific_native300m_resource_witness_authority_v1","classification":"pass","one_shot_consumed":true,"payload":{"environment":{"filesystem_observation_fsid":[16777234,26],"filesystem_observation_path":"/Users/runner/work/_temp/prime-native-decoder-b-specific-native300m-resource-witness-build/arm64-apple-macosx/release","metal_device_count":1,"metal_device_has_unified_memory":true,"metal_device_index":0,"metal_device_is_default":true,"metal_device_max_buffer_length_bytes":3758096384,"metal_device_max_recommended_working_set_bytes":5010800640,"metal_device_name":"Apple Paravirtual device","metal_device_registry_id":4294967699,"mlx_compile_transform_invocation_count":0,"mlx_cpu_fallback_used":false,"mlx_default_device_is_supplied_device":true,"mlx_default_stream_is_gpu":true,"mlx_device_constructor_index":0,"mlx_device_type":"gpu","mlx_enable_tf32":"0","mlx_revision":"d37885a278f1c37484a94d0f401a418735e66519","operating_system_build":"26.5.2-25F84","runtime_metallib_byte_count":6292716,"runtime_metallib_path":"/Users/runner/work/_temp/prime-native-decoder-b-specific-native300m-resource-witness-build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib","runtime_metallib_sha256":"934ed1214e2fb2de9c79efa072357ec9df8be0b87ca0e9395340f93c98ee829a","swift_sdk":"26.5","swift_version":"Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) Target: arm64-apple-macosx26.0","swiftpm_build_configuration":"release","xcode_version":"Xcode 26.6 Build version 17F113"},"lease":{"acquired_before_coregraphics_metal_or_mlx":true,"acquired_nonblocking":true,"held_through_candidate_flush":true,"held_through_postflight":true,"lease_path":"/Users/runner/work/_temp/prime-native-decoder-b-specific-native300m-resource-witness-metal-lease/device-0.lock","supervisor_owned":true,"supervisor_release_verifier_proved":false,"type":"PrimeMetalDeviceLease","worker_inherited_lease_descriptor_count":0,"worker_owned":false},"limits":{"available_filesystem_floor_bytes":12884901888,"configured_cache_limit_bytes":0,"configured_cache_limit_readback_bytes":0,"configured_memory_limit_bytes":5010800640,"configured_memory_limit_formula":"min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)","configured_memory_limit_readback_bytes":5010800640,"container_headers_and_manifests_included_in_minimum":false,"duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum":false,"gradient_logical_bytes":1084428288,"minimum_committed_tensor_state_bytes":3253284864,"minimum_memory_limit_floor_bytes":4337713152,"minimum_state_plus_gradient_bytes":4337713152,"mlx_limit_is_not_rss_limit":true,"optimizer_moment_logical_bytes":2168856576,"optimizer_moment_tensor_count":436,"statfs_is_observational_only":true,"supervisor_end_to_end_timeout_seconds":1500,"termination_grace_seconds":10,"three_times_committed_state_disk_comparator_bytes":9759854592,"validated_first_moment_tensor_count":218,"validated_gradient_logical_bytes":1084428288,"validated_gradient_path_count":218,"validated_optimizer_moment_logical_bytes":2168856576,"validated_parameter_path_count":218,"validated_second_moment_tensor_count":218,"validated_unique_parameter_count":271107072,"validated_weights_logical_bytes":1084428288,"weights_logical_bytes":1084428288,"worker_active_timeout_seconds":1200},"outcome":{"classification":"pass","gradient_clip_scale_float32_bits":1027397872,"loss_float32_bits":1088043293,"one_shot_consumed":true,"operation_counts":{"adamw_update_count":1,"backward_count":1,"checked_evaluation_barrier_count":6,"cross_entropy_count":1,"dense_embedding_construction_count":1,"direct_package_b_training_logits_api_call_count":1,"evaluation_forward_pass_count":0,"forward_loss_count":1,"full_graph_evaluation_count":1,"gpu_synchronization_barrier_count":6,"gradient_clip_count":1,"gradient_norm_count":1,"input_embedding_forward_pair_diagnostic_invocation_count":0,"kv_cache_allocation_count":0,"maintained_gather_training_logits_count":0,"memory_clear_cache_count":1,"mlx_peak_memory_reset_count":1,"model_allocation_count":1,"model_materialization_count":1,"optimizer_step_count":1,"postflight_device_reenumeration_count":1,"tiny_training_selector_invocation_count":0,"token_bounds_checked_eval_count":1,"token_bounds_gpu_synchronization_count":1,"token_bounds_host_bool_item_count":1,"token_bounds_validation_count":1,"value_and_grad_count":1},"parameter_fingerprint_after":"4e0f9afe1e7217d11379f02c1e44ea498c3cbda5add228c247166e6775d8f7d2","parameter_fingerprint_before":"64263c521c6534561fb66a0e87e10a1229bdc9fe859f879c3a9f91c11abfa04e","parameter_fingerprint_sample_count":654,"parameter_fingerprint_sample_plan_sha256":"a36fdb60e23052b03b8e257224e1d47fd9731294f34a268a5fbff2b21ac49f87","postflight_device_identity_matches_preflight":true,"postflight_mlx_policy_and_limits_match_preflight":true,"raw_gradient_norm_float32_bits":1101890567,"resource_clearance_established":true,"resource_envelope_established":true,"resource_probe_executed":true,"runner_memory_capacity_established":true,"status":"PASS","update_occurred":true,"worker_candidate_present":true},"phase_metrics":[{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":149300625,"filesystem_available_bytes":90454147072,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":32014336,"metal_current_allocated_bytes":0,"mlx_active_bytes":0,"mlx_cache_bytes":0,"mlx_peak_bytes":0,"phase":"preflight","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":6866304,"task_resident_bytes":32014336,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":2230749375,"filesystem_available_bytes":90453405696,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":74956800,"metal_current_allocated_bytes":1096794112,"mlx_active_bytes":1084430904,"mlx_cache_bytes":0,"mlx_peak_bytes":1084432640,"phase":"post_model_materialization","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":1131726784,"task_resident_bytes":70844416,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":5674713667,"filesystem_available_bytes":90452787200,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":74956800,"metal_current_allocated_bytes":2171158528,"mlx_active_bytes":2168857220,"mlx_cache_bytes":0,"mlx_peak_bytes":2196646016,"phase":"post_b_forward_backward","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":2209384384,"task_resident_bytes":66568192,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":13810115208,"filesystem_available_bytes":89378963456,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":78856192,"metal_current_allocated_bytes":3256221696,"mlx_active_bytes":3253285516,"mlx_cache_bytes":0,"mlx_peak_bytes":3253285668,"phase":"post_norm_clip","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":3304064960,"task_resident_bytes":38371328,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":26972302042,"filesystem_available_bytes":88305139712,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":101351424,"metal_current_allocated_bytes":4351885312,"mlx_active_bytes":4337715768,"mlx_cache_bytes":0,"mlx_peak_bytes":4790771492,"phase":"post_adam_update_full_evaluation","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":4423567488,"task_resident_bytes":68648960,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":29530094292,"filesystem_available_bytes":88305139712,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":101351424,"metal_current_allocated_bytes":1048576,"mlx_active_bytes":0,"mlx_cache_bytes":0,"mlx_peak_bytes":4790771492,"phase":"post_lexical_deallocation_and_clear_cache","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":69683264,"task_resident_bytes":58294272,"unavailable_reason":null}]},"schema_id":"ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_candidate_v1","schema_version":1,"scientific_status":"PASS"},"validated_private_terminal":{"actual_metadata":null,"actual_metadata_availability":"not_applicable","actual_metadata_unavailable_reason":null,"authority_canonical_sha256":"15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba","authority_id":"prime_native_decoder_b_specific_native300m_resource_witness_authority_v1","candidate_present":true,"candidate_scientific_status":"PASS","candidate_sha256":"aad81c55024652ef594e65dfbfbbba74f34176c6cf1792b45676cbbdaacfbba8","classification":"pass","errno":null,"errno_availability":"not_applicable","first_failed_guard_id":null,"lease_acquired":true,"one_shot_consumed":true,"release_verifier_exit_zero":true,"schema_id":"ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_terminal_v1","schema_version":1,"supervisor_integrity_guard_count":13,"supervisor_post_candidate_inventory":["device-0.lock"],"supervisor_post_candidate_lease_tuple":{"acl_entry_count":0,"byte_count":0,"device_id":16777234,"file_type":"regular_file","gid":20,"inode":2990754,"mode":"0600","observed_extended_attribute_names":[],"observed_nlink":1,"security_flags":0,"uid":501},"supervisor_post_candidate_parent_tuple":{"acl_entry_count":0,"device_id":16777234,"file_type":"directory","gid":20,"inode":2990745,"mode":"0700","observed_extended_attribute_names":[],"observed_nlink":3,"physical_path":"/Users/runner/work/_temp/prime-native-decoder-b-specific-native300m-resource-witness-metal-lease","security_flags":0,"uid":501},"supervisor_preflight_parent_tuple":{"acl_entry_count":0,"device_id":16777234,"file_type":"directory","gid":20,"inode":2990745,"mode":"0700","observed_extended_attribute_names":[],"observed_nlink":2,"physical_path":"/Users/runner/work/_temp/prime-native-decoder-b-specific-native300m-resource-witness-metal-lease","security_flags":0,"uid":501},"terminal_status":"PASS","verifier_inventory":["device-0.lock"],"verifier_lease_tuple":{"acl_entry_count":0,"byte_count":0,"device_id":16777234,"file_type":"regular_file","gid":20,"inode":2990754,"mode":"0600","observed_extended_attribute_names":[],"observed_nlink":1,"security_flags":0,"uid":501},"verifier_parent_tuple":{"acl_entry_count":0,"device_id":16777234,"file_type":"directory","gid":20,"inode":2990745,"mode":"0700","observed_extended_attribute_names":[],"observed_nlink":3,"physical_path":"/Users/runner/work/_temp/prime-native-decoder-b-specific-native300m-resource-witness-metal-lease","security_flags":0,"uid":501}}}
"""#

    public static let frozenV1: Self = {
        func source(
            _ path: String,
            _ mode: String,
            _ blob: String,
            _ bytes: Int,
            _ sha256: String,
            _ role: String
        ) -> SourceIdentity {
            .init(
                path: path,
                gitMode: mode,
                gitBlob: blob,
                byteCount: bytes,
                sha256: sha256,
                role: role)
        }

        let activeSteps = [
            "Set up job",
            "Check out the exact Prime revision",
            "Validate active metadata and preserved history",
            "Parse the changed Swift contracts without dependencies",
            "Validate isolated Latin capture and observation contracts",
            "Record the authority ceiling",
            "Complete job",
        ]
        let reviewedSteps = [
            "Set up job",
            "Record the hosted Apple toolchain",
            "Check out reviewed main exactly",
            "Fetch the exact private dependency without evaluating Prime",
            "Compile and run the focused contracts without a credential",
            "Run the Prime-owned decoder on live Metal",
            "Complete job",
        ]
        let sources = [
            source(
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                "100755", "401d0177d98e62da16c2d386c70a12baf9bc686a",
                801_935,
                "916399c9713d00af45a1fa87b338bcab6c9573ebc4d1b3695320933bdfbdccf6",
                "active_root_gate"),
            source(
                ".github/scripts/prime-ci-native-decoder-b-specific-native300m-resource-witness.sh",
                "100755", "b621916a678e6a2eb492504e3f63994d2d561491",
                137_210,
                "08dc6e648b81fee6f59b46b7009a74eb2f8e20ac2616c8d81a8a54f90c9597b4",
                "b_resource_witness_launcher"),
            source(
                ".github/workflows/prime-active-root-quarantine.yml",
                "100644", "8b461c5ac489c6f224882822b359c309992ce581",
                100_706,
                "34d7871c162015416b28f35ba5fb0a2450d4a358873bf64958e104993dadf82a",
                "workflow"),
            source(
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "100644", "04085f3be80123e41b1dfed54360f02c24107ab2",
                546,
                "e56e3de248d0546541e7ddb7ef480727b8e7fba1999932147fe3fe05e6a56b23",
                "embedded_provenance"),
            source(
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift",
                "100644", "cf3d743d121f4eaa028e0e392e04587bcd0b93d8",
                225_960,
                "77fbe6b5e9548d84af30c95ba4ca0cfa2d03d5e1884c74d0a9ae297b109eed8b",
                "b_resource_witness_probe"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                "100644", "08b732f88ce3be0cd86905df8b78f2492c7ca557",
                2_778,
                "46fca0c696a46ccc9e22180ca5ec80cffc202a43b68b5f8c9568051e8e71348e",
                "validation_manifest"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MResourceWitness/main.swift",
                "100644", "a8d85ea641b5442475893d97631fc3d1f886b9b9",
                231,
                "d10ebc104e8fa883509e4f42a7185484004ad37bc1f9d69c91cdd0e6c4695f51",
                "b_resource_witness_executable_main"),
            source(
                "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessContractTests.swift",
                "100644", "b78613e392ab20df0d11a2546aadf484e419b75c",
                30_202,
                "fb3abc5d6377867d438b8c48fd9cbeab3549f4570ded7570cf4bc9f585c1d8a7",
                "b_resource_witness_pure_contract_test"),
        ]
        let prActiveJob = JobIdentity(
            id: 94_949_960_837,
            name: "First-party MLX / active-root quarantine",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-15T02:31:28Z",
            completedAt: "2026-08-15T02:34:45Z",
            runnerID: 1_000_001_774,
            runnerName: "GitHub Actions 1000001774",
            runnerGroupName: "GitHub Actions",
            runnerLabel: "macos-15",
            orderedStepNames: activeSteps,
            orderedStepConclusions: Array(repeating: "success", count: 7),
            jobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31859411371/job/94949960837")
        let prReviewedJob = JobIdentity(
            id: 94_950_338_938,
            name: "Reviewed main / focused source contracts",
            status: "completed",
            conclusion: "skipped",
            startedAt: "2026-08-15T02:34:45Z",
            completedAt: "2026-08-15T02:34:45Z",
            runnerID: nil,
            runnerName: nil,
            runnerGroupName: nil,
            runnerLabel: "macos-26",
            orderedStepNames: [],
            orderedStepConclusions: [],
            jobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31859411371/job/94950338938")
        let activeJob = JobIdentity(
            id: 94_950_745_364,
            name: "First-party MLX / active-root quarantine",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-15T02:38:06Z",
            completedAt: "2026-08-15T02:42:16Z",
            runnerID: 1_000_001_775,
            runnerName: "GitHub Actions 1000001775",
            runnerGroupName: "GitHub Actions",
            runnerLabel: "macos-15",
            orderedStepNames: activeSteps,
            orderedStepConclusions: Array(repeating: "success", count: 7),
            jobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31859699200/job/94950745364")
        let reviewedJob = JobIdentity(
            id: 94_951_238_266,
            name: "Reviewed main / focused source contracts",
            status: "completed",
            conclusion: "success",
            startedAt: "2026-08-15T02:42:19Z",
            completedAt: "2026-08-15T03:41:38Z",
            runnerID: 1_000_001_776,
            runnerName: "GitHub Actions 1000001776",
            runnerGroupName: "GitHub Actions",
            runnerLabel: "macos-26",
            orderedStepNames: reviewedSteps,
            orderedStepConclusions: Array(repeating: "success", count: 7),
            jobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31859699200/job/94951238266")

        return Self(
            schemaVersion: 1,
            observationID:
                "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_execution_observation_v1",
            observationKind:
                "append_only_dependency_free_nonexecuting_b_specific_native300m_resource_witness_pass_execution_observation",
            predecessorAuthorityID:
                "prime_native_decoder_b_specific_native300m_resource_witness_authority_v1",
            predecessorAuthorityCanonicalSHA256:
                "15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba",
            repositoryIdentity: .init(
                repository: "Ergentics/ergentics-prime",
                pullRequestNumber: 113,
                ref: "refs/heads/main",
                baseRevision:
                    "b1695b17523068e2b720066d84c422cbe2e67975",
                reviewedHeadRevision:
                    "09c47cba0c9b2c69568bbe7e2a7c25f89fe3cbb3",
                reviewedHeadTree:
                    "2ef7501506f19b9d9734dbc63ccacc62182c3952",
                mergeRevision:
                    "bf98ddb13f6f6128a185b2f553b5cb3f1e30904b",
                mergeTree:
                    "2ef7501506f19b9d9734dbc63ccacc62182c3952",
                orderedParentRevisions: [
                    "b1695b17523068e2b720066d84c422cbe2e67975",
                    "09c47cba0c9b2c69568bbe7e2a7c25f89fe3cbb3",
                ],
                mergedAt: "2026-08-15T02:38:00Z",
                mergeCommitSignatureVerified: true,
                mergeCommitSignatureReason: "valid",
                mergeCommitSignatureVerifiedAt: "2026-08-15T02:38:00Z",
                historyPreservingTwoParentMergeObserved: true,
                mergeTreeEqualsReviewedHeadTree: true,
                exactMainRefMatchedAtTerminalAudit: true,
                changedPathCount: 8,
                manifestOrLockChangedPathCount: 1),
            observedSourceBindings: sources,
            pullRequestLane: .init(
                workflowID: 329_017_041,
                workflowName: "Prime active-root quarantine",
                workflowPath:
                    ".github/workflows/prime-active-root-quarantine.yml",
                runID: 31_859_411_371,
                runNumber: 122,
                runAttempt: 1,
                checkSuiteID: 86_430_890_995,
                event: "pull_request",
                headBranch:
                    "agent/stage6b-native300-resource-witness-mechanics",
                headRevision:
                    "09c47cba0c9b2c69568bbe7e2a7c25f89fe3cbb3",
                headTree:
                    "2ef7501506f19b9d9734dbc63ccacc62182c3952",
                orderedParentRevisions: [
                    "b1695b17523068e2b720066d84c422cbe2e67975",
                ],
                createdAt: "2026-08-15T02:31:25Z",
                startedAt: "2026-08-15T02:31:25Z",
                terminalUpdatedAt: "2026-08-15T02:34:46Z",
                status: "completed",
                conclusion: "success",
                exactHeadPullRequestRunCount: 1,
                previousAttemptURLWasNull: true,
                retryCount: 0,
                rerunCount: 0,
                artifactCount: 0,
                activeRootJob: prActiveJob,
                reviewedMainJob: prReviewedJob,
                launcherInvocationCount: 0,
                directExecutableProbeCount: 0,
                witnessExecutionCount: 0,
                metalExecutionCount: 0,
                native300MMechanicsExecutionCount: 0,
                relevantReceiptCount: 0,
                runURL:
                    "https://github.com/Ergentics/ergentics-prime/actions/runs/31859411371"),
            runIdentity: .init(
                workflowID: 329_017_041,
                workflowName: "Prime active-root quarantine",
                workflowPath:
                    ".github/workflows/prime-active-root-quarantine.yml",
                runID: 31_859_699_200,
                runNumber: 123,
                runAttempt: 1,
                checkSuiteID: 86_431_552_971,
                event: "push",
                headBranch: "main",
                headRevision:
                    "bf98ddb13f6f6128a185b2f553b5cb3f1e30904b",
                actor: "psyop-archivist",
                triggeringActor: "psyop-archivist",
                createdAt: "2026-08-15T02:38:02Z",
                startedAt: "2026-08-15T02:38:02Z",
                terminalUpdatedAt: "2026-08-15T03:41:39Z",
                status: "completed",
                conclusion: "success",
                exactHeadPushRunCount: 1,
                previousAttemptURLWasNull: true,
                retryCount: 0,
                rerunCount: 0,
                rerunObserved: false,
                rerunAuthorized: false,
                artifactCount: 0,
                runURL:
                    "https://github.com/Ergentics/ergentics-prime/actions/runs/31859699200"),
            activeRootJob: activeJob,
            reviewedMainJob: reviewedJob,
            activeRootRawLog: .init(
                codeUnitCount: 281_375,
                byteCount: 281_393,
                lfByteCount: 1_833,
                newlineDelimitedComponentCountIncludingTerminalEmpty: 1_834,
                utf8BOMHex: "efbbbf",
                startsWithUTF8BOM: true,
                usesLFOnly: true,
                endsWithLF: true,
                sha256:
                    "0a68ea617ea5c574f8ee430fd319ea958ca52c8dfdfd359225afdf29ed059ee3",
                publicReceiptOccurrenceCount: 0,
                internalCandidatePrefixOccurrenceCount: 0,
                internalTerminalPrefixOccurrenceCount: 0,
                rawGitHubLogArchiveBytesBound: false,
                retainedInRepository: false),
            reviewedMainRawLog: .init(
                codeUnitCount: 10_372_826,
                byteCount: 10_372_900,
                lfByteCount: 79_483,
                newlineDelimitedComponentCountIncludingTerminalEmpty: 79_484,
                utf8BOMHex: "efbbbf",
                startsWithUTF8BOM: true,
                usesLFOnly: true,
                endsWithLF: true,
                sha256:
                    "39559916cb1f930c0c2e07ed1cd669ebfad26f30349d3dd05bbb7834d339f71b",
                publicReceiptOccurrenceCount: 1,
                internalCandidatePrefixOccurrenceCount: 0,
                internalTerminalPrefixOccurrenceCount: 0,
                rawGitHubLogArchiveBytesBound: false,
                retainedInRepository: false),
            testTopology: .init(
                rootTestCount: 60,
                isolatedGroupTestCounts: [1, 1, 2, 2],
                isolatedTestCount: 6,
                focusedBContractTestCount: 1,
                focusedStepXCTestCount: 67,
                metalTestCount: 44,
                maintainedRuntimeTestCount: 1,
                tokenizerTestCount: 1,
                launcherLocalBContractTestCount: 1,
                liveStepXCTestCount: 47,
                totalXCTestCount: 114,
                totalFailureCount: 0,
                totalSkipCount: 0,
                bContractStartCount: 2,
                bContractPassCount: 2,
                bContractFailureCount: 0,
                bContractSkipCount: 0,
                launcherInvocationCount: 1,
                buildInvocationCount: 1,
                directXCTestInvocationCount: 1,
                directExecutableProbeCount: 1,
                privateCandidateCount: 1,
                privateTerminalCount: 1,
                publicReceiptCount: 1,
                aggregateInvocationCount: 3,
                originalStage5LauncherInvocationCount: 0,
                replacementStage5LauncherInvocationCount: 0,
                historicalStage6LauncherInvocationCount: 0,
                originalStage5ReceiptCount: 0,
                replacementStage5ReceiptCount: 0,
                historicalStage6ReceiptCount: 0,
                observedLiveOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                    "b_specific_native300m_resource_witness",
                ],
                observedBInternalOrder: [
                    "b_resource_witness_pure_contract_xctest",
                    "b_resource_witness_supervisor_resource_worker_and_release_verifier",
                ]),
            retirementBoundary: .init(
                retirementRequired: true,
                retirementObserved: false,
                successfulAttemptConsumed: true,
                exactMainClosureRequired: true,
                exactChangedPaths: [
                    .init(
                        path:
                            ".github/scripts/prime-ci-active-root-quarantine.sh",
                        gitMode: "100755",
                        role: "retire_b_resource_witness_live_invocation"),
                    .init(
                        path:
                            ".github/workflows/prime-active-root-quarantine.yml",
                        gitMode: "100644",
                        role: "restore_reviewed_main_without_b_witness_step"),
                    .init(
                        path:
                            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                        gitMode: "100644",
                        role: "retirement_embedded_provenance"),
                    .init(
                        path:
                            "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservation.swift",
                        gitMode: "100644",
                        role: "b_resource_witness_pass_observation"),
                    .init(
                        path:
                            "Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationTests.swift",
                        gitMode: "100644",
                        role: "b_resource_witness_pass_observation_test"),
                ],
                expectedRootTestCount: 61,
                expectedIsolatedGroupTestCounts: [1, 1, 2, 2],
                expectedIsolatedTestCount: 6,
                expectedFocusedWholeTestCount: 67,
                expectedMetalTestCount: 44,
                expectedMaintainedRuntimeTestCount: 1,
                expectedTokenizerTestCount: 1,
                expectedLiveStepXCTestCount: 46,
                expectedTotalXCTestCount: 113,
                expectedBFocusedContractTestCount: 0,
                expectedBLauncherLocalContractTestCount: 0,
                expectedBDirectExecutableProbeCount: 0,
                expectedBLauncherInvocationCount: 0,
                expectedBInternalCandidatePrefixCount: 0,
                expectedBInternalTerminalPrefixCount: 0,
                expectedBPublicReceiptCount: 0,
                expectedOriginalStage5LauncherInvocationCount: 0,
                expectedReplacementStage5LauncherInvocationCount: 0,
                expectedHistoricalStage6LauncherInvocationCount: 0,
                expectedOriginalStage5ReceiptCount: 0,
                expectedReplacementStage5ReceiptCount: 0,
                expectedHistoricalStage6ReceiptCount: 0,
                expectedMaintainedRuntimeReceiptCount: 1,
                expectedTokenizerReceiptCount: 1,
                expectedLiveOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                mechanicsSourcesPreservedForAudit: true),
            receiptIdentity: .init(
                prefix:
                    "PRIME_NATIVE_DECODER_B_SPECIFIC_NATIVE300M_RESOURCE_WITNESS_RECEIPT_V1=",
                prefixByteCount: 71,
                canonicalJSON: frozenReceiptCanonicalJSON,
                canonicalJSONByteCount: 14_493,
                canonicalJSONSHA256:
                    "600df63cec92063a3e6099075397b674ae238589c5232fb3cfa16cabc6212d54",
                storageByteCountIncludingLF: 14_494,
                storageSHA256IncludingLF:
                    "4b8bb792fc3af5fb950b77a8c592bdca76be410947246be7edfaa1fe27757a44",
                prefixedCanonicalByteCount: 14_564,
                prefixedCanonicalSHA256:
                    "92e16737351eaa261409f3e5edb282a9bed633dd5377041cd2bbfae777d59dc9",
                prefixedCanonicalLFByteCount: 14_565,
                prefixedCanonicalLFSHA256:
                    "408a3d343ae13dcfbdd85fd187a45c80555463edf9de4ed6f388a308ee2dd5db",
                emittedAt: "2026-08-15T03:41:26.6840080Z",
                fullTimestampedLineByteCount: 14_593,
                fullTimestampedLineSHA256:
                    "c29fa7ec8eb9ad0f70f02fe811121972e72132f31cd11811f1fe0a11e581c635",
                logLineNumber: 79_482,
                exactOccurrenceCount: 1,
                topLevelKeyCount: 39,
                candidateKeyCount: 8,
                terminalKeyCount: 26,
                receiptID:
                    "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_receipt_v1",
                schemaVersion: 1,
                status: "PASS",
                classification: "pass",
                candidateCanonicalByteCount: 8_397,
                candidateSHA256:
                    "aad81c55024652ef594e65dfbfbbba74f34176c6cf1792b45676cbbdaacfbba8",
                terminalCanonicalByteCount: 2_425,
                terminalSHA256:
                    "ec960f822eab44b516273f19205246de5cb4bd544da7312b1396f60ceb48c2a4"),
            resourcePassBoundary: .init(
                candidatePresent: true,
                candidateScientificStatus: "PASS",
                candidateClassification: "pass",
                resourceProbeExecuted: true,
                resourceEnvelopeEstablished: true,
                bSpecificNative300MResourceWitnessEstablished: true,
                bSpecificNative300MResourceClearanceEstablished: true,
                runnerMemoryCapacityEstablished: true,
                updateOccurred: true,
                directPackageBTrainingLogitsAPICallCount: 1,
                denseEmbeddingConstructionCount: 1,
                maintainedGatherTrainingLogitsCount: 0,
                inputEmbeddingForwardPairDiagnosticInvocationCount: 0,
                tinyTrainingSelectorInvocationCount: 0,
                checkedEvaluationBarrierCount: 6,
                gpuSynchronizationBarrierCount: 6,
                lossFloat32Bits: 1_088_043_293,
                rawGradientNormFloat32Bits: 1_101_890_567,
                gradientClipScaleFloat32Bits: 1_027_397_872,
                parameterFingerprintBefore:
                    "64263c521c6534561fb66a0e87e10a1229bdc9fe859f879c3a9f91c11abfa04e",
                parameterFingerprintAfter:
                    "4e0f9afe1e7217d11379f02c1e44ea498c3cbda5add228c247166e6775d8f7d2",
                parameterFingerprintSamplePlanSHA256:
                    "a36fdb60e23052b03b8e257224e1d47fd9731294f34a268a5fbff2b21ac49f87",
                parameterFingerprintSampleCount: 654,
                phaseNames: [
                    "preflight",
                    "post_model_materialization",
                    "post_b_forward_backward",
                    "post_norm_clip",
                    "post_adam_update_full_evaluation",
                    "post_lexical_deallocation_and_clear_cache",
                ],
                finalElapsedNanoseconds: 29_530_094_292,
                peakMLXBytes: 4_790_771_492,
                mlxMemoryHeadroomBytes: 220_029_148,
                physicalMemoryCapacityBytes: 7_516_192_768,
                configuredMemoryLimitBytes: 5_010_800_640,
                runtimeMetallibByteCount: 6_292_716,
                runtimeMetallibSHA256:
                    "934ed1214e2fb2de9c79efa072357ec9df8be0b87ca0e9395340f93c98ee829a"),
            integrityPassBoundary: .init(
                terminalStatus: "PASS",
                classification: "pass",
                leaseAcquired: true,
                releaseVerifierExitZero: true,
                supervisorIntegrityGuardCount: 13,
                firstFailedGuardID: nil,
                errnoAvailability: "not_applicable",
                errno: nil,
                actualMetadataAvailability: "not_applicable",
                actualMetadataPresent: false,
                actualMetadataUnavailableReason: nil,
                supervisorPostCandidateInventory: ["device-0.lock"],
                verifierInventory: ["device-0.lock"],
                leaseTupleStableThroughVerifier: true,
                leaseDeviceID: 16_777_234,
                leaseInode: 2_990_754,
                leaseUID: 501,
                leaseGID: 20,
                leaseMode: "0600",
                leaseObservedNlink: 1,
                leaseByteCount: 0,
                leaseFileType: "regular_file",
                parentStableFieldsMatchPreflightAndVerifier: true,
                parentPhysicalPath:
                    "/Users/runner/work/_temp/prime-native-decoder-b-specific-native300m-resource-witness-metal-lease",
                parentDeviceID: 16_777_234,
                parentInode: 2_990_745,
                parentUID: 501,
                parentGID: 20,
                parentMode: "0700",
                parentPreflightObservedNlink: 2,
                parentPostCandidateObservedNlink: 3,
                parentVerifierObservedNlink: 3),
            workflowClosureBoundary: .init(
                workflowConclusion: "success",
                activeRootJobConclusion: "success",
                reviewedMainJobConclusion: "success",
                launcherExitCode: 0,
                launcherExitedZero: true,
                launcherClosureEstablished: true,
                publicReceiptWasLastLauncherOutput: true,
                onlyPostReceiptRunnerLine:
                    "2026-08-15T03:41:26.8526870Z Cleaning up orphan processes",
                postReceiptRunnerLineNumber: 79_483,
                receiptDoesNotClaimMechanicsSuccess: true,
                receiptDoesNotClaimWorkflowSuccess: true,
                artifactUploadInvoked: false,
                retainedArtifactObserved: false,
                retryObserved: false,
                rerunObserved: false,
                outerJobClosedAfterReceipt: true),
            authorityCeiling: .init(
                oneShotConsumed: true,
                oneShotExhausted: true,
                stage5MechanicsSuccessEstablished: true,
                stage5ResultEstablished: true,
                stage5AssayClearanceEstablished: true,
                repeatedSameDeviceBPathDeterminismEstablished: true,
                exactSameDeviceBPathGradientBytesEstablished: true,
                bSpecificNative300MResourceWitnessEstablished: true,
                bSpecificNative300MResourceClearanceEstablished: true,
                historicalStage6ResourceClearanceRemainsEstablished: true,
                additionalExecutionAuthorized: false,
                replacementExecutionAuthorized: false,
                additionalNative300MAllocationAuthorized: false,
                additionalNative300MExecutionAuthorized: false,
                additionalBResourceWitnessExecutionAuthorized: false,
                retryAuthorized: false,
                rerunAuthorized: false,
                artifactUploadAuthorized: false,
                retainedArtifactAuthorized: false,
                ordinaryJobFitEstablished: false,
                historicalStage6ResourceClearanceAppliesToBPath: false,
                broadNative300MTrainingAuthorized: false,
                generalTrainingResumeEstablished: false,
                native300MTrajectoryTrainingResumeEstablished: false,
                durableCheckpointIOAuthorized: false,
                checkpointAdmissionGranted: false,
                candidateAdmissionGranted: false,
                modelQualityEstablished: false,
                downstreamTrialAuthorized: false,
                canaryAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false,
                stage7RequiresSeparateAuthorityAfterWitness: true,
                stage7AuthorityEstablished: false,
                stage7Authorized: false),
            status:
                "PASS_exact_main_b_specific_native300m_resource_witness_and_integrity_and_outer_workflow_closed_one_shot_consumed_no_rerun_no_artifact_stage7_false")
    }()

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationError
                    .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let drift =
            PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationError
                .contractDrift
        let authority =
            PrimeNativeDecoderBSpecificNative300MResourceWitnessAuthorityV1
                .frozenV1
        do {
            try authority.validateExactV1()
        } catch {
            throw drift("predecessor authority validation")
        }

        let prZeroCounts = [
            pullRequestLane.launcherInvocationCount,
            pullRequestLane.directExecutableProbeCount,
            pullRequestLane.witnessExecutionCount,
            pullRequestLane.metalExecutionCount,
            pullRequestLane.native300MMechanicsExecutionCount,
            pullRequestLane.relevantReceiptCount,
            pullRequestLane.retryCount,
            pullRequestLane.rerunCount,
            pullRequestLane.artifactCount,
        ]
        let historicalZeroCounts = [
            testTopology.originalStage5LauncherInvocationCount,
            testTopology.replacementStage5LauncherInvocationCount,
            testTopology.historicalStage6LauncherInvocationCount,
            testTopology.originalStage5ReceiptCount,
            testTopology.replacementStage5ReceiptCount,
            testTopology.historicalStage6ReceiptCount,
        ]
        let retirementZeroCounts = [
            retirementBoundary.expectedBFocusedContractTestCount,
            retirementBoundary.expectedBLauncherLocalContractTestCount,
            retirementBoundary.expectedBDirectExecutableProbeCount,
            retirementBoundary.expectedBLauncherInvocationCount,
            retirementBoundary.expectedBInternalCandidatePrefixCount,
            retirementBoundary.expectedBInternalTerminalPrefixCount,
            retirementBoundary.expectedBPublicReceiptCount,
            retirementBoundary.expectedOriginalStage5LauncherInvocationCount,
            retirementBoundary.expectedReplacementStage5LauncherInvocationCount,
            retirementBoundary.expectedHistoricalStage6LauncherInvocationCount,
            retirementBoundary.expectedOriginalStage5ReceiptCount,
            retirementBoundary.expectedReplacementStage5ReceiptCount,
            retirementBoundary.expectedHistoricalStage6ReceiptCount,
        ]
        let falseCeilings = [
            authorityCeiling.additionalExecutionAuthorized,
            authorityCeiling.replacementExecutionAuthorized,
            authorityCeiling.additionalNative300MAllocationAuthorized,
            authorityCeiling.additionalNative300MExecutionAuthorized,
            authorityCeiling.additionalBResourceWitnessExecutionAuthorized,
            authorityCeiling.retryAuthorized,
            authorityCeiling.rerunAuthorized,
            authorityCeiling.artifactUploadAuthorized,
            authorityCeiling.retainedArtifactAuthorized,
            authorityCeiling.ordinaryJobFitEstablished,
            authorityCeiling.historicalStage6ResourceClearanceAppliesToBPath,
            authorityCeiling.broadNative300MTrainingAuthorized,
            authorityCeiling.generalTrainingResumeEstablished,
            authorityCeiling.native300MTrajectoryTrainingResumeEstablished,
            authorityCeiling.durableCheckpointIOAuthorized,
            authorityCeiling.checkpointAdmissionGranted,
            authorityCeiling.candidateAdmissionGranted,
            authorityCeiling.modelQualityEstablished,
            authorityCeiling.downstreamTrialAuthorized,
            authorityCeiling.canaryAuthorized,
            authorityCeiling.quantizationAuthorized,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
            authorityCeiling.stage7AuthorityEstablished,
            authorityCeiling.stage7Authorized,
        ]
        let establishedClaims = [
            authorityCeiling.stage5MechanicsSuccessEstablished,
            authorityCeiling.stage5ResultEstablished,
            authorityCeiling.stage5AssayClearanceEstablished,
            authorityCeiling.repeatedSameDeviceBPathDeterminismEstablished,
            authorityCeiling.exactSameDeviceBPathGradientBytesEstablished,
            authorityCeiling.bSpecificNative300MResourceWitnessEstablished,
            authorityCeiling.bSpecificNative300MResourceClearanceEstablished,
            authorityCeiling
                .historicalStage6ResourceClearanceRemainsEstablished,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              predecessorAuthorityID == authority.authorityID,
              predecessorAuthorityCanonicalSHA256
                == Self.expectedAuthoritySHA256,
              repositoryIdentity.orderedParentRevisions
                == [
                    repositoryIdentity.baseRevision,
                    repositoryIdentity.reviewedHeadRevision,
                ],
              repositoryIdentity.reviewedHeadTree
                == repositoryIdentity.mergeTree,
              repositoryIdentity.mergeRevision == runIdentity.headRevision,
              repositoryIdentity.changedPathCount
                == observedSourceBindings.count,
              repositoryIdentity.changedPathCount == 8,
              repositoryIdentity.manifestOrLockChangedPathCount == 1,
              repositoryIdentity.mergeCommitSignatureVerified,
              repositoryIdentity.mergeCommitSignatureReason == "valid",
              repositoryIdentity.historyPreservingTwoParentMergeObserved,
              repositoryIdentity.mergeTreeEqualsReviewedHeadTree,
              repositoryIdentity.exactMainRefMatchedAtTerminalAudit,
              Set(observedSourceBindings.map(\.path)).count == 8,
              observedSourceBindings.allSatisfy(Self.validSource),
              pullRequestLane.headRevision
                == repositoryIdentity.reviewedHeadRevision,
              pullRequestLane.headTree == repositoryIdentity.reviewedHeadTree,
              pullRequestLane.orderedParentRevisions
                == [repositoryIdentity.baseRevision],
              pullRequestLane.runAttempt == 1,
              pullRequestLane.exactHeadPullRequestRunCount == 1,
              pullRequestLane.previousAttemptURLWasNull,
              pullRequestLane.status == "completed",
              pullRequestLane.conclusion == "success",
              pullRequestLane.activeRootJob.conclusion == "success",
              pullRequestLane.activeRootJob.orderedStepNames.count == 7,
              pullRequestLane.activeRootJob.orderedStepConclusions
                == Array(repeating: "success", count: 7),
              pullRequestLane.reviewedMainJob.conclusion == "skipped",
              pullRequestLane.reviewedMainJob.orderedStepNames.isEmpty,
              pullRequestLane.reviewedMainJob.orderedStepConclusions.isEmpty,
              prZeroCounts.allSatisfy({ $0 == 0 }),
              runIdentity.runAttempt == 1,
              runIdentity.exactHeadPushRunCount == 1,
              runIdentity.previousAttemptURLWasNull,
              runIdentity.retryCount == 0,
              runIdentity.rerunCount == 0,
              !runIdentity.rerunObserved,
              !runIdentity.rerunAuthorized,
              runIdentity.artifactCount == 0,
              runIdentity.status == "completed",
              runIdentity.conclusion == "success",
              activeRootJob.conclusion == "success",
              reviewedMainJob.conclusion == "success",
              activeRootJob.orderedStepNames.count == 7,
              reviewedMainJob.orderedStepNames.count == 7,
              activeRootJob.orderedStepConclusions
                == Array(repeating: "success", count: 7),
              reviewedMainJob.orderedStepConclusions
                == Array(repeating: "success", count: 7),
              Self.validRawLog(activeRootRawLog),
              Self.validRawLog(reviewedMainRawLog),
              activeRootRawLog.publicReceiptOccurrenceCount == 0,
              reviewedMainRawLog.publicReceiptOccurrenceCount == 1,
              activeRootRawLog.internalCandidatePrefixOccurrenceCount == 0,
              reviewedMainRawLog.internalCandidatePrefixOccurrenceCount == 0,
              activeRootRawLog.internalTerminalPrefixOccurrenceCount == 0,
              reviewedMainRawLog.internalTerminalPrefixOccurrenceCount == 0,
              testTopology.isolatedGroupTestCounts == [1, 1, 2, 2],
              testTopology.isolatedTestCount
                == testTopology.isolatedGroupTestCounts.reduce(0, +),
              testTopology.focusedStepXCTestCount
                == testTopology.rootTestCount
                    + testTopology.isolatedTestCount
                    + testTopology.focusedBContractTestCount,
              testTopology.liveStepXCTestCount
                == testTopology.metalTestCount
                    + testTopology.maintainedRuntimeTestCount
                    + testTopology.tokenizerTestCount
                    + testTopology.launcherLocalBContractTestCount,
              testTopology.totalXCTestCount
                == testTopology.focusedStepXCTestCount
                    + testTopology.liveStepXCTestCount,
              testTopology.totalFailureCount == 0,
              testTopology.totalSkipCount == 0,
              testTopology.bContractStartCount == 2,
              testTopology.bContractPassCount == 2,
              testTopology.bContractFailureCount == 0,
              testTopology.bContractSkipCount == 0,
              testTopology.launcherInvocationCount == 1,
              testTopology.buildInvocationCount == 1,
              testTopology.directXCTestInvocationCount == 1,
              testTopology.directExecutableProbeCount == 1,
              testTopology.privateCandidateCount == 1,
              testTopology.privateTerminalCount == 1,
              testTopology.publicReceiptCount == 1,
              testTopology.aggregateInvocationCount == 3,
              historicalZeroCounts.allSatisfy({ $0 == 0 }),
              retirementBoundary.retirementRequired,
              !retirementBoundary.retirementObserved,
              retirementBoundary.successfulAttemptConsumed,
              retirementBoundary.exactMainClosureRequired,
              retirementBoundary.exactChangedPaths.map(\.path)
                == [
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                    ".github/workflows/prime-active-root-quarantine.yml",
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservation.swift",
                    "Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MResourceWitnessExecutionObservationTests.swift",
                ],
              retirementBoundary.exactChangedPaths.map(\.gitMode)
                == ["100755", "100644", "100644", "100644", "100644"],
              Set(retirementBoundary.exactChangedPaths.map(\.path)).count == 5,
              retirementBoundary.expectedRootTestCount == 61,
              retirementBoundary.expectedIsolatedGroupTestCounts
                == [1, 1, 2, 2],
              retirementBoundary.expectedIsolatedTestCount
                == retirementBoundary.expectedIsolatedGroupTestCounts
                    .reduce(0, +),
              retirementBoundary.expectedFocusedWholeTestCount
                == retirementBoundary.expectedRootTestCount
                    + retirementBoundary.expectedIsolatedTestCount
                    + retirementBoundary.expectedBFocusedContractTestCount,
              retirementBoundary.expectedFocusedWholeTestCount == 67,
              retirementBoundary.expectedLiveStepXCTestCount
                == retirementBoundary.expectedMetalTestCount
                    + retirementBoundary.expectedMaintainedRuntimeTestCount
                    + retirementBoundary.expectedTokenizerTestCount
                    + retirementBoundary
                        .expectedBLauncherLocalContractTestCount,
              retirementBoundary.expectedLiveStepXCTestCount == 46,
              retirementBoundary.expectedTotalXCTestCount
                == retirementBoundary.expectedFocusedWholeTestCount
                    + retirementBoundary.expectedLiveStepXCTestCount,
              retirementBoundary.expectedTotalXCTestCount == 113,
              retirementZeroCounts.allSatisfy({ $0 == 0 }),
              retirementBoundary.expectedMaintainedRuntimeReceiptCount == 1,
              retirementBoundary.expectedTokenizerReceiptCount == 1,
              retirementBoundary.expectedLiveOrder
                == ["metal", "maintained_runtime", "tokenizer"],
              retirementBoundary.mechanicsSourcesPreservedForAudit,
              resourcePassBoundary.candidatePresent,
              resourcePassBoundary.candidateScientificStatus == "PASS",
              resourcePassBoundary.candidateClassification == "pass",
              resourcePassBoundary.resourceProbeExecuted,
              resourcePassBoundary.resourceEnvelopeEstablished,
              resourcePassBoundary.bSpecificNative300MResourceWitnessEstablished,
              resourcePassBoundary
                .bSpecificNative300MResourceClearanceEstablished,
              resourcePassBoundary.runnerMemoryCapacityEstablished,
              resourcePassBoundary.updateOccurred,
              resourcePassBoundary.parameterFingerprintBefore
                != resourcePassBoundary.parameterFingerprintAfter,
              integrityPassBoundary.terminalStatus == "PASS",
              integrityPassBoundary.classification == "pass",
              integrityPassBoundary.leaseAcquired,
              integrityPassBoundary.releaseVerifierExitZero,
              integrityPassBoundary.supervisorIntegrityGuardCount == 13,
              integrityPassBoundary.firstFailedGuardID == nil,
              integrityPassBoundary.errno == nil,
              !integrityPassBoundary.actualMetadataPresent,
              integrityPassBoundary.actualMetadataUnavailableReason == nil,
              integrityPassBoundary.leaseTupleStableThroughVerifier,
              integrityPassBoundary
                .parentStableFieldsMatchPreflightAndVerifier,
              workflowClosureBoundary.workflowConclusion == "success",
              workflowClosureBoundary.activeRootJobConclusion
                == activeRootJob.conclusion,
              workflowClosureBoundary.reviewedMainJobConclusion
                == reviewedMainJob.conclusion,
              workflowClosureBoundary.launcherExitCode == 0,
              workflowClosureBoundary.launcherExitedZero,
              workflowClosureBoundary.launcherClosureEstablished,
              workflowClosureBoundary.publicReceiptWasLastLauncherOutput,
              workflowClosureBoundary.receiptDoesNotClaimMechanicsSuccess,
              workflowClosureBoundary.receiptDoesNotClaimWorkflowSuccess,
              !workflowClosureBoundary.artifactUploadInvoked,
              !workflowClosureBoundary.retainedArtifactObserved,
              !workflowClosureBoundary.retryObserved,
              !workflowClosureBoundary.rerunObserved,
              workflowClosureBoundary.outerJobClosedAfterReceipt,
              authorityCeiling.oneShotConsumed,
              authorityCeiling.oneShotExhausted,
              establishedClaims.allSatisfy({ $0 }),
              authorityCeiling.stage7RequiresSeparateAuthorityAfterWitness,
              falseCeilings.allSatisfy({ !$0 }),
              try receiptCrossBindingsHold()
        else {
            throw drift("frozen execution observation")
        }
    }

    private static let expectedAuthoritySHA256 =
        "15e00a65594a69e380e93362dc22103ccf3ae42de2676ef9e459b4603af887ba"

    private func receiptCrossBindingsHold() throws -> Bool {
        let receipt = receiptIdentity
        guard let receiptData = receipt.canonicalJSON.data(using: .utf8),
              let prefixData = receipt.prefix.data(using: .utf8)
        else {
            return false
        }
        let storageData = receiptData + Data([0x0A])
        let prefixedData = prefixData + receiptData
        let prefixedLFData = prefixedData + Data([0x0A])
        let timestampedData = Data(
            (receipt.emittedAt + " " + receipt.prefix + receipt.canonicalJSON)
                .utf8
        )
        guard let root = try JSONSerialization.jsonObject(with: receiptData)
                as? [String: Any],
              let normalized = try? JSONSerialization.data(
                withJSONObject: root,
                options: [.sortedKeys, .withoutEscapingSlashes]),
              normalized == receiptData,
              receipt.canonicalJSON == Self.frozenReceiptCanonicalJSON,
              receipt.prefixByteCount == prefixData.count,
              receipt.canonicalJSONByteCount == receiptData.count,
              receipt.canonicalJSONSHA256
                == PrimeSHA256.hexDigest(of: receiptData),
              receipt.storageByteCountIncludingLF == storageData.count,
              receipt.storageSHA256IncludingLF
                == PrimeSHA256.hexDigest(of: storageData),
              receipt.prefixedCanonicalByteCount == prefixedData.count,
              receipt.prefixedCanonicalSHA256
                == PrimeSHA256.hexDigest(of: prefixedData),
              receipt.prefixedCanonicalLFByteCount == prefixedLFData.count,
              receipt.prefixedCanonicalLFSHA256
                == PrimeSHA256.hexDigest(of: prefixedLFData),
              receipt.fullTimestampedLineByteCount == timestampedData.count,
              receipt.fullTimestampedLineSHA256
                == PrimeSHA256.hexDigest(of: timestampedData),
              receipt.exactOccurrenceCount == 1,
              root.count == receipt.topLevelKeyCount,
              !root.keys.contains("mechanics_success"),
              !root.keys.contains("workflow_success"),
              string(root["schema_id"]) == receipt.receiptID,
              int(root["schema_version"]) == receipt.schemaVersion,
              string(root["status"]) == receipt.status,
              string(root["classification"]) == receipt.classification,
              string(root["authority_id"]) == predecessorAuthorityID,
              string(root["authority_canonical_sha256"])
                == predecessorAuthorityCanonicalSHA256,
              string(root["mechanics_revision"])
                == repositoryIdentity.mergeRevision,
              string(root["mechanics_tree"]) == repositoryIdentity.mergeTree,
              int(root["mechanics_run_id"]) == runIdentity.runID,
              int(root["mechanics_run_number"]) == runIdentity.runNumber,
              int(root["mechanics_run_attempt"]) == runIdentity.runAttempt,
              bool(root["candidate_present"])
                == resourcePassBoundary.candidatePresent,
              string(root["candidate_scientific_status"])
                == resourcePassBoundary.candidateScientificStatus,
              bool(root["b_specific_native300m_resource_witness"])
                == resourcePassBoundary
                    .bSpecificNative300MResourceWitnessEstablished,
              bool(root["b_specific_native300m_resource_clearance"])
                == resourcePassBoundary
                    .bSpecificNative300MResourceClearanceEstablished,
              bool(root["historical_stage6_resource_clearance_applies_to_b_path"])
                == authorityCeiling
                    .historicalStage6ResourceClearanceAppliesToBPath,
              bool(root["one_shot_consumed"])
                == authorityCeiling.oneShotConsumed,
              bool(root["ordinary_job_fit_established"])
                == authorityCeiling.ordinaryJobFitEstablished,
              bool(root["retry_authorized"])
                == authorityCeiling.retryAuthorized,
              bool(root["rerun_authorized"])
                == authorityCeiling.rerunAuthorized,
              bool(root["artifact_upload_authorized"])
                == authorityCeiling.artifactUploadAuthorized,
              bool(root["retained_artifact_authorized"])
                == authorityCeiling.retainedArtifactAuthorized,
              bool(root["stage7_authorized"])
                == authorityCeiling.stage7Authorized,
              bool(root["lease_acquired"])
                == integrityPassBoundary.leaseAcquired,
              bool(root["release_verifier_exit_zero"])
                == integrityPassBoundary.releaseVerifierExitZero,
              int(root["supervisor_integrity_guard_count"])
                == integrityPassBoundary.supervisorIntegrityGuardCount,
              root["first_failed_guard_id"] is NSNull,
              root["errno"] is NSNull,
              root["actual_metadata"] is NSNull,
              string(root["errno_availability"])
                == integrityPassBoundary.errnoAvailability,
              string(root["actual_metadata_availability"])
                == integrityPassBoundary.actualMetadataAvailability,
              root["actual_metadata_unavailable_reason"] is NSNull,
              let rawSources = root["exact_changed_source_identities"]
                as? [[String: Any]],
              rawSources.count == observedSourceBindings.count,
              zip(rawSources, observedSourceBindings).allSatisfy({
                  raw, typed in
                  string(raw["path"]) == typed.path
                      && string(raw["mode"]) == typed.gitMode
                      && string(raw["git_blob"]) == typed.gitBlob
                      && int(raw["byte_count"]) == typed.byteCount
                      && string(raw["sha256"]) == typed.sha256
              }),
              let candidate = dictionary(root["validated_private_candidate"]),
              let terminal = dictionary(root["validated_private_terminal"]),
              candidate.count == receipt.candidateKeyCount,
              terminal.count == receipt.terminalKeyCount,
              let candidateData = try? JSONSerialization.data(
                withJSONObject: candidate,
                options: [.sortedKeys, .withoutEscapingSlashes]),
              let terminalData = try? JSONSerialization.data(
                withJSONObject: terminal,
                options: [.sortedKeys, .withoutEscapingSlashes]),
              candidateData.count == receipt.candidateCanonicalByteCount,
              terminalData.count == receipt.terminalCanonicalByteCount,
              PrimeSHA256.hexDigest(of: candidateData)
                == receipt.candidateSHA256,
              PrimeSHA256.hexDigest(of: terminalData)
                == receipt.terminalSHA256,
              int(root["candidate_canonical_byte_count"])
                == receipt.candidateCanonicalByteCount,
              string(root["candidate_sha256"]) == receipt.candidateSHA256,
              int(root["terminal_canonical_byte_count"])
                == receipt.terminalCanonicalByteCount,
              string(root["terminal_sha256"]) == receipt.terminalSHA256,
              try candidateCrossBindingsHold(candidate),
              terminalCrossBindingsHold(terminal)
        else {
            return false
        }
        return true
    }

    private func candidateCrossBindingsHold(
        _ candidate: [String: Any]
    ) throws -> Bool {
        guard string(candidate["schema_id"])
                == "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_candidate_v1",
              int(candidate["schema_version"]) == 1,
              string(candidate["authority_id"]) == predecessorAuthorityID,
              string(candidate["authority_canonical_sha256"])
                == predecessorAuthorityCanonicalSHA256,
              string(candidate["scientific_status"])
                == resourcePassBoundary.candidateScientificStatus,
              string(candidate["classification"])
                == resourcePassBoundary.candidateClassification,
              bool(candidate["one_shot_consumed"])
                == authorityCeiling.oneShotConsumed,
              let payload = dictionary(candidate["payload"]),
              let environment = dictionary(payload["environment"]),
              let limits = dictionary(payload["limits"]),
              let outcome = dictionary(payload["outcome"]),
              let counts = dictionary(outcome["operation_counts"]),
              let phases = payload["phase_metrics"] as? [[String: Any]],
              string(outcome["status"])
                == resourcePassBoundary.candidateScientificStatus,
              string(outcome["classification"])
                == resourcePassBoundary.candidateClassification,
              bool(outcome["resource_probe_executed"])
                == resourcePassBoundary.resourceProbeExecuted,
              bool(outcome["resource_envelope_established"])
                == resourcePassBoundary.resourceEnvelopeEstablished,
              bool(outcome["resource_clearance_established"])
                == resourcePassBoundary
                    .bSpecificNative300MResourceClearanceEstablished,
              bool(outcome["runner_memory_capacity_established"])
                == resourcePassBoundary.runnerMemoryCapacityEstablished,
              bool(outcome["update_occurred"])
                == resourcePassBoundary.updateOccurred,
              int(counts["direct_package_b_training_logits_api_call_count"])
                == resourcePassBoundary
                    .directPackageBTrainingLogitsAPICallCount,
              int(counts["dense_embedding_construction_count"])
                == resourcePassBoundary.denseEmbeddingConstructionCount,
              int(counts["maintained_gather_training_logits_count"])
                == resourcePassBoundary.maintainedGatherTrainingLogitsCount,
              int(counts["input_embedding_forward_pair_diagnostic_invocation_count"])
                == resourcePassBoundary
                    .inputEmbeddingForwardPairDiagnosticInvocationCount,
              int(counts["tiny_training_selector_invocation_count"])
                == resourcePassBoundary.tinyTrainingSelectorInvocationCount,
              int(counts["checked_evaluation_barrier_count"])
                == resourcePassBoundary.checkedEvaluationBarrierCount,
              int(counts["gpu_synchronization_barrier_count"])
                == resourcePassBoundary.gpuSynchronizationBarrierCount,
              uint32(outcome["loss_float32_bits"])
                == resourcePassBoundary.lossFloat32Bits,
              uint32(outcome["raw_gradient_norm_float32_bits"])
                == resourcePassBoundary.rawGradientNormFloat32Bits,
              uint32(outcome["gradient_clip_scale_float32_bits"])
                == resourcePassBoundary.gradientClipScaleFloat32Bits,
              string(outcome["parameter_fingerprint_before"])
                == resourcePassBoundary.parameterFingerprintBefore,
              string(outcome["parameter_fingerprint_after"])
                == resourcePassBoundary.parameterFingerprintAfter,
              string(outcome["parameter_fingerprint_sample_plan_sha256"])
                == resourcePassBoundary.parameterFingerprintSamplePlanSHA256,
              int(outcome["parameter_fingerprint_sample_count"])
                == resourcePassBoundary.parameterFingerprintSampleCount,
              uint64(limits["configured_memory_limit_bytes"])
                == resourcePassBoundary.configuredMemoryLimitBytes,
              int(environment["runtime_metallib_byte_count"])
                == resourcePassBoundary.runtimeMetallibByteCount,
              string(environment["runtime_metallib_sha256"])
                == resourcePassBoundary.runtimeMetallibSHA256,
              phases.map({ string($0["phase"]) ?? "" })
                == resourcePassBoundary.phaseNames,
              let finalPhase = phases.last,
              uint64(finalPhase["cumulative_worker_probe_elapsed_nanoseconds"])
                == resourcePassBoundary.finalElapsedNanoseconds,
              uint64(finalPhase["physical_memory_capacity_bytes"])
                == resourcePassBoundary.physicalMemoryCapacityBytes,
              phases.compactMap({ uint64($0["mlx_peak_bytes"]) }).max()
                == resourcePassBoundary.peakMLXBytes,
              resourcePassBoundary.configuredMemoryLimitBytes
                    - resourcePassBoundary.peakMLXBytes
                == resourcePassBoundary.mlxMemoryHeadroomBytes
        else {
            return false
        }
        return true
    }

    private func terminalCrossBindingsHold(
        _ terminal: [String: Any]
    ) -> Bool {
        guard string(terminal["schema_id"])
                == "ergentics_prime_native_decoder_b_specific_native300m_resource_witness_internal_terminal_v1",
              int(terminal["schema_version"]) == 1,
              string(terminal["authority_id"]) == predecessorAuthorityID,
              string(terminal["authority_canonical_sha256"])
                == predecessorAuthorityCanonicalSHA256,
              string(terminal["terminal_status"])
                == integrityPassBoundary.terminalStatus,
              string(terminal["classification"])
                == integrityPassBoundary.classification,
              bool(terminal["candidate_present"])
                == resourcePassBoundary.candidatePresent,
              string(terminal["candidate_scientific_status"])
                == resourcePassBoundary.candidateScientificStatus,
              string(terminal["candidate_sha256"])
                == receiptIdentity.candidateSHA256,
              bool(terminal["lease_acquired"])
                == integrityPassBoundary.leaseAcquired,
              bool(terminal["release_verifier_exit_zero"])
                == integrityPassBoundary.releaseVerifierExitZero,
              int(terminal["supervisor_integrity_guard_count"])
                == integrityPassBoundary.supervisorIntegrityGuardCount,
              terminal["first_failed_guard_id"] is NSNull,
              terminal["errno"] is NSNull,
              terminal["actual_metadata"] is NSNull,
              strings(terminal["supervisor_post_candidate_inventory"])
                == integrityPassBoundary.supervisorPostCandidateInventory,
              strings(terminal["verifier_inventory"])
                == integrityPassBoundary.verifierInventory,
              let postLease = dictionary(
                terminal["supervisor_post_candidate_lease_tuple"]),
              let verifierLease = dictionary(terminal["verifier_lease_tuple"]),
              let preParent = dictionary(
                terminal["supervisor_preflight_parent_tuple"]),
              let postParent = dictionary(
                terminal["supervisor_post_candidate_parent_tuple"]),
              let verifierParent = dictionary(terminal["verifier_parent_tuple"]),
              tuple(postLease, matches: integrityPassBoundary),
              tuple(verifierLease, matches: integrityPassBoundary),
              parentTuple(
                preParent,
                observedNlink:
                    integrityPassBoundary.parentPreflightObservedNlink),
              parentTuple(
                postParent,
                observedNlink:
                    integrityPassBoundary.parentPostCandidateObservedNlink),
              parentTuple(
                verifierParent,
                observedNlink:
                    integrityPassBoundary.parentVerifierObservedNlink)
        else {
            return false
        }
        return true
    }

    private func tuple(
        _ raw: [String: Any],
        matches boundary: IntegrityPassBoundary
    ) -> Bool {
        uint64(raw["device_id"]) == boundary.leaseDeviceID
            && uint64(raw["inode"]) == boundary.leaseInode
            && int(raw["uid"]) == boundary.leaseUID
            && int(raw["gid"]) == boundary.leaseGID
            && string(raw["mode"]) == boundary.leaseMode
            && int(raw["observed_nlink"]) == boundary.leaseObservedNlink
            && int(raw["byte_count"]) == boundary.leaseByteCount
            && string(raw["file_type"]) == boundary.leaseFileType
            && int(raw["acl_entry_count"]) == 0
            && strings(raw["observed_extended_attribute_names"]) == []
            && int(raw["security_flags"]) == 0
    }

    private func parentTuple(
        _ raw: [String: Any],
        observedNlink: Int
    ) -> Bool {
        string(raw["physical_path"]) == integrityPassBoundary.parentPhysicalPath
            && uint64(raw["device_id"])
                == integrityPassBoundary.parentDeviceID
            && uint64(raw["inode"]) == integrityPassBoundary.parentInode
            && int(raw["uid"]) == integrityPassBoundary.parentUID
            && int(raw["gid"]) == integrityPassBoundary.parentGID
            && string(raw["mode"]) == integrityPassBoundary.parentMode
            && int(raw["observed_nlink"]) == observedNlink
            && string(raw["file_type"]) == "directory"
            && int(raw["acl_entry_count"]) == 0
            && strings(raw["observed_extended_attribute_names"]) == []
            && int(raw["security_flags"]) == 0
    }

    private static func validSource(_ source: SourceIdentity) -> Bool {
        !source.path.isEmpty
            && ["100644", "100755"].contains(source.gitMode)
            && validLowercaseHex(source.gitBlob, count: 40)
            && source.byteCount > 0
            && validLowercaseHex(source.sha256, count: 64)
            && !source.role.isEmpty
    }

    private static func validRawLog(_ log: RawLogIdentity) -> Bool {
        log.codeUnitCount > 0
            && log.byteCount >= log.codeUnitCount
            && log.lfByteCount > 0
            && log.newlineDelimitedComponentCountIncludingTerminalEmpty
                == log.lfByteCount + 1
            && log.utf8BOMHex == "efbbbf"
            && log.startsWithUTF8BOM
            && log.usesLFOnly
            && log.endsWithLF
            && validLowercaseHex(log.sha256, count: 64)
            && !log.rawGitHubLogArchiveBytesBound
            && !log.retainedInRepository
    }

    private static func validLowercaseHex(
        _ value: String,
        count: Int
    ) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy { scalar in
                (scalar.value >= 48 && scalar.value <= 57)
                    || (scalar.value >= 97 && scalar.value <= 102)
            }
    }

    private func dictionary(_ value: Any?) -> [String: Any]? {
        value as? [String: Any]
    }

    private func string(_ value: Any?) -> String? {
        value as? String
    }

    private func strings(_ value: Any?) -> [String]? {
        value as? [String]
    }

    private func int(_ value: Any?) -> Int? {
        (value as? NSNumber)?.intValue
    }

    private func uint32(_ value: Any?) -> UInt32? {
        (value as? NSNumber)?.uint32Value
    }

    private func uint64(_ value: Any?) -> UInt64? {
        (value as? NSNumber)?.uint64Value
    }

    private func bool(_ value: Any?) -> Bool? {
        value as? Bool
    }
}
