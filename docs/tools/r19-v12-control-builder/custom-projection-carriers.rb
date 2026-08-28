# frozen_string_literal: true

# Scratch-only V12 custom-projection source closure.
#
# This file is intended to be eval'd from finalize-control.rb after the other
# carrier overlays and before any catalog digest is computed.  It never reads
# an expected normalized fixture while constructing a source.  R00 sources are
# built from actual production-typed binding values.  Counter sources are
# replayed from actual typed receipts, source-instance bytes, snapshots, and
# held control tables.  Journal-dependent routes reuse the shared quarantined
# static-model catalog: it retains exact raw envelope bytes and closes only
# payload, predecessor, and Merkle algebra.  Operational production projection
# remains ABSTAIN_MISSING_REQUIRED_START.

def v12_cp_error_native(code, errno_value = 5)
  value = error_none
  value["state_enum"] = "NATIVE_ERRNO"
  value["code_string_or_null"] = code
  value["errno_int_or_null"] = errno_value
  value
end

def v12_cp_vnode(ordinal, type = "DIRECTORY")
  {
    "type_enum" => type,
    "device_uint" => 91,
    "inode_uint" => 91_000 + ordinal,
    "generation_uint" => 12,
    "uid_uint" => J.dig("roots", "uid"),
    "gid_uint" => J.dig("roots", "gid"),
    "mode_octal4" => type == "DIRECTORY" ? J.dig("roots", "mode") : "0600",
    "nlink_uint" => type == "DIRECTORY" ? 2 : 1,
    "flags_uint" => 0,
    "size_uint" => 0,
    "ctime_seconds_int" => 1,
    "ctime_nanoseconds_uint" => 1,
    "mtime_seconds_int" => 1,
    "mtime_nanoseconds_uint" => 1
  }
end

def v12_cp_named_join(path, vnode)
  {
    "path" => path,
    "state_enum" => "JOINED",
    "held_before_or_null" => clone(vnode),
    "held_after_or_null" => clone(vnode),
    "named_after_or_null" => clone(vnode),
    "held_stable_bool_or_null" => true,
    "named_join_bool_or_null" => true,
    "error" => error_none
  }
end

def v12_cp_absent_join(path)
  {
    "path" => path,
    "state_enum" => "ABSENT",
    "held_before_or_null" => nil,
    "held_after_or_null" => nil,
    "named_after_or_null" => nil,
    "held_stable_bool_or_null" => nil,
    "named_join_bool_or_null" => nil,
    "error" => error_none
  }
end

def v12_cp_inventory_name(name)
  {"raw_hex" => name.b.unpack1("H*"), "utf8_display_or_null" => name}
end

def v12_cp_inventory(names, requested)
  rows = names.sort_by { |name| name.b.bytes }.map { |name| v12_cp_inventory_name(name) }
  if requested
    {
      "state_enum" => "COMPLETE",
      "cap_entries_uint" => 4096,
      "observed_names" => rows,
      "observed_count_uint" => rows.length,
      "total_count_uint_or_null" => rows.length,
      "overflow_witness_bool_or_null" => false,
      "error" => error_none
    }
  else
    {
      "state_enum" => "NOT_REQUESTED",
      "cap_entries_uint" => 4096,
      "observed_names" => [],
      "observed_count_uint" => 0,
      "total_count_uint_or_null" => nil,
      "overflow_witness_bool_or_null" => nil,
      "error" => error_none
    }
  end
end

def v12_cp_namespace_assessment(required_names, allowed_names, observed_names)
  required = required_names.sort_by { |name| name.b.bytes }.map { |name| v12_cp_inventory_name(name) }
  allowed = allowed_names.sort_by { |name| name.b.bytes }.map { |name| v12_cp_inventory_name(name) }
  observed = observed_names.sort_by { |name| name.b.bytes }.map { |name| v12_cp_inventory_name(name) }
  {
    "role_enum" => "DIRECTORY_SNAPSHOT",
    "required_names" => required,
    "allowed_names" => allowed,
    "observed_names" => observed,
    "missing_required_names" => [],
    "unexpected_names" => [],
    "retained_residual_names" => [],
    "nonconforming_names" => [],
    "classification_complete_bool" => true,
    "integrity_bool" => true,
    "error" => error_none
  }
end

def v12_cp_directory_operation(plan_row, state)
  ordinal, label, parent_label, leaf, = plan_row
  base = {
    "ordinal_uint" => ordinal,
    "label" => label,
    "parent_label" => parent_label,
    "leaf" => leaf,
    "state_enum" => state,
    "attempted_bool" => false,
    "last_completed_step_enum" => "NONE",
    "created_side_effect_bool_or_null" => nil,
    "native_result_int_or_null" => nil,
    "held_vnode_or_null" => nil,
    "named_vnode_or_null" => nil,
    "named_join_bool_or_null" => nil,
    "parent_fsync_bool_or_null" => nil,
    "parent_fullsync_bool_or_null" => nil,
    "error" => error_none
  }
  case state
  when "NOT_ENTERED"
    base
  when "CREATED_JOINED"
    vnode = v12_cp_vnode(ordinal)
    base.merge(
      "attempted_bool" => true,
      "last_completed_step_enum" => "NAMED_REJOINED",
      "created_side_effect_bool_or_null" => true,
      "native_result_int_or_null" => 0,
      "held_vnode_or_null" => clone(vnode),
      "named_vnode_or_null" => clone(vnode),
      "named_join_bool_or_null" => true,
      "parent_fsync_bool_or_null" => true,
      "parent_fullsync_bool_or_null" => true
    )
  when "OPEN_FAILED"
    base.merge(
      "attempted_bool" => true,
      "last_completed_step_enum" => "MKDIR_ENTERED",
      "created_side_effect_bool_or_null" => true,
      "native_result_int_or_null" => -1,
      "error" => v12_cp_error_native("R00_CONFORMANCE_OPEN_FAILED")
    )
  when "SYNC_FAILED"
    base.merge(
      "attempted_bool" => true,
      "last_completed_step_enum" => "POLICY_VALIDATED",
      "created_side_effect_bool_or_null" => true,
      "native_result_int_or_null" => -1,
      "held_vnode_or_null" => v12_cp_vnode(ordinal),
      "error" => v12_cp_error_native("R00_CONFORMANCE_FSYNC_FAILED")
    )
  else
    raise "unsupported R00 carrier state #{state.inspect}"
  end
end

