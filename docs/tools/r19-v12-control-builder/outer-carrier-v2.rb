# frozen_string_literal: true

# Scratch-only replacement for the OUT_UNENTERED_EVIDENCE_CLEAN carrier.
#
# This layer deliberately has no case-enum materializer.  A vector may name
# one content-addressed source fixture, but the fixture must retain every raw
# production-profile input needed to reproduce the typed predicate carrier.
# In particular, a FrameReferenceV12 or a digest is never accepted in place of
# the complete frame bytes and their held-content/vnode admission.

V12_OUTER_V2_BASE_VECTOR_WIDTH = 18
V12_OUTER_V2_FINAL_VECTOR_WIDTH = 19
V12_OUTER_V2_CASE_COUNT = 22

raise "outer v2 vector count #{vectors.length}" unless vectors.length == V12_OUTER_V2_CASE_COUNT
raise "outer v2 scenario count #{scenario_cases.length}" unless scenario_cases.length == V12_OUTER_V2_CASE_COUNT
raise "outer v2 duplicate vector id" unless vectors.map(&:first).uniq.length == V12_OUTER_V2_CASE_COUNT
raise "outer v2 duplicate scenario id" unless scenario_cases.keys.uniq.length == V12_OUTER_V2_CASE_COUNT
raise "outer v2 vector/scenario order" unless vectors.map(&:first) == scenario_cases.keys
raise "outer v2 base widths #{vectors.map(&:length).uniq.inspect}" unless vectors.all? { |row| row.length == V12_OUTER_V2_BASE_VECTOR_WIDTH }
raise "outer v2 case tuple widths" unless scenario_cases.values.all? { |row| row.length == 11 }

# No mutation of RecordPresenceV12 is permitted.  The production shape already
# classifies a final fstatat failure as FINAL_WRONG_TYPE and a staging scan
# failure as STAGING_PRESENT; the orthogonal ArtifactSlotV12 axes retain the
# exact failure.
record_presence_before = clone(X.fetch("enum_domains_v12").fetch("RecordPresenceV12"))
raise "outer v2 unexpected RecordPresenceV12" unless record_presence_before == %w[ABSENT STAGING_PRESENT FINAL_WRONG_TYPE FINAL_AND_STAGING FINAL_PRESENT]

R["OuterJournalFrameSourceV12"] = {
  "keys" => ["ordinal_uint", "raw_complete_frame", "record_observation", "record_frame_bytes"],
  "field_types_exact" => {
    "ordinal_uint" => "U", "raw_complete_frame" => "REF(RawBytesV12)",
    "record_observation" => "REF(RecordObservationV12)",
    "record_frame_bytes" => "REF(RecordFrameBytesV12)"
  },
  "rule" => "raw_complete_frame_STRICTLY_DECODES_TO_ONE_CANONICAL_PRODUCTION_JOURNAL_ENVELOPE_PLUS_ONE_LF;ordinal_leaf_schema_status_payload_PREDECESSOR_AND_COMPLETE_HASH_JOIN_record_observation.frame_reference_AND_record_frame_bytes;ALL_CONTENT_LENGTH_LF_SHA_AND_VNODE_FIELDS_JOIN;NO_SYNTHETIC_FRAME_DIGEST_OR_CONFORMANCE_SENTINEL_BODY"
}
R["OuterJournalSlotSourceV12"] = {
  "keys" => [
    "ordinal_uint", "raw_observed_bytes_or_null", "record_observation",
    "record_frame_bytes_or_null"
  ],
  "field_types_exact" => {
    "ordinal_uint" => "U", "raw_observed_bytes_or_null" => "REF_OR_NULL(RawBytesV12)",
    "record_observation" => "REF(RecordObservationV12)",
    "record_frame_bytes_or_null" => "REF_OR_NULL(RecordFrameBytesV12)"
  },
  "rule" => "EXACT_ONE_FIXED_JOURNAL_SLOT;ABSENT_HAS_NO_RAW_BYTES_OR_FRAME_BYTES;VALID_FINAL_HAS_RAW_BYTES_AND_A_FULL_OuterJournalFrameSourceV12_JOIN;MALFORMED_WRONG_TYPE_STAGING_OR_UNAVAILABLE_RETAINS_RAW_BYTES_WHEN_ANY_WERE_READ_BUT_FORBIDS_RecordFrameBytesV12_AND_FRAME_REFERENCE;NO_FAILED_BYTES_ARE_DROPPED"
}
R["OuterAdmissionBaselineSourceV12"] = {
  "keys" => [
    "profile_id", "profile", "members", "baseline_rows", "current_rows",
    "materialized_joins"
  ],
  "field_types_exact" => {
    "profile_id" => "S", "profile" => "REF(AdmissionBaselineProfileV12)",
    "members" => "ARRAY(TUPLE(AdmissionProfileMemberV12),56,56,AdmissionOrdinalOrderV12)",
    "baseline_rows" => "ARRAY(REF_OR_NULL(AdmissionRowV12),56,56,AdmissionOrdinalOrderV12)",
    "current_rows" => "ARRAY(REF_OR_NULL(AdmissionRowV12),56,56,AdmissionOrdinalOrderV12)",
    "materialized_joins" => "REF(AdmissionBaselineJoinSetV12)"
  },
  "rule" => "profile_id_EXACT_OUTER_DIRECT_START_56_OR_OUTER_DIRECT_READINESS_56;profile_DEEP_EQUALS_THE_FROZEN_PROFILE;members_ARE_THE_EXACT_GLOBAL0THROUGH55_SLICE;EACH_JOIN_HASH_IS_RECOMPUTED_FROM_THE_ACTUAL_SCHEMA_ORDER_AdmissionRowV12_WITH_ordinal_uint_REMOVED_AND_EQUALITY_IS_TYPED_DEEP_EQUALITY_NOT_DIGEST_EQUALITY"
}
R["OuterFrameBaselineSourceV12"] = {
  "keys" => [
    "profile_id", "profile", "baseline_frame_references",
    "current_frame_references", "materialized_joins"
  ],
  "field_types_exact" => {
    "profile_id" => "S", "profile" => "REF(FrameBaselineProfileV12)",
    "baseline_frame_references" => "ARRAY(REF_OR_NULL(FrameReferenceV12),3,3,ContextProfileMemberOrderV12)",
    "current_frame_references" => "ARRAY(REF_OR_NULL(FrameReferenceV12),3,3,ContextProfileMemberOrderV12)",
    "materialized_joins" => "REF(FrameBaselineJoinSetV12)"
  },
  "rule" => "profile_id_EXACT_OUTER_CURRENT_START_3_OR_OUTER_CURRENT_PRESPAWN_3;profile_DEEP_EQUALS_THE_FROZEN_PROFILE;EACH_HASH_RECOMPUTES_THE_FULL_SCHEMA_ORDER_FrameReferenceV12_AND_EQUAL_REQUIRES_FULL_TYPED_DEEP_EQUALITY"
}
R["OuterPostfixReplayV12"] = {
  "keys" => ["predicate_id", "definition_sha256", "applicability_result", "assertion_result_or_null", "state_enum", "error"],
  "field_types_exact" => {
    "predicate_id" => "S", "definition_sha256" => "H64",
    "applicability_result" => "REF(EvalValueV12)",
    "assertion_result_or_null" => "REF_OR_NULL(EvalValueV12)", "state_enum" => "ENUM(PredicateEvaluationStateV12)",
    "error" => "REF(ErrorV12)"
  },
  "rule" => "RESULT_OF_EXECUTING_THE_EXACT_HASH_JOINED_CANONICAL_POSTFIX_PROGRAM;NO_HANDWRITTEN_CASE_CLASSIFICATION"
}
R["OuterUnenteredEvidenceSourceV12"] = {
  "keys" => [
    "endpoint_source", "endpoint_replay", "start_raw_observed_bytes_or_null",
    "prefix_raw_observed_bytes_or_null", "journal_slot_sources",
    "artifact_profile_id", "record_chain_profile_id", "frame_bytes_profile_id",
    "operation_profile_id", "root_profile_id", "output_profile_id",
    "admission_baseline_source", "frame_baseline_source", "materialized_input",
    "evidence_replay"
  ],
  "field_types_exact" => {
    "endpoint_source" => "REF(OuterPublicationEndpointInputV12)",
    "endpoint_replay" => "REF(OuterPostfixReplayV12)",
    "start_raw_observed_bytes_or_null" => "REF_OR_NULL(RawBytesV12)",
    "prefix_raw_observed_bytes_or_null" => "REF_OR_NULL(RawBytesV12)",
    "journal_slot_sources" => "ARRAY(OuterJournalSlotSourceV12,7,7,RecordObservationJournalOrderV12)",
    "artifact_profile_id" => "S", "record_chain_profile_id" => "S",
    "frame_bytes_profile_id" => "S", "operation_profile_id" => "S",
    "root_profile_id" => "S", "output_profile_id" => "S",
    "admission_baseline_source" => "REF(OuterAdmissionBaselineSourceV12)",
    "frame_baseline_source" => "REF(OuterFrameBaselineSourceV12)",
    "materialized_input" => "REF(OuterUnenteredEvidencePredicateInputV12)",
    "evidence_replay" => "REF(OuterPostfixReplayV12)"
  },
  "rule" => "EXACT_OUTER_PROFILES_ARTIFACT_NAMESPACE_6_OUTER_FULL_CENSUS_7_OUTER_OBSERVED_0_TO7_OUTER_OPERATION_CENSUS_ROOTS_TEST_A_B_OUTER_CENSUS_FIXED_SEVEN_OUTPUTS_OUTER_DIRECT_START_56_OUTER_CURRENT_START_3;JOURNAL_OPERATION_ROOT_CAPTURE_AND_NAMESPACE_STATES_ARE_ONE_CORRELATED_SNAPSHOT;STRICT_FIXTURE_ROUND_TRIP_AND_RECURSIVE_VALIDATION_PRECEDE_BOTH_LITERAL_POSTFIX_REPLAYS"
}

def v12_outer_v2_split_descriptor(text)
  parts = []
  depth = 0
  start = 0
  text.each_char.with_index do |char, index|
    depth += 1 if char == "("
    depth -= 1 if char == ")"
    if char == "," && depth.zero?
      parts << text[start...index]
      start = index + 1
    end
  end
  parts << text[start..]
  parts
end

def v12_outer_v2_schema(type_id)
  R[type_id] || D[type_id] ||
    J.dig("exact_record_schema_v12", "records", "journal", "body_schemas", type_id)
end

def v12_outer_v2_validate_primitive!(value, descriptor, path)
  nullable = descriptor.end_with?("_OR_NULL")
  return true if nullable && value.nil?
  base = nullable ? descriptor.sub(/_OR_NULL\z/, "") : descriptor
  valid = case base
  when "B" then value == true || value == false
  when "U" then value.is_a?(Integer) && value >= 0
  when "U32" then value.is_a?(Integer) && value.between?(0, 4_294_967_295)
  when "U64" then value.is_a?(Integer) && value.between?(0, 18_446_744_073_709_551_615)
  when "I" then value.is_a?(Integer)
  when "S" then value.is_a?(String) && value.bytes.all? { |byte| byte.between?(0x20, 0x7e) }
  when "H40" then value.is_a?(String) && value.match?(/\A[0-9a-f]{40}\z/)
  when "H64" then value.is_a?(String) && value.match?(/\A[0-9a-f]{64}\z/)
  when "B64"
    value.is_a?(String) && begin
      Base64.strict_encode64(Base64.strict_decode64(value)) == value
    rescue ArgumentError
      false
    end
  when "OCTAL4" then value.is_a?(String) && value.match?(/\A[0-7]{4}\z/)
  when "OCTAL6" then value.is_a?(String) && value.match?(/\A[0-7]{6}\z/)
  else
    false
  end
  raise "outer v2 type #{descriptor} at #{path}: #{value.inspect}" unless valid
  true
end

def v12_outer_v2_validate_type!(value, descriptor, local_schema, path)
  if descriptor.start_with?("REF_OR_NULL(")
    return true if value.nil?
    return v12_outer_v2_validate_schema!(value, descriptor[12...-1], path)
  end
  if descriptor.start_with?("REF(")
    return v12_outer_v2_validate_schema!(value, descriptor[4...-1], path)
  end
  if descriptor.start_with?("TUPLE(")
    return v12_outer_v2_validate_schema!(value, descriptor[6...-1], path)
  end
  if descriptor.start_with?("ENUM(")
    enum_id = descriptor[5...-1]
    domain = X.fetch("enum_domains_v12").fetch(enum_id)
    raise "outer v2 enum #{enum_id} at #{path}" unless domain.include?(value)
    return true
  end
  if descriptor.start_with?("LOCAL_ENUM(")
    key = descriptor[11...-1]
    domain = key.include?(",") ? key.split(",") : local_schema.fetch(key)
    raise "outer v2 local enum #{key} at #{path}" unless domain.include?(value)
    return true
  end
  if descriptor.start_with?("ARRAY(")
    member_type, minimum, maximum, = v12_outer_v2_split_descriptor(descriptor[6...-1])
    raise "outer v2 array at #{path}" unless value.is_a?(Array)
    raise "outer v2 array bound at #{path}: #{value.length}" unless value.length.between?(Integer(minimum, 10), Integer(maximum, 10))
    value.each_with_index { |member, index| v12_outer_v2_validate_type!(member, member_type, local_schema, "#{path}/#{index}") }
    return true
  end
  return v12_outer_v2_validate_schema!(value, descriptor, path) if v12_outer_v2_schema(descriptor)
  v12_outer_v2_validate_primitive!(value, descriptor, path)
