// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct
    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairSourceIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String
    public let claimScope: String
}

public struct
    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairRawLogIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let label: String
    public let byteCount: Int
    public let lfByteCount: Int
    public let sha256: String
    public let startsWithUTF8BOM: Bool
    public let usesLFOnly: Bool
    public let endsWithLF: Bool
}

public struct
    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairReceiptIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let prefix: String
    public let receiptID: String
    public let count: Int
    public let jsonByteCount: Int
    public let jsonSHA256: String
    public let metallibByteCount: Int
    public let metallibSHA256: String
    public let requiredStatus: String
    public let executedRevision: String
    public let executedTree: String
    public let executedEmbeddedSourceIdentitySHA256: String
    public let outcomeEstablished: Bool
    public let trainingExecutionObserved: Bool
    public let trainEvaluateSurfaceEstablished: Bool
}

public struct
    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairGreenPrerequisiteV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let mergedAt: String
    public let historyPreservingTwoParentMergeObserved: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
    public let mergeCommitSignatureVerified: Bool
    public let mergeCommitSignatureReason: String
    public let mergeCommitSignatureVerifiedAt: String
    public let embeddedSourceIdentitySHA256: String
    public let workflowID: Int
    public let runID: Int
    public let runNumber: Int
    public let runAttempt: Int
    public let checkSuiteID: Int
    public let exactHeadPushRunCount: Int
    public let previousAttemptURLAbsent: Bool
    public let secondAttemptEndpointHTTPStatus: Int
    public let rerunCount: Int
    public let runCreatedAt: String
    public let runStartedAt: String
    public let runUpdatedAt: String
    public let runConclusion: String
    public let activeRootJobID: Int
    public let activeRootRunnerID: Int
    public let activeRootStartedAt: String
    public let activeRootCompletedAt: String
    public let activeRootCompletedStepCount: Int
    public let activeRootConclusion: String
    public let reviewedMainJobID: Int
    public let reviewedMainRunnerID: Int
    public let reviewedMainStartedAt: String
    public let reviewedMainCompletedAt: String
    public let reviewedMainCompletedStepCount: Int
    public let reviewedMainConclusion: String
    public let runnerArchitecture: String
    public let reviewedRunnerOperatingSystem: String
    public let xcodeVersion: String
    public let xcodeBuildVersion: String
    public let swiftVersion: String
    public let swiftTarget: String
    public let sdkVersion: String
    public let secureFetchWorkflowBlockSHA256: String
    public let secureFetchCommandCount: Int
    public let recursiveSubmoduleUpdateCommandCount: Int
    public let workflowAuthoredRetryCount: Int
    public let separateSecureFetchRetryStepCount: Int
    public let gitInternalSubmoduleRetryScheduledCount: Int
    public let mlxSubmoduleCloneAttemptCount: Int
    public let mlxCSubmoduleCloneAttemptCount: Int
    public let gitSubmoduleTLSFailureCount: Int
    public let tlsVerificationBypassCount: Int
    public let customCAInstallationCount: Int
    public let mlxRevision: String
    public let mlxCoreRevision: String
    public let mlxCRevision: String
    public let focusedRootTestCount: Int
    public let focusedRootFailureCount: Int
    public let focusedRootSkipCount: Int
    public let isolatedFocusedGroupTestCounts: [Int]
    public let focusedWholeStepTestCount: Int
    public let focusedWholeStepFailureCount: Int
    public let focusedWholeStepSkipCount: Int
    public let retainedLiveSequence: [String]
    public let retainedLiveInvocationCounts: [Int]
    public let metallibBuildInvocationCount: Int
    public let metallibBuildCompletionCount: Int
    public let metallibByteCount: Int
    public let metallibSHA256: String
    public let metalTestCount: Int
    public let metalFailureCount: Int
    public let metalSkipCount: Int
    public let runtimeTestCount: Int
    public let runtimeFailureCount: Int
    public let runtimeSkipCount: Int
    public let tokenizerTestCount: Int
    public let tokenizerFailureCount: Int
    public let tokenizerSkipCount: Int
    public let preStage2CompletedTestCount: Int
    public let preStage2FailureCount: Int
    public let preStage2SkipCount: Int
    public let runtimeReceipt:
        PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairReceiptIdentityV1
    public let tokenizerReceipt:
        PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairReceiptIdentityV1
    public let stage2LauncherInvocationCount: Int
    public let stage2BuildInvocationCount: Int
    public let stage2MetallibCopyCount: Int
    public let stage2DirectXCTestInvocationCount: Int
    public let stage2TestStartCount: Int
    public let stage2TestPassCount: Int
    public let stage2TestFailureCount: Int
    public let stage2TestSkipCount: Int
    public let stage2ReceiptCount: Int
    public let actionsArtifactsTotalCount: Int
    public let actionsArtifactsArrayExactlyEmpty: Bool
    public let runLogArchiveByteCount: Int
    public let runLogArchiveMemberCount: Int
    public let runLogArchiveUncompressedByteCount: Int
    public let runLogArchiveSHA256: String
    public let rawLogs:
        [PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairRawLogIdentityV1]
    public let exactGreenPrerequisiteSatisfied: Bool
}

public struct
    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairFailureConsumptionV1:
    Codable,
    Equatable,
    Sendable
{
    public let failureObservationID: String
    public let failureObservationCanonicalSHA256: String
    public let exhaustedRunID: Int
    public let exhaustedRunAttempt: Int
    public let failedLauncherPath: String
    public let failedLauncherGitMode: String
    public let failedLauncherGitBlob: String
    public let failedLauncherByteCount: Int
    public let failedLauncherSHA256: String
    public let failureClassification: String
    public let impossibleMetalXCTestLogBindingDiagnostic: String
    public let aggregateMetalIdentityCount: Int
    public let metalXCTestLogIdentityCount: Int
    public let runtimeReceiptMetallibIdentityMatched: Bool
    public let tokenizerReceiptMetallibIdentityMatched: Bool
    public let metallibIdentityDivergenceObserved: Bool
    public let stage2FreshMetallibDiscoveryCount: Int
    public let stage2BuildInvocationCount: Int
    public let stage2MetallibCopyCount: Int
    public let stage2DirectXCTestInvocationCount: Int
    public let stage2TestStartCount: Int
    public let stage2TestPassCount: Int
    public let stage2TestFailureCount: Int
    public let stage2TestSkipCount: Int
    public let stage2ReceiptCount: Int
    public let predecessorExecutionAuthorityConsumed: Bool
    public let predecessorExecutionAuthorityExhausted: Bool
    public let failedRunRecoverable: Bool
    public let consumedLiveInvocationRetired: Bool
    public let launcherSourcePreservedForAudit: Bool
    public let distinctRepairAuthorityRequired: Bool
}

