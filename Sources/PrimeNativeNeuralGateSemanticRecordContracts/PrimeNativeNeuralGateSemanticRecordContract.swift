import Foundation
import PrimeNativeNeuralGateReplayArtifactContracts
import PrimeNativeNeuralGateReplayMechanics

public enum PrimeNativeNeuralGateSemanticRecordContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case invalidSchemaDeclaration(String)
    case invalidArtifactReference(String)
    case invalidSourceIdentity(String)
    case invalidHistoricalObservation(String)
    case invalidMLXObservation(String)
    case invalidStatisticsVerdict(String)
}

/// Explicit observation state for every semantic fact that may not yet have
/// been measured. `unavailable` and `observed_false` are intentionally
/// different wire values; neither is represented by `nil`.
public enum PrimeNativeNeuralGateSemanticObservationState:
    String,
    CaseIterable,
    Encodable,
    Equatable,
    Sendable
{
    case unavailable
    case observedFalse = "observed_false"
    case observedTrue = "observed_true"
}

/// Immutable content reference used by the semantic record schemas.
///
/// This value binds a safe path to bytes. It does not establish that the
/// bytes were descriptor-captured, durably published, delivered to a process,
/// or accepted as evidence.
public struct PrimeNativeNeuralGateSemanticArtifactReference:
    Encodable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let schemaID: String
    public let relativePath: String
    public let contentSHA256: String
    public let byteCount: UInt64
    public let maximumByteCount: UInt64
    public let purpose: String
    public let mode: String
    public let descriptorContentVerified:
        PrimeNativeNeuralGateSemanticObservationState
    public let durablePublicationObserved:
        PrimeNativeNeuralGateSemanticObservationState

    public init(
        schemaID: String,
        relativePath: String,
        contentSHA256: String,
        byteCount: UInt64,
        maximumByteCount: UInt64,
        descriptorContentVerified:
            PrimeNativeNeuralGateSemanticObservationState = .unavailable,
        durablePublicationObserved:
            PrimeNativeNeuralGateSemanticObservationState = .unavailable
    ) throws {
        schemaVersion = 1
        self.schemaID = schemaID
        self.relativePath = relativePath
        self.contentSHA256 = contentSHA256
        self.byteCount = byteCount
        self.maximumByteCount = maximumByteCount
        purpose = "immutable_data"
        mode = "0444"
        self.descriptorContentVerified =
            descriptorContentVerified
        self.durablePublicationObserved =
            durablePublicationObserved
        try validate()
    }

    public func validate() throws {
        guard schemaVersion == 1,
              semanticIsSafeIdentifier(schemaID),
              semanticIsSafeRelativePath(relativePath),
              semanticIsLowercaseSHA256(contentSHA256),
              byteCount > 0,
              maximumByteCount > 0,
              maximumByteCount
                <= PrimeNativeNeuralGateSemanticRecordContract
                .maximumLargeArtifactByteCount,
              byteCount <= maximumByteCount,
              purpose == "immutable_data",
              mode == "0444"
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidArtifactReference(relativePath)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case schemaID = "schema_id"
        case relativePath = "relative_path"
        case contentSHA256 = "content_sha256"
        case byteCount = "byte_count"
        case maximumByteCount = "maximum_byte_count"
        case purpose
        case mode
        case descriptorContentVerified =
            "descriptor_content_verified"
        case durablePublicationObserved =
            "durable_publication_observed"
    }
}

