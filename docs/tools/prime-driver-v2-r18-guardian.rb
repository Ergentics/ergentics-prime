#!/usr/bin/ruby

BOOTSTRAP_ENV = {
  "LANG" => "C.UTF-8",
  "LC_ALL" => "C.UTF-8",
  "TZ" => "UTC",
  "PATH" => "/usr/bin:/bin",
  "__CF_USER_TEXT_ENCODING" => "0x1F5:0x0:0x0",
}.freeze

unless ARGV.empty? && ENV.to_h == BOOTSTRAP_ENV
  STDERR.write("{\"status\":\"failed\",\"error\":\"unexpected-bootstrap\"}\n")
  exit 70
end

require "digest"
require "fiddle/import"
require "json"
require "set"

# This is safety-only Workstation instrumentation. It launches one frozen
# Swift command and may contain that command's private process domain. It does
# not interpret test data, close an authority bit, or promote Gate E.
EPOCH =
  "/private/tmp/gate-e1-4-mechanics-r18-befc6324-b501ad0d7ab1b6c5"
SOURCE =
  "/Users/ergentics/Documents/Codex/2026-08-09/" \
  "resume-latin-roadmap-pr45/.driver-v2-gate-c-staging"
PACKAGE = "#{SOURCE}/Tests/PrimeValidationWorkflow"
BUILD = "#{PACKAGE}/.build"
FIXTURE =
  "#{BUILD}/arm64-apple-macosx/release/" \
  "PrimeValidationWorkflowDriverV2SessionFixture"
TEST_RUNNER =
  "#{BUILD}/arm64-apple-macosx/release/" \
  "PrimeValidationWorkflowPackageTests.xctest/Contents/MacOS/" \
  "PrimeValidationWorkflowPackageTests"
TERMINAL_LEAF = "r18-guardian-terminal.json"
TERMINAL = "#{EPOCH}/#{TERMINAL_LEAF}"
TERMINAL_STAGING_TEMPLATE = "r18-guardian-terminal.XXXXXX.staging"
TERMINAL_STAGING_SUFFIX_LENGTH = 8
TERMINAL_STAGING_LEAF =
  /\Ar18-guardian-terminal\.[A-Za-z0-9]{6}\.staging\z/
