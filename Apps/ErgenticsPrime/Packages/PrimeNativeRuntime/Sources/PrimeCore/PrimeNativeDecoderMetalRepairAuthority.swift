// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderMetalRepairAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

public struct PrimeNativeDecoderCIMLXComputeEnvironmentPolicyDeclaration:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let policyID: String
    public let policyVersion: Int
    public let scope: String
    public let exactMLXRevision: String
    public let requiredEnvironmentKey: String
    public let requiredEnvironmentValue: String
    public let exclusiveEnvironmentKeyPrefix: String
    public let forbiddenEnvironmentKeyPrefixes: [String]
    public let numericMode: String
    public let comparisonPolicy: String
    public let authorityCeiling: String
}

public enum PrimeNativeDecoderCIMLXComputeEnvironmentPolicyError:
    Error,
    Equatable,
    Sendable
{
    case forbiddenInheritedKey(String)
    case forbiddenLaunchedKey(String)
    case missingRequiredKey(String)
    case invalidRequiredValue(key: String, value: String?)
    case unexpectedExclusivePrefixKeys([String])
}

/// A synthetic CI-mechanics policy, not an admitted runtime policy.
///
/// The reviewed launcher must start without any MLX environment override and
/// introduce the one exact key before the first Metal or MLX call. This does
/// not weaken or replace `PrimeMLXRuntimeEnvironmentPolicy`, whose frozen V1
/// continues to reject every `MLX_` key for the maintained runtime boundary.
public enum PrimeNativeDecoderCIMLXComputeEnvironmentPolicy {
    public static let frozenV1 =
        PrimeNativeDecoderCIMLXComputeEnvironmentPolicyDeclaration(
            schemaVersion: 1,
            policyID:
                "ergentics_prime_native_decoder_ci_mlx_compute_environment",
            policyVersion: 1,
            scope:
                "trusted_main_exact_head_synthetic_decoder_metal_mechanics",
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
                "existing_test_specific_thresholds_no_global_tolerance_widening",
            authorityCeiling: "synthetic_ci_mechanics_only"
        )

