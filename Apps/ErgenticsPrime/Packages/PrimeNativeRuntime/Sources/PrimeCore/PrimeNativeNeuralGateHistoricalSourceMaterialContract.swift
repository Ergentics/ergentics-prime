import Foundation

public extension PrimeNativeNeuralGateAdaptationProofContract {
    /// Additive routing correction for the source-material phase.
    ///
    /// V2 remains immutable history. V3 changes only the gate/carrier
    /// destinations and their proof descriptions so neither source is ever
    /// routed into the pure replay substrate.
    static let frozenV3: Self = {
        let historicalRoot =
            "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/"
        let entries = frozenV2.entries.map { entry in
            switch entry.role {
            case .nativeLanguageGate:
                PrimeNativeNeuralGateAdaptationProofEntry(
                    ordinal: entry.ordinal,
                    role: entry.role,
                    donorSHA256: entry.donorSHA256,
                    transplantPolicy:
                        entry.transplantPolicy,
                    primeDestinationRelativePath:
                        historicalRoot
                        + "PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
                    proofMechanism:
                        "byte_exact_donor_source_routed_only_to_future_historical_replay_with_separate_source_derived_gate_carrier_and_mutation_material_v3",
                    derivation: entry.derivation
                )
            case .verdictCarrier:
                PrimeNativeNeuralGateAdaptationProofEntry(
                    ordinal: entry.ordinal,
                    role: entry.role,
                    donorSHA256: entry.donorSHA256,
                    transplantPolicy:
                        entry.transplantPolicy,
                    primeDestinationRelativePath:
                        historicalRoot
                        + "PrimeNeuralVerifyAbstainGateCarrier.swift",
                    proofMechanism:
                        "exact_utf8_declaration_slice_routed_only_to_future_historical_replay_v3",
                    derivation: entry.derivation
                )
            default:
                entry
            }
        }
        return Self(
            contractID:
                "prime_source_pinned_neural_gate_adaptation_proof_v3",
            entries: entries,
            proofManifestRelativePath:
                "neural-gate-replay/source/adaptation-proof.v3.json",
            lexicalSourceDiffManifestRequired:
                frozenV2.lexicalSourceDiffManifestRequired,
            compiledTargetSourceClosureRequired:
                frozenV2.compiledTargetSourceClosureRequired,
            probeAndVerifierRecomputeRequired:
                frozenV2.probeAndVerifierRecomputeRequired,
            candidateDeclaredExpectedValuesPermitted:
                frozenV2
                .candidateDeclaredExpectedValuesPermitted,
            behavioralReplayMayReplaceSourceProof:
                frozenV2.behavioralReplayMayReplaceSourceProof,
            independentScientificOracleClaimed:
                frozenV2.independentScientificOracleClaimed,
            historicalFixtureInheritedTryBangCount:
                frozenV2
                .historicalFixtureInheritedTryBangCount,
            historicalFixtureContainsAdditionalTrapSites:
                frozenV2
                .historicalFixtureContainsAdditionalTrapSites,
            historicalFixtureWhollyFailClosed:
                frozenV2.historicalFixtureWhollyFailClosed,
            historicalFixtureFreshProcessContainmentRequired:
                frozenV2
                .historicalFixtureFreshProcessContainmentRequired,
            historicalFixtureMaximumWallSeconds:
                frozenV2.historicalFixtureMaximumWallSeconds,
            historicalFixtureMaximumStandardOutputBytes:
                frozenV2
                .historicalFixtureMaximumStandardOutputBytes,
            historicalFixtureMaximumStandardErrorBytes:
                frozenV2
                .historicalFixtureMaximumStandardErrorBytes,
            historicalFixtureChildEnvironmentPolicy:
                frozenV2
                .historicalFixtureChildEnvironmentPolicy,
            historicalFixtureChildStandardInputPolicy:
                frozenV2
                .historicalFixtureChildStandardInputPolicy,
            historicalFixtureAbnormalTerminationPolicy:
                frozenV2
                .historicalFixtureAbnormalTerminationPolicy
        )
    }()
}

