// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation
import PrimeCore

public enum
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Append-only binding for the one successful reviewed-main seed-43 repair.
///
/// The embedded typed receipt records one process-local random-initialized
/// Native-300M weights round trip. The exact launcher and terminal log bind
/// the supervisor's post-receipt verification followed by literal removal of
/// the immutable leaf and its empty private root. The checkpoint bytes were
/// neither uploaded nor retained, so this observation establishes no
/// beyond-process availability, artifact provenance, checkpoint admission,
/// forward behavior, training, candidate, publication, or product authority.
public struct
    PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorEvidenceID: String
    public let predecessorAuthorityRemainsFrozen: Bool
    public let predecessorAuthorityRequiredForConsumption: Bool
    public let predecessorAuthorityValidated: Bool
    public let predecessorBaseSourceBindingCount: Int
    public let predecessorNewExecutionSourceBindingCount: Int

    public let authoritativeRepository: String
    public let observedPullRequestNumber: Int
    public let observedPullRequestURL: String
    public let observedRef: String
    public let observedRevision: String
    public let observedOrderedParentRevisions: [String]
    public let observedTree: String
    public let reviewedPullRequestHeadRevision: String
    public let reviewedPullRequestHeadTree: String
    public let observedEmbeddedSourceIdentitySHA256: String
    public let historyPreservingTwoParentMergeObserved: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
    public let exactDirectSuccessorOfAuthorizedBaseObserved: Bool
    public let observedSourceBindings:
        [PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1]

    public let workflowID: Int
    public let workflowName: String
    public let workflowPath: String
    public let runID: Int
    public let runNumber: Int
    public let runAttempt: Int
    public let runEvent: String
    public let runActor: String
    public let runTriggeringActor: String
    public let runRef: String
    public let runURL: String
    public let runCreatedAt: String
    public let runStartedAt: String
    public let runUpdatedAt: String
    public let runStatus: String
    public let runConclusion: String

    public let activeRootJobID: Int
    public let activeRootJobName: String
    public let activeRootJobURL: String
    public let activeRootJobStartedAt: String
    public let activeRootJobCompletedAt: String
    public let activeRootJobStatus: String
    public let activeRootJobConclusion: String
    public let activeRootRunnerLabel: String
    public let activeRootOrderedStepNames: [String]
    public let activeRootOrderedStepConclusions: [String]

    public let reviewedMainJobID: Int
    public let reviewedMainJobName: String
    public let reviewedMainJobURL: String
    public let reviewedMainJobStartedAt: String
    public let reviewedMainJobCompletedAt: String
    public let reviewedMainJobStatus: String
    public let reviewedMainJobConclusion: String
    public let reviewedMainRunnerLabel: String
    public let reviewedMainOrderedStepNames: [String]
    public let reviewedMainOrderedStepConclusions: [String]
    public let reviewedMainRanAfterActiveRootSuccess: Bool
    public let liveStepName: String
    public let liveStepStartedAt: String
    public let liveStepCompletedAt: String
    public let liveStepConclusion: String

    public let consumedLiveLauncherPath: String
    public let consumedLiveLauncherCommand: String
    public let liveRepairCommandRetired: Bool
    public let retiredLauncherSourceRemainsFrozen: Bool
    public let consumedLiveExecutionReexecutionAuthorized: Bool
    public let reviewedMainTimeoutDuringObservedExecutionMinutes: Int
    public let reviewedMainTimeoutRestoredAfterObservationMinutes: Int
    public let reviewedMainTimeoutRestoredToOrdinary45Minutes: Bool
    public let reviewedMainCheckoutFetchDepthDuringObservedExecution: Int
    public let reviewedMainCheckoutFetchDepthRestoredAfterObservation: Int
    public let reviewedMainCheckoutDepthRestoredToOne: Bool

    public let activeJobTransportDecodedUTF8LogByteCount: Int
    public let activeJobTransportDecodedUTF8LogSplitLineCount: Int
    public let activeJobTransportDecodedUTF8LogSHA256: String
    public let reviewedMainJobTransportDecodedUTF8LogByteCount: Int
    public let reviewedMainJobTransportDecodedUTF8LogSplitLineCount: Int
    public let reviewedMainJobTransportDecodedUTF8LogSHA256: String
    public let decodedJobLogBindingKind: String
    public let decodedJobLogsIncludedUTF8BOM: Bool
    public let connectorResponseWrapperExcludedFromLogIdentity: Bool
    public let decodedJobLogsBound: Bool
    public let rawGitHubLogArchiveBytesBound: Bool
    public let jobLogsRetainedInRepository: Bool
    public let durableJobLogPublicationEstablished: Bool
    public let reviewedMainErrorAnnotationCount: Int
    public let publishedWorkflowArtifactCount: Int
    public let checkpointArtifactUploaded: Bool

    public let runnerVersion: String
    public let runnerProvisionerVersion: String
    public let runnerProvisionerCommit: String
    public let activeRunnerImage: String
    public let activeRunnerImageVersion: String
    public let activeOperatingSystemVersion: String
    public let activeOperatingSystemBuild: String
    public let reviewedRunnerImage: String
    public let reviewedRunnerImageVersion: String
    public let reviewedOperatingSystemVersion: String
    public let reviewedOperatingSystemBuild: String
    public let reviewedArchitecture: String
    public let xcodeVersion: String
    public let xcodeBuildVersion: String
    public let swiftVersion: String
    public let swiftTarget: String
    public let macOSSDKVersion: String
    public let swiftDriverVersion: String
    public let exactHostedRunnerImagesRecorded: Bool
    public let exactPhysicalRunnerIdentityRecorded: Bool

    public let receiptBeginMarker: String
    public let receiptChunkMarker: String
    public let receiptEndMarker: String
    public let receiptBeginMarkerCount: Int
    public let receiptChunkMarkerCount: Int
    public let receiptEndMarkerCount: Int
    public let receiptFirstChunkOrdinal: String
    public let receiptLastChunkOrdinal: String
    public let receiptChunkCharacterCount: Int
    public let receiptFinalChunkCharacterCount: Int
    public let receiptBase64CharacterCount: Int
    public let receiptCanonicalByteCount: Int
    public let receiptCanonicalSHA256: String
    public let compatibilityIdentityCanonicalByteCount: Int
    public let compatibilityIdentitySHA256: String
    public let tensorBindingsCanonicalByteCount: Int
    public let tensorBindingsSHA256: String
    public let manifestCanonicalByteCount: Int
    public let manifestCanonicalSHA256: String
    public let externalBindingCanonicalByteCount: Int
    public let externalBindingCanonicalSHA256: String
    public let receiptTransportWasOrderedContiguousAndFinal: Bool
    public let receiptEvidence:
        PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1

    public let exactParentPostReceiptVerificationSourceLineRange: [Int]
    public let exactParentArtifactUnlinkSourceLine: Int
    public let exactParentArtifactRootRmdirSourceLine: Int
    public let exactParentCleanupAbsencePostconditionSourceLineRange: [Int]
    public let receiptEndObservedAt: String
    public let parentCleanupSuccessObservedAt: String
    public let exactParentCleanupSuccessLine: String
    public let receiptEndPrecededParentCleanup: Bool
    public let parentReceiptVerificationCompleted: Bool
    public let parentArtifactUnlinkCompleted: Bool
    public let parentArtifactRootRmdirCompleted: Bool
    public let parentLiteralCleanupPostconditionCompleted: Bool
    public let parentCleanupBindingIsExactSourceAndTerminalLogControlFlow:
        Bool
    public let parentCleanupWasIndependentRetainedFilesystemObservation: Bool
    public let failureTrapCleanupEstablishedSuccess: Bool

    public let predecessorAuthorityAttemptConsumed: Bool
    public let predecessorAuthorityExhausted: Bool
    public let rerunObserved: Bool
    public let rerunAuthorized: Bool
    public let replacementExecutionAuthorityEstablished: Bool
    public let executionReceiptSourceAndRunBindingEstablished: Bool
    public let native300MModelAllocationObserved: Bool
    public let native300MCheckpointWriteObserved: Bool
    public let native300MCheckpointLoadObserved: Bool
    public let checkpointIOObserved: Bool
    public let checkpointArtifactAvailableDuringProcess: Bool
    public let checkpointContainerHashBound: Bool
    public let checkpointDurabilityMechanicsCompleted: Bool
    public let logicalParameterRoundTripViaPinnedCodecObserved: Bool
    public let publicationStableFiveFieldsMatched: Bool
    public let publicationRootLinkCountTransitionObserved: Bool
    public let readOnlyFullRootIdentityMatched: Bool

    public let checkpointArtifactAvailabilityBeyondProcessEstablished: Bool
    public let checkpointArtifactRetentionEstablished: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let existingCheckpointArtifactCompatibilityObserved: Bool
    public let atomicCheckpointReplacementEstablished: Bool
    public let failedCheckpointWriteRecoveryObserved: Bool
    public let independentPostLoadTensorHashReplayObserved: Bool
    public let independentCodecComparatorObserved: Bool
    public let independentPostLoadArtifactRootVerifyObserved: Bool
    public let checkpointLoadedForwardObserved: Bool
    public let checkpointRoundTripBehaviorParityEstablished: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let kvCacheStateIncluded: Bool
    public let decoderForwardObserved: Bool
    public let decoderKVCacheUsed: Bool
    public let backwardInvoked: Bool
    public let lossObserved: Bool
    public let optimizerStepObserved: Bool
    public let generationInvoked: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let trainingResumeEstablished: Bool
    public let trainingExecutionObserved: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    private static let frozenReceiptCanonicalJSONChunks = [
            #"{"architecture":"arm64","artifact_binding_verified_before_and_after_complete_materialization_via_pinned_artifact_root":true,"artifact_root_entry_count_after_write":1,"artifact_root_entry_names_after_write":["checkpoint-v2-native300m-seed43-root-identity-repair.safetensors"],"artifact_root_entry_names_before_write":[],"artifact_root_identity_after_load":{"change_time_nanoseconds":850740833,"change_time_seconds":1786448532,"device_id":16777230,"inode":2970995,"link_count":3,"modification_time_nanoseconds":850740833,"modification_time_seconds":1786448532,"owner_group_id":20,"owner_user_id":501,"permission_mode":448},"artifact_root_identity_after_write":{"change_time_nanoseconds":850740833,"change_time_seconds":1786448532,"device_id":16777230,"inode":2970995,"link_count":3,"modification_time_nanoseconds":850740833,"modification_time_seconds":1786448532,"owner_group_id":20,"owner_user_id":501,"permission_mode":448},"artifact_root_identity_before_write":{"change_time_nanoseconds":735646374,"change_time_seconds":1786448484,"device_id":16777230,"inode":2970995,"link_count":2,"modification_time_nanoseconds":733729583,"modification_time_seconds":1786448484,"owner_group_id":20,"owner_user_id":501,"permission_mode":448},"artifact_root_initially_empty":true,"artifact_root_owner_matched_effective_user":true,"artifact_root_path_is_absolute":true,"artifact_upload_invoked_before_receipt":false,"atomic_checkpoint_replacement_established":false,"authority_id":"ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_authority_v1","available_filesystem_bytes_after_build":101145567232,"available_filesystem_bytes_after_reclamation":102455418880,"backward_invoked":false,"cache_cleared_before_source_materialization":true,"cache_cleared_between_source_write_and_public_load":true,"caller_source_model_construction_count":1,"caller_supplied_revision_binding_is_independent_observation":false,"canary_replacement_authorized":false,"candidate_admission_granted":false,"checkpoint_admission_granted":false,"checkpoi"#,
            #"nt_artifact_availability_beyond_process_established":false,"checkpoint_artifact_available_during_process":true,"checkpoint_artifact_provenance_established":false,"checkpoint_artifact_retention_established":false,"checkpoint_container_hash_bound":true,"checkpoint_durability_mechanics_completed":true,"checkpoint_io_observed":true,"checkpoint_loaded_forward_observed":false,"checkpoint_round_trip_behavior_parity_established":false,"cleanup_required_after_parent_receipt_verification":true,"compatibility_identity_canonical_byte_count":30553,"compatibility_identity_sha256":"aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843","compatibility_identity_validated":true,"configuration":{"head_width":64,"intermediate_width":2816,"key_value_head_count":4,"layer_count":24,"maximum_sequence_length":2048,"model_width":1024,"query_head_count":16,"rms_norm_epsilon_float32_bit_pattern":925353388,"rope_theta_float32_bit_pattern":1176256512,"unique_parameter_count":271107072,"vocabulary_size":512},"container_materialization_count_required_by_pinned_codec":2,"core_graphics_bootstrap_observed":true,"cumulative_public_load_completion_count_source_inferred_after_success":1,"cumulative_public_write_completion_count_source_inferred_after_success":2,"data_cursor_included":false,"decoder_forward_observed":false,"decoder_kv_cache_used":false,"default_metal_device_matched_index_zero":true,"deterministic_seed_replay_observed":false,"enumerated_metal_device_count":1,"environment_policy":{"authorityCeiling":"one_process_local_seed43_native300m_source_materialization_one_v2_write_one_fresh_v2_load_no_forward_backward_retry_artifact_admission_upload_or_retention","comparisonPolicy":"exact_manifest_catalog_shape_dtype_count_and_logical_tensor_hash_via_pinned_codec_with_repaired_root_publication_snapshot","exactMLXRevision":"d37885a278f1c37484a94d0f401a418735e66519","exclusiveEnvironmentKeyPrefix":"MLX_","forbiddenEnvironmentKeyPrefixes":["DYLD_","LLVM_PROFILE_"],"numericMode":"float32_checkpoint_materialization_tf32_disabled","policyID":"#,
            #""ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_environment_v1","policyVersion":1,"predecessorPolicyID":"ergentics_prime_native_decoder_checkpoint_v2_container_io_execution_environment_v1","predecessorPolicyVersion":1,"predecessorRemainsFrozen":true,"requiredEnvironmentKey":"MLX_ENABLE_TF32","requiredEnvironmentValue":"0","schemaVersion":1,"scope":"one_seed43_native300m_v2_checkpoint_root_identity_repair_write_and_one_fresh_load"},"evidence_id":"ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_evidence_v1","exact_revision_matched_github_sha":true,"exclusive_no_replace_publication_completed":true,"executed_embedded_source_identity_sha256":"d1aa5b2352ebcf3595b5221f9bb784c610175ce3acc27d963d833cef85c57a90","executed_ordered_parent_revisions":["1a69407a8fbd5f141e8ece584066b8dcfa6f606f","7314b8a85c5f134c9521b84d2d51d12d3d5084bb"],"executed_revision":"44cfa2caa3af5bb44ad53294de33ba2d0faa9a59","executed_tree":"fbd57cd9de786e38121fa02b0664b1fb4fcd3d3c","execution_event":"push","execution_ref":"refs/heads/main","execution_repository":"Ergentics/ergentics-prime","execution_run_attempt":1,"exhausted_seed42_public_load_completion_count_source_inferred":0,"exhausted_seed42_public_write_completion_count_source_inferred":1,"existing_checkpoint_artifact_compatibility_observed":false,"existing_metallib_candidate_count_after_execution":1,"existing_metallib_candidate_count_before_execution":1,"external_binding":{"artifact_binding":{"byteCount":1084525304,"purpose":"immutable_data","relativePath":"checkpoint-v2-native300m-seed43-root-identity-repair.safetensors","sha256":"a6dae67b9a24e3d0220d22e3060bb43bab7d8cd027d97ea635db8580774cd538"},"manifest":{"artifact_kind":"prime_native_decoder_model_weights_only_checkpoint","checkpoint_format":"safetensors","compatibility_identity":{"architecture_schema":"ergentics_prime_native_gqa_decoder_architecture_v1","authority_id":"ergentics_prime_native_decoder_checkpoint_compatibility_v2","configuration":{"head_width"#,
            #"":64,"intermediate_width":2816,"key_value_head_count":4,"layer_count":24,"maximum_sequence_length":2048,"model_width":1024,"query_head_count":16,"rms_norm_epsilon_float32_bit_pattern":925353388,"rope_theta_float32_bit_pattern":1176256512,"unique_parameter_count":271107072,"vocabulary_size":512},"decoder_source_sha256":"058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b","exact_mlx_revision":"d37885a278f1c37484a94d0f401a418735e66519","identity_scope":"native300m_gqa_byte512_checkpoint_compatibility_v2","implementation_id":"PrimeNativeDecoder.PrimeNativeGQADecoder","maximum_checkpoint_byte_count":1101205504,"parameter_catalog":[{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"final_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.0.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.0.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.0.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.0.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.0.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.0.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.0.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.0.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.0.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.1.attention.key_projection.we"#,
            #"ight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.1.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.1.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.1.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.1.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.1.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.1.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.1.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.1.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.10.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.10.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.10.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.10.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.10.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.10.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.10.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534"#,
            #"336,"dtype":"float32","element_count":2883584,"path":"layers.10.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.10.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.11.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.11.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.11.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.11.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.11.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.11.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.11.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.11.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.11.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.12.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.12.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.12.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.12.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"pat"#,
            #"h":"layers.12.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.12.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.12.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.12.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.12.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.13.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.13.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.13.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.13.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.13.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.13.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.13.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.13.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.13.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.14.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.14.attention.output_projection.weight","sh"#,
            #"ape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.14.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.14.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.14.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.14.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.14.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.14.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.14.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.15.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.15.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.15.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.15.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.15.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.15.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.15.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.15.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"#,
            #""dtype":"float32","element_count":1024,"path":"layers.15.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.16.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.16.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.16.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.16.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.16.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.16.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.16.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.16.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.16.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.17.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.17.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.17.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.17.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.17.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.17.fee"#,
            #"d_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.17.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.17.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.17.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.18.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.18.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.18.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.18.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.18.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.18.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.18.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.18.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.18.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.19.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.19.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.19.attention.query_projection.weight","sha"#,
            #"pe":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.19.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.19.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.19.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.19.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.19.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.19.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.2.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.2.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.2.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.2.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.2.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.2.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.2.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.2.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.2.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_"#,
            #"count":262144,"path":"layers.20.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.20.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.20.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.20.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.20.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.20.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.20.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.20.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.20.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.21.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.21.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.21.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.21.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.21.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.21.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.21.feed_forwa"#,
            #"rd.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.21.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.21.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.22.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.22.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.22.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.22.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.22.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.22.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.22.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.22.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.22.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.23.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.23.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.23.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.23.attention.value_projection.weight","shape":[256,10"#,
            #"24]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.23.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.23.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.23.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.23.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.23.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.3.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.3.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.3.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.3.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.3.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.3.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.3.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.3.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.3.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.4.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"#,
            #""path":"layers.4.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.4.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.4.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.4.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.4.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.4.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.4.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.4.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.5.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.5.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.5.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.5.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.5.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.5.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.5.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.5.feed_forward.up_projection.weight""#,
            #","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.5.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.6.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.6.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.6.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.6.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.6.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.6.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.6.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.6.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.6.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.7.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.7.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.7.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.7.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.7.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":288"#,
            #"3584,"path":"layers.7.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.7.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.7.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.7.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.8.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.8.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.8.attention.query_projection.weight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.8.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.8.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.8.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.8.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.8.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.8.feed_forward_norm.weight","shape":[1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.9.attention.key_projection.weight","shape":[256,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.9.attention.output_projection.weight","shape":[1024,1024]},{"byte_count":4194304,"dtype":"float32","element_count":1048576,"path":"layers.9.attention.query_projection.we"#,
            #"ight","shape":[1024,1024]},{"byte_count":1048576,"dtype":"float32","element_count":262144,"path":"layers.9.attention.value_projection.weight","shape":[256,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.9.attention_norm.weight","shape":[1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.9.feed_forward.down_projection.weight","shape":[1024,2816]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.9.feed_forward.gate_projection.weight","shape":[2816,1024]},{"byte_count":11534336,"dtype":"float32","element_count":2883584,"path":"layers.9.feed_forward.up_projection.weight","shape":[2816,1024]},{"byte_count":4096,"dtype":"float32","element_count":1024,"path":"layers.9.feed_forward_norm.weight","shape":[1024]},{"byte_count":2097152,"dtype":"float32","element_count":524288,"path":"token_embedding.weight","shape":[512,1024]}],"parameter_catalog_sha256":"69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1","parameter_path_schema":"mlxnn_flattened_module_parameters_v1","predecessor_compatibility_identity_sha256":"acf439fcc9ddf4871ecc072d0e8372cb5b99e1673effc3afbfce755a0f9eec8d","repair_authority_id":"ergentics_prime_native_decoder_metal_repair_v1","required_tensor_dtype":"float32","schema_id":"ergentics_prime_native_decoder_checkpoint_compatibility_v2","schema_version":2,"tied_output_projection":true,"token_identity":{"schema_version":1,"tokenizer_id":"ergentics_prime_nfc_utf8_byte_v1","tokenizer_manifest_sha256":"f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7","vocabulary_size":512},"total_parameter_byte_count":1084428288,"total_parameter_count":271107072},"data_cursor_included":false,"kv_cache_state_included":false,"logical_tensor_byte_encoding":"contiguous_row_major_little_endian_float32","logical_tensor_hash_algorithm":"sha256","optimizer_state_included":false,"rng_state_included":false,"schema_id":"ergentics_prime_native_decoder_weights_checkpoint_v2","schema_version":2,"state_scope":"model_p"#,
            #"arameters_only_no_optimizer_rng_cursor_or_cache","tensor_bindings":[{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"final_norm.weight"},{"all_values_finite":true,"logical_sha256":"d5b98784a658fe60d6634cfd2fae3a6378dd55c4045963e6a135e8b8a3cffa37","path":"layers.0.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"1204eac44a24b8da81a856bc3873a7eab7a4f15b684c3767d3b2ff730bab0843","path":"layers.0.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"6a0286ccf173506c7b98b41a003c93f332b829cc564514369c6147a28b571f16","path":"layers.0.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"c3995e0ec80467cebdfeef100784c2ea12837b67c407d57c86ebea155a1f0623","path":"layers.0.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.0.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"093343e62c79dbdad85777dba88f314db8b2d9991b32a3d5eb53169b7d52fdd5","path":"layers.0.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"6c8415cd41606d71543b7250b43bbb7dcecc2731c520f99bfb95e1a4764b9e5f","path":"layers.0.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"3df7c760fc14e47e26d7aa14033d9e2f44366215dbad73abf4140dd282163632","path":"layers.0.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.0.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"54b7962911de867867f815fcfa42e93a69ab28902e5344cbd6bf4779b4f00192","path":"layers.1.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"897df3831b6dc6340c3ac6ed4de7e596b482ffe0be35ab15f21a769165aa88a6","path":"layers.1.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"cb6e22d9a50c08412a75f3fd"#,
            #"09f3e35782822dc4c9de4bf63c805ae14ee1ba94","path":"layers.1.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"c1f2889aa3a4fc56f4dd6155752091f9c02ae6e7f16eb5d272f8df23d3d37395","path":"layers.1.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.1.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"16dcf854f69f5146d9820459ce0fbe8dd901860e78b83239b965bdfecca791ba","path":"layers.1.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"4fc37bac379c2cb26841393b2b3287a5e394594f971fed5e582c35010507eca6","path":"layers.1.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"8ffe5fecdc13e81edf73e6c42f1b918ab3465619b5868b895ede35a6efd9cf1b","path":"layers.1.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.1.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"be5d17c61174719a8e390da9f46d354eb78d0a7c3d75470777e59c4826002443","path":"layers.10.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"9ecec6cdec5dadd28d91d1f30e6a856558e7871ca2717d507f336e0afe9e67a7","path":"layers.10.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"bfafbaa8fa15ca20fa9d04b656e1214175eaa8641976245ce34ce8216168d3e0","path":"layers.10.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"2549cc849ec01233a518e0d620b5fa50779a03a58183cad2835b8b716853712a","path":"layers.10.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.10.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"8661d6bbda4b85cfa9c67169e20d1fe9cf369b003706fb3ce393517c16d7bc5d","path":"layers.10.feed_forward.down_projection.weight"},{"all_values_finite"#,
            #"":true,"logical_sha256":"9eb932c6aa1b4f8a9763f4b303c181271abec7b1f5e48c73c4cda4eef87b4a30","path":"layers.10.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"cc08a023c4a80e2982c6bf4c0edd797fc8240cd1c428e6ce16c768f470ce9fba","path":"layers.10.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.10.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"9524689d1c2dcbdcce5b6c4cb9a97fc486f8b5aab2e7316e5b19ae547faccb56","path":"layers.11.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"484b261842f1ebcfe0b9b9977cd2fdc7e795a54a127098b47bc03ed8e05874c3","path":"layers.11.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"8a0dc37fffe2f34e92e08f76ad7641504fbdbf374d08f0d61645e6d6b8d166de","path":"layers.11.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"13fa6374c7a5dc00d6c44d0f183a1b99d9be566be13dc67f09caa50ced79a86d","path":"layers.11.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.11.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"049ebd65bccf0a7997c6e4c4e6d5c2e0386838dbaa3dbb47c58e4a6f125ba277","path":"layers.11.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"eb1242337af455852d3f2024f07d2e33185e166dce844baef7bcd54fa8b62545","path":"layers.11.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"e787e519f2fa5bc8339b2e1a2e3a35ff1170ef86f3f6987db0951cd58bd54475","path":"layers.11.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.11.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"80702f7d5cc19e267e3e0191eace380faf80241a5ca46aa5d851ee5f50a75520","path":"layers"#,
            #".12.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"bd963c75c9b311ef29245833f632cf79e1c2a955890d3981ef9f7bc43de8a1fd","path":"layers.12.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"499c9cf5f133ae518140f4be443a5f435f8f2a453f3d6dea1698d46b3034be59","path":"layers.12.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"a0e005e48c3dc4640c36c6f2ace6349f05969295f82bbce5a86c78ebfc5d27df","path":"layers.12.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.12.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"8bc8c5a20e9f222bb9ba03821ac56077fed2c7392eaa1c2d54bd6eda7c1ab461","path":"layers.12.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"3cb81d9a5f411cab61f57dcbb53356b1ef92351d9f35ae4097da656246ca63bb","path":"layers.12.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"ca866f9a33e0aaee4965c3d536264e2c1b0ffe097f2eb1a214413adbba46a001","path":"layers.12.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.12.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"55a17b820d79bcad792b014c2b6931b8519ec46d1dc499597c186be7f65944a4","path":"layers.13.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"ac4d857e17d5ed6c9b59896d3e4fcbf2aa9e87317d1843dc5439b9238d125519","path":"layers.13.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"d870dafd4ac733194046d105b545894620f4bf978063c28ed7d0250951acaaba","path":"layers.13.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"90fc3f50020dd41a4bfbb774d4feb9da9ca82a3c6c6ccc058ae0bf64e451c92d","path":"layers.13.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7c"#,
            #"b4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.13.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"fb9fb56c5bde387f6cd05def2d95dc6180053bf703dee33b4307638a3249a631","path":"layers.13.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"43b55957edc3142a27cd8e0be549420f46c4964b46b97bcabb0cf2910f735d71","path":"layers.13.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"2c2c7c958b315e7124c737e162c7d3d0586ffcea90322465bf51ebcc7b587860","path":"layers.13.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.13.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"3c259311a8863363a3ed852ed658b67c00cb5f1ef48c7a845370ca8fd6ebbecc","path":"layers.14.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"b805c7af02f1483d99ac764e043e90166d5c2d38adfddd868fc7c4ac047c9281","path":"layers.14.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"eb00bdf846dbbd164d5ed98e7a8d267664e0a4aecab1a7a93582b8d8880cf1a5","path":"layers.14.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"b5ee68144b97ce356a85f8bfb64c7325997b8a3551893db1ca407c9ba3188533","path":"layers.14.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.14.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"6136214d74b5ed79ddfa5906ceba553bf59abeb207d20d6fd99a42ce00cb38ab","path":"layers.14.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"bb8ff393d4570ea398fb059b0363488864c9e7ae1617a77284b7bd31947a92b7","path":"layers.14.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"ac0242c2124139c51aedcbeaf7e446e418f1ab1b489dbe4138c57abcd539631c","path":"layers.14.feed_forward.up_projection.weight"},{"#,
            #""all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.14.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"0021869c5db2a65c2ad0ba4250c73b9457f770837b3b111e497490ac3e4d480e","path":"layers.15.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"15768d93aa83f35b9ce0c1e77b6afbd0207169fe955189117d271780779fa61e","path":"layers.15.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"8b2bdf298bd1e2681dc2b3d5ccf1432bfbf8d17bfa7576f0718f2dd54e974774","path":"layers.15.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"3b9b7108fdbac856dd52fc8c19e653849fb9a4a41f80fbb6c079c01070161f8e","path":"layers.15.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.15.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"9fef53373c27e457627dc9c1efec4932bd0fc2d9fee5c4c5471b3c227433a8eb","path":"layers.15.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"a84b6cbfad1068c6b9ae0fac8263f206cbc33f30adab12a33eb489e1e7d79801","path":"layers.15.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"077021213fa5620a8ff2b9bf27708704678f6a5e59a732a69c6d1ab797a1a90f","path":"layers.15.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.15.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"6425d99d2dca9e006ff6771779cc93af81fef83d24a079a6705f07809481e971","path":"layers.16.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"7bf0ba3338fff2d85b3f16f9c3e92bc84ad5c6197e57079be87993f0a24b7f33","path":"layers.16.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"6705ce66eb506d5721c77b608cf8eff51fa06c88b1058618bb1114a60a76f0a7""#,
            #","path":"layers.16.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"bba480309db84f88d4dc11a8479073c5f78c33aa473bd9ae894aceca984aed88","path":"layers.16.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.16.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"da52064d840ad05c0adb6a2fb35afde9998f0c3703953543c1413480979fa4bb","path":"layers.16.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"93912a08aa172fb5339488d29c8f8aab19b7a264939b70888c249fdb053e6a31","path":"layers.16.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"8e5c58aa66706cdebf456f6b7bd117bca1c0ebdc017764801ee49d4575f92b28","path":"layers.16.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.16.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"c8dfcf54a4ba86a088e4e2b1796f81263806767172f2bd83a5f2dd2123c26e56","path":"layers.17.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"b73318c0d7faac0f17036b9cd850e6d979da934546ed9033590d91484c8f22b9","path":"layers.17.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"0c83624d6485862a701cba081a6d97f7d82ecb6c9ead78f7a97a5105cb7fc8fe","path":"layers.17.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"a680efa82cafeeb8c8824296366b5fb3baa400c74313d73097689cb585183298","path":"layers.17.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.17.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"a66f2c062f7e63020ff7df31651267b525e493dbdc1b8e68c305244a5fdf87b2","path":"layers.17.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"8626f74bd"#,
            #"88f3d2b26f24acca86b66aa3081d5b4d862d0467ad0bb8ceb7513dd","path":"layers.17.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"50d5d51950d323b335a62fa8079ea87d6ad54512edb0c0a3bb1c999f345e4431","path":"layers.17.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.17.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"0a9c635a07b56c8728aeac36cac09fbf1fd0438d32399a582a7914ca6592e41a","path":"layers.18.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"a8c14468db8a4663c14d3468997adbebde4dc10dca008c82af4f3e27922f4c00","path":"layers.18.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"ed349a3f66020c712577da9f047428fd2a26e316194b2a19d94464b5952abbb5","path":"layers.18.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"4e6735cebc5fcdb273d0e07f2a3cd69b1f76401a398e67967c3c98e667dfbf30","path":"layers.18.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.18.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"44306c77722e739ce2c9ef0c0f608c57abc57fe05eb4d0c403a4cbaa4cb033d6","path":"layers.18.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"41670aad43f99328289d5922d3e07a139e22f40e59571e4c477b01235705ed40","path":"layers.18.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"6f8d4a134cf338d443ae6167db7552ffbb0a712cf4a8f10c99afef3a2acfce67","path":"layers.18.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.18.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"e22f2817cc34e14a6885980d4f98c2c7786cb248193294fe2a0b64a922b537e4","path":"layers.19.attention.key_projection.weigh"#,
            #"t"},{"all_values_finite":true,"logical_sha256":"5f6c26a728765513af1d19ddfdba1fc904e083ae50cba1224e191d00d2076668","path":"layers.19.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"a472d93d252e9314efee705b298742b0157811516fdc0582362b032542408150","path":"layers.19.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"7b5e745013daba18d29fb258380fc7b44a62cb0e2393f7a691ea91edde306ec9","path":"layers.19.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.19.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"c11b8610ae9cb2badc70d47971060f3e349ef9f874dedaedb532d374653968e6","path":"layers.19.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"0985c80f25e5fd300e0fed41770d3483d23619683446bc60befbef4545a30d36","path":"layers.19.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"cd8aa9de883a5c6e1081ac5afb56eade993edff1a631b505201f09ba3e1c9822","path":"layers.19.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.19.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"b23295bf2f6cde7e66fabb3eb50f3aa5e742c37e9cec6d9384b7febfbbac87ac","path":"layers.2.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"283789d4c58eacd10252c5973b0c6abc665be8e68aa44ae5448712e4092db39b","path":"layers.2.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"1ff9374ccd390cbeedb5e212d8df41afc9cecbe81d4b7c7a3327604504df9405","path":"layers.2.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"f850333f015887aa8cba8329c89b4e203714bb6a9ec43b4360865e27dec38fc4","path":"layers.2.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd4585053"#,
            #"25f29c398c7","path":"layers.2.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"c5ae8a1bb0821b071bca9e5dd00da24796449bcc92fe490600f68c72938b3804","path":"layers.2.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"0f11c8a3c6e368d02f293aa8aaa6c7e13fc6f90f3f5cdbab0a607198b80f08e2","path":"layers.2.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"eb16beb0553989ed346906e0584c1ec105ab435ac85e7b8b679a6e71b8afae02","path":"layers.2.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.2.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"7dcb6ff0cf6b99db49ce5e41db76246faffcb837bfa3cec5ae53af01c966feec","path":"layers.20.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"a40a8a272d7bb16b9115a40e330cac6902798dab762f00749701e1737cb64998","path":"layers.20.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"a708e93081e9e184f0cfa7cecf2918e145620a139849aa6dce3e769c79827f40","path":"layers.20.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"4df8b6505ac5c944c9aa23c1655a1d898c3f5e5287918be10f4f71842e57a5c6","path":"layers.20.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.20.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"780d40a3547cdb588a16ec29f7b082a6991cbd56e2862ad268c3c71fcff72682","path":"layers.20.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"64727bd9fd75f63d78c81b4c0c086a1415c29dce056478b60c8283cb8a0ee761","path":"layers.20.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"741d1e07e0ec5ba22609789e1ff99104080841610a52c0bcb720e404d373aab8","path":"layers.20.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":""#,
            #"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.20.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"c0912f704e0a8135e7c9f555c7dc1e11eaafb51cac825a0ff4456008f6b7dd21","path":"layers.21.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"61bbc7cf3855ad57a04ba51a56062dc1529b5fadc938a3cf945e7c8a38d0ffef","path":"layers.21.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"610b1da9c2c29d56d0f8072b2aadb907df60af03ae9c428a6e00bb8ef4cf8475","path":"layers.21.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9e6944ac68a1cef15f09ada1df3e79e655f4b6dafa8753eaedfbeea15445dd4","path":"layers.21.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.21.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"f21bde6e7149e907b552d7a214184c0152f8fc516337e4bc7efca48f27c68139","path":"layers.21.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"0dda1ba7fce4a3b80160dfef24daa639ed8633e226c27ec8a2bb67aaf9ee3df6","path":"layers.21.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"f7766aa45e040e1e9394ce7a76070c7eb7d742344abbc2c82538af6f655ac3bd","path":"layers.21.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.21.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"3dbdbdb5e6ff00b78ac06c2481bbf09f7d323a87a02e60f3fdf69383194f9e59","path":"layers.22.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"8e04bac6314eb59094c372a222dfd2241ebdb37772c52294f4cbab4f20c219b3","path":"layers.22.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"80345393c18d3b39fc0774a307c9da804f03b2d173e152897fe30a8497e78b0a","path":"layers.22.attention.query_projecti"#,
            #"on.weight"},{"all_values_finite":true,"logical_sha256":"b2aa2c5fe045af7a9297e7ea2b7b84347eb89755afe15de3e871db11cceb67a6","path":"layers.22.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.22.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"c7e651f65f2fc1caa1842842959dfdf3b3291b7e491d54283083133105bc0cee","path":"layers.22.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"6dc94120d7e17816bb7cb396f1878dafbd0c41f4d79379126437530f54fb1c9f","path":"layers.22.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"ee64717f5a9cb3d7236028ff2b4ed03b429f2f47ac55d1ca3751af202bca1f87","path":"layers.22.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.22.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"da19682eb88b72d07f3d54d7e8bc8e425e721fa91a649d2e62b0929b1aff000f","path":"layers.23.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"a1d3daf1b5efc5a4baea4797778ae27d4f8fae78b2e9f5e40abf5a130d3a98e5","path":"layers.23.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"8f9c00c9c347fba4455e3985ffa55bdc465a140ca59850aec5efa8357f13a078","path":"layers.23.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"812ed0e434ee136d12bdf86d113cb2d8a01f296fe0911888996ea0a7af11af36","path":"layers.23.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.23.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"ca3a8da245d6bbc2a2ba0c1c33b6ce4e4fb0fe60a5523c2529de41f8dc6a0329","path":"layers.23.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"5c87b97b95d3fcb07333cf93fcb517827d52e3c0eff774200756"#,
            #"0cbb55dddcd2","path":"layers.23.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"0f02099513ab155131355a9adabfc460478b92a2109a371d9bbddf6cc4e74406","path":"layers.23.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.23.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"f3e58be34b7128ddfce25a711bd4012897b695dc2269786f38563819c0e70240","path":"layers.3.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"f44aca3b949fc56fc867164d4d2d84fe580851730b82c9d36e13d82e364b5013","path":"layers.3.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"5e61b5320f2b2c5e15f22f721ca6d2d6f3a78e4efaab1c284a527d71b189eb51","path":"layers.3.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"1c558bf3778ac7c05f01f9d8fe417b270438931f94ae4c4e2fce91d01621aab1","path":"layers.3.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.3.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"8a05b52d2265bee1e1373845c779d6c24acc4d3e36a7b68c1beec3dbb4b93b04","path":"layers.3.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"c4ad239e12d269e291e1d1c1634f7d6f9283a842db3bd8ad053451246018e947","path":"layers.3.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"2fffe288974accaec761220b09362f0ef9c89dc68d585f810523bbb257728a1b","path":"layers.3.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.3.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"ae6bd52ffcbee399c48484625432dc53a9d469670ae9c139ffaa712009a37b74","path":"layers.4.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"4e4bd"#,
            #"91e3811ea7173a12ab81fa58cbbb83b356491e254da8759525844023d81","path":"layers.4.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"c50438858da3631634020f3bfe18a17a273c277bedbea6ca8cc2b1cf440fe094","path":"layers.4.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"b1333091d6b3118a45026458290b50cebe557d0fa4174e349ab0709230f96f42","path":"layers.4.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.4.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"02f28d1156534d460c0c6c790796f60acea3ceb53e20fe7f0c0c0e30a6eb2b82","path":"layers.4.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"96066a3a5a4e4b2029ed2ef657ffa88436b4e0cccf4d3955ac061789fc0c31cb","path":"layers.4.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"1cabef7e5b6a52d76f1bcdddfcf2b6a5c9bb2bfb6247ca4e9e8a62a68e925102","path":"layers.4.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.4.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"69b8a5f0436b519b91de3ddc3a628cfb64e9a46e55289b42695487bc397b94c1","path":"layers.5.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"5be4459065e040f97181b2a4ae732ff72b9b175c611a06bbb055ec20b4430766","path":"layers.5.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"0a22e8f793d31592c10f10a4e9f792372629d5518ff24a321f36f92518139a5e","path":"layers.5.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"07c844d031ee848dca690c55f220c0d37ac6c47c44e5c4169b486896f073f89e","path":"layers.5.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.5.attention_norm.weight"},{"all_v"#,
            #"alues_finite":true,"logical_sha256":"28716860da6583b86b6f0b9f08d919851da85cb4d8d5a0d59a06bfb030ab8745","path":"layers.5.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"d3b7442b821a55e2f5022455f986af90df54b7e46aed36908cfd4e9eb96c4a95","path":"layers.5.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"89aab8e4c2806927dcd6e01225e3fd0a098112d89d4820a6320370b586d2b917","path":"layers.5.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.5.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"3b5bd80f8733f30708d3cd7f22a56e98eb545c7316a1acf56c80f91e61c4b459","path":"layers.6.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"f9aafb55161e84504d4b6fef5aeb3bc706697c8b9b50ab568eb45217482f0e15","path":"layers.6.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"8351c36b7a86123d90e54e2979343658f7f1dfc26c8f5ffc49470d880922b20b","path":"layers.6.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"d50378a030f3257bd867354d1d429b2f8da558d1376c266647ad758561898880","path":"layers.6.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.6.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"b1e1164414722fa1ebbab7baa0a00a9806945feadb2792e45708f92c3e720c87","path":"layers.6.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"b1a49e91f1f3db3a6041124b48f3d71c844b91ffc3b1ec91a13a0dd750bf477e","path":"layers.6.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"60662f074e3a7bfb4493954a76788a2c76816a6961ec2f4d5c493af7f7674e8e","path":"layers.6.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","pa"#,
            #"th":"layers.6.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"5385e91a996e7706036c41d3e992bf4d8186430cabed2f2cb8e1f257ea0f084c","path":"layers.7.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"d711831e757deeacb4ee85a622f61752c6eda058311ca3d13c74e85853ab38a4","path":"layers.7.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"49b563e649781a7423152a813224e82f0a826fd78e33021f697dbf3ba49e6f41","path":"layers.7.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"d049dd6d7b553265a6c6410a4b16dd6d47c394092aa77945ded6958fb1632a19","path":"layers.7.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.7.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"26b03b89dafe080e66b820c025628a69eaf1d919a1c275f55b5655bdd8eb6114","path":"layers.7.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"4745d89df0fbbb4f1254fea5ba9b2af9f7ede9f6a8e73bb969aadc818cc3663c","path":"layers.7.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"233be9a6ad2ab47924b210c2ec5126d933eb2cce3c6c12d8917f775d29b5fcdd","path":"layers.7.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.7.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"3b0325adafe6540858c6b06dd6f0c7f1be693541fa8be8a677ebd77f4b63fe4a","path":"layers.8.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"b261db9148e21a14a6f07e200cb039833bba4c7c2b953d1fc67ab77e9c6dabc3","path":"layers.8.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"9c0cb3127353ce461efd7cd9297f85aa0267ab55889977e8ad70dc87a533ebb7","path":"layers.8.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"db174b8414ece7f7e6652d41d1"#,
            #"e6ed28ddeb4e0cb861eeb9dec7b47dad95a57b","path":"layers.8.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.8.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"3161174ae8b2a280d0fd43b22c99d6f183a884778c7bcd3b7938d1b87ce217e7","path":"layers.8.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"f5bfcdef0975ce715fb2ad4bb8cade9a4ce2bdc1cf61575fa75fe4438e3b9e87","path":"layers.8.feed_forward.gate_projection.weight"},{"all_values_finite":true,"logical_sha256":"cec6069a20b6ef999e92ff415fc3be9559113bf7530138f6cdd9d7f862e46209","path":"layers.8.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.8.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"afb33efa686e7dc49e7cc36242fc61b03c4a06e76b6ab30ea510a2836ddd1848","path":"layers.9.attention.key_projection.weight"},{"all_values_finite":true,"logical_sha256":"23965782d54bf02b31b5110748e12e1fca0fee431aaa2c578a6d36923238ce2e","path":"layers.9.attention.output_projection.weight"},{"all_values_finite":true,"logical_sha256":"21994e47dd597b5cae0a2c51724f3da16d782e59913b1940a957386c8fcb81c6","path":"layers.9.attention.query_projection.weight"},{"all_values_finite":true,"logical_sha256":"c15b7a630dcf0573bb8d44cb262d71177fb5f82baab7b7fe2a9ba5762590336e","path":"layers.9.attention.value_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.9.attention_norm.weight"},{"all_values_finite":true,"logical_sha256":"8077e488d9d20b3444764bd9450b96f7a411cde5ee26b9af72034b17e4410484","path":"layers.9.feed_forward.down_projection.weight"},{"all_values_finite":true,"logical_sha256":"9b0705b2ed93e6e6e082fd27f8e77b12db6dd30344902d12d3582ec6af544fd5","path":"layers.9.feed_forward.gate_projection.weight"},{"all_values_finite":true"#,
            #","logical_sha256":"2265facbaa18af7b7dbfa6be9a9b3889781e8a2699b3cdb14bd954fafd725a28","path":"layers.9.feed_forward.up_projection.weight"},{"all_values_finite":true,"logical_sha256":"e9bac255f4adc7cb4ada9298e193a5ff66b434d15afabd458505325f29c398c7","path":"layers.9.feed_forward_norm.weight"},{"all_values_finite":true,"logical_sha256":"fb94eca84f89f2b2f0fd2ef02b293501876962b76c0fefeb1200c97011357d86","path":"token_embedding.weight"}],"tensor_bindings_sha256":"7cc7aec0d990a0bb6bb1748de396b84c85af06dea918610343e2f6560c926566"},"manifest_canonical_byte_count":66373,"manifest_canonical_sha256":"6b42dac70d522b248b02d564c8e850f82a28ca12fcfab4ca4db91ea8cc9098e3","schema_id":"manifest_plus_canonical_manifest_identity_plus_prime_artifact_binding_v2","schema_version":2},"external_binding_canonical_byte_count":66854,"external_binding_canonical_sha256":"c5a9b8a8aa4301f2dde0ab199bc39771298b1842009836537a085ba4b676d961","failed_checkpoint_write_recovery_observed":false,"focused_contract_logs_validated_before_reclamation":true,"free_space_preflight_passed":true,"fresh_loaded_model_construction_required_by_pinned_codec":true,"frozen_44_metal_log_validated_before_reclamation":true,"generated_file_and_parent_synchronization_returned_success":true,"generation_invoked":false,"github_actions":"true","independent_codec_comparator_observed":false,"independent_post_load_artifact_root_verify_observed":false,"independent_post_load_tensor_hash_replay_observed":false,"initial_parameter_materialization_evaluation_api":"MLX.checkedEval(model)","initial_parameter_materialization_evaluation_count":1,"initialization_seed":43,"known_runner_temporary_paths_absent_before_probe":true,"known_runner_temporary_reclamation_path_count":32,"kv_cache_state_included":false,"launched_environment_revalidated_after_evaluation":true,"launched_environment_validated_before_framework_access":true,"loaded_metallib_identity_independently_observed":false,"loaded_parameter_catalog_and_logical_hashes_matched_manifest_via_pinned_codec":true,"loaded_structural_parameter_ca"#,
            #"talog_matched":true,"logical_parameter_round_trip_via_pinned_codec_observed":true,"loss_observed":false,"maintained_runtime_authority_log_and_receipt_validated_before_reclamation":true,"manifest_canonical_byte_count":66373,"manifest_canonical_sha256":"6b42dac70d522b248b02d564c8e850f82a28ca12fcfab4ca4db91ea8cc9098e3","manifest_validated":true,"memory_cache_clear_count":2,"memory_cache_limit":0,"metal_lease_held_before_and_after_evaluation":true,"metal_library_validated_from_exact_url":true,"metallib_artifact_relative_path":"mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib","metallib_byte_count":6292732,"metallib_path_and_descriptor_reverified":true,"metallib_sha256":"d4e858ce07e26d7c82f8218fc7964d05f307db95620242348699cfff33e0d52f","mlx_device_index":0,"mlx_device_type":"gpu","model_quality_established":false,"native300m_checkpoint_load_observed":true,"native300m_checkpoint_write_observed":true,"native300m_model_allocation_observed":true,"observed_parameter_byte_count":1084428288,"observed_parameter_count":271107072,"operating_system":"macOS","optimizer_state_included":false,"optimizer_step_observed":false,"parent_success_cleanup_required_after_receipt":true,"physical_gpu_identity_established":false,"predecessor_failure_observation_consumed_by_authority_source":true,"predecessor_validated_log_count":10,"predecessor_validated_receipt_count":2,"process_exit_required_after_receipt":true,"product_use_authorized":false,"public_checkpoint_load_completion_count":1,"public_checkpoint_load_invocation_count":1,"public_checkpoint_write_completion_count":1,"public_checkpoint_write_invocation_count":1,"publication_authorized":false,"publication_root_link_counts_positive":true,"publication_stable_five_fields_matched":true,"published_artifact_device_matched_root":true,"published_artifact_is_regular_file":true,"published_artifact_is_symbolic_link":false,"published_artifact_link_count":1,"published_artifact_mode":292,"published_artifact_owner_matched_effective_user":true,"quantization_authorized":false,"read_only_full_roo"#,
            #"t_identity_matched":true,"release_instrumentation_evidence_absent":true,"reproducible_checkpoint_serialization_observed":false,"required_free_space_multiplier":3,"retry_observed":false,"reviewed_pull_request_head_tree":"fbd57cd9de786e38121fa02b0664b1fb4fcd3d3c","rng_state_included":false,"runner_environment":"github-hosted","runtime_dependency_closure_predecessor_receipt_validated_for_checkpoint_io":true,"schema_version":1,"second_independent_write_observed":false,"source_inferred_decoder_construction_count":3,"source_model_arc_deallocation_observed":false,"source_model_reference_lexical_scope_ended_before_public_load":true,"status":"PASS_process_local_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_only","success_cleanup_completed_before_receipt":false,"tensor_binding_count":218,"tensor_bindings_canonical_byte_count":35184,"tensor_bindings_sha256":"7cc7aec0d990a0bb6bb1748de396b84c85af06dea918610343e2f6560c926566","tf32_differential_observed":false,"tf32_static_value_directly_observed":false,"tokenizer_authority_log_and_receipt_validated_before_reclamation":true,"total_decoder_construction_count_is_source_inferred_only":true,"train_evaluate_surface_established":false,"training_execution_observed":false,"training_resume_established":false,"trial_authorized":false,"writer_hidden_descriptor_restore_and_reinspection_completed_via_successful_pinned_codec_return":true}"#,
        ]

    private struct SourceIdentitySeed: Encodable {
        let path: String
        let gitMode: String
        let gitBlob: String
        let byteCount: Int
        let sha256: String
    }

    private static func sourceIdentity(
        path: String,
        gitMode: String,
        gitBlob: String,
        byteCount: Int,
        sha256: String
    ) -> PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1 {
        do {
            let data = try JSONEncoder().encode(
                SourceIdentitySeed(
                    path: path,
                    gitMode: gitMode,
                    gitBlob: gitBlob,
                    byteCount: byteCount,
                    sha256: sha256))
            let identity = try JSONDecoder().decode(
                PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1.self,
                from: data)
            try identity.validate()
            return identity
        } catch {
            preconditionFailure("invalid frozen execution source identity")
        }
    }

    public static let frozenV1: Self = {
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1
                .frozenV1
        let receiptData = Data(
            frozenReceiptCanonicalJSONChunks.joined().utf8
        )
        let evidence:
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidenceV1
        do {
            guard receiptData.count == 77_205,
                  PrimeSHA256.hexDigest(of: receiptData)
                    == "b4aec02aa666433fa7bff5e913629e51f06f5388d21bf9e86d7801ca00dd67bf"
            else {
                preconditionFailure(
                    "invalid frozen root-identity repair receipt bytes")
            }
            evidence = try .decodeCanonicalReceipt(from: receiptData)
        } catch {
            preconditionFailure(
                "invalid frozen root-identity repair receipt evidence")
        }

        let activeSteps = [
            "Set up job",
            "Check out the exact Prime revision",
            "Validate active metadata and preserved history",
            "Parse the changed Swift contracts without dependencies",
            "Validate isolated Latin capture and observation contracts",
            "Record the authority ceiling",
            "Complete job",
        ]
        let reviewedSteps = [
            "Set up job",
            "Record the hosted Apple toolchain",
            "Check out reviewed main exactly",
            "Fetch the exact private dependency without evaluating Prime",
            "Compile and run the focused contracts without a credential",
            "Run the Prime-owned decoder on live Metal",
            "Complete job",
        ]

        return Self(
            schemaVersion: 1,
            observationID:
                "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_observation_v1",
            observationKind:
                "github_reviewed_main_exact_one_shot_checkpoint_v2_io_root_identity_repair_success_observation",
            predecessorAuthorityID: authority.authorityID,
            predecessorEvidenceID: evidence.evidenceID,
            predecessorAuthorityRemainsFrozen: true,
            predecessorAuthorityRequiredForConsumption: true,
            predecessorAuthorityValidated: true,
            predecessorBaseSourceBindingCount:
                authority.baseSourceBindings.count,
            predecessorNewExecutionSourceBindingCount:
                authority.newExecutionSourceBindings.count,

            authoritativeRepository: "Ergentics/ergentics-prime",
            observedPullRequestNumber: 79,
            observedPullRequestURL:
                "https://github.com/Ergentics/ergentics-prime/pull/79",
            observedRef: "refs/heads/main",
            observedRevision:
                "44cfa2caa3af5bb44ad53294de33ba2d0faa9a59",
            observedOrderedParentRevisions: [
                "1a69407a8fbd5f141e8ece584066b8dcfa6f606f",
                "7314b8a85c5f134c9521b84d2d51d12d3d5084bb",
            ],
            observedTree:
                "fbd57cd9de786e38121fa02b0664b1fb4fcd3d3c",
            reviewedPullRequestHeadRevision:
                "7314b8a85c5f134c9521b84d2d51d12d3d5084bb",
            reviewedPullRequestHeadTree:
                "fbd57cd9de786e38121fa02b0664b1fb4fcd3d3c",
            observedEmbeddedSourceIdentitySHA256:
                "d1aa5b2352ebcf3595b5221f9bb784c610175ce3acc27d963d833cef85c57a90",
            historyPreservingTwoParentMergeObserved: true,
            mergeTreeEqualsReviewedHeadTree: true,
            exactDirectSuccessorOfAuthorizedBaseObserved: true,
            observedSourceBindings: [
                sourceIdentity(
                    path:
                        "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthority.swift",
                    gitMode: "100644",
                    gitBlob: "244328c77fd20fb0338453e8d0ce9818e3470903",
                    byteCount: 63_136,
                    sha256:
                        "df689547c1a60ec904ad4cf320581cd6740fca6e797fc2a7fc17a3d9f7ac9f2e"),
                sourceIdentity(
                    path:
                        "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift",
                    gitMode: "100644",
                    gitBlob: "6edb77813df76adb8d7c84d8faf451e325634433",
                    byteCount: 62_078,
                    sha256:
                        "3bd2fa7bd7ada430b05e16e28242e452ebcd8bd0fb8165ee17723efd44096de8"),
                sourceIdentity(
                    path:
                        "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift",
                    gitMode: "100644",
                    gitBlob: "1cc830db123defbf6a8c0f1362d6d2bb9d754d34",
                    byteCount: 2_226,
                    sha256:
                        "0caa578cf38870dec6b12cced51859ebb5e3a75ecd30257b76e94c520690c1a4"),
                sourceIdentity(
                    path:
                        "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved",
                    gitMode: "100644",
                    gitBlob: "315cda0e2afccd6fd0acac96e6a0b9bf76afbeca",
                    byteCount: 645,
                    sha256:
                        "b93b010098821b26f2efe368e71d1fcf6a2dcb83403962140dfb61f2f70b4c34"),
                sourceIdentity(
                    path:
                        "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift",
                    gitMode: "100644",
                    gitBlob: "61f029352f7a27fa95b4a7b7238d58f1db834387",
                    byteCount: 41_866,
                    sha256:
                        "bac43ad7e9e44cc02b3b2e51ecf17d1ffb184a086e3c0c5854c8f2ba67b7a504"),
                sourceIdentity(
                    path:
                        "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift",
                    gitMode: "100644",
                    gitBlob: "8a7bbb1c147555a04e77937eda47b9938c6f742d",
                    byteCount: 41_659,
                    sha256:
                        "07575be036b7901ac9c8adba11d1d35a71df453a00bf62e2a8435a6af3e86373"),
                sourceIdentity(
                    path:
                        ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
                    gitMode: "100755",
                    gitBlob: "ed7852704219f61bc29841641257da697389458c",
                    byteCount: 66_828,
                    sha256:
                        "f56adf9d50d96fc8d06bfbf1bbebd9ce054f4de4f2577e778fc5afb24bd93f7b"),
                sourceIdentity(
                    path:
                        ".github/scripts/prime-ci-active-root-quarantine.sh",
                    gitMode: "100755",
                    gitBlob: "50ee76136a5d11a24119dc78053b357ab21cd1a3",
                    byteCount: 200_218,
                    sha256:
                        "303658f5ffb680bf1536eb2ff76ec6d4b0994dd0c24cdd0ab887979387811f96"),
                sourceIdentity(
                    path:
                        ".github/workflows/prime-active-root-quarantine.yml",
                    gitMode: "100644",
                    gitBlob: "f6d64634d66734a73061c9b93823ab7098776904",
                    byteCount: 33_497,
                    sha256:
                        "0d98ca3634658693492e822a84b94f02f43850ecb54d5e690a94e5cd027407b6"),
                sourceIdentity(
                    path:
                        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    gitMode: "100644",
                    gitBlob: "610eb14185e746dcb24c26b780f56d70925f3af7",
                    byteCount: 546,
                    sha256:
                        "df3efa4ef8242674a1fe85220ddf13af8f05cb465a1cf08ba67518010503e31c"),
            ] as [PrimeNativeDecoderMaintainedRuntimeSourceIdentityV1],

            workflowID: 329_017_041,
            workflowName: "Prime active-root quarantine",
            workflowPath:
                ".github/workflows/prime-active-root-quarantine.yml",
            runID: 31_484_642_403,
            runNumber: 55,
            runAttempt: 1,
            runEvent: "push",
            runActor: "psyop-archivist",
            runTriggeringActor: "psyop-archivist",
            runRef: "refs/heads/main",
            runURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31484642403",
            runCreatedAt: "2026-08-11T10:59:42Z",
            runStartedAt: "2026-08-11T10:59:42Z",
            runUpdatedAt: "2026-08-11T11:42:44Z",
            runStatus: "completed",
            runConclusion: "success",

            activeRootJobID: 93_757_136_546,
            activeRootJobName:
                "First-party MLX / active-root quarantine",
            activeRootJobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31484642403/job/93757136546",
            activeRootJobStartedAt: "2026-08-11T10:59:45Z",
            activeRootJobCompletedAt: "2026-08-11T11:02:15Z",
            activeRootJobStatus: "completed",
            activeRootJobConclusion: "success",
            activeRootRunnerLabel: "macos-15",
            activeRootOrderedStepNames: activeSteps,
            activeRootOrderedStepConclusions:
                Array(repeating: "success", count: activeSteps.count),

            reviewedMainJobID: 93_757_733_456,
            reviewedMainJobName:
                "Reviewed main / focused source contracts",
            reviewedMainJobURL:
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31484642403/job/93757733456",
            reviewedMainJobStartedAt: "2026-08-11T11:02:18Z",
            reviewedMainJobCompletedAt: "2026-08-11T11:42:43Z",
            reviewedMainJobStatus: "completed",
            reviewedMainJobConclusion: "success",
            reviewedMainRunnerLabel: "macos-26",
            reviewedMainOrderedStepNames: reviewedSteps,
            reviewedMainOrderedStepConclusions:
                Array(repeating: "success", count: reviewedSteps.count),
            reviewedMainRanAfterActiveRootSuccess: true,
            liveStepName: "Run the Prime-owned decoder on live Metal",
            liveStepStartedAt: "2026-08-11T11:15:26Z",
            liveStepCompletedAt: "2026-08-11T11:42:37Z",
            liveStepConclusion: "success",

            consumedLiveLauncherPath:
                ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
            consumedLiveLauncherCommand:
                "bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
            liveRepairCommandRetired: true,
            retiredLauncherSourceRemainsFrozen: true,
            consumedLiveExecutionReexecutionAuthorized: false,
            reviewedMainTimeoutDuringObservedExecutionMinutes:
                authority.reviewedMainTimeoutAfterMinutes,
            reviewedMainTimeoutRestoredAfterObservationMinutes:
                authority.reviewedMainTimeoutBeforeMinutes,
            reviewedMainTimeoutRestoredToOrdinary45Minutes: true,
            reviewedMainCheckoutFetchDepthDuringObservedExecution:
                authority.reviewedMainCheckoutFetchDepthDuringExecution,
            reviewedMainCheckoutFetchDepthRestoredAfterObservation:
                authority.reviewedMainCheckoutFetchDepthAfterObservation,
            reviewedMainCheckoutDepthRestoredToOne: true,

            activeJobTransportDecodedUTF8LogByteCount: 225_372,
            activeJobTransportDecodedUTF8LogSplitLineCount: 1_717,
            activeJobTransportDecodedUTF8LogSHA256:
                "a6f948b106edb307a3a826af74bdc82398afba6b1961359e77ec79bb9f069de8",
            reviewedMainJobTransportDecodedUTF8LogByteCount: 10_348_719,
            reviewedMainJobTransportDecodedUTF8LogSplitLineCount: 78_565,
            reviewedMainJobTransportDecodedUTF8LogSHA256:
                "caa3e223077cca02d917d2814668a2dc4e36d5e8eed3f60c76689821ed53e588",
            decodedJobLogBindingKind:
                "github_connector_transport_decoded_utf8_text_bom_included_response_wrapper_excluded",
            decodedJobLogsIncludedUTF8BOM: true,
            connectorResponseWrapperExcludedFromLogIdentity: true,
            decodedJobLogsBound: true,
            rawGitHubLogArchiveBytesBound: false,
            jobLogsRetainedInRepository: false,
            durableJobLogPublicationEstablished: false,
            reviewedMainErrorAnnotationCount: 0,
            publishedWorkflowArtifactCount: 0,
            checkpointArtifactUploaded: false,

            runnerVersion: "2.336.0",
            runnerProvisionerVersion: "20260707.563",
            runnerProvisionerCommit:
                "02667638d2b423fbc733a8e32a88b44996a3ba6e",
            activeRunnerImage: "macos-15-arm64",
            activeRunnerImageVersion: "20260727.0256.1",
            activeOperatingSystemVersion: "15.7.7",
            activeOperatingSystemBuild: "24G720",
            reviewedRunnerImage: "macos-26-arm64",
            reviewedRunnerImageVersion: "20260728.0273.1",
            reviewedOperatingSystemVersion: "26.5.2",
            reviewedOperatingSystemBuild: "25F84",
            reviewedArchitecture: "arm64",
            xcodeVersion: "26.6",
            xcodeBuildVersion: "17F113",
            swiftVersion:
                "Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)",
            swiftTarget: "arm64-apple-macosx26.0",
            macOSSDKVersion: "26.5",
            swiftDriverVersion: "1.148.6",
            exactHostedRunnerImagesRecorded: true,
            exactPhysicalRunnerIdentityRecorded: false,

            receiptBeginMarker:
                "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_BEGIN=",
            receiptChunkMarker:
                "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_CHUNK=",
            receiptEndMarker:
                "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_END=",
            receiptBeginMarkerCount: 1,
            receiptChunkMarkerCount: 26,
            receiptEndMarkerCount: 1,
            receiptFirstChunkOrdinal: "000000",
            receiptLastChunkOrdinal: "000025",
            receiptChunkCharacterCount: 4_096,
            receiptFinalChunkCharacterCount: 540,
            receiptBase64CharacterCount: 102_940,
            receiptCanonicalByteCount: 77_205,
            receiptCanonicalSHA256:
                "b4aec02aa666433fa7bff5e913629e51f06f5388d21bf9e86d7801ca00dd67bf",
            compatibilityIdentityCanonicalByteCount: 30_553,
            compatibilityIdentitySHA256:
                "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843",
            tensorBindingsCanonicalByteCount: 35_184,
            tensorBindingsSHA256:
                "7cc7aec0d990a0bb6bb1748de396b84c85af06dea918610343e2f6560c926566",
            manifestCanonicalByteCount: 66_373,
            manifestCanonicalSHA256:
                "6b42dac70d522b248b02d564c8e850f82a28ca12fcfab4ca4db91ea8cc9098e3",
            externalBindingCanonicalByteCount: 66_854,
            externalBindingCanonicalSHA256:
                "c5a9b8a8aa4301f2dde0ab199bc39771298b1842009836537a085ba4b676d961",
            receiptTransportWasOrderedContiguousAndFinal: true,
            receiptEvidence: evidence,

            exactParentPostReceiptVerificationSourceLineRange:
                [1_156, 1_175],
            exactParentArtifactUnlinkSourceLine: 1_176,
            exactParentArtifactRootRmdirSourceLine: 1_177,
            exactParentCleanupAbsencePostconditionSourceLineRange:
                [1_178, 1_180],
            receiptEndObservedAt: "2026-08-11T11:42:37.6029040Z",
            parentCleanupSuccessObservedAt:
                "2026-08-11T11:42:37.8067580Z",
            exactParentCleanupSuccessLine:
                "OK: exact reviewed-main one-shot Native-300M V2 checkpoint public write/load passed; the fixed artifact and 0700 root were removed after receipt validation",
            receiptEndPrecededParentCleanup: true,
            parentReceiptVerificationCompleted: true,
            parentArtifactUnlinkCompleted: true,
            parentArtifactRootRmdirCompleted: true,
            parentLiteralCleanupPostconditionCompleted: true,
            parentCleanupBindingIsExactSourceAndTerminalLogControlFlow:
                true,
            parentCleanupWasIndependentRetainedFilesystemObservation:
                false,
            failureTrapCleanupEstablishedSuccess: false,

            predecessorAuthorityAttemptConsumed: true,
            predecessorAuthorityExhausted: true,
            rerunObserved: false,
            rerunAuthorized: false,
            replacementExecutionAuthorityEstablished: false,
            executionReceiptSourceAndRunBindingEstablished: true,
            native300MModelAllocationObserved: true,
            native300MCheckpointWriteObserved: true,
            native300MCheckpointLoadObserved: true,
            checkpointIOObserved: true,
            checkpointArtifactAvailableDuringProcess: true,
            checkpointContainerHashBound: true,
            checkpointDurabilityMechanicsCompleted: true,
            logicalParameterRoundTripViaPinnedCodecObserved: true,
            publicationStableFiveFieldsMatched: true,
            publicationRootLinkCountTransitionObserved: true,
            readOnlyFullRootIdentityMatched: true,

            checkpointArtifactAvailabilityBeyondProcessEstablished: false,
            checkpointArtifactRetentionEstablished: false,
            checkpointArtifactProvenanceEstablished: false,
            checkpointAdmissionGranted: false,
            existingCheckpointArtifactCompatibilityObserved: false,
            atomicCheckpointReplacementEstablished: false,
            failedCheckpointWriteRecoveryObserved: false,
            independentPostLoadTensorHashReplayObserved: false,
            independentCodecComparatorObserved: false,
            independentPostLoadArtifactRootVerifyObserved: false,
            checkpointLoadedForwardObserved: false,
            checkpointRoundTripBehaviorParityEstablished: false,
            optimizerStateIncluded: false,
            rngStateIncluded: false,
            dataCursorIncluded: false,
            kvCacheStateIncluded: false,
            decoderForwardObserved: false,
            decoderKVCacheUsed: false,
            backwardInvoked: false,
            lossObserved: false,
            optimizerStepObserved: false,
            generationInvoked: false,
            trainEvaluateSurfaceEstablished: false,
            trainingResumeEstablished: false,
            trainingExecutionObserved: false,
            modelQualityEstablished: false,
            candidateAdmissionGranted: false,
            trialAuthorized: false,
            canaryReplacementAuthorized: false,
            quantizationAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            status:
                "ABSTAIN_exact_reviewed_main_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_parent_verified_ephemeral_cleanup_observed_no_artifact_retention_provenance_or_admission",
            orderedNextActions: [
                "define_generic_prime_owned_train_evaluate_surfaces_and_exact_optimizer_rng_data_cursor_state",
                "require_separate_authority_and_retained_artifact_provenance_before_training_or_checkpoint_admission",
            ])
    }()

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let authority =
            PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthorityPlanV1
                .frozenV1
        let receiptData: Data
        do {
            try authority.validateExactV1()
            for source in observedSourceBindings {
                try source.validate()
            }
            try receiptEvidence.validate()
            receiptData = try receiptEvidence.canonicalReceiptData()
        } catch {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationError
                    .contractDrift
        }

        let expectedSourcePaths = [
            "Sources/PrimeCore/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionAuthority.swift",
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionEvidence.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Package.resolved",
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Sources/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionProbe/main.swift",
            "Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionValidation/Tests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests/PrimeNativeDecoderCheckpointV2IORootIdentityRepairExecutionAuthorityTests.swift",
            ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
            ".github/scripts/prime-ci-active-root-quarantine.sh",
            ".github/workflows/prime-active-root-quarantine.yml",
            "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
        ]
        let beforeWrite = receiptEvidence.artifactRootIdentityBeforeWrite
        let afterWrite = receiptEvidence.artifactRootIdentityAfterWrite
        let afterLoad = receiptEvidence.artifactRootIdentityAfterLoad
        let artifact = receiptEvidence.externalBinding.artifactBinding

        guard self == expected,
              schemaVersion == 1,
              observationID
                == "ergentics_prime_native_decoder_checkpoint_v2_container_io_root_identity_repair_execution_observation_v1",
              observationKind
                == "github_reviewed_main_exact_one_shot_checkpoint_v2_io_root_identity_repair_success_observation",
              predecessorAuthorityID == authority.authorityID,
              predecessorEvidenceID == receiptEvidence.evidenceID,
              predecessorAuthorityRemainsFrozen,
              predecessorAuthorityRequiredForConsumption,
              predecessorAuthorityValidated,
              predecessorBaseSourceBindingCount
                == authority.baseSourceBindings.count,
              predecessorBaseSourceBindingCount == 12,
              predecessorNewExecutionSourceBindingCount
                == authority.newExecutionSourceBindings.count,
              predecessorNewExecutionSourceBindingCount == 6,
              authoritativeRepository == authority.authoritativeRepository,
              observedPullRequestNumber == 79,
              observedRef == authority.requiredExecutionRef,
              observedRevision == receiptEvidence.executedRevision,
              observedOrderedParentRevisions
                == receiptEvidence.executedOrderedParentRevisions,
              observedOrderedParentRevisions == [
                  authority.requiredDirectSuccessorFirstParentRevision,
                  reviewedPullRequestHeadRevision,
              ],
              observedTree == receiptEvidence.executedTree,
              reviewedPullRequestHeadTree == observedTree,
              receiptEvidence.reviewedPullRequestHeadTree == observedTree,
              observedEmbeddedSourceIdentitySHA256
                == receiptEvidence.executedEmbeddedSourceIdentitySHA256,
              historyPreservingTwoParentMergeObserved,
              mergeTreeEqualsReviewedHeadTree,
              exactDirectSuccessorOfAuthorizedBaseObserved,
              observedSourceBindings.map(\.path) == expectedSourcePaths,
              observedSourceBindings.count == 10,
              Set(observedSourceBindings.map(\.path)).count == 10,
              allObservedSourceHashesAreExactLowercaseHex,

              workflowID == 329_017_041,
              workflowName == "Prime active-root quarantine",
              workflowPath
                == ".github/workflows/prime-active-root-quarantine.yml",
              runID == 31_484_642_403,
              runNumber == 55,
              runAttempt == authority.requiredExecutionRunAttempt,
              runEvent == authority.requiredExecutionEvent,
              runActor == runTriggeringActor,
              runRef == authority.requiredExecutionRef,
              runStatus == "completed",
              runConclusion == "success",
              activeRootJobID == 93_757_136_546,
              activeRootJobStatus == "completed",
              activeRootJobConclusion == "success",
              activeRootRunnerLabel == "macos-15",
              activeRootOrderedStepNames.count == 7,
              activeRootOrderedStepConclusions
                == Array(repeating: "success", count: 7),
              reviewedMainJobID == 93_757_733_456,
              reviewedMainJobStatus == "completed",
              reviewedMainJobConclusion == "success",
              reviewedMainRunnerLabel == "macos-26",
              reviewedMainOrderedStepNames.count == 7,
              reviewedMainOrderedStepConclusions
                == Array(repeating: "success", count: 7),
              reviewedMainRanAfterActiveRootSuccess,
              liveStepName == reviewedMainOrderedStepNames[5],
              liveStepConclusion == "success",

              authority
                .observationSuccessorMustRemoveLiveLauncherCommandBeforeMerge,
              consumedLiveLauncherPath
                == ".github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
              consumedLiveLauncherPath
                == observedSourceBindings[6].path,
              consumedLiveLauncherCommand
                == "bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
              liveRepairCommandRetired,
              retiredLauncherSourceRemainsFrozen,
              !consumedLiveExecutionReexecutionAuthorized,
              reviewedMainTimeoutDuringObservedExecutionMinutes
                == authority.reviewedMainTimeoutAfterMinutes,
              reviewedMainTimeoutDuringObservedExecutionMinutes == 90,
              reviewedMainTimeoutRestoredAfterObservationMinutes
                == authority.reviewedMainTimeoutBeforeMinutes,
              reviewedMainTimeoutRestoredAfterObservationMinutes == 45,
              reviewedMainTimeoutRestoredToOrdinary45Minutes,
              reviewedMainCheckoutFetchDepthDuringObservedExecution
                == authority
                    .reviewedMainCheckoutFetchDepthDuringExecution,
              reviewedMainCheckoutFetchDepthDuringObservedExecution == 2,
              reviewedMainCheckoutFetchDepthRestoredAfterObservation
                == authority
                    .reviewedMainCheckoutFetchDepthAfterObservation,
              reviewedMainCheckoutFetchDepthRestoredAfterObservation == 1,
              reviewedMainCheckoutDepthRestoredToOne,

              activeJobTransportDecodedUTF8LogByteCount == 225_372,
              activeJobTransportDecodedUTF8LogSplitLineCount == 1_717,
              reviewedMainJobTransportDecodedUTF8LogByteCount
                == 10_348_719,
              reviewedMainJobTransportDecodedUTF8LogSplitLineCount
                == 78_565,
              decodedJobLogsIncludedUTF8BOM,
              connectorResponseWrapperExcludedFromLogIdentity,
              decodedJobLogsBound,
              !rawGitHubLogArchiveBytesBound,
              !jobLogsRetainedInRepository,
              !durableJobLogPublicationEstablished,
              reviewedMainErrorAnnotationCount == 0,
              publishedWorkflowArtifactCount == 0,
              !checkpointArtifactUploaded,
              runnerVersion == "2.336.0",
              runnerProvisionerVersion == "20260707.563",
              activeRunnerImage == "macos-15-arm64",
              reviewedRunnerImage == "macos-26-arm64",
              reviewedOperatingSystemVersion == "26.5.2",
              reviewedArchitecture == "arm64",
              xcodeVersion == "26.6",
              xcodeBuildVersion == "17F113",
              exactHostedRunnerImagesRecorded,
              !exactPhysicalRunnerIdentityRecorded,

              receiptBeginMarkerCount == 1,
              receiptChunkMarkerCount == 26,
              receiptEndMarkerCount == 1,
              receiptFirstChunkOrdinal == "000000",
              receiptLastChunkOrdinal == "000025",
              receiptChunkCharacterCount == 4_096,
              receiptFinalChunkCharacterCount == 540,
              receiptBase64CharacterCount == 102_940,
              receiptCanonicalByteCount == receiptData.count,
              receiptCanonicalByteCount == 77_205,
              PrimeSHA256.hexDigest(of: receiptData)
                == receiptCanonicalSHA256,
              receiptCanonicalSHA256
                == "b4aec02aa666433fa7bff5e913629e51f06f5388d21bf9e86d7801ca00dd67bf",
              compatibilityIdentityCanonicalByteCount
                == receiptEvidence.compatibilityIdentityCanonicalByteCount,
              compatibilityIdentitySHA256
                == receiptEvidence.compatibilityIdentitySHA256,
              tensorBindingsCanonicalByteCount
                == Int(
                    receiptEvidence.tensorBindingsCanonicalByteCount),
              tensorBindingsSHA256
                == receiptEvidence.tensorBindingsSHA256,
              manifestCanonicalByteCount
                == Int(receiptEvidence.manifestCanonicalByteCount),
              manifestCanonicalSHA256
                == receiptEvidence.manifestCanonicalSHA256,
              externalBindingCanonicalByteCount
                == Int(
                    receiptEvidence.externalBindingCanonicalByteCount),
              externalBindingCanonicalSHA256
                == receiptEvidence.externalBindingCanonicalSHA256,
              receiptTransportWasOrderedContiguousAndFinal,

              beforeWrite.deviceID == 16_777_230,
              beforeWrite.inode == 2_970_995,
              beforeWrite.ownerUserID == 501,
              beforeWrite.ownerGroupID == 20,
              beforeWrite.permissionMode == 0o700,
              beforeWrite.linkCount == 2,
              beforeWrite.publicationStableObjectFieldsEqual(
                  to: afterWrite),
              afterWrite.linkCount == 3,
              afterLoad.linkCount == 3,
              afterWrite.readOnlyFullIdentityEqual(to: afterLoad),
              artifact.relativePath
                == "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors",
              artifact.purpose == .immutableData,
              artifact.byteCount == 1_084_525_304,
              artifact.sha256
                == "a6dae67b9a24e3d0220d22e3060bb43bab7d8cd027d97ea635db8580774cd538",
              receiptEvidence.publishedArtifactMode == 0o444,
              receiptEvidence.publishedArtifactLinkCount == 1,
              receiptEvidence.publicCheckpointWriteCompletionCount == 1,
              receiptEvidence.publicCheckpointLoadCompletionCount == 1,

              exactParentPostReceiptVerificationSourceLineRange
                == [1_156, 1_175],
              exactParentArtifactUnlinkSourceLine == 1_176,
              exactParentArtifactRootRmdirSourceLine == 1_177,
              exactParentCleanupAbsencePostconditionSourceLineRange
                == [1_178, 1_180],
              receiptEndObservedAt < parentCleanupSuccessObservedAt,
              receiptEndPrecededParentCleanup,
              parentReceiptVerificationCompleted,
              parentArtifactUnlinkCompleted,
              parentArtifactRootRmdirCompleted,
              parentLiteralCleanupPostconditionCompleted,
              parentCleanupBindingIsExactSourceAndTerminalLogControlFlow,
              !parentCleanupWasIndependentRetainedFilesystemObservation,
              !failureTrapCleanupEstablishedSuccess,

              predecessorAuthorityAttemptConsumed,
              predecessorAuthorityExhausted,
              !rerunObserved,
              !rerunAuthorized,
              !replacementExecutionAuthorityEstablished,
              executionReceiptSourceAndRunBindingEstablished,
              native300MModelAllocationObserved,
              native300MCheckpointWriteObserved,
              native300MCheckpointLoadObserved,
              checkpointIOObserved,
              checkpointArtifactAvailableDuringProcess,
              checkpointContainerHashBound,
              checkpointDurabilityMechanicsCompleted,
              logicalParameterRoundTripViaPinnedCodecObserved,
              publicationStableFiveFieldsMatched,
              publicationRootLinkCountTransitionObserved,
              readOnlyFullRootIdentityMatched,
              allArtifactAdmissionTrainingAndProductCeilingsAreFalse,
              status
                == "ABSTAIN_exact_reviewed_main_seed43_native300m_v2_checkpoint_root_identity_repair_one_public_write_one_public_fresh_load_parent_verified_ephemeral_cleanup_observed_no_artifact_retention_provenance_or_admission",
              orderedNextActions == [
                  "define_generic_prime_owned_train_evaluate_surfaces_and_exact_optimizer_rng_data_cursor_state",
                  "require_separate_authority_and_retained_artifact_provenance_before_training_or_checkpoint_admission",
              ]
        else {
            throw
                PrimeNativeDecoderCheckpointV2ContainerIORootIdentityRepairExecutionObservationError
                    .contractDrift
        }
    }

    private var allObservedSourceHashesAreExactLowercaseHex: Bool {
        let gitObjects = [
            observedRevision,
            observedTree,
            reviewedPullRequestHeadRevision,
            reviewedPullRequestHeadTree,
        ] + observedOrderedParentRevisions
            + observedSourceBindings.map(\.gitBlob)
        let sha256s = [
            observedEmbeddedSourceIdentitySHA256,
            activeJobTransportDecodedUTF8LogSHA256,
            reviewedMainJobTransportDecodedUTF8LogSHA256,
            receiptCanonicalSHA256,
            compatibilityIdentitySHA256,
            tensorBindingsSHA256,
            manifestCanonicalSHA256,
            externalBindingCanonicalSHA256,
        ] + observedSourceBindings.map(\.sha256)
        return gitObjects.allSatisfy {
            $0.utf8.count == 40
                && $0.utf8.allSatisfy(Self.isLowercaseHex)
        } && sha256s.allSatisfy {
            $0.utf8.count == 64
                && $0.utf8.allSatisfy(Self.isLowercaseHex)
        }
    }

    private var allArtifactAdmissionTrainingAndProductCeilingsAreFalse:
        Bool
    {
        !checkpointArtifactAvailabilityBeyondProcessEstablished
            && !checkpointArtifactRetentionEstablished
            && !checkpointArtifactProvenanceEstablished
            && !checkpointAdmissionGranted
            && !existingCheckpointArtifactCompatibilityObserved
            && !atomicCheckpointReplacementEstablished
            && !failedCheckpointWriteRecoveryObserved
            && !independentPostLoadTensorHashReplayObserved
            && !independentCodecComparatorObserved
            && !independentPostLoadArtifactRootVerifyObserved
            && !checkpointLoadedForwardObserved
            && !checkpointRoundTripBehaviorParityEstablished
            && !optimizerStateIncluded
            && !rngStateIncluded
            && !dataCursorIncluded
            && !kvCacheStateIncluded
            && !decoderForwardObserved
            && !decoderKVCacheUsed
            && !backwardInvoked
            && !lossObserved
            && !optimizerStepObserved
            && !generationInvoked
            && !trainEvaluateSurfaceEstablished
            && !trainingResumeEstablished
            && !trainingExecutionObserved
            && !modelQualityEstablished
            && !candidateAdmissionGranted
            && !trialAuthorized
            && !canaryReplacementAuthorized
            && !quantizationAuthorized
            && !productUseAuthorized
            && !publicationAuthorized
    }

    private static func isLowercaseHex(_ byte: UInt8) -> Bool {
        (byte >= 48 && byte <= 57) || (byte >= 97 && byte <= 102)
    }
}