end

def v12_outer_v2_validate_schema!(value, type_id, path = "")
  schema = v12_outer_v2_schema(type_id)
  raise "outer v2 missing schema #{type_id} at #{path}" unless schema
  if schema.key?("keys")
    raise "outer v2 object #{type_id} at #{path}" unless value.is_a?(Hash)
    raise "outer v2 keys #{type_id} at #{path}: #{value.keys.inspect}" unless value.keys == schema.fetch("keys")
    field_types = schema.fetch("field_types_exact")
    raise "outer v2 descriptor coverage #{type_id} at #{path}" unless field_types.keys == schema.fetch("keys")
    field_types.each do |key, descriptor|
      v12_outer_v2_validate_type!(value.fetch(key), descriptor, schema, "#{path}/#{key}")
    end
    schema.fetch("constants_exact", {}).each do |key, expected|
      raise "outer v2 constant #{type_id}/#{key}" unless value.fetch(key) == expected
    end
  elsif schema.key?("tuple_fields_exact_order")
    raise "outer v2 tuple #{type_id} at #{path}" unless value.is_a?(Array)
    types = schema.fetch("tuple_field_types_exact")
    raise "outer v2 tuple descriptor coverage #{type_id} at #{path}" unless schema.fetch("tuple_fields_exact_order").length == types.length
    raise "outer v2 tuple width #{type_id} at #{path}" unless value.length == types.length
    types.each_with_index { |descriptor, index| v12_outer_v2_validate_type!(value.fetch(index), descriptor, schema, "#{path}/#{index}") }
  else
    raise "outer v2 unsupported schema #{type_id}"
  end
  v12_outer_v2_validate_semantics!(value, type_id, path)
  true
end

def v12_outer_v2_validate_semantics!(value, type_id, path)
  case type_id
  when "RawBytesV12"
    bytes = Base64.strict_decode64(value.fetch("base64"))
    raise "outer v2 raw length #{path}" unless bytes.bytesize == value.fetch("bytes_uint")
    raise "outer v2 raw hash #{path}" unless sha(bytes) == value.fetch("sha256")
    display = bytes.bytes.all? { |byte| byte.between?(0x20, 0x7e) } ? bytes : nil
    raise "outer v2 raw display #{path}" unless value.fetch("ascii_display_or_null") == display
  when "ErrorV12"
    if value.fetch("state_enum") == "NONE"
      raise "outer v2 NONE error payload #{path}" unless value.values_at(*value.keys.drop(1)).all?(&:nil?)
    end
    triple = value.values_at("message_base64_or_null", "message_bytes_uint_or_null", "message_sha256_or_null")
    unless triple.all?(&:nil?)
      raise "outer v2 partial error triple #{path}" if triple.any?(&:nil?)
      bytes = Base64.strict_decode64(triple.fetch(0))
      raise "outer v2 error length/hash #{path}" unless bytes.bytesize == triple.fetch(1) && sha(bytes) == triple.fetch(2)
    end
  when "ArtifactSlotV12"
    raise "outer v2 staging count #{path}" unless value.fetch("staging_match_count_uint") == value.fetch("staging_leaves").length
    raise "outer v2 slot scan #{path}" unless value.fetch("scan_complete_bool") == !%w[SCAN_OVERFLOW SCAN_ERROR].include?(value.fetch("staging_state_enum"))
  when "ContentAdmissionV12"
    if value.fetch("read_enum") == "COMPLETE"
      raise "outer v2 content complete triples #{path}" unless value.fetch("sample_bytes_uint") == value.fetch("complete_bytes_uint_or_null") && value.fetch("sample_lf_count_uint") == value.fetch("complete_lf_count_uint_or_null") && value.fetch("sample_sha256_or_null") == value.fetch("complete_sha256_or_null")
    end
    if value.fetch("join_enum") == "JOINED"
      vnodes = value.values_at("pre_vnode_or_null", "post_vnode_or_null", "named_vnode_or_null")
      raise "outer v2 content vnode join #{path}" unless vnodes.all? && vnodes.uniq.length == 1 && value.fetch("held_stable_bool_or_null") == true && value.fetch("named_join_bool_or_null") == true
    end
  when "FrameReferenceV12"
    raise "outer v2 frame ref LF #{path}" unless value.fetch("lf_count_uint") == 1
    raise "outer v2 frame ref vnode size #{path}" unless value.dig("vnode", "size_uint") == value.fetch("bytes_uint")
  when "RecordFrameBytesV12"
    ref = value.fetch("frame_reference")
    content = value.fetch("content_admission")
    raise "outer v2 frame bytes duplicate fields #{path}" unless value.fetch("bytes_uint") == ref.fetch("bytes_uint") && value.fetch("lf_count_uint") == ref.fetch("lf_count_uint") && value.fetch("complete_frame_sha256") == ref.fetch("complete_frame_sha256")
    raise "outer v2 frame content join #{path}" unless content.fetch("complete_bytes_uint_or_null") == value.fetch("bytes_uint") && content.fetch("complete_lf_count_uint_or_null") == value.fetch("lf_count_uint") && content.fetch("complete_sha256_or_null") == value.fetch("complete_frame_sha256")
  when "ArtifactSlotSetV12"
    raise "outer v2 slot set count #{path}" unless value.fetch("observed_count_uint") == value.fetch("slots").length
  when "RecordChainV12"
    raise "outer v2 chain count #{path}" unless value.fetch("observed_count_uint") == value.fetch("observations").length && value.fetch("valid_frame_count_uint") == value.fetch("valid_frames").length
  when "OutputObservationSetV12"
    raise "outer v2 output count #{path}" unless value.fetch("observed_count_uint") == value.fetch("rows").length
  when "AdmissionBaselineJoinSetV12", "FrameBaselineJoinSetV12"
    raise "outer v2 join count #{path}" unless value.fetch("observed_count_uint") == value.fetch("rows").length
  when "OuterJournalFrameSourceV12"
    v12_outer_v2_validate_journal_frame_source!(value, path)
  when "OuterJournalSlotSourceV12"
    v12_outer_v2_validate_journal_slot_source!(value, path)
  when "OuterAdmissionBaselineSourceV12"
    v12_outer_v2_validate_admission_baseline_source!(value, path)
  when "OuterFrameBaselineSourceV12"
    v12_outer_v2_validate_frame_baseline_source!(value, path)
  when "OuterUnenteredEvidenceSourceV12"
    v12_outer_v2_validate_outer_source_profiles!(value, path)
  end
end

def v12_outer_v2_validate_journal_slot_source!(source, path)
  observation = source.fetch("record_observation")
  raw = source.fetch("raw_observed_bytes_or_null")
  frame_bytes = source.fetch("record_frame_bytes_or_null")
  if observation.fetch("state_enum") == "ABSENT"
    raise "outer v2 absent slot retained bytes #{path}" unless raw.nil? && frame_bytes.nil? && observation.fetch("frame_reference_or_null").nil?
  elsif observation.fetch("state_enum") == "FINAL_PRESENT" && observation.fetch("parse_state_enum") == "VALID"
    raise "outer v2 valid slot missing raw/frame bytes #{path}" unless raw && frame_bytes
    v12_outer_v2_validate_journal_frame_source!({
      "ordinal_uint" => source.fetch("ordinal_uint"),
      "raw_complete_frame" => raw,
      "record_observation" => observation,
      "record_frame_bytes" => frame_bytes
    }, path)
  else
    raise "outer v2 invalid slot projected frame #{path}" unless frame_bytes.nil? && observation.fetch("frame_reference_or_null").nil?
    if observation.dig("content", "read_enum") == "COMPLETE"
      raise "outer v2 complete malformed slot dropped raw bytes #{path}" unless raw
      decoded = Base64.strict_decode64(raw.fetch("base64"))
      raise "outer v2 malformed slot raw length/hash join #{path}" unless observation.dig("content", "complete_bytes_uint_or_null") == decoded.bytesize && observation.dig("content", "complete_sha256_or_null") == sha(decoded)
    else
      raise "outer v2 unavailable slot invented raw bytes #{path}" unless raw.nil?
    end
  end
end

def v12_outer_v2_decode_fixture!(fixture, expected_type = nil)
  raise "outer v2 fixture type" if expected_type && fixture.fetch("type_id") != expected_type
  bytes = Base64.strict_decode64(fixture.fetch("canonical_json_base64"))
  raise "outer v2 fixture length #{fixture.fetch("fixture_id")}" unless bytes.bytesize == fixture.fetch("bytes_uint")
  raise "outer v2 fixture hash #{fixture.fetch("fixture_id")}" unless sha(bytes) == fixture.fetch("sha256")
  value = JSON.parse(bytes)
  raise "outer v2 fixture noncanonical #{fixture.fetch("fixture_id")}" unless canon(value) == bytes
  v12_outer_v2_validate_schema!(value, fixture.fetch("type_id"), "/fixture/#{fixture.fetch("fixture_id")}")
  value
rescue ArgumentError, JSON::ParserError => error
  raise "outer v2 fixture decode #{fixture.fetch("fixture_id")}: #{error.class}: #{error.message}"
end

def v12_outer_v2_pointer(root, pointer)
  return root if pointer == "" || pointer == "/"
  pointer.split("/", -1).drop(1).reduce(root) do |value, token|
    key = token.gsub("~1", "/").gsub("~0", "~")
    value.is_a?(Array) ? value.fetch(Integer(key, 10)) : value.fetch(key)
  end
end

def v12_outer_v2_truth_and(values)
  return false if values.include?(false)
  return :unknown if values.include?(:unknown)
  true
end

def v12_outer_v2_truth_or(values)
  return true if values.include?(true)
  return :unknown if values.include?(:unknown)
  false
end

def v12_outer_v2_execute_postfix!(predicate_id, program_enum, program, source, predicate_resolver:, custom_resolver:)
  stack = []
  trace = []
  program.each_with_index do |token, ordinal|
    op = token.fetch(0)
    case op
    when "BOOL", "STRING", "UINT"
      stack << token.fetch(1)
    when "GET"
      raise "outer v2 non-SELF GET #{token.inspect}" unless token.fetch(1) == "SELF"
      stack << v12_outer_v2_pointer(source, token.fetch(2))
    when "SCHEMA_VALID"
      candidate = stack.pop
      begin
        v12_outer_v2_validate_type!(candidate, token.fetch(1), {}, "/postfix/#{predicate_id}/#{program_enum}/#{ordinal}")
        stack << true
      rescue KeyError, TypeError, ArgumentError, RuntimeError
        stack << false
      end
    when "ARRAY_LENGTH"
      array = stack.pop
      raise "outer v2 ARRAY_LENGTH operand" unless array.is_a?(Array)
      stack << array.length
    when "ARRAY_ANY_MEMBER_EQ", "ARRAY_ALL_MEMBER_EQ"
      pointer = token.fetch(1)
      expected = stack.pop
      array = stack.pop
      raise "outer v2 array member operand" unless array.is_a?(Array)
      values = array.map { |member| v12_outer_v2_pointer(member, pointer) == expected }
      stack << (op == "ARRAY_ANY_MEMBER_EQ" ? values.any? : values.all?)
    when "EQ", "NE"
      right = stack.pop
      left = stack.pop
      equal = left == right
      stack << (op == "EQ" ? equal : !equal)
    when "NOT"
      value = stack.pop
      stack << (value == :unknown ? :unknown : !value)
    when "AND", "OR"
      values = stack.pop(token.fetch(1))
      stack << (op == "AND" ? v12_outer_v2_truth_and(values) : v12_outer_v2_truth_or(values))
    when "PRED"
      stack << predicate_resolver.call(token.fetch(1), source)
    else
      stack << custom_resolver.call(op, source)
    end
    trace << [ordinal, clone(token), stack.length, stack.last]
  end
  raise "outer v2 postfix stack #{predicate_id}/#{program_enum}: #{stack.inspect}" unless stack.length == 1 && [true, false, :unknown].include?(stack.first)
  [stack.first, trace]
end

def v12_outer_v2_predicate_definition(predicate_id)
  definition = (D.fetch("predicate_definitions_v12") + D.fetch("transition_predicate_definitions_v12")).find { |row| row.fetch("predicate_id") == predicate_id }
  raise "outer v2 missing predicate #{predicate_id}" unless definition
  definition