TERMINAL_MAX_BYTES = 16_384
ERROR_PREFIX_BYTES = 128
PRIVATE_TMP = "/private/tmp"
ADMISSION_PREFIX = "prime-validation-admission-tests-"
ADMISSION_LEAF = /\Aprime-validation-admission-tests-[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/
ADMISSION_BASELINE_COUNT = 16
ADMISSION_BASELINE_SHA256 =
  "6185ea35d684b2a50529aa79f1455bae789eda056e298f5509e7c5127423abd5"
EPOCH_CHILDREN = %w[
  home config tmp git-template swiftpm-cache swiftpm-config
  swiftpm-security clang-module-cache swiftpm-module-cache
].freeze

SWIFT_ENV = {
  "HOME" => "#{EPOCH}/home",
  "CFFIXED_USER_HOME" => "#{EPOCH}/home",
  "XDG_CONFIG_HOME" => "#{EPOCH}/config",
  "TMPDIR" => "#{EPOCH}/tmp/",
  "USER" => "ergentics",
  "LOGNAME" => "ergentics",
  "LANG" => "C.UTF-8",
  "LC_ALL" => "C.UTF-8",
  "TZ" => "UTC",
  "TERM" => "dumb",
  "NO_COLOR" => "1",
  "PATH" =>
    "/Applications/Xcode.app/Contents/Developer/usr/bin:" \
    "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
    "XcodeDefault.xctoolchain/usr/bin:/usr/bin:/bin",
  "DEVELOPER_DIR" => "/Applications/Xcode.app/Contents/Developer",
  "SDKROOT" =>
    "/Applications/Xcode.app/Contents/Developer/Platforms/" \
    "MacOSX.platform/Developer/SDKs/MacOSX.sdk",
  "GIT_EXEC_PATH" =>
    "/Applications/Xcode.app/Contents/Developer/usr/libexec/git-core",
  "GIT_CONFIG_NOSYSTEM" => "1",
  "GIT_CONFIG_GLOBAL" => "/dev/null",
  "GIT_ATTR_NOSYSTEM" => "1",
  "GIT_CONFIG_COUNT" => "6",
  "GIT_CONFIG_KEY_0" => "core.hooksPath",
  "GIT_CONFIG_VALUE_0" => "#{EPOCH}/git-template",
  "GIT_CONFIG_KEY_1" => "init.templateDir",
  "GIT_CONFIG_VALUE_1" => "#{EPOCH}/git-template",
  "GIT_CONFIG_KEY_2" => "core.attributesFile",
  "GIT_CONFIG_VALUE_2" => "/dev/null",
  "GIT_CONFIG_KEY_3" => "checkout.workers",
  "GIT_CONFIG_VALUE_3" => "1",
  "GIT_CONFIG_KEY_4" => "maintenance.auto",
  "GIT_CONFIG_VALUE_4" => "false",
  "GIT_CONFIG_KEY_5" => "gc.auto",
  "GIT_CONFIG_VALUE_5" => "0",
  "GIT_ALLOW_PROTOCOL" => "file",
  "GIT_PROTOCOL_FROM_USER" => "0",
  "GIT_OPTIONAL_LOCKS" => "0",
  "GIT_TERMINAL_PROMPT" => "0",
  "GIT_LFS_SKIP_SMUDGE" => "1",
  "GIT_NO_LAZY_FETCH" => "1",
  "GIT_NO_REPLACE_OBJECTS" => "1",
  "CLANG_MODULE_CACHE_PATH" => "#{EPOCH}/clang-module-cache",
  "SWIFTPM_MODULECACHE_OVERRIDE" => "#{EPOCH}/swiftpm-module-cache",
}.freeze

SWIFT_ARGV = [
  "/Applications/Xcode.app/Contents/Developer/Toolchains/" \
    "XcodeDefault.xctoolchain/usr/bin/swift",
  "test",
  "--package-path", PACKAGE,
  "--configuration", "release",
  "--scratch-path", BUILD,
  "--cache-path", "#{EPOCH}/swiftpm-cache",
  "--config-path", "#{EPOCH}/swiftpm-config",
  "--security-path", "#{EPOCH}/swiftpm-security",
  "--disable-netrc", "--disable-keychain", "--force-resolved-versions",
  "--disable-automatic-resolution", "--disable-sandbox",
  "--disable-swift-testing",
  "--filter",
  "^PrimeValidationWorkflowDriverCoreTests\\." \
    "PrimeValidationSwiftPMBuildInventoryAdmissionLiveTests/" \
    "testGateEJournalChainOneWinnerAndPoisonAreExact$",
].freeze

raise "swift-env-cardinality" unless SWIFT_ENV.length == 40

EXPECTED_UID = 501
EXPECTED_GID = 20
EXPECTED_GROUPS = [
  12, 20, 33, 61, 79, 80, 81, 98, 100, 204, 250, 395, 398, 399, 400, 701,
].freeze
SOURCE_IDENTITY = [16_777_231, 17_154_421].freeze
FIXTURE_IDENTITY = [16_777_231, 17_382_060].freeze
FIXTURE_BYTES = 53_072
FIXTURE_TIMES = [1_787_500_441, 1_787_500_441].freeze
FIXTURE_SHA256 =
  "177a18c20bc42486c77b52af4c472be222dec1baabf8973ece7b2d44ea92756e"
CHILD_NANOSECONDS = 840_000_000_000
HARD_NANOSECONDS = 900_000_000_000
TRACK_INTERVAL = 0.05
PID_CAPACITY = 131_072
CAPTURED_LIFETIME_CAP = 4_096
PROOF_GROUP_CAP = 32
SIGNAL_CALL_CAP = PROOF_GROUP_CAP * 2
WORKSPACE_ROOT_CAP = 64
FULL_BSD_SIZE = 136
SHORT_BSD_SIZE = 64
UNIQUE_INFO_SIZE = 56
JOIN_ATTEMPTS = 4
JOIN_RETRY_SECONDS = 0.001
REGION_SIZE = 1_272
VNODE_PATHS_SIZE = 2_352
PATH_SIZE = 4_096
PROC_ALL_PIDS = 1
PROC_PGRP_ONLY = 2
PROC_RUID_ONLY = 5
PROC_PIDTBSDINFO = 3
PROC_PIDT_SHORTBSDINFO = 13
PROC_PIDUNIQIDENTIFIERINFO = 17
PROC_PIDREGIONPATHINFO = 8
PROC_PIDVNODEPATHINFO = 9
VM_PROT_EXECUTE = 4
ERRNO_EPERM = 1
ERRNO_ESRCH = 3
O_RDONLY = 0
O_CLOEXEC = 0x01000000
O_NOFOLLOW_ANY = 0x20000000
O_DIRECTORY = 0x00100000
RENAME_EXCL = 0x00000004
RENAME_NOFOLLOW_ANY = 0x00000010
F_FULLFSYNC = 51
CERTIFICATE_MAX_AGE_NS = 50_000_000
SIGNALS = %w[HUP INT QUIT TERM].freeze
XNU_ABI_SOURCE =
  "apple-oss-distributions/xnu@xnu-12377.1.9/bsd/sys/proc_info_private.h"
EXPECTED_SYSCTLS = {
  "kern.osproductversion" => "26.5.2",
  "kern.osversion" => "25F84",
  "kern.osrelease" => "25.5.0",
  "kern.version" =>
    "Darwin Kernel Version 25.5.0: Tue Jun  9 22:28:34 PDT 2026; " \
      "root:xnu-12377.121.10~1/RELEASE_ARM64_T6050",
  "hw.machine" => "arm64",
}.freeze

module DarwinProcess
  extend Fiddle::Importer
  dlload Fiddle.dlopen(nil)
  extern "int proc_listpids(unsigned int, unsigned int, void*, int)"
  extern "int proc_pidinfo(int, int, unsigned long long, void*, int)"
  extern "int proc_pidpath(int, void*, unsigned int)"
  extern "int getsid(int)"
  extern "int getpgid(int)"
  extern "int kill(int, int)"
  extern "int mkostempsat_np(int, char*, int, int)"
  extern "int fchmod(int, unsigned int)"
  extern "int renameatx_np(int, const char*, int, const char*, unsigned int)"
  extern "int fcntl(int, int)"
  extern "int sysctlbyname(const char*, void*, void*, void*, unsigned long)"
end

class GuardianDeadline < StandardError; end
class TerminalPostcommitFailure < StandardError; end

def monotonic
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
end

def canonical_value(value)
  case value
  when Hash
    value.keys.sort.each_with_object({}) do |key, result|
      result[key] = canonical_value(value.fetch(key))
    end
  when Array
    value.map { |entry| canonical_value(entry) }
  else
    value
  end
end

def canonical_json(value)
  JSON.generate(canonical_value(value))
end

def error_receipt(error)
  bytes = error.class.name.to_s.b + ":".b + error.message.to_s.b
  {
    "bytes" => bytes.bytesize,
    "prefix_hex" => bytes.byteslice(0, ERROR_PREFIX_BYTES).unpack1("H*"),
    "sha256" => Digest::SHA256.hexdigest(bytes),
  }
end

def checked_sysctl_string(name)
  buffer = "\0" * 4_096
  length_storage = [buffer.bytesize].pack("J")
  Fiddle.last_error = 0
  result = DarwinProcess.sysctlbyname(
    name, buffer, length_storage, nil, 0
  )
  error = Fiddle.last_error
  raise "sysctl-#{name}-#{error}" unless result == 0
  length = length_storage.unpack1("J")
  raise "sysctl-frame-#{name}" unless length.between?(1, buffer.bytesize)
  value = buffer.byteslice(0, length)
  value = value.byteslice(0, value.bytesize - 1) if value.end_with?("\0")
  value.force_encoding(Encoding::UTF_8)
  raise "sysctl-encoding-#{name}" unless value.valid_encoding?
  value
end

def require_time(deadline, coordinate)
  return if deadline.nil?
  raise GuardianDeadline, coordinate unless monotonic < deadline
end

def u32(bytes, offset)
  bytes.byteslice(offset, 4).unpack1("L<")
end

def u64(bytes, offset)
  bytes.byteslice(offset, 8).unpack1("Q<")
end

def lifetime_key(member)
  [member.fetch("pid"), member.dig("unique", "uniqueid")]
end

def epoch_key(member)
  [member.dig("unique", "uniqueid"), member.dig("unique", "idversion")]
end

def parent_epoch_key(member)
  [member.dig("unique", "puniqueid"),
   member.dig("unique", "orig_ppidversion")]
end

def open_held(path, directory: false)
  flags = O_RDONLY | O_CLOEXEC | O_NOFOLLOW_ANY
  flags |= O_DIRECTORY if directory
  io = IO.new(IO.sysopen(path, flags))
  raise "descriptor-cloexec:#{path}" unless io.close_on_exec?
  io
end

def rejoin(path, io, directory: false)
  named = File.lstat(path)
  held = io.stat
  expected_type = directory ? named.directory? : named.file?
  raise "named-type:#{path}" unless expected_type
  raise "named-rebound:#{path}" unless [named.dev, named.ino] == [held.dev, held.ino]
  held
end

def held_sha256(io)
  digest = Digest::SHA256.new
  io.seek(0)
  chunk = nil
  digest.update(chunk) while (chunk = io.read(65_536))
  io.seek(0)
  digest.hexdigest
end

def verify_fixture(io)
  stat = rejoin(FIXTURE, io)
  expected = [
    *FIXTURE_IDENTITY, EXPECTED_UID, 20, 0o700, 1, FIXTURE_BYTES,
    *FIXTURE_TIMES,
  ]
  observed = [
    stat.dev, stat.ino, stat.uid, stat.gid, stat.mode & 0o7777, stat.nlink,
    stat.size, stat.mtime.to_i, stat.ctime.to_i,
  ]
  raise "fixture-preimage" unless observed == expected
  raise "fixture-sha256" unless held_sha256(io) == FIXTURE_SHA256
end

def raw_pidinfo(pid, flavor, size, deadline)
  require_time(deadline, "pidinfo-deadline")
  buffer = "\0" * size
  Fiddle.last_error = 0
  returned = DarwinProcess.proc_pidinfo(
    pid, flavor, 0, buffer, buffer.bytesize
  )
  error = Fiddle.last_error
  require_time(deadline, "pidinfo-deadline")
  [returned, error, buffer]
end

def parse_unique_info(buffer)
  raise "flavor17-frame" unless buffer.bytesize == UNIQUE_INFO_SIZE
  record = {
    "uuid_hex" => buffer.byteslice(0, 16).unpack1("H*"),
    "uniqueid" => buffer.byteslice(16, 8).unpack1("Q<"),
    "puniqueid" => buffer.byteslice(24, 8).unpack1("Q<"),
    "idversion" => buffer.byteslice(32, 4).unpack1("l<"),
    "orig_ppidversion" => buffer.byteslice(36, 4).unpack1("l<"),
    "reserve2" => buffer.byteslice(40, 8).unpack1("Q<"),
    "reserve3" => buffer.byteslice(48, 8).unpack1("Q<"),
  }
  raise "flavor17-zero-lifetime" if record["uniqueid"] == 0
  raise "flavor17-reserved" unless
    record["reserve2"] == 0 && record["reserve3"] == 0
  record
end

def parse_short_bsd(buffer)
  raise "shortbsd-frame" unless buffer.bytesize == SHORT_BSD_SIZE
  record = {
    "pid" => u32(buffer, 0),
    "ppid" => u32(buffer, 4),
    "pgid" => u32(buffer, 8),
    "status" => u32(buffer, 12),
    "comm_hex" => buffer.byteslice(16, 16).unpack1("H*"),
    "flags" => u32(buffer, 32),
    "uid" => u32(buffer, 36),
    "gid" => u32(buffer, 40),
    "ruid" => u32(buffer, 44),
    "rgid" => u32(buffer, 48),
    "svuid" => u32(buffer, 52),
    "svgid" => u32(buffer, 56),
    "rfu" => u32(buffer, 60),
  }
  raise "shortbsd-reserved" unless record["rfu"] == 0
  record
end

def read_unique(pid, deadline)
  returned, error, buffer = raw_pidinfo(
    pid, PROC_PIDUNIQIDENTIFIERINFO, UNIQUE_INFO_SIZE, deadline
  )
  return ["joined", parse_unique_info(buffer)] if returned == UNIQUE_INFO_SIZE
  raise "flavor17-partial-#{pid}-#{returned}" if returned.positive?
  return ["gone", nil] if returned == 0 && error == ERRNO_ESRCH
  raise "flavor17-#{pid}-#{returned}-#{error}"
end

def read_short(pid, deadline)
  returned, error, buffer = raw_pidinfo(
    pid, PROC_PIDT_SHORTBSDINFO, SHORT_BSD_SIZE, deadline
  )
  if returned == SHORT_BSD_SIZE
    record = parse_short_bsd(buffer)
    raise "shortbsd-pid-#{pid}" unless record["pid"] == pid
    return ["joined", record]
  end
  raise "shortbsd-partial-#{pid}-#{returned}" if returned.positive?
  return ["gone", nil] if returned == 0 && error == ERRNO_ESRCH
  raise "shortbsd-#{pid}-#{returned}-#{error}"
end

def read_domain_value(function_name, pid, deadline)
  require_time(deadline, "domain-deadline")
  Fiddle.last_error = 0
  value = function_name == "getsid" ?
    DarwinProcess.getsid(pid) : DarwinProcess.getpgid(pid)
  error = Fiddle.last_error
  require_time(deadline, "domain-deadline")
  return ["joined", value] if value >= 0
  return ["gone", nil] if error == ERRNO_ESRCH
  raise "#{function_name}-#{pid}-#{value}-#{error}"
end

def unique_records_equal?(left, right)
  %w[
    uuid_hex uniqueid puniqueid idversion orig_ppidversion reserve2 reserve3
  ].all? { |field| left[field] == right[field] }
end

def short_identity_stable?(left, right)
  %w[
    pid ppid pgid comm_hex uid gid ruid rgid svuid svgid rfu
  ].all? { |field| left[field] == right[field] }
end

def join_process(pid, deadline)
  observed_epochs = []
  JOIN_ATTEMPTS.times do |attempt|
    u0_kind, u0 = read_unique(pid, deadline)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1} if
      u0_kind == "gone" && observed_epochs.empty?
    if u0_kind == "gone"
      return {
        "kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
        "reason" => "exact_esrch_after_race",
        "tombstone_epochs" => observed_epochs.uniq,
      }
    end
    observed_epochs << [u0["uniqueid"], u0["idversion"]]
    s0_kind, s0 = read_short(pid, deadline)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed_epochs.uniq} if s0_kind == "gone"
    sid0_kind, sid0 = read_domain_value("getsid", pid, deadline)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed_epochs.uniq} if sid0_kind == "gone"
    pgid0_kind, pgid0 = read_domain_value("getpgid", pid, deadline)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed_epochs.uniq} if pgid0_kind == "gone"
    sid1_kind, sid1 = read_domain_value("getsid", pid, deadline)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed_epochs.uniq} if sid1_kind == "gone"
    pgid1_kind, pgid1 = read_domain_value("getpgid", pid, deadline)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed_epochs.uniq} if pgid1_kind == "gone"
    s1_kind, s1 = read_short(pid, deadline)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed_epochs.uniq} if s1_kind == "gone"
    u1_kind, u1 = read_unique(pid, deadline)
    return {"kind" => "gone", "pid" => pid, "attempts" => attempt + 1,
            "tombstone_epochs" => observed_epochs.uniq} if u1_kind == "gone"
    observed_epochs << [u1["uniqueid"], u1["idversion"]]
    stable = unique_records_equal?(u0, u1) &&
      short_identity_stable?(s0, s1) && sid0 == sid1 && pgid0 == pgid1 &&
      pgid0 == s0["pgid"] && pgid1 == s1["pgid"]
    return {
      "kind" => "joined", "pid" => pid, "attempts" => attempt + 1,
      "unique" => u1, "short" => s1, "sid" => sid1, "pgid" => pgid1,
    } if stable
    sleep(JOIN_RETRY_SECONDS) if attempt + 1 < JOIN_ATTEMPTS
  end
  {
    "kind" => "unknown", "pid" => pid, "attempts" => JOIN_ATTEMPTS,
    "reason" => "generation_or_domain_race",
    "observed_epochs" => observed_epochs.uniq,
  }
end

def require_joined(pid, deadline, context)
  joined = join_process(pid, deadline)
  raise "#{context}-#{joined.fetch("kind")}" unless joined["kind"] == "joined"
  joined
end

def expected_credentials?(member)
  %w[uid gid ruid rgid svuid svgid].map do |field|
    member.dig("short", field)
  end == [
    EXPECTED_UID, EXPECTED_GID, EXPECTED_UID, EXPECTED_GID,
    EXPECTED_UID, EXPECTED_GID,
  ]
end

def same_observation_identity?(left, right)
  unique_records_equal?(left.fetch("unique"), right.fetch("unique")) &&
    short_identity_stable?(left.fetch("short"), right.fetch("short")) &&
    left["sid"] == right["sid"] && left["pgid"] == right["pgid"]
end

