import Foundation

public enum PrimeNativeNeuralGateArtifactContractError:
    Error,
    Equatable,
    Sendable
{
    case invalidFrozenContract
    case invalidArtifactKey
    case invalidArtifactSpec(String)
    case duplicatePath(String)
}

public enum PrimeNativeNeuralGateArtifactSeed:
    Int,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case seed1618 = 1_618
    case seed2718 = 2_718
    case seed3141 = 3_141

    public var pathComponent: String {
        String(format: "%016d", rawValue)
    }
}

public enum PrimeNativeNeuralGateArtifactArm:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case historicalForensic =
        "historical_forensic"
    case correctedFixedCapEOS =
        "corrected_fixed_cap_eos"
}

public enum PrimeNativeNeuralGateHistoricalArtifactRole:
    String,
    Codable,
    CaseIterable,
    Equatable,
    Sendable
{
    case probe
    case verifier
}

public struct PrimeNativeNeuralGateMutationIdentity:
    Equatable,
    Hashable,
    Sendable
{
    public let arm: PrimeNativeNeuralGateArtifactArm
    public let ordinal: UInt32
    public let mutationID: String
    public let expectedFailedLegID: String

    public init(
        arm: PrimeNativeNeuralGateArtifactArm,
        ordinal: UInt32,
        mutationID: String
    ) throws {
        guard let entry =
                PrimeNativeNeuralGateMutationCatalog
                .entry(
                    arm: arm,
                    ordinal: ordinal
                ),
              mutationID == entry.mutationID
        else {
            throw PrimeNativeNeuralGateArtifactContractError
                .invalidArtifactKey
        }
        self.arm = arm
        self.ordinal = ordinal
        self.mutationID = mutationID
        expectedFailedLegID =
            entry.expectedFailedLegID
    }
}

public struct PrimeNativeNeuralGateMutationCatalogEntry:
    Codable,
    Equatable,
    Hashable,
    Sendable
{
    public let ordinal: UInt32
    public let mutationID: String
    public let expectedFailedLegID: String

    fileprivate init(
        ordinal: UInt32,
        mutationID: String,
        expectedFailedLegID: String
    ) {
        self.ordinal = ordinal
        self.mutationID = mutationID
        self.expectedFailedLegID =
            expectedFailedLegID
    }

    private enum CodingKeys: String, CodingKey {
        case ordinal
        case mutationID = "mutation_id"
        case expectedFailedLegID =
            "expected_failed_leg_id"
    }
}

/// Exact one-based Stage-B mutation identities copied from the frozen Swift
/// authorities and cross-checked against them in the root test target.
///
/// This catalog closes transport identity only. It does not execute a
/// mutation, detect one independently, or authorize a mechanics outcome.
public enum PrimeNativeNeuralGateMutationCatalog {
    public static let historicalEntries =
        makeEntries([
            ("obsolete_schema", "NL1_canonical_material_reload"),
            ("lineage", "NL1_canonical_material_reload"),
            ("quant_hessian_lineage", "NL1_canonical_material_reload"),
            ("profile", "NL1_canonical_material_reload"),
            ("debug_build_configuration", "NL1_canonical_material_reload"),
            ("non_float32_precision", "NL1_canonical_material_reload"),
            ("tokenizer", "NL3_foundation_tokenizer_corpus_regrade"),
            ("corpus_split_leakage", "NL3_foundation_tokenizer_corpus_regrade"),
            ("corpus_label_leakage", "NL3_foundation_tokenizer_corpus_regrade"),
            ("corpus_over_cap_target", "NL3_foundation_tokenizer_corpus_regrade"),
            ("corpus_prompt_window", "NL3_foundation_tokenizer_corpus_regrade"),
            ("target_length_oracle_leakage", "NL4_raw_executor_row_regrade"),
            ("target_dependent_prompt_grouping", "NL4_raw_executor_row_regrade"),
            ("constrained_ascii_decoding", "NL4_raw_executor_row_regrade"),
            ("eos_unavailable", "NL4_raw_executor_row_regrade"),
            ("immediate_eos_mean_omission", "NL4_raw_executor_row_regrade"),
            ("support_witness_inconsistency", "NL4_raw_executor_row_regrade"),
            ("trained_support_assistance", "NL9_capability_and_malformed_abstention"),
            ("executor_prediction", "NL4_raw_executor_row_regrade"),
            ("executor_row_hash", "NL4_raw_executor_row_regrade"),
            ("causal_training", "NL5_causal_training_mechanics"),
            ("heldout_loss_evidence", "NL5_causal_training_mechanics"),
            ("refusal_reason_schedule_count", "NL5_causal_training_mechanics"),
            ("refusal_reason_schedule_hash", "NL5_causal_training_mechanics"),
            ("optimizer_provenance", "NL5_causal_training_mechanics"),
            ("executor_wall_non_finite", "NL5_causal_training_mechanics"),
            ("executor_wall_zero", "NL5_causal_training_mechanics"),
            ("executor_wall_over_cap", "NL5_causal_training_mechanics"),
            ("cached_uncached_multi_step_delta", "NL5_causal_training_mechanics"),
            ("cached_uncached_multi_step_parity", "NL5_causal_training_mechanics"),
            ("cached_uncached_multi_step_decision_count", "NL5_causal_training_mechanics"),
            ("cached_uncached_multi_step_uneven_eos", "NL5_causal_training_mechanics"),
            ("executor_artifact_digest", "NL1_canonical_material_reload"),
            ("executor_artifact_file_name", "NL1_canonical_material_reload"),
            ("recommender_artifact_digest", "NL1_canonical_material_reload"),
            ("recommender_artifact_file_name", "NL1_canonical_material_reload"),
            ("configuration_artifact_digest", "NL1_canonical_material_reload"),
            ("configuration_artifact_file_name", "NL1_canonical_material_reload"),
            ("configuration_wall_cap_mismatch", "NL1_canonical_material_reload"),
            ("metal_library_artifact_digest", "NL1_canonical_material_reload"),
            ("metal_library_bundle_shadow_audit", "NL1_canonical_material_reload"),
            ("durability_checkpoint", "NL6_checkpoint_durability"),
            ("durability_provenance_mismatch", "NL6_checkpoint_durability"),
            ("same_seed_replay", "NL7_same_seed_initialization_training_result_replay"),
            ("seed_consensus", "NL8_frozen_exact_seed_consensus"),
            ("malformed_abstention", "NL9_capability_and_malformed_abstention"),
        ])

