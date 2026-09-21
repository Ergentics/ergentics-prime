// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

import Foundation

public enum
    PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityError:
    Error,
    Equatable,
    Sendable
{
    case contractDrift
}

/// Successor environment policy for one bounded tokenizer-to-model probe.
/// The maintained-runtime policy remains frozen; this wrapper reuses only its
/// exact environment validation mechanics, not its no-model authority ceiling.
public enum
    PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
{
    public static let declaration =
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1(
            schemaVersion: 1,
            policyID:
                "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_environment_v1",
            policyVersion: 1,
            scope:
                "byte512_tokenizer_to_random_initialized_native300m_one_full_prefix_forward",
            predecessorPolicyID:
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                    .declaration.policyID,
            predecessorPolicyVersion:
                PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                    .declaration.policyVersion,
            predecessorRemainsFrozen: true,
            exactMLXRevision:
                "d37885a278f1c37484a94d0f401a418735e66519",
            requiredEnvironmentKey: "MLX_ENABLE_TF32",
            requiredEnvironmentValue: "0",
            exclusiveEnvironmentKeyPrefix: "MLX_",
            forbiddenEnvironmentKeyPrefixes: ["DYLD_", "LLVM_PROFILE_"],
            numericMode: "float32_tf32_disabled",
            comparisonPolicy:
                "exact_fixture_catalog_shape_dtype_count_and_finiteness_dynamic_output_hash",
            authorityCeiling:
                "one_random_initialized_native300m_full_prefix_forward_no_cache_backward_checkpoint_generation_training_or_product_use"
        )

    @discardableResult
    public static func validateInherited(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        _ = try
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateInherited(environment: environment)
        return declaration
    }

    @discardableResult
    public static func validateLaunched(
        environment: [String: String]
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        _ = try
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicy
                .validateLaunched(environment: environment)
        return declaration
    }

    /// Must run before any CoreGraphics, Metal, MLX, or model operation.
    @discardableResult
    public static func validateLaunchedCurrentProcess(
        processInfo: ProcessInfo = .processInfo
    ) throws
        -> PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    {
        try validateLaunched(environment: processInfo.environment)
    }
}

public struct
    PrimeNativeDecoderTokenizerModelFunctionalCompatibilityConfigurationV1:
    Codable,
    Equatable,
    Sendable
{
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
    public let uniqueParameterCount: Int64

    public static let native300MByte512 = Self(
        vocabularySize: 512,
        modelWidth: 1_024,
        layerCount: 24,
        queryHeadCount: 16,
        keyValueHeadCount: 4,
        headWidth: 64,
        intermediateWidth: 2_816,
        maximumSequenceLength: 2_048,
        ropeThetaFloat32BitPattern: Float(10_000).bitPattern,
        rmsNormEpsilonFloat32BitPattern: Float(1e-5).bitPattern,
        uniqueParameterCount: 271_107_072
    )

    public func validateExactNative300MByte512() throws {
        guard self == Self.native300MByte512 else {
            throw
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityError
                    .contractDrift
        }
    }

    private enum CodingKeys: String, CodingKey {
        case vocabularySize = "vocabulary_size"
        case modelWidth = "model_width"
        case layerCount = "layer_count"
        case queryHeadCount = "query_head_count"
        case keyValueHeadCount = "key_value_head_count"
        case headWidth = "head_width"
        case intermediateWidth = "intermediate_width"
        case maximumSequenceLength = "maximum_sequence_length"
        case ropeThetaFloat32BitPattern =
            "rope_theta_float32_bit_pattern"
        case rmsNormEpsilonFloat32BitPattern =
            "rms_norm_epsilon_float32_bit_pattern"
        case uniqueParameterCount = "unique_parameter_count"
    }
}

