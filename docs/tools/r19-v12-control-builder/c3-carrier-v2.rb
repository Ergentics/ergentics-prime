# frozen_string_literal: true

# Scratch-only C3 carrier overlay.  This file is evaluated by
# finalize-control.rb after the ordinary mechanics carriers have been installed
# and before observation fixtures or digests are sealed.  It deliberately
# closes only the finite abstract prefix/integrity/hole algebra.  Missing R00
# operation evidence remains an operational abstention.

require File.expand_path("c3-static-model-v2.rb", __dir__)

c3_model = V12C3StaticModelCarrierV2
c3_install_receipt_type_id = "StaticModelJournalAlgebraInstallReceiptV12"
c3_self_test_receipt_type_id = "StaticModelJournalAlgebraSelfTestReceiptV12"
c3_install_receipt_field = "static_model_journal_algebra_install_receipt_v12"
c3_self_test_receipt_field = "static_model_journal_algebra_self_test_receipt_v12"
c3_receipt_type_definitions = {
  c3_install_receipt_type_id => {
    "keys" => [
      "catalog_field", "catalog_payload_sha256",
      "catalog_merkle_root_sha256", "installed_order_ids_exact",
      "operational_schema_sha256_before",
      "operational_schema_sha256_after",
      "operational_schemas_unchanged_bool"
    ],
    "field_types_exact" => {
      "catalog_field" => "S", "catalog_payload_sha256" => "H64",
      "catalog_merkle_root_sha256" => "H64",
      "installed_order_ids_exact" => "CONTROL_OBJECT",
      "operational_schema_sha256_before" => "CONTROL_OBJECT",
      "operational_schema_sha256_after" => "CONTROL_OBJECT",
      "operational_schemas_unchanged_bool" => "B"
    },
    "constants_exact" => {
      "catalog_field" => c3_model::CATALOG_FIELD,
      "operational_schemas_unchanged_bool" => true
    },
    "rule" => "CATALOG_PAYLOAD_AND_MERKLE_DIGESTS_JOIN_THE_INSTALLED_STATIC_MODEL_CATALOG;INSTALLED_ORDER_IDS_EQUAL_THE_STATIC_MODEL_ORDER_DEFINITION_KEYS_IN_DECLARATION_ORDER;THE_FOUR_PRODUCTION_OPERATIONAL_SCHEMA_DIGEST_MAPS_DEEP_EQUAL_BEFORE_AND_AFTER"
  },
  c3_self_test_receipt_type_id => {
    "keys" => [
      "result_enum", "catalog_payload_sha256", "merkle_root_sha256",
      "entry_count_uint", "edge_count_uint", "c3_case_count_uint",
      "legacy_and_c3_route_count_uint", "negative_case_count_uint",
      "c3_case_result_digests", "route_source_digests",
      "operational_replay_state_enum",
      "operational_frame_rows_emitted_uint", "authority_closed_bool"
    ],
    "field_types_exact" => {
      "result_enum" => "S", "catalog_payload_sha256" => "H64",
      "merkle_root_sha256" => "H64", "entry_count_uint" => "U",
      "edge_count_uint" => "U", "c3_case_count_uint" => "U",
      "legacy_and_c3_route_count_uint" => "U",
      "negative_case_count_uint" => "U",
      "c3_case_result_digests" => "CONTROL_OBJECT",
      "route_source_digests" => "CONTROL_OBJECT",
      "operational_replay_state_enum" => "S",
      "operational_frame_rows_emitted_uint" => "U",
      "authority_closed_bool" => "B"
    },
    "constants_exact" => {
      "result_enum" => "PASS", "entry_count_uint" => 6,
      "edge_count_uint" => 5, "c3_case_count_uint" => 7,
      "legacy_and_c3_route_count_uint" => 4,
      "negative_case_count_uint" => 5,
      "operational_replay_state_enum" =>
        "ABSTAIN_MISSING_REQUIRED_START",
      "operational_frame_rows_emitted_uint" => 0,
      "authority_closed_bool" => false
    },
    "rule" => "RECOMPUTED_STATIC_MODEL_CATALOG_PAYLOAD_MERKLE_BIDIRECTIONAL_INDEX_PREDECESSOR_AND_NEGATIVE_CASES_PASS;ALL_SEVEN_C3_PARTITIONS_AND_FOUR_SHARED_ROUTES_REPLAY;OPERATIONAL_PRODUCTION_FRAME_ROWS_REMAIN_ZERO_AND_AUTHORITY_REMAINS_OPEN"
  }
}
c3_receipt_type_definitions.each_key do |type_id|
  raise "C3 static-model receipt type collision #{type_id}" if R.key?(type_id)
