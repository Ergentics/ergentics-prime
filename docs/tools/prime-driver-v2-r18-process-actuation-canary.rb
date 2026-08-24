#!/usr/bin/ruby
# frozen_string_literal: true

# R18 is a disposable process-actuation composition canary. It does not invoke
# Swift, the supervisor, the guardian, Git, a shell, or any mechanics harness.
# Its only signal target is the private session/process group of its exact
# direct child. Its fixed marker is never a cwd and remains empty forever.

ROLE_KEY = "R18_PROCESS_ACTUATION_CANARY_ROLE"
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
    "\"status\":\"R18_PROCESS_ACTUATION_CANARY_FAILED\"}\n")
  exit(70)
end

require "digest"
require "fiddle/import"
require "json"
require "set"
require "time"

class R18Failure < StandardError
end

module R18LibC
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)

  extern "int getsid(int)"
  extern "int getpgid(int)"
  extern "int kill(int, int)"
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

SCRIPT_PATH = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r18-process-actuation-canary.rb"
RUBY_IMAGE = "/usr/bin/ruby"
EXPECTED_CWD = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging"
MARKER_PARENT_PATH = "/private/tmp"
MARKER_LEAF = "gate-e1-4-r18-process-actuation-canary-237713eb-befc6324-b501ad0d7ab1b6c5"
MARKER_PATH = "#{MARKER_PARENT_PATH}/#{MARKER_LEAF}"

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
RECEIPT_CAPACITY = 32_768
HELPER_TIMEOUT_SECONDS = 20.0
CONTROLLER_TIMEOUT_SECONDS = 30.0
CONSERVATION_TIMEOUT_SECONDS = 30.0
MODEL_VERSION = "r18-generation-domain-model-v1"
ACTUATION_MODEL_VERSION = "r18-generation-bound-actuation-model-v1"
XNU_ABI_SOURCE = "apple-oss-distributions/xnu@xnu-12377.1.9/bsd/sys/proc_info_private.h"
INTERRUPT_SIGNALS = %w[HUP INT QUIT TERM].freeze

def fail_r18(message)
  raise R18Failure, message
end

def monotonic_time
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
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