/// Append-only authorization for the full Native-300M compatibility witness.
/// It authorizes implementation and one reviewed-main run but observes none of
/// them; every execution or establishment claim therefore remains false.
public struct
    PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let authorityID: String
    public let predecessorObservationID: String
    public let predecessorRemainsFrozen: Bool
    public let predecessorObservationSourcePath: String
    public let predecessorObservationSourceGitBlob: String
    public let predecessorObservationSourceByteCount: Int
    public let predecessorObservationSourceSHA256: String
    public let authoritativeRepository: String
    public let baseRevision: String
    public let baseOrderedParentRevisions: [String]
    public let baseTree: String
    public let baseEmbeddedSourceIdentitySHA256: String
    public let basePullRequestNumber: Int

    public let tokenizerSourceSHA256: String
    public let repairedDecoderSourceSHA256: String
    public let compatibilityIdentityV2SourceSHA256: String
    public let maintainedRuntimeSourceSHA256: String
    public let rootPackageManifestSHA256: String
    public let rootPackageResolvedSHA256: String
    public let exactMLXRevision: String
    public let exactMLXCoreRevision: String
    public let exactMLXCRevision: String
    public let exactSwiftNumericsRevision: String
    public let environmentPolicy:
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1

    public let compatibilityIdentitySchema: String
    public let compatibilityIdentityCanonicalByteCount: Int
    public let compatibilityIdentitySHA256: String
    public let parameterPathSchema: String
    public let tokenizerID: String
    public let tokenizerManifestSHA256: String
    public let tokenizerReplayProbeSHA256: String
    public let sourceText: String
    public let sourceUTF8SHA256: String
    public let canonicalText: String
    public let canonicalUTF8SHA256: String
    public let sequenceTokenIDs: [Int]
    public let sequenceTokenIDsSHA256: String
    public let configuration:
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityConfigurationV1
    public let initializationSeed: UInt64
    public let parameterDescriptorCount: Int
    public let parameterCatalogCanonicalByteCount: Int
    public let parameterCatalogSHA256: String
    public let totalParameterCount: UInt64
    public let totalParameterByteCount: UInt64
    public let requiredModelConstructionCount: Int
    public let requiredForwardInvocationCount: Int
    public let requiredForwardMode: String
    public let requiredMemoryCacheLimit: Int
    public let requiredMemoryCacheClearCount: Int
    public let cacheClearRequiredBeforeParameterMaterialization: Bool
    public let requiredParameterMaterializationEvaluationCount: Int
    public let parameterMaterializationEvaluationAPI: String
    public let parametersMaterializedBeforeForwardRequired: Bool
    public let cacheClearRequiredAfterParameterMaterialization: Bool
    public let cacheClearRequiredBeforeForwardOutputEvaluation: Bool
    public let requiredForwardOutputEvaluationCount: Int
    public let forwardOutputEvaluationAPI: String
    public let cacheClearRequiredAfterForwardOutputEvaluation: Bool
    public let requiredLogitsReadbackCount: Int
    public let logitsReadbackAPI: String
    public let expectedOutputShape: [Int]
    public let expectedOutputDType: String
    public let expectedOutputElementCount: Int
    public let expectedOutputByteCount: Int
    public let outputHashEncoding: String

    public let validationPackagePath: String
    public let validationExecutableTarget: String
    public let validationAuthorityTestTarget: String
    public let compatibilityLauncherPath: String
    public let trustedWorkflowPath: String
    public let authorityAndEvidenceSourceAdditionAuthorized: Bool
    public let isolatedValidationPackageAdditionAuthorized: Bool
    public let isolatedCompatibilityLauncherAdditionAuthorized: Bool
    public let trustedWorkflowCommandExtensionAuthorized: Bool
    public let sourceGatePinExtensionAuthorized: Bool
    public let embeddedBuildProvenanceUpdateAuthorized: Bool
    public let documentationUpdateAuthorized: Bool
    public let tokenizerToModelSequenceMechanicsAuthorized: Bool
    public let native300MModelAllocationAuthorized: Bool
    public let actualParameterCatalogProjectionAuthorized: Bool
    public let singleFullPrefixForwardAuthorized: Bool
    public let reviewedMainExecutionAuthorized: Bool
    public let tokenizerSequenceMechanicsCompatibilityEstablished: Bool
    public let tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished:
        Bool
    public let tokenizerFunctionalCompatibilityEstablished: Bool
    public let modelFunctionalCompatibilityEstablished: Bool
    public let native300MModelAllocationObserved: Bool
    public let decoderForwardObserved: Bool
    public let actualParameterCatalogProjectionObserved: Bool
    public let outputShapeDTypeAndFinitenessObserved: Bool
    public let exactReviewedMainCompatibilityExecutionObserved: Bool

    public let decoderKVCacheUseAuthorized: Bool
    public let backwardAuthorized: Bool
    public let checkpointIOAuthorized: Bool
    public let generationAuthorized: Bool
    public let callerExpectationIsArtifactAdmission: Bool
    public let metallibArtifactProvenanceEstablished: Bool
    public let loadedMetallibIdentityIndependentlyObserved: Bool
    public let physicalGPUIdentityEstablished: Bool
    public let tf32StaticValueDirectlyObserved: Bool
    public let tf32DifferentialObserved: Bool
    public let naxTF32ConsumerPathObserved: Bool
    public let deterministicSeedReplayObserved: Bool
    public let paddingMaskingOrRaggedBatchCompatibilityEstablished: Bool
    public let kvCacheCompatibilityEstablished: Bool
    public let generatedTokenDetokenizationObserved: Bool
    public let semanticModelCompatibilityEstablished: Bool
    public let modelQualityEstablished: Bool
    public let v2ManifestDefined: Bool
    public let v2CodecDefined: Bool
    public let checkpointContainerIOImplemented: Bool
    public let checkpointArtifactAvailable: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let lossBackwardOrGradientObserved: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let trainingResumeEstablished: Bool
    public let trainingExecutionObserved: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let frozenSubsystemMutationAuthorized: Bool
    public let externalRenderingDependencyAuthorized: Bool
    public let newExternalDependencyAuthorized: Bool
    public let rootPackageMutationAuthorized: Bool
    public let frozenSourceMutationAuthorized: Bool
    public let tokenizerSourceMutationAuthorized: Bool
    public let repairedDecoderSourceMutationAuthorized: Bool
    public let checkpointSourceMutationAuthorized: Bool
    public let maintainedRuntimeSourceMutationAuthorized: Bool
    public let predecessorObservationMutationAuthorized: Bool
    public let frozenMetalLauncherMutationAuthorized: Bool
    public let existingValidationMutationAuthorized: Bool
    public let existing44TestInventoryMutationAuthorized: Bool
    public let workflowTopologyMutationAuthorized: Bool
    public let status: String

    public static let frozenV1 = Self(
        schemaVersion: 1,
        authorityID:
            "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_v1",
        predecessorObservationID:
            "ergentics_prime_native_decoder_maintained_runtime_execution_v1",
        predecessorRemainsFrozen: true,
        predecessorObservationSourcePath:
            "Sources/PrimeCore/PrimeNativeDecoderMaintainedRuntimeExecutionObservation.swift",
        predecessorObservationSourceGitBlob:
            "49e107f9fdd2ec5deb262d1885f015c6640eb33c",
        predecessorObservationSourceByteCount: 47_473,
        predecessorObservationSourceSHA256:
            "ecbe1cbacb5da829e867bb1097cf2542eff346ae293488b49deb2f9287edb9c0",
        authoritativeRepository: "Ergentics/ergentics-prime",
        baseRevision: "0760bb2dfea79006e1e588dcb17ac4bab449b069",
        baseOrderedParentRevisions: [
            "b127b2f96c1bcbc8f2ee2017027898853c871469",
            "d60dcba223d188666863cbc569960bb6aec4b56a",
        ],
        baseTree: "d7ffa1dad50a57198df5ce086c8cec19e31cf561",
        baseEmbeddedSourceIdentitySHA256:
            "ed4988ad7daa2110c1fa367f2793326352b91168e790f3c9808a4764fa465223",
        basePullRequestNumber: 73,
        tokenizerSourceSHA256:
            "c1278efca658e6b915c34fcdee8ca5fa1d678d4b709518927c615d5213f8a070",
        repairedDecoderSourceSHA256:
            "058ab392ac74a132a2503a04ab48400d1ef78a1bcad38eaddefce828b9252c9b",
        compatibilityIdentityV2SourceSHA256:
            "2b73886d067015ea65a71944bdc9d0f06025ee65858e9cfccf9a8f0936cf36f3",
        maintainedRuntimeSourceSHA256:
            "71d312d03f81509ece6234067a8b5f43c410ca2941da658134921141037fa981",
        rootPackageManifestSHA256:
            "db81e337640b8eb923dbc90b9e22ce898c371ccffe08eed08050e45c34551400",
        rootPackageResolvedSHA256:
            "a18ded75fe953803945898aba0b04a9cec4fca674f38bf914e5fa45dfdb70741",
        exactMLXRevision: "d37885a278f1c37484a94d0f401a418735e66519",
        exactMLXCoreRevision:
            "ce45c52505c8158ea48d2a54e8caae05efd86bfe",
        exactMLXCRevision: "0726ca922fc902c4c61ef9c27d94132be418e945",
        exactSwiftNumericsRevision:
            "0c0290ff6b24942dadb83a929ffaaa1481df04a2",
        environmentPolicy:
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEnvironmentPolicyV1
                .declaration,
        compatibilityIdentitySchema:
            "ergentics_prime_native_decoder_checkpoint_compatibility_v2",
        compatibilityIdentityCanonicalByteCount: 30_553,
        compatibilityIdentitySHA256:
            "aa3ee5d2208459280a81cc8067facd49cde6449659a766f58456a9c0d6150843",
        parameterPathSchema: "mlxnn_flattened_module_parameters_v1",
        tokenizerID: "ergentics_prime_nfc_utf8_byte_v1",
        tokenizerManifestSHA256:
            "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7",
        tokenizerReplayProbeSHA256:
            "9ce743183b0aecaf4e976d912382ebc11f5f6b07a868f76470dd5a0a6061f5bb",
        sourceText: "A",
        sourceUTF8SHA256:
            "559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd",
        canonicalText: "A",
        canonicalUTF8SHA256:
            "559aead08264d5795d3909718cdd05abd49572e84fe55590eef31a88a08fdffd",
        sequenceTokenIDs: [1, 321, 70],
        sequenceTokenIDsSHA256:
            "ee79e8d0748fc336565d6bd981be781c6eed4d34df268815e442de024127e8b3",
        configuration: .native300MByte512,
        initializationSeed: 42,
        parameterDescriptorCount: 218,
        parameterCatalogCanonicalByteCount: 28_951,
        parameterCatalogSHA256:
            "69c314930eeda2baab0a97378db7189dee0116eaaeb01fd922b10e1ee04c28a1",
        totalParameterCount: 271_107_072,
        totalParameterByteCount: 1_084_428_288,
        requiredModelConstructionCount: 1,
        requiredForwardInvocationCount: 1,
        requiredForwardMode: "full_prefix_no_cache_position_zero",
        requiredMemoryCacheLimit: 0,
        requiredMemoryCacheClearCount: 4,
        cacheClearRequiredBeforeParameterMaterialization: true,
        requiredParameterMaterializationEvaluationCount: 1,
        parameterMaterializationEvaluationAPI:
            "MLX.checkedEval(model)",
        parametersMaterializedBeforeForwardRequired: true,
        cacheClearRequiredAfterParameterMaterialization: true,
        cacheClearRequiredBeforeForwardOutputEvaluation: true,
        requiredForwardOutputEvaluationCount: 1,
        forwardOutputEvaluationAPI: "MLX.checkedEval(logits)",
        cacheClearRequiredAfterForwardOutputEvaluation: true,
        requiredLogitsReadbackCount: 1,
        logitsReadbackAPI: "MLX.MLXArray.asArray(Float.self)",
        expectedOutputShape: [1, 3, 512],
        expectedOutputDType: "float32",
        expectedOutputElementCount: 1_536,
        expectedOutputByteCount: 6_144,
        outputHashEncoding:
            "ordered_big_endian_float32_bit_patterns_v1",
        validationPackagePath:
            "Tests/PrimeNativeDecoderTokenizerCompatibilityValidation",
        validationExecutableTarget:
            "PrimeNativeDecoderTokenizerCompatibilityProbe",
        validationAuthorityTestTarget:
            "PrimeNativeDecoderTokenizerCompatibilityAuthorityTests",
        compatibilityLauncherPath:
            ".github/scripts/prime-ci-native-decoder-tokenizer-compatibility.sh",
        trustedWorkflowPath:
            ".github/workflows/prime-active-root-quarantine.yml",
        authorityAndEvidenceSourceAdditionAuthorized: true,
        isolatedValidationPackageAdditionAuthorized: true,
        isolatedCompatibilityLauncherAdditionAuthorized: true,
        trustedWorkflowCommandExtensionAuthorized: true,
        sourceGatePinExtensionAuthorized: true,
        embeddedBuildProvenanceUpdateAuthorized: true,
        documentationUpdateAuthorized: true,
        tokenizerToModelSequenceMechanicsAuthorized: true,
        native300MModelAllocationAuthorized: true,
        actualParameterCatalogProjectionAuthorized: true,
        singleFullPrefixForwardAuthorized: true,
        reviewedMainExecutionAuthorized: true,
        tokenizerSequenceMechanicsCompatibilityEstablished: false,
        tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished:
            false,
        tokenizerFunctionalCompatibilityEstablished: false,
        modelFunctionalCompatibilityEstablished: false,
        native300MModelAllocationObserved: false,
        decoderForwardObserved: false,
        actualParameterCatalogProjectionObserved: false,
        outputShapeDTypeAndFinitenessObserved: false,
        exactReviewedMainCompatibilityExecutionObserved: false,
        decoderKVCacheUseAuthorized: false,
        backwardAuthorized: false,
        checkpointIOAuthorized: false,
        generationAuthorized: false,
        callerExpectationIsArtifactAdmission: false,
        metallibArtifactProvenanceEstablished: false,
        loadedMetallibIdentityIndependentlyObserved: false,
        physicalGPUIdentityEstablished: false,
        tf32StaticValueDirectlyObserved: false,
        tf32DifferentialObserved: false,
        naxTF32ConsumerPathObserved: false,
        deterministicSeedReplayObserved: false,
        paddingMaskingOrRaggedBatchCompatibilityEstablished: false,
        kvCacheCompatibilityEstablished: false,
        generatedTokenDetokenizationObserved: false,
        semanticModelCompatibilityEstablished: false,
        modelQualityEstablished: false,
        v2ManifestDefined: false,
        v2CodecDefined: false,
        checkpointContainerIOImplemented: false,
        checkpointArtifactAvailable: false,
        checkpointArtifactProvenanceEstablished: false,
        checkpointAdmissionGranted: false,
        native300MCheckpointWriteAuthorized: false,
        native300MCheckpointLoadAuthorized: false,
        optimizerStateIncluded: false,
        rngStateIncluded: false,
        dataCursorIncluded: false,
        lossBackwardOrGradientObserved: false,
        trainEvaluateSurfaceEstablished: false,
        trainingResumeEstablished: false,
        trainingExecutionObserved: false,
        candidateAdmissionGranted: false,
        trialAuthorized: false,
        canaryReplacementAuthorized: false,
        quantizationAuthorized: false,
        productUseAuthorized: false,
        publicationAuthorized: false,
        frozenSubsystemMutationAuthorized: false,
        externalRenderingDependencyAuthorized: false,
        newExternalDependencyAuthorized: false,
        rootPackageMutationAuthorized: false,
        frozenSourceMutationAuthorized: false,
        tokenizerSourceMutationAuthorized: false,
        repairedDecoderSourceMutationAuthorized: false,
        checkpointSourceMutationAuthorized: false,
        maintainedRuntimeSourceMutationAuthorized: false,
        predecessorObservationMutationAuthorized: false,
        frozenMetalLauncherMutationAuthorized: false,
        existingValidationMutationAuthorized: false,
        existing44TestInventoryMutationAuthorized: false,
        workflowTopologyMutationAuthorized: false,
        status:
            "ABSTAIN_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_authorized_not_observed"
    )

    public func validateExactV1() throws {
        let predecessor =
            PrimeNativeDecoderMaintainedRuntimeExecutionObservationV1
                .frozenV1
        do {
            try predecessor.validateExactV1()
            try configuration.validateExactNative300MByte512()
        } catch {
            throw
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityError
                    .contractDrift
        }
        guard self == Self.frozenV1,
              predecessorObservationID == predecessor.observationID,
              predecessorRemainsFrozen,
              baseOrderedParentRevisions.count == 2,
              exactMLXRevision == environmentPolicy.exactMLXRevision,
              sequenceTokenIDs == [1, 321, 70],
              tokenizerManifestSHA256
                == "f9f768268edb488aaf7168453b703f2d2a78a1036572368c76f53f4f436434c7",
              parameterDescriptorCount == 218,
              totalParameterCount == 271_107_072,
              totalParameterByteCount == totalParameterCount * 4,
              requiredModelConstructionCount == 1,
              requiredForwardInvocationCount == 1,
              requiredMemoryCacheLimit == 0,
              requiredMemoryCacheClearCount == 4,
              cacheClearRequiredBeforeParameterMaterialization,
              requiredParameterMaterializationEvaluationCount == 1,
              parameterMaterializationEvaluationAPI
                == "MLX.checkedEval(model)",
              parametersMaterializedBeforeForwardRequired,
              cacheClearRequiredAfterParameterMaterialization,
              cacheClearRequiredBeforeForwardOutputEvaluation,
              requiredForwardOutputEvaluationCount == 1,
              forwardOutputEvaluationAPI == "MLX.checkedEval(logits)",
              cacheClearRequiredAfterForwardOutputEvaluation,
              requiredLogitsReadbackCount == 1,
              logitsReadbackAPI == "MLX.MLXArray.asArray(Float.self)",
              expectedOutputShape == [1, 3, 512],
              expectedOutputElementCount == expectedOutputShape.reduce(1, *),
              expectedOutputByteCount == expectedOutputElementCount * 4,
              outputHashEncoding
                == "ordered_big_endian_float32_bit_patterns_v1",
              authorityAndEvidenceSourceAdditionAuthorized,
              isolatedValidationPackageAdditionAuthorized,
              isolatedCompatibilityLauncherAdditionAuthorized,
              trustedWorkflowCommandExtensionAuthorized,
              sourceGatePinExtensionAuthorized,
              embeddedBuildProvenanceUpdateAuthorized,
              documentationUpdateAuthorized,
              tokenizerToModelSequenceMechanicsAuthorized,
              native300MModelAllocationAuthorized,
              actualParameterCatalogProjectionAuthorized,
              singleFullPrefixForwardAuthorized,
              reviewedMainExecutionAuthorized,
              !tokenizerSequenceMechanicsCompatibilityEstablished,
              !tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished,
              !tokenizerFunctionalCompatibilityEstablished,
              !modelFunctionalCompatibilityEstablished,
              !native300MModelAllocationObserved,
              !decoderForwardObserved,
              !actualParameterCatalogProjectionObserved,
              !outputShapeDTypeAndFinitenessObserved,
              !exactReviewedMainCompatibilityExecutionObserved,
              !decoderKVCacheUseAuthorized,
              !backwardAuthorized,
              !checkpointIOAuthorized,
              !generationAuthorized,
              !callerExpectationIsArtifactAdmission,
              !metallibArtifactProvenanceEstablished,
              !loadedMetallibIdentityIndependentlyObserved,
              !physicalGPUIdentityEstablished,
              !tf32StaticValueDirectlyObserved,
              !tf32DifferentialObserved,
              !naxTF32ConsumerPathObserved,
              !deterministicSeedReplayObserved,
              !paddingMaskingOrRaggedBatchCompatibilityEstablished,
              !kvCacheCompatibilityEstablished,
              !generatedTokenDetokenizationObserved,
              !semanticModelCompatibilityEstablished,
              !modelQualityEstablished,
              !v2ManifestDefined,
              !v2CodecDefined,
              !checkpointContainerIOImplemented,
              !checkpointArtifactAvailable,
              !checkpointArtifactProvenanceEstablished,
              !checkpointAdmissionGranted,
              !native300MCheckpointWriteAuthorized,
              !native300MCheckpointLoadAuthorized,
              !optimizerStateIncluded,
              !rngStateIncluded,
              !dataCursorIncluded,
              !lossBackwardOrGradientObserved,
              !trainEvaluateSurfaceEstablished,
              !trainingResumeEstablished,
              !trainingExecutionObserved,
              !candidateAdmissionGranted,
              !trialAuthorized,
              !canaryReplacementAuthorized,
              !quantizationAuthorized,
              !productUseAuthorized,
              !publicationAuthorized,
              !frozenSubsystemMutationAuthorized,
              !externalRenderingDependencyAuthorized,
              !newExternalDependencyAuthorized,
              !rootPackageMutationAuthorized,
              !frozenSourceMutationAuthorized,
              !tokenizerSourceMutationAuthorized,
              !repairedDecoderSourceMutationAuthorized,
              !checkpointSourceMutationAuthorized,
              !maintainedRuntimeSourceMutationAuthorized,
              !predecessorObservationMutationAuthorized,
              !frozenMetalLauncherMutationAuthorized,
              !existingValidationMutationAuthorized,
              !existing44TestInventoryMutationAuthorized,
              !workflowTopologyMutationAuthorized,
              status
                == "ABSTAIN_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_authorized_not_observed"
        else {
            throw
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityError
                    .contractDrift
        }
    }
}

