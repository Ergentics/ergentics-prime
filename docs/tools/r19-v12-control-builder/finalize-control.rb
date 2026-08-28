#!/usr/bin/ruby
# frozen_string_literal: true

require "json"
require "digest"
require "base64"

abort("usage: #{$PROGRAM_NAME} CONTROL.json") unless ARGV.length == 1
PATHNAME = ARGV.fetch(0)
J = JSON.parse(File.binread(PATHNAME))
X = J.fetch("exact_record_schema_v12")
R = X.fetch("reusable_objects")
S = X.fetch("state_constraint_registry_v12")
D = X.fetch("decision_kernel_v12")

def clone(value)
  Marshal.load(Marshal.dump(value))
end

def canon(value)
  JSON.generate(value)
end

def sha(value)
  Digest::SHA256.hexdigest(value.is_a?(String) ? value.b : canon(value))
end

def json_sha(value)
  Digest::SHA256.hexdigest(JSON.generate(value).b)
end

def ordered_object(source, keys)
  keys.each_with_object({}) { |key, output| output[key] = source.fetch(key) }
end

def resolve_pointer(root, pointer)
  raise "not absolute RFC6901: #{pointer}" unless pointer.start_with?("/")
  pointer.split("/", -1).drop(1).reduce(root) do |value, token|
    key = token.gsub("~1", "/").gsub("~0", "~")
    value.is_a?(Array) ? value.fetch(Integer(key, 10)) : value.fetch(key)
  end
end

def error_none
  {
    "state_enum" => "NONE", "code_string_or_null" => nil,
    "errno_int_or_null" => nil, "exception_class_string_or_null" => nil,
    "message_base64_or_null" => nil, "message_bytes_uint_or_null" => nil,
    "message_sha256_or_null" => nil
  }
end

def error_pred(code)
  value = error_none
  value["state_enum"] = "PREDICATE_FALSE"
  value["code_string_or_null"] = code
  value
end

def error_unknown(predicate_id)
  error_pred("PREDICATE_STATE_UNKNOWN:#{predicate_id}")
end

def failure_absent
  {
    "present_bool" => false, "phase_enum_or_null" => nil,
    "operation_label_or_null" => nil, "predicate_id_or_null" => nil,
    "classification_enum_or_null" => nil, "error" => error_none
  }
end

def failure_present(phase, operation_label, predicate_id, state, contradiction: false)
  classification = if contradiction
    "CONTRADICTION"
  elsif state == "UNKNOWN"
    "PREDICATE_UNKNOWN"
  else
    "PREDICATE_FALSE"
  end
  error = if contradiction
    error_pred("STATUS_CONTRADICTION:#{predicate_id}")
  elsif state == "UNKNOWN"
    error_unknown(predicate_id)
  else
    error_none
  end
  {
    "present_bool" => true, "phase_enum_or_null" => phase,
    "operation_label_or_null" => operation_label,
    "predicate_id_or_null" => predicate_id,
    "classification_enum_or_null" => classification, "error" => error
  }
end

# Admission failures preserve the earliest identity and the divergent witness.
# The former blanket-equality prose made HELD_DRIFT and NAMED_MISMATCH
# impossible to represent.  These matrices are the executable state partition.
named_join_schema = R.fetch("NamedJoinV12")
named_join_schema.fetch("state_matrix_exact").fetch("HELD_DRIFT").merge!(
  "held_before_after_vnode_not_equal" => true,
  "named_after_or_null" => nil,
  "held_stable_bool_or_null" => false,
  "named_join_bool_or_null" => nil
)
named_join_schema.fetch("state_matrix_exact").fetch("NAMED_MISMATCH").merge!(
  "held_before_after_vnode_equal" => true,
  "held_before_named_after_vnode_not_equal" => true,
  "held_stable_bool_or_null" => true,
  "named_join_bool_or_null" => false
)
named_join_schema["rule"] = "THE_STATE_MATRIX_AND_named_join_axis_integrity_FORM_ONE_TOTAL_FIRST_AXIS_CLASSIFICATION;JOINED_REQUIRES_ALL_THREE_VNODES_EQUAL;HELD_DRIFT_REQUIRES_held_before_NOT_EQUAL_held_after_AND_FORBIDS_A_NAMED_AFTER_WITNESS;NAMED_MISMATCH_REQUIRES_held_before_EQUAL_held_after_AND_named_after_NOT_EQUAL_THE_HELD_VNODE;VNODE_OR_BOOLEAN_FIELDS_FROM_A_LATER_UNREACHED_CUT_ARE_FORBIDDEN"

content_schema = R.fetch("ContentAdmissionV12")
content_schema.fetch("state_matrix_exact").fetch("join_HELD_DRIFT").merge!(
  "pre_post_vnode_not_equal" => true,
  "named_vnode_or_null" => nil,
  "named_join_bool_or_null" => nil,
  "error_state_not" => "NONE"
)
content_schema.fetch("state_matrix_exact").fetch("join_NAMED_MISMATCH").merge!(
  "pre_post_vnode_equal" => true,
  "pre_named_vnode_not_equal" => true,
  "held_stable_bool_or_null" => true,
  "named_join_bool_or_null" => false,
  "error_state_not" => "NONE"
)
content_schema["rule"] = "PRE_FSTAT_REWIND_READ_CAP_PLUS_ONE_COMPLETE_IFF_EOF_AT_OR_BELOW_CAP_OVERFLOW_RETAINS_BOUNDED_SAMPLE_ONLY_POST_FSTAT_AND_NAMED_JOIN_WHEN_POSSIBLE_ZERO_BYTE_COMPLETE_HAS_EMPTY_SHA_LF0;JOINED_REQUIRES_pre_post_named_EQUAL;HELD_DRIFT_ANCHORS_THE_EARLIEST_pre_vnode_AND_REQUIRES_post_NOT_EQUAL_pre_WITH_NO_NAMED_WITNESS;NAMED_MISMATCH_REQUIRES_pre_EQUAL_post_AND_named_NOT_EQUAL_pre"

admission_row_schema = R.fetch("AdmissionRowV12")
admission_row_schema["identity_relation_matrix_exact"] = {
  "JOINED" => "identity_EQUALS_named_join.held_before_EQUALS_held_after_EQUALS_named_after_AND_EVERY_AVAILABLE_CONTENT_OR_INVENTORY_OR_SYMLINK_VNODE",
  "HELD_DRIFT" => "identity_EQUALS_THE_EARLIEST_AVAILABLE_PRE_OR_HELD_BEFORE_VNODE;THE_LATER_POST_OR_HELD_AFTER_VNODE_IS_RETAINED_AND_MUST_DIFFER;NO_EQUALITY_COLLAPSE_OR_REBASELINE",
  "NAMED_MISMATCH" => "identity_EQUALS_STABLE_HELD_BEFORE_AND_HELD_AFTER;THE_RETAINED_NAMED_AFTER_VNODE_MUST_DIFFER",
  "NAMED_FSTATAT_FAILED" => "identity_EQUALS_STABLE_HELD_BEFORE_AND_HELD_AFTER;named_after_IS_NULL_AND_THE_TYPED_ERROR_JOIN_IS_EXACT",
  "NOT_REQUESTED_OR_EARLY_FAILURE" => "identity_IS_NULL_ONLY_BEFORE_ANY_SUCCESSFUL_LSTAT_OR_OPEN;OTHERWISE_identity_IS_THE_EARLIEST_OBSERVED_VNODE"
}
admission_row_schema["cross_constraints_exact"] = {
  "kind_identity_type_join" => "EVERY_NONNULL_identity_AND_EVERY_AVAILABLE_NESTED_VNODE_type_enum_EQUALS_kind_enum_or_null",
  "metadata_policy_typed" => "EXPECTED_KIND_MODE_UID_GID_NLINK_FLAGS_AND_POLICY_CAPS_ARE_RESOLVED_FROM_THE_EXACT_PROFILE_MEMBER_AND_COMPARED_TO_TYPED_FIELDS",
  "symlink_target_bounded" => "RawBytesV12.bytes_uint_AT_MOST_readlink_cap_bytes_or_null_AND_TARGET_ROLE_JOIN_EXACT",
  "inventory_applicability" => "inventory_NONNULL_IFF_THE_SELECTED_DIRECTORY_POLICY_REQUIRES_IT;IDENTITY_ONLY_AND_NONDIRECTORY_POLICIES_FORBID_INVENTORY",
  "state_aware_identity_relation" => true
}
admission_row_schema["rule"] = "kind_matrix_exact_SELECTS_ONLY_WHEN_observation_state_enum_PRESENT_ADMITTED_AND_kind_enum_or_null_NON_NULL;PRESENT_ADMITTED_REQUIRES_named_join_JOINED_KIND_POLICY_EXACT_TYPED_METADATA_POLICY_EXACT_BOUNDED_TARGET_OR_INVENTORY_APPLICABILITY_EXACT_AND_NULL_FAILURE_PHASE;EVERY_NONPRESENT_ROW_SELECTS_EXACTLY_ONE_admission_failure_phase_rows_exact_ROW_BY_UNTRUSTED_failure_phase_enum_or_null_PLUS_ALL_TYPED_AXES_AND_IS_REPLAYED_BY_PROFILED_ADMISSION_ROW_FAILURE_PHASE_BICONDITIONAL;identity_relation_matrix_exact_SELECTS_BY_THE_ACTUAL_NAMED_AND_CONTENT_JOIN_STATE_AND_PRESERVES_DIVERGENT_VNODES;NO_PHASE_LABEL_ALONE_CAN_AUTHORIZE_A_BRANCH"

R.fetch("AdmissionSetV12")["rule"] = "THE_FIXED_PROFILE_MEMBER_CENSUS_RUNS_TO_ITS_DECLARED_expected_count_WITHOUT_SHORT_CIRCUIT_AFTER_A_ROW_FAILURE;ONLY_AFTER_EVERY_MEMBER_CALL_RETURNS_IS_THE_IMMUTABLE_rows_ARRAY_FROZEN;observed_count_EQUALS_rows_LENGTH;complete_true_IFF_observed_equals_expected_ORDINALS_CONTIGUOUS_FROM0_ALL_ROWS_JOINED_AND_ERROR_NONE;A_PREFIX_HOLE_REORDER_DUPLICATE_OR_UNOBSERVED_SUFFIX_IS_NOT_A_COMPLETE_BASELINE"
R.fetch("RuntimeAdmissionV12")["rule"] = "os_argv_script_argv_environment_cwd_stream_uid_euid_gid_egid_umask_and_FD_projection_EXACTLY_MATCH_CONTROL_AS_TYPED_VALUES;EXECUTABLE_DESCRIPTOR_IS_NAMED_CONFIGURATION_IDENTITY_NOT_PROOF_OF_ACTUAL_RUNNING_IMAGE;matches_true_IFF_ALL_INBAND_FACTS_AND_error_NONE;A_MISMATCH_RETAINS_THE_COMPLETE_OBSERVED_CARRIER_AND_A_TYPED_NONNONE_ERROR"
R.fetch("FrameSetV12")["rule"] = "observed_count_EQUALS_frames_LENGTH;frames_MUST_BE_THE_EXACT_CONTIGUOUS_REACHED_PREFIX_WITH_NO_HOLE_DUPLICATE_REORDER_OR_FUTURE_MEMBER_RESOLUTION;complete_true_IFF_observed_equals_expected_DISTINCT_PATHS_ALL_FRAME_DIGESTS_VALID_AND_error_NONE"

R["AdmissionMechanicsConformanceVectorV12"] = {
  "tuple_fields_exact_order" => [
    "vector_id", "family_enum", "case_enum", "expected_valid_bool",
    "expected_complete_bool_or_null", "expected_state_enum_or_null",
    "expected_error_state_enum", "expected_error_code_or_null"
  ],
  "tuple_field_types_exact" => [
    "S", "LOCAL_ENUM(family_states)", "S", "B", "B_OR_NULL", "S_OR_NULL", "S", "S_OR_NULL"
  ],
  "family_states" => ["ADMISSION_ROW", "ADMISSION_SET", "RUNTIME_ADMISSION", "FRAME_SET"],
  "rule" => "case_enum_RESOLVES_EXACTLY_ONE_TYPED_CASE_ROW_IN_admission_mechanics_case_materialization_v12;THE_EVALUATOR_MATERIALIZES_THE_RAW_TYPED_PROTOTYPE_EXECUTES_THE_FROZEN_CALL_ORDER_APPLIES_ONLY_THE_DECLARED_MUTATION_AND_RECURSIVELY_VALIDATES_THE_RESULT;NO_VECTOR_ID_EXPECTED_FIELD_OR_PROSE_SELECTS_A_RESULT"
}
R["AdmissionMechanicsConformanceExpectedResultRowV12"] = {
  "tuple_fields_exact_order" => [
    "vector_id", "expected_valid_bool", "expected_complete_bool_or_null",
    "expected_state_enum_or_null", "expected_error_state_enum", "expected_error_code_or_null"
  ],
  "tuple_field_types_exact" => ["S", "B", "B_OR_NULL", "S_OR_NULL", "S", "S_OR_NULL"],
  "rule" => "EXACT_LOSSLESS_PROJECTION_OF_AdmissionMechanicsConformanceVectorV12_FIELDS0_AND3THROUGH7_IN_DECLARATION_ORDER"
}