end

def v12_outer_v2_cut_truth(source)
  state = source.dig("controller_process", "state_enum")
  input = {
    "controller_process_state_enum" => state,
    "cut_data_or_null" => clone(source["not_attempted_cut_data_or_null"])
  }
  program = D.dig("custom_operator_programs_v12", "OUTER_NOT_ATTEMPTED_CUT_PROGRAM")
  raise "outer v2 missing canonical cut program" unless program
  required_state = program.fetch("required_process_state_enum")
  if state != required_state
    raise "outer v2 canonical cut other-state nonnull nested input" unless input.fetch("cut_data_or_null").nil?
    raise "outer v2 canonical cut other-state rule" unless program.fetch("other_process_state_requires_null_and_result") == false
    return false
  end
  if input.fetch("cut_data_or_null").nil?
    raise "outer v2 canonical cut required-state null rule" unless program.fetch("required_state_with_null_result") == false
    return false
  end
  catalog = D.fetch("custom_operator_conformance_catalog_v12")
  fixtures = catalog.fetch("fixtures")
  vectors = catalog.fetch("vectors").select { |row| row.fetch("operator_id") == "OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED" }
  matching_fixture_ids = fixtures.select do |fixture|
    fixture.fetch("type_id") == "OuterNotAttemptedCutOperatorInputV12" &&
      fixture.fetch("sha256") == sha(canon(input)) &&
      v12_outer_v2_decode_fixture!(fixture, "OuterNotAttemptedCutOperatorInputV12") == input
  end.map { |fixture| fixture.fetch("fixture_id") }
  matching_vectors = vectors.select do |vector|
    binding = vector.fetch("bindings").find { |row| row.fetch("binding_id") == "NORMALIZED_INPUT" }
    binding && matching_fixture_ids.include?(binding.fetch("fixture_id_or_null"))
  end
  if matching_vectors.empty?
    source_fixture_ids = vectors.each_with_object([]) do |vector, ids|
      binding = vector.fetch("bindings").find { |row| row.fetch("binding_id") == "SOURCE_INSTANCE" }
      ids << binding.fetch("fixture_id_or_null") if binding && binding.fetch("state_enum") == "VALUE"
    end.uniq
    matching_vectors = vectors.select do |vector|
      binding = vector.fetch("bindings").find { |row| row.fetch("binding_id") == "SOURCE_INSTANCE" }
      next false unless binding && source_fixture_ids.include?(binding.fetch("fixture_id_or_null"))
      fixture = fixtures.find { |row| row.fetch("fixture_id") == binding.fetch("fixture_id_or_null") }
      next false unless fixture && fixture.fetch("type_id") == "OuterPublicationEndpointWorkspaceV12"
      workspace = v12_outer_v2_decode_fixture!(fixture, "OuterPublicationEndpointWorkspaceV12")
      v12_outer_v2_project_cut_input(workspace) == input
    end
  end
  raise "V12_OUTER_CARRIER_V2_MISSING_TYPED_DEPENDENCY: no exact content-addressed custom cut binding" if matching_vectors.empty?
  truths = matching_vectors.map do |vector|
    result = vector.fetch("expected_result")
    case result.fetch("state_enum")
    when "VALUE"
      raise "outer v2 cut result type" unless result.fetch("type_id") == "B"
      JSON.parse(Base64.strict_decode64(result.dig("value_or_null", "canonical_json_base64")))
    when "UNAVAILABLE"
      :unknown
    else
      raise "outer v2 cut conformance result #{result.fetch("state_enum")}"
    end
  end.uniq
  raise "outer v2 ambiguous content-addressed custom cut binding #{truths.inspect}" unless truths.length == 1
  truths.fetch(0)
end

def v12_outer_v2_execute_predicate_truth!(predicate_id, source, inherited = {})
  return inherited.fetch(predicate_id) if inherited.key?(predicate_id)
  definition = v12_outer_v2_predicate_definition(predicate_id)
  predicate_resolver = lambda do |nested_id, nested_source|
    v12_outer_v2_execute_predicate_truth!(nested_id, nested_source, inherited)
  end
  custom_resolver = lambda do |operator_id, operator_source|
    case operator_id
    when "OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED"
      v12_outer_v2_cut_truth(operator_source)
    else
      raise "outer v2 unsupported postfix operator #{operator_id}"
    end
  end
  applicability, = v12_outer_v2_execute_postfix!(
    predicate_id, "APPLICABILITY", definition.fetch("applicability_postfix_program"), source,
    predicate_resolver: predicate_resolver, custom_resolver: custom_resolver
  )
  return false if applicability == false
  return :unknown if applicability == :unknown
  assertion, = v12_outer_v2_execute_postfix!(
    predicate_id, "ASSERTION", definition.fetch("assertion_postfix_program"), source,
    predicate_resolver: predicate_resolver, custom_resolver: custom_resolver
  )
  assertion
end

def v12_outer_v2_typed(type_id, value)
  bytes = canon(value)
  {
    "type_id" => type_id, "canonical_json_base64" => Base64.strict_encode64(bytes),
    "bytes_uint" => bytes.bytesize, "sha256" => sha(bytes)
  }
end

def v12_outer_v2_eval_value(truth, unavailable_code = "POSTFIX_INPUT_UNAVAILABLE")
  if truth == true || truth == false
    {
      "state_enum" => "VALUE", "type_id" => "B",
      "value_or_null" => v12_outer_v2_typed("B", truth), "error" => error_none
    }
  else
    {
      "state_enum" => "UNAVAILABLE", "type_id" => "B",
      "value_or_null" => nil, "error" => error_pred(unavailable_code)
    }
  end
end

def v12_outer_v2_replay!(predicate_id, source, inherited = {})
  definition = v12_outer_v2_predicate_definition(predicate_id)
  predicate_resolver = lambda do |nested_id, nested_source|
    inherited.key?(nested_id) ? inherited.fetch(nested_id) : v12_outer_v2_execute_predicate_truth!(nested_id, nested_source, inherited)
  end
  custom_resolver = lambda do |operator_id, operator_source|
    operator_id == "OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED" ? v12_outer_v2_cut_truth(operator_source) : (raise "outer v2 unsupported postfix operator #{operator_id}")
  end
  applicability, = v12_outer_v2_execute_postfix!(
    predicate_id, "APPLICABILITY", definition.fetch("applicability_postfix_program"), source,
    predicate_resolver: predicate_resolver, custom_resolver: custom_resolver
  )
  assertion = nil
  assertion, = v12_outer_v2_execute_postfix!(
    predicate_id, "ASSERTION", definition.fetch("assertion_postfix_program"), source,
    predicate_resolver: predicate_resolver, custom_resolver: custom_resolver
  ) if applicability == true
  state = if applicability == :unknown
    "UNKNOWN"
  elsif applicability == false
    "NOT_APPLICABLE"
  elsif assertion == :unknown
    "UNKNOWN"
  elsif assertion
    "TRUE"
  else
    "FALSE"
  end
  unknown_code = if predicate_id == "OUT_UNENTERED_ENDPOINT_AUTHORIZED"
    "OUTER_ENDPOINT_EVALUATION_UNKNOWN"
  elsif predicate_id == "OUT_UNENTERED_EVIDENCE_CLEAN" && inherited.fetch("OUT_UNENTERED_ENDPOINT_AUTHORIZED", nil) == :unknown
    "OUTER_ENDPOINT_EVALUATION_UNKNOWN"
  else
    "POSTFIX_INPUT_UNAVAILABLE"
  end
  replay_error = state == "UNKNOWN" ? error_pred(unknown_code) : error_none
  {
    "predicate_id" => predicate_id, "definition_sha256" => sha(definition),
    "applicability_result" => v12_outer_v2_eval_value(applicability, unknown_code),
    "assertion_result_or_null" => assertion.nil? ? nil : v12_outer_v2_eval_value(assertion, unknown_code),
    "state_enum" => state, "error" => replay_error
  }
end

def v12_outer_v2_validate_journal_frame_source!(source, path)
  raw = Base64.strict_decode64(source.dig("raw_complete_frame", "base64"))
  raise "outer v2 journal LF #{path}" unless raw.end_with?("\n") && raw.count("\n") == 1
  envelope = JSON.parse(raw.byteslice(0, raw.bytesize - 1))
  raise "outer v2 journal canonical bytes #{path}" unless canon(envelope) + "\n" == raw
  expected_keys = J.dig("journal", "common_keys_exact_ordered")
  raise "outer v2 journal key order #{path}" unless envelope.keys == expected_keys
  raise "outer v2 journal schema #{path}" unless envelope.fetch("schema") == J.dig("journal", "frame_schema")
  leaves = J.dig("journal", "leaves_ordered")
  ordinal = source.fetch("ordinal_uint")
  raise "outer v2 journal ordinal #{path}" unless envelope.fetch("ordinal_zero_based") == ordinal && envelope.fetch("leaf") == leaves.fetch(ordinal)
  raise "outer v2 journal terminal #{path}" unless envelope.fetch("terminal_bool") == (ordinal == 6)
  predigest = envelope.reject { |key, _| key == "payload_sha256" }
  raise "outer v2 journal payload #{path}" unless sha(canon(predigest)) == envelope.fetch("payload_sha256")
  body_type = ordinal.zero? ? "R00" : (ordinal == 6 ? "TERMINAL" : "OPERATION")
  v12_outer_v2_validate_schema!(envelope.fetch("body"), body_type, "#{path}/decoded/body")
  observation = source.fetch("record_observation")
  frame_bytes = source.fetch("record_frame_bytes")
  reference = observation.fetch("frame_reference_or_null")
  raise "outer v2 journal observation #{path}" unless observation.fetch("state_enum") == "FINAL_PRESENT" && observation.fetch("parse_state_enum") == "VALID" && reference
  raise "outer v2 journal frame reference duplicate #{path}" unless frame_bytes.fetch("frame_reference") == reference
  raise "outer v2 journal raw joins #{path}" unless reference.fetch("bytes_uint") == raw.bytesize && reference.fetch("lf_count_uint") == 1 && reference.fetch("complete_frame_sha256") == sha(raw) && reference.fetch("payload_sha256") == envelope.fetch("payload_sha256")
  raise "outer v2 journal path/schema/status #{path}" unless reference.fetch("path").end_with?("/#{envelope.fetch("leaf")}") && reference.fetch("schema") == envelope.fetch("schema") && reference.fetch("status") == envelope.fetch("status")
  raise "outer v2 journal vnode join #{path}" unless observation.dig("slot", "final_vnode_or_null") == reference.fetch("vnode") && observation.dig("content", "pre_vnode_or_null") == reference.fetch("vnode") && observation.dig("content", "post_vnode_or_null") == reference.fetch("vnode") && observation.dig("content", "named_vnode_or_null") == reference.fetch("vnode")
end

def v12_outer_v2_admission_projection(row)
  schema = R.fetch("AdmissionRowV12")
  ordered = schema.fetch("keys").each_with_object({}) { |key, output| output[key] = clone(row.fetch(key)) unless key == "ordinal_uint" }
  canon(ordered)
end

def v12_outer_v2_validate_admission_baseline_source!(source, path)
  profile_id = source.fetch("profile_id")
  raise "outer v2 admission profile id #{path}" unless %w[OUTER_DIRECT_START_56 OUTER_DIRECT_READINESS_56].include?(profile_id)
  profile = S.dig("set_profile_registry_v12", "admission_baseline_joins", "profiles", profile_id)
  raise "outer v2 admission profile value #{path}" unless source.fetch("profile") == profile
  members = S.fetch("admission_member_registry_v12").first(56)
  raise "outer v2 admission members #{path}" unless source.fetch("members") == members
  joins = source.dig("materialized_joins", "rows")
  source.fetch("baseline_rows").zip(source.fetch("current_rows"), joins).each_with_index do |(baseline, current, join), index|
    if baseline.nil? || current.nil?
      raise "outer v2 admission unavailable #{path}/#{index}" unless join.fetch("baseline_projection_sha256_or_null").nil? && join.fetch("current_projection_sha256_or_null").nil? && join.fetch("equal_bool_or_null").nil? && join.fetch("state_enum") == "UNAVAILABLE"
    else
      baseline_projection = v12_outer_v2_admission_projection(baseline)
      current_projection = v12_outer_v2_admission_projection(current)
      raise "outer v2 admission baseline hash #{path}/#{index}" unless join.fetch("baseline_projection_sha256_or_null") == sha(baseline_projection)
      raise "outer v2 admission current hash #{path}/#{index}" unless join.fetch("current_projection_sha256_or_null") == sha(current_projection)
      equal = baseline_projection == current_projection
      raise "outer v2 admission equality #{path}/#{index}" unless join.fetch("equal_bool_or_null") == equal && join.fetch("state_enum") == (equal ? "EQUAL" : "NOT_EQUAL")
    end
  end
