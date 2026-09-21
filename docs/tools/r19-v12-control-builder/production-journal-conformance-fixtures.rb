# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require_relative "production-operation-frame"

# Scratch-only production-journal conformance assessment and construction.
#
# This module does not read historical receipts and does not manufacture facts
# from expected conformance outputs.  It accepts only newly constructed,
# recursively validated body bytes and the exact physical observations for the
# resulting held frame.  The earlier PASS_R00/FAIL_OPERATION/terminal route
# remains visible below only as a fail-closed audit trail; invocation is retired
# because it would require operational/history-bearing source facts.  The live
# constructor is the six-entry all-INCOMPLETE CATALOG_PLAN.
#
#   00-r00.json PASS_R00
#     -> 01-t01.json FAIL_OPERATION
#     -> 99-terminal.json FAIL_TERMINAL_CANDIDATE
#
# The ordinal-6 predecessor is the highest retained raw frame, ordinal 1.  The
# absent ordinal 2...5 suffix is a terminal-body fact which must be proved by
# that body's recursive validator; it is never inferred by this constructor.
module V12ProductionJournalConformanceFixtures
  FRAME = V12ProductionOperationFrame

  MINIMUM_CHAIN_PLAN = [
    ["00-r00.json", "PASS_R00", "R00", "JOURNAL_R00"],
    ["01-t01.json", "FAIL_OPERATION", "OPERATION", "JOURNAL_OPERATION"],
    ["99-terminal.json", "FAIL_TERMINAL_CANDIDATE", "TERMINAL", "JOURNAL_TERMINAL"]
  ].freeze

  PRODUCTION_JOURNAL_CONFORMANCE_CATALOG_FIELD =
    "production_journal_conformance_fixture_catalog_v12".freeze

  CATALOG_PLAN = [
    ["R00_INCOMPLETE", "00-r00.json", "INCOMPLETE_R00", "R00", "JOURNAL_R00", nil],
    ["T01_INCOMPLETE", "01-t01.json", "INCOMPLETE_OPERATION", "OPERATION", "JOURNAL_OPERATION", "R00_INCOMPLETE"],
    ["B01_INCOMPLETE", "02-b01.json", "INCOMPLETE_OPERATION", "OPERATION", "JOURNAL_OPERATION", "T01_INCOMPLETE"],
    ["B02_INCOMPLETE", "03-b02.json", "INCOMPLETE_OPERATION", "OPERATION", "JOURNAL_OPERATION", "B01_INCOMPLETE"],
    ["B03_INCOMPLETE", "04-b03.json", "INCOMPLETE_OPERATION", "OPERATION", "JOURNAL_OPERATION", "B02_INCOMPLETE"],
    ["B04_INCOMPLETE", "05-b04.json", "INCOMPLETE_OPERATION", "OPERATION", "JOURNAL_OPERATION", "B03_INCOMPLETE"]
  ].freeze

  MERKLE_ALGORITHM_ID =
    "SHA256_DOMAIN_SEPARATED_COMPLETE_FRAME_LEAVES_ODD_DUPLICATION_V12".freeze
  MERKLE_LEAF_DOMAIN = "ergentics-v12-production-journal-catalog-leaf\0".b.freeze
  MERKLE_NODE_DOMAIN = "ergentics-v12-production-journal-catalog-node\0".b.freeze

  RECORD_SCHEMA_TYPE_ID_BY_VARIANT = {
    "R00" => "records.journal.body_schemas.R00",
    "OPERATION" => "records.journal.body_schemas.OPERATION",
    "TERMINAL" => "records.journal.body_schemas.TERMINAL"
  }.freeze

  BODY_SCHEMA_POINTER_BY_VARIANT = {
    "R00" => "/exact_record_schema_v12/records/journal/body_schemas/R00",
    "OPERATION" => FRAME::OPERATION_BODY_SCHEMA_POINTER,
    "TERMINAL" => "/exact_record_schema_v12/records/journal/body_schemas/TERMINAL"
  }.freeze

  CONSTANTS_BY_VARIANT = {
    "R00" => {"body_schema" => "R00_V12", "label" => "R00"},
    "OPERATION" => {"body_schema" => "OPERATION_V12"},
    "TERMINAL" => {"body_schema" => "TERMINAL_V12"}
  }.freeze

  class AssessmentError < StandardError
    attr_reader :code, :details

    def initialize(code, details = {})
      @code = code
      @details = details
      super("#{code}:#{JSON.generate(details)}")
    end
  end

  module_function

  def sha256(bytes)
    Digest::SHA256.hexdigest(bytes)
  end

  def compact(value)
    JSON.generate(value)
  end

  def deep_clone(value)
    Marshal.load(Marshal.dump(value))
  end

  def error_none
    {
      "state_enum" => "NONE",
      "code_string_or_null" => nil,
      "errno_int_or_null" => nil,
      "exception_class_string_or_null" => nil,
      "message_base64_or_null" => nil,
      "message_bytes_uint_or_null" => nil,
      "message_sha256_or_null" => nil
    }
  end

  def exact_body_schema(control, variant)
    schema = control.dig(
      "exact_record_schema_v12", "records", "journal", "body_schemas", variant
    )
    unless schema.is_a?(Hash) && schema.fetch("keys", nil).is_a?(Array) &&
           schema.fetch("field_types_exact", nil).is_a?(Hash)
      raise AssessmentError.new(
        "MISSING_RECORD_BODY_SCHEMA",
        "schema_json_pointer" => BODY_SCHEMA_POINTER_BY_VARIANT.fetch(variant)
      )
    end
    constants = CONSTANTS_BY_VARIANT.fetch(variant)
    constants.each do |key, value|
      unless schema.dig("constants_exact", key) == value
        raise AssessmentError.new(
          "BODY_SCHEMA_CONSTANT_MISMATCH",
          "variant" => variant,
          "key" => key
        )
      end
    end
    schema
  end

  def parse_canonical_fixture_value!(fixture)
    bytes = Base64.strict_decode64(fixture.fetch("canonical_json_base64"))
    unless bytes.bytesize == fixture.fetch("bytes_uint") &&
           sha256(bytes) == fixture.fetch("sha256")
      raise AssessmentError.new(
        "SOURCE_FIXTURE_BYTE_TRIPLE_MISMATCH",
        "fixture_id" => fixture["fixture_id"]
      )
    end
    utf8 = bytes.dup.force_encoding(Encoding::UTF_8)
    unless utf8.valid_encoding?
      raise AssessmentError.new(
        "SOURCE_FIXTURE_NOT_UTF8",
        "fixture_id" => fixture["fixture_id"]
      )
    end
    value = JSON.parse(
      utf8,
      :object_class => FRAME::DuplicateRejectingHash,
      :array_class => Array,
      :create_additions => false
    )
    unless compact(value).b == bytes.b
      raise AssessmentError.new(
        "SOURCE_FIXTURE_NOT_CANONICAL",
        "fixture_id" => fixture["fixture_id"]
      )
    end
    [value, bytes]
  rescue ArgumentError, JSON::ParserError, KeyError => error
    raise AssessmentError.new(
      "SOURCE_FIXTURE_DECODE_FAILED",
      "fixture_id" => fixture["fixture_id"],
      "error_class" => error.class.name
    )
  end

  def valid_fixture_index(source_fixtures)
    by_type = Hash.new { |hash, key| hash[key] = [] }
    source_fixtures.each do |fixture|
      _value, bytes = parse_canonical_fixture_value!(fixture)
      by_type[fixture.fetch("type_id")] << {
        "fixture_id" => fixture.fetch("fixture_id"),
        "bytes_uint" => bytes.bytesize,
        "sha256" => sha256(bytes)
      }
    end
    by_type.each_value { |rows| rows.sort_by! { |row| row.fetch("fixture_id") } }
    by_type
  end

  def referenced_type_id(type_descriptor)
    match = /\AREF\(([^()]+)\)\z/.match(type_descriptor)
    match && match[1]
  end

  def context_bindings_by_pointer(control, record_kind)
    rows = control.dig(
      "exact_record_schema_v12", "state_constraint_registry_v12",
      "record_context_profile_bindings_exact"
    ) || []
    rows.select { |row| row[0] == record_kind }.group_by { |row| row[1] }
  end

  def component_assessment(control, source_fixtures, variant, record_kind)
    schema = exact_body_schema(control, variant)
    fixture_index = valid_fixture_index(source_fixtures)
    bindings = context_bindings_by_pointer(control, record_kind)
    constants = CONSTANTS_BY_VARIANT.fetch(variant)
    schema.fetch("keys").map do |key|
      descriptor = schema.fetch("field_types_exact").fetch(key)
      referenced = referenced_type_id(descriptor)
      candidate_type_id = referenced || descriptor
      candidates = fixture_index.fetch(candidate_type_id, [])
      {
        "body_json_pointer" => "/#{key}",
        "type_descriptor_exact" => descriptor,
        "constant_value_or_null" => constants.key?(key) ? constants.fetch(key) : nil,
        "context_binding_rows_exact" => deep_clone(bindings.fetch("/#{key}", [])),
        "independently_typed_fixture_candidates" => deep_clone(candidates),
        "candidate_state_enum" => if constants.key?(key)
          "SCHEMA_CONSTANT"
        elsif candidates.empty?
          "MISSING_TYPED_SOURCE"
        else
          "STRUCTURAL_CANDIDATE_REQUIRES_CONTEXT_REPLAY"
        end
      }
    end
  end

  def full_body_fixture_candidates(control, source_fixtures, variant)
    type_id = RECORD_SCHEMA_TYPE_ID_BY_VARIANT.fetch(variant)
    schema = exact_body_schema(control, variant)
    source_fixtures.map do |fixture|
      next unless fixture["type_id"] == type_id

      value, bytes = parse_canonical_fixture_value!(fixture)
      next unless value.is_a?(Hash) && value.keys == schema.fetch("keys")

      {
        "fixture_id" => fixture.fetch("fixture_id"),
        "bytes_uint" => bytes.bytesize,
        "sha256" => sha256(bytes)
      }
    end.compact
  end

  def chain_closure_assessment(control:, source_fixtures:)
    frames = MINIMUM_CHAIN_PLAN.map do |leaf, status, variant, record_kind|
      body_candidates = full_body_fixture_candidates(
        control, source_fixtures, variant
      )
      components = component_assessment(
        control, source_fixtures, variant, record_kind
      )
      {
        "leaf" => leaf,
        "status" => status,
        "variant" => variant,
        "record_kind" => record_kind,
        "body_schema_json_pointer" => BODY_SCHEMA_POINTER_BY_VARIANT.fetch(variant),
        "body_schema_sha256" => sha256(compact(exact_body_schema(control, variant))),
        "full_body_fixture_candidates" => body_candidates,
        "component_assessment" => components,
        "body_closure_state_enum" => if body_candidates.empty?
          "MISSING_RECURSIVELY_VALID_FULL_BODY_SOURCE"
        else
          "FULL_BODY_SOURCE_REQUIRES_FRESH_CONTEXT_REPLAY"
        end,
        "postpublication_observation_state_enum" =>
          "DERIVED_SYNTHETIC_AFTER_CANONICAL_FRAME_SIZING"
      }
    end
    {
      "closure_state_enum" => "MISSING_TYPED_DEPENDENCY",
      "chain_plan_exact" => deep_clone(MINIMUM_CHAIN_PLAN),
      "frames" => frames,
      "cross_frame_missing_dependencies" => [
        {
          "dependency_id" => "START_TO_R00_PUBLICATION_SUCCESSOR_JOIN",
          "required_source" => "FRESH_RECURSIVELY_VALID_START_RecordObservationV12_WITH_PublicationOriginV12"
        },
        {
          "dependency_id" => "R00_TO_T01_PREDECESSOR_PUBLICATION_JOIN",
          "required_source" => "FRESH_SYNTHESIZED_00_R00_FrameReferenceV12"
        },
        {
          "dependency_id" => "T01_TO_TERMINAL_PREDECESSOR_PUBLICATION_JOIN",
          "required_source" => "FRESH_SYNTHESIZED_01_T01_FrameReferenceV12"
        },
        {
          "dependency_id" => "TERMINAL_HIGHEST_RAW_SLOT_AND_ABSENT_SUFFIX_JOIN",
          "required_source" => "FRESH_RecordChainV12_RecordFrameBytesSetV12_OperationPrefixProjectionV12_WITH_SLOTS2_THROUGH5_ABSENT"
        }
      ],
      "historical_receipt_interpretation_bool" => false,
      "frame_emitted_bool" => false
    }
  end

  def catalog_schema_definitions
    {
      "SyntheticConformanceProvenanceV12" => {
        "keys" => [
          "dataset_kind_enum", "authority_bool", "historical_operation_bool",
          "operational_evidence_bool", "historical_receipt_interpretation_bool",
          "construction_plan_sha256", "journal_schema_sha256",
          "body_schema_set_sha256"
        ],
        "field_types_exact" => {
          "dataset_kind_enum" => "S", "authority_bool" => "B",
          "historical_operation_bool" => "B", "operational_evidence_bool" => "B",
          "historical_receipt_interpretation_bool" => "B",
          "construction_plan_sha256" => "H64", "journal_schema_sha256" => "H64",
          "body_schema_set_sha256" => "H64"
        },
        "constants_exact" => {
          "dataset_kind_enum" => "SYNTHETIC_CONFORMANCE",
          "authority_bool" => false,
          "historical_operation_bool" => false,
          "operational_evidence_bool" => false,
          "historical_receipt_interpretation_bool" => false
        },
        "rule" => "DIGESTS_COMMIT_THE_EXACT_FROZEN_CATALOG_PLAN_AND_HELD_JOURNAL_SCHEMAS;THIS_DATASET_IS_NEVER_OPERATIONAL_EVIDENCE_OR_A_HISTORICAL_RECEIPT"
      },
      "ProductionJournalConformanceFrameEntryV12" => {
        "keys" => [
          "fixture_id", "leaf", "status", "body_schema_json_pointer",
          "predecessor_fixture_id_or_null", "complete_frame_raw_bytes",
          "frame_reference", "record_observation", "record_frame_bytes"
        ],
        "field_types_exact" => {
          "fixture_id" => "S", "leaf" => "S", "status" => "S",
          "body_schema_json_pointer" => "S",
          "predecessor_fixture_id_or_null" => "S_OR_NULL",
          "complete_frame_raw_bytes" => "REF(RawBytesV12)",
          "frame_reference" => "REF(FrameReferenceV12)",
          "record_observation" => "REF(RecordObservationV12)",
          "record_frame_bytes" => "REF(RecordFrameBytesV12)"
        },
        "rule" => "fixture_id_SELECTS_ONE_EXACT_CATALOG_PLAN_ROW;RAW_BYTES_FRAME_REFERENCE_OBSERVATION_AND_RecordFrameBytesV12_HAVE_EXACT_PATH_VNODE_LENGTH_LF_COMPLETE_SHA256_PAYLOAD_AND_PREDECESSOR_JOINS;ALL_STATUSES_ARE_INCOMPLETE_AND_CANNOT_ASSERT_PASS_FAIL_OR_OPERATIONAL_AUTHORITY"
      },
      "ProductionJournalConformanceIndexRowV12" => {
        "tuple_fields_exact_order" => [
          "entry_ordinal_uint", "fixture_id", "entry_canonical_sha256",
          "complete_frame_sha256", "payload_sha256"
        ],
        "tuple_field_types_exact" => ["U", "S", "H64", "H64", "H64"],
        "rule" => "ONE_ROW_PER_ENTRY_IN_CATALOG_PLAN_ORDER;entry_canonical_sha256_HASHES_THE_COMPLETE_SCHEMA_ORDERED_ProductionJournalConformanceFrameEntryV12_WITH_NO_LF"
      },
      "ProductionJournalConformancePredecessorEdgeV12" => {
        "keys" => [
          "edge_id", "predecessor_fixture_id", "successor_fixture_id",
          "predecessor_complete_frame_sha256", "successor_embedded_predecessor_sha256",
          "joined_bool"
        ],
        "field_types_exact" => {
          "edge_id" => "S", "predecessor_fixture_id" => "S",
          "successor_fixture_id" => "S", "predecessor_complete_frame_sha256" => "H64",
          "successor_embedded_predecessor_sha256" => "H64", "joined_bool" => "B"
        },
        "constants_exact" => {"joined_bool" => true},
        "rule" => "BOTH_HASH_FIELDS_EQUAL_THE_REFERENCED_PREDECESSOR_complete_frame_sha256_AND_THE_SUCCESSOR_RAW_FRAME_PARSED_previous_complete_frame_with_lf_sha256_or_null"
      },
      "ProductionJournalConformanceMerkleCommitmentV12" => {
        "keys" => [
          "algorithm_id", "leaf_domain_base64", "node_domain_base64",
          "odd_rule_enum", "ordered_leaf_count_uint",
          "ordered_leaf_hashes", "root_sha256"
        ],
        "field_types_exact" => {
          "algorithm_id" => "S", "leaf_domain_base64" => "S",
          "node_domain_base64" => "S", "odd_rule_enum" => "S",
          "ordered_leaf_count_uint" => "U",
          "ordered_leaf_hashes" => "ARRAY(H64,6,6,ProductionJournalConformanceCatalogOrderV12)",
          "root_sha256" => "H64"
        },
        "constants_exact" => {
          "algorithm_id" => MERKLE_ALGORITHM_ID,
          "odd_rule_enum" => "DUPLICATE_LAST_AT_EACH_ODD_LEVEL"
        },
        "rule" => "EACH_LEAF_HASH_IS_SHA256(leaf_domain||complete_frame_bytes_with_exact_one_LF);EACH_PARENT_IS_SHA256(node_domain||left_raw_32_bytes||right_raw_32_bytes);AN_ODD_LAST_NODE_IS_DUPLICATED_AT_EACH_LEVEL;ROOT_IS_RECOMPUTED_FROM_ORDERED_CATALOG_ENTRIES"
      },
      "ProductionJournalConformanceFixtureCatalogV12" => {
        "keys" => [
          "provenance", "entries", "index_rows", "predecessor_edges",
          "merkle_commitment", "entry_count_uint", "edge_count_uint",
          "catalog_payload_sha256"
        ],
        "field_types_exact" => {
          "provenance" => "REF(SyntheticConformanceProvenanceV12)",
          "entries" => "ARRAY(ProductionJournalConformanceFrameEntryV12,6,6,ProductionJournalConformanceCatalogOrderV12)",
          "index_rows" => "ARRAY(TUPLE(ProductionJournalConformanceIndexRowV12),6,6,ProductionJournalConformanceCatalogOrderV12)",
          "predecessor_edges" => "ARRAY(ProductionJournalConformancePredecessorEdgeV12,5,5,ProductionJournalConformanceEdgeOrderV12)",
          "merkle_commitment" => "REF(ProductionJournalConformanceMerkleCommitmentV12)",
          "entry_count_uint" => "U", "edge_count_uint" => "U",
          "catalog_payload_sha256" => "H64"
        },
        "constants_exact" => {"entry_count_uint" => 6, "edge_count_uint" => 5},
        "rule" => "catalog_payload_sha256_HASHES_THE_COMPACT_SCHEMA_ORDERED_OBJECT_WITHOUT_THE_FINAL_DIGEST;ENTRIES_INDEX_ROWS_AND_EDGES_ARE_TOTAL_DISTINCT_AND_BIDIRECTIONALLY_JOINED;THE_CATALOG_IS_A_SHARED_CONTENT_ADDRESSED_SOURCE_FOR_C3_AND_CUSTOM_REPLAY_NOT_OPERATIONAL_EVIDENCE"
      }
    }
  end

  def catalog_order_definitions
    {
      "ProductionJournalConformanceCatalogOrderV12" =>
        "EXACT_R00_T01_B01_B02_B03_B04_INCOMPLETE_NO_RUNTIME_RESORT",
      "ProductionJournalConformanceEdgeOrderV12" =>
        "EXACT_R00_TO_T01_TO_B01_TO_B02_TO_B03_TO_B04_INCOMPLETE_NO_RUNTIME_RESORT"
    }
  end

  def catalog_closure_assessment(control:, source_fixtures:)
    frame_rows = CATALOG_PLAN.map do |fixture_id, leaf, status, variant, record_kind, predecessor_id|
      candidates = full_body_fixture_candidates(control, source_fixtures, variant)
      {
        "fixture_id" => fixture_id,
        "leaf" => leaf,
        "status" => status,
        "variant" => variant,
        "record_kind" => record_kind,
        "predecessor_fixture_id_or_null" => predecessor_id,
        "full_body_fixture_candidates" => candidates,
        "component_assessment" => component_assessment(
          control, source_fixtures, variant, record_kind
        ),
        "body_closure_state_enum" => candidates.empty? ?
          "MISSING_RECURSIVELY_VALID_FULL_BODY_SOURCE" :
          "FULL_BODY_SOURCE_REQUIRES_FRESH_CONTEXT_REPLAY",
        "postpublication_observation_state_enum" =>
          "DERIVED_SYNTHETIC_AFTER_CANONICAL_FRAME_SIZING"
      }
    end
    {
      "catalog_field" => PRODUCTION_JOURNAL_CONFORMANCE_CATALOG_FIELD,
      "closure_state_enum" => "MISSING_TYPED_DEPENDENCY",
      "catalog_plan_exact" => deep_clone(CATALOG_PLAN),
      "catalog_schema_definitions_sha256" => sha256(compact(catalog_schema_definitions)),
      "planned_predecessor_edges_exact" => CATALOG_PLAN.drop(1).map do |row|
        {
          "predecessor_fixture_id" => row.fetch(5),
          "successor_fixture_id" => row.fetch(0)
        }
      end,
      "merkle_plan_exact" => {
        "algorithm_id" => MERKLE_ALGORITHM_ID,
        "leaf_domain_base64" => Base64.strict_encode64(MERKLE_LEAF_DOMAIN),
        "node_domain_base64" => Base64.strict_encode64(MERKLE_NODE_DOMAIN),
        "odd_rule_enum" => "DUPLICATE_LAST_AT_EACH_ODD_LEVEL",
        "source_order_enum" =>
          "ProductionJournalConformanceCatalogOrderV12",
        "evaluation_state_enum" => "NOT_EVALUATED_NO_VALID_FRAMES"
      },
      "bidirectional_index_edge_check_state_enum" =>
        "NOT_EVALUATED_NO_VALID_FRAMES",
      "frames" => frame_rows,
      "r00_non_authority_source_requirement" => {
        "start_record_state_enum" => "ABSENT",
        "predecessor_publication_join_state_enum" => "NOT_PROVED",
        "selected_status_enum" => "INCOMPLETE_R00",
        "pass_or_fail_authority_bool" => false,
        "blocking_required_evidence_source_id" => "START",
        "blocking_required_evidence_availability_enum" => "MUST_BE_AVAILABLE",
        "blocking_required_evidence_type" => "HELD_RECORD_FRAME",
        "blocking_required_evidence_schema_json_pointer" =>
          "/exact_record_schema_v12/records/start",
        "blocking_reason_enum" =>
          "NO_NONHISTORICAL_NONAUTHORITY_RECURSIVELY_VALID_START_STATUS_EXISTS"
      },
      "catalog_emitted_bool" => false,
      "historical_receipt_interpretation_bool" => false
    }
  end

  def derive_status_decision(control, record_kind, predicate_evaluations)
    state_by_id = predicate_evaluations.to_h do |row|
      [row.fetch("predicate_id"), row.fetch("state_enum")]
    end
    unless state_by_id.length == predicate_evaluations.length
      raise AssessmentError.new("DUPLICATE_BODY_PREDICATE_ID", "record_kind" => record_kind)
    end
    rules = control.dig(
      "exact_record_schema_v12", "decision_kernel_v12",
      "status_rules_v12", record_kind
    )
    registry = control.dig(
      "exact_record_schema_v12", "decision_kernel_v12",
      "status_ruleset_registry_v12", record_kind
    )
    unless rules.is_a?(Array) && registry.is_a?(Array) && registry.length == 3
      raise AssessmentError.new("MISSING_STATUS_RULE_SOURCE", "record_kind" => record_kind)
    end
    evaluated = []
    selected = rules.sort_by { |rule| rule.fetch("priority_uint") }.find do |rule|
      evaluated << rule.fetch("rule_id")
      rule.fetch("conditions_all").all? do |condition|
        condition.fetch("allowed_states_exact_order").include?(
          state_by_id[condition.fetch("predicate_id")]
        )
      end
    end
    unless selected
      raise AssessmentError.new("STATUS_RULE_NO_MATCH", "record_kind" => record_kind)
    end
    {
      "ruleset_id" => registry.fetch(0),
      "ruleset_complete_json_sha256" => registry.fetch(2),
      "selected_rule_id" => selected.fetch("rule_id"),
      "selected_status_enum" => selected.fetch("selected_status_enum"),
      "evaluated_rule_ids_exact_order" => evaluated
    }
  end

  def validate_status_decision!(control, record_kind, status, body)
    registry = control.dig(
      "exact_record_schema_v12", "decision_kernel_v12",
      "status_ruleset_registry_v12", record_kind
    )
    unless registry.is_a?(Array) && registry.length == 3
      raise AssessmentError.new(
        "MISSING_STATUS_RULESET_REGISTRY",
        "record_kind" => record_kind
      )
    end
    decision = body.fetch("status_decision")
    derived_decision = derive_status_decision(
      control, record_kind, body.fetch("predicate_evaluations")
    )
    unless decision == derived_decision
      raise AssessmentError.new(
        "STATUS_DECISION_NOT_REGENERATED_FROM_PREDICATES",
        "record_kind" => record_kind,
        "status" => status,
        "derived_decision_sha256" => sha256(compact(derived_decision)),
        "actual_decision_sha256" => sha256(compact(decision))
      )
    end
    unless decision.fetch("ruleset_id") == registry[0] &&
           decision.fetch("ruleset_complete_json_sha256") == registry[2] &&
           decision.fetch("selected_status_enum") == status
      raise AssessmentError.new(
        "STATUS_DECISION_REPLAY_MISMATCH",
        "record_kind" => record_kind,
        "status" => status
      )
    end
    states = body.fetch("predicate_evaluations").to_h do |row|
      [row.fetch("predicate_id"), row.fetch("state_enum")]
    end
    unless states.length == body.fetch("predicate_evaluations").length
      raise AssessmentError.new("DUPLICATE_BODY_PREDICATE_ID", "record_kind" => record_kind)
    end
    true
  rescue KeyError, NoMethodError
    raise AssessmentError.new(
      "STATUS_DECISION_SOURCE_MALFORMED",
      "record_kind" => record_kind,
      "status" => status
    )
  end

  def expected_journal_path(control, leaf)
    test_root = control.dig("roots", "creation_order", 0)
    central = control.dig("roots", "central_journal")
    unless test_root.is_a?(String) && central == "<TEST>/captures/journal"
      raise AssessmentError.new("JOURNAL_PATH_CONTROL_SOURCE_MISMATCH")
    end
    File.join(test_root, "captures", "journal", leaf)
  end

  def validate_body!(control, variant, record_kind, status, body_bytes, validator)
    schema = exact_body_schema(control, variant)
    body = FRAME.parse_canonical_object!(
      body_bytes,
      schema.fetch("keys"),
      "#{variant}_BODY"
    )
    CONSTANTS_BY_VARIANT.fetch(variant).each do |key, value|
      unless body.fetch(key) == value
        raise AssessmentError.new(
          "BODY_CONSTANT_VALUE_MISMATCH",
          "variant" => variant,
          "field" => key
        )
      end
    end
    unless validator.respond_to?(:call)
      raise AssessmentError.new(
        "MISSING_RECURSIVE_BODY_VALIDATOR",
        "schema_json_pointer" => BODY_SCHEMA_POINTER_BY_VARIANT.fetch(variant)
      )
    end
    result = validator.call(
      BODY_SCHEMA_POINTER_BY_VARIANT.fetch(variant), body, body_bytes, control
    )
    unless result == true
      raise AssessmentError.new(
        "RECURSIVE_BODY_VALIDATION_FAILED",
        "variant" => variant,
        "body_sha256" => sha256(body_bytes),
        "validator_result" => result
      )
    end
    validate_status_decision!(control, record_kind, status, body)
    body
  end

  def build_nonoperation_frame!(
    control:,
    leaf:,
    status:,
    variant:,
    record_kind:,
    canonical_body_bytes:,
    recursive_body_validator:,
    predecessor_frame_reference:,
    path:,
    vnode:,
    artifact_slot:,
    content_admission:
  )
    journal_schema = FRAME.exact_journal_schema(control)
    ordinal = journal_schema.dig("ordinal_by_leaf_exact", leaf)
    unless ordinal.is_a?(Integer) &&
           journal_schema.dig("body_variant_by_leaf_exact", leaf) == variant &&
           journal_schema.dig("status_by_leaf", leaf)&.include?(status)
      raise AssessmentError.new(
        "NONOPERATION_LEAF_STATUS_VARIANT_MISMATCH",
        "leaf" => leaf,
        "status" => status,
        "variant" => variant
      )
    end
    predecessor_hash = if ordinal.zero?
      unless predecessor_frame_reference.nil?
        raise AssessmentError.new("R00_PREDECESSOR_MUST_BE_NULL")
      end
      nil
    else
      unless predecessor_frame_reference
        raise AssessmentError.new("MISSING_NONZERO_PREDECESSOR", "leaf" => leaf)
      end
      FRAME.validate_frame_reference!(control, predecessor_frame_reference)
      predecessor_frame_reference.fetch("complete_frame_sha256")
    end
    body = validate_body!(
      control,
      variant,
      record_kind,
      status,
      canonical_body_bytes,
      recursive_body_validator
    )
    predigest_object = {
      "schema" => FRAME::JOURNAL_FRAME_SCHEMA,
      "status" => status,
      "leaf" => leaf,
      "ordinal_zero_based" => ordinal,
      "terminal_bool" => journal_schema.dig("terminal_bool_by_leaf_exact", leaf),
      "previous_complete_frame_with_lf_sha256_or_null" => predecessor_hash,
      "body" => body
    }
    predigest_bytes = compact(predigest_object)
    payload_digest = sha256(predigest_bytes)
    envelope = predigest_object.merge("payload_sha256" => payload_digest)
    unless envelope.keys == FRAME::ENVELOPE_KEYS
      raise AssessmentError.new("NONOPERATION_ENVELOPE_ORDER_MISMATCH", "leaf" => leaf)
    end
    complete_bytes = compact(envelope) + "\n"
    contract = FRAME.journal_contract(control)
    cap = contract.fetch("maximum_bytes_per_frame")
    unless complete_bytes.count("\n") == 1 && complete_bytes.end_with?("\n") &&
           complete_bytes.bytesize <= cap
      raise AssessmentError.new(
        "NONOPERATION_FRAME_BYTES_INVALID",
        "leaf" => leaf,
        "bytes_uint" => complete_bytes.bytesize,
        "cap_bytes_uint" => cap
      )
    end
    expected_path = expected_journal_path(control, leaf)
    unless path == expected_path
      raise AssessmentError.new(
        "NONOPERATION_PATH_CONTROL_JOIN_MISMATCH",
        "leaf" => leaf,
        "expected_path" => expected_path,
        "actual_path" => path
      )
    end
    FRAME.validate_vnode!(vnode, complete_bytes.bytesize, leaf, contract)
    FRAME.validate_artifact_slot_join!(control, artifact_slot, path, vnode)
    complete_digest = sha256(complete_bytes)
    FRAME.validate_content_join!(
      control, content_admission, vnode, complete_bytes, complete_digest, cap
    )
    frame_reference = {
      "path" => path,
      "schema" => FRAME::JOURNAL_FRAME_SCHEMA,
      "status" => status,
      "vnode" => deep_clone(vnode),
      "bytes_uint" => complete_bytes.bytesize,
      "lf_count_uint" => 1,
      "complete_frame_sha256" => complete_digest,
      "payload_sha256" => payload_digest
    }
    FRAME.validate_frame_reference!(control, frame_reference, leaf)
    observation = {
      "state_enum" => "FINAL_PRESENT",
      "slot" => deep_clone(artifact_slot),
      "content" => deep_clone(content_admission),
      "parse_state_enum" => "VALID",
      "frame_reference_or_null" => deep_clone(frame_reference),
      "error" => error_none
    }
    bytes_row = {
      "ordinal_uint" => ordinal,
      "leaf" => leaf,
      "frame_reference" => deep_clone(frame_reference),
      "content_admission" => deep_clone(content_admission),
      "bytes_uint" => complete_bytes.bytesize,
      "lf_count_uint" => 1,
      "complete_frame_sha256" => complete_digest
    }
    {
      "predigest_raw_bytes" => FRAME.raw_bytes(predigest_bytes),
      "complete_frame_raw_bytes" => FRAME.raw_bytes(complete_bytes),
      "frame_reference" => frame_reference,
      "record_observation" => observation,
      "record_frame_bytes" => bytes_row
    }
  end

  def nonoperation_complete_frame_bytes!(
    control:,
    leaf:,
    status:,
    variant:,
    record_kind:,
    canonical_body_bytes:,
    recursive_body_validator:,
    predecessor_frame_reference:
  )
    journal = FRAME.exact_journal_schema(control)
    ordinal = journal.dig("ordinal_by_leaf_exact", leaf)
    predecessor_hash = if ordinal.zero?
      raise AssessmentError.new("R00_PREDECESSOR_MUST_BE_NULL") unless predecessor_frame_reference.nil?
      nil
    else
      FRAME.validate_frame_reference!(control, predecessor_frame_reference)
      predecessor_frame_reference.fetch("complete_frame_sha256")
    end
    body = validate_body!(
      control, variant, record_kind, status, canonical_body_bytes,
      recursive_body_validator
    )
    predigest = {
      "schema" => FRAME::JOURNAL_FRAME_SCHEMA,
      "status" => status,
      "leaf" => leaf,
      "ordinal_zero_based" => ordinal,
      "terminal_bool" => journal.dig("terminal_bool_by_leaf_exact", leaf),
      "previous_complete_frame_with_lf_sha256_or_null" => predecessor_hash,
      "body" => body
    }
    complete = compact(predigest.merge("payload_sha256" => sha256(compact(predigest)))) + "\n"
    unless complete.bytesize <= FRAME.journal_contract(control).fetch("maximum_bytes_per_frame")
      raise AssessmentError.new("NONOPERATION_FRAME_CAP_EXCEEDED", "leaf" => leaf)
    end
    complete
  end

  def body_bytes_from_builder!(builders, leaf, prior_frames)
    builder = builders[leaf]
    unless builder.respond_to?(:call)
      raise AssessmentError.new("MISSING_FRESH_BODY_BUILDER", "leaf" => leaf)
    end
    bytes = builder.call(deep_clone(prior_frames))
    unless bytes.is_a?(String)
      raise AssessmentError.new("BODY_BUILDER_DID_NOT_RETURN_BYTES", "leaf" => leaf)
    end
    bytes
  end

  def physical_observation!(observations, leaf)
    row = observations[leaf]
    required = %w[path vnode artifact_slot content_admission]
    unless row.is_a?(Hash) && required.all? { |key| row.key?(key) }
      raise AssessmentError.new(
        "MISSING_FRESH_POSTPUBLICATION_OBSERVATION",
        "leaf" => leaf,
        "required_keys" => required
      )
    end
    row
  end


  def validate_physical_path!(control, leaf, observation)
    expected = expected_journal_path(control, leaf)
    unless observation.fetch("path") == expected &&
           observation.dig("artifact_slot", "final_path") == expected
      raise AssessmentError.new(
        "FRESH_OBSERVATION_PATH_CONTROL_JOIN_MISMATCH",
        "leaf" => leaf,
        "expected_path" => expected
      )
    end
    true
  end

  def fixture(fixture_id, type_id, value)
    bytes = compact(value)
    {
      "fixture_id" => fixture_id,
      "type_id" => type_id,
      "canonical_json_base64" => Base64.strict_encode64(bytes),
      "bytes_uint" => bytes.bytesize,
      "sha256" => sha256(bytes)
    }
  end

  def component_fixtures(prefix, leaf, frame)
    stem = leaf.gsub(/[^0-9A-Za-z]+/, "_").upcase
    [
      fixture("#{prefix}_#{stem}_RAW", "RawBytesV12", frame.fetch("complete_frame_raw_bytes")),
      fixture("#{prefix}_#{stem}_REF", "FrameReferenceV12", frame.fetch("frame_reference")),
      fixture("#{prefix}_#{stem}_OBS", "RecordObservationV12", frame.fetch("record_observation")),
      fixture("#{prefix}_#{stem}_BYTES", "RecordFrameBytesV12", frame.fetch("record_frame_bytes"))
    ]
  end

  def catalog_body_bytes_from_builder!(builders, fixture_id, prior_entries)
    builder = builders[fixture_id]
    unless builder.respond_to?(:call)
      raise AssessmentError.new(
        "MISSING_FRESH_CATALOG_BODY_BUILDER", "fixture_id" => fixture_id
      )
    end
    bytes = builder.call(deep_clone(prior_entries))
    unless bytes.is_a?(String)
      raise AssessmentError.new(
        "CATALOG_BODY_BUILDER_DID_NOT_RETURN_BYTES", "fixture_id" => fixture_id
      )
    end
    bytes
  end

  def catalog_physical_observation!(control, observations, fixture_id, leaf)
    row = observations[fixture_id]
    required = %w[path vnode artifact_slot content_admission]
    unless row.is_a?(Hash) && required.all? { |key| row.key?(key) }
      raise AssessmentError.new(
        "MISSING_FRESH_CATALOG_POSTPUBLICATION_OBSERVATION",
        "fixture_id" => fixture_id,
        "required_keys" => required
      )
    end
    validate_physical_path!(control, leaf, row)
    row
  end

  def parse_complete_frame!(raw_bytes_value)
    bytes = Base64.strict_decode64(raw_bytes_value.fetch("base64"))
    unless bytes.bytesize == raw_bytes_value.fetch("bytes_uint") &&
           sha256(bytes) == raw_bytes_value.fetch("sha256") &&
           bytes.end_with?("\n") && bytes.count("\n") == 1
      raise AssessmentError.new("CATALOG_RAW_FRAME_BYTE_JOIN_FAILED")
    end
    json = bytes.delete_suffix("\n")
    parsed = JSON.parse(
      json,
      :object_class => FRAME::DuplicateRejectingHash,
      :array_class => Array,
      :create_additions => false
    )
    unless parsed.keys == FRAME::ENVELOPE_KEYS && compact(parsed) == json
      raise AssessmentError.new("CATALOG_RAW_FRAME_CANONICAL_JOIN_FAILED")
    end
    predigest = parsed.reject { |key, _value| key == "payload_sha256" }
    unless predigest.keys == FRAME::ENVELOPE_KEYS.first(7) &&
           parsed.fetch("payload_sha256") == sha256(compact(predigest))
      raise AssessmentError.new("CATALOG_RAW_FRAME_PAYLOAD_JOIN_FAILED")
    end
    parsed
  rescue ArgumentError, JSON::ParserError, KeyError => error
    raise AssessmentError.new(
      "CATALOG_RAW_FRAME_PARSE_FAILED", "error_class" => error.class.name
    )
  end

  def catalog_entry(plan_row, frame)
    fixture_id, leaf, status, variant, _record_kind, predecessor_id = plan_row
    {
      "fixture_id" => fixture_id,
      "leaf" => leaf,
      "status" => status,
      "body_schema_json_pointer" => BODY_SCHEMA_POINTER_BY_VARIANT.fetch(variant),
      "predecessor_fixture_id_or_null" => predecessor_id,
      "complete_frame_raw_bytes" => deep_clone(frame.fetch("complete_frame_raw_bytes")),
      "frame_reference" => deep_clone(frame.fetch("frame_reference")),
      "record_observation" => deep_clone(frame.fetch("record_observation")),
      "record_frame_bytes" => deep_clone(frame.fetch("record_frame_bytes"))
    }
  end

  def catalog_edge(predecessor_entry, successor_entry)
    predecessor_id = predecessor_entry.fetch("fixture_id")
    successor_id = successor_entry.fetch("fixture_id")
    predecessor_hash = predecessor_entry.dig(
      "frame_reference", "complete_frame_sha256"
    )
    successor_envelope = parse_complete_frame!(
      successor_entry.fetch("complete_frame_raw_bytes")
    )
    embedded_hash = successor_envelope.fetch(
      "previous_complete_frame_with_lf_sha256_or_null"
    )
    unless predecessor_hash == embedded_hash
      raise AssessmentError.new(
        "CATALOG_PREDECESSOR_EDGE_JOIN_FAILED",
        "predecessor_fixture_id" => predecessor_id,
        "successor_fixture_id" => successor_id
      )
    end
    {
      "edge_id" => "CATALOG_#{predecessor_id}_TO_#{successor_id}",
      "predecessor_fixture_id" => predecessor_id,
      "successor_fixture_id" => successor_id,
      "predecessor_complete_frame_sha256" => predecessor_hash,
      "successor_embedded_predecessor_sha256" => embedded_hash,
      "joined_bool" => true
    }
  end

  def merkle_commitment(entries)
    leaf_hashes = entries.map do |entry|
      raw = Base64.strict_decode64(
        entry.fetch("complete_frame_raw_bytes").fetch("base64")
      )
      unless raw.bytesize == entry.dig("complete_frame_raw_bytes", "bytes_uint") &&
             sha256(raw) == entry.dig("frame_reference", "complete_frame_sha256")
        raise AssessmentError.new(
          "CATALOG_MERKLE_SOURCE_BYTE_JOIN_FAILED",
          "fixture_id" => entry.fetch("fixture_id")
        )
      end
      sha256(MERKLE_LEAF_DOMAIN + raw.b)
    end
    raise AssessmentError.new("CATALOG_MERKLE_EMPTY") if leaf_hashes.empty?

    level = leaf_hashes.dup
    until level.length == 1
      level << level.last if level.length.odd?
      level = level.each_slice(2).map do |left, right|
        sha256(
          MERKLE_NODE_DOMAIN + [left].pack("H*") + [right].pack("H*")
        )
      end
    end
    {
      "algorithm_id" => MERKLE_ALGORITHM_ID,
      "leaf_domain_base64" => Base64.strict_encode64(MERKLE_LEAF_DOMAIN),
      "node_domain_base64" => Base64.strict_encode64(MERKLE_NODE_DOMAIN),
      "odd_rule_enum" => "DUPLICATE_LAST_AT_EACH_ODD_LEVEL",
      "ordered_leaf_count_uint" => leaf_hashes.length,
      "ordered_leaf_hashes" => leaf_hashes,
      "root_sha256" => level.fetch(0)
    }
  end

  def validate_catalog_bidirectional!(entries, index_rows, edges, merkle)
    planned_ids = CATALOG_PLAN.map(&:first)
    unless entries.map { |entry| entry.fetch("fixture_id") } == planned_ids
      raise AssessmentError.new("CATALOG_ENTRY_PLAN_ORDER_MISMATCH")
    end
    unless index_rows.length == entries.length &&
           index_rows.each_with_index.all? do |row, ordinal|
             entry = entries.fetch(ordinal)
             row == [
               ordinal,
               entry.fetch("fixture_id"),
               sha256(compact(entry)),
               entry.dig("frame_reference", "complete_frame_sha256"),
               entry.dig("frame_reference", "payload_sha256")
             ]
           end
      raise AssessmentError.new("CATALOG_INDEX_ENTRY_BIDIRECTIONAL_JOIN_FAILED")
    end
    expected_pairs = CATALOG_PLAN.drop(1).map do |row|
      [row.fetch(5), row.fetch(0)]
    end
    actual_pairs = edges.map do |edge|
      [edge.fetch("predecessor_fixture_id"), edge.fetch("successor_fixture_id")]
    end
    unless actual_pairs == expected_pairs && edges.all? { |edge| edge["joined_bool"] == true }
      raise AssessmentError.new("CATALOG_EDGE_PLAN_BIDIRECTIONAL_JOIN_FAILED")
    end
    unless merkle == merkle_commitment(entries)
      raise AssessmentError.new("CATALOG_MERKLE_ROUND_TRIP_MISMATCH")
    end
    true
  end

  def build_catalog!(
    control:,
    body_builders:,
    recursive_body_validator:,
    postpublication_observations: nil
  )
    frames = {}
    entries = {}

    CATALOG_PLAN.each_with_index do |plan, index|
      fixture_id, leaf, status, variant, record_kind, predecessor_id = plan
      body = catalog_body_bytes_from_builder!(
        body_builders, fixture_id, entries
      )
      predecessor_reference = predecessor_id &&
        frames.fetch(predecessor_id).fetch("frame_reference")
      observation = postpublication_observations &&
        catalog_physical_observation!(
          control, postpublication_observations, fixture_id, leaf
        )

      frames[fixture_id] = if variant == "R00"
        if observation.nil?
          complete = nonoperation_complete_frame_bytes!(
            :control => control, :leaf => leaf, :status => status,
            :variant => variant, :record_kind => record_kind,
            :canonical_body_bytes => body,
            :recursive_body_validator => recursive_body_validator,
            :predecessor_frame_reference => predecessor_reference
          )
          observation = FRAME.synthetic_physical_observation(
            control, expected_journal_path(control, leaf), complete, 100 + index
          )
        end
        build_nonoperation_frame!(
          :control => control, :leaf => leaf, :status => status,
          :variant => variant, :record_kind => record_kind,
          :canonical_body_bytes => body,
          :recursive_body_validator => recursive_body_validator,
          :predecessor_frame_reference => predecessor_reference,
          :path => observation.fetch("path"),
          :vnode => observation.fetch("vnode"),
          :artifact_slot => observation.fetch("artifact_slot"),
          :content_admission => observation.fetch("content_admission")
        )
      elsif observation
        FRAME.build_incomplete!(
          :control => control, :leaf => leaf,
          :canonical_body_bytes => body,
          :recursive_body_validator => recursive_body_validator,
          :predecessor_frame_reference => predecessor_reference,
          :path => observation.fetch("path"),
          :vnode => observation.fetch("vnode"),
          :artifact_slot => observation.fetch("artifact_slot"),
          :content_admission => observation.fetch("content_admission")
        )
      else
        FRAME.build_synthetic_incomplete!(
          :control => control, :leaf => leaf,
          :canonical_body_bytes => body,
          :recursive_body_validator => recursive_body_validator,
          :predecessor_frame_reference => predecessor_reference,
          :path => expected_journal_path(control, leaf),
          :synthetic_identity_ordinal => 100 + index
        )
      end
      entries[fixture_id] = catalog_entry(plan, frames.fetch(fixture_id))
    end

    ordered_entries = CATALOG_PLAN.map { |row| entries.fetch(row.fetch(0)) }
    vnode_identities = ordered_entries.map do |entry|
      vnode = entry.dig("frame_reference", "vnode")
      [vnode.fetch("device_uint"), vnode.fetch("inode_uint"), vnode.fetch("generation_uint")]
    end
    unless vnode_identities.uniq.length == vnode_identities.length
      raise AssessmentError.new("CATALOG_FRAME_VNODE_IDENTITIES_NOT_DISTINCT")
    end
    index_rows = ordered_entries.each_with_index.map do |entry, ordinal|
      [
        ordinal,
        entry.fetch("fixture_id"),
        sha256(compact(entry)),
        entry.dig("frame_reference", "complete_frame_sha256"),
        entry.dig("frame_reference", "payload_sha256")
      ]
    end
    edges = CATALOG_PLAN.drop(1).map do |plan|
      catalog_edge(
        entries.fetch(plan.fetch(5)), entries.fetch(plan.fetch(0))
      )
    end
    merkle = merkle_commitment(ordered_entries)
    validate_catalog_bidirectional!(ordered_entries, index_rows, edges, merkle)
    journal_schema = FRAME.exact_journal_schema(control)
    body_schema_set = {
      "R00" => exact_body_schema(control, "R00"),
      "OPERATION" => exact_body_schema(control, "OPERATION")
    }
    provenance = {
      "dataset_kind_enum" => "SYNTHETIC_CONFORMANCE",
      "authority_bool" => false,
      "historical_operation_bool" => false,
      "operational_evidence_bool" => false,
      "historical_receipt_interpretation_bool" => false,
      "construction_plan_sha256" => sha256(compact(CATALOG_PLAN)),
      "journal_schema_sha256" => sha256(compact(journal_schema)),
      "body_schema_set_sha256" => sha256(compact(body_schema_set))
    }
    predigest_catalog = {
      "provenance" => provenance,
      "entries" => ordered_entries,
      "index_rows" => index_rows,
      "predecessor_edges" => edges,
      "merkle_commitment" => merkle,
      "entry_count_uint" => ordered_entries.length,
      "edge_count_uint" => edges.length
    }
    catalog = predigest_catalog.merge(
      "catalog_payload_sha256" => sha256(compact(predigest_catalog))
    )
    {
      "control_field" => PRODUCTION_JOURNAL_CONFORMANCE_CATALOG_FIELD,
      "catalog" => catalog,
      "catalog_source_fixture" => fixture(
        "PRODUCTION_JOURNAL_CONFORMANCE_CATALOG_V12",
        "ProductionJournalConformanceFixtureCatalogV12",
        catalog
      ),
      "schema_definitions" => catalog_schema_definitions,
      "order_definitions" => catalog_order_definitions
    }
  end

  def synthesize_minimum_chain!(
    control:,
    body_builders:,
    recursive_body_validator:,
    postpublication_observations:,
    fixture_id_prefix:
  )
    raise AssessmentError.new(
      "RETIRED_PASS_FAIL_HISTORICAL_AUTHORITY_ROUTE",
      "replacement" => "build_catalog!",
      "required_provenance" => "SYNTHETIC_CONFORMANCE_NONAUTHORITY"
    )

    frames = {}

    r00_leaf, r00_status, r00_variant, r00_kind = MINIMUM_CHAIN_PLAN.fetch(0)
    r00_observation = physical_observation!(postpublication_observations, r00_leaf)
    validate_physical_path!(control, r00_leaf, r00_observation)
    r00_body = body_bytes_from_builder!(body_builders, r00_leaf, frames)
    frames[r00_leaf] = build_nonoperation_frame!(
      :control => control,
      :leaf => r00_leaf,
      :status => r00_status,
      :variant => r00_variant,
      :record_kind => r00_kind,
      :canonical_body_bytes => r00_body,
      :recursive_body_validator => recursive_body_validator,
      :predecessor_frame_reference => nil,
      :path => r00_observation.fetch("path"),
      :vnode => r00_observation.fetch("vnode"),
      :artifact_slot => r00_observation.fetch("artifact_slot"),
      :content_admission => r00_observation.fetch("content_admission")
    )

    t01_leaf, _t01_status, = MINIMUM_CHAIN_PLAN.fetch(1)
    t01_observation = physical_observation!(postpublication_observations, t01_leaf)
    validate_physical_path!(control, t01_leaf, t01_observation)
    t01_body = body_bytes_from_builder!(body_builders, t01_leaf, frames)
    frames[t01_leaf] = FRAME.build_controlled_fail!(
      :control => control,
      :leaf => t01_leaf,
      :canonical_body_bytes => t01_body,
      :recursive_body_validator => recursive_body_validator,
      :predecessor_frame_reference => frames.fetch(r00_leaf).fetch("frame_reference"),
      :path => t01_observation.fetch("path"),
      :vnode => t01_observation.fetch("vnode"),
      :artifact_slot => t01_observation.fetch("artifact_slot"),
      :content_admission => t01_observation.fetch("content_admission")
    )

    terminal_leaf, terminal_status, terminal_variant, terminal_kind =
      MINIMUM_CHAIN_PLAN.fetch(2)
    terminal_observation = physical_observation!(
      postpublication_observations, terminal_leaf
    )
    validate_physical_path!(control, terminal_leaf, terminal_observation)
    terminal_body = body_bytes_from_builder!(body_builders, terminal_leaf, frames)
    frames[terminal_leaf] = build_nonoperation_frame!(
      :control => control,
      :leaf => terminal_leaf,
      :status => terminal_status,
      :variant => terminal_variant,
      :record_kind => terminal_kind,
      :canonical_body_bytes => terminal_body,
      :recursive_body_validator => recursive_body_validator,
      :predecessor_frame_reference => frames.fetch(t01_leaf).fetch("frame_reference"),
      :path => terminal_observation.fetch("path"),
      :vnode => terminal_observation.fetch("vnode"),
      :artifact_slot => terminal_observation.fetch("artifact_slot"),
      :content_admission => terminal_observation.fetch("content_admission")
    )

    fixtures = frames.flat_map do |leaf, frame|
      component_fixtures(fixture_id_prefix, leaf, frame)
    end
    {
      "chain_plan_exact" => deep_clone(MINIMUM_CHAIN_PLAN),
      "frames" => frames,
      "source_fixtures" => fixtures,
      "source_fixture_count_uint" => fixtures.length,
      "source_fixture_catalog_sha256" => sha256(compact(fixtures)),
      "historical_receipt_interpretation_bool" => false
    }
  end
end
