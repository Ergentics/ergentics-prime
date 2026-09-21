// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeSecureChildProcessEvidenceDesignAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

/// Dependency-free design authority for a neutral Prime secure-child process
/// and diagnostic-evidence layer.
///
/// This value contains no executable locator, argument vector, environment,
/// process, lease, filesystem-write, MLX, Metal, or Native300M capability. It
/// records the green retirement boundary after the exhausted Stage-7 attempt,
/// binds the already maintained Prime secure-child substrate, and freezes the
/// requirements that a separately authorized implementation must satisfy.
public struct PrimeSecureChildProcessEvidenceDesignAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public struct SourceIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct FailurePredecessor: Codable, Equatable, Sendable {
        public let observationID: String
        public let canonicalSHA256: String
        public let observationSource: SourceIdentity
        public let observationTest: SourceIdentity
        public let privateCauseRecoverable: Bool
        public let stage7LeaseEvidence: String
        public let orphanSleepObserved: Bool
        public let watchdogChildAttributionDirectlyObserved: Bool
        public let watchdogChildAttributionInferenceOnly: Bool
        public let oneShotConsumed: Bool
        public let oneShotExhausted: Bool
        public let failureObservationAuthorizesNothing: Bool
        public let retirementObservedAtObservationAuthoring: Bool
    }

    public struct RetirementClosure: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParents: [String]
        public let signedMergeVerified: Bool
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let successfulAttempt: Int
        public let checkSuiteID: Int
        public let previousAttemptConclusion: String
        public let previousAttemptExternallyCancelled: Bool
        public let activeJobID: Int
        public let reviewedJobID: Int
        public let activeLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedMetalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let tokenizerTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let stage7JobCount: Int
        public let stage7LauncherInvocationCount: Int
        public let stage7ExecutableInvocationCount: Int
        public let stage7ReceiptCount: Int
        public let actionsArtifactCount: Int
        public let admittedSourceIdentitySHA256: String
        public let retirementPreservedIndexSHA256: String
        public let laterRetirementClosureObserved: Bool
    }

    public struct ExistingSubstrate: Codable, Equatable, Sendable {
        public let orderedSourceIdentities: [SourceIdentity]
        public let suspendedSpawnTransportAlreadyExists: Bool
        public let executableAndWorkingDirectoryProofAlreadyExists: Bool
        public let absoluteDeadlineAlreadyExists: Bool
        public let boundedConcurrentDrainAlreadyExists: Bool
        public let exactPIDReapAndGroupContainmentAlreadyExists: Bool
        public let singleOwnerSupervisionAlreadyExists: Bool
        public let closedNineModeFixtureCapabilityAlreadyExists: Bool
        public let duplicateSpawnWaitSignalImplementationPermitted: Bool
        public let initialImplementationTarget: String
        public let newSwiftPMTargetRequired: Bool
    }

    public struct ProcessPlanDesign: Codable, Equatable, Sendable {
        public let proposedPlanType: String
        public let proposedEvidenceType: String
        public let proposedTrustedCaptureType: String
        public let proposedInternalKernelType: String
        public let closedDomainAdaptersOnly: Bool
        public let arbitraryPublicExecutableCapabilityPermitted: Bool
        public let liveCaptureCodable: Bool
        public let transportProjectionCreatesLiveAuthority: Bool
        public let oneShotCapabilityRequired: Bool
        public let exactExecutableDescriptorRequired: Bool
        public let exactWorkingDirectoryDescriptorRequired: Bool
        public let suspendedAdmissionAndProofBeforeResumeRequired: Bool
        public let orderedUniqueEnvironmentRequired: Bool
        public let standardInputPolicy: String
        public let customInheritedDescriptorsInitiallyAuthorized: Bool
        public let absoluteMonotonicDeadlineRequired: Bool
        public let deadlineRefreshAfterFirstBytePermitted: Bool
        public let stdoutAndStderrDrainedConcurrentlyToTerminalState: Bool
        public let boundedCaptureRequired: Bool
        public let termThenKillRequired: Bool
        public let exactPIDReapRequired: Bool
        public let processGroupEmptyRequired: Bool
        public let unprovedContainmentDisposition: String
        public let hostileChildSandboxEstablished: Bool
        public let cleanupAfterMonitorSIGKILLGuaranteed: Bool
        public let cleanupAfterKernelOrHostLossGuaranteed: Bool
    }

    public struct EvidenceDesign: Codable, Equatable, Sendable {
        public let typedUnavailableDistinctFromFalse: Bool
        public let requiredProcessObservationKeys: [String]
        public let requiredStreamObservationKeys: [String]
        public let capturedPrefixSHA256IsFullStreamSHA256: Bool
        public let fullStreamSHA256MayBeClaimedWithoutFullHashing: Bool
        public let rawPIDPermittedInHostedProjection: Bool
        public let rawAbsolutePathPermittedInHostedProjection: Bool
        public let rawEnvironmentPermittedInHostedProjection: Bool
        public let rawStandardErrorPermittedInHostedProjection: Bool
        public let privateScientificFramePermittedInHostedProjection: Bool
        public let scientificOutcomeValueOnOperationalFailure: String
        public let diagnosticProjectionCreatesScientificReceipt: Bool
    }

    public struct DiagnosticDesign: Codable, Equatable, Sendable {
        public let maximumCanonicalByteCount: Int
        public let encoding: String
        public let requiredTopLevelKeys: [String]
        public let emissionPrerequisites: [String]
        public let maximumHostedLineCount: Int
        public let neutralLayerEmitsHostedLine: Bool
        public let closedHostedAdapterRequired: Bool
        public let localPersistenceAuthorized: Bool
        public let fsyncPersistenceAuthorized: Bool
        public let actionsArtifactUploadAuthorized: Bool
        public let retentionAuthorized: Bool
        public let successfulStreamEOFRequiredForProjection: Bool
        public let projectionOnUnprovedContainmentPermitted: Bool
    }

    public struct LeaseCompositionDesign: Codable, Equatable, Sendable {
        public let reviewedLeaseSource: SourceIdentity
        public let mechanism: String
        public let parentAndLeafLocksRequired: Bool
        public let nonblockingAcquisitionRequired: Bool
        public let descriptorAndNameRevalidationRequired: Bool
        public let staleFileContentsAuthoritative: Bool
        public let advisoryCooperatingProcessScopeOnly: Bool
        public let physicalMetalReservationEstablished: Bool
        public let mlxDeviceIdentityEstablished: Bool
        public let crossHostOrCrossJobContinuityEstablished: Bool
        public let currentIsHeldPropertyIsKernelProof: Bool
        public let stage7LeaseAcquisitionEvidence: String
        public let monitorHeldLeaseProvesWorkerLifetimeAfterMonitorLoss: Bool
        public let firstClassLeaseCompositionSeamRequired: Bool
        public let childLifetimeDescriptorTransferAuthorizedNow: Bool
        public let workerOwnedAcquisitionAuthorizedNow: Bool
        public let neutralLeaseGeneralizationAuthorizedNow: Bool
        public let laterLifetimePolicies: [String]
    }

    public struct ScaffoldingDesign: Codable, Equatable, Sendable {
        public let exactOrderedChangedPaths: [String]
        public let preservedIndexSHA256: String
        public let activeLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let embeddedProvenanceRecordCount: Int
        public let laterFixtureIntegrationSource: SourceIdentity
        public let laterFixtureModes: [String]
        public let laterFixtureCanaryAuthorizedNow: Bool
        public let scaffoldItselfImplementsProcessContainment: Bool
        public let scaffoldCanValidateClosedProcessContainmentLater: Bool
        public let scaffoldCanRecoverHistoricalRun129: Bool
        public let scaffoldItselfImplementsKernelLeaseExclusion: Bool
        public let scaffoldItselfProvidesDurableEvidence: Bool
    }

    public struct LanguageBoundary: Codable, Equatable, Sendable {
        public let pythonPermitted: Bool
        public let pythonInvocationCount: Int
        public let cppInvocationCount: Int
        public let cppFullNativeImplementationMayBeSeparatelyReviewedLater: Bool
        public let cppSwiftCABIAdapterMayBeSeparatelyReviewedLater: Bool
        public let cppImplementationAuthorizedNow: Bool
        public let cppRequiresSeparateTargetOrCABISeamReview: Bool
        public let currentRecommendedImplementationLanguage: String
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let designAuthorityEstablished: Bool
        public let implementationAuthorized: Bool
        public let diagnosticEmissionAuthorized: Bool
        public let hostedProjectionEmissionAuthorized: Bool
        public let customDescriptorTransportAuthorized: Bool
        public let processExecutionAuthorized: Bool
        public let fixtureExecutionAuthorized: Bool
        public let filesystemWriteAuthorized: Bool
        public let durableEvidenceEstablished: Bool
        public let durableTransactionImplementationAuthorized: Bool
        public let leaseAcquisitionAuthorized: Bool
        public let leaseContinuityEstablished: Bool
        public let watchdogRepairAuthorized: Bool
        public let oldLauncherMutationAuthorized: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let mlxAuthorized: Bool
        public let metalAuthorized: Bool
        public let native300MExecutionAuthorized: Bool
        public let scientificOutcomeEstablished: Bool
        public let checkpointAdmissionGranted: Bool
        public let stage8Authorized: Bool
        public let stage8AuthorityEstablished: Bool
        public let generalTrainingResumeAuthorized: Bool
        public let modelQualityEstablished: Bool
        public let candidateAdmissionAuthorized: Bool
        public let downstreamTrialAuthorized: Bool
        public let canaryAuthorized: Bool
        public let quantizationAuthorized: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
    }

    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let predecessorFailure: FailurePredecessor
    public let retirementClosure: RetirementClosure
    public let existingSubstrate: ExistingSubstrate
    public let processPlanDesign: ProcessPlanDesign
    public let evidenceDesign: EvidenceDesign
    public let diagnosticDesign: DiagnosticDesign
    public let leaseCompositionDesign: LeaseCompositionDesign
    public let scaffoldingDesign: ScaffoldingDesign
    public let languageBoundary: LanguageBoundary
    public let orderedSeparateSuccessorBoundaries: [String]
    public let authorityCeiling: AuthorityCeiling
    public let status: String

    public static let canonicalByteCount = 13_008
    public static let canonicalSHA256 =
        "7c3bb05e36b0094d5ec1003d52f5ac7224148001436cd45e69e8d540b3161c5f"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "prime_secure_child_process_evidence_design_authority_v1",
        authorityKind:
            "dependency_free_pure_design_authority_after_green_stage7_failure_retirement",
        predecessorFailure: .init(
            observationID:
                "ergentics_prime_native_decoder_b_specific_native300m_trajectory_checkpoint_execution_failure_observation_v1",
            canonicalSHA256:
                "0a188a5a99d90d90828dca5eadeb0a167a71c6a9348201ff103be042d60ccf97",
            observationSource: source(
                "Sources/PrimeCore/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservation.swift",
                "100644", "1db7426754a0983317d6d310a4f33893524f0a5e",
                60_513, 1_263,
                "e00ed2c5630a7619676d7b22bbea3ba9b77af07a87f4bdc9336dc7b033a48ac3",
                "frozen_run129_failure_observation"),
            observationTest: source(
                "Tests/PrimeCoreTests/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationTests.swift",
                "100644", "c1f770115d95ab0cb297121c273c4fd3df23b7d0",
                41_978, 905,
                "ed6b5ec4a7644cf521ebe580e04e1e1b08bdc8c16ebe86209dfcb950a8ca1bbc",
                "frozen_run129_failure_observation_test"),
            privateCauseRecoverable: false,
            stage7LeaseEvidence: "unknown",
            orphanSleepObserved: true,
            watchdogChildAttributionDirectlyObserved: false,
            watchdogChildAttributionInferenceOnly: true,
            oneShotConsumed: true,
            oneShotExhausted: true,
            failureObservationAuthorizesNothing: true,
            retirementObservedAtObservationAuthoring: false),
        retirementClosure: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            mergeRevision: "7077b6d2195e847bdff583e945e58d6c3b042d63",
            mergeTree: "d549a876312f9d65a86b030d35fb601a981dbdc6",
            orderedParents: [
                "88e001083c19f995f5ef5bd7c36f48356a90b997",
                "44ab4deb32e8f4c0840b39228fbb2ed71fa1b5ef",
            ],
            signedMergeVerified: true,
            workflowRunID: 31_888_756_258,
            workflowRunNumber: 131,
            successfulAttempt: 2,
            checkSuiteID: 86_497_384_253,
            previousAttemptConclusion: "cancelled",
            previousAttemptExternallyCancelled: true,
            activeJobID: 95_057_232_902,
            reviewedJobID: 95_057_662_875,
            activeLatinTestCount: 116,
            rootTestCount: 63,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 69,
            retainedMetalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            tokenizerTestCount: 1,
            retainedLiveTestCount: 46,
            aggregateTestCount: 115,
            stage7JobCount: 0,
            stage7LauncherInvocationCount: 0,
            stage7ExecutableInvocationCount: 0,
            stage7ReceiptCount: 0,
            actionsArtifactCount: 0,
            admittedSourceIdentitySHA256:
                "dd8ec692d700e9b90df232841bec3c1c591fdae45b6a8ddb94bb8946ac31447b",
            retirementPreservedIndexSHA256:
                "f587270f8fc32f7911b5881a2b5aed8f92fc9fd21de57ee63078838f4eb96b88",
            laterRetirementClosureObserved: true),
        existingSubstrate: .init(
            orderedSourceIdentities: [
                source(
                    "Sources/PrimeCore/PrimeSecureChildDarwinSubstrate.swift",
                    "100644", "a0a63e9e44b787aaa84cce7381e3af9f4b67fb49",
                    21_442, 726,
                    "072e8766286e0edda802f15df8137f94ff3febea7bf3f222d350d2efb776bfc5",
                    "suspended_spawn_and_pipe_transport"),
                source(
                    "Sources/PrimeCore/PrimeSecureChildDarwinProcessProof.swift",
                    "100644", "7385f62db90938f615a6e1c3cd02e10e20dd6716",
                    21_582, 561,
                    "a3bd049c0db3c0ae27f5bce06a0d376ce76e009a46bb42477f2c7c35cfbaf014",
                    "executable_cwd_and_mapped_image_proof"),
                source(
                    "Sources/PrimeCore/PrimeSecureChildDeadline.swift",
                    "100644", "89d2d2c8dd37baac399736b0cc9d88865dae68af",
                    10_800, 379,
                    "bd0e64cd50223b20e9ec6e947a9910ae10f3cfc09ee599634b1cb457134f81b9",
                    "absolute_deadline_and_cleanup_timeline"),
                source(
                    "Sources/PrimeCore/PrimeSecureChildDrains.swift",
                    "100644", "2d054829766e7833f28c94dd179f2f34249a4ac8",
                    13_245, 462,
                    "e52be6e132c346be60fc226a3d27b8f0345abde6d0aa485e168cdb5c4ae326f6",
                    "bounded_concurrent_stream_drains"),
                source(
                    "Sources/PrimeCore/PrimeSecureChildLifecycle.swift",
                    "100644", "e2b65441e015b7c4728f3bd3aaaf125ea21b137e",
                    26_436, 1_000,
                    "21fe130dbf1d4fc42437bfe6a9224d9f6d7f4568b7785c9dc5a0f8014538adb6",
                    "signal_wait_reap_and_group_containment"),
                source(
                    "Sources/PrimeCore/PrimeSecureChildSupervision.swift",
                    "100644", "cc8b3540727a5c295a7c13a6b9908c7ef37d125e",
                    23_501, 808,
                    "18f7bc3969732d2b5c2d46f67e38da7187fa243ce8c69072fafcd2b227abb511",
                    "single_owner_supervision"),
                source(
                    "Sources/PrimeCore/PrimeSecureChildKernel.swift",
                    "100644", "93f37a3bf3805dc92a4747b5fb98ce353a3ff7ab",
                    70_628, 1_997,
                    "a7cbd290903c9cee473ddf81c6a1d4ec47aa96848f305f1879d72dc48570f6a4",
                    "closed_validation_fixture_capability"),
            ],
            suspendedSpawnTransportAlreadyExists: true,
            executableAndWorkingDirectoryProofAlreadyExists: true,
            absoluteDeadlineAlreadyExists: true,
            boundedConcurrentDrainAlreadyExists: true,
            exactPIDReapAndGroupContainmentAlreadyExists: true,
            singleOwnerSupervisionAlreadyExists: true,
            closedNineModeFixtureCapabilityAlreadyExists: true,
            duplicateSpawnWaitSignalImplementationPermitted: false,
            initialImplementationTarget: "PrimeCore",
            newSwiftPMTargetRequired: false),
        processPlanDesign: .init(
            proposedPlanType: "PrimeSecureChildProcessPlanV1",
            proposedEvidenceType: "PrimeSecureChildProcessEvidenceV1",
            proposedTrustedCaptureType: "PrimeTrustedSecureChildProcessCapture",
            proposedInternalKernelType: "PrimeSecureChildExecutionKernel",
            closedDomainAdaptersOnly: true,
            arbitraryPublicExecutableCapabilityPermitted: false,
            liveCaptureCodable: false,
            transportProjectionCreatesLiveAuthority: false,
            oneShotCapabilityRequired: true,
            exactExecutableDescriptorRequired: true,
            exactWorkingDirectoryDescriptorRequired: true,
            suspendedAdmissionAndProofBeforeResumeRequired: true,
            orderedUniqueEnvironmentRequired: true,
            standardInputPolicy: "dev_null",
            customInheritedDescriptorsInitiallyAuthorized: false,
            absoluteMonotonicDeadlineRequired: true,
            deadlineRefreshAfterFirstBytePermitted: false,
            stdoutAndStderrDrainedConcurrentlyToTerminalState: true,
            boundedCaptureRequired: true,
            termThenKillRequired: true,
            exactPIDReapRequired: true,
            processGroupEmptyRequired: true,
            unprovedContainmentDisposition: "fail_stop_no_projection",
            hostileChildSandboxEstablished: false,
            cleanupAfterMonitorSIGKILLGuaranteed: false,
            cleanupAfterKernelOrHostLossGuaranteed: false),
        evidenceDesign: .init(
            typedUnavailableDistinctFromFalse: true,
            requiredProcessObservationKeys: [
                "spawn", "executable_identity", "working_directory_join",
                "mapped_executable_join", "deadline", "exit_or_signal",
                "term_attempt", "kill_attempt", "exact_pid_reap",
                "process_group_empty",
            ],
            requiredStreamObservationKeys: [
                "captured_prefix_byte_count", "captured_prefix_sha256",
                "observed_total_byte_count", "full_stream_sha256",
                "overflowed", "reached_eof", "read_errno", "write_errno",
            ],
            capturedPrefixSHA256IsFullStreamSHA256: false,
            fullStreamSHA256MayBeClaimedWithoutFullHashing: false,
            rawPIDPermittedInHostedProjection: false,
            rawAbsolutePathPermittedInHostedProjection: false,
            rawEnvironmentPermittedInHostedProjection: false,
            rawStandardErrorPermittedInHostedProjection: false,
            privateScientificFramePermittedInHostedProjection: false,
            scientificOutcomeValueOnOperationalFailure: "not_established",
            diagnosticProjectionCreatesScientificReceipt: false),
        diagnosticDesign: .init(
            maximumCanonicalByteCount: 4_096,
            encoding: "canonical_json_utf8_single_line",
            requiredTopLevelKeys: [
                "schema", "role", "phase", "operational_code",
                "completion", "deadline", "containment", "streams",
                "diagnostic_channel", "scientific_outcome",
            ],
            emissionPrerequisites: [
                "exact_pid_reaped", "process_group_empty",
                "stdout_drain_terminal", "stderr_drain_terminal",
                "stream_descriptors_closed", "allowlisted_projection_valid",
            ],
            maximumHostedLineCount: 1,
            neutralLayerEmitsHostedLine: false,
            closedHostedAdapterRequired: true,
            localPersistenceAuthorized: false,
            fsyncPersistenceAuthorized: false,
            actionsArtifactUploadAuthorized: false,
            retentionAuthorized: false,
            successfulStreamEOFRequiredForProjection: false,
            projectionOnUnprovedContainmentPermitted: false),
        leaseCompositionDesign: .init(
            reviewedLeaseSource: source(
                "Sources/PrimeCore/PrimeMetalDeviceLease.swift",
                "100644", "da3daa54802b67dc2c8c04a89b388e9927dd8726",
                16_985, 534,
                "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657",
                "descriptor_anchored_advisory_resource_lease"),
            mechanism: "darwin_parent_and_leaf_flock",
            parentAndLeafLocksRequired: true,
            nonblockingAcquisitionRequired: true,
            descriptorAndNameRevalidationRequired: true,
            staleFileContentsAuthoritative: false,
            advisoryCooperatingProcessScopeOnly: true,
            physicalMetalReservationEstablished: false,
            mlxDeviceIdentityEstablished: false,
            crossHostOrCrossJobContinuityEstablished: false,
            currentIsHeldPropertyIsKernelProof: false,
            stage7LeaseAcquisitionEvidence: "unknown",
            monitorHeldLeaseProvesWorkerLifetimeAfterMonitorLoss: false,
            firstClassLeaseCompositionSeamRequired: true,
            childLifetimeDescriptorTransferAuthorizedNow: false,
            workerOwnedAcquisitionAuthorizedNow: false,
            neutralLeaseGeneralizationAuthorizedNow: false,
            laterLifetimePolicies: [
                "monitor_held_supervisor_and_publication_authority",
                "separately_reviewed_child_lifetime_metal_resource_lease",
            ]),
        scaffoldingDesign: .init(
            exactOrderedChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeSecureChildProcessEvidenceDesignAuthority.swift",
                "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceDesignAuthorityTests.swift",
            ],
            preservedIndexSHA256:
                "9d33a0f0e85178085afabb71cef1a83d8fa0bef0278beba48c032261f6a9f033",
            activeLatinTestCount: 116,
            rootTestCount: 64,
            isolatedTestCount: 6,
            focusedWholeTestCount: 70,
            retainedLiveTestCount: 46,
            aggregateTestCount: 116,
            embeddedProvenanceRecordCount: 498,
            laterFixtureIntegrationSource: source(
                "Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowSecureChildIntegration/PrimeValidationWorkflowSecureChildIntegration.swift",
                "100644", "cce94e857f770f8108d7a694675ca75386a40ddb",
                17_656, 537,
                "9404187780e89137686d036c6909c675608c8ebd3ca8077cafd5bb002debf5c2",
                "future_closed_nine_mode_compatibility_canary_only"),
            laterFixtureModes: [
                "pass", "logical-argument-zero", "nonzero-exit",
                "bounded-streams", "overflow", "hang", "self-signal",
                "descendant-retains-streams", "exit-without-result",
            ],
            laterFixtureCanaryAuthorizedNow: false,
            scaffoldItselfImplementsProcessContainment: false,
            scaffoldCanValidateClosedProcessContainmentLater: true,
            scaffoldCanRecoverHistoricalRun129: false,
            scaffoldItselfImplementsKernelLeaseExclusion: false,
            scaffoldItselfProvidesDurableEvidence: false),
        languageBoundary: .init(
            pythonPermitted: false,
            pythonInvocationCount: 0,
            cppInvocationCount: 0,
            cppFullNativeImplementationMayBeSeparatelyReviewedLater: true,
            cppSwiftCABIAdapterMayBeSeparatelyReviewedLater: true,
            cppImplementationAuthorizedNow: false,
            cppRequiresSeparateTargetOrCABISeamReview: true,
            currentRecommendedImplementationLanguage:
                "swift_over_existing_prime_darwin_substrate"),
        orderedSeparateSuccessorBoundaries: [
            "close_this_pure_process_evidence_design_authority",
            "separately_authorize_neutral_primecore_process_evidence_implementation",
            "observe_and_retire_only_a_bounded_closed_fixture_canary",
            "separately_authorize_neutral_resource_lease_generalization",
            "compose_monitor_held_lease_with_secure_containment",
            "separately_authorize_generic_durable_transaction_design_and_implementation",
            "separately_authorize_transactional_execution_composition",
            "only_then_review_a_newly_named_native300m_adapter_and_opportunity",
        ],
        authorityCeiling: .init(
            designAuthorityEstablished: true,
            implementationAuthorized: false,
            diagnosticEmissionAuthorized: false,
            hostedProjectionEmissionAuthorized: false,
            customDescriptorTransportAuthorized: false,
            processExecutionAuthorized: false,
            fixtureExecutionAuthorized: false,
            filesystemWriteAuthorized: false,
            durableEvidenceEstablished: false,
            durableTransactionImplementationAuthorized: false,
            leaseAcquisitionAuthorized: false,
            leaseContinuityEstablished: false,
            watchdogRepairAuthorized: false,
            oldLauncherMutationAuthorized: false,
            retryAuthorized: false,
            rerunAuthorized: false,
            replacementExecutionAuthorized: false,
            mlxAuthorized: false,
            metalAuthorized: false,
            native300MExecutionAuthorized: false,
            scientificOutcomeEstablished: false,
            checkpointAdmissionGranted: false,
            stage8Authorized: false,
            stage8AuthorityEstablished: false,
            generalTrainingResumeAuthorized: false,
            modelQualityEstablished: false,
            candidateAdmissionAuthorized: false,
            downstreamTrialAuthorized: false,
            canaryAuthorized: false,
            quantizationAuthorized: false,
            productUseAuthorized: false,
            publicationAuthorized: false),
        status:
            "DESIGN_ONLY_secure_child_process_evidence_reuse_existing_prime_substrate_lease_gap_explicit_no_execution_no_stage7_no_python_cpp_deferred")

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeSecureChildProcessEvidenceDesignAuthorityError
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
            PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationV1
                .frozenV1
        do {
            try failure.validateExactV1()
        } catch {
            throw PrimeSecureChildProcessEvidenceDesignAuthorityError
                .contractDrift
        }

        let closure = retirementClosure
        let substrate = existingSubstrate
        let process = processPlanDesign
        let evidence = evidenceDesign
        let diagnostic = diagnosticDesign
        let lease = leaseCompositionDesign
        let scaffold = scaffoldingDesign
        let language = languageBoundary
        let ceiling = authorityCeiling
        let canonical = try canonicalData()
        let falseClaims = [
            ceiling.implementationAuthorized,
            ceiling.diagnosticEmissionAuthorized,
            ceiling.hostedProjectionEmissionAuthorized,
            ceiling.customDescriptorTransportAuthorized,
            ceiling.processExecutionAuthorized,
            ceiling.fixtureExecutionAuthorized,
            ceiling.filesystemWriteAuthorized,
            ceiling.durableEvidenceEstablished,
            ceiling.durableTransactionImplementationAuthorized,
            ceiling.leaseAcquisitionAuthorized,
            ceiling.leaseContinuityEstablished,
            ceiling.watchdogRepairAuthorized,
            ceiling.oldLauncherMutationAuthorized,
            ceiling.retryAuthorized,
            ceiling.rerunAuthorized,
            ceiling.replacementExecutionAuthorized,
            ceiling.mlxAuthorized,
            ceiling.metalAuthorized,
            ceiling.native300MExecutionAuthorized,
            ceiling.scientificOutcomeEstablished,
            ceiling.checkpointAdmissionGranted,
            ceiling.stage8Authorized,
            ceiling.stage8AuthorityEstablished,
            ceiling.generalTrainingResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.candidateAdmissionAuthorized,
            ceiling.downstreamTrialAuthorized,
            ceiling.canaryAuthorized,
            ceiling.quantizationAuthorized,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]

        guard self == Self.frozenV1,
              schemaVersion == 1,
              predecessorFailure.observationID == failure.observationID,
              predecessorFailure.canonicalSHA256
                == PrimeSHA256.hexDigest(of: try failure.canonicalData()),
              predecessorFailure.canonicalSHA256
                == PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecutionFailureObservationV1
                    .canonicalSHA256,
              !predecessorFailure.retirementObservedAtObservationAuthoring,
              closure.laterRetirementClosureObserved,
              closure.orderedParents.count == 2,
              closure.successfulAttempt == 2,
              closure.previousAttemptConclusion == "cancelled",
              closure.previousAttemptExternallyCancelled,
              closure.activeLatinTestCount == 116,
              closure.isolatedGroupTestCounts == [1, 1, 2, 2],
              closure.isolatedTestCount
                == closure.isolatedGroupTestCounts.reduce(0, +),
              closure.focusedWholeTestCount
                == closure.rootTestCount + closure.isolatedTestCount,
              closure.retainedLiveTestCount
                == closure.retainedMetalTestCount
                    + closure.maintainedRuntimeTestCount
                    + closure.tokenizerTestCount,
              closure.aggregateTestCount
                == closure.focusedWholeTestCount
                    + closure.retainedLiveTestCount,
              closure.stage7JobCount == 0,
              closure.stage7LauncherInvocationCount == 0,
              closure.stage7ExecutableInvocationCount == 0,
              closure.stage7ReceiptCount == 0,
              closure.actionsArtifactCount == 0,
              substrate.orderedSourceIdentities.count == 7,
              Set(substrate.orderedSourceIdentities.map(\.path)).count == 7,
              substrate.orderedSourceIdentities.allSatisfy(Self.validSource),
              !substrate.duplicateSpawnWaitSignalImplementationPermitted,
              !substrate.newSwiftPMTargetRequired,
              process.closedDomainAdaptersOnly,
              !process.arbitraryPublicExecutableCapabilityPermitted,
              !process.liveCaptureCodable,
              !process.transportProjectionCreatesLiveAuthority,
              process.oneShotCapabilityRequired,
              process.suspendedAdmissionAndProofBeforeResumeRequired,
              process.absoluteMonotonicDeadlineRequired,
              !process.deadlineRefreshAfterFirstBytePermitted,
              process.stdoutAndStderrDrainedConcurrentlyToTerminalState,
              process.termThenKillRequired,
              process.exactPIDReapRequired,
              process.processGroupEmptyRequired,
              !process.hostileChildSandboxEstablished,
              !process.cleanupAfterMonitorSIGKILLGuaranteed,
              !process.cleanupAfterKernelOrHostLossGuaranteed,
              evidence.typedUnavailableDistinctFromFalse,
              !evidence.capturedPrefixSHA256IsFullStreamSHA256,
              !evidence.fullStreamSHA256MayBeClaimedWithoutFullHashing,
              !evidence.rawPIDPermittedInHostedProjection,
              !evidence.rawAbsolutePathPermittedInHostedProjection,
              !evidence.rawEnvironmentPermittedInHostedProjection,
              !evidence.rawStandardErrorPermittedInHostedProjection,
              !evidence.privateScientificFramePermittedInHostedProjection,
              evidence.scientificOutcomeValueOnOperationalFailure
                == "not_established",
              !evidence.diagnosticProjectionCreatesScientificReceipt,
              diagnostic.maximumCanonicalByteCount == 4_096,
              diagnostic.maximumHostedLineCount == 1,
              !diagnostic.neutralLayerEmitsHostedLine,
              diagnostic.closedHostedAdapterRequired,
              !diagnostic.localPersistenceAuthorized,
              !diagnostic.fsyncPersistenceAuthorized,
              !diagnostic.actionsArtifactUploadAuthorized,
              !diagnostic.retentionAuthorized,
              !diagnostic.successfulStreamEOFRequiredForProjection,
              !diagnostic.projectionOnUnprovedContainmentPermitted,
              Self.validSource(lease.reviewedLeaseSource),
              lease.parentAndLeafLocksRequired,
              lease.nonblockingAcquisitionRequired,
              lease.descriptorAndNameRevalidationRequired,
              !lease.staleFileContentsAuthoritative,
              lease.advisoryCooperatingProcessScopeOnly,
              !lease.physicalMetalReservationEstablished,
              !lease.mlxDeviceIdentityEstablished,
              !lease.crossHostOrCrossJobContinuityEstablished,
              !lease.currentIsHeldPropertyIsKernelProof,
              lease.stage7LeaseAcquisitionEvidence == "unknown",
              !lease.monitorHeldLeaseProvesWorkerLifetimeAfterMonitorLoss,
              lease.firstClassLeaseCompositionSeamRequired,
              !lease.childLifetimeDescriptorTransferAuthorizedNow,
              !lease.workerOwnedAcquisitionAuthorizedNow,
              !lease.neutralLeaseGeneralizationAuthorizedNow,
              scaffold.exactOrderedChangedPaths.count == 5,
              Set(scaffold.exactOrderedChangedPaths).count == 5,
              scaffold.rootTestCount == 64,
              scaffold.isolatedTestCount == 6,
              scaffold.focusedWholeTestCount
                == scaffold.rootTestCount + scaffold.isolatedTestCount,
              scaffold.aggregateTestCount
                == scaffold.focusedWholeTestCount
                    + scaffold.retainedLiveTestCount,
              scaffold.embeddedProvenanceRecordCount == 498,
              Self.validSource(scaffold.laterFixtureIntegrationSource),
              scaffold.laterFixtureModes.count == 9,
              !scaffold.laterFixtureCanaryAuthorizedNow,
              !scaffold.scaffoldItselfImplementsProcessContainment,
              scaffold.scaffoldCanValidateClosedProcessContainmentLater,
              !scaffold.scaffoldCanRecoverHistoricalRun129,
              !scaffold.scaffoldItselfImplementsKernelLeaseExclusion,
              !scaffold.scaffoldItselfProvidesDurableEvidence,
              !language.pythonPermitted,
              language.pythonInvocationCount == 0,
              language.cppInvocationCount == 0,
              language.cppFullNativeImplementationMayBeSeparatelyReviewedLater,
              language.cppSwiftCABIAdapterMayBeSeparatelyReviewedLater,
              !language.cppImplementationAuthorizedNow,
              language.cppRequiresSeparateTargetOrCABISeamReview,
              orderedSeparateSuccessorBoundaries.count == 8,
              ceiling.designAuthorityEstablished,
              falseClaims.allSatisfy({ !$0 }),
              canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256 else {
            throw PrimeSecureChildProcessEvidenceDesignAuthorityError
                .contractDrift
        }
    }

    private static func source(
        _ path: String,
        _ gitMode: String,
        _ gitBlob: String,
        _ byteCount: Int,
        _ lfByteCount: Int,
        _ sha256: String,
        _ role: String
    ) -> SourceIdentity {
        SourceIdentity(
            path: path,
            gitMode: gitMode,
            gitBlob: gitBlob,
            byteCount: byteCount,
            lfByteCount: lfByteCount,
            sha256: sha256,
            role: role)
    }

    private static func validSource(_ source: SourceIdentity) -> Bool {
        source.path.count > 3
            && !source.path.hasPrefix("/")
            && source.gitMode == "100644"
            && source.gitBlob.count == 40
            && source.byteCount > 0
            && source.lfByteCount > 0
            && source.sha256.count == 64
            && !source.role.isEmpty
    }
}
