// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Darwin
import Foundation
import Metal
import MLX
import PrimeCore
import XCTest

@testable import PrimeNativeDecoderTraining

final class PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests:
    XCTestCase
{
    func testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes()
        throws
    {
        guard let leasePath = ProcessInfo.processInfo.environment[
            "PRIME_NATIVE_DECODER_STAGE5_METAL_LEASE_PATH"
        ], leasePath.hasPrefix("/"), !leasePath.hasSuffix("/") else {
            throw AssayError.contractDrift("Metal lease path")
        }
        let lease = try PrimeMetalDeviceLease.acquire(
            at: URL(fileURLWithPath: leasePath))
        guard lease.isHeld else {
            throw AssayError.contractDrift("Metal lease acquisition")
        }

        _ = CGColorSpaceCreateDeviceRGB()
        let preflightDevices = MTLCopyAllDevices()
        guard preflightDevices.count == 1,
              let preflightIndexZero = preflightDevices.first,
              let preflightDefault = MTLCreateSystemDefaultDevice(),
              preflightIndexZero === preflightDefault else {
            throw AssayError.contractDrift("preflight singleton Metal device")
        }
        let metalDeviceName = preflightIndexZero.name
        let metalDeviceRegistryID = preflightIndexZero.registryID
        let gpu = Device(.gpu, index: 0)

        let receiptLine = try Device.withDefaultDevice(gpu) {
            guard Device.defaultDevice() === gpu,
                  gpu.deviceType == .gpu,
                  StreamOrDevice.default.stream == Stream.gpu else {
                throw AssayError.contractDrift("explicit default GPU stream")
            }

            var crossTrialBaseline: TrialObservation?
            for _ in 0 ..< 3 {
                let observation = try Self.runIndependentTrial(gpu: gpu)
                try Self.validateExactTensorOrdering(observation)
                if let crossTrialBaseline {
                    guard observation == crossTrialBaseline else {
                        throw AssayError.contractDrift(
                            "cross-trial exact trajectory bytes")
                    }
                } else {
                    crossTrialBaseline = observation
                }
            }
            guard crossTrialBaseline != nil,
                  lease.isHeld,
                  Device.defaultDevice() === gpu,
                  StreamOrDevice.default.stream == Stream.gpu else {
                throw AssayError.contractDrift("assay postflight state")
            }

            let postflightDevices = MTLCopyAllDevices()
            guard postflightDevices.count == 1,
                  let postflightIndexZero = postflightDevices.first,
                  let postflightDefault = MTLCreateSystemDefaultDevice(),
                  postflightIndexZero === preflightIndexZero,
                  postflightDefault === preflightDefault,
                  postflightIndexZero === postflightDefault,
                  postflightIndexZero.registryID == metalDeviceRegistryID,
                  postflightIndexZero.name == metalDeviceName,
                  lease.isHeld else {
                throw AssayError.contractDrift(
                    "postflight singleton Metal device identity")
            }

            return try Self.makeCanonicalReceiptLine(
                leasePath: leasePath,
                metalDeviceName: metalDeviceName,
                metalDeviceRegistryID: metalDeviceRegistryID)
        }
        guard lease.isHeld else {
            throw AssayError.contractDrift("lease before receipt")
        }
        fputs(receiptLine, stdout)
        fflush(stdout)
        lease.release()
    }

    private struct TrialObservation: Equatable {
        let sourceStep: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
        let sourceEvaluation:
            PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1
        let importedBoundary:
            PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
        let successorStep:
            PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
        let terminalEvaluation:
            PrimeNativeDecoderTinyCPUTrainEvaluateEvaluationV1
        let terminalBoundary:
            PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
    }

    private enum AssayError: Error {
        case contractDrift(String)
    }

    private static func runIndependentTrial(
        gpu: Device
    ) throws -> TrialObservation {
        let uninterrupted =
            try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
                metalGPUIndexZero: gpu)
        let sourceSnapshot =
            try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
                metalGPUIndexZero: gpu)
        guard uninterrupted !== sourceSnapshot else {
            throw AssayError.contractDrift("fresh source objects")
        }

        let uninterruptedSourceStep =
            try uninterrupted.trainNextExactMetalTrajectoryStep()
        let sourceSnapshotSourceStep =
            try sourceSnapshot.trainNextExactMetalTrajectoryStep()
        guard uninterruptedSourceStep == sourceSnapshotSourceStep,
              uninterruptedSourceStep.result.globalStep == 1,
              uninterruptedSourceStep.result.selectedTargetCount == 6 else {
            throw AssayError.contractDrift("source-step exact bytes")
        }

        let uninterruptedSourceEvaluation =
            try uninterrupted.checkedEvaluate()
        let sourceSnapshotSourceEvaluation =
            try sourceSnapshot.checkedEvaluate()
        guard uninterruptedSourceEvaluation
                == sourceSnapshotSourceEvaluation,
              uninterruptedSourceEvaluation.globalStep == 1 else {
            throw AssayError.contractDrift("source evaluation bit patterns")
        }
        let uninterruptedBoundary =
            try uninterrupted.exactMetalTrajectoryBoundaryState()
        let sourceBoundary =
            try sourceSnapshot.exactMetalTrajectoryBoundaryState()
        guard uninterruptedBoundary == sourceBoundary else {
            throw AssayError.contractDrift("source boundary state")
        }

        let snapshot = try sourceSnapshot.exportInMemoryResumeSnapshot()
        let sourceBoundaryAfterExport =
            try sourceSnapshot.exactMetalTrajectoryBoundaryState()
        guard sourceBoundaryAfterExport == sourceBoundary else {
            throw AssayError.contractDrift(
                "source snapshot capture mutated boundary")
        }
        let sourceSnapshotSuccessorStep =
            try sourceSnapshot.trainNextExactMetalTrajectoryStep()
        let restored =
            try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
                restoring: snapshot,
                metalGPUIndexZero: gpu)
        guard restored !== sourceSnapshot,
              restored !== uninterrupted else {
            throw AssayError.contractDrift("fresh restored object")
        }
        let restoredSourceEvaluation = try restored.checkedEvaluate()
        let restoredBoundary =
            try restored.exactMetalTrajectoryBoundaryState()
        guard restoredSourceEvaluation == uninterruptedSourceEvaluation,
              restoredBoundary == uninterruptedBoundary else {
            throw AssayError.contractDrift(
                "fresh imported step-one boundary")
        }

        let uninterruptedSuccessorStep =
            try uninterrupted.trainNextExactMetalTrajectoryStep()
        let restoredSuccessorStep =
            try restored.trainNextExactMetalTrajectoryStep()
        guard uninterruptedSuccessorStep == sourceSnapshotSuccessorStep,
              uninterruptedSuccessorStep == restoredSuccessorStep,
              uninterruptedSuccessorStep.result.globalStep == 2,
              uninterruptedSuccessorStep.result.selectedTargetCount == 5 else {
            throw AssayError.contractDrift("successor exact bytes")
        }

        let uninterruptedTerminalEvaluation =
            try uninterrupted.checkedEvaluate()
        let sourceSnapshotTerminalEvaluation =
            try sourceSnapshot.checkedEvaluate()
        let restoredTerminalEvaluation = try restored.checkedEvaluate()
        guard uninterruptedTerminalEvaluation
                == sourceSnapshotTerminalEvaluation,
              uninterruptedTerminalEvaluation
                == restoredTerminalEvaluation,
              uninterruptedTerminalEvaluation.globalStep == 2 else {
            throw AssayError.contractDrift(
                "terminal evaluation bit patterns")
        }
        let uninterruptedTerminalBoundary =
            try uninterrupted.exactMetalTrajectoryBoundaryState()
        let sourceSnapshotTerminalBoundary =
            try sourceSnapshot.exactMetalTrajectoryBoundaryState()
        let restoredTerminalBoundary =
            try restored.exactMetalTrajectoryBoundaryState()
        guard uninterruptedTerminalBoundary
                == sourceSnapshotTerminalBoundary,
              uninterruptedTerminalBoundary == restoredTerminalBoundary else {
            throw AssayError.contractDrift("terminal exact state bytes")
        }

        return .init(
            sourceStep: uninterruptedSourceStep,
            sourceEvaluation: uninterruptedSourceEvaluation,
            importedBoundary: uninterruptedBoundary,
            successorStep: uninterruptedSuccessorStep,
            terminalEvaluation: uninterruptedTerminalEvaluation,
            terminalBoundary: uninterruptedTerminalBoundary)
    }

    private static func validateExactTensorOrdering(
        _ observation: TrialObservation
    ) throws {
        let tensorLists = [
            observation.sourceStep.rawGradients,
            observation.sourceStep.clippedGradients,
            observation.sourceStep.postStepTensors.modelParameters,
            observation.sourceStep.postStepTensors.firstMoments,
            observation.sourceStep.postStepTensors.secondMoments,
            observation.importedBoundary.tensors.modelParameters,
            observation.importedBoundary.tensors.firstMoments,
            observation.importedBoundary.tensors.secondMoments,
            observation.successorStep.rawGradients,
            observation.successorStep.clippedGradients,
            observation.successorStep.postStepTensors.modelParameters,
            observation.successorStep.postStepTensors.firstMoments,
            observation.successorStep.postStepTensors.secondMoments,
            observation.terminalBoundary.tensors.modelParameters,
            observation.terminalBoundary.tensors.firstMoments,
            observation.terminalBoundary.tensors.secondMoments,
        ]
        for tensors in tensorLists {
            guard tensors.count == 20,
                  tensors.map(\.path)
                    == tensors.map(\.path).sorted(by: Self.utf8Less),
                  Set(tensors.map(\.path)).count == 20 else {
                throw AssayError.contractDrift("canonical tensor paths")
            }
            for tensor in tensors {
                guard tensor.dtype == "float32",
                      tensor.float32BitPatterns.count
                        * MemoryLayout<UInt32>.size
                        == tensor.float32LittleEndianBytes.count,
                      tensor.shape.reduce(1, *)
                        == tensor.float32BitPatterns.count else {
                    throw AssayError.contractDrift(
                        "canonical tensor shape or dtype")
                }
                let expectedBytes = tensor.float32BitPatterns.flatMap {
                    bits in
                    [
                        UInt8(bits & 0xff),
                        UInt8((bits >> 8) & 0xff),
                        UInt8((bits >> 16) & 0xff),
                        UInt8((bits >> 24) & 0xff),
                    ]
                }
                guard tensor.float32LittleEndianBytes == expectedBytes else {
                    throw AssayError.contractDrift(
                        "Float32 little-endian tensor bytes")
                }
            }
        }
        guard observation.importedBoundary.globalStep == 1,
              observation.terminalBoundary.globalStep == 2,
              observation.sourceStep.controlState
                == observation.importedBoundary.controlState,
              observation.successorStep.controlState
                == observation.terminalBoundary.controlState,
              !observation.sourceStep.controlState.canonicalBytes.isEmpty,
              !observation.successorStep.controlState.canonicalBytes.isEmpty,
              observation.sourceStep.controlState.canonicalBytes
                != observation.successorStep.controlState.canonicalBytes else {
            throw AssayError.contractDrift("exact control state bytes")
        }
    }

    private static func makeCanonicalReceiptLine(
        leasePath: String,
        metalDeviceName: String,
        metalDeviceRegistryID: UInt64
    ) throws -> String {
        let environment = ProcessInfo.processInfo.environment
        func required(_ key: String) throws -> String {
            guard let value = environment[key], !value.isEmpty else {
                throw AssayError.contractDrift("missing environment \(key)")
            }
            return value
        }
        func exactInteger(_ key: String) throws -> Int {
            let value = try required(key)
            guard let result = Int(value), String(result) == value else {
                throw AssayError.contractDrift("integer environment \(key)")
            }
            return result
        }
        func exactSHA(_ key: String) throws -> String {
            let value = try required(key)
            guard value.count == 40 || value.count == 64,
                  value.utf8.allSatisfy({
                      ($0 >= 48 && $0 <= 57) || ($0 >= 97 && $0 <= 102)
                  }) else {
                throw AssayError.contractDrift("digest environment \(key)")
            }
            return value
        }

        let revision = try exactSHA(
            "PRIME_NATIVE_DECODER_STAGE5_EXECUTED_REVISION")
        let tree = try exactSHA("PRIME_NATIVE_DECODER_STAGE5_EXECUTED_TREE")
        let firstParent = try exactSHA(
            "PRIME_NATIVE_DECODER_STAGE5_FIRST_PARENT")
        let secondParent = try exactSHA(
            "PRIME_NATIVE_DECODER_STAGE5_SECOND_PARENT")
        guard firstParent
                == "522e4620596eed909822b80b782d74d282f429c5",
              environment["MLX_ENABLE_TF32"] == "0",
              environment["GITHUB_REPOSITORY"]
                == "Ergentics/ergentics-prime",
              environment["GITHUB_REF"] == "refs/heads/main",
              environment["GITHUB_EVENT_NAME"] == "push",
              environment["GITHUB_RUN_ATTEMPT"] == "1",
              try required(
                "PRIME_NATIVE_DECODER_STAGE5_BUILD_CONFIGURATION")
                == "debug",
              try required(
                "PRIME_NATIVE_DECODER_STAGE5_MLX_GRAPH_COMPILE_MODE")
                == "eager_uncompiled_no_compile_transform" else {
            throw AssayError.contractDrift("exact execution environment")
        }

        let changedPathsData = Data(try required(
            "PRIME_NATIVE_DECODER_STAGE5_CHANGED_PATHS_JSON").utf8)
        let changedPaths = try JSONDecoder().decode(
            [String].self,
            from: changedPathsData)
        let expectedChangedPaths = [
            ".github/scripts/prime-ci-active-root-quarantine.sh",
            ".github/scripts/prime-ci-native-decoder-stage5-tiny-repeated-metal-trajectory-determinism.sh",
            ".github/workflows/prime-active-root-quarantine.yml",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
            "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
            "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests.swift",
        ]
        guard changedPaths == expectedChangedPaths else {
            throw AssayError.contractDrift("exact changed paths")
        }

        let leaseURL = URL(fileURLWithPath: leasePath)
        let parentPath = leaseURL.deletingLastPathComponent().path
        var leaseStatus = stat()
        var parentStatus = stat()
        guard lstat(leasePath, &leaseStatus) == 0,
              lstat(parentPath, &parentStatus) == 0,
              leaseStatus.st_mode & S_IFMT == S_IFREG,
              parentStatus.st_mode & S_IFMT == S_IFDIR,
              leaseStatus.st_uid == geteuid(),
              parentStatus.st_uid == geteuid(),
              leaseStatus.st_nlink == 1,
              leaseStatus.st_mode & mode_t(0o777) == mode_t(0o600),
              parentStatus.st_mode & mode_t(0o777) == mode_t(0o700) else {
            throw AssayError.contractDrift("lease metadata")
        }

        let secureFetch: [String: Any] = [
            "authenticated_depth_one_fetch_count": 1,
            "completion_count": 1,
            "custom_ca_installation_count": 0,
            "git_internal_retry_scheduled_count": 0,
            "invocation_count": 1,
            "mlx_c_clone_count": 1,
            "mlx_clone_count": 1,
            "step_conclusion": "success",
            "submodule_update_invocation_count": 1,
            "tls_failure_count": 0,
            "tls_verification_bypass_count": 0,
            "workflow_authored_retry_count": 0,
        ]
        let receipt: [String: Any] = [
            "assay": [
                "all_trials_in_one_process": true,
                "build_count": 1,
                "direct_xctest_count": 1,
                "every_trial_uses_fresh_objects_and_arrays": true,
                "exact_branches_per_trial": [
                    "uninterrupted",
                    "source_snapshot",
                    "fresh_restored_from_source_snapshot",
                ],
                "independent_trial_count": 3,
                "source_snapshot_branch_continues_to_terminal": true,
                "source_snapshot_exists_only_in_memory": true,
                "test_class":
                    "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests",
                "test_filter":
                    "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayTests/testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes",
                "test_method":
                    "testRepeatedSameDeviceUninterruptedSourceSnapshotAndFreshRestoreExactBytes",
                "total_trajectory_branch_execution_count": 9,
            ],
            "authority": [
                "authority_canonical_sha256":
                    "00c49e63315b2aacb439204e778f54bcf63c2fdf643282f3bd64e2b3b4094089",
                "authority_id":
                    "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_authority_v1",
                "repair_authority_canonical_sha256":
                    "a5a8e5300ea8413e738fddd4b8fed930dcc9983d5a29eea102862f9744b50fff",
                "repair_authority_id":
                    "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_exact_main_swift_numerics_resolution_repair_authority_v1",
            ],
            "ceiling": [
                "additional_execution_or_rerun_authorized": false,
                "artifact_upload_authorized": false,
                "canary_authorized": false,
                "candidate_admission_granted": false,
                "checkpoint_admission_granted": false,
                "cross_device_claim_authorized": false,
                "downstream_trial_authorized": false,
                "durable_checkpoint_io_authorized": false,
                "general_training_authorized": false,
                "general_training_resume_established": false,
                "model_quality_established": false,
                "native300m_allocation_authorized": false,
                "native300m_training_authorized": false,
                "product_use_authorized": false,
                "publication_authorized": false,
                "retained_artifact_authorized": false,
                "stage4_rerun_authorized": false,
                "stage6_authorized": false,
            ],
            "environment": [
                "checked_evaluation_before_every_byte_read": true,
                "exact_metal_device_count": 1,
                "explicit_default_gpu_stream": true,
                "explicit_synchronize_before_every_byte_read": true,
                "exact_mlx_revision": try exactSHA(
                    "PRIME_NATIVE_DECODER_STAGE5_EXACT_MLX_REVISION"),
                "implicit_or_global_mlx_rng_used": false,
                "index_zero_matches_default_device": true,
                "kernel_identity": try required(
                    "PRIME_NATIVE_DECODER_STAGE5_KERNEL_IDENTITY"),
                "macos_sdk": try required(
                    "PRIME_NATIVE_DECODER_STAGE5_MACOS_SDK"),
                "metal_device_index": 0,
                "metal_device_name": metalDeviceName,
                "metal_device_registry_id": metalDeviceRegistryID,
                "mlx_compile_transform_invocation_count": 0,
                "mlx_enable_tf32": "0",
                "mlx_graph_compile_mode":
                    "eager_uncompiled_no_compile_transform",
                "operating_system_build": try required(
                    "PRIME_NATIVE_DECODER_STAGE5_OPERATING_SYSTEM_BUILD"),
                "postflight_device_identity_reverified": true,
                "same_metal_device_across_every_trial_and_branch": true,
                "swift_toolchain": try required(
                    "PRIME_NATIVE_DECODER_STAGE5_SWIFT_TOOLCHAIN"),
                "swiftpm_build_configuration": "debug",
                "xcode_toolchain": try required(
                    "PRIME_NATIVE_DECODER_STAGE5_XCODE_TOOLCHAIN"),
            ],
            "equality": [
                "canonical_parameter_shape_dtype_and_little_endian_order":
                    true,
                "exact_adam_first_moment_bytes": true,
                "exact_adam_second_moment_bytes": true,
                "exact_clipped_gradient_bytes": true,
                "exact_loss_norm_clip_and_evaluation_float32_bit_patterns":
                    true,
                "exact_model_parameter_bytes": true,
                "exact_next_unconsumed_cursor_bytes": true,
                "exact_raw_gradient_bytes": true,
                "exact_rng_domain_key_counter_and_consumption_bytes": true,
                "exact_terminal_control_state_bytes": true,
                "source_step_branches": [
                    "uninterrupted",
                    "source_snapshot",
                ],
                "successor_and_terminal_branches": [
                    "uninterrupted",
                    "source_snapshot",
                    "fresh_restored_from_source_snapshot",
                ],
                "unordered_or_tolerance_comparison_used": false,
            ],
            "execution": [
                "changed_paths": changedPaths,
                "embedded_source_identity_sha256": try exactSHA(
                    "PRIME_NATIVE_DECODER_STAGE5_EMBEDDED_SOURCE_IDENTITY_SHA256"),
                "first_parent_revision": firstParent,
                "github_event_name": "push",
                "github_run_attempt": 1,
                "parent_count": 2,
                "ref": "refs/heads/main",
                "repository": "Ergentics/ergentics-prime",
                "revision": revision,
                "second_parent_revision": secondParent,
                "tree": tree,
            ],
            "lease": [
                "acquired_before_coregraphics_metal_or_mlx_access": true,
                "environment_key":
                    "PRIME_NATIVE_DECODER_STAGE5_METAL_LEASE_PATH",
                "explicit_release_immediately_after_receipt": true,
                "file_is_physical_regular_nonlink": true,
                "file_link_count": 1,
                "file_owner_is_effective_user": true,
                "file_permission_mode": "600",
                "held_across_all_three_trials_and_nine_branches": true,
                "held_through_postflight_identity_validation": true,
                "no_fallible_operation_after_receipt": true,
                "parent_path": parentPath,
                "parent_permission_mode": "700",
                "path": leasePath,
                "receipt_emitted_while_held": true,
                "receipt_flushed_while_held": true,
            ],
            "metallib": [
                "artifact_provenance_established": false,
                "byte_count": try exactInteger(
                    "PRIME_NATIVE_DECODER_STAGE5_METALLIB_BYTES"),
                "path": try required(
                    "PRIME_NATIVE_DECODER_STAGE5_METALLIB_PATH"),
                "retained_after_job": false,
                "sha256": try exactSHA(
                    "PRIME_NATIVE_DECODER_STAGE5_METALLIB_SHA256"),
                "source_candidate_count": 1,
                "staged_copy_count": 2,
                "staged_permission_mode": "444",
            ],
            "predecessor": [
                "focused_isolated_test_count": 6,
                "focused_root_test_count": 53,
                "focused_whole_test_count": 59,
                "live_order": [
                    "root",
                    "metal",
                    "maintained_runtime",
                    "tokenizer",
                    "stage5",
                ],
                "maintained_runtime_receipt_count": 1,
                "maintained_runtime_test_count": 1,
                "metal_test_count": 44,
                "pre_stage5_total_test_count": 105,
                "stage5_direct_xctest_count": 1,
                "tokenizer_receipt_count": 1,
                "tokenizer_test_count": 1,
                "total_test_count": 106,
            ],
            "receipt_id":
                "prime_native_decoder_stage5_tiny_repeated_metal_trajectory_determinism_receipt_v1",
            "repair_closure": [
                "artifact_count": 0,
                "check_suite_id": try exactInteger(
                    "PRIME_NATIVE_DECODER_STAGE5_AUTHORITY_REPAIR_CLOSURE_CHECK_SUITE_ID"),
                "rerun_count": 0,
                "run_attempt": 1,
                "secure_fetch": secureFetch,
                "stage5_launcher_invocation_count": 0,
                "stage5_receipt_count": 0,
                "terminal_conclusion": "success",
                "workflow_run_id": try exactInteger(
                    "PRIME_NATIVE_DECODER_STAGE5_AUTHORITY_REPAIR_CLOSURE_WORKFLOW_RUN_ID"),
                "workflow_run_number": try exactInteger(
                    "PRIME_NATIVE_DECODER_STAGE5_AUTHORITY_REPAIR_CLOSURE_WORKFLOW_RUN_NUMBER"),
            ],
            "schema_version": 1,
            "status":
                "PASS_exact_main_tiny_same_device_three_trial_nine_branch_exact_metal_trajectory_determinism_one_test_zero_failure_zero_skip",
        ]
        guard JSONSerialization.isValidJSONObject(receipt) else {
            throw AssayError.contractDrift("receipt JSON value")
        }
        let data = try JSONSerialization.data(
            withJSONObject: receipt,
            options: [.sortedKeys, .withoutEscapingSlashes])
        let reparsed = try JSONSerialization.jsonObject(with: data)
        let canonical = try JSONSerialization.data(
            withJSONObject: reparsed,
            options: [.sortedKeys, .withoutEscapingSlashes])
        guard data == canonical,
              let json = String(data: data, encoding: .utf8) else {
            throw AssayError.contractDrift("canonical receipt JSON")
        }
        return "PRIME_NATIVE_DECODER_STAGE5_TINY_REPEATED_METAL_TRAJECTORY_DETERMINISM_RECEIPT=\(json)\n"
    }

    private static func utf8Less(_ lhs: String, _ rhs: String) -> Bool {
        lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
    }
}