end
[c3_install_receipt_field, c3_self_test_receipt_field].each do |field|
  raise "C3 static-model receipt field collision #{field}" if D.key?(field)
end
c3_obsolete_rule_suffix = ";expected_operation_projection_or_null_IS_NULL_EXACTLY_FOR_R00_AND_OTHERWISE_DEEP_EQUALS_THE_FOUR_NAMED_OperationPrefixProjectionV12_FIELDS_INCLUDING_EVERY_FULL_TYPED_FrameReferenceV12;THE_VALID_PREFIX_IS_THE_LONGEST_INITIAL_VALID_FINAL_RUN_AND_LATER_VALID_ROWS_REMAIN_VISIBLE_FOR_HOLE_DETECTION"
raise "missing obsolete C3 projection schema before install" unless
  R.key?("OperationPrefixProjectionExpectedV12")
c3_preflight_vector_schema = R.fetch("ObservationIntegrityConformanceVectorV12")
raise "C3 preflight expected field" unless
  c3_preflight_vector_schema.fetch("tuple_fields_exact_order").index(
    "expected_operation_projection_or_null"
  ) == 20 &&
  c3_preflight_vector_schema.fetch("tuple_fields_exact_order").length == 34 &&
  c3_preflight_vector_schema.fetch("tuple_field_types_exact").length == 34 &&
  c3_preflight_vector_schema.fetch("rule").end_with?(c3_obsolete_rule_suffix)
raise "C3 preflight observation vector set" unless
  observation.fetch("vectors").length == 53 &&
  observation.fetch("vectors").all? { |row| row.length == 34 }
c3_existing_fixture_ids = OBSERVATION_SOURCE_FIXTURES_V12.map do |fixture|
  fixture.fetch("fixture_id")
end
raise "C3 preflight existing fixture ids" unless
  c3_existing_fixture_ids.uniq.length == c3_existing_fixture_ids.length
c3_planned_fixture_ids = observation.fetch("vectors").reject do |row|
  row.fetch(1) == "R00"
end.map { |row| "C3_STATIC_MODEL_SOURCE_#{row.fetch(0)}" }
raise "C3 preflight planned fixture ids" unless
  c3_planned_fixture_ids.length == 51 &&
  c3_planned_fixture_ids.uniq.length == 51 &&
  (c3_existing_fixture_ids & c3_planned_fixture_ids).empty?

# The static schemas use three new order identifiers.  The module installs
# them atomically with its schemas and catalog; every prior occupant is a
# collision rather than an invitation to reinterpret it.
c3_order_registry = X.fetch("order_registry_v12")
c3_model.order_definitions.each_key do |order_id|
  raise "C3 static-model pre-install order collision #{order_id}" if c3_order_registry.key?(order_id)
end

# The quarantined install is append-only with respect to reusable schemas and
# decision-kernel fields.  Hash the production observation/frame surfaces
# before and after so this transformer cannot silently change them.
c3_operational_schema_ids = %w[
  RecordObservationV12
  FrameReferenceV12
  RecordFrameBytesV12
  RecordFrameBytesSetV12
  OperationPrefixProjectionV12
  OuterOperationCensusProjectionV12
]
c3_operational_schema_before = c3_operational_schema_ids.each_with_object({}) do |type_id, result|
  result[type_id] = json_sha(R.fetch(type_id))
end
c3_journal_schema_before = json_sha(X.fetch("records").fetch("journal"))
c3_install_report = c3_model.install!(J)
c3_operational_schema_after = c3_operational_schema_ids.each_with_object({}) do |type_id, result|
  result[type_id] = json_sha(R.fetch(type_id))
end
raise "C3 static-model operational schema mutation" unless c3_operational_schema_before == c3_operational_schema_after
raise "C3 static-model journal schema mutation" unless c3_journal_schema_before == json_sha(X.fetch("records").fetch("journal"))
raise "C3 static-model install report" unless c3_install_report.fetch("operational_schemas_unchanged_bool") == true
raise "C3 static-model installed order set" unless
  c3_install_report.fetch("installed_order_ids_exact") == c3_model.order_definitions.keys
c3_model.order_definitions.each do |order_id, definition|
  raise "C3 static-model order join #{order_id}" unless c3_order_registry.fetch(order_id) == definition
end

