// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import CryptoKit
import Darwin
import Dispatch
import Foundation
import Metal
import MLX
import MLXNN
import MLXOptimizers
import PrimeCore
import PrimeNativeDecoder
import PrimeNativeDecoderCheckpoint

/// Stage-7's one-shot B-path checkpoint/restore execution, private process
/// transport, and pure public-receipt contract.
///
/// The launcher calls ``runSupervisor()`` exactly once.  The supervisor owns
/// the Metal lease, execs one worker and one post-release verifier, relays one
/// validated private candidate followed by one private terminal frame, and
/// never writes the public receipt prefix.  The shell launcher independently
/// projects and validates the public receipt and is its sole publisher.
public enum
    PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
{
    public static let authorityID =
        "prime_native_decoder_native300m_trajectory_checkpoint_execution_authority_v1"
    public static let authorityCanonicalSHA256 =
        "4d995b21a20424f1b05fbcb9fbe33780dbd7af03cbf68047270db4aae192caa4"

    public static let predecessorMainRevision =
        "912ca2ab8148255fa588a2a1d336b9dcb1221978"
    public static let authorityClosureRevision =
        "300bad298bc9ff6f2752d1409639ff9e99318db6"
    public static let authorityClosureTree =
        "d7c57b442e6c9a278b2ab58142ac86cbfa622930"
    public static let authorityClosureOrderedParents = [
        "912ca2ab8148255fa588a2a1d336b9dcb1221978",
        "11dd1e6098fba025cae8107284d2c231a9f2ebf8",
    ]
    public static let authorityClosureWorkflowRunID: UInt64 =
        31_871_108_399
    public static let authorityClosureWorkflowRunNumber: UInt64 = 127
    public static let authorityClosureRunAttempt: UInt64 = 1
    public static let authorityClosureCheckSuiteID: UInt64 =
        86_457_353_564
    public static let authorityClosureActiveJobID: UInt64 =
        94_979_749_298
    public static let authorityClosureReviewedJobID: UInt64 =
        94_980_086_476

    public static let candidateSchemaID =
        "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_candidate_v1"
    public static let terminalSchemaID =
        "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_internal_terminal_v1"
    public static let publicReceiptSchemaID =
        "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_receipt_v1"
    public static let publicReceiptPrefix =
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RECEIPT_V1="

    public static let candidateSchemaKeys = [
        "schema", "authority_and_predecessor_bindings",
        "implementation_inventory", "terminal_scientific_status",
        "one_shot", "environment", "device_and_stream",
        "operation_counts", "baseline_checkpoint_binding",
        "uninterrupted_comparator_binding", "resumed_comparator_binding",
        "comparison_domains", "first_mismatch", "resource_phases",
        "artifact_inventory_and_cleanup", "raw_private_paths",
    ]
    public static let terminalSchemaKeys = [
        "schema", "candidate_byte_count", "candidate_sha256",
        "candidate_status", "first_failed_guard", "lease_acquisition",
        "cleanup_and_absence", "release_verifier",
        "supervisor_integrity", "private_raw_descriptor_tuples",
    ]
    public static let publicReceiptSchemaKeys = [
        "schema", "authority_and_exact_main_bindings",
        "implementation_inventory", "terminal_status",
        "one_shot_consumed", "candidate_byte_count", "candidate_sha256",
        "terminal_byte_count", "terminal_sha256",
        "environment_and_device_bindings", "operation_counts",
        "comparison_domain_results", "first_mismatch_if_any",
        "resource_phases", "checkpoint_and_comparator_bindings",
        "artifact_cleanup_and_absence", "lease_and_verifier",
        "semantic_path_roles_and_path_sha256",
    ]

    public static let terminalStatusDomain = [
        "PASS_EXACT", "MEASURED_EXACT_MISMATCH", "ABSTAIN_RESOURCE",
        "ABSTAIN_INTEGRITY",
    ]
    public static let noPublicReceiptFailureClasses = [
        "malformed_private_candidate", "unsafe_private_candidate",
        "canonicalization_failure", "publication_failure",
        "unknown_artifact_inventory",
        "lease_unavailable_or_acquisition_failure_after_one_shot_consumption",
        "release_verifier_integrity_failure",
    ]
    public static let phaseNames = [
        "preflight", "post_initial_model_materialization",
        "post_baseline_step_and_evaluation",
        "post_baseline_gradient_release_and_baseline_four_leaf_publication",
        "post_uninterrupted_successor_step_and_evaluation",
        "post_uninterrupted_comparator_publication",
        "post_uninterrupted_state_deallocation_and_cache_clear",
        "post_fresh_weight_moment_and_control_restore",
        "post_resumed_successor_step_and_evaluation",
        "post_resumed_comparator_publication",
        "post_streaming_compare_artifact_cleanup_and_absence",
        "postflight",
    ]
    public static let comparisonDomainIDs = [
        "snapshot_weights",
        "snapshot_optimizer_first_moments",
        "snapshot_optimizer_second_moments",
        "snapshot_full_canonical_control_state_roundtrip",
        "batch2_token_and_mask_digest",
        "successor_loss_per_target_and_whole_logits_bits",
        "successor_raw_gradient_bytes",
        "successor_clipped_gradient_bytes", "successor_raw_norm_bits",
        "successor_clipped_global_norm_bits", "successor_clip_scale_bits",
        "successor_post_update_parameter_bytes",
        "successor_optimizer_first_moment_bytes",
        "successor_optimizer_second_moment_bytes",
        "successor_checked_evaluation_state_and_read_only_nonmutation",
        "optimizer_global_step_schedule_and_current_learning_rate_bits",
        "explicit_rng_algorithm_domain_key_counter_and_consumption_digest",
        "cursor_and_snapshot_boundary_zero_state",
    ]
    public static let fixedComparisonMemberPathsByDomainID: [String: [String]] = [
        "snapshot_full_canonical_control_state_roundtrip": [
            "role", "global_step", "schedule_id",
            "current_learning_rate_float32_bits", "rng_domains",
            "data_cursor", "snapshot_boundary",
            "checked_evaluation_complete", "accumulation_phase",
            "pending_gradient_count", "pending_prefetch_count",
            "kv_cache_entry_count", "decoder_training_mode_true",
        ],
        "batch2_token_and_mask_digest": ["token_and_mask_sha256"],
        "successor_loss_per_target_and_whole_logits_bits": [
            "loss_float32_bits",
            "per_target_loss_tensor_shape_1x127_float32",
            "whole_logits_tensor_shape_1x128x512_float32",
        ],
        "successor_raw_norm_bits": ["raw_norm_float32_bits"],
        "successor_clipped_global_norm_bits": [
            "clipped_global_norm_float32_bits",
        ],
        "successor_clip_scale_bits": ["clip_scale_float32_bits"],
        "successor_checked_evaluation_state_and_read_only_nonmutation": [
            "loss_float32_bits",
            "per_target_loss_tensor_shape_1x127_float32",
            "whole_logits_tensor_shape_1x128x512_float32",
            "pre_model_catalog_binding", "post_model_catalog_binding",
            "pre_post_optimizer_catalog_binding",
            "pre_post_control_binding", "training_mode_restored_true",
        ],
        "optimizer_global_step_schedule_and_current_learning_rate_bits": [
            "global_step", "initial_global_step", "snapshot_global_step",
            "schedule_id", "current_learning_rate_float32_bits",
        ],
        "explicit_rng_algorithm_domain_key_counter_and_consumption_digest": [
            "rng_domains.model_initialization_v1",
            "rng_domains.training_data_order_v1",
            "rng_domains.augmentation_v1", "rng_domains.evaluation_v1",
        ],
        "cursor_and_snapshot_boundary_zero_state": [
            "terminal_data_cursor", "accumulation_phase",
            "pending_gradient_count", "pending_prefetch_count",
            "kv_cache_entry_count", "snapshot_boundary_consumed_once",
            "evaluation_did_not_advance_cursor",
            "decoder_training_mode_true",
        ],
    ]
    /// Exhaustive mapping of the 19 persisted comparator-control fields
    /// (everything except the deliberately role-specific `branch_role`) onto
    /// the scientific comparison domain whose evidence that field projects.
    public static let comparatorControlFieldToDomainID: [String: String] = [
        "loss_float32_bits":
            "successor_loss_per_target_and_whole_logits_bits",
        "per_target_loss_topology_and_sha256":
            "successor_loss_per_target_and_whole_logits_bits",
        "whole_logits_topology_and_sha256":
            "successor_loss_per_target_and_whole_logits_bits",
        "raw_gradient_catalog_topology_and_sha256":
            "successor_raw_gradient_bytes",
        "clipped_gradient_catalog_topology_and_sha256":
            "successor_clipped_gradient_bytes",
        "raw_norm_float32_bits": "successor_raw_norm_bits",
        "clipped_norm_float32_bits": "successor_clipped_global_norm_bits",
        "clip_scale_float32_bits": "successor_clip_scale_bits",
        "post_update_parameter_catalog_binding":
            "successor_post_update_parameter_bytes",
        "optimizer_first_moment_catalog_binding":
            "successor_optimizer_first_moment_bytes",
        "optimizer_second_moment_catalog_binding":
            "successor_optimizer_second_moment_bytes",
        "checked_evaluation_binding":
            "successor_checked_evaluation_state_and_read_only_nonmutation",
        "checked_evaluation_read_only_nonmutation_binding":
            "successor_checked_evaluation_state_and_read_only_nonmutation",
        "global_step":
            "optimizer_global_step_schedule_and_current_learning_rate_bits",
        "schedule_id":
            "optimizer_global_step_schedule_and_current_learning_rate_bits",
        "current_learning_rate_float32_bits":
            "optimizer_global_step_schedule_and_current_learning_rate_bits",
        "rng_domains":
            "explicit_rng_algorithm_domain_key_counter_and_consumption_digest",
        "terminal_data_cursor": "cursor_and_snapshot_boundary_zero_state",
        "decoder_training_mode_true":
            "cursor_and_snapshot_boundary_zero_state",
    ]
    public static let operationCountKeys = [
        "training_step_count", "backward_count", "optimizer_update_count",
        "dense_b_path_logits_call_count", "token_bounds_validation_count",
        "token_bounds_checked_eval_count",
        "token_bounds_gpu_synchronize_count",
        "token_bounds_host_bool_item_count",
        "dense_one_hot_matmul_construction_count",
        "gradient_evidence_capture_count", "gradient_catalog_release_count",
        "resource_measurement_checked_eval_count",
        "resource_measurement_synchronize_count",
        "checked_read_only_evaluation_count",
        "evaluation_forward_pass_count", "forward_loss_count",
        "cross_entropy_count", "training_mode_disable_count",
        "training_mode_restore_count", "v2_weights_write_count",
        "v2_internal_verification_load_count", "public_restore_load_count",
        "optimizer_moment_publish_count",
        "deferred_optimizer_moment_load_count", "leaf_publication_count",
        "final_commit_publication_count",
        "model_allocation_and_materialization_count",
        "optimizer_allocation_count", "typed_optimizer_state_import_count",
        "worker_process_count", "supervisor_process_count",
        "release_verifier_process_count", "maximum_public_receipt_count",
    ]
    public static let exactOperationCounts: [String: UInt64] = [
        "training_step_count": 3, "backward_count": 3,
        "optimizer_update_count": 3, "dense_b_path_logits_call_count": 6,
        "token_bounds_validation_count": 6,
        "token_bounds_checked_eval_count": 6,
        "token_bounds_gpu_synchronize_count": 6,
        "token_bounds_host_bool_item_count": 6,
        "dense_one_hot_matmul_construction_count": 6,
        "gradient_evidence_capture_count": 2,
        "gradient_catalog_release_count": 3,
        "resource_measurement_checked_eval_count": 8,
        "resource_measurement_synchronize_count": 12,
        "checked_read_only_evaluation_count": 3,
        "evaluation_forward_pass_count": 3, "forward_loss_count": 6,
        "cross_entropy_count": 6, "training_mode_disable_count": 3,
        "training_mode_restore_count": 3, "v2_weights_write_count": 3,
        "v2_internal_verification_load_count": 3,
        "public_restore_load_count": 1,
        "optimizer_moment_publish_count": 3,
        "deferred_optimizer_moment_load_count": 1,
        "leaf_publication_count": 12,
        "final_commit_publication_count": 3,
        "model_allocation_and_materialization_count": 5,
        "optimizer_allocation_count": 2,
        "typed_optimizer_state_import_count": 1, "worker_process_count": 1,
        "supervisor_process_count": 1, "release_verifier_process_count": 1,
        "maximum_public_receipt_count": 1,
    ]

    public static let checkpointBindingKeys = [
        "set_role", "load_authoritative", "commit_schema",
        "commit_byte_count", "commit_sha256", "leaf_count",
        "ordered_leaf_roles", "each_leaf_byte_count_and_sha256",
        "external_v2_binding", "control_schema_and_sha256",
    ]
    public static let comparisonDomainResultKeys = [
        "domain_id", "kind", "path_count", "catalog_preimage_schema",
        "catalog_sha256", "left_total_bytes", "left_sha256",
        "right_total_bytes", "right_sha256", "exact",
        "first_mismatch_path", "first_mismatch_expected_binding",
        "first_mismatch_observed_binding", "tensor_catalog_projection",
    ]
    public static let tensorCatalogProjectionKeys = [
        "algorithm_id", "sorted_unique_path_count",
        "shape_dtype_element_and_byte_count_preimage_sha256",
        "canonical_logical_bytes_preimage_sha256", "total_element_count",
        "total_logical_byte_count", "first_mismatch_path_if_any",
    ]
    public static let resourcePhaseKeys = [
        "phase_id", "cumulative_elapsed_nanoseconds",
        "physical_memory_capacity_bytes", "task_resident_bytes",
        "task_physical_footprint_bytes", "getrusage_max_rss_bytes",
        "mlx_active_bytes", "mlx_cache_bytes", "mlx_peak_bytes",
        "metal_current_allocated_bytes", "filesystem_fsid",
        "filesystem_semantic_role", "filesystem_path_sha256",
        "filesystem_capacity_bytes", "filesystem_available_bytes",
        "verified_configured_memory_limit_copied_from_preflight_bytes",
        "verified_configured_cache_limit_copied_from_preflight_bytes",
    ]
    public static let artifactCleanupKeys = [
        "initial_inventory_empty", "known_inventory_before_cleanup",
        "unknown_inventory_count", "deleted_known_leaf_count",
        "deleted_private_comparator_count", "post_cleanup_inventory_empty",
        "absence_proved", "recursive_cleanup_used", "artifact_upload_count",
        "retained_artifact_count",
    ]
    public static let firstMismatchKeys = [
        "availability", "domain_id", "path", "expected_binding",
        "observed_binding",
    ]
    public static let authorityAndExactMainBindingKeys = [
        "authority_id", "authority_canonical_sha256", "repository",
        "revision", "tree", "ordered_parents", "workflow_run_id",
        "workflow_run_number", "run_attempt",
    ]
    public static let leaseAndVerifierKeys = [
        "lease_acquired", "lease_release_count", "verifier_executed",
        "verifier_exit_zero", "supervisor_alive_during_verifier",
        "preflight_parent", "post_candidate_parent", "post_candidate_leaf",
        "verifier_parent", "verifier_leaf", "inventory_exact",
    ]
    public static let semanticPathProjectionKeys = [
        "semantic_role", "path_sha256", "byte_count", "content_sha256",
        "raw_absolute_path_present",
    ]
    public static let environmentAndDeviceReceiptKeys = [
        "mlx_enable_tf32", "mlx_checkout_origin", "mlx_revision",
        "swiftpm_configuration", "graph_mode", "compile_transform_count",
        "os_build", "xcode_build", "swift_driver", "swift_sdk",
        "staged_metallib_role", "staged_metallib_path_sha256",
        "staged_metallib_byte_count_and_content_sha256",
        "runtime_metallib_role", "runtime_metallib_path_sha256",
        "runtime_metallib_byte_count_and_content_sha256",
        "metal_name_registry_unified_max_buffer_recommended_set",
        "mlx_device_and_default_gpu_stream", "stream_order",
        "evaluation_order", "pre_post_identity_and_policy_equal",
        "root_and_validation_lock_bindings",
    ]
    public static let publicDescriptorTupleKeys = [
        "semantic_role", "path_sha256", "device_id", "inode", "uid", "gid",
        "mode", "acl_entry_count", "xattr_names", "security_flags",
        "file_type", "byte_count", "observed_nlink",
    ]
    public static let lockBindingKeys = [
        "path_role", "git_blob", "byte_count", "sha256",
    ]
    public static let byteCountAndSHA256Keys = ["byte_count", "sha256"]
    public static let metalDeviceReceiptKeys = [
        "name", "registry_id", "has_unified_memory", "max_buffer_length",
        "recommended_max_working_set_size",
    ]
    public static let mlxDeviceAndStreamReceiptKeys = [
        "device", "default_stream",
    ]
    public static let publicDescriptorSemanticRoles = [
        "preflight_parent", "post_candidate_parent", "post_candidate_leaf",
        "verifier_parent", "verifier_leaf",
    ]
    public static let semanticPathRoles = [
        "lease_root", "lease_path", "artifact_root", "staged_metallib",
        "runtime_metallib",
    ]

    public static let authorityAndPredecessorBindingKeys = [
        "authority_id", "authority_canonical_sha256", "repository",
        "predecessor_main_revision", "authority_closure_revision",
        "authority_closure_tree", "authority_closure_ordered_parents",
        "authority_closure_run_id", "authority_closure_run_number",
        "authority_closure_run_attempt", "authority_closure_check_suite_id",
        "authority_closure_active_job_id",
        "authority_closure_reviewed_job_id", "stage5_b_observation_sha256",
        "b_resource_observation_sha256", "mechanics_revision",
        "mechanics_tree", "mechanics_ordered_parents", "mechanics_run_id",
        "mechanics_run_number", "mechanics_run_attempt",
    ]
    public static let oneShotKeys = [
        "consumed", "opportunity_count", "retry_authorized",
        "rerun_authorized", "replacement_authorized",
    ]
    public static let environmentKeys = [
        "mlx_enable_tf32", "mlx_checkout_origin", "mlx_revision",
        "swiftpm_configuration", "graph_mode", "compile_transform_count",
        "operating_system_build", "xcode_build", "swift_driver",
        "swift_sdk", "staged_metallib", "runtime_metallib",
    ]
    public static let deviceAndStreamKeys = [
        "metal_device_count", "metal_device_index", "metal_device_name",
        "metal_device_registry_id", "metal_device_is_default",
        "metal_device_has_unified_memory",
        "metal_device_max_buffer_length_bytes",
        "metal_device_recommended_max_working_set_bytes", "mlx_device_type",
        "mlx_device_index", "mlx_default_device_is_supplied_device",
        "mlx_default_stream_is_gpu", "cpu_fallback_used", "stream_order",
        "evaluation_order", "configured_memory_limit_bytes",
        "configured_cache_limit_bytes", "pre_post_identity_and_policy_equal",
    ]
    public static let rawPrivatePathKeys = [
        "lease_root", "lease_path", "artifact_root",
        "staged_metallib_path", "runtime_metallib_path",
    ]
    public static let firstFailedGuardKeys = [
        "availability", "guard_id", "classification", "errno", "detail",
    ]
    public static let leaseAcquisitionKeys = [
        "acquired", "nonblocking", "supervisor_owned",
        "worker_inherited_descriptor_count",
        "held_through_cleanup_and_postflight",
    ]
    public static let cleanupAndAbsenceKeys = [
        "known_leaf_count", "deleted_leaf_count", "unknown_inventory_count",
        "post_cleanup_empty", "absence_proved", "recursive_cleanup_used",
    ]
    public static let releaseVerifierKeys = [
        "executed", "exit_zero", "supervisor_alive", "acquire_count",
        "release_count",
    ]
    public static let supervisorIntegrityKeys = [
        "candidate_validated", "stdout_candidate_then_terminal",
        "post_candidate_inventory_exact", "lease_released_explicitly",
        "terminal_canonical",
    ]
    public static let privateRawDescriptorTupleKeys = [
        "preflight_parent", "post_candidate_parent", "post_candidate_leaf",
        "verifier_parent", "verifier_leaf",
    ]
    public static let metallibBindingKeys = [
        "semantic_role", "path_sha256", "byte_count", "content_sha256",
    ]
    public static let checkpointLeafBindingKeys = [
        "role", "publication_ordinal", "byte_count", "sha256",
    ]
    public static let externalV2ProjectionKeys = [
        "schema_id", "compatibility_identity_sha256",
        "artifact_semantic_role", "artifact_path_sha256",
        "container_byte_count", "container_sha256", "manifest_sha256",
    ]
    public static let controlStateProjectionKeys = [
        "schema_id", "canonical_byte_count", "sha256",
    ]
    public static let filesystemIDKeys = ["word0", "word1"]
    public static let privateParentDescriptorTupleKeys = [
        "physical_path", "device_id", "inode", "uid", "gid", "mode", "acl",
        "xattr_names", "security_flags", "file_type", "observed_nlink",
    ]
    public static let privateLeaseDescriptorTupleKeys = [
        "device_id", "inode", "uid", "gid", "mode", "acl", "xattr_names",
        "security_flags", "file_type", "byte_count", "observed_nlink",
    ]

    public static let environmentVariableNames = [
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_EXECUTABLE_PATH",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_LEASE_ROOT",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_ARTIFACT_ROOT",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_STAGED_METALLIB_PATH",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_STAGED_METALLIB_BYTES",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_STAGED_METALLIB_SHA256",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RUNTIME_METALLIB_PATH",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RUNTIME_METALLIB_BYTES",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RUNTIME_METALLIB_SHA256",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_OPERATING_SYSTEM_BUILD",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_XCODE_BUILD",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_SWIFT_DRIVER",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_SWIFT_SDK",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_BUILD_CONFIGURATION",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_EXACT_MLX_ORIGIN",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_EXACT_MLX_REVISION",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_ID",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CANONICAL_SHA256",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_REVISION",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_TREE",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_ORDERED_PARENTS_JSON",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_RUN_ID",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_RUN_NUMBER",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_RUN_ATTEMPT",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_CHECK_SUITE_ID",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_ACTIVE_JOB_ID",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_AUTHORITY_CLOSURE_REVIEWED_JOB_ID",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_REVISION",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_TREE",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_ORDERED_PARENTS_JSON",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_RUN_ID",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_RUN_NUMBER",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_MECHANICS_RUN_ATTEMPT",
        "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_IMPLEMENTATION_INVENTORY_JSON",
    ]

    public static let workerArgument = "--trajectory-worker"
    public static let verifierArgument = "--release-verifier"
    public static let workerFrameDescriptor: Int32 = 19
    public static let maximumPrivateCandidateCanonicalByteCount = 262_144
    public static let maximumPrivateTerminalCanonicalByteCount = 65_536
    public static let maximumPublicCanonicalByteCount = 131_072
    public static let maximumFrameChunkByteCount = 16_384
    public static let frameReadDeadlineSeconds: UInt64 = 30
    public static let workerTimeoutSeconds: UInt64 = 4_800
    public static let supervisorTimeoutSeconds: UInt64 = 5_100
    public static let terminationGraceSeconds: UInt64 = 10
    public static let maximalPublicReceiptCanonicalByteCount = 54_022

    public static func validatePureContractV1() throws {
        let authority =
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                .frozenV1
        try authority.validateExactV1()
        try trajectoryRequire(
            authorityCanonicalSHA256
                == PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                    .canonicalSHA256,
            "authority canonical SHA-256")
        try trajectoryRequire(
            authority.authorityID == authorityID,
            "authority ID")
        try trajectoryRequire(
            authority.checkpoint.schemaID
                == PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .checkpointSchemaID
                && authority.checkpoint.externalCommitBindingSchemaID
                    == PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                        .externalCommitBindingSchemaID,
            "checkpoint schemas")
        try trajectoryRequire(
            authority.successor.checkpointCodecMomentValueType
                == "[String: MLXArray]"
                && authority.successor.optimizerTypedMappingOwner
                    == "PrimeNativeDecoderTraining",
            "neutral moment boundary")
        try trajectoryRequire(
            candidateSchemaID == authority.integrity.privateCandidateSchemaID
                && terminalSchemaID
                    == authority.integrity.privateTerminalSchemaID
                && publicReceiptSchemaID
                    == authority.integrity.publicReceiptSchemaID
                && publicReceiptPrefix
                    == authority.integrity.publicReceiptPrefix,
            "private and public schema IDs")
        try trajectoryRequire(
            candidateSchemaKeys
                == authority.integrity.requiredPrivateCandidateFields
                && terminalSchemaKeys
                    == authority.integrity.requiredPrivateTerminalFields
                && publicReceiptSchemaKeys
                    == authority.integrity.requiredPublicReceiptFields,
            "top-level schemas")
        try trajectoryRequire(
            phaseNames == authority.resource.requiredPhaseIDs
                && comparisonDomainIDs
                    == authority.comparison.domains.map(\.id)
                && operationCountKeys
                    == authority.integrity.operationCountReceiptFields,
            "ordered science vocabularies")
        let fixedDomainIndices = [3, 4, 5, 8, 9, 10, 14, 15, 16, 17]
        let fixedDomainIDs = Set(fixedDomainIndices.map {
            authority.comparison.domains[$0].id
        })
        try trajectoryRequire(
            Set(fixedComparisonMemberPathsByDomainID.keys)
                == fixedDomainIDs
                && fixedDomainIndices.allSatisfy { index in
                    let domain = authority.comparison.domains[index]
                    guard let paths =
                            fixedComparisonMemberPathsByDomainID[domain.id]
                    else { return false }
                    return paths.count == domain.expectedPathCount
                        && Set(paths).count == paths.count
                        && paths.allSatisfy { !$0.isEmpty }
                },
            "fixed comparison member path closure")
        let persistedControlFields = Set(
            authority.checkpoint.comparatorControlRequiredFields.filter {
                $0 != "branch_role"
            })
        try trajectoryRequire(
            comparatorControlFieldToDomainID.count == 19
                && Set(comparatorControlFieldToDomainID.keys)
                    == persistedControlFields
                && comparatorControlFieldToDomainID.values.allSatisfy {
                    comparisonDomainIDs.contains($0)
                },
            "persisted comparator control field-to-domain closure")
        try trajectoryRequire(
            checkpointBindingKeys
                == authority.integrity.checkpointSetBindingFields
                && comparisonDomainResultKeys
                    == authority.integrity.comparisonDomainResultFields
                && resourcePhaseKeys
                    == authority.integrity.resourcePhaseRecordFields
                && artifactCleanupKeys
                    == authority.integrity.artifactCleanupReceiptFields
                && environmentAndDeviceReceiptKeys
                    == authority.integrity.environmentAndDeviceReceiptFields
                && publicDescriptorTupleKeys
                    == authority.integrity.publicDescriptorTupleFields
                && lockBindingKeys
                    == authority.integrity.lockBindingFields
                && privateParentDescriptorTupleKeys
                    == authority.integrity.descriptorDerivedParentTupleFields
                && privateLeaseDescriptorTupleKeys
                    == authority.integrity.descriptorDerivedLeaseTupleFields,
            "nested schemas")
        try trajectoryRequire(
            terminalStatusDomain == authority.outcomes.allowedTerminalStatuses
                && noPublicReceiptFailureClasses
                    == authority.outcomes.noPublicReceiptFailureClasses,
            "outcome domains")
        try trajectoryRequire(
            maximumPrivateCandidateCanonicalByteCount
                == authority.integrity
                    .maximumPrivateCandidateCanonicalByteCount
                && maximumPrivateTerminalCanonicalByteCount
                    == authority.integrity
                        .maximumPrivateTerminalCanonicalByteCount
                && maximumPublicCanonicalByteCount
                    == authority.integrity.maximumPublicCanonicalByteCount
                && maximumFrameChunkByteCount
                    == authority.integrity.maximumFrameChunkByteCount
                && frameReadDeadlineSeconds
                    == UInt64(authority.integrity.frameReadDeadlineSeconds),
            "transport caps")
        try trajectoryRequire(
            workerTimeoutSeconds
                == UInt64(authority.successor.workerTimeoutSeconds)
                && supervisorTimeoutSeconds
                    == UInt64(authority.successor.supervisorTimeoutSeconds)
                && terminationGraceSeconds
                    == UInt64(authority.successor.terminationGraceSeconds)
                && maximalPublicReceiptCanonicalByteCount
                    == authority.integrity
                        .maximalPublicReceiptFixtureCanonicalByteCount,
            "execution and fixture caps")
        try trajectoryRequire(
            exactOperationCounts.count == operationCountKeys.count
                && Set(exactOperationCounts.keys) == Set(operationCountKeys),
            "exact operation key set")
        try trajectoryRequire(
            authorityClosureRevision
                == "300bad298bc9ff6f2752d1409639ff9e99318db6"
                && authorityClosureTree
                    == "d7c57b442e6c9a278b2ab58142ac86cbfa622930"
                && authorityClosureOrderedParents == [
                    predecessorMainRevision,
                    "11dd1e6098fba025cae8107284d2c231a9f2ebf8",
                ]
                && authorityClosureWorkflowRunID == 31_871_108_399
                && authorityClosureWorkflowRunNumber == 127
                && authorityClosureRunAttempt == 1
                && authorityClosureCheckSuiteID == 86_457_353_564
                && authorityClosureActiveJobID == 94_979_749_298
                && authorityClosureReviewedJobID == 94_980_086_476,
            "terminal predecessor authority closure")
        try trajectoryRequire(
            environmentVariableNames.count == 34
                && Set(environmentVariableNames).count == 34,
            "launcher environment vocabulary")
        let fixture = try maximalPublicReceiptFixtureCanonicalDataV1()
        try trajectoryRequire(
            fixture.count == maximalPublicReceiptCanonicalByteCount,
            "maximal public receipt fixture byte count")
    }

    /// Converts typed MLXOptimizers state to the neutral role-prefixed catalog
    /// owned by the checkpoint target.  Exact path, shape, dtype, and topology
    /// checks occur before any array is returned.
    public static func neutralMomentCatalog(
        from state: AdamOptimizerState,
        matching modelParameters: ModuleParameters
    ) throws -> [String: MLXArray] {
        let target = try exactCatalog(
            modelParameters,
            scope: "target model parameters")
        let first = try exactCatalog(
            state.firstMoment,
            scope: "Adam first moment")
        let second = try exactCatalog(
            state.secondMoment,
            scope: "Adam second moment")
        try validateMomentCatalogs(
            first: first,
            second: second,
            target: target)
        var result = [String: MLXArray]()
        result.reserveCapacity(target.count * 2)
        for path in target.keys.sorted(by: trajectoryRawUTF8Less) {
            result[
                PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .firstMomentStoragePrefix + path
            ] = first[path]!.reshaped(first[path]!.shape)
            result[
                PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .secondMomentStoragePrefix + path
            ] = second[path]!.reshaped(second[path]!.shape)
        }
        return result
    }

    /// Converts a neutral checkpoint catalog back into typed Adam state.
    /// The returned state is still imported only through the public strict
    /// `Adam.update(parameters:matching:)` API on a fresh optimizer.
    public static func typedAdamState(
        from neutralCatalog: [String: MLXArray],
        matching modelParameters: ModuleParameters
    ) throws -> AdamOptimizerState {
        let target = try exactCatalog(
            modelParameters,
            scope: "restored model parameters")
        var first = [String: MLXArray]()
        var second = [String: MLXArray]()
        for (key, array) in neutralCatalog {
            if key.hasPrefix(
                PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .firstMomentStoragePrefix)
            {
                let path = String(key.dropFirst(
                    PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                        .firstMomentStoragePrefix.count))
                try trajectoryRequire(
                    !path.isEmpty
                        && first.updateValue(array, forKey: path) == nil,
                    "duplicate or empty first-moment path")
            } else if key.hasPrefix(
                PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .secondMomentStoragePrefix)
            {
                let path = String(key.dropFirst(
                    PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                        .secondMomentStoragePrefix.count))
                try trajectoryRequire(
                    !path.isEmpty
                        && second.updateValue(array, forKey: path) == nil,
                    "duplicate or empty second-moment path")
            } else {
                throw TrajectoryExecutionError.contract(
                    "unknown neutral moment role")
            }
        }
        try validateMomentCatalogs(
            first: first,
            second: second,
            target: target)
        let state = AdamOptimizerState(
            firstMoment: ModuleParameters.unflattened(first.map {
                ($0.key, $0.value.reshaped($0.value.shape))
            }),
            secondMoment: ModuleParameters.unflattened(second.map {
                ($0.key, $0.value.reshaped($0.value.shape))
            }))
        return state
    }

    public static func canonicalPublicReceiptDataV1(
        _ object: [String: Any]
    ) throws -> Data {
        let data = try trajectoryCanonicalJSONData(object)
        try validateCanonicalPublicReceiptDataV1(data)
        return data
    }

    public static func validateCanonicalPublicReceiptDataV1(
        _ data: Data
    ) throws {
        guard !data.isEmpty,
              data.count <= maximumPublicCanonicalByteCount,
              !data.contains(0x0a), !data.contains(0x0d),
              let object = try trajectoryCanonicalJSONObject(data)
                as? [String: Any],
              Set(object.keys) == Set(publicReceiptSchemaKeys),
              object["schema"] as? String == publicReceiptSchemaID,
              let status = object["terminal_status"] as? String,
              terminalStatusDomain.contains(status),
              trajectoryExactBool(object["one_shot_consumed"]) == true,
              let authority = object["authority_and_exact_main_bindings"]
                as? [String: Any],
              trajectoryValidExactMainBinding(authority),
              let inventory = object["implementation_inventory"]
                as? [[String: Any]],
              try trajectoryInventoryEqualsFrozenAuthority(inventory),
              let environment = object["environment_and_device_bindings"]
                as? [String: Any],
              trajectoryValidEnvironmentAndDeviceReceipt(
                  environment,
                  inventory: inventory),
              let counts = object["operation_counts"] as? [String: Any],
              trajectoryValidOperationCounts(counts, status: status),
              let domains = object["comparison_domain_results"]
                as? [[String: Any]],
              let mismatch = object["first_mismatch_if_any"]
                as? [String: Any],
              trajectoryValidDomainOutcome(
                  domains,
                  mismatch: mismatch,
                  status: status),
              let phases = object["resource_phases"] as? [[String: Any]],
              trajectoryValidResourcePhases(
                  phases,
                  status: status,
                  mismatch: mismatch),
              let checkpoints = object[
                  "checkpoint_and_comparator_bindings"] as? [[String: Any]],
              trajectoryValidCheckpointOutcome(
                  checkpoints,
                  status: status),
              let cleanup = object["artifact_cleanup_and_absence"]
                as? [String: Any],
              trajectoryValidArtifactCleanup(cleanup, status: status),
              let lease = object["lease_and_verifier"] as? [String: Any],
              trajectoryValidLeaseAndVerifier(lease),
              let paths = object["semantic_path_roles_and_path_sha256"]
                as? [[String: Any]],
              trajectoryValidSemanticPaths(paths),
              let candidateByteCount = trajectoryExactUInt64(
                  object["candidate_byte_count"]),
              candidateByteCount > 0,
              candidateByteCount
                <= UInt64(maximumPrivateCandidateCanonicalByteCount),
              (object["candidate_sha256"] as? String).map({
                  trajectoryIsLowerHex($0, count: 64)
              }) == true,
              let terminalByteCount = trajectoryExactUInt64(
                  object["terminal_byte_count"]),
              terminalByteCount > 0,
              terminalByteCount
                <= UInt64(maximumPrivateTerminalCanonicalByteCount),
              (object["terminal_sha256"] as? String).map({
                  trajectoryIsLowerHex($0, count: 64)
              }) == true,
              !trajectoryContainsRawAbsolutePath(object)
        else {
            throw TrajectoryExecutionError.contract(
                "invalid canonical public receipt")
        }
        let checkpointCount = UInt64(checkpoints.count)
        let knownLeafCount = trajectoryExactUInt64(
            cleanup["known_inventory_before_cleanup"])!
        let expectedComparatorCount = knownLeafCount == 0
            ? 0 : (knownLeafCount - 1) / 4
        let measuredDomainPrefixCount = domains.prefix {
            trajectoryExactBool($0["exact"]) != nil
        }.count
        let privateCandidateDomainCount = status == "ABSTAIN_INTEGRITY"
            ? min(18, measuredDomainPrefixCount + 1)
            : measuredDomainPrefixCount
        try trajectoryRequire(
            checkpointCount == knownLeafCount / 4
                && trajectoryExactUInt64(
                    cleanup["deleted_known_leaf_count"])
                    == knownLeafCount
                && trajectoryExactUInt64(
                    cleanup["deleted_private_comparator_count"])
                    == expectedComparatorCount,
            "public checkpoint/cleanup exact cross-binding")
        try trajectoryRequire(
            trajectoryValidPhaseDependencies(
                counts,
                phaseCount: phases.count,
                checkpointCount: checkpoints.count,
                domainCount: privateCandidateDomainCount,
                status: status,
                mismatch: mismatch),
            "public operation/phase/checkpoint/domain dependency prefix")
    }

    public static func maximalPublicReceiptFixtureCanonicalDataV1()
        throws -> Data
    {
        var object = trajectoryMaximalPublicReceiptFixture()
        var environment = object["environment_and_device_bindings"]
            as! [String: Any]
        environment["swift_driver"] = ""
        object["environment_and_device_bindings"] = environment
        let base = try trajectoryCanonicalJSONData(object)
        let paddingCount = maximalPublicReceiptCanonicalByteCount - base.count
        try trajectoryRequire(paddingCount >= 0, "maximal fixture base size")
        environment["swift_driver"] = String(
            repeating: "x",
            count: paddingCount)
        object["environment_and_device_bindings"] = environment
        let data = try trajectoryCanonicalJSONData(object)
        try trajectoryRequire(
            data.count == maximalPublicReceiptCanonicalByteCount,
            "maximal fixture exact byte count")
        try validateCanonicalPublicReceiptDataV1(data)
        return data
    }
}

private enum TrajectoryExecutionError: Error, CustomStringConvertible {
    case contract(String)
    case posix(String, Int32)
    case classified(String, String)

    var description: String {
        switch self {
        case .contract(let detail): return "contract: \(detail)"
        case .posix(let operation, let code):
            return "\(operation): \(String(cString: strerror(code)))"
        case .classified(let classification, let detail):
            return "\(classification): \(detail)"
        }
    }
}

private func trajectoryRequire(
    _ condition: @autoclosure () -> Bool,
    _ detail: String
) throws {
    guard condition() else {
        throw TrajectoryExecutionError.contract(detail)
    }
}

private func trajectoryRawUTF8Less(_ lhs: String, _ rhs: String) -> Bool {
    lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
}

private func trajectoryIsLowerHex(_ value: String, count: Int) -> Bool {
    value.utf8.count == count && value.utf8.allSatisfy {
        ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
    }
}

private func trajectoryExactUInt64(_ value: Any?) -> UInt64? {
    guard let number = value as? NSNumber,
          CFGetTypeID(number) != CFBooleanGetTypeID()
    else { return nil }
    let decimal = number.stringValue
    guard !decimal.isEmpty,
          !decimal.hasPrefix("-"),
          !decimal.contains("."),
          !decimal.contains("e"),
          !decimal.contains("E"),
          decimal == "0" || !decimal.hasPrefix("0")
    else { return nil }
    return UInt64(decimal)
}

