#!/usr/bin/ruby
# frozen_string_literal: true

# Retired 2026-09-20: this historical r18-successor-stopped-adoption-canary helper has
# failure paths that can remain active indefinitely. Reject all roles before
# bootstrap intake, library loading, process inspection, or child creation.
# The historical body below is unchanged; its original Git blob is
# c59d7bf98972dccbfe4e8c76c114b2fdf0bd3229. Existing live instances are unaffected.
begin
  STDERR.write_nonblock(
    "{\"schema\":\"prime-driver-v2-r18-successor-stopped-adoption-canary-retirement/v1\"," \
    "\"status\":\"R18_SUCCESSOR_STOPPED_ADOPTION_CANARY_RETIRED\",\"launch_allowed\":false," \
    "\"gate_e_outcome\":\"ABSTAIN\",\"gate_e_clearance\":0}\n",
    exception: false
  )
rescue IOError, SystemCallError
  # Diagnostics are best-effort, including closed or full output pipes.
ensure
  Process.exit!(70)
end

# This is a disposable successor proof for the corrected R18 stopped-adoption
# transition. It selectively executes two hash-pinned regions of the committed
# guardian without loading guardian top-level code. It invokes no Swift, Git,
# shell, epoch constructor, production guardian, or mechanics harness.

ROLE_KEY = "R18_SUCCESSOR_STOPPED_ADOPTION_CANARY_ROLE"
CONTROLLER_ROLE = "controller"
WORKER_ROLE = "worker"
INCOMING_UMASK = File.umask(0o077)
BASE_ENVIRONMENT = {
  "LANG" => "C.UTF-8",
  "LC_ALL" => "C.UTF-8",
  "TZ" => "UTC",
  "PATH" => "/usr/bin:/bin",
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0"
}.freeze

role = ENV[ROLE_KEY]
expected_bootstrap_environment = BASE_ENVIRONMENT.merge(ROLE_KEY => role)
unless [CONTROLLER_ROLE, WORKER_ROLE].include?(role) &&
       ARGV.empty? && ENV.to_h == expected_bootstrap_environment
  STDERR.write("{\"error\":\"unexpected-bootstrap\"," \
    "\"status\":\"R18_SUCCESSOR_STOPPED_ADOPTION_CANARY_FAILED\"}\n")
  exit(70)
end

require "digest"
require "fiddle/import"
require "json"
require "ripper"
require "set"
require "time"

class R18Failure < StandardError
end

class GuardianDeadline < StandardError
end

module R18LibC
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)

  extern "int getsid(int)"
  extern "int getpgid(int)"
  extern "int kill(int, int)"
  extern "int raise(int)"
  extern "int fcntl(int, int)"
  extern "int mkdirat(int, const char *, unsigned int)"
  extern "int openat(int, const char *, int, unsigned int)"
  extern "int sysctlbyname(const char *, void *, void *, void *, unsigned long)"
end

module R18Libproc
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)

  extern "int proc_listpids(unsigned int, unsigned int, void *, int)"
  extern "int proc_pidinfo(int, int, unsigned long long, void *, int)"
end

SCRIPT_PATH = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r18-successor-stopped-adoption-canary.rb"
GUARDIAN_PATH =
  "/Users/ergentics/Documents/Codex/2026-08-09/" \
  "resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/" \
  "docs/tools/prime-driver-v2-r18-guardian.rb"
RUBY_IMAGE = "/usr/bin/ruby"
EXPECTED_CWD = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging"
MARKER_PARENT_PATH = "/private/tmp"
MARKER_LEAF = "gate-e1-4-r18-successor-stopped-adoption-canary-be1b2af-a550c1b"
MARKER_PATH = "#{MARKER_PARENT_PATH}/#{MARKER_LEAF}"
GUARDIAN_COMMIT = "a550c1b166bb94b0ae674202b144a1bfc071ffc0"
GUARDIAN_TREE = "14a7b38a524e9c19cbf848452124beceaec8dedd"
GUARDIAN_BLOB = "35596488986fcf98aa792c0c2d0a558c59109aed"
GUARDIAN_BYTES = 76_970
GUARDIAN_SHA256 =
  "33d54336a8cfd5427f52a27e0f3ccec965f7b3eb43720e46dfbcfdd349894aa2"
GUARDIAN_IDENTITY = {
  "device" => 16_777_231,
  "inode" => 17_416_984,
  "uid" => 501,
  "gid" => 20,
  "mode" => 0o644,
  "nlink" => 1,
}.freeze
GUARDIAN_ACTUATION_REGION = {
  "start" => "def group_member_receipt(member)\n",
  "finish" => "class ChildLifecycle\n",
  "offset" => 38_586,
  "bytes" => 6_680,
  "lines" => 177,
  "sha256" =>
    "cef63a1dddc35d57aa5c00f88b9d3de893c9d3a9e3238a1a6953e090062139f4",
}.freeze
GUARDIAN_ACTUATOR_REGION = {
  "start" => "class GroupActuator\n",
  "finish" => "def wait_generation_absence(pid, uniqueid, deadline)\n",
  "offset" => 45_863,
  "bytes" => 8_944,
  "lines" => 254,
  "sha256" =>
    "00cb0692997ae16f9a512f7362c37c15eb60b0f74927a20bc0d993e587b9ca1d",
}.freeze

EXPECTED_RUBY = {
  "engine" => "ruby",
  "version" => "2.6.10",
  "patchlevel" => 210,
  "platform" => "universal.arm64e-darwin25"
}.freeze
EXPECTED_RUBY_IMAGE = {
  "device" => 16_777_231,
  "inode" => 1_152_921_500_312_572_705,
  "uid" => 0,
  "gid" => 0,
  "mode" => 0o555,
  "nlink" => 1,
  "size" => 135_200,
  "sha256" => "9d6ff3e289c7d908e3c785e0bedd6692d1d6a3377965c88c04d847104b7c892c"
}.freeze
EXPECTED_RUBY_ARM64E_UUID_HEX = "eb2540b7e13236beb719619d0fbf7203"
EXPECTED_STDIN = {
  "device" => -458_678_049,
  "inode" => 336,
  "rdevice" => 50_331_650,
  "uid" => 0,
  "gid" => 0,
  "mode" => 0o666
}.freeze
EXPECTED_SYSCTLS = {
  "kern.osproductversion" => "26.5.2",
  "kern.osversion" => "25F84",
  "kern.osrelease" => "25.5.0",
  "kern.version" => "Darwin Kernel Version 25.5.0: Tue Jun  9 22:28:34 PDT 2026; root:xnu-12377.121.10~1/RELEASE_ARM64_T6050",
  "hw.machine" => "arm64"
}.freeze
EXPECTED_CREDENTIALS = {
  "uid" => 501,
  "euid" => 501,
  "gid" => 20,
  "egid" => 20,
  "groups" => [12, 20, 33, 61, 79, 80, 81, 98, 100, 204, 250, 395, 398, 399, 400, 701]
}.freeze
EXPECTED_PRIVATE_TMP = {
  "device" => 16_777_231,
  "inode" => 774_813,
  "uid" => 0,
  "gid" => 0,
  "mode" => 0o1777
}.freeze
EXPECTED_MARKER_GID = 0

PROC_PGRP_ONLY = 2
PROC_RUID_ONLY = 5
RUID_SELECTOR = 501
PROC_PIDTBSDINFO = 3
PROC_PIDT_SHORTBSDINFO = 13
PROC_PIDUNIQIDENTIFIERINFO = 17
FULL_BSD_SIZE = 136
SHORT_BSD_SIZE = 64
UNIQUE_INFO_SIZE = 56
PID_CAPACITY = 131_072
JOIN_ATTEMPTS = 4
JOIN_RETRY_SECONDS = 0.001
ERRNO_EPERM = 1
ERRNO_ESRCH = 3
AT_FDCWD = -2
O_RDONLY = 0
O_CLOEXEC = 0x01000000
O_DIRECTORY = 0x00100000
O_NOFOLLOW_ANY = 0x20000000
DIRECTORY_OPEN_FLAGS = O_RDONLY | O_CLOEXEC | O_DIRECTORY | O_NOFOLLOW_ANY
REGULAR_FILE_OPEN_FLAGS = O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
F_FULLFSYNC = 51
WORKER_COMMAND_FD = 8
WORKER_EVENT_FD = 9
FRAME_CAPACITY = 256
RECEIPT_CAPACITY = 16_384
RECEIPT_POLICY_MAX_BYTES = 12_288
MAXIMUM_UNSIGNED_64 = 18_446_744_073_709_551_615
MAXIMUM_UNSIGNED_32 = 4_294_967_295
MINIMUM_SIGNED_64 = -9_223_372_036_854_775_808
MAXIMUM_FINITE_FLOAT = Float::MAX
HELPER_TIMEOUT_SECONDS = 20.0
CONTROLLER_TIMEOUT_SECONDS = 30.0
CONSERVATION_TIMEOUT_SECONDS = 30.0
MODEL_VERSION = "r18-generation-domain-model-v1"
ACTUATION_MODEL_VERSION = "r18-stopped-adoption-model-v1"
EXPECTED_UID = 501
EXPECTED_GID = 20
PROOF_GROUP_CAP = 32
SIGNAL_CALL_CAP = PROOF_GROUP_CAP * 2
CERTIFICATE_MAX_AGE_NS = 50_000_000
SELF_STOP_SIGNAL = Signal.list.fetch("STOP")
XNU_ABI_SOURCE = "apple-oss-distributions/xnu@xnu-12377.1.9/bsd/sys/proc_info_private.h"
INTERRUPT_SIGNALS = %w[HUP INT QUIT TERM].freeze

def fail_r18(message)
  raise R18Failure, message
end

def monotonic_time
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

def monotonic
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
end

def require_time(deadline, coordinate)
  return if deadline.nil?
  raise GuardianDeadline, coordinate unless monotonic < deadline
end

def canonical_value(value)
  case value
  when Hash
    value.keys.sort.each_with_object({}) do |key, result|
      fail_r18("non-string canonical key") unless key.is_a?(String)
      result[key] = canonical_value(value.fetch(key))
    end
  when Array
    value.map { |entry| canonical_value(entry) }
  when String, Integer, Float, TrueClass, FalseClass, NilClass
    value
  else
    fail_r18("unsupported canonical value #{value.class}")
  end
end

def canonical_json(value)
  JSON.generate(canonical_value(value))
end

def canonical_receipt(payload)
  payload_bytes = canonical_json(payload)
  sealed = payload.merge("payload_sha256" => Digest::SHA256.hexdigest(payload_bytes))
  bytes = canonical_json(sealed) + "\n"
  fail_r18("receipt exceeds #{RECEIPT_CAPACITY} bytes") if bytes.bytesize > RECEIPT_CAPACITY
  bytes
end

def maximum_integer_width_value(key, value)
  candidate = if value.negative?
    MINIMUM_SIGNED_64
  elsif %w[
      inode uniqueid puniqueid generation reserve2 reserve3 size
      oversized_failure_payload_bytes fault_count containment_fault_count
      numeric_width_structural_upper_bound_bytes
    ].include?(key)
    MAXIMUM_UNSIGNED_64
  elsif %w[listed_count joined_count gone_count retry_count].include?(key)
    131_072
  elsif %w[hard_cap_bytes policy_max_bytes frame_cap_bytes].include?(key)
    16_384
  elsif key == "mode"
    4_096
  elsif key&.match?(/(?:calls|call_sites|entered_calls)\z/) ||
        %w[sequence member_count adopted_stopped_group_count].include?(key)
    64
  elsif %w[event_count case_count passed_count].include?(key)
    32
  elsif %w[attempts join_attempts].include?(key)
    4
  else
    MAXIMUM_UNSIGNED_32
  end
  candidate.to_s.bytesize >= value.to_s.bytesize ? candidate : value
end

def maximum_numeric_width_value(value, key = nil)
  case value
  when Hash
    if value["columns"].is_a?(Array) && value["rows"].is_a?(Array)
      columns = value.fetch("columns")
      result = value.each_with_object({}) do |(field, entry), output|
        output[field] = if field == "rows"
          entry.map do |row|
            row.each_with_index.map do |cell, index|
              maximum_numeric_width_value(cell, columns.fetch(index))
            end
          end
        else
          maximum_numeric_width_value(entry, field)
        end
      end
      return result
    end
    value.each_with_object({}) do |(key, entry), result|
      result[key] = maximum_numeric_width_value(entry, key)
    end
  when Array
    value.map { |entry| maximum_numeric_width_value(entry, key) }
  when Integer
    maximum_integer_width_value(key, value)
  when Float
    MAXIMUM_FINITE_FLOAT.to_s.bytesize >= value.to_s.bytesize ?
      MAXIMUM_FINITE_FLOAT : value
  when String, TrueClass, FalseClass, NilClass
    value
  else
    fail_r18("unsupported receipt-bound value #{value.class}")
  end
end

def structural_receipt_upper_bound_bytes(payload)
  maximum = maximum_numeric_width_value(payload)
  payload_bytes = canonical_json(maximum)
  sealed = maximum.merge(
    "payload_sha256" => Digest::SHA256.hexdigest(payload_bytes)
  )
  (canonical_json(sealed) + "\n").bytesize