    @discardableResult
    public static func validateInherited(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderCIMLXComputeEnvironmentPolicyDeclaration
    {
        let declaration = frozenV1
        if let key = environment.keys.sorted().first(where: { key in
            key.hasPrefix(declaration.exclusiveEnvironmentKeyPrefix)
                || declaration.forbiddenEnvironmentKeyPrefixes
                    .contains(where: key.hasPrefix)
        }) {
            throw PrimeNativeDecoderCIMLXComputeEnvironmentPolicyError
                .forbiddenInheritedKey(key)
        }
        return declaration
    }

    @discardableResult
    public static func validateLaunched(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderCIMLXComputeEnvironmentPolicyDeclaration
    {
        let declaration = frozenV1
        if let key = environment.keys.sorted().first(where: { key in
            declaration.forbiddenEnvironmentKeyPrefixes
                .contains(where: key.hasPrefix)
        }) {
            throw PrimeNativeDecoderCIMLXComputeEnvironmentPolicyError
                .forbiddenLaunchedKey(key)
        }

        guard let value = environment[declaration.requiredEnvironmentKey]
        else {
            throw PrimeNativeDecoderCIMLXComputeEnvironmentPolicyError
                .missingRequiredKey(declaration.requiredEnvironmentKey)
        }
        guard value == declaration.requiredEnvironmentValue else {
            throw PrimeNativeDecoderCIMLXComputeEnvironmentPolicyError
                .invalidRequiredValue(
                    key: declaration.requiredEnvironmentKey,
                    value: value)
        }
        let exclusiveKeys = environment.keys
            .filter {
                $0.hasPrefix(declaration.exclusiveEnvironmentKeyPrefix)
            }
            .sorted()
        guard exclusiveKeys == [declaration.requiredEnvironmentKey] else {
            throw PrimeNativeDecoderCIMLXComputeEnvironmentPolicyError
                .unexpectedExclusivePrefixKeys(exclusiveKeys)
        }
        return declaration
    }
}

public struct PrimeNativeDecoderMetalRepairObservation:
    Codable,
    Equatable,
    Sendable
{
    public let scopeID: String
    public let sourceState: String
    public let sourceIdentityComplete: Bool
    public let tf32Disposition: String
    public let batchedRoPERepairDisposition: String
    public let executedTestCount: Int
    public let failureCount: Int
    public let skipCount: Int
    public let logByteCount: Int
    public let logSHA256: String
    public let disposition: String
}

/// Append-only authority for a pinned-MLX Metal mechanics repair.
///
/// The frozen decoder, derived-delta, and checkpoint contracts remain exact
/// historical records. This successor binds the repaired source and an exact
/// synthetic-test compute policy. It does not establish a current checkpoint
/// identity, admitted runtime policy, training authority, or product use.
public struct PrimeNativeDecoderMetalRepairAuthorityPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let predecessorCheckpointAuthorityID: String
    public let predecessorsRemainFrozen: Bool
    public let historicalSourceRevision: String
    public let historicalDecoderSourcePath: String
    public let historicalDecoderSourceGitBlob: String
    public let historicalDecoderSourceByteCount: Int
    public let historicalDecoderSourceSHA256: String
    public let repairedDecoderSourcePath: String
    public let repairedDecoderSourceGitBlob: String
    public let repairedDecoderSourceGitMode: String
    public let repairedDecoderSourceByteCount: Int
    public let repairedDecoderSourceSHA256: String
    public let regressionTestSourcePath: String
    public let regressionTestSourceGitBlob: String
    public let regressionTestSourceGitMode: String
    public let regressionTestSourceByteCount: Int
    public let regressionTestSourceSHA256: String
    public let checkpointExecutionTestSourcePath: String
    public let checkpointExecutionTestSourceGitBlob: String
    public let checkpointExecutionTestSourceGitMode: String
    public let checkpointExecutionTestSourceByteCount: Int
    public let checkpointExecutionTestSourceSHA256: String
    public let authoritativeRepository: String
    public let authoritativeProduct: String
    public let authoritativeTarget: String
    public let authoritativeTargetDependencies: [String]
    public let authoritativeImplementationID: String
    public let architectureSchema: String
    public let parameterPathSchema: String
    public let exactMLXRevision: String
    public let exactMLXCoreRevision: String
    public let pinnedRoPESourcePath: String
    public let pinnedRoPESourceGitBlob: String
    public let pinnedRoPESourceByteCount: Int
    public let pinnedRoPESourceSHA256: String
    public let defectIntroducingUpstreamRevision: String
    public let upstreamRepairRevision: String
    public let defectID: String
    public let repairID: String
    public let repairScope: String
    public let ciMechanicsPolicy:
        PrimeNativeDecoderCIMLXComputeEnvironmentPolicyDeclaration
    public let ciMetalLauncherPath: String
    public let ciMetalLauncherGitBlob: String
    public let ciMetalLauncherGitMode: String
    public let ciMetalLauncherByteCount: Int
    public let ciMetalLauncherSHA256: String
    public let externalMetallibArtifactKind: String
    public let externalMetallibByteCount: Int
    public let externalMetallibSHA256: String
    public let externalMetallibFreshBuildProvenanceObserved: Bool
    public let orderedExternalObservations:
        [PrimeNativeDecoderMetalRepairObservation]
    public let parameterTopologyUnchanged: Bool
    public let repairImplementationPresent: Bool
    public let distinctRowRegressionPresent: Bool
    public let exactMechanicsPolicyEstablished: Bool
    public let allOtherMLXEnvironmentKeysRejected: Bool
    public let mechanicsPolicyAppliedBeforeFirstMLXCall: Bool
    public let externalWorkingTreeMetalDeviceObserved: Bool
    public let externalWorkingTreeAllExistingTestsObserved: Bool
    public let externalWorkingTreeFullSourceIdentityEstablished: Bool
    public let rawObservationLogsRetainedInRepository: Bool
    public let exactCommittedHeadMetalObserved: Bool
    public let githubHostedMetalObserved: Bool
    public let checkpointV1HistoricalIdentityPreserved: Bool
    public let currentCheckpointCompatibilityIdentityEstablished: Bool
    public let admittedRuntimeComputePolicyEstablished: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let native300MModelAllocationAuthorized: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
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
            "ergentics_prime_native_decoder_metal_repair_v1",
        predecessorCheckpointAuthorityID:
            PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1.authorityID,
        predecessorsRemainFrozen: true,
        historicalSourceRevision:
            "84504dc576603aa1c68f7d1a444b1e0e56fb29b0",
        historicalDecoderSourcePath:
            "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
        historicalDecoderSourceGitBlob:
            "55407cba9dbcc4e915b0994aed16f02c1da95e16",
        historicalDecoderSourceByteCount: 38_524,
        historicalDecoderSourceSHA256:
            "7e3e9c676225e7d600c5580cb3ae73a3d15fdeff12d0933e175b41923c370162",
        repairedDecoderSourcePath:
            "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
        repairedDecoderSourceGitBlob:
            "835a4826549e1f28ec27e3533f746218beb3bdf2",
        repairedDecoderSourceGitMode: "100644",
        repairedDecoderSourceByteCount: 39_050,
        repairedDecoderSourceSHA256:
            "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
        regressionTestSourcePath:
            "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeGQADecoderTests.swift",
        regressionTestSourceGitBlob:
            "0162a60c422de7d05abbdd6932420930adcd5813",
        regressionTestSourceGitMode: "100644",
        regressionTestSourceByteCount: 40_513,
        regressionTestSourceSHA256:
            "ee612ac7b02e759fdb556d1f29d4f1327da3d9bb39f6e20090a8d862b2a5c53f",
        checkpointExecutionTestSourcePath:
            "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderCheckpointTests.swift",
        checkpointExecutionTestSourceGitBlob:
            "375a9278d6fe82b7033c731a8e4f7d51c5cc96b5",
        checkpointExecutionTestSourceGitMode: "100644",
        checkpointExecutionTestSourceByteCount: 33_037,
        checkpointExecutionTestSourceSHA256:
            "97944a997a389e6ea79ba92f9be965bc66230064e171c51c9150f6b1080b9172",
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
        parameterPathSchema:
            "mlxnn_flattened_module_parameters_v1",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        exactMLXCoreRevision:
            "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
        pinnedRoPESourcePath:
            "Source/Cmlx/mlx/mlx/backend/metal/rope.cpp",
        pinnedRoPESourceGitBlob:
            "ca0a66221269b43f834a35d366027ab1ef27b921",
        pinnedRoPESourceByteCount: 4_953,
        pinnedRoPESourceSHA256:
            "c1d6d4952df627eb1a5a5b9faf0c32a4328d3032c4941ea82933d648e2592afd",
        defectIntroducingUpstreamRevision:
            "caecbe876a09b4d4cd1ceca64d7533e33555a974",
        upstreamRepairRevision:
            "76a977ca4ececef603cfdd242714df99fa0c6230",
        defectID:
            "pinned_mlx_scalar_offset_single_token_rope_dispatch_omits_batch_dimension",
        repairID:
            "prime_rectangular_batch_explicit_int32_rope_offsets_v1",
        repairScope:
            "prime_local_mechanics_workaround_no_mlx_pin_change",
        ciMechanicsPolicy:
            PrimeNativeDecoderCIMLXComputeEnvironmentPolicy.frozenV1,
        ciMetalLauncherPath:
            ".github/scripts/prime-ci-native-decoder-metal.sh",
        ciMetalLauncherGitBlob:
            "418d2d2753cee38e0b3558ad45e1e09865ffd11d",
        ciMetalLauncherGitMode: "100755",
        ciMetalLauncherByteCount: 11_793,
        ciMetalLauncherSHA256:
            "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff",
        externalMetallibArtifactKind:
            "external_prebuilt_exact_pinned_mlx_default_metallib",
        externalMetallibByteCount: 3_817_916,
        externalMetallibSHA256:
            "24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b",
        externalMetallibFreshBuildProvenanceObserved: false,
        orderedExternalObservations: [
            PrimeNativeDecoderMetalRepairObservation(
                scopeID: "exact_head_default_tf32_baseline",
                sourceState:
                    "ergentics_prime_at_84504dc576603aa1c68f7d1a444b1e0e56fb29b0",
                sourceIdentityComplete: true,
                tf32Disposition: "pinned_mlx_default_enabled",
                batchedRoPERepairDisposition: "absent",
                executedTestCount: 41,
                failureCount: 306,
                skipCount: 0,
                logByteCount: 143_350,
                logSHA256:
                    "77bbf845cb5042f0074e615b76f9a26ec1d314a254386bb99d7ae22785024f30",
                disposition:
                    "failed_scalar_single_batch_and_rectangular_batch_parity"
            ),
            PrimeNativeDecoderMetalRepairObservation(
                scopeID: "exact_head_tf32_disabled_discriminator",
                sourceState:
                    "ergentics_prime_at_84504dc576603aa1c68f7d1a444b1e0e56fb29b0",
                sourceIdentityComplete: true,
                tf32Disposition: "explicitly_disabled",
                batchedRoPERepairDisposition: "absent",
                executedTestCount: 41,
                failureCount: 96,
                skipCount: 0,
                logByteCount: 54_008,
                logSHA256:
                    "f3d83b9c0866bdc12f03e87f3d000413e3424f0f93768cd0e8d9f4500a13ac70",
                disposition:
                    "passed_scalar_and_single_batch_failed_rectangular_batch_parity"
            ),
            PrimeNativeDecoderMetalRepairObservation(
                scopeID: "repair_worktree_tf32_disabled",
                sourceState:
                    "uncommitted_decoder_blob_835a4826549e1f28ec27e3533f746218beb3bdf2_incomplete_test_source_identity_before_distinct_row_strengthening",
                sourceIdentityComplete: false,
                tf32Disposition: "explicitly_disabled",
                batchedRoPERepairDisposition: "present",
                executedTestCount: 41,
                failureCount: 0,
                skipCount: 0,
                logByteCount: 12_678,
                logSHA256:
                    "97e039894ddfc0350e8e7f2fa864379bd4f455a6a79616cb1c61188285952edd",
                disposition:
                    "all_existing_synthetic_mechanics_tests_passed_on_external_live_metal"
            ),
        ],
        parameterTopologyUnchanged: true,
        repairImplementationPresent: true,
        distinctRowRegressionPresent: true,
        exactMechanicsPolicyEstablished: true,
        allOtherMLXEnvironmentKeysRejected: true,
        mechanicsPolicyAppliedBeforeFirstMLXCall: true,
        externalWorkingTreeMetalDeviceObserved: true,
        externalWorkingTreeAllExistingTestsObserved: true,
        externalWorkingTreeFullSourceIdentityEstablished: false,
        rawObservationLogsRetainedInRepository: false,
        exactCommittedHeadMetalObserved: false,
        githubHostedMetalObserved: false,
        checkpointV1HistoricalIdentityPreserved: true,
        currentCheckpointCompatibilityIdentityEstablished: false,
        admittedRuntimeComputePolicyEstablished: false,
        runtimeDependencyClosureEstablished: false,
        runtimeInitializationEstablished: false,
        native300MModelAllocationAuthorized: false,
        native300MCheckpointWriteAuthorized: false,
        native300MCheckpointLoadAuthorized: false,
        functionalTrainingAuthorized: false,
        longTrainingAuthorized: false,
        candidateAdmissionGranted: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        status:
            "ABSTAIN_repair_worktree_mechanics_observed_exact_head_checkpoint_runtime_and_training_unestablished",
        orderedNextActions: [
            "run_exact_clean_head_live_metal_gate",
            "observe_github_hosted_live_metal_gate",
            "append_repaired_checkpoint_compatibility_identity",
            "append_admitted_runtime_compute_policy",
            "define_prime_owned_train_and_evaluate_surfaces",
            "persist_exact_optimizer_rng_and_data_cursor_state",
            "request_separate_bounded_training_authorization",
        ]
    )