admission_row_positive_cases = [
  ["AR_ABSENT_CONFIRMED", "ABSENT_CONFIRMED", "ABSENT", nil, "ALL_NULL", "ABSENT", "NO_IDENTITY"],
  ["AR_LSTAT_FAILED", "LSTAT_FAILED", "LSTAT_FAILED", nil, "ALL_NULL", "NOT_REQUESTED", "NO_IDENTITY"],
  ["AR_OPEN_FAILED_AFTER_LSTAT", "OPEN_FAILED_AFTER_LSTAT", "OPEN_FAILED", "REGULAR", "ALL_NULL", "OPEN_FAILED", "EARLIEST_IDENTITY"],
  ["AR_KIND_POLICY_REJECTED", "KIND_OR_METADATA_POLICY_REJECTED", "POLICY_REJECTED", "DIRECTORY", "ALL_NULL", "PRESENT_WRONG_TYPE", "NAMED_ONLY"],
  ["AR_METADATA_POLICY_REJECTED", "KIND_OR_METADATA_POLICY_REJECTED", "POLICY_REJECTED", "REGULAR", "ALL_NULL", "JOINED", "JOINED_EQUAL"],
  ["AR_REGULAR_NOT_ATTEMPTED", "REGULAR_CONTENT_FAILED", "POLICY_REJECTED", "REGULAR", "CONTENT_NOT_ATTEMPTED", "NOT_REQUESTED", "EARLIEST_IDENTITY"],
  ["AR_REGULAR_JOINED_POLICY_FAILURE", "REGULAR_CONTENT_FAILED", "POLICY_REJECTED", "REGULAR", "CONTENT_JOINED_FAILURE", "JOINED", "JOINED_EQUAL"],
  ["AR_REGULAR_HELD_DRIFT", "REGULAR_CONTENT_FAILED", "POLICY_REJECTED", "REGULAR", "CONTENT_HELD_DRIFT", "HELD_DRIFT", "PRE_NOT_EQUAL_POST"],
  ["AR_REGULAR_NAMED_MISMATCH", "REGULAR_CONTENT_FAILED", "POLICY_REJECTED", "REGULAR", "CONTENT_NAMED_MISMATCH", "NAMED_MISMATCH", "HELD_NOT_EQUAL_NAMED"],
  ["AR_REGULAR_POST_FSTAT_FAILED", "REGULAR_CONTENT_FAILED", "POLICY_REJECTED", "REGULAR", "CONTENT_POST_FSTAT_FAILED", "NOT_REQUESTED", "EARLIEST_IDENTITY"],
  ["AR_REGULAR_NAMED_FSTATAT_FAILED", "REGULAR_CONTENT_FAILED", "POLICY_REJECTED", "REGULAR", "CONTENT_NAMED_FSTATAT_FAILED", "NAMED_FSTATAT_FAILED", "STABLE_HELD_NAMED_NULL"],
  ["AR_DIRECTORY_JOINED_POLICY_MISMATCH", "DIRECTORY_INVENTORY_FAILED", "POLICY_REJECTED", "DIRECTORY", "INVENTORY_COMPLETE_MISMATCH", "JOINED", "JOINED_EQUAL"],
  ["AR_DIRECTORY_HELD_DRIFT", "DIRECTORY_INVENTORY_FAILED", "POLICY_REJECTED", "DIRECTORY", "INVENTORY_COMPLETE", "HELD_DRIFT", "PRE_NOT_EQUAL_POST"],
  ["AR_DIRECTORY_NAMED_MISMATCH", "DIRECTORY_INVENTORY_FAILED", "POLICY_REJECTED", "DIRECTORY", "INVENTORY_COMPLETE", "NAMED_MISMATCH", "HELD_NOT_EQUAL_NAMED"],
  ["AR_DIRECTORY_NAMED_FSTATAT_FAILED", "DIRECTORY_INVENTORY_FAILED", "POLICY_REJECTED", "DIRECTORY", "INVENTORY_ERROR", "NAMED_FSTATAT_FAILED", "STABLE_HELD_NAMED_NULL"],
  ["AR_SYMLINK_JOINED_TARGET_FAILURE", "SYMLINK_TARGET_FAILED", "POLICY_REJECTED", "SYMLINK", "BOUNDED_TARGET_MISMATCH", "JOINED", "JOINED_EQUAL"],
  ["AR_SYMLINK_HELD_DRIFT", "SYMLINK_TARGET_FAILED", "POLICY_REJECTED", "SYMLINK", "BOUNDED_TARGET", "HELD_DRIFT", "PRE_NOT_EQUAL_POST"],
  ["AR_SYMLINK_NAMED_MISMATCH", "SYMLINK_TARGET_FAILED", "POLICY_REJECTED", "SYMLINK", "BOUNDED_TARGET", "NAMED_MISMATCH", "HELD_NOT_EQUAL_NAMED"],
  ["AR_SYMLINK_NAMED_FSTATAT_FAILED", "SYMLINK_TARGET_FAILED", "POLICY_REJECTED", "SYMLINK", "READLINK_ERROR_OR_BOUNDED_TARGET", "NAMED_FSTATAT_FAILED", "STABLE_HELD_NAMED_NULL"],
  ["AR_POSTJOIN_HELD_DRIFT", "POSTJOIN_FAILED", "POLICY_REJECTED", "REGULAR", "KIND_SELECTED_SUCCESS", "HELD_DRIFT", "PRE_NOT_EQUAL_POST"],
  ["AR_POSTJOIN_NAMED_MISMATCH", "POSTJOIN_FAILED", "POLICY_REJECTED", "DIRECTORY", "KIND_SELECTED_SUCCESS", "NAMED_MISMATCH", "HELD_NOT_EQUAL_NAMED"],
  ["AR_POSTJOIN_NAMED_FSTATAT_FAILED", "POSTJOIN_FAILED", "POLICY_REJECTED", "SYMLINK", "KIND_SELECTED_SUCCESS", "NAMED_FSTATAT_FAILED", "STABLE_HELD_NAMED_NULL"]
]
admission_row_negative_cases = [
  ["AR_NEG_PHASE_STATE_MISMATCH", "PHASE_STATE_MISMATCH"],
  ["AR_NEG_KIND_IDENTITY_TYPE_MISMATCH", "KIND_IDENTITY_TYPE_MISMATCH"],
  ["AR_NEG_HELD_DRIFT_EQUAL_VNODES", "HELD_DRIFT_EQUAL_VNODES"],
  ["AR_NEG_NAMED_MISMATCH_EQUAL_VNODES", "NAMED_MISMATCH_EQUAL_VNODES"],
  ["AR_NEG_FAILURE_PAYLOAD_SHAPE", "FAILURE_PAYLOAD_SHAPE_INVALID"],
  ["AR_NEG_ERROR_JOIN_MISMATCH", "ERROR_JOIN_MISMATCH"],
  ["AR_NEG_SYMLINK_TARGET_EXCEEDS_CAP", "SYMLINK_TARGET_EXCEEDS_CAP"],
  ["AR_NEG_INVENTORY_NOT_APPLICABLE", "INVENTORY_NOT_APPLICABLE"]
]
admission_set_cases = [
  ["AS_FULL_SUCCESS", true, true, "FULL_CENSUS"],
  ["AS_FULL_WITH_RETAINED_FAILURE", true, false, "FULL_CENSUS_WITH_FAILURE"],
  ["AS_SHORT_PREFIX", true, false, "SHORT_CENSUS"],
  ["AS_HOLE_OR_REORDER", false, nil, "HOLE_OR_REORDER"]
]
runtime_admission_cases = [
  ["RA_EXACT_MATCH", true, "MATCH"],
  ["RA_ARGV_MISMATCH", false, "MISMATCH"],
  ["RA_ENVIRONMENT_MISMATCH", false, "MISMATCH"],
  ["RA_CWD_VNODE_MISMATCH", false, "MISMATCH"],
  ["RA_FD_CONTRACT_MISMATCH", false, "MISMATCH"]
]
frame_set_cases = [
  ["FS_REACHED_PREFIX_0", true, false, "PREFIX_0"],
  ["FS_REACHED_PREFIX_1", true, false, "PREFIX_1"],
  ["FS_REACHED_PREFIX_2", true, false, "PREFIX_2"],
  ["FS_FULL_3", true, true, "FULL_3"],
  ["FS_HOLE", false, nil, "HOLE"],
  ["FS_FUTURE_MEMBER_RESOLVED", false, nil, "FUTURE_MEMBER_RESOLVED"]
]

S["admission_mechanics_case_materialization_v12"] = {
  "admission_row_case_tuple_fields_exact_order" => [
    "case_enum", "failure_phase_enum", "observation_state_enum", "kind_enum_or_null",
    "payload_case_enum", "named_join_state_enum", "identity_relation_case_enum"
  ],
  "admission_row_positive_case_rows_exact" => admission_row_positive_cases,
  "admission_row_negative_case_rows_exact" => admission_row_negative_cases,
  "admission_set_case_rows_exact" => admission_set_cases,
  "runtime_admission_case_rows_exact" => runtime_admission_cases,
  "frame_set_case_rows_exact" => frame_set_cases,
  "admission_set_call_order_exact" => [
    "RESOLVE_THE_FIXED_PROFILE_ONCE", "FOR_EACH_EXPECTED_MEMBER_IN_ORDINAL_ORDER_EXECUTE_THE_COMPLETE_LSTAT_OPEN_READ_OR_READLINK_INVENTORY_AND_NAMED_JOIN_CASE_WITHOUT_SHORT_CIRCUIT", "RETAIN_EVERY_SUCCESS_OR_FAILURE_ROW", "AFTER_THE_LAST_EXPECTED_MEMBER_FREEZE_THE_IMMUTABLE_AdmissionSetV12", "VALIDATE_COUNT_ORDINAL_AND_COMPLETE_BICONDITIONAL"
  ],
  "frame_set_call_order_exact" => [
    "DERIVE_REACHED_COUNT_FROM_THE_TYPED_PARENT", "RESOLVE_ONLY_MEMBERS_STRICTLY_BELOW_REACHED_COUNT", "FREEZE_THE_EXACT_CONTIGUOUS_PREFIX", "FORBID_ANY_FUTURE_MEMBER_RESOLUTION", "VALIDATE_FrameSetV12"
  ],
  "materialization_rule" => "EVERY_CASE_STARTS_FROM_A_RECURSIVELY_VALID_TYPED_PROTOTYPE;CASE_ROWS_APPLY_ONE_EXACT_SIMULTANEOUS_TYPED_MUTATION_SET_WITH_EXPECTED_OLD_VALUES;ADMISSION_ROW_CASES_EXERCISE_ALL8_PHASES_AND22_POSITIVE_SUBBRANCHES_PLUS8_NEGATIVES;ADMISSION_SET_EXECUTES_A_FULL_CENSUS_EVEN_AFTER_THE_FIRST_RETAINED_FAILURE;NO_EXPECTED_RESULT_FIELD_IS_READ_DURING_MATERIALIZATION"
}

admission_vectors = []
admission_row_positive_cases.each do |case_row|
  admission_vectors << [case_row.fetch(0), "ADMISSION_ROW", case_row.fetch(0), true, nil, case_row.fetch(2), "NONE", nil]
end
admission_row_negative_cases.each do |case_row|
  admission_vectors << [case_row.fetch(0), "ADMISSION_ROW", case_row.fetch(0), false, nil, nil, "PREDICATE_FALSE", case_row.fetch(1)]
end
admission_set_cases.each do |case_id, valid, complete, state|
  admission_vectors << [case_id, "ADMISSION_SET", case_id, valid, complete, state, valid ? "NONE" : "PREDICATE_FALSE", valid ? nil : state]
end
runtime_admission_cases.each do |case_id, matches, state|
  admission_vectors << [case_id, "RUNTIME_ADMISSION", case_id, true, nil, state, "NONE", nil]
end
frame_set_cases.each do |case_id, valid, complete, state|
  admission_vectors << [case_id, "FRAME_SET", case_id, valid, complete, state, valid ? "NONE" : "PREDICATE_FALSE", valid ? nil : state]
end
raise "admission mechanics count #{admission_vectors.length}" unless admission_vectors.length == 45

# Prove that OPERATION_TIMING selects by the complete
# (capture-pair-state,process-state) product rather than by process state alone.
timing = S.fetch("timing_conformance_catalog_v12")
unless timing.fetch("call_order_vectors").any? { |row| row.fetch("vector_id") == "TC_OPERATION_REAPED_EXIT_CAPTURE_SELECTOR_INVALID" }
  source = timing.fetch("call_order_vectors").find { |row| row.fetch("vector_id") == "TC_OPERATION_REAPED_EXIT" }
  raise "missing reaped-exit timing source" unless source
  negative = clone(source)
  negative["vector_id"] = "TC_OPERATION_REAPED_EXIT_CAPTURE_SELECTOR_INVALID"
  negative["capture_pair_state_enum_or_null"] = "UNAVAILABLE"
  negative["expected_valid_bool"] = false
  negative["expected_complete_bool_or_null"] = nil
  negative["expected_error"] = error_pred("CALL_ORDER_CONTEXT_SELECTOR_MISMATCH")
  timing.fetch("call_order_vectors") << negative
end
timing.fetch("call_order_vectors").sort_by! { |row| row.fetch("vector_id") }
timing.fetch("coverage_exact")["call_order_vector_ids_exact_order"] =
  timing.fetch("call_order_vectors").map { |row| row.fetch("vector_id") }
timing["vector_count_uint"] = timing.fetch("join_vectors").length + timing.fetch("call_order_vectors").length + timing.fetch("outer_state_vectors").length + timing.fetch("failure_cut_vectors").length
raise "timing total #{timing.fetch("vector_count_uint")}" unless timing.fetch("vector_count_uint") == 88

# Expected timing rows are one lossless family-order projection.  Keep their
# exact schema order while rebuilding the newly extended call-order family.
timing["expected_result_rows"] = []
timing.fetch("join_vectors").each do |row|
  timing["expected_result_rows"] << [
    "TIMING_JOIN", row.fetch("vector_id"), row.fetch("expected_valid_bool"),
    row.fetch("expected_applicable_bool_or_null"), row.fetch("expected_state_enum_or_null"),
    row.fetch("expected_holds_bool_or_null"), row.dig("expected_error", "state_enum"),
    row.dig("expected_error", "code_string_or_null")
  ]
end
timing.fetch("call_order_vectors").each do |row|
  timing["expected_result_rows"] << [
    "CALL_ORDER", row.fetch("vector_id"), row.fetch("expected_valid_bool"),
    row.fetch("expected_complete_bool_or_null"), nil, nil,
    row.dig("expected_error", "state_enum"), row.dig("expected_error", "code_string_or_null")
  ]
end
timing.fetch("failure_cut_vectors").each do |row|
  timing["expected_result_rows"] << [
    "FAILURE_CUT", row.fetch("vector_id"), row.fetch("expected_valid_bool"),
    row.fetch("expected_timing_complete_bool_or_null"), nil, nil,
    row.dig("expected_error", "state_enum"), row.dig("expected_error", "code_string_or_null")
  ]
end
timing.fetch("outer_state_vectors").each do |row|
  timing["expected_result_rows"] << [
    "OUTER_STATE", row.fetch("vector_id"), row.fetch("expected_valid_bool"),
    row.fetch("expected_valid_bool") ? row.fetch("timing_complete_bool") : nil,
    nil, nil, row.dig("expected_error", "state_enum"), row.dig("expected_error", "code_string_or_null")
  ]
end

# Derive OUT_UNENTERED_EVIDENCE_CLEAN from its eleven raw carrier groups.  The
# legacy observation vectors remain untouched; this is a distinct mechanics
# family with its own lossless expected projection and explicit status joins.
R["OuterUnenteredEvidencePredicateInputV12"] = {
  "keys" => [
    "endpoint_authorized_evaluation", "start_record", "prefix_result",
    "artifact_slots", "journal_chain", "journal_frame_bytes",
    "operation_prefix_projection", "root_traversals", "fixed_output_observations",
    "admission_baseline_joins", "frame_baseline_joins"
  ],
  "field_types_exact" => {
    "endpoint_authorized_evaluation" => "REF(PredicateEvaluationV12)",
    "start_record" => "REF(RecordObservationV12)", "prefix_result" => "REF(RecordObservationV12)",
    "artifact_slots" => "REF(ArtifactSlotSetV12)", "journal_chain" => "REF(RecordChainV12)",
    "journal_frame_bytes" => "REF(RecordFrameBytesSetV12)",
    "operation_prefix_projection" => "REF(OuterOperationCensusProjectionV12)",
    "root_traversals" => "REF(RootTraversalSetV12)",
    "fixed_output_observations" => "REF(OutputObservationSetV12)",
    "admission_baseline_joins" => "REF(AdmissionBaselineJoinSetV12)",
    "frame_baseline_joins" => "REF(FrameBaselineJoinSetV12)"
  },
  "rule" => "CONFORMANCE_ONLY_SELF_CARRIER;endpoint_authorized_evaluation_ID_EXACT_OUT_UNENTERED_ENDPOINT_AUTHORIZED;ALL_TEN_EVIDENCE_GROUPS_RECURSIVELY_VALIDATE_IN_THE_EXACT_OUTER_PROFILES_AND_CROSS_JOIN_THE_SAME_RUNTIME_BODY;THE_LITERAL_FAILURE_ORDER82_APPLICABILITY_AND_ASSERTION_PROGRAMS_CONSUME_THIS_CARRIER_WITH_NO_VECTOR_ID_STATUS_OR_EXPECTED_RESULT_INPUT"
}
R["OuterUnenteredEvidenceConformanceVectorV12"] = {
  "tuple_fields_exact_order" => [
    "vector_id", "endpoint_case_enum", "start_case_enum", "prefix_case_enum",
    "artifact_case_enum", "journal_chain_case_enum", "journal_frame_bytes_case_enum",
    "operation_projection_case_enum", "root_case_enum", "fixed_output_case_enum",
    "admission_baseline_case_enum", "frame_baseline_case_enum", "expected_valid_bool",
    "expected_applicable_bool_or_null", "expected_assertion_bool_or_null",
    "expected_predicate_state_enum_or_null", "expected_error_state_enum",
    "expected_error_code_or_null"
  ],
  "tuple_field_types_exact" => [
    "S", "LOCAL_ENUM(endpoint_cases_exact)", "LOCAL_ENUM(record_cases_exact)",
    "LOCAL_ENUM(record_cases_exact)", "LOCAL_ENUM(artifact_cases_exact)",
    "LOCAL_ENUM(journal_cases_exact)", "LOCAL_ENUM(frame_bytes_cases_exact)",
    "LOCAL_ENUM(operation_cases_exact)", "LOCAL_ENUM(root_cases_exact)",
    "LOCAL_ENUM(fixed_output_cases_exact)", "LOCAL_ENUM(baseline_cases_exact)",
    "LOCAL_ENUM(baseline_cases_exact)", "B", "B_OR_NULL", "B_OR_NULL", "S_OR_NULL", "S", "S_OR_NULL"
  ],
  "endpoint_cases_exact" => ["TRUE", "FALSE", "UNKNOWN"],
  "record_cases_exact" => ["CLEAN_ABSENT", "DEFINITIVE_PRESENT", "OBSERVATION_FSTAT_FAILED", "OBSERVATION_SCAN_ERROR"],
  "artifact_cases_exact" => ["CLEAN_EXPECTED", "DEFINITIVE_DIRTY", "OBSERVATION_FSTAT_FAILED"],
  "journal_cases_exact" => ["CLEAN_ABSENT", "DEFINITIVE_VALID_FINAL", "OBSERVATION_SCAN_ERROR", "OPERATION_UNAVAILABLE"],
  "frame_bytes_cases_exact" => ["CLEAN_EMPTY", "DEFINITIVE_ROWS_PRESENT", "DECODE_INCOMPLETE"],
  "operation_cases_exact" => ["CLEAN_ABSENT", "DEFINITIVE_VALID_FINAL", "UNAVAILABLE"],
  "root_cases_exact" => ["CLEAN_ABSENT", "DEFINITIVE_PRESENT", "OPEN_FAILED", "CAPTURE_CENSUS_INCOMPLETE"],
  "fixed_output_cases_exact" => ["CLEAN_ABSENT", "DEFINITIVE_PRESENT_REGULAR", "NOT_REACHED"],
  "baseline_cases_exact" => ["CLEAN_EQUAL", "DEFINITIVE_NOT_EQUAL", "UNAVAILABLE"],
  "rule" => "EVERY_CASE_ROW_DRIVES_THE_TYPED_outer_unentered_evidence_case_materialization_v12_PROGRAM;THE_EVALUATOR_CONSTRUCTS_AND_RECURSIVELY_VALIDATES_RAW_CARRIERS_PROJECTS_OuterUnenteredEvidencePredicateInputV12_DEEP_EQUALS_AN_INDEPENDENT_COPY_AND_EXECUTES_THE_LITERAL_PREDICATE_PROGRAM;NO_OUTPUT_OR_VALIDITY_IS_INFERRED_FROM_vector_id"
}
R["OuterUnenteredEvidenceConformanceExpectedResultRowV12"] = {
  "tuple_fields_exact_order" => [
    "vector_id", "expected_valid_bool", "expected_applicable_bool_or_null",
    "expected_assertion_bool_or_null", "expected_predicate_state_enum_or_null",
    "expected_error_state_enum", "expected_error_code_or_null"
  ],
  "tuple_field_types_exact" => ["S", "B", "B_OR_NULL", "B_OR_NULL", "S_OR_NULL", "S", "S_OR_NULL"],
  "rule" => "EXACT_LOSSLESS_PROJECTION_OF_OuterUnenteredEvidenceConformanceVectorV12_FIELDS0_AND12THROUGH17_IN_DECLARATION_ORDER"
}

