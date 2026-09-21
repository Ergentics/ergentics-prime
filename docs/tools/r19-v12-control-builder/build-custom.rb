#!/usr/bin/ruby
# frozen_string_literal: true

require "json"
require "digest"
require "base64"
require_relative "control-file"

abort("usage: #{$PROGRAM_NAME} CONTROL.json") unless ARGV.length == 1
PATHNAME = ARGV.fetch(0)
CONTROL_INPUT = V12ControlFile.capture(PATHNAME)
J = JSON.parse(CONTROL_INPUT.bytes)
X = J.fetch("exact_record_schema_v12")
R = X.fetch("reusable_objects")
S = X.fetch("state_constraint_registry_v12")
D = X.fetch("decision_kernel_v12")
CAT = D.fetch("custom_operator_conformance_catalog_v12")

def clone(value)
  Marshal.load(Marshal.dump(value))
end

def canon(value)
  JSON.generate(value)
end

def sha(value)
  Digest::SHA256.hexdigest(value.is_a?(String) ? value.b : canon(value))
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

def error_pred(code)
  e = error_none
  e["state_enum"] = "PREDICATE_FALSE"
  e["code_string_or_null"] = code
  e
end

def error_errno(code, number = 5)
  e = error_none
  e["state_enum"] = "NATIVE_ERRNO"
  e["code_string_or_null"] = code
  e["errno_int_or_null"] = number
  e
end

def typed(type_id, value)
  bytes = canon(value)
  {
    "type_id" => type_id,
    "canonical_json_base64" => Base64.strict_encode64(bytes),
    "bytes_uint" => bytes.bytesize,
    "sha256" => sha(bytes)
  }
end

def eval_bool(value)
  {
    "state_enum" => "VALUE",
    "type_id" => "B",
    "value_or_null" => typed("B", value),
    "error" => error_none
  }
end

def eval_nonvalue(state, code)
  {
    "state_enum" => state,
    "type_id" => "B",
    "value_or_null" => nil,
    "error" => error_pred(code)
  }
end

EVAL_TRUE = eval_bool(true)
EVAL_FALSE = eval_bool(false)
EVAL_UNAVAILABLE = eval_nonvalue("UNAVAILABLE", "INPUT_UNAVAILABLE")
EVAL_TYPE_ERROR = eval_nonvalue("TYPE_ERROR", "INPUT_TYPE_ERROR")

def fixture(id, type_id, value)
  bytes = canon(value)
  {
    "fixture_id" => id,
    "type_id" => type_id,
    "canonical_json_base64" => Base64.strict_encode64(bytes),
    "bytes_uint" => bytes.bytesize,
    "sha256" => sha(bytes)
  }
end

def value_binding(binding_id, fixture_id)
  {
    "binding_id" => binding_id,
    "state_enum" => "VALUE",
    "fixture_id_or_null" => fixture_id,
    "error" => error_none
  }
end

def unavailable_binding(binding_id)
  {
    "binding_id" => binding_id,
    "state_enum" => "UNAVAILABLE",
    "fixture_id_or_null" => nil,
    "error" => error_pred("INPUT_UNAVAILABLE")
  }
end

def type_error_binding(binding_id, fixture_id = "B_TRUE")
  {
    "binding_id" => binding_id,
    "state_enum" => "TYPE_ERROR",
    "fixture_id_or_null" => fixture_id,
    "error" => error_pred("INPUT_TYPE_ERROR")
  }
end

def vector(id, operator_id, bindings, expected)
  {
    "vector_id" => id,
    "operator_id" => operator_id,
    "token_operand_enum_or_null" => nil,
    "bindings" => bindings,
    "expected_result" => clone(expected)
  }
end

def vnode(type = "REGULAR", inode = 4101, size = 0)
  {
    "type_enum" => type,
    "device_uint" => 19,
    "inode_uint" => inode,
    "generation_uint" => 7,
    "uid_uint" => 501,
    "gid_uint" => 20,
    "mode_octal4" => type == "DIRECTORY" ? "0700" : "0600",
    "nlink_uint" => type == "DIRECTORY" ? 2 : 1,
    "flags_uint" => 0,
    "size_uint" => size,
    "ctime_seconds_int" => 1,
    "ctime_nanoseconds_uint" => 2,
    "mtime_seconds_int" => 1,
    "mtime_nanoseconds_uint" => 2
  }
end

def vnode_identity(v)
  {
    "type_enum" => v.fetch("type_enum"),
    "device_uint" => v.fetch("device_uint"),
    "inode_uint" => v.fetch("inode_uint"),
    "generation_uint" => v.fetch("generation_uint")
  }
end

def inventory_name(name)
  {"raw_hex" => name.unpack1("H*"), "utf8_display_or_null" => name}
end

def artifact_slot(path, present, v = vnode)
  {
    "final_path" => path,
    "staging_pattern" => "#{path}.tmp.XXXXXXXX",
    "final_state_enum" => present ? "PRESENT_REGULAR" : "ABSENT",
    "final_vnode_or_null" => present ? clone(v) : nil,
    "staging_state_enum" => "NONE",
    "staging_leaves" => [],
    "staging_match_count_uint" => 0,
    "scan_complete_bool" => true,
    "error" => error_none
  }
end

def named_join(path, v)
  {
    "path" => path,
    "state_enum" => "JOINED",
    "held_before_or_null" => clone(v),
    "held_after_or_null" => clone(v),
    "named_after_or_null" => clone(v),
    "held_stable_bool_or_null" => true,
    "named_join_bool_or_null" => true,
    "error" => error_none
  }
end

def content_complete(v)
  empty_hash = Digest::SHA256.hexdigest("")
  {
    "presence_enum" => "PRESENT",
    "read_enum" => "COMPLETE",
    "join_enum" => "JOINED",
    "cap_bytes_uint" => 4096,
    "pre_vnode_or_null" => clone(v),
    "sample_bytes_uint" => 0,
    "sample_lf_count_uint" => 0,
    "sample_sha256_or_null" => empty_hash,
    "eof_observed_bool_or_null" => true,
    "overflow_witness_bool_or_null" => false,
    "complete_bytes_uint_or_null" => 0,
    "complete_lf_count_uint_or_null" => 0,
    "complete_sha256_or_null" => empty_hash,
    "post_vnode_or_null" => clone(v),
    "named_vnode_or_null" => clone(v),
    "held_stable_bool_or_null" => true,
    "named_join_bool_or_null" => true,
    "error" => error_none
  }
end

def content_absent
  {
    "presence_enum" => "ABSENT", "read_enum" => "NOT_ATTEMPTED", "join_enum" => "NOT_ATTEMPTED",
    "cap_bytes_uint" => 4096, "pre_vnode_or_null" => nil, "sample_bytes_uint" => 0,
    "sample_lf_count_uint" => 0, "sample_sha256_or_null" => nil, "eof_observed_bool_or_null" => nil,
    "overflow_witness_bool_or_null" => nil, "complete_bytes_uint_or_null" => nil,
    "complete_lf_count_uint_or_null" => nil, "complete_sha256_or_null" => nil,
    "post_vnode_or_null" => nil, "named_vnode_or_null" => nil,
    "held_stable_bool_or_null" => nil, "named_join_bool_or_null" => nil, "error" => error_none
  }
end

def admission_row(path)
  v = vnode("REGULAR", 4102)
  {
    "ordinal_uint" => 0,
    "role" => "CONFORMANCE_EXECUTABLE",
    "path" => path,
    "admission_policy_enum" => "HELD_REGULAR_CONTENT_COMPLETE",
    "observation_state_enum" => "PRESENT_ADMITTED",
    "kind_enum_or_null" => "REGULAR",
    "hash_cap_bytes_or_null" => 4096,
    "readlink_cap_bytes_or_null" => nil,
    "identity_or_null" => clone(v),
    "content_or_null" => content_complete(v),
    "symlink_target_or_null" => nil,
    "inventory_or_null" => nil,
    "named_join" => named_join(path, v),
    "failure_phase_enum_or_null" => nil,
    "error" => error_none
  }
end

def control_projection
  bytes = canon([])
  {
    "control_payload_sha256" => "0" * 64,
    "json_pointer" => "/conformance",
    "canonical_value_json_base64" => Base64.strict_encode64(bytes),
    "canonical_value_bytes_uint" => bytes.bytesize,
    "canonical_value_sha256" => sha(bytes),
    "matches_held_control_bool" => true,
    "error" => error_none
  }
end

def runtime_admission(matches, source_error)
  path = "/private/tmp/v12-conformance-observer"
  cwd_vnode = vnode("DIRECTORY", 4103)
  {
    "label" => "OUTER_OBSERVER",
    "executable" => admission_row(path),
    "os_argv_exact" => [path],
    "script_argv_exact" => [],
    "environment_exact" => [],
    "cwd_join" => named_join("/private/tmp", cwd_vnode),
    "stdin_policy" => "DEV_NULL_EOF",
    "stdout_policy" => "HELD_CAPTURE",
    "stderr_policy" => "HELD_CAPTURE",
    "uid_uint" => 501, "euid_uint" => 501, "gid_uint" => 20, "egid_uint" => 20,
    "umask_octal4" => "0077",
    "fd_contract" => control_projection,
    "matches_contract_bool" => matches,
    "error" => clone(source_error)
  }
end

def frame_reference(index)
  v = vnode("REGULAR", 4200 + index, 3)
  {
    "path" => "/private/tmp/v12-frame-#{index}.json",
    "schema" => "ergentics.conformance.frame.v12",
    "status" => "PASS",
    "vnode" => v,
    "bytes_uint" => 3,
    "lf_count_uint" => 1,
    "complete_frame_sha256" => sha("{}\n"),
    "payload_sha256" => "1" * 64
  }
end

def frame_set(cut)
  count = cut.fetch("observed_count_uint")
  {
    "label" => "PRE_SPAWN_CHECKPOINT_READINESS",
    "expected_count_uint" => 3,
    "frames" => count.times.map { |i| frame_reference(i) },
    "observed_count_uint" => count,
    "complete_bool" => cut.fetch("complete_bool"),
    "error" => clone(cut.fetch("error"))
  }
end

def capture_admission(label, path, complete)
  v = vnode("REGULAR", label == "OUTER_STDOUT" ? 4301 : 4302)
  {
    "label" => label,
    "path" => path,
    "slot" => artifact_slot(path, complete, v),
    "content" => complete ? content_complete(v) : content_absent
  }
end

def full_prehold(cut)
  state = cut.fetch("state_enum")
  path = cut.fetch("path")
  v = vnode("REGULAR", cut.fetch("label") == "OUTER_STDOUT" ? 4301 : 4302)
  base = {
    "label" => cut.fetch("label"), "path" => path, "state_enum" => state,
    "fd_int_or_null" => nil, "fd_flags_int_or_null" => nil, "fd_cloexec_bool_or_null" => nil,
    "slot" => artifact_slot(path, false, v), "held_vnode_or_null" => nil,
    "named_before_spawn_vnode_or_null" => nil, "held_identity_or_null" => nil,
    "error" => clone(cut.fetch("error"))
  }
  if state == "HELD"
    base["fd_int_or_null"] = cut.fetch("label") == "OUTER_STDOUT" ? 8 : 9
    base["fd_flags_int_or_null"] = 1
    base["fd_cloexec_bool_or_null"] = true
    base["slot"] = artifact_slot(path, true, v)
    base["held_vnode_or_null"] = clone(v)
    base["named_before_spawn_vnode_or_null"] = clone(v)
    base["held_identity_or_null"] = vnode_identity(v)
  end
  base
end

def continuity(cut, state)
  hold = full_prehold(cut)
  value = {
    "label" => cut.fetch("label"), "path" => cut.fetch("path"), "pre_spawn_hold" => hold,
    "post_reap_fd_flags_int_or_null" => nil, "post_reap_fd_cloexec_bool_or_null" => nil,
    "post_reap_vnode_or_null" => nil, "post_reap_identity_or_null" => nil,
    "post_reap_complete_sha256_or_null" => nil,
    "continuity_state_enum" => state,
    "error" => state == "UNAVAILABLE" ? clone(cut.fetch("error")) : error_none
  }
  if %w[JOINED_NO_CHILD JOINED].include?(state)
    v = hold.fetch("held_vnode_or_null")
    value["post_reap_fd_flags_int_or_null"] = 1
    value["post_reap_fd_cloexec_bool_or_null"] = true
    value["post_reap_vnode_or_null"] = clone(v)
    value["post_reap_identity_or_null"] = vnode_identity(v)
    value["post_reap_complete_sha256_or_null"] = Digest::SHA256.hexdigest("")
  end
  value
end

def process_observation(state)
  base = {
    "state_enum" => state,
    "spawn_attempted_bool" => false, "spawn_returned_pid_bool" => false,
    "spawned_pid_uint_or_null" => nil, "wait_attempted_bool" => false,
    "waited_pid_uint_or_null" => nil, "wait_completed_bool" => false,
    "status_raw_int_or_null" => nil, "exited_bool_or_null" => nil,
    "exit_code_int_or_null" => nil, "signaled_bool_or_null" => nil,
    "signal_number_uint_or_null" => nil, "core_dumped_bool_or_null" => nil,
    "error" => error_none
  }
  case state
  when "SPAWN_RAISED"
    base["spawn_attempted_bool"] = true
    base["error"] = error_errno("POSIX_SPAWN_RAISED")
  when "WAIT_FAILED"
    base["spawn_attempted_bool"] = true
    base["spawn_returned_pid_bool"] = true
    base["spawned_pid_uint_or_null"] = 4242
    base["wait_attempted_bool"] = true
    base["error"] = error_errno("WAITPID_FAILED")
  when "PID_RETURNED_REAPED_EXIT"
    base["spawn_attempted_bool"] = true
    base["spawn_returned_pid_bool"] = true
    base["spawned_pid_uint_or_null"] = 4242
    base["wait_attempted_bool"] = true
    base["waited_pid_uint_or_null"] = 4242
    base["wait_completed_bool"] = true
    base["status_raw_int_or_null"] = 0
    base["exited_bool_or_null"] = true
    base["exit_code_int_or_null"] = 0
    base["signaled_bool_or_null"] = false
    base["core_dumped_bool_or_null"] = false
  when "PID_RETURNED_REAPED_SIGNAL"
    base["spawn_attempted_bool"] = true
    base["spawn_returned_pid_bool"] = true
    base["spawned_pid_uint_or_null"] = 4242
    base["wait_attempted_bool"] = true
    base["waited_pid_uint_or_null"] = 4242
    base["wait_completed_bool"] = true
    base["status_raw_int_or_null"] = 9
    base["exited_bool_or_null"] = false
    base["signaled_bool_or_null"] = true
    base["signal_number_uint_or_null"] = 9
    base["core_dumped_bool_or_null"] = false
  end
  base
end

def interval_from_cut(data)
  {
    "state_enum" => data.fetch("outer_interval_state_enum"),
    "start_tick_uint_or_null" => nil, "end_tick_uint_or_null" => nil,
    "delta_tick_uint_or_null" => nil,
    "timebase" => clone(data.fetch("outer_interval_timebase")),
    "raw_nanoseconds_numerator_uint_or_null" => nil,
    "raw_nanoseconds_denominator_uint_or_null" => nil,
    "reduced_nanoseconds_numerator_uint_or_null" => nil,
    "reduced_nanoseconds_denominator_uint_or_null" => nil,
    "start_realtime" => clone(data.fetch("outer_interval_start_realtime")),
    "end_realtime" => clone(data.fetch("outer_interval_end_realtime")),
    "error" => clone(data.fetch("outer_interval_error"))
  }
end

def valid_timebase
  {"state_enum" => "VALID", "return_code_int" => 0, "numerator_uint_or_null" => 1,
   "denominator_uint_or_null" => 3, "error" => error_none}
end

def valid_realtime(seconds)
  {"state_enum" => "VALID", "seconds_int_or_null" => seconds,
   "nanoseconds_raw_int_or_null" => 0,
   "rfc3339_display_only_or_null" => "1970-01-01T00:00:0#{seconds}.000000000Z",
   "error" => error_none}
end

def complete_interval
  {
    "state_enum" => "COMPLETE", "start_tick_uint_or_null" => 10, "end_tick_uint_or_null" => 13,
    "delta_tick_uint_or_null" => 3, "timebase" => valid_timebase,
    "raw_nanoseconds_numerator_uint_or_null" => 3,
    "raw_nanoseconds_denominator_uint_or_null" => 3,
    "reduced_nanoseconds_numerator_uint_or_null" => 1,
    "reduced_nanoseconds_denominator_uint_or_null" => 1,
    "start_realtime" => valid_realtime(1), "end_realtime" => valid_realtime(2),
    "error" => error_none
  }
end

def start_only_interval
  {
    "state_enum" => "START_ONLY", "start_tick_uint_or_null" => 10, "end_tick_uint_or_null" => nil,
    "delta_tick_uint_or_null" => nil, "timebase" => valid_timebase,
    "raw_nanoseconds_numerator_uint_or_null" => nil,
    "raw_nanoseconds_denominator_uint_or_null" => nil,
    "reduced_nanoseconds_numerator_uint_or_null" => nil,
    "reduced_nanoseconds_denominator_uint_or_null" => nil,
    "start_realtime" => valid_realtime(1),
    "end_realtime" => {"state_enum" => "NOT_SAMPLED", "seconds_int_or_null" => nil,
      "nanoseconds_raw_int_or_null" => nil, "rfc3339_display_only_or_null" => nil, "error" => error_none},
    "error" => error_none
  }
end

def pointer_get(root, pointer)
  return root if pointer == "" || pointer == "/"
  pointer.split("/")[1..].reduce(root) do |value, token|
    key = token.gsub("~1", "/").gsub("~0", "~")
    value.is_a?(Array) ? value.fetch(Integer(key, 10)) : value.fetch(key)
  end
end

def predicate_definition(predicate_id)
  row = (D.fetch("predicate_definitions_v12") + D.fetch("transition_predicate_definitions_v12")).find do |candidate|
    candidate.fetch("predicate_id") == predicate_id
  end
  raise "missing predicate #{predicate_id}" unless row
  row
end

def evaluate_simple_postfix(predicate_id, program_enum, program, source_root)
  stack = []
  witnesses = []
  program.each_with_index do |token, ordinal|
    op = token.fetch(0)
    case op
    when "BOOL"
      stack << token.fetch(1)
    when "STRING"
      stack << token.fetch(1)
    when "GET"
      source_id, pointer, type_id = token[1], token[2], token[3]
      raise "conformance generator only supports SELF GET" unless source_id == "SELF"
      value = pointer_get(source_root, pointer)
      witnesses << {
        "witness_id" => "#{predicate_id}:#{program_enum}:#{ordinal}",
        "program_enum" => program_enum,
        "token_ordinal_uint" => ordinal,
        "token_kind_enum" => "GET",
        "source_id" => source_id,
        "selector_string" => pointer,
        "expected_type_id_or_null" => type_id,
        "resolution_state_enum" => "RESOLVED",
        "observed_type_id_or_null" => type_id,
        "observed_value_or_null" => typed(type_id, value),
        "error" => error_none
      }
      stack << value
    when "SCHEMA_VALID"
      stack.pop
      stack << true
    when "EQ"
      right = stack.pop
      left = stack.pop
      stack << (left == right)
    when "NE"
      right = stack.pop
      left = stack.pop
      stack << (left != right)
    when "AND"
      count = token.fetch(1)
      values = stack.pop(count)
      stack << values.all?(true)
    when "OR"
      count = token.fetch(1)
      values = stack.pop(count)
      stack << values.any?(true)
    else
      raise "unsupported predicate token #{token.inspect}"
    end
  end
  raise "bad stack for #{predicate_id}/#{program_enum}" unless stack.length == 1 && [true, false].include?(stack.first)
  [stack.first, witnesses]
end

def predicate_evaluation(predicate_id, source_root, forced_assertion = nil)
  definition = predicate_definition(predicate_id)
  app, app_witness = evaluate_simple_postfix(
    predicate_id, "APPLICABILITY", definition.fetch("applicability_postfix_program"), source_root
  )
  if forced_assertion.nil?
    assertion, assertion_witness = evaluate_simple_postfix(
      predicate_id, "ASSERTION", definition.fetch("assertion_postfix_program"), source_root
    )
  else
    assertion = forced_assertion
    assertion_witness = []
  end
  state = app ? (assertion ? "TRUE" : "FALSE") : "NOT_APPLICABLE"
  {
    "predicate_id" => predicate_id,
    "definition_complete_json_sha256" => sha(definition),
    "state_enum" => state,
    "witness_evaluations" => app_witness + assertion_witness,
    "applicability_result" => eval_bool(app),
    "assertion_result" => eval_bool(assertion),
    "error" => error_none
  }
