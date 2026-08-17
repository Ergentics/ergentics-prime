// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNeutralResourceLeaseGeneralizationAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
    case noncanonicalEncoding
}

/// Pure authority for one additive, neutral naming and typed-retention layer
/// over the byte-frozen `PrimeMetalDeviceLease` implementation.
///
/// This value is data only. It does not acquire, retain, release, or inspect a
/// lease; touch the filesystem; create or observe a process; transfer a file
/// descriptor; or invoke MLX, Metal, Native300M, Python, or C++. It preserves
/// every existing lease call site and defers secure-child composition and
/// durable transaction work to later, separately authorized boundaries.
public struct PrimeNeutralResourceLeaseGeneralizationAuthorityV1:
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

    public struct PathContract: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let gitStatus: String
        public let gitMode: String
        public let role: String
    }

    public struct RetirementClosure: Codable, Equatable, Sendable {
        public let repository: String
        public let ref: String
        public let mergeRevision: String
        public let mergeTree: String
        public let orderedParentRevisions: [String]
        public let pullRequestNumber: Int
        public let pullRequestBaseRevision: String
        public let pullRequestHeadRevision: String
        public let pullRequestHeadTree: String
        public let pullRequestWorkflowRunID: Int
        public let pullRequestWorkflowRunNumber: Int
        public let pullRequestWorkflowRunAttempt: Int
        public let pullRequestCheckSuiteID: Int
        public let pullRequestActiveRootJobID: Int
        public let pullRequestActiveRootJobConclusion: String
        public let pullRequestReviewedMainJobID: Int
        public let pullRequestReviewedMainJobConclusion: String
        public let pullRequestReviewedMainJobStepCount: Int
        public let pullRequestActionsArtifactCount: Int
        public let signedMergeVerified: Bool
        public let workflowRunID: Int
        public let workflowRunNumber: Int
        public let workflowRunAttempt: Int
        public let checkSuiteID: Int
        public let uniqueExactHeadRunCount: Int
        public let previousAttemptURLWasNull: Bool
        public let workflowConclusion: String
        public let activeRootJobID: Int
        public let activeRootJobConclusion: String
        public let reviewedMainJobID: Int
        public let reviewedMainJobConclusion: String
        public let activeLatinTestCount: Int
        public let rootTestCount: Int
        public let isolatedGroupTestCounts: [Int]
        public let isolatedTestCount: Int
        public let focusedWholeTestCount: Int
        public let retainedLiveTestCount: Int
        public let aggregateTestCount: Int
        public let reviewedFailureCount: Int
        public let reviewedSkipCount: Int
        public let observationTestFilter: String
        public let observationTestStartCount: Int
        public let observationTestPassCount: Int
        public let observationTestFailureCount: Int
        public let retryCount: Int
        public let rerunCount: Int
        public let actionsArtifactCount: Int
        public let canaryLauncherWorkflowReferenceCount: Int
        public let canaryLauncherInvocationCount: Int
        public let canaryMechanicsInvocationCount: Int
        public let adapterCommandAttemptCount: Int
        public let fixtureProcessExecutionCount: Int
        public let hostedOperationalRecordCount: Int
        public let retirementObservationCanonicalByteCount: Int
        public let retirementObservationCanonicalSHA256: String
        public let retirementObservationSource: SourceIdentity
        public let retirementObservationTest: SourceIdentity
        public let retirementObservedAtObservationAuthoring: Bool
        public let laterExactMainRetirementClosureObserved: Bool
        public let exactMainRetirementClosureEstablished: Bool
    }

    public struct FixturePinBranch: Codable, Equatable, Sendable {
        public let investigationRequested: Bool
        public let investigationDeferred: Bool
        public let investigationAuthorized: Bool
        public let requiredBeforeCanaryReopening: Bool
        public let requiredBeforeNeutralLeaseAuthority: Bool
        public let canaryReopeningAuthorized: Bool
        public let distinctNewAuthorityRequired: Bool
        public let retiredMechanicsMayBeReused: Bool
        public let retryAuthorized: Bool
        public let rerunAuthorized: Bool
        public let replacementExecutionAuthorized: Bool
        public let observedFixtureIdentityAvailable: Bool
        public let mismatchDimensionAvailable: Bool
    }

    public struct LegacyLeaseContract: Codable, Equatable, Sendable {
        public let source: SourceIdentity
        public let test: SourceIdentity
        public let concreteTypeName: String
        public let errorTypeName: String
        public let processCompatibilityAliasName: String
        public let mechanism: String
        public let imports: [String]
        public let acquisitionFunction: String
        public let releaseFunction: String
        public let localStateProperty: String
        public let parentDescriptorOpenFlags: [String]
        public let leafDescriptorOpenFlags: [String]
        public let parentAndLeafLocksRequired: Bool
        public let acquisitionNonblocking: Bool
        public let finalSymlinkComponentsRejected: Bool
        public let parentAndLeafOwnerValidatedAgainstEffectiveUID: Bool
        public let groupOrOtherWritableParentRejected: Bool
        public let leafModeRequired: String
        public let leafLinkCountRequired: Int
        public let accessControlListsRejected: Bool
        public let unallowedExtendedAttributesRejected: Bool
        public let allowedExtendedAttributeNames: [String]
        public let descriptorAndNameRevalidationRequired: Bool
        public let leafCreatedWhenAbsent: Bool
        public let leafUnlinkedByLease: Bool
        public let leafTruncatedByLease: Bool
        public let staleLeafContentsAuthoritative: Bool
        public let releaseIdempotent: Bool
        public let deinitCallsRelease: Bool
        public let descriptorsCloseOnExec: Bool
        public let localStatePropertyIsKernelProof: Bool
        public let physicalResourceReservationEstablished: Bool
        public let mlxDeviceIdentityEstablished: Bool
        public let crossHostOrCrossJobContinuityEstablished: Bool
        public let advisoryCooperatingProcessScopeOnly: Bool
        public let exactExistingTestMethods: [String]
        public let exactExistingTestCount: Int
    }

    public struct AcquisitionSite: Codable, Equatable, Sendable {
        public let ordinal: Int
        public let path: String
        public let acquisitionAPI: String
        public let role: String
        public let ownershipPolicy: String
        public let disposition: String
        public let staticOccurrenceCount: Int
        public let migrationAuthorizedByThisAuthority: Bool
    }

    public struct NeutralAPIContract: Codable, Equatable, Sendable {
        public let implementationSourcePath: String
        public let implementationTestPath: String
        public let neutralLeaseAlias: String
        public let neutralErrorAlias: String
        public let neutralLeaseAliasVisibility: String
        public let neutralErrorAliasVisibility: String
        public let neutralLeaseAliasDeclaration: String
        public let neutralErrorAliasDeclaration: String
        public let neutralLeaseAliasTarget: String
        public let neutralErrorAliasTarget: String
        public let internalCapabilityProtocol: String
        public let capabilityProtocolComposition: String
        public let capabilityProtocolDeclaration: String
        public let capabilityProtocolMethodCount: Int
        public let capabilityProtocolPropertyCount: Int
        public let legacyLeasePassiveConformanceRequired: Bool
        public let legacyLeasePassiveConformanceDeclaration: String
        public let internalRetentionType: String
        public let retentionTypeDeclaration: String
        public let retentionStoredPropertyName: String
        public let retentionStoredPropertyType: String
        public let retentionStorageStrength: String
        public let retentionStoredPropertyDeclaration: String
        public let retentionInitializerSignature: String
        public let retentionInitializerAssignment: String
        public let retentionPreservesObjectIdentity: Bool
        public let retentionIdentityMethodSignature: String
        public let retentionIdentityComparison: String
        public let retentionIdentityMethodCount: Int
        public let retentionAcquisitionMethodCount: Int
        public let retentionReleaseMethodCount: Int
        public let retentionDescriptorMethodCount: Int
        public let retentionDeinitMethodCount: Int
        public let capabilityProtocolVisibility: String
        public let retentionTypeVisibility: String
        public let compatibilityStrategy: String
        public let fixedTelemetryScope: String
        public let fixedTelemetryAdvisory: Bool
        public let fixedTelemetryOwnerMustRemainLive: Bool
        public let fixedTelemetryChildLifetimeContinuityEstablished: Bool
        public let fixedTelemetryMLXDeviceIdentityEstablished: Bool
        public let fixedTelemetryDurableEvidenceEstablished: Bool
        public let legacyConcreteTypeRemainsAvailable: Bool
        public let legacyErrorTypeRemainsAvailable: Bool
        public let processCompatibilityAliasRemainsAvailable: Bool
        public let existingCallSiteMigrationCount: Int
        public let newDarwinImportCount: Int
        public let newFlockImplementationCount: Int
        public let newLeaseAcquisitionImplementationCount: Int
        public let newLeaseReleaseImplementationCount: Int
        public let additionalRuntimeWrapperAuthorized: Bool
        public let secondLeaseOwnershipLifecycleAuthorized: Bool
        public let arbitraryResourceIdentifierAuthorized: Bool
        public let genericCallerTelemetryAuthorized: Bool
        public let productionConsumerCount: Int
        public let typedSeamCurrentlyUnused: Bool
        public let implementationAuthorizedOnlyAfterAuthorityExactMainGreen: Bool
    }

    public struct LayerABoundary: Codable, Equatable, Sendable {
        public let exactPreservedSources: [SourceIdentity]
        public let existingRetentionType: String
        public let existingRetentionAcceptsOpaqueAnyObject: Bool
        public let existingTelemetryScope: String
        public let existingTelemetryClaimsContinuity: Bool
        public let existingTelemetryClaimsMLXIdentity: Bool
        public let existingTelemetryClaimsDurability: Bool
        public let productionFixtureLeaseArgumentCount: Int
        public let productionLeaseRetentionConstructionCount: Int
        public let newTypedSeamUsedByLayerA: Bool
        public let newTypedSeamReplacesExistingRetention: Bool
        public let newTypedSeamComposesWithExistingRetention: Bool
        public let newTypedSeamMutatesExistingRetention: Bool
        public let existingRetentionMustRemainByteIdentical: Bool
        public let layerASourceMutationAuthorized: Bool
        public let fixtureAPIMutationAuthorized: Bool
        public let processSubstrateMutationAuthorized: Bool
        public let leaseContainmentCompositionAuthorized: Bool
        public let laterCompositionRequiresSeparateAuthority: Bool
    }

    public struct BMLXPreservationBoundary: Codable, Equatable, Sendable {
        public let packageManifest: SourceIdentity
        public let packageLock: SourceIdentity
        public let exactMLXRevision: String
        public let exactMLXOrigin: String
        public let exactPreservedSources: [SourceIdentity]
        public let bPathAlgorithmID: String
        public let bPathSelectorRawValue: String
        public let bPathTrainingLogitsAPI: String
        public let maintainedGatherTrainingLogitsAPI: String
        public let leaseReceiptTypeName: String
        public let supervisorOwnsLease: Bool
        public let workerInheritedLeaseDescriptorCount: Int
        public let distinctExecVerifierReacquiresAndReleases: Bool
        public let defaultGatherPathRemainsByteIdentical: Bool
        public let bPathRemainsExplicitOptIn: Bool
        public let packageManifestMutationAuthorized: Bool
        public let packageLockMutationAuthorized: Bool
        public let mlxRevisionMutationAuthorized: Bool
        public let decoderMutationAuthorized: Bool
        public let trainingMutationAuthorized: Bool
        public let comparatorMutationAuthorized: Bool
        public let existingLeaseReceiptMutationAuthorized: Bool
        public let neutralAliasAdoptionAuthorized: Bool
    }

    public struct TestBoundary: Codable, Equatable, Sendable {
        public let authorityTestPath: String
        public let authorityTestClassName: String
        public let authorityTestMethodName: String
        public let authorityTestFilter: String
        public let authorityExactTestCount: Int
        public let implementationTestPath: String
        public let implementationTestClassName: String
        public let implementationTestMethodName: String
        public let implementationTestFilter: String
        public let implementationExactTestCount: Int
        public let canonicalCodableRequired: Bool
        public let recursiveValueMutationRequired: Bool
        public let recursiveNullMutationRequired: Bool
        public let recursiveRemovalRequired: Bool
        public let recursiveUnknownFieldRequired: Bool
        public let arrayReorderMutationRequired: Bool
        public let noncanonicalEncodingRejectionRequired: Bool
        public let implementationUsesInMemoryFakeCapabilityOnly: Bool
        public let leaseAcquisitionInvocationCount: Int
        public let processInvocationCount: Int
        public let filesystemOperationCount: Int
        public let mlxInvocationCount: Int
        public let metalInvocationCount: Int
    }

    public struct DocumentationBoundary: Codable, Equatable, Sendable {
        public let readmePath: String
        public let stage3BlockedSectionStatus: String
        public let readmeIsTerminalRoadmapAuthority: Bool
        public let terminalRoadmapAuthority: String
        public let appendOnlyFrozenCodableChainRequired: Bool
        public let exactMainClosuresRequired: Bool
        public let readmeMutationAuthorized: Bool
        public let documentationMutationAuthorized: Bool
        public let documentationPathCountInAuthorityExactFive: Int
    }

    public struct Scope: Codable, Equatable, Sendable {
        public let authorityExactOrderedPaths: [PathContract]
        public let authorityExactPathCount: Int
        public let implementationExactOrderedPaths: [PathContract]
        public let implementationExactPathCount: Int
        public let authoritySourceAndTestAreOnlyAddedPaths: Bool
        public let implementationSourceAndTestAreOnlyAddedPaths: Bool
        public let packageManifestMustRemainByteIdentical: Bool
        public let packageLockMustRemainByteIdentical: Bool
        public let legacyLeasePairMustRemainByteIdentical: Bool
        public let layerABytesMustRemainByteIdentical: Bool
        public let bAndMLXBytesMustRemainByteIdentical: Bool
        public let canaryLauncherMustRemainByteIdentical: Bool
        public let canaryLauncherInvocationCount: Int
        public let implementationIncludedInThisPatch: Bool
        public let implementationAuthorizedOnlyAfterAuthorityExactMainGreen: Bool
        public let mechanicsAuthorizedByThisAuthority: Bool
    }

    public struct AuthorityCeiling: Codable, Equatable, Sendable {
        public let implementationPerformed: Bool
        public let implementationSourceAdded: Bool
        public let leaseAcquisitionAuthorized: Bool
        public let leaseReleaseAuthorized: Bool
        public let leaseReacquisitionAuthorized: Bool
        public let leaseFileCreationAuthorized: Bool
        public let leaseFileMutationAuthorized: Bool
        public let descriptorInspectionAuthorized: Bool
        public let descriptorTransferAuthorized: Bool
        public let workerOwnedAcquisitionAuthorized: Bool
        public let monitorDeathContinuityEstablished: Bool
        public let processExecutionAuthorized: Bool
        public let fixtureExecutionAuthorized: Bool
        public let canaryExecutionAuthorized: Bool
        public let canaryRetryAuthorized: Bool
        public let canaryRerunAuthorized: Bool
        public let canaryRepairAuthorized: Bool
        public let filesystemWriteAuthorized: Bool
        public let networkAuthorized: Bool
        public let layerAMutationAuthorized: Bool
        public let secureChildCompositionAuthorized: Bool
        public let durableTransactionLayerBAuthorized: Bool
        public let durableEvidenceEstablished: Bool
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
    public let retirementClosure: RetirementClosure
    public let fixturePinBranch: FixturePinBranch
    public let legacyLeaseContract: LegacyLeaseContract
    public let productionAcquisitionInventory: [AcquisitionSite]
    public let neutralAPIContract: NeutralAPIContract
    public let layerABoundary: LayerABoundary
    public let bMLXPreservationBoundary: BMLXPreservationBoundary
    public let testBoundary: TestBoundary
    public let documentationBoundary: DocumentationBoundary
    public let scope: Scope
    public let authorityCeiling: AuthorityCeiling
    public let orderedRequiredSeparateActions: [String]
    public let status: String

    public static let canonicalByteCount = 27_174
    public static let canonicalSHA256 =
        "ae5b5a73861bbd1584510f0adf358eee32ddb478878597272dc8b0a67c0142cb"

    public static let frozenV1: Self = {
        func source(
            _ path: String,
            _ mode: String,
            _ blob: String,
            _ bytes: Int,
            _ lines: Int,
            _ sha256: String,
            _ role: String
        ) -> SourceIdentity {
            .init(
                path: path,
                gitMode: mode,
                gitBlob: blob,
                byteCount: bytes,
                lfByteCount: lines,
                sha256: sha256,
                role: role)
        }

        func path(
            _ ordinal: Int,
            _ path: String,
            _ status: String,
            _ mode: String,
            _ role: String
        ) -> PathContract {
            .init(
                ordinal: ordinal,
                path: path,
                gitStatus: status,
                gitMode: mode,
                role: role)
        }

        func acquisition(
            _ ordinal: Int,
            _ path: String,
            _ api: String,
            _ role: String,
            _ ownership: String,
            _ disposition: String
        ) -> AcquisitionSite {
            .init(
                ordinal: ordinal,
                path: path,
                acquisitionAPI: api,
                role: role,
                ownershipPolicy: ownership,
                disposition: disposition,
                staticOccurrenceCount: 1,
                migrationAuthorizedByThisAuthority: false)
        }

        let retirementSource = source(
            "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservation.swift",
            "100644", "bd84b810a1842635b7e874826b7c58cf42baacda",
            52_517, 1_103,
            "739eed7ece6ea1b2f952d9f02ad613af15adc100788979a47f0edee4aedbb2f1",
            "frozen_pin_mismatch_observation_and_retirement")
        let retirementTest = source(
            "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests.swift",
            "100644", "01ee01a48eb24bf25139c01db2b4ec80196712a1",
            36_265, 811,
            "bb89e3b5072622d594383143720db99411746766e55cca229cde44724b244671",
            "frozen_pin_mismatch_observation_test")
        let legacyLeaseSource = source(
            "Sources/PrimeCore/PrimeMetalDeviceLease.swift",
            "100644", "da3daa54802b67dc2c8c04a89b388e9927dd8726",
            16_985, 534,
            "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657",
            "byte_frozen_parent_and_leaf_flock_implementation")
        let legacyLeaseTest = source(
            "Tests/PrimeCoreTests/PrimeMetalDeviceLeaseTests.swift",
            "100644", "05960c8017147f7a3e1d90fb68d2449bc18698b6",
            13_257, 451,
            "ebdcd5d62d0d0915a63e82822ba58dc954e209bcaf7905b663b99a4687670018",
            "byte_frozen_live_darwin_lease_tests")

        let authorityPaths = [
            path(1, ".github/scripts/prime-ci-active-root-quarantine.sh",
                 "M", "100755", "bind_pure_authority_pair_and_scope"),
            path(2, ".github/workflows/prime-active-root-quarantine.yml",
                 "M", "100644", "run_one_pure_authority_test"),
            path(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                 "M", "100644", "refresh_embedded_source_identity_only"),
            path(4,
                 "Sources/PrimeCore/PrimeNeutralResourceLeaseGeneralizationAuthority.swift",
                 "A", "100644", "pure_neutral_lease_generalization_authority"),
            path(5,
                 "Tests/PrimeCoreTests/PrimeNeutralResourceLeaseGeneralizationAuthorityTests.swift",
                 "A", "100644", "pure_canonical_exhaustive_authority_test"),
        ]
        let implementationPaths = [
            path(1, ".github/scripts/prime-ci-active-root-quarantine.sh",
                 "M", "100755", "bind_exact_additive_implementation"),
            path(2, ".github/workflows/prime-active-root-quarantine.yml",
                 "M", "100644", "run_one_pure_implementation_test"),
            path(3, "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                 "M", "100644", "refresh_embedded_source_identity_only"),
            path(4, "Sources/PrimeCore/PrimeExclusiveResourceLease.swift",
                 "A", "100644", "neutral_aliases_and_internal_typed_retention"),
            path(5,
                 "Tests/PrimeCoreTests/PrimeExclusiveResourceLeaseTests.swift",
                 "A", "100644", "pure_alias_and_fake_retention_contract"),
        ]

        return Self(
            schemaVersion: 1,
            schemaID:
                "prime_neutral_resource_lease_generalization_authority_schema_v1",
            authorityID:
                "prime_neutral_resource_lease_generalization_authority_v1",
            authorityKind:
                "pure_exact5_authority_for_additive_neutral_lease_alias_and_typed_retention_after_closed_canary_retirement",
            retirementClosure: .init(
                repository: "Ergentics/ergentics-prime",
                ref: "refs/heads/main",
                mergeRevision:
                    "4570716892722873757de6eae1bd897167d674eb",
                mergeTree:
                    "29d28080eb945563ca6da7e1e8475189bdce7c11",
                orderedParentRevisions: [
                    "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
                    "18ec420a4870657adc0125425a2b26ec41d06ed2",
                ],
                pullRequestNumber: 123,
                pullRequestBaseRevision:
                    "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
                pullRequestHeadRevision:
                    "18ec420a4870657adc0125425a2b26ec41d06ed2",
                pullRequestHeadTree:
                    "29d28080eb945563ca6da7e1e8475189bdce7c11",
                pullRequestWorkflowRunID: 31_979_882_205,
                pullRequestWorkflowRunNumber: 144,
                pullRequestWorkflowRunAttempt: 1,
                pullRequestCheckSuiteID: 86_706_120_484,
                pullRequestActiveRootJobID: 95_244_849_854,
                pullRequestActiveRootJobConclusion: "success",
                pullRequestReviewedMainJobID: 95_245_296_697,
                pullRequestReviewedMainJobConclusion: "skipped",
                pullRequestReviewedMainJobStepCount: 0,
                pullRequestActionsArtifactCount: 0,
                signedMergeVerified: true,
                workflowRunID: 31_980_256_444,
                workflowRunNumber: 145,
                workflowRunAttempt: 1,
                checkSuiteID: 86_706_948_013,
                uniqueExactHeadRunCount: 1,
                previousAttemptURLWasNull: true,
                workflowConclusion: "success",
                activeRootJobID: 95_245_754_364,
                activeRootJobConclusion: "success",
                reviewedMainJobID: 95_246_177_042,
                reviewedMainJobConclusion: "success",
                activeLatinTestCount: 116,
                rootTestCount: 79,
                isolatedGroupTestCounts: [1, 1, 2, 2],
                isolatedTestCount: 6,
                focusedWholeTestCount: 85,
                retainedLiveTestCount: 46,
                aggregateTestCount: 131,
                reviewedFailureCount: 0,
                reviewedSkipCount: 0,
                observationTestFilter:
                    "PrimeCoreTests.PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRetirementCeiling",
                observationTestStartCount: 1,
                observationTestPassCount: 1,
                observationTestFailureCount: 0,
                retryCount: 0,
                rerunCount: 0,
                actionsArtifactCount: 0,
                canaryLauncherWorkflowReferenceCount: 0,
                canaryLauncherInvocationCount: 0,
                canaryMechanicsInvocationCount: 0,
                adapterCommandAttemptCount: 0,
                fixtureProcessExecutionCount: 0,
                hostedOperationalRecordCount: 0,
                retirementObservationCanonicalByteCount: 12_604,
                retirementObservationCanonicalSHA256:
                    "327a3fedcd1fed6a936aa053c3882c770a106db7e2662e76815a2b5d21333e16",
                retirementObservationSource: retirementSource,
                retirementObservationTest: retirementTest,
                retirementObservedAtObservationAuthoring: false,
                laterExactMainRetirementClosureObserved: true,
                exactMainRetirementClosureEstablished: true),
            fixturePinBranch: .init(
                investigationRequested: false,
                investigationDeferred: true,
                investigationAuthorized: false,
                requiredBeforeCanaryReopening: true,
                requiredBeforeNeutralLeaseAuthority: false,
                canaryReopeningAuthorized: false,
                distinctNewAuthorityRequired: true,
                retiredMechanicsMayBeReused: false,
                retryAuthorized: false,
                rerunAuthorized: false,
                replacementExecutionAuthorized: false,
                observedFixtureIdentityAvailable: false,
                mismatchDimensionAvailable: false),
            legacyLeaseContract: .init(
                source: legacyLeaseSource,
                test: legacyLeaseTest,
                concreteTypeName: "PrimeMetalDeviceLease",
                errorTypeName: "PrimeMetalDeviceLeaseError",
                processCompatibilityAliasName: "PrimeExclusiveProcessLease",
                mechanism: "darwin_parent_and_leaf_flock",
                imports: ["Darwin", "Foundation"],
                acquisitionFunction: "acquire(at:)",
                releaseFunction: "release()",
                localStateProperty: "isHeld",
                parentDescriptorOpenFlags: [
                    "O_RDONLY", "O_DIRECTORY", "O_NOFOLLOW", "O_CLOEXEC",
                ],
                leafDescriptorOpenFlags: [
                    "O_RDWR", "O_CREAT", "O_NOFOLLOW", "O_CLOEXEC",
                ],
                parentAndLeafLocksRequired: true,
                acquisitionNonblocking: true,
                finalSymlinkComponentsRejected: true,
                parentAndLeafOwnerValidatedAgainstEffectiveUID: true,
                groupOrOtherWritableParentRejected: true,
                leafModeRequired: "0600",
                leafLinkCountRequired: 1,
                accessControlListsRejected: true,
                unallowedExtendedAttributesRejected: true,
                allowedExtendedAttributeNames: ["com.apple.provenance"],
                descriptorAndNameRevalidationRequired: true,
                leafCreatedWhenAbsent: true,
                leafUnlinkedByLease: false,
                leafTruncatedByLease: false,
                staleLeafContentsAuthoritative: false,
                releaseIdempotent: true,
                deinitCallsRelease: true,
                descriptorsCloseOnExec: true,
                localStatePropertyIsKernelProof: false,
                physicalResourceReservationEstablished: false,
                mlxDeviceIdentityEstablished: false,
                crossHostOrCrossJobContinuityEstablished: false,
                advisoryCooperatingProcessScopeOnly: true,
                exactExistingTestMethods: [
                    "testAcquireHoldsExclusiveLeaseAndReleaseIsIdempotent",
                    "testParentLockPreventsSplitLeaseAfterLeafRename",
                    "testCompetingProcessIsDeniedUntilHolderReleases",
                    "testSymbolicLinkLeaseIsDenied",
                    "testSymbolicLinkParentIsDenied",
                    "testHardLinkedLeaseIsDenied",
                    "testGroupWritableParentIsDenied",
                    "testNonPrivateLeaseModeIsDenied",
                    "testExtendedAttributesAreDenied",
                    "testStalePIDTextIsNeitherDeletedNorRewritten",
                ],
                exactExistingTestCount: 10),
            productionAcquisitionInventory: [
                acquisition(1,
                    "Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "swiftpm_build_inventory_admission_scope",
                    "admission_object_owned",
                    "retained_current_source"),
                acquisition(2,
                    "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
                    "PrimeExclusiveProcessLease.acquire",
                    "calibration_worker_expected_busy_supervisor_authority_probe",
                    "probe_only",
                    "retained_current_source"),
                acquisition(3,
                    "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "calibration_worker_metal_device_lease",
                    "worker_owned",
                    "retained_current_source"),
                acquisition(4,
                    "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
                    "PrimeExclusiveProcessLease.acquire",
                    "calibration_supervisor_artifact_publication_authority",
                    "supervisor_owned",
                    "retained_current_source"),
                acquisition(5,
                    "Sources/PrimeLeaseHolder/PrimeLeaseHolderMain.swift",
                    "PrimeExclusiveProcessLease.acquire",
                    "interactive_process_lease_holder",
                    "holder_process_owned",
                    "retained_current_source"),
                acquisition(6,
                    "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
                    "PrimeExclusiveProcessLease.acquire",
                    "native3b_worker_expected_busy_supervisor_authority_probe",
                    "probe_only",
                    "retained_current_source"),
                acquisition(7,
                    "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
                    "PrimeExclusiveProcessLease.acquire",
                    "native3b_supervisor_artifact_publication_authority",
                    "supervisor_owned",
                    "retained_current_source"),
                acquisition(8,
                    "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "native3b_supervisor_metal_device_lease",
                    "supervisor_owned",
                    "retained_current_source"),
                acquisition(9,
                    "Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "maintained_runtime_metal_device_lease",
                    "runtime_process_owned",
                    "retained_current_source"),
                acquisition(10,
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "b_specific_resource_supervisor_metal_device_lease",
                    "supervisor_owned",
                    "retired_mechanics_source_preserved"),
                acquisition(11,
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "b_specific_resource_exec_verifier_reacquisition",
                    "verifier_owned",
                    "retired_mechanics_source_preserved"),
                acquisition(12,
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "stage7_trajectory_supervisor_metal_device_lease",
                    "supervisor_owned",
                    "failed_retired_mechanics_source_preserved"),
                acquisition(13,
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "stage7_trajectory_exec_verifier_reacquisition",
                    "verifier_owned",
                    "failed_retired_mechanics_source_preserved"),
                acquisition(14,
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "stage6_supervisor_post_worker_reacquisition_proof",
                    "supervisor_probe_owned",
                    "historical_retired_mechanics_source_preserved"),
                acquisition(15,
                    "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift",
                    "PrimeMetalDeviceLease.acquire",
                    "stage6_worker_metal_device_lease",
                    "worker_owned",
                    "historical_retired_mechanics_source_preserved"),
            ],
            neutralAPIContract: .init(
                implementationSourcePath:
                    "Sources/PrimeCore/PrimeExclusiveResourceLease.swift",
                implementationTestPath:
                    "Tests/PrimeCoreTests/PrimeExclusiveResourceLeaseTests.swift",
                neutralLeaseAlias: "PrimeExclusiveResourceLease",
                neutralErrorAlias: "PrimeExclusiveResourceLeaseError",
                neutralLeaseAliasVisibility: "public",
                neutralErrorAliasVisibility: "public",
                neutralLeaseAliasDeclaration:
                    "public typealias PrimeExclusiveResourceLease = PrimeMetalDeviceLease",
                neutralErrorAliasDeclaration:
                    "public typealias PrimeExclusiveResourceLeaseError = PrimeMetalDeviceLeaseError",
                neutralLeaseAliasTarget: "PrimeMetalDeviceLease",
                neutralErrorAliasTarget: "PrimeMetalDeviceLeaseError",
                internalCapabilityProtocol:
                    "PrimeExclusiveResourceLeaseCapability",
                capabilityProtocolComposition: "AnyObject & Sendable",
                capabilityProtocolDeclaration:
                    "protocol PrimeExclusiveResourceLeaseCapability: AnyObject, Sendable {}",
                capabilityProtocolMethodCount: 0,
                capabilityProtocolPropertyCount: 0,
                legacyLeasePassiveConformanceRequired: true,
                legacyLeasePassiveConformanceDeclaration:
                    "extension PrimeMetalDeviceLease: PrimeExclusiveResourceLeaseCapability {}",
                internalRetentionType:
                    "PrimeExclusiveResourceLeaseRetention",
                retentionTypeDeclaration:
                    "final class PrimeExclusiveResourceLeaseRetention: Sendable",
                retentionStoredPropertyName: "lease",
                retentionStoredPropertyType:
                    "any PrimeExclusiveResourceLeaseCapability",
                retentionStorageStrength: "strong",
                retentionStoredPropertyDeclaration:
                    "private let lease: any PrimeExclusiveResourceLeaseCapability",
                retentionInitializerSignature:
                    "init(_ lease: any PrimeExclusiveResourceLeaseCapability)",
                retentionInitializerAssignment: "self.lease = lease",
                retentionPreservesObjectIdentity: true,
                retentionIdentityMethodSignature:
                    "func retains(_ candidate: any PrimeExclusiveResourceLeaseCapability) -> Bool",
                retentionIdentityComparison:
                    "ObjectIdentifier(lease) == ObjectIdentifier(candidate)",
                retentionIdentityMethodCount: 1,
                retentionAcquisitionMethodCount: 0,
                retentionReleaseMethodCount: 0,
                retentionDescriptorMethodCount: 0,
                retentionDeinitMethodCount: 0,
                capabilityProtocolVisibility: "internal_closed_marker",
                retentionTypeVisibility: "internal",
                compatibilityStrategy:
                    "additive_alias_first_no_existing_callsite_migration",
                fixedTelemetryScope: "cooperating_host_path_local",
                fixedTelemetryAdvisory: true,
                fixedTelemetryOwnerMustRemainLive: true,
                fixedTelemetryChildLifetimeContinuityEstablished: false,
                fixedTelemetryMLXDeviceIdentityEstablished: false,
                fixedTelemetryDurableEvidenceEstablished: false,
                legacyConcreteTypeRemainsAvailable: true,
                legacyErrorTypeRemainsAvailable: true,
                processCompatibilityAliasRemainsAvailable: true,
                existingCallSiteMigrationCount: 0,
                newDarwinImportCount: 0,
                newFlockImplementationCount: 0,
                newLeaseAcquisitionImplementationCount: 0,
                newLeaseReleaseImplementationCount: 0,
                additionalRuntimeWrapperAuthorized: false,
                secondLeaseOwnershipLifecycleAuthorized: false,
                arbitraryResourceIdentifierAuthorized: false,
                genericCallerTelemetryAuthorized: false,
                productionConsumerCount: 0,
                typedSeamCurrentlyUnused: true,
                implementationAuthorizedOnlyAfterAuthorityExactMainGreen: true),
            layerABoundary: .init(
                exactPreservedSources: [
                    source("Sources/PrimeCore/PrimeSecureChildProcessPlan.swift",
                        "100644", "f9bc922c90ad7b6ed5d8f28b2f0b6f5085043281",
                        5_440, 148,
                        "06e130d5f8367c2b5822a53787e610826c3b6dd7a3e8644cee7f0ba2384b0510",
                        "layer_a_closed_process_plan"),
                    source("Sources/PrimeCore/PrimeSecureChildProcessEvidence.swift",
                        "100644", "7ffa7711943e485f98e98ae8a862efb12f8a4516",
                        38_655, 1_040,
                        "950688d06bc4df919fe53fa4e1ea4711d704c968d4e9349fafe9c86ee5928b9b",
                        "layer_a_typed_operational_evidence"),
                    source("Sources/PrimeCore/PrimeTrustedSecureChildProcessCapture.swift",
                        "100644", "a289898d4b0239728bd882d14948d0ab01e91766",
                        5_499, 167,
                        "0cb4a2eb54b8b8a4baa0e1ffe4c17f05d407e91f316306426a0b611d54041b85",
                        "layer_a_one_shot_capture_and_opaque_lease_retention"),
                    source("Sources/PrimeCore/PrimeSecureChildExecutionKernel.swift",
                        "100644", "616af54193830c897c634500ce294b827a3d9e22",
                        11_167, 303,
                        "bb62c691fa78428bacc5c1e26800692e07fb060214b4e73ce654629f833c559a",
                        "layer_a_typed_projection_kernel"),
                    source("Sources/PrimeCore/PrimeSecureChildDrains.swift",
                        "100644", "6579b9a08dea19b7c4d4654ec3b9735d3cc0d8b4",
                        17_440, 609,
                        "8300f4845fc9861d78dd2bccfddc1d480920af74f0bd4cfa8f16dafd7ed5ecbe",
                        "layer_a_terminal_drain_substrate"),
                    source("Sources/PrimeCore/PrimeSecureChildSupervision.swift",
                        "100644", "13d882363479143d2a207375ac3eb84971fabb35",
                        24_830, 842,
                        "700f64199ccfcfac2c21cd7e0e8145d6e72d3cc85ad64ee8781a08fc7dcc6caf",
                        "layer_a_single_owner_supervision_substrate"),
                    source("Sources/PrimeCore/PrimeSecureChildKernel.swift",
                        "100644", "bfa381796b9647863e704006dbaa1406c533c7c5",
                        83_657, 2_327,
                        "1ed890d017b67c97a0d980d58cb7614bb71362091c02b03d26a26222b24d5fcd",
                        "layer_a_closed_fixture_compatibility_substrate"),
                    source("Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceTests.swift",
                        "100644", "d612316fe0fbe9c835331a3f8fcae4477064bd73",
                        45_527, 1_260,
                        "28ac04ed21e23cd33585db753083b1e719ad3f7a7b00214d8d101eb361e60a04",
                        "layer_a_exact12_deterministic_test_matrix"),
                ],
                existingRetentionType: "PrimeSecureChildLeaseRetention",
                existingRetentionAcceptsOpaqueAnyObject: true,
                existingTelemetryScope: "cooperating_host_path_local",
                existingTelemetryClaimsContinuity: false,
                existingTelemetryClaimsMLXIdentity: false,
                existingTelemetryClaimsDurability: false,
                productionFixtureLeaseArgumentCount: 0,
                productionLeaseRetentionConstructionCount: 0,
                newTypedSeamUsedByLayerA: false,
                newTypedSeamReplacesExistingRetention: false,
                newTypedSeamComposesWithExistingRetention: false,
                newTypedSeamMutatesExistingRetention: false,
                existingRetentionMustRemainByteIdentical: true,
                layerASourceMutationAuthorized: false,
                fixtureAPIMutationAuthorized: false,
                processSubstrateMutationAuthorized: false,
                leaseContainmentCompositionAuthorized: false,
                laterCompositionRequiresSeparateAuthority: true),
            bMLXPreservationBoundary: .init(
                packageManifest: source("Package.swift", "100644",
                    "8e14c10aded588b3902a042341bca7acc842bcc6",
                    32_843, 934,
                    "fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81",
                    "exact_root_package_manifest"),
                packageLock: source("Package.resolved", "100644",
                    "14d804bb4291720477240c27e24de6fbdc876b3b",
                    645, 23,
                    "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375",
                    "exact_root_dependency_lock"),
                exactMLXRevision:
                    "d37885a278f1c37484a94d0f401a418735e66519",
                exactMLXOrigin:
                    "https://github.com/Ergentics/ergentics-mlx-swift",
                exactPreservedSources: [
                    source("Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                        "100644", "de6cff4472de55a8fafe2962c3be4ca37c972caf",
                        43_339, 1_193,
                        "ec869ee013814c5b9e0228674097fe4d931d52aa119d23ebbc61d40f37cc7adc",
                        "current_b_decoder_and_comparator_source"),
                    source("Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                        "100644", "4566477e14b4b6cfa06286f384f07f8d452e8724",
                        97_449, 2_444,
                        "cab64f1e77d6f72bfef971bb8e1e4c40aee6072c1ed21f3b466599328f88fdcb",
                        "current_b_training_selector_source"),
                    source("Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift",
                        "100644", "cf3d743d121f4eaa028e0e392e04587bcd0b93d8",
                        225_960, 5_233,
                        "77fbe6b5e9548d84af30c95ba4ca0cfa2d03d5e1884c74d0a9ae297b109eed8b",
                        "retired_b_specific_resource_witness_source"),
                    source("Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
                        "100644", "939b949cd86741e98cdb389863f1b9378107b78f",
                        311_307, 7_129,
                        "15d2407998ac485ba0603cdd0f0318f06e2b668e79e87df5675429a145dd5238",
                        "failed_retired_b_trajectory_checkpoint_source"),
                ],
                bPathAlgorithmID:
                    "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1",
                bPathSelectorRawValue:
                    "flattened_dense_one_hot_matmul_input_embedding_v1",
                bPathTrainingLogitsAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1",
                maintainedGatherTrainingLogitsAPI:
                    "PrimeNativeGQADecoder.trainingLogitsNoCache",
                leaseReceiptTypeName: "PrimeMetalDeviceLease",
                supervisorOwnsLease: true,
                workerInheritedLeaseDescriptorCount: 0,
                distinctExecVerifierReacquiresAndReleases: true,
                defaultGatherPathRemainsByteIdentical: true,
                bPathRemainsExplicitOptIn: true,
                packageManifestMutationAuthorized: false,
                packageLockMutationAuthorized: false,
                mlxRevisionMutationAuthorized: false,
                decoderMutationAuthorized: false,
                trainingMutationAuthorized: false,
                comparatorMutationAuthorized: false,
                existingLeaseReceiptMutationAuthorized: false,
                neutralAliasAdoptionAuthorized: false),
            testBoundary: .init(
                authorityTestPath:
                    "Tests/PrimeCoreTests/PrimeNeutralResourceLeaseGeneralizationAuthorityTests.swift",
                authorityTestClassName:
                    "PrimeNeutralResourceLeaseGeneralizationAuthorityTests",
                authorityTestMethodName:
                    "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
                authorityTestFilter:
                    "PrimeCoreTests.PrimeNeutralResourceLeaseGeneralizationAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling",
                authorityExactTestCount: 1,
                implementationTestPath:
                    "Tests/PrimeCoreTests/PrimeExclusiveResourceLeaseTests.swift",
                implementationTestClassName:
                    "PrimeExclusiveResourceLeaseTests",
                implementationTestMethodName:
                    "testAliasesAndTypedRetentionRemainPureAndTruthful",
                implementationTestFilter:
                    "PrimeCoreTests.PrimeExclusiveResourceLeaseTests/testAliasesAndTypedRetentionRemainPureAndTruthful",
                implementationExactTestCount: 1,
                canonicalCodableRequired: true,
                recursiveValueMutationRequired: true,
                recursiveNullMutationRequired: true,
                recursiveRemovalRequired: true,
                recursiveUnknownFieldRequired: true,
                arrayReorderMutationRequired: true,
                noncanonicalEncodingRejectionRequired: true,
                implementationUsesInMemoryFakeCapabilityOnly: true,
                leaseAcquisitionInvocationCount: 0,
                processInvocationCount: 0,
                filesystemOperationCount: 0,
                mlxInvocationCount: 0,
                metalInvocationCount: 0),
            documentationBoundary: .init(
                readmePath: "README.md",
                stage3BlockedSectionStatus:
                    "historical_stale_not_terminal_roadmap_authority",
                readmeIsTerminalRoadmapAuthority: false,
                terminalRoadmapAuthority:
                    "append_only_frozen_codable_authority_observation_chain_plus_exact_main_closures",
                appendOnlyFrozenCodableChainRequired: true,
                exactMainClosuresRequired: true,
                readmeMutationAuthorized: false,
                documentationMutationAuthorized: false,
                documentationPathCountInAuthorityExactFive: 0),
            scope: .init(
                authorityExactOrderedPaths: authorityPaths,
                authorityExactPathCount: 5,
                implementationExactOrderedPaths: implementationPaths,
                implementationExactPathCount: 5,
                authoritySourceAndTestAreOnlyAddedPaths: true,
                implementationSourceAndTestAreOnlyAddedPaths: true,
                packageManifestMustRemainByteIdentical: true,
                packageLockMustRemainByteIdentical: true,
                legacyLeasePairMustRemainByteIdentical: true,
                layerABytesMustRemainByteIdentical: true,
                bAndMLXBytesMustRemainByteIdentical: true,
                canaryLauncherMustRemainByteIdentical: true,
                canaryLauncherInvocationCount: 0,
                implementationIncludedInThisPatch: false,
                implementationAuthorizedOnlyAfterAuthorityExactMainGreen: true,
                mechanicsAuthorizedByThisAuthority: false),
            authorityCeiling: .init(
                implementationPerformed: false,
                implementationSourceAdded: false,
                leaseAcquisitionAuthorized: false,
                leaseReleaseAuthorized: false,
                leaseReacquisitionAuthorized: false,
                leaseFileCreationAuthorized: false,
                leaseFileMutationAuthorized: false,
                descriptorInspectionAuthorized: false,
                descriptorTransferAuthorized: false,
                workerOwnedAcquisitionAuthorized: false,
                monitorDeathContinuityEstablished: false,
                processExecutionAuthorized: false,
                fixtureExecutionAuthorized: false,
                canaryExecutionAuthorized: false,
                canaryRetryAuthorized: false,
                canaryRerunAuthorized: false,
                canaryRepairAuthorized: false,
                filesystemWriteAuthorized: false,
                networkAuthorized: false,
                layerAMutationAuthorized: false,
                secureChildCompositionAuthorized: false,
                durableTransactionLayerBAuthorized: false,
                durableEvidenceEstablished: false,
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
                publicationAuthorized: false),
            orderedRequiredSeparateActions: [
                "merge_and_close_this_pure_exact5_neutral_resource_lease_generalization_authority",
                "separately_implement_only_the_additive_exact5_neutral_alias_and_typed_retention",
                "close_the_implementation_on_exact_main_without_lease_or_process_execution",
                "separately_authorize_monitor_held_lease_and_secure_containment_composition",
                "separately_authorize_durable_transaction_layer_b",
                "separately_authorize_lease_containment_and_durability_transactional_composition",
                "only_then_review_any_mlx_metal_native300_or_cpp_adapter",
            ],
            status:
                "AUTHORITY_ONLY_neutral_resource_lease_alias_and_typed_retention_exact5_no_implementation_no_mechanics_legacy_b_mlx_layer_a_preserved")
    }()

    public func canonicalData() throws -> Data {
        try PrimeCanonicalJSON.encode(self)
    }

    public static func decodeCanonical(_ data: Data) throws -> Self {
        let value = try JSONDecoder().decode(Self.self, from: data)
        guard try value.canonicalData() == data else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityError
                .noncanonicalEncoding
        }
        try value.validateExactV1()
        return value
    }

    public func validate() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityError
                .contractDrift
        }

        let closure = retirementClosure
        let legacy = legacyLeaseContract
        let api = neutralAPIContract
        let layerA = layerABoundary
        let b = bMLXPreservationBoundary
        let tests = testBoundary
        let documentation = documentationBoundary
        let authorityPaths = scope.authorityExactOrderedPaths
        let implementationPaths = scope.implementationExactOrderedPaths

        guard schemaVersion == 1,
              schemaID
                == "prime_neutral_resource_lease_generalization_authority_schema_v1",
              authorityID
                == "prime_neutral_resource_lease_generalization_authority_v1",
              closure.pullRequestNumber == 123,
              closure.orderedParentRevisions
                == [
                    closure.pullRequestBaseRevision,
                    closure.pullRequestHeadRevision,
                ],
              closure.pullRequestHeadTree == closure.mergeTree,
              closure.pullRequestWorkflowRunNumber == 144,
              closure.pullRequestWorkflowRunAttempt == 1,
              closure.pullRequestActiveRootJobConclusion == "success",
              closure.pullRequestReviewedMainJobConclusion == "skipped",
              closure.pullRequestReviewedMainJobStepCount == 0,
              closure.pullRequestActionsArtifactCount == 0,
              closure.workflowRunNumber == 145,
              closure.workflowRunAttempt == 1,
              closure.signedMergeVerified,
              closure.workflowConclusion == "success",
              closure.activeRootJobConclusion == "success",
              closure.reviewedMainJobConclusion == "success",
              closure.activeLatinTestCount == 116,
              closure.rootTestCount == 79,
              closure.isolatedGroupTestCounts == [1, 1, 2, 2],
              closure.isolatedTestCount == 6,
              closure.focusedWholeTestCount == 85,
              closure.retainedLiveTestCount == 46,
              closure.aggregateTestCount == 131,
              closure.observationTestStartCount == 1,
              closure.observationTestPassCount == 1,
              closure.observationTestFailureCount == 0,
              closure.retryCount == 0,
              closure.rerunCount == 0,
              closure.actionsArtifactCount == 0,
              closure.canaryLauncherWorkflowReferenceCount == 0,
              closure.canaryLauncherInvocationCount == 0,
              closure.canaryMechanicsInvocationCount == 0,
              closure.adapterCommandAttemptCount == 0,
              closure.fixtureProcessExecutionCount == 0,
              closure.hostedOperationalRecordCount == 0,
              closure.exactMainRetirementClosureEstablished,
              validSource(closure.retirementObservationSource),
              validSource(closure.retirementObservationTest),
              !closure.retirementObservedAtObservationAuthoring,
              closure.laterExactMainRetirementClosureObserved,
              !fixturePinBranch.investigationRequested,
              fixturePinBranch.investigationDeferred,
              !fixturePinBranch.investigationAuthorized,
              fixturePinBranch.requiredBeforeCanaryReopening,
              !fixturePinBranch.requiredBeforeNeutralLeaseAuthority,
              !fixturePinBranch.canaryReopeningAuthorized,
              fixturePinBranch.distinctNewAuthorityRequired,
              !fixturePinBranch.retiredMechanicsMayBeReused,
              validSource(legacy.source),
              validSource(legacy.test),
              legacy.parentAndLeafLocksRequired,
              legacy.acquisitionNonblocking,
              legacy.descriptorAndNameRevalidationRequired,
              !legacy.leafUnlinkedByLease,
              !legacy.leafTruncatedByLease,
              !legacy.staleLeafContentsAuthoritative,
              legacy.releaseIdempotent,
              legacy.deinitCallsRelease,
              legacy.descriptorsCloseOnExec,
              !legacy.localStatePropertyIsKernelProof,
              legacy.advisoryCooperatingProcessScopeOnly,
              legacy.exactExistingTestCount
                == legacy.exactExistingTestMethods.count,
              legacy.exactExistingTestCount == 10,
              productionAcquisitionInventory.count == 15,
              productionAcquisitionInventory.map(\.ordinal)
                == Array(1 ... 15),
              productionAcquisitionInventory.allSatisfy({
                  $0.staticOccurrenceCount == 1
                    && !$0.migrationAuthorizedByThisAuthority
              }),
              api.compatibilityStrategy
                == "additive_alias_first_no_existing_callsite_migration",
              api.neutralLeaseAliasTarget == legacy.concreteTypeName,
              api.neutralErrorAliasTarget == legacy.errorTypeName,
              api.neutralLeaseAliasVisibility == "public",
              api.neutralErrorAliasVisibility == "public",
              api.neutralLeaseAliasDeclaration
                == "public typealias PrimeExclusiveResourceLease = PrimeMetalDeviceLease",
              api.neutralErrorAliasDeclaration
                == "public typealias PrimeExclusiveResourceLeaseError = PrimeMetalDeviceLeaseError",
              api.capabilityProtocolComposition == "AnyObject & Sendable",
              api.capabilityProtocolDeclaration
                == "protocol PrimeExclusiveResourceLeaseCapability: AnyObject, Sendable {}",
              api.capabilityProtocolMethodCount == 0,
              api.capabilityProtocolPropertyCount == 0,
              api.legacyLeasePassiveConformanceRequired,
              api.legacyLeasePassiveConformanceDeclaration
                == "extension PrimeMetalDeviceLease: PrimeExclusiveResourceLeaseCapability {}",
              api.retentionTypeDeclaration
                == "final class PrimeExclusiveResourceLeaseRetention: Sendable",
              api.retentionStoredPropertyName == "lease",
              api.retentionStoredPropertyType
                == "any PrimeExclusiveResourceLeaseCapability",
              api.retentionStorageStrength == "strong",
              api.retentionStoredPropertyDeclaration
                == "private let lease: any PrimeExclusiveResourceLeaseCapability",
              api.retentionInitializerSignature
                == "init(_ lease: any PrimeExclusiveResourceLeaseCapability)",
              api.retentionInitializerAssignment == "self.lease = lease",
              api.retentionPreservesObjectIdentity,
              api.retentionIdentityMethodSignature
                == "func retains(_ candidate: any PrimeExclusiveResourceLeaseCapability) -> Bool",
              api.retentionIdentityComparison
                == "ObjectIdentifier(lease) == ObjectIdentifier(candidate)",
              api.retentionIdentityMethodCount == 1,
              api.retentionAcquisitionMethodCount == 0,
              api.retentionReleaseMethodCount == 0,
              api.retentionDescriptorMethodCount == 0,
              api.retentionDeinitMethodCount == 0,
              api.fixedTelemetryAdvisory,
              api.fixedTelemetryOwnerMustRemainLive,
              !api.fixedTelemetryChildLifetimeContinuityEstablished,
              !api.fixedTelemetryMLXDeviceIdentityEstablished,
              !api.fixedTelemetryDurableEvidenceEstablished,
              api.existingCallSiteMigrationCount == 0,
              api.newDarwinImportCount == 0,
              api.newFlockImplementationCount == 0,
              api.newLeaseAcquisitionImplementationCount == 0,
              api.newLeaseReleaseImplementationCount == 0,
              !api.additionalRuntimeWrapperAuthorized,
              !api.secondLeaseOwnershipLifecycleAuthorized,
              api.productionConsumerCount == 0,
              api.typedSeamCurrentlyUnused,
              api.implementationAuthorizedOnlyAfterAuthorityExactMainGreen,
              layerA.exactPreservedSources.count == 8,
              layerA.exactPreservedSources.allSatisfy(validSource),
              layerA.productionFixtureLeaseArgumentCount == 0,
              layerA.productionLeaseRetentionConstructionCount == 0,
              !layerA.newTypedSeamUsedByLayerA,
              !layerA.newTypedSeamReplacesExistingRetention,
              !layerA.newTypedSeamComposesWithExistingRetention,
              !layerA.newTypedSeamMutatesExistingRetention,
              layerA.existingRetentionMustRemainByteIdentical,
              !layerA.layerASourceMutationAuthorized,
              !layerA.leaseContainmentCompositionAuthorized,
              layerA.laterCompositionRequiresSeparateAuthority,
              validSource(b.packageManifest),
              validSource(b.packageLock),
              b.exactPreservedSources.count == 4,
              b.exactPreservedSources.allSatisfy(validSource),
              b.workerInheritedLeaseDescriptorCount == 0,
              b.defaultGatherPathRemainsByteIdentical,
              b.bPathRemainsExplicitOptIn,
              !b.packageManifestMutationAuthorized,
              !b.packageLockMutationAuthorized,
              !b.mlxRevisionMutationAuthorized,
              !b.decoderMutationAuthorized,
              !b.trainingMutationAuthorized,
              !b.comparatorMutationAuthorized,
              !b.existingLeaseReceiptMutationAuthorized,
              !b.neutralAliasAdoptionAuthorized,
              tests.authorityExactTestCount == 1,
              tests.implementationExactTestCount == 1,
              tests.canonicalCodableRequired,
              tests.recursiveValueMutationRequired,
              tests.recursiveNullMutationRequired,
              tests.recursiveRemovalRequired,
              tests.recursiveUnknownFieldRequired,
              tests.arrayReorderMutationRequired,
              tests.noncanonicalEncodingRejectionRequired,
              tests.implementationUsesInMemoryFakeCapabilityOnly,
              tests.leaseAcquisitionInvocationCount == 0,
              tests.processInvocationCount == 0,
              tests.filesystemOperationCount == 0,
              tests.mlxInvocationCount == 0,
              tests.metalInvocationCount == 0,
              documentation.readmePath == "README.md",
              documentation.stage3BlockedSectionStatus
                == "historical_stale_not_terminal_roadmap_authority",
              !documentation.readmeIsTerminalRoadmapAuthority,
              documentation.terminalRoadmapAuthority
                == "append_only_frozen_codable_authority_observation_chain_plus_exact_main_closures",
              documentation.appendOnlyFrozenCodableChainRequired,
              documentation.exactMainClosuresRequired,
              !documentation.readmeMutationAuthorized,
              !documentation.documentationMutationAuthorized,
              documentation.documentationPathCountInAuthorityExactFive == 0,
              scope.authorityExactPathCount == authorityPaths.count,
              scope.authorityExactPathCount == 5,
              authorityPaths.map(\.ordinal) == Array(1 ... 5),
              authorityPaths.map(\.gitStatus) == ["M", "M", "M", "A", "A"],
              scope.implementationExactPathCount == implementationPaths.count,
              scope.implementationExactPathCount == 5,
              implementationPaths.map(\.ordinal) == Array(1 ... 5),
              implementationPaths.map(\.gitStatus)
                == ["M", "M", "M", "A", "A"],
              scope.authoritySourceAndTestAreOnlyAddedPaths,
              scope.implementationSourceAndTestAreOnlyAddedPaths,
              scope.packageManifestMustRemainByteIdentical,
              scope.packageLockMustRemainByteIdentical,
              scope.legacyLeasePairMustRemainByteIdentical,
              scope.layerABytesMustRemainByteIdentical,
              scope.bAndMLXBytesMustRemainByteIdentical,
              scope.canaryLauncherMustRemainByteIdentical,
              scope.canaryLauncherInvocationCount == 0,
              !scope.implementationIncludedInThisPatch,
              scope.implementationAuthorizedOnlyAfterAuthorityExactMainGreen,
              !scope.mechanicsAuthorizedByThisAuthority,
              authorityCeilingFalseClaims.allSatisfy({ !$0 }),
              orderedRequiredSeparateActions.count == 7
        else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityError
                .contractDrift
        }
    }

    public func validateExactV1() throws {
        guard self == Self.frozenV1 else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityError
                .contractDrift
        }
        try validate()
        let canonical = try canonicalData()
        let digest = PrimeSHA256.hexDigest(of: canonical)
        guard Self.canonicalByteCount == canonical.count,
              Self.canonicalSHA256 == digest
        else {
            throw PrimeNeutralResourceLeaseGeneralizationAuthorityError
                .contractDrift
        }
    }

    private var authorityCeilingFalseClaims: [Bool] {
        [
            authorityCeiling.implementationPerformed,
            authorityCeiling.implementationSourceAdded,
            authorityCeiling.leaseAcquisitionAuthorized,
            authorityCeiling.leaseReleaseAuthorized,
            authorityCeiling.leaseReacquisitionAuthorized,
            authorityCeiling.leaseFileCreationAuthorized,
            authorityCeiling.leaseFileMutationAuthorized,
            authorityCeiling.descriptorInspectionAuthorized,
            authorityCeiling.descriptorTransferAuthorized,
            authorityCeiling.workerOwnedAcquisitionAuthorized,
            authorityCeiling.monitorDeathContinuityEstablished,
            authorityCeiling.processExecutionAuthorized,
            authorityCeiling.fixtureExecutionAuthorized,
            authorityCeiling.canaryExecutionAuthorized,
            authorityCeiling.canaryRetryAuthorized,
            authorityCeiling.canaryRerunAuthorized,
            authorityCeiling.canaryRepairAuthorized,
            authorityCeiling.filesystemWriteAuthorized,
            authorityCeiling.networkAuthorized,
            authorityCeiling.layerAMutationAuthorized,
            authorityCeiling.secureChildCompositionAuthorized,
            authorityCeiling.durableTransactionLayerBAuthorized,
            authorityCeiling.durableEvidenceEstablished,
            authorityCeiling.physicalMetalReservationEstablished,
            authorityCeiling.mlxDeviceIdentityEstablished,
            authorityCeiling.mlxExecutionAuthorized,
            authorityCeiling.metalExecutionAuthorized,
            authorityCeiling.native300MExecutionAuthorized,
            authorityCeiling.pythonAuthorized,
            authorityCeiling.cppAuthorized,
            authorityCeiling.checkpointAdmissionGranted,
            authorityCeiling.generalTrainingResumeAuthorized,
            authorityCeiling.modelQualityEstablished,
            authorityCeiling.productUseAuthorized,
            authorityCeiling.publicationAuthorized,
        ]
    }

    private func validSource(_ source: SourceIdentity) -> Bool {
        !source.path.isEmpty
            && source.gitMode == "100644"
            && isLowercaseHex(source.gitBlob, count: 40)
            && source.byteCount > 0
            && source.lfByteCount > 0
            && isLowercaseHex(source.sha256, count: 64)
            && !source.role.isEmpty
    }

    private func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }
}