private func trajectoryExactBool(_ value: Any?) -> Bool? {
    guard let number = value as? NSNumber,
          CFGetTypeID(number) == CFBooleanGetTypeID()
    else { return nil }
    return number.boolValue
}

private func trajectoryCanonicalJSONData(_ object: Any) throws -> Data {
    guard JSONSerialization.isValidJSONObject(object) else {
        throw TrajectoryExecutionError.contract("JSON object")
    }
    return try JSONSerialization.data(
        withJSONObject: object,
        options: [.sortedKeys, .withoutEscapingSlashes])
}

private func trajectoryCanonicalJSONObject(_ data: Data) throws -> Any {
    let object = try JSONSerialization.jsonObject(with: data)
    guard try trajectoryCanonicalJSONData(object) == data else {
        throw TrajectoryExecutionError.contract("canonical JSON")
    }
    return object
}

private func trajectoryValidImplementationIdentity(
    _ value: [String: Any]
) -> Bool {
    Set(value.keys) == [
        "path_role", "git_mode", "git_blob", "byte_count",
        "lf_byte_count", "sha256",
    ]
        && !(value["path_role"] as? String ?? "").isEmpty
        && ["100644", "100755"].contains(value["git_mode"] as? String ?? "")
        && ((value["git_blob"] as? String).map {
            trajectoryIsLowerHex($0, count: 40)
        } ?? false)
        && trajectoryExactUInt64(value["byte_count"]) != nil
        && trajectoryExactUInt64(value["lf_byte_count"]) != nil
        && ((value["sha256"] as? String).map {
            trajectoryIsLowerHex($0, count: 64)
        } ?? false)
}

private func trajectoryValidExactMainBinding(_ value: [String: Any]) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard Set(value.keys) == Set(Execution.authorityAndExactMainBindingKeys),
          value["authority_id"] as? String == Execution.authorityID,
          value["authority_canonical_sha256"] as? String
            == Execution.authorityCanonicalSHA256,
          value["repository"] as? String == "Ergentics/ergentics-prime",
          let revision = value["revision"] as? String,
          let tree = value["tree"] as? String,
          trajectoryIsLowerHex(revision, count: 40),
          trajectoryIsLowerHex(tree, count: 40),
          let parents = value["ordered_parents"] as? [String],
          parents.count == 2,
          parents[0] == Execution.authorityClosureRevision,
          parents.allSatisfy({ trajectoryIsLowerHex($0, count: 40) }),
          let runID = trajectoryExactUInt64(value["workflow_run_id"]),
          let runNumber = trajectoryExactUInt64(value["workflow_run_number"]),
          runID > 0, runNumber > 0,
          trajectoryExactUInt64(value["run_attempt"]) == 1
    else { return false }
    return true
}

private func trajectoryFrozenImplementationInventory() -> [[String: Any]] {
    PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
        .frozenV1.immutableImplementation.exactBaseSources.map {
            [
                "path_role": $0.role, "git_mode": $0.gitMode,
                "git_blob": $0.gitBlob, "byte_count": $0.byteCount,
                "lf_byte_count": $0.lfByteCount, "sha256": $0.sha256,
            ]
        }
}

private func trajectoryInventoryEqualsFrozenAuthority(
    _ value: [[String: Any]]
) throws -> Bool {
    guard value.count == 17,
          value.allSatisfy(trajectoryValidImplementationIdentity)
    else { return false }
    let observed = try trajectoryCanonicalJSONData(value)
    let expected = try trajectoryCanonicalJSONData(
        trajectoryFrozenImplementationInventory())
    return observed == expected
}

private func trajectoryValidByteCountAndSHA256(
    _ value: Any?
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard let object = value as? [String: Any],
          Set(object.keys) == Set(Execution.byteCountAndSHA256Keys),
          let count = trajectoryExactUInt64(object["byte_count"]), count > 0,
          let hash = object["sha256"] as? String,
          trajectoryIsLowerHex(hash, count: 64)
    else { return false }
    return true
}

private func trajectoryValidEnvironmentAndDeviceReceipt(
    _ value: [String: Any],
    inventory: [[String: Any]]
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard Set(value.keys) == Set(Execution.environmentAndDeviceReceiptKeys),
          value["mlx_enable_tf32"] as? String == "0",
          value["mlx_checkout_origin"] as? String
            == "https://github.com/Ergentics/ergentics-mlx-swift",
          value["mlx_revision"] as? String
            == "d37885a278f1c37484a94d0f401a418735e66519",
          value["swiftpm_configuration"] as? String == "release",
          value["graph_mode"] as? String
            == "eager_uncompiled_no_compile_transform",
          trajectoryExactUInt64(value["compile_transform_count"]) == 0,
          ["os_build", "xcode_build", "swift_driver", "swift_sdk"]
            .allSatisfy({ !(value[$0] as? String ?? "").isEmpty }),
          value["staged_metallib_role"] as? String == "staged_metallib",
          value["runtime_metallib_role"] as? String == "runtime_metallib",
          let stagedPath = value["staged_metallib_path_sha256"] as? String,
          let runtimePath = value["runtime_metallib_path_sha256"] as? String,
          trajectoryIsLowerHex(stagedPath, count: 64),
          trajectoryIsLowerHex(runtimePath, count: 64),
          trajectoryValidByteCountAndSHA256(
              value["staged_metallib_byte_count_and_content_sha256"]),
          trajectoryValidByteCountAndSHA256(
              value["runtime_metallib_byte_count_and_content_sha256"]),
          let metal = value[
              "metal_name_registry_unified_max_buffer_recommended_set"]
                as? [String: Any],
          Set(metal.keys) == Set(Execution.metalDeviceReceiptKeys),
          !(metal["name"] as? String ?? "").isEmpty,
          trajectoryExactUInt64(metal["registry_id"]) != nil,
          trajectoryExactBool(metal["has_unified_memory"]) == true,
          (trajectoryExactUInt64(metal["max_buffer_length"]) ?? 0) > 0,
          (trajectoryExactUInt64(
              metal["recommended_max_working_set_size"]) ?? 0) > 0,
          let mlx = value["mlx_device_and_default_gpu_stream"]
            as? [String: Any],
          Set(mlx.keys) == Set(Execution.mlxDeviceAndStreamReceiptKeys),
          mlx["device"] as? String == "gpu:0",
          mlx["default_stream"] as? String == "gpu",
          !(value["stream_order"] as? String ?? "").isEmpty,
          !(value["evaluation_order"] as? String ?? "").isEmpty,
          trajectoryExactBool(
              value["pre_post_identity_and_policy_equal"]) == true,
          let locks = value["root_and_validation_lock_bindings"]
            as? [[String: Any]],
          locks.count == 2,
          locks.allSatisfy({
              Set($0.keys) == Set(Execution.lockBindingKeys)
          })
    else { return false }
    let expectedLocks: [[String: Any]] = inventory.compactMap { identity in
        guard let role = identity["path_role"] as? String,
              role == "immutable_root_lock"
                || role == "immutable_validation_lock"
        else { return nil }
        return [
            "path_role": role, "git_blob": identity["git_blob"]!,
            "byte_count": identity["byte_count"]!,
            "sha256": identity["sha256"]!,
        ]
    }
    guard let observed = try? trajectoryCanonicalJSONData(locks),
          let expected = try? trajectoryCanonicalJSONData(expectedLocks)
    else { return false }
    return observed == expected
}

private func trajectoryValidOperationCounts(
    _ value: [String: Any],
    status: String
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard Set(value.keys) == Set(Execution.operationCountKeys) else {
        return false
    }
    var counts = [String: UInt64]()
    for key in Execution.operationCountKeys {
        guard let observed = trajectoryExactUInt64(value[key]),
              let maximum = Execution.exactOperationCounts[key],
              observed <= maximum
        else { return false }
        counts[key] = observed
    }
    let complete = status == "PASS_EXACT"
        || status == "MEASURED_EXACT_MISMATCH"
    if complete, counts != Execution.exactOperationCounts { return false }
    guard counts["optimizer_update_count"]! <= counts["backward_count"]!,
          counts["backward_count"]! <= counts["training_step_count"]!,
          counts["checked_read_only_evaluation_count"]!
            == counts["evaluation_forward_pass_count"]!,
          counts["checked_read_only_evaluation_count"]!
            <= counts["training_step_count"]!,
          counts["evaluation_forward_pass_count"]!
            <= counts["training_step_count"]!,
          counts["training_mode_restore_count"]!
            == counts["training_mode_disable_count"]!,
          counts["training_mode_disable_count"]!
            == counts["checked_read_only_evaluation_count"]!,
          counts["token_bounds_checked_eval_count"]!
            <= counts["token_bounds_validation_count"]!,
          counts["token_bounds_gpu_synchronize_count"]!
            <= counts["token_bounds_checked_eval_count"]!,
          counts["token_bounds_host_bool_item_count"]!
            <= counts["token_bounds_gpu_synchronize_count"]!,
          counts["dense_b_path_logits_call_count"]!
            <= counts["token_bounds_host_bool_item_count"]!,
          counts["dense_one_hot_matmul_construction_count"]!
            == counts["dense_b_path_logits_call_count"]!,
          counts["forward_loss_count"]!
            == counts["dense_b_path_logits_call_count"]!,
          counts["cross_entropy_count"]! == counts["forward_loss_count"]!,
          counts["dense_b_path_logits_call_count"]!
            == counts["training_step_count"]!
                + counts["evaluation_forward_pass_count"]!,
          counts["gradient_evidence_capture_count"]!
            <= counts["backward_count"]!,
          counts["gradient_catalog_release_count"]!
            <= counts["backward_count"]!,
          counts["final_commit_publication_count"]!
            <= counts["optimizer_moment_publish_count"]!,
          counts["optimizer_moment_publish_count"]!
            <= counts["v2_weights_write_count"]!,
          counts["v2_weights_write_count"]!
            <= counts["training_step_count"]!,
          counts["v2_internal_verification_load_count"]!
            == counts["v2_weights_write_count"]!,
          counts["leaf_publication_count"]!
            >= 4 * counts["final_commit_publication_count"]!,
          counts["leaf_publication_count"]!
            <= 4 * counts["v2_weights_write_count"]!,
          counts["public_restore_load_count"]!
            <= counts["final_commit_publication_count"]!,
          counts["deferred_optimizer_moment_load_count"]!
            <= counts["public_restore_load_count"]!,
          counts["typed_optimizer_state_import_count"]!
            <= counts["deferred_optimizer_moment_load_count"]!,
          counts["resource_measurement_checked_eval_count"]!
            <= counts["resource_measurement_synchronize_count"]!,
          counts["model_allocation_and_materialization_count"]!
            == counts["optimizer_allocation_count"]!
                + counts["v2_internal_verification_load_count"]!,
          counts["optimizer_allocation_count"]!
            == (counts["model_allocation_and_materialization_count"]! > 0
                ? 1 : 0)
                + counts["typed_optimizer_state_import_count"]!,
          counts["worker_process_count"]! == 1,
          counts["supervisor_process_count"]! == 1,
          counts["release_verifier_process_count"]! == 1,
          counts["maximum_public_receipt_count"]! == 1
    else { return false }
    return counts["training_step_count"]! != 3
        || (counts["public_restore_load_count"]! == 1
            && counts["typed_optimizer_state_import_count"]! == 1)
}

/// One shared dependency predicate is used by both the private supervisor
/// validator and the public canonical receipt validator.  This prevents a
/// schema-valid but temporally impossible operation prefix from being blessed
/// at either boundary.
private func trajectoryValidPhaseDependencies(
    _ value: [String: Any],
    phaseCount: Int,
    checkpointCount: Int,
    domainCount: Int,
    status: String,
    mismatch: [String: Any]
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let checkedEvalPrefix: [UInt64] = [
        0, 0, 1, 2, 3, 4, 5, 5, 6, 7, 8, 8, 8,
    ]
    guard phaseCount >= 0, phaseCount < checkedEvalPrefix.count,
          checkpointCount >= 0, checkpointCount <= 3,
          domainCount >= 0, domainCount <= 18
    else { return false }
    var counts = [String: UInt64]()
    for key in Execution.operationCountKeys {
        guard let count = trajectoryExactUInt64(value[key]) else {
            return false
        }
        counts[key] = count
    }
    guard counts["resource_measurement_synchronize_count"]
            == UInt64(phaseCount),
          counts["resource_measurement_checked_eval_count"]
            == checkedEvalPrefix[phaseCount],
          counts["final_commit_publication_count"]
            == UInt64(checkpointCount),
          counts["training_step_count"]! < 1 || phaseCount >= 2,
          counts["training_step_count"]! < 2 || phaseCount >= 4,
          counts["public_restore_load_count"]! != 1 || phaseCount >= 7,
          counts["training_step_count"]! != 3 || phaseCount >= 8,
          checkpointCount < 1 || counts["training_step_count"]! >= 1,
          checkpointCount < 2 || counts["training_step_count"]! >= 2,
          checkpointCount != 3 || counts["training_step_count"]! == 3
    else { return false }
    if domainCount > 0 {
        guard phaseCount >= 10, checkpointCount == 3,
              counts["training_step_count"] == 3,
              counts["backward_count"] == 3,
              counts["optimizer_update_count"] == 3
        else { return false }
    }
    let safeTimeout = status == "ABSTAIN_RESOURCE"
        && mismatch["domain_id"] as? String
            == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure"
    if safeTimeout && phaseCount >= 11 {
        guard domainCount == 18 else { return false }
        var expected = Execution.exactOperationCounts
        expected["resource_measurement_synchronize_count"] = UInt64(phaseCount)
        return counts == expected
    }
    return true
}

private func trajectoryValidNullableSHA256(_ value: Any?) -> Bool {
    value is NSNull
        || ((value as? String).map {
            trajectoryIsLowerHex($0, count: 64)
        } ?? false)
}

private func trajectoryValidTensorProjection(_ value: Any?) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard let projection = value as? [String: Any],
          Set(projection.keys) == Set(Execution.tensorCatalogProjectionKeys),
          projection["algorithm_id"] as? String
            == "prime_stage7_sorted_path_shape_dtype_element_and_byte_count_sha256_v1",
          let count = trajectoryExactUInt64(
              projection["sorted_unique_path_count"]), count <= 218,
          [
              "shape_dtype_element_and_byte_count_preimage_sha256",
              "canonical_logical_bytes_preimage_sha256",
          ].allSatisfy({
              (projection[$0] as? String).map {
                  trajectoryIsLowerHex($0, count: 64)
              } == true
          }),
          trajectoryExactUInt64(projection["total_element_count"]) != nil,
          trajectoryExactUInt64(
              projection["total_logical_byte_count"]) != nil,
          projection["first_mismatch_path_if_any"] is NSNull
            || !(projection["first_mismatch_path_if_any"] as? String ?? "")
                .isEmpty
    else { return false }
    return true
}

private func trajectoryAllowedComparisonPaths(_ index: Int) -> Set<String>? {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let domain = Execution.comparisonDomainIDs[index]
    if let fixed = Execution.fixedComparisonMemberPathsByDomainID[domain] {
        return Set(fixed)
    }
    guard let identity = try? PrimeNativeDecoderCompatibilityIdentityV2
            .native300MByte512()
    else { return nil }
    let prefix: String
    switch index {
    case 1, 12:
        prefix = PrimeNativeDecoderNative300MTrajectoryCheckpointV1
            .firstMomentStoragePrefix
    case 2, 13:
        prefix = PrimeNativeDecoderNative300MTrajectoryCheckpointV1
            .secondMomentStoragePrefix
    default:
        prefix = ""
    }
    return Set(identity.parameterCatalog.map { prefix + $0.path })
}

private func trajectoryValidMeasuredComparisonDomain(
    _ value: [String: Any],
    index: Int
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let contract =
        PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
            .frozenV1.comparison.domains[index]
    guard Set(value.keys) == Set(Execution.comparisonDomainResultKeys),
          value["domain_id"] as? String == contract.id,
          value["kind"] as? String == contract.kind,
          trajectoryExactUInt64(value["path_count"])
            == UInt64(contract.expectedPathCount),
          value["catalog_preimage_schema"] as? String
            == contract.expectedPathSetBinding,
          let catalog = value["catalog_sha256"] as? String,
          let left = value["left_sha256"] as? String,
          let right = value["right_sha256"] as? String,
          trajectoryIsLowerHex(catalog, count: 64),
          trajectoryIsLowerHex(left, count: 64),
          trajectoryIsLowerHex(right, count: 64),
          trajectoryExactUInt64(value["left_total_bytes"]) != nil,
          trajectoryExactUInt64(value["right_total_bytes"]) != nil,
          let exact = trajectoryExactBool(value["exact"]),
          exact == (left == right)
    else { return false }
    let tensorTopology = contract.kind == "tensor_catalog"
        || contract.kind == "scalar_and_tensor"
    if tensorTopology {
        guard trajectoryValidTensorProjection(
                value["tensor_catalog_projection"]),
              let projection = value["tensor_catalog_projection"]
                as? [String: Any],
              trajectoryExactUInt64(
                  projection["sorted_unique_path_count"])
                == UInt64(contract.expectedPathCount),
              projection[
                  "shape_dtype_element_and_byte_count_preimage_sha256"]
                as? String == catalog,
              trajectoryExactUInt64(
                  projection["total_logical_byte_count"])
                == trajectoryExactUInt64(value["left_total_bytes"]),
              trajectoryExactUInt64(value["left_total_bytes"])
                == trajectoryExactUInt64(value["right_total_bytes"]),
              projection["canonical_logical_bytes_preimage_sha256"]
                as? String == left
        else { return false }
        if exact {
            guard projection["first_mismatch_path_if_any"] is NSNull else {
                return false
            }
        } else {
            guard projection["first_mismatch_path_if_any"] as? String
                    == value["first_mismatch_path"] as? String
            else { return false }
        }
    } else if !(value["tensor_catalog_projection"] is NSNull) {
        return false
    }
    if exact {
        return value["first_mismatch_path"] is NSNull
            && value["first_mismatch_expected_binding"] is NSNull
            && value["first_mismatch_observed_binding"] is NSNull
            && left == right
    }
    guard !(value["first_mismatch_path"] as? String ?? "").isEmpty,
          let expected = value["first_mismatch_expected_binding"] as? String,
          let observed = value["first_mismatch_observed_binding"] as? String,
          trajectoryIsLowerHex(expected, count: 64),
          trajectoryIsLowerHex(observed, count: 64), expected != observed,
          let path = value["first_mismatch_path"] as? String,
          trajectoryAllowedComparisonPaths(index)?.contains(path) == true
    else { return false }
    return true
}

private func trajectoryValidUnmeasuredComparisonDomain(
    _ value: [String: Any],
    index: Int
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let contract =
        PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
            .frozenV1.comparison.domains[index]
    let nullableKeys = [
        "catalog_sha256", "left_total_bytes", "left_sha256",
        "right_total_bytes", "right_sha256", "exact",
        "first_mismatch_path", "first_mismatch_expected_binding",
        "first_mismatch_observed_binding", "tensor_catalog_projection",
    ]
    return Set(value.keys) == Set(Execution.comparisonDomainResultKeys)
        && value["domain_id"] as? String == contract.id
        && value["kind"] as? String == contract.kind
        && trajectoryExactUInt64(value["path_count"])
            == UInt64(contract.expectedPathCount)
        && value["catalog_preimage_schema"] as? String
            == contract.expectedPathSetBinding
        && nullableKeys.allSatisfy({ value[$0] is NSNull })
}

private func trajectoryValidDomainOutcome(
    _ domains: [[String: Any]],
    mismatch: [String: Any],
    status: String
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard domains.count == 18,
          Set(mismatch.keys) == Set(Execution.firstMismatchKeys)
    else { return false }
    if status == "ABSTAIN_RESOURCE",
       mismatch["domain_id"] as? String
        == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure",
       domains.enumerated().allSatisfy({
           trajectoryValidMeasuredComparisonDomain(
               $0.element, index: $0.offset)
       })
    {
        return mismatch["availability"] as? String == "unavailable"
            && mismatch["expected_binding"] is NSNull
    }
    if status == "PASS_EXACT" || status == "MEASURED_EXACT_MISMATCH" {
        guard domains.enumerated().allSatisfy({
            trajectoryValidMeasuredComparisonDomain($0.element, index: $0.offset)
        }) else { return false }
        let failures = domains.enumerated().filter {
            trajectoryExactBool($0.element["exact"]) == false
        }
        if status == "PASS_EXACT" {
            return failures.isEmpty
                && mismatch["availability"] as? String == "not_applicable"
                && ["domain_id", "path", "expected_binding", "observed_binding"]
                    .allSatisfy({ mismatch[$0] is NSNull })
        }
        guard let first = failures.first else { return false }
        return mismatch["availability"] as? String == "available"
            && mismatch["domain_id"] as? String
                == Execution.comparisonDomainIDs[first.offset]
            && mismatch["path"] as? String
                == first.element["first_mismatch_path"] as? String
            && mismatch["expected_binding"] as? String
                == first.element["first_mismatch_expected_binding"]
                    as? String
            && mismatch["observed_binding"] as? String
                == first.element["first_mismatch_observed_binding"]
                    as? String
    }
    var measuredCount = 0
    while measuredCount < domains.count,
          trajectoryValidMeasuredComparisonDomain(
              domains[measuredCount],
              index: measuredCount)
    {
        measuredCount += 1
    }
    guard measuredCount < 18,
          domains.prefix(measuredCount).allSatisfy({
              trajectoryExactBool($0["exact"]) == true
          }),
          domains.enumerated().dropFirst(measuredCount).allSatisfy({
              trajectoryValidUnmeasuredComparisonDomain(
                  $0.element,
                  index: $0.offset)
          }),
          mismatch["availability"] as? String == "unavailable",
          !(mismatch["domain_id"] as? String ?? "").isEmpty,
          !(mismatch["path"] as? String ?? "").isEmpty,
          let observed = mismatch["observed_binding"] as? String,
          trajectoryIsLowerHex(observed, count: 64)
    else { return false }
    if status == "ABSTAIN_RESOURCE" {
        let guards =
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                .frozenV1.resource.resourceABSTAINGuardIDs
        let guardID = mismatch["domain_id"] as! String
        guard guards.contains(guardID) else { return false }
        if guardID == "memory_limit_below_minimum_floor"
            || guardID == "filesystem_available_below_three_set_floor"
        {
            guard let expected = mismatch["expected_binding"] as? String,
                  trajectoryIsLowerHex(expected, count: 64)
            else { return false }
            return expected != observed
        }
        if guardID == "positively_identified_enomem" {
            return mismatch["expected_binding"] is NSNull
                && mismatch["path"] as? String == "errno"
                && observed == PrimeSHA256.hexDigest(
                    of: Data("errno=12".utf8))
        }
        if guardID == "positively_identified_enospc" {
            return mismatch["expected_binding"] is NSNull
                && mismatch["path"] as? String == "errno"
                && observed == PrimeSHA256.hexDigest(
                    of: Data("errno=28".utf8))
        }
        return mismatch["expected_binding"] is NSNull
    }
    guard let expected = mismatch["expected_binding"] as? String,
          trajectoryIsLowerHex(expected, count: 64),
          mismatch["domain_id"] as? String
            == Execution.comparisonDomainIDs[measuredCount],
          let path = mismatch["path"] as? String,
          trajectoryAllowedComparisonPaths(measuredCount)?.contains(path)
            == true
    else { return false }
    return expected != observed
}

private func trajectoryValidResourcePhases(
    _ phases: [[String: Any]],
    status: String,
    mismatch: [String: Any]
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let complete = status == "PASS_EXACT"
        || status == "MEASURED_EXACT_MISMATCH"
    let guardID = mismatch["domain_id"] as? String
    let safeTimeout = status == "ABSTAIN_RESOURCE"
        && guardID
            == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure"
    let safeIntegrity = status == "ABSTAIN_INTEGRITY"
    guard phases.count == (complete ? 12 : phases.count),
          complete || (phases.count >= 1
            && phases.count <= ((safeTimeout || safeIntegrity) ? 12 : 11))
    else { return false }
    var previousElapsed: UInt64?
    var previousPeak: UInt64?
    var previousRSS: UInt64?
    var copiedMemoryLimit: UInt64?
    var copiedCacheLimit: UInt64?
    var copiedPhysicalMemory: UInt64?
    var copiedFSID: [String: Any]?
    var copiedPathSHA: String?
    for (index, phase) in phases.enumerated() {
        guard Set(phase.keys) == Set(Execution.resourcePhaseKeys),
              phase["phase_id"] as? String == Execution.phaseNames[index],
              let elapsed = trajectoryExactUInt64(
                  phase["cumulative_elapsed_nanoseconds"]),
              let physical = trajectoryExactUInt64(
                  phase["physical_memory_capacity_bytes"]), physical > 0,
              trajectoryExactUInt64(phase["task_resident_bytes"]) != nil,
              trajectoryExactUInt64(
                  phase["task_physical_footprint_bytes"]) != nil,
              let rss = trajectoryExactUInt64(
                  phase["getrusage_max_rss_bytes"]),
              trajectoryExactUInt64(phase["mlx_active_bytes"]) != nil,
              trajectoryExactUInt64(phase["mlx_cache_bytes"]) != nil,
              let peak = trajectoryExactUInt64(phase["mlx_peak_bytes"]),
              trajectoryExactUInt64(
                  phase["metal_current_allocated_bytes"]) != nil,
              let fsid = phase["filesystem_fsid"] as? [String: Any],
              Set(fsid.keys) == Set(Execution.filesystemIDKeys),
              trajectoryExactUInt64(fsid["word0"]) != nil,
              trajectoryExactUInt64(fsid["word1"]) != nil,
              phase["filesystem_semantic_role"] as? String
                == "artifact_root",
              let pathSHA = phase["filesystem_path_sha256"] as? String,
              trajectoryIsLowerHex(pathSHA, count: 64),
              (trajectoryExactUInt64(
                  phase["filesystem_capacity_bytes"]) ?? 0) > 0,
              trajectoryExactUInt64(
                  phase["filesystem_available_bytes"]) != nil,
              let memoryLimit = trajectoryExactUInt64(
                  phase[
                    "verified_configured_memory_limit_copied_from_preflight_bytes"]),
              memoryLimit > 0,
              let cacheLimit = trajectoryExactUInt64(
                  phase[
                    "verified_configured_cache_limit_copied_from_preflight_bytes"]),
              cacheLimit == 0,
              previousElapsed.map({ elapsed > $0 }) ?? true,
              previousPeak.map({ peak >= $0 }) ?? true,
              previousRSS.map({ rss >= $0 }) ?? true,
              copiedMemoryLimit.map({ memoryLimit == $0 }) ?? true,
              copiedCacheLimit.map({ cacheLimit == $0 }) ?? true,
              copiedPhysicalMemory.map({ physical == $0 }) ?? true,
              copiedPathSHA.map({ pathSHA == $0 }) ?? true
        else { return false }
        if let copiedFSID,
           let observed = try? trajectoryCanonicalJSONData(fsid),
           let expected = try? trajectoryCanonicalJSONData(copiedFSID),
           observed != expected
        {
            return false
        }
        previousElapsed = elapsed
        previousPeak = peak
        previousRSS = rss
        copiedMemoryLimit = copiedMemoryLimit ?? memoryLimit
        copiedCacheLimit = copiedCacheLimit ?? cacheLimit
        copiedPhysicalMemory = copiedPhysicalMemory ?? physical
        copiedFSID = copiedFSID ?? fsid
        copiedPathSHA = copiedPathSHA ?? pathSHA
    }
    guard let first = phases.first,
          let available = trajectoryExactUInt64(
              first["filesystem_available_bytes"]),
          let memoryLimit = copiedMemoryLimit
    else { return false }
    let memoryFloor: UInt64 = 4_337_713_152
    let filesystemFloor: UInt64 = 12_884_901_888
    let peaksWithinLimit = phases.allSatisfy {
        (trajectoryExactUInt64($0["mlx_peak_bytes"]) ?? UInt64.max)
            < memoryLimit
    }
    if complete {
        return memoryLimit >= memoryFloor
            && available >= filesystemFloor
            && peaksWithinLimit
            && (trajectoryExactUInt64(
                phases.last?["cumulative_elapsed_nanoseconds"])
                ?? UInt64.max) < 4_800_000_000_000
    }
    if status == "ABSTAIN_RESOURCE",
       guardID == "memory_limit_below_minimum_floor"
    {
        return memoryLimit < memoryFloor
            && mismatch["path"] as? String
                == "device_and_stream.configured_memory_limit_bytes"
            && mismatch["observed_binding"] as? String
                == PrimeSHA256.hexDigest(of: Data(
                    "configured_memory_limit_bytes=\(memoryLimit)".utf8))
            && mismatch["expected_binding"] as? String
                == PrimeSHA256.hexDigest(of: Data(
                    "minimum_memory_limit_floor_bytes=4337713152".utf8))
    }
    if status == "ABSTAIN_RESOURCE",
       guardID == "filesystem_available_below_three_set_floor"
    {
        return memoryLimit >= memoryFloor
            && available < filesystemFloor
            && mismatch["path"] as? String
                == "resource_phases[0].filesystem_available_bytes"
            && mismatch["observed_binding"] as? String
                == PrimeSHA256.hexDigest(of: Data(
                    "filesystem_available_bytes=\(available)".utf8))
            && mismatch["expected_binding"] as? String
                == PrimeSHA256.hexDigest(of: Data(
                    "available_filesystem_floor_bytes=12884901888".utf8))
    }
    if status == "ABSTAIN_RESOURCE",
       guardID == "positively_identified_mlx_memory_limit_exhaustion",
       let last = phases.last,
       let peak = trajectoryExactUInt64(last["mlx_peak_bytes"])
    {
        return memoryLimit >= memoryFloor
            && available >= filesystemFloor
            && peak >= memoryLimit
            && mismatch["path"] as? String
                == "resource_phases[last].mlx_peak_bytes"
            && mismatch["observed_binding"] as? String
                == PrimeSHA256.hexDigest(of: Data(
                    "configured_memory_limit_bytes=\(memoryLimit);mlx_peak_bytes=\(peak);positively_identified_mlx_memory_limit_exhaustion=true"
                        .utf8))
    }
    if status == "ABSTAIN_RESOURCE",
       guardID
        == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure",
       let last = phases.last,
       let elapsed = trajectoryExactUInt64(
           last["cumulative_elapsed_nanoseconds"]),
       elapsed >= 4_800_000_000_000
    {
        return memoryLimit >= memoryFloor
            && available >= filesystemFloor
            && mismatch["expected_binding"] is NSNull
            && mismatch["path"] as? String
                == "resource_phases[last].cumulative_elapsed_nanoseconds"
            && mismatch["observed_binding"] as? String
                == PrimeSHA256.hexDigest(of: Data(
                    "timeout_role=worker;deadline_seconds=4800;elapsed_nanoseconds=\(elapsed);contained=true;cleanup_absence=true"
                        .utf8))
    }
    // Any later resource or integrity guard is reachable only after both
    // static floors were positively cleared.
    return memoryLimit >= memoryFloor && available >= filesystemFloor
        && guardID != "positively_identified_mlx_memory_limit_exhaustion"
        && guardID
            != "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure"
}

private func trajectoryValidCheckpointOutcome(
    _ checkpoints: [[String: Any]],
    status: String
) -> Bool {
    let complete = status == "PASS_EXACT"
        || status == "MEASURED_EXACT_MISMATCH"
    guard checkpoints.count <= 3,
          checkpoints.enumerated().allSatisfy({ index, checkpoint in
              trajectoryValidCheckpointProjection(checkpoint)
                && checkpoint["set_role"] as? String == [
                    "baseline_checkpoint",
                    "uninterrupted_n_plus_1_comparator",
                    "resumed_n_plus_1_comparator",
                ][index]
          })
    else { return false }
    return !complete || checkpoints.count == 3
}

private func trajectoryValidArtifactCleanup(
    _ cleanup: [String: Any],
    status: String
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard Set(cleanup.keys) == Set(Execution.artifactCleanupKeys),
          trajectoryExactBool(cleanup["initial_inventory_empty"]) == true,
          let known = trajectoryExactUInt64(
              cleanup["known_inventory_before_cleanup"]), known <= 12,
          trajectoryExactUInt64(cleanup["unknown_inventory_count"]) == 0,
          trajectoryExactUInt64(cleanup["deleted_known_leaf_count"]) == known,
          let comparatorCount = trajectoryExactUInt64(
              cleanup["deleted_private_comparator_count"]),
          comparatorCount <= 2,
          trajectoryExactBool(cleanup["post_cleanup_inventory_empty"]) == true,
          trajectoryExactBool(cleanup["absence_proved"]) == true,
          trajectoryExactBool(cleanup["recursive_cleanup_used"]) == false,
          trajectoryExactUInt64(cleanup["artifact_upload_count"]) == 0,
          trajectoryExactUInt64(cleanup["retained_artifact_count"]) == 0
    else { return false }
    let complete = status == "PASS_EXACT"
        || status == "MEASURED_EXACT_MISMATCH"
    return !complete || (known == 12 && comparatorCount == 2)
}

private func trajectoryValidPublicDescriptor(
    _ value: [String: Any],
    role: String,
    parent: Bool
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard Set(value.keys) == Set(Execution.publicDescriptorTupleKeys),
          value["semantic_role"] as? String == role,
          let pathSHA = value["path_sha256"] as? String,
          trajectoryIsLowerHex(pathSHA, count: 64),
          trajectoryExactUInt64(value["device_id"]) != nil,
          (trajectoryExactUInt64(value["inode"]) ?? 0) > 0,
          trajectoryExactUInt64(value["uid"]) != nil,
          trajectoryExactUInt64(value["gid"]) != nil,
          value["mode"] as? String == (parent ? "0700" : "0600"),
          trajectoryExactUInt64(value["acl_entry_count"]) == 0,
          let xattrs = value["xattr_names"] as? [String],
          xattrs == xattrs.sorted(by: trajectoryRawUTF8Less),
          Set(xattrs).count == xattrs.count,
          Set(xattrs).isSubset(of: trajectoryAllowedXattrs),
          trajectoryExactUInt64(value["security_flags"]) == 0,
          value["file_type"] as? String
            == (parent ? "directory" : "regular_file"),
          (parent
            ? value["byte_count"] is NSNull
            : trajectoryExactUInt64(value["byte_count"]) == 0),
          let nlink = trajectoryExactUInt64(value["observed_nlink"]),
          parent ? true : nlink == 1
    else { return false }
    return true
}

private func trajectoryPublicParentStable(
    _ lhs: [String: Any],
    _ rhs: [String: Any]
) -> Bool {
    ["path_sha256", "device_id", "inode", "uid", "gid", "mode", "file_type"]
        .allSatisfy { key in
            guard let leftValue = lhs[key], let rightValue = rhs[key],
                  let left = try? trajectoryCanonicalJSONData([leftValue]),
                  let right = try? trajectoryCanonicalJSONData([rightValue])
            else { return false }
            return left == right
        }
}

private func trajectoryPublicLeafStable(
    _ lhs: [String: Any],
    _ rhs: [String: Any]
) -> Bool {
    let ignored: Set<String> = ["semantic_role"]
    return Set(lhs.keys).subtracting(ignored).allSatisfy { key in
        guard let leftValue = lhs[key], let rightValue = rhs[key],
              let left = try? trajectoryCanonicalJSONData([leftValue]),
              let right = try? trajectoryCanonicalJSONData([rightValue])
        else { return false }
        return left == right
    }
}

private func trajectoryValidLeaseAndVerifier(
    _ lease: [String: Any]
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard Set(lease.keys) == Set(Execution.leaseAndVerifierKeys),
          trajectoryExactBool(lease["lease_acquired"]) == true,
          trajectoryExactUInt64(lease["lease_release_count"]) == 2,
          trajectoryExactBool(lease["verifier_executed"]) == true,
          trajectoryExactBool(lease["verifier_exit_zero"]) == true,
          trajectoryExactBool(
              lease["supervisor_alive_during_verifier"]) == true,
          trajectoryExactBool(lease["inventory_exact"]) == true,
          let preflight = lease["preflight_parent"] as? [String: Any],
          let postParent = lease["post_candidate_parent"] as? [String: Any],
          let postLeaf = lease["post_candidate_leaf"] as? [String: Any],
          let verifierParent = lease["verifier_parent"] as? [String: Any],
          let verifierLeaf = lease["verifier_leaf"] as? [String: Any],
          trajectoryValidPublicDescriptor(
              preflight, role: "preflight_parent", parent: true),
          trajectoryValidPublicDescriptor(
              postParent, role: "post_candidate_parent", parent: true),
          trajectoryValidPublicDescriptor(
              postLeaf, role: "post_candidate_leaf", parent: false),
          trajectoryValidPublicDescriptor(
              verifierParent, role: "verifier_parent", parent: true),
          trajectoryValidPublicDescriptor(
              verifierLeaf, role: "verifier_leaf", parent: false),
          trajectoryPublicParentStable(preflight, postParent),
          trajectoryPublicParentStable(postParent, verifierParent),
          trajectoryPublicLeafStable(postLeaf, verifierLeaf)
    else { return false }
    return true
}

private func trajectoryValidSemanticPaths(
    _ paths: [[String: Any]]
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard paths.count == 5 else { return false }
    for (index, path) in paths.enumerated() {
        let hasContent = index >= 3
        guard Set(path.keys) == Set(Execution.semanticPathProjectionKeys),
              path["semantic_role"] as? String
                == Execution.semanticPathRoles[index],
              let pathSHA = path["path_sha256"] as? String,
              trajectoryIsLowerHex(pathSHA, count: 64),
              trajectoryExactBool(path["raw_absolute_path_present"]) == false,
              hasContent
                ? ((trajectoryExactUInt64(path["byte_count"]) ?? 0) > 0
                    && (path["content_sha256"] as? String).map {
                        trajectoryIsLowerHex($0, count: 64)
                    } == true)
                : (path["byte_count"] is NSNull
                    && path["content_sha256"] is NSNull)
        else { return false }
    }
    return true
}

private func trajectoryValidCheckpointProjection(
    _ value: [String: Any]
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard let role = value["set_role"] as? String,
          [
              "baseline_checkpoint", "uninterrupted_n_plus_1_comparator",
              "resumed_n_plus_1_comparator",
          ].contains(role),
          trajectoryExactBool(value["load_authoritative"])
            == (role == "baseline_checkpoint"),
          value["commit_schema"] as? String
            == PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                .checkpointSchemaID,
          (trajectoryExactUInt64(value["commit_byte_count"]) ?? 0) > 0,
          (value["commit_sha256"] as? String).map({
              trajectoryIsLowerHex($0, count: 64)
          }) == true,
          trajectoryExactUInt64(value["leaf_count"]) == 4,
          value["ordered_leaf_roles"] as? [String] == [
              "weights_v2", "optimizer_moments", "control_state_manifest",
              "commit_manifest",
          ],
          let leaves = value["each_leaf_byte_count_and_sha256"]
            as? [[String: Any]],
          leaves.count == 4,
          leaves.enumerated().allSatisfy({ index, leaf in
              Set(leaf.keys) == Set(Execution.checkpointLeafBindingKeys)
                  && leaf["role"] as? String
                    == [
                        "weights_v2", "optimizer_moments",
                        "control_state_manifest", "commit_manifest",
                    ][index]
                  && trajectoryExactUInt64(leaf["publication_ordinal"])
                    == UInt64(index + 1)
                  && (trajectoryExactUInt64(leaf["byte_count"]) ?? 0) > 0
                  && (leaf["sha256"] as? String).map {
                      trajectoryIsLowerHex($0, count: 64)
                  } == true
          }),
          let external = value["external_v2_binding"] as? [String: Any],
          Set(external.keys) == Set(Execution.externalV2ProjectionKeys),
          !(external["schema_id"] as? String ?? "").isEmpty,
          external["artifact_semantic_role"] as? String == "weights_v2",
          (trajectoryExactUInt64(external["container_byte_count"]) ?? 0) > 0,
          [
              "compatibility_identity_sha256", "artifact_path_sha256",
              "container_sha256", "manifest_sha256",
          ].allSatisfy({ key in
              (external[key] as? String).map {
                  trajectoryIsLowerHex($0, count: 64)
              } == true
          }),
          let control = value["control_schema_and_sha256"]
            as? [String: Any],
          Set(control.keys) == Set(Execution.controlStateProjectionKeys),
          !(control["schema_id"] as? String ?? "").isEmpty,
          (trajectoryExactUInt64(control["canonical_byte_count"]) ?? 0) > 0,
          (control["sha256"] as? String).map({
              trajectoryIsLowerHex($0, count: 64)
          }) == true
    else { return false }
    return true
}