def v12_cp_directory_operation_valid?(row, plan_row)
  ordinal, label, parent_label, leaf, = plan_row
  return false unless [row["ordinal_uint"], row["label"], row["parent_label"], row["leaf"]] == [ordinal, label, parent_label, leaf]
  case row["state_enum"]
  when "NOT_ENTERED"
    row["attempted_bool"] == false &&
      row["last_completed_step_enum"] == "NONE" &&
      %w[
        created_side_effect_bool_or_null native_result_int_or_null
        held_vnode_or_null named_vnode_or_null named_join_bool_or_null
        parent_fsync_bool_or_null parent_fullsync_bool_or_null
      ].all? { |key| row[key].nil? } && row.dig("error", "state_enum") == "NONE"
  when "CREATED_JOINED"
    vnode = row["held_vnode_or_null"]
    row["attempted_bool"] == true &&
      row["last_completed_step_enum"] == "NAMED_REJOINED" &&
      row["created_side_effect_bool_or_null"] == true &&
      row["native_result_int_or_null"] == 0 &&
      vnode && row["named_vnode_or_null"] == vnode &&
      row["named_join_bool_or_null"] == true &&
      row["parent_fsync_bool_or_null"] == true &&
      row["parent_fullsync_bool_or_null"] == true &&
      row.dig("error", "state_enum") == "NONE"
  when "OPEN_FAILED"
    row["attempted_bool"] == true &&
      row["last_completed_step_enum"] == "MKDIR_ENTERED" &&
      row["created_side_effect_bool_or_null"] == true &&
      row["native_result_int_or_null"].is_a?(Integer) && row["native_result_int_or_null"] != 0 &&
      %w[
        held_vnode_or_null named_vnode_or_null named_join_bool_or_null
        parent_fsync_bool_or_null parent_fullsync_bool_or_null
      ].all? { |key| row[key].nil? } && row.dig("error", "state_enum") == "NATIVE_ERRNO"
  when "SYNC_FAILED"
    row["attempted_bool"] == true &&
      row["last_completed_step_enum"] == "POLICY_VALIDATED" &&
      row["created_side_effect_bool_or_null"] == true &&
      row["native_result_int_or_null"].is_a?(Integer) && row["native_result_int_or_null"] != 0 &&
      !row["held_vnode_or_null"].nil? && row["named_vnode_or_null"].nil? &&
      row["named_join_bool_or_null"].nil? &&
      row["parent_fsync_bool_or_null"].nil? && row["parent_fullsync_bool_or_null"].nil? &&
      row.dig("error", "state_enum") == "NATIVE_ERRNO"
  else
    false
  end
end

def v12_cp_snapshot(path, present, vnode, required_names, allowed_names)
  names = present ? required_names : []
  {
    "path" => path,
    "join" => present ? v12_cp_named_join(path, vnode) : v12_cp_absent_join(path),
    "inventory" => v12_cp_inventory(names, present),
    "namespace_assessment" => v12_cp_namespace_assessment(names, allowed_names, names)
  }
end

def v12_cp_first_unentered(plan, ordinal)
  if ordinal.nil?
    {
      "present_bool" => false,
      "operation_label_or_null" => nil,
      "reason_predicate_id_or_null" => nil
    }
  else
    {
      "present_bool" => true,
      "operation_label_or_null" => plan.fetch(ordinal).fetch(1),
      "reason_predicate_id_or_null" => "R00_DIRECTORY_OPERATION_NOT_ENTERED"
    }
  end
end

def v12_cp_build_r00_body(states, first_unentered_ordinal, identity_mismatch: false)
  plan = S.dig("set_profile_registry_v12", "directory_operations", "R00_EXACT_31", "rows_exact_order")
  raise "R00 plan missing" unless plan.is_a?(Array) && plan.length == 31
  raise "R00 source state count" unless states.length == plan.length
  operations = plan.zip(states).map { |plan_row, state| v12_cp_directory_operation(plan_row, state) }
  effects = operations.map { |row| row["created_side_effect_bool_or_null"] == true }
  root_labels = %w[TEST_ROOT A_ROOT B_ROOT]
  root_paths = J.dig("roots", "creation_order")
  root_snapshots = root_labels.zip(root_paths).map.with_index do |(root_label, path), root_index|
    root_ordinal = plan.index { |row| row.fetch(1) == root_label }
    root_present = effects.fetch(root_ordinal)
    child_rows = plan.select { |row| row.fetch(2) == root_label }
    present_child_names = child_rows.select { |row| effects.fetch(row.fetch(0)) }.map { |row| row.fetch(3) }
    allowed_child_names = child_rows.map { |row| row.fetch(3) }
    source_vnode = operations.fetch(root_ordinal)["held_vnode_or_null"] || v12_cp_vnode(root_ordinal)
    snapshot_vnode = clone(source_vnode)
    snapshot_vnode["inode_uint"] += 1 if identity_mismatch && root_index.zero?
    v12_cp_snapshot(path, root_present, snapshot_vnode, present_child_names, allowed_child_names)
  end
  journal_row = plan.fetch(10)
  journal_present = effects.fetch(10)
  journal_vnode = operations.fetch(10)["held_vnode_or_null"] || v12_cp_vnode(10)
  journal_snapshot = v12_cp_snapshot(journal_row.fetch(4), journal_present, journal_vnode, [], [])
  absence_paths = J.dig("roots", "absence_check_order_immediately_before_first_mkdirat")
  {
    "directory_operations" => operations,
    "root_absence_checks" => {
      "label" => "R00_ROOT_ABSENCE_BEFORE_FIRST_MKDIRAT",
      "expected_count_uint" => absence_paths.length,
      "joins" => absence_paths.map { |path| v12_cp_absent_join(path) },
      "observed_count_uint" => absence_paths.length,
      "complete_bool" => true,
      "error" => error_none
    },
    "root_snapshots" => root_snapshots,
    "journal_snapshot_before_r00_publication" => journal_snapshot,
    "first_unentered" => v12_cp_first_unentered(plan, first_unentered_ordinal)
  }
end

