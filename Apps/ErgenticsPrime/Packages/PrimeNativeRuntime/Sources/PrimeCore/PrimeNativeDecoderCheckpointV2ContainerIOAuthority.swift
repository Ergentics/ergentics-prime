// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderCheckpointV2ContainerIOAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// An exact source identity bound by this authority.
public struct PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1:
    Codable,
    Equatable,
    Sendable
{
    public let path: String
    public let gitMode: String
    public let gitBlob: String
    public let byteCount: Int
    public let sha256: String

    fileprivate func validate() throws {
        guard !path.isEmpty,
              !path.hasPrefix("/"),
              gitMode == "100644" || gitMode == "100755",
              isCheckpointV2ContainerIOLowercaseHex(
                  gitBlob,
                  count: 40),
              byteCount > 0,
              isCheckpointV2ContainerIOLowercaseHex(
                  sha256,
                  count: 64)
        else {
            throw PrimeNativeDecoderCheckpointV2ContainerIOAuthorityError
                .contractDrift
        }
    }
}

/// Append-only design authority for the repaired decoder's V2 weights-only
/// checkpoint manifest, external binding, codec, and artifact-root-backed I/O.
///
/// This record authorizes the separately materialized implementation and one
/// isolated declarative validation lane. Successful validation is not
/// evidence that a Native-300M write or load executed, checkpoint bytes were
/// retained, artifact provenance was established, or a checkpoint was
/// admitted for runtime or product use.
public struct PrimeNativeDecoderCheckpointV2ContainerIOAuthorityPlanV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let authorityKind: String
    public let predecessorObservationID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorRequiredForConsumption: Bool

    public let authoritativeRepository: String
    public let baseRef: String
    public let baseRevision: String
    public let baseOrderedParentRevisions: [String]
    public let baseTree: String
    public let baseEmbeddedSourceIdentitySHA256: String
    public let basePullRequestNumber: Int
    public let baseHistoryPreservingTwoParentMerge: Bool

    public let predecessorObservationSource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let checkpointV1AuthoritySource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let checkpointV1Source:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let checkpointV2IdentityAuthoritySource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let checkpointV2IdentitySource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let repairedDecoderSource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let durableArtifactCapabilitySource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let rootPackageManifestSource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let rootPackageResolvedSource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let baseActiveRootGateSource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let baseTrustedWorkflowSource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1

    public let exactMLXRepository: String
    public let exactMLXRevision: String
    public let mlxDescriptorIOPath: String
    public let mlxDescriptorIOGitMode: String
    public let mlxDescriptorIOGitBlob: String
    public let mlxDescriptorIOByteCount: Int
    public let mlxDescriptorIOSHA256: String

    public let authoritativeProduct: String
    public let authoritativeTarget: String
    public let authoritativeTargetDependencies: [String]
    public let implementationSourcePath: String
    public let implementationSourceExpectedGitMode: String
    public let implementationSourceIdentityStatus: String
    public let implementationSourceGitBlob: String?
    public let implementationSourceByteCount: Int?
    public let implementationSourceSHA256: String?
    public let validationPackagePath: String
    public let validationPackageManifestPath: String
    public let validationPackageResolvedPath: String
    public let validationPackageManifestSource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let validationPackageResolvedSource:
        PrimeNativeDecoderCheckpointV2ContainerIOPinnedSourceV1
    public let validationTestSourcePath: String
    public let validationTestSourceExpectedGitMode: String
    public let validationTestSourceIdentityStatus: String
    public let validationTestSourceGitBlob: String?
    public let validationTestSourceByteCount: Int?
    public let validationTestSourceSHA256: String?

    public let publicManifestType: String
    public let publicExternalBindingType: String
    public let publicErrorType: String
    public let publicCodecType: String
    public let publicTensorBindingType: String
    public let publicWriteDeclaration: String
    public let publicLoadDeclaration: String
    public let publicWriteRootParameterType: String
    public let publicLoadRootParameterType: String
    public let publicArtifactNameArgumentScope: String
    public let publicRawPathAPIAuthorized: Bool
    public let publicRawDescriptorAPIAuthorized: Bool
    public let publicDiscoverAndTrustAPIAuthorized: Bool
    public let publicInPlaceMutationAPIAuthorized: Bool
    public let publicReplacementAPIAuthorized: Bool

    public let manifestSchemaVersion: Int
    public let manifestSchemaID: String
    public let externalBindingSchema: String
    public let checkpointArtifactKind: String
    public let checkpointFormat: String
    public let stateScope: String
    public let logicalTensorHashAlgorithm: String
    public let logicalTensorByteEncoding: String
    public let manifestMetadataKey: String
    public let manifestSHA256MetadataKey: String
    public let metadataKeySetIsExact: Bool
    public let manifestContainerSelfHashForbidden: Bool
    public let wholeContainerHashMustComeFromExternalBinding: Bool
    public let artifactPurpose: String
    public let publicCompatibilityIdentitySchema: String
    public let publicCompatibilityProfile: String
    public let publicCompatibilityIdentityCanonicalByteCount: Int
    public let publicCompatibilityIdentitySHA256: String
    public let parameterDescriptorCount: Int
    public let parameterCatalogCanonicalByteCount: Int
    public let parameterCatalogSHA256: String
    public let totalParameterCount: UInt64
    public let totalParameterByteCount: UInt64
    public let maximumCheckpointByteCount: UInt64

    public let artifactRootPublishCapability: String
    public let artifactRootLoadCapability: String
    public let artifactRootCapabilityRequired: Bool
    public let artifactRootMustRemainFilesystemAuthority: Bool
    public let exclusiveNoReplacePublicationRequired: Bool
    public let hiddenGeneratedFileRequired: Bool
    public let immutablePublishedModeRequired: Bool
    public let generatedFileSynchronizationRequired: Bool
    public let publicationParentSynchronizationRequired: Bool
    public let wholeContainerSHA256BindingRequired: Bool
    public let preAndPostMaterializationVerificationRequired: Bool
    public let completeMaterializationInsideHeldCapabilityRequired: Bool
    public let destinationPublicationOnGenerationFailureForbidden: Bool
    public let callerSuppliedExternalBindingRequiredForLoad: Bool
    public let embeddedMetadataMaySupplyContainerExpectation: Bool

    public let exactConfigurationRequired: Bool
    public let exactOrderedParameterPathSetRequired: Bool
    public let exactParameterShapeRequired: Bool
    public let exactParameterDTypeRequired: Bool
    public let exactParameterByteCountRequired: Bool
    public let finiteParameterValuesRequired: Bool
    public let exactLogicalTensorHashRequired: Bool
    public let freshDecoderRestoreAfterCompletePreflightRequired: Bool
    public let restoredParameterReinspectionRequired: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let kvCacheStateIncluded: Bool

    public let implementationSourceAdditionAuthorized: Bool
    public let manifestImplementationAuthorized: Bool
    public let externalBindingImplementationAuthorized: Bool
    public let codecImplementationAuthorized: Bool
    public let artifactRootBackedIOImplementationAuthorized: Bool
    public let publicNativeProfileAPIAdditionAuthorized: Bool
    public let isolatedDeclarativeValidationPackageAuthorized: Bool
    public let isolatedDeclarativeValidationTestAuthorized: Bool
    public let declarativeValidationMayConstructUnadmittedFullProfileManifestFixture:
        Bool
    public let declarativeValidationMayConstructUnadmittedExternalBindingFixture:
        Bool
    public let declarativeValidationCodecIOAuthorized: Bool
    public let declarativeValidationMayAllocateNative300M: Bool
    public let declarativeValidationFixtureIsArtifactAdmission: Bool
    public let workflowCommandListExtensionAuthorized: Bool
    public let workflowTopologyMutationAuthorized: Bool
    public let rootPackageManifestMutationAuthorized: Bool
    public let rootPackageResolvedMutationAuthorized: Bool
    public let newExternalDependencyAuthorized: Bool
    public let frozenPredecessorMutationAuthorized: Bool
    public let checkpointV1SourceMutationAuthorized: Bool
    public let checkpointV2IdentitySourceMutationAuthorized: Bool
    public let repairedDecoderMutationAuthorized: Bool
    public let maintainedRuntimeSourceMutationAuthorized: Bool
    public let frozenDecoderValidationMutationAuthorized: Bool
    public let frozen44TestInventoryMutationAuthorized: Bool
    public let existingV2IdentityValidationMutationAuthorized: Bool
    public let existingLauncherMutationAuthorized: Bool

    public let v2ManifestDefined: Bool
    public let v2ExternalBindingDefined: Bool
    public let v2CodecDefined: Bool
    public let checkpointContainerIOImplemented: Bool
    public let artifactRootPublicationIntegrationImplemented: Bool
    public let validationCodecIOObserved: Bool
    public let native300MCheckpointWriteExecutionAuthorized: Bool
    public let native300MCheckpointLoadExecutionAuthorized: Bool
    public let native300MCheckpointWriteObserved: Bool
    public let native300MCheckpointLoadObserved: Bool
    public let checkpointIOObserved: Bool
    public let checkpointArtifactAvailable: Bool
    public let checkpointArtifactRetained: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointContainerHashBound: Bool
    public let checkpointAdmissionGranted: Bool
    public let artifactRootCapabilityAloneConstitutesArtifactAdmission: Bool
    public let atomicCheckpointReplacementEstablished: Bool
    public let checkpointDurabilityObserved: Bool
    public let failedCheckpointWriteRecoveryObserved: Bool
    public let runtimeDependencyClosureReobservedForCheckpointIO: Bool
    public let checkpointLoadedForwardObserved: Bool
    public let checkpointRoundTripBehaviorParityEstablished: Bool
    public let existingCheckpointArtifactCompatibilityObserved: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let optimizerStepObserved: Bool
    public let trainingResumeEstablished: Bool
    public let trainingExecutionObserved: Bool
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
        authorityID:
            "ergentics_prime_native_decoder_checkpoint_v2_container_io_authority_v1",
        authorityKind:
            "append_only_artifact_root_backed_v2_checkpoint_io_design_authority",
        predecessorObservationID:
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservationV1
                .frozenV1.observationID,
        predecessorRemainsFrozen: true,
        predecessorRequiredForConsumption: true,
        authoritativeRepository: "Ergentics/ergentics-prime",
        baseRef: "refs/heads/main",
        baseRevision:
            "15f858f4a8fa74a7b6a29b55da59d4660c50ff01",
        baseOrderedParentRevisions: [
            "16dbcb3bad551bc6fd94f02dc3289dff60a94f24",
            "2db5da020dea1760d22484f2d23f2505a089a8f4",
        ],
        baseTree:
            "84f675ac08fdcc0cfd964dfb45d5374659a25782",
        baseEmbeddedSourceIdentitySHA256:
            "2c7ad1f2724b9bbcb34bcde89ed7e7458efdb1495f1320322d50be6155eff8ab",
        basePullRequestNumber: 75,
        baseHistoryPreservingTwoParentMerge: true,
        predecessorObservationSource: .init(
            path:
                "Sources/PrimeCore/PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservation.swift",
            gitMode: "100644",
            gitBlob: "92bc5e2f1e802c37d2b3b6ac07c6b60ce483328c",
            byteCount: 48_237,
            sha256:
                "62eb03797435a40b7c3265b2d9886f58b1b9a5be3f7759804daa6b1bcf2e94a4"),
        checkpointV1AuthoritySource: .init(
            path:
                "Sources/PrimeCore/PrimeNativeDecoderCheckpointAuthority.swift",
            gitMode: "100644",
            gitBlob: "2621721ef52cfb0aa823f096df9be83c37971aab",
            byteCount: 14_399,
            sha256:
                "60d593b8b0346570400f98212b173cef9f4495f24af34517097c20309eb765ac"),
        checkpointV1Source: .init(
            path:
                "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift",
            gitMode: "100644",
            gitBlob: "24de078fb6424123b8e6974588b4cc514219c026",
            byteCount: 39_956,
            sha256:
                "a239d2dd4ea9cc794105e15c09457e7bda526d8e1dbafeb3383997bb14f89b8b"),
        checkpointV2IdentityAuthoritySource: .init(
            path:
                "Sources/PrimeCore/PrimeNativeDecoderCheckpointCompatibilityV2Authority.swift",
            gitMode: "100644",
            gitBlob: "b09e51e6cd79b3962fec4ddb28c1a154ef979076",
            byteCount: 29_660,
            sha256:
                "ea5048b74b37cb8df9978f10c632c9fdbef47655b414518ce926b9d73ada8bdd"),
        checkpointV2IdentitySource: .init(
            path:
                "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift",
            gitMode: "100644",
            gitBlob: "7e993df79cc3a7c37d130c9eb5e7f30f63a6c386",
            byteCount: 9_228,
            sha256:
                "2b73886d067015ea65a71944bdc9d0f06025ee65858e9cfccf9a8f0936cf36f3"),
        repairedDecoderSource: .init(
            path:
                "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
            gitMode: "100644",
            gitBlob: "835a4826549e1f28ec27e3533f746218beb3bdf2",
            byteCount: 39_050,
            sha256:
                "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b"),
        durableArtifactCapabilitySource: .init(
            path: "Sources/PrimeCore/PrimeDurableArtifacts.swift",
            gitMode: "100644",
            gitBlob: "e9e462aa17ae1d4393c77cf953b3c7d44abfcd1e",
            byteCount: 144_993,
            sha256:
                "faa8254ee6ecd97f064a6553efba8158fff6a33fc882607444ba117d56328430"),
        rootPackageManifestSource: .init(
            path: "Package.swift",
            gitMode: "100644",
            gitBlob: "f201abbf928e5e3d6b0c7785110539cdaeee911b",
            byteCount: 32_082,
            sha256:
                "db81e337640b8eb923dbc90b9e22ce898c371ccffe08eed08050e45c34551400"),
        rootPackageResolvedSource: .init(
            path: "Package.resolved",
            gitMode: "100644",
            gitBlob: "dcd0192f705c22378f2d9e871a240c0493ad8a80",
            byteCount: 645,
            sha256:
                "a18ded75fe953803945898aba0b04a9cec4fca674f38bf914e5fa45dfdb70741"),
        baseActiveRootGateSource: .init(
            path: ".github/scripts/prime-ci-active-root-quarantine.sh",
            gitMode: "100755",
            gitBlob: "8950b903b0a7313a46e3f09a38ad7470446ed751",
            byteCount: 89_385,
            sha256:
                "676bdeabdb59897dc9225588493402b711ec3a4aeec0f2f1476b5d342fb89005"),
        baseTrustedWorkflowSource: .init(
            path: ".github/workflows/prime-active-root-quarantine.yml",
            gitMode: "100644",
            gitBlob: "1c93c6988bd3a3c319cbd049bbfbe4eea7e025fa",
            byteCount: 24_343,
            sha256:
                "ee2aea7b5e7f40d5c41681b807697322c1ab129efc5801165f424321113e952d"),
        exactMLXRepository: "Ergentics/ergentics-mlx-swift",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        mlxDescriptorIOPath: "Source/MLX/FileDescriptorIO.swift",
        mlxDescriptorIOGitMode: "100644",
        mlxDescriptorIOGitBlob:
            "3f2a5c0e6deb0ca9bfbc05d7448d193ac089cc47",
        mlxDescriptorIOByteCount: 45_780,
        mlxDescriptorIOSHA256:
            "60b0f7fff4c9c2873845b506887875b920256a2a2a538020bdf846c73abdbe1d",
        authoritativeProduct: "PrimeNativeDecoderCheckpoint",
        authoritativeTarget: "PrimeNativeDecoderCheckpoint",
        authoritativeTargetDependencies: [
            "PrimeCore",
            "PrimeNativeDecoder",
            "MLX",
            "MLXNN",
        ],
        implementationSourcePath:
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV2.swift",
        implementationSourceExpectedGitMode: "100644",
        implementationSourceIdentityStatus:
            "PINNED_AFTER_SOURCE_STABILIZATION",
        implementationSourceGitBlob:
            "105af3f93acf9358e7b66c3a327e45a931deab8b",
        implementationSourceByteCount: 54_880,
        implementationSourceSHA256:
            "39f74373923fcbb56eae5da2038795668c3347115c854a219374d1b797c9761d",
        validationPackagePath:
            "Tests/PrimeNativeDecoderCheckpointV2IOValidation",
        validationPackageManifestPath:
            "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.swift",
        validationPackageResolvedPath:
            "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.resolved",
        validationPackageManifestSource: .init(
            path:
                "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.swift",
            gitMode: "100644",
            gitBlob: "0a371f2fec33db3fe42d425674e2fd2539927eb7",
            byteCount: 737,
            sha256:
                "f4b7232483671d73f1b73796d3bff738ea2e3c3f286370ffc1f7e53b2697a8f9"),
        validationPackageResolvedSource: .init(
            path:
                "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Package.resolved",
            gitMode: "100644",
            gitBlob: "d5621ea4139fee6cc1fc39e03512ea4c1b009b5f",
            byteCount: 645,
            sha256:
                "8effb57587a4ec226d390bef418324d6dcef4491905bc88e341e1c64f72d043f"),
        validationTestSourcePath:
            "Tests/PrimeNativeDecoderCheckpointV2IOValidation/Tests/PrimeNativeDecoderCheckpointV2IOTests/PrimeNativeDecoderCheckpointV2IOTests.swift",
        validationTestSourceExpectedGitMode: "100644",
        validationTestSourceIdentityStatus:
            "PINNED_AFTER_SOURCE_STABILIZATION",
        validationTestSourceGitBlob:
            "74129e24c11a742adb11a80a8e454924426c63ee",
        validationTestSourceByteCount: 18_388,
        validationTestSourceSHA256:
            "f910ae77c7ea54d67f751902168b278bd6a45a5c2deb45618c5f0cb0b6952376",
        publicManifestType:
            "PrimeNativeDecoderCheckpointManifestV2",
        publicExternalBindingType:
            "PrimeNativeDecoderCheckpointExternalBindingV2",
        publicErrorType: "PrimeNativeDecoderCheckpointV2Error",
        publicCodecType: "PrimeNativeDecoderCheckpointCodecV2",
        publicTensorBindingType:
            "PrimeNativeDecoderCheckpointTensorBindingV2",
        publicWriteDeclaration:
            "PrimeNativeDecoderCheckpointCodecV2.writeNative300MByte512(model:to:at:)",
        publicLoadDeclaration:
            "PrimeNativeDecoderCheckpointCodecV2.loadNative300MByte512(expected:from:)",
        publicWriteRootParameterType: "PrimeArtifactRoot",
        publicLoadRootParameterType: "PrimeArtifactRoot",
        publicArtifactNameArgumentScope:
            "descriptor_relative_name_validated_beneath_held_artifact_root",
        publicRawPathAPIAuthorized: false,
        publicRawDescriptorAPIAuthorized: false,
        publicDiscoverAndTrustAPIAuthorized: false,
        publicInPlaceMutationAPIAuthorized: false,
        publicReplacementAPIAuthorized: false,
        manifestSchemaVersion: 2,
        manifestSchemaID:
            "ergentics_prime_native_decoder_weights_checkpoint_v2",
        externalBindingSchema:
            "manifest_plus_canonical_manifest_identity_plus_prime_artifact_binding_v2",
        checkpointArtifactKind:
            "prime_native_decoder_model_weights_only_checkpoint",
        checkpointFormat: "safetensors",
        stateScope:
            "model_parameters_only_no_optimizer_rng_cursor_or_cache",
        logicalTensorHashAlgorithm: "sha256",
        logicalTensorByteEncoding:
            "contiguous_row_major_little_endian_float32",
        manifestMetadataKey:
            "ergentics_prime_native_decoder_checkpoint_manifest_v2",
        manifestSHA256MetadataKey:
            "ergentics_prime_native_decoder_checkpoint_manifest_sha256_v2",
        metadataKeySetIsExact: true,
        manifestContainerSelfHashForbidden: true,
        wholeContainerHashMustComeFromExternalBinding: true,
        artifactPurpose: "immutable_data",
        publicCompatibilityIdentitySchema:
            "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
        publicCompatibilityProfile:
            "native300m_gqa_byte512_checkpoint_compatibility_v2",
        publicCompatibilityIdentityCanonicalByteCount: 30_553,
        publicCompatibilityIdentitySHA256:
            "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843",
        parameterDescriptorCount: 218,
        parameterCatalogCanonicalByteCount: 28_951,
        parameterCatalogSHA256:
            "69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1",
        totalParameterCount: 271_107_072,
        totalParameterByteCount: 1_084_428_288,
        maximumCheckpointByteCount: 1_101_205_504,
        artifactRootPublishCapability:
            "PrimeArtifactRoot.publishGeneratedFile(at:purpose:maximumByteCount:generate:)",
        artifactRootLoadCapability:
            "PrimeArtifactRoot.withVerifiedArtifactDescriptor(_:load:materialize:)",
        artifactRootCapabilityRequired: true,
        artifactRootMustRemainFilesystemAuthority: true,
        exclusiveNoReplacePublicationRequired: true,
        hiddenGeneratedFileRequired: true,
        immutablePublishedModeRequired: true,
        generatedFileSynchronizationRequired: true,
        publicationParentSynchronizationRequired: true,
        wholeContainerSHA256BindingRequired: true,
        preAndPostMaterializationVerificationRequired: true,
        completeMaterializationInsideHeldCapabilityRequired: true,
        destinationPublicationOnGenerationFailureForbidden: true,
        callerSuppliedExternalBindingRequiredForLoad: true,
        embeddedMetadataMaySupplyContainerExpectation: false,
        exactConfigurationRequired: true,
        exactOrderedParameterPathSetRequired: true,
        exactParameterShapeRequired: true,
        exactParameterDTypeRequired: true,
        exactParameterByteCountRequired: true,
        finiteParameterValuesRequired: true,
        exactLogicalTensorHashRequired: true,
        freshDecoderRestoreAfterCompletePreflightRequired: true,
        restoredParameterReinspectionRequired: true,
        optimizerStateIncluded: false,
        rngStateIncluded: false,
        dataCursorIncluded: false,
        kvCacheStateIncluded: false,
        implementationSourceAdditionAuthorized: true,
        manifestImplementationAuthorized: true,
        externalBindingImplementationAuthorized: true,
        codecImplementationAuthorized: true,
        artifactRootBackedIOImplementationAuthorized: true,
        publicNativeProfileAPIAdditionAuthorized: true,
        isolatedDeclarativeValidationPackageAuthorized: true,
        isolatedDeclarativeValidationTestAuthorized: true,
        declarativeValidationMayConstructUnadmittedFullProfileManifestFixture:
            true,
        declarativeValidationMayConstructUnadmittedExternalBindingFixture:
            true,
        declarativeValidationCodecIOAuthorized: false,
        declarativeValidationMayAllocateNative300M: false,
        declarativeValidationFixtureIsArtifactAdmission: false,
        workflowCommandListExtensionAuthorized: true,
        workflowTopologyMutationAuthorized: false,
        rootPackageManifestMutationAuthorized: false,
        rootPackageResolvedMutationAuthorized: false,
        newExternalDependencyAuthorized: false,
        frozenPredecessorMutationAuthorized: false,
        checkpointV1SourceMutationAuthorized: false,
        checkpointV2IdentitySourceMutationAuthorized: false,
        repairedDecoderMutationAuthorized: false,
        maintainedRuntimeSourceMutationAuthorized: false,
        frozenDecoderValidationMutationAuthorized: false,
        frozen44TestInventoryMutationAuthorized: false,
        existingV2IdentityValidationMutationAuthorized: false,
        existingLauncherMutationAuthorized: false,
        v2ManifestDefined: true,
        v2ExternalBindingDefined: true,
        v2CodecDefined: true,
        checkpointContainerIOImplemented: true,
        artifactRootPublicationIntegrationImplemented: true,
        validationCodecIOObserved: false,
        native300MCheckpointWriteExecutionAuthorized: true,
        native300MCheckpointLoadExecutionAuthorized: true,
        native300MCheckpointWriteObserved: false,
        native300MCheckpointLoadObserved: false,
        checkpointIOObserved: false,
        checkpointArtifactAvailable: false,
        checkpointArtifactRetained: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointContainerHashBound: false,
        checkpointAdmissionGranted: false,
        artifactRootCapabilityAloneConstitutesArtifactAdmission: false,
        atomicCheckpointReplacementEstablished: false,
        checkpointDurabilityObserved: false,
        failedCheckpointWriteRecoveryObserved: false,
        runtimeDependencyClosureReobservedForCheckpointIO: false,
        checkpointLoadedForwardObserved: false,
        checkpointRoundTripBehaviorParityEstablished: false,
        existingCheckpointArtifactCompatibilityObserved: false,
        trainEvaluateSurfaceEstablished: false,
        optimizerStepObserved: false,
        trainingResumeEstablished: false,
        trainingExecutionObserved: false,
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
            "ABSTAIN_v2_checkpoint_artifact_root_manifest_container_codec_io_implemented_native_write_load_authorized_not_observed_no_artifact_admission",
        orderedNextActions: [
            "bind_new_source_identities_and_integrate_trusted_gates",
            "run_isolated_declarative_manifest_external_binding_validation",
            "run_exact_clean_hosted_one_write_one_load_under_separate_execution_approval",
            "append_exact_execution_observation_without_artifact_admission",
            "produce_and_bind_non_fixture_checkpoint_under_separate_training_and_artifact_authority",
        ])

    public func validateExactV1() throws {
        let expected = Self.frozenV1
        let predecessor =
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityExecutionObservationV1
                .frozenV1
        let identityAuthority =
            PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan.frozenV2
        let checkpointV1 = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1

        do {
            try predecessor.validateExactV1()
            try identityAuthority.validateExactV2()
            try checkpointV1.validate()
            for source in [
                predecessorObservationSource,
                checkpointV1AuthoritySource,
                checkpointV1Source,
                checkpointV2IdentityAuthoritySource,
                checkpointV2IdentitySource,
                repairedDecoderSource,
                durableArtifactCapabilitySource,
                rootPackageManifestSource,
                rootPackageResolvedSource,
                baseActiveRootGateSource,
                baseTrustedWorkflowSource,
                validationPackageManifestSource,
                validationPackageResolvedSource,
            ] {
                try source.validate()
            }
        } catch {
            throw PrimeNativeDecoderCheckpointV2ContainerIOAuthorityError
                .contractDrift
        }

        guard self == expected,
              schemaVersion == 1,
              predecessorObservationID == predecessor.observationID,
              predecessorRemainsFrozen,
              predecessorRequiredForConsumption,
              authoritativeRepository == "Ergentics/ergentics-prime",
              baseRef == "refs/heads/main",
              baseRevision
                == "15f858f4a8fa74a7b6a29b55da59d4660c50ff01",
              baseOrderedParentRevisions == [
                  "16dbcb3bad551bc6fd94f02dc3289dff60a94f24",
                  "2db5da020dea1760d22484f2d23f2505a089a8f4",
              ],
              baseTree
                == "84f675ac08fdcc0cfd964dfb45d5374659a25782",
              baseEmbeddedSourceIdentitySHA256
                == "2c7ad1f2724b9bbcb34bcde89ed7e7458efdb1495f1320322d50be6155eff8ab",
              basePullRequestNumber == 75,
              baseHistoryPreservingTwoParentMerge,
              exactMLXRevision == identityAuthority.exactMLXRevision,
              mlxDescriptorIOGitMode == "100644",
              isCheckpointV2ContainerIOLowercaseHex(
                  mlxDescriptorIOGitBlob,
                  count: 40),
              mlxDescriptorIOByteCount == 45_780,
              isCheckpointV2ContainerIOLowercaseHex(
                  mlxDescriptorIOSHA256,
                  count: 64),
              authoritativeProduct == authoritativeTarget,
              authoritativeTargetDependencies == [
                  "PrimeCore",
                  "PrimeNativeDecoder",
                  "MLX",
                  "MLXNN",
              ],
              implementationSourceIdentityStatus
                == "PINNED_AFTER_SOURCE_STABILIZATION",
              implementationSourceExpectedGitMode == "100644",
              implementationSourceGitBlob
                == "105af3f93acf9358e7b66c3a327e45a931deab8b",
              implementationSourceByteCount == 54_880,
              implementationSourceSHA256
                == "39f74373923fcbb56eae5da2038795668c3347115c854a219374d1b797c9761d",
              validationPackageManifestSource.path
                == validationPackageManifestPath,
              validationPackageResolvedSource.path
                == validationPackageResolvedPath,
              validationTestSourceIdentityStatus
                == "PINNED_AFTER_SOURCE_STABILIZATION",
              validationTestSourceExpectedGitMode == "100644",
              validationTestSourceGitBlob
                == "74129e24c11a742adb11a80a8e454924426c63ee",
              validationTestSourceByteCount == 18_388,
              validationTestSourceSHA256
                == "f910ae77c7ea54d67f751902168b278bd6a45a5c2deb45618c5f0cb0b6952376",
              publicManifestType
                == "PrimeNativeDecoderCheckpointManifestV2",
              publicExternalBindingType
                == "PrimeNativeDecoderCheckpointExternalBindingV2",
              publicErrorType
                == "PrimeNativeDecoderCheckpointV2Error",
              publicCodecType
                == "PrimeNativeDecoderCheckpointCodecV2",
              publicTensorBindingType
                == "PrimeNativeDecoderCheckpointTensorBindingV2",
              publicWriteRootParameterType == "PrimeArtifactRoot",
              publicLoadRootParameterType == "PrimeArtifactRoot",
              !publicRawPathAPIAuthorized,
              !publicRawDescriptorAPIAuthorized,
              !publicDiscoverAndTrustAPIAuthorized,
              !publicInPlaceMutationAPIAuthorized,
              !publicReplacementAPIAuthorized,
              manifestSchemaVersion == 2,
              publicCompatibilityIdentitySchema
                == identityAuthority.compatibilityIdentitySchema,
              publicCompatibilityProfile
                == identityAuthority.publicCompatibilityProfile,
              publicCompatibilityIdentityCanonicalByteCount
                == identityAuthority.publicV2CanonicalIdentityByteCount,
              publicCompatibilityIdentitySHA256
                == identityAuthority.publicV2CanonicalIdentitySHA256,
              parameterDescriptorCount
                == identityAuthority.parameterDescriptorCount,
              parameterCatalogCanonicalByteCount
                == identityAuthority.parameterCatalogCanonicalByteCount,
              parameterCatalogSHA256
                == identityAuthority.parameterCatalogSHA256,
              totalParameterCount == identityAuthority.totalParameterCount,
              totalParameterByteCount
                == identityAuthority.totalParameterByteCount,
              maximumCheckpointByteCount
                == identityAuthority.maximumCheckpointByteCount,
              metadataKeySetIsExact,
              manifestContainerSelfHashForbidden,
              wholeContainerHashMustComeFromExternalBinding,
              artifactRootCapabilityRequired,
              artifactRootMustRemainFilesystemAuthority,
              exclusiveNoReplacePublicationRequired,
              hiddenGeneratedFileRequired,
              immutablePublishedModeRequired,
              generatedFileSynchronizationRequired,
              publicationParentSynchronizationRequired,
              wholeContainerSHA256BindingRequired,
              preAndPostMaterializationVerificationRequired,
              completeMaterializationInsideHeldCapabilityRequired,
              destinationPublicationOnGenerationFailureForbidden,
              callerSuppliedExternalBindingRequiredForLoad,
              !embeddedMetadataMaySupplyContainerExpectation,
              exactConfigurationRequired,
              exactOrderedParameterPathSetRequired,
              exactParameterShapeRequired,
              exactParameterDTypeRequired,
              exactParameterByteCountRequired,
              finiteParameterValuesRequired,
              exactLogicalTensorHashRequired,
              freshDecoderRestoreAfterCompletePreflightRequired,
              restoredParameterReinspectionRequired,
              !optimizerStateIncluded,
              !rngStateIncluded,
              !dataCursorIncluded,
              !kvCacheStateIncluded,
              implementationSourceAdditionAuthorized,
              manifestImplementationAuthorized,
              externalBindingImplementationAuthorized,
              codecImplementationAuthorized,
              artifactRootBackedIOImplementationAuthorized,
              publicNativeProfileAPIAdditionAuthorized,
              isolatedDeclarativeValidationPackageAuthorized,
              isolatedDeclarativeValidationTestAuthorized,
              declarativeValidationMayConstructUnadmittedFullProfileManifestFixture,
              declarativeValidationMayConstructUnadmittedExternalBindingFixture,
              !declarativeValidationCodecIOAuthorized,
              !declarativeValidationMayAllocateNative300M,
              !declarativeValidationFixtureIsArtifactAdmission,
              workflowCommandListExtensionAuthorized,
              !workflowTopologyMutationAuthorized,
              !rootPackageManifestMutationAuthorized,
              !rootPackageResolvedMutationAuthorized,
              !newExternalDependencyAuthorized,
              !frozenPredecessorMutationAuthorized,
              !checkpointV1SourceMutationAuthorized,
              !checkpointV2IdentitySourceMutationAuthorized,
              !repairedDecoderMutationAuthorized,
              !maintainedRuntimeSourceMutationAuthorized,
              !frozenDecoderValidationMutationAuthorized,
              !frozen44TestInventoryMutationAuthorized,
              !existingV2IdentityValidationMutationAuthorized,
              !existingLauncherMutationAuthorized,
              v2ManifestDefined,
              v2ExternalBindingDefined,
              v2CodecDefined,
              checkpointContainerIOImplemented,
              artifactRootPublicationIntegrationImplemented,
              !validationCodecIOObserved,
              native300MCheckpointWriteExecutionAuthorized,
              native300MCheckpointLoadExecutionAuthorized,
              !native300MCheckpointWriteObserved,
              !native300MCheckpointLoadObserved,
              !checkpointIOObserved,
              !checkpointArtifactAvailable,
              !checkpointArtifactRetained,
              !checkpointArtifactProvenanceEstablished,
              !checkpointContainerHashBound,
              !checkpointAdmissionGranted,
              !artifactRootCapabilityAloneConstitutesArtifactAdmission,
              !atomicCheckpointReplacementEstablished,
              !checkpointDurabilityObserved,
              !failedCheckpointWriteRecoveryObserved,
              !runtimeDependencyClosureReobservedForCheckpointIO,
              !checkpointLoadedForwardObserved,
              !checkpointRoundTripBehaviorParityEstablished,
              !existingCheckpointArtifactCompatibilityObserved,
              !trainEvaluateSurfaceEstablished,
              !optimizerStepObserved,
              !trainingResumeEstablished,
              !trainingExecutionObserved,
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
              orderedNextActions.first
                == "bind_new_source_identities_and_integrate_trusted_gates",
              orderedNextActions.last
                == "produce_and_bind_non_fixture_checkpoint_under_separate_training_and_artifact_authority",
              predecessor.exactReviewedMainCompatibilityExecutionObserved,
              predecessor.native300MModelAllocationObserved,
              predecessor.decoderForwardObserved,
              !predecessor.checkpointIOObserved,
              !predecessor.checkpointArtifactProvenanceEstablished,
              !predecessor.checkpointAdmissionGranted
        else {
            throw PrimeNativeDecoderCheckpointV2ContainerIOAuthorityError
                .contractDrift
        }
    }
}

private func isCheckpointV2ContainerIOLowercaseHex(
    _ value: String,
    count: Int
) -> Bool {
    value.utf8.count == count
        && value.utf8.allSatisfy { byte in
            (48 ... 57).contains(byte) || (97 ... 102).contains(byte)
        }
        && value != String(repeating: "0", count: count)
}
