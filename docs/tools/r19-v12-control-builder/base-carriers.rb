# frozen_string_literal: true

# Loaded by finalize-control.rb after all mechanics vectors exist and before the
# exact-byte reseal.  This scratch transformer removes case-name authority:
# every affected mechanics row selects content-addressed canonical typed input.

R["ObservationConformanceSourceFixtureV12"] = {
  "keys" => ["fixture_id", "type_id", "canonical_json_base64", "bytes_uint", "sha256"],
  "field_types_exact" => {
    "fixture_id" => "S", "type_id" => "S", "canonical_json_base64" => "B64",
    "bytes_uint" => "U", "sha256" => "H64"
  },
  "rule" => "STRICT_BASE64_DECODE_LENGTH_SHA256_CANONICAL_JSON_REPARSE_AND_RECURSIVE_DECLARED_type_id_VALIDATION_EXACT;THE_FIXTURE_IS_INPUT_AUTHORITY_AND_EXPECTED_RESULT_ROWS_ARE_FORBIDDEN_DURING_DECODE_OR_EVALUATION"
}

# Directory payload applicability is policy-selected, not kind-selected.  The
# inherited kind matrix required inventory for both directory policies while
# its own cross-constraint forbade inventory for identity-only directories.
directory_kind_matrix = R.fetch("AdmissionRowV12").fetch("kind_matrix_exact").fetch("DIRECTORY")
directory_kind_matrix.delete("required_nonnull")
R.fetch("AdmissionRowV12")["admission_policy_matrix_exact"] = {
  "HELD_REGULAR_CONTENT_COMPLETE" => {"kind_enum" => "REGULAR", "content_or_null_nonnull" => true, "inventory_or_null" => nil, "symlink_target_or_null" => nil},
  "HELD_DIRECTORY_EXACT_IMMEDIATE_INVENTORY" => {"kind_enum" => "DIRECTORY", "inventory_or_null_nonnull" => true, "content_or_null" => nil, "symlink_target_or_null" => nil},
  "HELD_DIRECTORY_IDENTITY_ONLY" => {"kind_enum" => "DIRECTORY", "inventory_or_null" => nil, "content_or_null" => nil, "symlink_target_or_null" => nil},
  "HELD_SYMLINK_TARGET_AND_TARGET_ROLE_JOINED" => {"kind_enum" => "SYMLINK", "symlink_target_or_null_nonnull_only_after_complete_readlink" => true, "content_or_null" => nil, "inventory_or_null" => nil}
}
R.fetch("AdmissionRowV12").fetch("cross_constraints_exact")["inventory_applicability"] = "inventory_NONNULL_IFF_admission_policy_enum_IS_HELD_DIRECTORY_EXACT_IMMEDIATE_INVENTORY_AND_THE_INVENTORY_PHASE_WAS_REACHED;HELD_DIRECTORY_IDENTITY_ONLY_AND_ALL_NONDIRECTORY_POLICIES_FORBID_INVENTORY"
R.fetch("AdmissionRowV12")["rule"] += ";admission_policy_matrix_exact_IS_SELECTED_BY_THE_PROFILE_BOUND_admission_policy_enum_AFTER_KIND_CLASSIFICATION_AND_BEFORE_SUCCESS_OR_FAILURE_PHASE_REPLAY"

R["BoundedReadlinkObservationV12"] = {
  "keys" => [
    "state_enum", "cap_bytes_uint", "sample_bytes", "eof_observed_bool_or_null",
    "overflow_witness_bool_or_null", "complete_target_or_null", "error"
  ],
  "states_exact" => ["NOT_REQUESTED", "COMPLETE", "OVERFLOW", "ERROR"],
  "field_types_exact" => {
    "state_enum" => "LOCAL_ENUM(states_exact)", "cap_bytes_uint" => "U",
    "sample_bytes" => "REF(RawBytesV12)", "eof_observed_bool_or_null" => "B_OR_NULL",
    "overflow_witness_bool_or_null" => "B_OR_NULL",
    "complete_target_or_null" => "REF_OR_NULL(RawBytesV12)", "error" => "REF(ErrorV12)"
  },
  "state_matrix_exact" => {
    "NOT_REQUESTED" => {"sample_bytes.bytes_uint" => 0, "eof_observed_bool_or_null" => nil, "overflow_witness_bool_or_null" => nil, "complete_target_or_null" => nil, "error_state" => "NONE"},
    "COMPLETE" => {"sample_bytes.bytes_uint_at_most_cap" => true, "eof_observed_bool_or_null" => true, "overflow_witness_bool_or_null" => false, "complete_target_equals_sample" => true, "error_state" => "NONE"},
    "OVERFLOW" => {"sample_bytes.bytes_uint_equals_cap_plus_one" => true, "eof_observed_bool_or_null" => false, "overflow_witness_bool_or_null" => true, "complete_target_or_null" => nil, "error_state" => "NONE"},
    "ERROR" => {"sample_bytes.bytes_uint_at_most_cap" => true, "eof_observed_bool_or_null" => nil, "overflow_witness_bool_or_null" => nil, "complete_target_or_null" => nil, "error_state_not" => "NONE"}
  },
  "rule" => "READLINKAT_CAP_PLUS_ONE_RAW_BYTES_CARRIER;ONLY_COMPLETE_PROJECTS_complete_target_or_null_INTO_AdmissionRowV12.symlink_target_or_null;OVERFLOW_AND_ERROR_REMAIN_TYPED_SOURCE_OBSERVATIONS_AND_CAN_NEVER_BE_REPRESENTED_AS_A_SUCCESSFUL_RawBytesV12_TARGET"
}

