import Foundation

public struct
    PrimeNativeNeuralGateHistoricalEvidenceExportFieldRequirement:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let fieldID: String
    public let cardinalityAndEncodingPolicy: String
    public let sourceAuthority: String
    public let mayBeInferredFromHistoricalSummary: Bool
    public let mayEstablishIndependentDetection: Bool

    fileprivate init(
        ordinal: Int,
        fieldID: String,
        cardinalityAndEncodingPolicy: String,
        sourceAuthority: String
    ) {
        self.ordinal = ordinal
        self.fieldID = fieldID
        self.cardinalityAndEncodingPolicy =
            cardinalityAndEncodingPolicy
        self.sourceAuthority = sourceAuthority
        mayBeInferredFromHistoricalSummary = false
        mayEstablishIndependentDetection = false
    }

    fileprivate func validate() -> Bool {
        ordinal > 0
            && Self.safeIdentifier(fieldID)
            && Self.safeIdentifier(
                cardinalityAndEncodingPolicy
            )
            && Self.safeIdentifier(sourceAuthority)
            && !mayBeInferredFromHistoricalSummary
            && !mayEstablishIndependentDetection
    }

    private static func safeIdentifier(
        _ value: String
    ) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 512
            && value.utf8.allSatisfy {
                ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || ($0 >= 48 && $0 <= 57)
                    || $0 == 95
            }
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case fieldID = "field_id"
        case cardinalityAndEncodingPolicy =
            "cardinality_and_encoding_policy"
        case sourceAuthority = "source_authority"
        case mayBeInferredFromHistoricalSummary =
            "may_be_inferred_from_historical_summary"
        case mayEstablishIndependentDetection =
            "may_establish_independent_detection"
    }
}

public struct
    PrimeNativeNeuralGateHistoricalObservedFailureDomainContract:
    Codable,
    Equatable,
    Sendable
{
    public let orderedPrimitiveLegIDs: [String]
    public let mutationSweepMetaLegID: String
    public let mutationSweepMetaLegExcludedFromPerMutationRegrade:
        Bool
    public let observedSetMustFollowPrimitiveLegOrder: Bool
    public let exactObservedSetRequired: Bool
    public let allowedSetMustEqualExpectedSingleton: Bool
    public let observedSetMustEqualAllowedSet: Bool
    public let expectedLegSingletonMayStandInForObservedSet: Bool
    public let unknownOrDuplicateLegsPermitted: Bool

    fileprivate init(
        orderedPrimitiveLegIDs: [String],
        mutationSweepMetaLegID: String
    ) {
        self.orderedPrimitiveLegIDs = orderedPrimitiveLegIDs
        self.mutationSweepMetaLegID = mutationSweepMetaLegID
        mutationSweepMetaLegExcludedFromPerMutationRegrade =
            true
        observedSetMustFollowPrimitiveLegOrder = true
        exactObservedSetRequired = true
        allowedSetMustEqualExpectedSingleton = true
        observedSetMustEqualAllowedSet = true
        expectedLegSingletonMayStandInForObservedSet = false
        unknownOrDuplicateLegsPermitted = false
    }

    fileprivate func validate(
        against orderedCriticalLegIDs: [String]
    ) -> Bool {
        orderedCriticalLegIDs.count == 10
            && orderedPrimitiveLegIDs
                == Array(orderedCriticalLegIDs.dropLast())
            && mutationSweepMetaLegID
                == orderedCriticalLegIDs.last
            && Set(orderedPrimitiveLegIDs).count
                == orderedPrimitiveLegIDs.count
            && mutationSweepMetaLegExcludedFromPerMutationRegrade
            && observedSetMustFollowPrimitiveLegOrder
            && exactObservedSetRequired
            && allowedSetMustEqualExpectedSingleton
            && observedSetMustEqualAllowedSet
            && !expectedLegSingletonMayStandInForObservedSet
            && !unknownOrDuplicateLegsPermitted
    }

    private enum CodingKeys: String, CodingKey {
        case orderedPrimitiveLegIDs =
            "ordered_primitive_leg_ids"
        case mutationSweepMetaLegID =
            "mutation_sweep_meta_leg_id"
        case mutationSweepMetaLegExcludedFromPerMutationRegrade =
            "mutation_sweep_meta_leg_excluded_from_per_mutation_regrade"
        case observedSetMustFollowPrimitiveLegOrder =
            "observed_set_must_follow_primitive_leg_order"
        case exactObservedSetRequired =
            "exact_observed_set_required"
        case allowedSetMustEqualExpectedSingleton =
            "allowed_set_must_equal_expected_singleton"
        case observedSetMustEqualAllowedSet =
            "observed_set_must_equal_allowed_set"
        case expectedLegSingletonMayStandInForObservedSet =
            "expected_leg_singleton_may_stand_in_for_observed_set"
        case unknownOrDuplicateLegsPermitted =
            "unknown_or_duplicate_legs_permitted"
    }
}