def held_regular_file_receipt(path)
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
  {
    "device" => held.dev,
    "inode" => held.ino,
    "uid" => held.uid,
    "gid" => held.gid,
    "mode" => held.mode & 0o7777,
    "nlink" => held.nlink,
    "size" => held.size,
    "sha256" => Digest::SHA256.hexdigest(bytes)
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
  ruby_image = held_regular_file_receipt(RUBY_IMAGE)
  fail_r18("Ruby image identity mismatch") unless ruby_image == EXPECTED_RUBY_IMAGE
  script_image = held_regular_file_receipt(SCRIPT_PATH)
  stdin = validate_stdin_dev_null!

  {
    "ruby" => observed_ruby,
    "ruby_image" => ruby_image.merge("arm64e_uuid_hex" => EXPECTED_RUBY_ARM64E_UUID_HEX),
    "sysctls" => observed_sysctls,
    "credentials" => observed_credentials,
    "incoming_umask" => format("%04o", INCOMING_UMASK),
    "script_image" => script_image,
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
  read_command(R18LineReader.new(command_io, 64), "hold", deadline)
  loop do
    remaining = deadline - monotonic_time
    exit!(70) unless remaining.positive?
    sleep([remaining, 1.0].min)
  end
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

def poll_exact_child(pid)
  pair = Process.waitpid2(pid, Process::WNOHANG)
  return nil unless pair
  status = pair.last
  {
    "pid" => pid,
    "exited" => status.exited?,
    "exit_status" => status.exited? ? status.exitstatus : nil,
    "signaled" => status.signaled?,
    "term_signal" => status.signaled? ? status.termsig : nil,
    "raw_status" => status.to_i
  }
rescue Errno::ECHILD
  fail_r18("exact child ownership lost")
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

def joined_group_snapshot(group, expected_sid, expected_lifetimes)
  pids = list_group_pids(group)
  fail_r18("actuation group is empty") if pids.empty?
  fail_r18("actuation group membership mismatch") unless
    pids == expected_lifetimes.keys.sort
  pids.map do |pid|
    joined = join_process(pid)
    fail_r18("group member did not join stably") unless joined["kind"] == "joined"
    uniqueid = joined.dig("unique", "uniqueid")
    fail_r18("group member lifetime mismatch") unless
      expected_lifetimes[pid] == uniqueid
    fail_r18("group member executable UUID mismatch") unless
      joined.dig("unique", "uuid_hex") == EXPECTED_RUBY_ARM64E_UUID_HEX
    fail_r18("group member SID/PGID mismatch") unless
      joined["sid"] == expected_sid && joined["pgid"] == group &&
        joined.dig("short", "pgid") == group
    fail_r18("group member credential drift") unless
      expected_member_credentials?(joined)
    {
      "classification" => "owned",
      "pid" => pid,
      "uniqueid" => uniqueid,
      "idversion" => joined.dig("unique", "idversion"),
      "puniqueid" => joined.dig("unique", "puniqueid"),
      "orig_ppidversion" => joined.dig("unique", "orig_ppidversion"),
      "sid" => joined["sid"],
      "pgid" => joined["pgid"],
      "status" => joined.dig("short", "status"),
      "credentials" => %w[uid gid ruid rgid svuid svgid].map do |field|
        joined.dig("short", field)
      end
    }
  end.sort_by { |member| member["pid"] }
end

def double_group_snapshot(group, expected_sid, expected_lifetimes)
  first = joined_group_snapshot(group, expected_sid, expected_lifetimes)
  second = joined_group_snapshot(group, expected_sid, expected_lifetimes)
  fail_r18("actuation group changed between snapshots") unless first == second
  first
end

def issue_actuation_certificate(action, group, expected_sid, expected_lifetimes)
  fail_r18("invalid actuation") unless %w[STOP KILL].include?(action)
  members = double_group_snapshot(group, expected_sid, expected_lifetimes)
  if action == "STOP"
    fail_r18("STOP certificate lacks runnable/sleeping member state") unless
      members.all? { |member| [2, 3].include?(member["status"]) }
  else
    fail_r18("KILL certificate lacks stopped fixed point") unless
      members.all? { |member| member["status"] == 4 }
  end
  {
    "action" => action,
    "group" => group,
    "sid" => expected_sid,
    "members" => members,
    "members_sha256" => Digest::SHA256.hexdigest(canonical_json(members)),
    "issued_monotonic" => monotonic_time,
    "consumed" => false,
    "signal_call_entered" => false,
    "signal_delivered" => false
  }
end

CERTIFICATE_KEYS = %w[
  action consumed group issued_monotonic members members_sha256 sid
  signal_call_entered signal_delivered
].freeze

def consume_actuation_certificate(certificate, signal_call_budget,
                                   expected_action:, expected_group:,
                                   expected_sid:, expected_lifetimes:)
  fail_r18("actuation certificate is not an object") unless
    certificate.is_a?(Hash)
  fail_r18("actuation certificate key set mismatch") unless
    certificate.keys.sort == CERTIFICATE_KEYS.sort
  fail_r18("actuation certificate target mismatch") unless
    certificate["action"] == expected_action &&
      certificate["group"] == expected_group &&
      certificate["sid"] == expected_sid
  members = certificate["members"]
  fail_r18("actuation certificate members invalid") unless
    members.is_a?(Array) && !members.empty? &&
      Digest::SHA256.hexdigest(canonical_json(members)) ==
        certificate["members_sha256"]
  fail_r18("actuation certificate membership mismatch") unless
    members.map { |member| member["pid"] }.sort == expected_lifetimes.keys.sort
  fail_r18("actuation certificate member binding mismatch") unless
    members.all? do |member|
      member["classification"] == "owned" &&
        expected_lifetimes[member["pid"]] == member["uniqueid"] &&
        member["sid"] == expected_sid && member["pgid"] == expected_group &&
        member["credentials"] == [501, 20, 501, 20, 501, 20] &&
        (expected_action == "STOP" ? [2, 3].include?(member["status"]) :
          member["status"] == 4)
    end
  fail_r18("actuation certificate already consumed") unless
    certificate["consumed"] == false &&
      certificate["signal_call_entered"] == false &&
      certificate["signal_delivered"] == false
  fail_r18("actuation certificate expired") unless
    monotonic_time - certificate["issued_monotonic"] < 0.05
  certificate["consumed"] = true
  action = certificate["action"]
  fail_r18("signal call budget exhausted") unless signal_call_budget[action] == 0
  signal_call_budget[action] += 1
  certificate["signal_call_entered"] = true
  delivered = Process.kill(action, -certificate["group"])
  fail_r18("group signal delivery count mismatch") unless delivered == 1
  certificate["signal_delivered"] = true
  delivered
end

def stopped_certificate_once(group, sid, lifetimes)
  members = double_group_snapshot(group, sid, lifetimes)
  fail_r18("group member became zombie before KILL") if
    members.any? { |member| member["status"] == 5 }
  return nil unless members.all? { |member| member["status"] == 4 }
  {
    "action" => "KILL",
    "group" => group,
    "sid" => sid,
    "members" => members,
    "members_sha256" => Digest::SHA256.hexdigest(canonical_json(members)),
    "issued_monotonic" => monotonic_time,
    "consumed" => false,
    "signal_call_entered" => false,
    "signal_delivered" => false
  }
end

def wait_for_stopped_certificate(group, sid, lifetimes, deadline = nil)
  loop do
    fail_r18("controller interrupted") if $controller_interrupted
    certificate = stopped_certificate_once(group, sid, lifetimes)
    return certificate if certificate
    fail_r18("stopped fixed point timed out") if
      deadline && monotonic_time >= deadline
    sleep(0.001)
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

def model_certificate_allowed?(action, first, second, expected_sid:, expected_pgid:,
                               expected_lifetimes:)
  return false unless %w[STOP KILL].include?(action)
  return false unless first == second && !first.empty?
  return false unless first.map { |row| row["pid"] }.sort == expected_lifetimes.keys.sort
  first.all? do |row|
    row["classification"] == "owned" &&
      row["sid"] == expected_sid && row["pgid"] == expected_pgid &&
      expected_lifetimes[row["pid"]] == row["uniqueid"] &&
      row["credentials"] == [501, 20, 501, 20, 501, 20] &&
      (action == "STOP" ? [2, 3].include?(row["status"]) :
        row["status"] == 4)
  end
end

def run_actuation_model_cases
  base = [{
    "classification" => "owned", "pid" => 70, "uniqueid" => 700,
    "idversion" => 2, "sid" => 70, "pgid" => 70, "status" => 2,
    "credentials" => [501, 20, 501, 20, 501, 20]
  }]
  expected = { 70 => 700 }
  stopped = Marshal.load(Marshal.dump(base))
  stopped.first["status"] = 4
  cases = []
  add = lambda { |name, pass| cases << { "name" => name, "pass" => !!pass } }
  add.call("01_owned_active_double_snapshot_allows_stop",
           model_certificate_allowed?("STOP", base, base, expected_sid: 70,
                                      expected_pgid: 70, expected_lifetimes: expected))
  add.call("02_owned_stopped_double_snapshot_allows_kill",
           model_certificate_allowed?("KILL", stopped, stopped, expected_sid: 70,
                                      expected_pgid: 70, expected_lifetimes: expected))
  changed_epoch = Marshal.load(Marshal.dump(base))
  changed_epoch.first["idversion"] = 3
  add.call("03_epoch_change_between_snapshots_denies",
           !model_certificate_allowed?("STOP", base, changed_epoch,
                                       expected_sid: 70, expected_pgid: 70,
                                       expected_lifetimes: expected))
  changed_members = base + [base.first.merge("pid" => 71, "uniqueid" => 701)]
  add.call("04_membership_change_denies",
           !model_certificate_allowed?("STOP", base, changed_members,
                                       expected_sid: 70, expected_pgid: 70,
                                       expected_lifetimes: expected))
  unknown = [base.first.merge("classification" => "unknown")]
  add.call("05_unknown_denies", !model_certificate_allowed?(
    "STOP", unknown, unknown, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  ambient = [base.first.merge("classification" => "ambient")]
  add.call("06_ambient_denies", !model_certificate_allowed?(
    "STOP", ambient, ambient, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  rebound = [base.first.merge("uniqueid" => 999)]
  add.call("07_pid_rebound_denies", !model_certificate_allowed?(
    "STOP", rebound, rebound, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  wrong_domain = [base.first.merge("sid" => 1)]
  add.call("08_domain_rebound_denies", !model_certificate_allowed?(
    "STOP", wrong_domain, wrong_domain, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  drift = [base.first.merge("credentials" => [0, 0, 0, 0, 0, 0])]
  add.call("09_credential_drift_denies", !model_certificate_allowed?(
    "STOP", drift, drift, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  add.call("10_active_member_denies_kill", !model_certificate_allowed?(
    "KILL", base, base, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  zombie = Marshal.load(Marshal.dump(base))
  zombie.first["status"] = 5
  add.call("11_zombie_member_denies_kill", !model_certificate_allowed?(
    "KILL", zombie, zombie, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  idle = Marshal.load(Marshal.dump(base))
  idle.first["status"] = 1
  add.call("12_initializing_member_denies_stop", !model_certificate_allowed?(
    "STOP", idle, idle, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  invalid = Marshal.load(Marshal.dump(base))
  invalid.first["status"] = 6
  add.call("13_out_of_domain_status_denies_stop", !model_certificate_allowed?(
    "STOP", invalid, invalid, expected_sid: 70, expected_pgid: 70,
    expected_lifetimes: expected
  ))
  fail_r18("actuation model case count mismatch") unless cases.length == 13
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

def certificate_receipt(certificate)
  certificate.reject { |key, _| key == "issued_monotonic" }
end

def controller_main
  $controller_interrupted = nil
  INTERRUPT_SIGNALS.each do |signal|
    Signal.trap(signal) { $controller_interrupted ||= signal }
  end
  signal_call_budget = { "STOP" => 0, "KILL" => 0 }
  started_wall = Time.now.utc.iso8601(6)
  started_monotonic = monotonic_time
  initial_cwd = File.realpath(Dir.pwd)
  fail_r18("marker root may not be controller cwd") if initial_cwd == MARKER_PATH
  runtime = validate_static_runtime!
  generation_model = run_model_cases
  actuation_model = run_actuation_model_cases
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
  child_uniqueid = child_post.dig("unique", "uniqueid")
  expected_lifetimes = { child_pid => child_uniqueid }
  write_command(command_write, "hold")
  close_ios([command_write])
  fail_r18("controller interrupted before actuation") if $controller_interrupted

  stop_certificate = issue_actuation_certificate(
    "STOP", child_pid, child_pid, expected_lifetimes
  )
  consume_actuation_certificate(
    stop_certificate, signal_call_budget,
    expected_action: "STOP", expected_group: child_pid,
    expected_sid: child_pid, expected_lifetimes: expected_lifetimes
  )
  fail_r18("controller interrupted after STOP") if $controller_interrupted
  stopped_certificate = wait_for_stopped_certificate(
    child_pid, child_pid, expected_lifetimes, deadline
  )
  consume_actuation_certificate(
    stopped_certificate, signal_call_budget,
    expected_action: "KILL", expected_group: child_pid,
    expected_sid: child_pid, expected_lifetimes: expected_lifetimes
  )

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
  fail_r18("signal call budget mismatch") unless
    signal_call_budget == { "STOP" => 1, "KILL" => 1 }
  fail_r18("signal delivery proof mismatch") unless
    stop_certificate["signal_delivered"] &&
      stopped_certificate["signal_delivered"]

  transcript = [pre_event, post_event]
  payload = {
    "schema" => "prime-driver-v2-r18-process-actuation-canary/v1",
    "status" => "R18_PROCESS_ACTUATION_CANARY_PASS",
    "predecessor_commit" => "237713eba73353586883f81a7454063b2ea562e6",
    "started_at" => started_wall,
    "duration_milliseconds" =>
      ((monotonic_time - started_monotonic) * 1_000).round(3),
    "runtime" => runtime,
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
      "initial" => initial_cwd,
      "final" => final_cwd,
      "unchanged" => true,
      "marker_used_as_cwd" => false
    },
    "ruid_sweeps" => pre_sweeps + post_sweeps,
    "lineage" => {
      "controller" => public_join(controller_join),
      "controller_epoch_at_fork" => controller_epoch_at_fork,
      "worker_preexec" => public_join(child_pre),
      "worker_postexec" => public_join(child_post),
      "worker_exact_reap" => reap,
      "worker_generation_absence" => absence,
      "group_absence" => group_absence
    },
    "actuation" => {
      "private_session" => child_post["sid"],
      "private_process_group" => child_post["pgid"],
      "stop_certificate" => certificate_receipt(stop_certificate),
      "stopped_fixed_point_certificate" =>
        certificate_receipt(stopped_certificate),
      "stop_signals_sent" => stop_certificate["signal_delivered"] ? 1 : 0,
      "kill_signals_sent" => stopped_certificate["signal_delivered"] ? 1 : 0,
      "stop_kill_syscall_entries" => signal_call_budget.values.sum,
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
      "spawn_calls" => 0,
      "shell_calls" => 0,
      "swift_calls" => 0,
      "git_calls" => 0,
      "constructor_calls" => 0,
      "guardian_calls" => 0,
      "timeout_authority" => "liveness_only_never_abandonment",
      "failure_terminal_requires_blocking_conservation" => true
    },
    "pure_generation_model" => generation_model,
    "pure_actuation_model" => actuation_model,
    "scientific_authorities_closed" => 0,
    "authority_vector" => "00000000",
    "scientific_outcome" => "ABSTAIN"
  }
  receipt = canonical_receipt(payload)
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
  child_conservation = defined?(reap) ? reap : nil
  if defined?(fork_committed) && fork_committed &&
     defined?(child_active) && child_active
    stop_call_entered = defined?(stop_certificate) && stop_certificate &&
      stop_certificate["signal_call_entered"]
    if stop_call_entered
      loop do
        begin
          reaped = poll_exact_child(child_pid)
          if reaped
            child_conservation = reaped
            child_active = false
            break
          end
          kill_was_delivered = defined?(stopped_certificate) &&
            stopped_certificate && stopped_certificate["signal_delivered"]
          unless kill_was_delivered
            if signal_call_budget["KILL"] >= 1
              sleep(0.01)
              next
            end
            certificate = stopped_certificate_once(
              child_pid, child_pid, expected_lifetimes
            )
            if certificate
              containment_kill_certificate = certificate
              consume_actuation_certificate(
                containment_kill_certificate, signal_call_budget,
                expected_action: "KILL", expected_group: child_pid,
                expected_sid: child_pid,
                expected_lifetimes: expected_lifetimes
              )
            else
              sleep(0.01)
              next
            end
          end
          child_conservation = wait_exact_child(child_pid)
          child_active = false
          break
        rescue StandardError => containment_error
          containment_fault_count += 1
          last_containment_fault = containment_error.message
          sleep(0.01)
        end
      end
    else
      begin
        child_conservation = wait_exact_child(child_pid)
        child_active = false
      rescue StandardError => containment_error
        containment_fault_count += 1
        last_containment_fault = containment_error.message
      end
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
          last_containment_fault = conservation_error.message
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
        "error" => marker_error.message
      }
    end
  end

  failure_payload = {
    "schema" => "prime-driver-v2-r18-process-actuation-canary/v1",
    "status" => "R18_PROCESS_ACTUATION_CANARY_FAILED",
    "predecessor_commit" => "237713eba73353586883f81a7454063b2ea562e6",
    "error_class" => error.class.name,
    "error" => error.message,
    "marker" => marker_observation,
    "child_conservation" => child_conservation,
    "generation_absence" => absence,
    "group_absence" => group_absence,
    "process_conservation_complete" => process_conservation_complete,
    "stop_attempted" => signal_call_budget["STOP"] == 1,
    "stop_delivered" => !!(defined?(stop_certificate) && stop_certificate &&
      stop_certificate["signal_delivered"]),
    "kill_attempted" => signal_call_budget["KILL"] == 1,
    "kill_delivered" => !!(defined?(stopped_certificate) &&
      stopped_certificate && stopped_certificate["signal_delivered"]) ||
      !!(defined?(containment_kill_certificate) &&
        containment_kill_certificate &&
        containment_kill_certificate["signal_delivered"]),
    "signal_call_budget" => signal_call_budget,
    "stop_certificate" => (certificate_receipt(stop_certificate) if
      defined?(stop_certificate) && stop_certificate),
    "kill_certificate" => (certificate_receipt(stopped_certificate) if
      defined?(stopped_certificate) && stopped_certificate),
    "containment_kill_certificate" =>
      (certificate_receipt(containment_kill_certificate) if
        defined?(containment_kill_certificate) && containment_kill_certificate),
    "interrupted_signal" => $controller_interrupted,
    "containment_fault_count" => containment_fault_count,
    "last_containment_fault" => last_containment_fault,
    "scientific_authorities_closed" => 0,
    "authority_vector" => "00000000",
    "scientific_outcome" => "ABSTAIN"
  }
  STDERR.write(canonical_receipt(failure_payload))
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
