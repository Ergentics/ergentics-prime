// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreGraphics
import Darwin
import Foundation
import Metal
import MLX
import PrimeCore
import PrimeNativeDecoder
import PrimeNativeDecoderCheckpoint

public enum PrimeNativeDecoderRuntimeError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift(String)
    case fileSystemFailure(
        operation: String,
        path: String,
        errno: Int32
    )
    case unsafeFile(String)
    case runtimeImageUnavailable
    case runtimeImageIsNotMainExecutable
    case invalidLoaderCandidateCount(Int)
    case unexpectedLoaderCandidate(String)
    case metallibByteCountMismatch(
        expected: UInt64,
        actual: UInt64
    )
    case metallibSHA256Mismatch(
        expected: String,
        actual: String
    )
    case metalDeviceCountMismatch(Int)
    case defaultMetalDeviceUnavailable
    case defaultMetalDeviceMismatch
    case metallibLibraryValidationFailed(String)
    case mlxProbeShapeMismatch([Int])
    case mlxProbeDTypeMismatch(String)
    case mlxProbeValueMismatch([UInt32])
}

extension PrimeNativeDecoderRuntimeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .contractDrift(detail):
            "native-decoder runtime contract drift: \(detail)"
        case let .fileSystemFailure(operation, path, code):
            "native-decoder runtime \(operation) failed for \(path): errno \(code)"
        case let .unsafeFile(path):
            "native-decoder runtime rejected unsafe file: \(path)"
        case .runtimeImageUnavailable:
            "native-decoder runtime image is unavailable"
        case .runtimeImageIsNotMainExecutable:
            "native-decoder runtime is not statically linked into the main executable"
        case let .invalidLoaderCandidateCount(count):
            "native-decoder runtime observed \(count) existing MLX loader candidates"
        case let .unexpectedLoaderCandidate(path):
            "native-decoder runtime observed an unexpected MLX loader candidate: \(path)"
        case let .metallibByteCountMismatch(expected, actual):
            "native-decoder runtime metallib byte count mismatch: expected \(expected), actual \(actual)"
        case let .metallibSHA256Mismatch(expected, actual):
            "native-decoder runtime metallib SHA-256 mismatch: expected \(expected), actual \(actual)"
        case let .metalDeviceCountMismatch(count):
            "native-decoder runtime requires one Metal device, observed \(count)"
        case .defaultMetalDeviceUnavailable:
            "native-decoder runtime has no default Metal device"
        case .defaultMetalDeviceMismatch:
            "native-decoder runtime default Metal device does not match index zero"
        case let .metallibLibraryValidationFailed(detail):
            "native-decoder runtime could not validate the metallib: \(detail)"
        case let .mlxProbeShapeMismatch(shape):
            "native-decoder runtime MLX probe shape mismatch: \(shape)"
        case let .mlxProbeDTypeMismatch(dtype):
            "native-decoder runtime MLX probe dtype mismatch: \(dtype)"
        case let .mlxProbeValueMismatch(values):
            "native-decoder runtime MLX probe value mismatch: \(values)"
        }
    }
}

/// Pure, declarative preparation for the maintained native-decoder runtime.
///
/// Creating or validating this value validates the repaired V2 compatibility
/// identity and reconstructs the Native-300M inventory. It does not allocate a
/// decoder, initialize MLX, execute a forward pass, or perform checkpoint I/O.
public struct PrimeNativeDecoderMaintainedRuntimePlanV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let planID: String
    public let authorityID: String
    public let compatibilityIdentitySchema: String
    public let compatibilityIdentityCanonicalByteCount: Int
    public let compatibilityIdentitySHA256: String
    public let repairedDecoderSourceSHA256: String
    public let exactMLXRevision: String
    public let configuration: PrimeNativeDecoderConfigurationSnapshotV1
    public let initializationProbeOperation: String
    public let initializationProbeDType: String
    public let initializationProbeShape: [Int]
    public let initializationProbeLeftFloat32BitPatterns: [UInt32]
    public let initializationProbeRightFloat32BitPatterns: [UInt32]
    public let initializationProbeExpectedFloat32BitPatterns: [UInt32]
    public let decoderModelAllocated: Bool
    public let decoderForwardObserved: Bool
    public let checkpointIOObserved: Bool
    public let trainingExecutionObserved: Bool

    public static func native300MByte512() throws -> Self {
        try makeNative300MByte512()
    }

    public func validate() throws {
        guard self == (try Self.makeNative300MByte512()) else {
            throw PrimeNativeDecoderRuntimeError
                .contractDrift("maintained runtime plan")
        }
    }

    private static func makeNative300MByte512() throws -> Self {
        let authority =
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1
        try authority.validateExactV1()

        let identity = try PrimeNativeDecoderCompatibilityIdentityV2
            .native300MByte512()
        try identity.validate()
        let identityBytes = try PrimeCanonicalJSON.encode(identity)
        let compatibilityAuthority =
            PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan
                .frozenV2
        let configuration = try identity.configuration.configuration()
        let expectedConfiguration = try
            PrimeNativeGQADecoderConfiguration
                .native300MInventory(vocabularySize: 512)

        guard configuration == expectedConfiguration,
              identityBytes.count
                == compatibilityAuthority
                    .publicV2CanonicalIdentityByteCount,
              PrimeSHA256.hexDigest(of: identityBytes)
                == compatibilityAuthority
                    .publicV2CanonicalIdentitySHA256,
              identity.decoderSourceSHA256
                == authority.repairedDecoderSourceSHA256,
              identity.exactMLXRevision == authority.exactMLXRevision,
              identity.totalParameterCount
                == UInt64(expectedConfiguration.uniqueParameterCount)
        else {
            throw PrimeNativeDecoderRuntimeError
                .contractDrift("repaired V2 inventory")
        }

        return Self(
            schemaVersion: 1,
            planID:
                "ergentics_prime_native_decoder_maintained_runtime_plan_v1",
            authorityID: authority.authorityID,
            compatibilityIdentitySchema: identity.schemaID,
            compatibilityIdentityCanonicalByteCount:
                identityBytes.count,
            compatibilityIdentitySHA256:
                PrimeSHA256.hexDigest(of: identityBytes),
            repairedDecoderSourceSHA256:
                identity.decoderSourceSHA256,
            exactMLXRevision: identity.exactMLXRevision,
            configuration:
                PrimeNativeDecoderConfigurationSnapshotV1(
                    configuration
                ),
            initializationProbeOperation:
                authority.initializationProbeOperation,
            initializationProbeDType:
                authority.initializationProbeDType,
            initializationProbeShape:
                authority.initializationProbeShape,
            initializationProbeLeftFloat32BitPatterns:
                authority
                    .initializationProbeLeftFloat32BitPatterns,
            initializationProbeRightFloat32BitPatterns:
                authority
                    .initializationProbeRightFloat32BitPatterns,
            initializationProbeExpectedFloat32BitPatterns:
                authority
                    .initializationProbeExpectedFloat32BitPatterns,
            decoderModelAllocated: false,
            decoderForwardObserved: false,
            checkpointIOObserved: false,
            trainingExecutionObserved: false
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case planID = "plan_id"
        case authorityID = "authority_id"
        case compatibilityIdentitySchema =
            "compatibility_identity_schema"
        case compatibilityIdentityCanonicalByteCount =
            "compatibility_identity_canonical_byte_count"
        case compatibilityIdentitySHA256 =
            "compatibility_identity_sha256"
        case repairedDecoderSourceSHA256 =
            "repaired_decoder_source_sha256"
        case exactMLXRevision = "exact_mlx_revision"
        case configuration
        case initializationProbeOperation =
            "initialization_probe_operation"
        case initializationProbeDType =
            "initialization_probe_dtype"
        case initializationProbeShape =
            "initialization_probe_shape"
        case initializationProbeLeftFloat32BitPatterns =
            "initialization_probe_left_float32_bit_patterns"
        case initializationProbeRightFloat32BitPatterns =
            "initialization_probe_right_float32_bit_patterns"
        case initializationProbeExpectedFloat32BitPatterns =
            "initialization_probe_expected_float32_bit_patterns"
        case decoderModelAllocated = "decoder_model_allocated"
        case decoderForwardObserved = "decoder_forward_observed"
        case checkpointIOObserved = "checkpoint_io_observed"
        case trainingExecutionObserved =
            "training_execution_observed"
    }
}