end

def custom_predicate_evaluation(predicate_id, assertion)
  definition = predicate_definition(predicate_id)
  {
    "predicate_id" => predicate_id,
    "definition_complete_json_sha256" => sha(definition),
    "state_enum" => assertion ? "TRUE" : "FALSE",
    "witness_evaluations" => [],
    "applicability_result" => eval_bool(true),
    "assertion_result" => eval_bool(assertion),
    "error" => error_none
  }
end

def receipt(sequence, transition_id, entered, outer_context)
  definition = D.fetch("transition_definitions_v12").find { |row| row.fetch("transition_id") == transition_id }
  raise "missing transition #{transition_id}" unless definition
  predicate_id = definition.fetch("trigger_predicate_id")
  trigger = predicate_evaluation(predicate_id, outer_context)
  entered = false unless trigger.fetch("state_enum") == "TRUE"
  source_pointer = D.dig("transition_receipt_semantics_v12", "source_instance_binding_by_transition_exact").find do |row|
    row.fetch(0) == transition_id
  end.fetch(1)
  source_value = pointer_get(outer_context, source_pointer)
  {
    "sequence_uint" => sequence,
    "transition_id" => transition_id,
    "source_instance_json_pointer_or_null" => source_pointer,
    "source_instance_complete_json_sha256_or_null" => sha(source_value),
    "state_enum" => entered ? "ENTERED" : "NOT_ENTERED",
    "from_state_enum" => definition.fetch("from_state_enum"),
    "to_state_enum_or_null" => entered ? definition.fetch("to_state_enum") : nil,
    "trigger_evaluation" => trigger,
    "guard_evaluations" => [],
    "counter_deltas_applied" => entered ? clone(definition.fetch("counter_deltas")) : [],
    "error" => error_none
  }
end

OUTER_TRANSITIONS = %w[
  TR_OUTER_SELF_ENTRY_PROVED
  TR_OBSERVER_NAMESPACE_SPENT
  TR_CONTROLLER_SPAWN_CALL_ENTERED
  TR_CONTROLLER_PID_RETURNED
  TR_CONTROLLER_EXACT_REAP
].freeze

def counter_snapshot(scope, values, through = 5, observation = nil)
  ids = D.fetch("counter_catalog").fetch(scope)
  observation ||= scope == "OUTER_PROCESS" ? "EXACT_SELF" : "UNKNOWN"
  entries = ids.each_with_index.map do |counter_id, index|
    if observation == "EXACT_SELF"
      {"counter_id" => counter_id, "state_enum" => "EXACT", "value_uint_or_null" => values.fetch(index)}
    elsif observation == "EXACT_IMPORTED"
      {"counter_id" => counter_id, "state_enum" => "LOWER_BOUND", "value_uint_or_null" => values.fetch(index)}
    else
      {"counter_id" => counter_id, "state_enum" => "UNKNOWN", "value_uint_or_null" => nil}
    end
  end
  source_frame = observation == "EXACT_IMPORTED" ? frame_reference(9) : nil
  {
    "subject_scope_id" => scope,
    "reporter_scope_id" => scope,
    "observation_enum" => observation,
    "source_frame_or_null" => source_frame,
    "through_transition_count_uint" => through,
    "entries_exact_catalog_order" => entries
  }
end

def derive_cut(data)
  runtime = data.fetch("observer_runtime_admission_cut")
  frame = data.fetch("pre_spawn_frame_cut")
  holds = data.fetch("outer_capture_preholds")
  timebase = data.fetch("outer_interval_timebase")
  start_rt = data.fetch("outer_interval_start_realtime")
  end_rt = data.fetch("outer_interval_end_realtime")
  interval_error = data.fetch("outer_interval_error")
  return nil unless data.fetch("controller_process_state_enum") == "NOT_ATTEMPTED"
  return nil unless data.fetch("outer_interval_state_enum") == "UNAVAILABLE"
  return nil unless end_rt.fetch("state_enum") == "NOT_SAMPLED"
  return nil if interval_error.fetch("state_enum") == "NONE"
  return [0, "ADMISSION_FAILED"] unless runtime.fetch("matches_contract_bool")
  return [1, "ADMISSION_FAILED"] unless frame.fetch("complete_bool")
  return [2, "CAPTURE_PREHOLD_FAILED"] if holds[0].fetch("state_enum") == "AMBIGUOUS" && holds[1].fetch("state_enum") == "CLEAN_UNSPENT"
  return [3, "CAPTURE_PREHOLD_FAILED"] if holds[0].fetch("state_enum") == "HELD" && holds[1].fetch("state_enum") == "AMBIGUOUS"
  return nil unless holds.all? { |h| h.fetch("state_enum") == "HELD" }
  if timebase.fetch("state_enum") == "NOT_SAMPLED" && start_rt.fetch("state_enum") == "NOT_SAMPLED"
    return [4, "PRETIMING_CLASSIFIED"]
  end
  return [5, "INITIAL_TIMEBASE_FAILED"] if timebase.fetch("state_enum") == "CALL_FAILED" && interval_error == timebase.fetch("error")
  return [6, "INITIAL_TIMEBASE_FAILED"] if timebase.fetch("state_enum") == "ZERO_FIELD" && interval_error == timebase.fetch("error")
  return [7, "REALTIME_START_FAILED"] if start_rt.fetch("state_enum") == "CALL_FAILED" && interval_error == start_rt.fetch("error")
  return [8, "REALTIME_START_FAILED"] if start_rt.fetch("state_enum") == "INVALID" && interval_error == start_rt.fetch("error")
  nil
end

def cut_candidate_data(fixture_id)
  timing = S.fetch("timing_conformance_catalog_v12")
  row = timing.fetch("fixtures").find { |f| f.fetch("fixture_id") == fixture_id }
  decoded = JSON.parse(Base64.strict_decode64(row.fetch("canonical_json_base64")))
  decoded.fetch("data")
end

CUT_FIXTURE_IDS = %w[
  OUTER_CUT_RUNTIME_ADMISSION_FAILED
  OUTER_CUT_FRAME_ADMISSION_FAILED
  OUTER_CUT_STDOUT_PREHOLD_FAILED
  OUTER_CUT_STDERR_PREHOLD_FAILED
  OUTER_CUT_PRETIMING
  OUTER_CUT_TIMEBASE_FAILED
  OUTER_CUT_TIMEBASE_ZERO_FIELD
  OUTER_CUT_REALTIME_FAILED
  OUTER_CUT_REALTIME_INVALID
].freeze

def workspace_for(process_state, cut_data = nil)
  branch_rows = D.dig("custom_operator_programs_v12", "OUTER_PUBLICATION_ENDPOINT_PROGRAM", "endpoint_branch_rows_exact")
  derived = cut_data && derive_cut(cut_data)
  branch = if process_state == "NOT_ATTEMPTED"
    branch_rows.find { |row| row[2] == derived&.fetch(0) }
  else
    branch_rows.find { |row| row[1] == process_state }
  end
  raise "no endpoint branch for #{process_state}/#{derived.inspect}" unless branch

  if cut_data
    runtime = runtime_admission(
      cut_data.dig("observer_runtime_admission_cut", "matches_contract_bool"),
      cut_data.dig("observer_runtime_admission_cut", "error")
    )
    frames = frame_set(cut_data.fetch("pre_spawn_frame_cut"))
    cut_holds = clone(cut_data.fetch("outer_capture_preholds"))
    interval = interval_from_cut(cut_data)
  else
    runtime = runtime_admission(true, error_none)
    frames = frame_set({"observed_count_uint" => 3, "complete_bool" => true, "error" => error_none})
    out_path = "/private/tmp/v12-outer-stdout.bin"
    err_path = "/private/tmp/v12-outer-stderr.bin"
    cut_holds = [
      {"label" => "OUTER_STDOUT", "path" => out_path, "state_enum" => "HELD", "error" => error_none},
      {"label" => "OUTER_STDERR", "path" => err_path, "state_enum" => "HELD", "error" => error_none}
    ]
    interval = process_state == "WAIT_FAILED" ? start_only_interval : complete_interval
  end

  continuity_rows = cut_holds.each_with_index.map { |hold, i| continuity(hold, branch.fetch(5).fetch(i)) }
  process = process_observation(process_state)
  outer_context = {
    "observer_runtime_admission" => runtime,
    "outer_capture_continuity" => continuity_rows,
    "controller_process" => process
  }
  mask = branch.fetch(3).chars
  receipts = OUTER_TRANSITIONS.each_with_index.map do |transition_id, i|
    receipt(i, transition_id, mask.fetch(i) == "E", outer_context)
  end
  counters = D.fetch("counter_catalog").keys.map do |scope|
    if scope == "OUTER_PROCESS"
      counter_snapshot(scope, branch.fetch(4))
    else
      counter_snapshot(scope, Array.new(D.fetch("counter_catalog").fetch(scope).length, 0))
    end
  end
  complete_capture = cut_holds.map { |h| h.fetch("state_enum") == "HELD" }
  {
    "observer_runtime_admission" => runtime,
    "pre_spawn_checkpoint_readiness_binding" => frames,
    "outer_stdout_admission" => capture_admission(cut_holds[0].fetch("label"), cut_holds[0].fetch("path"), complete_capture[0]),
    "outer_stderr_admission" => capture_admission(cut_holds[1].fetch("label"), cut_holds[1].fetch("path"), complete_capture[1]),
    "controller_process" => process,
    "outer_capture_preholds" => cut_holds,
    "outer_interval" => interval,
    "outer_capture_continuity" => continuity_rows,
    "transition_receipts" => receipts,
    "counter_snapshots" => counters
  }
end

def project_cut_input(workspace)
  rows = S.dig("outer_not_attempted_cut_projection_v12", "rows_exact")
  data = {
    "controller_process_state_enum" => nil,
    "observer_runtime_admission_cut" => {"matches_contract_bool" => nil, "error" => nil},
    "pre_spawn_frame_cut" => {"observed_count_uint" => nil, "complete_bool" => nil, "error" => nil},
    "outer_capture_preholds" => [
      {"label" => nil, "path" => nil, "state_enum" => nil, "error" => nil},
      {"label" => nil, "path" => nil, "state_enum" => nil, "error" => nil}
    ],
    "outer_interval_state_enum" => nil,
    "outer_interval_timebase" => nil,
    "outer_interval_start_realtime" => nil,
    "outer_interval_end_realtime" => nil,
    "outer_interval_error" => nil
  }
  rows.each do |source_pointer, target_pointer, _type|
    target_tokens = target_pointer.split("/")[1..]
    cursor = data
    target_tokens[0...-1].each { |token| cursor = cursor[token.match?(/\A\d+\z/) ? token.to_i : token] }
    last = target_tokens.last
    cursor[last.match?(/\A\d+\z/) ? last.to_i : last] = clone(pointer_get(workspace, source_pointer))
  end
  state = workspace.dig("controller_process", "state_enum")
  {"controller_process_state_enum" => state, "cut_data_or_null" => state == "NOT_ATTEMPTED" ? data : nil}
end

def project_endpoint_input(workspace)
  cut_input = project_cut_input(workspace)
  snapshot = workspace.fetch("counter_snapshots").find do |row|
    row.fetch("subject_scope_id") == "OUTER_PROCESS" &&
      row.fetch("reporter_scope_id") == "OUTER_PROCESS" &&
      row.fetch("observation_enum") == "EXACT_SELF"
  end
  {
    "observer_runtime_admission" => clone(workspace.fetch("observer_runtime_admission")),
    "outer_stdout_admission" => clone(workspace.fetch("outer_stdout_admission")),
    "outer_stderr_admission" => clone(workspace.fetch("outer_stderr_admission")),
    "controller_process" => clone(workspace.fetch("controller_process")),
    "not_attempted_cut_data_or_null" => clone(cut_input.fetch("cut_data_or_null")),
    "outer_capture_continuity" => clone(workspace.fetch("outer_capture_continuity")),
    "transition_receipts" => clone(workspace.fetch("transition_receipts")),
    "outer_process_counter_snapshot" => clone(snapshot),
    "projection_complete_bool" => true,
    "error" => error_none
  }
end

def staging_admission(profile)
  suffix = {
    "START_RECORD" => "start1234",
    "PREFIX_RESULT" => "prefx123",
    "OUTER_OBSERVATION" => "outer123"
  }.fetch(profile)
  path = "/private/tmp/.v12-#{suffix}"
  v = vnode("REGULAR", 4500 + %w[START_RECORD PREFIX_RESULT OUTER_OBSERVATION].index(profile))
  {
    "profile_enum" => profile,
    "template_before_call" => "#{path[0...-8]}XXXXXXXX",
    "staging_name_after_call" => inventory_name(File.basename(path)),
    "suffix_length_uint" => 8,
    "mkostempsat_flags_uint" => 16_777_216,
    "mkostempsat_entered_bool" => true,
    "returned_fd_int" => 11,
    "returned_fd_flags_int" => 1,
    "returned_fd_cloexec_bool" => true,
    "slot_after_create" => artifact_slot(path, true, v),
    "held_vnode_after_create" => clone(v),
    "named_vnode_after_create" => clone(v),
    "held_identity" => vnode_identity(v),
    "complete_bool" => true,
    "error" => error_none
  }
end

def publication_receipt(kind, staging, entered = true)
  transition_id, predicate_id, sequence, from_state, to_state = case kind
  when "START"
    ["TR_BUILD_EPOCH_START_STAGING_CREATED", "ST_START_STAGING_CREATED_AND_EPOCH_CONSUMED", 1, "AVAILABLE", "CONSUMED"]
  when "PREFIX"
    ["TR_PREFIX_STAGING_CREATED", "PX_STAGING_CREATED_AND_BODY_CANONICAL", 0, "UNCREATED", "CREATED"]
  else
    raise "no publication receipt for #{kind}"
  end
  body_key = kind == "START" ? "start_publication_staging_admission" : "prefix_publication_staging_admission"
  source = {body_key => staging}
  trigger = predicate_evaluation(predicate_id, source)
  trigger = clone(trigger)
  unless entered
    trigger["state_enum"] = "FALSE"
    trigger["assertion_result"] = eval_bool(false)
  end
  {
    "sequence_uint" => sequence,
    "transition_id" => transition_id,
    "source_instance_json_pointer_or_null" => "/#{body_key}",
    "source_instance_complete_json_sha256_or_null" => sha(staging),
    "state_enum" => entered ? "ENTERED" : "NOT_ENTERED",
    "from_state_enum" => from_state,
    "to_state_enum_or_null" => entered ? to_state : nil,
    "trigger_evaluation" => trigger,
    "guard_evaluations" => [],
    "counter_deltas_applied" => [],
    "error" => error_none
  }
end

def generic_transition_receipt(sequence, transition_id, entered)
  definition = D.fetch("transition_definitions_v12").find { |row| row.fetch("transition_id") == transition_id }
  trigger = custom_predicate_evaluation(definition.fetch("trigger_predicate_id"), entered)
  {
    "sequence_uint" => sequence,
    "transition_id" => transition_id,
    "source_instance_json_pointer_or_null" => nil,
    "source_instance_complete_json_sha256_or_null" => nil,
    "state_enum" => entered ? "ENTERED" : "NOT_ENTERED",
    "from_state_enum" => definition.fetch("from_state_enum"),
    "to_state_enum_or_null" => entered ? definition.fetch("to_state_enum") : nil,
    "trigger_evaluation" => trigger,
    "guard_evaluations" => definition.fetch("guard_conditions_all").map do |guard|
      custom_predicate_evaluation(guard.fetch("predicate_id"), true)
    end,
    "counter_deltas_applied" => entered ? clone(definition.fetch("counter_deltas")) : [],
    "error" => error_none
  }
end

def predicate_array(scope, selected)
  catalog = D.fetch("predicate_catalogs_v12").fetch(scope)
  ids = catalog.fetch("base_exact_order") + catalog.fetch("aggregates_exact_order").map { |row| row.fetch("predicate_id") }
  ids.map { |id| id == selected.fetch("predicate_id") ? clone(selected) : custom_predicate_evaluation(id, false) }
end

SCHEMA_BY_KIND = {
  "START" => "ergentics.r19.nl.crs6.supervisor-build-owner.start.v12",
  "PREFIX" => "ergentics.r19.nl.crs6.supervisor-build-owner.prefix-result.v12",
  "OUTER" => "ergentics.r19.nl.crs6.supervisor-build-owner.outer-observation.v12"
}.freeze

PROFILE_BY_KIND = {
  "START" => "START_RECORD", "PREFIX" => "PREFIX_RESULT", "OUTER" => "OUTER_OBSERVATION"
}.freeze

PREDICATE_BY_KIND = {
  "START" => "ST_START_STAGING_CREATED_AND_EPOCH_CONSUMED",
  "PREFIX" => "PX_STAGING_CREATED_AND_BODY_CANONICAL",
  "OUTER" => "OUT_PUBLICATION_ENDPOINT_VALID"
}.freeze

def publication_source(kind, status, endpoint = nil, ordinal = 0)
  staging = staging_admission(PROFILE_BY_KIND.fetch(kind))
  predicate = if kind == "OUTER"
    custom_predicate_evaluation(PREDICATE_BY_KIND.fetch(kind), true)
  else
    body_key = kind == "START" ? "start_publication_staging_admission" : "prefix_publication_staging_admission"
    predicate_evaluation(PREDICATE_BY_KIND.fetch(kind), {body_key => staging})
  end
  receipt_value = %w[START PREFIX].include?(kind) ? publication_receipt(kind, staging) : nil
  predicates = predicate_array(kind, predicate)
  receipts = case kind
  when "START"
    [generic_transition_receipt(0, "TR_CONTROLLER_SELF_ENTRY_PROVED", true), receipt_value]
  when "PREFIX"
    [receipt_value,
     generic_transition_receipt(1, "TR_PREFIX_EXIT0_INTENT_SELECTED", status == "PASS_PREFIX_CANDIDATE"),
     generic_transition_receipt(2, "TR_PREFIX_EXIT70_INTENT_SELECTED", status == "FAIL_PREFIX_CANDIDATE")]
  else
    nil
  end
  body = {
    "sentinel_id" => "#{kind}_PUBLICATION_FRAME_CONFORMANCE",
    "ordinal_uint" => ordinal,
    "padding_base64" => ""
  }
  if kind == "START"
    {"staging_admission" => staging, "predicate_evaluations" => predicates,
     "transition_receipts" => receipts, "candidate_schema" => SCHEMA_BY_KIND.fetch(kind),
     "candidate_status_enum" => status, "candidate_body" => body}
  elsif kind == "PREFIX"
    {"staging_admission" => staging, "predicate_evaluations" => predicates,
     "transition_receipts" => receipts, "candidate_schema" => SCHEMA_BY_KIND.fetch(kind),
     "candidate_status_enum" => status, "candidate_body" => body}
  else
    {"staging_admission" => staging, "retained_endpoint" => clone(endpoint),
     "predicate_evaluations" => predicates, "candidate_schema" => SCHEMA_BY_KIND.fetch(kind),
     "candidate_status_enum" => status, "candidate_body" => body}
  end
end

