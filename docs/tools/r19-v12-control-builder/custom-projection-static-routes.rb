# frozen_string_literal: true

# Scratch-only atomic installer for the three journal-dependent custom
# projection routes.  It consumes the shared quarantined C3/static-model
# catalog and deliberately emits no production normalized input, observation,
# frame reference, record bytes row, vnode, path, authority, or history claim.

v12_cp_static_route_schema_definitions = {
  "StaticModelLegacyRouteReplayAssessmentV12" => {
    "keys" => [
      "route_id", "source_domain_enum", "catalog_payload_sha256",
      "catalog_merkle_root_sha256", "selected_fixture_count_uint",
      "selected_fixture_ids", "selected_complete_frame_sha256s",
      "exact_envelope_key_order_all_bool", "payload_digest_join_all_bool",
      "predecessor_digest_join_all_bool", "catalog_merkle_root_join_bool",
      "static_model_symbols_or_null", "operational_projection_state_enum",
      "normalized_production_input_emitted_bool", "authority_bool",
      "historical_operation_bool", "operational_evidence_bool",
      "source_fixture_id", "source_fixture_sha256"
    ],
    "field_types_exact" => {
      "route_id" => "S", "source_domain_enum" => "S",
      "catalog_payload_sha256" => "H64",
      "catalog_merkle_root_sha256" => "H64",
      "selected_fixture_count_uint" => "U",
      "selected_fixture_ids" =>
        "ARRAY(S,1,6,StaticModelJournalCatalogOrderV12)",
      "selected_complete_frame_sha256s" =>
        "ARRAY(H64,1,6,StaticModelJournalCatalogOrderV12)",
      "exact_envelope_key_order_all_bool" => "B",
      "payload_digest_join_all_bool" => "B",
      "predecessor_digest_join_all_bool" => "B",
      "catalog_merkle_root_join_bool" => "B",
      "static_model_symbols_or_null" =>
        "ARRAY_OR_NULL(S,6,7,FrameOrdinalOrderV12)",
      "operational_projection_state_enum" => "S",
      "normalized_production_input_emitted_bool" => "B",
      "authority_bool" => "B", "historical_operation_bool" => "B",
      "operational_evidence_bool" => "B", "source_fixture_id" => "S",
      "source_fixture_sha256" => "H64"
    },
    "constants_exact" => {
      "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA",
      "exact_envelope_key_order_all_bool" => true,
      "payload_digest_join_all_bool" => true,
      "predecessor_digest_join_all_bool" => true,
      "catalog_merkle_root_join_bool" => true,
      "operational_projection_state_enum" =>
        "ABSTAIN_MISSING_REQUIRED_START",
      "normalized_production_input_emitted_bool" => false,
      "authority_bool" => false, "historical_operation_bool" => false,
      "operational_evidence_bool" => false
    },
    "rule" => "CONTENT_ONLY_REPLAY_ASSESSMENT;EXACT_STATIC_ENVELOPE_PAYLOAD_PREDECESSOR_AND_MERKLE_JOINS_NEVER_CLOSE_A_PRODUCTION_OPERATOR_INPUT"
  },
  "CustomOperatorStaticModelRouteReplayV12" => {
    "keys" => [
      "schema_type_id", "static_model_catalog_payload_sha256",
      "static_model_catalog_merkle_root_sha256",
      "shared_module_self_test_sha256", "source_fixture_ids_exact",
      "route_assessments_exact", "typed_source_negative_case_count_uint",
      "shared_static_model_negative_case_count_uint",
      "source_before_expected_comparison_bool",
      "normalized_production_inputs_emitted_uint",
      "record_frame_bytes_rows_emitted_uint",
      "record_observations_emitted_uint",
      "operational_frame_reference_emitted_uint", "authority_bool",
      "historical_operation_bool", "operational_evidence_bool",
      "operational_projection_state_enum", "dependency_commitment_id",
      "dependency_commitment_json_pointer"
    ],
    "field_types_exact" => {
      "schema_type_id" => "S", "static_model_catalog_payload_sha256" => "H64",
      "static_model_catalog_merkle_root_sha256" => "H64",
      "shared_module_self_test_sha256" => "H64",
      "source_fixture_ids_exact" =>
        "ARRAY(S,3,3,StaticModelLegacyRouteOrderV12)",
      "route_assessments_exact" =>
        "ARRAY(StaticModelLegacyRouteReplayAssessmentV12,3,3,StaticModelLegacyRouteOrderV12)",
      "typed_source_negative_case_count_uint" => "U",
      "shared_static_model_negative_case_count_uint" => "U",
      "source_before_expected_comparison_bool" => "B",
      "normalized_production_inputs_emitted_uint" => "U",
      "record_frame_bytes_rows_emitted_uint" => "U",
      "record_observations_emitted_uint" => "U",
      "operational_frame_reference_emitted_uint" => "U",
      "authority_bool" => "B", "historical_operation_bool" => "B",
      "operational_evidence_bool" => "B",
      "operational_projection_state_enum" => "S",
      "dependency_commitment_id" => "S",
      "dependency_commitment_json_pointer" => "S"
    },
    "constants_exact" => {
      "schema_type_id" => "CustomOperatorStaticModelRouteReplayV12",
      "source_before_expected_comparison_bool" => true,
      "normalized_production_inputs_emitted_uint" => 0,
      "record_frame_bytes_rows_emitted_uint" => 0,
      "record_observations_emitted_uint" => 0,
      "operational_frame_reference_emitted_uint" => 0,
      "authority_bool" => false, "historical_operation_bool" => false,
      "operational_evidence_bool" => false,
      "operational_projection_state_enum" =>
        "ABSTAIN_MISSING_REQUIRED_START",
      "dependency_commitment_id" => "CUSTOM_OPERATOR_INPUT_PROJECTIONS",
      "dependency_commitment_json_pointer" =>
        "/exact_record_schema_v12/decision_kernel_v12/custom_operator_input_projection_registry_v12"
    },
    "rule" => "THREE_STATIC_ROUTE_SOURCE_REPLAYS_PLUS_TYPED_NEGATIVES;NO_OPERATIONAL_RECORD_SURFACE_IS_EMITTED"
  },
  "CustomOperatorProjectionSourceClosureAssessmentV12" => {
    "keys" => [
      "schema_type_id", "closed_programs_exact",
      "static_model_algebra_programs_exact",
      "blocked_production_programs_exact", "blocked_reason_enum",
      "static_model_catalog_payload_sha256",
      "static_model_catalog_merkle_root_sha256",
      "static_model_install_report_sha256",
      "source_before_expected_comparison_bool", "custom_vector_count_uint",
      "authority_bool", "historical_operation_bool",
      "operational_evidence_bool", "dependency_commitment_id",
      "dependency_commitment_json_pointer", "rule"
    ],
    "field_types_exact" => {
      "schema_type_id" => "S",
      "closed_programs_exact" =>
        "ARRAY(S,2,2,CustomProjectionClosedProgramOrderV12)",
      "static_model_algebra_programs_exact" =>
        "ARRAY(S,3,3,StaticModelLegacyRouteOrderV12)",
      "blocked_production_programs_exact" =>
        "ARRAY(S,3,3,StaticModelLegacyRouteOrderV12)",
      "blocked_reason_enum" => "S",
      "static_model_catalog_payload_sha256" => "H64",
      "static_model_catalog_merkle_root_sha256" => "H64",
      "static_model_install_report_sha256" => "H64",
      "source_before_expected_comparison_bool" => "B",
      "custom_vector_count_uint" => "U", "authority_bool" => "B",
      "historical_operation_bool" => "B", "operational_evidence_bool" => "B",
      "dependency_commitment_id" => "S",
      "dependency_commitment_json_pointer" => "S", "rule" => "S"
    },
    "constants_exact" => {
      "schema_type_id" => "CustomOperatorProjectionSourceClosureAssessmentV12",
      "blocked_reason_enum" => "ABSTAIN_MISSING_REQUIRED_START",
      "source_before_expected_comparison_bool" => true,
      "custom_vector_count_uint" => 259, "authority_bool" => false,
      "historical_operation_bool" => false, "operational_evidence_bool" => false,
      "dependency_commitment_id" => "CUSTOM_OPERATOR_INPUT_PROJECTIONS",
      "dependency_commitment_json_pointer" =>
        "/exact_record_schema_v12/decision_kernel_v12/custom_operator_input_projection_registry_v12"
    },
    "rule" => "ONLY_R00_AND_COUNTER_CLOSE_PRODUCTION_SHAPED_SOURCE_REPLAY;THREE_JOURNAL_DEPENDENT_ROUTES_REMAIN_OPERATIONALLY_BLOCKED"
  }
}
v12_cp_static_route_order_definitions = {
  "StaticModelLegacyRouteOrderV12" =>
    "EXACT_PROJECT_JOURNAL_ENVELOPE_THEN_JOURNAL_CHAIN_THEN_OUTER_CHAIN_ROUTE_ORDER",
  "CustomProjectionClosedProgramOrderV12" =>
    "EXACT_PROJECT_R00_INPUT_THEN_PROJECT_COUNTER_INPUT_SET_ORDER"
}