outer_unentered_case_fields = %w[
  endpoint_case_enum start_case_enum prefix_case_enum artifact_case_enum
  journal_chain_case_enum journal_frame_bytes_case_enum operation_projection_case_enum
  root_case_enum fixed_output_case_enum admission_baseline_case_enum frame_baseline_case_enum
]
clean_cases = [
  "TRUE", "CLEAN_ABSENT", "CLEAN_ABSENT", "CLEAN_EXPECTED", "CLEAN_ABSENT",
  "CLEAN_EMPTY", "CLEAN_ABSENT", "CLEAN_ABSENT", "CLEAN_ABSENT", "CLEAN_EQUAL", "CLEAN_EQUAL"
]
scenario_cases = {
  "OU_CLEAN_ALL_ABSENT_TRUE" => clean_cases,
  "OU_DIRTY_START_FINAL" => clean_cases.dup,
  "OU_DIRTY_PREFIX_FINAL" => clean_cases.dup,
  "OU_DIRTY_ARTIFACT_STAGING" => clean_cases.dup,
  "OU_DIRTY_JOURNAL_VALID_FINAL" => clean_cases.dup,
  "OU_DIRTY_JOURNAL_FRAME_DECODE" => clean_cases.dup,
  "OU_DIRTY_ROOT_PRESENT" => clean_cases.dup,
  "OU_DIRTY_FIXED_OUTPUT_PRESENT" => clean_cases.dup,
  "OU_DIRTY_ADMISSION_NOT_EQUAL" => clean_cases.dup,
  "OU_DIRTY_FRAME_NOT_EQUAL" => clean_cases.dup,
  "OU_NA_START_FSTAT_FAILED" => clean_cases.dup,
  "OU_NA_PREFIX_SCAN_ERROR" => clean_cases.dup,
  "OU_NA_ARTIFACT_FSTAT_FAILED" => clean_cases.dup,
  "OU_NA_JOURNAL_SCAN_ERROR" => clean_cases.dup,
  "OU_NA_OPERATION_UNAVAILABLE" => clean_cases.dup,
  "OU_NA_ROOT_OPEN_FAILED" => clean_cases.dup,
  "OU_NA_CAPTURE_CENSUS_INCOMPLETE" => clean_cases.dup,
  "OU_NA_FIXED_OUTPUT_NOT_REACHED" => clean_cases.dup,
  "OU_NA_ADMISSION_UNAVAILABLE" => clean_cases.dup,
  "OU_NA_FRAME_UNAVAILABLE" => clean_cases.dup,
  "OU_NA_ENDPOINT_FALSE" => clean_cases.dup,
  "OU_UNKNOWN_ENDPOINT_UNKNOWN" => clean_cases.dup
}
# Defensively duplicate every row again before the scenario mutations.
scenario_cases.transform_values!(&:dup)
scenario_cases["OU_DIRTY_START_FINAL"][1] = "DEFINITIVE_PRESENT"
scenario_cases["OU_DIRTY_PREFIX_FINAL"][2] = "DEFINITIVE_PRESENT"
scenario_cases["OU_DIRTY_ARTIFACT_STAGING"][3] = "DEFINITIVE_DIRTY"
scenario_cases["OU_DIRTY_JOURNAL_VALID_FINAL"][4] = "DEFINITIVE_VALID_FINAL"
scenario_cases["OU_DIRTY_JOURNAL_VALID_FINAL"][5] = "DEFINITIVE_ROWS_PRESENT"
scenario_cases["OU_DIRTY_JOURNAL_VALID_FINAL"][6] = "DEFINITIVE_VALID_FINAL"
scenario_cases["OU_DIRTY_JOURNAL_FRAME_DECODE"][5] = "DEFINITIVE_ROWS_PRESENT"
scenario_cases["OU_DIRTY_ROOT_PRESENT"][7] = "DEFINITIVE_PRESENT"
scenario_cases["OU_DIRTY_FIXED_OUTPUT_PRESENT"][8] = "DEFINITIVE_PRESENT_REGULAR"
scenario_cases["OU_DIRTY_ADMISSION_NOT_EQUAL"][9] = "DEFINITIVE_NOT_EQUAL"
scenario_cases["OU_DIRTY_FRAME_NOT_EQUAL"][10] = "DEFINITIVE_NOT_EQUAL"
scenario_cases["OU_NA_START_FSTAT_FAILED"][1] = "OBSERVATION_FSTAT_FAILED"
scenario_cases["OU_NA_PREFIX_SCAN_ERROR"][2] = "OBSERVATION_SCAN_ERROR"
scenario_cases["OU_NA_ARTIFACT_FSTAT_FAILED"][3] = "OBSERVATION_FSTAT_FAILED"
scenario_cases["OU_NA_JOURNAL_SCAN_ERROR"][4] = "OBSERVATION_SCAN_ERROR"
scenario_cases["OU_NA_OPERATION_UNAVAILABLE"][4] = "OPERATION_UNAVAILABLE"
scenario_cases["OU_NA_OPERATION_UNAVAILABLE"][6] = "UNAVAILABLE"
scenario_cases["OU_NA_ROOT_OPEN_FAILED"][7] = "OPEN_FAILED"
scenario_cases["OU_NA_CAPTURE_CENSUS_INCOMPLETE"][7] = "CAPTURE_CENSUS_INCOMPLETE"
scenario_cases["OU_NA_FIXED_OUTPUT_NOT_REACHED"][8] = "NOT_REACHED"
scenario_cases["OU_NA_ADMISSION_UNAVAILABLE"][9] = "UNAVAILABLE"
scenario_cases["OU_NA_FRAME_UNAVAILABLE"][10] = "UNAVAILABLE"
scenario_cases["OU_NA_ENDPOINT_FALSE"][0] = "FALSE"
scenario_cases["OU_UNKNOWN_ENDPOINT_UNKNOWN"][0] = "UNKNOWN"

dirty_ids = scenario_cases.keys.select { |id| id.start_with?("OU_DIRTY_") }
na_ids = scenario_cases.keys.select { |id| id.start_with?("OU_NA_") }
vectors = scenario_cases.map do |id, cases|
  expected = if id == "OU_CLEAN_ALL_ABSENT_TRUE"
    [true, true, "TRUE", "NONE", nil]
  elsif dirty_ids.include?(id)
    [true, false, "FALSE", "NONE", nil]
  elsif id == "OU_UNKNOWN_ENDPOINT_UNKNOWN"
    [nil, nil, "UNKNOWN", "PREDICATE_FALSE", "OUTER_ENDPOINT_EVALUATION_UNKNOWN"]
  else
    [false, nil, "NOT_APPLICABLE", "NONE", nil]
  end
  [id, *cases, true, *expected]
end
raise "outer-unentered vector count #{vectors.length}" unless vectors.length == 22

S["outer_unentered_evidence_case_materialization_v12"] = {
  "input_type_id" => "OuterUnenteredEvidenceConformanceVectorV12",
  "output_type_id" => "OuterUnenteredEvidencePredicateInputV12",
  "clean_prototype_case_row" => outer_unentered_case_fields.zip(clean_cases).to_h,
  "scenario_rows_exact" => scenario_cases.map { |id, cases| [id, *cases] },
  "case_tuple_fields_exact_order" => ["vector_id", *outer_unentered_case_fields],
  "materialization_program_exact" => [
    "SELECT_THE_CANONICAL_CLEAN_OUTER_RAW_CARRIER_PROTOTYPE_BY_EXACT_SET_PROFILES",
    "APPLY_THE_SCENARIO_TYPED_SIMULTANEOUS_MUTATIONS_TO_AN_IMMUTABLE_COPY_WITH_EXPECTED_OLD_TYPE_AND_CANONICAL_HASH",
    "RECURSIVELY_VALIDATE_EVERY_RESULTING_RAW_CARRIER_AND_ALL_CROSS_CARRIER_RUNTIME_JOINS",
    "PROJECT_THE_ELEVEN_KEYS_OF_OuterUnenteredEvidencePredicateInputV12",
    "DEEP_EQUAL_AN_INDEPENDENT_MATERIALIZATION_OF_THE_SAME_CASE",
    "EXECUTE_FAILURE_ORDER82_LITERAL_APPLICABILITY_THEN_ASSERTION_PROGRAM"
  ],
  "mutation_rule" => "NO_EXPECTED_RESULT_VECTOR_ID_PREFIX_OR_STATUS_FIELD_IS_READ;DEFINITIVE_ROWS_RETAIN_COMPLETE_OBSERVATIONS_AND_DERIVE_ASSERTION_FALSE;FSTAT_SCAN_OPEN_UNAVAILABLE_OR_INCOMPLETE_CAPTURE_ROWS_DERIVE_APPLICABILITY_FALSE;ENDPOINT_UNKNOWN_PROPAGATES_ITS_EXACT_ERROR"
}

observation = S.fetch("observation_integrity_conformance_catalog_v12")

# The observation evaluator returns the actual operation-prefix carrier, not a
# leaf/count paraphrase.  Full frame references retain vnode and byte identity.
R["OperationPrefixProjectionExpectedV12"] = {
  "keys" => [
    "valid_prefix_count_uint", "valid_frame_refs", "missing_expected_frames", "first_unentered"
  ],
  "field_types_exact" => {
    "valid_prefix_count_uint" => "U",
    "valid_frame_refs" => "ARRAY(FrameReferenceV12,0,5,ContextProfileMemberOrderV12)",
    "missing_expected_frames" => "ARRAY(S,0,5,MissingOperationFrameOrderV12)",
    "first_unentered" => "REF(FirstUnenteredV12)"
  },
  "rule" => "EXACT_DEEP_TYPED_PROJECTION_OF_OperationPrefixProjectionV12_FIELDS_valid_prefix_count_uint_valid_frame_refs_missing_expected_frames_first_unentered;FULL_FrameReferenceV12_PATH_VNODE_BYTES_FRAME_SHA_AND_PAYLOAD_SHA_EQUALITY_REQUIRED;A_LEAF_COUNT_OR_ORDINAL_SUMMARY_CANNOT_SUBSTITUTE"
}

operation_labels = J.fetch("swiftpm_operations_ordered").map { |row| row.fetch("label") }
operation_leaves = %w[01-t01.json 02-b01.json 03-b02.json 04-b03.json 05-b04.json]
raise "operation labels" unless operation_labels.length == 5

def conformance_frame_ref(leaf, label, index, status)
  tag = "#{leaf}|#{label}|#{index}|#{status}"
  payload_sha = Digest::SHA256.hexdigest("payload|#{tag}")
  frame_bytes = JSON.generate({
    "schema" => "ergentics.conformance.operation-frame.v12",
    "ordinal_uint" => index, "label" => label, "status" => status,
    "payload_sha256" => payload_sha
  }) + "\n"
  bytes = frame_bytes.bytesize
  {
    "path" => "/v12-conformance/journal/#{leaf}",
    "schema" => "ergentics.conformance.operation-frame.v12",
    "status" => status,
    "vnode" => {
      "type_enum" => "REGULAR", "device_uint" => 12_019,
      "inode_uint" => 120_190 + index, "generation_uint" => 1,
      "uid_uint" => 501, "gid_uint" => 20, "mode_octal4" => "0400",
      "nlink_uint" => 1, "flags_uint" => 0, "size_uint" => bytes,
      "ctime_seconds_int" => 0, "ctime_nanoseconds_uint" => index,
      "mtime_seconds_int" => 0, "mtime_nanoseconds_uint" => index
    },
    "bytes_uint" => bytes, "lf_count_uint" => 1,
    "complete_frame_sha256" => Digest::SHA256.hexdigest(frame_bytes),
    "payload_sha256" => payload_sha
  }
end

def operation_prefix_expected(scope, states, labels, leaves)
  prefix_count = states.take_while { |state| state == "VALID_FINAL" }.length
  clean_suffix = states == (["VALID_FINAL"] * prefix_count + ["ABSENT"] * (5 - prefix_count))
  ref_indices = if scope == "OUTER"
    states.each_index.select { |index| states.fetch(index) == "VALID_FINAL" }
  else
    (0...prefix_count).to_a
  end
  refs = ref_indices.map do |index|
    status = if clean_suffix && prefix_count < 5 && index == prefix_count - 1
      "FAIL_OPERATION"
    else
      "PASS_OPERATION"
    end
    conformance_frame_ref(leaves.fetch(index), labels.fetch(index), index, status)
  end
  missing = states.each_index.select { |index| states.fetch(index) != "VALID_FINAL" }.map { |index| leaves.fetch(index) }
  first_unentered = if prefix_count == 5
    {"present_bool" => false, "operation_label_or_null" => nil, "reason_predicate_id_or_null" => nil}
  else
    reason = if clean_suffix
      prefix_count.zero? ? "J_R00_FAILURE_CHAIN" : "J_OPERATION_SUCCESS"
    else
      "J_OPERATION_EVIDENCE_COMPLETE"
    end
    {
      "present_bool" => true,
      "operation_label_or_null" => labels.fetch(prefix_count),
      "reason_predicate_id_or_null" => reason
    }
  end
  {
    "valid_prefix_count_uint" => prefix_count,
    "valid_frame_refs" => refs,
    "missing_expected_frames" => missing,
    "first_unentered" => first_unentered
  }
end

base_prefix_case = observation.fetch("vectors").find { |row| row.fetch(0) == "OI_TERMINAL_CONTROLLED_B02_FAIL" }
raise "missing prefix case prototype" unless base_prefix_case
prefix_case_rows = [
  ["OI_TERMINAL_CONTROLLED_T01_FAIL", 1],
  ["OI_TERMINAL_CONTROLLED_B01_FAIL", 2],
  ["OI_TERMINAL_CONTROLLED_B03_FAIL", 4]
]
prefix_case_rows.each do |vector_id, count|
  next if observation.fetch("vectors").any? { |row| row.fetch(0) == vector_id }
  row = clone(base_prefix_case)
  row[0] = vector_id
  row[2] = ["VALID_FINAL"] * (count + 1) + ["ABSENT"] * (6 - count)
  row[3] = ["MATCH"] * count + ["NOT_APPLICABLE"] * (6 - count)
  row[4] = ["VALID_FINAL"] * count + ["ABSENT"] * (5 - count)
  row[17] = true
  row[18] = true
  row[19] = false
  observation.fetch("vectors") << row
end
observation.fetch("coverage_exact")["vector_ids_exact_order"] =
  observation.fetch("vectors").map { |row| row.fetch(0) }

observation_vector_schema = R.fetch("ObservationIntegrityConformanceVectorV12")
unless observation_vector_schema.fetch("tuple_fields_exact_order").include?("expected_operation_projection_or_null")
  observation_vector_schema.fetch("tuple_fields_exact_order").insert(20, "expected_operation_projection_or_null")
  observation_vector_schema.fetch("tuple_field_types_exact").insert(20, "REF_OR_NULL(OperationPrefixProjectionExpectedV12)")
end
observation_vector_schema["rule"] += ";expected_operation_projection_or_null_IS_NULL_EXACTLY_FOR_R00_AND_OTHERWISE_DEEP_EQUALS_THE_FOUR_NAMED_OperationPrefixProjectionV12_FIELDS_INCLUDING_EVERY_FULL_TYPED_FrameReferenceV12;THE_VALID_PREFIX_IS_THE_LONGEST_INITIAL_VALID_FINAL_RUN_AND_LATER_VALID_ROWS_REMAIN_VISIBLE_FOR_HOLE_DETECTION"

observation.fetch("vectors").each do |row|
  next if row.length == 34
  raise "unexpected observation width #{row.length}" unless row.length == 33
  expected_projection = row.fetch(1) == "R00" ? nil : operation_prefix_expected(row.fetch(1), row.fetch(4), operation_labels, operation_leaves)
  row.replace([*row[0..19], expected_projection, *row[20..32]])
end

observation_expected_schema = R.fetch("ObservationIntegrityConformanceExpectedResultRowV12")
unless observation_expected_schema.fetch("tuple_fields_exact_order").include?("expected_operation_projection_or_null")
  observation_expected_schema.fetch("tuple_fields_exact_order").insert(7, "expected_operation_projection_or_null")
  observation_expected_schema.fetch("tuple_field_types_exact").insert(7, "REF_OR_NULL(OperationPrefixProjectionExpectedV12)")
end
observation_expected_schema["rule"] = "EXACT_LOSSLESS_PROJECTION_OF_VECTOR_FIELDS0_AND14THROUGH33_IN_DECLARATION_ORDER;BOTH_EVALUATORS_MUST_RETURN_THIS_ROW_BYTE_FOR_BYTE_INCLUDING_FULL_TYPED_OPERATION_FRAME_REFERENCES"
observation["expected_result_rows"] = observation.fetch("vectors").map do |row|
  [row.fetch(0), *clone(row[14..33])]