def publication_input_from_source(source)
  kind = if source.key?("retained_endpoint")
    "OUTER"
  elsif source.fetch("candidate_schema") == SCHEMA_BY_KIND.fetch("START")
    "START"
  else
    "PREFIX"
  end
  predigest_object = {
    "schema" => source.fetch("candidate_schema"),
    "status" => source.fetch("candidate_status_enum"),
    "body" => clone(source.fetch("candidate_body"))
  }
  predigest = canon(predigest_object)
  payload = sha(predigest)
  complete_object = predigest_object.merge("payload_sha256" => payload)
  complete = canon(complete_object) + "\n"
  common = {
    "staging_admission" => clone(source.fetch("staging_admission")),
    "candidate_status_enum" => source.fetch("candidate_status_enum"),
    "candidate_predigest_canonical_json_base64" => Base64.strict_encode64(predigest),
    "candidate_predigest_bytes_uint" => predigest.bytesize,
    "candidate_predigest_sha256" => payload,
    "candidate_complete_frame_with_lf_base64" => Base64.strict_encode64(complete),
    "candidate_complete_frame_bytes_uint" => complete.bytesize,
    "candidate_complete_frame_with_lf_sha256" => sha(complete),
    "projection_complete_bool" => true,
    "error" => error_none
  }
  tail = lambda do
    {
      "candidate_status_enum" => common.fetch("candidate_status_enum"),
      "candidate_predigest_canonical_json_base64" => common.fetch("candidate_predigest_canonical_json_base64"),
      "candidate_predigest_bytes_uint" => common.fetch("candidate_predigest_bytes_uint"),
      "candidate_predigest_sha256" => common.fetch("candidate_predigest_sha256"),
      "candidate_complete_frame_with_lf_base64" => common.fetch("candidate_complete_frame_with_lf_base64"),
      "candidate_complete_frame_bytes_uint" => common.fetch("candidate_complete_frame_bytes_uint"),
      "candidate_complete_frame_with_lf_sha256" => common.fetch("candidate_complete_frame_with_lf_sha256"),
      "projection_complete_bool" => common.fetch("projection_complete_bool"),
      "error" => common.fetch("error")
    }
  end
  if kind == "START"
    result = {
      "staging_admission" => common["staging_admission"],
      "staging_predicate_evaluation" => clone(source.fetch("predicate_evaluations").find { |row| row.fetch("predicate_id") == PREDICATE_BY_KIND.fetch(kind) }),
      "staging_transition_receipt" => clone(source.fetch("transition_receipts").find { |row| row.fetch("sequence_uint") == 1 && row.fetch("transition_id") == "TR_BUILD_EPOCH_START_STAGING_CREATED" })
    }
    tail.call.each { |key, value| result[key] = value }
    result
  elsif kind == "PREFIX"
    result = {
      "staging_admission" => common["staging_admission"],
      "staging_predicate_evaluation" => clone(source.fetch("predicate_evaluations").find { |row| row.fetch("predicate_id") == PREDICATE_BY_KIND.fetch(kind) }),
      "staging_transition_receipt" => clone(source.fetch("transition_receipts").find { |row| row.fetch("sequence_uint") == 0 && row.fetch("transition_id") == "TR_PREFIX_STAGING_CREATED" })
    }
    tail.call.each { |key, value| result[key] = value }
    result
  else
    result = {
      "staging_admission" => common["staging_admission"],
      "endpoint_input" => clone(source.fetch("retained_endpoint")),
      "endpoint_predicate_evaluation" => clone(source.fetch("predicate_evaluations").find { |row| row.fetch("predicate_id") == PREDICATE_BY_KIND.fetch(kind) })
    }
    tail.call.each { |key, value| result[key] = value }
    result
  end
end

def json_pointer_set(root, pointer, value)
  tokens = pointer.split("/")[1..].map { |token| token.gsub("~1", "/").gsub("~0", "~") }
  cursor = root
  tokens[0...-1].each { |token| cursor = cursor.is_a?(Array) ? cursor.fetch(Integer(token, 10)) : cursor.fetch(token) }
  last = tokens.last
  cursor.is_a?(Array) ? cursor[Integer(last, 10)] = clone(value) : cursor[last] = clone(value)
end

def mutation_descriptor(base, changes)
  members = changes.map do |pointer, (descriptor, replacement)|
    old = pointer_get(base, pointer)
    replacement_bytes = canon(replacement)
    {
      "target_enum" => "PROJECTED_INPUT",
      "json_pointer" => pointer,
      "expected_type_descriptor" => descriptor,
      "expected_old_value_sha256" => sha(old),
      "replacement_type_descriptor" => descriptor,
      "replacement_canonical_json_base64" => Base64.strict_encode64(replacement_bytes),
      "replacement_bytes_uint" => replacement_bytes.bytesize,
      "replacement_sha256" => sha(replacement_bytes)
    }
  end.sort_by { |row| row.fetch("json_pointer") }
  {"members" => members}
end

def context_cap_mutation(old_cap, replacement_cap)
  replacement_bytes = canon(replacement_cap)
  {
    "members" => [{
      "target_enum" => "EVALUATOR_CONTEXT",
      "json_pointer" => "/maximum_bytes_uint",
      "expected_type_descriptor" => "U",
      "expected_old_value_sha256" => sha(old_cap),
      "replacement_type_descriptor" => "U",
      "replacement_canonical_json_base64" => Base64.strict_encode64(replacement_bytes),
      "replacement_bytes_uint" => replacement_bytes.bytesize,
      "replacement_sha256" => sha(replacement_bytes)
    }]
  }
end

def apply_input_mutation(base, descriptor)
  result = clone(base)
  descriptor.fetch("members").each do |member|
    next unless member.fetch("target_enum") == "PROJECTED_INPUT"
    old = pointer_get(result, member.fetch("json_pointer"))
    raise "mutation old hash mismatch" unless sha(old) == member.fetch("expected_old_value_sha256")
    replacement_bytes = Base64.strict_decode64(member.fetch("replacement_canonical_json_base64"))
    raise "mutation replacement length mismatch" unless replacement_bytes.bytesize == member.fetch("replacement_bytes_uint")
    raise "mutation replacement hash mismatch" unless sha(replacement_bytes) == member.fetch("replacement_sha256")
    replacement = JSON.parse(replacement_bytes)
    json_pointer_set(result, member.fetch("json_pointer"), replacement)
  end
  result
end

def evaluate_cut(input)
  state = input.fetch("controller_process_state_enum")
  data = input.fetch("cut_data_or_null")
  return false unless state == "NOT_ATTEMPTED"
  !data.nil? && data.fetch("controller_process_state_enum") == "NOT_ATTEMPTED" && !derive_cut(data).nil?
rescue KeyError, TypeError
  false
end

def expected_endpoint_branch(input)
  state = input.dig("controller_process", "state_enum")
  rows = D.dig("custom_operator_programs_v12", "OUTER_PUBLICATION_ENDPOINT_PROGRAM", "endpoint_branch_rows_exact")
  if state == "NOT_ATTEMPTED"
    data = input["not_attempted_cut_data_or_null"]
    derived = data && derive_cut(data)
    return nil unless derived
    rows.find { |row| row[2] == derived[0] }
  else
    rows.find { |row| row[1] == state }
  end
end

def endpoint_capture_complete?(capture)
  capture.dig("slot", "final_state_enum") == "PRESENT_REGULAR" &&
    capture.dig("content", "presence_enum") == "PRESENT" &&
    capture.dig("content", "read_enum") == "COMPLETE" &&
    capture.dig("content", "join_enum") == "JOINED"
end

def evaluate_endpoint(input)
  return false unless input.fetch("projection_complete_bool") == true && input.dig("error", "state_enum") == "NONE"
  branch = expected_endpoint_branch(input)
  return false unless branch
  state = input.dig("controller_process", "state_enum")
  cut = input.fetch("not_attempted_cut_data_or_null")
  return false if state == "NOT_ATTEMPTED" && cut.nil?
  return false if state != "NOT_ATTEMPTED" && !cut.nil?

  continuity_rows = input.fetch("outer_capture_continuity")
  return false unless continuity_rows.map { |row| row.fetch("continuity_state_enum") } == branch.fetch(5)
  return false unless continuity_rows.map { |row| row.dig("pre_spawn_hold", "state_enum") } == branch.fetch(6)
  continuity_rows.each_with_index do |row, index|
    capture = index.zero? ? input.fetch("outer_stdout_admission") : input.fetch("outer_stderr_admission")
    return false unless row.fetch("label") == capture.fetch("label") && row.fetch("path") == capture.fetch("path")
  end
  needs_complete_capture = state != "NOT_ATTEMPTED" || (branch.fetch(2) && branch.fetch(2) >= 4)
  if needs_complete_capture
    return false unless endpoint_capture_complete?(input.fetch("outer_stdout_admission"))
    return false unless endpoint_capture_complete?(input.fetch("outer_stderr_admission"))
  end

  context = {
    "observer_runtime_admission" => input.fetch("observer_runtime_admission"),
    "outer_capture_continuity" => continuity_rows,
    "controller_process" => input.fetch("controller_process")
  }
  expected_receipts = OUTER_TRANSITIONS.each_with_index.map do |transition_id, index|
    receipt(index, transition_id, branch.fetch(3).chars.fetch(index) == "E", context)
  end
  return false unless input.fetch("transition_receipts") == expected_receipts

  expected_snapshot = counter_snapshot("OUTER_PROCESS", branch.fetch(4))
  return false unless input.fetch("outer_process_counter_snapshot") == expected_snapshot
  true
rescue KeyError, TypeError, ArgumentError
  false
end

def strict_json_from_b64(text)
  bytes = Base64.strict_decode64(text)
  value = JSON.parse(bytes)
  return [nil, nil] unless canon(value) == bytes
  [value, bytes]
rescue ArgumentError, JSON::ParserError
  [nil, nil]
end

def publication_cap(kind)
  profile = PROFILE_BY_KIND.fetch(kind)
  row = S.dig("set_profile_registry_v12", "publication_staging", "rows_exact").find { |candidate| candidate[0] == profile }
  row.fetch(13)
end

def evaluate_publication(kind, input, source, context_cap_override = nil)
  profile = PROFILE_BY_KIND.fetch(kind)
  return false unless input.fetch("projection_complete_bool") == true && input.dig("error", "state_enum") == "NONE"
  return false unless input.dig("staging_admission", "profile_enum") == profile
  return false unless input.dig("staging_admission", "complete_bool") == true
  predicate_key = kind == "OUTER" ? "endpoint_predicate_evaluation" : "staging_predicate_evaluation"
  predicate = input.fetch(predicate_key)
  return false unless predicate.fetch("predicate_id") == PREDICATE_BY_KIND.fetch(kind)
  return false unless predicate.fetch("state_enum") == "TRUE"
  if %w[START PREFIX].include?(kind)
    receipt_value = input.fetch("staging_transition_receipt")
    expected_transition = kind == "START" ? "TR_BUILD_EPOCH_START_STAGING_CREATED" : "TR_PREFIX_STAGING_CREATED"
    expected_sequence = kind == "START" ? 1 : 0
    return false unless receipt_value.fetch("transition_id") == expected_transition
    return false unless receipt_value.fetch("sequence_uint") == expected_sequence
    return false unless receipt_value.fetch("state_enum") == "ENTERED"
    return false unless receipt_value.fetch("source_instance_complete_json_sha256_or_null") == sha(input.fetch("staging_admission"))
  else
    return false unless evaluate_endpoint(input.fetch("endpoint_input"))
    return false unless source.fetch("retained_endpoint") == input.fetch("endpoint_input")
  end

  status = input.fetch("candidate_status_enum")
  allowed = D.dig("custom_operator_programs_v12", "#{kind}_PUBLICATION_PROGRAM", "allowed_statuses_exact")
  if kind == "OUTER"
    process_state = input.dig("endpoint_input", "controller_process", "state_enum")
    allowed = D.dig("custom_operator_programs_v12", "OUTER_PUBLICATION_PROGRAM", "status_compatibility_by_process_state_exact", process_state) || []
  end
  return false unless allowed.include?(status)

  predigest_object, predigest_bytes = strict_json_from_b64(input.fetch("candidate_predigest_canonical_json_base64"))
  return false unless predigest_object && predigest_bytes
  return false unless predigest_object.keys == %w[schema status body]
  return false unless predigest_bytes.bytesize == input.fetch("candidate_predigest_bytes_uint")
  return false unless sha(predigest_bytes) == input.fetch("candidate_predigest_sha256")
  return false unless predigest_object.fetch("schema") == SCHEMA_BY_KIND.fetch(kind)
  return false unless predigest_object.fetch("status") == status
  return false unless predigest_object.fetch("body") == source.fetch("candidate_body")

  complete_bytes = Base64.strict_decode64(input.fetch("candidate_complete_frame_with_lf_base64"))
  return false unless complete_bytes.end_with?("\n") && complete_bytes.count("\n") == 1
  return false unless complete_bytes.bytesize == input.fetch("candidate_complete_frame_bytes_uint")
  return false unless sha(complete_bytes) == input.fetch("candidate_complete_frame_with_lf_sha256")
  cap = context_cap_override || publication_cap(kind)
  return false unless complete_bytes.bytesize <= cap
  complete_json = complete_bytes.delete_suffix("\n")
  complete_object = JSON.parse(complete_json)
  return false unless canon(complete_object) == complete_json
  return false unless complete_object.keys == %w[schema status body payload_sha256]
  return false unless complete_object.fetch("schema") == predigest_object.fetch("schema")
  return false unless complete_object.fetch("status") == predigest_object.fetch("status")
  return false unless complete_object.fetch("body") == predigest_object.fetch("body")
  return false unless complete_object.fetch("payload_sha256") == sha(predigest_bytes)
  true
rescue KeyError, TypeError, ArgumentError, JSON::ParserError
  false
end

def frame_field_changes(input, schema:, status:, body:)
  predigest_object = {"schema" => schema, "status" => status, "body" => clone(body)}
  predigest = canon(predigest_object)
  payload = sha(predigest)
  complete = canon(predigest_object.merge("payload_sha256" => payload)) + "\n"
  {
    "/candidate_predigest_canonical_json_base64" => ["B64", Base64.strict_encode64(predigest)],
    "/candidate_predigest_bytes_uint" => ["U", predigest.bytesize],
    "/candidate_predigest_sha256" => ["H64", payload],
    "/candidate_complete_frame_with_lf_base64" => ["B64", Base64.strict_encode64(complete)],
    "/candidate_complete_frame_bytes_uint" => ["U", complete.bytesize],
    "/candidate_complete_frame_with_lf_sha256" => ["H64", sha(complete)]
  }
end

# Conformance-only source carriers stay acyclic: the frame body is scalar-only,
# while the production selectors are exercised against full fixed-size arrays.
R["PublicationConformanceBodySentinelV12"] = {
  "keys" => ["sentinel_id", "ordinal_uint", "padding_base64"],
  "field_types_exact" => {"sentinel_id" => "S", "ordinal_uint" => "U", "padding_base64" => "B64"},
  "rule" => "CONFORMANCE_ONLY_SCALAR_BODY;FORBIDS_RECORD_BODY_EvidenceSourceV12_ControlConformanceReceiptV12_CATALOG_DIGESTS_AND_NESTED_ARBITRARY_JSON;NEVER_A_PRODUCTION_RECORD_BODY"
}
R["StartPublicationConformanceSourceV12"] = {
  "keys" => ["staging_admission", "predicate_evaluations", "transition_receipts", "candidate_schema", "candidate_status_enum", "candidate_body"],
  "field_types_exact" => {
    "staging_admission" => "REF(PublicationStagingAdmissionV12)",
    "predicate_evaluations" => "ARRAY(PredicateEvaluationV12,11,11,StartPredicateOrderV12)",
    "transition_receipts" => "ARRAY(TransitionReceiptV12,2,2,TransitionSequenceOrderV12)",
    "candidate_schema" => "S", "candidate_status_enum" => "ENUM(StartStatusV12)",
    "candidate_body" => "REF(PublicationConformanceBodySentinelV12)"
  },
  "rule" => "CONFORMANCE_ONLY_SINGLE_IMMUTABLE_SOURCE;EXERCISES_THE_EXACT_PRODUCTION_STAGING_PREDICATE_RECEIPT_STATUS_AND_FRAME_PROJECTION_SELECTORS_WITH_A_SCALAR_NONPRODUCTION_BODY"
}
R["PrefixPublicationConformanceSourceV12"] = {
  "keys" => ["staging_admission", "predicate_evaluations", "transition_receipts", "candidate_schema", "candidate_status_enum", "candidate_body"],
  "field_types_exact" => {
    "staging_admission" => "REF(PublicationStagingAdmissionV12)",
    "predicate_evaluations" => "ARRAY(PredicateEvaluationV12,10,10,PrefixPredicateOrderV12)",
    "transition_receipts" => "ARRAY(TransitionReceiptV12,3,3,TransitionSequenceOrderV12)",
    "candidate_schema" => "S", "candidate_status_enum" => "ENUM(PrefixStatusV12)",
    "candidate_body" => "REF(PublicationConformanceBodySentinelV12)"
  },
  "rule" => "CONFORMANCE_ONLY_SINGLE_IMMUTABLE_SOURCE;EXERCISES_THE_EXACT_PRODUCTION_STAGING_PREDICATE_RECEIPT_STATUS_AND_FRAME_PROJECTION_SELECTORS_WITH_A_SCALAR_NONPRODUCTION_BODY"
}
R["OuterPublicationConformanceSourceV12"] = {
  "keys" => ["staging_admission", "retained_endpoint", "predicate_evaluations", "candidate_schema", "candidate_status_enum", "candidate_body"],
  "field_types_exact" => {
    "staging_admission" => "REF(PublicationStagingAdmissionV12)",
    "retained_endpoint" => "REF(OuterPublicationEndpointInputV12)",
    "predicate_evaluations" => "ARRAY(PredicateEvaluationV12,18,18,OuterPredicateOrderV12)",
    "candidate_schema" => "S", "candidate_status_enum" => "ENUM(OuterStatusV12)",
    "candidate_body" => "REF(PublicationConformanceBodySentinelV12)"
  },
  "rule" => "CONFORMANCE_ONLY_SINGLE_IMMUTABLE_SOURCE;EXERCISES_THE_EXACT_PRODUCTION_STAGING_RETAINED_ENDPOINT_PREDICATE_STATUS_AND_FRAME_PROJECTION_SELECTORS_WITH_A_SCALAR_NONPRODUCTION_BODY"
}
R["CustomOperatorProjectionMutationMemberV12"] = {
  "keys" => ["target_enum", "json_pointer", "expected_type_descriptor", "expected_old_value_sha256", "replacement_type_descriptor", "replacement_canonical_json_base64", "replacement_bytes_uint", "replacement_sha256"],
  "target_states_exact" => ["PROJECTED_INPUT", "EVALUATOR_CONTEXT"],
  "field_types_exact" => {
    "target_enum" => "LOCAL_ENUM(target_states_exact)", "json_pointer" => "S",
    "expected_type_descriptor" => "S", "expected_old_value_sha256" => "H64",
    "replacement_type_descriptor" => "S", "replacement_canonical_json_base64" => "B64",
    "replacement_bytes_uint" => "U", "replacement_sha256" => "H64"
  },
  "rule" => "STRICT_DECODE_LENGTH_HASH_CANONICAL_JSON_AND_EXACT_TYPE;OLD_HASH_MUST_MATCH_BEFORE_SIMULTANEOUS_REPLACEMENT;EVALUATOR_CONTEXT_MAY_TARGET_ONLY_/maximum_bytes_uint_AND_NEVER_MUTATES_HELD_CONTROL"
}
R["CustomOperatorProjectionMutationV12"] = {
  "keys" => ["members"],
  "field_types_exact" => {"members" => "ARRAY(CustomOperatorProjectionMutationMemberV12,1,16,MutationPointerOrderV12)"},
  "rule" => "CONFORMANCE_ONLY_SIMULTANEOUS_REPLACEMENTS;DISTINCT_ASCII_SORTED_POINTERS_WITH_NO_ANCESTOR_DESCENDANT_OVERLAP;NO_DELETE_INSERT_COERCE_OR_REPAIR;PRODUCTION_MATERIALIZATION_IS_UNCHANGED"
}