R["AdmissionRowMechanicsSourceV12"] = {
  "keys" => ["profile_member", "readlink_observation_or_null", "row"],
  "field_types_exact" => {
    "profile_member" => "TUPLE(AdmissionProfileMemberV12)",
    "readlink_observation_or_null" => "REF_OR_NULL(BoundedReadlinkObservationV12)",
    "row" => "REF(AdmissionRowV12)"
  },
  "rule" => "profile_member_IS_THE_ONLY_POLICY_AUTHORITY;row_IS_REPLAYED_AGAINST_THAT_EXACT_MEMBER;readlink_observation_IS_NONNULL_IFF_THE_SYMLINK_PHASE_WAS_REACHED_AND_ONLY_ITS_COMPLETE_STATE_MAY_PROJECT_A_TARGET"
}
R["AdmissionSetMechanicsSourceV12"] = {
  "keys" => ["profile_members", "admission_set"],
  "field_types_exact" => {
    "profile_members" => "ARRAY(TUPLE(AdmissionProfileMemberV12),1,4,AdmissionOrdinalOrderV12)",
    "admission_set" => "REF(AdmissionSetV12)"
  },
  "rule" => "THE_PROFILE_ARRAY_IS_FROZEN_BEFORE_THE_CALL;THE_EVALUATOR_REPLAYS_EVERY_RETURNED_ROW_WITHOUT_SHORT_CIRCUIT_AND_THEN_REPLAYS_COUNT_ORDER_AND_COMPLETE"
}
R["RuntimeAdmissionMechanicsSourceV12"] = {
  "keys" => ["expected_contract", "observed_admission"],
  "field_types_exact" => {
    "expected_contract" => "REF(RuntimeAdmissionV12)",
    "observed_admission" => "REF(RuntimeAdmissionV12)"
  },
  "rule" => "COMPARE_ALL_CONTRACT_FIELDS_EXCEPT_matches_contract_bool_AND_error_FROM_TWO_RECURSIVELY_VALID_TYPED_VALUES;observed_matches_contract_bool_AND_error_MUST_EQUAL_THE_RECOMPUTED_RESULT"
}
R["FrameSetMechanicsSourceV12"] = {
  "keys" => ["expected_frames", "observed_frame_set"],
  "field_types_exact" => {
    "expected_frames" => "ARRAY(FrameReferenceV12,3,3,ContextProfileMemberOrderV12)",
    "observed_frame_set" => "REF(FrameSetV12)"
  },
  "rule" => "expected_frames_IS_FROZEN_BEFORE_RESOLUTION;ONLY_THE_CONTIGUOUS_REACHED_PREFIX_MAY_APPEAR_IN_observed_frame_set_AND_NO_FUTURE_MEMBER_MAY_BE_RESOLVED"
}

def obs_fixture(fixture_id, type_id, value)
  bytes = canon(value)
  {
    "fixture_id" => fixture_id, "type_id" => type_id,
    "canonical_json_base64" => Base64.strict_encode64(bytes),
    "bytes_uint" => bytes.bytesize, "sha256" => sha(bytes)
  }
end

def mechanics_error(code)
  value = error_pred(code)
  value
end

def mechanics_vnode(kind, inode)
  {
    "type_enum" => kind, "device_uint" => 19, "inode_uint" => inode,
    "generation_uint" => 7, "uid_uint" => 501, "gid_uint" => 20,
    "mode_octal4" => kind == "DIRECTORY" ? "0700" : (kind == "SYMLINK" ? "0777" : "0600"),
    "nlink_uint" => kind == "DIRECTORY" ? 2 : 1, "flags_uint" => 0,
    "size_uint" => 0, "ctime_seconds_int" => 1, "ctime_nanoseconds_uint" => 2,
    "mtime_seconds_int" => 1, "mtime_nanoseconds_uint" => 2
  }
end

def mechanics_raw_bytes(bytes)
  {
    "base64" => Base64.strict_encode64(bytes), "bytes_uint" => bytes.bytesize,
    "sha256" => sha(bytes),
    "ascii_display_or_null" => bytes.bytes.all? { |byte| byte.between?(0x20, 0x7e) } ? bytes : nil
  }