public struct
    PrimeNativeNeuralGateHistoricalMutationFailurePolicy:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let mutationID: String
    public let expectedFailedLegID: String
    public let orderedAllowedFailedLegIDs: [String]
    public let allowedSetMayBeWidenedAtRuntime: Bool
    public let allowedSetMayStandInForObservedSet: Bool

    fileprivate init(
        ordinal: Int,
        mutationID: String,
        expectedFailedLegID: String
    ) {
        self.ordinal = ordinal
        self.mutationID = mutationID
        self.expectedFailedLegID = expectedFailedLegID
        orderedAllowedFailedLegIDs = [expectedFailedLegID]
        allowedSetMayBeWidenedAtRuntime = false
        allowedSetMayStandInForObservedSet = false
    }

    fileprivate func validate(
        against mutation:
            PrimeNativeNeuralGateMutationContract
    ) -> Bool {
        ordinal == mutation.ordinal
            && mutationID == mutation.mutationID
            && expectedFailedLegID
                == mutation.expectedFailedLeg
            && orderedAllowedFailedLegIDs
                == [expectedFailedLegID]
            && !allowedSetMayBeWidenedAtRuntime
            && !allowedSetMayStandInForObservedSet
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case mutationID = "mutation_id"
        case expectedFailedLegID =
            "expected_failed_leg_id"
        case orderedAllowedFailedLegIDs =
            "ordered_allowed_failed_leg_ids"
        case allowedSetMayBeWidenedAtRuntime =
            "allowed_set_may_be_widened_at_runtime"
        case allowedSetMayStandInForObservedSet =
            "allowed_set_may_stand_in_for_observed_set"
    }
}

public struct
    PrimeNativeNeuralGateHistoricalMaterialsBridgeFieldRequirement:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let sourceFieldName: String
    public let destinationParameterName: String
    public let swiftTypeID: String
    public let donorInitializerDefaultPolicy: String
    public let bridgeMustPassExplicitValue: Bool
    public let identityMappingRequired: Bool

    fileprivate init(
        ordinal: Int,
        fieldName: String,
        swiftTypeID: String,
        donorInitializerDefaultPolicy: String
    ) {
        self.ordinal = ordinal
        sourceFieldName = fieldName
        destinationParameterName = fieldName
        self.swiftTypeID = swiftTypeID
        self.donorInitializerDefaultPolicy =
            donorInitializerDefaultPolicy
        bridgeMustPassExplicitValue = true
        identityMappingRequired = true
    }

    fileprivate func validate() -> Bool {
        ordinal > 0
            && Self.safeIdentifier(sourceFieldName)
            && destinationParameterName == sourceFieldName
            && Self.safeIdentifier(swiftTypeID)
            && Self.safeIdentifier(
                donorInitializerDefaultPolicy
            )
            && bridgeMustPassExplicitValue
            && identityMappingRequired
    }

    private static func safeIdentifier(
        _ value: String
    ) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 128
            && value.utf8.allSatisfy {
                ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || ($0 >= 48 && $0 <= 57)
                    || $0 == 95
            }
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case sourceFieldName = "source_field_name"
        case destinationParameterName =
            "destination_parameter_name"
        case swiftTypeID = "swift_type_id"
        case donorInitializerDefaultPolicy =
            "donor_initializer_default_policy"
        case bridgeMustPassExplicitValue =
            "bridge_must_pass_explicit_value"
        case identityMappingRequired =
            "identity_mapping_required"
    }
}