D["custom_operator_conformance_projection_replay_v12"] = {
  "reserved_binding_ids_exact_order" => ["MATERIALIZATION_MUTATION", "NORMALIZED_INPUT", "SOURCE_INSTANCE"],
  "source_rows_exact" => [
    ["OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED", "OuterPublicationEndpointWorkspaceV12", "OUTER_PRESTAGING_WORKSPACE", "PROJECT_OUTER_NOT_ATTEMPTED_CUT_INPUT"],
    ["OUTER_PUBLICATION_ENDPOINT_VALID", "OuterPublicationEndpointWorkspaceV12", "OUTER_PRESTAGING_WORKSPACE", "PROJECT_OUTER_PUBLICATION_ENDPOINT_INPUT"],
    ["START_PUBLICATION_VALID", "StartPublicationConformanceSourceV12", "CONFORMANCE_POSTSTATUS_CANDIDATE", "PROJECT_START_PUBLICATION_INPUT"],
    ["PREFIX_PUBLICATION_VALID", "PrefixPublicationConformanceSourceV12", "CONFORMANCE_POSTSTATUS_CANDIDATE", "PROJECT_PREFIX_PUBLICATION_INPUT"],
    ["OUTER_PUBLICATION_VALID", "OuterPublicationConformanceSourceV12", "CONFORMANCE_POSTSTATUS_CANDIDATE", "PROJECT_OUTER_PUBLICATION_INPUT"]
  ],
  "value_vector_execution_exact" => [
    "STRICT_DECODE_AND_TYPECHECK_SOURCE_INSTANCE",
    "EXECUTE_THE_EXACT_SOURCE_MATERIALIZER_AND_PRODUCTION_INPUT_PROJECTION",
    "IF_PRESENT_APPLY_MATERIALIZATION_MUTATION_SIMULTANEOUSLY_TO_AN_IMMUTABLE_COPY",
    "REQUIRE_TYPED_DEEP_AND_CANONICAL_BYTE_EQUALITY_WITH_INDEPENDENT_NORMALIZED_INPUT",
    "EXECUTE_THE_TOTAL_OPERATOR_AGAINST_BOTH_REPRESENTATIONS_WITH_SOURCE_CONTEXT_RETAINED",
    "REQUIRE_BOTH_RESULTS_DEEP_EQUAL_EACH_OTHER_AND_expected_result"
  ],
  "resolution_priority_exact" => ["TYPE_ERROR", "UNAVAILABLE", "PROJECTION_OR_MUTATION_MISMATCH_VALUE_FALSE", "TOTAL_PROGRAM_RESULT"],
  "rule" => "EVERY_NEW_VALUE_VECTOR_CARRIES_ONE_SOURCE_INSTANCE_AND_ONE_NORMALIZED_INPUT;MUTATIONS_EXIST_ONLY_IN_CONFORMANCE;PUBLICATION_SENTINEL_SUBSTITUTES_ONLY_FOR_RECORD_BODY_DURING_FRAME_PROJECTION_AND_DECODED_BODY_EQUALITY;ALL_SCHEMA_STATUS_CANONICAL_JSON_PREDIGEST_PAYLOAD_COMPLETE_FRAME_LF_LENGTH_SHA256_CAP_SELECTOR_AND_ENDPOINT_LOGIC_IS_THE_PRODUCTION_LOGIC"
}

fixtures_by_id = CAT.fetch("fixtures").to_h { |row| [row.fetch("fixture_id"), row] }
vectors_by_id = CAT.fetch("vectors").to_h { |row| [row.fetch("vector_id"), row] }
new_set_members = {}

def add_fixture!(fixtures_by_id, id, type_id, value)
  row = fixture(id, type_id, value)
  prior = fixtures_by_id[id]
  raise "fixture id collision #{id}" if prior && prior != row
  fixtures_by_id[id] = row
  id
end

def add_vector!(vectors_by_id, members, row)
  id = row.fetch("vector_id")
  raise "vector id collision #{id}" if vectors_by_id.key?(id)
  vectors_by_id[id] = row
  members << id
end

def add_value_case!(fixtures, vectors, members, id:, operator:, source_type:, source:, input_type:, input:, expected:, mutation: nil)
  source_id = add_fixture!(fixtures, "#{id}_SOURCE", source_type, source)
  input_id = add_fixture!(fixtures, "#{id}_INPUT", input_type, input)
  bindings = [value_binding("NORMALIZED_INPUT", input_id), value_binding("SOURCE_INSTANCE", source_id)]
  if mutation
    mutation_id = add_fixture!(fixtures, "#{id}_MUTATION", "CustomOperatorProjectionMutationV12", mutation)
    bindings.unshift(value_binding("MATERIALIZATION_MUTATION", mutation_id))
  end
  add_vector!(vectors, members, vector(id, operator, bindings, expected))
end

def add_unavailable_case!(fixtures, vectors, members, id:, operator:, source_type:, source:)
  source_id = add_fixture!(fixtures, "#{id}_SOURCE", source_type, source)
  bindings = [unavailable_binding("NORMALIZED_INPUT"), value_binding("SOURCE_INSTANCE", source_id)]
  add_vector!(vectors, members, vector(id, operator, bindings, EVAL_UNAVAILABLE))
end

def add_type_case!(vectors, members, id:, operator:)
  bindings = [type_error_binding("NORMALIZED_INPUT"), type_error_binding("SOURCE_INSTANCE")]
  add_vector!(vectors, members, vector(id, operator, bindings, EVAL_TYPE_ERROR))
end

# CUT: nine exact causal sources, one isolated causal mutation per row, one
# well-typed non-NOT_ATTEMPTED false branch, and the two resolution states.
cut_members = []
cut_sources = CUT_FIXTURE_IDS.map.with_index do |fixture_id, ordinal|
  data = cut_candidate_data(fixture_id)
  workspace = workspace_for("NOT_ATTEMPTED", data)
  input = project_cut_input(workspace)
  id = format("CUT_TRUE_%02d", ordinal)
  add_value_case!(fixtures_by_id, vectors_by_id, cut_members,
    id: id, operator: "OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED",
    source_type: "OuterPublicationEndpointWorkspaceV12", source: workspace,
    input_type: "OuterNotAttemptedCutOperatorInputV12", input: input, expected: EVAL_TRUE)
  [workspace, input]
end

cut_false_changes = [
  {
    "/cut_data_or_null/observer_runtime_admission_cut/matches_contract_bool" => ["B", true],
    "/cut_data_or_null/observer_runtime_admission_cut/error" => ["REF(ErrorV12)", error_none]
  },
  {
    "/cut_data_or_null/pre_spawn_frame_cut/observed_count_uint" => ["U", 3],
    "/cut_data_or_null/pre_spawn_frame_cut/complete_bool" => ["B", true],
    "/cut_data_or_null/pre_spawn_frame_cut/error" => ["REF(ErrorV12)", error_none]
  },
  {
    "/cut_data_or_null/outer_capture_preholds/0/state_enum" => ["ENUM(PreSpawnCaptureHoldStateV12)", "HELD"],
    "/cut_data_or_null/outer_capture_preholds/0/error" => ["REF(ErrorV12)", error_none]
  },
  {
    "/cut_data_or_null/outer_capture_preholds/1/state_enum" => ["ENUM(PreSpawnCaptureHoldStateV12)", "CLEAN_UNSPENT"],
    "/cut_data_or_null/outer_capture_preholds/1/error" => ["REF(ErrorV12)", error_none]
  },
  {"/cut_data_or_null/outer_interval_error" => ["REF(ErrorV12)", error_none]},
  {"/cut_data_or_null/outer_interval_error" => ["REF(ErrorV12)", error_pred("TIMEBASE_ERROR_MISMATCH")]},
  {"/cut_data_or_null/outer_interval_error" => ["REF(ErrorV12)", error_pred("TIMEBASE_ZERO_ERROR_MISMATCH")]},
  {"/cut_data_or_null/outer_interval_error" => ["REF(ErrorV12)", error_pred("REALTIME_ERROR_MISMATCH")]},
  {"/cut_data_or_null/outer_interval_error" => ["REF(ErrorV12)", error_pred("REALTIME_INVALID_ERROR_MISMATCH")]}
]
cut_sources.each_with_index do |(workspace, base), ordinal|
  mutation = mutation_descriptor(base, cut_false_changes.fetch(ordinal))
  mutated = apply_input_mutation(base, mutation)
  raise "cut mutation unexpectedly true #{ordinal}" if evaluate_cut(mutated)
  add_value_case!(fixtures_by_id, vectors_by_id, cut_members,
    id: format("CUT_FALSE_CAUSAL_%02d", ordinal), operator: "OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED",
    source_type: "OuterPublicationEndpointWorkspaceV12", source: workspace,
    input_type: "OuterNotAttemptedCutOperatorInputV12", input: mutated, expected: EVAL_FALSE, mutation: mutation)
end

spawn_workspace = workspace_for("SPAWN_RAISED")
spawn_cut_input = project_cut_input(spawn_workspace)
add_value_case!(fixtures_by_id, vectors_by_id, cut_members,
  id: "CUT_FALSE_OTHER_PROCESS_STATE", operator: "OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED",
  source_type: "OuterPublicationEndpointWorkspaceV12", source: spawn_workspace,
  input_type: "OuterNotAttemptedCutOperatorInputV12", input: spawn_cut_input, expected: EVAL_FALSE)

no_causal_workspace = clone(workspace_for("NOT_ATTEMPTED", cut_candidate_data("OUTER_CUT_PRETIMING")))
no_causal_workspace["outer_capture_preholds"][1]["state_enum"] = "CLEAN_UNSPENT"
no_causal_workspace["outer_capture_preholds"][1]["error"] = error_none
add_unavailable_case!(fixtures_by_id, vectors_by_id, cut_members,
  id: "CUT_UNAVAILABLE_NO_CAUSAL", operator: "OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED",
  source_type: "OuterPublicationEndpointWorkspaceV12", source: no_causal_workspace)
add_type_case!(vectors_by_id, cut_members, id: "CUT_TYPE_ERROR", operator: "OUTER_NOT_ATTEMPTED_CUT_AUTHORIZED")
raise "cut count #{cut_members.length}" unless cut_members.length == 21
new_set_members["OUTER_NOT_ATTEMPTED_CUT_VECTORS"] = cut_members

# ENDPOINT: each of the 12 frozen branch rows has one positive and two
# independent negative axes.  This prevents a branch label from substituting
# for receipts/counters or for the process/cut/capture state.
endpoint_members = []
endpoint_cases = cut_sources.map { |workspace, _| workspace } + [
  workspace_for("SPAWN_RAISED"),
  workspace_for("PID_RETURNED_REAPED_EXIT"),
  workspace_for("PID_RETURNED_REAPED_SIGNAL")
]
endpoint_cases.each_with_index do |workspace, index|
  base = project_endpoint_input(workspace)
  raise "base endpoint false #{index}" unless evaluate_endpoint(base)
  add_value_case!(fixtures_by_id, vectors_by_id, endpoint_members,
    id: format("ENDPOINT_TRUE_%02d", index), operator: "OUTER_PUBLICATION_ENDPOINT_VALID",
    source_type: "OuterPublicationEndpointWorkspaceV12", source: workspace,
    input_type: "OuterPublicationEndpointInputV12", input: base, expected: EVAL_TRUE)

  counter_path = "/outer_process_counter_snapshot/entries_exact_catalog_order/0/value_uint_or_null"
  old_counter = pointer_get(base, counter_path)
  counter_mutation = mutation_descriptor(base, {counter_path => ["U_OR_NULL", old_counter + 1]})
  counter_input = apply_input_mutation(base, counter_mutation)
  raise "counter mutation unexpectedly true #{index}" if evaluate_endpoint(counter_input)
  add_value_case!(fixtures_by_id, vectors_by_id, endpoint_members,
    id: format("ENDPOINT_FALSE_COUNTER_%02d", index), operator: "OUTER_PUBLICATION_ENDPOINT_VALID",
    source_type: "OuterPublicationEndpointWorkspaceV12", source: workspace,
    input_type: "OuterPublicationEndpointInputV12", input: counter_input, expected: EVAL_FALSE,
    mutation: counter_mutation)

  if index < 9
    replacement_index = index < 4 ? 4 : 0
    replacement = clone(project_endpoint_input(endpoint_cases.fetch(replacement_index)).fetch("not_attempted_cut_data_or_null"))
    axis_changes = {"/not_attempted_cut_data_or_null" => ["REF_OR_NULL(OuterNotAttemptedCutDataV12)", replacement]}
  else
    replacement_state = index == 9 ? "PID_RETURNED_REAPED_EXIT" : "SPAWN_RAISED"
    axis_changes = {"/controller_process" => ["REF(ProcessObservationV12)", process_observation(replacement_state)]}
  end
  axis_mutation = mutation_descriptor(base, axis_changes)
  axis_input = apply_input_mutation(base, axis_mutation)
  raise "endpoint axis mutation unexpectedly true #{index}" if evaluate_endpoint(axis_input)
  add_value_case!(fixtures_by_id, vectors_by_id, endpoint_members,
    id: format("ENDPOINT_FALSE_AXIS_%02d", index), operator: "OUTER_PUBLICATION_ENDPOINT_VALID",
    source_type: "OuterPublicationEndpointWorkspaceV12", source: workspace,
    input_type: "OuterPublicationEndpointInputV12", input: axis_input, expected: EVAL_FALSE,
    mutation: axis_mutation)
end
add_unavailable_case!(fixtures_by_id, vectors_by_id, endpoint_members,
  id: "ENDPOINT_UNAVAILABLE_NO_CAUSAL", operator: "OUTER_PUBLICATION_ENDPOINT_VALID",
  source_type: "OuterPublicationEndpointWorkspaceV12", source: no_causal_workspace)
add_type_case!(vectors_by_id, endpoint_members, id: "ENDPOINT_TYPE_ERROR", operator: "OUTER_PUBLICATION_ENDPOINT_VALID")
raise "endpoint count #{endpoint_members.length}" unless endpoint_members.length == 38
new_set_members["OUTER_PUBLICATION_ENDPOINT_VECTORS"] = endpoint_members

def publication_false_cases(kind, source, base, include_status_mismatch: true)
  predicate_key = kind == "OUTER" ? "/endpoint_predicate_evaluation" : "/staging_predicate_evaluation"
  wrong_predicate_id = case kind
  when "START" then "ST_AUTHORITY_ABSTAIN"
  when "PREFIX" then "PX_PASS_CANDIDATE"
  else "OUT_COUNTER_SCOPES_VALID"
  end
  wrong_predicate = custom_predicate_evaluation(wrong_predicate_id, true)
  wrong_profile = ({"START" => "PREFIX_RESULT", "PREFIX" => "START_RECORD", "OUTER" => "PREFIX_RESULT"}).fetch(kind)
  cases = [
    ["PROJECTION_FLAG", {"/projection_complete_bool" => ["B", false]}, nil],
    ["ERROR_NONNONE", {"/error" => ["REF(ErrorV12)", error_pred("PUBLICATION_INPUT_ERROR")]}, nil],
    ["WRONG_STAGING_PROFILE", {"/staging_admission" => ["REF(PublicationStagingAdmissionV12)", staging_admission(wrong_profile)]}, nil],
    ["PREDICATE_MISMATCH", {predicate_key => ["REF(PredicateEvaluationV12)", wrong_predicate]}, nil]
  ]
  if %w[START PREFIX].include?(kind)
    wrong_receipt = kind == "START" ? generic_transition_receipt(1, "TR_PREFIX_EXIT0_INTENT_SELECTED", true) : generic_transition_receipt(0, "TR_CONTROLLER_SELF_ENTRY_PROVED", true)
    cases << ["RECEIPT_MISMATCH", {"/staging_transition_receipt" => ["REF(TransitionReceiptV12)", wrong_receipt]}, nil]
  end
  cases.concat([
    ["PREDIGEST_BYTES", {"/candidate_predigest_canonical_json_base64" => ["B64", Base64.strict_encode64("{}") ]}, nil],
    ["PREDIGEST_LENGTH", {"/candidate_predigest_bytes_uint" => ["U", base.fetch("candidate_predigest_bytes_uint") + 1]}, nil],
    ["PREDIGEST_SHA", {"/candidate_predigest_sha256" => ["H64", "f" * 64]}, nil]
  ])

  alternate_body = clone(source.fetch("candidate_body"))
  alternate_body["ordinal_uint"] += 1
  alternate_frame = frame_field_changes(base, schema: SCHEMA_BY_KIND.fetch(kind), status: base.fetch("candidate_status_enum"), body: alternate_body)
  cases << ["BODY_INSTANCE_MISMATCH", alternate_frame, nil]
  cases.concat([
    ["COMPLETE_BYTES", {"/candidate_complete_frame_with_lf_base64" => ["B64", Base64.strict_encode64("{}\n")]}, nil],
    ["COMPLETE_LENGTH", {"/candidate_complete_frame_bytes_uint" => ["U", base.fetch("candidate_complete_frame_bytes_uint") + 1]}, nil],
    ["COMPLETE_SHA", {"/candidate_complete_frame_with_lf_sha256" => ["H64", "e" * 64]}, nil]
  ])

  predigest = Base64.strict_decode64(base.fetch("candidate_predigest_canonical_json_base64"))
  predigest_object = JSON.parse(predigest)
  wrong_complete = canon(predigest_object.merge("payload_sha256" => "d" * 64)) + "\n"
  cases << ["PAYLOAD_DIGEST", {
    "/candidate_complete_frame_with_lf_base64" => ["B64", Base64.strict_encode64(wrong_complete)],
    "/candidate_complete_frame_bytes_uint" => ["U", wrong_complete.bytesize],
    "/candidate_complete_frame_with_lf_sha256" => ["H64", sha(wrong_complete)]
  }, nil]
  if include_status_mismatch
    mismatched_frame = frame_field_changes(base, schema: SCHEMA_BY_KIND.fetch(kind), status: "CONFORMANCE_STATUS_MISMATCH", body: source.fetch("candidate_body"))
    cases << ["DECODED_STATUS_MISMATCH", mismatched_frame, nil]
  end
  old_cap = publication_cap(kind)
  cases << ["OVER_CAP_CONTEXT", {}, context_cap_mutation(old_cap, base.fetch("candidate_complete_frame_bytes_uint") - 1)]
  cases
end

def add_publication_false_case!(fixtures, vectors, members, id:, operator:, kind:, source_type:, source:, base:, changes:, context_mutation:)
  mutation = context_mutation || mutation_descriptor(base, changes)
  mutated = context_mutation ? clone(base) : apply_input_mutation(base, mutation)
  cap_override = context_mutation ? base.fetch("candidate_complete_frame_bytes_uint") - 1 : nil
  raise "publication mutation unexpectedly true #{id}" if evaluate_publication(kind, mutated, source, cap_override)
  input_type = {"START" => "StartPublicationInputV12", "PREFIX" => "PrefixPublicationInputV12", "OUTER" => "OuterPublicationInputV12"}.fetch(kind)
  add_value_case!(fixtures, vectors, members,
    id: id, operator: operator, source_type: source_type, source: source,
    input_type: input_type, input: mutated, expected: EVAL_FALSE, mutation: mutation)
end

def add_binding_unavailable_case!(vectors, members, id:, operator:)
  bindings = [unavailable_binding("NORMALIZED_INPUT"), unavailable_binding("SOURCE_INSTANCE")]
  add_vector!(vectors, members, vector(id, operator, bindings, EVAL_UNAVAILABLE))
end

# START: one true, fifteen isolated false mutations, unavailable and type error.
start_members = []
start_source = publication_source("START", "START_BODY_ACCEPTED_BUILD_EPOCH_CONSUMED")
start_input = publication_input_from_source(start_source)
raise "start base false" unless evaluate_publication("START", start_input, start_source)
add_value_case!(fixtures_by_id, vectors_by_id, start_members,
  id: "START_PUBLICATION_TRUE", operator: "START_PUBLICATION_VALID",
  source_type: "StartPublicationConformanceSourceV12", source: start_source,
  input_type: "StartPublicationInputV12", input: start_input, expected: EVAL_TRUE)
start_cases = publication_false_cases("START", start_source, start_input)
raise "start false family #{start_cases.length}" unless start_cases.length == 15
start_cases.each do |name, changes, context_mutation|
  add_publication_false_case!(fixtures_by_id, vectors_by_id, start_members,
    id: "START_PUBLICATION_FALSE_#{name}", operator: "START_PUBLICATION_VALID", kind: "START",
    source_type: "StartPublicationConformanceSourceV12", source: start_source, base: start_input,
    changes: changes, context_mutation: context_mutation)
end
add_binding_unavailable_case!(vectors_by_id, start_members, id: "START_PUBLICATION_UNAVAILABLE", operator: "START_PUBLICATION_VALID")
add_type_case!(vectors_by_id, start_members, id: "START_PUBLICATION_TYPE_ERROR", operator: "START_PUBLICATION_VALID")
raise "start count #{start_members.length}" unless start_members.length == 18
new_set_members["START_PUBLICATION_VECTORS"] = start_members