def process_path(pid, deadline)
  require_time(deadline, "pidpath-deadline")
  bytes = "\0" * PATH_SIZE
  Fiddle.last_error = 0
  returned = DarwinProcess.proc_pidpath(pid, bytes, bytes.bytesize)
  error = Fiddle.last_error
  require_time(deadline, "pidpath-deadline")
  return :gone if returned <= 0 && error == Errno::ESRCH::Errno
  raise "pidpath-#{pid}-#{error}" if returned <= 0
  raise "pidpath-frame-#{pid}" unless returned < bytes.bytesize
  bytes.byteslice(0, returned).split("\0", 2).first
end

def mapped_executable_identity(pid, deadline, expected_path)
  address = 0
  256.times do
    require_time(deadline, "region-deadline")
    bytes = "\0" * REGION_SIZE
    Fiddle.last_error = 0
    returned = DarwinProcess.proc_pidinfo(
      pid, PROC_PIDREGIONPATHINFO, address, bytes, bytes.bytesize
    )
    error = Fiddle.last_error
    require_time(deadline, "region-deadline")
    return :gone if returned <= 0 && error == Errno::ESRCH::Errno
    return false if returned <= 0 && error == 0
    raise "region-#{pid}-#{error}" unless returned == REGION_SIZE
    protection = u32(bytes, 0)
    file_offset = u64(bytes, 16)
    region_address = u64(bytes, 80)
    region_size = u64(bytes, 88)
    device = u32(bytes, 96)
    inode = u64(bytes, 104)
    raise "region-order-#{pid}" if region_address < address || region_size == 0
    following = region_address + region_size
    raise "region-overflow-#{pid}" if following > 0xffff_ffff_ffff_ffff
    if protection & VM_PROT_EXECUTE != 0 && file_offset == 0
      path = bytes.byteslice(248, 1_024).split("\0", 2).first
      return [device, inode] if path == expected_path
    end
    address = following
  end
  raise "region-capacity-#{pid}"
end

def process_cwd(pid, deadline)
  require_time(deadline, "cwd-deadline")
  bytes = "\0" * VNODE_PATHS_SIZE
  Fiddle.last_error = 0
  returned = DarwinProcess.proc_pidinfo(
    pid, PROC_PIDVNODEPATHINFO, 0, bytes, bytes.bytesize
  )
  error = Fiddle.last_error
  require_time(deadline, "cwd-deadline")
  return :gone if returned <= 0 && error == Errno::ESRCH::Errno
  raise "cwd-#{pid}-#{error}" unless returned == VNODE_PATHS_SIZE
  path = bytes.byteslice(152, 1_024).split("\0", 2).first
  raise "cwd-frame-#{pid}" unless path.start_with?("/")
  {
    path: path,
    identity: [u32(bytes, 0), u64(bytes, 8)],
  }
end

def inspect_process_image(joined, deadline, fixture_io)
  pid = joined.fetch("pid")
  path = process_path(pid, deadline)
  return nil if path == :gone
  mapped_identity = nil
  fixture_cwd = nil
  if path == FIXTURE
    mapped_identity = mapped_executable_identity(pid, deadline, FIXTURE)
    return nil if mapped_identity == :gone
    raise "fixture-mapped-image-#{pid}" unless mapped_identity == FIXTURE_IDENTITY
    held = fixture_io.stat
    raise "fixture-held-image-#{pid}" unless
      mapped_identity == [held.dev, held.ino]
    fixture_cwd = process_cwd(pid, deadline)
    return nil if fixture_cwd == :gone
  end
  after = join_process(pid, deadline)
  return nil if after["kind"] == "gone"
  raise "image-observation-unknown-#{pid}" unless after["kind"] == "joined"
  raise "image-observation-race-#{pid}" unless
    same_observation_identity?(joined, after)
  after.merge(
    "path" => path,
    "fixture" => !mapped_identity.nil?,
    "fixture_identity" => mapped_identity,
    "fixture_cwd" => fixture_cwd,
    "test_runner" => path == TEST_RUNNER,
  )
end

def listed_pids(deadline, list_type, type_info, allow_empty: false)
  require_time(deadline, "scan-deadline")
  bytes = "\0" * (PID_CAPACITY * 4)
  Fiddle.last_error = 0
  returned = DarwinProcess.proc_listpids(
    list_type, type_info, bytes, bytes.bytesize
  )
  error = Fiddle.last_error
  require_time(deadline, "scan-deadline")
  # A zero-byte group projection is a successful empty result; errno is
  # undefined after success and must not be transported or interpreted.
  return [] if allow_empty && returned == 0
  raise "pid-list-#{error}" unless returned > 0 &&
    returned < bytes.bytesize && returned % 4 == 0
  pids = bytes.byteslice(0, returned).unpack("L<*").select { |pid| pid > 0 }
  raise "pid-list-duplicate" unless pids.uniq.length == pids.length
  pids.sort
end

def global_session_projection(deadline, guardian_sid)
  listed_pids(deadline, PROC_ALL_PIDS, 0).each_with_object({}) do |pid, result|
    Fiddle.last_error = 0
    require_time(deadline, "global-session-deadline")
    sid = DarwinProcess.getsid(pid)
    sid_error = Fiddle.last_error
    require_time(deadline, "global-session-deadline")
    next if sid < 0 && sid_error == Errno::ESRCH::Errno
    raise "global-getsid-#{pid}-#{sid_error}" if sid < 0
    next unless sid == guardian_sid

    Fiddle.last_error = 0
    pgid = DarwinProcess.getpgid(pid)
    pgid_error = Fiddle.last_error
    require_time(deadline, "global-session-deadline")
    next if pgid < 0 && pgid_error == Errno::ESRCH::Errno
    raise "global-getpgid-#{pid}-#{pgid_error}" unless pgid > 0

    Fiddle.last_error = 0
    second_sid = DarwinProcess.getsid(pid)
    second_sid_error = Fiddle.last_error
    require_time(deadline, "global-session-deadline")
    next if second_sid < 0 && second_sid_error == Errno::ESRCH::Errno
    raise "global-getsid-second-#{pid}-#{second_sid_error}" if second_sid < 0
    next unless second_sid == guardian_sid
    result[pid] = pgid
  end
end

def joined_scan(deadline, list_type:, type_info:, allow_empty: false)
  listed_pids(
    deadline, list_type, type_info, allow_empty: allow_empty
  ).each_with_object([]) do |pid, records|
    joined = join_process(pid, deadline)
    next if joined["kind"] == "gone"
    raise "terminal-unknown-process-#{pid}" unless joined["kind"] == "joined"
    records << joined
  end
end

def pid1_abi_probe(deadline)
  returned, error, = raw_pidinfo(
    1, PROC_PIDTBSDINFO, FULL_BSD_SIZE, deadline
  )
  raise "pid1-fullbsd-control" unless returned == 0 && error == ERRNO_EPERM
  joined = require_joined(1, deadline, "pid1-join")
  {
    "full_bsd" => {"returned" => returned, "errno" => error},
    "uniqueid" => joined.dig("unique", "uniqueid"),
    "idversion" => joined.dig("unique", "idversion"),
    "sid" => joined["sid"],
    "pgid" => joined["pgid"],
  }
end

class WorkspaceRegistry
  attr_reader :baseline, :rebound_seen

  def initialize
    @baseline = current_paths.to_set
    @roots = {}
    @rebound_seen = false
  end

  def current_paths
    Dir.children(PRIVATE_TMP).select do |leaf|
      leaf.start_with?(ADMISSION_PREFIX)
    end
      .map { |leaf| "#{PRIVATE_TMP}/#{leaf}" }.sort
  end

  def preflight_unchanged?
    current_paths.to_set == @baseline
  end

  def update
    novel = current_paths.reject { |path| @baseline.include?(path) }
    raise "workspace-registry-capacity" if novel.length > WORKSPACE_ROOT_CAP
    novel.each do |base|
      raise "workspace-root-leaf" unless ADMISSION_LEAF.match?(File.basename(base))
      entry = @roots[base]
      unless entry
        root_io = open_held(base, directory: true)
        root_stat = rejoin(base, root_io, directory: true)
        raise "workspace-root-security" unless
          [root_stat.uid, root_stat.mode & 0o7777] == [EXPECTED_UID, 0o700]
        entry = {
          root: root_io,
          root_identity: [root_stat.dev, root_stat.ino],
          root_gid: root_stat.gid,
        }
        @roots[base] = entry
      else
        begin
          root_stat = rejoin(base, entry[:root], directory: true)
          raise "workspace-root-metadata" unless
            [root_stat.uid, root_stat.gid, root_stat.mode & 0o7777] ==
              [EXPECTED_UID, entry[:root_gid], 0o700]
        rescue Errno::ENOENT
          @rebound_seen = true
          entry[:invalid] = true
          next
        rescue RuntimeError
          @rebound_seen = true
          entry[:invalid] = true
        end
      end
      next if entry[:invalid]
      next if entry[:workspace]
      workspace = "#{base}/workspace"
      next unless File.exist?(workspace)
      workspace_io = open_held(workspace, directory: true)
      workspace_stat = rejoin(workspace, workspace_io, directory: true)
      raise "workspace-security" unless
        [workspace_stat.uid, workspace_stat.mode & 0o7777] ==
          [EXPECTED_UID, 0o700]
      entry[:workspace] = workspace_io
      entry[:workspace_path] = workspace
      entry[:workspace_identity] = [workspace_stat.dev, workspace_stat.ino]
      entry[:workspace_gid] = workspace_stat.gid
    end
  end

  def admits?(cwd)
    return false unless cwd
    path = cwd[:path]
    base = path.delete_suffix("/workspace")
    return false unless path == "#{base}/workspace"
    leaf = File.basename(base)
    return false unless ADMISSION_LEAF.match?(leaf)
    entry = @roots[base]
    return false unless entry && !entry[:invalid] && entry[:workspace] &&
      entry[:workspace_path] == path &&
      entry[:workspace_identity] == cwd[:identity]
    root = rejoin(base, entry[:root], directory: true)
    held = rejoin(path, entry[:workspace], directory: true)
    [root.uid, root.gid, root.mode & 0o7777] ==
      [EXPECTED_UID, entry[:root_gid], 0o700] &&
      [held.dev, held.ino] == cwd[:identity] &&
      [held.uid, held.gid, held.mode & 0o7777] ==
        [EXPECTED_UID, entry[:workspace_gid], 0o700]
  rescue Errno::ENOENT, RuntimeError
    @rebound_seen = true
    entry[:invalid] = true if entry
    false
  end

  def baseline_sha256
    bytes = @baseline.to_a.sort.join("\n") + "\n"
    Digest::SHA256.hexdigest(bytes)
  end

  def held_workspace_count
    @roots.values.count { |entry| entry[:workspace] }
  end