public struct PrimeNativeDecoderRuntimeExecutableEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let captureMethod: String
    public let executableName: String
    public let byteCount: UInt64
    public let sha256: String
    public let deviceID: UInt64
    public let inode: UInt64
    public let pathAndDescriptorReverified: Bool

    private enum CodingKeys: String, CodingKey {
        case captureMethod = "capture_method"
        case executableName = "executable_name"
        case byteCount = "byte_count"
        case sha256
        case deviceID = "device_id"
        case inode
        case pathAndDescriptorReverified =
            "path_and_descriptor_reverified"
    }
}

public struct PrimeNativeDecoderRuntimeMetallibEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let artifactRelativePath: String
    public let byteCount: UInt64
    public let sha256: String
    public let deviceID: UInt64
    public let inode: UInt64
    public let uniqueCandidateCountBeforeExecution: Int
    public let uniqueCandidateCountAfterExecution: Int
    public let existingCandidateCountBeforeExecution: Int
    public let existingCandidateCountAfterExecution: Int
    public let sourcePinnedLoaderIdentityClaimKind: String
    public let pathAndDescriptorReverified: Bool
    public let metalLibraryValidatedFromExactURL: Bool

    private enum CodingKeys: String, CodingKey {
        case artifactRelativePath = "artifact_relative_path"
        case byteCount = "byte_count"
        case sha256
        case deviceID = "device_id"
        case inode
        case uniqueCandidateCountBeforeExecution =
            "unique_candidate_count_before_execution"
        case uniqueCandidateCountAfterExecution =
            "unique_candidate_count_after_execution"
        case existingCandidateCountBeforeExecution =
            "existing_candidate_count_before_execution"
        case existingCandidateCountAfterExecution =
            "existing_candidate_count_after_execution"
        case sourcePinnedLoaderIdentityClaimKind =
            "source_pinned_loader_identity_claim_kind"
        case pathAndDescriptorReverified =
            "path_and_descriptor_reverified"
        case metalLibraryValidatedFromExactURL =
            "metal_library_validated_from_exact_url"
    }
}

public struct PrimeNativeDecoderRuntimeMetalDeviceEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let coreGraphicsBootstrapObserved: Bool
    public let enumeratedDeviceCount: Int
    public let indexZeroName: String
    public let indexZeroRegistryID: UInt64
    public let indexZeroArchitectureName: String
    public let indexZeroHasUnifiedMemory: Bool
    public let indexZeroIsLowPower: Bool
    public let indexZeroIsRemovable: Bool
    public let indexZeroIsHeadless: Bool
    public let defaultDeviceMatchedIndexZero: Bool
    public let postflightDeviceReverified: Bool
    public let mlxDeviceIdentityClaimKind: String
    public let physicalGPUIdentityRequired: Bool

    private enum CodingKeys: String, CodingKey {
        case coreGraphicsBootstrapObserved =
            "core_graphics_bootstrap_observed"
        case enumeratedDeviceCount = "enumerated_device_count"
        case indexZeroName = "index_zero_name"
        case indexZeroRegistryID = "index_zero_registry_id"
        case indexZeroArchitectureName =
            "index_zero_architecture_name"
        case indexZeroHasUnifiedMemory =
            "index_zero_has_unified_memory"
        case indexZeroIsLowPower = "index_zero_is_low_power"
        case indexZeroIsRemovable = "index_zero_is_removable"
        case indexZeroIsHeadless = "index_zero_is_headless"
        case defaultDeviceMatchedIndexZero =
            "default_device_matched_index_zero"
        case postflightDeviceReverified =
            "postflight_device_reverified"
        case mlxDeviceIdentityClaimKind =
            "mlx_device_identity_claim_kind"
        case physicalGPUIdentityRequired =
            "physical_gpu_identity_required"
    }
}

