// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeMonitorHeldLeaseSecureChildContainmentAuthorityError:
    Error,
    Equatable
{
    case contractDrift
    case noncanonicalEncoding
    case oversizedEncoding
}

/// Pure authority for a later closed composition. This value performs no lease,
/// filesystem, descriptor, process, fixture, launcher, model, or adapter work.
public struct PrimeMonitorHeldLeaseSecureChildContainmentAuthorityV1:
    Codable,
    Equatable,
    Sendable
{
    public struct FileIdentity: Codable, Equatable, Sendable {
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let gitBlob: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let sha256: String
        public let role: String
    }

    public struct RepositoryClosure: Codable, Equatable, Sendable {
        public let repository: String
        public let pullRequestNumber: Int
        public let baseRevision: String
        public let baseTree: String
        public let reviewedHeadRevision: String
        public let reviewedHeadTree: String
        public let reviewedHeadSoleParentRevision: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedMergeParentRevisions: [String]
        public let mergeTreeEqualsReviewedHeadTree: Bool
        public let reviewedHeadIsSoleChildOfBase: Bool
        public let historyPreservingTwoParentMergeObserved: Bool
        public let githubSignatureVerified: Bool
        public let githubSignatureReason: String
        public let githubSignatureVerifiedAt: String
    }

    public struct WorkflowClosure: Codable, Equatable, Sendable {
        public let workflowName: String
        public let runID: Int
        public let runNumber: Int
        public let runAttempt: Int
        public let checkSuiteID: Int
        public let event: String
        public let ref: String
        public let headSHA: String
        public let status: String
        public let conclusion: String
        public let previousAttemptURL: String?
        public let matchingRunCountForHead: Int
        public let retryCount: Int
        public let rerunCount: Int
        public let actionsArtifactCount: Int
        public let activeRootJobID: Int
        public let activeRootJobConclusion: String
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let reviewedMainJobStepCount: Int
        public let activeRootLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedMetalTestCount: Int
        public let retainedMaintainedRuntimeTestCount: Int
        public let retainedTokenizerTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let failureCount: Int
        public let skipCount: Int
        public let soleA1TestStartCount: Int
        public let soleA1TestPassCount: Int
    }

    public struct ConnectorDecodedUTF8JobLogIdentity:
        Codable,
        Equatable,
        Sendable
    {
        public let jobID: Int
        public let bindingKind: String
        public let representation: String
        public let byteCount: Int
        public let lfByteCount: Int
        public let crByteCount: Int
        public let sha256: String
        public let utf8BOMPresent: Bool
        public let terminalLFPresent: Bool
        public let repeatFetchExactlyEqual: Bool
        public let rawArchiveBytesBound: Bool
        public let rawArchiveRetained: Bool
    }

    public struct A1Contract: Codable, Equatable, Sendable {
        public let neutralLeaseType: String
        public let neutralErrorType: String
        public let exactNeutralLeaseAliasDeclaration: String
        public let exactNeutralErrorAliasDeclaration: String
        public let markerProtocol: String
        public let exactMarkerProtocolDeclaration: String
        public let exactConcreteConformanceDeclaration: String
        public let typedRetentionType: String
        public let exactTypedRetentionStoredType: String
        public let exactTypedRetentionStoredDeclaration: String
        public let exactTypedRetentionInitializerDeclaration: String
        public let exactTypedRetentionIdentityMethodDeclaration: String
        public let aliasExposesPublicRelease: Bool
        public let retainingExternallySuppliedAliasProvesObjectLifetimeOnly: Bool
        public let retainingExternallySuppliedAliasProvesKernelLockContinuity: Bool
        public let callerMayReleaseExternallySuppliedAlias: Bool
        public let mechanicsAddedByA1: Bool
        public let leaseAcquireInvocationCountInA1Patch: Int
        public let leaseReleaseInvocationCountInA1Patch: Int
        public let processInvocationCountInA1Patch: Int
    }

    public struct PathContract: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let role: String
    }

    public struct FutureCompositionContract: Codable, Equatable, Sendable {
        public let implementationType: String
        public let implementationSourcePath: String
        public let implementationTestPath: String
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let dependencyFree: Bool
        public let publicCapabilityScope: String
        public let exactAcceptedClosedAPIInputs: [String]
        public let acceptedLeaseDirectoryParameter: String
        public let fixedPrivateLeaseLeaf: String
        public let executableURLIsLocatorForFixedAuthenticatedFixtureOnly: Bool
        public let callerSuppliedFullLeaseFileURLAccepted: Bool
        public let callerSuppliedResourceIdentifierAccepted: Bool
        public let callerSuppliedLeaseObjectAccepted: Bool
        public let genericChildAccepted: Bool
        public let leaseObjectReturned: Bool
        public let releaseHandleReturned: Bool
        public let exactLeaseType: String
        public let productionAcquireCall: String
        public let productionAcquireCount: Int
        public let acquisitionMustPrecedePlanConstruction: Bool
        public let acquisitionMustPrecedePreparedFixtureConstruction: Bool
        public let rawLeaseReferenceMustRemainPrivateAndNonescaping: Bool
        public let explicitReleaseCallCount: Int
        public let leaseReacquisitionCount: Int
        public let descriptorTransferCount: Int
        public let workerInheritedLeaseDescriptorCount: Int
        public let workerLeaseAcquisitionCount: Int
        public let workerLeaseReleaseCount: Int
        public let monitorOwnsLeasePolicy: String
        public let existingSupervisorOwnsChildLifecycleOnly: Bool
        public let monitorOwnsChildLifecycle: Bool
        public let existingSupervisorOwnsLease: Bool
        public let orderedOwnershipChain: [String]
        public let ownershipChainMustRemainInBand: Bool
        public let existingClosedPlanFactory: String
        public let existingPreparedFixtureType: String
        public let existingCaptureType: String
        public let existingExecutionKernelType: String
        public let arbitraryExecutableAccepted: Bool
        public let arbitraryArgumentsAccepted: Bool
        public let arbitraryEnvironmentAccepted: Bool
        public let ordinaryLeaseDestructionOnlyAfterTerminalContainedReturnOrUnwind:
            Bool
        public let preSpawnFailureMayReleaseBecauseNoChildExists: Bool
        public let failStopPreservesNonreturningContainmentFailure: Bool
        public let layerABytesMustRemainByteIdentical: Bool
        public let layerATelemetryScope: String
        public let layerATelemetryAdvisory: Bool
        public let layerATelemetryOwnerMustRemainLive: Bool
        public let layerATelemetryRetentionIsInBandWithinCapture: Bool
        public let layerATelemetryLabelExternallyOwnedAdvisoryIsNotOwnershipProof:
            Bool
        public let layerATelemetryProvesExclusiveOwnership: Bool
        public let childLifetimeContinuityEstablished: Bool
        public let mlxDeviceIdentityEstablished: Bool
        public let physicalMetalReservationEstablished: Bool
        public let durableEvidenceEstablished: Bool
        public let pureInMemoryFakeTestOnly: Bool
        public let pureFakeMayProveOnly: [String]
        public let actualKernelLockContinuityCanaryIncluded: Bool
        public let actualKernelLockContinuityCanaryRequiresSeparateAuthority: Bool
    }

    public struct AuthorityScope: Codable, Equatable, Sendable {
        public let exactOrderedPaths: [PathContract]
        public let exactPathCount: Int
        public let activeRootLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let embeddedProvenanceRecordCount: Int
        public let soleAuthorityTestClassName: String
        public let soleAuthorityTestMethodName: String
        public let soleAuthorityTestExpectedStartCount: Int
        public let soleAuthorityTestExpectedPassCount: Int
        public let addedProofOnlyHistoricalWant: String
        public let addedProofOnlyWantCountPerExistingFetch: Int
        public let exactPrimeFetchInvocationCountPerCheckoutRemainsOne: Bool
        public let fetchDepthRemainsTwo: Bool
        public let workflowJobAndStepTopologyMustRemainUnchanged: Bool
        public let retainedLiveCommandsMustRemainByteIdentical: Bool
        public let packageManifestMustRemainByteIdentical: Bool
        public let packageLockMustRemainByteIdentical: Bool
        public let readmeMustRemainByteIdentical: Bool
        public let legacyLeasePairMustRemainByteIdentical: Bool
        public let a1PairMustRemainByteIdentical: Bool
        public let layerABytesMustRemainByteIdentical: Bool
        public let bMLXModelCheckpointBytesMustRemainByteIdentical: Bool
        public let canaryLauncherMustRemainByteIdentical: Bool
        public let implementationIncludedInThisPatch: Bool
        public let implementationAuthorizedOnlyAfterAuthorityExactMainGreen:
            Bool
        public let authorityExactMainGreenObservedAtAuthoring: Bool
    }

    public struct OptionalFixturePINBoundary: Codable, Equatable, Sendable {
        public let requestedByThisAuthority: Bool
        public let deferred: Bool
        public let authorizedByThisAuthority: Bool
        public let requiredForA2: Bool
        public let distinctAuthorityRequired: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let implementationPerformed: Bool
        public let implementationSourceAdded: Bool
        public let implementationTestAdded: Bool
        public let leaseAcquisitionAuthorized: Bool
        public let leaseAcquisitionPerformed: Bool
        public let leaseReleaseAuthorized: Bool
        public let leaseReleasePerformed: Bool
        public let leaseReacquisitionAuthorized: Bool
        public let leaseFileCreationAuthorized: Bool
        public let leaseFileMutationAuthorized: Bool
        public let descriptorInspectionAuthorized: Bool
        public let descriptorTransferAuthorized: Bool
        public let filesystemWriteAuthorized: Bool
        public let processExecutionAuthorized: Bool
        public let fixtureExecutionAuthorized: Bool
        public let launcherExecutionAuthorized: Bool
        public let canaryExecutionAuthorized: Bool
        public let canaryRetryAuthorized: Bool
        public let canaryRerunAuthorized: Bool
        public let networkAuthorized: Bool
        public let layerAMutationAuthorized: Bool
        public let durableTransactionLayerBAuthorized: Bool
        public let durableEvidenceEstablished: Bool
        public let childLifetimeContinuityEstablished: Bool
        public let physicalMetalReservationEstablished: Bool
        public let mlxDeviceIdentityEstablished: Bool
        public let mlxExecutionAuthorized: Bool
        public let metalExecutionAuthorized: Bool
        public let native300MExecutionAuthorized: Bool
        public let pythonAuthorized: Bool
        public let cppAuthorized: Bool
        public let checkpointAdmissionGranted: Bool
        public let generalTrainingResumeAuthorized: Bool
        public let modelQualityEstablished: Bool
        public let productUseAuthorized: Bool
        public let publicationAuthorized: Bool
    }

    public let schemaVersion: Int
    public let schemaID: String
    public let authorityID: String
    public let authorityKind: String
    public let status: String
    public let predecessorFiles: [FileIdentity]
    public let predecessorRepositoryClosure: RepositoryClosure
    public let predecessorPullRequestRun: WorkflowClosure
    public let predecessorPushMainRun: WorkflowClosure
    public let predecessorPullRequestActiveRootLog:
        ConnectorDecodedUTF8JobLogIdentity
    public let predecessorPushMainActiveRootLog:
        ConnectorDecodedUTF8JobLogIdentity
    public let predecessorPushMainReviewedMainLog:
        ConnectorDecodedUTF8JobLogIdentity
    public let a1Contract: A1Contract
    public let futureCompositionContract: FutureCompositionContract
    public let authorityScope: AuthorityScope
    public let authorityCeiling: AuthorityCeiling
    public let optionalFixturePINBoundary: OptionalFixturePINBoundary
    public let orderedRequiredSeparateActions: [String]

    public static let canonicalByteCount = 15_958
    public static let canonicalSHA256 =
        "fb5dcc4a24c34fefe7955a76d72a3e9fd1a3c5b81e4aeba935084fbe77568d0a"

    public static let frozenV1 = Self(
        schemaVersion: 1,
        schemaID:
            "prime_monitor_held_lease_secure_child_containment_authority_v1",
        authorityID:
            "ergentics_prime_monitor_held_lease_secure_child_containment_authority_v1",
        authorityKind:
            "pure_authority_for_later_closed_monitor_held_lease_secure_child_containment_composition",
        status:
            "AUTHORITY_ONLY_future_additive_exact5_nested_capture_composition_no_mechanics_continuity_mlx_durable_false",
        predecessorFiles: [
            .init(
                path: ".github/scripts/prime-ci-active-root-quarantine.sh",
                gitStatus: "M",
                gitMode: "100755",
                gitBlob: "879f938fbe9f93d891db8d5dc4ef997ac91cc6a5",
                byteCount: 1_278_954,
                lfByteCount: 21_065,
                sha256:
                    "d72302871539522c17ecacec0237a057e72e90046ef6bfb6481544450a4a65e3",
                role: "a1_active_root_gate"
            ),
            .init(
                path: ".github/workflows/prime-active-root-quarantine.yml",
                gitStatus: "M",
                gitMode: "100644",
                gitBlob: "533217661d78441be6e76d702836d3a060bb7e63",
                byteCount: 153_404,
                lfByteCount: 710,
                sha256:
                    "8b3addced346429f5f7d35dc3943761b3cd9d030b7afc1501f20fdb6f97094f3",
                role: "a1_hosted_workflow"
            ),
            .init(
                path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                gitStatus: "M",
                gitMode: "100644",
                gitBlob: "9f101b32c2c5bc2df889b97f5d8545a5b62a29f5",
                byteCount: 546,
                lfByteCount: 13,
                sha256:
                    "c07a9647804b30abdaeb771df72b3c72995498acd4e1f916929b1ae7912e552f",
                role: "a1_embedded_provenance_515_records"
            ),
            .init(
                path: "Sources/PrimeCore/PrimeExclusiveResourceLease.swift",
                gitStatus: "A",
                gitMode: "100644",
                gitBlob: "d5e98f2264102ee81840121399c7438082f6a077",
                byteCount: 791,
                lfByteCount: 24,
                sha256:
                    "2d57ca21d1fdc17bd235a5be19a548c476d1a7c42e68040474ac03bb7fef8885",
                role: "a1_neutral_alias_and_typed_retention_source"
            ),
            .init(
                path: "Tests/PrimeCoreTests/PrimeExclusiveResourceLeaseTests.swift",
                gitStatus: "A",
                gitMode: "100644",
                gitBlob: "2dcf7af7b9a5689bfbe932bc0140c33dd1ee05e2",
                byteCount: 1_298,
                lfByteCount: 37,
                sha256:
                    "b87c694a1481a81815fc4df4abf42ef3a021b5b84c90295e59c1c0b54cb32424",
                role: "a1_sole_pure_fake_test"
            ),
        ],
        predecessorRepositoryClosure: .init(
            repository: "Ergentics/ergentics-prime",
            pullRequestNumber: 126,
            baseRevision: "e1d90e3f2ae6c4d3c279bf5fb64ce3baafc1f540",
            baseTree: "569963ff059acf9c444c964eb224b2c8d96d3c93",
            reviewedHeadRevision:
                "c2a42ca4a3bd1c31f06560dd1bff970039dcc7f0",
            reviewedHeadTree:
                "127dc50e07e192e5868ef734cd27f74d59c63de6",
            reviewedHeadSoleParentRevision:
                "e1d90e3f2ae6c4d3c279bf5fb64ce3baafc1f540",
            mergeRevision: "ef64686e76d2d67e46deb696bfeef18ea96c96a2",
            mergeTree: "127dc50e07e192e5868ef734cd27f74d59c63de6",
            orderedMergeParentRevisions: [
                "e1d90e3f2ae6c4d3c279bf5fb64ce3baafc1f540",
                "c2a42ca4a3bd1c31f06560dd1bff970039dcc7f0",
            ],
            mergeTreeEqualsReviewedHeadTree: true,
            reviewedHeadIsSoleChildOfBase: true,
            historyPreservingTwoParentMergeObserved: true,
            githubSignatureVerified: true,
            githubSignatureReason: "valid",
            githubSignatureVerifiedAt: "2026-08-20T04:42:17Z"
        ),
        predecessorPullRequestRun: .init(
            workflowName: "Prime active-root quarantine",
            runID: 32_332_270_879,
            runNumber: 151,
            runAttempt: 1,
            checkSuiteID: 87_648_317_872,
            event: "pull_request",
            ref: "refs/pull/126/merge",
            headSHA: "c2a42ca4a3bd1c31f06560dd1bff970039dcc7f0",
            status: "completed",
            conclusion: "success",
            previousAttemptURL: nil,
            matchingRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0,
            actionsArtifactCount: 0,
            activeRootJobID: 96_315_061_445,
            activeRootJobConclusion: "success",
            reviewedMainJobID: 96_315_665_367,
            reviewedMainJobConclusion: "skipped",
            reviewedMainJobStepCount: 0,
            activeRootLatinTestCount: 116,
            rootTestCount: 0,
            isolatedGroupTestCounts: [],
            isolatedTestCount: 0,
            focusedWholeTestCount: 0,
            retainedMetalTestCount: 0,
            retainedMaintainedRuntimeTestCount: 0,
            retainedTokenizerTestCount: 0,
            retainedLiveTestCount: 0,
            aggregateTestCount: 0,
            failureCount: 0,
            skipCount: 0,
            soleA1TestStartCount: 0,
            soleA1TestPassCount: 0
        ),
        predecessorPushMainRun: .init(
            workflowName: "Prime active-root quarantine",
            runID: 32_332_846_929,
            runNumber: 152,
            runAttempt: 1,
            checkSuiteID: 87_649_771_967,
            event: "push",
            ref: "refs/heads/main",
            headSHA: "ef64686e76d2d67e46deb696bfeef18ea96c96a2",
            status: "completed",
            conclusion: "success",
            previousAttemptURL: nil,
            matchingRunCountForHead: 1,
            retryCount: 0,
            rerunCount: 0,
            actionsArtifactCount: 0,
            activeRootJobID: 96_316_657_574,
            activeRootJobConclusion: "success",
            reviewedMainJobID: 96_317_291_067,
            reviewedMainJobConclusion: "success",
            reviewedMainJobStepCount: 7,
            activeRootLatinTestCount: 116,
            rootTestCount: 82,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 88,
            retainedMetalTestCount: 44,
            retainedMaintainedRuntimeTestCount: 1,
            retainedTokenizerTestCount: 1,
            retainedLiveTestCount: 46,
            aggregateTestCount: 134,
            failureCount: 0,
            skipCount: 0,
            soleA1TestStartCount: 1,
            soleA1TestPassCount: 1
        ),
        predecessorPullRequestActiveRootLog: .init(
            jobID: 96_315_061_445,
            bindingKind:
                "github_connector_decoded_utf8_job_log_aggregate_identity",
            representation:
                "github_connector_decoded_utf8_job_log_aggregate_not_raw_zip",
            byteCount: 334_036,
            lfByteCount: 1_894,
            crByteCount: 0,
            sha256:
                "f6287c8ab27e18c784736009936b43e9436c8b9c47e1693430e16066d52bb3ae",
            utf8BOMPresent: true,
            terminalLFPresent: true,
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false
        ),
        predecessorPushMainActiveRootLog: .init(
            jobID: 96_316_657_574,
            bindingKind:
                "github_connector_decoded_utf8_job_log_aggregate_identity",
            representation:
                "github_connector_decoded_utf8_job_log_aggregate_not_raw_zip",
            byteCount: 334_048,
            lfByteCount: 1_894,
            crByteCount: 0,
            sha256:
                "5e4cf4e2f5760bc39f79109dcc1a5f34a6ebf836810cd3164c15891b26b530da",
            utf8BOMPresent: true,
            terminalLFPresent: true,
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false
        ),
        predecessorPushMainReviewedMainLog: .init(
            jobID: 96_317_291_067,
            bindingKind:
                "github_connector_decoded_utf8_job_log_aggregate_identity",
            representation:
                "github_connector_decoded_utf8_job_log_aggregate_not_raw_zip",
            byteCount: 10_331_433,
            lfByteCount: 79_005,
            crByteCount: 0,
            sha256:
                "64222d296afef53df0dc9e2b827a0762932af62e798a8fcb5b8dcc34c34f57b2",
            utf8BOMPresent: true,
            terminalLFPresent: true,
            repeatFetchExactlyEqual: true,
            rawArchiveBytesBound: false,
            rawArchiveRetained: false
        ),
        a1Contract: .init(
            neutralLeaseType: "PrimeExclusiveResourceLease",
            neutralErrorType: "PrimeExclusiveResourceLeaseError",
            exactNeutralLeaseAliasDeclaration:
                "public typealias PrimeExclusiveResourceLease = PrimeMetalDeviceLease",
            exactNeutralErrorAliasDeclaration:
                "public typealias PrimeExclusiveResourceLeaseError = PrimeMetalDeviceLeaseError",
            markerProtocol: "PrimeExclusiveResourceLeaseCapability",
            exactMarkerProtocolDeclaration:
                "protocol PrimeExclusiveResourceLeaseCapability: AnyObject, Sendable {}",
            exactConcreteConformanceDeclaration:
                "extension PrimeMetalDeviceLease: PrimeExclusiveResourceLeaseCapability {}",
            typedRetentionType: "PrimeExclusiveResourceLeaseRetention",
            exactTypedRetentionStoredType:
                "any PrimeExclusiveResourceLeaseCapability",
            exactTypedRetentionStoredDeclaration:
                "private let lease: any PrimeExclusiveResourceLeaseCapability",
            exactTypedRetentionInitializerDeclaration:
                "init(_ lease: any PrimeExclusiveResourceLeaseCapability)",
            exactTypedRetentionIdentityMethodDeclaration:
                "func retains(_ candidate: any PrimeExclusiveResourceLeaseCapability) -> Bool",
            aliasExposesPublicRelease: true,
            retainingExternallySuppliedAliasProvesObjectLifetimeOnly: true,
            retainingExternallySuppliedAliasProvesKernelLockContinuity: false,
            callerMayReleaseExternallySuppliedAlias: true,
            mechanicsAddedByA1: false,
            leaseAcquireInvocationCountInA1Patch: 0,
            leaseReleaseInvocationCountInA1Patch: 0,
            processInvocationCountInA1Patch: 0
        ),
        futureCompositionContract: .init(
            implementationType:
                "PrimeMonitorHeldLeaseSecureChildContainment",
            implementationSourcePath:
                "Sources/PrimeCore/PrimeMonitorHeldLeaseSecureChildContainment.swift",
            implementationTestPath:
                "Tests/PrimeCoreTests/PrimeMonitorHeldLeaseSecureChildContainmentTests.swift",
            exactOrderedPaths: [
                .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitStatus: "M", gitMode: "100755", role: "bind_authority_closure_and_additive_composition_ceiling"),
                .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitStatus: "M", gitMode: "100644", role: "integrate_sole_pure_fake_composition_test"),
                .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitStatus: "M", gitMode: "100644", role: "bind_successor_embedded_source_identity"),
                .init(ordinal: 4, path: "Sources/PrimeCore/PrimeMonitorHeldLeaseSecureChildContainment.swift", gitStatus: "A", gitMode: "100644", role: "closed_additive_nested_capture_composition"),
                .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeMonitorHeldLeaseSecureChildContainmentTests.swift", gitStatus: "A", gitMode: "100644", role: "sole_pure_in_memory_fake_composition_test"),
            ],
            exactPathCount: 5,
            dependencyFree: true,
            publicCapabilityScope:
                "closed_validation_workflow_fixture_child_only",
            exactAcceptedClosedAPIInputs: [
                "trustedLeaseDirectoryURL",
                "executableURL",
                "privateWorkingDirectoryURL",
                "privateResultDirectoryURL",
                "mode",
            ],
            acceptedLeaseDirectoryParameter: "trustedLeaseDirectoryURL",
            fixedPrivateLeaseLeaf:
                "prime-secure-child-monitor-held-resource-lease-v1.lock",
            executableURLIsLocatorForFixedAuthenticatedFixtureOnly: true,
            callerSuppliedFullLeaseFileURLAccepted: false,
            callerSuppliedResourceIdentifierAccepted: false,
            callerSuppliedLeaseObjectAccepted: false,
            genericChildAccepted: false,
            leaseObjectReturned: false,
            releaseHandleReturned: false,
            exactLeaseType: "PrimeExclusiveResourceLease",
            productionAcquireCall:
                "PrimeExclusiveResourceLease.acquire(at:)",
            productionAcquireCount: 1,
            acquisitionMustPrecedePlanConstruction: true,
            acquisitionMustPrecedePreparedFixtureConstruction: true,
            rawLeaseReferenceMustRemainPrivateAndNonescaping: true,
            explicitReleaseCallCount: 0,
            leaseReacquisitionCount: 0,
            descriptorTransferCount: 0,
            workerInheritedLeaseDescriptorCount: 0,
            workerLeaseAcquisitionCount: 0,
            workerLeaseReleaseCount: 0,
            monitorOwnsLeasePolicy:
                "closed_monitor_owns_private_lease_policy_only",
            existingSupervisorOwnsChildLifecycleOnly: true,
            monitorOwnsChildLifecycle: false,
            existingSupervisorOwnsLease: false,
            orderedOwnershipChain: [
                "PrimeExclusiveResourceLease",
                "PrimeExclusiveResourceLeaseRetention",
                "PrimeSecureChildLeaseRetention",
                "PrimeTrustedSecureChildProcessCapture.State",
                "PrimeTrustedSecureChildProcessCapture.Consumption",
                "PrimeTrustedSecureChildProcessCapture.Consumption.ExecutionClaim",
                "PrimeSecureChildExecutionKernel.Result",
            ],
            ownershipChainMustRemainInBand: true,
            existingClosedPlanFactory:
                "PrimeSecureChildProcessPlanV1.validationWorkflowFixture(mode:)",
            existingPreparedFixtureType: "PrimeSecureChildPreparedFixture",
            existingCaptureType: "PrimeTrustedSecureChildProcessCapture",
            existingExecutionKernelType: "PrimeSecureChildExecutionKernel",
            arbitraryExecutableAccepted: false,
            arbitraryArgumentsAccepted: false,
            arbitraryEnvironmentAccepted: false,
            ordinaryLeaseDestructionOnlyAfterTerminalContainedReturnOrUnwind:
                true,
            preSpawnFailureMayReleaseBecauseNoChildExists: true,
            failStopPreservesNonreturningContainmentFailure: true,
            layerABytesMustRemainByteIdentical: true,
            layerATelemetryScope: "cooperating_host_path_local",
            layerATelemetryAdvisory: true,
            layerATelemetryOwnerMustRemainLive: true,
            layerATelemetryRetentionIsInBandWithinCapture: true,
            layerATelemetryLabelExternallyOwnedAdvisoryIsNotOwnershipProof:
                true,
            layerATelemetryProvesExclusiveOwnership: false,
            childLifetimeContinuityEstablished: false,
            mlxDeviceIdentityEstablished: false,
            physicalMetalReservationEstablished: false,
            durableEvidenceEstablished: false,
            pureInMemoryFakeTestOnly: true,
            pureFakeMayProveOnly: [
                "identity",
                "strong_object_lifetime",
                "ordered_ownership_topology",
            ],
            actualKernelLockContinuityCanaryIncluded: false,
            actualKernelLockContinuityCanaryRequiresSeparateAuthority: true
        ),
        authorityScope: .init(
            exactOrderedPaths: [
                .init(ordinal: 1, path: ".github/scripts/prime-ci-active-root-quarantine.sh", gitStatus: "M", gitMode: "100755", role: "bind_a1_closure_and_authority_exact5_ceiling"),
                .init(ordinal: 2, path: ".github/workflows/prime-active-root-quarantine.yml", gitStatus: "M", gitMode: "100644", role: "integrate_sole_exhaustive_pure_authority_test"),
                .init(ordinal: 3, path: "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift", gitStatus: "M", gitMode: "100644", role: "bind_517_record_embedded_source_identity"),
                .init(ordinal: 4, path: "Sources/PrimeCore/PrimeMonitorHeldLeaseSecureChildContainmentAuthority.swift", gitStatus: "A", gitMode: "100644", role: "pure_future_composition_authority"),
                .init(ordinal: 5, path: "Tests/PrimeCoreTests/PrimeMonitorHeldLeaseSecureChildContainmentAuthorityTests.swift", gitStatus: "A", gitMode: "100644", role: "sole_exhaustive_pure_authority_test"),
            ],
            exactPathCount: 5,
            activeRootLatinTestCount: 116,
            rootTestCount: 83,
            isolatedGroupTestCounts: [1, 1, 2, 2],
            isolatedTestCount: 6,
            focusedWholeTestCount: 89,
            retainedLiveTestCount: 46,
            aggregateTestCount: 135,
            embeddedProvenanceRecordCount: 517,
            soleAuthorityTestClassName:
                "PrimeMonitorHeldLeaseSecureChildContainmentAuthorityTests",
            soleAuthorityTestMethodName:
                "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
            soleAuthorityTestExpectedStartCount: 1,
            soleAuthorityTestExpectedPassCount: 1,
            addedProofOnlyHistoricalWant:
                "e1d90e3f2ae6c4d3c279bf5fb64ce3baafc1f540",
            addedProofOnlyWantCountPerExistingFetch: 1,
            exactPrimeFetchInvocationCountPerCheckoutRemainsOne: true,
            fetchDepthRemainsTwo: true,
            workflowJobAndStepTopologyMustRemainUnchanged: true,
            retainedLiveCommandsMustRemainByteIdentical: true,
            packageManifestMustRemainByteIdentical: true,
            packageLockMustRemainByteIdentical: true,
            readmeMustRemainByteIdentical: true,
            legacyLeasePairMustRemainByteIdentical: true,
            a1PairMustRemainByteIdentical: true,
            layerABytesMustRemainByteIdentical: true,
            bMLXModelCheckpointBytesMustRemainByteIdentical: true,
            canaryLauncherMustRemainByteIdentical: true,
            implementationIncludedInThisPatch: false,
            implementationAuthorizedOnlyAfterAuthorityExactMainGreen: true,
            authorityExactMainGreenObservedAtAuthoring: false
        ),
        authorityCeiling: .init(
            implementationPerformed: false,
            implementationSourceAdded: false,
            implementationTestAdded: false,
            leaseAcquisitionAuthorized: false,
            leaseAcquisitionPerformed: false,
            leaseReleaseAuthorized: false,
            leaseReleasePerformed: false,
            leaseReacquisitionAuthorized: false,
            leaseFileCreationAuthorized: false,
            leaseFileMutationAuthorized: false,
            descriptorInspectionAuthorized: false,
            descriptorTransferAuthorized: false,
            filesystemWriteAuthorized: false,
            processExecutionAuthorized: false,
            fixtureExecutionAuthorized: false,
            launcherExecutionAuthorized: false,
            canaryExecutionAuthorized: false,
            canaryRetryAuthorized: false,
            canaryRerunAuthorized: false,
            networkAuthorized: false,
            layerAMutationAuthorized: false,
            durableTransactionLayerBAuthorized: false,
            durableEvidenceEstablished: false,
            childLifetimeContinuityEstablished: false,
            physicalMetalReservationEstablished: false,
            mlxDeviceIdentityEstablished: false,
            mlxExecutionAuthorized: false,
            metalExecutionAuthorized: false,
            native300MExecutionAuthorized: false,
            pythonAuthorized: false,
            cppAuthorized: false,
            checkpointAdmissionGranted: false,
            generalTrainingResumeAuthorized: false,
            modelQualityEstablished: false,
            productUseAuthorized: false,
            publicationAuthorized: false
        ),
        optionalFixturePINBoundary: .init(
            requestedByThisAuthority: false,
            deferred: true,
            authorizedByThisAuthority: false,
            requiredForA2: false,
            distinctAuthorityRequired: true
        ),
        orderedRequiredSeparateActions: [
            "merge_and_close_this_pure_exact5_monitor_held_lease_secure_child_containment_authority",
            "separately_implement_only_the_additive_exact5_closed_nested_capture_composition",
            "close_that_implementation_on_exact_main_without_invoking_new_mechanics",
            "separately_authorize_one_shot_real_lease_and_containment_canary",
            "observe_and_irrevocably_retire_that_canary_before_durable_layer_b",
            "separately_authorize_and_implement_durable_transaction_layer_b",
            "separately_authorize_lease_containment_and_durability_transactional_composition",
            "only_then_review_any_mlx_metal_native300_or_cpp_adapter",
        ]
    )

    public func canonicalData() throws -> Data {
        try validate()
        return try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        guard data.count <= 131_072 else {
            throw PrimeMonitorHeldLeaseSecureChildContainmentAuthorityError
                .oversizedEncoding
        }
        let value = try JSONDecoder().decode(Self.self, from: data)
        try value.validateExactV1()
        guard try PrimeCanonicalJSON.encode(value) == data else {
            throw PrimeMonitorHeldLeaseSecureChildContainmentAuthorityError
                .noncanonicalEncoding
        }
        return value
    }

    public func validate() throws {
        guard self == Self.frozenV1 else {
            throw PrimeMonitorHeldLeaseSecureChildContainmentAuthorityError
                .contractDrift
        }
    }

    public func validateExactV1() throws {
        try validate()
        let canonical = try PrimeCanonicalJSON.encode(self)
        guard canonical.count == Self.canonicalByteCount,
              PrimeSHA256.hexDigest(of: canonical) == Self.canonicalSHA256
        else {
            throw PrimeMonitorHeldLeaseSecureChildContainmentAuthorityError
                .contractDrift
        }
    }
}
