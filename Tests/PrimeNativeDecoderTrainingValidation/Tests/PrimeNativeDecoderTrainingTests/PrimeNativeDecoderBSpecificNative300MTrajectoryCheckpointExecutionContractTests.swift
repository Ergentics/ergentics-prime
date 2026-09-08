// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore
import PrimeNativeDecoderCheckpoint
import PrimeNativeDecoderTraining
import XCTest

final class
    PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionContractTests:
    XCTestCase
{
    func testBSpecificNative300MTrajectoryCheckpointExecutionContractIsExactAndExecutionPure()
        throws
    {
        typealias Authority =
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1
        typealias Execution =
            PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
        typealias Checkpoint =
            PrimeNativeDecoderNative300MTrajectoryCheckpointV1

        let authority = Authority.frozenV1
        try authority.validateExactV1()
        try Execution.validatePureContractV1()

        XCTAssertEqual(
            Authority.canonicalSHA256,
            "4d995b21a20424f1b05fbcb9fbe33780dbd7af03cbf68047270db4aae192caa4")
        XCTAssertEqual(
            Execution.authorityCanonicalSHA256,
            Authority.canonicalSHA256)
        XCTAssertEqual(Execution.authorityID, authority.authorityID)
        XCTAssertEqual(
            Execution.predecessorMainRevision,
            "912ca2ab8148255fa588a2a1d336b9dcb1221978")
        XCTAssertEqual(
            Execution.authorityClosureRevision,
            "300bad298bc9ff6f2752d1409639ff9e99318db6")
        XCTAssertEqual(
            Execution.authorityClosureTree,
            "d7c57b442e6c9a278b2ab58142ac86cbfa622930")
        XCTAssertEqual(
            Execution.authorityClosureOrderedParents,
            [
                "912ca2ab8148255fa588a2a1d336b9dcb1221978",
                "11dd1e6098fba025cae8107284d2c231a9f2ebf8",
            ])
        XCTAssertEqual(Execution.authorityClosureWorkflowRunID, 31_871_108_399)
        XCTAssertEqual(Execution.authorityClosureWorkflowRunNumber, 127)
        XCTAssertEqual(Execution.authorityClosureRunAttempt, 1)
        XCTAssertEqual(Execution.authorityClosureCheckSuiteID, 86_457_353_564)
        XCTAssertEqual(Execution.authorityClosureActiveJobID, 94_979_749_298)
        XCTAssertEqual(
            Execution.authorityClosureReviewedJobID,
            94_980_086_476)

        XCTAssertEqual(
            Execution.candidateSchemaID,
            authority.integrity.privateCandidateSchemaID)
        XCTAssertEqual(
            Execution.terminalSchemaID,
            authority.integrity.privateTerminalSchemaID)
        XCTAssertEqual(
            Execution.publicReceiptSchemaID,
            authority.integrity.publicReceiptSchemaID)
        XCTAssertEqual(
            Execution.publicReceiptPrefix,
            authority.integrity.publicReceiptPrefix)
        XCTAssertEqual(
            Execution.candidateSchemaKeys,
            authority.integrity.requiredPrivateCandidateFields)
        XCTAssertEqual(
            Execution.terminalSchemaKeys,
            authority.integrity.requiredPrivateTerminalFields)
        XCTAssertEqual(
            Execution.publicReceiptSchemaKeys,
            authority.integrity.requiredPublicReceiptFields)
        XCTAssertEqual(Execution.candidateSchemaKeys.count, 16)
        XCTAssertEqual(Execution.terminalSchemaKeys.count, 10)
        XCTAssertEqual(Execution.publicReceiptSchemaKeys.count, 18)

        XCTAssertEqual(
            Execution.terminalStatusDomain,
            authority.outcomes.allowedTerminalStatuses)
        XCTAssertEqual(
            Execution.noPublicReceiptFailureClasses,
            authority.outcomes.noPublicReceiptFailureClasses)
        XCTAssertEqual(
            Execution.phaseNames,
            authority.resource.requiredPhaseIDs)
        XCTAssertEqual(Execution.phaseNames.count, 12)
        XCTAssertEqual(
            Execution.comparisonDomainIDs,
            authority.comparison.domains.map(\.id))
        XCTAssertEqual(Execution.comparisonDomainIDs.count, 18)
        XCTAssertEqual(
            Execution.fixedComparisonMemberPathsByDomainID,
            [
                "snapshot_full_canonical_control_state_roundtrip": [
                    "role", "global_step", "schedule_id",
                    "current_learning_rate_float32_bits", "rng_domains",
                    "data_cursor", "snapshot_boundary",
                    "checked_evaluation_complete", "accumulation_phase",
                    "pending_gradient_count", "pending_prefetch_count",
                    "kv_cache_entry_count", "decoder_training_mode_true",
                ],
                "batch2_token_and_mask_digest": [
                    "token_and_mask_sha256",
                ],
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
                    "global_step", "initial_global_step",
                    "snapshot_global_step", "schedule_id",
                    "current_learning_rate_float32_bits",
                ],
                "explicit_rng_algorithm_domain_key_counter_and_consumption_digest": [
                    "rng_domains.model_initialization_v1",
                    "rng_domains.training_data_order_v1",
                    "rng_domains.augmentation_v1",
                    "rng_domains.evaluation_v1",
                ],
                "cursor_and_snapshot_boundary_zero_state": [
                    "terminal_data_cursor", "accumulation_phase",
                    "pending_gradient_count", "pending_prefetch_count",
                    "kv_cache_entry_count",
                    "snapshot_boundary_consumed_once",
                    "evaluation_did_not_advance_cursor",
                    "decoder_training_mode_true",
                ],
            ])
        XCTAssertEqual(
            Execution.operationCountKeys,
            authority.integrity.operationCountReceiptFields)
        XCTAssertEqual(
            Execution.checkpointBindingKeys,
            authority.integrity.checkpointSetBindingFields)
        XCTAssertEqual(
            Execution.comparisonDomainResultKeys,
            authority.integrity.comparisonDomainResultFields)
        XCTAssertEqual(
            Execution.tensorCatalogProjectionKeys,
            authority.integrity.tensorCatalogProjectionFields)
        XCTAssertEqual(
            Execution.resourcePhaseKeys,
            authority.integrity.resourcePhaseRecordFields)
        XCTAssertEqual(
            Execution.artifactCleanupKeys,
            authority.integrity.artifactCleanupReceiptFields)
        XCTAssertEqual(
            Execution.firstMismatchKeys,
            authority.integrity.firstMismatchReceiptFields)
        XCTAssertEqual(
            Execution.authorityAndExactMainBindingKeys,
            authority.integrity.authorityAndExactMainBindingFields)
        XCTAssertEqual(
            Execution.leaseAndVerifierKeys,
            authority.integrity.leaseAndVerifierReceiptFields)
        XCTAssertEqual(
            Execution.semanticPathProjectionKeys,
            authority.integrity.semanticPathProjectionFields)
        XCTAssertEqual(
            Execution.authorityAndPredecessorBindingKeys,
            [
                "authority_id", "authority_canonical_sha256", "repository",
                "predecessor_main_revision", "authority_closure_revision",
                "authority_closure_tree",
                "authority_closure_ordered_parents",
                "authority_closure_run_id",
                "authority_closure_run_number",
                "authority_closure_run_attempt",
                "authority_closure_check_suite_id",
                "authority_closure_active_job_id",
                "authority_closure_reviewed_job_id",
                "stage5_b_observation_sha256",
                "b_resource_observation_sha256", "mechanics_revision",
                "mechanics_tree", "mechanics_ordered_parents",
                "mechanics_run_id", "mechanics_run_number",
                "mechanics_run_attempt",
            ])
        XCTAssertEqual(
            Execution.oneShotKeys,
            [
                "consumed", "opportunity_count", "retry_authorized",
                "rerun_authorized", "replacement_authorized",
            ])
        XCTAssertEqual(
            Execution.environmentKeys,
            [
                "mlx_enable_tf32", "mlx_checkout_origin", "mlx_revision",
                "swiftpm_configuration", "graph_mode",
                "compile_transform_count", "operating_system_build",
                "xcode_build", "swift_driver", "swift_sdk",
                "staged_metallib", "runtime_metallib",
            ])
        XCTAssertEqual(
            Execution.deviceAndStreamKeys,
            [
                "metal_device_count", "metal_device_index",
                "metal_device_name", "metal_device_registry_id",
                "metal_device_is_default",
                "metal_device_has_unified_memory",
                "metal_device_max_buffer_length_bytes",
                "metal_device_recommended_max_working_set_bytes",
                "mlx_device_type", "mlx_device_index",
                "mlx_default_device_is_supplied_device",
                "mlx_default_stream_is_gpu", "cpu_fallback_used",
                "stream_order", "evaluation_order",
                "configured_memory_limit_bytes",
                "configured_cache_limit_bytes",
                "pre_post_identity_and_policy_equal",
            ])
        XCTAssertEqual(
            Execution.rawPrivatePathKeys,
            [
                "lease_root", "lease_path", "artifact_root",
                "staged_metallib_path", "runtime_metallib_path",
            ])
        XCTAssertEqual(
            Execution.firstFailedGuardKeys,
            [
                "availability", "guard_id", "classification", "errno",
                "detail",
            ])
        XCTAssertEqual(
            Execution.leaseAcquisitionKeys,
            [
                "acquired", "nonblocking", "supervisor_owned",
                "worker_inherited_descriptor_count",
                "held_through_cleanup_and_postflight",
            ])
        XCTAssertEqual(
            Execution.cleanupAndAbsenceKeys,
            [
                "known_leaf_count", "deleted_leaf_count",
                "unknown_inventory_count", "post_cleanup_empty",
                "absence_proved", "recursive_cleanup_used",
            ])
        XCTAssertEqual(
            Execution.releaseVerifierKeys,
            [
                "executed", "exit_zero", "supervisor_alive",
                "acquire_count", "release_count",
            ])
        XCTAssertEqual(
            Execution.supervisorIntegrityKeys,
            [
                "candidate_validated", "stdout_candidate_then_terminal",
                "post_candidate_inventory_exact",
                "lease_released_explicitly", "terminal_canonical",
            ])
        XCTAssertEqual(
            Execution.privateRawDescriptorTupleKeys,
            [
                "preflight_parent", "post_candidate_parent",
                "post_candidate_leaf", "verifier_parent", "verifier_leaf",
            ])
        XCTAssertEqual(
            Execution.metallibBindingKeys,
            ["semantic_role", "path_sha256", "byte_count", "content_sha256"])
        XCTAssertEqual(
            Execution.checkpointLeafBindingKeys,
            ["role", "publication_ordinal", "byte_count", "sha256"])
        XCTAssertEqual(
            Execution.externalV2ProjectionKeys,
            [
                "schema_id", "compatibility_identity_sha256",
                "artifact_semantic_role", "artifact_path_sha256",
                "container_byte_count", "container_sha256",
                "manifest_sha256",
            ])
        XCTAssertEqual(
            Execution.controlStateProjectionKeys,
            ["schema_id", "canonical_byte_count", "sha256"])
        XCTAssertEqual(Execution.filesystemIDKeys, ["word0", "word1"])
        XCTAssertEqual(
            Execution.privateParentDescriptorTupleKeys,
            [
                "physical_path", "device_id", "inode", "uid", "gid",
                "mode", "acl", "xattr_names", "security_flags",
                "file_type", "observed_nlink",
            ])
        XCTAssertEqual(
            Execution.privateLeaseDescriptorTupleKeys,
            [
                "device_id", "inode", "uid", "gid", "mode", "acl",
                "xattr_names", "security_flags", "file_type", "byte_count",
                "observed_nlink",
            ])
        XCTAssertEqual(
            Execution.environmentAndDeviceReceiptKeys,
            [
                "mlx_enable_tf32", "mlx_checkout_origin", "mlx_revision",
                "swiftpm_configuration", "graph_mode",
                "compile_transform_count", "os_build", "xcode_build",
                "swift_driver", "swift_sdk", "staged_metallib_role",
                "staged_metallib_path_sha256",
                "staged_metallib_byte_count_and_content_sha256",
                "runtime_metallib_role", "runtime_metallib_path_sha256",
                "runtime_metallib_byte_count_and_content_sha256",
                "metal_name_registry_unified_max_buffer_recommended_set",
                "mlx_device_and_default_gpu_stream", "stream_order",
                "evaluation_order", "pre_post_identity_and_policy_equal",
                "root_and_validation_lock_bindings",
            ])
        XCTAssertEqual(Execution.environmentAndDeviceReceiptKeys.count, 22)
        XCTAssertEqual(
            Execution.publicDescriptorTupleKeys,
            [
                "semantic_role", "path_sha256", "device_id", "inode", "uid",
                "gid", "mode", "acl_entry_count", "xattr_names",
                "security_flags", "file_type", "byte_count",
                "observed_nlink",
            ])
        XCTAssertEqual(
            Execution.lockBindingKeys,
            ["path_role", "git_blob", "byte_count", "sha256"])
        XCTAssertEqual(
            Execution.byteCountAndSHA256Keys,
            ["byte_count", "sha256"])
        XCTAssertEqual(
            Execution.metalDeviceReceiptKeys,
            [
                "name", "registry_id", "has_unified_memory",
                "max_buffer_length", "recommended_max_working_set_size",
            ])
        XCTAssertEqual(
            Execution.mlxDeviceAndStreamReceiptKeys,
            ["device", "default_stream"])
        XCTAssertEqual(
            Execution.publicDescriptorSemanticRoles,
            [
                "preflight_parent", "post_candidate_parent",
                "post_candidate_leaf", "verifier_parent", "verifier_leaf",
            ])
        XCTAssertEqual(
            Execution.semanticPathRoles,
            [
                "lease_root", "lease_path", "artifact_root",
                "staged_metallib", "runtime_metallib",
            ])

        XCTAssertEqual(
            Execution.maximumPrivateCandidateCanonicalByteCount,
            262_144)
        XCTAssertEqual(
            Execution.maximumPrivateTerminalCanonicalByteCount,
            65_536)
        XCTAssertEqual(Execution.maximumPublicCanonicalByteCount, 131_072)
        XCTAssertEqual(Execution.maximumFrameChunkByteCount, 16_384)
        XCTAssertEqual(Execution.frameReadDeadlineSeconds, 30)
        XCTAssertEqual(Execution.workerTimeoutSeconds, 4_800)
        XCTAssertEqual(Execution.supervisorTimeoutSeconds, 5_100)
        XCTAssertEqual(Execution.terminationGraceSeconds, 10)
        XCTAssertEqual(
            Execution.maximalPublicReceiptCanonicalByteCount,
            54_022)
        XCTAssertEqual(Execution.workerArgument, "--trajectory-worker")
        XCTAssertEqual(Execution.verifierArgument, "--release-verifier")
        XCTAssertEqual(Execution.workerFrameDescriptor, 19)

        let expectedOperationCounts: [String: UInt64] = [
            "training_step_count": 3, "backward_count": 3,
            "optimizer_update_count": 3,
            "dense_b_path_logits_call_count": 6,
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
            "evaluation_forward_pass_count": 3,
            "forward_loss_count": 6, "cross_entropy_count": 6,
            "training_mode_disable_count": 3,
            "training_mode_restore_count": 3,
            "v2_weights_write_count": 3,
            "v2_internal_verification_load_count": 3,
            "public_restore_load_count": 1,
            "optimizer_moment_publish_count": 3,
            "deferred_optimizer_moment_load_count": 1,
            "leaf_publication_count": 12,
            "final_commit_publication_count": 3,
            "model_allocation_and_materialization_count": 5,
            "optimizer_allocation_count": 2,
            "typed_optimizer_state_import_count": 1,
            "worker_process_count": 1, "supervisor_process_count": 1,
            "release_verifier_process_count": 1,
            "maximum_public_receipt_count": 1,
        ]
        XCTAssertEqual(Execution.exactOperationCounts, expectedOperationCounts)
        XCTAssertEqual(
            Set(Execution.exactOperationCounts.keys),
            Set(Execution.operationCountKeys))

        let expectedEnvironmentVariableNames = [
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
        XCTAssertEqual(
            Execution.environmentVariableNames,
            expectedEnvironmentVariableNames)
        XCTAssertEqual(expectedEnvironmentVariableNames.count, 34)
        XCTAssertEqual(
            Set(expectedEnvironmentVariableNames).count,
            expectedEnvironmentVariableNames.count)

        XCTAssertEqual(
            Checkpoint.checkpointSchemaID,
            authority.checkpoint.schemaID)
        XCTAssertEqual(
            Checkpoint.externalCommitBindingSchemaID,
            authority.checkpoint.externalCommitBindingSchemaID)
        XCTAssertEqual(
            Checkpoint.momentManifestSchemaID,
            "ergentics_prime_native_decoder_adamw_moments_checkpoint_v1")
        XCTAssertEqual(
            authority.checkpoint.leaves[1].artifactKind,
            "prime_native_decoder_adamw_moments_checkpoint_v1")
        XCTAssertEqual(
            authority.checkpoint.leaves[1].encoding,
            Checkpoint.momentEncoding)
        XCTAssertEqual(Checkpoint.expectedParameterPathCount, 218)
        XCTAssertEqual(Checkpoint.expectedMomentTensorCount, 436)
        XCTAssertEqual(
            Checkpoint.firstMomentStoragePrefix,
            "first_moment.")
        XCTAssertEqual(
            Checkpoint.secondMomentStoragePrefix,
            "second_moment.")
        XCTAssertEqual(
            PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
                .allCases.map(\.rawValue),
            authority.resource.ephemeralFourLeafSetRoles)
        XCTAssertTrue(
            PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
                .baselineCheckpoint.loadAuthoritative)
        XCTAssertFalse(
            PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
                .uninterruptedNPlus1Comparator.loadAuthoritative)
        XCTAssertFalse(
            PrimeNativeDecoderNative300MTrajectoryCheckpointSetRoleV1
                .resumedNPlus1Comparator.loadAuthoritative)

        try validateMaximalPublicReceiptPureContract(Execution.self)
        try validatePublicOutcomeMatrixPureContract(Execution.self)
        try validateOwnedAndCoordinatedSourceTopology(
            authority: authority,
            execution: Execution.self)
    }

    private func validateMaximalPublicReceiptPureContract(
        _ execution:
            PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
                .Type
    ) throws {
        let data = try execution
            .maximalPublicReceiptFixtureCanonicalDataV1()
        XCTAssertEqual(data.count, 54_022)
        XCTAssertFalse(data.contains(0x0A))
        XCTAssertFalse(data.contains(0x0D))
        XCTAssertNoThrow(
            try execution.validateCanonicalPublicReceiptDataV1(data))

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data)
                as? [String: Any])
        XCTAssertEqual(
            Set(object.keys),
            Set(execution.publicReceiptSchemaKeys))
        XCTAssertEqual(
            try execution.canonicalPublicReceiptDataV1(object),
            data)

        for key in execution.publicReceiptSchemaKeys {
            var mutated = object
            mutated.removeValue(forKey: key)
            XCTAssertThrowsError(
                try execution.canonicalPublicReceiptDataV1(mutated),
                key)
        }
        var unexpectedKey = object
        unexpectedKey["unexpected_schema_key"] = true
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(unexpectedKey))

        var schemaMutation = object
        schemaMutation["schema"] = "mutated"
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(schemaMutation))

        var hashMutation = object
        hashMutation["terminal_sha256"] =
            String(repeating: "A", count: 64)
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(hashMutation))

        var rawPathMutation = object
        var environment = try XCTUnwrap(
            rawPathMutation["environment_and_device_bindings"]
                as? [String: Any])
        environment["swift_driver"] = "/private/raw/path"
        rawPathMutation["environment_and_device_bindings"] = environment
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(rawPathMutation))

        var observationalParentNlinks = object
        var nlinkLease = try XCTUnwrap(
            observationalParentNlinks["lease_and_verifier"]
                as? [String: Any])
        for (key, value) in [
            ("preflight_parent", 0),
            ("post_candidate_parent", 1),
            ("verifier_parent", 2),
        ] {
            var descriptor = try XCTUnwrap(
                nlinkLease[key] as? [String: Any])
            descriptor["observed_nlink"] = value
            nlinkLease[key] = descriptor
        }
        observationalParentNlinks["lease_and_verifier"] = nlinkLease
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                observationalParentNlinks))

        var allowedProvenanceXattrs = object
        var provenanceLease = try XCTUnwrap(
            allowedProvenanceXattrs["lease_and_verifier"]
                as? [String: Any])
        for key in execution.publicDescriptorSemanticRoles {
            var descriptor = try XCTUnwrap(
                provenanceLease[key] as? [String: Any])
            descriptor["xattr_names"] = ["com.apple.provenance"]
            provenanceLease[key] = descriptor
        }
        allowedProvenanceXattrs["lease_and_verifier"] = provenanceLease
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                allowedProvenanceXattrs))

        var forbiddenXattr = allowedProvenanceXattrs
        var forbiddenLease = try XCTUnwrap(
            forbiddenXattr["lease_and_verifier"] as? [String: Any])
        var forbiddenLeaf = try XCTUnwrap(
            forbiddenLease["post_candidate_leaf"] as? [String: Any])
        forbiddenLeaf["xattr_names"] = ["com.apple.quarantine"]
        forbiddenLease["post_candidate_leaf"] = forbiddenLeaf
        forbiddenXattr["lease_and_verifier"] = forbiddenLease
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(forbiddenXattr))

        var forbiddenLeafNlink = object
        var leafNlinkLease = try XCTUnwrap(
            forbiddenLeafNlink["lease_and_verifier"] as? [String: Any])
        var leafNlink = try XCTUnwrap(
            leafNlinkLease["post_candidate_leaf"] as? [String: Any])
        leafNlink["observed_nlink"] = 2
        leafNlinkLease["post_candidate_leaf"] = leafNlink
        forbiddenLeafNlink["lease_and_verifier"] = leafNlinkLease
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(forbiddenLeafNlink))

        var domainOrderMutation = object
        var domains = try XCTUnwrap(
            domainOrderMutation["comparison_domain_results"]
                as? [[String: Any]])
        domains.swapAt(0, 1)
        domainOrderMutation["comparison_domain_results"] = domains
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                domainOrderMutation))

        var phaseOrderMutation = object
        var phases = try XCTUnwrap(
            phaseOrderMutation["resource_phases"]
                as? [[String: Any]])
        phases.swapAt(0, 1)
        phaseOrderMutation["resource_phases"] = phases
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                phaseOrderMutation))

        var signedFilesystemIDMutation = object
        var filesystemIDPhases = try XCTUnwrap(
            signedFilesystemIDMutation["resource_phases"]
                as? [[String: Any]])
        var filesystemID = try XCTUnwrap(
            filesystemIDPhases[0]["filesystem_fsid"]
                as? [String: Any])
        filesystemID["word0"] = -1
        filesystemIDPhases[0]["filesystem_fsid"] = filesystemID
        signedFilesystemIDMutation["resource_phases"] = filesystemIDPhases
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                signedFilesystemIDMutation),
            "filesystem ID words are unsigned 32-bit observations")

        XCTAssertThrowsError(
            try execution.validateCanonicalPublicReceiptDataV1(
                Data([0x20]) + data))
        XCTAssertThrowsError(
            try execution.validateCanonicalPublicReceiptDataV1(
                data + Data([0x0A])))
        XCTAssertThrowsError(
            try execution.validateCanonicalPublicReceiptDataV1(
                Data(data.dropLast())))
        var byteMutation = data
        byteMutation[byteMutation.startIndex] =
            byteMutation[byteMutation.startIndex] == 0x7B ? 0x5B : 0x7B
        XCTAssertThrowsError(
            try execution.validateCanonicalPublicReceiptDataV1(
                byteMutation))
    }

    private func validatePublicOutcomeMatrixPureContract(
        _ execution:
            PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
                .Type
    ) throws {
        let maximalData = try execution
            .maximalPublicReceiptFixtureCanonicalDataV1()
        let maximal = try XCTUnwrap(
            JSONSerialization.jsonObject(with: maximalData)
                as? [String: Any])

        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(maximal),
            "PASS_EXACT")
        var cleanupCheckpointCountMismatch = maximal
        var mismatchedCleanup = try XCTUnwrap(
            cleanupCheckpointCountMismatch[
                "artifact_cleanup_and_absence"] as? [String: Any])
        mismatchedCleanup["known_inventory_before_cleanup"] = 8
        mismatchedCleanup["deleted_known_leaf_count"] = 8
        mismatchedCleanup["deleted_private_comparator_count"] = 1
        cleanupCheckpointCountMismatch["artifact_cleanup_and_absence"] =
            mismatchedCleanup
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                cleanupCheckpointCountMismatch),
            "three committed sets require exact 12-leaf/two-comparator cleanup")

        let zeroSHA = String(repeating: "0", count: 64)
        let oneSHA = String(repeating: "1", count: 64)
        let modelMismatchPath = "token_embedding.weight"
        var measuredMismatch = maximal
        measuredMismatch["terminal_status"] = "MEASURED_EXACT_MISMATCH"
        var measuredDomains = try XCTUnwrap(
            measuredMismatch["comparison_domain_results"]
                as? [[String: Any]])
        var firstDomain = measuredDomains[0]
        firstDomain["exact"] = false
        firstDomain["right_sha256"] = oneSHA
        firstDomain["first_mismatch_path"] = modelMismatchPath
        firstDomain["first_mismatch_expected_binding"] = zeroSHA
        firstDomain["first_mismatch_observed_binding"] = oneSHA
        var firstProjection = try XCTUnwrap(
            firstDomain["tensor_catalog_projection"] as? [String: Any])
        firstProjection["first_mismatch_path_if_any"] = modelMismatchPath
        firstDomain["tensor_catalog_projection"] = firstProjection
        measuredDomains[0] = firstDomain
        measuredMismatch["comparison_domain_results"] = measuredDomains
        measuredMismatch["first_mismatch_if_any"] = [
            "availability": "available", "domain_id": "snapshot_weights",
            "path": modelMismatchPath, "expected_binding": zeroSHA,
            "observed_binding": oneSHA,
        ]
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(measuredMismatch),
            "MEASURED_EXACT_MISMATCH")
        var decoupledTopLevelMismatch = measuredMismatch
        var decoupledFirst = try XCTUnwrap(
            decoupledTopLevelMismatch["first_mismatch_if_any"]
                as? [String: Any])
        decoupledFirst["path"] = "final_norm.weight"
        decoupledTopLevelMismatch["first_mismatch_if_any"] = decoupledFirst
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                decoupledTopLevelMismatch))
        var decoupledTopLevelBindings = measuredMismatch
        var decoupledBindingFirst = try XCTUnwrap(
            decoupledTopLevelBindings["first_mismatch_if_any"]
                as? [String: Any])
        decoupledBindingFirst["expected_binding"] = oneSHA
        decoupledBindingFirst["observed_binding"] = zeroSHA
        decoupledTopLevelBindings["first_mismatch_if_any"] =
            decoupledBindingFirst
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                decoupledTopLevelBindings))

        var successorWeightMismatch = maximal
        successorWeightMismatch["terminal_status"] =
            "MEASURED_EXACT_MISMATCH"
        var successorWeightDomains = try XCTUnwrap(
            successorWeightMismatch["comparison_domain_results"]
                as? [[String: Any]])
        var successorWeightDomain = successorWeightDomains[11]
        successorWeightDomain["exact"] = false
        successorWeightDomain["right_sha256"] = oneSHA
        successorWeightDomain["first_mismatch_path"] = modelMismatchPath
        successorWeightDomain["first_mismatch_expected_binding"] = zeroSHA
        successorWeightDomain["first_mismatch_observed_binding"] = oneSHA
        var successorWeightProjection = try XCTUnwrap(
            successorWeightDomain["tensor_catalog_projection"]
                as? [String: Any])
        successorWeightProjection["first_mismatch_path_if_any"] =
            modelMismatchPath
        successorWeightDomain["tensor_catalog_projection"] =
            successorWeightProjection
        successorWeightDomains[11] = successorWeightDomain
        successorWeightMismatch["comparison_domain_results"] =
            successorWeightDomains
        successorWeightMismatch["first_mismatch_if_any"] = [
            "availability": "available",
            "domain_id": "successor_post_update_parameter_bytes",
            "path": modelMismatchPath,
            "expected_binding": zeroSHA,
            "observed_binding": oneSHA,
        ]
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                successorWeightMismatch),
            "successor weight divergence remains measured, not integrity")

        let firstMomentMismatchPath =
            "first_moment.token_embedding.weight"
        var firstMomentMismatch = maximal
        firstMomentMismatch["terminal_status"] =
            "MEASURED_EXACT_MISMATCH"
        var firstMomentDomains = try XCTUnwrap(
            firstMomentMismatch["comparison_domain_results"]
                as? [[String: Any]])
        var firstMomentDomain = firstMomentDomains[1]
        firstMomentDomain["exact"] = false
        firstMomentDomain["right_sha256"] = oneSHA
        firstMomentDomain["first_mismatch_path"] = firstMomentMismatchPath
        firstMomentDomain["first_mismatch_expected_binding"] = zeroSHA
        firstMomentDomain["first_mismatch_observed_binding"] = oneSHA
        var firstMomentProjection = try XCTUnwrap(
            firstMomentDomain["tensor_catalog_projection"]
                as? [String: Any])
        firstMomentProjection["first_mismatch_path_if_any"] =
            firstMomentMismatchPath
        firstMomentDomain["tensor_catalog_projection"] =
            firstMomentProjection
        firstMomentDomains[1] = firstMomentDomain
        firstMomentMismatch["comparison_domain_results"] =
            firstMomentDomains
        firstMomentMismatch["first_mismatch_if_any"] = [
            "availability": "available",
            "domain_id": "snapshot_optimizer_first_moments",
            "path": firstMomentMismatchPath,
            "expected_binding": zeroSHA,
            "observed_binding": oneSHA,
        ]
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                firstMomentMismatch))
        let wrongMomentPrefixPath =
            "second_moment.token_embedding.weight"
        var wrongMomentPrefix = firstMomentMismatch
        var wrongMomentDomains = firstMomentDomains
        var wrongMomentDomain = wrongMomentDomains[1]
        wrongMomentDomain["first_mismatch_path"] = wrongMomentPrefixPath
        var wrongMomentProjection = try XCTUnwrap(
            wrongMomentDomain["tensor_catalog_projection"]
                as? [String: Any])
        wrongMomentProjection["first_mismatch_path_if_any"] =
            wrongMomentPrefixPath
        wrongMomentDomain["tensor_catalog_projection"] =
            wrongMomentProjection
        wrongMomentDomains[1] = wrongMomentDomain
        wrongMomentPrefix["comparison_domain_results"] = wrongMomentDomains
        var wrongMomentTop = try XCTUnwrap(
            wrongMomentPrefix["first_mismatch_if_any"]
                as? [String: Any])
        wrongMomentTop["path"] = wrongMomentPrefixPath
        wrongMomentPrefix["first_mismatch_if_any"] = wrongMomentTop
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                wrongMomentPrefix))

        let twoSHA = String(repeating: "2", count: 64)
        let threeSHA = String(repeating: "3", count: 64)
        var memberBoundDigestMismatch = maximal
        memberBoundDigestMismatch["terminal_status"] =
            "MEASURED_EXACT_MISMATCH"
        var digestDomains = try XCTUnwrap(
            memberBoundDigestMismatch["comparison_domain_results"]
                as? [[String: Any]])
        var digestDomain = digestDomains[4]
        digestDomain["exact"] = false
        digestDomain["right_sha256"] = oneSHA
        digestDomain["first_mismatch_path"] = "token_and_mask_sha256"
        digestDomain["first_mismatch_expected_binding"] = twoSHA
        digestDomain["first_mismatch_observed_binding"] = threeSHA
        digestDomains[4] = digestDomain
        memberBoundDigestMismatch["comparison_domain_results"] =
            digestDomains
        memberBoundDigestMismatch["first_mismatch_if_any"] = [
            "availability": "available",
            "domain_id": "batch2_token_and_mask_digest",
            "path": "token_and_mask_sha256",
            "expected_binding": twoSHA,
            "observed_binding": threeSHA,
        ]
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                memberBoundDigestMismatch),
            "per-member mismatch evidence differs from aggregate bindings")
        var aggregateExactContradiction = memberBoundDigestMismatch
        var contradictoryDomains = try XCTUnwrap(
            aggregateExactContradiction["comparison_domain_results"]
                as? [[String: Any]])
        var contradictoryDomain = contradictoryDomains[4]
        contradictoryDomain["right_sha256"] =
            contradictoryDomain["left_sha256"]
        contradictoryDomains[4] = contradictoryDomain
        aggregateExactContradiction["comparison_domain_results"] =
            contradictoryDomains
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                aggregateExactContradiction),
            "aggregate equality cannot carry unequal member evidence")

        func completeReceiptBelowMemoryFloor(
            _ receipt: [String: Any]
        ) throws -> [String: Any] {
            var result = receipt
            var environment = try XCTUnwrap(
                result["environment_and_device_bindings"]
                    as? [String: Any])
            var metal = try XCTUnwrap(
                environment[
                    "metal_name_registry_unified_max_buffer_recommended_set"
                ] as? [String: Any])
            metal["recommended_max_working_set_size"] = 4_000_000_000
            environment[
                "metal_name_registry_unified_max_buffer_recommended_set"
            ] = metal
            result["environment_and_device_bindings"] = environment
            var phases = try XCTUnwrap(
                result["resource_phases"] as? [[String: Any]])
            phases = phases.map { phase in
                var below = phase
                below[
                    "verified_configured_memory_limit_copied_from_preflight_bytes"
                ] = 4_000_000_000
                return below
            }
            result["resource_phases"] = phases
            return result
        }
        func completeReceiptBelowFilesystemFloor(
            _ receipt: [String: Any]
        ) throws -> [String: Any] {
            var result = receipt
            var phases = try XCTUnwrap(
                result["resource_phases"] as? [[String: Any]])
            phases[0]["filesystem_available_bytes"] = 12_000_000_000
            result["resource_phases"] = phases
            return result
        }
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                completeReceiptBelowMemoryFloor(maximal)))
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                completeReceiptBelowFilesystemFloor(maximal)))
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                completeReceiptBelowMemoryFloor(measuredMismatch)))
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                completeReceiptBelowFilesystemFloor(measuredMismatch)))

        var nonmemberMismatch = measuredMismatch
        var nonmemberDomains = try XCTUnwrap(
            nonmemberMismatch["comparison_domain_results"]
                as? [[String: Any]])
        var nonmemberDomain = nonmemberDomains[0]
        nonmemberDomain["first_mismatch_path"] = "unexpected.weight"
        var nonmemberProjection = try XCTUnwrap(
            nonmemberDomain["tensor_catalog_projection"] as? [String: Any])
        nonmemberProjection["first_mismatch_path_if_any"] =
            "unexpected.weight"
        nonmemberDomain["tensor_catalog_projection"] = nonmemberProjection
        nonmemberDomains[0] = nonmemberDomain
        nonmemberMismatch["comparison_domain_results"] = nonmemberDomains
        var nonmemberFirst = try XCTUnwrap(
            nonmemberMismatch["first_mismatch_if_any"] as? [String: Any])
        nonmemberFirst["path"] = "unexpected.weight"
        nonmemberMismatch["first_mismatch_if_any"] = nonmemberFirst
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(nonmemberMismatch))

        func sha256(_ value: String) -> String {
            PrimeSHA256.hexDigest(of: Data(value.utf8))
        }
        func resourceReceipt(
            memoryLimit: UInt64?,
            filesystemAvailable: UInt64?,
            explicitMismatch: [String: Any]? = nil,
            elapsedNanoseconds: UInt64? = nil
        ) throws -> [String: Any] {
            let selectedGuardCount = [
                memoryLimit != nil,
                filesystemAvailable != nil,
                explicitMismatch != nil,
            ].filter { $0 }.count
            precondition(selectedGuardCount == 1)
            var receipt = maximal
            receipt["terminal_status"] = "ABSTAIN_RESOURCE"

            var counts = try XCTUnwrap(
                receipt["operation_counts"] as? [String: Any])
            for key in execution.operationCountKeys {
                counts[key] = 0
            }
            counts["worker_process_count"] = 1
            counts["supervisor_process_count"] = 1
            counts["release_verifier_process_count"] = 1
            counts["maximum_public_receipt_count"] = 1
            counts["resource_measurement_synchronize_count"] = 1
            receipt["operation_counts"] = counts

            let nullableDomainKeys = [
                "catalog_sha256", "left_total_bytes", "left_sha256",
                "right_total_bytes", "right_sha256", "exact",
                "first_mismatch_path",
                "first_mismatch_expected_binding",
                "first_mismatch_observed_binding",
                "tensor_catalog_projection",
            ]
            var domains = try XCTUnwrap(
                receipt["comparison_domain_results"]
                    as? [[String: Any]])
            domains = domains.map { domain in
                var unmeasured = domain
                for key in nullableDomainKeys {
                    unmeasured[key] = NSNull()
                }
                return unmeasured
            }
            receipt["comparison_domain_results"] = domains
            receipt["checkpoint_and_comparator_bindings"] =
                [[String: Any]]()

            var cleanup = try XCTUnwrap(
                receipt["artifact_cleanup_and_absence"]
                    as? [String: Any])
            cleanup["known_inventory_before_cleanup"] = 0
            cleanup["deleted_known_leaf_count"] = 0
            cleanup["deleted_private_comparator_count"] = 0
            receipt["artifact_cleanup_and_absence"] = cleanup

            let phases = try XCTUnwrap(
                receipt["resource_phases"] as? [[String: Any]])
            var preflight = phases[0]
            if let elapsedNanoseconds {
                preflight["cumulative_elapsed_nanoseconds"] =
                    elapsedNanoseconds
            }
            let mismatch: [String: Any]
            if let memoryLimit {
                preflight[
                    "verified_configured_memory_limit_copied_from_preflight_bytes"
                ] = memoryLimit
                var environment = try XCTUnwrap(
                    receipt["environment_and_device_bindings"]
                        as? [String: Any])
                var metal = try XCTUnwrap(
                    environment[
                        "metal_name_registry_unified_max_buffer_recommended_set"
                    ] as? [String: Any])
                metal["recommended_max_working_set_size"] = memoryLimit
                environment[
                    "metal_name_registry_unified_max_buffer_recommended_set"
                ] = metal
                receipt["environment_and_device_bindings"] = environment
                mismatch = [
                    "availability": "unavailable",
                    "domain_id": "memory_limit_below_minimum_floor",
                    "path":
                        "device_and_stream.configured_memory_limit_bytes",
                    "expected_binding": sha256(
                        "minimum_memory_limit_floor_bytes=4337713152"),
                    "observed_binding": sha256(
                        "configured_memory_limit_bytes=\(memoryLimit)"),
                ]
            } else if let filesystemAvailable {
                preflight["filesystem_available_bytes"] =
                    filesystemAvailable
                mismatch = [
                    "availability": "unavailable",
                    "domain_id":
                        "filesystem_available_below_three_set_floor",
                    "path":
                        "resource_phases[0].filesystem_available_bytes",
                    "expected_binding": sha256(
                        "available_filesystem_floor_bytes=12884901888"),
                    "observed_binding": sha256(
                        "filesystem_available_bytes=\(filesystemAvailable)"),
                ]
            } else {
                mismatch = try XCTUnwrap(explicitMismatch)
            }
            receipt["resource_phases"] = [preflight]
            receipt["first_mismatch_if_any"] = mismatch
            return receipt
        }

        let belowMemory = try resourceReceipt(
            memoryLimit: 4_000_000_000,
            filesystemAvailable: nil)
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(belowMemory),
            "ABSTAIN_RESOURCE memory floor")
        let belowFilesystem = try resourceReceipt(
            memoryLimit: nil,
            filesystemAvailable: 12_000_000_000)
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(belowFilesystem),
            "ABSTAIN_RESOURCE filesystem floor")

        var arbitraryResourceHash = belowMemory
        var arbitraryMismatch = try XCTUnwrap(
            arbitraryResourceHash["first_mismatch_if_any"]
                as? [String: Any])
        arbitraryMismatch["observed_binding"] = oneSHA
        arbitraryResourceHash["first_mismatch_if_any"] = arbitraryMismatch
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                arbitraryResourceHash))

        let enomem = try resourceReceipt(
            memoryLimit: nil,
            filesystemAvailable: nil,
            explicitMismatch: [
                "availability": "unavailable",
                "domain_id": "positively_identified_enomem",
                "path": "errno", "expected_binding": NSNull(),
                "observed_binding": sha256("errno=12"),
            ])
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(enomem),
            "ABSTAIN_RESOURCE ENOMEM")
        let enospc = try resourceReceipt(
            memoryLimit: nil,
            filesystemAvailable: nil,
            explicitMismatch: [
                "availability": "unavailable",
                "domain_id": "positively_identified_enospc",
                "path": "errno", "expected_binding": NSNull(),
                "observed_binding": sha256("errno=28"),
            ])
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(enospc),
            "ABSTAIN_RESOURCE ENOSPC")

        let maximalPhases = try XCTUnwrap(
            maximal["resource_phases"] as? [[String: Any]])
        let configuredMemoryLimit = try XCTUnwrap(
            maximalPhases[0][
                "verified_configured_memory_limit_copied_from_preflight_bytes"
            ] as? NSNumber).uint64Value
        let mlxPeak = configuredMemoryLimit
        var mlxExhaustion = try resourceReceipt(
            memoryLimit: nil,
            filesystemAvailable: nil,
            explicitMismatch: [
                "availability": "unavailable",
                "domain_id":
                    "positively_identified_mlx_memory_limit_exhaustion",
                "path": "resource_phases[last].mlx_peak_bytes",
                "expected_binding": NSNull(),
                "observed_binding": sha256(
                    "configured_memory_limit_bytes=\(configuredMemoryLimit);mlx_peak_bytes=\(mlxPeak);positively_identified_mlx_memory_limit_exhaustion=true"),
            ])
        var mlxExhaustionPhases = try XCTUnwrap(
            mlxExhaustion["resource_phases"] as? [[String: Any]])
        mlxExhaustionPhases[0]["mlx_peak_bytes"] = mlxPeak
        mlxExhaustion["resource_phases"] = mlxExhaustionPhases
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(mlxExhaustion),
            "ABSTAIN_RESOURCE MLX positive exhaustion")
        var lowPeakMLXExhaustion = mlxExhaustion
        var lowPeakPhases = mlxExhaustionPhases
        let lowPeak = configuredMemoryLimit - 1
        lowPeakPhases[0]["mlx_peak_bytes"] = lowPeak
        lowPeakMLXExhaustion["resource_phases"] = lowPeakPhases
        var lowPeakMismatch = try XCTUnwrap(
            lowPeakMLXExhaustion["first_mismatch_if_any"]
                as? [String: Any])
        lowPeakMismatch["observed_binding"] = sha256(
            "configured_memory_limit_bytes=\(configuredMemoryLimit);mlx_peak_bytes=\(lowPeak);positively_identified_mlx_memory_limit_exhaustion=true")
        lowPeakMLXExhaustion["first_mismatch_if_any"] = lowPeakMismatch
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                lowPeakMLXExhaustion),
            "MLX exhaustion requires peak bytes at or above the limit")

        let timeoutElapsed: UInt64 = 4_800_000_000_000
        let containedTimeout = try resourceReceipt(
            memoryLimit: nil,
            filesystemAvailable: nil,
            explicitMismatch: [
                "availability": "unavailable",
                "domain_id":
                    "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure",
                "path":
                    "resource_phases[last].cumulative_elapsed_nanoseconds",
                "expected_binding": NSNull(),
                "observed_binding": sha256(
                    "timeout_role=worker;deadline_seconds=4800;elapsed_nanoseconds=\(timeoutElapsed);contained=true;cleanup_absence=true"),
            ],
            elapsedNanoseconds: timeoutElapsed)
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(containedTimeout),
            "ABSTAIN_RESOURCE contained timeout")

        func lateContainedTimeout(
            _ receipt: [String: Any],
            phaseCount: Int = 12
        ) throws -> [String: Any] {
            precondition(phaseCount == 11 || phaseCount == 12)
            var result = receipt
            result["terminal_status"] = "ABSTAIN_RESOURCE"
            var phases = try XCTUnwrap(
                result["resource_phases"] as? [[String: Any]])
            phases = Array(phases.prefix(phaseCount))
            phases[phaseCount - 1]["cumulative_elapsed_nanoseconds"] =
                timeoutElapsed
            result["resource_phases"] = phases
            var counts = try XCTUnwrap(
                result["operation_counts"] as? [String: Any])
            counts["resource_measurement_synchronize_count"] = phaseCount
            result["operation_counts"] = counts
            result["first_mismatch_if_any"] = [
                "availability": "unavailable",
                "domain_id":
                    "worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure",
                "path":
                    "resource_phases[last].cumulative_elapsed_nanoseconds",
                "expected_binding": NSNull(),
                "observed_binding": sha256(
                    "timeout_role=worker;deadline_seconds=4800;elapsed_nanoseconds=\(timeoutElapsed);contained=true;cleanup_absence=true"),
            ]
            return result
        }
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                lateContainedTimeout(maximal)),
            "phase-12 timeout preserves all exact comparison evidence")
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                lateContainedTimeout(maximal, phaseCount: 11)),
            "phase-11 timeout preserves completed cleanup evidence")
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                lateContainedTimeout(successorWeightMismatch)),
            "late timeout preserves measured scientific mismatch evidence")
        var undercountedLateTimeout = try lateContainedTimeout(maximal)
        var undercountedLateCounts = try XCTUnwrap(
            undercountedLateTimeout["operation_counts"]
                as? [String: Any])
        undercountedLateCounts["gradient_evidence_capture_count"] = 1
        undercountedLateTimeout["operation_counts"] = undercountedLateCounts
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                undercountedLateTimeout),
            "full late-timeout evidence requires exact science counts")
        var lateTimeoutWithExpectedBinding = try lateContainedTimeout(maximal)
        var lateTimeoutExpectedMismatch = try XCTUnwrap(
            lateTimeoutWithExpectedBinding["first_mismatch_if_any"]
                as? [String: Any])
        lateTimeoutExpectedMismatch["expected_binding"] = oneSHA
        lateTimeoutWithExpectedBinding["first_mismatch_if_any"] =
            lateTimeoutExpectedMismatch
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                lateTimeoutWithExpectedBinding),
            "timeout guard expected binding must remain null")

        func completeOutcomeCrossingScienceCutoff(
            _ receipt: [String: Any]
        ) throws -> [String: Any] {
            var result = receipt
            var phases = try XCTUnwrap(
                result["resource_phases"] as? [[String: Any]])
            phases[phases.count - 1][
                "cumulative_elapsed_nanoseconds"] = timeoutElapsed
            result["resource_phases"] = phases
            return result
        }
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                completeOutcomeCrossingScienceCutoff(maximal)),
            "PASS_EXACT cannot cross the science cutoff")
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                completeOutcomeCrossingScienceCutoff(measuredMismatch)),
            "MEASURED_EXACT_MISMATCH cannot cross the science cutoff")

        for nonFloorResourceReceipt in [
            enomem, enospc, containedTimeout,
        ] {
            XCTAssertThrowsError(
                try execution.canonicalPublicReceiptDataV1(
                    completeReceiptBelowMemoryFloor(
                        nonFloorResourceReceipt)),
                "non-floor RESOURCE guard requires the memory floor")
        }
        for nonFloorResourceReceipt in [
            enomem, enospc, mlxExhaustion, containedTimeout,
        ] {
            XCTAssertThrowsError(
                try execution.canonicalPublicReceiptDataV1(
                    completeReceiptBelowFilesystemFloor(
                        nonFloorResourceReceipt)),
                "non-floor RESOURCE guard requires the preflight filesystem floor")
        }
        var mlxBelowMemoryFloor = try completeReceiptBelowMemoryFloor(
            mlxExhaustion)
        var mlxBelowMemoryMismatch = try XCTUnwrap(
            mlxBelowMemoryFloor["first_mismatch_if_any"]
                as? [String: Any])
        mlxBelowMemoryMismatch["observed_binding"] = sha256(
            "configured_memory_limit_bytes=4000000000;mlx_peak_bytes=\(mlxPeak);positively_identified_mlx_memory_limit_exhaustion=true")
        mlxBelowMemoryFloor["first_mismatch_if_any"] =
            mlxBelowMemoryMismatch
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                mlxBelowMemoryFloor),
            "MLX RESOURCE guard cannot bypass the memory floor")

        for resourceReceipt in [enomem, enospc, mlxExhaustion, containedTimeout] {
            var mutation = resourceReceipt
            var mismatch = try XCTUnwrap(
                mutation["first_mismatch_if_any"] as? [String: Any])
            mismatch["observed_binding"] = oneSHA
            mutation["first_mismatch_if_any"] = mismatch
            XCTAssertThrowsError(
                try execution.canonicalPublicReceiptDataV1(mutation))
        }

        var impossibleOperationPrefix = belowMemory
        var impossibleCounts = try XCTUnwrap(
            impossibleOperationPrefix["operation_counts"]
                as? [String: Any])
        impossibleCounts["optimizer_update_count"] = 1
        impossibleOperationPrefix["operation_counts"] = impossibleCounts
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                impossibleOperationPrefix))

        var unsynchronizedPhasePrefix = belowMemory
        var unsynchronizedCounts = try XCTUnwrap(
            unsynchronizedPhasePrefix["operation_counts"]
                as? [String: Any])
        unsynchronizedCounts["resource_measurement_synchronize_count"] = 0
        unsynchronizedPhasePrefix["operation_counts"] = unsynchronizedCounts
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                unsynchronizedPhasePrefix))
        var impossibleCheckedEvaluationPrefix = belowMemory
        var impossibleCheckedCounts = try XCTUnwrap(
            impossibleCheckedEvaluationPrefix["operation_counts"]
                as? [String: Any])
        impossibleCheckedCounts["resource_measurement_checked_eval_count"] = 1
        impossibleCheckedEvaluationPrefix["operation_counts"] =
            impossibleCheckedCounts
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                impossibleCheckedEvaluationPrefix))

        var uncountedCheckpointPrefix = belowMemory
        let maximalCheckpoints = try XCTUnwrap(
            maximal["checkpoint_and_comparator_bindings"]
                as? [[String: Any]])
        uncountedCheckpointPrefix["checkpoint_and_comparator_bindings"] =
            [maximalCheckpoints[0]]
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                uncountedCheckpointPrefix))

        var earlyMeasuredDomain = belowMemory
        let maximalDomains = try XCTUnwrap(
            maximal["comparison_domain_results"] as? [[String: Any]])
        var earlyDomains = try XCTUnwrap(
            earlyMeasuredDomain["comparison_domain_results"]
                as? [[String: Any]])
        earlyDomains[0] = maximalDomains[0]
        earlyMeasuredDomain["comparison_domain_results"] = earlyDomains
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                earlyMeasuredDomain))

        var fullDomainEarlyResource = belowMemory
        fullDomainEarlyResource["comparison_domain_results"] =
            maximal["comparison_domain_results"]
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                fullDomainEarlyResource))

        var fullTopologyIntegrity = maximal
        fullTopologyIntegrity["terminal_status"] = "ABSTAIN_INTEGRITY"
        var integrityDomains = try XCTUnwrap(
            fullTopologyIntegrity["comparison_domain_results"]
                as? [[String: Any]])
        let nullableDomainKeys = [
            "catalog_sha256", "left_total_bytes", "left_sha256",
            "right_total_bytes", "right_sha256", "exact",
            "first_mismatch_path", "first_mismatch_expected_binding",
            "first_mismatch_observed_binding", "tensor_catalog_projection",
        ]
        for key in nullableDomainKeys {
            integrityDomains[17][key] = NSNull()
        }
        fullTopologyIntegrity["comparison_domain_results"] = integrityDomains
        fullTopologyIntegrity["first_mismatch_if_any"] = [
            "availability": "unavailable",
            "domain_id": "cursor_and_snapshot_boundary_zero_state",
            "path": "terminal_data_cursor",
            "expected_binding": zeroSHA,
            "observed_binding": oneSHA,
        ]
        XCTAssertNoThrow(
            try execution.canonicalPublicReceiptDataV1(
                fullTopologyIntegrity),
            "ABSTAIN_INTEGRITY full topology drift")
        var nonmemberIntegrity = fullTopologyIntegrity
        var integrityMismatch = try XCTUnwrap(
            nonmemberIntegrity["first_mismatch_if_any"] as? [String: Any])
        integrityMismatch["path"] = "unexpected_cursor_member"
        nonmemberIntegrity["first_mismatch_if_any"] = integrityMismatch
        XCTAssertThrowsError(
            try execution.canonicalPublicReceiptDataV1(
                nonmemberIntegrity))
    }

    private func validateOwnedAndCoordinatedSourceTopology(
        authority:
            PrimeNativeDecoderNative300MTrajectoryCheckpointExecutionAuthorityV1,
        execution:
            PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution
                .Type
    ) throws {
        var repositoryRoot = URL(fileURLWithPath: #filePath)
        for _ in 0 ..< 5 {
            repositoryRoot.deleteLastPathComponent()
        }
        let exactPaths = authority.successor.exactChangedPaths.map(\.path)
        XCTAssertEqual(exactPaths.count, 9)

        let manifestSource = try source(
            at: repositoryRoot,
            relativePath:
                "Tests/PrimeNativeDecoderTrainingValidation/Package.swift")
        // The retired hosted surface still has exactly three products and
        // targets. Remove only the explicitly named current-local additions
        // before checking that historical topology.
        let currentLocalProduct =
            "        .executable(name: \"PrimeNativeDecoderCurrentLocal300MExecution\", targets: [\"PrimeNativeDecoderCurrentLocal300MExecution\"]),\n"
        let currentLocalTarget = try sourceSlice(
            manifestSource,
            from: "        .executableTarget(\n            name: \"PrimeNativeDecoderCurrentLocal300MExecution\",",
            to: "        .executableTarget(\n            name:\n                \"PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution\",")
        XCTAssertEqual(occurrences(of: currentLocalProduct, in: manifestSource), 1)
        XCTAssertEqual(occurrences(of: ".executableTarget(", in: currentLocalTarget), 1)
        XCTAssertTrue(criticalStaticContractHolds(
            in: currentLocalTarget,
            requiredAnchors: [
                ".product(name: \"PrimeCore\", package: \"ergentics-prime\")",
                ".product(name: \"PrimeNativeDecoderRuntime\", package: \"ergentics-prime\")",
                ".product(name: \"PrimeNativeDecoderTraining\", package: \"ergentics-prime\")",
                "path: \"Sources/PrimeNativeDecoderCurrentLocal300MExecution\"",
            ]))
        let historicalManifest = manifestSource
            .replacingOccurrences(of: currentLocalProduct, with: "")
            .replacingOccurrences(of: currentLocalTarget, with: "")
        XCTAssertFalse(historicalManifest.contains("PrimeNativeDecoderCurrentLocal300MExecution"))
        XCTAssertEqual(occurrences(of: ".executable(", in: historicalManifest), 3)
        XCTAssertEqual(occurrences(of: ".executableTarget(", in: historicalManifest), 3)
        XCTAssertEqual(occurrences(of: ".testTarget(", in: manifestSource), 1)
        XCTAssertEqual(
            occurrences(
                of:
                    "PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution",
                in: manifestSource),
            4)
        XCTAssertEqual(
            occurrences(
                of: "d37885a278f1c37484a94d0f401a418735e66519",
                in: manifestSource),
            1)

        let mainSource = try source(
            at: repositoryRoot,
            relativePath:
                "Tests/PrimeNativeDecoderTrainingValidation/Sources/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution/main.swift")
        XCTAssertEqual(
            importLines(in: mainSource),
            ["import Foundation", "import PrimeNativeDecoderTraining"])
        XCTAssertEqual(
            occurrences(of: ".runSupervisor()", in: mainSource),
            1)

        let checkpointSource = try source(
            at: repositoryRoot,
            relativePath:
                "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderNative300MTrajectoryCheckpointV1.swift")
        let checkpointAnchors = [
            "firstPaths == secondPaths",
            "firstPaths == modelPaths",
            "expectedParameterPathCount = 218",
            "array.shape == parameter.shape",
            "array.dtype == parameter.dtype",
            "array.size == parameter.size",
            "array.nbytes == parameter.nbytes",
            "partialPrecommitLeavesAreAuthoritative: false",
            "finalCommitManifestIsExclusiveCommitPoint: true",
            "case partialPublication(",
            "publishedPrecommitLeafBindings:",
            "knownLeafRelativePaths:",
            "finalCommitPublished: false",
            "loadRequiresExternallySuppliedExactCommitBinding: true",
        ]
        XCTAssertTrue(
            criticalStaticContractHolds(
                in: checkpointSource,
                requiredAnchors: checkpointAnchors))
        for anchor in checkpointAnchors {
            XCTAssertFalse(
                criticalStaticContractHolds(
                    in: replacingEvery(
                        anchor,
                        with: "MUTATED",
                        in: checkpointSource),
                    requiredAnchors: checkpointAnchors),
                anchor)
        }
        let committedPublicationCleanupBlock = try sourceSlice(
            checkpointSource,
            from: "    public static func publish(",
            to: "    public static func verify(")
        let precommitRecoveryDispatchAnchors = [
            "func rethrowAfterPrecommitRecovery(",
            ") throws -> Never {",
            "recoverCleanupLeafAfterPublicationFailure(",
            "priorLeaves: publishedPrecommit",
            "publishedPrecommit.append(recovered)",
            "publishedPrecommit.removeAll(keepingCapacity: false)",
            "throw publicationError",
            "let weights: PrimeNativeDecoderCheckpointExternalBindingV2",
            "weights = try PrimeNativeDecoderCheckpointCodecV2",
            "leafRole: .weightsV2",
            "publicationOrdinal: 1",
            "publishedPrecommit.append(weightsLeaf)",
            "let momentsArtifact: PrimeArtifactBinding",
            "momentsArtifact = try publishMoments(",
            "leafRole: .optimizerMoments",
            "publicationOrdinal: 2",
            "publishedPrecommit.append(momentsLeaf)",
            "let controlArtifact: PrimeArtifactBinding",
            "controlArtifact = try root.publishGeneratedFile(",
            "leafRole: .controlStateManifest",
            "publicationOrdinal: 3",
            "publishedPrecommit.append(controlLeaf)",
            "let precommit = [weightsLeaf, momentsLeaf, controlLeaf]",
        ]
        XCTAssertTrue(anchorsAppearInStrictOrder(
            precommitRecoveryDispatchAnchors,
            in: committedPublicationCleanupBlock))
        XCTAssertEqual(
            occurrences(
                of: "try rethrowAfterPrecommitRecovery(",
                in: committedPublicationCleanupBlock),
            3)
        XCTAssertEqual(
            occurrences(
                of: "publishedPrecommit.append(recovered)",
                in: committedPublicationCleanupBlock),
            1)
        let precommitRecoveryDispatchBlock = try sourceSlice(
            committedPublicationCleanupBlock,
            from: "        func rethrowAfterPrecommitRecovery(",
            to:
                "        do {\n            try root.requirePrivateRootMode()")
        XCTAssertFalse(precommitRecoveryDispatchBlock.contains("return"))
        XCTAssertFalse(precommitRecoveryDispatchBlock.contains("counter"))
        XCTAssertFalse(precommitRecoveryDispatchBlock.contains("load"))
        XCTAssertFalse(precommitRecoveryDispatchBlock.contains(
            "trajectoryCheckpointProjection"))
        XCTAssertFalse(precommitRecoveryDispatchBlock.contains(
            "committedBinding"))

        let precommitRecoveryHelperBlock = try sourceSlice(
            checkpointSource,
            from:
                "    private static func recoverCleanupLeafAfterPublicationFailure(",
            to: "    public static func knownLeafRelativePaths(")
        let precommitRecoveryHelperAnchors = [
            "let orderedRoles =",
            "PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1.allCases",
            "publicationOrdinal >= 1",
            "publicationOrdinal <= orderedRoles.count",
            "leafRole == orderedRoles[publicationOrdinal - 1]",
            "priorLeaves.map(\\.role)",
            "Array(orderedRoles.prefix(publicationOrdinal - 1))",
            "priorLeaves.map(\\.publicationOrdinal)",
            "Array(1 ..< publicationOrdinal)",
            "maximumByteCount > 0",
            "switch leafRole",
            "case .weightsV2: fileName = weightsFileName",
            "case .optimizerMoments: fileName = optimizerMomentsFileName",
            "case .controlStateManifest: fileName = controlStateFileName",
            "case .commitManifest: fileName = commitManifestFileName",
            "let relativePath = path(directory, fileName)",
            "let expectedPriorNames = priorLeaves.map",
            "guard priorLeaves.enumerated().allSatisfy",
            "leaf.artifact.relativePath",
            "weightsFileName, optimizerMomentsFileName",
            "controlStateFileName, commitManifestFileName",
            "leaf.artifact.purpose == .immutableData",
            "try root.requirePrivateRootMode()",
            "O_RDONLY | O_DIRECTORY | O_NOFOLLOW | O_CLOEXEC",
            "let rootIdentity = try root.verifiedRootIdentity()",
            "let beforeNames = try enumerateDescriptorNames(directoryDescriptor)",
            "beforeNames == expectedPriorNames.sorted(by: rawUTF8Less)",
            "try root.requireAbsent(at: relativePath)",
            "return nil",
            "let expectedPresentNames = (expectedPriorNames + [fileName]).sorted",
            "guard beforeNames == expectedPresentNames else",
            "O_RDONLY | O_NOFOLLOW | O_CLOEXEC",
            "fileBefore.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)",
            "fileBefore.st_mode & mode_t(0o7777) == mode_t(0o444)",
            "fileBefore.st_uid == rootIdentity.ownerUserID",
            "fileBefore.st_gid == rootIdentity.ownerGroupID",
            "fileBefore.st_nlink == 1",
            "fileBefore.st_size > 0",
            "UInt64(fileBefore.st_size) <= maximumByteCount",
            "let byteCount = UInt64(fileBefore.st_size)",
            "sha256: try descriptorSHA256(",
            "byteCount: byteCount",
            "purpose: .immutableData",
            "_ = try root.verify(binding)",
            "fstatat(",
            "AT_SYMLINK_NOFOLLOW",
            "fileBefore.st_dev == fileAfter.st_dev",
            "fileBefore.st_dev == namedAfter.st_dev",
            "fileBefore.st_ino == fileAfter.st_ino",
            "fileBefore.st_ino == namedAfter.st_ino",
            "fileBefore.st_nlink == fileAfter.st_nlink",
            "fileBefore.st_nlink == namedAfter.st_nlink",
            "fileBefore.st_size == fileAfter.st_size",
            "fileBefore.st_size == namedAfter.st_size",
            "try enumerateDescriptorNames(directoryDescriptor)",
            "== expectedPresentNames",
            "try root.verifiedRootIdentity() == rootIdentity",
            "role: leafRole",
            "publicationOrdinal: publicationOrdinal",
            "artifact: binding",
        ]
        XCTAssertTrue(anchorsAppearInStrictOrder(
            precommitRecoveryHelperAnchors,
            in: precommitRecoveryHelperBlock))
        XCTAssertEqual(
            occurrences(
                of: "return nil",
                in: precommitRecoveryHelperBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of: "_ = try root.verify(binding)",
                in: precommitRecoveryHelperBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of: "descriptorSHA256(",
                in: precommitRecoveryHelperBlock),
            1)
        let descriptorDigestBlock = try sourceSlice(
            checkpointSource,
            from: "    private static func descriptorSHA256(",
            to: "    public static func validateExternalBinding(")
        let descriptorDigestAnchors = [
            "var hasher = SHA256()",
            "var buffer = [UInt8](repeating: 0, count: 64 * 1024)",
            "while offset < byteCount",
            "min(UInt64(buffer.count), byteCount - offset)",
            "try trajectoryPreadExactlyV1(",
            "hasher.update(data: Data(buffer.prefix(count)))",
            "offset += UInt64(count)",
            "trajectoryDigestHexV1(hasher.finalize())",
        ]
        XCTAssertTrue(anchorsAppearInStrictOrder(
            descriptorDigestAnchors,
            in: descriptorDigestBlock))

        let quarantineValidationBlock = try sourceSlice(
            checkpointSource,
            from: "    public static func cleanupKnownPublishedSets(",
            to: "    private static func enumerateDescriptorNames(")
        let contiguousQuarantineAnchors = [
            "!quarantine.finalCommitPublished",
            "!quarantine.publishedPrecommitLeafBindings.isEmpty",
            "quarantine.publishedPrecommitLeafBindings.count < 4",
            "quarantine.publishedPrecommitLeafBindings",
            ".map(\\.role)",
            "PrimeNativeDecoderTrajectoryCheckpointLeafRoleV1",
            ".allCases.prefix(",
            "quarantine.publishedPrecommitLeafBindings",
            ".map(\\.publicationOrdinal)",
            "Array(",
            "1 ... quarantine",
            ".publishedPrecommitLeafBindings.count)",
            "leaf.artifact.relativePath",
            "== quarantine.knownLeafRelativePaths[index]",
            "leaf.artifact.purpose == .immutableData",
            "isLowercaseSHA256(leaf.artifact.sha256)",
        ]
        XCTAssertTrue(anchorsAppearInStrictOrder(
            contiguousQuarantineAnchors,
            in: quarantineValidationBlock))
        for anchor in precommitRecoveryDispatchAnchors
            + precommitRecoveryHelperAnchors
            + descriptorDigestAnchors
            + contiguousQuarantineAnchors
        {
            XCTAssertFalse(
                criticalStaticContractHolds(
                    in: replacingEvery(
                        anchor,
                        with: "MUTATED",
                        in: checkpointSource),
                    requiredAnchors:
                        precommitRecoveryDispatchAnchors
                        + precommitRecoveryHelperAnchors
                        + descriptorDigestAnchors
                        + contiguousQuarantineAnchors),
                anchor)
        }
        let committedPublicationRecoveryAnchors = [
            "var committedBinding:",
            "let commitRelativePath = path(",
            "let expectedCommitArtifact = PrimeArtifactBinding(",
            "sha256: PrimeSHA256.hexDigest(of: commitBytes)",
            "byteCount: UInt64(commitBytes.count)",
            "artifact: expectedCommitArtifact",
            "let result =",
            "try validateExternalBinding(result)",
            "committedBinding = result",
            "let commitArtifact = try root.publishCanonicalExclusively(",
            "at: commitRelativePath)",
            "guard commitArtifact == expectedCommitArtifact else",
            "commitPublished = true",
            "let publicationError = error",
            "if (try? root.verify(expectedCommitArtifact)) != nil",
            "commitPublished = true",
            ".committedPublicationRequiresCleanup(result)",
            "try root.requireAbsent(at: commitRelativePath)",
            "publishedPrecommit.removeAll(keepingCapacity: false)",
            "throw publicationError",
        ]
        let committedPublicationCleanupAnchors = [
            "_ = try root.captureTrustedInventory(",
            ".recaptureAndValidateUnchanged()",
            "if commitPublished, let committedBinding",
            ".committedPublicationRequiresCleanup(committedBinding)",
        ]
        XCTAssertTrue(anchorsAppearInStrictOrder(
            committedPublicationRecoveryAnchors
                + committedPublicationCleanupAnchors,
            in: committedPublicationCleanupBlock))
        XCTAssertEqual(
            occurrences(
                of: "root.verify(expectedCommitArtifact)",
                in: committedPublicationCleanupBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of: "root.requireAbsent(at: commitRelativePath)",
                in: committedPublicationCleanupBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of: "guard commitArtifact == expectedCommitArtifact else",
                in: committedPublicationCleanupBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of: "publishedPrecommit.removeAll(keepingCapacity: false)",
                in: committedPublicationCleanupBlock),
            2)
        XCTAssertEqual(
            occurrences(
                of: ".committedPublicationRequiresCleanup(result)",
                in: committedPublicationCleanupBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of:
                    ".committedPublicationRequiresCleanup(committedBinding)",
                in: committedPublicationCleanupBlock),
            4)
        let recoveredCommitProof = try XCTUnwrap(
            committedPublicationCleanupBlock.range(
                of: "root.verify(expectedCommitArtifact)")?.lowerBound)
        let exactAbsenceProof = try XCTUnwrap(
            committedPublicationCleanupBlock.range(
                of: "root.requireAbsent(at: commitRelativePath)")?.lowerBound)
        let unknownInventorySuppression = try XCTUnwrap(
            committedPublicationCleanupBlock.range(
                of:
                    "publishedPrecommit.removeAll(keepingCapacity: false)",
                range:
                    exactAbsenceProof
                    ..< committedPublicationCleanupBlock.endIndex)?
                .lowerBound)
        let partialQuarantine = try XCTUnwrap(
            committedPublicationCleanupBlock.range(
                of: "throw partialPublication(",
                range:
                    exactAbsenceProof
                    ..< committedPublicationCleanupBlock.endIndex)?
                .lowerBound)
        XCTAssertLessThan(recoveredCommitProof, exactAbsenceProof)
        XCTAssertLessThan(exactAbsenceProof, unknownInventorySuppression)
        XCTAssertLessThan(unknownInventorySuppression, partialQuarantine)
        for anchor in committedPublicationRecoveryAnchors
            + committedPublicationCleanupAnchors
        {
            XCTAssertFalse(
                criticalStaticContractHolds(
                    in: replacingEvery(
                        anchor,
                        with: "MUTATED",
                        in: committedPublicationCleanupBlock),
                    requiredAnchors:
                        committedPublicationRecoveryAnchors
                        + committedPublicationCleanupAnchors),
                anchor)
        }
        XCTAssertEqual(
            occurrences(
                of: "MLX.loadArraysAndMetadata",
                in: checkpointSource),
            1)
        XCTAssertEqual(
            occurrences(of: "checkedEval(", in: checkpointSource),
            0)
        let neutralMomentLoadBlock = try sourceSlice(
            checkpointSource,
            from: "    public static func loadNeutralMomentCatalog(",
            to: "    public static func validateExternalBinding(")
        XCTAssertEqual(
            occurrences(
                of: "MLX.loadArraysAndMetadata",
                in: neutralMomentLoadBlock),
            1)
        let momentPublicationBlock = try sourceSlice(
            checkpointSource,
            from: "    private static func publishMoments(",
            to: "    private static func makeMomentManifest(")
        XCTAssertEqual(
            occurrences(
                of: "MLX.loadArraysAndMetadata",
                in: momentPublicationBlock),
            0)
        let streamingComparatorBlock = try sourceSlice(
            checkpointSource,
            from:
                "    public static func comparePrivateComparatorsStreaming(",
            to: "    private static func compareSafetensorsStreaming(")
        XCTAssertEqual(
            occurrences(of: "try verify(root: root", in: streamingComparatorBlock),
            4)
        XCTAssertEqual(
            occurrences(
                of: "let weights = try compareSafetensorsStreaming(",
                in: streamingComparatorBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of: "let firstMoments = try compareSafetensorsStreaming(",
                in: streamingComparatorBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of: "let secondMoments = try compareSafetensorsStreaming(",
                in: streamingComparatorBlock),
            1)
        XCTAssertEqual(
            occurrences(of: "compareComparatorControls(", in: streamingComparatorBlock),
            1)
        XCTAssertEqual(
            occurrences(
                of: "MLX.loadArraysAndMetadata",
                in: streamingComparatorBlock),
            0)
        let descriptorStreamingBlock = try sourceSlice(
            checkpointSource,
            from: "    private static func compareSafetensorsStreaming(",
            to: "    static func compareComparatorControls(")
        let descriptorStreamingAnchors = [
            "withVerifiedArtifactDescriptor(leftArtifact)",
            "withVerifiedArtifactDescriptor(rightArtifact)",
            "let chunkByteCount = 64 * 1024",
            "for (left, right) in zip(leftSorted, rightSorted)",
            "try trajectoryPreadExactlyV1(",
            "exact = exact && leftData == rightData",
            "leftTensor.update(data: leftData)",
            "rightTensor.update(data: rightData)",
            "leftLogical.update(data: leftData)",
            "rightLogical.update(data: rightData)",
        ]
        XCTAssertTrue(
            criticalStaticContractHolds(
                in: descriptorStreamingBlock,
                requiredAnchors: descriptorStreamingAnchors))
        XCTAssertEqual(
            occurrences(
                of: "trajectoryPreadExactlyV1(",
                in: descriptorStreamingBlock),
            2)
        XCTAssertEqual(
            occurrences(
                of: "MLX.loadArraysAndMetadata",
                in: descriptorStreamingBlock),
            0)
        XCTAssertFalse(
            descriptorStreamingBlock.contains(
                "containerSHA256 =="))

        let fullExecutionSource = try source(
            at: repositoryRoot,
            relativePath:
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift")
        let currentLocalMarker = "// MARK: - Current-local, retained, three-process science"
        XCTAssertEqual(occurrences(of: currentLocalMarker, in: fullExecutionSource), 1)
        let currentLocalStart = try XCTUnwrap(fullExecutionSource.range(of: currentLocalMarker)?.lowerBound)
        let executionSource = String(fullExecutionSource[..<currentLocalStart])
        let currentLocalSource = String(fullExecutionSource[currentLocalStart...])
        let currentBaseline = try sourceSlice(currentLocalSource,
            from: "    static func runStage7Baseline(", to: "    static func runStage7Resume(")
        let currentResume = try sourceSlice(currentLocalSource,
            from: "    static func runStage7Resume(", to: "    static func retainedArtifactBindings(")
        let currentVerify = try sourceSlice(currentLocalSource,
            from: "    static func verifyRetainedStage7(", to: "private func currentLocalReloadSnapshot(")
        let currentReload = try sourceSlice(currentLocalSource,
            from: "private func currentLocalReloadSnapshot(", to: "private func currentLocalRequireBaselineControl(")
        XCTAssertEqual(occurrences(of: "trajectoryRunUninterruptedClosure(", in: currentBaseline), 1)
        XCTAssertEqual(occurrences(of: "trajectoryRunResumedClosure(", in: currentResume), 1)
        XCTAssertEqual(occurrences(of: "trajectoryBuildCompleteComparisons(", in: currentResume), 1)
        XCTAssertEqual(occurrences(of: ".comparePrivateComparatorsStreaming(", in: currentResume), 1)
        XCTAssertEqual(occurrences(of: ".comparePrivateComparatorsStreaming(", in: currentVerify), 1)
        XCTAssertEqual(occurrences(of: ".comparePrivateComparatorsStreaming(", in: currentLocalSource), 2)
        XCTAssertEqual(occurrences(of: "try checkedEval(", in: currentReload), 1)
        XCTAssertEqual(occurrences(of: "try checkedEval(", in: currentLocalSource), 1)
        for forbidden in ["TrajectoryLauncherBindings(", "runSupervisor(",
                          ".cleanupKnownPublishedSets(", ".beginEphemeralRun(",
                          "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RECEIPT_V1="] {
            XCTAssertFalse(currentLocalSource.contains(forbidden), forbidden)
        }
        let executionAnchors = [
            "public static func runSupervisor()",
            "arguments[1] == workerArgument",
            "arguments[1] == verifierArgument",
            "--frame-descriptor=\\(workerFrameDescriptor)",
            "PrimeMetalDeviceLease.acquire",
            "POSIX_SPAWN_SETPGROUP",
            "POSIX_SPAWN_CLOEXEC_DEFAULT",
            "maximumPrivateCandidateCanonicalByteCount = 262_144",
            "maximumPrivateTerminalCanonicalByteCount = 65_536",
            "maximumFrameChunkByteCount = 16_384",
            "frameReadDeadlineSeconds: UInt64 = 30",
            "workerTimeoutSeconds: UInt64 = 4_800",
            "supervisorTimeoutSeconds: UInt64 = 5_100",
            "terminationGraceSeconds: UInt64 = 10",
            "Set(first.keys) == Set(target.keys)",
            "Set(second.keys) == Set(target.keys)",
            "expectedParameterPathCount",
            "stdout_candidate_then_terminal",
            "candidate_byte_count",
            "candidate_sha256",
            "let pair = zip(leftCatalog.paths, rightCatalog.paths).first(where:",
            "mismatchPath = pair.0.path",
            "trajectorySysctlString(\"kern.osproductversion\")",
            "trajectorySysctlString(\"kern.osversion\")",
            "return product + \"-\" + build",
            "operatingSystemBuild == bindings.operatingSystemBuild",
        ]
        XCTAssertTrue(
            criticalStaticContractHolds(
                in: executionSource,
                requiredAnchors: executionAnchors))
        let committedCleanupCaptureBlock = try sourceSlice(
            executionSource,
            from: "private func trajectoryPublishCheckpoint(",
            to: "private func trajectoryCheckpointProjection(")
        let precommitCleanupCaptureAnchors = [
            "if case let .partialPublication(quarantine) = error",
            "context.quarantines.append(quarantine)",
        ]
        let committedCleanupCaptureAnchors = [
            "if case let .committedPublicationRequiresCleanup(binding) = error",
            "context.cleanupOnlyCommittedBindings.append(binding)",
            "throw error",
        ]
        XCTAssertTrue(anchorsAppearInStrictOrder(
            precommitCleanupCaptureAnchors
                + committedCleanupCaptureAnchors,
            in: committedCleanupCaptureBlock))
        let checkpointFailureCaptureBlock = try sourceSlice(
            committedCleanupCaptureBlock,
            from:
                "    } catch let error as\n        PrimeNativeDecoderNative300MTrajectoryCheckpointV1Error",
            to: "    try context.counter.increment(\"v2_weights_write_count\")")
        XCTAssertTrue(anchorsAppearInStrictOrder(
            precommitCleanupCaptureAnchors
                + committedCleanupCaptureAnchors,
            in: checkpointFailureCaptureBlock))
        XCTAssertFalse(checkpointFailureCaptureBlock.contains(
            "context.counter"))
        XCTAssertFalse(checkpointFailureCaptureBlock.contains(
            "trajectoryCheckpointProjection"))
        XCTAssertFalse(checkpointFailureCaptureBlock.contains(
            "return binding"))
        XCTAssertFalse(checkpointFailureCaptureBlock.contains(
            "baselineBinding"))
        XCTAssertFalse(checkpointFailureCaptureBlock.contains(
            "uninterruptedBinding"))
        XCTAssertFalse(checkpointFailureCaptureBlock.contains(
            "resumedBinding"))
        XCTAssertFalse(committedCleanupCaptureBlock.contains(
            "context.baselineBinding"))
        XCTAssertFalse(committedCleanupCaptureBlock.contains(
            "context.uninterruptedBinding"))
        XCTAssertFalse(committedCleanupCaptureBlock.contains(
            "context.resumedBinding"))
        XCTAssertFalse(committedCleanupCaptureBlock.contains(
            "trajectoryCheckpointProjection"))
        let committedCleanupRetirementAnchors = [
            "let publishedBindings = [",
            "context.baselineBinding",
            "context.uninterruptedBinding",
            "context.resumedBinding",
            "].compactMap { $0 } + context.cleanupOnlyCommittedBindings",
            ".cleanupKnownPublishedSets(",
            "root: artifactRoot, bindings: publishedBindings",
            "quarantines: context.quarantines",
        ]
        XCTAssertTrue(anchorsAppearInStrictOrder(
            committedCleanupRetirementAnchors,
            in: executionSource))
        XCTAssertEqual(
            occurrences(of: "cleanupOnlyCommittedBindings", in: executionSource),
            3)
        XCTAssertEqual(
            occurrences(of: "context.quarantines", in: executionSource),
            4)
        for anchor in precommitCleanupCaptureAnchors
            + committedCleanupCaptureAnchors
            + committedCleanupRetirementAnchors
        {
            XCTAssertFalse(
                criticalStaticContractHolds(
                    in: replacingEvery(
                        anchor,
                        with: "MUTATED",
                        in: executionSource),
                    requiredAnchors:
                        precommitCleanupCaptureAnchors
                        + committedCleanupCaptureAnchors
                        + committedCleanupRetirementAnchors),
                anchor)
        }
        XCTAssertEqual(
            occurrences(
                of:
                    "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_RECEIPT_V1=",
                in: executionSource),
            1)
        XCTAssertFalse(executionSource.contains("exec /usr/bin/printf"))
        XCTAssertFalse(executionSource.contains(" = Process()"))
        XCTAssertEqual(
            occurrences(
                of: "posix_spawnattr_setpgroup(&attributes, 0)",
                in: executionSource),
            2)
        XCTAssertEqual(
            occurrences(of: "POSIX_SPAWN_SETPGROUP", in: executionSource),
            2)
        XCTAssertEqual(
            occurrences(of: "try checkedEval(", in: executionSource),
            6)
        XCTAssertEqual(
            occurrences(
                of:
                    "increment(\"resource_measurement_checked_eval_count\")",
                in: executionSource),
            6)
        let countedStepAndEvaluationGraphs = try sourceSlice(
            executionSource,
            from: "private func trajectoryPerformStepAndEvaluationGraphs(",
            to: "private func trajectoryEvaluationControlBinding(")
        XCTAssertEqual(
            occurrences(
                of: "try checkedEval(",
                in: countedStepAndEvaluationGraphs),
            1)
        XCTAssertEqual(
            occurrences(
                of:
                    "increment(\"resource_measurement_checked_eval_count\")",
                in: countedStepAndEvaluationGraphs),
            1)
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "try trajectoryRecordCompletedForward(context: context)",
                "increment(\"evaluation_forward_pass_count\")",
                "let phaseMaterializationTargets = [",
                "try checkedEval(model, optimizer, phaseMaterializationTargets)",
                "increment(\"resource_measurement_checked_eval_count\")",
            ],
            in: countedStepAndEvaluationGraphs))
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "var rawResult: (MLXArray, ModuleParameters)?",
                "var gradientEntries = rawResult!.1.flattened().sorted",
                "rawResult = nil",
                "let rawGradientDigest: TrajectoryCatalogDigest?",
                "var clippedEntries = [(String, MLXArray)]()",
                "while let (path, gradient) = gradientEntries.popLast()",
                "let materialized = clipped.asData(access: .copy)",
                "clippedEntries.append((path, clipped))",
                "gradientEntries.isEmpty && clippedEntries.count == 218",
                "let clippedGradients = ModuleParameters.unflattened(clippedEntries)",
                "optimizer.update(model: model, gradients: clippedGradients)",
                "let phaseMaterializationTargets = [",
                "try checkedEval(model, optimizer, phaseMaterializationTargets)",
                "let clippedGradientDigest: TrajectoryCatalogDigest?",
            ],
            in: countedStepAndEvaluationGraphs))
        XCTAssertEqual(
            occurrences(
                of: "while let (path, gradient) = gradientEntries.popLast()",
                in: countedStepAndEvaluationGraphs),
            1)
        XCTAssertEqual(
            occurrences(
                of: "ModuleParameters.unflattened(clippedEntries)",
                in: countedStepAndEvaluationGraphs),
            1)
        XCTAssertFalse(countedStepAndEvaluationGraphs.contains(
            "let clippedEntries = gradientEntries.map"))
        XCTAssertFalse(countedStepAndEvaluationGraphs.contains(
            "gradients.flattenedValues()"))
        XCTAssertFalse(countedStepAndEvaluationGraphs.contains(
            "clippedGradients.flattenedValues()"))
        XCTAssertFalse(countedStepAndEvaluationGraphs.contains(
            "MLXArray(data: materialized)"))
        let phaseMaterializationBlock = try sourceSlice(
            countedStepAndEvaluationGraphs,
            from: "let phaseMaterializationTargets = [",
            to:
                "try context.counter.increment(\"resource_measurement_checked_eval_count\")")
        XCTAssertFalse(phaseMaterializationBlock.contains("gradientEntries"))
        XCTAssertFalse(phaseMaterializationBlock.contains("clippedEntries"))
        XCTAssertFalse(phaseMaterializationBlock.contains("clippedGradients"))
        let countedStepAndEvaluationWrapper = try sourceSlice(
            executionSource,
            from: "private func trajectoryRunStepAndEvaluation(",
            to: "private func trajectoryRNGDomains(")
        XCTAssertEqual(
            occurrences(
                of: "trajectoryPerformStepAndEvaluationGraphs(",
                in: countedStepAndEvaluationWrapper),
            1)
        XCTAssertEqual(
            occurrences(
                of: "increment(\"gradient_catalog_release_count\")",
                in: countedStepAndEvaluationWrapper),
            1)
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "trajectoryPerformStepAndEvaluationGraphs(",
                "increment(\"gradient_catalog_release_count\")",
                "return evidence",
            ],
            in: countedStepAndEvaluationWrapper))
        XCTAssertEqual(
            occurrences(
                of: "trajectoryRunStepAndEvaluation(",
                in: executionSource),
            4)
        let uninterruptedClosure = try sourceSlice(
            executionSource,
            from: "private func trajectoryRunUninterruptedClosure(",
            to: "private func trajectoryRunResumedClosure(")
        XCTAssertEqual(
            occurrences(
                of: "trajectoryRunStepAndEvaluation(",
                in: uninterruptedClosure),
            2)
        XCTAssertEqual(
            occurrences(of: "try checkedEval(", in: uninterruptedClosure),
            3)
        XCTAssertEqual(
            occurrences(
                of:
                    "increment(\"resource_measurement_checked_eval_count\")",
                in: uninterruptedClosure),
            3)
        let resumedClosure = try sourceSlice(
            executionSource,
            from: "private func trajectoryRunResumedClosure(",
            to: "private func trajectoryExecuteWorker(")
        XCTAssertEqual(
            occurrences(
                of: "trajectoryRunStepAndEvaluation(",
                in: resumedClosure),
            1)
        XCTAssertEqual(
            occurrences(of: "try checkedEval(", in: resumedClosure),
            2)
        XCTAssertEqual(
            occurrences(
                of:
                    "increment(\"resource_measurement_checked_eval_count\")",
                in: resumedClosure),
            2)

        let successfulScienceClosure = try sourceSlice(
            executionSource,
            from: "        do {\n            let uninterrupted = try trajectoryRunUninterruptedClosure(",
            to: "        } catch {")
        XCTAssertEqual(
            occurrences(of: "MLX.Memory.clearCache()", in: successfulScienceClosure),
            2)
        XCTAssertEqual(
            occurrences(
                of: ".comparePrivateComparatorsStreaming(",
                in: successfulScienceClosure),
            1)
        XCTAssertEqual(
            occurrences(
                of: "trajectoryBuildCompleteComparisons(",
                in: successfulScienceClosure),
            1)
        XCTAssertEqual(
            occurrences(
                of: ".cleanupKnownPublishedSets(",
                in: successfulScienceClosure),
            1)
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "let uninterrupted = try trajectoryRunUninterruptedClosure(",
                "MLX.Memory.clearCache()",
                "post_uninterrupted_state_deallocation_and_cache_clear",
                "let resumed = try trajectoryRunResumedClosure(",
                "MLX.Memory.clearCache()",
                ".comparePrivateComparatorsStreaming(",
                "trajectoryBuildCompleteComparisons(",
                ".cleanupKnownPublishedSets(",
                "context.cleanupEvidence = cleanup",
                "post_streaming_compare_artifact_cleanup_and_absence",
                "try trajectoryObserveResourcePhase(\"postflight\"",
            ],
            in: successfulScienceClosure))
        XCTAssertEqual(
            occurrences(
                of: ".comparePrivateComparatorsStreaming(",
                in: executionSource),
            1)
        XCTAssertEqual(
            occurrences(of: "MLX.loadArraysAndMetadata", in: executionSource),
            0)
        XCTAssertEqual(
            occurrences(
                of: "checkpointCount == knownLeafCount / 4",
                in: executionSource),
            2)
        XCTAssertEqual(
            occurrences(
                of: "(knownLeafCount - 1) / 4",
                in: executionSource),
            2)
        let completeComparisonBuilder = try sourceSlice(
            executionSource,
            from: "private func trajectoryBuildCompleteComparisons(",
            to: "private struct TrajectoryUninterruptedClosure")
        XCTAssertEqual(
            occurrences(
                of: "let successorSemanticExact = results[5...].allSatisfy",
                in: completeComparisonBuilder),
            1)
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "let successorSemanticExact = results[5...].allSatisfy",
                "let firstControlMismatch = try trajectoryFirstComparatorControlMismatchField(",
                "if successorSemanticExact {",
                "streamed.controlSemanticExact",
                "streamed.firstControlMismatchPath == nil",
                "firstControlMismatch == nil",
                "} else {",
                "let domainID = Execution",
                ".comparatorControlFieldToDomainID[firstControlMismatch]",
                "!streamed.controlSemanticExact",
                "streamed.firstControlMismatchPath == firstControlMismatch",
                "trajectoryExactBool(results[domainIndex][\"exact\"]) == false",
            ],
            in: completeComparisonBuilder))
        let resourceObservationBlock = try sourceSlice(
            executionSource,
            from: "private func trajectoryObserveResourcePhase(",
            to: "private final class TrajectoryForwardCapture")
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "context.phases.append([",
                "let scienceTimeout = Execution.workerTimeoutSeconds",
                ".multipliedReportingOverflow(by: 1_000_000_000)",
                "if elapsed.partialValue >= scienceTimeout.partialValue",
                "TrajectoryExecutionError.classified(",
                "\"ABSTAIN_RESOURCE\"",
                "\"worker_or_supervisor_timeout_with_complete_integrity_cleanup_and_verifier_closure\"",
            ],
            in: resourceObservationBlock))
        let timeoutEvidenceBlock = try sourceSlice(
            executionSource,
            from: "private func trajectoryPositiveResourceMismatch(",
            to: "private func trajectoryExecuteWorker(")
        XCTAssertTrue(criticalStaticContractHolds(
            in: timeoutEvidenceBlock,
            requiredAnchors: [
                "classification == \"ABSTAIN_RESOURCE\"",
                "elapsed >= 4_800_000_000_000",
                "timeout_role=worker;deadline_seconds=4800;elapsed_nanoseconds=\\(elapsed);contained=true;cleanup_absence=true",
                "\"path\": \"resource_phases[last].cumulative_elapsed_nanoseconds\"",
            ]))
        let resourceClosureBlock = try sourceSlice(
            executionSource,
            from: "        } catch {\n            let originalError = error",
            to: "private func trajectoryRunWorkerProcess(workerEpoch: UInt64)")
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "let originalError = error",
                "if let cleanupEvidence = context.cleanupEvidence",
                "try artifactRoot.requireEmpty()",
                "cleanup = trajectoryCleanupDictionary(cleanupEvidence)",
                "else if !publishedBindings.isEmpty",
                ".cleanupKnownPublishedSets(",
                "trajectoryPositiveResourceMismatch(",
                "trajectoryPostflightIdentityEqual(",
                "status: \"ABSTAIN_RESOURCE\"",
                "mismatch: mismatch, cleanup: cleanup",
            ],
            in: resourceClosureBlock))
        XCTAssertTrue(resourceClosureBlock.contains(
            "safeTimeout\n                    || (context.phases.count < 12"))
        let supervisorProcessBlock = try sourceSlice(
            executionSource,
            from: "private func trajectoryRunSupervisorProcess(",
            to: "private func trajectoryValidCandidateMetallib(")
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "let workerScienceDeadline = try trajectoryDeadline(",
                "afterSeconds: Execution.workerTimeoutSeconds",
                "let workerClosureDeadline = supervisorDeadline.partialValue",
                "workerScienceDeadline < workerClosureDeadline",
                "firstByteDeadline: workerClosureDeadline",
                "absoluteDeadline: workerClosureDeadline",
                "let workerWait = try trajectoryWaitForProcess(",
                "absoluteDeadline: workerClosureDeadline",
                "trajectoryValidatePrivateCandidate(",
                "lease.release()",
                "trajectoryRunVerifierFromSupervisor(",
                "trajectoryValidatePrivateTerminal(",
                "maximumPrivateCandidateCanonicalByteCount",
                "maximumPrivateTerminalCanonicalByteCount",
                "_exit(0)",
            ],
            in: supervisorProcessBlock))
        XCTAssertEqual(
            occurrences(
                of: "workerScienceDeadline",
                in: supervisorProcessBlock),
            3)
        XCTAssertFalse(supervisorProcessBlock.contains(
            "firstByteDeadline: workerScienceDeadline"))
        XCTAssertFalse(supervisorProcessBlock.contains(
            "absoluteDeadline: workerScienceDeadline"))
        let privateFrameReaderBlock = try sourceSlice(
            executionSource,
            from: "private func trajectoryReadFrame(",
            to: "private func trajectoryRequireFrameEOF(")
        XCTAssertTrue(privateFrameReaderBlock.contains(
            "let frameDeadline = min("))
        XCTAssertTrue(privateFrameReaderBlock.contains(
            "trajectoryDeadline(afterSeconds: Execution.frameReadDeadlineSeconds)"))
        let operatingSystemBuildObservation = try sourceSlice(
            executionSource,
            from: "private func trajectoryOperatingSystemBuild()",
            to: "private func trajectoryObservedEnvironment(")
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "trajectorySysctlString(\"kern.osproductversion\")",
                "trajectorySysctlString(\"kern.osversion\")",
                "return product + \"-\" + build",
            ],
            in: operatingSystemBuildObservation))
        let observedEnvironmentBlock = try sourceSlice(
            executionSource,
            from: "private func trajectoryObservedEnvironment(",
            to: "private func trajectoryDeviceDictionary(")
        XCTAssertTrue(observedEnvironmentBlock.contains(
            "operatingSystemBuild == bindings.operatingSystemBuild"))
        XCTAssertEqual(
            occurrences(
                of:
                    "UInt64(UInt32(bitPattern: filesystem.f_fsid.val.0))",
                in: executionSource),
            1)
        XCTAssertEqual(
            occurrences(
                of:
                    "UInt64(UInt32(bitPattern: filesystem.f_fsid.val.1))",
                in: executionSource),
            1)
        XCTAssertFalse(executionSource.contains(
            "UInt64(bitPattern: Int64(filesystem.f_fsid"))
        let executionDescriptorValidator = try sourceSlice(
            executionSource,
            from: "private func trajectoryValidPublicDescriptor(",
            to: "private func trajectoryPublicParentStable(")
        XCTAssertTrue(
            executionDescriptorValidator.contains(
                "Set(xattrs).isSubset(of: trajectoryAllowedXattrs)"))
        XCTAssertTrue(
            executionDescriptorValidator.contains(
                "parent ? true : nlink == 1"))
        let executionParentStability = try sourceSlice(
            executionSource,
            from: "private func trajectoryPublicParentStable(",
            to: "private func trajectoryPublicLeafStable(")
        XCTAssertFalse(executionParentStability.contains("observed_nlink"))

        let launcherSource = try source(
            at: repositoryRoot,
            relativePath:
                ".github/scripts/prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution.sh")
        XCTAssertTrue(launcherSource.hasPrefix("#!/usr/bin/env bash\n"))

        let workflowSource = try source(
            at: repositoryRoot,
            relativePath:
                ".github/workflows/prime-active-root-quarantine.yml")
        // The spent hosted Stage-7 job is retired. Its launcher below stays
        // checked as historical source; the current local process route does
        // not reactivate or impersonate that hosted execution.
        let jobsStart = try XCTUnwrap(workflowSource.range(of: "jobs:\n")?.upperBound)
        let jobLines = workflowSource[jobsStart...].split(separator: "\n").map(String.init).filter {
            $0.hasPrefix("  ") && !$0.hasPrefix("   ") && $0.hasSuffix(":")
        }
        XCTAssertEqual(jobLines, ["  active-root:", "  trusted-main-compile:"])
        let activeRootJob = try sourceSlice(workflowSource,
            from: "  active-root:\n", to: "  trusted-main-compile:\n")
        let trustedMainCompileStart = try XCTUnwrap(workflowSource.range(of: "  trusted-main-compile:\n")?.lowerBound)
        let trustedMainCompileJob = String(workflowSource[trustedMainCompileStart...])
        XCTAssertEqual(occurrences(of: "    steps:", in: workflowSource), 2)
        XCTAssertEqual(occurrences(of: "      - name:", in: activeRootJob), 5)
        XCTAssertEqual(occurrences(of: "      - name:", in: trustedMainCompileJob), 5)
        XCTAssertFalse(workflowSource.contains("trusted-main-stage7"))
        // Historical explanatory echo text still names the script; its
        // retired command must not be invoked by the current workflow.
        XCTAssertFalse(workflowSource.contains("bash .github/scripts/prime-ci-native-decoder-b-specific-native300m-trajectory-checkpoint-execution.sh"))
        XCTAssertFalse(workflowSource.contains("PrimeNativeDecoderCurrentLocal300MExecution"))
        let retirementGuard = try source(at: repositoryRoot,
            relativePath: ".github/scripts/prime-ci-active-root-quarantine.sh")
        XCTAssertTrue(retirementGuard.contains(
            #"&& "$(grep -Fxc -- '  trusted-main-stage7:' "$workflow_path")" == "0""#))
        XCTAssertTrue(retirementGuard.contains("hosted quarantine workflow retirement job topology changed"))

        let launcherAnchors = [
            "readonly authority_closure_revision=\"300bad298bc9ff6f2752d1409639ff9e99318db6\"",
            "readonly authority_closure_tree=\"d7c57b442e6c9a278b2ab58142ac86cbfa622930\"",
            "readonly authority_closure_first_parent=\"912ca2ab8148255fa588a2a1d336b9dcb1221978\"",
            "readonly authority_closure_second_parent=\"11dd1e6098fba025cae8107284d2c231a9f2ebf8\"",
            "readonly authority_closure_run_id=\"31871108399\"",
            "readonly authority_closure_run_number=\"127\"",
            "readonly authority_closure_run_attempt=\"1\"",
            "readonly authority_closure_check_suite_id=\"86457353564\"",
            "readonly authority_closure_active_job_id=\"94979749298\"",
            "readonly authority_closure_reviewed_job_id=\"94980086476\"",
            "readonly candidate_maximum_byte_count=\"262144\"",
            "readonly terminal_maximum_byte_count=\"65536\"",
            "readonly public_receipt_maximum_byte_count=\"131072\"",
            "readonly maximum_frame_chunk_byte_count=\"16384\"",
            "readonly frame_read_deadline_seconds=\"30\"",
            "readonly worker_timeout_seconds=\"4800\"",
            "readonly supervisor_timeout_seconds=\"5100\"",
            "readonly termination_grace_seconds=\"10\"",
            "readonly external_supervisor_failsafe_seconds=\"5120\"",
            "readonly outer_workflow_timeout_seconds=\"7200\"",
            "readonly maximum_pre_one_shot_setup_seconds=\"1790\"",
            "readonly runner_start_and_finalization_reserve_seconds=\"240\"",
            "readonly maximal_public_receipt_fixture_byte_count=\"54022\"",
            "readonly stage7_job_epoch_path=\"$runner_temp/prime-native-decoder-native300m-trajectory-checkpoint-execution-job.epoch\"",
            "\"trusted-main-stage7\"",
            "stage7_job_epoch_byte_count\" == \"11\"",
            "stage7_job_epoch_seconds\" =~ ^[1-9][0-9]{9}$",
            "stat -f %Lp \"$stage7_job_epoch_path\")\" == \"400\"",
            "pre_one_shot_setup_elapsed_seconds",
            "+ runner_start_and_finalization_reserve_seconds",
            "fail \"Stage-7 setup consumed the one-shot containment budget\"",
            "readonly operating_system_build=\"$(sw_vers -productVersion)-$(sw_vers -buildVersion)\"",
            "readonly supervisor_pid=\"$!\"",
            "exec env \\",
            "sleep \"$external_supervisor_failsafe_seconds\"",
            "descendant_process_groups()",
            "if (pid != root && cursor == root)",
            "capture_descendant_process_groups()",
            "stop_captured_child_process_groups()",
            "supervisor_process_group_id=\"$(",
            "!= \"$supervisor_process_group_id\"",
            "kill -0 \"$supervisor_pid\"",
            "kill -STOP \"$supervisor_pid\"",
            "supervisor_stopped=false",
            "for stop_observation_attempt in 0 1 2 3 4 5 6 7 8 9 10; do",
            "ps -o state= -p \"$supervisor_pid\"",
            "\"$supervisor_observed_state\" =~ ^T",
            "[[ \"$supervisor_stopped\" == true ]] || containment_invalid=1",
            "kill -TERM -- \"-$child_process_group\"",
            "kill -KILL -- \"-$child_process_group\"",
            "kill -TERM \"$supervisor_pid\"",
            "sleep \"$termination_grace_seconds\"",
            "kill -KILL \"$supervisor_pid\"",
            "process_group_exists \"$child_process_group\"",
            "process_group_has_live_process \"$child_process_group\"",
            "+ (5 * termination_grace_seconds)",
            "external_supervisor_failsafe_containment_failed",
            "sole supervisor exceeded its operational timeout",
            "emit_embedded_source_identity_paths()",
            "readonly embedded_source_identity_record_count=\"$(",
            "== \"494\"",
            "jq -jcsS '.' | shasum -a 256",
            "== \"$embedded_source_identity\"",
            "read_private_frame",
            "frame SHA-256 does not match before decode",
            "private frame stream contains trailing bytes",
            "candidate_contract_v1",
            "terminal_contract_v1",
            "public_contract_v1",
            "safely_candidate_contract_v1",
            "safely_terminal_contract_v1",
            "safely_public_contract_v1",
            "def native300_parameter_path:",
            "layers\\\\.(0|[1-9]|1[0-9]|2[0-3])",
            "startswith(\"first_moment.\")",
            "startswith(\"second_moment.\")",
            "else exact_catalog_member_path(",
            "configured_memory_limit_bytes=${candidate_configured_memory_limit_bytes};mlx_peak_bytes=${candidate_last_mlx_peak_bytes};positively_identified_mlx_memory_limit_exhaustion=true",
            "timeout_role=worker;deadline_seconds=${worker_timeout_seconds};elapsed_nanoseconds=${candidate_last_elapsed_nanoseconds};contained=true;cleanup_absence=true",
            "(.resource_phases | length) <= 12",
            "$phase_count >= 1 and $phase_count <= 12",
            "sha256_utf8 'errno=12'",
            "sha256_utf8 'errno=28'",
            ".first_mismatch.path == \"errno\"",
            ".first_failed_guard.errno == 12",
            ".first_failed_guard.errno == 28",
            "== (($known / 4) | floor)",
            "else (($known - 1) / 4) | floor end)",
            "semantic_path_roles_and_path_sha256",
            "raw_absolute_path_present:false",
            "exec /usr/bin/printf '%s\\n' \"$public_line\"",
        ]
        XCTAssertTrue(
            criticalStaticContractHolds(
                in: launcherSource,
                requiredAnchors: launcherAnchors))
        XCTAssertEqual(occurrences(of: "--build-tests", in: launcherSource), 1)
        XCTAssertEqual(
            occurrences(of: "sw_vers -productVersion", in: launcherSource),
            1)
        XCTAssertEqual(
            occurrences(of: "sw_vers -buildVersion", in: launcherSource),
            1)
        XCTAssertEqual(
            occurrences(of: "\"trusted-main-stage7\"", in: launcherSource),
            1)
        XCTAssertFalse(launcherSource.contains("\"trusted-main-compile\""))
        XCTAssertFalse(launcherSource.contains("predecessor_test_logs"))
        XCTAssertFalse(launcherSource.contains("predecessor_receipt_logs"))
        XCTAssertFalse(launcherSource.contains("$active_root_log"))
        XCTAssertEqual(occurrences(of: "--skip-build", in: launcherSource), 1)
        XCTAssertEqual(
            occurrences(of: "--filter \"$contract_filter\"", in: launcherSource),
            1)
        XCTAssertEqual(
            launcherSource.split(separator: "\n").filter {
                $0.trimmingCharacters(in: .whitespaces)
                    == "descendant_process_groups() {"
            }.count,
            1)
        XCTAssertEqual(
            occurrences(
                of: "def native300_parameter_path:",
                in: launcherSource),
            2)
        XCTAssertEqual(
            occurrences(
                of: "== (($known / 4) | floor)",
                in: launcherSource),
            2)
        XCTAssertEqual(
            occurrences(
                of: "else (($known - 1) / 4) | floor end)",
                in: launcherSource),
            2)
        XCTAssertEqual(
            occurrences(
                of: ".cumulative_elapsed_nanoseconds\n                 < 4800000000000",
                in: launcherSource),
            4)
        XCTAssertEqual(
            occurrences(of: ">= 11 then", in: launcherSource),
            2)
        XCTAssertEqual(
            occurrences(
                of: "def phase_dependency_prefix(",
                in: launcherSource),
            2)
        XCTAssertEqual(
            occurrences(
                of: "and phase_dependency_prefix(",
                in: launcherSource),
            2)
        XCTAssertEqual(
            occurrences(
                of: "and (.word0 | uint) and (.word1 | uint)",
                in: launcherSource),
            2)
        XCTAssertEqual(
            occurrences(
                of: "else exact_catalog_member_path(",
                in: launcherSource),
            4)
        XCTAssertEqual(
            occurrences(
                of: "capture_descendant_process_groups()",
                in: launcherSource),
            1)
        XCTAssertEqual(
            occurrences(
                of: "stop_captured_child_process_groups()",
                in: launcherSource),
            1)
        XCTAssertEqual(
            occurrences(
                of: "process_group_has_live_process()",
                in: launcherSource),
            1)
        XCTAssertEqual(
            occurrences(
                of: "capture_descendant_process_groups",
                in: launcherSource),
            6)
        let watchdogSource = try sourceSlice(
            launcherSource,
            from: "(\n    sleep \"$external_supervisor_failsafe_seconds\"",
            to: "readonly supervisor_watchdog_pid=\"$!\"")
        let watchdogOperations = try sourceSlice(
            watchdogSource,
            from:
                "        # Capture once to preserve an existing child group across a possible",
            to: "        [[ \"$containment_invalid\" -eq 0 ]]")
        let supervisorStop = try XCTUnwrap(
            watchdogOperations.range(
                of: "kill -STOP \"$supervisor_pid\"")?.lowerBound)
        let supervisorStoppedProof = try XCTUnwrap(
            watchdogOperations.range(
                of: "[[ \"$supervisor_stopped\" == true ]]")?.lowerBound)
        let postStopDescendantCapture = try XCTUnwrap(
            watchdogOperations.range(
                of:
                    "capture_descendant_process_groups\n        capture_descendant_process_groups")?
                .lowerBound)
        let childStop = try XCTUnwrap(
            watchdogOperations.range(
                of: "stop_captured_child_process_groups")?.lowerBound)
        let childTerm = try XCTUnwrap(
            watchdogOperations.range(
                of: "kill -TERM -- \"-$child_process_group\"")?.lowerBound)
        let childKill = try XCTUnwrap(
            watchdogOperations.range(
                of: "kill -KILL -- \"-$child_process_group\"")?.lowerBound)
        let supervisorTerm = try XCTUnwrap(
            watchdogOperations.range(
                of: "kill -TERM \"$supervisor_pid\"")?.lowerBound)
        let liveChildProof = try XCTUnwrap(
            watchdogOperations.range(
                of:
                    "process_group_has_live_process \"$child_process_group\"")?
                .lowerBound)
        let absenceProof = try XCTUnwrap(
            watchdogOperations.range(
                of: "process_group_exists \"$child_process_group\"")?
                .lowerBound)
        let stoppedStateAnchors = [
            "kill -STOP \"$supervisor_pid\"",
            "supervisor_stopped=false",
            "for stop_observation_attempt in 0 1 2 3 4 5 6 7 8 9 10; do",
            "ps -o state= -p \"$supervisor_pid\"",
            "\"$supervisor_observed_state\" =~ ^T",
            "[[ \"$supervisor_stopped\" == true ]] || containment_invalid=1",
        ]
        XCTAssertTrue(anchorsAppearInStrictOrder(
            stoppedStateAnchors,
            in: watchdogOperations))
        for anchor in stoppedStateAnchors {
            XCTAssertFalse(
                criticalStaticContractHolds(
                    in: replacingEvery(
                        anchor,
                        with: "MUTATED",
                        in: watchdogOperations),
                    requiredAnchors: stoppedStateAnchors),
                anchor)
        }
        XCTAssertEqual(
            occurrences(of: "            sleep 1", in: watchdogSource),
            3)
        XCTAssertEqual(
            occurrences(
                of: "sleep \"$termination_grace_seconds\"",
                in: watchdogSource),
            2)
        XCTAssertLessThan(supervisorStop, supervisorStoppedProof)
        XCTAssertLessThan(supervisorStoppedProof, postStopDescendantCapture)
        XCTAssertLessThan(postStopDescendantCapture, childStop)
        XCTAssertLessThan(childStop, childTerm)
        XCTAssertLessThan(childTerm, childKill)
        XCTAssertLessThan(childKill, liveChildProof)
        XCTAssertLessThan(liveChildProof, supervisorTerm)
        XCTAssertLessThan(supervisorTerm, absenceProof)
        let provenanceSeal = try XCTUnwrap(
            launcherSource.range(
                of: "readonly recomputed_embedded_source_identity=\"$(")?
                .lowerBound)
        let oneShotBuild = try XCTUnwrap(
            launcherSource.range(
                of: "# Exactly one Release compilation")?.lowerBound)
        XCTAssertLessThan(provenanceSeal, oneShotBuild)
        XCTAssertTrue(anchorsAppearInStrictOrder(
            [
                "readonly stage7_job_epoch_path=",
                "assert_regular_file \"$stage7_job_epoch_path\"",
                "readonly stage7_job_epoch_device_id=",
                "# Exactly one Release compilation",
                "assert_regular_file \"$stage7_job_epoch_path\"",
                "readonly pre_one_shot_epoch_seconds=",
                "== \"$stage7_job_epoch_device_id\"",
                "== \"$stage7_job_epoch_inode\"",
                "== \"$stage7_job_epoch_sha256\"",
                "\"$pre_one_shot_setup_elapsed_seconds\" -le \\",
                "\"$maximum_pre_one_shot_setup_seconds\"",
                "+ (5 * termination_grace_seconds))) -le 6960",
                "+ runner_start_and_finalization_reserve_seconds",
                "fail \"Stage-7 setup consumed the one-shot containment budget\"",
                "exec env \\",
            ],
            in: launcherSource))
        XCTAssertEqual(
            occurrences(
                of: "+ (4 * termination_grace_seconds)",
                in: launcherSource),
            0)
        let launcherEnvironmentNames = launcherSource.split(separator: "\n")
            .map(String.init)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter {
                $0.hasPrefix(
                    "PRIME_NATIVE_DECODER_NATIVE300M_TRAJECTORY_CHECKPOINT_EXECUTION_")
                    && $0.contains("=")
            }
            .compactMap { $0.split(separator: "=", maxSplits: 1).first }
            .map(String.init)
        XCTAssertEqual(launcherEnvironmentNames.count, 34)
        XCTAssertEqual(
            launcherEnvironmentNames.sorted(),
            execution.environmentVariableNames.sorted())
        let fixedMemberPathsData = Data(
            try singleQuotedShellConstant(
                "fixed_comparison_member_paths_json",
                in: launcherSource).utf8)
        let launcherFixedMemberPaths = try XCTUnwrap(
            JSONSerialization.jsonObject(with: fixedMemberPathsData)
                as? [String: [String]])
        XCTAssertEqual(
            launcherFixedMemberPaths,
            execution.fixedComparisonMemberPathsByDomainID)
        XCTAssertEqual(
            launcherSource.split(separator: "\n").filter {
                $0.trimmingCharacters(in: .whitespaces) == "\"$executable\""
            }.count,
            1)
        XCTAssertFalse(launcherSource.contains("\nrm "))
        XCTAssertFalse(launcherSource.contains("\nrmdir "))
        XCTAssertFalse(launcherSource.contains("GITHUB_STEP_SUMMARY"))
        XCTAssertEqual(
            occurrences(
                of: "(.observed_nlink | positive_uint)",
                in: launcherSource),
            0)
        XCTAssertGreaterThanOrEqual(
            occurrences(of: ".observed_nlink == 1", in: launcherSource),
            2)
        XCTAssertGreaterThanOrEqual(
            occurrences(
                of: "del(.semantic_role,.observed_nlink)",
                in: launcherSource),
            4)
        XCTAssertGreaterThanOrEqual(
            occurrences(
                of: "all(.[]; . == \"com.apple.provenance\")",
                in: launcherSource),
            2)
        XCTAssertGreaterThanOrEqual(
            occurrences(
                of: "[\"com.apple.quarantine\"]",
                in: launcherSource),
            2)

        let nonemptyLauncherLines = launcherSource.split(separator: "\n")
            .map(String.init)
            .filter { !$0.isEmpty }
        XCTAssertEqual(
            Array(nonemptyLauncherLines.suffix(2)),
            [
                "trap - EXIT HUP INT TERM",
                "exec /usr/bin/printf '%s\\n' \"$public_line\"",
            ])
        XCTAssertEqual(
            execution.maximalPublicReceiptCanonicalByteCount,
            54_022)
    }

    private func source(at root: URL, relativePath: String) throws -> String {
        try String(
            contentsOf: root.appendingPathComponent(relativePath),
            encoding: .utf8)
    }

    private func importLines(in source: String) -> [String] {
        source.split(separator: "\n")
            .map(String.init)
            .filter { $0.hasPrefix("import ") }
    }

    private func occurrences(of needle: String, in source: String) -> Int {
        source.components(separatedBy: needle).count - 1
    }

    private func sourceSlice(
        _ source: String,
        from start: String,
        to end: String
    ) throws -> String {
        let startIndex = try XCTUnwrap(
            source.range(of: start)?.lowerBound,
            "missing source-slice start marker: \(start)")
        let endIndex = try XCTUnwrap(
            source.range(
                of: end,
                range: startIndex ..< source.endIndex)?.lowerBound,
            "missing source-slice end marker after \(start): \(end)")
        return String(source[startIndex ..< endIndex])
    }

    private func singleQuotedShellConstant(
        _ name: String,
        in source: String
    ) throws -> String {
        let prefix = "readonly \(name)='"
        let valueStart = try XCTUnwrap(
            source.range(of: prefix)?.upperBound)
        let valueEnd = try XCTUnwrap(
            source.range(
                of: "'\n",
                range: valueStart ..< source.endIndex)?.lowerBound)
        return String(source[valueStart ..< valueEnd])
    }

    private func criticalStaticContractHolds(
        in source: String,
        requiredAnchors: [String]
    ) -> Bool {
        requiredAnchors.allSatisfy { source.contains($0) }
    }

    private func anchorsAppearInStrictOrder(
        _ anchors: [String],
        in source: String
    ) -> Bool {
        var cursor = source.startIndex
        for anchor in anchors {
            guard let range = source.range(
                of: anchor,
                range: cursor ..< source.endIndex)
            else {
                return false
            }
            cursor = range.upperBound
        }
        return true
    }

    private func replacingEvery(
        _ needle: String,
        with replacement: String,
        in source: String
    ) -> String {
        source.replacingOccurrences(of: needle, with: replacement)
    }
}