# Recursively close every type/order token used by the newly installed schemas.
# This catches the dangling-order defect that a catalog-local order description
# alone cannot close.
c3_model.schema_definitions.each do |type_id, definition|
  definition.fetch("field_types_exact", {}).each do |field, descriptor|
    descriptor.scan(/\b[A-Za-z][A-Za-z0-9_]*V12\b/).uniq.each do |dependency_id|
      next if R.key?(dependency_id) || c3_order_registry.key?(dependency_id)

      raise "C3 static-model dangling type/order #{type_id}.#{field}:#{dependency_id}"
    end
  end
end

c3_catalog = D.fetch(c3_model::CATALOG_FIELD)
c3_model.validate_catalog!(J, c3_catalog)
c3_assessment = c3_catalog.fetch("operational_replay_assessment")
raise "C3 static-model operational assessment" unless
  c3_assessment.fetch("state_enum") == "ABSTAIN_MISSING_REQUIRED_START" &&
  c3_assessment.fetch("required_source_available_bool") == false &&
  c3_assessment.fetch("record_frame_bytes_rows_emitted_uint") == 0 &&
  c3_assessment.fetch("record_observations_emitted_uint") == 0 &&
  c3_assessment.fetch("operational_frame_reference_emitted_uint") == 0 &&
  c3_assessment.fetch("operation_prefix_projection_closed_bool") == false &&
  c3_assessment.fetch("authority_closed_bool") == false

# The previous scratch carrier added a projection schema containing invented
# production-looking FrameReference values.  It is not a production schema and
# has no place in the static algebra.
old_projection_schema = R.delete("OperationPrefixProjectionExpectedV12")
raise "missing obsolete C3 projection schema" unless old_projection_schema