public struct PrimeNativeDecoderRuntimeMLXInitializationEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let deviceType: String
    public let deviceIndex: Int
    public let operation: String
    public let dtype: String
    public let shape: [Int]
    public let leftFloat32BitPatterns: [UInt32]
    public let rightFloat32BitPatterns: [UInt32]
    public let outputFloat32BitPatterns: [UInt32]
    public let evaluationAPI: String
    public let readbackAPI: String
    public let exactOutputEstablished: Bool
    public let launchedEnvironmentRevalidatedAfterEvaluation: Bool
    public let tf32StaticValueDirectlyObserved: Bool
    public let tf32DifferentialObserved: Bool
    public let naxTF32ConsumerPathObserved: Bool

    private enum CodingKeys: String, CodingKey {
        case deviceType = "device_type"
        case deviceIndex = "device_index"
        case operation
        case dtype
        case shape
        case leftFloat32BitPatterns =
            "left_float32_bit_patterns"
        case rightFloat32BitPatterns =
            "right_float32_bit_patterns"
        case outputFloat32BitPatterns =
            "output_float32_bit_patterns"
        case evaluationAPI = "evaluation_api"
        case readbackAPI = "readback_api"
        case exactOutputEstablished = "exact_output_established"
        case launchedEnvironmentRevalidatedAfterEvaluation =
            "launched_environment_revalidated_after_evaluation"
        case tf32StaticValueDirectlyObserved =
            "tf32_static_value_directly_observed"
        case tf32DifferentialObserved =
            "tf32_differential_observed"
        case naxTF32ConsumerPathObserved =
            "nax_tf32_consumer_path_observed"
    }
}

/// Primitive-only evidence returned after the bounded runtime closure.
///
/// No Metal, MLX, decoder, or checkpoint handle escapes in this value. The
/// metallib identity claim is deliberately limited to exhaustive source-pinned
/// loader precedence plus one exclusive candidate; the loaded path was not
/// independently instrumented.
public struct PrimeNativeDecoderMaintainedRuntimeInitializationEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let evidenceID: String
    public let authorityID: String
    public let plan: PrimeNativeDecoderMaintainedRuntimePlanV1
    public let environmentPolicy:
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    public let releaseInstrumentation:
        PrimeReleaseInstrumentationAdmissionEvidence
    public let executable:
        PrimeNativeDecoderRuntimeExecutableEvidenceV1
    public let metallibExpectation:
        PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
    public let metallib:
        PrimeNativeDecoderRuntimeMetallibEvidenceV1
    public let metalDevice:
        PrimeNativeDecoderRuntimeMetalDeviceEvidenceV1
    public let mlxInitialization:
        PrimeNativeDecoderRuntimeMLXInitializationEvidenceV1

    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeLoadedMetallibIdentityEstablished: Bool
    public let sourcePinnedExclusiveCandidateInferenceEstablished: Bool
    public let loadedMetallibIdentityIndependentlyObserved: Bool
    public let runtimeMetalDeviceIdentityEstablished: Bool
    public let boundedMLXRuntimeInitializationEstablished: Bool
    public let callerExpectationIsArtifactAdmission: Bool
    public let metallibArtifactProvenanceEstablished: Bool
    public let decoderModelInitializationEstablished: Bool
    public let decoderForwardObserved: Bool
    public let checkpointIOObserved: Bool
    public let checkpointAdmissionGranted: Bool
    public let trainingExecutionObserved: Bool
    public let productUseAuthorized: Bool

    public func validate() throws {
        try plan.validate()
        try metallibExpectation.validate()
        let authority =
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1
        try authority.validateExactV1()

        guard schemaVersion == 1,
              evidenceID
                == "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
              authorityID == authority.authorityID,
              plan.authorityID == authorityID,
              environmentPolicy
                == PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                    .declaration,
              releaseInstrumentation.declaration
                == PrimeReleaseInstrumentationAdmissionPolicy.declaration,
              !releaseInstrumentation.observation
                .instrumentationObserved,
              executable.captureMethod
                == "prime_secure_running_executable_capture_plus_retained_descriptor_v1",
              executable.byteCount > 0,
              isExactLowercaseSHA256(
                  executable.sha256
              ),
              executable.pathAndDescriptorReverified,
              metallib.artifactRelativePath
                == metallibExpectation.artifactRelativePath,
              metallib.byteCount == metallibExpectation.byteCount,
              metallib.sha256 == metallibExpectation.sha256,
              metallib.existingCandidateCountBeforeExecution == 1,
              metallib.existingCandidateCountAfterExecution == 1,
              metallib.sourcePinnedLoaderIdentityClaimKind
                == authority.loaderIdentityClaimKind,
              metallib.pathAndDescriptorReverified,
              metallib.metalLibraryValidatedFromExactURL,
              metalDevice.coreGraphicsBootstrapObserved,
              metalDevice.enumeratedDeviceCount
                == authority.requiredMetalDeviceCount,
              metalDevice.defaultDeviceMatchedIndexZero,
              metalDevice.postflightDeviceReverified,
              metalDevice.mlxDeviceIdentityClaimKind
                == authority.mlxDeviceIdentityClaimKind,
              metalDevice.physicalGPUIdentityRequired
                == authority.physicalGPUIdentityRequired,
              mlxInitialization.deviceType == "gpu",
              mlxInitialization.deviceIndex
                == authority.requiredMLXGPUIndex,
              mlxInitialization.operation
                == plan.initializationProbeOperation,
              mlxInitialization.dtype
                == plan.initializationProbeDType,
              mlxInitialization.shape
                == plan.initializationProbeShape,
              mlxInitialization.leftFloat32BitPatterns
                == plan.initializationProbeLeftFloat32BitPatterns,
              mlxInitialization.rightFloat32BitPatterns
                == plan.initializationProbeRightFloat32BitPatterns,
              mlxInitialization.outputFloat32BitPatterns
                == plan.initializationProbeExpectedFloat32BitPatterns,
              mlxInitialization.evaluationAPI
                == authority.initializationProbeEvaluationAPI,
              mlxInitialization.readbackAPI
                == authority.initializationProbeReadbackAPI,
              mlxInitialization.exactOutputEstablished,
              mlxInitialization
                .launchedEnvironmentRevalidatedAfterEvaluation,
              !mlxInitialization.tf32StaticValueDirectlyObserved,
              !mlxInitialization.tf32DifferentialObserved,
              !mlxInitialization.naxTF32ConsumerPathObserved,
              runtimeDependencyClosureEstablished,
              !runtimeLoadedMetallibIdentityEstablished,
              sourcePinnedExclusiveCandidateInferenceEstablished,
              !loadedMetallibIdentityIndependentlyObserved,
              runtimeMetalDeviceIdentityEstablished,
              boundedMLXRuntimeInitializationEstablished,
              !callerExpectationIsArtifactAdmission,
              !metallibArtifactProvenanceEstablished,
              !decoderModelInitializationEstablished,
              !decoderForwardObserved,
              !checkpointIOObserved,
              !checkpointAdmissionGranted,
              !trainingExecutionObserved,
              !productUseAuthorized
        else {
            throw PrimeNativeDecoderRuntimeError
                .contractDrift("initialization evidence")
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case evidenceID = "evidence_id"
        case authorityID = "authority_id"
        case plan
        case environmentPolicy = "environment_policy"
        case releaseInstrumentation = "release_instrumentation"
        case executable
        case metallibExpectation = "metallib_expectation"
        case metallib
        case metalDevice = "metal_device"
        case mlxInitialization = "mlx_initialization"
        case runtimeDependencyClosureEstablished =
            "runtime_dependency_closure_established"
        case runtimeLoadedMetallibIdentityEstablished =
            "runtime_loaded_metallib_identity_established"
        case sourcePinnedExclusiveCandidateInferenceEstablished =
            "source_pinned_exclusive_candidate_inference_established"
        case loadedMetallibIdentityIndependentlyObserved =
            "loaded_metallib_identity_independently_observed"
        case runtimeMetalDeviceIdentityEstablished =
            "runtime_metal_device_identity_established"
        case boundedMLXRuntimeInitializationEstablished =
            "bounded_mlx_runtime_initialization_established"
        case callerExpectationIsArtifactAdmission =
            "caller_expectation_is_artifact_admission"
        case metallibArtifactProvenanceEstablished =
            "metallib_artifact_provenance_established"
        case decoderModelInitializationEstablished =
            "decoder_model_initialization_established"
        case decoderForwardObserved = "decoder_forward_observed"
        case checkpointIOObserved = "checkpoint_io_observed"
        case checkpointAdmissionGranted =
            "checkpoint_admission_granted"
        case trainingExecutionObserved =
            "training_execution_observed"
        case productUseAuthorized = "product_use_authorized"
    }
}