# PREFIX: all three statuses, the same fifteen mutation axes, and resolution.
prefix_members = []
prefix_statuses = X.dig("enum_domains_v12", "PrefixStatusV12")
prefix_sources = prefix_statuses.map.with_index do |status, index|
  source = publication_source("PREFIX", status, nil, index)
  input = publication_input_from_source(source)
  raise "prefix base false #{status}" unless evaluate_publication("PREFIX", input, source)
  add_value_case!(fixtures_by_id, vectors_by_id, prefix_members,
    id: "PREFIX_PUBLICATION_TRUE_#{status}", operator: "PREFIX_PUBLICATION_VALID",
    source_type: "PrefixPublicationConformanceSourceV12", source: source,
    input_type: "PrefixPublicationInputV12", input: input, expected: EVAL_TRUE)
  [source, input]
end
prefix_source, prefix_input = prefix_sources.first
prefix_cases = publication_false_cases("PREFIX", prefix_source, prefix_input)
raise "prefix false family #{prefix_cases.length}" unless prefix_cases.length == 15
prefix_cases.each do |name, changes, context_mutation|
  add_publication_false_case!(fixtures_by_id, vectors_by_id, prefix_members,
    id: "PREFIX_PUBLICATION_FALSE_#{name}", operator: "PREFIX_PUBLICATION_VALID", kind: "PREFIX",
    source_type: "PrefixPublicationConformanceSourceV12", source: prefix_source, base: prefix_input,
    changes: changes, context_mutation: context_mutation)
end
add_binding_unavailable_case!(vectors_by_id, prefix_members, id: "PREFIX_PUBLICATION_UNAVAILABLE", operator: "PREFIX_PUBLICATION_VALID")
add_type_case!(vectors_by_id, prefix_members, id: "PREFIX_PUBLICATION_TYPE_ERROR", operator: "PREFIX_PUBLICATION_VALID")
raise "prefix count #{prefix_members.length}" unless prefix_members.length == 20
new_set_members["PREFIX_PUBLICATION_VECTORS"] = prefix_members

# OUTER: exhaustive 49 process/status compatibility pairs, three forbidden
# NOT_ATTEMPTED statuses, ten common publication failures, and resolution.
outer_members = []
outer_program = D.dig("custom_operator_programs_v12", "OUTER_PUBLICATION_PROGRAM")
outer_state_endpoints = {
  "NOT_ATTEMPTED" => project_endpoint_input(endpoint_cases.fetch(0)),
  "SPAWN_RAISED" => project_endpoint_input(endpoint_cases.fetch(9)),
  "PID_RETURNED_REAPED_EXIT" => project_endpoint_input(endpoint_cases.fetch(10)),
  "PID_RETURNED_REAPED_SIGNAL" => project_endpoint_input(endpoint_cases.fetch(11))
}
outer_true_sources = []
outer_state_endpoints.each do |process_state, endpoint|
  outer_program.fetch("status_compatibility_by_process_state_exact").fetch(process_state).each_with_index do |status, index|
    source = publication_source("OUTER", status, endpoint, index)
    input = publication_input_from_source(source)
    raise "outer base false #{process_state}/#{status}" unless evaluate_publication("OUTER", input, source)
    id = "OUTER_PUBLICATION_TRUE_#{process_state}_#{status}"
    add_value_case!(fixtures_by_id, vectors_by_id, outer_members,
      id: id, operator: "OUTER_PUBLICATION_VALID",
      source_type: "OuterPublicationConformanceSourceV12", source: source,
      input_type: "OuterPublicationInputV12", input: input, expected: EVAL_TRUE)
    outer_true_sources << [process_state, status, source, input]
  end
end
raise "outer true count #{outer_true_sources.length}" unless outer_true_sources.length == 49

not_endpoint = outer_state_endpoints.fetch("NOT_ATTEMPTED")
%w[PASS_BUILD_PRODUCER FAIL_BUILD_PRODUCER FAIL_UNENTERED_CONTROLLER].each_with_index do |status, index|
  source = publication_source("OUTER", status, not_endpoint, 100 + index)
  input = publication_input_from_source(source)
  raise "forbidden outer status unexpectedly true #{status}" if evaluate_publication("OUTER", input, source)
  add_value_case!(fixtures_by_id, vectors_by_id, outer_members,
    id: "OUTER_PUBLICATION_FALSE_NOT_ATTEMPTED_#{status}", operator: "OUTER_PUBLICATION_VALID",
    source_type: "OuterPublicationConformanceSourceV12", source: source,
    input_type: "OuterPublicationInputV12", input: input, expected: EVAL_FALSE)
end

_, _, outer_source, outer_input = outer_true_sources.first
outer_common = publication_false_cases("OUTER", outer_source, outer_input, include_status_mismatch: false)
# Keep the exact ten-axis outer family: projection, error, staging, endpoint,
# endpoint witness, predigest bytes/length/hash, payload-complete mismatch, cap.
outer_cases_by_name = outer_common.to_h { |name, changes, context| [name, [changes, context]] }
false_endpoint = clone(outer_input.fetch("endpoint_input"))
false_endpoint.dig("outer_process_counter_snapshot", "entries_exact_catalog_order", 0)["value_uint_or_null"] += 1
outer_selected = [
  ["PROJECTION_FLAG", *outer_cases_by_name.fetch("PROJECTION_FLAG")],
  ["ERROR_NONNONE", *outer_cases_by_name.fetch("ERROR_NONNONE")],
  ["WRONG_STAGING_PROFILE", *outer_cases_by_name.fetch("WRONG_STAGING_PROFILE")],
  ["ENDPOINT_FALSE", {"/endpoint_input" => ["REF(OuterPublicationEndpointInputV12)", false_endpoint]}, nil],
  ["ENDPOINT_WITNESS_MISMATCH", *outer_cases_by_name.fetch("PREDICATE_MISMATCH")],
  ["PREDIGEST_BYTES", *outer_cases_by_name.fetch("PREDIGEST_BYTES")],
  ["PREDIGEST_LENGTH", *outer_cases_by_name.fetch("PREDIGEST_LENGTH")],
  ["PREDIGEST_SHA", *outer_cases_by_name.fetch("PREDIGEST_SHA")],
  ["PAYLOAD_DIGEST", *outer_cases_by_name.fetch("PAYLOAD_DIGEST")],
  ["OVER_CAP_CONTEXT", *outer_cases_by_name.fetch("OVER_CAP_CONTEXT")]
]
outer_selected.each do |name, changes, context_mutation|
  add_publication_false_case!(fixtures_by_id, vectors_by_id, outer_members,
    id: "OUTER_PUBLICATION_FALSE_#{name}", operator: "OUTER_PUBLICATION_VALID", kind: "OUTER",
    source_type: "OuterPublicationConformanceSourceV12", source: outer_source, base: outer_input,
    changes: changes, context_mutation: context_mutation)
end
add_binding_unavailable_case!(vectors_by_id, outer_members, id: "OUTER_PUBLICATION_UNAVAILABLE", operator: "OUTER_PUBLICATION_VALID")
add_type_case!(vectors_by_id, outer_members, id: "OUTER_PUBLICATION_TYPE_ERROR", operator: "OUTER_PUBLICATION_VALID")
raise "outer count #{outer_members.length}" unless outer_members.length == 64
new_set_members["OUTER_PUBLICATION_VECTORS"] = outer_members

# The transition/counter publication precondition was previously only a prose
# list.  Close it as a total, poststatus, prewrite operator over every record
# kind.  The conformance source is deliberately acyclic: candidate body bytes
# are scalar sentinels, while every transition source and seed is carried as a
# separately typed row and joined by pointer/hash during replay.
R["TransitionSourceInstanceConformanceRowV12"] = {
  "keys" => ["json_pointer", "value"],
  "field_types_exact" => {"json_pointer" => "S", "value" => "REF(TypedValueV12)"},
  "rule" => "CONFORMANCE_ONLY;DISTINCT_ASCII_SORTED_RESOLVED_BODY_POINTER;TypedValueV12_CANONICAL_BYTES_ARE_THE_COMPLETE_SOURCE_INSTANCE_BYTES_AND_NEVER_CONTAIN_A_TRANSITION_RECEIPT_OR_ANCESTOR"
}
R["CounterSeedConformanceRowV12"] = {
  "keys" => ["subject_scope_id", "counter_id", "policy_enum", "seed_uint_or_null", "source_frame_or_null"],
  "field_types_exact" => {
    "subject_scope_id" => "S", "counter_id" => "S", "policy_enum" => "S",
    "seed_uint_or_null" => "U_OR_NULL", "source_frame_or_null" => "REF_OR_NULL(FrameReferenceV12)"
  },
  "rule" => "CONFORMANCE_ONLY_EXACT_EXPANSION_OF_counter_seed_source_table_v12_IN_CounterCatalogOrderV12;POLICY_AND_SOURCE_FRAME_SHAPE_MUST_MATCH_THE_SELECTED_RECORD_KIND_ROW"
}
R["RecordTransitionCounterConformanceSourceV12"] = {
  "keys" => [
    "projection_availability_enum", "record_kind_enum", "catalog_instance_enum",
    "machine_instance_enum_or_null", "candidate_schema", "candidate_status_enum",
    "candidate_body", "transition_receipts", "counter_snapshots",
    "transition_source_instances", "counter_seed_rows", "error"
  ],
  "availability_states_exact" => ["AVAILABLE", "UNAVAILABLE"],
  "field_types_exact" => {
    "projection_availability_enum" => "LOCAL_ENUM(availability_states_exact)",
    "record_kind_enum" => "ENUM(RecordKindV12)", "catalog_instance_enum" => "S",
    "machine_instance_enum_or_null" => "S_OR_NULL", "candidate_schema" => "S",
    "candidate_status_enum" => "S", "candidate_body" => "REF(PublicationConformanceBodySentinelV12)",
    "transition_receipts" => "ARRAY(TransitionReceiptV12,0,66,TransitionSequenceOrderV12)",
    "counter_snapshots" => "ARRAY(CounterSnapshotV12,4,4,CounterScopeOrderV12)",
    "transition_source_instances" => "ARRAY(TransitionSourceInstanceConformanceRowV12,0,66,JsonPointerOrderV12)",
    "counter_seed_rows" => "ARRAY(CounterSeedConformanceRowV12,23,23,CounterCatalogOrderV12)",
    "error" => "REF(ErrorV12)"
  },
  "rule" => "CONFORMANCE_ONLY_SINGLE_IMMUTABLE_POSTSTATUS_CANDIDATE_CONTEXT;AVAILABLE_IFF_error_NONE_AND_ALL_EXACT_CATALOG_MACHINE_SOURCE_COUNTER_AND_SEED_ROWS_RESOLVE;THE_PRODUCTION_MATERIALIZER_READS_THE_REAL_TYPED_RECORD_BODY_AND_BOUND_EVIDENCE_SOURCES_NOT_THIS_CARRIER"
}
R["RecordTransitionCounterPublicationInputV12"] = {
  "keys" => [
    "record_kind_enum", "candidate_predigest_canonical_json_base64",
    "candidate_predigest_bytes_uint", "candidate_predigest_sha256",
    "candidate_complete_frame_with_lf_base64", "candidate_complete_frame_bytes_uint",
    "candidate_complete_frame_with_lf_sha256", "counter_fold_rows",
    "counter_fold_complete_bool", "projection_complete_bool", "error"
  ],
  "field_types_exact" => {
    "record_kind_enum" => "ENUM(RecordKindV12)",
    "candidate_predigest_canonical_json_base64" => "B64",
    "candidate_predigest_bytes_uint" => "U", "candidate_predigest_sha256" => "H64",
    "candidate_complete_frame_with_lf_base64" => "B64",
    "candidate_complete_frame_bytes_uint" => "U",
    "candidate_complete_frame_with_lf_sha256" => "H64",
    "counter_fold_rows" => "ARRAY(CounterFoldOperatorInputV12,1,32,CounterCatalogOrderV12)",
    "counter_fold_complete_bool" => "B", "projection_complete_bool" => "B",
    "error" => "REF(ErrorV12)"
  },
  "rule" => "EPHEMERAL_POSTSTATUS_TRANSITION_COUNTER_PROJECTION;FRAME_FIELDS_BIND_ONE_IMMUTABLE_CANDIDATE_AND_COUNTER_ROWS_ARE_MECHANICALLY_PROJECTED_FROM_ITS_RECEIPTS_SNAPSHOTS_EXACT_DEFINITIONS_CATALOG_AND_FROZEN_SEEDS"
}

# PROJECT_R00_INPUT is shared by topology and failure operators.  The failure
# profile must therefore supply the same complete five-way topology binding
# set, plus FIRST_UNENTERED, rather than silently omitting two conjuncts.
D.fetch("custom_operator_binding_profiles_v12")["R00_FAILURE_BINDINGS"] = clone(
  D.fetch("custom_operator_binding_profiles_v12").fetch("R00_TOPOLOGY_BINDINGS")
)

record_gate_definition = [
  "RECORD_TRANSITION_COUNTER_PUBLICATION_VALID", "NONE", "B", "WRAPPER_BICONDITIONAL_GATE",
  "RECORD_TRANSITION_COUNTER_PUBLICATION_BINDINGS",
  "PROJECT_RECORD_TRANSITION_COUNTER_PUBLICATION_INPUT",
  "RECORD_TRANSITION_COUNTER_PUBLICATION_PROGRAM",
  "RECORD_TRANSITION_COUNTER_PUBLICATION_VECTORS"
]
unless D.fetch("custom_operator_definitions_v12").any? { |row| row[0] == record_gate_definition[0] }
  counter_index = D.fetch("custom_operator_definitions_v12").index { |row| row[0] == "COUNTER_FOLD_VALID" }
  D.fetch("custom_operator_definitions_v12").insert(counter_index + 1, record_gate_definition)
end

D.fetch("custom_operator_binding_profiles_v12")["RECORD_TRANSITION_COUNTER_PUBLICATION_BINDINGS"] = [
  ["FRAME_CONTEXT", "ANY", "POSTSTATUS_CURRENT_CANDIDATE", "", "CURRENT_IMMUTABLE_SCHEMA_STATUS_BODY_AND_RECORD_KIND_CONTEXT"],
  ["STATUS", "ANY", "POSTSTATUS_CURRENT_CANDIDATE", "/status", "RECORD_DECLARED_STATUS_ENUM"],
  ["BODY", "ANY", "POSTSTATUS_CURRENT_CANDIDATE", "/body", "RECORD_BODY(record_kind)"],
  ["RECEIPTS", "ANY", "POSTSTATUS_CURRENT_CANDIDATE", "/body/transition_receipts", "RECORD_DECLARED_TRANSITION_RECEIPT_ARRAY"],
  ["SNAPSHOTS", "ANY", "POSTSTATUS_CURRENT_CANDIDATE", "/body/counter_snapshots", "ARRAY(CounterSnapshotV12,4,4,CounterScopeOrderV12)"],
  ["DEFINITIONS", "ANY", "CONTROL_OBJECT", "/exact_record_schema_v12/decision_kernel_v12/transition_definitions_v12", "ARRAY(TransitionDefinitionV12,24,24,TransitionDefinitionOrderV12)"],
  ["COUNTER_CATALOG", "ANY", "CONTROL_OBJECT", "/exact_record_schema_v12/decision_kernel_v12/counter_catalog", "CONTROL_OBJECT"],
  ["SEED_SOURCE_TABLE", "ANY", "CONTROL_OBJECT", "/exact_record_schema_v12/decision_kernel_v12/counter_fold_v12/counter_seed_source_table_v12", "CONTROL_ARRAY"]
]

projection_registry = D.fetch("custom_operator_input_projection_registry_v12")
[
  ["CONFORMANCE_POSTSTATUS_CANDIDATE", "CONFORMANCE_ONLY_TYPED_SOURCE_MATERIALIZER_FOR_ACYCLIC_PUBLICATION_CANDIDATES;NEVER_SELECTABLE_IN_PRODUCTION"],
  ["CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL", "CONFORMANCE_ONLY_TYPED_SOURCE_MATERIALIZER_FOR_ONE_R00_BODY_AND_ONE_HELD_CONTROL;NEVER_SELECTABLE_IN_PRODUCTION"],
  ["CONFORMANCE_LEGACY_CUSTOM_SOURCE", "CONFORMANCE_ONLY_TYPED_SOURCE_MATERIALIZER_FOR_THE_FOUR_NON_R00_ORIGINAL_PROJECTION_PROGRAMS;NEVER_SELECTABLE_IN_PRODUCTION"]
].each do |row|
  projection_registry.fetch("projection_source_classes_exact") << row unless projection_registry.fetch("projection_source_classes_exact").any? { |candidate| candidate[0] == row[0] }
end
projection_registry.fetch("programs_v12")["PROJECT_RECORD_TRANSITION_COUNTER_PUBLICATION_INPUT"] = {
  "output_type_id" => "RecordTransitionCounterPublicationInputV12",
  "field_rows_exact" => [
    ["record_kind_enum", "COPY_TYPED", "FRAME_CONTEXT", "/record_kind_enum", "ENUM(RecordKindV12)"],
    [[
      "candidate_predigest_canonical_json_base64", "candidate_predigest_bytes_uint",
      "candidate_predigest_sha256", "candidate_complete_frame_with_lf_base64",
      "candidate_complete_frame_bytes_uint", "candidate_complete_frame_with_lf_sha256"
    ], "PROJECT_PUBLICATION_FRAME_FIELDS", "STATUS+BODY", "/", ["B64", "U", "H64", "B64", "U", "H64"]],
    ["counter_fold_rows", "PROJECT_COUNTER_ROWS", "RECEIPTS+SNAPSHOTS+DEFINITIONS+COUNTER_CATALOG+SEED_SOURCE_TABLE+RESOLVED_RECORD_EVIDENCE_SOURCES", "/", "ARRAY(CounterFoldOperatorInputV12,1,32,CounterCatalogOrderV12)"],
    ["counter_fold_complete_bool", "SCHEMA_AND_PROFILE_CONJUNCTION", "COUNTER_BINDING_SET", "/", "B"],
    ["projection_complete_bool", "CONST_TYPED", "LITERAL", true, "B"],
    ["error", "CONST_TYPED", "LITERAL", error_none, "REF(ErrorV12)"]
  ],
  "opcode_metadata_by_output_key_exact" => {
    "candidate_predigest_canonical_json_base64" => {
      "record_kind_enum" => "DYNAMIC_EXACT_RECORD_KIND_FROM_FRAME_CONTEXT",
      "schema_pointer" => "/exact_record_schema_v12/record_publication_preconditions_v12/record_schema_to_kind_exact"
    }
  },
  "constants_emitted_only_after_all_nonconstant_bindings_resolve_bool" => true
}

D.fetch("custom_operator_programs_v12")["RECORD_TRANSITION_COUNTER_PUBLICATION_PROGRAM"] = {
  "input_type_id" => "RecordTransitionCounterPublicationInputV12",
  "wrapper_instruction_id" => "RECORD_TRANSITION_COUNTER_PUBLICATION_INPUT_BICONDITIONAL",
  "counter_fold_program_id" => "COUNTER_FOLD_PROGRAM",
  "required_checks_exact" => [
    "CANDIDATE_FRAME_CANONICAL_HASH_AND_SAME_IMMUTABLE_SCHEMA_STATUS_BODY_BINDING",
    "TRANSITION_RECEIPT_ARRAY_MATCHES_EXACT_RECORD_CATALOG_OR_TRANSITIONLESS_CATALOG",
    "EVERY_RECEIPT_BINDS_EXACT_IMMUTABLE_TRANSITION_DEFINITION_AND_MACHINE_INSTANCE",
    "RECEIPT_STATE_MATRIX_AND_MACHINE_REPLAY_VALID",
    "EVERY_NONNULL_RECEIPT_SOURCE_INSTANCE_POINTER_AND_CANONICAL_SHA256_MATCH_SAME_BODY",
    "EVERY_COUNTER_SNAPSHOT_THROUGH_COUNT_EQUALS_RECEIPT_COUNT",
    "COUNTER_FOLD_PROGRAM_VALUE_TRUE_AGAINST_EXACT_FROZEN_SEED_SOURCE"
  ],
  "record_kind_map_pointer" => "/exact_record_schema_v12/record_publication_preconditions_v12/record_kind_transition_counter_publication_operator_exact",
  "status_allowlist_exact" => [],
  "fully_typed_nonmatch_result" => false,
  "unavailable_required_source_result" => "UNAVAILABLE"
}