def v12_cp_r00_topology_exact?(body)
  plan = S.dig("set_profile_registry_v12", "directory_operations", "R00_EXACT_31", "rows_exact_order")
  operations = body.fetch("directory_operations")
  return false unless operations.length == 31
  return false unless operations.zip(plan).all? { |row, plan_row| v12_cp_directory_operation_valid?(row, plan_row) }
  pairs = D.dig("custom_operator_programs_v12", "R00_TOPOLOGY_PROGRAM", "state_created_side_effect_pairs_exact").to_h
  return false unless operations.all? do |row|
    if row.fetch("state_enum") == "NOT_ENTERED"
      row.fetch("created_side_effect_bool_or_null").nil?
    else
      pairs.fetch(row.fetch("state_enum")) == row.fetch("created_side_effect_bool_or_null")
    end
  end
  absence_paths = J.dig("roots", "absence_check_order_immediately_before_first_mkdirat")
  absence = body.fetch("root_absence_checks")
  return false unless absence.fetch("complete_bool") && absence.fetch("expected_count_uint") == absence_paths.length
  return false unless absence.fetch("joins").map { |row| row.fetch("path") } == absence_paths
  return false unless absence.fetch("joins").all? { |row| row.fetch("state_enum") == "ABSENT" }

  effects = operations.map { |row| row["created_side_effect_bool_or_null"] == true }
  root_labels = %w[TEST_ROOT A_ROOT B_ROOT]
  roots = body.fetch("root_snapshots")
  return false unless roots.length == 3
  root_labels.zip(J.dig("roots", "creation_order"), roots).each do |root_label, path, snapshot|
    return false unless snapshot.fetch("path") == path
    root_ordinal = plan.index { |row| row.fetch(1) == root_label }
    present = effects.fetch(root_ordinal)
    expected_names = plan.select { |row| row.fetch(2) == root_label && effects.fetch(row.fetch(0)) }.map { |row| row.fetch(3) }
    if present
      return false unless snapshot.dig("join", "state_enum") == "JOINED"
      observed = snapshot.dig("inventory", "observed_names").map { |row| [row.fetch("raw_hex")].pack("H*") }
      return false unless observed.sort_by { |name| name.b.bytes } == expected_names.sort_by { |name| name.b.bytes }
      operation = operations.fetch(root_ordinal)
      if operation.fetch("state_enum") == "CREATED_JOINED"
        return false unless snapshot.dig("join", "held_before_or_null") == operation.fetch("held_vnode_or_null")
      end
    else
      return false unless snapshot.dig("join", "state_enum") == "ABSENT"
      return false unless snapshot.dig("inventory", "state_enum") == "NOT_REQUESTED"
    end
    return false unless snapshot.dig("namespace_assessment", "integrity_bool") == true
  end

  journal = body.fetch("journal_snapshot_before_r00_publication")
  journal_operation = operations.fetch(10)
  return false unless journal.fetch("path") == plan.fetch(10).fetch(4)
  if effects.fetch(10)
    return false unless journal.dig("join", "state_enum") == "JOINED"
    if journal_operation.fetch("state_enum") == "CREATED_JOINED"
      return false unless journal.dig("join", "held_before_or_null") == journal_operation.fetch("held_vnode_or_null")
    end
  else
    return false unless journal.dig("join", "state_enum") == "ABSENT"
  end
  true
rescue KeyError, TypeError
  false
end

def v12_cp_project_r00(source)
  return nil if source.fetch("state_enum") == "UNAVAILABLE"
  raise "R00 source state" unless source.fetch("state_enum") == "AVAILABLE"
  body = source.fetch("current_r00_body_or_null")
  raise "R00 available body missing" unless body
  plan = S.dig("set_profile_registry_v12", "directory_operations", "R00_EXACT_31", "rows_exact_order")
  operations = body.fetch("directory_operations")
  pairs = D.dig("custom_operator_programs_v12", "R00_TOPOLOGY_PROGRAM", "state_created_side_effect_pairs_exact").to_h
  first = body.fetch("first_unentered")
  first_ordinal = if first.fetch("present_bool")
    label = first.fetch("operation_label_or_null")
    row = plan.find { |candidate| candidate.fetch(1) == label }
    raise "R00 first-unentered label" unless row
    row.fetch(0)
  else
    raise "R00 absent first-unentered payload" unless first.fetch("operation_label_or_null").nil? && first.fetch("reason_predicate_id_or_null").nil?
    nil
  end
  {
    "states" => operations.map { |row| row.fetch("state_enum") },
    "created_side_effects" => operations.map { |row| pairs.fetch(row.fetch("state_enum")) },
    "topology_projection_exact_bool" => v12_cp_r00_topology_exact?(body),
    "first_unentered_ordinal_or_null" => first_ordinal
  }
end

def v12_cp_decode_custom_fixture(fixture)
  bytes = Base64.strict_decode64(fixture.fetch("canonical_json_base64"))
  raise "fixture byte count #{fixture.fetch("fixture_id")}" unless bytes.bytesize == fixture.fetch("bytes_uint")
  raise "fixture hash #{fixture.fetch("fixture_id")}" unless sha(bytes) == fixture.fetch("sha256")
  value = JSON.parse(bytes)
  raise "fixture canonical #{fixture.fetch("fixture_id")}" unless canon(value) == bytes
  value
end

def v12_cp_assert_exact_schema!(type_id, expected_keys, required_matrix_states = nil)
  schema = R.fetch(type_id)
  raise "#{type_id} reusable key matrix drift" unless schema.fetch("keys") == expected_keys
  return if required_matrix_states.nil?

  matrix = schema.fetch("state_matrix_exact")
  raise "#{type_id} reusable state matrix drift" unless required_matrix_states.all? { |state| matrix.key?(state) }
end

# These are the exact reusable matrices consumed by the R00 builders and
# replay.  The audit executes before any R00 source fixture is materialized so
# a schema change cannot be absorbed as a new conformance baseline.
v12_cp_assert_exact_schema!("DirectoryOperationV12", %w[
  ordinal_uint label parent_label leaf state_enum attempted_bool
  last_completed_step_enum created_side_effect_bool_or_null
  native_result_int_or_null held_vnode_or_null named_vnode_or_null
  named_join_bool_or_null parent_fsync_bool_or_null
  parent_fullsync_bool_or_null error
], %w[NOT_ENTERED CREATED_JOINED OPEN_FAILED SYNC_FAILED])
v12_cp_assert_exact_schema!("NamedJoinV12", %w[
  path state_enum held_before_or_null held_after_or_null named_after_or_null
  held_stable_bool_or_null named_join_bool_or_null error
], %w[ABSENT JOINED])
v12_cp_assert_exact_schema!("InventoryV12", %w[
  state_enum cap_entries_uint observed_names observed_count_uint
  total_count_uint_or_null overflow_witness_bool_or_null error
], %w[NOT_REQUESTED COMPLETE])
v12_cp_assert_exact_schema!("NamespaceAssessmentV12", %w[
  role_enum required_names allowed_names observed_names missing_required_names
  unexpected_names retained_residual_names nonconforming_names
  classification_complete_bool integrity_bool error
])
v12_cp_assert_exact_schema!("DirectorySnapshotV12", %w[
  path join inventory namespace_assessment
])
v12_cp_assert_exact_schema!("FirstUnenteredV12", %w[
  present_bool operation_label_or_null reason_predicate_id_or_null
])