/// The bounded maintained runtime entry point.
///
/// The caller must launch this process with the exact admitted environment.
/// This function never mutates the environment and must be followed by process
/// exit; it returns no live framework or model handle.
public enum PrimeNativeDecoderRuntime {
    public static func initializeCurrentProcess(
        metallibExpectation:
            PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1,
        metalLeaseURL: URL
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeInitializationEvidenceV1
    {
        let environmentPolicy = try
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateLaunchedCurrentProcess()
        let releaseInstrumentation = try
            PrimeReleaseInstrumentationAdmissionPolicy
                .validateCurrentProcess()
        let executable = try PrimeRuntimeHeldExecutable()

        let lease = try PrimeMetalDeviceLease.acquire(
            at: metalLeaseURL
        )
        defer { lease.release() }

        let authority =
            PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1
                .frozenV1
        try authority.validateExactV1()
        try metallibExpectation.validate()
        let plan = try PrimeNativeDecoderMaintainedRuntimePlanV1
            .native300MByte512()
        try plan.validate()

        let runtimeImageDirectory = try requireStaticRuntimeImage(
            executableURL: executable.url
        ).deletingLastPathComponent()
        let expectedMetallibURL = appendRelativePath(
            metallibExpectation.artifactRelativePath,
            to: runtimeImageDirectory
        )
        let preflightCandidates = try loaderCandidates(
            runtimeImageDirectory: runtimeImageDirectory
        )
        let preflightExisting = try existingCandidates(
            in: preflightCandidates
        )
        guard preflightExisting.count == 1 else {
            throw PrimeNativeDecoderRuntimeError
                .invalidLoaderCandidateCount(
                    preflightExisting.count
                )
        }
        guard preflightExisting[0].url.path
                == expectedMetallibURL.path else {
            throw PrimeNativeDecoderRuntimeError
                .unexpectedLoaderCandidate(
                    preflightExisting[0].url.path
                )
        }
        let metallib = try PrimeRuntimeHeldMetallib(
            url: preflightExisting[0].url,
            expectation: metallibExpectation
        )

        guard lease.isHeld else {
            throw PrimeNativeDecoderRuntimeError
                .contractDrift("Metal lease was released")
        }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard colorSpace.model == .rgb else {
            throw PrimeNativeDecoderRuntimeError
                .contractDrift("CoreGraphics bootstrap")
        }

        let metalDevices = MTLCopyAllDevices()
        guard metalDevices.count == authority.requiredMetalDeviceCount else {
            throw PrimeNativeDecoderRuntimeError
                .metalDeviceCountMismatch(metalDevices.count)
        }
        guard let indexZero = metalDevices.first else {
            throw PrimeNativeDecoderRuntimeError
                .metalDeviceCountMismatch(0)
        }
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            throw PrimeNativeDecoderRuntimeError
                .defaultMetalDeviceUnavailable
        }
        try requireSameMetalDevice(
            indexZero,
            defaultDevice
        )

        let validatedLibrary: any MTLLibrary
        do {
            validatedLibrary = try indexZero.makeLibrary(
                URL: metallib.url
            )
        } catch {
            throw PrimeNativeDecoderRuntimeError
                .metallibLibraryValidationFailed(
                    String(describing: error)
                )
        }

        let outputBitPatterns = try withExtendedLifetime(
            validatedLibrary
        ) {
            try executeBoundedMLXProbe(plan: plan)
        }

        let postflightEnvironmentPolicy = try
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateLaunchedCurrentProcess()
        guard postflightEnvironmentPolicy == environmentPolicy else {
            throw PrimeNativeDecoderRuntimeError
                .contractDrift("launched environment changed")
        }

        try metallib.revalidate(expectation: metallibExpectation)
        let postflightCandidates = try loaderCandidates(
            runtimeImageDirectory: runtimeImageDirectory
        )
        let postflightExisting = try existingCandidates(
            in: postflightCandidates
        )
        guard postflightExisting.count == 1 else {
            throw PrimeNativeDecoderRuntimeError
                .invalidLoaderCandidateCount(
                    postflightExisting.count
                )
        }
        guard postflightExisting[0].url.path
                == metallib.url.path else {
            throw PrimeNativeDecoderRuntimeError
                .unexpectedLoaderCandidate(
                    postflightExisting[0].url.path
                )
        }

        let postflightDevices = MTLCopyAllDevices()
        guard postflightDevices.count
                == authority.requiredMetalDeviceCount,
              let postflightIndexZero = postflightDevices.first,
              let postflightDefault = MTLCreateSystemDefaultDevice()
        else {
            throw PrimeNativeDecoderRuntimeError
                .metalDeviceCountMismatch(
                    postflightDevices.count
                )
        }
        try requireSameMetalDevice(
            indexZero,
            postflightIndexZero
        )
        try requireSameMetalDevice(
            indexZero,
            postflightDefault
        )
        guard lease.isHeld else {
            throw PrimeNativeDecoderRuntimeError
                .contractDrift("Metal lease was released")
        }
        try executable.revalidate()

        let evidence =
            PrimeNativeDecoderMaintainedRuntimeInitializationEvidenceV1(
                schemaVersion: 1,
                evidenceID:
                    "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
                authorityID: authority.authorityID,
                plan: plan,
                environmentPolicy: environmentPolicy,
                releaseInstrumentation: releaseInstrumentation,
                executable:
                    PrimeNativeDecoderRuntimeExecutableEvidenceV1(
                        captureMethod:
                            "prime_secure_running_executable_capture_plus_retained_descriptor_v1",
                        executableName:
                            executable.url.lastPathComponent,
                        byteCount: executable.byteCount,
                        sha256: executable.sha256,
                        deviceID: executable.deviceID,
                        inode: executable.inode,
                        pathAndDescriptorReverified: true
                    ),
                metallibExpectation: metallibExpectation,
                metallib:
                    PrimeNativeDecoderRuntimeMetallibEvidenceV1(
                        artifactRelativePath:
                            metallibExpectation.artifactRelativePath,
                        byteCount: metallib.byteCount,
                        sha256: metallib.sha256,
                        deviceID: metallib.deviceID,
                        inode: metallib.inode,
                        uniqueCandidateCountBeforeExecution:
                            preflightCandidates.count,
                        uniqueCandidateCountAfterExecution:
                            postflightCandidates.count,
                        existingCandidateCountBeforeExecution:
                            preflightExisting.count,
                        existingCandidateCountAfterExecution:
                            postflightExisting.count,
                        sourcePinnedLoaderIdentityClaimKind:
                            authority.loaderIdentityClaimKind,
                        pathAndDescriptorReverified: true,
                        metalLibraryValidatedFromExactURL: true
                    ),
                metalDevice:
                    PrimeNativeDecoderRuntimeMetalDeviceEvidenceV1(
                        coreGraphicsBootstrapObserved: true,
                        enumeratedDeviceCount: metalDevices.count,
                        indexZeroName: indexZero.name,
                        indexZeroRegistryID: indexZero.registryID,
                        indexZeroArchitectureName:
                            indexZero.architecture.name,
                        indexZeroHasUnifiedMemory:
                            indexZero.hasUnifiedMemory,
                        indexZeroIsLowPower: indexZero.isLowPower,
                        indexZeroIsRemovable: indexZero.isRemovable,
                        indexZeroIsHeadless: indexZero.isHeadless,
                        defaultDeviceMatchedIndexZero: true,
                        postflightDeviceReverified: true,
                        mlxDeviceIdentityClaimKind:
                            authority.mlxDeviceIdentityClaimKind,
                        physicalGPUIdentityRequired:
                            authority.physicalGPUIdentityRequired
                    ),
                mlxInitialization:
                    PrimeNativeDecoderRuntimeMLXInitializationEvidenceV1(
                        deviceType: "gpu",
                        deviceIndex: authority.requiredMLXGPUIndex,
                        operation: plan.initializationProbeOperation,
                        dtype: plan.initializationProbeDType,
                        shape: plan.initializationProbeShape,
                        leftFloat32BitPatterns:
                            plan
                                .initializationProbeLeftFloat32BitPatterns,
                        rightFloat32BitPatterns:
                            plan
                                .initializationProbeRightFloat32BitPatterns,
                        outputFloat32BitPatterns: outputBitPatterns,
                        evaluationAPI:
                            authority.initializationProbeEvaluationAPI,
                        readbackAPI:
                            authority.initializationProbeReadbackAPI,
                        exactOutputEstablished: true,
                        launchedEnvironmentRevalidatedAfterEvaluation:
                            true,
                        tf32StaticValueDirectlyObserved: false,
                        tf32DifferentialObserved: false,
                        naxTF32ConsumerPathObserved: false
                    ),
                runtimeDependencyClosureEstablished: true,
                runtimeLoadedMetallibIdentityEstablished: false,
                sourcePinnedExclusiveCandidateInferenceEstablished:
                    true,
                loadedMetallibIdentityIndependentlyObserved: false,
                runtimeMetalDeviceIdentityEstablished: true,
                boundedMLXRuntimeInitializationEstablished: true,
                callerExpectationIsArtifactAdmission: false,
                metallibArtifactProvenanceEstablished: false,
                decoderModelInitializationEstablished: false,
                decoderForwardObserved: false,
                checkpointIOObserved: false,
                checkpointAdmissionGranted: false,
                trainingExecutionObserved: false,
                productUseAuthorized: false
            )
        try evidence.validate()
        return evidence
    }