end

def mechanics_inventory(state = "NOT_REQUESTED", error = error_none, names = [])
  case state
  when "NOT_REQUESTED"
    {"state_enum" => state, "cap_entries_uint" => 8, "observed_names" => [], "observed_count_uint" => 0, "total_count_uint_or_null" => nil, "overflow_witness_bool_or_null" => nil, "error" => error}
  when "COMPLETE"
    {"state_enum" => state, "cap_entries_uint" => 8, "observed_names" => names, "observed_count_uint" => names.length, "total_count_uint_or_null" => names.length, "overflow_witness_bool_or_null" => false, "error" => error}
  when "ERROR"
    {"state_enum" => state, "cap_entries_uint" => 8, "observed_names" => names, "observed_count_uint" => names.length, "total_count_uint_or_null" => nil, "overflow_witness_bool_or_null" => nil, "error" => error}
  else
    raise "inventory state #{state}"
  end
end

def mechanics_named_join(path, state, kind = "REGULAR", inode = 5000, error = nil)
  before = mechanics_vnode(kind, inode)
  after = clone(before)
  named = clone(before)
  case state
  when "NOT_REQUESTED", "ABSENT"
    before = after = named = nil
    stable = joined = nil
    error ||= error_none
  when "JOINED"
    stable = joined = true
    error ||= error_none
  when "PRESENT_WRONG_TYPE"
    before = after = nil
    stable = nil
    joined = false
    error ||= mechanics_error("NAMED_PRESENT_WRONG_TYPE")
  when "OPEN_FAILED"
    before = after = nil
    stable = joined = nil
    error ||= mechanics_error("OPEN_FAILED")
  when "NAMED_FSTATAT_FAILED"
    named = nil
    stable = true
    joined = nil
    error ||= mechanics_error("NAMED_FSTATAT_FAILED")
  when "HELD_DRIFT"
    after = mechanics_vnode(kind, inode + 1)
    named = nil
    stable = false
    joined = nil
    error ||= mechanics_error("HELD_DRIFT")
  when "NAMED_MISMATCH"
    named = mechanics_vnode(kind, inode + 1)
    stable = true
    joined = false
    error ||= mechanics_error("NAMED_MISMATCH")
  else
    raise "named join state #{state}"
  end
  {
    "path" => path, "state_enum" => state, "held_before_or_null" => before,
    "held_after_or_null" => after, "named_after_or_null" => named,
    "held_stable_bool_or_null" => stable, "named_join_bool_or_null" => joined,
    "error" => error
  }
end

def mechanics_content(join_state = "JOINED", read_state = "COMPLETE", inode = 5000, error = nil)
  pre = mechanics_vnode("REGULAR", inode)
  post = clone(pre)
  named = clone(pre)
  sample_bytes = 0
  sample_lf = 0
  sample_sha = sha("")
  eof = true
  overflow = false
  complete_bytes = 0
  complete_lf = 0
  complete_sha = sha("")
  if read_state == "NOT_ATTEMPTED"
    sample_bytes = sample_lf = 0
    sample_sha = eof = overflow = complete_bytes = complete_lf = complete_sha = nil
  elsif read_state == "OVERFLOW"
    sample_bytes = 4097
    sample_lf = 0
    sample_sha = sha("x" * 4097)
    eof = false
    overflow = true
    complete_bytes = complete_lf = complete_sha = nil
  elsif read_state == "ERROR"
    sample_bytes = sample_lf = 0
    sample_sha = eof = overflow = complete_bytes = complete_lf = complete_sha = nil
  end
  stable = joined = nil
  case join_state
  when "NOT_ATTEMPTED"
    post = named = nil
  when "JOINED"
    stable = joined = true
  when "HELD_DRIFT"
    post = mechanics_vnode("REGULAR", inode + 1)
    named = nil
    stable = false
  when "NAMED_MISMATCH"
    named = mechanics_vnode("REGULAR", inode + 1)
    stable = true
    joined = false
  when "ERROR"
    named = nil
    stable = post.nil? ? nil : true
  else
    raise "content join #{join_state}"
  end
  error ||= (read_state == "COMPLETE" && join_state == "JOINED" ? error_none : mechanics_error("CONTENT_#{read_state}_#{join_state}"))
  {
    "presence_enum" => "PRESENT", "read_enum" => read_state, "join_enum" => join_state,
    "cap_bytes_uint" => 4096, "pre_vnode_or_null" => pre,
    "sample_bytes_uint" => sample_bytes, "sample_lf_count_uint" => sample_lf,
    "sample_sha256_or_null" => sample_sha, "eof_observed_bool_or_null" => eof,
    "overflow_witness_bool_or_null" => overflow, "complete_bytes_uint_or_null" => complete_bytes,
    "complete_lf_count_uint_or_null" => complete_lf, "complete_sha256_or_null" => complete_sha,
    "post_vnode_or_null" => post, "named_vnode_or_null" => named,
    "held_stable_bool_or_null" => stable, "named_join_bool_or_null" => joined,
    "error" => error
  }
