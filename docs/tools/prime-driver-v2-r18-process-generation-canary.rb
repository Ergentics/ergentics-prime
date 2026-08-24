#!/usr/bin/ruby
# frozen_string_literal: true

# R18 is a disposable, process-only ABI canary.  It does not invoke the Swift
# supervisor, the guardian, Git, a shell, or any mechanics harness.  Its fixed
# marker directory is the durable one-shot witness; the directory is never a
# cwd and deliberately remains empty after every outcome.

ROLE_KEY = "R18_PROCESS_GENERATION_CANARY_ROLE"
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
    "\"status\":\"R18_PROCESS_GENERATION_CANARY_FAILED\"}\n")
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

SCRIPT_PATH = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging/docs/tools/prime-driver-v2-r18-process-generation-canary.rb"
RUBY_IMAGE = "/usr/bin/ruby"
EXPECTED_CWD = "/Users/ergentics/Documents/Codex/2026-08-09/resume-latin-roadmap-pr45/.phase-a-v2-fixture-identity-restore-only-staging"
MARKER_PARENT_PATH = "/private/tmp"
MARKER_LEAF = "gate-e1-4-r18-process-generation-canary-d27a846b-befc6324-b501ad0d7ab1b6c5"
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
PARENT_COMMAND_FD = 8
WORKER_EVENT_FD = 9
FRAME_CAPACITY = 256
RECEIPT_CAPACITY = 32_768
HELPER_TIMEOUT_SECONDS = 20.0
CONTROLLER_TIMEOUT_SECONDS = 30.0
CONSERVATION_TIMEOUT_SECONDS = 30.0
PARENT_NO_WORKER_FAILURE_EXIT = 70
PARENT_WORKER_REAPED_FAILURE_EXIT = 71
MODEL_VERSION = "r18-generation-domain-model-v1"
XNU_ABI_SOURCE = "apple-oss-distributions/xnu@xnu-12377.1.9/bsd/sys/proc_info_private.h"

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
        @buffer = @buffer.byteslice(newline + 1, @buffer.bytesize - newline - 1) || "".b
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
  fail_r18("command mismatch expected=#{expected} observed=#{observed}") unless observed == expected
  true
end

def write_event(io, event, sequence, extra = {})
  frame = {
    "event" => event,
    "pid" => Process.pid,
    "ppid" => Process.ppid,
    "sequence" => sequence
  }.merge(extra)
  bytes = canonical_json(frame) + "\n"
  fail_r18("event frame exceeds cap") if bytes.bytesize > FRAME_CAPACITY
  write_bytes(io, bytes)
  frame
end

def read_event(reader, event, sequence, allowed_keys, deadline)
  raw = reader.read_line(deadline)
  parsed = JSON.parse(raw)
  fail_r18("event is not an object") unless parsed.is_a?(Hash)
  fail_r18("event frame is not canonical") unless canonical_json(parsed) == raw
  fail_r18("event key set mismatch") unless parsed.keys.sort == allowed_keys.sort
  fail_r18("event mismatch") unless parsed["event"] == event && parsed["sequence"] == sequence
  parsed
rescue JSON::ParserError
  fail_r18("event JSON rejected")
end

BASE_EVENT_KEYS = %w[event pid ppid sequence].freeze
WORKER_FORK_EVENT_KEYS = (BASE_EVENT_KEYS + %w[
  parent_idversion_at_fork
  parent_uniqueid_at_fork
  worker_idversion_at_fork
  worker_pid
  worker_uniqueid_at_fork
]).freeze

def close_ios(ios)
  ios.each do |io|
    io.close if io && !io.closed?
  rescue IOError
    nil
  end
end

def run_exec_worker
  validate_static_runtime!
  fail_r18("post-exec worker inherited marker cwd") if File.realpath(Dir.pwd) == MARKER_PATH
  require_ruby_image_joined(Process.pid, "post-exec worker self-join")
  command_io = IO.new(PARENT_COMMAND_FD, "r")
  event_io = IO.new(WORKER_EVENT_FD, "w")
  event_io.sync = true
  deadline = monotonic_time + HELPER_TIMEOUT_SECONDS
  write_event(event_io, "worker_postexec_ready", 4)
  reader = R18LineReader.new(command_io)
  read_command(reader, "exit_worker", deadline)
  write_event(event_io, "worker_exit_intent", 5)
  event_io.flush
  close_ios([command_io, event_io])
  exit!(0)
