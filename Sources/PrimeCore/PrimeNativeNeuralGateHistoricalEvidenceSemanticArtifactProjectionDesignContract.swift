// SPDX-FileCopyrightText: 2026 Ergentics, LLC
// SPDX-License-Identifier: LicenseRef-Ergentics-Proprietary

public enum
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
}

public enum
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDisposition:
    String,
    Codable,
    Equatable,
    Sendable
{
    case exact
    case validationOnly = "validation_only"
    case blocked
}

public struct
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactFieldProjection:
    Codable,
    Equatable,
    Sendable
{
    public let ordinal: Int
    public let carrierSwiftPropertyName: String
    public let destinationSwiftTypeNames: [String]
    public let destinationWorkerArtifactLeafNames: [String]
    public let projectionDisposition:
        PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDisposition
    public let blockingReason: String?

    fileprivate init(
        ordinal: Int,
        carrierSwiftPropertyName: String,
        destinationSwiftTypeNames: [String],
        destinationWorkerArtifactLeafNames: [String],
        projectionDisposition:
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDisposition,
        blockingReason: String? = nil
    ) {
        self.ordinal = ordinal
        self.carrierSwiftPropertyName =
            carrierSwiftPropertyName
        self.destinationSwiftTypeNames =
            destinationSwiftTypeNames
        self.destinationWorkerArtifactLeafNames =
            destinationWorkerArtifactLeafNames
        self.projectionDisposition =
            projectionDisposition
        self.blockingReason = blockingReason
    }

    fileprivate func validate() -> Bool {
        ordinal > 0
            && Self.isIdentifier(carrierSwiftPropertyName)
            && !destinationSwiftTypeNames.isEmpty
            && Set(destinationSwiftTypeNames).count
                == destinationSwiftTypeNames.count
            && destinationSwiftTypeNames.allSatisfy(
                Self.isSwiftTypeName
            )
            && Set(destinationWorkerArtifactLeafNames).count
                == destinationWorkerArtifactLeafNames.count
            && destinationWorkerArtifactLeafNames.allSatisfy(
                Self.isArtifactLeafName
            )
            && (
                projectionDisposition == .blocked
                    ? blockingReason.map(Self.isIdentifier) == true
                    : blockingReason == nil
            )
    }

    private static func isIdentifier(
        _ value: String
    ) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 256
            && value.utf8.allSatisfy {
                ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || ($0 >= 48 && $0 <= 57)
                    || $0 == 95
            }
    }

    private static func isSwiftTypeName(
        _ value: String
    ) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 256
            && value.utf8.allSatisfy {
                ($0 >= 65 && $0 <= 90)
                    || ($0 >= 97 && $0 <= 122)
                    || ($0 >= 48 && $0 <= 57)
                    || $0 == 46
            }
    }

    private static func isArtifactLeafName(
        _ value: String
    ) -> Bool {
        !value.isEmpty
            && value.utf8.count <= 256
            && !value.hasPrefix("/")
            && !value.contains("\\")
            && !value.contains("\0")
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case carrierSwiftPropertyName =
            "carrier_swift_property_name"
        case destinationSwiftTypeNames =
            "destination_swift_type_names"
        case destinationWorkerArtifactLeafNames =
            "destination_worker_artifact_leaf_names"
        case projectionDisposition =
            "projection_disposition"
        case blockingReason = "blocking_reason"
    }
}