private func trajectoryNullableByteCountAndHash(
    count: Any?,
    hash: Any?
) -> Bool {
    if count is NSNull, hash is NSNull { return true }
    guard trajectoryExactUInt64(count) != nil,
          let hash = hash as? String
    else { return false }
    return trajectoryIsLowerHex(hash, count: 64)
}

private func trajectoryContainsRawAbsolutePath(_ value: Any) -> Bool {
    if let string = value as? String { return string.hasPrefix("/") }
    if let values = value as? [Any] {
        return values.contains(where: trajectoryContainsRawAbsolutePath)
    }
    if let values = value as? [String: Any] {
        return values.values.contains(where: trajectoryContainsRawAbsolutePath)
    }
    return false
}

private func exactCatalog(
    _ parameters: ModuleParameters,
    scope: String
) throws -> [String: MLXArray] {
    var result = [String: MLXArray]()
    for (path, array) in parameters.flattened() {
        try trajectoryRequire(
            result.updateValue(array, forKey: path) == nil,
            "duplicate \(scope) path \(path)")
    }
    try trajectoryRequire(
        result.count
            == PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                .expectedParameterPathCount,
        "\(scope) path count")
    return result
}

private func validateMomentCatalogs(
    first: [String: MLXArray],
    second: [String: MLXArray],
    target: [String: MLXArray]
) throws {
    try trajectoryRequire(
        Set(first.keys) == Set(target.keys)
            && Set(second.keys) == Set(target.keys),
        "typed Adam path set")
    for path in target.keys.sorted(by: trajectoryRawUTF8Less) {
        let parameter = target[path]!
        let firstValue = first[path]!
        let secondValue = second[path]!
        try trajectoryRequire(
            parameter.dtype == .float32
                && firstValue.dtype == parameter.dtype
                && secondValue.dtype == parameter.dtype
                && firstValue.shape == parameter.shape
                && secondValue.shape == parameter.shape
                && parameter.size > 0,
            "typed Adam shape/dtype at \(path)")
    }
}

private func trajectoryMaximalPublicReceiptFixture() -> [String: Any] {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let hex40 = String(repeating: "0", count: 40)
    let hex64 = String(repeating: "0", count: 64)
    let inventory = trajectoryFrozenImplementationInventory()
    let domains: [[String: Any]] =
        PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
            .frozenV1.comparison.domains.enumerated().map { index, contract in
            let tensorTopology = contract.kind == "tensor_catalog"
                || contract.kind == "scalar_and_tensor"
            let logicalBytes = UInt64(contract.expectedPathCount * 4)
            let projection: [String: Any] = [
                "algorithm_id":
                    "prime_stage7_sorted_path_shape_dtype_element_and_byte_count_sha256_v1",
                "sorted_unique_path_count": contract.expectedPathCount,
                "shape_dtype_element_and_byte_count_preimage_sha256": hex64,
                "canonical_logical_bytes_preimage_sha256": hex64,
                "total_element_count": contract.expectedPathCount,
                "total_logical_byte_count": logicalBytes,
                "first_mismatch_path_if_any": NSNull(),
            ]
            return [
                "domain_id": contract.id, "kind": contract.kind,
                "path_count": contract.expectedPathCount,
                "catalog_preimage_schema": contract.expectedPathSetBinding,
                "catalog_sha256": hex64,
                "left_total_bytes": logicalBytes, "left_sha256": hex64,
                "right_total_bytes": logicalBytes, "right_sha256": hex64,
                "exact": true, "first_mismatch_path": NSNull(),
                "first_mismatch_expected_binding": NSNull(),
                "first_mismatch_observed_binding": NSNull(),
                "tensor_catalog_projection": tensorTopology
                    ? (projection as Any) : NSNull(),
            ]
        }
    let phases: [[String: Any]] = Execution.phaseNames.enumerated().map {
        index, phase in
        [
            "phase_id": phase,
            "cumulative_elapsed_nanoseconds": index + 1,
            "physical_memory_capacity_bytes": 17_179_869_184,
            "task_resident_bytes": 1, "task_physical_footprint_bytes": 1,
            "getrusage_max_rss_bytes": 1, "mlx_active_bytes": 1,
            "mlx_cache_bytes": 0, "mlx_peak_bytes": 1,
            "metal_current_allocated_bytes": 1,
            "filesystem_fsid": ["word0": 1, "word1": 2],
            "filesystem_semantic_role": "artifact_root",
            "filesystem_path_sha256": hex64,
            "filesystem_capacity_bytes": 20_000_000_000,
            "filesystem_available_bytes": 15_000_000_000,
            "verified_configured_memory_limit_copied_from_preflight_bytes":
                17_179_869_184,
            "verified_configured_cache_limit_copied_from_preflight_bytes": 0,
        ]
    }
    let checkpointRoles = [
        "baseline_checkpoint", "uninterrupted_n_plus_1_comparator",
        "resumed_n_plus_1_comparator",
    ]
    let checkpoints: [[String: Any]] = checkpointRoles.enumerated().map {
        index, role in
        [
            "set_role": role, "load_authoritative": index == 0,
            "commit_schema":
                PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .checkpointSchemaID,
            "commit_byte_count": 1, "commit_sha256": hex64,
            "leaf_count": 4,
            "ordered_leaf_roles": [
                "weights_v2", "optimizer_moments",
                "control_state_manifest", "commit_manifest",
            ],
            "each_leaf_byte_count_and_sha256": (0 ..< 4).map { leaf in
                [
                    "role": [
                        "weights_v2", "optimizer_moments",
                        "control_state_manifest", "commit_manifest",
                    ][leaf],
                    "publication_ordinal": leaf + 1, "byte_count": 1,
                    "sha256": hex64,
                ] as [String: Any]
            },
            "external_v2_binding": [
                "schema_id": "fixture_v2", "compatibility_identity_sha256": hex64,
                "artifact_semantic_role": "weights_v2",
                "artifact_path_sha256": hex64, "container_byte_count": 1,
                "container_sha256": hex64, "manifest_sha256": hex64,
            ],
            "control_schema_and_sha256": [
                "schema_id": "fixture_control_v1", "canonical_byte_count": 1,
                "sha256": hex64,
            ],
        ]
    }
    func descriptor(_ role: String, parent: Bool) -> [String: Any] {
        [
            "semantic_role": role, "path_sha256": hex64,
            "device_id": 1, "inode": 1, "uid": 1, "gid": 1,
            "mode": parent ? "0700" : "0600", "acl_entry_count": 0,
            "xattr_names": [], "security_flags": 0,
            "file_type": parent ? "directory" : "regular_file",
            "byte_count": parent ? NSNull() : 0,
            "observed_nlink": 1,
        ]
    }
    let semanticPaths: [[String: Any]] = (0 ..< 5).map { index in
        [
            "semantic_role": Execution.semanticPathRoles[index],
            "path_sha256": hex64,
            "byte_count": index < 3 ? NSNull() : 1,
            "content_sha256": index < 3 ? NSNull() : hex64,
            "raw_absolute_path_present": false,
        ]
    }
    var counts = [String: Any]()
    for key in Execution.operationCountKeys {
        counts[key] = Execution.exactOperationCounts[key]!
    }
    return [
        "schema": Execution.publicReceiptSchemaID,
        "authority_and_exact_main_bindings": [
            "authority_id": Execution.authorityID,
            "authority_canonical_sha256": Execution.authorityCanonicalSHA256,
            "repository": "Ergentics/ergentics-prime", "revision": hex40,
            "tree": hex40, "ordered_parents": [
                Execution.authorityClosureRevision, hex40,
            ],
            "workflow_run_id": 1, "workflow_run_number": 1,
            "run_attempt": 1,
        ],
        "implementation_inventory": inventory,
        "terminal_status": "PASS_EXACT", "one_shot_consumed": true,
        "candidate_byte_count": 1, "candidate_sha256": hex64,
        "terminal_byte_count": 1, "terminal_sha256": hex64,
        "environment_and_device_bindings": [
            "mlx_enable_tf32": "0",
            "mlx_checkout_origin":
                "https://github.com/Ergentics/ergentics-mlx-swift",
            "mlx_revision":
                "d37885a278f1c37484a94d0f401a418735e66519",
            "swiftpm_configuration": "release",
            "graph_mode": "eager_uncompiled_no_compile_transform",
            "compile_transform_count": 0, "os_build": "fixture",
            "xcode_build": "fixture", "swift_driver": "",
            "swift_sdk": "fixture",
            "staged_metallib_role": "staged_metallib",
            "staged_metallib_path_sha256": hex64,
            "staged_metallib_byte_count_and_content_sha256": [
                "byte_count": 1, "sha256": hex64,
            ],
            "runtime_metallib_role": "runtime_metallib",
            "runtime_metallib_path_sha256": hex64,
            "runtime_metallib_byte_count_and_content_sha256": [
                "byte_count": 1, "sha256": hex64,
            ],
            "metal_name_registry_unified_max_buffer_recommended_set": [
                "name": "fixture", "registry_id": 1,
                "has_unified_memory": true, "max_buffer_length": 1,
                "recommended_max_working_set_size": 17_179_869_184,
            ],
            "mlx_device_and_default_gpu_stream": [
                "device": "gpu:0", "default_stream": "gpu",
            ],
            "stream_order": "fixture", "evaluation_order": "fixture",
            "pre_post_identity_and_policy_equal": true,
            "root_and_validation_lock_bindings": inventory.compactMap {
                identity -> [String: Any]? in
                guard let role = identity["path_role"] as? String,
                      role == "immutable_root_lock"
                        || role == "immutable_validation_lock"
                else { return nil }
                return [
                    "path_role": role, "git_blob": identity["git_blob"]!,
                    "byte_count": identity["byte_count"]!,
                    "sha256": identity["sha256"]!,
                ]
            },
        ],
        "operation_counts": counts, "comparison_domain_results": domains,
        "first_mismatch_if_any": [
            "availability": "not_applicable", "domain_id": NSNull(),
            "path": NSNull(), "expected_binding": NSNull(),
            "observed_binding": NSNull(),
        ],
        "resource_phases": phases,
        "checkpoint_and_comparator_bindings": checkpoints,
        "artifact_cleanup_and_absence": [
            "initial_inventory_empty": true,
            "known_inventory_before_cleanup": 12,
            "unknown_inventory_count": 0, "deleted_known_leaf_count": 12,
            "deleted_private_comparator_count": 2,
            "post_cleanup_inventory_empty": true, "absence_proved": true,
            "recursive_cleanup_used": false, "artifact_upload_count": 0,
            "retained_artifact_count": 0,
        ],
        "lease_and_verifier": [
            "lease_acquired": true, "lease_release_count": 2,
            "verifier_executed": true, "verifier_exit_zero": true,
            "supervisor_alive_during_verifier": true,
            "preflight_parent": descriptor("preflight_parent", parent: true),
            "post_candidate_parent": descriptor(
                "post_candidate_parent", parent: true),
            "post_candidate_leaf": descriptor(
                "post_candidate_leaf", parent: false),
            "verifier_parent": descriptor("verifier_parent", parent: true),
            "verifier_leaf": descriptor("verifier_leaf", parent: false),
            "inventory_exact": true,
        ],
        "semantic_path_roles_and_path_sha256": semanticPaths,
    ]
}

// MARK: - Exact launcher bindings and private transport

private struct TrajectoryLauncherBindings {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution

    let executablePath: String
    let leaseRoot: String
    let leasePath: String
    let artifactRoot: String
    let stagedMetallibPath: String
    let stagedMetallibBytes: UInt64
    let stagedMetallibSHA256: String
    let runtimeMetallibPath: String
    let runtimeMetallibBytes: UInt64
    let runtimeMetallibSHA256: String
    let operatingSystemBuild: String
    let xcodeBuild: String
    let swiftDriver: String
    let swiftSDK: String
    let buildConfiguration: String
    let mlxOrigin: String
    let mlxRevision: String
    let mechanicsRevision: String
    let mechanicsTree: String
    let mechanicsOrderedParents: [String]
    let mechanicsRunID: UInt64
    let mechanicsRunNumber: UInt64
    let mechanicsRunAttempt: UInt64
    let implementationInventory: [[String: Any]]

    init(environment: [String: String]) throws {
        let names = Execution.environmentVariableNames
        let namespace =
            "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_"
        try trajectoryRequire(
            Set(environment.keys.filter { $0.hasPrefix(namespace) })
                == Set(names),
            "exact Stage-7 environment namespace")
        func required(_ suffix: String) throws -> String {
            let key = namespace + suffix
            guard let value = environment[key], !value.isEmpty else {
                throw TrajectoryExecutionError.contract(
                    "missing environment \(key)")
            }
            return value
        }
        func unsigned(_ suffix: String) throws -> UInt64 {
            let value = try required(suffix)
            guard let result = UInt64(value), String(result) == value else {
                throw TrajectoryExecutionError.contract(
                    "invalid unsigned environment \(suffix)")
            }
            return result
        }
        func canonicalStringArray(_ suffix: String) throws -> [String] {
            let value = try required(suffix)
            let data = Data(value.utf8)
            guard let result = try trajectoryCanonicalJSONObject(data)
                    as? [String]
            else {
                throw TrajectoryExecutionError.contract(
                    "invalid array environment \(suffix)")
            }
            return result
        }

        executablePath = try required("EXECUTABLE_PATH")
        leaseRoot = try required("LEASE_ROOT")
        leasePath = URL(fileURLWithPath: leaseRoot)
            .appendingPathComponent("device-0.lock").path
        artifactRoot = try required("ARTIFACT_ROOT")
        stagedMetallibPath = try required("STAGED_METALLIB_PATH")
        stagedMetallibBytes = try unsigned("STAGED_METALLIB_BYTES")
        stagedMetallibSHA256 = try required("STAGED_METALLIB_SHA256")
        runtimeMetallibPath = try required("RUNTIME_METALLIB_PATH")
        runtimeMetallibBytes = try unsigned("RUNTIME_METALLIB_BYTES")
        runtimeMetallibSHA256 = try required("RUNTIME_METALLIB_SHA256")
        operatingSystemBuild = try required("OPERATING_SYSTEM_BUILD")
        xcodeBuild = try required("XCODE_BUILD")
        swiftDriver = try required("SWIFT_DRIVER")
        swiftSDK = try required("SWIFT_SDK")
        buildConfiguration = try required("BUILD_CONFIGURATION")
        mlxOrigin = try required("EXACT_MLX_ORIGIN")
        mlxRevision = try required("EXACT_MLX_REVISION")

        let environmentAuthorityID = try required("AUTHORITY_ID")
        let environmentAuthoritySHA256 = try required(
            "AUTHORITY_CANONICAL_SHA256")
        try trajectoryRequire(
            environmentAuthorityID == Execution.authorityID
                && environmentAuthoritySHA256
                    == Execution.authorityCanonicalSHA256,
            "authority environment binding")
        let closureParents = try canonicalStringArray(
            "AUTHORITY_CLOSURE_ORDERED_PARENTS_JSON")
        let closureRevision = try required("AUTHORITY_CLOSURE_REVISION")
        let closureTree = try required("AUTHORITY_CLOSURE_TREE")
        let closureRunID = try unsigned("AUTHORITY_CLOSURE_RUN_ID")
        let closureRunNumber = try unsigned("AUTHORITY_CLOSURE_RUN_NUMBER")
        let closureRunAttempt = try unsigned("AUTHORITY_CLOSURE_RUN_ATTEMPT")
        let closureSuiteID = try unsigned(
            "AUTHORITY_CLOSURE_CHECK_SUITE_ID")
        let closureActiveJobID = try unsigned(
            "AUTHORITY_CLOSURE_ACTIVE_JOB_ID")
        let closureReviewedJobID = try unsigned(
            "AUTHORITY_CLOSURE_REVIEWED_JOB_ID")
        try trajectoryRequire(
            closureRevision == Execution.authorityClosureRevision
                && closureTree == Execution.authorityClosureTree
                && closureParents == Execution.authorityClosureOrderedParents
                && closureRunID == Execution.authorityClosureWorkflowRunID
                && closureRunNumber
                    == Execution.authorityClosureWorkflowRunNumber
                && closureRunAttempt == Execution.authorityClosureRunAttempt
                && closureSuiteID == Execution.authorityClosureCheckSuiteID
                && closureActiveJobID == Execution.authorityClosureActiveJobID
                && closureReviewedJobID
                    == Execution.authorityClosureReviewedJobID,
            "terminal green authority closure")

        mechanicsRevision = try required("MECHANICS_REVISION")
        mechanicsTree = try required("MECHANICS_TREE")
        mechanicsOrderedParents = try canonicalStringArray(
            "MECHANICS_ORDERED_PARENTS_JSON")
        mechanicsRunID = try unsigned("MECHANICS_RUN_ID")
        mechanicsRunNumber = try unsigned("MECHANICS_RUN_NUMBER")
        mechanicsRunAttempt = try unsigned("MECHANICS_RUN_ATTEMPT")
        try trajectoryRequire(
            trajectoryIsLowerHex(mechanicsRevision, count: 40)
                && trajectoryIsLowerHex(mechanicsTree, count: 40)
                && mechanicsOrderedParents.count == 2
                && mechanicsOrderedParents[0]
                    == Execution.authorityClosureRevision
                && mechanicsOrderedParents.allSatisfy({
                    trajectoryIsLowerHex($0, count: 40)
                })
                && mechanicsRunID > 0 && mechanicsRunNumber > 0
                && mechanicsRunAttempt == 1,
            "mechanics exact-main lineage")

        let inventoryText = try required("IMPLEMENTATION_INVENTORY_JSON")
        guard let decoded = try trajectoryCanonicalJSONObject(
                Data(inventoryText.utf8)) as? [[String: Any]],
              decoded.count == 17,
              decoded.allSatisfy(trajectoryValidImplementationIdentity)
        else {
            throw TrajectoryExecutionError.contract(
                "exact implementation inventory")
        }
        let frozenInventory: [[String: Any]] =
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
                .frozenV1.immutableImplementation.exactBaseSources.map {
                    [
                        "path_role": $0.role, "git_mode": $0.gitMode,
                        "git_blob": $0.gitBlob, "byte_count": $0.byteCount,
                        "lf_byte_count": $0.lfByteCount,
                        "sha256": $0.sha256,
                    ]
                }
        let decodedInventoryData = try trajectoryCanonicalJSONData(decoded)
        let frozenInventoryData = try trajectoryCanonicalJSONData(
            frozenInventory)
        try trajectoryRequire(
            decodedInventoryData == frozenInventoryData,
            "frozen exact-base implementation inventory")
        implementationInventory = decoded

        let expectedPhysicalExecutable = URL(fileURLWithPath: executablePath)
            .resolvingSymlinksInPath().standardizedFileURL.path
        let actualPhysicalExecutable = URL(
            fileURLWithPath: CommandLine.arguments[0])
            .resolvingSymlinksInPath().standardizedFileURL.path
        try trajectoryRequire(
            executablePath == expectedPhysicalExecutable
                && executablePath == actualPhysicalExecutable,
            "physical executable binding")
        for path in [
            leaseRoot, artifactRoot, stagedMetallibPath,
            runtimeMetallibPath,
        ] {
            try trajectoryRequire(
                path.hasPrefix("/")
                    && URL(fileURLWithPath: path)
                        .resolvingSymlinksInPath().standardizedFileURL.path
                        == path,
                "physical absolute runtime path")
        }
        try trajectoryRequire(
            buildConfiguration == "release"
                && mlxOrigin
                    == "https://github.com/Ergentics/ergentics-mlx-swift"
                && mlxRevision
                    == "d37885a278f1c37484a94d0f401a418735e66519"
                && stagedMetallibBytes > 0 && runtimeMetallibBytes > 0
                && trajectoryIsLowerHex(stagedMetallibSHA256, count: 64)
                && trajectoryIsLowerHex(runtimeMetallibSHA256, count: 64),
            "release MLX and metallib bindings")
    }

    var authorityAndPredecessorBindings: [String: Any] {
        [
            "authority_id": Execution.authorityID,
            "authority_canonical_sha256": Execution.authorityCanonicalSHA256,
            "repository": "Ergentics/ergentics-prime",
            "predecessor_main_revision": Execution.predecessorMainRevision,
            "authority_closure_revision": Execution.authorityClosureRevision,
            "authority_closure_tree": Execution.authorityClosureTree,
            "authority_closure_ordered_parents":
                Execution.authorityClosureOrderedParents,
            "authority_closure_run_id":
                Execution.authorityClosureWorkflowRunID,
            "authority_closure_run_number":
                Execution.authorityClosureWorkflowRunNumber,
            "authority_closure_run_attempt":
                Execution.authorityClosureRunAttempt,
            "authority_closure_check_suite_id":
                Execution.authorityClosureCheckSuiteID,
            "authority_closure_active_job_id":
                Execution.authorityClosureActiveJobID,
            "authority_closure_reviewed_job_id":
                Execution.authorityClosureReviewedJobID,
            "stage5_b_observation_sha256":
                "7e17cfdc59f63a775aa4ec5b797328e80c0ab75ef65b2b3ddd7f4bf8deb48ef9",
            "b_resource_observation_sha256":
                "da9edca25faaef6ae6fae38669692603faeb7c29f4995a0fce4a096015a49a88",
            "mechanics_revision": mechanicsRevision,
            "mechanics_tree": mechanicsTree,
            "mechanics_ordered_parents": mechanicsOrderedParents,
            "mechanics_run_id": mechanicsRunID,
            "mechanics_run_number": mechanicsRunNumber,
            "mechanics_run_attempt": mechanicsRunAttempt,
        ]
    }

    var rawPrivatePaths: [String: Any] {
        [
            "lease_root": leaseRoot, "lease_path": leasePath,
            "artifact_root": artifactRoot,
            "staged_metallib_path": stagedMetallibPath,
            "runtime_metallib_path": runtimeMetallibPath,
        ]
    }
}

private struct TrajectoryPrivateFrame {
    let canonicalData: Data
    let sha256: String
}

private func trajectoryWriteFrame(
    _ data: Data,
    maximumByteCount: Int,
    descriptor: Int32,
    absoluteDeadline: UInt64? = nil
) throws -> TrajectoryPrivateFrame {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    try trajectoryRequire(
        !data.isEmpty && data.count <= maximumByteCount,
        "private frame byte cap")
    _ = try trajectoryCanonicalJSONObject(data)
    let sha256 = PrimeSHA256.hexDigest(of: data)
    try trajectoryRawWriteAll(
        Data("\(data.count)\n".utf8),
        descriptor: descriptor,
        absoluteDeadline: absoluteDeadline)
    var offset = 0
    while offset < data.count {
        let end = min(
            data.count,
            offset + Execution.maximumFrameChunkByteCount)
        try trajectoryRawWriteAll(
            data.subdata(in: offset ..< end),
            descriptor: descriptor,
            absoluteDeadline: absoluteDeadline)
        offset = end
    }
    try trajectoryRawWriteAll(
        Data((sha256 + "\n").utf8),
        descriptor: descriptor,
        absoluteDeadline: absoluteDeadline)
    return .init(canonicalData: data, sha256: sha256)
}

private func trajectoryReadFrame(
    descriptor: Int32,
    maximumByteCount: Int,
    firstByteDeadline: UInt64,
    absoluteDeadline: UInt64,
    requireEOF: Bool
) throws -> TrajectoryPrivateFrame {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    try trajectoryRequire(
        firstByteDeadline <= absoluteDeadline,
        "private frame ordered deadlines")
    var lengthBytes = Data()
    let first = try trajectoryReadByte(
        descriptor: descriptor,
        deadline: firstByteDeadline)
    lengthBytes.append(first)
    let frameDeadline = min(
        absoluteDeadline,
        try trajectoryDeadline(afterSeconds: Execution.frameReadDeadlineSeconds))
    while lengthBytes.last != 0x0a {
        try trajectoryRequire(lengthBytes.count <= 20, "frame length line")
        lengthBytes.append(try trajectoryReadByte(
            descriptor: descriptor,
            deadline: frameDeadline))
    }
    let digits = lengthBytes.dropLast()
    guard !digits.isEmpty,
          digits.allSatisfy({ $0 >= 48 && $0 <= 57 }),
          digits.count == 1 || digits.first != 48,
          let length = Int(String(decoding: digits, as: UTF8.self)),
          length > 0, length <= maximumByteCount
    else {
        throw TrajectoryExecutionError.contract("canonical frame length")
    }
    var payload = Data()
    payload.reserveCapacity(length)
    while payload.count < length {
        let count = min(
            Execution.maximumFrameChunkByteCount,
            length - payload.count)
        payload.append(try trajectoryReadExact(
            descriptor: descriptor,
            count: count,
            deadline: frameDeadline))
    }
    var hashBytes = Data()
    while hashBytes.last != 0x0a {
        try trajectoryRequire(hashBytes.count <= 64, "frame hash line")
        hashBytes.append(try trajectoryReadByte(
            descriptor: descriptor,
            deadline: frameDeadline))
    }
    let hash = String(decoding: hashBytes.dropLast(), as: UTF8.self)
    try trajectoryRequire(
        trajectoryIsLowerHex(hash, count: 64)
            && hash == PrimeSHA256.hexDigest(of: payload),
        "frame SHA-256")
    try trajectoryRequire(
        DispatchTime.now().uptimeNanoseconds < absoluteDeadline,
        "private frame post-hash deadline")
    _ = try trajectoryCanonicalJSONObject(payload)
    if requireEOF {
        try trajectoryRequireFrameEOF(
            descriptor: descriptor,
            deadline: frameDeadline)
    }
    return .init(canonicalData: payload, sha256: hash)
}

private func trajectoryRequireFrameEOF(
    descriptor: Int32,
    deadline: UInt64
) throws {
    while true {
        let now = DispatchTime.now().uptimeNanoseconds
        try trajectoryRequire(now < deadline, "private frame EOF deadline")
        let remaining = deadline - now
        let milliseconds = min(
            UInt64(Int32.max),
            max(UInt64(1), remaining / 1_000_000))
        var pollDescriptor = pollfd(
            fd: descriptor,
            events: Int16(POLLIN | POLLHUP),
            revents: 0)
        let result = Darwin.poll(
            &pollDescriptor,
            1,
            Int32(milliseconds))
        if result < 0, errno == EINTR { continue }
        guard result > 0,
              pollDescriptor.revents & Int16(POLLNVAL | POLLERR) == 0
        else {
            throw TrajectoryExecutionError.contract(
                "private frame EOF timeout or descriptor failure")
        }
        var byte: UInt8 = 0
        let observed = Darwin.read(descriptor, &byte, 1)
        if observed < 0, errno == EINTR { continue }
        try trajectoryRequire(observed == 0, "frame trailing bytes")
        return
    }
}

private func trajectoryRawWriteAll(
    _ data: Data,
    descriptor: Int32,
    absoluteDeadline: UInt64?
) throws {
    try data.withUnsafeBytes { bytes in
        guard let base = bytes.baseAddress else { return }
        var offset = 0
        while offset < bytes.count {
            if let absoluteDeadline {
                let now = DispatchTime.now().uptimeNanoseconds
                try trajectoryRequire(
                    now < absoluteDeadline,
                    "private frame write deadline")
                let remaining = absoluteDeadline - now
                let milliseconds = min(
                    UInt64(Int32.max),
                    max(UInt64(1), remaining / 1_000_000))
                var pollDescriptor = pollfd(
                    fd: descriptor, events: Int16(POLLOUT), revents: 0)
                let pollResult = Darwin.poll(
                    &pollDescriptor, 1, Int32(milliseconds))
                if pollResult < 0, errno == EINTR { continue }
                try trajectoryRequire(
                    pollResult > 0
                        && pollDescriptor.revents
                            & Int16(POLLNVAL | POLLERR) == 0,
                    "private frame write poll")
            }
            let boundedCount = min(4_096, bytes.count - offset)
            let count = Darwin.write(
                descriptor,
                base.advanced(by: offset),
                boundedCount)
            if count < 0, errno == EINTR { continue }
            guard count > 0 else {
                throw TrajectoryExecutionError.posix(
                    "private frame write", errno)
            }
            offset += count
        }
    }
}

private func trajectoryReadByte(
    descriptor: Int32,
    deadline: UInt64
) throws -> UInt8 {
    let data = try trajectoryReadExact(
        descriptor: descriptor,
        count: 1,
        deadline: deadline)
    return data[0]
}

private func trajectoryReadExact(
    descriptor: Int32,
    count: Int,
    deadline: UInt64
) throws -> Data {
    var data = Data(count: count)
    var offset = 0
    while offset < count {
        let now = DispatchTime.now().uptimeNanoseconds
        try trajectoryRequire(now < deadline, "private frame deadline")
        let remaining = deadline - now
        let milliseconds = min(
            UInt64(Int32.max),
            max(UInt64(1), remaining / 1_000_000))
        var pollDescriptor = pollfd(
            fd: descriptor,
            events: Int16(POLLIN | POLLHUP),
            revents: 0)
        let pollResult = Darwin.poll(
            &pollDescriptor,
            1,
            Int32(milliseconds))
        if pollResult < 0, errno == EINTR { continue }
        guard pollResult > 0 else {
            throw TrajectoryExecutionError.contract("private frame timeout")
        }
        let readCount = data.withUnsafeMutableBytes { bytes in
            Darwin.read(
                descriptor,
                bytes.baseAddress!.advanced(by: offset),
                count - offset)
        }
        if readCount < 0, errno == EINTR { continue }
        guard readCount > 0 else {
            throw TrajectoryExecutionError.contract("private frame EOF")
        }
        offset += readCount
    }
    return data
}

private func trajectoryDeadline(afterSeconds seconds: UInt64) throws -> UInt64 {
    let delta = seconds.multipliedReportingOverflow(by: 1_000_000_000)
    let deadline = DispatchTime.now().uptimeNanoseconds
        .addingReportingOverflow(delta.partialValue)
    try trajectoryRequire(!delta.overflow && !deadline.overflow, "deadline")
    return deadline.partialValue
}

private func trajectoryDeadline(
    from start: UInt64,
    afterSeconds seconds: UInt64
) throws -> UInt64 {
    let delta = seconds.multipliedReportingOverflow(by: 1_000_000_000)
    let deadline = start.addingReportingOverflow(delta.partialValue)
    try trajectoryRequire(
        !delta.overflow && !deadline.overflow,
        "absolute process deadline")
    return deadline.partialValue
}

private func trajectoryRequireBeforeDeadline(
    _ deadline: UInt64,
    _ scope: String
) throws {
    try trajectoryRequire(
        DispatchTime.now().uptimeNanoseconds < deadline,
        "\(scope) supervisor deadline")
}

private func trajectoryCanonicalDecimal(_ value: Int) -> String {
    String(value)
}

private struct TrajectoryDescriptorObservation: Equatable {
    let physicalPath: String
    let deviceID: UInt64
    let inode: UInt64
    let uid: UInt64
    let gid: UInt64
    let mode: String
    let aclEntryCount: Int
    let xattrNames: [String]
    let securityFlags: UInt64
    let fileType: String
    let byteCount: UInt64
    let observedLinkCount: UInt64

    init(
        physicalPath: String,
        deviceID: UInt64,
        inode: UInt64,
        uid: UInt64,
        gid: UInt64,
        mode: String,
        aclEntryCount: Int,
        xattrNames: [String],
        securityFlags: UInt64,
        fileType: String,
        byteCount: UInt64,
        observedLinkCount: UInt64
    ) {
        self.physicalPath = physicalPath
        self.deviceID = deviceID
        self.inode = inode
        self.uid = uid
        self.gid = gid
        self.mode = mode
        self.aclEntryCount = aclEntryCount
        self.xattrNames = xattrNames
        self.securityFlags = securityFlags
        self.fileType = fileType
        self.byteCount = byteCount
        self.observedLinkCount = observedLinkCount
    }

    var parentDictionary: [String: Any] {
        [
            "physical_path": physicalPath, "device_id": deviceID,
            "inode": inode, "uid": uid, "gid": gid, "mode": mode,
            "acl": aclEntryCount, "xattr_names": xattrNames,
            "security_flags": securityFlags, "file_type": fileType,
            "observed_nlink": observedLinkCount,
        ]
    }

    var leaseDictionary: [String: Any] {
        [
            "device_id": deviceID, "inode": inode, "uid": uid, "gid": gid,
            "mode": mode, "acl": aclEntryCount, "xattr_names": xattrNames,
            "security_flags": securityFlags, "file_type": fileType,
            "byte_count": byteCount, "observed_nlink": observedLinkCount,
        ]
    }

    init(parentDictionary dictionary: [String: Any]) throws {
        typealias Execution =
            PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
        guard Set(dictionary.keys)
                == Set(Execution.privateParentDescriptorTupleKeys),
              let physicalPath = dictionary["physical_path"] as? String,
              let deviceID = trajectoryExactUInt64(dictionary["device_id"]),
              let inode = trajectoryExactUInt64(dictionary["inode"]),
              let uid = trajectoryExactUInt64(dictionary["uid"]),
              let gid = trajectoryExactUInt64(dictionary["gid"]),
              let mode = dictionary["mode"] as? String,
              let aclEntryCountValue = trajectoryExactUInt64(
                  dictionary["acl"]),
              aclEntryCountValue <= UInt64(Int.max),
              let xattrNames = dictionary["xattr_names"] as? [String],
              let securityFlags = trajectoryExactUInt64(
                  dictionary["security_flags"]),
              let fileType = dictionary["file_type"] as? String,
              let observedLinkCount = trajectoryExactUInt64(
                  dictionary["observed_nlink"])
        else {
            throw TrajectoryExecutionError.contract(
                "private descriptor tuple schema")
        }
        self.init(
            physicalPath: physicalPath, deviceID: deviceID, inode: inode,
            uid: uid, gid: gid, mode: mode,
            aclEntryCount: Int(aclEntryCountValue), xattrNames: xattrNames,
            securityFlags: securityFlags, fileType: fileType,
            byteCount: 0, observedLinkCount: observedLinkCount)
    }

    init(
        leaseDictionary dictionary: [String: Any],
        physicalPath: String
    ) throws {
        typealias Execution =
            PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
        guard Set(dictionary.keys)
                == Set(Execution.privateLeaseDescriptorTupleKeys),
              let deviceID = trajectoryExactUInt64(dictionary["device_id"]),
              let inode = trajectoryExactUInt64(dictionary["inode"]),
              let uid = trajectoryExactUInt64(dictionary["uid"]),
              let gid = trajectoryExactUInt64(dictionary["gid"]),
              let mode = dictionary["mode"] as? String,
              let aclEntryCountValue = trajectoryExactUInt64(
                  dictionary["acl"]),
              aclEntryCountValue <= UInt64(Int.max),
              let xattrNames = dictionary["xattr_names"] as? [String],
              let securityFlags = trajectoryExactUInt64(
                  dictionary["security_flags"]),
              let fileType = dictionary["file_type"] as? String,
              let byteCount = trajectoryExactUInt64(dictionary["byte_count"]),
              let observedLinkCount = trajectoryExactUInt64(
                  dictionary["observed_nlink"])
        else {
            throw TrajectoryExecutionError.contract(
                "private lease descriptor tuple schema")
        }
        self.init(
            physicalPath: physicalPath, deviceID: deviceID, inode: inode,
            uid: uid, gid: gid, mode: mode,
            aclEntryCount: Int(aclEntryCountValue), xattrNames: xattrNames,
            securityFlags: securityFlags, fileType: fileType,
            byteCount: byteCount, observedLinkCount: observedLinkCount)
    }

    func stableParentEquals(_ other: Self) -> Bool {
        physicalPath == other.physicalPath
            && deviceID == other.deviceID && inode == other.inode
            && uid == other.uid && gid == other.gid && mode == other.mode
            && fileType == other.fileType
    }

    func stableLeafEquals(_ other: Self) -> Bool {
        stableParentEquals(other)
            && aclEntryCount == other.aclEntryCount
            && xattrNames == other.xattrNames
            && securityFlags == other.securityFlags
            && byteCount == other.byteCount
            && observedLinkCount == other.observedLinkCount
    }

    var satisfiesObservedCleanPolicy: Bool {
        aclEntryCount == 0 && securityFlags == 0
            && Set(xattrNames).isSubset(of: trajectoryAllowedXattrs)
            && xattrNames.count == Set(xattrNames).count
    }
}

private struct TrajectoryDirectoryObservation {
    let tuple: TrajectoryDescriptorObservation
    let inventory: [String]
}

private let trajectoryAllowedXattrs: Set<String> = [
    "com.apple.provenance",
]

