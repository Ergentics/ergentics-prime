// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import CoreFoundation
import Foundation
@testable import PrimeCore
import XCTest

final class PrimeNeutralResourceLeaseGeneralizationAuthorityTests: XCTestCase {
    private typealias Authority =
        PrimeNeutralResourceLeaseGeneralizationAuthorityV1

    func testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling()
        throws
    {
        requireSendable(Authority.self)
        let authority = Authority.frozenV1

        XCTAssertEqual(authority.schemaVersion, 1)
        XCTAssertEqual(
            authority.schemaID,
            "prime_neutral_resource_lease_generalization_authority_schema_v1"
        )
        XCTAssertEqual(
            authority.authorityID,
            "prime_neutral_resource_lease_generalization_authority_v1"
        )
        XCTAssertEqual(
            authority.authorityKind,
            "pure_exact5_authority_for_additive_neutral_lease_alias_and_typed_retention_after_closed_canary_retirement"
        )

        let closure = authority.retirementClosure
        XCTAssertEqual(closure.repository, "Ergentics/ergentics-prime")
        XCTAssertEqual(closure.ref, "refs/heads/main")
        XCTAssertEqual(
            closure.mergeRevision,
            "4570716892722873757de6eae1bd897167d674eb"
        )
        XCTAssertEqual(
            closure.mergeTree,
            "29d28080eb945563ca6da7e1e8475189bdce7c11"
        )
        XCTAssertEqual(
            closure.orderedParentRevisions,
            [
                "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6",
                "18ec420a4870657adc0125425a2b26ec41d06ed2",
            ]
        )
        XCTAssertEqual(closure.pullRequestNumber, 123)
        XCTAssertEqual(
            closure.pullRequestBaseRevision,
            "d825c5366135cc6ef8d0c9dc7d26d3d2e4300ba6"
        )
        XCTAssertEqual(
            closure.pullRequestHeadRevision,
            "18ec420a4870657adc0125425a2b26ec41d06ed2"
        )
        XCTAssertEqual(closure.pullRequestHeadTree, closure.mergeTree)
        XCTAssertEqual(closure.pullRequestWorkflowRunID, 31_979_882_205)
        XCTAssertEqual(closure.pullRequestWorkflowRunNumber, 144)
        XCTAssertEqual(closure.pullRequestWorkflowRunAttempt, 1)
        XCTAssertEqual(closure.pullRequestCheckSuiteID, 86_706_120_484)
        XCTAssertEqual(closure.pullRequestActiveRootJobID, 95_244_849_854)
        XCTAssertEqual(closure.pullRequestActiveRootJobConclusion, "success")
        XCTAssertEqual(closure.pullRequestReviewedMainJobID, 95_245_296_697)
        XCTAssertEqual(closure.pullRequestReviewedMainJobConclusion, "skipped")
        XCTAssertEqual(closure.pullRequestReviewedMainJobStepCount, 0)
        XCTAssertEqual(closure.pullRequestActionsArtifactCount, 0)
        XCTAssertTrue(closure.signedMergeVerified)
        XCTAssertEqual(closure.workflowRunID, 31_980_256_444)
        XCTAssertEqual(closure.workflowRunNumber, 145)
        XCTAssertEqual(closure.workflowRunAttempt, 1)
        XCTAssertEqual(closure.checkSuiteID, 86_706_948_013)
        XCTAssertEqual(closure.uniqueExactHeadRunCount, 1)
        XCTAssertTrue(closure.previousAttemptURLWasNull)
        XCTAssertEqual(closure.workflowConclusion, "success")
        XCTAssertEqual(closure.activeRootJobID, 95_245_754_364)
        XCTAssertEqual(closure.activeRootJobConclusion, "success")
        XCTAssertEqual(closure.reviewedMainJobID, 95_246_177_042)
        XCTAssertEqual(closure.reviewedMainJobConclusion, "success")
        XCTAssertEqual(closure.activeLatinTestCount, 116)
        XCTAssertEqual(closure.rootTestCount, 79)
        XCTAssertEqual(closure.isolatedGroupTestCounts, [1, 1, 2, 2])
        XCTAssertEqual(closure.isolatedTestCount, 6)
        XCTAssertEqual(closure.focusedWholeTestCount, 85)
        XCTAssertEqual(closure.retainedLiveTestCount, 46)
        XCTAssertEqual(closure.aggregateTestCount, 131)
        XCTAssertEqual(closure.reviewedFailureCount, 0)
        XCTAssertEqual(closure.reviewedSkipCount, 0)
        XCTAssertEqual(
            closure.observationTestFilter,
            "PrimeCoreTests.PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndRetirementCeiling"
        )
        XCTAssertEqual(closure.observationTestStartCount, 1)
        XCTAssertEqual(closure.observationTestPassCount, 1)
        XCTAssertEqual(closure.observationTestFailureCount, 0)
        XCTAssertEqual(closure.retryCount, 0)
        XCTAssertEqual(closure.rerunCount, 0)
        XCTAssertEqual(closure.actionsArtifactCount, 0)
        XCTAssertEqual(closure.canaryLauncherWorkflowReferenceCount, 0)
        XCTAssertEqual(closure.canaryLauncherInvocationCount, 0)
        XCTAssertEqual(closure.canaryMechanicsInvocationCount, 0)
        XCTAssertEqual(closure.adapterCommandAttemptCount, 0)
        XCTAssertEqual(closure.fixtureProcessExecutionCount, 0)
        XCTAssertEqual(closure.hostedOperationalRecordCount, 0)
        XCTAssertEqual(closure.retirementObservationCanonicalByteCount, 12_604)
        XCTAssertEqual(
            closure.retirementObservationCanonicalSHA256,
            "327a3fedcd1fed6a936aa053c3882c770a106db7e2662e76815a2b5d21333e16"
        )
        assertSource(
            closure.retirementObservationSource,
            path: "Sources/PrimeCore/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservation.swift",
            blob: "bd84b810a1842635b7e874826b7c58cf42baacda",
            bytes: 52_517,
            lines: 1_103,
            sha256: "739eed7ece6ea1b2f952d9f02ad613af15adc100788979a47f0edee4aedbb2f1"
        )
        assertSource(
            closure.retirementObservationTest,
            path: "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceClosedFixtureCanaryPINMismatchExecutionObservationTests.swift",
            blob: "01ee01a48eb24bf25139c01db2b4ec80196712a1",
            bytes: 36_265,
            lines: 811,
            sha256: "bb89e3b5072622d594383143720db99411746766e55cca229cde44724b244671"
        )
        XCTAssertFalse(closure.retirementObservedAtObservationAuthoring)
        XCTAssertTrue(closure.laterExactMainRetirementClosureObserved)
        XCTAssertTrue(closure.exactMainRetirementClosureEstablished)

        let pin = authority.fixturePinBranch
        XCTAssertFalse(pin.investigationRequested)
        XCTAssertTrue(pin.investigationDeferred)
        XCTAssertFalse(pin.investigationAuthorized)
        XCTAssertTrue(pin.requiredBeforeCanaryReopening)
        XCTAssertFalse(pin.requiredBeforeNeutralLeaseAuthority)
        XCTAssertFalse(pin.canaryReopeningAuthorized)
        XCTAssertTrue(pin.distinctNewAuthorityRequired)
        XCTAssertFalse(pin.retiredMechanicsMayBeReused)
        XCTAssertFalse(pin.retryAuthorized)
        XCTAssertFalse(pin.rerunAuthorized)
        XCTAssertFalse(pin.replacementExecutionAuthorized)
        XCTAssertFalse(pin.observedFixtureIdentityAvailable)
        XCTAssertFalse(pin.mismatchDimensionAvailable)

        let legacy = authority.legacyLeaseContract
        assertSource(
            legacy.source,
            path: "Sources/PrimeCore/PrimeMetalDeviceLease.swift",
            blob: "da3daa54802b67dc2c8c04a89b388e9927dd8726",
            bytes: 16_985,
            lines: 534,
            sha256: "edef702776fec36788ebc190d1dc877d13012fda8d1a80ebfdbca32acb998657"
        )
        assertSource(
            legacy.test,
            path: "Tests/PrimeCoreTests/PrimeMetalDeviceLeaseTests.swift",
            blob: "05960c8017147f7a3e1d90fb68d2449bc18698b6",
            bytes: 13_257,
            lines: 451,
            sha256: "ebdcd5d62d0d0915a63e82822ba58dc954e209bcaf7905b663b99a4687670018"
        )
        XCTAssertEqual(legacy.concreteTypeName, "PrimeMetalDeviceLease")
        XCTAssertEqual(legacy.errorTypeName, "PrimeMetalDeviceLeaseError")
        XCTAssertEqual(
            legacy.processCompatibilityAliasName,
            "PrimeExclusiveProcessLease"
        )
        XCTAssertEqual(legacy.mechanism, "darwin_parent_and_leaf_flock")
        XCTAssertEqual(legacy.imports, ["Darwin", "Foundation"])
        XCTAssertEqual(legacy.acquisitionFunction, "acquire(at:)")
        XCTAssertEqual(legacy.releaseFunction, "release()")
        XCTAssertEqual(legacy.localStateProperty, "isHeld")
        XCTAssertEqual(
            legacy.parentDescriptorOpenFlags,
            ["O_RDONLY", "O_DIRECTORY", "O_NOFOLLOW", "O_CLOEXEC"]
        )
        XCTAssertEqual(
            legacy.leafDescriptorOpenFlags,
            ["O_RDWR", "O_CREAT", "O_NOFOLLOW", "O_CLOEXEC"]
        )
        XCTAssertTrue(legacy.parentAndLeafLocksRequired)
        XCTAssertTrue(legacy.acquisitionNonblocking)
        XCTAssertTrue(legacy.finalSymlinkComponentsRejected)
        XCTAssertTrue(legacy.parentAndLeafOwnerValidatedAgainstEffectiveUID)
        XCTAssertTrue(legacy.groupOrOtherWritableParentRejected)
        XCTAssertEqual(legacy.leafModeRequired, "0600")
        XCTAssertEqual(legacy.leafLinkCountRequired, 1)
        XCTAssertTrue(legacy.accessControlListsRejected)
        XCTAssertTrue(legacy.unallowedExtendedAttributesRejected)
        XCTAssertEqual(
            legacy.allowedExtendedAttributeNames,
            ["com.apple.provenance"]
        )
        XCTAssertTrue(legacy.descriptorAndNameRevalidationRequired)
        XCTAssertTrue(legacy.leafCreatedWhenAbsent)
        XCTAssertFalse(legacy.leafUnlinkedByLease)
        XCTAssertFalse(legacy.leafTruncatedByLease)
        XCTAssertFalse(legacy.staleLeafContentsAuthoritative)
        XCTAssertTrue(legacy.releaseIdempotent)
        XCTAssertTrue(legacy.deinitCallsRelease)
        XCTAssertTrue(legacy.descriptorsCloseOnExec)
        XCTAssertFalse(legacy.localStatePropertyIsKernelProof)
        XCTAssertFalse(legacy.physicalResourceReservationEstablished)
        XCTAssertFalse(legacy.mlxDeviceIdentityEstablished)
        XCTAssertFalse(legacy.crossHostOrCrossJobContinuityEstablished)
        XCTAssertTrue(legacy.advisoryCooperatingProcessScopeOnly)
        XCTAssertEqual(legacy.exactExistingTestCount, 10)
        XCTAssertEqual(
            legacy.exactExistingTestMethods,
            [
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
            ]
        )

        let inventory = authority.productionAcquisitionInventory
        XCTAssertEqual(inventory.count, 15)
        XCTAssertEqual(inventory.map(\.ordinal), Array(1 ... 15))
        XCTAssertEqual(
            inventory.map(\.path),
            [
                "Sources/PrimeCore/PrimeValidationSwiftPMBuildInventoryAdmission.swift",
                "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
                "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
                "Sources/PrimeGPUCalibration/PrimeGPUCalibrationMain.swift",
                "Sources/PrimeLeaseHolder/PrimeLeaseHolderMain.swift",
                "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
                "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
                "Sources/PrimeNative3BMetalContinuationProbe/PrimeNative3BMetalContinuationProbeMain.swift",
                "Sources/PrimeNativeDecoderRuntime/PrimeNativeDecoderRuntime.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderNative300MResourceOnlyOneStepProbe.swift",
            ]
        )
        XCTAssertEqual(
            inventory.map(\.acquisitionAPI),
            [
                "PrimeMetalDeviceLease.acquire",
                "PrimeExclusiveProcessLease.acquire",
                "PrimeMetalDeviceLease.acquire",
                "PrimeExclusiveProcessLease.acquire",
                "PrimeExclusiveProcessLease.acquire",
                "PrimeExclusiveProcessLease.acquire",
                "PrimeExclusiveProcessLease.acquire",
                "PrimeMetalDeviceLease.acquire",
                "PrimeMetalDeviceLease.acquire",
                "PrimeMetalDeviceLease.acquire",
                "PrimeMetalDeviceLease.acquire",
                "PrimeMetalDeviceLease.acquire",
                "PrimeMetalDeviceLease.acquire",
                "PrimeMetalDeviceLease.acquire",
                "PrimeMetalDeviceLease.acquire",
            ]
        )
        XCTAssertEqual(
            inventory.map(\.role),
            [
                "swiftpm_build_inventory_admission_scope",
                "calibration_worker_expected_busy_supervisor_authority_probe",
                "calibration_worker_metal_device_lease",
                "calibration_supervisor_artifact_publication_authority",
                "interactive_process_lease_holder",
                "native3b_worker_expected_busy_supervisor_authority_probe",
                "native3b_supervisor_artifact_publication_authority",
                "native3b_supervisor_metal_device_lease",
                "maintained_runtime_metal_device_lease",
                "b_specific_resource_supervisor_metal_device_lease",
                "b_specific_resource_exec_verifier_reacquisition",
                "stage7_trajectory_supervisor_metal_device_lease",
                "stage7_trajectory_exec_verifier_reacquisition",
                "stage6_supervisor_post_worker_reacquisition_proof",
                "stage6_worker_metal_device_lease",
            ]
        )
        XCTAssertEqual(
            inventory.map(\.ownershipPolicy),
            [
                "admission_object_owned", "probe_only", "worker_owned",
                "supervisor_owned", "holder_process_owned", "probe_only",
                "supervisor_owned", "supervisor_owned",
                "runtime_process_owned", "supervisor_owned", "verifier_owned",
                "supervisor_owned", "verifier_owned", "supervisor_probe_owned",
                "worker_owned",
            ]
        )
        XCTAssertTrue(inventory.allSatisfy { $0.staticOccurrenceCount == 1 })
        XCTAssertTrue(
            inventory.allSatisfy { !$0.migrationAuthorizedByThisAuthority }
        )

        let api = authority.neutralAPIContract
        XCTAssertEqual(
            api.implementationSourcePath,
            "Sources/PrimeCore/PrimeExclusiveResourceLease.swift"
        )
        XCTAssertEqual(
            api.implementationTestPath,
            "Tests/PrimeCoreTests/PrimeExclusiveResourceLeaseTests.swift"
        )
        XCTAssertEqual(api.neutralLeaseAlias, "PrimeExclusiveResourceLease")
        XCTAssertEqual(api.neutralErrorAlias, "PrimeExclusiveResourceLeaseError")
        XCTAssertEqual(api.neutralLeaseAliasVisibility, "public")
        XCTAssertEqual(api.neutralErrorAliasVisibility, "public")
        XCTAssertEqual(
            api.neutralLeaseAliasDeclaration,
            "public typealias PrimeExclusiveResourceLease = PrimeMetalDeviceLease"
        )
        XCTAssertEqual(
            api.neutralErrorAliasDeclaration,
            "public typealias PrimeExclusiveResourceLeaseError = PrimeMetalDeviceLeaseError"
        )
        XCTAssertEqual(api.neutralLeaseAliasTarget, legacy.concreteTypeName)
        XCTAssertEqual(api.neutralErrorAliasTarget, legacy.errorTypeName)
        XCTAssertEqual(
            api.internalCapabilityProtocol,
            "PrimeExclusiveResourceLeaseCapability"
        )
        XCTAssertEqual(api.capabilityProtocolComposition, "AnyObject & Sendable")
        XCTAssertEqual(
            api.capabilityProtocolDeclaration,
            "protocol PrimeExclusiveResourceLeaseCapability: AnyObject, Sendable {}"
        )
        XCTAssertEqual(api.capabilityProtocolMethodCount, 0)
        XCTAssertEqual(api.capabilityProtocolPropertyCount, 0)
        XCTAssertTrue(api.legacyLeasePassiveConformanceRequired)
        XCTAssertEqual(
            api.legacyLeasePassiveConformanceDeclaration,
            "extension PrimeMetalDeviceLease: PrimeExclusiveResourceLeaseCapability {}"
        )
        XCTAssertEqual(
            api.internalRetentionType,
            "PrimeExclusiveResourceLeaseRetention"
        )
        XCTAssertEqual(
            api.retentionTypeDeclaration,
            "final class PrimeExclusiveResourceLeaseRetention: Sendable"
        )
        XCTAssertEqual(api.retentionStoredPropertyName, "lease")
        XCTAssertEqual(
            api.retentionStoredPropertyType,
            "any PrimeExclusiveResourceLeaseCapability"
        )
        XCTAssertEqual(api.retentionStorageStrength, "strong")
        XCTAssertEqual(
            api.retentionStoredPropertyDeclaration,
            "private let lease: any PrimeExclusiveResourceLeaseCapability"
        )
        XCTAssertEqual(
            api.retentionInitializerSignature,
            "init(_ lease: any PrimeExclusiveResourceLeaseCapability)"
        )
        XCTAssertEqual(api.retentionInitializerAssignment, "self.lease = lease")
        XCTAssertTrue(api.retentionPreservesObjectIdentity)
        XCTAssertEqual(
            api.retentionIdentityMethodSignature,
            "func retains(_ candidate: any PrimeExclusiveResourceLeaseCapability) -> Bool"
        )
        XCTAssertEqual(
            api.retentionIdentityComparison,
            "ObjectIdentifier(lease) == ObjectIdentifier(candidate)"
        )
        XCTAssertEqual(api.retentionIdentityMethodCount, 1)
        XCTAssertEqual(api.retentionAcquisitionMethodCount, 0)
        XCTAssertEqual(api.retentionReleaseMethodCount, 0)
        XCTAssertEqual(api.retentionDescriptorMethodCount, 0)
        XCTAssertEqual(api.retentionDeinitMethodCount, 0)
        XCTAssertEqual(api.capabilityProtocolVisibility, "internal_closed_marker")
        XCTAssertEqual(api.retentionTypeVisibility, "internal")
        XCTAssertEqual(
            api.compatibilityStrategy,
            "additive_alias_first_no_existing_callsite_migration"
        )
        XCTAssertEqual(api.fixedTelemetryScope, "cooperating_host_path_local")
        XCTAssertTrue(api.fixedTelemetryAdvisory)
        XCTAssertTrue(api.fixedTelemetryOwnerMustRemainLive)
        XCTAssertFalse(api.fixedTelemetryChildLifetimeContinuityEstablished)
        XCTAssertFalse(api.fixedTelemetryMLXDeviceIdentityEstablished)
        XCTAssertFalse(api.fixedTelemetryDurableEvidenceEstablished)
        XCTAssertTrue(api.legacyConcreteTypeRemainsAvailable)
        XCTAssertTrue(api.legacyErrorTypeRemainsAvailable)
        XCTAssertTrue(api.processCompatibilityAliasRemainsAvailable)
        XCTAssertEqual(api.existingCallSiteMigrationCount, 0)
        XCTAssertEqual(api.newDarwinImportCount, 0)
        XCTAssertEqual(api.newFlockImplementationCount, 0)
        XCTAssertEqual(api.newLeaseAcquisitionImplementationCount, 0)
        XCTAssertEqual(api.newLeaseReleaseImplementationCount, 0)
        XCTAssertFalse(api.additionalRuntimeWrapperAuthorized)
        XCTAssertFalse(api.secondLeaseOwnershipLifecycleAuthorized)
        XCTAssertFalse(api.arbitraryResourceIdentifierAuthorized)
        XCTAssertFalse(api.genericCallerTelemetryAuthorized)
        XCTAssertEqual(api.productionConsumerCount, 0)
        XCTAssertTrue(api.typedSeamCurrentlyUnused)
        XCTAssertTrue(api.implementationAuthorizedOnlyAfterAuthorityExactMainGreen)

        let layerA = authority.layerABoundary
        XCTAssertEqual(layerA.exactPreservedSources.count, 8)
        XCTAssertEqual(
            layerA.exactPreservedSources.map(\.path),
            [
                "Sources/PrimeCore/PrimeSecureChildProcessPlan.swift",
                "Sources/PrimeCore/PrimeSecureChildProcessEvidence.swift",
                "Sources/PrimeCore/PrimeTrustedSecureChildProcessCapture.swift",
                "Sources/PrimeCore/PrimeSecureChildExecutionKernel.swift",
                "Sources/PrimeCore/PrimeSecureChildDrains.swift",
                "Sources/PrimeCore/PrimeSecureChildSupervision.swift",
                "Sources/PrimeCore/PrimeSecureChildKernel.swift",
                "Tests/PrimeCoreTests/PrimeSecureChildProcessEvidenceTests.swift",
            ]
        )
        XCTAssertEqual(
            layerA.exactPreservedSources.map(\.gitBlob),
            [
                "f9bc922c90ad7b6ed5d8f28b2f0b6f5085043281",
                "7ffa7711943e485f98e98ae8a862efb12f8a4516",
                "a289898d4b0239728bd882d14948d0ab01e91766",
                "616af54193830c897c634500ce294b827a3d9e22",
                "6579b9a08dea19b7c4d4654ec3b9735d3cc0d8b4",
                "13d882363479143d2a207375ac3eb84971fabb35",
                "bfa381796b9647863e704006dbaa1406c533c7c5",
                "d612316fe0fbe9c835331a3f8fcae4477064bd73",
            ]
        )
        XCTAssertEqual(
            layerA.exactPreservedSources.map(\.byteCount),
            [5_440, 38_655, 5_499, 11_167, 17_440, 24_830, 83_657, 45_527]
        )
        XCTAssertEqual(
            layerA.exactPreservedSources.map(\.lfByteCount),
            [148, 1_040, 167, 303, 609, 842, 2_327, 1_260]
        )
        XCTAssertEqual(layerA.existingRetentionType, "PrimeSecureChildLeaseRetention")
        XCTAssertTrue(layerA.existingRetentionAcceptsOpaqueAnyObject)
        XCTAssertEqual(layerA.existingTelemetryScope, "cooperating_host_path_local")
        XCTAssertFalse(layerA.existingTelemetryClaimsContinuity)
        XCTAssertFalse(layerA.existingTelemetryClaimsMLXIdentity)
        XCTAssertFalse(layerA.existingTelemetryClaimsDurability)
        XCTAssertEqual(layerA.productionFixtureLeaseArgumentCount, 0)
        XCTAssertEqual(layerA.productionLeaseRetentionConstructionCount, 0)
        XCTAssertFalse(layerA.newTypedSeamUsedByLayerA)
        XCTAssertFalse(layerA.newTypedSeamReplacesExistingRetention)
        XCTAssertFalse(layerA.newTypedSeamComposesWithExistingRetention)
        XCTAssertFalse(layerA.newTypedSeamMutatesExistingRetention)
        XCTAssertTrue(layerA.existingRetentionMustRemainByteIdentical)
        XCTAssertFalse(layerA.layerASourceMutationAuthorized)
        XCTAssertFalse(layerA.fixtureAPIMutationAuthorized)
        XCTAssertFalse(layerA.processSubstrateMutationAuthorized)
        XCTAssertFalse(layerA.leaseContainmentCompositionAuthorized)
        XCTAssertTrue(layerA.laterCompositionRequiresSeparateAuthority)

        let b = authority.bMLXPreservationBoundary
        assertSource(
            b.packageManifest,
            path: "Package.swift",
            blob: "8e14c10aded588b3902a042341bca7acc842bcc6",
            bytes: 32_843,
            lines: 934,
            sha256: "fa68f463ca31a4ca25af6b14eb19b139df0c8ef8259a6348bb40e97c2dcdeb81"
        )
        assertSource(
            b.packageLock,
            path: "Package.resolved",
            blob: "14d804bb4291720477240c27e24de6fbdc876b3b",
            bytes: 645,
            lines: 23,
            sha256: "bd7a18ec5b8def3b453d7eb86ba43a2f277c2308c9da806845b69ca5f76cd375"
        )
        XCTAssertEqual(
            b.exactMLXRevision,
            "d37885a278f1c37484a94d0f401a418735e66519"
        )
        XCTAssertEqual(
            b.exactMLXOrigin,
            "https://github.com/Ergentics/ergentics-mlx-swift"
        )
        XCTAssertEqual(b.exactPreservedSources.count, 4)
        XCTAssertEqual(
            b.exactPreservedSources.map(\.path),
            [
                "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderTraining.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MResourceWitness.swift",
                "Sources/PrimeNativeDecoderTraining/PrimeNativeDecoderBSpecificNative300MTrajectoryCheckpointExecution.swift",
            ]
        )
        XCTAssertEqual(
            b.exactPreservedSources.map(\.gitBlob),
            [
                "de6cff4472de55a8fafe2962c3be4ca37c972caf",
                "4566477e14b4b6cfa06286f384f07f8d452e8724",
                "cf3d743d121f4eaa028e0e392e04587bcd0b93d8",
                "939b949cd86741e98cdb389863f1b9378107b78f",
            ]
        )
        XCTAssertEqual(
            b.exactPreservedSources.map(\.byteCount),
            [43_339, 97_449, 225_960, 311_307]
        )
        XCTAssertEqual(
            b.exactPreservedSources.map(\.lfByteCount),
            [1_193, 2_444, 5_233, 7_129]
        )
        XCTAssertEqual(
            b.bPathAlgorithmID,
            "prime_native_decoder_flattened_dense_one_hot_matmul_input_embedding_v1"
        )
        XCTAssertEqual(
            b.bPathSelectorRawValue,
            "flattened_dense_one_hot_matmul_input_embedding_v1"
        )
        XCTAssertEqual(
            b.bPathTrainingLogitsAPI,
            "PrimeNativeGQADecoder.trainingLogitsNoCacheFlattenedDenseOneHotMatmulInputEmbeddingV1"
        )
        XCTAssertEqual(
            b.maintainedGatherTrainingLogitsAPI,
            "PrimeNativeGQADecoder.trainingLogitsNoCache"
        )
        XCTAssertEqual(b.leaseReceiptTypeName, legacy.concreteTypeName)
        XCTAssertTrue(b.supervisorOwnsLease)
        XCTAssertEqual(b.workerInheritedLeaseDescriptorCount, 0)
        XCTAssertTrue(b.distinctExecVerifierReacquiresAndReleases)
        XCTAssertTrue(b.defaultGatherPathRemainsByteIdentical)
        XCTAssertTrue(b.bPathRemainsExplicitOptIn)
        XCTAssertTrue(bFalseClaims(b).allSatisfy { !$0 })

        let tests = authority.testBoundary
        XCTAssertEqual(
            tests.authorityTestPath,
            "Tests/PrimeCoreTests/PrimeNeutralResourceLeaseGeneralizationAuthorityTests.swift"
        )
        XCTAssertEqual(
            tests.authorityTestClassName,
            "PrimeNeutralResourceLeaseGeneralizationAuthorityTests"
        )
        XCTAssertEqual(
            tests.authorityTestMethodName,
            "testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling"
        )
        XCTAssertEqual(
            tests.authorityTestFilter,
            "PrimeCoreTests.PrimeNeutralResourceLeaseGeneralizationAuthorityTests/testFrozenV1CanonicalCodableExhaustiveRecursiveMutationAndAuthorityCeiling"
        )
        XCTAssertEqual(tests.authorityExactTestCount, 1)
        XCTAssertEqual(
            tests.implementationTestPath,
            "Tests/PrimeCoreTests/PrimeExclusiveResourceLeaseTests.swift"
        )
        XCTAssertEqual(tests.implementationTestClassName, "PrimeExclusiveResourceLeaseTests")
        XCTAssertEqual(
            tests.implementationTestMethodName,
            "testAliasesAndTypedRetentionRemainPureAndTruthful"
        )
        XCTAssertEqual(tests.implementationExactTestCount, 1)
        XCTAssertTrue(tests.canonicalCodableRequired)
        XCTAssertTrue(tests.recursiveValueMutationRequired)
        XCTAssertTrue(tests.recursiveNullMutationRequired)
        XCTAssertTrue(tests.recursiveRemovalRequired)
        XCTAssertTrue(tests.recursiveUnknownFieldRequired)
        XCTAssertTrue(tests.arrayReorderMutationRequired)
        XCTAssertTrue(tests.noncanonicalEncodingRejectionRequired)
        XCTAssertTrue(tests.implementationUsesInMemoryFakeCapabilityOnly)
        XCTAssertEqual(tests.leaseAcquisitionInvocationCount, 0)
        XCTAssertEqual(tests.processInvocationCount, 0)
        XCTAssertEqual(tests.filesystemOperationCount, 0)
        XCTAssertEqual(tests.mlxInvocationCount, 0)
        XCTAssertEqual(tests.metalInvocationCount, 0)

        let documentation = authority.documentationBoundary
        XCTAssertEqual(documentation.readmePath, "README.md")
        XCTAssertEqual(
            documentation.stage3BlockedSectionStatus,
            "historical_stale_not_terminal_roadmap_authority"
        )
        XCTAssertFalse(documentation.readmeIsTerminalRoadmapAuthority)
        XCTAssertEqual(
            documentation.terminalRoadmapAuthority,
            "append_only_frozen_codable_authority_observation_chain_plus_exact_main_closures"
        )
        XCTAssertTrue(documentation.appendOnlyFrozenCodableChainRequired)
        XCTAssertTrue(documentation.exactMainClosuresRequired)
        XCTAssertFalse(documentation.readmeMutationAuthorized)
        XCTAssertFalse(documentation.documentationMutationAuthorized)
        XCTAssertEqual(documentation.documentationPathCountInAuthorityExactFive, 0)

        let scope = authority.scope
        assertExactFive(
            scope.authorityExactOrderedPaths,
            addedSource: "Sources/PrimeCore/PrimeNeutralResourceLeaseGeneralizationAuthority.swift",
            addedTest: "Tests/PrimeCoreTests/PrimeNeutralResourceLeaseGeneralizationAuthorityTests.swift"
        )
        XCTAssertEqual(scope.authorityExactPathCount, 5)
        assertExactFive(
            scope.implementationExactOrderedPaths,
            addedSource: "Sources/PrimeCore/PrimeExclusiveResourceLease.swift",
            addedTest: "Tests/PrimeCoreTests/PrimeExclusiveResourceLeaseTests.swift"
        )
        XCTAssertEqual(scope.implementationExactPathCount, 5)
        XCTAssertTrue(scope.authoritySourceAndTestAreOnlyAddedPaths)
        XCTAssertTrue(scope.implementationSourceAndTestAreOnlyAddedPaths)
        XCTAssertTrue(scope.packageManifestMustRemainByteIdentical)
        XCTAssertTrue(scope.packageLockMustRemainByteIdentical)
        XCTAssertTrue(scope.legacyLeasePairMustRemainByteIdentical)
        XCTAssertTrue(scope.layerABytesMustRemainByteIdentical)
        XCTAssertTrue(scope.bAndMLXBytesMustRemainByteIdentical)
        XCTAssertTrue(scope.canaryLauncherMustRemainByteIdentical)
        XCTAssertEqual(scope.canaryLauncherInvocationCount, 0)
        XCTAssertFalse(scope.implementationIncludedInThisPatch)
        XCTAssertTrue(scope.implementationAuthorizedOnlyAfterAuthorityExactMainGreen)
        XCTAssertFalse(scope.mechanicsAuthorizedByThisAuthority)

        XCTAssertTrue(authorityFalseClaims(authority.authorityCeiling).allSatisfy { !$0 })
        XCTAssertEqual(
            authority.orderedRequiredSeparateActions,
            [
                "merge_and_close_this_pure_exact5_neutral_resource_lease_generalization_authority",
                "separately_implement_only_the_additive_exact5_neutral_alias_and_typed_retention",
                "close_the_implementation_on_exact_main_without_lease_or_process_execution",
                "separately_authorize_monitor_held_lease_and_secure_containment_composition",
                "separately_authorize_durable_transaction_layer_b",
                "separately_authorize_lease_containment_and_durability_transactional_composition",
                "only_then_review_any_mlx_metal_native300_or_cpp_adapter",
            ]
        )
        XCTAssertEqual(
            authority.status,
            "AUTHORITY_ONLY_neutral_resource_lease_alias_and_typed_retention_exact5_no_implementation_no_mechanics_legacy_b_mlx_layer_a_preserved"
        )

        let canonical = try authority.canonicalData()
        XCTAssertEqual(canonical, try PrimeCanonicalJSON.encode(authority))
        XCTAssertEqual(canonical.count, Authority.canonicalByteCount)
        XCTAssertEqual(
            PrimeSHA256.hexDigest(of: canonical),
            Authority.canonicalSHA256
        )
        XCTAssertNoThrow(try authority.validate())
        XCTAssertNoThrow(try authority.validateExactV1())
        let decoded = try Authority.decodeCanonical(canonical)
        XCTAssertEqual(decoded, authority)
        XCTAssertEqual(try decoded.canonicalData(), canonical)
        XCTAssertNoThrow(try decoded.validateExactV1())

        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: canonical) as? [String: Any]
        )
        let parentsPath: JSONPath = [
            .key("retirementClosure"),
            .key("orderedParentRevisions"),
        ]
        let malformedParentArrays: [[Any]] = [
            [],
            [closure.pullRequestBaseRevision],
        ]
        for malformedParents in malformedParentArrays {
            let malformedObject = replacingValue(
                in: object,
                at: parentsPath,
                with: { _ in malformedParents }
            )
            let malformedData = try JSONSerialization.data(
                withJSONObject: malformedObject,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )
            let malformed = try JSONDecoder().decode(
                Authority.self,
                from: malformedData
            )
            XCTAssertThrowsError(try malformed.validate())
            XCTAssertThrowsError(try malformed.validateExactV1())
        }

        let overflowPairs: [(JSONPath, JSONPath)] = [
            (
                [.key("retirementClosure"), .key("rootTestCount")],
                [.key("retirementClosure"), .key("isolatedTestCount")]
            ),
            (
                [.key("retirementClosure"), .key("focusedWholeTestCount")],
                [.key("retirementClosure"), .key("retainedLiveTestCount")]
            ),
        ]
        for (maximumPath, incrementPath) in overflowPairs {
            let maximumObject = replacingValue(
                in: object,
                at: maximumPath,
                with: { _ in NSNumber(value: Int.max) }
            )
            let overflowObject = replacingValue(
                in: maximumObject,
                at: incrementPath,
                with: { _ in NSNumber(value: 1) }
            )
            let overflowData = try JSONSerialization.data(
                withJSONObject: overflowObject,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )
            let malformed = try JSONDecoder().decode(
                Authority.self,
                from: overflowData
            )
            XCTAssertThrowsError(try malformed.validate())
            XCTAssertThrowsError(try malformed.validateExactV1())
        }

        let valuePaths = allValuePaths(in: object)
        let dictionaryPaths = allDictionaryPaths(in: object)
        let scalarPaths = allScalarPaths(in: object)
        XCTAssertGreaterThan(valuePaths.count, 250)
        XCTAssertGreaterThan(dictionaryPaths.count, 20)
        XCTAssertGreaterThan(scalarPaths.count, 200)

        var regularDecodedDriftCount = 0
        for path in valuePaths {
            let mutationData = try assertCanonicalRejects(
                replacingValue(in: object, at: path, with: mutateJSONValue),
                label: "mutated \(pathLabel(path))"
            )
            if assertLooseDecodedDriftRejects(
                mutationData,
                comparedTo: authority
            ) {
                regularDecodedDriftCount += 1
            }
            let nullData = try assertCanonicalRejects(
                replacingValue(
                    in: object,
                    at: path,
                    with: { value in
                        if value is NSNull { return "__null_mutation" }
                        return NSNull()
                    }
                ),
                label: "null \(pathLabel(path))"
            )
            _ = assertLooseDecodedDriftRejects(
                nullData,
                comparedTo: authority
            )
            let removedData = try assertCanonicalRejects(
                removingValue(in: object, at: path),
                label: "removed \(pathLabel(path))"
            )
            _ = assertLooseDecodedDriftRejects(
                removedData,
                comparedTo: authority
            )
        }
        XCTAssertGreaterThan(regularDecodedDriftCount, 200)

        let arrayPaths = allArrayPaths(in: object)
        var reorderedArrayCount = 0
        for path in arrayPaths {
            var didReorder = false
            let reordered = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var array = value as! [Any]
                    guard array.count >= 2 else { return array }
                    for left in 0 ..< array.count {
                        for right in (left + 1) ..< array.count {
                            if canonicalJSONFragment(array[left])
                                != canonicalJSONFragment(array[right])
                            {
                                array.swapAt(left, right)
                                didReorder = true
                                return array
                            }
                        }
                    }
                    return array
                }
            )
            if didReorder {
                let reorderedData = try assertCanonicalRejects(
                    reordered,
                    label: "reordered array at \(pathLabel(path))"
                )
                XCTAssertTrue(
                    assertLooseDecodedDriftRejects(
                        reorderedData,
                        comparedTo: authority
                    )
                )
                reorderedArrayCount += 1
            }
        }
        XCTAssertGreaterThan(reorderedArrayCount, 10)

        for (index, path) in dictionaryPaths.enumerated() {
            let unknown = replacingValue(
                in: object,
                at: path,
                with: { value in
                    var dictionary = value as! [String: Any]
                    dictionary["unknown_neutral_lease_field_\(index)"] = true
                    return dictionary
                }
            )
            let unknownData = try assertCanonicalRejects(
                unknown,
                label: "unknown field at \(pathLabel(path))"
            )
            let loose = try JSONDecoder().decode(Authority.self, from: unknownData)
            XCTAssertEqual(loose, authority)
        }

        try assertNoncanonicalEncodingsReject(canonical, object: object)
    }

    private enum JSONPathComponent: Equatable {
        case key(String)
        case index(Int)

        var label: String {
            switch self {
            case let .key(key): return key
            case let .index(index): return "[\(index)]"
            }
        }
    }

    private typealias JSONPath = [JSONPathComponent]

    private func pathLabel(_ path: JSONPath) -> String {
        path.isEmpty ? "<root>" : path.map(\.label).joined(separator: ".")
    }

    private func allValuePaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                let path = prefix + [.key(key)]
                return [path] + allValuePaths(in: object[key]!, prefix: path)
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                let path = prefix + [.index(index)]
                return [path] + allValuePaths(in: array[index], prefix: path)
            }
        }
        return []
    }

    private func allDictionaryPaths(
        in value: Any,
        prefix: JSONPath = []
    ) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return [prefix] + object.keys.sorted().flatMap { key in
                allDictionaryPaths(
                    in: object[key]!,
                    prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allDictionaryPaths(
                    in: array[index],
                    prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allArrayPaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allArrayPaths(in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return [prefix] + array.indices.flatMap { index in
                allArrayPaths(in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return []
    }

    private func allScalarPaths(in value: Any, prefix: JSONPath = []) -> [JSONPath] {
        if let object = value as? [String: Any] {
            return object.keys.sorted().flatMap { key in
                allScalarPaths(in: object[key]!, prefix: prefix + [.key(key)])
            }
        }
        if let array = value as? [Any] {
            return array.indices.flatMap { index in
                allScalarPaths(in: array[index], prefix: prefix + [.index(index)])
            }
        }
        return [prefix]
    }

    private func replacingValue(
        in value: Any,
        at path: JSONPath,
        with transform: (Any) -> Any
    ) -> Any {
        guard let component = path.first else { return transform(value) }
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            object[key] = replacingValue(
                in: object[key]!,
                at: remainder,
                with: transform)
            return object
        case let .index(index):
            var array = value as! [Any]
            array[index] = replacingValue(
                in: array[index],
                at: remainder,
                with: transform)
            return array
        }
    }

    private func removingValue(in value: Any, at path: JSONPath) -> Any {
        precondition(!path.isEmpty)
        let component = path[0]
        let remainder = Array(path.dropFirst())
        switch component {
        case let .key(key):
            var object = value as! [String: Any]
            if remainder.isEmpty {
                object.removeValue(forKey: key)
            } else {
                object[key] = removingValue(in: object[key]!, at: remainder)
            }
            return object
        case let .index(index):
            var array = value as! [Any]
            if remainder.isEmpty {
                array.remove(at: index)
            } else {
                array[index] = removingValue(in: array[index], at: remainder)
            }
            return array
        }
    }

    private func canonicalJSONFragment(_ value: Any) -> Data {
        (try? JSONSerialization.data(
            withJSONObject: [value],
            options: [.sortedKeys, .withoutEscapingSlashes]
        )) ?? Data()
    }

    private func mutateJSONValue(_ value: Any) -> Any {
        if value is NSNull { return "__was_null_mutation" }
        if let string = value as? String { return string + "__mutation" }
        if let number = value as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return !number.boolValue
            }
            return NSNumber(value: number.int64Value + 1)
        }
        if var array = value as? [Any] {
            array.append(array.first ?? "__mutation")
            return array
        }
        if var object = value as? [String: Any] {
            object["unknown_recursive_mutation"] = true
            return object
        }
        XCTFail("unsupported canonical JSON value: \(value)")
        return value
    }

    @discardableResult
    private func assertCanonicalRejects(
        _ object: Any,
        label: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> Data {
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertThrowsError(
            try Authority.decodeCanonical(data),
            label,
            file: file,
            line: line
        )
        return data
    }

    @discardableResult
    private func assertLooseDecodedDriftRejects(
        _ data: Data,
        comparedTo authority: Authority,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Bool {
        guard let loose = try? JSONDecoder().decode(Authority.self, from: data),
              loose != authority
        else {
            return false
        }
        XCTAssertThrowsError(try loose.validate(), file: file, line: line)
        XCTAssertThrowsError(try loose.validateExactV1(), file: file, line: line)
        return true
    }

    private func assertNoncanonicalEncodingsReject(
        _ canonical: Data,
        object: [String: Any]
    ) throws {
        var prefixed = Data([0x20])
        prefixed.append(canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(prefixed))

        var suffixed = canonical
        suffixed.append(0x0A)
        XCTAssertThrowsError(try Authority.decodeCanonical(suffixed))

        let pretty = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        XCTAssertNotEqual(pretty, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(pretty))

        var slashEscaped = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let slashIndex = try XCTUnwrap(slashEscaped.firstIndex(of: "/"))
        slashEscaped.replaceSubrange(slashIndex ... slashIndex, with: "\\/")
        let slashEscapedData = try XCTUnwrap(slashEscaped.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(slashEscapedData))

        var reordered = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let schemaField = "\"schemaVersion\":1,"
        let schemaRange = try XCTUnwrap(reordered.range(of: schemaField))
        reordered.removeSubrange(schemaRange)
        let openingBrace = try XCTUnwrap(reordered.firstIndex(of: "{"))
        reordered.insert(
            contentsOf: schemaField,
            at: reordered.index(after: openingBrace))
        let reorderedData = try XCTUnwrap(reordered.data(using: .utf8))
        XCTAssertNotEqual(reorderedData, canonical)
        XCTAssertThrowsError(try Authority.decodeCanonical(reorderedData))

        var duplicate = try XCTUnwrap(String(data: canonical, encoding: .utf8))
        let duplicateOpening = try XCTUnwrap(duplicate.firstIndex(of: "{"))
        duplicate.insert(
            contentsOf: schemaField,
            at: duplicate.index(after: duplicateOpening))
        let duplicateData = try XCTUnwrap(duplicate.data(using: .utf8))
        XCTAssertThrowsError(try Authority.decodeCanonical(duplicateData))
    }

    private func assertSource(
        _ source: Authority.SourceIdentity,
        path: String,
        blob: String,
        bytes: Int,
        lines: Int,
        sha256: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(source.path, path, file: file, line: line)
        XCTAssertEqual(source.gitMode, "100644", file: file, line: line)
        XCTAssertEqual(source.gitBlob, blob, file: file, line: line)
        XCTAssertEqual(source.byteCount, bytes, file: file, line: line)
        XCTAssertEqual(source.lfByteCount, lines, file: file, line: line)
        XCTAssertEqual(source.sha256, sha256, file: file, line: line)
        XCTAssertFalse(source.role.isEmpty, file: file, line: line)
        XCTAssertTrue(
            isLowercaseHex(source.gitBlob, count: 40),
            file: file,
            line: line
        )
        XCTAssertTrue(
            isLowercaseHex(source.sha256, count: 64),
            file: file,
            line: line
        )
    }

    private func assertExactFive(
        _ paths: [Authority.PathContract],
        addedSource: String,
        addedTest: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(paths.count, 5, file: file, line: line)
        XCTAssertEqual(paths.map(\.ordinal), Array(1 ... 5), file: file, line: line)
        XCTAssertEqual(
            paths.map(\.path),
            [
                ".github/scripts/prime-ci-active-root-quarantine.sh",
                ".github/workflows/prime-active-root-quarantine.yml",
                "Sources/PrimeCore/PrimeEmbeddedBuildProvenance.swift",
                addedSource,
                addedTest,
            ],
            file: file,
            line: line
        )
        XCTAssertEqual(
            paths.map(\.gitStatus),
            ["M", "M", "M", "A", "A"],
            file: file,
            line: line
        )
        XCTAssertEqual(
            paths.map(\.gitMode),
            ["100755", "100644", "100644", "100644", "100644"],
            file: file,
            line: line
        )
        XCTAssertEqual(Set(paths.map(\.path)).count, 5, file: file, line: line)
        XCTAssertTrue(
            paths.allSatisfy { !$0.role.isEmpty },
            file: file,
            line: line
        )
    }

    private func bFalseClaims(
        _ boundary: Authority.BMLXPreservationBoundary
    ) -> [Bool] {
        [
            boundary.packageManifestMutationAuthorized,
            boundary.packageLockMutationAuthorized,
            boundary.mlxRevisionMutationAuthorized,
            boundary.decoderMutationAuthorized,
            boundary.trainingMutationAuthorized,
            boundary.comparatorMutationAuthorized,
            boundary.existingLeaseReceiptMutationAuthorized,
            boundary.neutralAliasAdoptionAuthorized,
        ]
    }

    private func authorityFalseClaims(
        _ ceiling: Authority.AuthorityCeiling
    ) -> [Bool] {
        [
            ceiling.implementationPerformed,
            ceiling.implementationSourceAdded,
            ceiling.leaseAcquisitionAuthorized,
            ceiling.leaseReleaseAuthorized,
            ceiling.leaseReacquisitionAuthorized,
            ceiling.leaseFileCreationAuthorized,
            ceiling.leaseFileMutationAuthorized,
            ceiling.descriptorInspectionAuthorized,
            ceiling.descriptorTransferAuthorized,
            ceiling.workerOwnedAcquisitionAuthorized,
            ceiling.monitorDeathContinuityEstablished,
            ceiling.processExecutionAuthorized,
            ceiling.fixtureExecutionAuthorized,
            ceiling.canaryExecutionAuthorized,
            ceiling.canaryRetryAuthorized,
            ceiling.canaryRerunAuthorized,
            ceiling.canaryRepairAuthorized,
            ceiling.filesystemWriteAuthorized,
            ceiling.networkAuthorized,
            ceiling.layerAMutationAuthorized,
            ceiling.secureChildCompositionAuthorized,
            ceiling.durableTransactionLayerBAuthorized,
            ceiling.durableEvidenceEstablished,
            ceiling.physicalMetalReservationEstablished,
            ceiling.mlxDeviceIdentityEstablished,
            ceiling.mlxExecutionAuthorized,
            ceiling.metalExecutionAuthorized,
            ceiling.native300MExecutionAuthorized,
            ceiling.pythonAuthorized,
            ceiling.cppAuthorized,
            ceiling.checkpointAdmissionGranted,
            ceiling.generalTrainingResumeAuthorized,
            ceiling.modelQualityEstablished,
            ceiling.productUseAuthorized,
            ceiling.publicationAuthorized,
        ]
    }

    private func isLowercaseHex(_ value: String, count: Int) -> Bool {
        value.utf8.count == count
            && value.unicodeScalars.allSatisfy {
                ($0.value >= 48 && $0.value <= 57)
                    || ($0.value >= 97 && $0.value <= 102)
            }
    }

    private func requireSendable<T: Sendable>(_: T.Type) {}
}