def v12_cp_fixture_row(fixture_id, type_id, value)
  bytes = canon(value)
  {
    "fixture_id" => fixture_id,
    "type_id" => type_id,
    "canonical_json_base64" => Base64.strict_encode64(bytes),
    "bytes_uint" => bytes.bytesize,
    "sha256" => sha(bytes)
  }
end

def v12_cp_source_binding(fixture_id)
  {
    "binding_id" => "SOURCE_INSTANCE",
    "state_enum" => "VALUE",
    "fixture_id_or_null" => fixture_id,
    "error" => error_none
  }
end

def v12_cp_unavailable_binding(binding_id)
  {
    "binding_id" => binding_id,
    "state_enum" => "UNAVAILABLE",
    "fixture_id_or_null" => nil,
    "error" => error_pred("INPUT_UNAVAILABLE")
  }
end

def v12_cp_eval_unavailable
  {
    "state_enum" => "UNAVAILABLE",
    "type_id" => "B",
    "value_or_null" => nil,
    "error" => error_pred("INPUT_UNAVAILABLE")
  }
end

def v12_cp_restore_install_root!(snapshot)
  restored_root = clone(snapshot)
  restored_schema = restored_root.fetch("exact_record_schema_v12")
  restored_reusable = restored_schema.fetch("reusable_objects")
  restored_constraints = restored_schema.fetch("state_constraint_registry_v12")
  restored_decision = restored_schema.fetch("decision_kernel_v12")

  R.replace(restored_reusable)
  S.replace(restored_constraints)
  D.replace(restored_decision)
  if defined?(CAT) && D.key?("custom_operator_conformance_catalog_v12")
    CAT.replace(D.fetch("custom_operator_conformance_catalog_v12"))
    D["custom_operator_conformance_catalog_v12"] = CAT
  end
  restored_schema["reusable_objects"] = R
  restored_schema["state_constraint_registry_v12"] = S
  restored_schema["decision_kernel_v12"] = D
  X.replace(restored_schema)
  restored_root["exact_record_schema_v12"] = X
  J.replace(restored_root)
end

v12_cp_main_new_schema_ids = %w[
  R00ProjectionBodyRootV12 CounterProjectionSourceV12
]
v12_cp_main_schema_collisions = v12_cp_main_new_schema_ids & R.keys
raise "custom projection carrier schema collision #{v12_cp_main_schema_collisions.inspect}" unless
  v12_cp_main_schema_collisions.empty?
raise "custom projection carrier missing replaced R00 schema" unless
  R.key?("R00ProjectionBindingConformanceRowV12") &&
  R.key?("R00ProjectionConformanceSourceV12")
v12_cp_obsolete_selector_type_id =
  "LegacyCustomProjection" + "ConformanceSourceV12"
raise "custom projection carrier missing selector schema" unless
  R.key?(v12_cp_obsolete_selector_type_id)

v12_cp_install_snapshot = clone(J)
begin

# Exact reusable source schemas.  R00 uses the real production field types and
# fixed body pointers.  ROOT_CONTROL is deliberately absent from the fixture:
# the materializer resolves it from the same held control at /roots.
R.delete("R00ProjectionBindingConformanceRowV12")
R.delete("R00ProjectionConformanceSourceV12")
R["R00ProjectionBodyRootV12"] = {
  "keys" => [
    "directory_operations", "root_absence_checks", "root_snapshots",
    "journal_snapshot_before_r00_publication", "first_unentered"
  ],
  "field_types_exact" => {
    "directory_operations" => "ARRAY(DirectoryOperationV12,31,31,DirectoryOperationOrderV12)",
    "root_absence_checks" => "REF(NamedJoinSetV12)",
    "root_snapshots" => "ARRAY(DirectorySnapshotV12,3,3,RootOrderV12)",
    "journal_snapshot_before_r00_publication" => "REF(DirectorySnapshotV12)",
    "first_unentered" => "REF(FirstUnenteredV12)"
  },
  "rule" => "ONE_IMMUTABLE_PRODUCTION_SHAPED_R00_BODY_BINDING_ROOT;THE_FIVE_MEMBERS_ARE_THE_EXACT_SELF_POINTER_TARGETS_OF_R00_TOPOLOGY_BINDINGS;NO_DERIVED_STATE_ARRAY_BOOLEAN_MATCH_FLAG_OR_EXPECTED_OPERATOR_INPUT"
}
R["R00ProjectionConformanceSourceV12"] = {
  "keys" => ["state_enum", "current_r00_body_or_null", "error"],
  "states_exact" => ["AVAILABLE", "UNAVAILABLE"],
  "field_types_exact" => {
    "state_enum" => "LOCAL_ENUM(states_exact)",
    "current_r00_body_or_null" => "REF_OR_NULL(R00ProjectionBodyRootV12)",
    "error" => "REF(ErrorV12)"
  },
  "state_matrix_exact" => {
    "AVAILABLE" => {"current_r00_body_or_null_nonnull" => true, "error_state" => "NONE"},
    "UNAVAILABLE" => {"current_r00_body_or_null" => nil, "error_state_not" => "NONE"}
  },
  "rule" => "SOURCE_TYPE_SELECTS_PROJECT_R00_INPUT;AVAILABLE_CARRIES_ONE_ACTUAL_TYPED_BODY_ROOT_AND_RESOLVES_ROOT_CONTROL_ONLY_FROM_THE_HELD_CONTROL_/roots;UNAVAILABLE_CARRIES_NO_PARTIAL_BODY;NO_PROGRAM_CASE_AVAILABILITY_SELECTOR_MATCH_ROWS_OR_EXPECTED_OUTPUT"
}