end

class Tracker
  attr_reader :captured, :proof_groups, :scans, :workspace_registry,
              :current_owned, :baseline_rows, :unknown_count,
              :unexpected_nested_seen,
              :group_sids, :classification_poisoned

  def initialize(fixture_io, guardian_join, workspace_registry)
    @fixture_io = fixture_io
    @guardian_pid = guardian_join.fetch("pid")
    @guardian_sid = guardian_join.fetch("sid")
    @workspace_registry = workspace_registry
    @epoch_classes = {}
    @lifetime_classes = {}
    @captured = {}
    @proof_groups = Set.new
    @group_sids = {}
    @current_owned = []
    @baseline_rows = []
    @scans = 0
    @unknown_count = 0
    @classification_poisoned = false
    @unexpected_nested_seen = false
    @fixture_lifetimes = Set.new
    @test_runner_lifetimes = Set.new
    @armed = false
    assign_class!(guardian_join, "owned")
  end

  def merge_class(existing, candidate)
    return candidate if existing.nil?
    return existing if candidate.nil? || existing == candidate
    "hard_stop"
  end

  def assign_map_class!(map, key, candidate)
    return if key.nil? || (key.respond_to?(:any?) && key.any?(&:nil?))
    merged = merge_class(map[key], candidate)
    raise "owned-ambient-class-collision-#{Array(key).join('-')}" if
      merged == "hard_stop"
    map[key] = merged
  end

  def assign_class!(member, candidate)
    assign_map_class!(@epoch_classes, epoch_key(member), candidate)
    assign_map_class!(
      @lifetime_classes, member.dig("unique", "uniqueid"), candidate
    )
  end

  def comm_string(member)
    [member.dig("short", "comm_hex")].pack("H*").split("\0", 2).first
  end

  def public_identity(member)
    {
      "pid" => member.fetch("pid"),
      "uniqueid" => member.dig("unique", "uniqueid"),
      "idversion" => member.dig("unique", "idversion"),
      "puniqueid" => member.dig("unique", "puniqueid"),
      "orig_ppidversion" => member.dig("unique", "orig_ppidversion"),
      "ppid" => member.dig("short", "ppid"),
      "sid" => member.fetch("sid"),
      "pgid" => member.fetch("pgid"),
      "status" => member.dig("short", "status"),
      "credentials" => %w[uid gid ruid rgid svuid svgid].map do |field|
        member.dig("short", field)
      end,
      "uuid_hex" => member.dig("unique", "uuid_hex"),
    }
  end

  def merged_census(deadline)
    records = joined_scan(
      deadline, list_type: PROC_RUID_ONLY, type_info: EXPECTED_UID
    )
    records.each do |member|
      raise "ruid-selector-drift-#{member.fetch('pid')}" unless
        member.dig("short", "ruid") == EXPECTED_UID
    end
    by_pid = records.to_h { |member| [member.fetch("pid"), member] }
    global_session_projection(deadline, @guardian_sid).each do |pid, pgid|
      prior = by_pid[pid]
      member = join_process(pid, deadline)
      next if member["kind"] == "gone"
      raise "global-session-terminal-unknown-#{pid}" unless
        member["kind"] == "joined"
      raise "global-session-pid-rebound-#{pid}" if prior &&
        prior.dig("unique", "uniqueid") !=
          member.dig("unique", "uniqueid")
      raise "global-session-projection-race-#{pid}" unless
        member["sid"] == @guardian_sid && member["pgid"] == pgid
      records.reject! { |record| record.fetch("pid") == pid }
      records << member
      by_pid[pid] = member
    end
    records.sort_by { |member| member.fetch("pid") }
  end

  def capture_ambient_baseline!(deadline)
    raise "ambient-baseline-after-arm" if @armed
    2.times do |index|
      records = merged_census(deadline)
      guardian = records.find { |member| member.fetch("pid") == @guardian_pid }
      raise "guardian-baseline-missing" unless guardian &&
        @lifetime_classes[guardian.dig("unique", "uniqueid")] == "owned"
      records.each do |member|
        next if member.fetch("pid") == @guardian_pid
        raise "preexisting-guardian-session-#{member.fetch('pid')}" if
          member["sid"] == @guardian_sid
        if comm_string(member).start_with?("PrimeValidation")
          inspected = inspect_process_image(member, deadline, @fixture_io)
          next unless inspected
          raise "preexisting-assessment-process-#{member.fetch('pid')}" if
            inspected["fixture"] || inspected["test_runner"]
          member = inspected
        end
        assign_class!(member, "ambient")
      end
      identities = records.map { |member| public_identity(member) }
      @baseline_rows << {
        "label" => "pre_#{index + 1}",
        "count" => identities.length,
        "rows_sha256" => Digest::SHA256.hexdigest(canonical_json(identities)),
      }
    end
    @baseline_rows
  end

  def candidate_class(member)
    candidates = []
    candidates << @epoch_classes[epoch_key(member)] if
      @epoch_classes.key?(epoch_key(member))
    lifetime = member.dig("unique", "uniqueid")
    candidates << @lifetime_classes[lifetime] if
      @lifetime_classes.key?(lifetime)
    parent = parent_epoch_key(member)
    candidates << @epoch_classes[parent] if
      parent != [0, 0] && @epoch_classes.key?(parent)
    if member["fixture"]
      raise "fixture-workspace-unadmitted-#{member.fetch('pid')}" unless
        @workspace_registry.admits?(member["fixture_cwd"])
      candidates << "owned"
    end
    candidates.compact.reduce(nil) { |memo, item| merge_class(memo, item) } ||
      "unknown"
  end

  def propagate_classes!(records)
    classifications = {}
    (records.length + 2).times do
      changed = false
      records.each do |member|
        key = lifetime_key(member)
        candidate = candidate_class(member)
        raise "owned-ambient-record-collision-#{key.join('-')}" if
          candidate == "hard_stop"
        changed ||= classifications[key] != candidate
        classifications[key] = candidate
        next if candidate == "unknown"
        before_epoch = @epoch_classes[epoch_key(member)]
        before_lifetime = @lifetime_classes[member.dig("unique", "uniqueid")]
        assign_class!(member, candidate)
        changed ||= before_epoch != @epoch_classes[epoch_key(member)] ||
          before_lifetime !=
            @lifetime_classes[member.dig("unique", "uniqueid")]
      end
      break unless changed
    end
    classifications
  end

  def classify_records!(records, deadline)
    classifications = propagate_classes!(records)
    inspected = records.each_with_object([]) do |member, result|
      classification = classifications[lifetime_key(member)]
      needs_image = classification == "owned" ||
        classification == "unknown" ||
        comm_string(member).start_with?("PrimeValidation")
      unless needs_image
        result << member
        next
      end
      observed = inspect_process_image(member, deadline, @fixture_io)
      result << observed if observed
    end
    classifications = propagate_classes!(inspected)
    inspected.each do |member|
      classification = classifications[lifetime_key(member)]
      if classification == "unknown"
        @unknown_count += 1
        raise "terminal-unknown-lineage-#{member.fetch('pid')}-#{member.dig('unique', 'uniqueid')}"
      end
      raise "classification-hard-stop-#{member.fetch('pid')}" unless
        %w[owned ambient].include?(classification)
      if classification == "ambient" &&
         (member["fixture"] || member["test_runner"])
        raise "ambient-assessment-collision-#{member.fetch('pid')}"
      end
    end
    [inspected, classifications]
  end

  def record_owned!(member, controller: false)
    raise "owned-credentials-#{member.fetch('pid')}" unless
      expected_credentials?(member)
    key = lifetime_key(member)
    entry = @captured[key]
    unless entry
      raise "captured-lifetime-cap" if
        @captured.length >= CAPTURED_LIFETIME_CAP
      entry = {
        "pid" => key.first,
        "uniqueid" => key.last,
        "idversions" => Set.new,
        "parent_epochs" => Set.new,
        "sids" => Set.new,
        "pgids" => Set.new,
      }
      @captured[key] = entry
    end
    entry["idversions"].add(member.dig("unique", "idversion"))
    entry["parent_epochs"].add(parent_epoch_key(member))
    entry["sids"].add(member.fetch("sid"))
    entry["pgids"].add(member.fetch("pgid"))
    assign_class!(member, "owned")
    return if controller
    group = member.fetch("pgid")
    raise "owned-guardian-group-#{member.fetch('pid')}" if
      group == @guardian_pid
    raise "owned-group-invalid-#{group}" unless group > 1
    prior_sid = @group_sids[group]
    raise "group-sid-rebound-#{group}" if
      prior_sid && prior_sid != member.fetch("sid")
    @group_sids[group] = member.fetch("sid")
    @proof_groups.add(group)
    raise "proof-group-cap" if @proof_groups.length > PROOF_GROUP_CAP
    @fixture_lifetimes.add(key) if member["fixture"]
    @test_runner_lifetimes.add(key) if member["test_runner"]
  end

  def arm_direct!(child_pid, controller_epoch, deadline)
    raise "tracker-already-armed" if @armed
    controller = require_joined(@guardian_pid, deadline, "guardian-at-spawn")
    raise "guardian-spawn-epoch-drift" unless
      controller.dig("unique", "uniqueid") == controller_epoch.fetch("uniqueid") &&
      controller.dig("unique", "idversion") ==
        controller_epoch.fetch("idversion")
    child = require_joined(child_pid, deadline, "direct-child")
    raise "direct-child-ppid" unless child.dig("short", "ppid") == @guardian_pid
    raise "direct-child-parent-lifetime" unless
      child.dig("unique", "puniqueid") == controller_epoch.fetch("uniqueid")
    raise "direct-child-parent-epoch" unless
      child.dig("unique", "orig_ppidversion") ==
        controller_epoch.fetch("idversion")
    raise "direct-child-domain" unless
      child["sid"] == @guardian_sid && child["pgid"] == child_pid
    raise "direct-child-ambient-collision" if
      @lifetime_classes[child.dig("unique", "uniqueid")] == "ambient"
    @armed = true
    assign_class!(child, "owned")
    record_owned!(child)
    child
  end

  def observe(deadline)
    raise "tracker-not-armed" unless @armed
    @workspace_registry.update
    records, classifications = classify_records!(
      merged_census(deadline), deadline
    )
    guardian = records.find { |member| member.fetch("pid") == @guardian_pid }
    raise "guardian-generation-missing" unless guardian &&
      classifications[lifetime_key(guardian)] == "owned" &&
      guardian["sid"] == @guardian_sid &&
      guardian["pgid"] == @guardian_pid
    records.each do |member|
      classification = classifications[lifetime_key(member)]
      if classification == "ambient"
        raise "ambient-entered-guardian-session-#{member.fetch('pid')}" if
          member["sid"] == @guardian_sid
        next
      end
      next if member.fetch("pid") == @guardian_pid
      record_owned!(member)
      @unexpected_nested_seen = true if
        member["sid"] != @guardian_sid && !member["fixture"]
    end
    @current_owned = records.select do |member|
      member.fetch("pid") != @guardian_pid &&
        classifications[lifetime_key(member)] == "owned"
    end.sort_by { |member| member.fetch("pid") }
    @scans += 1
    @current_owned
  rescue GuardianDeadline
    raise
  rescue StandardError
    @classification_poisoned = true
    raise
  end

  def classify_group!(records, group, sid, deadline)
    inspected, classifications = classify_records!(records, deadline)
    inspected.each do |member|
      raise "group-membership-domain-#{group}" unless
        member["pgid"] == group && member["sid"] == sid &&
        member.dig("short", "pgid") == group
      raise "group-member-not-owned-#{group}-#{member.fetch('pid')}" unless
        classifications[lifetime_key(member)] == "owned"
      record_owned!(member)
    end
    inspected.sort_by { |member| member.fetch("pid") }
  rescue GuardianDeadline
    raise
  rescue StandardError
    @classification_poisoned = true
    raise
  end

  def captured_lifetimes
    @captured.keys.sort
  end

  def fixture_lifetime_count
    @fixture_lifetimes.length
  end

  def test_runner_lifetime_count
    @test_runner_lifetimes.length
  end

  def captured_receipt
    @captured.keys.sort.map do |key|
      entry = @captured.fetch(key)
      {
        "pid" => entry.fetch("pid"),
        "uniqueid" => entry.fetch("uniqueid"),
        "idversions" => entry.fetch("idversions").to_a.sort,
        "parent_epochs" => entry.fetch("parent_epochs").to_a.sort,
        "sids" => entry.fetch("sids").to_a.sort,
        "pgids" => entry.fetch("pgids").to_a.sort,
      }
    end
  end