    public static let correctedEntries =
        makeEntries([
            ("target_value_changes_raw_execution", "corrected_target_value_independence"),
            ("target_length_changes_raw_execution", "corrected_target_length_independence"),
            ("expected_completion_injected_into_prediction", "corrected_prediction_input_exclusion"),
            ("target_dependent_prompt_grouping", "corrected_prompt_grouping"),
            ("target_dependent_decision_budget", "corrected_decision_budget"),
            ("eos_unavailable_at_decision", "corrected_eos_availability"),
            ("completion_support_narrowed", "corrected_completion_support"),
            ("fixed_cap_drift", "corrected_fixed_cap"),
            ("target_dependent_termination", "corrected_termination_independence"),
            ("target_dependent_row_inclusion", "corrected_row_inclusion_independence"),
            ("correlation_row_id_injected_into_prediction", "corrected_prediction_input_exclusion"),
            ("correlation_split_injected_into_prediction", "corrected_prediction_input_exclusion"),
            ("correlation_semantic_family_injected_into_prediction", "corrected_prediction_input_exclusion"),
            ("row_dependent_evaluation_seed", "corrected_replicate_seed_scope"),
            ("retained_state_changes_permuted_row_trace", "corrected_row_order_state_independence"),
        ])

    public static func entries(
        for arm: PrimeNativeNeuralGateArtifactArm
    ) -> [PrimeNativeNeuralGateMutationCatalogEntry] {
        switch arm {
        case .historicalForensic:
            historicalEntries
        case .correctedFixedCapEOS:
            correctedEntries
        }
    }

    public static func isExactOrderedSequence(
        _ identities:
            [PrimeNativeNeuralGateMutationIdentity],
        for arm: PrimeNativeNeuralGateArtifactArm
    ) -> Bool {
        let expected = entries(for: arm)
        guard identities.count == expected.count
        else {
            return false
        }
        return zip(identities, expected)
            .allSatisfy {
                $0.0.arm == arm
                    && $0.0.ordinal == $0.1.ordinal
                    && $0.0.mutationID
                        == $0.1.mutationID
                    && $0.0.expectedFailedLegID
                        == $0.1.expectedFailedLegID
            }
    }

    fileprivate static func entry(
        arm: PrimeNativeNeuralGateArtifactArm,
        ordinal: UInt32
    ) -> PrimeNativeNeuralGateMutationCatalogEntry? {
        guard ordinal >= 1 else {
            return nil
        }
        let values = entries(for: arm)
        let index = Int(ordinal - 1)
        guard values.indices.contains(index)
        else {
            return nil
        }
        return values[index]
    }

    private static func makeEntries(
        _ definitions:
            [(mutationID: String, expectedFailedLegID: String)]
    ) -> [PrimeNativeNeuralGateMutationCatalogEntry] {
        definitions.enumerated().map {
            PrimeNativeNeuralGateMutationCatalogEntry(
                ordinal: UInt32($0.offset + 1),
                mutationID: $0.element.mutationID,
                expectedFailedLegID:
                    $0.element.expectedFailedLegID
            )
        }
    }
}

/// Exact frozen leg domains used by bounded Stage-B artifact transport.
///
/// The historical order is semantic, not lexical: `NL10` follows `NL9`.
/// Corrected failure-leg order follows first appearance in the frozen
/// fifteen-mutation catalog. These values describe transport identity only
/// and cannot establish that any leg was independently evaluated.
public enum PrimeNativeNeuralGateReplayLegDomain {
    public static let historicalCriticalLegIDs = [
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

    public static let correctedMutationFailureLegIDs = [
        "corrected_target_value_independence",
        "corrected_target_length_independence",
        "corrected_prediction_input_exclusion",
        "corrected_prompt_grouping",
        "corrected_decision_budget",
        "corrected_eos_availability",
        "corrected_completion_support",
        "corrected_fixed_cap",
        "corrected_termination_independence",
        "corrected_row_inclusion_independence",
        "corrected_replicate_seed_scope",
        "corrected_row_order_state_independence",
    ]
}

/// Producer/decoder-shared record identities for the three bounded record
/// shapes currently implemented. Deferred semantic payloads deliberately
/// have no record identity here.
public enum PrimeNativeNeuralGateReplayRecordSchema {
    public static let promptOnlyRowV1 =
        "prime_stage_b_prompt_only_row_v1"
    public static let outerEvaluationRowV1 =
        "prime_stage_b_outer_evaluation_row_v1"
    public static let rawExecutionReferenceV1 =
        "prime_stage_b_raw_execution_reference_v1"