end

# A finite table maps a replayed current OPERATION decision and first failure
# to its causal next-operation marker.  It never guesses a reason from a leaf.
R["OperationFirstUnenteredInputV12"] = {
  "keys" => ["operation_label", "status_decision", "first_failure"],
  "field_types_exact" => {
    "operation_label" => "S", "status_decision" => "REF(StatusDecisionV12)",
    "first_failure" => "REF(FailureV12)"
  },
  "rule" => "ALL_THREE_FIELDS_ARE_READ_FROM_THE_SAME_IMMUTABLE_CURRENT_JOURNAL_OPERATION_BODY;status_decision_MUST_REPLAY_EXACTLY_UNDER_JOURNAL_OPERATION_AND_first_failure_MUST_SATISFY_decision_replay_registry_v12.first_failure_projection_exact_BEFORE_TABLE_SELECTION"
}
R["OperationFirstUnenteredRuleRowV12"] = {
  "tuple_fields_exact_order" => [
    "operation_label", "selected_status_enum", "result_present_bool",
    "result_operation_label_or_null", "reason_source_enum"
  ],
  "tuple_field_types_exact" => [
    "S", "ENUM(RecordStatusV12)", "B", "S_OR_NULL", "LOCAL_ENUM(reason_sources)"
  ],
  "reason_sources" => ["NONE", "CURRENT_FIRST_FAILURE_PREDICATE"],
  "rule" => "EXACTLY_ONE_ROW_BY_operation_label_AND_status_decision.selected_status_enum;CURRENT_FIRST_FAILURE_PREDICATE_COPIES_THE_REPLAYED_INPUT_first_failure.predicate_id_or_null_EXACTLY;NONE_EMITS_NULL_REASON"
}
R["OperationFirstUnenteredConformanceVectorV12"] = {
  "tuple_fields_exact_order" => ["vector_id", "input", "expected_result"],
  "tuple_field_types_exact" => ["S", "REF(OperationFirstUnenteredInputV12)", "REF(FirstUnenteredV12)"],
  "rule" => "EXECUTE_operation_first_unentered_materialization_v12_ON_input_AND_DEEP_TYPED_EQUAL_expected_result;NO_EXPECTED_RESULT_OR_VECTOR_ID_IS_READ_BY_THE_OPERATOR"
}
R["OperationFirstUnenteredConformanceExpectedResultRowV12"] = {
  "tuple_fields_exact_order" => ["vector_id", "expected_result"],
  "tuple_field_types_exact" => ["S", "REF(FirstUnenteredV12)"],
  "rule" => "EXACT_LOSSLESS_PROJECTION_OF_OperationFirstUnenteredConformanceVectorV12_FIELDS0_AND2"
}

operation_ruleset = D.fetch("status_ruleset_registry_v12").fetch("JOURNAL_OPERATION")
operation_status_cases = [
  ["PASS_OPERATION", "J_PASS", %w[J_CONTRADICTORY J_PASS], failure_absent],
  ["FAIL_OPERATION", "J_FAIL", %w[J_CONTRADICTORY J_PASS J_FAIL], failure_present("OPERATION", nil, "J_OPERATION_SUCCESS", "FALSE")],
  ["INCOMPLETE_OPERATION", "J_INCOMPLETE", %w[J_CONTRADICTORY J_PASS J_FAIL J_INCOMPLETE], failure_present("OPERATION", nil, "J_FRAME_PREDECESSOR_HASH_VALID", "FALSE")]
]
first_unentered_rule_rows = []
first_unentered_vectors = []
operation_labels.each_with_index do |label, operation_index|
  operation_status_cases.each do |status, rule_id, evaluated, failure_template|
    result_present = status != "PASS_OPERATION" && operation_index < operation_labels.length - 1
    next_label = result_present ? operation_labels.fetch(operation_index + 1) : nil
    reason_source = result_present ? "CURRENT_FIRST_FAILURE_PREDICATE" : "NONE"
    first_unentered_rule_rows << [label, status, result_present, next_label, reason_source]
    first_failure = clone(failure_template)
    first_failure["operation_label_or_null"] = label if first_failure.fetch("present_bool")
    status_decision = {
      "ruleset_id" => operation_ruleset.fetch(0),
      "ruleset_complete_json_sha256" => operation_ruleset.fetch(2),
      "selected_rule_id" => rule_id,
      "selected_status_enum" => status,
      "evaluated_rule_ids_exact_order" => evaluated
    }
    expected = {
      "present_bool" => result_present,
      "operation_label_or_null" => next_label,
      "reason_predicate_id_or_null" => result_present ? first_failure.fetch("predicate_id_or_null") : nil
    }
    first_unentered_vectors << [
      "FU_#{operation_index + 1}_#{status}",
      {"operation_label" => label, "status_decision" => status_decision, "first_failure" => first_failure},
      expected
    ]
  end
end
raise "first-unentered rows" unless first_unentered_rule_rows.length == 15 && first_unentered_vectors.length == 15
S["operation_first_unentered_materialization_v12"] = {
  "source_type_id" => "OperationFirstUnenteredInputV12",
  "output_type_id" => "FirstUnenteredV12",
  "rule_rows_exact" => first_unentered_rule_rows,
  "materialization_program_exact" => [
    "RECURSIVELY_VALIDATE_THE_SAME_BODY_OPERATION_LABEL_STATUS_DECISION_AND_FIRST_FAILURE",
    "REPLAY_THE_JOURNAL_OPERATION_STATUS_RULESET_AND_EXACT_FIRST_FAILURE_PROJECTION",
    "SELECT_EXACTLY_ONE_OperationFirstUnenteredRuleRowV12_BY_LABEL_AND_SELECTED_STATUS",
    "FOR_CURRENT_FIRST_FAILURE_PREDICATE_COPY_THE_NONNULL_REPLAYED_PREDICATE_ID_WITHOUT_TRANSLATION",
    "MATERIALIZE_FirstUnenteredV12_AND_RECURSIVELY_VALIDATE"
  ],
  "terminal_operation_rule" => "B04_PASS_FAIL_OR_INCOMPLETE_ALL_RETURN_present_false_BECAUSE_NO_LATER_OPERATION_EXISTS;THE_CURRENT_BODY_STILL_RETAINS_ITS_OWN_first_failure",
  "failure_rule" => "FAIL_OR_INCOMPLETE_BEFORE_B04_REQUIRES_first_failure_PRESENT_phase_OPERATION_operation_label_EQUAL_CURRENT_AND_REPLAY_EXACT;MISSING_OR_FALSE_IS_UNAVAILABLE_AND_NEVER_FABRICATES_A_REASON"
}
S.fetch("set_profile_registry_v12")["first_unentered"]["OPERATION_BY_FIXED_LABEL_AND_OUTCOME"] = {
  "source_type_id" => "OperationFirstUnenteredInputV12",
  "rule_table_pointer" => "/exact_record_schema_v12/state_constraint_registry_v12/operation_first_unentered_materialization_v12/rule_rows_exact",
  "rule_table_row_type" => "TUPLE(OperationFirstUnenteredRuleRowV12)",
  "result_type_id" => "FirstUnenteredV12",
  "complete_table_rows_uint" => 15
}

observation["operation_first_unentered_vectors"] = first_unentered_vectors
observation["operation_first_unentered_expected_result_rows"] = first_unentered_vectors.map do |row|
  [row.fetch(0), clone(row.fetch(2))]
end
observation["outer_unentered_evidence_vectors"] = vectors
observation["outer_unentered_evidence_expected_result_rows"] = vectors.map do |row|
  [row.fetch(0), *row[12..17]]
end
observation["outer_unentered_evidence_status_join_rows_exact"] = [
  ["TRUE", "OU_CLEAN_ALL_ABSENT_TRUE", "SS_OUT_UNENTERED_CLEAN", "EXACT_PREDICATE_STATE_EQUALITY"],
  ["FALSE", dirty_ids, "SS_OUT_UNENTERED_MUTATED", "EACH_EXACT_PREDICATE_STATE_EQUALITY"],
  ["NOT_APPLICABLE", na_ids, "SS_OUT_UNENTERED_OBSERVATION_NOT_APPLICABLE_NOT_MUTATION", "EACH_EXACT_PREDICATE_STATE_EQUALITY"],
  ["UNKNOWN", ["OU_UNKNOWN_ENDPOINT_UNKNOWN"], "SS_OUT_UNENTERED_OBSERVATION_UNKNOWN_NOT_MUTATION", "EXACT_PREDICATE_STATE_EQUALITY"]
]
observation["admission_mechanics_vectors"] = admission_vectors
observation["admission_mechanics_expected_result_rows"] = admission_vectors.map do |row|
  [row.fetch(0), *row[3..7]]
end

# Replace symbolic case-name materialization with content-addressed canonical
# typed source fixtures before binding or hashing any mechanics array.
carrier_transformer_path = File.expand_path("base-carriers.rb", __dir__)
eval(File.binread(carrier_transformer_path), binding, carrier_transformer_path)
outer_carrier_transformer_path = File.expand_path("outer-carrier-v2.rb", __dir__)
eval(File.binread(outer_carrier_transformer_path), binding, outer_carrier_transformer_path)
c3_carrier_transformer_path = File.expand_path("c3-carrier-v2.rb", __dir__)
eval(File.binread(c3_carrier_transformer_path), binding, c3_carrier_transformer_path)
custom_projection_carrier_path = File.expand_path("custom-projection-carriers.rb", __dir__)
eval(File.binread(custom_projection_carrier_path), binding, custom_projection_carrier_path)

# The production journal remains blocked at the held START-frame boundary.
# Assess the complete, domain-qualified observation-plus-custom source fixture
# universe only after every nonproduction carrier has been installed.  This
# emits an assessment and typed receipt, never a production journal catalog.
obsolete_c3_schema_id = "ergentics.conformance." + "operation-frame.v12"
raise "obsolete invented C3 operation-frame schema survived final carriers" if
  JSON.generate(J).include?(obsolete_c3_schema_id)
production_boundary_path = File.expand_path(
  "production-journal-boundary-overlay.rb", __dir__
)
eval(File.binread(production_boundary_path), binding, production_boundary_path)
production_boundary_sources = [
  ["OBSERVATION", OBSERVATION_SOURCE_FIXTURES_V12],
  ["CUSTOM", D.fetch("custom_operator_conformance_catalog_v12").fetch("fixtures")]
].flat_map do |domain, rows|
  rows.sort_by { |fixture| fixture.fetch("fixture_id") }.map do |fixture|
    clone(fixture).merge("fixture_id" => "#{domain}/#{fixture.fetch("fixture_id")}")
  end
end
raise "production boundary source fixture ids" unless
  production_boundary_sources.map { |row| row.fetch("fixture_id") }.uniq.length ==
    production_boundary_sources.length
production_boundary_receipt = V12ProductionJournalBoundaryOverlay.install!(
  J, production_boundary_sources
)
raise "production boundary receipt state" unless
  production_boundary_receipt.fetch("state_enum") == "MISSING_TYPED_DEPENDENCY" &&
  production_boundary_receipt.fetch("blocking_dependency_id") ==
    "MISSING_REQUIRED_JOURNAL_START_EVIDENCE_FRAME" &&
  production_boundary_receipt.fetch("assessed_source_fixture_count_uint") ==
    production_boundary_sources.length &&
  production_boundary_receipt.fetch("assessed_source_domains_exact_order") ==
    %w[OBSERVATION CUSTOM] &&
  production_boundary_receipt.fetch("assessed_source_order_rule_enum") ==
    "DOMAIN_DECLARATION_THEN_ASCII_FIXTURE_ID" &&
  production_boundary_receipt.fetch("assessed_source_fixtures_sha256") ==
    json_sha(production_boundary_sources) &&
  production_boundary_receipt.fetch("production_catalog_key_absent_bool") == true &&
  !D.key?(V12ProductionJournalBoundaryOverlay::FORBIDDEN_CATALOG_FIELD)

# Bind every externally retained static-model sequence to its reusable row
# schema and frozen order.  Whole-object hashes remain necessary, but are not
# a substitute for array element typing and order joins.
static_model_array_bindings = [
  [
    "/exact_record_schema_v12/decision_kernel_v12/static_model_journal_algebra_catalog_v12/entries",
    "REF(StaticModelJournalEntryV12)",
    "/exact_record_schema_v12/reusable_objects/StaticModelJournalEntryV12",
    "0" * 64, "ORDER_REGISTRY", "StaticModelJournalCatalogOrderV12", []
  ],
  [
    "/exact_record_schema_v12/decision_kernel_v12/static_model_journal_algebra_catalog_v12/index_rows",
    "TUPLE(StaticModelJournalIndexRowV12)",
    "/exact_record_schema_v12/reusable_objects/StaticModelJournalIndexRowV12",
    "0" * 64, "ORDER_REGISTRY", "StaticModelJournalCatalogOrderV12", []
  ],
  [
    "/exact_record_schema_v12/decision_kernel_v12/static_model_journal_algebra_catalog_v12/predecessor_edges",
    "REF(StaticModelJournalPredecessorEdgeV12)",
    "/exact_record_schema_v12/reusable_objects/StaticModelJournalPredecessorEdgeV12",
    "0" * 64, "ORDER_REGISTRY", "StaticModelJournalEdgeOrderV12", []
  ]
]
static_array_bindings = S.fetch("static_control_conformance_catalog_v12").fetch(
  "array_row_bindings_exact"
)
static_model_array_bindings.each do |row|
  raise "static-model array binding collision #{row.fetch(0)}" if
    static_array_bindings.any? { |existing| existing.fetch(0) == row.fetch(0) }
  static_array_bindings << row
end
raise "static array binding leaf order" unless
  static_array_bindings.map { |row| row.fetch(0).split("/").last } == %w[
    check_rows_exact expected_result_rows entries index_rows predecessor_edges
  ]

shared_boundary_dependency_rows = [
  ["PJ_START_BOUNDARY", "/exact_record_schema_v12/decision_kernel_v12/production_journal_start_boundary_assessment_v12"],
  ["PJ_CATALOG_CLOSURE", "/exact_record_schema_v12/decision_kernel_v12/production_journal_catalog_closure_assessment_v12"],
  ["PJ_BOUNDARY_RECEIPT", "/exact_record_schema_v12/decision_kernel_v12/production_journal_boundary_install_receipt_v12"]
]
shared_static_model_dependency_rows = [
  ["STATIC_MODEL_JOURNAL_CATALOG", "/exact_record_schema_v12/decision_kernel_v12/static_model_journal_algebra_catalog_v12"],
  ["STATIC_MODEL_INSTALL_RECEIPT", "/exact_record_schema_v12/decision_kernel_v12/static_model_journal_algebra_install_receipt_v12"],
  ["STATIC_MODEL_SELF_TEST_RECEIPT", "/exact_record_schema_v12/decision_kernel_v12/static_model_journal_algebra_self_test_receipt_v12"]
]
custom_static_route_dependency_rows = [
  ["CUSTOM_STATIC_MODEL_ROUTE_REPLAY", "/exact_record_schema_v12/decision_kernel_v12/custom_operator_static_model_route_replay_v12"],
  ["CUSTOM_PROJECTION_SOURCE_CLOSURE", "/exact_record_schema_v12/decision_kernel_v12/custom_operator_projection_source_closure_assessment_v12"]
]
dependency_additions = {
  "STATIC_CONTROL" => [
    *shared_boundary_dependency_rows,
    shared_static_model_dependency_rows.fetch(0),
    ["STATIC_MODEL_JOURNAL_SCHEMA_DEFINITIONS", "/exact_record_schema_v12/decision_kernel_v12/static_model_journal_algebra_schema_definitions_v12"],
    ["STATIC_MODEL_JOURNAL_ORDER_DEFINITIONS", "/exact_record_schema_v12/decision_kernel_v12/static_model_journal_algebra_order_definitions_v12"],
    *shared_static_model_dependency_rows.drop(1),
    *custom_static_route_dependency_rows
  ],
  "CUSTOM_OPERATOR" => [
    *shared_boundary_dependency_rows,
    *shared_static_model_dependency_rows,
    *custom_static_route_dependency_rows
  ],
  "OBSERVATION_INTEGRITY" => [
    *shared_boundary_dependency_rows,
    *shared_static_model_dependency_rows,
    ["OUTER_UNENTERED_SOURCE_MATERIALIZATION", "/exact_record_schema_v12/state_constraint_registry_v12/outer_unentered_evidence_case_materialization_v12"]
  ]
}
dependency_profiles_for_install = S.fetch("conformance_dependency_profiles_v12")
dependency_additions.each do |family, additions|
  rows = dependency_profiles_for_install.fetch(family).fetch("rows_exact")
  existing_ids = rows.map(&:first)
  existing_pointers = rows.map { |row| row.fetch(1) }
  addition_ids = additions.map(&:first)
  addition_pointers = additions.map { |row| row.fetch(1) }
  raise "dependency addition duplicate ids #{family}" unless
    addition_ids.uniq.length == addition_ids.length
  raise "dependency addition duplicate pointers #{family}" unless
    addition_pointers.uniq.length == addition_pointers.length
  raise "dependency addition id collision #{family}" unless
    (existing_ids & addition_ids).empty?
  raise "dependency addition pointer collision #{family}" unless
    (existing_pointers & addition_pointers).empty?
  additions.each { |_id, pointer| resolve_pointer(J, pointer) }
  rows.concat(clone(additions))