# The journal-envelope, journal-chain, and outer-chain routes are installed
# later from the shared quarantined StaticModelLegacyRouteSourceV12.  No
# operational record, vnode, observation, or frame-reference carrier is
# defined by this overlay.
R["CounterProjectionSourceV12"] = {
  "keys" => [
    "state_enum", "record_kind_enum_or_null", "transition_receipts_or_null",
    "counter_snapshots_or_null", "transition_source_instances_or_null",
    "counter_seed_rows_or_null", "error"
  ],
  "states_exact" => ["AVAILABLE", "UNAVAILABLE"],
  "field_types_exact" => {
    "state_enum" => "LOCAL_ENUM(states_exact)",
    "record_kind_enum_or_null" => "ENUM_OR_NULL(RecordKindV12)",
    "transition_receipts_or_null" => "ARRAY_OR_NULL(TransitionReceiptV12,0,66,TransitionSequenceOrderV12)",
    "counter_snapshots_or_null" => "ARRAY_OR_NULL(CounterSnapshotV12,4,4,CounterScopeOrderV12)",
    "transition_source_instances_or_null" => "ARRAY_OR_NULL(TransitionSourceInstanceConformanceRowV12,0,66,JsonPointerOrderV12)",
    "counter_seed_rows_or_null" => "ARRAY_OR_NULL(CounterSeedConformanceRowV12,23,23,CounterCatalogOrderV12)",
    "error" => "REF(ErrorV12)"
  },
  "state_matrix_exact" => {
    "AVAILABLE" => {
      "all_or_null_fields_nonnull" => true,
      "error_state" => "NONE"
    },
    "UNAVAILABLE" => {
      "all_or_null_fields_null" => true,
      "error_state_not" => "NONE"
    }
  },
  "rule" => "RECEIPTS_SNAPSHOTS_SOURCE_INSTANCE_CANONICAL_BYTES_AND_SEEDS_SHARE_ONE_CURRENT_TYPED_SOURCE_ROOT;DEFINITIONS_COUNTER_CATALOG_TRANSITION_CATALOG_SOURCE_POINTER_TABLE_AND_SEED_SOURCE_TABLE_RESOLVE_ONLY_FROM_HELD_CONTROL;NO_NORMALIZED_COUNTER_ROW_IS_A_SOURCE"
}
catalog = D.fetch("custom_operator_conformance_catalog_v12")
fixtures_by_id = catalog.fetch("fixtures").to_h { |row| [row.fetch("fixture_id"), row] }
vectors_by_id = catalog.fetch("vectors").to_h { |row| [row.fetch("vector_id"), row] }

available_source = lambda do |body|
  {"state_enum" => "AVAILABLE", "current_r00_body_or_null" => body, "error" => error_none}
end
unavailable_source = {
  "state_enum" => "UNAVAILABLE", "current_r00_body_or_null" => nil,
  "error" => error_pred("R00_CURRENT_BODY_BINDING_UNAVAILABLE")
}

r00_states_first = ["OPEN_FAILED"] + Array.new(30, "NOT_ENTERED")
r00_states_middle = Array.new(15, "CREATED_JOINED") + ["SYNC_FAILED"] + Array.new(15, "NOT_ENTERED")
r00_states_final = Array.new(30, "CREATED_JOINED") + ["SYNC_FAILED"]
r00_states_success = Array.new(31, "CREATED_JOINED")
r00_sources = {
  "R00_SOURCE_FAILURE_TRUE_SOURCE" => available_source.call(v12_cp_build_r00_body(r00_states_first, 1)),
  "R00_SOURCE_MIDDLE_FAILURE_TRUE_SOURCE" => available_source.call(v12_cp_build_r00_body(r00_states_middle, 16)),
  "R00_SOURCE_FINAL_FAILURE_TRUE_SOURCE" => available_source.call(v12_cp_build_r00_body(r00_states_final, nil)),
  "R00_SOURCE_REQUIRED_BINDING_UNAVAILABLE_SOURCE" => unavailable_source,
  "R00_SOURCE_WRONG_FIRST_UNENTERED_FALSE_SOURCE" => available_source.call(v12_cp_build_r00_body(r00_states_first, 2)),
  "R00_TOPO_TRUE_SUCCESS_SOURCE_V12" => available_source.call(v12_cp_build_r00_body(r00_states_success, nil)),
  "R00_TOPO_FALSE_IDENTITY_SOURCE_V12" => available_source.call(v12_cp_build_r00_body(r00_states_success, nil, identity_mismatch: true))
}
r00_sources.each do |fixture_id, source|
  fixtures_by_id[fixture_id] = v12_cp_fixture_row(fixture_id, "R00ProjectionConformanceSourceV12", source)
end

r00_vector_source_ids = {
  "R00_SOURCE_FAILURE_TRUE" => "R00_SOURCE_FAILURE_TRUE_SOURCE",
  "R00_SOURCE_MIDDLE_FAILURE_TRUE" => "R00_SOURCE_MIDDLE_FAILURE_TRUE_SOURCE",
  "R00_SOURCE_FINAL_FAILURE_TRUE" => "R00_SOURCE_FINAL_FAILURE_TRUE_SOURCE",
  "R00_SOURCE_REQUIRED_BINDING_UNAVAILABLE" => "R00_SOURCE_REQUIRED_BINDING_UNAVAILABLE_SOURCE",
  "R00_SOURCE_WRONG_FIRST_UNENTERED_FALSE" => "R00_SOURCE_WRONG_FIRST_UNENTERED_FALSE_SOURCE",
  "R00_TOPO_TRUE_SUCCESS" => "R00_TOPO_TRUE_SUCCESS_SOURCE_V12",
  "R00_TOPO_FALSE_FLAG" => "R00_TOPO_FALSE_IDENTITY_SOURCE_V12"
}
r00_vector_source_ids.each do |vector_id, fixture_id|
  vector = vectors_by_id.fetch(vector_id)
  vector.fetch("bindings").reject! { |binding_row| binding_row.fetch("binding_id") == "SOURCE_INSTANCE" }
  vector.fetch("bindings") << v12_cp_source_binding(fixture_id)
end

# Source construction is complete before any normalized fixture is decoded.
# These comparisons are conformance assertions, never source constructors.
r00_vector_source_ids.each do |vector_id, source_fixture_id|
  vector = vectors_by_id.fetch(vector_id)
  normalized_binding = vector.fetch("bindings").find { |row| row.fetch("binding_id") == "NORMALIZED_INPUT" }
  source_value = v12_cp_decode_custom_fixture(fixtures_by_id.fetch(source_fixture_id))
  projected = v12_cp_project_r00(source_value)
  if normalized_binding.fetch("state_enum") == "UNAVAILABLE"
    raise "R00 unavailable source materialized #{vector_id}" unless projected.nil?
  else
    expected = v12_cp_decode_custom_fixture(fixtures_by_id.fetch(normalized_binding.fetch("fixture_id_or_null")))
    raise "R00 independent normalized mismatch #{vector_id}" unless projected == expected
  end
end

catalog["fixtures"] = fixtures_by_id.values.sort_by { |row| row.fetch("fixture_id") }
catalog["vectors"] = vectors_by_id.values.sort_by { |row| row.fetch("vector_id") }
catalog["expected_result_rows"] = catalog.fetch("vectors").map do |row|
  [row.fetch("vector_id"), clone(row.fetch("expected_result"))]
end
catalog["fixture_count_uint"] = catalog.fetch("fixtures").length
catalog["vector_count_uint"] = catalog.fetch("vectors").length
raise "R00 carrier changed custom vector count" unless catalog.fetch("vector_count_uint") == 259