public struct
    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairDesignV1:
    Codable,
    Equatable,
    Sendable
{
    public let authorizedBaseRevision: String
    public let authorizedBaseTree: String
    public let requiredExecutionCommitParentCount: Int
    public let requiredFirstParentRevision: String
    public let executionMergeTreeMustEqualSecondParentTree: Bool
    public let activeRootCheckoutFetchDepth: Int
    public let reviewedMainCheckoutFetchDepth: Int
    public let exactDirectSuccessorChangedPaths: [String]
    public let exactDirectSuccessorChangedStatuses: [String]
    public let launcherPath: String
    public let launcherInvocation: String
    public let launcherNetworkFetchCommandCount: Int
    public let receiptPrefix: String
    public let receiptID: String
    public let receiptStatus: String
    public let impossibleMetalXCTestIdentityGrepRemovalCount: Int
    public let metalFullOutputLogRelativeToRunnerTemp: String
    public let metalFullOutputLogCaptureAdded: Bool
    public let metalFullOutputLogCaptureInvocationCount: Int
    public let metalFullOutputLogTeeInvocationCount: Int
    public let metalFullOutputLogInitialAbsenceRequired: Bool
    public let metalFullOutputLogRegularFileRequired: Bool
    public let metalFullOutputLogSymbolicLinkForbidden: Bool
    public let metalFullOutputLogRequiredHardLinkCount: Int
    public let requiredMetalLauncherPipeStatus: Int
    public let requiredMetalFullOutputTeePipeStatus: Int
    public let metalLauncherExitAndTeeExitValidated: Bool
    public let metalFullOutputLogIdentityPrefixCount: Int
    public let metalFullOutputLogFreshIdentityCount: Int
    public let metalXCTestLogIdentityPrefixCount: Int
    public let metalXCTestLogFreshIdentityCount: Int
    public let metalIdentityLinePrefix: String
    public let metalFreshIdentityDynamicTemplate: String
    public let metalLauncherSourceChanged: Bool
    public let metalLauncherMutationCount: Int
    public let predecessorLogClassifierMutationCount: Int
    public let requiredPredecessorLogCount: Int
    public let requiredClassifierScannedLogCount: Int
    public let classifierAcceptedFixtureCount: Int
    public let classifierRejectedFixtureCount: Int
    public let requiredPredecessorReceiptCount: Int
    public let requiredFocusedRootTestCount: Int
    public let requiredFocusedIsolatedTestCount: Int
    public let requiredFocusedWholeStepTestCount: Int
    public let requiredMetalTestCount: Int
    public let requiredRuntimeTestCount: Int
    public let requiredTokenizerTestCount: Int
    public let requiredPreStage2CompletedTestCount: Int
    public let requiredTrustedCompletedTestCount: Int
    public let freshMetallibRootRelativeToRunnerTemp: String
    public let freshSourceCandidateCount: Int
    public let freshSourceFileIdentityValidated: Bool
    public let requiredMetallibFileName: String
    public let maximumMetallibByteCount: Int
    public let requiredMetallibIdentityInventoryCount: Int
    public let requiredMetalBundleCandidateCount: Int
    public let metalBundleByteIdentityMatchCount: Int
    public let requiredRuntimeBundleCandidateCount: Int
    public let requiredTokenizerBundleCandidateCount: Int
    public let requiredByteIdenticalComparisonCount: Int
    public let requiredByteCountEqualityCount: Int
    public let requiredSHA256EqualityCount: Int
    public let metalXCTestLogStillRequiredForExact44GreenTests: Bool
    public let metalXCTestLogRequiredToContainAggregateIdentityLine: Bool
    public let runtimeReceiptCount: Int
    public let runtimeReceiptIdentityMatchCount: Int
    public let runtimeReceiptMustBindFreshMetallibIdentity: Bool
    public let tokenizerReceiptCount: Int
    public let tokenizerReceiptIdentityMatchCount: Int
    public let tokenizerReceiptMustBindFreshMetallibIdentity: Bool
    public let tokenizerReceiptMustBindSuccessorRevisionTreeAndProvenance: Bool
    public let receiptIdentityCrossBindingEstablished: Bool
    public let loadedMetallibPathInferred: Bool
    public let predecessorArtifactSnapshotCount: Int
    public let predecessorArtifactRevalidationCountAfterXCTest: Int
    public let validationPackagePath: String
    public let validationManifestPath: String
    public let validationLockPath: String
    public let validationTestPath: String
    public let stage2TestClass: String
    public let stage2TestMethod: String
    public let stage2TestFilter: String
    public let requiredExclusiveMLXEnvironment: [String: String]
    public let swiftBuildInvocationCount: Int
    public let stagedMetallibCopyCount: Int
    public let stagedMetallibPermissionMode: String
    public let directXCTestInvocationCount: Int
    public let rebuildAfterStagingInvocationCount: Int
    public let requiredStage2TestCount: Int
    public let requiredStage2FailureCount: Int
    public let requiredStage2SkipCount: Int
    public let oneDistinctExecutionAttemptAuthorized: Bool
    public let githubRunAttemptMustEqualOne: Bool
    public let successorOutcomeMustRetireLiveInvocation: Bool
}

public struct
    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let failureObservationMutationAuthorized: Bool
    public let predecessorAuthorityMutationAuthorized: Bool
    public let metalLauncherMutationAuthorized: Bool
    public let runtimeLauncherMutationAuthorized: Bool
    public let tokenizerLauncherMutationAuthorized: Bool
    public let productionTrainingSourceMutationAuthorized: Bool
    public let validationManifestMutationAuthorized: Bool
    public let validationLockMutationAuthorized: Bool
    public let validationTestMutationAuthorized: Bool
    public let secureFetchMutationAuthorized: Bool
    public let additionalLogCaptureBeyondFixedMetalFullOutputAuthorized: Bool
    public let tlsVerificationBypassAuthorized: Bool
    public let customCAInstallationAuthorized: Bool
    public let workflowAuthoredRetryAuthorized: Bool
    public let gitInternalRetryBehaviorMutationAuthorized: Bool
    public let rerunAuthorized: Bool
    public let failedRunRecoveryAuthorized: Bool
    public let newMetallibBuildAuthorized: Bool
    public let xcodebuildAuthorizedInRepairLauncher: Bool
    public let swiftTestAuthorizedInRepairLauncher: Bool
    public let postStagingRebuildAuthorized: Bool
    public let networkFetchAuthorizedInRepairLauncher: Bool
    public let additionalStage2AttemptBeyondOneAuthorized: Bool
    public let repairImplementationObservedByThisAuthority: Bool
    public let repairExecutionObservedByThisAuthority: Bool
    public let stage2SuccessEstablished: Bool
    public let checkpointReadAuthorized: Bool
    public let checkpointWriteAuthorized: Bool
    public let checkpointArtifactAuthorized: Bool
    public let checkpointArtifactUploadAuthorized: Bool
    public let checkpointResumeAuthorized: Bool
    public let native300MAllocationAuthorized: Bool
    public let native300MTrainingAuthorized: Bool
    public let trainingResumeAuthorized: Bool
    public let trajectoryExactResumeAuthorized: Bool
    public let modelQualityEstablished: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let stage3AuthorityEstablished: Bool
}

