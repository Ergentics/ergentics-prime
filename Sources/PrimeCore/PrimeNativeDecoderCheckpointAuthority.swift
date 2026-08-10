// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderCheckpointAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Append-only authority for a model-weights-only checkpoint compatibility
/// contract. This does not reinterpret either predecessor authority and does
/// not establish a live runtime, an accepted checkpoint, or training state.
public struct PrimeNativeDecoderCheckpointAuthorityPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let predecessorAuthorityID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorSourceGitBlob: String
    public let predecessorSourceByteCount: Int
    public let predecessorSourceSHA256: String
    public let decoderSourceGitBlob: String
    public let decoderSourceByteCount: Int
    public let decoderSourceSHA256: String
    public let authoritativeRepository: String
    public let authoritativeProduct: String
    public let authoritativeTarget: String
    public let authoritativeTargetDependencies: [String]
    public let checkpointSourcePath: String
    public let checkpointSourceGitBlob: String
    public let checkpointSourceGitMode: String
    public let checkpointSourceByteCount: Int
    public let checkpointSourceSHA256: String
    public let checkpointSchema: String
    public let checkpointArtifactKind: String
    public let compatibilityIdentitySchema: String
    public let parameterPathSchema: String
    public let logicalTensorHashAlgorithm: String
    public let logicalTensorByteEncoding: String
    public let exactMLXRevision: String
    public let checkpointFormat: String
    public let tensorDType: String
    public let stateScope: String
    public let publicCheckpointCompatibilityProfile: String
    public let publicTokenizerID: String
    public let publicTokenizerManifestSHA256: String
    public let publicVocabularySize: Int
    public let checkpointTargetForbiddenTokens: [String]
    public let compatibilityIdentitySchemaEstablished: Bool
    public let analyticParameterCatalogEstablished: Bool
    public let exactLogicalTensorHashContractEstablished: Bool
    public let borrowedDescriptorIOMechanicsImplemented: Bool
    public let freshDecoderPreflightPolicyEstablished: Bool
    public let boundedSyntheticRoundTripAuthorized: Bool
    public let native300MModelAllocationAuthorized: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let liveSyntheticRoundTripObserved: Bool
    public let metalDeviceObserved: Bool
    public let defaultMetallibObserved: Bool
    public let forwardExecutionObserved: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let tokenizerFunctionalCompatibilityEstablished: Bool
    public let acceptedCheckpointArtifactAvailable: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointContainerHashBound: Bool
    public let atomicCheckpointReplacementEstablished: Bool
    public let checkpointFsyncDurabilityEstablished: Bool
    public let failedCheckpointWriteRecoveryEstablished: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let kvCacheStateIncluded: Bool
    public let trainingResumeEstablished: Bool
    public let functionalTrainingAuthorized: Bool
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
            "ergentics_prime_native_decoder_checkpoint_compatibility_v1",
        predecessorAuthorityID:
            PrimeNativeDecoderDerivedDeltaPlan.frozenV1.authorityID,
        predecessorRemainsFrozen: true,
        predecessorSourceGitBlob:
            "84b8c0ce3f6753d21800d0ce60b430ee2bd7db3f",
        predecessorSourceByteCount: 11_872,
        predecessorSourceSHA256:
            "69246fd4d900119152c419f8d08dce9955416ef4ac44a4422dceb9b77c154d4e",
        decoderSourceGitBlob:
            "55407cba9dbcc4e915b0994aed16f02c1da95e16",
        decoderSourceByteCount: 38_524,
        decoderSourceSHA256:
            "7e3e9c676225e7d600c5580cb3ae73a3d15fdeff12d0933e175b41923c370162",
        authoritativeRepository: "Ergentics/ergentics-prime",
        authoritativeProduct: "PrimeNativeDecoderCheckpoint",
        authoritativeTarget: "PrimeNativeDecoderCheckpoint",
        authoritativeTargetDependencies: [
            "PrimeCore",
            "PrimeNativeDecoder",
            "MLX",
            "MLXNN",
        ],
        checkpointSourcePath:
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift",
        checkpointSourceGitBlob:
            "24de078fb6424123b8e6974588b4cc514219c026",
        checkpointSourceGitMode: "100644",
        checkpointSourceByteCount: 39_956,
        checkpointSourceSHA256:
            "a239d2dd4ea9cc794105e15c09457e7bda526d8e1dbafeb3383997bb14f89b8b",
        checkpointSchema:
            "ergentics_prime_native_decoder_weights_checkpoint_v1",
        checkpointArtifactKind:
            "prime_native_decoder_model_weights_only_checkpoint",
        compatibilityIdentitySchema:
            "ergentics_prime_native_decoder_checkpoint_compatibility_v1",
        parameterPathSchema:
            "mlxnn_flattened_module_parameters_v1",
        logicalTensorHashAlgorithm: "sha256",
        logicalTensorByteEncoding:
            "contiguous_row_major_little_endian_float32",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        checkpointFormat: "safetensors",
        tensorDType: "float32",
        stateScope:
            "model_parameters_only_no_optimizer_rng_cursor_or_cache",
        publicCheckpointCompatibilityProfile:
            "native300m_gqa_byte512_checkpoint_compatibility_v1",
        publicTokenizerID:
            "ergentics_prime_nfc_utf8_byte_v1",
        publicTokenizerManifestSHA256:
            "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7",
        publicVocabularySize: 512,
        checkpointTargetForbiddenTokens:
            PrimeNativeDecoderDerivedDeltaPlan.frozenV1
                .implementationForbiddenTokens + [
                    "FileManager",
                    "FileHandle",
                    "Data(contentsOf:",
                    "write(to:",
                    "PrimeArtifactRoot",
                    "URL(fileURLWithPath:",
                    "DispatchIO",
                    "NSFileCoordinator",
                    "open(",
                    "creat(",
                    "fopen(",
                    "close(",
                    "unlink(",
                    "rename(",
                    "fsync(",
                    "writeNative300MByte512",
                    "loadNative300MByte512",
                ],
        compatibilityIdentitySchemaEstablished: true,
        analyticParameterCatalogEstablished: true,
        exactLogicalTensorHashContractEstablished: true,
        borrowedDescriptorIOMechanicsImplemented: true,
        freshDecoderPreflightPolicyEstablished: true,
        boundedSyntheticRoundTripAuthorized: true,
        native300MModelAllocationAuthorized: false,
        native300MCheckpointWriteAuthorized: false,
        native300MCheckpointLoadAuthorized: false,
        liveSyntheticRoundTripObserved: false,
        metalDeviceObserved: false,
        defaultMetallibObserved: false,
        forwardExecutionObserved: false,
        runtimeDependencyClosureEstablished: false,
        runtimeInitializationEstablished: false,
        tokenizerFunctionalCompatibilityEstablished: false,
        acceptedCheckpointArtifactAvailable: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointContainerHashBound: false,
        atomicCheckpointReplacementEstablished: false,
        checkpointFsyncDurabilityEstablished: false,
        failedCheckpointWriteRecoveryEstablished: false,
        optimizerStateIncluded: false,
        rngStateIncluded: false,
        dataCursorIncluded: false,
        kvCacheStateIncluded: false,
        trainingResumeEstablished: false,
        functionalTrainingAuthorized: false,
        candidateAdmissionGranted: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        status:
            "ABSTAIN_checkpoint_compatibility_and_weights_only_descriptor_mechanics_no_live_runtime_or_candidate",
        orderedNextActions: [
            "compile_dependency_isolated_checkpoint_target",
            "run_bounded_synthetic_descriptor_round_trip_on_metal_capable_process",
            "authorize_native_profile_checkpoint_write_and_load_in_a_separate_successor",
            "define_generic_train_and_evaluate_surfaces_under_separate_authority",
            "establish_exact_optimizer_rng_and_data_cursor_resume",
            "authorize_bounded_training_and_produce_a_non_fixture_checkpoint",
            "bind_checkpoint_container_in_a_separate_verified_artifact_observation",
            "establish_runtime_dependency_closure_and_initialization",
            "request_separate_bounded_candidate_trial_authorization",
        ]
    )

    public func validate() throws {
        let expected = Self.frozenV1
        let predecessor = PrimeNativeDecoderDerivedDeltaPlan.frozenV1

        guard self == expected,
              schemaVersion == 1,
              predecessorAuthorityID == predecessor.authorityID,
              predecessorRemainsFrozen,
              predecessorSourceGitBlob.count == 40,
              predecessorSourceByteCount == 11_872,
              predecessorSourceSHA256.count == 64,
              decoderSourceGitBlob
                == predecessor.materializedSourceGitBlob,
              decoderSourceByteCount
                == predecessor.materializedSourceByteCount,
              decoderSourceSHA256
                == predecessor.materializedSourceSHA256,
              authoritativeRepository
                == predecessor.authoritativeRepository,
              authoritativeProduct == authoritativeTarget,
              authoritativeTargetDependencies == [
                  "PrimeCore",
                  "PrimeNativeDecoder",
                  "MLX",
                  "MLXNN",
              ],
              checkpointSourcePath
                == "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift",
              checkpointSourceGitBlob.utf8.count == 40,
              checkpointSourceGitBlob.utf8.allSatisfy(
                  isLowercaseHex),
              checkpointSourceGitBlob
                != String(repeating: "0", count: 40),
              checkpointSourceGitMode == "100644",
              checkpointSourceByteCount > 0,
              checkpointSourceSHA256.utf8.count == 64,
              checkpointSourceSHA256.utf8.allSatisfy(
                  isLowercaseHex),
              checkpointSourceSHA256
                != String(repeating: "0", count: 64),
              exactMLXRevision == predecessor.exactMLXRevision,
              checkpointFormat == "safetensors",
              tensorDType == "float32",
              logicalTensorHashAlgorithm == "sha256",
              logicalTensorByteEncoding
                == "contiguous_row_major_little_endian_float32",
              publicVocabularySize == 512,
              predecessor.implementationForbiddenTokens.allSatisfy({
                  checkpointTargetForbiddenTokens.contains($0)
              }),
              Set(checkpointTargetForbiddenTokens).count
                == checkpointTargetForbiddenTokens.count,
              checkpointTargetForbiddenTokens.contains("MLXOptimizers"),
              compatibilityIdentitySchemaEstablished,
              analyticParameterCatalogEstablished,
              exactLogicalTensorHashContractEstablished,
              borrowedDescriptorIOMechanicsImplemented,
              freshDecoderPreflightPolicyEstablished,
              boundedSyntheticRoundTripAuthorized,
              !native300MModelAllocationAuthorized,
              !native300MCheckpointWriteAuthorized,
              !native300MCheckpointLoadAuthorized,
              !liveSyntheticRoundTripObserved,
              !metalDeviceObserved,
              !defaultMetallibObserved,
              !forwardExecutionObserved,
              !runtimeDependencyClosureEstablished,
              !runtimeInitializationEstablished,
              !tokenizerFunctionalCompatibilityEstablished,
              !acceptedCheckpointArtifactAvailable,
              !checkpointArtifactProvenanceEstablished,
              !checkpointContainerHashBound,
              !atomicCheckpointReplacementEstablished,
              !checkpointFsyncDurabilityEstablished,
              !failedCheckpointWriteRecoveryEstablished,
              !optimizerStateIncluded,
              !rngStateIncluded,
              !dataCursorIncluded,
              !kvCacheStateIncluded,
              !trainingResumeEstablished,
              !functionalTrainingAuthorized,
              !candidateAdmissionGranted,
              !trialAuthorized,
              !canaryReplacementAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !publicationAuthorized,
              status.hasPrefix("ABSTAIN_"),
              orderedNextActions.first
                == "compile_dependency_isolated_checkpoint_target",
              orderedNextActions.last
                == "request_separate_bounded_candidate_trial_authorization"
        else {
            throw PrimeNativeDecoderCheckpointAuthorityError
                .contractDrift
        }
    }
}

private func isLowercaseHex(_ byte: UInt8) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