/// Catalog and path declaration only. Mutation transformations and detection
/// logic are intentionally excluded from this target.
public struct PrimeNativeNeuralGateMutationArtifactSchemaDeclaration:
    Encodable,
    Equatable,
    Sendable
{
    public let arm: PrimeNativeNeuralGateArtifactArm
    public let catalogID: String
    public let exactCatalogCount: Int
    public let catalog:
        [PrimeNativeNeuralGateMutationCatalogEntry]
    public let v4ManifestSchemaID: String
    public let semanticManifestSchemaID: String
    public let manifestRelativePath: String
    public let v4RecordStreamSchemaID: String
    public let semanticRecordSchemaID: String
    public let recordStreamRelativePath: String
    public let v4ChunkSchemaID: String
    public let semanticChunkSchemaID: String
    public let chunkRelativePathPattern: String
    public let maximumManifestByteCount: UInt64
    public let maximumRecordStreamByteCount: UInt64
    public let maximumChunkByteCount: UInt64
    public let exactOrExplicitlyAllowedFailureSetRequired:
        Bool
    public let mutationBehaviorImplementedHere: Bool

    fileprivate init(
        arm: PrimeNativeNeuralGateArtifactArm,
        catalogID: String,
        exactCatalogCount: Int,
        catalog:
            [PrimeNativeNeuralGateMutationCatalogEntry],
        v4ManifestSchemaID: String,
        manifestRelativePath: String,
        v4RecordStreamSchemaID: String,
        recordStreamRelativePath: String,
        v4ChunkSchemaID: String,
        chunkRelativePathPattern: String,
        maximumManifestByteCount: UInt64,
        maximumRecordStreamByteCount: UInt64,
        maximumChunkByteCount: UInt64
    ) {
        self.arm = arm
        self.catalogID = catalogID
        self.exactCatalogCount = exactCatalogCount
        self.catalog = catalog
        self.v4ManifestSchemaID = v4ManifestSchemaID
        semanticManifestSchemaID =
            "prime_stage_b_mutation_delta_manifest_v1"
        self.manifestRelativePath = manifestRelativePath
        self.v4RecordStreamSchemaID =
            v4RecordStreamSchemaID
        semanticRecordSchemaID =
            "prime_stage_b_mutation_delta_record_v1"
        self.recordStreamRelativePath =
            recordStreamRelativePath
        self.v4ChunkSchemaID = v4ChunkSchemaID
        semanticChunkSchemaID =
            "prime_stage_b_mutation_delta_chunk_v1"
        self.chunkRelativePathPattern =
            chunkRelativePathPattern
        self.maximumManifestByteCount =
            maximumManifestByteCount
        self.maximumRecordStreamByteCount =
            maximumRecordStreamByteCount
        self.maximumChunkByteCount =
            maximumChunkByteCount
        exactOrExplicitlyAllowedFailureSetRequired = true
        mutationBehaviorImplementedHere = false
    }

    public func validate() throws {
        let v4 =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4
        let manifest = try v4.spec(
            for: .mutationDeltaManifest(arm)
        )
        let records = try v4.spec(
            for: .mutationDeltaGlobal(arm)
        )
        let chunk = try v4.spec(
            for: .mutationDeltaChunk(arm, 0)
        )
        let expectedCatalog =
            PrimeNativeNeuralGateMutationCatalog
            .entries(for: arm)
        guard semanticIsSafeIdentifier(catalogID),
              exactCatalogCount == expectedCatalog.count,
              catalog == expectedCatalog,
              catalog.map(\.ordinal)
                == (1 ... exactCatalogCount)
                .map(UInt32.init),
              v4ManifestSchemaID == manifest.schemaID,
              manifestRelativePath == manifest.relativePath,
              maximumManifestByteCount
                == manifest.maximumByteCount,
              v4RecordStreamSchemaID == records.schemaID,
              recordStreamRelativePath == records.relativePath,
              maximumRecordStreamByteCount
                == records.maximumByteCount,
              v4ChunkSchemaID == chunk.schemaID,
              maximumChunkByteCount
                == chunk.maximumByteCount,
              semanticIsSafeRelativePathPattern(
                  chunkRelativePathPattern
              ),
              semanticIsSafeIdentifier(
                  semanticManifestSchemaID
              ),
              semanticIsSafeIdentifier(
                  semanticRecordSchemaID
              ),
              semanticIsSafeIdentifier(
                  semanticChunkSchemaID
              ),
              exactOrExplicitlyAllowedFailureSetRequired,
              !mutationBehaviorImplementedHere
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidSchemaDeclaration(arm.rawValue)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case arm
        case catalogID = "catalog_id"
        case exactCatalogCount = "exact_catalog_count"
        case catalog
        case v4ManifestSchemaID = "v4_manifest_schema_id"
        case semanticManifestSchemaID =
            "semantic_manifest_schema_id"
        case manifestRelativePath = "manifest_relative_path"
        case v4RecordStreamSchemaID =
            "v4_record_stream_schema_id"
        case semanticRecordSchemaID =
            "semantic_record_schema_id"
        case recordStreamRelativePath =
            "record_stream_relative_path"
        case v4ChunkSchemaID = "v4_chunk_schema_id"
        case semanticChunkSchemaID =
            "semantic_chunk_schema_id"
        case chunkRelativePathPattern =
            "chunk_relative_path_pattern"
        case maximumManifestByteCount =
            "maximum_manifest_byte_count"
        case maximumRecordStreamByteCount =
            "maximum_record_stream_byte_count"
        case maximumChunkByteCount =
            "maximum_chunk_byte_count"
        case exactOrExplicitlyAllowedFailureSetRequired =
            "exact_or_explicitly_allowed_failure_set_required"
        case mutationBehaviorImplementedHere =
            "mutation_behavior_implemented_here"
    }
}