end

def group_member_receipt(member)
  {
    "classification" => "owned",
    "pid" => member.fetch("pid"),
    "uniqueid" => member.dig("unique", "uniqueid"),
    "idversion" => member.dig("unique", "idversion"),
    "puniqueid" => member.dig("unique", "puniqueid"),
    "orig_ppidversion" => member.dig("unique", "orig_ppidversion"),
    "sid" => member.fetch("sid"),
    "pgid" => member.fetch("pgid"),
    "status" => member.dig("short", "status"),
    "credentials" => %w[uid gid ruid rgid svuid svgid].map do |field|
      member.dig("short", field)
    end,
  }
end

def receipt_lifetime_key(member)
  [member.fetch("pid"), member.fetch("uniqueid")]
end

def group_snapshot(tracker, group, sid, deadline)
  records = joined_scan(
    deadline, list_type: PROC_PGRP_ONLY, type_info: group, allow_empty: true
  )
  tracker.classify_group!(records, group, sid, deadline).map do |member|
    group_member_receipt(member)
  end.sort_by { |member| member.fetch("pid") }
end

def double_group_snapshot(tracker, group, sid, deadline)
  first = group_snapshot(tracker, group, sid, deadline)
  second = group_snapshot(tracker, group, sid, deadline)
  raise "group-snapshot-race-#{group}" unless first == second
  first
end

def issue_actuation_certificate(
  tracker, action, group, sid, deadline, permitted_lifetimes: nil
)
  raise "actuation-action" unless %w[STOP KILL].include?(action)
  members = double_group_snapshot(tracker, group, sid, deadline)
  return nil if members.empty? && action == "STOP"
  raise "kill-empty-group-#{group}" if members.empty?
  lifetimes = members.map { |member| receipt_lifetime_key(member) }.to_set
  if permitted_lifetimes
    unexpected = lifetimes.reject { |key| permitted_lifetimes.include?(key) }
    raise "late-group-member-#{group}" unless unexpected.empty?
  end
  eligible = if action == "STOP"
    members.all? { |member| [2, 3].include?(member.fetch("status")) }
  else
    members.all? { |member| member.fetch("status") == 4 }
  end
  raise "#{action.downcase}-state-ineligible-#{group}" unless eligible
  {
    "action" => action,
    "group" => group,
    "sid" => sid,
    "members" => members,
    "members_sha256" => Digest::SHA256.hexdigest(canonical_json(members)),
    "issued_monotonic_ns" => monotonic,
    "consumed" => false,
    "signal_call_entered" => false,
    "signal_delivered" => false,
  }
end

def issue_stopped_adoption_certificate(
  tracker, group, sid, deadline, expected_lifetimes:
)
  raise "stopped-adoption-target" unless group > 1 && sid > 0
  members = double_group_snapshot(tracker, group, sid, deadline)
  return nil if members.empty?
  return nil if members.all? do |member|
    [2, 3].include?(member.fetch("status"))
  end
  raise "stopped-adoption-cardinality-#{group}" unless members.length == 1
  member = members.first
  lifetimes = members.map { |entry| receipt_lifetime_key(entry) }
  raise "stopped-adoption-lifetime-#{group}" unless
    lifetimes.to_set == expected_lifetimes &&
      lifetimes.uniq.length == lifetimes.length
  raise "stopped-adoption-member-binding-#{group}" unless
    member.fetch("classification") == "owned" &&
      member.fetch("sid") == sid && member.fetch("pgid") == group &&
      member.fetch("status") == 4 &&
      member.fetch("credentials") == [
        EXPECTED_UID, EXPECTED_GID, EXPECTED_UID, EXPECTED_GID,
        EXPECTED_UID, EXPECTED_GID,
      ]
  {
    "kind" => "STOPPED_ADOPTION",
    "group" => group,
    "sid" => sid,
    "members" => members,
    "members_sha256" => Digest::SHA256.hexdigest(canonical_json(members)),
    "issued_monotonic_ns" => monotonic,
  }
end

ACTUATION_CERTIFICATE_KEYS = %w[
  action consumed group issued_monotonic_ns members members_sha256 sid
  signal_call_entered signal_delivered
].freeze

def consume_actuation_certificate(
  certificate, call_budget, signal_ledger,
  expected_action:, expected_group:, expected_sid:, expected_lifetimes:,
  permitted_lifetimes: nil
)
  raise "certificate-shape" unless certificate.is_a?(Hash) &&
    certificate.keys.sort == ACTUATION_CERTIFICATE_KEYS.sort
  members = certificate.fetch("members")
  raise "certificate-members" unless members.is_a?(Array) && !members.empty? &&
    Digest::SHA256.hexdigest(canonical_json(members)) ==
      certificate.fetch("members_sha256")
  action = certificate.fetch("action")
  group = certificate.fetch("group")
  sid = certificate.fetch("sid")
  raise "certificate-target" unless %w[STOP KILL].include?(action) &&
    group > 1 && sid > 0
  raise "certificate-intent" unless
    action == expected_action && group == expected_group && sid == expected_sid
  member_lifetimes = members.map { |member| receipt_lifetime_key(member) }
  raise "certificate-member-duplicate" unless
    member_lifetimes.uniq.length == member_lifetimes.length &&
      members.map { |member| member.fetch("pid") }.uniq.length == members.length
  raise "certificate-lifetime-intent" unless
    member_lifetimes.to_set == expected_lifetimes
  if permitted_lifetimes
    raise "certificate-lifetime-permission" unless
      member_lifetimes.all? { |key| permitted_lifetimes.include?(key) }
  end
  raise "certificate-consumed" unless
    certificate["consumed"] == false &&
      certificate["signal_call_entered"] == false &&
      certificate["signal_delivered"] == false
  raise "certificate-member-binding" unless members.all? do |member|
    member["classification"] == "owned" &&
      member["sid"] == sid && member["pgid"] == group &&
      member["credentials"] == [501, 20, 501, 20, 501, 20] &&
      (action == "STOP" ? [2, 3].include?(member["status"]) :
        member["status"] == 4)
  end
  issued = certificate.fetch("issued_monotonic_ns")
  now = monotonic
  raise "certificate-expired" unless
    issued <= now && now - issued < CERTIFICATE_MAX_AGE_NS
  key = [action, group]
  raise "signal-call-budget-#{action}-#{group}" unless call_budget[key].nil?
  raise "signal-ledger-cap" if call_budget.length >= SIGNAL_CALL_CAP
  call_budget[key] = 1
  certificate["consumed"] = true
  certificate["signal_call_entered"] = true
  ledger_entry = {
    "sequence" => signal_ledger.length + 1,
    "action" => action,
    "group" => group,
    "sid" => sid,
    "member_count" => members.length,
    "certificate_sha256" => Digest::SHA256.hexdigest(
      canonical_json(certificate.reject do |field, _|
        field == "issued_monotonic_ns"
      end)
    ),
    "call_entered" => true,
    "delivered" => false,
  }
  signal_ledger << ledger_entry
  delivered = Process.kill(action, -group)
  raise "signal-delivery-count-#{action}-#{group}" unless delivered == 1
  certificate["signal_delivered"] = true
  ledger_entry["delivered"] = true
  true
end

class ChildLifecycle
  attr_reader :pid, :status, :reaped_monotonic_ns, :reaped_wall_time

  def initialize(pid)
    @pid = pid
    @status = nil
    @reaped_monotonic_ns = nil
    @reaped_wall_time = nil
  end

  def exact_reaped?
    !@status.nil?
  end

  def poll
    return @status if exact_reaped?
    pair = Process.waitpid2(@pid, Process::WNOHANG)
    return nil unless pair
    raise "wait-wrong-pid" unless pair.first == @pid
    @status = pair.last
    @reaped_monotonic_ns = monotonic
    @reaped_wall_time = Time.now.to_i
  rescue Errno::ECHILD
    raise "wait-lost-owner"
  end
end