private func trajectoryObserveDirectory(
    _ path: String
) throws -> TrajectoryDirectoryObservation {
    let physical = URL(fileURLWithPath: path)
        .resolvingSymlinksInPath().standardizedFileURL.path
    try trajectoryRequire(physical == path, "directory physical path")
    let descriptor = Darwin.open(
        path,
        O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
    guard descriptor >= 0 else {
        throw TrajectoryExecutionError.posix("open private directory", errno)
    }
    defer { _ = Darwin.close(descriptor) }
    let tuple = try trajectoryDescriptorObservation(
        descriptor: descriptor,
        physicalPath: path,
        expectedType: S_IFDIR)
    try trajectoryRequire(
        tuple.uid == UInt64(geteuid()) && tuple.mode == "0700"
            && tuple.aclEntryCount == 0 && tuple.securityFlags == 0,
        "private directory policy")
    return .init(
        tuple: tuple,
        inventory: try trajectoryDirectoryInventory(descriptor))
}

private func trajectoryObserveLease(
    _ path: String,
    expectedParent: TrajectoryDescriptorObservation
) throws -> TrajectoryDescriptorObservation {
    let parentPath = URL(fileURLWithPath: path)
        .deletingLastPathComponent().path
    let leaf = URL(fileURLWithPath: path).lastPathComponent
    let parent = Darwin.open(
        parentPath,
        O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC)
    guard parent >= 0 else {
        throw TrajectoryExecutionError.posix("open lease parent", errno)
    }
    defer { _ = Darwin.close(parent) }
    let parentTuple = try trajectoryDescriptorObservation(
        descriptor: parent,
        physicalPath: parentPath,
        expectedType: S_IFDIR)
    try trajectoryRequire(
        parentTuple.deviceID == expectedParent.deviceID
            && parentTuple.inode == expectedParent.inode,
        "lease parent identity")
    let descriptor = leaf.withCString {
        openat(parent, $0, O_RDWR | O_NOFOLLOW | O_CLOEXEC)
    }
    guard descriptor >= 0 else {
        throw TrajectoryExecutionError.posix("open lease leaf", errno)
    }
    defer { _ = Darwin.close(descriptor) }
    let tuple = try trajectoryDescriptorObservation(
        descriptor: descriptor,
        physicalPath: path,
        expectedType: S_IFREG)
    var named = stat()
    let rebound = leaf.withCString {
        fstatat(parent, $0, &named, AT_SYMLINK_NOFOLLOW)
    }
    try trajectoryRequire(
        rebound == 0 && named.st_mode & S_IFMT == S_IFREG
            && tuple.deviceID == UInt64(truncatingIfNeeded: named.st_dev)
            && tuple.inode == UInt64(named.st_ino)
            && tuple.uid == UInt64(geteuid()) && tuple.mode == "0600"
            && tuple.observedLinkCount == 1 && tuple.byteCount == 0
            && tuple.aclEntryCount == 0 && tuple.securityFlags == 0,
        "lease leaf policy")
    return tuple
}

private func trajectoryDescriptorObservation(
    descriptor: Int32,
    physicalPath: String,
    expectedType: mode_t
) throws -> TrajectoryDescriptorObservation {
    var status = stat()
    guard fstat(descriptor, &status) == 0 else {
        throw TrajectoryExecutionError.posix("fstat descriptor", errno)
    }
    try trajectoryRequire(
        status.st_mode & S_IFMT == expectedType,
        "descriptor file type")
    let xattrs = try trajectoryExtendedAttributes(descriptor)
    let aclCount = try trajectoryACLEntryCount(descriptor)
    return .init(
        physicalPath: physicalPath,
        deviceID: UInt64(truncatingIfNeeded: status.st_dev),
        inode: UInt64(status.st_ino), uid: UInt64(status.st_uid),
        gid: UInt64(status.st_gid),
        mode: String(format: "%04o", UInt32(status.st_mode & 0o7777)),
        aclEntryCount: aclCount, xattrNames: xattrs,
        securityFlags: UInt64(status.st_flags),
        fileType: expectedType == S_IFDIR ? "directory" : "regular_file",
        byteCount: UInt64(max(off_t(0), status.st_size)),
        observedLinkCount: UInt64(status.st_nlink))
}

private func trajectoryExtendedAttributes(_ descriptor: Int32) throws
    -> [String]
{
    errno = 0
    let size = flistxattr(descriptor, nil, 0, 0)
    if size < 0 {
        if errno == ENOTSUP { return [] }
        throw TrajectoryExecutionError.posix("flistxattr", errno)
    }
    if size == 0 { return [] }
    try trajectoryRequire(size <= 65_536, "xattr byte cap")
    var names = [CChar](repeating: 0, count: size)
    let actual = names.withUnsafeMutableBufferPointer {
        flistxattr(descriptor, $0.baseAddress, $0.count, 0)
    }
    guard actual == size else {
        throw TrajectoryExecutionError.posix("flistxattr read", errno)
    }
    let bytes = names.prefix(actual).map { UInt8(bitPattern: $0) }
    var start = bytes.startIndex
    var result = Set<String>()
    for index in bytes.indices where bytes[index] == 0 {
        try trajectoryRequire(start < index, "xattr name")
        result.insert(String(decoding: bytes[start ..< index], as: UTF8.self))
        start = bytes.index(after: index)
    }
    try trajectoryRequire(
        start == bytes.endIndex
            && result.isSubset(of: trajectoryAllowedXattrs),
        "xattr policy")
    return result.sorted()
}

private func trajectoryACLEntryCount(_ descriptor: Int32) throws -> Int {
    errno = 0
    guard let acl = acl_get_fd_np(descriptor, ACL_TYPE_EXTENDED) else {
        if errno == ENOENT || errno == ENOTSUP { return 0 }
        throw TrajectoryExecutionError.posix("acl_get_fd_np", errno)
    }
    defer { acl_free(UnsafeMutableRawPointer(acl)) }
    var count = 0
    var entry: acl_entry_t?
    var selector = ACL_FIRST_ENTRY.rawValue
    while true {
        let result = acl_get_entry(acl, selector, &entry)
        if result == 1 {
            count += 1
            selector = ACL_NEXT_ENTRY.rawValue
        } else if result == 0 {
            return count
        } else {
            throw TrajectoryExecutionError.posix("acl_get_entry", errno)
        }
    }
}

private func trajectoryDirectoryInventory(_ descriptor: Int32) throws
    -> [String]
{
    let duplicate = dup(descriptor)
    guard duplicate >= 0, let directory = fdopendir(duplicate) else {
        if duplicate >= 0 { _ = Darwin.close(duplicate) }
        throw TrajectoryExecutionError.posix("fdopendir", errno)
    }
    defer { _ = closedir(directory) }
    var result = [String]()
    while let entry = readdir(directory) {
        let name = withUnsafePointer(to: &entry.pointee.d_name) { pointer in
            pointer.withMemoryRebound(
                to: CChar.self,
                capacity: Int(entry.pointee.d_namlen) + 1
            ) { String(cString: $0) }
        }
        if name != "." && name != ".." { result.append(name) }
    }
    try trajectoryRequire(
        Set(result).count == result.count,
        "unique directory inventory")
    return result.sorted(by: trajectoryRawUTF8Less)
}

private struct TrajectorySpawnedProcess {
    let pid: pid_t
    let readDescriptor: Int32
    let startNanoseconds: UInt64
}

private struct TrajectoryWaitResult {
    let exitCode: Int32?
    let signal: Int32?
    let timeout: Bool
}

private func trajectoryWaitExited(_ status: Int32) -> Bool {
    (status & 0x7f) == 0
}

private func trajectoryWaitExitCode(_ status: Int32) -> Int32 {
    (status >> 8) & 0xff
}

private func trajectoryWaitSignaled(_ status: Int32) -> Bool {
    let low = status & 0x7f
    return low != 0 && low != 0x7f
}

private func trajectoryWaitSignal(_ status: Int32) -> Int32 {
    status & 0x7f
}

private func trajectoryRelocateDescriptor(
    _ descriptor: inout Int32,
    forbidden: Set<Int32>,
    minimum: Int32
) throws {
    guard forbidden.contains(descriptor) else { return }
    let replacement = fcntl(descriptor, F_DUPFD_CLOEXEC, minimum)
    guard replacement >= 0 else {
        throw TrajectoryExecutionError.posix("relocate descriptor", errno)
    }
    _ = Darwin.close(descriptor)
    descriptor = replacement
}

private func trajectorySetCloseOnExec(_ descriptor: Int32) throws {
    let flags = fcntl(descriptor, F_GETFD)
    guard flags >= 0,
          fcntl(descriptor, F_SETFD, flags | FD_CLOEXEC) == 0
    else {
        throw TrajectoryExecutionError.posix("set FD_CLOEXEC", errno)
    }
}

private func trajectorySpawn(
    executable: String,
    arguments: [String],
    outputDescriptor: Int32
) throws -> pid_t {
    var actions: posix_spawn_file_actions_t?
    var attributes: posix_spawnattr_t?
    guard posix_spawn_file_actions_init(&actions) == 0,
          posix_spawnattr_init(&attributes) == 0
    else {
        throw TrajectoryExecutionError.contract("posix_spawn init")
    }
    defer {
        _ = posix_spawn_file_actions_destroy(&actions)
        _ = posix_spawnattr_destroy(&attributes)
    }
    let actionCodes = [
        posix_spawn_file_actions_addopen(
            &actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0),
        posix_spawn_file_actions_adddup2(
            &actions, outputDescriptor, STDOUT_FILENO),
        posix_spawn_file_actions_addopen(
            &actions, STDERR_FILENO, "/dev/null", O_WRONLY, 0),
        posix_spawn_file_actions_addclose(&actions, outputDescriptor),
    ]
    if let failure = actionCodes.first(where: { $0 != 0 }) {
        throw TrajectoryExecutionError.posix("posix_spawn action", failure)
    }
    var code = posix_spawnattr_setpgroup(&attributes, 0)
    guard code == 0 else {
        throw TrajectoryExecutionError.posix("posix_spawn pgroup", code)
    }
    let flags = UInt16(POSIX_SPAWN_SETPGROUP)
        | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
    code = posix_spawnattr_setflags(
        &attributes,
        Int16(bitPattern: flags))
    guard code == 0 else {
        throw TrajectoryExecutionError.posix("posix_spawn flags", code)
    }
    let argvStrings = [executable] + arguments
    let envStrings = ProcessInfo.processInfo.environment
        .map { "\($0.key)=\($0.value)" }.sorted()
    let argvAllocated = argvStrings.map { string in
        string.withCString { strdup($0) }
    }
    let envAllocated = envStrings.map { string in
        string.withCString { strdup($0) }
    }
    guard argvAllocated.allSatisfy({ $0 != nil }),
          envAllocated.allSatisfy({ $0 != nil })
    else {
        argvAllocated.forEach { free($0) }
        envAllocated.forEach { free($0) }
        throw TrajectoryExecutionError.posix("spawn strings", ENOMEM)
    }
    let argvPointers = argvAllocated.map { $0! }
    let envPointers = envAllocated.map { $0! }
    defer {
        argvPointers.forEach { free($0) }
        envPointers.forEach { free($0) }
    }
    var argv: [UnsafeMutablePointer<CChar>?] =
        argvPointers.map { Optional($0) } + [nil]
    var envp: [UnsafeMutablePointer<CChar>?] =
        envPointers.map { Optional($0) } + [nil]
    var pid: pid_t = 0
    code = argv.withUnsafeMutableBufferPointer { argvBuffer in
        envp.withUnsafeMutableBufferPointer { envBuffer in
            posix_spawn(
                &pid,
                executable,
                &actions,
                &attributes,
                argvBuffer.baseAddress,
                envBuffer.baseAddress)
        }
    }
    guard code == 0, pid > 0 else {
        throw TrajectoryExecutionError.posix(
            "posix_spawn", code == 0 ? ECHILD : code)
    }
    return pid
}

private func trajectorySpawnWorker(
    bindings: TrajectoryLauncherBindings
) throws -> TrajectorySpawnedProcess {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    var descriptors = [Int32](repeating: -1, count: 2)
    guard Darwin.pipe(&descriptors) == 0 else {
        throw TrajectoryExecutionError.posix("worker pipe", errno)
    }
    var readDescriptor = descriptors[0]
    var writeDescriptor = descriptors[1]
    do {
        try trajectoryRelocateDescriptor(
            &readDescriptor,
            forbidden: [STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO,
                        Execution.workerFrameDescriptor],
            minimum: Execution.workerFrameDescriptor + 1)
        try trajectoryRelocateDescriptor(
            &writeDescriptor,
            forbidden: [STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO,
                        Execution.workerFrameDescriptor],
            minimum: Execution.workerFrameDescriptor + 1)
        try trajectorySetCloseOnExec(readDescriptor)
        try trajectorySetCloseOnExec(writeDescriptor)

        var actions: posix_spawn_file_actions_t?
        var attributes: posix_spawnattr_t?
        guard posix_spawn_file_actions_init(&actions) == 0,
              posix_spawnattr_init(&attributes) == 0
        else {
            throw TrajectoryExecutionError.contract("worker spawn init")
        }
        defer {
            _ = posix_spawn_file_actions_destroy(&actions)
            _ = posix_spawnattr_destroy(&attributes)
        }
        let actionCodes = [
            posix_spawn_file_actions_addopen(
                &actions, STDIN_FILENO, "/dev/null", O_RDONLY, 0),
            posix_spawn_file_actions_addopen(
                &actions, STDOUT_FILENO, "/dev/null", O_WRONLY, 0),
            posix_spawn_file_actions_addopen(
                &actions, STDERR_FILENO, "/dev/null", O_WRONLY, 0),
            posix_spawn_file_actions_addclose(&actions, readDescriptor),
            posix_spawn_file_actions_adddup2(
                &actions, writeDescriptor, Execution.workerFrameDescriptor),
            posix_spawn_file_actions_addclose(&actions, writeDescriptor),
        ]
        if let failure = actionCodes.first(where: { $0 != 0 }) {
            throw TrajectoryExecutionError.posix("worker spawn action", failure)
        }
        var code = posix_spawnattr_setpgroup(&attributes, 0)
        try trajectoryRequire(code == 0, "worker pgroup")
        let flags = UInt16(POSIX_SPAWN_SETPGROUP)
            | UInt16(POSIX_SPAWN_CLOEXEC_DEFAULT)
        code = posix_spawnattr_setflags(
            &attributes,
            Int16(bitPattern: flags))
        try trajectoryRequire(code == 0, "worker spawn flags")
        let argumentStrings = [
            bindings.executablePath, Execution.workerArgument,
            "--frame-descriptor=\(Execution.workerFrameDescriptor)",
        ]
        let environmentStrings = ProcessInfo.processInfo.environment
            .map { "\($0.key)=\($0.value)" }.sorted()
        let allocatedArguments = argumentStrings.map { string in
            string.withCString { strdup($0) }
        }
        let allocatedEnvironment = environmentStrings.map { string in
            string.withCString { strdup($0) }
        }
        guard allocatedArguments.allSatisfy({ $0 != nil }),
              allocatedEnvironment.allSatisfy({ $0 != nil })
        else {
            allocatedArguments.forEach { free($0) }
            allocatedEnvironment.forEach { free($0) }
            throw TrajectoryExecutionError.posix("worker strings", ENOMEM)
        }
        let argumentPointers = allocatedArguments.map { $0! }
        let environmentPointers = allocatedEnvironment.map { $0! }
        defer {
            argumentPointers.forEach { free($0) }
            environmentPointers.forEach { free($0) }
        }
        var argv: [UnsafeMutablePointer<CChar>?] =
            argumentPointers.map { Optional($0) } + [nil]
        var envp: [UnsafeMutablePointer<CChar>?] =
            environmentPointers.map { Optional($0) } + [nil]
        var child: pid_t = 0
        let start = DispatchTime.now().uptimeNanoseconds
        code = argv.withUnsafeMutableBufferPointer { argvBuffer in
            envp.withUnsafeMutableBufferPointer { envBuffer in
                posix_spawn(
                    &child,
                    bindings.executablePath,
                    &actions,
                    &attributes,
                    argvBuffer.baseAddress,
                    envBuffer.baseAddress)
            }
        }
        guard code == 0, child > 0 else {
            throw TrajectoryExecutionError.posix(
                "spawn worker", code == 0 ? ECHILD : code)
        }
        _ = Darwin.close(writeDescriptor)
        writeDescriptor = -1
        return .init(
            pid: child,
            readDescriptor: readDescriptor,
            startNanoseconds: start)
    } catch {
        if readDescriptor >= 0 { _ = Darwin.close(readDescriptor) }
        if writeDescriptor >= 0 { _ = Darwin.close(writeDescriptor) }
        throw error
    }
}

private func trajectoryWaitForProcess(
    _ pid: pid_t,
    absoluteDeadline: UInt64
) throws -> TrajectoryWaitResult {
    while true {
        var status: Int32 = 0
        let result = waitpid(pid, &status, WNOHANG)
        if result == pid {
            // Reaping the process-group leader is not sufficient: a forked
            // descendant could otherwise outlive the supervisor.  A clean
            // protocol exit is accepted only when the negative PGID is absent.
            if trajectoryProcessGroupExists(pid) {
                let contained = trajectoryContainProcess(pid)
                try trajectoryRequire(
                    contained,
                    "descendant process group containment after leader exit")
                throw TrajectoryExecutionError.contract(
                    "child left a live process-group descendant")
            }
            if trajectoryWaitExited(status) {
                return .init(
                    exitCode: trajectoryWaitExitCode(status),
                    signal: nil,
                    timeout: false)
            }
            if trajectoryWaitSignaled(status) {
                return .init(
                    exitCode: nil,
                    signal: trajectoryWaitSignal(status),
                    timeout: false)
            }
            continue
        }
        if result < 0, errno != EINTR {
            throw TrajectoryExecutionError.posix("waitpid", errno)
        }
        let now = DispatchTime.now().uptimeNanoseconds
        if now >= absoluteDeadline {
            let contained = trajectoryContainProcess(pid)
            try trajectoryRequire(
                contained && !trajectoryProcessGroupExists(pid),
                "timed-out process-group absence")
            return .init(
                exitCode: nil,
                signal: SIGKILL,
                timeout: true)
        }
        usleep(10_000)
    }
}

private func trajectoryProcessGroupExists(_ pid: pid_t) -> Bool {
    while true {
        if Darwin.kill(-pid, 0) == 0 { return true }
        if errno == EINTR { continue }
        return errno != ESRCH
    }
}

/// Contains the whole child process group, reaps its leader, and proves the
/// negative PGID is absent.  The second bounded interval is only a post-KILL
/// absence/reap proof; TERM receives the exact frozen ten-second grace.
@discardableResult
private func trajectoryContainProcess(_ pid: pid_t) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    _ = Darwin.kill(-pid, SIGTERM)
    let grace = Execution.terminationGraceSeconds
        .multipliedReportingOverflow(by: 1_000_000_000)
    guard !grace.overflow else { return false }
    func deadlineFromNow() -> UInt64 {
        let value = DispatchTime.now().uptimeNanoseconds
            .addingReportingOverflow(grace.partialValue)
        return value.overflow ? UInt64.max : value.partialValue
    }
    var leaderReaped = false
    let termDeadline = deadlineFromNow()
    while DispatchTime.now().uptimeNanoseconds < termDeadline {
        var status: Int32 = 0
        let result = waitpid(pid, &status, WNOHANG)
        if result == pid || (result < 0 && errno == ECHILD) {
            leaderReaped = true
        } else if result < 0 && errno != EINTR {
            return false
        }
        if leaderReaped && !trajectoryProcessGroupExists(pid) { return true }
        usleep(10_000)
    }
    _ = Darwin.kill(-pid, SIGKILL)
    let killProofDeadline = deadlineFromNow()
    while DispatchTime.now().uptimeNanoseconds < killProofDeadline {
        if !leaderReaped {
            var status: Int32 = 0
            let result = waitpid(pid, &status, WNOHANG)
            if result == pid || (result < 0 && errno == ECHILD) {
                leaderReaped = true
            } else if result < 0 && errno != EINTR {
                return false
            }
        }
        if leaderReaped && !trajectoryProcessGroupExists(pid) { return true }
        usleep(10_000)
    }
    return leaderReaped && !trajectoryProcessGroupExists(pid)
}

extension
    PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
{
    /// Dispatches the one public supervisor entry and the two exact private
    /// exec roles.  Unknown modes fail before any Metal or MLX call.
    public static func runSupervisor() {
        let arguments = CommandLine.arguments
        if arguments.count == 3,
           arguments[1] == workerArgument,
           arguments[2] == "--frame-descriptor=\(workerFrameDescriptor)"
        {
            // This is the first instruction executed for the worker role.  Its
            // epoch therefore includes binding parsing, environment/metallib
            // observation, Metal admission, artifact setup, and all science.
            let workerEpoch = DispatchTime.now().uptimeNanoseconds
            trajectoryRunWorkerProcess(workerEpoch: workerEpoch)
        }
        if arguments.count == 2, arguments[1] == verifierArgument {
            trajectoryRunReleaseVerifierProcess()
        }
        guard arguments.count == 1 else {
            _exit(64)
        }
        // Start the supervisor-role clock before binding/environment parsing;
        // the 5,100-second closure deadline covers every later operation.
        let supervisorStart = DispatchTime.now().uptimeNanoseconds
        do {
            let bindings = try TrajectoryLauncherBindings(
                environment: ProcessInfo.processInfo.environment)
            try trajectoryRunSupervisorProcess(
                bindings: bindings,
                supervisorStart: supervisorStart)
        } catch {
            let message = "Stage-7 supervisor failed before a valid private terminal: \(error)\n"
            message.withCString { _ = fputs($0, stderr) }
            _exit(2)
        }
    }
}

private func trajectoryRunSupervisorProcess(
    bindings: TrajectoryLauncherBindings,
    supervisorStart: UInt64
) throws -> Never {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let supervisorDelta = Execution.supervisorTimeoutSeconds
        .multipliedReportingOverflow(by: 1_000_000_000)
    let supervisorDeadline = supervisorStart.addingReportingOverflow(
        supervisorDelta.partialValue)
    try trajectoryRequire(
        !supervisorDelta.overflow && !supervisorDeadline.overflow,
        "supervisor deadline")
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "supervisor binding validation")
    try Execution.validatePureContractV1()
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "pure contract validation")

    // No CoreGraphics, Metal, or MLX operation precedes this nonblocking
    // supervisor-owned lease acquisition.
    let preflightParent = try trajectoryObserveDirectory(bindings.leaseRoot)
    try trajectoryRequire(
        preflightParent.inventory.isEmpty,
        "preflight lease inventory empty")
    let preflightArtifacts = try trajectoryObserveDirectory(
        bindings.artifactRoot)
    try trajectoryRequire(
        preflightArtifacts.inventory.isEmpty,
        "preflight artifact inventory empty")
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "pre-lease descriptor observations")
    let lease: PrimeMetalDeviceLease
    do {
        lease = try PrimeMetalDeviceLease.acquire(
            at: URL(fileURLWithPath: bindings.leasePath))
    } catch {
        // Lease unavailability consumes the launcher one-shot but is one of
        // the frozen no-public-receipt classes.  No private frame is emitted.
        throw error
    }
    try trajectoryRequire(lease.isHeld, "supervisor lease held")
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "supervisor lease acquisition")
    var released = false
    defer {
        if !released { lease.release() }
    }

    let worker = try trajectorySpawnWorker(bindings: bindings)
    // Install containment immediately after spawn, before any throwable
    // deadline arithmetic or protocol work.
    var workerLive = true
    defer {
        if workerLive { trajectoryContainProcess(worker.pid) }
    }
    var workerDescriptor = worker.readDescriptor
    defer {
        if workerDescriptor >= 0 { _ = Darwin.close(workerDescriptor) }
    }
    let workerScienceDeadline = try trajectoryDeadline(
        from: worker.startNanoseconds,
        afterSeconds: Execution.workerTimeoutSeconds)
    let workerClosureDeadline = supervisorDeadline.partialValue
    try trajectoryRequire(
        workerScienceDeadline < workerClosureDeadline,
        "worker science timeout precedes safe cleanup closure deadline")
    let candidateFrame: TrajectoryPrivateFrame
    do {
        candidateFrame = try trajectoryReadFrame(
            descriptor: workerDescriptor,
            maximumByteCount:
                Execution.maximumPrivateCandidateCanonicalByteCount,
            firstByteDeadline: workerClosureDeadline,
            absoluteDeadline: workerClosureDeadline,
            requireEOF: true)
    } catch {
        _ = Darwin.close(workerDescriptor)
        workerDescriptor = -1
        throw error
    }
    _ = Darwin.close(workerDescriptor)
    workerDescriptor = -1
    let workerWait = try trajectoryWaitForProcess(
        worker.pid,
        absoluteDeadline: workerClosureDeadline)
    workerLive = false
    try trajectoryRequire(
        workerWait.exitCode == 0 && workerWait.signal == nil
            && !workerWait.timeout,
        "worker clean exit")
    let candidate = try trajectoryValidatePrivateCandidate(
        candidateFrame.canonicalData,
        bindings: bindings)
    if let mismatch = candidate["first_mismatch"] as? [String: Any],
       mismatch["domain_id"] as? String
        == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure"
    {
        try trajectoryRequire(
            DispatchTime.now().uptimeNanoseconds >= workerScienceDeadline,
            "safe worker timeout reached full-lifetime science deadline")
    }
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "candidate validation")

    let postArtifacts = try trajectoryObserveDirectory(bindings.artifactRoot)
    try trajectoryRequire(
        postArtifacts.tuple.stableParentEquals(preflightArtifacts.tuple)
            && postArtifacts.inventory.isEmpty,
        "post-candidate artifact absence")
    let postParent = try trajectoryObserveDirectory(bindings.leaseRoot)
    try trajectoryRequire(
        postParent.tuple.stableParentEquals(preflightParent.tuple)
            && postParent.inventory == ["device-0.lock"],
        "post-candidate lease inventory")
    let postLease = try trajectoryObserveLease(
        bindings.leasePath,
        expectedParent: postParent.tuple)
    try trajectoryRequire(
        lease.isHeld,
        "lease held through candidate cleanup and postflight")
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "candidate artifact and lease postflight")

    // This explicit Void-returning call is the first release.  The distinct
    // verifier below performs the second acquire/release while this supervisor
    // process remains alive.
    lease.release()
    released = true
    let verifier = try trajectoryRunVerifierFromSupervisor(
        bindings: bindings,
        supervisorDeadline: supervisorDeadline.partialValue)
    guard let verifierParent = verifier["parent"] as? [String: Any],
          let verifierLeaf = verifier["leaf"] as? [String: Any],
          trajectoryExactBool(verifier["acquired"]) == true,
          trajectoryExactBool(verifier["released"]) == true
    else {
        // Release-verifier integrity failure is frozen as no-public-receipt.
        throw TrajectoryExecutionError.contract("release verifier evidence")
    }
    let parsedVerifierParent = try TrajectoryDescriptorObservation(
        parentDictionary: verifierParent)
    let parsedVerifierLeaf = try TrajectoryDescriptorObservation(
        leaseDictionary: verifierLeaf,
        physicalPath: bindings.leasePath)
    try trajectoryRequire(
        parsedVerifierParent.stableParentEquals(postParent.tuple)
            && parsedVerifierParent.satisfiesObservedCleanPolicy
            && parsedVerifierLeaf.stableLeafEquals(postLease)
            && parsedVerifierLeaf.satisfiesObservedCleanPolicy
            && parsedVerifierLeaf.byteCount == 0
            && parsedVerifierLeaf.observedLinkCount == 1,
        "release verifier descriptor identity and policy")
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "release verifier validation")

    let status = candidate["terminal_scientific_status"] as! String
    let cleanup = candidate["artifact_inventory_and_cleanup"]
        as! [String: Any]
    let failedGuard: [String: Any]
    if status == "PASS_EXACT" || status == "MEASURED_EXACT_MISMATCH" {
        failedGuard = [
            "availability": "not_applicable", "guard_id": NSNull(),
            "classification": NSNull(), "errno": NSNull(),
            "detail": NSNull(),
        ]
    } else {
        let mismatch = candidate["first_mismatch"] as! [String: Any]
        let guardID = mismatch["domain_id"] as! String
        let positiveErrno: Any
        if guardID == "positively_identified_enomem" {
            positiveErrno = UInt64(ENOMEM)
        } else if guardID == "positively_identified_enospc" {
            positiveErrno = UInt64(ENOSPC)
        } else {
            positiveErrno = NSNull()
        }
        failedGuard = [
            "availability": "available",
            "guard_id": guardID,
            "classification": status, "errno": positiveErrno,
            "detail": mismatch["observed_binding"] ?? "worker_abstain",
        ]
    }
    let terminal: [String: Any] = [
        "schema": Execution.terminalSchemaID,
        "candidate_byte_count": candidateFrame.canonicalData.count,
        "candidate_sha256": candidateFrame.sha256,
        "candidate_status": status,
        "first_failed_guard": failedGuard,
        "lease_acquisition": [
            "acquired": true, "nonblocking": true,
            "supervisor_owned": true,
            "worker_inherited_descriptor_count": 0,
            "held_through_cleanup_and_postflight": true,
        ],
        "cleanup_and_absence": [
            "known_leaf_count": cleanup[
                "known_inventory_before_cleanup"] as Any,
            "deleted_leaf_count": cleanup["deleted_known_leaf_count"] as Any,
            "unknown_inventory_count": cleanup["unknown_inventory_count"] as Any,
            "post_cleanup_empty": cleanup[
                "post_cleanup_inventory_empty"] as Any,
            "absence_proved": cleanup["absence_proved"] as Any,
            "recursive_cleanup_used": cleanup["recursive_cleanup_used"] as Any,
        ],
        "release_verifier": [
            "executed": true, "exit_zero": true,
            "supervisor_alive": true, "acquire_count": 1,
            "release_count": 1,
        ],
        "supervisor_integrity": [
            "candidate_validated": true,
            "stdout_candidate_then_terminal": true,
            "post_candidate_inventory_exact": true,
            "lease_released_explicitly": true, "terminal_canonical": true,
        ],
        "private_raw_descriptor_tuples": [
            "preflight_parent": preflightParent.tuple.parentDictionary,
            "post_candidate_parent": postParent.tuple.parentDictionary,
            "post_candidate_leaf": postLease.leaseDictionary,
            "verifier_parent": verifierParent,
            "verifier_leaf": verifierLeaf,
        ],
    ]
    let terminalData = try trajectoryCanonicalJSONData(terminal)
    try trajectoryValidatePrivateTerminal(
        terminalData,
        candidateFrame: candidateFrame,
        candidateObject: candidate)
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "terminal canonical validation")

    // No bytes reach stdout before cleanup, postflight, release, and distinct
    // verifier closure.  Swift emits the validated private candidate then the
    // private terminal, never the public prefix.
    _ = try trajectoryWriteFrame(
        candidateFrame.canonicalData,
        maximumByteCount:
            Execution.maximumPrivateCandidateCanonicalByteCount,
        descriptor: STDOUT_FILENO,
        absoluteDeadline: supervisorDeadline.partialValue)
    try trajectoryRequireBeforeDeadline(
        supervisorDeadline.partialValue,
        "candidate stdout frame")
    _ = try trajectoryWriteFrame(
        terminalData,
        maximumByteCount:
            Execution.maximumPrivateTerminalCanonicalByteCount,
        descriptor: STDOUT_FILENO,
        absoluteDeadline: supervisorDeadline.partialValue)
    _exit(0)
}

private func trajectoryValidCandidateMetallib(
    _ value: Any?,
    role: String,
    path: String,
    byteCount: UInt64,
    sha256: String
) -> Bool {
    guard let value = value as? [String: Any] else { return false }
    return Set(value.keys) == [
        "semantic_role", "path_sha256", "byte_count", "content_sha256",
    ]
        && value["semantic_role"] as? String == role
        && value["path_sha256"] as? String
            == PrimeSHA256.hexDigest(of: Data(path.utf8))
        && trajectoryExactUInt64(value["byte_count"]) == byteCount
        && value["content_sha256"] as? String == sha256
}

private func trajectoryValidCandidateEnvironment(
    _ value: [String: Any],
    bindings: TrajectoryLauncherBindings
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    return Set(value.keys) == Set(Execution.environmentKeys)
        && value["mlx_enable_tf32"] as? String == "0"
        && value["mlx_checkout_origin"] as? String == bindings.mlxOrigin
        && value["mlx_revision"] as? String == bindings.mlxRevision
        && value["swiftpm_configuration"] as? String
            == bindings.buildConfiguration
        && value["graph_mode"] as? String
            == "eager_uncompiled_no_compile_transform"
        && trajectoryExactUInt64(value["compile_transform_count"]) == 0
        && value["operating_system_build"] as? String
            == bindings.operatingSystemBuild
        && value["xcode_build"] as? String == bindings.xcodeBuild
        && value["swift_driver"] as? String == bindings.swiftDriver
        && value["swift_sdk"] as? String == bindings.swiftSDK
        && trajectoryValidCandidateMetallib(
            value["staged_metallib"], role: "staged_metallib",
            path: bindings.stagedMetallibPath,
            byteCount: bindings.stagedMetallibBytes,
            sha256: bindings.stagedMetallibSHA256)
        && trajectoryValidCandidateMetallib(
            value["runtime_metallib"], role: "runtime_metallib",
            path: bindings.runtimeMetallibPath,
            byteCount: bindings.runtimeMetallibBytes,
            sha256: bindings.runtimeMetallibSHA256)
}

private func trajectoryValidCandidateDevice(
    _ value: [String: Any]
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard Set(value.keys) == Set(Execution.deviceAndStreamKeys),
          trajectoryExactUInt64(value["metal_device_count"]) == 1,
          trajectoryExactUInt64(value["metal_device_index"]) == 0,
          !(value["metal_device_name"] as? String ?? "").isEmpty,
          trajectoryExactUInt64(value["metal_device_registry_id"]) != nil,
          trajectoryExactBool(value["metal_device_is_default"]) == true,
          trajectoryExactBool(value["metal_device_has_unified_memory"])
            == true,
          (trajectoryExactUInt64(
              value["metal_device_max_buffer_length_bytes"]) ?? 0) > 0,
          let recommended = trajectoryExactUInt64(
              value["metal_device_recommended_max_working_set_bytes"]),
          recommended > 0,
          value["mlx_device_type"] as? String == "gpu",
          trajectoryExactUInt64(value["mlx_device_index"]) == 0,
          trajectoryExactBool(
              value["mlx_default_device_is_supplied_device"]) == true,
          trajectoryExactBool(value["mlx_default_stream_is_gpu"]) == true,
          trajectoryExactBool(value["cpu_fallback_used"]) == false,
          !(value["stream_order"] as? String ?? "").isEmpty,
          !(value["evaluation_order"] as? String ?? "").isEmpty,
          let memory = trajectoryExactUInt64(
              value["configured_memory_limit_bytes"]),
          memory == min(UInt64(17_179_869_184), recommended),
          trajectoryExactUInt64(value["configured_cache_limit_bytes"]) == 0,
          trajectoryExactBool(
              value["pre_post_identity_and_policy_equal"]) == true
    else { return false }
    return true
}

private func trajectoryValidPrivateDomainPrefix(
    _ domains: [[String: Any]],
    mismatch: [String: Any],
    status: String
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    if status == "PASS_EXACT" || status == "MEASURED_EXACT_MISMATCH" {
        return trajectoryValidDomainOutcome(
            domains, mismatch: mismatch, status: status)
    }
    let safeTimeout = status == "ABSTAIN_RESOURCE"
        && mismatch["domain_id"] as? String
            == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure"
    if safeTimeout, domains.count == 18 {
        return domains.enumerated().allSatisfy {
            trajectoryValidMeasuredComparisonDomain(
                $0.element, index: $0.offset)
        } && mismatch["availability"] as? String == "unavailable"
            && mismatch["expected_binding"] is NSNull
    }
    guard domains.count < 18,
          Set(mismatch.keys) == Set(Execution.firstMismatchKeys)
    else {
        if status != "ABSTAIN_INTEGRITY" { return false }
        guard domains.count == 18 else { return false }
        return trajectoryValidPrivateIntegrityPrefix(
            domains, mismatch: mismatch)
    }
    if status == "ABSTAIN_RESOURCE" {
        return domains.enumerated().allSatisfy {
            trajectoryValidMeasuredComparisonDomain(
                $0.element, index: $0.offset)
                && trajectoryExactBool($0.element["exact"]) == true
        }
            && mismatch["availability"] as? String == "unavailable"
    }
    return trajectoryValidPrivateIntegrityPrefix(
        domains, mismatch: mismatch)
}

private func trajectoryValidPrivateIntegrityPrefix(
    _ domains: [[String: Any]],
    mismatch: [String: Any]
) -> Bool {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard !domains.isEmpty, domains.count <= 18 else { return false }
    let failingIndex = domains.count - 1
    guard domains.enumerated().dropLast().allSatisfy({
        trajectoryValidMeasuredComparisonDomain(
            $0.element, index: $0.offset)
            && trajectoryExactBool($0.element["exact"]) == true
    }),
    trajectoryValidUnmeasuredComparisonDomain(
        domains[failingIndex], index: failingIndex),
    mismatch["availability"] as? String == "unavailable",
    mismatch["domain_id"] as? String
        == Execution.comparisonDomainIDs[failingIndex],
    let path = mismatch["path"] as? String,
    trajectoryAllowedComparisonPaths(failingIndex)?.contains(path) == true,
    let expected = mismatch["expected_binding"] as? String,
    let observed = mismatch["observed_binding"] as? String,
    trajectoryIsLowerHex(expected, count: 64),
    trajectoryIsLowerHex(observed, count: 64), expected != observed
    else { return false }
    return true
}

private func trajectoryValidPrivateCheckpointSlots(
    candidate: [String: Any],
    counts: [String: Any],
    status: String
) -> Bool {
    let keys = [
        "baseline_checkpoint_binding",
        "uninterrupted_comparator_binding",
        "resumed_comparator_binding",
    ]
    let roles = [
        "baseline_checkpoint", "uninterrupted_n_plus_1_comparator",
        "resumed_n_plus_1_comparator",
    ]
    var projected = [[String: Any]]()
    var encounteredNull = false
    for (index, key) in keys.enumerated() {
        let value = candidate[key]
        if value is NSNull {
            encounteredNull = true
            continue
        }
        guard !encounteredNull, let object = value as? [String: Any],
              trajectoryValidCheckpointProjection(object),
              object["set_role"] as? String == roles[index]
        else { return false }
        projected.append(object)
    }
    guard trajectoryExactUInt64(counts["final_commit_publication_count"])
            == UInt64(projected.count),
          trajectoryExactUInt64(counts["leaf_publication_count"])
            == UInt64(projected.count * 4)
    else { return false }
    let complete = status == "PASS_EXACT"
        || status == "MEASURED_EXACT_MISMATCH"
    return !complete || projected.count == 3
}

private func trajectoryDeepValidatePrivateCandidate(
    _ candidate: [String: Any],
    bindings: TrajectoryLauncherBindings,
    status: String,
    environment: [String: Any],
    device: [String: Any],
    counts: [String: Any],
    domains: [[String: Any]],
    mismatch: [String: Any],
    phases: [[String: Any]],
    cleanup: [String: Any]
) -> Bool {
    let checkpointSlotCount = [
        candidate["baseline_checkpoint_binding"],
        candidate["uninterrupted_comparator_binding"],
        candidate["resumed_comparator_binding"],
    ].filter { !($0 is NSNull) }.count
    guard trajectoryValidCandidateEnvironment(environment, bindings: bindings),
          trajectoryValidCandidateDevice(device),
          trajectoryValidOperationCounts(counts, status: status),
          trajectoryValidPrivateCheckpointSlots(
              candidate: candidate, counts: counts, status: status),
          trajectoryValidPrivateDomainPrefix(
              domains, mismatch: mismatch, status: status),
          trajectoryValidResourcePhases(
              phases, status: status, mismatch: mismatch),
          trajectoryValidArtifactCleanup(cleanup, status: status),
          trajectoryValidPhaseDependencies(
              counts,
              phaseCount: phases.count,
              checkpointCount: checkpointSlotCount,
              domainCount: domains.count,
              status: status,
              mismatch: mismatch),
          let checkpointCount = trajectoryExactUInt64(
              counts["final_commit_publication_count"]),
          let knownLeafCount = trajectoryExactUInt64(
              cleanup["known_inventory_before_cleanup"]),
          checkpointCount == knownLeafCount / 4,
          trajectoryExactUInt64(cleanup["deleted_known_leaf_count"])
            == knownLeafCount,
          trajectoryExactUInt64(
              cleanup["deleted_private_comparator_count"])
            == (knownLeafCount == 0 ? 0 : (knownLeafCount - 1) / 4),
          trajectoryExactUInt64(
              counts["resource_measurement_synchronize_count"])
            == UInt64(phases.count),
          phases.allSatisfy({ phase in
              phase["filesystem_path_sha256"] as? String
                == PrimeSHA256.hexDigest(of: Data(bindings.artifactRoot.utf8))
              && trajectoryExactUInt64(
                  phase[
                    "verified_configured_memory_limit_copied_from_preflight_bytes"])
                == trajectoryExactUInt64(
                    device["configured_memory_limit_bytes"])
          })
    else { return false }
    if !domains.isEmpty {
        guard phases.count >= 10,
              trajectoryExactUInt64(counts["training_step_count"]) == 3,
              trajectoryExactUInt64(counts["backward_count"]) == 3,
              trajectoryExactUInt64(counts["optimizer_update_count"]) == 3,
              trajectoryExactUInt64(
                  counts["gradient_evidence_capture_count"]) == 2
        else { return false }
    }
    return true
}

