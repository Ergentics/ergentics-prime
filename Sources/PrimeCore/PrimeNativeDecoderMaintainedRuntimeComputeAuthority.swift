// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderMaintainedRuntimeComputeAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

public enum PrimeNativeDecoderMaintainedRuntimeMetallibExpectationError:
    Error,
    Equatable,
    Sendable
{
    case invalidSchemaVersion(Int)
    case invalidArtifactRelativePath(String)
    case invalidByteCount(UInt64)
    case invalidSHA256(String)
}

/// A caller-supplied expectation for one freshly built MLX Metal library.
///
/// This value is a verification input, not artifact provenance or admission.
/// A successor execution observation must bind the exact expectation, build
/// provenance, runtime image, and receipt before it can support any claim
/// about the bytes used by an execution.
public struct PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1:
    Codable,
    Equatable,
    Sendable
{
    public static let schemaVersion = 1
    public static let artifactRelativePath =
        "mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib"
    public static let maximumByteCount: UInt64 =
        64 * 1_024 * 1_024

    public let schemaVersion: Int
    public let artifactRelativePath: String
    public let byteCount: UInt64
    public let sha256: String

    public init(
        byteCount: UInt64,
        sha256: String
    ) throws {
        self.schemaVersion = Self.schemaVersion
        self.artifactRelativePath =
            Self.artifactRelativePath
        self.byteCount = byteCount
        self.sha256 = sha256
        try validate()
    }

    public func validate() throws {
        guard schemaVersion == Self.schemaVersion else {
            throw
                PrimeNativeDecoderMaintainedRuntimeMetallibExpectationError
                    .invalidSchemaVersion(schemaVersion)
        }
        guard artifactRelativePath
                == Self.artifactRelativePath else {
            throw
                PrimeNativeDecoderMaintainedRuntimeMetallibExpectationError
                    .invalidArtifactRelativePath(
                        artifactRelativePath
                    )
        }
        guard byteCount > 0,
              byteCount <= Self.maximumByteCount else {
            throw
                PrimeNativeDecoderMaintainedRuntimeMetallibExpectationError
                    .invalidByteCount(byteCount)
        }
        guard isPrimeNativeDecoderExactLowercaseSHA256(
            sha256
        ) else {
            throw
                PrimeNativeDecoderMaintainedRuntimeMetallibExpectationError
                    .invalidSHA256(sha256)
        }
    }
}

/// Exact Git identity for one source admitted by the maintained-runtime arc.
///
/// The authority source itself is intentionally excluded: embedding its own
/// digest would require an impossible fixed point. Repository gates bind that
/// file externally; this value binds every other newly authorized source.
public struct PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String

    public func validate() throws {
        let components = path.split(
            separator: "/",
            omittingEmptySubsequences: false
        )
        guard !path.isEmpty,
              !path.hasPrefix("/"),
              !path.hasSuffix("/"),
              !components.contains(where: {
                  $0.isEmpty || $0 == "." || $0 == ".."
              }),
              gitMode == "100644" || gitMode == "100755",
              isPrimeNativeDecoderExactLowercaseGitObjectID(
                  gitBlob
              ),
              byteCount > 0,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  sha256
              ) else {
            throw
                PrimeNativeDecoderMaintainedRuntimeComputeAuthorityError
                    .contractDrift
        }
    }
}

public struct
    PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let policyID: String
    public let policyVersion: Int
    public let scope: String
    public let predecessorPolicyID: String
    public let predecessorPolicyVersion: Int
    public let predecessorRemainsFrozen: Bool
    public let exactMLXRevision: String
    public let requiredEnvironmentKey: String
    public let requiredEnvironmentValue: String
    public let exclusiveEnvironmentKeyPrefix: String
    public let forbiddenEnvironmentKeyPrefixes: [String]
    public let numericMode: String
    public let comparisonPolicy: String
    public let authorityCeiling: String
}

public enum
    PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyError:
    Error,
    Equatable,
    Sendable
{
    case forbiddenInheritedKey(String)
    case forbiddenLaunchedKey(String)
    case missingRequiredKey(String)
    case invalidRequiredValue(
        key: String,
        value: String?
    )
    case unexpectedExclusivePrefixKeys([String])
}

/// Append-only compute-environment admission for the maintained native-decoder
/// runtime boundary.
///
/// The historical `PrimeMLXRuntimeEnvironmentPolicy` remains frozen and still
/// rejects every `MLX_` key for its existing runtime roles. This new policy is
/// scoped only to the additive native-decoder runtime: its supervisor starts
/// with no MLX or dynamic-loader override, then introduces exactly
/// `MLX_ENABLE_TF32=0` before the runtime process makes any CoreGraphics,
/// Metal, or MLX call.
public enum PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy {
    public static let declaration =
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1(
            schemaVersion: 1,
            policyID:
                "ergentics_prime_native_decoder_maintained_runtime_compute_environment_v1",
            policyVersion: 1,
            scope:
                "bounded_native_decoder_runtime_dependency_metallib_device_and_mlx_initialization_closure",
            predecessorPolicyID:
                PrimeMLXRuntimeEnvironmentPolicy
                    .declaration.policyID,
            predecessorPolicyVersion:
                PrimeMLXRuntimeEnvironmentPolicy
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
                "float32_inputs_and_storage_tf32_disabled",
            comparisonPolicy:
                "exact_float32_probe_values_no_tolerance_widening",
            authorityCeiling:
                "bounded_mlx_runtime_initialization_only_no_decoder_model_checkpoint_or_training"
        )

    @discardableResult
    public static func validateInherited(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        let declaration = declaration
        if let key = environment.keys.sorted().first(where: { key in
            key.hasPrefix(
                declaration.exclusiveEnvironmentKeyPrefix
            )
                || declaration.forbiddenEnvironmentKeyPrefixes
                    .contains(where: key.hasPrefix)
        }) {
            throw
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyError
                    .forbiddenInheritedKey(key)
        }
        return declaration
    }

    @discardableResult
    public static func validateLaunched(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        let declaration = declaration
        if let key = environment.keys.sorted().first(where: { key in
            declaration.forbiddenEnvironmentKeyPrefixes
                .contains(where: key.hasPrefix)
        }) {
            throw
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyError
                    .forbiddenLaunchedKey(key)
        }

        guard let value =
                environment[
                    declaration.requiredEnvironmentKey
                ] else {
            throw
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyError
                    .missingRequiredKey(
                        declaration.requiredEnvironmentKey
                    )
        }
        guard value == declaration.requiredEnvironmentValue else {
            throw
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyError
                    .invalidRequiredValue(
                        key: declaration.requiredEnvironmentKey,
                        value: value
                    )
        }
        let exclusiveKeys = environment.keys
            .filter {
                $0.hasPrefix(
                    declaration.exclusiveEnvironmentKeyPrefix
                )
            }
            .sorted()
        guard exclusiveKeys
                == [declaration.requiredEnvironmentKey] else {
            throw
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyError
                    .unexpectedExclusivePrefixKeys(
                        exclusiveKeys
                    )
        }
        return declaration
    }