v12_cp_static_route_snapshot = clone(J)
begin
  static_schema_collisions =
    v12_cp_static_route_schema_definitions.keys & R.keys
  raise "custom static route schema collision #{static_schema_collisions.inspect}" unless
    static_schema_collisions.empty?
  static_order_collisions = v12_cp_static_route_order_definitions.keys &
    X.fetch("order_registry_v12").keys
  raise "custom static route order collision #{static_order_collisions.inspect}" unless
    static_order_collisions.empty?
  static_route_fields = %w[
    custom_operator_static_model_route_replay_v12
    custom_operator_projection_source_closure_assessment_v12
  ]
  static_field_collisions = static_route_fields.select { |field| D.key?(field) }
  raise "custom static route field collision #{static_field_collisions.inspect}" unless
    static_field_collisions.empty?
  route_projection_registry =
    D.fetch("custom_operator_input_projection_registry_v12")
  raise "custom static route binding collision" if
    route_projection_registry.key?("projection_source_assessment_fields_exact")
  custom_dependency_profile =
    S.dig("conformance_dependency_profiles_v12", "CUSTOM_OPERATOR")
  dependency_row = custom_dependency_profile.fetch("rows_exact").find do |row|
    row.fetch(0) == "CUSTOM_OPERATOR_INPUT_PROJECTIONS"
  end
  raise "custom static route dependency commitment missing" unless
    dependency_row == [
      "CUSTOM_OPERATOR_INPUT_PROJECTIONS",
      "/exact_record_schema_v12/decision_kernel_v12/custom_operator_input_projection_registry_v12"
    ]
  static_route_fields.each do |field|
    raise "custom registry payload field collision #{field}" if
      catalog.fetch("registry_payload_keys_exact_order").include?(field)
  end

  static_model_path = File.expand_path("c3-static-model-v2.rb", __dir__)
  require static_model_path unless defined?(V12C3StaticModelCarrierV2)
  static_model = V12C3StaticModelCarrierV2
  static_schema_definitions = static_model.schema_definitions
  static_order_definitions = static_model.order_definitions
  static_decision_fields = [
    static_model::CATALOG_FIELD, static_model::SCHEMA_FIELD,
    static_model::ORDER_FIELD
  ]
  static_presence = (
    static_schema_definitions.keys.map { |type_id| R.key?(type_id) } +
    static_order_definitions.keys.map do |order_id|
      X.fetch("order_registry_v12").key?(order_id)
    end +
    static_decision_fields.map { |field| D.key?(field) }
  )
  raise "static-model catalog must be installed by C3 carrier first" unless
    static_presence.all?
  static_schema_definitions.each do |type_id, definition|
    raise "static route schema join #{type_id}" unless
      R.fetch(type_id) == definition
  end
  static_order_definitions.each do |order_id, definition|
    raise "static route order join #{order_id}" unless
      X.fetch("order_registry_v12").fetch(order_id) == definition
  end
  raise "static route schema registry join" unless
    D.fetch(static_model::SCHEMA_FIELD) == static_schema_definitions
  raise "static route order registry join" unless
    D.fetch(static_model::ORDER_FIELD) == static_order_definitions

  static_install_receipt_type_id =
    "StaticModelJournalAlgebraInstallReceiptV12"
  static_self_test_receipt_type_id =
    "StaticModelJournalAlgebraSelfTestReceiptV12"
  static_install_receipt_field =
    "static_model_journal_algebra_install_receipt_v12"
  static_self_test_receipt_field =
    "static_model_journal_algebra_self_test_receipt_v12"
  raise "static-model install receipt schema missing" unless
    R.key?(static_install_receipt_type_id)
  raise "static-model self-test receipt schema missing" unless
    R.key?(static_self_test_receipt_type_id)
  static_install_report = D.fetch(static_install_receipt_field)
  static_self_test = D.fetch(static_self_test_receipt_field)

  static_catalog = D.fetch(static_model::CATALOG_FIELD)
  static_model.validate_catalog!(J, static_catalog)
  raise "static route persisted receipt join" unless
    static_install_report.fetch("catalog_field") ==
      static_model::CATALOG_FIELD &&
    static_install_report.fetch("catalog_payload_sha256") ==
      static_catalog.fetch("catalog_payload_sha256") &&
    static_install_report.fetch("catalog_merkle_root_sha256") ==
      static_catalog.dig("merkle_commitment", "root_sha256") &&
    static_install_report.fetch("installed_order_ids_exact") ==
      static_order_definitions.keys &&
    static_install_report.fetch("operational_schema_sha256_before") ==
      static_install_report.fetch("operational_schema_sha256_after") &&
    static_install_report.fetch("operational_schemas_unchanged_bool") == true &&
    static_self_test.fetch("result_enum") == "PASS" &&
    static_self_test.fetch("catalog_payload_sha256") ==
      static_catalog.fetch("catalog_payload_sha256") &&
    static_self_test.fetch("merkle_root_sha256") ==
      static_catalog.dig("merkle_commitment", "root_sha256") &&
    static_self_test.fetch("negative_case_count_uint") == 5 &&
    static_self_test.fetch("operational_replay_state_enum") ==
      "ABSTAIN_MISSING_REQUIRED_START" &&
    static_self_test.fetch("operational_frame_rows_emitted_uint") == 0 &&
    static_self_test.fetch("authority_closed_bool") == false

  v12_cp_static_route_schema_definitions.each do |type_id, definition|
    R[type_id] = clone(definition)
  end
  v12_cp_static_route_order_definitions.each do |order_id, definition|
    X.fetch("order_registry_v12")[order_id] = definition
  end

  def v12_cp_replay_static_route!(control, static_catalog, source, route_id)
    model = V12C3StaticModelCarrierV2
    model.validate_catalog!(control, static_catalog)
    expected_source = model.shared_route_source!(
      :control => control, :catalog => static_catalog, :route_id => route_id
    )
    raise "static route source/catalog join #{route_id}" unless
      source == expected_source

    ids = source.fetch("selected_fixture_ids")
    digests = source.fetch("selected_complete_frame_sha256s")
    raise "static route selected row count #{route_id}" unless
      ids.length == digests.length
    entries = ids.each_with_index.map do |fixture_id, index|
      entry = model.entry_by_fixture_id!(static_catalog, fixture_id)
      plan = model::JOURNAL::CATALOG_PLAN.find do |row|
        row.fetch(0) == fixture_id
      end
      raise "static route plan missing #{fixture_id}" unless plan
      _envelope, _bytes, identity = model.parse_model_frame!(
        control, entry.fetch("complete_frame_raw_bytes"), plan
      )
      digest = digests.fetch(index)
      raise "static route selected digest join #{fixture_id}" unless
        digest == identity.fetch("complete_frame_sha256") &&
        digest == entry.dig("frame_identity", "complete_frame_sha256")
      entry
    end

    predecessor_join = entries.each_cons(2).all? do |predecessor, successor|
      predecessor.dig("frame_identity", "complete_frame_sha256") ==
        successor.dig(
          "frame_identity",
          "previous_complete_frame_with_lf_sha256_or_null"
        )
    end
    assessment = source.fetch("operational_replay_assessment")
    unless assessment == static_catalog.fetch("operational_replay_assessment") &&
           assessment.fetch("state_enum") ==
             "ABSTAIN_MISSING_REQUIRED_START" &&
           assessment.fetch("required_source_available_bool") == false &&
           assessment.fetch("record_frame_bytes_rows_emitted_uint") == 0 &&
           assessment.fetch("record_observations_emitted_uint") == 0 &&
           assessment.fetch("operational_frame_reference_emitted_uint") == 0 &&
           assessment.fetch("operation_prefix_projection_closed_bool") == false &&
           assessment.fetch("authority_closed_bool") == false &&
           assessment.fetch("historical_operation_asserted_bool") == false &&
           assessment.fetch("operational_evidence_asserted_bool") == false
      raise "static route operational quarantine #{route_id}"
    end

    {
      "route_id" => route_id,
      "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA",
      "catalog_payload_sha256" => source.fetch("catalog_payload_sha256"),
      "catalog_merkle_root_sha256" =>
        source.fetch("catalog_merkle_root_sha256"),
      "selected_fixture_count_uint" => ids.length,
      "selected_fixture_ids" => clone(ids),
      "selected_complete_frame_sha256s" => clone(digests),
      "exact_envelope_key_order_all_bool" => true,
      "payload_digest_join_all_bool" => true,
      "predecessor_digest_join_all_bool" => predecessor_join,
      "catalog_merkle_root_join_bool" =>
        source.fetch("catalog_merkle_root_sha256") ==
          static_catalog.dig("merkle_commitment", "root_sha256"),
      "static_model_symbols_or_null" =>
        clone(source.fetch("static_model_symbols_or_null")),
      "operational_projection_state_enum" => assessment.fetch("state_enum"),
      "normalized_production_input_emitted_bool" => false,
      "authority_bool" => false,
      "historical_operation_bool" => false,
      "operational_evidence_bool" => false
    }
  end

  # This expected assessment is constructed only after source replay.  It
  # reads the immutable static catalog, never a normalized operator fixture or
  # vector expectation.
  def v12_cp_expected_static_route_assessment(static_catalog, route_id)
    entries = static_catalog.fetch("entries")
    selected = case route_id
    when "PROJECT_JOURNAL_ENVELOPE_INPUT"
      [entries.fetch(0)]
    when "PROJECT_JOURNAL_CHAIN_INPUT", "PROJECT_OUTER_CHAIN_INPUT"
      entries
    else
      raise "unsupported static legacy route #{route_id}"
    end
    symbols = case route_id
    when "PROJECT_JOURNAL_CHAIN_INPUT"
      ["INCOMPLETE"] * 6
    when "PROJECT_OUTER_CHAIN_INPUT"
      (["INCOMPLETE"] * 6) + ["ABSENT_TERMINAL"]
    else
      nil
    end
    {
      "route_id" => route_id,
      "source_domain_enum" => "STATIC_MODEL_EXACT_ENVELOPE_ALGEBRA",
      "catalog_payload_sha256" =>
        static_catalog.fetch("catalog_payload_sha256"),
      "catalog_merkle_root_sha256" =>
        static_catalog.dig("merkle_commitment", "root_sha256"),
      "selected_fixture_count_uint" => selected.length,
      "selected_fixture_ids" =>
        selected.map { |entry| entry.fetch("fixture_id") },
      "selected_complete_frame_sha256s" => selected.map do |entry|
        entry.dig("frame_identity", "complete_frame_sha256")
      end,
      "exact_envelope_key_order_all_bool" => true,
      "payload_digest_join_all_bool" => true,
      "predecessor_digest_join_all_bool" => true,
      "catalog_merkle_root_join_bool" => true,
      "static_model_symbols_or_null" => symbols,
      "operational_projection_state_enum" =>
        "ABSTAIN_MISSING_REQUIRED_START",
      "normalized_production_input_emitted_bool" => false,
      "authority_bool" => false,
      "historical_operation_bool" => false,
      "operational_evidence_bool" => false
    }
  end

  def v12_cp_rename_vector!(catalog_value, vectors, old_id, new_id)
    vector = vectors.delete(old_id)
    raise "source projection vector missing #{old_id}" unless vector
    raise "source projection vector duplicate #{new_id}" if vectors.key?(new_id)
    vector["vector_id"] = new_id
    vectors[new_id] = vector
    catalog_value.fetch("conformance_set_rows_exact").each do |row|
      row.fetch(1).map! do |vector_id|
        vector_id == old_id ? new_id : vector_id
      end
    end
    vector
  end

  static_route_specs = [
    ["PROJECT_JOURNAL_ENVELOPE_INPUT", "JOURNAL_ENVELOPE_CHAIN_VALID"],
    ["PROJECT_JOURNAL_CHAIN_INPUT", "JOURNAL_CHAIN_OUTCOME_IS"],
    ["PROJECT_OUTER_CHAIN_INPUT", "OUTER_CHAIN_OUTCOME_IS"]
  ]
  static_route_assessments = []
  static_route_source_fixture_ids = []

  # Phase one: construct and replay every source before reading any expected
  # result or normalized fixture.
  static_source_replays = {}
  static_route_specs.each do |program_id, _operator_id|
    source = static_model.shared_route_source!(
      :control => J, :catalog => static_catalog, :route_id => program_id
    )
    source_fixture_id =
      "SOURCE_PROJECTION_#{program_id}_STATIC_MODEL_SOURCE"
    v12_cp_replace_fixture!(
      fixtures_by_id, source_fixture_id,
      "StaticModelLegacyRouteSourceV12", source
    )
    decoded_source = v12_cp_decode_custom_fixture(
      fixtures_by_id.fetch(source_fixture_id)
    )
    replayed = v12_cp_replay_static_route!(
      J, static_catalog, decoded_source, program_id
    )
    static_source_replays[program_id] = [source_fixture_id, replayed]
    static_route_source_fixture_ids << source_fixture_id
  end

  # Phase two: compare the independent abstract expectation, then mark the
  # production normalized input unavailable.  Static algebra is not promoted.
  static_route_specs.each do |program_id, operator_id|
    source_fixture_id, replayed = static_source_replays.fetch(program_id)
    expected = v12_cp_expected_static_route_assessment(
      static_catalog, program_id
    )
    raise "static route source/expected mismatch #{program_id}" unless
      replayed == expected
    static_route_assessments << expected.merge(
      "source_fixture_id" => source_fixture_id,
      "source_fixture_sha256" =>
        fixtures_by_id.fetch(source_fixture_id).fetch("sha256")
    )

    old_vector_id = "SOURCE_PROJECTION_#{program_id}_TRUE"
    abstain_vector_id =
      "SOURCE_PROJECTION_#{program_id}_STATIC_MODEL_ABSTAIN"
    vector = v12_cp_rename_vector!(
      catalog, vectors_by_id, old_vector_id, abstain_vector_id
    )
    vector["operator_id"] = operator_id
    vector["bindings"] = [
      v12_cp_unavailable_binding("NORMALIZED_INPUT"),
      v12_cp_source_binding(source_fixture_id)
    ]
    vector["expected_result"] = v12_cp_eval_unavailable

    [
      "#{old_vector_id}_SOURCE", "#{old_vector_id}_INPUT",
      "SOURCE_PROJECTION_#{program_id}_UNAVAILABLE_SOURCE"
    ].each { |fixture_id| fixtures_by_id.delete(fixture_id) }

    unavailable_vector = vectors_by_id.fetch(
      "SOURCE_PROJECTION_#{program_id}_UNAVAILABLE"
    )
    unavailable_vector["bindings"] = [
      v12_cp_unavailable_binding("NORMALIZED_INPUT"),
      v12_cp_unavailable_binding("SOURCE_INSTANCE")
    ]
    unavailable_vector["expected_result"] = v12_cp_eval_unavailable
  end

  # Typed-source negatives mutate retained facts before replay and must fail at
  # the source/catalog join, before any expectation is inspected.
  static_route_specs.each do |program_id, _operator_id|
    source_fixture_id, = static_source_replays.fetch(program_id)
    mutation = v12_cp_decode_custom_fixture(
      fixtures_by_id.fetch(source_fixture_id)
    )
    mutation.fetch("selected_complete_frame_sha256s")[0] = "0" * 64
    rejected = begin
      v12_cp_replay_static_route!(J, static_catalog, mutation, program_id)
      false
    rescue RuntimeError, V12C3StaticModelCarrierV2::ModelError
      true
    end
    raise "static typed-source mutation accepted #{program_id}" unless rejected
  end

  {
    "JOURNAL_ENVELOPE_CHAIN_VALID" => "StaticModelLegacyRouteSourceV12",
    "JOURNAL_CHAIN_OUTCOME_IS" => "StaticModelLegacyRouteSourceV12",
    "OUTER_CHAIN_OUTCOME_IS" => "StaticModelLegacyRouteSourceV12"
  }.each do |operator_id, source_type_id|
    index = source_rows_exact.index { |row| row.fetch(0) == operator_id }
    raise "legacy replay row missing #{operator_id}" unless index
    source_rows_exact[index][1] = source_type_id
  end
  replay["rule"] = replay.fetch("rule") +
    ";STATIC_MODEL_LEGACY_ROUTE_SOURCES_REPLAY_EXACT_RAW_ENVELOPE_PAYLOAD_PREDECESSOR_AND_MERKLE_ALGEBRA_BEFORE_EXPECTATION_COMPARISON_BUT_NEVER_EMIT_A_PRODUCTION_NORMALIZED_INPUT_WITHOUT_REQUIRED_START"

  obsolete_selector_type_id =
    "LegacyCustomProjection" + "ConformanceSourceV12"
  selector_fixture_ids = fixtures_by_id.values.select do |row|
    row.fetch("type_id") == obsolete_selector_type_id
  end.map { |row| row.fetch("fixture_id") }
  selector_fixture_ids.each { |fixture_id| fixtures_by_id.delete(fixture_id) }
  raise "obsolete selector source schema missing" unless
    R.delete(obsolete_selector_type_id)

  catalog["fixtures"] = fixtures_by_id.values.sort_by do |row|
    row.fetch("fixture_id")
  end
  catalog["vectors"] = vectors_by_id.values.sort_by do |row|
    row.fetch("vector_id")
  end
  catalog["expected_result_rows"] = catalog.fetch("vectors").map do |row|
    [row.fetch("vector_id"), clone(row.fetch("expected_result"))]
  end
  catalog["fixture_count_uint"] = catalog.fetch("fixtures").length
  catalog["vector_count_uint"] = catalog.fetch("vectors").length
  raise "static route carrier changed custom vector count" unless
    catalog.fetch("vector_count_uint") == 259
  raise "static route carrier vector partition" unless
    catalog.fetch("conformance_set_rows_exact").flat_map do |row|
      row.fetch(1)
    end.sort == catalog.fetch("vectors").map do |row|
      row.fetch("vector_id")
    end.sort
  raise "static route fixture count" unless
    static_route_source_fixture_ids.length == 3 &&
    static_route_source_fixture_ids.uniq.length == 3
  raise "selector source fixture survived replacement" if
    catalog.fetch("fixtures").any? do |row|
      row.fetch("type_id") == obsolete_selector_type_id
    end

  coverage = catalog.fetch("coverage_exact")
  legacy_coverage_index = coverage.index do |row|
    row.start_with?(
      "ALL_FIVE_ORIGINAL_UNIQUE_SOURCE_PROJECTION_PROGRAMS_"
    )
  end
  raise "legacy source coverage row missing" unless legacy_coverage_index
  coverage[legacy_coverage_index] =
    "ALL_FIVE_ORIGINAL_UNIQUE_SOURCE_PROJECTION_PROGRAMS_HAVE_TYPED_SOURCE_ROUTES;R00_AND_COUNTER_CLOSE_PRODUCTION_SHAPED_REPLAY;THE_THREE_JOURNAL_DEPENDENT_ROUTES_CLOSE_ONLY_QUARANTINED_CONTENT_ADDRESSED_STATIC_ENVELOPE_PAYLOAD_PREDECESSOR_AND_MERKLE_ALGEBRA_AND_RETAIN_ABSTAIN_MISSING_REQUIRED_START;ALL_DEDICATED_ROUTES_RETAIN_REQUIRED_SOURCE_UNAVAILABLE;NORMALIZED_PASS_FAIL_TRUTH_TABLES_REMAIN_SEPARATE"

  D["custom_operator_static_model_route_replay_v12"] = {
    "schema_type_id" => "CustomOperatorStaticModelRouteReplayV12",
    "static_model_catalog_payload_sha256" =>
      static_catalog.fetch("catalog_payload_sha256"),
    "static_model_catalog_merkle_root_sha256" =>
      static_catalog.dig("merkle_commitment", "root_sha256"),
    "shared_module_self_test_sha256" => sha(static_self_test),
    "source_fixture_ids_exact" => clone(static_route_source_fixture_ids),
    "route_assessments_exact" => clone(static_route_assessments),
    "typed_source_negative_case_count_uint" => 3,
    "shared_static_model_negative_case_count_uint" =>
      static_self_test.fetch("negative_case_count_uint"),
    "source_before_expected_comparison_bool" => true,
    "normalized_production_inputs_emitted_uint" => 0,
    "record_frame_bytes_rows_emitted_uint" => 0,
    "record_observations_emitted_uint" => 0,
    "operational_frame_reference_emitted_uint" => 0,
    "authority_bool" => false,
    "historical_operation_bool" => false,
    "operational_evidence_bool" => false,
    "operational_projection_state_enum" =>
      "ABSTAIN_MISSING_REQUIRED_START",
    "dependency_commitment_id" => "CUSTOM_OPERATOR_INPUT_PROJECTIONS",
    "dependency_commitment_json_pointer" =>
      "/exact_record_schema_v12/decision_kernel_v12/custom_operator_input_projection_registry_v12"
  }

  D["custom_operator_projection_source_closure_assessment_v12"] = {
    "schema_type_id" =>
      "CustomOperatorProjectionSourceClosureAssessmentV12",
    "closed_programs_exact" => [
      "PROJECT_R00_INPUT", "PROJECT_COUNTER_INPUT_SET"
    ],
    "static_model_algebra_programs_exact" =>
      static_route_specs.map(&:first),
    "blocked_production_programs_exact" =>
      static_route_specs.map(&:first),
    "blocked_reason_enum" => "ABSTAIN_MISSING_REQUIRED_START",
    "static_model_catalog_payload_sha256" =>
      static_catalog.fetch("catalog_payload_sha256"),
    "static_model_catalog_merkle_root_sha256" =>
      static_catalog.dig("merkle_commitment", "root_sha256"),
    "static_model_install_report_sha256" => sha(static_install_report),
    "source_before_expected_comparison_bool" => true,
    "custom_vector_count_uint" => catalog.fetch("vector_count_uint"),
    "authority_bool" => false,
    "historical_operation_bool" => false,
    "operational_evidence_bool" => false,
    "dependency_commitment_id" => "CUSTOM_OPERATOR_INPUT_PROJECTIONS",
    "dependency_commitment_json_pointer" =>
      "/exact_record_schema_v12/decision_kernel_v12/custom_operator_input_projection_registry_v12",
    "rule" =>
      "R00_AND_COUNTER_REPLAY_ACTUAL_TYPED_SOURCE_FACTS;JOURNAL_ENVELOPE_JOURNAL_CHAIN_AND_OUTER_CHAIN_REPLAY_ONLY_THE_SHARED_QUARANTINED_STATIC_MODEL_ALGEBRA;THE_STATIC_BYTES_HAVE_EXACT_ENVELOPE_KEY_ORDER_PAYLOAD_PREDECESSOR_AND_MERKLE_JOINS_BUT_TYPED_BODY_HOLES_FOR_REQUIRED_START_FORCE_OPERATIONAL_ABSTAIN_AND_NULL_NORMALIZED_PRODUCTION_INPUT;NO_STATIC_RESULT_CLOSES_AUTHORITY_HISTORY_OR_OPERATIONAL_EVIDENCE"
  }

  route_projection_registry["projection_source_assessment_fields_exact"] = [
    [
      "custom_operator_static_model_route_replay_v12",
      "CustomOperatorStaticModelRouteReplayV12",
      "/exact_record_schema_v12/reusable_objects/CustomOperatorStaticModelRouteReplayV12"
    ],
    [
      "custom_operator_projection_source_closure_assessment_v12",
      "CustomOperatorProjectionSourceClosureAssessmentV12",
      "/exact_record_schema_v12/reusable_objects/CustomOperatorProjectionSourceClosureAssessmentV12"
    ]
  ]
  route_projection_registry["projection_source_assessment_dependency_exact"] = {
    "dependency_id" => "CUSTOM_OPERATOR_INPUT_PROJECTIONS",
    "json_pointer" =>
      "/exact_record_schema_v12/decision_kernel_v12/custom_operator_input_projection_registry_v12",
    "commits_full_registry_object_bool" => true
  }
  static_route_fields.each do |field|
    catalog.fetch("registry_payload_keys_exact_order") << field
  end
  raise "custom registry payload ids" unless
    catalog.fetch("registry_payload_keys_exact_order").uniq.length ==
      catalog.fetch("registry_payload_keys_exact_order").length
rescue StandardError
  v12_cp_restore_install_root!(v12_cp_static_route_snapshot)
  raise
end
