// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderMetalExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Append-only observation of the repaired decoder's exact committed-source
/// synthetic mechanics on an external live-Metal process.
///
/// This observation succeeds the repair authority without rewriting it. The
/// test bundle was rebuilt from the exact clean commit in the shared checkout,
/// but no independently published binary-provenance envelope or fresh
/// metallib-build receipt exists. Consequently this is not an admitted runtime
/// policy, checkpoint identity, training authorization, or product decision.
public struct PrimeNativeDecoderMetalExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let predecessorRepairAuthorityID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorRepairAuthoritySourcePath: String
    public let predecessorRepairAuthoritySourceGitBlob: String
    public let predecessorRepairAuthoritySourceByteCount: Int
    public let predecessorRepairAuthoritySourceSHA256: String
    public let authoritativeRepository: String
    public let observedRevision: String
    public let observedParentRevision: String
    public let observedTree: String
    public let observedEmbeddedSourceIdentitySHA256: String
    public let observedRevisionPublishedToOriginObserved: Bool
    public let executionBindingKind: String
    public let rawLogAloneBindsRevisionOrTree: Bool
    public let attachmentAloneBindsRevisionOrTree: Bool
    public let externalCommandSequence: [String]
    public let exactHeadAndCleanGateSequenceCompleted: Bool
    public let activeRootQuarantineGateCompleted: Bool
    public let latinProvenanceGateCompleted: Bool
    public let exactObservedTreeAndEmbeddedSourceIdentityBound: Bool
    public let testBundleRebuiltFromObservedCheckout: Bool
    public let testBundleBinaryProvenancePublished: Bool
    public let ciMechanicsPolicy:
        PrimeNativeDecoderCIMLXComputeEnvironmentPolicyDeclaration
    public let inProcessMechanicsPolicyPreflightObserved: Bool
    public let externalMetallibArtifactKind: String
    public let externalMetallibByteCount: Int
    public let externalMetallibSHA256: String
    public let externalMetallibFreshBuildProvenanceObserved: Bool
    public let testBundleRelativePath: String
    public let executedAuthorityTestCount: Int
    public let executedCheckpointTestCount: Int
    public let executedDecoderTestCount: Int
    public let executedTotalTestCount: Int
    public let failureCount: Int
    public let unexpectedFailureCount: Int
    public let skipCount: Int
    public let allStrengthenedRegressionsPassed: Bool
    public let rawTerminalLogArtifactKind: String
    public let rawTerminalLogByteCount: Int
    public let rawTerminalLogSHA256: String
    public let attachmentTransportID: String
    public let attachmentTransportName: String
    public let attachmentTransportByteCount: Int
    public let attachmentTransportSHA256: String
    public let attachmentTransportNormalization: String
    public let attachmentCommonPrefixByteCount: Int
    public let rawTerminalLogFinalByteHex: String
    public let attachmentHasNoOtherTransportMutation: Bool
    public let rawObservationLogRetainedInRepository: Bool
    public let attachmentTransportRetainedInRepository: Bool
    public let exactCommittedHeadMetalMechanicsObserved: Bool
    public let metalDeviceObserved: Bool
    public let metalDeviceIdentityRecorded: Bool
    public let modelInitializationObserved: Bool
    public let forwardExecutionObserved: Bool
    public let gqaScalarParityObserved: Bool
    public let batchedRoPERegressionObserved: Bool
    public let cacheParityObserved: Bool
    public let gradientExecutionObserved: Bool
    public let syntheticCheckpointRoundTripObserved: Bool
    public let checkpointFailurePathsObserved: Bool
    public let githubHostedMetalObserved: Bool
    public let checkpointV1HistoricalIdentityPreserved: Bool
    public let repairedCheckpointCompatibilityIdentityEstablished: Bool
    public let admittedRuntimeComputePolicyEstablished: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let native300MModelAllocationAuthorized: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let trainingResumeEstablished: Bool
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
        observationID:
            "ergentics_prime_native_decoder_external_metal_execution_v1",
        predecessorRepairAuthorityID:
            PrimeNativeDecoderMetalRepairAuthorityPlan.frozenV1.authorityID,
        predecessorRemainsFrozen: true,
        predecessorRepairAuthoritySourcePath:
            "Sources/PrimeCore/PrimeNativeDecoderMetalRepairAuthority.swift",
        predecessorRepairAuthoritySourceGitBlob:
            "f284cb6d9bfdd37add9273f3e0eecd69e13cd134",
        predecessorRepairAuthoritySourceByteCount: 26_865,
        predecessorRepairAuthoritySourceSHA256:
            "5e88a1a191f94daac01f86e5dbad48ebfcdd50957ac17acf6f404ac8dd0a97ac",
        authoritativeRepository: "Ergentics/ergentics-prime",
        observedRevision:
            "8e5d1555506a824d19528fb8dd3e115eb8aefb41",
        observedParentRevision:
            "84504dc576603aa1c68f7d1a444b1e0e56fb29b0",
        observedTree:
            "3549dd0f2e476bc7ff1d40d8097942463e52be2a",
        observedEmbeddedSourceIdentitySHA256:
            "298d0bffa5bc25a29d4b8d4655d00c886bf42e57130b8b43f7e18b60a38a3364",
        observedRevisionPublishedToOriginObserved: false,
        executionBindingKind:
            "user_terminal_silent_exact_head_tree_clean_preconditions_plus_raw_xctest_log",
        rawLogAloneBindsRevisionOrTree: false,
        attachmentAloneBindsRevisionOrTree: false,
        externalCommandSequence: [
            "prime_ci_active_root_quarantine_exact_clean_head",
            "prime_ci_latin_proposal_pair_capture_exact_clean_head",
            "direct_xcrun_xctest_exact_rebuilt_bundle",
        ],
        exactHeadAndCleanGateSequenceCompleted: true,
        activeRootQuarantineGateCompleted: true,
        latinProvenanceGateCompleted: true,
        exactObservedTreeAndEmbeddedSourceIdentityBound: true,
        testBundleRebuiltFromObservedCheckout: true,
        testBundleBinaryProvenancePublished: false,
        ciMechanicsPolicy:
            PrimeNativeDecoderCIMLXComputeEnvironmentPolicy.frozenV1,
        inProcessMechanicsPolicyPreflightObserved: true,
        externalMetallibArtifactKind:
            "external_prebuilt_exact_pinned_mlx_default_metallib",
        externalMetallibByteCount: 3_817_916,
        externalMetallibSHA256:
            "24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b",
        externalMetallibFreshBuildProvenanceObserved: false,
        testBundleRelativePath:
            ".build/prime-native-decoder-validation/arm64-apple-macosx/debug/PrimeNativeDecoderValidationPackageTests.xctest",
        executedAuthorityTestCount: 11,
        executedCheckpointTestCount: 14,
        executedDecoderTestCount: 19,
        executedTotalTestCount: 44,
        failureCount: 0,
        unexpectedFailureCount: 0,
        skipCount: 0,
        allStrengthenedRegressionsPassed: true,
        rawTerminalLogArtifactKind:
            "external_terminal_xctest_stdout_with_trailing_lf",
        rawTerminalLogByteCount: 13_556,
        rawTerminalLogSHA256:
            "0c4c8b1b40433cf391bdc49795dc8711ca3d9138a2e9b5ce6ccb7db9b6aeb431",
        attachmentTransportID:
            "98cf209a-ca11-462b-91c7-ecac76370833",
        attachmentTransportName: "pasted-text.txt",
        attachmentTransportByteCount: 13_555,
        attachmentTransportSHA256:
            "09bd17943f38ae9f33485dc9b44c9c6bf9e42880ce79df5fec7ce0a18c16f7b6",
        attachmentTransportNormalization:
            "removed_exactly_one_final_line_feed_from_raw_terminal_log",
        attachmentCommonPrefixByteCount: 13_555,
        rawTerminalLogFinalByteHex: "0a",
        attachmentHasNoOtherTransportMutation: true,
        rawObservationLogRetainedInRepository: false,
        attachmentTransportRetainedInRepository: false,
        exactCommittedHeadMetalMechanicsObserved: true,
        metalDeviceObserved: true,
        metalDeviceIdentityRecorded: false,
        modelInitializationObserved: true,
        forwardExecutionObserved: true,
        gqaScalarParityObserved: true,
        batchedRoPERegressionObserved: true,
        cacheParityObserved: true,
        gradientExecutionObserved: true,
        syntheticCheckpointRoundTripObserved: true,
        checkpointFailurePathsObserved: true,
        githubHostedMetalObserved: false,
        checkpointV1HistoricalIdentityPreserved: true,
        repairedCheckpointCompatibilityIdentityEstablished: false,
        admittedRuntimeComputePolicyEstablished: false,
        runtimeDependencyClosureEstablished: false,
        runtimeInitializationEstablished: false,
        native300MModelAllocationAuthorized: false,
        native300MCheckpointWriteAuthorized: false,
        native300MCheckpointLoadAuthorized: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointAdmissionGranted: false,
        trainingResumeEstablished: false,
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
            "ABSTAIN_exact_committed_head_external_metal_mechanics_observed_repaired_checkpoint_runtime_and_training_unestablished",
        orderedNextActions: [
            "observe_github_hosted_fresh_metallib_live_metal_gate_after_separately_authorized_publication",
            "append_repaired_checkpoint_compatibility_identity",
            "append_admitted_runtime_compute_policy",
            "define_prime_owned_train_and_evaluate_surfaces",
            "persist_exact_optimizer_rng_and_data_cursor_state",
            "request_separate_bounded_training_authorization",
        ]
    )

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let predecessor =
            PrimeNativeDecoderMetalRepairAuthorityPlan.frozenV1

        guard self == expected,
              schemaVersion == 1,
              predecessorRepairAuthorityID == predecessor.authorityID,
              predecessorRemainsFrozen,
              predecessorRepairAuthoritySourceGitBlob.utf8.count == 40,
              predecessorRepairAuthoritySourceGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionLowercaseHex),
              predecessorRepairAuthoritySourceByteCount == 26_865,
              predecessorRepairAuthoritySourceSHA256.utf8.count == 64,
              predecessorRepairAuthoritySourceSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionLowercaseHex),
              authoritativeRepository == predecessor.authoritativeRepository,
              observedRevision.utf8.count == 40,
              observedRevision.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionLowercaseHex),
              observedParentRevision.utf8.count == 40,
              observedParentRevision.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionLowercaseHex),
              observedTree.utf8.count == 40,
              observedTree.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionLowercaseHex),
              observedEmbeddedSourceIdentitySHA256.utf8.count == 64,
              observedEmbeddedSourceIdentitySHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionLowercaseHex),
              !observedRevisionPublishedToOriginObserved,
              executionBindingKind.hasPrefix("user_terminal_"),
              !rawLogAloneBindsRevisionOrTree,
              !attachmentAloneBindsRevisionOrTree,
              externalCommandSequence == [
                  "prime_ci_active_root_quarantine_exact_clean_head",
                  "prime_ci_latin_proposal_pair_capture_exact_clean_head",
                  "direct_xcrun_xctest_exact_rebuilt_bundle",
              ],
              exactHeadAndCleanGateSequenceCompleted,
              activeRootQuarantineGateCompleted,
              latinProvenanceGateCompleted,
              exactObservedTreeAndEmbeddedSourceIdentityBound,
              testBundleRebuiltFromObservedCheckout,
              !testBundleBinaryProvenancePublished,
              ciMechanicsPolicy == predecessor.ciMechanicsPolicy,
              inProcessMechanicsPolicyPreflightObserved,
              externalMetallibArtifactKind
                == predecessor.externalMetallibArtifactKind,
              externalMetallibByteCount
                == predecessor.externalMetallibByteCount,
              externalMetallibSHA256
                == predecessor.externalMetallibSHA256,
              !externalMetallibFreshBuildProvenanceObserved,
              executedAuthorityTestCount == 11,
              executedCheckpointTestCount == 14,
              executedDecoderTestCount == 19,
              executedAuthorityTestCount
                + executedCheckpointTestCount
                + executedDecoderTestCount == executedTotalTestCount,
              executedTotalTestCount == 44,
              failureCount == 0,
              unexpectedFailureCount == 0,
              skipCount == 0,
              allStrengthenedRegressionsPassed,
              rawTerminalLogByteCount == attachmentTransportByteCount + 1,
              rawTerminalLogSHA256.utf8.count == 64,
              rawTerminalLogSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionLowercaseHex),
              attachmentTransportSHA256.utf8.count == 64,
              attachmentTransportSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionLowercaseHex),
              attachmentTransportID.utf8.count == 36,
              attachmentTransportName == "pasted-text.txt",
              attachmentTransportNormalization.hasPrefix("removed_exactly_"),
              attachmentCommonPrefixByteCount
                == attachmentTransportByteCount,
              rawTerminalLogFinalByteHex == "0a",
              attachmentHasNoOtherTransportMutation,
              !rawObservationLogRetainedInRepository,
              !attachmentTransportRetainedInRepository,
              exactCommittedHeadMetalMechanicsObserved,
              metalDeviceObserved,
              !metalDeviceIdentityRecorded,
              modelInitializationObserved,
              forwardExecutionObserved,
              gqaScalarParityObserved,
              batchedRoPERegressionObserved,
              cacheParityObserved,
              gradientExecutionObserved,
              syntheticCheckpointRoundTripObserved,
              checkpointFailurePathsObserved,
              !githubHostedMetalObserved,
              checkpointV1HistoricalIdentityPreserved,
              !repairedCheckpointCompatibilityIdentityEstablished,
              !admittedRuntimeComputePolicyEstablished,
              !runtimeDependencyClosureEstablished,
              !runtimeInitializationEstablished,
              !native300MModelAllocationAuthorized,
              !native300MCheckpointWriteAuthorized,
              !native300MCheckpointLoadAuthorized,
              !checkpointArtifactProvenanceEstablished,
              !checkpointAdmissionGranted,
              !trainingResumeEstablished,
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
                == "observe_github_hosted_fresh_metallib_live_metal_gate_after_separately_authorized_publication",
              orderedNextActions.last
                == "request_separate_bounded_training_authorization"
        else {
            throw PrimeNativeDecoderMetalExecutionObservationError
                .contractDrift
        }
    }
}

private func isPrimeNativeDecoderExecutionLowercaseHex(
    _ byte: UInt8
) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