    /// Validates the actual launched runtime environment. Call this before
    /// any CoreGraphics, Metal, or MLX operation in the runtime process.
    @discardableResult
    public static func validateLaunchedCurrentProcess(
        processInfo: ProcessInfo = .processInfo
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        try validateLaunched(
            environment: processInfo.environment
        )
    }
}

/// Append-only authority for a bounded maintained-runtime closure.
///
/// This authority admits one exact compute-environment policy and authorizes
/// implementation of a new runtime product plus a hosted validation lane. It
/// does not itself observe a dependency closure, Metal device, loaded Metal
/// library, or MLX execution. The runtime receives a validated caller-supplied
/// Metal-library expectation; that input is not provenance or admission and
/// must be bound by a later exact-head execution observation.
public struct PrimeNativeDecoderMaintainedRuntimeComputeAuthorityPlanV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let predecessorAuthorityID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorRequiredForConsumption: Bool
    public let predecessorSourcePath: String
    public let predecessorSourceGitMode: String
    public let predecessorSourceGitBlob: String
    public let predecessorSourceByteCount: Int
    public let predecessorSourceSHA256: String

    public let authoritativeRepository: String
    public let baseRevision: String
    public let baseOrderedParentRevisions: [String]
    public let baseTree: String
    public let baseEmbeddedSourceIdentitySHA256: String
    public let basePullRequestNumber: Int

    public let compatibilityIdentityV2SourcePath: String
    public let compatibilityIdentityV2SourceGitMode: String
    public let compatibilityIdentityV2SourceGitBlob: String
    public let compatibilityIdentityV2SourceByteCount: Int
    public let compatibilityIdentityV2SourceSHA256: String
    public let repairedDecoderSourcePath: String
    public let repairedDecoderSourceGitMode: String
    public let repairedDecoderSourceGitBlob: String
    public let repairedDecoderSourceByteCount: Int
    public let repairedDecoderSourceSHA256: String

    public let baseRootPackageManifestPath: String
    public let baseRootPackageManifestGitMode: String
    public let baseRootPackageManifestGitBlob: String
    public let baseRootPackageManifestByteCount: Int
    public let baseRootPackageManifestSHA256: String
    public let baseRootPackageResolvedPath: String
    public let baseRootPackageResolvedGitMode: String
    public let baseRootPackageResolvedGitBlob: String
    public let baseRootPackageResolvedByteCount: Int
    public let baseRootPackageResolvedSHA256: String

    public let frozenEnvironmentPolicySourcePath: String
    public let frozenEnvironmentPolicySourceSHA256: String
    public let frozenRuntimeImageLayoutSourcePath: String
    public let frozenRuntimeImageLayoutSourceSHA256: String
    public let frozenPinnedMetallibSourcePath: String
    public let frozenPinnedMetallibSourceSHA256: String
    public let frozenMetalDeviceLeaseSourcePath: String
    public let frozenMetalDeviceLeaseSourceSHA256: String
    public let frozenReleaseInstrumentationPolicySourcePath: String
    public let frozenReleaseInstrumentationPolicySourceSHA256: String
    public let frozenMetalLauncherPath: String
    public let frozenMetalLauncherSHA256: String
    public let frozenEnvironmentPolicy:
        PrimeMLXRuntimeEnvironmentPolicyDeclaration
    public let maintainedComputeEnvironmentPolicy:
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1

    public let exactMLXRepository: String
    public let exactMLXRevision: String
    public let exactMLXCoreRevision: String
    public let exactMLXCRevision: String
    public let exactSwiftNumericsRevision: String
    public let mlxPackageSourcePath: String
    public let mlxPackageSourceGitMode: String
    public let mlxPackageSourceGitBlob: String
    public let mlxPackageSourceByteCount: Int
    public let mlxPackageSourceSHA256: String
    public let mlxMetalLoaderSourcePath: String
    public let mlxMetalLoaderSourceGitMode: String
    public let mlxMetalLoaderSourceGitBlob: String
    public let mlxMetalLoaderSourceByteCount: Int
    public let mlxMetalLoaderSourceSHA256: String
    public let mlxMetalLoaderHeaderPath: String
    public let mlxMetalLoaderHeaderGitMode: String
    public let mlxMetalLoaderHeaderGitBlob: String
    public let mlxMetalLoaderHeaderByteCount: Int
    public let mlxMetalLoaderHeaderSHA256: String
    public let mlxBinaryDirectorySourcePath: String
    public let mlxBinaryDirectorySourceGitBlob: String
    public let mlxBinaryDirectorySourceByteCount: Int
    public let mlxBinaryDirectorySourceSHA256: String
    public let mlxTF32EnvironmentSourcePath: String
    public let mlxTF32EnvironmentSourceGitBlob: String
    public let mlxTF32EnvironmentSourceByteCount: Int
    public let mlxTF32EnvironmentSourceSHA256: String
    public let mlxMatmulSourcePath: String
    public let mlxMatmulSourceGitBlob: String
    public let mlxMatmulSourceByteCount: Int
    public let mlxMatmulSourceSHA256: String
    public let mlxDeviceAPISourcePath: String
    public let mlxDeviceAPISourceGitBlob: String
    public let mlxDeviceAPISourceByteCount: Int
    public let mlxDeviceAPISourceSHA256: String
    public let mlxCheckedEvalSourcePath: String
    public let mlxCheckedEvalSourceGitBlob: String
    public let mlxCheckedEvalSourceByteCount: Int
    public let mlxCheckedEvalSourceSHA256: String
    public let mlxMetalAPISourcePath: String
    public let mlxMetalAPISourceGitBlob: String
    public let mlxMetalAPISourceByteCount: Int
    public let mlxMetalAPISourceSHA256: String
    public let mlxSwiftPMBundleCompileDefinition: String
    public let mlxDefaultMetallibCompileDefinition: String
    public let exactLoaderCandidateOrder: [String]
    public let loaderIdentityClaimKind: String

    public let metallibExpectationSchemaVersion: Int
    public let metallibArtifactRelativePath: String
    public let maximumMetallibByteCount: UInt64
    public let metallibExpectationProvidedByCaller: Bool
    public let callerExpectationIsArtifactAdmission: Bool
    public let successorObservationMustBindExpectation: Bool
    public let everyExistingLoaderCandidateMustMatchExpectation: Bool
    public let allNonadmittedLoaderCandidatesMustBeAbsent: Bool
    public let preAndPostExecutionMetallibBindingRequired: Bool
    public let independentLoaderInstrumentationRequired: Bool

    public let runtimeProduct: String
    public let runtimeTarget: String
    public let runtimeTargetDependencies: [String]
    public let runtimeSourcePath: String
    public let publicRuntimePlanType: String
    public let publicRuntimePlanFactoryDeclaration: String
    public let publicRuntimePlanValidatorDeclaration: String
    public let publicRuntimeInitializationDeclaration: String
    public let runtimeImageLayoutID: String
    public let stagedRuntimeExecutableName: String
    public let runtimeValidationPackagePath: String
    public let runtimeValidationProbeTarget: String
    public let runtimeValidationTestTarget: String
    public let runtimeClosureLauncherPath: String
    public let trustedWorkflowPath: String
    public let trustedWorkflowBaseGitBlob: String
    public let trustedWorkflowBaseByteCount: Int
    public let trustedWorkflowBaseSHA256: String
    public let trustedWorkflowTopology: String
    public let newSourcePinsFinalized: Bool
    public let successorRootPackageManifestSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let successorRootPackageResolvedSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let runtimeSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let runtimeValidationPackageManifestSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let runtimeValidationPackageResolvedSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let runtimeValidationProbeSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let runtimeValidationTestSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1
    public let runtimeClosureLauncherSource:
        PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1

    public let inheritedEnvironmentValidationStage: String
    public let launchedEnvironmentValidationStage: String
    public let launchedEnvironmentRetainedUntilProcessExitRequired: Bool
    public let releaseInstrumentationValidationRequired: Bool
    public let v2IdentityValidationIsDeclarativeOnly: Bool
    public let metalLeaseAcquiredBeforeFirstDeviceAccess: Bool
    public let coreGraphicsBootstrapRequired: Bool
    public let metalDeviceEnumerationAPI: String
    public let metalDefaultDeviceAPI: String
    public let requiredMetalDeviceCount: Int
    public let requiredMLXGPUIndex: Int
    public let metalDefaultDeviceMustMatchIndexZero: Bool
    public let mlxDeviceIdentityClaimKind: String
    public let physicalGPUIdentityRequired: Bool
    public let initializationProbeOperation: String
    public let initializationProbeDType: String
    public let initializationProbeShape: [Int]
    public let initializationProbeLeftFloat32BitPatterns: [UInt32]
    public let initializationProbeRightFloat32BitPatterns: [UInt32]
    public let initializationProbeExpectedFloat32BitPatterns: [UInt32]
    public let initializationProbeEvaluationAPI: String
    public let initializationProbeReadbackAPI: String

    public let admittedRuntimeComputePolicyEstablished: Bool
    public let runtimeDependencyClosureAuthorized: Bool
    public let sourcePinnedMetallibVerificationAuthorized: Bool
    public let runtimeMetalDeviceClosureAuthorized: Bool
    public let boundedMLXRuntimeInitializationAuthorized: Bool
    public let declarativeV2IdentityValidationAuthorized: Bool
    public let tinyExplicitGPUAllocationAuthorized: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeLoadedMetallibIdentityEstablished: Bool
    public let sourcePinnedExclusiveCandidateInferenceEstablished: Bool
    public let loadedMetallibIdentityIndependentlyObserved: Bool
    public let runtimeMetalDeviceIdentityEstablished: Bool
    public let boundedMLXRuntimeInitializationEstablished: Bool
    public let tf32StaticValueDirectlyObserved: Bool
    public let tf32DifferentialObserved: Bool
    public let naxTF32ConsumerPathObserved: Bool
    public let decoderModelInitializationEstablished: Bool
    public let decoderForwardObserved: Bool

    public let runtimeProductAndTargetAdditionAuthorized: Bool
    public let rootPackageManifestMutationAuthorized: Bool
    public let rootPackageResolvedMutationAuthorized: Bool
    public let runtimeSourceAdditionAuthorized: Bool
    public let runtimeValidationPackageAdditionAuthorized: Bool
    public let runtimeClosureLauncherAdditionAuthorized: Bool
    public let trustedWorkflowCommandExtensionAuthorized: Bool
    public let workflowTopologyMutationAuthorized: Bool
    public let sourceGatePinExtensionAuthorized: Bool
    public let embeddedBuildProvenanceUpdateAuthorized: Bool
    public let documentationUpdateAuthorized: Bool

    public let checkpointV1SourceMutationAuthorized: Bool
    public let checkpointV2SourceMutationAuthorized: Bool
    public let repairedDecoderMutationAuthorized: Bool
    public let frozenObservationMutationAuthorized: Bool
    public let frozenMetalLauncherMutationAuthorized: Bool
    public let existingIsolatedDecoderValidationMutationAuthorized: Bool
    public let existing44TestInventoryMutationAuthorized: Bool
    public let driverV2MutationAuthorized: Bool
    public let pmhnpMutationAuthorized: Bool
    public let geometryDependencyAuthorized: Bool
    public let newExternalDependencyAuthorized: Bool

    public let v2ManifestDefined: Bool
    public let v2CodecDefined: Bool
    public let checkpointContainerIOImplemented: Bool
    public let checkpointArtifactAvailable: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let native300MModelAllocationAuthorized: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let tokenizerFunctionalCompatibilityEstablished: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let trainingResumeEstablished: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let optimizerStepObserved: Bool
    public let trainingExecutionObserved: Bool
    public let modelQualityEstablished: Bool
    public let functionalTrainingAuthorized: Bool
    public let longTrainingAuthorized: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "ergentics_prime_native_decoder_maintained_runtime_compute_v1",
        predecessorAuthorityID:
            PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan
                .frozenV2.authorityID,
        predecessorRemainsFrozen: true,
        predecessorRequiredForConsumption: true,
        predecessorSourcePath:
            "Sources/PrimeCore/PrimeNativeDecoderCheckpointCompatibilityV2Authority.swift",
        predecessorSourceGitMode: "100644",
        predecessorSourceGitBlob:
            "b09e51e6cd79b3962fec4ddb28c1a154ef979076",
        predecessorSourceByteCount: 29_660,
        predecessorSourceSHA256:
            "ea5048b74b37cb8df9978f10c632c9fdbef47655b414518ce926b9d73ada8bdd",

        authoritativeRepository: "Ergentics/ergentics-prime",
        baseRevision:
            "933347eca2f3a744efc8f6bc434fea87725d81e5",
        baseOrderedParentRevisions: [
            "3da134d323301c1a65867b81a7ca6c61625676ee",
            "36b3b415f3f16c5ec3fb3e5aa7ff08be14b49786",
        ],
        baseTree:
            "6a57a27915137acbb3b4fc2191f684d46cd0be98",
        baseEmbeddedSourceIdentitySHA256:
            "0a82ae521865af64c29b9011d30f79a45fdaba25743516382a0c4fe0219d6da7",
        basePullRequestNumber: 71,

        compatibilityIdentityV2SourcePath:
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift",
        compatibilityIdentityV2SourceGitMode: "100644",
        compatibilityIdentityV2SourceGitBlob:
            "7e993df79cc3a7c37d130c9eb5e7f30f63a6c386",
        compatibilityIdentityV2SourceByteCount: 9_228,
        compatibilityIdentityV2SourceSHA256:
            "2b73886d067015ea65a71944bdc9d0f06025ee65858e9cfccf9a8f0936cf36f3",
        repairedDecoderSourcePath:
            "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
        repairedDecoderSourceGitMode: "100644",
        repairedDecoderSourceGitBlob:
            "835a4826549e1f28ec27e3533f746218beb3bdf2",
        repairedDecoderSourceByteCount: 39_050,
        repairedDecoderSourceSHA256:
            "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",

        baseRootPackageManifestPath: "Package.swift",
        baseRootPackageManifestGitMode: "100644",
        baseRootPackageManifestGitBlob:
            "4ae0e9f69f7bac68f992b7f16a7de41aa1d8e9ec",
        baseRootPackageManifestByteCount: 31_456,
        baseRootPackageManifestSHA256:
            "8fe0eb8f7521e2defc2d5ecb829907b1d65188ac9cc339d890261f6c23e41576",
        baseRootPackageResolvedPath: "Package.resolved",
        baseRootPackageResolvedGitMode: "100644",
        baseRootPackageResolvedGitBlob:
            "75fa628afdf1dc26072ed2ed95906ec200daf415",
        baseRootPackageResolvedByteCount: 645,
        baseRootPackageResolvedSHA256:
            "2ff02db34ba5804bfaede917af10c85869bb98d594d29ad2cffcb0b68394d848",

        frozenEnvironmentPolicySourcePath:
            "Sources/PrimeCore/PrimeMLXRuntimeEnvironmentPolicy.swift",
        frozenEnvironmentPolicySourceSHA256:
            "20fee288a85722d61eae63f10d38dbae226312ee31774b03712ff6cf1759b0f0",
        frozenRuntimeImageLayoutSourcePath:
            "Sources/PrimeCore/PrimeMLXRuntimeImageLayout.swift",
        frozenRuntimeImageLayoutSourceSHA256:
            "59ef17e619ef60d9445db624058ba9ebf133189461344e72d4b05c485ad1f623",
        frozenPinnedMetallibSourcePath:
            "Sources/PrimeCore/PrimePinnedMLXMetallib.swift",
        frozenPinnedMetallibSourceSHA256:
            "a5f875c089613f82e2bc1044f35fa1a2bfe13d3498685db4c9f9e5fc1ec51d78",
        frozenMetalDeviceLeaseSourcePath:
            "Sources/PrimeCore/PrimeMetalDeviceLease.swift",
        frozenMetalDeviceLeaseSourceSHA256:
            "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657",
        frozenReleaseInstrumentationPolicySourcePath:
            "Sources/PrimeCore/PrimeReleaseInstrumentationAdmissionPolicy.swift",
        frozenReleaseInstrumentationPolicySourceSHA256:
            "397d4ac8204c29ec84fdc1e88fa44ee9fef22a95261f76084ab132d42dcd95e6",
        frozenMetalLauncherPath:
            ".github/scripts/prime-ci-native-decoder-metal.sh",
        frozenMetalLauncherSHA256:
            "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff",
        frozenEnvironmentPolicy:
            PrimeMLXRuntimeEnvironmentPolicy.declaration,
        maintainedComputeEnvironmentPolicy:
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .declaration,

        exactMLXRepository: "Ergentics/ergentics-mlx-swift",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        exactMLXCoreRevision:
            "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
        exactMLXCRevision:
            "0726ca922fc902c4c61ef9c27d94132be418e945",
        exactSwiftNumericsRevision:
            "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
        mlxPackageSourcePath: "Package.swift",
        mlxPackageSourceGitMode: "100644",
        mlxPackageSourceGitBlob:
            "b1f1e5526455f74fc098c7fe5ed0607494a37b2a",
        mlxPackageSourceByteCount: 11_407,
        mlxPackageSourceSHA256:
            "f1f0aae93913b631487febff7c651abf4c04f0157cda48f6c233e0173ca09e88",
        mlxMetalLoaderSourcePath:
            "Source/Cmlx/mlx/mlx/backend/metal/device.cpp",
        mlxMetalLoaderSourceGitMode: "100644",
        mlxMetalLoaderSourceGitBlob:
            "15824d6c5c8938ab11582f239e6a9598af87c241",
        mlxMetalLoaderSourceByteCount: 24_956,
        mlxMetalLoaderSourceSHA256:
            "d2000ba53a5f4137c91f0a6222ae86cc3c2c0c3d69dfda2f421f60bd55813a98",
        mlxMetalLoaderHeaderPath:
            "Source/Cmlx/mlx/mlx/backend/metal/device.h",
        mlxMetalLoaderHeaderGitMode: "100644",
        mlxMetalLoaderHeaderGitBlob:
            "e6162d7da665d29bb6edcc7ddbb8d18190f5caa2",
        mlxMetalLoaderHeaderByteCount: 8_253,
        mlxMetalLoaderHeaderSHA256:
            "9de843b614a75a3fdeaa5964f9ccf5d15db3d76148181102afb28ec83240d4f5",
        mlxBinaryDirectorySourcePath:
            "Source/Cmlx/mlx/mlx/backend/common/utils.cpp",
        mlxBinaryDirectorySourceGitBlob:
            "ae169e35e2c88555d2d1e101697654e47e3fcf3e",
        mlxBinaryDirectorySourceByteCount: 6_047,
        mlxBinaryDirectorySourceSHA256:
            "f831b4e6576cb76519fddcbab2e424dc53e8f75811cce448f4a877ec1885331e",
        mlxTF32EnvironmentSourcePath:
            "Source/Cmlx/mlx/mlx/utils.h",
        mlxTF32EnvironmentSourceGitBlob:
            "62aa82b65867252df202c3c172e8fa7ca08c95b2",
        mlxTF32EnvironmentSourceByteCount: 5_080,
        mlxTF32EnvironmentSourceSHA256:
            "352624041e0eeb02ddff4f4038cf631a96c6bf92a7ac627b1655b17c61cf8ff8",
        mlxMatmulSourcePath:
            "Source/Cmlx/mlx/mlx/backend/metal/matmul.cpp",
        mlxMatmulSourceGitBlob:
            "84b6ee06da379ceb73b9c3b555adbda6af0c6322",
        mlxMatmulSourceByteCount: 84_257,
        mlxMatmulSourceSHA256:
            "4bef524645dce8feb94300766dec1586caf93c0167fe9757409fb452c15b1361",
        mlxDeviceAPISourcePath: "Source/MLX/Device.swift",
        mlxDeviceAPISourceGitBlob:
            "3a262c55306dab81abecfc36143eda73a0fc4c29",
        mlxDeviceAPISourceByteCount: 5_524,
        mlxDeviceAPISourceSHA256:
            "c357704669f8094bad35f1ea70920f9ce9a058256f776f593dbd81b1bb3e41ce",
        mlxCheckedEvalSourcePath:
            "Source/MLX/Transforms+Eval.swift",
        mlxCheckedEvalSourceGitBlob:
            "46fe9c593099c0b939d1d85a68f37023a6dacc24",
        mlxCheckedEvalSourceByteCount: 5_256,
        mlxCheckedEvalSourceSHA256:
            "14b867c903be78547b426305257ca70e214b7b854acf1c0dc2cf7c82333f4999",
        mlxMetalAPISourcePath: "Source/MLX/GPU+Metal.swift",
        mlxMetalAPISourceGitBlob:
            "c4644081760dc49031e90575674e038109b6ef64",
        mlxMetalAPISourceByteCount: 9_415,
        mlxMetalAPISourceSHA256:
            "ae42da993822c68d3b7d3dbd79813283795bf89321de870190d39488d6ba6a12",
        mlxSwiftPMBundleCompileDefinition:
            "SWIFTPM_BUNDLE=mlx-swift_Cmlx",
        mlxDefaultMetallibCompileDefinition:
            "METAL_PATH=default.metallib",
        exactLoaderCandidateOrder: [
            "current_binary_directory/mlx.metallib",
            "current_binary_directory/Resources/mlx.metallib",
            "swiftpm_main_bundle_resource_url/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
            "swiftpm_all_bundles_resource_urls/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib",
            "swiftpm_matching_framework_resource_url/default.metallib",
            "current_binary_directory/Resources/default.metallib",
            "current_working_directory/default.metallib",
        ],
        loaderIdentityClaimKind:
            "source_pinned_exhaustive_loader_precedence_and_exclusive_candidate_inference_not_independent_instrumentation",

        metallibExpectationSchemaVersion:
            PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                .schemaVersion,
        metallibArtifactRelativePath:
            PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                .artifactRelativePath,
        maximumMetallibByteCount:
            PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                .maximumByteCount,
        metallibExpectationProvidedByCaller: true,
        callerExpectationIsArtifactAdmission: false,
        successorObservationMustBindExpectation: true,
        everyExistingLoaderCandidateMustMatchExpectation: true,
        allNonadmittedLoaderCandidatesMustBeAbsent: true,
        preAndPostExecutionMetallibBindingRequired: true,
        independentLoaderInstrumentationRequired: false,

        runtimeProduct: "PrimeNativeDecoderRuntime",
        runtimeTarget: "PrimeNativeDecoderRuntime",
        runtimeTargetDependencies: [
            "PrimeCore",
            "PrimeNativeDecoder",
            "PrimeNativeDecoderCheckpoint",
            "MLX",
        ],
        runtimeSourcePath:
            "Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift",
        publicRuntimePlanType:
            "PrimeNativeDecoderMaintainedRuntimePlanV1",
        publicRuntimePlanFactoryDeclaration:
            "public static func native300MByte512() throws -> Self",
        publicRuntimePlanValidatorDeclaration:
            "public func validate() throws",
        publicRuntimeInitializationDeclaration:
            "public static func initializeCurrentProcess(metallibExpectation: PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1, metalLeaseURL: URL) throws -> PrimeNativeDecoderMaintainedRuntimeInitializationEvidenceV1",
        runtimeImageLayoutID:
            "ergentics_prime_native_decoder_runtime_exclusive_swiftpm_mlx_bundle_v1",
        stagedRuntimeExecutableName:
            "PrimeNativeDecoderRuntimeClosureProbe",
        runtimeValidationPackagePath:
            "Tests/PrimeNativeDecoderRuntimeClosureValidation",
        runtimeValidationProbeTarget:
            "PrimeNativeDecoderRuntimeClosureProbe",
        runtimeValidationTestTarget:
            "PrimeNativeDecoderRuntimeClosureAuthorityTests",
        runtimeClosureLauncherPath:
            ".github/scripts/prime-ci-native-decoder-runtime-closure.sh",
        trustedWorkflowPath:
            ".github/workflows/prime-active-root-quarantine.yml",
        trustedWorkflowBaseGitBlob:
            "7a9ca4e4dc45e54ce029b811a245fee37a2dbe15",
        trustedWorkflowBaseByteCount: 21_054,
        trustedWorkflowBaseSHA256:
            "69059eedfb0a94c861984fe2e47da459f0d9220b857e2e9bac302f259691ab50",
        trustedWorkflowTopology:
            "existing_reviewed_main_job_existing_live_metal_step_append_runtime_closure_launcher_after_frozen_44_launcher",
        newSourcePinsFinalized: true,
        successorRootPackageManifestSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path: "Package.swift",
                gitMode: "100644",
                gitBlob:
                    "f201abbf928e5e3d6b0c7785110539cdaeee911b",
                byteCount: 32_082,
                sha256:
                    "db81e337640b8eb923dbc90b9e22ce898c371ccffe08eed08050e45c34551400"
            ),
        successorRootPackageResolvedSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path: "Package.resolved",
                gitMode: "100644",
                gitBlob:
                    "dcd0192f705c22378f2d9e871a240c0493ad8a80",
                byteCount: 645,
                sha256:
                    "a18ded75fe953803945898aba0b04a9cec4fca674f38bf914e5fa45dfdb70741"
            ),
        runtimeSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path:
                    "Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift",
                gitMode: "100644",
                gitBlob:
                    "dd3ca76ba7799c6deb0012276967c07bee3644d0",
                byteCount: 55_550,
                sha256:
                    "71d312d03f81509ece6234067a8b5f43c410ca2941da658134921141037fa981"
            ),
        runtimeValidationPackageManifestSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path:
                    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.swift",
                gitMode: "100644",
                gitBlob:
                    "ed63a3edf5def776cdb531166090a69afdf0e425",
                byteCount: 1_368,
                sha256:
                    "57239460a6e2dc6884ba1a034b04084dbc52477c78c11078824b006ce0abe058"
            ),
        runtimeValidationPackageResolvedSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path:
                    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Package.resolved",
                gitMode: "100644",
                gitBlob:
                    "9128fe027a155fe6ea3c56667cf57989bc05128d",
                byteCount: 645,
                sha256:
                    "fabc36489bd4b7af41d0a9994286e7a7458f46fedd25c545fd0ab190274f33e5"
            ),
        runtimeValidationProbeSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path:
                    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Sources/PrimeNativeDecoderRuntimeClosureProbe/main.swift",
                gitMode: "100644",
                gitBlob:
                    "63679a06c900b803b23778b011980636a3b302f1",
                byteCount: 3_133,
                sha256:
                    "59419ec899b4ed12b8c40156c27c5f870efe78dcb93a45b0ec93ccf7ab26196c"
            ),
        runtimeValidationTestSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path:
                    "Tests/PrimeNativeDecoderRuntimeClosureValidation/Tests/PrimeNativeDecoderRuntimeClosureAuthorityTests/PrimeNativeDecoderRuntimeClosureAuthorityTests.swift",
                gitMode: "100644",
                gitBlob:
                    "f159267dfa77a643337ba9cd7f60d733d4d84033",
                byteCount: 15_364,
                sha256:
                    "cf80369f52e83ab4b1be453a3ca1fec4eea14013ca3843d67c17de29f36c69f5"
            ),
        runtimeClosureLauncherSource:
            PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1(
                path:
                    ".github/scripts/prime-ci-native-decoder-runtime-closure.sh",
                gitMode: "100755",
                gitBlob:
                    "f1c3041d7e47fa315f60c889a736a412640e8710",
                byteCount: 26_614,
                sha256:
                    "aac5421ec7b1465bb746079bf5ea2634e20b9456099b33ce0271228638342cc5"
            ),

        inheritedEnvironmentValidationStage:
            "supervisor_before_export_and_before_any_coregraphics_metal_or_mlx_call",
        launchedEnvironmentValidationStage:
            "runtime_in_process_before_any_coregraphics_metal_or_mlx_call",
        launchedEnvironmentRetainedUntilProcessExitRequired: true,
        releaseInstrumentationValidationRequired: true,
        v2IdentityValidationIsDeclarativeOnly: true,
        metalLeaseAcquiredBeforeFirstDeviceAccess: true,
        coreGraphicsBootstrapRequired: true,
        metalDeviceEnumerationAPI: "MTLCopyAllDevices",
        metalDefaultDeviceAPI: "MTLCreateSystemDefaultDevice",
        requiredMetalDeviceCount: 1,
        requiredMLXGPUIndex: 0,
        metalDefaultDeviceMustMatchIndexZero: true,
        mlxDeviceIdentityClaimKind:
            "source_pinned_index_zero_inference_from_singleton_metal_device_set",
        physicalGPUIdentityRequired: false,
        initializationProbeOperation:
            "mlx_gpu_index_zero_float32_2x2_matmul_checked_eval",
        initializationProbeDType: "float32",
        initializationProbeShape: [2, 2],
        initializationProbeLeftFloat32BitPatterns: [
            Float(-0.8).bitPattern,
            Float(0.2).bitPattern,
            Float(0.3).bitPattern,
            Float(-0.4).bitPattern,
        ],
        initializationProbeRightFloat32BitPatterns: [
            Float(1).bitPattern,
            Float(0).bitPattern,
            Float(0).bitPattern,
            Float(1).bitPattern,
        ],
        initializationProbeExpectedFloat32BitPatterns: [
            Float(-0.8).bitPattern,
            Float(0.2).bitPattern,
            Float(0.3).bitPattern,
            Float(-0.4).bitPattern,
        ],
        initializationProbeEvaluationAPI:
            "MLX.matmul+MLX.withError+MLX.checkedEval",
        initializationProbeReadbackAPI:
            "MLX.MLXArray.asArray(Float.self)",

        admittedRuntimeComputePolicyEstablished: true,
        runtimeDependencyClosureAuthorized: true,
        sourcePinnedMetallibVerificationAuthorized: true,
        runtimeMetalDeviceClosureAuthorized: true,
        boundedMLXRuntimeInitializationAuthorized: true,
        declarativeV2IdentityValidationAuthorized: true,
        tinyExplicitGPUAllocationAuthorized: true,
        runtimeDependencyClosureEstablished: false,
        runtimeLoadedMetallibIdentityEstablished: false,
        sourcePinnedExclusiveCandidateInferenceEstablished: false,
        loadedMetallibIdentityIndependentlyObserved: false,
        runtimeMetalDeviceIdentityEstablished: false,
        boundedMLXRuntimeInitializationEstablished: false,
        tf32StaticValueDirectlyObserved: false,
        tf32DifferentialObserved: false,
        naxTF32ConsumerPathObserved: false,
        decoderModelInitializationEstablished: false,
        decoderForwardObserved: false,

        runtimeProductAndTargetAdditionAuthorized: true,
        rootPackageManifestMutationAuthorized: true,
        rootPackageResolvedMutationAuthorized: true,
        runtimeSourceAdditionAuthorized: true,
        runtimeValidationPackageAdditionAuthorized: true,
        runtimeClosureLauncherAdditionAuthorized: true,
        trustedWorkflowCommandExtensionAuthorized: true,
        workflowTopologyMutationAuthorized: false,
        sourceGatePinExtensionAuthorized: true,
        embeddedBuildProvenanceUpdateAuthorized: true,
        documentationUpdateAuthorized: true,

        checkpointV1SourceMutationAuthorized: false,
        checkpointV2SourceMutationAuthorized: false,
        repairedDecoderMutationAuthorized: false,
        frozenObservationMutationAuthorized: false,
        frozenMetalLauncherMutationAuthorized: false,
        existingIsolatedDecoderValidationMutationAuthorized: false,
        existing44TestInventoryMutationAuthorized: false,
        driverV2MutationAuthorized: false,
        pmhnpMutationAuthorized: false,
        geometryDependencyAuthorized: false,
        newExternalDependencyAuthorized: false,

        v2ManifestDefined: false,
        v2CodecDefined: false,
        checkpointContainerIOImplemented: false,
        checkpointArtifactAvailable: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointAdmissionGranted: false,
        native300MModelAllocationAuthorized: false,
        native300MCheckpointWriteAuthorized: false,
        native300MCheckpointLoadAuthorized: false,
        tokenizerFunctionalCompatibilityEstablished: false,
        optimizerStateIncluded: false,
        rngStateIncluded: false,
        dataCursorIncluded: false,
        trainingResumeEstablished: false,
        trainEvaluateSurfaceEstablished: false,
        optimizerStepObserved: false,
        trainingExecutionObserved: false,
        modelQualityEstablished: false,
        functionalTrainingAuthorized: false,
        longTrainingAuthorized: false,
        candidateAdmissionGranted: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        status:
            "ABSTAIN_exact_source_bound_maintained_runtime_compute_policy_and_bounded_closure_implementation_no_execution_checkpoint_or_training",
        orderedNextActions: [
            "run_exact_clean_hosted_main_runtime_closure_and_append_execution_observation",
            "establish_tokenizer_model_functional_compatibility",
            "define_bounded_v2_checkpoint_manifest_codec_and_io_under_separate_authority",
            "define_generic_train_and_evaluate_surfaces",
            "establish_exact_optimizer_rng_and_data_cursor_resume",
            "request_separate_bounded_training_authorization",
        ]
    )

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let predecessor =
            PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan
                .frozenV2

        do {
            try predecessor.validateExactV2()
            _ = try
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateInherited(environment: [:])
            _ = try
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateLaunched(
                    environment: [
                        "MLX_ENABLE_TF32": "0",
                    ]
                )
            for source in [
                successorRootPackageManifestSource,
                successorRootPackageResolvedSource,
                runtimeSource,
                runtimeValidationPackageManifestSource,
                runtimeValidationPackageResolvedSource,
                runtimeValidationProbeSource,
                runtimeValidationTestSource,
                runtimeClosureLauncherSource,
            ] {
                try source.validate()
            }
        } catch {
            throw
                PrimeNativeDecoderMaintainedRuntimeComputeAuthorityError
                    .contractDrift
        }

        guard self == expected,
              schemaVersion == 1,
              predecessorAuthorityID == predecessor.authorityID,
              predecessorRemainsFrozen,
              predecessorRequiredForConsumption,
              predecessorSourceGitMode == "100644",
              predecessorSourceGitBlob.utf8.count == 40,
              predecessorSourceByteCount == 29_660,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  predecessorSourceSHA256
              ),
              authoritativeRepository
                == "Ergentics/ergentics-prime",
              baseRevision.utf8.count == 40,
              baseOrderedParentRevisions.count == 2,
              baseOrderedParentRevisions.allSatisfy({
                  $0.utf8.count == 40
              }),
              baseTree.utf8.count == 40,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  baseEmbeddedSourceIdentitySHA256
              ),
              basePullRequestNumber == 71,
              compatibilityIdentityV2SourceGitMode == "100644",
              compatibilityIdentityV2SourceGitBlob.utf8.count == 40,
              compatibilityIdentityV2SourceByteCount > 0,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  compatibilityIdentityV2SourceSHA256
              ),
              repairedDecoderSourceGitMode == "100644",
              repairedDecoderSourceGitBlob
                == predecessor.repairedDecoderSourceGitBlob,
              repairedDecoderSourceByteCount
                == predecessor.repairedDecoderSourceByteCount,
              repairedDecoderSourceSHA256
                == predecessor.repairedDecoderSourceSHA256,
              baseRootPackageManifestGitMode == "100644",
              baseRootPackageManifestGitBlob.utf8.count == 40,
              baseRootPackageManifestByteCount > 0,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  baseRootPackageManifestSHA256
              ),
              baseRootPackageResolvedGitMode == "100644",
              baseRootPackageResolvedGitBlob.utf8.count == 40,
              baseRootPackageResolvedByteCount > 0,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  baseRootPackageResolvedSHA256
              ),
              frozenEnvironmentPolicy
                == PrimeMLXRuntimeEnvironmentPolicy.declaration,
              maintainedComputeEnvironmentPolicy
                == PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                    .declaration,
              maintainedComputeEnvironmentPolicy
                .predecessorPolicyID
                == frozenEnvironmentPolicy.policyID,
              maintainedComputeEnvironmentPolicy
                .predecessorPolicyVersion
                == frozenEnvironmentPolicy.policyVersion,
              maintainedComputeEnvironmentPolicy
                .predecessorRemainsFrozen,
              exactMLXRevision
                == maintainedComputeEnvironmentPolicy
                    .exactMLXRevision,
              exactMLXRevision
                == predecessor.exactMLXRevision,
              [
                  exactMLXRevision,
                  exactMLXCoreRevision,
                  exactMLXCRevision,
                  exactSwiftNumericsRevision,
              ].allSatisfy({ $0.utf8.count == 40 }),
              mlxPackageSourceGitMode == "100644",
              mlxPackageSourceGitBlob.utf8.count == 40,
              mlxPackageSourceByteCount > 0,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  mlxPackageSourceSHA256
              ),
              mlxMetalLoaderSourceGitMode == "100644",
              mlxMetalLoaderSourceGitBlob.utf8.count == 40,
              mlxMetalLoaderSourceByteCount > 0,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  mlxMetalLoaderSourceSHA256
              ),
              mlxMetalLoaderHeaderGitMode == "100644",
              mlxMetalLoaderHeaderGitBlob.utf8.count == 40,
              mlxMetalLoaderHeaderByteCount > 0,
              isPrimeNativeDecoderExactLowercaseSHA256(
                  mlxMetalLoaderHeaderSHA256
              ),
              [
                  mlxDeviceAPISourceGitBlob,
                  mlxCheckedEvalSourceGitBlob,
                  mlxMetalAPISourceGitBlob,
                  mlxBinaryDirectorySourceGitBlob,
                  mlxTF32EnvironmentSourceGitBlob,
                  mlxMatmulSourceGitBlob,
              ].allSatisfy({ $0.utf8.count == 40 }),
              [
                  mlxDeviceAPISourceSHA256,
                  mlxCheckedEvalSourceSHA256,
                  mlxMetalAPISourceSHA256,
                  mlxBinaryDirectorySourceSHA256,
                  mlxTF32EnvironmentSourceSHA256,
                  mlxMatmulSourceSHA256,
              ].allSatisfy(
                  isPrimeNativeDecoderExactLowercaseSHA256
              ),
              mlxDeviceAPISourceByteCount > 0,
              mlxCheckedEvalSourceByteCount > 0,
              mlxMetalAPISourceByteCount > 0,
              mlxBinaryDirectorySourceByteCount == 6_047,
              mlxTF32EnvironmentSourceByteCount == 5_080,
              mlxMatmulSourceByteCount == 84_257,
              exactLoaderCandidateOrder.count == 7,
              Set(exactLoaderCandidateOrder).count
                == exactLoaderCandidateOrder.count,
              loaderIdentityClaimKind.contains("inference"),
              loaderIdentityClaimKind.contains(
                  "not_independent_instrumentation"
              ),
              metallibExpectationSchemaVersion
                == PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .schemaVersion,
              metallibArtifactRelativePath
                == PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .artifactRelativePath,
              maximumMetallibByteCount
                == PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .maximumByteCount,
              metallibExpectationProvidedByCaller,
              !callerExpectationIsArtifactAdmission,
              successorObservationMustBindExpectation,
              everyExistingLoaderCandidateMustMatchExpectation,
              allNonadmittedLoaderCandidatesMustBeAbsent,
              preAndPostExecutionMetallibBindingRequired,
              !independentLoaderInstrumentationRequired,
              runtimeProduct == runtimeTarget,
              runtimeTargetDependencies == [
                  "PrimeCore",
                  "PrimeNativeDecoder",
                  "PrimeNativeDecoderCheckpoint",
                  "MLX",
              ],
              publicRuntimePlanType
                == "PrimeNativeDecoderMaintainedRuntimePlanV1",
              publicRuntimePlanFactoryDeclaration
                == "public static func native300MByte512() throws -> Self",
              publicRuntimePlanValidatorDeclaration
                == "public func validate() throws",
              publicRuntimeInitializationDeclaration
                == "public static func initializeCurrentProcess(metallibExpectation: PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1, metalLeaseURL: URL) throws -> PrimeNativeDecoderMaintainedRuntimeInitializationEvidenceV1",
              requiredMetalDeviceCount == 1,
              requiredMLXGPUIndex == 0,
              metalDefaultDeviceMustMatchIndexZero,
              !physicalGPUIdentityRequired,
              initializationProbeDType == "float32",
              initializationProbeShape == [2, 2],
              initializationProbeLeftFloat32BitPatterns == [
                  Float(-0.8).bitPattern,
                  Float(0.2).bitPattern,
                  Float(0.3).bitPattern,
                  Float(-0.4).bitPattern,
              ],
              initializationProbeRightFloat32BitPatterns == [
                  Float(1).bitPattern,
                  Float(0).bitPattern,
                  Float(0).bitPattern,
                  Float(1).bitPattern,
              ],
              initializationProbeExpectedFloat32BitPatterns == [
                  Float(-0.8).bitPattern,
                  Float(0.2).bitPattern,
                  Float(0.3).bitPattern,
                  Float(-0.4).bitPattern,
              ],
              newSourcePinsFinalized,
              successorRootPackageManifestSource.path
                == baseRootPackageManifestPath,
              successorRootPackageManifestSource.gitMode
                == "100644",
              successorRootPackageResolvedSource.path
                == baseRootPackageResolvedPath,
              successorRootPackageResolvedSource.gitMode
                == "100644",
              runtimeSource.path == runtimeSourcePath,
              runtimeSource.gitMode == "100644",
              runtimeValidationPackageManifestSource.path
                == runtimeValidationPackagePath
                    + "/Package.swift",
              runtimeValidationPackageManifestSource.gitMode
                == "100644",
              runtimeValidationPackageResolvedSource.path
                == runtimeValidationPackagePath
                    + "/Package.resolved",
              runtimeValidationPackageResolvedSource.gitMode
                == "100644",
              runtimeValidationProbeSource.path
                == runtimeValidationPackagePath
                    + "/Sources/"
                    + runtimeValidationProbeTarget
                    + "/main.swift",
              runtimeValidationProbeSource.gitMode == "100644",
              runtimeValidationTestSource.path
                == runtimeValidationPackagePath
                    + "/Tests/"
                    + runtimeValidationTestTarget
                    + "/"
                    + runtimeValidationTestTarget
                    + ".swift",
              runtimeValidationTestSource.gitMode == "100644",
              runtimeClosureLauncherSource.path
                == runtimeClosureLauncherPath,
              runtimeClosureLauncherSource.gitMode == "100755",
              releaseInstrumentationValidationRequired,
              v2IdentityValidationIsDeclarativeOnly,
              launchedEnvironmentRetainedUntilProcessExitRequired,
              metalLeaseAcquiredBeforeFirstDeviceAccess,
              coreGraphicsBootstrapRequired,
              admittedRuntimeComputePolicyEstablished,
              runtimeDependencyClosureAuthorized,
              sourcePinnedMetallibVerificationAuthorized,
              runtimeMetalDeviceClosureAuthorized,
              boundedMLXRuntimeInitializationAuthorized,
              declarativeV2IdentityValidationAuthorized,
              tinyExplicitGPUAllocationAuthorized,
              !runtimeDependencyClosureEstablished,
              !runtimeLoadedMetallibIdentityEstablished,
              !sourcePinnedExclusiveCandidateInferenceEstablished,
              !loadedMetallibIdentityIndependentlyObserved,
              !runtimeMetalDeviceIdentityEstablished,
              !boundedMLXRuntimeInitializationEstablished,
              !tf32StaticValueDirectlyObserved,
              !tf32DifferentialObserved,
              !naxTF32ConsumerPathObserved,
              !decoderModelInitializationEstablished,
              !decoderForwardObserved,
              runtimeProductAndTargetAdditionAuthorized,
              rootPackageManifestMutationAuthorized,
              rootPackageResolvedMutationAuthorized,
              runtimeSourceAdditionAuthorized,
              runtimeValidationPackageAdditionAuthorized,
              runtimeClosureLauncherAdditionAuthorized,
              trustedWorkflowCommandExtensionAuthorized,
              !workflowTopologyMutationAuthorized,
              sourceGatePinExtensionAuthorized,
              embeddedBuildProvenanceUpdateAuthorized,
              documentationUpdateAuthorized,
              !checkpointV1SourceMutationAuthorized,
              !checkpointV2SourceMutationAuthorized,
              !repairedDecoderMutationAuthorized,
              !frozenObservationMutationAuthorized,
              !frozenMetalLauncherMutationAuthorized,
              !existingIsolatedDecoderValidationMutationAuthorized,
              !existing44TestInventoryMutationAuthorized,
              !driverV2MutationAuthorized,
              !pmhnpMutationAuthorized,
              !geometryDependencyAuthorized,
              !newExternalDependencyAuthorized,
              !v2ManifestDefined,
              !v2CodecDefined,
              !checkpointContainerIOImplemented,
              !checkpointArtifactAvailable,
              !checkpointArtifactProvenanceEstablished,
              !checkpointAdmissionGranted,
              !native300MModelAllocationAuthorized,
              !native300MCheckpointWriteAuthorized,
              !native300MCheckpointLoadAuthorized,
              !tokenizerFunctionalCompatibilityEstablished,
              !optimizerStateIncluded,
              !rngStateIncluded,
              !dataCursorIncluded,
              !trainingResumeEstablished,
              !trainEvaluateSurfaceEstablished,
              !optimizerStepObserved,
              !trainingExecutionObserved,
              !modelQualityEstablished,
              !functionalTrainingAuthorized,
              !longTrainingAuthorized,
              !candidateAdmissionGranted,
              !trialAuthorized,
              !canaryReplacementAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !publicationAuthorized,
              status.hasPrefix("ABSTAIN_"),
              orderedNextActions.first
                == "run_exact_clean_hosted_main_runtime_closure_and_append_execution_observation"
        else {
            throw
                PrimeNativeDecoderMaintainedRuntimeComputeAuthorityError
                    .contractDrift
        }
    }
}

private func isPrimeNativeDecoderExactLowercaseSHA256(
    _ value: String
) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy { byte in
            (48 ... 57).contains(byte)
                || (97 ... 102).contains(byte)
        }
        && value != String(repeating: "0", count: 64)
}

private func isPrimeNativeDecoderExactLowercaseGitObjectID(
    _ value: String
) -> Bool {
    value.utf8.count == 40
        && value.utf8.allSatisfy { byte in
            (48 ... 57).contains(byte)
                || (97 ... 102).contains(byte)
        }
        && value != String(repeating: "0", count: 40)
}