end
observation["source_fixtures"] = OBSERVATION_SOURCE_FIXTURES_V12.sort_by { |row| row.fetch("fixture_id") }
raise "observation source fixture ids" unless observation.fetch("source_fixtures").map { |row| row.fetch("fixture_id") }.uniq.length == observation.fetch("source_fixtures").length
observation["source_fixture_count_uint"] = observation.fetch("source_fixtures").length
observation["source_fixtures_sha256"] = json_sha(observation.fetch("source_fixtures"))

bindings = observation.fetch("array_row_bindings_exact")
bindings << [
  "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/source_fixtures",
  "REF(ObservationConformanceSourceFixtureV12)",
  "/exact_record_schema_v12/reusable_objects/ObservationConformanceSourceFixtureV12",
  "0" * 64, "ORDER_REGISTRY", "ObservationConformanceSourceFixtureIdOrderV12", []
] unless bindings.any? { |row| row[0].end_with?("/source_fixtures") }
bindings << [
  "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/outer_unentered_evidence_vectors",
  "TUPLE(OuterUnenteredEvidenceConformanceVectorV12)",
  "/exact_record_schema_v12/reusable_objects/OuterUnenteredEvidenceConformanceVectorV12",
  "0" * 64, "ORDER_REGISTRY", "OuterUnenteredEvidenceConformanceVectorOrderV12", []
] unless bindings.any? { |row| row[0].end_with?("/outer_unentered_evidence_vectors") }
bindings << [
  "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/outer_unentered_evidence_expected_result_rows",
  "TUPLE(OuterUnenteredEvidenceConformanceExpectedResultRowV12)",
  "/exact_record_schema_v12/reusable_objects/OuterUnenteredEvidenceConformanceExpectedResultRowV12",
  "0" * 64, "LOSSLESS_PROJECTION", nil,
  ["/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/outer_unentered_evidence_vectors"]
] unless bindings.any? { |row| row[0].end_with?("/outer_unentered_evidence_expected_result_rows") }
bindings << [
  "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/operation_first_unentered_vectors",
  "TUPLE(OperationFirstUnenteredConformanceVectorV12)",
  "/exact_record_schema_v12/reusable_objects/OperationFirstUnenteredConformanceVectorV12",
  "0" * 64, "ORDER_REGISTRY", "OperationFirstUnenteredConformanceVectorOrderV12", []
] unless bindings.any? { |row| row[0].end_with?("/operation_first_unentered_vectors") }
bindings << [
  "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/operation_first_unentered_expected_result_rows",
  "TUPLE(OperationFirstUnenteredConformanceExpectedResultRowV12)",
  "/exact_record_schema_v12/reusable_objects/OperationFirstUnenteredConformanceExpectedResultRowV12",
  "0" * 64, "LOSSLESS_PROJECTION", nil,
  ["/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/operation_first_unentered_vectors"]
] unless bindings.any? { |row| row[0].end_with?("/operation_first_unentered_expected_result_rows") }
bindings << [
  "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/admission_mechanics_vectors",
  "TUPLE(AdmissionMechanicsConformanceVectorV12)",
  "/exact_record_schema_v12/reusable_objects/AdmissionMechanicsConformanceVectorV12",
  "0" * 64, "ORDER_REGISTRY", "AdmissionMechanicsConformanceVectorOrderV12", []
] unless bindings.any? { |row| row[0].end_with?("/admission_mechanics_vectors") }
bindings << [
  "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/admission_mechanics_expected_result_rows",
  "TUPLE(AdmissionMechanicsConformanceExpectedResultRowV12)",
  "/exact_record_schema_v12/reusable_objects/AdmissionMechanicsConformanceExpectedResultRowV12",
  "0" * 64, "LOSSLESS_PROJECTION", nil,
  ["/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/admission_mechanics_vectors"]
] unless bindings.any? { |row| row[0].end_with?("/admission_mechanics_expected_result_rows") }

X.fetch("order_registry_v12")["OuterUnenteredEvidenceConformanceVectorOrderV12"] = "EXACT_outer_unentered_evidence_case_materialization_v12.scenario_rows_exact_VECTOR_ID_ORDER_DISTINCT"
X.fetch("order_registry_v12")["OperationFirstUnenteredConformanceVectorOrderV12"] = "EXACT_operation_label_ORDER_T01_B01_B02_B03_B04_THEN_STATUS_ORDER_PASS_FAIL_INCOMPLETE_DISTINCT"
X.fetch("order_registry_v12")["AdmissionMechanicsConformanceVectorOrderV12"] = "EXACT_ADMISSION_ROW22_POSITIVE_THEN8_NEGATIVE_THEN_ADMISSION_SET4_RUNTIME_ADMISSION5_FRAME_SET6_DISTINCT"
X.fetch("order_registry_v12")["ObservationConformanceSourceFixtureIdOrderV12"] = "ASCII_fixture_id_ASCENDING_DISTINCT"

# Two status rows prove that an unavailable or unknown observation is evidence
# incomplete, never mutation.  They differ only at the derived mechanics state.
status_source = observation.fetch("status_selection_vectors").find { |row| row.fetch(0) == "SS_OUT_UNENTERED_CLEAN" }
raise "missing clean unentered status vector" unless status_source
status_additions = [
  ["SS_OUT_UNENTERED_OBSERVATION_NOT_APPLICABLE_NOT_MUTATION", "NOT_APPLICABLE"],
  ["SS_OUT_UNENTERED_OBSERVATION_UNKNOWN_NOT_MUTATION", "UNKNOWN"]
].map do |id, mechanics_state|
  row = clone(status_source)
  row[0] = id
  row.dig(2, "predicate_states")["OUT_UNENTERED_EVIDENCE_CLEAN"] = mechanics_state
  row[3] = %w[
    OUT_CAPTURE_INCOMPLETE OUT_UNENTERED_MUTATED OUT_UNENTERED_CLEAN OUT_SIGNALLED
    OUT_START_ABSENT_MUTATED OUT_START_ABSENT_CLEAN OUT_START_INVALID OUT_ROOT_PARTIAL
    OUT_EVIDENCE_INCOMPLETE
  ]
  row[4] = "OUT_EVIDENCE_INCOMPLETE"
  row[5] = "INCOMPLETE_CONSUMED_EVIDENCE"
  row
end
existing_status_ids = observation.fetch("status_selection_vectors").map(&:first)
status_additions.each { |row| observation.fetch("status_selection_vectors") << row unless existing_status_ids.include?(row.fetch(0)) }

R["StatusDecisionPredicateObservationV12"] = {
  "tuple_fields_exact_order" => ["predicate_id", "state_enum", "error"],
  "tuple_field_types_exact" => ["S", "ENUM(PredicateEvaluationStateV12)", "REF(ErrorV12)"],
  "rule" => "predicate_id_RESOLVES_EXACTLY_ONE_CURRENT_PredicateDefinitionV12_AND_OCCURS_IN_ITS_SCOPE_CATALOG_ORDER;UNKNOWN_REQUIRES_A_TYPED_NONNONE_ErrorV12_WHILE_TRUE_FALSE_AND_NOT_APPLICABLE_REQUIRE_error_NONE"
}
status_vector_schema = R.fetch("StatusSelectionConformanceVectorV12")
record_kind_states = status_vector_schema.fetch("record_kind_states")
R["StatusDecisionPredicateInputV12"] = {
  "keys" => [
    "record_kind_enum", "operation_label_or_null", "predicate_observations", "status_decision_or_null"
  ],
  "field_types_exact" => {
    "record_kind_enum" => "LOCAL_ENUM(record_kind_states)",
    "operation_label_or_null" => "S_OR_NULL",
    "predicate_observations" => "ARRAY(TUPLE(StatusDecisionPredicateObservationV12),7,18,PredicateCatalogOrderV12)",
    "status_decision_or_null" => "REF_OR_NULL(StatusDecisionV12)"
  },
  "record_kind_states" => record_kind_states,
  "full_catalog_count_by_record_kind_exact" => {
    "SYNTAX" => 12, "IMPLEMENTATION" => 9, "READINESS" => 10,
    "LAUNCH_BINDING" => 7, "START" => 11,
    "JOURNAL_R00" => 15, "JOURNAL_OPERATION" => 15, "JOURNAL_TERMINAL" => 15,
    "PREFIX" => 10, "OUTER" => 18, "C5" => 11
  },
  "rule" => "predicate_observations_ARE_THE_COMPLETE_BASE_THEN_AGGREGATE_SCOPE_CATALOG_WITH_EXACT_COUNT_ORDER_DISTINCT_IDS_STATES_AND_ERRORS;EVERY_AGGREGATE_STATE_AND_ERROR_IS_REPLAYED_FROM_THE_BASE_ROWS;operation_label_IS_NONNULL_EXACTLY_FOR_JOURNAL_OPERATION_AND_IS_ONE_OF_THE_FIVE_FROZEN_LABELS;PROJECT_THE_EXACT_StatusSelectionContextV12_FROM_THE_STATUS_CONDITION_UNIVERSE;REPLAY_STATUS_PRIORITY_FROM_THAT_PROJECTION;status_decision_or_null_IS_THE_EXACT_REPLAYED_DECISION_OR_NULL_ONLY_FOR_A_PERMITTED_NO_MATCH;NO_EXPECTED_FAILURE_STATUS_OR_VECTOR_ID_IS_READ"
}
unless status_vector_schema.fetch("tuple_fields_exact_order").include?("decision_predicate_input")
  status_vector_schema.fetch("tuple_fields_exact_order") << "decision_predicate_input"
  status_vector_schema.fetch("tuple_fields_exact_order") << "expected_first_failure"
  status_vector_schema.fetch("tuple_field_types_exact") << "REF(StatusDecisionPredicateInputV12)"
  status_vector_schema.fetch("tuple_field_types_exact") << "REF(FailureV12)"
end
status_vector_schema["rule"] = "record_kind_enum_EQUALS_context.scope_enum_AND_decision_predicate_input.record_kind_enum;PROJECT_context_FROM_THE_FULL_ORDERED_decision_predicate_input.predicate_observations_AND_REQUIRE_DEEP_EQUAL;REPLAY_THE_EXACT_status_rules_v12_ARRAY_IN_ASCENDING_priority_uint;expected_evaluated_rule_ids_exact_order_IS_THE_EXACT_PREFIX_THROUGH_THE_FIRST_MATCH_OR_THE_FULL_ARRAY_WHEN_NO_RULE_MATCHES;expected_selected_rule_id_AND_expected_status_enum_EQUAL_THAT_FIRST_MATCH_OR_ARE_BOTH_NULL;status_decision_or_null_DEEP_EQUALS_THE_MATCHED_REPLAY_OR_IS_NULL_FOR_AN_EXPLICIT_PERMITTED_NO_MATCH;expected_first_failure_IS_DERIVED_ONLY_BY_decision_replay_registry_v12.first_failure_projection_exact_FROM_THE_SAME_FULL_PREDICATE_INPUT_AND_DECISION;NO_MATCH_ALWAYS_FORBIDS_PUBLICATION;NO_VECTOR_ID_COMMENTARY_STATUS_OR_EXPECTED_FAILURE_MAY_SUPPLY_A_PREDICATE_STATE"

status_expected_schema = R.fetch("StatusSelectionConformanceExpectedResultRowV12")
status_expected_schema["tuple_fields_exact_order"] = [
  "vector_id", "expected_evaluated_rule_ids_exact_order", "expected_selected_rule_id",
  "expected_status_enum", "expected_first_failure"
]
status_expected_schema["tuple_field_types_exact"] = [
  "S", "ARRAY(S,1,14,PreserveArgumentOrderV12)", "S_OR_NULL", "S_OR_NULL", "REF(FailureV12)"
]
status_expected_schema["rule"] = "EXACT_LOSSLESS_PROJECTION_OF_StatusSelectionConformanceVectorV12_FIELDS0_3_4_5_7_IN_DECLARATION_ORDER"

status_context_schema = R.fetch("StatusSelectionContextV12")
status_rules = D.fetch("status_rules_v12")
status_rulesets = D.fetch("status_ruleset_registry_v12")
predicate_catalogs = D.fetch("predicate_catalogs_v12")
predicate_definitions = D.fetch("predicate_definitions_v12")
definition_by_id = predicate_definitions.to_h { |definition| [definition.fetch("predicate_id"), definition] }
definition_order = definition_by_id.transform_values { |definition| definition.fetch("failure_order_uint") }
record_bindings = D.fetch("decision_replay_registry_v12").fetch("record_bindings_exact")
binding_by_kind = record_bindings.to_h { |row| [row.fetch(0), row] }
pass_rule_by_kind = D.fetch("decision_replay_registry_v12").fetch("pass_rule_id_by_record_kind_exact").to_h
contradiction_rule_ids = D.fetch("decision_replay_registry_v12").fetch("first_failure_projection_exact").fetch("contradiction_rule_ids_exact")

def status_replay(rules, predicate_states)
  evaluated = []
  selected = nil
  rules.each do |rule|
    evaluated << rule.fetch("rule_id")
    matches = rule.fetch("conditions_all").all? do |condition|
      condition.fetch("allowed_states_exact_order").include?(predicate_states.fetch(condition.fetch("predicate_id")))
    end
    if matches
      selected = rule
      break
    end
  end
  [evaluated, selected&.fetch("rule_id"), selected&.fetch("selected_status_enum")]
end

def aggregate_state(dependencies, full_states)
  values = dependencies.map { |predicate_id| full_states.fetch(predicate_id) }
  return "FALSE" if values.include?("FALSE")
  return "UNKNOWN" if values.include?("UNKNOWN")
  return "NOT_APPLICABLE" if values.include?("NOT_APPLICABLE")
  "TRUE"
end

def recursively_expand_base(predicate_id, aggregate_by_id)
  aggregate = aggregate_by_id[predicate_id]
  return [predicate_id] unless aggregate
  aggregate.fetch("and_dependencies_exact_order").flat_map do |dependency_id|
    recursively_expand_base(dependency_id, aggregate_by_id)
  end.uniq
end

def full_predicate_states_for(record_kind, plain_states, binding_by_kind, predicate_catalogs)
  binding = binding_by_kind.fetch(record_kind)
  catalog = predicate_catalogs.fetch(binding.fetch(1))
  base_ids = catalog.fetch("base_exact_order")
  aggregates = catalog.fetch("aggregates_exact_order")
  aggregate_by_id = aggregates.to_h { |row| [row.fetch("predicate_id"), row] }
  states = base_ids.to_h { |predicate_id| [predicate_id, "TRUE"] }
  direct_base = plain_states.keys & base_ids
  direct_base.each { |predicate_id| states[predicate_id] = plain_states.fetch(predicate_id) }

  protected = direct_base.dup
  aggregates.each do |aggregate|
    next unless plain_states[aggregate.fetch("predicate_id")] == "TRUE"
    protected.concat(recursively_expand_base(aggregate.fetch("predicate_id"), aggregate_by_id))
  end
  protected.uniq!

  aggregates.each do |aggregate|
    predicate_id = aggregate.fetch("predicate_id")
    desired = plain_states[predicate_id]
    next unless desired
    dependencies = recursively_expand_base(predicate_id, aggregate_by_id)
    current = aggregate_state(dependencies, states)
    next if current == desired
    if desired == "TRUE"
      dependencies.each { |dependency_id| states[dependency_id] = "TRUE" }
    elsif desired == "FALSE"
      candidate = dependencies.find { |dependency_id| !protected.include?(dependency_id) }
      raise "cannot materialize false aggregate #{record_kind}:#{predicate_id}" unless candidate
      states[candidate] = "FALSE"
    elsif desired == "UNKNOWN"
      raise "false dominates desired unknown #{record_kind}:#{predicate_id}" if dependencies.any? { |dependency_id| states.fetch(dependency_id) == "FALSE" }
      candidate = dependencies.find { |dependency_id| !protected.include?(dependency_id) }
      raise "cannot materialize unknown aggregate #{record_kind}:#{predicate_id}" unless candidate
      states[candidate] = "UNKNOWN"
    else
      raise "unsupported aggregate state #{desired}"
    end
  end
  aggregates.each do |aggregate|
    states[aggregate.fetch("predicate_id")] = aggregate_state(
      recursively_expand_base(aggregate.fetch("predicate_id"), aggregate_by_id), states
    )
  end
  plain_states.each do |predicate_id, expected_state|
    raise "predicate state projection mismatch #{record_kind}:#{predicate_id}" unless states.fetch(predicate_id) == expected_state
  end
  [base_ids + aggregates.map { |row| row.fetch("predicate_id") }, states, aggregate_by_id]
end

