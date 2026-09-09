// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeSecureChildProcessEvidenceImplementationAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

/// Pure authority for one deterministic implementation patch of the neutral
/// Prime secure-child process/evidence Layer A.
///
/// This value is data only. It carries no executable, arguments, environment,
/// process, descriptor, lease, hosted-output, MLX, Metal, or Native300M
/// capability. In particular, authorization of the exact source patch below
/// does not authorize executing the patch or its fixture canary.
public struct PrimeSecureChildProcessEvidenceImplementationAuthorityV1:
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

    public struct DesignPredecessor: Codable, Equatable, Sendable {
        public let authorityID: String
        public let canonicalByteCount: Int
        public let canonicalSHA256: String
        public let source: SourceIdentity
        public let test: SourceIdentity
        public let designAuthorityEstablished: Bool
        public let implementationAuthorizedByPredecessor: Bool
    }

    public struct ExactMainClosure: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParents: [String]
        public let pullRequestNumber: Int
        public let pullRequestBaseRevision: String
        public let pullRequestHeadRevision: String
        public let signedMergeVerified: Bool
        public let mergeTimestampUTC: String
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let previousAttemptURLIsNull: Bool
        public let workflowRerunCount: Int
        public let workflowConclusion: String
        public let workflowCreatedAtUTC: String
        public let workflowUpdatedAtUTC: String
        public let activeJobID: Int
        public let activeJobConclusion: String
        public let activeLatinTestCount: Int
        public let activeLatinFailureCount: Int
        public let reviewedJobID: Int
        public let reviewedJobConclusion: String
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedMetalTestCount: Int
        public let maintainedRuntimeTestCount: Int
        public let tokenizerTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let reviewedFailureCount: Int
        public let reviewedSkipCount: Int
        public let designAuthorityMethodStartCount: Int
        public let designAuthorityMethodPassCount: Int
        public let actionsArtifactCount: Int
        public let stage7JobCount: Int
        public let stage7LauncherInvocationCount: Int
        public let stage7ProductInvocationCount: Int
        public let stage7SupervisorInvocationCount: Int
        public let stage7ReceiptCount: Int
        public let secureChildFixtureInvocationCount: Int
        public let secureChildCaptureInvocationCount: Int
        public let leaseAcquisitionInvocationCount: Int
        public let pythonInterpreterInvocationCount: Int
        public let newCppImplementationInvocationCount: Int
        public let retainedMLXCompiledExistingCppDependency: Bool
        public let retainedMLXCopiedExistingPythonResources: Bool
    }

    public struct AuthorityScaffold: Codable, Equatable, Sendable {
        public let exactOrderedChangedPaths: [String]
        public let activeLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let embeddedProvenanceRecordCount: Int
        public let processMechanicsInvocationCount: Int
        public let fixtureInvocationCount: Int
        public let leaseInvocationCount: Int
        public let hostedDiagnosticEmissionCount: Int
    }

    public struct ImplementationPath: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let change: String
        public let role: String
        public let baselineIdentity: SourceIdentity?
    }

    public struct ImplementationScope: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [ImplementationPath]
        public let exactPathCount: Int
        public let addedSourcePathCount: Int
        public let modifiedSourcePathCount: Int
        public let addedTestPathCount: Int
        public let modifiedTestPathCount: Int
        public let integrationPathCount: Int
        public let onlyThesePathsAuthorized: Bool
        public let implementationMayBeginAfterAuthorityClosure: Bool
        public let implementationExecutionAuthorized: Bool
        public let expectedRootTestCount: Int
        public let expectedIsolatedTestCount: Int
        public let expectedFocusedWholeTestCount: Int
        public let expectedRetainedLiveTestCount: Int
        public let expectedAggregateTestCount: Int
        public let expectedEmbeddedProvenanceRecordCount: Int
    }

    public struct APISurface: Codable, Equatable, Sendable {
        public let orderedAuthorizedInternalTypeNames: [String]
        public let newTypesInternalOnly: Bool
        public let publicGenericExecutableAuthorityAdded: Bool
        public let publicArbitraryArgumentAuthorityAdded: Bool
        public let publicArbitraryEnvironmentAuthorityAdded: Bool
        public let processPlanCodable: Bool
        public let processEvidenceCodable: Bool
        public let trustedCaptureCodable: Bool
        public let trustedCaptureExactlyOneShot: Bool
        public let closedFirstPartyAdaptersOnly: Bool
        public let existingFixturePublicAPISpellingsMayChange: Bool
        public let standardInputPolicy: String
        public let customInheritedDescriptorsAuthorized: Bool
        public let orderedUniqueEnvironmentRequired: Bool
        public let exactExecutableDescriptorRequired: Bool
        public let exactWorkingDirectoryDescriptorRequired: Bool
        public let suspendedProofBeforeResumeRequired: Bool
        public let absoluteMonotonicUptimeDeadlineRequired: Bool
        public let continuousThroughSystemSleepClockEstablished: Bool
        public let hostileCodeSandboxEstablished: Bool
    }

    public struct EvidenceContract: Codable, Equatable, Sendable {
        public let typedUnavailableDistinctFromObservedFalse: Bool
        public let exactPIDReapRequired: Bool
        public let processGroupEmptyRequired: Bool
        public let termThenKillTimelineRequired: Bool
        public let signalSuppressionRecorded: Bool
        public let requiredProcessObservationKeys: [String]
        public let requiredStreamObservationKeys: [String]
        public let capturedPrefixSHA256MayClaimFullStreamSHA256: Bool
        public let failStopWithoutProjectionWhenContainmentUnproved: Bool
        public let processGroupContainsHostileDaemonization: Bool
        public let cleanupAfterKernelOrHostLossGuaranteed: Bool
    }

    public struct DrainTerminalAdjustment: Codable, Equatable, Sendable {
        public let orderedAuthorizedFiles: [String]
        public let workerFinishedPublishedOnlyAfterDescriptorsClose: Bool
        public let terminalStatesDistinguishEOFReadWriteAndCleanupErrors: Bool
        public let activeOrUnsettledDrainProjectsEvidence: Bool
        public let terminalErrorMayProjectAfterProvedContainment: Bool
        public let terminalErrorMayClaimReachedEOF: Bool
        public let fixtureSuccessStillRequiresEOFAndZeroErrors: Bool
        public let overflowContinuesDrainingToTerminalState: Bool
        public let capturedPrefixDigestIsFullStreamDigest: Bool
        public let duplicateRawProcessSyscallsAuthorized: Bool
    }

    public struct DiagnosticProjection: Codable, Equatable, Sendable {
        public let proposedEnvelopeType: String
        public let proposedProjectionType: String
        public let envelopeVisibility: String
        public let encoding: String
        public let maximumCanonicalByteCount: Int
        public let maximumLineCount: Int
        public let orderedAllowlistedTopLevelKeys: [String]
        public let rawPIDIncluded: Bool
        public let rawAbsolutePathIncluded: Bool
        public let rawEnvironmentIncluded: Bool
        public let rawStandardErrorIncluded: Bool
        public let privateScientificFrameIncluded: Bool
        public let scientificOutcomeValue: String
        public let constructionAuthorized: Bool
        public let neutralLayerEmissionAuthorized: Bool
        public let hostedEmissionAuthorized: Bool
        public let localPersistenceAuthorized: Bool
        public let fsyncAuthorized: Bool
        public let artifactUploadAuthorized: Bool
        public let retentionAuthorized: Bool
    }

    public struct LeaseComposition: Codable, Equatable, Sendable {
        public let seamVisibility: String
        public let optionalOpaqueRetentionSeamAuthorized: Bool
        public let deterministicFakeLeaseTestAuthorized: Bool
        public let externallyOwnedLeaseMayBeRetainedWhileOwnerLives: Bool
        public let seamItselfAcquiresLease: Bool
        public let concretePrimeMetalDeviceLeaseAdapterAuthorized: Bool
        public let leaseFileMutationAuthorized: Bool
        public let leaseReleaseOrReacquisitionAuthorized: Bool
        public let descriptorTransferToWorkerAuthorized: Bool
        public let workerOwnedAcquisitionAuthorized: Bool
        public let ownerDeathContinuityEstablished: Bool
        public let physicalMetalReservationEstablished: Bool
        public let mlxDeviceIdentityOrIdlenessEstablished: Bool
        public let crossHostOrCrossJobContinuityEstablished: Bool
        public let leaseTelemetryIsDurableEvidence: Bool
    }

    public struct DeterministicTest: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let method: String
        public let requiredBehavior: String
        public let invokesLiveProcess: Bool
        public let invokesLiveLease: Bool
    }

    public struct DeterministicTestMatrix: Codable, Equatable, Sendable {
        public let testFile: String
        public let exactOrderedTests: [DeterministicTest]
        public let exactTestCount: Int
        public let allFaultsAreInjectedValues: Bool
        public let liveFixtureExecutionAuthorized: Bool
        public let wallClockRaceRequired: Bool
        public let networkRequired: Bool
    }

    public struct SourceTopology: Codable, Equatable, Sendable {
        public let exactNewCoreFiles: [String]
        public let executionKernelMustReuseExistingPrimeSubstrate: Bool
        public let duplicateSpawnWaitSignalImplementationAuthorized: Bool
        public let rawProcessSyscallsAuthorizedInNewCoreFiles: Bool
        public let rawProcessSyscallsMayIncreaseInModifiedSubstrate: Bool
        public let foundationProcessAuthorized: Bool
        public let shellExecutionAuthorized: Bool
        public let pathSearchAuthorized: Bool
        public let inheritedAmbientEnvironmentAuthorized: Bool
        public let networkOrUploadAuthorized: Bool
        public let freeFormHostedPrintingAuthorized: Bool
        public let mlxMetalOrNative300ImportsAuthorized: Bool
        public let arbitraryExecutableFixtureAdapterAuthorized: Bool
    }

    public struct LanguageBoundary: Codable, Equatable, Sendable {
        public let currentImplementationLanguage: String
        public let pythonPermitted: Bool
        public let pythonInvocationCount: Int
        public let pythonSourcePathCount: Int
        public let cppNewImplementationInvocationCount: Int
        public let cppNewSourcePathCount: Int
        public let retainedBaselineCppDependencyCompilationObserved: Bool
        public let cppFullNativeAlternativeSeparatelyPermissibleLater: Bool
        public let cppSwiftCABIAlternativeSeparatelyPermissibleLater: Bool
        public let cppAlternativeAuthorizedNow: Bool
        public let cppAlternativeRequiresSeparateAuthority: Bool
    }

    public struct SuccessorCanary: Codable, Equatable, Sendable {
        public let authorityRequiredAfterImplementationGreen: Bool
        public let integrationSource: SourceIdentity
        public let orderedFixtureModes: [String]
        public let expectedAdapterInvocationCount: Int
        public let expectedActualChildCaptureCount: Int
        public let oneShotRaceIncluded: Bool
        public let executableReplacementIncluded: Bool
        public let leaseAcquisitionIncluded: Bool
        public let mlxMetalOrNative300Included: Bool
        public let hostedDiagnosticEmissionIncluded: Bool
        public let authorizedNow: Bool
        public let disposition: String
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let designAuthorityEstablished: Bool
        public let implementationAuthorityEstablished: Bool
        public let deterministicExact13SourcePatchAuthorized: Bool
        public let processExecutionAuthorized: Bool
        public let liveFixtureExecutionAuthorized: Bool
        public let hostedDiagnosticProjectionAuthorized: Bool
        public let hostedDiagnosticEmissionAuthorized: Bool
        public let customDescriptorTransportAuthorized: Bool
        public let durableEvidenceEstablished: Bool
        public let durableTransactionImplementationAuthorized: Bool
        public let leaseAcquisitionAuthorized: Bool
        public let leaseReleaseObservationAuthorized: Bool
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
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let designPredecessor: DesignPredecessor
    public let exactMainClosure: ExactMainClosure
    public let authorityScaffold: AuthorityScaffold
    public let implementationScope: ImplementationScope
    public let apiSurface: APISurface
    public let evidenceContract: EvidenceContract
    public let drainTerminalAdjustment: DrainTerminalAdjustment
    public let diagnosticProjection: DiagnosticProjection
    public let leaseComposition: LeaseComposition
    public let deterministicTestMatrix: DeterministicTestMatrix
    public let sourceTopology: SourceTopology
    public let languageBoundary: LanguageBoundary
    public let successorCanary: SuccessorCanary
    public let authorityCeiling: AuthorityCeiling
    public let orderedSuccessorBoundaries: [String]
    public let status: String

    public static let canonicalByteCount = 18_370
    public static let canonicalSHA256 =
        "43c29ff6e225219bfd13b642bd9ba2121aae9d2591bd1d1af3cf4d3bb41f08db"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_secure_child_process_evidence_implementation_authority_schema_v1",
        authorityID:
            "prime_secure_child_process_evidence_implementation_authority_v1",
        authorityKind:
            "pure_exact13_layer_a_implementation_authority_after_green_design_retirement",
        designPredecessor: .init(
            authorityID:
                "prime_secure_child_process_evidence_design_authority_v1",
            canonicalByteCount: 13_008,
            canonicalSHA256:
                "7c3bb05e36b0094d5ec1003d52f5ac7224148001436cd45e69e8d540b3161c5f",
            source: source(
                "Sources/PrimeCore/PrimeSecureChildProcessEvidenceDesignAuthority.swift",
                "100644", "aa8f971a061a3086aa1f8e9c829e2ef7a3d73c5a",
                40_198, 809,
                "e93c850726e725ccc170d4333812664ae9e558dc97d17603df36f40b4f19c3a1",
                "frozen_design_authority_source"),
            test: source(
                "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceDesignAuthorityTests.swift",
                "100644", "af5c9635d5c84ff63c402bf0e98c47a6965373e2",
                22_723, 553,
                "26ea368ad45d22df06591fc036e7496c2df6519a90ac5ba49f825d6568afc19b",
                "frozen_design_authority_exhaustive_pure_test"),
            designAuthorityEstablished: true,
            implementationAuthorizedByPredecessor: false),
        exactMainClosure: .init(
            repository: "Ergentics/ergentics-prime",
            ref: "refs/heads/main",
            mergeRevision: "bd8bd792ad77344c7c6b77de0459c1b53a6abd0b",
            mergeTree: "4fe40b0de8e38dad1837905e15cfbe73518b612b",
            orderedParents: [
                "7077b6d2195e847bdff583e945e58d6c3b042d63",
                "756dc967768029d5e11f46ede79e7447ae4297a9",
            ],
            pullRequestNumber: 118,
            pullRequestBaseRevision:
                "7077b6d2195e847bdff583e945e58d6c3b042d63",
            pullRequestHeadRevision:
                "756dc967768029d5e11f46ede79e7447ae4297a9",
            signedMergeVerified: true,
            mergeTimestampUTC: "2026-08-16T02:31:12Z",
            workflowRunID: 31_922_080_458,
            workflowRunNumber: 133,
            workflowAttempt: 1,
            checkSuiteID: 86_573_644_107,
            event: "push",
            previousAttemptURLIsNull: true,
            workflowRerunCount: 0,
            workflowConclusion: "success",
            workflowCreatedAtUTC: "2026-08-16T02:31:15Z",
            workflowUpdatedAtUTC: "2026-08-16T03:24:29Z",
            activeJobID: 95_103_468_969,
            activeJobConclusion: "success",
            activeLatinTestCount: 116,
            activeLatinFailureCount: 0,
            reviewedJobID: 95_103_856_298,
            reviewedJobConclusion: "success",
            rootTestCount: 64,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 70,
            retainedMetalTestCount: 44,
            maintainedRuntimeTestCount: 1,
            tokenizerTestCount: 1,
            retainedLiveTestCount: 46,
            aggregateTestCount: 116,
            reviewedFailureCount: 0,
            reviewedSkipCount: 0,
            designAuthorityMethodStartCount: 1,
            designAuthorityMethodPassCount: 1,
            actionsArtifactCount: 0,
            stage7JobCount: 0,
            stage7LauncherInvocationCount: 0,
            stage7ProductInvocationCount: 0,
            stage7SupervisorInvocationCount: 0,
            stage7ReceiptCount: 0,
            secureChildFixtureInvocationCount: 0,
            secureChildCaptureInvocationCount: 0,
            leaseAcquisitionInvocationCount: 0,
            pythonInterpreterInvocationCount: 0,
            newCppImplementationInvocationCount: 0,
            retainedMLXCompiledExistingCppDependency: true,
            retainedMLXCopiedExistingPythonResources: true),
        authorityScaffold: .init(
            exactOrderedChangedPaths: [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                "Sources/PrimeCore/PrimeSecureChildProcessEvidenceImplementationAuthority.swift",
                "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceImplementationAuthorityTests.swift",
            ],
            activeLatinTestCount: 116,
            rootTestCount: 65,
            isolatedTestCount: 6,
            focusedWholeTestCount: 71,
            retainedLiveTestCount: 46,
            aggregateTestCount: 117,
            embeddedProvenanceRecordCount: 500,
            processMechanicsInvocationCount: 0,
            fixtureInvocationCount: 0,
            leaseInvocationCount: 0,
            hostedDiagnosticEmissionCount: 0),
        implementationScope: .init(
            exactOrderedPaths: [
                path(1, ".github/scripts/prime-ci-active-root-quarantine.sh",
                    "modify", "bind_exact13_gate_and_deterministic_test_filter"),
                path(2, ".github/workflows/prime-active-root-quarantine.yml",
                    "modify", "compile_and_run_deterministic_pure_tests_only"),
                path(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                    "modify", "embed_exact13_source_identities"),
                path(4, "Sources/PrimeCore/PrimeSecureChildProcessPlan.swift",
                    "add", "internal_closed_process_plan"),
                path(5, "Sources/PrimeCore/PrimeSecureChildProcessEvidence.swift",
                    "add", "typed_operational_evidence_and_projection"),
                path(6, "Sources/PrimeCore/PrimeTrustedSecureChildProcessCapture.swift",
                    "add", "internal_one_shot_trusted_capture"),
                path(7, "Sources/PrimeCore/PrimeSecureChildExecutionKernel.swift",
                    "add", "internal_existing_substrate_composition"),
                path(8, "Sources/PrimeCore/PrimeSecureChildDrains.swift",
                    "modify", "terminal_drain_state_adjustment",
                    source(
                        "Sources/PrimeCore/PrimeSecureChildDrains.swift",
                        "100644", "2d054829766e7833f28c94dd179f2f34249a4ac8",
                        13_245, 462,
                        "e52be6e132c346be60fc226a3d27b8f0345abde6d0aa485e168cdb5c4ae326f6",
                        "authorized_baseline")),
                path(9, "Sources/PrimeCore/PrimeSecureChildSupervision.swift",
                    "modify", "compose_trusted_capture_and_terminal_drains",
                    source(
                        "Sources/PrimeCore/PrimeSecureChildSupervision.swift",
                        "100644", "cc8b3540727a5c295a7c13a6b9908c7ef37d125e",
                        23_501, 808,
                        "18f7bc3969732d2b5c2d46f67e38da7187fa243ce8c69072fafcd2b227abb511",
                        "authorized_baseline")),
                path(10, "Sources/PrimeCore/PrimeSecureChildKernel.swift",
                    "modify", "fixture_compatibility_migration_to_internal_kernel",
                    source(
                        "Sources/PrimeCore/PrimeSecureChildKernel.swift",
                        "100644", "93f37a3bf3805dc92a4747b5fb98ce353a3ff7ab",
                        70_628, 1_997,
                        "a7cbd290903c9cee473ddf81c6a1d4ec47aa96848f305f1879d72dc48570f6a4",
                        "authorized_baseline")),
                path(11, "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceTests.swift",
                    "add", "exact12_deterministic_fault_matrix"),
                path(12, "Tests/PrimeCoreTests/PrimeNativeNeuralGateSecureChildLifecycleTests.swift",
                    "modify", "retain_fixture_lifecycle_compatibility",
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeNeuralGateSecureChildLifecycleTests.swift",
                        "100644", "d330be943a97a04e0a42b7259f5e2e69d0574977",
                        37_215, 1_285,
                        "189f3269aca064b29cec05c6cd45b6b3d5bf66006312703c617843f20a062a60",
                        "authorized_baseline")),
                path(13, "Tests/PrimeCoreTests/PrimeNativeNeuralGateSecureExternalChildCaptureTests.swift",
                    "modify", "retain_one_shot_capture_compatibility",
                    source(
                        "Tests/PrimeCoreTests/PrimeNativeNeuralGateSecureExternalChildCaptureTests.swift",
                        "100644", "60a26f4e2e2ee62897285e2498f7729e70f0d17b",
                        83_846, 2_662,
                        "b688b19a45c4166f71e382bde1181ef07447411e60574df2d9415bff6d3d51d1",
                        "authorized_baseline")),
            ],
            exactPathCount: 13,
            addedSourcePathCount: 4,
            modifiedSourcePathCount: 3,
            addedTestPathCount: 1,
            modifiedTestPathCount: 2,
            integrationPathCount: 3,
            onlyThesePathsAuthorized: true,
            implementationMayBeginAfterAuthorityClosure: true,
            implementationExecutionAuthorized: false,
            expectedRootTestCount: 77,
            expectedIsolatedTestCount: 6,
            expectedFocusedWholeTestCount: 83,
            expectedRetainedLiveTestCount: 46,
            expectedAggregateTestCount: 129,
            expectedEmbeddedProvenanceRecordCount: 505),
        apiSurface: .init(
            orderedAuthorizedInternalTypeNames: [
                "PrimeSecureChildProcessPlanV1",
                "PrimeSecureChildProcessEvidenceV1",
                "PrimeTrustedSecureChildProcessCapture",
                "PrimeSecureChildExecutionKernel",
                "PrimeSecureChildDiagnosticEnvelopeV1",
                "PrimeSecureChildDiagnosticProjection",
                "PrimeSecureChildLeaseRetention",
            ],
            newTypesInternalOnly: true,
            publicGenericExecutableAuthorityAdded: false,
            publicArbitraryArgumentAuthorityAdded: false,
            publicArbitraryEnvironmentAuthorityAdded: false,
            processPlanCodable: false,
            processEvidenceCodable: false,
            trustedCaptureCodable: false,
            trustedCaptureExactlyOneShot: true,
            closedFirstPartyAdaptersOnly: true,
            existingFixturePublicAPISpellingsMayChange: false,
            standardInputPolicy: "dev_null",
            customInheritedDescriptorsAuthorized: false,
            orderedUniqueEnvironmentRequired: true,
            exactExecutableDescriptorRequired: true,
            exactWorkingDirectoryDescriptorRequired: true,
            suspendedProofBeforeResumeRequired: true,
            absoluteMonotonicUptimeDeadlineRequired: true,
            continuousThroughSystemSleepClockEstablished: false,
            hostileCodeSandboxEstablished: false),
        evidenceContract: .init(
            typedUnavailableDistinctFromObservedFalse: true,
            exactPIDReapRequired: true,
            processGroupEmptyRequired: true,
            termThenKillTimelineRequired: true,
            signalSuppressionRecorded: true,
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
                "finalization_errno", "worker_finished",
                "descriptors_closed",
            ],
            capturedPrefixSHA256MayClaimFullStreamSHA256: false,
            failStopWithoutProjectionWhenContainmentUnproved: true,
            processGroupContainsHostileDaemonization: false,
            cleanupAfterKernelOrHostLossGuaranteed: false),
        drainTerminalAdjustment: .init(
            orderedAuthorizedFiles: [
                "Sources/PrimeCore/PrimeSecureChildDrains.swift",
                "Sources/PrimeCore/PrimeSecureChildSupervision.swift",
                "Sources/PrimeCore/PrimeSecureChildKernel.swift",
            ],
            workerFinishedPublishedOnlyAfterDescriptorsClose: true,
            terminalStatesDistinguishEOFReadWriteAndCleanupErrors: true,
            activeOrUnsettledDrainProjectsEvidence: false,
            terminalErrorMayProjectAfterProvedContainment: true,
            terminalErrorMayClaimReachedEOF: false,
            fixtureSuccessStillRequiresEOFAndZeroErrors: true,
            overflowContinuesDrainingToTerminalState: true,
            capturedPrefixDigestIsFullStreamDigest: false,
            duplicateRawProcessSyscallsAuthorized: false),
        diagnosticProjection: .init(
            proposedEnvelopeType: "PrimeSecureChildDiagnosticEnvelopeV1",
            proposedProjectionType: "PrimeSecureChildDiagnosticProjection",
            envelopeVisibility: "internal",
            encoding: "canonical_json_utf8_single_line",
            maximumCanonicalByteCount: 4_096,
            maximumLineCount: 1,
            orderedAllowlistedTopLevelKeys: [
                "schema", "role", "phase", "operational_code",
                "completion", "deadline", "containment", "streams",
                "diagnostic_channel", "scientific_outcome",
            ],
            rawPIDIncluded: false,
            rawAbsolutePathIncluded: false,
            rawEnvironmentIncluded: false,
            rawStandardErrorIncluded: false,
            privateScientificFrameIncluded: false,
            scientificOutcomeValue: "not_established",
            constructionAuthorized: true,
            neutralLayerEmissionAuthorized: false,
            hostedEmissionAuthorized: false,
            localPersistenceAuthorized: false,
            fsyncAuthorized: false,
            artifactUploadAuthorized: false,
            retentionAuthorized: false),
        leaseComposition: .init(
            seamVisibility: "internal_optional_opaque",
            optionalOpaqueRetentionSeamAuthorized: true,
            deterministicFakeLeaseTestAuthorized: true,
            externallyOwnedLeaseMayBeRetainedWhileOwnerLives: true,
            seamItselfAcquiresLease: false,
            concretePrimeMetalDeviceLeaseAdapterAuthorized: false,
            leaseFileMutationAuthorized: false,
            leaseReleaseOrReacquisitionAuthorized: false,
            descriptorTransferToWorkerAuthorized: false,
            workerOwnedAcquisitionAuthorized: false,
            ownerDeathContinuityEstablished: false,
            physicalMetalReservationEstablished: false,
            mlxDeviceIdentityOrIdlenessEstablished: false,
            crossHostOrCrossJobContinuityEstablished: false,
            leaseTelemetryIsDurableEvidence: false),
        deterministicTestMatrix: .init(
            testFile:
                "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceTests.swift",
            exactOrderedTests: [
                test(1, "testPlanAdmissionRejectsUnsafeAndUnboundedInputs",
                    "closed_plan_validation"),
                test(2, "testTrustedCaptureIsExactlyOneShotUnderSequentialAndConcurrentCalls",
                    "deterministic_one_shot_state_machine"),
                test(3, "testEvidenceKeepsUnavailableDistinctFromObservedFalse",
                    "typed_observation_truth_table"),
                test(4, "testCompletionEvidenceCoversExitNonzeroAndSignal",
                    "completion_value_construction"),
                test(5, "testDeadlineEvidencePreservesTERMThenKILLAndSuppression",
                    "deadline_timeline_value_construction"),
                test(6, "testReapAndGroupFailuresFailStopWithoutProjection",
                    "containment_failure_value_injection"),
                test(7, "testOverflowUsesCapturedPrefixDigestAndUnavailableFullDigest",
                    "stream_overflow_value_injection"),
                test(8, "testTerminalStreamErrorsRemainTypedWithoutClaimingEOF",
                    "terminal_stream_error_value_injection"),
                test(9, "testActiveDrainOrOpenDescriptorCannotProject",
                    "unsettled_drain_value_injection"),
                test(10, "testDiagnosticProjectionIsCanonicalBoundedAndAllowlisted",
                    "pure_canonical_projection"),
                test(11, "testLeaseSeamRetainsOnlyExternallyOwnedTelemetry",
                    "deterministic_fake_opaque_lease"),
                test(12, "testFixtureAdapterMapsAllNineModesWithoutPublicGenericAuthority",
                    "pure_fixture_mode_mapping"),
            ],
            exactTestCount: 12,
            allFaultsAreInjectedValues: true,
            liveFixtureExecutionAuthorized: false,
            wallClockRaceRequired: false,
            networkRequired: false),
        sourceTopology: .init(
            exactNewCoreFiles: [
                "Sources/PrimeCore/PrimeSecureChildProcessPlan.swift",
                "Sources/PrimeCore/PrimeSecureChildProcessEvidence.swift",
                "Sources/PrimeCore/PrimeTrustedSecureChildProcessCapture.swift",
                "Sources/PrimeCore/PrimeSecureChildExecutionKernel.swift",
            ],
            executionKernelMustReuseExistingPrimeSubstrate: true,
            duplicateSpawnWaitSignalImplementationAuthorized: false,
            rawProcessSyscallsAuthorizedInNewCoreFiles: false,
            rawProcessSyscallsMayIncreaseInModifiedSubstrate: false,
            foundationProcessAuthorized: false,
            shellExecutionAuthorized: false,
            pathSearchAuthorized: false,
            inheritedAmbientEnvironmentAuthorized: false,
            networkOrUploadAuthorized: false,
            freeFormHostedPrintingAuthorized: false,
            mlxMetalOrNative300ImportsAuthorized: false,
            arbitraryExecutableFixtureAdapterAuthorized: false),
        languageBoundary: .init(
            currentImplementationLanguage: "swift_existing_prime_darwin_substrate",
            pythonPermitted: false,
            pythonInvocationCount: 0,
            pythonSourcePathCount: 0,
            cppNewImplementationInvocationCount: 0,
            cppNewSourcePathCount: 0,
            retainedBaselineCppDependencyCompilationObserved: true,
            cppFullNativeAlternativeSeparatelyPermissibleLater: true,
            cppSwiftCABIAlternativeSeparatelyPermissibleLater: true,
            cppAlternativeAuthorizedNow: false,
            cppAlternativeRequiresSeparateAuthority: true),
        successorCanary: .init(
            authorityRequiredAfterImplementationGreen: true,
            integrationSource: source(
                "Tests/PrimeValidationWorkflow/Sources/PrimeValidationWorkflowSecureChildIntegration/PrimeValidationWorkflowSecureChildIntegration.swift",
                "100644", "cce94e857f770f8108d7a694675ca75386a40ddb",
                17_656, 537,
                "9404187780e89137686d036c6909c675608c8ebd3ca8077cafd5bb002debf5c2",
                "separately_authorized_closed_compatibility_canary_only"),
            orderedFixtureModes: [
                "pass", "logical-argument-zero", "nonzero-exit",
                "bounded-streams", "overflow", "hang", "self-signal",
                "descendant-retains-streams", "exit-without-result",
            ],
            expectedAdapterInvocationCount: 1,
            expectedActualChildCaptureCount: 10,
            oneShotRaceIncluded: true,
            executableReplacementIncluded: true,
            leaseAcquisitionIncluded: false,
            mlxMetalOrNative300Included: false,
            hostedDiagnosticEmissionIncluded: false,
            authorizedNow: false,
            disposition: "observe_once_then_retire"),
        authorityCeiling: .init(
            designAuthorityEstablished: true,
            implementationAuthorityEstablished: true,
            deterministicExact13SourcePatchAuthorized: true,
            processExecutionAuthorized: false,
            liveFixtureExecutionAuthorized: false,
            hostedDiagnosticProjectionAuthorized: false,
            hostedDiagnosticEmissionAuthorized: false,
            customDescriptorTransportAuthorized: false,
            durableEvidenceEstablished: false,
            durableTransactionImplementationAuthorized: false,
            leaseAcquisitionAuthorized: false,
            leaseReleaseObservationAuthorized: false,
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
        orderedSuccessorBoundaries: [
            "close_this_pure_implementation_authority",
            "implement_only_the_exact13_deterministic_layer_a_patch",
            "close_the_implementation_on_exact_main_without_live_fixture_execution",
            "separately_authorize_one_closed_fixture_compatibility_canary",
            "observe_once_and_retire_the_fixture_canary",
            "separately_authorize_neutral_resource_lease_generalization",
            "separately_authorize_durable_transaction_layer_b",
            "only_then_review_any_new_mlx_metal_or_native300_adapter",
        ],
        status:
            "AUTHORITY_ONLY_deterministic_layer_a_implementation_exact13_no_live_execution_no_hosted_emission_no_lease_acquisition_no_python_cpp_deferred")

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeSecureChildProcessEvidenceImplementationAuthorityError
                .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        try validateExactV1()
    }

    public func validateExactV1() throws {
        let predecessor =
            PrimeSecureChildProcessEvidenceDesignAuthorityV1.frozenV1
        do {
            try predecessor.validateExactV1()
        } catch {
            throw PrimeSecureChildProcessEvidenceImplementationAuthorityError
                .contractDrift
        }

        let closure = exactMainClosure
        let scope = implementationScope
        let api = apiSurface
        let evidence = evidenceContract
        let drains = drainTerminalAdjustment
        let diagnostic = diagnosticProjection
        let lease = leaseComposition
        let tests = deterministicTestMatrix
        let topology = sourceTopology
        let language = languageBoundary
        let canary = successorCanary
        let ceiling = authorityCeiling
        let canonical = try canonicalData()
        let falseClaims = [
            ceiling.processExecutionAuthorized,
            ceiling.liveFixtureExecutionAuthorized,
            ceiling.hostedDiagnosticProjectionAuthorized,
            ceiling.hostedDiagnosticEmissionAuthorized,
            ceiling.customDescriptorTransportAuthorized,
            ceiling.durableEvidenceEstablished,
            ceiling.durableTransactionImplementationAuthorized,
            ceiling.leaseAcquisitionAuthorized,
            ceiling.leaseReleaseObservationAuthorized,
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
              designPredecessor.authorityID == predecessor.authorityID,
              designPredecessor.canonicalByteCount
                == PrimeSecureChildProcessEvidenceDesignAuthorityV1
                    .canonicalByteCount,
              designPredecessor.canonicalSHA256
                == PrimeSecureChildProcessEvidenceDesignAuthorityV1
                    .canonicalSHA256,
              designPredecessor.designAuthorityEstablished,
              !designPredecessor.implementationAuthorizedByPredecessor,
              closure.orderedParents.count == 2,
              closure.workflowRunNumber == 133,
              closure.workflowAttempt == 1,
              closure.event == "push",
              closure.previousAttemptURLIsNull,
              closure.workflowRerunCount == 0,
              closure.workflowConclusion == "success",
              closure.activeLatinTestCount == 116,
              closure.activeLatinFailureCount == 0,
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
              closure.designAuthorityMethodStartCount == 1,
              closure.designAuthorityMethodPassCount == 1,
              closure.actionsArtifactCount == 0,
              closure.stage7JobCount == 0,
              closure.stage7LauncherInvocationCount == 0,
              closure.stage7ProductInvocationCount == 0,
              closure.stage7SupervisorInvocationCount == 0,
              closure.stage7ReceiptCount == 0,
              closure.secureChildFixtureInvocationCount == 0,
              closure.secureChildCaptureInvocationCount == 0,
              closure.leaseAcquisitionInvocationCount == 0,
              closure.pythonInterpreterInvocationCount == 0,
              closure.newCppImplementationInvocationCount == 0,
              authorityScaffold.exactOrderedChangedPaths.count == 5,
              Set(authorityScaffold.exactOrderedChangedPaths).count == 5,
              authorityScaffold.rootTestCount == 65,
              authorityScaffold.focusedWholeTestCount == 71,
              authorityScaffold.aggregateTestCount == 117,
              authorityScaffold.embeddedProvenanceRecordCount == 500,
              scope.exactPathCount == 13,
              scope.exactOrderedPaths.count == 13,
              Set(scope.exactOrderedPaths.map(\.path)).count == 13,
              scope.exactOrderedPaths.map(\.ordinal) == Array(1 ... 13),
              scope.onlyThesePathsAuthorized,
              scope.implementationMayBeginAfterAuthorityClosure,
              !scope.implementationExecutionAuthorized,
              scope.expectedFocusedWholeTestCount
                == scope.expectedRootTestCount + scope.expectedIsolatedTestCount,
              scope.expectedAggregateTestCount
                == scope.expectedFocusedWholeTestCount
                    + scope.expectedRetainedLiveTestCount,
              api.newTypesInternalOnly,
              !api.publicGenericExecutableAuthorityAdded,
              !api.publicArbitraryArgumentAuthorityAdded,
              !api.publicArbitraryEnvironmentAuthorityAdded,
              !api.processPlanCodable,
              !api.processEvidenceCodable,
              !api.trustedCaptureCodable,
              api.trustedCaptureExactlyOneShot,
              api.closedFirstPartyAdaptersOnly,
              !api.existingFixturePublicAPISpellingsMayChange,
              !api.customInheritedDescriptorsAuthorized,
              api.suspendedProofBeforeResumeRequired,
              api.absoluteMonotonicUptimeDeadlineRequired,
              !api.continuousThroughSystemSleepClockEstablished,
              !api.hostileCodeSandboxEstablished,
              evidence.typedUnavailableDistinctFromObservedFalse,
              evidence.exactPIDReapRequired,
              evidence.processGroupEmptyRequired,
              evidence.failStopWithoutProjectionWhenContainmentUnproved,
              !evidence.capturedPrefixSHA256MayClaimFullStreamSHA256,
              !evidence.processGroupContainsHostileDaemonization,
              !evidence.cleanupAfterKernelOrHostLossGuaranteed,
              drains.workerFinishedPublishedOnlyAfterDescriptorsClose,
              drains.terminalStatesDistinguishEOFReadWriteAndCleanupErrors,
              !drains.activeOrUnsettledDrainProjectsEvidence,
              drains.terminalErrorMayProjectAfterProvedContainment,
              !drains.terminalErrorMayClaimReachedEOF,
              drains.fixtureSuccessStillRequiresEOFAndZeroErrors,
              drains.overflowContinuesDrainingToTerminalState,
              !drains.capturedPrefixDigestIsFullStreamDigest,
              !drains.duplicateRawProcessSyscallsAuthorized,
              diagnostic.maximumCanonicalByteCount == 4_096,
              diagnostic.maximumLineCount == 1,
              diagnostic.constructionAuthorized,
              !diagnostic.neutralLayerEmissionAuthorized,
              !diagnostic.hostedEmissionAuthorized,
              !diagnostic.localPersistenceAuthorized,
              !diagnostic.fsyncAuthorized,
              !diagnostic.artifactUploadAuthorized,
              !diagnostic.retentionAuthorized,
              lease.optionalOpaqueRetentionSeamAuthorized,
              lease.deterministicFakeLeaseTestAuthorized,
              lease.externallyOwnedLeaseMayBeRetainedWhileOwnerLives,
              !lease.seamItselfAcquiresLease,
              !lease.concretePrimeMetalDeviceLeaseAdapterAuthorized,
              !lease.leaseFileMutationAuthorized,
              !lease.leaseReleaseOrReacquisitionAuthorized,
              !lease.descriptorTransferToWorkerAuthorized,
              !lease.workerOwnedAcquisitionAuthorized,
              !lease.ownerDeathContinuityEstablished,
              !lease.physicalMetalReservationEstablished,
              !lease.mlxDeviceIdentityOrIdlenessEstablished,
              !lease.crossHostOrCrossJobContinuityEstablished,
              !lease.leaseTelemetryIsDurableEvidence,
              tests.exactTestCount == 12,
              tests.exactOrderedTests.count == 12,
              tests.exactOrderedTests.map(\.ordinal) == Array(1 ... 12),
              tests.exactOrderedTests.allSatisfy({
                  !$0.invokesLiveProcess && !$0.invokesLiveLease
              }),
              tests.allFaultsAreInjectedValues,
              !tests.liveFixtureExecutionAuthorized,
              !tests.wallClockRaceRequired,
              !tests.networkRequired,
              topology.exactNewCoreFiles.count == 4,
              topology.executionKernelMustReuseExistingPrimeSubstrate,
              !topology.duplicateSpawnWaitSignalImplementationAuthorized,
              !topology.rawProcessSyscallsAuthorizedInNewCoreFiles,
              !topology.rawProcessSyscallsMayIncreaseInModifiedSubstrate,
              !topology.foundationProcessAuthorized,
              !topology.shellExecutionAuthorized,
              !topology.pathSearchAuthorized,
              !topology.inheritedAmbientEnvironmentAuthorized,
              !topology.networkOrUploadAuthorized,
              !topology.freeFormHostedPrintingAuthorized,
              !topology.mlxMetalOrNative300ImportsAuthorized,
              !topology.arbitraryExecutableFixtureAdapterAuthorized,
              !language.pythonPermitted,
              language.pythonInvocationCount == 0,
              language.pythonSourcePathCount == 0,
              language.cppNewImplementationInvocationCount == 0,
              language.cppNewSourcePathCount == 0,
              language.retainedBaselineCppDependencyCompilationObserved,
              language.cppFullNativeAlternativeSeparatelyPermissibleLater,
              language.cppSwiftCABIAlternativeSeparatelyPermissibleLater,
              !language.cppAlternativeAuthorizedNow,
              language.cppAlternativeRequiresSeparateAuthority,
              canary.authorityRequiredAfterImplementationGreen,
              Self.validSource(canary.integrationSource),
              canary.orderedFixtureModes.count == 9,
              canary.expectedAdapterInvocationCount == 1,
              canary.expectedActualChildCaptureCount == 10,
              !canary.leaseAcquisitionIncluded,
              !canary.mlxMetalOrNative300Included,
              !canary.hostedDiagnosticEmissionIncluded,
              !canary.authorizedNow,
              ceiling.designAuthorityEstablished,
              ceiling.implementationAuthorityEstablished,
              ceiling.deterministicExact13SourcePatchAuthorized,
              falseClaims.allSatisfy({ !$0 }),
              orderedSuccessorBoundaries.count == 8,
              canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256 else {
            throw PrimeSecureChildProcessEvidenceImplementationAuthorityError
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

    private static func path(
        _ ordinal: Int,
        _ path: String,
        _ change: String,
        _ role: String,
        _ baselineIdentity: SourceIdentity? = nil
    ) -> ImplementationPath {
        ImplementationPath(
            ordinal: ordinal,
            path: path,
            change: change,
            role: role,
            baselineIdentity: baselineIdentity)
    }

    private static func test(
        _ ordinal: Int,
        _ method: String,
        _ requiredBehavior: String
    ) -> DeterministicTest {
        DeterministicTest(
            ordinal: ordinal,
            method: method,
            requiredBehavior: requiredBehavior,
            invokesLiveProcess: false,
            invokesLiveLease: false)
    }

    private static func validSource(_ source: SourceIdentity) -> Bool {
        source.path.count > 3
            && !source.path.hasPrefix("/")
            && ["100644", "100755"].contains(source.gitMode)
            && source.gitBlob.count == 40
            && source.byteCount > 0
            && source.lfByteCount > 0
            && source.sha256.count == 64
            && !source.role.isEmpty
    }
}
