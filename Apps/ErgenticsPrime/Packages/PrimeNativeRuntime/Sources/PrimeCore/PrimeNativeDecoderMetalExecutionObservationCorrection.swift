// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderMetalExecutionObservationCorrectionError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Append-only epistemic correction to the first external Metal observation.
///
/// The exact 44/44 XCTest result remains valid. The predecessor's active-root
/// completion claim does not: its fixed-substring `Process` scan included the
/// validation sources that necessarily inspect `ProcessInfo` before Metal or
/// MLX access. This correction preserves the predecessor bytes while making
/// the two contradicted gate-sequence claims unusable by downstream consumers.
public struct PrimeNativeDecoderMetalExecutionObservationCorrectionV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let correctionID: String
    public let correctionKind: String
    public let predecessorObservationID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorStandaloneConsumptionAllowed: Bool
    public let correctionRequiredForConsumption: Bool
    public let predecessorObservationSourcePath: String
    public let predecessorObservationSourceGitBlob: String
    public let predecessorObservationSourceGitMode: String
    public let predecessorObservationSourceByteCount: Int
    public let predecessorObservationSourceSHA256: String
    public let authoritativeRepository: String
    public let correctedObservedRevision: String
    public let correctedObservedParentRevision: String
    public let correctedObservedTree: String
    public let correctedObservedSourceIdentitySHA256: String
    public let discoveryRevision: String
    public let discoveryTree: String
    public let historicalGatePath: String
    public let historicalGateGitBlob: String
    public let historicalGateGitMode: String
    public let historicalGateByteCount: Int
    public let historicalGateSHA256: String
    public let discoveryGateGitBlob: String
    public let discoveryGateGitMode: String
    public let discoveryGateByteCount: Int
    public let discoveryGateSHA256: String
    public let contradictedMatcherKind: String
    public let contradictedNeedle: String
    public let correctedMatcherERE: String
    public let historicalValidationWitnessPaths: [String]
    public let historicalValidationWitnessGitBlobs: [String]
    public let historicalValidationWitnessNeedle: String
    public let historicalProductionNeedleMatchCount: Int
    public let historicalStandaloneProcessSymbolMatchCount: Int
    public let foundationProcessConstructionObserved: Bool
    public let subprocessExecutionObserved: Bool
    public let historicalActiveRootGateSuccessPossible: Bool
    public let discoveryPullRequestNumber: Int
    public let discoveryWorkflowRunIDs: [Int]
    public let discoveryWorkflowJobIDs: [Int]
    public let discoveryWorkflowName: String
    public let discoveryJobName: String
    public let discoveryFailureStepName: String
    public let discoveryFailureMessage: String
    public let discoveryRunsBoundToExactHead: Bool
    public let discoveryFailureLogsRetainedInRepository: Bool
    public let invalidatedPredecessorClaimNames: [String]
    public let activeRootQuarantineGateCompleted: Bool
    public let exactHeadAndCleanGateSequenceCompleted: Bool
    public let latinProvenanceGateClaimDisposition: String
    public let predecessorMetalMechanicsProjectionRetained: Bool
    public let retainedAuthorityTestCount: Int
    public let retainedCheckpointTestCount: Int
    public let retainedDecoderTestCount: Int
    public let retainedTotalTestCount: Int
    public let retainedFailureCount: Int
    public let retainedUnexpectedFailureCount: Int
    public let retainedSkipCount: Int
    public let retainedRawTerminalLogByteCount: Int
    public let retainedRawTerminalLogSHA256: String
    public let retainedAttachmentByteCount: Int
    public let retainedAttachmentSHA256: String
    public let retainedExternalMetallibByteCount: Int
    public let retainedExternalMetallibSHA256: String
    public let retainedExternalMetallibFreshBuildProvenanceObserved: Bool
    public let inProcessMechanicsPolicyPreflightObserved: Bool
    public let testBundleBinaryProvenancePublished: Bool
    public let exactCommittedHeadMetalMechanicsObserved: Bool
    public let allStrengthenedRegressionsPassed: Bool
    public let gateRepairScope: String
    public let standaloneProcessSymbolRemainsForbiddenAcrossClosure: Bool
    public let validationProcessInfoEnvironmentInspectionAllowed: Bool
    public let allOtherForbiddenChecksRemainUnchanged: Bool
    public let decoderMutationAuthorized: Bool
    public let checkpointMutationAuthorized: Bool
    public let isolatedDecoderValidationTestMutationAuthorized: Bool
    public let existingRootProvenanceTestMethodExtensionAuthorized: Bool
    public let metalLauncherMutationAuthorized: Bool
    public let workflowTopologyMutationAuthorized: Bool
    public let driverV2MutationAuthorized: Bool
    public let rootTestInventoryMutationAuthorized: Bool
    public let gateRepairExecutionObserved: Bool
    public let githubHostedMetalObserved: Bool
    public let freshMetallibBuildProvenanceObserved: Bool
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
        correctionID:
            "ergentics_prime_native_decoder_external_metal_execution_observation_correction_v1",
        correctionKind: "append_only_epistemic_narrowing",
        predecessorObservationID:
            PrimeNativeDecoderMetalExecutionObservationV1.frozenV1
                .observationID,
        predecessorRemainsFrozen: true,
        predecessorStandaloneConsumptionAllowed: false,
        correctionRequiredForConsumption: true,
        predecessorObservationSourcePath:
            "Sources/PrimeCore/PrimeNativeDecoderMetalExecutionObservation.swift",
        predecessorObservationSourceGitBlob:
            "39e37fc4dd7e2b6131ce0efc790b49602a94f484",
        predecessorObservationSourceGitMode: "100644",
        predecessorObservationSourceByteCount: 17_488,
        predecessorObservationSourceSHA256:
            "d132edeb434423e1f2c391258e7f0a502f872c53097b3a9a7db7780007a91306",
        authoritativeRepository: "Ergentics/ergentics-prime",
        correctedObservedRevision:
            "8e5d1555506a824d19528fb8dd3e115eb8aefb41",
        correctedObservedParentRevision:
            "84504dc576603aa1c68f7d1a444b1e0e56fb29b0",
        correctedObservedTree:
            "3549dd0f2e476bc7ff1d40d8097942463e52be2a",
        correctedObservedSourceIdentitySHA256:
            "298d0bffa5bc25a29d4b8d4655d00c886bf42e57130b8b43f7e18b60a38a3364",
        discoveryRevision:
            "ee5ed4276203b2c1eb299fa4eb17292de604e25d",
        discoveryTree:
            "2eb1f0c383f559b73133c832b17bde2622595aa3",
        historicalGatePath:
            ".github/scripts/prime-ci-active-root-quarantine.sh",
        historicalGateGitBlob:
            "391c0720fba56a32864c2e42edcf4d22ec11a5bc",
        historicalGateGitMode: "100755",
        historicalGateByteCount: 30_071,
        historicalGateSHA256:
            "d7ca063c5e9cde9e3729309920a0d3b2a9b6a9a9544ac9b552342b52d84aeafb",
        discoveryGateGitBlob:
            "3d6702a13a91f83122c28dfaaab23511e18a94a6",
        discoveryGateGitMode: "100755",
        discoveryGateByteCount: 31_258,
        discoveryGateSHA256:
            "d422da071e258e6bcc9e8afb178303a2489ea02a4d19bdccf5d03035844e38e7",
        contradictedMatcherKind: "grep_fixed_literal_substring",
        contradictedNeedle: "Process",
        correctedMatcherERE:
            "(^|[^[:alnum:]_])Process([^[:alnum:]_]|$)",
        historicalValidationWitnessPaths: [
            "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderCheckpointTests.swift",
            "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeGQADecoderTests.swift",
        ],
        historicalValidationWitnessGitBlobs: [
            "375a9278d6fe82b7033c731a8e4f7d51c5cc96b5",
            "0162a60c422de7d05abbdd6932420930adcd5813",
        ],
        historicalValidationWitnessNeedle:
            "ProcessInfo.processInfo.environment",
        historicalProductionNeedleMatchCount: 0,
        historicalStandaloneProcessSymbolMatchCount: 0,
        foundationProcessConstructionObserved: false,
        subprocessExecutionObserved: false,
        historicalActiveRootGateSuccessPossible: false,
        discoveryPullRequestNumber: 69,
        discoveryWorkflowRunIDs: [
            31_357_534_444,
            31_357_549_264,
        ],
        discoveryWorkflowJobIDs: [
            93_359_935_073,
            93_359_980_921,
        ],
        discoveryWorkflowName: "Prime active-root quarantine",
        discoveryJobName: "First-party MLX / active-root quarantine",
        discoveryFailureStepName:
            "Validate active metadata and preserved history",
        discoveryFailureMessage:
            "PrimeNativeDecoder closure contains forbidden value: Process",
        discoveryRunsBoundToExactHead: true,
        discoveryFailureLogsRetainedInRepository: false,
        invalidatedPredecessorClaimNames: [
            "exactHeadAndCleanGateSequenceCompleted",
            "activeRootQuarantineGateCompleted",
        ],
        activeRootQuarantineGateCompleted: false,
        exactHeadAndCleanGateSequenceCompleted: false,
        latinProvenanceGateClaimDisposition:
            "not_re_adjudicated_by_this_correction",
        predecessorMetalMechanicsProjectionRetained: true,
        retainedAuthorityTestCount: 11,
        retainedCheckpointTestCount: 14,
        retainedDecoderTestCount: 19,
        retainedTotalTestCount: 44,
        retainedFailureCount: 0,
        retainedUnexpectedFailureCount: 0,
        retainedSkipCount: 0,
        retainedRawTerminalLogByteCount: 13_556,
        retainedRawTerminalLogSHA256:
            "0c4c8b1b40433cf391bdc49795dc8711ca3d9138a2e9b5ce6ccb7db9b6aeb431",
        retainedAttachmentByteCount: 13_555,
        retainedAttachmentSHA256:
            "09bd17943f38ae9f33485dc9b44c9c6bf9e42880ce79df5fec7ce0a18c16f7b6",
        retainedExternalMetallibByteCount: 3_817_916,
        retainedExternalMetallibSHA256:
            "24d4cfcd3ca8b15ead691e46219f35adabbea64c9f8de4eae9bf293fd8d5eb7b",
        retainedExternalMetallibFreshBuildProvenanceObserved: false,
        inProcessMechanicsPolicyPreflightObserved: true,
        testBundleBinaryProvenancePublished: false,
        exactCommittedHeadMetalMechanicsObserved: true,
        allStrengthenedRegressionsPassed: true,
        gateRepairScope:
            "active_root_process_token_lexical_scope_only",
        standaloneProcessSymbolRemainsForbiddenAcrossClosure: true,
        validationProcessInfoEnvironmentInspectionAllowed: true,
        allOtherForbiddenChecksRemainUnchanged: true,
        decoderMutationAuthorized: false,
        checkpointMutationAuthorized: false,
        isolatedDecoderValidationTestMutationAuthorized: false,
        existingRootProvenanceTestMethodExtensionAuthorized: true,
        metalLauncherMutationAuthorized: false,
        workflowTopologyMutationAuthorized: false,
        driverV2MutationAuthorized: false,
        rootTestInventoryMutationAuthorized: false,
        gateRepairExecutionObserved: false,
        githubHostedMetalObserved: false,
        freshMetallibBuildProvenanceObserved: false,
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
            "ABSTAIN_external_metal_xctest_mechanics_retained_active_root_gate_sequence_corrected_and_unobserved",
        orderedNextActions: [
            "run_exact_clean_successor_active_root_and_latin_gates",
            "append_exact_successor_gate_observation",
            "observe_github_hosted_fresh_metallib_live_metal_gate_after_reviewed_main",
        ]
    )

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let predecessor =
            PrimeNativeDecoderMetalExecutionObservationV1.frozenV1

        guard self == expected,
              schemaVersion == 1,
              correctionKind == "append_only_epistemic_narrowing",
              predecessorObservationID == predecessor.observationID,
              predecessorRemainsFrozen,
              !predecessorStandaloneConsumptionAllowed,
              correctionRequiredForConsumption,
              predecessorObservationSourceGitBlob.utf8.count == 40,
              predecessorObservationSourceGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionCorrectionLowercaseHex),
              predecessorObservationSourceGitMode == "100644",
              predecessorObservationSourceByteCount == 17_488,
              predecessorObservationSourceSHA256.utf8.count == 64,
              predecessorObservationSourceSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionCorrectionLowercaseHex),
              authoritativeRepository == predecessor.authoritativeRepository,
              correctedObservedRevision == predecessor.observedRevision,
              correctedObservedParentRevision
                == predecessor.observedParentRevision,
              correctedObservedTree == predecessor.observedTree,
              correctedObservedSourceIdentitySHA256
                == predecessor.observedEmbeddedSourceIdentitySHA256,
              discoveryRevision.utf8.count == 40,
              discoveryRevision.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionCorrectionLowercaseHex),
              discoveryTree.utf8.count == 40,
              discoveryTree.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionCorrectionLowercaseHex),
              historicalGateGitBlob.utf8.count == 40,
              historicalGateGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionCorrectionLowercaseHex),
              historicalGateGitMode == "100755",
              historicalGateByteCount == 30_071,
              historicalGateSHA256.utf8.count == 64,
              historicalGateSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionCorrectionLowercaseHex),
              discoveryGateGitBlob.utf8.count == 40,
              discoveryGateGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionCorrectionLowercaseHex),
              discoveryGateGitMode == "100755",
              discoveryGateByteCount == 31_258,
              discoveryGateSHA256.utf8.count == 64,
              discoveryGateSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderExecutionCorrectionLowercaseHex),
              contradictedMatcherKind == "grep_fixed_literal_substring",
              contradictedNeedle == "Process",
              correctedMatcherERE
                == "(^|[^[:alnum:]_])Process([^[:alnum:]_]|$)",
              historicalValidationWitnessPaths.count == 2,
              historicalValidationWitnessGitBlobs.count == 2,
              historicalValidationWitnessGitBlobs.allSatisfy({ value in
                  value.utf8.count == 40
                    && value.utf8.allSatisfy(
                        isPrimeNativeDecoderExecutionCorrectionLowercaseHex)
              }),
              historicalValidationWitnessNeedle
                == "ProcessInfo.processInfo.environment",
              historicalProductionNeedleMatchCount == 0,
              historicalStandaloneProcessSymbolMatchCount == 0,
              !foundationProcessConstructionObserved,
              !subprocessExecutionObserved,
              !historicalActiveRootGateSuccessPossible,
              discoveryPullRequestNumber == 69,
              discoveryWorkflowRunIDs == [31_357_534_444, 31_357_549_264],
              discoveryWorkflowJobIDs == [93_359_935_073, 93_359_980_921],
              discoveryRunsBoundToExactHead,
              !discoveryFailureLogsRetainedInRepository,
              invalidatedPredecessorClaimNames == [
                  "exactHeadAndCleanGateSequenceCompleted",
                  "activeRootQuarantineGateCompleted",
              ],
              predecessor.exactHeadAndCleanGateSequenceCompleted,
              predecessor.activeRootQuarantineGateCompleted,
              !exactHeadAndCleanGateSequenceCompleted,
              !activeRootQuarantineGateCompleted,
              latinProvenanceGateClaimDisposition
                == "not_re_adjudicated_by_this_correction",
              predecessorMetalMechanicsProjectionRetained,
              retainedAuthorityTestCount
                == predecessor.executedAuthorityTestCount,
              retainedCheckpointTestCount
                == predecessor.executedCheckpointTestCount,
              retainedDecoderTestCount
                == predecessor.executedDecoderTestCount,
              retainedTotalTestCount == predecessor.executedTotalTestCount,
              retainedAuthorityTestCount
                + retainedCheckpointTestCount
                + retainedDecoderTestCount == retainedTotalTestCount,
              retainedTotalTestCount == 44,
              retainedFailureCount == predecessor.failureCount,
              retainedUnexpectedFailureCount
                == predecessor.unexpectedFailureCount,
              retainedSkipCount == predecessor.skipCount,
              retainedRawTerminalLogByteCount
                == predecessor.rawTerminalLogByteCount,
              retainedRawTerminalLogSHA256
                == predecessor.rawTerminalLogSHA256,
              retainedAttachmentByteCount
                == predecessor.attachmentTransportByteCount,
              retainedAttachmentSHA256
                == predecessor.attachmentTransportSHA256,
              retainedExternalMetallibByteCount
                == predecessor.externalMetallibByteCount,
              retainedExternalMetallibSHA256
                == predecessor.externalMetallibSHA256,
              !retainedExternalMetallibFreshBuildProvenanceObserved,
              inProcessMechanicsPolicyPreflightObserved
                == predecessor.inProcessMechanicsPolicyPreflightObserved,
              !testBundleBinaryProvenancePublished,
              exactCommittedHeadMetalMechanicsObserved
                == predecessor.exactCommittedHeadMetalMechanicsObserved,
              allStrengthenedRegressionsPassed
                == predecessor.allStrengthenedRegressionsPassed,
              standaloneProcessSymbolRemainsForbiddenAcrossClosure,
              validationProcessInfoEnvironmentInspectionAllowed,
              allOtherForbiddenChecksRemainUnchanged,
              !decoderMutationAuthorized,
              !checkpointMutationAuthorized,
              !isolatedDecoderValidationTestMutationAuthorized,
              existingRootProvenanceTestMethodExtensionAuthorized,
              !metalLauncherMutationAuthorized,
              !workflowTopologyMutationAuthorized,
              !driverV2MutationAuthorized,
              !rootTestInventoryMutationAuthorized,
              !gateRepairExecutionObserved,
              !githubHostedMetalObserved,
              !freshMetallibBuildProvenanceObserved,
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
              orderedNextActions == [
                  "run_exact_clean_successor_active_root_and_latin_gates",
                  "append_exact_successor_gate_observation",
                  "observe_github_hosted_fresh_metallib_live_metal_gate_after_reviewed_main",
              ]
        else {
            throw PrimeNativeDecoderMetalExecutionObservationCorrectionError
                .contractDrift
        }
    }
}

private func isPrimeNativeDecoderExecutionCorrectionLowercaseHex(
    _ byte: UInt8
) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