private func trajectoryValidatePrivateCandidate(
    _ data: Data,
    bindings: TrajectoryLauncherBindings
) throws -> [String: Any] {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard let candidate = try trajectoryCanonicalJSONObject(data)
            as? [String: Any],
          Set(candidate.keys) == Set(Execution.candidateSchemaKeys),
          candidate["schema"] as? String == Execution.candidateSchemaID,
          let status = candidate["terminal_scientific_status"] as? String,
          Execution.terminalStatusDomain.contains(status),
          let authority = candidate["authority_and_predecessor_bindings"]
            as? [String: Any],
          Set(authority.keys)
            == Set(Execution.authorityAndPredecessorBindingKeys),
          try trajectoryCanonicalJSONData(authority)
            == trajectoryCanonicalJSONData(
                bindings.authorityAndPredecessorBindings),
          let inventory = candidate["implementation_inventory"]
            as? [[String: Any]],
          try trajectoryCanonicalJSONData(inventory)
            == trajectoryCanonicalJSONData(bindings.implementationInventory),
          let oneShot = candidate["one_shot"] as? [String: Any],
          Set(oneShot.keys) == Set(Execution.oneShotKeys),
          trajectoryExactBool(oneShot["consumed"]) == true,
          trajectoryExactUInt64(oneShot["opportunity_count"]) == 1,
          trajectoryExactBool(oneShot["retry_authorized"]) == false,
          trajectoryExactBool(oneShot["rerun_authorized"]) == false,
          trajectoryExactBool(oneShot["replacement_authorized"]) == false,
          let environment = candidate["environment"] as? [String: Any],
          Set(environment.keys) == Set(Execution.environmentKeys),
          let device = candidate["device_and_stream"] as? [String: Any],
          Set(device.keys) == Set(Execution.deviceAndStreamKeys),
          let paths = candidate["raw_private_paths"] as? [String: Any],
          Set(paths.keys) == Set(Execution.rawPrivatePathKeys),
          try trajectoryCanonicalJSONData(paths)
            == trajectoryCanonicalJSONData(bindings.rawPrivatePaths),
          let counts = candidate["operation_counts"] as? [String: Any],
          Set(counts.keys) == Set(Execution.operationCountKeys),
          counts.values.allSatisfy({ trajectoryExactUInt64($0) != nil }),
          let domains = candidate["comparison_domains"] as? [[String: Any]],
          domains.count <= Execution.comparisonDomainIDs.count,
          domains.enumerated().allSatisfy({ index, domain in
              domain["domain_id"] as? String
                == Execution.comparisonDomainIDs[index]
                && Set(domain.keys)
                    == Set(Execution.comparisonDomainResultKeys)
          }),
          let mismatch = candidate["first_mismatch"] as? [String: Any],
          Set(mismatch.keys) == Set(Execution.firstMismatchKeys),
          let phases = candidate["resource_phases"] as? [[String: Any]],
          phases.count <= Execution.phaseNames.count,
          phases.enumerated().allSatisfy({ index, phase in
              Set(phase.keys) == Set(Execution.resourcePhaseKeys)
                  && phase["phase_id"] as? String
                    == Execution.phaseNames[index]
          }),
          let cleanup = candidate["artifact_inventory_and_cleanup"]
            as? [String: Any],
          Set(cleanup.keys) == Set(Execution.artifactCleanupKeys),
          trajectoryExactUInt64(cleanup["unknown_inventory_count"]) == 0,
          trajectoryExactBool(cleanup["post_cleanup_inventory_empty"])
            == true,
          trajectoryExactBool(cleanup["absence_proved"]) == true,
          trajectoryExactBool(cleanup["recursive_cleanup_used"]) == false,
          trajectoryExactUInt64(cleanup["artifact_upload_count"]) == 0,
          trajectoryExactUInt64(cleanup["retained_artifact_count"]) == 0
    else {
        throw TrajectoryExecutionError.contract("private candidate schema")
    }
    try trajectoryRequire(
        trajectoryDeepValidatePrivateCandidate(
            candidate, bindings: bindings, status: status,
            environment: environment, device: device, counts: counts,
            domains: domains, mismatch: mismatch, phases: phases,
            cleanup: cleanup),
        "private candidate deep semantic closure")
    return candidate
}

private func trajectoryValidatePrivateTerminal(
    _ data: Data,
    candidateFrame: TrajectoryPrivateFrame,
    candidateObject: [String: Any]
) throws {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    guard let terminal = try trajectoryCanonicalJSONObject(data)
            as? [String: Any],
          Set(terminal.keys) == Set(Execution.terminalSchemaKeys),
          terminal["schema"] as? String == Execution.terminalSchemaID,
          trajectoryExactUInt64(terminal["candidate_byte_count"])
            == UInt64(candidateFrame.canonicalData.count),
          !candidateFrame.canonicalData.isEmpty,
          terminal["candidate_sha256"] as? String == candidateFrame.sha256,
          let status = terminal["candidate_status"] as? String,
          Execution.terminalStatusDomain.contains(status),
          status == candidateObject["terminal_scientific_status"] as? String,
          let failed = terminal["first_failed_guard"] as? [String: Any],
          Set(failed.keys) == Set(Execution.firstFailedGuardKeys),
          let lease = terminal["lease_acquisition"] as? [String: Any],
          Set(lease.keys) == Set(Execution.leaseAcquisitionKeys),
          let cleanup = terminal["cleanup_and_absence"] as? [String: Any],
          Set(cleanup.keys) == Set(Execution.cleanupAndAbsenceKeys),
          let verifier = terminal["release_verifier"] as? [String: Any],
          Set(verifier.keys) == Set(Execution.releaseVerifierKeys),
          let integrity = terminal["supervisor_integrity"]
            as? [String: Any],
          Set(integrity.keys) == Set(Execution.supervisorIntegrityKeys),
          let tuples = terminal["private_raw_descriptor_tuples"]
            as? [String: Any],
          Set(tuples.keys) == Set(Execution.privateRawDescriptorTupleKeys),
          trajectoryExactBool(lease["acquired"]) == true,
          trajectoryExactBool(lease["nonblocking"]) == true,
          trajectoryExactBool(lease["supervisor_owned"]) == true,
          trajectoryExactUInt64(lease["worker_inherited_descriptor_count"])
            == 0,
          trajectoryExactBool(
              lease["held_through_cleanup_and_postflight"]) == true,
          trajectoryExactUInt64(cleanup["unknown_inventory_count"]) == 0,
          trajectoryExactBool(cleanup["post_cleanup_empty"]) == true,
          trajectoryExactBool(cleanup["absence_proved"]) == true,
          trajectoryExactBool(cleanup["recursive_cleanup_used"]) == false,
          trajectoryExactBool(verifier["executed"]) == true,
          trajectoryExactBool(verifier["exit_zero"]) == true,
          trajectoryExactBool(verifier["supervisor_alive"]) == true,
          trajectoryExactUInt64(verifier["acquire_count"]) == 1,
          trajectoryExactUInt64(verifier["release_count"]) == 1,
          Execution.supervisorIntegrityKeys.allSatisfy({
              trajectoryExactBool(integrity[$0]) == true
          }),
          let candidateCleanup = candidateObject[
              "artifact_inventory_and_cleanup"] as? [String: Any],
          trajectoryExactUInt64(cleanup["known_leaf_count"])
            == trajectoryExactUInt64(
                candidateCleanup["known_inventory_before_cleanup"]),
          trajectoryExactUInt64(cleanup["deleted_leaf_count"])
            == trajectoryExactUInt64(
                candidateCleanup["deleted_known_leaf_count"]),
          trajectoryExactUInt64(cleanup["unknown_inventory_count"])
            == trajectoryExactUInt64(
                candidateCleanup["unknown_inventory_count"]),
          trajectoryExactBool(cleanup["post_cleanup_empty"])
            == trajectoryExactBool(
                candidateCleanup["post_cleanup_inventory_empty"]),
          trajectoryExactBool(cleanup["absence_proved"])
            == trajectoryExactBool(candidateCleanup["absence_proved"]),
          trajectoryExactBool(cleanup["recursive_cleanup_used"])
            == trajectoryExactBool(
                candidateCleanup["recursive_cleanup_used"])
    else {
        throw TrajectoryExecutionError.contract("private terminal schema")
    }
    let complete = status == "PASS_EXACT"
        || status == "MEASURED_EXACT_MISMATCH"
    if complete {
        try trajectoryRequire(
            failed["availability"] as? String == "not_applicable"
                && failed["guard_id"] is NSNull
                && failed["classification"] is NSNull
                && failed["errno"] is NSNull
                && failed["detail"] is NSNull,
            "complete terminal failed-guard closure")
    } else {
        let candidateMismatch = candidateObject["first_mismatch"]
            as! [String: Any]
        let guardID = candidateMismatch["domain_id"] as! String
        let expectedErrno: UInt64? = guardID
            == "positively_identified_enomem" ? UInt64(ENOMEM)
            : (guardID == "positively_identified_enospc"
                ? UInt64(ENOSPC) : nil)
        try trajectoryRequire(
            failed["availability"] as? String == "available"
                && failed["guard_id"] as? String == guardID
                && failed["classification"] as? String == status
                && failed["detail"] as? String
                    == candidateMismatch["observed_binding"] as? String
                && (expectedErrno.map {
                    trajectoryExactUInt64(failed["errno"]) == $0
                } ?? (failed["errno"] is NSNull)),
            "abstain terminal positive guard evidence")
    }
    guard let candidatePaths = candidateObject["raw_private_paths"]
            as? [String: Any],
          let leasePath = candidatePaths["lease_path"] as? String
    else {
        throw TrajectoryExecutionError.contract(
            "private terminal descriptor path binding")
    }
    var decoded = [String: TrajectoryDescriptorObservation]()
    for key in ["preflight_parent", "post_candidate_parent", "verifier_parent"] {
        guard let dictionary = tuples[key] as? [String: Any] else {
            throw TrajectoryExecutionError.contract(
                "private terminal parent descriptor object")
        }
        let tuple = try TrajectoryDescriptorObservation(
            parentDictionary: dictionary)
        try trajectoryRequire(
            tuple.satisfiesObservedCleanPolicy,
            "private terminal parent descriptor policy")
        decoded[key] = tuple
    }
    for key in ["post_candidate_leaf", "verifier_leaf"] {
        guard let dictionary = tuples[key] as? [String: Any] else {
            throw TrajectoryExecutionError.contract(
                "private terminal lease descriptor object")
        }
        let tuple = try TrajectoryDescriptorObservation(
            leaseDictionary: dictionary,
            physicalPath: leasePath)
        try trajectoryRequire(
            tuple.satisfiesObservedCleanPolicy,
            "private terminal lease descriptor policy")
        decoded[key] = tuple
    }
    try trajectoryRequire(
        decoded["preflight_parent"]!.stableParentEquals(
            decoded["post_candidate_parent"]!)
            && decoded["post_candidate_parent"]!.stableParentEquals(
                decoded["verifier_parent"]!)
            && decoded["post_candidate_leaf"]!.stableLeafEquals(
                decoded["verifier_leaf"]!)
            && decoded["post_candidate_leaf"]!.byteCount == 0
            && decoded["post_candidate_leaf"]!.observedLinkCount == 1,
        "private terminal descriptor stability")
}

private func trajectoryRunVerifierFromSupervisor(
    bindings: TrajectoryLauncherBindings,
    supervisorDeadline: UInt64
) throws -> [String: Any] {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    var descriptors = [Int32](repeating: -1, count: 2)
    guard Darwin.pipe(&descriptors) == 0 else {
        throw TrajectoryExecutionError.posix("verifier pipe", errno)
    }
    var readDescriptor = descriptors[0]
    var writeDescriptor = descriptors[1]
    defer {
        if readDescriptor >= 0 { _ = Darwin.close(readDescriptor) }
        if writeDescriptor >= 0 { _ = Darwin.close(writeDescriptor) }
    }
    try trajectoryRelocateDescriptor(
        &readDescriptor,
        forbidden: [STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO],
        minimum: STDERR_FILENO + 1)
    try trajectoryRelocateDescriptor(
        &writeDescriptor,
        forbidden: [STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO],
        minimum: STDERR_FILENO + 1)
    try trajectorySetCloseOnExec(readDescriptor)
    try trajectorySetCloseOnExec(writeDescriptor)
    let start = DispatchTime.now().uptimeNanoseconds
    let pid = try trajectorySpawn(
        executable: bindings.executablePath,
        arguments: [Execution.verifierArgument],
        outputDescriptor: writeDescriptor)
    // As with the worker, containment exists before any throwable deadline
    // computation following the successful spawn.
    var verifierLive = true
    defer {
        if verifierLive { trajectoryContainProcess(pid) }
    }
    let verifierDeadline = min(
        supervisorDeadline,
        try trajectoryDeadline(
            from: start,
            afterSeconds: Execution.frameReadDeadlineSeconds))
    _ = Darwin.close(writeDescriptor)
    writeDescriptor = -1
    let frame: TrajectoryPrivateFrame
    do {
        frame = try trajectoryReadFrame(
            descriptor: readDescriptor,
            maximumByteCount: Execution.maximumPrivateTerminalCanonicalByteCount,
            firstByteDeadline: verifierDeadline,
            absoluteDeadline: verifierDeadline,
            requireEOF: true)
    } catch {
        throw error
    }
    _ = Darwin.close(readDescriptor)
    readDescriptor = -1
    let wait = try trajectoryWaitForProcess(
        pid,
        absoluteDeadline: verifierDeadline)
    verifierLive = false
    try trajectoryRequire(
        wait.exitCode == 0 && wait.signal == nil && !wait.timeout,
        "release verifier exit")
    guard let object = try trajectoryCanonicalJSONObject(frame.canonicalData)
            as? [String: Any],
          Set(object.keys)
            == ["schema", "parent", "leaf", "inventory", "acquired", "released"],
          object["schema"] as? String
            == "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_release_verifier_v1",
          object["inventory"] as? [String] == ["device-0.lock"]
    else {
        throw TrajectoryExecutionError.contract("release verifier packet")
    }
    return object
}

private func trajectoryRunReleaseVerifierProcess() -> Never {
    do {
        let bindings = try TrajectoryLauncherBindings(
            environment: ProcessInfo.processInfo.environment)
        let parent = try trajectoryObserveDirectory(bindings.leaseRoot)
        try trajectoryRequire(
            parent.inventory == ["device-0.lock"],
            "verifier inventory")
        let beforeLeaf = try trajectoryObserveLease(
            bindings.leasePath,
            expectedParent: parent.tuple)
        let lease = try PrimeMetalDeviceLease.acquire(
            at: URL(fileURLWithPath: bindings.leasePath))
        try trajectoryRequire(lease.isHeld, "verifier lease acquire")
        lease.release()
        let afterParent = try trajectoryObserveDirectory(bindings.leaseRoot)
        let afterLeaf = try trajectoryObserveLease(
            bindings.leasePath,
            expectedParent: afterParent.tuple)
        try trajectoryRequire(
            parent.tuple.stableParentEquals(afterParent.tuple)
                && beforeLeaf.stableLeafEquals(afterLeaf)
                && afterParent.inventory == ["device-0.lock"],
            "verifier stable identities")
        let packet: [String: Any] = [
            "schema":
                "ergentics_prime_native_decoder_native300m_trajectory_checkpoint_execution_release_verifier_v1",
            "parent": afterParent.tuple.parentDictionary,
            "leaf": afterLeaf.leaseDictionary,
            "inventory": afterParent.inventory,
            "acquired": true, "released": true,
        ]
        let data = try trajectoryCanonicalJSONData(packet)
        _ = try trajectoryWriteFrame(
            data,
            maximumByteCount:
                PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
                    .maximumPrivateTerminalCanonicalByteCount,
            descriptor: STDOUT_FILENO)
        _exit(0)
    } catch {
        _exit(82)
    }
}

private final class TrajectoryOperationCounter {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    private(set) var values: [String: UInt64]

    init() {
        values = Dictionary(
            uniqueKeysWithValues: Execution.operationCountKeys.map { ($0, 0) })
        values["worker_process_count"] = 1
        values["supervisor_process_count"] = 1
        values["release_verifier_process_count"] = 1
        values["maximum_public_receipt_count"] = 1
    }

    convenience init(scientificValues: [String: UInt64]) throws {
        self.init()
        let keys = Set(values.keys).subtracting(Self.transportKeys)
        try trajectoryRequire(Set(scientificValues.keys) == keys,
            "current local scientific counter keys")
        for (key, value) in scientificValues {
            try trajectoryRequire(value <= Execution.exactOperationCounts[key]!,
                "current local scientific counter bound")
            values[key] = value
        }
    }

    private static let transportKeys: Set<String> = [
        "worker_process_count", "supervisor_process_count",
        "release_verifier_process_count", "maximum_public_receipt_count",
    ]

    var scientificValues: [String: UInt64] {
        values.filter { !Self.transportKeys.contains($0.key) }
    }

    func increment(_ key: String, by delta: UInt64 = 1) throws {
        guard let current = values[key],
              let maximum = Execution.exactOperationCounts[key]
        else {
            throw TrajectoryExecutionError.contract(
                "unknown operation count \(key)")
        }
        let sum = current.addingReportingOverflow(delta)
        try trajectoryRequire(
            !sum.overflow && sum.partialValue <= maximum,
            "operation count overflow \(key)")
        values[key] = sum.partialValue
    }

    func candidateDictionary() -> [String: Any] {
        Dictionary(uniqueKeysWithValues: values.map { ($0.key, $0.value) })
    }

    func requireComplete() throws {
        try trajectoryRequire(
            values == Execution.exactOperationCounts,
            "complete operation counts")
    }
}

private struct TrajectoryBatch {
    let tokenIDs: MLXArray
    let completionMask: MLXArray
    let tokenAndMaskSHA256: String
}

private struct TrajectoryPathDigest: Codable, Equatable {
    let path: String
    let shape: [Int]
    let dtype: String
    let elementCount: UInt64
    let logicalByteCount: UInt64
    let logicalSHA256: String
    /// Retained only for the two small loss tensors whose bytes participate
    /// in a later mixed scalar-and-tensor comparison.  Model, moment, and
    /// gradient catalogs never retain their logical bytes here.
    let retainedLogicalBytes: Data?
}

private struct TrajectoryCatalogDigest: Codable, Equatable {
    let paths: [TrajectoryPathDigest]
    let structuralSHA256: String
    let logicalSHA256: String
    let totalElementCount: UInt64
    let totalLogicalByteCount: UInt64

    var projection: [String: Any] {
        [
            "algorithm_id":
                "prime_stage7_sorted_path_shape_dtype_element_and_byte_count_sha256_v1",
            "sorted_unique_path_count": paths.count,
            "shape_dtype_element_and_byte_count_preimage_sha256":
                structuralSHA256,
            "canonical_logical_bytes_preimage_sha256": logicalSHA256,
            "total_element_count": totalElementCount,
            "total_logical_byte_count": totalLogicalByteCount,
            "first_mismatch_path_if_any": NSNull(),
        ]
    }
}

private struct TrajectoryStepEvidence: Codable, Equatable {
    let lossBits: UInt32
    let perTargetLoss: TrajectoryCatalogDigest
    let wholeLogits: TrajectoryCatalogDigest
    let rawGradients: TrajectoryCatalogDigest?
    let clippedGradients: TrajectoryCatalogDigest?
    let rawNormBits: UInt32
    let clippedNormBits: UInt32
    let clipScaleBits: UInt32
    let postUpdateParameters: TrajectoryCatalogDigest
    let firstMoments: TrajectoryCatalogDigest
    let secondMoments: TrajectoryCatalogDigest
    let evaluationPerTargetLoss: TrajectoryCatalogDigest
    let evaluationWholeLogits: TrajectoryCatalogDigest
    let evaluationBinding: Data
    let evaluationReadOnlyBinding: Data
    let batchBinding: Data
}

private struct TrajectorySnapshotEvidence: Codable, Equatable {
    let weights: TrajectoryCatalogDigest
    let firstMoments: TrajectoryCatalogDigest
    let secondMoments: TrajectoryCatalogDigest
    let control: Data
}

private final class TrajectoryScienceContext {
    let counter: TrajectoryOperationCounter
    let epoch: UInt64
    let metalDevice: any MTLDevice
    let configuredMemoryLimit: UInt64
    let artifactRoot: PrimeArtifactRoot
    let phaseNames: [String]
    let currentLocalLease: PrimeMetalDeviceLease?
    let recordProgress: ((Data) throws -> Void)?
    var phases = [[String: Any]]()
    var comparisonDomains = [[String: Any]]()
    var baselineBinding:
        PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1?
    var uninterruptedBinding:
        PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1?
    var resumedBinding:
        PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1?
    var quarantines =
        [PrimeNativeDecoderNative300MTrajectoryQuarantineV1]()
    /// Complete committed sets that failed only after publication.  They are
    /// held solely for descriptor-bound retirement on the no-public failure
    /// path and are never projected as successful checkpoint bindings.
    var cleanupOnlyCommittedBindings =
        [PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1]()
    var cleanupEvidence:
        PrimeNativeDecoderNative300MTrajectoryCleanupV1?

    convenience init(
        bindings: TrajectoryLauncherBindings,
        epoch: UInt64,
        metalDevice: any MTLDevice,
        configuredMemoryLimit: UInt64,
        artifactRoot: PrimeArtifactRoot
    ) {
        self.init(epoch: epoch, metalDevice: metalDevice,
            configuredMemoryLimit: configuredMemoryLimit, artifactRoot: artifactRoot)
    }

    init(epoch: UInt64, metalDevice: any MTLDevice,
         configuredMemoryLimit: UInt64, artifactRoot: PrimeArtifactRoot,
         counter: TrajectoryOperationCounter = .init(),
         phaseNames: [String] = PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.phaseNames,
         currentLocalLease: PrimeMetalDeviceLease? = nil,
         recordProgress: ((Data) throws -> Void)? = nil) {
        self.counter = counter
        self.epoch = epoch
        self.metalDevice = metalDevice
        self.configuredMemoryLimit = configuredMemoryLimit
        self.artifactRoot = artifactRoot
        self.phaseNames = phaseNames
        self.currentLocalLease = currentLocalLease
        self.recordProgress = recordProgress
    }
}

private func trajectoryAppendBigEndian(
    _ value: UInt64,
    to data: inout Data
) {
    var bigEndian = value.bigEndian
    withUnsafeBytes(of: &bigEndian) { data.append(contentsOf: $0) }
}

private func trajectoryDigestHex<D: Digest>(_ digest: D) -> String {
    digest.map { String(format: "%02x", $0) }.joined()
}

private func trajectoryCatalogDigest(
    _ entries: [(String, MLXArray)],
    expectedPathCount: Int? = nil,
    retainLogicalBytes: Bool = false
) throws -> TrajectoryCatalogDigest {
    let sorted = entries.sorted { trajectoryRawUTF8Less($0.0, $1.0) }
    try trajectoryRequire(
        Set(sorted.map(\.0)).count == sorted.count
            && expectedPathCount.map({ sorted.count == $0 }) ?? true,
        "tensor catalog path topology")
    var structuralHasher = SHA256()
    var logicalHasher = SHA256()
    var records = [TrajectoryPathDigest]()
    records.reserveCapacity(sorted.count)
    var totalElements: UInt64 = 0
    var totalBytes: UInt64 = 0
    for (path, array) in sorted {
        try trajectoryRequire(
            !path.isEmpty && array.dtype == .float32 && array.itemSize == 4
                && array.size > 0 && array.nbytes == array.size * 4,
            "tensor catalog shape/dtype \(path)")
        let copied = array.asData(access: .copy)
        try trajectoryRequire(
            copied.shape == array.shape && copied.dType == array.dtype
                && copied.data.count == array.nbytes,
            "tensor logical bytes \(path)")
        let pathData = Data(path.utf8)
        var structural = Data()
        trajectoryAppendBigEndian(UInt64(pathData.count), to: &structural)
        structural.append(pathData)
        trajectoryAppendBigEndian(UInt64(array.shape.count), to: &structural)
        for dimension in array.shape {
            try trajectoryRequire(dimension >= 0, "negative tensor dimension")
            trajectoryAppendBigEndian(UInt64(dimension), to: &structural)
        }
        let dtypeData = Data("float32".utf8)
        trajectoryAppendBigEndian(UInt64(dtypeData.count), to: &structural)
        structural.append(dtypeData)
        trajectoryAppendBigEndian(UInt64(array.size), to: &structural)
        trajectoryAppendBigEndian(UInt64(array.nbytes), to: &structural)
        structuralHasher.update(data: structural)

        var logicalPrefix = Data()
        trajectoryAppendBigEndian(UInt64(pathData.count), to: &logicalPrefix)
        logicalPrefix.append(pathData)
        logicalHasher.update(data: logicalPrefix)
        logicalHasher.update(data: copied.data)

        let elementAddition = totalElements.addingReportingOverflow(
            UInt64(array.size))
        let byteAddition = totalBytes.addingReportingOverflow(
            UInt64(array.nbytes))
        try trajectoryRequire(
            !elementAddition.overflow && !byteAddition.overflow,
            "tensor catalog total overflow")
        totalElements = elementAddition.partialValue
        totalBytes = byteAddition.partialValue
        records.append(.init(
            path: path, shape: array.shape, dtype: "float32",
            elementCount: UInt64(array.size),
            logicalByteCount: UInt64(array.nbytes),
            logicalSHA256: PrimeSHA256.hexDigest(of: copied.data),
            retainedLogicalBytes: retainLogicalBytes ? copied.data : nil))
    }
    return .init(
        paths: records,
        structuralSHA256: trajectoryDigestHex(structuralHasher.finalize()),
        logicalSHA256: trajectoryDigestHex(logicalHasher.finalize()),
        totalElementCount: totalElements,
        totalLogicalByteCount: totalBytes)
}

private func trajectoryModelCatalogDigest(
    _ model: PrimeNativeGQADecoder
) throws -> TrajectoryCatalogDigest {
    try trajectoryCatalogDigest(
        model.parameters().flattened(),
        expectedPathCount:
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                .expectedParameterPathCount)
}

private func trajectoryMomentCatalogDigest(
    _ parameters: ModuleParameters,
    storagePrefix: String
) throws -> TrajectoryCatalogDigest {
    try trajectoryCatalogDigest(
        parameters.flattened().map {
            (storagePrefix + $0.0, $0.1)
        },
        expectedPathCount:
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                .expectedParameterPathCount)
}

private func trajectoryScalarDigest(_ bits: UInt32) -> Data {
    var bigEndian = bits.bigEndian
    return withUnsafeBytes(of: &bigEndian) { Data($0) }
}

private func trajectoryMakeBatch(
    stride: Int,
    offset: Int,
    expectedSHA256: String
) throws -> TrajectoryBatch {
    var tokens = [Int32(1)]
    tokens.append(contentsOf: (0 ..< 127).map { index in
        Int32(2 + ((index * stride + offset) % 510))
    })
    let completion = [false] + Array(repeating: true, count: 127)
    let canonical = try trajectoryCanonicalJSONData([
        "completion_mask": [completion],
        "token_ids": [tokens],
    ])
    let digest = PrimeSHA256.hexDigest(of: canonical)
    try trajectoryRequire(digest == expectedSHA256, "frozen batch digest")
    return .init(
        tokenIDs: MLXArray(tokens, [1, 128]),
        completionMask: MLXArray(completion, [1, 128]),
        tokenAndMaskSHA256: digest)
}

private func trajectoryObserveResourcePhase(
    _ phaseID: String,
    context: TrajectoryScienceContext
) throws {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    try trajectoryRequire(
        context.phases.count < context.phaseNames.count
            && context.phaseNames[context.phases.count] == phaseID,
        "resource phase order")
    if let lease = context.currentLocalLease {
        try trajectoryRequire(lease.isHeld, "current local science lease held")
    }
    StreamOrDevice.default.stream.synchronize()
    try context.counter.increment("resource_measurement_synchronize_count")

    var taskInformation = task_vm_info_data_t()
    var taskInformationCount = mach_msg_type_number_t(
        MemoryLayout<task_vm_info_data_t>.size
            / MemoryLayout<natural_t>.size)
    let taskResult: kern_return_t = withUnsafeMutablePointer(
        to: &taskInformation
    ) { pointer in
        pointer.withMemoryRebound(
            to: integer_t.self,
            capacity: Int(taskInformationCount)
        ) { rebound in
            task_info(
                mach_task_self_, task_flavor_t(TASK_VM_INFO), rebound,
                &taskInformationCount)
        }
    }
    try trajectoryRequire(taskResult == KERN_SUCCESS, "TASK_VM_INFO")
    var usage = rusage()
    try trajectoryRequire(
        getrusage(RUSAGE_SELF, &usage) == 0 && usage.ru_maxrss >= 0,
        "getrusage")
    var filesystem = statfs()
    try trajectoryRequire(
        context.artifactRoot.directoryURL.path.withCString {
            statfs($0, &filesystem)
        } == 0,
        "artifact-root statfs")
    try trajectoryRequire(
        filesystem.f_bsize > 0 && filesystem.f_blocks >= 0
            && filesystem.f_bavail >= 0,
        "artifact-root statfs values")
    let capacity = UInt64(filesystem.f_blocks)
        .multipliedReportingOverflow(by: UInt64(filesystem.f_bsize))
    let available = UInt64(filesystem.f_bavail)
        .multipliedReportingOverflow(by: UInt64(filesystem.f_bsize))
    try trajectoryRequire(
        !capacity.overflow && !available.overflow,
        "artifact-root capacity overflow")
    let elapsed = DispatchTime.now().uptimeNanoseconds
        .subtractingReportingOverflow(context.epoch)
    try trajectoryRequire(!elapsed.overflow && elapsed.partialValue > 0,
        "resource phase elapsed")
    let active = MLX.Memory.activeMemory
    let cache = MLX.Memory.cacheMemory
    let peak = MLX.Memory.peakMemory
    try trajectoryRequire(active >= 0 && cache >= 0 && peak >= 0,
        "MLX resource values")
    context.phases.append([
        "phase_id": phaseID,
        "cumulative_elapsed_nanoseconds": elapsed.partialValue,
        "physical_memory_capacity_bytes": ProcessInfo.processInfo.physicalMemory,
        "task_resident_bytes": UInt64(taskInformation.resident_size),
        "task_physical_footprint_bytes": UInt64(taskInformation.phys_footprint),
        "getrusage_max_rss_bytes": UInt64(usage.ru_maxrss),
        "mlx_active_bytes": UInt64(active), "mlx_cache_bytes": UInt64(cache),
        "mlx_peak_bytes": UInt64(peak),
        "metal_current_allocated_bytes":
            UInt64(context.metalDevice.currentAllocatedSize),
        "filesystem_fsid": [
            "word0": UInt64(UInt32(bitPattern: filesystem.f_fsid.val.0)),
            "word1": UInt64(UInt32(bitPattern: filesystem.f_fsid.val.1)),
        ],
        "filesystem_semantic_role": "artifact_root",
        "filesystem_path_sha256": PrimeSHA256.hexDigest(
            of: Data(context.artifactRoot.directoryURL.path.utf8)),
        "filesystem_capacity_bytes": capacity.partialValue,
        "filesystem_available_bytes": available.partialValue,
        "verified_configured_memory_limit_copied_from_preflight_bytes":
            context.configuredMemoryLimit,
        "verified_configured_cache_limit_copied_from_preflight_bytes": 0,
    ])
    if let recordProgress = context.recordProgress {
        try recordProgress(trajectoryCanonicalJSONData([
            "schema": "prime_current_local_native300m_resource_boundary_v1",
            "worker_pid": getpid(), "phase_ordinal": context.phases.count,
            "observation": context.phases.last!,
        ]))
    }
    let scienceTimeout = Execution.workerTimeoutSeconds
        .multipliedReportingOverflow(by: 1_000_000_000)
    try trajectoryRequire(!scienceTimeout.overflow, "science timeout interval")
    if elapsed.partialValue >= scienceTimeout.partialValue {
        if context.currentLocalLease != nil {
            throw TrajectoryExecutionError.contract("current local science deadline exceeded")
        }
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_RESOURCE",
            "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure")
    }
}

private final class TrajectoryForwardCapture: @unchecked Sendable {
    var logits: MLXArray?
    var perTargetLoss: MLXArray?
    var exactTopology = true
}

private func trajectoryForwardLoss(
    model: PrimeNativeGQADecoder,
    batch: TrajectoryBatch,
    capture: TrajectoryForwardCapture
) -> MLXArray {
    let logits = model
        .trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1(
            batch.tokenIDs)
    let shiftedLogits = logits[0..., 0 ..< 127, 0...]
    let shiftedTargets = batch.tokenIDs[0..., 1 ..< 128]
    let shiftedMask = batch.completionMask[0..., 1 ..< 128]
    let perTarget = crossEntropy(
        logits: shiftedLogits,
        targets: shiftedTargets,
        weights: nil,
        axis: -1,
        labelSmoothing: 0,
        reduction: .none)
    if logits.shape != [1, 128, 512] || logits.dtype != .float32
        || shiftedLogits.shape != [1, 127, 512]
        || shiftedTargets.shape != [1, 127]
        || shiftedMask.shape != [1, 127]
        || perTarget.shape != [1, 127] || perTarget.dtype != .float32
    {
        capture.exactTopology = false
    }
    capture.logits = logits
    capture.perTargetLoss = perTarget
    return MLX.sum(perTarget * shiftedMask.asType(.float32)) / Float32(127)
}

private let trajectoryForwardOperationKeys = [
    "dense_b_path_logits_call_count", "token_bounds_validation_count",
    "token_bounds_checked_eval_count", "token_bounds_gpu_synchronize_count",
    "token_bounds_host_bool_item_count",
    "dense_one_hot_matmul_construction_count", "forward_loss_count",
    "cross_entropy_count",
]

private func trajectoryRecordCompletedForward(
    context: TrajectoryScienceContext
) throws {
    for key in trajectoryForwardOperationKeys {
        try context.counter.increment(key)
    }
}