def derive_first_failure(record_kind, selected_rule_id, full_states, operation_label,
                         status_rules, pass_rule_by_kind, contradiction_rule_ids,
                         binding_by_kind, definition_order, aggregate_by_id)
  phase = binding_by_kind.fetch(record_kind).fetch(2)
  if selected_rule_id && contradiction_rule_ids.include?(selected_rule_id)
    rule = status_rules.fetch(record_kind).find { |candidate| candidate.fetch("rule_id") == selected_rule_id }
    candidates = rule.fetch("conditions_all").map { |condition| condition.fetch("predicate_id") }
      .select { |predicate_id| full_states.fetch(predicate_id) == "TRUE" }
    chosen = candidates.min_by { |predicate_id| definition_order.fetch(predicate_id) }
    raise "missing contradiction predicate #{record_kind}" unless chosen
    return failure_present(phase, operation_label, chosen, "TRUE", contradiction: true)
  end

  pass_rule_id = pass_rule_by_kind.fetch(record_kind)
  pass_rule = status_rules.fetch(record_kind).find { |candidate| candidate.fetch("rule_id") == pass_rule_id }
  pass_prerequisites = pass_rule.fetch("conditions_all").flat_map do |condition|
    recursively_expand_base(condition.fetch("predicate_id"), aggregate_by_id)
  end.uniq
  failing = pass_prerequisites.select { |predicate_id| %w[FALSE UNKNOWN].include?(full_states.fetch(predicate_id)) }
    .min_by { |predicate_id| definition_order.fetch(predicate_id) }
  return failure_absent if selected_rule_id == pass_rule_id && failing.nil?
  raise "nonpass without causal failure #{record_kind}:#{selected_rule_id.inspect}" unless failing
  failure_present(phase, operation_label, failing, full_states.fetch(failing))
end

# Correct the preexisting aggregate contradiction before generating any new
# case: C5_INTEGRITY cannot be true when its terminal dependency is false.
c5_nonterminal = observation.fetch("status_selection_vectors").find { |row| row.fetch(0) == "SS_C5_NONTERMINAL_NO_MATCH" }
raise "missing C5 nonterminal case" unless c5_nonterminal
c5_nonterminal.dig(2, "predicate_states")["C5_INTEGRITY"] = "FALSE"

removed_incomplete_ids = %w[
  SS_R00_INCOMPLETE SS_OPERATION_INCOMPLETE SS_TERMINAL_INCOMPLETE SS_PREFIX_INCOMPLETE
]
observation.fetch("status_selection_vectors").reject! { |row| removed_incomplete_ids.include?(row.fetch(0)) }

shared_gate_specs = {
  "JOURNAL_R00" => {
    "gates" => %w[J_FRAME_PREDECESSOR_HASH_VALID J_TIMING_EVIDENCE_COMPLETE J_WATCH_BEFORE_CLEAN J_R00_TOPOLOGY_EXACT_OR_EXACTLY_RECORDED_FAILURE J_WATCH_AFTER_CLEAN J_COUNTERS_FOLD_EXACT],
    "pass_candidate" => "J_R00_SUCCESS_CHAIN", "failure_candidate" => "J_R00_FAILURE_CHAIN"
  },
  "JOURNAL_OPERATION" => {
    "gates" => %w[J_FRAME_PREDECESSOR_HASH_VALID J_TIMING_EVIDENCE_COMPLETE J_WATCH_BEFORE_CLEAN J_OPERATION_PRECONDITION_TRUE J_OPERATION_EVIDENCE_COMPLETE J_WATCH_AFTER_CLEAN J_COUNTERS_FOLD_EXACT],
    "pass_candidate" => "J_OPERATION_SUCCESS", "failure_candidate" => "J_OPERATION_CONTROLLED_FAILURE"
  },
  "JOURNAL_TERMINAL" => {
    "gates" => %w[J_FRAME_PREDECESSOR_HASH_VALID J_TIMING_EVIDENCE_COMPLETE J_WATCH_BEFORE_CLEAN J_TERMINAL_REVALIDATION_PASS J_WATCH_AFTER_CLEAN J_COUNTERS_FOLD_EXACT],
    "pass_candidate" => "J_TERMINAL_SUCCESS_CHAIN", "failure_candidate" => "J_TERMINAL_FAILURE_CHAIN"
  },
  "PREFIX" => {
    "gates" => %w[PX_START_JOINED PX_TIMING_EVIDENCE_COMPLETE PX_JOURNAL_CHAIN_COMPLETE PX_ROOTS_COMPLETE_OR_R00_EXPLAINED PX_CAPTURES_COMPLETE PX_CONFIGURATION_REVALIDATION_PASS PX_COUNTERS_FOLD_EXACT PX_STAGING_CREATED_AND_BODY_CANONICAL],
    "pass_candidate" => "PX_PASS_CANDIDATE", "failure_candidate" => "PX_FAIL_CANDIDATE"
  }
}

gate_vectors = []
shared_gate_specs.each do |record_kind, spec|
  variant = status_context_schema.fetch("predicate_variant_by_scope_exact").fetch(record_kind)
  context_keys = status_context_schema.fetch("predicate_schemas").fetch(variant).fetch("keys")
  spec.fetch("gates").each do |gate_id|
    %w[FALSE UNKNOWN].each do |gate_state|
      states = context_keys.to_h { |predicate_id| [predicate_id, "FALSE"] }
      spec.fetch("gates").each { |predicate_id| states[predicate_id] = "TRUE" }
      states[spec.fetch("pass_candidate")] = "TRUE"
      states[spec.fetch("failure_candidate")] = "FALSE"
      states[gate_id] = gate_state
      replay = status_replay(status_rules.fetch(record_kind), states)
      gate_vectors << [
        "SS_GATE_#{record_kind}_#{gate_id}_#{gate_state}", record_kind,
        {"scope_enum" => record_kind, "predicate_states" => states}, *replay
      ]
    end
  end
end
raise "gate status vectors #{gate_vectors.length}" unless gate_vectors.length == 54
observation.fetch("status_selection_vectors").concat(gate_vectors)

unknown_case_specs = [
  ["SS_SYNTAX_UNKNOWN", "SS_SYNTAX_PASS", {"SYN_EVIDENCE_COMPLETE" => "UNKNOWN", "SYN_ACCEPT" => "UNKNOWN"}],
  ["SS_IMPLEMENTATION_UNKNOWN", "SS_IMPLEMENTATION_PASS", {"IMP_ACCEPT" => "UNKNOWN"}],
  ["SS_READINESS_UNKNOWN", "SS_READINESS_PASS", {"RD_ACCEPT" => "UNKNOWN"}],
  ["SS_LAUNCH_BINDING_UNKNOWN", "SS_LAUNCH_BINDING_PASS", {"LB_ACCEPT" => "UNKNOWN"}],
  ["SS_START_UNKNOWN", "SS_START_ACCEPTED", {"ST_ACCEPT" => "UNKNOWN"}],
  ["SS_C5_UNKNOWN", "SS_C5_TERMINAL_EXIT", {"C5_INTEGRITY" => "UNKNOWN"}]
]
unknown_vectors = unknown_case_specs.map do |vector_id, prototype_id, replacements|
  prototype = observation.fetch("status_selection_vectors").find { |row| row.fetch(0) == prototype_id }
  raise "missing unknown prototype #{prototype_id}" unless prototype
  row = clone(prototype[0..2])
  row[0] = vector_id
  replacements.each { |predicate_id, state| row.dig(2, "predicate_states")[predicate_id] = state }
  [*row, *status_replay(status_rules.fetch(row.fetch(1)), row.dig(2, "predicate_states"))]
end
observation.fetch("status_selection_vectors").concat(unknown_vectors)

# Recompute every replay outcome from the rules, then append the complete
# predicate/error carrier and the exact first-failure projection.
observation.fetch("status_selection_vectors").each do |row|
  raise "unexpected pre-C5 status width #{row.length}" unless row.length == 6
  vector_id, record_kind, context = row[0, 3]
  replay = status_replay(status_rules.fetch(record_kind), context.fetch("predicate_states"))
  unless row[3..5] == replay
    raise "stored status replay mismatch #{vector_id}: stored=#{row[3..5].inspect} actual=#{replay.inspect}"
  end
  catalog_ids, full_states, aggregate_by_id = full_predicate_states_for(
    record_kind, context.fetch("predicate_states"), binding_by_kind, predicate_catalogs
  )
  operation_label = record_kind == "JOURNAL_OPERATION" ? operation_labels.fetch(0) : nil
  observations = catalog_ids.map do |predicate_id|
    state = full_states.fetch(predicate_id)
    [predicate_id, state, state == "UNKNOWN" ? error_unknown(predicate_id) : error_none]
  end
  evaluated, selected_rule_id, selected_status = replay
  status_decision = if selected_rule_id
    ruleset = status_rulesets.fetch(record_kind)
    {
      "ruleset_id" => ruleset.fetch(0),
      "ruleset_complete_json_sha256" => ruleset.fetch(2),
      "selected_rule_id" => selected_rule_id,
      "selected_status_enum" => selected_status,
      "evaluated_rule_ids_exact_order" => clone(evaluated)
    }
  end
  first_failure = derive_first_failure(
    record_kind, selected_rule_id, full_states, operation_label,
    status_rules, pass_rule_by_kind, contradiction_rule_ids,
    binding_by_kind, definition_order, aggregate_by_id
  )
  input = {
    "record_kind_enum" => record_kind,
    "operation_label_or_null" => operation_label,
    "predicate_observations" => observations,
    "status_decision_or_null" => status_decision
  }
  row << input
  row << first_failure
end

observation["status_selection_expected_result_rows"] = observation.fetch("status_selection_vectors").map do |row|
  [row.fetch(0), clone(row.fetch(3)), row.fetch(4), row.fetch(5), clone(row.fetch(7))]
end

first_failure_projection = D.fetch("decision_replay_registry_v12").fetch("first_failure_projection_exact")
first_failure_projection["permitted_no_match_rule"] = "FOR_THE_EXPLICITLY_PERMITTED_NO_MATCH_CONTEXTS_status_decision_IS_NULL_AND_PUBLICATION_IS_FORBIDDEN_BUT_first_failure_REMAINS_A_DIAGNOSTIC_EXACT_MINIMUM_failure_order_uint_FALSE_OR_UNKNOWN_EXPANDED_PASS_PREREQUISITE_WITH_THE_SAME_PHASE_OPERATION_LABEL_CLASSIFICATION_AND_ERROR_RULE;NO_MATCH_WITHOUT_SUCH_A_CAUSAL_PREREQUISITE_IS_INVALID"

observation.fetch("coverage_exact")["outer_unentered_evidence_vector_ids_exact_order"] = vectors.map(&:first)
observation.fetch("coverage_exact")["outer_unentered_evidence_required_axes_exact"] = [
  "ONE_CLEAN_TRUE", "NINE_DEFINITIVE_DIRTY_FALSE_WITH_DEPENDENT_JOURNAL_FRAME_OPERATION_JOIN",
  "TEN_OBSERVATION_FAILURE_NOT_APPLICABLE", "ENDPOINT_FALSE_NOT_APPLICABLE", "ENDPOINT_UNKNOWN_PROPAGATED_UNKNOWN"
]
observation.fetch("coverage_exact")["operation_prefix_clean_suffix_counts_exact"] = [0, 1, 2, 3, 4, 5]
observation.fetch("coverage_exact")["operation_first_unentered_vector_ids_exact_order"] = first_unentered_vectors.map(&:first)
observation.fetch("coverage_exact")["operation_first_unentered_complete_cross_product"] = "FIVE_FIXED_OPERATION_LABELS_X_THREE_SELECTED_STATUSES_EXACT15"
observation.fetch("coverage_exact")["admission_mechanics_vector_ids_exact_order"] = admission_vectors.map(&:first)
observation.fetch("coverage_exact")["admission_mechanics_partition_exact"] = {
  "admission_row_positive_uint" => 22, "admission_row_negative_uint" => 8,
  "admission_set_uint" => 4, "runtime_admission_uint" => 5, "frame_set_uint" => 6
}
status_coverage = observation.fetch("status_selection_coverage_exact")
status_coverage["vector_ids_exact_order"] = observation.fetch("status_selection_vectors").map(&:first)
status_coverage["selected_rule_ids_by_vector_exact_order"] = observation.fetch("status_selection_vectors").map { |row| row.fetch(4) }
status_coverage["evaluated_rule_ids_by_vector_exact_order"] = observation.fetch("status_selection_vectors").map { |row| clone(row.fetch(3)) }
status_coverage["expected_first_failure_by_vector_exact_order"] = observation.fetch("status_selection_vectors").map { |row| clone(row.fetch(7)) }
status_coverage["no_match_vector_ids_exact_order"] = observation.fetch("status_selection_vectors").select do |row|
  row.fetch(4).nil?
end.map(&:first)
raise "status no-match coverage" unless status_coverage.fetch("no_match_vector_ids_exact_order").length == 5
status_coverage["outer_unentered_mechanics_join_vector_ids_exact_order"] = [
  "SS_OUT_UNENTERED_CLEAN", "SS_OUT_UNENTERED_MUTATED", *status_additions.map(&:first)
]
status_coverage["unknown_is_not_mutation_vector_ids_exact_order"] = [
  "SS_OUT_START_ABSENT_NAMESPACE_UNKNOWN_NOT_MUTATION",
  "SS_OUT_UNENTERED_OBSERVATION_UNKNOWN_NOT_MUTATION"
]
status_coverage["not_applicable_is_not_mutation_vector_id"] = "SS_OUT_UNENTERED_OBSERVATION_NOT_APPLICABLE_NOT_MUTATION"
status_coverage["removed_single_incomplete_examples_exact"] = removed_incomplete_ids
status_coverage["shared_gate_matrix_exact"] = shared_gate_specs.transform_values do |spec|
  {
    "gates_exact_order" => spec.fetch("gates"),
    "states_exact" => %w[FALSE UNKNOWN],
    "pass_candidate_state" => "TRUE", "failure_candidate_state" => "FALSE",
    "vector_count_uint" => spec.fetch("gates").length * 2
  }
end
status_coverage["shared_gate_vector_ids_exact_order"] = gate_vectors.map(&:first)
status_coverage["unknown_scope_vector_ids_exact_order"] = unknown_vectors.map(&:first)
status_coverage["full_failure_projection_input_required_for_every_vector_bool"] = true

observation["vector_count_uint"] = observation.fetch("vectors").length + vectors.length + first_unentered_vectors.length + admission_vectors.length
observation["status_selection_vector_count_uint"] = observation.fetch("status_selection_vectors").length
observation["total_case_count_uint"] = observation.fetch("vector_count_uint") + observation.fetch("status_selection_vector_count_uint")
raise "observation mechanics count" unless observation.fetch("vector_count_uint") == 135
raise "status count" unless observation.fetch("status_selection_vector_count_uint") == 109
raise "observation catalog total" unless observation.fetch("total_case_count_uint") == 244

observation["mechanics_vector_array_keys_exact_order"] = [
  "vectors", "outer_unentered_evidence_vectors", "operation_first_unentered_vectors", "admission_mechanics_vectors"
]
observation["mechanics_expected_result_array_keys_exact_order"] = [
  "expected_result_rows", "outer_unentered_evidence_expected_result_rows",
  "operation_first_unentered_expected_result_rows", "admission_mechanics_expected_result_rows"
]

observation["registry_payload_keys_exact_order"] = [
  "array_row_binding_row_type_descriptor_exact", "array_row_binding_schema_json_pointer",
  "array_row_binding_schema_sha256", "array_row_bindings_exact", "evaluator_bindings_json_pointer",
  "evaluator_bindings_sha256", "dependency_commitment_json_pointer", "dependency_commitment_sha256",
  "operator_semantics_exact", "coverage_exact", "status_selection_coverage_exact",
  "mechanics_vector_array_keys_exact_order", "mechanics_expected_result_array_keys_exact_order",
  "outer_unentered_evidence_status_join_rows_exact", "source_fixture_count_uint", "source_fixtures_sha256",
  "source_fixtures", "vectors", "outer_unentered_evidence_vectors",
  "operation_first_unentered_vectors", "admission_mechanics_vectors",
  "status_selection_vectors"
]
observation["digest_rule"] = "DERIVE_array_row_bindings_exact_COUNT_AND_REQUIRE_EXACTLY11_SCHEMA_VALID_ORDER_JOINED_BINDINGS_BEFORE_REPLAY_OR_DIGEST;source_fixtures_ARE_STRICT_CANONICAL_CONTENT_ADDRESSED_TYPED_INPUT_AUTHORITY;vectors_sha256_COMMITS_THE_CANONICAL_ORDERED_OBJECT_FROM_mechanics_vector_array_keys_exact_order;expected_result_rows_sha256_COMMITS_THE_CANONICAL_ORDERED_OBJECT_FROM_mechanics_expected_result_array_keys_exact_order;STATUS_SELECTION_VECTORS_AND_RESULTS_REMAIN_SEPARATELY_HASHED;EVERY_EXPECTED_ARRAY_IS_AN_EXACT_LOSSLESS_PROJECTION;FULL_OPERATION_FrameReferenceV12_StatusDecisionPredicateInputV12_AND_FailureV12_VALUES_ARE_HASHED_WITHOUT_SUMMARY_SUBSTITUTION;REGISTRY_HASH_IS_THE_COMPACT_OBJECT_OF_registry_payload_keys_exact_order;THE_DEPENDENCY_AND_EVALUATOR_HASH_JOINS_PRECEDE_REPLAY;BOTH_EVALUATORS_RETURN_IDENTICAL_MECHANICS_UNENTERED_ADMISSION_STATUS_AND_FAILURE_ROWS;NO_LF"