    private static func executeBoundedMLXProbe(
        plan: PrimeNativeDecoderMaintainedRuntimePlanV1
    ) throws -> [UInt32] {
        // The pinned MLX Metal matmul source can consume
        // MLX_ENABLE_TF32 on a NAX-capable path. This probe establishes the
        // exact operation and result under the retained launch environment;
        // it does not directly observe the cached flag or NAX-path selection.
        let gpu = Device(.gpu, index: 0)
        return try Device.withDefaultDevice(gpu) {
            try withError {
                let left = MLXArray(
                    plan.initializationProbeLeftFloat32BitPatterns
                        .map(Float.init(bitPattern:)),
                    plan.initializationProbeShape
                )
                let right = MLXArray(
                    plan.initializationProbeRightFloat32BitPatterns
                        .map(Float.init(bitPattern:)),
                    plan.initializationProbeShape
                )
                let result = matmul(
                    left,
                    right,
                    stream: .device(gpu)
                )
                try checkedEval(result)
                guard result.shape
                        == plan.initializationProbeShape else {
                    throw PrimeNativeDecoderRuntimeError
                        .mlxProbeShapeMismatch(result.shape)
                }
                guard result.dtype == .float32 else {
                    throw PrimeNativeDecoderRuntimeError
                        .mlxProbeDTypeMismatch(
                            String(describing: result.dtype)
                        )
                }
                let output = result.asArray(Float.self)
                    .map(\.bitPattern)
                guard output
                        == plan
                            .initializationProbeExpectedFloat32BitPatterns
                else {
                    throw PrimeNativeDecoderRuntimeError
                        .mlxProbeValueMismatch(output)
                }
                return output
            }
        }
    }