end

def v12_outer_v2_validate_frame_baseline_source!(source, path)
  profile_id = source.fetch("profile_id")
  raise "outer v2 frame profile id #{path}" unless %w[OUTER_CURRENT_START_3 OUTER_CURRENT_PRESPAWN_3].include?(profile_id)
  profile = S.dig("set_profile_registry_v12", "frame_baseline_joins", "profiles", profile_id)
  raise "outer v2 frame profile value #{path}" unless source.fetch("profile") == profile
  joins = source.dig("materialized_joins", "rows")
  source.fetch("baseline_frame_references").zip(source.fetch("current_frame_references"), joins).each_with_index do |(baseline, current, join), index|
    if baseline.nil? || current.nil?
      raise "outer v2 frame unavailable #{path}/#{index}" unless join.fetch("baseline_frame_reference_sha256_or_null").nil? && join.fetch("current_frame_reference_sha256_or_null").nil? && join.fetch("equal_bool_or_null").nil? && join.fetch("state_enum") == "UNAVAILABLE"
    else
      baseline_bytes = canon(R.fetch("FrameReferenceV12").fetch("keys").each_with_object({}) { |key, output| output[key] = baseline.fetch(key) })
      current_bytes = canon(R.fetch("FrameReferenceV12").fetch("keys").each_with_object({}) { |key, output| output[key] = current.fetch(key) })
      raise "outer v2 frame baseline hash #{path}/#{index}" unless join.fetch("baseline_frame_reference_sha256_or_null") == sha(baseline_bytes)
      raise "outer v2 frame current hash #{path}/#{index}" unless join.fetch("current_frame_reference_sha256_or_null") == sha(current_bytes)
      equal = baseline == current
      raise "outer v2 frame equality #{path}/#{index}" unless join.fetch("equal_bool_or_null") == equal && join.fetch("state_enum") == (equal ? "EQUAL" : "NOT_EQUAL")
    end
  end
end

def v12_outer_v2_validate_outer_source_profiles!(source, path)
  exact = {
    "artifact_profile_id" => "ARTIFACT_NAMESPACE_6",
    "record_chain_profile_id" => "OUTER_FULL_CENSUS_7",
    "frame_bytes_profile_id" => "OUTER_OBSERVED_0_TO7",
    "operation_profile_id" => "OUTER_OPERATION_CENSUS",
    "root_profile_id" => "ROOTS_TEST_A_B_OUTER_CENSUS",
    "output_profile_id" => "FIXED_SEVEN_OUTPUTS"
  }
  exact.each { |key, value| raise "outer v2 profile #{path}/#{key}" unless source.fetch(key) == value }
  input = source.fetch("materialized_input")
  endpoint_replay = v12_outer_v2_replay!("OUT_UNENTERED_ENDPOINT_AUTHORIZED", source.fetch("endpoint_source"))
  raise "outer v2 endpoint literal replay #{path}" unless source.fetch("endpoint_replay") == endpoint_replay
  raise "outer v2 endpoint evaluation projection #{path}" unless input.fetch("endpoint_authorized_evaluation") == v12_outer_v2_predicate_evaluation(endpoint_replay)
  [["start_record", "start_raw_observed_bytes_or_null"], ["prefix_result", "prefix_raw_observed_bytes_or_null"]].each do |record_key, raw_key|
    record = input.fetch(record_key)
    raw = source.fetch(raw_key)
    if record.fetch("state_enum") == "ABSENT"
      raise "outer v2 absent ancillary raw #{path}/#{record_key}" unless raw.nil?
    elsif record.fetch("state_enum") == "FINAL_PRESENT" && record.fetch("parse_state_enum") != "VALID"
      raise "outer v2 malformed ancillary raw #{path}/#{record_key}" unless raw
      decoded = Base64.strict_decode64(raw.fetch("base64"))
      raise "outer v2 ancillary content join #{path}/#{record_key}" unless record.dig("content", "complete_bytes_uint_or_null") == decoded.bytesize && record.dig("content", "complete_sha256_or_null") == sha(decoded)
    end
  end
  raise "outer v2 admission source join #{path}" unless input.fetch("admission_baseline_joins") == source.dig("admission_baseline_source", "materialized_joins")
  raise "outer v2 frame source join #{path}" unless input.fetch("frame_baseline_joins") == source.dig("frame_baseline_source", "materialized_joins")
  artifact_paths = J.dig("artifact_parent_target_scoped_admission_v12", "final_leaves_exact_ordered").map do |leaf|
    File.join(J.dig("artifact_parent_target_scoped_admission_v12", "parent_path"), leaf)
  end
  raise "outer v2 artifact namespace paths #{path}" unless input.dig("artifact_slots", "slots").map { |slot| slot.fetch("final_path") } == artifact_paths
  raise "outer v2 start artifact correlation #{path}" unless input.dig("artifact_slots", "slots", 2) == input.fetch("start_record").fetch("slot")
  raise "outer v2 prefix artifact correlation #{path}" unless input.dig("artifact_slots", "slots", 3) == input.fetch("prefix_result").fetch("slot")
  slot_sources = source.fetch("journal_slot_sources")
  raise "outer v2 journal source order #{path}" unless slot_sources.map { |row| row.fetch("ordinal_uint") } == (0..6).to_a
  journal_paths = J.dig("journal", "leaves_ordered").map { |leaf| File.join(J.dig("artifact_parent_target_scoped_admission_v12", "parent_path"), leaf) }
  raise "outer v2 journal source paths #{path}" unless slot_sources.map { |row| row.dig("record_observation", "slot", "final_path") } == journal_paths
  valid_sources = slot_sources.select do |row|
    row.dig("record_observation", "state_enum") == "FINAL_PRESENT" &&
      row.dig("record_observation", "parse_state_enum") == "VALID"
  end
  raise "outer v2 journal chain join #{path}" unless input.dig("journal_chain", "observations") == slot_sources.map { |row| row.fetch("record_observation") }
  raise "outer v2 journal valid projection #{path}" unless input.dig("journal_chain", "valid_frames") == valid_sources.map { |row| row.dig("record_observation", "frame_reference_or_null") }
  raise "outer v2 journal byte join #{path}" unless input.dig("journal_frame_bytes", "rows") == valid_sources.map { |row| row.fetch("record_frame_bytes_or_null") }
  operation = input.fetch("operation_prefix_projection")
  expected_operation_labels = J.fetch("swiftpm_operations_ordered").map { |row| row.fetch("label") }
  expected_operation_leaves = J.dig("journal", "leaves_ordered")[1, 5]
  raise "outer v2 operation profile #{path}" unless operation.fetch("rows").map { |row| row.fetch("label") } == expected_operation_labels && operation.fetch("rows").map { |row| row.fetch("leaf") } == expected_operation_leaves
  operation_refs = operation.fetch("rows").select { |row| row.fetch("observation_state_enum") == "VALID_FINAL" }.map { |row| row.fetch("frame_reference_or_null") }
  raise "outer v2 operation ref projection #{path}" unless operation.fetch("valid_frame_refs") == operation_refs
  first_operation_state = operation.dig("rows", 0, "observation_state_enum")
  first_operation_slot = slot_sources.fetch(1)
  if first_operation_state == "INVALID"
    raise "outer v2 invalid operation observation correlation #{path}" unless first_operation_slot.dig("record_observation", "state_enum") == "FINAL_PRESENT" && first_operation_slot.dig("record_observation", "parse_state_enum") == "MALFORMED" && first_operation_slot.fetch("raw_observed_bytes_or_null")
  elsif first_operation_state == "UNAVAILABLE"
    slot = first_operation_slot.dig("record_observation", "slot")
    raise "outer v2 unavailable operation observation correlation #{path}" unless slot.fetch("final_state_enum") == "FSTATAT_FAILED" || slot.fetch("staging_state_enum") == "SCAN_ERROR"
  end
  root_set = input.fetch("root_traversals")
  raise "outer v2 root labels/paths #{path}" unless root_set.fetch("roots").map { |row| row.values_at("label", "path") } == %w[TEST A B].zip(J.dig("roots", "creation_order"))
  output_set = input.fetch("fixed_output_observations")
  output_labels = X.dig("fixed_array_orders", "outputs")
  raise "outer v2 output labels/paths #{path}" unless output_set.fetch("rows").map { |row| row.values_at("label", "path") } == output_labels.map { |label| [label, J.fetch("fixed_output_handoff_paths").fetch(label)] }
  valid_operations = input.dig("operation_prefix_projection", "rows").count { |row| row.fetch("observation_state_enum") == "VALID_FINAL" }
  raise "outer v2 capture count correlation #{path}" unless input.dig("root_traversals", "current_entered_capture_census", "expected_count_uint") == valid_operations * 2
  endpoint_truth = case endpoint_replay.fetch("state_enum")
  when "TRUE" then true
  when "FALSE", "NOT_APPLICABLE" then false
  when "UNKNOWN" then :unknown
  else raise "outer v2 endpoint replay state #{path}"
  end
  evidence_replay = v12_outer_v2_replay!("OUT_UNENTERED_EVIDENCE_CLEAN", input, {"OUT_UNENTERED_ENDPOINT_AUTHORIZED" => endpoint_truth})
  raise "outer v2 evidence literal replay #{path}" unless source.fetch("evidence_replay") == evidence_replay
end

def v12_outer_v2_raw_bytes(bytes)
  {
    "base64" => Base64.strict_encode64(bytes), "bytes_uint" => bytes.bytesize,
    "sha256" => sha(bytes),
    "ascii_display_or_null" => bytes.bytes.all? { |byte| byte.between?(0x20, 0x7e) } ? bytes : nil
  }
end

def v12_outer_v2_vnode(kind, tag, size = 0)
  digest = sha("outer-v2-vnode|#{tag}")
  {
    "type_enum" => kind, "device_uint" => 12_019,
    "inode_uint" => digest[0, 15].to_i(16), "generation_uint" => digest[15, 8].to_i(16),
    "uid_uint" => 501, "gid_uint" => 20,
    "mode_octal4" => kind == "DIRECTORY" ? "0700" : (kind == "SYMLINK" ? "0777" : "0400"),
    "nlink_uint" => kind == "DIRECTORY" ? 2 : 1, "flags_uint" => 0,
    "size_uint" => size, "ctime_seconds_int" => 0, "ctime_nanoseconds_uint" => 0,
    "mtime_seconds_int" => 0, "mtime_nanoseconds_uint" => 0
  }
end

def v12_outer_v2_inventory_name(name)
  {
    "raw_hex" => name.b.unpack1("H*"),
    "utf8_display_or_null" => name.bytes.all? { |byte| byte.between?(0x20, 0x7e) } ? name : nil
  }
end

def v12_outer_v2_inventory(state, names = [], error = error_none)
  cap = 4096
  {
    "state_enum" => state, "cap_entries_uint" => cap,
    "observed_names" => clone(names), "observed_count_uint" => names.length,
    "total_count_uint_or_null" => state == "COMPLETE" ? names.length : nil,
    "overflow_witness_bool_or_null" => state == "COMPLETE" ? false : nil,
    "error" => clone(error)
  }
end

def v12_outer_v2_content_for_frame(vnode, bytes, cap_bytes: 4096)
  digest = sha(bytes)
  {
    "presence_enum" => "PRESENT", "read_enum" => "COMPLETE", "join_enum" => "JOINED",
    "cap_bytes_uint" => cap_bytes, "pre_vnode_or_null" => clone(vnode),
    "sample_bytes_uint" => bytes.bytesize, "sample_lf_count_uint" => bytes.count("\n"),
    "sample_sha256_or_null" => digest, "eof_observed_bool_or_null" => true,
    "overflow_witness_bool_or_null" => false, "complete_bytes_uint_or_null" => bytes.bytesize,
    "complete_lf_count_uint_or_null" => bytes.count("\n"), "complete_sha256_or_null" => digest,
    "post_vnode_or_null" => clone(vnode), "named_vnode_or_null" => clone(vnode),
    "held_stable_bool_or_null" => true, "named_join_bool_or_null" => true,
    "error" => error_none
  }
end

def v12_outer_v2_absent_content(cap_bytes: 4096)
  {
    "presence_enum" => "ABSENT", "read_enum" => "NOT_ATTEMPTED", "join_enum" => "NOT_ATTEMPTED",
    "cap_bytes_uint" => cap_bytes, "pre_vnode_or_null" => nil,
    "sample_bytes_uint" => 0, "sample_lf_count_uint" => 0, "sample_sha256_or_null" => nil,
    "eof_observed_bool_or_null" => nil, "overflow_witness_bool_or_null" => nil,
    "complete_bytes_uint_or_null" => nil, "complete_lf_count_uint_or_null" => nil,
    "complete_sha256_or_null" => nil, "post_vnode_or_null" => nil,
    "named_vnode_or_null" => nil, "held_stable_bool_or_null" => nil,
    "named_join_bool_or_null" => nil, "error" => error_none
  }