/// Additive semantic overlay. It preserves semantic namespace V4 byte-for-
/// byte and supplies only the missing record identities and validation
/// bounds. No value in this contract is execution evidence.
public struct PrimeNativeNeuralGateSemanticRecordContract:
    Encodable,
    Equatable,
    Sendable
{
    public static let maximumLargeArtifactByteCount:
        UInt64 = 1_073_741_824

    public let schemaVersion: Int
    public let contractID: String
    public let preservedArtifactOutputContractID: String
    public let preservedArtifactOutputContractSHA256:
        String
    public let preservedReplayPlanID: String
    public let preservedReplayPlanSHA256: String
    public let historicalMutationCatalogID: String
    public let historicalMutationCatalogSHA256:
        String
    public let correctedMutationCatalogID: String
    public let mutationArtifactSchemas:
        [PrimeNativeNeuralGateMutationArtifactSchemaDeclaration]
    public let semanticSchemaIDs: [String]
    public let maximumBoundedJSONByteCount: UInt64
    public let maximumJSONNestingDepth: Int
    public let maximumJSONStringByteCount: Int
    public let maximumJSONStructuralTokenCount:
        Int
    public let maximumInvariantRecordCount: Int
    public let maximumInvariantRecordByteCount:
        Int
    public let maximumInvariantAggregateRecordBytes:
        Int
    public let maximumInvariantRecordsPerChunk:
        Int
    public let exactCorrectedFixtureRowCount:
        Int
    public let fullVocabularyLogitCount: Int
    public let exactEvaluationSeeds:
        [PrimeNativeNeuralGateArtifactSeed]
    public let aggregateValuesEncodableOnly: Bool
    public let v4PreservedUnchanged: Bool
    public let semanticSchemasFrozen: Bool
    public let sourcePinningObserved: Bool
    public let processDeliveryObserved: Bool
    public let workerMaterialized: Bool
    public let executionObserved: Bool
    public let durablePublicationObserved: Bool
    public let mechanicsPassAuthorized: Bool
    public let scientificAuthorityAuthorized: Bool
    public let productAuthorityAuthorized: Bool
    public let sourceBindingV7Issued: Bool
    public let authorityStatement: String

    public static let frozenV1: Self = {
        let v4 =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4
        return Self(
            schemaVersion: 1,
            contractID:
                "prime_stage_b_semantic_record_schema_contract_v1",
            preservedArtifactOutputContractID:
                v4.contractID,
            preservedArtifactOutputContractSHA256:
                "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
            preservedReplayPlanID:
                v4.historicalReplayPlanID,
            preservedReplayPlanSHA256:
                "c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b",
            historicalMutationCatalogID:
                "prime_stage_b_historical_forensic_mutation_catalog_46_v1",
            historicalMutationCatalogSHA256:
                "8a1f70ae9f20f60e63cc53df6841d8a160bcbee61621c6f80a4f0272a186100f",
            correctedMutationCatalogID:
                "prime_stage_b_corrected_fixed_cap_eos_mutation_catalog_15_v1",
            mutationArtifactSchemas: [
                .init(
                    arm: .historicalForensic,
                    catalogID:
                        "prime_stage_b_historical_forensic_mutation_catalog_46_v1",
                    exactCatalogCount: 46,
                    catalog:
                        PrimeNativeNeuralGateMutationCatalog
                        .historicalEntries,
                    v4ManifestSchemaID:
                        "prime_stage_b_historical_forensic_mutation_delta_manifest_v1",
                    manifestRelativePath:
                        "neural-gate-replay/corrected/mutations/historical_forensic/delta-manifest.v1.json",
                    v4RecordStreamSchemaID:
                        "prime_stage_b_historical_forensic_mutation_delta_records_v1",
                    recordStreamRelativePath:
                        "neural-gate-replay/corrected/mutations/historical_forensic/deltas.v1.bin",
                    v4ChunkSchemaID:
                        "prime_stage_b_historical_forensic_mutation_delta_chunk_v1",
                    chunkRelativePathPattern:
                        "neural-gate-replay/corrected/mutations/historical_forensic/delta-chunks/{ordinal_8digit}.v1.bin",
                    maximumManifestByteCount:
                        1_048_576,
                    maximumRecordStreamByteCount:
                        1_048_576,
                    maximumChunkByteCount:
                        1_048_576
                ),
                .init(
                    arm: .correctedFixedCapEOS,
                    catalogID:
                        "prime_stage_b_corrected_fixed_cap_eos_mutation_catalog_15_v1",
                    exactCatalogCount: 15,
                    catalog:
                        PrimeNativeNeuralGateMutationCatalog
                        .correctedEntries,
                    v4ManifestSchemaID:
                        "prime_stage_b_corrected_fixed_cap_eos_mutation_delta_manifest_v1",
                    manifestRelativePath:
                        "neural-gate-replay/corrected/mutations/corrected_fixed_cap_eos/delta-manifest.v1.json",
                    v4RecordStreamSchemaID:
                        "prime_stage_b_corrected_fixed_cap_eos_mutation_delta_records_v1",
                    recordStreamRelativePath:
                        "neural-gate-replay/corrected/mutations/corrected_fixed_cap_eos/deltas.v1.bin",
                    v4ChunkSchemaID:
                        "prime_stage_b_corrected_fixed_cap_eos_mutation_delta_chunk_v1",
                    chunkRelativePathPattern:
                        "neural-gate-replay/corrected/mutations/corrected_fixed_cap_eos/delta-chunks/{ordinal_8digit}.v1.bin",
                    maximumManifestByteCount:
                        1_048_576,
                    maximumRecordStreamByteCount:
                        1_048_576,
                    maximumChunkByteCount:
                        1_048_576
                ),
            ],
            semanticSchemaIDs: [
                "prime_stage_b_mutation_delta_manifest_v1",
                "prime_stage_b_mutation_delta_record_v1",
                "prime_stage_b_mutation_delta_chunk_v1",
                "prime_stage_b_historical_material_identity_manifest_v1",
                "prime_stage_b_historical_gate_observation_v1",
                "prime_stage_b_historical_invariant_observation_v1",
                "prime_stage_b_historical_fingerprint_observation_v1",
                "prime_stage_b_historical_mutation_observation_v1",
                "prime_stage_b_historical_statistics_verdict_observation_v1",
                "prime_stage_b_mlx_logsoftmax_digest_observation_v1",
                "prime_stage_b_corrected_statistics_verdict_observation_v1",
                "prime_stage_b_corrected_detector_observation_v1",
            ],
            maximumBoundedJSONByteCount:
                v4.maximumBoundedInMemoryByteCount,
            maximumJSONNestingDepth:
                v4.maximumJSONNestingDepth,
            maximumJSONStringByteCount:
                v4.maximumJSONStringByteCount,
            maximumJSONStructuralTokenCount:
                v4.maximumJSONStructuralTokenCount,
            maximumInvariantRecordCount:
                PrimeNativeNeuralGateReplayDecodeLimits
                .stageB.maximumRecordCount,
            maximumInvariantRecordByteCount:
                PrimeNativeNeuralGateReplayDecodeLimits
                .stageB.maximumRecordByteCount,
            maximumInvariantAggregateRecordBytes:
                PrimeNativeNeuralGateReplayDecodeLimits
                .stageB.maximumAggregateRecordBytes,
            maximumInvariantRecordsPerChunk:
                PrimeNativeNeuralGateInvariantCodec
                .maximumRecordsPerChunk,
            exactCorrectedFixtureRowCount:
                v4.exactCorrectedFixtureRowCount,
            fullVocabularyLogitCount:
                v4.fullVocabularyLogitCount,
            exactEvaluationSeeds:
                PrimeNativeNeuralGateArtifactSeed
                .allCases,
            aggregateValuesEncodableOnly: true,
            v4PreservedUnchanged: true,
            semanticSchemasFrozen: true,
            sourcePinningObserved: false,
            processDeliveryObserved: false,
            workerMaterialized: false,
            executionObserved: false,
            durablePublicationObserved: false,
            mechanicsPassAuthorized: false,
            scientificAuthorityAuthorized: false,
            productAuthorityAuthorized: false,
            sourceBindingV7Issued: false,
            authorityStatement:
                "This additive V1 contract preserves semantic namespace V4 exactly and freezes only deferred semantic record identities, catalog mappings, and strict bounds. Aggregate values are Encodable-only. It does not execute a mutation or model, materialize a worker, observe source pinning, process delivery, durable publication, or evaluation, authorize mechanics PASS or a receipt, issue source binding V7, or establish scientific or product authority."
        )
    }()

    public func validate() throws {
        try PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4.validate()
        try mutationArtifactSchemas.forEach {
            try $0.validate()
        }
        let v4 =
            PrimeNativeNeuralGateReplayArtifactOutputContract
            .frozenV4
        guard self == .frozenV1,
              schemaVersion == 1,
              preservedArtifactOutputContractID
                == v4.contractID,
              preservedArtifactOutputContractSHA256
                == "60e10e6c10f9ec1f30102f5b6d27be123434a163c01d82c0cc5d4520824532d1",
              preservedReplayPlanID
                == v4.historicalReplayPlanID,
              preservedReplayPlanSHA256
                == "c811555bc3a04f053378519ca9c33d18de075d0eb7b347587a9789f4aff3466b",
              mutationArtifactSchemas.map(\.arm)
                == PrimeNativeNeuralGateArtifactArm
                .allCases,
              mutationArtifactSchemas.map(
                  \.exactCatalogCount
              ) == [46, 15],
              Set(semanticSchemaIDs).count
                == semanticSchemaIDs.count,
              semanticSchemaIDs.allSatisfy(
                  semanticIsSafeIdentifier
              ),
              maximumBoundedJSONByteCount
                == 1_048_576,
              maximumJSONNestingDepth == 16,
              maximumJSONStringByteCount == 65_536,
              maximumJSONStructuralTokenCount
                == 700_000,
              maximumInvariantRecordCount
                == 1_000_000,
              maximumInvariantRecordByteCount
                == 16_777_216,
              maximumInvariantAggregateRecordBytes
                == 1_073_741_824,
              maximumInvariantRecordsPerChunk
                == 4_096,
              exactCorrectedFixtureRowCount
                == 18_432,
              fullVocabularyLogitCount == 512,
              exactEvaluationSeeds
                == PrimeNativeNeuralGateArtifactSeed
                .allCases,
              aggregateValuesEncodableOnly,
              v4PreservedUnchanged,
              semanticSchemasFrozen,
              !sourcePinningObserved,
              !processDeliveryObserved,
              !workerMaterialized,
              !executionObserved,
              !durablePublicationObserved,
              !mechanicsPassAuthorized,
              !scientificAuthorityAuthorized,
              !productAuthorityAuthorized,
              !sourceBindingV7Issued
        else {
            throw PrimeNativeNeuralGateSemanticRecordContractError
                .invalidFrozenContract
        }
    }

    /// Deterministic content identity for the frozen scalar/array contract.
    /// This target cannot import PrimeCore's canonical-JSON authority, so the
    /// serialization identifier is explicitly local and non-authorizing.
    public func contentSHA256() throws -> String {
        try validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes,
        ]
        return PrimeNativeNeuralGateInvariantCodec.sha256(
            try encoder.encode(self)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case preservedArtifactOutputContractID =
            "preserved_artifact_output_contract_id"
        case preservedArtifactOutputContractSHA256 =
            "preserved_artifact_output_contract_sha256"
        case preservedReplayPlanID =
            "preserved_replay_plan_id"
        case preservedReplayPlanSHA256 =
            "preserved_replay_plan_sha256"
        case historicalMutationCatalogID =
            "historical_mutation_catalog_id"
        case historicalMutationCatalogSHA256 =
            "historical_mutation_catalog_sha256"
        case correctedMutationCatalogID =
            "corrected_mutation_catalog_id"
        case mutationArtifactSchemas =
            "mutation_artifact_schemas"
        case semanticSchemaIDs = "semantic_schema_ids"
        case maximumBoundedJSONByteCount =
            "maximum_bounded_json_byte_count"
        case maximumJSONNestingDepth =
            "maximum_json_nesting_depth"
        case maximumJSONStringByteCount =
            "maximum_json_string_byte_count"
        case maximumJSONStructuralTokenCount =
            "maximum_json_structural_token_count"
        case maximumInvariantRecordCount =
            "maximum_invariant_record_count"
        case maximumInvariantRecordByteCount =
            "maximum_invariant_record_byte_count"
        case maximumInvariantAggregateRecordBytes =
            "maximum_invariant_aggregate_record_bytes"
        case maximumInvariantRecordsPerChunk =
            "maximum_invariant_records_per_chunk"
        case exactCorrectedFixtureRowCount =
            "exact_corrected_fixture_row_count"
        case fullVocabularyLogitCount =
            "full_vocabulary_logit_count"
        case exactEvaluationSeeds =
            "exact_evaluation_seeds"
        case aggregateValuesEncodableOnly =
            "aggregate_values_encodable_only"
        case v4PreservedUnchanged =
            "v4_preserved_unchanged"
        case semanticSchemasFrozen =
            "semantic_schemas_frozen"
        case sourcePinningObserved =
            "source_pinning_observed"
        case processDeliveryObserved =
            "process_delivery_observed"
        case workerMaterialized = "worker_materialized"
        case executionObserved = "execution_observed"
        case durablePublicationObserved =
            "durable_publication_observed"
        case mechanicsPassAuthorized =
            "mechanics_pass_authorized"
        case scientificAuthorityAuthorized =
            "scientific_authority_authorized"
        case productAuthorityAuthorized =
            "product_authority_authorized"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case authorityStatement = "authority_statement"
    }
}