# Independently materialize the expected static result from the vector's
# abstract state input and the immutable catalog.  This routine never receives
# a source fixture or a replay result.
def c3_static_expected_projection(control, catalog, states, scope)
  model = V12C3StaticModelCarrierV2
  unless %w[TERMINAL PREFIX OUTER].include?(scope)
    raise "C3 static expected scope #{scope}"
  end
  unless states.is_a?(Array) && states.length == 5 &&
         states.all? { |state| model::ABSTRACT_STATES.include?(state) }
    raise "C3 static expected states"
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
    fixture_id = model::OPERATION_PLAN.fetch(index).fetch(0)
    entry = model.entry_by_fixture_id!(catalog, fixture_id)
    model.deep_clone(entry.fetch("frame_identity"))
  end
  missing = states.each_index.select do |index|
    states.fetch(index) != "VALID_FINAL"
  end.map { |index| model::OPERATION_PLAN.fetch(index).fetch(1) }
  first_unentered = if prefix_count == 5
    {
      "present_bool" => false,
      "operation_label_or_null" => nil,
      "abstract_reason_enum_or_null" => nil
    }
  else
    next_leaf = model::OPERATION_PLAN.fetch(prefix_count).fetch(1)
    label = model.exact_journal(control).fetch(
      "operation_body_tuple_by_leaf_exact"
    ).fetch(next_leaf).fetch(0)
    {
      "present_bool" => true,
      "operation_label_or_null" => label,
      "abstract_reason_enum_or_null" => if clean_suffix
        prefix_count.zero? ? "C3_R00_CUT" : "C3_CLEAN_ABSENT_SUFFIX"
      else
        "C3_EVIDENCE_DISCONTINUITY"
      end
    }
  end

  {
    "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA",
    "abstract_states" => model.deep_clone(states),
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

observation_vector_schema = R.fetch("ObservationIntegrityConformanceVectorV12")
c3_vector_fields = observation_vector_schema.fetch("tuple_fields_exact_order")
c3_vector_types = observation_vector_schema.fetch("tuple_field_types_exact")
c3_old_expected_index = c3_vector_fields.index("expected_operation_projection_or_null")
raise "obsolete C3 expected field position" unless c3_old_expected_index == 20
c3_vector_fields[c3_old_expected_index] = "expected_static_model_operation_projection_or_null"
c3_vector_types[c3_old_expected_index] = "REF_OR_NULL(StaticModelC3ProjectionV12)"
c3_source_field = "static_model_c3_source_fixture_id_or_null"
raise "C3 source field collision" if c3_vector_fields.include?(c3_source_field)
c3_vector_fields << c3_source_field
c3_vector_types << "S_OR_NULL"
c3_existing_vector_rule = observation_vector_schema.fetch("rule")
raise "obsolete C3 vector rule suffix" unless c3_existing_vector_rule.end_with?(c3_obsolete_rule_suffix)
observation_vector_schema["rule"] = c3_existing_vector_rule.delete_suffix(c3_obsolete_rule_suffix) + ";FOR_NON_R00_static_model_c3_source_fixture_id_or_null_RESOLVES_EXACTLY_ONE_CONTENT_ADDRESSED_StaticModelC3SourceV12_AND_THE_EVALUATOR_REPLAYS_PREFIX_INTEGRITY_HOLE_AND_STATIC_FRAME_IDENTITY_BEFORE_READING_expected_static_model_operation_projection_or_null;R00_REQUIRES_BOTH_FIELDS_NULL;THE_STATIC_RESULT_ALWAYS_RETAINS_operational_projection_state_enum_ABSTAIN_MISSING_REQUIRED_START_AND_NULL_OPERATIONAL_PROJECTION_AND_FRAME_BYTE_SET;THE_THREE_EXISTING_EXPECTED_OPERATION_FIELDS_MUST_EQUAL_THE_SEPARATELY_REPLAYED_STATIC_RESULT;NO_RecordObservationV12_FrameReferenceV12_RecordFrameBytesV12_OR_PRODUCTION_VNODE_PATH_VALUE_IS_EMITTED"

observation_expected_schema = R.fetch("ObservationIntegrityConformanceExpectedResultRowV12")
c3_expected_fields = observation_expected_schema.fetch("tuple_fields_exact_order")
c3_expected_types = observation_expected_schema.fetch("tuple_field_types_exact")
c3_old_result_index = c3_expected_fields.index("expected_operation_projection_or_null")
raise "obsolete C3 expected-result field position" unless c3_old_result_index == 7
c3_expected_fields[c3_old_result_index] = "expected_static_model_operation_projection_or_null"
c3_expected_types[c3_old_result_index] = "REF_OR_NULL(StaticModelC3ProjectionV12)"
observation_expected_schema["rule"] = "EXACT_LOSSLESS_PROJECTION_OF_VECTOR_FIELDS0_AND14THROUGH33_IN_DECLARATION_ORDER;THE_CONTENT_ADDRESSED_SOURCE_FIXTURE_ID_IS_INPUT_BINDING_NOT_EXPECTED_OUTPUT;STATIC_PREFIX_INTEGRITY_HOLE_AND_IDENTITY_ARE_COMPARED_ONLY_AFTER_SOURCE_REPLAY;OPERATIONAL_PROJECTION_AND_FRAME_BYTE_SET_REMAIN_NULL"

# Phase one: construct and decode source fixtures using input fields only.  No
# expected field is read in this phase.
c3_source_replays = {}
c3_source_fixture_ids = []
observation.fetch("vectors").each do |row|
  raise "C3 observation pre-overlay width #{row.fetch(0)}:#{row.length}" unless row.length == 34
  next if row.fetch(1) == "R00"

  vector_id = row.fetch(0)
  states = clone(row.fetch(4))
  source = c3_model.c3_source!(
    :control => J, :catalog => c3_catalog, :states => states
  )
  fixture_id = "C3_STATIC_MODEL_SOURCE_#{vector_id}"
  fixture = obs_fixture(fixture_id, "StaticModelC3SourceV12", source)
  raw = Base64.strict_decode64(fixture.fetch("canonical_json_base64"))
  raise "C3 source fixture length #{vector_id}" unless raw.bytesize == fixture.fetch("bytes_uint")
  raise "C3 source fixture hash #{vector_id}" unless sha(raw) == fixture.fetch("sha256")
  decoded = JSON.parse(raw)
  raise "C3 source fixture canonical #{vector_id}" unless canon(decoded) == raw
  raise "C3 source fixture source separation #{vector_id}" unless decoded == source

  replay = c3_model.replay_c3_algebra!(
    :control => J, :catalog => c3_catalog, :source => decoded,
    :scope => row.fetch(1)
  )
  c3_source_replays[vector_id] = [fixture_id, replay]
  c3_source_fixture_ids << fixture_id
  OBSERVATION_SOURCE_FIXTURES_V12 << fixture
end

# Phase two: materialize expected abstract outputs independently, compare the
# already-computed source replay, then attach expectation and fixture ID.
observation.fetch("vectors").each do |row|
  if row.fetch(1) == "R00"
    raise "C3 R00 obsolete expected projection #{row.fetch(0)}" unless row.fetch(20).nil?
    row << nil
    next
  end

  vector_id = row.fetch(0)
  fixture_id, replay = c3_source_replays.fetch(vector_id)
  expected = c3_static_expected_projection(
    J, c3_catalog, clone(row.fetch(4)), row.fetch(1)
  )
  raise "C3 abstract source/expected mismatch #{vector_id}" unless replay == expected
  declared = [row.fetch(17), row.fetch(18), row.fetch(19)]
  replayed = [
    replay.fetch("classification_complete_bool"),
    replay.fetch("operation_integrity_bool"),
    replay.fetch("operation_hole_detected_bool")
  ]
  raise "C3 abstract declared mismatch #{vector_id}" unless replayed == declared
  raise "C3 operational projection leaked #{vector_id}" unless
    replay.fetch("operational_projection_state_enum") == "ABSTAIN_MISSING_REQUIRED_START" &&
    replay.fetch("operation_prefix_projection_v12_or_null").nil? &&
    replay.fetch("record_frame_bytes_set_v12_or_null").nil?

  row[20] = expected
  row << fixture_id
end

raise "C3 observation vector width" unless observation.fetch("vectors").all? { |row| row.length == 35 }
raise "C3 observation vector count" unless observation.fetch("vectors").length == 53
raise "C3 static source fixture count" unless c3_source_fixture_ids.length == 51
raise "C3 static source fixture ids" unless c3_source_fixture_ids.uniq.length == 51
raise "C3 projected complete observation count" unless
  observation.fetch("vectors").length + vectors.length +
  first_unentered_vectors.length + admission_vectors.length == 135

# The source binding is deliberately absent from expected rows.  Rebuild them
# from the exact expected slice after all source-derived comparisons pass.
observation["expected_result_rows"] = observation.fetch("vectors").map do |row|
  [row.fetch(0), *clone(row[14..33])]
end
raise "C3 expected-result width" unless observation.fetch("expected_result_rows").all? { |row| row.length == 21 }

# Scan the emitted C3 values, not schema prose, for any operational object or
# physical identity claim.  Static model identities are content-only.
c3_forbidden_value_keys = %w[
  path vnode record_observation frame_reference record_frame_bytes
  content_admission artifact_slot
]
c3_scan_value = lambda do |value, location|
  case value
  when Hash
    overlap = value.keys & c3_forbidden_value_keys
    raise "C3 operational value leak #{location}:#{overlap.join(',')}" unless overlap.empty?
    value.each { |key, child| c3_scan_value.call(child, "#{location}/#{key}") }
  when Array
    value.each_with_index { |child, index| c3_scan_value.call(child, "#{location}/#{index}") }
  end
end
c3_source_fixture_id_set = c3_source_fixture_ids.each_with_object({}) { |fixture_id, set| set[fixture_id] = true }
OBSERVATION_SOURCE_FIXTURES_V12.each do |fixture|
  next unless c3_source_fixture_id_set.key?(fixture.fetch("fixture_id"))

  decoded = JSON.parse(Base64.strict_decode64(fixture.fetch("canonical_json_base64")))
  c3_scan_value.call(decoded, fixture.fetch("fixture_id"))
end
observation.fetch("vectors").each do |row|
  next if row.fetch(20).nil?

  c3_scan_value.call(row.fetch(20), "#{row.fetch(0)}/expected")
end

# The obsolete five-key made-up schema must not survive in emitted data.
obsolete_c3_schema_id = "ergentics.conformance." + "operation-frame.v12"
raise "obsolete invented C3 operation-frame schema survived" if
  JSON.generate(J).include?(obsolete_c3_schema_id)

c3_self_test = c3_model.self_test!(J)
raise "C3 static-model self test" unless
  c3_self_test.fetch("result_enum") == "PASS" &&
  c3_self_test.fetch("operational_replay_state_enum") ==
    "ABSTAIN_MISSING_REQUIRED_START" &&
  c3_self_test.fetch("operational_frame_rows_emitted_uint") == 0 &&
  c3_self_test.fetch("authority_closed_bool") == false
raise "C3 static-model receipt catalog join" unless
  c3_install_report.fetch("catalog_payload_sha256") ==
    c3_self_test.fetch("catalog_payload_sha256") &&
  c3_install_report.fetch("catalog_merkle_root_sha256") ==
    c3_self_test.fetch("merkle_root_sha256") &&
  c3_install_report.fetch("installed_order_ids_exact") ==
    c3_model.order_definitions.keys &&
  c3_install_report.fetch("operational_schema_sha256_before") ==
    c3_install_report.fetch("operational_schema_sha256_after") &&
  c3_self_test.values_at(
    "entry_count_uint", "edge_count_uint", "c3_case_count_uint",
    "legacy_and_c3_route_count_uint", "negative_case_count_uint"
  ) == [6, 5, 7, 4, 5]

c3_receipt_type_definitions.each do |type_id, definition|
  R[type_id] = clone(definition)
end
D[c3_install_receipt_field] = clone(c3_install_report)
D[c3_self_test_receipt_field] = clone(c3_self_test)
