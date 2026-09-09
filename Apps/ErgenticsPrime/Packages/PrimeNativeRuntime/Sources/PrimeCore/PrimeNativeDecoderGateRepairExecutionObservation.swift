// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderGateRepairExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Exact GitHub observation of the corrected active-root and Latin gate.
///
/// This record closes the corrected active-root/Latin-gate claim narrowed by
/// the predecessor correction. The broader whole-gate-sequence claim remains
/// false because the reviewed-main Metal job was intentionally skipped. This
/// observation grants no Metal-runtime, checkpoint, training, or downstream
/// authority.
public struct PrimeNativeDecoderGateRepairExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorCorrectionID: String
    public let predecessorCorrectionRemainsFrozen: Bool
    public let predecessorCorrectionRequiredForConsumption: Bool
    public let predecessorCorrectionSourcePath: String
    public let predecessorCorrectionSourceGitMode: String
    public let predecessorCorrectionSourceGitBlob: String
    public let predecessorCorrectionSourceByteCount: Int
    public let predecessorCorrectionSourceSHA256: String
    public let authoritativeRepository: String
    public let observedPullRequestNumber: Int
    public let observedBranch: String
    public let observedRevision: String
    public let observedParentRevision: String
    public let observedTree: String
    public let observedEmbeddedSourceIdentitySHA256: String
    public let observedWorkflowPath: String
    public let observedWorkflowGitMode: String
    public let observedWorkflowGitBlob: String
    public let observedWorkflowByteCount: Int
    public let observedWorkflowSHA256: String
    public let observedGatePath: String
    public let observedGateGitMode: String
    public let observedGateGitBlob: String
    public let observedGateByteCount: Int
    public let observedGateSHA256: String
    public let observedMatcherERE: String
    public let observedLatinGatePath: String
    public let observedLatinGateGitMode: String
    public let observedLatinGateGitBlob: String
    public let observedLatinGateByteCount: Int
    public let observedLatinGateSHA256: String
    public let automaticRunID: Int
    public let automaticRunEvent: String
    public let automaticRunURL: String
    public let automaticRunCreatedAt: String
    public let automaticRunUpdatedAt: String
    public let automaticRunStatus: String
    public let automaticRunConclusion: String
    public let automaticJobID: Int
    public let automaticJobURL: String
    public let automaticJobStartedAt: String
    public let automaticJobCompletedAt: String
    public let automaticJobStatus: String
    public let automaticJobConclusion: String
    public let workflowName: String
    public let activeRootJobName: String
    public let requiredSuccessfulStepNames: [String]
    public let automaticRunSucceeded: Bool
    public let exactRevisionCheckoutObserved: Bool
    public let activeMetadataAndPreservedHistoryGateCompleted: Bool
    public let changedSwiftContractsParsed: Bool
    public let isolatedLatinCaptureAndObservationGateCompleted: Bool
    public let authorityCeilingRecorded: Bool
    public let activeRootQuarantineGateCompleted: Bool
    public let exactHeadAndCleanGateSequenceCompleted: Bool
    public let correctedActiveRootAndLatinGateSequenceObserved: Bool
    public let gateRepairExecutionObserved: Bool
    public let workflowLogsRetainedInRepository: Bool
    public let reviewedMainJobName: String
    public let reviewedMainJobID: Int
    public let reviewedMainJobSkippedAsDesigned: Bool
    public let predecessorMetalMechanicsProjectionRetained: Bool
    public let historicalRetainedMetalTestCount: Int
    public let historicalRetainedMetalFailureCount: Int
    public let historicalRetainedMetalSkipCount: Int
    public let rawRunAndJobLogBytesBound: Bool
    public let exactPhysicalRunnerImageBound: Bool
    public let correctionRuntimeValidationObserved: Bool
    public let observationRuntimeValidationObserved: Bool
    public let metalDeviceObserved: Bool
    public let freshMetallibBuildExecuted: Bool
    public let decoderValidationSuiteExecuted: Bool
    public let executedDecoderValidationTestCount: Int
    public let decoderMutationAuthorized: Bool
    public let checkpointMutationAuthorized: Bool
    public let isolatedDecoderValidationTestMutationAuthorized: Bool
    public let metalLauncherMutationAuthorized: Bool
    public let packageGraphMutationAuthorized: Bool
    public let workflowTopologyMutationAuthorized: Bool
    public let driverV2MutationAuthorized: Bool
    public let rootTestInventoryMutationAuthorized: Bool
    public let pullRequestMergeAuthorizedByThisObservation: Bool
    public let githubHostedMetalObserved: Bool
    public let freshMetallibBuildProvenanceObserved: Bool
    public let testBundleBinaryProvenancePublished: Bool
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
            "ergentics_prime_native_decoder_gate_repair_execution_observation_v1",
        observationKind:
            "github_exact_head_corrected_active_root_and_latin_gate_observation",
        predecessorCorrectionID:
            PrimeNativeDecoderMetalExecutionObservationCorrectionV1
                .frozenV1.correctionID,
        predecessorCorrectionRemainsFrozen: true,
        predecessorCorrectionRequiredForConsumption: true,
        predecessorCorrectionSourcePath:
            "Sources/PrimeCore/PrimeNativeDecoderMetalExecutionObservationCorrection.swift",
        predecessorCorrectionSourceGitMode: "100644",
        predecessorCorrectionSourceGitBlob:
            "b9b0947cd814efc09d6412409d286b6be6db192f",
        predecessorCorrectionSourceByteCount: 22_744,
        predecessorCorrectionSourceSHA256:
            "9ef5851532c58d10165c6e6f511889f29d4f10bce7cc7b0b5d305392d0e54748",
        authoritativeRepository: "Ergentics/ergentics-prime",
        observedPullRequestNumber: 69,
        observedBranch: "feat/prime-latin-roadmap-next",
        observedRevision:
            "4a79fb2cb66c55ebc581fb4488ebcf9c7e2382c1",
        observedParentRevision:
            "ee5ed4276203b2c1eb299fa4eb17292de604e25d",
        observedTree:
            "5fe75b3632d52b5c5fcf82136174ab8ad9e90c3f",
        observedEmbeddedSourceIdentitySHA256:
            "3c9befd9f81178d3b0ca8a153a4534cc80901178cb1024a4a98bfa3ec0b0353b",
        observedWorkflowPath:
            ".github/workflows/prime-active-root-quarantine.yml",
        observedWorkflowGitMode: "100644",
        observedWorkflowGitBlob:
            "3358c1f71daa9b03909fa597d7e087fc3e006cc3",
        observedWorkflowByteCount: 18_438,
        observedWorkflowSHA256:
            "312362fb7846bfc4ddd8d8b8881effbe8081279534bf835e2613f4c0cec639bf",
        observedGatePath:
            ".github/scripts/prime-ci-active-root-quarantine.sh",
        observedGateGitMode: "100755",
        observedGateGitBlob:
            "efab3b129bae3671826a3adf5d5504b35490bc58",
        observedGateByteCount: 33_357,
        observedGateSHA256:
            "b649e0c49d4a12b8893f6368f6fd45cd496c1279a937db4399352535524cb4f9",
        observedMatcherERE:
            "(^|[^[:alnum:]_])Process([^[:alnum:]_]|$)",
        observedLatinGatePath:
            ".github/scripts/prime-ci-latin-proposal-pair-capture.sh",
        observedLatinGateGitMode: "100755",
        observedLatinGateGitBlob:
            "9e9875551e5a8a9d64b3e803ce609049d6939e52",
        observedLatinGateByteCount: 107_424,
        observedLatinGateSHA256:
            "cf46741af3eefea49e241af6a8b1c304a5fcb7236fba3ee2e70cf45568bf4fea",
        automaticRunID: 31_359_522_950,
        automaticRunEvent: "pull_request",
        automaticRunURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31359522950",
        automaticRunCreatedAt: "2026-08-10T05:43:53Z",
        automaticRunUpdatedAt: "2026-08-10T05:46:27Z",
        automaticRunStatus: "completed",
        automaticRunConclusion: "success",
        automaticJobID: 93_365_459_114,
        automaticJobURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31359522950/job/93365459114",
        automaticJobStartedAt: "2026-08-10T05:43:56Z",
        automaticJobCompletedAt: "2026-08-10T05:46:26Z",
        automaticJobStatus: "completed",
        automaticJobConclusion: "success",
        workflowName: "Prime active-root quarantine",
        activeRootJobName: "First-party MLX / active-root quarantine",
        requiredSuccessfulStepNames: [
            "Check out the exact Prime revision",
            "Validate active metadata and preserved history",
            "Parse the changed Swift contracts without dependencies",
            "Validate isolated Latin capture and observation contracts",
            "Record the authority ceiling",
        ],
        automaticRunSucceeded: true,
        exactRevisionCheckoutObserved: true,
        activeMetadataAndPreservedHistoryGateCompleted: true,
        changedSwiftContractsParsed: true,
        isolatedLatinCaptureAndObservationGateCompleted: true,
        authorityCeilingRecorded: true,
        activeRootQuarantineGateCompleted: true,
        exactHeadAndCleanGateSequenceCompleted: false,
        correctedActiveRootAndLatinGateSequenceObserved: true,
        gateRepairExecutionObserved: true,
        workflowLogsRetainedInRepository: false,
        reviewedMainJobName: "Reviewed main / focused source contracts",
        reviewedMainJobID: 93_365_854_108,
        reviewedMainJobSkippedAsDesigned: true,
        predecessorMetalMechanicsProjectionRetained: true,
        historicalRetainedMetalTestCount: 44,
        historicalRetainedMetalFailureCount: 0,
        historicalRetainedMetalSkipCount: 0,
        rawRunAndJobLogBytesBound: false,
        exactPhysicalRunnerImageBound: false,
        correctionRuntimeValidationObserved: false,
        observationRuntimeValidationObserved: false,
        metalDeviceObserved: false,
        freshMetallibBuildExecuted: false,
        decoderValidationSuiteExecuted: false,
        executedDecoderValidationTestCount: 0,
        decoderMutationAuthorized: false,
        checkpointMutationAuthorized: false,
        isolatedDecoderValidationTestMutationAuthorized: false,
        metalLauncherMutationAuthorized: false,
        packageGraphMutationAuthorized: false,
        workflowTopologyMutationAuthorized: false,
        driverV2MutationAuthorized: false,
        rootTestInventoryMutationAuthorized: false,
        pullRequestMergeAuthorizedByThisObservation: false,
        githubHostedMetalObserved: false,
        freshMetallibBuildProvenanceObserved: false,
        testBundleBinaryProvenancePublished: false,
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
            "ABSTAIN_corrected_exact_head_active_root_and_latin_gates_observed_hosted_metal_runtime_checkpoint_and_training_unestablished",
        orderedNextActions: [
            "merge_reviewed_history_preserving_pull_request_under_separate_authorization",
            "observe_trusted_main_fresh_metallib_live_metal_gate",
            "append_trusted_main_live_metal_observation",
            "append_repaired_checkpoint_compatibility_identity",
        ]
    )

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let predecessor =
            PrimeNativeDecoderMetalExecutionObservationCorrectionV1
                .frozenV1

        try predecessor.validateExactV1()

        guard self == expected,
              schemaVersion == 1,
              observationKind
                == "github_exact_head_corrected_active_root_and_latin_gate_observation",
              predecessorCorrectionID == predecessor.correctionID,
              predecessorCorrectionRemainsFrozen,
              predecessorCorrectionRequiredForConsumption,
              predecessorCorrectionSourceGitMode == "100644",
              predecessorCorrectionSourceGitBlob.utf8.count == 40,
              predecessorCorrectionSourceGitBlob.utf8.allSatisfy(
                  isPrimeNativeDecoderGateObservationLowercaseHex),
              predecessorCorrectionSourceByteCount == 22_744,
              predecessorCorrectionSourceSHA256.utf8.count == 64,
              predecessorCorrectionSourceSHA256.utf8.allSatisfy(
                  isPrimeNativeDecoderGateObservationLowercaseHex),
              authoritativeRepository == predecessor.authoritativeRepository,
              observedRevision.utf8.count == 40,
              observedParentRevision.utf8.count == 40,
              observedTree.utf8.count == 40,
              observedEmbeddedSourceIdentitySHA256.utf8.count == 64,
              observedWorkflowGitMode == "100644",
              observedWorkflowGitBlob.utf8.count == 40,
              observedWorkflowByteCount == 18_438,
              observedWorkflowSHA256.utf8.count == 64,
              observedGateGitMode == "100755",
              observedGateGitBlob.utf8.count == 40,
              observedGateByteCount == 33_357,
              observedGateSHA256.utf8.count == 64,
              observedMatcherERE == predecessor.correctedMatcherERE,
              observedLatinGateGitMode == "100755",
              observedLatinGateGitBlob.utf8.count == 40,
              observedLatinGateByteCount == 107_424,
              observedLatinGateSHA256.utf8.count == 64,
              observedPullRequestNumber == 69,
              automaticRunID == 31_359_522_950,
              automaticRunEvent == "pull_request",
              automaticJobID == 93_365_459_114,
              automaticRunStatus == "completed",
              automaticRunConclusion == "success",
              automaticJobStatus == "completed",
              automaticJobConclusion == "success",
              workflowName == "Prime active-root quarantine",
              activeRootJobName
                == "First-party MLX / active-root quarantine",
              requiredSuccessfulStepNames.count == 5,
              automaticRunSucceeded,
              exactRevisionCheckoutObserved,
              activeMetadataAndPreservedHistoryGateCompleted,
              changedSwiftContractsParsed,
              isolatedLatinCaptureAndObservationGateCompleted,
              authorityCeilingRecorded,
              activeRootQuarantineGateCompleted,
              !exactHeadAndCleanGateSequenceCompleted,
              correctedActiveRootAndLatinGateSequenceObserved,
              gateRepairExecutionObserved,
              !workflowLogsRetainedInRepository,
              reviewedMainJobID == 93_365_854_108,
              reviewedMainJobSkippedAsDesigned,
              !predecessor.activeRootQuarantineGateCompleted,
              !predecessor.exactHeadAndCleanGateSequenceCompleted,
              !predecessor.gateRepairExecutionObserved,
              predecessorMetalMechanicsProjectionRetained,
              historicalRetainedMetalTestCount
                == predecessor.retainedTotalTestCount,
              historicalRetainedMetalTestCount == 44,
              historicalRetainedMetalFailureCount == 0,
              historicalRetainedMetalSkipCount == 0,
              !rawRunAndJobLogBytesBound,
              !exactPhysicalRunnerImageBound,
              !correctionRuntimeValidationObserved,
              !observationRuntimeValidationObserved,
              !metalDeviceObserved,
              !freshMetallibBuildExecuted,
              !decoderValidationSuiteExecuted,
              executedDecoderValidationTestCount == 0,
              !decoderMutationAuthorized,
              !checkpointMutationAuthorized,
              !isolatedDecoderValidationTestMutationAuthorized,
              !metalLauncherMutationAuthorized,
              !packageGraphMutationAuthorized,
              !workflowTopologyMutationAuthorized,
              !driverV2MutationAuthorized,
              !rootTestInventoryMutationAuthorized,
              !pullRequestMergeAuthorizedByThisObservation,
              !githubHostedMetalObserved,
              !freshMetallibBuildProvenanceObserved,
              !testBundleBinaryProvenancePublished,
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
                  "merge_reviewed_history_preserving_pull_request_under_separate_authorization",
                  "observe_trusted_main_fresh_metallib_live_metal_gate",
                  "append_trusted_main_live_metal_observation",
                  "append_repaired_checkpoint_compatibility_identity",
              ]
        else {
            throw PrimeNativeDecoderGateRepairExecutionObservationError
                .contractDrift
        }
    }
}

private func isPrimeNativeDecoderGateObservationLowercaseHex(
    _ byte: UInt8
) -> Bool {
    (byte >= 48 && byte <= 57)
        || (byte >= 97 && byte <= 102)
}