end

def v12_outer_v2_slot(path, final_state: "ABSENT", vnode: nil, staging_state: "NONE", staging_leaves: [], error: error_none)
  leaf = File.basename(path)
  {
    "final_path" => path, "staging_pattern" => ".#{leaf}.XXXXXX.staging",
    "final_state_enum" => final_state, "final_vnode_or_null" => clone(vnode),
    "staging_state_enum" => staging_state, "staging_leaves" => clone(staging_leaves),
    "staging_match_count_uint" => staging_leaves.length,
    "scan_complete_bool" => !%w[SCAN_OVERFLOW SCAN_ERROR].include?(staging_state),
    "error" => clone(error)
  }
end

def v12_outer_v2_absent_record(path)
  {
    "state_enum" => "ABSENT", "slot" => v12_outer_v2_slot(path),
    "content" => v12_outer_v2_absent_content, "parse_state_enum" => "NOT_ATTEMPTED",
    "frame_reference_or_null" => nil, "error" => error_none
  }
end

def v12_outer_v2_failed_record(path, axis, code)
  error = mechanics_error(code)
  slot = case axis
  when "FSTATAT_FAILED"
    v12_outer_v2_slot(path, final_state: "FSTATAT_FAILED", error: error)
  when "SCAN_ERROR"
    v12_outer_v2_slot(path, staging_state: "SCAN_ERROR", error: error)
  else
    raise "outer v2 failed record axis #{axis}"
  end
  {
    "state_enum" => axis == "FSTATAT_FAILED" ? "FINAL_WRONG_TYPE" : "STAGING_PRESENT",
    "slot" => slot, "content" => v12_outer_v2_absent_content,
    "parse_state_enum" => "NOT_ATTEMPTED", "frame_reference_or_null" => nil,
    "error" => clone(error)
  }
end

def v12_outer_v2_malformed_record(path, tag, bytes)
  error = mechanics_error("MALFORMED_OBSERVED_RECORD:#{tag}")
  vnode = v12_outer_v2_vnode("REGULAR", tag, bytes.bytesize)
  content = v12_outer_v2_content_for_frame(
    vnode, bytes, cap_bytes: J.dig("journal", "maximum_bytes_per_frame")
  )
  record = {
    "state_enum" => "FINAL_PRESENT",
    "slot" => v12_outer_v2_slot(path, final_state: "PRESENT_REGULAR", vnode: vnode),
    "content" => content, "parse_state_enum" => "MALFORMED",
    "frame_reference_or_null" => nil, "error" => clone(error)
  }
  [record, v12_outer_v2_raw_bytes(bytes)]
end

def v12_outer_v2_slot_source(ordinal, record, raw = nil)
  {
    "ordinal_uint" => ordinal, "raw_observed_bytes_or_null" => clone(raw),
    "record_observation" => clone(record), "record_frame_bytes_or_null" => nil
  }
end

def v12_outer_v2_absent_slot_sources(paths)
  paths.each_with_index.map { |path, ordinal| v12_outer_v2_slot_source(ordinal, v12_outer_v2_absent_record(path)) }
end

def v12_outer_v2_journal_projection(slot_sources, frame_complete: true, frame_error: error_none)
  observations = slot_sources.map { |row| clone(row.fetch("record_observation")) }
  valid = slot_sources.select { |row| row.fetch("record_frame_bytes_or_null") }.map { |row| clone(row.fetch("record_frame_bytes_or_null")) }
  chain_complete = observations.none? do |row|
    %w[FSTATAT_FAILED].include?(row.dig("slot", "final_state_enum")) ||
      %w[SCAN_ERROR].include?(row.dig("slot", "staging_state_enum"))
  end
  chain_error = chain_complete ? error_none : mechanics_error("JOURNAL_OBSERVATION_UNAVAILABLE")
  chain = {
    "label" => "OUTER_JOURNAL_CHAIN", "profile_enum" => "OUTER_FULL_CENSUS_7",
    "observations" => observations, "observed_count_uint" => 7,
    "valid_frames" => valid.map { |row| clone(row.fetch("frame_reference")) },
    "valid_frame_count_uint" => valid.length, "complete_bool" => chain_complete,
    "integrity_bool" => false,
    "terminal_frame_present_bool" => !observations.fetch(6).fetch("frame_reference_or_null").nil?,
    "error" => chain_error
  }
  frame_set = {
    "profile_enum" => "OUTER_OBSERVED_0_TO7", "rows" => valid,
    "complete_bool" => frame_complete, "error" => clone(frame_error)
  }
  [chain, frame_set]
end

def v12_outer_v2_operation_projection(state = "ABSENT")
  labels = J.fetch("swiftpm_operations_ordered").map { |row| row.fetch("label") }
  leaves = J.dig("journal", "leaves_ordered")[1, 5]
  states = [state] + Array.new(4, "ABSENT")
  rows = states.each_with_index.map do |row_state, index|
    row_error = %w[INVALID UNAVAILABLE].include?(row_state) ? mechanics_error("OPERATION_#{row_state}") : error_none
    {
      "ordinal_uint" => index, "label" => labels.fetch(index), "leaf" => leaves.fetch(index),
      "observation_state_enum" => row_state, "process_state_enum_or_null" => nil,
      "frame_reference_or_null" => nil, "error" => row_error
    }
  end
  unavailable = state == "UNAVAILABLE"
  {
    "rows" => rows, "valid_prefix_count_uint" => 0, "valid_frame_refs" => [],
    "missing_expected_frames" => clone(leaves),
    "first_unentered" => {
      "present_bool" => true, "operation_label_or_null" => labels.fetch(0),
      "reason_predicate_id_or_null" => state == "ABSENT" ? "J_R00_FAILURE_CHAIN" : "J_OPERATION_EVIDENCE_COMPLETE"
    },
    "hole_detected_bool" => false, "integrity_bool" => state == "ABSENT",
    "complete_bool" => !unavailable,
    "error" => unavailable ? mechanics_error("OPERATION_UNAVAILABLE") : error_none
  }
end

def v12_outer_v2_namespace(role, allowed)
  {
    "role_enum" => role, "required_names" => [], "allowed_names" => clone(allowed),
    "observed_names" => [], "missing_required_names" => [], "unexpected_names" => [],
    "retained_residual_names" => [], "nonconforming_names" => [],
    "classification_complete_bool" => true, "integrity_bool" => true,
    "error" => error_none
  }
end

def v12_outer_v2_root_child(path, leaf, state: "ROOT_ABSENT")
  state_enum, join_state, inventory_state, row_error = case state
  when "ROOT_ABSENT"
    ["NOT_TRAVERSED_ROOT_ABSENT", "ABSENT", "NOT_REQUESTED", error_none]
  when "ABSENT"
    ["ABSENT", "ABSENT", "NOT_REQUESTED", error_none]
  when "PRESENT"
    ["PRESENT_DIRECTORY", "JOINED", "COMPLETE", error_none]
  when "ROOT_INVALID"
    error = mechanics_error("ROOT_CHILD_NOT_TRAVERSED_ROOT_INVALID")
    ["NOT_TRAVERSED_ROOT_INVALID", "NOT_REQUESTED", "NOT_REQUESTED", error]
  else
    raise "outer v2 root child state #{state}"
  end
  {
    "leaf" => leaf,
    "state_enum" => state_enum,
    "join" => join_state == "JOINED" ? mechanics_named_join(path, join_state, "DIRECTORY", 190_000 + path.bytes.sum) : mechanics_named_join(path, join_state, "DIRECTORY"),
    "inventory" => v12_outer_v2_inventory(inventory_state),
    "error" => row_error
  }
end

def v12_outer_v2_root(label, path, absent: true)
  children = J.dig("roots", "children_exact_sorted").map do |leaf|
    v12_outer_v2_root_child("#{path}/#{leaf}", leaf, state: absent ? "ROOT_ABSENT" : "PRESENT")
  end
  {
    "label" => label, "path" => path,
    "state_enum" => absent ? "ABSENT" : "PRESENT_DIRECTORY_COMPLETE",
    "root_join" => absent ? mechanics_named_join(path, "ABSENT", "DIRECTORY") : mechanics_named_join(path, "JOINED", "DIRECTORY", 200_000 + path.bytes.sum),
    "root_inventory" => absent ? v12_outer_v2_inventory("NOT_REQUESTED") : v12_outer_v2_inventory("COMPLETE", J.dig("roots", "children_exact_sorted").map { |name| v12_outer_v2_inventory_name(name) }.sort_by { |row| row.fetch("raw_hex") }),
    "children" => children,
    "journal" => v12_outer_v2_root_child("#{path}/captures/journal", "journal", state: absent ? "ROOT_ABSENT" : "ABSENT"),
    "unexpected_names" => [],
    "explanation_enum" => absent ? "UNENTERED_EXPECTED_ABSENCE" : "COMPLETE_EXPECTED_TOPOLOGY",
    "error" => error_none
  }
end

def v12_outer_v2_root_set(present_label = nil)
  operations = J.fetch("swiftpm_operations_ordered")
  allowed_by_root = %w[TEST A B].to_h do |label|
    names = operations.select { |row| row.fetch("root") == label }.flat_map do |row|
      [File.basename(row.fetch("stdout_leaf")), File.basename(row.fetch("stderr_leaf"))]
    end
    names << "journal" if label == "TEST"
    [label, names.map { |name| v12_outer_v2_inventory_name(name) }.sort_by { |row| row.fetch("raw_hex") }]
  end
  journal_allowed = J.dig("journal", "leaves_ordered").map { |name| v12_outer_v2_inventory_name(name) }.sort_by { |row| row.fetch("raw_hex") }
  roots = %w[TEST A B].each_with_index.map do |label, index|
    v12_outer_v2_root(label, J.dig("roots", "creation_order").fetch(index), absent: label != present_label)
  end
  {
    "roots" => roots,
    "namespace_assessments" => [
      v12_outer_v2_namespace("TEST_CAPTURES", allowed_by_root.fetch("TEST")),
      v12_outer_v2_namespace("A_CAPTURES", allowed_by_root.fetch("A")),
      v12_outer_v2_namespace("B_CAPTURES", allowed_by_root.fetch("B")),
      v12_outer_v2_namespace("TEST_JOURNAL", journal_allowed)
    ],
    "current_entered_capture_census" => {
      "expected_count_uint" => 0, "rows" => [], "observed_count_uint" => 0,
      "complete_bool" => true, "error" => error_none
    },
    "complete_bool" => true, "error" => error_none
  }
end

def v12_outer_v2_failed_root(label, path)
  error = mechanics_error("ROOT_OPEN_FAILED")
  children = J.dig("roots", "children_exact_sorted").map do |leaf|
    v12_outer_v2_root_child("#{path}/#{leaf}", leaf, state: "ROOT_INVALID")
  end
  {
    "label" => label, "path" => path, "state_enum" => "OPEN_FAILED",
    "root_join" => mechanics_named_join(path, "OPEN_FAILED", "DIRECTORY", 210_000 + path.bytes.sum, error),
    "root_inventory" => v12_outer_v2_inventory("NOT_REQUESTED"),
    "children" => children,
    "journal" => v12_outer_v2_root_child("#{path}/captures/journal", "journal", state: "ROOT_INVALID"),
    "unexpected_names" => [], "explanation_enum" => "INVALID_OBSERVATION",
    "error" => clone(error)
  }
end

def v12_outer_v2_failed_root_set
  set = v12_outer_v2_root_set
  set.fetch("roots")[0] = v12_outer_v2_failed_root("TEST", J.dig("roots", "creation_order").fetch(0))
  set["complete_bool"] = false
  set["error"] = mechanics_error("ROOT_OPEN_FAILED")
  set
end

def v12_outer_v2_output_set
  order = X.dig("fixed_array_orders", "outputs")
  paths = J.fetch("fixed_output_handoff_paths")
  rows = order.map do |label|
    {"label" => label, "path" => paths.fetch(label), "state_enum" => "ABSENT", "vnode_or_null" => nil, "error" => error_none}
  end
  {"rows" => rows, "observed_count_uint" => 7, "complete_bool" => true, "error" => error_none}
end

def v12_outer_v2_artifact_set(_endpoint_source)
  leaves = J.dig("artifact_parent_target_scoped_admission_v12", "final_leaves_exact_ordered")
  parent = J.dig("artifact_parent_target_scoped_admission_v12", "parent_path")
  slots = leaves.map { |leaf| v12_outer_v2_slot(File.join(parent, leaf)) }
  {"label" => "OUTER_ARTIFACT_NAMESPACE", "expected_count_uint" => 6, "slots" => slots, "observed_count_uint" => 6, "complete_bool" => true, "error" => error_none}
end