    public func validate() throws {
        let expected = Self.frozenV1
        let checkpoint = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
        let derived = PrimeNativeDecoderDerivedDeltaPlan.frozenV1

        guard self == expected,
              schemaVersion == 1,
              predecessorCheckpointAuthorityID == checkpoint.authorityID,
              predecessorsRemainFrozen,
              checkpoint.predecessorAuthorityID == derived.authorityID,
              historicalSourceRevision.utf8.count == 40,
              historicalSourceRevision.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              historicalDecoderSourcePath == repairedDecoderSourcePath,
              historicalDecoderSourceGitBlob
                == checkpoint.decoderSourceGitBlob,
              historicalDecoderSourceByteCount
                == checkpoint.decoderSourceByteCount,
              historicalDecoderSourceSHA256
                == checkpoint.decoderSourceSHA256,
              repairedDecoderSourceGitBlob.utf8.count == 40,
              repairedDecoderSourceGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              repairedDecoderSourceGitMode == "100644",
              repairedDecoderSourceByteCount > 0,
              repairedDecoderSourceSHA256.utf8.count == 64,
              repairedDecoderSourceSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              regressionTestSourceGitBlob.utf8.count == 40,
              regressionTestSourceGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              regressionTestSourceGitMode == "100644",
              regressionTestSourceByteCount > 0,
              regressionTestSourceSHA256.utf8.count == 64,
              regressionTestSourceSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              checkpointExecutionTestSourceGitBlob.utf8.count == 40,
              checkpointExecutionTestSourceGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              checkpointExecutionTestSourceGitMode == "100644",
              checkpointExecutionTestSourceByteCount > 0,
              checkpointExecutionTestSourceSHA256.utf8.count == 64,
              checkpointExecutionTestSourceSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              authoritativeRepository == derived.authoritativeRepository,
              authoritativeProduct == derived.authoritativeProduct,
              authoritativeTarget == derived.authoritativeTarget,
              authoritativeTargetDependencies
                == derived.authoritativeTargetDependencies,
              authoritativeImplementationID
                == derived.authoritativeImplementationID,
              architectureSchema == derived.architectureSchema,
              parameterPathSchema
                == checkpoint.parameterPathSchema,
              exactMLXRevision == derived.exactMLXRevision,
              exactMLXCoreRevision.utf8.count == 40,
              exactMLXCoreRevision.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              pinnedRoPESourceGitBlob.utf8.count == 40,
              pinnedRoPESourceGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              pinnedRoPESourceByteCount == 4_953,
              pinnedRoPESourceSHA256.utf8.count == 64,
              pinnedRoPESourceSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              defectIntroducingUpstreamRevision.utf8.count == 40,
              defectIntroducingUpstreamRevision.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              upstreamRepairRevision.utf8.count == 40,
              upstreamRepairRevision.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              repairedDecoderSourceGitBlob
                != historicalDecoderSourceGitBlob,
              repairedDecoderSourceSHA256
                != historicalDecoderSourceSHA256,
              ciMechanicsPolicy
                == PrimeNativeDecoderCIMLXComputeEnvironmentPolicy.frozenV1,
              ciMechanicsPolicy.exactMLXRevision == exactMLXRevision,
              ciMechanicsPolicy.requiredEnvironmentKey
                == "MLX_ENABLE_TF32",
              ciMechanicsPolicy.requiredEnvironmentValue == "0",
              ciMetalLauncherPath
                == ".github/scripts/prime-ci-native-decoder-metal.sh",
              ciMetalLauncherGitBlob.utf8.count == 40,
              ciMetalLauncherGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              ciMetalLauncherGitMode == "100755",
              ciMetalLauncherByteCount > 0,
              ciMetalLauncherSHA256.utf8.count == 64,
              ciMetalLauncherSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              externalMetallibArtifactKind.hasPrefix(
                  "external_prebuilt_"),
              externalMetallibByteCount == 3_817_916,
              externalMetallibSHA256.utf8.count == 64,
              externalMetallibSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderRepairLowercaseHex),
              !externalMetallibFreshBuildProvenanceObserved,
              orderedExternalObservations.count == 3,
              orderedExternalObservations.allSatisfy({ observation in
                  observation.executedTestCount == 41
                    && observation.failureCount >= 0
                    && observation.skipCount == 0
                    && observation.logByteCount > 0
                    && observation.logSHA256.utf8.count == 64
                    && observation.logSHA256.utf8.allSatisfy(
                        isPrimeNativeDecoderRepairLowercaseHex)
              }),
              orderedExternalObservations.map(\.failureCount)
                == [306, 96, 0],
              orderedExternalObservations.map(\.sourceIdentityComplete)
                == [true, true, false],
              parameterTopologyUnchanged,
              repairImplementationPresent,
              distinctRowRegressionPresent,
              exactMechanicsPolicyEstablished,
              allOtherMLXEnvironmentKeysRejected,
              mechanicsPolicyAppliedBeforeFirstMLXCall,
              externalWorkingTreeMetalDeviceObserved,
              externalWorkingTreeAllExistingTestsObserved,
              !externalWorkingTreeFullSourceIdentityEstablished,
              !rawObservationLogsRetainedInRepository,
              !exactCommittedHeadMetalObserved,
              !githubHostedMetalObserved,
              checkpointV1HistoricalIdentityPreserved,
              !currentCheckpointCompatibilityIdentityEstablished,
              !admittedRuntimeComputePolicyEstablished,
              !runtimeDependencyClosureEstablished,
              !runtimeInitializationEstablished,
              !native300MModelAllocationAuthorized,
              !native300MCheckpointWriteAuthorized,
              !native300MCheckpointLoadAuthorized,
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
                == "run_exact_clean_head_live_metal_gate",
              orderedNextActions.last
                == "request_separate_bounded_training_authorization"
        else {
            throw PrimeNativeDecoderMetalRepairAuthorityError
                .contractDrift
        }
    }
}

private func isPrimeNativeDecoderRepairLowercaseHex(
    _ byte: UInt8
) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
