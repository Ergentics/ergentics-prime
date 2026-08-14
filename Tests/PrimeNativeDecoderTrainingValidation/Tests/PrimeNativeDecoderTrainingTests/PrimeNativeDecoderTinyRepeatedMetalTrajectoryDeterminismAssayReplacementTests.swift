// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Darwin
import Foundation
import MLX
import Metal
import PrimeCore
import XCTest

@testable import PrimeNativeDecoderTraining

final class
  PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests:
    XCTestCase
{
  func testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume()
    throws
  {
    let inputs = try ExecutionInputs.current()
    try Self.validateAuthorityAndExecutionInputs(inputs)

    let lease = try PrimeMetalDeviceLease.acquire(
      at: URL(fileURLWithPath: inputs.metalLeasePath))
    guard lease.isHeld else {
      throw AssayError.contractDrift("Metal lease acquisition")
    }
    try Self.validateLeaseAndMetallib(inputs)

    _ = CGColorSpaceCreateDeviceRGB()
    let preflightDevices = MTLCopyAllDevices()
    guard preflightDevices.count == 1,
      let preflightIndexZero = preflightDevices.first,
      let preflightDefault = MTLCreateSystemDefaultDevice(),
      preflightIndexZero === preflightDefault
    else {
      throw AssayError.contractDrift(
        "preflight singleton Metal device")
    }
    let metalDeviceName = preflightIndexZero.name
    let metalDeviceRegistryID = preflightIndexZero.registryID
    let gpu = Device(.gpu, index: 0)

    let receiptLine = try Device.withDefaultDevice(gpu) {
      guard Device.defaultDevice() === gpu,
        gpu.deviceType == .gpu,
        StreamOrDevice.default.stream == Stream.gpu
      else {
        throw AssayError.contractDrift(
          "explicit default GPU stream")
      }

      let armA = try Self.runArmA(gpu: gpu)
      let armB = try Self.runArmB(
        gpu: gpu,
        armASourceStepCount: armA.pairs.count * 2)

      guard lease.isHeld,
        Device.defaultDevice() === gpu,
        StreamOrDevice.default.stream == Stream.gpu
      else {
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
        lease.isHeld
      else {
        throw AssayError.contractDrift(
          "postflight singleton Metal device identity")
      }

      return try Self.makeCanonicalReceiptLine(
        inputs: inputs,
        armA: armA,
        armB: armB,
        metalDeviceName: metalDeviceName,
        metalDeviceRegistryID: metalDeviceRegistryID)
    }
    guard lease.isHeld else {
      throw AssayError.contractDrift("lease before receipt")
    }
    guard fputs(receiptLine, stdout) >= 0 else {
      throw AssayError.contractDrift("receipt stdout emission")
    }
    guard fflush(stdout) == 0 else {
      throw AssayError.contractDrift("receipt stdout flush")
    }
    lease.release()
  }

  private enum AssayError: Error {
    case contractDrift(String)
  }

  private struct SourceIdentity: Codable, Equatable {
    var path: String
    var git_mode: String
    var git_blob: String
    var byte_count: Int
    var sha256: String
    var role: String
  }

  private enum Nullable<Value>: Codable, Equatable
  where Value: Codable & Equatable {
    case null
    case value(Value)

    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      if container.decodeNil() {
        self = .null
      } else {
        self = .value(try container.decode(Value.self))
      }
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      switch self {
      case .null:
        try container.encodeNil()
      case .value(let value):
        try container.encode(value)
      }
    }

    var optional: Value? {
      switch self {
      case .null: nil
      case .value(let value): value
      }
    }
  }

  private struct FirstMismatch: Codable, Equatable {
    var arm: String
    var branch: String
    var byte_offset: Int?
    var comparison_domain: String
    var component: String
    var dtype: String?
    var forward_boundary: String?
    var observed_branch: String
    var observed_scalar_float32_bits: UInt32?
    var observed_sha256: String?
    var parameter_or_tensor_path: String?
    var reference_branch: String
    var reference_scalar_float32_bits: UInt32?
    var reference_sha256: String?
    var scalar_name: String?
    var shape: [Int]?
    var trial_ordinal: Int

    private enum CodingKeys: String, CodingKey, CaseIterable {
      case arm
      case branch
      case byte_offset
      case comparison_domain
      case component
      case dtype
      case forward_boundary
      case observed_branch
      case observed_scalar_float32_bits
      case observed_sha256
      case parameter_or_tensor_path
      case reference_branch
      case reference_scalar_float32_bits
      case reference_sha256
      case scalar_name
      case shape
      case trial_ordinal
    }

    init(
      arm: String,
      branch: String,
      byte_offset: Int?,
      comparison_domain: String,
      component: String,
      dtype: String?,
      forward_boundary: String?,
      observed_branch: String,
      observed_scalar_float32_bits: UInt32?,
      observed_sha256: String?,
      parameter_or_tensor_path: String?,
      reference_branch: String,
      reference_scalar_float32_bits: UInt32?,
      reference_sha256: String?,
      scalar_name: String?,
      shape: [Int]?,
      trial_ordinal: Int
    ) {
      self.arm = arm
      self.branch = branch
      self.byte_offset = byte_offset
      self.comparison_domain = comparison_domain
      self.component = component
      self.dtype = dtype
      self.forward_boundary = forward_boundary
      self.observed_branch = observed_branch
      self.observed_scalar_float32_bits =
        observed_scalar_float32_bits
      self.observed_sha256 = observed_sha256
      self.parameter_or_tensor_path = parameter_or_tensor_path
      self.reference_branch = reference_branch
      self.reference_scalar_float32_bits =
        reference_scalar_float32_bits
      self.reference_sha256 = reference_sha256
      self.scalar_name = scalar_name
      self.shape = shape
      self.trial_ordinal = trial_ordinal
    }

    init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)
      guard Set(values.allKeys) == Set(CodingKeys.allCases) else {
        throw AssayError.contractDrift("first mismatch keys")
      }
      arm = try values.decode(String.self, forKey: .arm)
      branch = try values.decode(String.self, forKey: .branch)
      byte_offset = try values.decodeIfPresent(
        Int.self, forKey: .byte_offset)
      comparison_domain = try values.decode(
        String.self, forKey: .comparison_domain)
      component = try values.decode(String.self, forKey: .component)
      dtype = try values.decodeIfPresent(String.self, forKey: .dtype)
      forward_boundary = try values.decodeIfPresent(
        String.self, forKey: .forward_boundary)
      observed_branch = try values.decode(
        String.self, forKey: .observed_branch)
      observed_scalar_float32_bits = try values.decodeIfPresent(
        UInt32.self, forKey: .observed_scalar_float32_bits)
      observed_sha256 = try values.decodeIfPresent(
        String.self, forKey: .observed_sha256)
      parameter_or_tensor_path = try values.decodeIfPresent(
        String.self, forKey: .parameter_or_tensor_path)
      reference_branch = try values.decode(
        String.self, forKey: .reference_branch)
      reference_scalar_float32_bits = try values.decodeIfPresent(
        UInt32.self, forKey: .reference_scalar_float32_bits)
      reference_sha256 = try values.decodeIfPresent(
        String.self, forKey: .reference_sha256)
      scalar_name = try values.decodeIfPresent(
        String.self, forKey: .scalar_name)
      shape = try values.decodeIfPresent([Int].self, forKey: .shape)
      trial_ordinal = try values.decode(
        Int.self, forKey: .trial_ordinal)
    }

    func encode(to encoder: Encoder) throws {
      var values = encoder.container(keyedBy: CodingKeys.self)
      try values.encode(arm, forKey: .arm)
      try values.encode(branch, forKey: .branch)
      try Self.encode(byte_offset, to: &values, forKey: .byte_offset)
      try values.encode(comparison_domain, forKey: .comparison_domain)
      try values.encode(component, forKey: .component)
      try Self.encode(dtype, to: &values, forKey: .dtype)
      try Self.encode(
        forward_boundary, to: &values, forKey: .forward_boundary)
      try values.encode(observed_branch, forKey: .observed_branch)
      try Self.encode(
        observed_scalar_float32_bits,
        to: &values,
        forKey: .observed_scalar_float32_bits)
      try Self.encode(
        observed_sha256, to: &values, forKey: .observed_sha256)
      try Self.encode(
        parameter_or_tensor_path,
        to: &values,
        forKey: .parameter_or_tensor_path)
      try values.encode(reference_branch, forKey: .reference_branch)
      try Self.encode(
        reference_scalar_float32_bits,
        to: &values,
        forKey: .reference_scalar_float32_bits)
      try Self.encode(
        reference_sha256, to: &values, forKey: .reference_sha256)
      try Self.encode(scalar_name, to: &values, forKey: .scalar_name)
      try Self.encode(shape, to: &values, forKey: .shape)
      try values.encode(trial_ordinal, forKey: .trial_ordinal)
    }

    private static func encode<T>(
      _ value: T?,
      to container: inout KeyedEncodingContainer<CodingKeys>,
      forKey key: CodingKeys
    ) throws where T: Encodable {
      if let value {
        try container.encode(value, forKey: key)
      } else {
        try container.encodeNil(forKey: key)
      }
    }
  }

  private struct PairBoolean: Codable, Equatable {
    var trial_ordinal: Int
    var reference_branch: String
    var observed_branch: String
    var exact: Bool
  }

  private struct SelectorByBranch: Codable, Equatable {
    var trial_ordinal: Int
    var branch: String
    var selector_id: String
  }

  private struct ForwardBoolean: Codable, Equatable {
    var trial_ordinal: Int
    var boundary: String
    var exact: Bool
  }

  private struct DomainBoolean: Codable, Equatable {
    var comparison_domain: String
    var exact: Bool
  }

  private struct ArmAReceipt: Codable, Equatable {
    var completed_diagnostic_pair_count: Int
    var first_scalar_mismatch: Nullable<FirstMismatch>
    var first_tensor_mismatch: Nullable<FirstMismatch>
    var global_step_one_by_pair: [PairBoolean]
    var measured_mismatch: Bool
    var pair_branch_names: [String]
    var selected_target_count_six_by_pair: [PairBoolean]
    var source_step_equal_by_pair: [PairBoolean]
    var trial_count: Int
  }

  private struct ArmBReceipt: Codable, Equatable {
    var all_exact_comparisons_passed: Bool
    var all_forward_equivalence_checks_passed: Bool
    var branch_names: [String]
    var comparison_domain_results: [DomainBoolean]
    var first_mismatch: Nullable<FirstMismatch>
    var fresh_constructor: String
    var restore_constructor: String
    var selector_id_by_branch: [SelectorByBranch]
    var status: String
    var trajectory_branch_count: Int
    var trial_count: Int
  }

  private struct AuthorityReceipt: Codable, Equatable {
    var authority_canonical_sha256: String
    var authority_id: String
    var authority_source_git_blob: String
    var authority_source_sha256: String
    var authority_test_git_blob: String
    var authority_test_sha256: String
  }

  private struct DeviceIdentity: Codable, Equatable {
    var name: String
    var registry_id: UInt64
  }

  private struct EnvironmentReceipt: Codable, Equatable {
    var exact_metallib_byte_count: Int
    var exact_metallib_path: String
    var exact_metallib_sha256: String
    var exact_mlx_c_revision: String
    var exact_mlx_revision: String
    var lease_path: String
    var lease_type: String
    var metal_device_count: Int
    var metal_device_index: Int
    var metal_device_is_default: Bool
    var metal_device_name: String
    var metal_device_registry_id: UInt64
    var mlx_compile_transform_invocation_count: Int
    var mlx_default_stream_is_gpu: Bool
    var mlx_enable_tf32: String
    var mlx_graph_compile_mode: String
    var operating_system_build: String
    var swift_sdk: String
    var swift_version: String
    var swiftpm_build_configuration: String
    var xcode_version: String
  }

  private struct ExecutionReceipt: Codable, Equatable {
    var artifact_count: Int
    var authority_closure_active_job_conclusion: String
    var authority_closure_active_job_id: Int
    var authority_closure_check_suite_id: Int
    var authority_closure_conclusion: String
    var authority_closure_reviewed_job_conclusion: String
    var authority_closure_reviewed_job_id: Int
    var authority_closure_revision: String
    var authority_closure_run_attempt: Int
    var authority_closure_run_id: Int
    var authority_closure_run_number: Int
    var authority_closure_tree: String
    var build_count: Int
    var direct_xctest_count: Int
    var embedded_source_identity_sha256: String
    var exact_changed_source_identities: [SourceIdentity]
    var exact_main_revision: String
    var exact_main_tree: String
    var launcher_invocation_count: Int
    var lease_acquired_before_coregraphics_metal_or_mlx: Bool
    var lease_path: String
    var mechanics_event: String
    var mechanics_head_ordered_parent_revisions: [String]
    var mechanics_head_revision: String
    var mechanics_head_tree: String
    var mechanics_ref: String
    var mechanics_run_attempt: Int
    var one_shot_consumed: Bool
    var original_stage5_launcher_invocation_count: Int
    var rerun_count: Int
    var retained_metal_device_identity: DeviceIdentity
    var retry_count: Int
    var stage6_launcher_invocation_count: Int
    var test_filter: String
  }

  private struct ForwardReceipt: Codable, Equatable {
    var boundary_names: [String]
    var embedding_forward_exact_by_boundary: [ForwardBoolean]
    var same_model_pre_mutation: Bool
    var whole_logits_exact_by_boundary: [ForwardBoolean]
  }

  private struct OperationCounts: Codable, Equatable {
    var arm_a_source_step_count: Int
    var arm_b_dense_embedding_construction_count: Int
    var arm_b_dense_whole_logits_call_count: Int
    var arm_b_evaluate_count: Int
    var arm_b_forward_equivalence_check_count: Int
    var arm_b_input_embedding_pair_seam_count: Int
    var arm_b_restore_count: Int
    var arm_b_snapshot_count: Int
    var arm_b_token_bounds_checked_eval_count: Int
    var arm_b_token_bounds_gpu_synchronize_count: Int
    var arm_b_token_bounds_host_bool_item_count: Int
    var arm_b_token_bounds_validation_count: Int
    var arm_b_training_step_count: Int
    var receipt_count: Int
    var synchronize_count: Int
  }

  private struct CeilingReceipt: Codable, Equatable {
    var additional_execution_or_rerun_authorized: Bool
    var arbitrary_token_determinism_established: Bool
    var artifact_upload_authorized: Bool
    var b_specific_native300_resource_witness_authorized: Bool
    var b_specific_native300_resource_witness_established: Bool
    var b_specific_native300_resource_witness_requires_separate_authority: Bool
    var candidate_admission_granted: Bool
    var cross_device_determinism_established: Bool
    var default_gather_determinism_established: Bool
    var durable_checkpoint_io_authorized: Bool
    var exact_same_device_b_path_gradient_bytes_established: Bool
    var model_quality_established: Bool
    var one_shot_consumed: Bool
    var repeated_same_device_b_path_determinism_established: Bool
    var retained_artifact_authorized: Bool
    var stage5_assay_clearance_established: Bool
    var stage5_mechanics_success_established: Bool
    var stage5_result_established: Bool
    var stage6_historical_resource_clearance_applies_to_b_path: Bool
    var stage6_resource_clearance_remains_historical: Bool
    var stage7_authority_established: Bool
    var stage7_authorized: Bool
    var stage7_requires_new_b_specific_native300_resource_witness: Bool
    var stage7_requires_separate_authority_after_witness: Bool
  }

  private struct Receipt: Codable, Equatable {
    var arm_a: ArmAReceipt
    var arm_b: ArmBReceipt
    var authority: AuthorityReceipt
    var ceiling: CeilingReceipt
    var environment: EnvironmentReceipt
    var execution: ExecutionReceipt
    var forward_equivalence: ForwardReceipt
    var operation_counts: OperationCounts
    var receipt_id: String
    var schema_version: Int
    var status: String

    func canonicalData() throws -> Data {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
      return try encoder.encode(self)
    }

    static func decodeCanonical(_ data: Data) throws -> Self {
      let value = try JSONDecoder().decode(Self.self, from: data)
      guard try value.canonicalData() == data else {
        throw AssayError.contractDrift("noncanonical receipt")
      }
      return value
    }
  }

  private struct ExecutionInputs {
    let environment: [String: String]
    let metalLeasePath: String
    let authorityID: String
    let authorityCanonicalSHA256: String
    let authoritySourceIdentity: SourceIdentity
    let authorityTestIdentity: SourceIdentity
    let authorityClosureRevision: String
    let authorityClosureTree: String
    let authorityClosureRunID: Int
    let authorityClosureRunNumber: Int
    let authorityClosureRunAttempt: Int
    let authorityClosureCheckSuiteID: Int
    let authorityClosureActiveJobID: Int
    let authorityClosureActiveJobConclusion: String
    let authorityClosureReviewedJobID: Int
    let authorityClosureReviewedJobConclusion: String
    let authorityClosureConclusion: String
    let authorityClosureArtifactCount: Int
    let authorityClosureRerunCount: Int
    let authorityClosureRetryCount: Int
    let mechanicsHeadRevision: String
    let mechanicsHeadTree: String
    let mechanicsFirstParent: String
    let mechanicsSecondParent: String
    let mechanicsEvent: String
    let mechanicsRef: String
    let mechanicsRunAttempt: Int
    let exactMainRevision: String
    let exactMainTree: String
    let exactChangedSourceIdentities: [SourceIdentity]
    let embeddedSourceIdentitySHA256: String
    let exactMLXRevision: String
    let exactMLXCRevision: String
    let metallibPath: String
    let metallibBytes: Int
    let metallibSHA256: String
    let operatingSystemBuild: String
    let swiftVersion: String
    let xcodeVersion: String
    let swiftSDK: String
    let buildConfiguration: String
    let mlxGraphCompileMode: String

    static func current() throws -> Self {
      let environment = ProcessInfo.processInfo.environment
      let prefix = "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_"
      func required(_ suffix: String) throws -> String {
        let key = prefix + suffix
        guard let value = environment[key], !value.isEmpty else {
          throw AssayError.contractDrift(
            "missing environment \(key)")
        }
        return value
      }
      func integer(_ suffix: String) throws -> Int {
        let value = try required(suffix)
        guard let result = Int(value), String(result) == value else {
          throw AssayError.contractDrift(
            "integer environment \(prefix + suffix)")
        }
        return result
      }
      func identity(_ suffix: String) throws -> SourceIdentity {
        let data = Data(try required(suffix).utf8)
        let value = try JSONDecoder().decode(
          SourceIdentity.self, from: data)
        guard try Self.canonicalJSON(value) == data else {
          throw AssayError.contractDrift(
            "canonical identity environment \(suffix)")
        }
        return value
      }
      func identities(_ suffix: String) throws -> [SourceIdentity] {
        let data = Data(try required(suffix).utf8)
        let value = try JSONDecoder().decode(
          [SourceIdentity].self, from: data)
        guard try Self.canonicalJSON(value) == data else {
          throw AssayError.contractDrift(
            "canonical identities environment \(suffix)")
        }
        return value
      }

      return try .init(
        environment: environment,
        metalLeasePath: required("METAL_LEASE_PATH"),
        authorityID: required("AUTHORITY_ID"),
        authorityCanonicalSHA256: required(
          "AUTHORITY_CANONICAL_SHA256"),
        authoritySourceIdentity: identity(
          "AUTHORITY_SOURCE_IDENTITY_JSON"),
        authorityTestIdentity: identity(
          "AUTHORITY_TEST_IDENTITY_JSON"),
        authorityClosureRevision: required(
          "AUTHORITY_CLOSURE_REVISION"),
        authorityClosureTree: required("AUTHORITY_CLOSURE_TREE"),
        authorityClosureRunID: integer("AUTHORITY_CLOSURE_RUN_ID"),
        authorityClosureRunNumber: integer(
          "AUTHORITY_CLOSURE_RUN_NUMBER"),
        authorityClosureRunAttempt: integer(
          "AUTHORITY_CLOSURE_RUN_ATTEMPT"),
        authorityClosureCheckSuiteID: integer(
          "AUTHORITY_CLOSURE_CHECK_SUITE_ID"),
        authorityClosureActiveJobID: integer(
          "AUTHORITY_CLOSURE_ACTIVE_JOB_ID"),
        authorityClosureActiveJobConclusion: required(
          "AUTHORITY_CLOSURE_ACTIVE_JOB_CONCLUSION"),
        authorityClosureReviewedJobID: integer(
          "AUTHORITY_CLOSURE_REVIEWED_JOB_ID"),
        authorityClosureReviewedJobConclusion: required(
          "AUTHORITY_CLOSURE_REVIEWED_JOB_CONCLUSION"),
        authorityClosureConclusion: required(
          "AUTHORITY_CLOSURE_CONCLUSION"),
        authorityClosureArtifactCount: integer(
          "AUTHORITY_CLOSURE_ARTIFACT_COUNT"),
        authorityClosureRerunCount: integer(
          "AUTHORITY_CLOSURE_RERUN_COUNT"),
        authorityClosureRetryCount: integer(
          "AUTHORITY_CLOSURE_RETRY_COUNT"),
        mechanicsHeadRevision: required("MECHANICS_HEAD_REVISION"),
        mechanicsHeadTree: required("MECHANICS_HEAD_TREE"),
        mechanicsFirstParent: required("MECHANICS_HEAD_FIRST_PARENT"),
        mechanicsSecondParent: required(
          "MECHANICS_HEAD_SECOND_PARENT"),
        mechanicsEvent: required("MECHANICS_EVENT"),
        mechanicsRef: required("MECHANICS_REF"),
        mechanicsRunAttempt: integer("MECHANICS_RUN_ATTEMPT"),
        exactMainRevision: required("EXACT_MAIN_REVISION"),
        exactMainTree: required("EXACT_MAIN_TREE"),
        exactChangedSourceIdentities: identities(
          "EXACT_CHANGED_SOURCE_IDENTITIES_JSON"),
        embeddedSourceIdentitySHA256: required(
          "EMBEDDED_SOURCE_IDENTITY_SHA256"),
        exactMLXRevision: required("EXACT_MLX_REVISION"),
        exactMLXCRevision: required("EXACT_MLX_C_REVISION"),
        metallibPath: required("METALLIB_PATH"),
        metallibBytes: integer("METALLIB_BYTES"),
        metallibSHA256: required("METALLIB_SHA256"),
        operatingSystemBuild: required("OPERATING_SYSTEM_BUILD"),
        swiftVersion: required("SWIFT_VERSION"),
        xcodeVersion: required("XCODE_VERSION"),
        swiftSDK: required("SWIFT_SDK"),
        buildConfiguration: required("BUILD_CONFIGURATION"),
        mlxGraphCompileMode: required("MLX_GRAPH_COMPILE_MODE"))
    }

    private static func canonicalJSON<Value: Encodable>(
      _ value: Value
    ) throws -> Data {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
      return try encoder.encode(value)
    }
  }

  private struct ArmAPairObservation {
    let trialOrdinal: Int
    let uninterrupted: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
    let sourceSnapshot: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
  }

  private struct ArmAResult {
    let pairs: [ArmAPairObservation]
    let receipt: ArmAReceipt
  }

  private struct BTrialObservation {
    let trialOrdinal: Int
    let initialForward: PrimeNativeDecoderTinyTrainingInputPathForwardEquivalenceObservationV1
    let uninterruptedSourceStep: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
    let sourceSnapshotSourceStep: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
    let uninterruptedSourceEvaluation: PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1
    let sourceSnapshotSourceEvaluation: PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1
    let uninterruptedSourceBoundary: PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
    let sourceSnapshotSourceBoundary: PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
    let sourceForward: PrimeNativeDecoderTinyTrainingInputPathForwardEquivalenceObservationV1
    let restoredSourceEvaluation: PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1
    let restoredSourceBoundary: PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
    let uninterruptedSuccessorStep: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
    let sourceSnapshotSuccessorStep: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
    let restoredSuccessorStep: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
    let uninterruptedTerminalEvaluation:
      PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1
    let sourceSnapshotTerminalEvaluation:
      PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1
    let restoredTerminalEvaluation: PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1
    let uninterruptedTerminalBoundary: PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
    let sourceSnapshotTerminalBoundary: PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
    let restoredTerminalBoundary: PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
    let terminalForward: PrimeNativeDecoderTinyTrainingInputPathForwardEquivalenceObservationV1
    let selectors: [SelectorByBranch]
  }

  private struct ArmBResult {
    let trials: [BTrialObservation]
    let receipt: ArmBReceipt
    let forwardReceipt: ForwardReceipt
    let operationCounts: OperationCounts
  }

  private struct MismatchCandidate {
    let mismatch: FirstMismatch
    let domainRank: Int
    let branchRank: Int
    let pathOrScalar: String
    let byteOrScalarOrdinal: Int
  }

  private struct ComparisonAccumulator {
    var domainResults = Dictionary(
      uniqueKeysWithValues:
        PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests
        .replayDomains.map { ($0, true) })
    var candidates = [MismatchCandidate]()

    mutating func scalar(
      domain: String,
      trialOrdinal: Int,
      branch: String,
      referenceBranch: String,
      observedBranch: String,
      scalarName: String,
      referenceBits: UInt32,
      observedBits: UInt32,
      arm: String = "arm_b"
    ) {
      guard referenceBits != observedBits else { return }
      if domainResults[domain] != nil {
        domainResults[domain] = false
      }
      let mismatch = FirstMismatch(
        arm: arm,
        branch: branch,
        byte_offset: nil,
        comparison_domain: domain,
        component: "scalar_float32_bits",
        dtype: nil,
        forward_boundary: nil,
        observed_branch: observedBranch,
        observed_scalar_float32_bits: observedBits,
        observed_sha256: nil,
        parameter_or_tensor_path: nil,
        reference_branch: referenceBranch,
        reference_scalar_float32_bits: referenceBits,
        reference_sha256: nil,
        scalar_name: scalarName,
        shape: nil,
        trial_ordinal: trialOrdinal)
      candidates.append(
        .init(
          mismatch: mismatch,
          domainRank: Self.domainRank(domain),
          branchRank: Self.branchRank(branch),
          pathOrScalar: scalarName,
          byteOrScalarOrdinal: 0))
    }

    mutating func tensor(
      domain: String,
      trialOrdinal: Int,
      branch: String,
      referenceBranch: String,
      observedBranch: String,
      component: String,
      path: String,
      dtype: String,
      shape: [Int],
      referenceBytes: [UInt8],
      observedBytes: [UInt8],
      forwardBoundary: String? = nil,
      arm: String = "arm_b"
    ) throws {
      guard referenceBytes.count == observedBytes.count else {
        throw AssayError.contractDrift(
          "compared tensor byte count")
      }
      guard
        let offset = referenceBytes.indices.first(where: {
          referenceBytes[$0] != observedBytes[$0]
        })
      else { return }
      if domainResults[domain] != nil {
        domainResults[domain] = false
      }
      let mismatch = FirstMismatch(
        arm: arm,
        branch: branch,
        byte_offset: offset,
        comparison_domain: domain,
        component: component,
        dtype: dtype,
        forward_boundary: forwardBoundary,
        observed_branch: observedBranch,
        observed_scalar_float32_bits: nil,
        observed_sha256: PrimeSHA256.hexDigest(
          of: Data(observedBytes)),
        parameter_or_tensor_path: path,
        reference_branch: referenceBranch,
        reference_scalar_float32_bits: nil,
        reference_sha256: PrimeSHA256.hexDigest(
          of: Data(referenceBytes)),
        scalar_name: nil,
        shape: shape,
        trial_ordinal: trialOrdinal)
      candidates.append(
        .init(
          mismatch: mismatch,
          domainRank: Self.domainRank(domain),
          branchRank: Self.branchRank(branch),
          pathOrScalar: path,
          byteOrScalarOrdinal: offset))
    }

    private static func domainRank(_ domain: String) -> Int {
      PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests
        .mismatchDomainOrder.firstIndex(of: domain) ?? Int.max
    }

    private static func branchRank(_ branch: String) -> Int {
      PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests
        .branchNames.firstIndex(of: branch) ?? Int.max
    }
  }

  private struct MutableOperationCounts {
    var armASourceStepCount = 0
    var armBTrainingStepCount = 0
    var armBSnapshotCount = 0
    var armBRestoreCount = 0
    var armBEvaluateCount = 0
    var armBForwardEquivalenceCheckCount = 0

    var receipt: OperationCounts {
      let denseWholeLogitsCallCount =
        armBTrainingStepCount * 2
        + armBEvaluateCount
        + armBForwardEquivalenceCheckCount
      let inputEmbeddingPairSeamCount =
        armBForwardEquivalenceCheckCount
      let denseEmbeddingConstructionCount =
        denseWholeLogitsCallCount + inputEmbeddingPairSeamCount
      return .init(
        arm_a_source_step_count: armASourceStepCount,
        arm_b_dense_embedding_construction_count:
          denseEmbeddingConstructionCount,
        arm_b_dense_whole_logits_call_count:
          denseWholeLogitsCallCount,
        arm_b_evaluate_count: armBEvaluateCount,
        arm_b_forward_equivalence_check_count:
          armBForwardEquivalenceCheckCount,
        arm_b_input_embedding_pair_seam_count:
          inputEmbeddingPairSeamCount,
        arm_b_restore_count: armBRestoreCount,
        arm_b_snapshot_count: armBSnapshotCount,
        arm_b_token_bounds_checked_eval_count:
          denseEmbeddingConstructionCount,
        arm_b_token_bounds_gpu_synchronize_count:
          denseEmbeddingConstructionCount,
        arm_b_token_bounds_host_bool_item_count:
          denseEmbeddingConstructionCount,
        arm_b_token_bounds_validation_count:
          denseEmbeddingConstructionCount,
        arm_b_training_step_count: armBTrainingStepCount,
        receipt_count: 1,
        synchronize_count:
          denseEmbeddingConstructionCount
          + armBForwardEquivalenceCheckCount)
    }
  }

  private static let branchNames = [
    "uninterrupted",
    "source_snapshot",
    "fresh_restored_from_source_snapshot",
  ]
  private static let boundaryNames = [
    "initial", "source_boundary", "terminal",
  ]
  private static let replayDomains = [
    "control_rng_and_cursor_state",
    "evaluation_loss_and_logits_bytes",
    "global_step_and_selected_target_count",
    "model_parameter_bytes",
    "optimizer_first_and_second_moment_bytes",
    "raw_and_clipped_gradient_bytes",
    "training_loss_norm_and_clip_scalar_bits",
  ]
  private static let forwardDomains = [
    "arm_b_embedding_forward_bytes_against_arm_a",
    "arm_b_whole_logits_forward_bytes_against_arm_a",
  ]
  private static let mismatchDomainOrder = forwardDomains + replayDomains

  private static func validateAuthorityAndExecutionInputs(
    _ inputs: ExecutionInputs
  ) throws {
    let authority =
      PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
      .frozenV1
    try authority.validate()
    let runtimeAuthorityCanonicalSHA256 = PrimeSHA256.hexDigest(
      of: try authority.canonicalData())
    guard inputs.authorityID == authority.authorityID,
      inputs.authorityCanonicalSHA256
        == PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
        .canonicalSHA256,
      inputs.authorityCanonicalSHA256
        == runtimeAuthorityCanonicalSHA256,
      isLowercaseHex(
        inputs.authorityCanonicalSHA256, exactCount: 64),
      inputs.authoritySourceIdentity
        == .init(
          path:
            "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthority.swift",
          git_mode: "100644",
          git_blob: "ded305476edfc832ae4e910b1985da77c7a10cd0",
          byte_count: 144_935,
          sha256:
            "634eabe81f63a570cfe2f565d95befbd8c77ea98ba7864a212f45511c7f8b5fc",
          role: "replacement_execution_authority_source"),
      inputs.authorityTestIdentity
        == .init(
          path:
            "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityTests.swift",
          git_mode: "100644",
          git_blob: "e7e240f6bb6e037f0b41f28d925ce0fcd38c42a7",
          byte_count: 49_796,
          sha256:
            "71506cbc21fb8d03886bdc95500e6249f5d61a59f84569dfda95875289435e08",
          role: "replacement_execution_authority_test")
    else {
      throw AssayError.contractDrift("authority binding")
    }

    guard
      inputs.authorityClosureRevision
        == "a0ce9561bdbc867b12f13aed7a7f54846faf3020",
      inputs.authorityClosureTree
        == "e7f85dcecbc82b7e74065cc1991175152f53c13f",
      inputs.authorityClosureRunID == 31_824_087_086,
      inputs.authorityClosureRunNumber == 115,
      inputs.authorityClosureRunAttempt == 1,
      inputs.authorityClosureCheckSuiteID == 86_338_204_723,
      inputs.authorityClosureActiveJobID == 94_843_969_773,
      inputs.authorityClosureReviewedJobID == 94_844_683_376,
      inputs.authorityClosureActiveJobConclusion == "success",
      inputs.authorityClosureReviewedJobConclusion == "success",
      inputs.authorityClosureConclusion == "success",
      inputs.authorityClosureArtifactCount == 0,
      inputs.authorityClosureRerunCount == 0,
      inputs.authorityClosureRetryCount == 0
    else {
      throw AssayError.contractDrift("authority closure binding")
    }

    guard isLowercaseHex(inputs.mechanicsHeadRevision, exactCount: 40),
      isLowercaseHex(inputs.mechanicsHeadTree, exactCount: 40),
      inputs.mechanicsFirstParent == inputs.authorityClosureRevision,
      isLowercaseHex(inputs.mechanicsSecondParent, exactCount: 40),
      inputs.mechanicsSecondParent != inputs.mechanicsFirstParent,
      inputs.mechanicsHeadRevision == inputs.exactMainRevision,
      inputs.mechanicsHeadTree == inputs.exactMainTree,
      inputs.mechanicsEvent == "push",
      inputs.mechanicsRef == "refs/heads/main",
      inputs.mechanicsRunAttempt == 1,
      inputs.environment["GITHUB_REPOSITORY"]
        == "Ergentics/ergentics-prime",
      inputs.environment["GITHUB_EVENT_NAME"] == "push",
      inputs.environment["GITHUB_REF"] == "refs/heads/main",
      inputs.environment["GITHUB_RUN_ATTEMPT"] == "1"
    else {
      throw AssayError.contractDrift("exact-main mechanics binding")
    }

    let expectedPathsAndRoles = [
      (
        ".github/scripts/prime-ci-active-root-quarantine.sh",
        "active_root_gate", "100755"
      ),
      (
        ".github/scripts/prime-ci-native-decoder-stage5-repeated-trajectory-replacement.sh",
        "replacement_launcher", "100755"
      ),
      (
        ".github/workflows/prime-active-root-quarantine.yml",
        "workflow", "100644"
      ),
      (
        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
        "embedded_provenance", "100644"
      ),
      (
        "Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift",
        "current_decoder_identity_source", "100644"
      ),
      (
        "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
        "decoder_source", "100644"
      ),
      (
        "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
        "training_source", "100644"
      ),
      (
        "Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift",
        "current_decoder_identity_test", "100644"
      ),
      (
        "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift",
        "replacement_assay_test", "100644"
      ),
      (
        "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift",
        "retained_decoder_authority_test", "100644"
      ),
    ]
    guard
      inputs.exactChangedSourceIdentities.count
        == expectedPathsAndRoles.count
    else {
      throw AssayError.contractDrift("exact changed identity count")
    }
    for (identity, expected) in zip(
      inputs.exactChangedSourceIdentities,
      expectedPathsAndRoles)
    {
      guard identity.path == expected.0,
        identity.role == expected.1,
        identity.git_mode == expected.2,
        identity.byte_count > 0,
        isLowercaseHex(identity.git_blob, exactCount: 40),
        isLowercaseHex(identity.sha256, exactCount: 64)
      else {
        throw AssayError.contractDrift(
          "exact changed identity \(expected.1)")
      }
    }

    guard
      inputs.embeddedSourceIdentitySHA256
        == PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
      isLowercaseHex(
        inputs.embeddedSourceIdentitySHA256, exactCount: 64),
      inputs.exactMLXRevision
        == "d37885a278f1c37484a94d0f401a418735e66519",
      inputs.exactMLXCRevision
        == "0726ca922fc902c4c61ef9c27d94132be418e945",
      isLowercaseHex(inputs.metallibSHA256, exactCount: 64),
      inputs.metallibBytes > 0,
      inputs.metallibPath.hasPrefix("/"),
      !inputs.metallibPath.hasSuffix("/"),
      inputs.metalLeasePath.hasPrefix("/"),
      !inputs.metalLeasePath.hasSuffix("/"),
      inputs.buildConfiguration == "debug",
      inputs.buildConfiguration
        == PrimeEmbeddedBuildProvenance.buildConfiguration,
      inputs.mlxGraphCompileMode
        == "eager_uncompiled_no_compile_transform",
      inputs.environment["MLX_ENABLE_TF32"] == "0"
    else {
      throw AssayError.contractDrift("execution environment")
    }
  }

  private static func validateLeaseAndMetallib(
    _ inputs: ExecutionInputs
  ) throws {
    let leaseURL = URL(fileURLWithPath: inputs.metalLeasePath)
    let parentPath = leaseURL.deletingLastPathComponent().path
    var leaseStatus = stat()
    var parentStatus = stat()
    guard lstat(inputs.metalLeasePath, &leaseStatus) == 0,
      lstat(parentPath, &parentStatus) == 0,
      leaseStatus.st_mode & S_IFMT == S_IFREG,
      parentStatus.st_mode & S_IFMT == S_IFDIR,
      leaseStatus.st_uid == geteuid(),
      parentStatus.st_uid == geteuid(),
      leaseStatus.st_nlink == 1,
      leaseStatus.st_mode & mode_t(0o777) == mode_t(0o600),
      parentStatus.st_mode & mode_t(0o777) == mode_t(0o700)
    else {
      throw AssayError.contractDrift("lease metadata")
    }

    var metallibStatus = stat()
    guard lstat(inputs.metallibPath, &metallibStatus) == 0,
      metallibStatus.st_mode & S_IFMT == S_IFREG,
      metallibStatus.st_nlink == 1,
      metallibStatus.st_size == inputs.metallibBytes
    else {
      throw AssayError.contractDrift("metallib metadata")
    }
    let metallibData = try Data(
      contentsOf: URL(fileURLWithPath: inputs.metallibPath),
      options: [.mappedIfSafe])
    guard metallibData.count == inputs.metallibBytes,
      PrimeSHA256.hexDigest(of: metallibData)
        == inputs.metallibSHA256
    else {
      throw AssayError.contractDrift("metallib identity")
    }
  }

  private static func isLowercaseHex(
    _ value: String,
    exactCount: Int
  ) -> Bool {
    value.utf8.count == exactCount
      && value.utf8.allSatisfy {
        (48...57).contains($0) || (97...102).contains($0)
      }
  }

  private static func runArmA(gpu: Device) throws -> ArmAResult {
    var pairs = [ArmAPairObservation]()
    var sourceStepEqual = [PairBoolean]()
    var globalStepOne = [PairBoolean]()
    var selectedTargetCountSix = [PairBoolean]()
    var comparisons = ComparisonAccumulator()

    for trialOrdinal in 1...3 {
      let uninterrupted =
        try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
          metalGPUIndexZero: gpu)
      let sourceSnapshot =
        try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
          metalGPUIndexZero: gpu)
      guard uninterrupted !== sourceSnapshot else {
        throw AssayError.contractDrift("Arm A fresh source objects")
      }
      let uninterruptedStep =
        try uninterrupted.trainNextExactMetalTrajectoryStep()
      let sourceSnapshotStep =
        try sourceSnapshot.trainNextExactMetalTrajectoryStep()
      try validateStepInfrastructure(uninterruptedStep)
      try validateStepInfrastructure(sourceSnapshotStep)

      let pair = ArmAPairObservation(
        trialOrdinal: trialOrdinal,
        uninterrupted: uninterruptedStep,
        sourceSnapshot: sourceSnapshotStep)
      pairs.append(pair)
      sourceStepEqual.append(
        pairBoolean(
          trialOrdinal: trialOrdinal,
          exact: uninterruptedStep == sourceSnapshotStep))
      globalStepOne.append(
        pairBoolean(
          trialOrdinal: trialOrdinal,
          exact: uninterruptedStep.result.globalStep == 1
            && sourceSnapshotStep.result.globalStep == 1))
      selectedTargetCountSix.append(
        pairBoolean(
          trialOrdinal: trialOrdinal,
          exact: uninterruptedStep.result.selectedTargetCount == 6
            && sourceSnapshotStep.result.selectedTargetCount == 6))

      try compareSteps(
        uninterruptedStep,
        sourceSnapshotStep,
        trialOrdinal: trialOrdinal,
        referenceBranch: "uninterrupted",
        observedBranch: "source_snapshot",
        accumulator: &comparisons,
        arm: "arm_a",
        domainPrefix: "maintained_gather_source_step")
      for (branch, step) in [
        ("uninterrupted", uninterruptedStep),
        ("source_snapshot", sourceSnapshotStep),
      ] {
        comparisons.scalar(
          domain: "maintained_gather_source_step_scalar_bits",
          trialOrdinal: trialOrdinal,
          branch: branch,
          referenceBranch: "expected_fixture",
          observedBranch: branch,
          scalarName: "global_step",
          referenceBits: Float(1).bitPattern,
          observedBits: Float(step.result.globalStep).bitPattern,
          arm: "arm_a")
        comparisons.scalar(
          domain: "maintained_gather_source_step_scalar_bits",
          trialOrdinal: trialOrdinal,
          branch: branch,
          referenceBranch: "expected_fixture",
          observedBranch: branch,
          scalarName: "selected_target_count",
          referenceBits: Float(6).bitPattern,
          observedBits:
            Float(step.result.selectedTargetCount).bitPattern,
          arm: "arm_a")
      }
    }

    let tensorCandidates = comparisons.candidates.filter {
      $0.mismatch.arm == "arm_a"
        && $0.mismatch.observed_scalar_float32_bits == nil
    }.sorted(by: candidateLess)
    let scalarCandidates = comparisons.candidates.filter {
      $0.mismatch.arm == "arm_a"
        && $0.mismatch.observed_scalar_float32_bits != nil
    }.sorted(by: candidateLess)
    let measuredMismatch =
      sourceStepEqual.contains { !$0.exact }
      || globalStepOne.contains { !$0.exact }
      || selectedTargetCountSix.contains { !$0.exact }
    let receipt = ArmAReceipt(
      completed_diagnostic_pair_count: pairs.count,
      first_scalar_mismatch: scalarCandidates.first.map {
        .value($0.mismatch)
      } ?? .null,
      first_tensor_mismatch: tensorCandidates.first.map {
        .value($0.mismatch)
      } ?? .null,
      global_step_one_by_pair: globalStepOne,
      measured_mismatch: measuredMismatch,
      pair_branch_names: ["uninterrupted", "source_snapshot"],
      selected_target_count_six_by_pair: selectedTargetCountSix,
      source_step_equal_by_pair: sourceStepEqual,
      trial_count: pairs.count)
    return .init(pairs: pairs, receipt: receipt)
  }

  private static func runArmB(
    gpu: Device,
    armASourceStepCount: Int
  ) throws -> ArmBResult {
    var counts = MutableOperationCounts()
    counts.armASourceStepCount = armASourceStepCount
    var trials = [BTrialObservation]()
    let bPath =
      PrimeNativeDecoderTinyMetalTrajectoryTrainingInputPathV1
      .denseOneHotMatmulV1

    for trialOrdinal in 1...3 {
      let uninterrupted =
        try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
          metalGPUIndexZero: gpu,
          stage5ReplacementTrainingInputPath: bPath)
      let sourceSnapshot =
        try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
          metalGPUIndexZero: gpu,
          stage5ReplacementTrainingInputPath: bPath)
      guard uninterrupted !== sourceSnapshot else {
        throw AssayError.contractDrift("Arm B fresh source objects")
      }
      var selectors = [
        SelectorByBranch(
          trial_ordinal: trialOrdinal,
          branch: "uninterrupted",
          selector_id:
            uninterrupted.stage5ReplacementTrainingInputPathID),
        SelectorByBranch(
          trial_ordinal: trialOrdinal,
          branch: "source_snapshot",
          selector_id:
            sourceSnapshot.stage5ReplacementTrainingInputPathID),
      ]

      let initialForward =
        try uninterrupted
        .checkedTrainingInputPathForwardEquivalenceAtCurrentBoundaryV1()
      counts.armBForwardEquivalenceCheckCount += 1

      let uninterruptedSourceStep =
        try uninterrupted.trainNextExactMetalTrajectoryStep()
      counts.armBTrainingStepCount += 1
      let sourceSnapshotSourceStep =
        try sourceSnapshot.trainNextExactMetalTrajectoryStep()
      counts.armBTrainingStepCount += 1

      let uninterruptedSourceEvaluation =
        try uninterrupted.checkedEvaluateExactMetalTrajectory()
      counts.armBEvaluateCount += 1
      let sourceSnapshotSourceEvaluation =
        try sourceSnapshot.checkedEvaluateExactMetalTrajectory()
      counts.armBEvaluateCount += 1
      let uninterruptedSourceBoundary =
        try uninterrupted.exactMetalTrajectoryBoundaryState()
      let sourceSnapshotSourceBoundary =
        try sourceSnapshot.exactMetalTrajectoryBoundaryState()

      let sourceForward =
        try sourceSnapshot
        .checkedTrainingInputPathForwardEquivalenceAtCurrentBoundaryV1()
      counts.armBForwardEquivalenceCheckCount += 1

      let snapshot = try sourceSnapshot.exportInMemoryResumeSnapshot()
      counts.armBSnapshotCount += 1
      let sourceBoundaryAfterExport =
        try sourceSnapshot.exactMetalTrajectoryBoundaryState()
      guard sourceBoundaryAfterExport == sourceSnapshotSourceBoundary
      else {
        throw AssayError.contractDrift(
          "Arm B snapshot capture mutated boundary")
      }
      let sourceSnapshotSuccessorStep =
        try sourceSnapshot.trainNextExactMetalTrajectoryStep()
      counts.armBTrainingStepCount += 1

      let restored =
        try PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1(
          restoring: snapshot,
          metalGPUIndexZero: gpu,
          stage5ReplacementTrainingInputPath: bPath)
      counts.armBRestoreCount += 1
      guard restored !== sourceSnapshot,
        restored !== uninterrupted
      else {
        throw AssayError.contractDrift("Arm B fresh restored object")
      }
      selectors.append(
        .init(
          trial_ordinal: trialOrdinal,
          branch: "fresh_restored_from_source_snapshot",
          selector_id:
            restored.stage5ReplacementTrainingInputPathID))

      let restoredSourceEvaluation =
        try restored.checkedEvaluateExactMetalTrajectory()
      counts.armBEvaluateCount += 1
      let restoredSourceBoundary =
        try restored.exactMetalTrajectoryBoundaryState()

      let uninterruptedSuccessorStep =
        try uninterrupted.trainNextExactMetalTrajectoryStep()
      counts.armBTrainingStepCount += 1
      let restoredSuccessorStep =
        try restored.trainNextExactMetalTrajectoryStep()
      counts.armBTrainingStepCount += 1

      let uninterruptedTerminalEvaluation =
        try uninterrupted.checkedEvaluateExactMetalTrajectory()
      counts.armBEvaluateCount += 1
      let sourceSnapshotTerminalEvaluation =
        try sourceSnapshot.checkedEvaluateExactMetalTrajectory()
      counts.armBEvaluateCount += 1
      let restoredTerminalEvaluation =
        try restored.checkedEvaluateExactMetalTrajectory()
      counts.armBEvaluateCount += 1
      let uninterruptedTerminalBoundary =
        try uninterrupted.exactMetalTrajectoryBoundaryState()
      let sourceSnapshotTerminalBoundary =
        try sourceSnapshot.exactMetalTrajectoryBoundaryState()
      let restoredTerminalBoundary =
        try restored.exactMetalTrajectoryBoundaryState()

      let terminalForward =
        try restored
        .checkedTrainingInputPathForwardEquivalenceAtCurrentBoundaryV1()
      counts.armBForwardEquivalenceCheckCount += 1

      let trial = BTrialObservation(
        trialOrdinal: trialOrdinal,
        initialForward: initialForward,
        uninterruptedSourceStep: uninterruptedSourceStep,
        sourceSnapshotSourceStep: sourceSnapshotSourceStep,
        uninterruptedSourceEvaluation:
          uninterruptedSourceEvaluation,
        sourceSnapshotSourceEvaluation:
          sourceSnapshotSourceEvaluation,
        uninterruptedSourceBoundary: uninterruptedSourceBoundary,
        sourceSnapshotSourceBoundary: sourceSnapshotSourceBoundary,
        sourceForward: sourceForward,
        restoredSourceEvaluation: restoredSourceEvaluation,
        restoredSourceBoundary: restoredSourceBoundary,
        uninterruptedSuccessorStep: uninterruptedSuccessorStep,
        sourceSnapshotSuccessorStep: sourceSnapshotSuccessorStep,
        restoredSuccessorStep: restoredSuccessorStep,
        uninterruptedTerminalEvaluation:
          uninterruptedTerminalEvaluation,
        sourceSnapshotTerminalEvaluation:
          sourceSnapshotTerminalEvaluation,
        restoredTerminalEvaluation: restoredTerminalEvaluation,
        uninterruptedTerminalBoundary: uninterruptedTerminalBoundary,
        sourceSnapshotTerminalBoundary:
          sourceSnapshotTerminalBoundary,
        restoredTerminalBoundary: restoredTerminalBoundary,
        terminalForward: terminalForward,
        selectors: selectors)
      try validateBTrialInfrastructure(trial)
      trials.append(trial)
    }

    guard trials.count == 3 else {
      throw AssayError.contractDrift("Arm B trial count")
    }
    var comparisons = ComparisonAccumulator()
    var embeddingForward = [ForwardBoolean]()
    var wholeLogitsForward = [ForwardBoolean]()
    for trial in trials {
      try compareForward(
        trial.initialForward,
        boundary: "initial",
        trialOrdinal: trial.trialOrdinal,
        accumulator: &comparisons,
        embeddingResults: &embeddingForward,
        wholeLogitsResults: &wholeLogitsForward)
      try compareForward(
        trial.sourceForward,
        boundary: "source_boundary",
        trialOrdinal: trial.trialOrdinal,
        accumulator: &comparisons,
        embeddingResults: &embeddingForward,
        wholeLogitsResults: &wholeLogitsForward)
      try compareForward(
        trial.terminalForward,
        boundary: "terminal",
        trialOrdinal: trial.trialOrdinal,
        accumulator: &comparisons,
        embeddingResults: &embeddingForward,
        wholeLogitsResults: &wholeLogitsForward)
      try compareTrialReplayWithin(
        trial,
        accumulator: &comparisons)
    }
    let baseline = trials[0]
    for trial in trials.dropFirst() {
      try compareTrialReplayAcrossTrials(
        baseline,
        trial,
        accumulator: &comparisons)
    }

    let replayResults = replayDomains.map {
      DomainBoolean(
        comparison_domain: $0,
        exact: comparisons.domainResults[$0] == true)
    }
    let allReplayExact = replayResults.allSatisfy(\.exact)
    let allForwardExact =
      embeddingForward.allSatisfy(\.exact)
      && wholeLogitsForward.allSatisfy(\.exact)
    let status =
      allReplayExact && allForwardExact
      ? "PASS_CLEARANCE"
      : "MEASURED_EXACT_MISMATCH"
    let firstMismatch = comparisons.candidates
      .sorted(by: candidateLess).first
    let selectorIDs = trials.flatMap(\.selectors)
    let receipt = ArmBReceipt(
      all_exact_comparisons_passed: allReplayExact,
      all_forward_equivalence_checks_passed: allForwardExact,
      branch_names: branchNames,
      comparison_domain_results: replayResults,
      first_mismatch: firstMismatch.map { .value($0.mismatch) }
        ?? .null,
      fresh_constructor:
        "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(metalGPUIndexZero:stage5ReplacementTrainingInputPath:)",
      restore_constructor:
        "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(restoring:metalGPUIndexZero:stage5ReplacementTrainingInputPath:)",
      selector_id_by_branch: selectorIDs,
      status: status,
      trajectory_branch_count: selectorIDs.count,
      trial_count: trials.count)
    let forwardReceipt = ForwardReceipt(
      boundary_names: boundaryNames,
      embedding_forward_exact_by_boundary: embeddingForward,
      same_model_pre_mutation: true,
      whole_logits_exact_by_boundary: wholeLogitsForward)
    return .init(
      trials: trials,
      receipt: receipt,
      forwardReceipt: forwardReceipt,
      operationCounts: counts.receipt)
  }

  private static func validateBTrialInfrastructure(
    _ trial: BTrialObservation
  ) throws {
    for step in [
      trial.uninterruptedSourceStep,
      trial.sourceSnapshotSourceStep,
      trial.uninterruptedSuccessorStep,
      trial.sourceSnapshotSuccessorStep,
      trial.restoredSuccessorStep,
    ] {
      try validateStepInfrastructure(step)
    }
    for evaluation in [
      trial.uninterruptedSourceEvaluation,
      trial.sourceSnapshotSourceEvaluation,
      trial.restoredSourceEvaluation,
      trial.uninterruptedTerminalEvaluation,
      trial.sourceSnapshotTerminalEvaluation,
      trial.restoredTerminalEvaluation,
    ] {
      try validateEvaluationInfrastructure(evaluation)
    }
    for boundary in [
      trial.uninterruptedSourceBoundary,
      trial.sourceSnapshotSourceBoundary,
      trial.restoredSourceBoundary,
      trial.uninterruptedTerminalBoundary,
      trial.sourceSnapshotTerminalBoundary,
      trial.restoredTerminalBoundary,
    ] {
      try validateBoundaryInfrastructure(boundary)
    }
    for forward in [
      trial.initialForward,
      trial.sourceForward,
      trial.terminalForward,
    ] {
      try validateForwardInfrastructure(forward)
    }
    guard trial.selectors.count == 3,
      trial.selectors.map(\.branch) == branchNames,
      trial.selectors.allSatisfy({
        $0.trial_ordinal == trial.trialOrdinal
          && $0.selector_id
            == "flattened_dense_one_hot_matmul_input_embedding_v1"
      }),
      trial.uninterruptedSourceStep.result.globalStep == 1,
      trial.sourceSnapshotSourceStep.result.globalStep == 1,
      trial.uninterruptedSourceStep.result.selectedTargetCount == 6,
      trial.sourceSnapshotSourceStep.result.selectedTargetCount == 6,
      trial.uninterruptedSuccessorStep.result.globalStep == 2,
      trial.sourceSnapshotSuccessorStep.result.globalStep == 2,
      trial.restoredSuccessorStep.result.globalStep == 2,
      trial.uninterruptedSuccessorStep.result.selectedTargetCount == 5,
      trial.sourceSnapshotSuccessorStep.result.selectedTargetCount == 5,
      trial.restoredSuccessorStep.result.selectedTargetCount == 5,
      trial.uninterruptedSourceEvaluation.result.globalStep == 1,
      trial.sourceSnapshotSourceEvaluation.result.globalStep == 1,
      trial.restoredSourceEvaluation.result.globalStep == 1,
      trial.uninterruptedSourceEvaluation.result.selectedTargetCount == 7,
      trial.sourceSnapshotSourceEvaluation.result.selectedTargetCount == 7,
      trial.restoredSourceEvaluation.result.selectedTargetCount == 7,
      trial.uninterruptedTerminalEvaluation.result.globalStep == 2,
      trial.sourceSnapshotTerminalEvaluation.result.globalStep == 2,
      trial.restoredTerminalEvaluation.result.globalStep == 2,
      trial.uninterruptedTerminalEvaluation.result.selectedTargetCount == 7,
      trial.sourceSnapshotTerminalEvaluation.result.selectedTargetCount == 7,
      trial.restoredTerminalEvaluation.result.selectedTargetCount == 7,
      trial.uninterruptedSourceBoundary.globalStep == 1,
      trial.sourceSnapshotSourceBoundary.globalStep == 1,
      trial.restoredSourceBoundary.globalStep == 1,
      trial.uninterruptedTerminalBoundary.globalStep == 2,
      trial.sourceSnapshotTerminalBoundary.globalStep == 2,
      trial.restoredTerminalBoundary.globalStep == 2
    else {
      throw AssayError.contractDrift("Arm B fixture topology")
    }
  }

  private static func compareForward(
    _ observation:
      PrimeNativeDecoderTinyTrainingInputPathForwardEquivalenceObservationV1,
    boundary: String,
    trialOrdinal: Int,
    accumulator: inout ComparisonAccumulator,
    embeddingResults: inout [ForwardBoolean],
    wholeLogitsResults: inout [ForwardBoolean]
  ) throws {
    let branch =
      boundary == "initial"
      ? "uninterrupted"
      : boundary == "source_boundary"
        ? "source_snapshot"
        : "fresh_restored_from_source_snapshot"
    let embeddingExact =
      observation.maintainedGatherEmbedding.shape
      == observation.denseEmbedding.shape
      && observation.maintainedGatherEmbedding.dtype
        == observation.denseEmbedding.dtype
      && observation.maintainedGatherEmbedding
        .float32LittleEndianBytes
        == observation.denseEmbedding.float32LittleEndianBytes
    embeddingResults.append(
      .init(
        trial_ordinal: trialOrdinal,
        boundary: boundary,
        exact: embeddingExact))
    try accumulator.tensor(
      domain: "arm_b_embedding_forward_bytes_against_arm_a",
      trialOrdinal: trialOrdinal,
      branch: branch,
      referenceBranch: "maintained_gather_v1",
      observedBranch:
        "flattened_dense_one_hot_matmul_input_embedding_v1",
      component: "input_embedding_forward_bytes",
      path: boundary + "/input_embedding",
      dtype: observation.maintainedGatherEmbedding.dtype,
      shape: observation.maintainedGatherEmbedding.shape,
      referenceBytes: observation.maintainedGatherEmbedding
        .float32LittleEndianBytes,
      observedBytes: observation.denseEmbedding
        .float32LittleEndianBytes,
      forwardBoundary: boundary)

    let wholeLogitsExact =
      observation.maintainedGatherWholeLogits.shape
      == observation.denseWholeLogits.shape
      && observation.maintainedGatherWholeLogits.dtype
        == observation.denseWholeLogits.dtype
      && observation.maintainedGatherWholeLogits
        .float32LittleEndianBytes
        == observation.denseWholeLogits.float32LittleEndianBytes
    wholeLogitsResults.append(
      .init(
        trial_ordinal: trialOrdinal,
        boundary: boundary,
        exact: wholeLogitsExact))
    try accumulator.tensor(
      domain: "arm_b_whole_logits_forward_bytes_against_arm_a",
      trialOrdinal: trialOrdinal,
      branch: branch,
      referenceBranch: "maintained_gather_v1",
      observedBranch:
        "flattened_dense_one_hot_matmul_input_embedding_v1",
      component: "whole_logits_forward_bytes",
      path: boundary + "/whole_logits",
      dtype: observation.maintainedGatherWholeLogits.dtype,
      shape: observation.maintainedGatherWholeLogits.shape,
      referenceBytes: observation.maintainedGatherWholeLogits
        .float32LittleEndianBytes,
      observedBytes: observation.denseWholeLogits
        .float32LittleEndianBytes,
      forwardBoundary: boundary)
  }

  private static func compareTrialReplayWithin(
    _ trial: BTrialObservation,
    accumulator: inout ComparisonAccumulator
  ) throws {
    let expectedSteps:
      [(
        PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1,
        String,
        Int,
        Int,
        String
      )] = [
        (
          trial.uninterruptedSourceStep,
          "uninterrupted", 1, 6, "source"
        ),
        (
          trial.sourceSnapshotSourceStep,
          "source_snapshot", 1, 6, "source"
        ),
        (
          trial.uninterruptedSuccessorStep,
          "uninterrupted", 2, 5, "successor"
        ),
        (
          trial.sourceSnapshotSuccessorStep,
          "source_snapshot", 2, 5, "successor"
        ),
        (
          trial.restoredSuccessorStep,
          "fresh_restored_from_source_snapshot", 2, 5,
          "successor"
        ),
      ]
    for expected in expectedSteps {
      accumulator.scalar(
        domain: "global_step_and_selected_target_count",
        trialOrdinal: trial.trialOrdinal,
        branch: expected.1,
        referenceBranch: "expected_fixture",
        observedBranch: expected.1,
        scalarName: expected.4 + "_global_step",
        referenceBits: Float(expected.2).bitPattern,
        observedBits:
          Float(expected.0.result.globalStep).bitPattern)
      accumulator.scalar(
        domain: "global_step_and_selected_target_count",
        trialOrdinal: trial.trialOrdinal,
        branch: expected.1,
        referenceBranch: "expected_fixture",
        observedBranch: expected.1,
        scalarName: expected.4 + "_selected_target_count",
        referenceBits: Float(expected.3).bitPattern,
        observedBits:
          Float(expected.0.result.selectedTargetCount).bitPattern)
    }
    let expectedEvaluations:
      [(
        PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1,
        String,
        Int,
        String
      )] = [
        (
          trial.uninterruptedSourceEvaluation,
          "uninterrupted", 1, "source"
        ),
        (
          trial.sourceSnapshotSourceEvaluation,
          "source_snapshot", 1, "source"
        ),
        (
          trial.restoredSourceEvaluation,
          "fresh_restored_from_source_snapshot", 1, "source"
        ),
        (
          trial.uninterruptedTerminalEvaluation,
          "uninterrupted", 2, "terminal"
        ),
        (
          trial.sourceSnapshotTerminalEvaluation,
          "source_snapshot", 2, "terminal"
        ),
        (
          trial.restoredTerminalEvaluation,
          "fresh_restored_from_source_snapshot", 2, "terminal"
        ),
      ]
    for expected in expectedEvaluations {
      accumulator.scalar(
        domain: "global_step_and_selected_target_count",
        trialOrdinal: trial.trialOrdinal,
        branch: expected.1,
        referenceBranch: "expected_fixture",
        observedBranch: expected.1,
        scalarName: expected.3 + "_evaluation_global_step",
        referenceBits: Float(expected.2).bitPattern,
        observedBits:
          Float(expected.0.result.globalStep).bitPattern)
      accumulator.scalar(
        domain: "global_step_and_selected_target_count",
        trialOrdinal: trial.trialOrdinal,
        branch: expected.1,
        referenceBranch: "expected_fixture",
        observedBranch: expected.1,
        scalarName:
          expected.3 + "_evaluation_selected_target_count",
        referenceBits: Float(7).bitPattern,
        observedBits:
          Float(expected.0.result.selectedTargetCount).bitPattern)
    }
    let expectedBoundaries:
      [(
        PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1,
        String,
        Int,
        String
      )] = [
        (
          trial.uninterruptedSourceBoundary,
          "uninterrupted", 1, "source"
        ),
        (
          trial.sourceSnapshotSourceBoundary,
          "source_snapshot", 1, "source"
        ),
        (
          trial.restoredSourceBoundary,
          "fresh_restored_from_source_snapshot", 1, "source"
        ),
        (
          trial.uninterruptedTerminalBoundary,
          "uninterrupted", 2, "terminal"
        ),
        (
          trial.sourceSnapshotTerminalBoundary,
          "source_snapshot", 2, "terminal"
        ),
        (
          trial.restoredTerminalBoundary,
          "fresh_restored_from_source_snapshot", 2, "terminal"
        ),
      ]
    for expected in expectedBoundaries {
      accumulator.scalar(
        domain: "global_step_and_selected_target_count",
        trialOrdinal: trial.trialOrdinal,
        branch: expected.1,
        referenceBranch: "expected_fixture",
        observedBranch: expected.1,
        scalarName: expected.3 + "_boundary_global_step",
        referenceBits: Float(expected.2).bitPattern,
        observedBits: Float(expected.0.globalStep).bitPattern)
    }

    try compareSteps(
      trial.uninterruptedSourceStep,
      trial.sourceSnapshotSourceStep,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "source_snapshot",
      accumulator: &accumulator)
    try compareSteps(
      trial.uninterruptedSuccessorStep,
      trial.sourceSnapshotSuccessorStep,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "source_snapshot",
      accumulator: &accumulator)
    try compareSteps(
      trial.uninterruptedSuccessorStep,
      trial.restoredSuccessorStep,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "fresh_restored_from_source_snapshot",
      accumulator: &accumulator)

    try compareEvaluation(
      trial.uninterruptedSourceEvaluation,
      trial.sourceSnapshotSourceEvaluation,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "source_snapshot",
      accumulator: &accumulator)
    try compareEvaluation(
      trial.uninterruptedSourceEvaluation,
      trial.restoredSourceEvaluation,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "fresh_restored_from_source_snapshot",
      accumulator: &accumulator)
    try compareEvaluation(
      trial.uninterruptedTerminalEvaluation,
      trial.sourceSnapshotTerminalEvaluation,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "source_snapshot",
      accumulator: &accumulator)
    try compareEvaluation(
      trial.uninterruptedTerminalEvaluation,
      trial.restoredTerminalEvaluation,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "fresh_restored_from_source_snapshot",
      accumulator: &accumulator)

    try compareBoundary(
      trial.uninterruptedSourceBoundary,
      trial.sourceSnapshotSourceBoundary,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "source_snapshot",
      accumulator: &accumulator)
    try compareBoundary(
      trial.uninterruptedSourceBoundary,
      trial.restoredSourceBoundary,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "fresh_restored_from_source_snapshot",
      accumulator: &accumulator)
    try compareBoundary(
      trial.uninterruptedTerminalBoundary,
      trial.sourceSnapshotTerminalBoundary,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "source_snapshot",
      accumulator: &accumulator)
    try compareBoundary(
      trial.uninterruptedTerminalBoundary,
      trial.restoredTerminalBoundary,
      trialOrdinal: trial.trialOrdinal,
      referenceBranch: "uninterrupted",
      observedBranch: "fresh_restored_from_source_snapshot",
      accumulator: &accumulator)
  }

  private static func compareTrialReplayAcrossTrials(
    _ reference: BTrialObservation,
    _ observed: BTrialObservation,
    accumulator: inout ComparisonAccumulator
  ) throws {
    let stepPairs:
      [(
        PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1,
        PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1,
        String
      )] = [
        (
          reference.uninterruptedSourceStep,
          observed.uninterruptedSourceStep,
          "uninterrupted"
        ),
        (
          reference.sourceSnapshotSourceStep,
          observed.sourceSnapshotSourceStep,
          "source_snapshot"
        ),
        (
          reference.uninterruptedSuccessorStep,
          observed.uninterruptedSuccessorStep,
          "uninterrupted"
        ),
        (
          reference.sourceSnapshotSuccessorStep,
          observed.sourceSnapshotSuccessorStep,
          "source_snapshot"
        ),
        (
          reference.restoredSuccessorStep,
          observed.restoredSuccessorStep,
          "fresh_restored_from_source_snapshot"
        ),
      ]
    for pair in stepPairs {
      try compareSteps(
        pair.0,
        pair.1,
        trialOrdinal: observed.trialOrdinal,
        referenceBranch: pair.2,
        observedBranch: pair.2,
        accumulator: &accumulator)
    }

    let evaluationPairs:
      [(
        PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1,
        PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1,
        String
      )] = [
        (
          reference.uninterruptedSourceEvaluation,
          observed.uninterruptedSourceEvaluation,
          "uninterrupted"
        ),
        (
          reference.sourceSnapshotSourceEvaluation,
          observed.sourceSnapshotSourceEvaluation,
          "source_snapshot"
        ),
        (
          reference.restoredSourceEvaluation,
          observed.restoredSourceEvaluation,
          "fresh_restored_from_source_snapshot"
        ),
        (
          reference.uninterruptedTerminalEvaluation,
          observed.uninterruptedTerminalEvaluation,
          "uninterrupted"
        ),
        (
          reference.sourceSnapshotTerminalEvaluation,
          observed.sourceSnapshotTerminalEvaluation,
          "source_snapshot"
        ),
        (
          reference.restoredTerminalEvaluation,
          observed.restoredTerminalEvaluation,
          "fresh_restored_from_source_snapshot"
        ),
      ]
    for pair in evaluationPairs {
      try compareEvaluation(
        pair.0,
        pair.1,
        trialOrdinal: observed.trialOrdinal,
        referenceBranch: pair.2,
        observedBranch: pair.2,
        accumulator: &accumulator)
    }

    let boundaryPairs:
      [(
        PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1,
        PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1,
        String
      )] = [
        (
          reference.uninterruptedSourceBoundary,
          observed.uninterruptedSourceBoundary,
          "uninterrupted"
        ),
        (
          reference.sourceSnapshotSourceBoundary,
          observed.sourceSnapshotSourceBoundary,
          "source_snapshot"
        ),
        (
          reference.restoredSourceBoundary,
          observed.restoredSourceBoundary,
          "fresh_restored_from_source_snapshot"
        ),
        (
          reference.uninterruptedTerminalBoundary,
          observed.uninterruptedTerminalBoundary,
          "uninterrupted"
        ),
        (
          reference.sourceSnapshotTerminalBoundary,
          observed.sourceSnapshotTerminalBoundary,
          "source_snapshot"
        ),
        (
          reference.restoredTerminalBoundary,
          observed.restoredTerminalBoundary,
          "fresh_restored_from_source_snapshot"
        ),
      ]
    for pair in boundaryPairs {
      try compareBoundary(
        pair.0,
        pair.1,
        trialOrdinal: observed.trialOrdinal,
        referenceBranch: pair.2,
        observedBranch: pair.2,
        accumulator: &accumulator)
    }
  }

  private static func compareEvaluation(
    _ reference:
      PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1,
    _ observed:
      PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1,
    trialOrdinal: Int,
    referenceBranch: String,
    observedBranch: String,
    accumulator: inout ComparisonAccumulator
  ) throws {
    accumulator.scalar(
      domain: "global_step_and_selected_target_count",
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      scalarName: "evaluation_global_step",
      referenceBits: Float(reference.result.globalStep).bitPattern,
      observedBits: Float(observed.result.globalStep).bitPattern)
    accumulator.scalar(
      domain: "global_step_and_selected_target_count",
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      scalarName: "evaluation_selected_target_count",
      referenceBits:
        Float(reference.result.selectedTargetCount).bitPattern,
      observedBits:
        Float(observed.result.selectedTargetCount).bitPattern)
    accumulator.scalar(
      domain: "evaluation_loss_and_logits_bytes",
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      scalarName: "evaluation_loss",
      referenceBits: reference.result.lossFloat32BitPattern,
      observedBits: observed.result.lossFloat32BitPattern)
    guard
      reference.result.selectedLossFloat32BitPatterns.count
        == observed.result.selectedLossFloat32BitPatterns.count,
      reference.logits.shape == observed.logits.shape,
      reference.logits.dtype == observed.logits.dtype
    else {
      throw AssayError.contractDrift("evaluation comparison inventory")
    }
    for index in reference.result.selectedLossFloat32BitPatterns.indices {
      accumulator.scalar(
        domain: "evaluation_loss_and_logits_bytes",
        trialOrdinal: trialOrdinal,
        branch: observedBranch,
        referenceBranch: referenceBranch,
        observedBranch: observedBranch,
        scalarName: "evaluation_selected_loss_\(index)",
        referenceBits:
          reference.result.selectedLossFloat32BitPatterns[index],
        observedBits:
          observed.result.selectedLossFloat32BitPatterns[index])
    }
    try accumulator.tensor(
      domain: "evaluation_loss_and_logits_bytes",
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      component: "evaluation_logits_bytes",
      path: "evaluation_logits",
      dtype: reference.logits.dtype,
      shape: reference.logits.shape,
      referenceBytes: reference.logits.float32LittleEndianBytes,
      observedBytes: observed.logits.float32LittleEndianBytes)
  }

  private static func compareBoundary(
    _ reference:
      PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1,
    _ observed:
      PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1,
    trialOrdinal: Int,
    referenceBranch: String,
    observedBranch: String,
    accumulator: inout ComparisonAccumulator
  ) throws {
    accumulator.scalar(
      domain: "global_step_and_selected_target_count",
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      scalarName: "boundary_global_step",
      referenceBits: Float(reference.globalStep).bitPattern,
      observedBits: Float(observed.globalStep).bitPattern)
    try accumulator.tensor(
      domain: "control_rng_and_cursor_state",
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      component: "control_state_bytes",
      path: "control_state",
      dtype: "uint8",
      shape: [reference.controlState.canonicalBytes.count],
      referenceBytes: reference.controlState.canonicalBytes,
      observedBytes: observed.controlState.canonicalBytes)
    try compareTensorState(
      reference.tensors,
      observed.tensors,
      trialOrdinal: trialOrdinal,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      accumulator: &accumulator,
      arm: "arm_b",
      domainPrefix: nil)
  }

  private static func makeCanonicalReceiptLine(
    inputs: ExecutionInputs,
    armA: ArmAResult,
    armB: ArmBResult,
    metalDeviceName: String,
    metalDeviceRegistryID: UInt64
  ) throws -> String {
    let pass = armB.receipt.status == "PASS_CLEARANCE"
    let deviceIdentity = DeviceIdentity(
      name: metalDeviceName,
      registry_id: metalDeviceRegistryID)
    let ceiling = CeilingReceipt(
      additional_execution_or_rerun_authorized: false,
      arbitrary_token_determinism_established: false,
      artifact_upload_authorized: false,
      b_specific_native300_resource_witness_authorized: false,
      b_specific_native300_resource_witness_established: false,
      b_specific_native300_resource_witness_requires_separate_authority:
        true,
      candidate_admission_granted: false,
      cross_device_determinism_established: false,
      default_gather_determinism_established: false,
      durable_checkpoint_io_authorized: false,
      exact_same_device_b_path_gradient_bytes_established: pass,
      model_quality_established: false,
      one_shot_consumed: true,
      repeated_same_device_b_path_determinism_established: pass,
      retained_artifact_authorized: false,
      stage5_assay_clearance_established: pass,
      stage5_mechanics_success_established: true,
      stage5_result_established: true,
      stage6_historical_resource_clearance_applies_to_b_path: false,
      stage6_resource_clearance_remains_historical: true,
      stage7_authority_established: false,
      stage7_authorized: false,
      stage7_requires_new_b_specific_native300_resource_witness: true,
      stage7_requires_separate_authority_after_witness: true)
    let receipt = Receipt(
      arm_a: armA.receipt,
      arm_b: armB.receipt,
      authority: .init(
        authority_canonical_sha256:
          inputs.authorityCanonicalSHA256,
        authority_id: inputs.authorityID,
        authority_source_git_blob:
          inputs.authoritySourceIdentity.git_blob,
        authority_source_sha256:
          inputs.authoritySourceIdentity.sha256,
        authority_test_git_blob:
          inputs.authorityTestIdentity.git_blob,
        authority_test_sha256: inputs.authorityTestIdentity.sha256),
      ceiling: ceiling,
      environment: .init(
        exact_metallib_byte_count: inputs.metallibBytes,
        exact_metallib_path: inputs.metallibPath,
        exact_metallib_sha256: inputs.metallibSHA256,
        exact_mlx_c_revision: inputs.exactMLXCRevision,
        exact_mlx_revision: inputs.exactMLXRevision,
        lease_path: inputs.metalLeasePath,
        lease_type: "PrimeMetalDeviceLease",
        metal_device_count: 1,
        metal_device_index: 0,
        metal_device_is_default: true,
        metal_device_name: metalDeviceName,
        metal_device_registry_id: metalDeviceRegistryID,
        mlx_compile_transform_invocation_count: 0,
        mlx_default_stream_is_gpu: true,
        mlx_enable_tf32: "0",
        mlx_graph_compile_mode: inputs.mlxGraphCompileMode,
        operating_system_build: inputs.operatingSystemBuild,
        swift_sdk: inputs.swiftSDK,
        swift_version: inputs.swiftVersion,
        swiftpm_build_configuration: inputs.buildConfiguration,
        xcode_version: inputs.xcodeVersion),
      execution: .init(
        artifact_count: inputs.authorityClosureArtifactCount,
        authority_closure_active_job_conclusion:
          inputs.authorityClosureActiveJobConclusion,
        authority_closure_active_job_id:
          inputs.authorityClosureActiveJobID,
        authority_closure_check_suite_id:
          inputs.authorityClosureCheckSuiteID,
        authority_closure_conclusion:
          inputs.authorityClosureConclusion,
        authority_closure_reviewed_job_conclusion:
          inputs.authorityClosureReviewedJobConclusion,
        authority_closure_reviewed_job_id:
          inputs.authorityClosureReviewedJobID,
        authority_closure_revision:
          inputs.authorityClosureRevision,
        authority_closure_run_attempt:
          inputs.authorityClosureRunAttempt,
        authority_closure_run_id: inputs.authorityClosureRunID,
        authority_closure_run_number:
          inputs.authorityClosureRunNumber,
        authority_closure_tree: inputs.authorityClosureTree,
        build_count: 1,
        direct_xctest_count: 1,
        embedded_source_identity_sha256:
          inputs.embeddedSourceIdentitySHA256,
        exact_changed_source_identities:
          inputs.exactChangedSourceIdentities,
        exact_main_revision: inputs.exactMainRevision,
        exact_main_tree: inputs.exactMainTree,
        launcher_invocation_count: 1,
        lease_acquired_before_coregraphics_metal_or_mlx: true,
        lease_path: inputs.metalLeasePath,
        mechanics_event: inputs.mechanicsEvent,
        mechanics_head_ordered_parent_revisions: [
          inputs.mechanicsFirstParent,
          inputs.mechanicsSecondParent,
        ],
        mechanics_head_revision: inputs.mechanicsHeadRevision,
        mechanics_head_tree: inputs.mechanicsHeadTree,
        mechanics_ref: inputs.mechanicsRef,
        mechanics_run_attempt: inputs.mechanicsRunAttempt,
        one_shot_consumed: true,
        original_stage5_launcher_invocation_count: 0,
        rerun_count: inputs.authorityClosureRerunCount,
        retained_metal_device_identity: deviceIdentity,
        retry_count: inputs.authorityClosureRetryCount,
        stage6_launcher_invocation_count: 0,
        test_filter:
          "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests/testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume"
      ),
      forward_equivalence: armB.forwardReceipt,
      operation_counts: armB.operationCounts,
      receipt_id:
        "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_receipt_v1",
      schema_version: 1,
      status: armB.receipt.status)
    try validateReceipt(
      receipt,
      inputs: inputs,
      expectedDeviceIdentity: deviceIdentity)
    try validateReceiptMutationFixtures(
      receipt,
      inputs: inputs,
      expectedDeviceIdentity: deviceIdentity)
    let canonical = try receipt.canonicalData()
    let decoded = try Receipt.decodeCanonical(canonical)
    guard decoded == receipt else {
      throw AssayError.contractDrift("receipt round trip identity")
    }
    try validateReceipt(
      decoded,
      inputs: inputs,
      expectedDeviceIdentity: deviceIdentity)
    guard let json = String(data: canonical, encoding: .utf8) else {
      throw AssayError.contractDrift("receipt UTF-8")
    }
    return "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1=\(json)\n"
  }

  private static func validateReceipt(
    _ receipt: Receipt,
    inputs: ExecutionInputs,
    expectedDeviceIdentity: DeviceIdentity
  ) throws {
    let replay = receipt.arm_b.comparison_domain_results
    let replayExact = replay.allSatisfy(\.exact)
    let forward = receipt.forward_equivalence
    let forwardExact =
      forward.embedding_forward_exact_by_boundary.allSatisfy(\.exact)
      && forward.whole_logits_exact_by_boundary
        .allSatisfy(\.exact)
    let expectedStatus =
      replayExact && forwardExact
      ? "PASS_CLEARANCE"
      : "MEASURED_EXACT_MISMATCH"
    guard
      receipt.receipt_id
        == "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_receipt_v1",
      receipt.schema_version == 1,
      receipt.status == expectedStatus,
      receipt.arm_b.status == expectedStatus,
      receipt.arm_b.all_exact_comparisons_passed == replayExact,
      receipt.arm_b.all_forward_equivalence_checks_passed
        == forwardExact,
      ["MEASURED_EXACT_MISMATCH", "PASS_CLEARANCE"]
        .contains(receipt.status)
    else {
      throw AssayError.contractDrift("receipt status predicate")
    }

    let armA = receipt.arm_a
    let armAMismatch =
      armA.source_step_equal_by_pair.contains { !$0.exact }
      || armA.global_step_one_by_pair.contains { !$0.exact }
      || armA.selected_target_count_six_by_pair.contains {
        !$0.exact
      }
    guard armA.completed_diagnostic_pair_count == 3,
      armA.trial_count == 3,
      armA.pair_branch_names
        == ["uninterrupted", "source_snapshot"],
      armA.source_step_equal_by_pair.count == 3,
      armA.global_step_one_by_pair.count == 3,
      armA.selected_target_count_six_by_pair.count == 3,
      armA.measured_mismatch == armAMismatch,
      [
        armA.source_step_equal_by_pair,
        armA.global_step_one_by_pair,
        armA.selected_target_count_six_by_pair,
      ].allSatisfy({ pairs in
        pairs.enumerated().allSatisfy({
          $0.element.trial_ordinal == $0.offset + 1
            && $0.element.reference_branch == "uninterrupted"
            && $0.element.observed_branch == "source_snapshot"
        })
      })
    else {
      throw AssayError.contractDrift("Arm A receipt")
    }
    if armAMismatch {
      guard
        armA.first_scalar_mismatch.optional != nil
          || armA.first_tensor_mismatch.optional != nil
      else {
        throw AssayError.contractDrift("Arm A mismatch coordinate")
      }
    } else {
      guard armA.first_scalar_mismatch.optional == nil,
        armA.first_tensor_mismatch.optional == nil
      else {
        throw AssayError.contractDrift("Arm A exact coordinates")
      }
    }
    if let mismatch = armA.first_scalar_mismatch.optional {
      guard mismatch.arm == "arm_a",
        mismatch.observed_scalar_float32_bits != nil,
        mismatch.byte_offset == nil,
        ["uninterrupted", "source_snapshot"].contains(mismatch.branch)
      else {
        throw AssayError.contractDrift("Arm A scalar mismatch field")
      }
      try validateMismatchCoordinate(mismatch, armB: false)
    }
    if let mismatch = armA.first_tensor_mismatch.optional {
      guard mismatch.arm == "arm_a",
        mismatch.observed_scalar_float32_bits == nil,
        mismatch.byte_offset != nil,
        ["uninterrupted", "source_snapshot"].contains(mismatch.branch)
      else {
        throw AssayError.contractDrift("Arm A tensor mismatch field")
      }
      try validateMismatchCoordinate(mismatch, armB: false)
    }
    for mismatch in [
      armA.first_scalar_mismatch.optional,
      armA.first_tensor_mismatch.optional,
    ].compactMap({ $0 }) {
      guard mismatch.reference_branch != "fresh_restored_from_source_snapshot",
        mismatch.observed_branch != "fresh_restored_from_source_snapshot"
      else {
        throw AssayError.contractDrift("Arm A mismatch arm")
      }
    }
    func armAEvidence(
      _ rows: [PairBoolean],
      trialOrdinal: Int
    ) -> PairBoolean? {
      rows.first { $0.trial_ordinal == trialOrdinal }
    }
    if let mismatch = armA.first_tensor_mismatch.optional {
      guard
        mismatch.comparison_domain
          == "maintained_gather_source_step_tensor_bytes",
        mismatch.branch == "source_snapshot",
        mismatch.reference_branch == "uninterrupted",
        mismatch.observed_branch == "source_snapshot",
        armAEvidence(
          armA.source_step_equal_by_pair,
          trialOrdinal: mismatch.trial_ordinal)?.exact == false
      else {
        throw AssayError.contractDrift(
          "Arm A tensor coordinate evidence")
      }
    }
    if let mismatch = armA.first_scalar_mismatch.optional {
      guard
        mismatch.comparison_domain
          == "maintained_gather_source_step_scalar_bits"
      else {
        throw AssayError.contractDrift(
          "Arm A scalar coordinate domain")
      }
      if mismatch.reference_branch == "expected_fixture" {
        guard mismatch.observed_branch == mismatch.branch else {
          throw AssayError.contractDrift(
            "Arm A fixture scalar coordinate route")
        }
        let evidence: PairBoolean?
        switch mismatch.scalar_name {
        case "global_step":
          evidence = armAEvidence(
            armA.global_step_one_by_pair,
            trialOrdinal: mismatch.trial_ordinal)
        case "selected_target_count":
          evidence = armAEvidence(
            armA.selected_target_count_six_by_pair,
            trialOrdinal: mismatch.trial_ordinal)
        default:
          throw AssayError.contractDrift(
            "Arm A fixture scalar coordinate name")
        }
        guard evidence?.exact == false else {
          throw AssayError.contractDrift(
            "Arm A fixture scalar points to exact evidence")
        }
      } else {
        guard mismatch.branch == "source_snapshot",
          mismatch.reference_branch == "uninterrupted",
          mismatch.observed_branch == "source_snapshot",
          armAEvidence(
            armA.source_step_equal_by_pair,
            trialOrdinal: mismatch.trial_ordinal)?.exact == false
        else {
          throw AssayError.contractDrift(
            "Arm A pair scalar coordinate evidence")
        }
      }
    }

    let expectedSelectorRows = (1...3).flatMap { trial in
      branchNames.map { branch in
        SelectorByBranch(
          trial_ordinal: trial,
          branch: branch,
          selector_id:
            "flattened_dense_one_hot_matmul_input_embedding_v1")
      }
    }
    guard receipt.arm_b.branch_names == branchNames,
      receipt.arm_b.trial_count == 3,
      receipt.arm_b.trajectory_branch_count == 9,
      receipt.arm_b.selector_id_by_branch == expectedSelectorRows,
      receipt.arm_b.fresh_constructor
        == "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(metalGPUIndexZero:stage5ReplacementTrainingInputPath:)",
      receipt.arm_b.restore_constructor
        == "PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(restoring:metalGPUIndexZero:stage5ReplacementTrainingInputPath:)",
      replay.map(\.comparison_domain) == replayDomains,
      replay.count == 7,
      Set(replay.map(\.comparison_domain)).count == 7,
      replay.first(where: {
        $0.comparison_domain
          == "global_step_and_selected_target_count"
      })?.exact == true
    else {
      throw AssayError.contractDrift("Arm B receipt topology")
    }
    if replayExact && forwardExact {
      guard receipt.arm_b.first_mismatch.optional == nil else {
        throw AssayError.contractDrift("PASS first mismatch")
      }
    } else {
      guard let mismatch = receipt.arm_b.first_mismatch.optional,
        mismatch.arm == "arm_b"
      else {
        throw AssayError.contractDrift("mismatch first coordinate")
      }
      try validateMismatchCoordinate(mismatch, armB: true)
      if let replayEvidence = replay.first(where: {
        $0.comparison_domain == mismatch.comparison_domain
      }) {
        guard replayEvidence.exact == false else {
          throw AssayError.contractDrift(
            "replay mismatch points to exact evidence")
        }
      } else {
        let forwardEvidence: [ForwardBoolean]
        switch mismatch.comparison_domain {
        case "arm_b_embedding_forward_bytes_against_arm_a":
          forwardEvidence =
            forward.embedding_forward_exact_by_boundary
        case "arm_b_whole_logits_forward_bytes_against_arm_a":
          forwardEvidence = forward.whole_logits_exact_by_boundary
        default:
          throw AssayError.contractDrift("unknown mismatch domain")
        }
        guard
          forwardEvidence.contains(where: {
            $0.trial_ordinal == mismatch.trial_ordinal
              && $0.boundary == mismatch.forward_boundary
              && $0.exact == false
          })
        else {
          throw AssayError.contractDrift(
            "forward mismatch points to exact evidence")
        }
      }
    }

    let expectedForwardRows = (1...3).flatMap { trial in
      boundaryNames.map { boundary in
        (trial, boundary)
      }
    }
    guard forward.boundary_names == boundaryNames,
      forward.same_model_pre_mutation,
      forward.embedding_forward_exact_by_boundary.count == 9,
      forward.whole_logits_exact_by_boundary.count == 9,
      zip(
        forward.embedding_forward_exact_by_boundary,
        expectedForwardRows
      ).allSatisfy({
        $0.trial_ordinal == $1.0 && $0.boundary == $1.1
      }),
      zip(
        forward.whole_logits_exact_by_boundary,
        expectedForwardRows
      ).allSatisfy({
        $0.trial_ordinal == $1.0 && $0.boundary == $1.1
      })
    else {
      throw AssayError.contractDrift("forward receipt topology")
    }

    let counts = receipt.operation_counts
    guard
      counts
        == .init(
          arm_a_source_step_count: 6,
          arm_b_dense_embedding_construction_count: 66,
          arm_b_dense_whole_logits_call_count: 57,
          arm_b_evaluate_count: 18,
          arm_b_forward_equivalence_check_count: 9,
          arm_b_input_embedding_pair_seam_count: 9,
          arm_b_restore_count: 3,
          arm_b_snapshot_count: 3,
          arm_b_token_bounds_checked_eval_count: 66,
          arm_b_token_bounds_gpu_synchronize_count: 66,
          arm_b_token_bounds_host_bool_item_count: 66,
          arm_b_token_bounds_validation_count: 66,
          arm_b_training_step_count: 15,
          receipt_count: 1,
          synchronize_count: 75)
    else {
      throw AssayError.contractDrift("operation counts")
    }

    let pass = receipt.status == "PASS_CLEARANCE"
    let ceiling = receipt.ceiling
    guard ceiling.additional_execution_or_rerun_authorized == false,
      ceiling.arbitrary_token_determinism_established == false,
      ceiling.artifact_upload_authorized == false,
      ceiling.b_specific_native300_resource_witness_authorized
        == false,
      ceiling.b_specific_native300_resource_witness_established
        == false,
      ceiling
        .b_specific_native300_resource_witness_requires_separate_authority,
      ceiling.candidate_admission_granted == false,
      ceiling.cross_device_determinism_established == false,
      ceiling.default_gather_determinism_established == false,
      ceiling.durable_checkpoint_io_authorized == false,
      ceiling.exact_same_device_b_path_gradient_bytes_established
        == pass,
      ceiling.model_quality_established == false,
      ceiling.one_shot_consumed,
      ceiling.repeated_same_device_b_path_determinism_established
        == pass,
      ceiling.retained_artifact_authorized == false,
      ceiling.stage5_assay_clearance_established == pass,
      ceiling.stage5_mechanics_success_established,
      ceiling.stage5_result_established,
      ceiling.stage6_historical_resource_clearance_applies_to_b_path
        == false,
      ceiling.stage6_resource_clearance_remains_historical,
      ceiling.stage7_authority_established == false,
      ceiling.stage7_authorized == false,
      ceiling.stage7_requires_new_b_specific_native300_resource_witness,
      ceiling.stage7_requires_separate_authority_after_witness
    else {
      throw AssayError.contractDrift("receipt ceiling")
    }

    guard
      receipt.authority
        == .init(
          authority_canonical_sha256: inputs.authorityCanonicalSHA256,
          authority_id: inputs.authorityID,
          authority_source_git_blob:
            inputs.authoritySourceIdentity.git_blob,
          authority_source_sha256: inputs.authoritySourceIdentity.sha256,
          authority_test_git_blob: inputs.authorityTestIdentity.git_blob,
          authority_test_sha256: inputs.authorityTestIdentity.sha256),
      receipt.environment.exact_metallib_byte_count
        == inputs.metallibBytes,
      receipt.environment.exact_metallib_path == inputs.metallibPath,
      receipt.environment.exact_metallib_sha256
        == inputs.metallibSHA256,
      receipt.environment.exact_mlx_revision
        == inputs.exactMLXRevision,
      receipt.environment.exact_mlx_c_revision
        == inputs.exactMLXCRevision,
      receipt.environment.lease_path == inputs.metalLeasePath,
      receipt.environment.lease_type == "PrimeMetalDeviceLease",
      receipt.environment.metal_device_count == 1,
      receipt.environment.metal_device_index == 0,
      receipt.environment.metal_device_is_default,
      receipt.environment.mlx_compile_transform_invocation_count == 0,
      receipt.environment.mlx_default_stream_is_gpu,
      receipt.environment.mlx_enable_tf32 == "0",
      receipt.environment.mlx_graph_compile_mode
        == inputs.mlxGraphCompileMode,
      receipt.environment.operating_system_build
        == inputs.operatingSystemBuild,
      receipt.environment.swift_sdk == inputs.swiftSDK,
      receipt.environment.swift_version == inputs.swiftVersion,
      receipt.environment.swiftpm_build_configuration == "debug",
      receipt.environment.xcode_version == inputs.xcodeVersion,
      receipt.environment.metal_device_name
        == expectedDeviceIdentity.name,
      receipt.environment.metal_device_registry_id
        == expectedDeviceIdentity.registry_id
    else {
      throw AssayError.contractDrift(
        "receipt authority or environment")
    }

    let execution = receipt.execution
    guard execution.artifact_count == 0,
      execution.authority_closure_active_job_conclusion == "success",
      execution.authority_closure_active_job_id
        == inputs.authorityClosureActiveJobID,
      execution.authority_closure_check_suite_id
        == inputs.authorityClosureCheckSuiteID,
      execution.authority_closure_conclusion == "success",
      execution.authority_closure_reviewed_job_conclusion
        == "success",
      execution.authority_closure_reviewed_job_id
        == inputs.authorityClosureReviewedJobID,
      execution.authority_closure_revision
        == inputs.authorityClosureRevision,
      execution.authority_closure_run_attempt == 1,
      execution.authority_closure_run_id
        == inputs.authorityClosureRunID,
      execution.authority_closure_run_number == 115,
      execution.authority_closure_tree == inputs.authorityClosureTree,
      execution.build_count == 1,
      execution.direct_xctest_count == 1,
      execution.embedded_source_identity_sha256
        == PrimeEmbeddedBuildProvenance.sourceIdentitySHA256,
      execution.exact_changed_source_identities
        == inputs.exactChangedSourceIdentities,
      execution.exact_main_revision == inputs.exactMainRevision,
      execution.exact_main_tree == inputs.exactMainTree,
      execution.launcher_invocation_count == 1,
      execution.lease_acquired_before_coregraphics_metal_or_mlx,
      execution.lease_path == inputs.metalLeasePath,
      execution.mechanics_event == "push",
      execution.mechanics_head_ordered_parent_revisions == [
        inputs.mechanicsFirstParent,
        inputs.mechanicsSecondParent,
      ],
      execution.mechanics_head_revision == inputs.mechanicsHeadRevision,
      execution.mechanics_head_tree == inputs.mechanicsHeadTree,
      execution.mechanics_ref == "refs/heads/main",
      execution.mechanics_run_attempt == 1,
      execution.one_shot_consumed,
      execution.original_stage5_launcher_invocation_count == 0,
      execution.rerun_count == 0,
      execution.retry_count == 0,
      execution.stage6_launcher_invocation_count == 0,
      execution.test_filter
        == "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests/testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume",
      execution.retained_metal_device_identity.name
        == receipt.environment.metal_device_name,
      execution.retained_metal_device_identity.registry_id
        == receipt.environment.metal_device_registry_id,
      execution.retained_metal_device_identity == expectedDeviceIdentity
    else {
      throw AssayError.contractDrift("receipt execution")
    }
  }

  private static func validateMismatchCoordinate(
    _ mismatch: FirstMismatch,
    armB: Bool
  ) throws {
    guard (1...3).contains(mismatch.trial_ordinal),
      branchNames.contains(mismatch.branch),
      !mismatch.reference_branch.isEmpty,
      !mismatch.observed_branch.isEmpty,
      !mismatch.comparison_domain.isEmpty,
      !mismatch.component.isEmpty,
      !armB
        || mismatchDomainOrder.contains(
          mismatch.comparison_domain)
    else {
      throw AssayError.contractDrift("mismatch coordinate identity")
    }
    let isTensor = mismatch.byte_offset != nil
    if isTensor {
      guard let offset = mismatch.byte_offset,
        offset >= 0,
        mismatch.component != "scalar_float32_bits",
        let dtype = mismatch.dtype,
        ["float32", "uint8"].contains(dtype),
        let shape = mismatch.shape,
        !shape.isEmpty,
        shape.allSatisfy({ $0 > 0 }),
        mismatch.parameter_or_tensor_path?.isEmpty == false,
        let referenceSHA256 = mismatch.reference_sha256,
        isLowercaseHex(referenceSHA256, exactCount: 64),
        let observedSHA256 = mismatch.observed_sha256,
        isLowercaseHex(observedSHA256, exactCount: 64),
        referenceSHA256 != observedSHA256,
        mismatch.scalar_name == nil,
        mismatch.reference_scalar_float32_bits == nil,
        mismatch.observed_scalar_float32_bits == nil
      else {
        throw AssayError.contractDrift("tensor mismatch coordinate")
      }
      var elementCount = 1
      for dimension in shape {
        let product = elementCount.multipliedReportingOverflow(
          by: dimension)
        guard !product.overflow else {
          throw AssayError.contractDrift(
            "tensor mismatch shape overflow")
        }
        elementCount = product.partialValue
      }
      let byteCount = elementCount.multipliedReportingOverflow(
        by: dtype == "float32" ? 4 : 1)
      guard !byteCount.overflow,
        offset < byteCount.partialValue
      else {
        throw AssayError.contractDrift(
          "tensor mismatch byte offset")
      }
    } else {
      guard mismatch.component == "scalar_float32_bits",
        mismatch.dtype == nil,
        mismatch.shape == nil,
        mismatch.parameter_or_tensor_path == nil,
        mismatch.reference_sha256 == nil,
        mismatch.observed_sha256 == nil,
        mismatch.scalar_name?.isEmpty == false,
        let referenceBits = mismatch.reference_scalar_float32_bits,
        let observedBits = mismatch.observed_scalar_float32_bits,
        referenceBits != observedBits
      else {
        throw AssayError.contractDrift("scalar mismatch coordinate")
      }
    }
    let isForward = forwardDomains.contains(mismatch.comparison_domain)
    guard
      isForward
        ? boundaryNames.contains(mismatch.forward_boundary ?? "")
        : mismatch.forward_boundary == nil
    else {
      throw AssayError.contractDrift("forward mismatch boundary")
    }
    if isForward {
      guard let forwardBoundary = mismatch.forward_boundary else {
        throw AssayError.contractDrift("forward mismatch boundary")
      }
      let expectedBranch: String
      switch forwardBoundary {
      case "initial":
        expectedBranch = "uninterrupted"
      case "source_boundary":
        expectedBranch = "source_snapshot"
      case "terminal":
        expectedBranch = "fresh_restored_from_source_snapshot"
      default:
        throw AssayError.contractDrift("forward mismatch boundary mapping")
      }
      let expectedComponent: String
      let expectedPath: String
      let expectedShape: [Int]
      switch mismatch.comparison_domain {
      case "arm_b_embedding_forward_bytes_against_arm_a":
        expectedComponent = "input_embedding_forward_bytes"
        expectedPath = forwardBoundary + "/input_embedding"
        expectedShape = [2, 6, 16]
      case "arm_b_whole_logits_forward_bytes_against_arm_a":
        expectedComponent = "whole_logits_forward_bytes"
        expectedPath = forwardBoundary + "/whole_logits"
        expectedShape = [2, 6, 32]
      default:
        throw AssayError.contractDrift("forward mismatch domain")
      }
      guard isTensor,
        mismatch.branch == expectedBranch,
        mismatch.reference_branch == "maintained_gather_v1",
        mismatch.observed_branch
          == "flattened_dense_one_hot_matmul_input_embedding_v1",
        mismatch.component == expectedComponent,
        mismatch.parameter_or_tensor_path == expectedPath,
        mismatch.shape == expectedShape,
        mismatch.dtype == "float32"
      else {
        throw AssayError.contractDrift("forward mismatch coordinate route")
      }
    } else if armB {
      let isSameBranchCrossTrial =
        mismatch.reference_branch == mismatch.branch
        && (2...3).contains(mismatch.trial_ordinal)
      let isWithinTrialBranchReplay =
        mismatch.reference_branch == "uninterrupted"
        && [
          "source_snapshot",
          "fresh_restored_from_source_snapshot",
        ].contains(mismatch.branch)
      guard mismatch.observed_branch == mismatch.branch,
        isSameBranchCrossTrial || isWithinTrialBranchReplay
      else {
        throw AssayError.contractDrift("replay mismatch coordinate route")
      }
    }
  }

  private static func validateReceiptMutationFixtures(
    _ receipt: Receipt,
    inputs: ExecutionInputs,
    expectedDeviceIdentity: DeviceIdentity
  ) throws {
    func requireRejected(
      _ name: String,
      _ mutation: (inout Receipt) -> Void
    ) throws {
      var candidate = receipt
      mutation(&candidate)
      do {
        try validateReceipt(
          candidate,
          inputs: inputs,
          expectedDeviceIdentity: expectedDeviceIdentity)
      } catch {
        return
      }
      throw AssayError.contractDrift(
        "receipt validator accepted mutation \(name)")
    }
    func forceMeasuredBase(_ candidate: inout Receipt) {
      for index in candidate.arm_b.comparison_domain_results.indices {
        candidate.arm_b.comparison_domain_results[index].exact = true
      }
      for index in candidate.forward_equivalence
        .embedding_forward_exact_by_boundary.indices
      {
        candidate.forward_equivalence
          .embedding_forward_exact_by_boundary[index].exact = true
      }
      for index in candidate.forward_equivalence
        .whole_logits_exact_by_boundary.indices
      {
        candidate.forward_equivalence
          .whole_logits_exact_by_boundary[index].exact = true
      }
      candidate.arm_b.all_exact_comparisons_passed = true
      candidate.arm_b.all_forward_equivalence_checks_passed = true
      candidate.arm_b.status = "MEASURED_EXACT_MISMATCH"
      candidate.status = "MEASURED_EXACT_MISMATCH"
      candidate.ceiling
        .exact_same_device_b_path_gradient_bytes_established = false
      candidate.ceiling
        .repeated_same_device_b_path_determinism_established = false
      candidate.ceiling.stage5_assay_clearance_established = false
    }
    func forceReplayRouteMismatch(
      _ candidate: inout Receipt,
      branch: String,
      referenceBranch: String,
      observedBranch: String
    ) {
      forceMeasuredBase(&candidate)
      candidate.arm_b.comparison_domain_results[6].exact = false
      candidate.arm_b.all_exact_comparisons_passed = false
      candidate.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: branch,
          byte_offset: nil,
          comparison_domain:
            "training_loss_norm_and_clip_scalar_bits",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: nil,
          observed_branch: observedBranch,
          observed_scalar_float32_bits: 2,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: referenceBranch,
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "training_loss",
          shape: nil,
          trial_ordinal: 1))
    }
    func forceArmABase(_ candidate: inout Receipt) {
      for index in candidate.arm_a.source_step_equal_by_pair.indices {
        candidate.arm_a.source_step_equal_by_pair[index].exact = true
        candidate.arm_a.global_step_one_by_pair[index].exact = true
        candidate.arm_a.selected_target_count_six_by_pair[index].exact = true
      }
      candidate.arm_a.measured_mismatch = false
      candidate.arm_a.first_scalar_mismatch = .null
      candidate.arm_a.first_tensor_mismatch = .null
    }
    try requireRejected("receipt_id") {
      $0.receipt_id += "_mutated"
    }
    try requireRejected("terminal_status") {
      $0.status = "INVALID"
    }
    try requireRejected("replay_domain_partition") {
      $0.arm_b.comparison_domain_results.removeLast()
    }
    try requireRejected("replay_domain_order") {
      $0.arm_b.comparison_domain_results.swapAt(0, 1)
    }
    try requireRejected("arm_a_pair_order") {
      $0.arm_a.global_step_one_by_pair.swapAt(0, 1)
    }
    try requireRejected("arm_a_scalar_tensor_field_swap") {
      $0.arm_a.source_step_equal_by_pair[0].exact = false
      $0.arm_a.measured_mismatch = true
      $0.arm_a.first_scalar_mismatch = .value(
        .init(
          arm: "arm_a",
          branch: "source_snapshot",
          byte_offset: 0,
          comparison_domain: "maintained_gather_source_step_tensor_bytes",
          component: "model_parameter_bytes",
          dtype: "float32",
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: nil,
          observed_sha256: String(repeating: "1", count: 64),
          parameter_or_tensor_path: "model_parameter/test",
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: nil,
          reference_sha256: String(repeating: "0", count: 64),
          scalar_name: nil,
          shape: [1],
          trial_ordinal: 1))
    }
    try requireRejected("arm_a_restored_branch_coordinate") {
      $0.arm_a.source_step_equal_by_pair[0].exact = false
      $0.arm_a.measured_mismatch = true
      $0.arm_a.first_scalar_mismatch = .value(
        .init(
          arm: "arm_a",
          branch: "fresh_restored_from_source_snapshot",
          byte_offset: nil,
          comparison_domain: "maintained_gather_source_step_scalar_bits",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: nil,
          observed_branch: "fresh_restored_from_source_snapshot",
          observed_scalar_float32_bits: 2,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "global_step",
          shape: nil,
          trial_ordinal: 1))
    }
    try requireRejected("arm_a_scalar_coordinate_true_row") {
      forceArmABase(&$0)
      $0.arm_a.global_step_one_by_pair[0].exact = false
      $0.arm_a.measured_mismatch = true
      $0.arm_a.first_scalar_mismatch = .value(
        .init(
          arm: "arm_a",
          branch: "uninterrupted",
          byte_offset: nil,
          comparison_domain: "maintained_gather_source_step_scalar_bits",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: nil,
          observed_branch: "uninterrupted",
          observed_scalar_float32_bits: 2,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: "expected_fixture",
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "global_step",
          shape: nil,
          trial_ordinal: 2))
    }
    try requireRejected("arm_a_tensor_coordinate_true_row") {
      forceArmABase(&$0)
      $0.arm_a.source_step_equal_by_pair[0].exact = false
      $0.arm_a.measured_mismatch = true
      $0.arm_a.first_tensor_mismatch = .value(
        .init(
          arm: "arm_a",
          branch: "source_snapshot",
          byte_offset: 0,
          comparison_domain: "maintained_gather_source_step_tensor_bytes",
          component: "model_parameter_bytes",
          dtype: "float32",
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: nil,
          observed_sha256: String(repeating: "1", count: 64),
          parameter_or_tensor_path: "model_parameter/test",
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: nil,
          reference_sha256: String(repeating: "0", count: 64),
          scalar_name: nil,
          shape: [1],
          trial_ordinal: 2))
    }
    try requireRejected("arm_a_coordinate_wrong_domain") {
      forceArmABase(&$0)
      $0.arm_a.source_step_equal_by_pair[0].exact = false
      $0.arm_a.measured_mismatch = true
      $0.arm_a.first_scalar_mismatch = .value(
        .init(
          arm: "arm_a",
          branch: "source_snapshot",
          byte_offset: nil,
          comparison_domain: "wrong_arm_a_domain",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: 2,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "loss",
          shape: nil,
          trial_ordinal: 1))
    }
    try requireRejected("arm_a_coordinate_wrong_route") {
      forceArmABase(&$0)
      $0.arm_a.source_step_equal_by_pair[0].exact = false
      $0.arm_a.measured_mismatch = true
      $0.arm_a.first_scalar_mismatch = .value(
        .init(
          arm: "arm_a",
          branch: "source_snapshot",
          byte_offset: nil,
          comparison_domain: "maintained_gather_source_step_scalar_bits",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: 2,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: "expected_fixture",
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "loss",
          shape: nil,
          trial_ordinal: 1))
    }
    try requireRejected("forward_check_count") {
      $0.forward_equivalence
        .embedding_forward_exact_by_boundary.removeLast()
    }
    try requireRejected("synchronize_count") {
      $0.operation_counts.synchronize_count = 74
    }
    try requireRejected("stage7_ceiling") {
      $0.ceiling.stage7_authorized = true
    }
    try requireRejected("authority_canonical_binding") {
      $0.authority.authority_canonical_sha256 =
        "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1.canonicalSHA256"
    }
    try requireRejected("operating_system_build") {
      $0.environment.operating_system_build += "_mutated"
    }
    try requireRejected("swift_sdk") {
      $0.environment.swift_sdk += "_mutated"
    }
    try requireRejected("swift_version") {
      $0.environment.swift_version += "_mutated"
    }
    try requireRejected("xcode_version") {
      $0.environment.xcode_version += "_mutated"
    }
    try requireRejected("metal_identity_cross_binding") {
      $0.environment.metal_device_name += "_mutated"
    }
    try requireRejected("metal_identity_actual_binding") {
      $0.environment.metal_device_name += "_mutated"
      $0.execution.retained_metal_device_identity.name =
        $0.environment.metal_device_name
    }
    try requireRejected("gating_comparison_summary") {
      $0.arm_b.all_exact_comparisons_passed.toggle()
    }
    try requireRejected("replay_coordinate_wrong_reference_route") {
      forceReplayRouteMismatch(
        &$0,
        branch: "source_snapshot",
        referenceBranch: "fresh_restored_from_source_snapshot",
        observedBranch: "source_snapshot")
    }
    try requireRejected("replay_coordinate_wrong_observed_route") {
      forceReplayRouteMismatch(
        &$0,
        branch: "source_snapshot",
        referenceBranch: "uninterrupted",
        observedBranch: "uninterrupted")
    }
    try requireRejected("replay_coordinate_wrong_branch") {
      forceReplayRouteMismatch(
        &$0,
        branch: "invalid_branch",
        referenceBranch: "expected_fixture",
        observedBranch: "invalid_branch")
    }
    try requireRejected("replay_coordinate_expected_fixture_reference") {
      forceReplayRouteMismatch(
        &$0,
        branch: "source_snapshot",
        referenceBranch: "expected_fixture",
        observedBranch: "source_snapshot")
    }
    try requireRejected("replay_coordinate_trial_one_same_branch") {
      forceReplayRouteMismatch(
        &$0,
        branch: "source_snapshot",
        referenceBranch: "source_snapshot",
        observedBranch: "source_snapshot")
    }
    try requireRejected("replay_global_count_domain_false") {
      forceMeasuredBase(&$0)
      $0.arm_b.comparison_domain_results[2].exact = false
      $0.arm_b.all_exact_comparisons_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "source_snapshot",
          byte_offset: nil,
          comparison_domain:
            "global_step_and_selected_target_count",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: 2,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "source_global_step",
          shape: nil,
          trial_ordinal: 1))
    }
    try requireRejected("scalar_coordinate_equal_bits") {
      forceMeasuredBase(&$0)
      $0.arm_b.comparison_domain_results[6].exact = false
      $0.arm_b.all_exact_comparisons_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "source_snapshot",
          byte_offset: nil,
          comparison_domain:
            "training_loss_norm_and_clip_scalar_bits",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: 1,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "training_loss",
          shape: nil,
          trial_ordinal: 1))
    }
    try requireRejected("tensor_coordinate_out_of_range_offset") {
      forceMeasuredBase(&$0)
      $0.arm_b.comparison_domain_results[3].exact = false
      $0.arm_b.all_exact_comparisons_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "source_snapshot",
          byte_offset: 4,
          comparison_domain: "model_parameter_bytes",
          component: "model_parameter_bytes",
          dtype: "float32",
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: nil,
          observed_sha256: String(repeating: "1", count: 64),
          parameter_or_tensor_path: "model_parameters/test",
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: nil,
          reference_sha256: String(repeating: "0", count: 64),
          scalar_name: nil,
          shape: [1],
          trial_ordinal: 1))
    }
    try requireRejected("tensor_coordinate_invalid_dtype") {
      forceMeasuredBase(&$0)
      $0.arm_b.comparison_domain_results[3].exact = false
      $0.arm_b.all_exact_comparisons_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "source_snapshot",
          byte_offset: 0,
          comparison_domain: "model_parameter_bytes",
          component: "model_parameter_bytes",
          dtype: "float16",
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: nil,
          observed_sha256: String(repeating: "1", count: 64),
          parameter_or_tensor_path: "model_parameters/test",
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: nil,
          reference_sha256: String(repeating: "0", count: 64),
          scalar_name: nil,
          shape: [1],
          trial_ordinal: 1))
    }
    try requireRejected("tensor_coordinate_equal_hashes") {
      forceMeasuredBase(&$0)
      $0.arm_b.comparison_domain_results[3].exact = false
      $0.arm_b.all_exact_comparisons_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "source_snapshot",
          byte_offset: 0,
          comparison_domain: "model_parameter_bytes",
          component: "model_parameter_bytes",
          dtype: "float32",
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: nil,
          observed_sha256: String(repeating: "0", count: 64),
          parameter_or_tensor_path: "model_parameters/test",
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: nil,
          reference_sha256: String(repeating: "0", count: 64),
          scalar_name: nil,
          shape: [1],
          trial_ordinal: 1))
    }
    try requireRejected("replay_coordinate_points_to_exact_evidence") {
      forceMeasuredBase(&$0)
      $0.arm_b.comparison_domain_results[0].exact = false
      $0.arm_b.all_exact_comparisons_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "source_snapshot",
          byte_offset: nil,
          comparison_domain: "evaluation_loss_and_logits_bytes",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: nil,
          observed_branch: "source_snapshot",
          observed_scalar_float32_bits: 2,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: "uninterrupted",
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "evaluation_loss",
          shape: nil,
          trial_ordinal: 1))
    }
    try requireRejected("forward_coordinate_points_to_exact_evidence") {
      forceMeasuredBase(&$0)
      $0.forward_equivalence.embedding_forward_exact_by_boundary[0].exact =
        false
      $0.arm_b.all_forward_equivalence_checks_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "source_snapshot",
          byte_offset: 0,
          comparison_domain:
            "arm_b_embedding_forward_bytes_against_arm_a",
          component: "input_embedding_forward_bytes",
          dtype: "float32",
          forward_boundary: "source_boundary",
          observed_branch:
            "flattened_dense_one_hot_matmul_input_embedding_v1",
          observed_scalar_float32_bits: nil,
          observed_sha256: String(repeating: "1", count: 64),
          parameter_or_tensor_path: "source_boundary/input_embedding",
          reference_branch: "maintained_gather_v1",
          reference_scalar_float32_bits: nil,
          reference_sha256: String(repeating: "0", count: 64),
          scalar_name: nil,
          shape: [2, 6, 16],
          trial_ordinal: 1))
    }
    try requireRejected("forward_coordinate_wrong_branch") {
      forceMeasuredBase(&$0)
      $0.forward_equivalence.embedding_forward_exact_by_boundary[0].exact =
        false
      $0.arm_b.all_forward_equivalence_checks_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "source_snapshot",
          byte_offset: 0,
          comparison_domain:
            "arm_b_embedding_forward_bytes_against_arm_a",
          component: "input_embedding_forward_bytes",
          dtype: "float32",
          forward_boundary: "initial",
          observed_branch:
            "flattened_dense_one_hot_matmul_input_embedding_v1",
          observed_scalar_float32_bits: nil,
          observed_sha256: String(repeating: "1", count: 64),
          parameter_or_tensor_path: "initial/input_embedding",
          reference_branch: "maintained_gather_v1",
          reference_scalar_float32_bits: nil,
          reference_sha256: String(repeating: "0", count: 64),
          scalar_name: nil,
          shape: [2, 6, 16],
          trial_ordinal: 1))
    }
    try requireRejected("forward_coordinate_scalar") {
      forceMeasuredBase(&$0)
      $0.forward_equivalence.embedding_forward_exact_by_boundary[0].exact =
        false
      $0.arm_b.all_forward_equivalence_checks_passed = false
      $0.arm_b.first_mismatch = .value(
        .init(
          arm: "arm_b",
          branch: "uninterrupted",
          byte_offset: nil,
          comparison_domain:
            "arm_b_embedding_forward_bytes_against_arm_a",
          component: "scalar_float32_bits",
          dtype: nil,
          forward_boundary: "initial",
          observed_branch:
            "flattened_dense_one_hot_matmul_input_embedding_v1",
          observed_scalar_float32_bits: 2,
          observed_sha256: nil,
          parameter_or_tensor_path: nil,
          reference_branch: "maintained_gather_v1",
          reference_scalar_float32_bits: 1,
          reference_sha256: nil,
          scalar_name: "invalid_forward_scalar",
          shape: nil,
          trial_ordinal: 1))
    }
    try requireRejected("missing_measured_mismatch_coordinate") {
      $0.arm_b.comparison_domain_results[0].exact = false
      $0.arm_b.all_exact_comparisons_passed = false
      $0.arm_b.first_mismatch = .null
      $0.arm_b.status = "MEASURED_EXACT_MISMATCH"
      $0.status = "MEASURED_EXACT_MISMATCH"
      $0.ceiling.exact_same_device_b_path_gradient_bytes_established =
        false
      $0.ceiling.repeated_same_device_b_path_determinism_established =
        false
      $0.ceiling.stage5_assay_clearance_established = false
    }
  }

  private static func pairBoolean(
    trialOrdinal: Int,
    exact: Bool
  ) -> PairBoolean {
    .init(
      trial_ordinal: trialOrdinal,
      reference_branch: "uninterrupted",
      observed_branch: "source_snapshot",
      exact: exact)
  }

  private static func validateStepInfrastructure(
    _ step: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1
  ) throws {
    let tensorLists = [
      step.rawGradients,
      step.clippedGradients,
      step.postStepTensors.modelParameters,
      step.postStepTensors.firstMoments,
      step.postStepTensors.secondMoments,
    ]
    try validateTensorLists(tensorLists)
    let result = step.result
    let scalarBits =
      [
        result.lossFloat32BitPattern,
        result.rawGlobalGradientNormFloat32BitPattern,
        result.gradientClipScaleFloat32BitPattern,
        result.clippedGlobalGradientNormFloat32BitPattern,
      ] + result.selectedLossFloat32BitPatterns
    guard result.selectedTargetCount > 0,
      result.selectedLossFloat32BitPatterns.count
        == result.selectedTargetCount,
      scalarBits.allSatisfy({ Float(bitPattern: $0).isFinite }),
      isLowercaseHex(result.parameterStateSHA256, exactCount: 64),
      isLowercaseHex(result.firstMomentStateSHA256, exactCount: 64),
      isLowercaseHex(result.secondMomentStateSHA256, exactCount: 64),
      !step.controlState.canonicalBytes.isEmpty
    else {
      throw AssayError.contractDrift(
        "step scalar or control infrastructure")
    }
  }

  private static func validateEvaluationInfrastructure(
    _ evaluation:
      PrimeNativeDecoderTinyMetalTrajectoryEvaluationObservationV1
  ) throws {
    try validateTensor(evaluation.logits)
    let result = evaluation.result
    let scalarBits =
      [result.lossFloat32BitPattern]
      + result.selectedLossFloat32BitPatterns
    guard result.selectedTargetCount > 0,
      result.selectedLossFloat32BitPatterns.count
        == result.selectedTargetCount,
      scalarBits.allSatisfy({ Float(bitPattern: $0).isFinite }),
      isLowercaseHex(result.parameterStateSHA256, exactCount: 64),
      isLowercaseHex(result.firstMomentStateSHA256, exactCount: 64),
      isLowercaseHex(result.secondMomentStateSHA256, exactCount: 64),
      evaluation.logits.path == "evaluation_logits",
      evaluation.logits.shape == [2, 6, 32]
    else {
      throw AssayError.contractDrift(
        "evaluation scalar or logits infrastructure")
    }
  }

  private static func validateBoundaryInfrastructure(
    _ boundary: PrimeNativeDecoderTinyMetalTrajectoryBoundaryObservationV1
  ) throws {
    try validateTensorLists([
      boundary.tensors.modelParameters,
      boundary.tensors.firstMoments,
      boundary.tensors.secondMoments,
    ])
    guard !boundary.controlState.canonicalBytes.isEmpty
    else {
      throw AssayError.contractDrift("boundary infrastructure")
    }
  }

  private static func validateForwardInfrastructure(
    _ forward:
      PrimeNativeDecoderTinyTrainingInputPathForwardEquivalenceObservationV1
  ) throws {
    try validateTensor(forward.maintainedGatherEmbedding)
    try validateTensor(forward.denseEmbedding)
    try validateTensor(forward.maintainedGatherWholeLogits)
    try validateTensor(forward.denseWholeLogits)
    guard
      forward.maintainedGatherEmbedding.path
        == "maintained_gather_embedding",
      forward.denseEmbedding.path == "dense_embedding",
      forward.maintainedGatherWholeLogits.path
        == "maintained_gather_whole_logits",
      forward.denseWholeLogits.path == "dense_whole_logits",
      forward.maintainedGatherEmbedding.shape == [2, 6, 16],
      forward.denseEmbedding.shape == [2, 6, 16],
      forward.maintainedGatherWholeLogits.shape == [2, 6, 32],
      forward.denseWholeLogits.shape == [2, 6, 32]
    else {
      throw AssayError.contractDrift("forward fixture infrastructure")
    }
  }

  private static func validateTensorLists(
    _ lists: [[PrimeNativeDecoderTinyCPUExactTensorValueV1]]
  ) throws {
    var expectedInventory: [(String, [Int], String)]?
    for tensors in lists {
      guard tensors.count == 20,
        tensors.map(\.path)
          == tensors.map(\.path).sorted(by: utf8Less),
        Set(tensors.map(\.path)).count == 20
      else {
        throw AssayError.contractDrift("canonical tensor paths")
      }
      for tensor in tensors {
        try validateTensor(tensor)
      }
      let inventory = tensors.map { ($0.path, $0.shape, $0.dtype) }
      if let expectedInventory {
        guard
          zip(expectedInventory, inventory).allSatisfy({
            $0.0.0 == $0.1.0
              && $0.0.1 == $0.1.1
              && $0.0.2 == $0.1.2
          })
        else {
          throw AssayError.contractDrift("tensor inventory drift")
        }
      } else {
        expectedInventory = inventory
      }
    }
  }

  private static func validateTensor(
    _ tensor: PrimeNativeDecoderTinyCPUExactTensorValueV1
  ) throws {
    let expectedBytes = tensor.float32BitPatterns.flatMap { bits in
      [
        UInt8(bits & 0xff),
        UInt8((bits >> 8) & 0xff),
        UInt8((bits >> 16) & 0xff),
        UInt8((bits >> 24) & 0xff),
      ]
    }
    guard tensor.dtype == "float32",
      tensor.shape.allSatisfy({ $0 > 0 }),
      tensor.shape.reduce(1, *)
        == tensor.float32BitPatterns.count,
      expectedBytes == tensor.float32LittleEndianBytes,
      tensor.float32BitPatterns.allSatisfy({
        Float(bitPattern: $0).isFinite
      })
    else {
      throw AssayError.contractDrift(
        "canonical tensor shape dtype or bytes")
    }
  }

  private static func compareSteps(
    _ reference: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1,
    _ observed: PrimeNativeDecoderTinyMetalTrajectoryStepObservationV1,
    trialOrdinal: Int,
    referenceBranch: String,
    observedBranch: String,
    accumulator: inout ComparisonAccumulator,
    arm: String = "arm_b",
    domainPrefix: String? = nil
  ) throws {
    let globalDomain =
      domainPrefix.map {
        $0 + "_scalar_bits"
      } ?? "global_step_and_selected_target_count"
    accumulator.scalar(
      domain: globalDomain,
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      scalarName: "global_step",
      referenceBits: Float(reference.result.globalStep).bitPattern,
      observedBits: Float(observed.result.globalStep).bitPattern,
      arm: arm)
    accumulator.scalar(
      domain: globalDomain,
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      scalarName: "selected_target_count",
      referenceBits:
        Float(reference.result.selectedTargetCount).bitPattern,
      observedBits:
        Float(observed.result.selectedTargetCount).bitPattern,
      arm: arm)

    let scalarDomain =
      domainPrefix.map {
        $0 + "_scalar_bits"
      } ?? "training_loss_norm_and_clip_scalar_bits"
    try compareStepScalars(
      reference.result,
      observed.result,
      domain: scalarDomain,
      trialOrdinal: trialOrdinal,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      accumulator: &accumulator,
      arm: arm)

    let controlDomain =
      domainPrefix.map {
        $0 + "_tensor_bytes"
      } ?? "control_rng_and_cursor_state"
    try accumulator.tensor(
      domain: controlDomain,
      trialOrdinal: trialOrdinal,
      branch: observedBranch,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      component: "control_state_bytes",
      path: "control_state",
      dtype: "uint8",
      shape: [reference.controlState.canonicalBytes.count],
      referenceBytes: reference.controlState.canonicalBytes,
      observedBytes: observed.controlState.canonicalBytes,
      arm: arm)

    try compareTensorLists(
      reference.rawGradients,
      observed.rawGradients,
      domain: domainPrefix.map { $0 + "_tensor_bytes" }
        ?? "raw_and_clipped_gradient_bytes",
      component: "raw_gradient_bytes",
      pathPrefix: "raw_gradient",
      trialOrdinal: trialOrdinal,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      accumulator: &accumulator,
      arm: arm)
    try compareTensorLists(
      reference.clippedGradients,
      observed.clippedGradients,
      domain: domainPrefix.map { $0 + "_tensor_bytes" }
        ?? "raw_and_clipped_gradient_bytes",
      component: "clipped_gradient_bytes",
      pathPrefix: "clipped_gradient",
      trialOrdinal: trialOrdinal,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      accumulator: &accumulator,
      arm: arm)
    try compareTensorState(
      reference.postStepTensors,
      observed.postStepTensors,
      trialOrdinal: trialOrdinal,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      accumulator: &accumulator,
      arm: arm,
      domainPrefix: domainPrefix)
  }

  private static func compareStepScalars(
    _ reference: PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1,
    _ observed: PrimeNativeDecoderTinyCPUTrainEvaluateStepResultV1,
    domain: String,
    trialOrdinal: Int,
    referenceBranch: String,
    observedBranch: String,
    accumulator: inout ComparisonAccumulator,
    arm: String
  ) throws {
    let values: [(String, UInt32, UInt32)] = [
      (
        "loss", reference.lossFloat32BitPattern,
        observed.lossFloat32BitPattern
      ),
      (
        "raw_global_gradient_norm",
        reference.rawGlobalGradientNormFloat32BitPattern,
        observed.rawGlobalGradientNormFloat32BitPattern
      ),
      (
        "gradient_clip_scale",
        reference.gradientClipScaleFloat32BitPattern,
        observed.gradientClipScaleFloat32BitPattern
      ),
      (
        "clipped_global_gradient_norm",
        reference.clippedGlobalGradientNormFloat32BitPattern,
        observed.clippedGlobalGradientNormFloat32BitPattern
      ),
    ]
    for value in values {
      accumulator.scalar(
        domain: domain,
        trialOrdinal: trialOrdinal,
        branch: observedBranch,
        referenceBranch: referenceBranch,
        observedBranch: observedBranch,
        scalarName: value.0,
        referenceBits: value.1,
        observedBits: value.2,
        arm: arm)
    }
    guard
      reference.selectedLossFloat32BitPatterns.count
        == observed.selectedLossFloat32BitPatterns.count
    else {
      throw AssayError.contractDrift("selected loss inventory")
    }
    for index in reference.selectedLossFloat32BitPatterns.indices {
      accumulator.scalar(
        domain: domain,
        trialOrdinal: trialOrdinal,
        branch: observedBranch,
        referenceBranch: referenceBranch,
        observedBranch: observedBranch,
        scalarName: "selected_loss_\(index)",
        referenceBits:
          reference.selectedLossFloat32BitPatterns[index],
        observedBits:
          observed.selectedLossFloat32BitPatterns[index],
        arm: arm)
    }
  }

  private static func compareTensorState(
    _ reference: PrimeNativeDecoderTinyCPUExactTensorStateV1,
    _ observed: PrimeNativeDecoderTinyCPUExactTensorStateV1,
    trialOrdinal: Int,
    referenceBranch: String,
    observedBranch: String,
    accumulator: inout ComparisonAccumulator,
    arm: String,
    domainPrefix: String?
  ) throws {
    let modelDomain =
      domainPrefix.map { $0 + "_tensor_bytes" }
      ?? "model_parameter_bytes"
    let optimizerDomain =
      domainPrefix.map { $0 + "_tensor_bytes" }
      ?? "optimizer_first_and_second_moment_bytes"
    try compareTensorLists(
      reference.modelParameters,
      observed.modelParameters,
      domain: modelDomain,
      component: "model_parameter_bytes",
      pathPrefix: "model_parameter",
      trialOrdinal: trialOrdinal,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      accumulator: &accumulator,
      arm: arm)
    try compareTensorLists(
      reference.firstMoments,
      observed.firstMoments,
      domain: optimizerDomain,
      component: "optimizer_first_moment_bytes",
      pathPrefix: "first_moment",
      trialOrdinal: trialOrdinal,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      accumulator: &accumulator,
      arm: arm)
    try compareTensorLists(
      reference.secondMoments,
      observed.secondMoments,
      domain: optimizerDomain,
      component: "optimizer_second_moment_bytes",
      pathPrefix: "second_moment",
      trialOrdinal: trialOrdinal,
      referenceBranch: referenceBranch,
      observedBranch: observedBranch,
      accumulator: &accumulator,
      arm: arm)
  }

  private static func compareTensorLists(
    _ reference: [PrimeNativeDecoderTinyCPUExactTensorValueV1],
    _ observed: [PrimeNativeDecoderTinyCPUExactTensorValueV1],
    domain: String,
    component: String,
    pathPrefix: String,
    trialOrdinal: Int,
    referenceBranch: String,
    observedBranch: String,
    accumulator: inout ComparisonAccumulator,
    arm: String = "arm_b"
  ) throws {
    guard reference.count == observed.count else {
      throw AssayError.contractDrift("compared tensor inventory count")
    }
    for (referenceTensor, observedTensor) in zip(reference, observed) {
      guard referenceTensor.path == observedTensor.path,
        referenceTensor.shape == observedTensor.shape,
        referenceTensor.dtype == observedTensor.dtype
      else {
        throw AssayError.contractDrift(
          "compared tensor inventory identity")
      }
      try accumulator.tensor(
        domain: domain,
        trialOrdinal: trialOrdinal,
        branch: observedBranch,
        referenceBranch: referenceBranch,
        observedBranch: observedBranch,
        component: component,
        path: pathPrefix + "/" + referenceTensor.path,
        dtype: referenceTensor.dtype,
        shape: referenceTensor.shape,
        referenceBytes: referenceTensor.float32LittleEndianBytes,
        observedBytes: observedTensor.float32LittleEndianBytes,
        arm: arm)
    }
  }

  private static func candidateLess(
    _ lhs: MismatchCandidate,
    _ rhs: MismatchCandidate
  ) -> Bool {
    if lhs.domainRank != rhs.domainRank {
      return lhs.domainRank < rhs.domainRank
    }
    if lhs.mismatch.trial_ordinal != rhs.mismatch.trial_ordinal {
      return lhs.mismatch.trial_ordinal < rhs.mismatch.trial_ordinal
    }
    if lhs.branchRank != rhs.branchRank {
      return lhs.branchRank < rhs.branchRank
    }
    if lhs.pathOrScalar != rhs.pathOrScalar {
      return utf8Less(lhs.pathOrScalar, rhs.pathOrScalar)
    }
    return lhs.byteOrScalarOrdinal < rhs.byteOrScalarOrdinal
  }

  private static func utf8Less(_ lhs: String, _ rhs: String) -> Bool {
    lhs.utf8.lexicographicallyPrecedes(rhs.utf8)
  }
}
