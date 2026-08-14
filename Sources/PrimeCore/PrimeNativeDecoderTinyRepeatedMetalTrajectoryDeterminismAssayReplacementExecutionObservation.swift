// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift(String)
    case noncanonicalEncoding
}

/// Frozen evidence for the exhausted run-117 Stage-5 replacement execution.
///
/// The sole replacement XCTest passed and emitted exactly one canonical
/// `PASS_CLEARANCE` receipt. The reviewed-main job later failed in the
/// launcher's aggregate lease-parent postflight. These are deliberately
/// separate outcomes: the later supervisory guard failure does not erase the
/// bounded Stage-5 result, identify a failed conjunct, or authorize Stage 7.
public struct
    PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public struct SourceIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct RepositoryIdentity: Codable, Equatable, Sendable {
        public let repository: String
        public let pullRequestNumber: Int
        public let ref: String
        public let baseRevision: String
        public let baseTree: String
        public let reviewedHeadRevision: String
        public let reviewedHeadTree: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let mergedAt: String
        public let mergeCommitSignatureVerified: Bool
        public let mergeCommitSignatureReason: String
        public let historyPreservingTwoParentMergeObserved: Bool
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let exactMainRefMatchedAtTerminalAudit: Bool
        public let changedPathCount: Int
        public let manifestOrLockChangedPathCount: Int
    }

    public struct RunIdentity: Codable, Equatable, Sendable {
        public let workflowID: Int
        public let workflowName: String
        public let workflowPath: String
        public let runID: Int
        public let runNumber: Int
        public let runAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let headBranch: String
        public let headRevision: String
        public let actor: String
        public let triggeringActor: String
        public let createdAt: String
        public let startedAt: String
        public let terminalUpdatedAt: String
        public let status: String
        public let conclusion: String
        public let exactHeadPushRunCount: Int
        public let previousAttemptURLWasNull: Bool
        public let rerunCount: Int
        public let rerunObserved: Bool
        public let rerunAuthorized: Bool
        public let artifactCount: Int
        public let runURL: String
    }

    public struct JobIdentity: Codable, Equatable, Sendable {
        public let id: Int
        public let name: String
        public let status: String
        public let conclusion: String
        public let startedAt: String
        public let completedAt: String
        public let runnerID: Int
        public let runnerName: String
        public let runnerGroupName: String
        public let runnerLabel: String
        public let orderedStepNames: [String]
        public let orderedStepConclusions: [String]
        public let checkAnnotationCount: Int
        public let checkAnnotationPath: String
        public let checkAnnotationLine: Int
        public let checkAnnotationMessage: String
        public let jobURL: String
    }

    public struct RawLogIdentity: Codable, Equatable, Sendable {
        public let byteCount: Int
        public let lfByteCount: Int
        public let newlineDelimitedComponentCountIncludingTerminalEmpty: Int
        public let utf8BOMHex: String
        public let startsWithUTF8BOM: Bool
        public let usesLFOnly: Bool
        public let endsWithLF: Bool
        public let sha256: String
        public let bindingKind: String
        public let rawGitHubLogArchiveBytesBound: Bool
        public let retainedInRepository: Bool
    }

    public struct TestTopology: Codable, Equatable, Sendable {
        public let rootTestCount: Int
        public let isolatedCheckpointGroupTestCounts: [Int]
        public let isolatedCheckpointTestCount: Int
        public let focusedWholeTestCount: Int
        public let metalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let tokenizerTestCount: Int
        public let replacementAssayTestCount: Int
        public let totalTestCount: Int
        public let totalFailureCount: Int
        public let totalSkipCount: Int
        public let observedLiveExecutionOrder: [String]
    }

    public struct ReplacementTestBoundary: Codable, Equatable, Sendable {
        public let jobStepNumber: Int
        public let jobStepName: String
        public let jobStepStartedAt: String
        public let jobStepCompletedAt: String
        public let launcherInvocationCount: Int
        public let buildInvocationCount: Int
        public let buildCompletionCount: Int
        public let buildDurationMilliseconds: Int
        public let directXCTestInvocationCount: Int
        public let testFile: String
        public let testClass: String
        public let testMethod: String
        public let testFilter: String
        public let testStartCount: Int
        public let testPassCount: Int
        public let testFailureCount: Int
        public let testSkipCount: Int
        public let testDurationMilliseconds: Int
        public let receiptCount: Int
        public let receiptStatus: String
        public let receiptEmittedBeforeTestPass: Bool
    }

    public struct ReceiptIdentity: Codable, Equatable, Sendable {
        public let prefix: String
        public let prefixByteCount: Int
        public let canonicalJSON: String
        public let canonicalJSONByteCount: Int
        public let canonicalJSONSHA256: String
        public let storageByteCountIncludingLF: Int
        public let storageSHA256IncludingLF: String
        public let prefixedCanonicalByteCount: Int
        public let prefixedCanonicalSHA256: String
        public let prefixedCanonicalLFByteCount: Int
        public let prefixedCanonicalLFSHA256: String
        public let fullTimestampedLine: String
        public let fullTimestampedLineByteCount: Int
        public let fullTimestampedLineSHA256: String
        public let logLineNumber: Int
        public let emittedAt: String
        public let exactOccurrenceCount: Int
        public let receiptID: String
        public let schemaVersion: Int
        public let status: String
        public let authorityID: String
        public let authorityCanonicalSHA256: String
    }

    public struct OperationCounts: Codable, Equatable, Sendable {
        public let armASourceStepCount: Int
        public let armBTrainingStepCount: Int
        public let armBEvaluateCount: Int
        public let armBSnapshotCount: Int
        public let armBRestoreCount: Int
        public let armBForwardEquivalenceCheckCount: Int
        public let armBInputEmbeddingPairSeamCount: Int
        public let armBDenseWholeLogitsCallCount: Int
        public let armBDenseEmbeddingConstructionCount: Int
        public let armBTokenBoundsValidationCount: Int
        public let armBTokenBoundsCheckedEvalCount: Int
        public let armBTokenBoundsGPUSynchronizeCount: Int
        public let armBTokenBoundsHostBoolItemCount: Int
        public let synchronizeCount: Int
        public let receiptCount: Int
    }

    public struct ClearanceBoundary: Codable, Equatable, Sendable {
        public let armAIsDiagnosticOnly: Bool
        public let armAGatesOrSkipsArmB: Bool
        public let armATrialCount: Int
        public let armACompletedDiagnosticPairCount: Int
        public let armAMeasuredMismatch: Bool
        public let armBTrialCount: Int
        public let armBBranchCount: Int
        public let armBBranchNames: [String]
        public let armBComparisonDomains: [String]
        public let armBAllExactComparisonsPassed: Bool
        public let armBAllForwardEquivalenceChecksPassed: Bool
        public let armBFirstMismatchObserved: Bool
        public let sameModelPreMutationForwardEquivalence: Bool
        public let forwardEquivalenceBoundaries: [String]
        public let flattenedDenseOneHotMatmulSelectorID: String
        public let sameDeviceBPathExactGradientBytesEstablished: Bool
        public let repeatedSameDeviceBPathDeterminismEstablished: Bool
        public let stage5MechanicsSuccessEstablished: Bool
        public let stage5ResultEstablished: Bool
        public let stage5AssayClearanceEstablished: Bool
    }

    public struct OuterLauncherFailureBoundary: Codable, Equatable, Sendable {
        public let testOutcomeWasPass: Bool
        public let outerWorkflowOutcomeWasFailure: Bool
        public let failureOccurredAfterReceiptAndTestPass: Bool
        public let aggregateGuardSourceLines: [Int]
        public let aggregateGuardConjuncts: [String]
        public let aggregateGuardFailed: Bool
        public let failedConjunctIdentified: Bool
        public let actualLeaseParentMetadataObserved: Bool
        public let exactLauncherFailureMessage: String
        public let exactFailureLine: String
        public let failureLoggedAt: String
        public let exactFailureLineOccurrenceCount: Int
        public let launcherExitCode: Int
        public let workflowProcessExitCode: Int
        public let workflowExitAnnotationOccurrenceCount: Int
        public let localAPFSLinkCountReproductionBoundAsCause: Bool
        public let nextLeaseFileGuardReached: Bool
        public let exactChildInventoryGuardReached: Bool
        public let leaseFileRemovalReached: Bool
        public let leaseParentRemovalReached: Bool
        public let cleanupAbsenceProofReached: Bool
        public let repositoryPostflightReached: Bool
        public let privateWorkingDirectoryPostflightReached: Bool
        public let metallibPostflightReached: Bool
        public let launcherOKMarkerReached: Bool
    }

    public struct LeaseBoundary: Codable, Equatable, Sendable {
        public let environmentKey: String
        public let parentPath: String
        public let leasePath: String
        public let acquiredBeforeCoreGraphicsMetalOrMLX: Bool
        public let retainedDeviceName: String
        public let retainedDeviceRegistryID: UInt64
        public let receiptConstructedValidatedAndRoundTrippedWhileHeld: Bool
        public let receiptEmissionCheckedWhileHeld: Bool
        public let receiptFlushCheckedWhileHeld: Bool
        public let explicitReleaseAfterReceiptReached: Bool
        public let outerLeaseParentCleanupCompleted: Bool
    }

    public struct RetirementBoundary: Codable, Equatable, Sendable {
        public let retirementRequired: Bool
        public let retirementObserved: Bool
        public let exactChangedPathCount: Int
        public let exactOrderedChangedPaths: [String]
        public let expectedRootTestCount: Int
        public let expectedIsolatedCheckpointGroupTestCounts: [Int]
        public let expectedIsolatedCheckpointTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedMetalTestCount: Int
        public let expectedMaintainedRuntimeTestCount: Int
        public let expectedTokenizerTestCount: Int
        public let expectedReplacementAssayTestCount: Int
        public let expectedTotalTestCount: Int
        public let expectedFailureCount: Int
        public let expectedSkipCount: Int
        public let expectedLiveExecutionOrder: [String]
        public let expectedOriginalStage5LauncherInvocationCount: Int
        public let expectedOriginalStage5ReceiptCount: Int
        public let expectedReplacementStage5LauncherInvocationCount: Int
        public let expectedReplacementStage5ReceiptCount: Int
        public let expectedStage6LauncherInvocationCount: Int
        public let expectedStage6ReceiptCount: Int
        public let expectedReviewedMainTimeoutMinutes: Int
        public let replacementLauncherPreservedForAudit: Bool
        public let replacementAssaySourcePreservedForAudit: Bool
        public let replacementLiveExecutionPermittedByRetirement: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let oneShotConsumed: Bool
        public let oneShotExhausted: Bool
        public let additionalExecutionOrRerunAuthorized: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let stage5ReceiptEstablished: Bool
        public let stage5MechanicsSuccessEstablished: Bool
        public let stage5ResultEstablished: Bool
        public let stage5AssayClearanceEstablished: Bool
        public let launcherPostReceiptCompletionEstablished: Bool
        public let outerWorkflowSuccessEstablished: Bool
        public let repeatedSameDeviceBPathDeterminismEstablished: Bool
        public let exactSameDeviceBPathGradientBytesEstablished: Bool
        public let defaultGatherDeterminismEstablished: Bool
        public let arbitraryTokenDeterminismEstablished: Bool
        public let crossDeviceDeterminismEstablished: Bool
        public let durableCheckpointIOAuthorized: Bool
        public let retainedArtifactAuthorized: Bool
        public let artifactUploadAuthorized: Bool
        public let candidateAdmissionGranted: Bool
        public let modelQualityEstablished: Bool
        public let downstreamTrialAuthorized: Bool
        public let canaryAuthorized: Bool
        public let quantizationAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
        public let stage6HistoricalResourceClearanceRemainsEstablished: Bool
        public let stage6HistoricalResourceClearanceAppliesToBPath: Bool
        public let bSpecificNative300ResourceWitnessEstablished: Bool
        public let bSpecificNative300ResourceWitnessAuthorized: Bool
        public let bSpecificNative300ResourceWitnessRequiresSeparateAuthority: Bool
        public let stage7RequiresNewBSpecificNative300ResourceWitness: Bool
        public let stage7RequiresSeparateAuthorityAfterWitness: Bool
        public let stage7AuthorityEstablished: Bool
        public let stage7Authorized: Bool
    }

    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let predecessorAuthorityID: String
    public let predecessorAuthorityCanonicalSHA256: String
    public let repositoryIdentity: RepositoryIdentity
    public let observedSourceBindings: [SourceIdentity]
    public let runIdentity: RunIdentity
    public let activeRootJob: JobIdentity
    public let reviewedMainJob: JobIdentity
    public let activeRootRawLog: RawLogIdentity
    public let reviewedMainRawLog: RawLogIdentity
    public let testTopology: TestTopology
    public let replacementTestBoundary: ReplacementTestBoundary
    public let receiptIdentity: ReceiptIdentity
    public let operationCounts: OperationCounts
    public let clearanceBoundary: ClearanceBoundary
    public let outerLauncherFailureBoundary: OuterLauncherFailureBoundary
    public let leaseBoundary: LeaseBoundary
    public let retirementBoundary: RetirementBoundary
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalSHA256 =
        "7e17cfdc59f63a775aa4ec5b797328e80c0ab75ef65b2b3ddd7f4bf8deb48ef9"

    public static let frozenReceiptCanonicalJSON = #"""
{"arm_a":{"completed_diagnostic_pair_count":3,"first_scalar_mismatch":null,"first_tensor_mismatch":null,"global_step_one_by_pair":[{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":1},{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":2},{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":3}],"measured_mismatch":false,"pair_branch_names":["uninterrupted","source_snapshot"],"selected_target_count_six_by_pair":[{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":1},{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":2},{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":3}],"source_step_equal_by_pair":[{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":1},{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":2},{"exact":true,"observed_branch":"source_snapshot","reference_branch":"uninterrupted","trial_ordinal":3}],"trial_count":3},"arm_b":{"all_exact_comparisons_passed":true,"all_forward_equivalence_checks_passed":true,"branch_names":["uninterrupted","source_snapshot","fresh_restored_from_source_snapshot"],"comparison_domain_results":[{"comparison_domain":"control_rng_and_cursor_state","exact":true},{"comparison_domain":"evaluation_loss_and_logits_bytes","exact":true},{"comparison_domain":"global_step_and_selected_target_count","exact":true},{"comparison_domain":"model_parameter_bytes","exact":true},{"comparison_domain":"optimizer_first_and_second_moment_bytes","exact":true},{"comparison_domain":"raw_and_clipped_gradient_bytes","exact":true},{"comparison_domain":"training_loss_norm_and_clip_scalar_bits","exact":true}],"first_mismatch":null,"fresh_constructor":"PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(metalGPUIndexZero:stage5ReplacementTrainingInputPath:)","restore_constructor":"PrimeNativeDecoderTinyCPUExplicitRNGCursorResumeSessionV1.init(restoring:metalGPUIndexZero:stage5ReplacementTrainingInputPath:)","selector_id_by_branch":[{"branch":"uninterrupted","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":1},{"branch":"source_snapshot","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":1},{"branch":"fresh_restored_from_source_snapshot","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":1},{"branch":"uninterrupted","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":2},{"branch":"source_snapshot","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":2},{"branch":"fresh_restored_from_source_snapshot","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":2},{"branch":"uninterrupted","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":3},{"branch":"source_snapshot","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":3},{"branch":"fresh_restored_from_source_snapshot","selector_id":"flattened_dense_one_hot_matmul_input_embedding_v1","trial_ordinal":3}],"status":"PASS_CLEARANCE","trajectory_branch_count":9,"trial_count":3},"authority":{"authority_canonical_sha256":"e0b1fadf4075765078ba3cf29e7cce85be930791651020d45cba1b5b91466252","authority_id":"prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_authority_v1","authority_source_git_blob":"ded305476edfc832ae4e910b1985da77c7a10cd0","authority_source_sha256":"634eabe81f63a570cfe2f565d95befbd8c77ea98ba7864a212f45511c7f8b5fc","authority_test_git_blob":"e7e240f6bb6e037f0b41f28d925ce0fcd38c42a7","authority_test_sha256":"71506cbc21fb8d03886bdc95500e6249f5d61a59f84569dfda95875289435e08"},"ceiling":{"additional_execution_or_rerun_authorized":false,"arbitrary_token_determinism_established":false,"artifact_upload_authorized":false,"b_specific_native300_resource_witness_authorized":false,"b_specific_native300_resource_witness_established":false,"b_specific_native300_resource_witness_requires_separate_authority":true,"candidate_admission_granted":false,"cross_device_determinism_established":false,"default_gather_determinism_established":false,"durable_checkpoint_io_authorized":false,"exact_same_device_b_path_gradient_bytes_established":true,"model_quality_established":false,"one_shot_consumed":true,"repeated_same_device_b_path_determinism_established":true,"retained_artifact_authorized":false,"stage5_assay_clearance_established":true,"stage5_mechanics_success_established":true,"stage5_result_established":true,"stage6_historical_resource_clearance_applies_to_b_path":false,"stage6_resource_clearance_remains_historical":true,"stage7_authority_established":false,"stage7_authorized":false,"stage7_requires_new_b_specific_native300_resource_witness":true,"stage7_requires_separate_authority_after_witness":true},"environment":{"exact_metallib_byte_count":6292668,"exact_metallib_path":"/Users/runner/work/_temp/prime-native-decoder-stage5-replacement-build/arm64-apple-macosx/debug/PrimeNativeDecoderTrainingValidationPackageTests.xctest/Contents/Resources/mlx-swift_Cmlx.bundle/Contents/Resources/default.metallib","exact_metallib_sha256":"febfaba33d14e705e5d16f24dd4b8f0bb651d55da0e44065cac7d9c18b147004","exact_mlx_c_revision":"0726ca922fc902c4c61ef9c27d94132be418e945","exact_mlx_revision":"d37885a278f1c37484a94d0f401a418735e66519","lease_path":"/Users/runner/work/_temp/prime-native-decoder-stage5-replacement-metal-lease/device-0.lock","lease_type":"PrimeMetalDeviceLease","metal_device_count":1,"metal_device_index":0,"metal_device_is_default":true,"metal_device_name":"Apple Paravirtual device","metal_device_registry_id":4294967800,"mlx_compile_transform_invocation_count":0,"mlx_default_stream_is_gpu":true,"mlx_enable_tf32":"0","mlx_graph_compile_mode":"eager_uncompiled_no_compile_transform","operating_system_build":"26.5.2-25F84","swift_sdk":"26.5","swift_version":"Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) Target: arm64-apple-macosx26.0","swiftpm_build_configuration":"debug","xcode_version":"Xcode 26.6 Build version 17F113"},"execution":{"artifact_count":0,"authority_closure_active_job_conclusion":"success","authority_closure_active_job_id":94843969773,"authority_closure_check_suite_id":86338204723,"authority_closure_conclusion":"success","authority_closure_reviewed_job_conclusion":"success","authority_closure_reviewed_job_id":94844683376,"authority_closure_revision":"a0ce9561bdbc867b12f13aed7a7f54846faf3020","authority_closure_run_attempt":1,"authority_closure_run_id":31824087086,"authority_closure_run_number":115,"authority_closure_tree":"e7f85dcecbc82b7e74065cc1991175152f53c13f","build_count":1,"direct_xctest_count":1,"embedded_source_identity_sha256":"003a7c0d8be92319291cea399339a2b25500bfd743363583eddb615bf8e0cc0a","exact_changed_source_identities":[{"byte_count":717038,"git_blob":"2f5e139f5e79d4a5f3b1e481db8768aa7a9db920","git_mode":"100755","path":".github/scripts/prime-ci-active-root-quarantine.sh","role":"active_root_gate","sha256":"718375bcc556421b09fb380c896bcaceb8c23bd62dc5b8e4d29ec2f602228bf6"},{"byte_count":60532,"git_blob":"02c88d69e70a8e7bff2fe5975e8ae801b9839035","git_mode":"100755","path":".github/scripts/prime-ci-native-decoder-stage5-repeated-trajectory-replacement.sh","role":"replacement_launcher","sha256":"1967945c86f72a829b33f5cc58b33dc3e177650e34fc1f5b248dc7215a956e0f"},{"byte_count":88666,"git_blob":"f703b179982025e0a6596280c63a85d852406832","git_mode":"100644","path":".github/workflows/prime-active-root-quarantine.yml","role":"workflow","sha256":"255f485fcaf91dff35463e4964b822ae56ebea0b451d0681d3913cc649cf06c4"},{"byte_count":546,"git_blob":"e5b55e06b43035a459d6e09fda3446cb2cc2383c","git_mode":"100644","path":"Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift","role":"embedded_provenance","sha256":"09c04024d77ce164cbaa09e4104284630c5a8a82b2f81f1fa9ce0c03eccdc228"},{"byte_count":23783,"git_blob":"68a711c708eecff01b9d63795cdcb03c127d64b8","git_mode":"100644","path":"Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift","role":"current_decoder_identity_source","sha256":"88451317772e9ec05a1bb59362c4d2c3e953cb9284a3b9db65ee1892222f88c9"},{"byte_count":43339,"git_blob":"de6cff4472de55a8fafe2962c3be4ca37c972caf","git_mode":"100644","path":"Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift","role":"decoder_source","sha256":"ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc"},{"byte_count":97449,"git_blob":"4566477e14b4b6cfa06286f384f07f8d452e8724","git_mode":"100644","path":"Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift","role":"training_source","sha256":"cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb"},{"byte_count":23283,"git_blob":"f5b8e7787616d650b0a990227e2744b84d8b5e4c","git_mode":"100644","path":"Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift","role":"current_decoder_identity_test","sha256":"b0bdb47454adc6f9d69ec6e47f1cbc2df7c3c5aa8ccb1ac9d68a4ab593d605aa"},{"byte_count":142985,"git_blob":"1ed960a79c397cebcdfd3e9b62ab9acc67c894d7","git_mode":"100644","path":"Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift","role":"replacement_assay_test","sha256":"62aa2bdd1ac68c83630f771fe58ac36fa2e4a885e5e657cbcc56efe33b4ac836"},{"byte_count":35521,"git_blob":"9dbb273db5532ad5bf0c7eea502ec92204220bbd","git_mode":"100644","path":"Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift","role":"retained_decoder_authority_test","sha256":"f9a7cd1ff68065a53fd6fdf653010ebad74ff99b48fe437f43c41f2d417c7938"}],"exact_main_revision":"68422b34425fce761ce8d4afcbd7b0edbc1cf648","exact_main_tree":"658f7f2aa6a023efb37520bd7596c37b474ecda1","launcher_invocation_count":1,"lease_acquired_before_coregraphics_metal_or_mlx":true,"lease_path":"/Users/runner/work/_temp/prime-native-decoder-stage5-replacement-metal-lease/device-0.lock","mechanics_event":"push","mechanics_head_ordered_parent_revisions":["a0ce9561bdbc867b12f13aed7a7f54846faf3020","c778d7955976f2412826060aca3e1eb9e839d01d"],"mechanics_head_revision":"68422b34425fce761ce8d4afcbd7b0edbc1cf648","mechanics_head_tree":"658f7f2aa6a023efb37520bd7596c37b474ecda1","mechanics_ref":"refs/heads/main","mechanics_run_attempt":1,"one_shot_consumed":true,"original_stage5_launcher_invocation_count":0,"rerun_count":0,"retained_metal_device_identity":{"name":"Apple Paravirtual device","registry_id":4294967800},"retry_count":0,"stage6_launcher_invocation_count":0,"test_filter":"PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests/testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume"},"forward_equivalence":{"boundary_names":["initial","source_boundary","terminal"],"embedding_forward_exact_by_boundary":[{"boundary":"initial","exact":true,"trial_ordinal":1},{"boundary":"source_boundary","exact":true,"trial_ordinal":1},{"boundary":"terminal","exact":true,"trial_ordinal":1},{"boundary":"initial","exact":true,"trial_ordinal":2},{"boundary":"source_boundary","exact":true,"trial_ordinal":2},{"boundary":"terminal","exact":true,"trial_ordinal":2},{"boundary":"initial","exact":true,"trial_ordinal":3},{"boundary":"source_boundary","exact":true,"trial_ordinal":3},{"boundary":"terminal","exact":true,"trial_ordinal":3}],"same_model_pre_mutation":true,"whole_logits_exact_by_boundary":[{"boundary":"initial","exact":true,"trial_ordinal":1},{"boundary":"source_boundary","exact":true,"trial_ordinal":1},{"boundary":"terminal","exact":true,"trial_ordinal":1},{"boundary":"initial","exact":true,"trial_ordinal":2},{"boundary":"source_boundary","exact":true,"trial_ordinal":2},{"boundary":"terminal","exact":true,"trial_ordinal":2},{"boundary":"initial","exact":true,"trial_ordinal":3},{"boundary":"source_boundary","exact":true,"trial_ordinal":3},{"boundary":"terminal","exact":true,"trial_ordinal":3}]},"operation_counts":{"arm_a_source_step_count":6,"arm_b_dense_embedding_construction_count":66,"arm_b_dense_whole_logits_call_count":57,"arm_b_evaluate_count":18,"arm_b_forward_equivalence_check_count":9,"arm_b_input_embedding_pair_seam_count":9,"arm_b_restore_count":3,"arm_b_snapshot_count":3,"arm_b_token_bounds_checked_eval_count":66,"arm_b_token_bounds_gpu_synchronize_count":66,"arm_b_token_bounds_host_bool_item_count":66,"arm_b_token_bounds_validation_count":66,"arm_b_training_step_count":15,"receipt_count":1,"synchronize_count":75},"receipt_id":"ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_receipt_v1","schema_version":1,"status":"PASS_CLEARANCE"}
"""#

    public static let frozenV1: Self = {
        func source(
            _ path: String,
            _ mode: String,
            _ blob: String,
            _ bytes: Int,
            _ sha256: String,
            _ role: String
        ) -> SourceIdentity {
            .init(
                path: path,
                gitMode: mode,
                gitBlob: blob,
                byteCount: bytes,
                sha256: sha256,
                role: role)
        }

        let receiptPrefix =
            "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_RECEIPT_V1="
        let receiptTimestamp = "2026-08-14T20:34:19.4169310Z"

        return Self(
            schemaVersion: 1,
            observationID:
                "ergentics_prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_observation_v1",
            observationKind:
                "terminal_exact_main_stage5_replacement_pass_clearance_with_separate_outer_launcher_postflight_failure",
            predecessorAuthorityID:
                "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_authority_v1",
            predecessorAuthorityCanonicalSHA256:
                "e0b1fadf4075765078ba3cf29e7cce85be930791651020d45cba1b5b91466252",
            repositoryIdentity: .init(
                repository: "Ergentics/ergentics-prime",
                pullRequestNumber: 110,
                ref: "refs/heads/main",
                baseRevision: "a0ce9561bdbc867b12f13aed7a7f54846faf3020",
                baseTree: "e7f85dcecbc82b7e74065cc1991175152f53c13f",
                reviewedHeadRevision:
                    "c778d7955976f2412826060aca3e1eb9e839d01d",
                reviewedHeadTree:
                    "658f7f2aa6a023efb37520bd7596c37b474ecda1",
                mergeRevision: "68422b34425fce761ce8d4afcbd7b0edbc1cf648",
                mergeTree: "658f7f2aa6a023efb37520bd7596c37b474ecda1",
                orderedParentRevisions: [
                    "a0ce9561bdbc867b12f13aed7a7f54846faf3020",
                    "c778d7955976f2412826060aca3e1eb9e839d01d",
                ],
                mergedAt: "2026-08-14T19:42:53Z",
                mergeCommitSignatureVerified: true,
                mergeCommitSignatureReason: "valid",
                historyPreservingTwoParentMergeObserved: true,
                mergeTreeEqualsReviewedHeadTree: true,
                exactMainRefMatchedAtTerminalAudit: true,
                changedPathCount: 10,
                manifestOrLockChangedPathCount: 0),
            observedSourceBindings: [
                source(
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                    "100755", "2f5e139f5e79d4a5f3b1e481db8768aa7a9db920",
                    717_038,
                    "718375bcc556421b09fb380c896bcaceb8c23bd62dc5b8e4d29ec2f602228bf6",
                    "active_root_gate"),
                source(
                    ".github/scripts/prime-ci-native-decoder-stage5-repeated-trajectory-replacement.sh",
                    "100755", "02c88d69e70a8e7bff2fe5975e8ae801b9839035",
                    60_532,
                    "1967945c86f72a829b33f5cc58b33dc3e177650e34fc1f5b248dc7215a956e0f",
                    "replacement_launcher"),
                source(
                    ".github/workflows/prime-active-root-quarantine.yml",
                    "100644", "f703b179982025e0a6596280c63a85d852406832",
                    88_666,
                    "255f485fcaf91dff35463e4964b822ae56ebea0b451d0681d3913cc649cf06c4",
                    "workflow"),
                source(
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    "100644", "e5b55e06b43035a459d6e09fda3446cb2cc2383c",
                    546,
                    "09c04024d77ce164cbaa09e4104284630c5a8a82b2f81f1fa9ce0c03eccdc228",
                    "embedded_provenance"),
                source(
                    "Sources/PrimeCore/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservation.swift",
                    "100644", "68a711c708eecff01b9d63795cdcb03c127d64b8",
                    23_783,
                    "88451317772e9ec05a1bb59362c4d2c3e953cb9284a3b9db65ee1892222f88c9",
                    "current_decoder_identity_source"),
                source(
                    "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                    "100644", "de6cff4472de55a8fafe2962c3be4ca37c972caf",
                    43_339,
                    "ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc",
                    "decoder_source"),
                source(
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                    "100644", "4566477e14b4b6cfa06286f384f07f8d452e8724",
                    97_449,
                    "cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb",
                    "training_source"),
                source(
                    "Tests/PrimeCoreTests/PrimeNativeDecoderStage5RepeatedTrajectoryReplacementCurrentDecoderIdentityObservationTests.swift",
                    "100644", "f5b8e7787616d650b0a990227e2744b84d8b5e4c",
                    23_283,
                    "b0bdb47454adc6f9d69ec6e47f1cbc2df7c3c5aa8ccb1ac9d68a4ab593d605aa",
                    "current_decoder_identity_test"),
                source(
                    "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift",
                    "100644", "1ed960a79c397cebcdfd3e9b62ab9acc67c894d7",
                    142_985,
                    "62aa2bdd1ac68c83630f771fe58ac36fa2e4a885e5e657cbcc56efe33b4ac836",
                    "replacement_assay_test"),
                source(
                    "Tests/PrimeNativeDecoderValidation/Tests/PrimeNativeDecoderTests/PrimeNativeDecoderAuthorityTests.swift",
                    "100644", "9dbb273db5532ad5bf0c7eea502ec92204220bbd",
                    35_521,
                    "f9a7cd1ff68065a53fd6fdf653010ebad74ff99b48fe437f43c41f2d417c7938",
                    "retained_decoder_authority_test"),
            ],
            runIdentity: .init(
                workflowID: 329_017_041,
                workflowName: "Prime active-root quarantine",
                workflowPath:
                    ".github/workflows/prime-active-root-quarantine.yml",
                runID: 31_834_513_845,
                runNumber: 117,
                runAttempt: 1,
                checkSuiteID: 86_367_936_511,
                event: "push",
                headBranch: "main",
                headRevision: "68422b34425fce761ce8d4afcbd7b0edbc1cf648",
                actor: "psyop-archivist",
                triggeringActor: "psyop-archivist",
                createdAt: "2026-08-14T19:42:56Z",
                startedAt: "2026-08-14T19:42:56Z",
                terminalUpdatedAt: "2026-08-14T20:34:30Z",
                status: "completed",
                conclusion: "failure",
                exactHeadPushRunCount: 1,
                previousAttemptURLWasNull: true,
                rerunCount: 0,
                rerunObserved: false,
                rerunAuthorized: false,
                artifactCount: 0,
                runURL:
                    "https://github.com/Ergentics/ergentics-prime/actions/runs/31834513845"),
            activeRootJob: job(
                94_877_692_182,
                "First-party MLX / active-root quarantine",
                "success",
                "2026-08-14T19:42:59Z",
                "2026-08-14T19:45:29Z",
                1_000_001_766,
                "GitHub Actions 1000001766",
                "macos-15",
                [
                    "Set up job",
                    "Check out the exact Prime revision",
                    "Validate active metadata and preserved history",
                    "Parse the changed Swift contracts without dependencies",
                    "Validate isolated Latin capture and observation contracts",
                    "Record the authority ceiling",
                    "Complete job",
                ],
                Array(repeating: "success", count: 7),
                0, "", 0, "",
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31834513845/job/94877692182"),
            reviewedMainJob: job(
                94_878_305_625,
                "Reviewed main / focused source contracts",
                "failure",
                "2026-08-14T19:45:33Z",
                "2026-08-14T20:34:30Z",
                1_000_001_767,
                "GitHub Actions 1000001767",
                "macos-26",
                [
                    "Set up job",
                    "Record the hosted Apple toolchain",
                    "Check out reviewed main exactly",
                    "Fetch the exact private dependency without evaluating Prime",
                    "Compile and run the focused contracts without a credential",
                    "Run the Prime-owned decoder on live Metal",
                    "Complete job",
                ],
                [
                    "success", "success", "success", "success", "success",
                    "failure", "success",
                ],
                1, ".github", 75_394,
                "Process completed with exit code 2.",
                "https://github.com/Ergentics/ergentics-prime/actions/runs/31834513845/job/94878305625"),
            activeRootRawLog: rawLog(
                272_058, 1_820,
                "b86a463fd351bd91e25bb7dfa2929c88a7ab07c2d2c21f84a0050cab33b3f1cb"),
            reviewedMainRawLog: rawLog(
                10_345_902, 79_185,
                "baf8736d0578a5c92440ada6400bb07318d5b122c87de6be6f3a405782445f78"),
            testTopology: .init(
                rootTestCount: 58,
                isolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
                isolatedCheckpointTestCount: 6,
                focusedWholeTestCount: 64,
                metalTestCount: 44,
                maintainedRuntimeTestCount: 1,
                tokenizerTestCount: 1,
                replacementAssayTestCount: 1,
                totalTestCount: 111,
                totalFailureCount: 0,
                totalSkipCount: 0,
                observedLiveExecutionOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                    "stage5_replacement",
                ]),
            replacementTestBoundary: .init(
                jobStepNumber: 6,
                jobStepName: "Run the Prime-owned decoder on live Metal",
                jobStepStartedAt: "2026-08-14T20:09:40Z",
                jobStepCompletedAt: "2026-08-14T20:34:19Z",
                launcherInvocationCount: 1,
                buildInvocationCount: 1,
                buildCompletionCount: 1,
                buildDurationMilliseconds: 187_840,
                directXCTestInvocationCount: 1,
                testFile:
                    "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests.swift",
                testClass:
                    "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests",
                testMethod:
                    "testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume",
                testFilter:
                    "PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementTests/testMaintainedGatherDiagnosticAndFlattenedDenseOneHotMatmulExactResume",
                testStartCount: 1,
                testPassCount: 1,
                testFailureCount: 0,
                testSkipCount: 0,
                testDurationMilliseconds: 6_932,
                receiptCount: 1,
                receiptStatus: "PASS_CLEARANCE",
                receiptEmittedBeforeTestPass: true),
            receiptIdentity: .init(
                prefix: receiptPrefix,
                prefixByteCount: 51,
                canonicalJSON: frozenReceiptCanonicalJSON,
                canonicalJSONByteCount: 13_036,
                canonicalJSONSHA256:
                    "ce939ca5f6e9e5d37cf61b412dcb02d811495909466903c8575169265a330fb0",
                storageByteCountIncludingLF: 13_037,
                storageSHA256IncludingLF:
                    "b8b202c0408d0379a390e4fe12053ef4ac79914c4431e5eb93ba55c64578e2e0",
                prefixedCanonicalByteCount: 13_087,
                prefixedCanonicalSHA256:
                    "2154abe45f7e0c65e8196f8ebc4aabab0363caf18ce93d10c72f822ac8ade1f3",
                prefixedCanonicalLFByteCount: 13_088,
                prefixedCanonicalLFSHA256:
                    "751c73d0cca21c4a705345fa9c76ba480df850d353aae005179c6272c6cf4f8c",
                fullTimestampedLine:
                    receiptTimestamp + " " + receiptPrefix
                        + frozenReceiptCanonicalJSON,
                fullTimestampedLineByteCount: 13_116,
                fullTimestampedLineSHA256:
                    "cce381a08a4b77b2210ede6511dd7ae61c15eca4db1371dccceb4980f2fc4b3f",
                logLineNumber: 79_175,
                emittedAt: receiptTimestamp,
                exactOccurrenceCount: 1,
                receiptID:
                    "ergentics_prime_native_decoder_stage5_repeated_trajectory_replacement_receipt_v1",
                schemaVersion: 1,
                status: "PASS_CLEARANCE",
                authorityID:
                    "prime_native_decoder_tiny_repeated_metal_trajectory_determinism_assay_replacement_execution_authority_v1",
                authorityCanonicalSHA256:
                    "e0b1fadf4075765078ba3cf29e7cce85be930791651020d45cba1b5b91466252"),
            operationCounts: .init(
                armASourceStepCount: 6,
                armBTrainingStepCount: 15,
                armBEvaluateCount: 18,
                armBSnapshotCount: 3,
                armBRestoreCount: 3,
                armBForwardEquivalenceCheckCount: 9,
                armBInputEmbeddingPairSeamCount: 9,
                armBDenseWholeLogitsCallCount: 57,
                armBDenseEmbeddingConstructionCount: 66,
                armBTokenBoundsValidationCount: 66,
                armBTokenBoundsCheckedEvalCount: 66,
                armBTokenBoundsGPUSynchronizeCount: 66,
                armBTokenBoundsHostBoolItemCount: 66,
                synchronizeCount: 75,
                receiptCount: 1),
            clearanceBoundary: .init(
                armAIsDiagnosticOnly: true,
                armAGatesOrSkipsArmB: false,
                armATrialCount: 3,
                armACompletedDiagnosticPairCount: 3,
                armAMeasuredMismatch: false,
                armBTrialCount: 3,
                armBBranchCount: 9,
                armBBranchNames: [
                    "uninterrupted", "source_snapshot",
                    "fresh_restored_from_source_snapshot",
                ],
                armBComparisonDomains: [
                    "control_rng_and_cursor_state",
                    "evaluation_loss_and_logits_bytes",
                    "global_step_and_selected_target_count",
                    "model_parameter_bytes",
                    "optimizer_first_and_second_moment_bytes",
                    "raw_and_clipped_gradient_bytes",
                    "training_loss_norm_and_clip_scalar_bits",
                ],
                armBAllExactComparisonsPassed: true,
                armBAllForwardEquivalenceChecksPassed: true,
                armBFirstMismatchObserved: false,
                sameModelPreMutationForwardEquivalence: true,
                forwardEquivalenceBoundaries: [
                    "initial", "source_boundary", "terminal",
                ],
                flattenedDenseOneHotMatmulSelectorID:
                    "flattened_dense_one_hot_matmul_input_embedding_v1",
                sameDeviceBPathExactGradientBytesEstablished: true,
                repeatedSameDeviceBPathDeterminismEstablished: true,
                stage5MechanicsSuccessEstablished: true,
                stage5ResultEstablished: true,
                stage5AssayClearanceEstablished: true),
            outerLauncherFailureBoundary: .init(
                testOutcomeWasPass: true,
                outerWorkflowOutcomeWasFailure: true,
                failureOccurredAfterReceiptAndTestPass: true,
                aggregateGuardSourceLines: [1122, 1123, 1124, 1125, 1126],
                aggregateGuardConjuncts: [
                    "lease_root_is_directory",
                    "lease_root_is_not_symbolic_link",
                    "lease_root_physical_path_equals_exact_lease_root",
                    "lease_root_owner_uid_equals_effective_uid",
                    "lease_root_mode_equals_0700",
                    "lease_root_link_count_equals_2",
                ],
                aggregateGuardFailed: true,
                failedConjunctIdentified: false,
                actualLeaseParentMetadataObserved: false,
                exactLauncherFailureMessage:
                    "replacement lease parent identity changed",
                exactFailureLine:
                    "swift-driver version: 1.148.6 prime-native-decoder-stage5-repeated-trajectory-replacement: replacement lease parent identity changed",
                failureLoggedAt: "2026-08-14T20:34:19.5246420Z",
                exactFailureLineOccurrenceCount: 1,
                launcherExitCode: 2,
                workflowProcessExitCode: 2,
                workflowExitAnnotationOccurrenceCount: 1,
                localAPFSLinkCountReproductionBoundAsCause: false,
                nextLeaseFileGuardReached: false,
                exactChildInventoryGuardReached: false,
                leaseFileRemovalReached: false,
                leaseParentRemovalReached: false,
                cleanupAbsenceProofReached: false,
                repositoryPostflightReached: false,
                privateWorkingDirectoryPostflightReached: false,
                metallibPostflightReached: false,
                launcherOKMarkerReached: false),
            leaseBoundary: .init(
                environmentKey:
                    "PRIME_NATIVE_DECODER_STAGE5_REPLACEMENT_METAL_LEASE_PATH",
                parentPath:
                    "/Users/runner/work/_temp/prime-native-decoder-stage5-replacement-metal-lease",
                leasePath:
                    "/Users/runner/work/_temp/prime-native-decoder-stage5-replacement-metal-lease/device-0.lock",
                acquiredBeforeCoreGraphicsMetalOrMLX: true,
                retainedDeviceName: "Apple Paravirtual device",
                retainedDeviceRegistryID: 4_294_967_800,
                receiptConstructedValidatedAndRoundTrippedWhileHeld: true,
                receiptEmissionCheckedWhileHeld: true,
                receiptFlushCheckedWhileHeld: true,
                explicitReleaseAfterReceiptReached: true,
                outerLeaseParentCleanupCompleted: false),
            retirementBoundary: .init(
                retirementRequired: true,
                retirementObserved: false,
                exactChangedPathCount: 5,
                exactOrderedChangedPaths: [
                    ".github/scripts/prime-ci-active-root-quarantine.sh",
                    ".github/workflows/prime-active-root-quarantine.yml",
                    "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    "Sources/PrimeCore/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservation.swift",
                    "Tests/PrimeCoreTests/PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationTests.swift",
                ],
                expectedRootTestCount: 59,
                expectedIsolatedCheckpointGroupTestCounts: [1, 1, 2, 2],
                expectedIsolatedCheckpointTestCount: 6,
                expectedFocusedWholeTestCount: 65,
                expectedMetalTestCount: 44,
                expectedMaintainedRuntimeTestCount: 1,
                expectedTokenizerTestCount: 1,
                expectedReplacementAssayTestCount: 0,
                expectedTotalTestCount: 111,
                expectedFailureCount: 0,
                expectedSkipCount: 0,
                expectedLiveExecutionOrder: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                expectedOriginalStage5LauncherInvocationCount: 0,
                expectedOriginalStage5ReceiptCount: 0,
                expectedReplacementStage5LauncherInvocationCount: 0,
                expectedReplacementStage5ReceiptCount: 0,
                expectedStage6LauncherInvocationCount: 0,
                expectedStage6ReceiptCount: 0,
                expectedReviewedMainTimeoutMinutes: 60,
                replacementLauncherPreservedForAudit: true,
                replacementAssaySourcePreservedForAudit: true,
                replacementLiveExecutionPermittedByRetirement: false),
            authorityCeiling: .init(
                oneShotConsumed: true,
                oneShotExhausted: true,
                additionalExecutionOrRerunAuthorized: false,
                retryAuthorized: false,
                rerunAuthorized: false,
                replacementExecutionAuthorized: false,
                stage5ReceiptEstablished: true,
                stage5MechanicsSuccessEstablished: true,
                stage5ResultEstablished: true,
                stage5AssayClearanceEstablished: true,
                launcherPostReceiptCompletionEstablished: false,
                outerWorkflowSuccessEstablished: false,
                repeatedSameDeviceBPathDeterminismEstablished: true,
                exactSameDeviceBPathGradientBytesEstablished: true,
                defaultGatherDeterminismEstablished: false,
                arbitraryTokenDeterminismEstablished: false,
                crossDeviceDeterminismEstablished: false,
                durableCheckpointIOAuthorized: false,
                retainedArtifactAuthorized: false,
                artifactUploadAuthorized: false,
                candidateAdmissionGranted: false,
                modelQualityEstablished: false,
                downstreamTrialAuthorized: false,
                canaryAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false,
                stage6HistoricalResourceClearanceRemainsEstablished: true,
                stage6HistoricalResourceClearanceAppliesToBPath: false,
                bSpecificNative300ResourceWitnessEstablished: false,
                bSpecificNative300ResourceWitnessAuthorized: false,
                bSpecificNative300ResourceWitnessRequiresSeparateAuthority: true,
                stage7RequiresNewBSpecificNative300ResourceWitness: true,
                stage7RequiresSeparateAuthorityAfterWitness: true,
                stage7AuthorityEstablished: false,
                stage7Authorized: false),
            orderedRequiredSeparateActions: [
                "retire_consumed_stage5_replacement_live_invocation_without_rerun",
                "preserve_replacement_launcher_and_assay_sources_for_audit",
                "retain_unknown_failed_lease_parent_guard_conjunct_and_metadata",
                "obtain_new_separate_authority_for_b_specific_native300_resource_witness",
                "obtain_separate_stage7_authority_only_after_that_witness",
            ],
            status:
                "PASS_CLEARANCE_exact_main_stage5_replacement_one_test_passed_one_receipt_then_outer_launcher_postflight_failure_one_shot_consumed_no_rerun_stage7_false")
    }()

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationError
                    .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let contractError =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionObservationError
                .contractDrift
        let predecessor =
            PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            guard predecessorAuthorityID == predecessor.authorityID,
                  predecessorAuthorityCanonicalSHA256
                    == PrimeNativeDecoderTinyRepeatedMetalTrajectoryDeterminismAssayReplacementExecutionAuthorityV1
                        .canonicalSHA256 else {
                throw contractError("predecessor authority")
            }
        } catch {
            throw contractError("predecessor authority")
        }

        let repository = repositoryIdentity
        let run = runIdentity
        let topology = testTopology
        let assay = replacementTestBoundary
        let receipt = receiptIdentity
        let counts = operationCounts
        let clearance = clearanceBoundary
        let outer = outerLauncherFailureBoundary
        let lease = leaseBoundary
        let retirement = retirementBoundary
        let ceiling = authorityCeiling

        guard let receiptData = receipt.canonicalJSON.data(using: .utf8),
              let prefixData = receipt.prefix.data(using: .utf8),
              let timestampedData = receipt.fullTimestampedLine.data(using: .utf8)
        else {
            throw contractError("receipt UTF-8")
        }
        let prefixedData = prefixData + receiptData
        let storageData = receiptData + Data([0x0A])
        let prefixedLFData = prefixedData + Data([0x0A])
        guard let receiptObject = try? JSONSerialization.jsonObject(
            with: receiptData),
              let normalizedReceipt = try? JSONSerialization.data(
                withJSONObject: receiptObject,
                options: [.sortedKeys, .withoutEscapingSlashes])
        else {
            throw contractError("receipt JSON")
        }

        let falseClaims = [
            ceiling.additionalExecutionOrRerunAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.replacementExecutionAuthorized,
            ceiling.launcherPostReceiptCompletionEstablished,
            ceiling.outerWorkflowSuccessEstablished,
            ceiling.defaultGatherDeterminismEstablished,
            ceiling.arbitraryTokenDeterminismEstablished,
            ceiling.crossDeviceDeterminismEstablished,
            ceiling.durableCheckpointIOAuthorized,
            ceiling.retainedArtifactAuthorized,
            ceiling.artifactUploadAuthorized,
            ceiling.candidateAdmissionGranted,
            ceiling.modelQualityEstablished,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage6HistoricalResourceClearanceAppliesToBPath,
            ceiling.bSpecificNative300ResourceWitnessEstablished,
            ceiling.bSpecificNative300ResourceWitnessAuthorized,
            ceiling.stage7AuthorityEstablished,
            ceiling.stage7Authorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              repository.orderedParentRevisions
                == [repository.baseRevision, repository.reviewedHeadRevision],
              repository.reviewedHeadTree == repository.mergeTree,
              repository.mergeRevision == run.headRevision,
              repository.changedPathCount == observedSourceBindings.count,
              repository.manifestOrLockChangedPathCount == 0,
              Set(observedSourceBindings.map(\.path)).count == 10,
              observedSourceBindings.allSatisfy(Self.validSource),
              run.runAttempt == 1,
              run.exactHeadPushRunCount == 1,
              run.previousAttemptURLWasNull,
              run.rerunCount == 0,
              !run.rerunObserved,
              !run.rerunAuthorized,
              run.artifactCount == 0,
              activeRootJob.orderedStepNames.count == 7,
              activeRootJob.orderedStepConclusions
                == Array(repeating: "success", count: 7),
              reviewedMainJob.orderedStepNames.count == 7,
              reviewedMainJob.orderedStepConclusions
                == [
                    "success", "success", "success", "success", "success",
                    "failure", "success",
                ],
              Self.validRawLog(activeRootRawLog),
              Self.validRawLog(reviewedMainRawLog),
              topology.isolatedCheckpointGroupTestCounts == [1, 1, 2, 2],
              topology.isolatedCheckpointTestCount
                == topology.isolatedCheckpointGroupTestCounts.reduce(0, +),
              topology.focusedWholeTestCount
                == topology.rootTestCount + topology.isolatedCheckpointTestCount,
              topology.totalTestCount
                == topology.focusedWholeTestCount + topology.metalTestCount
                    + topology.maintainedRuntimeTestCount
                    + topology.tokenizerTestCount
                    + topology.replacementAssayTestCount,
              topology.totalFailureCount == 0,
              topology.totalSkipCount == 0,
              assay.launcherInvocationCount == 1,
              assay.buildInvocationCount == 1,
              assay.buildCompletionCount == 1,
              assay.directXCTestInvocationCount == 1,
              assay.testStartCount == 1,
              assay.testPassCount == 1,
              assay.testFailureCount == 0,
              assay.testSkipCount == 0,
              assay.receiptCount == 1,
              assay.receiptStatus == "PASS_CLEARANCE",
              assay.receiptEmittedBeforeTestPass,
              receipt.prefixByteCount == prefixData.count,
              receipt.canonicalJSON == Self.frozenReceiptCanonicalJSON,
              receipt.canonicalJSONByteCount == receiptData.count,
              receipt.canonicalJSONSHA256
                == PrimeSHA256.hexDigest(of: receiptData),
              normalizedReceipt == receiptData,
              receipt.storageByteCountIncludingLF == storageData.count,
              receipt.storageSHA256IncludingLF
                == PrimeSHA256.hexDigest(of: storageData),
              receipt.prefixedCanonicalByteCount == prefixedData.count,
              receipt.prefixedCanonicalSHA256
                == PrimeSHA256.hexDigest(of: prefixedData),
              receipt.prefixedCanonicalLFByteCount == prefixedLFData.count,
              receipt.prefixedCanonicalLFSHA256
                == PrimeSHA256.hexDigest(of: prefixedLFData),
              receipt.fullTimestampedLine
                == receipt.emittedAt + " " + receipt.prefix
                    + receipt.canonicalJSON,
              receipt.fullTimestampedLineByteCount == timestampedData.count,
              receipt.fullTimestampedLineSHA256
                == PrimeSHA256.hexDigest(of: timestampedData),
              receipt.exactOccurrenceCount == 1,
              receipt.schemaVersion == 1,
              receipt.status == "PASS_CLEARANCE",
              receipt.authorityID == predecessorAuthorityID,
              receipt.authorityCanonicalSHA256
                == predecessorAuthorityCanonicalSHA256,
              counts.armASourceStepCount == 6,
              counts.armBTrainingStepCount == 15,
              counts.armBEvaluateCount == 18,
              counts.armBSnapshotCount == 3,
              counts.armBRestoreCount == 3,
              counts.armBForwardEquivalenceCheckCount == 9,
              counts.armBInputEmbeddingPairSeamCount == 9,
              counts.armBDenseWholeLogitsCallCount == 57,
              counts.armBDenseEmbeddingConstructionCount == 66,
              counts.armBTokenBoundsValidationCount == 66,
              counts.armBTokenBoundsCheckedEvalCount == 66,
              counts.armBTokenBoundsGPUSynchronizeCount == 66,
              counts.armBTokenBoundsHostBoolItemCount == 66,
              counts.synchronizeCount == 75,
              counts.receiptCount == 1,
              clearance.armAIsDiagnosticOnly,
              !clearance.armAGatesOrSkipsArmB,
              clearance.armATrialCount == 3,
              clearance.armACompletedDiagnosticPairCount == 3,
              !clearance.armAMeasuredMismatch,
              clearance.armBTrialCount == 3,
              clearance.armBBranchCount == 9,
              clearance.armBBranchNames.count == 3,
              clearance.armBComparisonDomains.count == 7,
              clearance.armBAllExactComparisonsPassed,
              clearance.armBAllForwardEquivalenceChecksPassed,
              !clearance.armBFirstMismatchObserved,
              clearance.sameModelPreMutationForwardEquivalence,
              clearance.forwardEquivalenceBoundaries
                == ["initial", "source_boundary", "terminal"],
              clearance.sameDeviceBPathExactGradientBytesEstablished,
              clearance.repeatedSameDeviceBPathDeterminismEstablished,
              clearance.stage5MechanicsSuccessEstablished,
              clearance.stage5ResultEstablished,
              clearance.stage5AssayClearanceEstablished,
              outer.testOutcomeWasPass,
              outer.outerWorkflowOutcomeWasFailure,
              outer.failureOccurredAfterReceiptAndTestPass,
              outer.aggregateGuardSourceLines == [1122, 1123, 1124, 1125, 1126],
              outer.aggregateGuardConjuncts.count == 6,
              outer.aggregateGuardFailed,
              !outer.failedConjunctIdentified,
              !outer.actualLeaseParentMetadataObserved,
              outer.exactFailureLine.hasSuffix(
                outer.exactLauncherFailureMessage),
              outer.exactFailureLineOccurrenceCount == 1,
              outer.launcherExitCode == 2,
              outer.workflowProcessExitCode == 2,
              outer.workflowExitAnnotationOccurrenceCount == 1,
              !outer.localAPFSLinkCountReproductionBoundAsCause,
              Self.outerUnreachedClaims(outer).allSatisfy({ !$0 }),
              lease.acquiredBeforeCoreGraphicsMetalOrMLX,
              lease.receiptConstructedValidatedAndRoundTrippedWhileHeld,
              lease.receiptEmissionCheckedWhileHeld,
              lease.receiptFlushCheckedWhileHeld,
              lease.explicitReleaseAfterReceiptReached,
              !lease.outerLeaseParentCleanupCompleted,
              retirement.retirementRequired,
              !retirement.retirementObserved,
              retirement.exactChangedPathCount
                == retirement.exactOrderedChangedPaths.count,
              Set(retirement.exactOrderedChangedPaths).count == 5,
              retirement.expectedIsolatedCheckpointGroupTestCounts
                == [1, 1, 2, 2],
              retirement.expectedIsolatedCheckpointTestCount == 6,
              retirement.expectedFocusedWholeTestCount
                == retirement.expectedRootTestCount
                    + retirement.expectedIsolatedCheckpointTestCount,
              retirement.expectedTotalTestCount
                == retirement.expectedFocusedWholeTestCount
                    + retirement.expectedMetalTestCount
                    + retirement.expectedMaintainedRuntimeTestCount
                    + retirement.expectedTokenizerTestCount
                    + retirement.expectedReplacementAssayTestCount,
              retirement.expectedTotalTestCount == topology.totalTestCount,
              retirement.expectedFailureCount == 0,
              retirement.expectedSkipCount == 0,
              retirement.expectedReplacementAssayTestCount == 0,
              retirement.expectedOriginalStage5LauncherInvocationCount == 0,
              retirement.expectedOriginalStage5ReceiptCount == 0,
              retirement.expectedReplacementStage5LauncherInvocationCount == 0,
              retirement.expectedReplacementStage5ReceiptCount == 0,
              retirement.expectedStage6LauncherInvocationCount == 0,
              retirement.expectedStage6ReceiptCount == 0,
              retirement.expectedReviewedMainTimeoutMinutes == 60,
              retirement.replacementLauncherPreservedForAudit,
              retirement.replacementAssaySourcePreservedForAudit,
              !retirement.replacementLiveExecutionPermittedByRetirement,
              ceiling.oneShotConsumed,
              ceiling.oneShotExhausted,
              ceiling.stage5ReceiptEstablished,
              ceiling.stage5MechanicsSuccessEstablished,
              ceiling.stage5ResultEstablished,
              ceiling.stage5AssayClearanceEstablished,
              ceiling.repeatedSameDeviceBPathDeterminismEstablished,
              ceiling.exactSameDeviceBPathGradientBytesEstablished,
              ceiling.stage6HistoricalResourceClearanceRemainsEstablished,
              ceiling.bSpecificNative300ResourceWitnessRequiresSeparateAuthority,
              ceiling.stage7RequiresNewBSpecificNative300ResourceWitness,
              ceiling.stage7RequiresSeparateAuthorityAfterWitness,
              falseClaims.allSatisfy({ !$0 }) else {
            throw contractError("frozen observation")
        }
    }

    private static func job(
        _ id: Int,
        _ name: String,
        _ conclusion: String,
        _ startedAt: String,
        _ completedAt: String,
        _ runnerID: Int,
        _ runnerName: String,
        _ runnerLabel: String,
        _ stepNames: [String],
        _ stepConclusions: [String],
        _ annotationCount: Int,
        _ annotationPath: String,
        _ annotationLine: Int,
        _ annotationMessage: String,
        _ url: String
    ) -> JobIdentity {
        .init(
            id: id,
            name: name,
            status: "completed",
            conclusion: conclusion,
            startedAt: startedAt,
            completedAt: completedAt,
            runnerID: runnerID,
            runnerName: runnerName,
            runnerGroupName: "GitHub Actions",
            runnerLabel: runnerLabel,
            orderedStepNames: stepNames,
            orderedStepConclusions: stepConclusions,
            checkAnnotationCount: annotationCount,
            checkAnnotationPath: annotationPath,
            checkAnnotationLine: annotationLine,
            checkAnnotationMessage: annotationMessage,
            jobURL: url)
    }

    private static func rawLog(
        _ bytes: Int,
        _ lines: Int,
        _ sha256: String
    ) -> RawLogIdentity {
        .init(
            byteCount: bytes,
            lfByteCount: lines,
            newlineDelimitedComponentCountIncludingTerminalEmpty: lines + 1,
            utf8BOMHex: "efbbbf",
            startsWithUTF8BOM: true,
            usesLFOnly: true,
            endsWithLF: true,
            sha256: sha256,
            bindingKind: "github_job_log_endpoint_decoded_utf8_bytes_v1",
            rawGitHubLogArchiveBytesBound: false,
            retainedInRepository: false)
    }

    private static func validSource(_ source: SourceIdentity) -> Bool {
        !source.path.isEmpty
            && ["100644", "100755"].contains(source.gitMode)
            && validLowercaseHex(source.gitBlob, count: 40)
            && source.byteCount > 0
            && validLowercaseHex(source.sha256, count: 64)
            && !source.role.isEmpty
    }

    private static func validRawLog(_ log: RawLogIdentity) -> Bool {
        log.byteCount > 0
            && log.lfByteCount > 0
            && log.newlineDelimitedComponentCountIncludingTerminalEmpty
                == log.lfByteCount + 1
            && log.utf8BOMHex == "efbbbf"
            && log.startsWithUTF8BOM
            && log.usesLFOnly
            && log.endsWithLF
            && validLowercaseHex(log.sha256, count: 64)
            && !log.rawGitHubLogArchiveBytesBound
            && !log.retainedInRepository
    }

    private static func outerUnreachedClaims(
        _ boundary: OuterLauncherFailureBoundary
    ) -> [Bool] {
        [
            boundary.nextLeaseFileGuardReached,
            boundary.exactChildInventoryGuardReached,
            boundary.leaseFileRemovalReached,
            boundary.leaseParentRemovalReached,
            boundary.cleanupAbsenceProofReached,
            boundary.repositoryPostflightReached,
            boundary.privateWorkingDirectoryPostflightReached,
            boundary.metallibPostflightReached,
            boundary.launcherOKMarkerReached,
        ]
    }

    private static func validLowercaseHex(
        _ value: String,
        count: Int
    ) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy { scalar in
                (scalar.value >= 48 && scalar.value <= 57)
                    || (scalar.value >= 97 && scalar.value <= 102)
            }
    }
}
