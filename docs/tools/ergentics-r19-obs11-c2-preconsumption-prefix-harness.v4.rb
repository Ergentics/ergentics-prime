#!/usr/bin/ruby

# Exact, non-consuming C2 prefix harness. It evaluates the closed controller
# only through the complete bootstrap_preflight definition and never evaluates
# the controller bottom that constructs state, journal, or build namespaces.

require "digest"
require "json"

class C2PrefixHarnessFailure < StandardError; end

HARNESS_EXPECTED_ENVIRONMENT = {
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze
HARNESS_SOURCE =
  "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/" \
  ".phase-a-v2-fixture-identity-restore-only-staging/docs/tools/" \
  "ergentics-r19-obs11-c2-build-controller.rb"
HARNESS_SOURCE_EXPECTED = {
  "bytes" => 150_714,
  "device" => 16_777_231,
  "gid" => 20,
  "inode" => 17_945_704,
  "mode" => "0644",
  "nlink" => 1,
  "sha256" =>
    "2f1568b11f715a007cda4e74e65bd205fc330e4a9a7556d0adcfa8296aa5a9d7",
  "uid" => 501,
}.freeze
HARNESS_PREFIX_MARKER =
  "\njournal = nil\nstate = C2StateMachine.new\n".b.freeze
HARNESS_PREFIX_EXPECTED = {
  "bytes" => 143_916,
  "lines" => 3_879,
  "sha256" =>
    "3328e81448266ad8a63dbeca72fba580e9f91556aaede391f92e30c37084e8b4",
}.freeze
HARNESS_FROZEN_ROOTS = [
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-build-a-v1",
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-build-b-v1",
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-execution-closure-v1",
  "/private/tmp/ergentics-r19-obs11-chain-runner-296d32da-build-b-witness-closure-v1",
  "/private/tmp/ergentics-r19-obs11-c2-build-control-8405636a-v1",
].freeze
HARNESS_LANGUAGE_AND_FD_POLICY = {
  "eventual_swift_spawn_close_others_frozen" => true,
  "python" => "FORBIDDEN",
  "ruby_fd3_through_fd7_pipe_deviation" =>
    "CATALOGED_UNSUITABLE_AS_SWIFT_FD_DOMAIN_PROXY",
  "ruby_inherited_fd_census_in_this_harness" => false,
  "swift_fd_domain_inference_from_this_harness" => false,
}.freeze

def harness_fail(code)
  raise C2PrefixHarnessFailure, code
end

def harness_mode(stat)
  format("%04o", stat.mode & 0o7777)
end

def harness_source_identity(stat, sha256:)
  {
    "bytes" => stat.size,
    "device" => stat.dev,
    "gid" => stat.gid,
    "inode" => stat.ino,
    "mode" => harness_mode(stat),
    "nlink" => stat.nlink,
    "sha256" => sha256,
    "uid" => stat.uid,
  }
end

def harness_canonical(value)
  case value
  when Hash
    value.keys.sort.each_with_object({}) do |key, output|
      output[key] = harness_canonical(value.fetch(key))
    end
  when Array
    value.map { |entry| harness_canonical(entry) }
  else
    value
  end
end

def harness_json(value)
  JSON.generate(harness_canonical(value))
end

def harness_require_absent(path, label)
  File.lstat(path)
  harness_fail("#{label}:PRESENT:#{path}")
rescue Errno::ENOENT
  true
end

def harness_close(io)
  return nil if io.nil? || io.closed?
  io.close
  nil
rescue Errno::EINTR
  retry
rescue StandardError => error
  error.class.name
end

def harness_source_revalidate(io, label)
  before = io.stat
  io.rewind
  bytes = io.read
  after = io.stat
  named = File.lstat(HARNESS_SOURCE)
  digest = Digest::SHA256.hexdigest(bytes)
  identity = harness_source_identity(after, sha256: digest)
  harness_fail("#{label}:HELD_DRIFT") unless
    [before.dev, before.ino, before.mode, before.uid, before.gid,
     before.nlink, before.size] ==
      [after.dev, after.ino, after.mode, after.uid, after.gid,
       after.nlink, after.size]
  harness_fail("#{label}:NAMED_REJOIN") unless
    [named.dev, named.ino, named.mode, named.uid, named.gid,
     named.nlink, named.size] ==
      [after.dev, after.ino, after.mode, after.uid, after.gid,
       after.nlink, after.size]
  harness_fail("#{label}:EXPECTED_IDENTITY") unless
    identity == HARNESS_SOURCE_EXPECTED
  [bytes, identity]
end

source_io = nil
preflight = nil
close_results = []
operations = {
  "apple_ruby_harness_entries" => 1,
  "bootstrap_preflight_entries" => 0,
  "continuity_revalidation_entries_after_bootstrap" => 0,
  "controller_bottom_entries" => 0,
  "controller_full_invocations" => 0,
  "dot_build_snapshot_entries_after_bootstrap" => 0,
  "filesystem_creation_call_entries" => 0,
  "journal_constructor_entries" => 0,
  "process_signal_call_entries" => 0,
  "process_spawn_call_entries" => 0,
  "product_execution_entries" => 0,
  "python_entries" => 0,
  "source_prefix_evaluation_entries" => 0,
  "state_machine_constructor_entries" => 0,
  "swiftpm_spawn_entries" => 0,
}

begin
  harness_fail("ARGV") unless ARGV.empty?
  harness_fail("ENVIRONMENT") unless
    ENV.to_h == HARNESS_EXPECTED_ENVIRONMENT
  harness_fail("CWD") unless Dir.pwd == "/private/var/empty"
  HARNESS_FROZEN_ROOTS.each do |path|
    harness_require_absent(path, "BEFORE")
  end

  named_before = File.lstat(HARNESS_SOURCE)
  harness_fail("SOURCE_NOT_REGULAR") unless named_before.file?
  source_io = File.open(HARNESS_SOURCE, "rb")
  source_io.close_on_exec = true
  harness_fail("SOURCE_NOT_CLOEXEC") unless source_io.close_on_exec?
  source, source_identity = harness_source_revalidate(source_io, "CAPTURE")
  harness_fail("SOURCE_LINES") unless source.count("\n") == 4_054
  harness_fail("PREFIX_MARKER_COUNT") unless
    source.scan(HARNESS_PREFIX_MARKER).length == 1
  marker_offset = source.index(HARNESS_PREFIX_MARKER)
  harness_fail("PREFIX_MARKER_OFFSET") unless
    marker_offset == HARNESS_PREFIX_EXPECTED.fetch("bytes")
  prefix = source.byteslice(0, marker_offset)
  prefix_identity = {
    "bytes" => prefix.bytesize,
    "lines" => prefix.count("\n"),
    "sha256" => Digest::SHA256.hexdigest(prefix),
  }
  harness_fail("PREFIX_IDENTITY") unless
    prefix_identity == HARNESS_PREFIX_EXPECTED

  operations["source_prefix_evaluation_entries"] += 1
  eval(prefix, TOPLEVEL_BINDING, HARNESS_SOURCE, 1)
  operations["bootstrap_preflight_entries"] += 1
  preflight = bootstrap_preflight
  continuity = preflight.fetch("continuity")
  tmp_io = preflight.fetch("tmp_io")
  baseline = preflight.fetch("dot_build")

  harness_fail("CONTINUITY_ARMED") if continuity.armed
  harness_fail("CONTINUITY_POISONED") if continuity.poisoned
  harness_fail("CONTINUITY_EVENTS") unless continuity.events.empty?
  operations["continuity_revalidation_entries_after_bootstrap"] += 1
  continuity.revalidate!("READINESS_PREFIX_POST_PREFLIGHT_1")
  operations["dot_build_snapshot_entries_after_bootstrap"] += 1
  after_snapshot = TreeSnapshot.new(SOURCE_LOCAL_DOT_BUILD).receipt
  harness_fail("DOT_BUILD_DRIFT") unless after_snapshot == baseline
  operations["continuity_revalidation_entries_after_bootstrap"] += 1
  continuity.revalidate!("READINESS_PREFIX_POST_PREFLIGHT_2")
  HARNESS_FROZEN_ROOTS.each do |path|
    require_absent(path, "READINESS_PREFIX_AFTER")
    harness_require_absent(path, "AFTER")
  end

  _source_after, source_identity_after =
    harness_source_revalidate(source_io, "FINAL")
  harness_fail("SOURCE_IDENTITY_DRIFT") unless
    source_identity_after == source_identity

  continuity_receipt = continuity.receipt
  tmp_receipt = identity(tmp_io)
  node_count = continuity.nodes.length
  continuity.nodes.each do |node|
    close_results << harness_close(node.io)
  end
  close_results << harness_close(tmp_io)
  close_results << harness_close(source_io)
  harness_fail("DESCRIPTOR_CLOSE") unless close_results.all?(&:nil?)
  harness_fail("DESCRIPTOR_STILL_OPEN") unless
    continuity.nodes.all? { |node| node.io.closed? } &&
      tmp_io.closed? && source_io.closed?

  receipt = {
    "bottom_entry_evaluated" => false,
    "continuity" => continuity_receipt,
    "controller" => process_receipt(preflight.fetch("controller_join")),
    "controller_source" => source_identity_after,
    "descriptor_close_count" => node_count + 2,
    "dot_build" => after_snapshot,
    "frozen_roots_after" =>
      HARNESS_FROZEN_ROOTS.to_h { |path| [path, "ABSENT"] },
    "historical_operations_reinterpreted" => false,
    "language_and_fd_policy" => HARNESS_LANGUAGE_AND_FD_POLICY,
    "mapped_ruby" => preflight.fetch("mapped_ruby"),
    "operation_scope" => "THIS_EXACT_HARNESS_PROCESS_ONLY",
    "operations" => operations,
    "prefix" => prefix_identity,
    "status" => "PASS_EXACT_NONCONSUMING_C2_PREFIX_PREFLIGHT_V4",
    "tmp" => tmp_receipt,
  }
  STDOUT.write(harness_json(receipt) + "\n")
rescue StandardError => error
  if preflight
    continuity = preflight["continuity"]
    continuity.nodes.each { |node| close_results << harness_close(node.io) } if
      continuity
    close_results << harness_close(preflight["tmp_io"])
  end
  close_results << harness_close(source_io)
  message = error.message.b
  bounded_message = message.byteslice(0, 1_024)
  failure = {
    "bottom_entry_evaluated" => false,
    "cleanup_close_attempts" => close_results.length,
    "cleanup_close_errors" => close_results.compact,
    "error_class" => error.class.name,
    "error_message_bytes" => message.bytesize,
    "error_message_prefix_hex" => bounded_message.unpack1("H*"),
    "error_message_prefix_truncated" => bounded_message.bytesize != message.bytesize,
    "error_message_sha256" => Digest::SHA256.hexdigest(message),
    "historical_operations_reinterpreted" => false,
    "language_and_fd_policy" => HARNESS_LANGUAGE_AND_FD_POLICY,
    "operation_scope" => "THIS_EXACT_HARNESS_PROCESS_ONLY",
    "operations" => operations,
    "process_exit_closes_unreachable_partial_preflight_descriptors" => true,
    "status" => "FAIL_NONCONSUMING_C2_PREFIX_PREFLIGHT_V4",
  }
  STDERR.write(harness_json(failure) + "\n")
  exit(70)
end