    public static let orderedImplementedIDs = [
        promptOnlyRowV1,
        outerEvaluationRowV1,
        rawExecutionReferenceV1,
    ]
}

public enum PrimeNativeNeuralGateArtifactPurpose:
    String,
    Codable,
    Equatable,
    Sendable
{
    case immutableData = "immutable_data"
}

public enum PrimeNativeNeuralGateArtifactEncoding:
    String,
    Codable,
    Equatable,
    Sendable
{
    case canonicalJSON = "canonical_json_v1"
    case rawUTF8InvariantGlobal =
        "prime_raw_utf8_invariant_global_v1"
    case rawUTF8InvariantChunk =
        "prime_raw_utf8_invariant_chunk_v1"
    case logitDictionary =
        "prime_logit_dictionary_v1"
    case logitChunk = "prime_logit_chunk_v1"
    case logitManifest =
        "prime_logit_manifest_v1"
    case reservedSchemaDeferred =
        "reserved_schema_deferred"
}

public enum PrimeNativeNeuralGateArtifactDecoderMode:
    String,
    Codable,
    Equatable,
    Sendable
{
    case boundedCanonicalJSON =
        "bounded_canonical_json"
    case descriptorStreamingRequired =
        "descriptor_streaming_required"
    case sourceBoundCodecRequired =
        "source_bound_codec_required"
    case schemaDeferred = "schema_deferred"
}

public enum PrimeNativeNeuralGateArtifactOwner:
    String,
    Codable,
    Equatable,
    Sendable
{
    case correctedFixtureAuthority =
        "corrected_fixture_authority"
    case evaluationOwnerDeferred =
        "evaluation_owner_deferred"
    case correctedRawWorker =
        "corrected_raw_worker"
    case mutationProducerDeferred =
        "mutation_producer_deferred"
    case historicalWorkerProbe =
        "historical_worker_probe"
    case historicalWorkerVerifier =
        "historical_worker_verifier"
    case mlxRecomputationOwnerDeferred =
        "mlx_recomputation_owner_deferred"
    case processOwnerDeferred =
        "process_owner_deferred"
    case terminalReceiptOwnerDeferred =
        "terminal_receipt_owner_deferred"
}

public enum PrimeNativeNeuralGateArtifactReader:
    String,
    Codable,
    Equatable,
    Sendable
{
    case correctedRawWorker =
        "corrected_raw_worker"
    case outerEvaluation =
        "outer_evaluation"
    case mutationDetectorDeferred =
        "mutation_detector_deferred"
    case mlxRecomputationReaderDeferred =
        "mlx_recomputation_reader_deferred"
    case terminalVerifier =
        "terminal_verifier"
}

public enum PrimeNativeNeuralGateArtifactKey:
    Equatable,
    Hashable,
    Sendable
{
    case promptOnlyFixtureManifest
    case promptOnlyFixtureGlobal
    case promptOnlyFixtureChunk(UInt32)
    case outerEvaluationManifest
    case outerEvaluationGlobal
    case outerEvaluationChunk(UInt32)
    case rawExecutionManifest(
        PrimeNativeNeuralGateArtifactSeed
    )
    case rawExecutionGlobal(
        PrimeNativeNeuralGateArtifactSeed
    )
    case rawExecutionChunk(
        PrimeNativeNeuralGateArtifactSeed,
        UInt32
    )
    case mutationDeltaManifest(
        PrimeNativeNeuralGateArtifactArm
    )
    case mutationDeltaGlobal(
        PrimeNativeNeuralGateArtifactArm
    )
    case mutationDeltaChunk(
        PrimeNativeNeuralGateArtifactArm,
        UInt32
    )
    case historicalMaterialManifest(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case historicalGateObservation(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case historicalMutationObservation(
        PrimeNativeNeuralGateHistoricalArtifactRole
    )
    case logitDictionary(
        PrimeNativeNeuralGateArtifactSeed
    )
    case logitManifest(
        PrimeNativeNeuralGateArtifactSeed
    )
    case logitChunk(
        PrimeNativeNeuralGateArtifactSeed,
        UInt32
    )
    case mlxObservation(
        PrimeNativeNeuralGateArtifactSeed
    )
    case correctedStatisticsVerdict
    case correctedWorkerRequestReserved
    case correctedWorkerProcessReserved
    case correctedWorkerExecutionReserved
    case correctedWorkerResultReserved
    case replacementTerminalReceiptReserved
}

public struct PrimeNativeNeuralGateArtifactSpec:
    Codable,
    Equatable,
    Sendable
{
    public let schemaID: String
    public let schemaVersion: Int
    public let relativePath: String
    public let maximumByteCount: UInt64
    public let encoding:
        PrimeNativeNeuralGateArtifactEncoding
    public let decoderMode:
        PrimeNativeNeuralGateArtifactDecoderMode
    public let purpose:
        PrimeNativeNeuralGateArtifactPurpose
    public let mode: String
    public let owner:
        PrimeNativeNeuralGateArtifactOwner
    public let allowedReaders:
        [PrimeNativeNeuralGateArtifactReader]
    public let transportCanAuthorizeMechanicsPass:
        Bool
    public let transportCanAuthorizeCapability:
        Bool
    public let transportCanAuthorizeReceipt:
        Bool

    public func validate(
        maximumBoundedInMemoryByteCount:
            UInt64
    ) throws {
        guard Self.isSafeRelativePath(
                  relativePath
              ),
              schemaID.utf8.count <= 160,
              !schemaID.isEmpty,
              schemaID.utf8.allSatisfy({
                  ($0 >= 97 && $0 <= 122)
                      || ($0 >= 48 && $0 <= 57)
                      || $0 == 95
              }),
              schemaVersion == 1,
              maximumByteCount > 0,
              purpose == .immutableData,
              mode == "0444",
              Set(allowedReaders.map(\.rawValue))
                .count == allowedReaders.count,
              allowedReaders.map(\.rawValue)
                == allowedReaders
                .map(\.rawValue).sorted(),
              !transportCanAuthorizeMechanicsPass,
              !transportCanAuthorizeCapability,
              !transportCanAuthorizeReceipt
        else {
            throw PrimeNativeNeuralGateArtifactContractError
                .invalidArtifactSpec(relativePath)
        }
        switch decoderMode {
        case .boundedCanonicalJSON:
            guard encoding == .canonicalJSON,
                  maximumByteCount
                    <= maximumBoundedInMemoryByteCount
            else {
                throw PrimeNativeNeuralGateArtifactContractError
                    .invalidArtifactSpec(relativePath)
            }
        case .descriptorStreamingRequired:
            guard [
                .rawUTF8InvariantGlobal,
                .rawUTF8InvariantChunk,
            ].contains(encoding)
            else {
                throw PrimeNativeNeuralGateArtifactContractError
                    .invalidArtifactSpec(relativePath)
            }
        case .sourceBoundCodecRequired:
            guard [
                .logitDictionary,
                .logitChunk,
                .logitManifest,
            ].contains(encoding)
            else {
                throw PrimeNativeNeuralGateArtifactContractError
                    .invalidArtifactSpec(relativePath)
            }
        case .schemaDeferred:
            guard encoding == .reservedSchemaDeferred
            else {
                throw PrimeNativeNeuralGateArtifactContractError
                    .invalidArtifactSpec(relativePath)
            }
        }
    }

    private static func isSafeRelativePath(
        _ path: String
    ) -> Bool {
        guard !path.hasPrefix("/"),
              !path.contains("\\"),
              !path.contains("\0"),
              path.utf8.allSatisfy({
                  $0 >= 0x21 && $0 <= 0x7e
              })
        else {
            return false
        }
        return path.split(
            separator: "/",
            omittingEmptySubsequences: false
        ).allSatisfy {
            !$0.isEmpty
                && $0 != "."
                && $0 != ".."
                && $0 != ".git"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaID = "schema_id"
        case schemaVersion = "schema_version"
        case relativePath = "relative_path"
        case maximumByteCount =
            "maximum_byte_count"
        case encoding
        case decoderMode = "decoder_mode"
        case purpose
        case mode
        case owner
        case allowedReaders = "allowed_readers"
        case transportCanAuthorizeMechanicsPass =
            "transport_can_authorize_mechanics_pass"
        case transportCanAuthorizeCapability =
            "transport_can_authorize_capability"
        case transportCanAuthorizeReceipt =
            "transport_can_authorize_receipt"
    }
}

public struct PrimeNativeNeuralGateReplayArtifactOutputContract:
    Codable,
    Equatable,
    Sendable
{
    public let schemaVersion: Int
    public let contractID: String
    public let preservedHistoricalOutputContractID:
        String
    public let historicalReplayPlanID: String
    public let admittedSeeds:
        [PrimeNativeNeuralGateArtifactSeed]
    public let admittedArms:
        [PrimeNativeNeuralGateArtifactArm]
    public let historicalRoles:
        [PrimeNativeNeuralGateHistoricalArtifactRole]
    public let maximumBoundedInMemoryByteCount:
        UInt64
    public let maximumJSONNestingDepth: Int
    public let maximumJSONStringByteCount: Int
    public let maximumJSONStructuralTokenCount:
        Int
    public let exactCorrectedFixtureRowCount:
        Int
    public let maximumPromptTokenCount: Int
    public let fullVocabularyLogitCount: Int
    public let maximumGenerationDecisions:
        Int
    public let logitRowsPerChunk: Int
    public let logitChunkCount: Int
    public let maximumLogitDictionaryEntryCount:
        Int
    public let invariantRecordsPerChunk: Int
    public let historicalMutationRecordCount:
        Int
    public let correctedMutationRecordCount:
        Int
    public let fixedRelativePaths: [String]
    public let dynamicRelativePathPatterns:
        [String]
    public let artifactSpecs:
        [PrimeNativeNeuralGateArtifactSpec]
    public let historicalMutationCatalog:
        [PrimeNativeNeuralGateMutationCatalogEntry]
    public let correctedMutationCatalog:
        [PrimeNativeNeuralGateMutationCatalogEntry]
    public let historicalCriticalLegIDs:
        [String]
    public let correctedMutationFailureLegIDs:
        [String]
    public let implementedRecordSchemaIDs:
        [String]
    public let publicationAuthorized: Bool
    public let executionImplemented: Bool
    public let sourceBindingV7Issued: Bool
    public let finalNamespaceClosed: Bool
    public let descriptorStreamingDecoderImplemented:
        Bool
    public let processAndReceiptOwnershipDeferred:
        Bool
    public let mutationProducerDetectorDeferred:
        Bool
    public let authorityStatement: String

    public static let frozenV4: Self = {
        let fixed = Self.fixedKeys.compactMap {
            Self.makeSpec(for: $0)?
                .relativePath
        }
        let specs = Self.allConcreteKeys
            .compactMap {
                Self.makeSpec(for: $0)
            }
            .sorted {
                $0.relativePath < $1.relativePath
            }
        return Self(
            schemaVersion: 4,
            contractID:
                "prime_stage_b_non_authorizing_semantic_output_namespace_v4",
            preservedHistoricalOutputContractID:
                "prime_stage_b_output_path_namespace_classification_v3",
            historicalReplayPlanID:
                "ergentics_prime_native_neural_gate_dual_fixture_replay_v5",
            admittedSeeds:
                PrimeNativeNeuralGateArtifactSeed
                .allCases,
            admittedArms:
                PrimeNativeNeuralGateArtifactArm
                .allCases,
            historicalRoles:
                PrimeNativeNeuralGateHistoricalArtifactRole
                .allCases,
            maximumBoundedInMemoryByteCount:
                1_048_576,
            maximumJSONNestingDepth: 16,
            maximumJSONStringByteCount:
                65_536,
            maximumJSONStructuralTokenCount:
                700_000,
            exactCorrectedFixtureRowCount:
                18_432,
            maximumPromptTokenCount: 4_097,
            fullVocabularyLogitCount: 512,
            maximumGenerationDecisions: 64,
            logitRowsPerChunk: 1_024,
            logitChunkCount: 18,
            maximumLogitDictionaryEntryCount:
                65_536,
            invariantRecordsPerChunk: 4_096,
            historicalMutationRecordCount: 46,
            correctedMutationRecordCount: 15,
            fixedRelativePaths: fixed.sorted(),
            dynamicRelativePathPatterns:
                Self.dynamicPatterns.sorted(),
            artifactSpecs: specs,
            historicalMutationCatalog:
                PrimeNativeNeuralGateMutationCatalog
                .historicalEntries,
            correctedMutationCatalog:
                PrimeNativeNeuralGateMutationCatalog
                .correctedEntries,
            historicalCriticalLegIDs:
                PrimeNativeNeuralGateReplayLegDomain
                .historicalCriticalLegIDs,
            correctedMutationFailureLegIDs:
                PrimeNativeNeuralGateReplayLegDomain
                .correctedMutationFailureLegIDs,
            implementedRecordSchemaIDs:
                PrimeNativeNeuralGateReplayRecordSchema
                .orderedImplementedIDs,
            publicationAuthorized: false,
            executionImplemented: false,
            sourceBindingV7Issued: false,
            finalNamespaceClosed: false,
            descriptorStreamingDecoderImplemented:
                false,
            processAndReceiptOwnershipDeferred:
                true,
            mutationProducerDetectorDeferred:
                true,
            authorityStatement:
                "This V4 overlay preserves the historical V3 output classification and reserves only semantic-content paths and deferred process/receipt paths. It admits bounded canonical JSON only for the prompt-only, outer-evaluation, and raw-execution manifests and their three pathless record shapes, freezes typed bindings for large payloads, and defers every other semantic or process schema. It does not read descriptor-rooted files, stream invariant or logit payloads, execute a worker or mutation, authorize publication, establish mechanics PASS or capability, issue source binding V7, or close the final Stage-B namespace."
        )
    }()

    public func spec(
        for key: PrimeNativeNeuralGateArtifactKey
    ) throws -> PrimeNativeNeuralGateArtifactSpec {
        try validate()
        guard let spec = Self.makeSpec(
            for: key
        ) else {
            throw PrimeNativeNeuralGateArtifactContractError
                .invalidArtifactKey
        }
        try spec.validate(
            maximumBoundedInMemoryByteCount:
                maximumBoundedInMemoryByteCount
        )
        return spec
    }

    public func validate() throws {
        let expectedArtifactSpecs =
            Self.allConcreteKeys
            .compactMap {
                Self.makeSpec(for: $0)
            }
            .sorted {
                $0.relativePath < $1.relativePath
            }
        guard self == .frozenV4,
              schemaVersion == 4,
              admittedSeeds
                == PrimeNativeNeuralGateArtifactSeed
                .allCases,
              admittedArms
                == PrimeNativeNeuralGateArtifactArm
                .allCases,
              historicalRoles
                == PrimeNativeNeuralGateHistoricalArtifactRole
                .allCases,
              maximumBoundedInMemoryByteCount
                == 1_048_576,
              maximumJSONNestingDepth == 16,
              maximumJSONStringByteCount
                == 65_536,
              maximumJSONStructuralTokenCount
                == 700_000,
              exactCorrectedFixtureRowCount
                == 18_432,
              maximumPromptTokenCount == 4_097,
              fullVocabularyLogitCount == 512,
              maximumGenerationDecisions == 64,
              logitRowsPerChunk == 1_024,
              logitChunkCount == 18,
              maximumLogitDictionaryEntryCount
                == 65_536,
              invariantRecordsPerChunk == 4_096,
              historicalMutationRecordCount == 46,
              correctedMutationRecordCount == 15,
              !publicationAuthorized,
              !executionImplemented,
              !sourceBindingV7Issued,
              !finalNamespaceClosed,
              !descriptorStreamingDecoderImplemented,
              processAndReceiptOwnershipDeferred,
              mutationProducerDetectorDeferred,
              Set(fixedRelativePaths).count
                == fixedRelativePaths.count,
              fixedRelativePaths == fixedRelativePaths
                .sorted(),
              Set(dynamicRelativePathPatterns).count
                == dynamicRelativePathPatterns.count,
              dynamicRelativePathPatterns
                == dynamicRelativePathPatterns.sorted(),
              artifactSpecs == expectedArtifactSpecs,
              Set(artifactSpecs.map(\.relativePath))
                .count == artifactSpecs.count,
              historicalMutationCatalog
                == PrimeNativeNeuralGateMutationCatalog
                .historicalEntries,
              correctedMutationCatalog
                == PrimeNativeNeuralGateMutationCatalog
                .correctedEntries,
              historicalCriticalLegIDs
                == PrimeNativeNeuralGateReplayLegDomain
                .historicalCriticalLegIDs,
              correctedMutationFailureLegIDs
                == PrimeNativeNeuralGateReplayLegDomain
                .correctedMutationFailureLegIDs,
              implementedRecordSchemaIDs
                == PrimeNativeNeuralGateReplayRecordSchema
                .orderedImplementedIDs
        else {
            throw PrimeNativeNeuralGateArtifactContractError
                .invalidFrozenContract
        }
        var observed = Set<String>()
        for key in Self.fixedKeys {
            guard let spec = Self.makeSpec(
                for: key
            ) else {
                throw PrimeNativeNeuralGateArtifactContractError
                    .invalidFrozenContract
            }
            try spec.validate(
                maximumBoundedInMemoryByteCount:
                    maximumBoundedInMemoryByteCount
            )
            guard observed.insert(
                spec.relativePath
            ).inserted
            else {
                throw PrimeNativeNeuralGateArtifactContractError
                .duplicatePath(spec.relativePath)
            }
        }
        for spec in artifactSpecs {
            try spec.validate(
                maximumBoundedInMemoryByteCount:
                    maximumBoundedInMemoryByteCount
            )
        }
    }

    private static let fixedKeys:
        [PrimeNativeNeuralGateArtifactKey] =
        [
            .promptOnlyFixtureManifest,
            .promptOnlyFixtureGlobal,
            .outerEvaluationManifest,
            .outerEvaluationGlobal,
            .mutationDeltaManifest(
                .historicalForensic
            ),
            .mutationDeltaGlobal(
                .historicalForensic
            ),
            .mutationDeltaManifest(
                .correctedFixedCapEOS
            ),
            .mutationDeltaGlobal(
                .correctedFixedCapEOS
            ),
            .historicalMaterialManifest(.probe),
            .historicalGateObservation(.probe),
            .historicalMutationObservation(.probe),
            .historicalMaterialManifest(.verifier),
            .historicalGateObservation(.verifier),
            .historicalMutationObservation(.verifier),
            .correctedStatisticsVerdict,
            .correctedWorkerRequestReserved,
            .correctedWorkerProcessReserved,
            .correctedWorkerExecutionReserved,
            .correctedWorkerResultReserved,
            .replacementTerminalReceiptReserved,
        ]
        + PrimeNativeNeuralGateArtifactSeed
        .allCases.flatMap {
            [
                .rawExecutionManifest($0),
                .rawExecutionGlobal($0),
                .logitDictionary($0),
                .logitManifest($0),
                .mlxObservation($0),
            ]
        }

    private static let allConcreteKeys =
        fixedKeys
        + (0 ..< 5).flatMap {
            [
                PrimeNativeNeuralGateArtifactKey
                    .promptOnlyFixtureChunk(
                        UInt32($0)
                    ),
                PrimeNativeNeuralGateArtifactKey
                    .outerEvaluationChunk(
                        UInt32($0)
                    ),
            ]
        }
        + PrimeNativeNeuralGateArtifactArm
        .allCases.map {
            PrimeNativeNeuralGateArtifactKey
                .mutationDeltaChunk($0, 0)
        }
        + PrimeNativeNeuralGateArtifactSeed
        .allCases.flatMap { seed in
            (0 ..< 5).map {
                PrimeNativeNeuralGateArtifactKey
                    .rawExecutionChunk(
                        seed,
                        UInt32($0)
                    )
            }
        }
        + PrimeNativeNeuralGateArtifactSeed
        .allCases.flatMap { seed in
            (0 ..< 18).map {
                PrimeNativeNeuralGateArtifactKey
                    .logitChunk(
                        seed,
                        UInt32($0)
                    )
            }
        }

    private static let dynamicPatterns = [
        "neural-gate-replay/corrected/fixture/prompt-only-rows-chunks/{ordinal_8digit}.v1.bin",
        "neural-gate-replay/corrected/evaluation/outer-material-chunks/{ordinal_8digit}.v1.bin",
        "neural-gate-replay/corrected/mutations/corrected_fixed_cap_eos/delta-chunks/{ordinal_8digit}.v1.bin",
        "neural-gate-replay/corrected/mutations/historical_forensic/delta-chunks/{ordinal_8digit}.v1.bin",
    ]
        + PrimeNativeNeuralGateArtifactSeed
        .allCases.flatMap {
            [
                "neural-gate-replay/corrected/replicates/\($0.pathComponent)/raw-execution-chunks/{ordinal_8digit}.v1.bin",
                "neural-gate-replay/corrected/replicates/\($0.pathComponent)/logits/chunks/{ordinal_8digit}.v1.bin",
            ]
        }

    private static func makeSpec(
        for key: PrimeNativeNeuralGateArtifactKey
    ) -> PrimeNativeNeuralGateArtifactSpec? {
        let jsonLimit: UInt64 = 1_048_576
        let invariantLimit: UInt64 =
            1_073_741_824
        let prefix =
            "neural-gate-replay"
        switch key {
        case .promptOnlyFixtureManifest:
            return json(
                "prompt_only_fixture_manifest",
                "\(prefix)/corrected/fixture/prompt-only-rows-manifest.v1.json",
                .correctedFixtureAuthority,
                [
                    .correctedRawWorker,
                    .terminalVerifier,
                ]
            )
        case .promptOnlyFixtureGlobal:
            return stream(
                "prompt_only_fixture_records",
                "\(prefix)/corrected/fixture/prompt-only-rows.v1.bin",
                .rawUTF8InvariantGlobal,
                .correctedFixtureAuthority,
                [
                    .correctedRawWorker,
                    .terminalVerifier,
                ],
                invariantLimit
            )
        case let .promptOnlyFixtureChunk(ordinal):
            guard ordinal < 5 else {
                return nil
            }
            return stream(
                "prompt_only_fixture_chunk",
                "\(prefix)/corrected/fixture/prompt-only-rows-chunks/\(ordinalPath(ordinal)).v1.bin",
                .rawUTF8InvariantChunk,
                .correctedFixtureAuthority,
                [
                    .correctedRawWorker,
                    .terminalVerifier,
                ],
                invariantLimit
            )
        case .outerEvaluationManifest:
            return json(
                "outer_evaluation_manifest",
                "\(prefix)/corrected/evaluation/outer-material-manifest.v1.json",
                .evaluationOwnerDeferred,
                [
                    .outerEvaluation,
                    .terminalVerifier,
                ]
            )
        case .outerEvaluationGlobal:
            return stream(
                "outer_evaluation_records",
                "\(prefix)/corrected/evaluation/outer-material.v1.bin",
                .rawUTF8InvariantGlobal,
                .evaluationOwnerDeferred,
                [
                    .outerEvaluation,
                    .terminalVerifier,
                ],
                invariantLimit
            )
        case let .outerEvaluationChunk(ordinal):
            guard ordinal < 5 else {
                return nil
            }
            return stream(
                "outer_evaluation_chunk",
                "\(prefix)/corrected/evaluation/outer-material-chunks/\(ordinalPath(ordinal)).v1.bin",
                .rawUTF8InvariantChunk,
                .evaluationOwnerDeferred,
                [
                    .outerEvaluation,
                    .terminalVerifier,
                ],
                invariantLimit
            )
        case let .rawExecutionManifest(seed):
            return json(
                "raw_execution_manifest",
                "\(replicatePrefix(seed))/raw-executions-manifest.v1.json",
                .correctedRawWorker,
                [
                    .outerEvaluation,
                    .terminalVerifier,
                ]
            )
        case let .rawExecutionGlobal(seed):
            return stream(
                "raw_execution_records",
                "\(replicatePrefix(seed))/raw-executions.v1.bin",
                .rawUTF8InvariantGlobal,
                .correctedRawWorker,
                [
                    .outerEvaluation,
                    .terminalVerifier,
                ],
                invariantLimit
            )
        case let .rawExecutionChunk(seed, ordinal):
            guard ordinal < 5 else {
                return nil
            }
            return stream(
                "raw_execution_chunk",
                "\(replicatePrefix(seed))/raw-execution-chunks/\(ordinalPath(ordinal)).v1.bin",
                .rawUTF8InvariantChunk,
                .correctedRawWorker,
                [
                    .outerEvaluation,
                    .terminalVerifier,
                ],
                invariantLimit
            )
        case let .mutationDeltaManifest(arm):
            return reserved(
                "\(arm.rawValue)_mutation_delta_manifest",
                "\(mutationPrefix(arm))/delta-manifest.v1.json",
                .mutationProducerDeferred,
                [
                    .mutationDetectorDeferred,
                    .terminalVerifier,
                ]
            )
        case let .mutationDeltaGlobal(arm):
            return reserved(
                "\(arm.rawValue)_mutation_delta_records",
                "\(mutationPrefix(arm))/deltas.v1.bin",
                .mutationProducerDeferred,
                [
                    .mutationDetectorDeferred,
                    .terminalVerifier,
                ]
            )
        case let .mutationDeltaChunk(
            arm,
            ordinal
        ):
            guard ordinal == 0 else {
                return nil
            }
            return reserved(
                "\(arm.rawValue)_mutation_delta_chunk",
                "\(mutationPrefix(arm))/delta-chunks/\(ordinalPath(ordinal)).v1.bin",
                .mutationProducerDeferred,
                [
                    .mutationDetectorDeferred,
                    .terminalVerifier,
                ]
            )
        case let .historicalMaterialManifest(role):
            return reserved(
                "historical_material_manifest",
                "\(historicalPrefix(role))/material-identity-manifest.v1.json",
                historicalOwner(role)
            )
        case let .historicalGateObservation(role):
            return reserved(
                "historical_gate_observation",
                "\(historicalPrefix(role))/gate-observation.v1.json",
                historicalOwner(role)
            )
        case let .historicalMutationObservation(role):
            return reserved(
                "historical_mutation_observation",
                "\(historicalPrefix(role))/mutation-observations.v1.json",
                historicalOwner(role)
            )
        case let .logitDictionary(seed):
            return codec(
                "logit_dictionary",
                "\(replicatePrefix(seed))/logits/dictionary.v1.bin",
                .logitDictionary,
                268_435_456
            )
        case let .logitManifest(seed):
            return codec(
                "logit_manifest",
                "\(replicatePrefix(seed))/logits/manifest.v1.bin",
                .logitManifest,
                65_536
            )
        case let .logitChunk(seed, ordinal):
            guard ordinal < 18 else {
                return nil
            }
            return codec(
                "logit_chunk",
                "\(replicatePrefix(seed))/logits/chunks/\(ordinalPath(ordinal)).v1.bin",
                .logitChunk,
                1_048_576
            )
        case let .mlxObservation(seed):
            return reserved(
                "mlx_logsoftmax_digest_observation",
                "\(replicatePrefix(seed))/mlx-logsoftmax-observation.v1.json",
                .mlxRecomputationOwnerDeferred,
                [
                    .outerEvaluation,
                    .terminalVerifier,
                ]
            )
        case .correctedStatisticsVerdict:
            return reserved(
                "corrected_statistics_verdict",
                "\(prefix)/corrected/statistics-verdict-observation.v1.json",
                .evaluationOwnerDeferred
            )
        case .correctedWorkerRequestReserved:
            return reserved(
                "corrected_worker_request",
                "\(prefix)/corrected/worker-request.v1.json",
                .processOwnerDeferred
            )
        case .correctedWorkerProcessReserved:
            return reserved(
                "corrected_worker_process",
                "\(prefix)/corrected/worker-process-binding.v1.json",
                .processOwnerDeferred
            )
        case .correctedWorkerExecutionReserved:
            return reserved(
                "corrected_worker_execution",
                "\(prefix)/corrected/worker-execution.v1.json",
                .processOwnerDeferred
            )
        case .correctedWorkerResultReserved:
            return reserved(
                "corrected_worker_result",
                "\(prefix)/corrected/worker-result.v1.json",
                .processOwnerDeferred
            )
        case .replacementTerminalReceiptReserved:
            return reserved(
                "replacement_terminal_receipt",
                "prime-native-neural-gate-fixture-replay-receipt.v2.json",
                .terminalReceiptOwnerDeferred
            )
        }

        func json(
            _ schema: String,
            _ path: String,
            _ owner:
                PrimeNativeNeuralGateArtifactOwner,
            _ readers:
                [PrimeNativeNeuralGateArtifactReader]
        ) -> PrimeNativeNeuralGateArtifactSpec {
            spec(
                schema,
                path,
                jsonLimit,
                .canonicalJSON,
                .boundedCanonicalJSON,
                owner,
                readers
            )
        }

        func stream(
            _ schema: String,
            _ path: String,
            _ encoding:
                PrimeNativeNeuralGateArtifactEncoding,
            _ owner:
                PrimeNativeNeuralGateArtifactOwner,
            _ readers:
                [PrimeNativeNeuralGateArtifactReader],
            _ limit: UInt64
        ) -> PrimeNativeNeuralGateArtifactSpec {
            spec(
                schema,
                path,
                limit,
                encoding,
                .descriptorStreamingRequired,
                owner,
                readers
            )
        }

        func codec(
            _ schema: String,
            _ path: String,
            _ encoding:
                PrimeNativeNeuralGateArtifactEncoding,
            _ limit: UInt64
        ) -> PrimeNativeNeuralGateArtifactSpec {
            spec(
                schema,
                path,
                limit,
                encoding,
                .sourceBoundCodecRequired,
                .correctedRawWorker,
                [
                    .mlxRecomputationReaderDeferred,
                    .terminalVerifier,
                ]
            )
        }

        func reserved(
            _ schema: String,
            _ path: String,
            _ owner:
                PrimeNativeNeuralGateArtifactOwner,
            _ readers:
                [PrimeNativeNeuralGateArtifactReader] =
                [.terminalVerifier]
        ) -> PrimeNativeNeuralGateArtifactSpec {
            spec(
                schema,
                path,
                jsonLimit,
                .reservedSchemaDeferred,
                .schemaDeferred,
                owner,
                readers
            )
        }
    }

    private static func spec(
        _ schema: String,
        _ path: String,
        _ maximumByteCount: UInt64,
        _ encoding:
            PrimeNativeNeuralGateArtifactEncoding,
        _ decoderMode:
            PrimeNativeNeuralGateArtifactDecoderMode,
        _ owner:
            PrimeNativeNeuralGateArtifactOwner,
        _ readers:
            [PrimeNativeNeuralGateArtifactReader]
    ) -> PrimeNativeNeuralGateArtifactSpec {
        PrimeNativeNeuralGateArtifactSpec(
            schemaID:
                "prime_stage_b_\(schema)_v1",
            schemaVersion: 1,
            relativePath: path,
            maximumByteCount:
                maximumByteCount,
            encoding: encoding,
            decoderMode: decoderMode,
            purpose: .immutableData,
            mode: "0444",
            owner: owner,
            allowedReaders:
                readers.sorted {
                    $0.rawValue < $1.rawValue
                },
            transportCanAuthorizeMechanicsPass:
                false,
            transportCanAuthorizeCapability:
                false,
            transportCanAuthorizeReceipt:
                false
        )
    }

    private static func ordinalPath(
        _ ordinal: UInt32
    ) -> String {
        String(format: "%08u", ordinal)
    }

    private static func replicatePrefix(
        _ seed: PrimeNativeNeuralGateArtifactSeed
    ) -> String {
        "neural-gate-replay/corrected/replicates/\(seed.pathComponent)"
    }

    private static func mutationPrefix(
        _ arm: PrimeNativeNeuralGateArtifactArm
    ) -> String {
        "neural-gate-replay/corrected/mutations/\(arm.rawValue)"
    }

    private static func historicalPrefix(
        _ role:
            PrimeNativeNeuralGateHistoricalArtifactRole
    ) -> String {
        "neural-gate-replay/historical/\(role.rawValue)"
    }

    private static func historicalOwner(
        _ role:
            PrimeNativeNeuralGateHistoricalArtifactRole
    ) -> PrimeNativeNeuralGateArtifactOwner {
        switch role {
        case .probe:
            .historicalWorkerProbe
        case .verifier:
            .historicalWorkerVerifier
        }
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case contractID = "contract_id"
        case preservedHistoricalOutputContractID =
            "preserved_historical_output_contract_id"
        case historicalReplayPlanID =
            "historical_replay_plan_id"
        case admittedSeeds = "admitted_seeds"
        case admittedArms = "admitted_arms"
        case historicalRoles = "historical_roles"
        case maximumBoundedInMemoryByteCount =
            "maximum_bounded_in_memory_byte_count"
        case maximumJSONNestingDepth =
            "maximum_json_nesting_depth"
        case maximumJSONStringByteCount =
            "maximum_json_string_byte_count"
        case maximumJSONStructuralTokenCount =
            "maximum_json_structural_token_count"
        case exactCorrectedFixtureRowCount =
            "exact_corrected_fixture_row_count"
        case maximumPromptTokenCount =
            "maximum_prompt_token_count"
        case fullVocabularyLogitCount =
            "full_vocabulary_logit_count"
        case maximumGenerationDecisions =
            "maximum_generation_decisions"
        case logitRowsPerChunk =
            "logit_rows_per_chunk"
        case logitChunkCount =
            "logit_chunk_count"
        case maximumLogitDictionaryEntryCount =
            "maximum_logit_dictionary_entry_count"
        case invariantRecordsPerChunk =
            "invariant_records_per_chunk"
        case historicalMutationRecordCount =
            "historical_mutation_record_count"
        case correctedMutationRecordCount =
            "corrected_mutation_record_count"
        case fixedRelativePaths =
            "fixed_relative_paths"
        case dynamicRelativePathPatterns =
            "dynamic_relative_path_patterns"
        case artifactSpecs = "artifact_specs"
        case historicalMutationCatalog =
            "historical_mutation_catalog"
        case correctedMutationCatalog =
            "corrected_mutation_catalog"
        case historicalCriticalLegIDs =
            "historical_critical_leg_ids"
        case correctedMutationFailureLegIDs =
            "corrected_mutation_failure_leg_ids"
        case implementedRecordSchemaIDs =
            "implemented_record_schema_ids"
        case publicationAuthorized =
            "publication_authorized"
        case executionImplemented =
            "execution_implemented"
        case sourceBindingV7Issued =
            "source_binding_v7_issued"
        case finalNamespaceClosed =
            "final_namespace_closed"
        case descriptorStreamingDecoderImplemented =
            "descriptor_streaming_decoder_implemented"
        case processAndReceiptOwnershipDeferred =
            "process_and_receipt_ownership_deferred"
        case mutationProducerDetectorDeferred =
            "mutation_producer_detector_deferred"
        case authorityStatement =
            "authority_statement"
    }
}