/// Frozen V15 design and source boundary for projecting the V13 historical
/// evidence carrier into the V8 semantic records required by the V2 worker.
///
/// This contract deliberately does not materialize a projector. Forward
/// audit found three unresolved implementation constraints: the V4 namespace
/// reserves only three of the worker's twenty-two semantic artifacts per
/// role, and the carrier retains three seed-specific statistics families
/// while the frozen statistics schema accepts one of each. The semantic-record
/// target also reaches the corrected mutation surface, which is forbidden in
/// the historical worker closure. Choosing a seed, inventing a reduction, or
/// importing that mixed target would corrupt evidence or isolation. V15
/// therefore source-binds the exact mappings and blockers while preserving
/// the V14 package graph and unavailable worker byte-for-byte.
public struct
    PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let rightsHolder: String
    public let licenseExpression: String

    public let preservedCallEdgeSourceContractID: String
    public let preservedCallEdgeSourceContractSHA256: String
    public let preservedTopologyV14ID: String
    public let preservedTopologyV14SHA256: String
    public let preservedExporterSourceContractID: String
    public let preservedExporterSourceContractSHA256: String
    public let preservedSemanticRecordContractID: String
    public let preservedSemanticRecordContractSHA256: String
    public let preservedSemanticNamespaceContractID: String
    public let preservedSemanticNamespaceContractSHA256: String
    public let preservedWorkerContractID: String

    public let exporterCarrierSwiftTypeName: String
    public let carrierFieldProjections:
        [PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactFieldProjection]
    public let exactCarrierFieldCount: Int
    public let carrierRemainsNonCodable: Bool
    public let carrierRemainsRoleNeutral: Bool
    public let carrierRemainsPathFree: Bool
    public let carrierRemainsTimingFree: Bool
    public let carrierRemainsAuthorityFree: Bool
    public let requiredExternalProjectionContextNames: [String]
    public let externalContextDestinationWorkerArtifactLeafNames:
        [String]
    public let externalProjectionContextMayBeInferredFromCarrier: Bool
    public let invocationRoleRequired: Bool
    public let invocationRoleProjectionSource: String
    public let rolePrefixDerivedFromInvocationRole: Bool

    public let workerSemanticFixedLeafPaths: [String]
    public let workerInvariantChunkLeafPathPattern: String
    public let exactWorkerInvariantChunkCount: Int
    public let exactWorkerSemanticArtifactCountPerRole: Int
    public let frozenNamespaceHistoricalKeyNames: [String]
    public let frozenNamespaceHistoricalKeyCountPerRole: Int
    public let frozenNamespaceHistoricalEncoding: String
    public let frozenNamespaceHistoricalDecoderMode: String
    public let frozenNamespaceHistoricalSpecsProjectionReady: Bool
    public let missingNamespaceFixedLeafPaths: [String]
    public let missingNamespaceDynamicLeafPathPatterns: [String]
    public let semanticNamespaceComplete: Bool
    public let frozenNamespaceFinalClosed: Bool
    public let descriptorStreamingDecoderImplemented: Bool

    public let admittedHistoricalSeeds: [Int]
    public let carrierSeedArrayOrderAuthoritative: Bool
    public let keyedSeedCanonicalizationDefined: Bool
    public let carrierHeldoutStatisticsCount: Int
    public let carrierFixedPromptReplayValueCount: Int
    public let carrierCapabilityValueCount: Int
    public let semanticWeightedStatisticsValueCount: Int
    public let semanticFixedPromptMarginValueCount: Int
    public let semanticCapabilityValueCount: Int
    public let losslessThreeSeedReductionPolicyID: String
    public let losslessThreeSeedReductionDefined: Bool
    public let additiveKeyedThreeSeedEnvelopeDefined: Bool
    public let statisticsProjectionLossless: Bool
    public let materialIdentitySourceBytesResolvedProjectionState:
        String
    public let materialIdentityAdaptationProofProjectionState:
        String
    public let criticalLegEvidenceProjectionState: String
    public let descriptorVerificationProjectionState: String
    public let durablePublicationProjectionState: String
    public let exactProjectionJoinRuleIDs: [String]
    public let unresolvedSemanticContextFieldNames: [String]
    public let semanticContextFieldPolicyComplete: Bool
    public let carrierDerivedObservationPromotionPermitted: Bool
    public let semanticContextFieldPolicyIDs: [String]

    public let semanticRecordTargetName: String
    public let semanticRecordTargetDirectLocalDependencyNames: [String]
    public let correctedMutationSurfaceTargetName: String
    public let historicalWorkerMayReachCorrectedMutationSurface: Bool
    public let historicalOnlySemanticProjectionBoundaryAvailable: Bool
    public let dependencyIsolationComplete: Bool

    public let reservedProjectionTargetName: String
    public let reservedProjectionSourceRelativePath: String
    public let projectionPlanSourceBound: Bool
    public let projectionCodecSourceBound: Bool
    public let projectionTargetMaterialized: Bool
    public let projectionSourceMaterialized: Bool
    public let packageGraphChanged: Bool
    public let workerSourceChanged: Bool
    public let workerDependenciesChanged: Bool
    public let workerMainUnavailable: Bool
    public let unavailableExitStatus: Int32

    public let workerRequestHandlingEnabled: Bool
    public let workerSealed: Bool
    public let workerLaunched: Bool
    public let workerExecuted: Bool
    public let fixtureMaterialized: Bool
    public let exporterInvoked: Bool
    public let projectionInvoked: Bool
    public let historicalGateExecuted: Bool
    public let historicalEvidenceObserved: Bool
    public let evidenceEncoded: Bool
    public let artifactBindingsCreated: Bool
    public let artifactWritePerformed: Bool
    public let evidencePublished: Bool
    public let durablePublicationObserved: Bool
    public let modelExecutionObserved: Bool
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
        let callEdge =
            PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV14
        let exporter =
            PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract
            .frozenV1
        let worker =
            PrimeNativeNeuralGateHistoricalWorkerContract
            .frozenV2

        return Self(
            schemaVersion: 1,
            contractID:
                "prime_source_bound_historical_evidence_semantic_artifact_projection_design_v15",
            rightsHolder: "Ergentics, LLC",
            licenseExpression:
                "LicenseRef-Ergentics-Proprietary",
            preservedCallEdgeSourceContractID:
                callEdge.contractID,
            preservedCallEdgeSourceContractSHA256:
                "8112cf3e6190fcd6385614322be11f391bccc1ca411b6af85c7bd8cf57c4a4e8",
            preservedTopologyV14ID:
                topology.contractID,
            preservedTopologyV14SHA256:
                "4aee5e011a7db85ed74955684f885b03f306e82b8fd4d0f12422d0b791663564",
            preservedExporterSourceContractID:
                exporter.contractID,
            preservedExporterSourceContractSHA256:
                "ecc329a7e56d843b53f9d894af4e335c9d00ac05d56efe308d61860835278d5e",
            preservedSemanticRecordContractID:
                "prime_stage_b_semantic_record_schema_contract_v1",
            preservedSemanticRecordContractSHA256:
                "67451098c4c486cd6a2d1701190c7ba3129d48f47956dc5c674295053f47cf9a",
            preservedSemanticNamespaceContractID:
                "prime_stage_b_non_authorizing_semantic_output_namespace_v4",
            preservedSemanticNamespaceContractSHA256:
                "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
            preservedWorkerContractID:
                worker.contractID,
            exporterCarrierSwiftTypeName:
                "PrimeNativeNeuralGateHistoricalEvidenceExporter.Evidence",
            carrierFieldProjections: [
                field(
                    1,
                    "orderedInvariantRecords",
                    [
                        "PrimeNativeNeuralGateHistoricalInvariantObservation",
                    ],
                    [
                        "invariant-records.v1.bin",
                        "invariant-chunks/{ordinal_8digit}.v1.bin",
                    ],
                    .exact
                ),
                field(
                    2,
                    "orderedInvariantRecordASCIIFlags",
                    [
                        "PrimeNativeNeuralGateHistoricalInvariantObservation",
                    ],
                    [],
                    .validationOnly
                ),
                field(
                    3,
                    "baselineInvariantBundle",
                    [
                        "PrimeNativeNeuralGateHistoricalInvariantObservation",
                        "PrimeNativeNeuralGateHistoricalFingerprintObservation",
                    ],
                    [
                        "invariant-records-manifest.v1.json",
                        "invariant-records.v1.bin",
                        "invariant-chunks/{ordinal_8digit}.v1.bin",
                        "fingerprint-observation.v1.json",
                    ],
                    .exact
                ),
                field(
                    4,
                    "orderedMutationIdentities",
                    [
                        "PrimeNativeNeuralGateHistoricalMutationSweepObservation",
                    ],
                    [
                        "mutation-observations.v1.json",
                    ],
                    .exact
                ),
                field(
                    5,
                    "perMutationStreamIdentities",
                    [
                        "PrimeNativeNeuralGateHistoricalMutationRecordObservation",
                    ],
                    [
                        "mutation-observations.v1.json",
                    ],
                    .exact
                ),
                field(
                    6,
                    "perMutationFingerprints",
                    [
                        "PrimeNativeNeuralGateHistoricalMutationRecordObservation",
                    ],
                    [
                        "mutation-observations.v1.json",
                    ],
                    .exact
                ),
                field(
                    7,
                    "perMutationObservedFailedLegIDs",
                    [
                        "PrimeNativeNeuralGateHistoricalMutationRecordObservation",
                    ],
                    [
                        "mutation-observations.v1.json",
                    ],
                    .exact
                ),
                field(
                    8,
                    "historicalCriticalLegValues",
                    [
                        "PrimeNativeNeuralGateHistoricalGateObservation",
                        "PrimeNativeNeuralGateStatisticsVerdictObservation",
                    ],
                    [
                        "gate-observation.v1.json",
                        "statistics-verdict-observation.v1.json",
                    ],
                    .exact
                ),
                field(
                    9,
                    "historicalStatisticsAndVerdictValues",
                    [
                        "PrimeNativeNeuralGateHistoricalStatisticsVerdictObservation",
                    ],
                    [
                        "statistics-verdict-observation.v1.json",
                    ],
                    .blocked,
                    blockingReason:
                        "lossless_three_seed_to_singular_statistics_projection_not_frozen"
                ),
            ],
            exactCarrierFieldCount: 9,
            carrierRemainsNonCodable: true,
            carrierRemainsRoleNeutral: true,
            carrierRemainsPathFree: true,
            carrierRemainsTimingFree: true,
            carrierRemainsAuthorityFree: true,
            requiredExternalProjectionContextNames: [
                "invocationRole",
                "sourceBytesResolved",
                "adaptationProofRecomputed",
            ],
            externalContextDestinationWorkerArtifactLeafNames: [
                "material-identity-manifest.v1.json",
            ],
            externalProjectionContextMayBeInferredFromCarrier:
                false,
            invocationRoleRequired: true,
            invocationRoleProjectionSource:
                "explicit_worker_invocation_context_only",
            rolePrefixDerivedFromInvocationRole: true,
            workerSemanticFixedLeafPaths: [
                "material-identity-manifest.v1.json",
                "gate-observation.v1.json",
                "invariant-records-manifest.v1.json",
                "invariant-records.v1.bin",
                "fingerprint-observation.v1.json",
                "mutation-observations.v1.json",
                "statistics-verdict-observation.v1.json",
            ],
            workerInvariantChunkLeafPathPattern:
                "invariant-chunks/{ordinal_8digit}.v1.bin",
            exactWorkerInvariantChunkCount: 15,
            exactWorkerSemanticArtifactCountPerRole: 22,
            frozenNamespaceHistoricalKeyNames: [
                "historicalMaterialManifest",
                "historicalGateObservation",
                "historicalMutationObservation",
            ],
            frozenNamespaceHistoricalKeyCountPerRole: 3,
            frozenNamespaceHistoricalEncoding:
                "reserved_schema_deferred",
            frozenNamespaceHistoricalDecoderMode:
                "schema_deferred",
            frozenNamespaceHistoricalSpecsProjectionReady:
                false,
            missingNamespaceFixedLeafPaths: [
                "invariant-records-manifest.v1.json",
                "invariant-records.v1.bin",
                "fingerprint-observation.v1.json",
                "statistics-verdict-observation.v1.json",
            ],
            missingNamespaceDynamicLeafPathPatterns: [
                "invariant-chunks/{ordinal_8digit}.v1.bin",
            ],
            semanticNamespaceComplete: false,
            frozenNamespaceFinalClosed: false,
            descriptorStreamingDecoderImplemented: false,
            admittedHistoricalSeeds: [
                1_618,
                2_718,
                3_141,
            ],
            carrierSeedArrayOrderAuthoritative: false,
            keyedSeedCanonicalizationDefined: true,
            carrierHeldoutStatisticsCount: 3,
            carrierFixedPromptReplayValueCount: 3,
            carrierCapabilityValueCount: 3,
            semanticWeightedStatisticsValueCount: 1,
            semanticFixedPromptMarginValueCount: 1,
            semanticCapabilityValueCount: 1,
            losslessThreeSeedReductionPolicyID:
                "unresolved_no_lossless_three_seed_to_singular_semantic_projection_v1",
            losslessThreeSeedReductionDefined: false,
            additiveKeyedThreeSeedEnvelopeDefined: false,
            statisticsProjectionLossless: false,
            materialIdentitySourceBytesResolvedProjectionState:
                "unavailable",
            materialIdentityAdaptationProofProjectionState:
                "unavailable",
            criticalLegEvidenceProjectionState:
                "unavailable",
            descriptorVerificationProjectionState:
                "unavailable",
            durablePublicationProjectionState:
                "unavailable",
            exactProjectionJoinRuleIDs: [
                "ascii_flag_count_and_each_flag_match_raw_record_bytes_v1",
                "baseline_invariant_bundle_exactly_recomputed_from_ordered_records_v1",
                "mutation_arrays_joined_by_exact_ordinal_and_identity_across_all_46_v1",
                "allowed_failure_singletons_derived_only_from_frozen_historical_catalog_v1",
                "critical_legs_joined_by_exact_ordinal_and_identity_across_all_10_v1",
                "seed_arrays_keyed_and_canonicalized_by_seed_never_positionally_v1",
            ],
            unresolvedSemanticContextFieldNames: [],
            semanticContextFieldPolicyComplete: true,
            carrierDerivedObservationPromotionPermitted: false,
            semanticContextFieldPolicyIDs: [
                "critical_leg_detail_is_fixed_source_derived_historical_carrier_value_v1",
                "critical_leg_evidence_references_empty_until_content_bindings_exist_v1",
                "mutation_execution_observation_unavailable_until_projection_executes_v1",
                "mutation_independent_detection_observation_unavailable_v1",
                "invariant_observation_states_unavailable_until_projection_executes_v1",
                "fingerprint_observation_states_unavailable_until_projection_executes_v1",
                "gate_source_bound_critical_leg_evidence_unavailable_until_bindings_exist_v1",
                "gate_model_execution_observation_unavailable_v1",
                "statistics_distinct_family_observation_unavailable_v1",
                "statistics_four_tier_audit_observation_unavailable_v1",
            ],
            semanticRecordTargetName:
                "PrimeNativeNeuralGateSemanticRecordContracts",
            semanticRecordTargetDirectLocalDependencyNames: [
                "PrimeNativeNeuralGateReplayArtifactContracts",
                "PrimeNativeNeuralGateReplayMechanics",
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            ],
            correctedMutationSurfaceTargetName:
                "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
            historicalWorkerMayReachCorrectedMutationSurface:
                false,
            historicalOnlySemanticProjectionBoundaryAvailable:
                false,
            dependencyIsolationComplete: false,
            reservedProjectionTargetName:
                "PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection",
            reservedProjectionSourceRelativePath:
                "Sources/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection/PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjection.swift",
            projectionPlanSourceBound: true,
            projectionCodecSourceBound: false,
            projectionTargetMaterialized: false,
            projectionSourceMaterialized: false,
            packageGraphChanged: false,
            workerSourceChanged: false,
            workerDependenciesChanged: false,
            workerMainUnavailable: true,
            unavailableExitStatus: 78,
            workerRequestHandlingEnabled: false,
            workerSealed: false,
            workerLaunched: false,
            workerExecuted: false,
            fixtureMaterialized: false,
            exporterInvoked: false,
            projectionInvoked: false,
            historicalGateExecuted: false,
            historicalEvidenceObserved: false,
            evidenceEncoded: false,
            artifactBindingsCreated: false,
            artifactWritePerformed: false,
            evidencePublished: false,
            durablePublicationObserved: false,
            modelExecutionObserved: false,
            independentDetectionEstablished: false,
            distinctImplementationFamiliesEstablished: false,
            agentContractKitFourTierAuditPerformed: false,
            mechanicsPassAuthorized: false,
            terminalReceiptAuthorized: false,
            sourceBindingV7Issued: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            nextImplementationPrerequisite:
                "freeze_the_complete_non_authorizing_historical_semantic_artifact_namespace_and_additive_keyed_three_seed_statistics_envelope_then_source_bind_a_historical_only_projection_codec_without_enabling_worker_request_handling_sealing_launch_execution_publication_or_issuing_source_binding_v7",
            authorityStatement:
                "This V15 design/source contract preserves the exact V13 exporter, V14 private worker/exporter call edge, V14 topology, V8 semantic record contract, V4 non-authorizing namespace, and V2 worker artifact protocol. It source-binds all nine carrier-field artifact-set destinations, exact ordinal/identity joins, explicit fail-closed context-state policies, and the exact seven fixed plus fifteen dynamic worker semantic artifacts per role. Forward audit proves that all three existing V4 historical specifications remain schema-deferred; invariant manifest/global/chunks, fingerprint, and statistics paths are absent; the singular statistics schema cannot retain all three keyed seed families and therefore requires an additive keyed envelope; and the current semantic-record target reaches the corrected mutation surface forbidden from the historical worker closure. V15 therefore materializes no projector source or target, changes no package or worker source/dependency edge, keeps main unavailable at status 78, and performs no carrier projection or encoding. No request handling, sealing, launch, worker/exporter/gate/model execution, evidence publication, durable observation, independent detection, distinct-family or four-tier audit, mechanics PASS, terminal receipt, source or execution binding V7, scientific authority, or product authority is observed or authorized."
        )
    }()

    public func validate() throws {
        let callEdge =
            PrimeNativeNeuralGateHistoricalWorkerEvidenceExportCallEdgeSourceContract
            .frozenV1
        let topology =
            PrimeNativeNeuralGateTrapDisjointTopologyContract
            .frozenV14
        let exporter =
            PrimeNativeNeuralGateHistoricalEvidenceExportSourceContract
            .frozenV1
        let worker =
            PrimeNativeNeuralGateHistoricalWorkerContract
            .frozenV2
        try callEdge.validate()
        try topology.validate()
        try exporter.validate()

        guard self == .frozenV1,
              schemaVersion == 1,
              contractID
                == "prime_source_bound_historical_evidence_semantic_artifact_projection_design_v15",
              rightsHolder == "Ergentics, LLC",
              licenseExpression
                == "LicenseRef-Ergentics-Proprietary",
              preservedCallEdgeSourceContractID
                == callEdge.contractID,
              preservedCallEdgeSourceContractSHA256
                == (try callEdge.contentSHA256()),
              preservedTopologyV14ID
                == topology.contractID,
              preservedTopologyV14SHA256
                == (try topology.contentSHA256()),
              preservedExporterSourceContractID
                == exporter.contractID,
              preservedExporterSourceContractSHA256
                == (try exporter.contentSHA256()),
              preservedSemanticRecordContractID
                == "prime_stage_b_semantic_record_schema_contract_v1",
              preservedSemanticRecordContractSHA256
                == "67451098c4c486cd6a2d1701190c7ba3129d48f47956dc5c674295053f47cf9a",
              preservedSemanticNamespaceContractID
                == "prime_stage_b_non_authorizing_semantic_output_namespace_v4",
              preservedSemanticNamespaceContractSHA256
                == "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
              preservedWorkerContractID
                == worker.contractID,
              carrierFieldProjections.count
                == exactCarrierFieldCount,
              carrierFieldProjections.map(\.ordinal)
                == Array(1 ... exactCarrierFieldCount),
              Set(
                  carrierFieldProjections.map(
                      \.carrierSwiftPropertyName
                  )
              ).count == exactCarrierFieldCount,
              carrierFieldProjections.allSatisfy({
                  $0.validate()
              }),
              carrierFieldProjections.filter({
                  $0.projectionDisposition == .blocked
              }).map(\.ordinal) == [9],
              exactCarrierFieldCount == 9,
              carrierRemainsNonCodable,
              carrierRemainsRoleNeutral,
              carrierRemainsPathFree,
              carrierRemainsTimingFree,
              carrierRemainsAuthorityFree,
              requiredExternalProjectionContextNames
                == [
                    "invocationRole",
                    "sourceBytesResolved",
                    "adaptationProofRecomputed",
                ],
              externalContextDestinationWorkerArtifactLeafNames
                == [
                    "material-identity-manifest.v1.json",
                ],
              !externalProjectionContextMayBeInferredFromCarrier,
              invocationRoleRequired,
              invocationRoleProjectionSource
                == "explicit_worker_invocation_context_only",
              rolePrefixDerivedFromInvocationRole,
              workerSemanticFixedLeafPaths
                == worker.workerOwnedFixedOutputLeafPaths
                    .filter({
                        ![
                            "worker-process-binding.v1.json",
                            "worker-result.v1.json",
                        ].contains($0)
                    }),
              exactWorkerInvariantChunkCount == 15,
              exactWorkerSemanticArtifactCountPerRole
                == workerSemanticFixedLeafPaths.count
                    + exactWorkerInvariantChunkCount,
              exactWorkerSemanticArtifactCountPerRole == 22,
              workerInvariantChunkLeafPathPattern
                == worker.dynamicChunkLeafPathPattern,
              frozenNamespaceHistoricalKeyCountPerRole == 3,
              frozenNamespaceHistoricalKeyNames.count == 3,
              frozenNamespaceHistoricalEncoding
                == "reserved_schema_deferred",
              frozenNamespaceHistoricalDecoderMode
                == "schema_deferred",
              !frozenNamespaceHistoricalSpecsProjectionReady,
              missingNamespaceFixedLeafPaths.count == 4,
              missingNamespaceDynamicLeafPathPatterns
                == [workerInvariantChunkLeafPathPattern],
              !semanticNamespaceComplete,
              !frozenNamespaceFinalClosed,
              !descriptorStreamingDecoderImplemented,
              admittedHistoricalSeeds
                == [1_618, 2_718, 3_141],
              !carrierSeedArrayOrderAuthoritative,
              keyedSeedCanonicalizationDefined,
              carrierHeldoutStatisticsCount == 3,
              carrierFixedPromptReplayValueCount == 3,
              carrierCapabilityValueCount == 3,
              semanticWeightedStatisticsValueCount == 1,
              semanticFixedPromptMarginValueCount == 1,
              semanticCapabilityValueCount == 1,
              !losslessThreeSeedReductionDefined,
              !additiveKeyedThreeSeedEnvelopeDefined,
              !statisticsProjectionLossless,
              materialIdentitySourceBytesResolvedProjectionState
                == "unavailable",
              materialIdentityAdaptationProofProjectionState
                == "unavailable",
              criticalLegEvidenceProjectionState
                == "unavailable",
              descriptorVerificationProjectionState
                == "unavailable",
              durablePublicationProjectionState
                == "unavailable",
              exactProjectionJoinRuleIDs.count == 6,
              Set(exactProjectionJoinRuleIDs).count == 6,
              unresolvedSemanticContextFieldNames.isEmpty,
              semanticContextFieldPolicyComplete,
              !carrierDerivedObservationPromotionPermitted,
              semanticContextFieldPolicyIDs.count == 10,
              Set(semanticContextFieldPolicyIDs).count == 10,
              semanticRecordTargetName
                == "PrimeNativeNeuralGateSemanticRecordContracts",
              semanticRecordTargetDirectLocalDependencyNames
                == [
                    "PrimeNativeNeuralGateReplayArtifactContracts",
                    "PrimeNativeNeuralGateReplayMechanics",
                    "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
                ],
              correctedMutationSurfaceTargetName
                == "PrimeNativeNeuralGateCorrectedMutationSurfaceContracts",
              !historicalWorkerMayReachCorrectedMutationSurface,
              !historicalOnlySemanticProjectionBoundaryAvailable,
              !dependencyIsolationComplete,
              projectionPlanSourceBound,
              !projectionCodecSourceBound,
              !projectionTargetMaterialized,
              !projectionSourceMaterialized,
              !packageGraphChanged,
              !workerSourceChanged,
              !workerDependenciesChanged,
              workerMainUnavailable,
              unavailableExitStatus == 78,
              !workerRequestHandlingEnabled,
              !workerSealed,
              !workerLaunched,
              !workerExecuted,
              !fixtureMaterialized,
              !exporterInvoked,
              !projectionInvoked,
              !historicalGateExecuted,
              !historicalEvidenceObserved,
              !evidenceEncoded,
              !artifactBindingsCreated,
              !artifactWritePerformed,
              !evidencePublished,
              !durablePublicationObserved,
              !modelExecutionObserved,
              !independentDetectionEstablished,
              !distinctImplementationFamiliesEstablished,
              !agentContractKitFourTierAuditPerformed,
              !mechanicsPassAuthorized,
              !terminalReceiptAuthorized,
              !sourceBindingV7Issued,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized
        else {
            throw PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDesignContractError
                .invalidFrozenContract
        }
    }

    public func contentSHA256() throws -> String {
        try validate()
        return PrimeSHA256.hexDigest(
            of: try PrimeCanonicalJSON.encode(self)
        )
    }

    private static func field(
        _ ordinal: Int,
        _ carrierSwiftPropertyName: String,
        _ destinationSwiftTypeNames: [String],
        _ destinationWorkerArtifactLeafNames: [String],
        _ projectionDisposition:
            PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactProjectionDisposition,
        blockingReason: String? = nil
    )
        -> PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactFieldProjection
    {
        PrimeNativeNeuralGateHistoricalEvidenceSemanticArtifactFieldProjection(
            ordinal: ordinal,
            carrierSwiftPropertyName:
                carrierSwiftPropertyName,
            destinationSwiftTypeNames:
                destinationSwiftTypeNames,
            destinationWorkerArtifactLeafNames:
                destinationWorkerArtifactLeafNames,
            projectionDisposition:
                projectionDisposition,
            blockingReason: blockingReason
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case rightsHolder = "rights_holder"
        case licenseExpression = "license_expression"
        case preservedCallEdgeSourceContractID =
            "preserved_call_edge_source_contract_id"
        case preservedCallEdgeSourceContractSHA256 =
            "preserved_call_edge_source_contract_sha256"
        case preservedTopologyV14ID =
            "preserved_topology_v14_id"
        case preservedTopologyV14SHA256 =
            "preserved_topology_v14_sha256"
        case preservedExporterSourceContractID =
            "preserved_exporter_source_contract_id"
        case preservedExporterSourceContractSHA256 =
            "preserved_exporter_source_contract_sha256"
        case preservedSemanticRecordContractID =
            "preserved_semantic_record_contract_id"
        case preservedSemanticRecordContractSHA256 =
            "preserved_semantic_record_contract_sha256"
        case preservedSemanticNamespaceContractID =
            "preserved_semantic_namespace_contract_id"
        case preservedSemanticNamespaceContractSHA256 =
            "preserved_semantic_namespace_contract_sha256"
        case preservedWorkerContractID =
            "preserved_worker_contract_id"
        case exporterCarrierSwiftTypeName =
            "exporter_carrier_swift_type_name"
        case carrierFieldProjections =
            "carrier_field_projections"
        case exactCarrierFieldCount =
            "exact_carrier_field_count"
        case carrierRemainsNonCodable =
            "carrier_remains_non_codable"
        case carrierRemainsRoleNeutral =
            "carrier_remains_role_neutral"
        case carrierRemainsPathFree =
            "carrier_remains_path_free"
        case carrierRemainsTimingFree =
            "carrier_remains_timing_free"
        case carrierRemainsAuthorityFree =
            "carrier_remains_authority_free"
        case requiredExternalProjectionContextNames =
            "required_external_projection_context_names"
        case externalContextDestinationWorkerArtifactLeafNames =
            "external_context_destination_worker_artifact_leaf_names"
        case externalProjectionContextMayBeInferredFromCarrier =
            "external_projection_context_may_be_inferred_from_carrier"
        case invocationRoleRequired =
            "invocation_role_required"
        case invocationRoleProjectionSource =
            "invocation_role_projection_source"
        case rolePrefixDerivedFromInvocationRole =
            "role_prefix_derived_from_invocation_role"
        case workerSemanticFixedLeafPaths =
            "worker_semantic_fixed_leaf_paths"
        case workerInvariantChunkLeafPathPattern =
            "worker_invariant_chunk_leaf_path_pattern"
        case exactWorkerInvariantChunkCount =
            "exact_worker_invariant_chunk_count"
        case exactWorkerSemanticArtifactCountPerRole =
            "exact_worker_semantic_artifact_count_per_role"
        case frozenNamespaceHistoricalKeyNames =
            "frozen_namespace_historical_key_names"
        case frozenNamespaceHistoricalKeyCountPerRole =
            "frozen_namespace_historical_key_count_per_role"
        case frozenNamespaceHistoricalEncoding =
            "frozen_namespace_historical_encoding"
        case frozenNamespaceHistoricalDecoderMode =
            "frozen_namespace_historical_decoder_mode"
        case frozenNamespaceHistoricalSpecsProjectionReady =
            "frozen_namespace_historical_specs_projection_ready"
        case missingNamespaceFixedLeafPaths =
            "missing_namespace_fixed_leaf_paths"
        case missingNamespaceDynamicLeafPathPatterns =
            "missing_namespace_dynamic_leaf_path_patterns"
        case semanticNamespaceComplete =
            "semantic_namespace_complete"
        case frozenNamespaceFinalClosed =
            "frozen_namespace_final_closed"
        case descriptorStreamingDecoderImplemented =
            "descriptor_streaming_decoder_implemented"
        case admittedHistoricalSeeds =
            "admitted_historical_seeds"
        case carrierSeedArrayOrderAuthoritative =
            "carrier_seed_array_order_authoritative"
        case keyedSeedCanonicalizationDefined =
            "keyed_seed_canonicalization_defined"
        case carrierHeldoutStatisticsCount =
            "carrier_heldout_statistics_count"
        case carrierFixedPromptReplayValueCount =
            "carrier_fixed_prompt_replay_value_count"
        case carrierCapabilityValueCount =
            "carrier_capability_value_count"
        case semanticWeightedStatisticsValueCount =
            "semantic_weighted_statistics_value_count"
        case semanticFixedPromptMarginValueCount =
            "semantic_fixed_prompt_margin_value_count"
        case semanticCapabilityValueCount =
            "semantic_capability_value_count"
        case losslessThreeSeedReductionPolicyID =
            "lossless_three_seed_reduction_policy_id"
        case losslessThreeSeedReductionDefined =
            "lossless_three_seed_reduction_defined"
        case additiveKeyedThreeSeedEnvelopeDefined =
            "additive_keyed_three_seed_envelope_defined"
        case statisticsProjectionLossless =
            "statistics_projection_lossless"
        case materialIdentitySourceBytesResolvedProjectionState =
            "material_identity_source_bytes_resolved_projection_state"
        case materialIdentityAdaptationProofProjectionState =
            "material_identity_adaptation_proof_projection_state"
        case criticalLegEvidenceProjectionState =
            "critical_leg_evidence_projection_state"
        case descriptorVerificationProjectionState =
            "descriptor_verification_projection_state"
        case durablePublicationProjectionState =
            "durable_publication_projection_state"
        case exactProjectionJoinRuleIDs =
            "exact_projection_join_rule_ids"
        case unresolvedSemanticContextFieldNames =
            "unresolved_semantic_context_field_names"
        case semanticContextFieldPolicyComplete =
            "semantic_context_field_policy_complete"
        case carrierDerivedObservationPromotionPermitted =
            "carrier_derived_observation_promotion_permitted"
        case semanticContextFieldPolicyIDs =
            "semantic_context_field_policy_ids"
        case semanticRecordTargetName =
            "semantic_record_target_name"
        case semanticRecordTargetDirectLocalDependencyNames =
            "semantic_record_target_direct_local_dependency_names"
        case correctedMutationSurfaceTargetName =
            "corrected_mutation_surface_target_name"
        case historicalWorkerMayReachCorrectedMutationSurface =
            "historical_worker_may_reach_corrected_mutation_surface"
        case historicalOnlySemanticProjectionBoundaryAvailable =
            "historical_only_semantic_projection_boundary_available"
        case dependencyIsolationComplete =
            "dependency_isolation_complete"
        case reservedProjectionTargetName =
            "reserved_projection_target_name"
        case reservedProjectionSourceRelativePath =
            "reserved_projection_source_relative_path"
        case projectionPlanSourceBound =
            "projection_plan_source_bound"
        case projectionCodecSourceBound =
            "projection_codec_source_bound"
        case projectionTargetMaterialized =
            "projection_target_materialized"
        case projectionSourceMaterialized =
            "projection_source_materialized"
        case packageGraphChanged = "package_graph_changed"
        case workerSourceChanged = "worker_source_changed"
        case workerDependenciesChanged =
            "worker_dependencies_changed"
        case workerMainUnavailable =
            "worker_main_unavailable"
        case unavailableExitStatus =
            "unavailable_exit_status"
        case workerRequestHandlingEnabled =
            "worker_request_handling_enabled"
        case workerSealed = "worker_sealed"
        case workerLaunched = "worker_launched"
        case workerExecuted = "worker_executed"
        case fixtureMaterialized = "fixture_materialized"
        case exporterInvoked = "exporter_invoked"
        case projectionInvoked = "projection_invoked"
        case historicalGateExecuted =
            "historical_gate_executed"
        case historicalEvidenceObserved =
            "historical_evidence_observed"
        case evidenceEncoded = "evidence_encoded"
        case artifactBindingsCreated =
            "artifact_bindings_created"
        case artifactWritePerformed =
            "artifact_write_performed"
        case evidencePublished = "evidence_published"
        case durablePublicationObserved =
            "durable_publication_observed"
        case modelExecutionObserved =
            "model_execution_observed"
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