end

def mechanics_readlink(state = "COMPLETE", cap = 16, bytes = "target")
  sample = state == "OVERFLOW" ? ("x" * (cap + 1)) : bytes
  raw = mechanics_raw_bytes(sample)
  {
    "state_enum" => state, "cap_bytes_uint" => cap, "sample_bytes" => raw,
    "eof_observed_bool_or_null" => state == "COMPLETE" ? true : (state == "OVERFLOW" ? false : nil),
    "overflow_witness_bool_or_null" => state == "COMPLETE" ? false : (state == "OVERFLOW" ? true : nil),
    "complete_target_or_null" => state == "COMPLETE" ? clone(raw) : nil,
    "error" => state == "ERROR" ? mechanics_error("READLINK_ERROR") : error_none
  }
end

def mechanics_profile(kind, policy, cap, target = nil)
  [
    0, "CONFORMANCE_MEMBER", "/private/tmp/v12-admission-member", kind,
    policy == "HELD_REGULAR_CONTENT_COMPLETE" ? cap : nil,
    target, policy == "HELD_SYMLINK_TARGET_AND_TARGET_ROLE_JOINED" ? "CONFORMANCE_TARGET" : nil,
    policy
  ]
end

def mechanics_row_base(kind, policy, join_state: "JOINED", inode: 5000)
  path = "/private/tmp/v12-admission-member"
  identity = mechanics_vnode(kind, inode)
  row = {
    "ordinal_uint" => 0, "role" => "CONFORMANCE_MEMBER", "path" => path,
    "admission_policy_enum" => policy, "observation_state_enum" => "PRESENT_ADMITTED",
    "kind_enum_or_null" => kind,
    "hash_cap_bytes_or_null" => kind == "REGULAR" ? 4096 : nil,
    "readlink_cap_bytes_or_null" => kind == "SYMLINK" ? 16 : nil,
    "identity_or_null" => identity,
    "content_or_null" => kind == "REGULAR" ? mechanics_content(join_state, "COMPLETE", inode) : nil,
    "symlink_target_or_null" => kind == "SYMLINK" ? mechanics_raw_bytes("target") : nil,
    "inventory_or_null" => kind == "DIRECTORY" ? mechanics_inventory("COMPLETE") : nil,
    "named_join" => mechanics_named_join(path, join_state, kind, inode),
    "failure_phase_enum_or_null" => nil, "error" => error_none
  }
  row
end

