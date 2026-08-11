// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutFileIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutRepositoryIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let repository: String
    public let pullRequestNumber: Int
    public let observedRef: String
    public let mergeRevision: String
    public let mergeTree: String
    public let orderedParentRevisions: [String]
    public let reviewedHeadRevision: String
    public let reviewedHeadTree: String
    public let historyPreservingTwoParentMergeObserved: Bool
    public let mergeTreeEqualsReviewedHeadTree: Bool
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutStepOutcomeV1:
    Codable,
    Equatable,
    Sendable
{
    public let number: Int
    public let name: String
    public let status: String
    public let conclusion: String
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutJobObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let jobID: Int
    public let name: String
    public let status: String
    public let conclusion: String
    public let apiStartedAt: String
    public let apiCompletedAt: String
    public let firstDecodedLogTimestamp: String
    public let lastDecodedLogTimestamp: String
    public let decodedLogObservationDurationMilliseconds: Int
    public let steps: [PrimeNativeDecoderTrajectoryDesignTimeoutStepOutcomeV1]
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutLogIdentityV1:
    Codable,
    Equatable,
    Sendable
{
    public let role: String
    public let archiveMemberPath: String
    public let firstTimestamp: String
    public let lastTimestamp: String
    public let byteCount: Int
    public let lineCount: Int
    public let sha256: String
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutFocusedTestsV1:
    Codable,
    Equatable,
    Sendable
{
    public let apiStartedAt: String
    public let apiCompletedAt: String
    public let groupNames: [String]
    public let groupTestCounts: [Int]
    public let totalTestCount: Int
    public let failureCount: Int
    public let skipCount: Int
    public let allFiveCommandsCompleted: Bool
    public let publicCheckpointV2IOExecuted: Bool
    public let modelAllocated: Bool
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutMetalObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let commandStartedAt: String
    public let successRecordedAt: String
    public let decodedLogDurationMilliseconds: Int
    public let deviceName: String
    public let deviceObserved: Bool
    public let metallibByteCount: Int
    public let metallibSHA256: String
    public let testCount: Int
    public let failureCount: Int
    public let skipCount: Int
    public let suiteCompleted: Bool
    public let syntheticCheckpointTestCount: Int
    public let publicCheckpointV2IOExecuted: Bool
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutRuntimeObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let firstOutputAt: String
    public let receiptRecordedAt: String
    public let successRecordedAt: String
    public let receiptCount: Int
    public let maintainedDependencyClosureEstablished: Bool
    public let boundedMLXInitializationEstablished: Bool
    public let checkpointIOObserved: Bool
    public let decoderForwardObserved: Bool
    public let trainingExecutionObserved: Bool
    public let commandCompleted: Bool
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutTokenizerObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let firstOutputAt: String
    public let probeProductBuildCompletedAt: String
    public let probeProductBuildReportedDurationMilliseconds: Int
    public let authorityTestBuildLastProgressAt: String
    public let authorityTestBuildLastProgress: String
    public let cancellationRecordedAt: String
    public let phaseOutcome: String
    public let probeProductBuildCompleted: Bool
    public let authorityTestBuildCompleted: Bool
    public let testExecutionStarted: Bool
    public let executedTestCount: Int
    public let probeExecuted: Bool
    public let native300MModelAllocated: Bool
    public let decoderForwardObserved: Bool
    public let receiptCount: Int
    public let successMarkerObserved: Bool
    public let semanticFailureObserved: Bool
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutArtifactAndLogEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let rawRunLogZIPByteCount: Int
    public let rawRunLogZIPSHA256: String
    public let rawRunLogZIPMemberCount: Int
    public let rawRunLogZIPUncompressedByteCount: Int
    public let rawRunLogZIPMemberTimestampsAreDOSZero: Bool
    public let decodedJobLogs: [
        PrimeNativeDecoderTrajectoryDesignTimeoutLogIdentityV1
    ]
    public let exactStepMembers: [
        PrimeNativeDecoderTrajectoryDesignTimeoutLogIdentityV1
    ]
    public let bindingKind: String
    public let logsRetainedInRepository: Bool
    public let publishedWorkflowArtifactCount: Int
    public let workflowArtifactAPIResponseWasExactEmptyArray: Bool
    public let artifactUploadStepPresent: Bool
}

public struct PrimeNativeDecoderTrajectoryDesignTimeoutAuthorityCeilingV1:
    Codable,
    Equatable,
    Sendable
{
    public let semanticFailureEstablished: Bool
    public let trajectoryDesignInvalidated: Bool
    public let timeoutRepairImplementedByThisObservation: Bool
    public let workflowMutationAuthorizedByThisObservation: Bool
    public let rerunAuthorizedByThisObservation: Bool
    public let rerunObserved: Bool
    public let exactResumeImplementationEstablished: Bool
    public let exactResumeExecutionObserved: Bool
    public let tinyCPUTrainEvaluateMechanicsObserved: Bool
    public let trajectoryCheckpointWriteObserved: Bool
    public let trajectoryCheckpointLoadObserved: Bool
    public let trajectoryArtifactAvailable: Bool
    public let trajectoryArtifactRetentionEstablished: Bool
    public let trajectoryArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let trainingResumeEstablished: Bool
    public let native300MCheckpointWriteObserved: Bool
    public let native300MCheckpointLoadObserved: Bool
    public let native300MTrainingObserved: Bool
    public let native300MTrainingAuthorized: Bool
    public let modelQualityEstablished: Bool
    public let functionalTrainingAuthorized: Bool
    public let longTrainingAuthorized: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let pullRequestMergeAuthorizedByThisObservation: Bool
}

/// Exact observation of the first reviewed-main run for the dependency-free
/// trajectory exact-resume design arc.
///
/// The active-root job and the reviewed-main focused, Metal, and maintained-
/// runtime phases completed. The final tokenizer phase exhausted the configured
/// 45-minute job budget while compiling its authority tests, before any
/// tokenizer test or probe execution. This is a timeout/incomplete observation,
/// not a semantic failure. It grants no retry, execution, checkpoint, resume,
/// training, admission, or downstream authority.
public struct PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let observationID: String
    public let observationKind: String
    public let classification: String
    public let predecessorDesignAuthorityID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorRequiredForConsumption: Bool
    public let predecessorCanonicalJSONSHA256: String
    public let predecessorDesignSource:
        PrimeNativeDecoderTrajectoryDesignTimeoutFileIdentityV1
    public let observedWorkflowSource:
        PrimeNativeDecoderTrajectoryDesignTimeoutFileIdentityV1
    public let observedActiveGateSource:
        PrimeNativeDecoderTrajectoryDesignTimeoutFileIdentityV1
    public let repositoryIdentity:
        PrimeNativeDecoderTrajectoryDesignTimeoutRepositoryIdentityV1

    public let workflowName: String
    public let runID: Int
    public let runNumber: Int
    public let runAttempt: Int
    public let runEvent: String
    public let runURL: String
    public let runCreatedAt: String
    public let runStartedAt: String
    public let runUpdatedAt: String
    public let runStatus: String
    public let runConclusion: String
    public let configuredReviewedMainTimeoutMinutes: Int
    public let configuredTimeoutBoundaryReached: Bool
    public let exactCancellationErrorLine: String
    public let exactCancellationErrorLineCount: Int
    public let exactTimeoutAnnotation: String
    public let exactTimeoutAnnotationCount: Int
    public let timeoutInferenceBasis: [String]

    public let activeRootJob:
        PrimeNativeDecoderTrajectoryDesignTimeoutJobObservationV1
    public let activeRootLatinTestCount: Int
    public let activeRootLatinFailureCount: Int
    public let reviewedMainJob:
        PrimeNativeDecoderTrajectoryDesignTimeoutJobObservationV1
    public let focusedTests:
        PrimeNativeDecoderTrajectoryDesignTimeoutFocusedTestsV1
    public let liveCommandOrder: [String]
    public let metal:
        PrimeNativeDecoderTrajectoryDesignTimeoutMetalObservationV1
    public let maintainedRuntime:
        PrimeNativeDecoderTrajectoryDesignTimeoutRuntimeObservationV1
    public let tokenizer:
        PrimeNativeDecoderTrajectoryDesignTimeoutTokenizerObservationV1
    public let artifactAndLogEvidence:
        PrimeNativeDecoderTrajectoryDesignTimeoutArtifactAndLogEvidenceV1

    public let retiredSeed42LauncherCommandCount: Int
    public let retiredSeed43LauncherCommandCount: Int
    public let retiredSeed42LauncherCommand: String
    public let retiredSeed43LauncherCommand: String
    public let checkpointReceiptMarkerCounts: [String: Int]
    public let retiredCheckpointArtifactFilenameCounts: [String: Int]
    public let publicCheckpointV2IOExecuted: Bool
    public let onlyPureOrSyntheticCheckpointTestsObserved: Bool
    public let timeoutIncompleteNotSemanticFailure: Bool
    public let partialSuccessDoesNotCompleteReviewedMainJob: Bool
    public let aRerunWouldBeNewExecutionNotRecovery: Bool
    public let allowedSourceImports: [String]
    public let mlxImportedByObservationSource: Bool
    public let modelImportedByObservationSource: Bool
    public let processExecutionUsedByObservationSource: Bool
    public let filesystemIOUsedByObservationSource: Bool
    public let networkIOUsedByObservationSource: Bool
    public let observationRuntimeExecutionPerformed: Bool
    public let authorityCeiling:
        PrimeNativeDecoderTrajectoryDesignTimeoutAuthorityCeilingV1
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV1 = Self(
        schemaVersion: 1,
        observationID:
            "ergentics_prime_native_decoder_trajectory_design_reviewed_main_timeout_observation_v1",
        observationKind: "reviewed_main_timeout_observation",
        classification: "timeout_incomplete_not_semantic_failure",
        predecessorDesignAuthorityID:
            "ergentics_prime_native_decoder_trajectory_exact_resume_design_authority_v1",
        predecessorRemainsFrozen: true,
        predecessorRequiredForConsumption: true,
        predecessorCanonicalJSONSHA256:
            "ccd5e2acdd8fb5a522331ee843f0e212e842453e2dcacd263702bc9951436589",
        predecessorDesignSource: .init(
            path:
                "Sources/PrimeCore/PrimeNativeDecoderTrajectoryExactResumeDesignAuthority.swift",
            gitMode: "100644",
            gitBlob: "20bcbf28ddcfa9a6339510d53e81da02ada9953e",
            byteCount: 77_582,
            sha256:
                "92194cb171eb1219393008c1dcd3b1c7dfcb2fd9232f4149391dfc428a5e7969"
        ),
        observedWorkflowSource: .init(
            path: ".github/workflows/prime-active-root-quarantine.yml",
            gitMode: "100644",
            gitBlob: "0c484281a624b9f67c9a662271983a2651cb8eaf",
            byteCount: 35_445,
            sha256:
                "3b3c83bf6aa483f1a3e65eccdf00aa3bc97d425226fdc98e6c02f28457bc40de"
        ),
        observedActiveGateSource: .init(
            path: ".github/scripts/prime-ci-active-root-quarantine.sh",
            gitMode: "100755",
            gitBlob: "87b7286416b16791cc88b9c2083acbf825b5d46d",
            byteCount: 233_975,
            sha256:
                "1955a60afb1899b54de6ada7ae050e180c4281528f4d0de305e1d1accf564bf4"
        ),
        repositoryIdentity: .init(
            repository: "Ergentics/ergentics-prime",
            pullRequestNumber: 81,
            observedRef: "refs/heads/main",
            mergeRevision: "5eeba9e6483bafd1bbb5c96753491b3dd1609ea0",
            mergeTree: "aeae7b7f0c7ab1eb0236a6a2216789c62a082ea1",
            orderedParentRevisions: [
                "3ab523afa0a50fbea42dd3e3ead1f010b7e1b800",
                "646e853a7814c96ab61d97ff7540a8838ada1173",
            ],
            reviewedHeadRevision:
                "646e853a7814c96ab61d97ff7540a8838ada1173",
            reviewedHeadTree:
                "aeae7b7f0c7ab1eb0236a6a2216789c62a082ea1",
            historyPreservingTwoParentMergeObserved: true,
            mergeTreeEqualsReviewedHeadTree: true
        ),
        workflowName: "Prime active-root quarantine",
        runID: 31_509_046_898,
        runNumber: 59,
        runAttempt: 1,
        runEvent: "push",
        runURL:
            "https://github.com/Ergentics/ergentics-prime/actions/runs/31509046898",
        runCreatedAt: "2026-08-11T15:48:37Z",
        runStartedAt: "2026-08-11T15:48:37Z",
        runUpdatedAt: "2026-08-11T16:36:58Z",
        runStatus: "completed",
        runConclusion: "cancelled",
        configuredReviewedMainTimeoutMinutes: 45,
        configuredTimeoutBoundaryReached: true,
        exactCancellationErrorLine:
            "2026-08-11T16:36:34.9237830Z ##[error]The operation was canceled.",
        exactCancellationErrorLineCount: 1,
        exactTimeoutAnnotation:
            "The job has exceeded the maximum execution time of 45m0s",
        exactTimeoutAnnotationCount: 1,
        timeoutInferenceBasis: [
            "workflow_reviewed_main_timeout_minutes_45",
            "reviewed_main_job_elapsed_beyond_45_minutes",
            "github_job_conclusion_cancelled",
            "sole_error_operation_was_canceled",
        ],
        activeRootJob: .init(
            jobID: 93_837_901_444,
            name: "First-party MLX / active-root quarantine",
            status: "completed",
            conclusion: "success",
            apiStartedAt: "2026-08-11T15:48:40Z",
            apiCompletedAt: "2026-08-11T15:51:15Z",
            firstDecodedLogTimestamp: "2026-08-11T15:48:41.0976780Z",
            lastDecodedLogTimestamp: "2026-08-11T15:51:11.8648170Z",
            decodedLogObservationDurationMilliseconds: 150_767,
            steps: [
                .init(number: 1, name: "Set up job", status: "completed", conclusion: "success"),
                .init(number: 2, name: "Check out the exact Prime revision", status: "completed", conclusion: "success"),
                .init(number: 3, name: "Validate active metadata and preserved history", status: "completed", conclusion: "success"),
                .init(number: 4, name: "Parse the changed Swift contracts without dependencies", status: "completed", conclusion: "success"),
                .init(number: 5, name: "Validate isolated Latin capture and observation contracts", status: "completed", conclusion: "success"),
                .init(number: 6, name: "Record the authority ceiling", status: "completed", conclusion: "success"),
                .init(number: 7, name: "Complete job", status: "completed", conclusion: "success"),
            ]
        ),
        activeRootLatinTestCount: 116,
        activeRootLatinFailureCount: 0,
        reviewedMainJob: .init(
            jobID: 93_838_685_818,
            name: "Reviewed main / focused source contracts",
            status: "completed",
            conclusion: "cancelled",
            apiStartedAt: "2026-08-11T15:51:18Z",
            apiCompletedAt: "2026-08-11T16:36:50Z",
            firstDecodedLogTimestamp: "2026-08-11T15:51:19.6910230Z",
            lastDecodedLogTimestamp: "2026-08-11T16:36:35.1638200Z",
            decodedLogObservationDurationMilliseconds: 2_715_472,
            steps: [
                .init(number: 1, name: "Set up job", status: "completed", conclusion: "success"),
                .init(number: 2, name: "Record the hosted Apple toolchain", status: "completed", conclusion: "success"),
                .init(number: 3, name: "Check out reviewed main exactly", status: "completed", conclusion: "success"),
                .init(number: 4, name: "Fetch the exact private dependency without evaluating Prime", status: "completed", conclusion: "success"),
                .init(number: 5, name: "Compile and run the focused contracts without a credential", status: "completed", conclusion: "success"),
                .init(number: 6, name: "Run the Prime-owned decoder on live Metal", status: "completed", conclusion: "cancelled"),
                .init(number: 7, name: "Complete job", status: "completed", conclusion: "success"),
            ]
        ),
        focusedTests: .init(
            apiStartedAt: "2026-08-11T15:51:37Z",
            apiCompletedAt: "2026-08-11T16:11:45Z",
            groupNames: [
                "root_focused_source_contracts",
                "checkpoint_compatibility_v2",
                "checkpoint_v2_container_io",
                "checkpoint_v2_io_execution_pure",
                "checkpoint_v2_io_root_identity_repair_execution_pure",
            ],
            groupTestCounts: [32, 1, 1, 2, 2],
            totalTestCount: 38,
            failureCount: 0,
            skipCount: 0,
            allFiveCommandsCompleted: true,
            publicCheckpointV2IOExecuted: false,
            modelAllocated: false
        ),
        liveCommandOrder: [
            "prime-ci-native-decoder-metal.sh",
            "prime-ci-native-decoder-runtime-closure.sh",
            "prime-ci-native-decoder-tokenizer-compatibility.sh",
        ],
        metal: .init(
            commandStartedAt: "2026-08-11T16:11:45.0908850Z",
            successRecordedAt: "2026-08-11T16:18:40.1495180Z",
            decodedLogDurationMilliseconds: 415_059,
            deviceName: "Apple Paravirtual device",
            deviceObserved: true,
            metallibByteCount: 6_292_764,
            metallibSHA256:
                "01ef9960491bbf2505aee29f1a7cff683c874133c2544138109adfaeb45a68ae",
            testCount: 44,
            failureCount: 0,
            skipCount: 0,
            suiteCompleted: true,
            syntheticCheckpointTestCount: 14,
            publicCheckpointV2IOExecuted: false
        ),
        maintainedRuntime: .init(
            firstOutputAt: "2026-08-11T16:18:41.8837640Z",
            receiptRecordedAt: "2026-08-11T16:27:33.4893740Z",
            successRecordedAt: "2026-08-11T16:27:34.9732830Z",
            receiptCount: 1,
            maintainedDependencyClosureEstablished: true,
            boundedMLXInitializationEstablished: true,
            checkpointIOObserved: false,
            decoderForwardObserved: false,
            trainingExecutionObserved: false,
            commandCompleted: true
        ),
        tokenizer: .init(
            firstOutputAt: "2026-08-11T16:27:37.0753920Z",
            probeProductBuildCompletedAt: "2026-08-11T16:36:24.1990270Z",
            probeProductBuildReportedDurationMilliseconds: 527_150,
            authorityTestBuildLastProgressAt:
                "2026-08-11T16:36:27.6723230Z",
            authorityTestBuildLastProgress: "[3/7] Write swift-version",
            cancellationRecordedAt: "2026-08-11T16:36:34.9237830Z",
            phaseOutcome:
                "tokenizer_authority_test_build_cancelled_before_test_execution",
            probeProductBuildCompleted: true,
            authorityTestBuildCompleted: false,
            testExecutionStarted: false,
            executedTestCount: 0,
            probeExecuted: false,
            native300MModelAllocated: false,
            decoderForwardObserved: false,
            receiptCount: 0,
            successMarkerObserved: false,
            semanticFailureObserved: false
        ),
        artifactAndLogEvidence: .init(
            rawRunLogZIPByteCount: 1_342_624,
            rawRunLogZIPSHA256:
                "4c486e32f9b8a70034157e67db700a3f78ff556bf4c772ed4b7d5cab050d1232",
            rawRunLogZIPMemberCount: 18,
            rawRunLogZIPUncompressedByteCount: 20_896_693,
            rawRunLogZIPMemberTimestampsAreDOSZero: true,
            decodedJobLogs: [
                .init(
                    role: "active_root_decoded_job_log_aggregate",
                    archiveMemberPath:
                        "1_First-party MLX _ active-root quarantine.txt",
                    firstTimestamp: "2026-08-11T15:48:41.0976780Z",
                    lastTimestamp: "2026-08-11T15:51:11.8648170Z",
                    byteCount: 227_498,
                    lineCount: 1_723,
                    sha256:
                        "5042f65f7185aa0395b126b4e9cdc8dffee39fb2bc277b9aae4bbf383fe3961a"
                ),
                .init(
                    role: "reviewed_main_decoded_job_log_aggregate",
                    archiveMemberPath:
                        "0_Reviewed main _ focused source contracts.txt",
                    firstTimestamp: "2026-08-11T15:51:19.6910230Z",
                    lastTimestamp: "2026-08-11T16:36:35.1638200Z",
                    byteCount: 10_220_130,
                    lineCount: 78_313,
                    sha256:
                        "20844ca1de14ac3f3ab1990494338ea994a353d0b063f36be6669ecaa7219038"
                ),
            ],
            exactStepMembers: [
                .init(
                    role: "focused_contracts_raw_zip_step_member",
                    archiveMemberPath:
                        "Reviewed main _ focused source contracts/5_Compile and run the focused contracts without a credential.txt",
                    firstTimestamp: "2026-08-11T15:51:37.6798770Z",
                    lastTimestamp: "2026-08-11T16:11:44.9163860Z",
                    byteCount: 329_706,
                    lineCount: 3_253,
                    sha256:
                        "270f893baaf84ad69cd464df17ba6db96b4e238f06b635607802f3bcdb6c3dc8"
                ),
                .init(
                    role: "live_metal_runtime_tokenizer_raw_zip_step_member",
                    archiveMemberPath:
                        "Reviewed main _ focused source contracts/6_Run the Prime-owned decoder on live Metal.txt",
                    firstTimestamp: "2026-08-11T16:11:45.0908790Z",
                    lastTimestamp: "2026-08-11T16:36:34.9237480Z",
                    byteCount: 9_879_300,
                    lineCount: 74_917,
                    sha256:
                        "06eaa2ad085611f8e0395836043b8e77a8f6eea0b059987feaa0e8d1be88b296"
                ),
            ],
            bindingKind:
                "raw_github_run_log_zip_plus_exact_decoded_job_aggregates_and_step_members",
            logsRetainedInRepository: false,
            publishedWorkflowArtifactCount: 0,
            workflowArtifactAPIResponseWasExactEmptyArray: true,
            artifactUploadStepPresent: false
        ),
        retiredSeed42LauncherCommandCount: 0,
        retiredSeed43LauncherCommandCount: 0,
        retiredSeed42LauncherCommand:
            "bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io.sh",
        retiredSeed43LauncherCommand:
            "bash .github/scripts/prime-ci-native-decoder-checkpoint-v2-io-root-identity-repair.sh",
        checkpointReceiptMarkerCounts: [
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_BEGIN": 0,
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_CHUNK": 0,
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_RECEIPT_END": 0,
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_BEGIN": 0,
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_CHUNK": 0,
            "PRIME_NATIVE_DECODER_CHECKPOINT_V2_IO_ROOT_IDENTITY_REPAIR_RECEIPT_END": 0,
        ],
        retiredCheckpointArtifactFilenameCounts: [
            "checkpoint-v2-native300m-seed42.safetensors": 0,
            "checkpoint-v2-native300m-seed43-root-identity-repair.safetensors": 0,
        ],
        publicCheckpointV2IOExecuted: false,
        onlyPureOrSyntheticCheckpointTestsObserved: true,
        timeoutIncompleteNotSemanticFailure: true,
        partialSuccessDoesNotCompleteReviewedMainJob: true,
        aRerunWouldBeNewExecutionNotRecovery: true,
        allowedSourceImports: ["Foundation"],
        mlxImportedByObservationSource: false,
        modelImportedByObservationSource: false,
        processExecutionUsedByObservationSource: false,
        filesystemIOUsedByObservationSource: false,
        networkIOUsedByObservationSource: false,
        observationRuntimeExecutionPerformed: false,
        authorityCeiling: .init(
            semanticFailureEstablished: false,
            trajectoryDesignInvalidated: false,
            timeoutRepairImplementedByThisObservation: false,
            workflowMutationAuthorizedByThisObservation: false,
            rerunAuthorizedByThisObservation: false,
            rerunObserved: false,
            exactResumeImplementationEstablished: false,
            exactResumeExecutionObserved: false,
            tinyCPUTrainEvaluateMechanicsObserved: false,
            trajectoryCheckpointWriteObserved: false,
            trajectoryCheckpointLoadObserved: false,
            trajectoryArtifactAvailable: false,
            trajectoryArtifactRetentionEstablished: false,
            trajectoryArtifactProvenanceEstablished: false,
            checkpointAdmissionGranted: false,
            trainingResumeEstablished: false,
            native300MCheckpointWriteObserved: false,
            native300MCheckpointLoadObserved: false,
            native300MTrainingObserved: false,
            native300MTrainingAuthorized: false,
            modelQualityEstablished: false,
            functionalTrainingAuthorized: false,
            longTrainingAuthorized: false,
            candidateAdmissionGranted: false,
            trialAuthorized: false,
            canaryReplacementAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false,
            pullRequestMergeAuthorizedByThisObservation: false
        ),
        status: "ABSTAIN_REVIEWED_MAIN_TIMEOUT_INCOMPLETE_NOT_SEMANTIC_FAILURE",
        orderedNextActions: [
            "append_timeout_budget_repair_under_separate_authority",
            "require_full_exact_main_completion_after_repair",
            "do_not_advance_to_tiny_cpu_mechanics_before_full_completion",
        ]
    )

    public func canonicalData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(self)
    }

    public static func decodeCanonical(
        _ data: Data
    ) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationError
                .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNativeDecoderTrajectoryDesignReviewedMainTimeoutObservationError
                .contractDrift
        }
    }
}