/// Owns all gradient graph references.  On return, only host-side digest and
/// scalar evidence survives, so the caller can truthfully count the graph and
/// catalog release before beginning the read-only evaluation.
private func trajectoryPerformStepAndEvaluationGraphs(
    model: PrimeNativeGQADecoder,
    optimizer: AdamW,
    batch: TrajectoryBatch,
    globalStepBefore: UInt64,
    captureGradientEvidence: Bool,
    context: TrajectoryScienceContext
) throws -> TrajectoryStepEvidence {
    let globalStep = globalStepBefore.addingReportingOverflow(1)
    try trajectoryRequire(!globalStep.overflow, "global-step overflow")
    let observedGlobalStep = globalStep.partialValue
    let trainingCapture = TrajectoryForwardCapture()
    let lossAndGradient = valueAndGrad(model: model) {
        model, tokenIDs, completionMask in
        trajectoryForwardLoss(
            model: model,
            batch: .init(
                tokenIDs: tokenIDs,
                completionMask: completionMask,
                tokenAndMaskSHA256: batch.tokenAndMaskSHA256),
            capture: trainingCapture)
    }
    var rawResult: (MLXArray, ModuleParameters)? = lossAndGradient(
        model, batch.tokenIDs, batch.completionMask)
    try context.counter.increment("training_step_count")
    try context.counter.increment("backward_count")
    try trajectoryRecordCompletedForward(context: context)

    guard rawResult != nil else {
        throw TrajectoryExecutionError.contract("training loss ownership")
    }
    // Materialize the scalar while the value-and-gradient result is still
    // owned.  The evaluated scalar is detached from its inputs and remains as
    // the tiny training target for the later phase barrier; the original tuple
    // and its full gradient ownership are released below.
    let trainingLoss = rawResult!.0
    let lossValue = trainingLoss.item(Float32.self)
    var gradientEntries = rawResult!.1.flattened().sorted {
        trajectoryRawUTF8Less($0.0, $1.0)
    }
    // Flattening transfers the only full raw-gradient ownership into the
    // mutable list.  Nil the original ModuleParameters tuple before any
    // clipped catalog is constructed, so entries can be consumed one by one.
    rawResult = nil
    let modelPaths = model.trainableParameters().flattened().map {
        $0.0
    }.sorted(by: trajectoryRawUTF8Less)
    let gradientPaths = gradientEntries.map { $0.0 }
    try trajectoryRequire(
        gradientEntries.count == 218 && gradientPaths == modelPaths,
        "gradient/model exact path set")

    let rawNormValue: Float32 = {
        var squaredNorm = MLXArray(Float32(0))
        for (_, gradient) in gradientEntries {
            squaredNorm = squaredNorm + MLX.sum(
                MLX.square(gradient.asType(DType.float32)))
        }
        return MLX.sqrt(squaredNorm).item(Float32.self)
    }()
    let scaleValue = min(
        Float32(1), Float32(1) / (rawNormValue + Float32(1e-6)))
    let clippedNormValue = rawNormValue * scaleValue
    let rawGradientDigest: TrajectoryCatalogDigest? =
        captureGradientEvidence
            ? try trajectoryCatalogDigest(
                gradientEntries, expectedPathCount: 218)
            : nil
    var clippedEntries = [(String, MLXArray)]()
    clippedEntries.reserveCapacity(gradientEntries.count)
    while let (path, gradient) = gradientEntries.popLast() {
        let clipped = gradient * scaleValue
        let materialized = clipped.asData(access: .copy)
        try trajectoryRequire(
            materialized.shape == gradient.shape
                && materialized.dType == .float32
                && materialized.data.count == gradient.nbytes,
            "one-path clipped gradient materialization")
        // MLX's evaluated-array contract detaches this materialized value from
        // its inputs.  Keep the GPU-path array itself; the one-path host copy
        // exists only for validation/digest materialization and is released at
        // the end of this iteration.  There is no host-to-device rebuild.
        clippedEntries.append((path, clipped))
    }
    try trajectoryRequire(
        gradientEntries.isEmpty && clippedEntries.count == 218,
        "raw gradient catalog consumed before clipped catalog use")
    let clippedGradients = ModuleParameters.unflattened(clippedEntries)
    optimizer.update(model: model, gradients: clippedGradients)
    try context.counter.increment("optimizer_update_count")

    guard let trainingLogits = trainingCapture.logits,
          let trainingPerTarget = trainingCapture.perTargetLoss,
          trainingCapture.exactTopology
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY", "training forward topology drift")
    }
    try trajectoryRequire(
        lossValue.isFinite && rawNormValue.isFinite && rawNormValue > 0
            && scaleValue.isFinite && scaleValue > 0 && scaleValue <= 1
            && clippedNormValue.isFinite,
        "finite training scalars")
    let perTargetDigest = try trajectoryCatalogDigest([
        ("per_target_loss", trainingPerTarget),
    ], expectedPathCount: 1, retainLogicalBytes: true)
    let logitsDigest = try trajectoryCatalogDigest([
        ("whole_logits", trainingLogits),
    ], expectedPathCount: 1, retainLogicalBytes: true)
    let capturedTrainingMode = model.training
    try trajectoryRequire(
        capturedTrainingMode,
        "pre-evaluation decoder training mode must be true")
    let preControl = try trajectoryEvaluationControlBinding(
        globalStep: observedGlobalStep,
        batch: batch,
        trainingMode: capturedTrainingMode)
    let preEvaluation = try trajectoryCaptureEvaluationState(
        model: model,
        optimizer: optimizer,
        control: preControl)

    let evaluationCapture = TrajectoryForwardCapture()
    model.train(false)
    try context.counter.increment("training_mode_disable_count")
    let evaluationLoss = trajectoryForwardLoss(
        model: model,
        batch: batch,
        capture: evaluationCapture)
    try trajectoryRecordCompletedForward(context: context)
    try context.counter.increment("evaluation_forward_pass_count")
    guard let evaluationLogits = evaluationCapture.logits,
          let evaluationPerTarget = evaluationCapture.perTargetLoss,
          evaluationCapture.exactTopology,
          !model.training
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY",
            "evaluation topology or disabled-mode drift")
    }
    let phaseMaterializationTargets = [
        trainingLoss, trainingLogits, trainingPerTarget, evaluationLoss,
        evaluationLogits, evaluationPerTarget,
    ]
    try checkedEval(model, optimizer, phaseMaterializationTargets)
    try context.counter.increment("resource_measurement_checked_eval_count")
    let evaluationLossValue = evaluationLoss.item(Float32.self)
    try trajectoryRequire(
        evaluationLossValue.isFinite,
        "finite read-only evaluation loss")
    let evaluationPerTargetDigest = try trajectoryCatalogDigest([
        ("per_target_loss", evaluationPerTarget),
    ], expectedPathCount: 1, retainLogicalBytes: true)
    let evaluationLogitsDigest = try trajectoryCatalogDigest([
        ("whole_logits", evaluationLogits),
    ], expectedPathCount: 1, retainLogicalBytes: true)
    model.train(capturedTrainingMode)
    try context.counter.increment("training_mode_restore_count")
    try trajectoryRequire(
        model.training == capturedTrainingMode && model.training,
        "evaluation training mode exact restoration")
    let postControl = try trajectoryEvaluationControlBinding(
        globalStep: observedGlobalStep,
        batch: batch,
        trainingMode: model.training)
    let postEvaluation = try trajectoryCaptureEvaluationState(
        model: model,
        optimizer: optimizer,
        control: postControl)
    guard preEvaluation == postEvaluation else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY",
            "checked read-only evaluation mutated model optimizer or control")
    }
    try context.counter.increment("checked_read_only_evaluation_count")
    let clippedGradientDigest: TrajectoryCatalogDigest?
    if captureGradientEvidence {
        clippedGradientDigest = try trajectoryCatalogDigest(
            clippedEntries, expectedPathCount: 218)
        try context.counter.increment("gradient_evidence_capture_count")
    } else {
        clippedGradientDigest = nil
    }

    let evaluationObject: [String: Any] = [
        "loss_float32_bits": evaluationLossValue.bitPattern,
        "per_target_loss_sha256":
            evaluationPerTargetDigest.logicalSHA256,
        "whole_logits_sha256": evaluationLogitsDigest.logicalSHA256,
        "model_catalog_sha256": postEvaluation.weights.logicalSHA256,
        "optimizer_first_moment_sha256":
            postEvaluation.firstMoments.logicalSHA256,
        "optimizer_second_moment_sha256":
            postEvaluation.secondMoments.logicalSHA256,
        "training_mode_restored_true": model.training,
        "batch_token_and_mask_sha256": batch.tokenAndMaskSHA256,
    ]
    let evaluationBinding = try trajectoryCanonicalJSONData(evaluationObject)
    let readOnlyBinding = try trajectoryCanonicalJSONData([
        "pre_model_catalog_sha256": preEvaluation.weights.logicalSHA256,
        "post_model_catalog_sha256": postEvaluation.weights.logicalSHA256,
        "pre_optimizer_catalog_sha256": PrimeSHA256.hexDigest(
            of: try trajectoryCanonicalJSONData([
                preEvaluation.firstMoments.logicalSHA256,
                preEvaluation.secondMoments.logicalSHA256,
            ])),
        "post_optimizer_catalog_sha256": PrimeSHA256.hexDigest(
            of: try trajectoryCanonicalJSONData([
                postEvaluation.firstMoments.logicalSHA256,
                postEvaluation.secondMoments.logicalSHA256,
            ])),
        "pre_control_sha256": PrimeSHA256.hexDigest(of: preControl),
        "post_control_sha256": PrimeSHA256.hexDigest(of: postControl),
        "training_mode_restored_true": model.training,
    ] as [String: Any])
    let batchBinding = try trajectoryCanonicalJSONData([
        "token_and_mask_sha256": batch.tokenAndMaskSHA256,
    ])
    return .init(
        lossBits: lossValue.bitPattern,
        perTargetLoss: perTargetDigest,
        wholeLogits: logitsDigest,
        rawGradients: rawGradientDigest,
        clippedGradients: clippedGradientDigest,
        rawNormBits: rawNormValue.bitPattern,
        clippedNormBits: clippedNormValue.bitPattern,
        clipScaleBits: scaleValue.bitPattern,
        postUpdateParameters: postEvaluation.weights,
        firstMoments: postEvaluation.firstMoments,
        secondMoments: postEvaluation.secondMoments,
        evaluationPerTargetLoss: evaluationPerTargetDigest,
        evaluationWholeLogits: evaluationLogitsDigest,
        evaluationBinding: evaluationBinding,
        evaluationReadOnlyBinding: readOnlyBinding,
        batchBinding: batchBinding)
}

private func trajectoryEvaluationControlBinding(
    globalStep: UInt64,
    batch: TrajectoryBatch,
    trainingMode: Bool
) throws -> Data {
    try trajectoryCanonicalJSONData([
        "global_step": globalStep,
        "batch_token_and_mask_sha256": batch.tokenAndMaskSHA256,
        "training_mode": trainingMode,
        "schedule_id": "constant_float32_learning_rate_v1",
        "current_learning_rate_float32_bits": Float32(1e-4).bitPattern,
    ])
}

private func trajectoryCaptureEvaluationState(
    model: PrimeNativeGQADecoder,
    optimizer: AdamW,
    control: Data
) throws -> TrajectorySnapshotEvidence {
    let state = try optimizer.parameters()
    return try .init(
        weights: trajectoryModelCatalogDigest(model),
        firstMoments: trajectoryMomentCatalogDigest(
            state.firstMoment,
            storagePrefix:
                PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .firstMomentStoragePrefix),
        secondMoments: trajectoryMomentCatalogDigest(
            state.secondMoment,
            storagePrefix:
                PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .secondMomentStoragePrefix),
        control: control)
}

private func trajectoryRunStepAndEvaluation(
    model: PrimeNativeGQADecoder,
    optimizer: AdamW,
    batch: TrajectoryBatch,
    globalStepBefore: UInt64,
    captureGradientEvidence: Bool,
    context: TrajectoryScienceContext
) throws -> TrajectoryStepEvidence {
    let evidence = try trajectoryPerformStepAndEvaluationGraphs(
        model: model,
        optimizer: optimizer,
        batch: batch,
        globalStepBefore: globalStepBefore,
        captureGradientEvidence: captureGradientEvidence,
        context: context)
    // The helper's lexical return destroys every raw/clipped gradient graph
    // reference before this release count is authored.
    try context.counter.increment("gradient_catalog_release_count")
    return evidence
}

private func trajectoryRNGDomains(terminal: Bool) -> [[String: Any]] {
    [
        [
            "domain_id": "model_initialization_v1",
            "algorithm_id": "sha256_counter_stream_v1",
            "key_sha256":
                "81841e917219c7b5f32b1d28f346de8e200944c74db551c4d68b447d640ab7c3",
            "counter": 1,
            "consumption_sha256":
                "09a94232c0e287538033a198c102d21e9e66463cc753195463bd6bcea5dbf49d",
        ],
        [
            "domain_id": "training_data_order_v1",
            "algorithm_id": "sha256_counter_stream_v1",
            "key_sha256":
                "5dac53cfa73ddb616073eb979a105b8670e0032f9f58dcc578c200e01f9fc7e8",
            "counter": terminal ? 2 : 1,
            "consumption_sha256": terminal
                ? "8635f63040d540b810e954758592718d7aa217a8223cd06015bcee7e7bac75cf"
                : "478e3bc27342c234e560fe0f115acadc9322875ed1f0b704111436b54a61aba7",
        ],
        [
            "domain_id": "augmentation_v1",
            "algorithm_id": "sha256_counter_stream_v1",
            "key_sha256":
                "844e82c444546ad5e68ed6aa2b03cb4dc339bbd92890692d0bf6d82f6c101936",
            "counter": 0,
            "consumption_sha256":
                "63de1106d0a8ec16ea7a25f425b09ab314b6bf8613c59be058609744788845b9",
        ],
        [
            "domain_id": "evaluation_v1",
            "algorithm_id": "sha256_counter_stream_v1",
            "key_sha256":
                "015098b6cc2e83b47ae326da0501cd1478d5b9b556975ef7d5775be569878088",
            "counter": 0,
            "consumption_sha256":
                "be7149ab830966707309adfdf1cba38da5c1e7e5036e98d66962f8c025f0f211",
        ],
    ]
}

private func trajectorySnapshotCursor() -> [String: Any] {
    [
        "schema_id":
            "prime_native_decoder_native300m_stage7_fixed_two_batch_cursor_v1",
        "corpus_binding": "synthetic_stage7_fixed_two_batch_fixture_v1",
        "tokenizer_binding": "not_applicable_direct_frozen_token_ids_v1",
        "example_generator_binding": "stage7_seed44_two_batch_formulae_v1",
        "source_inventory_binding":
            "two_in_memory_rank_two_token_and_mask_batches_v1",
        "split_identity": "synthetic_train_only_v1",
        "curriculum_identity": "fixed_batch1_then_batch2_v1",
        "epoch": 0, "next_batch_ordinal": 1, "next_row_index": 1,
        "next_row_ids": ["stage7_fixed_row_1"],
        "next_row_ids_sha256":
            "0ea879e81cb0c6cfe5727a5d326477f795cda9cb30060fdc5654047a9db258e1",
        "next_batch_token_and_mask_sha256":
            "e9ed189a1a8a9204cbc4bcf873e5c8b9c25273b6b9bd2e3c22e9279d1945088e",
    ]
}

private func trajectoryTerminalCursor() -> [String: Any] {
    [
        "schema_id":
            "prime_native_decoder_native300m_stage7_fixed_two_batch_cursor_v1",
        "epoch": 1, "next_batch_ordinal": 2, "next_row_index": 2,
        "next_row_ids": [String](),
        "next_row_ids_sha256":
            "4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945",
        "no_next_batch_identity":
            "end_of_exact_two_batch_fixture_no_next_batch_v1",
        "no_next_batch_sha256":
            "e060fff180d0d64ee23be9ee3a3bbcde166773ad8d207d61f074831258967d7a",
    ]
}

private func trajectoryBaselineControl() throws -> Data {
    try trajectoryCanonicalJSONData([
        "role": "baseline_checkpoint",
        "global_step": 1,
        "schedule_id": "constant_float32_learning_rate_v1",
        "current_learning_rate_float32_bits": Float32(1e-4).bitPattern,
        "rng_domains": trajectoryRNGDomains(terminal: false),
        "data_cursor": trajectorySnapshotCursor(),
        "snapshot_boundary":
            "after_baseline_optimizer_update_and_checked_read_only_evaluation_before_batch2_consumption",
        "checked_evaluation_complete": true,
        "accumulation_phase": 0, "pending_gradient_count": 0,
        "pending_prefetch_count": 0, "kv_cache_entry_count": 0,
        "decoder_training_mode_true": true,
    ])
}

private func trajectoryComparatorControl(
    branchRole: String,
    evidence: TrajectoryStepEvidence
) throws -> Data {
    guard let rawGradients = evidence.rawGradients,
          let clippedGradients = evidence.clippedGradients
    else {
        throw TrajectoryExecutionError.contract(
            "comparator gradient evidence is required")
    }
    let parameterBinding: [String: Any] = [
        "structural_sha256": evidence.postUpdateParameters.structuralSHA256,
        "logical_sha256": evidence.postUpdateParameters.logicalSHA256,
        "path_count": evidence.postUpdateParameters.paths.count,
    ]
    let firstBinding: [String: Any] = [
        "structural_sha256": evidence.firstMoments.structuralSHA256,
        "logical_sha256": evidence.firstMoments.logicalSHA256,
        "path_count": evidence.firstMoments.paths.count,
    ]
    let secondBinding: [String: Any] = [
        "structural_sha256": evidence.secondMoments.structuralSHA256,
        "logical_sha256": evidence.secondMoments.logicalSHA256,
        "path_count": evidence.secondMoments.paths.count,
    ]
    guard let evaluationObject = try trajectoryCanonicalJSONObject(
            evidence.evaluationBinding) as? [String: Any],
          let readOnlyObject = try trajectoryCanonicalJSONObject(
            evidence.evaluationReadOnlyBinding) as? [String: Any]
    else {
        throw TrajectoryExecutionError.contract(
            "comparator evaluation binding objects")
    }
    return try trajectoryCanonicalJSONData([
        "branch_role": branchRole, "global_step": 2,
        "schedule_id": "constant_float32_learning_rate_v1",
        "current_learning_rate_float32_bits": Float32(1e-4).bitPattern,
        "rng_domains": trajectoryRNGDomains(terminal: true),
        "terminal_data_cursor": trajectoryTerminalCursor(),
        "loss_float32_bits": evidence.lossBits,
        "per_target_loss_topology_and_sha256": [
            "shape": [1, 127], "dtype": "float32",
            "sha256": evidence.perTargetLoss.logicalSHA256,
        ],
        "whole_logits_topology_and_sha256": [
            "shape": [1, 128, 512], "dtype": "float32",
            "sha256": evidence.wholeLogits.logicalSHA256,
        ],
        "raw_gradient_catalog_topology_and_sha256": [
            "path_count": 218,
            "structural_sha256": rawGradients.structuralSHA256,
            "logical_sha256": rawGradients.logicalSHA256,
        ],
        "clipped_gradient_catalog_topology_and_sha256": [
            "path_count": 218,
            "structural_sha256": clippedGradients.structuralSHA256,
            "logical_sha256": clippedGradients.logicalSHA256,
        ],
        "raw_norm_float32_bits": evidence.rawNormBits,
        "clipped_norm_float32_bits": evidence.clippedNormBits,
        "clip_scale_float32_bits": evidence.clipScaleBits,
        "post_update_parameter_catalog_binding": parameterBinding,
        "optimizer_first_moment_catalog_binding": firstBinding,
        "optimizer_second_moment_catalog_binding": secondBinding,
        "checked_evaluation_binding": evaluationObject,
        "checked_evaluation_read_only_nonmutation_binding":
            readOnlyObject,
        "decoder_training_mode_true": true,
    ])
}

private func trajectoryPublishCheckpoint(
    role: PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1,
    model: PrimeNativeGQADecoder,
    optimizer: AdamW,
    control: Data,
    context: TrajectoryScienceContext
) throws -> PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1 {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let neutral = try {
        let state = try optimizer.parameters()
        return try Execution.neutralMomentCatalog(
            from: state,
            matching: model.trainableParameters())
    }()
    let binding:
        PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    do {
        binding = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1
            .publish(
                root: context.artifactRoot,
                directory: role.rawValue,
                setRole: role,
                model: model,
                optimizerMoments: neutral,
                controlState: control)
    } catch let error as
        PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error
    {
        if case let .partialPublication(quarantine) = error {
            context.quarantines.append(quarantine)
        }
        if case let .committedPublicationRequiresCleanup(binding) = error {
            context.cleanupOnlyCommittedBindings.append(binding)
        }
        throw error
    }
    try context.counter.increment("v2_weights_write_count")
    try context.counter.increment("v2_internal_verification_load_count")
    try context.counter.increment("optimizer_moment_publish_count")
    try context.counter.increment("leaf_publication_count", by: 4)
    try context.counter.increment("final_commit_publication_count")
    try context.counter.increment("model_allocation_and_materialization_count")
    return binding
}

private func trajectoryCheckpointProjection(
    _ binding:
        PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
) throws -> [String: Any] {
    let external = binding.weightsExternalBinding
    let compatibilityData = try PrimeCanonicalJSON.encode(
        external.manifest.compatibilityIdentity)
    return [
        "set_role": binding.setRole.rawValue,
        "load_authoritative": binding.loadAuthoritative,
        "commit_schema":
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                .checkpointSchemaID,
        "commit_byte_count": binding.commitManifestCanonicalByteCount,
        "commit_sha256": binding.commitManifestCanonicalSHA256,
        "leaf_count": 4,
        "ordered_leaf_roles": binding.orderedLeafBindings.map(\.role.rawValue),
        "each_leaf_byte_count_and_sha256":
            binding.orderedLeafBindings.map { leaf in
                [
                    "role": leaf.role.rawValue,
                    "publication_ordinal": leaf.publicationOrdinal,
                    "byte_count": leaf.artifact.byteCount,
                    "sha256": leaf.artifact.sha256,
                ] as [String: Any]
            },
        "external_v2_binding": [
            "schema_id": external.schemaID,
            "compatibility_identity_sha256":
                PrimeSHA256.hexDigest(of: compatibilityData),
            "artifact_semantic_role": "weights_v2",
            "artifact_path_sha256": PrimeSHA256.hexDigest(
                of: Data(external.artifactBinding.relativePath.utf8)),
            "container_byte_count": external.artifactBinding.byteCount,
            "container_sha256": external.artifactBinding.sha256,
            "manifest_sha256": external.manifestCanonicalSHA256,
        ],
        "control_schema_and_sha256": [
            "schema_id": "prime_native_decoder_trajectory_control_state_v1",
            "canonical_byte_count": binding.controlStateCanonicalByteCount,
            "sha256": binding.controlStateCanonicalSHA256,
        ],
    ]
}

private struct TrajectoryComparisonValue {
    let catalog: TrajectoryCatalogDigest
    let projectsTensorTopology: Bool
}

private struct TrajectoryComparisonIntegrityFailure: Error {
    let path: String
    let expectedBinding: String
    let observedBinding: String
}

private struct TrajectorySafeIntegrityPrefixError: Error {
    let domains: [[String: Any]]
    let mismatch: [String: Any]
}

private func trajectoryOrderedAllowedComparisonPaths(_ index: Int)
    -> [String]
{
    (trajectoryAllowedComparisonPaths(index) ?? []).sorted(
        by: trajectoryRawUTF8Less)
}

private func trajectoryUnmeasuredComparisonDomain(_ index: Int)
    -> [String: Any]
{
    let contract =
        PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
            .frozenV1.comparison.domains[index]
    return [
        "domain_id": contract.id, "kind": contract.kind,
        "path_count": contract.expectedPathCount,
        "catalog_preimage_schema": contract.expectedPathSetBinding,
        "catalog_sha256": NSNull(), "left_total_bytes": NSNull(),
        "left_sha256": NSNull(), "right_total_bytes": NSNull(),
        "right_sha256": NSNull(), "exact": NSNull(),
        "first_mismatch_path": NSNull(),
        "first_mismatch_expected_binding": NSNull(),
        "first_mismatch_observed_binding": NSNull(),
        "tensor_catalog_projection": NSNull(),
    ]
}

private func trajectorySafeIntegrityPrefixError(
    prefix: [[String: Any]],
    failingIndex: Int,
    failure: TrajectoryComparisonIntegrityFailure
) throws -> TrajectorySafeIntegrityPrefixError {
    try trajectoryRequire(
        failingIndex == prefix.count && failingIndex >= 0
            && failingIndex < 18
            && prefix.allSatisfy {
                trajectoryExactBool($0["exact"]) == true
            }
            && trajectoryAllowedComparisonPaths(failingIndex)?
                .contains(failure.path) == true
            && trajectoryIsLowerHex(failure.expectedBinding, count: 64)
            && trajectoryIsLowerHex(failure.observedBinding, count: 64)
            && failure.expectedBinding != failure.observedBinding,
        "safe ordered integrity-prefix evidence")
    return .init(
        domains: prefix + [trajectoryUnmeasuredComparisonDomain(failingIndex)],
        mismatch: [
            "availability": "unavailable",
            "domain_id":
                PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
                    .comparisonDomainIDs[failingIndex],
            "path": failure.path,
            "expected_binding": failure.expectedBinding,
            "observed_binding": failure.observedBinding,
        ])
}

private func trajectoryGenericIntegrityFailure(
    index: Int,
    detail: String
) throws -> TrajectoryComparisonIntegrityFailure {
    guard let path = trajectoryOrderedAllowedComparisonPaths(index).first else {
        throw TrajectoryExecutionError.contract(
            "integrity domain has no frozen member path")
    }
    let contract =
        PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
            .frozenV1.comparison.domains[index]
    let expected = try trajectoryCanonicalJSONData([
        "classification": "expected_authority_domain_contract",
        "domain_id": contract.id, "path": path,
        "path_count": contract.expectedPathCount,
        "path_set_binding": contract.expectedPathSetBinding,
    ])
    let observed = try trajectoryCanonicalJSONData([
        "classification": "observed_integrity_failure",
        "domain_id": contract.id, "path": path, "detail": detail,
    ])
    return .init(
        path: path,
        expectedBinding: PrimeSHA256.hexDigest(of: expected),
        observedBinding: PrimeSHA256.hexDigest(of: observed))
}

private func trajectoryCatalogComparisonValue(
    _ catalog: TrajectoryCatalogDigest
) -> TrajectoryComparisonValue {
    .init(catalog: catalog, projectsTensorTopology: true)
}

private func trajectoryMemberCatalog(
    _ orderedMembers: [(String, Any)]
) throws -> TrajectoryCatalogDigest {
    try trajectoryRequire(
        !orderedMembers.isEmpty
            && Set(orderedMembers.map { $0.0 }).count == orderedMembers.count,
        "comparison member paths")
    let sortedMembers = orderedMembers.sorted {
        trajectoryRawUTF8Less($0.0, $1.0)
    }
    var structural = SHA256()
    var logical = SHA256()
    var paths = [TrajectoryPathDigest]()
    var totalElements: UInt64 = 0
    var totalBytes: UInt64 = 0
    for (path, value) in sortedMembers {
        let bytes = try trajectoryCanonicalJSONData([value])
        let pathData = Data(path.utf8)
        var structuralRecord = Data()
        trajectoryAppendBigEndian(UInt64(pathData.count), to: &structuralRecord)
        structuralRecord.append(pathData)
        trajectoryAppendBigEndian(1, to: &structuralRecord)
        trajectoryAppendBigEndian(UInt64(bytes.count), to: &structuralRecord)
        let dtypeData = Data("canonical_json".utf8)
        trajectoryAppendBigEndian(UInt64(dtypeData.count), to: &structuralRecord)
        structuralRecord.append(dtypeData)
        trajectoryAppendBigEndian(UInt64(bytes.count), to: &structuralRecord)
        trajectoryAppendBigEndian(UInt64(bytes.count), to: &structuralRecord)
        structural.update(data: structuralRecord)
        var logicalPrefix = Data()
        trajectoryAppendBigEndian(UInt64(pathData.count), to: &logicalPrefix)
        logicalPrefix.append(pathData)
        logical.update(data: logicalPrefix)
        logical.update(data: bytes)
        let addition = totalBytes.addingReportingOverflow(UInt64(bytes.count))
        try trajectoryRequire(!addition.overflow, "member byte total")
        totalBytes = addition.partialValue
        let elementAddition = totalElements.addingReportingOverflow(
            UInt64(bytes.count))
        try trajectoryRequire(!elementAddition.overflow, "member element total")
        totalElements = elementAddition.partialValue
        paths.append(.init(
            path: path,
            shape: [bytes.count],
            dtype: "canonical_json",
            elementCount: UInt64(bytes.count),
            logicalByteCount: UInt64(bytes.count),
            logicalSHA256: PrimeSHA256.hexDigest(of: bytes),
            retainedLogicalBytes: nil))
    }
    return .init(
        paths: paths,
        structuralSHA256: trajectoryDigestHex(structural.finalize()),
        logicalSHA256: trajectoryDigestHex(logical.finalize()),
        totalElementCount: totalElements,
        totalLogicalByteCount: totalBytes)
}

private struct TrajectoryMixedComparisonMember {
    let path: String
    let shape: [Int]
    let dtype: String
    let elementCount: UInt64
    let logicalBytes: Data
}

private func trajectoryMixedMemberCatalog(
    _ members: [TrajectoryMixedComparisonMember]
) throws -> TrajectoryCatalogDigest {
    let sorted = members.sorted { trajectoryRawUTF8Less($0.path, $1.path) }
    try trajectoryRequire(
        !sorted.isEmpty && Set(sorted.map(\.path)).count == sorted.count,
        "mixed comparison member paths")
    var structural = SHA256()
    var logical = SHA256()
    var paths = [TrajectoryPathDigest]()
    var totalElements: UInt64 = 0
    var totalBytes: UInt64 = 0
    for member in sorted {
        try trajectoryRequire(
            !member.path.isEmpty && !member.dtype.isEmpty
                && member.elementCount > 0 && !member.logicalBytes.isEmpty,
            "mixed comparison member topology")
        var product: UInt64 = member.shape.isEmpty ? 1 : 1
        for dimension in member.shape {
            try trajectoryRequire(dimension > 0, "mixed member dimension")
            let multiplied = product.multipliedReportingOverflow(
                by: UInt64(dimension))
            try trajectoryRequire(!multiplied.overflow, "mixed member shape")
            product = multiplied.partialValue
        }
        try trajectoryRequire(
            product == member.elementCount
                && (member.dtype != "float32"
                    || member.logicalBytes.count
                        == Int(member.elementCount) * 4),
            "mixed member element/byte topology")
        let pathData = Data(member.path.utf8)
        let dtypeData = Data(member.dtype.utf8)
        var structuralRecord = Data()
        trajectoryAppendBigEndian(UInt64(pathData.count), to: &structuralRecord)
        structuralRecord.append(pathData)
        trajectoryAppendBigEndian(
            UInt64(member.shape.count), to: &structuralRecord)
        for dimension in member.shape {
            trajectoryAppendBigEndian(UInt64(dimension), to: &structuralRecord)
        }
        trajectoryAppendBigEndian(UInt64(dtypeData.count), to: &structuralRecord)
        structuralRecord.append(dtypeData)
        trajectoryAppendBigEndian(member.elementCount, to: &structuralRecord)
        trajectoryAppendBigEndian(
            UInt64(member.logicalBytes.count), to: &structuralRecord)
        structural.update(data: structuralRecord)
        var logicalPrefix = Data()
        trajectoryAppendBigEndian(UInt64(pathData.count), to: &logicalPrefix)
        logicalPrefix.append(pathData)
        logical.update(data: logicalPrefix)
        logical.update(data: member.logicalBytes)
        let elementAddition = totalElements.addingReportingOverflow(
            member.elementCount)
        let byteAddition = totalBytes.addingReportingOverflow(
            UInt64(member.logicalBytes.count))
        try trajectoryRequire(
            !elementAddition.overflow && !byteAddition.overflow,
            "mixed comparison totals")
        totalElements = elementAddition.partialValue
        totalBytes = byteAddition.partialValue
        paths.append(.init(
            path: member.path, shape: member.shape, dtype: member.dtype,
            elementCount: member.elementCount,
            logicalByteCount: UInt64(member.logicalBytes.count),
            logicalSHA256: PrimeSHA256.hexDigest(of: member.logicalBytes),
            retainedLogicalBytes: nil))
    }
    return .init(
        paths: paths,
        structuralSHA256: trajectoryDigestHex(structural.finalize()),
        logicalSHA256: trajectoryDigestHex(logical.finalize()),
        totalElementCount: totalElements,
        totalLogicalByteCount: totalBytes)
}

private func trajectoryFloat32Member(
    path: String,
    bits: UInt32
) -> TrajectoryMixedComparisonMember {
    .init(
        path: path, shape: [], dtype: "float32", elementCount: 1,
        logicalBytes: trajectoryScalarDigest(bits))
}

private func trajectoryTensorMember(
    path: String,
    catalog: TrajectoryCatalogDigest
) throws -> TrajectoryMixedComparisonMember {
    guard catalog.paths.count == 1,
          let source = catalog.paths.first,
          source.dtype == "float32",
          let bytes = source.retainedLogicalBytes,
          UInt64(bytes.count) == source.logicalByteCount,
          PrimeSHA256.hexDigest(of: bytes) == source.logicalSHA256
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY", "mixed tensor logical bytes")
    }
    return .init(
        path: path, shape: source.shape, dtype: source.dtype,
        elementCount: source.elementCount, logicalBytes: bytes)
}

private func trajectoryCanonicalMember(
    path: String,
    value: Any
) throws -> TrajectoryMixedComparisonMember {
    let bytes = try trajectoryCanonicalJSONData([value])
    return .init(
        path: path, shape: [bytes.count], dtype: "canonical_json",
        elementCount: UInt64(bytes.count), logicalBytes: bytes)
}

private func trajectoryLossComparisonValue(
    _ evidence: TrajectoryStepEvidence
) throws -> TrajectoryComparisonValue {
    let catalog = try trajectoryMixedMemberCatalog([
        trajectoryFloat32Member(
            path: "loss_float32_bits", bits: evidence.lossBits),
        try trajectoryTensorMember(
            path: "per_target_loss_tensor_shape_1x127_float32",
            catalog: evidence.perTargetLoss),
        try trajectoryTensorMember(
            path: "whole_logits_tensor_shape_1x128x512_float32",
            catalog: evidence.wholeLogits),
    ])
    return .init(catalog: catalog, projectsTensorTopology: true)
}

private func trajectoryEvaluationComparisonValue(
    _ evidence: TrajectoryStepEvidence
) throws -> TrajectoryComparisonValue {
    let members = try trajectoryJSONObjectDictionary(
        evidence.evaluationBinding, scope: "evaluation binding")
    let readOnly = try trajectoryJSONObjectDictionary(
        evidence.evaluationReadOnlyBinding,
        scope: "evaluation read-only binding")
    guard let loss = trajectoryExactUInt64(members["loss_float32_bits"]),
          loss <= UInt64(UInt32.max),
          let preModel = readOnly["pre_model_catalog_sha256"],
          let postModel = readOnly["post_model_catalog_sha256"],
          let preOptimizer = readOnly["pre_optimizer_catalog_sha256"],
          let postOptimizer = readOnly["post_optimizer_catalog_sha256"],
          let preControl = readOnly["pre_control_sha256"],
          let postControl = readOnly["post_control_sha256"],
          let restored = readOnly["training_mode_restored_true"]
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY", "evaluation mixed members")
    }
    let catalog = try trajectoryMixedMemberCatalog([
        trajectoryFloat32Member(
            path: "loss_float32_bits", bits: UInt32(loss)),
        try trajectoryTensorMember(
            path: "per_target_loss_tensor_shape_1x127_float32",
            catalog: evidence.evaluationPerTargetLoss),
        try trajectoryTensorMember(
            path: "whole_logits_tensor_shape_1x128x512_float32",
            catalog: evidence.evaluationWholeLogits),
        try trajectoryCanonicalMember(
            path: "pre_model_catalog_binding", value: preModel),
        try trajectoryCanonicalMember(
            path: "post_model_catalog_binding", value: postModel),
        try trajectoryCanonicalMember(
            path: "pre_post_optimizer_catalog_binding",
            value: ["pre": preOptimizer, "post": postOptimizer]),
        try trajectoryCanonicalMember(
            path: "pre_post_control_binding",
            value: ["pre": preControl, "post": postControl]),
        try trajectoryCanonicalMember(
            path: "training_mode_restored_true", value: restored),
    ])
    return .init(catalog: catalog, projectsTensorTopology: true)
}

private func trajectoryMemberComparisonValue(
    object: [String: Any],
    orderedPaths: [String],
    projectsTensorTopology: Bool = false
) throws -> TrajectoryComparisonValue {
    var members = [(String, Any)]()
    for path in orderedPaths {
        guard let value = object[path] else {
            throw TrajectoryExecutionError.classified(
                "ABSTAIN_INTEGRITY",
                "missing comparison member \(path)")
        }
        members.append((path, value))
    }
    return .init(
        catalog: try trajectoryMemberCatalog(members),
        projectsTensorTopology: projectsTensorTopology)
}

private func trajectorySameCatalogTopology(
    _ left: TrajectoryCatalogDigest,
    _ right: TrajectoryCatalogDigest
) -> Bool {
    guard left.paths.count == right.paths.count else { return false }
    for (lhs, rhs) in zip(left.paths, right.paths) {
        guard lhs.path == rhs.path,
              lhs.shape == rhs.shape,
              lhs.dtype == rhs.dtype,
              lhs.elementCount == rhs.elementCount,
              lhs.logicalByteCount == rhs.logicalByteCount
        else { return false }
    }
    return true
}

private func trajectoryTopologyDictionary(
    _ path: TrajectoryPathDigest?
) -> Any {
    guard let path else { return NSNull() }
    return [
        "path": path.path, "shape": path.shape, "dtype": path.dtype,
        "element_count": path.elementCount,
        "logical_byte_count": path.logicalByteCount,
    ] as [String: Any]
}

private func trajectoryComparisonTopologyFailure(
    index: Int,
    left: TrajectoryComparisonValue,
    right: TrajectoryComparisonValue
) throws -> TrajectoryComparisonIntegrityFailure {
    let contract =
        PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
            .frozenV1.comparison.domains[index]
    let ordered = trajectoryOrderedAllowedComparisonPaths(index)
    guard let fallback = ordered.first else {
        throw TrajectoryExecutionError.contract(
            "comparison topology has no frozen path")
    }
    var leftByPath = [String: TrajectoryPathDigest]()
    var rightByPath = [String: TrajectoryPathDigest]()
    var duplicatePath: String?
    for path in left.catalog.paths {
        if leftByPath.updateValue(path, forKey: path.path) != nil {
            duplicatePath = duplicatePath ?? path.path
        }
    }
    for path in right.catalog.paths {
        if rightByPath.updateValue(path, forKey: path.path) != nil {
            duplicatePath = duplicatePath ?? path.path
        }
    }
    let mismatchPath = duplicatePath.flatMap { duplicate in
        ordered.contains(duplicate) ? duplicate : nil
    } ?? ordered.first { path in
        guard let lhs = leftByPath[path], let rhs = rightByPath[path] else {
            return true
        }
        return lhs.shape != rhs.shape || lhs.dtype != rhs.dtype
            || lhs.elementCount != rhs.elementCount
            || lhs.logicalByteCount != rhs.logicalByteCount
    } ?? fallback
    let expected = try trajectoryCanonicalJSONData([
        "classification": "expected_authority_pair_topology",
        "domain_id": contract.id, "path": mismatchPath,
        "path_count": contract.expectedPathCount,
        "path_set_binding": contract.expectedPathSetBinding,
        "tensor_projection_required":
            contract.kind == "tensor_catalog"
                || contract.kind == "scalar_and_tensor",
        "left_topology": trajectoryTopologyDictionary(leftByPath[mismatchPath]),
    ])
    let observed = try trajectoryCanonicalJSONData([
        "classification": "observed_pair_topology",
        "domain_id": contract.id, "path": mismatchPath,
        "left_path_count": left.catalog.paths.count,
        "right_path_count": right.catalog.paths.count,
        "left_projects_tensor_topology": left.projectsTensorTopology,
        "right_projects_tensor_topology": right.projectsTensorTopology,
        "right_topology":
            trajectoryTopologyDictionary(rightByPath[mismatchPath]),
    ])
    return .init(
        path: mismatchPath,
        expectedBinding: PrimeSHA256.hexDigest(of: expected),
        observedBinding: PrimeSHA256.hexDigest(of: observed))
}

private func trajectoryComparisonResult(
    index: Int,
    left: TrajectoryComparisonValue,
    right: TrajectoryComparisonValue
) throws -> [String: Any] {
    typealias Authority =
        PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
    let contract = Authority.frozenV1.comparison.domains[index]
    var mismatchPath: Any = NSNull()
    var expectedBinding: Any = NSNull()
    var observedBinding: Any = NSNull()
    let leftCatalog = left.catalog
    let rightCatalog = right.catalog
    let expectedTensorProjection = contract.kind == "tensor_catalog"
        || contract.kind == "scalar_and_tensor"
    let orderedAllowedPaths = trajectoryOrderedAllowedComparisonPaths(index)
    guard left.projectsTensorTopology == expectedTensorProjection,
          right.projectsTensorTopology == expectedTensorProjection,
          leftCatalog.paths.count == contract.expectedPathCount,
          leftCatalog.paths.map(\.path) == orderedAllowedPaths,
          rightCatalog.paths.map(\.path) == orderedAllowedPaths,
          !expectedTensorProjection
            || trajectorySameCatalogTopology(leftCatalog, rightCatalog)
    else {
        throw try trajectoryComparisonTopologyFailure(
            index: index, left: left, right: right)
    }
    let exact = leftCatalog.logicalSHA256 == rightCatalog.logicalSHA256
    var projection: Any = NSNull()
    let catalogSHA = leftCatalog.structuralSHA256
    let leftBytes = leftCatalog.totalLogicalByteCount
    let rightBytes = rightCatalog.totalLogicalByteCount
    let leftSHA = leftCatalog.logicalSHA256
    let rightSHA = rightCatalog.logicalSHA256
    if !exact,
       let pair = zip(leftCatalog.paths, rightCatalog.paths).first(where: {
           $0.0.logicalSHA256 != $0.1.logicalSHA256
       })
    {
        mismatchPath = pair.0.path
        expectedBinding = pair.0.logicalSHA256
        observedBinding = pair.1.logicalSHA256
    }
    if left.projectsTensorTopology {
        projection = [
            "algorithm_id":
                "prime_stage7_sorted_path_shape_dtype_element_and_byte_count_sha256_v1",
            "sorted_unique_path_count": leftCatalog.paths.count,
            "shape_dtype_element_and_byte_count_preimage_sha256":
                leftCatalog.structuralSHA256,
            "canonical_logical_bytes_preimage_sha256":
                leftCatalog.logicalSHA256,
            "total_element_count": leftCatalog.totalElementCount,
            "total_logical_byte_count": leftCatalog.totalLogicalByteCount,
            "first_mismatch_path_if_any": mismatchPath,
        ] as [String: Any]
    }
    return [
        "domain_id": contract.id, "kind": contract.kind,
        "path_count": contract.expectedPathCount,
        "catalog_preimage_schema": contract.expectedPathSetBinding,
        "catalog_sha256": catalogSHA,
        "left_total_bytes": leftBytes, "left_sha256": leftSHA,
        "right_total_bytes": rightBytes, "right_sha256": rightSHA,
        "exact": exact, "first_mismatch_path": mismatchPath,
        "first_mismatch_expected_binding": expectedBinding,
        "first_mismatch_observed_binding": observedBinding,
        "tensor_catalog_projection": projection,
    ]
}

private func trajectoryJSONObjectDictionary(
    _ data: Data,
    scope: String
) throws -> [String: Any] {
    guard let object = try trajectoryCanonicalJSONObject(data)
            as? [String: Any]
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY", "\(scope) canonical object")
    }
    return object
}