end

def error_receipt(error)
  bytes = error.class.name.to_s.b + ":".b + error.message.to_s.b
  {
    "bytes" => bytes.bytesize,
    "prefix_hex" => bytes.byteslice(0, 128).unpack1("H*"),
    "sha256" => Digest::SHA256.hexdigest(bytes),
  }
end

def checked_sysctl_string(name)
  buffer = "\0" * 4_096
  length_storage = [buffer.bytesize].pack("J")
  Fiddle.last_error = 0
  result = R18LibC.sysctlbyname(name, buffer, length_storage, nil, 0)
  error = Fiddle.last_error
  fail_r18("sysctlbyname #{name} failed errno=#{error}") unless result == 0
  length = length_storage.unpack1("J")
  fail_r18("sysctlbyname #{name} length invalid") unless length.between?(1, buffer.bytesize)
  value = buffer.byteslice(0, length)
  value = value.byteslice(0, value.bytesize - 1) if value.end_with?("\0")
  value.force_encoding(Encoding::UTF_8)
  fail_r18("sysctlbyname #{name} returned invalid UTF-8") unless value.valid_encoding?
  value
end

def held_regular_file(path)
  descriptor = IO.sysopen(path, REGULAR_FILE_OPEN_FLAGS)
  io = IO.new(descriptor, "rb")
  io.close_on_exec = true
  fail_r18("held file descriptor is not close-on-exec: #{path}") unless io.close_on_exec?
  named = File.lstat(path)
  held = io.stat
  fail_r18("held file is not regular: #{path}") unless named.file? && held.file?
  fail_r18("held file is a symlink: #{path}") if named.symlink?
  fail_r18("held file descriptor/name join failed: #{path}") unless
    named.dev == held.dev && named.ino == held.ino
  bytes = io.read
  fail_r18("held file read failed: #{path}") if bytes.nil?
  receipt = {
    "device" => held.dev,
    "inode" => held.ino,
    "uid" => held.uid,
    "gid" => held.gid,
    "mode" => held.mode & 0o7777,
    "nlink" => held.nlink,
    "size" => held.size,
    "sha256" => Digest::SHA256.hexdigest(bytes)
  }
  [receipt, bytes]
ensure
  io.close if defined?(io) && io && !io.closed?
end

def held_regular_file_receipt(path)
  held_regular_file(path).first
end

def validate_static_script_surface!(bytes)
  source = bytes.dup.force_encoding(Encoding::UTF_8)
  fail_r18("script source encoding invalid") unless source.valid_encoding?
  fail_r18("script source Ripper parse failed") unless Ripper.sexp(source)
  expected_lines = {
    ["child_pid = ", "Process", ".fork do"].join => 1,
    ["Process", ".exec("].join => 1,
    ["result = R18LibC", ".raise(SELF_STOP_SIGNAL)"].join => 1,
    ["result = R18LibC", ".kill(-group, 0)"].join => 1,
  }
  observed = expected_lines.each_with_object({}) do |(line, count), result|
    observed_count = source.lines.count { |entry| entry.strip == line }
    fail_r18("script static call-site mismatch #{line}") unless
      observed_count == count
    result[line] = observed_count
  end
  prohibited = [
    ["Process", ".spawn("].join,
    ["Process", ".kill("].join,
    ["IO", ".popen("].join,
    ["File", ".delete("].join,
    ["File", ".unlink("].join,
    ["File", ".rename("].join,
  ]
  prohibited.each do |surface|
    fail_r18("script gained prohibited surface #{surface}") if
      source.include?(surface)
  end
  eval_surface = ["eval", "(region, TOPLEVEL_BINDING"].join
  fail_r18("script eval site count mismatch") unless
    source.lines.count { |entry| entry.include?(eval_surface) } == 1
  {
    "process_fork_call_sites" =>
      observed.fetch(["child_pid = ", "Process", ".fork do"].join),
    "process_exec_call_sites" =>
      observed.fetch(["Process", ".exec("].join),
    "worker_libc_raise_call_sites" =>
      observed.fetch(["result = R18LibC", ".raise(SELF_STOP_SIGNAL)"].join),
    "signal_zero_call_sites" =>
      observed.fetch(["result = R18LibC", ".kill(-group, 0)"].join),
    "direct_process_kill_call_sites" => 0,
    "process_spawn_call_sites" => 0,
    "selective_eval_call_sites" => 1,
  }
end