    private static func requireSameMetalDevice(
        _ lhs: any MTLDevice,
        _ rhs: any MTLDevice
    ) throws {
        guard lhs.registryID == rhs.registryID,
              lhs.name == rhs.name,
              lhs.architecture.name == rhs.architecture.name else {
            throw PrimeNativeDecoderRuntimeError
                .defaultMetalDeviceMismatch
        }
    }
}

@_cdecl("ergentics_prime_native_decoder_runtime_image_anchor_v1")
func ergenticsPrimeNativeDecoderRuntimeImageAnchorV1() {}

private func requireStaticRuntimeImage(
    executableURL: URL
) throws -> URL {
    let anchor: @convention(c) () -> Void =
        ergenticsPrimeNativeDecoderRuntimeImageAnchorV1
    let address = unsafeBitCast(
        anchor,
        to: UnsafeRawPointer.self
    )
    var information = Dl_info()
    guard dladdr(address, &information) != 0,
          let imageName = information.dli_fname else {
        throw PrimeNativeDecoderRuntimeError.runtimeImageUnavailable
    }
    let imageURL = URL(
        fileURLWithPath: String(cString: imageName)
    ).resolvingSymlinksInPath().standardizedFileURL
    guard imageURL.path == executableURL.path else {
        throw PrimeNativeDecoderRuntimeError
            .runtimeImageIsNotMainExecutable
    }
    return imageURL
}

private struct PrimeRuntimeLoaderCandidate {
    let role: String
    let url: URL
}

private func loaderCandidates(
    runtimeImageDirectory: URL
) throws -> [PrimeRuntimeLoaderCandidate] {
    var result = [PrimeRuntimeLoaderCandidate]()
    var observedPaths = Set<String>()

    func append(_ role: String, _ rawURL: URL) {
        let url = rawURL.standardizedFileURL
        guard observedPaths.insert(url.path).inserted else {
            return
        }
        result.append(
            PrimeRuntimeLoaderCandidate(
                role: role,
                url: url
            )
        )
    }

    func appendSwiftPMBundle(
        role: String,
        baseURL: URL
    ) {
        let bundleURL = baseURL
            .appendingPathComponent(
                "mlx-swift_Cmlx.bundle",
                isDirectory: true
            )
        guard let bundle = Bundle(url: bundleURL),
              let resourceURL = bundle.resourceURL else {
            return
        }
        append(
            role,
            resourceURL.appendingPathComponent(
                "default.metallib",
                isDirectory: false
            )
        )
    }

    append(
        "current_binary_directory_mlx",
        runtimeImageDirectory.appendingPathComponent(
            "mlx.metallib"
        )
    )
    append(
        "current_binary_directory_resources_mlx",
        runtimeImageDirectory
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent("mlx.metallib")
    )
    appendSwiftPMBundle(
        role: "swiftpm_main_bundle_resource_url",
        baseURL: Bundle.main.bundleURL
    )
    for bundle in Bundle.allBundles {
        if let resourceURL = bundle.resourceURL {
            appendSwiftPMBundle(
                role: "swiftpm_all_bundles_resource_urls",
                baseURL: resourceURL
            )
        }
    }
    for framework in Bundle.allFrameworks
    where framework.bundleIdentifier == "mlx-swift_Cmlx" {
        if let resourceURL = framework.resourceURL {
            append(
                "swiftpm_matching_framework_resource_url",
                resourceURL.appendingPathComponent(
                    "default.metallib"
                )
            )
        }
    }
    append(
        "current_binary_directory_resources_default",
        runtimeImageDirectory
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent("default.metallib")
    )
    let workingDirectory = URL(
        fileURLWithPath:
            FileManager.default.currentDirectoryPath,
        isDirectory: true
    ).standardizedFileURL
    append(
        "current_working_directory_default",
        workingDirectory.appendingPathComponent(
            "default.metallib"
        )
    )
    return result
}

