// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case nonCanonicalEncoding
}

/// Immutable evidence for the sole run-111 Stage-6 resource-only execution.
///
/// This value is append-only and dependency-free. It records the exact PASS
/// receipt and its execution envelope; it performs no filesystem, process,
/// network, Metal, MLX, model, optimizer, artifact, or publication operation.
/// Stage 5 remains result-false and assay-clearance-false, so the independent
/// Stage-6 resource clearance does not establish or authorize Stage 7.
public struct
    PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public struct Job: Codable, Equatable, Sendable {
        public let id: Int
        public let runnerImage: String
        public let startedAt: String
        public let completedAt: String
        public let orderedStepCount: Int
        public let successfulStepCount: Int
        public let status: String
        public let conclusion: String
    }

    public struct Run: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let headBranch: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let checkSuiteID: Int
        public let runAttempt: Int
        public let event: String
        public let exactHeadPushRunCount: Int
        public let previousAttemptURLWasNull: Bool
        public let rerunCount: Int
        public let artifactCount: Int
        public let status: String
        public let conclusion: String
        public let activeRootJob: Job
        public let reviewedMainJob: Job
    }

    public struct PredecessorBoundary: Codable, Equatable, Sendable {
        public let stage5ObservationID: String
        public let stage5ObservationCanonicalSHA256: String
        public let stage5MechanicsExecuted: Bool
        public let stage5OneShotConsumed: Bool
        public let stage5LifecycleCompletedAndRetired: Bool
        public let stage5ResultEstablished: Bool
        public let stage5MechanicsSuccessEstablished: Bool
        public let stage5AssayClearanceEstablished: Bool
        public let repeatedTrajectoryDeterminismEstablished: Bool
        public let exactMetalGradientBytesEstablished: Bool
        public let metalDeterminismEstablished: Bool
        public let stage5ReplacementExecutionAuthorized: Bool
        public let stage6AuthorityID: String
        public let stage6AuthorityCanonicalSHA256: String
        public let authorityClosureRunID: Int
        public let authorityClosureRunNumber: Int
        public let authorityClosureCheckSuiteID: Int
        public let authorityClosureRevision: String
        public let authorityClosureTree: String
        public let authorityClosureRunAttempt: Int
        public let authorityClosureArtifactCount: Int
        public let authorityClosureRerunCount: Int
        public let authorityClosureConclusion: String
    }

    public struct Suite: Codable, Equatable, Sendable {
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedStage6PureContractXCTestCount: Int
        public let focusedStepXCTestCount: Int
        public let metalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let maintainedRuntimeReceiptCount: Int
        public let tokenizerTestCount: Int
        public let tokenizerReceiptCount: Int
        public let stage6LauncherPureContractXCTestCount: Int
        public let liveStepXCTestCount: Int
        public let totalXCTestCount: Int
        public let totalXCTestFailureCount: Int
        public let totalXCTestSkipCount: Int
        public let stage6LauncherInvocationCount: Int
        public let stage6BuildCount: Int
        public let stage6DirectXCTestCount: Int
        public let stage6DirectExecutableProbeCount: Int
        public let stage6ReceiptCount: Int
        public let stage6AggregateInvocationCount: Int
        public let exactLiveOrder: [String]
        public let exactStage6InternalOrder: [String]
    }

    public struct SecureFetch: Codable, Equatable, Sendable {
        public let invocationCount: Int
        public let completionCount: Int
        public let authenticatedDepthOneFetchCount: Int
        public let submoduleUpdateCount: Int
        public let mlxCloneCount: Int
        public let mlxCCloneCount: Int
        public let workflowAuthoredRetryCount: Int
        public let gitInternalRetryCount: Int
        public let tlsFailureCount: Int
        public let sslFailureCount: Int
        public let certificateFailureCount: Int
        public let dnsFailureCount: Int
        public let tlsVerificationBypassCount: Int
        public let customCAInstallationCount: Int
    }

    public struct Metallib: Codable, Equatable, Sendable {
        public let runtimePath: String
        public let byteCount: Int
        public let sha256: String
        public let freshCandidateCount: Int
        public let stagedCopyCount: Int
        public let stagedPermissionMode: String
        public let retainedAfterJob: Bool
        public let artifactUploadInvoked: Bool
    }

    public struct Receipt: Codable, Equatable, Sendable {
        public let receiptID: String
        public let schemaVersion: Int
        public let prefix: String
        public let anchoredOccurrenceCount: Int
        public let totalOccurrenceCount: Int
        public let rawJSONByteCount: Int
        public let rawJSONLFByteCount: Int
        public let rawJSONSHA256: String
        public let rawJSONWasCanonical: Bool
        public let rawJSONEndsWithLF: Bool
        public let prefixedLineByteCount: Int
        public let prefixedLineSHA256: String
        public let canonicalJSON: String
    }

    public struct Lease: Codable, Equatable, Sendable {
        public let type: String
        public let path: String
        public let workerOwned: Bool
        public let acquiredNonblocking: Bool
        public let acquiredBeforeCoreGraphicsMetalOrMLX: Bool
        public let heldThroughCandidateFlush: Bool
        public let heldThroughPostflight: Bool
        public let supervisorReacquireReleaseProved: Bool
    }

    public struct OperationCounts: Codable, Equatable, Sendable {
        public let modelAllocationCount: Int
        public let modelMaterializationCount: Int
        public let trainingLogitsCount: Int
        public let crossEntropyCount: Int
        public let forwardLossCount: Int
        public let valueAndGradCount: Int
        public let backwardCount: Int
        public let gradientNormCount: Int
        public let gradientClipCount: Int
        public let optimizerStepCount: Int
        public let adamWUpdateCount: Int
        public let fullGraphEvaluationCount: Int
        public let checkedEvaluationBarrierCount: Int
        public let gpuSynchronizationBarrierCount: Int
        public let evaluationForwardPassCount: Int
        public let kvCacheAllocationCount: Int
        public let mlxPeakMemoryResetCount: Int
        public let memoryClearCacheCount: Int
        public let postflightDeviceReenumerationCount: Int
    }

    public struct Outcome: Codable, Equatable, Sendable {
        public let status: String
        public let classification: String
        public let oneShotConsumed: Bool
        public let workerCandidatePresent: Bool
        public let resourceProbeExecuted: Bool
        public let resourceEnvelopeEstablished: Bool
        public let resourceClearanceEstablished: Bool
        public let runnerMemoryCapacityEstablished: Bool
        public let updateOccurred: Bool
        public let postflightDeviceIdentityMatchesPreflight: Bool
        public let postflightMLXPolicyAndLimitsMatchPreflight: Bool
        public let lossFloat32Bits: UInt32
        public let rawGradientNormFloat32Bits: UInt32
        public let gradientClipScaleFloat32Bits: UInt32
        public let parameterFingerprintBefore: String
        public let parameterFingerprintAfter: String
        public let parameterFingerprintSamplePlanSHA256: String
        public let parameterFingerprintSampleCount: Int
        public let operationCounts: OperationCounts
    }

    public struct ResourceLimits: Codable, Equatable, Sendable {
        public let weightsLogicalBytes: UInt64
        public let gradientLogicalBytes: UInt64
        public let optimizerMomentTensorCount: Int
        public let optimizerMomentLogicalBytes: UInt64
        public let minimumCommittedTensorStateBytes: UInt64
        public let minimumStatePlusGradientBytes: UInt64
        public let minimumMemoryLimitFloorBytes: UInt64
        public let threeTimesCommittedStateDiskComparatorBytes: UInt64
        public let configuredMemoryLimitBytes: UInt64
        public let configuredMemoryLimitReadbackBytes: UInt64
        public let configuredMemoryLimitFormula: String
        public let configuredCacheLimitBytes: UInt64
        public let configuredCacheLimitReadbackBytes: UInt64
        public let availableFilesystemFloorBytes: UInt64
        public let supervisorEndToEndTimeoutSeconds: Int
        public let workerActiveTimeoutSeconds: Int
        public let terminationGraceSeconds: Int
        public let validatedUniqueParameterCount: UInt64
        public let validatedParameterPathCount: Int
        public let validatedGradientPathCount: Int
        public let validatedFirstMomentTensorCount: Int
        public let validatedSecondMomentTensorCount: Int
        public let containerHeadersAndManifestsIncludedInMinimum: Bool
        public let duplicateMaterializationsGraphsAndTemporaryBuffersIncludedInMinimum:
            Bool
        public let mlxLimitIsNotRSSLimit: Bool
        public let statfsIsObservationalOnly: Bool
    }

    public struct PhaseMetric: Codable, Equatable, Sendable {
        public let phase: String
        public let availability: String
        public let unavailableReason: String?
        public let cumulativeWorkerProbeElapsedNanoseconds: UInt64
        public let physicalMemoryCapacityBytes: UInt64
        public let taskResidentBytes: UInt64
        public let taskPhysicalFootprintBytes: UInt64
        public let getrusageMaxRSSBytes: UInt64
        public let metalCurrentAllocatedBytes: UInt64
        public let mlxActiveBytes: UInt64
        public let mlxCacheBytes: UInt64
        public let mlxPeakBytes: UInt64
        public let filesystemCapacityBytes: UInt64
        public let filesystemAvailableBytes: UInt64
    }

    public struct Retirement: Codable, Equatable, Sendable {
        public let required: Bool
        public let observed: Bool
        public let successfulAttemptConsumed: Bool
        public let exactMainRetirementClosureRequired: Bool
        public let exactChangedPaths: [String]
        public let expectedRootTestCount: Int
        public let expectedIsolatedGroupTestCounts: [Int]
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedMetalTestCount: Int
        public let expectedMaintainedRuntimeTestCount: Int
        public let expectedTokenizerTestCount: Int
        public let expectedTotalTestCount: Int
        public let expectedLiveOrder: [String]
        public let stage6LauncherPath: String
        public let stage6LauncherMode: String
        public let stage6LauncherGitBlob: String
        public let stage6LauncherByteCount: Int
        public let stage6LauncherLFByteCount: Int
        public let stage6LauncherSHA256: String
        public let expectedStage6LauncherInvocationCount: Int
        public let expectedStage6ReceiptCount: Int
        public let launcherSourcePreservedForAudit: Bool
    }

    public struct Ceiling: Codable, Equatable, Sendable {
        public let additionalExecutionOrRerunAuthorized: Bool
        public let additionalNative300MAllocationAuthorized: Bool
        public let additionalResourceProbeExecutionAuthorized: Bool
        public let artifactUploadAuthorized: Bool
        public let broadNative300MTrainingAuthorized: Bool
        public let canaryAuthorized: Bool
        public let candidateAdmissionGranted: Bool
        public let checkpointAdmissionGranted: Bool
        public let downstreamTrialAuthorized: Bool
        public let durableCheckpointIOAuthorized: Bool
        public let exactMetalGradientBytesEstablished: Bool
        public let generalTrainingResumeEstablished: Bool
        public let metalDeterminismEstablished: Bool
        public let modelQualityEstablished: Bool
        public let native300MTrajectoryTrainingResumeEstablished: Bool
        public let ordinaryJobFitEstablished: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
        public let quantizationAuthorized: Bool
        public let repeatedTrajectoryDeterminismEstablished: Bool
        public let retainedArtifactAuthorized: Bool
        public let stage5AssayClearanceEstablished: Bool
        public let stage5MechanicsSuccessEstablished: Bool
        public let stage5ReplacementExecutionAuthorized: Bool
        public let stage5ResultEstablished: Bool
        public let stage7RequiresStage5AssayAndStage6ResourceClearance: Bool
        public let stage5AssayClearanceMissingBlocksStage7: Bool
        public let stage7AuthorityEstablished: Bool
        public let stage7Authorized: Bool
    }

    public static let canonicalSHA256 =
        "6f18f128b30565cba0e53ad4f834882d050851199639299d2aa9ecf2e0cb51bf"

    private static let exactReceiptJSON = #"""
{"authority":{"authority_canonical_sha256":"2627ffc0dd6499a9a1b20fa217b7f1c4a9723a6fd6332ef24a9ee251b5b0bf56","authority_id":"prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1","authority_source_git_blob":"d65361e24a5eb3608ca774066a76ecf608c76d53","authority_source_sha256":"a03507b0cbd532949178fa5515d0b0d0cabfe786b0d79619d89453ea23b855c6","authority_test_git_blob":"a6ff11d4d8beb2aa39ca6e04ac32defb94220033","authority_test_sha256":"a501188363b11b61731099066d61594a0dc3d27fbe5c5c4eec3d0fbcea0de065"},"ceiling":{"additional_execution_or_rerun_authorized":false,"artifact_upload_authorized":false,"broad_native300m_training_authorized":false,"canary_authorized":false,"candidate_admission_granted":false,"checkpoint_admission_granted":false,"downstream_trial_authorized":false,"durable_checkpoint_io_authorized":false,"exact_metal_gradient_bytes_established":false,"general_training_resume_established":false,"metal_determinism_established":false,"model_quality_established":false,"native300m_trajectory_training_resume_established":false,"ordinary_job_fit_established":false,"product_use_authorized":false,"publication_authorized":false,"quantization_authorized":false,"repeated_trajectory_determinism_established":false,"retained_artifact_authorized":false,"stage5_assay_clearance_established":false,"stage5_mechanics_success_established":false,"stage5_replacement_execution_authorized":false,"stage5_result_established":false,"stage7_authority_established":false,"stage7_authorized":false},"configuration":{"adamw_beta1_float32_bits":1063675494,"adamw_beta2_float32_bits":1065336439,"adamw_bias_correction_applied":false,"adamw_epsilon_float32_bits":841731191,"adamw_learning_rate_float32_bits":953267991,"adamw_weight_decay_float32_bits":1008981770,"batch_size":1,"batch_token_ids_sha256":"220a52583cdbb82311863f4643679734b2ffc69725af021f066a84fc7520a172","completion_mask_dtype":"bool","cross_entropy_api":"MLXNN.crossEntropy(logits:targets:weights:axis:labelSmoothing:reduction:)","cross_entropy_reduction":"none","gradient_accumulation_count":1,"gradient_clip_algorithm_id":"prime_stage6_global_norm_clip_f32_v1","gradient_clip_mode":"global_l2_norm_clip_once_before_adamw_update","gradient_norm_epsilon_float32_bits":897988541,"initialization_seed":44,"logits_dtype":"float32","loss_dtype":"float32","loss_graph_algorithm_id":"prime_stage6_causal_masked_mean_cross_entropy_f32_v1","maximum_gradient_norm_float32_bits":1065353216,"model_configuration_factory":"native300MInventory(vocabularySize:)","model_factory":"make(configuration:seed:)","optimizer_qualified_type":"MLXOptimizers.AdamW","optimizer_state_inspection_api":"MLXOptimizers.AdamW.innerState()","optimizer_state_pair_topology":"218_adjacent_[first_moment,second_moment]_pairs_from_TupleState.innerState","optimizer_step_count":1,"parameter_dtype":"float32","parameter_fingerprint_algorithm_id":"prime_stage6_parameter_catalog_sample_f32be_sha256_v1","parameter_fingerprint_expected_path_count":218,"parameter_fingerprint_expected_sample_count":654,"parameter_fingerprint_samples_per_path":3,"parameter_path_count":218,"per_target_loss_dtype":"float32","per_target_loss_expected_element_count":127,"per_target_loss_expected_shape":[1,127],"post_model_full_state_evaluation_api":"checkedEval(model,before_fingerprint_sample_views)","post_update_full_state_evaluation_api":"checkedEval(model,optimizer,after_fingerprint_sample_views)","raw_gradient_norm_algorithm_id":"prime_stage6_global_f32_l2_norm_utf8_catalog_v1","selected_target_count":127,"sequence_length":128,"token_id_dtype":"int32","training_logits_api":"PrimeNativeGQADecoder.trainingLogitsNoCache","unique_parameter_count":271107072,"valid_token_count":128,"value_and_grad_api":"MLXNN.valueAndGrad(model:_:)"},"environment":{"filesystem_observation_fsid":[16777232,26],"filesystem_observation_path":"/Users/runner/work/_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-build/arm64-apple-macosx/release","metal_device_count":1,"metal_device_has_unified_memory":true,"metal_device_index":0,"metal_device_is_default":true,"metal_device_max_buffer_length_bytes":3758096384,"metal_device_max_recommended_working_set_bytes":5010800640,"metal_device_name":"Apple Paravirtual device","metal_device_registry_id":4294967704,"mlx_compile_transform_invocation_count":0,"mlx_cpu_fallback_used":false,"mlx_default_device_is_supplied_device":true,"mlx_default_stream_is_gpu":true,"mlx_device_constructor_index":0,"mlx_device_type":"gpu","mlx_enable_tf32":"0","mlx_revision":"d37885a278f1c37484a94d0f401a418735e66519","operating_system_build":"26.5.2-25F84","runtime_metallib_byte_count":6292716,"runtime_metallib_path":"/Users/runner/work/_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib","runtime_metallib_sha256":"835c4bb71b0693022a8a9565b2131f3a6bd478e78f03737b6b0cc373401f05be","swift_sdk":"26.5","swift_version":"Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) Target: arm64-apple-macosx26.0","swiftpm_build_configuration":"release","xcode_version":"Xcode 26.6 Build version 17F113"},"execution":{"authority_base_revision":"f5a9638194c53922f09c39c3c76095b5cc47c25e","authority_base_tree":"a17a8f92604157c0de0252dbc30cf22681d6a13d","authority_closure_active_job_conclusion":"success","authority_closure_active_job_id":94683934560,"authority_closure_artifact_count":0,"authority_closure_check_suite_id":86198647430,"authority_closure_conclusion":"success","authority_closure_event":"push","authority_closure_ref":"refs/heads/main","authority_closure_rerun_count":0,"authority_closure_reviewed_job_conclusion":"success","authority_closure_reviewed_job_id":94684324255,"authority_closure_revision":"7dd21f2b8c79ebe53f62eab1945ac41b104c2b27","authority_closure_run_attempt":1,"authority_closure_run_id":31773463958,"authority_closure_run_number":109,"authority_closure_status":"completed","authority_closure_tree":"5124b8a75ca753d1e7659a2535242aa909329c44","build_count":1,"direct_executable_probe_count":1,"direct_xctest_count":1,"exact_changed_source_identities":[{"byte_count":668999,"git_blob":"b1fb5e79b448645ea661386e1ff53bf8dffd606f","mode":"100755","path":".github/scripts/prime-ci-active-root-quarantine.sh","sha256":"ab742c6002681f2d331964ff1f7a130cfdb61110dc9bd5a1d847369d7417abba"},{"byte_count":108576,"git_blob":"9e8f7ca0c6fa6c02bc4b0f40cc2185d2e6d46d13","mode":"100755","path":".github/scripts/prime-ci-native-decoder-stage6-native300m-resource-only-one-step.sh","sha256":"8801c46f54eaee475f3a2fdb697b2184af4233b9cdf7a66ddd9867d14eb4f349"},{"byte_count":79973,"git_blob":"46eea6e394fd8730550996418e53cc59b24e559a","mode":"100644","path":".github/workflows/prime-active-root-quarantine.yml","sha256":"320291ca90fbb7f11aaea5295a3cebe4370b7e0059f3e7015050c3addb4c35a5"},{"byte_count":546,"git_blob":"f431fa730d5ba52ab16835a466f83ec48432398e","mode":"100644","path":"Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift","sha256":"81f91539cd9256288c0ec1d56d7d910c6e0c8885f72d607e9d9b1c1c87cdd8aa"},{"byte_count":188872,"git_blob":"4c13d3098f07eb748980a351823dcf4fc36da337","mode":"100644","path":"Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift","sha256":"b29384112ed178b6d3bce6fb8dd138c861521cbddd968d418208baa669b5caf0"},{"byte_count":1993,"git_blob":"1bce54baedf4293fcba01238228105f987fd43d3","mode":"100644","path":"Tests/PrimeNativeDecoderTrainingValidation/Package.swift","sha256":"8488fbd194efcd6900604923a922485f72c2ce4b870c6efd2267564f3bff43a9"},{"byte_count":231,"git_blob":"22af7bd97dd53e9778eef3a437f7f3f10e120a2f","mode":"100644","path":"Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe/main.swift","sha256":"6060f1e8afe7b27e68c96b16d2af60f617ccdcf875a085b21aed32b3589f9395"},{"byte_count":3532,"git_blob":"75deca6b2d1d640d2c6d3b4eb3f6dfbb52101ec7","mode":"100644","path":"Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeContractTests.swift","sha256":"d7ad08a56dab0936cd9aac434de2a8828a2302df1a588b6ceca6de5d46a8981a"}],"launcher_invocation_count":1,"mechanics_event":"push","mechanics_head_ordered_parent_revisions":["7dd21f2b8c79ebe53f62eab1945ac41b104c2b27","5164075dc6f83242563ee804caea24e9599eb71d"],"mechanics_head_revision":"437acb46a5af63f6c604e5f5c50f3b63eaa296f2","mechanics_head_tree":"f87272ed850cd2ac1898bd6c5d4cbefd2c664bb0","mechanics_ref":"refs/heads/main","mechanics_run_attempt":1,"mechanics_run_id":31784730175,"mechanics_run_number":111,"provenance_source_identities":{"embedded_source_identity_sha256":"087b9008d051d8f1ec7ab5d762ae11180ffca94ee31e461a9c81f254b163f678","identities":[{"byte_count":12919,"git_blob":"89baf9cc69d7e4f046467f197ce9da8a309248c3","mode":"100644","path":"Source/MLX/Memory.swift","sha256":"cb6976cc37aa3e8a0fa1be8269fea2869ecdf5951e469556f67e21604b1701f8"},{"byte_count":24109,"git_blob":"fb9c5d9636a211bb74fae7bf6a1dbbd4fe01d7b9","mode":"100644","path":"Source/MLXOptimizers/Optimizers.swift","sha256":"f2a36919b73cbec5f3fac6ea23022832474a7aca04b7bfc4ce63bd1f201f6e2d"},{"byte_count":16985,"git_blob":"da3daa54802b67dc2c8c04a89b388e9927dd8726","mode":"100644","path":"Sources/PrimeCore/PrimeMetalDeviceLease.swift","sha256":"edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657"},{"byte_count":210057,"git_blob":"d65361e24a5eb3608ca774066a76ecf608c76d53","mode":"100644","path":"Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthority.swift","sha256":"a03507b0cbd532949178fa5515d0b0d0cabfe786b0d79619d89453ea23b855c6"},{"byte_count":39598,"git_blob":"0c80c1ab7173c2620a92c2a14e8d42d6562dbe0f","mode":"100644","path":"Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift","sha256":"d59a19bdbb37a74d5d08bea65c6b77bf2ed2dd4d3f138e5758a4ef9613b93994"},{"byte_count":188872,"git_blob":"4c13d3098f07eb748980a351823dcf4fc36da337","mode":"100644","path":"Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift","sha256":"b29384112ed178b6d3bce6fb8dd138c861521cbddd968d418208baa669b5caf0"},{"byte_count":36733,"git_blob":"a6ff11d4d8beb2aa39ca6e04ac32defb94220033","mode":"100644","path":"Tests/PrimeCoreTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeAuthorityTests.swift","sha256":"a501188363b11b61731099066d61594a0dc3d27fbe5c5c4eec3d0fbcea0de065"}]},"repository":"Ergentics/ergentics-prime","supervisor_end_to_end_elapsed_nanoseconds":33532625042,"supervisor_process_count":1,"supervisor_timeout_trigger_elapsed_nanoseconds":null,"supervisor_timeout_triggered":false,"timeout_scope":null,"worker_active_elapsed_nanoseconds":33519059708,"worker_candidate_frame_count":1,"worker_exit_code":0,"worker_last_complete_frame_sequence":4280,"worker_process_count":1,"worker_progress_frame_count":4280,"worker_signal":null,"worker_spawn_attempt_count":1,"worker_spawn_errno":null,"worker_spawn_succeeded":true,"worker_timeout_trigger_elapsed_nanoseconds":null,"worker_timeout_triggered":false,"worker_trailing_partial_frame_discarded":false,"worker_transport_drift_detected":false},"lease":{"acquired_before_coregraphics_metal_or_mlx":true,"acquired_nonblocking":true,"held_through_candidate_flush":true,"held_through_postflight":true,"lease_path":"/Users/runner/work/_temp/prime-native-decoder-stage6-metal-lease/device-0.lock","supervisor_reacquire_release_proved":true,"type":"PrimeMetalDeviceLease","worker_owned":true},"limits":{"available_filesystem_floor_bytes":12884901888,"configured_cache_limit_bytes":0,"configured_cache_limit_readback_bytes":0,"configured_memory_limit_bytes":5010800640,"configured_memory_limit_formula":"min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)","configured_memory_limit_readback_bytes":5010800640,"container_headers_and_manifests_included_in_minimum":false,"duplicate_materializations_graphs_and_temporary_buffers_included_in_minimum":false,"gradient_logical_bytes":1084428288,"minimum_committed_tensor_state_bytes":3253284864,"minimum_memory_limit_floor_bytes":4337713152,"minimum_state_plus_gradient_bytes":4337713152,"mlx_limit_is_not_rss_limit":true,"optimizer_moment_logical_bytes":2168856576,"optimizer_moment_tensor_count":436,"statfs_is_observational_only":true,"supervisor_end_to_end_timeout_seconds":1500,"termination_grace_seconds":10,"three_times_committed_state_disk_comparator_bytes":9759854592,"validated_first_moment_tensor_count":218,"validated_gradient_logical_bytes":1084428288,"validated_gradient_path_count":218,"validated_optimizer_moment_logical_bytes":2168856576,"validated_parameter_path_count":218,"validated_second_moment_tensor_count":218,"validated_unique_parameter_count":271107072,"validated_weights_logical_bytes":1084428288,"weights_logical_bytes":1084428288,"worker_active_timeout_seconds":1200},"outcome":{"classification":"pass","gradient_clip_scale_float32_bits":1027397872,"loss_float32_bits":1088043293,"one_shot_consumed":true,"operation_counts":{"adamw_update_count":1,"backward_count":1,"checked_evaluation_barrier_count":5,"cross_entropy_count":1,"evaluation_forward_pass_count":0,"forward_loss_count":1,"full_graph_evaluation_count":1,"gpu_synchronization_barrier_count":5,"gradient_clip_count":1,"gradient_norm_count":1,"kv_cache_allocation_count":0,"memory_clear_cache_count":1,"mlx_peak_memory_reset_count":1,"model_allocation_count":1,"model_materialization_count":1,"optimizer_step_count":1,"postflight_device_reenumeration_count":1,"training_logits_count":1,"value_and_grad_count":1},"parameter_fingerprint_after":"4e0f9afe1e7217d11379f02c1e44ea498c3cbda5add228c247166e6775d8f7d2","parameter_fingerprint_before":"64263c521c6534561fb66a0e87e10a1229bdc9fe859f879c3a9f91c11abfa04e","parameter_fingerprint_sample_count":654,"parameter_fingerprint_sample_plan_sha256":"a36fdb60e23052b03b8e257224e1d47fd9731294f34a268a5fbff2b21ac49f87","postflight_device_identity_matches_preflight":true,"postflight_mlx_policy_and_limits_match_preflight":true,"raw_gradient_norm_float32_bits":1101890567,"resource_clearance_established":true,"resource_envelope_established":true,"resource_probe_executed":true,"runner_memory_capacity_established":true,"status":"PASS","update_occurred":true,"worker_candidate_present":true},"phase_metrics":[{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":60808375,"filesystem_available_bytes":91885637632,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":29556736,"metal_current_allocated_bytes":0,"mlx_active_bytes":0,"mlx_cache_bytes":0,"mlx_peak_bytes":0,"phase":"preflight","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":6047104,"task_resident_bytes":29556736,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":2113609792,"filesystem_available_bytes":91884892160,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":72335360,"metal_current_allocated_bytes":1096794112,"mlx_active_bytes":1084430904,"mlx_cache_bytes":0,"mlx_peak_bytes":1084432344,"phase":"post_model_materialization","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":1131202752,"task_resident_bytes":68616192,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":5743047208,"filesystem_available_bytes":91883593728,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":72335360,"metal_current_allocated_bytes":2171158528,"mlx_active_bytes":2168857220,"mlx_cache_bytes":0,"mlx_peak_bytes":2190878848,"phase":"post_forward_backward","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":2206992640,"task_resident_bytes":39501824,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":15539313833,"filesystem_available_bytes":90810826752,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":72335360,"metal_current_allocated_bytes":3256221696,"mlx_active_bytes":3253285516,"mlx_cache_bytes":0,"mlx_peak_bytes":3253285660,"phase":"post_norm_clip","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":3301951744,"task_resident_bytes":41533440,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":31451135667,"filesystem_available_bytes":89737068544,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":101400576,"metal_current_allocated_bytes":4351885312,"mlx_active_bytes":4337715768,"mlx_cache_bytes":0,"mlx_peak_bytes":4781317844,"phase":"post_adam_update_full_evaluation","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":4422175104,"task_resident_bytes":66682880,"unavailable_reason":null},{"availability":"observed","cumulative_worker_probe_elapsed_nanoseconds":33413595458,"filesystem_available_bytes":89737068544,"filesystem_capacity_bytes":343073095680,"getrusage_max_rss_bytes":101400576,"metal_current_allocated_bytes":1048576,"mlx_active_bytes":0,"mlx_cache_bytes":0,"mlx_peak_bytes":4781317844,"phase":"post_lexical_deallocation_and_clear_cache","physical_memory_capacity_bytes":7516192768,"task_physical_footprint_bytes":69126464,"task_resident_bytes":56262656,"unavailable_reason":null}],"receipt_id":"ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_receipt_v1","schema_version":1}
"""#

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_execution_observation_v1",
        run: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            headBranch: "main",
            mergeRevision:
                "437acb46a5af63f6c604e5f5c50f3b63eaa296f2",
            mergeTree:
                "f87272ed850cd2ac1898bd6c5d4cbefd2c664bb0",
            orderedParentRevisions: [
                "7dd21f2b8c79ebe53f62eab1945ac41b104c2b27",
                "5164075dc6f83242563ee804caea24e9599eb71d",
            ],
            workflowRunID: 31_784_730_175,
            workflowRunNumber: 111,
            checkSuiteID: 86_228_325_084,
            runAttempt: 1,
            event: "push",
            exactHeadPushRunCount: 1,
            previousAttemptURLWasNull: true,
            rerunCount: 0,
            artifactCount: 0,
            status: "completed",
            conclusion: "success",
            activeRootJob: .init(
                id: 94_718_000_573,
                runnerImage: "macos-15",
                startedAt: "2026-08-14T08:38:26Z",
                completedAt: "2026-08-14T08:41:03Z",
                orderedStepCount: 7,
                successfulStepCount: 7,
                status: "completed",
                conclusion: "success"),
            reviewedMainJob: .init(
                id: 94_718_575_857,
                runnerImage: "macos-26",
                startedAt: "2026-08-14T08:41:06Z",
                completedAt: "2026-08-14T09:42:41Z",
                orderedStepCount: 7,
                successfulStepCount: 7,
                status: "completed",
                conclusion: "success")),
        predecessor: .init(
            stage5ObservationID:
                "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_execution_failure_observation_v1",
            stage5ObservationCanonicalSHA256:
                "ac735b84948e6b9b6b492a79925d7e0770d6eb332ba4d643d7f2884a4a7f81d2",
            stage5MechanicsExecuted: true,
            stage5OneShotConsumed: true,
            stage5LifecycleCompletedAndRetired: true,
            stage5ResultEstablished: false,
            stage5MechanicsSuccessEstablished: false,
            stage5AssayClearanceEstablished: false,
            repeatedTrajectoryDeterminismEstablished: false,
            exactMetalGradientBytesEstablished: false,
            metalDeterminismEstablished: false,
            stage5ReplacementExecutionAuthorized: false,
            stage6AuthorityID:
                "prime_native_decoder_native300m_resource_only_one_step_probe_authority_v1",
            stage6AuthorityCanonicalSHA256:
                "2627ffc0dd6499a9a1b20fa217b7f1c4a9723a6fd6332ef24a9ee251b5b0bf56",
            authorityClosureRunID: 31_773_463_958,
            authorityClosureRunNumber: 109,
            authorityClosureCheckSuiteID: 86_198_647_430,
            authorityClosureRevision:
                "7dd21f2b8c79ebe53f62eab1945ac41b104c2b27",
            authorityClosureTree:
                "5124b8a75ca753d1e7659a2535242aa909329c44",
            authorityClosureRunAttempt: 1,
            authorityClosureArtifactCount: 0,
            authorityClosureRerunCount: 0,
            authorityClosureConclusion: "success"),
        suite: .init(
            rootTestCount: 55,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedStage6PureContractXCTestCount: 1,
            focusedStepXCTestCount: 62,
            metalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            maintainedRuntimeReceiptCount: 1,
            tokenizerTestCount: 1,
            tokenizerReceiptCount: 1,
            stage6LauncherPureContractXCTestCount: 1,
            liveStepXCTestCount: 47,
            totalXCTestCount: 109,
            totalXCTestFailureCount: 0,
            totalXCTestSkipCount: 0,
            stage6LauncherInvocationCount: 1,
            stage6BuildCount: 1,
            stage6DirectXCTestCount: 1,
            stage6DirectExecutableProbeCount: 1,
            stage6ReceiptCount: 1,
            stage6AggregateInvocationCount: 3,
            exactLiveOrder: [
                "metal", "maintained_runtime", "tokenizer", "stage6",
            ],
            exactStage6InternalOrder: [
                "stage6_pure_contract_xctest",
                "stage6_resource_probe_executable",
            ]),
        secureFetch: .init(
            invocationCount: 1,
            completionCount: 1,
            authenticatedDepthOneFetchCount: 1,
            submoduleUpdateCount: 1,
            mlxCloneCount: 1,
            mlxCCloneCount: 1,
            workflowAuthoredRetryCount: 0,
            gitInternalRetryCount: 0,
            tlsFailureCount: 0,
            sslFailureCount: 0,
            certificateFailureCount: 0,
            dnsFailureCount: 0,
            tlsVerificationBypassCount: 0,
            customCAInstallationCount: 0),
        metallib: .init(
            runtimePath:
                "/Users/runner/work/_temp/prime-native-decoder-stage6-native300m-resource-only-one-step-build/arm64-apple-macosx/release/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
            byteCount: 6_292_716,
            sha256:
                "835c4bb71b0693022a8a9565b2131f3a6bd478e78f03737b6b0cc373401f05be",
            freshCandidateCount: 1,
            stagedCopyCount: 1,
            stagedPermissionMode: "444",
            retainedAfterJob: false,
            artifactUploadInvoked: false),
        receipt: .init(
            receiptID:
                "ergentics_prime_native_decoder_native300m_resource_only_one_step_probe_receipt_v1",
            schemaVersion: 1,
            prefix:
                "PRIME_NATIVE_DECODER_STAGE6_NATIVE300M_RESOURCE_ONLY_ONE_STEP_RECEIPT=",
            anchoredOccurrenceCount: 1,
            totalOccurrenceCount: 1,
            rawJSONByteCount: 17_435,
            rawJSONLFByteCount: 0,
            rawJSONSHA256:
                "104f3579f2caf19f27cbbe694f8a854cc8927d9188af055075c11b1fe1c94c55",
            rawJSONWasCanonical: true,
            rawJSONEndsWithLF: false,
            prefixedLineByteCount: 17_505,
            prefixedLineSHA256:
                "454b623ce9a95131de9b2f03f5a1e4100ef52023bc0ccaf644567d6d4eda2185",
            canonicalJSON: exactReceiptJSON),
        lease: .init(
            type: "PrimeMetalDeviceLease",
            path:
                "/Users/runner/work/_temp/prime-native-decoder-stage6-metal-lease/device-0.lock",
            workerOwned: true,
            acquiredNonblocking: true,
            acquiredBeforeCoreGraphicsMetalOrMLX: true,
            heldThroughCandidateFlush: true,
            heldThroughPostflight: true,
            supervisorReacquireReleaseProved: true),
        limits: .init(
            weightsLogicalBytes: 1_084_428_288,
            gradientLogicalBytes: 1_084_428_288,
            optimizerMomentTensorCount: 436,
            optimizerMomentLogicalBytes: 2_168_856_576,
            minimumCommittedTensorStateBytes: 3_253_284_864,
            minimumStatePlusGradientBytes: 4_337_713_152,
            minimumMemoryLimitFloorBytes: 4_337_713_152,
            threeTimesCommittedStateDiskComparatorBytes: 9_759_854_592,
            configuredMemoryLimitBytes: 5_010_800_640,
            configuredMemoryLimitReadbackBytes: 5_010_800_640,
            configuredMemoryLimitFormula:
                "min(UInt64(17179869184), retainedMTLDevice.recommendedMaxWorkingSetSize)",
            configuredCacheLimitBytes: 0,
            configuredCacheLimitReadbackBytes: 0,
            availableFilesystemFloorBytes: 12_884_901_888,
            supervisorEndToEndTimeoutSeconds: 1_500,
            workerActiveTimeoutSeconds: 1_200,
            terminationGraceSeconds: 10,
            validatedUniqueParameterCount: 271_107_072,
            validatedParameterPathCount: 218,
            validatedGradientPathCount: 218,
            validatedFirstMomentTensorCount: 218,
            validatedSecondMomentTensorCount: 218,
            containerHeadersAndManifestsIncludedInMinimum: false,
            duplicateMaterializationsGraphsAndTemporaryBuffersIncludedInMinimum:
                false,
            mlxLimitIsNotRSSLimit: true,
            statfsIsObservationalOnly: true),
        outcome: .init(
            status: "PASS",
            classification: "pass",
            oneShotConsumed: true,
            workerCandidatePresent: true,
            resourceProbeExecuted: true,
            resourceEnvelopeEstablished: true,
            resourceClearanceEstablished: true,
            runnerMemoryCapacityEstablished: true,
            updateOccurred: true,
            postflightDeviceIdentityMatchesPreflight: true,
            postflightMLXPolicyAndLimitsMatchPreflight: true,
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
            operationCounts: .init(
                modelAllocationCount: 1,
                modelMaterializationCount: 1,
                trainingLogitsCount: 1,
                crossEntropyCount: 1,
                forwardLossCount: 1,
                valueAndGradCount: 1,
                backwardCount: 1,
                gradientNormCount: 1,
                gradientClipCount: 1,
                optimizerStepCount: 1,
                adamWUpdateCount: 1,
                fullGraphEvaluationCount: 1,
                checkedEvaluationBarrierCount: 5,
                gpuSynchronizationBarrierCount: 5,
                evaluationForwardPassCount: 0,
                kvCacheAllocationCount: 0,
                mlxPeakMemoryResetCount: 1,
                memoryClearCacheCount: 1,
                postflightDeviceReenumerationCount: 1)),
        phaseMetrics: [
            .init(
                phase: "preflight",
                availability: "observed",
                unavailableReason: nil,
                cumulativeWorkerProbeElapsedNanoseconds: 60_808_375,
                physicalMemoryCapacityBytes: 7_516_192_768,
                taskResidentBytes: 29_556_736,
                taskPhysicalFootprintBytes: 6_047_104,
                getrusageMaxRSSBytes: 29_556_736,
                metalCurrentAllocatedBytes: 0,
                mlxActiveBytes: 0,
                mlxCacheBytes: 0,
                mlxPeakBytes: 0,
                filesystemCapacityBytes: 343_073_095_680,
                filesystemAvailableBytes: 91_885_637_632),
            .init(
                phase: "post_model_materialization",
                availability: "observed",
                unavailableReason: nil,
                cumulativeWorkerProbeElapsedNanoseconds: 2_113_609_792,
                physicalMemoryCapacityBytes: 7_516_192_768,
                taskResidentBytes: 68_616_192,
                taskPhysicalFootprintBytes: 1_131_202_752,
                getrusageMaxRSSBytes: 72_335_360,
                metalCurrentAllocatedBytes: 1_096_794_112,
                mlxActiveBytes: 1_084_430_904,
                mlxCacheBytes: 0,
                mlxPeakBytes: 1_084_432_344,
                filesystemCapacityBytes: 343_073_095_680,
                filesystemAvailableBytes: 91_884_892_160),
            .init(
                phase: "post_forward_backward",
                availability: "observed",
                unavailableReason: nil,
                cumulativeWorkerProbeElapsedNanoseconds: 5_743_047_208,
                physicalMemoryCapacityBytes: 7_516_192_768,
                taskResidentBytes: 39_501_824,
                taskPhysicalFootprintBytes: 2_206_992_640,
                getrusageMaxRSSBytes: 72_335_360,
                metalCurrentAllocatedBytes: 2_171_158_528,
                mlxActiveBytes: 2_168_857_220,
                mlxCacheBytes: 0,
                mlxPeakBytes: 2_190_878_848,
                filesystemCapacityBytes: 343_073_095_680,
                filesystemAvailableBytes: 91_883_593_728),
            .init(
                phase: "post_norm_clip",
                availability: "observed",
                unavailableReason: nil,
                cumulativeWorkerProbeElapsedNanoseconds: 15_539_313_833,
                physicalMemoryCapacityBytes: 7_516_192_768,
                taskResidentBytes: 41_533_440,
                taskPhysicalFootprintBytes: 3_301_951_744,
                getrusageMaxRSSBytes: 72_335_360,
                metalCurrentAllocatedBytes: 3_256_221_696,
                mlxActiveBytes: 3_253_285_516,
                mlxCacheBytes: 0,
                mlxPeakBytes: 3_253_285_660,
                filesystemCapacityBytes: 343_073_095_680,
                filesystemAvailableBytes: 90_810_826_752),
            .init(
                phase: "post_adam_update_full_evaluation",
                availability: "observed",
                unavailableReason: nil,
                cumulativeWorkerProbeElapsedNanoseconds: 31_451_135_667,
                physicalMemoryCapacityBytes: 7_516_192_768,
                taskResidentBytes: 66_682_880,
                taskPhysicalFootprintBytes: 4_422_175_104,
                getrusageMaxRSSBytes: 101_400_576,
                metalCurrentAllocatedBytes: 4_351_885_312,
                mlxActiveBytes: 4_337_715_768,
                mlxCacheBytes: 0,
                mlxPeakBytes: 4_781_317_844,
                filesystemCapacityBytes: 343_073_095_680,
                filesystemAvailableBytes: 89_737_068_544),
            .init(
                phase: "post_lexical_deallocation_and_clear_cache",
                availability: "observed",
                unavailableReason: nil,
                cumulativeWorkerProbeElapsedNanoseconds: 33_413_595_458,
                physicalMemoryCapacityBytes: 7_516_192_768,
                taskResidentBytes: 56_262_656,
                taskPhysicalFootprintBytes: 69_126_464,
                getrusageMaxRSSBytes: 101_400_576,
                metalCurrentAllocatedBytes: 1_048_576,
                mlxActiveBytes: 0,
                mlxCacheBytes: 0,
                mlxPeakBytes: 4_781_317_844,
                filesystemCapacityBytes: 343_073_095_680,
                filesystemAvailableBytes: 89_737_068_544),
        ],
        retirement: .init(
            required: true,
            observed: false,
            successfulAttemptConsumed: true,
            exactMainRetirementClosureRequired: true,
            exactChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservation.swift",
                "Tests/PrimeCoreTests/PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationTests.swift",
            ],
            expectedRootTestCount: 56,
            expectedIsolatedGroupTestCounts: [1, 1, 2, 2],
            expectedIsolatedTestCount: 6,
            expectedFocusedWholeTestCount: 62,
            expectedMetalTestCount: 44,
            expectedMaintainedRuntimeTestCount: 1,
            expectedTokenizerTestCount: 1,
            expectedTotalTestCount: 108,
            expectedLiveOrder: [
                "metal", "maintained_runtime", "tokenizer",
            ],
            stage6LauncherPath:
                ".github/scripts/prime-ci-native-decoder-stage6-native300m-resource-only-one-step.sh",
            stage6LauncherMode: "100755",
            stage6LauncherGitBlob:
                "9e8f7ca0c6fa6c02bc4b0f40cc2185d2e6d46d13",
            stage6LauncherByteCount: 108_576,
            stage6LauncherLFByteCount: 2_016,
            stage6LauncherSHA256:
                "8801c46f54eaee475f3a2fdb697b2184af4233b9cdf7a66ddd9867d14eb4f349",
            expectedStage6LauncherInvocationCount: 0,
            expectedStage6ReceiptCount: 0,
            launcherSourcePreservedForAudit: true),
        ceiling: .init(
            additionalExecutionOrRerunAuthorized: false,
            additionalNative300MAllocationAuthorized: false,
            additionalResourceProbeExecutionAuthorized: false,
            artifactUploadAuthorized: false,
            broadNative300MTrainingAuthorized: false,
            canaryAuthorized: false,
            candidateAdmissionGranted: false,
            checkpointAdmissionGranted: false,
            downstreamTrialAuthorized: false,
            durableCheckpointIOAuthorized: false,
            exactMetalGradientBytesEstablished: false,
            generalTrainingResumeEstablished: false,
            metalDeterminismEstablished: false,
            modelQualityEstablished: false,
            native300MTrajectoryTrainingResumeEstablished: false,
            ordinaryJobFitEstablished: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            quantizationAuthorized: false,
            repeatedTrajectoryDeterminismEstablished: false,
            retainedArtifactAuthorized: false,
            stage5AssayClearanceEstablished: false,
            stage5MechanicsSuccessEstablished: false,
            stage5ReplacementExecutionAuthorized: false,
            stage5ResultEstablished: false,
            stage7RequiresStage5AssayAndStage6ResourceClearance: true,
            stage5AssayClearanceMissingBlocksStage7: true,
            stage7AuthorityEstablished: false,
            stage7Authorized: false))

    public let schemaVersion: Int
    public let observationID: String
    public let run: Run
    public let predecessor: PredecessorBoundary
    public let suite: Suite
    public let secureFetch: SecureFetch
    public let metallib: Metallib
    public let receipt: Receipt
    public let lease: Lease
    public let limits: ResourceLimits
    public let outcome: Outcome
    public let phaseMetrics: [PhaseMetric]
    public let retirement: Retirement
    public let ceiling: Ceiling

    public func validateExactV1() throws {
        let zeroSecureFetchFailures = [
            secureFetch.workflowAuthoredRetryCount,
            secureFetch.gitInternalRetryCount,
            secureFetch.tlsFailureCount,
            secureFetch.sslFailureCount,
            secureFetch.certificateFailureCount,
            secureFetch.dnsFailureCount,
            secureFetch.tlsVerificationBypassCount,
            secureFetch.customCAInstallationCount,
        ]
        let falseCeilings = [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.additionalNative300MAllocationAuthorized,
            ceiling.additionalResourceProbeExecutionAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.broadNative300MTrainingAuthorized,
            ceiling.canaryAuthorized,
            ceiling.candidateAdmissionGranted,
            ceiling.checkpointAdmissionGranted,
            ceiling.downstreamTrialAuthorized,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.exactMetalGradientBytesEstablished,
            ceiling.generalTrainingResumeEstablished,
            ceiling.metalDeterminismEstablished,
            ceiling.modelQualityEstablished,
            ceiling.native300MTrajectoryTrainingResumeEstablished,
            ceiling.ordinaryJobFitEstablished,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.repeatedTrajectoryDeterminismEstablished,
            ceiling.retainedArtifactAuthorized,
            ceiling.stage5AssayClearanceEstablished,
            ceiling.stage5MechanicsSuccessEstablished,
            ceiling.stage5ReplacementExecutionAuthorized,
            ceiling.stage5ResultEstablished,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
        ]
        guard self == Self.frozenV1,
              schemaVersion == 1,
              run.orderedParentRevisions.count == 2,
              run.runAttempt == 1,
              run.exactHeadPushRunCount == 1,
              run.previousAttemptURLWasNull,
              run.rerunCount == 0,
              run.artifactCount == 0,
              run.status == "completed",
              run.conclusion == "success",
              run.activeRootJob.orderedStepCount == 7,
              run.activeRootJob.successfulStepCount == 7,
              run.reviewedMainJob.orderedStepCount == 7,
              run.reviewedMainJob.successfulStepCount == 7,
              run.activeRootJob.conclusion == "success",
              run.reviewedMainJob.conclusion == "success",
              predecessor.stage5MechanicsExecuted,
              predecessor.stage5OneShotConsumed,
              predecessor.stage5LifecycleCompletedAndRetired,
              !predecessor.stage5ResultEstablished,
              !predecessor.stage5MechanicsSuccessEstablished,
              !predecessor.stage5AssayClearanceEstablished,
              !predecessor.repeatedTrajectoryDeterminismEstablished,
              !predecessor.exactMetalGradientBytesEstablished,
              !predecessor.metalDeterminismEstablished,
              !predecessor.stage5ReplacementExecutionAuthorized,
              predecessor.authorityClosureRunAttempt == 1,
              predecessor.authorityClosureArtifactCount == 0,
              predecessor.authorityClosureRerunCount == 0,
              predecessor.authorityClosureConclusion == "success",
              suite.isolatedTestCount
                == suite.isolatedGroupTestCounts.reduce(0, +),
              suite.focusedStepXCTestCount
                == suite.rootTestCount + suite.isolatedTestCount
                    + suite.focusedStage6PureContractXCTestCount,
              suite.liveStepXCTestCount
                == suite.metalTestCount
                    + suite.maintainedRuntimeTestCount
                    + suite.tokenizerTestCount
                    + suite.stage6LauncherPureContractXCTestCount,
              suite.totalXCTestCount
                == suite.focusedStepXCTestCount + suite.liveStepXCTestCount,
              suite.totalXCTestFailureCount == 0,
              suite.totalXCTestSkipCount == 0,
              suite.stage6LauncherInvocationCount == 1,
              suite.stage6BuildCount == 1,
              suite.stage6DirectXCTestCount == 1,
              suite.stage6DirectExecutableProbeCount == 1,
              suite.stage6ReceiptCount == 1,
              suite.stage6AggregateInvocationCount == 3,
              suite.exactLiveOrder
                == ["metal", "maintained_runtime", "tokenizer", "stage6"],
              suite.exactStage6InternalOrder
                == [
                    "stage6_pure_contract_xctest",
                    "stage6_resource_probe_executable",
                ],
              secureFetch.invocationCount == 1,
              secureFetch.completionCount == 1,
              secureFetch.authenticatedDepthOneFetchCount == 1,
              secureFetch.submoduleUpdateCount == 1,
              secureFetch.mlxCloneCount == 1,
              secureFetch.mlxCCloneCount == 1,
              zeroSecureFetchFailures.allSatisfy({ $0 == 0 }),
              metallib.byteCount == 6_292_716,
              metallib.sha256.count == 64,
              metallib.freshCandidateCount == 1,
              metallib.stagedCopyCount == 1,
              metallib.stagedPermissionMode == "444",
              !metallib.retainedAfterJob,
              !metallib.artifactUploadInvoked,
              receipt.anchoredOccurrenceCount == 1,
              receipt.totalOccurrenceCount == 1,
              receipt.rawJSONByteCount == 17_435,
              receipt.rawJSONLFByteCount == 0,
              receipt.rawJSONSHA256.count == 64,
              receipt.rawJSONWasCanonical,
              !receipt.rawJSONEndsWithLF,
              receipt.prefixedLineByteCount == 17_505,
              receipt.prefixedLineSHA256.count == 64,
              receipt.canonicalJSON.utf8.count == receipt.rawJSONByteCount,
              receipt.prefix.utf8.count + receipt.rawJSONByteCount
                == receipt.prefixedLineByteCount,
              lease.workerOwned,
              lease.acquiredNonblocking,
              lease.acquiredBeforeCoreGraphicsMetalOrMLX,
              lease.heldThroughCandidateFlush,
              lease.heldThroughPostflight,
              lease.supervisorReacquireReleaseProved,
              outcome.status == "PASS",
              outcome.classification == "pass",
              outcome.oneShotConsumed,
              outcome.workerCandidatePresent,
              outcome.resourceProbeExecuted,
              outcome.resourceEnvelopeEstablished,
              outcome.resourceClearanceEstablished,
              outcome.runnerMemoryCapacityEstablished,
              outcome.updateOccurred,
              outcome.parameterFingerprintBefore
                != outcome.parameterFingerprintAfter,
              outcome.parameterFingerprintSampleCount == 654,
              outcome.operationCounts.checkedEvaluationBarrierCount == 5,
              outcome.operationCounts.gpuSynchronizationBarrierCount == 5,
              outcome.operationCounts.evaluationForwardPassCount == 0,
              outcome.operationCounts.kvCacheAllocationCount == 0,
              phaseMetrics.map(\.phase)
                == [
                    "preflight",
                    "post_model_materialization",
                    "post_forward_backward",
                    "post_norm_clip",
                    "post_adam_update_full_evaluation",
                    "post_lexical_deallocation_and_clear_cache",
                ],
              phaseMetrics.allSatisfy({
                  $0.availability == "observed" && $0.unavailableReason == nil
              }),
              retirement.required,
              !retirement.observed,
              retirement.successfulAttemptConsumed,
              retirement.exactMainRetirementClosureRequired,
              retirement.exactChangedPaths
                == retirement.exactChangedPaths.sorted(),
              Set(retirement.exactChangedPaths).count == 5,
              retirement.expectedIsolatedTestCount
                == retirement.expectedIsolatedGroupTestCounts.reduce(0, +),
              retirement.expectedFocusedWholeTestCount
                == retirement.expectedRootTestCount
                    + retirement.expectedIsolatedTestCount,
              retirement.expectedTotalTestCount
                == retirement.expectedFocusedWholeTestCount
                    + retirement.expectedMetalTestCount
                    + retirement.expectedMaintainedRuntimeTestCount
                    + retirement.expectedTokenizerTestCount,
              retirement.expectedLiveOrder
                == ["metal", "maintained_runtime", "tokenizer"],
              retirement.expectedStage6LauncherInvocationCount == 0,
              retirement.expectedStage6ReceiptCount == 0,
              retirement.launcherSourcePreservedForAudit,
              ceiling.stage7RequiresStage5AssayAndStage6ResourceClearance,
              ceiling.stage5AssayClearanceMissingBlocksStage7,
              !ceiling.stage5AssayClearanceEstablished,
              !ceiling.stage7AuthorityEstablished,
              !ceiling.stage7Authorized,
              falseCeilings.allSatisfy({ !$0 }),
              try receiptJSONCrossBindingsHold()
        else {
            throw PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationError
                .contractDrift
        }
    }

    public func canonicalData() throws -> Data {
        try validateExactV1()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try value.canonicalData() == data else {
            throw PrimeNativeDecoderNative300MResourceOnlyOneStepProbeExecutionObservationError
                .nonCanonicalEncoding
        }
        return value
    }

    private func receiptJSONCrossBindingsHold() throws -> Bool {
        let data = Data(receipt.canonicalJSON.utf8)
        guard data.count == receipt.rawJSONByteCount,
              !data.contains(0x0A),
              let object = try JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else {
            return false
        }
        let canonical = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        guard canonical == data,
              int(object["schema_version"]) == receipt.schemaVersion,
              string(object["receipt_id"]) == receipt.receiptID,
              let authority = dictionary(object["authority"]),
              string(authority["authority_id"])
                == predecessor.stage6AuthorityID,
              string(authority["authority_canonical_sha256"])
                == predecessor.stage6AuthorityCanonicalSHA256,
              let execution = dictionary(object["execution"]),
              string(execution["repository"]) == run.repository,
              string(execution["mechanics_ref"]) == run.ref,
              string(execution["mechanics_head_revision"])
                == run.mergeRevision,
              string(execution["mechanics_head_tree"]) == run.mergeTree,
              strings(execution["mechanics_head_ordered_parent_revisions"])
                == run.orderedParentRevisions,
              int(execution["mechanics_run_id"]) == run.workflowRunID,
              int(execution["mechanics_run_number"])
                == run.workflowRunNumber,
              int(execution["mechanics_run_attempt"]) == run.runAttempt,
              int(execution["authority_closure_run_id"])
                == predecessor.authorityClosureRunID,
              int(execution["authority_closure_run_number"])
                == predecessor.authorityClosureRunNumber,
              int(execution["authority_closure_check_suite_id"])
                == predecessor.authorityClosureCheckSuiteID,
              string(execution["authority_closure_revision"])
                == predecessor.authorityClosureRevision,
              string(execution["authority_closure_tree"])
                == predecessor.authorityClosureTree,
              int(execution["build_count"]) == suite.stage6BuildCount,
              int(execution["direct_xctest_count"])
                == suite.stage6DirectXCTestCount,
              int(execution["direct_executable_probe_count"])
                == suite.stage6DirectExecutableProbeCount,
              int(execution["launcher_invocation_count"])
                == suite.stage6LauncherInvocationCount,
              let environment = dictionary(object["environment"]),
              string(environment["runtime_metallib_path"])
                == metallib.runtimePath,
              int(environment["runtime_metallib_byte_count"])
                == metallib.byteCount,
              string(environment["runtime_metallib_sha256"])
                == metallib.sha256,
              let receiptLease = dictionary(object["lease"]),
              string(receiptLease["type"]) == lease.type,
              string(receiptLease["lease_path"]) == lease.path,
              bool(receiptLease["worker_owned"]) == lease.workerOwned,
              bool(receiptLease["acquired_nonblocking"])
                == lease.acquiredNonblocking,
              bool(receiptLease["acquired_before_coregraphics_metal_or_mlx"])
                == lease.acquiredBeforeCoreGraphicsMetalOrMLX,
              bool(receiptLease["held_through_candidate_flush"])
                == lease.heldThroughCandidateFlush,
              bool(receiptLease["held_through_postflight"])
                == lease.heldThroughPostflight,
              bool(receiptLease["supervisor_reacquire_release_proved"])
                == lease.supervisorReacquireReleaseProved,
              let receiptLimits = dictionary(object["limits"]),
              uint64(receiptLimits["weights_logical_bytes"])
                == limits.weightsLogicalBytes,
              uint64(receiptLimits["gradient_logical_bytes"])
                == limits.gradientLogicalBytes,
              int(receiptLimits["optimizer_moment_tensor_count"])
                == limits.optimizerMomentTensorCount,
              uint64(receiptLimits["optimizer_moment_logical_bytes"])
                == limits.optimizerMomentLogicalBytes,
              uint64(receiptLimits["configured_memory_limit_bytes"])
                == limits.configuredMemoryLimitBytes,
              uint64(receiptLimits["available_filesystem_floor_bytes"])
                == limits.availableFilesystemFloorBytes,
              let receiptOutcome = dictionary(object["outcome"]),
              string(receiptOutcome["status"]) == outcome.status,
              string(receiptOutcome["classification"])
                == outcome.classification,
              bool(receiptOutcome["one_shot_consumed"])
                == outcome.oneShotConsumed,
              bool(receiptOutcome["resource_probe_executed"])
                == outcome.resourceProbeExecuted,
              bool(receiptOutcome["resource_envelope_established"])
                == outcome.resourceEnvelopeEstablished,
              bool(receiptOutcome["resource_clearance_established"])
                == outcome.resourceClearanceEstablished,
              bool(receiptOutcome["runner_memory_capacity_established"])
                == outcome.runnerMemoryCapacityEstablished,
              uint32(receiptOutcome["loss_float32_bits"])
                == outcome.lossFloat32Bits,
              uint32(receiptOutcome["raw_gradient_norm_float32_bits"])
                == outcome.rawGradientNormFloat32Bits,
              uint32(receiptOutcome["gradient_clip_scale_float32_bits"])
                == outcome.gradientClipScaleFloat32Bits,
              string(receiptOutcome["parameter_fingerprint_before"])
                == outcome.parameterFingerprintBefore,
              string(receiptOutcome["parameter_fingerprint_after"])
                == outcome.parameterFingerprintAfter,
              int(receiptOutcome["parameter_fingerprint_sample_count"])
                == outcome.parameterFingerprintSampleCount,
              let receiptPhases = object["phase_metrics"] as? [[String: Any]],
              receiptPhases.count == phaseMetrics.count,
              zip(receiptPhases, phaseMetrics).allSatisfy(phaseMatches),
              let receiptCeiling = dictionary(object["ceiling"]),
              receiptCeiling.count == 25,
              receiptCeiling.values.allSatisfy({ bool($0) == false })
        else {
            return false
        }
        return true
    }

    private func phaseMatches(
        _ pair: ([String: Any], PhaseMetric)
    ) -> Bool {
        let raw = pair.0
        let typed = pair.1
        return string(raw["phase"]) == typed.phase
            && string(raw["availability"]) == typed.availability
            && raw["unavailable_reason"] is NSNull
            && uint64(raw["cumulative_worker_probe_elapsed_nanoseconds"])
                == typed.cumulativeWorkerProbeElapsedNanoseconds
            && uint64(raw["physical_memory_capacity_bytes"])
                == typed.physicalMemoryCapacityBytes
            && uint64(raw["task_resident_bytes"])
                == typed.taskResidentBytes
            && uint64(raw["task_physical_footprint_bytes"])
                == typed.taskPhysicalFootprintBytes
            && uint64(raw["getrusage_max_rss_bytes"])
                == typed.getrusageMaxRSSBytes
            && uint64(raw["metal_current_allocated_bytes"])
                == typed.metalCurrentAllocatedBytes
            && uint64(raw["mlx_active_bytes"])
                == typed.mlxActiveBytes
            && uint64(raw["mlx_cache_bytes"])
                == typed.mlxCacheBytes
            && uint64(raw["mlx_peak_bytes"])
                == typed.mlxPeakBytes
            && uint64(raw["filesystem_capacity_bytes"])
                == typed.filesystemCapacityBytes
            && uint64(raw["filesystem_available_bytes"])
                == typed.filesystemAvailableBytes
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