def mechanics_failure_row(case_id)
  path = "/private/tmp/v12-admission-member"
  row = mechanics_row_base("REGULAR", "HELD_REGULAR_CONTENT_COMPLETE")
  readlink = nil
  case case_id
  when "AR_ABSENT_CONFIRMED"
    row.merge!("observation_state_enum" => "ABSENT", "kind_enum_or_null" => nil, "identity_or_null" => nil, "content_or_null" => nil, "named_join" => mechanics_named_join(path, "ABSENT"), "failure_phase_enum_or_null" => "ABSENT_CONFIRMED")
  when "AR_LSTAT_FAILED"
    err = mechanics_error("LSTAT_FAILED")
    row.merge!("observation_state_enum" => "LSTAT_FAILED", "kind_enum_or_null" => nil, "identity_or_null" => nil, "content_or_null" => nil, "named_join" => mechanics_named_join(path, "NOT_REQUESTED"), "failure_phase_enum_or_null" => "LSTAT_FAILED", "error" => err)
  when "AR_OPEN_FAILED_AFTER_LSTAT"
    err = mechanics_error("OPEN_FAILED")
    join = mechanics_named_join(path, "OPEN_FAILED", "REGULAR", 5000, err)
    row.merge!("observation_state_enum" => "OPEN_FAILED", "content_or_null" => nil, "named_join" => join, "identity_or_null" => clone(join.fetch("named_after_or_null")), "failure_phase_enum_or_null" => "OPEN_FAILED_AFTER_LSTAT", "error" => clone(err))
  when "AR_KIND_POLICY_REJECTED"
    err = mechanics_error("KIND_POLICY_REJECTED")
    join = mechanics_named_join(path, "PRESENT_WRONG_TYPE", "DIRECTORY", 5000, err)
    row.merge!("observation_state_enum" => "POLICY_REJECTED", "kind_enum_or_null" => "DIRECTORY", "hash_cap_bytes_or_null" => nil, "identity_or_null" => clone(join.fetch("named_after_or_null")), "content_or_null" => nil, "named_join" => join, "failure_phase_enum_or_null" => "KIND_OR_METADATA_POLICY_REJECTED", "error" => clone(err))
  when "AR_METADATA_POLICY_REJECTED"
    err = mechanics_error("METADATA_POLICY_REJECTED")
    row["identity_or_null"]["mode_octal4"] = "0666"
    row["content_or_null"] = nil
    row["named_join"].values_at("held_before_or_null", "held_after_or_null", "named_after_or_null").compact.each { |v| v["mode_octal4"] = "0666" }
    row.merge!("observation_state_enum" => "POLICY_REJECTED", "failure_phase_enum_or_null" => "KIND_OR_METADATA_POLICY_REJECTED", "error" => err)
  when /^AR_REGULAR_/
    err = mechanics_error(case_id)
    read_state = case_id.include?("JOINED_POLICY") ? "OVERFLOW" : (case_id.include?("NOT_ATTEMPTED") ? "NOT_ATTEMPTED" : "COMPLETE")
    content_join = if case_id.include?("HELD_DRIFT") then "HELD_DRIFT" elsif case_id.include?("NAMED_MISMATCH") then "NAMED_MISMATCH" elsif case_id.include?("POST_FSTAT") || case_id.include?("NAMED_FSTATAT") then "ERROR" else (read_state == "NOT_ATTEMPTED" ? "NOT_ATTEMPTED" : "JOINED") end
    row["content_or_null"] = mechanics_content(content_join, read_state, 5000, err)
    named_state = if case_id.include?("HELD_DRIFT") then "HELD_DRIFT" elsif case_id.include?("NAMED_MISMATCH") then "NAMED_MISMATCH" elsif case_id.include?("NAMED_FSTATAT") then "NAMED_FSTATAT_FAILED" else (content_join == "JOINED" ? "JOINED" : "NOT_REQUESTED") end
    row["named_join"] = mechanics_named_join(path, named_state, "REGULAR", 5000, named_state == "JOINED" || named_state == "NOT_REQUESTED" ? nil : err)
    row.merge!("observation_state_enum" => "POLICY_REJECTED", "failure_phase_enum_or_null" => "REGULAR_CONTENT_FAILED", "error" => clone(err))
  when /^AR_DIRECTORY_/
    err = mechanics_error(case_id)
    row = mechanics_row_base("DIRECTORY", "HELD_DIRECTORY_EXACT_IMMEDIATE_INVENTORY")
    named_state = if case_id.include?("HELD_DRIFT") then "HELD_DRIFT" elsif case_id.include?("NAMED_MISMATCH") then "NAMED_MISMATCH" elsif case_id.include?("NAMED_FSTATAT") then "NAMED_FSTATAT_FAILED" else "JOINED" end
    names = case_id.include?("POLICY_MISMATCH") ? [{"raw_hex" => "78", "utf8_display_or_null" => "x"}] : []
    row["inventory_or_null"] = mechanics_inventory(case_id.include?("NAMED_FSTATAT") ? "ERROR" : "COMPLETE", case_id.include?("NAMED_FSTATAT") ? err : error_none, names)
    row["named_join"] = mechanics_named_join(path, named_state, "DIRECTORY", 5000, named_state == "JOINED" ? nil : err)
    row.merge!("observation_state_enum" => "POLICY_REJECTED", "failure_phase_enum_or_null" => "DIRECTORY_INVENTORY_FAILED", "error" => clone(err))
  when /^AR_SYMLINK_/
    err = mechanics_error(case_id)
    row = mechanics_row_base("SYMLINK", "HELD_SYMLINK_TARGET_AND_TARGET_ROLE_JOINED")
    named_state = if case_id.include?("HELD_DRIFT") then "HELD_DRIFT" elsif case_id.include?("NAMED_MISMATCH") then "NAMED_MISMATCH" elsif case_id.include?("NAMED_FSTATAT") then "NAMED_FSTATAT_FAILED" else "JOINED" end
    readlink = if case_id.include?("NAMED_FSTATAT")
      mechanics_readlink("ERROR")
    elsif case_id.include?("JOINED_TARGET_FAILURE")
      mechanics_readlink("COMPLETE", 16, "wrong")
    else
      mechanics_readlink("COMPLETE")
    end
    row["symlink_target_or_null"] = clone(readlink["complete_target_or_null"])
    row["named_join"] = mechanics_named_join(path, named_state, "SYMLINK", 5000, named_state == "JOINED" ? nil : err)
    row.merge!("observation_state_enum" => "POLICY_REJECTED", "failure_phase_enum_or_null" => "SYMLINK_TARGET_FAILED", "error" => clone(err))
  when /^AR_POSTJOIN_/
    err = mechanics_error(case_id)
    kind = case_id.include?("HELD_DRIFT") ? "REGULAR" : (case_id.include?("NAMED_MISMATCH") ? "DIRECTORY" : "SYMLINK")
    policy = {"REGULAR" => "HELD_REGULAR_CONTENT_COMPLETE", "DIRECTORY" => "HELD_DIRECTORY_EXACT_IMMEDIATE_INVENTORY", "SYMLINK" => "HELD_SYMLINK_TARGET_AND_TARGET_ROLE_JOINED"}.fetch(kind)
    row = mechanics_row_base(kind, policy)
    named_state = case_id.include?("HELD_DRIFT") ? "HELD_DRIFT" : (case_id.include?("NAMED_MISMATCH") ? "NAMED_MISMATCH" : "NAMED_FSTATAT_FAILED")
    row["named_join"] = mechanics_named_join(path, named_state, kind, 5000, err)
    readlink = mechanics_readlink("COMPLETE") if kind == "SYMLINK"
    row.merge!("observation_state_enum" => "POLICY_REJECTED", "failure_phase_enum_or_null" => "POSTJOIN_FAILED", "error" => clone(err))
  else
    raise "unhandled positive admission case #{case_id}"
  end
  [row, readlink]
