# frozen_string_literal: true

require "base64"
require "digest"
require "json"

# Scratch-only constructor for exact production JOURNAL_OPERATION frames.
#
# This file intentionally has no load-time mutation.  It will not turn a
# conformance sentinel, an expected projection, or a schema definition into a
# record body.  A caller must provide:
#
# * canonical held OPERATION_V12 body bytes,
# * the exact recursively-validating body replay,
# * the held immediate predecessor FrameReferenceV12,
# * and the post-publication descriptor/content/namespace observations.
#
# Missing any one of those inputs is a closure failure and produces no frame.
module V12ProductionOperationFrame
  JOURNAL_SCHEMA_POINTER = "/exact_record_schema_v12/records/journal".freeze
  OPERATION_BODY_SCHEMA_POINTER =
    "/exact_record_schema_v12/records/journal/body_schemas/OPERATION".freeze
  JOURNAL_FRAME_SCHEMA =
    "ergentics-r19-obs11-c2-build-owner-journal-frame-v12".freeze

  ENVELOPE_KEYS = [
    "schema",
    "status",
    "leaf",
    "ordinal_zero_based",
    "terminal_bool",
    "previous_complete_frame_with_lf_sha256_or_null",
    "body",
    "payload_sha256"
  ].freeze

  OPERATION_BODY_KEYS = [
    "body_schema",
    "label",
    "one_based_ordinal",
    "root_label",
    "child_contract",
    "watch_before",
    "precondition",
    "capture_lifetime",
    "fixed_output_observations_before",
    "stdout_publication",
    "stderr_publication",
    "process",
    "interval",
    "timing_evidence",
    "stdout_admission",
    "stderr_admission",
    "test_summary",
    "fixed_output_observations_after",
    "fixed_output_provenance",
    "watch_after",
    "postcondition",
    "first_failure",
    "first_unentered",
    "predecessor_publication_joins",
    "publication_origin",
    "evidence_sources",
    "predicate_evaluations",
    "status_decision",
    "transition_receipts",
    "counter_snapshots"
  ].freeze

  OPERATION_CONSTANT_KEYS = [
    "body_schema", "label", "one_based_ordinal", "root_label"
  ].freeze

  OPERATION_TRANSITIONS = [
    "TR_SWIFTPM_CAPTURES_HELD",
    "TR_SWIFTPM_SPAWN_CALL_ENTERED",
    "TR_SWIFTPM_PID_RETURNED",
    "TR_SWIFTPM_EXACT_REAP"
  ].freeze

  class ClosureError < StandardError
    attr_reader :code, :details

    def initialize(code, details = {})
      @code = code
      @details = details
      super("#{code}:#{JSON.generate(details)}")
    end
  end

  class DuplicateRejectingHash < Hash
    def []=(key, value)
      raise ClosureError.new("DUPLICATE_JSON_KEY", "key" => key) if key?(key)

      super
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

  def h64?(value)
    value.is_a?(String) && value.match?(/\A[0-9a-f]{64}\z/)
  end

  def pointer_escape(token)
    token.to_s.gsub("~", "~0").gsub("/", "~1")
  end

  def exact_journal_schema(control)
    journal = control.dig("exact_record_schema_v12", "records", "journal")
    raise ClosureError.new("MISSING_JOURNAL_SCHEMA", "pointer" => JOURNAL_SCHEMA_POINTER) unless journal.is_a?(Hash)
    unless journal.fetch("schema", nil) == JOURNAL_FRAME_SCHEMA
      raise ClosureError.new(
        "JOURNAL_SCHEMA_ID_MISMATCH",
        "expected" => JOURNAL_FRAME_SCHEMA,
        "actual" => journal["schema"]
      )
    end
    unless journal.fetch("envelope_keys_exact_ordered", nil) == ENVELOPE_KEYS
      raise ClosureError.new("JOURNAL_ENVELOPE_KEYS_MISMATCH")
    end

    journal
  end

  def exact_operation_schema(control)
    journal = exact_journal_schema(control)
    schema = journal.dig("body_schemas", "OPERATION")
    raise ClosureError.new("MISSING_OPERATION_BODY_SCHEMA", "pointer" => OPERATION_BODY_SCHEMA_POINTER) unless schema.is_a?(Hash)
    raise ClosureError.new("OPERATION_BODY_KEYS_MISMATCH") unless schema.fetch("keys", nil) == OPERATION_BODY_KEYS
    unless schema.dig("constants_exact", "body_schema") == "OPERATION_V12"
      raise ClosureError.new("OPERATION_BODY_SCHEMA_CONSTANT_MISMATCH")
    end

    schema
  end

  def journal_contract(control)
    contract = control["journal"]
    unless contract.is_a?(Hash) &&
           contract.fetch("frame_schema", nil) == JOURNAL_FRAME_SCHEMA &&
           contract.fetch("common_keys_exact_ordered", nil) == ENVELOPE_KEYS
      raise ClosureError.new("MISSING_OR_MISMATCHED_JOURNAL_CONTRACT")
    end
    contract
  end

  def parse_canonical_object!(bytes, expected_keys, source_id)
    unless bytes.is_a?(String) && bytes.encoding != Encoding::UTF_16LE && bytes.encoding != Encoding::UTF_16BE
      raise ClosureError.new("SOURCE_BYTES_NOT_STRING", "source_id" => source_id)
    end
    if bytes.end_with?("\n") || bytes.include?("\r")
      raise ClosureError.new("SOURCE_BODY_HAS_RECORD_TERMINATOR", "source_id" => source_id)
    end

    utf8_bytes = bytes.dup.force_encoding(Encoding::UTF_8)
    unless utf8_bytes.valid_encoding?
      raise ClosureError.new("SOURCE_BYTES_NOT_UTF8", "source_id" => source_id)
    end

    parsed = JSON.parse(
      utf8_bytes,
      :object_class => DuplicateRejectingHash,
      :array_class => Array,
      :create_additions => false
    )
    unless parsed.is_a?(Hash) && parsed.keys == expected_keys
      raise ClosureError.new(
        "SOURCE_OBJECT_KEYS_MISMATCH",
        "source_id" => source_id,
        "expected" => expected_keys,
        "actual" => parsed.is_a?(Hash) ? parsed.keys : nil
      )
    end
    unless compact(parsed).b == bytes.b
      raise ClosureError.new("SOURCE_BYTES_NOT_COMPACT_SCHEMA_ORDER", "source_id" => source_id)
    end

    parsed
  rescue JSON::ParserError => error
    raise ClosureError.new(
      "SOURCE_JSON_PARSE_FAILED",
      "source_id" => source_id,
      "error_class" => error.class.name
    )
  end

  def operation_tuple!(journal, leaf)
    tuple = journal.dig("operation_body_tuple_by_leaf_exact", leaf)
    unless tuple.is_a?(Array) && tuple.length == 3
      raise ClosureError.new("LEAF_IS_NOT_OPERATION", "leaf" => leaf)
    end
    ordinal = journal.dig("ordinal_by_leaf_exact", leaf)
    unless tuple[1] == ordinal && journal.dig("body_variant_by_leaf_exact", leaf) == "OPERATION"
      raise ClosureError.new("OPERATION_LEAF_TABLE_CONTRADICTION", "leaf" => leaf)
    end

    tuple
  end

  def validate_vnode!(vnode, expected_size, source_id, journal = nil)
    keys = %w[
      type_enum device_uint inode_uint generation_uint uid_uint gid_uint
      mode_octal4 nlink_uint flags_uint size_uint ctime_seconds_int
      ctime_nanoseconds_uint mtime_seconds_int mtime_nanoseconds_uint
    ]
    unless vnode.is_a?(Hash) && vnode.keys == keys
      raise ClosureError.new("VNODE_KEYS_MISMATCH", "source_id" => source_id)
    end
    unless vnode.fetch("type_enum") == "REGULAR" && vnode.fetch("size_uint") == expected_size
      raise ClosureError.new(
        "VNODE_TYPE_OR_SIZE_MISMATCH",
        "source_id" => source_id,
        "expected_size" => expected_size,
        "actual_type" => vnode["type_enum"],
        "actual_size" => vnode["size_uint"]
      )
    end
    unless vnode.fetch("ctime_nanoseconds_uint").between?(0, 999_999_999) &&
           vnode.fetch("mtime_nanoseconds_uint").between?(0, 999_999_999)
      raise ClosureError.new("VNODE_NANOSECONDS_OUT_OF_RANGE", "source_id" => source_id)
    end
    if journal
      expected_publication_identity = {
        "uid_uint" => journal.fetch("every_complete_frame_uid"),
        "gid_uint" => journal.fetch("every_complete_frame_gid"),
        "mode_octal4" => journal.fetch("every_complete_frame_final_mode"),
        "nlink_uint" => journal.fetch("every_complete_frame_nlink"),
        "flags_uint" => journal.fetch("every_complete_frame_flags")
      }
      expected_publication_identity.each do |key, value|
        unless vnode.fetch(key) == value
          raise ClosureError.new(
            "VNODE_PUBLICATION_IDENTITY_MISMATCH",
            "source_id" => source_id,
            "field" => key,
            "expected" => value,
            "actual" => vnode[key]
          )
        end
      end
    end

    true
  rescue KeyError, NoMethodError
    raise ClosureError.new("VNODE_MALFORMED", "source_id" => source_id)
  end

  def validate_frame_reference!(control, reference, expected_leaf = nil)
    keys = control.dig(
      "exact_record_schema_v12", "reusable_objects", "FrameReferenceV12", "keys"
    )
    unless reference.is_a?(Hash) && reference.keys == keys
      raise ClosureError.new("FRAME_REFERENCE_KEYS_MISMATCH")
    end
    unless reference.fetch("schema") == JOURNAL_FRAME_SCHEMA &&
           reference.fetch("lf_count_uint") == 1 &&
           h64?(reference.fetch("complete_frame_sha256")) &&
           h64?(reference.fetch("payload_sha256"))
      raise ClosureError.new("FRAME_REFERENCE_STATIC_JOIN_FAILED")
    end
    leaf = File.basename(reference.fetch("path"))
    allowed_statuses = exact_journal_schema(control).dig("status_by_leaf", leaf)
    unless allowed_statuses.is_a?(Array) && allowed_statuses.include?(reference.fetch("status"))
      raise ClosureError.new(
        "FRAME_REFERENCE_LEAF_STATUS_MISMATCH",
        "leaf" => leaf,
        "status" => reference.fetch("status")
      )
    end
    if reference.fetch("bytes_uint") > journal_contract(control).fetch("maximum_bytes_per_frame")
      raise ClosureError.new("FRAME_REFERENCE_CAP_EXCEEDED", "leaf" => leaf)
    end
    if expected_leaf && File.basename(reference.fetch("path")) != expected_leaf
      raise ClosureError.new(
        "PREDECESSOR_LEAF_MISMATCH",
        "expected_leaf" => expected_leaf,
        "actual_path" => reference.fetch("path")
      )
    end
    validate_vnode!(
      reference.fetch("vnode"),
      reference.fetch("bytes_uint"),
      "frame_reference",
      journal_contract(control)
    )
    true
  end

  def validate_operation_body!(control, journal, leaf, status, body_bytes, recursive_validator)
    _schema = exact_operation_schema(control)
    body = parse_canonical_object!(body_bytes, OPERATION_BODY_KEYS, "OPERATION_V12_BODY")
    tuple = operation_tuple!(journal, leaf)
    expected_constants = ["OPERATION_V12", tuple[0], tuple[1], tuple[2]]
    actual_constants = OPERATION_CONSTANT_KEYS.map { |key| body.fetch(key) }
    unless actual_constants == expected_constants
      raise ClosureError.new(
        "OPERATION_BODY_LEAF_TUPLE_MISMATCH",
        "leaf" => leaf,
        "expected" => expected_constants,
        "actual" => actual_constants
      )
    end
    unless recursive_validator.respond_to?(:call)
      raise ClosureError.new(
        "MISSING_RECURSIVE_BODY_VALIDATOR",
        "schema_pointer" => OPERATION_BODY_SCHEMA_POINTER,
        "body_sha256" => sha256(body_bytes)
      )
    end
    validation = recursive_validator.call(
      OPERATION_BODY_SCHEMA_POINTER,
      body,
      body_bytes,
      control
    )
    unless validation == true
      raise ClosureError.new(
        "RECURSIVE_BODY_VALIDATION_FAILED",
        "schema_pointer" => OPERATION_BODY_SCHEMA_POINTER,
        "body_sha256" => sha256(body_bytes),
        "validator_result" => validation
      )
    end

    validate_operation_decision!(control, body, status)
    validate_operation_transitions!(body, status)
    body
  end

  def validate_operation_decision!(control, body, status)
    decision = body.fetch("status_decision")
    ruleset = control.dig(
      "exact_record_schema_v12", "decision_kernel_v12",
      "status_ruleset_registry_v12", "JOURNAL_OPERATION"
    )
    unless ruleset.is_a?(Array) && ruleset.length == 3
      raise ClosureError.new("MISSING_OPERATION_RULESET_REGISTRY")
    end
    evaluations = body.fetch("predicate_evaluations")
    states = evaluations.to_h { |row| [row.fetch("predicate_id"), row.fetch("state_enum")] }
    unless states.length == evaluations.length
      raise ClosureError.new("DUPLICATE_OPERATION_PREDICATE_ID")
    end
    rules = control.dig(
      "exact_record_schema_v12", "decision_kernel_v12",
      "status_rules_v12", "JOURNAL_OPERATION"
    )
    evaluated_rule_ids = []
    selected = rules.sort_by { |rule| rule.fetch("priority_uint") }.find do |rule|
      evaluated_rule_ids << rule.fetch("rule_id")
      rule.fetch("conditions_all").all? do |condition|
        condition.fetch("allowed_states_exact_order").include?(
          states[condition.fetch("predicate_id")]
        )
      end
    end
    unless selected
      raise ClosureError.new("OPERATION_STATUS_RULE_NO_MATCH", "status" => status)
    end
    derived = {
      "ruleset_id" => ruleset[0],
      "ruleset_complete_json_sha256" => ruleset[2],
      "selected_rule_id" => selected.fetch("rule_id"),
      "selected_status_enum" => selected.fetch("selected_status_enum"),
      "evaluated_rule_ids_exact_order" => evaluated_rule_ids
    }
    unless decision == derived && decision.fetch("selected_status_enum") == status
      raise ClosureError.new(
        "OPERATION_STATUS_DECISION_MISMATCH",
        "status" => status,
        "derived_decision_sha256" => sha256(compact(derived)),
        "actual_decision_sha256" => sha256(compact(decision))
      )
    end

    true
  rescue KeyError, NoMethodError
    raise ClosureError.new("OPERATION_STATUS_DECISION_MALFORMED", "status" => status)
  end

  def validate_operation_transitions!(body, status)
    receipts = body.fetch("transition_receipts")
    unless receipts.is_a?(Array) && receipts.length == OPERATION_TRANSITIONS.length
      raise ClosureError.new("OPERATION_TRANSITION_COUNT_MISMATCH")
    end
    state_vector = receipts.map { |receipt| receipt.fetch("state_enum") }
    unless state_vector.all? { |state| %w[ENTERED NOT_ENTERED].include?(state) }
      raise ClosureError.new("OPERATION_TRANSITION_STATE_DOMAIN_MISMATCH")
    end
    entered_count = state_vector.take_while { |state| state == "ENTERED" }.length
    unless state_vector == (["ENTERED"] * entered_count + ["NOT_ENTERED"] * (4 - entered_count))
      raise ClosureError.new("OPERATION_TRANSITION_PREFIX_MISMATCH")
    end
    if %w[PASS_OPERATION FAIL_OPERATION].include?(status) && entered_count != 4
      raise ClosureError.new("TERMINAL_OPERATION_TRANSITIONS_NOT_ALL_ENTERED", "status" => status)
    end
    receipts.each_with_index do |receipt, index|
      unless receipt.fetch("sequence_uint") == index &&
             receipt.fetch("transition_id") == OPERATION_TRANSITIONS[index]
        raise ClosureError.new(
          "OPERATION_TRANSITION_RECEIPT_MISMATCH",
          "sequence_uint" => index,
          "expected_transition_id" => OPERATION_TRANSITIONS[index]
        )
      end
    end
    true
  rescue KeyError, NoMethodError
    raise ClosureError.new("OPERATION_TRANSITION_RECEIPT_MALFORMED")
  end

  def validate_artifact_slot_join!(control, slot, path, vnode)
    expected_keys = control.dig(
      "exact_record_schema_v12", "reusable_objects", "ArtifactSlotV12", "keys"
    )
    unless slot.is_a?(Hash) && slot.keys == expected_keys &&
           slot.fetch("final_path") == path &&
           slot.fetch("staging_pattern") == ".#{File.basename(path)}.XXXXXX.staging" &&
           slot.fetch("final_state_enum") == "PRESENT_REGULAR" &&
           slot.fetch("final_vnode_or_null") == vnode &&
           slot.fetch("staging_state_enum") == "NONE" &&
           slot.fetch("staging_leaves") == [] &&
           slot.fetch("staging_match_count_uint") == 0 &&
           slot.fetch("scan_complete_bool") == true &&
           slot.dig("error", "state_enum") == "NONE"
      raise ClosureError.new("ARTIFACT_SLOT_FRAME_JOIN_FAILED", "path" => path)
    end
    true
  rescue KeyError, NoMethodError
    raise ClosureError.new("ARTIFACT_SLOT_MALFORMED", "path" => path)
  end

  def validate_content_join!(control, content, vnode, bytes, digest, cap)
    expected_keys = control.dig(
      "exact_record_schema_v12", "reusable_objects", "ContentAdmissionV12", "keys"
    )
    unless content.is_a?(Hash) && content.keys == expected_keys
      raise ClosureError.new("CONTENT_ADMISSION_KEYS_MISMATCH")
    end
    expected = {
      "presence_enum" => "PRESENT",
      "read_enum" => "COMPLETE",
      "join_enum" => "JOINED",
      "cap_bytes_uint" => cap,
      "pre_vnode_or_null" => vnode,
      "sample_bytes_uint" => bytes.bytesize,
      "sample_lf_count_uint" => 1,
      "sample_sha256_or_null" => digest,
      "eof_observed_bool_or_null" => true,
      "overflow_witness_bool_or_null" => false,
      "complete_bytes_uint_or_null" => bytes.bytesize,
      "complete_lf_count_uint_or_null" => 1,
      "complete_sha256_or_null" => digest,
      "post_vnode_or_null" => vnode,
      "named_vnode_or_null" => vnode,
      "held_stable_bool_or_null" => true,
      "named_join_bool_or_null" => true
    }
    expected.each do |key, value|
      unless content.fetch(key) == value
        raise ClosureError.new(
          "CONTENT_FRAME_JOIN_FAILED",
          "field" => key,
          "expected_sha256" => sha256(compact(value)),
          "actual_sha256" => sha256(compact(content[key]))
        )
      end
    end
    unless content.dig("error", "state_enum") == "NONE"
      raise ClosureError.new("CONTENT_FRAME_JOIN_ERROR_NONNONE")
    end
    true
  rescue KeyError, NoMethodError
    raise ClosureError.new("CONTENT_ADMISSION_MALFORMED")
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

  def synthetic_physical_observation(control, path, complete_bytes, identity_ordinal)
    unless identity_ordinal.is_a?(Integer) && identity_ordinal >= 0
      raise ClosureError.new("SYNTHETIC_IDENTITY_ORDINAL_INVALID")
    end
    contract = journal_contract(control)
    vnode = {
      "type_enum" => "REGULAR",
      "device_uint" => 9_012,
      "inode_uint" => 9_012_000 + identity_ordinal,
      "generation_uint" => 12_000 + identity_ordinal,
      "uid_uint" => contract.fetch("every_complete_frame_uid"),
      "gid_uint" => contract.fetch("every_complete_frame_gid"),
      "mode_octal4" => contract.fetch("every_complete_frame_final_mode"),
      "nlink_uint" => contract.fetch("every_complete_frame_nlink"),
      "flags_uint" => contract.fetch("every_complete_frame_flags"),
      "size_uint" => complete_bytes.bytesize,
      "ctime_seconds_int" => 1,
      "ctime_nanoseconds_uint" => identity_ordinal,
      "mtime_seconds_int" => 1,
      "mtime_nanoseconds_uint" => identity_ordinal
    }
    cap = contract.fetch("maximum_bytes_per_frame")
    digest = sha256(complete_bytes)
    no_error = {
      "state_enum" => "NONE", "code_string_or_null" => nil,
      "errno_int_or_null" => nil, "exception_class_string_or_null" => nil,
      "message_base64_or_null" => nil, "message_bytes_uint_or_null" => nil,
      "message_sha256_or_null" => nil
    }
    slot = {
      "final_path" => path,
      "staging_pattern" => ".#{File.basename(path)}.XXXXXX.staging",
      "final_state_enum" => "PRESENT_REGULAR",
      "final_vnode_or_null" => deep_clone(vnode),
      "staging_state_enum" => "NONE",
      "staging_leaves" => [],
      "staging_match_count_uint" => 0,
      "scan_complete_bool" => true,
      "error" => deep_clone(no_error)
    }
    content = {
      "presence_enum" => "PRESENT", "read_enum" => "COMPLETE",
      "join_enum" => "JOINED", "cap_bytes_uint" => cap,
      "pre_vnode_or_null" => deep_clone(vnode),
      "sample_bytes_uint" => complete_bytes.bytesize,
      "sample_lf_count_uint" => 1, "sample_sha256_or_null" => digest,
      "eof_observed_bool_or_null" => true,
      "overflow_witness_bool_or_null" => false,
      "complete_bytes_uint_or_null" => complete_bytes.bytesize,
      "complete_lf_count_uint_or_null" => 1,
      "complete_sha256_or_null" => digest,
      "post_vnode_or_null" => deep_clone(vnode),
      "named_vnode_or_null" => deep_clone(vnode),
      "held_stable_bool_or_null" => true, "named_join_bool_or_null" => true,
      "error" => deep_clone(no_error)
    }
    {
      "path" => path,
      "vnode" => vnode,
      "artifact_slot" => slot,
      "content_admission" => content
    }
  end

  def operation_complete_frame_bytes!(
    control:,
    leaf:,
    status:,
    canonical_body_bytes:,
    recursive_body_validator:,
    predecessor_frame_reference:
  )
    journal = exact_journal_schema(control)
    tuple = operation_tuple!(journal, leaf)
    validate_frame_reference!(
      control,
      predecessor_frame_reference,
      journal.fetch("journal_leaf_tuple_table_v12").map(&:first).fetch(tuple[1] - 1)
    )
    body = validate_operation_body!(
      control, journal, leaf, status, canonical_body_bytes,
      recursive_body_validator
    )
    predigest = {
      "schema" => JOURNAL_FRAME_SCHEMA,
      "status" => status,
      "leaf" => leaf,
      "ordinal_zero_based" => tuple[1],
      "terminal_bool" => false,
      "previous_complete_frame_with_lf_sha256_or_null" =>
        predecessor_frame_reference.fetch("complete_frame_sha256"),
      "body" => body
    }
    payload = sha256(compact(predigest))
    complete = compact(predigest.merge("payload_sha256" => payload)) + "\n"
    unless complete.bytesize <= journal_contract(control).fetch("maximum_bytes_per_frame")
      raise ClosureError.new("PRODUCTION_FRAME_CAP_EXCEEDED")
    end
    complete
  end

  def build_synthetic!(
    control:,
    leaf:,
    status:,
    canonical_body_bytes:,
    recursive_body_validator:,
    predecessor_frame_reference:,
    path:,
    synthetic_identity_ordinal:
  )
    complete = operation_complete_frame_bytes!(
      :control => control, :leaf => leaf, :status => status,
      :canonical_body_bytes => canonical_body_bytes,
      :recursive_body_validator => recursive_body_validator,
      :predecessor_frame_reference => predecessor_frame_reference
    )
    observation = synthetic_physical_observation(
      control, path, complete, synthetic_identity_ordinal
    )
    build!(
      :control => control, :leaf => leaf, :status => status,
      :canonical_body_bytes => canonical_body_bytes,
      :recursive_body_validator => recursive_body_validator,
      :predecessor_frame_reference => predecessor_frame_reference,
      :path => observation.fetch("path"), :vnode => observation.fetch("vnode"),
      :artifact_slot => observation.fetch("artifact_slot"),
      :content_admission => observation.fetch("content_admission")
    )
  end

  def build_synthetic_incomplete!(**arguments)
    build_synthetic!(**arguments.merge(:status => "INCOMPLETE_OPERATION"))
  end

  def build!(
    control:,
    leaf:,
    status:,
    canonical_body_bytes:,
    recursive_body_validator:,
    predecessor_frame_reference:,
    path:,
    vnode:,
    artifact_slot:,
    content_admission:
  )
    journal = exact_journal_schema(control)
    tuple = operation_tuple!(journal, leaf)
    allowed_statuses = journal.dig("status_by_leaf", leaf)
    unless allowed_statuses.is_a?(Array) && allowed_statuses.include?(status) &&
           %w[PASS_OPERATION FAIL_OPERATION INCOMPLETE_OPERATION].include?(status)
      raise ClosureError.new(
        "STATUS_NOT_OPERATION_DOMAIN",
        "leaf" => leaf,
        "status" => status
      )
    end

    ordinal = tuple[1]
    leaves = journal.fetch("journal_leaf_tuple_table_v12").map(&:first)
    expected_predecessor_leaf = leaves.fetch(ordinal - 1)
    validate_frame_reference!(control, predecessor_frame_reference, expected_predecessor_leaf)
    predecessor_hash = predecessor_frame_reference.fetch("complete_frame_sha256")

    body = validate_operation_body!(
      control,
      journal,
      leaf,
      status,
      canonical_body_bytes,
      recursive_body_validator
    )
    predigest_object = {
      "schema" => JOURNAL_FRAME_SCHEMA,
      "status" => status,
      "leaf" => leaf,
      "ordinal_zero_based" => ordinal,
      "terminal_bool" => false,
      "previous_complete_frame_with_lf_sha256_or_null" => predecessor_hash,
      "body" => body
    }
    predigest_bytes = compact(predigest_object)
    payload_digest = sha256(predigest_bytes)
    envelope = predigest_object.merge("payload_sha256" => payload_digest)
    unless envelope.keys == ENVELOPE_KEYS
      raise ClosureError.new("PRODUCTION_ENVELOPE_ORDER_MISMATCH")
    end
    complete_bytes = compact(envelope) + "\n"
    unless complete_bytes.count("\n") == 1 && complete_bytes.end_with?("\n")
      raise ClosureError.new("PRODUCTION_FRAME_LF_MISMATCH")
    end
    publication_contract = journal_contract(control)
    frame_cap_bytes_uint = publication_contract.fetch("maximum_bytes_per_frame")
    unless frame_cap_bytes_uint.is_a?(Integer) && frame_cap_bytes_uint >= 0 &&
           complete_bytes.bytesize <= frame_cap_bytes_uint
      raise ClosureError.new(
        "PRODUCTION_FRAME_CAP_EXCEEDED",
        "bytes_uint" => complete_bytes.bytesize,
        "cap_bytes_uint" => frame_cap_bytes_uint
      )
    end
    unless path.is_a?(String) && File.basename(path) == leaf
      raise ClosureError.new("PRODUCTION_FRAME_PATH_LEAF_MISMATCH", "path" => path, "leaf" => leaf)
    end

    validate_vnode!(vnode, complete_bytes.bytesize, "published_frame", publication_contract)
    validate_artifact_slot_join!(control, artifact_slot, path, vnode)
    complete_digest = sha256(complete_bytes)
    validate_content_join!(
      control,
      content_admission,
      vnode,
      complete_bytes,
      complete_digest,
      frame_cap_bytes_uint
    )

    frame_reference = {
      "path" => path,
      "schema" => JOURNAL_FRAME_SCHEMA,
      "status" => status,
      "vnode" => deep_clone(vnode),
      "bytes_uint" => complete_bytes.bytesize,
      "lf_count_uint" => 1,
      "complete_frame_sha256" => complete_digest,
      "payload_sha256" => payload_digest
    }
    validate_frame_reference!(control, frame_reference, leaf)
    record_observation = {
      "state_enum" => "FINAL_PRESENT",
      "slot" => deep_clone(artifact_slot),
      "content" => deep_clone(content_admission),
      "parse_state_enum" => "VALID",
      "frame_reference_or_null" => deep_clone(frame_reference),
      "error" => {
        "state_enum" => "NONE",
        "code_string_or_null" => nil,
        "errno_int_or_null" => nil,
        "exception_class_string_or_null" => nil,
        "message_base64_or_null" => nil,
        "message_bytes_uint_or_null" => nil,
        "message_sha256_or_null" => nil
      }
    }
    record_frame_bytes = {
      "ordinal_uint" => ordinal,
      "leaf" => leaf,
      "frame_reference" => deep_clone(frame_reference),
      "content_admission" => deep_clone(content_admission),
      "bytes_uint" => complete_bytes.bytesize,
      "lf_count_uint" => 1,
      "complete_frame_sha256" => complete_digest
    }

    {
      "predigest_raw_bytes" => raw_bytes(predigest_bytes),
      "complete_frame_raw_bytes" => raw_bytes(complete_bytes),
      "frame_reference" => frame_reference,
      "record_observation" => record_observation,
      "record_frame_bytes" => record_frame_bytes
    }
  end

  def build_pass!(**arguments)
    build!(**arguments.merge(:status => "PASS_OPERATION"))
  end

  def build_controlled_fail!(**arguments)
    build!(**arguments.merge(:status => "FAIL_OPERATION"))
  end

  def build_incomplete!(**arguments)
    build!(**arguments.merge(:status => "INCOMPLETE_OPERATION"))
  end

  def operation_body_candidates(control)
    candidates = []
    walk = lambda do |value, pointer|
      case value
      when Hash
        if value.keys == OPERATION_BODY_KEYS && value["body_schema"] == "OPERATION_V12"
          candidates << {
            "json_pointer" => pointer,
            "canonical_bytes_uint" => compact(value).bytesize,
            "canonical_sha256" => sha256(compact(value)),
            "label" => value["label"],
            "selected_status_enum_or_null" => value.dig("status_decision", "selected_status_enum")
          }
        end
        value.each do |key, member|
          walk.call(member, "#{pointer}/#{pointer_escape(key)}")
        end
      when Array
        value.each_with_index { |member, index| walk.call(member, "#{pointer}/#{index}") }
      end
    end
    walk.call(control, "")
    candidates
  end

  def held_control_closure_assessment(control, leaf:, status:)
    journal = exact_journal_schema(control)
    schema = exact_operation_schema(control)
    tuple = operation_tuple!(journal, leaf)
    candidates = operation_body_candidates(control).select do |row|
      row["label"] == tuple[0] && row["selected_status_enum_or_null"] == status
    end
    bindings = control.dig(
      "exact_record_schema_v12", "state_constraint_registry_v12",
      "record_context_profile_bindings_exact"
    ) || []
    typed_dependencies = OPERATION_BODY_KEYS.drop(OPERATION_CONSTANT_KEYS.length).map do |key|
      pointer = "/#{key}"
      bound = bindings.select { |row| row[0] == "JOURNAL_OPERATION" && row[1] == pointer }
      {
        "body_json_pointer" => pointer,
        "type_descriptor_exact" => schema.fetch("field_types_exact").fetch(key),
        "context_binding_rows_exact" => deep_clone(bound),
        "required_source_state" => "HELD_RECURSIVELY_SCHEMA_VALID_CANONICAL_VALUE"
      }
    end
    predecessor_leaf = journal.fetch("journal_leaf_tuple_table_v12").map(&:first).fetch(tuple[1] - 1)
    missing = []
    if candidates.empty?
      missing << {
        "dependency_id" => "OPERATION_V12_BODY_INSTANCE:#{leaf}:#{status}",
        "schema_json_pointer" => OPERATION_BODY_SCHEMA_POINTER,
        "typed_members_required" => typed_dependencies
      }
    end
    missing << {
      "dependency_id" => "IMMEDIATE_PREDECESSOR_FRAME_REFERENCE:#{predecessor_leaf}",
      "type_descriptor_exact" => "REF(FrameReferenceV12)",
      "required_join" => "HELD_COMPLETE_FRAME_WITH_LF_SHA256"
    }
    missing << {
      "dependency_id" => "POSTPUBLICATION_FRAME_OBSERVATION:#{leaf}",
      "type_descriptors_exact" => [
        "REF(VnodeV12)", "REF(ArtifactSlotV12)", "REF(ContentAdmissionV12)"
      ],
      "required_join" => "PATH_VNODE_BYTES_LF_COMPLETE_SHA256_PAYLOAD_SHA256"
    }

    {
      "closure_state_enum" => missing.empty? ? "CLOSED" : "MISSING_TYPED_DEPENDENCY",
      "journal_schema" => JOURNAL_FRAME_SCHEMA,
      "operation_body_schema_json_pointer" => OPERATION_BODY_SCHEMA_POINTER,
      "operation_body_schema_sha256" => sha256(compact(schema)),
      "leaf" => leaf,
      "status" => status,
      "held_operation_body_candidates" => candidates,
      "missing_dependencies" => missing,
      "frame_emitted_bool" => false
    }
  end
end