private func trajectoryStreamedCatalogPair(
    _ streamed: PrimeNativeDecoderNative300MTrajectoryStreamedCatalogV1
) -> (TrajectoryComparisonValue, TrajectoryComparisonValue) {
    let leftPaths = streamed.tensors.map {
        TrajectoryPathDigest(
            path: $0.path, shape: $0.shape, dtype: $0.dtype,
            elementCount: $0.elementCount,
            logicalByteCount: $0.logicalByteCount,
            logicalSHA256: $0.leftLogicalSHA256,
            retainedLogicalBytes: nil)
    }
    let rightPaths = streamed.tensors.map {
        TrajectoryPathDigest(
            path: $0.path, shape: $0.shape, dtype: $0.dtype,
            elementCount: $0.elementCount,
            logicalByteCount: $0.logicalByteCount,
            logicalSHA256: $0.rightLogicalSHA256,
            retainedLogicalBytes: nil)
    }
    let left = TrajectoryCatalogDigest(
        paths: leftPaths,
        structuralSHA256: streamed.structuralSHA256,
        logicalSHA256: streamed.leftLogicalSHA256,
        totalElementCount: streamed.totalElementCount,
        totalLogicalByteCount: streamed.totalLogicalByteCount)
    let right = TrajectoryCatalogDigest(
        paths: rightPaths,
        structuralSHA256: streamed.structuralSHA256,
        logicalSHA256: streamed.rightLogicalSHA256,
        totalElementCount: streamed.totalElementCount,
        totalLogicalByteCount: streamed.totalLogicalByteCount)
    return (
        trajectoryCatalogComparisonValue(left),
        trajectoryCatalogComparisonValue(right))
}

private func trajectoryRNGMembers(
    _ control: [String: Any]
) throws -> [String: Any] {
    guard let records = control["rng_domains"] as? [[String: Any]],
          records.count == 4
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY", "successor RNG members")
    }
    var result = [String: Any]()
    for record in records {
        guard let domain = record["domain_id"] as? String,
              result.updateValue(
                  record,
                  forKey: "rng_domains.\(domain)") == nil
        else {
            throw TrajectoryExecutionError.classified(
                "ABSTAIN_INTEGRITY", "successor RNG member identity")
        }
    }
    return result
}

private func trajectoryOptimizerMembers(
    _ control: [String: Any]
) throws -> [String: Any] {
    guard let globalStep = control["global_step"],
          let schedule = control["schedule_id"],
          let learningRate = control["current_learning_rate_float32_bits"]
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY", "persisted optimizer members")
    }
    return [
        "global_step": globalStep, "initial_global_step": 0,
        "snapshot_global_step": 1, "schedule_id": schedule,
        "current_learning_rate_float32_bits": learningRate,
    ]
}

private func trajectoryCursorMembers(
    _ control: [String: Any]
) throws -> [String: Any] {
    guard let cursor = control["terminal_data_cursor"],
          let training = control["decoder_training_mode_true"]
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY", "persisted cursor members")
    }
    return [
        "terminal_data_cursor": cursor,
        "accumulation_phase": 0, "pending_gradient_count": 0,
        "pending_prefetch_count": 0, "kv_cache_entry_count": 0,
        "snapshot_boundary_consumed_once": true,
        "evaluation_did_not_advance_cursor": true,
        "decoder_training_mode_true": training,
    ]
}

private func trajectoryComparatorControlMemberPath(
    field: String,
    domainIndex: Int
) throws -> String {
    let explicit: [String: String] = [
        "loss_float32_bits": "loss_float32_bits",
        "per_target_loss_topology_and_sha256":
            "per_target_loss_tensor_shape_1x127_float32",
        "whole_logits_topology_and_sha256":
            "whole_logits_tensor_shape_1x128x512_float32",
        "raw_norm_float32_bits": "raw_norm_float32_bits",
        "clipped_norm_float32_bits": "clipped_global_norm_float32_bits",
        "clip_scale_float32_bits": "clip_scale_float32_bits",
        "checked_evaluation_binding": "loss_float32_bits",
        "checked_evaluation_read_only_nonmutation_binding":
            "pre_model_catalog_binding",
        "global_step": "global_step", "schedule_id": "schedule_id",
        "current_learning_rate_float32_bits":
            "current_learning_rate_float32_bits",
        "rng_domains": "rng_domains.augmentation_v1",
        "terminal_data_cursor": "terminal_data_cursor",
        "decoder_training_mode_true": "decoder_training_mode_true",
    ]
    let path = explicit[field]
        ?? trajectoryOrderedAllowedComparisonPaths(domainIndex).first
    guard let path,
          trajectoryAllowedComparisonPaths(domainIndex)?.contains(path) == true
    else {
        throw TrajectoryExecutionError.contract(
            "persisted control field has no comparison member")
    }
    return path
}

private func trajectoryComparatorControlCrossBindingFailure(
    index: Int,
    left: [String: Any],
    right: [String: Any],
    expectedLeft: [String: Any],
    expectedRight: [String: Any]
) throws -> TrajectoryComparisonIntegrityFailure? {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let domainID = Execution.comparisonDomainIDs[index]
    let fields = Execution.comparatorControlFieldToDomainID.compactMap {
        $0.value == domainID ? $0.key : nil
    }.sorted(by: trajectoryRawUTF8Less)
    for field in fields {
        guard let leftValue = left[field],
              let rightValue = right[field],
              let expectedLeftValue = expectedLeft[field],
              let expectedRightValue = expectedRight[field]
        else {
            return try trajectoryGenericIntegrityFailure(
                index: index,
                detail: "missing persisted comparator field \(field)")
        }
        for (branch, expectedValue, observedValue) in [
            ("uninterrupted", expectedLeftValue, leftValue),
            ("resumed", expectedRightValue, rightValue),
        ] {
            let expectedData = try trajectoryCanonicalJSONData([expectedValue])
            let observedData = try trajectoryCanonicalJSONData([observedValue])
            if expectedData != observedData {
                let path = try trajectoryComparatorControlMemberPath(
                    field: field, domainIndex: index)
                let expected = try trajectoryCanonicalJSONData([
                    "branch": branch, "field": field, "path": path,
                    "value": expectedValue,
                ])
                let observed = try trajectoryCanonicalJSONData([
                    "branch": branch, "field": field, "path": path,
                    "value": observedValue,
                ])
                return .init(
                    path: path,
                    expectedBinding: PrimeSHA256.hexDigest(of: expected),
                    observedBinding: PrimeSHA256.hexDigest(of: observed))
            }
        }
    }
    return nil
}

private func trajectoryFirstComparatorControlMismatchField(
    left: [String: Any],
    right: [String: Any]
) throws -> String? {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    for field in Execution.comparatorControlFieldToDomainID.keys.sorted(
        by: trajectoryRawUTF8Less)
    {
        guard let leftValue = left[field], let rightValue = right[field] else {
            throw TrajectoryExecutionError.contract(
                "missing persisted comparator semantic field")
        }
        if try trajectoryCanonicalJSONData([leftValue])
            != trajectoryCanonicalJSONData([rightValue])
        {
            return field
        }
    }
    return nil
}

private func trajectoryBuildCompleteComparisons(
    snapshot: TrajectorySnapshotEvidence,
    restoredSnapshot: TrajectorySnapshotEvidence,
    uninterrupted: TrajectoryStepEvidence,
    resumed: TrajectoryStepEvidence,
    streamed:
        PrimeNativeDecoderNative300MTrajectoryStreamingComparisonV1
) throws -> [[String: Any]] {
    guard let uninterruptedRaw = uninterrupted.rawGradients,
          let resumedRaw = resumed.rawGradients,
          let uninterruptedClipped = uninterrupted.clippedGradients,
          let resumedClipped = resumed.clippedGradients
    else {
        throw TrajectoryExecutionError.contract(
            "complete comparator gradient evidence")
    }
    let leftControl = try trajectoryJSONObjectDictionary(
        streamed.uninterruptedControlState,
        scope: "uninterrupted comparator control")
    let rightControl = try trajectoryJSONObjectDictionary(
        streamed.resumedControlState,
        scope: "resumed comparator control")
    let expectedLeftControlData = try trajectoryComparatorControl(
        branchRole: "uninterrupted_n_plus_1", evidence: uninterrupted)
    let expectedRightControlData = try trajectoryComparatorControl(
        branchRole: "resumed_n_plus_1", evidence: resumed)
    let expectedLeftControl = try trajectoryJSONObjectDictionary(
        expectedLeftControlData,
        scope: "expected uninterrupted comparator control")
    let expectedRightControl = try trajectoryJSONObjectDictionary(
        expectedRightControlData,
        scope: "expected resumed comparator control")
    let snapshotLeft = try trajectoryJSONObjectDictionary(
        snapshot.control, scope: "snapshot control")
    let snapshotRight = try trajectoryJSONObjectDictionary(
        restoredSnapshot.control, scope: "restored snapshot control")
    let batchLeft = try trajectoryJSONObjectDictionary(
        uninterrupted.batchBinding, scope: "uninterrupted batch")
    let batchRight = try trajectoryJSONObjectDictionary(
        resumed.batchBinding, scope: "resumed batch")
    let streamedWeights = trajectoryStreamedCatalogPair(streamed.weights)
    let streamedFirst = trajectoryStreamedCatalogPair(streamed.firstMoments)
    let streamedSecond = trajectoryStreamedCatalogPair(streamed.secondMoments)
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    func fixed(_ domain: String) -> [String] {
        Execution.fixedComparisonMemberPathsByDomainID[domain]!
    }
    typealias Pair = (TrajectoryComparisonValue, TrajectoryComparisonValue)
    // Closures deliberately delay each pair's construction.  If topology or
    // member evidence fails, the already validated exact prefix is still
    // available for the frozen safe-integrity receipt.
    let pairBuilders: [() throws -> Pair] = [
        {
            (trajectoryCatalogComparisonValue(snapshot.weights),
             trajectoryCatalogComparisonValue(restoredSnapshot.weights))
        },
        {
            (trajectoryCatalogComparisonValue(snapshot.firstMoments),
             trajectoryCatalogComparisonValue(restoredSnapshot.firstMoments))
        },
        {
            (trajectoryCatalogComparisonValue(snapshot.secondMoments),
             trajectoryCatalogComparisonValue(restoredSnapshot.secondMoments))
        },
        {
            (try trajectoryMemberComparisonValue(
                object: snapshotLeft,
                orderedPaths: fixed(
                    "snapshot_full_canonical_control_state_roundtrip")),
             try trajectoryMemberComparisonValue(
                object: snapshotRight,
                orderedPaths: fixed(
                    "snapshot_full_canonical_control_state_roundtrip")))
        },
        {
            (try trajectoryMemberComparisonValue(
                object: batchLeft,
                orderedPaths: fixed("batch2_token_and_mask_digest")),
             try trajectoryMemberComparisonValue(
                object: batchRight,
                orderedPaths: fixed("batch2_token_and_mask_digest")))
        },
        {
            (try trajectoryLossComparisonValue(uninterrupted),
             try trajectoryLossComparisonValue(resumed))
        },
        {
            (trajectoryCatalogComparisonValue(uninterruptedRaw),
             trajectoryCatalogComparisonValue(resumedRaw))
        },
        {
            (trajectoryCatalogComparisonValue(uninterruptedClipped),
             trajectoryCatalogComparisonValue(resumedClipped))
        },
        {
            (try trajectoryMemberComparisonValue(
                object: ["raw_norm_float32_bits": uninterrupted.rawNormBits],
                orderedPaths: fixed("successor_raw_norm_bits")),
             try trajectoryMemberComparisonValue(
                object: ["raw_norm_float32_bits": resumed.rawNormBits],
                orderedPaths: fixed("successor_raw_norm_bits")))
        },
        {
            (try trajectoryMemberComparisonValue(
                object: [
                    "clipped_global_norm_float32_bits":
                        uninterrupted.clippedNormBits,
                ],
                orderedPaths: fixed("successor_clipped_global_norm_bits")),
             try trajectoryMemberComparisonValue(
                object: [
                    "clipped_global_norm_float32_bits": resumed.clippedNormBits,
                ],
                orderedPaths: fixed("successor_clipped_global_norm_bits")))
        },
        {
            (try trajectoryMemberComparisonValue(
                object: [
                    "clip_scale_float32_bits": uninterrupted.clipScaleBits,
                ], orderedPaths: fixed("successor_clip_scale_bits")),
             try trajectoryMemberComparisonValue(
                object: ["clip_scale_float32_bits": resumed.clipScaleBits],
                orderedPaths: fixed("successor_clip_scale_bits")))
        },
        { streamedWeights },
        { streamedFirst },
        { streamedSecond },
        {
            (try trajectoryEvaluationComparisonValue(uninterrupted),
             try trajectoryEvaluationComparisonValue(resumed))
        },
        {
            (try trajectoryMemberComparisonValue(
                object: trajectoryOptimizerMembers(leftControl),
                orderedPaths: fixed(
                    "optimizer_global_step_schedule_and_current_learning_rate_bits")),
             try trajectoryMemberComparisonValue(
                object: trajectoryOptimizerMembers(rightControl),
                orderedPaths: fixed(
                    "optimizer_global_step_schedule_and_current_learning_rate_bits")))
        },
        {
            (try trajectoryMemberComparisonValue(
                object: trajectoryRNGMembers(leftControl),
                orderedPaths: fixed(
                    "explicit_rng_algorithm_domain_key_counter_and_consumption_digest")),
             try trajectoryMemberComparisonValue(
                object: trajectoryRNGMembers(rightControl),
                orderedPaths: fixed(
                    "explicit_rng_algorithm_domain_key_counter_and_consumption_digest")))
        },
        {
            (try trajectoryMemberComparisonValue(
                object: trajectoryCursorMembers(leftControl),
                orderedPaths: fixed("cursor_and_snapshot_boundary_zero_state")),
             try trajectoryMemberComparisonValue(
                object: trajectoryCursorMembers(rightControl),
                orderedPaths: fixed("cursor_and_snapshot_boundary_zero_state")))
        },
    ]
    try trajectoryRequire(pairBuilders.count == 18, "comparison builder count")
    var results = [[String: Any]]()
    results.reserveCapacity(pairBuilders.count)
    for (index, buildPair) in pairBuilders.enumerated() {
        do {
            if let failure = try trajectoryComparatorControlCrossBindingFailure(
                index: index,
                left: leftControl,
                right: rightControl,
                expectedLeft: expectedLeftControl,
                expectedRight: expectedRightControl)
            {
                throw failure
            }
            let pair = try buildPair()
            results.append(try trajectoryComparisonResult(
                index: index, left: pair.0, right: pair.1))
        } catch let failure as TrajectoryComparisonIntegrityFailure {
            throw try trajectorySafeIntegrityPrefixError(
                prefix: results, failingIndex: index, failure: failure)
        } catch let error as TrajectoryExecutionError {
            if case .classified(let classification, let detail) = error,
               classification == "ABSTAIN_INTEGRITY"
            {
                let failure = try trajectoryGenericIntegrityFailure(
                    index: index, detail: detail)
                throw try trajectorySafeIntegrityPrefixError(
                    prefix: results, failingIndex: index, failure: failure)
            }
            throw error
        }
    }
    let successorSemanticExact = results[5...].allSatisfy {
        trajectoryExactBool($0["exact"]) == true
    }
    let firstControlMismatch = try trajectoryFirstComparatorControlMismatchField(
        left: leftControl, right: rightControl)
    if successorSemanticExact {
        try trajectoryRequire(
            streamed.controlSemanticExact
                && streamed.firstControlMismatchPath == nil
                && firstControlMismatch == nil,
            "exact streamed comparator control semantic result")
    } else {
        guard let firstControlMismatch,
              let domainID = Execution
                .comparatorControlFieldToDomainID[firstControlMismatch],
              let domainIndex = Execution.comparisonDomainIDs.firstIndex(
                of: domainID)
        else {
            throw TrajectoryExecutionError.contract(
                "persisted comparator mismatch field mapping")
        }
        try trajectoryRequire(
            !streamed.controlSemanticExact
                && streamed.firstControlMismatchPath == firstControlMismatch
                && trajectoryExactBool(results[domainIndex]["exact"]) == false,
            "nonexact streamed comparator control field/domain mapping")
    }
    return results
}

private struct TrajectoryUninterruptedClosure: Codable, Equatable {
    let snapshot: TrajectorySnapshotEvidence
    let successor: TrajectoryStepEvidence
}

private struct TrajectoryResumedClosure {
    let restoredSnapshot: TrajectorySnapshotEvidence
    let successor: TrajectoryStepEvidence
}

private func trajectoryMakeAdamW() -> AdamW {
    AdamW(
        learningRate: Float32(1e-4),
        betas: (Float32(0.9), Float32(0.999)),
        eps: Float32(1e-8),
        weightDecay: Float32(0.01))
}