projection_registry = D.fetch("custom_operator_input_projection_registry_v12")
projection_registry.fetch("projection_source_classes_exact").reject! do |row|
  row.fetch(0) == "CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL"
end
projection_registry.fetch("projection_source_classes_exact") << [
  "CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL",
  "ONE_ACTUAL_TYPED_R00_BODY_BINDING_ROOT_PLUS_THE_SAME_HELD_CONTROL_/roots;NO_SELECTOR_FLAGS_EXPECTED_ROWS_OR_STRING_INSTANCE_IDS"
]
projection_registry.fetch("projection_source_materializer_programs_v12")["CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL"] = {
  "source_class_enum" => "CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL",
  "source_type_id" => "R00ProjectionConformanceSourceV12",
  "output_type_id" => "R00OperatorInputV12",
  "binding_ids_exact_order" => %w[ROWS ROOT_ABSENCE ROOT_SNAPSHOTS JOURNAL_SNAPSHOT FIRST_UNENTERED ROOT_CONTROL],
  "binding_source_rows_exact" => [
    ["ROWS", "SOURCE_INSTANCE", "/current_r00_body_or_null/directory_operations", "ARRAY(DirectoryOperationV12,31,31,DirectoryOperationOrderV12)"],
    ["ROOT_ABSENCE", "SOURCE_INSTANCE", "/current_r00_body_or_null/root_absence_checks", "REF(NamedJoinSetV12)"],
    ["ROOT_SNAPSHOTS", "SOURCE_INSTANCE", "/current_r00_body_or_null/root_snapshots", "ARRAY(DirectorySnapshotV12,3,3,RootOrderV12)"],
    ["JOURNAL_SNAPSHOT", "SOURCE_INSTANCE", "/current_r00_body_or_null/journal_snapshot_before_r00_publication", "REF(DirectorySnapshotV12)"],
    ["FIRST_UNENTERED", "SOURCE_INSTANCE", "/current_r00_body_or_null/first_unentered", "REF(FirstUnenteredV12)"],
    ["ROOT_CONTROL", "HELD_CONTROL", "/roots", "CONTROL_OBJECT"]
  ],
  "production_projection_program_id" => "PROJECT_R00_INPUT",
  "materialization_rule" => "STRICTLY_TYPECHECK_ONE_ACTUAL_R00_BODY_ROOT;RESOLVE_ROOT_CONTROL_FROM_THE_SAME_RAW_HELD_CONTROL_ONLY;EXECUTE_THE_SIX_EXACT_BINDINGS_AND_UNCHANGED_PROJECT_R00_INPUT;DERIVE_STATES_SIDE_EFFECTS_TOPOLOGY_AND_FIRST_UNENTERED;ONLY_THEN_COMPARE_THE_SEPARATE_NORMALIZED_INPUT;MISSING_REQUIRED_BODY_RETURNS_UNAVAILABLE"
}

replay = D.fetch("custom_operator_conformance_projection_replay_v12")
source_rows = replay.fetch("source_rows_exact")
source_rows.reject! do |row|
  %w[R00_TOPOLOGY_CLASSIFIABLE R00_FAILURE_CHAIN_VALID].include?(row.fetch(0))
end
failure_index = source_rows.index { |row| row.fetch(0) == "JOURNAL_ENVELOPE_CHAIN_VALID" } || source_rows.length
r00_replay_rows = [
  ["R00_TOPOLOGY_CLASSIFIABLE", "R00ProjectionConformanceSourceV12", "CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL", "PROJECT_R00_INPUT"],
  ["R00_FAILURE_CHAIN_VALID", "R00ProjectionConformanceSourceV12", "CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL", "PROJECT_R00_INPUT"]
]
source_rows.insert(failure_index, *r00_replay_rows)
replay["rule"] = replay.fetch("rule").sub(
  "EVERY_NEW_VALUE_VECTOR_CARRIES_ONE_SOURCE_INSTANCE_AND_ONE_NORMALIZED_INPUT",
  "EVERY_SOURCE_REPLAY_VALUE_VECTOR_CARRIES_ONE_ACTUAL_TYPED_SOURCE_INSTANCE_AND_ONE_SEPARATE_NORMALIZED_INPUT;BOTH_R00_OPERATORS_EXECUTE_PROJECT_R00_INPUT_FROM_THE_SAME_SOURCE_TYPE"
)

def v12_cp_typed_value_bytes(row)
  raw = Base64.strict_decode64(row.fetch("canonical_json_base64"))
  raise "typed source byte count" unless raw.bytesize == row.fetch("bytes_uint")
  raise "typed source digest" unless sha(raw) == row.fetch("sha256")
  parsed = JSON.parse(raw)
  raise "typed source is not canonical" unless canon(parsed) == raw
  raw
end

def v12_cp_counter_source_pointer_valid?(source, receipt, definition)
  pointer_rows = D.dig(
    "transition_receipt_semantics_v12",
    "source_instance_binding_by_transition_exact"
  )
  expected_pointer = pointer_rows.to_h.fetch(definition.fetch("transition_id"))
  actual_pointer = receipt.fetch("source_instance_json_pointer_or_null")
  actual_digest = receipt.fetch("source_instance_complete_json_sha256_or_null")
  return actual_pointer.nil? && actual_digest.nil? if expected_pointer.nil?
  return false unless actual_pointer == expected_pointer

  source_row = source.fetch("transition_source_instances_or_null").find do |row|
    row.fetch("json_pointer") == actual_pointer
  end
  return false unless source_row
  raw = v12_cp_typed_value_bytes(source_row.fetch("value"))
  actual_digest == sha(raw)
rescue KeyError, TypeError, ArgumentError, JSON::ParserError
  false
end

def v12_cp_counter_definition_valid?(source, receipt, definition, sequence)
  return false unless receipt.fetch("sequence_uint") == sequence
  return false unless receipt.fetch("transition_id") == definition.fetch("transition_id")
  return false unless receipt.fetch("from_state_enum") == definition.fetch("from_state_enum")
  entered = receipt.fetch("state_enum") == "ENTERED"
  expected_to = entered ? definition.fetch("to_state_enum") : nil
  expected_deltas = entered ? definition.fetch("counter_deltas") : []
  return false unless receipt.fetch("to_state_enum_or_null") == expected_to
  return false unless receipt.fetch("counter_deltas_applied") == expected_deltas
  return false unless receipt.dig("trigger_evaluation", "predicate_id") == definition.fetch("trigger_predicate_id")
  return false unless receipt.dig("trigger_evaluation", "state_enum") == (entered ? "TRUE" : "FALSE")
  return false unless receipt.fetch("guard_evaluations").map { |row| row.fetch("predicate_id") } ==
    definition.fetch("guard_conditions_all").map { |row| row.fetch("predicate_id") }
  return false unless receipt.dig("error", "state_enum") == "NONE"
  v12_cp_counter_source_pointer_valid?(source, receipt, definition)