func semanticIsLowercaseSHA256(
    _ value: String
) -> Bool {
    value.utf8.count == 64
        && value.utf8.allSatisfy {
            ($0 >= 48 && $0 <= 57)
                || ($0 >= 97 && $0 <= 102)
        }
}

func semanticIsSafeIdentifier(
    _ value: String
) -> Bool {
    !value.isEmpty
        && value.utf8.count <= 192
        && value.utf8.allSatisfy {
            ($0 >= 97 && $0 <= 122)
                || ($0 >= 48 && $0 <= 57)
                || $0 == 95
        }
}

func semanticIsSafeRelativePath(
    _ value: String
) -> Bool {
    guard !value.hasPrefix("/"),
          !value.contains("\\"),
          !value.contains("\0"),
          value.utf8.count <= 1_024,
          value.utf8.allSatisfy({
              $0 >= 0x21 && $0 <= 0x7e
          })
    else {
        return false
    }
    return value.split(
        separator: "/",
        omittingEmptySubsequences: false
    ).allSatisfy {
        !$0.isEmpty
            && $0 != "."
            && $0 != ".."
            && $0 != ".git"
    }
}

func semanticIsSafeRelativePathPattern(
    _ value: String
) -> Bool {
    let placeholder = "{ordinal_8digit}"
    guard value.components(
        separatedBy: placeholder
    ).count == 2
    else {
        return false
    }
    return semanticIsSafeRelativePath(
        value.replacingOccurrences(
            of: placeholder,
            with: "00000000"
        )
    )
}

func semanticIsBoundedUTF8(
    _ value: String,
    maximumByteCount: Int
) -> Bool {
    !value.isEmpty
        && value.utf8.count <= maximumByteCount
}