class GroupActuator
  attr_reader :signal_ledger, :call_budget, :stopped_groups,
              :adoption_certificates, :poisoned, :disabled, :fault_count

  def initialize(tracker)
    @tracker = tracker
    @signal_ledger = []
    @call_budget = {}
    @stopped_groups = {}
    @adoption_certificates = []
    @poisoned = false
    @disabled = false
    @fault_count = 0
    @fault_receipts = []
    @last_fault = nil
  end

  def poison!
    @poisoned = true
  end

  def disable!
    @disabled = true
    @poisoned = true
  end

  def signaling_disabled?
    disable! if @tracker.classification_poisoned || @tracker.unknown_count > 0
    @disabled
  end

  def record_fault(action, group, error)
    @poisoned = true
    @fault_count += 1
    receipt = {
      "action" => action,
      "group" => group,
      "error" => error_receipt(error),
    }
    @last_fault = receipt
    @fault_receipts << receipt if @fault_receipts.length < SIGNAL_CALL_CAP
    signaling_disabled?
  end

  def retain_rejected_adoption!(group, sid, lifetimes)
    @stopped_groups[group] = {
      "sid" => sid,
      "lifetimes" => lifetimes,
      "stop_certificate" => nil,
      "stop_delivered" => false,
      "stopped_adopted" => false,
      "adoption_certificate" => nil,
      "kill_delivered" => false,
      "empty_without_kill" => false,
      "invalid" => true,
    }
  end

  def stop_current_groups!(owned, deadline)
    groups = owned.group_by do |member|
      [member.fetch("sid"), member.fetch("pgid")]
    end
    groups.keys.sort_by { |sid, group| [group, sid] }.each do |sid, group|
      state = @stopped_groups[group]
      if state
        next if state["invalid"]
        begin
          raise "stopped-group-sid-rebound-#{group}" unless state["sid"] == sid
          current = groups.fetch([sid, group]).map do |member|
            lifetime_key(member)
          end
          late = current.reject { |key| state["lifetimes"].include?(key) }
          raise "late-member-after-stop-#{group}" unless late.empty?
        rescue StandardError => error
          state["invalid"] = true
          record_fault("STOPPED_GROUP", group, error)
        end
        next
      end
      next if signaling_disabled?
      expected_lifetimes = groups.fetch([sid, group]).map do |member|
        lifetime_key(member)
      end.to_set
      fault_action = "ADOPT_STOPPED"
      begin
        adoption = issue_stopped_adoption_certificate(
          @tracker, group, sid, deadline,
          expected_lifetimes: expected_lifetimes
        )
        if adoption
          raise "stopped-adoption-cap" if
            @adoption_certificates.length >= PROOF_GROUP_CAP
          @stopped_groups[group] = {
            "sid" => sid,
            "lifetimes" => expected_lifetimes,
            "stop_certificate" => nil,
            "stop_delivered" => false,
            "stopped_adopted" => true,
            "adoption_certificate" => adoption,
            "kill_delivered" => false,
            "empty_without_kill" => false,
          }
          @adoption_certificates << adoption
          next
        end
        fault_action = "STOP"
        certificate = issue_actuation_certificate(
          @tracker, "STOP", group, sid, deadline
        )
        next unless certificate
        state = {
          "sid" => sid,
          "lifetimes" => expected_lifetimes,
          "stop_certificate" => certificate,
          "stop_delivered" => false,
          "stopped_adopted" => false,
          "kill_delivered" => false,
          "empty_without_kill" => false,
        }
        @stopped_groups[group] = state
        consume_actuation_certificate(
          certificate, @call_budget, @signal_ledger,
          expected_action: "STOP", expected_group: group,
          expected_sid: sid, expected_lifetimes: expected_lifetimes
        )
        state["stop_delivered"] = true
      rescue GuardianDeadline
        if fault_action == "ADOPT_STOPPED"
          retain_rejected_adoption!(group, sid, expected_lifetimes)
        else
          @stopped_groups.delete(group) if @call_budget[["STOP", group]].nil?
        end
        raise
      rescue StandardError => error
        record_fault(fault_action, group, error)
        if fault_action == "ADOPT_STOPPED"
          retain_rejected_adoption!(group, sid, expected_lifetimes)
        else
          @stopped_groups.delete(group) if @call_budget[["STOP", group]].nil?
        end
      end
    end
  end

  def kill_ready_groups!(deadline)
    @stopped_groups.keys.sort.each do |group|
      state = @stopped_groups.fetch(group)
      next if state["kill_delivered"] || state["empty_without_kill"]
      next if state["invalid"]
      next unless state["stop_delivered"] || state["stopped_adopted"]
      next if state.dig("kill_certificate", "signal_call_entered")
      next if signaling_disabled?
      begin
        bases = [state["stop_delivered"], state["stopped_adopted"]].count(true)
        unless bases == 1
          state["invalid"] = true
          raise "kill-basis-partition-#{group}"
        end
        members = double_group_snapshot(
          @tracker, group, state.fetch("sid"), deadline
        )
        if members.empty?
          state["empty_without_kill"] = true
          next
        end
        current = members.map { |member| receipt_lifetime_key(member) }.to_set
        raise "late-member-before-kill-#{group}" unless
          current.all? { |key| state.fetch("lifetimes").include?(key) }
        raise "zombie-before-kill-#{group}" if
          members.any? { |member| member.fetch("status") == 5 }
        next unless members.all? { |member| member.fetch("status") == 4 }
        certificate = issue_actuation_certificate(
          @tracker, "KILL", group, state.fetch("sid"), deadline,
          permitted_lifetimes: state.fetch("lifetimes")
        )
        state["kill_certificate"] = certificate
        consume_actuation_certificate(
          certificate, @call_budget, @signal_ledger,
          expected_action: "KILL", expected_group: group,
          expected_sid: state.fetch("sid"), expected_lifetimes: current,
          permitted_lifetimes: state.fetch("lifetimes")
        )
        state["kill_delivered"] = true
      rescue GuardianDeadline
        state.delete("kill_certificate") if
          @call_budget[["KILL", group]].nil?
        raise
      rescue StandardError => error
        record_fault("KILL", group, error)
        state.delete("kill_certificate") if
          @call_budget[["KILL", group]].nil?
      end
    end
  end

  def receipt
    ledger = @signal_ledger.sort_by { |entry| entry["sequence"] }
    adoptions = @adoption_certificates.sort_by do |certificate|
      certificate.fetch("group")
    end
    raise "stopped-adoption-receipt-cap" if
      adoptions.length > PROOF_GROUP_CAP
    adoption_groups = adoptions.map { |certificate| certificate.fetch("group") }
    raise "stopped-adoption-receipt-duplicate" unless
      adoption_groups.uniq.length == adoption_groups.length
    adoption_rows = adoptions.map do |certificate|
      certificate.reject { |field, _| field == "issued_monotonic_ns" }
    end
    kill_groups = ledger.select do |entry|
      entry.fetch("action") == "KILL"
    end.map { |entry| entry.fetch("group") }
    delivered_stop_groups = ledger.select do |entry|
      entry.fetch("action") == "STOP" && entry.fetch("delivered")
    end.map { |entry| entry.fetch("group") }
    kill_groups.each do |group|
      bases = (delivered_stop_groups.include?(group) ? 1 : 0) +
        (adoption_groups.include?(group) ? 1 : 0)
      raise "kill-basis-partition-#{group}" unless bases == 1
    end
    columns = %w[
      sequence action group sid member_count certificate_sha256
      call_entered delivered
    ]
    rows = ledger.map do |entry|
      columns.map { |field| entry.fetch(field) }
    end
    {
      "signal_calls" => ledger.length,
      "stop_calls" =>
        ledger.count { |entry| entry["action"] == "STOP" },
      "kill_calls" =>
        ledger.count { |entry| entry["action"] == "KILL" },
      "adopted_stopped_group_count" => adoptions.length,
      "adopted_stopped_groups" => adoption_groups,
      "adopted_stopped_certificates_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(adoption_rows)),
      "signal_ledger_columns" => columns,
      "signal_ledger_rows" => rows,
      "signal_ledger_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(ledger)),
      "poisoned" => @poisoned,
      "disabled" => @disabled,
      "fault_count" => @fault_count,
      "fault_receipts_retained" => @fault_receipts.length,
      "fault_receipts_truncated" => @fault_count > @fault_receipts.length,
      "fault_receipts_sha256" =>
        Digest::SHA256.hexdigest(canonical_json(@fault_receipts)),
      "last_fault" => @last_fault,
      "atomic_generation_bound_signal_available" => false,
      "userspace_snapshot_signal_race_named" => true,
    }
  end
end

def wait_generation_absence(pid, uniqueid, deadline)
  loop do
    kind, observed = read_unique(pid, deadline)
    if kind == "gone"
      return {
        "pid" => pid, "uniqueid" => uniqueid,
        "flavor17_observation" => "ESRCH",
      }
    end
    raise "pid-rebound-before-esrch-#{pid}" unless
      observed.fetch("uniqueid") == uniqueid
    sleep(0.001)
  end
end

def wait_group_absence(group, deadline)
  observations = []
  until observations.length == 2
    pids = listed_pids(
      deadline, PROC_PGRP_ONLY, group, allow_empty: true
    )
    unless pids.empty?
      sleep(0.001)
      next
    end
    require_time(deadline, "group-absence-deadline")
    Fiddle.last_error = 0
    result = DarwinProcess.kill(-group, 0)
    error = Fiddle.last_error
    if result == -1 && error == ERRNO_ESRCH
      observations << {
        "group" => group,
        "process_list_observation" => "EMPTY",
        "signal_zero_observation" => "ESRCH",
        "signal_zero_errno" => error,
      }
    else
      sleep(0.001)
    end
  end
  observations
end

def prove_process_conservation(tracker, lifecycle, deadline)
  raise "direct-child-not-reaped" unless lifecycle.exact_reaped?
  raise "sticky-terminal-classification" if
    tracker.classification_poisoned || tracker.unknown_count > 0
  2.times do
    raise "owned-domain-not-empty" unless tracker.observe(deadline).empty?
  end
  generation_observations = tracker.captured_lifetimes.flat_map do |pid, uniqueid|
    [
      wait_generation_absence(pid, uniqueid, deadline),
      wait_generation_absence(pid, uniqueid, deadline),
    ]
  end
  group_observations = tracker.proof_groups.to_a.sort.flat_map do |group|
    wait_group_absence(group, deadline)
  end
  captured = tracker.captured_receipt
  {
    "empty_owned_scans" => 2,
    "captured_lifetime_count" => captured.length,
    "captured_lifetimes_sha256" =>
      Digest::SHA256.hexdigest(canonical_json(captured)),
    "generation_esrch_observations" => generation_observations.length,
    "generation_esrch_sha256" =>
      Digest::SHA256.hexdigest(canonical_json(generation_observations)),
    "proof_group_count" => tracker.proof_groups.length,
    "proof_groups" => tracker.proof_groups.to_a.sort,
    "group_absence_observations" => group_observations.length,
    "group_absence_sha256" =>
      Digest::SHA256.hexdigest(canonical_json(group_observations)),
  }
end