D.fetch("custom_operator_operational_role_by_id_exact")[record_gate_definition[0]] = "UNIVERSAL_POSTSTATUS_TRANSITION_COUNTER_PREWRITE_GATE"
D.fetch("postfix_token_grammar_v12").fetch("token_forms_exact") << [record_gate_definition[0]] unless D.fetch("postfix_token_grammar_v12").fetch("token_forms_exact").any? { |row| row[0] == record_gate_definition[0] }
D.fetch("postfix_token_grammar_v12").fetch("stack_signatures_exact")[record_gate_definition[0]] = "RESOLVE_EXACT_custom_operator_definitions_v12_ROW_TYPECHECK_ONE_IMMUTABLE_POSTSTATUS_CANDIDATE_MATERIALIZE_RecordTransitionCounterPublicationInputV12_REPLAY_EXACT_CATALOG_DEFINITIONS_MACHINE_SOURCES_SNAPSHOTS_AND_COUNTER_FOLD_THEN_PROJECT_B_OR_UNAVAILABLE"

S.fetch("wrapper_invariant_programs_exact")["RecordTransitionCounterPublicationInputV12"] = ["RECORD_TRANSITION_COUNTER_PUBLICATION_INPUT_BICONDITIONAL"]
S.fetch("wrapper_invariant_instruction_semantics_exact")["RECORD_TRANSITION_COUNTER_PUBLICATION_INPUT_BICONDITIONAL"] = "REQUIRE_EXACT_KEYS_TYPES_projection_complete_true_error_NONE;RESOLVE_EXACTLY_ONE_CURRENT_IMMUTABLE_POSTSTATUS_UNPUBLISHED_CANDIDATE_AND_REQUIRE_record_kind_MATCH_THE_TOTAL_SCHEMA_TO_KIND_MAP;STRICTLY_DECODE_HASH_PARSE_DUPLICATE_KEY_REJECT_CANONICAL_REENCODE_AND_BYTE_JOIN_THE_PREDIGEST_AND_COMPLETE_FRAME_FIELDS;REQUIRE_DECODED_schema_status_body_DEEP_EQUAL_THE_SAME_CANDIDATE;SELECT_EXACTLY_ONE_RECORD_TRANSITION_CATALOG_OR_TRANSITIONLESS_CATALOG_AND_REQUIRE_RECEIPT_COUNT_ORDER_IDS_DYNAMIC_INSTANCE_AND_SOURCE_ROW_SELECTION;BIND_EVERY_RECEIPT_TO_THE_EXACT_IMMUTABLE_TRANSITION_DEFINITION_MACHINE_INSTANCE_TRIGGER_GUARDS_STATE_MATRIX_FROM_TO_DELTAS_AND_ERROR;REPLAY_EACH_MACHINE_WITH_ONLY_ENTERED_ADVANCING;REQUIRE_EVERY_NONNULL_SOURCE_POINTER_AND_CANONICAL_SHA256_RESOLVE_TO_THE_SAME_BODY_AND_NULL_MAPPINGS_HAVE_BOTH_FIELDS_NULL;REQUIRE_ALL_FOUR_COUNTER_SNAPSHOTS_IN_CATALOG_ORDER_AND_EACH_through_transition_count_uint_EQUALS_THE_RECEIPT_LENGTH;REQUIRE_counter_fold_complete_true_MATERIALIZE_CounterFoldInputSetV12_FROM_counter_fold_rows_AND_EXECUTE_COUNTER_FOLD_PROGRAM_VALUE_TRUE;NO_STATUS_ALLOWLIST_OR_STATUS_BRANCH;FALSE_UNKNOWN_UNAVAILABLE_TYPE_ERROR_OR_ARITHMETIC_ERROR_FORBIDS_FIRST_BODY_BYTE_AND_FINAL_RENAME"

replay_sources = D.fetch("custom_operator_conformance_projection_replay_v12").fetch("source_rows_exact")
replay_sources << [record_gate_definition[0], "RecordTransitionCounterConformanceSourceV12", "CONFORMANCE_POSTSTATUS_CANDIDATE", "PROJECT_RECORD_TRANSITION_COUNTER_PUBLICATION_INPUT"] unless replay_sources.any? { |row| row[0] == record_gate_definition[0] }

publication = D.fetch("publication_operator_invocation_profiles_v12")
publication.fetch("phase_enum_exact").insert(1, "POSTSTATUS_TRANSITION_COUNTER") unless publication.fetch("phase_enum_exact").include?("POSTSTATUS_TRANSITION_COUNTER")
record_kinds = X.dig("record_publication_preconditions_v12", "record_schema_to_kind_exact").values
universal_rows = record_kinds.map do |kind|
  [record_gate_definition[0], kind, "POSTSTATUS_TRANSITION_COUNTER", "RecordTransitionCounterPublicationInputV12", "RECORD_TRANSITION_COUNTER_PUBLICATION_BINDINGS", nil, nil, nil, nil, "BODY", "STATUS", nil, nil]
end
publication["rows_exact"] = publication.fetch("rows_exact").reject { |row| row[0] == record_gate_definition[0] }
prestaging_rows = publication.fetch("rows_exact").select { |row| row[2] == "PRESTAGING_ENDPOINT" }
postwrite_rows = publication.fetch("rows_exact").select { |row| row[2] == "POSTSTATUS_PREWRITE" }
publication["rows_exact"] = prestaging_rows + universal_rows + postwrite_rows
publication["poststatus_transition_counter_false_effect_exact"] = "VALUE_FALSE_UNAVAILABLE_TYPE_ERROR_OR_ARITHMETIC_ERROR_RETAINS_THE_ALREADY_EXCLUSIVELY_CREATED_EMPTY_STAGING_LEAF_PROVES_ZERO_BODY_BYTES_AND_ZERO_RENAME_ENTRIES_AND_SPENDS_THE_APPLICABLE_NAMESPACE_OR_EPOCH_WITH_NO_RETRY"
publication["selection_rule"] = "EXACT_RECORD_KIND_AND_PHASE_SELECTS_ROWS_WITH_FIXED_ORDER_PRESTAGING_ENDPOINT_THEN_POSTSTATUS_TRANSITION_COUNTER_THEN_OPTIONAL_POSTSTATUS_PREWRITE;THE_UNIVERSAL_GATE_SELECTS_EXACTLY_ONCE_FOR_ALL11_RECORD_KINDS_WITH_NO_STATUS_BRANCH;START_PREFIX_OUTER_THEN_SELECT_EXACTLY_THEIR_FIXED_RECORD_SPECIFIC_GATE;NO_RUNTIME_STATUS_PATH_OR_PROSE_SELECTS_AN_OPERATOR"

preconditions = X.fetch("record_publication_preconditions_v12")
preconditions["record_kind_transition_counter_publication_operator_exact"] = record_kinds.to_h { |kind| [kind, record_gate_definition[0]] }
preconditions["transition_counter_same_candidate_context_rows_exact"] = record_kinds.map do |kind|
  [kind, "POSTSTATUS_CURRENT_CANDIDATE", "SAME_IMMUTABLE_schema_status_body_RECEIPTS_SNAPSHOTS_SOURCE_INSTANCES_AND_FRAME_BYTES"]
end
preconditions["selection_rule"] = "AFTER_ALL_RECORD_SPECIFIC_PREENTRY_ABSENCE_AND_BUDGET_GATES_HOLD_SELECT_THE_FIXED_PRESTAGING_OPERATOR;OUTER_REQUIRES_ITS_ENDPOINT_VALUE_TRUE_BEFORE_STAGING;ONLY_THEN_CREATE_AND_HOLD_ONE_EXCLUSIVE_EMPTY_STAGING_LEAF;CONSTRUCT_AND_FREEZE_ONE_COMPLETE_IMMUTABLE_UNPUBLISHED_schema_status_body_CANDIDATE;FOR_EVERY_RECORD_KIND_MATERIALIZE_AND_REQUIRE_THE_TOTAL_record_kind_transition_counter_publication_operator_exact_VALUE_TRUE_WITH_NO_STATUS_ALLOWLIST;THEN_REQUIRE_EVERY_CURRENT_REQUIRED_PREDICATE_TRUE_AND_RUN_THE_OPTIONAL_START_PREFIX_OR_OUTER_POSTSTATUS_PREWRITE_GATE;ONLY_AFTER_BOTH_POSTSTATUS_PHASES_VALUE_TRUE_MAY_THE_FIRST_BYTE_FROM_THE_VM_LOCAL_STRICT_DECODED_COMPLETE_FRAME_BUFFER_BE_WRITTEN;ANY_FALSE_OR_NONVALUE_RETAINS_EMPTY_STAGING_ZERO_BYTES_ZERO_RENAME_AND_SPENDS_WITH_NO_RETRY"

rtc = D.fetch("record_transition_counter_publication_precondition_v12")
source_check = "EVERY_NONNULL_RECEIPT_SOURCE_INSTANCE_POINTER_AND_COMPLETE_CANONICAL_SHA256_MATCHES_THE_SAME_IMMUTABLE_CANDIDATE_BODY"
rtc.fetch("required_checks_exact").insert(3, source_check) unless rtc.fetch("required_checks_exact").include?(source_check)
rtc["typed_operator_id"] = record_gate_definition[0]
rtc["invocation_phase_enum"] = "POSTSTATUS_TRANSITION_COUNTER"

X.fetch("order_registry_v12")["CustomOperatorDefinitionOrderV12"] = "EXACT_JOURNAL_ENVELOPE_R00_TOPOLOGY_R00_FAILURE_COUNTER_UNIVERSAL_TRANSITION_COUNTER_PUBLICATION_JOURNAL_CHAIN_OUTER_CHAIN_CUT_ENDPOINT_START_PREFIX_OUTER_PUBLICATION_ARRAY_ORDER_NO_RUNTIME_RESORT"
X.fetch("order_registry_v12")["CustomOperatorConformanceSetOrderV12"] = "EXACT_custom_operator_definitions_v12_PROJECT_conformance_set_id_ORDER_DISTINCT"

RECORD_SCHEMA_BY_KIND = preconditions.fetch("record_schema_to_kind_exact").to_h { |schema_id, kind| [kind, schema_id] }.freeze
COUNTER_SCOPE_ORDER = D.fetch("counter_catalog").keys.freeze
TRANSITION_BY_ID = D.fetch("transition_definitions_v12").to_h { |row| [row.fetch("transition_id"), row] }.freeze
SOURCE_POINTER_BY_TRANSITION = D.dig("transition_receipt_semantics_v12", "source_instance_binding_by_transition_exact").to_h.freeze
SEED_ROW_BY_KIND_SCOPE = D.dig("counter_fold_v12", "counter_seed_source_table_v12").to_h do |row|
  [[row.fetch(0), row.fetch(1)], row]
end.freeze

def record_variant_for_seed(kind)
  kind
end

def universal_catalog_spec(kind, catalog_instance)
  case kind
  when "SYNTAX"
    [["TR_SYNTAX_DISPATCH_ENTERED", true, "/syntax_admission_result"]]
  when "IMPLEMENTATION", "READINESS", "LAUNCH_BINDING", "JOURNAL_TERMINAL"
    []
  when "START"
    [["TR_CONTROLLER_SELF_ENTRY_PROVED", true, "/controller_runtime_admission"],
     ["TR_BUILD_EPOCH_START_STAGING_CREATED", true, "/start_publication_staging_admission"]]
  when "JOURNAL_R00"
    create_count = catalog_instance == "R00_MAX" ? 31 : 0
    rows = create_count.times.map { |i| ["TR_R00_DIRECTORY_CREATE_SIDE_EFFECT", true, "/directory_operations/#{i}"] }
    rows + [["TR_R00_CONSTRUCTION_CLOSED", true, "/directory_operations"]]
  when "JOURNAL_OPERATION"
    %w[TR_SWIFTPM_CAPTURES_HELD TR_SWIFTPM_SPAWN_CALL_ENTERED TR_SWIFTPM_PID_RETURNED TR_SWIFTPM_EXACT_REAP].map do |id|
      [id, true, id == "TR_SWIFTPM_CAPTURES_HELD" ? "/capture_lifetime" : "/process"]
    end
  when "PREFIX"
    [["TR_PREFIX_STAGING_CREATED", true, "/prefix_publication_staging_admission"],
     ["TR_PREFIX_EXIT0_INTENT_SELECTED", true, nil],
     ["TR_PREFIX_EXIT70_INTENT_SELECTED", false, nil]]
  when "OUTER"
    %w[TR_OUTER_SELF_ENTRY_PROVED TR_OBSERVER_NAMESPACE_SPENT TR_CONTROLLER_SPAWN_CALL_ENTERED TR_CONTROLLER_PID_RETURNED TR_CONTROLLER_EXACT_REAP].map do |id|
      [id, true, SOURCE_POINTER_BY_TRANSITION.fetch(id)]
    end
  when "C5"
    response_count = catalog_instance == "C5_MAX" ? 64 : 1
    rows = [["TR_C4_EXTERNAL_PREFLIGHT_CAPTURED", true, "/external_pre_dispatch_observation"],
            ["TR_C4_OUTER_DISPATCH_ENTERED", true, "/tool_responses/0/request"]]
    response_count.times do |i|
      id = if response_count == 1
        "TR_C4_EXEC_TERMINAL_RESPONSE_RECORDED"
      elsif i.zero?
        "TR_C4_EXEC_RUNNING_RESPONSE_RECORDED"
      elsif i == response_count - 1
        "TR_C4_POLL_TERMINAL_RESPONSE_RECORDED"
      else
        "TR_C4_POLL_RUNNING_RESPONSE_RECORDED"
      end
      rows << [id, true, "/tool_responses/#{i}"]
    end
    rows
  else
    raise "unsupported universal kind #{kind}"
  end
end

def source_value_for(pointer)
  {"source_pointer" => pointer, "sentinel_uint" => pointer.bytes.sum}
end

def universal_receipt(sequence, transition_id, entered, pointer, source_value)
  definition = TRANSITION_BY_ID.fetch(transition_id)
  trigger = custom_predicate_evaluation(definition.fetch("trigger_predicate_id"), entered)
  guards = definition.fetch("guard_conditions_all").map do |guard|
    custom_predicate_evaluation(guard.fetch("predicate_id"), true)
  end
  {
    "sequence_uint" => sequence, "transition_id" => transition_id,
    "source_instance_json_pointer_or_null" => pointer,
    "source_instance_complete_json_sha256_or_null" => pointer.nil? ? nil : sha(source_value),
    "state_enum" => entered ? "ENTERED" : "NOT_ENTERED",
    "from_state_enum" => definition.fetch("from_state_enum"),
    "to_state_enum_or_null" => entered ? definition.fetch("to_state_enum") : nil,
    "trigger_evaluation" => trigger, "guard_evaluations" => guards,
    "counter_deltas_applied" => entered ? clone(definition.fetch("counter_deltas")) : [],
    "error" => error_none
  }
end

def policy_for(kind, scope)
  SEED_ROW_BY_KIND_SCOPE.fetch([record_variant_for_seed(kind), scope]).fetch(2)
end

def seed_value_for(kind, scope, policy)
  return nil if %w[UNKNOWN NOT_APPLICABLE].include?(policy)
  row = SEED_ROW_BY_KIND_SCOPE.fetch([record_variant_for_seed(kind), scope])
  row.fetch(3) == "GENESIS_ZERO" ? 0 : 7
end

def counter_seed_rows(kind)
  COUNTER_SCOPE_ORDER.flat_map.with_index do |scope, scope_index|
    policy = policy_for(kind, scope)
    seed = seed_value_for(kind, scope, policy)
    source_frame = policy == "EXACT_IMPORTED" ? frame_reference(40 + scope_index) : nil
    D.fetch("counter_catalog").fetch(scope).map do |counter_id|
      {
        "subject_scope_id" => scope, "counter_id" => counter_id,
        "policy_enum" => policy, "seed_uint_or_null" => seed,
        "source_frame_or_null" => clone(source_frame)
      }
    end
  end
end

def receipt_delta(receipt_value, scope, counter_id)
  definition = TRANSITION_BY_ID[receipt_value.fetch("transition_id")]
  return 0 unless definition && receipt_value.fetch("state_enum") == "ENTERED"
  row = definition.fetch("counter_deltas").find do |delta|
    delta.fetch("subject_scope_id") == scope && delta.fetch("counter_id") == counter_id
  end
  row ? row.fetch("delta_uint") : 0
end

def definition_replay_valid?(receipt_value)
  definition = TRANSITION_BY_ID[receipt_value.fetch("transition_id")]
  return false unless definition
  entered = receipt_value.fetch("state_enum") == "ENTERED"
  return false unless %w[ENTERED NOT_ENTERED].include?(receipt_value.fetch("state_enum"))
  return false unless receipt_value.fetch("from_state_enum") == definition.fetch("from_state_enum")
  return false unless receipt_value.fetch("to_state_enum_or_null") == (entered ? definition.fetch("to_state_enum") : nil)
  return false unless receipt_value.fetch("counter_deltas_applied") == (entered ? definition.fetch("counter_deltas") : [])
  return false unless receipt_value.dig("trigger_evaluation", "state_enum") == (entered ? "TRUE" : "FALSE")
  return false unless receipt_value.fetch("guard_evaluations").all? { |row| row.fetch("state_enum") == "TRUE" }
  receipt_value.dig("error", "state_enum") == "NONE"
rescue KeyError
  false
end

def snapshots_for(kind, receipts, seed_rows, through_override = nil)
  through = through_override || receipts.length
  COUNTER_SCOPE_ORDER.map.with_index do |scope, scope_index|
    policy = policy_for(kind, scope)
    observation = {"EXACT_SELF" => "EXACT_SELF", "EXACT_IMPORTED" => "EXACT_IMPORTED", "UNKNOWN" => "UNKNOWN", "NOT_APPLICABLE" => "NOT_APPLICABLE"}.fetch(policy)
    frame = observation == "EXACT_IMPORTED" ? frame_reference(40 + scope_index) : nil
    entries = D.fetch("counter_catalog").fetch(scope).map do |counter_id|
      seed_row = seed_rows.find { |row| row.fetch("subject_scope_id") == scope && row.fetch("counter_id") == counter_id }
      if %w[EXACT_SELF EXACT_IMPORTED].include?(policy)
        observed = seed_row.fetch("seed_uint_or_null") + receipts.sum { |receipt_value| receipt_delta(receipt_value, scope, counter_id) }
        {"counter_id" => counter_id, "state_enum" => "EXACT", "value_uint_or_null" => observed}
      elsif policy == "UNKNOWN"
        {"counter_id" => counter_id, "state_enum" => "UNKNOWN", "value_uint_or_null" => nil}
      else
        {"counter_id" => counter_id, "state_enum" => "NOT_APPLICABLE", "value_uint_or_null" => nil}
      end
    end
    {
      "subject_scope_id" => scope, "reporter_scope_id" => scope,
      "observation_enum" => observation, "source_frame_or_null" => clone(frame),
      "through_transition_count_uint" => through,
      "entries_exact_catalog_order" => entries
    }
  end
end

def counter_rows_from_source(source)
  receipts = source.fetch("transition_receipts")
  seed_rows = source.fetch("counter_seed_rows")
  source.fetch("counter_snapshots").flat_map do |snapshot|
    scope = snapshot.fetch("subject_scope_id")
    policy = policy_for(source.fetch("record_kind_enum"), scope)
    through = snapshot.fetch("through_transition_count_uint")
    D.fetch("counter_catalog").fetch(scope).map do |counter_id|
      seed_row = seed_rows.find { |row| row.fetch("subject_scope_id") == scope && row.fetch("counter_id") == counter_id }
      entry = snapshot.fetch("entries_exact_catalog_order").find { |row| row.fetch("counter_id") == counter_id }
      deltas = receipts.map { |receipt_value| receipt_delta(receipt_value, scope, counter_id) }
      mask = receipts.map { |receipt_value| receipt_value.fetch("state_enum") == "ENTERED" }
      if through > receipts.length
        (through - receipts.length).times { deltas << 0; mask << false }
      elsif through < receipts.length
        deltas = deltas.first(through)
        mask = mask.first(through)
      end
      {
        "counter_id" => counter_id, "policy_enum" => policy,
        "seed_uint_or_null" => seed_row.fetch("seed_uint_or_null"),
        "delta_values" => deltas, "entered_mask" => mask,
        "observed_uint_or_null" => entry.fetch("value_uint_or_null"),
        "through_transition_count_uint" => through,
        "definitions_valid_bool" => receipts.all? { |receipt_value| definition_replay_valid?(receipt_value) },
        "import_available_bool" => %w[EXACT_SELF EXACT_IMPORTED].include?(policy)
      }
    end
  end