/// Narrow authority for one exact direct-successor repair of the exhausted
/// Stage-2 fresh-metallib evidence surface.
///
/// The repair replaces only the impossible requirement that the Metal
/// identity line appear inside the Metal XCTest-only log. The workflow captures
/// the unchanged Metal launcher's complete output in one fixed same-job log,
/// validates both pipeline statuses, and binds the dynamic identity there. The
/// same file is then cross-bound through five metallib identities and the exact
/// runtime and tokenizer receipts. This value authorizes one distinct first
/// attempt; it is not execution evidence.
public struct
    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let greenPrerequisite:
        PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairGreenPrerequisiteV1
    public let consumedFailure:
        PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairFailureConsumptionV1
    public let observedBaseSourceBindings:
        [PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairSourceIdentityV1]
    public let repairDesign:
        PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairDesignV1
    public let exactGreenPrerequisiteConsumed: Bool
    public let failureObservationConsumedWithoutRecovery: Bool
    public let boundedEvidenceSurfaceRepairAuthorized: Bool
    public let impossibleMetalXCTestLogBindingRemovalAuthorized: Bool
    public let fixedMetalFullOutputLogCaptureAuthorized: Bool
    public let mechanicalLauncherGateWorkflowAndProvenancePinsAuthorized: Bool
    public let sameJobFreshMetallibConsumptionAuthorized: Bool
    public let exactReceiptCrossBindingAuthorized: Bool
    public let twoCopyMetallibStagingAuthorized: Bool
    public let directBuiltXCTestExecutionAuthorized: Bool
    public let exactOneDirectSuccessorAttemptAuthorized: Bool
    public let authorityCeiling:
        PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairCeilingV1
    public let status: String
    public let orderedRequiredActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_evidence_surface_repair_authority_v1",
        authorityKind:
            "exact_main_direct_successor_bounded_fresh_metallib_evidence_surface_repair_and_one_replacement_stage2_execution_authority",
        greenPrerequisite:
            PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairGreenPrerequisiteV1(
                repository: "Ergentics/ergentics-prime",
                mergeRevision:
                    "075922cec8361c0085d5b2c6d000828e3c0bfc35",
                mergeTree:
                    "c6bd910b13796bb12098834c5e7daab83cba8668",
                orderedParentRevisions: [
                    "050c0e4c60df4a1d0bd3dbba1f194f425609cb1b",
                    "35726475e1ce8af0ce406148f1a3025b1de1388b",
                ],
                mergedAt: "2026-08-12T03:30:08Z",
                historyPreservingTwoParentMergeObserved: true,
                mergeTreeEqualsReviewedHeadTree: true,
                mergeCommitSignatureVerified: true,
                mergeCommitSignatureReason: "valid",
                mergeCommitSignatureVerifiedAt: "2026-08-12T03:30:52Z",
                embeddedSourceIdentitySHA256:
                    "dad2151f1481acb742b9c3e885acae2029fc0c83259e2eb2dbe8b48949049956",
                workflowID: 329_017_041,
                runID: 31_560_270_980,
                runNumber: 77,
                runAttempt: 1,
                checkSuiteID: 85_610_747_095,
                exactHeadPushRunCount: 1,
                previousAttemptURLAbsent: true,
                secondAttemptEndpointHTTPStatus: 404,
                rerunCount: 0,
                runCreatedAt: "2026-08-12T03:30:11Z",
                runStartedAt: "2026-08-12T03:30:11Z",
                runUpdatedAt: "2026-08-12T04:15:38Z",
                runConclusion: "success",
                activeRootJobID: 94_000_965_034,
                activeRootRunnerID: 1_000_001_706,
                activeRootStartedAt: "2026-08-12T03:30:14Z",
                activeRootCompletedAt: "2026-08-12T03:32:41Z",
                activeRootCompletedStepCount: 7,
                activeRootConclusion: "success",
                reviewedMainJobID: 94_001_351_745,
                reviewedMainRunnerID: 1_000_001_707,
                reviewedMainStartedAt: "2026-08-12T03:32:45Z",
                reviewedMainCompletedAt: "2026-08-12T04:15:37Z",
                reviewedMainCompletedStepCount: 7,
                reviewedMainConclusion: "success",
                runnerArchitecture: "arm64",
                reviewedRunnerOperatingSystem: "macOS 26.5.2",
                xcodeVersion: "26.6",
                xcodeBuildVersion: "17F113",
                swiftVersion: "6.3.3",
                swiftTarget: "arm64-apple-macosx26.0",
                sdkVersion: "26.5",
                secureFetchWorkflowBlockSHA256:
                    "ef783783f50147161e2420fc8be7efd48b42d57ed1ebd79281033ab85ce90847",
                secureFetchCommandCount: 1,
                recursiveSubmoduleUpdateCommandCount: 1,
                workflowAuthoredRetryCount: 0,
                separateSecureFetchRetryStepCount: 0,
                gitInternalSubmoduleRetryScheduledCount: 0,
                mlxSubmoduleCloneAttemptCount: 1,
                mlxCSubmoduleCloneAttemptCount: 1,
                gitSubmoduleTLSFailureCount: 0,
                tlsVerificationBypassCount: 0,
                customCAInstallationCount: 0,
                mlxRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                mlxCoreRevision:
                    "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
                mlxCRevision:
                    "0726ca922fc902c4c61ef9c27d94132be418e945",
                focusedRootTestCount: 42,
                focusedRootFailureCount: 0,
                focusedRootSkipCount: 0,
                isolatedFocusedGroupTestCounts: [1, 1, 2, 2],
                focusedWholeStepTestCount: 48,
                focusedWholeStepFailureCount: 0,
                focusedWholeStepSkipCount: 0,
                retainedLiveSequence: [
                    "metal", "maintained_runtime", "tokenizer",
                ],
                retainedLiveInvocationCounts: [1, 1, 1],
                metallibBuildInvocationCount: 1,
                metallibBuildCompletionCount: 1,
                metallibByteCount: 6_292_652,
                metallibSHA256:
                    "026a9cb2e57091ea50d51f037ec94735d04941d4115adc567dace16d629c65b7",
                metalTestCount: 44,
                metalFailureCount: 0,
                metalSkipCount: 0,
                runtimeTestCount: 1,
                runtimeFailureCount: 0,
                runtimeSkipCount: 0,
                tokenizerTestCount: 1,
                tokenizerFailureCount: 0,
                tokenizerSkipCount: 0,
                preStage2CompletedTestCount: 94,
                preStage2FailureCount: 0,
                preStage2SkipCount: 0,
                runtimeReceipt:
                    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairReceiptIdentityV1(
                        prefix: "PRIME_NATIVE_DECODER_RUNTIME_CLOSURE_RECEIPT=",
                        receiptID:
                            "ergentics_prime_native_decoder_maintained_runtime_initialization_v1",
                        count: 1,
                        jsonByteCount: 6_853,
                        jsonSHA256:
                            "c8006b0b16059bc1d60e69079743747482604cf9c4b48bd496086df198548baa",
                        metallibByteCount: 6_292_652,
                        metallibSHA256:
                            "026a9cb2e57091ea50d51f037ec94735d04941d4115adc567dace16d629c65b7",
                        requiredStatus:
                            "runtime_dependency_closure_established_true",
                        executedRevision: "",
                        executedTree: "",
                        executedEmbeddedSourceIdentitySHA256: "",
                        outcomeEstablished: true,
                        trainingExecutionObserved: false,
                        trainEvaluateSurfaceEstablished: false),
                tokenizerReceipt:
                    PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairReceiptIdentityV1(
                        prefix:
                            "PRIME_NATIVE_DECODER_TOKENIZER_COMPATIBILITY_RECEIPT=",
                        receiptID:
                            "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1",
                        count: 1,
                        jsonByteCount: 7_182,
                        jsonSHA256:
                            "bb5ab23a6b64515f50d4e7d2e8ce7438ef6923b92dd3ddb8904e0a2e26ad3568",
                        metallibByteCount: 6_292_652,
                        metallibSHA256:
                            "026a9cb2e57091ea50d51f037ec94735d04941d4115adc567dace16d629c65b7",
                        requiredStatus:
                            "PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only",
                        executedRevision:
                            "075922cec8361c0085d5b2c6d000828e3c0bfc35",
                        executedTree:
                            "c6bd910b13796bb12098834c5e7daab83cba8668",
                        executedEmbeddedSourceIdentitySHA256:
                            "dad2151f1481acb742b9c3e885acae2029fc0c83259e2eb2dbe8b48949049956",
                        outcomeEstablished: true,
                        trainingExecutionObserved: false,
                        trainEvaluateSurfaceEstablished: false),
                stage2LauncherInvocationCount: 0,
                stage2BuildInvocationCount: 0,
                stage2MetallibCopyCount: 0,
                stage2DirectXCTestInvocationCount: 0,
                stage2TestStartCount: 0,
                stage2TestPassCount: 0,
                stage2TestFailureCount: 0,
                stage2TestSkipCount: 0,
                stage2ReceiptCount: 0,
                actionsArtifactsTotalCount: 0,
                actionsArtifactsArrayExactlyEmpty: true,
                runLogArchiveByteCount: 1_344_159,
                runLogArchiveMemberCount: 18,
                runLogArchiveUncompressedByteCount: 20_983_497,
                runLogArchiveSHA256:
                    "8112ede2cb0c1caaa325495a55481e7b6f15491c3919a0013ab11a6dfc038ef3",
                rawLogs: [
                    rawLog(
                        "active_job", 237_779, 1_758,
                        "0acb2a27341088fe60a01c63477df3dcf038df55ae033dc53f65c2d09c2a8a7a"),
                    rawLog(
                        "reviewed_job", 10_253_251, 78_476,
                        "5e58921a075a76ba6caf16c9f0b73bc09ca293d9b6414ed21f9e13a278bc9ba0"),
                    rawLog(
                        "secure_fetch_step", 4_893, 54,
                        "b1de2fd0e427540f121bbdcf6536d60b9e93658272c1f15301b63da85a7beb61"),
                    rawLog(
                        "focused_contracts_step", 352_054, 3_391,
                        "621c0573ad8c8641d915fefb8ec2871d542d5ab23cd1a15f676292c3653bd73e"),
                    rawLog(
                        "live_metal_runtime_tokenizer_step", 9_890_141,
                        74_943,
                        "56cd920690a31cb567363898da032a9c0b43e9723ddf26e41e5372d64dda2af9"),
                ],
                exactGreenPrerequisiteSatisfied: true),
        consumedFailure:
            PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairFailureConsumptionV1(
                failureObservationID:
                    "ergentics_prime_native_decoder_tiny_cpu_train_evaluate_mechanics_default_metallib_bootstrap_fresh_metallib_cross_binding_execution_failure_observation_v1",
                failureObservationCanonicalSHA256:
                    "6c0f9a82ff61e30abc9122faca47fdace203deecd464431d41fd84d0709d382f",
                exhaustedRunID: 31_555_440_908,
                exhaustedRunAttempt: 1,
                failedLauncherPath:
                    ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                failedLauncherGitMode: "100755",
                failedLauncherGitBlob:
                    "45fc1f82ecfe14a6a9e98c345706f75b37c2d1cb",
                failedLauncherByteCount: 44_691,
                failedLauncherSHA256:
                    "3b8a0790b521de9c6ca03760aef8e9bbece4d46f6d1f8505dae44fc9a559d185",
                failureClassification:
                    "deterministic_evidence_capture_scope_mismatch_after_fresh_metallib_discovery_no_identity_divergence",
                impossibleMetalXCTestLogBindingDiagnostic:
                    "prime-native-decoder-stage2-metallib-bootstrap-repair: Metal log does not bind the fresh metallib",
                aggregateMetalIdentityCount: 1,
                metalXCTestLogIdentityCount: 0,
                runtimeReceiptMetallibIdentityMatched: true,
                tokenizerReceiptMetallibIdentityMatched: true,
                metallibIdentityDivergenceObserved: false,
                stage2FreshMetallibDiscoveryCount: 1,
                stage2BuildInvocationCount: 0,
                stage2MetallibCopyCount: 0,
                stage2DirectXCTestInvocationCount: 0,
                stage2TestStartCount: 0,
                stage2TestPassCount: 0,
                stage2TestFailureCount: 0,
                stage2TestSkipCount: 0,
                stage2ReceiptCount: 0,
                predecessorExecutionAuthorityConsumed: true,
                predecessorExecutionAuthorityExhausted: true,
                failedRunRecoverable: false,
                consumedLiveInvocationRetired: true,
                launcherSourcePreservedForAudit: true,
                distinctRepairAuthorityRequired: true),
        observedBaseSourceBindings: baseSourceBindings,
        repairDesign:
            PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairDesignV1(
                authorizedBaseRevision:
                    "075922cec8361c0085d5b2c6d000828e3c0bfc35",
                authorizedBaseTree:
                    "c6bd910b13796bb12098834c5e7daab83cba8668",
                requiredExecutionCommitParentCount: 2,
                requiredFirstParentRevision:
                    "075922cec8361c0085d5b2c6d000828e3c0bfc35",
                executionMergeTreeMustEqualSecondParentTree: true,
                activeRootCheckoutFetchDepth: 1,
                reviewedMainCheckoutFetchDepth: 2,
                exactDirectSuccessorChangedPaths: expectedChangedPaths,
                exactDirectSuccessorChangedStatuses: [
                    "M", "M", "M", "M", "A", "A",
                ],
                launcherPath:
                    ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                launcherInvocation:
                    "bash .github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
                launcherNetworkFetchCommandCount: 0,
                receiptPrefix:
                    "PRIME_NATIVE_DECODER_STAGE2_METALLIB_BOOTSTRAP_FRESH_METALLIB_EVIDENCE_SURFACE_REPAIR_RECEIPT=",
                receiptID:
                    "ergentics_prime_native_decoder_stage2_metallib_bootstrap_fresh_metallib_evidence_surface_repair_receipt_v1",
                receiptStatus:
                    "PASS_exact_main_stage2_same_job_fresh_metallib_evidence_surface_repair_one_test_zero_failure_zero_skip",
                impossibleMetalXCTestIdentityGrepRemovalCount: 1,
                metalFullOutputLogRelativeToRunnerTemp:
                    "prime-native-decoder-metal-full-output.log",
                metalFullOutputLogCaptureAdded: true,
                metalFullOutputLogCaptureInvocationCount: 1,
                metalFullOutputLogTeeInvocationCount: 1,
                metalFullOutputLogInitialAbsenceRequired: true,
                metalFullOutputLogRegularFileRequired: true,
                metalFullOutputLogSymbolicLinkForbidden: true,
                metalFullOutputLogRequiredHardLinkCount: 1,
                requiredMetalLauncherPipeStatus: 0,
                requiredMetalFullOutputTeePipeStatus: 0,
                metalLauncherExitAndTeeExitValidated: true,
                metalFullOutputLogIdentityPrefixCount: 1,
                metalFullOutputLogFreshIdentityCount: 1,
                metalXCTestLogIdentityPrefixCount: 0,
                metalXCTestLogFreshIdentityCount: 0,
                metalIdentityLinePrefix:
                    "Prime decoder Metal gate: metallib_sha256=",
                metalFreshIdentityDynamicTemplate:
                    "Prime decoder Metal gate: metallib_sha256=<fresh_sha256> metallib_bytes=<fresh_byte_count>",
                metalLauncherSourceChanged: false,
                metalLauncherMutationCount: 0,
                predecessorLogClassifierMutationCount: 0,
                requiredPredecessorLogCount: 11,
                requiredClassifierScannedLogCount: 8,
                classifierAcceptedFixtureCount: 8,
                classifierRejectedFixtureCount: 5,
                requiredPredecessorReceiptCount: 2,
                requiredFocusedRootTestCount: 43,
                requiredFocusedIsolatedTestCount: 6,
                requiredFocusedWholeStepTestCount: 49,
                requiredMetalTestCount: 44,
                requiredRuntimeTestCount: 1,
                requiredTokenizerTestCount: 1,
                requiredPreStage2CompletedTestCount: 95,
                requiredTrustedCompletedTestCount: 96,
                freshMetallibRootRelativeToRunnerTemp:
                    "prime-native-decoder-metallib",
                freshSourceCandidateCount: 1,
                freshSourceFileIdentityValidated: true,
                requiredMetallibFileName: "default.metallib",
                maximumMetallibByteCount: 67_108_864,
                requiredMetallibIdentityInventoryCount: 5,
                requiredMetalBundleCandidateCount: 2,
                metalBundleByteIdentityMatchCount: 2,
                requiredRuntimeBundleCandidateCount: 1,
                requiredTokenizerBundleCandidateCount: 1,
                requiredByteIdenticalComparisonCount: 5,
                requiredByteCountEqualityCount: 5,
                requiredSHA256EqualityCount: 5,
                metalXCTestLogStillRequiredForExact44GreenTests: true,
                metalXCTestLogRequiredToContainAggregateIdentityLine: false,
                runtimeReceiptCount: 1,
                runtimeReceiptIdentityMatchCount: 1,
                runtimeReceiptMustBindFreshMetallibIdentity: true,
                tokenizerReceiptCount: 1,
                tokenizerReceiptIdentityMatchCount: 1,
                tokenizerReceiptMustBindFreshMetallibIdentity: true,
                tokenizerReceiptMustBindSuccessorRevisionTreeAndProvenance:
                    true,
                receiptIdentityCrossBindingEstablished: true,
                loadedMetallibPathInferred: false,
                predecessorArtifactSnapshotCount: 16,
                predecessorArtifactRevalidationCountAfterXCTest: 16,
                validationPackagePath:
                    "Tests/PrimeNativeDecoderTrainingValidation",
                validationManifestPath:
                    "Tests/PrimeNativeDecoderTrainingValidation/Package.swift",
                validationLockPath:
                    "Tests/PrimeNativeDecoderTrainingValidation/Package.resolved",
                validationTestPath:
                    "Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift",
                stage2TestClass: "PrimeNativeDecoderTrainingTests",
                stage2TestMethod:
                    "testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                stage2TestFilter:
                    "PrimeNativeDecoderTrainingTests/testTinyCPUTrainEvaluateMechanicsAreExactAndFailClosed",
                requiredExclusiveMLXEnvironment: ["MLX_ENABLE_TF32": "0"],
                swiftBuildInvocationCount: 1,
                stagedMetallibCopyCount: 2,
                stagedMetallibPermissionMode: "444",
                directXCTestInvocationCount: 1,
                rebuildAfterStagingInvocationCount: 0,
                requiredStage2TestCount: 1,
                requiredStage2FailureCount: 0,
                requiredStage2SkipCount: 0,
                oneDistinctExecutionAttemptAuthorized: true,
                githubRunAttemptMustEqualOne: true,
                successorOutcomeMustRetireLiveInvocation: true),
        exactGreenPrerequisiteConsumed: true,
        failureObservationConsumedWithoutRecovery: true,
        boundedEvidenceSurfaceRepairAuthorized: true,
        impossibleMetalXCTestLogBindingRemovalAuthorized: true,
        fixedMetalFullOutputLogCaptureAuthorized: true,
        mechanicalLauncherGateWorkflowAndProvenancePinsAuthorized: true,
        sameJobFreshMetallibConsumptionAuthorized: true,
        exactReceiptCrossBindingAuthorized: true,
        twoCopyMetallibStagingAuthorized: true,
        directBuiltXCTestExecutionAuthorized: true,
        exactOneDirectSuccessorAttemptAuthorized: true,
        authorityCeiling:
            PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairCeilingV1(
                failureObservationMutationAuthorized: false,
                predecessorAuthorityMutationAuthorized: false,
                metalLauncherMutationAuthorized: false,
                runtimeLauncherMutationAuthorized: false,
                tokenizerLauncherMutationAuthorized: false,
                productionTrainingSourceMutationAuthorized: false,
                validationManifestMutationAuthorized: false,
                validationLockMutationAuthorized: false,
                validationTestMutationAuthorized: false,
                secureFetchMutationAuthorized: false,
                additionalLogCaptureBeyondFixedMetalFullOutputAuthorized: false,
                tlsVerificationBypassAuthorized: false,
                customCAInstallationAuthorized: false,
                workflowAuthoredRetryAuthorized: false,
                gitInternalRetryBehaviorMutationAuthorized: false,
                rerunAuthorized: false,
                failedRunRecoveryAuthorized: false,
                newMetallibBuildAuthorized: false,
                xcodebuildAuthorizedInRepairLauncher: false,
                swiftTestAuthorizedInRepairLauncher: false,
                postStagingRebuildAuthorized: false,
                networkFetchAuthorizedInRepairLauncher: false,
                additionalStage2AttemptBeyondOneAuthorized: false,
                repairImplementationObservedByThisAuthority: false,
                repairExecutionObservedByThisAuthority: false,
                stage2SuccessEstablished: false,
                checkpointReadAuthorized: false,
                checkpointWriteAuthorized: false,
                checkpointArtifactAuthorized: false,
                checkpointArtifactUploadAuthorized: false,
                checkpointResumeAuthorized: false,
                native300MAllocationAuthorized: false,
                native300MTrainingAuthorized: false,
                trainingResumeAuthorized: false,
                trajectoryExactResumeAuthorized: false,
                modelQualityEstablished: false,
                candidateAdmissionGranted: false,
                trialAuthorized: false,
                canaryReplacementAuthorized: false,
                quantizationAuthorized: false,
                productUseAuthorized: false,
                publicationAuthorized: false,
                stage3AuthorityEstablished: false),
        status:
            "AUTHORIZED_exact_one_direct_successor_bounded_fresh_metallib_evidence_surface_repair_and_one_replacement_stage2_execution_not_execution_evidence_no_retry_rerun_artifact_checkpoint_or_downstream_authority",
        orderedRequiredActions: [
            "preserve_the_green_base_failed_launcher_and_consumed_cross_binding_failure_observation_as_exact_history",
            "materialize_only_the_exact_six_path_direct_successor_evidence_surface_repair",
            "capture_the_unchanged_metal_launcher_complete_output_once_in_the_fixed_runner_temp_log_with_launcher_and_tee_pipe_status_zero",
            "replace_the_impossible_metal_xctest_identity_requirement_with_prefix0_dynamic0_inside_and_prefix1_dynamic1_in_the_full_output_log",
            "bind_the_fixed_same_job_fresh_artifact_to_two_metal_runtime_and_tokenizer_bundle_candidates_by_bytes_count_and_sha256",
            "bind_exactly_one_runtime_and_one_tokenizer_receipt_to_the_same_fresh_metallib_and_bind_tokenizer_to_successor_revision_tree_and_provenance",
            "retain_one_build_two_mode444_copies_and_one_direct_xctest_with_root43_whole49_pre_stage2_total95_and_trusted_total96",
            "authorize_exactly_one_distinct_first_attempt_and_require_a_separate_terminal_outcome_observation_to_retire_it",
        ])

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityError
                    .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let failure =
            PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationV1
                .frozenV1
        do {
            try failure.validateExactV1()
            guard consumedFailure.failureObservationID == failure.observationID,
                  consumedFailure.failureObservationCanonicalSHA256
                    == PrimeSHA256.hexDigest(of: try failure.canonicalData())
            else {
                throw
                    PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityError
                        .contractDrift
            }
        } catch {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityError
                    .contractDrift
        }

        let green = greenPrerequisite
        let consumed = consumedFailure
        let design = repairDesign
        let ceiling = authorityCeiling
        let falseClaims = [
            ceiling.failureObservationMutationAuthorized,
            ceiling.predecessorAuthorityMutationAuthorized,
            ceiling.metalLauncherMutationAuthorized,
            ceiling.runtimeLauncherMutationAuthorized,
            ceiling.tokenizerLauncherMutationAuthorized,
            ceiling.productionTrainingSourceMutationAuthorized,
            ceiling.validationManifestMutationAuthorized,
            ceiling.validationLockMutationAuthorized,
            ceiling.validationTestMutationAuthorized,
            ceiling.secureFetchMutationAuthorized,
            ceiling.additionalLogCaptureBeyondFixedMetalFullOutputAuthorized,
            ceiling.tlsVerificationBypassAuthorized,
            ceiling.customCAInstallationAuthorized,
            ceiling.workflowAuthoredRetryAuthorized,
            ceiling.gitInternalRetryBehaviorMutationAuthorized,
            ceiling.rerunAuthorized,
            ceiling.failedRunRecoveryAuthorized,
            ceiling.newMetallibBuildAuthorized,
            ceiling.xcodebuildAuthorizedInRepairLauncher,
            ceiling.swiftTestAuthorizedInRepairLauncher,
            ceiling.postStagingRebuildAuthorized,
            ceiling.networkFetchAuthorizedInRepairLauncher,
            ceiling.additionalStage2AttemptBeyondOneAuthorized,
            ceiling.repairImplementationObservedByThisAuthority,
            ceiling.repairExecutionObservedByThisAuthority,
            ceiling.stage2SuccessEstablished,
            ceiling.checkpointReadAuthorized,
            ceiling.checkpointWriteAuthorized,
            ceiling.checkpointArtifactAuthorized,
            ceiling.checkpointArtifactUploadAuthorized,
            ceiling.checkpointResumeAuthorized,
            ceiling.native300MAllocationAuthorized,
            ceiling.native300MTrainingAuthorized,
            ceiling.trainingResumeAuthorized,
            ceiling.trajectoryExactResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionGranted,
            ceiling.trialAuthorized,
            ceiling.canaryReplacementAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
            ceiling.stage3AuthorityEstablished,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              green.orderedParentRevisions.count == 2,
              green.mergeRevision == design.authorizedBaseRevision,
              green.mergeTree == design.authorizedBaseTree,
              green.runAttempt == 1,
              green.exactHeadPushRunCount == 1,
              green.previousAttemptURLAbsent,
              green.secondAttemptEndpointHTTPStatus == 404,
              green.rerunCount == 0,
              green.workflowAuthoredRetryCount == 0,
              green.gitInternalSubmoduleRetryScheduledCount == 0,
              green.gitSubmoduleTLSFailureCount == 0,
              green.tlsVerificationBypassCount == 0,
              green.customCAInstallationCount == 0,
              green.focusedRootTestCount == 42,
              green.isolatedFocusedGroupTestCounts == [1, 1, 2, 2],
              green.focusedWholeStepTestCount
                == green.focusedRootTestCount
                    + green.isolatedFocusedGroupTestCounts.reduce(0, +),
              green.focusedWholeStepTestCount == 48,
              green.retainedLiveSequence
                == ["metal", "maintained_runtime", "tokenizer"],
              green.retainedLiveInvocationCounts == [1, 1, 1],
              green.metalTestCount == 44,
              green.runtimeTestCount == 1,
              green.tokenizerTestCount == 1,
              green.preStage2CompletedTestCount
                == green.focusedWholeStepTestCount + green.metalTestCount
                    + green.runtimeTestCount + green.tokenizerTestCount,
              green.preStage2CompletedTestCount == 94,
              green.metallibBuildInvocationCount == 1,
              green.metallibBuildCompletionCount == 1,
              Self.validReceipt(green.runtimeReceipt),
              Self.validReceipt(green.tokenizerReceipt),
              green.runtimeReceipt.metallibByteCount == green.metallibByteCount,
              green.tokenizerReceipt.metallibByteCount == green.metallibByteCount,
              green.runtimeReceipt.metallibSHA256 == green.metallibSHA256,
              green.tokenizerReceipt.metallibSHA256 == green.metallibSHA256,
              green.tokenizerReceipt.executedRevision == green.mergeRevision,
              green.tokenizerReceipt.executedTree == green.mergeTree,
              green.tokenizerReceipt.executedEmbeddedSourceIdentitySHA256
                == green.embeddedSourceIdentitySHA256,
              green.stage2LauncherInvocationCount == 0,
              green.stage2BuildInvocationCount == 0,
              green.stage2MetallibCopyCount == 0,
              green.stage2DirectXCTestInvocationCount == 0,
              green.stage2TestStartCount == 0,
              green.stage2TestPassCount == 0,
              green.stage2TestFailureCount == 0,
              green.stage2TestSkipCount == 0,
              green.stage2ReceiptCount == 0,
              green.actionsArtifactsTotalCount == 0,
              green.actionsArtifactsArrayExactlyEmpty,
              green.rawLogs.count == 5,
              green.rawLogs.allSatisfy(Self.validRawLog),
              green.exactGreenPrerequisiteSatisfied,
              observedBaseSourceBindings.count == 16,
              Set(observedBaseSourceBindings.map(\.path)).count == 16,
              observedBaseSourceBindings.allSatisfy(Self.validSourceIdentity),
              consumed.aggregateMetalIdentityCount == 1,
              consumed.metalXCTestLogIdentityCount == 0,
              consumed.runtimeReceiptMetallibIdentityMatched,
              consumed.tokenizerReceiptMetallibIdentityMatched,
              !consumed.metallibIdentityDivergenceObserved,
              consumed.stage2FreshMetallibDiscoveryCount == 1,
              consumed.stage2BuildInvocationCount == 0,
              consumed.stage2MetallibCopyCount == 0,
              consumed.stage2DirectXCTestInvocationCount == 0,
              consumed.stage2TestStartCount == 0,
              consumed.stage2TestPassCount == 0,
              consumed.stage2TestFailureCount == 0,
              consumed.stage2TestSkipCount == 0,
              consumed.stage2ReceiptCount == 0,
              consumed.predecessorExecutionAuthorityConsumed,
              consumed.predecessorExecutionAuthorityExhausted,
              !consumed.failedRunRecoverable,
              consumed.consumedLiveInvocationRetired,
              consumed.launcherSourcePreservedForAudit,
              consumed.distinctRepairAuthorityRequired,
              design.requiredExecutionCommitParentCount == 2,
              design.requiredFirstParentRevision == green.mergeRevision,
              design.activeRootCheckoutFetchDepth == 1,
              design.reviewedMainCheckoutFetchDepth == 2,
              design.exactDirectSuccessorChangedPaths == Self.expectedChangedPaths,
              design.exactDirectSuccessorChangedStatuses
                == ["M", "M", "M", "M", "A", "A"],
              design.exactDirectSuccessorChangedPaths.count == 6,
              design.launcherNetworkFetchCommandCount == 0,
              design.impossibleMetalXCTestIdentityGrepRemovalCount == 1,
              design.metalFullOutputLogRelativeToRunnerTemp
                == "prime-native-decoder-metal-full-output.log",
              design.metalFullOutputLogCaptureAdded,
              design.metalFullOutputLogCaptureInvocationCount == 1,
              design.metalFullOutputLogTeeInvocationCount == 1,
              design.metalFullOutputLogInitialAbsenceRequired,
              design.metalFullOutputLogRegularFileRequired,
              design.metalFullOutputLogSymbolicLinkForbidden,
              design.metalFullOutputLogRequiredHardLinkCount == 1,
              design.requiredMetalLauncherPipeStatus == 0,
              design.requiredMetalFullOutputTeePipeStatus == 0,
              design.metalLauncherExitAndTeeExitValidated,
              design.metalFullOutputLogIdentityPrefixCount == 1,
              design.metalFullOutputLogFreshIdentityCount == 1,
              design.metalXCTestLogIdentityPrefixCount == 0,
              design.metalXCTestLogFreshIdentityCount == 0,
              design.metalIdentityLinePrefix
                == "Prime decoder Metal gate: metallib_sha256=",
              design.metalFreshIdentityDynamicTemplate
                == "Prime decoder Metal gate: metallib_sha256=<fresh_sha256> metallib_bytes=<fresh_byte_count>",
              !design.metalLauncherSourceChanged,
              design.metalLauncherMutationCount == 0,
              design.predecessorLogClassifierMutationCount == 0,
              design.requiredPredecessorLogCount == 11,
              design.requiredClassifierScannedLogCount == 8,
              design.classifierAcceptedFixtureCount == 8,
              design.classifierRejectedFixtureCount == 5,
              design.requiredPredecessorReceiptCount == 2,
              design.requiredFocusedRootTestCount == 43,
              design.requiredFocusedIsolatedTestCount == 6,
              design.requiredFocusedWholeStepTestCount == 49,
              design.requiredFocusedWholeStepTestCount
                == design.requiredFocusedRootTestCount
                    + design.requiredFocusedIsolatedTestCount,
              design.requiredMetalTestCount == 44,
              design.requiredRuntimeTestCount == 1,
              design.requiredTokenizerTestCount == 1,
              design.requiredPreStage2CompletedTestCount == 95,
              design.requiredPreStage2CompletedTestCount
                == design.requiredFocusedWholeStepTestCount
                    + design.requiredMetalTestCount
                    + design.requiredRuntimeTestCount
                    + design.requiredTokenizerTestCount,
              design.requiredTrustedCompletedTestCount == 96,
              design.requiredTrustedCompletedTestCount
                == design.requiredPreStage2CompletedTestCount
                    + design.requiredStage2TestCount,
              design.freshSourceCandidateCount == 1,
              design.freshSourceFileIdentityValidated,
              design.requiredMetallibIdentityInventoryCount == 5,
              design.requiredMetalBundleCandidateCount == 2,
              design.metalBundleByteIdentityMatchCount == 2,
              design.requiredRuntimeBundleCandidateCount == 1,
              design.requiredTokenizerBundleCandidateCount == 1,
              design.requiredByteIdenticalComparisonCount == 5,
              design.requiredByteCountEqualityCount == 5,
              design.requiredSHA256EqualityCount == 5,
              design.metalXCTestLogStillRequiredForExact44GreenTests,
              !design.metalXCTestLogRequiredToContainAggregateIdentityLine,
              design.runtimeReceiptCount == 1,
              design.runtimeReceiptIdentityMatchCount == 1,
              design.runtimeReceiptMustBindFreshMetallibIdentity,
              design.tokenizerReceiptCount == 1,
              design.tokenizerReceiptIdentityMatchCount == 1,
              design.tokenizerReceiptMustBindFreshMetallibIdentity,
              design.tokenizerReceiptMustBindSuccessorRevisionTreeAndProvenance,
              design.receiptIdentityCrossBindingEstablished,
              !design.loadedMetallibPathInferred,
              design.predecessorArtifactSnapshotCount == 16,
              design.predecessorArtifactRevalidationCountAfterXCTest == 16,
              design.requiredExclusiveMLXEnvironment == ["MLX_ENABLE_TF32": "0"],
              design.swiftBuildInvocationCount == 1,
              design.stagedMetallibCopyCount == 2,
              design.stagedMetallibPermissionMode == "444",
              design.directXCTestInvocationCount == 1,
              design.rebuildAfterStagingInvocationCount == 0,
              design.requiredStage2TestCount == 1,
              design.requiredStage2FailureCount == 0,
              design.requiredStage2SkipCount == 0,
              design.oneDistinctExecutionAttemptAuthorized,
              design.githubRunAttemptMustEqualOne,
              design.successorOutcomeMustRetireLiveInvocation,
              exactGreenPrerequisiteConsumed,
              failureObservationConsumedWithoutRecovery,
              boundedEvidenceSurfaceRepairAuthorized,
              impossibleMetalXCTestLogBindingRemovalAuthorized,
              fixedMetalFullOutputLogCaptureAuthorized,
              mechanicalLauncherGateWorkflowAndProvenancePinsAuthorized,
              sameJobFreshMetallibConsumptionAuthorized,
              exactReceiptCrossBindingAuthorized,
              twoCopyMetallibStagingAuthorized,
              directBuiltXCTestExecutionAuthorized,
              exactOneDirectSuccessorAttemptAuthorized,
              falseClaims.allSatisfy({ !$0 }),
              orderedRequiredActions.count == 8
        else {
            throw
                PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityError
                    .contractDrift
        }
    }

    private static let expectedChangedPaths = [
        ".github/scripts/prime-ci-active-root-quarantine.sh",
        ".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh",
        ".github/workflows/prime-active-root-quarantine.yml",
        "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
        "Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthority.swift",
        "Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibEvidenceSurfaceRepairAuthorityTests.swift",
    ]

    private static let baseSourceBindings = [
        source(".github/scripts/prime-ci-active-root-quarantine.sh", "100755", "906308b0ed10c9036195f08f3bd36d78d9e20323", 391_158, "b89e6af85757a454406eae03ec2a493aa9335e9372e2c6a6ac28e2facc4b2ffa", "exact_root42_gate"),
        source(".github/scripts/prime-ci-native-decoder-metal.sh", "100755", "418d2d2753cee38e0b3558ad45e1e09865ffd11d", 11_793, "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff", "preserved_metal_launcher_with_aggregate_identity_before_xctest_tee"),
        source(".github/scripts/prime-ci-native-decoder-runtime-closure.sh", "100755", "f1c3041d7e47fa315f60c889a736a412640e8710", 26_614, "aac5421ec7b1465bb746079bf5ea2634e20b9456099b33ce0271228638342cc5", "preserved_runtime_receipt_launcher"),
        source(".github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh", "100755", "b12d52802e7f24be7a905ae0cbceeed945fcc11a", 33_174, "0c70d3cd538e297cf629707a51bcc8ede87b42e488369ffd321ac3c44062f06a", "preserved_tokenizer_receipt_launcher"),
        source(".github/scripts/prime-ci-native-decoder-stage2-metallib-bootstrap-repair.sh", "100755", "45fc1f82ecfe14a6a9e98c345706f75b37c2d1cb", 44_691, "3b8a0790b521de9c6ca03760aef8e9bbece4d46f6d1f8505dae44fc9a559d185", "preserved_failed_evidence_surface_launcher"),
        source(".github/workflows/prime-active-root-quarantine.yml", "100644", "de6e3107db4cb82b3d228297eed7775cdff1f076", 48_245, "f00bba4e2f34cf46ce3b17c29341ee07060253b98d97e2eacd6a23e783f30246", "exact_green_base_workflow_with_stage2_retired"),
        source("Package.swift", "100644", "765d3c88139bc1f74af16b77b2f3b06d33f66f75", 32_795, "bc889436fb167cc206aa87cb079da4888a7fe95e517eb7cf63cbf44b35dc27c2", "unchanged_root_manifest"),
        source("Package.resolved", "100644", "14d804bb4291720477240c27e24de6fbdc876b3b", 645, "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375", "unchanged_root_lock"),
        source("Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", "100644", "e5708351a0da0f5b5f834310db493e81850f6fda", 546, "33f3a8a536ff2c566146ecbc987f4a21685f79a4d96c865f8d1c6eb38538ac65", "exact_green_base_embedded_provenance"),
        source("Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthority.swift", "100644", "b3b42c285c8fe048d4eeea111f3f9f9bab37707d", 66_167, "2f97065f3c09f69d2ce38774a16a5d4dcb9deb20899cdeb1f8821334d2486983", "consumed_predecessor_authority"),
        source("Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapPredecessorLogClassifierRepairAuthorityTests.swift", "100644", "15164c2256129816789fd2408f73f7b1c7eaccbd", 35_453, "2600a86636c5440ddd010e10a0928fd7f49b96d2926536d881364e524630d187", "consumed_predecessor_authority_test"),
        source("Sources/PrimeCore/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservation.swift", "100644", "35ca8e0d056ea9cffce532f2882c9d13d622e5cf", 76_806, "3fbd5f40b70a589e38393468df526da7a128e427d9fbf9a83462efd80d35fe93", "consumed_cross_binding_failure_observation"),
        source("Tests/PrimeCoreTests/PrimeNativeDecoderTinyCPUTrainEvaluateMechanicsDefaultMetallibBootstrapFreshMetallibCrossBindingExecutionFailureObservationTests.swift", "100644", "c176a50a7ac7367cbd7f66e6003613ba597adb43", 41_359, "c7fd5fcd2c1422cece77d34f45e70f5778c29bbf258972c9b9b30b5e6d3f8e2e", "consumed_cross_binding_failure_observation_test"),
        source("Tests/PrimeNativeDecoderTrainingValidation/Package.swift", "100644", "9f05e5a17426f00adf9dad7b55d84057122e98f9", 1_054, "0523184de79bb204113432428e635113220e1f3f8ba20177762959a73e861d45", "unchanged_stage2_validation_manifest"),
        source("Tests/PrimeNativeDecoderTrainingValidation/Package.resolved", "100644", "8bf05edf1ea8789e7683e72fe756d79aaaa61320", 645, "a393c9c0dad758b4b1cda315f583dcf9ee4b8cddd8d63a397602d6cf9bcec225", "unchanged_stage2_validation_lock"),
        source("Tests/PrimeNativeDecoderTrainingValidation/Tests/PrimeNativeDecoderTrainingTests/PrimeNativeDecoderTrainingTests.swift", "100644", "61e86200c508526ae2ab66e359d771841f7208db", 30_214, "29399e46e1197e09fd181c373ca12f424260abc7f671189d0dc712a48fadac96", "unchanged_stage2_validation_test"),
    ]

    private static func source(
        _ path: String,
        _ gitMode: String,
        _ gitBlob: String,
        _ byteCount: Int,
        _ sha256: String,
        _ claimScope: String
    ) -> PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairSourceIdentityV1 {
        .init(
            path: path,
            gitMode: gitMode,
            gitBlob: gitBlob,
            byteCount: byteCount,
            sha256: sha256,
            claimScope: claimScope)
    }

    private static func rawLog(
        _ label: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String
    ) -> PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairRawLogIdentityV1 {
        .init(
            label: label,
            byteCount: byteCount,
            lfByteCount: lfByteCount,
            sha256: sha256,
            startsWithUTF8BOM: true,
            usesLFOnly: true,
            endsWithLF: true)
    }

    private static func validSourceIdentity(
        _ source:
            PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairSourceIdentityV1
    ) -> Bool {
        ["100644", "100755"].contains(source.gitMode)
            && source.gitBlob.utf8.count == 40
            && source.byteCount > 0
            && source.sha256.utf8.count == 64
            && !source.claimScope.isEmpty
    }

    private static func validRawLog(
        _ log:
            PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairRawLogIdentityV1
    ) -> Bool {
        !log.label.isEmpty
            && log.byteCount > 0
            && log.lfByteCount > 0
            && log.sha256.utf8.count == 64
            && log.startsWithUTF8BOM
            && log.usesLFOnly
            && log.endsWithLF
    }

    private static func validReceipt(
        _ receipt:
            PrimeNativeDecoderStage2FreshMetallibEvidenceSurfaceRepairReceiptIdentityV1
    ) -> Bool {
        receipt.prefix.hasSuffix("=")
            && !receipt.receiptID.isEmpty
            && receipt.count == 1
            && receipt.jsonByteCount > 0
            && receipt.jsonSHA256.utf8.count == 64
            && receipt.metallibByteCount > 0
            && receipt.metallibSHA256.utf8.count == 64
            && !receipt.requiredStatus.isEmpty
            && receipt.outcomeEstablished
            && !receipt.trainingExecutionObserved
            && !receipt.trainEvaluateSurfaceEstablished
    }
}