def contain_until_reaped_and_empty(
  tracker, lifecycle, hard_deadline, report
)
  actuator = GroupActuator.new(tracker)
  deadline = hard_deadline
  loop do
    begin
      owned = tracker.observe(deadline)
    rescue GuardianDeadline => error
      report["hard_deadline_crossed"] = true
      report["containment_deadline_coordinate"] ||= error.message
      deadline = nil
      owned = tracker.current_owned
    rescue StandardError => error
      report["containment_fault_count"] += 1
      report["last_containment_fault"] = error_receipt(error)
      actuator.disable!
      deadline = nil
      owned = tracker.current_owned
    end
    begin
      lifecycle.poll
      actuator.stop_current_groups!(owned, deadline)
      actuator.kill_ready_groups!(deadline)
    rescue GuardianDeadline => error
      report["hard_deadline_crossed"] = true
      report["containment_deadline_coordinate"] ||= error.message
      deadline = nil
    rescue StandardError => error
      report["containment_fault_count"] += 1
      report["last_containment_fault"] = error_receipt(error)
      actuator.poison!
      deadline = nil
    end
    begin
      lifecycle.poll
      break if lifecycle.exact_reaped? &&
        tracker.observe(deadline).empty?
    rescue GuardianDeadline => error
      report["hard_deadline_crossed"] = true
      report["containment_deadline_coordinate"] ||= error.message
      deadline = nil
    rescue StandardError => error
      report["containment_fault_count"] += 1
      report["last_containment_fault"] = error_receipt(error)
      actuator.disable!
      deadline = nil
    end
    sleep(0.01)
  end
  [actuator, deadline]
end

def verify_epoch
  raise "epoch-inventory" unless Dir.children(EPOCH).sort == EPOCH_CHILDREN.sort
  parent = open_held(EPOCH, directory: true)
  parent_stat = rejoin(EPOCH, parent, directory: true)
  raise "epoch-security" unless
    [parent_stat.uid, parent_stat.mode & 0o7777] == [EXPECTED_UID, 0o700]
  children = EPOCH_CHILDREN.to_h do |leaf|
    path = "#{EPOCH}/#{leaf}"
    io = open_held(path, directory: true)
    stat = rejoin(path, io, directory: true)
    raise "epoch-child-security-#{leaf}" unless
      [stat.uid, stat.gid, stat.mode & 0o7777] ==
        [EXPECTED_UID, parent_stat.gid, 0o700]
    raise "epoch-child-nonempty-#{leaf}" unless Dir.children(path).empty?
    [leaf, io]
  end
  [parent, children]
end

def path_absent?(path)
  File.lstat(path)
  false
rescue Errno::ENOENT
  true
end

def full_fsync(io)
  Fiddle.last_error = 0
  result = DarwinProcess.fcntl(io.fileno, F_FULLFSYNC)
  error = Fiddle.last_error
  raise "fullfsync-#{error}" unless result == 0
  true
end

def sync_io(io)
  io.fsync
  full_fsync(io)
  true
end

def held_bytes(io)
  io.flush
  io.seek(0)
  bytes = io.read
  io.seek(0)
  bytes
end

def rejoin_regular(path, io)
  named = File.lstat(path)
  held = io.stat
  raise "terminal-file-type-#{path}" unless named.file? && held.file?
  raise "terminal-file-rebound-#{path}" unless
    [named.dev, named.ino] == [held.dev, held.ino]
  held
end

def validate_terminal_file(io, parent_stat, mode:, size:)
  stat = io.stat
  expected = [
    parent_stat.dev, EXPECTED_UID, parent_stat.gid, mode, 1, size,
  ]
  observed = [
    stat.dev, stat.uid, stat.gid, stat.mode & 0o7777, stat.nlink, stat.size,
  ]
  raise "terminal-file-metadata" unless observed == expected && stat.file?
  raise "terminal-file-cloexec" unless io.close_on_exec?
  stat
end

def persist_terminal(report, epoch_parent)
  raise "terminal-preexists" unless path_absent?(TERMINAL)
  parent_stat = rejoin(EPOCH, epoch_parent, directory: true)
  template_bytes = TERMINAL_STAGING_TEMPLATE + "\0"
  template = Fiddle::Pointer.malloc(template_bytes.bytesize)
  template[0, template_bytes.bytesize] = template_bytes
  Fiddle.last_error = 0
  descriptor = DarwinProcess.mkostempsat_np(
    epoch_parent.fileno, template, TERMINAL_STAGING_SUFFIX_LENGTH, O_CLOEXEC
  )
  error = Fiddle.last_error
  raise "terminal-mkostempsat-#{error}" unless descriptor >= 3
  leaf = template.to_s(
    TERMINAL_STAGING_TEMPLATE.bytesize
  ).split("\0", 2).first
  raise "terminal-staging-leaf-#{leaf}" unless
    TERMINAL_STAGING_LEAF.match?(leaf)
  staging_path = "#{EPOCH}/#{leaf}"
  io = File.new(descriptor, "r+")
  begin
    initial = rejoin_regular(staging_path, io)
    validate_terminal_file(io, parent_stat, mode: 0o600, size: 0)
    Fiddle.last_error = 0
    chmod_result = DarwinProcess.fchmod(io.fileno, 0o400)
    chmod_error = Fiddle.last_error
    raise "terminal-fchmod-#{chmod_error}" unless chmod_result == 0
    validate_terminal_file(io, parent_stat, mode: 0o400, size: 0)

    report["terminal_publication"] = {
      "primitive" => "mkostempsat_np+fchmod+renameatx_np",
      "generated_staging_leaf" => leaf,
      "published_leaf" => TERMINAL_LEAF,
      "staging_initial_mode" => "0600",
      "sealed_mode" => "0400",
      "rename_flags" => RENAME_EXCL | RENAME_NOFOLLOW_ANY,
      "published_no_replace" => true,
      "post_publish_parent_sync_required" => true,
    }
    payload = canonical_json(report)
    terminal_report = report.merge(
      "payload_sha256" => Digest::SHA256.hexdigest(payload)
    )
    bytes = canonical_json(terminal_report) + "\n"
    raise "terminal-cap" if bytes.bytesize > TERMINAL_MAX_BYTES
    written = io.write(bytes)
    raise "terminal-short-write" unless written == bytes.bytesize
    sync_io(io)
    staged = rejoin_regular(staging_path, io)
    validate_terminal_file(
      io, parent_stat, mode: 0o400, size: bytes.bytesize
    )
    raise "terminal-readback" unless held_bytes(io) == bytes
    raise "terminal-byte-hash" unless
      held_sha256(io) == Digest::SHA256.hexdigest(bytes)
    raise "terminal-staging-vnode" unless
      [initial.dev, initial.ino] == [staged.dev, staged.ino]
    sync_io(epoch_parent)

    raise "terminal-final-appeared" unless path_absent?(TERMINAL)
    Fiddle.last_error = 0
    rename_result = DarwinProcess.renameatx_np(
      epoch_parent.fileno, leaf, epoch_parent.fileno, TERMINAL_LEAF,
      RENAME_EXCL | RENAME_NOFOLLOW_ANY
    )
    rename_error = Fiddle.last_error
    raise "terminal-rename-#{rename_error}" unless rename_result == 0
    begin
      raise "terminal-staging-remains" unless path_absent?(staging_path)
      final_stat = rejoin_regular(TERMINAL, io)
      raise "terminal-published-vnode" unless
        [final_stat.dev, final_stat.ino] == [initial.dev, initial.ino]
      validate_terminal_file(
        io, parent_stat, mode: 0o400, size: bytes.bytesize
      )
      raise "terminal-published-bytes" unless held_bytes(io) == bytes
      sync_io(epoch_parent)
      parent_stat = rejoin(EPOCH, epoch_parent, directory: true)
      final_stat = rejoin_regular(TERMINAL, io)
      validate_terminal_file(
        io, parent_stat, mode: 0o400, size: bytes.bytesize
      )
      raise "terminal-published-vnode-after-sync" unless
        [final_stat.dev, final_stat.ino] == [initial.dev, initial.ino]
    rescue StandardError => error
      raise TerminalPostcommitFailure, canonical_json(error_receipt(error))
    end
    bytes
  ensure
    begin
      io.close unless io.closed?
    rescue StandardError
      nil
    end
  end
end

$interrupted = nil
SIGNALS.each { |signal| Signal.trap(signal) { $interrupted ||= signal } }
incoming_umask = File.umask(0o077)

report = {
  "schema" => "prime-driver-v2-r18-guardian/v1",
  "status" => "R18_GUARDIAN_PRELAUNCH_FAILED",
  "authority_vector" => "00000000",
  "scientific_authorities_closed" => 0,
  "missing_authority_count" => 8,
  "gate_e_outcome" => "ABSTAIN",
  "gate_e_clearance" => 0,
  "process_census_scope" =>
    "ruid:501+global-session+flavor17+shortbsd",
  "xnu_abi_source" => XNU_ABI_SOURCE,
  "atomic_generation_bound_signal_available" => false,
  "userspace_snapshot_signal_race_named" => true,
  "uncatchable_guardian_stop_or_kill_named" => true,
  "child_started_at" => nil,
  "child_ended_at" => nil,
  "child_raw_status" => nil,
  "child_exit_status" => nil,
  "child_term_signal" => nil,
  "assessment_start_monotonic_ns" => nil,
  "assessment_elapsed_ns" => nil,
  "ordinary_cutoff_ns" => CHILD_NANOSECONDS,
  "containment_horizon_ns" => HARD_NANOSECONDS,
  "containment_started_elapsed_ns" => nil,
  "child_reaped_elapsed_ns" => nil,
  "interrupted_signal" => nil,
  "timed_out" => false,
  "containment_started" => false,
  "process_containment_complete" => false,
  "hard_deadline_crossed" => false,
  "containment_fault_count" => 0,
  "complete_scan_count" => 0,
  "terminal_unknown_count" => 0,
  "workspace_baseline_count" => 0,
  "workspace_baseline_sha256" => nil,
  "held_workspace_count" => 0,
  "workspace_rebound_seen" => false,
  "incoming_umask" => format("%04o", incoming_umask),
}

child_pid = nil
spawn_committed = false
direct_generation_joined = false
lifecycle = nil
tracker = nil
fixture_io = nil
epoch_parent = nil
epoch_children = nil
source_io = nil
workspace_registry = nil
hard_deadline = nil
started_monotonic = nil
operational_error = nil
process_proof = false
process_conservation = nil
actuator = nil
pid1_probe = nil
direct_child_join = nil
runtime_sysctls = nil