rescue KeyError, TypeError
  false
end

def v12_cp_project_counter_source(source)
  return nil if source.fetch("state_enum") == "UNAVAILABLE"
  raise "counter source state" unless source.fetch("state_enum") == "AVAILABLE"
  raise "counter source error" unless source.dig("error", "state_enum") == "NONE"

  kind = source.fetch("record_kind_enum_or_null")
  receipts = source.fetch("transition_receipts_or_null")
  snapshots = source.fetch("counter_snapshots_or_null")
  seed_rows = source.fetch("counter_seed_rows_or_null")
  raise "counter source missing available members" unless kind && receipts && snapshots && seed_rows

  catalog = D.fetch("transition_record_catalogs_v12").find do |row|
    row.fetch("record_kind_enum") == kind
  end
  raise "counter transition catalog unavailable #{kind}" unless catalog
  sequence = catalog.fetch("sequence_exact")
  raise "counter conformance requires a fixed sequence" unless sequence.all? { |row| row.length == 2 }
  expected_transition_ids = sequence.map(&:first)
  raise "counter receipt count" unless receipts.length == expected_transition_ids.length
  raise "counter receipt order" unless receipts.map { |row| row.fetch("transition_id") } == expected_transition_ids

  definitions = D.fetch("transition_definitions_v12").to_h do |row|
    [row.fetch("transition_id"), row]
  end
  definition_rows = receipts.map { |receipt| definitions.fetch(receipt.fetch("transition_id")) }
  definitions_valid = receipts.each_with_index.all? do |receipt, index|
    v12_cp_counter_definition_valid?(source, receipt, definition_rows.fetch(index), index)
  end

  scope_order = D.fetch("counter_catalog").keys
  raise "counter snapshot scope order" unless snapshots.map { |row| row.fetch("subject_scope_id") } == scope_order
  raise "counter snapshot through count" unless snapshots.all? do |row|
    row.fetch("through_transition_count_uint") == receipts.length
  end

  frozen_seed_rows = D.dig("counter_fold_v12", "counter_seed_source_table_v12").select do |row|
    row.fetch(0) == kind
  end
  raise "counter seed scope table" unless frozen_seed_rows.map { |row| row.fetch(1) } == scope_order
  expected_seed_order = scope_order.flat_map do |scope|
    D.dig("counter_catalog", scope).map { |counter_id| [scope, counter_id] }
  end
  raise "counter seed row order" unless seed_rows.map do |row|
    [row.fetch("subject_scope_id"), row.fetch("counter_id")]
  end == expected_seed_order

  seed_by_pair = seed_rows.to_h do |row|
    [[row.fetch("subject_scope_id"), row.fetch("counter_id")], row]
  end
  snapshot_by_scope = snapshots.to_h { |row| [row.fetch("subject_scope_id"), row] }
  rows = expected_seed_order.map do |scope, counter_id|
    seed = seed_by_pair.fetch([scope, counter_id])
    seed_control = frozen_seed_rows.find { |row| row.fetch(1) == scope }
    raise "counter seed policy drift #{scope}/#{counter_id}" unless seed.fetch("policy_enum") == seed_control.fetch(2)
    expected_seed = seed.fetch("policy_enum") == "EXACT_SELF" && seed_control.fetch(3) == "GENESIS_ZERO" ? 0 : nil
    raise "counter seed value drift #{scope}/#{counter_id}" unless seed.fetch("seed_uint_or_null") == expected_seed
    raise "counter START seed unexpectedly references a frame" unless seed.fetch("source_frame_or_null").nil?

    snapshot = snapshot_by_scope.fetch(scope)
    entry = snapshot.fetch("entries_exact_catalog_order").find do |row|
      row.fetch("counter_id") == counter_id
    end
    raise "counter snapshot entry missing #{scope}/#{counter_id}" unless entry
    observed = entry.fetch("value_uint_or_null")
    policy = seed.fetch("policy_enum")
    {
      "counter_id" => counter_id,
      "policy_enum" => policy,
      "seed_uint_or_null" => seed.fetch("seed_uint_or_null"),
      "delta_values" => definition_rows.map do |definition|
        delta = definition.fetch("counter_deltas").find do |row|
          row.fetch("subject_scope_id") == scope && row.fetch("counter_id") == counter_id
        end
        delta ? delta.fetch("delta_uint") : 0
      end,
      "entered_mask" => receipts.map { |receipt| receipt.fetch("state_enum") == "ENTERED" },
      "observed_uint_or_null" => observed,
      "through_transition_count_uint" => receipts.length,
      "definitions_valid_bool" => definitions_valid,
      "import_available_bool" => %w[EXACT_SELF EXACT_IMPORTED LOWER_BOUND_IMPORTED].include?(policy)
    }
  end
  {"rows" => rows, "complete_bool" => true}
rescue KeyError, TypeError
  raise "counter source projection malformed"
end

def v12_cp_counter_source_from_rtc(rtc)
  raise "RTC counter carrier not available" unless rtc.fetch("projection_availability_enum") == "AVAILABLE"
  {
    "state_enum" => "AVAILABLE",
    "record_kind_enum_or_null" => rtc.fetch("record_kind_enum"),
    "transition_receipts_or_null" => clone(rtc.fetch("transition_receipts")),
    "counter_snapshots_or_null" => clone(rtc.fetch("counter_snapshots")),
    "transition_source_instances_or_null" => clone(rtc.fetch("transition_source_instances")),
    "counter_seed_rows_or_null" => clone(rtc.fetch("counter_seed_rows")),
    "error" => error_none
  }
end

def v12_cp_replace_fixture!(fixtures_by_id, fixture_id, type_id, value)
  fixtures_by_id[fixture_id] = v12_cp_fixture_row(fixture_id, type_id, value)
end

# Counter construction reads the independently generated RTC typed source and
# no normalized input.  Only after projection is complete is the independently
# generated RTC normalized input decoded and compared.
rtc_start_vector = vectors_by_id.fetch("RTC_PUBLICATION_TRUE_START_START")
rtc_start_source_binding = rtc_start_vector.fetch("bindings").find do |row|
  row.fetch("binding_id") == "SOURCE_INSTANCE"
end
raise "RTC START source binding" unless rtc_start_source_binding
rtc_start_source = v12_cp_decode_custom_fixture(
  fixtures_by_id.fetch(rtc_start_source_binding.fetch("fixture_id_or_null"))
)
counter_source = v12_cp_counter_source_from_rtc(rtc_start_source)
counter_projection = v12_cp_project_counter_source(counter_source)