# Executable structural join preventing any custom projection from naming an
# input its binding profile cannot supply.  This is the exact invariant whose
# absence allowed R00_FAILURE_BINDINGS to omit ROOT_ABSENCE and ROOT_CONTROL.
static_catalog = S.fetch("static_control_conformance_catalog_v12")
static_catalog.fetch("operator_semantics_exact").transform_values! do |value|
  value.is_a?(String) ? value.gsub("EXACT50_observation_integrity_MECHANICS_ROWS", "EXACT53_observation_integrity_MECHANICS_ROWS") : value
end
observation.fetch("operator_semantics_exact").transform_values! do |value|
  value.is_a?(String) ? value.gsub("THREE_FROZEN_NO_MATCH", "FIVE_FROZEN_NO_MATCH") : value
end
static_catalog.fetch("operator_semantics_exact")["CUSTOM_OPERATOR_BINDING_PROJECTION_CLOSURE"] = "FOR_EACH_custom_operator_definitions_v12_ROW_RESOLVE_EXACTLY_ONE_BINDING_PROFILE_AND_INPUT_PROJECTION_PROGRAM;DERIVE_EVERY_DIRECT_SOURCE_ID_FROM_EACH_FIELD_ROW;WHEN_SOURCE_ID_IS_R00_BINDING_SET_EXPAND_EXACTLY_topology_conjunct_binding_ids_exact_AND_UNION_DIRECT_ROWS_AND_FIRST_UNENTERED;REQUIRE_THE_DUPLICATE_FREE_CONSUMED_BINDING_ID_SET_DEEP_EQUAL_THE_PROFILE_BINDING_ID_SET_WITH_NO_MISSING_OR_UNCONSUMED_EXTRA;R00_TOPOLOGY_BINDINGS_AND_R00_FAILURE_BINDINGS_MUST_BOTH_DEEP_EQUAL_ORDERED_[ROWS_ROOT_ABSENCE_ROOT_SNAPSHOTS_JOURNAL_SNAPSHOT_FIRST_UNENTERED_ROOT_CONTROL];RESOLVE_JOURNAL_R00_THROUGH_THE_EXPLICIT_RECORD_KIND_TO_EVIDENCE_SCOPE_ALIAS_JOURNAL;TYPECHECK_EVERY_SELF_POINTER_AGAINST_THE_R00_BODY_SCHEMA_AND_CONTROL_/roots_AGAINST_THE_HELD_CONTROL_OBJECT;REQUIRE_EVERY_DESTINATION_KEY_WRITTEN_ONCE_AND_EVERY_PROJECTED_OUTPUT_TYPE_DEEP_EQUAL_R00OperatorInputV12;APPLY_THE_SAME_SOURCE_TYPE_OUTPUT_BIJECTION_TO_ALL_CUSTOM_PROGRAMS;MISSING_AMBIGUOUS_DANGLING_DUPLICATE_EXTRA_OR_TYPE_MISMATCH_IS_FALSE"
unless static_catalog.fetch("check_rows_exact").any? { |row| row.fetch(1) == "SC61_CUSTOM_OPERATOR_BINDING_PROJECTION_CLOSURE" }
  static_catalog.fetch("check_rows_exact") << [
    static_catalog.fetch("check_rows_exact").length,
    "SC61_CUSTOM_OPERATOR_BINDING_PROJECTION_CLOSURE",
    "CUSTOM_OPERATOR_BINDING_PROJECTION_CLOSURE",
    "/exact_record_schema_v12/decision_kernel_v12/custom_operator_input_projection_registry_v12",
    true
  ]
end
static_catalog["expected_result_rows"] = static_catalog.fetch("check_rows_exact").map do |row|
  [row.fetch(0), row.fetch(1), row.fetch(4), nil]
end
static_catalog["check_count_uint"] = static_catalog.fetch("check_rows_exact").length
raise "static count" unless static_catalog.fetch("check_count_uint") == 61
X.fetch("order_registry_v12")["StaticControlConformanceOrdinalOrderV12"] = "TUPLE_INDEX0_CONTIGUOUS0_THROUGH60_DISTINCT_AND_TUPLE_INDEX1_DISTINCT"

primitive_catalog = S.fetch("primitive_wrapper_conformance_v12")
custom_catalog = D.fetch("custom_operator_conformance_catalog_v12")
final_counts = {
  "static" => static_catalog.fetch("check_count_uint"),
  "primitive" => primitive_catalog.fetch("vector_count_uint"),
  "custom" => custom_catalog.fetch("vector_count_uint"),
  "timing" => timing.fetch("vector_count_uint"),
  "observation" => observation.fetch("vector_count_uint"),
  "status" => observation.fetch("status_selection_vector_count_uint")
}
raise "final family counts #{final_counts.inspect}" unless final_counts == {
  "static" => 61, "primitive" => 32, "custom" => 259,
  "timing" => 88, "observation" => 135, "status" => 109
}
final_total = final_counts.values.sum
raise "final total #{final_total}" unless final_total == 684

static_catalog["digest_rule"] = "MANIFEST_HASH_IS_UTF8_JSON.generate_COMPACT_OBJECT_OF_EXACT_manifest_payload_keys_exact_order_VALUES_WITH_NO_LF_AND_NEVER_INCLUDES_STORED_DIGESTS_OR_EXPECTED_ROWS;THE_MANIFEST_COMMITS_THE_EXACT_ARRAY_ROW_BINDINGS_CANONICAL_EVALUATOR_BINDING_POINTER_PLUS_RECOMPUTED_HASH_AND_STATIC_CONTROL_DEPENDENCY_POINTER_PLUS_RECOMPUTED_COMPLETE_OBJECT_HASH;EXPECTED_ROWS_HASH_IS_COMPACT_CANONICAL_expected_result_rows;ALL_DEPENDENCIES_AND_ROWS_SCHEMA_VALIDATE_AND_ORDER_JOIN_BEFORE_DIGEST;CHECK_ORDINALS_CONTIGUOUS0_THROUGH60_IDS_AND_OPERATORS_DISTINCT_EXPECTED_TRUE;BOTH_EVALUATORS_BIND_THE_SINGLE_CANONICAL_TABLE_AND_RETURN_IDENTICAL_RESULT_ROWS"
static_semantics = static_catalog.fetch("operator_semantics_exact")
static_semantics["CONTROL_BOOTSTRAP_NO_GET_CLOSURE"] = "SCOPE_DISPATCH_IS_TOTAL;SYNTAX_AND_IMPLEMENTATION_DIRECTLY_RECOMPUTE_ALL684_STATIC61_PRIMITIVE32_CUSTOM259_TIMING88_OBSERVATION135_STATUS109_FROM_RAW_HELD_BYTES;READINESS_REQUIRES_BOTH_SOURCE_EVALUATORS_AND_INLINE_RECEIPT;LATER_SCOPES_REPLAY_BOUND_READINESS;NO_BRANCH_EXPOSES_CONTROL_GET_FIRST"
static_semantics["STATUS_PASS_FAIL_INCOMPLETE_SEPARATION"] = "RESOLVE_HASH_JOIN_SCHEMA_VALIDATE_AND_DUAL_EVALUATOR_REPLAY_ALL109_TYPED_status_selection_vectors_AND_THEIR_FULL_StatusDecisionPredicateInputV12_AND_FailureV12_VALUES_AGAINST_THE_EXACT11_status_rules_v12_ARRAYS;THE_SCOPE_FIXED_CONTEXT_KEY_UNIVERSE_DEEP_EQUALS_EACH_RULESET_CONDITION_PREDICATE_UNIVERSE_IN_PREDICATE_CATALOG_ORDER;ALL42_RULE_IDS_ARE_SELECTED_AT_LEAST_ONCE;EACH_EVALUATED_RULE_ID_ARRAY_IS_THE_EXACT_PRIORITY_PREFIX_THROUGH_FIRST_MATCH;THE54_SHARED_GATE_FALSE_OR_UNKNOWN_ROWS_CANNOT_SELECT_PASS_OR_FAIL_AND_NAME_THE_FLIPPED_GATE_AS_FIRST_FAILURE;THE_SIX_UNKNOWN_SCOPE_ROWS_RETAIN_EXACT_TYPED_ERRORS;ONLY_THE_FIVE_EXPLICIT_UNCONSUMED_OR_UNKNOWN_SYNTAX_START_AND_C5_CONTEXTS_SELECT_NO_RULE_AND_ALL_FORBID_PUBLICATION;NO_UNKNOWN_OR_UNBOUND_VALUE_CAN_SELECT_PASS_OR_FAIL"

wrapper_semantics = S.fetch("wrapper_invariant_instruction_semantics_exact")
wrapper_semantics["PROFILED_ADMISSION_ROW_FAILURE_PHASE_BICONDITIONAL"] = "MATCH_THE_ACTUAL_TYPED_PARENT_CHAIN_TO_EXACTLY_ONE_admission_row_context_dispatch_v12_ROW_AND_RESOLVE_ITS_EXACT_GLOBAL_admission_member_registry_v12_MEMBER;REQUIRE_role_path_policy_caps_AND_EXPECTED_KIND_MATCH_IN_EVERY_PHASE;REQUIRE_kind_enum_EQUALS_EVERY_AVAILABLE_VNODE_type_enum;PRESENT_ADMITTED_REQUIRES_NULL_FAILURE_PHASE_FULL_TYPED_METADATA_TARGET_INVENTORY_POLICY_SUCCESS_AND_JOINED_EQUAL_IDENTITIES;ABSENT_OR_PRELSTAT_FAILURE_HAS_NO_IDENTITY;AFTER_THE_FIRST_IDENTITY_EXISTS_AdmissionRow.identity_or_null_IS_ALWAYS_THE_EARLIEST_PRE_OR_HELD_BEFORE_VNODE;JOINED_REQUIRES_ALL_AVAILABLE_VNODES_EQUAL;HELD_DRIFT_REQUIRES_THE_RETAINED_LATER_POST_OR_HELD_AFTER_VNODE_NOT_EQUAL_THE_EARLIEST_AND_FORBIDS_REBASELINE;NAMED_MISMATCH_REQUIRES_STABLE_HELD_BEFORE_EQUALS_HELD_AFTER_AND_RETAINED_named_after_NOT_EQUAL_THE_HELD_VNODE;NAMED_FSTATAT_FAILED_REQUIRES_STABLE_HELD_BEFORE_EQUALS_HELD_AFTER_AND_NULL_named_after;EVERY_NONPRESENT_ROW_SELECTS_EXACTLY_ONE_admission_failure_phase_rows_exact_ROW_AND_PRESERVES_ITS_PHASE_SPECIFIC_PAYLOAD_AND_EXACT_TYPED_ERROR_JOINS;RawBytesV12_TARGET_BYTES_MUST_NOT_EXCEED_THE_PROFILE_READLINK_CAP_AND_inventory_IS_NONNULL_ONLY_WHEN_THE_SELECTED_DIRECTORY_POLICY_REQUIRES_IT;ANY_MISSING_AMBIGUOUS_CROSS_CARRIER_CONTRADICTORY_EQUALIZED_DRIFT_UNBOUNDED_TARGET_INAPPLICABLE_INVENTORY_OR_ERROR_MISMATCH_INVALIDATES_THE_ROW"
wrapper_semantics["PROFILED_ADMISSION_SET_BICONDITIONAL"] = "RESOLVE_CONTEXT_PROFILE_ONCE_TO_ONE_EXACT_FIXED_SLICE;EXECUTE_THE_COMPLETE_MEMBER_CENSUS_IN_ORDINAL_ORDER_WITHOUT_SHORT_CIRCUIT_AFTER_ANY_FAILURE;RETAIN_EVERY_SCHEMA_VALID_SUCCESS_OR_FAILURE_AdmissionRowV12_AND_ONLY_AFTER_THE_LAST_EXPECTED_MEMBER_FREEZE_THE_IMMUTABLE_rows_ARRAY;expected_count_EQUALS_PROFILE_COUNT;observed_count_EQUALS_rows_LENGTH;LOCAL_ORDINAL_ROLE_PATH_POLICY_CAP_AND_EXPECTED_KIND_JOIN_EACH_PROFILE_MEMBER;EVERY_ROW_RECURSIVELY_VALIDATES_PROFILED_ADMISSION_ROW_FAILURE_PHASE_BICONDITIONAL;complete_bool_IFF_THE_FULL_COUNT_CONTIGUOUS_ROWS_ALL_PRESENT_ADMITTED_POLICY_SUCCESS_AND_SET_error_NONE;A_SHORT_PREFIX_HOLE_DUPLICATE_REORDER_UNOBSERVED_SUFFIX_OR_POSTFAIL_REBASELINE_INVALIDATES_COMPLETION"
wrapper_semantics["CONTROL_CONFORMANCE_RECEIPT_EXACT"] = "CONTROL_FRAME_HASH_EQUALS_THE_EXACT_HELD_COMPLETE_V12_FRAME;STATIC_MANIFEST_AND_EXPECTED_ROW_DIGESTS_PLUS_ALL_THREE_PRIMITIVE_ALL_FOUR_CUSTOM_ALL_FOUR_TIMING_AND_ALL_FIVE_OBSERVATION_AND_STATUS_DIGEST_FIELDS_EQUAL_RECOMPUTED_FROZEN_CATALOG_BYTES_WITHOUT_TRUSTING_STORED_DIGESTS;RESOLVE_THE_SINGLE_conformance_evaluator_bindings_v12_TABLE_VALIDATE_ITS_ROW_SCHEMA_POINTER_HASH_ORDER_SOURCE_ROLE_PROJECTION_AND_REQUIRED_IMPLEMENTATION_CHECKPOINT_EVIDENCE_SOURCE;evaluators_LENGTH2_AND_EACH_ROW_AT_THE_SAME_ORDINAL_HAS_THE_EXACT_BOUND_evaluator_id_AND_source_sha256_FROM_ITS_ROW_SOURCE_POINTER;EACH_REPORTS_STATIC_COUNT61_PRIMITIVE_COUNT32_CUSTOM_COUNT259_TIMING_COUNT88_OBSERVATION_COUNT135_STATUS_COUNT109_TOTAL684_PASSED684_AND_EXACT_STRUCTURAL_PRIMITIVE_CUSTOM_TIMING_OBSERVATION_STATUS_PLUS_CANONICAL_SIX_FAMILY_COMBINED_RESULT_DIGESTS;THE_TWO_EVALUATOR_RESULTS_MATCH_EACH_OTHER_EXCEPT_THE_TWO_FIELDS_EXPLICITLY_BOUND_BY_THEIR_DISTINCT_TABLE_ROWS;complete_bool_IFF_ALL_EXACT_AND_error_NONE"

control_dispatch = D.fetch("evidence_source_resolver_v12").fetch("control_frame_scope_dispatch_exact")
direct_recompute = "DIRECT_RAW_HELD_STATIC61_PRIMITIVE32_CUSTOM259_TIMING88_OBSERVATION135_STATUS109_RECOMPUTE_NO_INLINE_RECEIPT"
control_dispatch["SYNTAX"] = direct_recompute
control_dispatch["IMPLEMENTATION"] = direct_recompute
D.fetch("evidence_source_resolver_v12").fetch("schema_validation_by_kind_exact")["CONTROL_FRAME"] = "BOOTSTRAP_DIRECTLY_FROM_THE_EXACT_HELD_FULL_V12_CONTROL_RAW_BYTES_WITHOUT_A_CONTROL_EVIDENCE_GET;STRICT_UTF8_PARSE_WITH_DUPLICATE_KEYS_REJECTED;REQUIRE_THE_PROFILE_schema_json_pointer_exact_TO_RESOLVE_ITS_exact_record_schema_v12_REGISTRY_ANCHOR;REQUIRE_HELD_BYTES_PATH_VNODE_LENGTH_SHA256_GIT_BLOB_AND_CONTROL_COMMIT_TREE_JOINS;SELECT_EXACTLY_ONE_control_frame_scope_dispatch_exact_ROW_BY_EVIDENCE_SCOPE;SYNTAX_AND_IMPLEMENTATION_DIRECTLY_RECOMPUTE_STATIC61_PRIMITIVE32_CUSTOM259_TIMING88_OBSERVATION135_STATUS109_WITH_NO_RECEIPT_DEPENDENCY;READINESS_ALSO_REQUIRES_ITS_CURRENT_BODY_/control_conformance_receipt_ControlConformanceReceiptV12_WITH_TWO_IDENTICAL_ALL684_PASS_RESULTS;LATER_SCOPES_REQUIRE_THE_EXACT_BOUND_READINESS_/body/control_conformance_receipt_REPLAY;ONLY_THEN_EXPOSE_ANY_CONTROL_POINTER;DO_NOT_VALIDATE_THE_WHOLE_DOCUMENT_AS_IF_THE_REGISTRY_ANCHOR_WERE_ITS_SCHEMA"