def v12_outer_v2_profile_pointer(profile, side, ordinal)
  segment = profile.fetch(side).find { |row| ordinal >= row.fetch(0) && ordinal < row.fetch(0) + row.fetch(1) }
  raise "outer v2 missing #{side} segment #{ordinal}" unless segment
  [segment.fetch(2), "#{segment.fetch(3)}#{ordinal - segment.fetch(4)}"]
end

def v12_outer_v2_admission_row(member, members)
  ordinal, role, path, kind, cap, target, _target_role, policy = member
  vnode = v12_outer_v2_vnode(kind, "admission|#{ordinal}|#{role}", 0)
  content = nil
  inventory = nil
  symlink = nil
  readlink_cap = nil
  if kind == "REGULAR"
    content = v12_outer_v2_content_for_frame(vnode, "", cap_bytes: cap)
  elsif kind == "DIRECTORY" && policy == "HELD_DIRECTORY_EXACT_IMMEDIATE_INVENTORY"
    names = members.select { |candidate| File.dirname(candidate.fetch(2)) == path }.map { |candidate| File.basename(candidate.fetch(2)) }.uniq
    inventory = v12_outer_v2_inventory("COMPLETE", names.map { |name| v12_outer_v2_inventory_name(name) }.sort_by { |row| row.fetch("raw_hex") })
  elsif kind == "DIRECTORY"
    inventory = v12_outer_v2_inventory("NOT_REQUESTED")
  elsif kind == "SYMLINK"
    symlink = clone(target)
    readlink_cap = 1024
  end
  {
    "ordinal_uint" => ordinal, "role" => role, "path" => path,
    "admission_policy_enum" => policy, "observation_state_enum" => "PRESENT_ADMITTED",
    "kind_enum_or_null" => kind, "hash_cap_bytes_or_null" => kind == "REGULAR" ? cap : nil,
    "readlink_cap_bytes_or_null" => readlink_cap, "identity_or_null" => clone(vnode),
    "content_or_null" => content, "symlink_target_or_null" => symlink,
    "inventory_or_null" => inventory,
    "named_join" => mechanics_named_join(path, "JOINED", kind, vnode.fetch("inode_uint")).merge(
      "held_before_or_null" => clone(vnode), "held_after_or_null" => clone(vnode), "named_after_or_null" => clone(vnode)
    ),
    "failure_phase_enum_or_null" => nil, "error" => error_none
  }
end

def v12_outer_v2_shift_admission_row(row)
  shifted = clone(row)
  shifted["identity_or_null"]["inode_uint"] += 1
  shifted.fetch("named_join").values_at("held_before_or_null", "held_after_or_null", "named_after_or_null").each { |vnode| vnode["inode_uint"] += 1 }
  if shifted.fetch("content_or_null")
    shifted.fetch("content_or_null").values_at("pre_vnode_or_null", "post_vnode_or_null", "named_vnode_or_null").each { |vnode| vnode["inode_uint"] += 1 }
  end
  shifted
end

def v12_outer_v2_admission_baseline_source(case_state = "EQUAL")
  profile_id = "OUTER_DIRECT_READINESS_56"
  profile = clone(S.dig("set_profile_registry_v12", "admission_baseline_joins", "profiles", profile_id))
  members = clone(S.fetch("admission_member_registry_v12").first(56))
  baseline = members.map { |member| v12_outer_v2_admission_row(member, members) }
  current = clone(baseline)
  current[0] = v12_outer_v2_shift_admission_row(current.fetch(0)) if case_state == "NOT_EQUAL"
  current[0] = nil if case_state == "UNAVAILABLE"
  rows = members.each_with_index.map do |member, ordinal|
    baseline_source, baseline_pointer = v12_outer_v2_profile_pointer(profile, "baseline_segments_exact_order", ordinal)
    current_source, current_pointer = v12_outer_v2_profile_pointer(profile, "current_segments_exact_order", ordinal)
    left = baseline.fetch(ordinal)
    right = current.fetch(ordinal)
    if right.nil?
      state = "UNAVAILABLE"
      left_hash = right_hash = equal = nil
      row_error = mechanics_error("ADMISSION_BASELINE_UNAVAILABLE")
    else
      left_hash = sha(v12_outer_v2_admission_projection(left))
      right_hash = sha(v12_outer_v2_admission_projection(right))
      equal = left == right
      state = equal ? "EQUAL" : "NOT_EQUAL"
      row_error = equal ? error_none : mechanics_error("ADMISSION_BASELINE_NOT_EQUAL")
    end
    {
      "join_id" => format("%02d:%s", ordinal, member.fetch(1)), "role" => member.fetch(1),
      "baseline_source_id" => baseline_source, "baseline_json_pointer" => baseline_pointer,
      "current_source_id" => current_source, "current_json_pointer" => current_pointer,
      "baseline_projection_sha256_or_null" => left_hash,
      "current_projection_sha256_or_null" => right_hash,
      "state_enum" => state, "equal_bool_or_null" => equal, "error" => row_error
    }
  end
  all_equal = rows.all? { |row| row.fetch("state_enum") == "EQUAL" }
  set_error = all_equal ? error_none : mechanics_error("ADMISSION_BASELINE_SET_#{case_state}")
  {
    "profile_id" => profile_id, "profile" => profile, "members" => members,
    "baseline_rows" => baseline, "current_rows" => current,
    "materialized_joins" => {
      "expected_count_uint" => 56, "rows" => rows, "observed_count_uint" => 56,
      "all_equal_bool" => all_equal, "complete_bool" => all_equal, "error" => set_error
    }
  }
end

def v12_outer_v2_frame_baseline_source(frame_refs, case_state = "EQUAL")
  profile_id = "OUTER_CURRENT_PRESPAWN_3"
  profile = clone(S.dig("set_profile_registry_v12", "frame_baseline_joins", "profiles", profile_id))
  baseline = clone(frame_refs)
  current = clone(frame_refs)
  current[0]["vnode"]["inode_uint"] += 1 if case_state == "NOT_EQUAL"
  current[0] = nil if case_state == "UNAVAILABLE"
  rows = profile.fetch("rows_exact_order").each_with_index.map do |profile_row, index|
    left = baseline.fetch(index)
    right = current.fetch(index)
    if right.nil?
      state = "UNAVAILABLE"
      left_hash = right_hash = equal = nil
      row_error = mechanics_error("FRAME_BASELINE_UNAVAILABLE")
    else
      left_hash = sha(canon(R.fetch("FrameReferenceV12").fetch("keys").each_with_object({}) { |key, output| output[key] = left.fetch(key) }))
      right_hash = sha(canon(R.fetch("FrameReferenceV12").fetch("keys").each_with_object({}) { |key, output| output[key] = right.fetch(key) }))
      equal = left == right
      state = equal ? "EQUAL" : "NOT_EQUAL"
      row_error = equal ? error_none : mechanics_error("FRAME_BASELINE_NOT_EQUAL")
    end
    {
      "join_id" => profile_row.fetch(0), "role" => profile_row.fetch(1),
      "baseline_source_id" => profile_row.fetch(2), "baseline_json_pointer" => profile_row.fetch(3),
      "current_source_id" => profile_row.fetch(4), "current_json_pointer" => profile_row.fetch(5),
      "baseline_frame_reference_sha256_or_null" => left_hash,
      "current_frame_reference_sha256_or_null" => right_hash,
      "state_enum" => state, "equal_bool_or_null" => equal, "error" => row_error
    }
  end
  all_equal = rows.all? { |row| row.fetch("state_enum") == "EQUAL" }
  {
    "profile_id" => profile_id, "profile" => profile,
    "baseline_frame_references" => baseline, "current_frame_references" => current,
    "materialized_joins" => {
      "expected_count_uint" => 3, "rows" => rows, "observed_count_uint" => 3,
      "all_equal_bool" => all_equal, "complete_bool" => all_equal,
      "error" => all_equal ? error_none : mechanics_error("FRAME_BASELINE_SET_#{case_state}")
    }
  }
end

def v12_outer_v2_predicate_evaluation(replay)
  {
    "predicate_id" => replay.fetch("predicate_id"),
    "definition_complete_json_sha256" => replay.fetch("definition_sha256"),
    "state_enum" => replay.fetch("state_enum"), "witness_evaluations" => [],
    "applicability_result" => clone(replay.fetch("applicability_result")),
    "assertion_result" => clone(replay.fetch("assertion_result_or_null") || v12_outer_v2_eval_value(false)),
    "error" => clone(replay.fetch("error"))
  }
end

def v12_outer_v2_catalog_fixture!(fixture_id, type_id)
  fixture = D.fetch("custom_operator_conformance_catalog_v12").fetch("fixtures").find { |row| row.fetch("fixture_id") == fixture_id }
  raise "V12_OUTER_CARRIER_V2_MISSING_TYPED_DEPENDENCY: exact custom fixture #{fixture_id}:#{type_id}" unless fixture
  v12_outer_v2_decode_fixture!(fixture, type_id)
end

def v12_outer_v2_project_cut_input(workspace)
  data = {
    "controller_process_state_enum" => nil,
    "observer_runtime_admission_cut" => {"matches_contract_bool" => nil, "error" => nil},
    "pre_spawn_frame_cut" => {"observed_count_uint" => nil, "complete_bool" => nil, "error" => nil},
    "outer_capture_preholds" => [
      {"label" => nil, "path" => nil, "state_enum" => nil, "error" => nil},
      {"label" => nil, "path" => nil, "state_enum" => nil, "error" => nil}
    ],
    "outer_interval_state_enum" => nil, "outer_interval_timebase" => nil,
    "outer_interval_start_realtime" => nil, "outer_interval_end_realtime" => nil,
    "outer_interval_error" => nil
  }
  S.dig("outer_not_attempted_cut_projection_v12", "rows_exact").each do |source_pointer, target_pointer, _type|
    target_tokens = target_pointer.split("/").drop(1)
    cursor = data
    target_tokens[0...-1].each do |token|
      cursor = cursor[token.match?(/\A\d+\z/) ? Integer(token, 10) : token]
    end
    last = target_tokens.fetch(-1)
    cursor[last.match?(/\A\d+\z/) ? Integer(last, 10) : last] = clone(v12_outer_v2_pointer(workspace, source_pointer))
  end
  state = workspace.dig("controller_process", "state_enum")
  {"controller_process_state_enum" => state, "cut_data_or_null" => state == "NOT_ATTEMPTED" ? data : nil}
end

def v12_outer_v2_project_endpoint_input(workspace)
  cut_input = v12_outer_v2_project_cut_input(workspace)
  snapshot = workspace.fetch("counter_snapshots").find do |row|
    row.fetch("subject_scope_id") == "OUTER_PROCESS" &&
      row.fetch("reporter_scope_id") == "OUTER_PROCESS" &&
      row.fetch("observation_enum") == "EXACT_SELF"
  end
  raise "outer v2 endpoint exact self counter snapshot" unless snapshot
  {
    "observer_runtime_admission" => clone(workspace.fetch("observer_runtime_admission")),
    "outer_stdout_admission" => clone(workspace.fetch("outer_stdout_admission")),
    "outer_stderr_admission" => clone(workspace.fetch("outer_stderr_admission")),
    "controller_process" => clone(workspace.fetch("controller_process")),
    "not_attempted_cut_data_or_null" => clone(cut_input.fetch("cut_data_or_null")),
    "outer_capture_continuity" => clone(workspace.fetch("outer_capture_continuity")),
    "transition_receipts" => clone(workspace.fetch("transition_receipts")),
    "outer_process_counter_snapshot" => clone(snapshot),
    "projection_complete_bool" => true, "error" => error_none
  }
end

def v12_outer_v2_endpoint_sources
  true_source = v12_outer_v2_catalog_fixture!("ENDPOINT_TRUE_00_INPUT", "OuterPublicationEndpointInputV12")
  false_source = v12_outer_v2_catalog_fixture!("ENDPOINT_FALSE_AXIS_09_INPUT", "OuterPublicationEndpointInputV12")
  true_workspace = v12_outer_v2_catalog_fixture!("ENDPOINT_TRUE_00_SOURCE", "OuterPublicationEndpointWorkspaceV12")
  unknown_workspace = v12_outer_v2_catalog_fixture!("ENDPOINT_UNAVAILABLE_NO_CAUSAL_SOURCE", "OuterPublicationEndpointWorkspaceV12")
  raise "outer v2 true endpoint source/workspace join" unless v12_outer_v2_project_endpoint_input(true_workspace) == true_source
  unknown_source = v12_outer_v2_project_endpoint_input(unknown_workspace)
  frames = clone(true_workspace.dig("pre_spawn_checkpoint_readiness_binding", "frames"))
  raise "outer v2 endpoint frame profile width" unless frames&.length == 3
  [true_source, false_source, unknown_source, frames]
end