end

def mechanics_negative_row(case_id)
  case case_id
  when "AR_NEG_PHASE_STATE_MISMATCH"
    row, readlink = mechanics_failure_row("AR_ABSENT_CONFIRMED")
    row["failure_phase_enum_or_null"] = "LSTAT_FAILED"
  when "AR_NEG_KIND_IDENTITY_TYPE_MISMATCH"
    row = mechanics_row_base("REGULAR", "HELD_REGULAR_CONTENT_COMPLETE")
    row["identity_or_null"]["type_enum"] = "DIRECTORY"
    readlink = nil
  when "AR_NEG_HELD_DRIFT_EQUAL_VNODES"
    row, readlink = mechanics_failure_row("AR_REGULAR_HELD_DRIFT")
    row["content_or_null"]["post_vnode_or_null"] = clone(row["content_or_null"]["pre_vnode_or_null"])
    row["named_join"]["held_after_or_null"] = clone(row["named_join"]["held_before_or_null"])
  when "AR_NEG_NAMED_MISMATCH_EQUAL_VNODES"
    row, readlink = mechanics_failure_row("AR_REGULAR_NAMED_MISMATCH")
    row["content_or_null"]["named_vnode_or_null"] = clone(row["content_or_null"]["pre_vnode_or_null"])
    row["named_join"]["named_after_or_null"] = clone(row["named_join"]["held_before_or_null"])
  when "AR_NEG_FAILURE_PAYLOAD_SHAPE"
    row, readlink = mechanics_failure_row("AR_ABSENT_CONFIRMED")
    row["content_or_null"] = mechanics_content
  when "AR_NEG_ERROR_JOIN_MISMATCH"
    row, readlink = mechanics_failure_row("AR_OPEN_FAILED_AFTER_LSTAT")
    row["error"] = mechanics_error("DIFFERENT_ERROR")
  when "AR_NEG_SYMLINK_TARGET_EXCEEDS_CAP"
    row, readlink = mechanics_failure_row("AR_SYMLINK_JOINED_TARGET_FAILURE")
    readlink = mechanics_readlink("OVERFLOW", 16)
    row["symlink_target_or_null"] = clone(readlink.fetch("sample_bytes"))
  when "AR_NEG_INVENTORY_NOT_APPLICABLE"
    row = mechanics_row_base("REGULAR", "HELD_REGULAR_CONTENT_COMPLETE")
    row["inventory_or_null"] = mechanics_inventory("COMPLETE")
    readlink = nil
  else
    raise "negative admission case #{case_id}"
  end
  [row, readlink]
end

observation_source_fixtures = []
admission_fixture_id_by_case = {}

admission_row_positive_cases.each do |case_row|
  case_id = case_row.fetch(0)
  row, readlink = mechanics_failure_row(case_id)
  kind = row.fetch("kind_enum_or_null") || "REGULAR"
  policy = row.fetch("admission_policy_enum")
  target = policy == "HELD_SYMLINK_TARGET_AND_TARGET_ROLE_JOINED" ? mechanics_raw_bytes("target") : nil
  source = {"profile_member" => mechanics_profile(kind, policy, 4096, target), "readlink_observation_or_null" => readlink, "row" => row}
  fixture_id = "ADMISSION_MECHANICS_SOURCE_#{case_id}"
  observation_source_fixtures << obs_fixture(fixture_id, "AdmissionRowMechanicsSourceV12", source)
  admission_fixture_id_by_case[case_id] = fixture_id
end
admission_row_negative_cases.each do |case_row|
  case_id = case_row.fetch(0)
  row, readlink = mechanics_negative_row(case_id)
  kind = row.fetch("kind_enum_or_null") || "REGULAR"
  policy = row.fetch("admission_policy_enum")
  target = policy == "HELD_SYMLINK_TARGET_AND_TARGET_ROLE_JOINED" ? mechanics_raw_bytes("target") : nil
  source = {"profile_member" => mechanics_profile(kind, policy, 4096, target), "readlink_observation_or_null" => readlink, "row" => row}
  fixture_id = "ADMISSION_MECHANICS_SOURCE_#{case_id}"
  observation_source_fixtures << obs_fixture(fixture_id, "AdmissionRowMechanicsSourceV12", source)
  admission_fixture_id_by_case[case_id] = fixture_id
