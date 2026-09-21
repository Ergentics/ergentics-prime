// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Superseding authority for future Prime decoder implementation work.
///
/// `PrimeNativeArcContinuityPlan.frozenV1` remains immutable evidence of the
/// completed, bounded `MLXLLM.LlamaModel` mechanics continuation. That
/// historical implementation cannot select the decoder used by a future
/// functional trainer. This contract pins the already-existing Ergentics
/// Logic decoder semantics as the source donor and authorizes only a
/// Prime-owned Swift mechanical port over maintained MLX primitives.
public struct PrimeNativeDecoderAuthorityPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let supersededHistoricalArcID: String
    public let historicalMechanicsImplementation: String
    public let historicalMechanicsDisposition: String
    public let historicalMechanicsReceiptsRemainValid: Bool
    public let historicalMechanicsReceiptMutationAuthorized: Bool
    public let historicalMechanicsMaySelectFutureDecoder: Bool
    public let historicalMLXLLMTargetAllowlist: [String]
    public let historicalMLXLLMSourceReferenceAllowlist: [String]
    public let historicalMLXLLMNonImportReferenceImportTokenCounts:
        [String: Int]
    public let sourceDonorRightsHolder: String
    public let sourceDonorLicenseID: String
    public let sourceDonorRepository: String
    public let sourceDonorRevision: String
    public let sourceDonorPath: String
    public let sourceDonorGitBlob: String
    public let sourceDonorGitMode: String
    public let sourceDonorByteCount: Int
    public let sourceDonorSHA256: String
    public let sourceDonorTypeName: String
    public let sourceDonorLanguage: String
    public let ownershipEvidencePath: String
    public let ownershipEvidenceGitBlob: String
    public let ownershipEvidenceGitMode: String
    public let ownershipEvidenceByteCount: Int
    public let ownershipEvidenceSHA256: String
    public let sourceDonorRole: String
    public let sourceDonorRuntimeDependencyAuthorized: Bool
    public let sourceDonorPythonExecutionAuthorized: Bool
    public let pythonInterpreterAuthorized: Bool
    public let pythonReferenceParityRunAuthorized: Bool
    public let shellScientificAuthorityAuthorized: Bool
    public let authoritativeRepository: String
    public let authoritativeTarget: String
    public let authoritativeTargetDependencies: [String]
    public let authoritativeTargetForbiddenTokens: [String]
    public let authoritativeTargetAllowedFileExtensions: [String]
    public let rootMLXLLMDependencyMustBeAbsentBeforeTarget: Bool
    public let authoritativeImplementationID: String
    public let authoritativeImplementationLanguage: String
    public let authoritativePrimitiveModules: [String]
    public let trainerOptimizerModule: String
    public let deviceExecutionSubstrate: String
    public let mechanicalPortOfPinnedArchitectureAuthorized: Bool
    public let newArchitectureFamilyAuthorized: Bool
    public let adaptationByteExact: Bool
    public let donorWeightsImported: Bool
    public let donorTokenizerImported: Bool
    public let donorCorpusImported: Bool
    public let historicalCheckpointCompatibilityClaimed: Bool
    public let historicalReceiptSchemaMayAdmitNewEvidence: Bool
    public let newEvidenceSchemaRequired: Bool
    public let thirdPartyPretrainedWeightsAuthorized: Bool
    public let thirdPartyDecoderImplementationAuthorized: Bool
    public let initialExecutableProfileScope: String
    public let deferredProfileInventoryScope: String
    public let gqaExtensionStatus: String
    public let mlxLLMRootDependencyDisposition: String
    public let largerProfileSelectionAuthority: String
    public let functionalTrainingAuthorized: Bool
    public let longTrainingAuthorized: Bool
    public let profilePromotionAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productPromotionAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "ergentics_prime_first_party_decoder_authority_v1",
        supersededHistoricalArcID:
            "ergentics_prime_native_neuralkit_continuity_v1",
        historicalMechanicsImplementation:
            "MLXLLM.LlamaModel",
        historicalMechanicsDisposition:
            "quarantined_bounded_mechanics_comparator_only",
        historicalMechanicsReceiptsRemainValid: true,
        historicalMechanicsReceiptMutationAuthorized: false,
        historicalMechanicsMaySelectFutureDecoder: false,
        historicalMLXLLMTargetAllowlist: [
            "PrimeGPUCalibration",
            "PrimeNative3BMetalContinuationProbe",
        ],
        historicalMLXLLMSourceReferenceAllowlist: [
            "Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
            "Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift",
            "Sources/PrimeCore/PrimeNative3BMetalContinuation.swift",
            "Sources/PrimeCore/PrimeNativeArcContinuity.swift",
            "Sources/PrimeCore/PrimeNativeDecoderAuthority.swift",
            "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
            "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
            "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/EngineProposesNativeLanguageVerifyAbstainFixture.swift",
        ],
        historicalMLXLLMNonImportReferenceImportTokenCounts: [
            "Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift": 2,
            "Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift": 2,
            "Sources/PrimeCore/PrimeNative3BMetalContinuation.swift": 3,
            "Sources/PrimeCore/PrimeNativeArcContinuity.swift": 1,
            "Sources/PrimeCore/PrimeNativeDecoderAuthority.swift": 1,
            "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/EngineProposesNativeLanguageVerifyAbstainFixture.swift": 4,
        ],
        sourceDonorRightsHolder: "Ergentics, LLC",
        sourceDonorLicenseID:
            "LicenseRef-Ergentics-Proprietary",
        sourceDonorRepository:
            "Ergentics/ergentics-logic",
        sourceDonorRevision:
            "97be84b2790b79ce79558d6bade846a532226540",
        sourceDonorPath:
            "Sources/ModelKit/model.py",
        sourceDonorGitBlob:
            "fcc471205780bf742fb7d70f5d4fdb073b90f216",
        sourceDonorGitMode: "100644",
        sourceDonorByteCount: 7_189,
        sourceDonorSHA256:
            "8e28d1e19b5aea4504af62d5ff11b8d318d77c3e232670b9d8751b0996e264a2",
        sourceDonorTypeName: "ErgeticsLogicModel",
        sourceDonorLanguage: "Python",
        ownershipEvidencePath: "SEED.md",
        ownershipEvidenceGitBlob:
            "3ed6e27813bf61ca76e3919848ac14f14d4c4c4f",
        ownershipEvidenceGitMode: "100644",
        ownershipEvidenceByteCount: 23_250,
        ownershipEvidenceSHA256:
            "e85812acc482d37643c135fd6db8dbfc0007dd5add712ed4407b7076ab978d54",
        sourceDonorRole:
            "architecture_and_reference_source_only_no_execution",
        sourceDonorRuntimeDependencyAuthorized: false,
        sourceDonorPythonExecutionAuthorized: false,
        pythonInterpreterAuthorized: false,
        pythonReferenceParityRunAuthorized: false,
        shellScientificAuthorityAuthorized: false,
        authoritativeRepository:
            "Ergentics/ergentics-prime",
        authoritativeTarget: "PrimeNativeDecoder",
        authoritativeTargetDependencies: [
            "PrimeCore",
            "MLX",
            "MLXNN",
        ],
        authoritativeTargetForbiddenTokens: [
            "MLXLLM",
            "MLXLMCommon",
            "LlamaModel",
            "LlamaConfiguration",
            "Python",
            "python",
            "PythonKit",
            "PrimeNativeProfiles.exact3B",
            "PrimeNative3BMetalContinuation",
            "ErgenticsNativeScaleEngineRecommend",
            "huggingface.co",
            "loadModelContainer",
            "snapshot_download",
            "/usr/bin/python",
            "/bin/python",
            "/bin/sh",
            "/bin/zsh",
            "/bin/bash",
            "posix_spawn",
            "execve(",
            "Process",
        ],
        authoritativeTargetAllowedFileExtensions: [
            "swift",
        ],
        rootMLXLLMDependencyMustBeAbsentBeforeTarget: true,
        authoritativeImplementationID:
            "prime_owned_swift_mlxnn_port_of_pinned_ergentics_logic_decoder",
        authoritativeImplementationLanguage: "Swift",
        authoritativePrimitiveModules: ["MLX", "MLXNN"],
        trainerOptimizerModule: "MLXOptimizers",
        deviceExecutionSubstrate: "Metal",
        mechanicalPortOfPinnedArchitectureAuthorized: true,
        newArchitectureFamilyAuthorized: false,
        adaptationByteExact: false,
        donorWeightsImported: false,
        donorTokenizerImported: false,
        donorCorpusImported: false,
        historicalCheckpointCompatibilityClaimed: false,
        historicalReceiptSchemaMayAdmitNewEvidence: false,
        newEvidenceSchemaRequired: true,
        thirdPartyPretrainedWeightsAuthorized: false,
        thirdPartyDecoderImplementationAuthorized: false,
        initialExecutableProfileScope:
            "pinned_logic_10m_conformance_only",
        deferredProfileInventoryScope:
            "pinned_logic_phase1_300m_configuration_inventoried_execution_not_authorized",
        gqaExtensionStatus:
            "ABSTAIN_requires_explicit_derived_delta",
        mlxLLMRootDependencyDisposition:
            "remove_before_authoritative_decoder_implementation_or_isolate_uncompiled_historical_package",
        largerProfileSelectionAuthority:
            "EngineProposeDeriveDispose_after_swift_parity_and_feasibility_evidence",
        functionalTrainingAuthorized: false,
        longTrainingAuthorized: false,
        profilePromotionAuthorized: false,
        quantizationAuthorized: false,
        productPromotionAuthorized: false,
        status:
            "ABSTAIN_pending_swift_port_and_mechanics_gates",
        orderedNextActions: [
            "finish_neutral_secure_child_supervision",
            "finish_driver_v2_raw_byte_acquisition_and_swift_parser_derivation",
            "bind_pinned_ergentics_logic_source_and_derivation_evidence",
            "remove_mlxllm_from_root_or_isolate_uncompiled_historical_package",
            "mechanically_port_pinned_decoder_semantics_to_prime_swift_mlxnn",
            "prove_component_forward_backward_checkpoint_resume_and_deterministic_parity",
            "run_multiseed_first_party_function_learning_canary",
            "ask_engine_to_select_or_abstain_on_larger_profile",
            "consider_quantization_only_after_accepted_fp_functional_checkpoint",
        ]
    )

    public func validate() throws {
        let expected = Self.frozenV1
        let historical =
            PrimeNativeArcContinuityPlan.frozenV1

        guard self == expected,
              schemaVersion == 1,
              supersededHistoricalArcID
                == historical.arcID,
              historicalMechanicsImplementation
                == historical.continuationModelImplementation,
              historicalMechanicsDisposition
                == "quarantined_bounded_mechanics_comparator_only",
              historicalMechanicsReceiptsRemainValid,
              !historicalMechanicsReceiptMutationAuthorized,
              !historicalMechanicsMaySelectFutureDecoder,
              historicalMLXLLMTargetAllowlist == [
                  "PrimeGPUCalibration",
                  "PrimeNative3BMetalContinuationProbe",
              ],
              historicalMLXLLMSourceReferenceAllowlist == [
                  "Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift",
                  "Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift",
                  "Sources/PrimeCore/PrimeNative3BMetalContinuation.swift",
                  "Sources/PrimeCore/PrimeNativeArcContinuity.swift",
                  "Sources/PrimeCore/PrimeNativeDecoderAuthority.swift",
                  "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
                  "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
                  "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/EngineProposesNativeLanguageVerifyAbstainFixture.swift",
              ],
              historicalMLXLLMNonImportReferenceImportTokenCounts == [
                  "Sources/ErgenticsPrimeRuntime/ErgenticsNativeLanguageCanary.swift": 2,
                  "Sources/ErgenticsPrimeRuntime/ErgenticsNativeScaleEngineRecommend.swift": 2,
                  "Sources/PrimeCore/PrimeNative3BMetalContinuation.swift": 3,
                  "Sources/PrimeCore/PrimeNativeArcContinuity.swift": 1,
                  "Sources/PrimeCore/PrimeNativeDecoderAuthority.swift": 1,
                  "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/EngineProposesNativeLanguageVerifyAbstainFixture.swift": 4,
              ],
              sourceDonorRightsHolder == "Ergentics, LLC",
              sourceDonorLicenseID
                == "LicenseRef-Ergentics-Proprietary",
              sourceDonorRepository
                == "Ergentics/ergentics-logic",
              sourceDonorRevision.count == 40,
              sourceDonorRevision.allSatisfy({
                  "0123456789abcdef".contains($0)
              }),
              sourceDonorPath
                == "Sources/ModelKit/model.py",
              sourceDonorGitBlob
                == "fcc471205780bf742fb7d70f5d4fdb073b90f216",
              sourceDonorGitMode == "100644",
              sourceDonorByteCount == 7_189,
              sourceDonorSHA256
                == "8e28d1e19b5aea4504af62d5ff11b8d318d77c3e232670b9d8751b0996e264a2",
              sourceDonorTypeName
                == "ErgeticsLogicModel",
              sourceDonorLanguage == "Python",
              ownershipEvidencePath == "SEED.md",
              ownershipEvidenceGitBlob
                == "3ed6e27813bf61ca76e3919848ac14f14d4c4c4f",
              ownershipEvidenceGitMode == "100644",
              ownershipEvidenceByteCount == 23_250,
              ownershipEvidenceSHA256
                == "e85812acc482d37643c135fd6db8dbfc0007dd5add712ed4407b7076ab978d54",
              sourceDonorRole
                == "architecture_and_reference_source_only_no_execution",
              !sourceDonorRuntimeDependencyAuthorized,
              !sourceDonorPythonExecutionAuthorized,
              !pythonInterpreterAuthorized,
              !pythonReferenceParityRunAuthorized,
              !shellScientificAuthorityAuthorized,
              authoritativeRepository
                == "Ergentics/ergentics-prime",
              authoritativeTarget == "PrimeNativeDecoder",
              authoritativeTargetDependencies
                == ["PrimeCore", "MLX", "MLXNN"],
              authoritativeTargetForbiddenTokens == [
                  "MLXLLM",
                  "MLXLMCommon",
                  "LlamaModel",
                  "LlamaConfiguration",
                  "Python",
                  "python",
                  "PythonKit",
                  "PrimeNativeProfiles.exact3B",
                  "PrimeNative3BMetalContinuation",
                  "ErgenticsNativeScaleEngineRecommend",
                  "huggingface.co",
                  "loadModelContainer",
                  "snapshot_download",
                  "/usr/bin/python",
                  "/bin/python",
                  "/bin/sh",
                  "/bin/zsh",
                  "/bin/bash",
                  "posix_spawn",
                  "execve(",
                  "Process",
              ],
              authoritativeTargetAllowedFileExtensions
                == ["swift"],
              rootMLXLLMDependencyMustBeAbsentBeforeTarget,
              authoritativeImplementationID
                != historicalMechanicsImplementation,
              authoritativeImplementationLanguage
                == "Swift",
              authoritativePrimitiveModules
                == ["MLX", "MLXNN"],
              trainerOptimizerModule == "MLXOptimizers",
              deviceExecutionSubstrate == "Metal",
              mechanicalPortOfPinnedArchitectureAuthorized,
              !newArchitectureFamilyAuthorized,
              !adaptationByteExact,
              !donorWeightsImported,
              !donorTokenizerImported,
              !donorCorpusImported,
              !historicalCheckpointCompatibilityClaimed,
              !historicalReceiptSchemaMayAdmitNewEvidence,
              newEvidenceSchemaRequired,
              !thirdPartyPretrainedWeightsAuthorized,
              !thirdPartyDecoderImplementationAuthorized,
              initialExecutableProfileScope
                == "pinned_logic_10m_conformance_only",
              deferredProfileInventoryScope
                == "pinned_logic_phase1_300m_configuration_inventoried_execution_not_authorized",
              gqaExtensionStatus
                == "ABSTAIN_requires_explicit_derived_delta",
              mlxLLMRootDependencyDisposition
                == "remove_before_authoritative_decoder_implementation_or_isolate_uncompiled_historical_package",
              largerProfileSelectionAuthority.hasPrefix(
                  "EngineProposeDeriveDispose_"
              ),
              !functionalTrainingAuthorized,
              !longTrainingAuthorized,
              !profilePromotionAuthorized,
              !quantizationAuthorized,
              !productPromotionAuthorized,
              status
                == "ABSTAIN_pending_swift_port_and_mechanics_gates",
              orderedNextActions.first
                == "finish_neutral_secure_child_supervision",
              orderedNextActions.last
                == "consider_quantization_only_after_accepted_fp_functional_checkpoint"
        else {
            throw PrimeNativeDecoderAuthorityError
                .contractDrift
        }
    }
}
