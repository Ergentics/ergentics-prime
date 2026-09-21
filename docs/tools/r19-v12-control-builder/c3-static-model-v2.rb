# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require_relative "production-operation-frame"
require_relative "production-journal-conformance-fixtures"
require_relative "production-journal-incomplete-body-builder"

# Scratch-only, non-authority journal algebra for C3 and the legacy projection
# conformance routes.  This module intentionally does not construct a
# RecordObservationV12, FrameReferenceV12, RecordFrameBytesV12, or
# RecordFrameBytesSetV12.  Its frames use the exact eight-key production
# envelope solely as content-addressed STATIC_MODEL data.  The body retains the
# exact production body key order, constants, and operation tuple, but every
# otherwise-required value is an explicit typed hole.  Consequently the model
# can prove envelope/payload/predecessor/Merkle and finite prefix/hole algebra;
# it cannot prove recursive record validity or any historical operation.
module V12C3StaticModelCarrierV2
  FRAME = V12ProductionOperationFrame
  JOURNAL = V12ProductionJournalConformanceFixtures
  INCOMPLETE = V12ProductionJournalIncompleteBodyBuilder

  CATALOG_FIELD = "static_model_journal_algebra_catalog_v12".freeze
  SCHEMA_FIELD = "static_model_journal_algebra_schema_definitions_v12".freeze
  ORDER_FIELD = "static_model_journal_algebra_order_definitions_v12".freeze
  ROUTE_IDS = %w[
    C3_OPERATION_PREFIX_ALGEBRA
    PROJECT_JOURNAL_ENVELOPE_INPUT
    PROJECT_JOURNAL_CHAIN_INPUT
    PROJECT_OUTER_CHAIN_INPUT
  ].freeze
  ABSTRACT_STATES = %w[VALID_FINAL ABSENT INVALID UNAVAILABLE].freeze
  OPERATION_PLAN = JOURNAL::CATALOG_PLAN.drop(1).freeze
  MODEL_BODY_HOLE_REASON = "MISSING_REQUIRED_START".freeze
  OPERATIONAL_ABSTAIN_REASON =
    "MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME".freeze

  class ModelError < StandardError
    attr_reader :code, :details

    def initialize(code, details = {})
      @code = code
      @details = details
      super("#{code}:#{JSON.generate(details)}")
    end
  end

  class DuplicateRejectingHash < Hash
    def []=(key, value)
      raise ModelError.new("DUPLICATE_JSON_KEY", "key" => key) if key?(key)

      super
    end
  end

  module_function

  def compact(value)
    JSON.generate(value)
  end

  def sha256(bytes)
    Digest::SHA256.hexdigest(bytes.b)
  end

  def deep_clone(value)
    Marshal.load(Marshal.dump(value))
  end

  def h64?(value)
    value.is_a?(String) && value.match?(/\A[0-9a-f]{64}\z/)
  end

  def raw_bytes(bytes)
    ascii = if bytes.bytes.all? { |byte| byte.between?(0x20, 0x7e) }
      bytes.dup.force_encoding(Encoding::US_ASCII)
    end
    {
      "base64" => Base64.strict_encode64(bytes),
      "bytes_uint" => bytes.bytesize,
      "sha256" => sha256(bytes),
      "ascii_display_or_null" => ascii
    }
  end

  def decode_raw_bytes!(value)
    bytes = Base64.strict_decode64(value.fetch("base64"))
    unless bytes.bytesize == value.fetch("bytes_uint") &&
           sha256(bytes) == value.fetch("sha256")
      raise ModelError.new("RAW_BYTES_CONTENT_JOIN_FAILED")
    end
    expected_ascii = if bytes.bytes.all? { |byte| byte.between?(0x20, 0x7e) }
      bytes.dup.force_encoding(Encoding::US_ASCII)
    end
    unless value.fetch("ascii_display_or_null") == expected_ascii
      raise ModelError.new("RAW_BYTES_ASCII_PROJECTION_MISMATCH")
    end
    bytes
  rescue ArgumentError, KeyError => error
    raise ModelError.new("RAW_BYTES_DECODE_FAILED", "error_class" => error.class.name)
  end

  def exact_journal(control)
    FRAME.exact_journal_schema(control)
  end

  def exact_body_schema(control, variant)
    schema = control.dig(
      "exact_record_schema_v12", "records", "journal", "body_schemas", variant
    )
    unless schema.is_a?(Hash) && schema.fetch("keys", nil).is_a?(Array) &&
           schema.fetch("field_types_exact", nil).is_a?(Hash)
      raise ModelError.new("MISSING_EXACT_BODY_SCHEMA", "variant" => variant)
    end
    schema
  end

  def static_hole(type_descriptor)
    {
      "expected_type_descriptor_exact" => type_descriptor,
      "reason_enum" => MODEL_BODY_HOLE_REASON,
      "operational_value_present_bool" => false
    }
  end

  def model_body(control, plan_row)
    _fixture_id, leaf, _status, variant, _record_kind, = plan_row
    schema = exact_body_schema(control, variant)
    constants = schema.fetch("constants_exact", {})
    tuple = exact_journal(control).dig("operation_body_tuple_by_leaf_exact", leaf)
    body = schema.fetch("keys").each_with_object({}) do |key, result|
      result[key] = if constants.key?(key)
        deep_clone(constants.fetch(key))
      elsif variant == "OPERATION" && key == "label"
        tuple.fetch(0)
      elsif variant == "OPERATION" && key == "one_based_ordinal"
        tuple.fetch(1)
      elsif variant == "OPERATION" && key == "root_label"
        tuple.fetch(2)
      else
        static_hole(schema.fetch("field_types_exact").fetch(key))
      end
    end
    unless body.keys == schema.fetch("keys")
      raise ModelError.new("STATIC_MODEL_BODY_KEY_ORDER_MISMATCH", "leaf" => leaf)
    end
    body
  end

  def body_model_validation(control, plan_row, body)
    _fixture_id, leaf, _status, variant, _record_kind, = plan_row
    schema = exact_body_schema(control, variant)
    unless body.is_a?(Hash) && body.keys == schema.fetch("keys")
      raise ModelError.new("STATIC_MODEL_BODY_KEY_ORDER_MISMATCH", "leaf" => leaf)
    end
    schema.fetch("constants_exact", {}).each do |key, value|
      unless body.fetch(key) == value
        raise ModelError.new("STATIC_MODEL_BODY_CONSTANT_MISMATCH", "leaf" => leaf, "key" => key)
      end
    end
    if variant == "OPERATION"
      tuple = exact_journal(control).dig("operation_body_tuple_by_leaf_exact", leaf)
      unless [body.fetch("label"), body.fetch("one_based_ordinal"), body.fetch("root_label")] == tuple
        raise ModelError.new("STATIC_MODEL_OPERATION_TUPLE_MISMATCH", "leaf" => leaf)
      end
    end
    exempt = schema.fetch("constants_exact", {}).keys
    exempt += %w[label one_based_ordinal root_label] if variant == "OPERATION"
    hole_keys = schema.fetch("keys") - exempt
    unless hole_keys.all? do |key|
      body.fetch(key) == static_hole(schema.fetch("field_types_exact").fetch(key))
    end
      raise ModelError.new("STATIC_MODEL_TYPED_HOLE_MISMATCH", "leaf" => leaf)
    end
    {
      "body_key_order_valid_bool" => true,
      "body_constants_valid_bool" => true,
      "operation_tuple_valid_bool_or_null" => variant == "OPERATION" ? true : nil,
      "typed_hole_count_uint" => hole_keys.length,
      "recursive_operational_validation_state_enum" =>
        "ABSTAIN_MISSING_REQUIRED_START"
    }
  end

  def model_frame_identity(envelope, complete_bytes)
    {
      "schema" => envelope.fetch("schema"),
      "status" => envelope.fetch("status"),
      "leaf" => envelope.fetch("leaf"),
      "ordinal_zero_based" => envelope.fetch("ordinal_zero_based"),
      "terminal_bool" => envelope.fetch("terminal_bool"),
      "previous_complete_frame_with_lf_sha256_or_null" =>
        envelope.fetch("previous_complete_frame_with_lf_sha256_or_null"),
      "bytes_uint" => complete_bytes.bytesize,
      "lf_count_uint" => 1,
      "complete_frame_sha256" => sha256(complete_bytes),
      "payload_sha256" => envelope.fetch("payload_sha256"),
      "body_static_model_sha256" => sha256(compact(envelope.fetch("body")))
    }
  end

  def parse_model_frame!(control, raw_value, expected_plan_row = nil)
    bytes = decode_raw_bytes!(raw_value)
    unless bytes.end_with?("\n") && bytes.count("\n") == 1
      raise ModelError.new("STATIC_MODEL_FRAME_LF_MISMATCH")
    end
    json = bytes.delete_suffix("\n")
    envelope = JSON.parse(
      json,
      :object_class => DuplicateRejectingHash,
      :array_class => Array,
      :create_additions => false
    )
    unless envelope.keys == FRAME::ENVELOPE_KEYS
      raise ModelError.new(
        "STATIC_MODEL_ENVELOPE_KEYS_MISMATCH",
        "actual_keys" => envelope.keys,
        "expected_keys" => FRAME::ENVELOPE_KEYS
      )
    end
    unless compact(envelope) == json
      raise ModelError.new("STATIC_MODEL_FRAME_NOT_CANONICAL")
    end
    predigest = {}
    FRAME::ENVELOPE_KEYS.first(7).each do |key|
      predigest[key] = envelope.fetch(key)
    end
    unless predigest.keys == FRAME::ENVELOPE_KEYS.first(7) &&
           envelope.fetch("payload_sha256") == sha256(compact(predigest))
      raise ModelError.new("STATIC_MODEL_PAYLOAD_DIGEST_MISMATCH")
    end
    journal = exact_journal(control)
    unless envelope.fetch("schema") == FRAME::JOURNAL_FRAME_SCHEMA
      raise ModelError.new("STATIC_MODEL_JOURNAL_SCHEMA_MISMATCH")
    end
    leaf = envelope.fetch("leaf")
    unless envelope.fetch("ordinal_zero_based") == journal.dig("ordinal_by_leaf_exact", leaf) &&
           envelope.fetch("terminal_bool") == journal.dig("terminal_bool_by_leaf_exact", leaf) &&
           Array(journal.dig("status_by_leaf", leaf)).include?(envelope.fetch("status"))
      raise ModelError.new("STATIC_MODEL_LEAF_TUPLE_OR_STATUS_MISMATCH", "leaf" => leaf)
    end
    if expected_plan_row
      fixture_id, expected_leaf, status, variant, _record_kind, = expected_plan_row
      unless [leaf, envelope.fetch("status")] == [expected_leaf, status]
        raise ModelError.new("STATIC_MODEL_PLAN_FRAME_MISMATCH", "fixture_id" => fixture_id)
      end
      body_model_validation(control, expected_plan_row, envelope.fetch("body"))
      unless journal.dig("body_variant_by_leaf_exact", leaf) == variant
        raise ModelError.new("STATIC_MODEL_BODY_VARIANT_MISMATCH", "fixture_id" => fixture_id)
      end
    end
    [envelope, bytes, model_frame_identity(envelope, bytes)]
  rescue JSON::ParserError, KeyError, TypeError => error
    raise error if error.is_a?(ModelError)

    raise ModelError.new("STATIC_MODEL_FRAME_PARSE_FAILED", "error_class" => error.class.name)
  end

  def build_entry(control, plan_row, predecessor_entry)
    fixture_id, leaf, status, _variant, _record_kind, predecessor_id = plan_row
    if predecessor_id.nil? != predecessor_entry.nil?
      raise ModelError.new("STATIC_MODEL_PREDECESSOR_PRESENCE_MISMATCH", "fixture_id" => fixture_id)
    end
    if predecessor_entry && predecessor_entry.fetch("fixture_id") != predecessor_id
      raise ModelError.new("STATIC_MODEL_PREDECESSOR_ID_MISMATCH", "fixture_id" => fixture_id)
    end
    journal = exact_journal(control)
    body = model_body(control, plan_row)
    predigest = {
      "schema" => FRAME::JOURNAL_FRAME_SCHEMA,
      "status" => status,
      "leaf" => leaf,
      "ordinal_zero_based" => journal.dig("ordinal_by_leaf_exact", leaf),
      "terminal_bool" => journal.dig("terminal_bool_by_leaf_exact", leaf),
      "previous_complete_frame_with_lf_sha256_or_null" => predecessor_entry &&
        predecessor_entry.dig("frame_identity", "complete_frame_sha256"),
      "body" => body
    }
    complete = compact(predigest.merge("payload_sha256" => sha256(compact(predigest)))) + "\n"
    raw = raw_bytes(complete)
    envelope, reparsed, identity = parse_model_frame!(control, raw, plan_row)
    unless reparsed == complete
      raise ModelError.new("STATIC_MODEL_BUILD_PARSE_ROUND_TRIP_MISMATCH", "fixture_id" => fixture_id)
    end
    {
      "fixture_id" => fixture_id,
      "leaf" => leaf,
      "status" => status,
      "body_schema_json_pointer" =>
        JOURNAL::BODY_SCHEMA_POINTER_BY_VARIANT.fetch(plan_row.fetch(3)),
      "predecessor_fixture_id_or_null" => predecessor_id,
      "complete_frame_raw_bytes" => raw,
      "frame_identity" => identity,
      "body_model_validation" => body_model_validation(control, plan_row, envelope.fetch("body"))
    }
  end

  def merkle_commitment(entries)
    leaf_hashes = entries.map do |entry|
      bytes = decode_raw_bytes!(entry.fetch("complete_frame_raw_bytes"))
      sha256(JOURNAL::MERKLE_LEAF_DOMAIN + bytes.b)
    end
    raise ModelError.new("STATIC_MODEL_MERKLE_EMPTY") if leaf_hashes.empty?

    level = leaf_hashes.dup
    until level.length == 1
      level << level.last if level.length.odd?
      level = level.each_slice(2).map do |left, right|
        sha256(
          JOURNAL::MERKLE_NODE_DOMAIN + [left].pack("H*") + [right].pack("H*")
        )
      end
    end
    {
      "algorithm_id" => JOURNAL::MERKLE_ALGORITHM_ID,
      "leaf_domain_base64" => Base64.strict_encode64(JOURNAL::MERKLE_LEAF_DOMAIN),
      "node_domain_base64" => Base64.strict_encode64(JOURNAL::MERKLE_NODE_DOMAIN),
      "odd_rule_enum" => "DUPLICATE_LAST_AT_EACH_ODD_LEVEL",
      "ordered_leaf_count_uint" => leaf_hashes.length,
      "ordered_leaf_hashes" => leaf_hashes,
      "root_sha256" => level.fetch(0)
    }
  end

  def operational_replay_assessment(control)
    missing = INCOMPLETE.closure_assessment(control)
    unless missing.fetch("closure_state_enum") == "MISSING_TYPED_DEPENDENCY" &&
           missing.dig("missing_typed_dependency", "dependency_id") == OPERATIONAL_ABSTAIN_REASON &&
           missing.dig("missing_typed_dependency", "available_bool") == false
      raise ModelError.new("STATIC_MODEL_OPERATIONAL_ABSTAIN_PROOF_MISMATCH")
    end
    {
      "state_enum" => "ABSTAIN_MISSING_REQUIRED_START",
      "reason_enum" => OPERATIONAL_ABSTAIN_REASON,
      "required_schema_json_pointer" =>
        missing.dig("missing_typed_dependency", "schema_json_pointer"),
      "required_source_available_bool" => false,
      "static_model_envelope_replay_bool" => true,
      "record_frame_bytes_rows_emitted_uint" => 0,
      "record_observations_emitted_uint" => 0,
      "operational_frame_reference_emitted_uint" => 0,
      "operation_prefix_projection_closed_bool" => false,
      "authority_closed_bool" => false,
      "historical_operation_asserted_bool" => false,
      "operational_evidence_asserted_bool" => false
    }
  end

  def provenance(control)
    journal = exact_journal(control)
    body_schemas = {
      "R00" => exact_body_schema(control, "R00"),
      "OPERATION" => exact_body_schema(control, "OPERATION")
    }
    {
      "dataset_kind_enum" => "STATIC_MODEL",
      "authority_bool" => false,
      "historical_operation_bool" => false,
      "operational_evidence_bool" => false,
      "historical_receipt_interpretation_bool" => false,
      "operational_record_frame_bytes_claim_bool" => false,
      "body_recursive_validation_state_enum" =>
        "ABSTAIN_MISSING_REQUIRED_START",
      "construction_plan_sha256" => sha256(compact(JOURNAL::CATALOG_PLAN)),
      "journal_schema_sha256" => sha256(compact(journal)),
      "body_schema_set_sha256" => sha256(compact(body_schemas))
    }
  end

  def build_catalog!(control)
    entries = []
    JOURNAL::CATALOG_PLAN.each do |plan_row|
      predecessor_id = plan_row.fetch(5)
      predecessor = predecessor_id && entries.find do |entry|
        entry.fetch("fixture_id") == predecessor_id
      end
      entries << build_entry(control, plan_row, predecessor)
    end
    index_rows = entries.each_with_index.map do |entry, ordinal|
      [
        ordinal,
        entry.fetch("fixture_id"),
        sha256(compact(entry)),
        entry.dig("frame_identity", "complete_frame_sha256"),
        entry.dig("frame_identity", "payload_sha256")
      ]
    end
    edges = entries.drop(1).each_with_index.map do |successor, index|
      predecessor = entries.fetch(index)
      predecessor_hash = predecessor.dig("frame_identity", "complete_frame_sha256")
      embedded = successor.dig(
        "frame_identity", "previous_complete_frame_with_lf_sha256_or_null"
      )
      unless predecessor_hash == embedded
        raise ModelError.new("STATIC_MODEL_PREDECESSOR_EDGE_JOIN_FAILED")
      end
      {
        "edge_id" => "STATIC_MODEL_#{predecessor.fetch("fixture_id")}_TO_#{successor.fetch("fixture_id")}",
        "predecessor_fixture_id" => predecessor.fetch("fixture_id"),
        "successor_fixture_id" => successor.fetch("fixture_id"),
        "predecessor_complete_frame_sha256" => predecessor_hash,
        "successor_embedded_predecessor_sha256" => embedded,
        "joined_bool" => true
      }
    end
    predigest = {
      "provenance" => provenance(control),
      "entries" => entries,
      "index_rows" => index_rows,
      "predecessor_edges" => edges,
      "merkle_commitment" => merkle_commitment(entries),
      "operational_replay_assessment" => operational_replay_assessment(control),
      "entry_count_uint" => entries.length,
      "edge_count_uint" => edges.length
    }
    catalog = predigest.merge("catalog_payload_sha256" => sha256(compact(predigest)))
    validate_catalog!(control, catalog)
    catalog
  end

  def validate_provenance!(value)
    constants = {
      "dataset_kind_enum" => "STATIC_MODEL",
      "authority_bool" => false,
      "historical_operation_bool" => false,
      "operational_evidence_bool" => false,
      "historical_receipt_interpretation_bool" => false,
      "operational_record_frame_bytes_claim_bool" => false,
      "body_recursive_validation_state_enum" =>
        "ABSTAIN_MISSING_REQUIRED_START"
    }
    constants.each do |key, expected|
      unless value.fetch(key) == expected
        raise ModelError.new("STATIC_MODEL_PROVENANCE_MISMATCH", "key" => key)
      end
    end
    %w[construction_plan_sha256 journal_schema_sha256 body_schema_set_sha256].each do |key|
      raise ModelError.new("STATIC_MODEL_PROVENANCE_DIGEST_INVALID", "key" => key) unless h64?(value.fetch(key))
    end
    true
  end

  def validate_catalog!(control, catalog)
    unless catalog.fetch("entry_count_uint") == 6 && catalog.fetch("edge_count_uint") == 5
      raise ModelError.new("STATIC_MODEL_CATALOG_COUNT_MISMATCH")
    end
    predigest = catalog.reject { |key, _value| key == "catalog_payload_sha256" }
    unless catalog.fetch("catalog_payload_sha256") == sha256(compact(predigest))
      raise ModelError.new("STATIC_MODEL_CATALOG_PAYLOAD_MISMATCH")
    end
    validate_provenance!(catalog.fetch("provenance"))
    entries = catalog.fetch("entries")
    planned_ids = JOURNAL::CATALOG_PLAN.map(&:first)
    unless entries.map { |entry| entry.fetch("fixture_id") } == planned_ids
      raise ModelError.new("STATIC_MODEL_ENTRY_PLAN_ORDER_MISMATCH")
    end
    entries.each_with_index do |entry, ordinal|
      plan = JOURNAL::CATALOG_PLAN.fetch(ordinal)
      envelope, bytes, identity = parse_model_frame!(
        control, entry.fetch("complete_frame_raw_bytes"), plan
      )
      unless entry.fetch("frame_identity") == identity &&
             entry.fetch("leaf") == envelope.fetch("leaf") &&
             entry.fetch("status") == envelope.fetch("status") &&
             entry.fetch("body_model_validation") ==
               body_model_validation(control, plan, envelope.fetch("body"))
        raise ModelError.new("STATIC_MODEL_ENTRY_JOIN_MISMATCH", "ordinal" => ordinal)
      end
      predecessor_hash = ordinal.zero? ? nil : entries.fetch(ordinal - 1).dig(
        "frame_identity", "complete_frame_sha256"
      )
      unless envelope.fetch("previous_complete_frame_with_lf_sha256_or_null") == predecessor_hash &&
             bytes.bytesize == identity.fetch("bytes_uint")
        raise ModelError.new("STATIC_MODEL_ENTRY_PREDECESSOR_MISMATCH", "ordinal" => ordinal)
      end
    end
    expected_index = entries.each_with_index.map do |entry, ordinal|
      [
        ordinal, entry.fetch("fixture_id"), sha256(compact(entry)),
        entry.dig("frame_identity", "complete_frame_sha256"),
        entry.dig("frame_identity", "payload_sha256")
      ]
    end
    unless catalog.fetch("index_rows") == expected_index
      raise ModelError.new("STATIC_MODEL_INDEX_BIDIRECTIONAL_JOIN_FAILED")
    end
    expected_edges = entries.drop(1).each_with_index.map do |successor, index|
      predecessor = entries.fetch(index)
      digest = predecessor.dig("frame_identity", "complete_frame_sha256")
      {
        "edge_id" => "STATIC_MODEL_#{predecessor.fetch("fixture_id")}_TO_#{successor.fetch("fixture_id")}",
        "predecessor_fixture_id" => predecessor.fetch("fixture_id"),
        "successor_fixture_id" => successor.fetch("fixture_id"),
        "predecessor_complete_frame_sha256" => digest,
        "successor_embedded_predecessor_sha256" => digest,
        "joined_bool" => true
      }
    end
    unless catalog.fetch("predecessor_edges") == expected_edges
      raise ModelError.new("STATIC_MODEL_EDGE_BIDIRECTIONAL_JOIN_FAILED")
    end
    unless catalog.fetch("merkle_commitment") == merkle_commitment(entries)
      raise ModelError.new("STATIC_MODEL_MERKLE_ROUND_TRIP_MISMATCH")
    end
    assessment = catalog.fetch("operational_replay_assessment")
    unless assessment == operational_replay_assessment(control)
      raise ModelError.new("STATIC_MODEL_OPERATIONAL_ASSESSMENT_MISMATCH")
    end
    forbidden = %w[
      record_observation record_frame_bytes frame_reference vnode path
      content_admission artifact_slot
    ]
    walk = lambda do |value|
      case value
      when Hash
        overlap = value.keys & forbidden
        unless overlap.empty?
          raise ModelError.new("STATIC_MODEL_OPERATIONAL_FIELD_LEAK", "keys" => overlap)
        end
        value.each_value { |child| walk.call(child) }
      when Array
        value.each { |child| walk.call(child) }
      end
    end
    walk.call(catalog.fetch("entries"))
    true
  rescue KeyError, TypeError => error
    raise error if error.is_a?(ModelError)

    raise ModelError.new("STATIC_MODEL_CATALOG_MALFORMED", "error_class" => error.class.name)
  end

  def entry_by_fixture_id!(catalog, fixture_id)
    entry = catalog.fetch("entries").find do |candidate|
      candidate.fetch("fixture_id") == fixture_id
    end
    raise ModelError.new("STATIC_MODEL_ENTRY_NOT_FOUND", "fixture_id" => fixture_id) unless entry

    entry
  end

  def invalid_bytes_from_entry(entry)
    bytes = decode_raw_bytes!(entry.fetch("complete_frame_raw_bytes"))
    envelope = JSON.parse(bytes.delete_suffix("\n"))
    envelope["payload_sha256"] = "0" * 64
    raw_bytes(compact(envelope) + "\n")
  end

  def c3_source!(control:, catalog:, states:)
    validate_catalog!(control, catalog)
    unless states.is_a?(Array) && states.length == 5 &&
           states.all? { |state| ABSTRACT_STATES.include?(state) }
      raise ModelError.new("STATIC_MODEL_C3_STATE_VECTOR_INVALID", "states" => states)
    end
    rows = OPERATION_PLAN.each_with_index.map do |plan, index|
      fixture_id, leaf, = plan
      entry = entry_by_fixture_id!(catalog, fixture_id)
      state = states.fetch(index)
      case state
      when "VALID_FINAL"
        {
          "ordinal_uint" => index,
          "leaf" => leaf,
          "abstract_state_enum" => state,
          "catalog_fixture_id_or_null" => fixture_id,
          "catalog_entry_canonical_sha256_or_null" => sha256(compact(entry)),
          "observed_static_model_bytes_or_null" =>
            deep_clone(entry.fetch("complete_frame_raw_bytes")),
          "model_replay_state_enum" => "VALID_EXACT_ENVELOPE",
          "model_error_code_or_null" => nil
        }
      when "ABSENT"
        {
          "ordinal_uint" => index, "leaf" => leaf,
          "abstract_state_enum" => state,
          "catalog_fixture_id_or_null" => nil,
          "catalog_entry_canonical_sha256_or_null" => nil,
          "observed_static_model_bytes_or_null" => nil,
          "model_replay_state_enum" => "ABSENT",
          "model_error_code_or_null" => nil
        }
      when "INVALID"
        {
          "ordinal_uint" => index, "leaf" => leaf,
          "abstract_state_enum" => state,
          "catalog_fixture_id_or_null" => fixture_id,
          "catalog_entry_canonical_sha256_or_null" => sha256(compact(entry)),
          "observed_static_model_bytes_or_null" => invalid_bytes_from_entry(entry),
          "model_replay_state_enum" => "INVALID_PAYLOAD_DIGEST",
          "model_error_code_or_null" => "STATIC_MODEL_PAYLOAD_DIGEST_MISMATCH"
        }
      when "UNAVAILABLE"
        {
          "ordinal_uint" => index, "leaf" => leaf,
          "abstract_state_enum" => state,
          "catalog_fixture_id_or_null" => nil,
          "catalog_entry_canonical_sha256_or_null" => nil,
          "observed_static_model_bytes_or_null" => nil,
          "model_replay_state_enum" => "UNAVAILABLE",
          "model_error_code_or_null" => "STATIC_MODEL_SOURCE_UNAVAILABLE"
        }
      end
    end
    {
      "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA",
      "catalog_payload_sha256" => catalog.fetch("catalog_payload_sha256"),
      "provenance" => deep_clone(catalog.fetch("provenance")),
      "rows" => rows,
      "operational_replay_assessment" =>
        deep_clone(catalog.fetch("operational_replay_assessment"))
    }
  end

  def validate_invalid_model_row!(control, row)
    begin
      parse_model_frame!(control, row.fetch("observed_static_model_bytes_or_null"))
    rescue ModelError => error
      unless error.code == row.fetch("model_error_code_or_null")
        raise ModelError.new(
          "STATIC_MODEL_INVALID_ROW_WRONG_REJECTION",
          "expected" => row.fetch("model_error_code_or_null"),
          "actual" => error.code
        )
      end
      return true
    end
    raise ModelError.new("STATIC_MODEL_INVALID_ROW_ACCEPTED")
  end

  def replay_c3_algebra!(control:, catalog:, source:, scope:)
    validate_catalog!(control, catalog)
    unless %w[TERMINAL PREFIX OUTER].include?(scope)
      raise ModelError.new("STATIC_MODEL_C3_SCOPE_INVALID", "scope" => scope)
    end
    unless source.fetch("source_domain_enum") == "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA" &&
           source.fetch("catalog_payload_sha256") == catalog.fetch("catalog_payload_sha256") &&
           source.fetch("provenance") == catalog.fetch("provenance") &&
           source.fetch("operational_replay_assessment") ==
             catalog.fetch("operational_replay_assessment")
      raise ModelError.new("STATIC_MODEL_C3_SOURCE_CATALOG_JOIN_FAILED")
    end
    rows = source.fetch("rows")
    unless rows.length == 5
      raise ModelError.new("STATIC_MODEL_C3_SOURCE_ROW_COUNT_MISMATCH")
    end
    states = rows.each_with_index.map do |row, index|
      plan = OPERATION_PLAN.fetch(index)
      fixture_id, leaf, = plan
      unless row.fetch("ordinal_uint") == index && row.fetch("leaf") == leaf
        raise ModelError.new("STATIC_MODEL_C3_ROW_ORDER_MISMATCH", "index" => index)
      end
      state = row.fetch("abstract_state_enum")
      case state
      when "VALID_FINAL"
        entry = entry_by_fixture_id!(catalog, fixture_id)
        unless row.fetch("catalog_fixture_id_or_null") == fixture_id &&
               row.fetch("catalog_entry_canonical_sha256_or_null") == sha256(compact(entry)) &&
               row.fetch("observed_static_model_bytes_or_null") == entry.fetch("complete_frame_raw_bytes") &&
               row.fetch("model_replay_state_enum") == "VALID_EXACT_ENVELOPE" &&
               row.fetch("model_error_code_or_null").nil?
          raise ModelError.new("STATIC_MODEL_C3_VALID_ROW_JOIN_FAILED", "index" => index)
        end
        parse_model_frame!(control, row.fetch("observed_static_model_bytes_or_null"), plan)
      when "ABSENT"
        unless row.fetch("catalog_fixture_id_or_null").nil? &&
               row.fetch("catalog_entry_canonical_sha256_or_null").nil? &&
               row.fetch("observed_static_model_bytes_or_null").nil? &&
               row.fetch("model_replay_state_enum") == "ABSENT" &&
               row.fetch("model_error_code_or_null").nil?
          raise ModelError.new("STATIC_MODEL_C3_ABSENT_ROW_SHAPE_INVALID", "index" => index)
        end
      when "INVALID"
        validate_invalid_model_row!(control, row)
      when "UNAVAILABLE"
        unless row.fetch("catalog_fixture_id_or_null").nil? &&
               row.fetch("catalog_entry_canonical_sha256_or_null").nil? &&
               row.fetch("observed_static_model_bytes_or_null").nil? &&
               row.fetch("model_replay_state_enum") == "UNAVAILABLE" &&
               row.fetch("model_error_code_or_null") == "STATIC_MODEL_SOURCE_UNAVAILABLE"
          raise ModelError.new("STATIC_MODEL_C3_UNAVAILABLE_ROW_SHAPE_INVALID", "index" => index)
        end
      else
        raise ModelError.new("STATIC_MODEL_C3_ABSTRACT_STATE_INVALID", "state" => state)
      end
      state
    end
    prefix_count = states.take_while { |state| state == "VALID_FINAL" }.length
    clean_suffix = states == (
      ["VALID_FINAL"] * prefix_count + ["ABSENT"] * (5 - prefix_count)
    )
    hole = states.each_with_index.any? do |state, index|
      state == "VALID_FINAL" && index > prefix_count
    end
    selected_indices = if scope == "OUTER"
      states.each_index.select { |index| states.fetch(index) == "VALID_FINAL" }
    else
      (0...prefix_count).to_a
    end
    identities = selected_indices.map do |index|
      fixture_id = OPERATION_PLAN.fetch(index).fetch(0)
      deep_clone(entry_by_fixture_id!(catalog, fixture_id).fetch("frame_identity"))
    end
    missing = states.each_index.select do |index|
      states.fetch(index) != "VALID_FINAL"
    end.map { |index| OPERATION_PLAN.fetch(index).fetch(1) }
    first_unentered = if prefix_count == 5
      {
        "present_bool" => false,
        "operation_label_or_null" => nil,
        "abstract_reason_enum_or_null" => nil
      }
    else
      labels = exact_journal(control).fetch("operation_body_tuple_by_leaf_exact")
      next_leaf = OPERATION_PLAN.fetch(prefix_count).fetch(1)
      {
        "present_bool" => true,
        "operation_label_or_null" => labels.fetch(next_leaf).fetch(0),
        "abstract_reason_enum_or_null" => if clean_suffix
          prefix_count.zero? ? "C3_R00_CUT" : "C3_CLEAN_ABSENT_SUFFIX"
        else
          "C3_EVIDENCE_DISCONTINUITY"
        end
      }
    end
    {
      "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA",
      "abstract_states" => states,
      "classification_complete_bool" => true,
      "operation_integrity_bool" => clean_suffix,
      "operation_hole_detected_bool" => hole,
      "valid_prefix_count_uint" => prefix_count,
      "valid_static_model_frame_identities" => identities,
      "missing_expected_frames" => missing,
      "first_unentered_abstract" => first_unentered,
      "operational_projection_state_enum" => "ABSTAIN_MISSING_REQUIRED_START",
      "operation_prefix_projection_v12_or_null" => nil,
      "record_frame_bytes_set_v12_or_null" => nil
    }
  end

  def shared_route_source!(control:, catalog:, route_id:)
    validate_catalog!(control, catalog)
    unless ROUTE_IDS.include?(route_id)
      raise ModelError.new("STATIC_MODEL_ROUTE_ID_INVALID", "route_id" => route_id)
    end
    entries = catalog.fetch("entries")
    selected = case route_id
    when "C3_OPERATION_PREFIX_ALGEBRA"
      entries.drop(1)
    when "PROJECT_JOURNAL_ENVELOPE_INPUT"
      [entries.fetch(0)]
    when "PROJECT_JOURNAL_CHAIN_INPUT", "PROJECT_OUTER_CHAIN_INPUT"
      entries
    end
    symbols = if route_id == "PROJECT_OUTER_CHAIN_INPUT"
      (["INCOMPLETE"] * 6) + ["ABSENT_TERMINAL"]
    elsif route_id == "PROJECT_JOURNAL_CHAIN_INPUT"
      ["INCOMPLETE"] * 6
    else
      nil
    end
    {
      "route_id" => route_id,
      "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA",
      "catalog_payload_sha256" => catalog.fetch("catalog_payload_sha256"),
      "catalog_merkle_root_sha256" =>
        catalog.dig("merkle_commitment", "root_sha256"),
      "selected_fixture_ids" => selected.map { |entry| entry.fetch("fixture_id") },
      "selected_complete_frame_sha256s" => selected.map do |entry|
        entry.dig("frame_identity", "complete_frame_sha256")
      end,
      "static_model_symbols_or_null" => symbols,
      "operational_replay_assessment" =>
        deep_clone(catalog.fetch("operational_replay_assessment"))
    }
  end

  def schema_definitions
    {
      "StaticModelJournalProvenanceV12" => {
        "keys" => [
          "dataset_kind_enum", "authority_bool", "historical_operation_bool",
          "operational_evidence_bool", "historical_receipt_interpretation_bool",
          "operational_record_frame_bytes_claim_bool",
          "body_recursive_validation_state_enum", "construction_plan_sha256",
          "journal_schema_sha256", "body_schema_set_sha256"
        ],
        "field_types_exact" => {
          "dataset_kind_enum" => "S", "authority_bool" => "B",
          "historical_operation_bool" => "B", "operational_evidence_bool" => "B",
          "historical_receipt_interpretation_bool" => "B",
          "operational_record_frame_bytes_claim_bool" => "B",
          "body_recursive_validation_state_enum" => "S",
          "construction_plan_sha256" => "H64", "journal_schema_sha256" => "H64",
          "body_schema_set_sha256" => "H64"
        },
        "constants_exact" => {
          "dataset_kind_enum" => "STATIC_MODEL", "authority_bool" => false,
          "historical_operation_bool" => false, "operational_evidence_bool" => false,
          "historical_receipt_interpretation_bool" => false,
          "operational_record_frame_bytes_claim_bool" => false,
          "body_recursive_validation_state_enum" =>
            "ABSTAIN_MISSING_REQUIRED_START"
        },
        "rule" => "STATIC_MODEL_IS_CONTENT_ADDRESSED_CONFORMANCE_DATA_ONLY_AND_NEVER_A_RecordObservationV12_FrameReferenceV12_OR_RecordFrameBytesV12_AUTHORITY"
      },
      "StaticModelTypedHoleV12" => {
        "keys" => [
          "expected_type_descriptor_exact", "reason_enum",
          "operational_value_present_bool"
        ],
        "field_types_exact" => {
          "expected_type_descriptor_exact" => "S", "reason_enum" => "S",
          "operational_value_present_bool" => "B"
        },
        "constants_exact" => {
          "reason_enum" => MODEL_BODY_HOLE_REASON,
          "operational_value_present_bool" => false
        },
        "rule" => "A_TYPED_HOLE_PRESERVES_THE_EXACT_PRODUCTION_BODY_FIELD_AND_EXPECTED_TYPE_WITHOUT_PRETENDING_TO_SUPPLY_THE_MISSING_OPERATIONAL_VALUE"
      },
      "StaticModelFrameIdentityV12" => {
        "keys" => [
          "schema", "status", "leaf", "ordinal_zero_based", "terminal_bool",
          "previous_complete_frame_with_lf_sha256_or_null", "bytes_uint",
          "lf_count_uint", "complete_frame_sha256", "payload_sha256",
          "body_static_model_sha256"
        ],
        "field_types_exact" => {
          "schema" => "S", "status" => "S", "leaf" => "S",
          "ordinal_zero_based" => "U", "terminal_bool" => "B",
          "previous_complete_frame_with_lf_sha256_or_null" => "H64_OR_NULL",
          "bytes_uint" => "U", "lf_count_uint" => "U",
          "complete_frame_sha256" => "H64", "payload_sha256" => "H64",
          "body_static_model_sha256" => "H64"
        },
        "constants_exact" => {"lf_count_uint" => 1},
        "rule" => "CONTENT_IDENTITY_ONLY_WITH_NO_PATH_VNODE_DESCRIPTOR_OR_PHYSICAL_OBSERVATION_CLAIM"
      },
      "StaticModelBodyValidationV12" => {
        "keys" => [
          "body_key_order_valid_bool", "body_constants_valid_bool",
          "operation_tuple_valid_bool_or_null", "typed_hole_count_uint",
          "recursive_operational_validation_state_enum"
        ],
        "field_types_exact" => {
          "body_key_order_valid_bool" => "B",
          "body_constants_valid_bool" => "B",
          "operation_tuple_valid_bool_or_null" => "B_OR_NULL",
          "typed_hole_count_uint" => "U",
          "recursive_operational_validation_state_enum" => "S"
        },
        "constants_exact" => {
          "body_key_order_valid_bool" => true,
          "body_constants_valid_bool" => true,
          "recursive_operational_validation_state_enum" =>
            "ABSTAIN_MISSING_REQUIRED_START"
        },
        "rule" => "KEY_ORDER_CONSTANTS_AND_OPERATION_TUPLE_ARE_MODEL_FACTS_WHILE_RECURSIVE_PRODUCTION_BODY_VALIDITY_REMAINS_ABSTAIN"
      },
      "StaticModelJournalEntryV12" => {
        "keys" => [
          "fixture_id", "leaf", "status", "body_schema_json_pointer",
          "predecessor_fixture_id_or_null", "complete_frame_raw_bytes",
          "frame_identity", "body_model_validation"
        ],
        "field_types_exact" => {
          "fixture_id" => "S", "leaf" => "S", "status" => "S",
          "body_schema_json_pointer" => "S",
          "predecessor_fixture_id_or_null" => "S_OR_NULL",
          "complete_frame_raw_bytes" => "REF(RawBytesV12)",
          "frame_identity" => "REF(StaticModelFrameIdentityV12)",
          "body_model_validation" => "REF(StaticModelBodyValidationV12)"
        },
        "rule" => "RAW_BYTES_USE_THE_EXACT_EIGHT_KEY_PRODUCTION_ENVELOPE_AND_EXACT_ONE_LF_BUT_THE_ENTRY_HAS_NO_PATH_VNODE_DESCRIPTOR_OR_OPERATIONAL_RECORD_OBJECT"
      },
      "StaticModelJournalIndexRowV12" => {
        "tuple_fields_exact_order" => [
          "entry_ordinal_uint", "fixture_id", "entry_canonical_sha256",
          "complete_frame_sha256", "payload_sha256"
        ],
        "tuple_field_types_exact" => ["U", "S", "H64", "H64", "H64"],
        "rule" => "ONE_BIDIRECTIONALLY_JOINED_ROW_PER_STATIC_MODEL_ENTRY_IN_FROZEN_ORDER"
      },
      "StaticModelJournalPredecessorEdgeV12" => {
        "keys" => [
          "edge_id", "predecessor_fixture_id", "successor_fixture_id",
          "predecessor_complete_frame_sha256",
          "successor_embedded_predecessor_sha256", "joined_bool"
        ],
        "field_types_exact" => {
          "edge_id" => "S", "predecessor_fixture_id" => "S",
          "successor_fixture_id" => "S",
          "predecessor_complete_frame_sha256" => "H64",
          "successor_embedded_predecessor_sha256" => "H64",
          "joined_bool" => "B"
        },
        "constants_exact" => {"joined_bool" => true},
        "rule" => "SUCCESSOR_EXACT_ENVELOPE_PREDECESSOR_DIGEST_EQUALS_THE_REFERENCED_PRIOR_STATIC_MODEL_COMPLETE_FRAME_DIGEST"
      },
      "StaticModelJournalMerkleCommitmentV12" => {
        "keys" => [
          "algorithm_id", "leaf_domain_base64", "node_domain_base64",
          "odd_rule_enum", "ordered_leaf_count_uint", "ordered_leaf_hashes",
          "root_sha256"
        ],
        "field_types_exact" => {
          "algorithm_id" => "S", "leaf_domain_base64" => "S",
          "node_domain_base64" => "S", "odd_rule_enum" => "S",
          "ordered_leaf_count_uint" => "U",
          "ordered_leaf_hashes" =>
            "ARRAY(H64,6,6,StaticModelJournalCatalogOrderV12)",
          "root_sha256" => "H64"
        },
        "constants_exact" => {
          "algorithm_id" => JOURNAL::MERKLE_ALGORITHM_ID,
          "odd_rule_enum" => "DUPLICATE_LAST_AT_EACH_ODD_LEVEL"
        },
        "rule" => "USES_THE_SHARED_DOMAIN_SEPARATED_COMPLETE_FRAME_LEAF_AND_NODE_ALGORITHM_WITH_FROZEN_ODD_DUPLICATION"
      },
      "StaticModelJournalCatalogV12" => {
        "keys" => [
          "provenance", "entries", "index_rows", "predecessor_edges",
          "merkle_commitment", "operational_replay_assessment",
          "entry_count_uint", "edge_count_uint", "catalog_payload_sha256"
        ],
        "field_types_exact" => {
          "provenance" => "REF(StaticModelJournalProvenanceV12)",
          "entries" =>
            "ARRAY(StaticModelJournalEntryV12,6,6,StaticModelJournalCatalogOrderV12)",
          "index_rows" =>
            "ARRAY(TUPLE(StaticModelJournalIndexRowV12),6,6,StaticModelJournalCatalogOrderV12)",
          "predecessor_edges" =>
            "ARRAY(StaticModelJournalPredecessorEdgeV12,5,5,StaticModelJournalEdgeOrderV12)",
          "merkle_commitment" => "REF(StaticModelJournalMerkleCommitmentV12)",
          "operational_replay_assessment" =>
            "REF(StaticModelOperationalReplayAssessmentV12)",
          "entry_count_uint" => "U", "edge_count_uint" => "U",
          "catalog_payload_sha256" => "H64"
        },
        "constants_exact" => {"entry_count_uint" => 6, "edge_count_uint" => 5},
        "rule" => "SELF_HASHED_CONTENT_ADDRESSED_STATIC_MODEL_SOURCE_SHARED_BY_C3_AND_LEGACY_ROUTES;NO_OPERATIONAL_RECORD_TYPES_ARE_EMBEDDED"
      },
      "StaticModelC3SourceRowV12" => {
        "keys" => [
          "ordinal_uint", "leaf", "abstract_state_enum",
          "catalog_fixture_id_or_null", "catalog_entry_canonical_sha256_or_null",
          "observed_static_model_bytes_or_null", "model_replay_state_enum",
          "model_error_code_or_null"
        ],
        "field_types_exact" => {
          "ordinal_uint" => "U", "leaf" => "S",
          "abstract_state_enum" => "S", "catalog_fixture_id_or_null" => "S_OR_NULL",
          "catalog_entry_canonical_sha256_or_null" => "H64_OR_NULL",
          "observed_static_model_bytes_or_null" => "REF_OR_NULL(RawBytesV12)",
          "model_replay_state_enum" => "S", "model_error_code_or_null" => "S_OR_NULL"
        },
        "rule" => "VALID_FINAL_IS_AN_ABSTRACT_C3_STATE_BOUND_ONLY_TO_A_STATIC_MODEL_EXACT_ENVELOPE;IT_DOES_NOT_MEAN_AN_OPERATIONAL_RecordObservationV12_VALID_FINAL"
      },
      "StaticModelC3SourceV12" => {
        "keys" => [
          "source_domain_enum", "catalog_payload_sha256", "provenance", "rows",
          "operational_replay_assessment"
        ],
        "field_types_exact" => {
          "source_domain_enum" => "S", "catalog_payload_sha256" => "H64",
          "provenance" => "REF(StaticModelJournalProvenanceV12)",
          "rows" =>
            "ARRAY(StaticModelC3SourceRowV12,5,5,StaticModelC3OperationOrderV12)",
          "operational_replay_assessment" =>
            "REF(StaticModelOperationalReplayAssessmentV12)"
        },
        "constants_exact" => {
          "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA"
        },
        "rule" => "THE_SOURCE_BINDS_EACH_ABSTRACT_STATE_TO_ACTUAL_STATIC_MODEL_BYTES_ABSENCE_A_DETERMINISTIC_REJECTED_MUTATION_OR_UNAVAILABILITY"
      },
      "StaticModelFirstUnenteredV12" => {
        "keys" => [
          "present_bool", "operation_label_or_null",
          "abstract_reason_enum_or_null"
        ],
        "field_types_exact" => {
          "present_bool" => "B", "operation_label_or_null" => "S_OR_NULL",
          "abstract_reason_enum_or_null" => "S_OR_NULL"
        },
        "rule" => "ABSTRACT_C3_REASON_ENUMS_NEVER_SUBSTITUTE_FOR_A_PRODUCTION_FirstUnenteredV12_PREDICATE_ID"
      },
      "StaticModelC3ProjectionV12" => {
        "keys" => [
          "source_domain_enum", "abstract_states", "classification_complete_bool",
          "operation_integrity_bool", "operation_hole_detected_bool",
          "valid_prefix_count_uint", "valid_static_model_frame_identities",
          "missing_expected_frames", "first_unentered_abstract",
          "operational_projection_state_enum",
          "operation_prefix_projection_v12_or_null",
          "record_frame_bytes_set_v12_or_null"
        ],
        "field_types_exact" => {
          "source_domain_enum" => "S",
          "abstract_states" =>
            "ARRAY(S,5,5,StaticModelC3OperationOrderV12)",
          "classification_complete_bool" => "B", "operation_integrity_bool" => "B",
          "operation_hole_detected_bool" => "B", "valid_prefix_count_uint" => "U",
          "valid_static_model_frame_identities" =>
            "ARRAY(StaticModelFrameIdentityV12,0,5,StaticModelC3OperationOrderV12)",
          "missing_expected_frames" => "ARRAY(S,0,5,MissingOperationFrameOrderV12)",
          "first_unentered_abstract" => "REF(StaticModelFirstUnenteredV12)",
          "operational_projection_state_enum" => "S",
          "operation_prefix_projection_v12_or_null" =>
            "REF_OR_NULL(OperationPrefixProjectionV12)",
          "record_frame_bytes_set_v12_or_null" =>
            "REF_OR_NULL(RecordFrameBytesSetV12)"
        },
        "constants_exact" => {
          "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA",
          "classification_complete_bool" => true,
          "operational_projection_state_enum" =>
            "ABSTAIN_MISSING_REQUIRED_START",
          "operation_prefix_projection_v12_or_null" => nil,
          "record_frame_bytes_set_v12_or_null" => nil
        },
        "rule" => "PREFIX_INTEGRITY_AND_HOLE_ARE_CLOSED_ONLY_IN_THE_STATIC_MODEL_DOMAIN;THE_TWO_OPERATIONAL_OUTPUTS_REMAIN_NULL"
      },
      "StaticModelLegacyRouteSourceV12" => {
        "keys" => [
          "route_id", "source_domain_enum", "catalog_payload_sha256",
          "catalog_merkle_root_sha256", "selected_fixture_ids",
          "selected_complete_frame_sha256s", "static_model_symbols_or_null",
          "operational_replay_assessment"
        ],
        "field_types_exact" => {
          "route_id" => "S", "source_domain_enum" => "S",
          "catalog_payload_sha256" => "H64", "catalog_merkle_root_sha256" => "H64",
          "selected_fixture_ids" => "ARRAY(S,1,6,StaticModelJournalCatalogOrderV12)",
          "selected_complete_frame_sha256s" =>
            "ARRAY(H64,1,6,StaticModelJournalCatalogOrderV12)",
          "static_model_symbols_or_null" => "ARRAY_OR_NULL(S,6,7,FrameOrdinalOrderV12)",
          "operational_replay_assessment" =>
            "REF(StaticModelOperationalReplayAssessmentV12)"
        },
        "constants_exact" => {
          "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA"
        },
        "rule" => "ALL_FOUR_ROUTES_RESOLVE_THEIR_RAW_BYTES_BY_SELECTED_FIXTURE_ID_AND_DIGEST_FROM_THE_ONE_SHARED_CATALOG;NORMALIZED_TRUTH_TABLES_AND_OPERATIONAL_REPLAY_ARE_SEPARATE"
      },
      "StaticModelOperationalReplayAssessmentV12" => {
        "keys" => operational_replay_assessment_schema_keys,
        "field_types_exact" => operational_replay_assessment_schema_types,
        "constants_exact" => {
          "state_enum" => "ABSTAIN_MISSING_REQUIRED_START",
          "required_source_available_bool" => false,
          "record_frame_bytes_rows_emitted_uint" => 0,
          "record_observations_emitted_uint" => 0,
          "operational_frame_reference_emitted_uint" => 0,
          "operation_prefix_projection_closed_bool" => false,
          "authority_closed_bool" => false,
          "historical_operation_asserted_bool" => false,
          "operational_evidence_asserted_bool" => false
        },
        "rule" => "THE_STATIC_MODEL_AND_OPERATIONAL_REPLAY_RESULTS_ARE_SEPARATE_PRODUCTS;MISSING_REQUIRED_START_REMAINS_ABSTAIN_AND_CANNOT_BE_PROMOTED_BY_MODEL_BYTES"
      }
    }
  end

  def operational_replay_assessment_schema_keys
    %w[
      state_enum reason_enum required_schema_json_pointer
      required_source_available_bool static_model_envelope_replay_bool
      record_frame_bytes_rows_emitted_uint record_observations_emitted_uint
      operational_frame_reference_emitted_uint
      operation_prefix_projection_closed_bool authority_closed_bool
      historical_operation_asserted_bool operational_evidence_asserted_bool
    ]
  end

  def operational_replay_assessment_schema_types
    {
      "state_enum" => "S", "reason_enum" => "S",
      "required_schema_json_pointer" => "S",
      "required_source_available_bool" => "B",
      "static_model_envelope_replay_bool" => "B",
      "record_frame_bytes_rows_emitted_uint" => "U",
      "record_observations_emitted_uint" => "U",
      "operational_frame_reference_emitted_uint" => "U",
      "operation_prefix_projection_closed_bool" => "B",
      "authority_closed_bool" => "B", "historical_operation_asserted_bool" => "B",
      "operational_evidence_asserted_bool" => "B"
    }
  end

  def order_definitions
    {
      "StaticModelJournalCatalogOrderV12" =>
        "EXACT_R00_T01_B01_B02_B03_B04_INCOMPLETE_NO_RUNTIME_RESORT",
      "StaticModelJournalEdgeOrderV12" =>
        "EXACT_R00_TO_T01_TO_B01_TO_B02_TO_B03_TO_B04_INCOMPLETE_NO_RUNTIME_RESORT",
      "StaticModelC3OperationOrderV12" =>
        "EXACT_T01_B01_B02_B03_B04_NO_RUNTIME_RESORT"
    }
  end

  def install!(control)
    record_schema = control.fetch("exact_record_schema_v12")
    reusable = record_schema.fetch("reusable_objects")
    order_registry = record_schema.fetch("order_registry_v12")
    decision = record_schema.fetch("decision_kernel_v12")
    operational_ids = %w[
      RecordObservationV12 FrameReferenceV12 RecordFrameBytesV12 RecordFrameBytesSetV12
    ]
    before = operational_ids.to_h do |type_id|
      [type_id, sha256(compact(reusable.fetch(type_id)))]
    end
    definitions = schema_definitions
    orders = order_definitions
    schema_collision = definitions.keys & reusable.keys
    unless schema_collision.empty?
      raise ModelError.new("STATIC_MODEL_SCHEMA_ID_COLLISION", "type_ids" => schema_collision)
    end
    order_collision = orders.keys & order_registry.keys
    unless order_collision.empty?
      raise ModelError.new("STATIC_MODEL_ORDER_ID_COLLISION", "order_ids" => order_collision)
    end
    decision_collision = [CATALOG_FIELD, SCHEMA_FIELD, ORDER_FIELD].select do |field|
      decision.key?(field)
    end
    unless decision_collision.empty?
      raise ModelError.new(
        "STATIC_MODEL_DECISION_FIELD_COLLISION", "fields" => decision_collision
      )
    end
    catalog = build_catalog!(control)

    definitions.each { |type_id, schema| reusable[type_id] = deep_clone(schema) }
    orders.each { |order_id, rule| order_registry[order_id] = rule }
    after = operational_ids.to_h do |type_id|
      [type_id, sha256(compact(reusable.fetch(type_id)))]
    end
    unless before == after
      raise ModelError.new("OPERATIONAL_RECORD_SCHEMA_MUTATED_BY_STATIC_MODEL_INSTALL")
    end
    decision[CATALOG_FIELD] = catalog
    decision[SCHEMA_FIELD] = deep_clone(definitions)
    decision[ORDER_FIELD] = deep_clone(orders)
    {
      "catalog_field" => CATALOG_FIELD,
      "catalog_payload_sha256" => catalog.fetch("catalog_payload_sha256"),
      "catalog_merkle_root_sha256" => catalog.dig("merkle_commitment", "root_sha256"),
      "installed_order_ids_exact" => orders.keys,
      "operational_schema_sha256_before" => before,
      "operational_schema_sha256_after" => after,
      "operational_schemas_unchanged_bool" => true
    }
  end

  def expect_error(expected_code)
    begin
      yield
    rescue ModelError => error
      unless error.code == expected_code
        raise ModelError.new(
          "STATIC_MODEL_SELF_TEST_WRONG_ERROR",
          "expected" => expected_code,
          "actual" => error.code
        )
      end
      return true
    end
    raise ModelError.new("STATIC_MODEL_SELF_TEST_EXPECTED_REJECTION_MISSING", "expected" => expected_code)
  end

  def self_test!(control)
    catalog = build_catalog!(control)
    validate_catalog!(control, catalog)
    cases = [
      ["ALL_VALID", %w[VALID_FINAL VALID_FINAL VALID_FINAL VALID_FINAL VALID_FINAL], 5, true, false],
      ["CLEAN_PREFIX", %w[VALID_FINAL VALID_FINAL VALID_FINAL ABSENT ABSENT], 3, true, false],
      ["ALL_ABSENT", %w[ABSENT ABSENT ABSENT ABSENT ABSENT], 0, true, false],
      ["ABSENT_HOLE", %w[VALID_FINAL ABSENT VALID_FINAL ABSENT ABSENT], 1, false, true],
      ["INVALID_HOLE", %w[VALID_FINAL INVALID VALID_FINAL ABSENT ABSENT], 1, false, true],
      ["UNAVAILABLE_HOLE", %w[VALID_FINAL UNAVAILABLE VALID_FINAL ABSENT ABSENT], 1, false, true],
      ["INVALID_SUFFIX", %w[VALID_FINAL VALID_FINAL INVALID ABSENT ABSENT], 2, false, false]
    ]
    case_results = cases.map do |case_id, states, prefix, integrity, hole|
      source = c3_source!(:control => control, :catalog => catalog, :states => states)
      replay = replay_c3_algebra!(
        :control => control, :catalog => catalog, :source => source, :scope => "OUTER"
      )
      unless replay.fetch("valid_prefix_count_uint") == prefix &&
             replay.fetch("classification_complete_bool") == true &&
             replay.fetch("operation_integrity_bool") == integrity &&
             replay.fetch("operation_hole_detected_bool") == hole &&
             replay.fetch("operational_projection_state_enum") ==
               "ABSTAIN_MISSING_REQUIRED_START" &&
             replay.fetch("operation_prefix_projection_v12_or_null").nil? &&
             replay.fetch("record_frame_bytes_set_v12_or_null").nil?
        raise ModelError.new("STATIC_MODEL_C3_CASE_MISMATCH", "case_id" => case_id)
      end
      [case_id, sha256(compact(source)), sha256(compact(replay))]
    end

    routes = ROUTE_IDS.map do |route_id|
      source = shared_route_source!(
        :control => control, :catalog => catalog, :route_id => route_id
      )
      unless source.dig("operational_replay_assessment", "state_enum") ==
             "ABSTAIN_MISSING_REQUIRED_START"
        raise ModelError.new("STATIC_MODEL_ROUTE_OPERATIONAL_STATE_MISMATCH", "route_id" => route_id)
      end
      [route_id, sha256(compact(source))]
    end

    invented = raw_bytes(compact({
      "schema" => "ergentics.conformance.operation-frame.v12",
      "ordinal_uint" => 1,
      "label" => "T01",
      "status" => "PASS_OPERATION",
      "payload_sha256" => "0" * 64
    }) + "\n")
    expect_error("STATIC_MODEL_ENVELOPE_KEYS_MISMATCH") do
      parse_model_frame!(control, invented)
    end

    payload_mutation = deep_clone(catalog)
    entry = payload_mutation.fetch("entries").fetch(1)
    entry["complete_frame_raw_bytes"] = invalid_bytes_from_entry(entry)
    predigest = payload_mutation.reject { |key, _value| key == "catalog_payload_sha256" }
    payload_mutation["catalog_payload_sha256"] = sha256(compact(predigest))
    expect_error("STATIC_MODEL_PAYLOAD_DIGEST_MISMATCH") do
      validate_catalog!(control, payload_mutation)
    end

    predecessor_mutation = deep_clone(catalog)
    entry = predecessor_mutation.fetch("entries").fetch(2)
    bytes = decode_raw_bytes!(entry.fetch("complete_frame_raw_bytes"))
    envelope = JSON.parse(bytes.delete_suffix("\n"))
    envelope["previous_complete_frame_with_lf_sha256_or_null"] = "f" * 64
    predigest_envelope = envelope.reject { |key, _value| key == "payload_sha256" }
    envelope["payload_sha256"] = sha256(compact(predigest_envelope))
    entry["complete_frame_raw_bytes"] = raw_bytes(compact(envelope) + "\n")
    entry["frame_identity"] = model_frame_identity(envelope, compact(envelope) + "\n")
    predigest = predecessor_mutation.reject { |key, _value| key == "catalog_payload_sha256" }
    predecessor_mutation["catalog_payload_sha256"] = sha256(compact(predigest))
    expect_error("STATIC_MODEL_ENTRY_PREDECESSOR_MISMATCH") do
      validate_catalog!(control, predecessor_mutation)
    end

    merkle_mutation = deep_clone(catalog)
    merkle_mutation["merkle_commitment"]["root_sha256"] = "a" * 64
    predigest = merkle_mutation.reject { |key, _value| key == "catalog_payload_sha256" }
    merkle_mutation["catalog_payload_sha256"] = sha256(compact(predigest))
    expect_error("STATIC_MODEL_MERKLE_ROUND_TRIP_MISMATCH") do
      validate_catalog!(control, merkle_mutation)
    end

    provenance_mutation = deep_clone(catalog)
    provenance_mutation["provenance"]["authority_bool"] = true
    predigest = provenance_mutation.reject { |key, _value| key == "catalog_payload_sha256" }
    provenance_mutation["catalog_payload_sha256"] = sha256(compact(predigest))
    expect_error("STATIC_MODEL_PROVENANCE_MISMATCH") do
      validate_catalog!(control, provenance_mutation)
    end

    {
      "result_enum" => "PASS",
      "catalog_payload_sha256" => catalog.fetch("catalog_payload_sha256"),
      "merkle_root_sha256" => catalog.dig("merkle_commitment", "root_sha256"),
      "entry_count_uint" => catalog.fetch("entry_count_uint"),
      "edge_count_uint" => catalog.fetch("edge_count_uint"),
      "c3_case_count_uint" => case_results.length,
      "legacy_and_c3_route_count_uint" => routes.length,
      "negative_case_count_uint" => 5,
      "c3_case_result_digests" => case_results,
      "route_source_digests" => routes,
      "operational_replay_state_enum" =>
        catalog.dig("operational_replay_assessment", "state_enum"),
      "operational_frame_rows_emitted_uint" => 0,
      "authority_closed_bool" => false
    }
  end
end
