// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderDerivedDeltaError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Additive authority for materializing the Ergentics GQA decoder mechanics
/// inside Prime without reinterpreting the frozen Logic-MHA authority.
///
/// This plan authorizes source integration and bounded synthetic mechanics
/// tests only. It is not an execution observation, checkpoint admission,
/// training authorization, candidate selection, or product decision.
public struct PrimeNativeDecoderDerivedDeltaPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let predecessorAuthorityID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorGQAAbstentionPreserved: Bool
    public let authoritativeRepository: String
    public let authoritativeProduct: String
    public let authoritativeTarget: String
    public let authoritativeTargetDependencies: [String]
    public let authoritativeImplementationID: String
    public let architectureSchema: String
    public let materializedSourcePath: String
    public let materializedSourceGitBlob: String
    public let materializedSourceGitMode: String
    public let materializedSourceByteCount: Int
    public let materializedSourceSHA256: String
    public let portAdaptationDisposition: String
    public let implementationLanguage: String
    public let primitiveModules: [String]
    public let exactMLXRevision: String
    public let donorRepository: String
    public let donorBodyRevision: String
    public let donorCacheRevision: String
    public let donorTree: String
    public let donorSourcePath: String
    public let donorSourceGitBlob: String
    public let donorSourceGitMode: String
    public let donorSourceByteCount: Int
    public let donorSourceSHA256: String
    public let donorArchitectureSchema: String
    public let donorImplementationID: String
    public let donorRevisionPublishedToOriginObserved: Bool
    public let donorRole: String
    public let ergenticsLLMRuntimeDependencyAuthorized: Bool
    public let sourcePortMaterializationAuthorized: Bool
    public let sourceCompilationAuthorized: Bool
    public let boundedSyntheticMechanicsTestsAuthorized: Bool
    public let orderedDerivedDeltas: [String]
    public let logic10MConformanceProfileDisposition: String
    public let native300MProfileDisposition: String
    public let implementationForbiddenTokens: [String]
    public let modelInitializationObserved: Bool
    public let forwardExecutionObserved: Bool
    public let metalExecutionObserved: Bool
    public let cacheParityObserved: Bool
    public let gradientExecutionObserved: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let checkpointContractEstablished: Bool
    public let checkpointLoadAuthorized: Bool
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
            "ergentics_prime_native_decoder_gqa_derived_delta_v1",
        predecessorAuthorityID:
            PrimeNativeDecoderAuthorityPlan.frozenV1.authorityID,
        predecessorRemainsFrozen: true,
        predecessorGQAAbstentionPreserved: true,
        authoritativeRepository: "Ergentics/ergentics-prime",
        authoritativeProduct: "PrimeNativeDecoder",
        authoritativeTarget: "PrimeNativeDecoder",
        authoritativeTargetDependencies: [
            "PrimeCore",
            "MLX",
            "MLXNN",
        ],
        authoritativeImplementationID:
            "PrimeNativeDecoder.PrimeNativeGQADecoder",
        architectureSchema:
            "ergentics_prime_native_gqa_decoder_architecture_v1",
        materializedSourcePath:
            "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
        materializedSourceGitBlob:
            "55407cba9dbcc4e915b0994aed16f02c1da95e16",
        materializedSourceGitMode: "100644",
        materializedSourceByteCount: 38_524,
        materializedSourceSHA256:
            "7e3e9c676225e7d600c5580cb3ae73a3d15fdeff12d0933e175b41923c370162",
        portAdaptationDisposition:
            "reviewed_prime_prefix_module_identity_and_logic_inventory_adaptation_of_exact_pinned_donor",
        implementationLanguage: "Swift",
        primitiveModules: ["MLX", "MLXNN"],
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        donorRepository: "Ergentics/ergentics-llm",
        donorBodyRevision:
            "79cfeb250c064359c49298c0861fdd1b41d05f87",
        donorCacheRevision:
            "8eb36a77891154ce13cca96d8def9cf59c76bd5b",
        donorTree:
            "7c8f6666030ae4f16de239d6d178fb3c1f3e55e5",
        donorSourcePath:
            "Sources/ErgenticsLLM/ErgenticsNativeGQADecoder.swift",
        donorSourceGitBlob:
            "cf2524b25944a021e75bbdcd647984747df6fe13",
        donorSourceGitMode: "100644",
        donorSourceByteCount: 37_970,
        donorSourceSHA256:
            "9f834930d38182b665b62dbeb2f6212eca0e45189a084f1109c97c57b4a691f3",
        donorArchitectureSchema:
            "ergentics_native_gqa_decoder_architecture_v1",
        donorImplementationID:
            "ErgenticsLLM.ErgenticsNativeGQADecoder",
        donorRevisionPublishedToOriginObserved: false,
        donorRole:
            "pinned_local_source_donor_no_runtime_or_package_authority",
        ergenticsLLMRuntimeDependencyAuthorized: false,
        sourcePortMaterializationAuthorized: true,
        sourceCompilationAuthorized: true,
        boundedSyntheticMechanicsTestsAuthorized: true,
        orderedDerivedDeltas: [
            "logic_mha_to_grouped_query_attention",
            "no_cache_to_append_only_kv_cache",
            "manual_attention_path_to_mlx_fast_causal_sdpa",
            "logic_rms_norm_epsilon_1e_6_to_native_1e_5",
        ],
        logic10MConformanceProfileDisposition:
            "representable_with_equal_query_and_kv_heads_parity_not_claimed",
        native300MProfileDisposition:
            "geometry_inventory_only_allocation_and_execution_not_authorized",
        implementationForbiddenTokens:
            PrimeNativeDecoderAuthorityPlan.frozenV1
                .authoritativeTargetForbiddenTokens + [
                    "HuggingFace",
                    "PMHNP",
                    "URLSession",
                    "MLXOptimizers",
                    "ErgenticsLLM",
                    "NativeTinyDecoder",
                ],
        modelInitializationObserved: false,
        forwardExecutionObserved: false,
        metalExecutionObserved: false,
        cacheParityObserved: false,
        gradientExecutionObserved: false,
        runtimeDependencyClosureEstablished: false,
        runtimeInitializationEstablished: false,
        checkpointContractEstablished: false,
        checkpointLoadAuthorized: false,
        functionalTrainingAuthorized: false,
        longTrainingAuthorized: false,
        candidateAdmissionGranted: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        status:
            "ABSTAIN_prime_source_materialized_runtime_and_training_unestablished",
        orderedNextActions: [
            "compile_dependency_isolated_target",
            "run_synthetic_mechanics_tests_on_metal_capable_process",
            "define_strict_checkpoint_and_runtime_identity",
            "establish_runtime_dependency_closure_and_initialization",
            "request_separate_bounded_trial_authorization",
        ]
    )

    public func validate() throws {
        let expected = Self.frozenV1
        let predecessor = PrimeNativeDecoderAuthorityPlan.frozenV1

        guard self == expected,
              schemaVersion == 1,
              predecessorAuthorityID == predecessor.authorityID,
              predecessorRemainsFrozen,
              predecessorGQAAbstentionPreserved,
              predecessor.gqaExtensionStatus
                == "ABSTAIN_requires_explicit_derived_delta",
              authoritativeRepository
                == predecessor.authoritativeRepository,
              authoritativeTarget
                == predecessor.authoritativeTarget,
              authoritativeTargetDependencies
                == predecessor.authoritativeTargetDependencies,
              authoritativeProduct == authoritativeTarget,
              authoritativeImplementationID
                != predecessor.authoritativeImplementationID,
              architectureSchema
                == "ergentics_prime_native_gqa_decoder_architecture_v1",
              materializedSourcePath
                == "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
              materializedSourceGitBlob.count == 40,
              materializedSourceGitMode == "100644",
              materializedSourceByteCount == 38_524,
              materializedSourceSHA256.count == 64,
              portAdaptationDisposition.hasPrefix("reviewed_prime_"),
              implementationLanguage == "Swift",
              primitiveModules == ["MLX", "MLXNN"],
              exactMLXRevision.count == 40,
              donorRepository == "Ergentics/ergentics-llm",
              donorBodyRevision.count == 40,
              donorCacheRevision.count == 40,
              donorTree.count == 40,
              donorSourceGitBlob.count == 40,
              donorSourceGitMode == "100644",
              donorSourceByteCount == 37_970,
              donorSourceSHA256.count == 64,
              !donorRevisionPublishedToOriginObserved,
              !ergenticsLLMRuntimeDependencyAuthorized,
              sourcePortMaterializationAuthorized,
              sourceCompilationAuthorized,
              boundedSyntheticMechanicsTestsAuthorized,
              orderedDerivedDeltas.count == 4,
              native300MProfileDisposition.hasPrefix(
                  "geometry_inventory_only_"
              ),
              predecessor.authoritativeTargetForbiddenTokens.allSatisfy({
                  implementationForbiddenTokens.contains($0)
              }),
              implementationForbiddenTokens.contains("ErgenticsLLM"),
              !modelInitializationObserved,
              !forwardExecutionObserved,
              !metalExecutionObserved,
              !cacheParityObserved,
              !gradientExecutionObserved,
              !runtimeDependencyClosureEstablished,
              !runtimeInitializationEstablished,
              !checkpointContractEstablished,
              !checkpointLoadAuthorized,
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
                == "compile_dependency_isolated_target",
              orderedNextActions.last
                == "request_separate_bounded_trial_authorization"
        else {
            throw PrimeNativeDecoderDerivedDeltaError.contractDrift
        }
    }
}