def v12_outer_v2_base_source(endpoint_source, frame_refs)
  endpoint_replay = v12_outer_v2_replay!("OUT_UNENTERED_ENDPOINT_AUTHORIZED", endpoint_source)
  journal_paths = J.dig("journal", "leaves_ordered").map { |leaf| File.join(J.dig("artifact_parent_target_scoped_admission_v12", "parent_path"), leaf) }
  slots = v12_outer_v2_absent_slot_sources(journal_paths)
  chain, frame_bytes = v12_outer_v2_journal_projection(slots)
  admission_source = v12_outer_v2_admission_baseline_source
  frame_source = v12_outer_v2_frame_baseline_source(frame_refs)
  input = {
    "endpoint_authorized_evaluation" => v12_outer_v2_predicate_evaluation(endpoint_replay),
    "start_record" => v12_outer_v2_absent_record(J.fetch("authorized_paths_exact").fetch("start_record")),
    "prefix_result" => v12_outer_v2_absent_record(J.fetch("authorized_paths_exact").fetch("prefix_result")),
    "artifact_slots" => v12_outer_v2_artifact_set(endpoint_source),
    "journal_chain" => chain, "journal_frame_bytes" => frame_bytes,
    "operation_prefix_projection" => v12_outer_v2_operation_projection,
    "root_traversals" => v12_outer_v2_root_set,
    "fixed_output_observations" => v12_outer_v2_output_set,
    "admission_baseline_joins" => clone(admission_source.fetch("materialized_joins")),
    "frame_baseline_joins" => clone(frame_source.fetch("materialized_joins"))
  }
  source = {
    "endpoint_source" => clone(endpoint_source), "endpoint_replay" => endpoint_replay,
    "start_raw_observed_bytes_or_null" => nil, "prefix_raw_observed_bytes_or_null" => nil,
    "journal_slot_sources" => slots, "artifact_profile_id" => "ARTIFACT_NAMESPACE_6",
    "record_chain_profile_id" => "OUTER_FULL_CENSUS_7",
    "frame_bytes_profile_id" => "OUTER_OBSERVED_0_TO7",
    "operation_profile_id" => "OUTER_OPERATION_CENSUS",
    "root_profile_id" => "ROOTS_TEST_A_B_OUTER_CENSUS",
    "output_profile_id" => "FIXED_SEVEN_OUTPUTS",
    "admission_baseline_source" => admission_source, "frame_baseline_source" => frame_source,
    "materialized_input" => input, "evidence_replay" => nil
  }
  source
end

def v12_outer_v2_replace_artifact_slot!(source, index, slot, error = error_none)
  set = source.dig("materialized_input", "artifact_slots")
  set.fetch("slots")[index] = clone(slot)
  complete = error.fetch("state_enum") == "NONE"
  set["complete_bool"] = complete
  set["error"] = complete ? error_none : clone(error)
end

def v12_outer_v2_sync_journal!(source, frame_complete: true, frame_error: error_none)
  chain, frame_bytes = v12_outer_v2_journal_projection(source.fetch("journal_slot_sources"), frame_complete: frame_complete, frame_error: frame_error)
  source.fetch("materialized_input")["journal_chain"] = chain
  source.fetch("materialized_input")["journal_frame_bytes"] = frame_bytes
end

def v12_outer_v2_truth_from_eval(value)
  return nil unless value && value.fetch("state_enum") == "VALUE"
  JSON.parse(Base64.strict_decode64(value.dig("value_or_null", "canonical_json_base64")))
end

def v12_outer_v2_expected_projection(replay)
  [
    true, v12_outer_v2_truth_from_eval(replay.fetch("applicability_result")),
    v12_outer_v2_truth_from_eval(replay.fetch("assertion_result_or_null")),
    replay.fetch("state_enum"), replay.dig("error", "state_enum"),
    replay.dig("error", "code_string_or_null")
  ]
end

# Search only already content-addressed fixture bytes.  This scan is a separate
# C3/custom-JE dependency diagnostic; Failure Order 82 does not require a valid
# production journal frame when the observed journal slots are absent,
# malformed, wrong-type, or unavailable.
fixture_pool = clone(D.fetch("custom_operator_conformance_catalog_v12").fetch("fixtures"))
fixture_pool.concat(clone(OBSERVATION_SOURCE_FIXTURES_V12)) if defined?(OBSERVATION_SOURCE_FIXTURES_V12)
fixture_ids = fixture_pool.map { |row| row.fetch("fixture_id") }
raise "outer v2 duplicate fixture ids before admission" unless fixture_ids.uniq.length == fixture_ids.length

typed_journal_sources = fixture_pool.select { |row| row.fetch("type_id") == "OuterJournalFrameSourceV12" }.map do |fixture|
  [fixture, v12_outer_v2_decode_fixture!(fixture, "OuterJournalFrameSourceV12")]
end
production_envelope_candidates = []
foreign_complete_frame_candidates = []
fixture_pool.each do |fixture|
  bytes = Base64.strict_decode64(fixture.fetch("canonical_json_base64"))
  value = JSON.parse(bytes)
  walk = lambda do |node, node_path|
    if node.is_a?(Hash)
      if node.key?("candidate_complete_frame_with_lf_base64")
        raw = Base64.strict_decode64(node.fetch("candidate_complete_frame_with_lf_base64")) rescue nil
        if raw&.end_with?("\n")
          begin
            envelope = JSON.parse(raw.byteslice(0, raw.bytesize - 1))
            target = envelope["schema"] == J.dig("journal", "frame_schema") ? production_envelope_candidates : foreign_complete_frame_candidates
            target << [fixture.fetch("fixture_id"), node_path, envelope["schema"], envelope["status"]]
          rescue JSON::ParserError
            foreign_complete_frame_candidates << [fixture.fetch("fixture_id"), node_path, "MALFORMED", nil]
          end
        end
      end
      node.each { |key, child| walk.call(child, "#{node_path}/#{key}") if child.is_a?(Hash) || child.is_a?(Array) }
    elsif node.is_a?(Array)
      node.each_with_index { |child, index| walk.call(child, "#{node_path}/#{index}") if child.is_a?(Hash) || child.is_a?(Array) }
    end
  end
  walk.call(value, "/fixture/#{fixture.fetch("fixture_id")}")
end

required_chain_ordinals = [0, 1, 6]
admitted_by_ordinal = typed_journal_sources.group_by { |_fixture, source| source.fetch("ordinal_uint") }
missing_ordinals = required_chain_ordinals.reject { |ordinal| admitted_by_ordinal.fetch(ordinal, []).length == 1 }
production_chain_state = missing_ordinals.empty? ? "AVAILABLE_UNVERIFIED_CHAIN" : "MISSING_TYPED_DEPENDENCY"
if missing_ordinals.empty?
  minimum_chain = required_chain_ordinals.map { |ordinal| admitted_by_ordinal.fetch(ordinal).fetch(0).fetch(1) }
  minimum_chain.each_cons(2) do |left, right|
    right_bytes = Base64.strict_decode64(right.dig("raw_complete_frame", "base64"))
    right_envelope = JSON.parse(right_bytes.byteslice(0, right_bytes.bytesize - 1))
    left_sha = left.dig("record_frame_bytes", "complete_frame_sha256")
    raise "outer v2 predecessor chain #{left.fetch("ordinal_uint")}->#{right.fetch("ordinal_uint")}" unless right_envelope.fetch("previous_complete_frame_with_lf_sha256_or_null") == left_sha
  end
  production_chain_state = "AVAILABLE_VALIDATED_CHAIN"
end
production_chain_diagnostic = {
  "state" => production_chain_state,
  "required_ordinals" => required_chain_ordinals,
  "missing_ordinals" => missing_ordinals,
  "missing_leaves" => missing_ordinals.map { |ordinal| J.dig("journal", "leaves_ordered").fetch(ordinal) },
  "typed_source_count" => typed_journal_sources.length,
  "raw_production_envelope_candidate_count" => production_envelope_candidates.length,
  "foreign_or_conformance_complete_frame_candidate_count" => foreign_complete_frame_candidates.length,
  "scope" => "C3_CUSTOM_JE_JOURNAL_CHAIN_ONLY_NOT_FAILURE_ORDER82"
}

def v12_outer_v2_set_ancillary_record!(source, key, raw_key, artifact_index, record, raw)
  source.fetch("materialized_input")[key] = clone(record)
  source[raw_key] = clone(raw)
  slot = record.fetch("slot")
  unavailable = slot.fetch("final_state_enum") == "FSTATAT_FAILED" || slot.fetch("staging_state_enum") == "SCAN_ERROR"
  v12_outer_v2_replace_artifact_slot!(source, artifact_index, slot, unavailable ? record.fetch("error") : error_none)
end

def v12_outer_v2_set_journal_slot!(source, ordinal, record, raw, operation_state: nil, frame_complete: true, frame_error: error_none)
  source.fetch("journal_slot_sources")[ordinal] = v12_outer_v2_slot_source(ordinal, record, raw)
  source.fetch("materialized_input")["operation_prefix_projection"] = v12_outer_v2_operation_projection(operation_state) if operation_state
  v12_outer_v2_sync_journal!(source, frame_complete: frame_complete, frame_error: frame_error)
end

endpoint_true, endpoint_false, endpoint_unknown, endpoint_frame_refs = v12_outer_v2_endpoint_sources
outer_sources_v2 = scenario_cases.keys.to_h do |case_id|
  endpoint = case case_id
  when "OU_NA_ENDPOINT_FALSE" then endpoint_false
  when "OU_UNKNOWN_ENDPOINT_UNKNOWN" then endpoint_unknown
  else endpoint_true
  end
  [case_id, v12_outer_v2_base_source(endpoint, endpoint_frame_refs)]
end

artifact_leaves_v2 = J.dig("artifact_parent_target_scoped_admission_v12", "final_leaves_exact_ordered")
raise "outer v2 artifact profile width" unless artifact_leaves_v2.length == 6
artifact_parent_v2 = J.dig("artifact_parent_target_scoped_admission_v12", "parent_path")
artifact_paths_v2 = artifact_leaves_v2.map { |leaf| File.join(artifact_parent_v2, leaf) }
journal_paths_v2 = J.dig("journal", "leaves_ordered").map { |leaf| File.join(artifact_parent_v2, leaf) }
start_path_v2 = J.fetch("authorized_paths_exact").fetch("start_record")
prefix_path_v2 = J.fetch("authorized_paths_exact").fetch("prefix_result")

start_record_v2, start_raw_v2 = v12_outer_v2_malformed_record(start_path_v2, "start-final", '{"outer_v2":"malformed-start-conformance"}')
v12_outer_v2_set_ancillary_record!(outer_sources_v2.fetch("OU_DIRTY_START_FINAL"), "start_record", "start_raw_observed_bytes_or_null", 2, start_record_v2, start_raw_v2)

prefix_record_v2, prefix_raw_v2 = v12_outer_v2_malformed_record(prefix_path_v2, "prefix-final", '{"outer_v2":"malformed-prefix-conformance"}')
v12_outer_v2_set_ancillary_record!(outer_sources_v2.fetch("OU_DIRTY_PREFIX_FINAL"), "prefix_result", "prefix_raw_observed_bytes_or_null", 3, prefix_record_v2, prefix_raw_v2)

staging_name_v2 = ".#{artifact_leaves_v2.fetch(4)}.ABC123.staging"
staging_vnode_v2 = v12_outer_v2_vnode("REGULAR", "artifact-staging", 0)
staging_slot_v2 = v12_outer_v2_slot(
  artifact_paths_v2.fetch(4), staging_state: "ONE",
  staging_leaves: [{"name" => v12_outer_v2_inventory_name(staging_name_v2), "vnode" => staging_vnode_v2}]
)
v12_outer_v2_replace_artifact_slot!(outer_sources_v2.fetch("OU_DIRTY_ARTIFACT_STAGING"), 4, staging_slot_v2)

# The two legacy vector labels mention a valid final/row.  No production R00
# or OPERATION body instance exists in the held control.  The actual source is
# therefore the stronger honest observation: retained malformed bytes at the
# operation slot, INVALID operation state, and zero valid frame rows.
journal_dirty_record_v2, journal_dirty_raw_v2 = v12_outer_v2_malformed_record(
  journal_paths_v2.fetch(1), "journal-operation-invalid", '{"outer_v2":"malformed-operation-conformance"}'
)
v12_outer_v2_set_journal_slot!(
  outer_sources_v2.fetch("OU_DIRTY_JOURNAL_VALID_FINAL"), 1,
  journal_dirty_record_v2, journal_dirty_raw_v2, operation_state: "INVALID"
)

journal_decode_error_v2 = mechanics_error("JOURNAL_FRAME_DECODE_INCOMPLETE")
journal_decode_record_v2, journal_decode_raw_v2 = v12_outer_v2_malformed_record(
  journal_paths_v2.fetch(1), "journal-frame-decode", '{"outer_v2":"truncated-operation-conformance"'
)
journal_decode_record_v2["error"] = clone(journal_decode_error_v2)
v12_outer_v2_set_journal_slot!(
  outer_sources_v2.fetch("OU_DIRTY_JOURNAL_FRAME_DECODE"), 1,
  journal_decode_record_v2, journal_decode_raw_v2, operation_state: "INVALID",
  frame_complete: false, frame_error: journal_decode_error_v2
)