rescue StandardError
  exit!(70)
end

def run_preexec_worker(worker_command_read, event_write, gate_read)
  validate_expected_cwd!
  validate_stdin_dev_null!
  deadline = monotonic_time + HELPER_TIMEOUT_SECONDS
  gate_reader = R18LineReader.new(gate_read, 64)
  read_command(gate_reader, "go", deadline)
  close_ios([gate_read])
  write_event(event_write, "worker_preexec_ready", 3)
  command_reader = R18LineReader.new(worker_command_read, 64)
  read_command(command_reader, "exec_worker", deadline)
  fail_r18("pre-exec worker entered marker cwd") if File.realpath(Dir.pwd) == MARKER_PATH

  worker_environment = BASE_ENVIRONMENT.merge(ROLE_KEY => WORKER_ROLE)
  Process.exec(
    worker_environment,
    RUBY_IMAGE,
    "--disable-gems",
    SCRIPT_PATH,
    PARENT_COMMAND_FD => worker_command_read,
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

def run_parent(parent_command_read, worker_command_read, event_write, gate_read, gate_write,
               inherited_controller_ios)
  close_ios(inherited_controller_ios)
  validate_expected_cwd!
  validate_stdin_dev_null!
  deadline = monotonic_time + HELPER_TIMEOUT_SECONDS
  event_write.sync = true
  parent_reader = R18LineReader.new(parent_command_read, 64)
  write_event(event_write, "parent_ready", 1)
  read_command(parent_reader, "fork_worker", deadline)
  parent_epoch_at_fork = immediate_unique_epoch(Process.pid, "parent immediately before worker fork")

  worker_pid = Process.fork do
    close_ios([parent_command_read, gate_write])
    run_preexec_worker(worker_command_read, event_write, gate_read)
  end

  worker_epoch_at_fork = immediate_unique_epoch(worker_pid, "worker immediately after fork")
  close_ios([worker_command_read, gate_read])
  write_event(
    event_write,
    "worker_forked",
    2,
    "worker_pid" => worker_pid,
    "parent_uniqueid_at_fork" => parent_epoch_at_fork["uniqueid"],
    "parent_idversion_at_fork" => parent_epoch_at_fork["idversion"],
    "worker_uniqueid_at_fork" => worker_epoch_at_fork["uniqueid"],
    "worker_idversion_at_fork" => worker_epoch_at_fork["idversion"]
  )
  write_command(gate_write, "go")
  close_ios([gate_write, event_write])
  read_command(parent_reader, "exit_parent", deadline)
  close_ios([parent_command_read])
  exit!(0)
rescue StandardError
  close_ios([parent_command_read, worker_command_read, event_write, gate_read, gate_write])
  if defined?(worker_pid) && worker_pid
    begin
      wait_exact_child_blocking(worker_pid)
    rescue StandardError
      loop { sleep(60.0) }
    end
    exit!(PARENT_WORKER_REAPED_FAILURE_EXIT)
  end
  exit!(PARENT_NO_WORKER_FAILURE_EXIT)
end

def wait_exact_child(pid, deadline)
  loop do
    pair = Process.waitpid2(pid, Process::WNOHANG)
    if pair
      status = pair.last
      return {
        "pid" => pid,
        "exited" => status.exited?,
        "exit_status" => status.exited? ? status.exitstatus : nil,
        "signaled" => status.signaled?,
        "term_signal" => status.signaled? ? status.termsig : nil
      }
    end
    fail_r18("exact child reap timed out") unless monotonic_time < deadline
    sleep(0.002)
  end
rescue Errno::ECHILD
  fail_r18("exact child ownership lost")
end

def wait_exact_child_blocking(pid)
  pair = begin
    Process.waitpid2(pid)
  rescue Errno::EINTR
    retry
  end
  status = pair.last
  {
    "pid" => pid,
    "exited" => status.exited?,
    "exit_status" => status.exited? ? status.exitstatus : nil,
    "signaled" => status.signaled?,
    "term_signal" => status.signaled? ? status.termsig : nil
  }
rescue Errno::ECHILD
  fail_r18("exact child ownership lost")
end

def wait_for_reparent(worker_pid, worker_uniqueid, parent_pid, deadline)
  loop do
    joined = join_process(worker_pid)
    fail_r18("worker vanished before reparent proof") unless joined["kind"] == "joined"
    fail_r18("worker generation changed before reparent proof") unless
      joined.dig("unique", "uniqueid") == worker_uniqueid
    return joined if joined.dig("short", "ppid") != parent_pid
    fail_r18("worker reparent timed out") unless monotonic_time < deadline
    sleep(0.002)
  end
end

def wait_for_generation_absence(pid, uniqueid, deadline = nil)
  loop do
    kind, current = read_unique(pid)
    if kind == "gone"
      return { "pid" => pid, "generation" => uniqueid, "observation" => "ESRCH" }
    end
    if current["uniqueid"] != uniqueid
      fail_r18(
        "PID #{pid} rebound before exact ESRCH absence: " \
        "expected_uniqueid=#{uniqueid} observed_uniqueid=#{current["uniqueid"]}"
      )
    end
    fail_r18("worker generation absence timed out") if deadline && monotonic_time >= deadline
    sleep(0.002)
  end
end

def wait_for_generation_absence_without_abandon(pid, uniqueid)
  fault_count = 0
  last_fault = nil
  loop do
    begin
      result = wait_for_generation_absence(pid, uniqueid)
      return result.merge(
        "non_abandoning_fault_count" => fault_count,
        "last_non_abandoning_fault" => last_fault
      )
    rescue StandardError => error
      fault_count += 1
      last_fault = error.message
      sleep(0.01)
    end
  end
end

def assert_same_worker_lifetime!(before_exec, after_exec)
  before_unique = before_exec.fetch("unique")
  after_unique = after_exec.fetch("unique")
  %w[uuid_hex uniqueid puniqueid orig_ppidversion reserve2 reserve3].each do |field|
    fail_r18("worker lifetime field changed across exec: #{field}") unless
      before_unique[field] == after_unique[field]
  end
  fail_r18("worker idversion did not change across exec") if
    before_unique["idversion"] == after_unique["idversion"]
  %w[pid pgid comm_hex uid gid ruid rgid svuid svgid rfu].each do |field|
    fail_r18("worker short-BSD field changed across exec: #{field}") unless
      before_exec.dig("short", field) == after_exec.dig("short", field)
  end
  fail_r18("worker SID changed across exec") unless before_exec["sid"] == after_exec["sid"]
  true
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

def validate_event_pid!(event, pid, expected_ppid = nil)
  fail_r18("event pid mismatch") unless event["pid"] == pid
  fail_r18("event ppid mismatch") if expected_ppid && event["ppid"] != expected_ppid
end

def controller_main
  started_wall = Time.now.utc.iso8601(6)
  started_monotonic = monotonic_time
  initial_cwd = File.realpath(Dir.pwd)
  fail_r18("marker root may not be controller cwd") if initial_cwd == MARKER_PATH
  runtime = validate_static_runtime!
  model = run_model_cases
  marker_state = create_marker_once!
  abi_probe = pid1_abi_probe
  controller_join = require_ruby_image_joined(Process.pid, "controller")
  controller_generation = controller_join.dig("unique", "uniqueid")
  pre_sweeps = [
    perform_ruid_sweep("pre_1", controller_generation),
    perform_ruid_sweep("pre_2", controller_generation)
  ]
  revalidate_marker!(marker_state)

  parent_command_read, parent_command_write = IO.pipe
  worker_command_read, worker_command_write = IO.pipe
  event_read, event_write = IO.pipe
  gate_read, gate_write = IO.pipe
  [parent_command_read, parent_command_write, worker_command_read, worker_command_write,
   event_read, event_write, gate_read, gate_write].each { |io| io.close_on_exec = true }
  event_reader = R18LineReader.new(event_read)
  transcript = []
  deadline = monotonic_time + CONTROLLER_TIMEOUT_SECONDS

  controller_epoch_at_parent_fork = immediate_unique_epoch(
    Process.pid,
    "controller immediately before parent fork"
  )
  parent_pid = Process.fork do
    close_ios([parent_command_write, worker_command_write, event_read])
    run_parent(
      parent_command_read,
      worker_command_read,
      event_write,
      gate_read,
      gate_write,
      [marker_state["parent_io"], marker_state["marker_io"]]
    )
  end

  close_ios([parent_command_read, worker_command_read, event_write, gate_read, gate_write])
  parent_ready = read_event(event_reader, "parent_ready", 1, BASE_EVENT_KEYS, deadline)
  transcript << parent_ready
  validate_event_pid!(parent_ready, parent_pid, Process.pid)
  parent_join = require_ruby_image_joined(parent_pid, "forked parent")
  fail_r18("parent unique parent mismatch") unless
    parent_join.dig("unique", "puniqueid") == controller_epoch_at_parent_fork["uniqueid"]
  fail_r18("parent orig_ppidversion mismatch") unless
    parent_join.dig("unique", "orig_ppidversion") == controller_epoch_at_parent_fork["idversion"]
  fail_r18("parent short-BSD parent mismatch") unless parent_join.dig("short", "ppid") == Process.pid

  fork_worker_committed = true
  write_command(parent_command_write, "fork_worker")
  worker_forked = read_event(event_reader, "worker_forked", 2, WORKER_FORK_EVENT_KEYS, deadline)
  transcript << worker_forked
  worker_pid = worker_forked["worker_pid"]
  worker_uniqueid = worker_forked["worker_uniqueid_at_fork"]
  fail_r18("worker PID invalid") unless worker_pid.is_a?(Integer) && worker_pid > 1
  fail_r18("worker fork generation invalid") unless
    worker_uniqueid.is_a?(Integer) && worker_uniqueid.positive?
  validate_event_pid!(worker_forked, parent_pid, Process.pid)
  fail_r18("parent fork epoch uniqueid changed") unless
    worker_forked["parent_uniqueid_at_fork"] == parent_join.dig("unique", "uniqueid")
  fail_r18("parent fork epoch idversion changed") unless
    worker_forked["parent_idversion_at_fork"] == parent_join.dig("unique", "idversion")
  worker_pre_event = read_event(event_reader, "worker_preexec_ready", 3, BASE_EVENT_KEYS, deadline)
  transcript << worker_pre_event
  validate_event_pid!(worker_pre_event, worker_pid, parent_pid)
  worker_pre = require_ruby_image_joined(worker_pid, "worker before exec")
  fail_r18("worker fork uniqueid changed before exec") unless
    worker_pre.dig("unique", "uniqueid") == worker_uniqueid
  fail_r18("worker fork idversion changed before exec") unless
    worker_pre.dig("unique", "idversion") == worker_forked["worker_idversion_at_fork"]
  fail_r18("worker unique parent mismatch") unless
    worker_pre.dig("unique", "puniqueid") == worker_forked["parent_uniqueid_at_fork"]
  fail_r18("worker orig_ppidversion mismatch") unless
    worker_pre.dig("unique", "orig_ppidversion") == worker_forked["parent_idversion_at_fork"]
  fail_r18("worker short-BSD parent mismatch") unless worker_pre.dig("short", "ppid") == parent_pid

  write_command(worker_command_write, "exec_worker")
  worker_post_event = read_event(event_reader, "worker_postexec_ready", 4, BASE_EVENT_KEYS, deadline)
  transcript << worker_post_event
  validate_event_pid!(worker_post_event, worker_pid, parent_pid)
  worker_post = require_ruby_image_joined(worker_pid, "worker after exec")
  assert_same_worker_lifetime!(worker_pre, worker_post)
  fail_r18("worker parent epoch changed across exec") unless
    worker_post.dig("unique", "orig_ppidversion") == worker_forked["parent_idversion_at_fork"]

  write_command(parent_command_write, "exit_parent")
  close_ios([parent_command_write])
  parent_reap = wait_exact_child(parent_pid, deadline)
  parent_pid = nil
  fail_r18("parent did not exit naturally with status zero") unless
    parent_reap["exited"] && parent_reap["exit_status"] == 0 && !parent_reap["signaled"]

  worker_reparented = wait_for_reparent(
    worker_pid,
    worker_pre.dig("unique", "uniqueid"),
    parent_reap["pid"],
    deadline
  )
  fail_r18("worker lifetime changed during reparent") unless
    worker_reparented.dig("unique", "uniqueid") == worker_post.dig("unique", "uniqueid") &&
      worker_reparented.dig("unique", "puniqueid") == worker_post.dig("unique", "puniqueid") &&
      worker_reparented.dig("unique", "orig_ppidversion") == worker_post.dig("unique", "orig_ppidversion") &&
      worker_reparented.dig("unique", "idversion") == worker_post.dig("unique", "idversion")
  fail_r18("worker process domain changed during reparent") unless
    worker_reparented["sid"] == worker_post["sid"] && worker_reparented["pgid"] == worker_post["pgid"]

  write_command(worker_command_write, "exit_worker")
  close_ios([worker_command_write])
  worker_exit_event = read_event(event_reader, "worker_exit_intent", 5, BASE_EVENT_KEYS, deadline)
  transcript << worker_exit_event
  validate_event_pid!(worker_exit_event, worker_pid, worker_reparented.dig("short", "ppid"))

  conservation_deadline = monotonic_time + CONSERVATION_TIMEOUT_SECONDS
  absence_1 = wait_for_generation_absence(
    worker_pid,
    worker_pre.dig("unique", "uniqueid"),
    conservation_deadline
  )
  post_sweep_1 = perform_ruid_sweep("post_1", controller_generation)
  sleep(0.005)
  absence_2 = wait_for_generation_absence(
    worker_pid,
    worker_pre.dig("unique", "uniqueid"),
    conservation_deadline
  )
  post_sweep_2 = perform_ruid_sweep("post_2", controller_generation)
  event_reader.require_clean_eof(conservation_deadline)
  close_ios([event_read])

  revalidate_marker!(marker_state)
  final_cwd = File.realpath(Dir.pwd)
  fail_r18("cwd changed") unless final_cwd == initial_cwd

  payload = {
    "schema" => "prime-driver-v2-r18-process-generation-canary/v1",
    "status" => "R18_PROCESS_GENERATION_CANARY_PASS",
    "predecessor_commit" => "d27a846b91fd2b7a1397f93ce8c67a100601f889",
    "started_at" => started_wall,
    "duration_milliseconds" => ((monotonic_time - started_monotonic) * 1_000).round(3),
    "runtime" => runtime,
    "abi" => {
      "xnu_family" => "12377",
      "published_private_header_pin" => XNU_ABI_SOURCE,
      "flavor_17" => {
        "size" => UNIQUE_INFO_SIZE,
        "uuid_offset" => 0,
        "uniqueid_offset" => 16,
        "puniqueid_offset" => 24,
        "idversion_offset" => 32,
        "orig_ppidversion_offset" => 36,
        "reserve2_offset" => 40,
        "reserve3_offset" => 48
      },
      "short_bsd" => {
        "size" => SHORT_BSD_SIZE,
        "pid_offset" => 0,
        "ppid_offset" => 4,
        "pgid_offset" => 8,
        "status_offset" => 12,
        "comm_offset" => 16,
        "flags_offset" => 32,
        "credentials_offsets" => [36, 40, 44, 48, 52, 56],
        "rfu_offset" => 60
      },
      "read_policy" => {
        "successful_call_errno" => "ignored_and_not_recorded",
        "failed_call_errno" => "interpreted",
        "join_attempts" => JOIN_ATTEMPTS,
        "later_stable_retry" => "accepted",
        "exact_esrch_after_partial_join" => "gone_with_generation_tombstone",
        "terminal_unknown" => "hard_fail",
        "absence_proof" => "two_exact_ESRCH_observations"
      }
    },
    "pid1_probe" => abi_probe,
    "marker" => marker_state["receipt"],
    "cwd" => {
      "initial" => initial_cwd,
      "final" => final_cwd,
      "unchanged" => true,
      "marker_used_as_cwd" => false
    },
    "ruid_sweeps" => pre_sweeps + [post_sweep_1, post_sweep_2],
    "lineage" => {
      "controller" => public_join(controller_join),
      "controller_epoch_at_parent_fork" => controller_epoch_at_parent_fork,
      "parent" => public_join(parent_join),
      "parent_epoch_at_worker_fork" => {
        "uniqueid" => worker_forked["parent_uniqueid_at_fork"],
        "idversion" => worker_forked["parent_idversion_at_fork"]
      },
      "worker_preexec" => public_join(worker_pre),
      "worker_postexec" => public_join(worker_post),
      "worker_reparented" => public_join(worker_reparented),
      "parent_exact_reap" => parent_reap,
      "worker_exact_reap" => false,
      "worker_generation_absence" => [absence_1, absence_2]
    },
    "protocol" => {
      "controller_parent_worker_one_script" => true,
      "event_count" => transcript.length,
      "events" => transcript.map { |event| event["event"] },
      "transcript_sha256" => Digest::SHA256.hexdigest(canonical_json(transcript)),
      "worker_command_fd" => PARENT_COMMAND_FD,
      "worker_event_fd" => WORKER_EVENT_FD,
      "event_frame_cap_bytes" => FRAME_CAPACITY,
      "ruby_argv_empty_in_each_role" => true,
      "role_values" => [CONTROLLER_ROLE, WORKER_ROLE]
    },
    "operations" => {
      "fork_calls" => 2,
      "exec_calls" => 1,
      "spawn_calls" => 0,
      "shell_calls" => 0,
      "external_signal_calls" => 0,
      "observed_parent_fork_join" => true,
      "observed_worker_fork_join" => true,
      "observed_worker_exec_idversion_change" => true,
      "timeout_authority" => "liveness_only_never_abandonment",
      "failure_terminal_requires_blocking_conservation" => true,
      "parent_failure_exit_without_worker" => PARENT_NO_WORKER_FAILURE_EXIT,
      "parent_failure_exit_after_exact_worker_reap" => PARENT_WORKER_REAPED_FAILURE_EXIT,
      "parent_natural_exit" => true,
      "worker_natural_exit" => true
    },
    "pure_model" => model,
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
    defined?(parent_command_write) ? parent_command_write : nil,
    defined?(worker_command_write) ? worker_command_write : nil
  ])

  parent_conservation = defined?(parent_reap) ? parent_reap : nil
  if defined?(parent_pid) && parent_pid
    begin
      parent_conservation = wait_exact_child_blocking(parent_pid)
      parent_pid = nil
    rescue StandardError => conservation_error
      parent_conservation = { "status" => "UNKNOWN", "error" => conservation_error.message }
    end
  end
  worker_conservation = nil
  conserved_worker_uniqueid = if defined?(worker_pre) && worker_pre
                                worker_pre.dig("unique", "uniqueid")
                              elsif defined?(worker_uniqueid) && worker_uniqueid
                                worker_uniqueid
                              end
  if defined?(worker_pid) && worker_pid && conserved_worker_uniqueid
    begin
      absence_first = wait_for_generation_absence_without_abandon(
        worker_pid,
        conserved_worker_uniqueid
      )
      absence_second = wait_for_generation_absence_without_abandon(
        worker_pid,
        conserved_worker_uniqueid
      )
      worker_conservation = [absence_first, absence_second]
    rescue StandardError => conservation_error
      worker_conservation = { "status" => "UNKNOWN", "error" => conservation_error.message }
    end
  elsif defined?(fork_worker_committed) && fork_worker_committed &&
        parent_conservation.is_a?(Hash) && parent_conservation["exited"] &&
        !parent_conservation["signaled"]
    if parent_conservation["exit_status"] == PARENT_WORKER_REAPED_FAILURE_EXIT
      worker_conservation = {
        "status" => "conserved_by_parent_exact_worker_reap",
        "worker_generation_observed_by_controller" => false
      }
    elsif parent_conservation["exit_status"] == PARENT_NO_WORKER_FAILURE_EXIT
      worker_conservation = {
        "status" => "parent_certified_no_worker_created",
        "worker_generation_observed_by_controller" => false
      }
    end
  end

  parent_conserved = if defined?(parent_pid) && parent_pid
                       false
                     elsif parent_conservation.nil?
                       true
                     else
                       parent_conservation.is_a?(Hash) && parent_conservation.key?("pid") &&
                         (parent_conservation["exited"] || parent_conservation["signaled"])
                     end
  worker_conserved = if !defined?(fork_worker_committed) || !fork_worker_committed
                       true
                     elsif worker_conservation.is_a?(Array)
                       worker_conservation.length == 2 && worker_conservation.all? do |entry|
                         entry["observation"] == "ESRCH" &&
                           entry["generation"] == conserved_worker_uniqueid
                       end
                     else
                       worker_conservation.is_a?(Hash) &&
                         [
                           "conserved_by_parent_exact_worker_reap",
                           "parent_certified_no_worker_created"
                         ].include?(worker_conservation["status"])
                     end
  unless parent_conserved && worker_conserved
    loop { sleep(60.0) }
  end

  close_ios([defined?(event_read) ? event_read : nil])

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
      marker_observation = { "path" => MARKER_PATH, "status" => "UNKNOWN", "error" => marker_error.message }
    end
  end

  failure_payload = {
    "schema" => "prime-driver-v2-r18-process-generation-canary/v1",
    "status" => "R18_PROCESS_GENERATION_CANARY_FAILED",
    "predecessor_commit" => "d27a846b91fd2b7a1397f93ce8c67a100601f889",
    "error_class" => error.class.name,
    "error" => error.message,
    "marker" => marker_observation,
    "parent_conservation" => parent_conservation,
    "worker_conservation" => worker_conservation,
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