/// Frozen V12 design boundary for a future historical evidence exporter.
///
/// The byte-exact historical gate discards raw invariant records, mutated
/// fingerprints, and complete failed-leg sets behind lexical `private`
/// boundaries. A separate Swift wrapper cannot recover those values. This
/// contract therefore source-binds only the exact whole-gate namespace basis
/// and the evidence semantics that a later isolated, same-file instrumented
/// variant must implement. The variant and its exporter suffix do not exist
/// in the package at V12.
public struct
    PrimeNativeNeuralGateHistoricalEvidenceExportAdapterDesignContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String
    public let companionRepository: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let companionInputCatalogSHA256: String
    public let preservedV11SourceContractID: String
    public let preservedV11SourceContractSHA256: String
    public let preservedTopologyV11ID: String
    public let preservedTopologyV11SHA256: String
    public let donorGateRepositoryRelativePath: String
    public let donorGateGitBlobOID: String
    public let donorGateLineCount: Int
    public let donorGateByteCount: UInt64
    public let donorGateSHA256: String
    public let checkedInByteExactGateRelativePath: String
    public let checkedInByteExactGateByteCount: UInt64
    public let checkedInByteExactGateSHA256: String
    public let futureIsolatedTargetName: String
    public let futureDerivedSourceRelativePath: String
    public let futureDerivedTopLevelTypeName: String
    public let namespaceBasisDerivation:
        PrimeNativeNeuralGateSourceDerivationContract
    public let requiredEvidenceFields:
        [PrimeNativeNeuralGateHistoricalEvidenceExportFieldRequirement]
    public let observedFailureDomain:
        PrimeNativeNeuralGateHistoricalObservedFailureDomainContract
    public let mutationFailurePolicies:
        [PrimeNativeNeuralGateHistoricalMutationFailurePolicy]
    public let exactHistoricalInvariantRecordCount: Int
    public let exactHistoricalInvariantChunkCount: Int
    public let invariantRecordsPerFullChunk: Int
    public let finalInvariantChunkRecordCount: Int
    public let exactHistoricalMutationCount: Int
    public let completeMaterialsBridgeRequired: Bool
    public let completeMaterialsBridgeFieldCount: Int
    public let materialsBridgeFields:
        [PrimeNativeNeuralGateHistoricalMaterialsBridgeFieldRequirement]
    public let derivedMaterialsCacheKeyFieldName: String
    public let derivedMaterialsCacheKeyExcludedFromBridgeCount: Bool
    public let bridgeMayDropOrDefaultFields: Bool
    public let fullSourceDerivedVariantRequired: Bool
    public let thinWrapperPermitted: Bool
    public let compactReconstructionKernelPermitted: Bool
    public let reflectionOrUnsafeMemoryAccessPermitted: Bool
    public let donorAccessLevelMutationPermitted: Bool
    public let originalByteExactGateMutationPermitted: Bool
    public let exporterCarrierCodable: Bool
    public let exporterCarrierRoleNeutral: Bool
    public let exporterCarrierPathFree: Bool
    public let exporterCarrierTimingFree: Bool
    public let exporterCarrierAuthorityFree: Bool
    public let sameFamilyHistoricalReconstructionOnly: Bool
    public let namespaceBasisSourceBound: Bool
    public let exporterSuffixSourceBound: Bool
    public let finalDerivedSourceIdentityBound: Bool
    public let futureTargetMaterialized: Bool
    public let packageGraphChanged: Bool
    public let workerSourceChanged: Bool
    public let workerMainUnavailable: Bool
    public let workerInvoked: Bool
    public let historicalGateExecuted: Bool
    public let historicalEvidenceObserved: Bool
    public let durablePublicationObserved: Bool
    public let independentDetectionEstablished: Bool
    public let distinctImplementationFamiliesEstablished: Bool
    public let agentContractKitFourTierAuditPerformed: Bool
    public let mechanicsPassAuthorized: Bool
    public let terminalReceiptAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let nextImplementationPrerequisite: String
    public let authorityStatement: String

    public static let frozenV1: Self = {
        let plan =
            PrimeNativeNeuralGateFixtureReplayPlan.frozenV5
        let donorGate = plan.inputPins[0]
        let projectedMutationCatalog =
            PrimeNativeNeuralGateContractProjection
            .frozenV1.mutationCatalog
        let criticalLegIDs = [
            "NL1_canonical_material_reload",
            "NL2_finite_field_sz_pool_expansion",
            "NL3_foundation_tokenizer_corpus_regrade",
            "NL4_raw_executor_row_regrade",
            "NL5_causal_training_mechanics",
            "NL6_checkpoint_durability",
            "NL7_same_seed_initialization_training_result_replay",
            "NL8_frozen_exact_seed_consensus",
            "NL9_capability_and_malformed_abstention",
            "NL10_mutation_synthesis",
        ]
        let namespaceBasisDerivation =
            PrimeNativeNeuralGateSourceDerivationContract(
                derivationID:
                    "exact_whole_gate_namespace_clone_two_rewrite_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [1],
                lineGroups: [
                    .init(
                        ordinal: 1,
                        firstLine: 1,
                        lastLine: 9_242,
                        terminalLFPolicy:
                            .preserveTerminalLF,
                        expectedByteCount: 368_918,
                        expectedSHA256:
                            "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6"
                    ),
                ],
                joinedGroupByteCount: 368_918,
                joinedGroupSHA256:
                    "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
                rewrites: [
                    .init(
                        ordinal: 1,
                        rewriteID:
                            "internal_isolated_gate_namespace_declaration",
                        sourceUTF8:
                            "public enum PrimeNeuralNativeLanguageVerifyAbstainGate {",
                        sourceByteCount: 56,
                        sourceSHA256:
                            "4f9077034b6bff78ff926d17cecf12641ef3fc5859eb29fca577526f3e898b7b",
                        replacementUTF8:
                            "enum PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter {",
                        replacementByteCount: 70,
                        replacementSHA256:
                            "8133fb6157154d866541f1d379ad9d478caaf09d2eb79dc970dc2b2a7d05a0fb"
                    ),
                    .init(
                        ordinal: 2,
                        rewriteID:
                            "internal_isolated_gate_namespace_self_reference",
                        sourceUTF8:
                            "PrimeNeuralNativeLanguageVerifyAbstainGate\n"
                            + "                .exactMaterialsCacheKey",
                        sourceByteCount: 82,
                        sourceSHA256:
                            "51b33089416e7bac694073d8a5c1136e0847ab57142a636210cfc35948e32a70",
                        replacementUTF8:
                            "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter\n"
                            + "                .exactMaterialsCacheKey",
                        replacementByteCount: 103,
                        replacementSHA256:
                            "cd864c2d2a1e4508580029a0cc1ee34ac12f3057f387bd0b6a94b7eebf650e4e"
                    ),
                ],
                transformedBodyByteCount: 368_953,
                transformedBodySHA256:
                    "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31",
                expectedOutputByteCount: 368_953,
                expectedOutputSHA256:
                    "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31"
            )

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_evidence_export_adapter_design_v12",
            rightsHolder: "Ergentics, LLC",
            licenseExpression:
                "LicenseRef-Ergentics-Proprietary",
            companionRepository:
                "Ergentics/pmhnp-companion-ergentics",
            companionRevision: plan.companionRevision,
            companionTreeOID: plan.companionTreeOID,
            companionInputCatalogSHA256:
                plan.inputCatalogSHA256,
            preservedV11SourceContractID:
                PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract
                .frozenV1.contractID,
            preservedV11SourceContractSHA256:
                "64f0de29eed04145db6b598f2895bf9ee9d7804b03b35971f1ca77a72f76e9fb",
            preservedTopologyV11ID:
                PrimeNativeNeuralGateTrapDisjointTopologyContract
                .frozenV11.contractID,
            preservedTopologyV11SHA256:
                "06ce2af33e574c04ef4a46ca356402457ddd4e045bce6d100fed796c19c909eb",
            donorGateRepositoryRelativePath:
                donorGate.repositoryRelativePath,
            donorGateGitBlobOID: donorGate.gitBlobOID,
            donorGateLineCount: 9_242,
            donorGateByteCount: donorGate.byteCount,
            donorGateSHA256: donorGate.sha256,
            checkedInByteExactGateRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
            checkedInByteExactGateByteCount: 368_918,
            checkedInByteExactGateSHA256:
                "c3c93c637cb15f3a6944e78d8d44c0045f873f7df54f6121ee2d25e4f166b0f6",
            futureIsolatedTargetName:
                "PrimeNativeNeuralGateHistoricalEvidenceExportMechanics",
            futureDerivedSourceRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalEvidenceExportMechanics/PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter.swift",
            futureDerivedTopLevelTypeName:
                "PrimeNeuralNativeLanguageVerifyAbstainGateEvidenceExportAdapter",
            namespaceBasisDerivation:
                namespaceBasisDerivation,
            requiredEvidenceFields: [
                .init(
                    ordinal: 1,
                    fieldID: "ordered_invariant_records",
                    cardinalityAndEncodingPolicy:
                        "exact_59497_raw_utf8_records_preserving_gate_order_and_duplicates",
                    sourceAuthority:
                        "donor_private_intermediate"
                ),
                .init(
                    ordinal: 2,
                    fieldID:
                        "ordered_invariant_record_ascii_flags",
                    cardinalityAndEncodingPolicy:
                        "exact_59497_one_to_one_boolean_flags",
                    sourceAuthority:
                        "donor_private_intermediate"
                ),
                .init(
                    ordinal: 3,
                    fieldID: "baseline_invariant_bundle",
                    cardinalityAndEncodingPolicy:
                        "one_primeirm1_global_fifteen_primeirc1_chunks_direct_accelerated_fingerprint_exact_equality",
                    sourceAuthority:
                        "prime_recomputed_from_raw_records"
                ),
                .init(
                    ordinal: 4,
                    fieldID: "ordered_mutation_identities",
                    cardinalityAndEncodingPolicy:
                        "exact_46_catalog_order",
                    sourceAuthority:
                        "donor_same_family_mutation_dispatch"
                ),
                .init(
                    ordinal: 5,
                    fieldID:
                        "per_mutation_stream_identities",
                    cardinalityAndEncodingPolicy:
                        "exact_46_baseline_mutated_restored_stream_sha256_triplets",
                    sourceAuthority:
                        "prime_recomputed_from_raw_records"
                ),
                .init(
                    ordinal: 6,
                    fieldID: "per_mutation_fingerprints",
                    cardinalityAndEncodingPolicy:
                        "exact_46_baseline_mutated_restored_direct_accelerated_fingerprint_sets",
                    sourceAuthority:
                        "prime_recomputed_from_raw_records"
                ),
                .init(
                    ordinal: 7,
                    fieldID:
                        "per_mutation_observed_failed_leg_ids",
                    cardinalityAndEncodingPolicy:
                        "exact_46_complete_sets_ordered_by_primitive_leg_domain",
                    sourceAuthority:
                        "source_derived_same_family_full_leg_regrade"
                ),
                .init(
                    ordinal: 8,
                    fieldID:
                        "historical_critical_leg_values",
                    cardinalityAndEncodingPolicy:
                        "exact_10_ordered_gate_leg_values",
                    sourceAuthority:
                        "donor_same_family_gate_values"
                ),
                .init(
                    ordinal: 9,
                    fieldID:
                        "historical_statistics_and_verdict_values",
                    cardinalityAndEncodingPolicy:
                        "role_neutral_path_free_timing_free_same_family_values",
                    sourceAuthority:
                        "donor_same_family_gate_values"
                ),
            ],
            observedFailureDomain: .init(
                orderedPrimitiveLegIDs:
                    Array(criticalLegIDs.dropLast()),
                mutationSweepMetaLegID:
                    criticalLegIDs.last!
            ),
            mutationFailurePolicies:
                projectedMutationCatalog.map {
                    .init(
                        ordinal: $0.ordinal,
                        mutationID: $0.mutationID,
                        expectedFailedLegID:
                            $0.expectedFailedLeg
                    )
                },
            exactHistoricalInvariantRecordCount: 59_497,
            exactHistoricalInvariantChunkCount: 15,
            invariantRecordsPerFullChunk: 4_096,
            finalInvariantChunkRecordCount: 2_153,
            exactHistoricalMutationCount: 46,
            completeMaterialsBridgeRequired: true,
            completeMaterialsBridgeFieldCount: 12,
            materialsBridgeFields: [
                .init(
                    ordinal: 1,
                    fieldName: "reportData",
                    swiftTypeID: "array_data",
                    donorInitializerDefaultPolicy:
                        "no_default"
                ),
                .init(
                    ordinal: 2,
                    fieldName: "tokenizerManifestData",
                    swiftTypeID: "optional_data",
                    donorInitializerDefaultPolicy:
                        "no_default"
                ),
                .init(
                    ordinal: 3,
                    fieldName: "corpusManifestData",
                    swiftTypeID: "optional_data",
                    donorInitializerDefaultPolicy:
                        "no_default"
                ),
                .init(
                    ordinal: 4,
                    fieldName:
                        "packageResolvedArtifactBinding",
                    swiftTypeID:
                        "optional_observed_package_resolved_binding",
                    donorInitializerDefaultPolicy:
                        "default_nil"
                ),
                .init(
                    ordinal: 5,
                    fieldName:
                        "probeTokenManifestDataBySeed",
                    swiftTypeID:
                        "dictionary_int_data",
                    donorInitializerDefaultPolicy:
                        "default_empty_dictionary"
                ),
                .init(
                    ordinal: 6,
                    fieldName:
                        "evaluationShardDataBySeed",
                    swiftTypeID:
                        "dictionary_int_dictionary_string_data",
                    donorInitializerDefaultPolicy:
                        "default_empty_dictionary"
                ),
                .init(
                    ordinal: 7,
                    fieldName:
                        "executorArtifactDataByFileName",
                    swiftTypeID:
                        "dictionary_string_data",
                    donorInitializerDefaultPolicy:
                        "default_empty_dictionary"
                ),
                .init(
                    ordinal: 8,
                    fieldName:
                        "recommenderArtifactDataByFileName",
                    swiftTypeID:
                        "dictionary_string_data",
                    donorInitializerDefaultPolicy:
                        "default_empty_dictionary"
                ),
                .init(
                    ordinal: 9,
                    fieldName:
                        "checkpointArtifactBindingBySeed",
                    swiftTypeID:
                        "dictionary_int_observed_checkpoint_binding",
                    donorInitializerDefaultPolicy:
                        "default_empty_dictionary"
                ),
                .init(
                    ordinal: 10,
                    fieldName:
                        "metalLibraryArtifactBindingBySeed",
                    swiftTypeID:
                        "dictionary_int_observed_metal_library_binding",
                    donorInitializerDefaultPolicy:
                        "default_empty_dictionary"
                ),
                .init(
                    ordinal: 11,
                    fieldName:
                        "trainingStageArtifactDataBySeed",
                    swiftTypeID:
                        "dictionary_int_data",
                    donorInitializerDefaultPolicy:
                        "default_empty_dictionary"
                ),
                .init(
                    ordinal: 12,
                    fieldName:
                        "configurationArtifactDataBySeed",
                    swiftTypeID:
                        "dictionary_int_data",
                    donorInitializerDefaultPolicy:
                        "default_empty_dictionary"
                ),
            ],
            derivedMaterialsCacheKeyFieldName:
                "exactArtifactCacheKey",
            derivedMaterialsCacheKeyExcludedFromBridgeCount:
                true,
            bridgeMayDropOrDefaultFields: false,
            fullSourceDerivedVariantRequired: true,
            thinWrapperPermitted: false,
            compactReconstructionKernelPermitted: false,
            reflectionOrUnsafeMemoryAccessPermitted: false,
            donorAccessLevelMutationPermitted: false,
            originalByteExactGateMutationPermitted: false,
            exporterCarrierCodable: false,
            exporterCarrierRoleNeutral: true,
            exporterCarrierPathFree: true,
            exporterCarrierTimingFree: true,
            exporterCarrierAuthorityFree: true,
            sameFamilyHistoricalReconstructionOnly: true,
            namespaceBasisSourceBound: true,
            exporterSuffixSourceBound: false,
            finalDerivedSourceIdentityBound: false,
            futureTargetMaterialized: false,
            packageGraphChanged: false,
            workerSourceChanged: false,
            workerMainUnavailable: true,
            workerInvoked: false,
            historicalGateExecuted: false,
            historicalEvidenceObserved: false,
            durablePublicationObserved: false,
            independentDetectionEstablished: false,
            distinctImplementationFamiliesEstablished: false,
            agentContractKitFourTierAuditPerformed: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            nextImplementationPrerequisite:
                "materialize_the_exact_source_bound_historical_evidence_export_variant_in_the_isolated_historical_replay_boundary_without_executing_the_gate_or_worker_sealing_or_launching_a_worker_or_issuing_source_binding_v7",
            authorityStatement:
                "This V12 design contract preserves V11 byte-for-byte and closes the access-control ambiguity discovered before implementation. The pinned gate keeps its raw invariant records, ASCII flags, mutated fingerprints, and mutation helpers behind lexical private boundaries, and its public MutationResult never computes a complete observed failed-leg set. A thin wrapper, reflection, access relaxation, expected-leg substitution, or compact hand-reconstruction therefore cannot supply truthful historical evidence. V12 source-binds only the exact whole-file two-rewrite internal namespace basis for a later isolated same-file instrumented variant and freezes its role-neutral, path-free, timing-free, non-Codable evidence semantics, including a nine-leg per-mutation primitive regrade with NL10 retained only as the aggregate sweep leg. Each of the 46 allowed-failure sets is frozen to its projected expected-leg singleton but cannot stand in for the independently observed full regrade, and runtime widening is forbidden. The twelve Materials initializer inputs are identity-mapped by ordered name, type, optional/default declaration, and explicit-value policy; the derived exactArtifactCacheKey is excluded from that bridge count. The exporter suffix, complete Materials bridge implementation, final derived source identity, target, and worker call edge remain absent. No gate, fixture, worker, model, mutation, or evidence path executes; no historical observation, durable publication, independent detector, distinct-family/four-tier audit, mechanics PASS, terminal receipt, source/execution-binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    public func validate() throws {
        let plan =
            PrimeNativeNeuralGateFixtureReplayPlan.frozenV5
        let donorGate = plan.inputPins[0]
        let v11 =
            PrimeNativeNeuralGateHistoricalFixtureWorkerSourceContract
            .frozenV1
        let topologyV11 =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV11
        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        try v11.validate()
        try topologyV11.validate()
        try projection.validate()
        try namespaceBasisDerivation.validate(
            donorByteCount: donorGate.byteCount,
            donorSHA256: donorGate.sha256
        )
        let criticalLegIDs = [
            "NL1_canonical_material_reload",
            "NL2_finite_field_sz_pool_expansion",
            "NL3_foundation_tokenizer_corpus_regrade",
            "NL4_raw_executor_row_regrade",
            "NL5_causal_training_mechanics",
            "NL6_checkpoint_durability",
            "NL7_same_seed_initialization_training_result_replay",
            "NL8_frozen_exact_seed_consensus",
            "NL9_capability_and_malformed_abstention",
            "NL10_mutation_synthesis",
        ]
        let requirementsValid =
            requiredEvidenceFields.enumerated().allSatisfy {
                index, requirement in
                requirement.ordinal == index + 1
                    && requirement.validate()
            }
        let mutationFailurePoliciesValid =
            mutationFailurePolicies.count
                == projection.mutationCatalog.count
            && zip(
                mutationFailurePolicies,
                projection.mutationCatalog
            ).allSatisfy {
                $0.0.validate(against: $0.1)
            }
        let materialsBridgeFieldsValid =
            materialsBridgeFields.enumerated().allSatisfy {
                index, field in
                field.ordinal == index + 1
                    && field.validate()
            }
        let v11SHA256 = try v11.contentSHA256()
        let topologyV11SHA256 =
            try topologyV11.contentSHA256()

        guard self == .frozenV1,
              schemaVersion == 1,
              companionRevision == plan.companionRevision,
              companionTreeOID == plan.companionTreeOID,
              companionInputCatalogSHA256
                == plan.inputCatalogSHA256,
              preservedV11SourceContractID
                == v11.contractID,
              preservedV11SourceContractSHA256
                == v11SHA256,
              preservedTopologyV11ID
                == topologyV11.contractID,
              preservedTopologyV11SHA256
                == topologyV11SHA256,
              donorGateRepositoryRelativePath
                == donorGate.repositoryRelativePath,
              donorGateGitBlobOID == donorGate.gitBlobOID,
              donorGateLineCount == 9_242,
              donorGateByteCount == donorGate.byteCount,
              donorGateSHA256 == donorGate.sha256,
              checkedInByteExactGateByteCount
                == donorGateByteCount,
              checkedInByteExactGateSHA256
                == donorGateSHA256,
              namespaceBasisDerivation.requiredInputOrdinals
                == [1],
              namespaceBasisDerivation.lineGroups.count == 1,
              namespaceBasisDerivation.rewrites.count == 2,
              namespaceBasisDerivation.expectedOutputByteCount
                == 368_953,
              namespaceBasisDerivation.expectedOutputSHA256
                == "c323aab1b3f01c78552ee30e5d50c2c7974a1d846121d887dc5f005f6a89cd31",
              requirementsValid,
              requiredEvidenceFields.count == 9,
              Set(requiredEvidenceFields.map(\.fieldID)).count
                == requiredEvidenceFields.count,
              observedFailureDomain.validate(
                  against: criticalLegIDs
              ),
              mutationFailurePoliciesValid,
              mutationFailurePolicies.count == 46,
              mutationFailurePolicies.allSatisfy({
                  $0.orderedAllowedFailedLegIDs
                      == [$0.expectedFailedLegID]
              }),
              exactHistoricalInvariantRecordCount == 59_497,
              exactHistoricalInvariantChunkCount == 15,
              invariantRecordsPerFullChunk == 4_096,
              (exactHistoricalInvariantChunkCount - 1)
                * invariantRecordsPerFullChunk
                + finalInvariantChunkRecordCount
                == exactHistoricalInvariantRecordCount,
              exactHistoricalMutationCount == 46,
              completeMaterialsBridgeRequired,
              completeMaterialsBridgeFieldCount == 12,
              materialsBridgeFieldsValid,
              materialsBridgeFields.count
                == completeMaterialsBridgeFieldCount,
              derivedMaterialsCacheKeyFieldName
                == "exactArtifactCacheKey",
              derivedMaterialsCacheKeyExcludedFromBridgeCount,
              !bridgeMayDropOrDefaultFields,
              fullSourceDerivedVariantRequired,
              !thinWrapperPermitted,
              !compactReconstructionKernelPermitted,
              !reflectionOrUnsafeMemoryAccessPermitted,
              !donorAccessLevelMutationPermitted,
              !originalByteExactGateMutationPermitted,
              !exporterCarrierCodable,
              exporterCarrierRoleNeutral,
              exporterCarrierPathFree,
              exporterCarrierTimingFree,
              exporterCarrierAuthorityFree,
              sameFamilyHistoricalReconstructionOnly,
              namespaceBasisSourceBound,
              !exporterSuffixSourceBound,
              !finalDerivedSourceIdentityBound,
              !futureTargetMaterialized,
              !packageGraphChanged,
              !workerSourceChanged,
              workerMainUnavailable,
              !workerInvoked,
              !historicalGateExecuted,
              !historicalEvidenceObserved,
              !durablePublicationObserved,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !agentContractKitFourTierAuditPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              !authorityStatement.isEmpty
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_evidence_export_adapter_design_contract"
                )
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case companionRepository = "companion_repository"
        case companionRevision = "companion_revision"
        case companionTreeOID = "companion_tree_oid"
        case companionInputCatalogSHA256 =
            "companion_input_catalog_sha256"
        case preservedV11SourceContractID =
            "preserved_v11_source_contract_id"
        case preservedV11SourceContractSHA256 =
            "preserved_v11_source_contract_sha256"
        case preservedTopologyV11ID =
            "preserved_topology_v11_id"
        case preservedTopologyV11SHA256 =
            "preserved_topology_v11_sha256"
        case donorGateRepositoryRelativePath =
            "donor_gate_repository_relative_path"
        case donorGateGitBlobOID = "donor_gate_git_blob_oid"
        case donorGateLineCount = "donor_gate_line_count"
        case donorGateByteCount = "donor_gate_byte_count"
        case donorGateSHA256 = "donor_gate_sha256"
        case checkedInByteExactGateRelativePath =
            "checked_in_byte_exact_gate_relative_path"
        case checkedInByteExactGateByteCount =
            "checked_in_byte_exact_gate_byte_count"
        case checkedInByteExactGateSHA256 =
            "checked_in_byte_exact_gate_sha256"
        case futureIsolatedTargetName =
            "future_isolated_target_name"
        case futureDerivedSourceRelativePath =
            "future_derived_source_relative_path"
        case futureDerivedTopLevelTypeName =
            "future_derived_top_level_type_name"
        case namespaceBasisDerivation =
            "namespace_basis_derivation"
        case requiredEvidenceFields =
            "required_evidence_fields"
        case observedFailureDomain =
            "observed_failure_domain"
        case mutationFailurePolicies =
            "mutation_failure_policies"
        case exactHistoricalInvariantRecordCount =
            "exact_historical_invariant_record_count"
        case exactHistoricalInvariantChunkCount =
            "exact_historical_invariant_chunk_count"
        case invariantRecordsPerFullChunk =
            "invariant_records_per_full_chunk"
        case finalInvariantChunkRecordCount =
            "final_invariant_chunk_record_count"
        case exactHistoricalMutationCount =
            "exact_historical_mutation_count"
        case completeMaterialsBridgeRequired =
            "complete_materials_bridge_required"
        case completeMaterialsBridgeFieldCount =
            "complete_materials_bridge_field_count"
        case materialsBridgeFields =
            "materials_bridge_fields"
        case derivedMaterialsCacheKeyFieldName =
            "derived_materials_cache_key_field_name"
        case derivedMaterialsCacheKeyExcludedFromBridgeCount =
            "derived_materials_cache_key_excluded_from_bridge_count"
        case bridgeMayDropOrDefaultFields =
            "bridge_may_drop_or_default_fields"
        case fullSourceDerivedVariantRequired =
            "full_source_derived_variant_required"
        case thinWrapperPermitted = "thin_wrapper_permitted"
        case compactReconstructionKernelPermitted =
            "compact_reconstruction_kernel_permitted"
        case reflectionOrUnsafeMemoryAccessPermitted =
            "reflection_or_unsafe_memory_access_permitted"
        case donorAccessLevelMutationPermitted =
            "donor_access_level_mutation_permitted"
        case originalByteExactGateMutationPermitted =
            "original_byte_exact_gate_mutation_permitted"
        case exporterCarrierCodable =
            "exporter_carrier_codable"
        case exporterCarrierRoleNeutral =
            "exporter_carrier_role_neutral"
        case exporterCarrierPathFree =
            "exporter_carrier_path_free"
        case exporterCarrierTimingFree =
            "exporter_carrier_timing_free"
        case exporterCarrierAuthorityFree =
            "exporter_carrier_authority_free"
        case sameFamilyHistoricalReconstructionOnly =
            "same_family_historical_reconstruction_only"
        case namespaceBasisSourceBound =
            "namespace_basis_source_bound"
        case exporterSuffixSourceBound =
            "exporter_suffix_source_bound"
        case finalDerivedSourceIdentityBound =
            "final_derived_source_identity_bound"
        case futureTargetMaterialized =
            "future_target_materialized"
        case packageGraphChanged = "package_graph_changed"
        case workerSourceChanged = "worker_source_changed"
        case workerMainUnavailable =
            "worker_main_unavailable"
        case workerInvoked = "worker_invoked"
        case historicalGateExecuted =
            "historical_gate_executed"
        case historicalEvidenceObserved =
            "historical_evidence_observed"
        case durablePublicationObserved =
            "durable_publication_observed"
        case independentDetectionEstablished =
            "independent_detection_established"
        case distinctImplementationFamiliesEstablished =
            "distinct_implementation_families_established"
        case agentContractKitFourTierAuditPerformed =
            "agent_contract_kit_four_tier_audit_performed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case terminalReceiptAuthorized =
            "terminal_receipt_authorized"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case nextImplementationPrerequisite =
            "next_implementation_prerequisite"
        case authorityStatement = "authority_statement"
    }
}