R.fetch("ConformanceEvaluatorResultV12")["rule"] = "evaluator_id_AND_source_sha256_ARE_SELECTED_ONLY_BY_THE_SAME_ORDINAL_conformance_evaluator_bindings_v12_ROW_AND_ITS_BOUND_IMPLEMENTATION_CHECKPOINT_SOURCE_POINTER;structural_check_count_uint_EQUALS61;primitive_wrapper_vector_count_uint_EQUALS32;custom_vector_count_uint_EQUALS259;timing_vector_count_uint_EQUALS88;observation_integrity_vector_count_uint_EQUALS135;status_selection_vector_count_uint_EQUALS109;total_case_count_uint_EQUALS684;passed_count_uint_EQUALS684_ONLY_WHEN_ALL_SIX_FAMILY_RESULT_DOMAINS_REPLAY_EXACTLY;SEVEN_RESULT_DIGESTS_HASH_CANONICAL_STRUCTURAL_ROWS_PRIMITIVE_WRAPPER_ROWS_CUSTOM_ROWS_TIMING_ROWS_OBSERVATION_INTEGRITY_ROWS_STATUS_SELECTION_ROWS_AND_CANONICAL_SIX_FAMILY_COMBINATION_RESPECTIVELY"
R.fetch("ControlConformanceReceiptV12")["rule"] = "INLINE_READINESS_VALUE_ONLY_NO_STANDALONE_RECEIPT_PATH_OR_PUBLICATION;BOOTSTRAP_FROM_RAW_HELD_CONTROL_BYTES_WITH_DUPLICATE_KEYS_REJECTED_AND_NO_CONTROL_EVIDENCE_GET;TWO_STRUCTURALLY_INDEPENDENT_EVALUATORS_EMBEDDED_SEPARATELY_IN_OUTER_OBSERVER_AND_CONTROLLER_SOURCES_REPLAY_STATIC61_PRIMITIVE32_CUSTOM259_TIMING88_OBSERVATION135_STATUS109;THE_SINGLE_DIGEST_BOUND_conformance_evaluator_bindings_v12_TABLE_BINDS_ORDINAL_ID_SOURCE_ROLE_IMPLEMENTATION_CHECKPOINT_SOURCE_INSTANCE_AND_EXACT_POSTCOMMIT_HASH_POINTER_FOR_EACH_RECEIPT_ROW;BOTH_MATCH_THEIR_RESOLVED_SOURCE_HASHES_COUNTS_ALL684_PASS_SEPARATE_RESULT_DIGESTS_AND_IDENTICAL_CANONICAL_SIX_FAMILY_COMBINED_RESULT_DIGEST;ONLY_AFTER_THIS_RECEIPT_VALIDATES_MAY_CONTROL_EVIDENCE_POINTERS_BE_EXPOSED;NO_LIVE_AUTHORITY_PRODUCT_COMPILER_OR_CHILD_EXECUTION"

publication_gate_rows = X.fetch("publication_conformance_gate_by_record_kind_exact")
publication_gate_rows.each do |row|
  if %w[SYNTAX IMPLEMENTATION].include?(row.fetch(0))
    row[1] = "DIRECT_RAW_CONTROL_STATIC61_PRIMITIVE32_CUSTOM259_TIMING88_OBSERVATION135_STATUS109_RECOMPUTE_NO_RECEIPT"
  end
end
X["publication_conformance_gate_rule"] = "SYNTAX_AND_IMPLEMENTATION_DIRECTLY_RECOMPUTE_THE_EXACT_static_control_conformance_catalog_v12_primitive_wrapper_conformance_v12_custom_operator_conformance_catalog_v12_timing_conformance_catalog_v12_AND_observation_integrity_conformance_catalog_v12_DIGESTS_CASE_SET_COVERAGE_AND_EVERY_EXPECTED_RESULT_ROW_FROM_RAW_HELD_CONTROL_WITHOUT_TRUSTING_STORED_DIGESTS_OR_REQUIRING_A_FUTURE_RECEIPT;THE_PRIMITIVE_CATALOG_IS_AN_EXPLICIT_INDEPENDENT_REPLAY_AND_CANNOT_BE_ABSORBED_BY_STATIC_OR_CUSTOM;READINESS_RECOMPUTES_THE_SAME_FIVE_CATALOG_DOMAINS_AND_REQUIRES_ControlConformanceReceiptV12_DEEP_EQUAL_ALL_FIVE_CATALOG_CONSTANT_SETS_TWO_POSTCOMMIT_SOURCE_HASHES_AND_BOTH_INDEPENDENT_EVALUATOR_RESULTS;LATER_RECORDS_REPLAY_THE_EXACT_BOUND_READINESS_FRAME_AND_RD_OPERATOR_CONFORMANCE_PASS_SOURCE_PREDICATE;FALSE_UNKNOWN_MISSING_OR_ANY_FailureV12_MISMATCH_FORBIDS_PUBLICATION"

# ---- Acyclic exact-byte reseal ------------------------------------------------
# First close all rule and schema joins, then primitive, dependencies, the
# custom/timing/observation catalogs, and finally the static manifest.
status_rulesets.each do |key, tuple|
  next unless status_rules.key?(key)
  tuple[2] = json_sha(status_rules.fetch(key))
end
record_kind_states.each do |record_kind|
  tuple = status_rulesets.fetch(record_kind)
  raise "status ruleset hash #{record_kind}" unless tuple.fetch(2) == json_sha(status_rules.fetch(record_kind))
end

# Status decisions embedded earlier use the now-verified registry hash.
first_unentered_vectors.each do |row|
  row.fetch(1).fetch("status_decision")["ruleset_complete_json_sha256"] = status_rulesets.fetch("JOURNAL_OPERATION").fetch(2)
end
observation.fetch("status_selection_vectors").each do |row|
  decision = row.fetch(6).fetch("status_decision_or_null")
  next unless decision
  decision["ruleset_complete_json_sha256"] = status_rulesets.fetch(row.fetch(1)).fetch(2)
end

binding_row_schema_hash = json_sha(resolve_pointer(J, "/exact_record_schema_v12/reusable_objects/ConformanceCatalogArrayBindingV12"))

observation_binding_order = %w[
  source_fixtures
  vectors expected_result_rows
  outer_unentered_evidence_vectors outer_unentered_evidence_expected_result_rows
  operation_first_unentered_vectors operation_first_unentered_expected_result_rows
  admission_mechanics_vectors admission_mechanics_expected_result_rows
  status_selection_vectors status_selection_expected_result_rows
]
bindings.sort_by! do |row|
  leaf = row.fetch(0).split("/").last
  observation_binding_order.index(leaf) || raise("unknown observation binding #{leaf}")
end
raise "observation binding order" unless bindings.map { |row| row.fetch(0).split("/").last } == observation_binding_order

catalog_binding_groups = [
  [static_catalog, "array_row_binding_schema_json_pointer", "array_row_binding_schema_sha256", "array_row_bindings_exact"],
  [observation, "array_row_binding_schema_json_pointer", "array_row_binding_schema_sha256", "array_row_bindings_exact"],
  [D.fetch("custom_operator_conformance_array_bindings_v12"), "binding_row_schema_json_pointer", "binding_row_schema_sha256", "rows_exact"],
  [S.fetch("timing_conformance_array_bindings_v12"), "binding_row_schema_json_pointer", "binding_row_schema_sha256", "rows_exact"]
]
catalog_binding_groups.each do |holder, schema_pointer_key, schema_hash_key, rows_key|
  holder[schema_hash_key] = json_sha(resolve_pointer(J, holder.fetch(schema_pointer_key)))
  raise "binding-row schema mismatch" unless holder.fetch(schema_hash_key) == binding_row_schema_hash
  holder.fetch(rows_key).each do |row|
    row[3] = json_sha(resolve_pointer(J, row.fetch(2)))
  end
end

evaluator_bindings = D.fetch("conformance_evaluator_bindings_v12")
evaluator_bindings["binding_row_schema_sha256"] = json_sha(
  resolve_pointer(J, evaluator_bindings.fetch("binding_row_schema_json_pointer"))
)
evaluator_bindings_hash = json_sha(evaluator_bindings)
static_catalog["evaluator_bindings_sha256"] = evaluator_bindings_hash
observation["evaluator_bindings_sha256"] = evaluator_bindings_hash

primitive_catalog["vector_row_schema_sha256"] = json_sha(
  resolve_pointer(J, primitive_catalog.fetch("vector_row_schema_json_pointer"))
)
primitive_catalog["expected_result_row_schema_sha256"] = json_sha(
  resolve_pointer(J, primitive_catalog.fetch("expected_result_row_schema_json_pointer"))
)
primitive_catalog["vector_count_uint"] = primitive_catalog.fetch("vectors").length
raise "primitive expected count" unless primitive_catalog.fetch("expected_result_rows").length == primitive_catalog.fetch("vector_count_uint")
primitive_catalog["vectors_sha256"] = json_sha(primitive_catalog.fetch("vectors"))
primitive_catalog["expected_result_rows_sha256"] = json_sha(primitive_catalog.fetch("expected_result_rows"))
primitive_catalog["catalog_sha256"] = json_sha(
  ordered_object(primitive_catalog, primitive_catalog.fetch("payload_keys_exact_order"))
)

dependency_profiles = S.fetch("conformance_dependency_profiles_v12")
dependency_commitments = S.fetch("conformance_dependency_commitments_v12")
dependency_profiles.each do |family, profile|
  commitment = dependency_commitments.fetch(family)
  commitment["catalog_id"] = profile.fetch("catalog_id")
  commitment["rows_exact"] = profile.fetch("rows_exact").map do |dependency_id, pointer|
    [dependency_id, pointer, json_sha(resolve_pointer(J, pointer))]
  end
  commitment["rows_sha256"] = json_sha(commitment.fetch("rows_exact"))
end
raise "static dependency rows" unless dependency_commitments.fetch("STATIC_CONTROL").fetch("rows_exact").length == 50
raise "custom dependency rows" unless dependency_commitments.fetch("CUSTOM_OPERATOR").fetch("rows_exact").length == 35
raise "timing dependency rows" unless dependency_commitments.fetch("TIMING").fetch("rows_exact").length == 28
raise "observation dependency rows" unless dependency_commitments.fetch("OBSERVATION_INTEGRITY").fetch("rows_exact").length == 54
%w[STATIC_CONTROL OBSERVATION_INTEGRITY].each do |family|
  ids = dependency_commitments.fetch(family).fetch("rows_exact").map(&:first)
  raise "missing outer-start dependency #{family}" unless ids.include?("OUTER_START_BASELINE_DISPATCH")
  raise "missing outer-cut dependency #{family}" unless ids.include?("OUTER_NOT_ATTEMPTED_CUT_PROJECTION")
end
static_catalog["dependency_commitment_sha256"] = json_sha(dependency_commitments.fetch("STATIC_CONTROL"))
D["custom_operator_conformance_dependency_commitment_sha256"] = json_sha(dependency_commitments.fetch("CUSTOM_OPERATOR"))
observation["dependency_commitment_sha256"] = json_sha(dependency_commitments.fetch("OBSERVATION_INTEGRITY"))

custom_catalog["fixture_count_uint"] = custom_catalog.fetch("fixtures").length
custom_catalog["vector_count_uint"] = custom_catalog.fetch("vectors").length
raise "custom expected count" unless custom_catalog.fetch("expected_result_rows").length == 259
raise "custom vector count" unless custom_catalog.fetch("vector_count_uint") == 259
input_schemas = custom_catalog.fetch("input_schema_ids_exact_order").each_with_object({}) do |schema_id, output|
  output[schema_id] = R.fetch(schema_id)
end
custom_registry_payload = custom_catalog.fetch("registry_payload_keys_exact_order").each_with_object({}) do |key, output|
  output[key] = key == "input_schemas_v12" ? input_schemas : D.fetch(key)
end
custom_catalog["registry_sha256"] = json_sha(custom_registry_payload)
custom_catalog["fixtures_sha256"] = json_sha(custom_catalog.fetch("fixtures"))
custom_catalog["vectors_sha256"] = json_sha(custom_catalog.fetch("vectors"))
custom_catalog["expected_result_rows_sha256"] = json_sha(custom_catalog.fetch("expected_result_rows"))

timing["fixture_count_uint"] = timing.fetch("fixtures").length
timing["vector_count_uint"] = timing.fetch("join_vectors").length + timing.fetch("call_order_vectors").length + timing.fetch("failure_cut_vectors").length + timing.fetch("outer_state_vectors").length
raise "timing expected count" unless timing.fetch("expected_result_rows").length == 88
timing_registry_payload = timing.fetch("registry_payload_json_pointers_exact_order").map do |pointer|
  resolve_pointer(J, pointer)
end
timing["registry_sha256"] = json_sha(timing_registry_payload)
timing["fixtures_sha256"] = json_sha(timing.fetch("fixtures"))
timing["vectors_sha256"] = json_sha({
  "join_vectors" => timing.fetch("join_vectors"),
  "call_order_vectors" => timing.fetch("call_order_vectors"),
  "failure_cut_vectors" => timing.fetch("failure_cut_vectors"),
  "outer_state_vectors" => timing.fetch("outer_state_vectors")
})
timing["expected_result_rows_sha256"] = json_sha(timing.fetch("expected_result_rows"))

mechanics_vectors = ordered_object(observation, observation.fetch("mechanics_vector_array_keys_exact_order"))
mechanics_expected = ordered_object(observation, observation.fetch("mechanics_expected_result_array_keys_exact_order"))
observation["vectors_sha256"] = json_sha(mechanics_vectors)
observation["expected_result_rows_sha256"] = json_sha(mechanics_expected)
observation["status_selection_vectors_sha256"] = json_sha(observation.fetch("status_selection_vectors"))
observation["status_selection_expected_result_rows_sha256"] = json_sha(observation.fetch("status_selection_expected_result_rows"))
observation["registry_sha256"] = json_sha(
  ordered_object(observation, observation.fetch("registry_payload_keys_exact_order"))
)

static_catalog["expected_result_rows_sha256"] = json_sha(static_catalog.fetch("expected_result_rows"))
combined_family_order = %w[
  STATIC_CONTROL PRIMITIVE_WRAPPER CUSTOM_OPERATOR TIMING OBSERVATION_INTEGRITY STATUS_SELECTION
]
combined_result_rows = [
  static_catalog.fetch("expected_result_rows"),
  primitive_catalog.fetch("expected_result_rows"),
  custom_catalog.fetch("expected_result_rows"),
  timing.fetch("expected_result_rows"),
  mechanics_expected,
  observation.fetch("status_selection_expected_result_rows")
]
static_catalog["combined_result_family_order_exact"] = combined_family_order
static_catalog["combined_result_rows_sha256"] = json_sha(combined_result_rows)
static_catalog["catalog_case_counts_exact"] = final_counts.merge("total" => final_total)
%w[combined_result_family_order_exact combined_result_rows_sha256 catalog_case_counts_exact].each do |key|
  static_catalog.fetch("manifest_payload_keys_exact_order") << key unless static_catalog.fetch("manifest_payload_keys_exact_order").include?(key)
end
static_catalog["manifest_sha256"] = json_sha(
  ordered_object(static_catalog, static_catalog.fetch("manifest_payload_keys_exact_order"))
)

# Independent stored-hash and projection verification.  This block recomputes
# every value without reading any expected prose or a future receipt.
catalog_binding_groups.each do |holder, schema_pointer_key, schema_hash_key, rows_key|
  raise "binding table schema verification" unless holder.fetch(schema_hash_key) == json_sha(resolve_pointer(J, holder.fetch(schema_pointer_key)))
  holder.fetch(rows_key).each do |row|
    raise "bound row schema verification #{row.fetch(0)}" unless row.fetch(3) == json_sha(resolve_pointer(J, row.fetch(2)))
  end
end
raise "evaluator binding verification" unless evaluator_bindings_hash == json_sha(evaluator_bindings)
dependency_profiles.each do |family, profile|
  commitment = dependency_commitments.fetch(family)
  raise "dependency catalog id #{family}" unless commitment.fetch("catalog_id") == profile.fetch("catalog_id")
  raise "dependency row count #{family}" unless commitment.fetch("rows_exact").length == profile.fetch("rows_exact").length
  commitment.fetch("rows_exact").zip(profile.fetch("rows_exact")).each do |committed, profiled|
    raise "dependency identity #{family}" unless committed[0, 2] == profiled
    raise "dependency digest #{family}:#{committed.fetch(0)}" unless committed.fetch(2) == json_sha(resolve_pointer(J, committed.fetch(1)))
  end
  raise "dependency rows hash #{family}" unless commitment.fetch("rows_sha256") == json_sha(commitment.fetch("rows_exact"))
end
raise "primitive catalog verification" unless primitive_catalog.fetch("catalog_sha256") == json_sha(ordered_object(primitive_catalog, primitive_catalog.fetch("payload_keys_exact_order")))
raise "custom registry verification" unless custom_catalog.fetch("registry_sha256") == json_sha(custom_registry_payload)
raise "timing registry verification" unless timing.fetch("registry_sha256") == json_sha(timing_registry_payload)
raise "observation registry verification" unless observation.fetch("registry_sha256") == json_sha(ordered_object(observation, observation.fetch("registry_payload_keys_exact_order")))
raise "static manifest verification" unless static_catalog.fetch("manifest_sha256") == json_sha(ordered_object(static_catalog, static_catalog.fetch("manifest_payload_keys_exact_order")))
raise "combined result verification" unless static_catalog.fetch("combined_result_rows_sha256") == json_sha(combined_result_rows)
raise "observation mechanics projection count" unless mechanics_expected.values.sum(&:length) == 135
raise "status projection count" unless observation.fetch("status_selection_expected_result_rows").length == 109

if ENV["V12_FINAL_WRITE"] == "1"
  File.binwrite(PATHNAME, JSON.pretty_generate(J) + "\n")
end