end

admitted_row = mechanics_row_base("REGULAR", "HELD_REGULAR_CONTENT_COMPLETE")
admitted_profile = mechanics_profile("REGULAR", "HELD_REGULAR_CONTENT_COMPLETE", 4096)
failed_row, = mechanics_failure_row("AR_ABSENT_CONFIRMED")
admission_set_sources = {
  "AS_FULL_SUCCESS" => [[admitted_profile], {"label" => "CONFORMANCE_SET", "expected_count_uint" => 1, "rows" => [admitted_row], "observed_count_uint" => 1, "complete_bool" => true, "error" => error_none}],
  "AS_FULL_WITH_RETAINED_FAILURE" => [[admitted_profile], {"label" => "CONFORMANCE_SET", "expected_count_uint" => 1, "rows" => [failed_row], "observed_count_uint" => 1, "complete_bool" => false, "error" => error_none}],
  "AS_SHORT_PREFIX" => [[admitted_profile, [1, "SECOND", "/private/tmp/v12-second", "REGULAR", 4096, nil, nil, "HELD_REGULAR_CONTENT_COMPLETE"]], {"label" => "CONFORMANCE_SET", "expected_count_uint" => 2, "rows" => [admitted_row], "observed_count_uint" => 1, "complete_bool" => false, "error" => error_none}],
  "AS_HOLE_OR_REORDER" => [[admitted_profile, [1, "SECOND", "/private/tmp/v12-second", "REGULAR", 4096, nil, nil, "HELD_REGULAR_CONTENT_COMPLETE"]], {"label" => "CONFORMANCE_SET", "expected_count_uint" => 2, "rows" => [clone(admitted_row).merge("ordinal_uint" => 1), admitted_row], "observed_count_uint" => 2, "complete_bool" => true, "error" => error_none}]
}
admission_set_sources.each do |case_id, (profiles, set_value)|
  fixture_id = "ADMISSION_MECHANICS_SOURCE_#{case_id}"
  source = {"profile_members" => profiles, "admission_set" => set_value}
  observation_source_fixtures << obs_fixture(fixture_id, "AdmissionSetMechanicsSourceV12", source)
  admission_fixture_id_by_case[case_id] = fixture_id
end

custom_fixtures = D.fetch("custom_operator_conformance_catalog_v12").fetch("fixtures")
endpoint_fixture = custom_fixtures.find { |row| row.fetch("type_id") == "OuterPublicationEndpointInputV12" }
raise "runtime admission prototype fixture" unless endpoint_fixture
endpoint_value = JSON.parse(Base64.strict_decode64(endpoint_fixture.fetch("canonical_json_base64")))
runtime_expected = clone(endpoint_value.fetch("observer_runtime_admission"))
runtime_expected["matches_contract_bool"] = true
runtime_expected["error"] = error_none
runtime_sources = {
  "RA_EXACT_MATCH" => clone(runtime_expected),
  "RA_ARGV_MISMATCH" => clone(runtime_expected),
  "RA_ENVIRONMENT_MISMATCH" => clone(runtime_expected),
  "RA_CWD_VNODE_MISMATCH" => clone(runtime_expected),
  "RA_FD_CONTRACT_MISMATCH" => clone(runtime_expected)
}
runtime_sources.fetch("RA_ARGV_MISMATCH")["os_argv_exact"] = ["/different"]
runtime_sources.fetch("RA_ENVIRONMENT_MISMATCH")["environment_exact"] = [{"name" => "X", "value" => "1"}]
cwd_mismatch = runtime_sources.fetch("RA_CWD_VNODE_MISMATCH").fetch("cwd_join")
cwd_mismatch["state_enum"] = "NAMED_MISMATCH"
cwd_mismatch["named_after_or_null"]["inode_uint"] += 1
cwd_mismatch["held_stable_bool_or_null"] = true
cwd_mismatch["named_join_bool_or_null"] = false
cwd_mismatch["error"] = mechanics_error("RUNTIME_CWD_NAMED_MISMATCH")
fd_mismatch = runtime_sources.fetch("RA_FD_CONTRACT_MISMATCH").fetch("fd_contract")
fd_mismatch["canonical_value_json_base64"] = Base64.strict_encode64("false")
fd_mismatch["canonical_value_bytes_uint"] = 5
fd_mismatch["canonical_value_sha256"] = sha("false")
fd_mismatch["matches_held_control_bool"] = false
fd_mismatch["error"] = mechanics_error("RUNTIME_FD_CONTRACT_MISMATCH")
runtime_sources.each do |case_id, observed|
  unless case_id == "RA_EXACT_MATCH"
    observed["matches_contract_bool"] = false
    observed["error"] = mechanics_error("RUNTIME_CONTRACT_MISMATCH")
  end
  fixture_id = "ADMISSION_MECHANICS_SOURCE_#{case_id}"
  source = {"expected_contract" => clone(runtime_expected), "observed_admission" => observed}
  observation_source_fixtures << obs_fixture(fixture_id, "RuntimeAdmissionMechanicsSourceV12", source)
  admission_fixture_id_by_case[case_id] = fixture_id