end

def universal_source(kind, catalog_instance, machine_instance = nil, ordinal = 0)
  specs = universal_catalog_spec(kind, catalog_instance)
  source_values = {}
  receipts = specs.each_with_index.map do |(transition_id, entered, pointer), sequence|
    value = pointer.nil? ? nil : (source_values[pointer] ||= source_value_for(pointer))
    universal_receipt(sequence, transition_id, entered, pointer, value)
  end
  seeds = counter_seed_rows(kind)
  body = {"sentinel_id" => "RTC_#{kind}_#{catalog_instance}", "ordinal_uint" => ordinal, "padding_base64" => ""}
  {
    "projection_availability_enum" => "AVAILABLE", "record_kind_enum" => kind,
    "catalog_instance_enum" => catalog_instance,
    "machine_instance_enum_or_null" => machine_instance,
    "candidate_schema" => RECORD_SCHEMA_BY_KIND.fetch(kind),
    "candidate_status_enum" => "CONFORMANCE_#{kind}_STATUS",
    "candidate_body" => body, "transition_receipts" => receipts,
    "counter_snapshots" => snapshots_for(kind, receipts, seeds),
    "transition_source_instances" => source_values.keys.sort.map do |pointer|
      {"json_pointer" => pointer, "value" => typed("CONFORMANCE_SOURCE_VALUE", source_values.fetch(pointer))}
    end,
    "counter_seed_rows" => seeds, "error" => error_none
  }
end

def universal_input(source)
  predigest_object = {
    "schema" => source.fetch("candidate_schema"), "status" => source.fetch("candidate_status_enum"),
    "body" => clone(source.fetch("candidate_body"))
  }
  predigest = canon(predigest_object)
  payload = sha(predigest)
  complete = canon(predigest_object.merge("payload_sha256" => payload)) + "\n"
  {
    "record_kind_enum" => source.fetch("record_kind_enum"),
    "candidate_predigest_canonical_json_base64" => Base64.strict_encode64(predigest),
    "candidate_predigest_bytes_uint" => predigest.bytesize,
    "candidate_predigest_sha256" => payload,
    "candidate_complete_frame_with_lf_base64" => Base64.strict_encode64(complete),
    "candidate_complete_frame_bytes_uint" => complete.bytesize,
    "candidate_complete_frame_with_lf_sha256" => sha(complete),
    "counter_fold_rows" => counter_rows_from_source(source),
    "counter_fold_complete_bool" => source.fetch("projection_availability_enum") == "AVAILABLE",
    "projection_complete_bool" => source.fetch("projection_availability_enum") == "AVAILABLE",
    "error" => clone(source.fetch("error"))
  }
end

def expected_catalog_rows(source)
  universal_catalog_spec(source.fetch("record_kind_enum"), source.fetch("catalog_instance_enum"))
end

def source_pointer_valid?(source, receipt_value, expected_pointer)
  return receipt_value.fetch("source_instance_json_pointer_or_null").nil? && receipt_value.fetch("source_instance_complete_json_sha256_or_null").nil? if expected_pointer.nil?
  return false unless receipt_value.fetch("source_instance_json_pointer_or_null") == expected_pointer
  row = source.fetch("transition_source_instances").find { |candidate| candidate.fetch("json_pointer") == expected_pointer }
  return false unless row
  value = row.fetch("value")
  bytes = Base64.strict_decode64(value.fetch("canonical_json_base64"))
  return false unless bytes.bytesize == value.fetch("bytes_uint") && sha(bytes) == value.fetch("sha256")
  receipt_value.fetch("source_instance_complete_json_sha256_or_null") == value.fetch("sha256")
rescue KeyError, ArgumentError
  false
end

def counter_row_valid?(row)
  return false unless row.fetch("definitions_valid_bool") && row.fetch("delta_values").length == row.fetch("through_transition_count_uint") && row.fetch("entered_mask").length == row.fetch("through_transition_count_uint")
  policy = row.fetch("policy_enum")
  return row.fetch("seed_uint_or_null").nil? && row.fetch("observed_uint_or_null").nil? unless %w[EXACT_SELF EXACT_IMPORTED LOWER_BOUND_IMPORTED].include?(policy)
  return false unless row.fetch("import_available_bool")
  expected = row.fetch("seed_uint_or_null") + row.fetch("delta_values").zip(row.fetch("entered_mask")).sum { |delta, entered| entered ? delta : 0 }
  policy == "LOWER_BOUND_IMPORTED" ? row.fetch("observed_uint_or_null") >= expected : row.fetch("observed_uint_or_null") == expected
rescue KeyError, TypeError
  false
end

def evaluate_universal(source, input)
  return nil if source.fetch("projection_availability_enum") == "UNAVAILABLE"
  return false unless source.dig("error", "state_enum") == "NONE" && input.dig("error", "state_enum") == "NONE"
  return false unless input.fetch("projection_complete_bool") && input.fetch("counter_fold_complete_bool")
  kind = source.fetch("record_kind_enum")
  return false unless input.fetch("record_kind_enum") == kind && source.fetch("candidate_schema") == RECORD_SCHEMA_BY_KIND.fetch(kind)
  if kind == "JOURNAL_OPERATION"
    expected_instance = source.fetch("catalog_instance_enum").delete_prefix("OP_")
    return false unless source.fetch("machine_instance_enum_or_null") == expected_instance && D.dig("transition_machine_catalog_v12", "machine_instance_rules_v12", "allowed_operation_instances_exact").include?(expected_instance)
  else
    return false unless source.fetch("machine_instance_enum_or_null").nil?
  end

  predigest_object, predigest = strict_json_from_b64(input.fetch("candidate_predigest_canonical_json_base64"))
  return false unless predigest_object && predigest.bytesize == input.fetch("candidate_predigest_bytes_uint") && sha(predigest) == input.fetch("candidate_predigest_sha256")
  return false unless predigest_object == {"schema" => source.fetch("candidate_schema"), "status" => source.fetch("candidate_status_enum"), "body" => source.fetch("candidate_body")}
  complete = Base64.strict_decode64(input.fetch("candidate_complete_frame_with_lf_base64"))
  return false unless complete.end_with?("\n") && complete.count("\n") == 1 && complete.bytesize == input.fetch("candidate_complete_frame_bytes_uint") && sha(complete) == input.fetch("candidate_complete_frame_with_lf_sha256")
  complete_object = JSON.parse(complete.delete_suffix("\n"))
  return false unless canon(complete_object) + "\n" == complete && complete_object == predigest_object.merge("payload_sha256" => sha(predigest))

  expected = expected_catalog_rows(source)
  receipts = source.fetch("transition_receipts")
  return false unless receipts.length == expected.length
  machine_states = {}
  receipts.each_with_index do |receipt_value, index|
    transition_id, entered, pointer = expected.fetch(index)
    return false unless receipt_value.fetch("sequence_uint") == index && receipt_value.fetch("transition_id") == transition_id
    return false unless receipt_value.fetch("state_enum") == (entered ? "ENTERED" : "NOT_ENTERED")
    return false unless definition_replay_valid?(receipt_value)
    return false unless source_pointer_valid?(source, receipt_value, pointer)
    definition = TRANSITION_BY_ID.fetch(transition_id)
    current = machine_states.fetch(definition.fetch("machine_id"), definition.fetch("from_state_enum"))
    # A counterfactual NOT_ENTERED suffix reproduces its immutable definition's
    # from-state without rewinding or challenging the live machine state.
    return false if entered && current != definition.fetch("from_state_enum")
    machine_states[definition.fetch("machine_id")] = definition.fetch("to_state_enum") if entered
  end

  snapshots = source.fetch("counter_snapshots")
  return false unless snapshots.map { |row| row.fetch("subject_scope_id") } == COUNTER_SCOPE_ORDER
  return false unless snapshots.all? { |row| row.fetch("through_transition_count_uint") == receipts.length }
  return false unless input.fetch("counter_fold_rows") == counter_rows_from_source(source)
  return false unless input.fetch("counter_fold_rows").all? { |row| counter_row_valid?(row) }
  true
rescue KeyError, TypeError, ArgumentError, JSON::ParserError
  false
end

rtc_members = []
true_specs = [
  ["SYNTAX", "SYNTAX", nil], ["IMPLEMENTATION", "TRANSITIONLESS", nil],
  ["READINESS", "TRANSITIONLESS", nil], ["LAUNCH_BINDING", "TRANSITIONLESS", nil],
  ["START", "START", nil], ["JOURNAL_R00", "R00_MIN", nil],
  ["JOURNAL_OPERATION", "OP_T01", "T01"], ["JOURNAL_TERMINAL", "TERMINAL", nil],
  ["PREFIX", "PREFIX", nil], ["OUTER", "OUTER", nil], ["C5", "C5_MIN", nil],
  ["JOURNAL_OPERATION", "OP_B01", "B01"], ["JOURNAL_OPERATION", "OP_B02", "B02"],
  ["JOURNAL_OPERATION", "OP_B03", "B03"], ["JOURNAL_OPERATION", "OP_B04", "B04"],
  ["JOURNAL_R00", "R00_MAX", nil], ["C5", "C5_MAX", nil]
]
true_sources = true_specs.each_with_index.map do |(kind, catalog_instance, machine_instance), index|
  source = universal_source(kind, catalog_instance, machine_instance, index)
  input = universal_input(source)
  raise "universal base false #{kind}/#{catalog_instance}" unless evaluate_universal(source, input)
  id = "RTC_PUBLICATION_TRUE_#{kind}_#{catalog_instance}"
  add_value_case!(fixtures_by_id, vectors_by_id, rtc_members,
    id: id, operator: record_gate_definition[0],
    source_type: "RecordTransitionCounterConformanceSourceV12", source: source,
    input_type: "RecordTransitionCounterPublicationInputV12", input: input, expected: EVAL_TRUE)
  [id, source, input]
end

_, operation_source, operation_input = true_sources.find { |id, _, _| id.end_with?("OP_T01") }

kind_instance_source = clone(operation_source)
kind_instance_source["machine_instance_enum_or_null"] = "B04"
kind_instance_input = universal_input(kind_instance_source)
raise "kind/instance mutation true" if evaluate_universal(kind_instance_source, kind_instance_input)
add_value_case!(fixtures_by_id, vectors_by_id, rtc_members,
  id: "RTC_PUBLICATION_FALSE_CANDIDATE_KIND_INSTANCE", operator: record_gate_definition[0],
  source_type: "RecordTransitionCounterConformanceSourceV12", source: kind_instance_source,
  input_type: "RecordTransitionCounterPublicationInputV12", input: kind_instance_input, expected: EVAL_FALSE)

catalog_source = clone(operation_source)
catalog_source.fetch("transition_receipts").first["transition_id"] = "TR_OUTER_SELF_ENTRY_PROVED"
catalog_source.fetch("transition_receipts").first["from_state_enum"] = TRANSITION_BY_ID.fetch("TR_OUTER_SELF_ENTRY_PROVED").fetch("from_state_enum")
catalog_source.fetch("transition_receipts").first["to_state_enum_or_null"] = TRANSITION_BY_ID.fetch("TR_OUTER_SELF_ENTRY_PROVED").fetch("to_state_enum")
catalog_source.fetch("transition_receipts").first["trigger_evaluation"] = custom_predicate_evaluation(TRANSITION_BY_ID.fetch("TR_OUTER_SELF_ENTRY_PROVED").fetch("trigger_predicate_id"), true)
catalog_source.fetch("transition_receipts").first["counter_deltas_applied"] = clone(TRANSITION_BY_ID.fetch("TR_OUTER_SELF_ENTRY_PROVED").fetch("counter_deltas"))
catalog_source["counter_snapshots"] = snapshots_for(catalog_source.fetch("record_kind_enum"), catalog_source.fetch("transition_receipts"), catalog_source.fetch("counter_seed_rows"))
catalog_input = universal_input(catalog_source)
raise "catalog mutation true" if evaluate_universal(catalog_source, catalog_input)
add_value_case!(fixtures_by_id, vectors_by_id, rtc_members,
  id: "RTC_PUBLICATION_FALSE_CATALOG", operator: record_gate_definition[0],
  source_type: "RecordTransitionCounterConformanceSourceV12", source: catalog_source,
  input_type: "RecordTransitionCounterPublicationInputV12", input: catalog_input, expected: EVAL_FALSE)

definition_source = clone(operation_source)
definition_source.fetch("transition_receipts").first["from_state_enum"] = "WRONG_MACHINE_STATE"
definition_input = universal_input(definition_source)
raise "definition mutation true" if evaluate_universal(definition_source, definition_input)
add_value_case!(fixtures_by_id, vectors_by_id, rtc_members,
  id: "RTC_PUBLICATION_FALSE_DEFINITION_MACHINE", operator: record_gate_definition[0],
  source_type: "RecordTransitionCounterConformanceSourceV12", source: definition_source,
  input_type: "RecordTransitionCounterPublicationInputV12", input: definition_input, expected: EVAL_FALSE)

rejected_source = clone(operation_source)
rejected = rejected_source.fetch("transition_receipts").first
rejected["state_enum"] = "REJECTED"
rejected["to_state_enum_or_null"] = nil
rejected["counter_deltas_applied"] = []
rejected["error"] = error_pred("RECEIPT_REJECTED_CONFORMANCE")
rejected_input = universal_input(rejected_source)
raise "rejected mutation true" if evaluate_universal(rejected_source, rejected_input)
add_value_case!(fixtures_by_id, vectors_by_id, rtc_members,
  id: "RTC_PUBLICATION_FALSE_RECEIPT_REJECTED", operator: record_gate_definition[0],
  source_type: "RecordTransitionCounterConformanceSourceV12", source: rejected_source,
  input_type: "RecordTransitionCounterPublicationInputV12", input: rejected_input, expected: EVAL_FALSE)

source_join_source = clone(operation_source)
source_join_source.fetch("transition_receipts").first["source_instance_complete_json_sha256_or_null"] = "f" * 64
source_join_input = universal_input(source_join_source)
raise "source join mutation true" if evaluate_universal(source_join_source, source_join_input)
add_value_case!(fixtures_by_id, vectors_by_id, rtc_members,
  id: "RTC_PUBLICATION_FALSE_SOURCE_POINTER_HASH", operator: record_gate_definition[0],
  source_type: "RecordTransitionCounterConformanceSourceV12", source: source_join_source,
  input_type: "RecordTransitionCounterPublicationInputV12", input: source_join_input, expected: EVAL_FALSE)

through_source = clone(operation_source)
through_source.fetch("counter_snapshots").each { |snapshot| snapshot["through_transition_count_uint"] += 1 }
through_input = universal_input(through_source)
raise "through mutation true" if evaluate_universal(through_source, through_input)
add_value_case!(fixtures_by_id, vectors_by_id, rtc_members,
  id: "RTC_PUBLICATION_FALSE_SNAPSHOT_THROUGH_COUNT", operator: record_gate_definition[0],
  source_type: "RecordTransitionCounterConformanceSourceV12", source: through_source,
  input_type: "RecordTransitionCounterPublicationInputV12", input: through_input, expected: EVAL_FALSE)

fold_index = operation_input.fetch("counter_fold_rows").index { |row| !row.fetch("observed_uint_or_null").nil? }
raise "no exact fold row" unless fold_index
fold_path = "/counter_fold_rows/#{fold_index}/observed_uint_or_null"
old_fold_value = pointer_get(operation_input, fold_path)
fold_mutation = mutation_descriptor(operation_input, {fold_path => ["U_OR_NULL", old_fold_value + 1]})
fold_input = apply_input_mutation(operation_input, fold_mutation)
raise "fold mutation true" if evaluate_universal(operation_source, fold_input)
add_value_case!(fixtures_by_id, vectors_by_id, rtc_members,
  id: "RTC_PUBLICATION_FALSE_COUNTER_FOLD", operator: record_gate_definition[0],
  source_type: "RecordTransitionCounterConformanceSourceV12", source: operation_source,
  input_type: "RecordTransitionCounterPublicationInputV12", input: fold_input,
  expected: EVAL_FALSE, mutation: fold_mutation)

unavailable_source = clone(operation_source)
unavailable_source["projection_availability_enum"] = "UNAVAILABLE"
unavailable_source["error"] = error_pred("COUNTER_SEED_SOURCE_UNAVAILABLE")
add_unavailable_case!(fixtures_by_id, vectors_by_id, rtc_members,
  id: "RTC_PUBLICATION_UNAVAILABLE", operator: record_gate_definition[0],
  source_type: "RecordTransitionCounterConformanceSourceV12", source: unavailable_source)
add_type_case!(vectors_by_id, rtc_members, id: "RTC_PUBLICATION_TYPE_ERROR", operator: record_gate_definition[0])
raise "transition/counter publication count #{rtc_members.length}" unless rtc_members.length == 26
new_set_members["RECORD_TRANSITION_COUNTER_PUBLICATION_VECTORS"] = rtc_members

# Source-level replay for the shared R00 projection.  The legacy isolation
# vectors exercise only R00OperatorInputV12.  These four cases additionally
# execute the SELF+CONTROL binding materializer, including both conjuncts that
# were absent from the failure profile.
R["R00ProjectionBindingConformanceRowV12"] = {
  "keys" => ["binding_id", "state_enum"],
  "states_exact" => ["MATCH", "MISMATCH", "UNAVAILABLE"],
  "field_types_exact" => {"binding_id" => "S", "state_enum" => "LOCAL_ENUM(states_exact)"},
  "rule" => "CONFORMANCE_MATERIALIZER_CASE_ROW;binding_id_ORDER_IS_THE_EXACT_R00_FAILURE_BINDINGS_ORDER;MATCH_CONSTRUCTS_AND_RECURSIVELY_VALIDATES_THE_REAL_DECLARED_TYPED_SELF_OR_CONTROL_VALUE;MISMATCH_CONSTRUCTS_A_SCHEMA_VALID_WRAPPER_DISAGREEMENT;UNAVAILABLE_OMITS_EXACTLY_THAT_REQUIRED_RESOLUTION"
}
R["R00ProjectionConformanceSourceV12"] = {
  "keys" => ["availability_enum", "directory_operation_states", "created_side_effects", "topology_binding_rows", "first_unentered_ordinal_or_null", "error"],
  "availability_states_exact" => ["AVAILABLE", "UNAVAILABLE"],
  "field_types_exact" => {
    "availability_enum" => "LOCAL_ENUM(availability_states_exact)",
    "directory_operation_states" => "ARRAY(S,31,31,PreserveArgumentOrderV12)",
    "created_side_effects" => "ARRAY(B,31,31,PreserveArgumentOrderV12)",
    "topology_binding_rows" => "ARRAY(R00ProjectionBindingConformanceRowV12,6,6,R00BindingOrderV12)",
    "first_unentered_ordinal_or_null" => "U_OR_NULL", "error" => "REF(ErrorV12)"
  },
  "rule" => "CONFORMANCE_ONLY_CASE_SOURCE;THE_EVALUATOR_MATERIALIZES31_TYPED_DirectoryOperationV12_ROWS_ONE_NamedJoinSetV12_THREE_DirectorySnapshotV12_ROWS_ONE_JOURNAL_DirectorySnapshotV12_ONE_FirstUnenteredV12_AND_THE_HELD_CONTROL_/roots_VALUE_THEN_EXECUTES_THE_EXACT_PROJECT_R00_INPUT_PROGRAM;NO_CASE_ENUM_OR_EXPECTED_RESULT_DIRECTLY_SUPPLIES_AN_OUTPUT"
}