outer_sources_v2.fetch("OU_DIRTY_ROOT_PRESENT").fetch("materialized_input")["root_traversals"] = v12_outer_v2_root_set("A")

output_present_v2 = outer_sources_v2.fetch("OU_DIRTY_FIXED_OUTPUT_PRESENT").dig("materialized_input", "fixed_output_observations")
output_present_v2.fetch("rows").fetch(0).merge!(
  "state_enum" => "PRESENT_REGULAR", "vnode_or_null" => v12_outer_v2_vnode("REGULAR", "fixed-output-present", 0)
)

admission_dirty_v2 = v12_outer_v2_admission_baseline_source("NOT_EQUAL")
outer_sources_v2.fetch("OU_DIRTY_ADMISSION_NOT_EQUAL")["admission_baseline_source"] = admission_dirty_v2
outer_sources_v2.fetch("OU_DIRTY_ADMISSION_NOT_EQUAL").fetch("materialized_input")["admission_baseline_joins"] = clone(admission_dirty_v2.fetch("materialized_joins"))

frame_dirty_v2 = v12_outer_v2_frame_baseline_source(endpoint_frame_refs, "NOT_EQUAL")
outer_sources_v2.fetch("OU_DIRTY_FRAME_NOT_EQUAL")["frame_baseline_source"] = frame_dirty_v2
outer_sources_v2.fetch("OU_DIRTY_FRAME_NOT_EQUAL").fetch("materialized_input")["frame_baseline_joins"] = clone(frame_dirty_v2.fetch("materialized_joins"))

start_failed_v2 = v12_outer_v2_failed_record(start_path_v2, "FSTATAT_FAILED", "START_OBSERVATION_FSTAT_FAILED")
v12_outer_v2_set_ancillary_record!(outer_sources_v2.fetch("OU_NA_START_FSTAT_FAILED"), "start_record", "start_raw_observed_bytes_or_null", 2, start_failed_v2, nil)

prefix_failed_v2 = v12_outer_v2_failed_record(prefix_path_v2, "SCAN_ERROR", "PREFIX_OBSERVATION_SCAN_ERROR")
v12_outer_v2_set_ancillary_record!(outer_sources_v2.fetch("OU_NA_PREFIX_SCAN_ERROR"), "prefix_result", "prefix_raw_observed_bytes_or_null", 3, prefix_failed_v2, nil)

artifact_failed_error_v2 = mechanics_error("ARTIFACT_FSTAT_FAILED")
artifact_failed_slot_v2 = v12_outer_v2_slot(artifact_paths_v2.fetch(4), final_state: "FSTATAT_FAILED", error: artifact_failed_error_v2)
v12_outer_v2_replace_artifact_slot!(outer_sources_v2.fetch("OU_NA_ARTIFACT_FSTAT_FAILED"), 4, artifact_failed_slot_v2, artifact_failed_error_v2)

journal_scan_record_v2 = v12_outer_v2_failed_record(journal_paths_v2.fetch(1), "SCAN_ERROR", "JOURNAL_SCAN_ERROR")
v12_outer_v2_set_journal_slot!(outer_sources_v2.fetch("OU_NA_JOURNAL_SCAN_ERROR"), 1, journal_scan_record_v2, nil)

operation_unavailable_record_v2 = v12_outer_v2_failed_record(journal_paths_v2.fetch(1), "FSTATAT_FAILED", "OPERATION_OBSERVATION_UNAVAILABLE")
v12_outer_v2_set_journal_slot!(
  outer_sources_v2.fetch("OU_NA_OPERATION_UNAVAILABLE"), 1,
  operation_unavailable_record_v2, nil, operation_state: "UNAVAILABLE"
)

outer_sources_v2.fetch("OU_NA_ROOT_OPEN_FAILED").fetch("materialized_input")["root_traversals"] = v12_outer_v2_failed_root_set

capture_incomplete_v2 = outer_sources_v2.fetch("OU_NA_CAPTURE_CENSUS_INCOMPLETE").dig("materialized_input", "root_traversals")
capture_incomplete_error_v2 = mechanics_error("CAPTURE_CENSUS_INCOMPLETE")
capture_incomplete_v2.fetch("current_entered_capture_census").merge!("complete_bool" => false, "error" => clone(capture_incomplete_error_v2))
capture_incomplete_v2.merge!("complete_bool" => false, "error" => clone(capture_incomplete_error_v2))

output_not_reached_v2 = outer_sources_v2.fetch("OU_NA_FIXED_OUTPUT_NOT_REACHED").dig("materialized_input", "fixed_output_observations")
output_not_reached_v2.fetch("rows").fetch(0)["state_enum"] = "NOT_REACHED"
output_not_reached_v2["complete_bool"] = false

admission_unavailable_v2 = v12_outer_v2_admission_baseline_source("UNAVAILABLE")
outer_sources_v2.fetch("OU_NA_ADMISSION_UNAVAILABLE")["admission_baseline_source"] = admission_unavailable_v2
outer_sources_v2.fetch("OU_NA_ADMISSION_UNAVAILABLE").fetch("materialized_input")["admission_baseline_joins"] = clone(admission_unavailable_v2.fetch("materialized_joins"))

frame_unavailable_v2 = v12_outer_v2_frame_baseline_source(endpoint_frame_refs, "UNAVAILABLE")
outer_sources_v2.fetch("OU_NA_FRAME_UNAVAILABLE")["frame_baseline_source"] = frame_unavailable_v2
outer_sources_v2.fetch("OU_NA_FRAME_UNAVAILABLE").fetch("materialized_input")["frame_baseline_joins"] = clone(frame_unavailable_v2.fetch("materialized_joins"))

outer_fixture_id_by_case_v2 = {}
outer_fixtures_v2 = []
outer_sources_v2.each do |case_id, source|
  endpoint_truth = case source.dig("endpoint_replay", "state_enum")
  when "TRUE" then true
  when "FALSE", "NOT_APPLICABLE" then false
  when "UNKNOWN" then :unknown
  else raise "outer v2 endpoint state #{case_id}"
  end
  source["evidence_replay"] = v12_outer_v2_replay!(
    "OUT_UNENTERED_EVIDENCE_CLEAN", source.fetch("materialized_input"),
    {"OUT_UNENTERED_ENDPOINT_AUTHORIZED" => endpoint_truth}
  )
  fixture_id = "OUTER_UNENTERED_SOURCE_V2_#{case_id}"
  fixture = obs_fixture(fixture_id, "OuterUnenteredEvidenceSourceV12", source)
  decoded_source = v12_outer_v2_decode_fixture!(fixture, "OuterUnenteredEvidenceSourceV12")
  raise "outer v2 fixture round trip #{case_id}" unless decoded_source == source
  vector = vectors.find { |row| row.fetch(0) == case_id }
  raise "outer v2 vector missing #{case_id}" unless vector
  expected = vector.values_at(12, 13, 14, 15, 16, 17)
  actual = v12_outer_v2_expected_projection(decoded_source.fetch("evidence_replay"))
  raise "outer v2 literal replay #{case_id}: #{actual.inspect} != #{expected.inspect}" unless actual == expected
  outer_fixtures_v2 << fixture
  outer_fixture_id_by_case_v2[case_id] = fixture_id
end

raise "outer v2 source fixture count" unless outer_fixtures_v2.length == V12_OUTER_V2_CASE_COUNT
raise "outer v2 duplicate new fixture ids" unless outer_fixtures_v2.map { |row| row.fetch("fixture_id") }.uniq.length == V12_OUTER_V2_CASE_COUNT
raise "outer v2 fixture id collision" unless (fixture_ids & outer_fixtures_v2.map { |row| row.fetch("fixture_id") }).empty?
raise "outer v2 observation fixture registry missing" unless defined?(OBSERVATION_SOURCE_FIXTURES_V12)
OBSERVATION_SOURCE_FIXTURES_V12.concat(outer_fixtures_v2)

outer_vector_schema_v2 = R.fetch("OuterUnenteredEvidenceConformanceVectorV12")
raise "outer v2 vector schema already extended" if outer_vector_schema_v2.fetch("tuple_fields_exact_order").include?("source_fixture_id")
outer_vector_schema_v2.fetch("tuple_fields_exact_order") << "source_fixture_id"
outer_vector_schema_v2.fetch("tuple_field_types_exact") << "S"
vectors.each do |row|
  raise "outer v2 vector width before append #{row.fetch(0)}" unless row.length == V12_OUTER_V2_BASE_VECTOR_WIDTH
  row << outer_fixture_id_by_case_v2.fetch(row.fetch(0))
end
outer_vector_schema_v2["rule"] = "source_fixture_id_RESOLVES_EXACTLY_ONE_CONTENT_ADDRESSED_OuterUnenteredEvidenceSourceV12;STRICT_DECODE_LENGTH_HASH_CANONICAL_JSON_AND_RECURSIVE_DESCRIPTOR_VALIDATION;ACTUAL_TYPED_BASELINE_CURRENT_VALUES_RECOMPUTE_HASHES_AND_EQUALITY;RETAIN_RAW_MALFORMED_BYTES_WHEN_READ;EXECUTE_EXACT_HASH_JOINED_OUT_UNENTERED_ENDPOINT_AUTHORIZED_AND_OUT_UNENTERED_EVIDENCE_CLEAN_POSTFIX_PROGRAMS;COMPARE_THE_SEPARATE_EXPECTED_FIELDS_ONLY_AFTER_REPLAY;CASE_ENUMS_AND_VECTOR_ID_NEVER_SUPPLY_INPUT"
S.fetch("outer_unentered_evidence_case_materialization_v12").merge!(
  "source_fixture_array_pointer" => "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/source_fixtures",
  "source_fixture_type_id" => "OuterUnenteredEvidenceSourceV12",
  "source_fixture_id_by_case_exact" => outer_fixture_id_by_case_v2.to_a,
  "full_raw_typed_input_per_vector_bool" => true,
  "production_frame_chain_dependency_diagnostic" => production_chain_diagnostic,
  "production_frame_chain_dependency_scope" => "SEPARATE_C3_CUSTOM_JE_JOURNAL_CHAIN_CONFORMANCE_NOT_AN_APPLICABILITY_REQUIREMENT_FOR_FAILURE_ORDER82",
  "materialization_program_exact" => [
    "RESOLVE_VECTOR_SOURCE_FIXTURE_ID",
    "STRICT_DECODE_LENGTH_HASH_CANONICAL_JSON_AND_RECURSIVE_DESCRIPTOR_VALIDATION",
    "VERIFY_EXACT_NAMESPACE_AND_PROFILE_MEMBERSHIP",
    "RECOMPUTE_ACTUAL_TYPED_ADMISSION_AND_FRAME_BASELINE_HASHES_AND_EQUALITY",
    "JOIN_RAW_OBSERVED_BYTES_TO_EACH_COMPLETE_MALFORMED_RECORD",
    "EXECUTE_EXACT_OUT_UNENTERED_ENDPOINT_AUTHORIZED_POSTFIX_PROGRAM",
    "EXECUTE_EXACT_OUT_UNENTERED_EVIDENCE_CLEAN_POSTFIX_PROGRAM",
    "COMPARE_SEPARATELY_STORED_EXPECTED_RESULT_AFTER_BOTH_REPLAYS"
  ],
  "mutation_rule" => "NO_ENUM_TO_CARRIER_MATERIALIZATION_AND_NO_EXPECTED_RESULT_INPUT;SEVEN_ABSENT_OBSERVATIONS_CLOSE_CLEAN_WITH_ZERO_FRAME_ROWS;DIRTY_JOURNAL_OPERATION_SOURCES_RETAIN_MALFORMED_BYTES_PROJECT_OPERATION_INVALID_AND_KEEP_ZERO_VALID_FRAME_ROWS;FSTAT_SCAN_OPEN_UNAVAILABLE_AND_INCOMPLETE_STATES_REMAIN_TYPED_FACTS"
)

raise "outer v2 RecordPresenceV12 mutation" unless X.fetch("enum_domains_v12").fetch("RecordPresenceV12") == record_presence_before
raise "outer v2 final vector count" unless vectors.length == V12_OUTER_V2_CASE_COUNT
raise "outer v2 final widths #{vectors.map(&:length).uniq.inspect}" unless vectors.all? { |row| row.length == V12_OUTER_V2_FINAL_VECTOR_WIDTH }
raise "outer v2 final schema width" unless outer_vector_schema_v2.fetch("tuple_fields_exact_order").length == V12_OUTER_V2_FINAL_VECTOR_WIDTH && outer_vector_schema_v2.fetch("tuple_field_types_exact").length == V12_OUTER_V2_FINAL_VECTOR_WIDTH