/// Source-pinned, non-executable material needed before the historical gate
/// can be placed in an isolated replay target.
///
/// This contract binds exact donor bytes and deterministic LF line-group
/// derivations. It does not parse Swift case semantics, compile the donor,
/// reconstruct historical invariant records, or establish a detector.
public struct PrimeNativeNeuralGateHistoricalSourceMaterialContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let preservedAdaptationProofV2ID: String
    public let requiredAdaptationProofV3ID: String
    public let companionRevision: String
    public let companionTreeOID: String
    public let inputCatalogSHA256: String
    public let historicalDestinationRoot: String
    public let gateDestinationRelativePath: String
    public let carrierDestinationRelativePath: String
    public let carrierMaterialRelativePath: String
    public let gateCarrierUseMaterialRelativePath: String
    public let mutationMaterialRelativePath: String
    public let carrierDerivation:
        PrimeNativeNeuralGateSourceDerivationContract
    public let gateCarrierUseDerivation:
        PrimeNativeNeuralGateSourceDerivationContract
    public let mutationMaterialDerivation:
        PrimeNativeNeuralGateSourceDerivationContract
    public let historicalMutationCatalogID: String
    public let projectionCatalogEncodingID: String
    public let projectionCatalogSHA256: String
    public let exactMutationCount: Int
    public let rawPredictionMutationCount: Int
    public let sourceBytesMayBeSuppliedOnlyByCaller: Bool
    public let runtimeManifestMaySupplyExpectedValues: Bool
    public let perCaseSourceParsingPerformed: Bool
    public let executableTransformBindingEstablished: Bool
    public let exactFailureSetsDerived: Bool
    public let historicalTargetsMaterialized: Bool
    public let sourceBindingV7Issued: Bool
    public let executionObserved: Bool
    public let independentDetectionEstablished: Bool
    public let distinctImplementationFamiliesEstablished: Bool
    public let mechanicsPassAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let authorityStatement: String

    public static let frozenV1: Self = {
        let emptySHA256 =
            "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        func group(
            _ ordinal: Int,
            _ firstLine: Int,
            _ lastLine: Int,
            _ byteCount: UInt64,
            _ sha256: String
        ) -> PrimeNativeNeuralGateSourceLineGroup {
            PrimeNativeNeuralGateSourceLineGroup(
                ordinal: ordinal,
                firstLine: firstLine,
                lastLine: lastLine,
                terminalLFPolicy: .preserveTerminalLF,
                expectedByteCount: byteCount,
                expectedSHA256: sha256
            )
        }
        let carrier =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV3.entries[8].derivation
        let gateCarrierUse =
            PrimeNativeNeuralGateSourceDerivationContract(
                derivationID:
                    "exact_lf_native_gate_carrier_construction_use_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [1],
                lineGroups: [
                    group(
                        1,
                        1_916,
                        1_930,
                        510,
                        "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb"
                    ),
                ],
                joinedGroupByteCount: 510,
                joinedGroupSHA256:
                    "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb",
                prefixSHA256: emptySHA256,
                suffixSHA256: emptySHA256,
                transformedBodyByteCount: 510,
                transformedBodySHA256:
                    "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb",
                expectedOutputByteCount: 510,
                expectedOutputSHA256:
                    "61224beb553d22a5f0edd5e2244a93c7c3fd45a93eca77e2de6e02e56d1c06eb"
            )
        let mutationMaterial =
            PrimeNativeNeuralGateSourceDerivationContract(
                derivationID:
                    "exact_lf_historical_forty_six_mutation_raw_material_six_group_v1",
                kind: .frozenLineGroupsAndRewrites,
                requiredInputOrdinals: [1],
                lineGroups: [
                    group(
                        1,
                        257,
                        405,
                        6_398,
                        "81d99227f79d4734a89ef369ac761d2bd354cd2a324db2db327dfa85d1d30386"
                    ),
                    group(
                        2,
                        407,
                        425,
                        662,
                        "d992aca9b9ea00690c442a6165a8dcfd39fa093b00d460513f4ae393f7c84fe1"
                    ),
                    group(
                        3,
                        426,
                        441,
                        562,
                        "f075bc32a9f74396190d7666e4103cf9b68dafa39d60f95e3a72aa2b61e4c2c9"
                    ),
                    group(
                        4,
                        7_147,
                        7_350,
                        8_402,
                        "f1de9075e1e8bbce8707396f7b9e14f884c3060ffad5e54022f546493d58b9a9"
                    ),
                    group(
                        5,
                        7_352,
                        7_453,
                        4_319,
                        "74d972ef325c0aae169394d7ae97819502c65645ea79ceb667ed462fe04f2730"
                    ),
                    group(
                        6,
                        7_486,
                        8_148,
                        24_747,
                        "046f8935d866868e3bc60172971bdb62b2b2e607648461ebe210f328f54a7969"
                    ),
                ],
                betweenGroupUTF8Hex: [
                    "", "", "", "", "",
                ],
                joinedGroupByteCount: 45_090,
                joinedGroupSHA256:
                    "307c79edcaa72ee35aa3e0cdad67208c248f27ade898e503834309d3dcd2a8bb",
                prefixSHA256: emptySHA256,
                suffixSHA256: emptySHA256,
                transformedBodyByteCount: 45_090,
                transformedBodySHA256:
                    "307c79edcaa72ee35aa3e0cdad67208c248f27ade898e503834309d3dcd2a8bb",
                expectedOutputByteCount: 45_090,
                expectedOutputSHA256:
                    "307c79edcaa72ee35aa3e0cdad67208c248f27ade898e503834309d3dcd2a8bb"
            )
        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_pinned_historical_gate_carrier_and_mutation_material_v1",
            preservedAdaptationProofV2ID:
                "prime_source_pinned_neural_gate_adaptation_proof_v2",
            requiredAdaptationProofV3ID:
                "prime_source_pinned_neural_gate_adaptation_proof_v3",
            companionRevision:
                "163fc100710ece48119bc25954452d10f6a84f7f",
            companionTreeOID:
                "9009daa4f8a07fbd5897e00b9571cef44ec292db",
            inputCatalogSHA256:
                "e9ac9a697dd24cbe6583c713e96840c810cda1771497a6a69ace1e190963bca4",
            historicalDestinationRoot:
                "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/",
            gateDestinationRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/PrimeNeuralNativeLanguageVerifyAbstainGate.swift",
            carrierDestinationRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalReplayMechanics/PrimeNeuralVerifyAbstainGateCarrier.swift",
            carrierMaterialRelativePath:
                "neural-gate-replay/source/historical-verdict-carrier.v1.swift-source.bin",
            gateCarrierUseMaterialRelativePath:
                "neural-gate-replay/source/historical-gate-carrier-use.v1.swift-source.bin",
            mutationMaterialRelativePath:
                "neural-gate-replay/source/historical-mutation-material.v1.swift-source.bin",
            carrierDerivation: carrier,
            gateCarrierUseDerivation: gateCarrierUse,
            mutationMaterialDerivation: mutationMaterial,
            historicalMutationCatalogID:
                "prime_stage_b_historical_forensic_mutation_catalog_46_v1",
            projectionCatalogEncodingID:
                "prime_stage_a_projection_mutation_contract_ordinal_id_expected_leg_raw_prediction_v1",
            projectionCatalogSHA256:
                "8a1f70ae9f20f60e63cc53df6841d8a160bcbee61621c6f80a4f0272a186100f",
            exactMutationCount: 46,
            rawPredictionMutationCount: 12,
            sourceBytesMayBeSuppliedOnlyByCaller: true,
            runtimeManifestMaySupplyExpectedValues: false,
            perCaseSourceParsingPerformed: false,
            executableTransformBindingEstablished: false,
            exactFailureSetsDerived: false,
            historicalTargetsMaterialized: false,
            sourceBindingV7Issued: false,
            executionObserved: false,
            independentDetectionEstablished: false,
            distinctImplementationFamiliesEstablished: false,
            mechanicsPassAuthorized: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            authorityStatement:
                "This contract preserves adaptation V2 and corrects only future gate/carrier routing through additive V3. It binds exact caller-supplied donor bytes to the frozen gate and carrier pins, derives the bounded carrier declaration, native gate/carrier construction use, and direct six-group historical mutation source material, and names the richer projection-catalog encoding separately from transport and observation encodings. The mutation material contains the exact pinned declarations, result and sweep carriers, sweep implementation, same-family named-leg dispatch, and forty-six report transforms. It is inert noncompiled source material, not a per-case parser, executable transform binding, independent detector, exact failure-set derivation, restored-state proof, invariant-record reconstruction, SZ/statistics/triad verdict, worker/process/model execution, durable observation, receipt, source/execution-binding V7, scientific authority, or product authority."
        )
    }()

    public func validate() throws {
        let plan = PrimeNativeNeuralGateFixtureReplayPlan.frozenV3
        let adaptationV2 =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV2
        let adaptationV3 =
            PrimeNativeNeuralGateAdaptationProofContract
            .frozenV3
        try adaptationV2.validate(against: plan.inputPins)
        try adaptationV3.validate(against: plan.inputPins)

        let gateInput = plan.inputPins[0]
        let carrierInput = plan.inputPins[8]
        try carrierDerivation.validate(
            donorByteCount: carrierInput.byteCount,
            donorSHA256: carrierInput.sha256
        )
        try gateCarrierUseDerivation.validate(
            donorByteCount: gateInput.byteCount,
            donorSHA256: gateInput.sha256
        )
        try mutationMaterialDerivation.validate(
            donorByteCount: gateInput.byteCount,
            donorSHA256: gateInput.sha256
        )

        let projection =
            PrimeNativeNeuralGateContractProjection
            .frozenV1
        let rawPredictionCount =
            projection.mutationCatalog.filter {
                $0.mutatesRawPredictions
            }.count
        let v3Gate = adaptationV3.entries[0]
        let v3Carrier = adaptationV3.entries[8]
        guard self == .frozenV1,
              schemaVersion == 1,
              preservedAdaptationProofV2ID
                == adaptationV2.contractID,
              requiredAdaptationProofV3ID
                == adaptationV3.contractID,
              companionRevision
                == plan.companionRevision,
              companionTreeOID
                == plan.companionTreeOID,
              inputCatalogSHA256
                == plan.inputCatalogSHA256,
              gateDestinationRelativePath
                == v3Gate.primeDestinationRelativePath,
              carrierDestinationRelativePath
                == v3Carrier.primeDestinationRelativePath,
              gateDestinationRelativePath
                .hasPrefix(historicalDestinationRoot),
              carrierDestinationRelativePath
                .hasPrefix(historicalDestinationRoot),
              projectionCatalogSHA256
                == PrimeSHA256.hexDigest(
                    of: try PrimeCanonicalJSON.encode(
                        projection.mutationCatalog
                    )
                ),
              exactMutationCount
                == projection.mutationCatalog.count,
              rawPredictionMutationCount
                == rawPredictionCount,
              sourceBytesMayBeSuppliedOnlyByCaller,
              !runtimeManifestMaySupplyExpectedValues,
              !perCaseSourceParsingPerformed,
              !executableTransformBindingEstablished,
              !exactFailureSetsDerived,
              !historicalTargetsMaterialized,
              !sourceBindingV7Issued,
              !executionObserved,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !mechanicsPassAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              authorityStatement.contains(
                  "same-family named-leg dispatch"
              ),
              authorityStatement.contains(
                  "not a per-case parser"
              )
        else {
            throw PrimeNativeNeuralGateFixtureReplayPlanError
                .invalidPlan(
                    "historical_source_material"
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
        case preservedAdaptationProofV2ID =
            "preserved_adaptation_proof_v2_id"
        case requiredAdaptationProofV3ID =
            "required_adaptation_proof_v3_id"
        case companionRevision = "companion_revision"
        case companionTreeOID = "companion_tree_oid"
        case inputCatalogSHA256 = "input_catalog_sha256"
        case historicalDestinationRoot =
            "historical_destination_root"
        case gateDestinationRelativePath =
            "gate_destination_relative_path"
        case carrierDestinationRelativePath =
            "carrier_destination_relative_path"
        case carrierMaterialRelativePath =
            "carrier_material_relative_path"
        case gateCarrierUseMaterialRelativePath =
            "gate_carrier_use_material_relative_path"
        case mutationMaterialRelativePath =
            "mutation_material_relative_path"
        case carrierDerivation = "carrier_derivation"
        case gateCarrierUseDerivation =
            "gate_carrier_use_derivation"
        case mutationMaterialDerivation =
            "mutation_material_derivation"
        case historicalMutationCatalogID =
            "historical_mutation_catalog_id"
        case projectionCatalogEncodingID =
            "projection_catalog_encoding_id"
        case projectionCatalogSHA256 =
            "projection_catalog_sha256"
        case exactMutationCount = "exact_mutation_count"
        case rawPredictionMutationCount =
            "raw_prediction_mutation_count"
        case sourceBytesMayBeSuppliedOnlyByCaller =
            "source_bytes_may_be_supplied_only_by_caller"
        case runtimeManifestMaySupplyExpectedValues =
            "runtime_manifest_may_supply_expected_values"
        case perCaseSourceParsingPerformed =
            "per_case_source_parsing_performed"
        case executableTransformBindingEstablished =
            "executable_transform_binding_established"
        case exactFailureSetsDerived =
            "exact_failure_sets_derived"
        case historicalTargetsMaterialized =
            "historical_targets_materialized"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case executionObserved = "execution_observed"
        case independentDetectionEstablished =
            "independent_detection_established"
        case distinctImplementationFamiliesEstablished =
            "distinct_implementation_families_established"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case authorityStatement = "authority_statement"
    }
}