rtc_start_input_binding = rtc_start_vector.fetch("bindings").find do |row|
  row.fetch("binding_id") == "NORMALIZED_INPUT"
end
raise "RTC START normalized binding" unless rtc_start_input_binding
rtc_start_input = v12_cp_decode_custom_fixture(
  fixtures_by_id.fetch(rtc_start_input_binding.fetch("fixture_id_or_null"))
)
raise "independent RTC/counter replay mismatch" unless counter_projection.fetch("rows") == rtc_start_input.fetch("counter_fold_rows")

counter_positive_source_id = "SOURCE_PROJECTION_PROJECT_COUNTER_INPUT_SET_TRUE_SOURCE"
counter_positive_input_id = "SOURCE_PROJECTION_PROJECT_COUNTER_INPUT_SET_TRUE_INPUT"
v12_cp_replace_fixture!(fixtures_by_id, counter_positive_source_id, "CounterProjectionSourceV12", counter_source)
v12_cp_replace_fixture!(fixtures_by_id, counter_positive_input_id, "CounterFoldInputSetV12", counter_projection)

counter_unavailable_source = {
  "state_enum" => "UNAVAILABLE",
  "record_kind_enum_or_null" => nil,
  "transition_receipts_or_null" => nil,
  "counter_snapshots_or_null" => nil,
  "transition_source_instances_or_null" => nil,
  "counter_seed_rows_or_null" => nil,
  "error" => error_pred("COUNTER_REQUIRED_TYPED_SOURCE_UNAVAILABLE")
}
v12_cp_replace_fixture!(
  fixtures_by_id,
  "SOURCE_PROJECTION_PROJECT_COUNTER_INPUT_SET_UNAVAILABLE_SOURCE",
  "CounterProjectionSourceV12",
  counter_unavailable_source
)
raise "counter unavailable source materialized" unless v12_cp_project_counter_source(counter_unavailable_source).nil?

# A negative source vector mutates an actual typed receipt fact before
# projection. AVAILABLE remains available; the definition disagreement is a
# value-false row axis, not an unavailable shortcut.
counter_definition_source = clone(counter_source)
counter_definition_source.fetch("transition_receipts_or_null").first["from_state_enum"] = "AVAILABLE"
counter_definition_projection = v12_cp_project_counter_source(counter_definition_source)
raise "counter definition mutation retained true" if counter_definition_projection.fetch("rows").all? do |row|
  row.fetch("definitions_valid_bool")
end
counter_definition_source_id = "COUNTER_FALSE_DEFINITIONS_TYPED_SOURCE_V12"
v12_cp_replace_fixture!(fixtures_by_id, counter_definition_source_id, "CounterProjectionSourceV12", counter_definition_source)
v12_cp_replace_fixture!(fixtures_by_id, "COUNTER_DEFINITIONS_FALSE", "CounterFoldInputSetV12", counter_definition_projection)
counter_definition_vector = vectors_by_id.fetch("COUNTER_FALSE_DEFINITIONS")
counter_definition_vector.fetch("bindings").reject! { |row| row.fetch("binding_id") == "SOURCE_INSTANCE" }
counter_definition_vector.fetch("bindings") << v12_cp_source_binding(counter_definition_source_id)

counter_projection_vector = vectors_by_id.fetch("SOURCE_PROJECTION_PROJECT_COUNTER_INPUT_SET_TRUE")
counter_projection_vector.fetch("bindings").find do |row|
  row.fetch("binding_id") == "SOURCE_INSTANCE"
end["fixture_id_or_null"] = counter_positive_source_id

legacy_materializer = projection_registry.fetch("projection_source_materializer_programs_v12").fetch(
  "CONFORMANCE_LEGACY_CUSTOM_SOURCE"
)
legacy_materializer.delete("source_type_id")
legacy_materializer["source_type_by_program_exact"] = {
  "PROJECT_JOURNAL_ENVELOPE_INPUT" => "StaticModelLegacyRouteSourceV12",
  "PROJECT_COUNTER_INPUT_SET" => "CounterProjectionSourceV12",
  "PROJECT_JOURNAL_CHAIN_INPUT" => "StaticModelLegacyRouteSourceV12",
  "PROJECT_OUTER_CHAIN_INPUT" => "StaticModelLegacyRouteSourceV12"
}
legacy_materializer["materialization_rule"] = "SELECT_THE_EXACT_SOURCE_TYPE_BY_PROGRAM;PROJECT_COUNTER_INPUT_SET_REPLAYS_TYPED_OPERATIONAL_RECEIPTS_SNAPSHOTS_SOURCE_BYTES_AND_HELD_CONTROL;THE_THREE_JOURNAL_DEPENDENT_PROGRAMS_REPLAY_ONLY_QUARANTINED_STATIC_MODEL_EXACT_ENVELOPE_PAYLOAD_PREDECESSOR_AND_MERKLE_ALGEBRA_THEN_RETURN_ABSTAIN_MISSING_REQUIRED_START_WITH_NO_NORMALIZED_PRODUCTION_INPUT;EXPECTED_ROWS_AND_VECTOR_IDS_ARE_NEVER_SOURCE_INPUTS"

source_rows_exact = replay.fetch("source_rows_exact")
counter_replay_index = source_rows_exact.index do |row|
  row.fetch(0) == "COUNTER_FOLD_VALID"
end
raise "counter replay row missing" unless counter_replay_index
source_rows_exact[counter_replay_index] = [
  "COUNTER_FOLD_VALID", "CounterProjectionSourceV12",
  "CONFORMANCE_LEGACY_CUSTOM_SOURCE", "PROJECT_COUNTER_INPUT_SET"
]

catalog["fixtures"] = fixtures_by_id.values.sort_by { |row| row.fetch("fixture_id") }
catalog["vectors"] = vectors_by_id.values.sort_by { |row| row.fetch("vector_id") }
catalog["expected_result_rows"] = catalog.fetch("vectors").map do |row|
  [row.fetch("vector_id"), clone(row.fetch("expected_result"))]
end
catalog["fixture_count_uint"] = catalog.fetch("fixtures").length
catalog["vector_count_uint"] = catalog.fetch("vectors").length
raise "counter carrier changed custom vector count" unless catalog.fetch("vector_count_uint") == 259

rescue StandardError
  v12_cp_restore_install_root!(v12_cp_install_snapshot)
  raise
end

static_route_overlay_path = File.expand_path(
  "custom-projection-static-routes.rb", __dir__
)
eval(
  File.binread(static_route_overlay_path), binding,
  static_route_overlay_path
)