begin
  raise "guardian-umask" unless incoming_umask == 0o077
  raise "guardian-ruby" unless
    [RUBY_VERSION, RUBY_PATCHLEVEL, RUBY_PLATFORM] ==
      ["2.6.10", 210, "universal.arm64e-darwin25"]
  raise "guardian-pointer-width" unless [0].pack("J").bytesize == 8
  raise "guardian-byte-order" unless [1].pack("L").bytes == [1, 0, 0, 0]
  raise "guardian-credentials" unless
    [Process.uid, Process.euid, Process.gid, Process.egid] ==
      [EXPECTED_UID, EXPECTED_UID, EXPECTED_GID, EXPECTED_GID]
  raise "guardian-supplementary-groups" unless
    Process.groups.sort == EXPECTED_GROUPS
  runtime_sysctls = EXPECTED_SYSCTLS.keys.each_with_object({}) do |name, result|
    result[name] = checked_sysctl_string(name)
  end
  raise "guardian-sysctls" unless runtime_sysctls == EXPECTED_SYSCTLS

  source_io = open_held(SOURCE, directory: true)
  source_stat = rejoin(SOURCE, source_io, directory: true)
  raise "source-identity" unless
    [source_stat.dev, source_stat.ino] == SOURCE_IDENTITY
  epoch_parent, epoch_children = verify_epoch
  fixture_io = open_held(FIXTURE)
  verify_fixture(fixture_io)

  guardian_sid = Process.setsid
  guardian_pid = Process.pid
  raise "guardian-session" unless guardian_sid == guardian_pid &&
    Process.getsid(0) == guardian_pid && Process.getpgrp == guardian_pid
  preflight_deadline = monotonic + 15_000_000_000
  guardian_join = require_joined(
    guardian_pid, preflight_deadline, "guardian"
  )
  raise "guardian-ruby-image" unless
    guardian_join.dig("unique", "uuid_hex") ==
      "eb2540b7e13236beb719619d0fbf7203"
  raise "guardian-joined-domain" unless
    guardian_join["sid"] == guardian_pid &&
      guardian_join["pgid"] == guardian_pid
  pid1_probe = pid1_abi_probe(preflight_deadline)

  workspace_registry = WorkspaceRegistry.new
  raise "workspace-baseline" unless
    workspace_registry.baseline.length == ADMISSION_BASELINE_COUNT &&
    workspace_registry.baseline_sha256 == ADMISSION_BASELINE_SHA256
  tracker = Tracker.new(fixture_io, guardian_join, workspace_registry)
  tracker.capture_ambient_baseline!(preflight_deadline)
  2.times do
    raise "workspace-preflight-drift" unless
      workspace_registry.preflight_unchanged?
  end
  verify_fixture(fixture_io)
  rejoin(SOURCE, source_io, directory: true)
  rejoin(EPOCH, epoch_parent, directory: true)
  raise "interrupted-before-spawn:#{$interrupted}" if $interrupted

  started_monotonic = monotonic
  ordinary_deadline = started_monotonic + CHILD_NANOSECONDS
  hard_deadline = started_monotonic + HARD_NANOSECONDS
  report["assessment_start_monotonic_ns"] = started_monotonic
  controller_at_spawn = require_joined(
    guardian_pid, ordinary_deadline, "guardian-immediately-before-spawn"
  ).fetch("unique")
  child_pid = Process.spawn(
    SWIFT_ENV,
    *SWIFT_ARGV,
    chdir: SOURCE,
    in: File::NULL,
    pgroup: true,
    close_others: true,
    unsetenv_others: true,
    umask: 0o077
  )
  spawn_committed = true
  report["child_started_at"] = Time.now.to_i
  lifecycle = ChildLifecycle.new(child_pid)
  direct_child_join = tracker.arm_direct!(
    child_pid, controller_at_spawn, ordinary_deadline
  )
  direct_generation_joined = true

  loop do
    lifecycle.poll
    break if lifecycle.exact_reaped? || $interrupted
    if monotonic >= ordinary_deadline
      report["timed_out"] = true
      break
    end
    begin
      tracker.observe(ordinary_deadline)
    rescue GuardianDeadline
      report["timed_out"] = true
      break
    end
    lifecycle.poll
    break if lifecycle.exact_reaped?
    remaining = (ordinary_deadline - monotonic).fdiv(1_000_000_000)
    if remaining <= 0
      report["timed_out"] = true
      break
    end
    sleep([TRACK_INTERVAL, remaining].min)
  end

  report["interrupted_signal"] = $interrupted
  current_owned = tracker.observe(hard_deadline)
  if !lifecycle.exact_reaped? || !current_owned.empty? ||
     $interrupted || report["timed_out"]
    report["containment_started"] = true
    report["containment_started_elapsed_ns"] =
      monotonic - started_monotonic
    actuator, hard_deadline = contain_until_reaped_and_empty(
      tracker, lifecycle, hard_deadline, report
    )
  else
    actuator = GroupActuator.new(tracker)
  end

  proof_deadline = hard_deadline
  loop do
    begin
      process_conservation = prove_process_conservation(
        tracker, lifecycle, proof_deadline
      )
      break
    rescue GuardianDeadline => error
      report["hard_deadline_crossed"] = true
      report["containment_deadline_coordinate"] ||= error.message
      proof_deadline = nil
    rescue StandardError => error
      report["containment_fault_count"] += 1
      report["last_containment_fault"] = error_receipt(error)
      actuator.poison!
      proof_deadline = nil
      sleep(0.01)
    end
  end
  process_proof = true
  report["process_containment_complete"] = true

  verify_fixture(fixture_io)
  rejoin(SOURCE, source_io, directory: true)
  rejoin(EPOCH, epoch_parent, directory: true)
  raise "epoch-inventory-post" unless
    Dir.children(EPOCH).sort == EPOCH_CHILDREN.sort
  epoch_children.each do |leaf, io|
    rejoin("#{EPOCH}/#{leaf}", io, directory: true)
  end
rescue StandardError => error
  operational_error ||= error
  if spawn_committed
    # A numeric PID/group without the exact direct generation and original
    # parent epoch never acquires signal or terminal authority.
    loop { sleep(60.0) } unless direct_generation_joined
    unless process_proof
      report["containment_started"] = true
      report["containment_started_elapsed_ns"] ||=
        monotonic - started_monotonic
      actuator, hard_deadline = contain_until_reaped_and_empty(
        tracker, lifecycle, hard_deadline, report
      )
      proof_deadline = hard_deadline
      loop do
        begin
          process_conservation = prove_process_conservation(
            tracker, lifecycle, proof_deadline
          )
          process_proof = true
          report["process_containment_complete"] = true
          break
        rescue GuardianDeadline => proof_error
          report["hard_deadline_crossed"] = true
          report["containment_deadline_coordinate"] ||= proof_error.message
          proof_deadline = nil
        rescue StandardError => proof_error
          report["containment_fault_count"] += 1
          report["last_containment_fault"] = error_receipt(proof_error)
          actuator.poison!
          proof_deadline = nil
          sleep(0.01)
        end
      end
    end
  end
end

SIGNALS.each { |signal| Signal.trap(signal, "IGNORE") }
report["interrupted_signal"] = $interrupted
report["assessment_elapsed_ns"] =
  monotonic - started_monotonic if started_monotonic
if lifecycle&.status
  report["child_raw_status"] = lifecycle.status.to_i
  report["child_exit_status"] = lifecycle.status.exitstatus
  report["child_term_signal"] = lifecycle.status.termsig
  report["child_ended_at"] = lifecycle.reaped_wall_time
  report["child_reaped_elapsed_ns"] =
    lifecycle.reaped_monotonic_ns - started_monotonic
end
if tracker
  captured = tracker.captured_receipt
  report["complete_scan_count"] = tracker.scans
  report["terminal_unknown_count"] = tracker.unknown_count
  report["ambient_baseline_sweeps"] = tracker.baseline_rows
  report["captured_lifetime_count"] = captured.length
  report["captured_lifetimes_sha256"] =
    Digest::SHA256.hexdigest(canonical_json(captured))
  report["captured_fixture_lifetimes"] =
    tracker.fixture_lifetime_count
  report["captured_test_runner_lifetimes"] =
    tracker.test_runner_lifetime_count
  report["proof_groups"] = tracker.proof_groups.to_a.sort
  report["unexpected_nested_session_seen"] =
    tracker.unexpected_nested_seen
end
if workspace_registry
  report["workspace_baseline_count"] = workspace_registry.baseline.length
  report["workspace_baseline_sha256"] =
    workspace_registry.baseline_sha256
  report["held_workspace_count"] = workspace_registry.held_workspace_count
  report["workspace_rebound_seen"] = workspace_registry.rebound_seen
end
report["pid1_abi_probe"] = pid1_probe if pid1_probe
report["runtime_sysctls"] = runtime_sysctls if runtime_sysctls
report["direct_child"] =
  tracker.public_identity(direct_child_join) if tracker && direct_child_join
report["actuation"] = actuator.receipt if actuator
report["process_conservation"] = process_conservation if process_conservation
report["error"] = error_receipt(operational_error) if operational_error

if spawn_committed && process_proof
  natural = operational_error.nil? && lifecycle.status&.success? &&
    !$interrupted && !report["timed_out"] &&
    !report["containment_started"] &&
    actuator.signal_ledger.empty? &&
    !actuator.poisoned && report["containment_fault_count"] == 0 &&
    !report["hard_deadline_crossed"] &&
    tracker.unknown_count == 0 &&
    !tracker.classification_poisoned &&
    !tracker.unexpected_nested_seen &&
    !workspace_registry.rebound_seen &&
    report["assessment_elapsed_ns"] < CHILD_NANOSECONDS
  report["status"] = natural ?
    "R18_GUARDIAN_NATURAL_EXIT" : "R18_GUARDIAN_CONTAINED_ABNORMAL"
  begin
    terminal_bytes = persist_terminal(report, epoch_parent)
  rescue TerminalPostcommitFailure => terminal_error
    diagnostic = {
      "schema" => "prime-driver-v2-r18-guardian/v1",
      "status" => "R18_GUARDIAN_TERMINAL_POSTCOMMIT_UNCERTAIN",
      "authority_vector" => "00000000",
      "gate_e_outcome" => "ABSTAIN",
      "gate_e_clearance" => 0,
      "process_containment_complete" => process_proof,
      "immutable_final_publication_entered" => true,
      "error" => error_receipt(terminal_error),
    }
    begin
      STDERR.write(canonical_json(diagnostic) + "\n")
      STDERR.flush
    rescue StandardError
      nil
    end
    exit 70
  rescue StandardError => terminal_error
    failure = {
      "schema" => "prime-driver-v2-r18-guardian/v1",
      "status" => "R18_GUARDIAN_TERMINAL_FAILED",
      "authority_vector" => "00000000",
      "gate_e_outcome" => "ABSTAIN",
      "gate_e_clearance" => 0,
      "process_containment_complete" => process_proof,
      "immutable_final_publication_entered" => false,
      "error" => error_receipt(terminal_error),
    }
    STDERR.write(canonical_json(failure) + "\n")
    STDERR.flush
    exit 70
  end
  begin
    written = STDOUT.write(terminal_bytes)
    STDOUT.flush if written == terminal_bytes.bytesize
  rescue StandardError
    nil
  end
  exit(natural ? 0 : 70)
end

failure = report.merge(
  "status" => "R18_GUARDIAN_PRELAUNCH_FAILED",
  "process_containment_complete" => false
)
STDERR.write(canonical_json(failure) + "\n")
STDERR.flush
exit 70