/// Dynamic, process-local evidence. A later append-only source must bind the
/// reviewed-main run before these facts become durable repository authority.
public struct
    PrimeNativeDecoderTokenizerModelFunctionalCompatibilityEvidenceV1:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let evidenceID: String
    public let authorityID: String
    public let executedRevision: String
    public let executedTree: String
    public let executedEmbeddedSourceIdentitySHA256: String
    public let environmentPolicy:
        PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1
    public let launchedEnvironmentValidatedBeforeFrameworkAccess: Bool
    public let launchedEnvironmentRevalidatedAfterEvaluation: Bool
    public let releaseInstrumentationEvidenceAbsent: Bool
    public let coreGraphicsBootstrapObserved: Bool
    public let enumeratedMetalDeviceCount: Int
    public let defaultMetalDeviceMatchedIndexZero: Bool
    public let mlxDeviceType: String
    public let mlxDeviceIndex: Int
    public let metalLeaseHeldBeforeAndAfterEvaluation: Bool
    public let tokenizerManifestSHA256: String
    public let tokenizerReplayProbeSHA256: String
    public let tokenizerManifestAndReplayValidated: Bool
    public let sourceText: String
    public let sourceUTF8SHA256: String
    public let canonicalText: String
    public let canonicalUTF8SHA256: String
    public let primarySequenceTokenIDs: [Int]
    public let independentSequenceTokenIDs: [Int]
    public let sequenceTokenIDsSHA256: String
    public let primaryAndIndependentTokenPathsAgree: Bool
    public let decodedText: String
    public let decodeRoundTripEstablished: Bool
    public let compatibilityIdentityCanonicalByteCount: Int
    public let compatibilityIdentitySHA256: String
    public let compatibilityIdentityValidated: Bool
    public let configuration:
        PrimeNativeDecoderTokenizerModelFunctionalCompatibilityConfigurationV1
    public let initializationSeed: UInt64
    public let modelConstructionCount: Int
    public let parameterDescriptorCount: Int
    public let parameterCatalogCanonicalByteCount: Int
    public let parameterCatalogSHA256: String
    public let parameterPathSetMatches: Bool
    public let parameterPathOrderMatches: Bool
    public let parameterPathOrder: String
    public let parameterShapesMatch: Bool
    public let parameterDTypesMatch: Bool
    public let observedParameterCount: UInt64
    public let observedParameterByteCount: UInt64
    public let forwardInvocationCount: Int
    public let forwardMode: String
    public let decoderKVCacheUsed: Bool
    public let backwardInvoked: Bool
    public let checkpointIOObserved: Bool
    public let generationInvoked: Bool
    public let memoryCacheLimit: Int
    public let memoryCacheClearCount: Int
    public let cacheClearedBeforeParameterMaterialization: Bool
    public let parameterMaterializationEvaluationCount: Int
    public let parameterMaterializationEvaluationAPI: String
    public let parametersMaterializedBeforeForward: Bool
    public let cacheClearedAfterParameterMaterialization: Bool
    public let cacheClearedBeforeForwardOutputEvaluation: Bool
    public let forwardOutputEvaluationCount: Int
    public let forwardOutputEvaluationAPI: String
    public let cacheClearedAfterForwardOutputEvaluation: Bool
    public let logitsReadbackCount: Int
    public let logitsReadbackAPI: String
    public let outputShape: [Int]
    public let outputDType: String
    public let outputElementCount: Int
    public let outputByteCount: Int
    public let outputAllFinite: Bool
    public let outputFiniteValueCount: Int
    public let outputHashEncoding: String
    public let outputFloat32BitPatternSHA256: String
    public let metallibArtifactRelativePath: String
    public let metallibByteCount: UInt64
    public let metallibSHA256: String
    public let existingMetallibCandidateCountBeforeExecution: Int
    public let existingMetallibCandidateCountAfterExecution: Int
    public let metallibPathAndDescriptorReverified: Bool
    public let metalLibraryValidatedFromExactURL: Bool

    public let tokenizerSequenceMechanicsCompatibilityEstablished: Bool
    public let tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished:
        Bool
    public let tokenizerFunctionalCompatibilityEstablished: Bool
    public let modelFunctionalCompatibilityEstablished: Bool
    public let native300MModelAllocationObserved: Bool
    public let decoderForwardObserved: Bool
    public let actualParameterCatalogProjectionObserved: Bool
    public let outputShapeDTypeAndFinitenessObserved: Bool
    public let callerSuppliedRevisionBindingIsIndependentObservation: Bool
    public let callerExpectationIsArtifactAdmission: Bool
    public let metallibArtifactProvenanceEstablished: Bool
    public let loadedMetallibIdentityIndependentlyObserved: Bool
    public let physicalGPUIdentityEstablished: Bool
    public let tf32StaticValueDirectlyObserved: Bool
    public let tf32DifferentialObserved: Bool
    public let naxTF32ConsumerPathObserved: Bool
    public let deterministicSeedReplayObserved: Bool
    public let paddingMaskingOrRaggedBatchCompatibilityEstablished: Bool
    public let kvCacheCompatibilityEstablished: Bool
    public let generatedTokenDetokenizationObserved: Bool
    public let semanticModelCompatibilityEstablished: Bool
    public let modelQualityEstablished: Bool
    public let v2ManifestDefined: Bool
    public let v2CodecDefined: Bool
    public let checkpointContainerIOImplemented: Bool
    public let checkpointArtifactAvailable: Bool
    public let checkpointArtifactProvenanceEstablished: Bool
    public let checkpointAdmissionGranted: Bool
    public let native300MCheckpointWriteAuthorized: Bool
    public let native300MCheckpointLoadAuthorized: Bool
    public let optimizerStateIncluded: Bool
    public let rngStateIncluded: Bool
    public let dataCursorIncluded: Bool
    public let lossBackwardOrGradientObserved: Bool
    public let trainEvaluateSurfaceEstablished: Bool
    public let trainingResumeEstablished: Bool
    public let trainingExecutionObserved: Bool
    public let candidateAdmissionGranted: Bool
    public let trialAuthorized: Bool
    public let canaryReplacementAuthorized: Bool
    public let quantizationAuthorized: Bool
    public let productUseAuthorized: Bool
    public let publicationAuthorized: Bool
    public let frozenSubsystemMutationAuthorized: Bool
    public let externalRenderingDependencyAuthorized: Bool
    public let newExternalDependencyAuthorized: Bool
    public let processExitRequiredAfterReceipt: Bool
    public let status: String

    public init(
        executedRevision: String,
        executedTree: String,
        executedEmbeddedSourceIdentitySHA256: String,
        environmentPolicy:
            PrimeNativeDecoderMaintainedRuntimeComputeEnvironmentPolicyDeclarationV1,
        launchedEnvironmentValidatedBeforeFrameworkAccess: Bool,
        launchedEnvironmentRevalidatedAfterEvaluation: Bool,
        releaseInstrumentationEvidenceAbsent: Bool,
        coreGraphicsBootstrapObserved: Bool,
        enumeratedMetalDeviceCount: Int,
        defaultMetalDeviceMatchedIndexZero: Bool,
        mlxDeviceType: String,
        mlxDeviceIndex: Int,
        metalLeaseHeldBeforeAndAfterEvaluation: Bool,
        tokenizerManifestSHA256: String,
        tokenizerReplayProbeSHA256: String,
        tokenizerManifestAndReplayValidated: Bool,
        sourceText: String,
        sourceUTF8SHA256: String,
        canonicalText: String,
        canonicalUTF8SHA256: String,
        primarySequenceTokenIDs: [Int],
        independentSequenceTokenIDs: [Int],
        sequenceTokenIDsSHA256: String,
        primaryAndIndependentTokenPathsAgree: Bool,
        decodedText: String,
        decodeRoundTripEstablished: Bool,
        compatibilityIdentityCanonicalByteCount: Int,
        compatibilityIdentitySHA256: String,
        compatibilityIdentityValidated: Bool,
        configuration:
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityConfigurationV1,
        initializationSeed: UInt64,
        modelConstructionCount: Int,
        parameterDescriptorCount: Int,
        parameterCatalogCanonicalByteCount: Int,
        parameterCatalogSHA256: String,
        parameterPathSetMatches: Bool,
        parameterPathOrderMatches: Bool,
        parameterPathOrder: String,
        parameterShapesMatch: Bool,
        parameterDTypesMatch: Bool,
        observedParameterCount: UInt64,
        observedParameterByteCount: UInt64,
        forwardInvocationCount: Int,
        forwardMode: String,
        decoderKVCacheUsed: Bool,
        backwardInvoked: Bool,
        checkpointIOObserved: Bool,
        generationInvoked: Bool,
        memoryCacheLimit: Int,
        memoryCacheClearCount: Int,
        cacheClearedBeforeParameterMaterialization: Bool,
        parameterMaterializationEvaluationCount: Int,
        parameterMaterializationEvaluationAPI: String,
        parametersMaterializedBeforeForward: Bool,
        cacheClearedAfterParameterMaterialization: Bool,
        cacheClearedBeforeForwardOutputEvaluation: Bool,
        forwardOutputEvaluationCount: Int,
        forwardOutputEvaluationAPI: String,
        cacheClearedAfterForwardOutputEvaluation: Bool,
        logitsReadbackCount: Int,
        logitsReadbackAPI: String,
        outputShape: [Int],
        outputDType: String,
        outputElementCount: Int,
        outputByteCount: Int,
        outputAllFinite: Bool,
        outputFiniteValueCount: Int,
        outputHashEncoding: String,
        outputFloat32BitPatternSHA256: String,
        metallibArtifactRelativePath: String,
        metallibByteCount: UInt64,
        metallibSHA256: String,
        existingMetallibCandidateCountBeforeExecution: Int,
        existingMetallibCandidateCountAfterExecution: Int,
        metallibPathAndDescriptorReverified: Bool,
        metalLibraryValidatedFromExactURL: Bool
    ) throws {
        self.schemaVersion = 1
        self.evidenceID =
            "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1"
        self.authorityID =
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
                .frozenV1.authorityID
        self.executedRevision = executedRevision
        self.executedTree = executedTree
        self.executedEmbeddedSourceIdentitySHA256 =
            executedEmbeddedSourceIdentitySHA256
        self.environmentPolicy = environmentPolicy
        self.launchedEnvironmentValidatedBeforeFrameworkAccess =
            launchedEnvironmentValidatedBeforeFrameworkAccess
        self.launchedEnvironmentRevalidatedAfterEvaluation =
            launchedEnvironmentRevalidatedAfterEvaluation
        self.releaseInstrumentationEvidenceAbsent =
            releaseInstrumentationEvidenceAbsent
        self.coreGraphicsBootstrapObserved = coreGraphicsBootstrapObserved
        self.enumeratedMetalDeviceCount = enumeratedMetalDeviceCount
        self.defaultMetalDeviceMatchedIndexZero =
            defaultMetalDeviceMatchedIndexZero
        self.mlxDeviceType = mlxDeviceType
        self.mlxDeviceIndex = mlxDeviceIndex
        self.metalLeaseHeldBeforeAndAfterEvaluation =
            metalLeaseHeldBeforeAndAfterEvaluation
        self.tokenizerManifestSHA256 = tokenizerManifestSHA256
        self.tokenizerReplayProbeSHA256 = tokenizerReplayProbeSHA256
        self.tokenizerManifestAndReplayValidated =
            tokenizerManifestAndReplayValidated
        self.sourceText = sourceText
        self.sourceUTF8SHA256 = sourceUTF8SHA256
        self.canonicalText = canonicalText
        self.canonicalUTF8SHA256 = canonicalUTF8SHA256
        self.primarySequenceTokenIDs = primarySequenceTokenIDs
        self.independentSequenceTokenIDs = independentSequenceTokenIDs
        self.sequenceTokenIDsSHA256 = sequenceTokenIDsSHA256
        self.primaryAndIndependentTokenPathsAgree =
            primaryAndIndependentTokenPathsAgree
        self.decodedText = decodedText
        self.decodeRoundTripEstablished = decodeRoundTripEstablished
        self.compatibilityIdentityCanonicalByteCount =
            compatibilityIdentityCanonicalByteCount
        self.compatibilityIdentitySHA256 = compatibilityIdentitySHA256
        self.compatibilityIdentityValidated = compatibilityIdentityValidated
        self.configuration = configuration
        self.initializationSeed = initializationSeed
        self.modelConstructionCount = modelConstructionCount
        self.parameterDescriptorCount = parameterDescriptorCount
        self.parameterCatalogCanonicalByteCount =
            parameterCatalogCanonicalByteCount
        self.parameterCatalogSHA256 = parameterCatalogSHA256
        self.parameterPathSetMatches = parameterPathSetMatches
        self.parameterPathOrderMatches = parameterPathOrderMatches
        self.parameterPathOrder = parameterPathOrder
        self.parameterShapesMatch = parameterShapesMatch
        self.parameterDTypesMatch = parameterDTypesMatch
        self.observedParameterCount = observedParameterCount
        self.observedParameterByteCount = observedParameterByteCount
        self.forwardInvocationCount = forwardInvocationCount
        self.forwardMode = forwardMode
        self.decoderKVCacheUsed = decoderKVCacheUsed
        self.backwardInvoked = backwardInvoked
        self.checkpointIOObserved = checkpointIOObserved
        self.generationInvoked = generationInvoked
        self.memoryCacheLimit = memoryCacheLimit
        self.memoryCacheClearCount = memoryCacheClearCount
        self.cacheClearedBeforeParameterMaterialization =
            cacheClearedBeforeParameterMaterialization
        self.parameterMaterializationEvaluationCount =
            parameterMaterializationEvaluationCount
        self.parameterMaterializationEvaluationAPI =
            parameterMaterializationEvaluationAPI
        self.parametersMaterializedBeforeForward =
            parametersMaterializedBeforeForward
        self.cacheClearedAfterParameterMaterialization =
            cacheClearedAfterParameterMaterialization
        self.cacheClearedBeforeForwardOutputEvaluation =
            cacheClearedBeforeForwardOutputEvaluation
        self.forwardOutputEvaluationCount = forwardOutputEvaluationCount
        self.forwardOutputEvaluationAPI = forwardOutputEvaluationAPI
        self.cacheClearedAfterForwardOutputEvaluation =
            cacheClearedAfterForwardOutputEvaluation
        self.logitsReadbackCount = logitsReadbackCount
        self.logitsReadbackAPI = logitsReadbackAPI
        self.outputShape = outputShape
        self.outputDType = outputDType
        self.outputElementCount = outputElementCount
        self.outputByteCount = outputByteCount
        self.outputAllFinite = outputAllFinite
        self.outputFiniteValueCount = outputFiniteValueCount
        self.outputHashEncoding = outputHashEncoding
        self.outputFloat32BitPatternSHA256 =
            outputFloat32BitPatternSHA256
        self.metallibArtifactRelativePath = metallibArtifactRelativePath
        self.metallibByteCount = metallibByteCount
        self.metallibSHA256 = metallibSHA256
        self.existingMetallibCandidateCountBeforeExecution =
            existingMetallibCandidateCountBeforeExecution
        self.existingMetallibCandidateCountAfterExecution =
            existingMetallibCandidateCountAfterExecution
        self.metallibPathAndDescriptorReverified =
            metallibPathAndDescriptorReverified
        self.metalLibraryValidatedFromExactURL =
            metalLibraryValidatedFromExactURL

        tokenizerSequenceMechanicsCompatibilityEstablished = true
        tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished =
            true
        tokenizerFunctionalCompatibilityEstablished = true
        modelFunctionalCompatibilityEstablished = false
        native300MModelAllocationObserved = true
        decoderForwardObserved = true
        actualParameterCatalogProjectionObserved = true
        outputShapeDTypeAndFinitenessObserved = true
        callerSuppliedRevisionBindingIsIndependentObservation = false
        callerExpectationIsArtifactAdmission = false
        metallibArtifactProvenanceEstablished = false
        loadedMetallibIdentityIndependentlyObserved = false
        physicalGPUIdentityEstablished = false
        tf32StaticValueDirectlyObserved = false
        tf32DifferentialObserved = false
        naxTF32ConsumerPathObserved = false
        deterministicSeedReplayObserved = false
        paddingMaskingOrRaggedBatchCompatibilityEstablished = false
        kvCacheCompatibilityEstablished = false
        generatedTokenDetokenizationObserved = false
        semanticModelCompatibilityEstablished = false
        modelQualityEstablished = false
        v2ManifestDefined = false
        v2CodecDefined = false
        checkpointContainerIOImplemented = false
        checkpointArtifactAvailable = false
        checkpointArtifactProvenanceEstablished = false
        checkpointAdmissionGranted = false
        native300MCheckpointWriteAuthorized = false
        native300MCheckpointLoadAuthorized = false
        optimizerStateIncluded = false
        rngStateIncluded = false
        dataCursorIncluded = false
        lossBackwardOrGradientObserved = false
        trainEvaluateSurfaceEstablished = false
        trainingResumeEstablished = false
        trainingExecutionObserved = false
        candidateAdmissionGranted = false
        trialAuthorized = false
        canaryReplacementAuthorized = false
        quantizationAuthorized = false
        productUseAuthorized = false
        publicationAuthorized = false
        frozenSubsystemMutationAuthorized = false
        externalRenderingDependencyAuthorized = false
        newExternalDependencyAuthorized = false
        processExitRequiredAfterReceipt = true
        status =
            "PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only"
        try validate()
    }

    public func validate() throws {
        let authority =
            PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityPlanV1
                .frozenV1
        do {
            try authority.validateExactV1()
            try configuration.validateExactNative300MByte512()
        } catch {
            throw
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityError
                    .contractDrift
        }
        guard schemaVersion == 1,
              evidenceID
                == "ergentics_prime_native_decoder_tokenizer_model_functional_compatibility_evidence_v1",
              authorityID == authority.authorityID,
              isExactGitObjectID(executedRevision),
              isExactGitObjectID(executedTree),
              isExactSHA256(executedEmbeddedSourceIdentitySHA256),
              environmentPolicy == authority.environmentPolicy,
              launchedEnvironmentValidatedBeforeFrameworkAccess,
              launchedEnvironmentRevalidatedAfterEvaluation,
              releaseInstrumentationEvidenceAbsent,
              coreGraphicsBootstrapObserved,
              enumeratedMetalDeviceCount == 1,
              defaultMetalDeviceMatchedIndexZero,
              mlxDeviceType == "gpu",
              mlxDeviceIndex == 0,
              metalLeaseHeldBeforeAndAfterEvaluation,
              tokenizerManifestSHA256 == authority.tokenizerManifestSHA256,
              tokenizerReplayProbeSHA256
                == authority.tokenizerReplayProbeSHA256,
              tokenizerManifestAndReplayValidated,
              sourceText == authority.sourceText,
              sourceUTF8SHA256 == authority.sourceUTF8SHA256,
              canonicalText == authority.canonicalText,
              canonicalUTF8SHA256 == authority.canonicalUTF8SHA256,
              primarySequenceTokenIDs == authority.sequenceTokenIDs,
              independentSequenceTokenIDs == authority.sequenceTokenIDs,
              sequenceTokenIDsSHA256 == authority.sequenceTokenIDsSHA256,
              primaryAndIndependentTokenPathsAgree,
              decodedText == authority.canonicalText,
              decodeRoundTripEstablished,
              compatibilityIdentityCanonicalByteCount
                == authority.compatibilityIdentityCanonicalByteCount,
              compatibilityIdentitySHA256
                == authority.compatibilityIdentitySHA256,
              compatibilityIdentityValidated,
              configuration == authority.configuration,
              initializationSeed == authority.initializationSeed,
              modelConstructionCount
                == authority.requiredModelConstructionCount,
              parameterDescriptorCount == authority.parameterDescriptorCount,
              parameterCatalogCanonicalByteCount
                == authority.parameterCatalogCanonicalByteCount,
              parameterCatalogSHA256 == authority.parameterCatalogSHA256,
              parameterPathSetMatches,
              parameterPathOrderMatches,
              parameterPathOrder == "global_lexicographic_ascending_utf8_v1",
              parameterShapesMatch,
              parameterDTypesMatch,
              observedParameterCount == authority.totalParameterCount,
              observedParameterByteCount == authority.totalParameterByteCount,
              forwardInvocationCount
                == authority.requiredForwardInvocationCount,
              forwardMode == authority.requiredForwardMode,
              !decoderKVCacheUsed,
              !backwardInvoked,
              !checkpointIOObserved,
              !generationInvoked,
              memoryCacheLimit == authority.requiredMemoryCacheLimit,
              memoryCacheClearCount
                == authority.requiredMemoryCacheClearCount,
              cacheClearedBeforeParameterMaterialization,
              parameterMaterializationEvaluationCount
                == authority.requiredParameterMaterializationEvaluationCount,
              parameterMaterializationEvaluationAPI
                == authority.parameterMaterializationEvaluationAPI,
              parametersMaterializedBeforeForward,
              cacheClearedAfterParameterMaterialization,
              cacheClearedBeforeForwardOutputEvaluation,
              forwardOutputEvaluationCount
                == authority.requiredForwardOutputEvaluationCount,
              forwardOutputEvaluationAPI
                == authority.forwardOutputEvaluationAPI,
              cacheClearedAfterForwardOutputEvaluation,
              logitsReadbackCount == authority.requiredLogitsReadbackCount,
              logitsReadbackAPI == authority.logitsReadbackAPI,
              outputShape == authority.expectedOutputShape,
              outputDType == authority.expectedOutputDType,
              outputElementCount == authority.expectedOutputElementCount,
              outputByteCount == authority.expectedOutputByteCount,
              outputAllFinite,
              outputFiniteValueCount == authority.expectedOutputElementCount,
              outputHashEncoding == authority.outputHashEncoding,
              isExactSHA256(outputFloat32BitPatternSHA256),
              metallibArtifactRelativePath
                == PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .artifactRelativePath,
              metallibByteCount > 0,
              metallibByteCount
                <= PrimeNativeDecoderMaintainedRuntimeMetallibExpectationV1
                    .maximumByteCount,
              isExactSHA256(metallibSHA256),
              existingMetallibCandidateCountBeforeExecution == 1,
              existingMetallibCandidateCountAfterExecution == 1,
              metallibPathAndDescriptorReverified,
              metalLibraryValidatedFromExactURL,
              tokenizerSequenceMechanicsCompatibilityEstablished,
              tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished,
              tokenizerFunctionalCompatibilityEstablished,
              !modelFunctionalCompatibilityEstablished,
              native300MModelAllocationObserved,
              decoderForwardObserved,
              actualParameterCatalogProjectionObserved,
              outputShapeDTypeAndFinitenessObserved,
              falseCeilingsAreExact,
              processExitRequiredAfterReceipt,
              status
                == "PASS_process_local_tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_only"
        else {
            throw
                PrimeNativeDecoderTokenizerModelFunctionalCompatibilityAuthorityError
                    .contractDrift
        }
    }

    private var falseCeilingsAreExact: Bool {
        !callerSuppliedRevisionBindingIsIndependentObservation
            && !callerExpectationIsArtifactAdmission
            && !metallibArtifactProvenanceEstablished
            && !loadedMetallibIdentityIndependentlyObserved
            && !physicalGPUIdentityEstablished
            && !tf32StaticValueDirectlyObserved
            && !tf32DifferentialObserved
            && !naxTF32ConsumerPathObserved
            && !deterministicSeedReplayObserved
            && !paddingMaskingOrRaggedBatchCompatibilityEstablished
            && !kvCacheCompatibilityEstablished
            && !generatedTokenDetokenizationObserved
            && !semanticModelCompatibilityEstablished
            && !modelQualityEstablished
            && !v2ManifestDefined
            && !v2CodecDefined
            && !checkpointContainerIOImplemented
            && !checkpointArtifactAvailable
            && !checkpointArtifactProvenanceEstablished
            && !checkpointAdmissionGranted
            && !native300MCheckpointWriteAuthorized
            && !native300MCheckpointLoadAuthorized
            && !optimizerStateIncluded
            && !rngStateIncluded
            && !dataCursorIncluded
            && !lossBackwardOrGradientObserved
            && !trainEvaluateSurfaceEstablished
            && !trainingResumeEstablished
            && !trainingExecutionObserved
            && !candidateAdmissionGranted
            && !trialAuthorized
            && !canaryReplacementAuthorized
            && !quantizationAuthorized
            && !productUseAuthorized
            && !publicationAuthorized
            && !frozenSubsystemMutationAuthorized
            && !externalRenderingDependencyAuthorized
            && !newExternalDependencyAuthorized
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case evidenceID = "evidence_id"
        case authorityID = "authority_id"
        case executedRevision = "executed_revision"
        case executedTree = "executed_tree"
        case executedEmbeddedSourceIdentitySHA256 =
            "executed_embedded_source_identity_sha256"
        case environmentPolicy = "environment_policy"
        case launchedEnvironmentValidatedBeforeFrameworkAccess =
            "launched_environment_validated_before_framework_access"
        case launchedEnvironmentRevalidatedAfterEvaluation =
            "launched_environment_revalidated_after_evaluation"
        case releaseInstrumentationEvidenceAbsent =
            "release_instrumentation_evidence_absent"
        case coreGraphicsBootstrapObserved =
            "core_graphics_bootstrap_observed"
        case enumeratedMetalDeviceCount = "enumerated_metal_device_count"
        case defaultMetalDeviceMatchedIndexZero =
            "default_metal_device_matched_index_zero"
        case mlxDeviceType = "mlx_device_type"
        case mlxDeviceIndex = "mlx_device_index"
        case metalLeaseHeldBeforeAndAfterEvaluation =
            "metal_lease_held_before_and_after_evaluation"
        case tokenizerManifestSHA256 = "tokenizer_manifest_sha256"
        case tokenizerReplayProbeSHA256 = "tokenizer_replay_probe_sha256"
        case tokenizerManifestAndReplayValidated =
            "tokenizer_manifest_and_replay_validated"
        case sourceText = "source_text"
        case sourceUTF8SHA256 = "source_utf8_sha256"
        case canonicalText = "canonical_text"
        case canonicalUTF8SHA256 = "canonical_utf8_sha256"
        case primarySequenceTokenIDs = "primary_sequence_token_ids"
        case independentSequenceTokenIDs = "independent_sequence_token_ids"
        case sequenceTokenIDsSHA256 = "sequence_token_ids_sha256"
        case primaryAndIndependentTokenPathsAgree =
            "primary_and_independent_token_paths_agree"
        case decodedText = "decoded_text"
        case decodeRoundTripEstablished = "decode_round_trip_established"
        case compatibilityIdentityCanonicalByteCount =
            "compatibility_identity_canonical_byte_count"
        case compatibilityIdentitySHA256 = "compatibility_identity_sha256"
        case compatibilityIdentityValidated =
            "compatibility_identity_validated"
        case configuration
        case initializationSeed = "initialization_seed"
        case modelConstructionCount = "model_construction_count"
        case parameterDescriptorCount = "parameter_descriptor_count"
        case parameterCatalogCanonicalByteCount =
            "parameter_catalog_canonical_byte_count"
        case parameterCatalogSHA256 = "parameter_catalog_sha256"
        case parameterPathSetMatches = "parameter_path_set_matches"
        case parameterPathOrderMatches = "parameter_path_order_matches"
        case parameterPathOrder = "parameter_path_order"
        case parameterShapesMatch = "parameter_shapes_match"
        case parameterDTypesMatch = "parameter_dtypes_match"
        case observedParameterCount = "observed_parameter_count"
        case observedParameterByteCount = "observed_parameter_byte_count"
        case forwardInvocationCount = "forward_invocation_count"
        case forwardMode = "forward_mode"
        case decoderKVCacheUsed = "decoder_kv_cache_used"
        case backwardInvoked = "backward_invoked"
        case checkpointIOObserved = "checkpoint_io_observed"
        case generationInvoked = "generation_invoked"
        case memoryCacheLimit = "memory_cache_limit"
        case memoryCacheClearCount = "memory_cache_clear_count"
        case cacheClearedBeforeParameterMaterialization =
            "cache_cleared_before_parameter_materialization"
        case parameterMaterializationEvaluationCount =
            "parameter_materialization_evaluation_count"
        case parameterMaterializationEvaluationAPI =
            "parameter_materialization_evaluation_api"
        case parametersMaterializedBeforeForward =
            "parameters_materialized_before_forward"
        case cacheClearedAfterParameterMaterialization =
            "cache_cleared_after_parameter_materialization"
        case cacheClearedBeforeForwardOutputEvaluation =
            "cache_cleared_before_forward_output_evaluation"
        case forwardOutputEvaluationCount =
            "forward_output_evaluation_count"
        case forwardOutputEvaluationAPI = "forward_output_evaluation_api"
        case cacheClearedAfterForwardOutputEvaluation =
            "cache_cleared_after_forward_output_evaluation"
        case logitsReadbackCount = "logits_readback_count"
        case logitsReadbackAPI = "logits_readback_api"
        case outputShape = "output_shape"
        case outputDType = "output_dtype"
        case outputElementCount = "output_element_count"
        case outputByteCount = "output_byte_count"
        case outputAllFinite = "output_all_finite"
        case outputFiniteValueCount = "output_finite_value_count"
        case outputHashEncoding = "output_hash_encoding"
        case outputFloat32BitPatternSHA256 =
            "output_float32_bit_pattern_sha256"
        case metallibArtifactRelativePath =
            "metallib_artifact_relative_path"
        case metallibByteCount = "metallib_byte_count"
        case metallibSHA256 = "metallib_sha256"
        case existingMetallibCandidateCountBeforeExecution =
            "existing_metallib_candidate_count_before_execution"
        case existingMetallibCandidateCountAfterExecution =
            "existing_metallib_candidate_count_after_execution"
        case metallibPathAndDescriptorReverified =
            "metallib_path_and_descriptor_reverified"
        case metalLibraryValidatedFromExactURL =
            "metal_library_validated_from_exact_url"
        case tokenizerSequenceMechanicsCompatibilityEstablished =
            "tokenizer_sequence_mechanics_compatibility_established"
        case tokenizerToRandomInitializedNative300MFullPrefixForwardWitnessEstablished =
            "tokenizer_to_random_initialized_native300m_full_prefix_forward_witness_established"
        case tokenizerFunctionalCompatibilityEstablished =
            "tokenizer_functional_compatibility_established"
        case modelFunctionalCompatibilityEstablished =
            "model_functional_compatibility_established"
        case native300MModelAllocationObserved =
            "native300m_model_allocation_observed"
        case decoderForwardObserved = "decoder_forward_observed"
        case actualParameterCatalogProjectionObserved =
            "actual_parameter_catalog_projection_observed"
        case outputShapeDTypeAndFinitenessObserved =
            "output_shape_dtype_and_finiteness_observed"
        case callerSuppliedRevisionBindingIsIndependentObservation =
            "caller_supplied_revision_binding_is_independent_observation"
        case callerExpectationIsArtifactAdmission =
            "caller_expectation_is_artifact_admission"
        case metallibArtifactProvenanceEstablished =
            "metallib_artifact_provenance_established"
        case loadedMetallibIdentityIndependentlyObserved =
            "loaded_metallib_identity_independently_observed"
        case physicalGPUIdentityEstablished =
            "physical_gpu_identity_established"
        case tf32StaticValueDirectlyObserved =
            "tf32_static_value_directly_observed"
        case tf32DifferentialObserved = "tf32_differential_observed"
        case naxTF32ConsumerPathObserved =
            "nax_tf32_consumer_path_observed"
        case deterministicSeedReplayObserved =
            "deterministic_seed_replay_observed"
        case paddingMaskingOrRaggedBatchCompatibilityEstablished =
            "padding_masking_or_ragged_batch_compatibility_established"
        case kvCacheCompatibilityEstablished =
            "kv_cache_compatibility_established"
        case generatedTokenDetokenizationObserved =
            "generated_token_detokenization_observed"
        case semanticModelCompatibilityEstablished =
            "semantic_model_compatibility_established"
        case modelQualityEstablished = "model_quality_established"
        case v2ManifestDefined = "v2_manifest_defined"
        case v2CodecDefined = "v2_codec_defined"
        case checkpointContainerIOImplemented =
            "checkpoint_container_io_implemented"
        case checkpointArtifactAvailable = "checkpoint_artifact_available"
        case checkpointArtifactProvenanceEstablished =
            "checkpoint_artifact_provenance_established"
        case checkpointAdmissionGranted = "checkpoint_admission_granted"
        case native300MCheckpointWriteAuthorized =
            "native300m_checkpoint_write_authorized"
        case native300MCheckpointLoadAuthorized =
            "native300m_checkpoint_load_authorized"
        case optimizerStateIncluded = "optimizer_state_included"
        case rngStateIncluded = "rng_state_included"
        case dataCursorIncluded = "data_cursor_included"
        case lossBackwardOrGradientObserved =
            "loss_backward_or_gradient_observed"
        case trainEvaluateSurfaceEstablished =
            "train_evaluate_surface_established"
        case trainingResumeEstablished = "training_resume_established"
        case trainingExecutionObserved = "training_execution_observed"
        case candidateAdmissionGranted = "candidate_admission_granted"
        case trialAuthorized = "trial_authorized"
        case canaryReplacementAuthorized = "canary_replacement_authorized"
        case quantizationAuthorized = "quantization_authorized"
        case productUseAuthorized = "product_use_authorized"
        case publicationAuthorized = "publication_authorized"
        case frozenSubsystemMutationAuthorized =
            "frozen_subsystem_mutation_authorized"
        case externalRenderingDependencyAuthorized =
            "external_rendering_dependency_authorized"
        case newExternalDependencyAuthorized =
            "new_external_dependency_authorized"
        case processExitRequiredAfterReceipt =
            "process_exit_required_after_receipt"
        case status
    }
}

private func isExactSHA256(_ value: String) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy {
            (48 ... 57).contains($0) || (97 ... 102).contains($0)
        }
        && value != String(repeating: "0", count: 64)
}

private func isExactGitObjectID(_ value: String) -> Bool {
    value.utf8.count == 40
        && value.utf8.allSatisfy {
            (48 ... 57).contains($0) || (97 ... 102).contains($0)
        }
        && value != String(repeating: "0", count: 40)
}
