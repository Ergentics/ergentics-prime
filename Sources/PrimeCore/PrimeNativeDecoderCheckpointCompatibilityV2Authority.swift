// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum PrimeNativeDecoderCheckpointCompatibilityV2AuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Append-only authority for the repaired decoder's declarative checkpoint
/// compatibility identity.
///
/// This successor retains the exact V1 configuration, tokenizer identity, and
/// ordered parameter catalog while changing the schema, authority lineage,
/// and decoder-source binding. It defines no V2 manifest or codec, performs no
/// model allocation or checkpoint I/O, and grants no runtime or training
/// authority.
public struct PrimeNativeDecoderCheckpointCompatibilityV2AuthorityPlan:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let predecessorObservationID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorRequiredForConsumption: Bool
    public let predecessorSourcePath: String
    public let predecessorSourceGitMode: String
    public let predecessorSourceGitBlob: String
    public let predecessorSourceByteCount: Int
    public let predecessorSourceSHA256: String

    public let authoritativeRepository: String
    public let baseRevision: String
    public let baseOrderedParentRevisions: [String]
    public let baseTree: String
    public let baseEmbeddedSourceIdentitySHA256: String
    public let basePullRequestNumber: Int

    public let checkpointV1AuthoritySourcePath: String
    public let checkpointV1AuthoritySourceGitMode: String
    public let checkpointV1AuthoritySourceGitBlob: String
    public let checkpointV1AuthoritySourceByteCount: Int
    public let checkpointV1AuthoritySourceSHA256: String
    public let checkpointV1SourcePath: String
    public let checkpointV1SourceGitMode: String
    public let checkpointV1SourceGitBlob: String
    public let checkpointV1SourceByteCount: Int
    public let checkpointV1SourceSHA256: String
    public let repairedDecoderSourcePath: String
    public let repairedDecoderSourceGitMode: String
    public let repairedDecoderSourceGitBlob: String
    public let repairedDecoderSourceByteCount: Int
    public let repairedDecoderSourceSHA256: String
    public let metalLauncherPath: String
    public let metalLauncherGitMode: String
    public let metalLauncherGitBlob: String
    public let metalLauncherByteCount: Int
    public let metalLauncherSHA256: String
    public let identityV2SourcePath: String
    public let identityV2SourceGitMode: String
    public let identityV2SourceGitBlob: String
    public let identityV2SourceByteCount: Int
    public let identityV2SourceSHA256: String

    public let authoritativeProduct: String
    public let authoritativeTarget: String
    public let authoritativeTargetDependencies: [String]
    public let publicIdentityType: String
    public let publicFactoryDeclaration: String
    public let publicValidatorDeclaration: String
    public let publicIdentityConformances: [String]
    public let compatibilityIdentitySchema: String
    public let publicCompatibilityProfile: String
    public let architectureSchema: String
    public let implementationID: String
    public let repairAuthorityID: String
    public let historicalV1CompatibilityIdentitySchema: String
    public let historicalV1CompatibilityProfile: String
    public let historicalV1DecoderSourceSHA256: String
    public let historicalV1CanonicalIdentityByteCount: Int
    public let historicalV1CanonicalIdentitySHA256: String
    public let publicV2CanonicalIdentityByteCount: Int
    public let publicV2CanonicalIdentitySHA256: String
    public let exactMLXRevision: String
    public let parameterPathSchema: String
    public let requiredTensorDType: String
    public let tiedOutputProjection: Bool

    public let vocabularySize: Int
    public let modelWidth: Int
    public let layerCount: Int
    public let queryHeadCount: Int
    public let keyValueHeadCount: Int
    public let headWidth: Int
    public let intermediateWidth: Int
    public let maximumSequenceLength: Int
    public let ropeThetaFloat32BitPattern: UInt32
    public let rmsNormEpsilonFloat32BitPattern: UInt32
    public let tokenizerID: String
    public let tokenizerManifestSHA256: String
    public let tokenizerVocabularySize: Int
    public let parameterDescriptorCount: Int
    public let parameterCatalogCanonicalByteCount: Int
    public let parameterCatalogSHA256: String
    public let totalParameterCount: UInt64
    public let totalParameterByteCount: UInt64
    public let maximumCheckpointByteCount: UInt64
    public let identityDelta: String
    public let identityV2ForbiddenTokens: [String]
    public let identityV2ValidationPackagePath: String
    public let identityV2ValidationScope: String

    public let reviewedMainSyntheticMechanicsObserved: Bool
    public let historicalV1CompatibilityIdentityPreserved: Bool
    public let repairedDecoderSourceBound: Bool
    public let v1ArchitectureTokenizerAndParameterProjectionRetained: Bool
    public let declarativeWeightPathShapeAndDTypeCompatibilityEstablished: Bool
    public let declarativeRepairedCheckpointCompatibilityIdentityEstablished:
        Bool
    public let identityScopeIsDeclarativeOnly: Bool
    public let identityV2SourceAdditionAuthorized: Bool
    public let separateIdentityV2ValidationPackageAuthorized: Bool
    public let identityV2ValidationModelOrMetalExecutionAuthorized: Bool
    public let identityV2ValidationCheckpointIOAuthorized: Bool
    public let v1ToV2CrossVersionRelabelingRejected: Bool
    public let v2ToV1CrossVersionRelabelingRejected: Bool
    public let v1ManifestAcceptsV2Identity: Bool
    public let v2ManifestDefined: Bool
    public let v2CodecDefined: Bool
    public let checkpointContainerIOImplemented: Bool
    public let repairedDecoderBehaviorParityWithHistoricalV1Established: Bool
    public let existingCheckpointArtifactCompatibilityObserved: Bool
    public let native300MModelAllocationObserved: Bool
    public let native300MCheckpointWriteObserved: Bool
    public let native300MCheckpointLoadObserved: Bool
    public let native300MModelAllocationAuthorized: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let checkpointArtifactAvailable: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointContainerHashBound: Bool
    public let checkpointAdmissionGranted: Bool
    public let admittedRuntimeComputePolicyEstablished: Bool
    public let runtimeDependencyClosureEstablished: Bool
    public let runtimeLoadedMetallibIdentityEstablished: Bool
    public let runtimeMetalDeviceIdentityEstablished: Bool
    public let runtimeInitializationEstablished: Bool
    public let tokenizerFunctionalCompatibilityEstablished: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let kvCacheStateIncluded: Bool
    public let trainingResumeEstablished: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let optimizerStepObserved: Bool
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
    public let rootPackageManifestMutationAuthorized: Bool
    public let checkpointV1SourceMutationAuthorized: Bool
    public let repairedDecoderMutationAuthorized: Bool
    public let metalLauncherMutationAuthorized: Bool
    public let existingIsolatedDecoderValidationMutationAuthorized: Bool
    public let existing44TestInventoryMutationAuthorized: Bool
    public let driverV2MutationAuthorized: Bool
    public let pmhnpMutationAuthorized: Bool
    public let geometryDependencyAuthorized: Bool
    public let workflowTopologyMutationAuthorized: Bool
    public let status: String
    public let orderedNextActions: [String]

    public static let frozenV2 = Self(
        schemaVersion: 2,
        authorityID:
            "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
        predecessorObservationID:
            PrimeNativeDecoderReviewedMainMetalExecutionObservationV1
                .frozenV1.observationID,
        predecessorRemainsFrozen: true,
        predecessorRequiredForConsumption: true,
        predecessorSourcePath:
            "Sources/PrimeCore/PrimeNativeDecoderReviewedMainMetalExecutionObservation.swift",
        predecessorSourceGitMode: "100644",
        predecessorSourceGitBlob:
            "f5025b136b761b2db680cdc656542c6d5caa309e",
        predecessorSourceByteCount: 37_500,
        predecessorSourceSHA256:
            "c94fa198edc1708eab69687fc2baac9fddfd91900bca99f1fe7cb5c4473f1746",
        authoritativeRepository: "Ergentics/ergentics-prime",
        baseRevision:
            "3da134d323301c1a65867b81a7ca6c61625676ee",
        baseOrderedParentRevisions: [
            "b7bad4db76a3ceadba69195ff218af64b19fb716",
            "add1d552c0afeb42560cddb624a0fb5f4b732597",
        ],
        baseTree:
            "71343694f275b64fb5c89d37feca002aa0f4027e",
        baseEmbeddedSourceIdentitySHA256:
            "c338cdbbb7c35c5706bae0015757bc5907aad730167d6906075daea7474d55fd",
        basePullRequestNumber: 70,
        checkpointV1AuthoritySourcePath:
            "Sources/PrimeCore/PrimeNativeDecoderCheckpointAuthority.swift",
        checkpointV1AuthoritySourceGitMode: "100644",
        checkpointV1AuthoritySourceGitBlob:
            "2621721ef52cfb0aa823f096df9be83c37971aab",
        checkpointV1AuthoritySourceByteCount: 14_399,
        checkpointV1AuthoritySourceSHA256:
            "60d593b8b0346570400f98212b173cef9f4495f24af34517097c20309eb765ac",
        checkpointV1SourcePath:
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCheckpointV1.swift",
        checkpointV1SourceGitMode: "100644",
        checkpointV1SourceGitBlob:
            "24de078fb6424123b8e6974588b4cc514219c026",
        checkpointV1SourceByteCount: 39_956,
        checkpointV1SourceSHA256:
            "a239d2dd4ea9cc794105e15c09457e7bda526d8e1dbafeb3383997bb14f89b8b",
        repairedDecoderSourcePath:
            "Sources/PrimeNativeDecoder/PrimeNativeGQADecoder.swift",
        repairedDecoderSourceGitMode: "100644",
        repairedDecoderSourceGitBlob:
            "835a4826549e1f28ec27e3533f746218beb3bdf2",
        repairedDecoderSourceByteCount: 39_050,
        repairedDecoderSourceSHA256:
            "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
        metalLauncherPath:
            ".github/scripts/prime-ci-native-decoder-metal.sh",
        metalLauncherGitMode: "100755",
        metalLauncherGitBlob:
            "418d2d2753cee38e0b3558ad45e1e09865ffd11d",
        metalLauncherByteCount: 11_793,
        metalLauncherSHA256:
            "88029b6e9510aba607e00fe93b5c1f04e580c77fed42992b581363e4d54fbcff",
        identityV2SourcePath:
            "Sources/PrimeNativeDecoderCheckpoint/PrimeNativeDecoderCompatibilityIdentityV2.swift",
        identityV2SourceGitMode: "100644",
        identityV2SourceGitBlob:
            "7e993df79cc3a7c37d130c9eb5e7f30f63a6c386",
        identityV2SourceByteCount: 9_228,
        identityV2SourceSHA256:
            "2b73886d067015ea65a71944bdc9d0f06025ee65858e9cfccf9a8f0936cf36f3",
        authoritativeProduct: "PrimeNativeDecoderCheckpoint",
        authoritativeTarget: "PrimeNativeDecoderCheckpoint",
        authoritativeTargetDependencies: [
            "PrimeCore",
            "PrimeNativeDecoder",
            "MLX",
            "MLXNN",
        ],
        publicIdentityType:
            "PrimeNativeDecoderCompatibilityIdentityV2",
        publicFactoryDeclaration:
            "public static func native300MByte512() throws -> Self",
        publicValidatorDeclaration:
            "public func validate() throws",
        publicIdentityConformances: [
            "Codable",
            "Equatable",
            "Sendable",
        ],
        compatibilityIdentitySchema:
            "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
        publicCompatibilityProfile:
            "native300m_gqa_byte512_checkpoint_compatibility_v2",
        architectureSchema:
            "ergentics_prime_native_gqa_decoder_architecture_v1",
        implementationID:
            "PrimeNativeDecoder.PrimeNativeGQADecoder",
        repairAuthorityID:
            PrimeNativeDecoderMetalRepairAuthorityPlan.frozenV1.authorityID,
        historicalV1CompatibilityIdentitySchema:
            PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                .compatibilityIdentitySchema,
        historicalV1CompatibilityProfile:
            PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                .publicCheckpointCompatibilityProfile,
        historicalV1DecoderSourceSHA256:
            PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
                .decoderSourceSHA256,
        historicalV1CanonicalIdentityByteCount: 30_371,
        historicalV1CanonicalIdentitySHA256:
            "acf439fcc9ddf4871ecc072d0e8372cb5b99e1673effc3afbfce755a0f9eec8d",
        publicV2CanonicalIdentityByteCount: 30_553,
        publicV2CanonicalIdentitySHA256:
            "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843",
        exactMLXRevision:
            "d37885a278f1c37484a94d0f401a418735e66519",
        parameterPathSchema:
            "mlxnn_flattened_module_parameters_v1",
        requiredTensorDType: "float32",
        tiedOutputProjection: true,
        vocabularySize: 512,
        modelWidth: 1_024,
        layerCount: 24,
        queryHeadCount: 16,
        keyValueHeadCount: 4,
        headWidth: 64,
        intermediateWidth: 2_816,
        maximumSequenceLength: 2_048,
        ropeThetaFloat32BitPattern: 1_176_256_512,
        rmsNormEpsilonFloat32BitPattern: 925_353_388,
        tokenizerID: "ergentics_prime_nfc_utf8_byte_v1",
        tokenizerManifestSHA256:
            "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7",
        tokenizerVocabularySize: 512,
        parameterDescriptorCount: 218,
        parameterCatalogCanonicalByteCount: 28_951,
        parameterCatalogSHA256:
            "69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1",
        totalParameterCount: 271_107_072,
        totalParameterByteCount: 1_084_428_288,
        maximumCheckpointByteCount: 1_101_205_504,
        identityDelta:
            "new_v2_schema_authority_lineage_and_repaired_decoder_source_binding_no_parameter_projection_change",
        identityV2ForbiddenTokens: [
            "import Darwin",
            "import Metal",
            "import MLX",
            "import MLXNN",
            "import MLXOptimizers",
            "MLXArray",
            "PrimeNativeDecoderCheckpointManifestV1",
            "PrimeNativeDecoderCheckpointCodecV1",
            "FileManager",
            "FileHandle",
            "URL(fileURLWithPath:",
            "open(",
            "close(",
            "read(",
            "write(",
            "load(",
            "save(",
        ],
        identityV2ValidationPackagePath:
            "Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation",
        identityV2ValidationScope:
            "canonical_v1_v2_declarative_identity_only_no_model_allocation_metal_or_checkpoint_io",
        reviewedMainSyntheticMechanicsObserved: true,
        historicalV1CompatibilityIdentityPreserved: true,
        repairedDecoderSourceBound: true,
        v1ArchitectureTokenizerAndParameterProjectionRetained: true,
        declarativeWeightPathShapeAndDTypeCompatibilityEstablished: true,
        declarativeRepairedCheckpointCompatibilityIdentityEstablished: true,
        identityScopeIsDeclarativeOnly: true,
        identityV2SourceAdditionAuthorized: true,
        separateIdentityV2ValidationPackageAuthorized: true,
        identityV2ValidationModelOrMetalExecutionAuthorized: false,
        identityV2ValidationCheckpointIOAuthorized: false,
        v1ToV2CrossVersionRelabelingRejected: true,
        v2ToV1CrossVersionRelabelingRejected: true,
        v1ManifestAcceptsV2Identity: false,
        v2ManifestDefined: false,
        v2CodecDefined: false,
        checkpointContainerIOImplemented: false,
        repairedDecoderBehaviorParityWithHistoricalV1Established: false,
        existingCheckpointArtifactCompatibilityObserved: false,
        native300MModelAllocationObserved: false,
        native300MCheckpointWriteObserved: false,
        native300MCheckpointLoadObserved: false,
        native300MModelAllocationAuthorized: false,
        native300MCheckpointWriteAuthorized: false,
        native300MCheckpointLoadAuthorized: false,
        checkpointArtifactAvailable: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointContainerHashBound: false,
        checkpointAdmissionGranted: false,
        admittedRuntimeComputePolicyEstablished: false,
        runtimeDependencyClosureEstablished: false,
        runtimeLoadedMetallibIdentityEstablished: false,
        runtimeMetalDeviceIdentityEstablished: false,
        runtimeInitializationEstablished: false,
        tokenizerFunctionalCompatibilityEstablished: false,
        optimizerStateIncluded: false,
        rngStateIncluded: false,
        dataCursorIncluded: false,
        kvCacheStateIncluded: false,
        trainingResumeEstablished: false,
        trainEvaluateSurfaceEstablished: false,
        optimizerStepObserved: false,
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
        rootPackageManifestMutationAuthorized: false,
        checkpointV1SourceMutationAuthorized: false,
        repairedDecoderMutationAuthorized: false,
        metalLauncherMutationAuthorized: false,
        existingIsolatedDecoderValidationMutationAuthorized: false,
        existing44TestInventoryMutationAuthorized: false,
        driverV2MutationAuthorized: false,
        pmhnpMutationAuthorized: false,
        geometryDependencyAuthorized: false,
        workflowTopologyMutationAuthorized: false,
        status:
            "ABSTAIN_declarative_repaired_checkpoint_compatibility_identity_only_no_manifest_codec_artifact_runtime_or_training",
        orderedNextActions: [
            "append_admitted_runtime_compute_policy",
            "establish_exact_runtime_dependency_metallib_device_and_initialization_closure",
            "establish_tokenizer_model_functional_compatibility",
            "define_bounded_v2_native_profile_checkpoint_container_manifest_codec_and_io_under_separate_authority",
            "define_generic_train_and_evaluate_surfaces",
            "establish_exact_optimizer_rng_and_data_cursor_resume",
            "request_separate_bounded_training_authorization",
            "produce_and_bind_non_fixture_checkpoint_artifact",
        ]
    )

    public func validateExactV2() throws {
        let expected = Self.frozenV2
        let predecessor =
            PrimeNativeDecoderReviewedMainMetalExecutionObservationV1.frozenV1
        let checkpointV1 = PrimeNativeDecoderCheckpointAuthorityPlan.frozenV1
        let repair = PrimeNativeDecoderMetalRepairAuthorityPlan.frozenV1

        do {
            try predecessor.validateExactV1()
            try checkpointV1.validate()
            try repair.validate()
        } catch {
            throw PrimeNativeDecoderCheckpointCompatibilityV2AuthorityError
                .contractDrift
        }

        guard self == expected,
              schemaVersion == 2,
              predecessorObservationID == predecessor.observationID,
              predecessorRemainsFrozen,
              predecessorRequiredForConsumption,
              predecessorSourceGitMode == "100644",
              predecessorSourceGitBlob.utf8.count == 40,
              predecessorSourceByteCount == 37_500,
              isExactLowercaseSHA256(predecessorSourceSHA256),
              authoritativeRepository == "Ergentics/ergentics-prime",
              baseRevision.utf8.count == 40,
              baseOrderedParentRevisions.count == 2,
              baseOrderedParentRevisions.allSatisfy({ $0.utf8.count == 40 }),
              baseTree.utf8.count == 40,
              isExactLowercaseSHA256(baseEmbeddedSourceIdentitySHA256),
              basePullRequestNumber == 70,
              checkpointV1AuthoritySourceGitMode == "100644",
              checkpointV1AuthoritySourceGitBlob.utf8.count == 40,
              checkpointV1AuthoritySourceByteCount == 14_399,
              isExactLowercaseSHA256(checkpointV1AuthoritySourceSHA256),
              checkpointV1SourceGitMode == "100644",
              checkpointV1SourceGitBlob == checkpointV1.checkpointSourceGitBlob,
              checkpointV1SourceByteCount == checkpointV1.checkpointSourceByteCount,
              checkpointV1SourceSHA256 == checkpointV1.checkpointSourceSHA256,
              repairedDecoderSourceGitMode == "100644",
              repairedDecoderSourceGitBlob == repair.repairedDecoderSourceGitBlob,
              repairedDecoderSourceByteCount == repair.repairedDecoderSourceByteCount,
              repairedDecoderSourceSHA256 == repair.repairedDecoderSourceSHA256,
              metalLauncherPath == repair.ciMetalLauncherPath,
              metalLauncherGitMode == repair.ciMetalLauncherGitMode,
              metalLauncherGitBlob == repair.ciMetalLauncherGitBlob,
              metalLauncherByteCount == repair.ciMetalLauncherByteCount,
              metalLauncherSHA256 == repair.ciMetalLauncherSHA256,
              identityV2SourceGitMode == "100644",
              identityV2SourceGitBlob.utf8.count == 40,
              identityV2SourceByteCount > 0,
              isExactLowercaseSHA256(identityV2SourceSHA256),
              authoritativeProduct == authoritativeTarget,
              authoritativeTargetDependencies == [
                  "PrimeCore",
                  "PrimeNativeDecoder",
                  "MLX",
                  "MLXNN",
              ],
              publicIdentityConformances == [
                  "Codable",
                  "Equatable",
                  "Sendable",
              ],
              compatibilityIdentitySchema == authorityID,
              architectureSchema == repair.architectureSchema,
              implementationID == repair.authoritativeImplementationID,
              repairAuthorityID == repair.authorityID,
              historicalV1CompatibilityIdentitySchema
                == checkpointV1.compatibilityIdentitySchema,
              historicalV1CompatibilityProfile
                == checkpointV1.publicCheckpointCompatibilityProfile,
              historicalV1DecoderSourceSHA256
                == checkpointV1.decoderSourceSHA256,
              historicalV1CanonicalIdentityByteCount == 30_371,
              isExactLowercaseSHA256(
                  historicalV1CanonicalIdentitySHA256),
              publicV2CanonicalIdentityByteCount == 30_553,
              isExactLowercaseSHA256(publicV2CanonicalIdentitySHA256),
              exactMLXRevision == repair.exactMLXRevision,
              parameterPathSchema == repair.parameterPathSchema,
              requiredTensorDType == "float32",
              tiedOutputProjection,
              vocabularySize == tokenizerVocabularySize,
              vocabularySize == 512,
              modelWidth == 1_024,
              layerCount == 24,
              queryHeadCount == 16,
              keyValueHeadCount == 4,
              headWidth == 64,
              intermediateWidth == 2_816,
              maximumSequenceLength == 2_048,
              ropeThetaFloat32BitPattern == Float(10_000).bitPattern,
              rmsNormEpsilonFloat32BitPattern == Float(1e-5).bitPattern,
              tokenizerManifestSHA256 == checkpointV1
                .publicTokenizerManifestSHA256,
              tokenizerID == checkpointV1.publicTokenizerID,
              parameterDescriptorCount == 218,
              parameterCatalogCanonicalByteCount == 28_951,
              isExactLowercaseSHA256(parameterCatalogSHA256),
              totalParameterCount == 271_107_072,
              totalParameterByteCount == totalParameterCount * 4,
              maximumCheckpointByteCount
                == totalParameterByteCount + 16 * 1_024 * 1_024,
              Set(identityV2ForbiddenTokens).count
                == identityV2ForbiddenTokens.count,
              identityV2ValidationPackagePath
                == "Tests/PrimeNativeDecoderCheckpointCompatibilityV2Validation",
              identityV2ValidationScope
                == "canonical_v1_v2_declarative_identity_only_no_model_allocation_metal_or_checkpoint_io",
              predecessor.exactReviewedMainSyntheticMechanicsObserved,
              reviewedMainSyntheticMechanicsObserved,
              historicalV1CompatibilityIdentityPreserved,
              repairedDecoderSourceBound,
              v1ArchitectureTokenizerAndParameterProjectionRetained,
              declarativeWeightPathShapeAndDTypeCompatibilityEstablished,
              declarativeRepairedCheckpointCompatibilityIdentityEstablished,
              identityScopeIsDeclarativeOnly,
              identityV2SourceAdditionAuthorized,
              separateIdentityV2ValidationPackageAuthorized,
              !identityV2ValidationModelOrMetalExecutionAuthorized,
              !identityV2ValidationCheckpointIOAuthorized,
              v1ToV2CrossVersionRelabelingRejected,
              v2ToV1CrossVersionRelabelingRejected,
              !v1ManifestAcceptsV2Identity,
              !v2ManifestDefined,
              !v2CodecDefined,
              !checkpointContainerIOImplemented,
              !repairedDecoderBehaviorParityWithHistoricalV1Established,
              !existingCheckpointArtifactCompatibilityObserved,
              !native300MModelAllocationObserved,
              !native300MCheckpointWriteObserved,
              !native300MCheckpointLoadObserved,
              !native300MModelAllocationAuthorized,
              !native300MCheckpointWriteAuthorized,
              !native300MCheckpointLoadAuthorized,
              !checkpointArtifactAvailable,
              !checkpointArtifactProvenanceEstablished,
              !checkpointContainerHashBound,
              !checkpointAdmissionGranted,
              !admittedRuntimeComputePolicyEstablished,
              !runtimeDependencyClosureEstablished,
              !runtimeLoadedMetallibIdentityEstablished,
              !runtimeMetalDeviceIdentityEstablished,
              !runtimeInitializationEstablished,
              !tokenizerFunctionalCompatibilityEstablished,
              !optimizerStateIncluded,
              !rngStateIncluded,
              !dataCursorIncluded,
              !kvCacheStateIncluded,
              !trainingResumeEstablished,
              !trainEvaluateSurfaceEstablished,
              !optimizerStepObserved,
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
              !rootPackageManifestMutationAuthorized,
              !checkpointV1SourceMutationAuthorized,
              !repairedDecoderMutationAuthorized,
              !metalLauncherMutationAuthorized,
              !existingIsolatedDecoderValidationMutationAuthorized,
              !existing44TestInventoryMutationAuthorized,
              !driverV2MutationAuthorized,
              !pmhnpMutationAuthorized,
              !geometryDependencyAuthorized,
              !workflowTopologyMutationAuthorized,
              status.hasPrefix("ABSTAIN_"),
              orderedNextActions == [
                  "append_admitted_runtime_compute_policy",
                  "establish_exact_runtime_dependency_metallib_device_and_initialization_closure",
                  "establish_tokenizer_model_functional_compatibility",
                  "define_bounded_v2_native_profile_checkpoint_container_manifest_codec_and_io_under_separate_authority",
                  "define_generic_train_and_evaluate_surfaces",
                  "establish_exact_optimizer_rng_and_data_cursor_resume",
                  "request_separate_bounded_training_authorization",
                  "produce_and_bind_non_fixture_checkpoint_artifact",
              ]
        else {
            throw PrimeNativeDecoderCheckpointCompatibilityV2AuthorityError
                .contractDrift
        }
    }
}

private func isExactLowercaseSHA256(_ value: String) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy { byte in
            (48 ... 57).contains(byte) || (97 ... 102).contains(byte)
        }
        && value != String(repeating: "0", count: 64)
}