def load_guardian_regions!
  fail_r18("guardian path is not canonical") unless
    File.realpath(GUARDIAN_PATH) == GUARDIAN_PATH
  descriptor = IO.sysopen(GUARDIAN_PATH, REGULAR_FILE_OPEN_FLAGS)
  io = IO.new(descriptor, "rb")
  io.close_on_exec = true
  fail_r18("guardian descriptor is not close-on-exec") unless io.close_on_exec?
  named = File.lstat(GUARDIAN_PATH)
  held = io.stat
  fail_r18("guardian is not a held regular file") unless
    named.file? && held.file? && !named.symlink?
  fail_r18("guardian descriptor/name join failed") unless
    [named.dev, named.ino] == [held.dev, held.ino]
  observed_identity = {
    "device" => held.dev,
    "inode" => held.ino,
    "uid" => held.uid,
    "gid" => held.gid,
    "mode" => held.mode & 0o7777,
    "nlink" => held.nlink,
  }
  fail_r18("guardian held identity mismatch") unless
    observed_identity == GUARDIAN_IDENTITY
  bytes = io.read
  fail_r18("guardian read failed") unless bytes
  fail_r18("guardian byte count mismatch") unless bytes.bytesize == GUARDIAN_BYTES
  fail_r18("guardian SHA-256 mismatch") unless
    Digest::SHA256.hexdigest(bytes) == GUARDIAN_SHA256

  region_receipts = [
    ["actuation", GUARDIAN_ACTUATION_REGION],
    ["actuator", GUARDIAN_ACTUATOR_REGION],
  ].map do |label, pin|
    offset = pin.fetch("offset")
    length = pin.fetch("bytes")
    region = bytes.byteslice(offset, length)
    fail_r18("guardian #{label} region missing") unless
      region && region.bytesize == length
    fail_r18("guardian #{label} start boundary mismatch") unless
      region.start_with?(pin.fetch("start"))
    fail_r18("guardian #{label} finish boundary mismatch") unless
      bytes.byteslice(offset + length, pin.fetch("finish").bytesize) ==
        pin.fetch("finish")
    fail_r18("guardian #{label} region line count mismatch") unless
      region.lines.length == pin.fetch("lines")
    fail_r18("guardian #{label} region SHA-256 mismatch") unless
      Digest::SHA256.hexdigest(region) == pin.fetch("sha256")
    region.force_encoding(Encoding::UTF_8)
    fail_r18("guardian #{label} region encoding invalid") unless
      region.valid_encoding?
    fail_r18("guardian #{label} region Ripper parse failed") unless
      Ripper.sexp(region)
    [label, pin, region]
  end

  actuation_region = region_receipts.fetch(0).fetch(2)
  actuator_region = region_receipts.fetch(1).fetch(2)
  expected_functions = %w[
    group_member_receipt receipt_lifetime_key group_snapshot
    double_group_snapshot issue_actuation_certificate
    issue_stopped_adoption_certificate consume_actuation_certificate
  ]
  observed_functions =
    actuation_region.scan(/^def ([a-z_][a-z0-9_!?]*)/).flatten
  fail_r18("guardian actuation method allowlist mismatch") unless
    observed_functions == expected_functions
  expected_methods = %w[
    initialize poison! disable! signaling_disabled? record_fault
    retain_rejected_adoption! stop_current_groups! kill_ready_groups! receipt
  ]
  observed_methods =
    actuator_region.scan(/^  def ([a-z_][a-z0-9_!?]*)/).flatten
  fail_r18("guardian actuator method allowlist mismatch") unless
    observed_methods == expected_methods
  fail_r18("guardian actuation signal surface mismatch") unless
    actuation_region.scan(/\bProcess\.kill\s*\(/).length == 1
  fail_r18("guardian actuator gained a process call") if
    actuator_region.match?(/\bProcess\.(?:spawn|fork|exec|kill)\b/)
  fail_r18("guardian regions gained shell execution") if
    (actuation_region + actuator_region).match?(
      /\b(?:system|spawn|fork|exec)\s*\(|\x60/
    )
  adoption_route = actuator_region.index(
    "adoption = issue_stopped_adoption_certificate("
  )
  ordinary_stop_route = actuator_region.index(
    "certificate = issue_actuation_certificate(\n" \
      "          @tracker, \"STOP\", group, sid, deadline\n"
  )
  fail_r18("guardian stopped-adoption routing pin mismatch") unless
    adoption_route && ordinary_stop_route && adoption_route < ordinary_stop_route
  fail_r18("canary adapter admitted a non-SSTOP status") unless
    defined?(ClosedStoppedTracker) &&
      ClosedStoppedTracker::ADMITTED_STATUS == 4

  region_receipts.each do |_label, pin, region|
    line = bytes.byteslice(0, pin.fetch("offset")).count("\n") + 1
    eval(region, TOPLEVEL_BINDING, GUARDIAN_PATH, line)
  end
  fail_r18("guardian GroupActuator did not load") unless
    defined?(GroupActuator) && defined?(ACTUATION_CERTIFICATE_KEYS)

  {
    "path" => GUARDIAN_PATH,
    "commit" => GUARDIAN_COMMIT,
    "tree" => GUARDIAN_TREE,
    "blob" => GUARDIAN_BLOB,
    "bytes" => bytes.bytesize,
    "sha256" => GUARDIAN_SHA256,
    "identity" => observed_identity,
    "regions" => region_receipts.map do |label, pin, _region|
      {
        "label" => label,
        "offset" => pin.fetch("offset"),
        "bytes" => pin.fetch("bytes"),
        "lines" => pin.fetch("lines"),
        "sha256" => pin.fetch("sha256"),
      }
    end,
    "executed_exact_regions" => true,
  }
ensure
  io.close if defined?(io) && io && !io.closed?
end

def validate_stdin_dev_null!
  named = File.stat(File::NULL)
  held = STDIN.stat
  fail_r18("stdin is not a character device") unless named.chardev? && held.chardev?
  fail_r18("stdin /dev/null descriptor/name join failed") unless
    named.dev == held.dev && named.ino == held.ino && named.rdev == held.rdev
  observed = {
    "device" => held.dev,
    "inode" => held.ino,
    "rdevice" => held.rdev,
    "uid" => held.uid,
    "gid" => held.gid,
    "mode" => held.mode & 0o7777
  }
  fail_r18("stdin /dev/null identity mismatch") unless observed == EXPECTED_STDIN
  fail_r18("stdin unexpectedly reports a tty") if STDIN.tty?
  observed.merge("path" => File::NULL, "character_device" => true, "tty" => false)
end

def validate_expected_cwd!
  observed = File.realpath(Dir.pwd)
  fail_r18("cwd pin mismatch") unless observed == EXPECTED_CWD
  observed
end

def validate_static_runtime!
  observed_ruby = {
    "engine" => RUBY_ENGINE,
    "version" => RUBY_VERSION,
    "patchlevel" => RUBY_PATCHLEVEL,
    "platform" => RUBY_PLATFORM
  }
  fail_r18("Ruby runtime pin mismatch") unless observed_ruby == EXPECTED_RUBY
  fail_r18("incoming umask mismatch") unless INCOMING_UMASK == 0o077
  fail_r18("runtime pointer width mismatch") unless [0].pack("J").bytesize == 8
  fail_r18("runtime byte order mismatch") unless [1].pack("L").bytes == [1, 0, 0, 0]

  observed_sysctls = EXPECTED_SYSCTLS.keys.each_with_object({}) do |name, result|
    result[name] = checked_sysctl_string(name)
  end
  fail_r18("OS/runtime sysctl pin mismatch") unless observed_sysctls == EXPECTED_SYSCTLS

  observed_credentials = {
    "uid" => Process.uid,
    "euid" => Process.euid,
    "gid" => Process.gid,
    "egid" => Process.egid,
    "groups" => Process.groups.sort
  }
  fail_r18("credential pin mismatch") unless observed_credentials == EXPECTED_CREDENTIALS
  validate_expected_cwd!
  fail_r18("program image path mismatch") unless File.realpath($PROGRAM_NAME) == SCRIPT_PATH
  fail_r18("Ruby image path mismatch") unless File.realpath(RUBY_IMAGE) == RUBY_IMAGE
  ruby_image, = held_regular_file(RUBY_IMAGE)
  fail_r18("Ruby image identity mismatch") unless ruby_image == EXPECTED_RUBY_IMAGE
  script_image, script_bytes = held_regular_file(SCRIPT_PATH)
  script_surface = validate_static_script_surface!(script_bytes)
  stdin = validate_stdin_dev_null!

  {
    "ruby" => observed_ruby,
    "ruby_image" => ruby_image.merge("arm64e_uuid_hex" => EXPECTED_RUBY_ARM64E_UUID_HEX),
    "sysctls" => observed_sysctls,
    "credentials" => observed_credentials,
    "incoming_umask" => format("%04o", INCOMING_UMASK),
    "script_image" => script_image,
    "script_surface" => script_surface,
    "cwd" => EXPECTED_CWD,
    "stdin" => stdin
  }
end

def raw_pidinfo(pid, flavor, size)
  buffer = "\0" * size
  Fiddle.last_error = 0
  returned = R18Libproc.proc_pidinfo(pid, flavor, 0, buffer, buffer.bytesize)
  error = Fiddle.last_error
  [returned, error, buffer]
end

def parse_unique_info(buffer)
  fail_r18("flavor-17 buffer size mismatch") unless buffer.bytesize == UNIQUE_INFO_SIZE
  record = {
    "uuid_hex" => buffer.byteslice(0, 16).unpack1("H*"),
    "uniqueid" => buffer.byteslice(16, 8).unpack1("Q<"),
    "puniqueid" => buffer.byteslice(24, 8).unpack1("Q<"),
    "idversion" => buffer.byteslice(32, 4).unpack1("l<"),
    "orig_ppidversion" => buffer.byteslice(36, 4).unpack1("l<"),
    "reserve2" => buffer.byteslice(40, 8).unpack1("Q<"),
    "reserve3" => buffer.byteslice(48, 8).unpack1("Q<")
  }
  fail_r18("flavor-17 uniqueid is zero") if record["uniqueid"] == 0
  fail_r18("flavor-17 XNU 12377 reserves are nonzero") unless
    record["reserve2"] == 0 && record["reserve3"] == 0
  record
end

def parse_short_bsd(buffer)
  fail_r18("short-BSD buffer size mismatch") unless buffer.bytesize == SHORT_BSD_SIZE
  record = {
    "pid" => buffer.byteslice(0, 4).unpack1("L<"),
    "ppid" => buffer.byteslice(4, 4).unpack1("L<"),
    "pgid" => buffer.byteslice(8, 4).unpack1("L<"),
    "status" => buffer.byteslice(12, 4).unpack1("L<"),
    "comm_hex" => buffer.byteslice(16, 16).unpack1("H*"),
    "flags" => buffer.byteslice(32, 4).unpack1("L<"),
    "uid" => buffer.byteslice(36, 4).unpack1("L<"),
    "gid" => buffer.byteslice(40, 4).unpack1("L<"),
    "ruid" => buffer.byteslice(44, 4).unpack1("L<"),
    "rgid" => buffer.byteslice(48, 4).unpack1("L<"),
    "svuid" => buffer.byteslice(52, 4).unpack1("L<"),
    "svgid" => buffer.byteslice(56, 4).unpack1("L<"),
    "rfu" => buffer.byteslice(60, 4).unpack1("L<")
  }
  fail_r18("short-BSD reserve is nonzero") unless record["rfu"] == 0
  record
end

def read_unique(pid)
  returned, error, buffer = raw_pidinfo(pid, PROC_PIDUNIQIDENTIFIERINFO, UNIQUE_INFO_SIZE)
  if returned == UNIQUE_INFO_SIZE
    return ["joined", parse_unique_info(buffer)]
  end
  fail_r18("flavor-17 pid=#{pid} returned partial bytes=#{returned}") if returned.positive?
  return ["gone", nil] if returned == 0 && error == ERRNO_ESRCH
  fail_r18("flavor-17 pid=#{pid} returned=#{returned} errno=#{error}")
end

def read_short(pid)
  returned, error, buffer = raw_pidinfo(pid, PROC_PIDT_SHORTBSDINFO, SHORT_BSD_SIZE)
  if returned == SHORT_BSD_SIZE
    record = parse_short_bsd(buffer)
    fail_r18("short-BSD requested pid=#{pid} observed=#{record["pid"]}") unless record["pid"] == pid
    return ["joined", record]
  end
  fail_r18("short-BSD pid=#{pid} returned partial bytes=#{returned}") if returned.positive?
  return ["gone", nil] if returned == 0 && error == ERRNO_ESRCH
  fail_r18("short-BSD pid=#{pid} returned=#{returned} errno=#{error}")
end

def read_domain_value(function_name, pid)
  Fiddle.last_error = 0
  value = function_name == "getsid" ? R18LibC.getsid(pid) : R18LibC.getpgid(pid)
  error = Fiddle.last_error
  if value >= 0
    return ["joined", value]
  end
  return ["gone", nil] if error == ERRNO_ESRCH
  fail_r18("#{function_name} pid=#{pid} returned=#{value} errno=#{error}")
end

def unique_records_equal?(left, right)
  %w[uuid_hex uniqueid puniqueid idversion orig_ppidversion reserve2 reserve3].all? do |field|
    left[field] == right[field]
  end
end

def short_identity_stable?(left, right)
  %w[pid ppid pgid comm_hex uid gid ruid rgid svuid svgid rfu].all? do |field|
    left[field] == right[field]
  end
end

def join_process(pid)
  observed_epochs = []
  race_reasons = []
  JOIN_ATTEMPTS.times do |attempt|
    u0_kind, u0 = read_unique(pid)
    if u0_kind == "gone"
      return { "kind" => "gone", "pid" => pid, "attempts" => attempt + 1 } if observed_epochs.empty?
      return {
        "kind" => "gone",
        "pid" => pid,
        "attempts" => attempt + 1,
        "reason" => "exact_esrch_after_race",
        "tombstone_epochs" => observed_epochs.uniq
      }
    end
    observed_epochs << [u0["uniqueid"], u0["idversion"]]
    s0_kind, s0 = read_short(pid)
    if s0_kind == "gone"
      return {
        "kind" => "gone",
        "pid" => pid,
        "attempts" => attempt + 1,
        "reason" => "exact_esrch_during_join",
        "tombstone_epochs" => observed_epochs.uniq
      }
    end
    sid0_kind, sid0 = read_domain_value("getsid", pid)
    if sid0_kind == "gone"
      return {
        "kind" => "gone",
        "pid" => pid,
        "attempts" => attempt + 1,
        "reason" => "exact_esrch_during_join",
        "tombstone_epochs" => observed_epochs.uniq
      }
    end
    pgid0_kind, pgid0 = read_domain_value("getpgid", pid)
    if pgid0_kind == "gone"
      return {
        "kind" => "gone",
        "pid" => pid,
        "attempts" => attempt + 1,
        "reason" => "exact_esrch_during_join",
        "tombstone_epochs" => observed_epochs.uniq
      }
    end
    sid1_kind, sid1 = read_domain_value("getsid", pid)
    if sid1_kind == "gone"
      return {
        "kind" => "gone",
        "pid" => pid,
        "attempts" => attempt + 1,
        "reason" => "exact_esrch_during_join",
        "tombstone_epochs" => observed_epochs.uniq
      }
    end
    pgid1_kind, pgid1 = read_domain_value("getpgid", pid)
    if pgid1_kind == "gone"
      return {
        "kind" => "gone",
        "pid" => pid,
        "attempts" => attempt + 1,
        "reason" => "exact_esrch_during_join",
        "tombstone_epochs" => observed_epochs.uniq
      }
    end
    s1_kind, s1 = read_short(pid)
    if s1_kind == "gone"
      return {
        "kind" => "gone",
        "pid" => pid,
        "attempts" => attempt + 1,
        "reason" => "exact_esrch_during_join",
        "tombstone_epochs" => observed_epochs.uniq
      }
    end
    u1_kind, u1 = read_unique(pid)
    if u1_kind == "gone"
      return {
        "kind" => "gone",
        "pid" => pid,
        "attempts" => attempt + 1,
        "reason" => "exact_esrch_during_join",
        "tombstone_epochs" => observed_epochs.uniq
      }
    end
    observed_epochs << [u1["uniqueid"], u1["idversion"]]

    stable = unique_records_equal?(u0, u1) && short_identity_stable?(s0, s1) &&
      sid0 == sid1 && pgid0 == pgid1 && pgid0 == s0["pgid"] && pgid1 == s1["pgid"]
    if stable
      return {
        "kind" => "joined",
        "pid" => pid,
        "attempts" => attempt + 1,
        "unique" => u1,
        "short" => s1,
        "sid" => sid1,
        "pgid" => pgid1
      }
    end
    race_reasons << "generation_or_domain_race"
    sleep(JOIN_RETRY_SECONDS) if attempt + 1 < JOIN_ATTEMPTS
  end
  {
    "kind" => "unknown",
    "pid" => pid,
    "attempts" => JOIN_ATTEMPTS,
    "reason" => race_reasons.uniq.join("+"),
    "observed_epochs" => observed_epochs.uniq
  }
end

def require_joined(pid, context)
  result = join_process(pid)
  fail_r18("#{context} did not form a stable process join: #{result["kind"]}") unless
    result["kind"] == "joined"
  result
end

def require_ruby_image_joined(pid, context)
  result = require_joined(pid, context)
  fail_r18("#{context} executable UUID mismatch") unless
    result.dig("unique", "uuid_hex") == EXPECTED_RUBY_ARM64E_UUID_HEX
  result
end

def immediate_unique_epoch(pid, context)
  kind, record = read_unique(pid)
  fail_r18("#{context} flavor-17 epoch unavailable") unless kind == "joined"
  record
end

def pid1_abi_probe
  returned, error, = raw_pidinfo(1, PROC_PIDTBSDINFO, FULL_BSD_SIZE)
  fail_r18("PID 1 full BSD probe did not fail exactly EPERM") unless
    returned == 0 && error == ERRNO_EPERM

  joined = require_joined(1, "PID 1 flavor-17/short-BSD probe")
  {
    "full_bsd" => {
      "flavor" => PROC_PIDTBSDINFO,
      "requested_bytes" => FULL_BSD_SIZE,
      "returned_bytes" => returned,
      "errno" => error,
      "expected" => "EPERM"
    },
    "short_bsd" => {
      "flavor" => PROC_PIDT_SHORTBSDINFO,
      "returned_bytes" => SHORT_BSD_SIZE
    },
    "unique_identifier" => {
      "flavor" => PROC_PIDUNIQIDENTIFIERINFO,
      "returned_bytes" => UNIQUE_INFO_SIZE,
      "uniqueid" => joined.dig("unique", "uniqueid"),
      "idversion" => joined.dig("unique", "idversion"),
      "orig_ppidversion" => joined.dig("unique", "orig_ppidversion"),
      "uuid_hex" => joined.dig("unique", "uuid_hex")
    },
    "domain" => {
      "sid" => joined["sid"],
      "pgid" => joined["pgid"]
    },
    "join_attempts" => joined["attempts"]
  }
end

def list_ruid_pids
  buffer = "\0" * (PID_CAPACITY * 4)
  Fiddle.last_error = 0
  returned = R18Libproc.proc_listpids(PROC_RUID_ONLY, RUID_SELECTOR, buffer, buffer.bytesize)
  error = Fiddle.last_error
  fail_r18("RUID process list failed returned=#{returned} errno=#{error}") unless returned > 0
  fail_r18("RUID process list reached capacity") if returned >= buffer.bytesize
  fail_r18("RUID process list byte count is not PID-aligned") unless (returned % 4).zero?
  pids = buffer.byteslice(0, returned).unpack("L<*").reject(&:zero?)
  fail_r18("RUID process list contains duplicates") unless pids.uniq.length == pids.length
  pids.sort
end

def sweep_row_for(result)
  return result if result["kind"] != "joined"
  {
    "kind" => "joined",
    "pid" => result["pid"],
    "uniqueid" => result.dig("unique", "uniqueid"),
    "puniqueid" => result.dig("unique", "puniqueid"),
    "idversion" => result.dig("unique", "idversion"),
    "orig_ppidversion" => result.dig("unique", "orig_ppidversion"),
    "uuid_hex" => result.dig("unique", "uuid_hex"),
    "ppid" => result.dig("short", "ppid"),
    "pgid" => result["pgid"],
    "sid" => result["sid"],
    "status" => result.dig("short", "status"),
    "flags" => result.dig("short", "flags"),
    "comm_hex" => result.dig("short", "comm_hex"),
    "uid" => result.dig("short", "uid"),
    "gid" => result.dig("short", "gid"),
    "ruid" => result.dig("short", "ruid"),
    "rgid" => result.dig("short", "rgid"),
    "svuid" => result.dig("short", "svuid"),
    "svgid" => result.dig("short", "svgid"),
    "attempts" => result["attempts"]
  }
end

def perform_ruid_sweep(label, controller_generation)
  pids = list_ruid_pids
  rows = pids.map do |pid|
    result = join_process(pid)
    if result["kind"] == "joined" && result.dig("short", "ruid") != RUID_SELECTOR
      {
        "kind" => "unknown",
        "pid" => pid,
        "attempts" => result["attempts"],
        "reason" => "ruid_selector_generation_rebound",
        "observed_uniqueid" => result.dig("unique", "uniqueid"),
        "observed_ruid" => result.dig("short", "ruid")
      }
    else
      sweep_row_for(result)
    end
  end

  controller_row = rows.find do |row|
    row["kind"] == "joined" && row["pid"] == Process.pid &&
      row["uniqueid"] == controller_generation
  end
  fail_r18("#{label} omitted the controller generation") unless controller_row

  joined_count = rows.count { |row| row["kind"] == "joined" }
  gone_count = rows.count { |row| row["kind"] == "gone" }
  unknown_count = rows.count { |row| row["kind"] == "unknown" }
  fail_r18("#{label} retained #{unknown_count} sticky UNKNOWN joins") unless unknown_count.zero?
  {
    "label" => label,
    "selector" => { "kind" => "RUID", "value" => RUID_SELECTOR },
    "listed_count" => pids.length,
    "joined_count" => joined_count,
    "gone_count" => gone_count,
    "sticky_unknown_count" => unknown_count,
    "sticky_unknowns" => rows.select { |row| row["kind"] == "unknown" },
    "retry_count" => rows.sum { |row| [row.fetch("attempts", 1) - 1, 0].max },
    "rows_sha256" => Digest::SHA256.hexdigest(canonical_json(rows))
  }
end

def checked_openat(directory_fd, path, flags)
  Fiddle.last_error = 0
  descriptor = R18LibC.openat(directory_fd, path, flags, 0)
  error = Fiddle.last_error
  fail_r18("openat #{path} failed errno=#{error}") if descriptor < 0
  fail_r18("openat #{path} returned reserved descriptor=#{descriptor}") if descriptor < 3
  descriptor
end

def full_fsync!(io, context)
  Fiddle.last_error = 0
  result = R18LibC.fcntl(io.fileno, F_FULLFSYNC)
  error = Fiddle.last_error
  fail_r18("#{context} fullfsync failed errno=#{error}") unless result == 0
  true
end

def durable_sync!(io, context)
  io.fsync
  full_fsync!(io, context)
  { "fsync" => true, "fullfsync" => true }
end

def stat_identity(stat)
  {
    "device" => stat.dev,
    "inode" => stat.ino,
    "uid" => stat.uid,
    "gid" => stat.gid,
    "mode" => stat.mode & 0o7777,
    "nlink" => stat.nlink
  }
end

def create_marker_once!
  begin
    File.lstat(MARKER_PATH)
    fail_r18("durable marker already exists; canary is consumed")
  rescue Errno::ENOENT
    nil
  end

  parent_fd = checked_openat(AT_FDCWD, MARKER_PARENT_PATH, DIRECTORY_OPEN_FLAGS)
  parent_io = IO.new(parent_fd)
  parent_io.close_on_exec = true
  fail_r18("marker parent descriptor is not close-on-exec") unless parent_io.close_on_exec?
  parent_named = File.lstat(MARKER_PARENT_PATH)
  parent_held = parent_io.stat
  fail_r18("marker parent is not a directory") unless parent_named.directory? && parent_held.directory?
  fail_r18("marker parent descriptor/name join failed") unless
    parent_named.dev == parent_held.dev && parent_named.ino == parent_held.ino
  observed_parent = stat_identity(parent_held)
  EXPECTED_PRIVATE_TMP.each do |field, expected|
    fail_r18("marker parent #{field} pin mismatch") unless observed_parent[field] == expected
  end

  Fiddle.last_error = 0
  result = R18LibC.mkdirat(parent_io.fileno, MARKER_LEAF, 0o700)
  error = Fiddle.last_error
  fail_r18("mkdirat marker failed errno=#{error}") unless result == 0

  marker_fd = checked_openat(parent_io.fileno, MARKER_LEAF, DIRECTORY_OPEN_FLAGS)
  marker_io = IO.new(marker_fd)
  marker_io.close_on_exec = true
  fail_r18("marker descriptor is not close-on-exec") unless marker_io.close_on_exec?
  marker_named = File.lstat(MARKER_PATH)
  marker_held = marker_io.stat
  fail_r18("marker is not a directory") unless marker_named.directory? && marker_held.directory?
  fail_r18("marker descriptor/name join failed") unless
    marker_named.dev == marker_held.dev && marker_named.ino == marker_held.ino
  marker_identity = stat_identity(marker_held)
  fail_r18("marker uid mismatch") unless marker_identity["uid"] == EXPECTED_CREDENTIALS["euid"]
  fail_r18("marker gid mismatch") unless marker_identity["gid"] == EXPECTED_MARKER_GID
  fail_r18("marker mode mismatch") unless marker_identity["mode"] == 0o700
  fail_r18("marker nlink mismatch") unless marker_identity["nlink"] == 2
  fail_r18("marker was not born empty") unless Dir.children(MARKER_PATH).empty?
  marker_sync = durable_sync!(marker_io, "marker directory")
  parent_sync = durable_sync!(parent_io, "marker parent directory")
  marker_after_sync = File.lstat(MARKER_PATH)
  fail_r18("marker changed while syncing") unless
    marker_after_sync.dev == marker_held.dev && marker_after_sync.ino == marker_held.ino &&
      stat_identity(marker_after_sync) == marker_identity && Dir.children(MARKER_PATH).empty?

  {
    "parent_io" => parent_io,
    "marker_io" => marker_io,
    "receipt" => {
      "path" => MARKER_PATH,
      "leaf" => MARKER_LEAF,
      "created_once" => true,
      "kept_after_outcome" => true,
      "used_as_cwd" => false,
      "parent_identity" => observed_parent,
      "marker_identity" => marker_identity,
      "marker_sync" => marker_sync,
      "parent_sync" => parent_sync,
      "entry_count" => 0,
      "empty_inventory_sha256" => Digest::SHA256.hexdigest("")
    }
  }
rescue StandardError
  parent_io.close if defined?(parent_io) && parent_io && !parent_io.closed?
  marker_io.close if defined?(marker_io) && marker_io && !marker_io.closed?
  raise
end

def revalidate_marker!(marker_state)
  named = File.lstat(MARKER_PATH)
  held = marker_state.fetch("marker_io").stat
  fail_r18("marker ceased to be a directory") unless named.directory? && held.directory?
  fail_r18("marker descriptor/name rebound") unless named.dev == held.dev && named.ino == held.ino
  fail_r18("marker metadata changed") unless stat_identity(held) == marker_state.dig("receipt", "marker_identity")
  entries = Dir.children(MARKER_PATH)
  fail_r18("marker is not empty") unless entries.empty?
  fail_r18("marker became cwd") if File.realpath(Dir.pwd) == MARKER_PATH
  true
end

def model_record(label, uniqueid:, idversion:, puniqueid: 0, orig_ppidversion: 0,
                 fixture: nil, pid: 1, sid: 10, pgid: 10)
  {
    "label" => label,
    "pid" => pid,
    "uniqueid" => uniqueid,
    "idversion" => idversion,
    "puniqueid" => puniqueid,
    "orig_ppidversion" => orig_ppidversion,
    "fixture" => fixture,
    "sid" => sid,
    "pgid" => pgid
  }
end

def merge_model_class(existing, candidate)
  return candidate if existing.nil?
  return existing if candidate.nil? || existing == candidate
  "hard_stop"
end

def classify_model(records, owned_epochs: [], ambient_epochs: [], fixture_identity: "closed-vnode")
  epoch_classes = {}
  lifetime_classes = {}
  owned_epochs.each do |epoch|
    epoch_classes[epoch] = merge_model_class(epoch_classes[epoch], "owned")
    lifetime_classes[epoch.first] = merge_model_class(lifetime_classes[epoch.first], "owned")
  end
  ambient_epochs.each do |epoch|
    epoch_classes[epoch] = merge_model_class(epoch_classes[epoch], "ambient")
    lifetime_classes[epoch.first] = merge_model_class(lifetime_classes[epoch.first], "ambient")
  end

  classifications = {}
  (records.length + 2).times do
    changed = false
    records.each do |record|
      current_epoch = [record["uniqueid"], record["idversion"]]
      parent_epoch = [record["puniqueid"], record["orig_ppidversion"]]
      candidates = []
      candidates << epoch_classes[current_epoch] if epoch_classes.key?(current_epoch)
      candidates << lifetime_classes[record["uniqueid"]] if lifetime_classes.key?(record["uniqueid"])
      candidates << epoch_classes[parent_epoch] if epoch_classes.key?(parent_epoch)
      candidates << "owned" if record["fixture"] == fixture_identity
      candidate = candidates.compact.reduce(nil) { |memo, item| merge_model_class(memo, item) }
      candidate ||= "unknown"
      previous = classifications[record["label"]]
      classifications[record["label"]] = candidate
      changed ||= previous != candidate
      next if candidate == "unknown"

      merged_epoch = merge_model_class(epoch_classes[current_epoch], candidate)
      merged_lifetime = merge_model_class(lifetime_classes[record["uniqueid"]], candidate)
      changed ||= epoch_classes[current_epoch] != merged_epoch
      changed ||= lifetime_classes[record["uniqueid"]] != merged_lifetime
      epoch_classes[current_epoch] = merged_epoch
      lifetime_classes[record["uniqueid"]] = merged_lifetime
    end
    break unless changed
  end
  classifications
end

def model_signal_allowed?(action, records, classifications, expected_sid:, expected_pgid:,
                          expected_generations:)
  return false unless ["STOP", "KILL"].include?(action)
  records.all? do |record|
    classifications[record["label"]] == "owned" &&
      record["sid"] == expected_sid && record["pgid"] == expected_pgid &&
      expected_generations[record["pid"]] == record["uniqueid"]
  end
end

def run_model_cases
  cases = []
  add = lambda do |name, pass|
    cases << { "name" => name, "pass" => !!pass }
  end

  direct = model_record("direct", uniqueid: 10, idversion: 1)
  add.call("01_supervisor_session_epoch_owned",
           classify_model([direct], owned_epochs: [[10, 1]])["direct"] == "owned")

  child = model_record("child", uniqueid: 11, idversion: 1,
                       puniqueid: 10, orig_ppidversion: 1)
  classified = classify_model([direct, child], owned_epochs: [[10, 1]])
  add.call("02_captured_actuation_descendant_owned", classified["child"] == "owned")

  reparented = model_record("reparented", uniqueid: 12, idversion: 1,
                            puniqueid: 10, orig_ppidversion: 1, pid: 12, sid: 1, pgid: 12)
  add.call("03_reparented_actuation_descendant_retains_parent_epoch",
           classify_model([reparented], owned_epochs: [[10, 1]])["reparented"] == "owned")

  ambient = model_record("ambient", uniqueid: 20, idversion: 1)
  add.call("04_baseline_epoch_ambient",
           classify_model([ambient], ambient_epochs: [[20, 1]])["ambient"] == "ambient")

  ambient_child = model_record("ambient-child", uniqueid: 21, idversion: 1,
                               puniqueid: 20, orig_ppidversion: 1)
  add.call("05_ambient_descendant_stays_ambient",
           classify_model([ambient_child], ambient_epochs: [[20, 1]])["ambient-child"] == "ambient")

  unknown = model_record("unknown", uniqueid: 30, idversion: 1,
                         puniqueid: 999, orig_ppidversion: 7)
  add.call("06_unjoined_parent_is_unknown", classify_model([unknown])["unknown"] == "unknown")

  rebound = model_record("rebound", uniqueid: 31, idversion: 1, pid: 77)
  add.call("07_pid_reuse_does_not_inherit_owner",
           classify_model([rebound], owned_epochs: [[30, 1]])["rebound"] == "unknown")

  exec_epoch = model_record("exec", uniqueid: 10, idversion: 2)
  add.call("08_exec_epoch_inherits_owned_lifetime",
           classify_model([exec_epoch], owned_epochs: [[10, 1]])["exec"] == "owned")

  historical_child = model_record("historical-child", uniqueid: 13, idversion: 1,
                                  puniqueid: 10, orig_ppidversion: 1)
  add.call("09_historical_parent_epoch_survives_exec",
           classify_model([exec_epoch, historical_child], owned_epochs: [[10, 1]])["historical-child"] == "owned")

  wrong_parent_version = model_record("wrong-parent-version", uniqueid: 14, idversion: 1,
                                      puniqueid: 10, orig_ppidversion: 9)
  add.call("10_wrong_orig_ppidversion_is_unknown",
           classify_model([wrong_parent_version], owned_epochs: [[10, 1]])["wrong-parent-version"] == "unknown")

  fixture = model_record("fixture", uniqueid: 40, idversion: 1, fixture: "closed-vnode")
  add.call("11_closed_fixture_identity_is_owned", classify_model([fixture])["fixture"] == "owned")

  wrong_fixture = model_record("wrong-fixture", uniqueid: 41, idversion: 1, fixture: "path-only")
  add.call("12_path_only_fixture_is_unknown", classify_model([wrong_fixture])["wrong-fixture"] == "unknown")

  collision = model_record("collision", uniqueid: 50, idversion: 1)
  add.call("13_owned_ambient_epoch_collision_is_hard_stop",
           classify_model([collision], owned_epochs: [[50, 1]], ambient_epochs: [[50, 1]])["collision"] == "hard_stop")

  detached_fixture = model_record("detached-fixture", uniqueid: 60, idversion: 1,
                                  fixture: "closed-vnode", pid: 60, sid: 1, pgid: 60)
  add.call("14_detached_fixture_workspace_remains_visible_owned",
           classify_model([detached_fixture])["detached-fixture"] == "owned")

  signal_records = [
    model_record("signal-a", uniqueid: 70, idversion: 1, pid: 70, sid: 70, pgid: 70),
    model_record("signal-b", uniqueid: 71, idversion: 1, puniqueid: 70,
                 orig_ppidversion: 1, pid: 71, sid: 70, pgid: 70)
  ]
  signal_classes = classify_model(signal_records, owned_epochs: [[70, 1]])
  exact_generations = { 70 => 70, 71 => 71 }
  add.call("15_stop_and_kill_require_closed_owned_group",
           %w[STOP KILL].all? do |action|
             model_signal_allowed?(action, signal_records, signal_classes,
                                   expected_sid: 70, expected_pgid: 70,
                                   expected_generations: exact_generations)
           end)

  mixed = signal_records + [model_record("unknown-member", uniqueid: 72, idversion: 1,
                                         pid: 72, sid: 70, pgid: 70)]
  mixed_classes = classify_model(mixed, owned_epochs: [[70, 1]])
  add.call("16_unknown_group_member_denies_stop_and_kill",
           %w[STOP KILL].none? do |action|
             model_signal_allowed?(action, mixed, mixed_classes,
                                   expected_sid: 70, expected_pgid: 70,
                                   expected_generations: exact_generations.merge(72 => 72))
           end)

  wrong_domain = signal_records.map(&:dup)
  wrong_domain.last["sid"] = 1
  add.call("17_generation_or_domain_rebound_denies_stop_and_kill",
           %w[STOP KILL].none? do |action|
             model_signal_allowed?(action, signal_records, signal_classes,
                                   expected_sid: 70, expected_pgid: 70,
                                   expected_generations: exact_generations.merge(71 => 99)) ||
               model_signal_allowed?(action, wrong_domain, signal_classes,
                                     expected_sid: 70, expected_pgid: 70,
                                     expected_generations: exact_generations)
           end)

  fail_r18("pure model case count mismatch") unless cases.length == 17
  fail_r18("pure model case failed") unless cases.all? { |entry| entry["pass"] }
  {
    "version" => MODEL_VERSION,
    "case_count" => cases.length,
    "passed_count" => cases.count { |entry| entry["pass"] },
    "cases" => cases,
    "cases_sha256" => Digest::SHA256.hexdigest(canonical_json(cases)),
    "performed_process_operations" => false
  }
end

class R18LineReader
  def initialize(io, capacity = FRAME_CAPACITY)
    @io = io
    @capacity = capacity
    @buffer = "".b
  end

  def read_line(deadline)
    loop do
      newline = @buffer.index("\n")
      if newline
        line = @buffer.byteslice(0, newline)
        @buffer = @buffer.byteslice(
          newline + 1, @buffer.bytesize - newline - 1
        ) || "".b
        fail_r18("protocol frame contains carriage return") if line.include?("\r")
        return line
      end
      fail_r18("protocol frame exceeds cap") if @buffer.bytesize >= @capacity
      remaining = deadline - monotonic_time
      fail_r18("protocol read timed out") unless remaining.positive?
      ready = IO.select([@io], nil, nil, remaining)
      fail_r18("protocol read timed out") unless ready
      begin
        chunk = @io.read_nonblock([4_096, @capacity - @buffer.bytesize].min)
        fail_r18("protocol EOF") if chunk.nil? || chunk.empty?
        @buffer << chunk
      rescue IO::WaitReadable
        next
      rescue EOFError
        fail_r18("protocol EOF")
      end
    end
  end

  def require_clean_eof(deadline)
    fail_r18("trailing protocol bytes") unless @buffer.empty?
    loop do
      remaining = deadline - monotonic_time
      fail_r18("protocol EOF timed out") unless remaining.positive?
      ready = IO.select([@io], nil, nil, remaining)
      fail_r18("protocol EOF timed out") unless ready
      begin
        chunk = @io.read_nonblock(4_096)
        fail_r18("extra protocol bytes") unless chunk.nil? || chunk.empty?
      rescue IO::WaitReadable
        next
      rescue EOFError
        return true
      end
    end
  end
end

def write_bytes(io, bytes)
  offset = 0
  while offset < bytes.bytesize
    written = io.syswrite(bytes.byteslice(offset, bytes.bytesize - offset))
    fail_r18("zero-byte protocol write") unless written.positive?
    offset += written
  end
  true
end

def write_command(io, command)
  fail_r18("invalid command token") unless command.match?(/\A[a-z_]+\z/)
  write_bytes(io, command + "\n")
end

def read_command(reader, expected, deadline)
  observed = reader.read_line(deadline)
  fail_r18("command mismatch expected=#{expected} observed=#{observed}") unless
    observed == expected
  true
end

def write_event(io, event, sequence, joined)
  frame = {
    "event" => event,
    "pid" => Process.pid,
    "ppid" => Process.ppid,
    "sequence" => sequence,
    "uniqueid" => joined.dig("unique", "uniqueid"),
    "idversion" => joined.dig("unique", "idversion"),
    "sid" => joined["sid"],
    "pgid" => joined["pgid"]
  }
  bytes = canonical_json(frame) + "\n"
  fail_r18("event frame exceeds cap") if bytes.bytesize > FRAME_CAPACITY
  write_bytes(io, bytes)
  frame
end

EVENT_KEYS = %w[event idversion pgid pid ppid sequence sid uniqueid].freeze

def read_event(reader, event, sequence, deadline)
  raw = reader.read_line(deadline)
  parsed = JSON.parse(raw)
  fail_r18("event is not an object") unless parsed.is_a?(Hash)
  fail_r18("event frame is not canonical") unless canonical_json(parsed) == raw
  fail_r18("event key set mismatch") unless parsed.keys.sort == EVENT_KEYS.sort
  fail_r18("event mismatch") unless
    parsed["event"] == event && parsed["sequence"] == sequence
  parsed
rescue JSON::ParserError
  fail_r18("event JSON rejected")
end

def close_ios(ios)
  ios.each do |io|
    io.close if io && !io.closed?
  rescue IOError
    nil
  end
end

def assert_event_join!(event, joined, expected_pid, expected_ppid)
  fail_r18("event PID mismatch") unless event["pid"] == expected_pid
  fail_r18("event PPID mismatch") unless event["ppid"] == expected_ppid
  fail_r18("event uniqueid mismatch") unless
    event["uniqueid"] == joined.dig("unique", "uniqueid")
  fail_r18("event idversion mismatch") unless
    event["idversion"] == joined.dig("unique", "idversion")
  fail_r18("event SID mismatch") unless event["sid"] == joined["sid"]
  fail_r18("event PGID mismatch") unless event["pgid"] == joined["pgid"]
end

def run_exec_worker
  validate_static_runtime!
  fail_r18("worker entered marker cwd") if File.realpath(Dir.pwd) == MARKER_PATH
  command_io = IO.new(WORKER_COMMAND_FD, "r")
  event_io = IO.new(WORKER_EVENT_FD, "w")
  event_io.sync = true
  joined = require_ruby_image_joined(Process.pid, "post-exec worker")
  write_event(event_io, "worker_postexec_ready", 2, joined)
  deadline = monotonic_time + HELPER_TIMEOUT_SECONDS
  read_command(R18LineReader.new(command_io, 64), "self_stop", deadline)
  joined = require_ruby_image_joined(Process.pid, "worker before self-stop")
  write_event(event_io, "worker_self_stop_entering", 3, joined)
  close_ios([command_io, event_io])
  result = R18LibC.raise(SELF_STOP_SIGNAL)
  exit!(70) unless result == 0
  exit!(70)
rescue StandardError
  exit!(70)
end

def run_preexec_worker(command_read, event_write, inherited_ios)
  close_ios(inherited_ios)
  validate_expected_cwd!
  validate_stdin_dev_null!
  sid = Process.setsid
  fail_r18("worker private session creation failed") unless
    sid == Process.pid && Process.getsid(0) == Process.pid &&
      Process.getpgrp == Process.pid
  joined = require_ruby_image_joined(Process.pid, "pre-exec worker")
  write_event(event_write, "worker_preexec_ready", 1, joined)
  deadline = monotonic_time + HELPER_TIMEOUT_SECONDS
  read_command(R18LineReader.new(command_read, 64), "exec_worker", deadline)
  worker_environment = BASE_ENVIRONMENT.merge(ROLE_KEY => WORKER_ROLE)
  Process.exec(
    worker_environment,
    RUBY_IMAGE,
    "--disable-gems",
    SCRIPT_PATH,
    WORKER_COMMAND_FD => command_read,
    WORKER_EVENT_FD => event_write,
    in: File::NULL,
    out: File::NULL,
    err: File::NULL,
    close_others: true,
    unsetenv_others: true
  )
rescue StandardError
  exit!(70)
end

def exact_terminal_wait_receipt(pid, status)
  {
    "pid" => pid,
    "exited" => status.exited?,
    "exit_status" => status.exited? ? status.exitstatus : nil,
    "signaled" => status.signaled?,
    "term_signal" => status.signaled? ? status.termsig : nil,
    "raw_status" => status.to_i
  }
end

def poll_exact_child(pid)
  pair = Process.waitpid2(pid, Process::WNOHANG)
  return nil unless pair
  fail_r18("exact child wait returned wrong PID") unless pair.first == pid
  exact_terminal_wait_receipt(pid, pair.last)
rescue Errno::ECHILD
  fail_r18("exact child ownership lost")
end

def wait_exact_child_stopped(pid, deadline)
  loop do
    pair = Process.waitpid2(
      pid, Process::WNOHANG | Process::WUNTRACED
    )
    if pair
      fail_r18("stopped observation wrong PID") unless pair.first == pid
      status = pair.last
      if status.exited? || status.signaled?
        return {
          "kind" => "terminal_before_sstop",
          "terminal" => exact_terminal_wait_receipt(pid, status),
        }
      end
      fail_r18("child wait status was not stopped") unless status.stopped?
      fail_r18("child stopped by unexpected signal") unless
        status.stopsig == SELF_STOP_SIGNAL
      return {
        "kind" => "sstop",
        "observation" => {
          "pid" => pid,
          "stopped" => true,
          "stop_signal" => status.stopsig,
          "raw_status" => status.to_i,
        },
      }
    end
    fail_r18("self-stop observation timed out") unless
      monotonic_time < deadline
    sleep(0.001)
  end
rescue Errno::ECHILD
  fail_r18("exact child ownership lost before stopped observation")
end

def wait_exact_child(pid, deadline = nil)
  loop do
    observation = poll_exact_child(pid)
    return observation if observation
    fail_r18("exact child reap timed out") if
      deadline && monotonic_time >= deadline
    sleep(0.002)
  end
end

def wait_for_generation_absence(pid, uniqueid, deadline = nil)
  loop do
    kind, current = read_unique(pid)
    if kind == "gone"
      return { "pid" => pid, "generation" => uniqueid, "observation" => "ESRCH" }
    end
    fail_r18("PID rebound before exact ESRCH") unless
      current["uniqueid"] == uniqueid
    fail_r18("generation absence timed out") if
      deadline && monotonic_time >= deadline
    sleep(0.002)
  end
end

def public_join(joined)
  {
    "pid" => joined["pid"],
    "attempts" => joined["attempts"],
    "uuid_hex" => joined.dig("unique", "uuid_hex"),
    "uniqueid" => joined.dig("unique", "uniqueid"),
    "puniqueid" => joined.dig("unique", "puniqueid"),
    "idversion" => joined.dig("unique", "idversion"),
    "orig_ppidversion" => joined.dig("unique", "orig_ppidversion"),
    "ppid" => joined.dig("short", "ppid"),
    "pgid" => joined["pgid"],
    "sid" => joined["sid"],
    "ruid" => joined.dig("short", "ruid"),
    "status" => joined.dig("short", "status"),
    "comm_hex" => joined.dig("short", "comm_hex")
  }
end

JOIN_TABLE_COLUMNS = %w[
  label pid attempts uuid_hex uniqueid puniqueid idversion orig_ppidversion
  ppid pgid sid ruid status comm_hex
].freeze

def public_join_table(labeled_joins)
  rows = labeled_joins.map do |label, joined|
    public = public_join(joined)
    [label] + JOIN_TABLE_COLUMNS.drop(1).map { |field| public.fetch(field) }
  end
  {
    "columns" => JOIN_TABLE_COLUMNS,
    "rows" => rows,
    "rows_sha256" => Digest::SHA256.hexdigest(canonical_json(rows)),
  }
end

SWEEP_TABLE_COLUMNS = %w[
  label selector_kind selector_value listed_count joined_count gone_count
  sticky_unknown_count retry_count rows_sha256
].freeze

def public_sweep_table(sweeps)
  rows = sweeps.map do |sweep|
    [
      sweep.fetch("label"), sweep.dig("selector", "kind"),
      sweep.dig("selector", "value"), sweep.fetch("listed_count"),
      sweep.fetch("joined_count"), sweep.fetch("gone_count"),
      sweep.fetch("sticky_unknown_count"), sweep.fetch("retry_count"),
      sweep.fetch("rows_sha256"),
    ]
  end
  fail_r18("public sweep retained UNKNOWN rows") unless
    rows.all? { |row| row.fetch(6).zero? }
  {
    "columns" => SWEEP_TABLE_COLUMNS,
    "rows" => rows,
    "rows_sha256" => Digest::SHA256.hexdigest(canonical_json(rows)),
  }
end

def list_group_pids(group)
  fail_r18("invalid process group") unless group.is_a?(Integer) && group > 1
  buffer = "\0" * (PID_CAPACITY * 4)
  Fiddle.last_error = 0
  returned = R18Libproc.proc_listpids(
    PROC_PGRP_ONLY, group, buffer, buffer.bytesize
  )
  error = Fiddle.last_error
  return [] if returned == 0
  fail_r18("process-group list failed returned=#{returned} errno=#{error}") unless
    returned.positive?
  fail_r18("process-group list reached capacity") if returned >= buffer.bytesize
  fail_r18("process-group list is not PID-aligned") unless (returned % 4).zero?
  pids = buffer.byteslice(0, returned).unpack("L<*").reject(&:zero?)
  fail_r18("process-group list contains duplicates") unless
    pids.uniq.length == pids.length
  pids.sort
end

def expected_member_credentials?(joined)
  %w[uid gid ruid rgid svuid svgid].map do |field|
    joined.dig("short", field)
  end == [501, 20, 501, 20, 501, 20]
end

def lifetime_key(member)
  [member.fetch("pid"), member.dig("unique", "uniqueid")]
end

def joined_scan(deadline, list_type:, type_info:, allow_empty:)
  require_time(deadline, "canary-group-scan-deadline")
  fail_r18("guardian requested non-group scan") unless
    list_type == PROC_PGRP_ONLY && type_info.is_a?(Integer) && type_info > 1
  pids = list_group_pids(type_info)
  return [] if pids.empty? && allow_empty
  fail_r18("guardian group scan is empty") if pids.empty?
  pids.map do |pid|
    joined = join_process(pid)
    fail_r18("guardian group member did not join") unless
      joined["kind"] == "joined"
    joined
  end
rescue StandardError
  $closed_stopped_tracker.poison_classification! if
    defined?($closed_stopped_tracker) && $closed_stopped_tracker
  raise
end

class ClosedStoppedTracker
  ADMITTED_STATUS = 4

  attr_reader :classification_poisoned, :unknown_count

  def initialize(expected_join)
    @expected = expected_join
    @classification_poisoned = false
    @unknown_count = 0
    $closed_stopped_tracker = self
  end

  def poison_classification!
    @classification_poisoned = true
  end

  def classify_group!(records, group, sid, _deadline)
    raise "canary-group-cardinality" unless records.length == 1
    member = records.first
    expected = @expected
    raise "canary-group-generation" unless
      member.fetch("pid") == expected.fetch("pid") &&
      member.dig("unique", "uniqueid") ==
        expected.dig("unique", "uniqueid") &&
      member.dig("unique", "idversion") ==
        expected.dig("unique", "idversion") &&
      member.dig("unique", "uuid_hex") ==
        EXPECTED_RUBY_ARM64E_UUID_HEX
    raise "canary-group-parent-epoch" unless
      member.dig("unique", "puniqueid") ==
        expected.dig("unique", "puniqueid") &&
      member.dig("unique", "orig_ppidversion") ==
        expected.dig("unique", "orig_ppidversion") &&
      member.dig("short", "ppid") == expected.dig("short", "ppid")
    raise "canary-group-domain" unless
      group == expected.fetch("pgid") && sid == expected.fetch("sid") &&
      member.fetch("sid") == sid && member.fetch("pgid") == group &&
      member.dig("short", "pgid") == group
    raise "canary-group-credentials" unless
      expected_member_credentials?(member)
    raise "canary-group-not-first-seen-sstop" unless
      member.dig("short", "status") == ADMITTED_STATUS
    records
  rescue StandardError
    poison_classification!
    raise
  end
end

def double_group_absence(group, deadline = nil)
  observations = []
  2.times do
    fail_r18("group absence timed out") if deadline && monotonic_time >= deadline
    pids = list_group_pids(group)
    fail_r18("group not empty after exact reap") unless pids.empty?
    Fiddle.last_error = 0
    result = R18LibC.kill(-group, 0)
    error = Fiddle.last_error
    fail_r18("signal-zero group absence was not exact ESRCH") unless
      result == -1 && error == ERRNO_ESRCH
    observations << {
      "group" => group,
      "pids" => [],
      "process_list_observation" => "EMPTY",
      "signal_zero_observation" => "ESRCH",
      "signal_zero_errno" => error
    }
  end
  observations
end

def model_stopped_adoption_allowed?(first, second, expected)
  return false unless first == second && first.length == 1
  row = first.first
  row["classification"] == "owned" &&
    row["pid"] == expected["pid"] &&
    row["uniqueid"] == expected["uniqueid"] &&
    row["idversion"] == expected["idversion"] &&
    row["puniqueid"] == expected["puniqueid"] &&
    row["orig_ppidversion"] == expected["orig_ppidversion"] &&
    row["sid"] == expected["sid"] && row["pgid"] == expected["pgid"] &&
    row["status"] == 4 &&
    row["credentials"] == [501, 20, 501, 20, 501, 20]
end

def model_kill_basis_allowed?(stop_delivered, stopped_adopted)
  [stop_delivered, stopped_adopted].count(true) == 1
end

def model_post_adoption_kill_allowed?(first, second, expected, state)
  return false if state["invalid"] || state["kill_call_entered"]
  return false unless model_kill_basis_allowed?(
    state["stop_delivered"], state["stopped_adopted"]
  )
  model_stopped_adoption_allowed?(first, second, expected)
end

def model_kill_certificate_allowed?(certificate, expected_members, now_ns)
  expected_keys = %w[
    action consumed group issued_monotonic_ns members members_sha256 sid
    signal_call_entered signal_delivered
  ]
  return false unless certificate.keys.sort == expected_keys.sort
  return false unless certificate["action"] == "KILL" &&
    certificate["group"] == 70 && certificate["sid"] == 70 &&
    certificate["consumed"] == false &&
    certificate["signal_call_entered"] == false &&
    certificate["signal_delivered"] == false &&
    certificate["members"] == expected_members &&
    certificate["members_sha256"] ==
      Digest::SHA256.hexdigest(canonical_json(expected_members))
  issued = certificate["issued_monotonic_ns"]
  issued.is_a?(Integer) && issued <= now_ns &&
    now_ns - issued < CERTIFICATE_MAX_AGE_NS
end

def model_stop_wait_disposition(kind)
  return "adopt" if kind == "sstop"
  return "conserve_failure" if kind == "terminal_before_sstop"
  "reject_without_losing_owner"
end

def run_actuation_model_cases
  expected = {
    "pid" => 70, "uniqueid" => 700, "idversion" => 2,
    "puniqueid" => 600, "orig_ppidversion" => 9,
    "sid" => 70, "pgid" => 70,
  }
  stopped = [expected.merge(
    "classification" => "owned", "status" => 4,
    "credentials" => [501, 20, 501, 20, 501, 20]
  )]
  cases = []
  add = lambda { |name, pass| cases << { "name" => name, "pass" => !!pass } }
  deny = lambda do |name, rows|
    add.call(name, !model_stopped_adoption_allowed?(rows, rows, expected))
  end

  add.call("01_exact_singleton_sstop_adopts",
           model_stopped_adoption_allowed?(stopped, stopped, expected))
  deny.call("02_active_status_2_cannot_enter_canary_adapter",
            [stopped.first.merge("status" => 2)])
  deny.call("03_active_status_3_cannot_enter_canary_adapter",
            [stopped.first.merge("status" => 3)])
  add.call("04_empty_group_not_adopted",
           !model_stopped_adoption_allowed?([], [], expected))
  add.call("05_multiple_members_not_adopted",
           !model_stopped_adoption_allowed?(
             stopped + [stopped.first.merge("pid" => 71)],
             stopped + [stopped.first.merge("pid" => 71)], expected
           ))
  changed = [stopped.first.merge("idversion" => 3)]
  add.call("06_double_snapshot_drift_not_adopted",
           !model_stopped_adoption_allowed?(stopped, changed, expected))
  deny.call("07_unknown_classification_not_adopted",
            [stopped.first.merge("classification" => "unknown")])
  deny.call("08_ambient_classification_not_adopted",
            [stopped.first.merge("classification" => "ambient")])
  deny.call("09_pid_rebound_not_adopted",
            [stopped.first.merge("pid" => 71)])
  deny.call("10_uniqueid_rebound_not_adopted",
            [stopped.first.merge("uniqueid" => 701)])
  deny.call("11_idversion_rebound_not_adopted",
            [stopped.first.merge("idversion" => 3)])
  deny.call("12_parent_uniqueid_rebound_not_adopted",
            [stopped.first.merge("puniqueid" => 601)])
  deny.call("13_parent_idversion_rebound_not_adopted",
            [stopped.first.merge("orig_ppidversion" => 10)])
  deny.call("14_session_rebound_not_adopted",
            [stopped.first.merge("sid" => 1)])
  deny.call("15_group_rebound_not_adopted",
            [stopped.first.merge("pgid" => 1)])
  deny.call("16_credential_drift_not_adopted",
            [stopped.first.merge("credentials" => [0, 0, 0, 0, 0, 0])])
  deny.call("17_initializing_status_not_adopted",
            [stopped.first.merge("status" => 1)])
  deny.call("18_zombie_status_not_adopted",
            [stopped.first.merge("status" => 5)])
  deny.call("19_out_of_domain_status_not_adopted",
            [stopped.first.merge("status" => 6)])
  add.call("20_adoption_only_is_one_kill_basis",
           model_kill_basis_allowed?(false, true))
  add.call("21_delivered_stop_only_is_one_kill_basis",
           model_kill_basis_allowed?(true, false))
  add.call("22_missing_kill_basis_denied",
           !model_kill_basis_allowed?(false, false))
  add.call("23_dual_kill_basis_denied",
           !model_kill_basis_allowed?(true, true))
  adopted_state = {
    "invalid" => false, "kill_call_entered" => false,
    "stop_delivered" => false, "stopped_adopted" => true,
  }
  add.call("24_exact_post_adoption_sstop_allows_kill",
           model_post_adoption_kill_allowed?(
             stopped, stopped, expected, adopted_state
           ))
  late = stopped + [stopped.first.merge("pid" => 71, "uniqueid" => 701)]
  add.call("25_late_member_before_kill_denied",
           !model_post_adoption_kill_allowed?(
             late, late, expected, adopted_state
           ))
  rejected_state = adopted_state.merge("invalid" => true)
  add.call("26_rejected_adoption_then_shrink_remains_denied",
           !model_post_adoption_kill_allowed?(
             stopped, stopped, expected, rejected_state
           ))
  resumed = [stopped.first.merge("status" => 2)]
  add.call("27_post_adoption_resume_denied",
           !model_post_adoption_kill_allowed?(
             resumed, resumed, expected, adopted_state
           ))
  add.call("28_post_adoption_disappearance_cannot_prove_kill",
           !model_post_adoption_kill_allowed?([], [], expected, adopted_state))
  now_ns = 100_000_000
  kill_certificate = {
    "action" => "KILL", "consumed" => false, "group" => 70,
    "issued_monotonic_ns" => now_ns - 1,
    "members" => stopped,
    "members_sha256" => Digest::SHA256.hexdigest(canonical_json(stopped)),
    "sid" => 70, "signal_call_entered" => false,
    "signal_delivered" => false,
  }
  add.call("29_fresh_exact_kill_certificate_allowed",
           model_kill_certificate_allowed?(kill_certificate, stopped, now_ns))
  stale = kill_certificate.merge(
    "issued_monotonic_ns" => now_ns - CERTIFICATE_MAX_AGE_NS
  )
  add.call("30_expired_kill_certificate_denied",
           !model_kill_certificate_allowed?(stale, stopped, now_ns))
  reshaped = kill_certificate.reject { |key, _| key == "members_sha256" }
  add.call("31_reshaped_kill_certificate_denied",
           !model_kill_certificate_allowed?(reshaped, stopped, now_ns))
  consumed = kill_certificate.merge("consumed" => true)
  add.call("32_consumed_kill_certificate_denied",
           !model_kill_certificate_allowed?(consumed, stopped, now_ns))
  entered_state = adopted_state.merge("kill_call_entered" => true)
  add.call("33_second_kill_entry_denied",
           !model_post_adoption_kill_allowed?(
             stopped, stopped, expected, entered_state
           ))
  dual_state = adopted_state.merge("stop_delivered" => true)
  add.call("34_dual_basis_second_pass_denied",
           !model_post_adoption_kill_allowed?(
             stopped, stopped, expected, dual_state
           ))
  add.call("35_terminal_before_sstop_is_retained_for_conservation",
           model_stop_wait_disposition("terminal_before_sstop") ==
             "conserve_failure")
  add.call("36_unknown_stop_wait_never_enters_adoption",
           model_stop_wait_disposition("unknown") ==
             "reject_without_losing_owner")

  fail_r18("actuation model case count mismatch") unless cases.length == 36
  fail_r18("actuation model case failed") unless cases.all? { |entry| entry["pass"] }
  {
    "version" => ACTUATION_MODEL_VERSION,
    "case_count" => cases.length,
    "passed_count" => cases.count { |entry| entry["pass"] },
    "cases" => cases,
    "cases_sha256" => Digest::SHA256.hexdigest(canonical_json(cases)),
    "performed_process_operations" => false
  }
end

def compact_model_receipt(model)
  {
    "version" => model.fetch("version"),
    "case_count" => model.fetch("case_count"),
    "passed_count" => model.fetch("passed_count"),
    "cases_sha256" => model.fetch("cases_sha256"),
    "performed_process_operations" =>
      model.fetch("performed_process_operations"),
  }
end

def certificate_receipt(certificate)
  certificate.reject do |key, _|
    ["issued_monotonic", "issued_monotonic_ns"].include?(key)
  end
end

def compact_certificate_receipt(certificate)
  public = certificate_receipt(certificate)
  members = public.fetch("members")
  result = {
    "kind" => public["kind"],
    "action" => public["action"],
    "group" => public.fetch("group"),
    "sid" => public.fetch("sid"),
    "member_count" => members.length,
    "members_sha256" => public.fetch("members_sha256"),
    "certificate_sha256" => Digest::SHA256.hexdigest(canonical_json(public)),
  }
  %w[consumed signal_call_entered signal_delivered].each do |field|
    result[field] = public[field] if public.key?(field)
  end
  result
end

def actuator_entered_call_count(actuator, action)
  return "UNKNOWN" unless actuator
  actuator.call_budget.keys.count do |key|
    key.is_a?(Array) && key.length == 2 && key.first == action
  end
end

def actuator_delivered_call_count(actuator, action)
  return "UNKNOWN" unless actuator
  actuator.signal_ledger.count do |entry|
    entry["action"] == action && entry["delivered"] == true
  end
end

def controller_main
  $controller_interrupted = nil
  INTERRUPT_SIGNALS.each do |signal|
    Signal.trap(signal) { $controller_interrupted ||= signal }
  end
  adoption_method_entered = false
  kill_method_entered = false
  self_stop_command_sent = false
  started_wall = Time.now.utc.iso8601(6)
  started_monotonic = monotonic_time
  initial_cwd = File.realpath(Dir.pwd)
  fail_r18("marker root may not be controller cwd") if initial_cwd == MARKER_PATH
  runtime = validate_static_runtime!
  generation_model = run_model_cases
  actuation_model = run_actuation_model_cases
  guardian = load_guardian_regions!
  marker_state = create_marker_once!
  abi_probe = pid1_abi_probe
  controller_join = require_ruby_image_joined(Process.pid, "controller")
  controller_generation = controller_join.dig("unique", "uniqueid")
  pre_sweeps = [
    perform_ruid_sweep("pre_1", controller_generation),
    perform_ruid_sweep("pre_2", controller_generation)
  ]
  revalidate_marker!(marker_state)

  command_read, command_write = IO.pipe
  event_read, event_write = IO.pipe
  [command_read, command_write, event_read, event_write].each do |io|
    io.close_on_exec = true
  end
  event_reader = R18LineReader.new(event_read)
  deadline = monotonic_time + CONTROLLER_TIMEOUT_SECONDS
  controller_epoch_at_fork = immediate_unique_epoch(
    Process.pid, "controller immediately before worker fork"
  )
  child_pid = Process.fork do
    INTERRUPT_SIGNALS.each { |signal| Signal.trap(signal, "DEFAULT") }
    close_ios([command_write, event_read])
    run_preexec_worker(
      command_read, event_write,
      [marker_state["parent_io"], marker_state["marker_io"]]
    )
  end
  fork_committed = true
  child_active = true
  close_ios([command_read, event_write])

  pre_event = read_event(event_reader, "worker_preexec_ready", 1, deadline)
  child_pre = require_ruby_image_joined(child_pid, "worker before exec")
  assert_event_join!(pre_event, child_pre, child_pid, Process.pid)
  fail_r18("worker did not establish private session/group") unless
    child_pre["sid"] == child_pid && child_pre["pgid"] == child_pid
  fail_r18("worker pre-exec PPID mismatch") unless
    child_pre.dig("short", "ppid") == Process.pid
  fail_r18("worker parent uniqueid mismatch") unless
    child_pre.dig("unique", "puniqueid") == controller_epoch_at_fork["uniqueid"]
  fail_r18("worker parent idversion mismatch") unless
    child_pre.dig("unique", "orig_ppidversion") ==
      controller_epoch_at_fork["idversion"]
  child_uniqueid = child_pre.dig("unique", "uniqueid")

  write_command(command_write, "exec_worker")
  post_event = read_event(event_reader, "worker_postexec_ready", 2, deadline)
  child_post = require_ruby_image_joined(child_pid, "worker after exec")
  assert_event_join!(post_event, child_post, child_pid, Process.pid)
  fail_r18("worker lifetime changed across exec") unless
    child_post.dig("unique", "uniqueid") == child_pre.dig("unique", "uniqueid")
  fail_r18("worker idversion did not change across exec") if
    child_post.dig("unique", "idversion") == child_pre.dig("unique", "idversion")
  fail_r18("worker domain changed across exec") unless
    [child_post["sid"], child_post["pgid"]] == [child_pid, child_pid]
  fail_r18("worker post-exec PPID mismatch") unless
    child_post.dig("short", "ppid") == Process.pid
  fail_r18("worker parent uniqueid changed across exec") unless
    child_post.dig("unique", "puniqueid") ==
      child_pre.dig("unique", "puniqueid") &&
      child_post.dig("unique", "puniqueid") ==
        controller_epoch_at_fork["uniqueid"]
  fail_r18("worker parent idversion changed across exec") unless
    child_post.dig("unique", "orig_ppidversion") ==
      child_pre.dig("unique", "orig_ppidversion") &&
      child_post.dig("unique", "orig_ppidversion") ==
        controller_epoch_at_fork["idversion"]
  expected_lifetimes = Set[[child_pid, child_uniqueid]]
  write_command(command_write, "self_stop")
  self_stop_command_sent = true
  close_ios([command_write])
  self_stop_event = read_event(
    event_reader, "worker_self_stop_entering", 3, deadline
  )
  child_stop_wait = wait_exact_child_stopped(child_pid, deadline)
  if child_stop_wait["kind"] == "terminal_before_sstop"
    terminal_before_sstop = child_stop_wait.fetch("terminal")
    child_active = false
    fail_r18("child reached a retained terminal before SSTOP")
  end
  fail_r18("child stop wait disposition mismatch") unless
    child_stop_wait["kind"] == "sstop"
  child_stop_observation = child_stop_wait.fetch("observation")
  child_stopped = require_ruby_image_joined(child_pid, "self-stopped worker")
  assert_event_join!(self_stop_event, child_stopped, child_pid, Process.pid)
  fail_r18("worker did not remain exact singleton SSTOP") unless
    child_stopped.dig("short", "status") == 4 &&
      [child_stopped["sid"], child_stopped["pgid"]] == [child_pid, child_pid] &&
      child_stopped.dig("unique", "uniqueid") == child_uniqueid &&
      child_stopped.dig("unique", "idversion") ==
        child_post.dig("unique", "idversion")
  fail_r18("controller interrupted before stopped adoption") if
    $controller_interrupted

  tracker = ClosedStoppedTracker.new(child_stopped)
  actuator = GroupActuator.new(tracker)
  actuation_deadline = monotonic +
    (CONTROLLER_TIMEOUT_SECONDS * 1_000_000_000).to_i
  adoption_method_entered = true
  actuator.stop_current_groups!([child_stopped], actuation_deadline)
  stopped_state = actuator.stopped_groups.fetch(child_pid)
  adoption_certificate = stopped_state.fetch("adoption_certificate")
  pre_kill_actuation = actuator.receipt
  fail_r18("guardian stopped-adoption transition mismatch") unless
    stopped_state["stopped_adopted"] == true &&
      stopped_state["stop_delivered"] == false &&
      stopped_state["invalid"] != true &&
      actuator.call_budget.empty? && actuator.signal_ledger.empty? &&
      pre_kill_actuation["signal_calls"] == 0 &&
      pre_kill_actuation["stop_calls"] == 0 &&
      pre_kill_actuation["kill_calls"] == 0 &&
      pre_kill_actuation["adopted_stopped_group_count"] == 1 &&
      pre_kill_actuation["adopted_stopped_groups"] == [child_pid] &&
      !actuator.poisoned && !actuator.disabled &&
      actuator.fault_count == 0 && !tracker.classification_poisoned

  kill_method_entered = true
  actuator.kill_ready_groups!(actuation_deadline)
  stopped_state = actuator.stopped_groups.fetch(child_pid)
  kill_certificate = stopped_state.fetch("kill_certificate")
  actuation_receipt = actuator.receipt
  fail_r18("guardian one-KILL transition mismatch") unless
    actuator.call_budget == { ["KILL", child_pid] => 1 } &&
      actuator.signal_ledger.length == 1 &&
      actuator.signal_ledger.first["action"] == "KILL" &&
      actuator.signal_ledger.first["group"] == child_pid &&
      actuator.signal_ledger.first["call_entered"] == true &&
      actuator.signal_ledger.first["delivered"] == true &&
      stopped_state["kill_delivered"] == true &&
      actuation_receipt["signal_calls"] == 1 &&
      actuation_receipt["stop_calls"] == 0 &&
      actuation_receipt["kill_calls"] == 1 &&
      actuation_receipt["adopted_stopped_group_count"] == 1 &&
      !actuator.poisoned && !actuator.disabled &&
      actuator.fault_count == 0 && !tracker.classification_poisoned

  reap = wait_exact_child(child_pid, deadline)
  child_conservation = reap
  child_active = false
  fail_r18("child was not killed exactly by SIGKILL") unless
    reap["signaled"] && reap["term_signal"] == Signal.list.fetch("KILL") &&
      !reap["exited"]
  conservation_deadline = monotonic_time + CONSERVATION_TIMEOUT_SECONDS
  absence = [
    wait_for_generation_absence(reap["pid"], child_uniqueid, conservation_deadline),
    wait_for_generation_absence(reap["pid"], child_uniqueid, conservation_deadline)
  ]
  group_absence = double_group_absence(reap["pid"], conservation_deadline)
  process_conservation_complete = true
  post_sweeps = [
    perform_ruid_sweep("post_1", controller_generation),
    perform_ruid_sweep("post_2", controller_generation)
  ]
  event_reader.require_clean_eof(conservation_deadline)
  close_ios([event_read])
  revalidate_marker!(marker_state)
  final_cwd = File.realpath(Dir.pwd)
  fail_r18("cwd changed") unless final_cwd == initial_cwd
  INTERRUPT_SIGNALS.each { |signal| Signal.trap(signal, "IGNORE") }
  fail_r18("controller interrupted after conservation") if $controller_interrupted

  transcript = [pre_event, post_event, self_stop_event]
  payload = {
    "schema" => "prime-driver-v2-r18-successor-stopped-adoption-canary/v1",
    "status" => "R18_SUCCESSOR_STOPPED_ADOPTION_CANARY_PASS",
    "predecessor_commit" => "be1b2af174ae4dd3dc50997f3cad56cce2193c8c",
    "started_at" => started_wall,
    "duration_milliseconds" =>
      ((monotonic_time - started_monotonic) * 1_000).round(3),
    "runtime" => runtime,
    "guardian_regions" => guardian,
    "abi" => {
      "xnu_family" => "12377",
      "published_private_header_pin" => XNU_ABI_SOURCE,
      "flavor_17_size" => UNIQUE_INFO_SIZE,
      "short_bsd_size" => SHORT_BSD_SIZE,
      "successful_call_errno" => "ignored_and_not_recorded",
      "join_attempts" => JOIN_ATTEMPTS
    },
    "pid1_probe" => abi_probe,
    "marker" => marker_state["receipt"],
    "cwd" => {
      "path" => initial_cwd,
      "unchanged" => true,
      "marker_used_as_cwd" => false
    },
    "ruid_sweeps" => public_sweep_table(pre_sweeps + post_sweeps),
    "lineage" => {
      "joined_processes" => public_join_table([
        ["controller", controller_join],
        ["worker_preexec", child_pre],
        ["worker_postexec", child_post],
        ["worker_self_stopped", child_stopped],
      ]),
      "controller_epoch_at_fork" => controller_epoch_at_fork,
      "worker_stop_observation" => child_stop_observation,
      "worker_exact_reap" => reap,
      "worker_generation_absence" => absence,
      "group_absence" => group_absence
    },
    "actuation" => {
      "private_session" => child_post["sid"],
      "private_process_group" => child_post["pgid"],
      "stopped_member" => group_member_receipt(child_stopped),
      "stopped_adoption_certificate" =>
        compact_certificate_receipt(adoption_certificate),
      "kill_certificate" => compact_certificate_receipt(kill_certificate),
      "guardian_actuator_receipt" => actuation_receipt,
      "worker_libc_raise_call_sites" => 1,
      "worker_self_stop_intent_observed" => true,
      "worker_sigstop_wait_observed" => true,
      "worker_self_stop_entered_calls" => "UNPROVEN",
      "self_stop_origin_race_named" => true,
      "guardian_region_stop_entered_calls" => 0,
      "guardian_region_kill_entered_calls" => 1,
      "controller_cont_entered_calls" => 0,
      "signal_zero_absence_probes" => group_absence.length,
      "signal_target_scope" => "exact_direct_child_private_group",
      "atomic_generation_bound_signal_available" => false,
      "userspace_snapshot_signal_race_named" => true
    },
    "protocol" => {
      "events" => transcript.map { |event| event["event"] },
      "event_count" => transcript.length,
      "transcript_sha256" => Digest::SHA256.hexdigest(canonical_json(transcript)),
      "command_fd" => WORKER_COMMAND_FD,
      "event_fd" => WORKER_EVENT_FD,
      "frame_cap_bytes" => FRAME_CAPACITY
    },
    "operations" => {
      "fork_calls" => 1,
      "exec_calls" => 1,
      "worker_libc_raise_call_sites" => 1,
      "worker_self_stop_entered_calls" => "UNPROVEN",
      "guardian_region_process_kill_call_sites" => 1,
      "guardian_region_stop_entered_calls" => 0,
      "guardian_region_kill_entered_calls" => 1,
      "controller_cont_entered_calls" => 0,
      "signal_zero_call_sites" => 1,
      "signal_zero_entered_calls" => 2,
      "spawn_calls" => 0,
      "shell_calls" => 0,
      "swift_calls" => 0,
      "git_calls" => 0,
      "constructor_calls" => 0,
      "production_guardian_invocations" => 0,
      "selectively_executed_guardian_regions" => 2,
      "script_transport" => "named_path_to_pinned_ruby_interpreter",
      "script_is_held_mapped_executable" => false,
      "named_script_snapshot_to_exec_race_named" => true,
      "timeout_authority" => "liveness_only_never_abandonment",
      "failure_terminal_requires_blocking_conservation" => true
    },
    "receipt_bounds" => {
      "hard_cap_bytes" => RECEIPT_CAPACITY,
      "policy_max_bytes" => RECEIPT_POLICY_MAX_BYTES,
      "numeric_width_structural_upper_bound_bytes" => MAXIMUM_UNSIGNED_64,
    },
    "pure_generation_model" => compact_model_receipt(generation_model),
    "pure_actuation_model" => compact_model_receipt(actuation_model),
    "scientific_authorities_closed" => 0,
    "authority_vector" => "00000000",
    "scientific_outcome" => "ABSTAIN"
  }
  structural_bound = structural_receipt_upper_bound_bytes(payload)
  fail_r18("success structural receipt bound exceeds policy maximum") if
    structural_bound > RECEIPT_POLICY_MAX_BYTES
  payload["receipt_bounds"][
    "numeric_width_structural_upper_bound_bytes"
  ] = structural_bound
  receipt = canonical_receipt(payload)
  fail_r18("success receipt exceeds structural bound") if
    receipt.bytesize > structural_bound
  written = STDOUT.write(receipt)
  fail_r18("success receipt short write") unless written == receipt.bytesize
  STDOUT.flush
  close_ios([marker_state["marker_io"], marker_state["parent_io"]])
  0
rescue StandardError => error
  close_ios([
    defined?(command_write) ? command_write : nil,
    defined?(event_read) ? event_read : nil
  ])

  containment_fault_count = 0
  last_containment_fault = nil
  child_conservation = if defined?(reap) && reap
    reap
  elsif defined?(terminal_before_sstop) && terminal_before_sstop
    terminal_before_sstop
  end
  if defined?(fork_committed) && fork_committed &&
     defined?(child_active) && child_active
    loop do
      begin
        reaped = poll_exact_child(child_pid)
        if reaped
          child_conservation = reaped
          child_active = false
          break
        end

        expected_join = if defined?(child_stopped) && child_stopped
          child_stopped
        elsif defined?(child_post) && child_post
          child_post
        elsif defined?(child_pre) && child_pre
          child_pre
        end
        current = join_process(child_pid)
        if expected_join && current["kind"] == "joined" &&
           current.dig("short", "status") == 4
          fail_r18("containment child generation drift") unless
            current.dig("unique", "uniqueid") ==
              expected_join.dig("unique", "uniqueid") &&
              current.dig("unique", "idversion") ==
                expected_join.dig("unique", "idversion") &&
              [current["sid"], current["pgid"]] == [child_pid, child_pid]
          unless defined?(actuator) && actuator
            tracker = ClosedStoppedTracker.new(expected_join)
            actuator = GroupActuator.new(tracker)
          end
          unless adoption_method_entered
            adoption_method_entered = true
            containment_deadline = monotonic +
              (CONTROLLER_TIMEOUT_SECONDS * 1_000_000_000).to_i
            actuator.stop_current_groups!([current], containment_deadline)
          end
          unless kill_method_entered
            kill_method_entered = true
            containment_deadline = monotonic +
              (CONTROLLER_TIMEOUT_SECONDS * 1_000_000_000).to_i
            actuator.kill_ready_groups!(containment_deadline)
          end
        end
      rescue StandardError => containment_error
        containment_fault_count += 1
        last_containment_fault = error_receipt(containment_error)
      end
      sleep(0.01)
    end
  end
  loop { sleep(60.0) } if
    defined?(fork_committed) && fork_committed &&
      defined?(child_active) && child_active

  absence = defined?(absence) ? absence : nil
  group_absence = defined?(group_absence) ? group_absence : nil
  process_conservation_complete =
    defined?(process_conservation_complete) && process_conservation_complete
  unless process_conservation_complete
    if child_conservation && child_conservation["pid"]
      conserved_pid = child_conservation["pid"]
      loop do
        begin
          if defined?(child_uniqueid) && child_uniqueid
            absence = [
              wait_for_generation_absence(conserved_pid, child_uniqueid),
              wait_for_generation_absence(conserved_pid, child_uniqueid)
            ]
          else
            first_kind, = read_unique(conserved_pid)
            second_kind, = read_unique(conserved_pid)
            fail_r18("unidentified child PID did not reach exact ESRCH") unless
              first_kind == "gone" && second_kind == "gone"
            absence = [
              { "pid" => conserved_pid, "observation" => "ESRCH" },
              { "pid" => conserved_pid, "observation" => "ESRCH" }
            ]
          end
          group_absence = double_group_absence(conserved_pid)
          process_conservation_complete = true
          break
        rescue StandardError => conservation_error
          containment_fault_count += 1
          last_containment_fault = error_receipt(conservation_error)
          sleep(0.01)
        end
      end
    elsif !defined?(fork_committed) || !fork_committed
      process_conservation_complete = true
    else
      loop { sleep(60.0) }
    end
  end
  INTERRUPT_SIGNALS.each { |signal| Signal.trap(signal, "IGNORE") }

  marker_observation = nil
  if defined?(marker_state) && marker_state
    begin
      revalidate_marker!(marker_state)
      marker_observation = {
        "path" => MARKER_PATH,
        "empty" => true,
        "kept_after_outcome" => true,
        "used_as_cwd" => false
      }
    rescue StandardError => marker_error
      marker_observation = {
        "path" => MARKER_PATH,
        "status" => "UNKNOWN",
        "error" => error_receipt(marker_error)
      }
    end
  end

  failure_payload = {
    "schema" => "prime-driver-v2-r18-successor-stopped-adoption-canary/v1",
    "status" => "R18_SUCCESSOR_STOPPED_ADOPTION_CANARY_FAILED",
    "predecessor_commit" => "be1b2af174ae4dd3dc50997f3cad56cce2193c8c",
    "error" => error_receipt(error),
    "marker" => marker_observation,
    "child_conservation" => child_conservation,
    "generation_absence" => absence,
    "group_absence" => group_absence,
    "process_conservation_complete" => process_conservation_complete,
    "self_stop_command_sent" => self_stop_command_sent,
    "worker_libc_raise_call_sites" => 1,
    "worker_self_stop_intent_observed" =>
      !!(defined?(self_stop_event) && self_stop_event),
    "worker_sigstop_wait_observed" =>
      !!(defined?(child_stop_observation) && child_stop_observation),
    "worker_self_stop_entered_calls" => "UNPROVEN",
    "self_stop_origin_race_named" => true,
    "guardian_region_process_kill_call_sites" => 1,
    "guardian_region_stop_entered_calls" =>
      actuator_entered_call_count(
        defined?(actuator) && actuator ? actuator : nil, "STOP"
      ),
    "guardian_region_stop_delivered_calls" =>
      actuator_delivered_call_count(
        defined?(actuator) && actuator ? actuator : nil, "STOP"
      ),
    "guardian_region_kill_entered_calls" =>
      actuator_entered_call_count(
        defined?(actuator) && actuator ? actuator : nil, "KILL"
      ),
    "guardian_region_kill_delivered_calls" =>
      actuator_delivered_call_count(
        defined?(actuator) && actuator ? actuator : nil, "KILL"
      ),
    "adoption_method_entered" => adoption_method_entered,
    "kill_method_entered" => kill_method_entered,
    "kill_call_entered" => !!(defined?(actuator) && actuator &&
      actuator.call_budget[["KILL", child_pid]]),
    "kill_delivery_recorded" => !!(defined?(actuator) && actuator &&
      actuator.signal_ledger.any? do |entry|
        entry["action"] == "KILL" && entry["delivered"]
      end),
    "actuator" => if defined?(actuator) && actuator
      begin
        actuator.receipt
      rescue StandardError => receipt_error
        { "status" => "UNAVAILABLE", "error" => error_receipt(receipt_error) }
      end
    end,
    "interrupted_signal" => $controller_interrupted,
    "containment_fault_count" => containment_fault_count,
    "last_containment_fault" => last_containment_fault,
    "receipt_bounds" => {
      "hard_cap_bytes" => RECEIPT_CAPACITY,
      "policy_max_bytes" => RECEIPT_POLICY_MAX_BYTES,
      "numeric_width_structural_upper_bound_bytes" => MAXIMUM_UNSIGNED_64,
    },
    "scientific_authorities_closed" => 0,
    "authority_vector" => "00000000",
    "scientific_outcome" => "ABSTAIN"
  }
  failure_unsealed = canonical_json(failure_payload)
  failure_bound = structural_receipt_upper_bound_bytes(failure_payload)
  if failure_bound > RECEIPT_POLICY_MAX_BYTES
    failure_payload = {
      "schema" =>
        "prime-driver-v2-r18-successor-stopped-adoption-canary/v1",
      "status" => "R18_SUCCESSOR_STOPPED_ADOPTION_CANARY_FAILED",
      "predecessor_commit" =>
        "be1b2af174ae4dd3dc50997f3cad56cce2193c8c",
      "error" => error_receipt(error),
      "oversized_failure_payload_bytes" => failure_unsealed.bytesize,
      "oversized_failure_payload_sha256" =>
        Digest::SHA256.hexdigest(failure_unsealed),
      "process_conservation_complete" => process_conservation_complete,
      "child_conservation" => child_conservation,
      "generation_absence" => absence,
      "group_absence" => group_absence,
      "marker" => marker_observation,
      "receipt_bounds" => {
        "hard_cap_bytes" => RECEIPT_CAPACITY,
        "policy_max_bytes" => RECEIPT_POLICY_MAX_BYTES,
        "numeric_width_structural_upper_bound_bytes" => MAXIMUM_UNSIGNED_64,
      },
      "scientific_authorities_closed" => 0,
      "authority_vector" => "00000000",
      "scientific_outcome" => "ABSTAIN",
    }
    failure_bound = structural_receipt_upper_bound_bytes(failure_payload)
  end
  if failure_bound > RECEIPT_POLICY_MAX_BYTES
    failure_payload = {
      "schema" =>
        "prime-driver-v2-r18-successor-stopped-adoption-canary/v1",
      "status" => "R18_SUCCESSOR_STOPPED_ADOPTION_CANARY_FAILED",
      "predecessor_commit" =>
        "be1b2af174ae4dd3dc50997f3cad56cce2193c8c",
      "error" => error_receipt(error),
      "unpublishable_failure_payload_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(failure_payload)),
      "process_conservation_complete" => process_conservation_complete,
      "receipt_bounds" => {
        "hard_cap_bytes" => RECEIPT_CAPACITY,
        "policy_max_bytes" => RECEIPT_POLICY_MAX_BYTES,
        "numeric_width_structural_upper_bound_bytes" => MAXIMUM_UNSIGNED_64,
      },
      "scientific_authorities_closed" => 0,
      "authority_vector" => "00000000",
      "scientific_outcome" => "ABSTAIN",
    }
    failure_bound = structural_receipt_upper_bound_bytes(failure_payload)
  end
  fail_r18("minimal failure structural bound exceeds policy maximum") if
    failure_bound > RECEIPT_POLICY_MAX_BYTES
  failure_payload["receipt_bounds"][
    "numeric_width_structural_upper_bound_bytes"
  ] = failure_bound
  failure_receipt = canonical_receipt(failure_payload)
  fail_r18("failure receipt exceeds structural bound") if
    failure_receipt.bytesize > failure_bound
  STDERR.write(failure_receipt)
  STDERR.flush
  close_ios([
    defined?(marker_state) && marker_state ? marker_state["marker_io"] : nil,
    defined?(marker_state) && marker_state ? marker_state["parent_io"] : nil
  ])
  70
end

if role == WORKER_ROLE
  run_exec_worker
else
  exit(controller_main)
end