private func trajectoryObserveBoundFile(
    path: String,
    expectedByteCount: UInt64,
    expectedSHA256: String,
    semanticRole: String
) throws -> [String: Any] {
    let descriptor = path.withCString {
        Darwin.open($0, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
    }
    guard descriptor >= 0 else {
        throw TrajectoryExecutionError.posix("bound file open", errno)
    }
    defer { _ = Darwin.close(descriptor) }
    var status = stat()
    try trajectoryRequire(
        fstat(descriptor, &status) == 0
            && status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && status.st_size >= 0
            && UInt64(status.st_size) == expectedByteCount
            && status.st_nlink == 1,
        "bound file descriptor identity")
    var hasher = SHA256()
    var buffer = [UInt8](repeating: 0, count: 64 * 1024)
    var offset: UInt64 = 0
    while offset < expectedByteCount {
        let count = Int(min(UInt64(buffer.count), expectedByteCount - offset))
        let result = buffer.withUnsafeMutableBytes {
            Darwin.pread(
                descriptor, $0.baseAddress, count, off_t(offset))
        }
        if result < 0, errno == EINTR { continue }
        try trajectoryRequire(result == count, "bound file pread")
        hasher.update(data: Data(buffer.prefix(count)))
        offset += UInt64(count)
    }
    let observedSHA256 = trajectoryDigestHex(hasher.finalize())
    try trajectoryRequire(
        observedSHA256 == expectedSHA256,
        "bound file content SHA-256")
    return [
        "semantic_role": semanticRole,
        "path_sha256": PrimeSHA256.hexDigest(of: Data(path.utf8)),
        "byte_count": expectedByteCount,
        "content_sha256": observedSHA256,
    ]
}

private func trajectorySysctlString(_ name: String) throws -> String {
    var count: size_t = 0
    try trajectoryRequire(
        name.withCString {
            sysctlbyname($0, nil, &count, nil, 0)
        } == 0 && count > 1,
        "operating-system sysctl size")
    var bytes = [CChar](repeating: 0, count: count)
    try trajectoryRequire(
        name.withCString { key in
            sysctlbyname(key, &bytes, &count, nil, 0)
        } == 0,
        "operating-system sysctl value")
    return String(cString: bytes)
}

private func trajectoryOperatingSystemBuild() throws -> String {
    let product = try trajectorySysctlString("kern.osproductversion")
    let build = try trajectorySysctlString("kern.osversion")
    return product + "-" + build
}

private func trajectoryObservedEnvironment(
    _ bindings: TrajectoryLauncherBindings
) throws -> [String: Any] {
    let environment = ProcessInfo.processInfo.environment
    _ = try PrimeNativeDecoderCIMLXComputeEnvironmentPolicy
        .validateLaunched(environment: environment)
    let operatingSystemBuild = try trajectoryOperatingSystemBuild()
    try trajectoryRequire(
        environment["MLX_ENABLE_TF32"] == "0"
            && operatingSystemBuild == bindings.operatingSystemBuild,
        "observed MLX and operating-system environment")
    let staged = try trajectoryObserveBoundFile(
        path: bindings.stagedMetallibPath,
        expectedByteCount: bindings.stagedMetallibBytes,
        expectedSHA256: bindings.stagedMetallibSHA256,
        semanticRole: "staged_metallib")
    let runtime = try trajectoryObserveBoundFile(
        path: bindings.runtimeMetallibPath,
        expectedByteCount: bindings.runtimeMetallibBytes,
        expectedSHA256: bindings.runtimeMetallibSHA256,
        semanticRole: "runtime_metallib")
    return [
        "mlx_enable_tf32": "0",
        "mlx_checkout_origin": bindings.mlxOrigin,
        "mlx_revision": bindings.mlxRevision,
        "swiftpm_configuration": bindings.buildConfiguration,
        "graph_mode": "eager_uncompiled_no_compile_transform",
        "compile_transform_count": 0,
        "operating_system_build": bindings.operatingSystemBuild,
        "xcode_build": bindings.xcodeBuild,
        "swift_driver": bindings.swiftDriver,
        "swift_sdk": bindings.swiftSDK,
        "staged_metallib": staged,
        "runtime_metallib": runtime,
    ]
}

private func trajectoryDeviceDictionary(
    metalDevice: any MTLDevice,
    configuredMemoryLimit: UInt64,
    prePostEqual: Bool
) -> [String: Any] {
    [
        "metal_device_count": 1, "metal_device_index": 0,
        "metal_device_name": metalDevice.name,
        "metal_device_registry_id": metalDevice.registryID,
        "metal_device_is_default": true,
        "metal_device_has_unified_memory": metalDevice.hasUnifiedMemory,
        "metal_device_max_buffer_length_bytes":
            UInt64(metalDevice.maxBufferLength),
        "metal_device_recommended_max_working_set_bytes":
            UInt64(metalDevice.recommendedMaxWorkingSetSize),
        "mlx_device_type": "gpu", "mlx_device_index": 0,
        "mlx_default_device_is_supplied_device": true,
        "mlx_default_stream_is_gpu": true, "cpu_fallback_used": false,
        "stream_order":
            "single_default_gpu_stream_program_order_v1",
        "evaluation_order":
            "training_update_then_checked_read_only_evaluation_v1",
        "configured_memory_limit_bytes": configuredMemoryLimit,
        "configured_cache_limit_bytes": 0,
        "pre_post_identity_and_policy_equal": prePostEqual,
    ]
}

private func trajectoryPostflightIdentityEqual(
    metalDevice: any MTLDevice,
    executionDevice: Device,
    configuredMemoryLimit: UInt64
) -> Bool {
    let devices = MTLCopyAllDevices()
    guard devices.count == 1,
          let defaultDevice = MTLCreateSystemDefaultDevice()
    else { return false }
    let observed = devices[0]
    return observed.registryID == metalDevice.registryID
        && defaultDevice.registryID == metalDevice.registryID
        && observed.name == metalDevice.name
        && observed.hasUnifiedMemory == metalDevice.hasUnifiedMemory
        && observed.maxBufferLength == metalDevice.maxBufferLength
        && observed.recommendedMaxWorkingSetSize
            == metalDevice.recommendedMaxWorkingSetSize
        && executionDevice.deviceType == .gpu
        && Device.defaultDevice() === executionDevice
        && Stream() == Stream.gpu
        && MLX.Memory.memoryLimit >= 0
        && UInt64(MLX.Memory.memoryLimit) == configuredMemoryLimit
        && MLX.Memory.cacheLimit == 0
}

private func trajectoryCleanupDictionary(
    _ cleanup: PrimeNativeDecoderNative300MTrajectoryCleanupV1
) -> [String: Any] {
    [
        "initial_inventory_empty": true,
        "known_inventory_before_cleanup": cleanup.knownLeafCount,
        "unknown_inventory_count": cleanup.unknownInventoryCount,
        "deleted_known_leaf_count": cleanup.deletedLeafCount,
        "deleted_private_comparator_count":
            cleanup.deletedPrivateComparatorCount,
        "post_cleanup_inventory_empty": cleanup.postCleanupInventoryEmpty,
        "absence_proved": cleanup.absenceProved,
        "recursive_cleanup_used": cleanup.recursiveCleanupUsed,
        "artifact_upload_count": 0, "retained_artifact_count": 0,
    ]
}

private func trajectoryEmptyCleanupDictionary() -> [String: Any] {
    [
        "initial_inventory_empty": true, "known_inventory_before_cleanup": 0,
        "unknown_inventory_count": 0, "deleted_known_leaf_count": 0,
        "deleted_private_comparator_count": 0,
        "post_cleanup_inventory_empty": true, "absence_proved": true,
        "recursive_cleanup_used": false, "artifact_upload_count": 0,
        "retained_artifact_count": 0,
    ]
}

private func trajectoryCandidate(
    bindings: TrajectoryLauncherBindings,
    environment: [String: Any],
    device: [String: Any],
    context: TrajectoryScienceContext,
    status: String,
    mismatch: [String: Any],
    cleanup: [String: Any]
) throws -> [String: Any] {
    [
        "schema":
            PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
                .candidateSchemaID,
        "authority_and_predecessor_bindings":
            bindings.authorityAndPredecessorBindings,
        "implementation_inventory": bindings.implementationInventory,
        "terminal_scientific_status": status,
        "one_shot": [
            "consumed": true, "opportunity_count": 1,
            "retry_authorized": false, "rerun_authorized": false,
            "replacement_authorized": false,
        ],
        "environment": environment, "device_and_stream": device,
        "operation_counts": context.counter.candidateDictionary(),
        "baseline_checkpoint_binding": try context.baselineBinding.map(
            trajectoryCheckpointProjection) ?? NSNull(),
        "uninterrupted_comparator_binding":
            try context.uninterruptedBinding.map(
                trajectoryCheckpointProjection) ?? NSNull(),
        "resumed_comparator_binding": try context.resumedBinding.map(
            trajectoryCheckpointProjection) ?? NSNull(),
        "comparison_domains": context.comparisonDomains,
        "first_mismatch": mismatch, "resource_phases": context.phases,
        "artifact_inventory_and_cleanup": cleanup,
        "raw_private_paths": bindings.rawPrivatePaths,
    ]
}

private func trajectoryRunUninterruptedClosure(
    context: TrajectoryScienceContext
) throws -> TrajectoryUninterruptedClosure {
    let configuration = try PrimeNativeGQADecoderConfiguration
        .native300MInventory(vocabularySize: 512)
    let model = PrimeNativeGQADecoder.make(
        configuration: configuration, seed: 44)
    model.train(true)
    try context.counter.increment("model_allocation_and_materialization_count")
    let optimizer = trajectoryMakeAdamW()
    try context.counter.increment("optimizer_allocation_count")
    try checkedEval(model)
    try context.counter.increment("resource_measurement_checked_eval_count")
    try trajectoryObserveResourcePhase(
        "post_initial_model_materialization", context: context)

    let batch1 = try trajectoryMakeBatch(
        stride: 73, offset: 44,
        expectedSHA256:
            "7fc5c4626fcb884976a4f5d4b8644ed087fa178027cc14a64044eb589daf5b62")
    let baseline = try trajectoryRunStepAndEvaluation(
        model: model, optimizer: optimizer, batch: batch1,
        globalStepBefore: 0, captureGradientEvidence: false,
        context: context)
    try trajectoryObserveResourcePhase(
        "post_baseline_step_and_evaluation", context: context)
    let baselineControl = try trajectoryBaselineControl()
    let snapshot = TrajectorySnapshotEvidence(
        weights: baseline.postUpdateParameters,
        firstMoments: baseline.firstMoments,
        secondMoments: baseline.secondMoments,
        control: baselineControl)
    let baselineBinding = try trajectoryPublishCheckpoint(
        role: .baselineCheckpoint, model: model, optimizer: optimizer,
        control: baselineControl, context: context)
    context.baselineBinding = baselineBinding
    try checkedEval(model, optimizer)
    try context.counter.increment("resource_measurement_checked_eval_count")
    try trajectoryObserveResourcePhase(
        "post_baseline_gradient_release_and_baseline_four_leaf_publication",
        context: context)

    let batch2 = try trajectoryMakeBatch(
        stride: 151, offset: 45,
        expectedSHA256:
            "e9ed189a1a8a9204cbc4bcf873e5c8b9c25273b6b9bd2e3c22e9279d1945088e")
    let successor = try trajectoryRunStepAndEvaluation(
        model: model, optimizer: optimizer, batch: batch2,
        globalStepBefore: 1, captureGradientEvidence: true,
        context: context)
    try trajectoryObserveResourcePhase(
        "post_uninterrupted_successor_step_and_evaluation",
        context: context)
    let comparatorControl = try trajectoryComparatorControl(
        branchRole: "uninterrupted_n_plus_1", evidence: successor)
    let comparatorBinding = try trajectoryPublishCheckpoint(
        role: .uninterruptedNPlus1Comparator,
        model: model, optimizer: optimizer, control: comparatorControl,
        context: context)
    context.uninterruptedBinding = comparatorBinding
    try checkedEval(model, optimizer)
    try context.counter.increment("resource_measurement_checked_eval_count")
    try trajectoryObserveResourcePhase(
        "post_uninterrupted_comparator_publication", context: context)
    return .init(snapshot: snapshot, successor: successor)
}

private func trajectoryRunResumedClosure(
    context: TrajectoryScienceContext,
    baselineBinding:
        PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
) throws -> TrajectoryResumedClosure {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    let restored = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1
        .loadAuthoritativeModelAndControl(
            root: context.artifactRoot,
            externalCommitBinding: baselineBinding)
    try context.counter.increment("public_restore_load_count")
    try context.counter.increment("model_allocation_and_materialization_count")
    let expectedBaselineControl = try trajectoryBaselineControl()
    try trajectoryRequire(
        restored.controlState == expectedBaselineControl,
        "restored baseline control bytes")
    restored.model.train(true)
    let neutral = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1
        .loadNeutralMomentCatalog(
            root: context.artifactRoot,
            externalCommitBinding: baselineBinding,
            matching: restored.model)
    try context.counter.increment("deferred_optimizer_moment_load_count")
    let typed = try Execution.typedAdamState(
        from: neutral,
        matching: restored.model.trainableParameters())
    let optimizer = trajectoryMakeAdamW()
    try context.counter.increment("optimizer_allocation_count")
    try optimizer.update(
        parameters: typed,
        matching: restored.model.trainableParameters())
    try context.counter.increment("typed_optimizer_state_import_count")
    try checkedEval(restored.model, optimizer)
    try context.counter.increment("resource_measurement_checked_eval_count")
    let restoredSnapshot = try trajectoryCaptureEvaluationState(
        model: restored.model, optimizer: optimizer,
        control: restored.controlState)
    try trajectoryObserveResourcePhase(
        "post_fresh_weight_moment_and_control_restore", context: context)

    let batch2 = try trajectoryMakeBatch(
        stride: 151, offset: 45,
        expectedSHA256:
            "e9ed189a1a8a9204cbc4bcf873e5c8b9c25273b6b9bd2e3c22e9279d1945088e")
    let successor = try trajectoryRunStepAndEvaluation(
        model: restored.model, optimizer: optimizer, batch: batch2,
        globalStepBefore: 1, captureGradientEvidence: true,
        context: context)
    try trajectoryObserveResourcePhase(
        "post_resumed_successor_step_and_evaluation", context: context)
    let comparatorControl = try trajectoryComparatorControl(
        branchRole: "resumed_n_plus_1", evidence: successor)
    let comparatorBinding = try trajectoryPublishCheckpoint(
        role: .resumedNPlus1Comparator,
        model: restored.model, optimizer: optimizer,
        control: comparatorControl, context: context)
    context.resumedBinding = comparatorBinding
    try checkedEval(restored.model, optimizer)
    try context.counter.increment("resource_measurement_checked_eval_count")
    try trajectoryObserveResourcePhase(
        "post_resumed_comparator_publication", context: context)
    return .init(restoredSnapshot: restoredSnapshot, successor: successor)
}

private func trajectoryExplicitMLXMemoryExhaustion(
    _ error: Error
) -> Bool {
    let signature = String(describing: error).lowercased()
    func containsUnsignedDecimal(
        prefix: String,
        suffix: String
    ) -> Bool {
        guard let prefixRange = signature.range(of: prefix) else {
            return false
        }
        let tail = signature[prefixRange.upperBound...]
        guard let suffixRange = tail.range(of: suffix) else { return false }
        let digits = tail[..<suffixRange.lowerBound]
        return !digits.isEmpty && digits.allSatisfy(\.isNumber)
    }
    return containsUnsignedDecimal(
        prefix: "[metal::malloc] resource limit (",
        suffix: ") exceeded.")
        || containsUnsignedDecimal(
            prefix: "[malloc] unable to allocate ",
            suffix: " bytes.")
}

private func trajectoryPositivePOSIXResourceCode(
    _ error: Error
) -> Int32? {
    if case let TrajectoryExecutionError.posix(_, code) = error,
       code == ENOMEM || code == ENOSPC
    {
        return code
    }
    if let error = error as? POSIXError {
        let code = Int32(error.code.rawValue)
        if code == ENOMEM || code == ENOSPC { return code }
    }
    let nsError = error as NSError
    if nsError.domain == NSPOSIXErrorDomain {
        let code = Int32(nsError.code)
        if code == ENOMEM || code == ENOSPC { return code }
    }
    return nil
}

private func trajectoryPositiveResourceMismatch(
    error: Error,
    context: TrajectoryScienceContext
) -> [String: Any]? {
    if case let TrajectoryExecutionError.classified(
        classification,
        guardID
    ) = error,
       classification == "ABSTAIN_RESOURCE",
       guardID
        == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure",
       let last = context.phases.last,
       let elapsed = trajectoryExactUInt64(
           last["cumulative_elapsed_nanoseconds"]),
       elapsed >= 4_800_000_000_000
    {
        let preimage =
            "timeout_role=worker;deadline_seconds=4800;elapsed_nanoseconds=\(elapsed);contained=true;cleanup_absence=true"
        return [
            "availability": "unavailable", "domain_id": guardID,
            "path": "resource_phases[last].cumulative_elapsed_nanoseconds",
            "expected_binding": NSNull(),
            "observed_binding": PrimeSHA256.hexDigest(
                of: Data(preimage.utf8)),
        ]
    }
    if let code = trajectoryPositivePOSIXResourceCode(error) {
        let guardID = code == ENOMEM
            ? "positively_identified_enomem"
            : "positively_identified_enospc"
        return [
            "availability": "unavailable", "domain_id": guardID,
            "path": "errno", "expected_binding": NSNull(),
            "observed_binding": PrimeSHA256.hexDigest(
                of: Data("errno=\(code)".utf8)),
        ]
    }
    if trajectoryExplicitMLXMemoryExhaustion(error),
       let last = context.phases.last,
       let peak = trajectoryExactUInt64(last["mlx_peak_bytes"]),
       peak >= context.configuredMemoryLimit
    {
        let preimage =
            "configured_memory_limit_bytes=\(context.configuredMemoryLimit);mlx_peak_bytes=\(peak);positively_identified_mlx_memory_limit_exhaustion=true"
        return [
            "availability": "unavailable",
            "domain_id":
                "positively_identified_mlx_memory_limit_exhaustion",
            "path": "resource_phases[last].mlx_peak_bytes",
            "expected_binding": NSNull(),
            "observed_binding": PrimeSHA256.hexDigest(
                of: Data(preimage.utf8)),
        ]
    }
    return nil
}

private func trajectoryExecuteWorker(
    bindings: TrajectoryLauncherBindings,
    workerEpoch: UInt64
) throws -> [String: Any] {
    let observedEnvironment = try trajectoryObservedEnvironment(bindings)
    let metalDevices = MTLCopyAllDevices()
    guard metalDevices.count == 1,
          let defaultMetalDevice = MTLCreateSystemDefaultDevice()
    else {
        throw TrajectoryExecutionError.classified(
            "ABSTAIN_INTEGRITY", "Metal singleton topology")
    }
    let metalDevice = metalDevices[0]
    try trajectoryRequire(
        metalDevice.registryID == defaultMetalDevice.registryID
            && metalDevice.name == defaultMetalDevice.name
            && metalDevice.hasUnifiedMemory
            && metalDevice.maxBufferLength > 0
            && metalDevice.recommendedMaxWorkingSetSize > 0,
        "Metal default unified device")
    let configuredMemoryLimit = min(
        UInt64(17_179_869_184),
        UInt64(metalDevice.recommendedMaxWorkingSetSize))
    try trajectoryRequire(
        configuredMemoryLimit <= UInt64(Int.max),
        "configured MLX memory-limit conversion")
    let artifactRoot = try PrimeArtifactRoot(
        directoryURL: URL(fileURLWithPath: bindings.artifactRoot))
    try PrimeNativeDecoderNative300MTrajectoryCheckpointV1
        .beginEphemeralRun(root: artifactRoot)
    let executionDevice = Device(.gpu, index: Int32(0))
    return try Device.withDefaultDevice(executionDevice) {
        try trajectoryRequire(
            executionDevice.deviceType == .gpu
                && Device.defaultDevice() === executionDevice
                && Stream() == Stream.gpu,
            "MLX GPU/default-stream identity")
        MLX.Memory.memoryLimit = Int(configuredMemoryLimit)
        MLX.Memory.cacheLimit = 0
        try trajectoryRequire(
            MLX.Memory.memoryLimit >= 0
                && UInt64(MLX.Memory.memoryLimit) == configuredMemoryLimit
                && MLX.Memory.cacheLimit == 0,
            "MLX configured limit readback")
        MLX.Memory.peakMemory = 0
        let context = TrajectoryScienceContext(
            bindings: bindings, epoch: workerEpoch,
            metalDevice: metalDevice,
            configuredMemoryLimit: configuredMemoryLimit,
            artifactRoot: artifactRoot)
        do {
            try trajectoryObserveResourcePhase("preflight", context: context)
        } catch {
            guard context.phases.count == 1,
                  let available = trajectoryExactUInt64(
                    context.phases[0]["filesystem_available_bytes"])
            else { throw error }
            let mismatch: [String: Any]?
            if configuredMemoryLimit < 4_337_713_152 {
                mismatch = [
                    "availability": "unavailable",
                    "domain_id": "memory_limit_below_minimum_floor",
                    "path": "device_and_stream.configured_memory_limit_bytes",
                    "expected_binding": PrimeSHA256.hexDigest(of: Data(
                        "minimum_memory_limit_floor_bytes=4337713152".utf8)),
                    "observed_binding": PrimeSHA256.hexDigest(of: Data(
                        "configured_memory_limit_bytes=\(configuredMemoryLimit)"
                            .utf8)),
                ]
            } else if available < 12_884_901_888 {
                mismatch = [
                    "availability": "unavailable",
                    "domain_id":
                        "filesystem_available_below_three_set_floor",
                    "path": "resource_phases[0].filesystem_available_bytes",
                    "expected_binding": PrimeSHA256.hexDigest(of: Data(
                        "available_filesystem_floor_bytes=12884901888".utf8)),
                    "observed_binding": PrimeSHA256.hexDigest(of: Data(
                        "filesystem_available_bytes=\(available)".utf8)),
                ]
            } else {
                mismatch = trajectoryPositiveResourceMismatch(
                    error: error, context: context)
            }
            guard let mismatch else { throw error }
            try artifactRoot.requireEmpty()
            let postflightEqual = trajectoryPostflightIdentityEqual(
                metalDevice: metalDevice, executionDevice: executionDevice,
                configuredMemoryLimit: configuredMemoryLimit)
            try trajectoryRequire(
                postflightEqual,
                "preflight-timeout device post-observation")
            return try trajectoryCandidate(
                bindings: bindings, environment: observedEnvironment,
                device: trajectoryDeviceDictionary(
                    metalDevice: metalDevice,
                    configuredMemoryLimit: configuredMemoryLimit,
                    prePostEqual: postflightEqual),
                context: context, status: "ABSTAIN_RESOURCE",
                mismatch: mismatch,
                cleanup: trajectoryEmptyCleanupDictionary())
        }
        let earlyPostflightEqual = trajectoryPostflightIdentityEqual(
            metalDevice: metalDevice, executionDevice: executionDevice,
            configuredMemoryLimit: configuredMemoryLimit)
        try trajectoryRequire(
            earlyPostflightEqual,
            "preflight resource-outcome device post-observation")
        let provisionalDevice = trajectoryDeviceDictionary(
            metalDevice: metalDevice,
            configuredMemoryLimit: configuredMemoryLimit,
            prePostEqual: earlyPostflightEqual)
        if configuredMemoryLimit < 4_337_713_152 {
            let observed = PrimeSHA256.hexDigest(of: Data(
                "configured_memory_limit_bytes=\(configuredMemoryLimit)".utf8))
            return try trajectoryCandidate(
                bindings: bindings, environment: observedEnvironment,
                device: provisionalDevice, context: context,
                status: "ABSTAIN_RESOURCE",
                mismatch: [
                    "availability": "unavailable",
                    "domain_id": "memory_limit_below_minimum_floor",
                    "path": "device_and_stream.configured_memory_limit_bytes",
                    "expected_binding": PrimeSHA256.hexDigest(of: Data(
                        "minimum_memory_limit_floor_bytes=4337713152".utf8)),
                    "observed_binding": observed,
                ], cleanup: trajectoryEmptyCleanupDictionary())
        }
        let filesystemAvailable = trajectoryExactUInt64(
            context.phases[0]["filesystem_available_bytes"])!
        if filesystemAvailable < 12_884_901_888 {
            let observed = PrimeSHA256.hexDigest(of: Data(
                "filesystem_available_bytes=\(filesystemAvailable)".utf8))
            return try trajectoryCandidate(
                bindings: bindings, environment: observedEnvironment,
                device: provisionalDevice, context: context,
                status: "ABSTAIN_RESOURCE",
                mismatch: [
                    "availability": "unavailable",
                    "domain_id":
                        "filesystem_available_below_three_set_floor",
                    "path": "resource_phases[0].filesystem_available_bytes",
                    "expected_binding": PrimeSHA256.hexDigest(of: Data(
                        "available_filesystem_floor_bytes=12884901888".utf8)),
                    "observed_binding": observed,
                ], cleanup: trajectoryEmptyCleanupDictionary())
        }

        do {
            let uninterrupted = try trajectoryRunUninterruptedClosure(
                context: context)
            guard let baselineBinding = context.baselineBinding,
                  let uninterruptedBinding = context.uninterruptedBinding
            else {
                throw TrajectoryExecutionError.contract(
                    "uninterrupted publication bindings")
            }
            // This lexical boundary destroys the uninterrupted model and
            // optimizer before the cache clear and before any restore load.
            MLX.Memory.clearCache()
            try trajectoryObserveResourcePhase(
                "post_uninterrupted_state_deallocation_and_cache_clear",
                context: context)
            let resumed = try trajectoryRunResumedClosure(
                context: context, baselineBinding: baselineBinding)
            guard let resumedBinding = context.resumedBinding else {
                throw TrajectoryExecutionError.contract(
                    "resumed publication binding")
            }
            // The resumed model, optimizer, and deferred moments have left
            // their lexical scope before the second cache clear.  Only host
            // digests and the small loss/evaluation bytes remain.
            MLX.Memory.clearCache()
            let streamed = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                .comparePrivateComparatorsStreaming(
                    root: artifactRoot,
                    uninterrupted: uninterruptedBinding,
                    resumed: resumedBinding)
            context.comparisonDomains = try trajectoryBuildCompleteComparisons(
                snapshot: uninterrupted.snapshot,
                restoredSnapshot: resumed.restoredSnapshot,
                uninterrupted: uninterrupted.successor,
                resumed: resumed.successor,
                streamed: streamed)
            let cleanup = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                .cleanupKnownPublishedSets(
                    root: artifactRoot,
                    bindings: [
                        baselineBinding, uninterruptedBinding, resumedBinding,
                    ],
                    quarantines: context.quarantines)
            context.cleanupEvidence = cleanup
            try trajectoryObserveResourcePhase(
                "post_streaming_compare_artifact_cleanup_and_absence",
                context: context)
            let postflightEqual = trajectoryPostflightIdentityEqual(
                metalDevice: metalDevice, executionDevice: executionDevice,
                configuredMemoryLimit: configuredMemoryLimit)
            try trajectoryRequire(postflightEqual, "postflight identity")
            try trajectoryObserveResourcePhase("postflight", context: context)
            try context.counter.requireComplete()
            let firstFailure = context.comparisonDomains.first {
                trajectoryExactBool($0["exact"]) == false
            }
            let status = firstFailure == nil
                ? "PASS_EXACT" : "MEASURED_EXACT_MISMATCH"
            let mismatch: [String: Any]
            if let firstFailure {
                mismatch = [
                    "availability": "available",
                    "domain_id": firstFailure["domain_id"] as Any,
                    "path": firstFailure["first_mismatch_path"] as Any,
                    "expected_binding": firstFailure[
                        "first_mismatch_expected_binding"] as Any,
                    "observed_binding": firstFailure[
                        "first_mismatch_observed_binding"] as Any,
                ]
            } else {
                mismatch = [
                    "availability": "not_applicable", "domain_id": NSNull(),
                    "path": NSNull(), "expected_binding": NSNull(),
                    "observed_binding": NSNull(),
                ]
            }
            return try trajectoryCandidate(
                bindings: bindings, environment: observedEnvironment,
                device: trajectoryDeviceDictionary(
                    metalDevice: metalDevice,
                    configuredMemoryLimit: configuredMemoryLimit,
                    prePostEqual: postflightEqual),
                context: context, status: status, mismatch: mismatch,
                cleanup: trajectoryCleanupDictionary(cleanup))
        } catch {
            let originalError = error
            let publishedBindings = [
                context.baselineBinding,
                context.uninterruptedBinding,
                context.resumedBinding,
            ].compactMap { $0 } + context.cleanupOnlyCommittedBindings
            let cleanup: [String: Any]
            if let cleanupEvidence = context.cleanupEvidence {
                try artifactRoot.requireEmpty()
                cleanup = trajectoryCleanupDictionary(cleanupEvidence)
            } else if !publishedBindings.isEmpty || !context.quarantines.isEmpty {
                let cleanupEvidence = try
                    PrimeNativeDecoderNative300MTrajectoryCheckpointV1
                    .cleanupKnownPublishedSets(
                        root: artifactRoot, bindings: publishedBindings,
                        quarantines: context.quarantines)
                cleanup = trajectoryCleanupDictionary(cleanupEvidence)
            } else {
                try artifactRoot.requireEmpty()
                cleanup = trajectoryEmptyCleanupDictionary()
            }
            if let integrity = originalError
                as? TrajectorySafeIntegrityPrefixError
            {
                context.comparisonDomains = integrity.domains
                // A safe comparator/topology integrity outcome still closes
                // the full cleanup and postflight resource sequence.  If the
                // 4,800-second science cutoff is crossed while recording these
                // final observations, the already-established topology failure
                // remains the primary INTEGRITY outcome; both phase records are
                // nevertheless retained truthfully.
                func observeIntegrityClosurePhase(_ phase: String) throws {
                    do {
                        try trajectoryObserveResourcePhase(
                            phase, context: context)
                    } catch {
                        guard trajectoryPositiveResourceMismatch(
                            error: error, context: context)?["domain_id"]
                            as? String
                            == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure"
                        else { throw error }
                    }
                }
                try trajectoryRequire(
                    context.phases.count == 10,
                    "integrity cleanup phase boundary")
                try observeIntegrityClosurePhase(
                    "post_streaming_compare_artifact_cleanup_and_absence")
                let postflightEqual = trajectoryPostflightIdentityEqual(
                    metalDevice: metalDevice,
                    executionDevice: executionDevice,
                    configuredMemoryLimit: configuredMemoryLimit)
                try trajectoryRequire(
                    postflightEqual,
                    "integrity-outcome device post-observation")
                try observeIntegrityClosurePhase("postflight")
                try context.counter.requireComplete()
                return try trajectoryCandidate(
                    bindings: bindings,
                    environment: observedEnvironment,
                    device: trajectoryDeviceDictionary(
                        metalDevice: metalDevice,
                        configuredMemoryLimit: configuredMemoryLimit,
                        prePostEqual: postflightEqual),
                    context: context,
                    status: "ABSTAIN_INTEGRITY",
                    mismatch: integrity.mismatch,
                    cleanup: cleanup)
            }
            guard context.phases.count >= 1,
                  context.phases.count <= 12,
                  let mismatch = trajectoryPositiveResourceMismatch(
                    error: originalError, context: context)
            else {
                throw originalError
            }
            let safeTimeout = mismatch["domain_id"] as? String
                == "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure"
            try trajectoryRequire(
                safeTimeout
                    || (context.phases.count < 12
                        && context.comparisonDomains.count < 18),
                "late resource outcome is timeout-only")
            let postflightEqual = trajectoryPostflightIdentityEqual(
                metalDevice: metalDevice, executionDevice: executionDevice,
                configuredMemoryLimit: configuredMemoryLimit)
            try trajectoryRequire(
                postflightEqual,
                "resource-outcome device post-observation")
            return try trajectoryCandidate(
                bindings: bindings, environment: observedEnvironment,
                device: trajectoryDeviceDictionary(
                    metalDevice: metalDevice,
                    configuredMemoryLimit: configuredMemoryLimit,
                    prePostEqual: postflightEqual),
                context: context, status: "ABSTAIN_RESOURCE",
                mismatch: mismatch, cleanup: cleanup)
        }
    }
}

private func trajectoryRunWorkerProcess(workerEpoch: UInt64) -> Never {
    typealias Execution =
        PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
    do {
        let workerClosureDeadline = try trajectoryDeadline(
            from: workerEpoch,
            afterSeconds: Execution.supervisorTimeoutSeconds)
        let bindings = try TrajectoryLauncherBindings(
            environment: ProcessInfo.processInfo.environment)
        let candidate = try trajectoryExecuteWorker(
            bindings: bindings, workerEpoch: workerEpoch)
        try trajectoryRequireBeforeDeadline(
            workerClosureDeadline,
            "worker candidate construction")
        let data = try trajectoryCanonicalJSONData(candidate)
        try trajectoryRequireBeforeDeadline(
            workerClosureDeadline,
            "worker candidate canonicalization")
        _ = try trajectoryWriteFrame(
            data,
            maximumByteCount:
                Execution.maximumPrivateCandidateCanonicalByteCount,
            descriptor: Execution.workerFrameDescriptor,
            absoluteDeadline: workerClosureDeadline)
        _ = Darwin.close(Execution.workerFrameDescriptor)
        _exit(0)
    } catch {
        _ = Darwin.close(Execution.workerFrameDescriptor)
        _exit(71)
    }
}

// MARK: - Current-local, retained, three-process science

private struct CurrentLocalTrajectoryBaseline: Codable {
    let schema: String
    let status: String
    let scienceStartedAt: UInt64
    let completedAt: UInt64
    let workerPID: Int32
    let baseline: PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    let uninterrupted: PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    let evidence: TrajectoryUninterruptedClosure
    let scientificOperationCounts: [String: UInt64]
    let resourcePhases: Data
    let device: Data
    let artifactRootIdentity: Data
}

private struct CurrentLocalTrajectoryResult: Codable {
    let schema: String
    let status: String
    let baselineRun: CurrentLocalTrajectoryBaseline
    let resumed: PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
    let resumeWorkerPID: Int32
    let resumeWorkerStartedAt: UInt64
    let completedAt: UInt64
    let comparisonDomains: Data
    let scientificOperationCounts: [String: UInt64]
    let resourcePhases: Data
    let device: Data
    let artifactRootIdentity: Data
    // The embedded V2 source hash is a historical compatibility identity.
    // Current source/image identities are observed by the local controller.
    let compatibilityIdentityScope: String
}

private let currentLocalTrajectoryPhaseNames: [String] = {
    var names = PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.phaseNames
    names[10] = "post_streaming_compare_retained_artifact_verification"
    return names
}()

private func currentLocalRootIdentity(_ root: PrimeArtifactRoot) throws -> Data {
    let value = try root.verifiedRootIdentity()
    return try trajectoryCanonicalJSONData([
        "device_id": value.deviceID, "inode": value.inode,
        "owner_uid": value.ownerUserID, "owner_gid": value.ownerGroupID,
        "mode": value.actualMode, "link_count": value.linkCount,
        "mtime_seconds": value.modificationSeconds, "mtime_nanoseconds": value.modificationNanoseconds,
        "ctime_seconds": value.statusChangeSeconds, "ctime_nanoseconds": value.statusChangeNanoseconds,
    ])
}

private func currentLocalDeadline(_ epoch: UInt64, lease: PrimeMetalDeviceLease) throws {
    let now = DispatchTime.now().uptimeNanoseconds
    try trajectoryRequire(epoch > 0 && now >= epoch && now - epoch < 4_800_000_000_000,
        "current local science deadline")
    try trajectoryRequire(lease.isHeld, "current local science retained lease")
}

private func currentLocalEncode<T: Encodable>(_ value: T) throws -> Data {
    let data = try PrimeCanonicalJSON.encode(value)
    try trajectoryRequire(data.count <= PrimeNativeDecoderCurrentLocalNative300MExecution.maximumResultByteCount,
        "current local result size")
    return data
}

private func currentLocalDecode<T: Codable>(_ type: T.Type, _ data: Data) throws -> T {
    try trajectoryRequire(!data.isEmpty && data.count <= PrimeNativeDecoderCurrentLocalNative300MExecution.maximumResultByteCount,
        "current local input size")
    return try PrimeCanonicalJSON.decode(type, from: data)
}

private func currentLocalValidateBaseline(_ value: CurrentLocalTrajectoryBaseline) throws {
    try trajectoryRequire(value.schema == "prime_current_local_native300m_baseline_v1"
        && value.status == "UNINTERRUPTED_RETAINED"
        && value.workerPID > 0 && value.scienceStartedAt > 0
        && value.completedAt > value.scienceStartedAt
        && value.completedAt - value.scienceStartedAt < 4_800_000_000_000
        && value.baseline.setRole == .baselineCheckpoint
        && value.uninterrupted.setRole == .uninterruptedNPlus1Comparator
        && value.evidence.snapshot.weights.totalElementCount == 271_107_072
        && value.evidence.snapshot.weights.paths.count == 218
        && value.evidence.snapshot.firstMoments.totalElementCount == 271_107_072
        && value.evidence.snapshot.secondMoments.totalElementCount == 271_107_072,
        "current local baseline identity")
    try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.validateExternalBinding(value.baseline)
    try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.validateExternalBinding(value.uninterrupted)
    try currentLocalRequireBaselineControl(value.evidence.snapshot.control)
    let phases = try trajectoryCanonicalJSONObject(value.resourcePhases) as? [[String: Any]]
    try trajectoryRequire(phases?.compactMap { $0["phase_id"] as? String }
        == Array(currentLocalTrajectoryPhaseNames.prefix(7)), "current local baseline phase prefix")
    _ = try TrajectoryOperationCounter(scientificValues: value.scientificOperationCounts)
    _ = try trajectoryCanonicalJSONObject(value.device)
    _ = try trajectoryCanonicalJSONObject(value.artifactRootIdentity)
}

private func currentLocalValidateResult(_ value: CurrentLocalTrajectoryResult) throws {
    try currentLocalValidateBaseline(value.baselineRun)
    try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.validateExternalBinding(value.resumed)
    let domains = try trajectoryCanonicalJSONObject(value.comparisonDomains) as? [[String: Any]]
    let phases = try trajectoryCanonicalJSONObject(value.resourcePhases) as? [[String: Any]]
    let counts = try TrajectoryOperationCounter(scientificValues: value.scientificOperationCounts)
    try counts.requireComplete()
    try trajectoryRequire(value.schema == "prime_current_local_native300m_stage7_result_v1"
        && ["PASS_EXACT", "MEASURED_EXACT_MISMATCH"].contains(value.status)
        && value.resumeWorkerPID > 0 && value.resumeWorkerPID != value.baselineRun.workerPID
        && value.resumeWorkerStartedAt >= value.baselineRun.completedAt
        && value.completedAt > value.resumeWorkerStartedAt
        && value.completedAt - value.baselineRun.scienceStartedAt < 4_800_000_000_000
        && value.resumed.setRole == .resumedNPlus1Comparator
        && value.device == value.baselineRun.device
        && value.compatibilityIdentityScope == "historical_v2_compatibility_only_current_source_bound_by_controller"
        && domains?.compactMap { $0["domain_id"] as? String }
            == PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.comparisonDomainIDs
        && phases?.compactMap { $0["phase_id"] as? String } == currentLocalTrajectoryPhaseNames,
        "current local complete stage7 identity")
    guard let domains else { throw TrajectoryExecutionError.contract("current local domains") }
    for (index, domain) in domains.enumerated() {
        try trajectoryRequire(trajectoryValidMeasuredComparisonDomain(domain, index: index),
            "current local complete comparison domain")
    }
    try trajectoryRequire((value.status == "PASS_EXACT") == domains.allSatisfy { trajectoryExactBool($0["exact"]) == true },
        "current local comparison disposition")
    _ = try trajectoryCanonicalJSONObject(value.artifactRootIdentity)
}

private func currentLocalWithDevice<T>(
    lease: PrimeMetalDeviceLease, epoch: UInt64,
    body: (any MTLDevice, Device, UInt64) throws -> T
) throws -> T {
    try currentLocalDeadline(epoch, lease: lease)
    try trajectoryRequire(ProcessInfo.processInfo.environment["MLX_ENABLE_TF32"] == "0",
        "current local TF32 disabled")
    let devices = MTLCopyAllDevices()
    guard devices.count == 1, let metal = devices.first, let originalDefault = MTLCreateSystemDefaultDevice() else {
        throw TrajectoryExecutionError.contract("current local singleton Metal topology")
    }
    try trajectoryRequire(metal.registryID == originalDefault.registryID
        && metal.name == originalDefault.name && metal.hasUnifiedMemory
        && metal.maxBufferLength > 0 && metal.recommendedMaxWorkingSetSize > 0,
        "current local default unified Metal device")
    let limit = min(UInt64(17_179_869_184), UInt64(metal.recommendedMaxWorkingSetSize))
    try trajectoryRequire(limit >= 4_337_713_152 && limit <= UInt64(Int.max),
        "current local native300m memory floor")
    let execution = Device(.gpu, index: 0)
    return try Device.withDefaultDevice(execution) {
        MLX.Memory.memoryLimit = Int(limit)
        MLX.Memory.cacheLimit = 0
        MLX.Memory.peakMemory = 0
        try trajectoryRequire(trajectoryPostflightIdentityEqual(metalDevice: metal,
            executionDevice: execution, configuredMemoryLimit: limit), "current local GPU policy")
        let result = try body(metal, execution, limit)
        try trajectoryRequire(trajectoryPostflightIdentityEqual(metalDevice: metal,
            executionDevice: execution, configuredMemoryLimit: limit), "current local GPU policy postflight")
        try currentLocalDeadline(epoch, lease: lease)
        return result
    }
}

public extension PrimeNativeDecoderCurrentLocalNative300MExecution {
    /// Support check only: exercises the actual host-evidence codec and
    /// comparison/control guards without allocating any MLX model or tensor.
    static func validatePureContractV1() throws {
        let bytes = Data([0, 0, 128, 63, 1, 0, 192, 127])
        let digest = PrimeSHA256.hexDigest(of: bytes)
        let path = TrajectoryPathDigest(path: "serialization_fixture", shape: [1, 2], dtype: "float32",
            elementCount: 2, logicalByteCount: 8, logicalSHA256: digest, retainedLogicalBytes: bytes)
        let catalog = TrajectoryCatalogDigest(paths: [path], structuralSHA256: digest,
            logicalSHA256: digest, totalElementCount: 2, totalLogicalByteCount: 8)
        let control = try trajectoryBaselineControl()
        let snapshot = TrajectorySnapshotEvidence(weights: catalog, firstMoments: catalog,
            secondMoments: catalog, control: control)
        let step = TrajectoryStepEvidence(lossBits: 0x7fc00001, perTargetLoss: catalog, wholeLogits: catalog,
            rawGradients: catalog, clippedGradients: catalog, rawNormBits: UInt32.max,
            clippedNormBits: 0x80000000, clipScaleBits: 0x3f800000,
            postUpdateParameters: catalog, firstMoments: catalog, secondMoments: catalog,
            evaluationPerTargetLoss: catalog, evaluationWholeLogits: catalog,
            evaluationBinding: Data("{}".utf8), evaluationReadOnlyBinding: Data("{}".utf8), batchBinding: Data("{}".utf8))
        let original = TrajectoryUninterruptedClosure(snapshot: snapshot, successor: step)
        let encoded = try currentLocalEncode(original)
        let decoded = try currentLocalDecode(TrajectoryUninterruptedClosure.self, encoded)
        try trajectoryRequire(decoded == original, "current local host evidence exact codec roundtrip")
        try currentLocalRequireBaselineControl(decoded.snapshot.control)
        var wrongControl = try trajectoryJSONObjectDictionary(control, scope: "pure baseline control")
        wrongControl["global_step"] = 2
        let changedControl = try trajectoryCanonicalJSONData(wrongControl)
        var rejected = false
        do { try currentLocalRequireBaselineControl(changedControl) } catch { rejected = true }
        try trajectoryRequire(rejected, "current local changed control rejected")
        let left = try trajectoryMemberComparisonValue(object: ["raw_norm_float32_bits": UInt32(0x3f800000)],
            orderedPaths: ["raw_norm_float32_bits"])
        let right = try trajectoryMemberComparisonValue(object: ["raw_norm_float32_bits": UInt32(0x40000000)],
            orderedPaths: ["raw_norm_float32_bits"])
        let exact = try trajectoryComparisonResult(index: 8, left: left, right: left)
        let mismatch = try trajectoryComparisonResult(index: 8, left: left, right: right)
        try trajectoryRequire(trajectoryValidMeasuredComparisonDomain(exact, index: 8)
            && trajectoryExactBool(exact["exact"]) == true
            && trajectoryValidMeasuredComparisonDomain(mismatch, index: 8)
            && trajectoryExactBool(mismatch["exact"]) == false,
            "current local actual comparison accepts exact and records changed bits")
        var falsePass = mismatch
        falsePass["exact"] = true
        try trajectoryRequire(!trajectoryValidMeasuredComparisonDomain(falsePass, index: 8),
            "current local comparison false exact rejected")
        var wrongDomain = exact
        wrongDomain["domain_id"] = "snapshot_weights"
        try trajectoryRequire(!trajectoryValidMeasuredComparisonDomain(wrongDomain, index: 8),
            "current local wrong comparison domain rejected")
        rejected = false
        do { _ = try currentLocalDecode(TrajectoryUninterruptedClosure.self, encoded + Data([10])) } catch { rejected = true }
        try trajectoryRequire(rejected, "current local noncanonical host evidence rejected")
    }

    /// First worker: initial model, baseline update/checkpoint, uninterrupted
    /// successor and host-only comparison evidence. Nothing is deleted.
    static func runStage7Baseline(
        artifactRoot: PrimeArtifactRoot, lease: PrimeMetalDeviceLease,
        workerEpochNanoseconds: UInt64, recordProgress: @escaping (Data) throws -> Void
    ) throws -> Data {
        try artifactRoot.requirePrivateRootMode()
        try artifactRoot.requireEmpty()
        return try currentLocalWithDevice(lease: lease, epoch: workerEpochNanoseconds) { metal, device, limit in
            let context = TrajectoryScienceContext(epoch: workerEpochNanoseconds,
                metalDevice: metal, configuredMemoryLimit: limit, artifactRoot: artifactRoot,
                phaseNames: currentLocalTrajectoryPhaseNames, currentLocalLease: lease,
                recordProgress: recordProgress)
            try trajectoryObserveResourcePhase("preflight", context: context)
            try trajectoryRequire((trajectoryExactUInt64(context.phases[0]["filesystem_available_bytes"]) ?? 0) >= 12_884_901_888,
                "current local three-set filesystem floor")
            let evidence = try trajectoryRunUninterruptedClosure(context: context)
            guard let baseline = context.baselineBinding, let uninterrupted = context.uninterruptedBinding else {
                throw TrajectoryExecutionError.contract("current local baseline publications")
            }
            // Both model and optimizer left the original lexical kernel.
            MLX.Memory.clearCache()
            try trajectoryObserveResourcePhase("post_uninterrupted_state_deallocation_and_cache_clear", context: context)
            let retained = try PrimeCurrentLocalNative300MRetainedInventory(root: artifactRoot, bindings: [baseline, uninterrupted])
            try retained.revalidate()
            let value = CurrentLocalTrajectoryBaseline(schema: "prime_current_local_native300m_baseline_v1",
                status: "UNINTERRUPTED_RETAINED", scienceStartedAt: workerEpochNanoseconds,
                completedAt: DispatchTime.now().uptimeNanoseconds, workerPID: getpid(),
                baseline: baseline, uninterrupted: uninterrupted, evidence: evidence,
                scientificOperationCounts: context.counter.scientificValues,
                resourcePhases: try trajectoryCanonicalJSONData(context.phases),
                device: try trajectoryCanonicalJSONData(trajectoryDeviceDictionary(metalDevice: metal,
                    configuredMemoryLimit: limit, prePostEqual: true)),
                artifactRootIdentity: try currentLocalRootIdentity(artifactRoot))
            try currentLocalValidateBaseline(value)
            try currentLocalDeadline(workerEpochNanoseconds, lease: lease)
            return try currentLocalEncode(value)
        }
    }

    /// Second, distinct OS worker: reload the real baseline weights/control,
    /// import real typed Adam moments, execute batch2, and compare all18 domains.
    static func runStage7Resume(
        artifactRoot: PrimeArtifactRoot, intermediateResult: Data,
        lease: PrimeMetalDeviceLease, workerEpochNanoseconds: UInt64,
        recordProgress: @escaping (Data) throws -> Void
    ) throws -> Data {
        let previous = try currentLocalDecode(CurrentLocalTrajectoryBaseline.self, intermediateResult)
        try currentLocalValidateBaseline(previous)
        try trajectoryRequire(getpid() != previous.workerPID
            && workerEpochNanoseconds >= previous.completedAt
            && workerEpochNanoseconds <= DispatchTime.now().uptimeNanoseconds,
            "current local fresh resume process")
        let initialRootIdentity = try currentLocalRootIdentity(artifactRoot)
        try trajectoryRequire(initialRootIdentity == previous.artifactRootIdentity,
            "current local baseline root continuity")
        return try currentLocalWithDevice(lease: lease, epoch: previous.scienceStartedAt) { metal, device, limit in
            let observedDevice = try trajectoryCanonicalJSONData(trajectoryDeviceDictionary(metalDevice: metal,
                configuredMemoryLimit: limit, prePostEqual: true))
            try trajectoryRequire(observedDevice == previous.device, "current local cross-process device equality")
            do {
                let held = try PrimeCurrentLocalNative300MRetainedInventory(root: artifactRoot,
                    bindings: [previous.baseline, previous.uninterrupted])
                try held.revalidate()
            }
            let context = TrajectoryScienceContext(epoch: previous.scienceStartedAt,
                metalDevice: metal, configuredMemoryLimit: limit, artifactRoot: artifactRoot,
                counter: try .init(scientificValues: previous.scientificOperationCounts),
                phaseNames: currentLocalTrajectoryPhaseNames, currentLocalLease: lease,
                recordProgress: recordProgress)
            guard let priorPhases = try trajectoryCanonicalJSONObject(previous.resourcePhases) as? [[String: Any]] else {
                throw TrajectoryExecutionError.contract("current local prior resource phases")
            }
            context.phases = priorPhases
            context.baselineBinding = previous.baseline
            context.uninterruptedBinding = previous.uninterrupted
            try currentLocalDeadline(previous.scienceStartedAt, lease: lease)
            let resumed = try trajectoryRunResumedClosure(context: context, baselineBinding: previous.baseline)
            guard let resumedBinding = context.resumedBinding else {
                throw TrajectoryExecutionError.contract("current local resumed publication")
            }
            MLX.Memory.clearCache()
            let streamed = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.comparePrivateComparatorsStreaming(
                root: artifactRoot, uninterrupted: previous.uninterrupted, resumed: resumedBinding)
            let domains = try trajectoryBuildCompleteComparisons(snapshot: previous.evidence.snapshot,
                restoredSnapshot: resumed.restoredSnapshot, uninterrupted: previous.evidence.successor,
                resumed: resumed.successor, streamed: streamed)
            let retained = try PrimeCurrentLocalNative300MRetainedInventory(root: artifactRoot,
                bindings: [previous.baseline, previous.uninterrupted, resumedBinding])
            try retained.revalidate()
            try trajectoryObserveResourcePhase(currentLocalTrajectoryPhaseNames[10], context: context)
            try trajectoryObserveResourcePhase("postflight", context: context)
            try context.counter.requireComplete()
            let value = CurrentLocalTrajectoryResult(schema: "prime_current_local_native300m_stage7_result_v1",
                status: domains.allSatisfy { trajectoryExactBool($0["exact"]) == true } ? "PASS_EXACT" : "MEASURED_EXACT_MISMATCH",
                baselineRun: previous, resumed: resumedBinding, resumeWorkerPID: getpid(),
                resumeWorkerStartedAt: workerEpochNanoseconds, completedAt: DispatchTime.now().uptimeNanoseconds,
                comparisonDomains: try trajectoryCanonicalJSONData(domains),
                scientificOperationCounts: context.counter.scientificValues,
                resourcePhases: try trajectoryCanonicalJSONData(context.phases), device: observedDevice,
                artifactRootIdentity: try currentLocalRootIdentity(artifactRoot),
                compatibilityIdentityScope: "historical_v2_compatibility_only_current_source_bound_by_controller")
            try currentLocalValidateResult(value)
            try currentLocalDeadline(previous.scienceStartedAt, lease: lease)
            return try currentLocalEncode(value)
        }
    }

    static func stage7Status(in data: Data) throws -> String {
        let result = try currentLocalDecode(CurrentLocalTrajectoryResult.self, data)
        try currentLocalValidateResult(result)
        return result.status
    }

    /// Descriptor-free expected values only. The controller must verify each
    /// binding against its retained native artifact root before publication.
    static func retainedArtifactBindings(in data: Data) throws -> [PrimeArtifactBinding] {
        let result = try currentLocalDecode(CurrentLocalTrajectoryResult.self, data)
        try currentLocalValidateResult(result)
        return [result.baselineRun.baseline, result.baselineRun.uninterrupted, result.resumed]
            .flatMap { $0.orderedLeafBindings.map(\.artifact) }
    }

    static func baselineStatus(in data: Data) throws -> String {
        let result = try currentLocalDecode(CurrentLocalTrajectoryBaseline.self, data)
        try currentLocalValidateBaseline(result)
        return result.status
    }

    static func stage8Status(in data: Data) throws -> String {
        try trajectoryRequire(!data.isEmpty && data.count <= maximumResultByteCount,
            "current local stage8 result size")
        guard let value = try trajectoryCanonicalJSONObject(data) as? [String: Any],
              Set(value.keys) == ["schema", "status", "worker_pid", "worker_started_at", "completed_at",
                "stage7_result_byte_count", "stage7_result_sha256", "actual_model_parameter_count",
                "model_weights_exact", "typed_adam_first_moments_exact", "typed_adam_second_moments_exact",
                "canonical_control_exact", "retained_leaf_count", "retained_set_count",
                "retained_artifacts_deleted", "additional_training_steps", "resource_phases", "device", "artifact_root_identity"],
              value["schema"] as? String == "prime_current_local_native300m_stage8_retained_verification_v1",
              value["status"] as? String == "PASS_RETAINED_RELOAD_EXACT",
              let pid = trajectoryExactUInt64(value["worker_pid"]), pid > 0,
              let start = trajectoryExactUInt64(value["worker_started_at"]), start > 0,
              let end = trajectoryExactUInt64(value["completed_at"]), end > start,
              end - start < 4_800_000_000_000,
              let size = trajectoryExactUInt64(value["stage7_result_byte_count"]), size > 0, size <= maximumResultByteCount,
              let hash = value["stage7_result_sha256"] as? String, trajectoryIsLowerHex(hash, count: 64),
              trajectoryExactUInt64(value["actual_model_parameter_count"]) == parameterCount,
              trajectoryExactUInt64(value["retained_leaf_count"]) == 12,
              trajectoryExactUInt64(value["retained_set_count"]) == 3,
              trajectoryExactUInt64(value["additional_training_steps"]) == 0,
              trajectoryExactBool(value["retained_artifacts_deleted"]) == false,
              ["model_weights_exact", "typed_adam_first_moments_exact", "typed_adam_second_moments_exact", "canonical_control_exact"]
                .allSatisfy({ trajectoryExactBool(value[$0]) == true }),
              let phases = value["resource_phases"] as? [[String: Any]],
              phases.compactMap({ $0["phase_id"] as? String }) == ["stage8_preflight", "stage8_post_model_adam_control_reload",
                "stage8_post_retained_comparator_verification", "stage8_postflight"],
              let device = value["device"] as? [String: Any],
              trajectoryValidCandidateDevice(device),
              let identity = value["artifact_root_identity"] as? [String: Any],
              trajectoryExactUInt64(identity["inode"]) != nil else {
            throw TrajectoryExecutionError.contract("current local stage8 result identity")
        }
        return "PASS_RETAINED_RELOAD_EXACT"
    }

    /// Third OS worker: actual retained baseline model/control/moment reload,
    /// typed Adam import, original snapshot equality, all12 file hashes and
    /// the three persisted successor tensor domains. It runs no extra training.
    static func verifyRetainedStage7(
        artifactRoot: PrimeArtifactRoot, stage7Result: Data,
        lease: PrimeMetalDeviceLease, workerEpochNanoseconds: UInt64,
        recordProgress: @escaping (Data) throws -> Void
    ) throws -> Data {
        let prior = try currentLocalDecode(CurrentLocalTrajectoryResult.self, stage7Result)
        try currentLocalValidateResult(prior)
        try trajectoryRequire(prior.status == "PASS_EXACT"
            && getpid() != prior.resumeWorkerPID && getpid() != prior.baselineRun.workerPID
            && workerEpochNanoseconds >= prior.completedAt
            && workerEpochNanoseconds <= DispatchTime.now().uptimeNanoseconds,
            "current local retained verification requires exact prior and fresh process")
        let initialRootIdentity = try currentLocalRootIdentity(artifactRoot)
        try trajectoryRequire(initialRootIdentity == prior.artifactRootIdentity,
            "current local retained root continuity")
        return try currentLocalWithDevice(lease: lease, epoch: workerEpochNanoseconds) { metal, device, limit in
            let observedDevice = try trajectoryCanonicalJSONData(trajectoryDeviceDictionary(metalDevice: metal,
                configuredMemoryLimit: limit, prePostEqual: true))
            try trajectoryRequire(observedDevice == prior.device, "current local verifier device equality")
            let names = ["stage8_preflight", "stage8_post_model_adam_control_reload",
                "stage8_post_retained_comparator_verification", "stage8_postflight"]
            let context = TrajectoryScienceContext(epoch: workerEpochNanoseconds, metalDevice: metal,
                configuredMemoryLimit: limit, artifactRoot: artifactRoot, phaseNames: names,
                currentLocalLease: lease, recordProgress: recordProgress)
            try trajectoryObserveResourcePhase(names[0], context: context)
            let retained = try PrimeCurrentLocalNative300MRetainedInventory(root: artifactRoot,
                bindings: [prior.baselineRun.baseline, prior.baselineRun.uninterrupted, prior.resumed])
            let restoredSnapshot = try currentLocalReloadSnapshot(root: artifactRoot, binding: prior.baselineRun.baseline)
            try trajectoryRequire(restoredSnapshot == prior.baselineRun.evidence.snapshot,
                "current local independent model Adam control snapshot equality")
            MLX.Memory.clearCache()
            try trajectoryObserveResourcePhase(names[1], context: context)
            let comparison = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.comparePrivateComparatorsStreaming(
                root: artifactRoot, uninterrupted: prior.baselineRun.uninterrupted, resumed: prior.resumed)
            try trajectoryRequire(comparison.controlSemanticExact && comparison.firstControlMismatchPath == nil,
                "current local retained comparator control equality")
            try currentLocalRequireStreamedEquality(comparison)
            try retained.revalidate()
            try trajectoryObserveResourcePhase(names[2], context: context)
            try trajectoryObserveResourcePhase(names[3], context: context)
            try currentLocalDeadline(workerEpochNanoseconds, lease: lease)
            return try trajectoryCanonicalJSONData([
                "schema": "prime_current_local_native300m_stage8_retained_verification_v1",
                "status": "PASS_RETAINED_RELOAD_EXACT", "worker_pid": getpid(),
                "worker_started_at": workerEpochNanoseconds,
                "completed_at": DispatchTime.now().uptimeNanoseconds,
                "stage7_result_byte_count": stage7Result.count,
                "stage7_result_sha256": PrimeSHA256.hexDigest(of: stage7Result),
                "actual_model_parameter_count": restoredSnapshot.weights.totalElementCount,
                "model_weights_exact": true, "typed_adam_first_moments_exact": true,
                "typed_adam_second_moments_exact": true, "canonical_control_exact": true,
                "retained_leaf_count": 12, "retained_set_count": 3,
                "retained_artifacts_deleted": false, "additional_training_steps": 0,
                "resource_phases": context.phases,
                "device": try trajectoryCanonicalJSONObject(observedDevice),
                "artifact_root_identity": try trajectoryCanonicalJSONObject(currentLocalRootIdentity(artifactRoot)),
            ])
        }
    }
}

private func currentLocalReloadSnapshot(
    root: PrimeArtifactRoot,
    binding: PrimeNativeDecoderNative300MTrajectoryExternalCommitBindingV1
) throws -> TrajectorySnapshotEvidence {
    let restored = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.loadAuthoritativeModelAndControl(
        root: root, externalCommitBinding: binding)
    try currentLocalRequireBaselineControl(restored.controlState)
    restored.model.train(true)
    let neutral = try PrimeNativeDecoderNative300MTrajectoryCheckpointV1.loadNeutralMomentCatalog(
        root: root, externalCommitBinding: binding, matching: restored.model)
    let typed = try PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.typedAdamState(
        from: neutral, matching: restored.model.trainableParameters())
    let optimizer = trajectoryMakeAdamW()
    try optimizer.update(parameters: typed, matching: restored.model.trainableParameters())
    try checkedEval(restored.model, optimizer)
    return try trajectoryCaptureEvaluationState(model: restored.model, optimizer: optimizer, control: restored.controlState)
}

private func currentLocalRequireBaselineControl(_ data: Data) throws {
    let expected = try trajectoryBaselineControl()
    try trajectoryRequire(data == expected, "current local baseline control")
}

private func currentLocalRequireStreamedEquality(
    _ comparison: PrimeNativeDecoderNative300MTrajectoryStreamingComparisonV1
) throws {
    // All actual catalogs are streamed by the original checkpoint reader;
    // require exact per-tensor bytes, not container hash equality.
    for catalog in [comparison.weights, comparison.firstMoments, comparison.secondMoments] {
        try trajectoryRequire(catalog.exact && catalog.leftLogicalSHA256 == catalog.rightLogicalSHA256
            && catalog.tensors.count == 218 && catalog.totalElementCount == 271_107_072
            && catalog.tensors.allSatisfy({ $0.exact && $0.leftLogicalSHA256 == $0.rightLogicalSHA256 }),
            "current local retained streamed tensor equality")
    }
}