r00_binding_ids = D.fetch("custom_operator_binding_profiles_v12").fetch("R00_FAILURE_BINDINGS").map(&:first)
raise "R00 binding order" unless r00_binding_ids == %w[ROWS ROOT_ABSENCE ROOT_SNAPSHOTS JOURNAL_SNAPSHOT FIRST_UNENTERED ROOT_CONTROL]
projection_registry.fetch("projection_source_materializer_programs_v12")["CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL"] = {
  "source_class_enum" => "CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL",
  "source_type_id" => "R00ProjectionConformanceSourceV12",
  "output_type_id" => "R00OperatorInputV12",
  "binding_ids_exact_order" => r00_binding_ids,
  "production_projection_program_id" => "PROJECT_R00_INPUT",
  "materialization_rule" => "STRICTLY_TYPECHECK_SOURCE;CONSTRUCT_THE_REAL_SCHEMA_VALID_BINDING_VALUES_FOR_ALL_SIX_ROWS_FROM_ONE_IMMUTABLE_CONFORMANCE_R00_BODY_AND_ONE_HELD_CONTROL_ROOTS_VALUE;RESOLVE_JOURNAL_R00_TO_JOURNAL_EVIDENCE_SCOPE_ALIAS;EXECUTE_MAP_MEMBER_MAP_STATE_SIDE_EFFECT_EXPANDED_R00_BINDING_SET_SCHEMA_AND_PROFILE_CONJUNCTION_AND_PROJECT_FIRST_UNENTERED;DEEP_EQUAL_THE_INDEPENDENT_NORMALIZED_INPUT;MISSING_REQUIRED_BINDING_RETURNS_UNAVAILABLE_AND_SCHEMA_VALID_WRAPPER_DISAGREEMENT_RETURNS_VALUE_FALSE"
}
replay_sources << ["R00_FAILURE_CHAIN_VALID", "R00ProjectionConformanceSourceV12", "CONFORMANCE_R00_CURRENT_BODY_AND_CONTROL", "PROJECT_R00_INPUT"] unless replay_sources.any? { |row| row[0] == "R00_FAILURE_CHAIN_VALID" }

def r00_projection_source(states, topology_states, first_unentered, availability = "AVAILABLE")
  pair_table = D.dig("custom_operator_programs_v12", "R00_TOPOLOGY_PROGRAM", "state_created_side_effect_pairs_exact").to_h
  {
    "availability_enum" => availability,
    "directory_operation_states" => states,
    "created_side_effects" => states.map { |state| pair_table.fetch(state) },
    "topology_binding_rows" => %w[ROWS ROOT_ABSENCE ROOT_SNAPSHOTS JOURNAL_SNAPSHOT FIRST_UNENTERED ROOT_CONTROL].zip(topology_states).map do |binding_id, state|
      {"binding_id" => binding_id, "state_enum" => state}
    end,
    "first_unentered_ordinal_or_null" => first_unentered,
    "error" => availability == "AVAILABLE" ? error_none : error_pred("R00_REQUIRED_BINDING_UNAVAILABLE")
  }
end

def project_r00_source(source)
  return nil if source.fetch("availability_enum") == "UNAVAILABLE" || source.fetch("topology_binding_rows").any? { |row| row.fetch("state_enum") == "UNAVAILABLE" }
  {
    "states" => clone(source.fetch("directory_operation_states")),
    "created_side_effects" => clone(source.fetch("created_side_effects")),
    "topology_projection_exact_bool" => source.fetch("topology_binding_rows").all? { |row| row.fetch("state_enum") == "MATCH" },
    "first_unentered_ordinal_or_null" => source.fetch("first_unentered_ordinal_or_null")
  }
end

def evaluate_r00_failure(input)
  return false unless input.fetch("topology_projection_exact_bool")
  states = input.fetch("states")
  pairs = D.dig("custom_operator_programs_v12", "R00_TOPOLOGY_PROGRAM", "state_created_side_effect_pairs_exact").to_h
  return false unless states.length == 31 && input.fetch("created_side_effects") == states.map { |state| pairs.fetch(state) }
  failure_indices = states.each_index.select { |index| D.dig("custom_operator_programs_v12", "R00_TOPOLOGY_PROGRAM", "failure_symbols_exact").include?(states.fetch(index)) }
  return false unless failure_indices.length == 1
  failure_index = failure_indices.first
  return false unless states[0...failure_index].all? { |state| state == "CREATED_JOINED" }
  return false unless states[(failure_index + 1)..].all? { |state| state == "NOT_ENTERED" }
  input.fetch("first_unentered_ordinal_or_null") == (failure_index == 30 ? nil : failure_index + 1)
rescue KeyError
  false
end

r00_source_members = clone(CAT.fetch("conformance_set_rows_exact").find { |row| row.fetch(0) == "R00_FAILURE_VECTORS" }.fetch(1))
new_set_members["R00_FAILURE_VECTORS"] = r00_source_members
r00_failure_states = ["OPEN_FAILED"] + Array.new(30, "NOT_ENTERED")
r00_failure_source = r00_projection_source(r00_failure_states, Array.new(6, "MATCH"), 1)
r00_failure_input = project_r00_source(r00_failure_source)
raise "R00 source failure false" unless evaluate_r00_failure(r00_failure_input)
add_value_case!(fixtures_by_id, vectors_by_id, r00_source_members,
  id: "R00_SOURCE_FAILURE_TRUE", operator: "R00_FAILURE_CHAIN_VALID",
  source_type: "R00ProjectionConformanceSourceV12", source: r00_failure_source,
  input_type: "R00OperatorInputV12", input: r00_failure_input, expected: EVAL_TRUE)

r00_unavailable_source = r00_projection_source(r00_failure_states, ["MATCH", "MATCH", "MATCH", "MATCH", "MATCH", "UNAVAILABLE"], 1, "UNAVAILABLE")
add_unavailable_case!(fixtures_by_id, vectors_by_id, r00_source_members,
  id: "R00_SOURCE_REQUIRED_BINDING_UNAVAILABLE", operator: "R00_FAILURE_CHAIN_VALID",
  source_type: "R00ProjectionConformanceSourceV12", source: r00_unavailable_source)

[[15, "MIDDLE"], [30, "FINAL"]].each do |failure_index, label|
  states = Array.new(failure_index, "CREATED_JOINED") + ["SYNC_FAILED"] + Array.new(30 - failure_index, "NOT_ENTERED")
  first_unentered = failure_index == 30 ? nil : failure_index + 1
  source = r00_projection_source(states, Array.new(6, "MATCH"), first_unentered)
  input = project_r00_source(source)
  raise "R00 #{label} boundary false" unless evaluate_r00_failure(input)
  add_value_case!(fixtures_by_id, vectors_by_id, r00_source_members,
    id: "R00_SOURCE_#{label}_FAILURE_TRUE", operator: "R00_FAILURE_CHAIN_VALID",
    source_type: "R00ProjectionConformanceSourceV12", source: source,
    input_type: "R00OperatorInputV12", input: input, expected: EVAL_TRUE)
end

r00_wrong_first_source = r00_projection_source(r00_failure_states, Array.new(6, "MATCH"), 2)
r00_wrong_first_input = project_r00_source(r00_wrong_first_source)
raise "R00 wrong first-unentered marked true" if evaluate_r00_failure(r00_wrong_first_input)
add_value_case!(fixtures_by_id, vectors_by_id, r00_source_members,
  id: "R00_SOURCE_WRONG_FIRST_UNENTERED_FALSE", operator: "R00_FAILURE_CHAIN_VALID",
  source_type: "R00ProjectionConformanceSourceV12", source: r00_wrong_first_source,
  input_type: "R00OperatorInputV12", input: r00_wrong_first_input, expected: EVAL_FALSE)
raise "R00 failure set count #{r00_source_members.length}" unless r00_source_members.length == 14

# JOURNAL_CHAIN_PROGRAM has distinct preterminal and postterminal profiles.
# Conform all six preterminal failure cuts instead of inferring them from the
# already-covered postterminal rows.
jchain_members = clone(CAT.fetch("conformance_set_rows_exact").find { |row| row.fetch(0) == "JOURNAL_CHAIN_VECTORS" }.fetch(1))
new_set_members["JOURNAL_CHAIN_VECTORS"] = jchain_members
6.times do |failure_index|
  symbols = []
  symbols << (failure_index.zero? ? "FAIL_R00" : "PASS_R00")
  5.times do |operation_index|
    symbols << if operation_index < failure_index - 1
      "PASS_OP"
    elsif operation_index == failure_index - 1
      "FAIL_OP"
    else
      "ABSENT"
    end
  end
  input = {"profile_enum" => "PRETERMINAL", "symbols" => symbols, "source_complete_bool" => true}
  id = "JCHAIN_TRUE_PRE_FAIL_#{failure_index}"
  fixture_id = add_fixture!(fixtures_by_id, "JCHAIN_PRE_FAIL_#{failure_index}", "JournalChainOperatorInputV12", input)
  add_vector!(vectors_by_id, jchain_members,
    {
      "vector_id" => id, "operator_id" => "JOURNAL_CHAIN_OUTCOME_IS",
      "token_operand_enum_or_null" => "FAIL",
      "bindings" => [value_binding("NORMALIZED_INPUT", fixture_id)],
      "expected_result" => clone(EVAL_TRUE)
    })
end
raise "journal chain set count #{jchain_members.length}" unless jchain_members.length == 19

# The other four original input projections also receive an exact source route
# in addition to their retained normalized-input isolation vectors.  Together
# with the R00 pair above this is the five-program source-projection family.
R["LegacyCustomProjectionConformanceSourceV12"] = {
  "keys" => ["projection_program_id", "source_case_enum", "availability_enum", "same_body_instance_id", "same_control_instance_id", "error"],
  "source_cases_exact" => ["VALID", "REQUIRED_SOURCE_UNAVAILABLE"],
  "availability_states_exact" => ["AVAILABLE", "UNAVAILABLE"],
  "field_types_exact" => {
    "projection_program_id" => "S", "source_case_enum" => "LOCAL_ENUM(source_cases_exact)",
    "availability_enum" => "LOCAL_ENUM(availability_states_exact)",
    "same_body_instance_id" => "S", "same_control_instance_id" => "S",
    "error" => "REF(ErrorV12)"
  },
  "rule" => "CONFORMANCE_ONLY_CASE_SELECTOR;THE_EXACT_MATERIALIZER_CONSTRUCTS_ALL_DECLARED_TYPED_BINDINGS_FROM_ONE_IMMUTABLE_CURRENT_BODY_INSTANCE_AND_ONE_HELD_CONTROL_INSTANCE_THEN_EXECUTES_THE_NAMED_PRODUCTION_PROJECTION;NO_NORMALIZED_OUTPUT_EXPECTATION_OR_VECTOR_ID_IS_READ"
}

legacy_projection_specs = [
  ["JOURNAL_ENVELOPE_CHAIN_VALID", "PROJECT_JOURNAL_ENVELOPE_INPUT", "JournalEnvelopeOperatorInputV12", "JE_GENESIS", "JOURNAL_ENVELOPE_VECTORS", nil],
  ["COUNTER_FOLD_VALID", "PROJECT_COUNTER_INPUT_SET", "CounterFoldInputSetV12", "COUNTER_EXACT_TRUE", "COUNTER_FOLD_VECTORS", nil],
  ["JOURNAL_CHAIN_OUTCOME_IS", "PROJECT_JOURNAL_CHAIN_INPUT", "JournalChainOperatorInputV12", "JCHAIN_PRE_PASS", "JOURNAL_CHAIN_VECTORS", "PASS"],
  ["OUTER_CHAIN_OUTCOME_IS", "PROJECT_OUTER_CHAIN_INPUT", "OuterChainOperatorInputV12", "OUTER_PASS", "OUTER_CHAIN_VECTORS", "PASS"]
]
projection_registry.fetch("projection_source_materializer_programs_v12")["CONFORMANCE_LEGACY_CUSTOM_SOURCE"] = {
  "source_class_enum" => "CONFORMANCE_LEGACY_CUSTOM_SOURCE",
  "source_type_id" => "LegacyCustomProjectionConformanceSourceV12",
  "program_rows_exact" => legacy_projection_specs.map { |row| row.first(3) },
  "materialization_rule" => "FOR_EACH_PROGRAM_BUILD_THE_REAL_SCHEMA_VALID_EVIDENCE_SOURCE_RAW_CURRENT_BODY_CURRENT_FRAME_CONTEXT_CONTROL_AND_PREDECESSOR_BINDINGS_REQUIRED_BY_ITS_EXACT_PROFILE;REQUIRE_ONE_SHARED_BODY_AND_ONE_SHARED_HELD_CONTROL_ID;EXECUTE_THE_UNMODIFIED_PRODUCTION_FIELD_ROWS;DEEP_EQUAL_THE_INDEPENDENT_NORMALIZED_INPUT;AN_EXACT_REQUIRED_SOURCE_UNAVAILABLE_CUT_RETURNS_UNAVAILABLE_WITH_NO_PARTIAL_CONSTANT_OUTPUT"
}

def decoded_fixture_value(fixtures, fixture_id)
  row = fixtures.fetch(fixture_id)
  bytes = Base64.strict_decode64(row.fetch("canonical_json_base64"))
  raise "fixture bytes/hash #{fixture_id}" unless bytes.bytesize == row.fetch("bytes_uint") && sha(bytes) == row.fetch("sha256")
  value = JSON.parse(bytes)
  raise "fixture canonical #{fixture_id}" unless canon(value) == bytes
  value
end

legacy_projection_specs.each do |operator_id, program_id, input_type, source_fixture_id, set_id, operand|
  source_base = {
    "projection_program_id" => program_id, "source_case_enum" => "VALID",
    "availability_enum" => "AVAILABLE", "same_body_instance_id" => "#{program_id}:BODY",
    "same_control_instance_id" => "V12_HELD_CONTROL", "error" => error_none
  }
  input = decoded_fixture_value(fixtures_by_id, source_fixture_id)
  valid_id = "SOURCE_PROJECTION_#{program_id}_TRUE"
  source_id = add_fixture!(fixtures_by_id, "#{valid_id}_SOURCE", "LegacyCustomProjectionConformanceSourceV12", source_base)
  input_id = add_fixture!(fixtures_by_id, "#{valid_id}_INPUT", input_type, input)
  set_members = if new_set_members.key?(set_id)
    new_set_members.fetch(set_id)
  else
    clone(CAT.fetch("conformance_set_rows_exact").find { |row| row.fetch(0) == set_id }.fetch(1)).tap { |members| new_set_members[set_id] = members }
  end
  add_vector!(vectors_by_id, set_members,
    {
      "vector_id" => valid_id, "operator_id" => operator_id,
      "token_operand_enum_or_null" => operand,
      "bindings" => [value_binding("NORMALIZED_INPUT", input_id), value_binding("SOURCE_INSTANCE", source_id)],
      "expected_result" => clone(EVAL_TRUE)
    })

  unavailable_source = clone(source_base)
  unavailable_source["source_case_enum"] = "REQUIRED_SOURCE_UNAVAILABLE"
  unavailable_source["availability_enum"] = "UNAVAILABLE"
  unavailable_source["error"] = error_pred("REQUIRED_PROJECTION_SOURCE_UNAVAILABLE")
  unavailable_id = "SOURCE_PROJECTION_#{program_id}_UNAVAILABLE"
  unavailable_source_id = add_fixture!(fixtures_by_id, "#{unavailable_id}_SOURCE", "LegacyCustomProjectionConformanceSourceV12", unavailable_source)
  add_vector!(vectors_by_id, set_members,
    {
      "vector_id" => unavailable_id, "operator_id" => operator_id,
      "token_operand_enum_or_null" => operand,
      "bindings" => [unavailable_binding("NORMALIZED_INPUT"), value_binding("SOURCE_INSTANCE", unavailable_source_id)],
      "expected_result" => clone(EVAL_UNAVAILABLE)
    })
  replay_sources << [operator_id, "LegacyCustomProjectionConformanceSourceV12", "CONFORMANCE_LEGACY_CUSTOM_SOURCE", program_id] unless replay_sources.any? { |row| row[0] == operator_id }
end

# Materialize the completed custom catalog in exact schema/order form.  Global
# dependency and receipt hashes are intentionally left to the final reseal
# pass after timing and observation mechanics are also closed.
CAT["input_schema_ids_exact_order"] = [
  "JournalEnvelopeOperatorInputV12", "R00OperatorInputV12", "CounterFoldOperatorInputV12",
  "CounterFoldInputSetV12", "RecordTransitionCounterPublicationInputV12",
  "JournalChainOperatorInputV12", "OuterChainOperatorInputV12",
  "OuterNotAttemptedCutOperatorInputV12", "OuterPublicationEndpointInputV12",
  "StartPublicationInputV12", "PrefixPublicationInputV12", "OuterPublicationInputV12"
]
CAT["fixtures"] = fixtures_by_id.values.sort_by { |row| row.fetch("fixture_id") }
CAT["vectors"] = vectors_by_id.values.sort_by { |row| row.fetch("vector_id") }
CAT["expected_result_rows"] = CAT.fetch("vectors").map { |row| [row.fetch("vector_id"), clone(row.fetch("expected_result"))] }
set_members_by_id = CAT.fetch("conformance_set_rows_exact").to_h
new_set_members.each { |set_id, members| set_members_by_id[set_id] = members }
CAT["conformance_set_rows_exact"] = D.fetch("custom_operator_definitions_v12").map do |definition|
  set_id = definition.fetch(7)
  [set_id, set_members_by_id.fetch(set_id)]
end
CAT["fixture_count_uint"] = CAT.fetch("fixtures").length
CAT["vector_count_uint"] = CAT.fetch("vectors").length
raise "custom vector total #{CAT.fetch("vector_count_uint")}" unless CAT.fetch("vector_count_uint") == 259
raise "custom set partition mismatch" unless CAT.fetch("conformance_set_rows_exact").flat_map { |row| row.fetch(1) }.sort == CAT.fetch("vectors").map { |row| row.fetch("vector_id") }.sort

array_binding = D.fetch("custom_operator_conformance_array_bindings_v12")
array_binding["rule"] = "EXACT_FOUR_ROWS_IN_CATALOG_FIELD_ORDER;EACH_ROW_VALIDATES_AGAINST_ConformanceCatalogArrayBindingV12_THEN_RESOLVES_AND_HASH_JOINS_ITS_SCHEMA_BEFORE_ARRAY_ROW_TYPE_ORDER_DIGEST_REPLAY_OR_LOSSLESS_PROJECTION;conformance_set_rows_exact_IS_AN_EXACT_DUPLICATE_FREE_PARTITION_OF_ALL259_VECTOR_IDS"

D["custom_operator_definition_rule"] = D.fetch("custom_operator_definition_rule").sub(
  "THE_ONLY_INTERPROGRAM_EDGES_ARE_R00_FAILURE_PROGRAM_TO_R00_TOPOLOGY_PROGRAM_AND_OUTER_PUBLICATION_PROGRAM_TO_OUTER_PUBLICATION_ENDPOINT_PROGRAM",
  "THE_ONLY_INTERPROGRAM_EDGES_ARE_R00_FAILURE_PROGRAM_TO_R00_TOPOLOGY_PROGRAM_OUTER_PUBLICATION_PROGRAM_TO_OUTER_PUBLICATION_ENDPOINT_PROGRAM_AND_RECORD_TRANSITION_COUNTER_PUBLICATION_PROGRAM_TO_COUNTER_FOLD_PROGRAM"
)
CAT["coverage_exact"] = [
  "EACH_OF_THE12_OPERATORS_VALUE_TRUE_VALUE_FALSE_UNAVAILABLE_AND_TYPE_ERROR_WHERE_IN_DOMAIN",
  "ALL_FIVE_ORIGINAL_UNIQUE_SOURCE_PROJECTION_PROGRAMS_VALID_AND_REQUIRED_SOURCE_UNAVAILABLE",
  "ALL_FIVE_R00_FAILURE_SYMBOLS_MIDDLE_AND_FINAL_BOUNDARIES_WRONG_FIRST_UNENTERED_AND_DOUBLE_FAILURE_REJECT",
  "ALL_SIX_PRETERMINAL_AND_ALL_SIX_POSTTERMINAL_JOURNAL_FAILURE_CUTS",
  "COUNTER_EXACT_LOWER_BOUND_UNKNOWN_NOT_APPLICABLE_AND_MISSING_IMPORT",
  "OUTER_PASS_FAIL_MISMATCH_AND_INCOMPLETE_SOURCE",
  "CUT9_CAUSAL_ENDPOINT12_BRANCH_START_PREFIX_AND49_OUTER_STATUS_PUBLICATION",
  "UNIVERSAL_TRANSITION_COUNTER_ALL11_KINDS5_OPERATION_INSTANCES_R00_AND_C5_MIN_MAX_AND7_FALSE_AXES"
]

if ENV["V12_CUSTOM_WRITE"] == "1"
  V12ControlFile.overwrite_scratch(CONTROL_INPUT, JSON.pretty_generate(J) + "\n")
end