end

workspace_fixture = custom_fixtures.find { |row| row.fetch("type_id") == "OuterPublicationEndpointWorkspaceV12" }
raise "frame set prototype fixture" unless workspace_fixture
workspace_value = JSON.parse(Base64.strict_decode64(workspace_fixture.fetch("canonical_json_base64")))
frame_prototype = clone(workspace_value.fetch("pre_spawn_checkpoint_readiness_binding"))
expected_frames = clone(frame_prototype.fetch("frames"))
frame_sources = {}
[0, 1, 2].each do |count|
  frame_sources["FS_REACHED_PREFIX_#{count}"] = {"label" => "CONFORMANCE_FRAMES", "expected_count_uint" => 3, "frames" => clone(expected_frames.first(count)), "observed_count_uint" => count, "complete_bool" => false, "error" => error_none}
end
frame_sources["FS_FULL_3"] = clone(frame_prototype)
frame_sources["FS_HOLE"] = {"label" => "CONFORMANCE_FRAMES", "expected_count_uint" => 3, "frames" => [clone(expected_frames[0]), clone(expected_frames[2])], "observed_count_uint" => 2, "complete_bool" => false, "error" => mechanics_error("FRAME_PREFIX_HOLE")}
frame_sources["FS_FUTURE_MEMBER_RESOLVED"] = {"label" => "CONFORMANCE_FRAMES", "expected_count_uint" => 3, "frames" => [clone(expected_frames[1])], "observed_count_uint" => 1, "complete_bool" => false, "error" => mechanics_error("FUTURE_FRAME_RESOLVED")}
frame_sources.each do |case_id, frame_set|
  fixture_id = "ADMISSION_MECHANICS_SOURCE_#{case_id}"
  source = {"expected_frames" => clone(expected_frames), "observed_frame_set" => frame_set}
  observation_source_fixtures << obs_fixture(fixture_id, "FrameSetMechanicsSourceV12", source)
  admission_fixture_id_by_case[case_id] = fixture_id
end

admission_vector_schema = R.fetch("AdmissionMechanicsConformanceVectorV12")
unless admission_vector_schema.fetch("tuple_fields_exact_order").include?("source_fixture_id")
  admission_vector_schema.fetch("tuple_fields_exact_order") << "source_fixture_id"
  admission_vector_schema.fetch("tuple_field_types_exact") << "S"
end
admission_vectors.each do |row|
  row << admission_fixture_id_by_case.fetch(row.fetch(2)) if row.length == 8
end
admission_vector_schema["rule"] = "source_fixture_id_RESOLVES_EXACTLY_ONE_content_addressed_ObservationConformanceSourceFixtureV12_OF_THE_FAMILY_EXACT_SOURCE_TYPE;STRICT_DECODE_RECURSIVE_VALIDATE_AND_EVALUATE_THE_ACTUAL_SOURCE_BYTES_WITHOUT_READING_vector_id_OR_EXPECTED_FIELDS;THE_SEPARATE_EXPECTED_RESULT_ROW_IS_COMPARED_ONLY_AFTER_EVALUATION"

S.fetch("admission_mechanics_case_materialization_v12").merge!(
  "source_fixture_array_pointer" => "/exact_record_schema_v12/state_constraint_registry_v12/observation_integrity_conformance_catalog_v12/source_fixtures",
  "source_fixture_id_by_case_exact" => admission_fixture_id_by_case.to_a,
  "full_raw_typed_input_per_vector_bool" => true,
  "materialization_rule" => "RESOLVE_THE_EXACT_VECTOR_source_fixture_id;STRICT_DECODE_LENGTH_HASH_CANONICAL_JSON_AND_RECURSIVELY_VALIDATE_AdmissionRowMechanicsSourceV12_AdmissionSetMechanicsSourceV12_RuntimeAdmissionMechanicsSourceV12_OR_FrameSetMechanicsSourceV12;EXECUTE_THE_ACTUAL_TYPED_MECHANICS;ONLY_AFTER_RESULT_MATERIALIZATION_COMPARE_THE_SEPARATELY_STORED_EXPECTED_ROW;NO_CASE_ENUM_PROSE_OR_EXPECTED_FIELD_SUPPLIES_INPUT"
)

# Carrier families below append their own fixtures to this shared array before
# finalize-control.rb binds and reseals it.
OBSERVATION_SOURCE_FIXTURES_V12 = observation_source_fixtures