private func existingCandidates(
    in candidates: [PrimeRuntimeLoaderCandidate]
) throws -> [PrimeRuntimeLoaderCandidate] {
    try candidates.filter { candidate in
        var metadata = stat()
        if lstat(candidate.url.path, &metadata) == 0 {
            return true
        }
        if errno == ENOENT || errno == ENOTDIR {
            return false
        }
        throw PrimeNativeDecoderRuntimeError.fileSystemFailure(
            operation: "inspect MLX loader candidate \(candidate.role)",
            path: candidate.url.path,
            errno: errno
        )
    }
}

private func appendRelativePath(
    _ relativePath: String,
    to baseURL: URL
) -> URL {
    relativePath.split(separator: "/").reduce(
        baseURL.standardizedFileURL
    ) { partial, component in
        partial.appendingPathComponent(String(component))
    }.standardizedFileURL
}

private func isExactLowercaseSHA256(_ value: String) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57)
                || ($0 >= 97 && $0 <= 102)
        }
}

private final class PrimeRuntimeHeldExecutable {
    let url: URL
    let byteCount: UInt64
    let sha256: String
    let deviceID: UInt64
    let inode: UInt64

    private let descriptor: Int32
    private let initialStatus: stat
    private let data: Data

    init() throws {
        let secureData = try PrimeSecureRunningExecutableCapture.data()
        url = try Self.currentExecutableURL()
        let opened = open(
            url.path,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard opened >= 0 else {
            throw PrimeNativeDecoderRuntimeError.fileSystemFailure(
                operation: "open running executable",
                path: url.path,
                errno: errno
            )
        }
        descriptor = opened

        do {
            var status = stat()
            guard fstat(descriptor, &status) == 0,
                  Self.isExecutable(status),
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0 else {
                throw PrimeNativeDecoderRuntimeError
                    .unsafeFile(url.path)
            }
            let captured = try readExactFile(
                descriptor: descriptor,
                byteCount: UInt64(status.st_size),
                maximumByteCount:
                    PrimeSecureRunningExecutableCapture
                        .maximumByteCount,
                path: url.path
            )
            guard captured == secureData,
                  try PrimeSecureRunningExecutableCapture.data()
                    == secureData else {
                throw PrimeNativeDecoderRuntimeError
                    .unsafeFile(url.path)
            }
            initialStatus = status
            data = captured
            byteCount = UInt64(status.st_size)
            sha256 = PrimeSHA256.hexDigest(of: captured)
            deviceID = UInt64(bitPattern: Int64(status.st_dev))
            inode = UInt64(status.st_ino)
        } catch {
            _ = close(descriptor)
            throw error
        }
    }

    deinit {
        _ = close(descriptor)
    }

    func revalidate() throws {
        var held = stat()
        guard fstat(descriptor, &held) == 0,
              sameStableMetadata(initialStatus, held),
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0 else {
            throw PrimeNativeDecoderRuntimeError.unsafeFile(url.path)
        }
        let rebound = open(
            url.path,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard rebound >= 0 else {
            throw PrimeNativeDecoderRuntimeError.fileSystemFailure(
                operation: "reopen running executable",
                path: url.path,
                errno: errno
            )
        }
        defer { _ = close(rebound) }
        var reboundStatus = stat()
        guard fstat(rebound, &reboundStatus) == 0,
              sameStableMetadata(initialStatus, reboundStatus),
              try readExactFile(
                  descriptor: descriptor,
                  byteCount: byteCount,
                  maximumByteCount:
                      PrimeSecureRunningExecutableCapture
                          .maximumByteCount,
                  path: url.path
              ) == data,
              try readExactFile(
                  descriptor: rebound,
                  byteCount: byteCount,
                  maximumByteCount:
                      PrimeSecureRunningExecutableCapture
                          .maximumByteCount,
                  path: url.path
              ) == data,
              try PrimeSecureRunningExecutableCapture.data() == data else {
            throw PrimeNativeDecoderRuntimeError.unsafeFile(url.path)
        }
    }

    private static func currentExecutableURL() throws -> URL {
        var requiredSize: UInt32 = 0
        _ = _NSGetExecutablePath(nil, &requiredSize)
        guard requiredSize > 1 else {
            throw PrimeNativeDecoderRuntimeError
                .runtimeImageUnavailable
        }
        var buffer = [CChar](
            repeating: 0,
            count: Int(requiredSize)
        )
        guard _NSGetExecutablePath(
            &buffer,
            &requiredSize
        ) == 0 else {
            throw PrimeNativeDecoderRuntimeError
                .runtimeImageUnavailable
        }
        return URL(
            fileURLWithPath: String(cString: buffer)
        ).resolvingSymlinksInPath().standardizedFileURL
    }

    private static func isExecutable(_ status: stat) -> Bool {
        status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && status.st_uid == geteuid()
            && status.st_nlink == 1
            && status.st_size > 0
            && UInt64(status.st_size)
                <= PrimeSecureRunningExecutableCapture
                    .maximumByteCount
            && status.st_mode & mode_t(0o022) == 0
            && status.st_mode & mode_t(0o111) != 0
    }
}

private final class PrimeRuntimeHeldMetallib {
    let url: URL
    let byteCount: UInt64
    let sha256: String
    let deviceID: UInt64
    let inode: UInt64

    private let descriptor: Int32
    private let initialStatus: stat
    private let data: Data

    init(
        url: URL,
        expectation:
            PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
    ) throws {
        try expectation.validate()
        self.url = url.standardizedFileURL

        var pathStatus = stat()
        guard lstat(self.url.path, &pathStatus) == 0,
              Self.isAdmitted(pathStatus, expectation: expectation)
        else {
            throw PrimeNativeDecoderRuntimeError
                .unsafeFile(self.url.path)
        }
        let opened = open(
            self.url.path,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard opened >= 0 else {
            throw PrimeNativeDecoderRuntimeError.fileSystemFailure(
                operation: "open MLX metallib",
                path: self.url.path,
                errno: errno
            )
        }
        descriptor = opened

        do {
            var heldStatus = stat()
            guard fstat(descriptor, &heldStatus) == 0,
                  Self.isAdmitted(
                      heldStatus,
                      expectation: expectation
                  ),
                  sameStableMetadata(pathStatus, heldStatus),
                  fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0 else {
                throw PrimeNativeDecoderRuntimeError
                    .unsafeFile(self.url.path)
            }
            let captured = try readExactFile(
                descriptor: descriptor,
                byteCount: expectation.byteCount,
                maximumByteCount:
                    PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                        .maximumByteCount,
                path: self.url.path
            )
            let digest = PrimeSHA256.hexDigest(of: captured)
            guard digest == expectation.sha256 else {
                throw PrimeNativeDecoderRuntimeError
                    .metallibSHA256Mismatch(
                        expected: expectation.sha256,
                        actual: digest
                    )
            }
            initialStatus = heldStatus
            data = captured
            byteCount = UInt64(heldStatus.st_size)
            sha256 = digest
            deviceID = UInt64(
                bitPattern: Int64(heldStatus.st_dev)
            )
            inode = UInt64(heldStatus.st_ino)
        } catch {
            _ = close(descriptor)
            throw error
        }
    }

    deinit {
        _ = close(descriptor)
    }

    func revalidate(
        expectation:
            PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
    ) throws {
        try expectation.validate()
        var heldStatus = stat()
        guard fstat(descriptor, &heldStatus) == 0,
              Self.isAdmitted(
                  heldStatus,
                  expectation: expectation
              ),
              sameStableMetadata(initialStatus, heldStatus),
              fcntl(descriptor, F_GETFD) & FD_CLOEXEC != 0 else {
            throw PrimeNativeDecoderRuntimeError.unsafeFile(url.path)
        }
        let rebound = open(
            url.path,
            O_RDONLY | O_NOFOLLOW | O_CLOEXEC
        )
        guard rebound >= 0 else {
            throw PrimeNativeDecoderRuntimeError.fileSystemFailure(
                operation: "reopen MLX metallib",
                path: url.path,
                errno: errno
            )
        }
        defer { _ = close(rebound) }
        var reboundStatus = stat()
        let heldData = try readExactFile(
            descriptor: descriptor,
            byteCount: expectation.byteCount,
            maximumByteCount:
                PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .maximumByteCount,
            path: url.path
        )
        let reboundData = try readExactFile(
            descriptor: rebound,
            byteCount: expectation.byteCount,
            maximumByteCount:
                PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .maximumByteCount,
            path: url.path
        )
        guard fstat(rebound, &reboundStatus) == 0,
              Self.isAdmitted(
                  reboundStatus,
                  expectation: expectation
              ),
              sameStableMetadata(initialStatus, reboundStatus),
              heldData == data,
              reboundData == data,
              PrimeSHA256.hexDigest(of: heldData)
                == expectation.sha256,
              PrimeSHA256.hexDigest(of: reboundData)
                == expectation.sha256 else {
            throw PrimeNativeDecoderRuntimeError.unsafeFile(url.path)
        }
    }

    private static func isAdmitted(
        _ status: stat,
        expectation:
            PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
    ) -> Bool {
        status.st_mode & mode_t(S_IFMT) == mode_t(S_IFREG)
            && status.st_uid == geteuid()
            && status.st_nlink == 1
            && status.st_size > 0
            && UInt64(status.st_size) == expectation.byteCount
            && status.st_mode & mode_t(0o022) == 0
            && status.st_mode & mode_t(0o7000) == 0
            && status.st_mode & mode_t(0o111) == 0
            && status.st_mode & mode_t(0o400) != 0
    }
}

private func sameStableMetadata(
    _ lhs: stat,
    _ rhs: stat
) -> Bool {
    lhs.st_dev == rhs.st_dev
        && lhs.st_ino == rhs.st_ino
        && lhs.st_mode == rhs.st_mode
        && lhs.st_uid == rhs.st_uid
        && lhs.st_gid == rhs.st_gid
        && lhs.st_nlink == rhs.st_nlink
        && lhs.st_size == rhs.st_size
        && lhs.st_mtimespec.tv_sec == rhs.st_mtimespec.tv_sec
        && lhs.st_mtimespec.tv_nsec == rhs.st_mtimespec.tv_nsec
        && lhs.st_ctimespec.tv_sec == rhs.st_ctimespec.tv_sec
        && lhs.st_ctimespec.tv_nsec == rhs.st_ctimespec.tv_nsec
}

private func readExactFile(
    descriptor: Int32,
    byteCount: UInt64,
    maximumByteCount: UInt64,
    path: String
) throws -> Data {
    guard byteCount > 0,
          byteCount <= maximumByteCount,
          byteCount <= UInt64(Int.max) else {
        throw PrimeNativeDecoderRuntimeError.unsafeFile(path)
    }
    let count = Int(byteCount)
    var result = Data()
    result.reserveCapacity(count)
    var offset = 0
    var buffer = [UInt8](repeating: 0, count: 64 * 1_024)
    while offset < count {
        let requested = min(buffer.count, count - offset)
        let actual = buffer.withUnsafeMutableBytes { bytes in
            pread(
                descriptor,
                bytes.baseAddress,
                requested,
                off_t(offset)
            )
        }
        if actual < 0, errno == EINTR {
            continue
        }
        guard actual > 0 else {
            throw PrimeNativeDecoderRuntimeError.fileSystemFailure(
                operation: "read exact file",
                path: path,
                errno: errno
            )
        }
        result.append(contentsOf: buffer[0 ..< actual])
        offset += actual
    }
    var trailing: UInt8 = 0
    let trailingCount = withUnsafeMutablePointer(to: &trailing) {
        pread(descriptor, $0, 1, off_t(count))
    }
    guard trailingCount == 0 else {
        throw PrimeNativeDecoderRuntimeError.unsafeFile(path)
    }
    return result
}
